---
name: cmux
description: End-user control of cmux topology and routing (windows, workspaces, panes/surfaces, non-focus moves, reorder, identify, trigger flash). Use when automation needs deterministic placement and navigation in a multi-pane cmux layout.
---

# cmux Core Control

Use this skill to control non-browser cmux topology and routing.

## Core Concepts

- Window: top-level macOS cmux window.
- Workspace: tab-like group within a window.
- Pane: split container in a workspace.
- Surface: a tab within a pane (terminal or browser panel).

## Targeting Rule

- Default to `caller` context from `cmux identify --json`, not `focused`.
- Use `caller.workspace_ref` plus explicit pane/surface refs you just created or verified.
- Do not infer the target from `focused.workspace_ref`, `focused.pane_ref`, or `focused.surface_ref` unless the user explicitly wants the currently focused UI.
- Do not call `select-workspace`, `focus-window`, `focus-pane`, `focus-surface`, `focus-panel`, or `move-surface --focus true` during agent automation unless the user explicitly asks for a visible UI focus change.
- If the user explicitly asks to change visible UI focus, use the manual-only focus sections in the reference docs instead of mixing those commands into normal automation flows.
- After creating or moving anything, verify placement with `cmux tree`, `cmux list-panes`, or `cmux list-pane-surfaces` before continuing.
- For browser surfaces: if a command times out, keep retrying the same surface for about 30 seconds before calling it stuck. Do not open extra replacement pages during that window. If replacement is needed, close the stuck surface first with `cmux close-surface --surface ...`, then open one replacement surface.

## Fast Start

```bash
# identify current caller context
cmux identify --json

# list topology
cmux list-windows
cmux list-workspaces
cmux list-panes
cmux list-pane-surfaces --pane pane:1

# create/route/move
cmux new-workspace
cmux new-split right --panel pane:1
cmux move-surface --surface surface:7 --pane pane:2
cmux reorder-surface --surface surface:7 --before surface:3

# send input to a terminal surface
cmux send --surface surface:7 "npm run dev\n"
cmux send-key --surface surface:7 ctrl+c

# attention cue
cmux trigger-flash --surface surface:7
```

## Handle Model

- Default output uses short refs: `window:N`, `workspace:N`, `pane:N`, `surface:N`.
- UUIDs are still accepted as inputs.
- Request UUID output only when needed: `--id-format uuids|both`.

## Deep-Dive References

| Reference | When to Use |
|-----------|-------------|
| [references/handles-and-identify.md](references/handles-and-identify.md) | Handle syntax, self-identify, caller targeting |
| [references/windows-workspaces.md](references/windows-workspaces.md) | Window/workspace lifecycle and reorder/move |
| [references/panes-surfaces.md](references/panes-surfaces.md) | Splits, surfaces, non-focus move/reorder, routing |
| [references/trigger-flash-and-health.md](references/trigger-flash-and-health.md) | Flash cue and surface health checks |
| [references/send-input.md](references/send-input.md) | Send text and keystrokes to terminal surfaces |
| [references/sidebar-notifications.md](references/sidebar-notifications.md) | Notifications, status pills, progress bars, log entries |
| [../cmux-browser/SKILL.md](../cmux-browser/SKILL.md) | Browser automation on surface-backed webviews |
| [../cmux-markdown/SKILL.md](../cmux-markdown/SKILL.md) | Markdown viewer panel with live file watching |
