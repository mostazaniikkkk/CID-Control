#------------------------------------------------
#Logica del servicio
#------------------------------------------------

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