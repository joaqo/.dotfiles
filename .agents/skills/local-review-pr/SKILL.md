---
name: local-review-pr
description: Locally review a PR branch in depth before deciding follow-up actions.
disable-model-invocation: true
---

# Local Review PR

Review a PR locally while keeping the user in control of all remote actions.

## Rules

- Checkout the real PR source branch locally, not a copy.
- Fetch `origin/main` and the PR source branch before reviewing freshness.
- Check if the PR is behind/diverged from `origin/main`; if rebase would help, recommend it and wait.
- Never push, force-push, merge, close, or update the remote PR unless the user explicitly asks later.
- If later asked to push rewritten history, use `--force-with-lease`, never plain `--force`.
- Stop after review and wait for user direction.

## Workflow

1. Identify PR number/URL, source branch, and base branch.
2. Fetch current refs.
3. Switch to the real PR source branch.
4. Report freshness vs `origin/main`; ask before rebasing.
5. Read the diff enough to understand intent and affected systems.
6. Load relevant project standards before judging code:
   - Always load UI standards for UI work (`ui` skill in Mellow).
   - Load data/backend/domain skills when touched.
   - Apply the `retro` mindset: simplify, clean up, dedupe, refactor, and remove dev artifacts.
7. Review for correctness, regressions, quality, complexity, duplication, shared-code opportunities, architecture boundaries, platform boundaries, project conventions, checks/tests, and UI layout regressions.
8. Run relevant checks/tests when useful or requested.
9. Report findings first, ordered by severity, with file/line refs.
10. Include local state: branch, rebase status, checks run, uncommitted/unpushed local changes.
11. Stop.
