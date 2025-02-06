---

## **Instructions (English)**

### Prerequisites
- **Termux App**: Official repository [Termux App](https://github.com/termux/termux-app).
- Update and upgrade packages:
  ```bash
  pkg update && pkg upgrade -y
  ```
- Install Git:
  ```bash
  pkg install git -y
  ```

---

### Installation Options

#### **Option 1: Using `curl` or `wget`**
1. Download and execute the installation script directly:
   ```bash
   curl -sL https://raw.githubusercontent.com/nglmercer/install-code-server-termux/main/installcodeserver.sh | bash

   wget -qO- https://raw.githubusercontent.com/nglmercer/install-code-server-termux/main/installcodeserver.sh | bash
   ```

2. Start the server:
   ```bash
   curl -sL https://raw.githubusercontent.com/nglmercer/install-code-server-termux/main/startcodeserver.sh | bash

   wget -qO- https://raw.githubusercontent.com/nglmercer/install-code-server-termux/main/startcodeserver.sh | bash
   ```

---

#### **Option 2: Cloning the Repository**
1. Clone the repository:
   ```bash
   git clone https://github.com/nglmercer/install-code-server-termux.git
   cd install-code-server-termux
   ```

2. Make the scripts executable:
   ```bash
   chmod +x installcodeserver.sh startcodeserver.sh
   ```

3. Run the installation script:
   ```bash
   ./installcodeserver.sh
   ```

4. Start the server:
   ```bash
   ./startcodeserver.sh
   ```

---

### Optional: Manual Installation
1. Install a text editor (e.g., Nano):
   ```bash
   pkg install nano -y
   ```

2. Create a script file:
   ```bash
   nano startcodeserver.sh
   ```

3. Paste the following code into the file:
   ```bash
   #!/bin/bash
   code-server
   ```

4. Save and exit:
   - Press `CTRL + S` to save.
   - Press `CTRL + X` to exit.

5. Make the script executable:
   ```bash
   chmod +x startcodeserver.sh
   ```

6. Run the script:
   ```bash
   ./startcodeserver.sh
   ```

---

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
