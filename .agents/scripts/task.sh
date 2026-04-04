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

PROJECT_PATH=""
WORKTREE_BRANCH=""
WORKSPACE_NAME=""
PROMPT_TEXT=""

derive_workspace_name() {
  local target_cwd="$1"
  local branch_name="$2"

  if [[ -n "$WORKSPACE_NAME" ]]; then
    printf '%s\n' "$WORKSPACE_NAME"
  elif [[ -n "$branch_name" ]]; then
    printf '%s\n' "$branch_name"
  else
    printf 'MAIN:%s\n' "$(basename "$target_cwd")"
  fi
}

main() {
  local base_cwd repo_root main_repo effective_project branch_name target_cwd workspace_name launch_command

  [[ -n "$PROJECT_PATH" ]] || fail "missing-project-path"
  [[ -n "$PROMPT_TEXT" ]] || fail "missing-prompt"
  [[ -d "$PROJECT_PATH" ]] || fail "project-path-not-found:$PROJECT_PATH"

  project_context_load "$PROJECT_PATH"
  base_cwd="$PROJECT_CONTEXT_PATH"
  repo_root="$PROJECT_CONTEXT_REPO_ROOT"
  main_repo="$PROJECT_CONTEXT_MAIN_REPO"
  effective_project="$PROJECT_CONTEXT_KIND"
  target_cwd="$base_cwd"
  branch_name=""

  if [[ -n "$WORKTREE_BRANCH" ]]; then
    [[ -n "$repo_root" ]] || fail "not-a-git-repo"
    branch_name="$WORKTREE_BRANCH"
    target_cwd="$(project_create_worktree "$effective_project" "$repo_root" "$branch_name")"
  elif [[ -n "$repo_root" ]]; then
    target_cwd="$repo_root"
  fi

  workspace_name="$(derive_workspace_name "$target_cwd" "$branch_name")"
  launch_command="AGENT_TASK_WORKSPACE=1 agent open $(shell_quote "$PROMPT_TEXT")"

  say "project=$effective_project"
  launch_workspace "$workspace_name" "$target_cwd" "$launch_command"
  [[ -n "$branch_name" ]] && say "branch=$branch_name"
  say "prompt=inline"
}

need agent
need cmux
need jq

while [[ $# -gt 0 ]]; do
  case "$1" in
    --worktree)
      WORKTREE_BRANCH="${2:-}"
      shift 2
      ;;
    --workspace-name)
      WORKSPACE_NAME="${2:-}"
      shift 2
      ;;
    --prompt)
      PROMPT_TEXT="${2:-}"
      shift 2
      ;;
    -*)
      fail "unknown-arg:$1"
      ;;
    *)
      [[ -z "$PROJECT_PATH" ]] || fail "extra-arg:$1"
      PROJECT_PATH="$1"
      shift
      ;;
  esac
done

main
