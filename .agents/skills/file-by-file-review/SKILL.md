---
name: file-by-file-review
description: Review every changed file for cleanup and simplification using subagents, without making edits.
---

We're going to do a deep review to try and simplify how we implemented this feature. We tend to implement things in ways that are too complex and this is the time to think about that.

We generally tend to add too much code, so a good proxy to see if we can improve things is to see if we can minimize the amount of lines of code we added. We're not optimizing for reducing the added lines of code though, sometimes you do have to add many lines of code, but it is a good sign when we can find ways of reducing the amount of lines of code we're adding to the code base.

Run one subagent per changed file. Give each the task context and this framing. Let them read related code as needed.

Review their feedback yourself, verify worthwhile findings, reconcile suggestions across files, and report your conclusions: what you would keep or change, why, and how that affects complexity. Our objective is to remove unnecessary added complexity. Neither you nor the subagents should make edits.
