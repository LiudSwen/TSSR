

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

La visualisation des disques est la première étape essentielle avant toute opération de partitionnement ou de gestion du stockage. Ces commandes permettent d'identifier les périphériques disponibles, leur structure, leurs caractéristiques et leurs identifiants uniques.

> [!info] Pourquoi c'est important Avant de manipuler des disques (partition, formatage, montage), il est crucial de bien identifier les périphériques pour éviter toute erreur destructive. Une mauvaise identification peut entraîner la perte de données critiques.

---

## lsblk - Visualiser la structure en arbre

### 📖 Description

`lsblk` (list block devices) affiche les périphériques de bloc sous forme d'arborescence hiérarchique. C'est l'outil le plus intuitif pour comprendre rapidement la structure des disques et leurs partitions.

### 🎯 Quand l'utiliser

- Pour obtenir une vue d'ensemble rapide de tous les disques
- Pour identifier la hiérarchie disque → partition → point de montage
- Pour vérifier l'état de montage des partitions
- Lors d'un diagnostic initial du système de stockage

### 📝 Syntaxe de base

```bash
# Affichage standard
lsblk

# Affichage avec tous les détails
lsblk -a

# Affichage sans périphériques esclaves (boucles, etc.)
lsblk -d

# Format personnalisé avec colonnes spécifiques
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE

# Affichage en octets bruts (pas d'unités humaines)
lsblk -b

# Inclure les partitions vides
lsblk -p  # Affiche les chemins complets (/dev/sda au lieu de sda)
```

### 💡 Options principales

|Option|Description|Exemple d'usage|
|---|---|---|
|`-a`|Affiche tous les périphériques, y compris vides|`lsblk -a`|
|`-b`|Taille en octets bruts|`lsblk -b`|
|`-d`|Affiche uniquement les disques (pas les partitions)|`lsblk -d`|
|`-f`|Affiche les informations sur les systèmes de fichiers|`lsblk -f`|
|`-m`|Affiche les permissions des périphériques|`lsblk -m`|
|`-o`|Spécifie les colonnes à afficher|`lsblk -o NAME,SIZE,TYPE`|
|`-p`|Affiche les chemins complets|`lsblk -p`|
|`-t`|Affiche les informations sur la topologie|`lsblk -t`|

### 🔍 Colonnes importantes

```bash
# Colonnes par défaut
NAME    # Nom du périphérique
MAJ:MIN # Numéros majeur:mineur du périphérique
RM      # Périphérique amovible (1 = oui, 0 = non)
SIZE    # Taille du périphérique
RO      # Lecture seule (1 = oui, 0 = non)
TYPE    # Type (disk, part, lvm, etc.)
MOUNTPOINT # Point de montage actuel

# Colonnes supplémentaires utiles avec -o
FSTYPE  # Type de système de fichiers (ext4, xfs, swap, etc.)
UUID    # Identifiant unique universel
LABEL   # Étiquette de la partition
MODEL   # Modèle du disque
SERIAL  # Numéro de série
STATE   # État du périphérique
OWNER   # Propriétaire du périphérique
GROUP   # Groupe du périphérique
MODE    # Permissions
```

### 📋 Exemples pratiques

```bash
# Vue complète avec système de fichiers
lsblk -f

# Résultat typique :
# NAME   FSTYPE LABEL UUID                                 MOUNTPOINT
# sda                                                      
# ├─sda1 vfat         1234-5678                            /boot/efi
# ├─sda2 ext4         a1b2c3d4-e5f6-7890-abcd-ef1234567890 /
# └─sda3 swap         98765432-1234-5678-90ab-cdef12345678 [SWAP]

# Afficher uniquement les disques avec leur taille
lsblk -d -o NAME,SIZE,TYPE,MODEL

# Afficher les permissions et propriétaires
lsblk -m

# Format JSON pour scripts
lsblk --json
lsblk --json -o NAME,SIZE,TYPE,MOUNTPOINT

# Format liste (pas d'arbre) pour parsing
lsblk -l
```

> [!example] Exemple de sortie détaillée
> 
> ```bash
> $ lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,UUID
> NAME   SIZE TYPE MOUNTPOINT FSTYPE UUID
> sda    100G disk                   
> ├─sda1 512M part /boot/efi  vfat   1A2B-3C4D
> ├─sda2  80G part /          ext4   a1b2c3d4-...
> └─sda3  19G part [SWAP]     swap   98765432-...
> sdb    500G disk                   
> └─sdb1 500G part /data      ext4   e5f6g7h8-...
> ```

### ⚠️ Pièges courants

