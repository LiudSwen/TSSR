# 

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

## 🎯 Introduction au partitionnement

Le partitionnement consiste à diviser un disque physique en plusieurs sections logiques indépendantes appelées **partitions**. Chaque partition peut être formatée avec un système de fichiers différent et montée séparément dans l'arborescence Linux.

> [!info] Pourquoi partitionner ?
> 
> - **Séparation des données** : isoler le système des données utilisateurs
> - **Multi-boot** : installer plusieurs systèmes d'exploitation
> - **Sécurité** : limiter l'impact d'un remplissage de disque
> - **Performance** : optimiser selon les usages (SSD vs HDD)
> - **Sauvegarde** : faciliter les sauvegardes ciblées

### Concepts clés

**Disque physique** : `/dev/sda`, `/dev/nvme0n1`, `/dev/vda` **Partitions** : `/dev/sda1`, `/dev/sda2`, `/dev/nvme0n1p1`

> [!warning] Attention Le partitionnement détruit les données existantes. Toujours faire une sauvegarde avant toute modification !

---

## ⚖️ Différences MBR vs GPT

### MBR (Master Boot Record)

Standard historique créé dans les années 1980 pour IBM PC.

**Caractéristiques techniques :**

- Table de partition stockée dans le **premier secteur** du disque (512 octets)
- Maximum **4 partitions primaires**
- Possibilité de créer une partition étendue contenant des partitions logiques
- Limite de taille de disque : **2 To**
- Limite de taille de partition : **2 To**
- Compatible avec les anciens BIOS

**Structure :**

```
┌─────────────────────────────────────────┐
│  MBR (512 octets)                       │
│  ├─ Boot loader (446 octets)            │
│  ├─ Table de partition (64 octets)      │
│  └─ Signature (2 octets)                │
├─────────────────────────────────────────┤
│  Partition 1                            │
├─────────────────────────────────────────┤
│  Partition 2                            │
└─────────────────────────────────────────┘
```

### GPT (GUID Partition Table)

Standard moderne faisant partie de l'UEFI, remplaçant progressivement le MBR.

**Caractéristiques techniques :**

- Table de partition au **début ET à la fin** du disque (redondance)
- Maximum **128 partitions** par défaut (extensible)
- Support de disques jusqu'à **9,4 Zo** (zettaoctets)
- Checksums CRC32 pour détecter les corruptions
- Identifiants GUID uniques pour chaque partition
- MBR protecteur pour compatibilité avec anciens outils
- Requis pour UEFI sur disques > 2 To

**Structure :**

```
┌─────────────────────────────────────────┐
│  MBR protecteur (compatibilité)         │
├─────────────────────────────────────────┤
│  En-tête GPT primaire                   │
├─────────────────────────────────────────┤
│  Table de partitions GPT                │
├─────────────────────────────────────────┤
│  Partition 1                            │
├─────────────────────────────────────────┤
│  Partition 2                            │
├─────────────────────────────────────────┤
│  ...                                    │
├─────────────────────────────────────────┤
│  Table de partitions GPT (copie)        │
├─────────────────────────────────────────┤
│  En-tête GPT secondaire                 │
└─────────────────────────────────────────┘
```

### Tableau comparatif

|Critère|MBR|GPT|
|---|---|---|
|**Année**|1983|2000|
|**Taille max disque**|2 To|9,4 Zo|
|**Nombre de partitions**|4 primaires (+logiques)|128 par défaut|
|**Redondance**|Non|Oui (en-têtes dupliqués)|
|**Détection corruption**|Non|Oui (CRC32)|
|**Boot UEFI**|Non|Oui|
|**Boot BIOS**|Oui|Oui (via MBR protecteur)|
|**Identifiants uniques**|Non|Oui (GUID)|

> [!tip] Quel format choisir ?
> 
> - **GPT** : pour les nouveaux systèmes, disques > 2 To, boot UEFI
> - **MBR** : pour la compatibilité avec très vieux systèmes BIOS, disques < 2 To

---

## 🔧 Partitionnement MBR avec fdisk

`fdisk` est l'outil classique pour gérer les partitions MBR. Il fonctionne en mode interactif.

### Lancer fdisk

```bash
# Lister tous les disques et partitions
sudo fdisk -l

# Ouvrir fdisk sur un disque spécifique
sudo fdisk /dev/sdb
```

> [!warning] Changements non appliqués immédiatement Avec `fdisk`, les modifications restent en mémoire jusqu'à la commande `w` (write). Vous pouvez annuler avec `q` (quit sans sauvegarder).

