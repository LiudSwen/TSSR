

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

## 📦 Installation sur Debian/Ubuntu

### Pourquoi c'est important
Avant d'utiliser rsync, il est essentiel de s'assurer qu'il est correctement installé sur votre système. Sur les distributions Debian et Ubuntu, rsync n'est pas toujours installé par défaut, bien qu'il soit présent sur de nombreux systèmes.

### Installation standard

```bash
# Mise à jour de la liste des paquets
sudo apt update

# Installation de rsync
sudo apt install rsync

# Installation avec confirmation automatique (scripts)
sudo apt install -y rsync
```

> [!tip] Astuce de vérification rapide
> Avant d'installer, vérifiez si rsync est déjà présent avec `which rsync` ou `rsync --version`. Cela vous évitera une installation inutile.

### Vérification post-installation

```bash
# Vérifier que rsync est installé
dpkg -l | grep rsync

# Affichage attendu :
# ii  rsync  3.2.x-x  amd64  fast, versatile, remote (and local) file-copying tool
```

> [!info] Informations sur le paquet
> - **Nom du paquet** : `rsync`
> - **Dépendances** : automatiquement gérées par APT
> - **Taille approximative** : ~400 KB
> - **Maintenu par** : Debian/Ubuntu officiellement

---

## 📦 Installation sur RedHat/CentOS

### Avec YUM (CentOS 7 et versions antérieures)

```bash
# Installation avec YUM
sudo yum install rsync

# Installation avec confirmation automatique
sudo yum install -y rsync
```

### Avec DNF (CentOS 8+, RHEL 8+, Fedora)

```bash
# Installation avec DNF (gestionnaire moderne)
sudo dnf install rsync

# Installation avec confirmation automatique
sudo dnf install -y rsync
```

> [!warning] Attention aux versions
> Sur les systèmes plus anciens (CentOS 6 et antérieurs), la version de rsync peut être obsolète. Vérifiez toujours la version après installation.

### Vérification post-installation

```bash
# Vérifier avec RPM
rpm -qa | grep rsync

# Ou plus détaillé
rpm -qi rsync
```

> [!example] Sortie typique de rpm -qi
> ```
> Name        : rsync
> Version     : 3.2.x
> Release     : x.el8
> Architecture: x86_64
> Install Date: ...
> Group       : Applications/Internet
> Size        : ...
> Summary     : A program for synchronizing files over a network
> ```

---

## ✅ Vérification de la version

### Commande de base

```bash
# Afficher la version de rsync
rsync --version
```

### Sortie typique

```
rsync  version 3.2.7  protocol version 31
Copyright (C) 1996-2022 by Andrew Tridgell, Wayne Davison, and others.
Web site: https://rsync.samba.org/
Capabilities:
    64-bit files, 64-bit inums, 64-bit timestamps, 64-bit long ints,
    socketpairs, hardlinks, hardlink-specials, symlinks, IPv6, atimes,
    batchfiles, inplace, append, ACLs, xattrs, optional protect-args,
    iconv, symtimes, prealloc, stop-at, no crtimes
Optimizations:
    SIMD, asm, openssl-crypto
Checksum list:
    xxh128 xxh3 xxh64 (xxhash) md5 md4 none
Compress list:
    zstd lz4 zlibx zlib none
```

> [!info] Comprendre la version
> - **Version** : Indique la version majeure et mineure de rsync
> - **Protocol version** : Important pour la compatibilité entre machines
> - **Capabilities** : Fonctionnalités supportées par cette compilation
> - **Optimizations** : Options de performance activées

### Tableau des versions importantes

| Version | Date de sortie | Changements majeurs |
|---------|---------------|---------------------|
| 3.0.x   | 2008          | Protocole 30, amélioration performances |
| 3.1.x   | 2013          | Support ACL amélioré, compression |
| 3.2.x   | 2020          | Protocole 31, checksums modernes (xxHash) |
| 3.3.x   | 2024          | Optimisations, nouvelles fonctionnalités |

> [!warning] Compatibilité des versions
> Bien que rsync soit généralement rétro-compatible, des problèmes peuvent survenir entre versions très éloignées. Si vous synchronisez entre deux machines, vérifiez que les versions ne sont pas trop différentes (différence majeure < 2).

### Vérification du protocole

```bash
# Le numéro de protocole est crucial pour la compatibilité
rsync --version | grep protocol

# Sortie : protocol version 31
```

---

## 📁 Emplacement des fichiers de configuration

### Configuration système

#### Sur Debian/Ubuntu

```bash
# Fichier de configuration principal (si mode daemon)
/etc/rsyncd.conf

# Fichier de secrets (authentification daemon)
/etc/rsyncd.secrets

# Script de démarrage systemd
/lib/systemd/system/rsync.service
```

#### Sur RedHat/CentOS

```bash
# Configuration principale
/etc/rsyncd.conf

# Fichiers secrets
/etc/rsyncd.secrets

# Service systemd
/usr/lib/systemd/system/rsyncd.service
```

