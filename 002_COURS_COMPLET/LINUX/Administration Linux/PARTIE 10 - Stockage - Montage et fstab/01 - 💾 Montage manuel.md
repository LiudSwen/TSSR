

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

## Introduction au montage

> [!info] Qu'est-ce que le montage ? Dans les systèmes Linux, contrairement à Windows qui utilise des lettres de lecteur (C:, D:, etc.), tous les périphériques de stockage sont intégrés dans une **arborescence unique** commençant à la racine `/`. Le **montage** est l'opération qui permet d'attacher un système de fichiers (partition, disque, réseau, etc.) à un point spécifique de cette arborescence appelé **point de montage**.

### Pourquoi c'est important ?

Le montage est une opération fondamentale pour :

- Accéder aux données d'une partition ou d'un disque
- Gérer des périphériques externes (clés USB, disques durs)
- Monter des partages réseau (NFS, CIFS/SMB)
- Configurer des systèmes de fichiers temporaires (`tmpfs`)
- Organiser l'architecture de stockage d'un serveur

---

## Montage manuel

### Commande mount

#### Syntaxe de base

```bash
mount [options] <périphérique> <point_de_montage>
```

> [!example] Exemple simple
> 
> ```bash
> # Monter une partition sur /mnt/data
> mount /dev/sdb1 /mnt/data
> 
> # Monter un partage NFS
> mount 192.168.1.100:/export/shared /mnt/nfs
> 
> # Monter une image ISO
> mount -o loop /chemin/vers/image.iso /mnt/iso
> ```

#### Afficher les montages actuels

```bash
# Afficher tous les systèmes de fichiers montés
mount

# Afficher de manière plus lisible
mount | column -t

# Lister uniquement certains types
mount -t ext4
mount -t nfs
```

> [!tip] Alternative moderne La commande `findmnt` offre une vue hiérarchique plus claire :
> 
> ```bash
> findmnt
> findmnt /mnt/data
> findmnt --df  # Format similaire à df
> ```

#### Montage avec spécification du système de fichiers

```bash
# Spécifier explicitement le type de système de fichiers
mount -t ext4 /dev/sdb1 /mnt/data
mount -t xfs /dev/sdc1 /mnt/backup
mount -t vfat /dev/sdd1 /mnt/usb
mount -t ntfs-3g /dev/sde1 /mnt/windows
```

> [!info] Détection automatique En général, `mount` détecte automatiquement le type de système de fichiers. L'option `-t` est utile pour :
> 
> - Forcer un type spécifique
> - Éviter des tentatives de détection sur des systèmes exotiques
> - Documenter explicitement le type dans des scripts

#### Montage en lecture seule

```bash
# Monter en lecture seule
mount -o ro /dev/sdb1 /mnt/readonly

# Remonter un système déjà monté en lecture seule
mount -o remount,ro /mnt/data
```

> [!warning] Attention aux modifications Un montage en lecture seule est crucial pour :
> 
> - Examiner un disque sans risque de corruption
> - Monter des systèmes de fichiers endommagés
> - Garantir l'intégrité de données sensibles
> - Respecter des contraintes de sécurité

#### Montage d'images disques et ISO

```bash
# Monter une image ISO (option loop)
mount -o loop /chemin/vers/ubuntu.iso /mnt/iso

# Monter une image disque brute
mount -o loop disk.img /mnt/image

# Monter une partition spécifique dans une image disque
# (offset en octets, à calculer avec fdisk -l image.img)
mount -o loop,offset=1048576 disk.img /mnt/partition1
```

---

### Commande umount

#### Syntaxe de base

```bash
umount <point_de_montage>
# ou
umount <périphérique>
```

> [!example] Exemples de démontage
> 
> ```bash
> # Démonter par point de montage
> umount /mnt/data
> 
> # Démonter par périphérique
> umount /dev/sdb1
> 
> # Démonter tous les points de montage d'un type
> umount -a -t nfs
> ```

