

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

## 🎯 Introduction au formatage

Le formatage d'une partition consiste à créer un **système de fichiers** (filesystem) sur celle-ci. Sans système de fichiers, une partition n'est qu'un espace de stockage brut inutilisable pour stocker des fichiers et répertoires.

> [!info] Qu'est-ce qu'un système de fichiers ? Un système de fichiers est une structure logique qui organise et gère les données sur un périphérique de stockage. Il définit comment les fichiers sont nommés, stockés, organisés et récupérés.

> [!warning] Attention - Opération destructive ! Le formatage **efface toutes les données** présentes sur la partition. Assurez-vous toujours d'avoir sauvegardé vos données importantes avant de formater.

**Quand formater une partition ?**

- Après avoir créé une nouvelle partition
- Pour changer de système de fichiers
- Pour effacer complètement une partition
- Pour résoudre des problèmes de corruption

---

## 🔧 La commande mkfs

`mkfs` (make filesystem) est la commande principale pour créer des systèmes de fichiers sous Linux.

### Syntaxe générale

```bash
mkfs [options] <périphérique>
```

### Variantes de mkfs

`mkfs` est en réalité un programme frontal qui appelle des utilitaires spécifiques selon le type de système de fichiers :

```bash
# Syntaxe générale avec type
mkfs -t <type> <périphérique>

# Ou directement avec la commande spécifique
mkfs.ext4 <périphérique>
mkfs.xfs <périphérique>
mkfs.btrfs <périphérique>
```

> [!example] Exemples de base
> 
> ```bash
> # Formater en ext4
> mkfs.ext4 /dev/sdb1
> 
> # Formater en XFS
> mkfs.xfs /dev/sdb2
> 
> # Formater en Btrfs
> mkfs.btrfs /dev/sdb3
> ```

### Options communes

```bash
# Forcer le formatage sans confirmation
mkfs.ext4 -F /dev/sdb1

# Ajouter un label (étiquette)
mkfs.ext4 -L "mes_donnees" /dev/sdb1

# Vérifier les mauvais blocs pendant le formatage
mkfs.ext4 -c /dev/sdb1

# Vérifier intensivement (lecture + écriture, LENT)
mkfs.ext4 -cc /dev/sdb1
```

> [!tip] Labels de partitions Donner un label à vos partitions facilite leur identification et leur montage. C'est particulièrement utile dans `/etc/fstab`.

---

## 📂 Systèmes de fichiers Linux

### ext4

**Extended File System version 4** - Le système de fichiers standard de Linux.

#### Caractéristiques

- **Maturité** : Très stable et éprouvé depuis des années
- **Performance** : Excellentes performances pour un usage général
- **Taille maximale** : Volumes jusqu'à 1 Exaoctet, fichiers jusqu'à 16 Téraoctets
- **Journalisation** : Protection contre la corruption des données
- **Compatibilité** : Support universel sur toutes les distributions Linux

#### Création d'un système ext4

```bash
# Formatage standard
mkfs.ext4 /dev/sdb1

# Avec options avancées
mkfs.ext4 -L "donnees" \          # Label
          -m 1 \                   # 1% réservé pour root (au lieu de 5%)
          -O ^has_journal \        # Désactiver le journal (SSD)
          /dev/sdb1
```

#### Options importantes

```bash
# Définir le nombre d'inodes
mkfs.ext4 -N 500000 /dev/sdb1

# Définir la taille des blocs (1024, 2048, ou 4096 octets)
mkfs.ext4 -b 4096 /dev/sdb1

# Réserver de l'espace pour root
mkfs.ext4 -m 5 /dev/sdb1  # 5% par défaut
```

> [!info] Espace réservé pour root Par défaut, ext4 réserve 5% de l'espace pour l'utilisateur root. Sur de grands disques, cela peut représenter beaucoup d'espace. Vous pouvez réduire ce pourcentage avec `-m`.

#### Quand utiliser ext4 ?

✅ **Recommandé pour :**

- Systèmes de fichiers racine (/)
- Partitions /home
- Usage général et bureautique
- Serveurs avec besoins standards
- Disques durs traditionnels (HDD)

---

### XFS

Système de fichiers haute performance développé par Silicon Graphics.

#### Caractéristiques

- **Performance** : Excellent pour les gros fichiers et l'I/O parallèle
- **Scalabilité** : Gestion optimale de très gros volumes
- **Taille maximale** : Volumes jusqu'à 8 Exaoctets, fichiers jusqu'à 8 Exaoctets
- **Allocation retardée** : Amélioration des performances d'écriture
- **Pas de réduction** : Impossible de rétrécir un système XFS

#### Création d'un système XFS

