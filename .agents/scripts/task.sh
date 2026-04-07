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

wait_for_task_session() {
  local target_cwd="$1"
  local prompt_text="$2"
  local started_after_ms="$3"
  local attempt session_id

  for attempt in {1..100}; do
    session_id="$(
      agent sessions --json 2>/dev/null | jq -sr \
        --arg cwd "$target_cwd" \
        --arg prompt "$prompt_text" \
        --argjson started_after_ms "$started_after_ms" '
          map(
            select(
              .cwd == $cwd
              and (
                (.started_at // 0) >= $started_after_ms
                or (.updated_at // 0) >= $started_after_ms
              )
              and (
                (.title // "") == $prompt
                or ((.command // "") | contains($prompt))
              )
            )
          )
          | sort_by(.updated_at // 0)
          | last
          | .id // empty
        '
    )"

    if [[ -n "$session_id" ]]; then
      printf '%s\n' "$session_id"
      return 0
    fi

    sleep 0.1
  done

  return 1
}

retry_workspace_launch_command() {
  local workspace_ref="$1"
  local surface_ref="$2"
  local command_text="$3"

  [[ -n "$workspace_ref" ]] || return 1
  [[ -n "$surface_ref" ]] || surface_ref="$(workspace_primary_terminal_surface "$workspace_ref")"
  [[ -n "$surface_ref" ]] || return 1

  say "launch-retry=workspace:$workspace_ref"
  say "launch-retry-surface=$surface_ref"
  cmux_send_to_surface "$workspace_ref" "$surface_ref" "${command_text}\\n"
}

main() {
  local base_cwd repo_root main_repo effective_project branch_name target_cwd workspace_name launch_command launch_started_ms retry_started_ms session_id

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
  launch_started_ms="$(( $(date +%s) * 1000 ))"

  say "project=$effective_project"
  launch_workspace "$workspace_name" "$target_cwd" "$launch_command"
  session_id="$(wait_for_task_session "$target_cwd" "$PROMPT_TEXT" "$launch_started_ms")" || {
    retry_started_ms="$(( $(date +%s) * 1000 ))"
    retry_workspace_launch_command "${LAUNCH_WORKSPACE_REF:-}" "${LAUNCH_WORKSPACE_PRIMARY_SURFACE_REF:-}" "$launch_command" \
      || fail "workspace-launch-command-retry-failed:${LAUNCH_WORKSPACE_REF:-unknown}"
    session_id="$(wait_for_task_session "$target_cwd" "$PROMPT_TEXT" "$retry_started_ms")" || fail "agent-session-not-detected:$target_cwd"
  }
  [[ -n "$branch_name" ]] && say "branch=$branch_name"
  say "session=$session_id"
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
