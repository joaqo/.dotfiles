#!/usr/bin/env bash

say() {
  printf '%s\n' "$*"
}

retry_command() {
  local attempts="$1"
  local delay_seconds="$2"
  shift 2

  local attempt
  for ((attempt = 1; attempt <= attempts; attempt++)); do
    if "$@"; then
      return 0
    fi
    (( attempt == attempts )) && return 1
    sleep "$delay_seconds"
  done
}

fail() {
  say "error=$1"
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || fail "missing-command:$1"
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9][^a-z0-9]*/-/g; s/^-//; s/-$//'
}

shell_quote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\"'\"'/g")"
}

current_workspace_ref() {
  cmux identify --json 2>/dev/null | jq -r '.caller.workspace_ref // empty' 2>/dev/null || true
}

close_workspace() {
  local workspace_ref="$1"
  if [[ -z "${workspace_ref:-}" ]]; then
    say "workspace=skipped:not-in-cmux"
    return 0
  fi

  if [[ "${AGENT_TASK_WORKSPACE:-}" != "1" ]]; then
    say "workspace=skipped:not-task-workspace"
    return 0
  fi

  cmux close-workspace --workspace "$workspace_ref"
  say "workspace=closed:$workspace_ref"
}

find_main_repo() {
  local candidate git_dir common_dir

  while read -r line; do
    [[ "$line" == worktree\ * ]] || continue
    candidate="${line#worktree }"
    git_dir="$(git -C "$candidate" rev-parse --git-dir 2>/dev/null || true)"
    common_dir="$(git -C "$candidate" rev-parse --git-common-dir 2>/dev/null || true)"
    if [[ -n "$git_dir" && "$git_dir" == "$common_dir" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done < <(git worktree list --porcelain)

  return 1
}

derive_generic_worktree_path() {
  local repo_root="$1"
  local branch_name="$2"
  local repo_name dir_name

  repo_name="$(basename "$repo_root")"
  dir_name="${branch_name//\//-}"
  printf '%s/worktrees/%s-%s\n' "$HOME" "$repo_name" "$dir_name"
}

create_generic_worktree() {
  local repo_root="$1"
  local branch_name="$2"
  local target

  target="$(derive_generic_worktree_path "$repo_root" "$branch_name")"
  if [[ -d "$target" ]]; then
    printf '%s\n' "$target"
    return 0
  fi

  if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch_name"; then
    git -C "$repo_root" worktree add "$target" "$branch_name" >/dev/null
  else
    git -C "$repo_root" worktree add -b "$branch_name" "$target" >/dev/null
  fi

  printf '%s\n' "$target"
}

delete_generic_worktree() {
  local main_repo="$1"
  local task_path="$2"
  local branch_name="${3:-}"
  local branch_delete_flag="${4:--d}"

  cd /
  git -C "$main_repo" worktree remove --force "$task_path"
  [[ -n "$branch_name" ]] || return 0
  git -C "$main_repo" branch "$branch_delete_flag" "$branch_name"
}

workspace_exists() {
  local workspace_ref="$1"
  cmux --json list-panes --workspace "$workspace_ref" >/dev/null 2>&1
}

workspace_primary_terminal_surface() {
  local workspace_ref="$1"

  cmux --json list-panes --workspace "$workspace_ref" 2>/dev/null | jq -r '
    .panes[0].selected_surface_ref
    // .panes[0].surface_refs[0]
    // empty
  '
}

workspace_has_surface() {
  local workspace_ref="$1"
  local surface_ref="$2"

  cmux --json list-panes --workspace "$workspace_ref" 2>/dev/null | jq -e \
    --arg surface_ref "$surface_ref" '
      [.panes[].surface_refs[]?]
      | index($surface_ref) != null
    ' >/dev/null
}

cmux_create_workspace() {
  local workspace_name="$1"
  local target_cwd="$2"
  local command_text="$3"
  local workspace_ref attempt

  for attempt in {1..3}; do
    workspace_ref="$(cmux new-workspace --name "$workspace_name" --cwd "$target_cwd" --command "$command_text" 2>/dev/null | awk '{print $2}')"
    if [[ -n "$workspace_ref" ]] && workspace_exists "$workspace_ref"; then
      printf '%s\n' "$workspace_ref"
      return 0
    fi
    [[ -n "$workspace_ref" ]] && cmux close-workspace --workspace "$workspace_ref" >/dev/null 2>&1 || true
    sleep 0.2
  done

  return 1
}

cmux_create_surface() {
  local workspace_ref="$1"
  local response surface_ref attempt

  for attempt in {1..3}; do
    response="$(cmux --json new-surface --workspace "$workspace_ref" 2>/dev/null || true)"
    surface_ref="$(jq -r '.surface_ref // empty' <<<"$response" 2>/dev/null)"
    if [[ -n "$surface_ref" ]] && workspace_has_surface "$workspace_ref" "$surface_ref"; then
      printf '%s\n' "$surface_ref"
      return 0
    fi
    sleep 0.2
  done

  return 1
}

cmux_configure_surface() {
  local workspace_ref="$1"
  local surface_ref="$2"
  local title="$3"
  local command_text="$4"

  retry_command 3 0.2 cmux rename-tab --workspace "$workspace_ref" --surface "$surface_ref" "$title" >/dev/null 2>&1 || return 1
  retry_command 3 0.2 cmux send --workspace "$workspace_ref" --surface "$surface_ref" "$command_text" >/dev/null 2>&1 || return 1
}

cmux_send_to_surface() {
  local workspace_ref="$1"
  local surface_ref="$2"
  local command_text="$3"

  retry_command 3 0.2 cmux send --workspace "$workspace_ref" --surface "$surface_ref" "$command_text" >/dev/null 2>&1
}

launch_workspace() {
  local workspace_name="$1"
  local target_cwd="$2"
  local command_text="$3"
  local workspace_ref surface_ref

  workspace_ref="$(cmux_create_workspace "$workspace_name" "$target_cwd" "$command_text")"
  [[ -n "$workspace_ref" ]] || fail "workspace-create-failed"

  LAUNCH_WORKSPACE_REF="$workspace_ref"
  LAUNCH_WORKSPACE_PRIMARY_SURFACE_REF="$(workspace_primary_terminal_surface "$workspace_ref")"
  [[ -n "$LAUNCH_WORKSPACE_PRIMARY_SURFACE_REF" ]] || fail "workspace-primary-surface-not-found:$workspace_ref"

  surface_ref="$(cmux_create_surface "$workspace_ref")"
  [[ -n "$surface_ref" ]] || fail "workspace-surface-create-failed:$workspace_ref:nvim"
  cmux_configure_surface "$workspace_ref" "$surface_ref" "nvim" "nvim\n" || fail "workspace-surface-configure-failed:$workspace_ref:$surface_ref:nvim"

  surface_ref="$(cmux_create_surface "$workspace_ref")"
  [[ -n "$surface_ref" ]] || fail "workspace-surface-create-failed:$workspace_ref:lazygit"
  cmux_configure_surface "$workspace_ref" "$surface_ref" "lazygit" "lazygit\n" || fail "workspace-surface-configure-failed:$workspace_ref:$surface_ref:lazygit"

  say "workspace=created:$workspace_ref"
  say "cwd=$target_cwd"
}
