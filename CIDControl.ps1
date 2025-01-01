#------------------------------------------------
#Logica del servicio
#------------------------------------------------

class CheckIDTray {
    # Inicializa dos instancias de _CheckProcess para los servicios principales y auxiliares
    [_CheckProcess]$tray = [_CheckProcess]::new("C:/Program Files/SOLEM/CheckIDTray", "CheckID Tray")
    [_CheckProcess]$aux = [_CheckProcess]::new("C:/Program Files (x86)/SOLEM/CheckIDTray Aux", "CheckID Tray AUX")

    # Archivos de configuración
    [string]$devices = "Devices.config"
    [string]$config = "CheckIdTray.dll.config"

    # Método para reiniciar ambos servicios
    [void] Restart() {
        Write-Host "Reiniciando servicios de CheckIDTray..."
        $this.tray.Restart()
        $this.aux.Restart()
        $this.ShowLogAndWait("Servicios de CheckIDTray reiniciados.")
    }

    # Método para reiniciar un servicio específico
    [void] RestartProcess([string]$serviceName) {
        Write-Host "Iniciando reinicio del servicio '$serviceName'..."
        try {
            Write-Verbose "Intentando detener el servicio '$serviceName' con Stop-Service..."
            Stop-Service -Name $serviceName -Force -ErrorAction Stop
            $this.ShowLogAndWait("Servicio '$serviceName' detenido correctamente.")
        }
        catch {
            Write-Warning "No se pudo detener el servicio '$serviceName' con Stop-Service. Se intentará forzar la detención."
            $this.ShowLogAndWait("No se pudo detener el servicio '$serviceName' con Stop-Service.")
            try {
                Write-Verbose "Obteniendo información del servicio '$serviceName' con Get-WmiObject..."
                $service = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"
                if ($service) {
                    $processId = $service.ProcessId
                    Write-Verbose "PID del servicio '$serviceName': $processId"
                    if ($processId -ne 0) {
                        Write-Host "Forzando la detención del proceso con PID '$processId'..."
                        taskkill /PID $processId /F
                        $this.ShowLogAndWait("Proceso con PID '$processId' detenido correctamente.")
                    } else {
                        $this.ShowLogAndWait("El servicio '$serviceName' no está en ejecución o no se pudo obtener su PID.")
                    }
                } else {
                    $this.ShowLogAndWait("No se encontró el servicio '$serviceName'.")
                }
            }
            catch {
                Write-Error "Error al forzar la detención del servicio '$serviceName': $($_.Exception.Message)"
                $this.ShowLogAndWait("Error al forzar la detención del servicio '$serviceName'.")
            }
        }

        try {
            Write-Verbose "Iniciando el servicio '$serviceName' con Start-Service..."
            Start-Service -Name $serviceName -ErrorAction Stop
            $this.ShowLogAndWait("Servicio '$serviceName' iniciado correctamente.")
        }
        catch {
            $this.ShowLogAndWait("Error al iniciar el servicio '$serviceName'.")
        }
        Write-Host "Finalizado reinicio del servicio '$serviceName'."
    }

    #Metodo para reiniciar servicios EVS
    [void] RestartAllEVS(){
        $this.RestartProcess("EVS_FINGERPRINT")
        $this.RestartProcess("EVS_PHOTO")
        $this.RestartProcess("EVS_SUPERVISOR")
    }

    # Método para configurar un dispositivo en el archivo Devices.config
    [void] SetConfigDevice([string]$device, [string]$value){
        Write-Host "Configurando '$device' con el valor '$value' en Devices.config..."
    
        # Cargar el archivo XML
        try {
            $xml = [xml](Get-Content -Path $this.devicesConfigPath -Raw)
            Write-Verbose "Archivo Devices.config cargado correctamente."
        }
        catch {
            Write-Error "Error al cargar el archivo Devices.config: $($_.Exception.Message)"
            $this.ShowLogAndWait("Log: Error al cargar el archivo Devices.config") # Llamada a Show-LogAndWait
            return
        }
    
        # Modificar el valor del dispositivo
        $node = $xml.SelectSingleNode("//add[@key='$device']")
        if ($node) {
            $node.SetAttribute("value", $value)
            Write-Verbose "Atributo 'value' del nodo con key '$device' actualizado a '$value'."
    
            # Guardar los cambios
            try {
                $xml.Save($this.devicesConfigPath)
                Write-Host "Dispositivo '$device' configurado correctamente en Devices.config."
                $this.ShowLogAndWait("Log: Dispositivo '$device' configurado correctamente.") # Llamada a Show-LogAndWait
            }
            catch {
                Write-Error "Error al guardar los cambios en Devices.config: $($_.Exception.Message)"
                $this.ShowLogAndWait("Log: Error al guardar los cambios en Devices.config") # Llamada a Show-LogAndWait
                return
            }
        } else {
            Write-Warning "No se encontró el dispositivo '$device' en Devices.config."
            $this.ShowLogAndWait("Log: No se encontró el dispositivo '$device' en Devices.config.") # Llamada a Show-LogAndWait
        }
    }

