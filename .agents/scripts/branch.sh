#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]}"
while [[ -L "$SOURCE_PATH" ]]; do
  SOURCE_DIR="$(cd -P -- "$(dirname -- "$SOURCE_PATH")" && pwd)"
  SOURCE_PATH="$(readlink "$SOURCE_PATH")"
  [[ "$SOURCE_PATH" != /* ]] && SOURCE_PATH="$SOURCE_DIR/$SOURCE_PATH"
done
SCRIPT_DIR="$(cd -P -- "$(dirname -- "$SOURCE_PATH")" && pwd)"
source "$SCRIPT_DIR/lib/init.sh"

PROMPT_TEXT="${*:-}"

current_session_id() {
  local session_id="${CODEX_THREAD_ID:-}"

  if [[ -n "$session_id" ]]; then
    printf '%s\n' "$session_id"
    return 0
  fi

  agent sessions \
    | jq -r --argjson pid "$PPID" 'select(.pid == $pid) | .id' \
    | head -n 1
}

derive_tab_name() {
  local prompt_text="$1"
  local slug

  if [[ -z "$prompt_text" ]]; then
    printf 'branch\n'
    return 0
  fi

  slug="$(slugify "$prompt_text")"
  slug="${slug:0:24}"
  [[ -n "$slug" ]] || slug="branch"
  printf 'branch:%s\n' "$slug"
}

main() {
  local identify_json pane_ref workspace_ref target_surface session_id tab_name launch_command

  identify_json="$(cmux identify --json)"
  pane_ref="$(printf '%s' "$identify_json" | jq -r '.caller.pane_ref // empty')"
  workspace_ref="$(printf '%s' "$identify_json" | jq -r '.caller.workspace_ref // empty')"

  [[ -n "$pane_ref" ]] || fail "not-in-cmux-pane"
  [[ -n "$workspace_ref" ]] || fail "not-in-cmux-workspace"

  session_id="$(current_session_id)"
  [[ -n "$session_id" ]] || fail "current-session-not-found"

  target_surface="$(cmux --json new-surface --pane "$pane_ref" | jq -r '.surface_ref')"
  [[ -n "$target_surface" ]] || fail "surface-create-failed"

  tab_name="$(derive_tab_name "$PROMPT_TEXT")"
  cmux rename-tab --workspace "$workspace_ref" --surface "$target_surface" "$tab_name"

  launch_command="cd $(shell_quote "$PWD") && agent fork $(shell_quote "$session_id")"
  if [[ -n "$PROMPT_TEXT" ]]; then
    launch_command="$launch_command $(shell_quote "$PROMPT_TEXT")"
  fi

  cmux send --workspace "$workspace_ref" --surface "$target_surface" "$launch_command\n"

  say "surface=created:$target_surface"
  say "session=$session_id"
  [[ -n "$PROMPT_TEXT" ]] && say "prompt=inline"
}

need agent
need cmux
need jq

main
