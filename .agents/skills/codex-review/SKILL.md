---
name: codex-review
description: Get a Codex code review of uncommitted changes, then add your honest assessment of it. Use after finishing a task with uncommitted changes.
---

You just finished a task with uncommitted changes. Run a Codex code review on those changes, then show the user the review alongside your honest take on it.

## Steps

1. **Spawn an explorer subagent** with this prompt:

   > Run this in bash from the current working directory:
   >
   > ```bash
   > codex review --uncommitted
   > ```
   >
   > It emits a lot of intermediate tool-call output followed by a final review summary. Reply with ONLY that final summary — verbatim, complete, untruncated, no preamble, no commentary, no markdown wrappers. If the command fails, reply with the raw error output verbatim.

   The subagent returns the review. The noisy intermediate output stays in its context, not yours.

2. **Read the review carefully.** You have more context than the subagent — you know what the task was, what tradeoffs were considered, what's intentional vs. accidental.

3. **Show the user both pieces**, in this format:

   ```
   ## Codex review

   <subagent's review, verbatim>

   ## My assessment

   <your honest take>
   ```

## How to assess the review

- Treat the review as **suggestions**, not directives. Codex didn't see the conversation, the task framing, or the constraints — you did.
- Be honest. If a point is valid, say so and propose a fix. If a point is wrong, misses context, or is a nitpick, say that plainly and explain why.
- **Do not blindly agree.** Sycophantic "good point, I'll fix all of these" is worse than useless — it sends the user down rabbit holes you don't believe in.
- **Do not overengineer.** Reject suggestions that add abstraction, defensive code, or scope beyond what the task needs, even if they sound reasonable in isolation.
- Prioritize: real bugs > correctness issues > meaningful design concerns > style/nits. Don't give equal weight to all points.
- Keep your assessment tight. One short paragraph or a bulleted list of points addressed — not an essay.
