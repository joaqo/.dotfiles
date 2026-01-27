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
    set itermWasFocused to false

    if itermWasRunning then
        tell application "System Events"
            set frontApp to name of first application process whose frontmost is true
            if frontApp is "iTerm2" then
                set itermWasFocused to true
            end if
        end tell
    end if

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
                -- Switch back to original tab if iTerm was focused
                if itermWasFocused then
                    select originalTab
                end if
            end tell
        end if
    end tell

end run
