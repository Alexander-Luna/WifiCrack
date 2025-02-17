# Herramientas de Auditoría de Seguridad WiFi

Este repositorio contiene información sobre herramientas de auditoría de seguridad WiFi utilizadas para pruebas de penetración en redes inalámbricas. **Úsalo solo en entornos legales y con autorización explícita.**

## Herramientas Incluidas

### 1. Aircrack-ng
- Conjunto de herramientas para auditoría de redes WiFi.
- Permite capturar paquetes y descifrar claves WEP y WPA/WPA2.
- Sitio oficial: [https://www.aircrack-ng.org](https://www.aircrack-ng.org)

### 2. Hashcat
- Herramienta avanzada de descifrado de contraseñas utilizando la potencia de la GPU.
- Compatible con múltiples algoritmos de hash, incluyendo WPA/WPA2.
- Sitio oficial: [https://hashcat.net/hashcat/](https://hashcat.net/hashcat/)

### 3. WiFiPhisher
- Herramienta para ataques de ingeniería social en redes WiFi.
- Crea puntos de acceso falsos para capturar credenciales.
- Sitio oficial: [https://github.com/wifiphisher/wifiphisher](https://github.com/wifiphisher/wifiphisher)

## Instalación
Cada herramienta tiene requisitos específicos. Para instalar en Kali Linux:
```bash
sudo apt update && sudo apt install aircrack-ng hashcat
```
Para WiFiPhisher:
```bash
git clone https://github.com/wifiphisher/wifiphisher.git
cd wifiphisher
sudo python3 setup.py install
```

## ⚖️ Consideraciones Legales
Este software debe usarse únicamente para:
✔️ Pruebas de seguridad autorizadas  
✔️ Investigación académica  
✔️ Desarrollo de sistemas de validación 
✔️ Pruebas de penetración en redes WiFi
❌ Estas herramientas deben utilizarse exclusivamente para auditorías de seguridad en redes donde tengas permiso explícito. **El uso indebido puede ser ilegal y conllevar sanciones.**
❌ **No para ataques maliciosos**
❌ **El mal uso de esta herramienta es responsabilidad exclusiva del usuario.**


## Contribuciones
Si deseas mejorar este repositorio, abre un issue o haz un pull request.

## 📜 Licencia
Este proyecto está licenciado bajo la **Licencia MIT**, lo que significa que puedes usarlo y modificarlo libremente siempre que se otorgue el crédito correspondiente al autor.

