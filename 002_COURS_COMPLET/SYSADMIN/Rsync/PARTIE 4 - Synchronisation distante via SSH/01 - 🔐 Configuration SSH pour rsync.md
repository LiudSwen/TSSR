

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

SSH (Secure Shell) est le protocole recommandé pour utiliser rsync à distance. Il offre un canal chiffré et sécurisé pour le transfert de données. Par défaut, rsync utilise SSH comme transport distant, ce qui combine la puissance de synchronisation de rsync avec la sécurité de SSH.

> [!info] Pourquoi SSH avec rsync ?
> - **Sécurité** : Toutes les données sont chiffrées
> - **Authentification** : Utilise les mécanismes SSH existants
> - **Simplicité** : Pas besoin de configurer un daemon rsync
> - **Compatibilité** : Fonctionne à travers les pare-feux (port 22)

---

## Syntaxe avec SSH

### Structure de base

```bash
# Syntaxe générale
rsync [options] source user@host:destination
rsync [options] user@host:source destination
```

> [!example] Exemples de syntaxe
> ```bash
> # Envoi vers serveur distant
> rsync -av /local/data/ user@192.168.1.100:/remote/backup/
> 
> # Récupération depuis serveur distant
> rsync -av user@server.example.com:/var/www/ /local/mirror/
> 
> # Avec nom de domaine
> rsync -av documents/ admin@backup.entreprise.fr:/backups/docs/
> ```

### Décomposition de la syntaxe

| Élément | Description | Exemple |
|---------|-------------|---------|
| `user@` | Nom d'utilisateur distant | `john@`, `backup@`, `root@` |
| `host` | Adresse IP ou nom d'hôte | `192.168.1.50`, `server.local` |
| `:` | Séparateur obligatoire | Toujours présent |
| `chemin` | Chemin absolu ou relatif | `/var/data/`, `~/documents/` |

> [!warning] Le deux-points (:) est crucial
> Sans le `:`, rsync considère la destination comme locale et créera un dossier avec le nom complet (ex: `user@host/path`)

### Chemins relatifs vs absolus

```bash
# Chemin absolu (commence par /)
rsync -av files/ user@server:/home/user/backup/

# Chemin relatif au home de l'utilisateur distant
rsync -av files/ user@server:backup/
# Équivaut à : /home/user/backup/

# Chemin relatif au répertoire courant de l'utilisateur
rsync -av files/ user@server:./backup/
```

---

## Authentification par mot de passe

### Fonctionnement

Par défaut, si aucune clé SSH n'est configurée, rsync demandera le mot de passe de l'utilisateur distant.

```bash
# Exemple : vous serez invité à entrer le mot de passe
rsync -av /local/docs/ admin@192.168.1.50:/backup/docs/
```

**Sortie attendue :**
```
admin@192.168.1.50's password: _
```

> [!warning] Limitations de l'authentification par mot de passe
> - **Non automatisable** : Impossible à utiliser dans des scripts non-interactifs
> - **Moins sécurisé** : Le mot de passe peut être intercepté si SSH n'est pas bien configuré
> - **Peu pratique** : Nécessite une saisie à chaque exécution
> - **Problématique pour cron** : Les tâches planifiées ne peuvent pas saisir de mot de passe

### Quand utiliser cette méthode ?

✅ **Recommandé pour :**
- Tests ponctuels
- Transferts occasionnels manuels
- Situations où les clés SSH ne sont pas autorisées

❌ **À éviter pour :**
- Automatisation et scripts
- Tâches cron
- Transferts fréquents
- Environnements de production

---

## Authentification par clé

L'authentification par clé SSH est la méthode recommandée pour rsync en production. Elle permet une connexion sans mot de passe, sécurisée et automatisable.

### Génération de la paire de clés

```bash
# Génération d'une paire de clés RSA
ssh-keygen -t rsa -b 4096 -C "backup-rsync"

# Génération d'une paire de clés ED25519 (recommandé - plus moderne)
ssh-keygen -t ed25519 -C "backup-rsync"
```

**Sortie interactive :**
```
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/user/.ssh/id_ed25519): [Entrée]
Enter passphrase (empty for no passphrase): [Entrée pour aucune phrase de passe]
Enter same passphrase again: [Entrée]
```