> [!info] Fichier rsyncd.conf
> Ce fichier n'existe **PAS par défaut**. Il doit être créé manuellement si vous souhaitez utiliser rsync en mode daemon. Pour une utilisation classique via SSH, ce fichier n'est pas nécessaire.

### Configuration utilisateur

```bash
# Fichiers d'exclusion personnalisés (créés par l'utilisateur)
~/.rsync-exclude
~/.rsync/exclude.txt

# Tout emplacement défini via --exclude-from
```

### Binaire et documentation

```bash
# Emplacement du binaire
/usr/bin/rsync

# Pages de manuel
/usr/share/man/man1/rsync.1.gz
/usr/share/man/man5/rsyncd.conf.5.gz

# Consulter la documentation
man rsync           # Manuel complet de rsync
man rsyncd.conf     # Manuel de configuration du daemon
```

> [!tip] Documentation locale vs en ligne
> La commande `man rsync` affiche la documentation correspondant à **votre version installée**. C'est toujours la référence la plus fiable pour connaître les options disponibles sur votre système.

### Vérification des emplacements

```bash
# Trouver l'emplacement du binaire
which rsync
# Sortie : /usr/bin/rsync

# Voir tous les fichiers installés par le paquet
dpkg -L rsync    # Debian/Ubuntu
rpm -ql rsync    # RedHat/CentOS
```

### Fichiers de logs

```bash
# Par défaut, rsync n'écrit pas dans des logs système
# Les logs doivent être configurés manuellement

# Si mode daemon avec syslog activé :
/var/log/syslog          # Debian/Ubuntu
/var/log/messages        # RedHat/CentOS

# Logs personnalisés (via scripts ou --log-file)
/var/log/rsync.log       # Exemple courant
```

> [!example] Création d'un fichier de log personnalisé
> ```bash
> # Dans un script ou une commande
> rsync -av --log-file=/var/log/rsync.log /source/ /destination/
> ```

---

## 🎯 Pièges courants

### Piège 1 : Oublier sudo pour l'installation

```bash
# ❌ ERREUR : Permission denied
apt install rsync

# ✅ CORRECT
sudo apt install rsync
```

### Piège 2 : Ne pas mettre à jour la liste des paquets

```bash
# ❌ RISQUE : Installer une version obsolète
sudo apt install rsync

# ✅ MEILLEURE PRATIQUE
sudo apt update && sudo apt install rsync
```

### Piège 3 : Confondre rsync client et rsync daemon

> [!warning] Important à comprendre
> - **rsync en mode client** : Utilisé directement en ligne de commande, ne nécessite AUCUNE configuration
> - **rsync en mode daemon** : Service qui écoute sur le port 873, nécessite `/etc/rsyncd.conf`
> 
> Pour 90% des cas d'usage (synchronisation via SSH notamment), vous n'aurez **jamais besoin** de configurer le daemon.

### Piège 4 : Versions incompatibles

```bash
# Vérifier les versions sur les deux machines
# Machine A
rsync --version | head -1
# rsync  version 3.2.7  protocol version 31

# Machine B
rsync --version | head -1
# rsync  version 3.1.2  protocol version 31
```

> [!tip] Astuce de compatibilité
> Même si les versions mineures diffèrent (3.1.x vs 3.2.x), tant que le **protocol version** est identique, la compatibilité est généralement assurée.

---

## 💡 Bonnes pratiques

### ✅ Toujours vérifier après installation

```bash
# Triple vérification
which rsync           # Présence du binaire
rsync --version       # Version et fonctionnalités
man rsync            # Documentation disponible
```

### ✅ Documenter la version dans les scripts

```bash
#!/bin/bash
# Script de sauvegarde
# Nécessite rsync >= 3.1.0

# Vérification de version (optionnel mais recommandé en production)
RSYNC_VERSION=$(rsync --version | head -1 | awk '{print $3}')
echo "Utilisation de rsync version: $RSYNC_VERSION"
```

### ✅ Maintenir rsync à jour

```bash
# Debian/Ubuntu
sudo apt update && sudo apt upgrade rsync

# RedHat/CentOS
sudo dnf upgrade rsync
```

> [!info] Pourquoi mettre à jour ?
> - Corrections de bugs
> - Améliorations de performances
> - Nouvelles fonctionnalités (checksums plus rapides, compression moderne)
> - Correctifs de sécurité

---

## 🔍 Vérification complète du système

```bash
# Script de vérification complet
echo "=== Vérification rsync ==="
echo "Binaire: $(which rsync)"
echo "Version: $(rsync --version | head -1)"
echo "Paquet installé:"
if command -v dpkg &> /dev/null; then
    dpkg -l | grep rsync
elif command -v rpm &> /dev/null; then
    rpm -qa | grep rsync
fi
echo "Documentation: $(man -w rsync 2>/dev/null || echo 'Non disponible')"
```

> [!example] Sortie attendue
> ```
> === Vérification rsync ===
> Binaire: /usr/bin/rsync
> Version: rsync  version 3.2.7  protocol version 31
> Paquet installé:
> ii  rsync  3.2.7-1  amd64  fast, versatile, remote file-copying tool
> Documentation: /usr/share/man/man1/rsync.1.gz
> ```