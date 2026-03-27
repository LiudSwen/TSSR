

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

## Syntaxe client vers daemon

### 📌 Structure de base

La syntaxe pour se connecter à un daemon rsync diffère de celle utilisée pour SSH. Elle utilise le **double deux-points** `::` pour indiquer qu'on communique avec un daemon.

```bash
# Syntaxe générale
rsync [OPTIONS] SOURCE DESTINATION

# Format pour le daemon (avec ::)
rsync [OPTIONS] utilisateur@hôte::module/chemin destination_locale
rsync [OPTIONS] source_locale utilisateur@hôte::module/chemin
```

> [!info] Distinction importante
> - **SSH** : utilise un seul `:` → `user@host:/chemin`
> - **Daemon** : utilise deux `::` → `user@host::module/chemin`
> - Le daemon écoute par défaut sur le **port 873** (vs port 22 pour SSH)

### 🎯 Exemples de base

**Téléchargement depuis un daemon (pull)** :
```bash
# Récupérer des fichiers depuis le module 'backup' du serveur
rsync -avz admin@192.168.1.100::backup/documents/ /home/user/docs/

# Sans authentification (si le module est en accès anonyme)
rsync -avz 192.168.1.100::public/files/ /tmp/downloads/
```

**Envoi vers un daemon (push)** :
```bash
# Envoyer des fichiers vers le module 'backup'
rsync -avz /home/user/photos/ admin@192.168.1.100::backup/photos/

# Avec progression détaillée
rsync -avz --progress /var/www/ webmaster@server.local::web-backup/
```

> [!warning] Module obligatoire
> Contrairement à SSH où vous pouvez accéder à n'importe quel chemin (selon vos permissions), avec un daemon vous **devez** spécifier un module existant. Vous ne pouvez pas accéder directement à un chemin système arbitraire.

### 🔧 Syntaxe alternative avec rsync://

Il existe une syntaxe URL alternative, plus moderne :

```bash
# Format URL (équivalent à ::)
rsync -avz rsync://utilisateur@hôte/module/chemin /destination/locale/
rsync -avz /source/locale/ rsync://utilisateur@hôte/module/chemin

# Exemples concrets
rsync -avz rsync://backup@srv.example.com/documents/ /backup/docs/
rsync -avz /data/site/ rsync://deploy@web.company.lan/website/
```

> [!tip] Quelle syntaxe choisir ?
> - **`host::module`** : syntaxe traditionnelle, plus courte
> - **`rsync://host/module`** : syntaxe URL, plus explicite et standardisée
> 
> Les deux sont strictement équivalentes. Choisissez celle qui vous paraît la plus claire.

### 📊 Comparaison des syntaxes

| Type de connexion | Syntaxe | Port par défaut | Exemple |
|-------------------|---------|-----------------|---------|
| **Local** | `/chemin` | N/A | `rsync -av /src/ /dst/` |
| **SSH** | `user@host:/chemin` | 22 | `rsync -av user@srv:/data/ /backup/` |
| **Daemon (::)** | `user@host::module/chemin` | 873 | `rsync -av user@srv::backup/ /data/` |
| **Daemon (URL)** | `rsync://user@host/module/chemin` | 873 | `rsync -av rsync://user@srv/backup/ /data/` |

---

## Liste des modules disponibles

### 🔍 Lister les modules accessibles

Avant de synchroniser, il est utile de connaître les modules disponibles sur un serveur daemon.

```bash
# Lister tous les modules d'un serveur
rsync nom_hote::

# Exemples
rsync 192.168.1.100::
rsync backup.company.lan::
rsync rsync://srv.example.com/
```

**Sortie typique** :
```
backup          Espace de sauvegarde sécurisé
public          Fichiers publics en lecture seule
web-data        Données du site web
archives        Archives système
```

> [!example] Exemple pratique
> ```bash
> # Découvrir les modules disponibles sur le serveur
> $ rsync backup-srv.local::
> backup          Sauvegarde quotidienne des données
> logs            Logs système (read-only)
> shared          Partage d'équipe
> 
> # Lister le contenu d'un module spécifique
> $ rsync backup-srv.local::backup/
> drwxr-xr-x          4,096 2025/01/20 10:30:00 database/
> drwxr-xr-x          4,096 2025/01/22 15:45:00 configs/
> drwxr-xr-x          4,096 2025/01/24 08:20:00 documents/
> ```

