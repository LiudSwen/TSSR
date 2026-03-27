

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

La connexion SSH depuis Linux vers Windows est devenue possible grâce à l'intégration native d'OpenSSH dans Windows 10/11 et Windows Server 2019+. Cette capacité permet d'administrer des machines Windows à distance avec les mêmes outils que pour Linux, unifiant ainsi la gestion des infrastructures hétérogènes.

> [!info] Pourquoi connecter Linux vers Windows via SSH ?
> 
> - Administration unifiée de parcs machines mixtes
> - Scripts d'automatisation multi-plateformes
> - Accès sécurisé aux serveurs Windows depuis des postes Linux
> - Alternative moderne à RDP pour l'administration en ligne de commande
> - Intégration dans des workflows DevOps

---

## Configuration du serveur OpenSSH Windows

### Installation d'OpenSSH Server

OpenSSH n'est pas toujours installé par défaut sur Windows. Voici comment l'installer et le configurer.

#### Via PowerShell (méthode recommandée)

```powershell
# Vérifier si OpenSSH Server est installé
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

# Installer OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Démarrer le service SSH
Start-Service sshd

# Configurer le démarrage automatique
Set-Service -Name sshd -StartupType 'Automatic'

# Vérifier le statut du service
Get-Service sshd
```

#### Via l'interface graphique

1. **Paramètres** → **Applications** → **Fonctionnalités facultatives**
2. Cliquer sur **Ajouter une fonctionnalité**
3. Rechercher et installer **Serveur OpenSSH**
4. Démarrer le service via **Services.msc**

> [!warning] Pare-feu Windows L'installation d'OpenSSH Server crée normalement une règle de pare-feu automatiquement, mais vérifiez que le port 22 (TCP) est bien ouvert :
> 
> ```powershell
> # Vérifier la règle de pare-feu
> Get-NetFirewallRule -Name *ssh*
> 
> # Créer une règle si nécessaire
> New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
> ```

### Configuration du fichier sshd_config

Le fichier de configuration se trouve dans `C:\ProgramData\ssh\sshd_config`.

```powershell
# Éditer le fichier de configuration
notepad C:\ProgramData\ssh\sshd_config
```

#### Paramètres importants pour l'interopérabilité Linux-Windows

```bash
# Port d'écoute (défaut: 22)
Port 22

# Autoriser l'authentification par clé publique
PubkeyAuthentication yes

# Fichier des clés autorisées (spécifique à Windows)
AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys

# Autoriser l'authentification par mot de passe (à désactiver en production)
PasswordAuthentication yes

# Définir le shell par défaut (PowerShell recommandé)
Subsystem powershell pwsh.exe -sshs -NoLogo

# Shell par défaut pour les connexions (optionnel)
# ForceCommand powershell.exe -NoProfile
```

> [!tip] Shell par défaut Par défaut, OpenSSH sur Windows lance `cmd.exe`. Pour utiliser PowerShell automatiquement, ajoutez à la fin du fichier :
> 
> ```bash
> # Utiliser PowerShell comme shell par défaut
> Subsystem powershell C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sshs -NoLogo -NoProfile
> ```

#### Redémarrer le service après modification

```powershell
# Redémarrer le service SSH pour appliquer les changements
Restart-Service sshd
```

### Configuration des clés autorisées pour les administrateurs

Sur Windows, les utilisateurs du groupe **Administrateurs** doivent utiliser un fichier de clés spécifique.

```powershell
# Créer le fichier pour les administrateurs
New-Item -Path C:\ProgramData\ssh\administrators_authorized_keys -ItemType File -Force

# Définir les permissions appropriées (CRUCIAL)
# Seuls SYSTEM et les Administrateurs doivent avoir accès
$acl = Get-Acl C:\ProgramData\ssh\administrators_authorized_keys
$acl.SetAccessRuleProtection($true, $false)
$administratorsRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "Allow")
$systemRule = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "Allow")
$acl.SetAccessRule($administratorsRule)
$acl.SetAccessRule($systemRule)
Set-Acl -Path C:\ProgramData\ssh\administrators_authorized_keys -AclObject $acl
```

> [!warning] Permissions critiques Si les permissions du fichier `administrators_authorized_keys` ne sont pas correctement configurées, l'authentification par clé publique échouera silencieusement. Le fichier doit appartenir aux administrateurs et à SYSTEM uniquement.

### Vérification de la configuration

```powershell
# Tester la configuration SSH
sshd -t

# Afficher les logs SSH (en cas de problème)
Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 50

# Vérifier que le service écoute bien
netstat -an | findstr :22
```

---

## Authentification depuis Linux

### Connexion par mot de passe

La méthode la plus simple pour tester la connexion initiale.

```bash
# Syntaxe de base
ssh utilisateur@adresse_ip_windows

# Exemple avec un utilisateur local Windows
ssh john@192.168.1.100

# Spécifier un port différent si nécessaire
ssh -p 2222 john@192.168.1.100
```

> [!example] Exemple de première connexion
> 
> ```bash
> $ ssh admin@192.168.1.100
> The authenticity of host '192.168.1.100 (192.168.1.100)' can't be established.
> ECDSA key fingerprint is SHA256:xxx...
> Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
> Warning: Permanently added '192.168.1.100' (ECDSA) to the list of known hosts.
> admin@192.168.1.100's password: 
> 
> Microsoft Windows [Version 10.0.19045.3803]
> (c) Microsoft Corporation. All rights reserved.
> 
> admin@DESKTOP-WIN C:\Users\admin>
> ```

### Authentification par clé publique

Méthode recommandée pour une authentification sécurisée et automatisée.

#### Génération de la paire de clés (sur Linux)

