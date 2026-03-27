

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

## Introduction

PowerShell Remoting via SSH combine la puissance de PowerShell avec la sécurité et la flexibilité de SSH. Contrairement au remoting PowerShell traditionnel (basé sur WinRM), cette approche offre plusieurs avantages significatifs :

> [!info] Pourquoi utiliser PowerShell Remoting via SSH ?
> 
> - **Sécurité renforcée** : Utilise le protocole SSH éprouvé au lieu de WinRM
> - **Compatibilité multiplateforme** : Fonctionne sur Windows, Linux et macOS
> - **Simplicité de configuration** : Pas besoin de configurer WinRM et les règles firewall complexes
> - **Authentification par clés** : Support natif de l'authentification SSH par clés
> - **Tunneling facile** : Intégration native avec les tunnels SSH

> [!warning] Différence avec WinRM PowerShell Remoting via SSH n'utilise PAS WinRM. C'est une approche complètement différente qui utilise le sous-système SSH. Les deux peuvent coexister, mais sont configurés et utilisés différemment.

---

## Configuration de PowerShell SSH Remoting

### Prérequis

Avant de configurer PowerShell Remoting via SSH, assurez-vous que :

1. **PowerShell Core (7+)** est installé (PowerShell SSH Remoting nécessite PowerShell 6 minimum, mais PowerShell 7+ est recommandé)
2. **OpenSSH Server** est installé et en cours d'exécution
3. Le **port SSH (22)** est accessible

> [!tip] Vérification rapide
> 
> ```powershell
> # Vérifier la version de PowerShell
> $PSVersionTable.PSVersion
> 
> # Vérifier le service SSH
> Get-Service sshd
> 
> # Vérifier le port d'écoute
> netstat -an | Select-String ":22"
> ```

### Configuration côté serveur Windows

#### Étape 1 : Définir PowerShell comme shell SSH par défaut

Le serveur SSH doit être configuré pour utiliser PowerShell comme sous-système :

```powershell
# Méthode 1 : Configuration automatique via script
# Localiser le chemin de pwsh.exe
$pwshPath = (Get-Command pwsh).Source

# Ajouter le sous-système PowerShell à sshd_config
$sshdConfigPath = "$env:ProgramData\ssh\sshd_config"
$subsystemLine = "Subsystem powershell $pwshPath -sshs -NoLogo"

# Vérifier si le sous-système existe déjà
$configContent = Get-Content $sshdConfigPath
if ($configContent -notmatch "Subsystem.*powershell") {
    Add-Content -Path $sshdConfigPath -Value "`n$subsystemLine"
    Write-Host "Sous-système PowerShell ajouté avec succès" -ForegroundColor Green
} else {
    Write-Host "Sous-système PowerShell déjà configuré" -ForegroundColor Yellow
}
```

```bash
# Méthode 2 : Édition manuelle du fichier sshd_config
# Ouvrir le fichier avec un éditeur
notepad C:\ProgramData\ssh\sshd_config

# Ajouter cette ligne à la fin du fichier :
# Subsystem powershell C:/Program Files/PowerShell/7/pwsh.exe -sshs -NoLogo
```

> [!info] Explication des paramètres
> 
> - `-sshs` : Active le mode SSH Subsystem dans PowerShell
> - `-NoLogo` : Supprime le banner PowerShell au démarrage (optionnel mais recommandé)

#### Étape 2 : Redémarrer le service SSH

```powershell
# Redémarrer le service pour appliquer les changements
Restart-Service sshd

# Vérifier que le service est bien démarré
Get-Service sshd | Select-Object Status, StartType
```

#### Étape 3 : Configuration de l'authentification

```powershell
# Par défaut, OpenSSH supporte l'authentification par mot de passe
# Pour utiliser l'authentification par clés (recommandé) :

# 1. Créer le dossier .ssh pour l'utilisateur si nécessaire
$sshFolder = "$env:USERPROFILE\.ssh"
if (!(Test-Path $sshFolder)) {
    New-Item -ItemType Directory -Path $sshFolder | Out-Null
}

# 2. Créer ou éditer le fichier authorized_keys
$authorizedKeysPath = "$sshFolder\authorized_keys"

# 3. Définir les permissions appropriées (important pour la sécurité SSH)
icacls $authorizedKeysPath /inheritance:r
icacls $authorizedKeysPath /grant:r "$env:USERNAME:(R)"
icacls $authorizedKeysPath /grant:r "SYSTEM:(F)"
```

> [!warning] Permissions critiques Les permissions du fichier `authorized_keys` sont essentielles. Si elles sont trop permissives, SSH refusera l'authentification par clé pour des raisons de sécurité.

#### Étape 4 : Vérification de la configuration

```powershell
# Tester la connexion SSH locale
ssh localhost

# Tester le sous-système PowerShell
ssh -s localhost powershell

# Si la connexion fonctionne, vous devriez obtenir un prompt PowerShell
```

### Configuration côté serveur Linux

#### Étape 1 : Installer PowerShell Core

```bash
# Ubuntu/Debian
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell

# CentOS/RHEL/Fedora
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y powershell

# Vérifier l'installation
pwsh -v
```

#### Étape 2 : Configurer le sous-système SSH

```bash
# Éditer le fichier de configuration SSH
sudo nano /etc/ssh/sshd_config

# Ajouter la ligne suivante (généralement à la fin du fichier)
# Subsystem powershell /usr/bin/pwsh -sshs -NoLogo

# Alternative : utiliser sed pour ajouter automatiquement
echo "Subsystem powershell /usr/bin/pwsh -sshs -NoLogo" | sudo tee -a /etc/ssh/sshd_config

# Redémarrer le service SSH
sudo systemctl restart sshd

# Vérifier le statut
sudo systemctl status sshd
```

#### Étape 3 : Configuration des permissions

```bash
# Créer le dossier .ssh si nécessaire
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Créer le fichier authorized_keys
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Ajouter une clé publique (exemple)
# echo "votre-clé-publique" >> ~/.ssh/authorized_keys
```

> [!tip] Sécurité SELinux Sur les systèmes avec SELinux activé (RHEL, CentOS, Fedora), vous devrez peut-être ajuster le contexte de sécurité :
> 
> ```bash
> sudo restorecon -R -v ~/.ssh
> ```

---

## Connexion à des serveurs Windows distants

### Connexion interactive

La cmdlet `Enter-PSSession` permet d'établir une session interactive avec un serveur distant :

```powershell
# Syntaxe de base
Enter-PSSession -HostName serveur.domaine.com -UserName utilisateur

# Avec spécification du port SSH
Enter-PSSession -HostName serveur.domaine.com -Port 2222 -UserName utilisateur

