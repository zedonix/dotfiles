while true; do
    VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '/Volume/ {print $2}' | awk '{printf "%.0f", $1 * 100}')
    MUTE_STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '/Volume/ {print $3}')
    if [[ "$MUTE_STATUS" == "[MUTED]" ]]; then
        echo "$(date +'[%a %d %b %I:%M:%S %p]') [Vol: muted]"
    else
        echo "$(date +'[%a %d %b %I:%M:%S %p]') [Vol: ${VOLUME}%]"
    fi
    sleep 1
done
