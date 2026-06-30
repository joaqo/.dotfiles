---
name: delete-worktree
description: Delete the current worktree and its branch without merging — removes the worktree.
---

# Delete Worktree

Use when the user asks to delete, discard, or drop the current worktree/branch **without** landing its work onto the main branch.

The source is the current `HEAD` (may be a branch or a detached Codex worktree). The target is the **main branch**: whatever branch is checked out in the primary worktree (first entry of `git worktree list --porcelain`) — `master` in some repos, `main` in others. Never assume the name.

## Workflow

1. Read source state: `git rev-parse --show-toplevel` (source worktree), `git branch --show-current` (source branch, may be empty). If the working tree is dirty, stop and confirm with the user — deleting discards uncommitted work.

   Then **capture the Ghostty tab id** for the source worktree *now*, before removal. Two gotchas: (a) Ghostty only learns a tab's `working directory` from the shell's OSC 7 escape, which fires at a prompt — but an agent occupies this tab without a prompt, so Ghostty's cwd for it is **blank** (this is why matching by cwd never worked). (b) Once the worktree is removed no path matches anyway. Fix: inject OSC 7 into the agent's controlling pts so Ghostty learns the path, then capture the tab id (the only stable handle after removal). Run this from the source worktree and save the printed id (empty = no Ghostty tab / not in Ghostty; skip the close step later):

   ```bash
   SRC="$(git rev-parse --show-toplevel)"
   # walk up the process tree to the agent's controlling pts (the Bash tool itself is detached)
   tty=""; pid=$$
   for i in $(seq 1 10); do
     read ppid t < <(ps -o ppid=,tty= -p "$pid" 2>/dev/null)
     [ -n "$t" ] && [ "$t" != "??" ] && { tty="$t"; break; }
     [ -z "$ppid" ] && break
     pid=$ppid
   done
   [ -n "$tty" ] && printf '\033]7;file://%s%s\033\\' "$(hostname)" "$SRC" > "/dev/$tty" 2>/dev/null

   osascript - "$SRC" <<'EOF'
   on run argv
     set target to item 1 of argv
     if not (application "Ghostty" is running) then return ""
     tell application "Ghostty"
       repeat with w in windows
         repeat with t in tabs of w
           try
             if (working directory of (focused terminal of t)) is target then return (id of t)
           end try
         end repeat
       end repeat
     end tell
     return ""
   end run
   EOF
   ```
2. Find the main worktree (the one on the main branch). If the source *is* the main worktree, stop — never delete the main worktree.
3. **Clean up resources this session/task spawned.** Only tear down what *this* work started — leave unrelated sims, tabs, and servers alone. Do the dev-server step before removing the worktree, or a live server will rewrite files into the path and leave an orphaned stub.
   - **Dev servers**: stop any you started in this worktree. For mellow: `mellow site kill`, `mellow sellerWeb kill`, `mellow favorites kill` from the worktree (each no-ops if no session). Kill any other dev server you launched.
   - **iOS simulators / Argent**: if you booted simulators or started Metro / simulator-servers this session, tear them down — `mcp__argent__stop-all-simulator-servers`, `mcp__argent__stop-metro`, then `xcrun simctl shutdown <udid>` for each sim *you* booted. Don't touch sims you didn't boot.
   - **Chrome tabs**: close tabs you opened via the claude-in-chrome tools with `mcp__claude-in-chrome__tabs_close_mcp`. Don't close the user's other tabs.
4. **Remove the worktree**: `cd` to the main worktree, `git worktree remove <source_worktree>`, then `git branch -d <source_branch>` if it had one. If `-d` refuses (unmerged work), report and suggest `-D` rather than force-deleting.
5. Report what was removed.
6. **Close the Ghostty tab** captured in step 1 (skip if the id was empty). Do this last, after reporting — it kills the running agent. Close by the saved id, not by working directory (the path is gone now):

   ```bash
   osascript - "<tab_id>" <<'EOF'
   on run argv
     set wantedId to item 1 of argv
     tell application "Ghostty"
       repeat with w in windows
         repeat with t in tabs of w
           try
             if (id of t) is wantedId then
               close tab t
               return
             end if
           end try
         end repeat
       end repeat
     end tell
   end run
   EOF
   ```