# Avec authentification par clé privée
Enter-PSSession -HostName serveur.domaine.com -UserName utilisateur -KeyFilePath C:\Users\nom\.ssh\id_rsa

# Exemple complet avec toutes les options courantes
Enter-PSSession -HostName 192.168.1.100 `
                -UserName admin `
                -KeyFilePath $env:USERPROFILE\.ssh\id_ed25519 `
                -Port 22
```

> [!example] Session interactive typique
> 
> ```powershell
> PS C:\Users\Alice> Enter-PSSession -HostName srv-prod-01 -UserName alice
> [srv-prod-01]: PS C:\Users\alice\Documents> 
> 
> # Le prompt change pour indiquer que vous êtes sur le serveur distant
> # Toutes les commandes sont maintenant exécutées sur srv-prod-01
> 
> [srv-prod-01]: PS C:\Users\alice\Documents> Get-Process | Select -First 5
> [srv-prod-01]: PS C:\Users\alice\Documents> Get-Service W*
> 
> # Pour quitter la session
> [srv-prod-01]: PS C:\Users\alice\Documents> Exit-PSSession
> PS C:\Users\Alice>
> ```

> [!info] Différence avec ssh classique Contrairement à `ssh utilisateur@serveur` qui vous donne un shell bash/cmd, `Enter-PSSession` vous place directement dans un environnement PowerShell complet avec accès à toutes les cmdlets et fonctionnalités PowerShell.

### Exécution de commandes distantes

Pour exécuter des commandes sans entrer en mode interactif, utilisez `Invoke-Command` :

```powershell
# Exécuter une commande simple
Invoke-Command -HostName serveur.domaine.com `
               -UserName utilisateur `
               -ScriptBlock { Get-Service }

# Exécuter plusieurs commandes
Invoke-Command -HostName serveur.domaine.com `
               -UserName utilisateur `
               -ScriptBlock {
                   $os = Get-CimInstance Win32_OperatingSystem
                   $cs = Get-CimInstance Win32_ComputerSystem
                   [PSCustomObject]@{
                       ComputerName = $cs.Name
                       OS = $os.Caption
                       Memory = [math]::Round($cs.TotalPhysicalMemory/1GB, 2)
                       Uptime = (Get-Date) - $os.LastBootUpTime
                   }
               }

# Exécuter sur plusieurs serveurs simultanément
$serveurs = @("srv01.domain.com", "srv02.domain.com", "srv03.domain.com")
Invoke-Command -HostName $serveurs `
               -UserName admin `
               -ScriptBlock { Get-Disk | Select Number, OperationalStatus, Size }

# Exécuter un script local sur un serveur distant
Invoke-Command -HostName serveur.domaine.com `
               -UserName utilisateur `
               -FilePath C:\Scripts\maintenance.ps1
```

> [!tip] Passage d'arguments
> 
> ```powershell
> # Utiliser -ArgumentList pour passer des variables
> $nomService = "wuauserv"
> Invoke-Command -HostName serveur.domaine.com `
>                -UserName admin `
>                -ScriptBlock { 
>                    param($service)
>                    Get-Service -Name $service 
>                } `
>                -ArgumentList $nomService
> 
> # Avec plusieurs arguments
> $service = "wuauserv"
> $action = "Stop"
> Invoke-Command -HostName serveur.domaine.com `
>                -UserName admin `
>                -ScriptBlock {
>                    param($svc, $act)
>                    if ($act -eq "Stop") { Stop-Service $svc }
>                    elseif ($act -eq "Start") { Start-Service $svc }
>                    Get-Service $svc
>                } `
>                -ArgumentList $service, $action
> ```

### Sessions persistantes

Les sessions persistantes permettent de réutiliser une connexion SSH sans avoir à se reconnecter à chaque commande :

```powershell
# Créer une session persistante
$session = New-PSSession -HostName serveur.domaine.com `
                         -UserName utilisateur `
                         -KeyFilePath $env:USERPROFILE\.ssh\id_ed25519

# Vérifier la session
$session | Format-List *

# Utiliser la session pour exécuter des commandes
Invoke-Command -Session $session -ScriptBlock { Get-Process }
Invoke-Command -Session $session -ScriptBlock { Get-EventLog -LogName System -Newest 10 }

# Entrer en mode interactif avec la session existante
Enter-PSSession -Session $session

# Fermer la session quand vous avez terminé
Remove-PSSession -Session $session
```

> [!info] Avantages des sessions persistantes
> 
> - **Performance** : Pas de reconnexion à chaque commande
> - **État partagé** : Les variables et l'environnement sont conservés entre les commandes
> - **Gestion des ressources** : Meilleur contrôle du cycle de vie des connexions
> - **Exécution en parallèle** : Possibilité d'exécuter plusieurs commandes simultanément

```powershell
# Exemple d'utilisation avancée : déploiement en plusieurs étapes
$session = New-PSSession -HostName srv-web-01 -UserName deploy

# Étape 1 : Arrêter le service
Invoke-Command -Session $session -ScriptBlock {
    Stop-Service -Name "MonApplication"
}

# Étape 2 : Copier les fichiers (la session reste ouverte)
Copy-Item -Path C:\Deploy\App\* `
          -Destination C:\inetpub\wwwroot\App\ `
          -ToSession $session `
          -Recurse -Force

# Étape 3 : Mettre à jour la configuration
Invoke-Command -Session $session -ScriptBlock {
    $config = Get-Content C:\inetpub\wwwroot\App\config.json | ConvertFrom-Json
    $config.version = "2.5.1"
    $config | ConvertTo-Json | Set-Content C:\inetpub\wwwroot\App\config.json
}

# Étape 4 : Redémarrer le service
Invoke-Command -Session $session -ScriptBlock {
    Start-Service -Name "MonApplication"
    Get-Service -Name "MonApplication"
}

# Nettoyer
Remove-PSSession -Session $session
```

> [!warning] Gestion des sessions N'oubliez pas de fermer les sessions avec `Remove-PSSession`. Les sessions abandonnées consomment des ressources sur le serveur distant et peuvent atteindre les limites de connexion SSH.

---

## Connexion à des serveurs Linux

### Particularités Linux

Lors de la connexion à des serveurs Linux, PowerShell s'exécute dans un environnement Unix, ce qui implique quelques différences importantes :

```powershell
# Connexion à un serveur Linux
Enter-PSSession -HostName linux-server.domain.com -UserName admin

# Une fois connecté, PowerShell utilise les conventions Linux
[linux-server]: PS /home/admin>

# Les chemins utilisent des slashes (/)
[linux-server]: PS /home/admin> Get-ChildItem /var/log
[linux-server]: PS /home/admin> Set-Location /etc

