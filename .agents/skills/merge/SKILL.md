---
name: merge
description: Merge the current worktree/branch onto the local main branch by rebasing then fast-forwarding, consulting the user on conflicts, then removing the worktree.
---

# Merge Worktree

Use when the user asks to merge, land, or finish work from a Codex Desktop worktree or any local branch.

The source is the current `HEAD` (may be a branch or a detached Codex worktree). The target is the **main branch**: whatever branch is checked out in the primary worktree (first entry of `git worktree list --porcelain`) — `master` in some repos, `main` in others. Never assume the name.

Constraints: Never squash, cherry-pick, or create merge commits.

## Workflow

1. Read source state: `git status --short`, `git rev-parse --show-toplevel` (source worktree), `git branch --show-current` (source branch, may be empty), `git rev-parse HEAD` (source commit). If dirty, stop — user must commit/stash first.
2. Find the main worktree (the one on the main branch) and confirm it's clean and on the main branch. If the source *is* the main worktree, stop.
3. **Rebase** the source onto the main branch (`git rebase <main_branch>` from the source worktree).
   - On conflict: stop and consult. Show the conflicting files and diffs, state how you'd resolve each and why, phrased so the user can reply "ok" to let you proceed. Only resolve after they agree; if they decline, `git rebase --abort` and report. Then update the source commit to the new HEAD.
4. **Fast-forward** main onto the rebased source: `git merge --ff-only <source_commit>` from the main worktree. After a rebase this must fast-forward; if it doesn't, stop and report.
5. **Remove the worktree**: `cd` to the main worktree, `git worktree remove <source_worktree>`, then `git branch -d <source_branch>` if it had one. If `-d` refuses, report and suggest `-D` rather than force-deleting.
6. Report how it landed (clean vs resolved conflicts).
