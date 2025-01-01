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