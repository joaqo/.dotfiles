---
name: delete-worktree
description: Delete the current worktree and its branch without merging — removes the worktree.
---

# Delete Worktree

Use when the user asks to delete, discard, or drop the current worktree/branch **without** landing its work onto the main branch.

The source is the current `HEAD` (may be a branch or a detached Codex worktree). The target is the **main branch**: whatever branch is checked out in the primary worktree (first entry of `git worktree list --porcelain`) — `master` in some repos, `main` in others. Never assume the name.

## Workflow

1. Read source state: `git rev-parse --show-toplevel` (source worktree), `git branch --show-current` (source branch, may be empty). If the working tree is dirty, stop and confirm with the user — deleting discards uncommitted work.

   Capture this session's terminal tab before removing the worktree, and save the printed `app:tab` reference. The `terminal` helper identifies the owning Ghostty app from the process tree; the launch preference does not affect this lookup. If it prints nothing or cannot identify a unique tab, skip the tab-close step.

   ```bash
   terminal tab-ref --cwd "$(git rev-parse --show-toplevel)"
   ```
2. Find the main worktree (the one on the main branch). If the source *is* the main worktree, stop — never delete the main worktree.
3. **Clean up resources this session/task spawned.** Only tear down what *this* work started — leave unrelated sims, tabs, and servers alone. Do the dev-server step before removing the worktree, or a live server will rewrite files into the path and leave an orphaned stub.
   - **Dev servers**: stop any you started in this worktree. For mellow: `mellow site kill`, `mellow sellerWeb kill`, `mellow favorites kill` from the worktree (each no-ops if no session). Kill any other dev server you launched.
   - **iOS simulators / Argent**: if you booted simulators or started Metro / simulator-servers this session, tear them down — `mcp__argent__stop-all-simulator-servers`, `mcp__argent__stop-metro`, then `xcrun simctl shutdown <udid>` for each sim *you* booted. Don't touch sims you didn't boot.
   - **Chrome tabs**: close tabs you opened via the claude-in-chrome tools with `mcp__claude-in-chrome__tabs_close_mcp`. Don't close the user's other tabs.
4. **Remove the worktree**: `cd` to the main worktree, `git worktree remove <source_worktree>`, then `git branch -d <source_branch>` if it had one. If `-d` refuses (unmerged work), report and suggest `-D` rather than force-deleting.
5. Report what was removed.
6. **Close the captured terminal tab**, if a reference was saved. Do this last, after reporting — it kills the running agent. The reference preserves both the app and tab ID even if the default terminal changed or the worktree is gone.

   ```bash
   terminal close-tab '<captured_app:tab_reference>'
   ```
