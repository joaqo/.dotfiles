---
name: delete-worktree
description: Delete the current worktree and its branch without merging — removes the worktree.
---

# Delete Worktree

Use when the user asks to delete, discard, or drop the current worktree/branch **without** landing its work onto the main branch.

The source is the current `HEAD` (may be a branch or a detached Codex worktree). The target is the **main branch**: whatever branch is checked out in the primary worktree (first entry of `git worktree list --porcelain`) — `master` in some repos, `main` in others. Never assume the name.

## Workflow

1. Read source state: `git rev-parse --show-toplevel` (source worktree), `git branch --show-current` (source branch, may be empty). If the working tree is dirty, stop and confirm with the user — deleting discards uncommitted work.
2. Find the main worktree (the one on the main branch). If the source *is* the main worktree, stop — never delete the main worktree.
3. **Remove the worktree**: `cd` to the main worktree, `git worktree remove <source_worktree>`, then `git branch -d <source_branch>` if it had one. If `-d` refuses (unmerged work), report and suggest `-D` rather than force-deleting.
4. Report what was removed.
