

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

## 🔰 Introduction à SFTP

### Qu'est-ce que SFTP ?

**SFTP (SSH File Transfer Protocol)** est un protocole de transfert de fichiers sécurisé qui fonctionne sur SSH. Contrairement à son nom, ce n'est **pas** une version de FTP, mais un protocole complètement différent.

> [!info] SFTP vs FTP
> 
> - **SFTP** : Utilise SSH (port 22), chiffré de bout en bout, une seule connexion
> - **FTP** : Ports 20/21, non chiffré par défaut, connexions multiples
> - **FTPS** : FTP avec SSL/TLS, différent de SFTP

### Pourquoi utiliser SFTP ?

- ✅ **Sécurité** : Tout le trafic est chiffré (authentification + données)
- ✅ **Simplicité** : Une seule connexion, un seul port (22)
- ✅ **Compatibilité** : Fonctionne partout où SSH est disponible
- ✅ **Fiabilité** : Gestion robuste des erreurs et reprise de transfert
- ✅ **Fonctionnalités avancées** : Permissions, propriétaires, liens symboliques

> [!tip] Quand utiliser SFTP ?
> 
> - Transfert de fichiers vers/depuis des serveurs distants
> - Automatisation de sauvegardes sécurisées
> - Synchronisation de données entre machines
> - Alternative sécurisée à FTP

---

## 🔌 Connexion SFTP interactive

### Syntaxe de base

```bash
# Connexion simple
sftp utilisateur@serveur

# Avec port personnalisé
sftp -P 2222 utilisateur@serveur

# Avec clé SSH spécifique
sftp -i ~/.ssh/ma_cle utilisateur@serveur

# Verbose (débogage)
sftp -v utilisateur@serveur
```

> [!warning] Attention au -P majuscule SFTP utilise `-P` (majuscule) pour le port, contrairement à SSH qui utilise `-p` (minuscule).

### Options de connexion courantes

|Option|Description|Exemple|
|---|---|---|
|`-P port`|Spécifier un port|`sftp -P 2222 user@host`|
|`-i fichier`|Clé privée à utiliser|`sftp -i ~/.ssh/key user@host`|
|`-v`|Mode verbeux|`sftp -v user@host`|
|`-C`|Activer la compression|`sftp -C user@host`|
|`-o option`|Options SSH|`sftp -o "StrictHostKeyChecking=no"`|
|`-b fichier`|Mode batch (script)|`sftp -b commandes.txt user@host`|

### Exemple de connexion

```bash
# Connexion standard
sftp admin@192.168.1.100

# Sortie attendue :
# Connected to 192.168.1.100.
# sftp>
```

> [!example] Première connexion Lors de la première connexion, vous devrez confirmer l'empreinte du serveur, comme avec SSH :
> 
> ```
> The authenticity of host '192.168.1.100 (192.168.1.100)' can't be established.
> ECDSA key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
> Are you sure you want to continue connecting (yes/no)? yes
> ```

### Déconnexion

```bash
# Trois façons de quitter SFTP
sftp> quit
sftp> exit
sftp> bye
```

---

## 📦 Commandes SFTP essentielles

### Navigation et exploration

#### Commandes locales vs distantes

SFTP maintient **deux répertoires courants** : un local et un distant. Les commandes préfixées par `l` (local) agissent sur votre machine.

```bash
# COMMANDES DISTANTES (serveur)
sftp> pwd              # Afficher le répertoire distant actuel
sftp> ls               # Lister les fichiers distants
sftp> ls -la           # Liste détaillée avec fichiers cachés
sftp> cd /var/www      # Changer de répertoire distant
sftp> mkdir backup     # Créer un répertoire distant

# COMMANDES LOCALES (votre machine)
sftp> lpwd             # Afficher le répertoire local actuel
sftp> lls              # Lister les fichiers locaux
sftp> lls -la          # Liste détaillée locale
sftp> lcd /tmp         # Changer de répertoire local
sftp> lmkdir backup    # Créer un répertoire local
```

> [!tip] Mémorisation Pensez au **"l"** comme **"local"** : `ls` = serveur, `lls` = local

#### Exemples pratiques de navigation

```bash
sftp> pwd
Remote working directory: /home/admin

sftp> lpwd
Local working directory: /home/user/downloads

sftp> ls
file1.txt    file2.txt    documents/

sftp> lls
local_file.txt    backup/

sftp> cd documents
sftp> pwd
Remote working directory: /home/admin/documents

sftp> lcd ~/backup
sftp> lpwd
Local working directory: /home/user/backup
```

### Téléchargement de fichiers (get)

#### Syntaxe de base

```bash
# Télécharger un fichier
sftp> get fichier_distant.txt

# Télécharger avec nouveau nom
sftp> get fichier_distant.txt fichier_local.txt

# Télécharger vers un répertoire spécifique
sftp> get fichier.txt /tmp/fichier.txt

# Télécharger un répertoire (récursif)
sftp> get -r dossier_distant/

# Télécharger avec préservation des attributs
sftp> get -P fichier.txt
```

> [!info] Option -P (preserve) L'option `-P` préserve les permissions, dates de modification et temps d'accès du fichier original.

#### Téléchargement multiple avec wildcards

```bash
# Télécharger tous les fichiers .txt
sftp> get *.txt

# Télécharger tous les fichiers commençant par "backup"
sftp> get backup*

# Télécharger tous les .log et .conf
sftp> mget *.log *.conf
```

> [!warning] Limitation des wildcards Les wildcards ne fonctionnent que dans le répertoire courant, pas récursivement dans les sous-dossiers.

#### Exemples pratiques

```bash
# Scénario : Télécharger les logs d'une application
sftp> cd /var/log/myapp
sftp> lcd ~/logs
sftp> get -r logs/
# Télécharge récursivement le dossier logs/

# Scénario : Récupérer une sauvegarde
sftp> get /backup/database_20231215.sql.gz
# Télécharge dans le répertoire local courant

# Scénario : Télécharger avec progression
sftp> get -P large_file.zip
Fetching /home/user/large_file.zip to large_file.zip
/home/user/large_file.zip                    45% 2301MB  15.2MB/s   00:42 ETA
```

### Envoi de fichiers (put)

#### Syntaxe de base

