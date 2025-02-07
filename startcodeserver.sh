#!/data/data/com.termux/files/usr/bin/bash

# Directorio de configuración de code-server
CONFIG_DIR="$HOME/.config/code-server"
KEY_FILE="$CONFIG_DIR/selfsigned.key"
CERT_FILE="$CONFIG_DIR/selfsigned.crt"

# Preguntar al usuario si quiere cambiar el puerto
echo "Puerto predeterminado: 8080. ¿Desea cambiarlo? (s/n)"
read -r change_port
if [[ "$change_port" == "s" ]]; then
    echo "Ingrese el nuevo puerto:"
    read -r PORT
else
    PORT=8080
fi

# Verificar si code-server está instalado
if ! command -v code-server &> /dev/null; then
    echo "code-server no está instalado. Por favor, instálalo primero."
    exit 1
fi

# Buscar un puerto disponible
tmp_port=$PORT
while lsof -i:$tmp_port &> /dev/null; do
    tmp_port=$((tmp_port + 1))
done
PORT=$tmp_port

# Obtener la IP local del dispositivo en Termux (evita loopback 127.0.0.1)
IP_LOCAL=$(ifconfig wlan0 | grep 'inet ' | awk '{print $2}')

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

# Preguntar al usuario si quiere habilitar dnsmasq
echo "code-server se está ejecutando en $PROTOCOL://$IP_LOCAL:$PORT"
echo "¿Desea habilitar un DNS local con dnsmasq? (s/n)"
read -r enable_dns
if [[ "$enable_dns" == "s" ]]; then
    DNS_NAME="codeserver.local"
    echo "address=/$DNS_NAME/$IP_LOCAL" | tee $HOME/.termux_dns.conf

    # Verificar si dnsmasq está instalado
    if ! command -v dnsmasq &> /dev/null; then
        echo "Instalando dnsmasq..."
        pkg install dnsmasq -y
    fi

    # Iniciar dnsmasq con la configuración local
    dnsmasq --no-resolv --no-poll --address=/$DNS_NAME/$IP_LOCAL &
    echo "code-server se está ejecutando en $PROTOCOL://$DNS_NAME:$PORT"
else
    echo "code-server se está ejecutando en $PROTOCOL://$IP_LOCAL:$PORT"
fi
