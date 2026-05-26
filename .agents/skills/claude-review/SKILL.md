---
name: claude-review
description: Get a Claude code review of uncommitted changes, then add your honest assessment of it. Use after finishing a task with uncommitted changes.
---

You just finished a task with uncommitted changes. Run a Claude code review on those changes, then show the user the review alongside your honest take on it.

## Steps

1. **Spawn an explorer subagent** with this prompt:

   > Run this in bash from the current working directory:
   >
   > ```bash
   > agent exec claude "Review the uncommitted changes in the current working directory. Focus on bugs, risks, behavioral regressions, and missing tests. Reply with only the final review summary." --ephemeral
   > ```
   >
   > It emits intermediate output followed by a final review summary. Reply with ONLY that final summary — verbatim, complete, untruncated, no preamble, no commentary, no markdown wrappers. If the command fails, reply with the raw error output verbatim.

   The subagent returns the review. The noisy intermediate output stays in its context, not yours.

2. **Read the review carefully.** You have more context than the subagent — you know what the task was, what tradeoffs were considered, what's intentional vs. accidental.

3. **Show the user both pieces**, in this format:

   ```
   ## Claude review

   <subagent's review, verbatim>

   ## My assessment

   <your honest take>
   ```

## How to assess the review

- Treat the review as **suggestions**, not directives. Claude didn't see the conversation, the task framing, or the constraints — you did.
- Be honest. If a point is valid, say so and propose a fix. If a point is wrong, misses context, or is a nitpick, say that plainly and explain why.
- **Do not blindly agree.** Sycophantic "good point, I'll fix all of these" is worse than useless — it sends the user down rabbit holes you don't believe in.
- **Do not overengineer.** Reject suggestions that add abstraction, defensive code, or scope beyond what the task needs, even if they sound reasonable in isolation.
- Prioritize: real bugs > correctness issues > meaningful design concerns > style/nits. Don't give equal weight to all points.
- Keep your assessment tight. One short paragraph or a bulleted list of points addressed — not an essay.
