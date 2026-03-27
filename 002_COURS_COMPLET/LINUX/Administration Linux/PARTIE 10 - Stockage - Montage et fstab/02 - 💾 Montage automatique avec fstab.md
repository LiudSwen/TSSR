

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

Le fichier `/etc/fstab` (File System TABle) est le fichier de configuration central pour le montage automatique des systèmes de fichiers sous Linux. Il permet de définir quels systèmes de fichiers doivent être montés au démarrage du système et avec quelles options.

> [!info] Pourquoi utiliser fstab ?
> 
> - **Automatisation** : Les systèmes de fichiers sont montés automatiquement au démarrage
> - **Cohérence** : Configuration centralisée et persistante entre les redémarrages
> - **Simplicité** : Permet d'utiliser `mount /point-de-montage` sans spécifier tous les paramètres
> - **Normalisation** : Standard utilisé par tous les systèmes Unix/Linux

---

## Structure du fichier /etc/fstab

### Format général

Le fichier `/etc/fstab` contient une ligne par système de fichiers, avec 6 champs séparés par des espaces ou des tabulations :

```bash
# <périphérique>  <point-de-montage>  <type>  <options>  <dump>  <pass>
```

### Détail des champs

|Champ|Nom|Description|
|---|---|---|
|1|Périphérique|Identification du système de fichiers (device, UUID, LABEL)|
|2|Point de montage|Répertoire où sera monté le système de fichiers|
|3|Type|Type de système de fichiers (ext4, xfs, vfat, nfs, etc.)|
|4|Options|Options de montage (séparées par des virgules)|
|5|Dump|Sauvegarde avec dump (0=non, 1=oui) - généralement obsolète|
|6|Pass|Ordre de vérification fsck au boot (0=non, 1=root, 2=autres)|

### Exemple de fichier fstab

```bash
# /etc/fstab: static file system information
#
# <file system>             <mount point>  <type>  <options>           <dump>  <pass>

# Système de fichiers racine
UUID=1234-5678-90ab-cdef    /              ext4    defaults            1       1

# Partition swap
UUID=abcd-ef12-3456-7890    none           swap    sw                  0       0

# Partition home
UUID=9876-5432-10fe-dcba    /home          ext4    defaults,noatime    1       2

# Partition de données
UUID=fedc-ba09-8765-4321    /data          xfs     defaults,nofail     0       2

# Montage temporaire
tmpfs                       /tmp           tmpfs   defaults,size=2G    0       0

# Montage réseau NFS
server:/export/share        /mnt/nfs       nfs     defaults,_netdev    0       0

# Clé USB avec label
LABEL=USB_BACKUP            /mnt/backup    ext4    noauto,user         0       0
```

> [!warning] Commentaires dans fstab
> 
> - Les lignes commençant par `#` sont des commentaires
> - Il est recommandé de documenter chaque entrée pour faciliter la maintenance
> - Un fstab mal configuré peut empêcher le système de démarrer correctement

### Signification du champ dump

```bash
# 0 : Ne pas sauvegarder avec dump (valeur par défaut recommandée)
# 1 : Sauvegarder avec dump (outil historique, peu utilisé aujourd'hui)
```

> [!tip] Astuce dump Utilisez toujours `0` pour ce champ sauf si vous utilisez explicitement l'outil `dump` pour vos sauvegardes, ce qui est très rare sur les systèmes modernes.

### Signification du champ pass (fsck)

```bash
# 0 : Ne pas vérifier avec fsck au démarrage
# 1 : Vérifier en premier (réservé au système de fichiers racine /)
# 2 : Vérifier après le système racine (pour les autres partitions)
```

> [!info] Ordre de vérification fsck
> 
> - Le système de fichiers racine `/` doit avoir `pass=1`
> - Les autres systèmes de fichiers locaux ont généralement `pass=2`
> - Les systèmes de fichiers réseau ou temporaires ont `pass=0`

---

## Identification par UUID et LABEL

### Pourquoi utiliser UUID ou LABEL ?

Les noms de périphériques traditionnels (`/dev/sda1`, `/dev/sdb1`) peuvent changer entre les redémarrages si l'ordre de détection change. Les UUID et LABEL garantissent l'identification stable des systèmes de fichiers.

> [!warning] Problème des noms de périphériques Si vous ajoutez un nouveau disque, `/dev/sdb` peut devenir `/dev/sdc`, cassant votre configuration fstab basée sur les noms de périphériques.

### Méthodes d'identification

