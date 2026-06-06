---
name: merge
description: Merge the current worktree/branch onto the local main branch by rebasing then fast-forwarding, consulting the user on conflicts, then removing the worktree.
---

# Merge Worktree

Use when the user asks to merge, land, or finish work from a Codex Desktop worktree or any local branch.

The source is the current `HEAD` (may be a branch or a detached Codex worktree). The target is the **main branch**: whatever branch is checked out in the primary worktree (first entry of `git worktree list --porcelain`) — `master` in some repos, `main` in others. Never assume the name.

Constraints: Never squash, cherry-pick, or create merge commits.

## Workflow

1. Read source state: `git status --short`, `git rev-parse --show-toplevel` (source worktree), `git branch --show-current` (source branch, may be empty), `git rev-parse HEAD` (source commit). If dirty, stop — user must commit/stash first.

   Then **capture the Ghostty tab id** for the source worktree *now*, before removal. Ghostty reports `working directory` live from the shell, so once the worktree is removed no tab matches the path anymore — you must grab the id while the path still exists. Save the printed id (empty = no Ghostty tab / not in Ghostty; skip the close step later):

   ```bash
   osascript - "<source_worktree>" <<'EOF'
   on run argv
     set target to item 1 of argv
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
2. Find the main worktree (the one on the main branch) and confirm it's clean and on the main branch. If the source *is* the main worktree, stop.
3. **Rebase** the source onto the main branch (`git rebase <main_branch>` from the source worktree).
   - On conflict: stop and consult. Show the conflicting files and diffs, state how you'd resolve each and why, phrased so the user can reply "ok" to let you proceed. Only resolve after they agree; if they decline, `git rebase --abort` and report. Then update the source commit to the new HEAD.
4. **Fast-forward** main onto the rebased source: `git merge --ff-only <source_commit>` from the main worktree. After a rebase this must fast-forward; if it doesn't, stop and report.
5. **Stop dev servers in the source worktree** first, or they'll rewrite files into the path and leave an orphaned stub. Run `mellow site kill`, `mellow sellerWeb kill`, `mellow favorites kill` from the worktree (each no-ops if no session).
6. **Remove the worktree**: `cd` to the main worktree, `git worktree remove <source_worktree>`, then `git branch -d <source_branch>` if it had one. If `-d` refuses, report and suggest `-D` rather than force-deleting.
7. Report how it landed (clean vs resolved conflicts).
8. **Close the Ghostty tab** captured in step 1 (skip if the id was empty). Do this last, after reporting — it kills the running agent. Close by the saved id, not by working directory (the path is gone now):

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
