#!/bin/bash

# Skip if headless (-p flag in parent claude process)
parent_args=$(ps -p $PPID -o args= 2>/dev/null)
[[ "$parent_args" =~ " -p " || "$parent_args" =~ " --print " ]] && exit 0

# Read input first (Claude Code expects this)
input=$(cat)

# Skip idle_prompt notifications
notification_type=$(echo "$input" | /usr/bin/jq -r '.notification_type // empty')
[[ "$notification_type" == "idle_prompt" ]] && exit 0

# Check if iTerm is frontmost
iterm_frontmost=$(osascript -e 'tell application "System Events" to return frontmost of application process "iTerm2"' 2>/dev/null)

if [[ "$iterm_frontmost" == "true" ]]; then
    # Get visible session's tty
    visible_tty=$(osascript -e 'tell application "iTerm" to return tty of current session of current tab of current window' 2>/dev/null)
    visible_tty="${visible_tty#/dev/}"

    if [[ -n "$TMUX" ]]; then
        # Running inside tmux - check if pane is active AND iTerm tab is visible
        pane_active=$(tmux display-message -p '#{pane_active}' 2>/dev/null)
        window_active=$(tmux display-message -p '#{window_active}' 2>/dev/null)
        tmux_client_tty=$(tmux display-message -p '#{client_tty}' 2>/dev/null)
        tmux_client_tty="${tmux_client_tty#/dev/}"

        [[ "$pane_active" == "1" && "$window_active" == "1" && "$tmux_client_tty" == "$visible_tty" ]] && exit 0
    else
        # Not in tmux - check by comparing parent tty with visible session tty
        check_pid=$PPID
        parent_tty=""
        for i in 1 2 3 4 5; do
            parent_tty=$(ps -p $check_pid -o tty= 2>/dev/null | tr -d ' ')
            [[ -n "$parent_tty" && "$parent_tty" != "??" ]] && break
            check_pid=$(ps -p $check_pid -o ppid= 2>/dev/null | tr -d ' ')
            [[ -z "$check_pid" || "$check_pid" == "1" ]] && break
        done

        [[ "$parent_tty" == "$visible_tty" ]] && exit 0
    fi
fi

# Extract last message from transcript
transcript_path=$(echo "$input" | /usr/bin/jq -r '.transcript_path // empty')
last_message="Claude responded"
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    extracted=$(tail -20 "$transcript_path" | /usr/bin/jq -rs '
        [.[] | select(.type == "assistant")] | last | .message.content |
        if type == "array" then [.[] | select(.type == "text") | .text] | join(" ")
        else . end
    ' 2>/dev/null | head -c 200)
    [[ -n "$extracted" ]] && last_message="$extracted"
fi

# Send notification
if [[ -n "$TMUX" ]]; then
    focus_arg=$(tmux display-message -p '#{client_tty}' 2>/dev/null)
else
    focus_arg="$ITERM_SESSION_ID"
fi

/opt/homebrew/bin/terminal-notifier \
  -title "Claude Code" \
  -message "$last_message" \
  -sound Hero \
  -execute "$HOME/.dotfiles/bin/focus-iterm-session $focus_arg"
