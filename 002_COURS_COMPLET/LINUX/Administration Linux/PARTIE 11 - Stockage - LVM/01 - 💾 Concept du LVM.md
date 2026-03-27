

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

## Introduction au LVM

**LVM** (Logical Volume Manager) est une couche d'abstraction entre les disques physiques et les systèmes de fichiers. Il permet une gestion flexible et dynamique de l'espace de stockage en découplant la logique de stockage de la réalité matérielle.

> [!info] Architecture LVM LVM s'organise en trois niveaux hiérarchiques :
> 
> 1. **PV** (Physical Volume) : Les disques ou partitions physiques
> 2. **VG** (Volume Group) : Regroupement de PV en pool de stockage
> 3. **LV** (Logical Volume) : Partitions logiques créées dans le VG

```
┌─────────────────────────────────────────┐
│         Système de fichiers             │
│         (ext4, xfs, etc.)               │
└─────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────┐
│      Volumes Logiques (LV)              │
│    /dev/vg_data/lv_home                 │
│    /dev/vg_data/lv_var                  │
└─────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────┐
│      Groupe de Volumes (VG)             │
│         vg_data (pool)                  │
└─────────────────────────────────────────┘
                    ↕
┌──────────────┬──────────────┬───────────┐
│   PV /dev/sdb│   PV /dev/sdc│ PV /dev/sdd│
│  (Disque 1)  │  (Disque 2)  │ (Disque 3) │
└──────────────┴──────────────┴───────────┘
```

---

## 🔷 Volumes Physiques (PV)

### Qu'est-ce qu'un Volume Physique ?

Un **Physical Volume (PV)** est un disque ou une partition qui a été initialisé pour être utilisé par LVM. C'est la brique de base qui fournit l'espace de stockage physique.

> [!info] Unité de base : Physical Extent (PE) LVM divise chaque PV en blocs de taille fixe appelés **PE** (Physical Extents), généralement de 4 Mo. C'est l'unité d'allocation minimale.

### Initialisation d'un Volume Physique

```bash
# Créer un PV sur un disque entier
pvcreate /dev/sdb

# Créer un PV sur une partition
pvcreate /dev/sdc1

# Créer plusieurs PV simultanément
pvcreate /dev/sdb /dev/sdc /dev/sdd
```

> [!warning] Attention aux données La commande `pvcreate` écrit un label LVM sur le périphérique. Bien que cela ne détruise pas immédiatement les données, le périphérique devient inutilisable sans LVM. Toujours vérifier deux fois avant d'exécuter !

### Consultation des Volumes Physiques

```bash
# Lister tous les PV
pvs

# Affichage détaillé d'un PV spécifique
pvdisplay /dev/sdb

# Affichage très détaillé avec métadonnées
pvdisplay -v /dev/sdb

# Scanner tous les périphériques pour détecter les PV
pvscan
```

**Exemple de sortie `pvs` :**

```
  PV         VG      Fmt  Attr PSize   PFree
  /dev/sdb   vg_data lvm2 a--  100.00g 50.00g
  /dev/sdc   vg_data lvm2 a--  200.00g 200.00g
  /dev/sdd           lvm2 ---  150.00g 150.00g
```

|Colonne|Description|
|---|---|
|PV|Chemin du périphérique|
|VG|Groupe de volumes auquel il appartient|
|Fmt|Format (lvm2 est le standard)|
|Attr|Attributs (a = allocatable)|
|PSize|Taille totale|
|PFree|Espace libre|

### Suppression d'un Volume Physique

```bash
# Retirer un PV d'un VG (doit être fait avant suppression)
vgreduce vg_data /dev/sdb

# Supprimer les métadonnées LVM d'un PV
pvremove /dev/sdb
```

> [!tip] Vérifier avant de supprimer Utilisez `pvdisplay` pour vérifier qu'un PV n'est pas alloué avant de le supprimer. Un PV ne peut être supprimé que s'il n'appartient à aucun VG ou si son espace n'est pas utilisé.

