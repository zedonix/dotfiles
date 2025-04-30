#!/bin/bash
prev_status=$(nmcli networking connectivity)

while true; do
  current_status=$(nmcli networking connectivity)

  if [[ $current_status != $prev_status ]]; then
    case $current_status in
      full) notify-send "Internet Connected" "Connection established" ;;
      none) notify-send "Internet Disconnected" "No network access" ;;
    esac
    prev_status=$current_status
  fi

  sleep 5
done
