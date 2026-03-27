

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

Bien que Windows 10/11 intègre désormais un client SSH natif via PowerShell et Command Prompt, les clients SSH tiers restent populaires grâce à leurs fonctionnalités avancées, leurs interfaces graphiques intuitives et leur richesse d'options. Ces outils sont particulièrement appréciés des administrateurs système et développeurs travaillant fréquemment avec des serveurs distants.

> [!info] Pourquoi utiliser un client tiers ?
> 
> - **Interface graphique** : gestion visuelle des connexions et paramètres
> - **Gestion de sessions** : sauvegarde de profils de connexion
> - **Transfert de fichiers** : SFTP/SCP intégré
> - **Fonctionnalités avancées** : tunneling, macros, scripts
> - **Compatibilité** : support de protocoles multiples (SSH, Telnet, RDP, VNC)

---

## PuTTY

### Présentation et installation

PuTTY est le client SSH le plus ancien et le plus répandu sur Windows. Gratuit et open-source, il est extrêmement léger et portable.

> [!tip] Caractéristiques principales
> 
> - **Taille** : moins de 3 Mo
> - **Licence** : MIT (libre et gratuit)
> - **Portabilité** : pas d'installation nécessaire (version portable)
> - **Stabilité** : développement depuis 1999, très mature

**Installation** :

1. Télécharger depuis le site officiel : `https://www.putty.org/`
2. Choisir entre installateur (`.msi`) ou exécutable portable (`.exe`)
3. Le package complet inclut : PuTTY, PuTTYgen, Pageant, PSFTP, PSCP

```bash
# Versions incluses dans le package PuTTY
putty.exe      # Client SSH principal
puttygen.exe   # Générateur de clés SSH
pageant.exe    # Agent d'authentification SSH
pscp.exe       # Secure Copy (transfert fichiers en ligne de commande)
psftp.exe      # SFTP en ligne de commande
plink.exe      # Interface en ligne de commande pour PuTTY
```

---

### Configuration d'une connexion

L'interface de PuTTY est organisée en catégories à gauche, avec les paramètres correspondants à droite.

> [!example] Connexion SSH basique
> 
> 1. Lancer `putty.exe`
> 2. Dans "Host Name" : saisir l'IP ou le nom de domaine
> 3. Dans "Port" : laisser 22 (port SSH par défaut)
> 4. "Connection type" : sélectionner SSH
> 5. Cliquer sur "Open"

**Paramètres essentiels** :

|Catégorie|Paramètre|Usage|
|---|---|---|
|**Session**|Host Name|IP ou domaine du serveur|
|**Session**|Port|Port SSH (défaut : 22)|
|**Session**|Connection type|SSH, Telnet, Serial, etc.|
|**Connection > Data**|Auto-login username|Nom d'utilisateur par défaut|
|**Window > Appearance**|Font settings|Police et taille du terminal|
|**Window > Colours**|Colour scheme|Personnalisation des couleurs|

> [!warning] Premier avertissement de sécurité Lors de la première connexion, PuTTY affiche l'empreinte de la clé du serveur. Vérifiez cette empreinte avant d'accepter pour éviter les attaques man-in-the-middle.

**Options de terminal** :

```bash
# Configuration Terminal > Keyboard
- Backspace key : Control-? (127)
- Home and End keys : Standard
- Function keys : Linux
- Cursor blinks : activé pour meilleure visibilité

# Configuration Window
- Rows : 24-50 (selon préférence)
- Columns : 80-120
- Scrollback lines : 2000-20000 (historique)
```

---

### Gestion des clés avec PuTTYgen

PuTTYgen est l'outil de génération et conversion de clés SSH de PuTTY. Il utilise un format propriétaire (`.ppk`) différent du format OpenSSH standard.

> [!info] Format PPK PuTTY Private Key (.ppk) est le format natif de PuTTY. Il doit être converti depuis/vers le format OpenSSH pour interopérabilité.

**Génération d'une nouvelle paire de clés** :

1. Lancer `puttygen.exe`
2. Choisir le type de clé :
    - **RSA** : 2048-4096 bits (recommandé 4096)
    - **Ed25519** : plus moderne, sécurisé et rapide
    - **ECDSA** : courbes elliptiques
3. Cliquer sur "Generate"
4. Bouger la souris pour générer de l'entropie
5. Ajouter une passphrase (optionnel mais recommandé)
6. Sauvegarder les clés :
    - "Save public key" : clé publique (`.pub`)
    - "Save private key" : clé privée (`.ppk`)

```bash
# Exemple de clé publique générée (à copier sur le serveur)
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAg8dF... rsa-key-20241215

# Cette clé doit être ajoutée dans ~/.ssh/authorized_keys sur le serveur
```

**Conversion de clés OpenSSH vers PPK** :

```bash
# Si vous avez une clé privée OpenSSH (id_rsa, id_ed25519, etc.)
1. Dans PuTTYgen : Conversions > Import key
2. Sélectionner la clé privée OpenSSH
3. Entrer la passphrase si présente
4. Save private key au format .ppk
```

**Conversion de clés PPK vers OpenSSH** :

```bash
# Pour utiliser une clé PuTTY avec OpenSSH ou d'autres clients
1. Dans PuTTYgen : Load une clé .ppk
2. Conversions > Export OpenSSH key
3. Sauvegarder (généralement sans extension ou .pem)
```

**Utilisation de Pageant (agent SSH)** :

Pageant garde les clés privées en mémoire pour éviter de retaper la passphrase.

```bash
# Lancer pageant.exe (icône dans la barre système)
1. Clic droit sur l'icône > Add Key
2. Sélectionner le fichier .ppk
3. Entrer la passphrase
# La clé reste chargée jusqu'à fermeture de Pageant

# Pageant peut se lancer automatiquement au démarrage
# Créer un raccourci dans le dossier Démarrage avec :
"C:\Program Files\PuTTY\pageant.exe" "C:\Users\VotreNom\.ssh\ma_cle.ppk"
```

> [!tip] Astuce sécurité Utilisez toujours une passphrase pour vos clés privées. Si la clé est volée, la passphrase constitue une couche de protection supplémentaire.

---

### Sessions sauvegardées

PuTTY permet de sauvegarder des profils de connexion pour accès rapide.

**Créer une session sauvegardée** :

```bash
# Configuration complète d'un profil
1. Configurer tous les paramètres (host, port, username, clé, apparence)
2. Dans Session > Saved Sessions : entrer un nom descriptif
3. Cliquer sur "Save"

# Exemples de noms de sessions
- prod-webserver
- dev-database
- backup-server-paris
```

**Charger une session** :

```bash
# Méthode 1 : Interface graphique
1. Double-cliquer sur le nom de la session dans la liste

# Méthode 2 : Ligne de commande
putty.exe -load "prod-webserver"

# Méthode 3 : Créer un raccourci Windows
"C:\Program Files\PuTTY\putty.exe" -load "prod-webserver"
```

**Organisation des sessions** :

```bash
# Utiliser des préfixes pour organiser
PROD/webserver-01
PROD/webserver-02
DEV/test-server
DEV/staging

# Ou par localisation
FR-Paris/web01
US-NYC/db01
```

> [!warning] Stockage des mots de passe PuTTY peut sauvegarder les mots de passe dans les sessions, mais c'est déconseillé pour des raisons de sécurité. Privilégiez l'authentification par clé.

**Exporter/Importer les sessions** :

```bash
# Les sessions sont stockées dans la base de registre Windows
# Localisation : HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions

# Export manuel (via regedit)
1. regedit > naviguer vers la clé ci-dessus
2. Clic droit sur Sessions > Exporter
3. Sauvegarder en .reg

# Import
1. Double-cliquer sur le fichier .reg
2. Confirmer l'ajout au registre

# Export via ligne de commande (PowerShell)
reg export "HKCU\Software\SimonTatham\PuTTY\Sessions" putty-sessions.reg
reg import putty-sessions.reg
```

---

### Tunneling et port forwarding

PuTTY permet de créer des tunnels SSH pour sécuriser ou contourner des restrictions réseau.

> [!info] Types de tunneling
> 
> - **Local** : rediriger un port local vers un port distant via SSH
> - **Remote** : exposer un port local sur un port distant
> - **Dynamic** : créer un proxy SOCKS

**Local port forwarding** :

