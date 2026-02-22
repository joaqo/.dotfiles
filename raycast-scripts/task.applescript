#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Task
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ⛏️
# @raycast.packageName Dev Tools

# Arguments:
# @raycast.argument1 { "type": "text", "placeholder": "prompt" }

on run argv
    set inputText to item 1 of argv
    -- Replace newlines with spaces to avoid multiline issues
    set AppleScript's text item delimiters to {linefeed, return}
    set textItems to text items of inputText
    set AppleScript's text item delimiters to " "
    set inputText to textItems as text
    set AppleScript's text item delimiters to ""
    set cmdText to "cd ~/mellow && company task run " & quoted form of inputText & "; exit"

    set itermWasRunning to application "iTerm" is running

    tell application "iTerm"
        if not itermWasRunning then
            -- Launch without activating, use initial window/tab
            launch
            delay 0.5
        else
            -- iTerm running, create new tab
            tell current window
                create tab with default profile
            end tell
        end if
        tell current session of current window
            write text cmdText
        end tell
    end tell
end run
