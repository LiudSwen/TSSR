# Script d'installation de GLPI Agent par GPO

# Variables
$GlpiServer = "http://172.16.13.1"
$InstallerPath = "\\DOM-FS-01\departements\dsi\scripts\GLPI-Agent-1.15-x64.msi"
$LogPath = "C:\Windows\Temp\glpi-agent-install.log"
$MsiLogPath = "C:\Windows\Temp\glpi-agent-msi-install.log"

# Fonction de log
function Write-Log {
    param($Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -FilePath $LogPath -Append -Encoding UTF8
}

Write-Log "=== Début installation GLPI Agent ==="

# Vérifier si déjà installé (via registre)
$Installed = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | 
             Where-Object { $_.DisplayName -like "*GLPI*Agent*" }

if ($Installed) {
    Write-Log "Agent GLPI déjà installé (version: $($Installed.DisplayVersion))"
    exit 0
}

# Vérifier l'accès au fichier MSI
if (-not (Test-Path $InstallerPath)) {
    Write-Log "ERREUR: Fichier MSI introuvable: $InstallerPath"
    exit 1
}

# Installation
Write-Log "Installation de GLPI Agent en cours..."

$MsiArguments = @(
    "/i"
    "`"$InstallerPath`""
    "/quiet"
    "/norestart"
    "SERVER=$GlpiServer"
    "ADD_FIREWALL_EXCEPTION=1"
    "RUNNOW=1"
    "TAG=GPO-Deploy"
    "/L*v"
    "`"$MsiLogPath`""
)

try {
    $Process = Start-Process -FilePath "msiexec.exe" -ArgumentList $MsiArguments -Wait -PassThru -NoNewWindow
    
    if ($Process.ExitCode -eq 0) {
        Write-Log "Installation réussie"
    } elseif ($Process.ExitCode -eq 3010) {
        Write-Log "Installation réussie (redémarrage requis)"
    } else {
        Write-Log "ERREUR: Code de sortie MSI: $($Process.ExitCode)"
    }
    
    exit $Process.ExitCode
    
} catch {
    Write-Log "ERREUR Exception: $($_.Exception.Message)"
    exit 1
}