```bash
# Scénario : accéder à une base de données distante en local
# Rediriger localhost:3306 vers dbserver:3306 via sshserver

Configuration dans PuTTY :
Connection > SSH > Tunnels
- Source port : 3306
- Destination : dbserver:3306
- Type : Local
- Cliquer sur "Add"

# Utilisation après connexion
mysql -h 127.0.0.1 -P 3306 -u user -p
# Se connecte en réalité à dbserver:3306 via le tunnel
```

**Remote port forwarding** :

```bash
# Scénario : exposer un serveur web local (port 8080) sur le serveur distant
# Le serveur distant écoute sur son port 80 et redirige vers votre machine

Configuration dans PuTTY :
Connection > SSH > Tunnels
- Source port : 80
- Destination : localhost:8080
- Type : Remote
- Cliquer sur "Add"

# Le serveur distant peut maintenant accéder à votre localhost:8080 via son port 80
```

**Dynamic port forwarding (SOCKS proxy)** :

```bash
# Scénario : utiliser le serveur SSH comme proxy pour tout le trafic

Configuration dans PuTTY :
Connection > SSH > Tunnels
- Source port : 1080
- Type : Dynamic
- Cliquer sur "Add"

# Configuration dans Firefox/Chrome
Proxy settings :
- SOCKS Host : 127.0.0.1
- Port : 1080
- SOCKS v5

# Tout le trafic du navigateur passe maintenant par le tunnel SSH
```

**Ligne de commande avec Plink** :

```bash
# Local forwarding
plink.exe -L 3306:dbserver:3306 user@sshserver

# Remote forwarding
plink.exe -R 80:localhost:8080 user@sshserver

# Dynamic forwarding (SOCKS proxy)
plink.exe -D 1080 user@sshserver

# Avec authentification par clé
plink.exe -i C:\Users\You\.ssh\key.ppk -L 3306:dbserver:3306 user@sshserver
```

> [!tip] Tunnels multiples Vous pouvez configurer plusieurs tunnels simultanément dans une même session PuTTY. Ajoutez simplement plusieurs règles dans la section Tunnels.

> [!warning] Sécurité du tunneling
> 
> - Évitez d'exposer des services sensibles via remote forwarding
> - Utilisez des pare-feux pour restreindre l'accès aux ports tunnelés

- Ne partagez pas vos tunnels SOCKS avec des personnes non autorisées

---

## MobaXterm

### Présentation et versions

MobaXterm est un client SSH avancé avec un terminal X11, un gestionnaire de fichiers SFTP intégré et des dizaines d'outils réseau dans une seule application.

> [!info] Philosophie de MobaXterm "Un couteau suisse" pour administrateurs système : SSH, SFTP, X11, RDP, VNC, tunneling, et 50+ outils Unix natifs sur Windows, le tout dans une interface graphique moderne.

**Versions disponibles** :

|Version|Prix|Limitations|Usage recommandé|
|---|---|---|---|
|**Home Edition**|Gratuit|12 sessions max, 4 tunnels max, 2 macros max|Utilisateurs individuels|
|**Professional**|~70€/an|Illimité|Professionnels et entreprises|
|**Portable**|Gratuit/Payant|Selon version|Utilisation sur clé USB|

**Installation** :

```bash
# Téléchargement depuis https://mobaxterm.mobatek.net/

# Version Installer (recommandée)
- Installation complète avec raccourcis
- Mises à jour automatiques
- Intégration menu contextuel

# Version Portable
- Un seul fichier .exe
- Aucune installation nécessaire
- Idéal pour clé USB ou systèmes verrouillés
- Les configurations sont stockées dans un fichier .ini adjacent
```

> [!tip] Version portable La version portable stocke toutes ses données (sessions, clés, configurations) dans son dossier d'exécution. Parfait pour transporter votre environnement de travail sur clé USB.

---

### Interface et fonctionnalités

MobaXterm propose une interface à onglets avec plusieurs panneaux configurables.

**Organisation de l'interface** :

```bash
┌─────────────────────────────────────────────────────────┐
│ Menu principal et barre d'outils                        │
├──────────────┬──────────────────────────────────────────┤
│              │                                          │
│   Sessions   │       Terminal SSH / SFTP / RDP         │
│   sauvées    │       (onglets multiples)               │
│              │                                          │
│   Sidebar    ├──────────────────────────────────────────┤
│   (SFTP,     │       Unix tools (en bas)               │
│   tunnel,    │       ou SFTP browser (côté)            │
│   macros)    │                                          │
│              │                                          │
└──────────────┴──────────────────────────────────────────┘
```

**Fonctionnalités principales** :

|Fonctionnalité|Description|
|---|---|
|**Multi-onglets**|Plusieurs sessions SSH/RDP/VNC dans une fenêtre|
|**SFTP intégré**|Navigateur de fichiers graphique automatique|
|**X11 server**|Exécuter des applications graphiques Linux|
|**Unix tools**|Bash, grep, awk, sed, vim, etc. natifs Windows|
|**Macros**|Automatisation de commandes répétitives|
|**Terminal local**|PowerShell, CMD, WSL, Cygwin|
|**Split panes**|Diviser l'écran en plusieurs terminaux|
|**Enregistreur**|Enregistrer les sessions en logs|

---

### Connexions SSH

**Créer une nouvelle session SSH** :

```bash
# Méthode 1 : Quick connection
1. Cliquer sur "Session" dans la barre
2. Sélectionner "SSH"
3. Remplir :
   - Remote host : IP ou domaine
   - Username : nom d'utilisateur
   - Port : 22 (par défaut)
4. Cliquer sur "OK"

# Méthode 2 : Sessions manager (gauche)
1. Cliquer sur "+" en haut du panneau gauche
2. Session settings similaires à la méthode 1
3. Ajouter des options avancées (voir ci-dessous)
```

**Configuration avancée d'une session** :

```bash
Basic SSH settings :
├─ Remote host : serveur.example.com
├─ Port : 22
├─ Username : admin
└─ Specify username (cocher)

Advanced SSH settings :
├─ Private key : Parcourir vers la clé privée (.ppk ou format OpenSSH)
├─ SSH-browser type : SFTP protocol (recommandé)
├─ Compression : Activé (accélère sur connexions lentes)
├─ X11-Forwarding : Activé si besoin d'applications graphiques
├─ SSH keepalive : 30 secondes (maintient la connexion)
└─ Execute command : commande à lancer automatiquement (optionnel)

Terminal settings :
├─ Font : Consolas, DejaVu Sans Mono
├─ Font size : 10-12
├─ Terminal type : xterm-256color
└─ Scrollback : 10000 lignes

Network settings :
├─ Gateway (jump host) : serveur intermédiaire
├─ Port forwarding : tunnels SSH
└─ Proxy settings : HTTP/SOCKS proxy si nécessaire
```

> [!example] Configuration avec Jump Host Si vous devez passer par un bastion/jump server :
> 
> ```
> Session 1 (Jump host) :
> - Remote host : bastion.company.com
> - Username : your_user
> 
> Session 2 (Serveur final) :
> - Remote host : internal-server
> - Username : admin
> - Gateway : [Sélectionner Session 1]
> ```
> 
> MobaXterm établira automatiquement la connexion en cascade.

**Authentification** :

```bash
# Ordre de préférence (modifiable dans Settings)
1. Clé SSH privée (spécifiée dans session settings)
2. Agent SSH MobaXterm (MobAgent)
3. Pageant (si disponible)
4. Mot de passe (demandé interactivement)

# Configurer MobAgent (agent SSH intégré)
Settings > Configuration > SSH
├─ Use internal SSH agent (MobAgent) : cocher
├─ Load following keys at startup : ajouter vos clés
└─ Forward SSH agents : cocher pour jump hosts
```

---

### Terminal intégré et outils Unix

MobaXterm inclut un ensemble complet d'outils Unix/Linux compilés nativement pour Windows.

**Outils disponibles** (liste partielle) :

```bash
# Shells
bash, zsh, sh

# Éditeurs
vim, nano, emacs

# Utilitaires texte
grep, sed, awk, cut, sort, uniq, wc, diff, patch

# Réseau
curl, wget, ssh, scp, sftp, rsync, nc (netcat), telnet, ping, traceroute

# Compression
tar, gzip, bzip2, xz, zip, unzip

# Système
ps, top, kill, df, du, find, locate

# Développement
git, make, gcc (via plugin), python, perl, ruby

# Autres
screen, tmux, cron (Windows Task Scheduler)
```

**Utilisation du terminal local** :

