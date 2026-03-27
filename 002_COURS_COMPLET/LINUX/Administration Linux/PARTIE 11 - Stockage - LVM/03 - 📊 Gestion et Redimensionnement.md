

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

## 🔍 Visualisation de l'infrastructure LVM

La visualisation est cruciale pour comprendre l'état de votre infrastructure de stockage LVM avant toute opération de maintenance. LVM propose deux ensembles de commandes : des versions courtes pour une vue d'ensemble rapide, et des versions détaillées pour l'analyse approfondie.

### Commandes de visualisation rapide

Ces commandes fournissent un résumé concis et tabulaire, idéal pour une vue d'ensemble rapide.

#### pvs - Physical Volume Summary

Affiche un résumé des volumes physiques.

```bash
# Affichage basique
pvs

# Exemple de sortie :
#   PV         VG     Fmt  Attr PSize   PFree
#   /dev/sda1  vg01   lvm2 a--  100.00g 20.00g
#   /dev/sdb1  vg01   lvm2 a--   50.00g 50.00g
```

```bash
# Options utiles
pvs -o pv_name,vg_name,pv_size,pv_free,pv_used    # Colonnes personnalisées
pvs --units g                                      # Affichage en Go
pvs -v                                             # Mode verbeux
```

> [!tip] Astuce Utilisez `pvs -o +pv_uuid` pour ajouter l'UUID aux colonnes par défaut, utile pour identifier de manière unique les disques.

#### vgs - Volume Group Summary

Affiche un résumé des groupes de volumes.

```bash
# Affichage basique
vgs

# Exemple de sortie :
#   VG     #PV #LV #SN Attr   VSize   VFree
#   vg01     2   3   0 wz--n- 149.99g  70.00g
```

```bash
# Options utiles
vgs -o vg_name,vg_size,vg_free,lv_count,pv_count  # Colonnes personnalisées
vgs --units m                                      # Affichage en Mo
vgs -a                                             # Inclut les VG internes
```

> [!info] Comprendre les attributs L'attribut `wz--n-` signifie :
> 
> - `w` : writeable (inscriptible)
> - `z` : resizable (redimensionnable)
> - `-` : pas d'allocation normale
> - `-` : pas de mirroring
> - `n` : non-clustered
> - `-` : pas de snapshots invalides

#### lvs - Logical Volume Summary

Affiche un résumé des volumes logiques.

```bash
# Affichage basique
lvs

# Exemple de sortie :
#   LV      VG     Attr       LSize  Pool Origin Data%  Meta%
#   lv_root vg01   -wi-ao---- 50.00g
#   lv_home vg01   -wi-ao---- 30.00g
```

```bash
# Options utiles
lvs -o lv_name,vg_name,lv_size,lv_path            # Colonnes personnalisées
lvs -a                                             # Affiche tous les LV (y compris cachés)
lvs --segments                                     # Vue par segments
```

> [!example] Exemple pratique Pour voir rapidement l'utilisation de tous vos volumes :
> 
> ```bash
> lvs -o lv_name,vg_name,lv_size,data_percent,metadata_percent --units g
> ```

---

### Commandes de visualisation détaillée

Ces commandes fournissent des informations exhaustives, essentielles pour le diagnostic et la planification.

#### pvdisplay - Physical Volume Display

Affiche des informations détaillées sur les volumes physiques.

```bash
# Affichage détaillé de tous les PV
pvdisplay

# Exemple de sortie :
#   --- Physical volume ---
#   PV Name               /dev/sda1
#   VG Name               vg01
#   PV Size               100.00 GiB / not usable 4.00 MiB
#   Allocatable           yes
#   PE Size               4.00 MiB
#   Total PE              25599
#   Free PE               5119
#   Allocated PE          20480
#   PV UUID               abc123-def456-...
```

```bash
# Afficher un PV spécifique
pvdisplay /dev/sda1

# Format court (similaire à pvs mais un peu plus détaillé)
pvdisplay -c

# Affichage des PV avec leur mapping
pvdisplay -m
```

> [!info] PE (Physical Extent) Les Physical Extents sont les plus petites unités d'allocation dans un PV. Par défaut, ils font 4 MiB. Le nombre total de PE détermine la capacité utilisable du PV.

#### vgdisplay - Volume Group Display

Affiche des informations détaillées sur les groupes de volumes.

```bash
# Affichage détaillé de tous les VG
vgdisplay

# Exemple de sortie :
#   --- Volume group ---
#   VG Name               vg01
#   System ID
#   Format                lvm2
#   Metadata Areas        2
#   Metadata Sequence No  15
#   VG Access             read/write
#   VG Status             resizable
#   MAX LV                0
#   Cur LV                3
#   Open LV               3
#   Max PV                0
#   Cur PV                2
#   Act PV                2
#   VG Size               149.99 GiB
#   PE Size               4.00 MiB
#   Total PE              38397
#   Alloc PE / Size       20480 / 80.00 GiB
#   Free  PE / Size       17917 / 69.99 GiB
#   VG UUID               xyz789-abc123-...
```