> [!tip] Phrase de passe ou pas ?
> - **Avec phrase de passe** : Plus sécurisé, mais nécessite ssh-agent pour l'automatisation
> - **Sans phrase de passe** : Automatisation simple, mais la clé doit être protégée (permissions 600)
> - **Pour scripts automatisés** : Généralement sans phrase de passe, avec clé dédiée

### Copie de la clé publique vers le serveur distant

```bash
# Méthode 1 : Utiliser ssh-copy-id (recommandé)
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server.example.com

# Méthode 2 : Copie manuelle
cat ~/.ssh/id_ed25519.pub | ssh user@server.example.com "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Méthode 3 : Copie très manuelle
scp ~/.ssh/id_ed25519.pub user@server.example.com:~/
ssh user@server.example.com
cat ~/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Vérification de la configuration

```bash
# Test de connexion SSH sans mot de passe
ssh user@server.example.com

# Si cela fonctionne sans demander de mot de passe, rsync fonctionnera aussi
```

### Utilisation avec rsync

```bash
# Une fois la clé configurée, rsync fonctionne sans interaction
rsync -av /local/data/ user@server:/backup/data/

# Spécifier une clé particulière si nécessaire
rsync -av -e "ssh -i /home/user/.ssh/backup_key" /local/data/ user@server:/backup/
```

> [!example] Exemple complet de configuration
> ```bash
> # Sur la machine source
> ssh-keygen -t ed25519 -f ~/.ssh/rsync_backup -C "Clé pour sauvegardes rsync"
> ssh-copy-id -i ~/.ssh/rsync_backup.pub backup@backup-server.lan
> 
> # Test
> ssh -i ~/.ssh/rsync_backup backup@backup-server.lan
> 
> # Utilisation dans rsync
> rsync -av -e "ssh -i ~/.ssh/rsync_backup" \
>   /var/www/ \
>   backup@backup-server.lan:/backups/www/
> ```

### Permissions importantes

```bash
# Sur la machine locale
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Sur le serveur distant
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

> [!warning] Problèmes de permissions
> SSH est très strict sur les permissions. Des permissions trop ouvertes entraîneront le rejet de la clé :
> - `.ssh/` doit être 700 (rwx------)
> - Clé privée doit être 600 (rw-------)
> - `authorized_keys` doit être 600 (rw-------)

---

## Port SSH personnalisé

De nombreux serveurs utilisent un port SSH différent du port 22 par défaut pour des raisons de sécurité.

### Syntaxe avec option -e

```bash
# Spécifier le port avec l'option -e
rsync -av -e "ssh -p 2222" /local/data/ user@server:/backup/

# Avec d'autres options SSH
rsync -av -e "ssh -p 2222 -i ~/.ssh/backup_key" /local/data/ user@server:/backup/
```

### Décomposition de l'option -e

| Élément | Signification |
|---------|---------------|
| `-e` | Spécifie le shell distant à utiliser |
| `"ssh -p 2222"` | Commande SSH avec ses options |
| `-p 2222` | Port SSH personnalisé |
| `-i chemin/clé` | Clé SSH spécifique (optionnel) |

> [!example] Exemples avancés
> ```bash
> # Port personnalisé + clé spécifique
> rsync -av -e "ssh -p 2222 -i ~/.ssh/backup_key" \
>   files/ user@server:/backup/
> 
> # Port personnalisé + compression SSH désactivée (rsync gère déjà la compression)
> rsync -avz -e "ssh -p 2222 -o Compression=no" \
>   data/ user@server:/backup/
> 
> # Port personnalisé + StrictHostKeyChecking désactivé (pour automatisation)
> rsync -av -e "ssh -p 2222 -o StrictHostKeyChecking=no" \
>   files/ user@server:/backup/
> ```

### Configuration SSH pour simplifier

Plutôt que de spécifier le port à chaque fois, vous pouvez configurer SSH :

**Fichier `~/.ssh/config` :**
```
Host backup-server
    HostName 192.168.1.100
    User backup
    Port 2222
    IdentityFile ~/.ssh/backup_key
    Compression no
```

**Utilisation simplifiée :**
```bash
# Grâce au fichier config, ceci suffit :
rsync -av files/ backup-server:/backup/

# Au lieu de :
rsync -av -e "ssh -p 2222 -i ~/.ssh/backup_key" files/ backup@192.168.1.100:/backup/
```

