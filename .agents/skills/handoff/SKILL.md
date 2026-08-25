---
name: handoff
description: Package the current session for a successor agent — write a handoff summary and generate a readable transcript from the session JSONL, so a fresh agent can continue this work when context runs out or the session breaks.
disable-model-invocation: true
---

Produce a handoff so another agent can resume this work in a fresh session.

1. Pick a dir: `DIR=~/.claude/handoffs/$(date +%Y%m%d-%H%M%S)` and `mkdir -p "$DIR"`.

2. Write `$DIR/handoff.md` from memory: the goal, current status, next step, key decisions, and any gotchas. Keep it short; point at the code, don't paste it.

3. Generate the transcript:
   ```bash
   node ~/.claude/skills/handoff/transcript.js --out "$DIR"
   ```

4. Print this to the user:
   > You're picking up work from another agent whose session ran out. Read `$DIR/handoff.md` to get oriented — it has the goal, current status, and next step. The full transcript of that session is at `$DIR/transcript.md`; consult it if you need more detail on how something was decided or done. Then continue the work.
