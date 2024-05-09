#!/bin/bash

log_file="$HOME/triz_labs/network_status.log"
valid_ip_found=false

# Function to check for a valid IP address
check_ip_address() {
    interface=$(iwconfig 2>/dev/null | grep -oP '^\w+' | head -n 1)
    ip_address=$(ifconfig "$interface" | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | awk '{print $2}')
    if [ -n "$ip_address" ]; then
        if ! $valid_ip_found; then
            echo "$(date +'%Y-%m-%d %H:%M:%S') - Network is available" >> "$log_file"
            echo "$(date +'%Y-%m-%d %H:%M:%S') - Valid IP address found: $ip_address" >> "$log_file"
            valid_ip_found=true
            return 0
        fi
        
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') - No valid IP address found" >> "$log_file"
        valid_ip_found=false
        return 1
    fi
}

# Main loop
while true; do
    if check_ip_address; then
        sleep 10
    else
        # Apply Netplan configuration
        echo "$(date +'%Y-%m-%d %H:%M:%S') - Applying Netplan configuration" >> "$log_file"
        sudo netplan apply >> /dev/null 2>&1
        sleep 10
        
        # Check for IP address again
        if check_ip_address; then
            sleep 10
        else
            # Reset network
            echo "$(date +'%Y-%m-%d %H:%M:%S') - Resetting network" >> "$log_file"
            sudo systemctl restart NetworkManager >> /dev/null 2>&1
            sleep 10
        fi
    fi
done
