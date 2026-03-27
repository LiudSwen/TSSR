

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

Le transfert de fichiers sécurisé est une fonctionnalité essentielle de SSH. Windows, depuis l'intégration native d'OpenSSH, offre plusieurs méthodes pour transférer des fichiers de manière sécurisée entre machines. Cette section explore les différentes approches disponibles, du terminal aux interfaces graphiques, en passant par l'automatisation.

> [!info] Contexte Depuis Windows 10 (version 1809) et Windows Server 2019, OpenSSH est disponible nativement, incluant les outils `scp` et `sftp`. Plus besoin d'outils tiers pour les transferts de base !

---

## SCP avec OpenSSH Windows

### Qu'est-ce que SCP ?

**SCP (Secure Copy Protocol)** est un outil en ligne de commande permettant de copier des fichiers entre machines via SSH. Il utilise le même mécanisme d'authentification et de chiffrement que SSH.

> [!tip] Quand utiliser SCP ?
> 
> - Transferts ponctuels de fichiers ou dossiers
> - Scripts simples nécessitant une seule commande
> - Environnements où la simplicité prime sur la flexibilité

### Syntaxe de base

```bash
# Syntaxe générale
scp [options] source destination

# Upload : local → distant
scp fichier.txt user@serveur:/chemin/destination/

# Download : distant → local
scp user@serveur:/chemin/fichier.txt C:\destination\

# Copie récursive (dossiers)
scp -r dossier/ user@serveur:/chemin/
```

### Exemples pratiques

```bash
# Copier un fichier vers un serveur distant
scp C:\Users\Jean\document.pdf admin@192.168.1.100:/home/admin/documents/

# Télécharger un fichier depuis un serveur
scp admin@serveur.exemple.com:/var/log/app.log C:\Logs\

# Copier un dossier complet (récursif)
scp -r C:\Projets\MonApp admin@serveur:/opt/applications/

# Utiliser un port SSH non-standard
scp -P 2222 fichier.txt admin@serveur:/tmp/

# Préserver les métadonnées (timestamps, permissions)
scp -p config.ini admin@serveur:/etc/app/

# Mode verbeux pour le débogage
scp -v fichier.log admin@serveur:/var/log/
```

### Options importantes

|Option|Description|Exemple|
|---|---|---|
|`-r`|Copie récursive (dossiers)|`scp -r dossier/ user@host:/path/`|
|`-P`|Spécifier le port SSH|`scp -P 2222 file.txt user@host:/`|
|`-p`|Préserver les métadonnées|`scp -p file.txt user@host:/`|
|`-v`|Mode verbeux (débogage)|`scp -v file.txt user@host:/`|
|`-C`|Activer la compression|`scp -C bigfile.zip user@host:/`|
|`-i`|Utiliser une clé privée spécifique|`scp -i C:\keys\id_rsa file.txt user@host:/`|
|`-l`|Limiter la bande passante (Kbit/s)|`scp -l 1000 file.txt user@host:/`|

### Gestion des chemins Windows

> [!warning] Attention aux backslashes ! Windows utilise `\` pour les chemins, mais dans les commandes shell, utilisez `/` ou échappez les backslashes avec `\\`.

```bash
# ✅ Recommandé : utiliser des slashes
scp C:/Users/Jean/document.txt admin@serveur:/home/admin/

# ✅ Alternative : guillemets avec backslashes
scp "C:\Users\Jean\document.txt" admin@serveur:/home/admin/

# ❌ Éviter : backslashes non échappés sans guillemets
scp C:\Users\Jean\document.txt admin@serveur:/home/admin/
```

### Utilisation avec des clés SSH

```bash
# Spécifier une clé privée
scp -i C:\Users\Jean\.ssh\id_rsa_serveur fichier.txt admin@serveur:/tmp/

# Avec agent SSH actif (clé déjà chargée)
scp fichier.txt admin@serveur:/tmp/

# Désactiver l'agent SSH et forcer la clé
scp -o "IdentitiesOnly=yes" -i C:\keys\ma_cle fichier.txt admin@serveur:/tmp/
```

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> - **Permission denied** : Vérifiez les droits d'écriture sur la destination
> - **No such file or directory** : Vérifiez que le chemin distant existe
> - **Connection refused** : Le serveur SSH doit être actif (port 22 par défaut)
> - **Host key verification failed** : Ajoutez l'hôte aux known_hosts ou utilisez `-o StrictHostKeyChecking=no` (déconseillé en production)

```bash
# Ignorer la vérification de clé d'hôte (développement uniquement)
scp -o StrictHostKeyChecking=no fichier.txt user@serveur:/tmp/

# Ajouter manuellement l'hôte aux known_hosts
ssh-keyscan serveur.exemple.com >> C:\Users\Jean\.ssh\known_hosts
```

### Bonnes pratiques

> [!tip] Astuces SCP
> 
> - Utilisez `-C` pour les gros fichiers non compressés (logs, texte)
> - Combinez `-r` et `-p` pour préserver la structure complète : `scp -rp`
> - Limitez la bande passante avec `-l` pour éviter de saturer le réseau
> - Utilisez des chemins absolus pour éviter les ambiguïtés
> - Testez d'abord avec `-v` en cas de problème

---

## SFTP natif Windows

### Qu'est-ce que SFTP ?

**SFTP (SSH File Transfer Protocol)** est un protocole interactif de transfert de fichiers via SSH. Contrairement à SCP, SFTP offre une session interactive permettant de naviguer, lister, renommer, et gérer les fichiers.

> [!info] SFTP vs SCP
> 
> - **SCP** : Simple, rapide, une seule commande → transfert immédiat
> - **SFTP** : Interactif, flexible, session persistante → manipulation avancée de fichiers

### Lancer une session SFTP

```bash
# Connexion SFTP de base
sftp user@serveur

# Avec port personnalisé
sftp -P 2222 user@serveur