### Modification des attributs d'un PV

```bash
# Rendre un PV non-allocatable (empêche la création de nouveaux LV)
pvchange -x n /dev/sdb

# Rendre un PV allocatable
pvchange -x y /dev/sdb

# Redimensionner un PV après extension de partition
pvresize /dev/sdb1
```

---

## 🔶 Groupes de Volumes (VG)

### Qu'est-ce qu'un Groupe de Volumes ?

Un **Volume Group (VG)** est un pool de stockage créé en regroupant un ou plusieurs PV. C'est dans ce pool que seront créés les volumes logiques (LV).

> [!info] Analogie Pensez au VG comme un grand disque virtuel formé par la combinaison de plusieurs disques physiques. Vous pouvez ensuite découper ce disque virtuel en partitions logiques (LV).

### Création d'un Groupe de Volumes

```bash
# Créer un VG avec un seul PV
vgcreate vg_data /dev/sdb

# Créer un VG avec plusieurs PV
vgcreate vg_data /dev/sdb /dev/sdc /dev/sdd

# Créer un VG avec une taille de PE personnalisée (8 Mo au lieu de 4 Mo)
vgcreate -s 8M vg_data /dev/sdb
```

> [!tip] Nommage des VG Adoptez une convention de nommage claire : `vg_data`, `vg_system`, `vg_backup`, etc. Cela facilite l'administration, surtout dans les environnements multi-serveurs.

### Consultation des Groupes de Volumes

```bash
# Lister tous les VG
vgs

# Affichage détaillé d'un VG spécifique
vgdisplay vg_data

# Affichage avec plus d'informations
vgdisplay -v vg_data

# Scanner pour détecter tous les VG
vgscan
```

**Exemple de sortie `vgs` :**

```
  VG      #PV #LV #SN Attr   VSize   VFree
  vg_data   3   2   0 wz--n- 450.00g 200.00g
```

|Colonne|Description|
|---|---|
|VG|Nom du groupe de volumes|
|#PV|Nombre de PV dans le VG|
|#LV|Nombre de LV créés|
|#SN|Nombre de snapshots|
|Attr|Attributs (w = writable, z = resizable, n = normal)|
|VSize|Taille totale du VG|
|VFree|Espace libre disponible|

### Extension d'un Groupe de Volumes

```bash
# Ajouter un nouveau PV à un VG existant
vgextend vg_data /dev/sdd

# Ajouter plusieurs PV
vgextend vg_data /dev/sdd /dev/sde
```

> [!example] Cas d'usage Votre serveur manque d'espace. Vous ajoutez un nouveau disque `/dev/sdd`, vous l'initialisez avec `pvcreate`, puis vous l'ajoutez au VG existant avec `vgextend`. L'espace devient immédiatement disponible pour créer de nouveaux LV ou étendre les existants.

### Réduction d'un Groupe de Volumes

```bash
# Déplacer les données d'un PV avant de le retirer
pvmove /dev/sdd

# Retirer un PV du VG
vgreduce vg_data /dev/sdd

# Retirer tous les PV vides (non utilisés) d'un VG
vgreduce --removemissing vg_data
```

> [!warning] Déplacer avant de réduire Avant de retirer un PV d'un VG, assurez-vous qu'il ne contient aucune donnée ou utilisez `pvmove` pour déplacer les données vers d'autres PV du VG.

### Suppression d'un Groupe de Volumes

```bash
# Supprimer un VG (tous les LV doivent être supprimés d'abord)
vgremove vg_data
```

### Activation et désactivation d'un VG

```bash
# Désactiver un VG (rend tous les LV inaccessibles)
vgchange -a n vg_data

# Activer un VG
vgchange -a y vg_data
```

> [!tip] Utilité de la désactivation La désactivation est utile pour la maintenance, la sauvegarde ou avant de déplacer des disques vers un autre système.

---

## 🔵 Volumes Logiques (LV)

### Qu'est-ce qu'un Volume Logique ?