```bash
# Générer une paire de clés ED25519 (recommandé)
ssh-keygen -t ed25519 -C "mon_email@example.com"

# Ou RSA 4096 bits pour une compatibilité maximale
ssh-keygen -t rsa -b 4096 -C "mon_email@example.com"

# Les clés sont créées dans ~/.ssh/
# - Clé privée : ~/.ssh/id_ed25519 (ou id_rsa)
# - Clé publique : ~/.ssh/id_ed25519.pub (ou id_rsa.pub)
```

#### Transfert de la clé publique vers Windows

##### Méthode 1 : Transfert manuel (utilisateur standard)

```bash
# Copier le contenu de la clé publique
cat ~/.ssh/id_ed25519.pub

# Se connecter à Windows et créer le répertoire .ssh
ssh john@192.168.1.100
mkdir C:\Users\john\.ssh
exit

# Transférer la clé publique
scp ~/.ssh/id_ed25519.pub john@192.168.1.100:C:/Users/john/.ssh/authorized_keys
```

##### Méthode 2 : Avec ssh-copy-id (si disponible)

```bash
# ssh-copy-id automatise le processus
ssh-copy-id -i ~/.ssh/id_ed25519.pub john@192.168.1.100
```

> [!warning] Attention pour les administrateurs Windows Les utilisateurs du groupe **Administrateurs** doivent placer leur clé publique dans :
> 
> ```
> C:\ProgramData\ssh\administrators_authorized_keys
> ```
> 
> Et non dans leur répertoire utilisateur.

##### Méthode 3 : Pour les administrateurs Windows

```bash
# Copier la clé publique
cat ~/.ssh/id_ed25519.pub

# Se connecter à Windows avec PowerShell
ssh admin@192.168.1.100

# Ajouter la clé au fichier des administrateurs
Add-Content -Path C:\ProgramData\ssh\administrators_authorized_keys -Value "ssh-ed25519 AAAA...votre_clé..."

# Vérifier les permissions (si pas déjà configuré)
icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "Administrators:F"
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "SYSTEM:F"
```

#### Test de l'authentification par clé

```bash
# Connexion sans mot de passe
ssh john@192.168.1.100

# Connexion avec une clé spécifique
ssh -i ~/.ssh/id_ed25519 john@192.168.1.100

# Mode verbeux pour diagnostiquer les problèmes
ssh -v john@192.168.1.100
```

### Configuration du client SSH (fichier config)

Pour simplifier les connexions répétées, créez un fichier de configuration SSH.

```bash
# Éditer ou créer le fichier config
nano ~/.ssh/config
```

```bash
# Configuration pour un serveur Windows spécifique
Host winserver
    HostName 192.168.1.100
    User admin
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Configuration avec rebond (jump host)
Host winserver-prod
    HostName 10.0.0.50
    User administrator
    ProxyJump bastion.example.com
    IdentityFile ~/.ssh/id_rsa_prod

# Wildcard pour tous les serveurs Windows
Host win*.example.com
    User administrator
    IdentityFile ~/.ssh/id_company
```

```bash
# Connexion simplifiée
ssh winserver

# Au lieu de
ssh -i ~/.ssh/id_ed25519 admin@192.168.1.100
```

> [!tip] Astuces de configuration
> 
> - `ServerAliveInterval` : maintient la connexion active (utile pour les connexions instables)
> - `ProxyJump` : permet de passer par un serveur intermédiaire (bastion)
> - `ControlMaster` : réutilise une connexion existante pour accélérer les connexions multiples

### Résolution des problèmes d'authentification

|Problème|Cause probable|Solution|
|---|---|---|
|Permission denied (publickey)|Clé publique mal configurée|Vérifier `authorized_keys` et les permissions|
|Connection refused|Service SSH non démarré|Vérifier `Get-Service sshd` sur Windows|
|Connection timed out|Pare-feu bloque le port 22|Vérifier les règles de pare-feu|
|Shell incorrect (cmd au lieu de PowerShell)|Configuration du shell par défaut|Modifier `sshd_config` (voir section Configuration)|
|Authentication fails for admin|Mauvais fichier de clés|Utiliser `administrators_authorized_keys`|

> [!tip] Diagnostic avancé
> 
> ```bash
> # Activer le mode verbeux (3 niveaux : -v, -vv, -vvv)
> ssh -vvv john@192.168.1.100
> 
> # Sur Windows, vérifier les logs SSH
> Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 100
> 
> # Tester la configuration SSH côté serveur
> sshd -t -d
> ```

---

## Exécution de commandes PowerShell

### Commandes simples en mode non-interactif

L'exécution de commandes à distance est l'un des cas d'usage les plus puissants de SSH.

```bash
# Syntaxe de base
ssh utilisateur@windows_host "commande"

# Exemples PowerShell de base
ssh admin@192.168.1.100 "Get-Process"
ssh admin@192.168.1.100 "Get-Service | Where-Object Status -eq 'Running'"
ssh admin@192.168.1.100 "Get-ComputerInfo | Select-Object CsName, OsVersion"
```

> [!info] Différence entre cmd.exe et PowerShell Par défaut, SSH sur Windows peut lancer `cmd.exe`. Pour forcer PowerShell :
> 
> ```bash
> ssh admin@192.168.1.100 "powershell -Command \"Get-Process\""
> ```
> 
> Si vous avez configuré PowerShell comme shell par défaut (voir Configuration), ce n'est pas nécessaire.

### Gestion des chemins Windows

Les chemins Windows utilisent le backslash `\` qui doit être échappé.

```bash
# Mauvais : le backslash sera interprété
ssh admin@192.168.1.100 "Get-Content C:\Users\admin\document.txt"

# Correct : échapper les backslashes
ssh admin@192.168.1.100 "Get-Content C:\\Users\\admin\\document.txt"

# Alternative : utiliser le forward slash (PowerShell l'accepte)
ssh admin@192.168.1.100 "Get-Content C:/Users/admin/document.txt"