> [!warning] Attention aux périphériques de boucle `lsblk` affiche aussi les périphériques loop (snaps, images montées). Utilisez `-d` pour ne voir que les disques physiques ou filtrez avec `grep -v loop`.

> [!warning] Lecture seule vs montage read-only La colonne `RO` indique si le périphérique est en lecture seule au niveau matériel, pas si le montage est en read-only. Vérifiez les options de montage avec `mount` ou `findmnt`.

### 💎 Astuces

> [!tip] Surveillance en temps réel Bien que `lsblk` ne soit pas dynamique, vous pouvez le surveiller avec `watch` :
> 
> ```bash
> watch -n 2 lsblk
> ```

> [!tip] Filtrage par type Pour voir uniquement certains types de périphériques :
> 
> ```bash
> lsblk | grep disk    # Uniquement les disques
> lsblk | grep part    # Uniquement les partitions
> lsblk | grep -v loop # Exclure les loops
> ```

---

## fdisk -l - Lister les disques détaillés

### 📖 Description

`fdisk -l` (list) affiche des informations détaillées sur tous les disques et leurs partitions, incluant la table de partitionnement, les secteurs, et la géométrie des disques. C'est un outil plus technique que `lsblk`.

### 🎯 Quand l'utiliser

- Pour obtenir des informations détaillées sur la géométrie des disques
- Pour voir le type de table de partitionnement (MBR/GPT)
- Pour identifier les secteurs de début et fin de chaque partition
- Pour diagnostiquer des problèmes de partitionnement
- Avant et après des opérations de partitionnement pour vérifier les changements

### 📝 Syntaxe de base

```bash
# Lister tous les disques (nécessite root ou sudo)
sudo fdisk -l

# Lister un disque spécifique
sudo fdisk -l /dev/sda

# Format plus lisible avec unités en secteurs
sudo fdisk -l -u

# Exclure les périphériques RAM
sudo fdisk -l | grep -v "ram"
```

### 💡 Informations fournies

```bash
# En-tête du disque
Disk /dev/sda: 100 GiB, 107374182400 bytes, 209715200 sectors
# └─ Chemin   └─ Taille lisible  └─ Octets    └─ Secteurs totaux

Disk model: Samsung SSD 860
Units: sectors of 1 * 512 = 512 bytes
# └─ Unité d'affichage des positions (secteurs de 512 octets)

Sector size (logical/physical): 512 bytes / 512 bytes
# └─ Taille logique et physique des secteurs

I/O size (minimum/optimal): 512 bytes / 512 bytes
# └─ Taille d'E/S minimale et optimale

Disklabel type: gpt
# └─ Type de table de partitionnement (gpt ou dos pour MBR)

Disk identifier: 12345678-90AB-CDEF-1234-567890ABCDEF
# └─ Identifiant unique du disque (pour GPT)
```

### 📊 Tableau des partitions

```bash
# Colonnes du tableau de partitions
Device       Start       End   Sectors  Size Type
/dev/sda1     2048   1050623   1048576  512M EFI System
/dev/sda2  1050624 168615935 167565312   80G Linux filesystem
/dev/sda3 168615936 209713151  41097216 19.6G Linux swap

# Device    : Nom du périphérique de partition
# Start     : Secteur de début
# End       : Secteur de fin
# Sectors   : Nombre de secteurs
# Size      : Taille lisible
# Type      : Type de partition
```

### 🔍 Types de partitions courants

|Type MBR (dos)|Type GPT|Description|
|---|---|---|
|83|Linux filesystem|Partition Linux standard|
|82|Linux swap|Partition d'échange (swap)|
|8e|Linux LVM|Partition pour LVM|
|ef|EFI System|Partition système EFI (ESP)|
|7|Microsoft basic data|Partition NTFS/exFAT|
|fd|Linux RAID auto|Partition pour RAID logiciel|

### 📋 Exemples pratiques

```bash
# Lister tous les disques avec détails
sudo fdisk -l

# Lister un disque spécifique
sudo fdisk -l /dev/sda
sudo fdisk -l /dev/nvme0n1  # Pour disques NVMe

# Voir uniquement les résumés des disques
sudo fdisk -l | grep "^Disk /dev"

# Afficher avec unités en secteurs (plus précis)
sudo fdisk -l -u=sectors

# Combiner avec grep pour filtrer
sudo fdisk -l | grep -A 10 "^Disk /dev/sda"  # Disque + 10 lignes suivantes
```