```bash
# Lancer un terminal local Windows
Tools > MobaXterm local terminal
# ou cliquer sur l'icône terminal en haut

# Vous avez accès à tous les outils Unix + commandes Windows
$ ls -la           # Unix-style
$ dir              # Windows-style
$ pwd              # Affiche le chemin actuel
$ cd /drives/c/    # Accès aux disques Windows (/drives/c/, /drives/d/, etc.)

# Exemple : rechercher des fichiers
$ find /drives/c/Users/VotreNom -name "*.txt" -mtime -7
# Trouve tous les .txt modifiés dans les 7 derniers jours
```

**Scripting bash sur Windows** :

```bash
# Créer un script bash
$ vim backup.sh

#!/bin/bash
# Script de sauvegarde

SOURCE="/drives/c/Users/VotreNom/Documents"
BACKUP="/drives/d/Backups/$(date +%Y%m%d)"

mkdir -p "$BACKUP"
rsync -av --delete "$SOURCE/" "$BACKUP/"

echo "Backup completed: $BACKUP"

# Rendre exécutable
$ chmod +x backup.sh

# Exécuter
$ ./backup.sh
```

> [!tip] Package manager MobaXterm a un gestionnaire de plugins (MobApt) pour installer des outils supplémentaires :
> 
> ```bash
> Tools > MobaXterm Plugin (MobApt)
> # Installer gcc, python3, nodejs, etc.
> ```

---

### Transfert de fichiers intégré

MobaXterm ouvre automatiquement un navigateur SFTP en sidebar lors d'une connexion SSH.

**Interface SFTP automatique** :

```bash
┌──────────────────────────────────┐
│  Sftp  │ [Local files]           │
├──────────────────────────────────┤
│ /home/user/                      │
│ ├─ documents/                    │
│ ├─ downloads/                    │
│ ├─ scripts/                      │
│ └─ config.txt                    │
└──────────────────────────────────┘

# Actions disponibles (clic droit) :
- Download (télécharger vers Windows)
- Upload (envoyer depuis Windows)
- Edit (modifier avec éditeur intégré)
- Delete, Rename, Properties
- Create folder
- Synchronize (synchronisation bidirectionnelle)
```

**Opérations de transfert** :

```bash
# Download (serveur -> local)
1. Naviguer dans le répertoire distant
2. Clic droit sur fichier/dossier > Download
3. Choisir destination Windows
# Ou glisser-déposer vers une fenêtre Windows

# Upload (local -> serveur)
1. Clic droit dans la zone SFTP > Upload to current folder
2. Sélectionner fichiers Windows
# Ou glisser-déposer depuis l'Explorateur Windows

# Edition directe
1. Double-cliquer sur un fichier texte
2. MobaXterm l'ouvre dans son éditeur intégré
3. Sauvegarder : upload automatique vers le serveur
```

**Synchronisation de dossiers** :

```bash
# Synchroniser un dossier local avec un distant
1. Clic droit sur un dossier (local ou distant)
2. Synchronize > Configure
3. Paramètres :
   - Direction : Upload / Download / Both
   - Delete extra files : supprimer fichiers non présents dans source
   - Overwrite existing : écraser ou ignorer
4. Run synchronization

# Use case typique : déploiement de site web
Local : C:\projets\monsite\
Distant : /var/www/html/
Direction : Upload
-> Chaque sync met à jour le serveur web
```

> [!warning] Synchronisation destructive L'option "Delete extra files" supprime les fichiers dans la destination qui n'existent pas dans la source. Utilisez avec précaution.

**Transfert en ligne de commande** :

```bash
# Depuis le terminal MobaXterm local
$ scp fichier.txt user@serveur:/path/to/destination/
$ scp -r dossier/ user@serveur:/path/to/destination/

# Ou utiliser rsync (plus puissant)
$ rsync -avz --progress dossier/ user@serveur:/path/

# Download depuis le serveur
$ scp user@serveur:/path/fichier.txt ./
$ rsync -avz user@serveur:/path/dossier/ ./local/
```

---

### Tunneling X11

MobaXterm inclut un serveur X11 intégré permettant d'exécuter des applications graphiques Linux sur Windows.

> [!info] Qu'est-ce que X11 ? X11 (X Window System) est le système graphique des Unix/Linux. Avec X11 forwarding, une application graphique s'exécute sur le serveur distant mais s'affiche sur votre écran Windows.

**Activation du X11 forwarding** :

```bash
# Configuration session SSH
Advanced SSH settings
└─ X11-Forwarding : cocher

# Ou en ligne de commande
$ ssh -X user@serveur
# L'option -X active le X11 forwarding
```

**Lancement d'applications graphiques** :

```bash
# Après connexion SSH avec X11 activé
$ echo $DISPLAY
localhost:10.0
# Variable d'environnement confirmant que X11 est actif

# Lancer des applications graphiques
$ firefox &              # Navigateur Firefox
$ gedit fichier.txt &    # Éditeur de texte Gedit
$ nautilus &             # Explorateur de fichiers Gnome
$ xclock &               # Horloge (test simple)
$ gimp &                 # Éditeur d'images GIMP

# Les fenêtres s'affichent sur votre bureau Windows
# L'application s'exécute sur le serveur Linux
```

**Applications courantes via X11** :

|Application|Commande|Usage|
|---|---|---|
|**Éditeurs**|gedit, kate, geany|Édition de texte avec GUI|
|**IDE**|eclipse, intellij-idea|Développement|
|**Navigateurs**|firefox, chromium|Navigation web|
|**Gestionnaires fichiers**|nautilus, thunar, dolphin|Explorer le serveur|
|**Outils admin**|virt-manager, gparted|Administration système|
|**Scientifique**|octave-gui, matlab|Calcul numérique|

> [!tip] Performance X11 Le X11 forwarding peut être lent sur connexions à faible bande passante. Pour améliorer :
> 
> ```bash
> # Utiliser compression SSH
> $ ssh -X -C user@serveur
> # Option -C active la compression
> 
> # Ou dans MobaXterm session settings
> Advanced SSH settings > Compression : activé
> ```

**Résolution de problèmes X11** :

```bash
# Erreur "cannot open display"
$ echo $DISPLAY
# Si vide, X11 forwarding n'est pas actif

# Vérifier configuration serveur (/etc/ssh/sshd_config)
X11Forwarding yes
X11UseLocalhost yes

# Redémarrer service SSH sur serveur
$ sudo systemctl restart sshd

# Tester avec application simple
$ xeyes &
# Si les "yeux" suivent votre curseur, X11 fonctionne
```

> [!warning] Sécurité X11 X11 forwarding peut présenter des risques de sécurité. Ne l'activez que sur des connexions de confiance et désactivez-le après usage sur des serveurs sensibles.

---

## WinSCP

### Présentation et installation

WinSCP est un client SFTP/SCP graphique spécialisé dans le transfert de fichiers, avec une interface à deux panneaux (local/distant) intuitive.

> [!info] Pourquoi WinSCP ? Contrairement à PuTTY ou MobaXterm qui sont avant tout des clients SSH avec SFTP intégré, WinSCP est optimisé pour le transfert de fichiers avec des fonctionnalités avancées de synchronisation, d'édition à distance et d'automatisation.

**Caractéristiques** :

- **Licence** : Open-source (GPL)
- **Protocoles** : SFTP, SCP, FTP, FTPS, WebDAV
- **Interfaces** : Commander (deux panneaux) ou Explorer (style Windows)
- **Intégration** : PuTTY, Pageant, éditeurs externes
- **Automatisation** : Scripts .NET, ligne de commande

**Installation** :

```bash
# Téléchargement depuis https://winscp.net/

# Options d'installation
1. Interface utilisateur :
   - Commander interface (recommandée pour power users)
   - Explorer interface (familière style Windows)

2. Intégration shell :
   - Upload with WinSCP (menu contextuel Explorateur)
   - Drag & drop handler

3. Éditeur par défaut :
   - Notepad
   - Notepad++
   - VS Code
   - Autre (personnalisé)
```

---

### Interface graphique

**Mode Commander (deux panneaux)** :

```bash
┌─────────────────────────────────────────────────────────────┐
│  Session: user@serveur.com         [Outils] [Options]       │
├─────────────────────────────┬───────────────────────────────┤
│  Local (C:\Users\Nom\)      │  Distant (/home/user/)        │
├─────────────────────────────┼───────────────────────────────┤
│  📁 Documents               │  📁 documents                 │
│  📁 Downloads               │  📁 scripts                   │
│  📄 fichier.txt             │  📄 config.conf               │
│  📄 image.png               │  📄 log.txt                   │
└─────────────────────────────┴───────────────────────────────┘
│  [Upload] [Download] [Edit] [Delete] [Rename] [Properties]  │
└─────────────────────────────────────────────────────────────┘
```

