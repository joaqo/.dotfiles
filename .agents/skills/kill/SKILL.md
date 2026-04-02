---
name: kill
description: Deletes the current linked git worktree and closes the current cmux workspace when invoked or when the user asks to kill the current task context.
---

# Kill Current Context

Use this skill to tear down the current task context fast.

## Rules

- Detect the caller workspace with `cmux identify --json`
- Never use `select-workspace`
- Delete a git worktree only when the current repo is a linked worktree, never the main worktree
- If the repo has a documented delete helper below, use it
- Otherwise use generic git worktree cleanup
- Close the caller cmux workspace last
- If worktree deletion fails, stop and report it. Do not continue to workspace close.

## Workflow

1. Try `git rev-parse --show-toplevel 2>/dev/null`
2. If that fails, skip git cleanup
3. If it succeeds, compare:

```bash
git_dir="$(git rev-parse --git-dir)"
common_dir="$(git rev-parse --git-common-dir)"
```

4. If `git_dir == common_dir`, skip git cleanup because this is the main worktree
5. If `git_dir != common_dir`, resolve:

```bash
task_path="$(git rev-parse --show-toplevel)"
main_repo="$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')"
branch="$(git branch --show-current || true)"
```

6. Delete the worktree:
- If the repo matches a documented helper below, use that helper
- Otherwise run:

```bash
cd /
git -C "$main_repo" worktree remove --force "$task_path"
if [[ -n "$branch" ]]; then
  git -C "$main_repo" branch -D "$branch"
fi
```

7. Resolve the caller workspace and close it last:

```bash
workspace_ref="$(cmux identify --json 2>/dev/null | jq -r '.caller.workspace_ref // empty')"
if [[ -n "$workspace_ref" ]]; then
  cmux close-workspace --workspace "$workspace_ref"
fi
```

8. Report tersely what happened:
- `worktree=deleted:<path>`
- `worktree=skipped:not-a-git-repo`
- `worktree=skipped:main-worktree`
- `workspace=closed:<workspace-ref>`
- `workspace=skipped:not-in-cmux`

## Repo Helpers

Use these only after you have already confirmed the current repo is a linked worktree.

## Mellow

- For Mellow linked worktrees, use:

```bash
mellow worktree delete
```
