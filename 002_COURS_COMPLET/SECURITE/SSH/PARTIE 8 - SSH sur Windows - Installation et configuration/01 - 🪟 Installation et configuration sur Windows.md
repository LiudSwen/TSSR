

## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 2 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## 🎯 Introduction

Historiquement, Windows nécessitait des outils tiers comme PuTTY pour établir des connexions SSH. Depuis Windows 10 (version 1809) et Windows Server 2019, Microsoft a intégré **OpenSSH** nativement dans le système d'exploitation. Cette implémentation permet d'utiliser SSH directement depuis PowerShell ou l'invite de commandes, offrant ainsi une expérience similaire aux systèmes Unix/Linux.

> [!info] Pourquoi OpenSSH natif ?
> 
> - **Standardisation** : Utilise les mêmes commandes que Linux/macOS
> - **Intégration système** : Géré comme un service Windows natif
> - **Maintenance** : Mises à jour via Windows Update
> - **Compatibilité** : Support complet du protocole SSH moderne

---

## 🔧 OpenSSH natif sur Windows

### 📥 Activation d'OpenSSH Client

Le client OpenSSH permet de se connecter à des serveurs SSH distants depuis votre machine Windows.

#### **Méthode 1 : Via l'interface graphique (Paramètres)**

1. Ouvrir **Paramètres Windows** (`Win + I`)
2. Naviguer vers **Applications** → **Fonctionnalités facultatives**
3. Cliquer sur **Ajouter une fonctionnalité**
4. Rechercher **"Client OpenSSH"**
5. Cliquer sur **Installer**

#### **Méthode 2 : Via PowerShell (Administrateur)**

```powershell
# Vérifier si le client est déjà installé
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'

# Installer le client OpenSSH
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```

> [!tip] Méthode recommandée La méthode PowerShell est idéale pour les déploiements automatisés ou les scripts d'installation. Elle offre également un retour d'information précis sur l'état de l'installation.

#### **Résultat attendu**

```powershell
Path          :
Online        : True
RestartNeeded : False
```

> [!example] Exemple d'utilisation immédiate Une fois installé, vous pouvez immédiatement utiliser la commande `ssh` depuis n'importe quel terminal :
> 
> ```powershell
> ssh utilisateur@192.168.1.100
> ```

---

### 🖥️ Activation d'OpenSSH Server

Le serveur OpenSSH transforme votre machine Windows en serveur SSH, permettant des connexions SSH entrantes pour l'administration à distance.

#### **Méthode 1 : Via l'interface graphique**

1. Ouvrir **Paramètres Windows** (`Win + I`)
2. Naviguer vers **Applications** → **Fonctionnalités facultatives**
3. Cliquer sur **Ajouter une fonctionnalité**
4. Rechercher **"Serveur OpenSSH"**
5. Cliquer sur **Installer**

#### **Méthode 2 : Via PowerShell (Administrateur)**

```powershell
# Vérifier si le serveur est déjà installé
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

# Installer le serveur OpenSSH
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

#### **Configuration du service SSH**

Après l'installation, le service doit être configuré pour démarrer automatiquement :

```powershell
# Démarrer le service SSH
Start-Service sshd

# Configurer le démarrage automatique
Set-Service -Name sshd -StartupType 'Automatic'

# Vérifier le statut du service
Get-Service sshd
```

> [!example] Résultat attendu
> 
> ```
> Status   Name               DisplayName
> ------   ----               -----------
> Running  sshd               OpenSSH SSH Server
> ```

#### **Configuration du pare-feu**

Le pare-feu Windows doit autoriser les connexions SSH entrantes sur le port 22 :

```powershell
# Vérifier si la règle existe déjà
Get-NetFirewallRule -Name *OpenSSH-Server* | Select-Object Name, Enabled

# Créer la règle de pare-feu (si nécessaire)
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' `
    -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

> [!warning] Sécurité du pare-feu Par défaut, cette règle autorise les connexions SSH depuis n'importe quelle adresse IP. Pour restreindre l'accès à des réseaux spécifiques, ajoutez le paramètre `-RemoteAddress` :
> 
> ```powershell
> -RemoteAddress 192.168.1.0/24
> ```

#### **Emplacement des fichiers de configuration**

