---
name: branch
description: Branch the current live agent into a separate cmux tab in the same pane and same working directory, with full current session context and no worktree. Use when the user asks to branch out, fork this task, split off a parallel agent, or continue a side task in another tab.
---

# Branch Agent

Use this skill to fork the current live agent session into a sibling cmux tab.

## Rules

- Same `cwd`.
- Same cmux pane; create a new surface/tab beside the current one.
- Preserve full session context by forking the current session, not by reconstructing prompts.
- Keep the branch prompt short and task-specific.

## Command

```bash
branch-run "<branch prompt>"
```

If no extra prompt is needed:

```bash
branch-run
```

## Notes

- `branch-run` resolves the exact current session from env or parent pid.
- It does not change cmux focus.
- The new tab runs `agent fork ...`, so backend-specific fork behavior stays in the wrapper.
