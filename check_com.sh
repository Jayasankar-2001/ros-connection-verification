#!/bin/bash

# IP address of the second computer
computer2_ip="192.168.137.140"

# Function to log connection status
log_connection_status() {
    local status="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $status" >> ~/com_check.log
}

# Check connection status
ping -c 1 $computer2_ip > /dev/null 2>&1

if [ $? -eq 0 ]; then
    # Connection is established, make computer 1 connection as default
    echo "Connection established"
    log_connection_status "Connection established"
else
    # Recheck connection status for 12 seconds
    end_time=$((SECONDS + 12))
    while [ $SECONDS -lt $end_time ]; do
        ping -c 1 $computer2_ip > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            # Connection established within 12 seconds
            echo "Connection established"
            log_connection_status "Connection established"
            exit 0
        fi
        sleep 1  # Wait for 1 second before rechecking
    done

    # No connection established after 12 seconds
    echo "Computer 1 communication error"
    log_connection_status "Computer 1 communication error"

    # Read computer 2 error log and display
    ssh user@$computer2_ip "cat /path/to/error.log" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Error log on computer 2:"
        ssh user@$computer2_ip "cat /path/to/error.log"
    else
        echo "Failed to read error log on computer 2"
    fi
fi