# Avec clé SSH spécifique
sftp -i C:\Users\Jean\.ssh\id_rsa user@serveur

# Connexion directe à un répertoire
sftp user@serveur:/chemin/vers/dossier
```

### Commandes SFTP essentielles

#### Navigation et exploration

```bash
# Afficher le répertoire distant actuel
pwd

# Lister les fichiers distants
ls
ls -la  # Liste détaillée

# Changer de répertoire distant
cd /var/www/html
cd ..  # Remonter d'un niveau

# Afficher le répertoire local actuel
lpwd

# Lister les fichiers locaux
lls
lls -la

# Changer de répertoire local
lcd C:\Downloads
```

#### Transfert de fichiers

```bash
# Upload : local → distant
put fichier.txt
put fichier.txt nouveau_nom.txt  # Renommer pendant le transfert
put -r dossier/  # Upload récursif

# Download : distant → local
get fichier.txt
get fichier.txt nouveau_nom.txt
get -r dossier/  # Download récursif

# Upload multiple (wildcards)
mput *.log
mput *.txt *.csv

# Download multiple
mget *.pdf
```

#### Gestion des fichiers distants

```bash
# Créer un répertoire distant
mkdir nouveau_dossier

# Supprimer un fichier distant
rm fichier.txt

# Supprimer un répertoire distant (vide)
rmdir dossier_vide

# Renommer un fichier distant
rename ancien_nom.txt nouveau_nom.txt

# Changer les permissions distantes (chmod)
chmod 644 fichier.txt
chmod 755 script.sh
```

#### Gestion des fichiers locaux

```bash
# Créer un répertoire local
lmkdir C:\nouveau_dossier

# Supprimer un fichier local
!del fichier.txt  # Windows
!rm fichier.txt   # Si WSL ou Git Bash

# Exécuter une commande locale
!dir              # Windows
!ls -la           # WSL/Git Bash
```

### Session SFTP interactive complète

```bash
# Connexion
PS C:\Users\Jean> sftp admin@192.168.1.100
Connected to 192.168.1.100.
sftp> 

# Vérifier où on est (distant)
sftp> pwd
Remote working directory: /home/admin

# Vérifier où on est (local)
sftp> lpwd
Local working directory: C:\Users\Jean

# Naviguer côté distant
sftp> cd /var/www/html
sftp> ls
index.html    style.css    app.js    images/

# Télécharger un fichier
sftp> get index.html
Fetching /var/www/html/index.html to index.html
index.html                                    100% 2048    1.5MB/s   00:00

# Changer le dossier local de destination
sftp> lcd C:\Websites\backup
sftp> lpwd
Local working directory: C:\Websites\backup

# Télécharger tout un dossier
sftp> get -r images/
Fetching /var/www/html/images/ to images
Retrieving /var/www/html/images/

# Upload un nouveau fichier
sftp> put C:\Dev\newfile.js
Uploading C:\Dev\newfile.js to /var/www/html/newfile.js
newfile.js                                    100% 1024    800KB/s   00:00

# Quitter
sftp> bye
PS C:\Users\Jean>
```

### Mode batch (non-interactif)

```bash
# Exécuter une série de commandes via un fichier
echo put fichier.txt > commandes.txt
echo get backup.zip >> commandes.txt
echo bye >> commandes.txt

sftp -b commandes.txt admin@serveur

# Exécuter des commandes directement
echo "put fichier.txt" | sftp admin@serveur

# Avec plusieurs commandes
(echo "cd /var/www"; echo "put index.html"; echo "bye") | sftp admin@serveur
```

### Options SFTP importantes

|Option|Description|Exemple|
|---|---|---|
|`-P`|Port SSH personnalisé|`sftp -P 2222 user@host`|
|`-i`|Clé privée spécifique|`sftp -i ~/.ssh/id_rsa user@host`|
|`-b`|Fichier de commandes batch|`sftp -b script.txt user@host`|
|`-C`|Activer la compression|`sftp -C user@host`|
|`-v`|Mode verbeux|`sftp -v user@host`|
|`-r`|Transfert récursif (avec get/put)|`get -r dossier/`|

### Bonnes pratiques SFTP

> [!tip] Astuces SFTP
> 
> - Utilisez `lcd` avant les uploads pour être dans le bon répertoire local
> - Utilisez `cd` avant les downloads pour cibler le bon répertoire distant
> - Vérifiez avec `ls` et `lls` avant les transferts massifs
> - Préférez `-r` pour les dossiers plutôt que des `mget`/`mput` complexes
> - Utilisez le mode batch pour automatiser des transferts répétitifs

> [!warning] Pièges à éviter
> 
> - **Ne pas confondre** les commandes locales (`lpwd`, `lcd`) et distantes (`pwd`, `cd`)
> - Les wildcards (`*.txt`) fonctionnent avec `mget`/`mput`, pas avec `get`/`put` simple
> - `rmdir` ne supprime que les dossiers vides, utilisez `rm -r` pour un dossier complet
> - Les permissions Windows et Unix sont différentes, `chmod` peut ne pas avoir l'effet attendu

---

## Clients graphiques

### Pourquoi utiliser un client graphique ?

Les clients graphiques offrent une interface visuelle intuitive pour gérer les transferts de fichiers SSH, idéale pour les utilisateurs préférant éviter la ligne de commande ou pour des opérations complexes de synchronisation.

> [!info] Avantages
> 
> - Interface drag-and-drop intuitive
> - Visualisation simultanée des fichiers locaux et distants
> - Gestion visuelle des permissions et métadonnées
> - Synchronisation de dossiers
> - Éditeur de fichiers intégré
> - Gestion de multiples connexions

### WinSCP

**WinSCP** est le client graphique SFTP/SCP le plus populaire sous Windows, gratuit et open-source.

#### Installation

```powershell
# Via winget (Windows Package Manager)
winget install WinSCP.WinSCP

