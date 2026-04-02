---
name: kill
description: Deletes the current linked git worktree and closes the current cmux workspace when invoked or when the user asks to kill the current task context.
---

# Kill Current Context

- Run `task-kill`.
- Optimize for speed. Do not inspect the tool first unless it fails or the request clearly needs a special-case tweak.
- Never continue to workspace close after a cleanup failure.