# Ou utiliser des guillemets simples pour éviter l'interprétation
ssh admin@192.168.1.100 'Get-Content C:\Users\admin\document.txt'
```

### Exécution de scripts PowerShell complexes

#### Méthode 1 : Script en ligne (here-document)

```bash
# Exécuter plusieurs commandes PowerShell
ssh admin@192.168.1.100 << 'EOF'
$services = Get-Service | Where-Object Status -eq 'Running'
$services | Format-Table Name, Status, DisplayName
Write-Host "Total de services actifs: $($services.Count)"
EOF
```

#### Méthode 2 : Transférer et exécuter un script

```bash
# Créer un script local
cat > script.ps1 << 'EOF'
param(
    [string]$ServiceName = "sshd"
)

$service = Get-Service -Name $ServiceName
Write-Host "Service: $($service.Name)"
Write-Host "Statut: $($service.Status)"
Write-Host "Type de démarrage: $($service.StartType)"
EOF

# Transférer le script vers Windows
scp script.ps1 admin@192.168.1.100:C:/Temp/

# Exécuter le script
ssh admin@192.168.1.100 "powershell -ExecutionPolicy Bypass -File C:/Temp/script.ps1 -ServiceName 'wuauserv'"
```

> [!warning] Politique d'exécution PowerShell Par défaut, Windows empêche l'exécution de scripts PowerShell. Utilisez `-ExecutionPolicy Bypass` pour les scripts de confiance, ou configurez la politique globalement :
> 
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
> ```

### Commandes système courantes

#### Informations système

```bash
# Version de Windows
ssh admin@192.168.1.100 "systeminfo | findstr /B /C:'OS Name' /C:'OS Version'"

# Utilisation disque
ssh admin@192.168.1.100 "Get-PSDrive C | Select-Object Used,Free,@{Name='Total';Expression={(\$_.Used+\$_.Free)}}"

# Utilisation mémoire
ssh admin@192.168.1.100 "Get-CimInstance Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory"

# Uptime
ssh admin@192.168.1.100 "(Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime"
```

#### Gestion des processus

```bash
# Lister les processus par consommation mémoire
ssh admin@192.168.1.100 "Get-Process | Sort-Object WS -Descending | Select-Object -First 10"

# Arrêter un processus par nom
ssh admin@192.168.1.100 "Stop-Process -Name notepad -Force"

# Démarrer une application
ssh admin@192.168.1.100 "Start-Process notepad"
```

#### Gestion des services

```bash
# Statut d'un service
ssh admin@192.168.1.100 "Get-Service -Name sshd"

# Démarrer un service
ssh admin@192.168.1.100 "Start-Service -Name wuauserv"

# Arrêter un service
ssh admin@192.168.1.100 "Stop-Service -Name wuauserv"

# Redémarrer un service
ssh admin@192.168.1.100 "Restart-Service -Name sshd"
```

#### Gestion des utilisateurs

```bash
# Lister les utilisateurs locaux
ssh admin@192.168.1.100 "Get-LocalUser | Select-Object Name, Enabled, LastLogon"

# Créer un utilisateur
ssh admin@192.168.1.100 "New-LocalUser -Name 'nouveau_user' -Password (ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force)"

# Ajouter au groupe Administrateurs
ssh admin@192.168.1.100 "Add-LocalGroupMember -Group 'Administrators' -Member 'nouveau_user'"
```

### Gestion des sorties et encodage

Windows utilise un encodage différent de Linux, ce qui peut causer des problèmes d'affichage.

```bash
# Forcer l'encodage UTF-8 dans PowerShell
ssh admin@192.168.1.100 "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; Get-Process"

# Rediriger la sortie vers un fichier sur Windows
ssh admin@192.168.1.100 "Get-Process > C:/Temp/processus.txt"

# Récupérer le fichier sur Linux
scp admin@192.168.1.100:C:/Temp/processus.txt ./
```

### Exécution asynchrone (tâches en arrière-plan)

```bash
# Lancer une tâche en arrière-plan avec Start-Job
ssh admin@192.168.1.100 "Start-Job -ScriptBlock { Start-Sleep 60; Get-Date > C:/Temp/resultat.txt }"

# Vérifier les jobs en cours
ssh admin@192.168.1.100 "Get-Job"

# Récupérer le résultat d'un job
ssh admin@192.168.1.100 "Receive-Job -Id 1"
```

> [!tip] Exécution de tâches longues Pour des tâches très longues, utilisez le Planificateur de tâches Windows au lieu de jobs PowerShell :
> 
> ```bash
> ssh admin@192.168.1.100 "schtasks /create /tn 'MaTache' /tr 'powershell.exe -File C:/Scripts/script.ps1' /sc once /st 23:00"
> ```

### Bonnes pratiques pour l'exécution de commandes

|Pratique|Raison|Exemple|
|---|---|---|
|Utiliser des guillemets simples `'`|Évite l'interprétation par le shell Linux|`ssh host 'Get-Process'`|
|Échapper les variables PowerShell|Évite l'expansion côté Linux|`ssh host "\$var = 10"`|
|Tester localement d'abord|Déboguer sur Windows directement|PowerShell ISE ou terminal local|
|Utiliser `-ErrorAction Stop`|Arrêter l'exécution en cas d'erreur|`Get-Service -ErrorAction Stop`|
|Logger les sorties|Tracer les exécutions|`...|

---

## Transfert de fichiers bidirectionnel

### SCP (Secure Copy Protocol)

SCP est l'outil traditionnel pour le transfert de fichiers via SSH.

#### Linux vers Windows

```bash
# Syntaxe de base
scp fichier_local utilisateur@windows_host:chemin/distant

# Exemples
scp document.txt admin@192.168.1.100:C:/Users/admin/Documents/
scp rapport.pdf admin@192.168.1.100:C:/Temp/

# Transfert de plusieurs fichiers
scp file1.txt file2.txt file3.txt admin@192.168.1.100:C:/Backup/

# Transfert avec wildcards
scp *.log admin@192.168.1.100:C:/Logs/

