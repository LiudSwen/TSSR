

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

## Introduction à la création LVM

La création d'une structure LVM se fait en **trois étapes obligatoires** qui doivent être respectées dans l'ordre :

1. **Volumes Physiques (PV)** : Initialisation des disques/partitions
2. **Groupes de Volumes (VG)** : Regroupement des PV en pools de stockage
3. **Volumes Logiques (LV)** : Découpage du VG en volumes utilisables

> [!info] Analogie
> 
> - **PV** = Briques individuelles
> - **VG** = Palette de briques
> - **LV** = Constructions faites avec ces briques

> [!warning] Prérequis Avant de commencer, assurez-vous d'avoir :
> 
> - Des disques ou partitions disponibles non montés
> - Les droits root ou sudo
> - Le paquet `lvm2` installé

---

## 1. Création des volumes physiques (pvcreate)

### 🎯 Objectif

`pvcreate` initialise un disque ou une partition pour être utilisé par LVM. Cette commande crée les métadonnées LVM sur le périphérique.

### Syntaxe

```bash
pvcreate [options] <périphérique>
```

### Options principales

|Option|Description|
|---|---|
|`-f, --force`|Force la création même si des signatures existent|
|`-y`|Répond automatiquement "oui" aux questions|
|`-u <uuid>`|Spécifie un UUID personnalisé|
|`--metadatasize <taille>`|Taille de la zone de métadonnées (défaut: auto)|
|`-Z, --zero`|Écrit des zéros au début du périphérique|

### Exemples pratiques

#### Créer un PV sur un disque entier

```bash
# Initialiser /dev/sdb comme volume physique
sudo pvcreate /dev/sdb
```

#### Créer un PV sur une partition

```bash
# Initialiser /dev/sdc1 comme volume physique
sudo pvcreate /dev/sdc1
```

#### Créer plusieurs PV en une commande

```bash
# Initialiser plusieurs disques simultanément
sudo pvcreate /dev/sdb /dev/sdc /dev/sdd
```

#### Forcer la création avec signature existante

```bash
# Si un système de fichiers existe déjà
sudo pvcreate -f /dev/sdb
# Attention : cela écrasera les données existantes !
```

> [!example] Exemple complet
> 
> ```bash
> # Vérifier que le disque n'est pas monté
> lsblk /dev/sdb
> 
> # Créer le volume physique
> sudo pvcreate /dev/sdb
>   Physical volume "/dev/sdb" successfully created.
> 
> # Vérifier la création
> sudo pvs
>   PV         VG   Fmt  Attr PSize   PFree
>   /dev/sdb        lvm2 ---   50.00g 50.00g
> ```

### Vérification des volumes physiques

```bash
# Liste simple
sudo pvs

# Informations détaillées
sudo pvdisplay /dev/sdb

# Afficher tous les PV avec détails
sudo pvdisplay
```

> [!tip] Bonnes pratiques
> 
> - Utilisez des partitions plutôt que des disques entiers pour plus de flexibilité
> - Documentez les disques utilisés pour LVM
> - Vérifiez toujours avec `lsblk` ou `fdisk -l` avant de créer un PV
> - Sauvegardez les données importantes avant d'initialiser un disque

> [!warning] Pièges courants
> 
> - **Disque monté** : Vous ne pouvez pas créer un PV sur un disque/partition monté
> - **Données existantes** : `pvcreate` écrase les métadonnées existantes
> - **Type de partition** : Il est recommandé de définir le type de partition à `8e` (Linux LVM) avec `fdisk`

---

## 2. Création des groupes de volumes (vgcreate)

### 🎯 Objectif

`vgcreate` regroupe un ou plusieurs volumes physiques en un pool de stockage unifié appelé Volume Group.

### Syntaxe

```bash
vgcreate [options] <nom_vg> <pv1> [pv2] [...]
```

### Options principales

|Option|Description|
|---|---|
|`-s, --physicalextentsize <taille>`|Taille des PE (défaut: 4 MiB)|
|`-l, --maxlogicalvolumes <nombre>`|Nombre max de LV (défaut: 0 = illimité)|
|`-p, --maxphysicalvolumes <nombre>`|Nombre max de PV (défaut: 0 = illimité)|
|`--alloc <politique>`|Politique d'allocation (contiguous, normal, anywhere)|
|`-A, --autobackup`|Active/désactive la sauvegarde auto des métadonnées|

### Concepts clés

> [!info] Physical Extent (PE) Le PE est l'unité d'allocation de base dans un VG. Tous les PV d'un même VG partagent la même taille de PE.
> 
> - **Taille par défaut** : 4 MiB
> - **Tailles possibles** : 1 KiB à 16 GiB (puissances de 2)
> - **Impact** : Une PE plus grande = moins de métadonnées mais granularité plus grossière

### Exemples pratiques

