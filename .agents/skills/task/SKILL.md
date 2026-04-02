---
name: task
description: Personal workflow for creating, resuming, and managing coding tasks across projects. Whenever I tell you to do a task, load up this skill.
---

# Task Workflow
Use this skill when the user wants to start, resume, or reorganize a coding task.

## Rules
- Use `agent`. Never call `codex` or `claude` directly.
- Use the [`cmux`](../cmux/SKILL.md) skill for workspace and tab operations.
- This skill is a launcher. Do not do the coding work yourself in the current session.
- If the user says `task: <prompt>`, treat `<prompt>` as the payload to forward to `agent open`.
- Treat task creation as a launch flow, not a management loop.
- Once the task is launched, stop. Do not poll, monitor, inspect transcripts, or wait for progress.
- Keep the launch sequence lean. Use the fewest cmux commands that still produce the standard result.
- Run launch commands one by one. Do not wrap the cmux launch flow in a shell script block.
- Do not run `--help` commands for `agent` or `cmux` unless a command actually fails and you need syntax.
- Use the exact cmux output-parsing pattern documented below. Do not improvise with other parsing.
- Do not inspect the repo to rediscover helper names already documented here or in `AGENTS.md`.
- Do not run exploratory commands, this is supposed to be a simple repeatable task that you'll be doing over and over, just do it quickly based on the instructions here. No improvisation.
- During launch, do not run `agent --help`, `agent sessions`, `cmux list-panes`, `cmux list-pane-surfaces`, `sleep`, or `git status` unless a previous command failed and you need to recover.
- Do not report session ids unless the user asks.

## Create a Task
1. Decide whether the task should run in the current repo or a new worktree.
2. If it needs a worktree choose a branch name for it and create the worktree.
3. If the worktree helper says the worktree already exists, reuse it immediately and continue.
4. Create a cmux workspace in the target cwd.
5. Launch the agent with the forwarded task prompt.
6. Consider your job done and stop after launch.

### Worktree Policy
- Prefer a worktree for almost all tasks
- Prefer the current repo for diagnostics, tasks that are just running a command, or when the user explicitly says not to use a worktree.
- The skill chooses the branch name. Keep it short and kebab-case. Prefer prefixes like `fix/`, `feat/`, `refactor/`, `chore/`.

### Creating worktrees
- In repos without a helper, use plain git worktrees.

### Generic Git Worktree Pattern
```bash
repo_root="$(git rev-parse --show-toplevel)"
repo_name="$(basename "$repo_root")"
branch="feat/example"
path=~/worktrees/<repo-name>-<branch-with-slashes-replaced>
git -C "$repo_root" worktree add -b "$branch" "$path"
```

## Delete a Task
1. Identify the target worktree path and branch.
2. If the repo has a helper for local cleanup, use it.
3. Otherwise:
   - stop any repo processes tied to that worktree if you started them
   - `git worktree remove --force <path>`
   - `git -C <main-repo> branch -D <branch>`

## Merge a Task
1. Identify the task worktree, branch, main repo path, and base branch.
2. Verify the task worktree is clean: no uncommitted changes.
3. Rebase the task branch onto the base branch.
4. Fast-forward merge the task branch into the base branch from the main repo.
5. Delete the worktree and merged branch.
6. If the repo has local cleanup rules, run its delete helper after merge or use its integrated finish flow if one exists.

If you encounter anything unexpected or any command fails, just stop, explain to me what happened and wait for further instructions. Always play it safe.

Default git flow:

```bash
task_path="$(git rev-parse --show-toplevel)"
task_branch="$(git -C "$task_path" branch --show-current)"
main_repo="$(git -C "$task_path" worktree list --porcelain | awk '/^worktree /{print $2; exit}')"
base_branch="$(git -C "$main_repo" branch --show-current)"

git -C "$task_path" status --short
git -C "$task_path" rebase "$base_branch"
git -C "$main_repo" merge --ff-only "$task_branch"
git -C "$main_repo" branch -d "$task_branch"
git -C "$main_repo" worktree remove --force "$task_path"
```

Notes:
- Prefer `--ff-only`.
- Prefer rebasing before merge.
- Delete the branch only after merge succeeds.
- If the repo is in a dirty state or the rebase conflicts, stop and tell the user.

## Launch Pattern
```bash
workspace_ref=$(cmux new-workspace --name "<name>" --cwd "<target-cwd>" --command 'agent open "<prompt>"' | awk '{print $2}')
surface_ref=$(cmux --json new-surface --workspace "$workspace_ref" | jq -r '.surface_ref')
cmux rename-tab --workspace "$workspace_ref" --surface "$surface_ref" "nvim"
cmux send --surface "$surface_ref" --workspace "$workspace_ref" "nvim\n"
surface_ref=$(cmux --json new-surface --workspace "$workspace_ref" | jq -r '.surface_ref')
cmux rename-tab --workspace "$workspace_ref" --surface "$surface_ref" "lazygit"
cmux send --surface "$surface_ref" --workspace "$workspace_ref" "lazygit\n"
```

Parsing rules:
- `cmux new-workspace` returns short text like `OK workspace:23`. Extract the second field for the workspace ref.
- `cmux --json new-surface` returns JSON. Extract `.surface_ref`.
Pass the user request directly and simply to `agent open "<prompt>"`. Do not rewrite it into a long launcher prompt.
If the user invoked this skill with `task: <prompt>`, pass `<prompt>` through to `agent open` and do not attempt the task yourself first.
Name the cmux workspace after the branch name if in a branch, or else `MAIN:${project_name}`
If `cmux new-workspace` succeeds, assume the launch succeeded. Do not do extra verification after that unless a later command fails.

## Resume Pattern
1. Run `agent sessions`.
2. Find the target session by cwd, title, or recent activity.
3. If a matching cmux workspace exists, focus it.
4. If not, create a workspace in that cwd and run `agent resume <session-id>`.

## Mellow
- Create worktrees with `mellow worktree add <branch>`.
- Delete worktrees with `mellow worktree delete <target>`.
- Use Mellow helpers for repo-local cleanup. Keep generic task policy in this skill.
- For Mellow task launch, use `mellow worktree add` directly. Do not inspect the repo to rediscover that helper.
