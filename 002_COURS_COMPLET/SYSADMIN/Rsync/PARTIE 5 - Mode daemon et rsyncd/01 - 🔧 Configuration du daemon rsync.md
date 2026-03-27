

## 📑 Table des matières

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

## 🎯 Qu'est-ce que le mode daemon

Le mode daemon transforme rsync en un service réseau permanent qui écoute sur un port (par défaut 873) et expose des "modules" - des répertoires configurés que les clients peuvent synchroniser.

> [!info] Différence avec le mode SSH
> 
> - **Mode SSH** : rsync utilise SSH comme transport, authentification par SSH
> - **Mode daemon** : rsync fonctionne comme serveur autonome, authentification propre
> - Le mode daemon est plus adapté pour des synchronisations publiques ou semi-publiques

### Quand utiliser le mode daemon ?

- Partage de fichiers publics (miroirs, repositories)
- Sauvegardes centralisées depuis plusieurs clients
- Synchronisation entre datacenters
- Besoin de contrôle fin par module
- Performance accrue (pas de surcharge SSH)

---

## 📄 Le fichier rsyncd.conf

Le fichier de configuration principal du daemon rsync est `/etc/rsyncd.conf`. Ce fichier n'existe pas par défaut et doit être créé manuellement.

> [!warning] Emplacement du fichier L'emplacement standard est `/etc/rsyncd.conf`, mais peut varier selon la distribution :
> 
> - Debian/Ubuntu : `/etc/rsyncd.conf`
> - RedHat/CentOS : `/etc/rsyncd.conf`
> - Alternative : `--config=/chemin/vers/config`

### Création du fichier de configuration

```bash
# Créer le fichier avec les bonnes permissions
sudo touch /etc/rsyncd.conf
sudo chmod 644 /etc/rsyncd.conf

# Éditer avec votre éditeur préféré
sudo nano /etc/rsyncd.conf
```

> [!tip] Validation de la configuration Avant de démarrer le daemon, testez toujours votre configuration :
> 
> ```bash
> rsync --daemon --config=/etc/rsyncd.conf --no-detach
> ```
> 
> Le mode `--no-detach` permet de voir les erreurs directement dans le terminal.

---

## 🏗️ Structure de configuration

Le fichier `rsyncd.conf` est divisé en deux parties principales :

1. **Section globale** : paramètres qui s'appliquent à tous les modules
2. **Sections modules** : configuration spécifique pour chaque répertoire partagé

```bash
# ============================================
# SECTION GLOBALE
# ============================================
# Options qui s'appliquent à tout le daemon
option_globale1 = valeur
option_globale2 = valeur

# ============================================
# MODULE 1
# ============================================
[nom_du_module]
    path = /chemin/vers/repertoire
    option1 = valeur
    option2 = valeur

# ============================================
# MODULE 2
# ============================================
[autre_module]
    path = /autre/chemin
    option1 = valeur
```

### Syntaxe importante

- Les commentaires commencent par `#`
- Format : `paramètre = valeur`
- Les noms de modules sont entre crochets `[module]`
- Les options de module sont indentées (par convention)
- Sensible à la casse

---

## 📦 Modules rsync

Un module est une section nommée qui expose un répertoire spécifique aux clients rsync. Chaque module a un nom unique utilisé par les clients pour y accéder.

### Exemple de configuration avec modules

```bash
# Section globale
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid

# Module pour les sauvegardes
[backup]
    path = /srv/backup
    comment = Zone de sauvegarde
    read only = false

# Module pour les fichiers publics
[public]
    path = /srv/public
    comment = Fichiers publics en lecture seule
    read only = true

# Module pour les logs
[logs]
    path = /var/log/apps
    comment = Logs applicatifs
    read only = true
```

### Accès aux modules depuis un client

```bash
# Lister les modules disponibles sur un serveur
rsync serveur.exemple.com::

# Synchroniser depuis un module
rsync -av serveur.exemple.com::backup /local/backup/

# Syntaxe complète
rsync [OPTIONS] serveur::module/chemin /destination/
```

> [!example] Comprendre la syntaxe
> 
> - `serveur.exemple.com::` → liste tous les modules
> - `serveur::backup` → accède au module "backup"
> - `serveur::backup/dir1` → accède au sous-répertoire dir1 dans le module

---

## 🌍 Options globales

Les options globales affectent le comportement général du daemon. Elles sont placées avant toute définition de module.

### Options globales courantes

```bash
# ============================================
# CONFIGURATION GLOBALE
# ============================================

# Fichier de log principal
log file = /var/log/rsyncd.log

# Fichier contenant le PID du processus
pid file = /var/run/rsyncd.pid

# Port d'écoute (873 par défaut)
port = 873

# Adresse d'écoute (toutes par défaut)
address = 0.0.0.0

# Message d'accueil pour les clients
motd file = /etc/rsyncd.motd

# Timeout pour les connexions inactives (en secondes)
timeout = 600

# Nombre maximum de connexions simultanées
max connections = 10

# Fichier de verrouillage
lock file = /var/run/rsync.lock

# Utiliser chroot pour tous les modules
use chroot = yes

# Utilisateur sous lequel le daemon s'exécute
uid = nobody
gid = nogroup
```

