---
name: claude-review
description: Get a Claude code review of uncommitted changes, then add your honest assessment of it. Use after finishing a task with uncommitted changes.
disable-model-invocation: true
---

You just finished a task with uncommitted changes. Run a Claude code review on those changes, then show the user the review alongside your honest take on it.

## Steps

1. **Run Claude directly** from the current working directory:

   ```bash
   agent exec claude "Review the uncommitted changes in the current working directory. Focus on bugs, risks, behavioral regressions, and missing tests. Reply with only the final review summary." --ephemeral
   ```

   If you are running from Codex, this only works when approvals go to the user, or in Full Access. If the thread is using Guardian/Auto Review approvals, the command can be rejected before the user sees an approval prompt because it sends private workspace data to Claude. Do not delegate this through a subagent. If escalation is rejected, tell the user to switch the thread permissions from Guardian/Auto Review to user approval or Full Access, then rerun the command.

2. **Read the review carefully.** You have more context than Claude — you know what the task was, what tradeoffs were considered, what's intentional vs. accidental.

3. **Show the user both pieces**, in this format:

   ```
   ## Claude review

   <Claude's review, verbatim>

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
