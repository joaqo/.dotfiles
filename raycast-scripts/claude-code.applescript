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
    set cmdText to "cd ~/mellow && claude " & quoted form of inputText

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
            -- iTerm running, create new tab
            tell current window
                set originalTab to current tab
                set newTab to (create tab with default profile)
                tell current session of newTab
                    write text cmdText
                end tell
                -- Always switch back to original tab so user isn't disturbed
                select originalTab
            end tell
        end if
    end tell

end run