```bash
# Envoyer un fichier
sftp> put fichier_local.txt

# Envoyer avec nouveau nom
sftp> put fichier_local.txt fichier_distant.txt

# Envoyer vers un chemin spécifique
sftp> put fichier.txt /var/www/html/fichier.txt

# Envoyer un répertoire (récursif)
sftp> put -r dossier_local/

# Envoyer avec préservation des attributs
sftp> put -P fichier.txt
```

#### Envoi multiple

```bash
# Envoyer tous les fichiers .jpg
sftp> put *.jpg

# Envoyer plusieurs fichiers spécifiques
sftp> mput file1.txt file2.txt file3.txt

# Envoyer avec confirmation interactive
sftp> mput -i *.txt
mput file1.txt? y
mput file2.txt? n
mput file3.txt? y
```

#### Exemples pratiques

```bash
# Scénario : Déployer une application web
sftp> cd /var/www/html
sftp> lcd ~/projects/myapp
sftp> put -r public/
# Envoie récursivement le dossier public/

# Scénario : Backup de configuration
sftp> put /etc/nginx/nginx.conf /backup/nginx.conf.bak

# Scénario : Upload multiple avec filtre
sftp> lcd ~/photos
sftp> cd /storage/photos
sftp> mput vacation_*.jpg
```

### Gestion des fichiers et répertoires

#### Création et suppression

```bash
# Créer un répertoire distant
sftp> mkdir backup
sftp> mkdir -p backup/2023/12  # Créer récursivement (si supporté)

# Supprimer un fichier distant
sftp> rm fichier.txt

# Supprimer un répertoire distant (doit être vide)
sftp> rmdir backup/

# Renommer/déplacer un fichier distant
sftp> rename ancien.txt nouveau.txt
sftp> rename file.txt /archive/file.txt
```

> [!warning] Suppression de répertoires `rmdir` ne fonctionne que sur des répertoires **vides**. Pour supprimer un répertoire avec son contenu, vous devez d'abord supprimer tous les fichiers qu'il contient.

#### Gestion des permissions

```bash
# Changer les permissions (distant)
sftp> chmod 644 fichier.txt
sftp> chmod 755 script.sh

# Changer le propriétaire (distant, nécessite root)
sftp> chown utilisateur fichier.txt
sftp> chgrp groupe fichier.txt

# Créer un lien symbolique (distant)
sftp> symlink cible lien
sftp> ln -s /var/www/html/app current
```

#### Informations sur les fichiers

```bash
# Statistiques détaillées d'un fichier
sftp> stat fichier.txt
File: /home/user/fichier.txt
Size: 1024        Blocks: 8          IO Block: 4096   regular file
Permissions: 0644  Uid: 1000   Gid: 1000

# Vérifier le type de fichier
sftp> ls -l fichier.txt
-rw-r--r--   1 user  group    1024 Dec 15 10:30 fichier.txt

# Afficher l'espace disque (si supporté)
sftp> df -h
    Size     Used    Avail   (root)    %Capacity
  99.9GB   45.2GB   49.5GB   54.7GB          45%
```

### Commandes avancées

#### Affichage du contenu

```bash
# Afficher l'espace disque du serveur distant
sftp> df
# ou
sftp> df -h    # Format lisible

# Obtenir la version du protocole
sftp> version
SFTP protocol version 3

# Afficher l'aide
sftp> help
# ou
sftp> ?
```

#### Commandes système locales

```bash
# Exécuter une commande shell locale (préfixe !)
sftp> !pwd
/home/user/downloads

sftp> !ls -la
total 48
drwxr-xr-x  3 user group  4096 Dec 15 10:30 .
drwxr-xr-x 25 user group  4096 Dec 15 09:15 ..

sftp> !cat /etc/hostname
my-laptop

# Ouvrir un shell local temporaire
sftp> !bash
$ # Vous êtes maintenant dans un shell local
$ ls
$ exit
sftp> # Retour à SFTP
```

> [!tip] Commandes locales rapides Le préfixe `!` vous permet d'exécuter n'importe quelle commande sur votre machine locale sans quitter SFTP.

### Tableau récapitulatif des commandes

|Commande|Description|Équivalent local|
|---|---|---|
|`pwd`|Répertoire distant actuel|`lpwd`|
|`ls`|Liste fichiers distants|`lls`|
|`cd`|Changer répertoire distant|`lcd`|
|`mkdir`|Créer répertoire distant|`lmkdir`|
|`get`|Télécharger fichier|-|
|`put`|Envoyer fichier|-|
|`rm`|Supprimer fichier distant|-|
|`rmdir`|Supprimer répertoire distant|-|
|`rename`|Renommer/déplacer distant|-|
|`chmod`|Changer permissions distant|`lchmod`|
|`df`|Espace disque distant|-|
|`!cmd`|Exécuter commande locale|-|

---

## 🤖 Mode batch et automatisation

### Qu'est-ce que le mode batch ?

Le mode batch permet d'exécuter des commandes SFTP de manière **non interactive**, idéal pour l'automatisation et les scripts.

> [!info] Avantages du mode batch
> 
> - Exécution automatique sans interaction humaine
> - Répétabilité des opérations
> - Intégration dans des scripts et tâches planifiées
> - Gestion d'erreurs programmable

### Créer un fichier de commandes

#### Exemple simple

Créez un fichier `commandes_sftp.txt` :

```bash
# commandes_sftp.txt
cd /var/www/html
lcd ~/backup
get -r public/
put backup.tar.gz
chmod 644 backup.tar.gz
bye
```

Exécution :

```bash
sftp -b commandes_sftp.txt utilisateur@serveur
```

> [!tip] Commentaires dans les fichiers batch Les lignes commençant par `#` sont des commentaires et seront ignorées.

#### Exemple avancé avec gestion d'erreur

```bash
# backup_automatique.txt
# Script SFTP pour sauvegarde quotidienne

# Aller dans le répertoire de sauvegarde distant
cd /backup/daily

# Créer un dossier pour aujourd'hui
mkdir backup_$(date +%Y%m%d)
cd backup_$(date +%Y%m%d)

# Se positionner localement
lcd /var/log

# Uploader les logs
put -r logs/
put application.log

# Permissions
chmod 640 *.log

# Quitter
quit
```

