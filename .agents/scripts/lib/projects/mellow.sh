#!/usr/bin/env bash

is_mellow_project_context() {
  local project_path="${1:-}"
  local repo_root="${2:-}"
  local main_repo="${3:-}"

  [[ "$project_path" == "$HOME/mellow" || "$project_path" == "$HOME/mellow/"* || "$repo_root" == "$HOME/mellow" || "$main_repo" == "$HOME/mellow" ]]
}

mellow_create_worktree() {
  local repo_root="$1"
  local branch_name="$2"
  local target

  is_mellow_project_context "" "$repo_root" "" || fail "project-mismatch:mellow"
  need mellow

  target="$HOME/worktrees/${branch_name//\//-}"
  if [[ -e "$target" ]]; then
    fail "worktree-target-exists:$target"
  fi

  mellow worktree add "$branch_name"
}

mellow_delete_worktree() {
  local task_path="$1"
  local main_repo="$2"

  is_mellow_project_context "$task_path" "" "$main_repo" || fail "project-mismatch:mellow"
  need mellow
  mellow worktree delete "$task_path"
}
