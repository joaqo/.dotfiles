---
name: launch-task
description: Start a new task (a fresh worktree with its own agent working on a prompt) on Joaquín's machine. Use when asked to launch, start, spin off, or hand off work as a new task.
---

# Launch a task

A task is a worktree in `~/worktrees` with an agent running in a Ghostty Agents tab. Start one with:

```bash
task-manager launch [--project <name>] [--agent claude|codex] [--no-worktree] "<prompt>"
```

- `--project`: `mellow` (default), `dotfiles`, `agent`, `task-manager`, `terminal`.
- `--agent`: `claude` (default) or `codex`.
- `--no-worktree`: run in the project's main checkout. Refused if an agent is already live there.

It names the branch, creates the worktree (`mellow worktree add` for mellow), opens a background tab and prints `{"cwd": "...", "terminal_id": "..."}`.

## The prompt

The new agent starts with no context, so the prompt must stand alone: the goal, what was already found (causes, file paths, IDs, log lines), what is decided and what is still open, and any constraints the user gave. For long prompts, write them to a file and pass `"$(cat <file>)"`.

## After launching

Tell the user the worktree path. Drive or check the agent with its `terminal_id`:

- `agent screen <id>`: what its pane shows now.
- `agent send <id> "<message>"`: send it a message.
- `agent wait <id>`: wait for its reply, or for it to ask something.
- `agent close <id>`: stop it. Only when the user asks.