Un **Logical Volume (LV)** est l'équivalent d'une partition traditionnelle, mais avec beaucoup plus de flexibilité. Il est créé dans un VG et peut être redimensionné à volonté (tant qu'il y a de l'espace disponible).

> [!info] Unité de base : Logical Extent (LE) Les LV sont composés de **LE** (Logical Extents), qui correspondent aux PE des PV sous-jacents. Par défaut, un LE = un PE.

### Création d'un Volume Logique

```bash
# Créer un LV de 50 Go
lvcreate -L 50G -n lv_home vg_data

# Créer un LV utilisant 100% de l'espace libre
lvcreate -l 100%FREE -n lv_backup vg_data

# Créer un LV utilisant 50% de l'espace libre
lvcreate -l 50%FREE -n lv_var vg_data

# Créer un LV avec un nombre spécifique d'extents
lvcreate -l 1000 -n lv_test vg_data
```

|Option|Description|
|---|---|
|`-L`|Taille en unités (K, M, G, T)|
|`-l`|Nombre d'extents ou pourcentage|
|`-n`|Nom du LV|
|Dernier argument|Nom du VG|

> [!tip] Accès au LV Une fois créé, le LV est accessible via `/dev/vg_data/lv_home` ou `/dev/mapper/vg_data-lv_home`.

### Formatage et montage d'un LV

```bash
# Formater le LV en ext4
mkfs.ext4 /dev/vg_data/lv_home

# Créer un point de montage
mkdir /home

# Monter le LV
mount /dev/vg_data/lv_home /home

# Rendre le montage permanent (ajouter dans /etc/fstab)
echo "/dev/vg_data/lv_home /home ext4 defaults 0 2" >> /etc/fstab
```

### Consultation des Volumes Logiques

```bash
# Lister tous les LV
lvs

# Affichage détaillé d'un LV spécifique
lvdisplay /dev/vg_data/lv_home

# Affichage avec segments et mapping
lvdisplay -m /dev/vg_data/lv_home

# Scanner tous les LV
lvscan
```

**Exemple de sortie `lvs` :**

```
  LV      VG      Attr       LSize   Pool Origin Data%  Meta%
  lv_home vg_data -wi-ao---- 50.00g
  lv_var  vg_data -wi-ao---- 100.00g
```

|Colonne|Description|
|---|---|
|LV|Nom du volume logique|
|VG|Groupe de volumes parent|
|Attr|Attributs (w = writable, i = inherited, a = active, o = open)|
|LSize|Taille du LV|

### Extension d'un Volume Logique

```bash
# Étendre un LV de 20 Go supplémentaires
lvextend -L +20G /dev/vg_data/lv_home

# Étendre un LV jusqu'à 100 Go au total
lvextend -L 100G /dev/vg_data/lv_home

# Étendre un LV pour utiliser tout l'espace libre du VG
lvextend -l +100%FREE /dev/vg_data/lv_home

# Étendre et redimensionner le système de fichiers simultanément
lvextend -L +20G -r /dev/vg_data/lv_home
```

> [!warning] Redimensionnement du système de fichiers L'extension du LV n'étend pas automatiquement le système de fichiers ! Utilisez l'option `-r` ou exécutez manuellement :
> 
> - Pour ext4 : `resize2fs /dev/vg_data/lv_home`
> - Pour xfs : `xfs_growfs /home`

### Réduction d'un Volume Logique

```bash
# Démonter le LV avant réduction
umount /home

# Vérifier le système de fichiers
e2fsck -f /dev/vg_data/lv_home

# Réduire le système de fichiers
resize2fs /dev/vg_data/lv_home 30G

# Réduire le LV
lvreduce -L 30G /dev/vg_data/lv_home

# Remonter
mount /dev/vg_data/lv_home /home
```

> [!warning] Danger de perte de données La réduction est **dangereuse** et peut entraîner une perte de données si mal effectuée. Toujours réduire le système de fichiers AVANT le LV, jamais l'inverse. XFS ne supporte pas la réduction !

