---
name: delete-worktree
description: Delete the current worktree and its branch without merging — removes the worktree.
---

# Delete Worktree

Use when the user asks to delete, discard, or drop the current worktree/branch **without** landing its work onto the main branch.

The source is the current `HEAD` (may be a branch or a detached Codex worktree). The target is the **main branch**: whatever branch is checked out in the primary worktree (first entry of `git worktree list --porcelain`) — `master` in some repos, `main` in others. Never assume the name.

## Workflow

1. Read source state: `git rev-parse --show-toplevel` (source worktree), `git branch --show-current` (source branch, may be empty). If the working tree is dirty, stop and confirm with the user — deleting discards uncommitted work.
2. Find the main worktree (the one on the main branch). If the source *is* the main worktree, stop — never delete the main worktree.
3. **Clean up resources this session/task spawned.** Only tear down what *this* work started — leave unrelated sims, tabs, and servers alone. Do the dev-server step before removing the worktree, or a live server will rewrite files into the path and leave an orphaned stub.
   - **Dev servers**: stop any you started in this worktree, the way the project's AGENTS.md says, or kill them directly if it doesn't.
   - **iOS simulators / Argent**: if you booted simulators or started Metro / simulator-servers this session, tear them down — `mcp__argent__stop-all-simulator-servers`, `mcp__argent__stop-metro`, then `xcrun simctl shutdown <udid>` for each sim *you* booted. Don't touch sims you didn't boot.
   - **Chrome tabs**: close tabs you opened via the claude-in-chrome tools with `mcp__claude-in-chrome__tabs_close_mcp`. Don't close the user's other tabs.
4. **Remove the worktree**: `cd` to the main worktree, `git worktree remove <source_worktree>`, then `git branch -d <source_branch>` if it had one. If `-d` refuses (unmerged work), report and suggest `-D` rather than force-deleting.
5. Report what was removed.
6. **Close this agent's Herdr space** if `$HC_TERMINAL_ID` is set. Do this last, after reporting — it kills the running agent. Close the whole space, not just this agent's terminal: any other pane in it (a lazygit split, a shell) would keep it open. `hc kill` is the fallback for when the Herdr window isn't running.

   ```bash
   herdr-app do space.close --id "$(hc get "$HC_TERMINAL_ID" --json | jq -r '.labels["herdr.space"]')" --confirmed true || hc kill "$HC_TERMINAL_ID"
   ```