> [!tip] Avantages du fichier ~/.ssh/config
> - Syntaxe rsync simplifiée
> - Configuration centralisée et réutilisable
> - Fonctionne aussi pour ssh, scp, sftp
> - Facilite la maintenance

---

## Pièges courants

### 1. Oublier le deux-points (:)

```bash
# ❌ INCORRECT - Crée un dossier local nommé "user@server"
rsync -av files/ user@server/backup/

# ✅ CORRECT - Synchronise vers le serveur distant
rsync -av files/ user@server:/backup/
```

### 2. Confusion entre chemins absolus et relatifs

```bash
# Chemin relatif au home (~) de l'utilisateur distant
rsync -av files/ user@server:backup/
# Destination réelle : /home/user/backup/

# Chemin absolu explicite
rsync -av files/ user@server:/var/backups/data/
# Destination réelle : /var/backups/data/
```

### 3. Permissions de clés SSH incorrectes

```bash
# ❌ La clé est trop ouverte
-rw-rw-r-- 1 user user 464 Jan 15 10:00 ~/.ssh/id_ed25519
# Erreur : Permissions 0664 for '~/.ssh/id_ed25519' are too open.

# ✅ Correction
chmod 600 ~/.ssh/id_ed25519
```

### 4. Utiliser le mauvais utilisateur distant

```bash
# ❌ ERREUR - L'utilisateur 'root' n'accepte pas les connexions SSH
rsync -av files/ root@server:/backup/
# Permission denied (publickey,password).

# ✅ CORRECT - Utiliser l'utilisateur approprié
rsync -av files/ backup@server:/backup/
```

### 5. Ne pas tester SSH avant rsync

```bash
# Toujours tester SSH d'abord
ssh user@server
# Si SSH ne fonctionne pas, rsync ne fonctionnera pas non plus
```

---

## Astuces professionnelles

### 1. Variables d'environnement pour simplification

```bash
# Définir des variables pour les transferts répétitifs
REMOTE_HOST="user@backup-server.lan"
REMOTE_PATH="/backups/daily"

rsync -av /var/www/ ${REMOTE_HOST}:${REMOTE_PATH}/www/
rsync -av /home/ ${REMOTE_HOST}:${REMOTE_PATH}/home/
```

### 2. Bande passante limitée sur SSH

```bash
# Limiter la bande passante à 5000 KB/s
rsync -av --bwlimit=5000 -e "ssh -p 2222" /data/ user@server:/backup/
```

### 3. Verbose SSH pour débogage

```bash
# Activer le mode verbose de SSH pour diagnostiquer les problèmes
rsync -av -e "ssh -vv -p 2222" /data/ user@server:/backup/
```

### 4. Utiliser un fichier de log SSH

```bash
# Enregistrer les détails de connexion SSH
rsync -av -e "ssh -E /tmp/ssh-rsync.log" /data/ user@server:/backup/
```

### 5. Keepalive pour connexions longues

```bash
# Éviter les déconnexions sur les transferts longs
rsync -av -e "ssh -o ServerAliveInterval=60" /data/ user@server:/backup/
```

### 6. Clés SSH dédiées par usage

```bash
# Bonne pratique : une clé par service/usage
~/.ssh/
├── id_ed25519           # Clé personnelle générale
├── rsync_backup         # Clé dédiée aux sauvegardes rsync
├── deploy_web           # Clé dédiée au déploiement web
└── git_projects         # Clé dédiée à Git
```

### 7. Test rapide de connectivité

```bash
# Vérifier rapidement si rsync peut se connecter
rsync -e "ssh -p 2222" user@server:
# Liste les fichiers du home distant si la connexion fonctionne
```

### 8. Alias utiles

```bash
# Dans ~/.bashrc ou ~/.bash_aliases
alias rsync-backup='rsync -av -e "ssh -p 2222 -i ~/.ssh/backup_key"'
alias rsync-web='rsync -av -e "ssh -p 2222" --exclude=".git"'

# Utilisation
rsync-backup /var/www/ user@server:/backup/www/
```

---

> [!info] Points clés à retenir
> - SSH est le protocole par défaut et recommandé pour rsync distant
> - L'authentification par clé est préférable pour l'automatisation
> - L'option `-e` permet de personnaliser les paramètres SSH
> - Le fichier `~/.ssh/config` simplifie grandement la syntaxe
> - Toujours vérifier que SSH fonctionne avant de tester rsync