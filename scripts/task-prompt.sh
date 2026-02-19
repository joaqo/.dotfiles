#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$("$SCRIPT_DIR/TaskPrompt/task-prompt" 2>/dev/null)

if [ -z "$INPUT" ]; then
    exit 0
fi

osascript <<ITERM
set itermWasRunning to application "iTerm" is running

tell application "iTerm"
    if not itermWasRunning then
        launch
        delay 0.5
        tell current session of current window
            write text "cd ~/mellow && company task run " & quoted form of "$INPUT"
        end tell
    else
        tell current window
            set originalTab to current tab
            set newTab to (create tab with default profile)
            tell current session of newTab
                write text "cd ~/mellow && company task run " & quoted form of "$INPUT"
            end tell
            select originalTab
        end tell
    end if
end tell
ITERM