# Via Chocolatey
choco install winscp

# Téléchargement manuel : https://winscp.net
```

#### Fonctionnalités principales

|Fonctionnalité|Description|
|---|---|
|**Interface double panneau**|Fichiers locaux à gauche, distants à droite|
|**Drag & drop**|Glisser-déposer pour transférer|
|**Synchronisation**|Synchroniser automatiquement des dossiers|
|**Éditeur intégré**|Modifier des fichiers directement sur le serveur|
|**Gestion des permissions**|Interface visuelle pour chmod|
|**Automatisation**|Scripting avec ligne de commande WinSCP|
|**Protocoles supportés**|SFTP, SCP, FTP, FTPS, WebDAV, S3|

#### Configuration d'une connexion SFTP

```
1. Lancer WinSCP
2. Cliquer sur "Nouvelle session"
3. Remplir les paramètres :
   - Protocole de fichier : SFTP
   - Nom d'hôte : serveur.exemple.com
   - Port : 22
   - Nom d'utilisateur : admin
   - Mot de passe : (ou utiliser une clé SSH)
4. Cliquer sur "Avancé..." pour :
   - Spécifier une clé privée (Authentification SSH)
   - Configurer le répertoire de démarrage
   - Définir des options de transfert
5. Cliquer sur "Connexion"
```

#### Utilisation de clés SSH avec WinSCP

> [!warning] Format de clé WinSCP utilise le format PuTTY (.ppk) pour les clés privées. Si vous avez une clé OpenSSH, convertissez-la avec PuTTYgen.

```
Conversion d'une clé OpenSSH vers PPK :
1. Ouvrir PuTTYgen (inclus avec WinSCP)
2. Conversions → Import key
3. Sélectionner votre clé OpenSSH (id_rsa)
4. Save private key → Enregistrer en .ppk
5. Dans WinSCP : Avancé → SSH → Authentification → Fichier de clé privée → Sélectionner le .ppk
```

#### Synchronisation de dossiers

```
1. Connectez-vous au serveur distant
2. Commandes → Synchroniser...
3. Choisir le mode :
   - Local → Distant : Pousser les modifications locales
   - Distant → Local : Récupérer les modifications distantes
   - Les deux sens : Synchronisation bidirectionnelle
4. Options utiles :
   - Supprimer les fichiers : Effacer les fichiers absents de l'autre côté
   - Fichiers existants uniquement : Ne traiter que les fichiers modifiés
   - Aperçu : Afficher les modifications avant validation
5. Démarrer
```

#### Scripting WinSCP (automatisation)

```batch
# Script batch Windows pour automatisation
@echo off

"C:\Program Files (x86)\WinSCP\WinSCP.com" ^
  /command ^
    "open sftp://admin:password@serveur.com/" ^
    "put C:\Backup\*.zip /home/admin/backups/" ^
    "exit"

pause
```

```powershell
# Script PowerShell avec WinSCP .NET Assembly
# Charger l'assembly WinSCP
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Configuration de la session
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = "serveur.com"
    UserName = "admin"
    SshHostKeyFingerprint = "ssh-rsa 2048 xx:xx:xx:..."
    SshPrivateKeyPath = "C:\Users\Jean\.ssh\id_rsa.ppk"
}

$session = New-Object WinSCP.Session

try {
    # Connexion
    $session.Open($sessionOptions)
    
    # Upload
    $session.PutFiles("C:\Backup\*.zip", "/home/admin/backups/").Check()
    
    Write-Host "Transfert réussi !"
}
finally {
    # Déconnexion
    $session.Dispose()
}
```

### FileZilla

**FileZilla** est un client FTP/SFTP gratuit et multiplateforme, très populaire.

#### Installation

```powershell
# Via winget
winget install FileZilla.FileZilla

# Via Chocolatey
choco install filezilla

# Téléchargement manuel : https://filezilla-project.org
```

#### Connexion SFTP rapide

```
1. Lancer FileZilla
2. En haut de l'interface (Quick Connect) :
   - Hôte : sftp://serveur.exemple.com
   - Identifiant : admin
   - Mot de passe : ********
   - Port : 22
3. Cliquer sur "Connexion rapide"
```

#### Gestionnaire de sites

```
Pour enregistrer des connexions :
1. Fichier → Gestionnaire de sites
2. Nouveau site
3. Paramètres :
   - Protocole : SFTP
   - Hôte : serveur.exemple.com
   - Port : 22
   - Type d'authentification : Fichier de clés ou Mot de passe
   - Identifiant : admin
4. Onglet "Avancé" :
   - Répertoire distant par défaut : /var/www
   - Répertoire local par défaut : C:\Projets
5. OK → Connexion
```

#### Utilisation de clés SSH

```
1. Édition → Paramètres → SFTP
2. Ajouter un fichier de clé...
3. Sélectionner votre clé privée OpenSSH (id_rsa)
   FileZilla convertira automatiquement au format PuTTY si nécessaire