#### Créer un VG simple avec un seul PV

```bash
# Créer le VG "data_vg" avec /dev/sdb
sudo vgcreate data_vg /dev/sdb
  Volume group "data_vg" successfully created
```

#### Créer un VG avec plusieurs PV

```bash
# Créer un VG utilisant 3 disques
sudo vgcreate storage_vg /dev/sdb /dev/sdc /dev/sdd
```

#### Définir une taille de PE personnalisée

```bash
# PE de 16 MiB pour un très gros VG
sudo vgcreate -s 16M big_vg /dev/sdb /dev/sdc
```

#### Limiter le nombre de LV

```bash
# Autoriser maximum 10 volumes logiques
sudo vgcreate -l 10 restricted_vg /dev/sdb
```

> [!example] Exemple complet
> 
> ```bash
> # Créer le groupe de volumes
> sudo vgcreate -s 8M storage_vg /dev/sdb /dev/sdc
>   Volume group "storage_vg" successfully created
> 
> # Vérifier la création
> sudo vgs
>   VG         #PV #LV #SN Attr   VSize   VFree
>   storage_vg   2   0   0 wz--n- 149.99g 149.99g
> 
> # Voir les détails
> sudo vgdisplay storage_vg
> ```

### Vérification des groupes de volumes

```bash
# Liste simple
sudo vgs

# Informations détaillées
sudo vgdisplay storage_vg

# Afficher tous les VG
sudo vgdisplay

# Voir les PV appartenant à un VG
sudo pvs -o +vg_name
```

### Conventions de nommage

> [!tip] Nommage des VG Adoptez une convention claire :
> 
> - `data_vg`, `backup_vg`, `vm_vg` (par usage)
> - `vg_prod`, `vg_test` (par environnement)
> - `vg01`, `vg02` (numérotation simple)
> 
> **Évitez** : espaces, caractères spéciaux, noms trop longs

> [!warning] Pièges courants
> 
> - **Nom déjà utilisé** : Les noms de VG doivent être uniques sur le système
> - **PV déjà utilisé** : Un PV ne peut appartenir qu'à un seul VG
> - **Taille de PE** : Ne peut pas être modifiée après création du VG
> - **Disques hétérogènes** : Mélanger SSD et HDD dans un même VG peut créer des déséquilibres de performance

---

## 3. Création des volumes logiques (lvcreate)

### 🎯 Objectif

`lvcreate` découpe l'espace disponible d'un VG en volumes logiques qui seront formatés et montés comme des partitions classiques.

### Syntaxe

```bash
lvcreate [options] -n <nom_lv> -L <taille> <vg>
lvcreate [options] -n <nom_lv> -l <extents> <vg>
```

### Options principales de taille

|Option|Description|Exemple|
|---|---|---|
|`-L, --size <taille>`|Taille en unités (K, M, G, T)|`-L 10G`|
|`-l, --extents <nombre>`|Nombre de PE ou pourcentage|`-l 2560`|
|`-l <pourcentage>VG`|Pourcentage du VG|`-l 50%VG`|
|`-l <pourcentage>FREE`|Pourcentage de l'espace libre|`-l 100%FREE`|
|`-l <pourcentage>PVS`|Pourcentage de PV spécifiques|`-l 50%PVS /dev/sdb`|

### Options de configuration

|Option|Description|
|---|---|
|`-n, --name <nom>`|Nom du volume logique|
|`-C, --contiguous`|Allouer des PE contigus|
|`-i, --stripes <nombre>`|Nombre de bandes (striping)|
|`-I, --stripesize <taille>`|Taille des bandes (défaut: 64 KiB)|
|`-m, --mirrors <nombre>`|Créer un miroir (RAID 1)|
|`-s, --snapshot`|Créer un snapshot|
|`-p, --permission <r|rw>`|

### Exemples pratiques

#### Créer un LV avec taille absolue

```bash
# Créer un volume de 20 Go
sudo lvcreate -n home_lv -L 20G data_vg
  Logical volume "home_lv" created.
```

#### Créer un LV avec pourcentage du VG

```bash
# Utiliser 50% du groupe de volumes
sudo lvcreate -n backup_lv -l 50%VG data_vg
```

#### Utiliser tout l'espace libre restant

```bash
# Allouer 100% de l'espace disponible
sudo lvcreate -n last_lv -l 100%FREE data_vg
```

#### Créer un LV avec striping (performance)

```bash
# Stripe sur 2 disques avec bandes de 128K
sudo lvcreate -n fast_lv -L 40G -i 2 -I 128K storage_vg
```

#### Créer un LV sur des PV spécifiques

```bash
# Forcer l'utilisation de /dev/sdb uniquement
sudo lvcreate -n specific_lv -L 10G data_vg /dev/sdb
```