> [!warning] Variables dans les fichiers batch Les variables shell comme `$(date +%Y%m%d)` **ne sont pas** évaluées dans les fichiers de commandes SFTP. Vous devez les générer avant.

### Automatisation avec scripts shell

#### Script de sauvegarde complet

```bash
#!/bin/bash
# backup_sftp.sh - Script de sauvegarde automatique via SFTP

# Configuration
SERVER="backup.example.com"
USER="backup_user"
KEY="/home/user/.ssh/backup_key"
LOCAL_DIR="/var/app/data"
REMOTE_DIR="/backups/myapp"
DATE=$(date +%Y%m%d_%H%M%S)

# Créer une archive locale
echo "Création de l'archive..."
tar -czf /tmp/backup_${DATE}.tar.gz ${LOCAL_DIR}

# Générer le fichier de commandes SFTP
cat > /tmp/sftp_commands_${DATE}.txt <<EOF
cd ${REMOTE_DIR}
put /tmp/backup_${DATE}.tar.gz
chmod 600 backup_${DATE}.tar.gz
ls -l backup_*
bye
EOF

# Exécuter SFTP en mode batch
echo "Transfert vers le serveur..."
sftp -i ${KEY} -b /tmp/sftp_commands_${DATE}.txt ${USER}@${SERVER}

# Vérifier le résultat
if [ $? -eq 0 ]; then
    echo "✅ Sauvegarde réussie : backup_${DATE}.tar.gz"
    # Nettoyer les fichiers temporaires
    rm /tmp/backup_${DATE}.tar.gz
    rm /tmp/sftp_commands_${DATE}.txt
else
    echo "❌ Erreur lors de la sauvegarde"
    exit 1
fi
```

Rendre le script exécutable et le tester :

```bash
chmod +x backup_sftp.sh
./backup_sftp.sh
```

#### Script de synchronisation bidirectionnelle

```bash
#!/bin/bash
# sync_sftp.sh - Synchronisation de fichiers via SFTP

SERVER="data.example.com"
USER="sync_user"
LOCAL_DIR="/home/user/shared"
REMOTE_DIR="/shared"

# Fichier de commandes temporaire
SFTP_BATCH=$(mktemp)

# Générer les commandes SFTP dynamiquement
cat > ${SFTP_BATCH} <<EOF
# Télécharger les nouveaux fichiers du serveur
cd ${REMOTE_DIR}
lcd ${LOCAL_DIR}
get -R *

# Envoyer les fichiers locaux
put -R ${LOCAL_DIR}/*

# Quitter
bye
EOF

# Exécuter avec gestion d'erreur
if sftp -b ${SFTP_BATCH} ${USER}@${SERVER} 2>&1 | tee /tmp/sftp_sync.log; then
    echo "Synchronisation terminée"
else
    echo "Erreur de synchronisation, voir /tmp/sftp_sync.log"
fi

# Nettoyer
rm ${SFTP_BATCH}
```

### Automatisation avec expect (interaction scriptée)

Pour les cas où vous avez besoin d'entrer un mot de passe :

```bash
#!/usr/bin/expect -f
# sftp_expect.sh - SFTP avec authentification par mot de passe

set timeout 30
set server "example.com"
set user "myuser"
set password "MySecretPassword"

spawn sftp ${user}@${server}
expect "password:"
send "${password}\r"

expect "sftp>"
send "cd /uploads\r"

expect "sftp>"
send "put local_file.txt\r"

expect "sftp>"
send "quit\r"

expect eof
```

> [!warning] Sécurité des mots de passe Évitez de stocker des mots de passe en clair dans des scripts. Préférez l'authentification par clés SSH.

### Planification avec cron

#### Exemple de tâche cron

```bash
# Éditer le crontab
crontab -e

# Ajouter une sauvegarde quotidienne à 2h du matin
0 2 * * * /home/user/scripts/backup_sftp.sh >> /var/log/backup_sftp.log 2>&1

# Sauvegarde toutes les 6 heures
0 */6 * * * /home/user/scripts/backup_sftp.sh

# Synchronisation du lundi au vendredi à 18h
0 18 * * 1-5 /home/user/scripts/sync_sftp.sh
```

#### Script avec rotation des logs

```bash
#!/bin/bash
# backup_cron.sh - Script pour cron avec rotation de logs

LOGFILE="/var/log/backup_sftp.log"
MAXSIZE=10485760  # 10 MB

# Rotation du log si trop gros
if [ -f ${LOGFILE} ] && [ $(stat -f%z ${LOGFILE}) -gt ${MAXSIZE} ]; then
    mv ${LOGFILE} ${LOGFILE}.old
fi

# Timestamp
echo "========================================" >> ${LOGFILE}
echo "Backup started: $(date)" >> ${LOGFILE}

# Exécuter le backup
/home/user/scripts/backup_sftp.sh >> ${LOGFILE} 2>&1

# Résultat
if [ $? -eq 0 ]; then
    echo "Backup completed: $(date)" >> ${LOGFILE}
else
    echo "Backup FAILED: $(date)" >> ${LOGFILE}
    # Envoyer une alerte email
    echo "Backup failed on $(hostname)" | mail -s "SFTP Backup Error" admin@example.com
fi
```

### Gestion d'erreurs avancée

```bash
#!/bin/bash
# backup_robust.sh - Script avec gestion d'erreurs robuste

set -euo pipefail  # Arrêt en cas d'erreur

# Configuration
SERVER="backup.example.com"
USER="backup"
KEY="~/.ssh/backup_key"

# Fonction de cleanup
cleanup() {
    rm -f /tmp/sftp_commands_*.txt
    rm -f /tmp/backup_*.tar.gz
}

# Trap pour cleanup en cas d'erreur ou d'interruption
trap cleanup EXIT INT TERM

# Vérifier que le serveur est accessible
if ! ping -c 1 ${SERVER} &> /dev/null; then
    echo "❌ Serveur ${SERVER} inaccessible"
    exit 1
fi

# Vérifier que la clé SSH existe
if [ ! -f ${KEY} ]; then
    echo "❌ Clé SSH ${KEY} introuvable"
    exit 1
fi

# Test de connexion SFTP
echo "quit" | sftp -i ${KEY} -o ConnectTimeout=10 ${USER}@${SERVER} &> /dev/null
if [ $? -ne 0 ]; then
    echo "❌ Impossible de se connecter via SFTP"
    exit 1
fi

# Continuer avec le backup...
echo "✅ Tous les tests réussis, démarrage du backup"

# ... reste du script ...
```

