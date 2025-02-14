Dark Wolf Apps - WiFi Cracking Tool
===================================

¡Bienvenido/a a Dark Wolf Apps - WiFi Cracking Tool!

Este proyecto contiene un script orientado a auditorías de redes WiFi y pruebas de penetración, facilitando:
- Activar/Desactivar modo monitor
- Escanear redes con airodump-ng
- Capturar tráfico para buscar handshakes
- Realizar ataques de desautenticación (aireplay-ng)
- Crackeo de contraseñas con CPU (aircrack-ng) o GPU (hashcat)
- Ataques WPS (reaver)
- Ataques de phishing con WiFiPhisher

─────────────────────────────────────────────────────────────────────────────
REQUISITOS Y DEPENDENCIAS
─────────────────────────────────────────────────────────────────────────────

- Sistema operativo basado en Linux. 
  (En Windows, puedes usar WSL o una máquina virtual con Linux.)
- aircrack-ng (incluye airodump-ng, aireplay-ng, etc.)
- iw, iproute2 (manejo de redes e interfaces)
- hashcat (para crackeo por GPU)
- reaver (ataques WPS)
- wifiphisher (ataques de phishing)
- hcxtools (especialmente hcxpcapngtool)

Para distribuciones Debian/Ubuntu (Linux), podrías instalar:
------------------------------------------------------------
sudo apt-get update && sudo apt-get install aircrack-ng iw iproute2 gnome-terminal hashcat reaver wifiphisher hcxtools
------------------------------------------------------------

─────────────────────────────────────────────────────────────────────────────
CÓMO USAR ESTE SCRIPT
─────────────────────────────────────────────────────────────────────────────

1. Descarga y descomprime el repositorio.
2. Da permisos de ejecución al script principal:
   chmod +x wifi_cracking_tool.sh
3. Ejecuta con privilegios de superusuario:
   sudo ./wifi_cracking_tool.sh
4. Selecciona la opción deseada en el menú:
   1. Mostrar Interfaces
   2. Activar Interfaz en modo monitor
   3. Desactivar Interfaz en modo monitor
   4. Escanear redes WiFi
   5. Capturar tráfico
   6. Enviar paquetes de desautenticación
   7. Crackear con WifiPhisher
   8. Crackear con CPU (aircrack-ng)
   9. Crackear con GPU (hashcat)
   10. Crackear con WPS (reaver)
   11. Limpiar la carpeta de capturas
   12. Salir

Flujo básico de auditoría WiFi:
-------------------------------
- Muestra o selecciona la interfaz y actívala en modo monitor.
- Escanea redes para identificar la que deseas auditar.
- Inicia la captura de tráfico en la red elegida.
- (Opcional) Lanza paquetes de desautenticación para forzar la generación de handshakes.
- Crackea la contraseña, ya sea usando CPU, GPU o mediante exploits WPS o ingeniería social.
- Por último, limpia la carpeta de capturas y desactiva la interfaz en modo monitor si lo deseas.

─────────────────────────────────────────────────────────────────────────────
CONSIDERACIONES
─────────────────────────────────────────────────────────────────────────────

- Ejecútalo únicamente en redes bajo tu control o con autorización explícita.  
- Verifica la compatibilidad de tu hardware (tarjetas inalámbricas que soporten modo monitor).  
- En Windows, puedes instalar las herramientas en el Subsistema de Windows para Linux (WSL) o usar una máquina virtual.  
- Esta herramienta está pensada para aprendizaje y pruebas de penetración con permiso.

─────────────────────────────────────────────────────────────────────────────
¡Disfruta aprendiendo y explorando con responsabilidad!
─────────────────────────────────────────────────────────────────────────────