```powershell
# Fichier de configuration principal du serveur
C:\ProgramData\ssh\sshd_config

# Répertoire des clés d'hôte
C:\ProgramData\ssh\

# Logs du serveur SSH
C:\ProgramData\ssh\logs\
```

> [!tip] Édition de la configuration Pour modifier le fichier `sshd_config`, utilisez un éditeur avec privilèges administrateur :
> 
> ```powershell
> notepad C:\ProgramData\ssh\sshd_config
> ```
> 
> Après modification, redémarrez le service :
> 
> ```powershell
> Restart-Service sshd
> ```

---

### ✅ Vérification de l'installation

#### **Vérification du client OpenSSH**

```powershell
# Vérifier la version du client SSH
ssh -V

# Résultat attendu (exemple)
# OpenSSH_for_Windows_8.6p1, LibreSSL 3.4.3
```

```powershell
# Afficher l'aide et les options disponibles
ssh -?

# Tester une connexion locale (si le serveur est installé)
ssh localhost
```

#### **Vérification du serveur OpenSSH**

```powershell
# Vérifier le statut du service
Get-Service sshd

# Vérifier les ports en écoute
netstat -an | Select-String ":22"

# Résultat attendu
# TCP    0.0.0.0:22             0.0.0.0:0              LISTENING
# TCP    [::]:22                [::]:0                 LISTENING
```

```powershell
# Vérifier les logs du serveur
Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 20
```

> [!example] Test de connexion SSH locale Pour vérifier que le serveur fonctionne correctement :
> 
> ```powershell
> # Se connecter à soi-même
> ssh $env:USERNAME@localhost
> 
> # Ou avec l'IP locale
> ssh $env:USERNAME@127.0.0.1
> ```

#### **Commandes de diagnostic avancées**

```powershell
# Lister toutes les capacités OpenSSH
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# Vérifier l'intégrité de l'installation
Repair-WindowsImage -Online -CheckHealth

# Afficher les services SSH disponibles
Get-Service | Where-Object {$_.Name -like '*ssh*'}
```

---

### 🔄 Différences avec Linux

Bien qu'OpenSSH sur Windows soit basé sur le même code source que sur Linux, il existe des différences importantes dues à l'architecture système de Windows.

#### **Tableau comparatif des différences principales**

|Aspect|Linux|Windows|
|---|---|---|
|**Emplacement config client**|`~/.ssh/config`|`C:\Users\<user>\.ssh\config`|
|**Emplacement config serveur**|`/etc/ssh/sshd_config`|`C:\ProgramData\ssh\sshd_config`|
|**Clés d'hôte**|`/etc/ssh/ssh_host_*`|`C:\ProgramData\ssh\ssh_host_*`|
|**Shell par défaut**|`/bin/bash` ou `/bin/sh`|PowerShell ou `cmd.exe`|
|**Gestion du service**|`systemctl` / `service`|`Start-Service` / `Stop-Service`|
|**Utilisateur du service**|`root` (puis bascule)|`NT AUTHORITY\SYSTEM`|
|**Permissions fichiers**|POSIX (chmod)|ACL Windows (icacls)|
|**Agent SSH**|`ssh-agent` (socket Unix)|Service Windows `ssh-agent`|

#### **Gestion des permissions**

Sur Linux, les permissions SSH sont gérées avec `chmod` :

```bash
# Linux
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
```

Sur Windows, on utilise les ACL (Access Control Lists) avec `icacls` :

```powershell
# Windows - Protéger le répertoire .ssh
icacls "$env:USERPROFILE\.ssh" /inheritance:r
icacls "$env:USERPROFILE\.ssh" /grant:r "$($env:USERNAME):(OI)(CI)F"

# Windows - Protéger une clé privée
icacls "$env:USERPROFILE\.ssh\id_rsa" /inheritance:r
icacls "$env:USERPROFILE\.ssh\id_rsa" /grant:r "$($env:USERNAME):F"
```

> [!warning] Permissions strictes requises OpenSSH sur Windows vérifie les permissions des fichiers de clés. Si les permissions sont trop ouvertes, SSH refusera d'utiliser la clé avec l'erreur :
> 
> ```
> WARNING: UNPROTECTED PRIVATE KEY FILE!
> Permissions for 'id_rsa' are too open.
> ```

#### **Shell par défaut**

```powershell
# Vérifier le shell par défaut configuré
Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell

# Définir PowerShell comme shell par défaut
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell `
    -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

