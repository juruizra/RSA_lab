#!/bin/sh
# Install dependencies
apk update && apk add --no-cache openssl netcat-openbsd

# Generate client keys if missing
if [ ! -f /app/client_private.pem ]; then
  echo "Client: Generating RSA keys..."
  openssl genrsa -out /app/client_private.pem 2048
  openssl rsa -in /app/client_private.pem -pubout -out /shared_keys/client_public.pem
fi

# Wait for server to be ready
echo "Client: Waiting for server..."
sleep 10

# Receive encrypted file via attacker
echo "Client: Connecting to attacker (172.22.0.3:5000)..."
nc 172.22.0.3 5000 > /app/encrypted.txt

# Decrypt results using pkeyutl 
echo "Client: Decrypting results..."
openssl pkeyutl -decrypt -inkey /app/client_private.pem \
  -in /app/encrypted.txt -out /app/decrypted.txt

echo "Client: Decryption complete. Results:"
cat /app/decrypted.txt