> [!example] Exemple complet avec vérification
> 
> ```bash
> # Vérifier l'espace disponible
> sudo vgs data_vg
>   VG      #PV #LV #SN Attr   VSize  VFree
>   data_vg   1   0   0 wz--n- 50.00g 50.00g
> 
> # Créer plusieurs volumes logiques
> sudo lvcreate -n mysql_lv -L 15G data_vg
> sudo lvcreate -n logs_lv -L 10G data_vg
> sudo lvcreate -n var_lv -l 100%FREE data_vg
> 
> # Vérifier les LV créés
> sudo lvs
>   LV       VG      Attr       LSize  Pool Origin Data%  Meta%
>   logs_lv  data_vg -wi-a----- 10.00g
>   mysql_lv data_vg -wi-a----- 15.00g
>   var_lv   data_vg -wi-a----- 25.00g
> ```

### Chemins d'accès aux LV

Les volumes logiques sont accessibles via plusieurs chemins :

```bash
# Chemin standard (lien symbolique)
/dev/vg_name/lv_name

# Chemin device mapper (réel)
/dev/mapper/vg_name-lv_name

# Chemin complet dm
/dev/dm-X
```

> [!tip] Utilisation recommandée Utilisez toujours `/dev/vg_name/lv_name` dans vos scripts et `/etc/fstab` pour la clarté et la portabilité.

### Calcul des extents

> [!info] Conversion taille ↔ extents
> 
> ```bash
> # Si PE = 4 MiB
> Nombre d'extents = Taille en MiB / 4
> 
> # Exemple : 10 Go = 10240 MiB = 2560 extents
> sudo lvcreate -n lv1 -L 10G vg1    # Avec taille
> sudo lvcreate -n lv2 -l 2560 vg1   # Avec extents (équivalent)
> ```

### Vérification des volumes logiques

```bash
# Liste simple
sudo lvs

# Détails complets
sudo lvdisplay /dev/data_vg/home_lv

# Tous les LV avec détails
sudo lvdisplay

# Informations sur l'allocation
sudo lvs -o +devices
```

> [!tip] Bonnes pratiques
> 
> - **Planification** : Réfléchissez à la répartition avant de créer les LV
> - **Nommage** : Utilisez des noms explicites (mysql_lv, home_lv, var_lv)
> - **Espace libre** : Gardez 10-20% d'espace libre pour les extensions futures
> - **Striping** : Utilisez-le pour les charges I/O intensives (bases de données)
> - **Documentation** : Documentez l'usage de chaque LV

> [!warning] Pièges courants
> 
> - **Sur-allocation** : Vérifier l'espace disponible avec `vgs` avant de créer
> - **Unités** : `-L 10M` = 10 MiB, `-L 10G` = 10 GiB (attention aux confusions)
> - **100%FREE** : Peut ne pas utiliser exactement tout l'espace si le calcul des PE ne tombe pas juste
> - **Striping** : Nécessite au moins autant de PV que de stripes demandés
> - **Performance** : Un LV qui span sur plusieurs disques lents n'est pas plus rapide qu'un sur un seul disque

---

## 4. Formatage et montage des volumes logiques

### 🎯 Objectif

Une fois le LV créé, il faut le formater avec un système de fichiers et le monter pour l'utiliser.

### Étapes du workflow

1. **Formater** le volume logique
2. **Créer** un point de montage
3. **Monter** temporairement (test)
4. **Configurer** le montage automatique dans `/etc/fstab`

### Formatage du volume logique

#### Systèmes de fichiers courants

|Système|Usage recommandé|Commande|
|---|---|---|
|**ext4**|Usage général Linux|`mkfs.ext4`|
|**xfs**|Fichiers volumineux, haute performance|`mkfs.xfs`|
|**btrfs**|Fonctionnalités avancées (snapshots, compression)|`mkfs.btrfs`|
|**swap**|Espace d'échange|`mkswap`|

#### Exemples de formatage

```bash
# Format ext4 (le plus courant)
sudo mkfs.ext4 /dev/data_vg/home_lv

# Format XFS avec label
sudo mkfs.xfs -L "home_volume" /dev/data_vg/home_lv

# Format ext4 avec options
sudo mkfs.ext4 -L "mysql_data" -m 1 /dev/data_vg/mysql_lv
# -m 1 : réserve seulement 1% pour root (au lieu de 5%)

# Créer un volume swap
sudo mkswap /dev/data_vg/swap_lv
sudo swapon /dev/data_vg/swap_lv
```

