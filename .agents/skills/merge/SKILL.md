---
name: merge
description: Merge the current worktree/branch onto the local main branch by rebasing then fast-forwarding, consulting the user on conflicts. Deletes the current worktree and closes its Herdr space, so it must be the last step of a task.
---

# Merge Worktree

Use when the user asks to merge, land, or finish work from a Codex Desktop worktree or any local branch.

The source is the current `HEAD` (may be a branch or a detached Codex worktree). The target is the **main branch**: whatever branch is checked out in the primary worktree (first entry of `git worktree list --porcelain`) — `master` in some repos, `main` in others. Never assume the name.

Constraints: Never squash, cherry-pick, or create merge commits.

## Workflow

1. Read source state: `git status --short`, `git rev-parse --show-toplevel` (source worktree), `git branch --show-current` (source branch, may be empty), `git rev-parse HEAD` (source commit). If dirty, stop — user must commit/stash first.
2. Find the main worktree (the one on the main branch) and confirm it's clean and on the main branch. If the source *is* the main worktree, stop.
3. **Rebase** the source onto the main branch (`git rebase <main_branch>` from the source worktree).
   - On conflict: stop and consult. Show the conflicting files and diffs, state how you'd resolve each and why, phrased so the user can reply "ok" to let you proceed. Only resolve after they agree; if they decline, `git rebase --abort` and report. Then update the source commit to the new HEAD.
4. **Fast-forward** main onto the rebased source: `git merge --ff-only <source_commit>` from the main worktree. After a rebase this must fast-forward; if it doesn't, stop and report.
5. **Notion task**: if the task's initial prompt was a Notion page link and the work fully completed it, mark it done with the `notion-tool` skill (`notion done <page-id> -p <project> -d <database>`). If only partially done, leave its status alone and say so in the report.
6. **Clean up resources this session/task spawned.** Only tear down what *this* work started — leave unrelated sims, tabs, and servers alone. Do the dev-server step before removing the worktree, or a live server will rewrite files into the path and leave an orphaned stub.
   - **Dev servers**: stop any you started in this worktree, the way the project's AGENTS.md says, or kill them directly if it doesn't.
   - **iOS simulators / Argent**: if you booted simulators or started Metro / simulator-servers this session, tear them down — `mcp__argent__stop-all-simulator-servers`, `mcp__argent__stop-metro`, then `xcrun simctl shutdown <udid>` for each sim *you* booted. Don't touch sims you didn't boot.
   - **Chrome tabs**: close tabs you opened via the claude-in-chrome tools with `mcp__claude-in-chrome__tabs_close_mcp`. Don't close the user's other tabs.
7. **Report** how it landed (clean vs resolved conflicts) and the Notion task status, if any. If `$HC_TERMINAL_ID` is unset (not running in Herdr), say the space stays open.
8. **Finish**: remove the worktree, delete the branch, and end this agent's Herdr terminal, which closes its space, in one final command. It must be one command: the agent's working directory is deleted and ending the terminal kills the agent, so nothing can run after it. Omit `git branch -D` if the source had no branch, and omit `hc kill` if `$HC_TERMINAL_ID` is unset. Use `-D`: main was just fast-forwarded onto the branch, so it holds all of its commits, but `-d` still refuses when the branch tracks a remote copy pushed before the rebase.

   ```bash
   cd <main_worktree> && git worktree remove <source_worktree> && git branch -D <source_branch> && hc kill "$HC_TERMINAL_ID"
   ```

   If it fails, the space stays open: report the error.