### Astuces d'automatisation

> [!tip] Bonnes pratiques
> 
> 1. **Toujours utiliser des clés SSH** plutôt que des mots de passe
> 2. **Loguer toutes les opérations** pour le débogage
> 3. **Implémenter des vérifications** avant les opérations critiques
> 4. **Utiliser des fichiers temporaires** avec `mktemp` pour la sécurité
> 5. **Mettre en place des notifications** en cas d'échec
> 6. **Tester les scripts** avant de les automatiser

> [!warning] Pièges courants
> 
> - Ne pas vérifier l'espace disque avant un transfert
> - Oublier de gérer les erreurs réseau
> - Ne pas prévoir de rotation des logs
> - Utiliser des chemins relatifs au lieu de chemins absolus
> - Ne pas tester les restaurations de sauvegardes

---

## 🖥️ Clients SFTP graphiques

Pour les utilisateurs préférant une interface graphique, plusieurs clients SFTP excellents existent.

### FileZilla

**FileZilla** est l'un des clients FTP/SFTP gratuits les plus populaires et complets.

#### Installation

```bash
# Ubuntu/Debian
sudo apt install filezilla

# Fedora
sudo dnf install filezilla

# Arch Linux
sudo pacman -S filezilla
```

#### Caractéristiques principales

- ✅ Interface à deux panneaux (local / distant)
- ✅ Glisser-déposer pour transferts
- ✅ Gestionnaire de sites pour sauvegarder les connexions
- ✅ File d'attente de transferts
- ✅ Reprise de transferts interrompus
- ✅ Comparaison de répertoires
- ✅ Support SFTP, FTP, FTPS

#### Configuration d'une connexion SFTP

1. **Ouvrir le Gestionnaire de Sites** : `Fichier > Gestionnaire de sites` (Ctrl+S)
2. **Créer un nouveau site** : Cliquer sur "Nouveau site"
3. **Configurer les paramètres** :
    - **Protocole** : SFTP - SSH File Transfer Protocol
    - **Hôte** : adresse du serveur
    - **Port** : 22 (par défaut)
    - **Type d'authentification** :
        - "Normale" pour mot de passe
        - "Fichier de clés" pour clé SSH
    - **Utilisateur** : votre nom d'utilisateur
    - **Mot de passe** : (si authentification par mot de passe)
    - **Fichier de clés** : chemin vers votre clé privée (si applicable)

> [!tip] Convertir les clés SSH pour FileZilla FileZilla utilise le format PuTTY (.ppk) pour les clés. Convertissez votre clé avec :
> 
> ```bash
> # Installer puttygen
> sudo apt install putty-tools
> 
> # Convertir la clé
> puttygen ~/.ssh/id_rsa -o ~/.ssh/id_rsa.ppk -O private
> ```

### WinSCP (via Wine sur Linux)

**WinSCP** est un excellent client Windows qui peut fonctionner sur Linux via Wine.

#### Installation avec Wine

```bash
# Installer Wine
sudo apt install wine winetricks

# Télécharger et installer WinSCP
wget https://winscp.net/download/WinSCP-X.XX.X-Setup.exe
wine WinSCP-X.XX.X-Setup.exe
```

#### Fonctionnalités notables

- ✅ Interface type Norton Commander ou Explorer
- ✅ Synchronisation de répertoires
- ✅ Éditeur de texte intégré
- ✅ Générateur de scripts
- ✅ Recherche de fichiers distants

> [!info] Alternative native Pour une solution 100% Linux, préférez FileZilla ou Cyberduck.

### Cyberduck

**Cyberduck** est un client élégant et moderne, natif pour Linux.

#### Installation

```bash
# Via Snap
sudo snap install cyberduck

# Via Flatpak
flatpak install flathub org.cyberduck.Cyberduck
```

#### Points forts

- ✅ Interface épurée et intuitive
- ✅ Support de nombreux protocoles (SFTP, S3, WebDAV, etc.)
- ✅ Intégration avec les éditeurs externes
- ✅ Prévisualisation de fichiers
- ✅ Synchronisation et sauvegardes
- ✅ Cryptographie côté client

### Nautilus (gestionnaire de fichiers GNOME)

Le gestionnaire de fichiers par défaut de GNOME peut se connecter directement aux serveurs SFTP.

#### Utilisation

1. Ouvrir Nautilus
2. Dans la barre d'adresse, taper : `sftp://utilisateur@serveur`
3. Ou via le menu : `Autres emplacements` > `Se connecter au serveur`

```bash
# Format de l'URL
sftp://utilisateur@serveur:port/chemin

# Exemples
sftp://admin@192.168.1.100
sftp://user@example.com:2222/var/www
```

> [!tip] Montage permanent Nautilus peut sauvegarder la connexion pour un accès rapide ultérieur. Les serveurs connectés apparaissent dans la barre latérale.

#### Avantages

- ✅ Déjà installé sur GNOME
- ✅ Intégration native avec le système
- ✅ Pas d'application supplémentaire
- ✅ Utilise vos clés SSH existantes automatiquement

### Dolphin (gestionnaire de fichiers KDE)

Le gestionnaire de fichiers de KDE Plasma supporte également SFTP nativement.

#### Utilisation

1. Ouvrir Dolphin
2. Dans la barre d'adresse : `sftp://utilisateur@serveur`
3. Ou via : `Réseau` > `Ajouter un dossier réseau`

```bash
# Format identique à Nautilus
sftp://utilisateur@serveur:port/chemin
```

### Midnight Commander (mc)

**Midnight Commander** est un gestionnaire de fichiers en mode texte avec support SFTP intégré.

#### Installation

```bash
# Ubuntu/Debian
sudo apt install mc

# Fedora
sudo dnf install mc

# Arch Linux
sudo pacman -S mc
```

#### Connexion SFTP

