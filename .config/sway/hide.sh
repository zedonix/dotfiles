#!/bin/bash

# State file to store toggle state
STATE_FILE="/tmp/cursor_hidden_state"

# Get screen dimensions
output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused==true)')
width=$(echo "$output" | jq '.current_mode.width')
height=$(echo "$output" | jq '.current_mode.height')

# Get center coordinates
center_x=$((width / 2))
center_y=$((height / 2))

# Read current state, default to 0 (visible)
if [[ -f $STATE_FILE ]]; then
    state=$(cat "$STATE_FILE")
else
    state=0
fi

if [[ "$state" -eq 0 ]]; then
    # Hide cursor: move to bottom-right
    swaymsg seat '*' cursor set $((width-1)) $((height-1))
    echo 1 > "$STATE_FILE"
else
    # Show cursor: move to center
    swaymsg seat '*' cursor set "$center_x" "$center_y"
    echo 0 > "$STATE_FILE"
fi
