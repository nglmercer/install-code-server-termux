#!/data/data/com.termux/files/usr/bin/bash

# Directorio de configuración de code-server
CONFIG_DIR="$HOME/.config/code-server"
KEY_FILE="$CONFIG_DIR/selfsigned.key"
CERT_FILE="$CONFIG_DIR/selfsigned.crt"

# Puerto inicial
PORT=8080

# Verificar si code-server está instalado
if ! command -v code-server &> /dev/null; then
    echo "code-server no está instalado. Por favor, instálalo primero."
    exit 1
fi

# Función para verificar qué proceso está usando un puerto
check_port_usage() {
    local port=$1
    local process_info=$(lsof -i:$port 2>/dev/null)
    if [ ! -z "$process_info" ]; then
        local process_name=$(echo "$process_info" | tail -n 1 | awk '{print $1}')
        local pid=$(echo "$process_info" | tail -n 1 | awk '{print $2}')
        echo "El puerto $port está siendo usado por el proceso $process_name (PID: $pid)"
        return 1
    fi
    return 0
}

# Buscar un puerto disponible
while ! check_port_usage $PORT; do
    echo "Intentando con el puerto $((PORT + 1))..."
    PORT=$((PORT + 1))
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

# Mostrar información al usuario
echo "code-server se está ejecutando en $PROTOCOL://$IP_LOCAL:$PORT"
