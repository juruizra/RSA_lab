#!/bin/sh
# Actualizar e instalar paquetes necesarios
apk update && apk add --no-cache openssl netcat-openbsd

# Verificar si ya existen las llaves RSA; si no, generarlas
if [ ! -f /app/private.pem ]; then
  echo "Cliente: Generando par de llaves RSA..."
  openssl genrsa -out /app/private.pem 2048
  openssl rsa -in /app/private.pem -pubout -out /app/public.pem
  # Compartir la clave pública para que el servidor la encuentre
  cp /app/public.pem /app/keys/client_public.pem
  echo "Cliente: Llaves generadas y clave pública compartida."
fi

# Dar tiempo al servidor para que esté listo y detecte la clave pública
sleep 10

echo "Cliente: Conectándose al servidor (172.21.0.2) para recibir el archivo cifrado..."
# Conectar al servidor usando la IP de attacker_net (172.21.0.2) y recibir el archivo cifrado
nc 172.21.0.2 5000 > /app/encrypted.txt

echo "Cliente: Descifrando el archivo recibido..."
# Descifrar el archivo usando la clave privada
openssl rsautl -decrypt -inkey /app/private.pem -in /app/encrypted.txt -out /app/decrypted.txt

echo "Cliente: Proceso completado. Revisa 'decrypted.txt' para ver el contenido descifrado."