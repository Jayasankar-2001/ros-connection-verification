#!/bin/bash

log_file="$HOME/triz_labs/internet_status.log"
internet_available=false

# Ensure the directory exists
mkdir -p "$(dirname "$log_file")"

while true; do
    if ping -c 1 google.com &> /dev/null; then
        if [ "$internet_available" = false ]; then
            echo "$(date +'%Y-%m-%d %H:%M:%S') - Internet connection is available" >> "$log_file"
            echo "$(date +'%Y-%m-%d %H:%M:%S') - Internet connection is available"
            internet_available=true
        fi
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') - Internet connection not available" >> "$log_file"
        internet_available=false
    fi
    sleep 10
done