```bash
# Afficher un VG spécifique
vgdisplay vg01

# Format court
vgdisplay -c

# Afficher avec détails des LV
vgdisplay -v vg01
```

> [!tip] Vérification de capacité Utilisez `vgdisplay vg01 | grep "Free"` pour vérifier rapidement l'espace disponible avant une extension.

#### lvdisplay - Logical Volume Display

Affiche des informations détaillées sur les volumes logiques.

```bash
# Affichage détaillé de tous les LV
lvdisplay

# Exemple de sortie :
#   --- Logical volume ---
#   LV Path                /dev/vg01/lv_root
#   LV Name                lv_root
#   VG Name                vg01
#   LV UUID                mno345-pqr678-...
#   LV Write Access        read/write
#   LV Creation host, time server01, 2024-01-15 10:30:22 +0100
#   LV Status              available
#   # open                 1
#   LV Size                50.00 GiB
#   Current LE             12800
#   Segments               1
#   Allocation             inherit
#   Read ahead sectors     auto
#   - currently set to     256
#   Block device           253:0
```

```bash
# Afficher un LV spécifique
lvdisplay /dev/vg01/lv_root

# Format court
lvdisplay -c

# Afficher le mapping des segments
lvdisplay -m /dev/vg01/lv_root

# Afficher tous les LV (y compris cachés)
lvdisplay -a
```

> [!info] LE (Logical Extent) Les Logical Extents sont mappés 1:1 avec les Physical Extents. Leur taille est identique au PE Size du VG (généralement 4 MiB).

---

### Tableau comparatif des commandes

|Commande|Format|Usage principal|Avantages|
|---|---|---|---|
|`pvs`|Tabulaire concis|Vue d'ensemble rapide des PV|Facile à parser, vue multi-disques|
|`pvdisplay`|Détaillé verbeux|Diagnostic et analyse|Informations complètes, UUID|
|`vgs`|Tabulaire concis|Vue d'ensemble rapide des VG|Synthèse de capacité|
|`vgdisplay`|Détaillé verbeux|Planification d'extension|Détails de PE et métadonnées|
|`lvs`|Tabulaire concis|Monitoring des volumes|Vue consolidée|
|`lvdisplay`|Détaillé verbeux|Vérification pré-opération|Informations de montage et devices|

---

## 📈 Extension de volumes logiques

L'extension est l'opération la plus courante en production. Elle permet d'augmenter la capacité d'un volume logique sans interruption de service (sur la plupart des systèmes de fichiers modernes).

> [!warning] Prérequis Avant d'étendre un LV, vérifiez qu'il y a suffisamment d'espace libre dans le VG avec `vgdisplay` ou `vgs`.

### Extension du volume logique (lvextend)

La commande `lvextend` augmente la taille allouée au volume logique.

#### Syntaxe de base

```bash
lvextend [OPTIONS] /dev/VG_NAME/LV_NAME
```

#### Méthodes d'extension

**1. Extension par taille absolue**

```bash
# Étendre à une taille totale de 100G
lvextend -L 100G /dev/vg01/lv_home

# Exemple :
#   Size of logical volume vg01/lv_home changed from 30.00 GiB to 100.00 GiB
#   Logical volume vg01/lv_home successfully resized.
```

> [!warning] Attention L'option `-L` définit la taille **finale** du volume, pas la taille à ajouter. Pour ajouter 100G à la taille existante, utilisez `-L +100G`.

**2. Extension par ajout de taille**

```bash
# Ajouter 20G au volume actuel
lvextend -L +20G /dev/vg01/lv_home

# Ajouter 500M
lvextend -L +500M /dev/vg01/lv_home
```

**3. Extension en pourcentage du VG**

```bash
# Utiliser 50% de l'espace libre du VG
lvextend -l +50%FREE /dev/vg01/lv_home

# Utiliser tout l'espace libre du VG
lvextend -l +100%FREE /dev/vg01/lv_home

# Étendre à 80% de la taille totale du VG
lvextend -l 80%VG /dev/vg01/lv_home
```

> [!tip] Bonnes pratiques L'utilisation de `+100%FREE` est pratique pour allouer tout l'espace restant d'un VG à un volume.

**4. Extension par nombre d'extents**

```bash
# Ajouter 1000 extents logiques
lvextend -l +1000 /dev/vg01/lv_home

# Définir la taille à 5000 extents
lvextend -l 5000 /dev/vg01/lv_home
```

#### Extension avec système de fichiers automatique

```bash
# Étendre le LV ET le système de fichiers en une commande (recommandé)
lvextend -L +20G -r /dev/vg01/lv_home

# L'option -r (--resizefs) redimensionne automatiquement le système de fichiers
# Compatible avec ext2/ext3/ext4 et XFS
```

> [!tip] Option recommandée L'option `-r` ou `--resizefs` est le moyen le plus sûr d'étendre un volume en production. Elle gère automatiquement l'extension du système de fichiers après celle du LV.