# Transfert récursif d'un répertoire entier
scp -r mon_dossier/ admin@192.168.1.100:C:/Data/

# Préserver les attributs (timestamps, permissions)
scp -p fichier.txt admin@192.168.1.100:C:/Archive/
```

#### Windows vers Linux

```bash
# Syntaxe
scp utilisateur@windows_host:chemin/distant fichier_local

# Exemples
scp admin@192.168.1.100:C:/Users/admin/rapport.docx ./

# Télécharger depuis un chemin avec espaces (échapper ou utiliser des guillemets)
scp "admin@192.168.1.100:C:/Program Files/app/config.xml" ./

# Télécharger un dossier complet
scp -r admin@192.168.1.100:C:/Projects/MonProjet ./
```

> [!warning] Chemins Windows dans SCP
> 
> - Utilisez `/` au lieu de `\` dans les chemins Windows
> - Les espaces dans les chemins doivent être entre guillemets ou échappés
> - Le `:` après le hostname est obligatoire
> 
> ```bash
> # Correct
> scp file.txt admin@192.168.1.100:C:/Users/admin/Documents/
> 
> # Avec espaces
> scp "admin@192.168.1.100:C:/Program Files/app/file.txt" ./
> ```

#### Options utiles de SCP

```bash
# Spécifier un port SSH différent
scp -P 2222 fichier.txt admin@192.168.1.100:C:/Temp/

# Mode verbeux (pour diagnostiquer les problèmes)
scp -v fichier.txt admin@192.168.1.100:C:/Temp/

# Limiter la bande passante (en Kbit/s)
scp -l 1000 gros_fichier.iso admin@192.168.1.100:C:/Downloads/

# Utiliser une clé d'identité spécifique
scp -i ~/.ssh/id_special fichier.txt admin@192.168.1.100:C:/Temp/

# Compression des données (utile pour les fichiers texte)
scp -C fichier.txt admin@192.168.1.100:C:/Temp/
```

### SFTP (SSH File Transfer Protocol)

SFTP offre une interface interactive plus flexible que SCP.

#### Session SFTP interactive

```bash
# Démarrer une session SFTP
sftp admin@192.168.1.100

# Commandes disponibles dans la session SFTP
sftp> help

# Navigation et listage
sftp> pwd                    # Répertoire courant (distant)
sftp> lpwd                   # Répertoire courant (local)
sftp> ls                     # Lister fichiers distants
sftp> lls                    # Lister fichiers locaux
sftp> cd C:/Users/admin      # Changer de répertoire distant
sftp> lcd /home/user         # Changer de répertoire local

# Transfert Linux → Windows
sftp> put fichier.txt                          # Upload un fichier
sftp> put -r mon_dossier                       # Upload récursif
sftp> put fichier.txt C:/Temp/nouveau_nom.txt  # Upload avec renommage

# Transfert Windows → Linux
sftp> get rapport.pdf                          # Download un fichier
sftp> get -r C:/Projects/MonProjet             # Download récursif
sftp> get config.xml /home/user/backup/        # Download vers un chemin spécifique

# Gestion des fichiers distants
sftp> mkdir C:/Backup/nouveau_dossier          # Créer un répertoire
sftp> rmdir C:/Backup/vieux_dossier            # Supprimer un répertoire vide
sftp> rm fichier_inutile.txt                   # Supprimer un fichier
sftp> rename ancien.txt nouveau.txt            # Renommer un fichier

# Quitter
sftp> exit
```

#### SFTP en mode batch (non-interactif)

```bash
# Exécuter des commandes SFTP depuis un fichier
cat > commandes.sftp << 'EOF'
cd C:/Backup
put -r mes_donnees/
get logs.txt
bye
EOF

sftp -b commandes.sftp admin@192.168.1.100

# Ou utiliser un pipe
echo "get C:/Logs/app.log" | sftp admin@192.168.1.100
```

> [!tip] SFTP vs SCP : Quand utiliser lequel ?
> 
> **Utilisez SCP quand :**
> 
> - Transfert simple de fichiers connus
> - Scripts automatisés
> - Besoin de vitesse (légèrement plus rapide)
> 
> **Utilisez SFTP quand :**
> 
> - Exploration de répertoires distants
> - Transferts multiples dans une session
> - Manipulation de fichiers (renommer, supprimer)
> - Reprise de transferts interrompus

### Rsync sur SSH (si disponible sur Windows)

Rsync n'est pas natif sur Windows mais peut être installé via WSL ou Cygwin.

```bash
# Synchronisation Linux → Windows (si rsync disponible sur Windows)
rsync -avz -e ssh mes_fichiers/ admin@192.168.1.100:/cygdrive/c/Backup/

# Synchronisation avec suppression des fichiers absents de la source
rsync -avz --delete -e ssh mes_fichiers/ admin@192.168.1.100:/cygdrive/c/Backup/

# Dry-run (simulation sans modification)
rsync -avzn -e ssh mes_fichiers/ admin@192.168.1.100:/cygdrive/c/Backup/
```

> [!info] Limitation de rsync sur Windows Rsync natif n'est pas disponible sur Windows standard. Alternatives :
> 
> - Installer WSL (Windows Subsystem for Linux)
> - Utiliser Cygwin ou cwRsync
> - Privilégier SCP/SFTP pour l'interopérabilité Linux-Windows

### Automatisation du transfert de fichiers

#### Script de sauvegarde automatique

```bash
#!/bin/bash
# backup_to_windows.sh

# Configuration
WIN_HOST="admin@192.168.1.100"
WIN_PATH="C:/Backups"
LOCAL_PATH="/home/user/data"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${DATE}.tar.gz"

# Créer l'archive
echo "Création de l'archive..."
tar -czf "/tmp/${BACKUP_NAME}" -C "${LOCAL_PATH}" .