### Commandes interactives fdisk

Une fois dans fdisk, voici les commandes principales :

```bash
# Afficher l'aide
m

# Afficher la table de partitions actuelle
p

# Créer une nouvelle partition
n
  # Ensuite : choisir primaire (p) ou étendue (e)
  # Puis : numéro de partition (1-4)
  # Puis : premier secteur (Enter pour défaut)
  # Puis : dernier secteur ou taille (+500M, +2G, etc.)

# Supprimer une partition
d
  # Puis : numéro de partition à supprimer

# Changer le type de partition
t
  # Puis : numéro de partition
  # Puis : code hexadécimal (L pour lister les codes)

# Lister les types de partitions
l

# Créer une nouvelle table de partitions (EFFACE TOUT)
o   # pour MBR

# Écrire les changements et quitter
w

# Quitter sans sauvegarder
q

# Vérifier la table de partitions
v
```

### Codes de type de partition courants

|Code|Type|Usage|
|---|---|---|
|**83**|Linux|Système de fichiers Linux standard|
|**82**|Linux swap|Partition d'échange mémoire|
|**8e**|Linux LVM|Volume LVM|
|**fd**|Linux raid|Partition RAID logiciel|
|**ef**|EFI System|Partition système EFI (GPT)|
|**7**|NTFS|Windows|

### Exemple pratique complet

```bash
# 1. Vérifier les disques disponibles
sudo fdisk -l

# 2. Ouvrir le disque /dev/sdb
sudo fdisk /dev/sdb

# Dans fdisk :
# 3. Créer une nouvelle table de partitions MBR
Command: o
# Created a new DOS disklabel

# 4. Créer une partition primaire de 500M
Command: n
Partition type: p
Partition number (1-4): 1
First sector: [Enter]
Last sector: +500M

# 5. Créer une partition primaire de 2G pour swap
Command: n
Partition type: p
Partition number (1-4): 2
First sector: [Enter]
Last sector: +2G

# 6. Changer le type de la partition 2 en swap
Command: t
Partition number: 2
Hex code: 82

# 7. Créer une partition avec le reste de l'espace
Command: n
Partition type: p
Partition number (1-4): 3
First sector: [Enter]
Last sector: [Enter]

# 8. Afficher la table finale
Command: p

# 9. Vérifier
Command: v

# 10. Écrire les changements
Command: w
# The partition table has been altered.
```

> [!example] Résultat attendu
> 
> ```
> Device     Boot   Start      End  Sectors  Size Id Type
> /dev/sdb1          2048  1026047  1024000  500M 83 Linux
> /dev/sdb2       1026048  5220351  4194304    2G 82 Linux swap
> /dev/sdb3       5220352 20971519 15751168  7.5G 83 Linux
> ```

### Commandes post-partitionnement

```bash
# Forcer le noyau à relire la table de partitions
sudo partprobe /dev/sdb

# Ou alternativement
sudo blockdev --rereadpt /dev/sdb

# Vérifier que les partitions sont reconnues
lsblk /dev/sdb
```

> [!tip] Astuce pour les débutants Utilisez d'abord `fdisk` avec `q` (quit sans sauvegarder) pour vous entraîner. Examinez le résultat avec `p`, puis quittez. Une fois à l'aise, utilisez `w` pour appliquer.

### Pièges courants avec fdisk

> [!warning] Partitions étendues et logiques
> 
> - Vous ne pouvez avoir que **4 partitions primaires** maximum
> - Si vous avez besoin de plus, créez 3 primaires + 1 étendue
> - Dans l'étendue, créez des partitions logiques (numéros 5+)
> - Les numéros 1-4 sont réservés aux primaires/étendues

```bash
# Exemple avec partition étendue
Command: n
Partition type: e  # étendue
Partition number: 4

# Puis créer des logiques dedans
Command: n
# Automatiquement logique (numéro 5)
```

---

## 🆕 Partitionnement GPT avec gdisk

`gdisk` est l'équivalent de fdisk pour les tables de partitions GPT. L'interface est très similaire.

### Lancer gdisk

```bash
# Afficher les informations sur les disques
sudo gdisk -l /dev/sdb

# Ouvrir gdisk sur un disque
sudo gdisk /dev/sdb
```

### Commandes interactives gdisk

L'interface est quasiment identique à fdisk :

