---
name: retro
description: Retrospective — reflect on the work done, then clean up the solution
---

We're done with the task. Do two things:

## 1. Reflect

Knowing everything you know now — the root cause, the codebase structure, the gotchas you hit, any wrong turns you took — what would have been the most elegant and simplest way to solve this from the start?

Be concise. Focus on what you'd do differently, not on rehashing what happened.

## 2. Clean up

Now look at the current solution with fresh eyes. During exploration you likely left behind:
- Dead code, unnecessary fallbacks, or defensive checks that were only needed while debugging
- Over-engineered solutions when a simpler one would work now that you understand the root cause
- Redundant logic that could be collapsed
- Code that worked around the problem instead of fixing it directly

If the solution would be significantly simpler by rewriting part of it with the knowledge you have now, do it. Delete everything that isn't pulling its weight. If the whole approach was wrong and a targeted fix at the root cause would replace most of what you wrote, propose that rewrite.

If the current solution is already clean, say so and move on.

## 3. CLAUDE.md improvements

Think about the issues you encountered, wrong turns, gotchas, or things that took longer than they should have. Could any of these have been avoided if CLAUDE.md had contained specific instructions or context? If so, suggest concrete additions or modifications to CLAUDE.md that would help future sessions avoid the same pitfalls.