**Mode Explorer (panneau unique)** :

```bash
┌─────────────────────────────────────────────────────────────┐
│  📍 /home/user/documents/                                    │
├─────────────────────────────────────────────────────────────┤
│  Nom              Taille    Type          Modifié           │
│  📁 projets       -         Folder        15/12/2024        │
│  📁 backup        -         Folder        10/12/2024        │
│  📄 readme.txt    1.2 KB    Text file     14/12/2024        │
│  📄 data.json     45 KB     JSON file     12/12/2024        │
└─────────────────────────────────────────────────────────────┘
```

**Opérations de base** :

```bash
# Navigation
- Double-clic sur dossier : entrer dans le dossier
- Flèches haut/bas : sélectionner fichiers
- Backspace : remonter au dossier parent
- Ctrl+\ : racine du système

# Transfert fichiers
- Glisser-déposer : entre panneaux ou depuis Explorateur Windows
- F5 (Upload) : copier fichier local vers distant
- F6 (Download) : copier fichier distant vers local
- Ctrl+C/V : copier-coller entre panneaux

# Gestion fichiers
- F7 : créer nouveau dossier
- F8 / Del : supprimer fichier/dossier
- F2 : renommer
- Alt+Enter : propriétés et permissions

# Édition
- F4 : éditer avec éditeur interne
- Ctrl+P : ouvrir avec éditeur externe configuré
```

> [!tip] Raccourcis clavier WinSCP utilise les conventions de Norton Commander / Total Commander :
> 
> - F3 : voir, F4 : éditer, F5 : copier, F6 : déplacer, F7 : nouveau dossier, F8 : supprimer

---

### Connexion SFTP

**Créer une nouvelle connexion** :

```bash
# Fenêtre de login (au démarrage)
File protocol : SFTP (SSH File Transfer Protocol)
Host name : serveur.example.com
Port number : 22
User name : votre_username
Password : ******** (ou laisser vide pour clé SSH)

# Bouton Advanced pour options avancées
```

**Configuration avancée** :

```bash
Environment
├─ SFTP server : /usr/lib/sftp-server (par défaut, auto-détecté)
├─ Protocol options : 
│  └─ Preferred SFTP protocol version : 3-6 (auto)
└─ Directory options :
   └─ Remote directory : /home/user (répertoire de démarrage)

Connection
├─ Timeout : 15 secondes
├─ Keepalives : Send keepalive every 30 seconds
└─ Server response timeout : 15 seconds

Proxy
├─ Proxy type : None / HTTP / SOCKS4 / SOCKS5
└─ Configuration si proxy d'entreprise requis

Tunnel
├─ Connect through SSH tunnel : cocher si jump host
├─ Host name : bastion.company.com
└─ Port number : 22

Authentication
├─ Private key file : chemin vers clé privée (.ppk ou OpenSSH)
├─ SSH agent : Use Pageant / Use internal agent
├─ Attempt 'keyboard-interactive' authentication
└─ Authentication parameters (passphrase si clé protégée)
```

**Sauvegarder un site** :

```bash
# Après configuration
1. Cliquer sur "Save" dans la fenêtre de login
2. Donner un nom au site : "Production Server"
3. Options de sauvegarde :
   - Save password : déconseillé (sécurité)
   - Save as Site / Folder : organiser hiérarchiquement
   - Create desktop shortcut : accès rapide

# Gestionnaire de sites (Ctrl+Alt+B)
Session > Sites > Organize
├─ Production/
│  ├─ Web Server 01
│  └─ Database Server
├─ Development/
│  └─ Test Server
└─ Backup Servers/
```

> [!warning] Stockage des mots de passe WinSCP peut chiffrer les mots de passe sauvegardés avec un mot de passe maître. Activez cette option dans Preferences > Security > Master password.

**Import depuis PuTTY** :

```bash
# WinSCP peut importer les sessions PuTTY
Tools > Import Sites
├─ Import from : PuTTY
├─ Source : Registry (sessions PuTTY stockées)
└─ Select sessions : choisir les sessions à importer

# Les sessions sont converties automatiquement
# Les clés .ppk sont utilisées directement
```

---

### Transfert et synchronisation

**Modes de transfert** :

|Mode|Description|Usage|
|---|---|---|
|**Binary**|Transfert binaire brut|Images, exécutables, archives|
|**Text**|Conversion fins de ligne (CRLF ↔ LF)|Fichiers texte, scripts|
|**Automatic**|Détection selon extension|Recommandé (par défaut)|

```bash
# Configuration du mode de transfert
Options > Preferences > Transfer > Text mode

# Extensions texte (conversion CRLF/LF)
*.txt; *.html; *.php; *.css; *.js; *.sh; *.py; *.conf

# Extensions binaires (pas de conversion)
*.jpg; *.png; *.zip; *.exe; *.pdf; *.bin
```

**Synchronisation de répertoires** :

```bash
# Commandes > Synchroniser
Commands > Synchronize (Ctrl+S)

Direction :
├─ Local → Remote : Upload (mise à jour serveur)
├─ Remote → Local : Download (récupération depuis serveur)
└─ Both : Synchronisation bidirectionnelle

Mode :
├─ Synchronize : copier fichiers manquants/modifiés
├─ Mirror : synchroniser + supprimer fichiers supplémentaires
└─ Keep local files : ne jamais supprimer localement

Options :
├─ Existing files only : ne synchroniser que fichiers existants
├─ Preview changes : prévisualiser avant d'appliquer
├─ Delete files : supprimer fichiers obsolètes (mode Mirror)
└─ Subdirectories : inclure sous-dossiers (récursif)

Filters :
├─ File mask : *.php; *.html; *.css (inclure)
├─ Exclude mask : *.log; *.tmp; .git/ (exclure)
└─ Size / Date constraints : filtres avancés
```

> [!example] Cas d'usage : Synchroniser un site web
> 
> ```bash
> Local : C:\projets\monsite\
> Remote : /var/www/html/
> Direction : Local → Remote
> Mode : Synchronize
> Exclude : *.log; .git/; node_modules/
> 
> → Tous les fichiers modifiés localement sont uploadés
> → Les fichiers .log et dossiers .git ne sont pas touchés
> ```

**Keep Remote Directory Up To Date** :

```bash
# Surveillance continue des modifications locales
Commands > Keep Remote Directory up to Date

# Fonctionnement
1. WinSCP surveille le répertoire local
2. Détecte automatiquement les modifications de fichiers
3. Upload automatique vers le serveur
4. Idéal pour développement web en temps réel

# Options
├─ Synchronize on start : sync initial avant surveillance
├─ Update subdirectories : inclure sous-dossiers
├─ Filters : mêmes filtres que synchronisation
└─ Options avancées : délai, gestion conflits
```

> [!tip] Développement en direct "Keep Remote Directory up to Date" permet de travailler avec votre éditeur local (VS Code, Sublime) et voir les modifications appliquées instantanément sur le serveur web distant.

**File Masks (masques de fichiers)** :

```bash
# Syntaxe des masques
*.txt               # Tous fichiers .txt
file?.txt           # file1.txt, fileA.txt (? = 1 caractère)
data[0-9].csv       # data0.csv à data9.csv
*.php; *.html       # Plusieurs extensions (séparées par ;)

# Exclusions
*.* | *.log         # Tout sauf .log
*.txt | temp*       # Tous .txt sauf ceux commençant par temp

# Chemins
/home/*/backup/     # Tous dossiers backup
*/logs/*.log        # Tous .log dans sous-dossiers logs

# Exemples pratiques
*.php; *.html; *.css; *.js    # Fichiers web
*/ | .git/; node_modules/     # Tous dossiers sauf .git et node_modules
*.* | *.tmp; *.bak; *~        # Tout sauf fichiers temporaires
```

---

### Intégration avec PuTTY

WinSCP peut ouvrir des sessions terminales PuTTY directement depuis l'interface.

**Configuration de l'intégration** :

```bash
Options > Preferences > Integration > Applications

PuTTY/Terminal client path :
C:\Program Files\PuTTY\putty.exe

# Ou autre terminal SSH
- KiTTY (fork amélioré de PuTTY)
- MobaXterm
- Windows Terminal avec SSH

Remember session password and pass it to PuTTY :
└─ Cocher pour éviter de retaper le mot de passe
```