### Tableau des options globales essentielles

|Option|Description|Valeur par défaut|Exemple|
|---|---|---|---|
|`log file`|Chemin du fichier de log|aucun|`/var/log/rsyncd.log`|
|`pid file`|Fichier contenant le PID|aucun|`/var/run/rsyncd.pid`|
|`port`|Port d'écoute TCP|873|`873`|
|`address`|Adresse IP d'écoute|toutes|`192.168.1.10`|
|`max connections`|Connexions simultanées max|0 (illimité)|`10`|
|`timeout`|Timeout en secondes|0 (aucun)|`600`|
|`use chroot`|Isolation chroot|yes|`yes` ou `no`|
|`uid`|Utilisateur d'exécution|nobody|`rsync`|
|`gid`|Groupe d'exécution|nobody|`rsync`|

> [!warning] Attention au chroot `use chroot = yes` isole le daemon dans le répertoire du module pour la sécurité, mais nécessite que le daemon soit lancé en root. Si vous rencontrez des problèmes, essayez `use chroot = no`.

---

## ⚙️ Options par module

Chaque module peut avoir ses propres options qui surchargent ou complètent les options globales.

### Configuration complète d'un module

```bash
[backup_serveur]
    # Chemin du répertoire à partager (OBLIGATOIRE)
    path = /srv/backup
    
    # Description du module
    comment = Sauvegarde du serveur de production
    
    # Mode lecture seule
    read only = false
    
    # Liste des fichiers autorisés/interdits
    list = yes
    
    # Utilisateur/groupe propriétaire des fichiers
    uid = backup
    gid = backup
    
    # Restrictions d'hôtes
    hosts allow = 192.168.1.0/24 10.0.0.5
    hosts deny = *
    
    # Authentification
    auth users = admin, backup_user
    secrets file = /etc/rsyncd.secrets
    
    # Chemin chroot spécifique
    use chroot = yes
    
    # Nombre max de connexions pour ce module
    max connections = 5
    
    # Options de log
    log format = %t %a %m %f %b
    transfer logging = yes
    
    # Exclusions
    exclude = *.tmp *.cache
```

### Tableau des options par module essentielles

|Option|Description|Défaut|Exemple|
|---|---|---|---|
|`path`|Répertoire partagé (**obligatoire**)|aucun|`/srv/data`|
|`comment`|Description visible|aucun|`"Fichiers publics"`|
|`read only`|Lecture seule|yes|`yes` ou `no`|
|`list`|Visible dans la liste|yes|`yes` ou `no`|
|`uid`|Propriétaire des fichiers|nobody|`rsync`|
|`gid`|Groupe des fichiers|nobody|`rsync`|
|`hosts allow`|IPs autorisées|toutes|`192.168.1.0/24`|
|`hosts deny`|IPs refusées|aucune|`*`|
|`auth users`|Utilisateurs autorisés|aucun|`user1, user2`|
|`secrets file`|Fichier de mots de passe|aucun|`/etc/rsyncd.secrets`|
|`max connections`|Connexions max au module|0|`5`|
|`exclude`|Patterns à exclure|aucun|`*.tmp logs/`|

### Options de lecture/écriture

```bash
# Module en lecture seule (clients peuvent télécharger uniquement)
[telechargements]
    path = /srv/public
    read only = yes

# Module en lecture/écriture (clients peuvent envoyer des fichiers)
[upload]
    path = /srv/upload
    read only = false
    
# Module caché (n'apparaît pas dans la liste mais reste accessible)
[cache]
    path = /srv/cache
    list = no
```

> [!tip] Bonne pratique de sécurité Par défaut, créez des modules en `read only = yes` et n'activez l'écriture que lorsque c'est nécessaire. Combinez toujours l'écriture avec `auth users` et `hosts allow`.

### Options d'authentification

```bash
[secure_backup]
    path = /srv/secure
    read only = false
    
    # Activer l'authentification
    auth users = alice, bob
    
    # Fichier contenant les mots de passe
    secrets file = /etc/rsyncd.secrets
    
    # Strictement nécessaire : permissions 600 sur le fichier secrets
    # sudo chmod 600 /etc/rsyncd.secrets
```

**Format du fichier secrets** (`/etc/rsyncd.secrets`) :

```bash
# Format : utilisateur:mot_de_passe
alice:motdepasse_alice_securise
bob:motdepasse_bob_complexe
```

> [!warning] Sécurité du fichier secrets Le fichier `secrets file` DOIT avoir les permissions 600, sinon rsync refusera de démarrer :
> 
> ```bash
> sudo chmod 600 /etc/rsyncd.secrets
> ```

### Options de restriction réseau