|Méthode|Exemple|Avantages|Inconvénients|
|---|---|---|---|
|Device|`/dev/sda1`|Simple|Peut changer|
|UUID|`UUID=xxx-yyy`|Unique, stable|Moins lisible|
|LABEL|`LABEL=MonDisque`|Lisible|Doit être unique|
|Path|`/dev/disk/by-path/...`|Stable|Complexe|

### Obtenir l'UUID d'un système de fichiers

**Méthode 1 : avec blkid (recommandé)**

```bash
# Lister tous les UUID
sudo blkid

# Obtenir l'UUID d'un périphérique spécifique
sudo blkid /dev/sda1

# Sortie filtrée (UUID uniquement)
sudo blkid -s UUID -o value /dev/sda1
```

**Méthode 2 : avec lsblk**

```bash
# Afficher UUID et LABEL
lsblk -f

# Afficher UUID avec colonnes personnalisées
lsblk -o NAME,UUID,FSTYPE,SIZE,MOUNTPOINT
```

**Méthode 3 : via /dev/disk/by-uuid/**

```bash
# Lister les liens symboliques UUID
ls -l /dev/disk/by-uuid/

# Exemple de sortie :
# lrwxrwxrwx 1 root root 10 Dec 26 10:00 1234-5678 -> ../../sda1
```

> [!example] Exemple complet
> 
> ```bash
> # Identifier le périphérique
> $ sudo blkid /dev/sdb1
> /dev/sdb1: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="ext4"
> 
> # Entrée fstab correspondante
> UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890  /data  ext4  defaults  0  2
> ```

### Obtenir et définir un LABEL

**Afficher le label existant**

```bash
# Avec blkid
sudo blkid -s LABEL -o value /dev/sda1

# Avec lsblk
lsblk -o NAME,LABEL /dev/sda1

# Avec e2label (ext2/ext3/ext4)
sudo e2label /dev/sda1
```

**Définir un nouveau label**

```bash
# Pour ext2/ext3/ext4
sudo e2label /dev/sda1 MES_DONNEES

# Pour XFS
sudo xfs_admin -L "MES_DONNEES" /dev/sda1

# Pour FAT32
sudo fatlabel /dev/sda1 MES_DONNEES

# Pour NTFS
sudo ntfslabel /dev/sda1 MES_DONNEES

# Pour Btrfs
sudo btrfs filesystem label /dev/sda1 MES_DONNEES
```

> [!tip] Bonnes pratiques pour les labels
> 
> - Utilisez des noms descriptifs et courts (max 16 caractères pour ext4)
> - Évitez les espaces (utilisez des tirets ou underscores)
> - Assurez-vous que les labels sont uniques sur le système
> - Préférez MAJUSCULES ou snake_case pour la visibilité

**Utiliser un LABEL dans fstab**

```bash
# Syntaxe avec LABEL
LABEL=MES_DONNEES  /data  ext4  defaults  0  2

# Équivalent avec UUID
UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890  /data  ext4  defaults  0  2
```

### Comparaison UUID vs LABEL

> [!info] Quand utiliser UUID ?
> 
> - **Systèmes de production** : Garantie absolue d'unicité
> - **Disques multiples** : Pas de risque de collision de noms
> - **Automatisation** : UUID générés automatiquement à la création
> - **Sécurité** : Impossible de créer accidentellement un doublon

> [!info] Quand utiliser LABEL ?
> 
> - **Lisibilité** : Plus facile à comprendre (`BACKUP` vs `a1b2c3d4-...`)
> - **Documentation** : Le nom décrit l'usage
> - **Petits systèmes** : Quand vous contrôlez tous les périphériques
> - **Médias amovibles** : Identification rapide (clés USB, disques externes)

---

## Options de montage dans fstab

### Options génériques communes

Les options sont séparées par des virgules **sans espaces**.

```bash
UUID=xxx  /data  ext4  defaults,noatime,errors=remount-ro  0  2
                       └─────────────────────────────────┘
                       Options séparées par des virgules
```

#### defaults

```bash
# Option la plus courante - équivalent à :
rw,suid,dev,exec,auto,nouser,async

UUID=xxx  /data  ext4  defaults  0  2
```

> [!info] Que signifie defaults ? C'est un raccourci qui active les options standard : lecture-écriture, SUID autorisé, périphériques reconnus, exécution permise, montage automatique, réservé à root, E/S asynchrones.

#### Options de lecture/écriture

|Option|Description|
|---|---|
|`rw`|Lecture-écriture (défaut)|
|`ro`|Lecture seule|

```bash
# Système de fichiers en lecture seule (archives, ISO montés)
UUID=xxx  /media/iso  iso9660  ro,noauto  0  0
```

#### Options de performance

|Option|Description|Impact|
|---|---|---|
|`noatime`|Ne pas mettre à jour l'heure d'accès|⚡ Améliore les performances|
|`nodiratime`|Ne pas mettre à jour atime pour les répertoires|⚡ Moins d'impact que noatime|
|`relatime`|Mise à jour atime relative (défaut moderne)|⚡ Bon compromis|
|`async`|Écriture asynchrone (défaut)|⚡ Plus rapide mais moins sûr|
|`sync`|Écriture synchrone|🐌 Plus lent mais plus sûr|

```bash
# Optimisation pour SSD
UUID=xxx  /home  ext4  defaults,noatime,discard  1  2

# Clé USB avec écriture synchrone (sécurité)
UUID=xxx  /mnt/usb  vfat  sync,noatime  0  0
```

> [!tip] Recommandation noatime L'option `noatime` est recommandée pour les SSD et les systèmes où les performances sont importantes. Elle évite des écritures inutiles à chaque lecture de fichier.

#### Options de sécurité et exécution

|Option|Description|
|---|---|
|`exec`|Autoriser l'exécution de binaires (défaut)|
|`noexec`|Interdire l'exécution de binaires|
|`suid`|Autoriser les bits SUID/SGID (défaut)|
|`nosuid`|Ignorer les bits SUID/SGID|
|`dev`|Interpréter les fichiers spéciaux (défaut)|
|`nodev`|Ne pas interpréter les fichiers spéciaux|

```bash
# Partition /tmp sécurisée
tmpfs  /tmp  tmpfs  defaults,noexec,nosuid,nodev  0  0

# Partition de données utilisateurs sécurisée
UUID=xxx  /data  ext4  defaults,nosuid,nodev  0  2
```

> [!warning] Sécurité importante Pour les partitions où les utilisateurs peuvent écrire (`/tmp`, `/home`, `/data`), utilisez `nosuid` et `nodev` pour limiter les risques de sécurité. Ajoutez `noexec` pour `/tmp` si aucun script ne doit y être exécuté.

#### Options de montage automatique

|Option|Description|
|---|---|
|`auto`|Montage automatique au boot (défaut)|
|`noauto`|Montage manuel uniquement|
|`user`|Autoriser le montage par un utilisateur normal|
|`nouser`|Seul root peut monter (défaut)|
|`users`|Tout utilisateur peut monter et démonter|

```bash
# Clé USB montable par les utilisateurs
LABEL=USB_BACKUP  /mnt/usb  ext4  noauto,user,nosuid,nodev  0  0

# CD/DVD en lecture seule
/dev/sr0  /media/cdrom  iso9660  ro,noauto,user  0  0
```

> [!example] Cas d'usage noauto Utilisez `noauto` pour les médias amovibles, les partitions de sauvegarde, ou tout système de fichiers qui ne doit pas être monté automatiquement au démarrage.

#### Options de gestion des erreurs

|Option|Description|
|---|---|
|`errors=remount-ro`|Remonter en lecture seule en cas d'erreur|
|`errors=continue`|Continuer normalement|
|`errors=panic`|Kernel panic en cas d'erreur|
|`nofail`|Ne pas échouer au boot si le montage échoue|

```bash
# Système critique
UUID=xxx  /  ext4  defaults,errors=remount-ro  1  1

# Disque externe optionnel
UUID=xxx  /mnt/externe  ext4  defaults,nofail  0  2

# Disque réseau qui peut être indisponible
server:/share  /mnt/nfs  nfs  defaults,nofail,_netdev  0  0
```

> [!warning] Option nofail critique Utilisez TOUJOURS `nofail` pour les systèmes de fichiers réseau ou les disques externes qui peuvent ne pas être disponibles au démarrage. Sans cette option, le système peut bloquer au boot.

### Options spécifiques par type de système de fichiers

#### Options ext4

```bash
# Options courantes pour ext4
UUID=xxx  /data  ext4  defaults,noatime,errors=remount-ro,data=ordered  0  2

# Options avancées
UUID=xxx  /var  ext4  defaults,noatime,commit=60,barrier=1  0  2
```

|Option ext4|Description|
|---|---|
|`data=ordered`|Métadonnées avant données (défaut, recommandé)|
|`data=writeback`|Performances max, moins de cohérence|
|`data=journal`|Toutes les données dans le journal (plus lent, plus sûr)|
|`barrier=1`|Barrières d'écriture activées (sécurité)|
|`commit=X`|Intervalle de commit en secondes (défaut 5)|

#### Options XFS

```bash
# Options courantes pour XFS
UUID=xxx  /data  xfs  defaults,noatime,logbufs=8  0  2
```

|Option XFS|Description|
|---|---|
|`logbufs=8`|Nombre de buffers de log (performance)|
|`logbsize=256k`|Taille des buffers de log|
|`nobarrier`|Désactiver les barrières (danger !)|

#### Options Btrfs

```bash
# Options courantes pour Btrfs
UUID=xxx  /data  btrfs  defaults,noatime,compress=zstd,space_cache=v2  0  2
```

|Option Btrfs|Description|
|---|---|
|`compress=zstd`|Compression transparente (zstd, lzo, zlib)|
|`compress-force=zstd`|Forcer la compression de tous les fichiers|
|`space_cache=v2`|Cache d'espace libre v2 (performance)|
|`autodefrag`|Défragmentation automatique|
|`ssd`|Optimisations pour SSD|

#### Options VFAT/FAT32 (Windows)

```bash
# Partition Windows avec support UTF-8
UUID=xxx  /mnt/windows  vfat  defaults,utf8,dmask=027,fmask=137,uid=1000,gid=1000  0  0
```

|Option VFAT|Description|
|---|---|
|`utf8`|Support des caractères UTF-8|
|`uid=1000`|Propriétaire des fichiers|
|`gid=1000`|Groupe des fichiers|
|`umask=000`|Permissions globales|
|`dmask=027`|Permissions des répertoires|
|`fmask=137`|Permissions des fichiers|

> [!info] Calcul des masques
> 
> - `dmask=027` → répertoires : 750 (rwxr-x---)
> - `fmask=137` → fichiers : 640 (rw-r-----)

#### Options NTFS (Windows)

```bash
# Partition NTFS avec support complet (ntfs-3g)
UUID=xxx  /mnt/windows  ntfs-3g  defaults,uid=1000,gid=1000,dmask=027,fmask=137,windows_names  0  0
```

|Option NTFS|Description|
|---|---|
|`windows_names`|Respecter les conventions de nommage Windows|
|`big_writes`|Améliorer les performances d'écriture|
|`streams_interface=windows`|Support des flux NTFS alternatifs|

#### Options NFS (réseau)

```bash
# Montage NFS avec options de robustesse
server:/export  /mnt/nfs  nfs  defaults,_netdev,nofail,soft,timeo=30,retrans=3  0  0
```

|Option NFS|Description|
|---|---|
|`_netdev`|Attendre que le réseau soit disponible|
|`soft`|Abandonner après timeout (vs `hard`)|
|`hard`|Réessayer indéfiniment (défaut)|
|`timeo=30`|Timeout en dixièmes de seconde|
|`retrans=3`|Nombre de retransmissions|
|`rsize=8192`|Taille de lecture|
|`wsize=8192`|Taille d'écriture|
|`intr`|Interruptible par signal|

> [!tip] NFS et _netdev Utilisez TOUJOURS `_netdev` pour les montages réseau (NFS, CIFS/SMB). Cela garantit que le système attend que le réseau soit disponible avant de tenter le montage.

#### Options CIFS/SMB (partages Windows)

```bash
# Montage CIFS avec authentification
//server/share  /mnt/smb  cifs  credentials=/root/.smbcredentials,uid=1000,gid=1000,iocharset=utf8  0  0
```

|Option CIFS|Description|
|---|---|
|`credentials=/path`|Fichier contenant user/password|
|`username=xxx`|Nom d'utilisateur (alternative)|
|`password=xxx`|Mot de passe (non recommandé dans fstab)|
|`domain=xxx`|Domaine Windows|
|`iocharset=utf8`|Encodage des caractères|
|`vers=3.0`|Version du protocole SMB|

**Fichier de credentials** (`/root/.smbcredentials`) :

```bash
username=monuser
password=monpass
domain=MONDOMAINE
```

```bash
# Sécuriser le fichier
sudo chmod 600 /root/.smbcredentials
```

### Exemples de configurations complètes

#### Configuration système typique

```bash
# Système racine
UUID=xxx  /  ext4  defaults,errors=remount-ro  1  1

# Swap
UUID=yyy  none  swap  sw  0  0

# Home avec optimisations
UUID=zzz  /home  ext4  defaults,noatime,nosuid,nodev  1  2

# Tmp en RAM
tmpfs  /tmp  tmpfs  defaults,noexec,nosuid,nodev,size=4G,mode=1777  0  0
```

#### Configuration serveur avec NFS et données

```bash
# Système racine
UUID=root-uuid  /  ext4  defaults,errors=remount-ro  1  1

# Partition de données volumineuses (XFS)
UUID=data-uuid  /data  xfs  defaults,noatime,logbufs=8  0  2

# Export NFS monté depuis un autre serveur
nfs-server:/export  /mnt/shared  nfs  defaults,_netdev,nofail,hard,intr  0  0

# Backup monté manuellement
UUID=backup-uuid  /mnt/backup  ext4  noauto,nosuid,nodev  0  0
```

#### Configuration poste de travail

```bash
# Système
UUID=sys-uuid  /  ext4  defaults,errors=remount-ro  1  1
UUID=home-uuid  /home  ext4  defaults,noatime  1  2

# Partition Windows en dual-boot
UUID=win-uuid  /mnt/windows  ntfs-3g  defaults,uid=1000,gid=1000,windows_names  0  0

# Clé USB pour backups (montage manuel)
LABEL=BACKUP  /media/backup  ext4  noauto,user,nosuid,nodev,noexec  0  0

# Partition de jeux (SSD)
UUID=games-uuid  /games  ext4  defaults,noatime,discard  0  2
```

> [!tip] Ordre des options L'ordre des options n'a généralement pas d'importance, mais par convention on met `defaults` en premier puis les options spécifiques.

---

## Commande mount -a pour tester fstab

### Utilité de mount -a

La commande `mount -a` (mount all) permet de monter tous les systèmes de fichiers définis dans `/etc/fstab` qui ont l'option `auto` (ou pas d'option `noauto`). C'est l'outil indispensable pour **tester** vos modifications de fstab **avant de redémarrer**.

> [!warning] Tester avant de redémarrer ! Une erreur dans `/etc/fstab` peut empêcher le système de démarrer correctement. Utilisez TOUJOURS `mount -a` pour tester vos modifications avant de redémarrer.

### Syntaxe et options

```bash
# Monter tous les systèmes de fichiers définis dans fstab
sudo mount -a

# Mode verbeux pour voir les détails
sudo mount -av

# Tester sans réellement monter (simulation)
sudo mount -a --fake

# Monter seulement un type spécifique
sudo mount -a -t ext4

# Monter tout sauf un type
sudo mount -a -t noext4,noxfs
```

### Workflow de test recommandé

**Étape 1 : Sauvegarder fstab**

```bash
# Toujours faire une sauvegarde avant modification
sudo cp /etc/fstab /etc/fstab.backup

# Ou avec la date
sudo cp /etc/fstab /etc/fstab.$(date +%Y%m%d)
```

**Étape 2 : Éditer fstab**

```bash
# Éditer avec votre éditeur préféré
sudo nano /etc/fstab
# ou
sudo vim /etc/fstab
```

**Étape 3 : Vérifier la syntaxe**

```bash
# Vérifier qu'il n'y a pas d'erreur évidente
cat /etc/fstab | grep -v "^#" | grep -v "^$"
```

**Étape 4 : Tester avec mount -a**

```bash
# Démonter d'abord si le point de montage existe déjà
sudo umount /nouveau/point/montage 2>/dev/null

# Tester le montage
sudo mount -av

# Vérifier que tout est monté correctement
mount | grep "/nouveau/point/montage"
df -h /nouveau/point/montage
```

**Étape 5 : Vérifier les erreurs**

```bash
# Consulter les logs si problème
sudo journalctl -xe | tail -50

# Ou les logs système
sudo tail -f /var/log/syslog
```

> [!example] Exemple complet de test
> 
> ```bash
> # 1. Sauvegarde
> $ sudo cp /etc/fstab /etc/fstab.backup
> 
> # 2. Ajout d'une ligne dans fstab
> $ echo "UUID=xxx /data ext4 defaults,noatime 0 2" | sudo tee -a /etc/fstab
> 
> # 3. Créer le point de montage
> $ sudo mkdir -p /data
> 
> # 4. Tester
> $ sudo mount -av
> /                        : ignored
> none                     : ignored
> /home                    : already mounted
> /data                    : successfully mounted
> 
> # 5. Vérifier
> $ df -h /data
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/sdb1       100G  1.5G   94G   2% /data
> 
> # 6. Si OK, le système peut être redémarré en toute sécurité
> ```

### Gestion des erreurs courantes

#### Erreur : périphérique introuvable

```bash
# Erreur
mount: /data: can't find UUID=xxx

# Diagnostic
sudo blkid | grep xxx
# Si vide, l'UUID est incorrect

# Solution
# Vérifier le bon UUID
sudo blkid /dev/sdX1
# Corriger dans fstab
```

#### Erreur : point de montage inexistant

```bash
# Erreur
mount: /data: mount point does not exist

# Solution
sudo mkdir -p /data
sudo mount -a
```

#### Erreur : déjà monté

```bash
# Erreur
mount: /data: /dev/sdb1 already mounted on /data

# Solution
# C'est normal si le système de fichiers est déjà monté
# Pour remonter avec les nouvelles options :
sudo umount /data
sudo mount /data
```

#### Erreur : type de système de fichiers incorrect

```bash
# Erreur
mount: /data: wrong fs type, bad option, bad superblock

# Diagnostic
sudo blkid /dev/sdb1  # Vérifier le type réel
sudo file -s /dev/sdb1

# Solution
# Corriger le type dans fstab (3ème colonne)
```

#### Erreur : options invalides

```bash
# Erreur
mount: /data: invalid option

# Solution
# Vérifier la syntaxe des options
# - Pas d'espaces entre les options
# - Virgules uniquement entre les options
# - Options valides pour le type de FS
```

### Tester une seule entrée fstab

```bash
# Monter seulement un point de montage spécifique
sudo mount /data

# Cette commande utilise les paramètres définis dans fstab
# Équivalent à spécifier tous les paramètres manuellement
```

> [!tip] Astuce pour tests isolés Au lieu de `mount -a` qui monte tout, vous pouvez tester une seule ligne avec `mount /point-de-montage`. Cela lit la configuration depuis fstab mais ne monte que ce système de fichiers spécifique.

### Vérifications après montage

**Vérifier les montages actifs**

```bash
# Voir tous les montages
mount

# Filtrer un point de montage spécifique
mount | grep /data

# Avec findmnt (plus lisible)
findmnt /data

# Vue arborescente
findmnt -t ext4,xfs
```

**Vérifier l'espace disque**

```bash
# Espace utilisé/disponible
df -h /data

# Détail des inodes
df -i /data
```

**Vérifier les permissions**

```bash
# Permissions du point de montage
ls -ld /data

# Tester l'écriture
sudo touch /data/test_write
ls -l /data/test_write
sudo rm /data/test_write
```

**Vérifier les options de montage effectives**

```bash
# Voir exactement quelles options sont actives
mount | grep /data

# Ou avec findmnt
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS /data
```

> [!example] Exemple de vérification complète
> 
> ```bash
> $ findmnt /data
> TARGET SOURCE    FSTYPE OPTIONS
> /data  /dev/sdb1 ext4   rw,noatime,errors=remount-ro
> 
> $ df -h /data
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/sdb1       100G  1.5G   94G   2% /data
> 
> $ ls -ld /data
> drwxr-xr-x 3 root root 4096 Dec 26 10:00 /data
> 
> $ sudo touch /data/test && echo "Écriture OK" && sudo rm /data/test
> Écriture OK
> ```

### Restaurer en cas de problème

**Si le système ne démarre plus après modification de fstab**

```bash
# 1. Démarrer en mode rescue/recovery depuis GRUB
# 2. Monter le système racine en mode écriture
mount -o remount,rw /

# 3. Restaurer la sauvegarde
cp /etc/fstab.backup /etc/fstab

# 4. Ou commenter la ligne problématique
sed -i 's/^UUID=problematique/#UUID=problematique/' /etc/fstab

# 5. Redémarrer
reboot
```

> [!warning] Accès mode rescue Si vous ne pouvez pas démarrer, vous devrez utiliser un Live CD/USB ou le mode recovery de votre distribution pour accéder au système de fichiers et corriger `/etc/fstab`.

### Automatiser les tests avec un script

```bash
#!/bin/bash
# test-fstab.sh - Script de test de configuration fstab

echo "=== Test de la configuration fstab ==="

# Sauvegarde
if [ ! -f /etc/fstab.backup ]; then
    echo "Création de la sauvegarde..."
    sudo cp /etc/fstab /etc/fstab.backup
fi

# Validation syntaxique basique
echo "Vérification syntaxique..."
if ! grep -v "^#" /etc/fstab | grep -v "^$" | awk '{if (NF < 6) print "Erreur ligne: "$0}' | grep -q "Erreur"; then
    echo "✓ Syntaxe OK"
else
    echo "✗ Erreur de syntaxe détectée"
    exit 1
fi

# Test de montage
echo "Test de montage..."
if sudo mount -a --fake; then
    echo "✓ Test à blanc OK"
    
    # Montage réel
    if sudo mount -av; then
        echo "✓ Montage réussi"
        
        # Vérification
        echo "Points de montage actifs:"
        findmnt --df
    else
        echo "✗ Échec du montage"
        exit 1
    fi
else
    echo "✗ Test à blanc échoué"
    exit 1
fi

echo "=== Test terminé avec succès ==="
```

**Utilisation du script**

```bash
# Rendre le script exécutable
chmod +x test-fstab.sh

# Exécuter
sudo ./test-fstab.sh
```

> [!tip] Bonnes pratiques de test
> 
> - Toujours sauvegarder fstab avant modification
> - Utiliser `mount -a` pour tester avant redémarrage
> - Vérifier les logs en cas d'erreur
> - Tester l'écriture sur les nouveaux points de montage
> - Garder un Live USB de secours à portée de main

### Commandes utiles pour le diagnostic

```bash
# Voir tous les systèmes de fichiers détectés
lsblk -f

# Voir les UUID de tous les périphériques
sudo blkid

# Voir l'arbre des montages
findmnt

# Voir les options de montage d'un point spécifique
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS /data

# Vérifier si un périphérique est monté
mountpoint /data

# Voir l'historique des montages
journalctl -u systemd-fsck@* | tail -50

# Tester la syntaxe sans monter
mount -a --fake -v
```

### Scénarios de récupération d'urgence

#### Scénario 1 : Système refuse de démarrer

```bash
# Au démarrage GRUB, appuyer sur 'e' pour éditer
# Ajouter à la ligne linux: systemd.unit=rescue.target
# Appuyer sur Ctrl+X pour démarrer

# Une fois en mode rescue
mount -o remount,rw /
nano /etc/fstab
# Commenter la ligne problématique avec #
reboot
```

#### Scénario 2 : Montage réseau bloque le boot

```bash
# Ajouter l'option nofail à tous les montages réseau
server:/share  /mnt/nfs  nfs  defaults,nofail,_netdev  0  0

# Ou désactiver temporairement
sudo systemctl mask mnt-nfs.mount
```

#### Scénario 3 : Permissions incorrectes après montage

```bash
# Vérifier les options uid/gid dans fstab
UUID=xxx  /data  ext4  defaults,uid=1000,gid=1000  0  2

# Pour NTFS/FAT, définir umask
UUID=xxx  /mnt/win  ntfs-3g  defaults,uid=1000,gid=1000,umask=022  0  0
```

### Intégration avec systemd

Systemd génère automatiquement des unités de montage à partir de `/etc/fstab`. Vous pouvez les voir et les gérer :

```bash
# Lister les unités de montage générées
systemctl list-units --type=mount

# Voir le statut d'un montage spécifique
systemctl status data.mount

# Recharger après modification de fstab
sudo systemctl daemon-reload

# Démarrer manuellement un montage
sudo systemctl start data.mount

# Arrêter un montage
sudo systemctl stop data.mount
```

**Correspondance fstab → systemd**

```bash
# Entrée fstab
/data  →  data.mount

# Sous-répertoires
/mnt/backup  →  mnt-backup.mount
/var/lib/docker  →  var-lib-docker.mount
```

> [!info] Systemd et fstab Systemd convertit automatiquement chaque entrée de `/etc/fstab` en une unité `.mount`. Les tirets dans le nom de l'unité représentent les slashs du chemin de montage.

### Cas d'usage avancés

#### Montage conditionnel avec x-systemd

```bash
# Monter seulement si un autre montage existe déjà
UUID=xxx  /data/backup  ext4  defaults,nofail,x-systemd.requires=data.mount  0  2

# Monter après le réseau
UUID=xxx  /data  ext4  defaults,x-systemd.after=network-online.target  0  2

# Timeout personnalisé
UUID=xxx  /data  ext4  defaults,x-systemd.mount-timeout=30  0  2
```

#### Montage avec chiffrement LUKS

```bash
# 1. Définir le périphérique chiffré dans /etc/crypttab
backup  /dev/sdb1  none  luks,timeout=180

# 2. Monter le volume déchiffré dans fstab
/dev/mapper/backup  /mnt/backup  ext4  defaults,nofail  0  2
```

#### Montage de sous-volumes Btrfs

```bash
# Monter un sous-volume spécifique
UUID=xxx  /home  btrfs  defaults,subvol=@home,compress=zstd  0  2
UUID=xxx  /snapshots  btrfs  defaults,subvol=@snapshots,ro  0  0
```

### Checklist finale avant redémarrage

> [!tip] Checklist de vérification
> 
> - [ ] Sauvegarde de fstab créée (`/etc/fstab.backup`)
> - [ ] UUID/LABEL vérifiés avec `blkid`
> - [ ] Points de montage créés (`mkdir -p`)
> - [ ] Test avec `mount -a` réussi
> - [ ] Vérification avec `df -h` et `findmnt`
> - [ ] Test d'écriture effectué
> - [ ] Option `nofail` ajoutée pour montages optionnels
> - [ ] Option `_netdev` ajoutée pour montages réseau
> - [ ] Logs consultés (`journalctl -xe`)
> - [ ] Documentation des changements effectuée

### Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> **1. Espaces dans les options**
> 
> ```bash
> # ✗ INCORRECT
> UUID=xxx  /data  ext4  defaults, noatime  0  2
>                                  └─ espace ici !
> 
> # ✓ CORRECT
> UUID=xxx  /data  ext4  defaults,noatime  0  2
> ```
> 
> **2. Oublier nofail pour montages optionnels**
> 
> ```bash
> # ✗ Bloquera le boot si le disque est absent
> UUID=xxx  /mnt/externe  ext4  defaults  0  2
> 
> # ✓ Continuera le boot même si absent
> UUID=xxx  /mnt/externe  ext4  defaults,nofail  0  2
> ```
> 
> **3. Mauvais ordre des champs**
> 
> ```bash
> # ✗ INCORRECT - options et type inversés
> UUID=xxx  /data  defaults  ext4  0  2
> 
> # ✓ CORRECT
> UUID=xxx  /data  ext4  defaults  0  2
> ```
> 
> **4. Oublier _netdev pour montages réseau**
> 
> ```bash
> # ✗ Tentera de monter avant le réseau
> server:/share  /mnt/nfs  nfs  defaults  0  0
> 
> # ✓ Attendra le réseau
> server:/share  /mnt/nfs  nfs  defaults,_netdev,nofail  0  0
> ```
> 
> **5. Chemin de point de montage inexistant**
> 
> ```bash
> # Toujours créer le répertoire AVANT mount -a
> sudo mkdir -p /nouveau/point/montage
> ```

### Résumé des commandes essentielles

|Commande|Description|
|---|---|
|`sudo blkid`|Lister les UUID de tous les périphériques|
|`lsblk -f`|Afficher systèmes de fichiers et UUID|
|`sudo mount -a`|Monter tous les FS définis dans fstab|
|`sudo mount -av`|Montage verbeux pour voir les détails|
|`sudo mount /point`|Monter un seul point défini dans fstab|
|`findmnt`|Afficher l'arbre des montages|
|`df -h`|Afficher l'espace disque utilisé|
|`sudo e2label /dev/sdX1`|Voir/définir label pour ext4|
|`sudo cp /etc/fstab /etc/fstab.backup`|Sauvegarder fstab|
|`sudo systemctl daemon-reload`|Recharger config systemd après modif fstab|

---

## 🎯 Points clés à retenir

> [!info] À retenir absolument
> 
> 1. **fstab = configuration permanente** : Définit les montages automatiques au démarrage
>     
> 2. **6 champs obligatoires** : périphérique, point, type, options, dump, pass
>     
> 3. **UUID > LABEL > device** : Préférer UUID pour la stabilité
>     
> 4. **Toujours tester avant reboot** : `mount -a` est votre meilleur ami
>     
> 5. **Options critiques** :
>     
>     - `nofail` pour disques optionnels
>     - `_netdev` pour montages réseau
>     - `noauto` pour montages manuels
>     - `nosuid,nodev,noexec` pour sécurité
> 6. **Sauvegardez toujours** : `cp /etc/fstab /etc/fstab.backup`
>     
> 7. **Syntaxe stricte** : Pas d'espaces dans les options (virgules uniquement)
>     

---

_Cours d'Administration Linux - Stockage et Montage automatique avec fstab_