```bash
# Afficher l'aide
?

# Afficher la table de partitions GPT
p

# Créer une nouvelle partition
n
  # Numéro de partition (Enter pour suivant)
  # Premier secteur (Enter pour défaut)
  # Dernier secteur ou taille (+10G, +500M)
  # Code de type de partition (Enter pour Linux par défaut)

# Supprimer une partition
d

# Changer le type de partition
t
  # Numéro de partition
  # Code (L pour lister)

# Lister les codes de type
l

# Créer une nouvelle table GPT (EFFACE TOUT)
o

# Écrire et quitter
w

# Quitter sans sauvegarder
q

# Vérifier l'intégrité
v

# Afficher des infos détaillées
i
  # Numéro de partition
```

### Codes de type GPT courants

|Code|Type|Usage|
|---|---|---|
|**8300**|Linux filesystem|Partition Linux standard|
|**8200**|Linux swap|Swap Linux|
|**8e00**|Linux LVM|Volume LVM|
|**ef00**|EFI System|Partition système EFI/ESP|
|**ef02**|BIOS boot|Pour GRUB sur GPT avec BIOS|
|**fd00**|Linux RAID|RAID logiciel|
|**0700**|Microsoft basic data|NTFS/exFAT|

### Exemple pratique GPT complet

```bash
# 1. Ouvrir gdisk
sudo gdisk /dev/sdc

# Dans gdisk :
# 2. Créer une nouvelle table GPT
Command: o
# This option deletes all partitions and creates a new protective MBR and a new GPT

# 3. Créer une partition EFI de 512M (pour boot UEFI)
Command: n
Partition number: 1
First sector: [Enter]
Last sector: +512M
Hex code or GUID: ef00

# 4. Créer une partition swap de 4G
Command: n
Partition number: 2
First sector: [Enter]
Last sector: +4G
Hex code: 8200

# 5. Créer une partition Linux avec le reste
Command: n
Partition number: 3
First sector: [Enter]
Last sector: [Enter]
Hex code: 8300  # ou Enter (défaut)

# 6. Afficher la table
Command: p

# 7. Vérifier
Command: v

# 8. Écrire les changements
Command: w
# Do you want to proceed? (Y/N): y
```

> [!example] Résultat attendu
> 
> ```
> Number  Start (sector)    End (sector)  Size       Code  Name
>    1            2048         1050623   512.0 MiB   EF00  EFI System
>    2         1050624         9439231   4.0 GiB     8200  Linux swap
>    3         9439232       125829086   55.5 GiB    8300  Linux filesystem
> ```

### Commandes avancées gdisk

```bash
# Afficher les informations détaillées d'une partition
Command: i
Partition number: 1

# Backup de la table GPT
sudo gdisk /dev/sdc
Command: b
# Fichier de backup créé

# Restaurer depuis un backup
sudo gdisk /dev/sdc
Command: l
# Puis charger le fichier

# Convertir MBR vers GPT (avec préservation des données)
sudo gdisk /dev/sdc
Command: w
# gdisk détecte le MBR et propose la conversion
```

> [!tip] Conversion MBR vers GPT `gdisk` peut convertir un disque MBR en GPT en préservant les données. Cependant, faites **toujours une sauvegarde** avant !

### Spécificités GPT importantes

> [!info] Partition EFI System (ESP) Pour booter en UEFI, vous **devez** créer une partition ESP :
> 
> - Type : `ef00` (EFI System)
> - Taille recommandée : 512M à 1G
> - Formatage : FAT32
> - Point de montage : `/boot/efi`

```bash
# Après création de la partition ESP avec gdisk
sudo mkfs.fat -F32 /dev/sdc1
```

---

## 🛠️ Partitionnement avec parted

`parted` est un outil de partitionnement qui supporte **à la fois MBR et GPT**. Contrairement à fdisk/gdisk, il applique les changements **immédiatement** (pas de "write").

### Modes d'utilisation

```bash
# Mode interactif
sudo parted /dev/sdd

# Mode ligne de commande (scriptable)
sudo parted /dev/sdd commande arguments
```

> [!warning] Changements immédiats ! Avec `parted`, chaque commande s'exécute immédiatement. Il n'y a pas de "undo" possible. Soyez prudent !

### Commandes principales parted

#### En mode interactif

