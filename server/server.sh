#!/bin/sh
# Actualizar e instalar paquetes necesarios
apk update && apk add --no-cache openssl netcat-openbsd

echo "Servidor: Esperando a que se genere la clave pública del cliente..."
# Espera hasta que la clave pública del cliente esté disponible en el volumen compartido
while [ ! -f /app/keys/client_public.pem ]; do
  sleep 2
done
echo "Servidor: Clave pública del cliente encontrada."

# Generar (o actualizar) el archivo de resultados médicos
echo "Resultados médicos: El paciente se encuentra en óptimas condiciones." > /app/results.txt

echo "Servidor: Cifrando el documento con la clave pública del cliente..."
# Cifrar el documento usando la clave pública del cliente
openssl rsautl -encrypt -pubin -inkey /app/keys/client_public.pem -in /app/results.txt -out /app/encrypted.txt

echo "Servidor: Iniciando servidor TCP en el puerto 5000 (attacker_net)..."
# Escucha en el puerto 5000 en todas las interfaces (incluye attacker_net)
cat /app/encrypted.txt | nc -l -p 5000