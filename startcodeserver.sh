#!/data/data/com.termux/files/usr/bin/bash

# Directorio de configuración de code-server
CONFIG_DIR="$HOME/.config/code-server"
KEY_FILE="$CONFIG_DIR/selfsigned.key"
CERT_FILE="$CONFIG_DIR/selfsigned.crt"
PID_FILE="/tmp/code-server.pid"

# Función para limpiar al salir
cleanup() {
    if [ -f "$PID_FILE" ]; then
        CODE_SERVER_PID=$(cat "$PID_FILE")
        echo "Cerrando code-server (PID: $CODE_SERVER_PID)..."
        kill $CODE_SERVER_PID 2>/dev/null
        rm -f "$PID_FILE"
    fi
    exit 0
}

# Registrar la función de limpieza para señales de terminación
trap cleanup SIGINT SIGTERM EXIT

# Verificar si code-server está instalado
if ! command -v code-server &> /dev/null; then
    echo "code-server no está instalado. Por favor, instálalo primero."
    exit 1
fi

# Puerto inicial
PORT=8080
MAX_PORT=8180  # Límite máximo de puerto a intentar

# Buscar un puerto disponible
while lsof -i:$PORT &> /dev/null; do
    PORT=$((PORT + 1))
    if [ $PORT -gt $MAX_PORT ]; then
        echo "No se encontró ningún puerto disponible entre 8080 y $MAX_PORT"
        exit 1
    fi
done

# Obtener la IP local del dispositivo (evita loopback 127.0.0.1)
IP_LOCAL=$(ifconfig | awk '/inet / && !/127.0.0.1/ {print $2}' | head -n 1)

# Si sigue sin obtener la IP, asignar localhost como última opción
if [[ -z "$IP_LOCAL" ]]; then
    IP_LOCAL="127.0.0.1"
fi

# Verificar si los certificados SSL existen
if [[ -f "$KEY_FILE" && -f "$CERT_FILE" ]]; then
    # Iniciar code-server con HTTPS
    code-server --bind-addr "0.0.0.0:$PORT" --auth none --cert "$CERT_FILE" --cert-key "$KEY_FILE" &
    PROTOCOL="https"
else
    # Iniciar code-server con HTTP
    code-server --bind-addr "0.0.0.0:$PORT" --auth none &
    PROTOCOL="http"
fi

# Guardar el PID del proceso
echo $! > "$PID_FILE"

# Mostrar información al usuario
echo "code-server se está ejecutando en $PROTOCOL://$IP_LOCAL:$PORT"
echo "Presiona Ctrl+C para detener el servidor"

# Mantener el script en ejecución
wait
