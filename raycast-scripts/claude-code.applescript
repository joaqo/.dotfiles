#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Claude Code
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Dev Tools

# Arguments:
# @raycast.argument1 { "type": "text", "placeholder": "prompt" }

on run argv
    set inputText to item 1 of argv

    -- Write to temp file via AppleScript file I/O (no shell involvement).
    -- $(cat) output inside double quotes is not re-expanded by the shell.
    set tempFile to POSIX file "/tmp/claude-prompt.txt"
    set fileRef to open for access tempFile with write permission
    set eof of fileRef to 0
    write inputText to fileRef as «class utf8»
    close access fileRef
    set cmdText to "cd ~/mellow && claude \"$(cat /tmp/claude-prompt.txt)\""

    set itermWasRunning to application "iTerm" is running

    tell application "iTerm"
        if not itermWasRunning then
            -- Launch without activating, use initial window/tab
            launch
            delay 0.5
            tell current session of current window
                write text cmdText
            end tell
        else
            -- iTerm running — check if a window exists
            if (count of windows) is 0 then
                create window with default profile
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
        end if
    end tell

end run
