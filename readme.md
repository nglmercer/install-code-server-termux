## Prerequisites
### termux-app official repository https://github.com/termux/termux-app
- update and upgrade pkg ```pkg update && pkg upgrade -y```
- install git `pkg install git`

## how install
- clone installcodeserver.sh `git clone https://github.com/nglmercer/install-code-server-termux/blob/main/installcodeserver.sh`
- chmod +x ./installcodeserver.sh
- ./installcodeserver.sh

## how start server
- clone startcodeserver.sh `git clone https://github.com/nglmercer/install-code-server-termux/blob/main/startcodeserver.sh`
- chmod +x ./startcodeserver.sh
- ./startcodeserver.sh


## optional install manually
- install nano `pkg install nano`
- create script example `nano startcodeserver.sh`
- paste code and save with ` crtl + s  ` and exit ` crtl + k  `
- add permision `chmod +x startcodeserver.sh`
- execute `./startcodeserver.sh`
startcodeserver.sh
```
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

# Buscar un puerto disponible
while lsof -i:$PORT &> /dev/null; do
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


```
----
./installcodeserver.sh
```
#!/bin/bash

# Función para instalar code-server
instalar_code_server() {
    echo "Actualizando paquetes..."
    pkg update && pkg upgrade -y

    echo "Instalando tur-repo..."
    pkg install tur-repo -y

    echo "Instalando code-server..."
    pkg install code-server -y

    echo "Instalación completada. Puedes iniciar code-server ejecutando 'code-server'."
}

# Verificar si code-server ya está instalado
if command -v code-server &> /dev/null; then
    echo "code-server ya está instalado."
    read -p "¿Deseas reinstalarlo? (s/n): " respuesta
    if [[ "$respuesta" == "s" || "$respuesta" == "S" ]]; then
        instalar_code_server
    else
        echo "Reinstalación cancelada."
    fi
else
    echo "code-server no está instalado. Procediendo con la instalación..."
    instalar_code_server
fi
```