```bash
# Lancer mc
mc

# Appuyer sur F9 pour le menu
# Choisir "Droite" ou "Gauche" > "Connexion SFTP"

# Ou directement dans le panneau :
# Appuyer sur F9 > Menu droite > Shell SFTP
# Entrer : utilisateur@serveur
```

> [!tip] Raccourcis Midnight Commander
> 
> - **F9** : Menu principal
> - **F5** : Copier
> - **F6** : Déplacer/Renommer
> - **F8** : Supprimer
> - **Ctrl+O** : Afficher/masquer les panneaux

#### Avantages pour l'administration

- ✅ Fonctionne en SSH (pas besoin de X11)
- ✅ Léger et rapide
- ✅ Idéal pour les serveurs sans interface graphique
- ✅ Deux panneaux pour transferts faciles

### Comparaison des clients

|Client|Type|Facilité|Fonctionnalités|Usage recommandé|
|---|---|---|---|---|
|**FileZilla**|Graphique|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|Usage quotidien, transferts volumineux|
|**Cyberduck**|Graphique|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|Interface moderne, cloud|
|**Nautilus**|Graphique|⭐⭐⭐⭐⭐|⭐⭐⭐|Intégration bureau GNOME|
|**Dolphin**|Graphique|⭐⭐⭐⭐⭐|⭐⭐⭐|Intégration bureau KDE|
|**Midnight Commander**|Terminal|⭐⭐⭐|⭐⭐⭐⭐|Administration serveur, SSH|
|**WinSCP**|Graphique (Wine)|⭐⭐⭐|⭐⭐⭐⭐⭐|Windows émulé, scripts|

### Clients en ligne de commande alternatifs

#### lftp

**lftp** est un client FTP/SFTP sophistiqué en ligne de commande avec de nombreuses fonctionnalités avancées.

##### Installation

```bash
# Ubuntu/Debian
sudo apt install lftp

# Fedora
sudo dnf install lftp

# Arch Linux
sudo pacman -S lftp
```

##### Utilisation avec SFTP

```bash
# Connexion SFTP
lftp sftp://utilisateur@serveur

# Avec port personnalisé
lftp -p 2222 sftp://utilisateur@serveur

# Avec clé SSH
lftp -u utilisateur, -p 22 sftp://serveur
```

##### Fonctionnalités avancées

```bash
# Miroir (synchronisation complète)
lftp> mirror /remote/path /local/path

# Miroir inverse (upload)
lftp> mirror -R /local/path /remote/path

# Téléchargement parallèle (segments)
lftp> pget -n 4 gros_fichier.iso

# Téléchargement avec bande passante limitée
lftp> set net:limit-rate 1000000  # 1 MB/s
lftp> get fichier.zip

# Queue de téléchargements
lftp> queue get fichier1.txt
lftp> queue get fichier2.txt
lftp> queue start

# Bookmarks
lftp> bookmark add mon_serveur
lftp> bookmark list
lftp> open mon_serveur
```

> [!tip] Avantages de lftp
> 
> - **Mirror intelligent** : synchronise uniquement les différences
> - **Reprise automatique** : continue après interruption
> - **Téléchargement parallèle** : plusieurs connexions simultanées
> - **Scriptable** : excellent pour l'automatisation

##### Script lftp pour automatisation

```bash
#!/bin/bash
# sync_lftp.sh - Synchronisation avec lftp

lftp -c "
set sftp:auto-confirm yes
set ssl:verify-certificate no
open sftp://user@server
lcd /local/path
cd /remote/path
mirror --verbose --use-cache --reverse --delete
bye
"
```

#### sshfs (montage SFTP comme système de fichiers)

**sshfs** permet de monter un répertoire distant via SFTP comme s'il s'agissait d'un disque local.

##### Installation

```bash
# Ubuntu/Debian
sudo apt install sshfs

# Fedora
sudo dnf install fuse-sshfs

# Arch Linux
sudo pacman -S sshfs
```

##### Utilisation de base

```bash
# Créer un point de montage
mkdir ~/remote_server

# Monter le répertoire distant
sshfs utilisateur@serveur:/chemin/distant ~/remote_server

# Avec port personnalisé
sshfs -p 2222 utilisateur@serveur:/distant ~/remote_server

# Avec clé SSH spécifique
sshfs -o IdentityFile=~/.ssh/ma_cle utilisateur@serveur:/distant ~/remote_server

# Utiliser le répertoire comme un disque local
cd ~/remote_server
ls
cp fichier.txt .
```

##### Démonter

```bash
# Démonter proprement
fusermount -u ~/remote_server

# Ou sur certains systèmes
umount ~/remote_server
```

##### Options avancées

```bash
# Montage avec compression (meilleur pour connexions lentes)
sshfs -o compression=yes utilisateur@serveur:/distant ~/remote_server

# Montage avec cache pour améliorer les performances
sshfs -o cache=yes,kernel_cache utilisateur@serveur:/distant ~/remote_server

# Montage avec reconnexion automatique
sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 \
      utilisateur@serveur:/distant ~/remote_server

# Montage en lecture seule
sshfs -o ro utilisateur@serveur:/distant ~/remote_server

# Permettre à d'autres utilisateurs d'accéder au montage
sshfs -o allow_other utilisateur@serveur:/distant ~/remote_server
```

> [!warning] Permissions sur sshfs Pour utiliser l'option `allow_other`, vous devez modifier `/etc/fuse.conf` et décommenter la ligne `user_allow_other`.

##### Montage automatique au démarrage (fstab)

```bash
# Éditer /etc/fstab
sudo nano /etc/fstab

# Ajouter la ligne (tout sur une ligne)
utilisateur@serveur:/distant /home/user/remote_server fuse.sshfs noauto,x-systemd.automount,_netdev,users,idmap=user,IdentityFile=/home/user/.ssh/id_rsa,allow_other,reconnect 0 0

# Recharger systemd
sudo systemctl daemon-reload

# Tester
ls ~/remote_server  # Le montage se fait automatiquement
```

##### Avantages et inconvénients de sshfs

**Avantages** ✅

- Accès transparent comme un disque local
- Fonctionne avec toutes les applications
- Pas besoin d'apprendre de nouvelles commandes
- Idéal pour l'édition de fichiers distants

