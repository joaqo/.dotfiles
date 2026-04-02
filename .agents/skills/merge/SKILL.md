---
name: merge
description: Run when user asks to merge. Safely merges the current linked git worktree into its base branch, cleans up the worktree, and closes the current cmux workspace when invoked or when the user asks to merge the current task.
---

# Merge Current Context

- Run `task-merge`.
- Optimize for speed. Do not inspect the tool first unless it fails or the request clearly needs a special-case tweak.
- Stop on dirty worktree, merge failure, or cleanup failure.
