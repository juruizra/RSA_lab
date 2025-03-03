#!/bin/sh
# Install dependencies
apk update && apk add --no-cache tcpdump socat

# Forward traffic between networks
echo "Attacker: Setting up traffic forwarding..."
socat TCP-LISTEN:5000,fork,reuseaddr TCP:172.20.0.2:5000 &

# Capture traffic on both networks
echo "Attacker: Starting packet capture..."
tcpdump -i any -w /app/capture.pcap -v

echo "Attacker: Captured traffic saved to /app/capture.pcap"