#!/bin/bash

# IP address of Computer2
COMPUTER2_IP="192.168.137.140"

# Check if both computers are connected to the same network
ping -c 1 $COMPUTER2_IP > /dev/null 2>&1
if [ $? -eq 0 ]; then
    # Connection established
    echo "$(date) - Connection established" >> ~/sync_error.log
else
    # Connection failed
    echo "$(date) - Connection failed" >> ~/sync_error.log
    exit 1
fi

# Check if the date and time are in sync
while true; do
    DATE1=$(date +%s)
    DATE2=$(ssh user@$COMPUTER2_IP 'date +%s')
    if [ $((DATE1 - DATE2)) -le 5 ]; then
        # Date and time are in sync
        echo "$(date) - Date and time is in sync" >> ~/sync_error.log
        exit 0
    else
        # Date and time are not in sync
        echo "$(date) - Date and time of Computer1 and Computer2 is not in sync... syncing date and time" >> ~/sync_error.log
        # Sync date and time
        ssh user@$COMPUTER2_IP "sudo date -s \"$(date)\""
        echo "$(date) - Date and time synced" >> ~/sync_error.log
        exit 0
    fi
done