**Ouvrir un terminal** :

```bash
# Méthode 1 : Menu
Commands > Open in PuTTY (Ctrl+P)
# Ouvre PuTTY avec la session actuelle

# Méthode 2 : Bouton toolbar
[PuTTY icon] dans barre d'outils

# Méthode 3 : Raccourci clavier
Ctrl+P : ouverture rapide

# Le terminal PuTTY s'ouvre :
- Avec la même connexion SSH
- Dans le répertoire actuel de WinSCP
- Avec authentification déjà effectuée
```

**Commandes personnalisées** :

```bash
# Créer des commandes rapides
Options > Preferences > Integration > Custom Commands

# Exemples de commandes personnalisées
Nom : Edit in vim
Command : vim !
Description : Éditer le fichier sélectionné avec vim

Nom : Permissions 755
Command : chmod 755 !
Description : Mettre permissions 755

Nom : Extract tar.gz
Command : tar -xzf "!" -C "!?Extract to:?/tmp!"
Description : Extraire archive avec demande de destination

# Utilisation
- Clic droit sur fichier > Custom Commands > [Nom commande]
- Ou assigner raccourci clavier
```

**Variables disponibles pour commandes** :

```bash
!           # Fichier(s) sélectionné(s) avec chemin complet
!&          # Fichier(s) sélectionné(s) (nom seul)
!/          # Chemin du répertoire actuel
!?Texte?!   # Demander une valeur à l'utilisateur

# Exemples avancés
grep "!?Search term:?!" !
# Recherche dans fichier avec prompt utilisateur

find !/ -name "*.log" -mtime +30 -delete
# Supprimer logs de plus de 30 jours dans répertoire actuel

rsync -avz !/ user@backup-server:!/
# Backup du répertoire actuel vers serveur de backup
```

> [!tip] Raccourcis pratiques Assignez des raccourcis clavier (Ctrl+1 à Ctrl+9) à vos commandes personnalisées les plus utilisées pour un accès ultra-rapide.

---

### Scripts et automatisation

WinSCP offre plusieurs méthodes d'automatisation pour tâches répétitives ou intégration dans workflows.

**Scripts en ligne de commande** :

```bash
# Syntaxe de base
winscp.com /command "commande1" "commande2" "commande3"

# Exemple : Upload automatique
winscp.com /command ^
    "open sftp://user:password@serveur.com/" ^
    "put C:\local\fichier.txt /remote/path/" ^
    "exit"

# Utiliser un fichier de script
winscp.com /script=script.txt
```

**Fichier de script WinSCP** :

```bash
# script.txt
option batch abort
option confirm off

# Connexion
open sftp://user@serveur.com/ -privatekey="C:\keys\mykey.ppk"

# Commandes
lcd C:\local\backup
cd /remote/backup
put *.zip
synchronize remote C:\website /var/www/html

# Déconnexion
close
exit
```

**Commandes disponibles** :

|Commande|Description|Exemple|
|---|---|---|
|**open**|Ouvrir session|`open sftp://user@host/`|
|**close**|Fermer session|`close`|
|**cd**|Changer répertoire distant|`cd /var/www`|
|**lcd**|Changer répertoire local|`lcd C:\backup`|
|**put**|Upload fichier(s)|`put file.txt /remote/`|
|**get**|Download fichier(s)|`get /remote/file.txt`|
|**rm**|Supprimer distant|`rm /remote/old.txt`|
|**mv**|Renommer/déplacer distant|`mv old.txt new.txt`|
|**mkdir**|Créer dossier distant|`mkdir /remote/newfolder`|
|**chmod**|Modifier permissions|`chmod 755 script.sh`|
|**synchronize**|Synchroniser|`synchronize remote C:\ /home/`|
|**keepuptodate**|Surveillance continue|`keepuptodate C:\dev /var/www`|
|**exit**|Quitter|`exit`|

**Options importantes** :

```bash
# Options globales (avant commandes)
option batch abort          # Arrêter sur erreur
option batch continue       # Continuer malgré erreurs
option confirm off          # Pas de confirmations interactives
option transfer binary      # Mode binaire
option transfer automatic   # Mode automatique
option reconnecttime 120    # Reconnexion auto après 120 sec

# Options dans commandes
put -delete file.txt        # Supprimer source après upload
get -resumesupport=on       # Reprendre téléchargement interrompu
synchronize -delete         # Supprimer fichiers obsolètes
```

**Script batch Windows** :

```batch
@echo off
REM backup.bat - Script de sauvegarde automatisé

echo === Backup des fichiers vers serveur ===
echo Debut : %date% %time%

REM Exécuter WinSCP script
"C:\Program Files (x86)\WinSCP\winscp.com" /script="C:\scripts\backup-script.txt" /log="C:\logs\backup.log"

REM Vérifier code de sortie
if %ERRORLEVEL% equ 0 (
    echo Backup reussi !
) else (
    echo Erreur lors du backup - Code: %ERRORLEVEL%
)

echo Fin : %date% %time%
pause
```

**Planification avec Task Scheduler** :

```bash
# Créer une tâche planifiée Windows
1. Ouvrir Task Scheduler (taskschd.msc)
2. Create Basic Task
3. Nom : "Backup quotidien WinSCP"
4. Trigger : Daily à 2:00 AM
5. Action : Start a program
   - Program : C:\scripts\backup.bat
   - Start in : C:\scripts\
6. Finish

# La sauvegarde s'exécutera automatiquement chaque nuit
```

**Automatisation avec PowerShell (.NET assembly)** :

```powershell
# Charger l'assembly WinSCP .NET
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Configuration session
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = "serveur.com"
    UserName = "user"
    SshPrivateKeyPath = "C:\keys\mykey.ppk"
}

# Connexion
$session = New-Object WinSCP.Session
try {
    $session.Open($sessionOptions)
    
    # Upload fichiers
    $transferResult = $session.PutFiles("C:\local\*", "/remote/path/", $False)
    
    # Vérifier résultat
    $transferResult.Check()
    
    # Afficher fichiers transférés
    foreach ($transfer in $transferResult.Transfers) {
        Write-Host "Upload: $($transfer.FileName)"
    }
}
finally {
    $session.Dispose()
}
```

> [!example] Use case : Déploiement automatisé
> 
> ```powershell
> # deploy.ps1 - Déploiement site web après build
> 
> # 1. Build du projet
> npm run build
> 
> # 2. Upload via WinSCP
> winscp.com /script=deploy-script.txt
> 
> # 3. Commandes post-déploiement (via SSH)
> plink user@serveur "sudo systemctl restart nginx"
> 
> Write-Host "Déploiement terminé !"
> ```

> [!warning] Sécurité des scripts
> 
> - Ne jamais mettre de mots de passe en clair dans les scripts
> - Utiliser l'authentification par clé SSH
> - Stocker les scripts dans un répertoire protégé
> - Journaliser les exécutions avec `/log` pour audit

---

## Comparaison et cas d'usage

### Tableau comparatif

|Critère|PuTTY|MobaXterm|WinSCP|
|---|---|---|---|
|**Prix**|Gratuit|Gratuit / Pro (~70€)|Gratuit|
|**Licence**|MIT (Open Source)|Freemium|GPL (Open Source)|
|**Taille**|3 MB|25 MB|10 MB|
|**Portabilité**|Oui|Oui|Oui|
|**Multi-onglets**|❌|✅|❌|
|**SFTP intégré**|❌ (PSFTP séparé)|✅ (sidebar)|✅ (principal)|
|**X11 forwarding**|✅|✅ (serveur intégré)|❌|
|**Outils Unix**|❌|✅ (50+ outils)|❌|
|**Interface graphique**|Basique|Moderne, riche|Très soignée|
|**Tunneling SSH**|✅|✅|✅|
|**Synchronisation**|❌|✅ (basique)|✅ (avancée)|
|**Macros**|❌|✅ (limité gratuit)|✅ (commandes)|
|**Scripts**|✅ (Plink)|✅|✅ (CLI + .NET)|
|**Gestion sessions**|✅ (registre)|✅ (fichiers)|✅ (fichiers)|
|**Éditeur intégré**|❌|✅|✅|
|**RDP/VNC**|❌|✅|❌|
|**Courbe apprentissage**|Faible|Moyenne|Faible|

---

### Recommandations par profil

**Administrateur système** :

