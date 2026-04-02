# Send Input to Surfaces

Send text and keystrokes to terminal surfaces programmatically.

## Send Text

```bash
# Send to focused surface
cmux send "npm run dev\n"

# Send to specific surface
cmux send --surface surface:7 "echo hello\n"

# Send without trailing newline (won't execute)
cmux send "partial command"
```

> Use `\n` to execute the command. Without it, text is typed but not submitted.

## Send Keys

```bash
# Send to focused surface
cmux send-key enter
cmux send-key tab
cmux send-key escape
cmux send-key backspace
cmux send-key up
cmux send-key down
cmux send-key left
cmux send-key right

# Send to specific surface
cmux send-key --surface surface:7 enter

# Modifier combinations
cmux send-key ctrl+c
cmux send-key ctrl+d
cmux send-key ctrl+z
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
