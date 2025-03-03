#!/bin/sh
# Install dependencies
apk update && apk add --no-cache tcpdump socat

# Start traffic forwarding in the background and save its PID
echo "Attacker: Setting up traffic forwarding..."
socat TCP-LISTEN:5000,fork,reuseaddr TCP:172.20.0.2:5000 &
FORWARD_PID=$!

# Set up trap to terminate the forwarding process when the script exits
trap "echo 'Attacker: Terminating forwarding process...'; kill $FORWARD_PID 2>/dev/null" EXIT

# Capture traffic on both networks without entering promiscuous mode for a limited time
echo "Attacker: Starting packet capture..."
timeout 30s tcpdump -p -i any -w /app/capture.pcap -v

echo "Attacker: Captured traffic saved to /app/capture.pcap"

# Instead of opening an interactive shell automatically,
# leave the container running so you can exec into it later.
echo "Attacker: Capture complete. Container will remain running."
tail -f /dev/null