```bash
# Formatage standard
mkfs.xfs /dev/sdb1

# Avec options avancées
mkfs.xfs -L "media" \             # Label
         -f \                      # Force (écrase les données existantes)
         -i size=512 \             # Taille des inodes
         /dev/sdb1
```

#### Options importantes

```bash
# Spécifier la taille des blocs
mkfs.xfs -b size=4096 /dev/sdb1

# Optimiser pour les SSD
mkfs.xfs -d sunit=512,swidth=2048 /dev/sdb1

# Forcer le formatage
mkfs.xfs -f /dev/sdb1
```

> [!warning] XFS ne peut pas être réduit Contrairement à ext4, une fois créé, un système de fichiers XFS ne peut qu'être agrandi, jamais réduit. Planifiez la taille en conséquence.

#### Quand utiliser XFS ?

✅ **Recommandé pour :**

- Serveurs de fichiers avec gros fichiers
- Bases de données
- Environnements nécessitant de l'I/O parallèle
- Systèmes avec beaucoup de RAM
- Stockage de vidéos et médias volumineux

❌ **Moins adapté pour :**

- Nombreux petits fichiers
- Systèmes avec peu de RAM
- Besoin de réduire les partitions

---

### Btrfs

**B-tree File System** - Système de fichiers moderne avec fonctionnalités avancées.

#### Caractéristiques

- **Copy-on-Write (CoW)** : Protection des données et snapshots instantanés
- **Snapshots** : Captures instantanées du système de fichiers
- **Compression** : Compression transparente des données
- **RAID intégré** : Gestion native du RAID
- **Checksums** : Vérification d'intégrité des données
- **Subvolumes** : Partitionnement logique flexible

#### Création d'un système Btrfs

```bash
# Formatage standard
mkfs.btrfs /dev/sdb1

# Avec options avancées
mkfs.btrfs -L "backup" \          # Label
           -m single \             # Metadata en simple (pas de duplication)
           -d single \             # Data en simple
           /dev/sdb1
```

#### Options importantes

```bash
# Créer un système Btrfs multi-disques (RAID)
mkfs.btrfs -d raid1 -m raid1 /dev/sdb1 /dev/sdc1

# Forcer le formatage
mkfs.btrfs -f /dev/sdb1

# Définir la taille des blocs de metadata
mkfs.btrfs -n 16384 /dev/sdb1

# Définir la taille des secteurs
mkfs.btrfs -s 4096 /dev/sdb1
```

> [!tip] Compression avec Btrfs Btrfs peut compresser automatiquement les données au moment du montage avec l'option `compress=zstd`. Cela se configure lors du montage, pas lors du formatage.

#### Fonctionnalités avancées

```bash
# Créer des subvolumes (après montage)
btrfs subvolume create /mnt/subvol1

# Créer un snapshot
btrfs subvolume snapshot /mnt/subvol1 /mnt/snapshot1

# Vérifier l'utilisation
btrfs filesystem usage /mnt
```

#### Quand utiliser Btrfs ?

✅ **Recommandé pour :**

- Systèmes nécessitant des snapshots fréquents
- Sauvegardes incrémentales
- Serveurs NAS domestiques
- Postes de travail avec besoin de restauration rapide
- Compression transparente des données

❌ **Moins adapté pour :**

- Bases de données haute performance
- Environnements de production critiques (encore en maturation)
- Serveurs avec charge I/O intensive aléatoire

> [!warning] Maturité de Btrfs Bien que Btrfs soit stable pour un usage général, certaines fonctionnalités (comme RAID 5/6) sont encore considérées comme expérimentales. Vérifiez la documentation récente avant utilisation en production.

---

### 📊 Tableau comparatif

|Caractéristique|ext4|XFS|Btrfs|
|---|---|---|---|
|**Maturité**|⭐⭐⭐⭐⭐|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|
|**Performance générale**|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|
|**Gros fichiers**|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|
|**Petits fichiers**|⭐⭐⭐⭐⭐|⭐⭐⭐|⭐⭐⭐⭐|
|**Snapshots**|❌|❌|✅|
|**Compression**|❌|❌|✅|
|**Redimensionnement**|✅ (agrandir/réduire)|✅ (agrandir seulement)|✅ (agrandir/réduire)|
|**Récupération après crash**|Excellent|Excellent|Excellent|
|**Taille max volume**|1 EB|8 EB|16 EB|
|**Taille max fichier**|16 TB|8 EB|16 EB|
|**Usage mémoire**|Faible|Moyen|Moyen-Élevé|
|**RAID intégré**|❌|❌|✅|
|**Défragmentation**|✅ (en ligne)|✅ (en ligne)|✅ (en ligne)|

