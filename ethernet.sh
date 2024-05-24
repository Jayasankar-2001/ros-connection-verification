#!/usr/bin/env bash

echo "Ethernet connectivity status"

log_file="$HOME/triz_labs/internet_status.log"
mkdir -p "$(dirname "$log_file")"

ipaddr() {
   # Detect Ethernet interface
   interface=$(nmcli connection show --active | grep ethernet | awk '{print $6}')

   # Get the IP address of the interface (using awk for better reliability)
   ip_address=$(ip addr show "$interface" | awk '/inet /{print $2}' | cut -d '/' -f 1)
}

# Function to validate IPv4 address
valid_ipv4() {
   local ip="$1"
   [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
   for i in ${ip//./ }; do
       [[ "${#i}" -gt 1 && "${i:0:1}" == 0 ]] && return 1
       [[ "$i" -gt 255 ]] && return 1
   done
}

export -f valid_ipv4
export -f ipaddr

# Function to reset network configuration
reset_network() {
  echo "Resetting network configuration..."
  # You may need to adjust this command based on your network configuration
  sudo netplan apply >> /dev/null 2>&1
  ipaddr
  
  timeout 5 bash -c "
   while :; do
    if ! valid_ipv4 '$ip_address'; then
      echo '$interface IP connectivity is OK. IP address: $ip_address'
      echo \"\$(date +'%Y-%m-%d %H:%M:%S') - Ethernet IP connectivity is OK. IP address: $ip_address\" >> \"$log_file\"
      exit 0
    fi
    sleep 1
   done
  "
  
  # If connectivity issue persists after 5 seconds, report error
  echo "Failed to restore Ethernet IP connectivity."
  echo "$(date +'%Y-%m-%d %H:%M:%S') - Failed to restore Ethernet IP connectivity." >> "$log_file"
  exit 1
}

ipaddr

# Check if the interface is up
if ! ip link show "$interface" up &>/dev/null; then
  echo "Interface $interface is not up."
  exit 1
fi

if [ -z "$ip_address" ]; then
  echo "No IP address assigned to $interface."
  exit 0
fi

# Validate the IP address of the Ethernet interface
if valid_ipv4 "$ip_address"; then
  echo "Ethernet IP address is invalid."
  reset_network
fi

echo "$interface IP connectivity is OK. IP address: $ip_address"
echo "$(date +'%Y-%m-%d %H:%M:%S') - Ethernet IP connectivity is OK. IP address: $ip_address" >> "$log_file"
