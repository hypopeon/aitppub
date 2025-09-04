# --- THE AX211 MODERN STANDBY DESTROYER ---
Write-Host "PÅBÖRJAR SYSTEMMODIFIERING: MODERN STANDBY-PROTOKOLLEN AVSLUTAS." -ForegroundColor Red

Write-Host "Avaktiverar CsEnabled-flaggan..." -ForegroundColor Cyan
try {
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power"
    Set-ItemProperty -Path $RegPath -Name "CsEnabled" -Value 0 -Force
    Write-Host "CsEnabled har avaktiverats." -ForegroundColor Green
} catch {
    Write-Host "FEL: Avaktivering av CsEnabled misslyckades: $_" -ForegroundColor Red
}

Write-Host "Justerar PlatformAoAcOverride..." -ForegroundColor Cyan
try {
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power"
    Set-ItemProperty -Path $RegPath -Name "PlatformAoAcOverride" -Value 0 -Force
    Write-Host "PlatformAoAcOverride har ställts in på 0." -ForegroundColor Green
} catch {
    Write-Host "FEL: Inställning av PlatformAoAcOverride misslyckades: $_" -ForegroundColor Red
}

Write-Host "Inaktiverar Snabbstart (HiberbootEnabled)..." -ForegroundColor Cyan
try {
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
    Set-ItemProperty -Path $RegPath -Name "HiberbootEnabled" -Value 0 -Force
    Write-Host "Snabbstart har inaktiverats." -ForegroundColor Green
} catch {
    Write-Host "FEL: Inaktivering av Snabbstart misslyckades: $_" -ForegroundColor Red
}

Write-Host "Korrigerar beroenden för WcmSvc..." -ForegroundColor Cyan
try {
    $WcmSvcKey = "HKLM:\SYSTEM\CurrentControlSet\Services\WcmSvc"
    $DependValue = @("RpcSs","NSI")  # Behåller endast nödvändiga beroenden
    Set-ItemProperty -Path $WcmSvcKey -Name "DependOnService" -Value $DependValue -Force
    Write-Host "Beroenden för WcmSvc har korrigerats." -ForegroundColor Green
} catch {
    Write-Host "FEL: Korrigering av WcmSvc-beroenden misslyckades: $_" -ForegroundColor Red
}

Write-Host "Konfigurerar starttyp för WinHttpAutoProxySvc..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinHttpAutoProxySvc" -Name "Start" -Value 3 -Force
    Write-Host "WinHttpAutoProxySvc starttyp satt till Manuell." -ForegroundColor Green
} catch {
    Write-Host "FEL: Konfigurering av WinHttpAutoProxySvc misslyckades: $_" -ForegroundColor Red
}

Write-Host "Tvingar WcmSvc-beroendekonfiguration via SC.exe..." -ForegroundColor Cyan
try {
    Start-Process -FilePath "sc.exe" -ArgumentList "config wcmsvc depend= RpcSs/NSI" -WindowStyle Hidden -Wait
    Write-Host "SC-kommando för WcmSvc har exekverats." -ForegroundColor Green
} catch {
    Write-Host "FEL: Exekvering av SC-kommando misslyckades: $_" -ForegroundColor Red
}

Write-Host "Inaktiverar selektiv avstängning för USB-enheter..." -ForegroundColor Cyan
try {
    $usbDevices = Get-WmiObject -Namespace root\cimv2 -Class Win32_USBHub
    foreach ($device in $usbDevices) {
        $devicePath = $device.PNPDeviceID
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$devicePath\Device Parameters"
        Set-ItemProperty -Path $regPath -Name "DeviceSelectiveSuspended" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "SelectiveSuspendEnabled" -Value 0 -ErrorAction SilentlyContinue
    }
    Write-Host "Selektiv avstängning för USB har inaktiverats." -ForegroundColor Green
} catch {
    Write-Host "FEL: Inaktivering av USB selektiv avstängning misslyckades: $_" -ForegroundColor Red
}

Write-Host "Inaktiverar strömsparfunktion för nätverksadaptrar..." -ForegroundColor Cyan
try {
    $adapters = Get-NetAdapter | Get-NetAdapterPowerManagement
    foreach ($adapter in $adapters)
    {
        $adapter.AllowComputerToTurnOffDevice = 'Disabled'
        $adapter | Set-NetAdapterPowerManagement
    }
    Write-Host "Strömsparfunktion för nätverksadaptrar har inaktiverats." -ForegroundColor Green
} catch {
    Write-Host "FEL: Konfigurering av nätverksadaptrar misslyckades: $_" -ForegroundColor Red
}

Write-Host "Applicerar slutgiltiga ströminställningar..." -ForegroundColor Cyan
powercfg /change monitor-timeout-ac 5
powercfg /change standby-timeout-ac 180
powercfg /setactive SCHEME_CURRENT
Write-Host "Strömplanen har konfigurerats." -ForegroundColor Green


Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
Write-Host "OPERATION SLUTFÖRD. Systemet är nu optimerat." -ForegroundColor Yellow
Write-Host "Alla fientliga strömsparfunktioner har neutraliserats." -ForegroundColor Yellow
Write-Host "------------------------------------------------------------" -ForegroundColor Yellow