> [!example] Exemple de sortie complète
> 
> ```bash
> $ sudo fdisk -l /dev/sda
> Disk /dev/sda: 100 GiB, 107374182400 bytes, 209715200 sectors
> Disk model: Samsung SSD 860
> Units: sectors of 1 * 512 = 512 bytes
> Sector size (logical/physical): 512 bytes / 512 bytes
> I/O size (minimum/optimal): 512 bytes / 512 bytes
> Disklabel type: gpt
> Disk identifier: A1B2C3D4-E5F6-7890-ABCD-EF1234567890
> 
> Device       Start       End   Sectors  Size Type
> /dev/sda1     2048   1050623   1048576  512M EFI System
> /dev/sda2  1050624 168615935 167565312   80G Linux filesystem
> /dev/sda3 168615936 209713151  41097216 19.6G Linux swap
> ```

### ⚠️ Pièges courants

> [!warning] Nécessite les privilèges root `fdisk -l` nécessite généralement `sudo` pour accéder aux informations des disques. Sans sudo, vous pourriez obtenir des résultats incomplets ou des erreurs.

> [!warning] Différence MBR vs GPT La sortie varie selon le type de table de partitionnement :
> 
> - **MBR (dos)** : Limité à 4 partitions primaires, types numérotés (83, 82, etc.)
> - **GPT** : Jusqu'à 128 partitions, types nommés explicitement

> [!warning] Numérotation des disques NVMe Les disques NVMe suivent une nomenclature différente : `/dev/nvme0n1` (disque), `/dev/nvme0n1p1` (partition). Adaptez vos commandes en conséquence.

### 💎 Astuces

> [!tip] Vérifier l'alignement des partitions Les secteurs de début devraient être alignés sur des multiples de 2048 (ou 1MiB) pour des performances optimales sur les SSD modernes. Vérifiez la colonne "Start".

> [!tip] Identifier rapidement le type de table
> 
> ```bash
> sudo fdisk -l /dev/sda | grep "Disklabel type"
> # Résultat : Disklabel type: gpt  (ou dos pour MBR)
> ```

> [!tip] Calculer l'espace non partitionné Comparez le nombre total de secteurs du disque avec le secteur "End" de la dernière partition pour voir s'il reste de l'espace libre.

---

## blkid - Identifier les partitions

### 📖 Description

`blkid` (block device identifier) affiche les attributs des périphériques de bloc, notamment les UUID, les types de systèmes de fichiers, et les étiquettes. C'est l'outil de référence pour identifier de manière unique les partitions.

### 🎯 Quand l'utiliser

- Pour obtenir l'UUID d'une partition (essentiel pour `/etc/fstab`)
- Pour identifier le type de système de fichiers d'une partition
- Pour lister toutes les partitions avec leurs identifiants uniques
- Pour vérifier l'étiquette (LABEL) d'un système de fichiers
- Avant de monter une partition pour vérifier ses caractéristiques

### 📝 Syntaxe de base

```bash
# Lister tous les périphériques avec leurs attributs
sudo blkid

# Afficher les informations d'un périphérique spécifique
sudo blkid /dev/sda1

# Rechercher par UUID
sudo blkid -U a1b2c3d4-e5f6-7890-abcd-ef1234567890

# Rechercher par LABEL
sudo blkid -L "MonDisque"

# Format de sortie personnalisé
sudo blkid -o list     # Format tableau
sudo blkid -o device   # Uniquement les noms de périphériques
sudo blkid -o value -s UUID /dev/sda1  # Uniquement la valeur UUID
```

### 💡 Attributs principaux

```bash
# Sortie typique de blkid
/dev/sda1: UUID="1A2B-3C4D" TYPE="vfat" PARTUUID="12345678-01"
/dev/sda2: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="ext4" PARTUUID="12345678-02"
/dev/sda3: UUID="98765432-1234-5678-90ab-cdef12345678" TYPE="swap" PARTUUID="12345678-03"

# Attributs disponibles :
# UUID        : Identifiant unique du système de fichiers
# TYPE        : Type de système de fichiers (ext4, xfs, vfat, swap, etc.)
# PARTUUID    : UUID de la partition (différent de l'UUID du FS)
# LABEL       : Étiquette du système de fichiers
# PARTLABEL   : Étiquette de la partition (GPT uniquement)
# PTTYPE      : Type de table de partitionnement (gpt, dos)
```

### 🔍 Différence UUID vs PARTUUID

|Attribut|Description|Utilisation|
|---|---|---|
|**UUID**|Identifiant du système de fichiers|Montage dans `/etc/fstab`, identification du contenu|
|**PARTUUID**|Identifiant de la partition elle-même|Bootloaders, identification au niveau matériel|