# Ou définir PowerShell 7 (si installé)
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell `
    -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String -Force
```

> [!info] Shell par défaut Si aucun shell n'est spécifié, Windows utilise `cmd.exe` par défaut, contrairement à Linux qui utilise le shell défini dans `/etc/passwd`.

#### **Chemins de fichiers**

Les chemins Windows utilisent des backslashes (`\`) mais SSH accepte également les slashes (`/`) :

```powershell
# Équivalents sur Windows
~/.ssh/config
$env:USERPROFILE\.ssh\config
C:\Users\<username>\.ssh\config

# Dans les commandes SSH, les deux fonctionnent
ssh -i ~/.ssh/id_rsa user@host
ssh -i $env:USERPROFILE\.ssh\id_rsa user@host
```

#### **Variables d'environnement**

|Linux|Windows PowerShell|Description|
|---|---|---|
|`$HOME`|`$env:USERPROFILE`|Répertoire utilisateur|
|`$USER`|`$env:USERNAME`|Nom d'utilisateur|
|`$HOSTNAME`|`$env:COMPUTERNAME`|Nom de la machine|
|`$PATH`|`$env:PATH`|Chemins exécutables|

#### **Service SSH Agent**

```powershell
# Sur Windows, l'agent SSH est un service distinct
Get-Service ssh-agent

# Démarrer et configurer l'agent SSH
Start-Service ssh-agent
Set-Service -Name ssh-agent -StartupType 'Automatic'

# Ajouter une clé à l'agent
ssh-add $env:USERPROFILE\.ssh\id_rsa
```

> [!tip] Agent SSH automatique Sur Linux, `ssh-agent` démarre souvent automatiquement avec la session. Sur Windows, vous devez démarrer le service manuellement ou le configurer en démarrage automatique.

#### **Authentification Windows**

Windows OpenSSH supporte des méthodes d'authentification spécifiques :

```powershell
# Dans sshd_config, options spécifiques Windows

# Utiliser l'authentification Windows (Active Directory)
# Commenté par défaut
#PubkeyAuthentication yes
#PasswordAuthentication no

# Groupe d'administration SSH (équivalent sudo)
Match Group administrators
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

> [!warning] Fichier authorized_keys pour administrateurs Sur Windows, les comptes administrateurs utilisent un fichier `authorized_keys` différent situé dans `C:\ProgramData\ssh\` au lieu du répertoire utilisateur. Ce fichier doit avoir des permissions très strictes (accessible uniquement par SYSTEM et Administrators).

#### **Commandes de gestion des services**

**Linux (systemd) :**

```bash
sudo systemctl start sshd
sudo systemctl stop sshd
sudo systemctl restart sshd
sudo systemctl status sshd
sudo systemctl enable sshd
```

**Windows (PowerShell) :**

```powershell
Start-Service sshd
Stop-Service sshd
Restart-Service sshd
Get-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
```

#### **Logs et débogage**

**Linux :**

```bash
# Logs système
sudo journalctl -u sshd
sudo tail -f /var/log/auth.log

# Mode debug
sudo /usr/sbin/sshd -d
```

**Windows :**

```powershell
# Logs OpenSSH
Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 50

# Logs événements Windows
Get-EventLog -LogName Application -Source sshd -Newest 20

# Mode debug (arrêter le service d'abord)
Stop-Service sshd
& 'C:\Windows\System32\OpenSSH\sshd.exe' -d
```

> [!tip] Débogage avancé Pour un débogage détaillé sur Windows, ajoutez les lignes suivantes dans `sshd_config` :
> 
> ```
> LogLevel DEBUG3
> SyslogFacility LOCAL0
> ```
> 
> Puis redémarrez le service avec `Restart-Service sshd`.

---

## 🎓 Pièges courants et bonnes pratiques

### ⚠️ Pièges fréquents

1. **Permissions incorrectes sur les clés**
    
    - Symptôme : `WARNING: UNPROTECTED PRIVATE KEY FILE!`
    - Solution : Utiliser `icacls` pour restreindre les permissions
2. **Service SSH non démarré**
    
    - Symptôme : `Connection refused` lors de la connexion
    - Solution : Vérifier avec `Get-Service sshd` et démarrer si nécessaire
3. **Pare-feu bloque les connexions**
    
    - Symptôme : Timeout lors de la connexion depuis un réseau externe
    - Solution : Vérifier les règles avec `Get-NetFirewallRule -Name *ssh*`
4. **Shell par défaut inadapté**
    
    - Symptôme : Environnement bizarre après connexion SSH
    - Solution : Configurer PowerShell comme shell par défaut dans la registry
5. **Fichier authorized_keys ignoré pour les admins**
    
    - Symptôme : Authentification par clé ne fonctionne pas pour les administrateurs
    - Solution : Utiliser `C:\ProgramData\ssh\administrators_authorized_keys`

### ✅ Bonnes pratiques

1. **Toujours configurer le démarrage automatique**
    
    ```powershell
    Set-Service -Name sshd -StartupType 'Automatic'
    Set-Service -Name ssh-agent -StartupType 'Automatic'
    ```
    
2. **Vérifier régulièrement les logs**
    
    ```powershell
    Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 20
    ```
    
3. **Utiliser PowerShell comme shell par défaut** pour une meilleure expérience
    
4. **Maintenir OpenSSH à jour** via Windows Update
    
5. **Documenter les modifications** apportées à `sshd_config`
    
6. **Tester les connexions** après chaque modification de configuration
    

---

## 🎯 Astuces

### 💡 Astuce 1 : Connexion SSH rapide avec alias PowerShell

```powershell
# Ajouter à votre profil PowerShell ($PROFILE)
function Connect-MyServer {
    ssh utilisateur@serveur.example.com
}

# Utilisation
Connect-MyServer
```

### 💡 Astuce 2 : Vérification rapide de l'état SSH

```powershell
# Créer une fonction de diagnostic
function Test-SSHStatus {
    Write-Host "=== Client SSH ===" -ForegroundColor Cyan
    ssh -V
    
    Write-Host "`n=== Serveur SSH ===" -ForegroundColor Cyan
    Get-Service sshd | Select-Object Status, StartType, Name
    
    Write-Host "`n=== Port 22 ===" -ForegroundColor Cyan
    netstat -an | Select-String ":22.*LISTENING"
    
    Write-Host "`n=== Agent SSH ===" -ForegroundColor Cyan
    Get-Service ssh-agent | Select-Object Status, StartType, Name
}

# Utilisation
Test-SSHStatus
```

### 💡 Astuce 3 : Réinitialisation rapide des permissions

```powershell
# Script de correction des permissions .ssh
function Repair-SSHPermissions {
    $sshDir = "$env:USERPROFILE\.ssh"
    
    # Répertoire .ssh
    icacls $sshDir /inheritance:r
    icacls $sshDir /grant:r "$($env:USERNAME):(OI)(CI)F"
    
    # Clés privées (tous les fichiers sans extension ou .pem)
    Get-ChildItem $sshDir -File | Where-Object {
        $_.Extension -in @('', '.pem') -and $_.Name -notlike '*.pub'
    } | ForEach-Object {
        icacls $_.FullName /inheritance:r
        icacls $_.FullName /grant:r "$($env:USERNAME):F"
    }
    
    Write-Host "Permissions SSH corrigées !" -ForegroundColor Green
}
```

### 💡 Astuce 4 : Sauvegarde de la configuration

```powershell
# Sauvegarder la configuration SSH
$backupDate = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = "$env:USERPROFILE\ssh_backup_$backupDate"

New-Item -ItemType Directory -Path $backupPath
Copy-Item -Path "$env:USERPROFILE\.ssh" -Destination $backupPath -Recurse
Copy-Item -Path "C:\ProgramData\ssh\sshd_config" -Destination $backupPath

Write-Host "Sauvegarde créée dans : $backupPath" -ForegroundColor Green
```

### 💡 Astuce 5 : Installation silencieuse via script

```powershell
# Script d'installation complète OpenSSH (à exécuter en admin)
function Install-OpenSSHComplete {
    # Installer client et serveur
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    
    # Configurer et démarrer les services
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    
    Start-Service ssh-agent
    Set-Service -Name ssh-agent -StartupType 'Automatic'
    
    # Configurer le pare-feu
    New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    
    # Définir PowerShell comme shell par défaut
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell `
        -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
        -PropertyType String -Force
    
    Write-Host "`nOpenSSH installé et configuré avec succès !" -ForegroundColor Green
    Write-Host "Serveur SSH : " -NoNewline
    (Get-Service sshd).Status
}
```

---