#### Gestion des erreurs "device is busy"

> [!warning] Erreur courante : target is busy Cette erreur survient quand des processus utilisent encore le système de fichiers.

```bash
# Identifier les processus utilisant le point de montage
lsof /mnt/data
fuser -m /mnt/data

# Tuer les processus bloquants (avec prudence !)
fuser -km /mnt/data

# Afficher les processus de manière détaillée
lsof +D /mnt/data
```

> [!tip] Vérification avant démontage Toujours vérifier qu'aucun terminal n'a son répertoire courant dans le point de montage :
> 
> ```bash
> pwd  # Si vous êtes dans /mnt/data, cd ailleurs d'abord !
> cd /
> umount /mnt/data
> ```

#### Démontage paresseux (lazy unmount)

```bash
# Démontage lazy : détache immédiatement mais nettoie quand c'est possible
umount -l /mnt/data
```

> [!warning] Utilisation du lazy unmount Le démontage lazy (`-l`) :
> 
> - **Avantage** : Ne bloque pas, détache le système de fichiers immédiatement
> - **Inconvénient** : Peut masquer des problèmes (processus bloqués non identifiés)
> - **Usage recommandé** : En dernier recours ou pour des situations de maintenance d'urgence

#### Démontage forcé

```bash
# Force le démontage (dangereux, surtout pour NFS)
umount -f /mnt/nfs

# Combinaison force + lazy
umount -f -l /mnt/nfs
```

> [!danger] Attention au démontage forcé Le démontage forcé peut entraîner :
> 
> - Perte de données non synchronisées
> - Corruption du système de fichiers
> - Blocage de processus
> 
> À utiliser uniquement quand :
> 
> - Un serveur NFS est inaccessible de manière permanente
> - Aucune autre solution ne fonctionne
> - Vous acceptez le risque de perte de données

#### Vérification après démontage

```bash
# Vérifier que le démontage a réussi
mount | grep /mnt/data
findmnt /mnt/data

# Résultat vide = démontage réussi
```

---

### Options de montage courantes

Les options de montage modifient le comportement du système de fichiers monté. Elles se spécifient avec `-o`.

#### Syntaxe générale

```bash
mount -o option1,option2,option3 <périphérique> <point_de_montage>
```

#### Options de lecture/écriture

|Option|Description|Usage typique|
|---|---|---|
|`ro`|Read-only (lecture seule)|Disques de récupération, ISO, protection|
|`rw`|Read-write (lecture/écriture)|Mode par défaut|
|`remount`|Remonter avec nouvelles options|Changer ro↔rw sans démonter|

```bash
# Monter en lecture seule
mount -o ro /dev/sdb1 /mnt/data

# Remonter en lecture/écriture sans démonter
mount -o remount,rw /mnt/data

# Remonter la racine en lecture seule (maintenance)
mount -o remount,ro /
```

#### Options d'exécution et de sécurité

|Option|Description|Impact sécurité|
|---|---|---|
|`exec`|Autoriser l'exécution de binaires|Par défaut|
|`noexec`|Interdire l'exécution de binaires|⚠️ Haute sécurité|
|`suid`|Autoriser les bits SUID/SGID|Par défaut|
|`nosuid`|Ignorer les bits SUID/SGID|⚠️ Haute sécurité|
|`dev`|Interpréter les fichiers spéciaux|Par défaut|
|`nodev`|Ignorer les fichiers spéciaux|⚠️ Haute sécurité|

```bash
# Monter une partition utilisateur de manière sécurisée
mount -o noexec,nosuid,nodev /dev/sdb1 /home

# Monter une clé USB avec restrictions maximales
mount -o noexec,nosuid,nodev,ro /dev/sdd1 /mnt/usb

# Partition /tmp sécurisée
mount -o noexec,nosuid,nodev /dev/sdb2 /tmp
```

