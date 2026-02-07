#!/bin/bash

# Skip if headless (-p flag in parent claude process)
parent_args=$(ps -p $PPID -o args= 2>/dev/null)
[[ "$parent_args" =~ " -p " || "$parent_args" =~ " --print " ]] && exit 0

# Read input first (Claude Code expects this)
input=$(cat)

# Log for debugging missing notification messages
LOG_FILE="$HOME/.dotfiles/.claude/hooks/notify-debug.log"

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

# Extract message - prefer input's message field, then transcript
last_message="Claude responded"
input_message=$(echo "$input" | /usr/bin/jq -r '.message // empty')

if [[ -n "$input_message" ]]; then
    last_message=$(echo "$input_message" | head -c 200)
else
    transcript_path=$(echo "$input" | /usr/bin/jq -r '.transcript_path // empty')
    if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
        extracted=$(tail -20 "$transcript_path" | /usr/bin/jq -rs '
            [.[] | select(.type == "assistant")] | last | .message.content |
            if type == "array" then
                ([.[] | select(.type == "text") | .text] | join(" ")) as $text |
                if ($text | length) > 0 then $text
                else "Used " + ([.[] | select(.type == "tool_use") | .name] | join(", "))
                end
            else . end
        ' 2>/dev/null | head -c 200)
        if [[ -n "$extracted" && "$extracted" != "Used " ]]; then
            # Map single tool names to friendly messages
            case "$extracted" in
                "Used ExitPlanMode")   last_message="Waiting for plan approval" ;;
                "Used AskUserQuestion") last_message="Waiting for your answer" ;;
                "Used Edit")           last_message="Made code changes" ;;
                "Used Write")          last_message="Wrote a file" ;;
                "Used Bash")           last_message="Ran a command" ;;
                "Used Task")           last_message="Launched a subagent" ;;
                *)                     last_message="$extracted" ;;
            esac
        fi
    fi
fi

# Log input and output for debugging
{
  echo "=== $(date -Iseconds) ==="
  echo "INPUT:"
  echo "$input" | /usr/bin/jq -c '.' 2>/dev/null || echo "$input"
  echo "OUTPUT: $last_message"
  echo ""
} >> "$LOG_FILE"

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