> [!info] Quand utiliser UUID vs PARTUUID
> 
> - **UUID** : Pour monter des systèmes de fichiers (recommandé dans `/etc/fstab`)
> - **PARTUUID** : Pour identifier des partitions avant qu'elles ne soient formatées, ou dans les configurations de bootloader

### 📋 Exemples pratiques

```bash
# Lister toutes les partitions avec leurs UUID
sudo blkid

# Obtenir uniquement l'UUID d'une partition
sudo blkid -s UUID -o value /dev/sda2
# Résultat : a1b2c3d4-e5f6-7890-abcd-ef1234567890

# Obtenir le type de système de fichiers
sudo blkid -s TYPE -o value /dev/sda2
# Résultat : ext4

# Trouver le périphérique correspondant à un UUID
sudo blkid -U a1b2c3d4-e5f6-7890-abcd-ef1234567890
# Résultat : /dev/sda2

# Format tableau pour une vue d'ensemble
sudo blkid -o list
# device         fs_type  label    mount point        UUID
# /dev/sda1      vfat              /boot/efi          1A2B-3C4D
# /dev/sda2      ext4              /                  a1b2c3d4-...
# /dev/sda3      swap              [SWAP]             98765432-...

# Afficher toutes les propriétés disponibles
sudo blkid -o full

# Filtrer par type de système de fichiers
sudo blkid | grep ext4
sudo blkid | grep swap

# Obtenir l'étiquette d'une partition
sudo blkid -s LABEL -o value /dev/sdb1
```

> [!example] Exemple d'utilisation pour /etc/fstab
> 
> ```bash
> # 1. Obtenir l'UUID de la partition
> $ sudo blkid /dev/sda2
> /dev/sda2: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="ext4"
> 
> # 2. Utiliser dans /etc/fstab
> UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890  /data  ext4  defaults  0  2
> ```

### ⚠️ Pièges courants

> [!warning] UUID vide pour partitions non formatées `blkid` ne retournera pas d'UUID pour une partition qui n'a pas encore été formatée avec un système de fichiers. Seul PARTUUID sera disponible.

> [!warning] Cache de blkid `blkid` utilise un cache. Après avoir créé ou modifié des partitions, vous pourriez avoir besoin de le rafraîchir :
> 
> ```bash
> sudo blkid -g  # Garbage collect (nettoyage du cache)
> ```

> [!warning] Différence entre périphériques Les disques entiers (`/dev/sda`) n'ont généralement pas d'UUID, seulement les partitions (`/dev/sda1`). Cependant, ils ont un PTUUID (UUID de la table de partitionnement).

### 💎 Astuces

> [!tip] Vérification rapide d'une partition Avant de monter une partition, vérifiez son type :
> 
> ```bash
> sudo blkid /dev/sdb1 && echo "Partition valide" || echo "Partition non formatée"
> ```

> [!tip] Générer des entrées /etc/fstab automatiquement
> 
> ```bash
> # Script simple pour générer une ligne fstab
> DEVICE="/dev/sda2"
> UUID=$(sudo blkid -s UUID -o value $DEVICE)
> TYPE=$(sudo blkid -s TYPE -o value $DEVICE)
> echo "UUID=$UUID  /mnt/point  $TYPE  defaults  0  2"
> ```

> [!tip] Trouver toutes les partitions swap
> 
> ```bash
> sudo blkid | grep swap
> # Utile pour identifier toutes les partitions d'échange du système
> ```

> [!tip] Vérifier si une partition est montée via UUID
> 
> ```bash
> UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890"
> findmnt -S UUID=$UUID  # Affiche le point de montage si monté
> ```

---

## Comparaison des outils

|Critère|lsblk|fdisk -l|blkid|
|---|---|---|---|
|**Vue d'ensemble**|⭐⭐⭐ Excellent|⭐⭐ Bon|⭐ Basique|
|**Hiérarchie visuelle**|⭐⭐⭐ Arborescence|⭐ Liste plate|⭐ Liste plate|
|**Détails techniques**|⭐⭐ Moyen|⭐⭐⭐ Détaillé|⭐⭐ Identifiants|
|**Points de montage**|⭐⭐⭐ Oui|❌ Non|❌ Non|
|**UUID**|⭐⭐ Avec -o|❌ Non|⭐⭐⭐ Oui|
|**Géométrie disque**|❌ Non|⭐⭐⭐ Détaillée|❌ Non|
|**Type de FS**|⭐⭐⭐ Avec -f|❌ Non|⭐⭐⭐ Oui|
|**Table de partitionnement**|❌ Non|⭐⭐⭐ Oui (type)|⭐ PTTYPE|
|**Nécessite sudo**|❌ Non (généralement)|⭐ Oui|⭐ Oui|
|**Facilité de lecture**|⭐⭐⭐ Très lisible|⭐⭐ Technique|⭐⭐ Moyen|