```bash
[backup_local]
    path = /srv/backup
    
    # Autoriser uniquement le réseau local
    hosts allow = 192.168.1.0/24
    hosts deny = *
    
[backup_specifique]
    path = /srv/backup2
    
    # Autoriser plusieurs réseaux ou IPs spécifiques
    hosts allow = 192.168.1.0/24 10.0.0.5 172.16.0.0/16
    hosts deny = *
```

> [!info] Ordre d'évaluation
> 
> - `hosts allow` est évalué en premier
> - Si une IP match, l'accès est autorisé
> - Sinon, `hosts deny` est évalué
> - Par défaut, tout est autorisé si rien n'est spécifié

---

## ⚠️ Pièges courants

### 1. Oublier le path obligatoire

```bash
# ❌ INCORRECT - le module ne fonctionnera pas
[backup]
    comment = Zone de backup
    read only = false

# ✅ CORRECT
[backup]
    path = /srv/backup
    comment = Zone de backup
    read only = false
```

### 2. Mauvaises permissions sur secrets file

```bash
# ❌ Le daemon refusera de démarrer
-rw-r--r-- 1 root root /etc/rsyncd.secrets

# ✅ Permissions correctes
-rw------- 1 root root /etc/rsyncd.secrets

# Commande pour corriger
sudo chmod 600 /etc/rsyncd.secrets
```

### 3. Confusion entre options globales et locales

```bash
# ❌ INCORRECT - uid/gid dans la section globale mais path dans le module
uid = rsync
gid = rsync

[backup]
    path = /srv/backup

# ✅ MEILLEUR - cohérence de la configuration
[backup]
    path = /srv/backup
    uid = rsync
    gid = rsync
```

> [!tip] Astuce de configuration Les options globales sont pratiques pour des valeurs par défaut, mais il est souvent plus clair de tout définir au niveau du module pour éviter la confusion.

### 4. Oublier use chroot avec read only = false

```bash
# ⚠️ RISQUE DE SÉCURITÉ - écriture sans isolation
[upload]
    path = /srv/upload
    read only = false

# ✅ PLUS SÉCURISÉ
[upload]
    path = /srv/upload
    read only = false
    use chroot = yes
    uid = rsync
    gid = rsync
    hosts allow = 192.168.1.0/24
    hosts deny = *
```

### 5. Ne pas tester avant de mettre en production

> [!warning] Toujours tester d'abord
> 
> ```bash
> # Lancer le daemon en mode test (ne se détache pas)
> sudo rsync --daemon --no-detach --config=/etc/rsyncd.conf
> 
> # Dans un autre terminal, tester la connexion
> rsync localhost::
> 
> # Si tout fonctionne, arrêter (Ctrl+C) et lancer en mode daemon
> sudo rsync --daemon --config=/etc/rsyncd.conf
> ```

### 6. Confondre la syntaxe SSH et daemon

```bash
# ❌ Syntaxe SSH (un seul ':')
rsync -av serveur:/srv/backup /local/

# ✅ Syntaxe daemon (deux '::')
rsync -av serveur::backup /local/
```

---

## 💡 Astuces

### Astuce 1 : Configuration minimale fonctionnelle

Pour démarrer rapidement, voici une configuration minimale :

```bash
# /etc/rsyncd.conf
log file = /var/log/rsyncd.log

[test]
    path = /tmp/rsync-test
    comment = Module de test
    read only = yes
```

### Astuce 2 : Débugger avec les logs détaillés

```bash
# Configuration pour debug
[backup]
    path = /srv/backup
    log format = %t [%p] %o %h %m %f %l %b
    transfer logging = yes
    
# Lire les logs en temps réel
sudo tail -f /var/log/rsyncd.log
```

### Astuce 3 : Module avec exclusions prédéfinies

```bash
[home_backup]
    path = /home
    read only = yes
    
    # Exclure les fichiers temporaires et caches
    exclude = .cache/ .thumbnails/ *.tmp Downloads/
    
    # Exclure les fichiers cachés système
    exclude = .Private/ .ecryptfs/
```

### Astuce 4 : Créer un fichier motd personnalisé

```bash
# /etc/rsyncd.motd
==============================================
Serveur de sauvegarde - Entreprise XYZ
==============================================
Accès réservé aux administrateurs autorisés
Toutes les connexions sont loggées
==============================================

# Dans rsyncd.conf
motd file = /etc/rsyncd.motd
```

Lorsque les clients se connectent, ils verront ce message.

### Astuce 5 : Organisation multi-modules

```bash
# Configuration organisée pour différents services

[backup_web]
    path = /srv/backup/web
    comment = Sauvegardes sites web
    auth users = web_admin
    secrets file = /etc/rsyncd.secrets

[backup_db]
    path = /srv/backup/databases
    comment = Sauvegardes bases de données
    auth users = db_admin
    secrets file = /etc/rsyncd.secrets

[backup_mail]
    path = /srv/backup/mail
    comment = Sauvegardes serveur mail
    auth users = mail_admin
    secrets file = /etc/rsyncd.secrets
```

Chaque service a son module dédié avec son propre contrôle d'accès.

---