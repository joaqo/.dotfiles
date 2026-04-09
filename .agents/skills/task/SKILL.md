---
name: task
description: Personal workflow for creating new tasks across projects. Whenever I tell you to create a new task, or say 'task:' followed by an ask, load up this skill.
---

# Task Workflow

- Pass the task prompt directly to `task-run`
- Keep prompts reasonably short/simple so they fit cleanly in a normal CLI arg
- Decide what repo this task belongs to
- Decide what branch name to choose for the git worktree this task will run in
    - Always run tasks in a worktree unless the user explicitly says not to
    - Treat no-worktree runs as opt-out, not a default judgment call
- Run `task-run`.
- Inspect the `task-run` output carefully.
- Preserve the exact launch facts and errors for the caller.

```bash
task-run <project-path> --worktree <branch-name> --prompt "<task prompt>"
```

- Optional flags:
- `--workspace-name <name>`
- Omit `--worktree` only when the user explicitly asked for no worktree

- After task launches, stop.
