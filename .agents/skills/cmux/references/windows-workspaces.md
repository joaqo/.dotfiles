# Windows and Workspaces

Window/workspace lifecycle and ordering operations.

Automation rule: never call `focus-window` or `select-workspace` unless the user explicitly asks to change visible UI focus.

## Inspect

```bash
cmux list-windows
cmux current-window
cmux list-workspaces
cmux current-workspace
```

## Create/Close

```bash
cmux new-window
cmux close-window --window window:2

cmux new-workspace
cmux close-workspace --workspace workspace:4
```

## Manual Focus Commands

Only use these when the user explicitly asks to change visible UI focus.

```bash
cmux focus-window --window window:2
cmux select-workspace --workspace workspace:4
```

## Reorder and Move

```bash
cmux reorder-workspace --workspace workspace:4 --before workspace:2
cmux move-workspace-to-window --workspace workspace:4 --window window:1
```
