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

need cmux
need git
need jq

[[ $# -eq 0 ]] || fail "unknown-arg:$1"

workspace_ref="$(current_workspace_ref)"

if ! task_path="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  say "project=generic"
  say "worktree=skipped:not-a-git-repo"
  close_workspace "$workspace_ref"
  exit 0
fi

git_dir="$(git rev-parse --git-dir)"
common_dir="$(git rev-parse --git-common-dir)"

if [[ "$git_dir" == "$common_dir" ]]; then
  project_context_load "$task_path"
  say "project=$PROJECT_CONTEXT_KIND"
  say "worktree=skipped:main-worktree"
  close_workspace "$workspace_ref"
  exit 0
fi

project_context_load "$task_path"
main_repo="$PROJECT_CONTEXT_MAIN_REPO"
effective_project="$PROJECT_CONTEXT_KIND"
[[ -n "$main_repo" ]] || fail "main-repo-not-found"
branch="$(git branch --show-current || true)"
project_delete_worktree "$effective_project" "$task_path" "$main_repo" "$branch" -D || true

say "project=$effective_project"
say "worktree=deleted:$task_path"
close_workspace "$workspace_ref"
