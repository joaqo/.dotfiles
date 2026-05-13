---
name: codex-review
description: Get a Codex code review of uncommitted changes. Returns only the final review summary verbatim; intermediate tool-call noise stays out of the caller's context.
context: fork
agent: general-purpose
---

Run this in bash from the current working directory:

```bash
codex review --uncommitted
```

It emits a lot of intermediate tool-call output followed by a final review summary. Reply with ONLY that final summary — verbatim, complete, untruncated, no preamble, no commentary, no markdown wrappers. If the command fails, reply with the raw error output verbatim.