**Inconvénients** ⚠️

- Performances inférieures au NFS pour gros volumes
- Latence réseau affecte les opérations
- Cache peut causer des problèmes de cohérence
- Ne convient pas aux bases de données

> [!tip] Cas d'usage idéaux pour sshfs
> 
> - Éditer des fichiers de configuration distants
> - Accéder à des logs pour analyse
> - Développement sur serveur distant
> - Accès occasionnel à des fichiers distants

### Configurations avancées pour clients graphiques

#### FileZilla : Configuration optimale

**Limiter la vitesse de transfert**

```
Édition > Paramètres > Transferts
└─ Limites de vitesse :
   ├─ Téléchargement : 1000 Ko/s
   └─ Envoi : 500 Ko/s
```

**Augmenter le nombre de transferts simultanés**

```
Édition > Paramètres > Transferts
└─ Nombre maximal de transferts simultanés : 5
```

**Configurer un proxy SOCKS**

```
Édition > Paramètres > Connexion > Proxy FTP
└─ Type : SOCKS5
    ├─ Hôte : localhost
    └─ Port : 1080
```

**Filtres de fichiers**

```
Affichage > Filtres de répertoires
└─ Créer des règles pour masquer :
   ├─ *.tmp
   ├─ .git/
   └─ node_modules/
```

#### Sécurité dans les clients graphiques

> [!warning] Bonnes pratiques de sécurité
> 
> 1. **Ne jamais sauvegarder les mots de passe** dans les clients graphiques
> 2. **Toujours utiliser des clés SSH** plutôt que des mots de passe
> 3. **Vérifier les empreintes** lors de la première connexion
> 4. **Utiliser des connexions chiffrées** (SFTP, pas FTP)
> 5. **Fermer les sessions** après utilisation
> 6. **Mettre à jour régulièrement** les clients

#### Configuration de clés SSH dans FileZilla

```bash
# 1. Générer une clé SSH (si nécessaire)
ssh-keygen -t ed25519 -C "filezilla@monpc"

# 2. Copier la clé publique sur le serveur
ssh-copy-id -i ~/.ssh/id_ed25519 utilisateur@serveur

# 3. Dans FileZilla :
# Gestionnaire de sites > Nouveau site
# Type d'authentification : Fichier de clés
# Fichier de clés : ~/.ssh/id_ed25519
```

Si FileZilla nécessite le format PuTTY (.ppk) :

```bash
# Convertir la clé
puttygen ~/.ssh/id_ed25519 -o ~/.ssh/id_ed25519.ppk -O private
```

---

## 🎯 Cas d'usage pratiques

### Scénario 1 : Sauvegarde quotidienne automatique

**Objectif** : Sauvegarder automatiquement une base de données chaque nuit.

```bash
#!/bin/bash
# /home/user/scripts/backup_db.sh

# Variables
DB_NAME="production"
DB_USER="dbadmin"
BACKUP_DIR="/tmp"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${DB_NAME}_${DATE}.sql.gz"

# Serveur SFTP
SFTP_HOST="backup.example.com"
SFTP_USER="backup"
SFTP_DIR="/backups/database"
SFTP_KEY="/home/user/.ssh/backup_key"

# 1. Créer le dump de la base de données
echo "📦 Création du backup..."
mysqldump -u ${DB_USER} -p${DB_PASS} ${DB_NAME} | gzip > ${BACKUP_FILE}

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors du dump de la base de données"
    exit 1
fi

# 2. Transférer via SFTP
echo "📤 Transfert vers le serveur de backup..."
sftp -i ${SFTP_KEY} ${SFTP_USER}@${SFTP_HOST} <<EOF
cd ${SFTP_DIR}
put ${BACKUP_FILE}
ls -lh backup_${DB_NAME}_*
bye
EOF

if [ $? -eq 0 ]; then
    echo "✅ Backup transféré avec succès"
    # Nettoyer le fichier local
    rm ${BACKUP_FILE}
    
    # Garder seulement les 7 derniers backups sur le serveur
    sftp -i ${SFTP_KEY} ${SFTP_USER}@${SFTP_HOST} <<EOF
cd ${SFTP_DIR}
ls -t backup_${DB_NAME}_* | tail -n +8 | xargs -I {} rm {}
bye
EOF
else
    echo "❌ Erreur lors du transfert SFTP"
    exit 1
fi
```

**Planification cron** :

```bash
# Tous les jours à 2h du matin
0 2 * * * /home/user/scripts/backup_db.sh >> /var/log/backup_db.log 2>&1
```

### Scénario 2 : Déploiement d'application web

**Objectif** : Déployer automatiquement une application après un build.

```bash
#!/bin/bash
# /home/user/scripts/deploy_app.sh

# Configuration
APP_DIR="/home/user/projects/myapp"
BUILD_DIR="${APP_DIR}/dist"
SERVER="web.example.com"
USER="deploy"
REMOTE_DIR="/var/www/html"
BACKUP_DIR="/var/www/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🚀 Démarrage du déploiement..."

# 1. Build de l'application
echo "🔨 Build de l'application..."
cd ${APP_DIR}
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Échec du build"
    exit 1
fi

# 2. Créer une archive
echo "📦 Création de l'archive..."
cd ${BUILD_DIR}
tar -czf /tmp/app_${TIMESTAMP}.tar.gz .

# 3. Créer le script SFTP
cat > /tmp/deploy_sftp.txt <<EOF
# Créer un backup de l'ancienne version
cd ${REMOTE_DIR}
!tar -czf ${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz .

# Nettoyer le répertoire actuel
rm -rf *

# Uploader la nouvelle version
put /tmp/app_${TIMESTAMP}.tar.gz

# Extraire
!cd ${REMOTE_DIR} && tar -xzf app_${TIMESTAMP}.tar.gz && rm app_${TIMESTAMP}.tar.gz

# Vérifier
ls -la

bye
EOF

# 4. Déployer via SFTP
echo "📤 Déploiement sur le serveur..."
sftp -b /tmp/deploy_sftp.txt ${USER}@${SERVER}

if [ $? -eq 0 ]; then
    echo "✅ Déploiement réussi !"
    
    # Nettoyer
    rm /tmp/app_${TIMESTAMP}.tar.gz
    rm /tmp/deploy_sftp.txt
    
    # Redémarrer le serveur web (via SSH)
    ssh ${USER}@${SERVER} "sudo systemctl restart nginx"
    
    echo "🎉 Application déployée et serveur redémarré"
else
    echo "❌ Échec du déploiement"
    exit 1
fi
```