```bash
Outil principal : MobaXterm Professional
Raisons :
- Gestion centralisée de dizaines/centaines de serveurs
- Tunnels et macros illimités
- X11 pour outils d'administration graphiques
- Outils Unix intégrés pour scripts
- RDP/VNC pour serveurs Windows

Complément : WinSCP
Raisons :
- Transferts massifs de fichiers
- Synchronisation avancée
- Automatisation avec scripts PowerShell
```

**Développeur web** :

```bash
Outil principal : MobaXterm Home ou WinSCP
Raisons :
- MobaXterm : terminal + SFTP + édition dans une fenêtre
- WinSCP : synchronisation temps réel avec "Keep Remote Up to Date"
- Édition directe de fichiers distants

Complément : PuTTY (portable)
Raisons :
- Connexions SSH rapides ponctuelles
- Clé USB avec PuTTY portable + sessions
```

**Utilisateur occasionnel** :

```bash
Outil recommandé : WinSCP
Raisons :
- Interface intuitive type Explorateur Windows
- Transfert fichiers par glisser-déposer
- Intégration PuTTY pour terminal si besoin
- Pas de fonctionnalités superflues

Ou : Client SSH natif Windows + Explorateur SFTP
Raisons :
- Pas d'installation nécessaire
- PowerShell/CMD avec ssh, scp
- Mappage lecteur réseau SFTP (sshfs-win)
```

**Développeur DevOps** :

```bash
Outil principal : Ligne de commande (OpenSSH + scripts)
Raisons :
- Automatisation CI/CD
- Scripts Ansible, Terraform
- Intégration Git Bash / WSL

Compléments : PuTTY (tunneling) + WinSCP (scripts .NET)
Raisons :
- PuTTY : tunnels persistants pour bases de données
- WinSCP : automatisation transferts avec PowerShell
- Plink : SSH en ligne de commande pour scripts Batch
```

**Support technique** :

```bash
Outil principal : MobaXterm Portable (clé USB)
Raisons :
- Aucune installation requise sur machines clients
- Tous les outils dans une application
- Sessions sauvegardées transportables
- Multi-protocoles (SSH, RDP, VNC, Telnet)

Alternative : PuTTY Portable + WinSCP Portable
Raisons :
- Encore plus léger (< 15 MB total)
- Fiabilité maximale
- Compatibilité universelle
```

---

### Cas d'usage spécifiques

**Scénario 1 : Administration de serveurs web**

```bash
Besoin :
- Connexion SSH fréquente
- Édition fichiers de configuration
- Déploiement de code
- Consultation logs

Solution optimale : MobaXterm
Workflow :
1. Connexion SSH avec SFTP sidebar
2. Édition directe fichiers (Ctrl+P ou double-clic)
3. Consultation logs en temps réel (tail -f)
4. Scripts de déploiement dans macros
```

**Scénario 2 : Transfert massif de fichiers**

```bash
Besoin :
- Upload/Download gros volumes
- Synchronisation entre environnements
- Automatisation nocturne

Solution optimale : WinSCP
Workflow :
1. Connexion SFTP avec mode Commander
2. Synchronisation avec filtres et masques
3. Script WinSCP + Task Scheduler
4. Logs de transfert pour audit
```

**Scénario 3 : Accès via bastion/jump host**

```bash
Besoin :
- Connexion à travers serveur de rebond
- Tunneling de ports pour bases de données
- Conformité sécurité

Solution optimale : PuTTY ou MobaXterm
Workflow PuTTY :
1. Session 1 : connexion au bastion avec tunnel local
2. Session 2 : connexion au serveur final via localhost
3. Pageant pour gestion des clés

Workflow MobaXterm :
1. Session serveur final avec Gateway = bastion
2. MobaXterm gère automatiquement la cascade
3. Plus simple, mais moins de contrôle
```

**Scénario 4 : Applications graphiques Linux**

```bash
Besoin :
- Lancer IDE distant (Eclipse, IntelliJ)
- Outils d'administration graphiques
- Performance acceptable

Solution optimale : MobaXterm
Raisons :
- Serveur X11 intégré optimisé
- Compression automatique
- Pas de configuration X11 manuelle
- Gestion fenêtres native Windows

Alternative : PuTTY + Xming/VcXsrv
Raisons :
- Plus léger en ressources
- Meilleure performance sur connexions rapides
- Configuration manuelle nécessaire
```

**Scénario 5 : Développement mobile (Android/iOS)**

```bash
Besoin :
- Accès serveur de build
- Upload applications compilées
- Consultation logs de crash

Solution optimale : WinSCP + PuTTY
Workflow :
1. WinSCP pour upload .apk / .ipa vers serveur
2. PuTTY pour lancer builds et consulter logs
3. Téléchargement artifacts via WinSCP
4. Sessions sauvegardées pour accès rapide
```

---

### Pièges courants et solutions

> [!warning] Problème : "Network error: Connection timed out" **Causes** :
> 
> - Firewall bloque port 22
> - Serveur SSH non démarré
> - Mauvaise adresse IP/domaine
> 
> **Solutions** :
> 
> ```bash
> # Vérifier connectivité réseau
> ping serveur.com
> 
> # Vérifier port SSH ouvert
> telnet serveur.com 22
> # ou avec PowerShell
> Test-NetConnection serveur.com -Port 22
> 
> # Tester depuis ligne de commande
> ssh -vvv user@serveur.com
> # Mode verbeux pour diagnostiquer
> ```

> [!warning] Problème : "Disconnected: No supported authentication methods available" **Causes** :
> 
> - Mauvaise clé SSH
> - Permissions incorrectes sur authorized_keys
> - Méthode d'authentification désactivée
> 
> **Solutions** :
> 
> ```bash
> # Vérifier permissions serveur
> chmod 700 ~/.ssh
> chmod 600 ~/.ssh/authorized_keys
> 
> # Vérifier configuration sshd (/etc/ssh/sshd_config)
> PubkeyAuthentication yes
> PasswordAuthentication yes
> 
> # Tester avec mot de passe d'abord
> # Puis ajouter clé publique correctement
> ```

> [!warning] Problème : Transfert SFTP très lent **Causes** :
> 
> - Connexion internet faible
> - Compression désactivée
> - Chiffrement fort sur CPU faible
> 
> **Solutions** :
> 
> ```bash
> # PuTTY : activer compression
> Connection > SSH > Enable compression
> 
> # WinSCP : choisir algorithme plus rapide
> Advanced > Connection > Encryption
> Cipher : aes128-ctr (plus rapide que aes256)
> 
> # MobaXterm : activer compression
> Session settings > Advanced SSH > Compression
> 
> # Utiliser rsync avec compression
> rsync -avz --progress file.tar.gz user@serveur:/path/
> ```

> [!warning] Problème : "Host key verification failed" **Causes** :
> 
> - Clé du serveur a changé (réinstallation)
> - Attaque man-in-the-middle possible
> 
> **Solutions** :
> 
> ```bash
> # Windows OpenSSH
> # Supprimer ancienne clé dans :
> C:\Users\VotreNom\.ssh\known_hosts
> 
> # PuTTY : supprimer via registre
> regedit > HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\SshHostKeys
> 
> # Ou accepter nouvelle clé après vérification
> # IMPORTANT : vérifier l'empreinte avec admin serveur
> ```

> [!tip] Astuces d'optimisation **Connexions multiples simultanées** :
> 
> ```bash
> # OpenSSH : multiplexage de connexion
> # Dans ~/.ssh/config (Windows : C:\Users\Nom\.ssh\config)
> Host serveur.com
>     ControlMaster auto
>     ControlPath ~/.ssh/sockets/%r@%h-%p
>     ControlPersist 10m
> 
> # Première connexion établit le tunnel
> # Connexions suivantes réutilisent le même tunnel (instantané)
> ```
> 
> **Transferts volumineux** :
> 
> ```bash
> # Compresser avant transfert pour gros fichiers
> tar -czf archive.tar.gz dossier/
> # Upload archive compressée
> # Décompresser côté serveur
> 
> # Ou utiliser rsync avec compression intégrée
> rsync -avz --partial --progress gros_fichier.iso user@serveur:/path/
> # --partial : reprend transfert interrompu
> ```

---

## 🎯 Points clés à retenir

> [!tip] Choisir le bon outil
> 
> - **PuTTY** : léger, stable, universel → connexions SSH simples et tunneling
> - **MobaXterm** : tout-en-un → administration système et usage intensif
> - **WinSCP** : transfert fichiers → développement web et synchronisation
> - **Client natif Windows** : intégré → scripts et automatisation moderne