```bash
sudo parted /dev/sdd

# Afficher l'aide
(parted) help

# Afficher la table de partitions
(parted) print

# Afficher tous les disques
(parted) print all

# Afficher l'espace libre
(parted) print free

# Créer une nouvelle table de partitions
(parted) mklabel gpt    # pour GPT
(parted) mklabel msdos  # pour MBR

# Créer une partition
(parted) mkpart nom_type système_fichiers début fin
# Exemples :
(parted) mkpart primary ext4 1MiB 512MiB
(parted) mkpart primary linux-swap 512MiB 4GiB
(parted) mkpart primary ext4 4GiB 100%

# Supprimer une partition
(parted) rm numéro

# Redimensionner une partition (si système de fichiers le permet)
(parted) resizepart numéro fin

# Définir les flags
(parted) set numéro flag état
(parted) set 1 boot on
(parted) set 1 esp on

# Changer l'unité d'affichage
(parted) unit MiB
(parted) unit GiB
(parted) unit %

# Aligner les partitions (performance)
(parted) align-check optimal numéro

# Quitter
(parted) quit
```

### Syntaxe des positions

|Format|Exemple|Signification|
|---|---|---|
|**MiB, GiB**|`1MiB`, `10GiB`|Unités binaires (1024)|
|**MB, GB**|`1MB`, `10GB`|Unités décimales (1000)|
|**%**|`50%`, `100%`|Pourcentage du disque|
|**s**|`2048s`|Numéro de secteur|

> [!tip] Utiliser des unités binaires Préférez `MiB`, `GiB` plutôt que `MB`, `GB` pour éviter les confusions entre standards.

### Exemple pratique avec parted

#### Approche interactive

```bash
# 1. Lancer parted
sudo parted /dev/sdd

# 2. Afficher l'état actuel
(parted) print

# 3. Créer une table GPT
(parted) mklabel gpt
Warning: The existing disk label on /dev/sdd will be destroyed...
Yes/No? yes

# 4. Créer une partition EFI de 512MiB
(parted) mkpart EFI fat32 1MiB 513MiB
(parted) set 1 esp on

# 5. Créer une partition swap de 4GiB
(parted) mkpart swap linux-swap 513MiB 4609MiB

# 6. Créer une partition root avec le reste
(parted) mkpart root ext4 4609MiB 100%

# 7. Vérifier
(parted) print
(parted) print free

# 8. Vérifier l'alignement
(parted) align-check optimal 1
(parted) align-check optimal 2
(parted) align-check optimal 3

# 9. Quitter
(parted) quit
```

#### Approche en ligne de commande

```bash
# Tout en une seule série de commandes
sudo parted /dev/sdd --script \
  mklabel gpt \
  mkpart EFI fat32 1MiB 513MiB \
  set 1 esp on \
  mkpart swap linux-swap 513MiB 4609MiB \
  mkpart root ext4 4609MiB 100%

# Vérifier le résultat
sudo parted /dev/sdd print
```

> [!tip] Script automation La syntaxe `--script` est idéale pour automatiser le partitionnement dans des scripts d'installation.

### Types de partitions parted

Pour GPT, les noms sont libres. Voici les conventions courantes :

|Nom|Type système|Usage|
|---|---|---|
|**EFI**|fat32|Partition EFI System|
|**boot**|ext4|Partition /boot|
|**root**|ext4/xfs/btrfs|Partition racine /|
|**home**|ext4/xfs/btrfs|Partition /home|
|**swap**|linux-swap|Swap|
|**data**|ext4/xfs|Données|

### Flags disponibles

```bash
# Lister les flags disponibles
(parted) help set

# Flags courants :
# boot     : partition bootable (MBR)
# esp      : EFI System Partition (GPT)
# lvm      : partition LVM
# raid     : partition RAID
# swap     : partition swap

# Exemples
(parted) set 1 boot on   # MBR
(parted) set 1 esp on    # GPT
```

### Redimensionnement avec parted

> [!warning] Limitations du redimensionnement `parted` peut redimensionner la **partition** mais pas toujours le **système de fichiers**. Utilisez les outils spécifiques après :
> 
> - `resize2fs` pour ext2/ext3/ext4
> - `xfs_growfs` pour XFS
> - `btrfs filesystem resize` pour Btrfs

```bash
# 1. Redimensionner la partition
sudo parted /dev/sdd
(parted) resizepart 3 80GiB
(parted) quit

# 2. Redimensionner le système de fichiers
sudo resize2fs /dev/sdd3   # pour ext4
# ou
sudo xfs_growfs /montage   # pour XFS
```

### Alignement des partitions

L'alignement est crucial pour les performances, particulièrement avec les SSD.

