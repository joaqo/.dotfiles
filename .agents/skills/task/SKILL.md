---
name: task
description: Personal workflow for creating new tasks across projects. Whenever I tell you to create a new task, or say 'task:' followed by an ask, load up this skill.
---

# Task Workflow

- Pass the task prompt directly to `task-run`
- Keep prompts reasonably short/simple so they fit cleanly in a normal CLI arg
- Decide what repo this task belongs to
- Decide if it deserves a worktree or if its a small task that can just be run on the original repo
    - Most task will need worktrees, if in doubt just create a worktree
    - User may override this decision in prompt
- Run `task-run`.

```bash
task-run <project-path> --prompt "<task prompt>"
```

- Optional flags:
- `--worktree <branch-name>`
- `--workspace-name <name>`

- Optimize for speed. Do not inspect the tool first unless it fails or the request clearly needs a special unusual flow.
- After task launches, stop.