### 📂 Explorer le contenu d'un module

```bash
# Lister le contenu d'un module (comme un 'ls')
rsync nom_hote::nom_module/

# Lister récursivement
rsync -r nom_hote::nom_module/

# Avec détails (tailles, dates, permissions)
rsync -rlt nom_hote::nom_module/

# Exemples
rsync 192.168.1.100::backup/
rsync -r backup.local::archives/2024/
rsync -rlt rsync://srv.company.com/public/documents/
```

> [!tip] Exploration sans transfert
> Ajouter l'option `--list-only` ou `-n` (dry-run) permet de lister sans rien télécharger :
> ```bash
> rsync -avz --list-only backup-srv::backup/
> rsync -avn backup-srv::backup/database/
> ```

### 🚫 Modules cachés ou restreints

Certains modules peuvent être configurés pour ne pas apparaître dans la liste globale :

```bash
# Dans rsyncd.conf, un module peut être masqué
[hidden-module]
    path = /secret/data
    list = false          # Ne pas afficher dans la liste
    auth users = admin
```

Ces modules **existent** mais ne s'affichent pas avec `rsync host::`. Vous devez connaître leur nom pour y accéder :

```bash
# Le module n'apparaît pas dans la liste
$ rsync srv::
public          Fichiers publics

# Mais on peut y accéder directement si on connaît le nom
$ rsync srv::hidden-module/
# (demande authentification)
```

---

## Connexion authentifiée

### 🔐 Authentification par mot de passe

Lorsqu'un module requiert une authentification, rsync demande le mot de passe de manière interactive.

```bash
# Connexion avec authentification
rsync -avz admin@backup-srv::secure-backup/ /local/backup/

# Rsync demande le mot de passe :
Password:
```

> [!warning] Sécurité de base
> Le mot de passe est demandé de manière interactive, ce qui est sécurisé pour une utilisation manuelle. **Ne jamais** passer le mot de passe directement dans la ligne de commande (il serait visible dans l'historique et par d'autres utilisateurs).

### 🤖 Automatisation avec RSYNC_PASSWORD

Pour les scripts automatisés (sauvegardes cron par exemple), vous pouvez utiliser la variable d'environnement `RSYNC_PASSWORD`.

```bash
# Définir le mot de passe dans une variable d'environnement
export RSYNC_PASSWORD='MonMotDePasse123'

# Puis lancer rsync (pas de prompt)
rsync -avz admin@backup-srv::backup/ /local/backup/

# En une seule ligne
RSYNC_PASSWORD='MonMotDePasse123' rsync -avz admin@backup-srv::backup/ /local/backup/
```

> [!warning] Sécurité avec RSYNC_PASSWORD
> - Le mot de passe sera visible dans la liste des processus (`ps aux`)
> - **Préférez** stocker le mot de passe dans un fichier séparé avec permissions restrictives

### 📄 Fichier de mot de passe sécurisé

**Méthode recommandée pour l'automatisation** :

```bash
# 1. Créer un fichier pour le mot de passe
echo "MonMotDePasse123" > ~/.rsync-password

# 2. Restreindre les permissions (OBLIGATOIRE)
chmod 600 ~/.rsync-password

# 3. Utiliser l'option --password-file
rsync -avz --password-file=~/.rsync-password admin@backup-srv::backup/ /local/backup/
```

> [!info] Format du fichier de mot de passe
> Le fichier doit contenir **uniquement le mot de passe**, sur une seule ligne, sans le nom d'utilisateur. Rsync utilise le nom d'utilisateur spécifié dans la commande.

**Structure pour un script de sauvegarde** :