```bash
# Vérifier l'alignement
sudo parted /dev/sdd
(parted) align-check optimal 1
# 1 aligned

# Spécifier l'alignement au démarrage
(parted) unit s
(parted) mkpart primary 2048s 1050623s
```

> [!info] Pourquoi l'alignement est important
> 
> - Les SSD utilisent des pages de 4K ou plus
> - Un mauvais alignement cause des écritures supplémentaires
> - Perte de performance jusqu'à 30-50% sur SSD
> - `parted` aligne automatiquement sur 1MiB par défaut

---

## ✅ Bonnes pratiques

### Choix du schéma de partitionnement

> [!tip] Recommandations modernes **Pour un système standard :**
> 
> - `/boot/efi` : 512M (type EFI, FAT32) si UEFI
> - `swap` : 2-4G ou égal à la RAM si hibernation
> - `/` : 25-50G minimum
> - `/home` : le reste (ou partition séparée)
> 
> **Pour un serveur :**
> 
> - `/boot` : 512M-1G
> - `swap` : selon charge
> - `/` : 20-30G
> - `/var` : 10-20G+ (logs, bases de données)
> - `/home` : selon besoins
> - `/srv` ou `/data` : données applicatives

### Début de partition recommandé

```bash
# Toujours commencer à 1MiB pour alignement optimal
# MBR : secteur 2048 (1MiB)
# GPT : 1MiB après l'en-tête GPT

# Avec fdisk/gdisk : accepter la valeur par défaut
# Avec parted : spécifier 1MiB explicitement
```

### Sauvegarde et sécurité

> [!warning] Précautions essentielles
> 
> ```bash
> # 1. TOUJOURS sauvegarder avant de partitionner
> sudo dd if=/dev/sdb of=~/backup_mbr.img bs=512 count=1    # MBR
> sudo dd if=/dev/sdb of=~/backup_gpt.img bs=512 count=34   # GPT header
> 
> # 2. Sauvegarder la table complète
> sudo sfdisk -d /dev/sdb > ~/backup_partition_table.txt    # MBR
> sudo sgdisk --backup=~/backup_gpt_table.bin /dev/sdb      # GPT
> 
> # 3. Noter les UUID avant modification
> sudo blkid > ~/backup_uuid.txt
> ```

### Vérification post-partitionnement

```bash
# 1. Relire la table de partitions
sudo partprobe /dev/sdb

# 2. Vérifier avec plusieurs outils
lsblk /dev/sdb
sudo fdisk -l /dev/sdb
sudo parted /dev/sdb print

# 3. Vérifier que le noyau voit les partitions
ls -l /dev/sdb*
cat /proc/partitions

# 4. Vérifier l'alignement (important pour SSD)
sudo parted /dev/sdb
(parted) align-check optimal 1
```

### Comparaison des outils

|Critère|fdisk|gdisk|parted|
|---|---|---|---|
|**Format**|MBR|GPT|MBR + GPT|
|**Interface**|Interactive|Interactive|Les deux|
|**Changements**|Différés|Différés|Immédiats|
|**Scriptable**|Non|Non|Oui|
|**Redimensionnement**|Non|Non|Oui|
|**Alignement auto**|Non|Oui|Oui|
|**Facilité**|★★★★|★★★★|★★★|

> [!tip] Quel outil choisir ?
> 
> - **fdisk** : disques MBR, simplicité, compatibilité maximale
> - **gdisk** : disques GPT, conversion MBR→GPT, vérifications avancées
> - **parted** : scripting, redimensionnement, support universel MBR/GPT

### Erreurs courantes à éviter