# Transférer vers Windows
echo "Transfert vers ${WIN_HOST}..."
scp "/tmp/${BACKUP_NAME}" "${WIN_HOST}:${WIN_PATH}/"

# Vérifier le transfert
if [ $? -eq 0 ]; then
    echo "Sauvegarde réussie : ${BACKUP_NAME}"
    rm "/tmp/${BACKUP_NAME}"
else
    echo "Erreur lors du transfert" >&2
    exit 1
fi
```

#### Surveillance et synchronisation continue

```bash
#!/bin/bash
# sync_watch.sh - Surveille un dossier et synchronise vers Windows

WATCH_DIR="/home/user/documents"
WIN_DEST="admin@192.168.1.100:C:/Documents"

# Installer inotify-tools si nécessaire : apt-get install inotify-tools

inotifywait -m -r -e modify,create,delete "${WATCH_DIR}" | while read path action file; do
    echo "Changement détecté : ${action} ${file}"
    scp -r "${WATCH_DIR}/"* "${WIN_DEST}/"
done
```

### Transfert de fichiers volumineux : optimisation

```bash
# Compression à la volée (pour fichiers texte/logs)
tar -czf - mon_dossier/ | ssh admin@192.168.1.100 "cat > C:/Temp/archive.tar.gz"

# Sans compression (pour fichiers déjà compressés : vidéos, images, archives)
scp -C large_file.zip admin@192.168.1.100:C:/Downloads/

# Transfert avec reprise (sftp uniquement, pas scp)
sftp admin@192.168.1.100 << EOF
reget large_file.iso C:/Downloads/large_file.iso
EOF

# Parallélisation avec plusieurs connexions SSH (script avancé)
# Divisez le fichier et transférez en parallèle
split -b 100M large_file.iso part_
for part in part_*; do
    scp "$part" admin@192.168.1.100:C:/Temp/ &
done
wait
```

### Gestion des permissions et propriétaires

Les permissions Linux et Windows étant fondamentalement différentes, certains aspects ne se traduisent pas directement.

```bash
# Sur Linux, les permissions POSIX sont préservées lors de la copie
ls -l fichier.txt
# -rw-r--r-- 1 user user 1234 Dec 15 10:30 fichier.txt

# Après transfert vers Windows, les permissions sont mappées aux ACL Windows
scp fichier.txt admin@192.168.1.100:C:/Temp/

# Sur Windows, vérifier les permissions
ssh admin@192.168.1.100 "icacls C:/Temp/fichier.txt"
```

> [!warning] Incompatibilité des modèles de permissions
> 
> - Linux utilise le modèle POSIX (user/group/other + rwx)
> - Windows utilise les ACL (Access Control Lists)
> - Le mapping n'est pas parfait : les permissions Linux sont approximées en ACL Windows
> - Les attributs spéciaux (setuid, setgid, sticky bit) ne sont pas transférés

### Problèmes courants et solutions

|Problème|Cause|Solution|
|---|---|---|
|Transfert échoue sans message|Chemin destination invalide|Vérifier que le répertoire existe sur Windows|
|Permission denied (côté Windows)|Utilisateur SSH n'a pas les droits|Vérifier les permissions NTFS du dossier destination|
|Fichier corrompu après transfert|Transfert interrompu|Utiliser SFTP avec `reget` ou vérifier avec des checksums|
|Noms de fichiers tronqués|Caractères spéciaux incompatibles|Éviter `< > : " / \|
|Transfert très lent|Pas de compression|Ajouter `-C` à SCP ou utiliser la compression tar|

### Vérification de l'intégrité des transferts

```bash
# Calculer le checksum avant transfert (Linux)
sha256sum fichier.txt
# a1b2c3d4... fichier.txt

# Transférer le fichier
scp fichier.txt admin@192.168.1.100:C:/Temp/

# Vérifier le checksum après transfert (Windows)
ssh admin@192.168.1.100 "Get-FileHash C:/Temp/fichier.txt -Algorithm SHA256"

# Automatiser la vérification
LOCAL_HASH=$(sha256sum fichier.txt | awk '{print $1}')
REMOTE_HASH=$(ssh admin@192.168.1.100 "Get-FileHash C:/Temp/fichier.txt -Algorithm SHA256 | Select-Object -ExpandProperty Hash")

if [ "$LOCAL_HASH" == "$REMOTE_HASH" ]; then
    echo "✓ Transfert vérifié avec succès"
else
    echo "✗ Erreur : les checksums ne correspondent pas"
fi
```

### Script complet de transfert sécurisé avec vérification

```bash
#!/bin/bash
# secure_transfer.sh - Transfert avec vérification d'intégrité

set -e  # Arrêter en cas d'erreur

# Configuration
SOURCE_FILE="$1"
WIN_HOST="$2"
WIN_PATH="$3"

# Vérifications préliminaires
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Erreur : fichier source introuvable" >&2
    exit 1
fi

if [ -z "$WIN_HOST" ] || [ -z "$WIN_PATH" ]; then
    echo "Usage: $0 <fichier_source> <host_windows> <chemin_destination>" >&2
    exit 1
fi

# Calculer le hash local
echo "Calcul du checksum local..."
LOCAL_HASH=$(sha256sum "$SOURCE_FILE" | awk '{print $1}')
echo "Hash local : $LOCAL_HASH"

# Transférer le fichier
echo "Transfert en cours..."
scp -C "$SOURCE_FILE" "${WIN_HOST}:${WIN_PATH}/"
FILENAME=$(basename "$SOURCE_FILE")

# Vérifier le hash distant
echo "Vérification du checksum distant..."
REMOTE_HASH=$(ssh "$WIN_HOST" "Get-FileHash ${WIN_PATH}/${FILENAME} -Algorithm SHA256 | Select-Object -ExpandProperty Hash" | tr '[:upper:]' '[:lower:]' | tr -d '\r')

# Comparaison
if [ "$LOCAL_HASH" == "$REMOTE_HASH" ]; then
    echo "✓ Transfert réussi et vérifié"
    exit 0
else
    echo "✗ Erreur : intégrité du fichier compromise" >&2
    echo "  Local  : $LOCAL_HASH"
    echo "  Distant: $REMOTE_HASH"
    exit 1
fi
```

