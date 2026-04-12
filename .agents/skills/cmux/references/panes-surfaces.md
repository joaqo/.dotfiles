# Panes and Surfaces

Split layout, surface creation, non-focus move, and reorder.

Automation rule: never call `focus-pane`, `focus-surface`, `focus-panel`, or `move-surface --focus true` unless the user explicitly asks to change visible UI focus.

## Inspect

```bash
cmux list-panes
cmux list-pane-surfaces --pane pane:1
cmux list-surfaces          # flat list of all surfaces across all panes
cmux tree                   # full hierarchy: windows → workspaces → panes → surfaces
```

## Create Splits/Surfaces

```bash
cmux new-split right --panel pane:1
cmux new-surface --type terminal --pane pane:1
cmux new-surface --type browser --pane pane:1 --url https://example.com
```

## Close

```bash
cmux close-surface --surface surface:7
```

## Manual Focus Commands

Only use these when the user explicitly asks to change visible UI focus.

```bash
cmux focus-pane --pane pane:2
cmux focus-surface --surface surface:7
cmux focus-panel --panel surface:7   # legacy alias
```

## Move/Reorder Surfaces

```bash
cmux move-surface --surface surface:7 --pane pane:2
cmux move-surface --surface surface:7 --workspace workspace:2 --window window:1 --after surface:4
cmux reorder-surface --surface surface:7 --before surface:3
```

Only use `cmux move-surface --surface surface:7 --pane pane:2 --focus true` when the user explicitly asks the move to also change visible UI focus.

Surface identity is stable across move/reorder operations.
