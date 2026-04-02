---
name: merge
description: Run when user asks to merge. Safely merges the current linked git worktree into its base branch, cleans up the worktree, and closes the current cmux workspace when invoked or when the user asks to merge the current task.
---

# Merge Current Context

Use this skill to finish the current task context fast and safely.

## Rules

- Detect the caller workspace with `cmux identify --json`
- Never use `select-workspace`
- Merge only when the current repo is a linked worktree, never the main worktree
- Stop if the worktree has uncommitted changes
- Rebase before merge
- Merge with `--ff-only`
- If the repo has a documented cleanup helper below, use it after merge succeeds
- Otherwise use generic git cleanup
- Close the caller cmux workspace last
- If any command fails, stop and report it. Do not continue to cleanup or workspace close.

## Workflow

1. Try `git rev-parse --show-toplevel 2>/dev/null`
2. If that fails, stop and report `not-a-git-repo`
3. If it succeeds, compare:

```bash
git_dir="$(git rev-parse --git-dir)"
common_dir="$(git rev-parse --git-common-dir)"
```

4. If `git_dir == common_dir`, stop and report `main-worktree`
5. If `git_dir != common_dir`, resolve:

```bash
task_path="$(git rev-parse --show-toplevel)"
task_branch="$(git branch --show-current)"
main_repo="$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')"
base_branch="$(git -C "$main_repo" branch --show-current)"
```

6. Verify the task worktree is clean:

```bash
git -C "$task_path" status --short
```

If output is non-empty, stop and report `dirty-worktree`.

7. Rebase and merge:

```bash
git -C "$task_path" rebase "$base_branch"
git -C "$main_repo" merge --ff-only "$task_branch"
```

8. Clean up:
- If the repo matches a documented helper below, use that helper from `task_path`
- Otherwise run:

```bash
cd /
git -C "$main_repo" branch -d "$task_branch"
git -C "$main_repo" worktree remove --force "$task_path"
```

9. Resolve the caller workspace and close it last:

```bash
workspace_ref="$(cmux identify --json 2>/dev/null | jq -r '.caller.workspace_ref // empty')"
if [[ -n "$workspace_ref" ]]; then
  cmux close-workspace --workspace "$workspace_ref"
fi
```

10. Report tersely what happened:
- `merge=ok:<task-branch>-><base-branch>`
- `cleanup=ok:<task-path>`
- `workspace=closed:<workspace-ref>`
- `workspace=skipped:not-in-cmux`

## Repo Helpers

Use these only after merge succeeds.

## Mellow

- If you're in a linked worktree for the project mellow, run the following command from `task_path`:

```bash
mellow worktree delete
```
If you're in any other project, like .dotfiles for example, just do the normal cleanup.