> [!tip] Bonnes pratiques de sécurité Montez systématiquement avec `noexec,nosuid,nodev` :
> 
> - `/tmp` - évite l'exécution de malware temporaire
> - `/home` - limite les élévations de privilèges
> - Partitions utilisateur externes
> - Clés USB et supports amovibles

#### Options de temps d'accès (atime)

|Option|Description|Performance|
|---|---|---|
|`atime`|Met à jour le temps d'accès|⚠️ Écritures fréquentes|
|`noatime`|Ne met jamais à jour atime|✅ Meilleures performances|
|`relatime`|Met à jour atime si modifié ou ancien|⚡ Bon compromis (défaut)|
|`strictatime`|Met toujours à jour atime|⚠️ Performances dégradées|

```bash
# Optimisation performance pour SSD
mount -o noatime /dev/sdb1 /mnt/data

# Compromis entre compatibilité et performance (défaut moderne)
mount -o relatime /dev/sdb1 /mnt/data
```

> [!info] Impact des options atime
> 
> - **`atime`** : Chaque lecture génère une écriture → usure SSD, performance réduite
> - **`noatime`** : Gain de performance 5-10%, recommandé pour SSD et serveurs
> - **`relatime`** : Défaut moderne, bon compromis
> - Certaines applications anciennes dépendent de atime (rares aujourd'hui)

#### Options utilisateur

|Option|Description|Permissions|
|---|---|---|
|`user`|Autoriser les utilisateurs normaux à monter|N'importe quel utilisateur|
|`nouser`|Seul root peut monter|Par défaut|
|`users`|N'importe qui peut monter, n'importe qui peut démonter|Très permissif|
|`owner`|Seul le propriétaire du périphérique peut monter|Propriété requise|

```bash
# Permettre aux utilisateurs de monter leur clé USB
mount -o user,noexec,nosuid,nodev /dev/sdd1 /media/usb

# Dans /etc/fstab pour autoriser les utilisateurs
/dev/sdd1  /media/usb  vfat  user,noauto,noexec,nosuid,nodev  0  0
```

#### Options de synchronisation

|Option|Description|Performance vs Sécurité|
|---|---|---|
|`sync`|Écritures synchrones immédiates|⚠️ Très lent, très sûr|
|`async`|Écritures asynchrones en cache|✅ Rapide, défaut|
|`dirsync`|Synchrone uniquement pour les métadonnées de répertoires|⚡ Compromis|

```bash
# Clé USB avec écritures synchrones (évite la corruption si débranchée)
mount -o sync /dev/sdd1 /mnt/usb

# Serveur de base de données (performance critique)
mount -o async,noatime /dev/sdb1 /var/lib/mysql
```

> [!warning] sync vs async
> 
> - **`sync`** : Chaque écriture attend la confirmation physique → TRÈS lent pour clés USB
> - **`async`** : Écritures en cache → risque de perte si déconnexion brutale
> - Préférez `async` avec `umount` propre plutôt que `sync` permanent

#### Options spécifiques aux systèmes de fichiers

##### ext4

```bash
# Désactiver le journal pour plus de performance (dangeureux)
mount -o nojournal /dev/sdb1 /mnt/data

# Options de barrière d'écriture
mount -o barrier=0 /dev/sdb1 /mnt/data  # Désactive (gain perf, perte sûreté)
mount -o barrier=1 /dev/sdb1 /mnt/data  # Active (défaut, plus sûr)
```

##### NTFS (via ntfs-3g)

```bash
# Monter NTFS avec permissions pour tous
mount -t ntfs-3g -o permissions,uid=1000,gid=1000 /dev/sdb1 /mnt/windows

# NTFS en lecture/écriture complète
mount -t ntfs-3g -o rw,uid=1000,gid=1000,dmask=022,fmask=133 /dev/sdb1 /mnt/windows
```

##### VFAT/FAT32

```bash
# Monter FAT32 avec propriétaire spécifique
mount -t vfat -o uid=1000,gid=1000,dmask=022,fmask=133 /dev/sdd1 /mnt/usb

# Avec encodage spécifique pour les noms de fichiers
mount -t vfat -o iocharset=utf8,codepage=850 /dev/sdd1 /mnt/usb
```

#### Options réseau (NFS)

```bash
# Montage NFS avec options de performance
mount -t nfs -o rw,hard,intr,rsize=8192,wsize=8192 server:/export /mnt/nfs

# Montage NFS avec timeout
mount -t nfs -o soft,timeo=10,retrans=3 server:/export /mnt/nfs
```

|Option NFS|Description|
|---|---|
|`hard`|Réessaye indéfiniment si serveur inaccessible (défaut)|
|`soft`|Retourne une erreur après timeout|
|`intr`|Permet d'interrompre les requêtes bloquées|
|`rsize`|Taille des paquets de lecture|
|`wsize`|Taille des paquets d'écriture|

#### Combinaison d'options courantes

```bash
# Partition /home sécurisée et optimisée
mount -o noexec,nosuid,nodev,noatime,relatime /dev/sdb1 /home

# Partition /tmp volatile et sécurisée
mount -t tmpfs -o mode=1777,nodev,nosuid,noexec tmpfs /tmp

# SSD avec optimisations maximales
mount -o noatime,discard,errors=remount-ro /dev/sdb1 /mnt/ssd

# Clé USB sécurisée et portable
mount -o user,noexec,nosuid,nodev,utf8,flush /dev/sdd1 /media/usb
```

> [!tip] Astuces pour choisir les options
> 
> 1. **Sécurité d'abord** : Toujours commencer par `noexec,nosuid,nodev` sauf si nécessaire
> 2. **Performance SSD** : Ajouter `noatime,discard`
> 3. **Supports amovibles** : Ajouter `sync` ou `flush` (vfat) pour éviter la corruption
> 4. **Partitions système** : Conserver les options par défaut sauf raison spécifique
> 5. **Test** : Tester les options avec `mount -o remount` avant de les fixer dans fstab

---

## 🎯 Pièges courants et bonnes pratiques

### Pièges à éviter

> [!danger] Erreurs fréquentes
> 
> 1. **Oublier de créer le point de montage** avant de monter
>     
>     ```bash
>     mkdir -p /mnt/data  # Toujours créer d'abord !
>     mount /dev/sdb1 /mnt/data
>     ```
>     
> 2. **Démonter sans vérifier les processus actifs**
>     
>     ```bash
>     lsof /mnt/data  # Toujours vérifier avant !
>     ```
>     
> 3. **Utiliser `umount -f` trop rapidement**
>     
>     - Essayer d'abord d'identifier et arrêter les processus
>     - Le force unmount est un dernier recours
> 4. **Monter avec les mauvaises permissions (NTFS/FAT)**
>     
>     - Toujours spécifier `uid`, `gid`, `dmask`, `fmask` pour les systèmes non-Unix
> 5. **Ignorer `noatime` sur les SSD**
>     
>     - Gain de performance significatif
>     - Réduit l'usure des SSD

### Bonnes pratiques

> [!tip] Recommandations professionnelles
> 
> **Avant montage :**
> 
> - Vérifier l'existence du périphérique : `lsblk`, `fdisk -l`
> - Créer le point de montage : `mkdir -p /mnt/destination`
> - Vérifier que le point de montage est vide
> 
> **Pendant le montage :**
> 
> - Spécifier explicitement le type si doute : `-t ext4`
> - Utiliser les options de sécurité par défaut : `noexec,nosuid,nodev`
> - Documenter les options inhabituelles
> 
> **Avant démontage :**
> 
> - Quitter tous les répertoires du point de montage : `cd /`
> - Vérifier les processus actifs : `lsof`, `fuser`
> - Synchroniser les écritures : `sync` (optionnel mais prudent)
> 
> **Pour les scripts :**
> 
> - Toujours vérifier le code retour : `if mount ...; then`
> - Utiliser des chemins absolus
> - Nettoyer en cas d'erreur (démonter si échec)

### Vérifications utiles

```bash
# Vérifier qu'un système de fichiers est bien monté
mountpoint /mnt/data
# Retourne 0 si monté, 1 sinon

# Vérifier l'espace disponible après montage
df -h /mnt/data

# Vérifier les permissions
ls -ld /mnt/data

# Tester l'accès en écriture
touch /mnt/data/test && rm /mnt/data/test

# Vérifier les options de montage actives
findmnt /mnt/data
```

---

## 💡 Astuces avancées

### Montage automatique au démarrage

> [!info] Pour le montage automatique permanent Les sections suivantes sur `/etc/fstab` et `systemd.mount` seront couvertes dans d'autres parties du cours. Pour un montage temporaire, utilisez les commandes `mount` manuelles.

### Montages bind

```bash
# Monter un répertoire existant ailleurs dans l'arborescence
mount --bind /home/user/documents /mnt/docs

# Monter en lecture seule bind
mount --bind /source /destination
mount -o remount,ro,bind /destination
```

> [!example] Cas d'usage des bind mounts
> 
> - Partager un répertoire dans plusieurs emplacements
> - Présenter des données à un chroot ou conteneur
> - Réorganiser temporairement l'arborescence
> - Permettre l'accès à des données sans lien symbolique

### Montages en boucle avec offset

```bash
# Afficher la table de partition d'une image
fdisk -l disk.img

# Calculer l'offset : début de partition × taille de secteur
# Exemple : secteur 2048 × 512 = 1048576 octets
mount -o loop,offset=1048576 disk.img /mnt/partition

# Alternative avec losetup pour plus de contrôle
losetup -f --show -o 1048576 disk.img  # Retourne /dev/loop0
mount /dev/loop0 /mnt/partition
# Démontage
umount /mnt/partition
losetup -d /dev/loop0
```

### Montages overlay (union)

```bash
# Créer une vue combinée de plusieurs répertoires
mount -t overlay overlay \
  -o lowerdir=/dir1:/dir2,upperdir=/changes,workdir=/work \
  /mnt/combined
```

> [!info] Utilité d'overlay Utilisé principalement dans Docker et les conteneurs pour empiler les couches du système de fichiers (sera détaillé dans une partie sur les systèmes de fichiers avancés).

---

## 📊 Récapitulatif des commandes essentielles

|Commande|Description|Exemple|
|---|---|---|
|`mount`|Monter un système de fichiers|`mount /dev/sdb1 /mnt/data`|
|`mount -a`|Monter tout ce qui est dans fstab|`mount -a`|
|`mount -o remount`|Remonter avec nouvelles options|`mount -o remount,ro /`|
|`umount`|Démonter|`umount /mnt/data`|
|`umount -l`|Démontage lazy|`umount -l /mnt/busy`|
|`findmnt`|Afficher l'arborescence des montages|`findmnt /mnt/data`|
|`lsblk`|Lister les périphériques bloc|`lsblk`|
|`lsof`|Processus utilisant un montage|`lsof /mnt/data`|
|`fuser`|Identifier/tuer processus|`fuser -m /mnt/data`|
|`mountpoint`|Vérifier si monté|`mountpoint /mnt/data`|

---

> [!success] Points clés à retenir
> 
> - Le montage intègre un système de fichiers dans l'arborescence Linux
> - `mount` attache, `umount` détache
> - Les options de montage (`-o`) contrôlent le comportement et la sécurité
> - Toujours vérifier les processus actifs avant de démonter
> - Les options `noexec,nosuid,nodev,noatime` améliorent sécurité et performances
> - Utiliser `findmnt` et `lsof` pour diagnostiquer les problèmes de montage