> [!info] Bonnes pratiques
> 
> - Toujours utiliser l'authentification par clé SSH (pas de mots de passe)
> - Sauvegarder et organiser vos sessions/profils
> - Utiliser Pageant ou MobAgent pour éviter de retaper les passphrases
> - Activer la compression sur connexions lentes
> - Vérifier les empreintes de clés lors de première connexion
> - Journaliser les transferts automatisés pour audit
> - Planifier les tâches répétitives avec Task Scheduler

---

## 🔧 Astuces avancées

### Optimisation des performances

**Réutilisation de connexions SSH (ControlMaster)** :

Bien que cette fonctionnalité soit native à OpenSSH, certains clients tiers peuvent en bénéficier indirectement.

```bash
# Avec le client OpenSSH Windows
# Fichier : C:\Users\VotreNom\.ssh\config

Host prod-*
    ControlMaster auto
    ControlPath C:\Users\VotreNom\.ssh\sockets\%r@%h-%p
    ControlPersist 10m
    ServerAliveInterval 60

# Avantages :
# - Connexions instantanées après la première
# - Partage de tunnel SSH entre sessions
# - Moins de charge sur le serveur
```

**Configuration optimale pour connexions lentes** :

```bash
# PuTTY
Connection > Data > Terminal details
└─ Terminal-type string : xterm-256color

Connection > SSH
├─ Enable compression : cocher
└─ Preferred SSH protocol version : 2 only

Connection > SSH > Cipher
└─ Encryption cipher selection :
   1. aes128-ctr (rapide)
   2. aes128-cbc
   3. 3des-cbc (éviter, très lent)

# WinSCP
Avancé > Connexion
├─ Timeout : augmenter à 60 sec
└─ Algorithme de compression : zlib

# MobaXterm
Session settings > Advanced
├─ Compression : Enabled
└─ Speed optimization : High latency
```

**Batch de connexions multiples** :

```bash
# Script PowerShell pour ouvrir plusieurs sessions
# open-servers.ps1

$servers = @(
    "web01.prod.com",
    "web02.prod.com",
    "db01.prod.com"
)

foreach ($server in $servers) {
    Start-Process "putty.exe" "-load $server"
    Start-Sleep -Milliseconds 500
}

# Ou avec MobaXterm
foreach ($server in $servers) {
    Start-Process "MobaXterm.exe" "-newtab ssh://$server"
}
```

---

### Sécurité renforcée

**Durcissement de la configuration PuTTY** :

```bash
# Connection > SSH > Kex (Key Exchange)
Algorithm selection policy :
├─ curve25519 (priorité max)
├─ ecdh-sha2-nistp256
└─ diffie-hellman-group14-sha256

# Désactiver algorithmes faibles
├─ diffie-hellman-group1-sha1 : décocher
└─ rsa1 : décocher

# Connection > SSH > Host keys
Preferred host key types :
├─ Ed25519
├─ ECDSA
└─ RSA (minimum 2048 bits)

# Connection > SSH > Cipher
Encryption algorithms :
├─ aes256-ctr
├─ aes256-gcm@openssh.com
└─ Éviter : arcfour, 3des-cbc, blowfish
```

**Protection des clés privées** :

```bash
# Toujours utiliser une passphrase forte
PuTTYgen > Key passphrase :
├─ Minimum 15 caractères
├─ Mélange majuscules/minuscules/chiffres/symboles
└─ Phrase mémorisable mais imprévisible

# Stockage sécurisé
C:\Users\VotreNom\.ssh\
├─ Permissions : Lecture seule pour votre compte
├─ Chiffrement EFS (Windows) : clic droit > Propriétés > Avancé > Chiffrer
└─ Sauvegarde chiffrée sur clé USB ou gestionnaire mots de passe

# Renouvellement périodique
# Regénérer les clés tous les 6-12 mois
# Supprimer anciennes clés publiques des serveurs
```

**Audit et surveillance** :

```bash
# PuTTY : enregistrement des sessions
Session > Logging
├─ Session logging : All session output
├─ Log file name : C:\logs\putty-%Y%M%D-%h.log
└─ What to do if log file exists : Append

# WinSCP : logs détaillés
Options > Preferences > Logging
├─ Enable session logging : cocher
├─ Log protocol : détaillé
├─ Log file : C:\logs\winscp-%TIMESTAMP%.log
└─ Log passwords : JAMAIS cocher

# MobaXterm : enregistrement automatique
Settings > Configuration > Terminal
├─ Save terminal output : activé
└─ Location : C:\logs\mobaxterm\
```

> [!warning] Confidentialité des logs Les logs peuvent contenir des informations sensibles. Protégez-les avec des permissions restrictives et nettoyez-les régulièrement.

---

### Intégration avec autres outils

**VS Code Remote-SSH** :

```bash
# Bien que VS Code ait son propre SSH, vous pouvez réutiliser config PuTTY
# Exporter sessions PuTTY vers config OpenSSH

# Script PowerShell : putty-to-openssh.ps1
$sessions = Get-ChildItem "HKCU:\Software\SimonTatham\PuTTY\Sessions"

$config = @()
foreach ($session in $sessions) {
    $name = $session.PSChildName
    $host = (Get-ItemProperty $session.PSPath).HostName
    $user = (Get-ItemProperty $session.PSPath).UserName
    $port = (Get-ItemProperty $session.PSPath).PortNumber
    
    $config += @"
Host $name
    HostName $host
    User $user
    Port $port

"@
}

$config | Out-File -Encoding UTF8 "$env:USERPROFILE\.ssh\config"
```

**Git avec SSH** :

```bash
# Utiliser Pageant pour Git Bash
# Configurer Git pour utiliser plink (PuTTY)

# Méthode 1 : Variable d'environnement
setx GIT_SSH "C:\Program Files\PuTTY\plink.exe"

# Méthode 2 : Configuration Git
git config --global core.sshCommand "C:/Program\ Files/PuTTY/plink.exe"

# Vérification
git clone git@github.com:user/repo.git
# Utilise automatiquement Pageant pour l'authentification

# Ou avec MobaXterm
# Le MobAgent remplace Pageant automatiquement
```

**Docker avec SSH tunnel** :

```bash
# Accéder à Docker distant via tunnel SSH
# Configuration PuTTY : Local forwarding
Source port : 2375
Destination : localhost:2375

# Après connexion SSH avec tunnel
# Dans PowerShell/CMD
$env:DOCKER_HOST = "tcp://localhost:2375"
docker ps
# Commande exécutée sur serveur distant via tunnel sécurisé

# Ou avec WinSCP script
winscp.com /command ^
    "open sftp://user@dockerhost" ^
    "call docker ps" ^
    "exit"
```

**Ansible avec PuTTY** :

```bash
# Ansible sur Windows peut utiliser plink
# ansible.cfg
[defaults]
host_key_checking = False
remote_user = admin

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
# Utilise Pageant pour authentification

# Inventory (hosts.ini)
[webservers]
web01.prod.com
web02.prod.com

[databases]
db01.prod.com

# Playbook
ansible webservers -i hosts.ini -m ping
# Utilise les clés chargées dans Pageant
```

---

### Dépannage avancé

**Problèmes d'encodage de caractères** :

```bash
# PuTTY affiche mal les accents/caractères spéciaux
Window > Translation
├─ Remote character set : UTF-8
├─ Handling of line drawing : Use Unicode
└─ CJK ambiguous characters : Wide (pour caractères asiatiques)

# WinSCP
Options > Preferences > Transfer > Text
└─ Transfer mode : Text (with UTF-8 encoding)

# MobaXterm
Settings > Configuration > Terminal
└─ Default charset : UTF-8
```

**Problèmes de permissions SFTP** :

```bash
# Erreur "Permission denied" lors de l'upload
# Vérifier sur le serveur :

# Permissions du répertoire de destination
ls -la /path/to/destination/
# Doit être writable par votre utilisateur

# Propriétaire
chown -R votre_user:votre_groupe /path/to/destination/

# Permissions standard
chmod 755 /path/to/destination/  # Dossiers
chmod 644 /path/to/destination/*  # Fichiers

# Si utilisation de SFTP chroot
# Vérifier /etc/ssh/sshd_config
Match User votre_user
    ChrootDirectory /home/votre_user
    ForceCommand internal-sftp
    AllowTcpForwarding no

# Le ChrootDirectory doit appartenir à root
chown root:root /home/votre_user
chmod 755 /home/votre_user
```

