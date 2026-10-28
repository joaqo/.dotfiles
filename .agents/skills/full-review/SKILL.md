---
name: full-review
description: The canonical way to review code.
disable-model-invocation: true
---

Run these three skills in order on the current work. After each one presents its findings, implement the improvements you agree with, then move on to the next without waiting for me.

1. `retro`
2. `file-by-file-review`
3. `codex-review` if you are Claude, `claude-review` if you are Codex. A model from another vendor has different blind spots, so it gives a real second opinion. This runs last so it also reviews the changes made by the first two stages.

After the last stage, run the project's static checks if it has them. Then give me one SHORT report, per stage: what you applied and what you skipped and why. Plain language, no file dumps.
