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
task_path="$(git rev-parse --show-toplevel 2>/dev/null)" || fail "not-a-git-repo"
git_dir="$(git rev-parse --git-dir)"
common_dir="$(git rev-parse --git-common-dir)"

if [[ "$git_dir" == "$common_dir" ]]; then
  fail "main-worktree"
fi

project_context_load "$task_path"
main_repo="$PROJECT_CONTEXT_MAIN_REPO"
effective_project="$PROJECT_CONTEXT_KIND"
[[ -n "$main_repo" ]] || fail "main-repo-not-found"
task_branch="$(git branch --show-current)"
base_branch="$(git -C "$main_repo" branch --show-current)"
status_output="$(git -C "$task_path" status --short)"

if [[ -n "$status_output" ]]; then
  fail "dirty-worktree"
fi

git -C "$task_path" rebase "$base_branch"
git -C "$main_repo" merge --ff-only "$task_branch"

if project_delete_worktree "$effective_project" "$task_path" "$main_repo"; then
  :
else
  cd /
  git -C "$main_repo" branch -d "$task_branch"
  git -C "$main_repo" worktree remove --force "$task_path"
fi

say "project=$effective_project"
say "merge=ok:$task_branch->$base_branch"
say "cleanup=ok:$task_path"
close_workspace "$workspace_ref"