**Debugging connexion SSH** :

```bash
# PuTTY : mode debug
# Créer un fichier .bat pour lancer avec logs détaillés
@echo off
"C:\Program Files\PuTTY\putty.exe" -v -load "votre-session" > putty-debug.log 2>&1

# Plink : mode très verbeux
plink.exe -v -v -v user@serveur 2> debug.txt

# Analyser les logs pour identifier :
├─ Tentatives d'authentification
├─ Algorithmes de chiffrement négociés
├─ Erreurs de clé ou de certificat
└─ Timeouts réseau

# WinSCP : session log XML
winscp.com /log="session.xml" /xmllog="session-detailed.xml" /command ...
# Ouvrir avec navigateur pour analyse structurée
```

**Récupération après plantage** :

```bash
# PuTTY : sessions bloquées
# Tuer processus orphelins
taskkill /F /IM putty.exe

# Nettoyer les tunnels restants
netstat -ano | findstr :XXXX  # XXXX = port du tunnel
taskkill /F /PID <PID>

# MobaXterm : réinitialisation configuration
# Sauvegarder d'abord
C:\Users\VotreNom\Documents\MobaXterm\
├─ MobaXterm.ini (configuration)
├─ Sessions\ (sessions sauvegardées)
└─ Home\ (.ssh, scripts, etc.)

# En cas de corruption, supprimer MobaXterm.ini
# Au redémarrage, configuration par défaut restaurée

# WinSCP : corruption de cache
# Supprimer cache
%APPDATA%\WinSCP\
└─ Cache\ (supprimer tout le contenu)
```

---

### Personnalisation avancée

**Thèmes et apparence** :

```bash
# PuTTY : schéma de couleurs personnalisé
Window > Colours

# Thème Solarized Dark (exemple)
Default Foreground : R131 G148 B150
Default Background : R  0 G  43 B  54
Cursor Text        : R  0 G  43 B  54
Cursor Colour      : R131 G148 B150

# Exporter/Importer thème via registre
# Export
regedit > HKCU\Software\SimonTatham\PuTTY\Sessions\VotreTheme
> Export > theme.reg

# MobaXterm : thèmes prédéfinis
Settings > Configuration > Terminal > Terminal colors
├─ Solarized Dark
├─ Monokai
├─ Dracula
└─ Custom (personnalisé)

# Police avec ligatures (pour développeurs)
Window > Appearance > Font
├─ Fira Code
├─ JetBrains Mono
├─ Cascadia Code
└─ Size: 10-12 pt
```

**Macros et snippets** :

```bash
# MobaXterm : macros personnalisées
Tools > Macros > New macro

# Exemple : Monitoring système
Macro name: SysMonitor
Commands:
  echo "=== System Monitoring ==="
  uptime
  free -h
  df -h
  top -b -n 1 | head -20

# Assigner raccourci : Ctrl+Shift+M

# PuTTY : simuler macros avec scripts AutoHotkey
; putty-macros.ahk
^!s::  ; Ctrl+Alt+S pour envoyer commande
Send, sudo systemctl status nginx{Enter}
return

^!r::  ; Ctrl+Alt+R pour restart
Send, sudo systemctl restart nginx{Enter}
return
```

**Profils contextuels** :

```bash
# Créer profils par environnement
# Structure recommandée

PuTTY Sessions:
├─ PROD/
│  ├─ web-01
│  ├─ web-02
│  └─ db-master
├─ STAGING/
│  ├─ staging-web
│  └─ staging-db
└─ DEV/
   └─ dev-server

# Couleurs par environnement (éviter erreurs)
PROD   : Fond noir, texte rouge (prudence)
STAGING: Fond bleu foncé, texte blanc
DEV    : Fond vert foncé, texte blanc

# WinSCP : même organisation
Sites/
├─ Production/
├─ Staging/
└─ Development/
```

---

## 📊 Tableaux de référence rapide

### Raccourcis clavier essentiels

#### PuTTY

|Raccourci|Action|
|---|---|
|`Ctrl+C`|Copier (sélection auto)|
|`Shift+Insert`|Coller|
|`Clic droit`|Coller (alternatif)|
|`Alt+Enter`|Plein écran|
|`Ctrl+Clic droit`|Menu contextuel|

#### MobaXterm

|Raccourci|Action|
|---|---|
|`Ctrl+Shift+C`|Copier|
|`Ctrl+Shift+V`|Coller|
|`Ctrl+T`|Nouvel onglet|
|`Ctrl+W`|Fermer onglet|
|`Ctrl+Tab`|Onglet suivant|
|`Ctrl+Shift+T`|Rouvrir onglet fermé|
|`Ctrl+F`|Rechercher dans terminal|
|`F11`|Plein écran|

#### WinSCP

|Raccourci|Action|
|---|---|
|`F3`|Voir fichier|
|`F4`|Éditer fichier|
|`F5`|Copier (Upload)|
|`F6`|Déplacer|
|`F7`|Nouveau dossier|
|`F8`|Supprimer|
|`Ctrl+P`|Ouvrir PuTTY|
|`Ctrl+S`|Synchroniser|
|`Alt+F7`|Rechercher fichiers|

---

### Commandes CLI équivalentes

|Opération|PuTTY/Plink|MobaXterm|WinSCP|
|---|---|---|---|
|**Connexion simple**|`plink user@host`|`ssh user@host`|`winscp.com sftp://user@host`|
|**Avec clé**|`plink -i key.ppk`|`ssh -i key`|`winscp.com /privatekey=key.ppk`|
|**Port forwarding**|`plink -L 3306:db:3306`|`ssh -L 3306:db:3306`|(via session settings)|
|**Upload fichier**|`pscp file user@host:/path`|`scp file user@host:/path`|`winscp.com /command "put file"`|
|**Download fichier**|`pscp user@host:/file .`|`scp user@host:/file .`|`winscp.com /command "get file"`|
|**Exécution commande**|`plink user@host "cmd"`|`ssh user@host "cmd"`|`winscp.com /command "call cmd"`|

---

### Ports standards par protocole

|Protocole|Port|Usage|Client recommandé|
|---|---|---|---|
|SSH|22|Shell distant, SFTP|PuTTY, MobaXterm|
|Telnet|23|Shell non chiffré (obsolète)|MobaXterm|
|FTP|21|Transfert fichiers non chiffré|WinSCP|
|FTPS|990|FTP sécurisé (SSL/TLS)|WinSCP|
|SFTP|22|Transfert via SSH|WinSCP, MobaXterm|
|SCP|22|Copie sécurisée|Tous (via SSH)|
|RDP|3389|Bureau distant Windows|MobaXterm|
|VNC|5900+|Bureau distant multi-OS|MobaXterm|
|HTTP|80|Web non chiffré|Tunneling SSH|
|HTTPS|443|Web chiffré|Tunneling SSH|

---

## 🎓 Conclusion

Les clients SSH tiers pour Windows offrent des fonctionnalités bien au-delà du client natif, répondant à des besoins variés selon les profils d'utilisateurs.

**Récapitulatif des forces** :

- **PuTTY** : La référence historique, légère et fiable. Idéale pour l'essentiel SSH et le tunneling avancé.
- **MobaXterm** : Le couteau suisse moderne. Parfait pour les administrateurs et utilisateurs intensifs multi-serveurs.
- **WinSCP** : Le spécialiste du transfert de fichiers. Imbattable pour la synchronisation et l'automatisation SFTP.

**Recommandation finale** :

Pour une utilisation professionnelle complète, **combinez les outils** selon vos besoins :

- Base : **MobaXterm** pour l'administration quotidienne
- Complément : **WinSCP** pour les transferts massifs et l'automatisation
- Portable : **PuTTY** sur clé USB pour dépannages et environnements restreints

L'investissement dans la maîtrise de ces outils se rentabilise rapidement par le gain de temps et la réduction d'erreurs dans les opérations quotidiennes d'administration système et de développement.

> [!success] Vous maîtrisez maintenant ✅ Configuration et optimisation de PuTTY, MobaXterm et WinSCP ✅ Gestion avancée des clés SSH et authentification ✅ Tunneling et port forwarding pour sécuriser vos connexions ✅ Transfert et synchronisation de fichiers efficaces ✅ Automatisation avec scripts et planification ✅ Dépannage des problèmes courants ✅ Choix du bon outil selon le contexte

---

_Cours créé pour Obsidian - Partie : Clients SSH tiers pour Windows_