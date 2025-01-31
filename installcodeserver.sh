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
