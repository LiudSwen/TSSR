

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

## Introduction

Les **points de montage** sont des répertoires qui servent de porte d'entrée pour accéder au contenu d'un système de fichiers. Sous Linux, toute partition, disque ou périphérique de stockage doit être monté sur un point de montage pour être accessible.

> [!info] Concept fondamental Contrairement à Windows qui utilise des lettres de lecteurs (C:, D:, E:), Linux intègre tous les systèmes de fichiers dans une arborescence unique commençant à la racine `/`. Les points de montage permettent d'ajouter des branches à cet arbre.

---

## Création de points de montage

### 📍 Qu'est-ce qu'un point de montage ?

Un point de montage est simplement un **répertoire vide** qui va recevoir le contenu d'un système de fichiers. Une fois le montage effectué, les fichiers du système de fichiers deviennent accessibles via ce répertoire.

### Pourquoi créer des points de montage ?

- Organiser le stockage de manière logique
- Séparer les données système des données utilisateur
- Faciliter les sauvegardes et la maintenance
- Améliorer la sécurité en isolant certaines partitions
- Permettre le montage de périphériques externes

### Création d'un point de montage

```bash
# Syntaxe de base
sudo mkdir /chemin/vers/point_de_montage

# Exemples courants
sudo mkdir /mnt/data
sudo mkdir /media/backup
sudo mkdir /srv/web
```

> [!tip] Bonne pratique Créez toujours vos points de montage avec les permissions root (sudo) et vérifiez qu'ils sont vides avant le montage.

### Vérification avant montage

```bash
# Vérifier que le répertoire est vide
ls -la /mnt/data

# Vérifier les permissions
ls -ld /mnt/data

# Résultat attendu : drwxr-xr-x
```

> [!warning] Attention au contenu existant Si un répertoire contient déjà des fichiers, ceux-ci deviendront inaccessibles une fois qu'un système de fichiers sera monté dessus. Ils ne sont pas supprimés, juste masqués jusqu'au démontage.

### Montage manuel d'un système de fichiers

```bash
# Syntaxe générale
sudo mount [options] <périphérique> <point_de_montage>

# Exemple : monter une partition ext4
sudo mount /dev/sdb1 /mnt/data

# Exemple : monter avec des options spécifiques
sudo mount -t ext4 -o defaults,noatime /dev/sdb1 /mnt/data
```

### Vérification du montage

```bash
# Afficher tous les systèmes de fichiers montés
mount | grep /mnt/data

# Ou utiliser df
df -h /mnt/data

# Ou lister avec findmnt (plus moderne)
findmnt /mnt/data
```

> [!example] Exemple de sortie
> 
> ```
> /dev/sdb1 on /mnt/data type ext4 (rw,relatime)
> ```

### Démontage

```bash
# Démonter un système de fichiers
sudo umount /mnt/data

# Ou en spécifiant le périphérique
sudo umount /dev/sdb1

# Forcer le démontage (à utiliser avec précaution)
sudo umount -f /mnt/data

# Démontage paresseux (lazy unmount)
sudo umount -l /mnt/data
```

> [!warning] Démontage bloqué Si un processus utilise encore des fichiers sur le système de fichiers, le démontage échouera. Utilisez `lsof` ou `fuser` pour identifier les processus concernés :
> 
> ```bash
> sudo lsof /mnt/data
> sudo fuser -m /mnt/data
> ```

---

## Conventions de nommage

### 📂 Hiérarchie standard FHS (Filesystem Hierarchy Standard)

Linux suit des conventions bien établies pour l'organisation des points de montage. Respecter ces conventions facilite l'administration et la maintenance.

### Emplacements standards

|Point de montage|Usage|Description|
|---|---|---|
|`/`|Racine|Point de montage principal du système|
|`/boot`|Démarrage|Partition contenant le noyau et les fichiers de démarrage|
|`/home`|Utilisateurs|Répertoires personnels des utilisateurs|
|`/tmp`|Temporaire|Fichiers temporaires (souvent en tmpfs)|
|`/var`|Variables|Logs, caches, spools, données variables|
|`/srv`|Services|Données servies par le système (web, FTP)|
|`/opt`|Optionnel|Applications tierces|
|`/mnt`|Montage temporaire|Point de montage manuel temporaire|
|`/media`|Médias amovibles|Montage automatique des périphériques (USB, CD)|

### Emplacement `/mnt`

Utilisé pour les montages **temporaires** et **manuels** d'administrateur.

```bash
# Exemples d'utilisation
sudo mkdir /mnt/usb_backup
sudo mkdir /mnt/network_share
sudo mkdir /mnt/iso_image

# Montage d'une clé USB
sudo mount /dev/sdc1 /mnt/usb_backup

# Montage d'une image ISO
sudo mount -o loop image.iso /mnt/iso_image
```

> [!info] Quand utiliser /mnt ?
> 
> - Montages temporaires pour maintenance
> - Tests de nouveaux disques
> - Montages manuels ponctuels
> - Travail d'administration système

