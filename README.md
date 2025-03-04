
Este proyecto es un laboratorio académico y educativo que simula una comunicación segura utilizando RSA sobre un canal inseguro. Se implementa un escenario en el que una compañía médica envía resultados de exámenes médicos cifrados a un paciente, mientras un atacante intenta interceptar el tráfico. La comunicación se realiza a través de contenedores Docker, con redes separadas para el servidor, el cliente y el atacante.

## Tabla de Contenidos

- Objetivos
    
- Topología y Escenario
    
- Requisitos
    
- Estructura del Proyecto
    
- Archivos y Scripts
    
    - docker-compose.yml
        
    - server/server.sh
        
    - client/client.sh
        
    - attacker/attacker.sh
        
- Pasos para Ejecutar el Laboratorio
    
- Extensiones y Pruebas Adicionales
    
- Conclusión
    

---

## Objetivos

- **Demostrar el uso de RSA:**  
    Se muestra cómo se utiliza RSA para cifrar información sensible en un entorno realista (envío de resultados médicos).
    
- **Simulación de un Canal Inseguro:**  
    La comunicación entre el servidor y el cliente se realiza a través de una red insegura accesible por un atacante.
    
- **Análisis de Ataques:**  
    Se permite observar cómo un atacante puede interceptar el tráfico, y se explica que, sin la clave privada correcta, la información permanece segura.
    
- **Automatización de Llaves:**  
    El cliente genera automáticamente un par de llaves RSA y comparte su clave pública para que el servidor la use en el cifrado.
    

---

## Topología y Escenario

Se crean tres contenedores:

1. **Servidor:**
    
    - Ubicado en la red `server_net` (IP: 172.20.0.2).
        
    - También conectado a `attacker_net` (IP: 172.21.0.2) para la comunicación.
        
    - Cifra un archivo con los resultados médicos utilizando la clave pública del cliente y envía el archivo a través del puerto 5000.
        
2. **Cliente (Paciente):**
    
    - Ubicado en la red `client_net` (IP: 172.22.0.2).
        
    - Genera su par de llaves RSA, comparte su clave pública y descifra el mensaje recibido.
        
3. **Atacante:**
    
    - Conectado únicamente a la red `attacker_net`. Tiene acceso a `server_net` (IP: 172.20.0.3)
        
    - Captura el tráfico en el puerto 5000 para demostrar que, a pesar de la intercepción, no puede descifrar la información sin la clave privada.
        

La comunicación entre el servidor y el cliente se realiza a través de la red `attacker_net`, lo que permite al atacante capturar el tráfico.

---

## Requisitos

Para ejecutar este laboratorio en tu máquina (por ejemplo, Ubuntu, WSL, VM o cualquier distribución de Linux), asegúrate de tener instalados:

- **Ubuntu 18.04 LTS o superior**
    
- **Docker Engine:** [Instalación de Docker en Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
    
- **Docker Compose:** [Instalación de Docker Compose](https://docs.docker.com/compose/install/)
    
- **Permisos Suficientes:**  
    Asegúrate de tener permisos para ejecutar Docker (puedes agregar tu usuario al grupo `docker`).
    
- **Conexión a Internet y Recursos Suficientes:**  
    Verifica que tu sistema tenga la capacidad para correr múltiples contenedores y suficiente espacio en disco. 
    

---

## Estructura del Proyecto

```
RSA_lab/
├── docker-compose.yml
├── shared_keys/         
├── server/
│   ├── server.sh
│   └── results.txt      
├── client/
│   └── client.sh
└── attacker/
    └── attacker.sh
```

---

## Pasos para Ejecutar el Laboratorio

1. Clonar el repositorio y acceder al directorio del proyecto.
```sh
git clone https://github.com/juruizra/rsa_lab
```
    
2. Ejecutar:
    
    ```sh
    docker compose up --build
    ```
    
3. Una vez que el servidor haya finalizado y el atacante siga ejecutándose, abre otra terminal y accede al contenedor del atacante:
    
    ```sh
    docker exec -it attacker /bin/sh
    ```
    
4. Instalar dependencias necesarias:
    
    ```sh
    apk update && apk add --no-cache python3 py3-pip tshark
    ```
    
5. Activar el entorno virtual (opcional, según configuración):
    
    ```sh
    cd home/  # No necesario, puedes ejecutar desde cualquier ruta
    . env/bin/activate
    ```
    
6. Instalar librerías necesarias:
    
    ```sh
    pip install scapy pycryptodome sympy
    ```
    
7. Verificar que la clave pública del cliente esté en la carpeta del atacante. Puedes también montar la carpeta `shared_keys` agregando esta línea en `docker-compose.yml` dentro del servicio del atacante:
    
    ```yaml
    volumes:
      - ./shared_keys:/app
    ```
    
8. Intentar descifrar el mensaje interceptado:
    
    ``` python
    python3 /app/decrypt_attempt.py /app/capture.pcap /shared_keys/client_public.pem
    ```
    
9. Para visualizar el tráfico capturado con `tshark`:
    
    ```
    tshark -r /app/capture.pcap -Y "tcp" -x
    ```
    
    Esto filtra el tráfico TCP y lo imprime en formato hexadecimal.
    

---