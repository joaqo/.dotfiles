---
name: monitor
description: Inspect and control other running agent sessions. Use when the user asks what other agents are doing or asks to send a message to another agent.
---

# Monitor Agents

Use this skill when the user wants status on other live agents or wants you to relay commands to one.

## Rules

- `agent sessions` is the only source of truth.
- Do not keep a registry or cache.
- Resolve the target session by `cwd`, title, recency, or explicit session id.
- Resolve cmux handles from the target `pid` with:

```bash
ps eww -p <pid> -o pid=,command=
```

- Extract `CMUX_WORKSPACE_ID` and `CMUX_SURFACE_ID`.
- cmux accepts those UUIDs directly.
- If the pid has no cmux vars, say the session is not controllable via cmux right now.
- Use `agent transcript <session-id> --limit N` for status.
- For agent sessions, send text with `cmux send ... "..."` and then after a few milliseconds submit with `cmux send-key ... enter`.
- Use `cmux send-key ... ctrl+c` to interrupt.
- Relay user instructions exactly.

## Common Workflows

### What are other agents up to?

- Run `agent sessions`.
- Read recent transcript lines for the relevant sessions.
- Summarize briefly what each one is doing. Don't return non important information like the session's id or its full path.

### Send a message to another agent

- Resolve the target session.
- Resolve its cmux handles from the pid env.
- Send the exact requested text, then wait a few milliseconds and `send-key enter`.

### Control another agent for me

- Resolve the target session.
- Read its transcript and summarize what it is doing now.
- Wait for the user's instructions.
- Forward those instructions with `cmux send ... "..."`, then wait a few milliseconds and `cmux send-key ... enter`.
- Re-check transcript as needed and report back briefly.

## Useful Commands

```bash
agent sessions
agent transcript <session-id> --limit 10
ps eww -p <pid> -o pid=,command=
cmux send --workspace <workspace_uuid> --surface <surface_uuid> "message"
cmux send-key --workspace <workspace_uuid> --surface <surface_uuid> enter
cmux send-key --workspace <workspace_uuid> --surface <surface_uuid> ctrl+c
```