    # Método para renombrar una impresora
    [void] RenamePrinter([string]$printer) {
        Write-Host "Renombrando la impresora '$printer'..."
        try {
            Rename-Printer -Name $printer -NewName "HP Laser 408 PCL6"
            $this.ShowLogAndWait("Impresora renombrada a 'HP Laser 408 PCL6'.")
        }
        catch {
            Write-Error "Error al forzar la detención del dispositivo '$printer', revisa el nombre de los dispositivos y vuelve a intentarlo."
            Write-Host "Como recordatorio:"
            Write-Host "- El nombre ingresado debe estar registrado dentro de la lista de impresoras que se encuentra dentro del menu de ajustes."
            Write-Host "- El nombre nuevo no debe coincidir con el de otros dispositivos conectados al equipo."
            Write-Host ""
            $this.ShowLogAndWait("No se pudo renombrar dispositivo.")
        }
    }

    # Método para mostrar un mensaje de log y esperar a que el usuario presione una tecla
    [void] ShowLogAndWait([string]$logMessage) {
        Write-Host "$logMessage Presione cualquier tecla para continuar..." -ForegroundColor Yellow
    
        # Esperar a que el usuario presione cualquier tecla
        $null = $this.PSHost.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") # Usar $this.PSHost en lugar de $Host
    
        # Limpiar la pantalla
        Clear-Host
    }
}

class _CheckProcess {
    [string]$route
    [string]$exec

    # Constructor para inicializar la ruta y el ejecutable del proceso
    _CheckProcess([string]$route, [string]$exec){
        $this.route = $route
        $this.exec = $exec
    }

    # Método para reiniciar el proceso
    [void] Restart() {
        Write-Host "Reiniciando proceso '$($this.exec)'..."
        Write-Verbose "Deteniendo proceso '$($this.exec)' con Stop-Process..."
        Stop-Process -Name $this.exec -Force -ErrorAction SilentlyContinue

        $fullPath = Join-Path -Path $this.route -ChildPath "$($this.exec).exe"
        Write-Verbose "Iniciando proceso '$($this.exec)' desde '$fullPath'..."
        Start-Process -FilePath $fullPath -WindowStyle Normal
        Write-Host "Proceso '$($this.exec)' reiniciado."

        $this.RestartBrowser("https://app.nuevosidiv.chile")
    }

    # Abre el navegador
    [void] RestartBrowser([string]$url) {
        # Lista de navegadores comunes y sus rutas de ejecutable
        $browsers = @{
            "chrome" = "C:\Program Files\Google\Chrome\Application\chrome.exe"
            "msedge" = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
        }

        # Detectar navegadores abiertos
        $openBrowser = $null
        foreach ($browser in $browsers.Keys) {
            if (Get-Process -Name $browser -ErrorAction SilentlyContinue) {
                $openBrowser = $browser
                break
            }
        }

        if ($openBrowser) {
            Write-Host "Navegador detectado: $openBrowser"

            # Cerrar el navegador detectado
            Stop-Process -Name $openBrowser -Force -ErrorAction SilentlyContinue

            # Esperar un momento para asegurarse de que el navegador se haya cerrado
            Start-Sleep -Seconds 2

            # Abrir el navegador con la URL específica
            Write-Host "Abriendo $openBrowser con la URL $url..."
            Start-Process -FilePath $browsers[$openBrowser] -ArgumentList $url
        } else {
            Write-Host "No se detectó ningún navegador abierto."
        }
    }
}

#------------------------------------------------
#Gestion de la TUI
#------------------------------------------------

# Crear una instancia de CheckIDTray
$checkid = [CheckIDTray]::new()