> [!info] Légende EB = Exaoctet (1 million de TB) | TB = Téraoctet

---

## 💿 Création de swap

Le **swap** (espace d'échange) est une partition ou un fichier utilisé comme extension de la RAM. Lorsque la mémoire physique est pleine, le système déplace des données moins utilisées vers le swap.

### Pourquoi utiliser du swap ?

- **Extension de mémoire** : Permet au système de fonctionner avec plus de processus
- **Hibernation** : Nécessaire pour mettre le système en veille prolongée
- **Sécurité** : Évite les plantages en cas de saturation de RAM
- **Performance** : Le kernel peut optimiser l'utilisation de la mémoire

> [!info] Taille recommandée du swap
> 
> - **RAM < 2 GB** : 2x la RAM
> - **RAM 2-8 GB** : 1x la RAM
> - **RAM > 8 GB** : 4-8 GB suffisent généralement
> - **Pour hibernation** : Au moins égal à la RAM

### Créer une partition swap

#### Étape 1 : Créer la partition

Vous devez d'abord créer une partition avec `fdisk`, `gdisk`, ou `parted` (type Linux swap).

#### Étape 2 : Formater en swap

```bash
# Créer le système de fichiers swap
mkswap /dev/sdb1

# Avec un label
mkswap -L "swap_principal" /dev/sdb1
```

#### Étape 3 : Activer le swap

```bash
# Activer immédiatement
swapon /dev/sdb1

# Vérifier le swap actif
swapon --show
# ou
free -h
```

#### Étape 4 : Rendre permanent

Pour que le swap soit activé au démarrage, ajoutez-le à `/etc/fstab` :

```bash
# Éditer /etc/fstab
nano /etc/fstab

# Ajouter la ligne
/dev/sdb1    none    swap    sw    0    0
# ou avec UUID (recommandé)
UUID=xxxx-xxxx    none    swap    sw    0    0
```

> [!tip] Trouver l'UUID
> 
> ```bash
> blkid /dev/sdb1
> ```

### Désactiver le swap

```bash
# Désactiver temporairement
swapoff /dev/sdb1

# Désactiver tout le swap
swapoff -a
```

### Options avancées du swap

```bash
# Créer avec vérification des mauvais blocs
mkswap -c /dev/sdb1

# Définir la taille de page (généralement 4096)
mkswap -p 4096 /dev/sdb1

# Forcer la création
mkswap -f /dev/sdb1
```

### Fichier swap vs partition swap

Au lieu d'une partition dédiée, vous pouvez utiliser un fichier swap (plus flexible) :

```bash
# Créer un fichier de 4GB
fallocate -l 4G /swapfile
# ou
dd if=/dev/zero of=/swapfile bs=1M count=4096

# Sécuriser les permissions
chmod 600 /swapfile

# Formater en swap
mkswap /swapfile

# Activer
swapon /swapfile

# Ajouter à /etc/fstab
/swapfile    none    swap    sw    0    0
```

> [!tip] Avantage du fichier swap Un fichier swap peut être redimensionné facilement sans répartitionner le disque. C'est particulièrement utile sur des systèmes virtuels ou cloud.

### Priorité du swap

Si vous avez plusieurs espaces swap, vous pouvez définir des priorités :

```bash
# Dans /etc/fstab
/dev/sdb1    none    swap    sw,pri=10    0    0
/swapfile    none    swap    sw,pri=5     0    0
```

Plus la priorité est élevée, plus le swap sera utilisé en premier.

### Paramétrage du swap (swappiness)

```bash
# Voir la valeur actuelle (0-100)
cat /proc/sys/vm/swappiness

# Changer temporairement
sysctl vm.swappiness=10

# Changer définitivement (dans /etc/sysctl.conf)
vm.swappiness=10
```

> [!info] Valeur de swappiness
> 
> - **0** : Évite le swap sauf mémoire pleine
> - **10** : Recommandé pour desktops
> - **60** : Valeur par défaut
> - **100** : Swap agressif

---

## ✅ Bonnes pratiques

### Avant le formatage

> [!warning] Checklist de sécurité
> 
> - ✅ Vérifier que vous formatez la **bonne** partition (`lsblk`)
> - ✅ Sauvegarder les données importantes
> - ✅ Démonter la partition si elle est montée (`umount`)
> - ✅ Tester la partition avec `badblocks` si c'est un vieux disque

### Choix du système de fichiers

```bash
# Usage général, système racine
mkfs.ext4 /dev/sdX

# Serveurs, gros fichiers, bases de données
mkfs.xfs /dev/sdX

# Snapshots, compression, sauvegardes
mkfs.btrfs /dev/sdX
```

### Labels et UUID

Toujours utiliser des labels ou UUID dans `/etc/fstab` plutôt que les noms de périphériques :

```bash
# Ajouter un label lors du formatage
mkfs.ext4 -L "mes_donnees" /dev/sdb1

# Récupérer l'UUID
blkid /dev/sdb1

# Dans /etc/fstab, préférer
UUID=xxx-xxx-xxx    /mnt/data    ext4    defaults    0    2
# plutôt que
/dev/sdb1    /mnt/data    ext4    defaults    0    2
```

> [!tip] Pourquoi UUID ? Les noms de périphériques (`/dev/sdb1`) peuvent changer après un redémarrage si vous ajoutez/retirez des disques. Les UUID restent constants.

### Vérification après formatage

```bash
# Vérifier le système de fichiers
fsck /dev/sdb1

# Afficher les informations du système de fichiers
# Pour ext4
tune2fs -l /dev/sdb1

# Pour XFS
xfs_info /dev/sdb1

# Pour Btrfs
btrfs filesystem show /dev/sdb1
```

### Optimisations SSD

Pour les disques SSD, quelques ajustements sont recommandés :

```bash
# ext4 : désactiver le journal si recherche de performance maximale
mkfs.ext4 -O ^has_journal /dev/sdb1

# XFS : optimisations SSD
mkfs.xfs -f -K /dev/sdb1

# Dans /etc/fstab, ajouter noatime et discard
UUID=xxx /mnt ext4 defaults,noatime,discard 0 2
```

> [!info] Option discard L'option `discard` active le TRIM sur SSD, ce qui améliore les performances et la durée de vie. Certains préfèrent utiliser `fstrim` en cron hebdomadaire plutôt que `discard` continu.

### Pièges courants

> [!warning] Erreurs à éviter
> 
> - ❌ Formater une partition montée
> - ❌ Oublier de sauvegarder avant formatage
> - ❌ Utiliser `/dev/sdX` au lieu de `/dev/sdX1` (formaterait tout le disque !)
> - ❌ Ne pas vérifier la partition avec `lsblk` avant de formater
> - ❌ Créer un swap trop petit pour l'hibernation
> - ❌ Utiliser XFS si vous prévoyez de réduire la partition plus tard

---

## 🎓 Astuces d'administration

### Formater rapidement plusieurs partitions

```bash
# Script pour formater plusieurs partitions
for part in /dev/sdb{1,2,3}; do
    mkfs.ext4 -L "partition_$(basename $part)" $part
done
```

### Connaître le système de fichiers d'une partition

```bash
# Afficher le type de système de fichiers
lsblk -f
# ou
blkid /dev/sdb1
# ou
file -s /dev/sdb1
```

### Changer le label d'un système existant

```bash
# ext4
e2label /dev/sdb1 "nouveau_nom"

# XFS (doit être monté)
xfs_admin -L "nouveau_nom" /dev/sdb1

# Btrfs (doit être monté)
btrfs filesystem label /mnt "nouveau_nom"

# Swap
swaplabel -L "nouveau_nom" /dev/sdb1
```

### Convertir un système de fichiers

> [!warning] Conversion risquée La conversion entre systèmes de fichiers peut être risquée. La méthode la plus sûre est :
> 
> 1. Sauvegarder les données
> 2. Reformater dans le nouveau système
> 3. Restaurer les données

```bash
# Il existe des outils de conversion mais ils sont risqués
# ext2 → ext3 → ext4 est possible
tune2fs -j /dev/sdb1  # ajoute le journal (ext2→ext3)

# Pour d'autres conversions, préférer sauvegarde + formatage
```

### Forcer un formatage "rapide"

```bash
# ext4 : formatage rapide (ne vérifie pas les blocs)
mkfs.ext4 -F /dev/sdb1

# XFS : toujours rapide par défaut
mkfs.xfs -f /dev/sdb1

# Pour vraiment effacer un disque de façon sécurisée
shred -vfz -n 3 /dev/sdb1
# ou pour tout le disque
dd if=/dev/zero of=/dev/sdb bs=1M status=progress
```

---

> [!tip] Mémo rapide
> 
> ```bash
> # Formater en ext4
> mkfs.ext4 -L "label" /dev/sdXN
> 
> # Formater en XFS
> mkfs.xfs -f -L "label" /dev/sdXN
> 
> # Formater en Btrfs
> mkfs.btrfs -L "label" /dev/sdXN
> 
> # Créer un swap
> mkswap /dev/sdXN && swapon /dev/sdXN
> 
> # Vérifier les systèmes de fichiers
> lsblk -f
> ```