4. OK
5. La clé sera utilisée automatiquement pour les connexions SFTP
```

#### Fonctionnalités utiles

|Fonctionnalité|Description|
|---|---|
|**File de transfert**|Visualiser et gérer les transferts en cours/en attente|
|**Transferts simultanés**|Configurer le nombre de transferts parallèles|
|**Filtres de fichiers**|Ignorer certains types de fichiers (.git, node_modules)|
|**Comparaison de dossiers**|Identifier les différences entre local et distant|
|**Édition de fichiers**|Ouvrir et modifier des fichiers distants|
|**Recherche de fichiers**|Rechercher dans les répertoires distants|

### Comparaison des clients

|Critère|WinSCP|FileZilla|
|---|---|---|
|**Interface**|Explorateur Windows-like|Panneau quadruple (local/distant/queue)|
|**Protocoles**|SFTP, SCP, FTP, FTPS, WebDAV, S3|FTP, FTPS, SFTP|
|**Synchronisation**|✅ Excellente, bidirectionnelle|⚠️ Basique|
|**Scripting**|✅ Ligne de commande + .NET API|❌ Non|
|**Éditeur intégré**|✅ Oui|✅ Oui (externe)|
|**Format de clés**|PuTTY (.ppk)|OpenSSH (conversion auto)|
|**Courbe d'apprentissage**|Moyenne|Facile|
|**Meilleur pour**|Automatisation, synchronisation|Transferts FTP/SFTP simples|

> [!tip] Quel client choisir ?
> 
> - **WinSCP** : Pour l'automatisation, la synchronisation avancée, et si vous êtes habitué à l'Explorateur Windows
> - **FileZilla** : Pour des transferts simples FTP/SFTP avec une interface claire et des transferts parallèles

### Autres alternatives

- **Bitvise SSH Client** : Client SSH/SFTP complet avec terminal intégré
- **MobaXterm** : Suite complète avec terminal, X11, SFTP, et outils réseau
- **Cyberduck** : Client cloud/SFTP élégant supportant de nombreux protocoles

---

## Automatisation avec PowerShell

### Pourquoi automatiser avec PowerShell ?

PowerShell permet d'intégrer les transferts SSH dans des workflows automatisés, des scripts planifiés, ou des pipelines CI/CD. C'est la solution native pour l'automatisation sous Windows.

> [!info] Cas d'usage
> 
> - Sauvegardes automatiques vers un serveur distant
> - Déploiement automatisé d'applications
> - Synchronisation planifiée de fichiers
> - Scripts de maintenance système
> - Intégration dans des tâches planifiées Windows

### Utilisation basique de SCP en PowerShell

```powershell
# SCP simple - Upload
scp C:\Backup\database.sql admin@serveur:/backups/

# SCP simple - Download
scp admin@serveur:/var/log/app.log C:\Logs\

# SCP récursif
scp -r C:\Projets\MonApp admin@serveur:/opt/applications/

# Variables PowerShell
$serveur = "192.168.1.100"
$user = "admin"
$fichier = "C:\Data\export.csv"
$destination = "/home/admin/imports/"

scp "$fichier" "${user}@${serveur}:${destination}"
```

### Utilisation de SFTP en PowerShell

```powershell
# Créer un script de commandes SFTP
$commandesSFTP = @"
cd /var/www/html
put C:\Websites\index.html
put C:\Websites\style.css
chmod 644 index.html
chmod 644 style.css
bye
"@

# Sauvegarder dans un fichier temporaire
$scriptFile = "C:\Temp\sftp_script.txt"
$commandesSFTP | Out-File -FilePath $scriptFile -Encoding ASCII

# Exécuter les commandes SFTP
sftp -b $scriptFile admin@serveur

# Nettoyer
Remove-Item $scriptFile
```

### Fonction PowerShell réutilisable pour SCP

```powershell
function Send-SCPFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$LocalPath,
        
        [Parameter(Mandatory=$true)]
        [string]$RemoteHost,
        
        [Parameter(Mandatory=$true)]
        [string]$RemotePath,
        
        [Parameter(Mandatory=$true)]
        [string]$Username,
        
        [string]$KeyPath,
        
        [int]$Port = 22,
        
        [switch]$Recursive
    )
    
    # Construction de la commande SCP
    $scpArgs = @()
    
    if ($Port -ne 22) {
        $scpArgs += "-P", $Port
    }
    
    if ($KeyPath) {
        $scpArgs += "-i", $KeyPath
    }
    
    if ($Recursive) {
        $scpArgs += "-r"
    }
    
    $scpArgs += $LocalPath
    $scpArgs += "${Username}@${RemoteHost}:${RemotePath}"
    
    # Exécution
    Write-Verbose "Exécution : scp $($scpArgs -join ' ')"
    
    try {
        & scp @scpArgs
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Transfert réussi : $LocalPath → ${RemoteHost}:${RemotePath}" -ForegroundColor Green
            return $true
        } else {
            Write-Error "❌ Échec du transfert (Code: $LASTEXITCODE)"
            return $false
        }
    }
    catch {
        Write-Error "❌ Erreur : $($_.Exception.Message)"
        return $false
    }
}

# Utilisation
Send-SCPFile -LocalPath "C:\Backup\db.sql" `
             -RemoteHost "serveur.com" `
             -RemotePath "/backups/" `
             -Username "admin" `
             -KeyPath "C:\Users\Jean\.ssh\id_rsa"

# Avec récursion
Send-SCPFile -LocalPath "C:\Projets\MonApp" `
             -RemoteHost "192.168.1.100" `
             -RemotePath "/opt/apps/" `
             -Username "deploy" `
             -Recursive
