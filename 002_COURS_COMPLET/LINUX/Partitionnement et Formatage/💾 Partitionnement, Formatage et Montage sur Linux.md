
> [!info] À propos de ce cours Ce cours complet couvre la gestion des disques sous Linux : du partitionnement au montage en passant par le formatage. Ces compétences sont essentielles pour tout administrateur système.

---

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

## 🎯 Introduction et concepts fondamentaux

### Qu'est-ce qu'un disque, une partition et un système de fichiers ?

> [!info] Hiérarchie de stockage **Disque physique** → **Partitions** → **Système de fichiers** → **Montage** → **Utilisation**

**Disque physique** : Le matériel de stockage (HDD, SSD, clé USB)

- Identifié par `/dev/sda`, `/dev/sdb`, `/dev/nvme0n1`, etc.

**Partition** : Division logique d'un disque

- Permet de séparer les données, installer plusieurs OS, ou optimiser les performances
- Identifiée par `/dev/sda1`, `/dev/sda2`, `/dev/nvme0n1p1`, etc.

**Système de fichiers** : Structure qui organise les données sur une partition

- ext4, xfs, btrfs, ntfs, fat32, etc.
- Doit être créé (formaté) sur une partition avant utilisation

**Point de montage** : Emplacement dans l'arborescence où la partition est accessible

- `/`, `/home`, `/mnt/data`, etc.

### Tables de partition : MBR vs GPT

|Caractéristique|MBR (Master Boot Record)|GPT (GUID Partition Table)|
|---|---|---|
|**Année de création**|1983|2000|
|**Nombre max de partitions**|4 primaires (+ étendues)|128 par défaut|
|**Taille max de disque**|2 To|9.4 Zo (zettaoctets)|
|**Compatibilité UEFI**|Non (sauf CSM)|Oui|
|**Résilience**|Faible (un seul emplacement)|Élevée (redondance)|
|**Usage recommandé**|Anciens systèmes, BIOS|Systèmes modernes, UEFI|

> [!tip] Recommandation Utilisez **GPT** pour tous les nouveaux systèmes. MBR n'est nécessaire que pour la compatibilité avec de vieux matériels.

### Types de partitions (MBR)

- **Partition primaire** : Partition de base, bootable, maximum 4
- **Partition étendue** : Conteneur pour les partitions logiques (1 seule possible)
- **Partition logique** : Partition dans la partition étendue (nombre illimité)

> [!warning] Limitation MBR Avec MBR, si vous avez besoin de plus de 4 partitions, vous devez créer 3 primaires + 1 étendue contenant des logiques.

---

## 🔍 Visualisation des disques et partitions

### lsblk - Liste des périphériques bloc

**Utilité** : Affiche l'arborescence des disques et partitions de manière claire et lisible.

#### Syntaxe de base

```bash
lsblk [OPTIONS] [PÉRIPHÉRIQUE]
```

#### Options principales

```bash
# Affichage simple (par défaut)
lsblk

# Affichage avec systèmes de fichiers et UUIDs
lsblk -f

# Affichage avec informations de montage
lsblk -m

# Format personnalisé
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT

# Afficher tout (y compris les périphériques vides)
lsblk -a

# Mode liste (pas d'arborescence)
lsblk -l

# Afficher la taille en octets
lsblk -b
```

> [!example] Exemple de sortie
> 
> ```bash
> $ lsblk
> NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
> sda      8:0    0 465,8G  0 disk 
> ├─sda1   8:1    0   512M  0 part /boot/efi
> ├─sda2   8:2    0    50G  0 part /
> └─sda3   8:3    0 415,3G  0 part /home
> sdb      8:16   0   1,8T  0 disk 
> └─sdb1   8:17   0   1,8T  0 part /mnt/data
> ```

#### Colonnes importantes

|Colonne|Signification|
|---|---|
|**NAME**|Nom du périphérique|
|**SIZE**|Taille totale|
|**TYPE**|Type (disk, part, lvm, rom)|
|**FSTYPE**|Type de système de fichiers|
|**MOUNTPOINT**|Point de montage actuel|
|**UUID**|Identifiant unique (avec -f)|
|**LABEL**|Étiquette de la partition (avec -f)|

> [!tip] Astuce pro `lsblk -f` est votre meilleur ami pour avoir une vue d'ensemble rapide avec les UUID nécessaires pour /etc/fstab.

---

### fdisk -l - Lister les partitions

**Utilité** : Affiche des informations détaillées sur les partitions, incluant les secteurs, types, et drapeaux.

#### Syntaxe

```bash
# Lister tous les disques (nécessite root)
sudo fdisk -l

# Lister un disque spécifique
sudo fdisk -l /dev/sda

# Format plus lisible
sudo fdisk -l | less
```

> [!example] Exemple de sortie
> 
> ```bash
> $ sudo fdisk -l /dev/sda
> Disk /dev/sda: 465,76 GiB, 500107862016 bytes, 976773168 sectors
> Disklabel type: gpt
> Disk identifier: 5F7E8A9B-1234-5678-90AB-CDEF12345678
> 
> Device       Start       End   Sectors  Size Type
> /dev/sda1     2048   1050623   1048576  512M EFI System
> /dev/sda2  1050624 105908223 104857600   50G Linux filesystem
> /dev/sda3 105908224 976773134 870864911  415G Linux filesystem
> ```

#### Informations fournies

- **Type de table de partition** (GPT/MBR)
- **Identifiant du disque** (UUID du disque)
- **Secteurs de début et fin** de chaque partition
- **Type de partition** (EFI, Linux filesystem, swap, etc.)
- **Drapeaux** (boot, esp, etc.)

> [!warning] Attention `fdisk -l` nécessite les privilèges root. Sans sudo, vous ne verrez que des informations limitées.

---

### blkid - Identifier les systèmes de fichiers

**Utilité** : Affiche les UUID, types de systèmes de fichiers, et labels des partitions. Crucial pour la configuration de `/etc/fstab`.

#### Syntaxe

```bash
# Afficher tous les périphériques
sudo blkid

# Afficher un périphérique spécifique
sudo blkid /dev/sda1

# Rechercher par UUID
sudo blkid -U 1234-5678-90AB-CDEF

# Rechercher par label
sudo blkid -L "MaPartition"

# Afficher seulement l'UUID
sudo blkid -s UUID -o value /dev/sda1
```

> [!example] Exemple de sortie
> 
> ```bash
> $ sudo blkid
> /dev/sda1: UUID="1234-5678" TYPE="vfat" PARTLABEL="EFI System Partition" PARTUUID="abcd-ef01"
> /dev/sda2: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="ext4" PARTUUID="1234-5678"
> /dev/sda3: UUID="f9e8d7c6-b5a4-3210-fedc-ba9876543210" TYPE="ext4" PARTUUID="9876-5432"
> ```

#### Informations clés

