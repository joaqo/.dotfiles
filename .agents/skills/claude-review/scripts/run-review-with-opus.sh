#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
agent_bin="$(command -v agent)"
claude_bin="$(command -v claude)"
temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/claude-review.XXXXXX")"
debug_log="$temp_dir/debug.log"

cleanup() {
  [[ -e "$debug_log" ]] && unlink "$debug_log"
  [[ -L "$temp_dir/latest" ]] && unlink "$temp_dir/latest"
  rmdir "$temp_dir" 2>/dev/null || true
}
trap cleanup EXIT

export CLAUDE_REVIEW_REAL_CLAUDE="$claude_bin"
export CLAUDE_REVIEW_DEBUG_LOG="$debug_log"

prompt="Review the uncommitted changes in the current working directory. Focus on bugs, risks, behavioral regressions, and missing tests. Reply with only the final review summary."
review="$(PATH="$script_dir:$PATH" ANTHROPIC_MODEL=opus "$agent_bin" exec claude "$prompt" --ephemeral)"

model_line="$(rg '\[API:timing\] dispatching to firstParty model=' "$debug_log" | tail -n 1 || true)"
model="${model_line##*model=}"
model="${model%% *}"

if [[ "$model" != claude-opus-* ]]; then
  printf 'Claude review aborted: expected Opus, final API dispatch was %s\n' "${model:-unknown}" >&2
  exit 1
fi

printf 'Verified model: %s\n\n%s\n' "$model" "$review"