```

### Fonction PowerShell pour SFTP batch

```powershell
function Invoke-SFTPBatch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$RemoteHost,
        
        [Parameter(Mandatory=$true)]
        [string]$Username,
        
        [Parameter(Mandatory=$true)]
        [string[]]$Commands,
        
        [string]$KeyPath,
        
        [int]$Port = 22
    )
    
    # Créer un fichier temporaire pour les commandes
    $tempFile = [System.IO.Path]::GetTempFileName()
    
    try {
        # Écrire les commandes dans le fichier
        $Commands | Out-File -FilePath $tempFile -Encoding ASCII
        
        # Construction de la commande SFTP
        $sftpArgs = @("-b", $tempFile)
        
        if ($Port -ne 22) {
            $sftpArgs += "-P", $Port
        }
        
        if ($KeyPath) {
            $sftpArgs += "-i", $KeyPath
        }
        
        $sftpArgs += "${Username}@${RemoteHost}"
        
        Write-Verbose "Exécution : sftp $($sftpArgs -join ' ')"
        Write-Verbose "Commandes :`n$($Commands -join "`n")"
        
        # Exécution
        & sftp @sftpArgs
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Commandes SFTP exécutées avec succès" -ForegroundColor Green
            return $true
        } else {
            Write-Error "❌ Échec SFTP (Code: $LASTEXITCODE)"
            return $false
        }
    }
    catch {
        Write-Error "❌ Erreur : $($_.Exception.Message)"
        return $false
    }
    finally {
        # Nettoyer le fichier temporaire
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }
    }
}

# Utilisation
$commandes = @(
    "cd /var/www/html",
    "put C:\Websites\index.html",
    "put C:\Websites\app.js",
    "chmod 644 index.html",
    "chmod 644 app.js",
    "bye"
)

Invoke-SFTPBatch -RemoteHost "serveur.com" `
                 -Username "admin" `
                 -Commands $commandes `
                 -KeyPath "C:\Users\Jean\.ssh\id_rsa"
```

### Script de sauvegarde automatisé

```powershell
<#
.SYNOPSIS
    Script de sauvegarde automatique vers serveur distant via SCP
.DESCRIPTION
    Compresse un dossier, le transfère via SCP, et nettoie les anciennes sauvegardes
#>

param(
    [string]$SourcePath = "C:\Important\Data",
    [string]$RemoteHost = "backup.serveur.com",
    [string]$RemoteUser = "backup",
    [string]$RemotePath = "/backups/windows",
    [string]$KeyPath = "C:\Keys\backup_key",
    [int]$RetentionDays = 7
)

# Configuration
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupName = "backup_$timestamp.zip"
$tempBackupPath = "$env:TEMP\$backupName"

try {
    Write-Host "🗜️ Compression de $SourcePath..." -ForegroundColor Cyan
    
    # Compression
    Compress-Archive -Path $SourcePath `
                     -DestinationPath $tempBackupPath `
                     -CompressionLevel Optimal `
                     -Force
    
    $backupSize = (Get-Item $tempBackupPath).Length / 1MB
    Write-Host "✅ Archive créée : $backupName ($([math]::Round($backupSize, 2)) MB)" -ForegroundColor Green
    
    # Transfert SCP
    Write-Host "📤 Transfert vers $RemoteHost..." -ForegroundColor Cyan
    
    $scpArgs = @("-i", $KeyPath, $tempBackupPath, "${RemoteUser}@${RemoteHost}:${RemotePath}/")
    & scp @scpArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Sauvegarde transférée avec succès !" -ForegroundColor Green
    } else {
        throw "Échec du transfert SCP (Code: $LASTEXITCODE)"
    }
    
    # Nettoyage des anciennes sauvegardes distantes
    Write-Host "🧹 Nettoyage des sauvegardes de plus de $RetentionDays jours..." -ForegroundColor Cyan
    
    $cleanupCommand = "find $RemotePath -name 'backup_*.zip' -mtime +$RetentionDays -delete"
    ssh -i $KeyPath "${RemoteUser}@${RemoteHost}" $cleanupCommand
    
    Write-Host "✅ Script de sauvegarde terminé !" -ForegroundColor Green
    
} catch {
    Write-Error "❌ Erreur durant la sauvegarde : $($_.Exception.Message)"
    exit 1
} finally {
    # Nettoyer le fichier temporaire local
    if (Test-Path $tempBackupPath) {
        Remove-Item $tempBackupPath -Force
        Write-Host "🧹 Fichier temporaire supprimé" -ForegroundColor Gray
    }
}
```

### Utilisation avec le module Posh-SSH

Le module **Posh-SSH** offre une alternative PowerShell native plus riche que les commandes OpenSSH.

#### Installation de Posh-SSH

```powershell
# Installation (nécessite PowerShell 5.1+)
Install-Module -Name Posh-SSH -Scope CurrentUser -Force

# Vérification
Get-Module -ListAvailable Posh-SSH

# Import
Import-Module Posh-SSH
```

#### Connexion SFTP avec Posh-SSH

```powershell
# Import du module
Import-Module Posh-SSH

# Créer un objet d'identification (avec mot de passe)
$password = ConvertTo-SecureString "MonMotDePasse" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("admin", $password)

# Établir une session SFTP
$session = New-SFTPSession -ComputerName "serveur.com" -Credential $credential

# Vérifier la connexion
if ($session.Connected) {
    Write-Host "✅ Connecté à $($session.Host)" -ForegroundColor Green
}
```

#### Connexion avec clé SSH

```powershell
# Créer un objet d'identification avec clé privée
$keyFile = "C:\Users\Jean\.ssh\id_rsa"
$credential = New-Object System.Management.Automation.PSCredential ("admin", (New-Object System.Security.SecureString))

# Session SFTP avec clé
$session = New-SFTPSession -ComputerName "serveur.com" `
                           -Credential $credential `
                           -KeyFile $keyFile `
                           -AcceptKey

Write-Host "SessionId: $($session.SessionId)"
```

#### Opérations SFTP avec Posh-SSH

```powershell
# Lister les fichiers distants
Get-SFTPChildItem -SessionId $session.SessionId -Path "/var/www/html"

# Upload un fichier
Set-SFTPItem -SessionId $session.SessionId `
             -Path "C:\Websites\index.html" `
             -Destination "/var/www/html/"

# Download un fichier
Get-SFTPItem -SessionId $session.SessionId `
             -Path "/var/log/app.log" `
             -Destination "C:\Logs\"

# Upload récursif (dossier)
Set-SFTPItem -SessionId $session.SessionId `
             -Path "C:\Projets\MonApp" `
             -Destination "/opt/applications/" `
             -Recurse

# Créer un répertoire distant
New-SFTPItem -SessionId $session.SessionId `
             -Path "/backups/2024" `
             -ItemType Directory

# Renommer un fichier distant
Rename-SFTPFile -SessionId $session.SessionId `
                -Path "/tmp/old_name.txt" `
                -NewName "new_name.txt"

# Supprimer un fichier distant
Remove-SFTPItem -SessionId $session.SessionId `
                -Path "/tmp/file_to_delete.txt" `
                -Force

# Fermer la session
Remove-SFTPSession -SessionId $session.SessionId
```

#### Script complet avec Posh-SSH

```powershell
<#
.SYNOPSIS
    Synchronisation de fichiers avec Posh-SSH
#>

Import-Module Posh-SSH

# Configuration
$remoteHost = "serveur.com"
$username = "admin"
$keyFile = "C:\Users\Jean\.ssh\id_rsa"
$localPath = "C:\Websites"
$remotePath = "/var/www/html"

# Credential avec clé SSH
$credential = New-Object System.Management.Automation.PSCredential ($username, (New-Object System.Security.SecureString))

try {
    # Connexion SFTP
    Write-Host "📡 Connexion à $remoteHost..." -ForegroundColor Cyan
    $session = New-SFTPSession -ComputerName $remoteHost `
                               -Credential $credential `
                               -KeyFile $keyFile `
                               -AcceptKey
    
    Write-Host "✅ Connecté (Session ID: $($session.SessionId))" -ForegroundColor Green
    
    # Lister les fichiers locaux à synchroniser
    $localFiles = Get-ChildItem -Path $localPath -File
    
    foreach ($file in $localFiles) {
        Write-Host "📤 Upload : $($file.Name)..." -ForegroundColor Cyan
        
        Set-SFTPItem -SessionId $session.SessionId `
                     -Path $file.FullName `
                     -Destination $remotePath `
                     -Force
        
        Write-Host "  ✅ $($file.Name) transféré" -ForegroundColor Green
    }
    
    # Vérification des fichiers distants
    Write-Host "`n📋 Fichiers distants :" -ForegroundColor Cyan
    $remoteFiles = Get-SFTPChildItem -SessionId $session.SessionId -Path $remotePath
    $remoteFiles | ForEach-Object { Write-Host "  - $($_.Name)" }
    
    Write-Host "`n✅ Synchronisation terminée !" -ForegroundColor Green
    
} catch {
    Write-Error "❌ Erreur : $($_.Exception.Message)"
} finally {
    # Fermeture de la session
    if ($session) {
        Remove-SFTPSession -SessionId $session.SessionId
        Write-Host "🔌 Session fermée" -ForegroundColor Gray
    }
}
```

### Gestion des erreurs et logging

```powershell
function Write-TransferLog {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info",
        [string]$LogFile = "C:\Logs\sftp_transfers.log"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Affichage console avec couleur
    switch ($Level) {
        "Success" { Write-Host $logEntry -ForegroundColor Green }
        "Warning" { Write-Host $logEntry -ForegroundColor Yellow }
        "Error"   { Write-Host $logEntry -ForegroundColor Red }
        default   { Write-Host $logEntry }
    }
    
    # Écriture dans le fichier log
    Add-Content -Path $LogFile -Value $logEntry
}

function Send-FileWithRetry {
    param(
        [string]$LocalPath,
        [string]$RemoteHost,
        [string]$RemotePath,
        [string]$Username,
        [string]$KeyPath,
        [int]$MaxRetries = 3,
        [int]$RetryDelaySeconds = 5
    )
    
    $attempt = 0
    $success = $false
    
    while (-not $success -and $attempt -lt $MaxRetries) {
        $attempt++
        Write-TransferLog "Tentative $attempt/$MaxRetries : Transfer de $LocalPath" -Level Info
        
        try {
            $scpArgs = @("-i", $KeyPath, $LocalPath, "${Username}@${RemoteHost}:${RemotePath}")
            & scp @scpArgs 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                $success = $true
                Write-TransferLog "Transfert réussi : $LocalPath" -Level Success
            } else {
                throw "SCP a retourné le code : $LASTEXITCODE"
            }
        }
        catch {
            Write-TransferLog "Échec tentative $attempt : $($_.Exception.Message)" -Level Warning
            
            if ($attempt -lt $MaxRetries) {
                Write-TransferLog "Nouvelle tentative dans $RetryDelaySeconds secondes..." -Level Info
                Start-Sleep -Seconds $RetryDelaySeconds
            } else {
                Write-TransferLog "Échec définitif après $MaxRetries tentatives" -Level Error
                throw
            }
        }
    }
    
    return $success
}

# Utilisation
Send-FileWithRetry -LocalPath "C:\Data\important.db" `
                   -RemoteHost "backup.com" `
                   -RemotePath "/backups/" `
                   -Username "admin" `
                   -KeyPath "C:\Keys\backup_key" `
                   -MaxRetries 3
```

### Planification avec le Planificateur de tâches Windows

```powershell
# Créer une tâche planifiée pour exécuter un script de sauvegarde quotidien

# Définir l'action (script à exécuter)
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File C:\Scripts\backup_sftp.ps1"

# Définir le déclencheur (tous les jours à 2h du matin)
$trigger = New-ScheduledTaskTrigger -Daily -At "02:00"

# Définir les paramètres
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable `
                                         -RunOnlyIfNetworkAvailable `
                                         -WakeToRun

# Créer la tâche
Register-ScheduledTask -TaskName "Sauvegarde SFTP Quotidienne" `
                       -Action $action `
                       -Trigger $trigger `
                       -Settings $settings `
                       -Description "Sauvegarde automatique quotidienne via SFTP" `
                       -RunLevel Highest

Write-Host "✅ Tâche planifiée créée avec succès !" -ForegroundColor Green
```

### Surveillance et notifications

```powershell
function Send-EmailNotification {
    param(
        [string]$Subject,
        [string]$Body,
        [string]$To = "admin@exemple.com",
        [string]$SmtpServer = "smtp.exemple.com",
        [int]$SmtpPort = 587,
        [PSCredential]$Credential
    )
    
    $mailParams = @{
        To = $To
        From = "backup@exemple.com"
        Subject = $Subject
        Body = $Body
        SmtpServer = $SmtpServer
        Port = $SmtpPort
        UseSsl = $true
        Credential = $Credential
    }
    
    Send-MailMessage @mailParams
}

# Script de sauvegarde avec notification
try {
    $result = Send-FileWithRetry -LocalPath "C:\Data\backup.zip" `
                                  -RemoteHost "backup.com" `
                                  -RemotePath "/backups/" `
                                  -Username "admin" `
                                  -KeyPath "C:\Keys\backup_key"
    
    if ($result) {
        $subject = "✅ Sauvegarde réussie"
        $body = "La sauvegarde quotidienne a été transférée avec succès à $(Get-Date)"
    }
    
} catch {
    $subject = "❌ Échec de la sauvegarde"
    $body = "Erreur lors de la sauvegarde : $($_.Exception.Message)`n`nDate: $(Get-Date)"
}

# Envoyer la notification
$smtpCred = Get-Credential -Message "Identifiants SMTP"
Send-EmailNotification -Subject $subject -Body $body -Credential $smtpCred
```

### Bonnes pratiques d'automatisation

> [!tip] Recommandations PowerShell
> 
> - **Utilisez des variables d'environnement** pour les informations sensibles ou les chemins
> - **Centralisez la configuration** dans un fichier JSON ou XML externe
> - **Implémentez un système de logging** pour tracer toutes les opérations
> - **Ajoutez des mécanismes de retry** pour gérer les problèmes réseau temporaires
> - **Validez les résultats** avec `$LASTEXITCODE` pour détecter les échecs silencieux
> - **Sécurisez les credentials** avec `ConvertTo-SecureString` ou Windows Credential Manager
> - **Testez les connexions** avant les opérations critiques
> - **Nettoyez les fichiers temporaires** dans un bloc `finally`

### Fichier de configuration externe

```powershell
# config.json
{
    "RemoteHost": "backup.serveur.com",
    "Username": "backup",
    "KeyPath": "C:\\Keys\\backup_key",
    "RemotePath": "/backups/windows",
    "SourcePaths": [
        "C:\\Important\\Data",
        "C:\\Databases",
        "C:\\Websites"
    ],
    "RetentionDays": 7,
    "EmailNotifications": true,
    "EmailTo": "admin@exemple.com"
}
```

```powershell
# Charger la configuration
$config = Get-Content "C:\Scripts\config.json" | ConvertFrom-Json

# Utiliser la configuration
foreach ($sourcePath in $config.SourcePaths) {
    Write-Host "Sauvegarde de $sourcePath..." -ForegroundColor Cyan
    
    # Compression et transfert
    $backupName = "backup_$(Split-Path $sourcePath -Leaf)_$(Get-Date -Format 'yyyyMMdd').zip"
    $tempPath = "$env:TEMP\$backupName"
    
    Compress-Archive -Path $sourcePath -DestinationPath $tempPath -Force
    
    scp -i $config.KeyPath $tempPath "$($config.Username)@$($config.RemoteHost):$($config.RemotePath)/"
    
    Remove-Item $tempPath -Force
}
```

### Utilisation de Windows Credential Manager

```powershell
# Stocker un credential de manière sécurisée
$credential = Get-Credential -Message "Identifiants SSH"
$credential | Export-Clixml -Path "C:\Secure\ssh_cred.xml"

# Récupérer le credential
$credential = Import-Clixml -Path "C:\Secure\ssh_cred.xml"
$username = $credential.UserName
$password = $credential.GetNetworkCredential().Password

# Utiliser avec Posh-SSH
$session = New-SFTPSession -ComputerName "serveur.com" -Credential $credential
```

### Exemple complet : Pipeline de déploiement

```powershell
<#
.SYNOPSIS
    Pipeline de déploiement automatisé via SFTP
.DESCRIPTION
    Build, test et déploie une application web vers un serveur distant
#>

param(
    [string]$Environment = "production",
    [string]$Version
)

# Configuration
$config = @{
    production = @{
        Host = "prod.serveur.com"
        Path = "/var/www/production"
        User = "deploy"
        Key = "C:\Keys\deploy_prod"
    }
    staging = @{
        Host = "staging.serveur.com"
        Path = "/var/www/staging"
        User = "deploy"
        Key = "C:\Keys\deploy_staging"
    }
}

$envConfig = $config[$Environment]
$buildPath = "C:\Projects\MonApp\build"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

try {
    Write-Host "🏗️ ÉTAPE 1/4 : Build de l'application..." -ForegroundColor Cyan
    # Simuler un build (remplacer par votre processus réel)
    # npm run build
    # dotnet publish
    Write-Host "✅ Build terminé" -ForegroundColor Green
    
    Write-Host "`n🧪 ÉTAPE 2/4 : Tests..." -ForegroundColor Cyan
    # Exécuter les tests
    # npm test
    Write-Host "✅ Tests passés" -ForegroundColor Green
    
    Write-Host "`n📦 ÉTAPE 3/4 : Préparation du package..." -ForegroundColor Cyan
    $packageName = "deploy_${Version}_${timestamp}.zip"
    $packagePath = "$env:TEMP\$packageName"
    
    Compress-Archive -Path "$buildPath\*" -DestinationPath $packagePath -Force
    $packageSize = (Get-Item $packagePath).Length / 1MB
    Write-Host "✅ Package créé : $packageName ($([math]::Round($packageSize, 2)) MB)" -ForegroundColor Green
    
    Write-Host "`n🚀 ÉTAPE 4/4 : Déploiement vers $Environment..." -ForegroundColor Cyan
    
    # Backup de la version actuelle sur le serveur
    $backupCmd = "cd $($envConfig.Path) && tar -czf backup_${timestamp}.tar.gz * 2>/dev/null || true"
    ssh -i $envConfig.Key "$($envConfig.User)@$($envConfig.Host)" $backupCmd
    
    # Transfert du nouveau package
    scp -i $envConfig.Key $packagePath "$($envConfig.User)@$($envConfig.Host):$($envConfig.Path)/"
    
    # Décompression et activation
    $deployCmd = @"
cd $($envConfig.Path) && \
unzip -o $packageName && \
rm $packageName && \
echo "Déployé : Version $Version - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" > .deploy_info
"@
    
    ssh -i $envConfig.Key "$($envConfig.User)@$($envConfig.Host)" $deployCmd
    
    Write-Host "✅ Déploiement terminé avec succès !" -ForegroundColor Green
    Write-Host "🌐 Application disponible sur : https://$($envConfig.Host)" -ForegroundColor Cyan
    
} catch {
    Write-Error "❌ Échec du déploiement : $($_.Exception.Message)"
    exit 1
} finally {
    # Nettoyage
    if (Test-Path $packagePath) {
        Remove-Item $packagePath -Force
    }
}
```

### Comparaison : OpenSSH natif vs Posh-SSH

|Critère|OpenSSH (scp/sftp)|Posh-SSH|
|---|---|---|
|**Installation**|Natif Windows 10+|Module PowerShell à installer|
|**Syntaxe**|Commandes shell classiques|Cmdlets PowerShell|
|**Gestion des erreurs**|`$LASTEXITCODE`|Try/Catch natif|
|**Sessions persistantes**|Non (nouveau process à chaque fois)|Oui (objets de session)|
|**Intégration PowerShell**|Moyenne|Excellente|
|**Performance**|Légèrement plus rapide|Comparable|
|**Courbe d'apprentissage**|Familier si vous connaissez Linux|PowerShell-friendly|
|**Fonctionnalités avancées**|Limitées|Nombreuses (cmdlets dédiés)|
|**Meilleur pour**|Scripts simples, compatibilité|Scripts complexes, pipelines PowerShell|

> [!tip] Quel outil choisir ?
> 
> - **OpenSSH natif** : Pour des scripts simples, une compatibilité maximale, ou si vous êtes déjà familier avec scp/sftp
> - **Posh-SSH** : Pour des workflows complexes, une meilleure gestion d'erreurs, et une intégration profonde avec PowerShell

---

## 🎯 Récapitulatif

### Points clés à retenir

> [!info] SCP
> 
> - Outil simple pour transferts ponctuels : une commande = un transfert
> - Syntaxe : `scp [options] source destination`
> - Options essentielles : `-r` (récursif), `-P` (port), `-i` (clé SSH)
> - Idéal pour scripts basiques et transferts rapides

> [!info] SFTP
> 
> - Session interactive pour manipulations avancées de fichiers
> - Commandes : `put`, `get`, `ls`, `cd`, `mkdir`, `rm`, `chmod`
> - Mode batch avec `-b` pour automatisation
> - Plus flexible que SCP pour opérations multiples

> [!info] Clients graphiques
> 
> - **WinSCP** : Excellent pour synchronisation et automatisation
> - **FileZilla** : Simple et efficace pour transferts FTP/SFTP de base
> - Interface drag-and-drop intuitive
> - Gestion visuelle des permissions et métadonnées

> [!info] Automatisation PowerShell
> 
> - **OpenSSH natif** : Scripts simples avec scp/sftp
> - **Posh-SSH** : Intégration complète avec PowerShell
> - Fonctions réutilisables pour transferts avec retry et logging
> - Planification avec le Planificateur de tâches Windows
> - Configuration externalisée pour faciliter la maintenance

### Cas d'usage recommandés

|Besoin|Outil recommandé|
|---|---|
|Transfert ponctuel unique|`scp` en ligne de commande|
|Navigation et manipulation de fichiers distants|`sftp` interactif|
|Synchronisation régulière de dossiers|WinSCP (interface ou script)|
|Transferts FTP/SFTP occasionnels|FileZilla|
|Automatisation simple|Script PowerShell avec `scp`|
|Pipeline CI/CD complexe|PowerShell avec Posh-SSH|
|Sauvegarde automatique planifiée|Script PowerShell + Planificateur de tâches|
|Déploiement d'applications|Script PowerShell avec logging et notifications|

### Sécurité et bonnes pratiques

> [!warning] Sécurité
> 
> - **Toujours utiliser des clés SSH** plutôt que des mots de passe pour l'automatisation
> - **Ne jamais hardcoder** les credentials dans les scripts
> - **Limiter les permissions** des clés SSH (lecture seule si possible)
> - **Valider les empreintes** des hôtes SSH (known_hosts)
> - **Utiliser Windows Credential Manager** ou des fichiers de configuration sécurisés
> - **Auditer régulièrement** les logs de transfert

> [!tip] Performance
> 
> - Utilisez `-C` pour compresser les transferts de gros fichiers non compressés
> - Limitez la bande passante avec `-l` si nécessaire
> - Préférez transférer des archives plutôt que de nombreux petits fichiers
> - Utilisez SFTP batch plutôt que des commandes répétées
> - Configurez `KeepAlive` dans la config SSH pour éviter les timeouts

### Dépannage rapide

|Problème|Solution|
|---|---|
|**Permission denied**|Vérifiez les droits d'écriture distants et l'authentification SSH|
|**Connection refused**|Vérifiez que le service SSH est actif (port 22 ou personnalisé)|
|**Host key verification failed**|Ajoutez l'hôte : `ssh-keyscan host >> known_hosts`|
|**Timeout**|Augmentez `ConnectTimeout` dans la config SSH ou vérifiez le réseau|
|**SCP/SFTP introuvable**|Installez OpenSSH : `Add-WindowsCapability -Online -Name OpenSSH.Client*`|
|**Transfert lent**|Activez la compression `-C` ou vérifiez la bande passante réseau|

---

**🎓 Vous maîtrisez maintenant les différentes méthodes de transfert de fichiers sécurisé sous Windows !**