### Suppression d'un Volume Logique

```bash
# Démonter le LV
umount /home

# Supprimer le LV
lvremove /dev/vg_data/lv_home

# Forcer la suppression sans confirmation
lvremove -f /dev/vg_data/lv_home
```

### Renommage d'un Volume Logique

```bash
# Renommer un LV (doit être inactif ou démonté pour certaines opérations)
lvrename vg_data lv_home lv_home_new

# Alternative avec chemin complet
lvrename /dev/vg_data/lv_home /dev/vg_data/lv_home_new
```

---

## ⭐ Avantages du LVM

### 1. Flexibilité de redimensionnement

LVM permet d'agrandir ou de réduire les volumes à chaud (pour l'extension) sans interruption de service, contrairement aux partitions traditionnelles.

> [!example] Cas pratique Votre partition `/var` atteint 95% d'utilisation. Avec LVM, vous ajoutez simplement un nouveau disque, l'intégrez au VG, et étendez le LV de `/var` en quelques commandes. Avec des partitions classiques, vous devriez sauvegarder, repartitionner et restaurer.

### 2. Agrégation de disques

LVM permet de combiner plusieurs disques physiques en un seul pool de stockage logique, simplifiant la gestion.

```bash
# Trois disques de 100 Go chacun
pvcreate /dev/sdb /dev/sdc /dev/sdd

# Deviennent un seul VG de 300 Go
vgcreate vg_data /dev/sdb /dev/sdc /dev/sdd

# D'où vous pouvez créer un LV de 250 Go
lvcreate -L 250G -n lv_huge vg_data
```

### 3. Snapshots

LVM permet de créer des instantanés (snapshots) d'un LV pour les sauvegardes ou les tests, sans dupliquer toutes les données immédiatement.

> [!info] Principe du snapshot Un snapshot LVM utilise le mécanisme **copy-on-write** : seules les modifications sont stockées, pas l'intégralité des données. Cela permet des sauvegardes cohérentes de systèmes en production.

```bash
# Créer un snapshot de 10 Go pour lv_home
lvcreate -L 10G -s -n snap_home /dev/vg_data/lv_home

# Monter le snapshot en lecture seule pour sauvegarde
mount -o ro /dev/vg_data/snap_home /mnt/snapshot

# Après sauvegarde, supprimer le snapshot
lvremove /dev/vg_data/snap_home
```

### 4. Migration de données transparente

La commande `pvmove` permet de déplacer les données d'un disque à un autre sans interruption de service, utile pour remplacer du matériel défaillant.

```bash
# Déplacer toutes les données de /dev/sdb vers d'autres PV du VG
pvmove /dev/sdb

# Déplacer uniquement un LV spécifique
pvmove -n lv_home /dev/sdb /dev/sdc
```

> [!tip] Remplacement de disque
> 
> 1. Ajouter le nouveau disque au VG avec `vgextend`
> 2. Déplacer les données avec `pvmove`
> 3. Retirer l'ancien disque avec `vgreduce`
> 4. Remplacer physiquement le matériel

### 5. Simplification de la gestion multi-disques

Au lieu de jongler avec `/dev/sdb1`, `/dev/sdc2`, etc., vous manipulez des noms logiques comme `/dev/vg_data/lv_home`, plus intuitifs et stables.

### 6. Allocation flexible de l'espace

Avec des partitions traditionnelles, vous devez décider de la taille au moment de la création. Avec LVM, vous pouvez :

- Créer des LV de petite taille initialement
- Les étendre au fur et à mesure des besoins
- Éviter le gaspillage d'espace

### 7. Indépendance matérielle

Les LV ne sont pas liés à un disque physique spécifique. Vous pouvez ajouter, retirer ou remplacer des disques sans réorganiser vos partitions logiques.

### Tableau récapitulatif

