#!/bin/bash
# Get screen dimensions
output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused==true)')
width=$(echo "$output" | jq '.current_mode.width')
height=$(echo "$output" | jq '.current_mode.height')

# Move to bottom-right corner (offset by 1px to avoid edge detection issues)
swaymsg seat '*' cursor set $((width-1)) $((height-1))
