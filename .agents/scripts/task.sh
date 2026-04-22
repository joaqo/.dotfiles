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
TASK_PROJECT=""
TASK_TARGET_CWD=""
TASK_WORKSPACE_REF=""
TASK_BRANCH=""
TASK_PROMPT_SOURCE="inline"
QUIET_SAY_OUTPUT=1

emit_task_result() {
  local status="$1"
  local summary="$2"
  local error_text="${3:-}"

  jq -cn \
    --arg route "task" \
    --arg status "$status" \
    --arg summary "$summary" \
    --arg error "$error_text" \
    --arg project "${TASK_PROJECT:-}" \
    --arg cwd "${TASK_TARGET_CWD:-}" \
    --arg workspace "${TASK_WORKSPACE_REF:-}" \
    --arg branch "${TASK_BRANCH:-}" \
    --arg prompt_source "${TASK_PROMPT_SOURCE:-}" '
      {
        route: $route,
        status: $status,
        summary: $summary,
        data: {
          project: (if $project == "" then null else $project end),
          cwd: (if $cwd == "" then null else $cwd end),
          workspace: (if $workspace == "" then null else $workspace end),
          branch: (if $branch == "" then null else $branch end),
          prompt_source: (if $prompt_source == "" then null else $prompt_source end)
        },
        error: (if $error == "" then null else $error end)
      }
    '
}

fail() {
  emit_task_result "error" "Task launch failed" "$1"
  exit 1
}

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
  TASK_PROJECT="$effective_project"
  target_cwd="$base_cwd"
  branch_name=""

  if [[ -n "$WORKTREE_BRANCH" ]]; then
    [[ -n "$repo_root" ]] || fail "not-a-git-repo"
    branch_name="$WORKTREE_BRANCH"
    TASK_BRANCH="$branch_name"
    target_cwd="$(project_create_worktree "$effective_project" "$repo_root" "$branch_name")"
  elif [[ -n "$repo_root" ]]; then
    target_cwd="$repo_root"
  fi
  TASK_TARGET_CWD="$target_cwd"

  workspace_name="$(derive_workspace_name "$target_cwd" "$branch_name")"
  launch_command="agent open $(shell_quote "$PROMPT_TEXT")"

  launch_workspace "$workspace_name" "$target_cwd" "$launch_command"
  TASK_WORKSPACE_REF="${LAUNCH_WORKSPACE_REF:-}"
  emit_task_result "ok" "Task launched"
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
