# Send Input to Surfaces

Send text and keystrokes to terminal surfaces programmatically.

Automation rule: never rely on the focused surface. Resolve a target surface first, then pass `--surface`.

## Send Text

```bash
# Send to specific surface
cmux send --surface surface:7 "echo hello\n"

# Send without trailing newline (won't execute)
cmux send --surface surface:7 "partial command"
```

> Use `\n` to execute the command. Without it, text is typed but not submitted.

## Send Keys

```bash
cmux send-key --surface surface:7 enter
cmux send-key --surface surface:7 tab
cmux send-key --surface surface:7 escape
cmux send-key --surface surface:7 backspace
cmux send-key --surface surface:7 up
cmux send-key --surface surface:7 down
cmux send-key --surface surface:7 left
cmux send-key --surface surface:7 right

# Modifier combinations
cmux send-key --surface surface:7 ctrl+c
cmux send-key --surface surface:7 ctrl+d
cmux send-key --surface surface:7 ctrl+z
```

## Common Patterns

### Start a command in another terminal

```bash
# Create a new terminal surface
cmux new-surface --type terminal --pane pane:1

# Send a command to it (get surface ref from new-surface output)
cmux send --surface surface:8 "cd ~/project && npm start\n"
```

### Interrupt a running process

```bash
cmux send-key --surface surface:7 ctrl+c
```

### Confirm a prompt

```bash
cmux send --surface surface:7 "y\n"
```