# Función para mostrar el menú principal
function Show-Menu {
    Clear-Host
    Write-Host "Menú Principal - CheckIDTray" -ForegroundColor Cyan
    Write-Host "1: Reiniciar servicios de CheckIDTray" -ForegroundColor Yellow
    Write-Host "2: Reiniciar un servicio específico de EVS" -ForegroundColor Yellow
    Write-Host "3: Configurar impresora o escaner" -ForegroundColor Yellow
    Write-Host "4: Renombrar impresora" -ForegroundColor Yellow
    Write-Host "5: Reiniciar todos los servicios de EVS" -ForegroundColor Yellow
    Write-Host "6: Salir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Seleccione una opción: " -NoNewline
}

# Función para mostrar el submenú de reinicio de servicios EVS
function Show-EVS-Submenu {
    Clear-Host
    Write-Host "Menú Reinicio de Servicios EVS" -ForegroundColor Cyan
    Write-Host "1: Reiniciar EVS_FINGERPRINT" -ForegroundColor Yellow
    Write-Host "2: Reiniciar EVS_PHOTO" -ForegroundColor Yellow
    Write-Host "3: Reiniciar EVS_SUPERVISOR" -ForegroundColor Yellow
    Write-Host "4: Volver al menú principal" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Seleccione una opción (ESC para volver): " -NoNewline
}

# Función para mostrar el submenú de configuración de dispositivos
function Show-Devices-Submenu {
    Clear-Host
    Write-Host "Menú Configuración de Dispositivos" -ForegroundColor Cyan
    Write-Host "1: Configurar impresora" -ForegroundColor Yellow
    Write-Host "2: Configurar escáner" -ForegroundColor Yellow
    Write-Host "3: Volver al menú principal" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Seleccione una opción (ESC para volver): " -NoNewline
}

# Ciclo principal del menú
while ($true) {
    Show-Menu

    $opcion = Read-Host # Se usa Read-Host en el menú principal

    switch ($opcion) {
        "1" {
            $checkid.Restart()
        }
        "2" {
            # Submenú para reiniciar un servicio específico
            while ($true) {
                Show-EVS-Submenu
                $subOpcion = ''
                while ($subOpcion -eq '') {
                    $key = [Console]::ReadKey($true)
                    if ($key.Key -eq "Escape") {
                        $subOpcion = "4" # Volver al menú principal
                    } elseif ($key.KeyChar) {
                        $subOpcion = $key.KeyChar
                    }
                }

                switch ($subOpcion) {
                    "1" {
                        $checkid.RestartProcess("EVS_FINGERPRINT")
                        break
                    }
                    "2" {
                        $checkid.RestartProcess("EVS_PHOTO")
                        break
                    }
                    "3" {
                        $checkid.RestartProcess("EVS_SUPERVISOR")
                        break
                    }
                    "4" {
                        break # Salir del submenú
                    }
                    default {
                        Write-Host "Opción no válida. Intente de nuevo."
                        Read-Host "Presione ENTER para continuar"
                    }
                }

                if ($subOpcion -eq "4") {
                    break # Salir del bucle del submenú
                }
            }
        }
        "3" {
            # Submenú para configurar dispositivos
            while ($true) {
                Show-Devices-Submenu
                $subOpcion = ''
                while ($subOpcion -eq '') {
                    $key = [Console]::ReadKey($true)
                    if ($key.Key -eq "Escape") {
                        $subOpcion = "3" # Volver al menú principal
                    } elseif ($key.KeyChar) {
                        $subOpcion = $key.KeyChar
                    }
                }

                switch ($subOpcion) {
                    "1" {
                        $printer = Read-Host "Ingrese el nombre de la impresora"
                        $checkid.SetConfigDevice("PrinterDev", $printer)
                        break
                    }
                    "2" {
                        $scanner = Read-Host "Ingrese el nombre del escáner"
                        $checkid.SetConfigDevice("ScannerDocDev", $scanner)
                        break
                    }
                    "3" {
                        break # Salir del submenú
                    }
                    default {
                        Write-Host "Opción no válida. Intente de nuevo."
                        Read-Host "Presione ENTER para continuar"
                    }
                }

                if ($subOpcion -eq "3") {
                    break # Salir del bucle del submenú
                }
            }
        }
        "4" {
            $printer = Read-Host "Ingrese el nombre de la impresora a renombrar"
            $checkid.RenamePrinter($printer)
        }
        "5" {
            $checkid.RestartAllEVS()
        }
        "6" {
            Write-Host "Saliendo del programa..."
            return
        }
        default {
            Write-Host "Opción no válida. Intente de nuevo."
            Read-Host "Presione ENTER para continuar"
        }
    }
}