#### Options avancées

```bash
# Mode test (n'effectue aucune modification)
lvextend -L +10G --test /dev/vg01/lv_home

# Spécifier les PV à utiliser pour l'extension
lvextend -L +20G /dev/vg01/lv_home /dev/sdb1

# Extension striped (répartition sur plusieurs disques)
lvextend -L +50G -i 2 /dev/vg01/lv_data
# -i 2 : stripe sur 2 disques
```

---

### Extension du système de fichiers

Si vous n'avez pas utilisé l'option `-r` avec `lvextend`, vous devez manuellement étendre le système de fichiers pour utiliser le nouvel espace.

#### Pour ext2/ext3/ext4 - resize2fs

```bash
# Étendre le système de fichiers au maximum
resize2fs /dev/vg01/lv_home

# Exemple de sortie :
#   resize2fs 1.46.5 (30-Dec-2021)
#   Filesystem at /dev/vg01/lv_home is mounted on /home; on-line resizing required
#   old_desc_blocks = 4, new_desc_blocks = 13
#   The filesystem on /dev/vg01/lv_home is now 26214400 (4k) blocks long.
```

```bash
# Étendre à une taille spécifique (en blocs)
resize2fs /dev/vg01/lv_home 50G

# Vérifier le système de fichiers avant redimensionnement (si non monté)
e2fsck -f /dev/vg01/lv_home
resize2fs /dev/vg01/lv_home
```

> [!info] Redimensionnement en ligne `resize2fs` peut étendre un système de fichiers ext2/ext3/ext4 **monté** (online resizing). Aucun démontage n'est nécessaire pour l'extension.

> [!tip] Vérification Après l'extension, vérifiez avec `df -h /home` que l'espace est bien disponible.

#### Pour XFS - xfs_growfs

```bash
# Étendre le système de fichiers XFS (doit être monté)
xfs_growfs /home

# OU en spécifiant le point de montage
xfs_growfs /dev/vg01/lv_home
```

```bash
# Exemple de sortie :
#   meta-data=/dev/mapper/vg01-lv_home isize=512    agcount=4, agsize=1966080 blks
#            =                          sectsz=512   attr=2, projid32bit=1
#   data     =                          bsize=4096   blocks=7864320, imaxpct=25
#            =                          sunit=0      swidth=0 blks
#   naming   =version 2                 bsize=4096   ascii-ci=0 ftype=1
#   log      =internal                  bsize=4096   blocks=3840, version=2
#   realtime =none                      extsz=4096   blocks=0, rtextents=0
#   data blocks changed from 7864320 to 26214400
```

> [!warning] XFS : montage obligatoire Contrairement à `resize2fs`, `xfs_growfs` nécessite que le système de fichiers soit **monté**. De plus, XFS ne peut être étendu que vers le haut, jamais réduit.

#### Workflow complet d'extension

```bash
# 1. Vérifier l'espace disponible
vgs vg01

# 2. Étendre le LV et le système de fichiers en une commande
lvextend -L +20G -r /dev/vg01/lv_home

# 3. Vérifier le résultat
df -h /home
lvs vg01/lv_home
```

> [!example] Exemple pratique complet Extension d'un volume `/home` de 30G à 80G :
> 
> ```bash
> # État initial
> df -h /home
> # /dev/mapper/vg01-lv_home   30G   25G  3.8G  87% /home
> 
> # Vérification VG
> vgs vg01
> # VG     #PV #LV #SN Attr   VSize   VFree
> # vg01     2   3   0 wz--n- 149.99g  70.00g
> 
> # Extension (50G disponibles, j'en ajoute 50G)
> lvextend -L +50G -r /dev/vg01/lv_home
> 
> # Vérification finale
> df -h /home
> # /dev/mapper/vg01-lv_home   80G   25G   52G  33% /home
> ```

---

## 📉 Réduction de volumes logiques

La réduction est une opération **délicate et risquée**. Elle nécessite de réduire le système de fichiers avant de réduire le LV pour éviter la perte de données.

> [!warning] Risques majeurs
> 
> - La réduction peut entraîner une **perte de données** si mal exécutée
> - Toujours faire une **sauvegarde complète** avant de réduire
> - Ne jamais réduire un LV en dessous de la taille des données qu'il contient

> [!info] XFS ne peut pas être réduit Le système de fichiers XFS ne supporte **pas** la réduction. Si vous devez réduire un volume XFS, vous devez :
> 
> 1. Sauvegarder les données
> 2. Recréer le LV à la taille souhaitée
> 3. Reformater en XFS
> 4. Restaurer les données

### Réduction pour ext2/ext3/ext4

#### Workflow de réduction sécurisée

```bash
# 1. SAUVEGARDE OBLIGATOIRE
tar -czf /backup/home_backup.tar.gz /home

# 2. Démonter le système de fichiers
umount /home

# 3. Vérifier l'intégrité du système de fichiers
e2fsck -f /dev/vg01/lv_home
```

