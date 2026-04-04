#!/usr/bin/env bash

source "$SCRIPT_LIB_DIR/projects/mellow.sh"

project_context_load() {
  local base_path="${1:-$PWD}"

  PROJECT_CONTEXT_PATH="$(cd "$base_path" && pwd)"
  PROJECT_CONTEXT_REPO_ROOT="$(git -C "$PROJECT_CONTEXT_PATH" rev-parse --show-toplevel 2>/dev/null || true)"
  PROJECT_CONTEXT_MAIN_REPO=""
  if [[ -n "$PROJECT_CONTEXT_REPO_ROOT" ]]; then
    PROJECT_CONTEXT_MAIN_REPO="$(cd "$PROJECT_CONTEXT_PATH" && find_main_repo || true)"
  fi
  PROJECT_CONTEXT_KIND="$(project_resolve "$PROJECT_CONTEXT_PATH" "$PROJECT_CONTEXT_REPO_ROOT" "$PROJECT_CONTEXT_MAIN_REPO")"
}

project_resolve() {
  local project_path="${1:-}"
  local repo_root="${2:-}"
  local main_repo="${3:-}"

  if is_mellow_project_context "$project_path" "$repo_root" "$main_repo"; then
    printf 'mellow\n'
  else
    printf 'generic\n'
  fi
}

project_create_worktree() {
  local project="$1"
  shift

  case "$project" in
    mellow)
      mellow_create_worktree "$@"
      ;;
    generic)
      create_generic_worktree "$@"
      ;;
    *)
      fail "unknown-project:$project"
      ;;
  esac
}

project_delete_worktree() {
  local project="$1"
  local task_path main_repo branch_name branch_delete_flag
  shift

  case "$project" in
    mellow)
      mellow_delete_worktree "$@"
      ;;
    generic)
      task_path="${1:-}"
      main_repo="${2:-}"
      branch_name="${3:-}"
      branch_delete_flag="${4:--d}"
      delete_generic_worktree "$main_repo" "$task_path" "$branch_name" "$branch_delete_flag"
      ;;
    *)
      fail "unknown-project:$project"
      ;;
  esac
}