```bash
# Utilisation du script
chmod +x secure_transfer.sh
./secure_transfer.sh document.pdf admin@192.168.1.100 C:/Documents
```

---

## 🎯 Pièges courants et bonnes pratiques

### Pièges à éviter

> [!warning] Erreurs fréquentes
> 
> **1. Mauvaise configuration des clés pour les administrateurs**
> 
> ```bash
> # ✗ INCORRECT pour un administrateur Windows
> scp ~/.ssh/id_rsa.pub admin@192.168.1.100:C:/Users/admin/.ssh/authorized_keys
> 
> # ✓ CORRECT pour un administrateur Windows
> # La clé doit être dans C:\ProgramData\ssh\administrators_authorized_keys
> ```
> 
> **2. Oublier d'échapper les chemins Windows**
> 
> ```bash
> # ✗ INCORRECT
> ssh admin@192.168.1.100 "Get-Content C:\Users\admin\file.txt"
> 
> # ✓ CORRECT
> ssh admin@192.168.1.100 "Get-Content C:\\Users\\admin\\file.txt"
> # ou
> ssh admin@192.168.1.100 'Get-Content C:\Users\admin\file.txt'
> ```
> 
> **3. Utiliser cmd.exe au lieu de PowerShell**
> 
> ```bash
> # Problème : certaines commandes ne fonctionnent qu'en PowerShell
> ssh admin@192.168.1.100 "Get-Process"  # Échoue si cmd.exe est le shell par défaut
> 
> # Solution : forcer PowerShell
> ssh admin@192.168.1.100 "powershell -Command Get-Process"
> # ou configurer PowerShell comme shell par défaut dans sshd_config
> ```
> 
> **4. Ignorer les politiques d'exécution PowerShell**
> 
> ```bash
> # Échoue souvent
> ssh admin@192.168.1.100 "C:/Scripts/script.ps1"
> 
> # Solution
> ssh admin@192.168.1.100 "powershell -ExecutionPolicy Bypass -File C:/Scripts/script.ps1"
> ```
> 
> **5. Ne pas gérer les espaces dans les chemins Windows**
> 
> ```bash
> # ✗ INCORRECT
> scp file.txt admin@192.168.1.100:C:/Program Files/app/
> 
> # ✓ CORRECT
> scp file.txt "admin@192.168.1.100:C:/Program Files/app/"
> ```

### Bonnes pratiques de sécurité

> [!tip] Sécurisation recommandée
> 
> **1. Désactiver l'authentification par mot de passe**
> 
> ```powershell
> # Dans C:\ProgramData\ssh\sshd_config
> PasswordAuthentication no
> PubkeyAuthentication yes
> 
> # Redémarrer le service
> Restart-Service sshd
> ```
> 
> **2. Limiter les utilisateurs autorisés**
> 
> ```powershell
> # Dans sshd_config, autoriser uniquement certains utilisateurs
> AllowUsers admin@192.168.1.* backup_user
> 
> # Ou refuser certains utilisateurs
> DenyUsers guest public
> ```
> 
> **3. Changer le port SSH par défaut**
> 
> ```powershell
> # Dans sshd_config
> Port 2222
> 
> # Mettre à jour la règle de pare-feu
> Remove-NetFirewallRule -Name sshd
> New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 2222
> 
> # Connexion depuis Linux
> ssh -p 2222 admin@192.168.1.100
> ```
> 
> **4. Utiliser des clés robustes**
> 
> ```bash
> # Privilégier ED25519 (plus sûr et plus rapide)
> ssh-keygen -t ed25519 -C "admin@example.com"
> 
> # Ou RSA 4096 bits minimum
> ssh-keygen -t rsa -b 4096 -C "admin@example.com"
> ```
> 
> **5. Configurer un timeout pour les sessions inactives**
> 
> ```powershell
> # Dans sshd_config
> ClientAliveInterval 300
> ClientAliveCountMax 2
> # Déconnexion après 10 minutes d'inactivité (300s × 2)
> ```
> 
> **6. Journaliser les connexions SSH**
> 
> ```powershell
> # Dans sshd_config
> SyslogFacility AUTH
> LogLevel VERBOSE
> 
> # Consulter les logs
> Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 50
> 
> # Surveiller les tentatives de connexion échouées
> Get-Content C:\ProgramData\ssh\logs\sshd.log | Select-String "Failed password"
> ```

### Optimisation des performances

> [!tip] Améliorer les performances
> 
> **1. Réutiliser les connexions SSH (multiplexing)**
> 
> ```bash
> # Dans ~/.ssh/config
> Host winserver
>     HostName 192.168.1.100
>     User admin
>     ControlMaster auto
>     ControlPath ~/.ssh/sockets/%r@%h-%p
>     ControlPersist 10m
> 
> # Créer le répertoire pour les sockets
> mkdir -p ~/.ssh/sockets
> 
> # Première connexion : crée la connexion principale
> ssh winserver "Get-Date"
> 
> # Connexions suivantes : réutilisent la connexion (beaucoup plus rapides)
> ssh winserver "Get-Process"
> scp file.txt winserver:C:/Temp/
> ```
> 
> **2. Compression pour les transferts de fichiers texte**
> 
> ```bash
> # SCP avec compression
> scp -C large_log_file.log admin@192.168.1.100:C:/Logs/
> 
> # SFTP avec compression
> sftp -C admin@192.168.1.100
> ```
> 
> **3. Ajuster les algorithmes de chiffrement**
> 
> ```bash
> # Dans ~/.ssh/config (pour des connexions locales sécurisées)
> Host 192.168.*
>     Ciphers aes128-gcm@openssh.com,aes256-gcm@openssh.com
>     MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
> 
> # Plus rapide mais moins sécurisé (uniquement pour réseaux de confiance)
> # Ciphers aes128-ctr,aes192-ctr,aes256-ctr
> ```
> 
> **4. Paralléliser les transferts de fichiers multiples**
> 
> ```bash
> # Transférer plusieurs fichiers en parallèle
> for file in *.log; do
>     scp "$file" admin@192.168.1.100:C:/Logs/ &
> done
> wait
> echo "Tous les transferts sont terminés"
> ```