```bash
# 4. Réduire le système de fichiers à la taille cible
#    IMPORTANT : réduire LE SYSTÈME DE FICHIERS EN PREMIER
resize2fs /dev/vg01/lv_home 20G

# Exemple de sortie :
#   resize2fs 1.46.5 (30-Dec-2021)
#   Resizing the filesystem on /dev/vg01/lv_home to 5242880 (4k) blocks.
#   The filesystem on /dev/vg01/lv_home is now 5242880 (4k) blocks long.
```

```bash
# 5. Réduire le volume logique
#    IMPORTANT : la taille du LV doit être ≥ à celle du système de fichiers
lvreduce -L 20G /dev/vg01/lv_home

# Confirmation demandée :
#   WARNING: Reducing active logical volume to 20.00 GiB.
#   THIS MAY DESTROY YOUR DATA (filesystem etc.)
# Do you really want to reduce vg01/lv_home? [y/n]: y
#   Size of logical volume vg01/lv_home changed from 50.00 GiB to 20.00 GiB.
#   Logical volume vg01/lv_home successfully resized.
```

```bash
# 6. Remonter le système de fichiers
mount /home

# 7. Vérifier le résultat
df -h /home
lvs vg01/lv_home
```

#### Syntaxe de lvreduce

```bash
# Réduire à une taille absolue
lvreduce -L 20G /dev/vg01/lv_home

# Réduire de X Go
lvreduce -L -10G /dev/vg01/lv_home

# Réduire de X extents
lvreduce -l -2000 /dev/vg01/lv_home

# Forcer sans confirmation (dangereux)
lvreduce -L 20G -f /dev/vg01/lv_home
```

> [!warning] Ordre impératif **TOUJOURS dans cet ordre :**
> 
> 1. Sauvegarder
> 2. Démonter
> 3. Vérifier (e2fsck)
> 4. Réduire le système de fichiers (resize2fs)
> 5. Réduire le LV (lvreduce)
> 6. Remonter
> 
> **Jamais l'inverse !** Réduire le LV avant le système de fichiers causera une corruption des données.

#### Réduction avec marge de sécurité

```bash
# Bonne pratique : laisser une marge de 5-10% lors de la réduction du FS
# Si vous voulez un LV final de 20G :

# 1. Réduire le FS à 19G (marge de 1G)
resize2fs /dev/vg01/lv_home 19G

# 2. Réduire le LV à 20G
lvreduce -L 20G /dev/vg01/lv_home

# 3. Ré-étendre le FS au maximum du LV
resize2fs /dev/vg01/lv_home
```

> [!tip] Marge de sécurité Cette technique évite les risques d'avoir un système de fichiers légèrement plus grand que le LV, ce qui causerait une corruption.

---

### Tableau comparatif extension vs réduction

|Aspect|Extension|Réduction|
|---|---|---|
|**Risque**|Très faible|Élevé (perte de données possible)|
|**En ligne (ext4)**|Oui|Non (démontage requis)|
|**En ligne (XFS)**|Oui|Impossible|
|**Ordre opérations**|LV puis FS (ou simultané avec -r)|FS puis LV|
|**Vérification pré-op**|Optionnelle|Obligatoire (e2fsck)|
|**Sauvegarde**|Recommandée|**OBLIGATOIRE**|
|**Réversibilité**|Difficile|Facile (ré-extension)|

---

## ✅ Workflow complet et bonnes pratiques

### Checklist avant toute opération

> [!info] Checklist pré-opération
> 
> - [ ] Vérifier l'espace disponible avec `vgs` ou `vgdisplay`
> - [ ] Vérifier l'utilisation actuelle avec `df -h`
> - [ ] Créer une sauvegarde (surtout pour réduction)
> - [ ] Tester la commande avec `--test` si disponible
> - [ ] Planifier une fenêtre de maintenance pour la réduction
> - [ ] Documenter l'opération (état avant/après)

### Commandes de vérification post-opération

```bash
# Vérifier la nouvelle taille du LV
lvs /dev/vg01/lv_home

# Vérifier le système de fichiers
df -h /home

# Vérifier l'intégrité (si ext2/3/4, non monté)
e2fsck -n /dev/vg01/lv_home

# Vérifier l'espace libre restant dans le VG
vgs vg01
```

### Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> **1. Oublier d'étendre le système de fichiers**
> 
> ```bash
> # ❌ Erreur : le LV est étendu mais pas le FS
> lvextend -L +20G /dev/vg01/lv_home
> # Résultat : df -h montre toujours l'ancienne taille
> 
> # ✅ Solution : toujours utiliser -r ou exécuter resize2fs/xfs_growfs
> lvextend -L +20G -r /dev/vg01/lv_home
> ```
> 
> **2. Réduire le LV avant le système de fichiers**
> 
> ```bash
> # ❌ DANGER : perte de données garantie
> lvreduce -L 20G /dev/vg01/lv_home
> resize2fs /dev/vg01/lv_home
> 
> # ✅ Bon ordre
> resize2fs /dev/vg01/lv_home 20G
> lvreduce -L 20G /dev/vg01/lv_home
> ```
> 
> **3. Confondre -L (taille absolue) et -L + (ajout)**
> 
> ```bash
> # ❌ Erreur : réduit le volume à 10G au lieu d'ajouter 10G
> lvextend -L 10G /dev/vg01/lv_home  # Si le LV fait 50G, il passera à 10G !
> 
> # ✅ Correct : ajoute 10G
> lvextend -L +10G /dev/vg01/lv_home
> ```
> 
> **4. Tenter de réduire XFS**
> 
> ```bash
> # ❌ Impossible
> xfs_shrink /dev/vg01/lv_home  # Cette commande n'existe pas
> 
> # ✅ Solution : sauvegarder, recréer, restaurer
> ```

### Scripts d'automatisation

**Script d'extension sécurisée**

```bash
#!/bin/bash
# extend_lv.sh - Extension sécurisée d'un LV

LV_PATH=$1
SIZE=$2

if [ -z "$LV_PATH" ] || [ -z "$SIZE" ]; then
    echo "Usage: $0 /dev/VG/LV +SIZE"
    exit 1
fi

echo "=== Extension de $LV_PATH de $SIZE ==="

# Vérification pré-opération
echo "État avant :"
lvs "$LV_PATH"
df -h | grep "$LV_PATH"

# Sauvegarde des informations
lvdisplay "$LV_PATH" > "/tmp/lv_backup_$(date +%Y%m%d_%H%M%S).txt"

# Extension avec système de fichiers
echo "Extension en cours..."
lvextend -L "$SIZE" -r "$LV_PATH"

if [ $? -eq 0 ]; then
    echo "✓ Extension réussie"
    echo "État après :"
    lvs "$LV_PATH"
    df -h | grep "$LV_PATH"
else
    echo "✗ Erreur lors de l'extension"
    exit 1
fi
```

### Monitoring et alertes

```bash
# Surveiller l'utilisation des LV
lvs -o lv_name,vg_name,lv_size,data_percent | awk '$4 > 80 {print "ALERTE: " $0}'

# Surveiller l'espace libre dans les VG
vgs -o vg_name,vg_free --units g | awk '$2+0 < 10 {print "ALERTE VG: " $0}'

# Script de monitoring à mettre dans cron
watch -n 60 'df -h | grep -E "vg01|Filesystem"'
```

---

## 📝 Récapitulatif des commandes essentielles

|Opération|Commande|Usage|
|---|---|---|
|**Visualisation**|||
|Vue rapide PV|`pvs`|Lister tous les PV|
|Vue rapide VG|`vgs`|Lister tous les VG|
|Vue rapide LV|`lvs`|Lister tous les LV|
|Détails PV|`pvdisplay /dev/sda1`|Informations complètes d'un PV|
|Détails VG|`vgdisplay vg01`|Informations complètes d'un VG|
|Détails LV|`lvdisplay /dev/vg01/lv_home`|Informations complètes d'un LV|
|**Extension**|||
|Étendre LV+FS|`lvextend -L +20G -r /dev/vg01/lv_home`|Extension complète recommandée|
|Étendre LV seul|`lvextend -L +20G /dev/vg01/lv_home`|Extension du LV uniquement|
|Tout l'espace|`lvextend -l +100%FREE -r /dev/vg01/lv_home`|Utiliser tout l'espace libre|
|Étendre ext4|`resize2fs /dev/vg01/lv_home`|Extension FS ext2/3/4|
|Étendre XFS|`xfs_growfs /home`|Extension FS XFS (monté)|
|**Réduction**|||
|Réduire ext4|`resize2fs /dev/vg01/lv_home 20G`|Réduire FS en premier|
|Réduire LV|`lvreduce -L 20G /dev/vg01/lv_home`|Réduire LV après FS|
|**Vérification**|||
|Vérifier FS|`e2fsck -f /dev/vg01/lv_home`|Vérifier ext2/3/4|
|Espace disque|`df -h /home`|Vérifier utilisation FS|

---

> [!tip] Mémo final
> 
> - Pour l'**extension** : utilisez toujours `lvextend -r` pour une opération en une étape
> - Pour la **réduction** : sauvegarde → démonter → e2fsck → resize2fs → lvreduce → remonter
> - XFS ne se réduit jamais, mais s'étend facilement avec `xfs_growfs`
> - Toujours vérifier l'espace disponible dans le VG avant extension
> - La visualisation régulière avec `pvs`, `vgs`, `lvs` permet d'anticiper les besoins

---

## 🎯 Scénarios pratiques courants

### Scénario 1 : Extension d'urgence d'un volume root plein

