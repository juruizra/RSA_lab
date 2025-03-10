#!/bin/sh
# Install dependencies
apk update && apk add --no-cache openssl socat

# Generate server keys if missing
if [ ! -f /app/server_private.pem ]; then
  echo "Server: Generating RSA keys..."
  openssl genrsa -out /app/server_private.pem 2048
  openssl rsa -in /app/server_private.pem -pubout -out /shared_keys/server_public.pem
fi

# Wait for client's public key
echo "Server: Waiting for client's public key..."
while [ ! -f /shared_keys/client_public.pem ]; do
  sleep 2
done

# Encrypt medical results using pkeyutl 
echo "Server: Encrypting results..."
openssl pkeyutl -encrypt -pubin -inkey /shared_keys/client_public.pem \
  -in /app/results.txt -out /app/encrypted.txt

# Listen for a connection for a limited time and then exit
echo "Server: Listening for connections on 172.20.0.2:5000..."
timeout 30s socat TCP-LISTEN:5000,fork,reuseaddr FILE:/app/encrypted.txt

echo "Server: Transmission complete. Exiting."