### 🎯 Quel outil choisir ?

```bash
# Première exploration d'un système
lsblk -f
# → Vue complète et intuitive avec montages et FS

# Avant de partitionner
sudo fdisk -l /dev/sda
# → Géométrie précise, secteurs, table de partitionnement

# Pour /etc/fstab ou scripts
sudo blkid /dev/sda2
# → UUID et TYPE pour montage persistant

# Diagnostic complet (combinaison)
lsblk -f && sudo fdisk -l && sudo blkid
```

> [!tip] Workflow recommandé
> 
> 1. **Identification initiale** : `lsblk -f` pour voir la structure
> 2. **Analyse technique** : `sudo fdisk -l` pour les détails de partitionnement
> 3. **Récupération d'UUID** : `sudo blkid` pour configuration /etc/fstab

---

## Bonnes pratiques

### ✅ Recommandations générales

> [!tip] Toujours vérifier avant de modifier Avant toute opération de partitionnement, formatage ou montage, visualisez l'état actuel avec au moins `lsblk -f` pour éviter les erreurs de périphérique.

> [!tip] Utiliser les UUID dans /etc/fstab Préférez toujours les UUID aux noms de périphériques (`/dev/sda1`) dans `/etc/fstab`. Les UUID sont stables même si l'ordre des disques change.
> 
> ```bash
> # ✅ Bon (stable)
> UUID=a1b2c3d4-... /data ext4 defaults 0 2
> 
> # ❌ À éviter (peut changer)
> /dev/sdb1 /data ext4 defaults 0 2
> ```

> [!tip] Combiner les outils N'hésitez pas à utiliser plusieurs outils pour obtenir une vue complète :
> 
> ```bash
> lsblk -f && sudo fdisk -l /dev/sda && sudo blkid /dev/sda2
> ```

> [!tip] Documenter vos disques Gardez une trace des UUID et des points de montage de vos systèmes critiques :
> 
> ```bash
> sudo blkid > ~/disk-inventory-$(date +%F).txt
> ```

### 🔒 Sécurité et prévention

> [!warning] Double vérification des périphériques Avant toute opération destructive, vérifiez DEUX FOIS le nom du périphérique. Une erreur sur `/dev/sda` au lieu de `/dev/sdb` peut être catastrophique.

> [!warning] Prudence avec les disques similaires Si vous avez plusieurs disques de même taille/modèle, identifiez-les par leur numéro de série :
> 
> ```bash
> lsblk -o NAME,SIZE,MODEL,SERIAL
> ```

### 📝 Scripts et automatisation

Lorsque vous écrivez des scripts utilisant ces commandes :

```bash
# ✅ Bon : vérifier l'existence avant d'agir
if sudo blkid /dev/sdb1 &> /dev/null; then
    UUID=$(sudo blkid -s UUID -o value /dev/sdb1)
    echo "Partition trouvée : $UUID"
else
    echo "Partition non formatée ou inexistante"
fi

# ✅ Bon : parsing robuste de lsblk
lsblk -Jpo NAME,SIZE,TYPE,MOUNTPOINT | jq -r '.blockdevices[]'

# ❌ À éviter : parsing non fiable
lsblk | grep sda | awk '{print $1}'  # Fragile face aux changements de format
```

### 🔍 Diagnostic et dépannage

> [!tip] Workflow de diagnostic
> 
> ```bash
> # 1. Vue globale
> lsblk -f
> 
> # 2. Détails d'un disque problématique
> sudo fdisk -l /dev/sda
> 
> # 3. Vérification des UUID
> sudo blkid /dev/sda*
> 
> # 4. État de montage
> findmnt
> 
> # 5. Logs système pour erreurs
> sudo dmesg | grep -i "sd[a-z]"
> ```

### 📊 Surveillance continue

Pour surveiller les disques dans le temps :

```bash
# Créer un alias pratique
echo "alias diskinfo='lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,UUID'" >> ~/.bashrc

# Surveiller les changements (utile lors de hot-plug)
watch -n 2 'lsblk'

# Logger les informations disques régulièrement
echo "0 */6 * * * lsblk -f > /var/log/disk-state.log" | sudo crontab -
```

---

> [!info] 📚 Rappel important Ces trois outils (`lsblk`, `fdisk -l`, `blkid`) sont complémentaires et non redondants. Maîtriser leur utilisation combinée vous permettra d'avoir une vision complète de votre système de stockage avant toute intervention.