> [!warning] Pièges fréquents
> 
> 1. **Ne pas sauvegarder** avant de partitionner
> 2. **Oublier partprobe** après modification (ou redémarrer)
> 3. **Mixer fdisk et gdisk** sur le même disque
> 4. **Créer une partition EFI en MBR** (ne fonctionne pas)
> 5. **Partitionner un disque monté** (démonter d'abord)
> 6. **Ignorer l'alignement** sur les SSD
> 7. **Confondre numéros** de partition (/dev/sda1 vs /dev/sda2)
> 8. **Oublier le type de partition** (swap doit être type 82/8200)

### Workflow recommandé

```bash
# 1. Identifier le disque cible
lsblk
sudo fdisk -l

# 2. Sauvegarder (si données existantes)
sudo dd if=/dev/sdb of=~/backup.img bs=4M status=progress

# 3. Démonter toutes les partitions du disque
sudo umount /dev/sdb*

# 4. Choisir l'outil approprié
# - fdisk pour MBR simple
# - gdisk pour GPT
# - parted pour automatisation ou redimensionnement

# 5. Créer le schéma de partitionnement
sudo gdisk /dev/sdb
# ... commandes de partitionnement ...

# 6. Vérifier avant d'écrire
Command: p
Command: v

# 7. Écrire les changements
Command: w

# 8. Forcer la relecture
sudo partprobe /dev/sdb

# 9. Vérifier le résultat
lsblk /dev/sdb
sudo gdisk -l /dev/sdb

# 10. Procéder au formatage (étape suivante, non détaillée ici)
```

### Considérations SSD vs HDD

> [!info] Optimisations spécifiques **Pour SSD :**
> 
> - Toujours aligner sur 1MiB minimum
> - Utiliser GPT (support TRIM natif)
> - Laisser 10-20% d'espace non partitionné (over-provisioning)
> 
> **Pour HDD :**
> 
> - L'alignement reste important mais moins critique
> - MBR acceptable pour disques < 2To
> - Pas besoin d'over-provisioning

### Vérification de l'intégrité

```bash
# Vérifier les checksums GPT
sudo gdisk /dev/sdb
Command: v
# Problem: The CRC for the backup GPT header is invalid...
# → Si erreurs, GPT corrompu

# Tester la lisibilité des secteurs
sudo badblocks -v /dev/sdb

# Vérifier les attributs SMART (santé du disque)
sudo smartctl -a /dev/sdb
```

---

## 📝 Résumé des commandes essentielles

### Identification et listage

```bash
lsblk                           # Afficher tous les disques et partitions
sudo fdisk -l                   # Lister détails de tous les disques
sudo blkid                      # Afficher UUID et types de toutes les partitions
cat /proc/partitions            # Partitions vues par le noyau
```

### Partitionnement MBR

```bash
sudo fdisk /dev/sdX            # Ouvrir fdisk sur un disque
  o                            # Créer nouvelle table MBR
  n                            # Nouvelle partition
  t                            # Changer le type
  d                            # Supprimer partition
  p                            # Afficher table
  w                            # Écrire et quitter
```

### Partitionnement GPT

```bash
sudo gdisk /dev/sdX            # Ouvrir gdisk sur un disque
  o                            # Créer nouvelle table GPT
  n                            # Nouvelle partition
  t                            # Changer le type
  d                            # Supprimer partition
  p                            # Afficher table
  w                            # Écrire et quitter
  q                            # Quitter sans sauvegarder
```

### Partitionnement avec parted

```bash
sudo parted /dev/sdX           # Ouvrir parted (mode interactif)
  mklabel gpt                  # Créer table GPT
  mklabel msdos                # Créer table MBR
  mkpart NOM TYPE DEBUT FIN    # Créer partition
  rm NUMERO                    # Supprimer partition
  print                        # Afficher table
  print free                   # Afficher espace libre
  set NUMERO FLAG on           # Activer un flag
  align-check optimal NUMERO   # Vérifier alignement
  quit                         # Quitter

# Mode ligne de commande (scriptable)
sudo parted /dev/sdX --script mklabel gpt mkpart primary ext4 1MiB 100%
```

### Post-partitionnement

```bash
sudo partprobe /dev/sdX        # Forcer relecture table de partitions
sudo blockdev --rereadpt /dev/sdX  # Alternative pour relecture
lsblk /dev/sdX                 # Vérifier les nouvelles partitions
```

---

## 🎓 Points clés à retenir

> [!info] Synthèse
> 
> - **MBR** : ancien standard, limité à 2 To et 4 partitions primaires
> - **GPT** : standard moderne, support jusqu'à 128 partitions et disques géants
> - **fdisk** : pour MBR, interface interactive, changements différés
> - **gdisk** : pour GPT, similaire à fdisk, avec vérifications CRC
> - **parted** : universel MBR/GPT, scriptable, changements immédiats
> - Toujours commencer les partitions à **1MiB** pour alignement optimal
> - **Sauvegarder** avant toute opération de partitionnement
> - Utiliser **partprobe** après modification pour éviter un redémarrage
> - Les partitions EFI (type ef00) sont **obligatoires** pour boot UEFI

---

**📌 Nota Bene** : Ce cours couvre uniquement le partitionnement. Le formatage des partitions et leur montage seront abordés dans d'autres sections du cours d'administration Linux.