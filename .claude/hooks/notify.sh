#!/bin/bash

# Skip if headless (-p flag in parent claude process)
parent_args=$(ps -p $PPID -o args= 2>/dev/null)
[[ "$parent_args" =~ " -p " || "$parent_args" =~ " --print " ]] && exit 0

# Skip if this iTerm session is focused
session_id="${ITERM_SESSION_ID#*:}"
is_focused=$(osascript <<EOF
tell application "System Events"
    if frontmost of application process "iTerm2" is false then return "no"
end tell
tell application "iTerm"
    set currentSession to current session of current tab of current window
    if unique id of currentSession is "$session_id" then return "yes"
end tell
return "no"
EOF
)
[[ "$is_focused" == "yes" ]] && exit 0

repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "")

input=$(cat)

# Skip idle_prompt notifications (Stop hook already handles "done" notifications)
notification_type=$(echo "$input" | /usr/bin/jq -r '.notification_type // empty')
[[ "$notification_type" == "idle_prompt" ]] && exit 0

transcript_path=$(echo "$input" | /usr/bin/jq -r '.transcript_path')

last_message="Done"
if [[ -f "$transcript_path" ]]; then
  last_message=$(tail -20 "$transcript_path" | /usr/bin/jq -rs '[.[] | select(.type == "assistant")] | last | .message.content | if type == "array" then [.[] | select(.type == "text") | .text] | join(" ") else . end' 2>/dev/null | head -c 200)
  [[ -z "$last_message" ]] && last_message="Done"
fi

/opt/homebrew/bin/terminal-notifier \
  -title "Claude Code" \
  -message "$last_message" \
  -sound Hero \
  -execute "$HOME/.dotfiles/bin/focus-iterm-session '$ITERM_SESSION_ID'"
