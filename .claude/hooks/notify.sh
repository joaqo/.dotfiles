#!/bin/bash
repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "")

input=$(cat)
transcript_path=$(echo "$input" | /usr/bin/jq -r '.transcript_path')

last_message="Done"
if [[ -f "$transcript_path" ]]; then
  last_message=$(tail -20 "$transcript_path" | /usr/bin/jq -rs '[.[] | select(.type == "assistant")] | last | .message.content | if type == "array" then [.[] | select(.type == "text") | .text] | join(" ") else . end' 2>/dev/null | head -c 200)
  [[ -z "$last_message" ]] && last_message="Done"
fi

/opt/homebrew/bin/terminal-notifier \
  -title "Claude Code" \
  -subtitle "$repo" \
  -message "$last_message" \
  -sound Hero \
  -execute "$HOME/.local/bin/focus-iterm-session '$ITERM_SESSION_ID'"
