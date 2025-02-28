#!/bin/sh
# Actualizar e instalar paquetes necesarios
apk update && apk add --no-cache tcpdump netcat-openbsd

# Esperar unos segundos para que comience la comunicación
sleep 5

echo "Atacante: Iniciando tcpdump para capturar tráfico en el puerto 5000 en attacker_net..."
# Capturar 20 paquetes del tráfico que pase por el puerto 5000 en la interfaz eth0
tcpdump -i eth0 port 5000 -w /app/capture.pcap -c 20

echo "Atacante: Captura completada. Archivo guardado en /app/capture.pcap."

echo "Atacante: Intentando descifrar la información capturada (esto fallará sin la clave privada)..."
# Ejemplo de intento de descifrado (comentado, ya que no se dispone de la clave privada)
# openssl rsautl -decrypt -inkey /app/clave_privada_atacante.pem -in /app/capture.pcap -out /app/attempt_decrypted.txt
echo "Atacante: Fin del proceso."