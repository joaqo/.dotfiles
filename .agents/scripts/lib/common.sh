#!/usr/bin/env bash

say() {
  printf '%s\n' "$*"
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

launch_workspace() {
  local workspace_name="$1"
  local target_cwd="$2"
  local command_text="$3"
  local workspace_ref surface_ref

  workspace_ref="$(cmux new-workspace --name "$workspace_name" --cwd "$target_cwd" --command "$command_text" | awk '{print $2}')"
  [[ -n "$workspace_ref" ]] || fail "workspace-create-failed"

  surface_ref="$(cmux --json new-surface --workspace "$workspace_ref" | jq -r '.surface_ref')"
  cmux rename-tab --workspace "$workspace_ref" --surface "$surface_ref" "nvim"
  cmux send --workspace "$workspace_ref" --surface "$surface_ref" "nvim\n"

  surface_ref="$(cmux --json new-surface --workspace "$workspace_ref" | jq -r '.surface_ref')"
  cmux rename-tab --workspace "$workspace_ref" --surface "$surface_ref" "lazygit"
  cmux send --workspace "$workspace_ref" --surface "$surface_ref" "lazygit\n"

  say "workspace=created:$workspace_ref"
  say "cwd=$target_cwd"
}