### Emplacement `/media`

Utilisé pour les montages **automatiques** de périphériques amovibles, généralement géré par le système.

```bash
# Structure typique
/media/username/USB_DISK
/media/username/CDROM
/media/username/Partition_Label
```

> [!tip] Montage automatique Les environnements de bureau modernes (GNOME, KDE, XFCE) montent automatiquement les périphériques amovibles dans `/media/$USER/`. Ne créez pas manuellement de points de montage ici.

### Emplacements personnalisés pour données permanentes

Pour les partitions de données permanentes, créez des points de montage logiques :

```bash
# Données d'applications
/data
/data/mysql
/data/postgres
/data/www

# Sauvegardes
/backup
/backup/daily
/backup/weekly

# Partages réseau
/nfs
/nfs/shared
/nfs/projects

# Stockage spécifique
/storage
/storage/documents
/storage/media
```

### Convention de nommage des répertoires

> [!tip] Bonnes pratiques
> 
> - **Minuscules** : utilisez des noms en minuscules (`/mnt/data` plutôt que `/mnt/Data`)
> - **Pas d'espaces** : utilisez des underscores ou tirets (`backup_files` ou `backup-files`)
> - **Noms descriptifs** : privilégiez la clarté (`/mnt/external_backup` plutôt que `/mnt/disk`)
> - **Cohérence** : adoptez une convention et respectez-la

### Exemples de mauvaises pratiques

```bash
# ❌ À éviter
/My Documents           # Espaces
/MNT/DATA              # Majuscules
/mnt/d                 # Nom non descriptif
/mnt/temp disk 2023    # Espaces et peu clair
```

```bash
# ✅ Préférer
/mnt/documents
/mnt/data
/mnt/external_disk
/mnt/backup_2024
```

---

## Montage de partitions supplémentaires

### 🔧 Identification des partitions

Avant de monter une partition, il faut l'identifier correctement.

#### Liste des périphériques de bloc

```bash
# Lister tous les périphériques de bloc
lsblk

# Sortie détaillée avec système de fichiers
lsblk -f

# Affichage avec UUID
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,UUID,FSTYPE
```

> [!example] Exemple de sortie lsblk
> 
> ```
> NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
> sda      8:0    0 238.5G  0 disk 
> ├─sda1   8:1    0   512M  0 part /boot/efi
> ├─sda2   8:2    0    50G  0 part /
> └─sda3   8:3    0   188G  0 part /home
> sdb      8:16   0   1.8T  0 disk 
> └─sdb1   8:17   0   1.8T  0 part 
> ```

#### Affichage des UUID

L'UUID (Universally Unique Identifier) est l'identifiant unique d'une partition, préférable aux noms de périphériques qui peuvent changer.

```bash
# Méthode 1 : blkid
sudo blkid

# Méthode 2 : lsblk avec UUID
lsblk -f

# Méthode 3 : consulter /dev/disk/by-uuid/
ls -l /dev/disk/by-uuid/
```

> [!info] Pourquoi utiliser les UUID ? Les noms de périphériques (`/dev/sdb1`) peuvent changer au redémarrage si vous ajoutez/retirez des disques. Les UUID restent constants et garantissent que la bonne partition sera toujours montée.

### Préparation d'une nouvelle partition

#### Étapes complètes

```bash
# 1. Identifier le nouveau disque
lsblk

# 2. Créer un système de fichiers (si nécessaire)
sudo mkfs.ext4 /dev/sdb1

# 3. Créer le point de montage
sudo mkdir /mnt/storage

# 4. Monter temporairement pour tester
sudo mount /dev/sdb1 /mnt/storage

# 5. Vérifier le montage
df -h /mnt/storage
ls -la /mnt/storage

# 6. Tester l'écriture
sudo touch /mnt/storage/test_file
```

### Montage avec options spécifiques

```bash
# Montage en lecture seule
sudo mount -o ro /dev/sdb1 /mnt/storage

# Montage avec noatime (améliore les performances)
sudo mount -o noatime /dev/sdb1 /mnt/storage

# Montage avec permissions spécifiques (utile pour NTFS/FAT32)
sudo mount -o uid=1000,gid=1000 /dev/sdb1 /mnt/storage

# Combinaison d'options
sudo mount -o defaults,noatime,nodiratime /dev/sdb1 /mnt/storage
```

### Options de montage courantes

|Option|Description|Usage|
|---|---|---|
|`defaults`|Options par défaut (rw, suid, dev, exec, auto, nouser, async)|Standard|
|`rw` / `ro`|Lecture-écriture / Lecture seule|Contrôle d'accès|
|`noatime`|Ne met pas à jour l'heure d'accès aux fichiers|Performance|
|`nodiratime`|Ne met pas à jour l'heure d'accès aux répertoires|Performance|
|`noexec`|Empêche l'exécution de binaires|Sécurité|
|`nosuid`|Ignore les bits SUID/SGID|Sécurité|
|`nodev`|Ignore les fichiers de périphériques|Sécurité|
|`user`|Permet aux utilisateurs de monter|Commodité|
|`auto` / `noauto`|Montage automatique au boot ou non|Configuration boot|