### Maintenance et monitoring

```bash
# Script de monitoring des connexions SSH (à exécuter sur Linux)
#!/bin/bash
# monitor_ssh_windows.sh

WIN_HOST="admin@192.168.1.100"

# Tester la connectivité
if ssh -o ConnectTimeout=5 "$WIN_HOST" "echo OK" &>/dev/null; then
    echo "✓ SSH accessible"
else
    echo "✗ SSH inaccessible" >&2
    exit 1
fi

# Vérifier le statut du service SSH
SERVICE_STATUS=$(ssh "$WIN_HOST" "Get-Service sshd | Select-Object -ExpandProperty Status")
echo "Service SSH : $SERVICE_STATUS"

# Vérifier les connexions actives
echo "Connexions SSH actives :"
ssh "$WIN_HOST" "Get-NetTCPConnection -LocalPort 22 -State Established | Select-Object RemoteAddress, RemotePort, CreationTime"

# Vérifier les dernières tentatives de connexion
echo "Dernières tentatives de connexion :"
ssh "$WIN_HOST" "Get-Content C:/ProgramData/ssh/logs/sshd.log -Tail 10 | Select-String 'Accepted\|Failed'"
```

### Automatisation avec cron (Linux)

```bash
# Sauvegarde automatique quotidienne vers Windows
# Éditer la crontab
crontab -e

# Ajouter cette ligne pour une sauvegarde tous les jours à 2h du matin
0 2 * * * /home/user/scripts/backup_to_windows.sh >> /var/log/backup_windows.log 2>&1

# Synchronisation toutes les heures
0 * * * * /usr/bin/rsync -az /home/user/data/ admin@192.168.1.100:/cygdrive/c/Backup/

# Vérification de la connectivité SSH toutes les 5 minutes
*/5 * * * * /home/user/scripts/monitor_ssh_windows.sh || echo "Alerte SSH" | mail -s "SSH Windows inaccessible" admin@example.com
```

---

## 📊 Récapitulatif des commandes essentielles

### Configuration initiale (Windows)

```powershell
# Installation et démarrage
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Configuration pare-feu
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# Configuration des clés pour administrateurs
New-Item -Path C:\ProgramData\ssh\administrators_authorized_keys -ItemType File -Force
icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "Administrators:F"
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "SYSTEM:F"
```

### Connexion et authentification (Linux)

```bash
# Connexion simple
ssh utilisateur@192.168.1.100

# Générer une paire de clés
ssh-keygen -t ed25519 -C "email@example.com"

# Copier la clé publique (utilisateur standard)
ssh-copy-id -i ~/.ssh/id_ed25519.pub utilisateur@192.168.1.100

# Configuration ~/.ssh/config
cat >> ~/.ssh/config << 'EOF'
Host winserver
    HostName 192.168.1.100
    User admin
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
EOF
```

### Exécution de commandes

```bash
# Commande simple
ssh admin@192.168.1.100 "Get-Service sshd"

# Commande complexe avec heredoc
ssh admin@192.168.1.100 << 'EOF'
$services = Get-Service | Where-Object Status -eq 'Running'
Write-Host "Services actifs : $($services.Count)"
EOF

# Exécuter un script PowerShell distant
ssh admin@192.168.1.100 "powershell -ExecutionPolicy Bypass -File C:/Scripts/script.ps1"
```

### Transfert de fichiers

```bash
# SCP : Linux → Windows
scp fichier.txt admin@192.168.1.100:C:/Temp/
scp -r dossier/ admin@192.168.1.100:C:/Backup/

# SCP : Windows → Linux
scp admin@192.168.1.100:C:/Data/rapport.pdf ./

# SFTP interactif
sftp admin@192.168.1.100
# put fichier.txt
# get rapport.pdf
# bye

# Transfert avec vérification d'intégrité
sha256sum fichier.txt
scp fichier.txt admin@192.168.1.100:C:/Temp/
ssh admin@192.168.1.100 "Get-FileHash C:/Temp/fichier.txt -Algorithm SHA256"
```

---

## 🔍 Diagnostic et résolution de problèmes

### Checklist de diagnostic

```bash
# 1. Tester la connectivité réseau
ping 192.168.1.100

# 2. Tester la connectivité SSH
nc -zv 192.168.1.100 22
# ou
telnet 192.168.1.100 22

# 3. Connexion SSH en mode verbeux
ssh -vvv admin@192.168.1.100

# 4. Vérifier la configuration SSH locale
ssh -G admin@192.168.1.100

# 5. Tester l'authentification par clé
ssh -i ~/.ssh/id_ed25519 -v admin@192.168.1.100
```

### Vérifications côté Windows (via PowerShell direct ou RDP)

```powershell
# 1. Statut du service
Get-Service sshd

# 2. Logs SSH
Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 50

# 3. Configuration SSH
Get-Content C:\ProgramData\ssh\sshd_config

# 4. Pare-feu
Get-NetFirewallRule -Name *ssh*

# 5. Écoute sur le port 22
Get-NetTCPConnection -LocalPort 22

# 6. Permissions du fichier de clés (pour administrateurs)
icacls C:\ProgramData\ssh\administrators_authorized_keys
```

### Messages d'erreur courants

