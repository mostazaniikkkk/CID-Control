#------------------------------------------------
#Logica del servicio
#------------------------------------------------

Import-Module -Path .\_CheckProcess.ps1
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