### Scénario 3 : Synchronisation de fichiers de configuration

**Objectif** : Garder les configurations synchronisées entre plusieurs serveurs.

```bash
#!/bin/bash
# sync_configs.sh - Synchronisation de configurations

SERVERS=(
    "web1.example.com"
    "web2.example.com"
    "web3.example.com"
)

CONFIG_FILES=(
    "/etc/nginx/nginx.conf"
    "/etc/nginx/sites-available/default"
    "/etc/php/8.1/fpm/php.ini"
)

MASTER_USER="admin"
TEMP_DIR="/tmp/configs_sync"

# Créer le répertoire temporaire
mkdir -p ${TEMP_DIR}

echo "🔄 Synchronisation des configurations..."

# Pour chaque serveur
for SERVER in "${SERVERS[@]}"; do
    echo "📡 Serveur : ${SERVER}"
    
    # Pour chaque fichier de configuration
    for CONFIG in "${CONFIG_FILES[@]}"; do
        BASENAME=$(basename ${CONFIG})
        
        echo "  📥 Téléchargement de ${CONFIG}..."
        
        # Télécharger le fichier
        sftp ${MASTER_USER}@${SERVER} <<EOF
get ${CONFIG} ${TEMP_DIR}/${SERVER}_${BASENAME}
bye
EOF
        
        if [ $? -eq 0 ]; then
            echo "  ✅ ${BASENAME} téléchargé"
        else
            echo "  ❌ Échec du téléchargement de ${BASENAME}"
        fi
    done
    echo ""
done

echo "📊 Comparaison des fichiers..."
# Comparer les fichiers entre serveurs
for CONFIG in "${CONFIG_FILES[@]}"; do
    BASENAME=$(basename ${CONFIG})
    echo "Fichier : ${BASENAME}"
    
    FILES=(${TEMP_DIR}/*_${BASENAME})
    if [ ${#FILES[@]} -gt 1 ]; then
        diff -s "${FILES[0]}" "${FILES[1]}"
    fi
    echo ""
done

# Nettoyer
rm -rf ${TEMP_DIR}
```

### Scénario 4 : Monitoring de l'espace disque distant

**Objectif** : Vérifier l'espace disque et télécharger les logs si nécessaire.

```bash
#!/bin/bash
# monitor_disk.sh - Surveillance de l'espace disque via SFTP

SERVER="monitoring.example.com"
USER="monitor"
THRESHOLD=85  # Seuil d'alerte en %

echo "💾 Vérification de l'espace disque sur ${SERVER}..."

# Obtenir l'utilisation du disque
DISK_USAGE=$(sftp ${USER}@${SERVER} <<EOF | grep "Capacity" | awk '{print $6}' | tr -d '%'
df -h
bye
EOF
)

echo "Utilisation actuelle : ${DISK_USAGE}%"

if [ ${DISK_USAGE} -gt ${THRESHOLD} ]; then
    echo "⚠️  ALERTE : L'espace disque dépasse ${THRESHOLD}% !"
    
    # Télécharger les logs pour analyse
    echo "📥 Téléchargement des logs..."
    
    LOGS_DIR="/tmp/logs_$(date +%Y%m%d)"
    mkdir -p ${LOGS_DIR}
    
    sftp ${USER}@${SERVER} <<EOF
cd /var/log
lcd ${LOGS_DIR}
get -r *
bye
EOF
    
    # Envoyer une alerte email
    echo "Espace disque: ${DISK_USAGE}% sur ${SERVER}" | \
    mail -s "⚠️ Alerte espace disque" admin@example.com
    
    echo "✅ Logs téléchargés dans ${LOGS_DIR}"
else
    echo "✅ Espace disque OK (${DISK_USAGE}%)"
fi
```

---

## 🔧 Résolution de problèmes courants

### Problème 1 : "Permission denied (publickey)"

**Symptôme** : Impossible de se connecter avec la clé SSH

**Solutions** :

```bash
# 1. Vérifier les permissions de la clé
chmod 600 ~/.ssh/id_rsa
chmod 700 ~/.ssh

# 2. Vérifier que la clé publique est sur le serveur
ssh-copy-id utilisateur@serveur

# 3. Tester la connexion en mode verbose
sftp -v utilisateur@serveur

# 4. Vérifier la configuration SSH du serveur
# Sur le serveur :
sudo grep "PubkeyAuthentication" /etc/ssh/sshd_config
# Doit être : PubkeyAuthentication yes
```

### Problème 2 : "Connection refused" ou timeout

**Symptôme** : Impossible de se connecter au serveur

**Diagnostic** :

```bash
# 1. Vérifier que le serveur est accessible
ping serveur.com

# 2. Vérifier que le port SSH est ouvert
nc -zv serveur.com 22
# ou
telnet serveur.com 22

# 3. Vérifier le pare-feu local
sudo ufw status
sudo iptables -L | grep 22

# 4. Vérifier le service SSH sur le serveur
# Sur le serveur :
sudo systemctl status sshd
```

### Problème 3 : Transferts très lents

**Symptôme** : Les transferts SFTP sont anormalement lents

**Solutions** :

```bash
# 1. Activer la compression
sftp -C utilisateur@serveur

# 2. Utiliser un cipher plus rapide
sftp -o Ciphers=aes128-gcm@openssh.com utilisateur@serveur

# 3. Tester la bande passante
# Installer iperf3 sur les deux machines
iperf3 -s  # Sur le serveur
iperf3 -c serveur.com  # Sur le client

# 4. Désactiver les vérifications strictes (test uniquement)
sftp -o StrictHostKeyChecking=no utilisateur@serveur

# 5. Utiliser lftp avec téléchargement parallèle
lftp sftp://utilisateur@serveur
lftp> pget -n 4 gros_fichier.iso
```

### Problème 4 : "Packet too big" ou erreurs de MTU

**Symptôme** : Connexion établie mais transferts échouent

**Solutions** :

