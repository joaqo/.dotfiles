---
name: task
description: Personal workflow for creating new tasks across projects. Whenever I tell you to create a new task, or say 'task:' followed by an ask, load up this skill.
---

# Task Workflow

- Pass the task prompt directly to `task-run`
- Keep prompts reasonably short/simple so they fit cleanly in a normal CLI arg
- Decide what repo this task belongs to
- Decide what branch name to choose for the git worktree this task will run in.
    - Most task will need worktrees, if in doubt just create a worktree
    - User may override this decision in prompt
    - The only instances in which you might choose not to run inside a worktree is if the task will not modify any code.
- Run `task-run`.

```bash
task-run <project-path> --prompt "<task prompt>"
```

- Optional flags:
- `--worktree <branch-name>`
- `--workspace-name <name>`

- After task launches, stop.
