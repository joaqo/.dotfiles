---
name: local-review-pr
description: Check out and review a GitHub PR locally. Use when the user wants to look at, check out, test, or review a PR here.
---

# Local Review PR

Review a PR locally while keeping the user in control of all remote actions.

## Guidelines

- **Check out the real PR source branch**, not a copy.
- **Freshness:** fetch `origin/main` and say whether the PR is behind or diverged. If a rebase would help, recommend it and wait.
- **Remote stays untouched:** never push, force-push, merge, close, or update the PR unless the user asks. If asked to push rewritten history, use `--force-with-lease`, never plain `--force`.
- **Load project standards before judging:** the `ui` skill for UI work in Mellow, data/backend/domain skills when touched. Apply the `retro` mindset: simplify, clean up, dedupe, refactor, remove dev artifacts.
- **Review for** correctness, regressions, complexity, duplication, shared-code opportunities, architecture and platform boundaries, project conventions, checks/tests, and UI layout regressions. Run checks when useful.
- **Report** findings first, most severe first, with file:line refs. Then local state: branch, rebase status, checks run, uncommitted/unpushed changes.
- **Stop** after the report and wait.