```bash
# Situation : /dev/vg01/lv_root est plein à 95%
df -h /
# Filesystem                Size  Used Avail Use% Mounted on
# /dev/mapper/vg01-lv_root   50G   48G  1.2G  98% /

# 1. Vérifier l'espace disponible dans le VG
vgs vg01
# VG     #PV #LV #SN Attr   VSize   VFree
# vg01     2   3   0 wz--n- 149.99g  30.00g

# 2. Extension rapide avec système de fichiers
lvextend -L +20G -r /dev/vg01/lv_root

# 3. Vérification immédiate
df -h /
# Filesystem                Size  Used Avail Use% Mounted on
# /dev/mapper/vg01-lv_root   70G   48G   20G  71% /
```

### Scénario 2 : Allocation de tout l'espace restant

```bash
# Situation : vous voulez donner tout l'espace libre à /home
vgs vg01
# VG     #PV #LV #SN Attr   VSize   VFree
# vg01     2   3   0 wz--n- 149.99g  50.00g

# Extension avec 100% de l'espace libre
lvextend -l +100%FREE -r /dev/vg01/lv_home

# Vérification
lvs vg01
vgs vg01  # VFree devrait être à 0
```

### Scénario 3 : Réduction pour libérer de l'espace

```bash
# Situation : /dev/vg01/lv_backup utilise 100G mais ne contient que 30G de données
# Objectif : réduire à 40G pour libérer 60G

# 1. Sauvegarde de sécurité
rsync -av /backup/ /mnt/external_backup/

# 2. Démonter
umount /backup

# 3. Vérifier l'intégrité
e2fsck -f /dev/vg01/lv_backup

# 4. Réduire le système de fichiers à 38G (marge de sécurité de 2G)
resize2fs /dev/vg01/lv_backup 38G

# 5. Réduire le LV à 40G
lvreduce -L 40G /dev/vg01/lv_backup

# 6. Ré-étendre le système de fichiers au maximum
resize2fs /dev/vg01/lv_backup

# 7. Remonter
mount /backup

# 8. Vérifier
df -h /backup
vgs vg01  # VFree devrait avoir augmenté de 60G
```

### Scénario 4 : Extension avec choix de disque spécifique

```bash
# Situation : vous avez ajouté un nouveau SSD rapide (/dev/sdc1) au VG
# et voulez que le LV de base de données utilise ce disque

# 1. Vérifier les PV disponibles
pvs
# PV         VG     Fmt  Attr PSize   PFree
# /dev/sda1  vg01   lvm2 a--  100.00g 10.00g
# /dev/sdb1  vg01   lvm2 a--   50.00g  5.00g
# /dev/sdc1  vg01   lvm2 a--  200.00g 200.00g  ← nouveau SSD

# 2. Étendre en spécifiant le PV à utiliser
lvextend -L +50G -r /dev/vg01/lv_database /dev/sdc1

# 3. Vérifier que l'espace a bien été pris sur le bon disque
pvs
# PV         VG     Fmt  Attr PSize   PFree
# /dev/sda1  vg01   lvm2 a--  100.00g 10.00g
# /dev/sdb1  vg01   lvm2 a--   50.00g  5.00g
# /dev/sdc1  vg01   lvm2 a--  200.00g 150.00g  ← l'espace a été utilisé ici
```

### Scénario 5 : Extension progressive planifiée

```bash
# Situation : planification d'extension sur plusieurs mois
# Mois 1 : +10G, Mois 2 : +10G, etc.

# Script de planification
#!/bin/bash
# plan_extension.sh

LV="/dev/vg01/lv_data"
INCREMENT="+10G"

echo "=== Planification d'extension ==="
echo "LV: $LV"
echo "État actuel:"
lvs "$LV" -o lv_name,lv_size
vgs -o vg_name,vg_free

# Calcul du nombre d'extensions possibles
VG_FREE=$(vgs --noheadings -o vg_free --units g vg01 | tr -d ' G')
INCREMENT_SIZE=10
POSSIBLE_EXTENSIONS=$((${VG_FREE%.*} / INCREMENT_SIZE))

echo ""
echo "Espace libre: ${VG_FREE}G"
echo "Extensions possibles de 10G: $POSSIBLE_EXTENSIONS"
echo ""
echo "Plan d'extension suggéré:"
for i in $(seq 1 $POSSIBLE_EXTENSIONS); do
    echo "  Mois $i: lvextend -L +10G -r $LV"
done
```

---

## 🔧 Dépannage et résolution de problèmes

### Problème 1 : "Insufficient free space"

```bash
# Erreur lors de l'extension
lvextend -L +50G /dev/vg01/lv_home
# Insufficient free space: 12800 extents needed, but only 5120 available

# Diagnostic
vgs vg01
# VG     #PV #LV #SN Attr   VSize   VFree
# vg01     2   3   0 wz--n- 149.99g  20.00g

# Solution 1 : réduire la taille demandée
lvextend -L +20G -r /dev/vg01/lv_home

# Solution 2 : ajouter un nouveau PV au VG (si possible)
# pvcreate /dev/sdd1
# vgextend vg01 /dev/sdd1
# lvextend -L +50G -r /dev/vg01/lv_home

# Solution 3 : réduire un autre LV pour libérer de l'espace
# (voir scénario 3)
```

