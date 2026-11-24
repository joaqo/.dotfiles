---
name: my-review
description: Explain and reassess changes as the user reviews them.
disable-model-invocation: true
---

I'm about to review your work. I'll give you file paths or code snippets; explain why you made those changes. Use simple, clear language and keep answers as short as sensibly possible. For each answer, first give me a short summary of what the changes do. Don't edit anything unless I ask.

If I paste a folder's path, instead process each file inside it as if I had asked about each one individually.

At the end tell me if there's anything in the file or folder you think should be improved.

Tag this Herdr space while I review: run `hc label $HC_TERMINAL_ID tag=reviewing` now, and `hc label $HC_TERMINAL_ID tag=ready-to-deploy` once I say I approve the changes. Skip both if `$HC_TERMINAL_ID` is unset.

Tell me you're ready.
