**Solution : Installation manuelle depuis GitHub**

Voici les étapes précises à suivre :

**1. Télécharger OpenSSH**
```powershell
# Télécharger la dernière version (depuis PowerShell)
Invoke-WebRequest -Uri "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.5.0.0p1-Beta/OpenSSH-Win64.zip" -OutFile "$env:TEMP\OpenSSH-Win64.zip"
```

**2. Extraire et installer**
```powershell
# Extraire
Expand-Archive -Path "$env:TEMP\OpenSSH-Win64.zip" -DestinationPath "C:\Program Files" -Force

# Aller dans le dossier
cd "C:\Program Files\OpenSSH-Win64"

# Installer le service
.\install-sshd.ps1

# Configurer le démarrage automatique
Set-Service -Name sshd -StartupType 'Automatic'
Set-Service -Name ssh-agent -StartupType 'Automatic'

# Démarrer le service
Start-Service sshd
Start-Service ssh-agent

# Configurer le pare-feu
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

**3. Vérifier que ça fonctionne**
```powershell
Get-Service sshd
```