- **UUID** : Identifiant unique universel (recommandé pour fstab)
- **TYPE** : Type de système de fichiers (ext4, xfs, vfat, ntfs, etc.)
- **LABEL** : Étiquette lisible de la partition
- **PARTUUID** : UUID de la partition elle-même (différent de l'UUID du fs)

> [!tip] UUID vs PARTUUID
> 
> - **UUID** : Identifie le système de fichiers (change après reformatage)
> - **PARTUUID** : Identifie la partition (ne change pas, sauf repartitionnement)
> 
> Utilisez UUID pour fstab car c'est plus portable et standard.

---

### df - Espace disque utilisé

**Utilité** : Affiche l'espace disque utilisé et disponible pour les systèmes de fichiers montés.

#### Syntaxe

```bash
# Affichage standard
df

# Format lisible par l'humain
df -h

# Afficher le type de système de fichiers
df -T

# Afficher les inodes
df -i

# Cibler un système de fichiers spécifique
df -h /home

# Exclure certains types (ex: tmpfs)
df -h -x tmpfs -x devtmpfs
```

> [!example] Exemple de sortie
> 
> ```bash
> $ df -hT
> Filesystem     Type      Size  Used Avail Use% Mounted on
> /dev/sda2      ext4       50G   15G   33G  32% /
> /dev/sda1      vfat      512M   35M  477M   7% /boot/efi
> /dev/sda3      ext4      410G  120G  270G  31% /home
> /dev/sdb1      ext4      1,8T  850G  900G  49% /mnt/data
> ```

#### Colonnes principales

|Colonne|Signification|
|---|---|
|**Filesystem**|Périphérique ou pseudo-fs|
|**Type**|Type de système de fichiers|
|**Size**|Taille totale|
|**Used**|Espace utilisé|
|**Avail**|Espace disponible|
|**Use%**|Pourcentage utilisé|
|**Mounted on**|Point de montage|

> [!warning] Espace réservé Sur ext4, 5% de l'espace est réservé au root par défaut. C'est pourquoi "Used + Avail ≠ Size".

---

## 🔧 Partitionnement des disques

### fdisk - Partitionnement en ligne de commande

**Utilité** : Outil interactif en ligne de commande pour créer, supprimer, et modifier des partitions. Support MBR et GPT.

> [!warning] Danger fdisk modifie la table de partitions. Les changements sont écrits uniquement quand vous tapez `w`. Aucune donnée n'est supprimée avant ce moment, mais une fois `w` exécuté, les modifications sont irréversibles.

#### Lancement de fdisk

```bash
# Ouvrir fdisk sur un disque
sudo fdisk /dev/sdb

# Lister les partitions avant de modifier
sudo fdisk -l /dev/sdb
```

#### Commandes interactives de fdisk

Une fois dans fdisk, vous êtes en mode interactif. Voici les commandes principales :

|Commande|Action|
|---|---|
|**m**|Afficher l'aide|
|**p**|Afficher la table de partitions|
|**n**|Créer une nouvelle partition|
|**d**|Supprimer une partition|
|**t**|Changer le type de partition|
|**l**|Lister les types de partitions|
|**w**|Écrire les changements et quitter|
|**q**|Quitter sans sauvegarder|
|**g**|Créer une table GPT (nouveau disque)|
|**o**|Créer une table MBR (nouveau disque)|
|**v**|Vérifier la table de partitions|

#### Workflow complet : créer une partition

```bash
# 1. Lancer fdisk
sudo fdisk /dev/sdb

# 2. Dans fdisk, taper les commandes suivantes :

# Afficher les partitions existantes
p

# Créer une nouvelle partition
n
# Choisir le type (p pour primaire, e pour étendue, ou accepter défaut)
p
# Numéro de partition (1-4, ou accepter défaut)
1
# Premier secteur (accepter défaut pour commencer après la dernière partition)
[Entrée]
# Dernier secteur (ou taille : +10G pour 10 Go)
+50G

# Afficher pour vérifier
p

# Changer le type si nécessaire (ex: swap = 82 en MBR, 19 en GPT)
t
# Numéro de partition
1
# Type (taper L pour voir la liste)
83  # Linux filesystem (MBR) ou 20 (GPT)

# Écrire les changements (ATTENTION : point de non-retour)
w
```

> [!example] Tailles courantes
> 
> ```bash
> +512M    # 512 mégaoctets
> +10G     # 10 gigaoctets
> +1T      # 1 téraoctet
> [Entrée] # Utiliser tout l'espace restant
> ```

#### Types de partitions courants

**Pour MBR :**

- `83` : Linux filesystem
- `82` : Linux swap
- `7` : NTFS/exFAT
- `b` : W95 FAT32
- `ef` : EFI (nécessite GPT en réalité)

**Pour GPT :**

- `20` : Linux filesystem
- `19` : Linux swap
- `1` : EFI System
- `11` : Microsoft basic data

> [!tip] Vérifier les changements Après avoir écrit avec `w`, utilisez `lsblk` ou `fdisk -l` pour confirmer que la partition est créée.

#### Après la création : informer le kernel

```bash
# Forcer le kernel à relire la table de partitions
sudo partprobe /dev/sdb

# Ou redémarrer si partprobe ne fonctionne pas
sudo reboot
```

> [!warning] Partition en cours d'utilisation Si le disque contient des partitions montées, vous devrez les démonter avant de pouvoir modifier la table de partitions.

---

### cfdisk - Partitionnement interactif

**Utilité** : Interface semi-graphique en ncurses, plus intuitive que fdisk. Idéal pour les débutants.

#### Lancement

```bash
# Ouvrir cfdisk sur un disque
sudo cfdisk /dev/sdb

# Spécifier le type de table (si nouveau disque)
sudo cfdisk -z /dev/sdb  # Lance l'assistant de création
```

#### Navigation dans cfdisk

```
┌──────────────────────────────────────────────────┐
│                  Disk: /dev/sdb                  │
│            Size: 1.8 TiB, 2000398934016 bytes    │
│                 Label: gpt, identifier: ...      │
│                                                  │
│    Device        Start         End     Sectors   │
│ >> Free space      2048  3907029134  3907027087  │
│                                                  │
│ [  New  ] [ Quit ] [ Help ] [ Write ] [  Dump  ] │
└──────────────────────────────────────────────────┘
```

**Navigation :**

- **Flèches haut/bas** : Sélectionner partition ou espace libre
- **Flèches gauche/droite** : Sélectionner les actions en bas
- **Entrée** : Exécuter l'action sélectionnée

#### Créer une partition avec cfdisk

1. **Sélectionner "Free space"** avec les flèches
2. **Sélectionner [ New ]** en bas
3. **Entrer la taille** : 50G, 1T, ou Entrée pour tout l'espace
4. **Choisir le type** : Linux filesystem, swap, EFI, etc.
5. **Sélectionner [ Write ]** pour enregistrer
6. **Taper "yes"** pour confirmer
7. **Sélectionner [ Quit ]** pour quitter

> [!tip] Avantages de cfdisk
> 
> - Interface visuelle claire
> - Moins de risques d'erreurs
> - Affichage en temps réel de l'espace
> - Idéal pour apprendre

#### Types de partitions dans cfdisk

Lorsque vous créez une partition, cfdisk propose :

- **Linux filesystem** (type par défaut)
- **Linux swap**
- **EFI System**
- **Microsoft basic data**
- Et bien d'autres...

> [!example] Workflow rapide
> 
> ```bash
> sudo cfdisk /dev/sdb
> # → Sélectionner Free space
> # → [New] → Taille: 100G → Entrée
> # → [Type] → Linux filesystem
> # → [Write] → yes
> # → [Quit]
> ```

---

### parted - Outil avancé de partitionnement

**Utilité** : Outil puissant en ligne de commande et mode interactif. Support avancé de GPT, redimensionnement, alignement optimal.

> [!info] Différence fdisk vs parted
> 
> - **fdisk** : Modifications en mémoire, écriture finale avec `w`
> - **parted** : Chaque commande est appliquée immédiatement (DANGEREUX)

#### Syntaxe

```bash
# Mode interactif
sudo parted /dev/sdb

# Mode direct (une commande)
sudo parted /dev/sdb print

# Créer une table GPT
sudo parted /dev/sdb mklabel gpt

# Créer une table MBR
sudo parted /dev/sdb mklabel msdos
```

#### Commandes interactives de parted

|Commande|Action|
|---|---|
|**print**|Afficher la table de partitions|
|**mklabel gpt/msdos**|Créer une table GPT ou MBR|
|**mkpart**|Créer une partition|
|**rm NUMBER**|Supprimer une partition|
|**resizepart NUMBER END**|Redimensionner une partition|
|**name NUMBER NAME**|Nommer une partition (GPT)|
|**set NUMBER FLAG STATE**|Activer/désactiver un drapeau|
|**align-check TYPE NUMBER**|Vérifier l'alignement|
|**quit**|Quitter|

#### Créer une partition avec parted

```bash
# Lancer parted
sudo parted /dev/sdb

# Créer une table GPT (si nouveau disque)
(parted) mklabel gpt

# Créer une partition
(parted) mkpart primary ext4 0% 50GB

# Explication :
# - primary : type (ou logical, extended pour MBR)
# - ext4 : système de fichiers (indicatif, pas vraiment formaté)
# - 0% : début (0% = début du disque)
# - 50GB : fin (ou 100% pour tout utiliser)

# Afficher le résultat
(parted) print

# Quitter
(parted) quit
```

#### Syntaxe mkpart détaillée

```bash
mkpart [PART-TYPE] [FS-TYPE] START END

# PART-TYPE (MBR uniquement) : primary, logical, extended
# FS-TYPE : ext4, xfs, fat32, linux-swap (informatif seulement)
# START : 0%, 1MiB, 2048s (secteurs)
# END : 50GB, 100%, 1000MiB
```

> [!example] Exemples de partitions
> 
> ```bash
> # Partition EFI (512 Mo)
> mkpart ESP fat32 1MiB 513MiB
> set 1 esp on
> 
> # Partition root (50 Go)
> mkpart primary ext4 513MiB 50.5GiB
> 
> # Partition home (reste du disque)
> mkpart primary ext4 50.5GiB 100%
> ```

#### Redimensionner une partition

```bash
# ATTENTION : Sauvegarder vos données avant !
sudo parted /dev/sdb

# Redimensionner la partition 1 jusqu'à 100 Go
(parted) resizepart 1 100GB

# IMPORTANT : Redimensionner aussi le système de fichiers après
# (nous verrons cela dans la section formatage)
```

> [!warning] Danger parted Avec parted, **chaque commande est immédiate**. Il n'y a pas de "w" pour valider. Soyez certain de vos commandes avant de les exécuter.

#### Aligner les partitions (performances)

```bash
# Vérifier l'alignement
(parted) align-check optimal 1

# Créer avec alignement optimal (recommandé)
mkpart primary ext4 1MiB 100GiB  # Commence à 1MiB, pas 0
```

> [!tip] Alignement Commencer les partitions à 1MiB garantit un alignement optimal pour les SSD et disques avancés. Parted le fait automatiquement avec des pourcentages (0%, 50%, etc.).

---

## 💿 Formatage des partitions

### mkfs - Créer un système de fichiers

**Utilité** : Formate une partition avec un système de fichiers spécifique (ext4, xfs, fat32, etc.).

> [!warning] Danger ABSOLU `mkfs` **DÉTRUIT** toutes les données sur la partition. Vérifiez deux fois le périphérique cible avant d'exécuter.

#### Syntaxe générale

```bash
# Format générique
sudo mkfs -t TYPE /dev/sdXN

# Ou utiliser les commandes spécifiques
sudo mkfs.ext4 /dev/sdXN
sudo mkfs.xfs /dev/sdXN
sudo mkfs.vfat /dev/sdXN
```

#### Formatage ext4 (le plus courant)

```bash
# Formatage simple
sudo mkfs.ext4 /dev/sdb1

# Avec label (étiquette)
sudo mkfs.ext4 -L "MesDonnees" /dev/sdb1

# Avec options avancées
sudo mkfs.ext4 -L "MesDonnees" -m 1 -O ^has_journal /dev/sdb1

# Options expliquées :
# -L : Label de la partition
# -m 1 : Réserver seulement 1% pour root (au lieu de 5%)
# -O ^has_journal : Désactiver le journal (plus rapide, moins sûr)
```

> [!example] Options courantes de mkfs.ext4
> 
> ```bash
> -L LABEL          # Définir un label
> -m POURCENTAGE    # Espace réservé pour root (défaut 5%)
> -N NOMBRE         # Nombre d'inodes
> -b TAILLE         # Taille des blocs (1024, 2048, 4096)
> -O feature        # Activer une fonctionnalité
> -O ^feature       # Désactiver une fonctionnalité
> -c                # Vérifier les mauvais blocs avant formatage
> ```

#### Formatage XFS

```bash
# Formatage simple
sudo mkfs.xfs /dev/sdb1

# Avec label
sudo mkfs.xfs -L "Backup" /dev/sdb1

# Avec options de performance
sudo mkfs.xfs -f -L "Backup" -b size=4096 /dev/sdb1

# -f : Force (écrase le système de fichiers existant)
# -b size=4096 : Taille de bloc 4K (optimal pour SSD)
```

> [!info] XFS vs ext4
> 
> - **XFS** : Meilleur pour gros fichiers, haute performance, ne peut pas être réduit
> - **ext4** : Standard, flexible, peut être réduit et agrandi

#### Formatage FAT32/exFAT (compatibilité Windows)

```bash
# FAT32 (compatibilité maximale)
sudo mkfs.vfat -F 32 -n "USB_DISK" /dev/sdb1

# exFAT (pour fichiers > 4 Go)
sudo mkfs.exfat -n "EXTERN_HDD" /dev/sdb1

# Options :
# -F 32 : FAT32 (12, 16, ou 32)
# -n : Label (11 caractères max pour FAT)
```

> [!warning] Limitation FAT32 FAT32 ne supporte pas les fichiers > 4 Go. Utilisez exFAT ou NTFS pour les gros fichiers.

#### Formatage NTFS (compatibilité Windows)

```bash
# Installer ntfs-3g si nécessaire
sudo apt install ntfs-3g  # Debian/Ubuntu
sudo yum install ntfs-3g  # RHEL/CentOS

# Formater en NTFS
sudo mkfs.ntfs -f -L "WindowsData" /dev/sdb1

# -f : Formatage rapide
# -L : Label
```

#### Formatage Btrfs (avancé)

```bash
# Formatage simple
sudo mkfs.btrfs /dev/sdb1

# Avec label
sudo mkfs.btrfs -L "BtrfsVol" /dev/sdb1

# RAID avec plusieurs disques
sudo mkfs.btrfs -m raid1 -d raid1 /dev/sdb1 /dev/sdc1

# -m : Métadonnées en RAID1
# -d : Données en RAID1
```

> [!tip] Btrfs Système de fichiers moderne avec snapshots, compression, déduplication. Idéal pour serveurs et workstations avancées.

#### Créer un swap

```bash
# Formater en swap
sudo mkswap /dev/sdb2

# Avec label
sudo mkswap -L "swap" /dev/sdb2

# Activer le swap
sudo swapon /dev/sdb2

# Vérifier
sudo swapon --show

# Désactiver
sudo swapoff /dev/sdb2
```

> [!info] Swap Espace d'échange utilisé quand la RAM est pleine. Recommandation : taille = 1-2x la RAM (pour hibernation) ou 2-4 Go minimum.

---

### Types de systèmes de fichiers

#### Comparatif des systèmes de fichiers Linux

|Système|Usage recommandé|Avantages|Inconvénients|
|---|---|---|---|
|**ext4**|Usage général, root, home|Stable, mature, flexible|Moins performant que XFS/Btrfs|
|**XFS**|Gros fichiers, NAS, médias|Très performant, grande capacité|Ne peut pas être réduit|
|**Btrfs**|Serveurs, snapshots, RAID|Snapshots, compression, RAID intégré|Moins mature que ext4|
|**F2FS**|SSD, cartes SD, Flash|Optimisé pour Flash|Spécialisé|
|**FAT32**|Clés USB, compatibilité|Compatible tous OS|Fichiers < 4 Go, pas de permissions|
|**exFAT**|Disques externes|Fichiers > 4 Go, compatible|Pas de permissions Unix|
|**NTFS**|Partage Windows/Linux|Compatible Windows|Performance moyenne sous Linux|

#### Caractéristiques détaillées

**ext4 (Fourth Extended Filesystem)**

- Standard Linux depuis 2008
- Taille max fichier : 16 To
- Taille max partition : 1 Eo (exaoctet)
- Journal pour la récupération après crash
- Support des ACL et des attributs étendus

**XFS (X File System)**

- Système de fichiers haute performance
- Taille max fichier : 8 Eo
- Taille max partition : 8 Eo
- Excellent pour les gros fichiers et la vidéo
- Allocation retardée pour de meilleures performances
- Ne peut PAS être réduit (seulement agrandi)

**Btrfs (B-tree File System)**

- Système de fichiers moderne "copy-on-write"
- Snapshots instantanés
- Compression transparente (zlib, lzo, zstd)
- RAID intégré (0, 1, 5, 6, 10)
- Déduplication et clonage de fichiers
- Auto-réparation avec checksums

**F2FS (Flash-Friendly File System)**

- Optimisé pour mémoire Flash (SSD, eMMC, SD)
- Réduit l'usure des cellules Flash
- Performances excellentes sur Flash
- Utilisé dans Android

> [!tip] Recommandations selon l'usage
> 
> - **Système d'exploitation** : ext4 ou XFS
> - **Serveur de fichiers** : XFS ou Btrfs
> - **SSD moderne** : ext4, XFS ou F2FS
> - **Backups/Snapshots** : Btrfs
> - **Compatibilité multi-OS** : exFAT

#### Modifier le label d'un système de fichiers existant

```bash
# ext4
sudo e2label /dev/sdb1 "NouveauLabel"

# XFS
sudo xfs_admin -L "NouveauLabel" /dev/sdb1

# FAT32/exFAT
sudo fatlabel /dev/sdb1 "NOUVEAU"

# NTFS
sudo ntfslabel /dev/sdb1 "NouveauLabel"

# Btrfs
sudo btrfs filesystem label /dev/sdb1 "NouveauLabel"
```

---

## 🗂️ Montage des partitions

### mount - Monter un système de fichiers

**Utilité** : Rend une partition accessible dans l'arborescence Linux en l'attachant à un point de montage.

> [!info] Concept de montage Sous Linux, toutes les partitions doivent être "montées" dans l'arborescence pour être utilisables. Le montage attache une partition à un dossier (point de montage).

#### Syntaxe de base

```bash
sudo mount [OPTIONS] PÉRIPHÉRIQUE POINT_DE_MONTAGE
```

#### Montage simple

```bash
# Créer le point de montage
sudo mkdir -p /mnt/data

# Monter la partition
sudo mount /dev/sdb1 /mnt/data

# Vérifier
mount | grep sdb1
# ou
df -h /mnt/data
```

#### Options de montage courantes

```bash
# Montage en lecture seule
sudo mount -o ro /dev/sdb1 /mnt/data

# Montage en lecture-écriture (défaut)
sudo mount -o rw /dev/sdb1 /mnt/data

# Montage avec options multiples
sudo mount -o rw,noexec,nosuid /dev/sdb1 /mnt/data

# Spécifier le type de système de fichiers
sudo mount -t ext4 /dev/sdb1 /mnt/data

# Montage avec UUID (recommandé)
sudo mount UUID=1234-5678-90ab-cdef /mnt/data
```

#### Options de montage importantes

|Option|Description|Usage|
|---|---|---|
|**rw**|Lecture-écriture (défaut)|Usage normal|
|**ro**|Lecture seule|Protection, récupération|
|**noexec**|Pas d'exécution de binaires|Sécurité|
|**nosuid**|Ignorer les bits SUID/SGID|Sécurité|
|**nodev**|Pas de fichiers spéciaux|Sécurité|
|**noatime**|Ne pas mettre à jour atime|Performance|
|**nodiratime**|Ne pas mettre à jour atime des dossiers|Performance|
|**relatime**|Mise à jour atime relative|Compromis perf/info|
|**user**|Autoriser les utilisateurs non-root|Clés USB|
|**users**|Idem + démontage par tous|Clés USB|
|**auto**|Montage au boot (fstab)|Montage auto|
|**noauto**|Pas de montage au boot|Montage manuel|
|**defaults**|rw,suid,dev,exec,auto,nouser,async|Standard|

> [!example] Combinaison d'options
> 
> ```bash
> # Partition /home avec optimisations
> sudo mount -o defaults,noatime,nodiratime /dev/sdb3 /home
> 
> # Clé USB accessible aux utilisateurs
> sudo mount -o rw,nosuid,nodev,user /dev/sdc1 /media/usb
> 
> # Partition temporaire sécurisée
> sudo mount -o rw,noexec,nosuid,nodev /dev/sdb2 /tmp
> ```

#### Montage par UUID (recommandé)

```bash
# Récupérer l'UUID
sudo blkid /dev/sdb1

# Monter avec UUID
sudo mount UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" /mnt/data
```

> [!tip] Pourquoi utiliser UUID ?
> 
> - Les noms de périphériques (/dev/sdb1) peuvent changer au redémarrage
> - L'UUID est unique et permanent
> - Indispensable pour /etc/fstab

#### Montage de systèmes de fichiers spéciaux

```bash
# Monter une partition NTFS
sudo mount -t ntfs-3g /dev/sdb1 /mnt/windows

# Monter une partition FAT32
sudo mount -t vfat /dev/sdb1 /mnt/usb

# Monter une image ISO
sudo mount -o loop fichier.iso /mnt/iso

# Monter un partage NFS (réseau)
sudo mount -t nfs 192.168.1.100:/export/share /mnt/nfs

# Monter un partage CIFS/SMB (Windows)
sudo mount -t cifs //serveur/partage /mnt/smb -o username=user,password=pass
```

#### Remonter une partition (changer les options)

```bash
# Remonter en lecture seule sans démonter
sudo mount -o remount,ro /mnt/data

# Remonter en lecture-écriture
sudo mount -o remount,rw /mnt/data

# Ajouter noatime à une partition montée
sudo mount -o remount,noatime /mnt/data
```

#### Afficher les montages actuels

```bash
# Toutes les partitions montées
mount

# Partitions montées de façon lisible
mount | column -t

# Seulement les systèmes de fichiers réels
mount -t ext4,xfs,btrfs

# Avec df
df -h

# Format détaillé
findmnt
```

> [!tip] findmnt `findmnt` est un outil moderne qui affiche une arborescence claire des montages avec toutes les options.

---

### umount - Démonter un système de fichiers

**Utilité** : Détache une partition de l'arborescence et libère les ressources.

> [!warning] Démontage obligatoire Toujours démonter une partition avant de débrancher un périphérique externe (clé USB, disque externe) pour éviter la corruption des données.

#### Syntaxe

```bash
# Démonter par point de montage
sudo umount /mnt/data

# Démonter par périphérique
sudo umount /dev/sdb1

# Démonter plusieurs partitions
sudo umount /mnt/data1 /mnt/data2 /mnt/data3
```

#### Démonter avec options

```bash
# Forcer le démontage (dangereux)
sudo umount -f /mnt/data

# Démontage "paresseux" (attendre la fin des opérations)
sudo umount -l /mnt/data

# Démonter et synchroniser avant
sync && sudo umount /mnt/data
```

> [!warning] umount -f Le démontage forcé (`-f`) peut causer une perte de données. Utilisez-le seulement en dernier recours (ex: partage réseau inaccessible).

#### Erreur "device is busy"

```bash
# Erreur courante
$ sudo umount /mnt/data
umount: /mnt/data: target is busy.
```

**Causes :**

- Un processus utilise des fichiers sur la partition
- Vous êtes dans un dossier de la partition (avec `cd`)
- Un programme a des fichiers ouverts

**Solutions :**

```bash
# 1. Vérifier qui utilise la partition
sudo lsof /mnt/data

# ou
sudo fuser -m /mnt/data

# 2. Sortir du répertoire si vous y êtes
cd /

# 3. Tuer les processus qui utilisent la partition
sudo fuser -km /mnt/data

# 4. Démonter en mode paresseux si nécessaire
sudo umount -l /mnt/data
```

> [!example] Exemple lsof
> 
> ```bash
> $ sudo lsof /mnt/data
> COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
> bash     1234 user  cwd    DIR   8,17     4096  256 /mnt/data
> firefox  5678 user   12r   REG   8,17   102400  512 /mnt/data/file.txt
> ```
> 
> Ici, bash a son répertoire courant dans /mnt/data, et firefox a un fichier ouvert.

#### Démonter toutes les partitions d'un disque

```bash
# Démonter toutes les partitions de /dev/sdb
sudo umount /dev/sdb*

# ou avec une boucle
for part in /dev/sdb*; do sudo umount $part 2>/dev/null; done
```

---

### /etc/fstab - Montage automatique

**Utilité** : Fichier de configuration qui définit les partitions à monter automatiquement au démarrage du système.

> [!info] Importance de fstab `/etc/fstab` (File System TABle) est le fichier central de configuration des montages permanents. Erreur = système qui ne démarre plus !

#### Structure du fichier /etc/fstab

```bash
# Afficher le contenu
cat /etc/fstab
```

Chaque ligne contient 6 champs séparés par des espaces/tabs :

```
<périphérique> <point_montage> <type> <options> <dump> <pass>
```

|Champ|Description|Valeurs courantes|
|---|---|---|
|**périphérique**|UUID, LABEL, ou /dev/sdXN|UUID=..., LABEL=..., /dev/sdb1|
|**point_montage**|Où monter|/, /home, /mnt/data|
|**type**|Système de fichiers|ext4, xfs, vfat, ntfs, swap|
|**options**|Options de montage|defaults, noatime, rw, ro|
|**dump**|Sauvegarde avec dump|0 (non), 1 (oui)|
|**pass**|Ordre vérification fsck|0 (jamais), 1 (root), 2 (autres)|

#### Exemple de /etc/fstab complet

```bash
# /etc/fstab: static file system information.
#
# <file system>                            <mount point>  <type>  <options>                    <dump> <pass>

# Partition root
UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890  /              ext4    defaults,noatime             0      1

# Partition EFI
UUID=1234-5678                             /boot/efi      vfat    umask=0077                   0      2

# Partition home
UUID=f9e8d7c6-b5a4-3210-fedc-ba9876543210  /home          ext4    defaults,noatime             0      2

# Partition swap
UUID=12345678-abcd-ef01-2345-67890abcdef   none           swap    sw                           0      0

# Disque de données
UUID=abcdefgh-1234-5678-90ab-cdefghijk123  /mnt/data      ext4    defaults,noatime,noauto      0      0

# Partition temporaire en tmpfs (RAM)
tmpfs                                      /tmp           tmpfs   defaults,noatime,mode=1777   0      0
```

#### Ajouter une partition au fstab

**Étapes complètes :**

```bash
# 1. Identifier l'UUID de la partition
sudo blkid /dev/sdb1
# Sortie : /dev/sdb1: UUID="abcd-efgh-1234-5678" TYPE="ext4"

# 2. Créer le point de montage si nécessaire
sudo mkdir -p /mnt/data

# 3. Tester le montage manuellement
sudo mount UUID=abcd-efgh-1234-5678 /mnt/data

# 4. Vérifier que ça fonctionne
ls /mnt/data
df -h /mnt/data

# 5. Démonter
sudo umount /mnt/data

# 6. Éditer /etc/fstab
sudo nano /etc/fstab
# ou
sudo vim /etc/fstab

# 7. Ajouter la ligne (avec votre UUID réel)
UUID=abcd-efgh-1234-5678  /mnt/data  ext4  defaults,noatime  0  2

# 8. Tester la configuration fstab SANS redémarrer
sudo mount -a

# 9. Vérifier
df -h /mnt/data
```

> [!warning] CRITIQUE : Tester avec mount -a **TOUJOURS** tester avec `sudo mount -a` avant de redémarrer. Une erreur dans fstab peut empêcher le système de démarrer !

#### Options fstab courantes

```bash
# Montage standard
defaults,noatime  0  2

# Partition /home optimisée
defaults,noatime,nodiratime  0  2

# Partition de données, pas de montage auto
defaults,noatime,noauto  0  0

# Clé USB accessible aux utilisateurs
defaults,noatime,noauto,user  0  0

# Partition Windows (NTFS)
defaults,noatime,noauto,uid=1000,gid=1000,umask=022  0  0

# Swap
sw  0  0

# tmpfs (RAM) pour /tmp
defaults,noatime,nosuid,nodev,noexec,mode=1777  0  0
```

#### Options de sécurité recommandées

|Partition|Options recommandées|Raison|
|---|---|---|
|**/**|`defaults,noatime`|Standard, performance|
|**/home**|`defaults,noatime,nosuid,nodev`|Sécurité utilisateurs|
|**/tmp**|`defaults,noexec,nosuid,nodev`|Empêcher exécution malware|
|**/var**|`defaults,noatime,nosuid`|Logs et données système|
|**/boot**|`defaults,ro`|Protection kernel|
|**Données**|`defaults,noatime,noauto`|Montage manuel|

#### Utiliser des LABELS au lieu d'UUID

```bash
# Créer un label (si pas fait à la création)
sudo e2label /dev/sdb1 "MesDonnees"

# Dans fstab
LABEL=MesDonnees  /mnt/data  ext4  defaults,noatime  0  2
```

> [!tip] UUID vs LABEL
> 
> - **UUID** : Plus fiable, ne change jamais
> - **LABEL** : Plus lisible, peut être dupliqué (attention)
> 
> Préférez UUID pour les systèmes critiques.

#### Champs dump et pass expliqués

**dump (5ème champ) :**

- `0` : Pas de sauvegarde avec l'outil `dump` (usage moderne)
- `1` : Inclure dans les sauvegardes dump (peu utilisé aujourd'hui)

**pass (6ème champ) :**

- `0` : Pas de vérification fsck au démarrage
- `1` : Première vérification (réservé à la partition root /)
- `2` : Vérification après la partition root (autres partitions)

> [!info] fsck `fsck` (File System ChecK) vérifie et répare les systèmes de fichiers. Le champ `pass` détermine l'ordre de vérification au boot.

#### Commenter et organiser fstab

```bash
# Utilisez des commentaires pour la lisibilité
# ============================================
# Partitions système principales
# ============================================

UUID=...  /      ext4  defaults,noatime  0  1
UUID=...  /home  ext4  defaults,noatime  0  2

# ============================================
# Disques de données supplémentaires
# ============================================

UUID=...  /mnt/data     ext4  defaults,noatime,noauto  0  0
UUID=...  /mnt/backup   xfs   defaults,noatime,noauto  0  0
```

#### Réparer un fstab cassé

Si le système ne démarre plus à cause d'un fstab incorrect :

```bash
# 1. Booter en mode recovery/rescue

# 2. Remonter / en lecture-écriture
mount -o remount,rw /

# 3. Éditer fstab
nano /etc/fstab

# 4. Commenter la ligne problématique avec #
# UUID=... /mnt/data ext4 defaults 0 2

# 5. Enregistrer et redémarrer
reboot
```

> [!warning] Mode rescue Ayez toujours une clé USB bootable (live USB) pour réparer un système qui ne démarre plus à cause de fstab.

---

## 🛠️ Commandes complémentaires essentielles

### partprobe - Informer le kernel des changements

```bash
# Forcer la relecture de la table de partitions
sudo partprobe /dev/sdb

# Pour tous les disques
sudo partprobe
```

**Utilité :** Après avoir créé/modifié des partitions avec fdisk/parted, le kernel doit être informé pour reconnaître les changements sans redémarrer.

---

### fsck - Vérifier et réparer un système de fichiers

```bash
# Vérifier une partition (doit être démontée)
sudo fsck /dev/sdb1

# Vérifier et réparer automatiquement
sudo fsck -y /dev/sdb1

# Forcer la vérification même si propre
sudo fsck -f /dev/sdb1

# Vérifier avec type spécifique
sudo fsck.ext4 /dev/sdb1
sudo fsck.xfs /dev/sdb1
```

> [!warning] fsck sur partition montée **JAMAIS** exécuter fsck sur une partition montée en écriture ! Cela peut causer des corruptions irréversibles.

**Cas d'usage :**

- Erreurs de disque
- Système de fichiers corrompu
- Après un crash système
- Périodiquement en maintenance

---

### tune2fs - Modifier les paramètres ext4

```bash
# Afficher les informations
sudo tune2fs -l /dev/sdb1

# Changer le label
sudo tune2fs -L "NouveauLabel" /dev/sdb1

# Modifier l'espace réservé à root (défaut 5%)
sudo tune2fs -m 1 /dev/sdb1

# Changer l'intervalle de vérification fsck
sudo tune2fs -i 0 /dev/sdb1  # Désactiver vérification temps
sudo tune2fs -c 0 /dev/sdb1  # Désactiver vérification nombre montages

# Activer/désactiver le journal
sudo tune2fs -O ^has_journal /dev/sdb1  # Désactiver
sudo tune2fs -O has_journal /dev/sdb1   # Activer
```

> [!tip] Optimisation SSD Sur SSD, désactiver les vérifications automatiques peut améliorer la durée de vie :
> 
> ```bash
> sudo tune2fs -c 0 -i 0 /dev/sdb1
> ```

---

### resize2fs - Redimensionner ext4

```bash
# Agrandir jusqu'à la taille max de la partition
sudo resize2fs /dev/sdb1

# Réduire à une taille spécifique (partition démontée !)
sudo resize2fs /dev/sdb1 50G

# Vérifier d'abord avec e2fsck
sudo e2fsck -f /dev/sdb1
sudo resize2fs /dev/sdb1
```

> [!warning] Ordre important Pour **réduire** une partition :
> 
> 1. Démonter
> 2. `e2fsck -f`
> 3. `resize2fs` (réduire le FS)
> 4. `parted resizepart` (réduire la partition)
> 
> Pour **agrandir** :
> 
> 1. `parted resizepart` (agrandir la partition d'abord)
> 2. `resize2fs` (agrandir le FS ensuite)

---

### xfs_growfs - Agrandir XFS

```bash
# Agrandir au maximum (partition doit être MONTÉE)
sudo xfs_growfs /mnt/data

# Afficher les informations XFS
sudo xfs_info /mnt/data
```

> [!info] XFS ne peut pas être réduit XFS supporte seulement l'agrandissement, jamais la réduction. Si vous devez réduire, vous devez sauvegarder, supprimer, recréer.

---

### dd - Copier des partitions/disques

```bash
# Cloner un disque entier
sudo dd if=/dev/sda of=/dev/sdb bs=4M status=progress

# Sauvegarder une partition dans un fichier
sudo dd if=/dev/sdb1 of=/backup/partition.img bs=4M status=progress

# Restaurer une partition depuis une image
sudo dd if=/backup/partition.img of=/dev/sdb1 bs=4M status=progress

# Effacer un disque (avec zéros)
sudo dd if=/dev/zero of=/dev/sdb bs=4M status=progress

# Créer un fichier test de 1 Go
dd if=/dev/zero of=fichier_test.bin bs=1M count=1024
```

> [!warning] dd est DESTRUCTIF `dd` écrase sans confirmation. Vérifiez TROIS FOIS vos `if` (input) et `of` (output) avant d'appuyer sur Entrée. **Surnommé "Disk Destroyer" pour une bonne raison !**

**Options importantes :**

- `if=` : Input file (source)
- `of=` : Output file (destination)
- `bs=` : Block size (4M optimal pour disques modernes)
- `status=progress` : Afficher la progression
- `conv=sync,noerror` : Continuer même en cas d'erreur (récupération)

---

### wipefs - Effacer les signatures de système de fichiers

```bash
# Afficher les signatures présentes
sudo wipefs /dev/sdb1

# Effacer toutes les signatures
sudo wipefs -a /dev/sdb1

# Utile avant de repartitionner ou reformater
```

**Utilité :** Parfois, des signatures anciennes empêchent le bon formatage. `wipefs` nettoie ces traces.

---

### hdparm / sdparm - Informations et configuration disques

```bash
# Informations détaillées du disque
sudo hdparm -I /dev/sda

# Tester la vitesse de lecture
sudo hdparm -tT /dev/sda

# Mettre en veille un disque
sudo hdparm -y /dev/sda

# Vérifier si un SSD supporte TRIM
sudo hdparm -I /dev/sda | grep TRIM
```

---

### smartctl - Surveillance SMART des disques

```bash
# Installer smartmontools si nécessaire
sudo apt install smartmontools

# Afficher les informations SMART
sudo smartctl -a /dev/sda

# Vérifier la santé globale
sudo smartctl -H /dev/sda

# Lancer un test court
sudo smartctl -t short /dev/sda

# Lancer un test long
sudo smartctl -t long /dev/sda
```

**Utilité :** SMART surveille la santé du disque et prédit les pannes. Essentiel pour la maintenance préventive.

---

## 🔄 Workflows complets

### Workflow 1 : Ajouter un nouveau disque complet

**Scénario :** Vous installez un nouveau disque /dev/sdb de 1 To pour stocker des données.

```bash
# 1. Vérifier que le disque est reconnu
lsblk
sudo fdisk -l /dev/sdb

# 2. Créer une table de partitions GPT
sudo parted /dev/sdb mklabel gpt

# 3. Créer une partition utilisant tout l'espace
sudo parted /dev/sdb mkpart primary ext4 0% 100%

# 4. Vérifier
lsblk

# 5. Formater en ext4 avec label
sudo mkfs.ext4 -L "Stockage" /dev/sdb1

# 6. Créer le point de montage
sudo mkdir -p /mnt/stockage

# 7. Récupérer l'UUID
UUID=$(sudo blkid -s UUID -o value /dev/sdb1)
echo $UUID

# 8. Ajouter à fstab
echo "UUID=$UUID  /mnt/stockage  ext4  defaults,noatime  0  2" | sudo tee -a /etc/fstab

# 9. Tester le montage
sudo mount -a

# 10. Vérifier
df -h /mnt/stockage
```

---

### Workflow 2 : Créer plusieurs partitions sur un disque

**Scénario :** Disque de 500 Go divisé en 3 partitions (100G, 150G, reste).

```bash
# 1. Lancer cfdisk (plus visuel)
sudo cfdisk /dev/sdb

# Dans cfdisk :
# - Créer table GPT si demandé
# - [New] → 100G → Type: Linux filesystem
# - [New] → 150G → Type: Linux filesystem
# - [New] → [Entrée] (reste) → Type: Linux filesystem
# - [Write] → yes
# - [Quit]

# 2. Vérifier
lsblk

# 3. Formater les partitions
sudo mkfs.ext4 -L "Documents" /dev/sdb1
sudo mkfs.ext4 -L "Medias" /dev/sdb2
sudo mkfs.xfs -L "Backups" /dev/sdb3

# 4. Créer les points de montage
sudo mkdir -p /mnt/{documents,medias,backups}

# 5. Ajouter à fstab (récupérer les UUIDs d'abord)
sudo blkid /dev/sdb1 /dev/sdb2 /dev/sdb3

# 6. Éditer fstab et ajouter
sudo nano /etc/fstab

# UUID=... /mnt/documents ext4 defaults,noatime 0 2
# UUID=... /mnt/medias    ext4 defaults,noatime 0 2
# UUID=... /mnt/backups   xfs  defaults,noatime 0 2

# 7. Monter tout
sudo mount -a

# 8. Vérifier
df -h
```

---

### Workflow 3 : Préparer une clé USB multi-OS

**Scénario :** Clé USB avec partition FAT32 (compatibilité Windows/Mac/Linux).

```bash
# 1. Identifier la clé
lsblk

# 2. Démonter si montée automatiquement
sudo umount /dev/sdc1

# 3. Effacer les signatures existantes
sudo wipefs -a /dev/sdc

# 4. Créer table MBR (meilleure compatibilité pour USB)
sudo parted /dev/sdc mklabel msdos

# 5. Créer partition FAT32
sudo parted /dev/sdc mkpart primary fat32 0% 100%

# 6. Marquer comme bootable
sudo parted /dev/sdc set 1 boot on

# 7. Formater en FAT32
sudo mkfs.vfat -F 32 -n "MA_CLE" /dev/sdc1

# 8. Monter temporairement
sudo mkdir -p /mnt/usb
sudo mount /dev/sdc1 /mnt/usb

# 9. Vérifier
df -h /mnt/usb

# 10. Démonter avant de retirer
sudo umount /mnt/usb
```

---

### Workflow 4 : Ajouter un swap

**Scénario :** Créer une partition swap de 4 Go.

```bash
# 1. Créer la partition avec fdisk ou cfdisk
sudo cfdisk /dev/sdb
# Type: Linux swap

# 2. Formater en swap
sudo mkswap -L "swap" /dev/sdb2

# 3. Activer temporairement
sudo swapon /dev/sdb2

# 4. Vérifier
sudo swapon --show
free -h

# 5. Rendre permanent dans fstab
UUID=$(sudo blkid -s UUID -o value /dev/sdb2)
echo "UUID=$UUID  none  swap  sw  0  0" | sudo tee -a /etc/fstab

# 6. Vérifier fstab
sudo swapon -a
```

---

### Workflow 5 : Monter une partition Windows (NTFS)

**Scénario :** Double boot Windows/Linux, accéder aux fichiers Windows depuis Linux.

```bash
# 1. Installer le support NTFS
sudo apt install ntfs-3g  # Debian/Ubuntu

# 2. Identifier la partition Windows
sudo fdisk -l | grep NTFS
# ou
lsblk -f

# 3. Créer le point de montage
sudo mkdir -p /mnt/windows

# 4. Monter temporairement
sudo mount -t ntfs-3g /dev/sda3 /mnt/windows

# 5. Vérifier l'accès
ls /mnt/windows

# 6. Rendre permanent dans fstab (avec permissions utilisateur)
UUID=$(sudo blkid -s UUID -o value /dev/sda3)
echo "UUID=$UUID  /mnt/windows  ntfs-3g  defaults,noatime,uid=1000,gid=1000,umask=022  0  0" | sudo tee -a /etc/fstab

# 7. Tester
sudo umount /mnt/windows
sudo mount -a
ls /mnt/windows
```

> [!info] Options NTFS importantes
> 
> - `uid=1000,gid=1000` : Propriétaire des fichiers (votre utilisateur)
> - `umask=022` : Permissions (755 pour dossiers, 644 pour fichiers)
> - `windows_names` : Respecter les restrictions de noms Windows

---

### Workflow 6 : Agrandir une partition existante

**Scénario :** Partition /dev/sdb1 de 50G à agrandir à 100G (espace libre disponible après).

```bash
# 1. Sauvegarder les données (TOUJOURS)
# ... copie de sécurité ...

# 2. Démonter la partition
sudo umount /dev/sdb1

# 3. Vérifier le système de fichiers
sudo e2fsck -f /dev/sdb1

# 4. Agrandir la partition avec parted
sudo parted /dev/sdb
(parted) print  # Noter le numéro et le début
(parted) resizepart 1 100GB
(parted) quit

# 5. Agrandir le système de fichiers
sudo resize2fs /dev/sdb1

# 6. Remonter
sudo mount /dev/sdb1 /mnt/data

# 7. Vérifier
df -h /mnt/data
```

> [!warning] Ordre critique Pour agrandir : **partition PUIS système de fichiers** Pour réduire : **système de fichiers PUIS partition**

---

### Workflow 7 : Migrer des données vers un nouveau disque

**Scénario :** Remplacer /dev/sdb (ancien) par /dev/sdc (nouveau, plus grand).

```bash
# 1. Préparer le nouveau disque
sudo parted /dev/sdc mklabel gpt
sudo parted /dev/sdc mkpart primary ext4 0% 100%
sudo mkfs.ext4 -L "Nouveau" /dev/sdc1

# 2. Monter les deux disques
sudo mkdir -p /mnt/{ancien,nouveau}
sudo mount /dev/sdb1 /mnt/ancien
sudo mount /dev/sdc1 /mnt/nouveau

# 3. Copier avec rsync (préserve permissions)
sudo rsync -avxHAX --progress /mnt/ancien/ /mnt/nouveau/

# Ou avec cp (alternative)
# sudo cp -a /mnt/ancien/* /mnt/nouveau/

# 4. Vérifier l'intégrité
sudo diff -r /mnt/ancien /mnt/nouveau

# 5. Mettre à jour fstab
sudo blkid /dev/sdc1  # Noter le nouvel UUID
sudo nano /etc/fstab  # Remplacer l'ancien UUID par le nouveau

# 6. Tester
sudo umount /mnt/ancien /mnt/nouveau
sudo mount -a

# 7. Une fois validé, vous pouvez retirer l'ancien disque
```

> [!tip] rsync vs cp **rsync** est préférable car :
> 
> - Affiche la progression
> - Peut reprendre après interruption
> - Plus fiable pour les permissions et liens

---

## 📋 Cheat Sheet complète

### 🔍 Visualisation

```bash
# Vue d'ensemble rapide
lsblk -f

# Détails complets d'un disque
sudo fdisk -l /dev/sda

# UUID et types de FS
sudo blkid

# Espaces utilisés (montés)
df -h

# Arborescence des montages
findmnt

# Informations détaillées SMART
sudo smartctl -a /dev/sda
```

---

### 🔧 Partitionnement

```bash
# fdisk - Mode interactif classique
sudo fdisk /dev/sdb
# Dans fdisk: m (aide), n (new), d (delete), t (type), w (write), q (quit)

# cfdisk - Interface semi-graphique
sudo cfdisk /dev/sdb

# parted - Commandes directes
sudo parted /dev/sdb mklabel gpt
sudo parted /dev/sdb mkpart primary ext4 0% 50GB
sudo parted /dev/sdb mkpart primary ext4 50GB 100%

# Informer le kernel des changements
sudo partprobe /dev/sdb
```

---

### 💿 Formatage

```bash
# ext4 (standard Linux)
sudo mkfs.ext4 -L "MonLabel" /dev/sdb1

# XFS (performance)
sudo mkfs.xfs -L "MonLabel" /dev/sdb1

# Btrfs (moderne, snapshots)
sudo mkfs.btrfs -L "MonLabel" /dev/sdb1

# FAT32 (compatibilité)
sudo mkfs.vfat -F 32 -n "USB" /dev/sdb1

# exFAT (gros fichiers multi-OS)
sudo mkfs.exfat -n "EXTERN" /dev/sdb1

# NTFS (Windows)
sudo mkfs.ntfs -f -L "Windows" /dev/sdb1

# Swap
sudo mkswap -L "swap" /dev/sdb2
sudo swapon /dev/sdb2

# Changer label après création
sudo e2label /dev/sdb1 "NouveauLabel"  # ext4
sudo xfs_admin -L "NouveauLabel" /dev/sdb1  # XFS
```

---

### 🗂️ Montage

```bash
# Montage simple
sudo mount /dev/sdb1 /mnt/data

# Avec UUID (recommandé)
sudo mount UUID=a1b2c3d4-... /mnt/data

# Avec options
sudo mount -o rw,noatime,noexec /dev/sdb1 /mnt/data

# Lecture seule
sudo mount -o ro /dev/sdb1 /mnt/data

# Remonter avec nouvelles options
sudo mount -o remount,rw /mnt/data

# Image ISO
sudo mount -o loop fichier.iso /mnt/iso

# Démonter
sudo umount /mnt/data

# Démonter (partition busy)
cd /  # Sortir du répertoire
sudo fuser -km /mnt/data  # Tuer les processus
sudo umount -l /mnt/data  # Démontage paresseux si nécessaire

# Monter tout depuis fstab
sudo mount -a
```

---

### 📝 /etc/fstab

```bash
# Structure
<UUID/device>  <mount_point>  <type>  <options>  <dump>  <pass>

# Exemples de lignes fstab
UUID=...  /              ext4  defaults,noatime           0  1
UUID=...  /home          ext4  defaults,noatime           0  2
UUID=...  /mnt/data      xfs   defaults,noatime,noauto    0  0
UUID=...  none           swap  sw                         0  0
tmpfs     /tmp           tmpfs defaults,noatime,mode=1777 0  0

# Tester fstab sans redémarrer
sudo mount -a

# Options courantes
defaults            # rw,suid,dev,exec,auto,nouser,async
noatime            # Pas de mise à jour access time (performance)
noauto             # Pas de montage auto au boot
user               # Utilisateurs peuvent monter
noexec             # Pas d'exécution (sécurité)
nosuid             # Ignorer SUID/SGID (sécurité)
ro                 # Lecture seule
```

---

### 🛠️ Maintenance

```bash
# Vérifier et réparer (partition DÉMONTÉE)
sudo fsck -y /dev/sdb1
sudo e2fsck -f /dev/sdb1  # ext4 spécifique

# Agrandir ext4
sudo resize2fs /dev/sdb1

# Agrandir XFS (partition MONTÉE)
sudo xfs_growfs /mnt/data

# Modifier paramètres ext4
sudo tune2fs -l /dev/sdb1  # Afficher
sudo tune2fs -L "Label" /dev/sdb1  # Changer label
sudo tune2fs -m 1 /dev/sdb1  # Espace réservé root: 1%

# Effacer signatures
sudo wipefs -a /dev/sdb1

# Cloner disque
sudo dd if=/dev/sda of=/dev/sdb bs=4M status=progress

# Test vitesse lecture
sudo hdparm -tT /dev/sda

# Santé disque (SMART)
sudo smartctl -H /dev/sda
```

---

### 🔑 Trouver des informations

```bash
# UUID d'une partition
sudo blkid /dev/sdb1
sudo blkid -s UUID -o value /dev/sdb1  # Seulement UUID

# Label d'une partition
sudo blkid -s LABEL -o value /dev/sdb1

# Type de FS
sudo blkid -s TYPE -o value /dev/sdb1

# Partition qui utilise un point de montage
df /mnt/data

# Processus qui bloquent un démontage
sudo lsof /mnt/data
sudo fuser -m /mnt/data

# Voir tous les montages
mount | column -t
findmnt
cat /proc/mounts
```

---

### 🚨 Commandes de dépannage

```bash
# Forcer relecture table de partitions
sudo partprobe /dev/sdb
sudo blockdev --rereadpt /dev/sdb

# Partition marquée dirty, forcer vérification
sudo tune2fs -C 1 /dev/sdb1
sudo fsck -f /dev/sdb1

# Remonter / en lecture-écriture (mode recovery)
mount -o remount,rw /

# Réparer fstab cassé (mode recovery)
mount -o remount,rw /
nano /etc/fstab  # Commenter ligne problématique

# Supprimer tous les montages d'un disque
sudo umount /dev/sdb*

# Synchroniser avant démontage
sync
```

---

### 🎯 Cas d'usage rapides

**Nouveau disque complet en 5 commandes :**

```bash
sudo parted /dev/sdb mklabel gpt
sudo parted /dev/sdb mkpart primary ext4 0% 100%
sudo mkfs.ext4 -L "Data" /dev/sdb1
sudo mkdir -p /mnt/data
echo "UUID=$(sudo blkid -s UUID -o value /dev/sdb1)  /mnt/data  ext4  defaults,noatime  0  2" | sudo tee -a /etc/fstab && sudo mount -a
```

**Clé USB FAT32 rapide :**

```bash
sudo umount /dev/sdc1
sudo mkfs.vfat -F 32 -n "USB" /dev/sdc1
```

**Swap en urgence (fichier) :**

```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
```

**Monter partition Windows/NTFS :**

```bash
sudo mkdir -p /mnt/windows
sudo mount -t ntfs-3g -o uid=$(id -u),gid=$(id -g),umask=022 /dev/sda3 /mnt/windows
```

**Cloner partition vers image :**

```bash
sudo dd if=/dev/sdb1 of=/backup/partition_$(date +%Y%m%d).img bs=4M status=progress
```

---

### 📊 Tableaux récapitulatifs

#### Systèmes de fichiers recommandés

|Usage|Système de fichiers|Raison|
|---|---|---|
|Partition système (/)|ext4|Stabilité, compatibilité|
|Serveur fichiers|XFS|Performance gros fichiers|
|Backups/Snapshots|Btrfs|Snapshots, compression|
|SSD moderne|F2FS ou ext4|Optimisation Flash|
|Clé USB portable|FAT32|Compatibilité universelle|
|Disque externe >4Go/fichier|exFAT|Multi-OS, pas de limite 4Go|
|Dual boot Windows|NTFS|Compatibilité Windows|

#### Options fstab par partition

|Partition|Options recommandées|
|---|---|
|/ (root)|`defaults,noatime`|
|/home|`defaults,noatime,nosuid,nodev`|
|/tmp|`defaults,noexec,nosuid,nodev`|
|/var|`defaults,noatime,nosuid`|
|/boot|`defaults,ro` (après config)|
|Swap|`sw`|
|Données|`defaults,noatime,noauto`|
|USB|`defaults,noauto,user,noexec`|

#### Comparaison outils de partitionnement

|Outil|Interface|Difficulté|Application immédiate|Recommandé pour|
|---|---|---|---|---|
|**fdisk**|Ligne de commande|Moyenne|Non (w pour écrire)|Utilisateurs avancés|
|**cfdisk**|Semi-graphique|Facile|Non (Write pour écrire)|Débutants|
|**parted**|Ligne de commande|Moyenne|**OUI (DANGER)**|Scripts, GPT avancé|

#### Pass fsck selon la partition

|Partition|Pass|Raison|
|---|---|---|
|/ (root)|1|Vérification en premier|
|/home, /var, etc.|2|Vérification après root|
|/mnt/data (manuel)|0|Pas de vérification auto|
|tmpfs, swap|0|Non applicable|

---

### 💡 Pièges courants et solutions

#### "device is busy" au démontage

```bash
# Trouver qui utilise la partition
sudo lsof /mnt/data
sudo fuser -m /mnt/data

# Sortir du répertoire
cd /

# Tuer les processus
sudo fuser -km /mnt/data

# Démontage paresseux en dernier recours
sudo umount -l /mnt/data
```

#### Partition non reconnue après création

```bash
# Informer le kernel
sudo partprobe /dev/sdb

# Si ça ne suffit pas
sudo blockdev --rereadpt /dev/sdb

# En dernier recours
sudo reboot
```

#### fstab empêche le boot

```bash
# Booter en recovery mode
# Remonter / en écriture
mount -o remount,rw /

# Éditer et commenter ligne problématique
nano /etc/fstab

# Sauvegarder et redémarrer
reboot
```

#### Erreur "Read-only file system"

```bash
# Le système est passé en lecture seule (protection)
# Remonter en lecture-écriture
sudo mount -o remount,rw /

# Vérifier le système de fichiers
sudo fsck -f /dev/sda1  # À faire en rescue mode
```

#### UUID ne change pas après reformatage

```bash
# C'est normal, UUID identifie le système de fichiers
# Pour forcer un nouvel UUID
sudo tune2fs -U random /dev/sdb1  # ext4
sudo xfs_admin -U generate /dev/sdb1  # XFS
```

#### Espace disponible incohérent (ext4)

```bash
# 5% réservé à root par défaut
# Afficher le pourcentage réservé
sudo tune2fs -l /dev/sdb1 | grep "Reserved block count"

# Réduire à 1%
sudo tune2fs -m 1 /dev/sdb1
```

#### Performance médiocre sur SSD

```bash
# Vérifier si TRIM est activé
sudo systemctl status fstrim.timer

# Activer TRIM hebdomadaire
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

# Ou ajouter discard dans fstab (pas recommandé)
# UUID=...  /  ext4  defaults,noatime,discard  0  1
```

#### Partition NTFS en lecture seule

```bash
# Windows pas éteint proprement (hibernation)
# Démonter et remonter avec option remove_hiberfile
sudo umount /mnt/windows
sudo mount -t ntfs-3g -o remove_hiberfile /dev/sda3 /mnt/windows

# Ou désactiver l'hibernation sous Windows
```

---

### 🔐 Bonnes pratiques de sécurité

1. **Toujours démonter avant de débrancher**
    
    ```bash
    sync && sudo umount /mnt/usb
    ```
    
2. **Sauvegarder avant toute opération de partitionnement**
    
    ```bash
    sudo dd if=/dev/sdb of=/backup/sdb_table.img bs=512 count=1
    ```
    
3. **Tester fstab avant redémarrage**
    
    ```bash
    sudo mount -a  # Si erreur, corriger avant reboot
    ```
    
4. **Utiliser UUID plutôt que /dev/sdX dans fstab**
    
    ```bash
    # Bon
    UUID=abc-123  /mnt/data  ext4  defaults  0  2
    
    # Mauvais
    /dev/sdb1  /mnt/data  ext4  defaults  0  2
    ```
    
5. **Appliquer les options de sécurité appropriées**
    
    ```bash
    /home     → nosuid,nodev
    /tmp      → noexec,nosuid,nodev
    Données   → noauto (montage manuel)
    ```
    
6. **Surveiller la santé des disques**
    
    ```bash
    sudo smartctl -H /dev/sda  # Régulièrement
    ```
    
7. **Vérifier les systèmes de fichiers périodiquement**
    
    ```bash
    # En mode rescue/single user
    sudo fsck -f /dev/sdb1
    ```
    
8. **Documenter vos partitions**
    
    ```bash
    # Commentaires dans fstab
    # /mnt/data - Disque 2To Seagate ajouté le 2024-01-15
    UUID=...  /mnt/data  ext4  defaults  0  2
    ```
    

---

### ⚡ Optimisations de performance

#### Pour SSD

```bash
# Options fstab optimales pour SSD
UUID=...  /  ext4  defaults,noatime,discard  0  1

# Désactiver vérifications fsck périodiques
sudo tune2fs -c 0 -i 0 /dev/sdb1

# Activer TRIM automatique
sudo systemctl enable fstrim.timer
```

#### Pour disques mécaniques

```bash
# Options fstab
UUID=...  /mnt/data  ext4  defaults,noatime,commit=60  0  2

# commit=60 : Écrit le cache toutes les 60s (défaut 5s)
```

#### Pour serveurs de fichiers

```bash
# XFS avec options optimales
UUID=...  /srv/data  xfs  defaults,noatime,logbufs=8,largeio  0  2
```

#### Pour partitions /tmp

```bash
# tmpfs en RAM (rapide mais volatile)
tmpfs  /tmp  tmpfs  defaults,noatime,nosuid,nodev,noexec,mode=1777,size=2G  0  0
```

---

### 🎓 Concepts avancés à connaître

#### LVM (Logical Volume Manager)

> [!info] LVM Couche d'abstraction entre partitions physiques et système de fichiers. Permet redimensionnement à chaud, snapshots, etc. Sujet avancé non couvert ici.

#### RAID logiciel

> [!info] RAID Combinaison de plusieurs disques pour redondance (RAID 1, 10) ou performance (RAID 0, 5). Géré par `mdadm` sous Linux.

#### Encryption (LUKS)

> [!info] Chiffrement LUKS (Linux Unified Key Setup) permet de chiffrer des partitions entières. Nécessite `cryptsetup`.

#### Quotas disque

> [!info] Quotas Limitation d'espace disque par utilisateur ou groupe. Activé avec options `usrquota,grpquota` dans fstab.

---

## 🏁 Points clés à retenir

> [!tip] Les commandements du partitionnement
> 
> 1. **Toujours sauvegarder** avant de modifier les partitions
> 2. **Utiliser UUID** dans /etc/fstab, jamais /dev/sdX
> 3. **Tester fstab** avec `mount -a` avant de redémarrer
> 4. **Démonter proprement** avant de débrancher (sync + umount)
> 5. **Vérifier deux fois** avant d'exécuter dd, mkfs, ou wipefs
> 6. **Privilégier GPT** sur MBR pour les nouveaux systèmes
> 7. **Préférer ext4** sauf besoin spécifique
> 8. **Documenter** vos partitions et choix dans fstab
> 9. **Surveiller SMART** pour anticiper les pannes
> 10. **Tester en VM** avant les opérations critiques

---

## 🎯 Résumé en une page

### Processus complet d'ajout d'un disque

```bash
# 1. VISUALISATION
lsblk -f                              # Vue d'ensemble
sudo fdisk -l /dev/sdb                # Détails du disque

# 2. PARTITIONNEMENT
sudo cfdisk /dev/sdb                  # Interface visuelle
# → Créer table GPT → New → Taille → Write → Quit
sudo partprobe /dev/sdb               # Informer kernel

# 3. FORMATAGE
sudo mkfs.ext4 -L "MonLabel" /dev/sdb1  # Créer système de fichiers

# 4. MONTAGE TEMPORAIRE (test)
sudo mkdir -p /mnt/data               # Point de montage
sudo mount /dev/sdb1 /mnt/data        # Monter
df -h /mnt/data                       # Vérifier

# 5. MONTAGE PERMANENT
sudo blkid /dev/sdb1                  # Noter UUID
sudo nano /etc/fstab                  # Éditer fstab
# Ajouter : UUID=... /mnt/data ext4 defaults,noatime 0 2
sudo mount -a                         # Tester fstab
df -h /mnt/data                       # Vérifier final
```

### Hiérarchie des commandes par fréquence d'usage

**Quotidien :**

- `lsblk`, `df -h`, `mount`, `umount`

**Régulier (ajout/retrait matériel) :**

- `fdisk -l`, `blkid`, `cfdisk`, `mkfs.ext4`

**Occasionnel (maintenance) :**

- `fsck`, `tune2fs`, `resize2fs`, `parted`

**Rare (troubleshooting) :**

- `lsof`, `fuser`, `wipefs`, `dd`, `smartctl`

---

**🎉 Félicitations ! Vous maîtrisez maintenant le partitionnement, formatage et montage sur Linux !**