### Montage de différents types de systèmes de fichiers

#### Partition Linux (ext4, xfs, btrfs)

```bash
# ext4 (le plus courant)
sudo mount -t ext4 /dev/sdb1 /mnt/data

# XFS
sudo mount -t xfs /dev/sdb1 /mnt/data

# Btrfs avec compression
sudo mount -t btrfs -o compress=zstd /dev/sdb1 /mnt/data
```

#### Partition Windows (NTFS)

```bash
# NTFS avec support lecture/écriture (nécessite ntfs-3g)
sudo mount -t ntfs-3g /dev/sdb1 /mnt/windows

# Avec permissions pour un utilisateur spécifique
sudo mount -t ntfs-3g -o uid=1000,gid=1000,umask=022 /dev/sdb1 /mnt/windows
```

> [!warning] Pilote NTFS Pour un support complet de NTFS, installez le paquet `ntfs-3g` :
> 
> ```bash
> sudo apt install ntfs-3g    # Debian/Ubuntu
> sudo yum install ntfs-3g    # RHEL/CentOS
> ```

#### Partition FAT32 (clés USB)

```bash
# FAT32 / vFAT
sudo mount -t vfat -o uid=1000,gid=1000,umask=022 /dev/sdc1 /mnt/usb
```

#### Partition exFAT

```bash
# exFAT (nécessite exfat-fuse et exfat-utils)
sudo mount -t exfat /dev/sdc1 /mnt/external
```

### Montage de partages réseau

#### NFS (Network File System)

```bash
# Créer le point de montage
sudo mkdir /mnt/nfs_share

# Monter un partage NFS
sudo mount -t nfs server.example.com:/export/share /mnt/nfs_share

# Avec options
sudo mount -t nfs -o rw,soft,intr server.example.com:/export/share /mnt/nfs_share
```

#### CIFS/SMB (Windows Share)

```bash
# Monter un partage Windows/Samba
sudo mount -t cifs //server/share /mnt/smb -o username=user,password=pass

# Avec fichier de credentials (plus sécurisé)
sudo mount -t cifs //server/share /mnt/smb -o credentials=/root/.smbcredentials
```

### Montage d'images ISO

```bash
# Créer le point de montage
sudo mkdir /mnt/iso

# Monter l'image ISO en lecture seule
sudo mount -o loop /chemin/vers/image.iso /mnt/iso

# Vérifier le contenu
ls /mnt/iso
```

> [!tip] Option loop L'option `-o loop` permet de monter un fichier image comme s'il s'agissait d'un périphérique de bloc réel.

### Gestion des permissions après montage

```bash
# Changer le propriétaire du point de montage
sudo chown -R username:groupname /mnt/data

# Modifier les permissions
sudo chmod 755 /mnt/data

# Pour les systèmes de fichiers ne supportant pas les permissions Unix (FAT32, NTFS),
# utilisez les options de montage uid, gid et umask
```

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> **"Device or resource busy"**
> 
> - Un processus utilise encore le système de fichiers
> - Solution : `sudo fuser -km /mnt/data` (termine les processus)
> 
> **"Mount point does not exist"**
> 
> - Le point de montage n'a pas été créé
> - Solution : `sudo mkdir /mnt/point_montage`
> 
> **"Wrong fs type, bad option, bad superblock"**
> 
> - Type de système de fichiers incorrect
> - Solution : Vérifier avec `sudo blkid /dev/sdX` et spécifier `-t type`
> 
> **Permissions refusées après montage**
> 
> - Pour NTFS/FAT : utiliser options `uid=`, `gid=`, `umask=`
> - Pour ext4/xfs : utiliser `chown` et `chmod` après montage

### Automatisation du montage

Pour un montage permanent au démarrage, il faut configurer le fichier `/etc/fstab` (ce sujet sera abordé dans une autre partie du cours).

```bash
# Montage temporaire pour la session actuelle
sudo mount /dev/sdb1 /mnt/data

# Pour rendre permanent, ajouter une ligne dans /etc/fstab
# (voir section fstab du cours)
```

---

> [!tip] Récapitulatif
> 
> - Créez toujours des points de montage vides avec `mkdir`
> - Utilisez des conventions de nommage cohérentes et descriptives
> - Privilégiez `/mnt` pour les montages temporaires manuels
> - Utilisez les UUID plutôt que les noms de périphériques pour la stabilité
> - Testez toujours un montage manuel avant de le rendre permanent
> - Vérifiez le type de système de fichiers avec `lsblk -f` ou `blkid`
> - Adaptez les options de montage selon vos besoins (performance, sécurité)