### Problème 2 : Système de fichiers non étendu après lvextend

```bash
# Symptôme
lvextend -L +20G /dev/vg01/lv_home  # Sans -r
df -h /home  # La taille n'a pas changé !

# Diagnostic
lvs /dev/vg01/lv_home  # Montre la nouvelle taille
df -h /home            # Montre l'ancienne taille

# Solution pour ext4
resize2fs /dev/vg01/lv_home

# Solution pour XFS
xfs_growfs /home

# Vérification
df -h /home  # Devrait montrer la nouvelle taille
```

### Problème 3 : "Can't resize mounted filesystem" (XFS)

```bash
# Erreur
xfs_growfs /dev/vg01/lv_home
# xfs_growfs: /dev/vg01/lv_home is not a mounted XFS filesystem

# Cause : XFS nécessite le point de montage, pas le device

# Solution
xfs_growfs /home  # Utiliser le point de montage

# OU
xfs_growfs $(findmnt -n -o TARGET /dev/vg01/lv_home)
```

### Problème 4 : Erreur lors de la réduction

```bash
# Erreur
lvreduce -L 20G /dev/vg01/lv_home
# Refusing to reduce active logical volume below 25.00 GiB
# Please reduce filesystem size first

# Cause : le système de fichiers n'a pas été réduit en premier

# Solution : suivre l'ordre correct
umount /home
e2fsck -f /dev/vg01/lv_home
resize2fs /dev/vg01/lv_home 20G  # ← Étape manquante
lvreduce -L 20G /dev/vg01/lv_home
mount /home
```

### Problème 5 : Corruption après réduction mal exécutée

```bash
# Symptôme
mount /home
# mount: wrong fs type, bad option, bad superblock on /dev/vg01/lv_home

# Diagnostic
e2fsck -n /dev/vg01/lv_home  # Mode lecture seule
# Superblock invalid

# Solution (si sauvegarde disponible)
# 1. Restaurer depuis la sauvegarde
# 2. Ou tenter de récupérer avec un superblock de secours

# Lister les superblocks de secours
dumpe2fs /dev/vg01/lv_home | grep -i superblock

# Tenter la réparation avec un superblock alternatif
e2fsck -b 32768 /dev/vg01/lv_home

# Si réparation impossible : restaurer depuis sauvegarde
mkfs.ext4 /dev/vg01/lv_home
mount /home
rsync -av /backup/home_backup/ /home/
```

> [!warning] Leçon importante Ce problème illustre pourquoi la sauvegarde avant réduction est **non négociable**. Sans sauvegarde, la perte de données est définitive.

---

## 📊 Optimisation et bonnes pratiques avancées

### Stratégie d'allocation d'espace

```bash
# Bonne pratique : ne pas allouer 100% du VG immédiatement
# Garder toujours 10-15% d'espace libre pour la flexibilité

# Exemple de stratégie d'allocation pour un VG de 500G :
# - lv_root:     50G  (10%)   - système
# - lv_var:      100G (20%)   - logs et données variables
# - lv_home:     150G (30%)   - utilisateurs
# - lv_data:     150G (30%)   - applications
# - Libre:       50G  (10%)   - réserve

# Vérifier l'allocation actuelle
vgs -o vg_name,vg_size,vg_free,vg_free_percent
```

### Monitoring proactif

```bash
# Script de monitoring à placer dans /usr/local/bin/check_lvm.sh
#!/bin/bash

THRESHOLD=80
EMAIL="admin@example.com"

echo "=== LVM Health Check $(date) ===" > /tmp/lvm_report.txt

# Vérifier les LV
lvs -o lv_name,vg_name,lv_size,data_percent --noheadings | while read LV VG SIZE PERCENT; do
    if [ ! -z "$PERCENT" ]; then
        PERCENT_INT=${PERCENT%.*}
        if [ "$PERCENT_INT" -gt "$THRESHOLD" ]; then
            echo "ALERTE: $VG/$LV utilise ${PERCENT}% (seuil: ${THRESHOLD}%)" >> /tmp/lvm_report.txt
        fi
    fi
done

# Vérifier les VG
vgs -o vg_name,vg_free --units g --noheadings | while read VG FREE; do
    FREE_INT=${FREE%.*}
    if [ "$FREE_INT" -lt 10 ]; then
        echo "ALERTE: VG $VG a seulement ${FREE}G libre" >> /tmp/lvm_report.txt
    fi
done

# Envoyer par email si des alertes
if grep -q "ALERTE" /tmp/lvm_report.txt; then
    mail -s "LVM Alert" "$EMAIL" < /tmp/lvm_report.txt
fi
```

```bash
# Ajouter au crontab pour exécution quotidienne
# crontab -e
# 0 8 * * * /usr/local/bin/check_lvm.sh
```

### Documentation automatique de l'infrastructure

