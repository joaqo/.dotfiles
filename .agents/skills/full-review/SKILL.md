---
name: full-review
description: The canonical way to review code.
disable-model-invocation: true
---

Run these three skills in order on the current work. After each one presents its findings, implement the improvements you agree with, then move on to the next without waiting for me.

1. `retro`
2. `codex-review` if you are Claude, `claude-review` if you are Codex. A model from another vendor has different blind spots, so it gives a real second opinion.
3. `file-by-file-review`

Don't hold back on large changes, restructures or refactors if they make the codebase simpler or more elegant. We care about the final state of the codebase more than the effort needed to get there.

After the last stage, run the project's static checks if it has them. Then give me one SHORT report, per stage: what you applied and what you skipped and why, also save anything you couldn't decide on what to do, and ask me what to do about them here.

Plain language, no file dumps.
