---
name: file-by-file-review
description: Review every changed file for cleanup and simplification using subagents, without making edits.
---

We're going to do a deep review to try and simplify how we implemented this feature, and see if we can minimize the diff, its quite possible we added and modified too much stuff.

Run one subagent per changed file. Give each the task context. Let them read related code as needed.

Review their feedback yourself, verify worthwhile findings, reconcile suggestions across files, and report your conclusions: what you would keep or change, why, and how that affects complexity. Our objective is to remove unnecessary added complexity. Neither you nor the subagents should make edits.