> [!tip] Options de formatage utiles
> 
> - `-L <label>` : Définir un label (facilite l'identification)
> - `-m <pourcentage>` : Espace réservé à root (ext4, défaut 5%)
> - `-N <nombre>` : Nombre d'inodes (pour beaucoup de petits fichiers)
> - `-b <taille>` : Taille des blocs (1024, 2048, 4096)

### Création du point de montage

```bash
# Créer le répertoire de montage
sudo mkdir -p /mnt/home

# Ou pour plusieurs points
sudo mkdir -p /mnt/{home,mysql,logs}
```

### Montage temporaire (test)

```bash
# Monter le volume
sudo mount /dev/data_vg/home_lv /mnt/home

# Vérifier le montage
df -h /mnt/home
mount | grep home_lv

# Tester l'écriture
sudo touch /mnt/home/test.txt

# Démonter après test
sudo umount /mnt/home
```

### Configuration du montage automatique

#### Méthode 1 : Par chemin de périphérique

```bash
# Éditer /etc/fstab
sudo nano /etc/fstab

# Ajouter la ligne
/dev/data_vg/home_lv  /mnt/home  ext4  defaults  0  2
```

#### Méthode 2 : Par UUID (recommandé)

```bash
# Obtenir l'UUID
sudo blkid /dev/data_vg/home_lv
# Sortie : /dev/data_vg/home_lv: UUID="abc123..." TYPE="ext4"

# Ajouter dans /etc/fstab
UUID=abc123...  /mnt/home  ext4  defaults  0  2
```

#### Méthode 3 : Par label

```bash
# Si un label a été défini avec mkfs
LABEL=home_volume  /mnt/home  ext4  defaults  0  2
```

### Structure de /etc/fstab

```bash
# <périphérique>  <point_montage>  <type>  <options>  <dump>  <pass>
```

|Champ|Description|Valeurs courantes|
|---|---|---|
|`<périphérique>`|Chemin, UUID ou LABEL|`/dev/data_vg/lv`, `UUID=...`, `LABEL=...`|
|`<point_montage>`|Où monter|`/mnt/home`, `/var/lib/mysql`|
|`<type>`|Système de fichiers|`ext4`, `xfs`, `swap`|
|`<options>`|Options de montage|`defaults`, `noatime`, `nodiratime`|
|`<dump>`|Sauvegarde (obsolète)|`0` (pas de backup)|
|`<pass>`|Ordre de vérification fsck|`0` (pas de check), `1` (root), `2` (autres)|

### Options de montage courantes

|Option|Description|
|---|---|
|`defaults`|Options par défaut (rw, suid, dev, exec, auto, nouser, async)|
|`noatime`|Ne pas mettre à jour l'heure d'accès (performance)|
|`nodiratime`|Ne pas mettre à jour l'heure d'accès des répertoires|
|`discard`|Active TRIM pour les SSD|
|`nofail`|Continue le boot même si le montage échoue|
|`x-systemd.automount`|Montage automatique à la demande (systemd)|

> [!example] Exemple complet de configuration
> 
> ```bash
> # 1. Formater les volumes
> sudo mkfs.ext4 -L "home" /dev/data_vg/home_lv
> sudo mkfs.xfs -L "mysql" /dev/data_vg/mysql_lv
> sudo mkfs.ext4 -L "logs" /dev/data_vg/logs_lv
> 
> # 2. Créer les points de montage
> sudo mkdir -p /home2
> sudo mkdir -p /var/lib/mysql2
> sudo mkdir -p /var/log/app
> 
> # 3. Récupérer les UUID
> sudo blkid | grep data_vg
> 
> # 4. Éditer /etc/fstab
> sudo nano /etc/fstab
> 
> # Ajouter :
> UUID=xxx-home    /home2           ext4  defaults,noatime    0  2
> UUID=xxx-mysql   /var/lib/mysql2  xfs   defaults,noatime    0  2
> UUID=xxx-logs    /var/log/app     ext4  defaults,nodiratime 0  2
> 
> # 5. Tester la configuration
> sudo mount -a
> 
> # 6. Vérifier
> df -h
> ```

### Vérification après montage

```bash
# Vérifier tous les montages
df -hT

# Vérifier un montage spécifique
findmnt /mnt/home

# Voir les détails du système de fichiers
sudo tune2fs -l /dev/data_vg/home_lv | head -20  # Pour ext4
sudo xfs_info /mnt/home                          # Pour XFS

# Lister tous les LV et leurs points de montage
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | grep data_vg
```

### Test de la configuration fstab

```bash
# Tester sans redémarrer
sudo mount -a
# Si pas d'erreur, la configuration est correcte

# Démonter tout
sudo umount /mnt/home /var/lib/mysql2 /var/log/app

# Remonter tout selon fstab
sudo mount -a

# Vérifier
df -h
```

> [!tip] Bonnes pratiques
> 
> - **UUID plutôt que chemin** : Plus fiable, survit aux changements de configuration
> - **Labels explicites** : Facilitent l'identification (`-L` lors du formatage)
> - **Option nofail** : Évite les échecs de boot si un volume n'est pas disponible
> - **Options performance** : `noatime` et `nodiratime` réduisent les I/O inutiles
> - **Sauvegarde de fstab** : `sudo cp /etc/fstab /etc/fstab.backup` avant modification
> - **Test avant reboot** : Toujours tester avec `mount -a` avant de redémarrer

> [!warning] Pièges courants
> 
> - **fstab mal configuré** : Peut empêcher le système de démarrer (mode rescue)
> - **Point de montage non vide** : Le contenu existant sera masqué par le montage
> - **Permissions** : Vérifier les permissions du point de montage après premier montage
> - **Type de FS incorrect** : Vérifier le type dans fstab correspond au formatage
> - **Options incompatibles** : Certaines options ne fonctionnent qu'avec certains FS
> - **UUID dans fstab** : Ne pas mettre d'espaces ou de caractères superflus autour de l'UUID

---

## Workflow complet de création LVM

### 📋 Procédure pas à pas

Voici le workflow complet pour créer une structure LVM opérationnelle :

```bash
# ═══════════════════════════════════════════════════════════
# ÉTAPE 1 : PRÉPARATION
# ═══════════════════════════════════════════════════════════

# Identifier les disques disponibles
lsblk
sudo fdisk -l

# Vérifier qu'aucun disque n'est monté
mount | grep sdb


# ═══════════════════════════════════════════════════════════
# ÉTAPE 2 : CRÉATION DES VOLUMES PHYSIQUES
# ═══════════════════════════════════════════════════════════

# Initialiser les disques
sudo pvcreate /dev/sdb /dev/sdc

# Vérifier
sudo pvs
sudo pvdisplay


# ═══════════════════════════════════════════════════════════
# ÉTAPE 3 : CRÉATION DU GROUPE DE VOLUMES
# ═══════════════════════════════════════════════════════════

# Créer le VG
sudo vgcreate -s 8M data_vg /dev/sdb /dev/sdc

# Vérifier
sudo vgs
sudo vgdisplay data_vg


# ═══════════════════════════════════════════════════════════
# ÉTAPE 4 : CRÉATION DES VOLUMES LOGIQUES
# ═══════════════════════════════════════════════════════════

# Créer les LV selon les besoins
sudo lvcreate -n home_lv -L 30G data_vg
sudo lvcreate -n mysql_lv -L 20G data_vg
sudo lvcreate -n logs_lv -l 100%FREE data_vg

# Vérifier
sudo lvs
sudo lvdisplay


# ═══════════════════════════════════════════════════════════
# ÉTAPE 5 : FORMATAGE
# ═══════════════════════════════════════════════════════════

# Formater chaque LV
sudo mkfs.ext4 -L "home" /dev/data_vg/home_lv
sudo mkfs.xfs -L "mysql" /dev/data_vg/mysql_lv
sudo mkfs.ext4 -L "logs" /dev/data_vg/logs_lv


# ═══════════════════════════════════════════════════════════
# ÉTAPE 6 : CRÉATION DES POINTS DE MONTAGE
# ═══════════════════════════════════════════════════════════

sudo mkdir -p /mnt/home
sudo mkdir -p /var/lib/mysql
sudo mkdir -p /var/log/app


# ═══════════════════════════════════════════════════════════
# ÉTAPE 7 : MONTAGE TEMPORAIRE ET TEST
# ═══════════════════════════════════════════════════════════

# Monter temporairement
sudo mount /dev/data_vg/home_lv /mnt/home
sudo mount /dev/data_vg/mysql_lv /var/lib/mysql
sudo mount /dev/data_vg/logs_lv /var/log/app

# Vérifier
df -hT
lsblk -f

# Tester l'écriture
sudo touch /mnt/home/test.txt
ls -la /mnt/home/

# Démonter
sudo umount /mnt/home /var/lib/mysql /var/log/app


# ═══════════════════════════════════════════════════════════
# ÉTAPE 8 : CONFIGURATION FSTAB
# ═══════════════════════════════════════════════════════════

# Récupérer les UUID
sudo blkid | grep data_vg

# Sauvegarder fstab
sudo cp /etc/fstab /etc/fstab.backup

# Éditer fstab
sudo nano /etc/fstab

# Ajouter les lignes (exemple) :
# UUID=xxx-home    /mnt/home        ext4  defaults,noatime  0  2
# UUID=xxx-mysql   /var/lib/mysql   xfs   defaults,noatime  0  2
# UUID=xxx-logs    /var/log/app     ext4  defaults          0  2


# ═══════════════════════════════════════════════════════════
# ÉTAPE 9 : VALIDATION FINALE
# ═══════════════════════════════════════════════════════════

# Tester le montage via fstab
sudo mount -a

# Vérifier que tout est monté
df -h
findmnt | grep data_vg

# Vérifier l'intégrité de la structure LVM
sudo vgs
sudo lvs -a
```

> [!example] Exemple de résultat final
> 
> ```bash
> $ df -hT | grep data_vg
> /dev/mapper/data_vg-home_lv   ext4   30G   45M   28G   1% /mnt/home
> /dev/mapper/data_vg-mysql_lv  xfs    20G   33M   20G   1% /var/lib/mysql
> /dev/mapper/data_vg-logs_lv   ext4   50G   53M   47G   1% /var/log/app
> 
> $ sudo lvs
>   LV       VG      Attr       LSize  Pool Origin Data%  Meta%
>   home_lv  data_vg -wi-ao---- 30.00g
>   logs_lv  data_vg -wi-ao---- 50.00g
>   mysql_lv data_vg -wi-ao---- 20.00g
> ```

### Checklist de vérification

> [!tip] Liste de contrôle finale
> 
> - [ ] Tous les PV sont visibles avec `sudo pvs`
> - [ ] Le VG affiche la bonne taille avec `sudo vgs`
> - [ ] Tous les LV sont créés et actifs avec `sudo lvs`
> - [ ] Chaque LV est formaté (vérifier avec `lsblk -f`)
> - [ ] Les points de montage existent et ont les bonnes permissions
> - [ ] `/etc/fstab` est sauvegardé avant modification
> - [ ] `sudo mount -a` fonctionne sans erreur
> - [ ] `df -h` montre tous les volumes montés
> - [ ] Test d'écriture réussi sur chaque volume
> - [ ] Documentation de l'infrastructure créée

### Schéma récapitulatif

```
┌─────────────────────────────────────────────────────────────┐
│                     DISQUES PHYSIQUES                        │
│              /dev/sdb (50GB)    /dev/sdc (50GB)             │
└──────────────────────┬──────────────────┬───────────────────┘
                       │                  │
                    pvcreate           pvcreate
                       │                  │
                       ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                   VOLUMES PHYSIQUES (PV)                     │
│              PV: /dev/sdb       PV: /dev/sdc                │
└──────────────────────┬──────────────────┬───────────────────┘
                       │                  │
                       └────────┬─────────┘
                             vgcreate
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                  GROUPE DE VOLUMES (VG)                      │
│                    VG: data_vg (100GB)                       │
│                   PE Size: 8 MiB                             │
└──────────────────────┬──────────────────────────────────────┘
                       │
              ┌────────┴────────┬────────────┐
           lvcreate         lvcreate      lvcreate
              │                 │              │
              ▼                 ▼              ▼
┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐
│ VOLUME LOGIQUE   │ │ VOLUME       │ │ VOLUME LOGIQUE   │
│ LV: home_lv      │ │ LOGIQUE      │ │ LV: logs_lv      │
│ Size: 30GB       │ │ LV: mysql_lv │ │ Size: 50GB       │
└────────┬─────────┘ │ Size: 20GB   │ └────────┬─────────┘
         │           └──────┬───────┘          │
      mkfs.ext4         mkfs.xfs           mkfs.ext4
         │                 │                    │
         ▼                 ▼                    ▼
┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐
│ SYSTÈME FICHIERS │ │ SYSTÈME      │ │ SYSTÈME FICHIERS │
│ ext4             │ │ FICHIERS     │ │ ext4             │
│                  │ │ xfs          │ │                  │
└────────┬─────────┘ └──────┬───────┘ └────────┬─────────┘
         │                  │                   │
      mount              mount               mount
         │                  │                   │
         ▼                  ▼                   ▼
┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐
│ POINT MONTAGE    │ │ POINT        │ │ POINT MONTAGE    │
│ /mnt/home        │ │ MONTAGE      │ │ /var/log/app     │
│                  │ │ /var/lib/    │ │                  │
│                  │ │ mysql        │ │                  │
└──────────────────┘ └──────────────┘ └──────────────────┘
```

---

## 🔍 Commandes de diagnostic et vérification

### Vue d'ensemble complète

```bash
# Vision globale de la structure LVM
sudo lsblk -f

# Arbre hiérarchique des périphériques
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT

# Résumé de tous les composants LVM
sudo pvs && echo "---" && sudo vgs && echo "---" && sudo lvs
```

### Diagnostic des volumes physiques

```bash
# Statut de tous les PV
sudo pvs -o +pv_used,pv_free,pv_uuid

# Détails d'un PV spécifique
sudo pvdisplay -m /dev/sdb

# Vérifier l'intégrité
sudo pvscan --cache

# Voir quel VG utilise un PV
sudo pvs -o pv_name,vg_name
```

### Diagnostic des groupes de volumes

```bash
# Statut avec espace utilisé/libre
sudo vgs -o +vg_free,vg_size,vg_uuid

# Détails complets avec allocation
sudo vgdisplay -v data_vg

# Voir tous les PV d'un VG
sudo vgs -o +pv_name data_vg

# Statut de tous les VG
sudo vgscan
```

### Diagnostic des volumes logiques

```bash
# Statut détaillé
sudo lvs -o +lv_size,lv_path,devices

# Information complète
sudo lvdisplay -m /dev/data_vg/home_lv

# Voir sur quels PV un LV est alloué
sudo lvs -o +devices data_vg/home_lv

# Scanner tous les LV
sudo lvscan
```

### Vérification des systèmes de fichiers

```bash
# État des montages
df -hT

# Détails d'un montage spécifique
findmnt /mnt/home

# Utilisation des inodes
df -i

# Informations ext4
sudo tune2fs -l /dev/data_vg/home_lv

# Informations XFS
sudo xfs_info /var/lib/mysql

# Vérifier la cohérence (démonté)
sudo fsck -n /dev/data_vg/home_lv  # -n = dry-run
```

> [!warning] Vérification système de fichiers
> 
> - **Toujours démonter** avant de lancer fsck en mode réparation
> - Utilisez `-n` (dry-run) pour vérifier sans modifier
> - Pour XFS, utilisez `xfs_repair` au lieu de fsck

---

## 💡 Astuces et optimisations

### Performance

> [!tip] Optimisations pour bases de données
> 
> ```bash
> # Créer un LV stripé pour MySQL
> sudo lvcreate -n mysql_lv -L 50G -i 3 -I 256K data_vg
> 
> # Formater avec options optimisées
> sudo mkfs.xfs -d su=256k,sw=3 /dev/data_vg/mysql_lv
> 
> # Monter avec options performance
> # Dans /etc/fstab :
> UUID=xxx  /var/lib/mysql  xfs  defaults,noatime,nodiratime,nobarrier  0  0
> ```

### Labels et identification

```bash
# Définir un label lors du formatage
sudo mkfs.ext4 -L "home_volume" /dev/data_vg/home_lv

# Changer le label après coup
sudo e2label /dev/data_vg/home_lv "nouveau_label"  # ext4
sudo xfs_admin -L "nouveau_label" /dev/data_vg/mysql_lv  # XFS

# Lister tous les labels
lsblk -o NAME,LABEL,UUID,FSTYPE
```

### Monitoring de l'espace

```bash
# Surveiller l'utilisation
watch -n 5 'df -h | grep data_vg'

# Alertes d'espace avec seuil
df -h | awk '$5+0 > 80 {print "⚠️ ", $0}'

# Voir les plus gros fichiers
sudo du -h /mnt/home | sort -rh | head -10
```

### Scripts utiles

> [!example] Script de vérification quotidienne
> 
> ```bash
> #!/bin/bash
> # check_lvm.sh - Vérification quotidienne LVM
> 
> echo "=== Vérification LVM $(date) ==="
> 
> # Vérifier les PV
> echo -e "\n📦 Volumes Physiques:"
> sudo pvs -o pv_name,vg_name,pv_size,pv_free
> 
> # Vérifier les VG
> echo -e "\n📚 Groupes de Volumes:"
> sudo vgs -o vg_name,vg_size,vg_free
> 
> # Vérifier les LV
> echo -e "\n💾 Volumes Logiques:"
> sudo lvs -o lv_name,vg_name,lv_size,lv_path
> 
> # Vérifier les montages
> echo -e "\n🗂️  Montages:"
> df -h | grep mapper
> 
> # Alertes si espace < 20%
> echo -e "\n⚠️  Alertes d'espace:"
> df -h | awk '$5+0 > 80 {print "ATTENTION: "$1" utilisé à "$5}'
> ```

### Raccourcis et alias

```bash
# Ajouter dans ~/.bashrc ou ~/.bash_aliases

# Vues rapides LVM
alias lvms='sudo lvs -o +devices'
alias vgms='sudo vgs -o +vg_free'
alias pvms='sudo pvs -o +pv_free'

# Vue complète
alias lvm-status='sudo pvs && echo "---" && sudo vgs && echo "---" && sudo lvs'

# Espace disque LVM
alias lvm-space='df -h | grep mapper'

# Scans
alias lvm-scan='sudo pvscan && sudo vgscan && sudo lvscan'
```

---

## ⚠️ Erreurs courantes et solutions

### Erreur : "Device or resource busy"

```bash
# Problème : Impossible de démonter un volume

# Solution 1 : Identifier les processus
sudo lsof /mnt/home
sudo fuser -v /mnt/home

# Solution 2 : Arrêter les processus
sudo fuser -km /mnt/home

# Solution 3 : Forcer le démontage (dernier recours)
sudo umount -l /mnt/home  # lazy unmount
```

### Erreur : "Can't open /dev/sdb exclusively"

```bash
# Problème : Le disque est en cours d'utilisation

# Vérifier les montages
mount | grep sdb

# Vérifier les utilisateurs du disque
sudo lsof /dev/sdb

# Démonter proprement
sudo umount /dev/sdb1
```

### Erreur : "Insufficient free space"

```bash
# Problème : Pas assez d'espace dans le VG

# Vérifier l'espace disponible
sudo vgs data_vg -o +vg_free

# Solution : Réduire d'autres LV ou ajouter des PV
# (sera vu dans la partie gestion LVM)
```

### Erreur : "/etc/fstab incorrect" au boot

```bash
# Problème : Système ne démarre pas (mode rescue)

# En mode rescue :
# 1. Monter la partition root
mount /dev/mapper/vg-root /mnt

# 2. Éditer fstab
nano /mnt/etc/fstab

# 3. Commenter les lignes problématiques avec #
# UUID=xxx  /mnt/home  ext4  defaults  0  2

# 4. Redémarrer
reboot
```

### Erreur : "No space left on device" avec espace libre

```bash
# Problème : Manque d'inodes, pas d'espace

# Vérifier les inodes
df -i

# Si inodes épuisés sur ext4 :
# Trouver les répertoires avec beaucoup de fichiers
sudo find /mnt/home -xdev -type d -exec sh -c \
  'echo "$(find "$1" -maxdepth 1 | wc -l) $1"' _ {} \; | sort -rn | head -20

# Solution : nettoyer ou reformater avec plus d'inodes
sudo mkfs.ext4 -N 10000000 /dev/data_vg/home_lv  # 10M inodes
```

---

## 📊 Tableau récapitulatif des commandes

|Opération|Commande|Exemple|
|---|---|---|
|**Créer PV**|`pvcreate`|`sudo pvcreate /dev/sdb`|
|**Lister PV**|`pvs` / `pvdisplay`|`sudo pvs`|
|**Créer VG**|`vgcreate`|`sudo vgcreate data_vg /dev/sdb`|
|**Lister VG**|`vgs` / `vgdisplay`|`sudo vgs`|
|**Créer LV (taille)**|`lvcreate -L`|`sudo lvcreate -n lv1 -L 10G vg1`|
|**Créer LV (%)**|`lvcreate -l`|`sudo lvcreate -n lv2 -l 50%VG vg1`|
|**Lister LV**|`lvs` / `lvdisplay`|`sudo lvs`|
|**Formater ext4**|`mkfs.ext4`|`sudo mkfs.ext4 /dev/vg/lv`|
|**Formater XFS**|`mkfs.xfs`|`sudo mkfs.xfs /dev/vg/lv`|
|**Monter**|`mount`|`sudo mount /dev/vg/lv /mnt/point`|
|**Démonter**|`umount`|`sudo umount /mnt/point`|
|**UUID**|`blkid`|`sudo blkid /dev/vg/lv`|
|**Tester fstab**|`mount -a`|`sudo mount -a`|
|**Vue d'ensemble**|`lsblk`|`lsblk -f`|

---

## 🎯 Points clés à retenir

> [!info] Ordre impératif **PV → VG → LV → Format → Mount**
> 
> Cette séquence doit toujours être respectée. On ne peut pas créer de VG sans PV, ni de LV sans VG.

> [!tip] Meilleures pratiques
> 
> 1. **Planifier** avant de créer (répartition, nommage, tailles)
> 2. **Documenter** la structure créée
> 3. **Garder de l'espace libre** (15-20%) dans les VG pour extension future
> 4. **Utiliser des UUID** dans `/etc/fstab` pour la stabilité
> 5. **Tester** avec `mount -a` avant de redémarrer
> 6. **Sauvegarder** `/etc/fstab` avant modification
> 7. **Labels explicites** pour faciliter l'identification
> 8. **Vérifier régulièrement** l'espace disque avec `df -h`

> [!warning] Points de vigilance
> 
> - ❌ Ne jamais utiliser `pvcreate` sur un disque monté
> - ❌ Ne jamais modifier `/etc/fstab` sans sauvegarde
> - ❌ Ne jamais forcer un démontage sans raison valable
> - ✅ Toujours vérifier avec `pvs`, `vgs`, `lvs` après création
> - ✅ Toujours tester le montage avant de configurer fstab
> - ✅ Toujours garder de l'espace libre pour les extensions

---

## 🏁 Conclusion

Vous maîtrisez maintenant la **création complète d'une structure LVM** :

✅ Initialisation des **volumes physiques** avec `pvcreate` ✅ Création des **groupes de volumes** avec `vgcreate` ✅ Découpage en **volumes logiques** avec `lvcreate` ✅ **Formatage** et **montage** des systèmes de fichiers ✅ Configuration du **montage automatique** dans `/etc/fstab`

Cette base solide vous permet de créer des infrastructures de stockage flexibles et évolutives. Les prochaines étapes concerneront la gestion dynamique de LVM (extension, réduction, suppression).