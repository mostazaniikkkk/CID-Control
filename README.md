# 🚀 CID Control 🚀

Bienvenidos al repositorio de **CID Control**, Un programa simple y sencillo para gestionar CheckIDTray.

<a href="https://ko-fi.com/mostazaniikkkk" target="_blank"><img src="https://www.ko-fi.com/img/githubbutton_sm.svg"></a>

## Descripción

✨ ¡**CIDControl** es tu herramienta amigable con una **Interfaz de Usuario de Texto (TUI)** para administrar los servicios de CheckIDTray de forma eficiente! ✨

Olvídate de anotar, copiar y pegar comandos. Con su menú interactivo, CIDControl te permite reiniciar servicios, configurar dispositivos y renombrar impresoras de forma sencilla.  Es la solución ideal para mantener tus sistemas que usan CheckIDTray funcionando sin problemas. ⚙️💻

## Características

*   🤩 **Interfaz de Usuario de Texto (TUI)**: ¡Navega por menús interactivos sin necesidad de escribir comandos!
*   🔄 **Reinicio de Servicios**: Reinicia los servicios principal y auxiliar de CheckIDTray con un solo clic.
*   🎯 **Reinicio de Servicios EVS Específicos**: ¿Problemas con un servicio en particular? Reinícialo individualmente a través de un submenú.
*   🗂️ **Reinicio Completo de Servicios EVS**: Reinicia todos los servicios de EVS (EVS_FINGERPRINT, EVS_PHOTO, EVS_SUPERVISOR) de una sola vez.
*   🖨️ **Configuración de Impresoras y Escáneres**: Configura fácilmente el nombre de tu impresora o escáner a través de un submenú y del archivo `Devices.config`.
*   🏷️ **Renombrado de Impresoras**: Dale a tu impresora el nombre que se merece.
*   🔍 **Manejo de Errores y Logging Detallado**:  CIDControl te informa de cualquier problema (visible a través de la función `ShowLogAndWait`).

## Requisitos

*   ✅ PowerShell 5.1 o superior.
*   ✅ Servicios de CheckIDTray instalados y configurados.
*   ✅ Endpoint Central para ejecutar el script.

## Instalación

¡Descargar e instalar CIDControl es muy fácil!

1.  **📥 Descarga la última versión:** Dirígete a la sección [**Releases**](<URL de la sección Releases de tu repositorio en GitHub>) de este repositorio y descarga el archivo comprimido (.zip o .7z) de la última versión.
2.  **📂 Descomprime el archivo:** Extrae el contenido del archivo comprimido en una carpeta de tu elección (por ejemplo, `C:\CIDControl`).

## Uso

¡Es tan fácil como 1, 2, 3!

1.  🔥 Abre una consola de PowerShell con permisos de administrador.
2.  📂 Navega hasta el directorio donde descomprimiste CIDControl (por ejemplo, `cd C:\CIDControl`).
3.  🚀 Ejecuta:

    ```bash
    .\CIDControl.ps1
    ```

¡Listo! 🎉 Aparecerá un menú interactivo y podrás controlar tus servicios de CheckIDTray.

### Menú Principal

*   **1️⃣ Reiniciar servicios de CheckIDTray:** 🔄 Reinicia los servicios principal y auxiliar.
*   **2️⃣ Reiniciar un servicio específico de EVS:** 🎯 Accede a un submenú para reiniciar un servicio EVS específico.
*   **3️⃣ Configurar impresora o escáner:** 🖨️ 🗂️ Accede a un submenú para configurar el nombre de la impresora o el escáner en `Devices.config`.
*   **4️⃣ Renombrar impresora:** 🏷️ Renombra tu impresora.
*   **5️⃣ Reiniciar todos los servicios de EVS:** 🔄 Reinicia todos los servicios de EVS de una vez.
*   **6️⃣ Salir:** 👋 Cierra la aplicación.

### Submenú Reinicio de Servicios EVS

*   **1️⃣ Reiniciar EVS_FINGERPRINT:** 🎯 Reinicia el servicio EVS_FINGERPRINT.
*   **2️⃣ Reiniciar EVS_PHOTO:** 🎯 Reinicia el servicio EVS_PHOTO.
*   **3️⃣ Reiniciar EVS_SUPERVISOR:** 🎯 Reinicia el servicio EVS_SUPERVISOR.
*   **4️⃣ Volver al menú principal:** ↩️ Regresa al menú principal.
*   **ESC:** ↩️ Volver al menú principal.

### Submenú Configuración de Dispositivos

*   **1️⃣ Configurar impresora:** 🖨️ Configura el nombre de la impresora en `Devices.config`.
*   **2️⃣ Configurar escáner:** 🗂️ Configura el nombre del escáner en `Devices.config`.
*   **3️⃣ Volver al menú principal:** ↩️ Regresa al menú principal.
*   **ESC:** ↩️ Volver al menú principal.

**Nota:** En los submenús, puedes usar la tecla `ESC` para volver al menú principal.

## Contribuciones

💖 ¡Las contribuciones son bienvenidas! 💖 Si quieres mejorar CIDControl, por favor crea un *fork* del repositorio, realiza tus cambios y envía un *pull request*.

## Licencia

Este proyecto está bajo la licencia GPL-3.0 license.