```bash
#!/bin/bash

# Script de sauvegarde automatisé

RSYNC_USER="backup-admin"
RSYNC_HOST="backup-srv.company.lan"
RSYNC_MODULE="daily-backup"
RSYNC_PASS_FILE="/root/.rsync-backup-password"
LOCAL_DEST="/var/backups/rsync/"

# Vérification du fichier de mot de passe
if [ ! -f "$RSYNC_PASS_FILE" ]; then
    echo "ERREUR: Fichier de mot de passe introuvable"
    exit 1
fi

# Vérification des permissions
PERMS=$(stat -c %a "$RSYNC_PASS_FILE")
if [ "$PERMS" != "600" ]; then
    echo "ERREUR: Permissions incorrectes sur le fichier de mot de passe"
    echo "Exécutez: chmod 600 $RSYNC_PASS_FILE"
    exit 1
fi

# Synchronisation
rsync -avz \
    --password-file="$RSYNC_PASS_FILE" \
    --delete \
    --log-file=/var/log/rsync-backup.log \
    "${RSYNC_USER}@${RSYNC_HOST}::${RSYNC_MODULE}/" \
    "$LOCAL_DEST"

if [ $? -eq 0 ]; then
    echo "Sauvegarde réussie - $(date)"
else
    echo "ERREUR lors de la sauvegarde - $(date)"
    exit 1
fi
```

### 🔑 Authentification par utilisateur virtuel

Le daemon rsync utilise des **utilisateurs virtuels** définis dans `rsyncd.conf`, qui ne sont **pas** les utilisateurs système Linux.

```bash
# Dans rsyncd.conf du serveur
[backup]
    path = /data/backups
    auth users = alice, bob, charlie
    secrets file = /etc/rsyncd.secrets

# Fichier /etc/rsyncd.secrets (sur le serveur)
alice:MotDePasseAlice123
bob:MotDePasseBob456
charlie:MotDePasseCharlie789
```

**Côté client** :

```bash
# Alice se connecte
rsync -avz --password-file=~/.alice-password alice@srv::backup/ /local/

# Bob se connecte
rsync -avz --password-file=~/.bob-password bob@srv::backup/ /local/

# Chaque utilisateur a son propre mot de passe
```

> [!tip] Différence utilisateur système vs utilisateur rsync
> - **Utilisateur système** : compte Linux réel (`/etc/passwd`)
> - **Utilisateur rsync** : compte virtuel défini uniquement dans `rsyncd.conf` et `secrets file`
> 
> Ces utilisateurs virtuels n'ont aucun accès shell au système, uniquement au module rsync.

---

## Pièges courants et bonnes pratiques

### ⚠️ Pièges à éviter

**1. Confusion entre SSH et daemon** :
```bash
# ❌ ERREUR : Utiliser : au lieu de ::
rsync -avz user@srv:backup/ /local/
# Rsync tente une connexion SSH, pas daemon !

# ✅ CORRECT : Double deux-points pour daemon
rsync -avz user@srv::backup/ /local/
```

**2. Oubli du module** :
```bash
# ❌ ERREUR : Pas de module spécifié
rsync -avz user@srv::/data/backups/ /local/
# Erreur: module non spécifié

# ✅ CORRECT : Module obligatoire
rsync -avz user@srv::backup/data/ /local/
```

**3. Permissions du fichier de mot de passe** :
```bash
# ❌ ERREUR : Permissions trop larges
$ chmod 644 ~/.rsync-password
$ rsync --password-file=~/.rsync-password ...
ERROR: password file must not be other-accessible

# ✅ CORRECT : Permissions strictes
chmod 600 ~/.rsync-password
```

**4. Port firewall non ouvert** :
```bash
# Le daemon écoute sur le port 873
# Vérifier que le firewall autorise ce port

# Sur le serveur (exemple avec firewalld)
sudo firewall-cmd --add-port=873/tcp --permanent
sudo firewall-cmd --reload

# Sur le serveur (exemple avec ufw)
sudo ufw allow 873/tcp
```

### ✅ Bonnes pratiques

**1. Tester la connectivité d'abord** :
```bash
# 1. Vérifier que le serveur répond
rsync srv.company.lan::

# 2. Lister le contenu du module
rsync srv.company.lan::backup/

# 3. Faire un dry-run avant le vrai transfert
rsync -avzn --password-file=~/.rsync-pass user@srv::backup/ /local/

# 4. Lancer la vraie synchronisation
rsync -avz --password-file=~/.rsync-pass user@srv::backup/ /local/
```