|Erreur|Signification|Solution|
|---|---|---|
|`Connection refused`|Service SSH non démarré ou pare-feu|Démarrer le service : `Start-Service sshd`|
|`Permission denied (publickey)`|Clé publique invalide ou mal placée|Vérifier `authorized_keys` et permissions|
|`Host key verification failed`|Clé d'hôte a changé|Éditer `~/.ssh/known_hosts` ou `ssh-keygen -R 192.168.1.100`|
|`Connection timed out`|Problème réseau ou pare-feu|Vérifier connectivité réseau et règles pare-feu|
|`No supported authentication methods`|Configuration authentification incorrecte|Vérifier `sshd_config` (PasswordAuthentication, PubkeyAuthentication)|
|`Unable to negotiate`|Incompatibilité algorithmes|Mettre à jour OpenSSH ou ajuster les algorithmes|

---

## ✨ Cas d'usage pratiques

### Exemple 1 : Sauvegarde automatisée Linux → Windows

```bash
#!/bin/bash
# daily_backup.sh

BACKUP_DIR="/home/user/important_data"
WIN_HOST="admin@192.168.1.100"
WIN_BACKUP="C:/Backups/$(hostname)"
DATE=$(date +%Y%m%d)

# Créer l'archive
tar -czf "/tmp/backup_${DATE}.tar.gz" "$BACKUP_DIR"

# Transférer vers Windows
scp "/tmp/backup_${DATE}.tar.gz" "${WIN_HOST}:${WIN_BACKUP}/"

# Nettoyer
rm "/tmp/backup_${DATE}.tar.gz"

# Notification
echo "Sauvegarde terminée : backup_${DATE}.tar.gz"
```

### Exemple 2 : Surveillance de services Windows depuis Linux

```bash
#!/bin/bash
# check_windows_services.sh

WIN_HOST="admin@192.168.1.100"
SERVICES=("sshd" "wuauserv" "W3SVC")

for service in "${SERVICES[@]}"; do
    status=$(ssh "$WIN_HOST" "Get-Service -Name $service | Select-Object -ExpandProperty Status")
    echo "Service $service : $status"
    
    if [ "$status" != "Running" ]; then
        echo "ALERTE : $service n'est pas actif !" >&2
        # Envoyer une notification, email, etc.
    fi
done
```

### Exemple 3 : Déploiement d'application sur Windows depuis Linux

```bash
#!/bin/bash
# deploy_to_windows.sh

APP_NAME="MonApp"
APP_VERSION="1.2.3"
LOCAL_BUILD="./build/${APP_NAME}-${APP_VERSION}.zip"
WIN_HOST="admin@192.168.1.100"
WIN_DEPLOY_PATH="C:/Applications/${APP_NAME}"

echo "Déploiement de ${APP_NAME} v${APP_VERSION}..."

# 1. Arrêter l'application existante
ssh "$WIN_HOST" "Stop-Service ${APP_NAME} -ErrorAction SilentlyContinue"

# 2. Sauvegarder l'ancienne version
ssh "$WIN_HOST" "Rename-Item ${WIN_DEPLOY_PATH} ${WIN_DEPLOY_PATH}_backup -ErrorAction SilentlyContinue"

# 3. Transférer la nouvelle version
scp "$LOCAL_BUILD" "${WIN_HOST}:C:/Temp/"

# 4. Décompresser et déployer
ssh "$WIN_HOST" << 'EOF'
Expand-Archive -Path C:/Temp/${APP_NAME}-${APP_VERSION}.zip -DestinationPath ${WIN_DEPLOY_PATH}
Remove-Item C:/Temp/${APP_NAME}-${APP_VERSION}.zip
EOF

# 5. Démarrer l'application
ssh "$WIN_HOST" "Start-Service ${APP_NAME}"

# 6. Vérifier le déploiement
sleep 5
STATUS=$(ssh "$WIN_HOST" "Get-Service ${APP_NAME} | Select-Object -ExpandProperty Status")

if [ "$STATUS" == "Running" ]; then
    echo "✓ Déploiement réussi"
else
    echo "✗ Échec du déploiement" >&2
    exit 1
fi
```

---

## 🎓 Points clés à retenir

> [!tip] Synthèse
> 
> **Configuration serveur Windows :**
> 
> - OpenSSH Server s'installe facilement via PowerShell ou l'interface graphique
> - Le fichier `sshd_config` contrôle tous les paramètres de sécurité et comportement
> - Les administrateurs Windows ont un fichier de clés séparé : `administrators_authorized_keys`
> - Les permissions du fichier de clés sont critiques pour la sécurité
> 
> **Authentification depuis Linux :**
> 
> - Privilégier l'authentification par clé publique (plus sécurisée)
> - ED25519 est recommandé pour sa sécurité et rapidité
> - Le fichier `~/.ssh/config` simplifie grandement les connexions répétées
> 
> **Exécution de commandes PowerShell :**
> 
> - Échapper correctement les chemins Windows (backslash ou guillemets simples)
> - Attention à la politique d'exécution PowerShell (`-ExecutionPolicy Bypass`)
> - PowerShell comme shell par défaut améliore l'expérience
> 
> **Transfert de fichiers :**
> 
> - SCP pour des transferts simples et scripts automatisés
> - SFTP pour des sessions interactives et manipulations de fichiers
> - Toujours vérifier l'intégrité des transferts critiques (checksums)
> - Les permissions POSIX ne se traduisent pas parfaitement en ACL Windows
> 
> **Sécurité :**
> 
> - Désactiver l'authentification par mot de passe en production
> - Changer le port SSH par défaut pour réduire les scans automatisés
> - Limiter les utilisateurs autorisés avec `AllowUsers`
> - Surveiller régulièrement les logs SSH
> 
> **Performance :**
> 
> - Utiliser le multiplexing SSH pour réutiliser les connexions
> - Activer la compression pour les fichiers texte
> - Paralléliser les transferts de fichiers multiples