```bash
# 1. Réduire la taille MTU dans SSH
sftp -o "IPQoS=throughput" utilisateur@serveur

# 2. Configurer le MTU réseau
sudo ip link set dev eth0 mtu 1400

# 3. Ajouter dans ~/.ssh/config
Host serveur.com
    IPQoS throughput
    TCPKeepAlive yes
```

### Problème 5 : "Too many authentication failures"

**Symptôme** : Rejet après plusieurs tentatives

**Solutions** :

```bash
# 1. Spécifier uniquement la bonne clé
sftp -i ~/.ssh/cle_correcte utilisateur@serveur

# 2. Désactiver l'agent SSH temporairement
sftp -o IdentitiesOnly=yes -i ~/.ssh/cle utilisateur@serveur

# 3. Configurer dans ~/.ssh/config
Host serveur.com
    IdentitiesOnly yes
    IdentityFile ~/.ssh/cle_specifique
```

### Problème 6 : Échec de reprise de transfert

**Symptôme** : Impossible de reprendre un transfert interrompu

**Solutions** :

```bash
# 1. Utiliser lftp qui supporte la reprise automatique
lftp sftp://utilisateur@serveur
lftp> get -c gros_fichier.iso  # -c pour continuer

# 2. Utiliser rsync over SSH au lieu de SFTP
rsync -avz -e ssh --partial utilisateur@serveur:/fichier /local/

# 3. Pour SFTP natif, supprimer et recommencer
sftp> rm fichier_partiel.zip
sftp> get fichier.zip
```

---

## 🎓 Astuces et bonnes pratiques

### Optimisation des performances

> [!tip] Améliorer la vitesse des transferts
> 
> 1. **Compression** : Utilisez `-C` pour fichiers texte
> 2. **Cipher rapide** : `aes128-gcm@openssh.com` est plus rapide
> 3. **Batch operations** : Regroupez les petits fichiers dans une archive
> 4. **lftp** : Utilisez le téléchargement parallèle avec `pget -n 4`
> 5. **sshfs** : Activez le cache avec `-o cache=yes`

### Configuration SSH pour SFTP optimisé

Ajoutez dans `~/.ssh/config` :

```bash
# Configuration optimisée pour SFTP
Host backup-server
    HostName backup.example.com
    User backup
    Port 22
    IdentityFile ~/.ssh/backup_key
    Compression yes
    Ciphers aes128-gcm@openssh.com,aes256-gcm@openssh.com
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
```

Utilisation :

```bash
# Au lieu de :
sftp -P 22 -i ~/.ssh/backup_key backup@backup.example.com

# Utilisez simplement :
sftp backup-server
```

### Sécurité renforcée

> [!warning] Liste de contrôle sécurité
> 
> - ✅ Toujours utiliser des clés SSH (pas de mots de passe)
> - ✅ Protéger les clés privées : `chmod 600 ~/.ssh/id_rsa`
> - ✅ Utiliser des passphrases pour les clés
> - ✅ Désactiver root login via SSH sur le serveur
> - ✅ Changer le port SSH par défaut (22 → autre)
> - ✅ Utiliser fail2ban pour bloquer les tentatives de brute force
> - ✅ Limiter l'accès SFTP avec chroot (jail)
> - ✅ Auditer régulièrement les connexions : `/var/log/auth.log`

### Gestion des erreurs dans les scripts

```bash
#!/bin/bash
# Script SFTP robuste avec gestion d'erreurs

set -euo pipefail  # Arrêt si erreur

# Fonction de logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/sftp_script.log
}

# Fonction de cleanup
cleanup() {
    log "Nettoyage..."
    rm -f /tmp/sftp_batch_*.txt
}

trap cleanup EXIT ERR INT TERM

# Vérifications préalables
if [ ! -f ~/.ssh/backup_key ]; then
    log "❌ ERREUR : Clé SSH introuvable"
    exit 1
fi

if ! ping -c 1 backup.example.com &>/dev/null; then
    log "❌ ERREUR : Serveur inaccessible"
    exit 1
fi

# Exécution SFTP
log "📤 Démarrage du transfert..."
if sftp -i ~/.ssh/backup_key user@server <<EOF
put file.txt
bye
EOF
then
    log "✅ Transfert réussi"
else
    log "❌ Échec du transfert"
    exit 1
fi
```

---

## 📚 Récapitulatif

### Points clés à retenir

1. **SFTP est différent de FTP** : Protocole sécurisé sur SSH, pas une extension de FTP
2. **Deux répertoires courants** : Local (l-commands) et distant (commands normales)
3. **get/put** : Commandes essentielles pour télécharger et uploader
4. **Mode batch** : Automatisation via fichiers de commandes
5. **Clients graphiques** : FileZilla, Cyberduck, ou intégration dans gestionnaires de fichiers
6. **sshfs** : Montage de répertoires distants comme disques locaux
7. **lftp** : Alternative puissante avec mirror et téléchargement parallèle

### Commandes SFTP à mémoriser

```bash
# Connexion
sftp user@host
sftp -P 2222 user@host

# Navigation
pwd / lpwd    # Où suis-je ?
ls / lls      # Qu'y a-t-il ?
cd / lcd      # Aller vers

# Transferts
get fichier       # Télécharger
get -r dossier/   # Télécharger récursivement
put fichier       # Uploader
put -r dossier/   # Uploader récursivement

# Gestion
mkdir / rmdir     # Créer/supprimer dossier
rm fichier        # Supprimer fichier
rename a b        # Renommer
chmod 644 file    # Permissions

# Batch
sftp -b commandes.txt user@host

# Quitter
quit / exit / bye
```

### Choix du bon outil

|Besoin|Outil recommandé|
|---|---|
|Transfert ponctuel simple|`sftp` en ligne de commande|
|Automatisation/scripts|`sftp` en mode batch ou `lftp`|
|Interface graphique|FileZilla ou Cyberduck|
|Édition de fichiers distants|`sshfs` + éditeur local|
|Synchronisation avancée|`lftp mirror` ou `rsync`|
|Administration serveur|Midnight Commander (`mc`)|

---

**🎉 Félicitations !** Vous maîtrisez maintenant le transfert de fichiers sécurisé avec SFTP sur Linux.