```bash
# Script pour documenter l'état du LVM
#!/bin/bash
# lvm_documentation.sh

OUTPUT="/root/lvm_state_$(date +%Y%m%d).txt"

{
    echo "======================================"
    echo "Documentation LVM - $(date)"
    echo "======================================"
    echo ""
    
    echo "=== Physical Volumes ==="
    pvdisplay
    echo ""
    
    echo "=== Volume Groups ==="
    vgdisplay
    echo ""
    
    echo "=== Logical Volumes ==="
    lvdisplay
    echo ""
    
    echo "=== Résumé tabulaire ==="
    echo "--- PV ---"
    pvs
    echo ""
    echo "--- VG ---"
    vgs
    echo ""
    echo "--- LV ---"
    lvs
    echo ""
    
    echo "=== Utilisation des systèmes de fichiers ==="
    df -h | grep -E "Filesystem|/dev/mapper"
    echo ""
    
    echo "=== Configuration fstab ==="
    grep -E "^/dev/mapper|^UUID.*vg" /etc/fstab
    
} > "$OUTPUT"

echo "Documentation générée : $OUTPUT"
```

### Performance : striping et allocation

```bash
# Pour améliorer les performances, utiliser le striping sur plusieurs disques

# Créer un LV stripé sur 2 disques
lvcreate -L 100G -i 2 -I 64K -n lv_fast vg01 /dev/sdb1 /dev/sdc1
# -i 2 : stripe sur 2 disques
# -I 64K : taille de stripe de 64KB (bon pour les bases de données)

# Étendre un LV existant avec striping
lvextend -L +50G -i 2 /dev/vg01/lv_data /dev/sdb1 /dev/sdc1

# Vérifier la configuration de striping
lvs -o +stripes,stripe_size /dev/vg01/lv_fast
```

---

## 🎓 Points clés à retenir

> [!info] Résumé des concepts essentiels
> 
> **Visualisation**
> 
> - `pvs`, `vgs`, `lvs` : vue rapide et tabulaire
> - `pvdisplay`, `vgdisplay`, `lvdisplay` : informations détaillées
> - Toujours vérifier l'état avant modification
> 
> **Extension**
> 
> - Opération sûre et réversible (techniquement)
> - `lvextend -L +SIZE -r` : méthode recommandée (LV + FS en une fois)
> - Peut être faite en ligne sur ext4 et XFS
> - Toujours vérifier l'espace libre dans le VG avant
> 
> **Réduction**
> 
> - Opération risquée nécessitant sauvegarde
> - Ordre impératif : FS d'abord, LV ensuite
> - Nécessite démontage pour ext2/3/4
> - **Impossible sur XFS**
> - Toujours laisser une marge de sécurité
> 
> **Systèmes de fichiers**
> 
> - ext2/3/4 : `resize2fs` (extension en ligne, réduction hors ligne)
> - XFS : `xfs_growfs` (extension uniquement, montage requis)
> 
> **Sécurité**
> 
> - Sauvegarde avant réduction : non négociable
> - Vérification avec `e2fsck -f` avant réduction
> - Utiliser `--test` pour simuler sans modifier
> - Documenter chaque opération

---

## 📖 Aide-mémoire des options principales

### lvextend

|Option|Description|Exemple|
|---|---|---|
|`-L SIZE`|Taille absolue finale|`-L 100G`|
|`-L +SIZE`|Ajouter de la taille|`-L +20G`|
|`-l EXTENTS`|Nombre d'extents|`-l 5000`|
|`-l +EXTENTS`|Ajouter des extents|`-l +1000`|
|`-l +X%FREE`|Pourcentage espace libre|`-l +50%FREE`|
|`-l +100%FREE`|Tout l'espace libre|`-l +100%FREE`|
|`-r, --resizefs`|Redimensionner le FS|`-r`|
|`--test`|Mode simulation|`--test`|

### lvreduce

|Option|Description|Exemple|
|---|---|---|
|`-L SIZE`|Taille absolue finale|`-L 20G`|
|`-L -SIZE`|Retirer de la taille|`-L -10G`|
|`-l EXTENTS`|Nombre d'extents|`-l 3000`|
|`-f, --force`|Forcer sans confirmation|`-f`|

### resize2fs (ext2/3/4)

|Commande|Description|
|---|---|
|`resize2fs /dev/vg/lv`|Étendre au maximum du LV|
|`resize2fs /dev/vg/lv 20G`|Redimensionner à 20G|
|`e2fsck -f /dev/vg/lv`|Vérifier avant réduction|

### xfs_growfs (XFS)

|Commande|Description|
|---|---|
|`xfs_growfs /mountpoint`|Étendre au maximum (montage requis)|
|`xfs_growfs -D size /mountpoint`|Étendre à une taille spécifique|

---

> [!success] Félicitations ! Vous maîtrisez maintenant la gestion et le redimensionnement des volumes LVM. Ces compétences sont essentielles pour tout administrateur système Linux gérant du stockage en production.