# Les commandes PowerShell fonctionnent normalement
[linux-server]: PS /etc> Get-Process | Where-Object CPU -gt 10
[linux-server]: PS /etc> Get-Service  # Fonctionne avec systemd
```

> [!info] Cmdlets spécifiques à Linux PowerShell Core sur Linux adapte certaines cmdlets pour fonctionner avec les systèmes Unix :
> 
> - `Get-Service` interroge systemd
> - `Get-Process` utilise les API Linux
> - Les cmdlets de fichiers comprennent les permissions Unix
> - Les variables d'environnement suivent les conventions Linux ($HOME au lieu de $env:USERPROFILE)

### Gestion des chemins

```powershell
# Variables d'environnement Linux
Invoke-Command -HostName linux-server -UserName admin -ScriptBlock {
    $HOME           # /home/admin
    $env:HOME       # /home/admin
    $env:PATH       # /usr/local/bin:/usr/bin:/bin
    $env:SHELL      # /bin/bash (shell par défaut de l'utilisateur)
    
    # PSModulePath sur Linux
    $env:PSModulePath
    # /home/admin/.local/share/powershell/Modules:/usr/local/share/powershell/Modules
}

# Construction de chemins multiplateformes
Invoke-Command -HostName linux-server -UserName admin -ScriptBlock {
    # Utiliser Join-Path pour la compatibilité
    $logPath = Join-Path -Path "/var" -ChildPath "log"
    
    # Ou utiliser les opérateurs PowerShell
    $configPath = "/etc" + "/" + "nginx"
    
    # Tester l'existence de fichiers
    Test-Path "/etc/nginx/nginx.conf"
    
    # Gérer les permissions Unix
    Get-ChildItem /home/admin | Select-Object Name, Mode, LastWriteTime
}
```

> [!example] Gestion des permissions Unix
> 
> ```powershell
> # Lire les permissions Unix depuis PowerShell
> Invoke-Command -HostName linux-server -UserName admin -ScriptBlock {
>     $fichier = Get-Item /home/admin/script.sh
>     
>     # Le Mode affiche les permissions Unix
>     $fichier.Mode  # -rwxr-xr-x
>     
>     # Utiliser chmod via PowerShell (nécessite les permissions appropriées)
>     # Note : chmod n'est pas une cmdlet PowerShell, mais peut être appelé
>     & chmod +x /home/admin/script.sh
>     
>     # Vérifier le propriétaire
>     $fichier.User   # admin
>     $fichier.Group  # admin
> }
> ```

### Compatibilité des commandes

```powershell
# Commandes PowerShell natives fonctionnent sur Linux
Invoke-Command -HostName linux-server -UserName admin -ScriptBlock {
    # Gestion des fichiers
    Get-ChildItem /var/log -Recurse -Filter "*.log"
    Copy-Item -Path /tmp/source.txt -Destination /home/admin/backup.txt
    Remove-Item -Path /tmp/old-files/* -Recurse
    
    # Gestion des processus
    Get-Process | Where-Object ProcessName -like "*apache*"
    Stop-Process -Name "defunct-process" -Force
    
    # Gestion des services (systemd)
    Get-Service nginx
    Restart-Service nginx  # Équivalent à systemctl restart nginx
    
    # Variables et objets
    $disques = Get-PSDrive
    $memoire = Get-Process | Measure-Object WorkingSet -Sum
}

# Appeler des commandes Linux natives depuis PowerShell
Invoke-Command -HostName linux-server -UserName admin -ScriptBlock {
    # Utiliser l'opérateur & pour exécuter des commandes natives
    & df -h
    & du -sh /var/log/*
    & systemctl status nginx
    & grep "error" /var/log/syslog
    
    # Capturer la sortie dans des variables PowerShell
    $diskUsage = & df -h | Select-Object -Skip 1
    $topProcesses = & ps aux | Sort-Object | Select-Object -Last 10
    
    # Combiner commandes natives et PowerShell
    $logErrors = & grep "ERROR" /var/log/application.log | 
                 ForEach-Object { $_.Split()[0] } |
                 Group-Object |
                 Sort-Object Count -Descending
}
```

> [!tip] Meilleures pratiques multiplateforme
> 
> ```powershell
> # Détecter le système d'exploitation
> Invoke-Command -HostName linux-server -UserName admin -ScriptBlock {
>     if ($IsLinux) {
>         Write-Host "Système Linux détecté"
>         $separator = "/"
>         $configPath = "/etc/myapp"
>     }
>     elseif ($IsWindows) {
>         Write-Host "Système Windows détecté"
>         $separator = "\"
>         $configPath = "C:\ProgramData\myapp"
>     }
>     
>     # Utiliser les cmdlets PowerShell plutôt que les commandes natives
>     # pour une meilleure compatibilité
>     Get-ChildItem -Path $configPath
>     Get-Content -Path (Join-Path $configPath "config.json")
> }
> ```

> [!warning] Différences importantes
> 
> - **Sensibilité à la casse** : Linux est sensible à la casse (`/home/Admin` ≠ `/home/admin`)
> - **Séparateurs** : Utiliser `/` sur Linux, `\` sur Windows (ou `Join-Path` pour la portabilité)
> - **Fin de ligne** : LF (`\n`) sur Linux vs CRLF (`\r\n`) sur Windows
> - **Exécutables** : Pas d'extension `.exe` sur Linux, vérifier les permissions d'exécution
> - **Chemins absolus** : Commencent par `/` sur Linux, par `C:\` sur Windows

---

## Cmdlets PowerShell pour SSH

### New-PSSession

Crée une nouvelle session PowerShell persistante via SSH :

```powershell
# Syntaxe complète
New-PSSession -HostName <string> 
              [-UserName <string>] 
              [-Port <int>] 
              [-KeyFilePath <string>] 
              [-Subsystem <string>] 
              [-ConnectingTimeout <int>] 
              [-Name <string>] 
              [-Options <hashtable>]

# Exemple basique
$session = New-PSSession -HostName srv-prod-01.domain.com -UserName admin

# Avec authentification par clé
$session = New-PSSession -HostName srv-prod-01.domain.com `
                         -UserName admin `
                         -KeyFilePath C:\Users\admin\.ssh\id_rsa

# Avec port personnalisé
$session = New-PSSession -HostName srv-prod-01.domain.com `
                         -UserName admin `
                         -Port 2222

# Session nommée (utile pour la gestion de multiples sessions)
$session = New-PSSession -HostName srv-prod-01.domain.com `
                         -UserName admin `
                         -Name "SessionProduction"

# Avec timeout de connexion personnalisé (en millisecondes)
$session = New-PSSession -HostName srv-prod-01.domain.com `
                         -UserName admin `
                         -ConnectingTimeout 10000  # 10 secondes
```

> [!info] Paramètres importants
> 
> |Paramètre|Description|Valeur par défaut|
> |---|---|---|
> |`-HostName`|Nom d'hôte ou IP du serveur distant|Obligatoire|
> |`-UserName`|Nom d'utilisateur pour la connexion SSH|Utilisateur actuel|
> |`-Port`|Port SSH|22|
> |`-KeyFilePath`|Chemin vers la clé privée SSH|Clé par défaut (~/.ssh/id_rsa)|
> |`-Subsystem`|Sous-système SSH à utiliser|"powershell"|
> |`-ConnectingTimeout`|Timeout de connexion en ms|180000 (3 min)|
> |`-Name`|Nom friendly de la session|Auto-généré|

```powershell
# Créer plusieurs sessions en une seule commande
$serveurs = @("srv01", "srv02", "srv03")
$sessions = New-PSSession -HostName $serveurs -UserName admin

# Vérifier les sessions créées
$sessions | Format-Table Id, Name, ComputerName, State, Availability

# Utiliser des options SSH avancées
$sshOptions = @{
    "StrictHostKeyChecking" = "no"
    "UserKnownHostsFile" = "/dev/null"
}
$session = New-PSSession -HostName srv-test `
                         -UserName testuser `
                         -Options $sshOptions
```

> [!warning] Gestion des erreurs
> 
> ```powershell
> # Gestion d'erreur lors de la création de session
> try {
>     $session = New-PSSession -HostName serveur-distant `
>                              -UserName admin `
>                              -ErrorAction Stop
>     Write-Host "Session créée : $($session.Name)" -ForegroundColor Green
> }
> catch {
>     Write-Host "Erreur de connexion : $_" -ForegroundColor Red
>     # Causes communes :
>     # - Serveur inaccessible
>     # - Authentification échouée
>     # - Port SSH fermé
>     # - Sous-système PowerShell non configuré
> }
> ```

### Enter-PSSession

Entre en mode interactif dans une session distante :

```powershell
# Syntaxe avec HostName (crée une session temporaire)
Enter-PSSession -HostName <string> 
                [-UserName <string>] 
                [-Port <int>] 
                [-KeyFilePath <string>]

# Syntaxe avec Session existante
Enter-PSSession -Session <PSSession>

# Syntaxe avec Id de session
Enter-PSSession -Id <int>

# Exemples

# Créer et entrer directement (session temporaire)
Enter-PSSession -HostName srv-web-01 -UserName webadmin

# Utiliser une session existante
$session = New-PSSession -HostName srv-web-01 -UserName webadmin
Enter-PSSession -Session $session

# Utiliser l'ID de session
Get-PSSession  # Affiche les sessions et leurs IDs
Enter-PSSession -Id 3

# Quitter la session interactive
Exit-PSSession  # ou simplement taper 'exit'
```

> [!example] Workflow typique avec session persistante
> 
> ```powershell
> # 1. Créer la session
> $session = New-PSSession -HostName srv-db-01 -UserName dba -Name "SessionBDD"
> 
> # 2. Exécuter des commandes non-interactives
> Invoke-Command -Session $session -ScriptBlock {
>     Get-Service MSSQLSERVER
> }
> 
> # 3. Entrer en mode interactif pour du travail manuel
> Enter-PSSession -Session $session
> 
> # [srv-db-01]: PS C:\> (vous êtes maintenant sur le serveur distant)
> # Travailler interactivement...
> 
> # 4. Quitter le mode interactif
> Exit-PSSession
> 
> # 5. Continuer à utiliser la session pour d'autres commandes
> Invoke-Command -Session $session -ScriptBlock {
>     # Autres opérations...
> }
> 
> # 6. Fermer la session
> Remove-PSSession -Session $session
> ```

> [!tip] Indication du prompt Lorsque vous êtes dans une session interactive, PowerShell modifie le prompt pour afficher le nom du serveur distant :
> 
> ```
> PS C:\Users\Alice> Enter-PSSession -HostName srv-prod-01 -UserName alice
> [srv-prod-01]: PS C:\Users\alice\Documents>
> ```
> 
> Cela vous aide à identifier rapidement où vos commandes seront exécutées.

### Invoke-Command

Exécute des commandes ou des scripts sur des ordinateurs distants :

```powershell
# Syntaxe complète
Invoke-Command [-HostName <string[]>] 
               [-UserName <string>] 
               [-Port <int>] 
               [-KeyFilePath <string>] 
               [-ScriptBlock <scriptblock>] 
               [-FilePath <string>] 
               [-ArgumentList <Object[]>] 
               [-AsJob] 
               [-InDisconnectedSession] 
               [-ThrottleLimit <int>]

# Syntaxe avec session existante
Invoke-Command -Session <PSSession[]> 
               [-ScriptBlock <scriptblock>] 
               [-FilePath <string>] 
               [-ArgumentList <Object[]>]

# Exemples de base

# Commande simple sur un serveur
Invoke-Command -HostName srv01 `
               -UserName admin `
               -ScriptBlock { Get-Process | Select -First 5 }

# Commande sur plusieurs serveurs
$serveurs = "srv01", "srv02", "srv03"
Invoke-Command -HostName $serveurs `
               -UserName admin `
               -ScriptBlock { 
                   [PSCustomObject]@{
                       Server = $env:COMPUTERNAME
                       Uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
                   }
               }

# Exécuter un script local sur un serveur distant
Invoke-Command -HostName srv-web-01 `
               -UserName webadmin `
               -FilePath C:\Scripts\Deploy-Website.ps1

# Avec passage d'arguments
$siteName = "MonSite"
$version = "2.5.0"
Invoke-Command -HostName srv-web-01 `
               -UserName webadmin `
               -FilePath C:\Scripts\Deploy-Website.ps1 `
               -ArgumentList $siteName, $version

# Utiliser une session existante
$session = New-PSSession -HostName srv01 -UserName admin
Invoke-Command -Session $session -ScriptBlock {
    Get-EventLog -LogName System -Newest 10
}
```

> [!info] Exécution parallèle Par défaut, `Invoke-Command` exécute les commandes en parallèle sur plusieurs ordinateurs avec un maximum de 32 connexions simultanées. Utilisez `-ThrottleLimit` pour ajuster ce nombre.

```powershell
# Exécution parallèle avec contrôle du throttle
$serveurs = 1..50 | ForEach-Object { "srv$_.domain.com" }

Invoke-Command -HostName $serveurs `
               -UserName admin `
               -ThrottleLimit 10 `  # Maximum 10 connexions simultanées
               -ScriptBlock {
                   [PSCustomObject]@{
                       Server = $env:COMPUTERNAME
                       FreeSpace = (Get-PSDrive C).Free / 1GB
                       Services = (Get-Service | Where-Object Status -eq 'Running').Count
                   }
               }

# Exécution en tant que job (asynchrone)
$job = Invoke-Command -HostName $serveurs `
                      -UserName admin `
                      -AsJob `
                      -ScriptBlock {
                          # Tâche longue...
                          Start-Sleep -Seconds 30
                          Get-Process
                      }

# Vérifier le statut du job
Get-Job -Id $job.Id

# Récupérer les résultats
$resultats = Receive-Job -Job $job -Wait
```

> [!example] Passage de variables et arguments
> 
> ```powershell
> # Méthode 1 : Utiliser -ArgumentList avec param()
> $serviceName = "W3SVC"
> $action = "Restart"
> 
> Invoke-Command -HostName srv-web-01 `
>                -UserName admin `
>                -ScriptBlock {
>                    param($svc, $act)
>                    
>                    if ($act -eq "Restart") {
>                        Restart-Service -Name $svc
>                    }
>                    Get-Service -Name $svc | Select Name, Status, StartType
>                } `
>                -ArgumentList $serviceName, $action
> 
> # Méthode 2 : Utiliser $using: (uniquement avec sessions persistantes)
> $session = New-PSSession -HostName srv-web-01 -UserName admin
> $serviceName = "W3SVC"
> 
> Invoke-Command -Session $session -ScriptBlock {
>     # $using: permet d'accéder aux variables de la session locale
>     Get-Service -Name $using:serviceName
> }
> ```

> [!warning] Piège courant : Sérialisation des objets Les objets retournés par `Invoke-Command` sont désérialisés et perdent leurs méthodes. Ils deviennent des objets "morts" en lecture seule.
> 
> ```powershell
> # Sur le serveur distant, $service a des méthodes
> $remoteResult = Invoke-Command -HostName srv01 -UserName admin -ScriptBlock {
>     $service = Get-Service W3SVC
>     $service.Start()  # ✅ Fonctionne (objet vivant)
>     return $service
> }
> 
> # Localement, $remoteResult est désérialisé
> $remoteResult.Start()  # ❌ Erreur : la méthode n'existe plus
> $remoteResult.Status   # ✅ Les propriétés fonctionnent toujours
> 
> # Solution : Effectuer les actions sur le serveur distant
> Invoke-Command -HostName srv01 -UserName admin -ScriptBlock {
>     $service = Get-Service W3SVC
>     $service.Start()
>     Start-Sleep -Seconds 2
>     return $service.Status  # Retourner seulement les données nécessaires
> }
> ```

### Get-PSSession et Remove-PSSession

Gérer les sessions PowerShell actives :

```powershell
# Get-PSSession : Lister toutes les sessions

# Toutes les sessions
Get-PSSession

# Sessions sur un ordinateur spécifique
Get-PSSession -ComputerName srv-web-01

# Session par nom
Get-PSSession -Name "SessionProduction"

# Session par ID
Get-PSSession -Id 3

# Affichage détaillé
Get-PSSession | Format-List *

# Affichage tableau avec colonnes personnalisées
Get-PSSession | Format-Table Id, Name, ComputerName, State, Availability, Runspace

# Filtrer les sessions par état
Get-PSSession | Where-Object State -eq "Opened"
Get-PSSession | Where-Object State -eq "Disconnected"
Get-PSSession | Where-Object State -eq "Broken"
```

> [!info] États des sessions
> 
> |État|Description|
> |---|---|
> |`Opened`|Session active et disponible|
> |`Closed`|Session fermée normalement|
> |`Broken`|Session interrompue (erreur réseau, timeout)|
> |`Disconnected`|Session déconnectée mais toujours active sur le serveur|
> |`Opening`|Session en cours de création|
> |`Closing`|Session en cours de fermeture|

```powershell
# Remove-PSSession : Fermer des sessions

# Fermer une session spécifique
$session = Get-PSSession -Name "SessionProduction"
Remove-PSSession -Session $session

# Fermer par ID
Remove-PSSession -Id 3

# Fermer toutes les sessions d'un serveur
Get-PSSession -ComputerName srv-web-01 | Remove-PSSession

# Fermer toutes les sessions
Get-PSSession | Remove-PSSession

# Fermer les sessions avec confirmation
Get-PSSession | Remove-PSSession -Confirm

# Fermer seulement les sessions inactives
Get-PSSession | Where-Object State -ne "Opened" | Remove-PSSession
```

> [!example] Script de nettoyage des sessions
> 
> ```powershell
> # Script pour nettoyer les sessions abandonnées ou cassées
> function Clean-PSSessions {
>     [CmdletBinding(SupportsShouldProcess)]
>     param(
>         [switch]$IncludeDisconnected,
>         [switch]$Force
>     )
>     
>     Write-Host "Analyse des sessions PowerShell..." -ForegroundColor Cyan
>     
>     $allSessions = Get-PSSession
>     $toRemove = @()
>     
>     # Sessions cassées (toujours à supprimer)
>     $brokenSessions = $allSessions | Where-Object State -eq "Broken"
>     $toRemove += $brokenSessions
>     
>     if ($brokenSessions.Count -gt 0) {
>         Write-Host "  Sessions cassées trouvées : $($brokenSessions.Count)" -ForegroundColor Yellow
>     }
>     
>     # Sessions déconnectées (optionnel)
>     if ($IncludeDisconnected) {
>         $disconnectedSessions = $allSessions | Where-Object State -eq "Disconnected"
>         $toRemove += $disconnectedSessions
>         
>         if ($disconnectedSessions.Count -gt 0) {
>             Write-Host "  Sessions déconnectées trouvées : $($disconnectedSessions.Count)" -ForegroundColor Yellow
>         }
>     }
>     
>     # Sessions fermées (nettoyage)
>     $closedSessions = $allSessions | Where-Object State -eq "Closed"
>     $toRemove += $closedSessions
>     
>     if ($toRemove.Count -eq 0) {
>         Write-Host "  Aucune session à nettoyer." -ForegroundColor Green
>         return
>     }
>     
>     Write-Host "`nSessions à supprimer :" -ForegroundColor Yellow
>     $toRemove | Format-Table Id, Name, ComputerName, State -AutoSize
>     
>     if ($Force -or $PSCmdlet.ShouldProcess("$($toRemove.Count) session(s)", "Supprimer")) {
>         $toRemove | Remove-PSSession -ErrorAction SilentlyContinue
>         Write-Host "`n$($toRemove.Count) session(s) supprimée(s)." -ForegroundColor Green
>     }
> }
> 
> # Utilisation
> Clean-PSSessions                      # Supprime les sessions cassées
> Clean-PSSessions -IncludeDisconnected # Inclut les sessions déconnectées
> Clean-PSSessions -Force               # Sans confirmation
> ```

> [!tip] Gestion automatique avec finally
> 
> ```powershell
> # Toujours fermer les sessions avec un bloc finally
> $session = $null
> try {
>     $session = New-PSSession -HostName srv01 -UserName admin
>     
>     # Utiliser la session...
>     Invoke-Command -Session $session -ScriptBlock {
>         # Travail...
>     }
> }
> catch {
>     Write-Error "Erreur : $_"
> }
> finally {
>     # Garantir la fermeture même en cas d'erreur
>     if ($session) {
>         Remove-PSSession -Session $session
>         Write-Host "Session fermée." -ForegroundColor Gray
>     }
> }
> ```

### Copy-Item via SSH

Copier des fichiers entre machines en utilisant les sessions SSH :

```powershell
# Syntaxe de base
Copy-Item -Path <source> 
          -Destination <destination> 
          -ToSession <PSSession>    # Pour copier VERS le serveur distant
          -FromSession <PSSession>  # Pour copier DEPUIS le serveur distant
          [-Recurse] 
          [-Force]

# Créer une session pour les transferts
$session = New-PSSession -HostName srv-web-01 -UserName webadmin

# Copier un fichier vers le serveur distant
Copy-Item -Path C:\Local\fichier.txt `
          -Destination C:\Remote\fichier.txt `
          -ToSession $session

# Copier un dossier complet (récursif)
Copy-Item -Path C:\Local\MonApplication `
          -Destination C:\Remote\Applications\ `
          -ToSession $session `
          -Recurse -Force

# Copier depuis le serveur distant vers la machine locale
Copy-Item -Path C:\Remote\logs\application.log `
          -Destination C:\Local\Logs\ `
          -FromSession $session

# Copier entre deux serveurs distants
$session1 = New-PSSession -HostName srv01 -UserName admin
$session2 = New-PSSession -HostName srv02 -UserName admin

# 1. Copier depuis srv01 vers local
Copy-Item -Path C:\Data\backup.zip `
          -Destination C:\Temp\backup.zip `
          -FromSession $session1

# 2. Copier depuis local vers srv02
Copy-Item -Path C:\Temp\backup.zip `
          -Destination C:\Data\backup.zip `
          -ToSession $session2
```

> [!example] Script de déploiement avec Copy-Item
> 
> ```powershell
> # Script de déploiement d'application
> function Deploy-Application {
>     param(
>         [string]$SourcePath = "C:\Build\MyApp",
>         [string]$TargetServer = "srv-web-01",
>         [string]$TargetPath = "C:\inetpub\wwwroot\MyApp",
>         [string]$UserName = "deploy"
>     )
>     
>     Write-Host "Démarrage du déploiement vers $TargetServer..." -ForegroundColor Cyan
>     
>     try {
>         # Créer la session
>         Write-Host "Connexion au serveur..." -ForegroundColor Gray
>         $session = New-PSSession -HostName $TargetServer -UserName $UserName
>         
>         # Arrêter l'application
>         Write-Host "Arrêt de l'application..." -ForegroundColor Yellow
>         Invoke-Command -Session $session -ScriptBlock {
>             param($path)
>             if (Test-Path $path) {
>                 Stop-Process -Name "w3wp" -Force -ErrorAction SilentlyContinue
>             }
>         } -ArgumentList $TargetPath
>         
>         # Sauvegarder l'ancienne version
>         Write-Host "Sauvegarde de l'ancienne version..." -ForegroundColor Gray
>         Invoke-Command -Session $session -ScriptBlock {
>             param($path)
>             if (Test-Path $path) {
>                 $backupPath = "$path.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
>                 Move-Item -Path $path -Destination $backupPath -Force
>                 Write-Host "  Sauvegardé vers : $backupPath"
>             }
>         } -ArgumentList $TargetPath
>         
>         # Copier les nouveaux fichiers
>         Write-Host "Copie des fichiers..." -ForegroundColor Yellow
>         Copy-Item -Path $SourcePath `
>                   -Destination $TargetPath `
>                   -ToSession $session `
>                   -Recurse -Force
>         
>         # Vérifier le déploiement
>         Write-Host "Vérification du déploiement..." -ForegroundColor Gray
>         $filesCount = Invoke-Command -Session $session -ScriptBlock {
>             param($path)
>             (Get-ChildItem -Path $path -Recurse -File).Count
>         } -ArgumentList $TargetPath
>         
>         Write-Host "  $filesCount fichiers déployés" -ForegroundColor Gray
>         
>         # Redémarrer l'application
>         Write-Host "Démarrage de l'application..." -ForegroundColor Yellow
>         Invoke-Command -Session $session -ScriptBlock {
>             Restart-Service W3SVC -Force
>         }
>         
>         Write-Host "`nDéploiement terminé avec succès !" -ForegroundColor Green
>     }
>     catch {
>         Write-Host "`nErreur lors du déploiement : $_" -ForegroundColor Red
>         throw
>     }
>     finally {
>         if ($session) {
>             Remove-PSSession -Session $session
>         }
>     }
> }
> 
> # Utilisation
> Deploy-Application -TargetServer srv-web-01
> ```

> [!warning] Limitations de Copy-Item via SSH
> 
> - **Performance** : Plus lent que SCP natif pour les très gros fichiers
> - **Chemins** : Les chemins doivent être absolus sur les machines distantes
> - **Permissions** : L'utilisateur doit avoir les droits d'écriture sur la destination
> - **Taille** : Peut être problématique pour les fichiers très volumineux (>1 GB)
> 
> Pour les très gros transferts, considérez utiliser SCP directement :
> 
> ```powershell
> # Alternative avec SCP pour les gros fichiers
> scp -r C:\Local\BigFolder user@server:/remote/path
> ```

> [!tip] Copie avec filtrage
> 
> ```powershell
> # Copier seulement certains types de fichiers
> $session = New-PSSession -HostName srv01 -UserName admin
> 
> # Récupérer la liste des fichiers à copier localement
> $filesToCopy = Get-ChildItem -Path C:\Source -Filter "*.log" -Recurse
> 
> foreach ($file in $filesToCopy) {
>     $relativePath = $file.FullName.Substring("C:\Source".Length)
>     $remotePath = "C:\Destination" + $relativePath
>     
>     # Créer le dossier distant si nécessaire
>     $remoteFolder = Split-Path $remotePath -Parent
>     Invoke-Command -Session $session -ScriptBlock {
>         param($folder)
>         if (!(Test-Path $folder)) {
>             New-Item -ItemType Directory -Path $folder -Force | Out-Null
>         }
>     } -ArgumentList $remoteFolder
>     
>     # Copier le fichier
>     Copy-Item -Path $file.FullName `
>               -Destination $remotePath `
>               -ToSession $session
>     
>     Write-Host "Copié : $relativePath" -ForegroundColor Gray
> }
> 
> Remove-PSSession -Session $session
> ```

---

## Bonnes pratiques et optimisation

### Gestion des sessions

```powershell
# ✅ BONNE PRATIQUE : Réutiliser les sessions
$session = New-PSSession -HostName srv01 -UserName admin

# Plusieurs opérations avec la même session
Invoke-Command -Session $session -ScriptBlock { Get-Service }
Invoke-Command -Session $session -ScriptBlock { Get-Process }
Invoke-Command -Session $session -ScriptBlock { Get-EventLog System -Newest 10 }

Remove-PSSession -Session $session

# ❌ MAUVAISE PRATIQUE : Créer une nouvelle session à chaque fois
Invoke-Command -HostName srv01 -UserName admin -ScriptBlock { Get-Service }
Invoke-Command -HostName srv01 -UserName admin -ScriptBlock { Get-Process }
Invoke-Command -HostName srv01 -UserName admin -ScriptBlock { Get-EventLog System -Newest 10 }
```

> [!tip] Pattern de session avec try-finally
> 
> ```powershell
> # Garantir la fermeture même en cas d'erreur
> function Invoke-RemoteOperations {
>     param(
>         [string]$HostName,
>         [string]$UserName
>     )
>     
>     $session = $null
>     try {
>         $session = New-PSSession -HostName $HostName -UserName $UserName
>         
>         # Vos opérations ici...
>         $result1 = Invoke-Command -Session $session -ScriptBlock { ... }
>         $result2 = Invoke-Command -Session $session -ScriptBlock { ... }
>         
>         return @{
>             Result1 = $result1
>             Result2 = $result2
>         }
>     }
>     finally {
>         if ($session) {
>             Remove-PSSession -Session $session
>         }
>     }
> }
> ```

### Authentification et sécurité

```powershell
# ✅ BONNE PRATIQUE : Utiliser l'authentification par clés
$session = New-PSSession -HostName srv01 `
                         -UserName admin `
                         -KeyFilePath ~/.ssh/id_ed25519

# ✅ BONNE PRATIQUE : Vérifier les empreintes des hôtes
# Lors de la première connexion, vérifiez manuellement l'empreinte
# Les connexions suivantes utiliseront le fichier known_hosts

# ❌ ÉVITER : Désactiver la vérification des clés d'hôte (sauf environnements de test)
$options = @{ "StrictHostKeyChecking" = "no" }
$session = New-PSSession -HostName srv01 -UserName admin -Options $options

# ✅ BONNE PRATIQUE : Utiliser des clés différentes par environnement
$keyDev = "~/.ssh/id_dev"
$keyProd = "~/.ssh/id_prod"

$sessionDev = New-PSSession -HostName srv-dev-01 -UserName admin -KeyFilePath $keyDev
$sessionProd = New-PSSession -HostName srv-prod-01 -UserName admin -KeyFilePath $keyProd
```

> [!warning] Sécurité des identifiants
> 
> ```powershell
> # ❌ NE JAMAIS faire ça : hardcoder les mots de passe
> $password = "MonMotDePasse123"
> 
> # ✅ Utiliser l'authentification par clés SSH (pas de mot de passe)
> # ✅ Ou utiliser des secrets managers (Azure Key Vault, etc.)
> 
> # Pour les scripts automatisés, configurez l'agent SSH
> ssh-agent
> ssh-add ~/.ssh/id_ed25519
> 
> # Ensuite, les sessions SSH utiliseront automatiquement les clés chargées
> $session = New-PSSession -HostName srv01 -UserName admin
> ```

### Performance et optimisation

```powershell
# ✅ BONNE PRATIQUE : Exécution parallèle sur plusieurs serveurs
$serveurs = @("srv01", "srv02", "srv03", "srv04", "srv05")

# Utiliser Invoke-Command avec plusieurs HostNames (parallèle par défaut)
$results = Invoke-Command -HostName $serveurs `
                          -UserName admin `
                          -ScriptBlock {
                              Get-Service | Where-Object Status -eq 'Running'
                          }

# ✅ BONNE PRATIQUE : Contrôler le throttle pour ne pas surcharger
$results = Invoke-Command -HostName $serveurs `
                          -UserName admin `
                          -ThrottleLimit 5 `  # Max 5 connexions simultanées
                          -ScriptBlock { ... }

# ✅ BONNE PRATIQUE : Utiliser des jobs pour les opérations longues
$job = Invoke-Command -HostName $serveurs `
                      -UserName admin `
                      -AsJob `
                      -ScriptBlock {
                          # Opération longue (backup, analyse, etc.)
                          Start-Sleep -Seconds 300
                          Get-EventLog -LogName System -Newest 1000
                      }

# Continuer à travailler pendant l'exécution du job
Write-Host "Job lancé, je peux faire autre chose..."

# Vérifier périodiquement
Get-Job -Id $job.Id

# Récupérer les résultats quand c'est prêt
$results = Receive-Job -Job $job -Wait
```

> [!tip] Optimisation des transferts de données
> 
> ```powershell
> # ❌ Moins optimal : Retourner des objets volumineux
> $data = Invoke-Command -HostName srv01 -UserName admin -ScriptBlock {
>     Get-Process | Select-Object *  # Trop de propriétés
> }
> 
> # ✅ Mieux : Retourner seulement les données nécessaires
> $data = Invoke-Command -HostName srv01 -UserName admin -ScriptBlock {
>     Get-Process | Select-Object Name, CPU, WorkingSet | Where-Object CPU -gt 10
> }
> 
> # ✅ Encore mieux : Faire le traitement sur le serveur distant
> $summary = Invoke-Command -HostName srv01 -UserName admin -ScriptBlock {
>     $processes = Get-Process
>     [PSCustomObject]@{
>         TotalProcesses = $processes.Count
>         TopCPU = ($processes | Sort-Object CPU -Descending | Select-Object -First 5).Name
>         TotalMemory = ($processes | Measure-Object WorkingSet -Sum).Sum / 1GB
>     }
> }
> ```

### Gestion des erreurs

```powershell
# ✅ BONNE PRATIQUE : Gestion d'erreur robuste
function Invoke-RemoteCommandSafe {
    param(
        [string]$HostName,
        [string]$UserName,
        [scriptblock]$ScriptBlock,
        [int]$RetryCount = 3
    )
    
    $attempt = 0
    $success = $false
    
    while (-not $success -and $attempt -lt $RetryCount) {
        $attempt++
        try {
            Write-Host "Tentative $attempt/$RetryCount..." -ForegroundColor Gray
            
            $result = Invoke-Command -HostName $HostName `
                                     -UserName $UserName `
                                     -ScriptBlock $ScriptBlock `
                                     -ErrorAction Stop
            
            $success = $true
            return $result
        }
        catch {
            Write-Warning "Erreur lors de la tentative $attempt : $_"
            
            if ($attempt -lt $RetryCount) {
                $waitTime = [math]::Pow(2, $attempt)  # Backoff exponentiel
                Write-Host "Nouvelle tentative dans $waitTime secondes..." -ForegroundColor Yellow
                Start-Sleep -Seconds $waitTime
            }
            else {
                Write-Error "Échec après $RetryCount tentatives"
                throw
            }
        }
    }
}

# Utilisation
$result = Invoke-RemoteCommandSafe -HostName srv01 `
                                    -UserName admin `
                                    -ScriptBlock { Get-Service } `
                                    -RetryCount 3
```

> [!example] Gestion des sessions interrompues
> 
> ```powershell
> # Fonction pour vérifier et recréer les sessions si nécessaire
> function Get-ValidPSSession {
>     param(
>         [string]$HostName,
>         [string]$UserName,
>         [ref]$SessionRef
>     )
>     
>     # Vérifier si la session existe et est valide
>     if ($SessionRef.Value -and $SessionRef.Value.State -eq "Opened") {
>         return $SessionRef.Value
>     }
>     
>     # Session invalide, la recréer
>     Write-Host "Recréation de la session vers $HostName..." -ForegroundColor Yellow
>     
>     if ($SessionRef.Value) {
>         Remove-PSSession -Session $SessionRef.Value -ErrorAction SilentlyContinue
>     }
>     
>     $SessionRef.Value = New-PSSession -HostName $HostName -UserName $UserName
>     return $SessionRef.Value
> }
> 
> # Utilisation
> $session = $null
> 
> # Premier appel
> $validSession = Get-ValidPSSession -HostName srv01 -UserName admin -SessionRef ([ref]$session)
> Invoke-Command -Session $validSession -ScriptBlock { Get-Service }
> 
> # ... du temps passe, la session peut être interrompue ...
> 
> # Deuxième appel (recrée automatiquement si nécessaire)
> $validSession = Get-ValidPSSession -HostName srv01 -UserName admin -SessionRef ([ref]$session)
> Invoke-Command -Session $validSession -ScriptBlock { Get-Process }
> ```

### Logging et monitoring

```powershell
# ✅ BONNE PRATIQUE : Logger les opérations distantes
function Invoke-CommandWithLogging {
    param(
        [string]$HostName,
        [string]$UserName,
        [scriptblock]$ScriptBlock,
        [string]$LogPath = "C:\Logs\RemoteCommands.log"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp | $HostName | Début d'exécution"
    Add-Content -Path $LogPath -Value $logEntry
    
    try {
        $result = Invoke-Command -HostName $HostName `
                                 -UserName $UserName `
                                 -ScriptBlock $ScriptBlock `
                                 -ErrorAction Stop
        
        $logEntry = "$timestamp | $HostName | Succès"
        Add-Content -Path $LogPath -Value $logEntry
        
        return $result
    }
    catch {
        $logEntry = "$timestamp | $HostName | Erreur : $_"
        Add-Content -Path $LogPath -Value $logEntry
        throw
    }
}

# Monitoring des sessions actives
function Get-PSSessionReport {
    $sessions = Get-PSSession
    
    [PSCustomObject]@{
        Total = $sessions.Count
        Opened = ($sessions | Where-Object State -eq "Opened").Count
        Broken = ($sessions | Where-Object State -eq "Broken").Count
        Disconnected = ($sessions | Where-Object State -eq "Disconnected").Count
        Sessions = $sessions | Select-Object Id, Name, ComputerName, State, IdleTimeout
    }
}

# Utilisation
Get-PSSessionReport | Format-List
```

> [!tip] Script de surveillance continu
> 
> ```powershell
> # Surveiller les sessions toutes les 30 secondes
> while ($true) {
>     Clear-Host
>     Write-Host "=== Surveillance des sessions PowerShell ===" -ForegroundColor Cyan
>     Write-Host "Dernière mise à jour : $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
>     Write-Host ""
>     
>     $report = Get-PSSessionReport
>     
>     Write-Host "Total sessions : $($report.Total)" -ForegroundColor White
>     Write-Host "  Ouvertes : $($report.Opened)" -ForegroundColor Green
>     Write-Host "  Cassées : $($report.Broken)" -ForegroundColor Red
>     Write-Host "  Déconnectées : $($report.Disconnected)" -ForegroundColor Yellow
>     Write-Host ""
>     
>     if ($report.Sessions.Count -gt 0) {
>         $report.Sessions | Format-Table -AutoSize
>     }
>     
>     Start-Sleep -Seconds 30
> }
> ```

---

## 🎯 Récapitulatif

PowerShell Remoting via SSH offre une solution moderne et sécurisée pour l'administration à distance multiplateforme :

**Points clés à retenir :**

1. **Configuration serveur** : Installation du sous-système PowerShell dans sshd_config
2. **Cmdlets principales** :
    - `New-PSSession` pour créer des sessions persistantes
    - `Enter-PSSession` pour le mode interactif
    - `Invoke-Command` pour l'exécution de commandes
    - `Copy-Item` pour les transferts de fichiers
3. **Compatibilité** : Fonctionne sur Windows, Linux et macOS
4. **Sécurité** : Authentification par clés SSH recommandée
5. **Performance** : Réutiliser les sessions et exécuter en parallèle

> [!warning] Pièges courants à éviter
> 
> - Oublier de fermer les sessions (`Remove-PSSession`)
> - Ne pas gérer les erreurs de connexion
> - Utiliser des sessions temporaires pour des opérations multiples
> - Désactiver la vérification des clés d'hôte en production
> - Retourner trop de données depuis les commandes distantes
> - Ne pas utiliser le parallélisme pour les opérations sur plusieurs serveurs

**Avantages de SSH sur WinRM :**

- ✅ Pas de configuration complexe de pare-feu
- ✅ Authentification par clés natives
- ✅ Fonctionne sur tous les OS (Windows, Linux, macOS)
- ✅ Standard de l'industrie éprouvé
- ✅ Meilleure compatibilité avec les environnements cloud

---

_Ce cours couvre les fonctionnalités essentielles de PowerShell Remoting via SSH. Pour une utilisation optimale, combinez ces techniques avec une gestion rigoureuse des sessions et une bonne sécurité._