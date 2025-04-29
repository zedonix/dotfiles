while true; do
    date=$(date +'%A, %d %b')
    time=$(date +'%I:%M %p')

    echo "$date | $time"
    sleep 60
done
