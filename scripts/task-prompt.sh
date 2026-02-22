#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$("$SCRIPT_DIR/TaskPrompt/task-prompt" 2>/dev/null)

if [ -z "$INPUT" ]; then
    exit 0
fi

osascript - "$INPUT" <<'ITERM'
on run argv
    set inputText to item 1 of argv

    -- Write to temp file to avoid shell escaping issues with special chars
    set tempFile to POSIX file "/tmp/company-task-prompt.txt"
    set fileRef to open for access tempFile with write permission
    set eof of fileRef to 0
    write inputText to fileRef as «class utf8»
    close access fileRef

    set cmdText to "cd ~/mellow && company task run -f /tmp/company-task-prompt.txt; exit"
    set itermWasRunning to application "iTerm" is running

    tell application "iTerm"
        if not itermWasRunning then
            launch
            delay 0.5
            tell current session of current window
                write text cmdText
            end tell
        else
            tell current window
                set originalTab to current tab
                set newTab to (create tab with default profile)
                tell current session of newTab
                    write text cmdText
                end tell
                select originalTab
            end tell
        end if
    end tell
end run
ITERM