**2. Sécuriser les fichiers de mots de passe** :
```bash
# Stocker dans un répertoire protégé
sudo mkdir -p /root/.rsync-credentials
sudo chmod 700 /root/.rsync-credentials

# Créer le fichier de mot de passe
sudo bash -c 'echo "MonMotDePasse" > /root/.rsync-credentials/backup.pass'
sudo chmod 600 /root/.rsync-credentials/backup.pass

# Utiliser dans les scripts
rsync --password-file=/root/.rsync-credentials/backup.pass ...
```

**3. Logger les transferts** :
```bash
# Garder une trace des synchronisations
rsync -avz \
    --password-file=~/.rsync-pass \
    --log-file=/var/log/rsync-backup-$(date +%Y%m%d).log \
    user@srv::backup/ /local/backup/

# Ou rediriger vers syslog
rsync -avz \
    --password-file=~/.rsync-pass \
    user@srv::backup/ /local/backup/ 2>&1 | logger -t rsync-backup
```

**4. Utiliser des modules en lecture seule pour les pulls** :
```bash
# Sur le serveur, définir un module read-only pour les téléchargements
[download-only]
    path = /data/public
    read only = yes         # Empêche l'envoi de fichiers
    auth users = downloader

# Le client peut télécharger mais pas uploader
rsync -avz downloader@srv::download-only/ /local/  # ✅ OK
rsync -avz /local/file.txt downloader@srv::download-only/  # ❌ Refusé
```

---

## Astuces avancées

### 💡 Combiner daemon et SSH (tunnel SSH)

Pour sécuriser un daemon rsync avec SSH :

```bash
# Sur le client, créer un tunnel SSH vers le port 873
ssh -L 8873:localhost:873 user@srv.company.lan

# Dans un autre terminal, utiliser le tunnel
rsync -avz rsync://backup-user@localhost:8873/backup/ /local/backup/
```

> [!info] Pourquoi tunneliser ?
> Le protocole daemon rsync transmet les mots de passe en clair sur le réseau. Un tunnel SSH chiffre toute la communication, combinant la flexibilité du daemon et la sécurité de SSH.

### 🎯 Utiliser des modules différents selon les besoins

```bash
# Module pour backup quotidien (plus permissif)
rsync -avz user@srv::daily-backup/ /backups/daily/

# Module pour backup mensuel (lecture seule, archives)
rsync -avz user@srv::monthly-archive/ /backups/monthly/

# Module pour déploiement web (write-only)
rsync -avz /var/www/html/ deploy@srv::web-deploy/
```

### 📊 Vérifier la version du protocole

```bash
# Afficher les informations de version et protocole
rsync --version

# Certaines fonctionnalités nécessitent des versions spécifiques
# du protocole rsync sur le client ET le serveur
```

### 🔄 Spécifier un port daemon personnalisé

Si le daemon n'écoute pas sur le port 873 par défaut :

```bash
# Avec la syntaxe ::
rsync -avz --port=8873 user@srv::backup/ /local/

# Avec la syntaxe URL
rsync -avz rsync://user@srv:8873/backup/ /local/
```

### 🛡️ Connexion anonyme (sans authentification)

Si un module autorise l'accès anonyme :

```bash
# Pas besoin de spécifier d'utilisateur
rsync -avz srv.company.lan::public-files/ /tmp/downloads/

# Équivalent avec syntaxe URL
rsync -avz rsync://srv.company.lan/public-files/ /tmp/downloads/
```

> [!warning] Attention à la sécurité
> L'accès anonyme doit être réservé aux fichiers vraiment publics. Toujours utiliser `read only = yes` pour ces modules.

### 📝 Vérifier les statistiques de transfert

```bash
# Afficher les statistiques détaillées après le transfert
rsync -avz --stats --password-file=~/.rsync-pass user@srv::backup/ /local/

# Sortie exemple :
# Number of files: 1,523
# Number of files transferred: 145
# Total file size: 2.34G bytes
# Total transferred file size: 523.45M bytes
# Literal data: 523.45M bytes
# Matched data: 0 bytes
# File list size: 35.23K
# Total bytes sent: 1.23K
# Total bytes received: 523.47M
```