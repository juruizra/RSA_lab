#!/bin/sh
# Install dependencies
apk update && apk add --no-cache tcpdump socat

# Start traffic forwarding in the background and save its PID
echo "Attacker: Setting up traffic forwarding..."
socat TCP-LISTEN:5000,fork,reuseaddr TCP:172.20.0.2:5000 &
FORWARD_PID=$!

# Set up trap to terminate the forwarding process when the script exits
trap "echo 'Attacker: Terminating forwarding process...'; kill $FORWARD_PID 2>/dev/null" EXIT

# Capture traffic on both networks 
echo "Attacker: Starting packet capture..."
timeout 30s tcpdump -p -i any -w /app/capture.pcap -v

echo "Attacker: Captured traffic saved to /app/capture.pcap"


# leave the container running to open a terminal later (trying to break the rsa).
echo "Attacker: Capture complete. Container will remain running."
tail -f /dev/null