|Besoin|Solution traditionnelle|Solution LVM|
|---|---|---|
|Agrandir une partition|Complexe, souvent impossible|`lvextend` en quelques secondes|
|Combiner plusieurs disques|RAID ou montages séparés|VG unique et transparent|
|Sauvegarde cohérente|Arrêt du service|Snapshot en production|
|Remplacer un disque|Sauvegarde/restauration|`pvmove` à chaud|
|Réorganiser l'espace|Repartitionnement complet|Redimensionnement flexible|

---

## 🎯 Workflow typique LVM

Voici un exemple de workflow complet de mise en place d'un environnement LVM :

```bash
# 1. Initialiser les disques physiques
pvcreate /dev/sdb /dev/sdc

# 2. Créer un groupe de volumes
vgcreate vg_data /dev/sdb /dev/sdc

# 3. Créer des volumes logiques
lvcreate -L 50G -n lv_home vg_data
lvcreate -L 100G -n lv_var vg_data

# 4. Formater les LV
mkfs.ext4 /dev/vg_data/lv_home
mkfs.ext4 /dev/vg_data/lv_var

# 5. Monter les LV
mount /dev/vg_data/lv_home /home
mount /dev/vg_data/lv_var /var

# 6. Rendre permanent dans /etc/fstab
echo "/dev/vg_data/lv_home /home ext4 defaults 0 2" >> /etc/fstab
echo "/dev/vg_data/lv_var /var ext4 defaults 0 2" >> /etc/fstab
```

> [!tip] Architecture recommandée Pour un serveur de production :
> 
> - `/` : Partition classique ou petit LV (20-30 Go)
> - `/home`, `/var`, `/opt` : LV séparés pour flexibilité
> - Garder 20-30% d'espace libre dans le VG pour extensions futures

---

## 🔍 Commandes de diagnostic

```bash
# Vue d'ensemble complète du système LVM
pvs && vgs && lvs

# Détails sur l'utilisation de l'espace
vgdisplay -v vg_data

# Voir où sont stockées physiquement les données d'un LV
lvdisplay -m /dev/vg_data/lv_home

# Vérifier l'état des PV
pvck /dev/sdb

# Afficher la correspondance PE/LE
pvdisplay -m /dev/sdb
```

---

## ⚠️ Pièges courants

> [!warning] Erreurs fréquentes à éviter

1. **Réduire un LV sans réduire le système de fichiers d'abord** : Perte de données garantie
2. **Oublier de mettre à jour `/etc/fstab`** : Le système ne démarre plus après redémarrage
3. **Utiliser toute la capacité du VG** : Gardez toujours une marge pour les snapshots et l'extension
4. **Ne pas vérifier l'espace libre avant extension** : Utilisez `vgs` pour vérifier `VFree`
5. **Supprimer un PV encore utilisé** : Utilisez `pvmove` d'abord pour déplacer les données
6. **Créer des snapshots trop petits** : Ils peuvent déborder si trop de modifications ont lieu

---

## 💡 Bonnes pratiques

1. **Nommage cohérent** : Utilisez des conventions claires (`vg_data`, `lv_home`, etc.)
2. **Documentation** : Notez la structure LVM dans votre documentation système
3. **Monitoring** : Surveillez l'espace libre des VG et LV (`vgs`, `lvs`, `df`)
4. **Snapshots réguliers** : Avant toute modification importante du système
5. **Marge de sécurité** : Ne jamais utiliser 100% de la capacité d'un VG
6. **Sauvegardes de métadonnées** : LVM sauvegarde automatiquement dans `/etc/lvm/backup/`
7. **Tests en environnement non-production** : Avant toute manipulation critique

> [!tip] Commande de sauvegarde manuelle
> 
> ```bash
> # Sauvegarder la configuration LVM
> vgcfgbackup vg_data
> 
> # Restaurer en cas de problème
> vgcfgrestore vg_data
> ```

---

**Résumé** : LVM est un outil puissant qui apporte flexibilité et simplicité dans la gestion du stockage Linux. Maîtriser la hiérarchie PV → VG → LV et les commandes associées est essentiel pour tout administrateur système moderne.