---
name: launch-task
description: Start a new task (a fresh worktree with its own agent working on a prompt) on Joaquín's machine. Use when asked to launch, start, spin off, or hand off work as a new task.
---

# Launch a task

A task is a worktree in `~/worktrees` with an agent running in its own Herdr space. Start one with:

```bash
task-manager launch [--project <name>] [--agent claude|codex] [--no-worktree] "<prompt>"
```

- `--project`: run `task-manager launch` with no arguments to list them; `mellow` is the default.
- `--agent`: `claude` (default) or `codex`.
- `--no-worktree`: run in the project's main checkout. Refused if an agent is already live there.

It names the branch, creates the worktree, opens a Herdr space in the background and prints the worktree path.

## The prompt

The new agent starts with no context, so the prompt must stand alone: the goal, what was already found (causes, file paths, IDs, log lines), what is decided and what is still open, and any constraints the user gave. For long prompts, write them to a file and pass `"$(cat <file>)"`.

## After launching

Tell the user the worktree path. To drive or check the agent, find its terminal in `hc ls` (its `cwd` is the worktree):

- `hc read <t>`: what its terminal shows now.
- `hc send <t> "<message>"`: send it a message.
- `hc wait <t>`: wait until it stops working, or needs someone.
- `hc kill <t>`: stop it. Only when the user asks.

See `hc --skill` for the rest.
