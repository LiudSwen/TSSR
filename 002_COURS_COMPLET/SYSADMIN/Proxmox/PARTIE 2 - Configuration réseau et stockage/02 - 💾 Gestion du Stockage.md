

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

La gestion du stockage dans Proxmox est un élément fondamental qui détermine où et comment vos machines virtuelles, conteneurs, images ISO et sauvegardes seront stockés. Proxmox offre une grande flexibilité avec différents types de stockage, chacun adapté à des cas d'usage spécifiques.

> [!info] Pourquoi c'est important Une bonne configuration du stockage impacte directement :
> 
> - Les performances de vos VMs et conteneurs
> - La facilité de gestion et de sauvegarde
> - La scalabilité de votre infrastructure
> - La redondance et la disponibilité des données

---

## Types de stockage disponibles

Proxmox supporte plusieurs types de stockage, chacun avec ses avantages et inconvénients.

### Local

**Description** : Stockage basé sur le système de fichiers local du serveur Proxmox.

**Caractéristiques** :

- Accès direct au disque dur du serveur
- Performances optimales pour un nœud unique
- Pas de partage entre plusieurs nœuds
- Simple à configurer

**Cas d'usage** :

- Installation de Proxmox
- Stockage d'images ISO et templates
- Sauvegardes locales
- Environnements de test

> [!warning] Limitation Le stockage local n'est pas partagé entre les nœuds d'un cluster. Les migrations en direct (live migration) ne sont pas possibles avec ce type de stockage.

---

### LVM (Logical Volume Manager)

**Description** : Gestionnaire de volumes logiques qui permet de créer des volumes flexibles sur des disques physiques.

**Caractéristiques** :

- Gestion avancée des volumes
- Snapshots possibles (mais consomment de l'espace)
- Allocation d'espace fixe (thick provisioning)
- Performances excellentes

**Avantages** :

- ✅ Redimensionnement des volumes à chaud
- ✅ Création de snapshots
- ✅ Gestion flexible de l'espace disque
- ✅ Performances natives du système de fichiers

**Inconvénients** :

- ❌ Allocation d'espace complète dès la création
- ❌ Snapshots consomment de l'espace supplémentaire

**Cas d'usage** :

- VMs nécessitant des performances maximales
- Environnements de production critiques
- Quand l'overprovisioning n'est pas souhaité

> [!example] Exemple de création
> 
> ```bash
> # Créer un volume group
> vgcreate vg_data /dev/sdb
> 
> # Ajouter le stockage dans Proxmox
> pvesm add lvm storage_lvm --vgname vg_data
> ```

---

### LVM-Thin

**Description** : Version "thin provisioning" de LVM qui permet l'allocation dynamique de l'espace disque.

**Caractéristiques** :

- Allocation d'espace à la demande (thin provisioning)
- Overprovisioning possible
- Snapshots très efficaces en espace
- Légère surcharge de performance par rapport à LVM

**Avantages** :

- ✅ Économie d'espace disque (seul l'espace utilisé est consommé)
- ✅ Snapshots peu coûteux en espace
- ✅ Permet d'allouer plus d'espace que disponible physiquement
- ✅ Gestion efficace des clones

**Inconvénients** :

- ❌ Risque de saturation si l'overprovisioning est mal géré
- ❌ Performances légèrement inférieures à LVM classique

**Cas d'usage** :

- Environnements de développement/test
- Quand on a beaucoup de VMs avec de l'espace non utilisé
- Disques de VMs par défaut dans Proxmox

> [!tip] Configuration par défaut C'est le type de stockage utilisé par défaut pour `local-lvm` lors de l'installation de Proxmox.

```bash
# Vérifier l'espace thin pool
lvs -a

# Exemple de sortie
# LV              VG  Attr       LSize   Pool Origin Data%  Meta%
# data            pve twi-aotz-- 150.00g             45.23  2.34
```

---

### Directory

**Description** : Stockage basé sur un répertoire du système de fichiers (ext4, xfs, etc.).

**Caractéristiques** :

- Simple et flexible
- Supporte tous les content types
- Peut être sur un disque local ou un montage réseau
- Format de fichiers standards (qcow2, raw)

**Avantages** :

- ✅ Très simple à configurer
- ✅ Compatible avec tous les types de contenu
- ✅ Formats de fichiers portables
- ✅ Facilite les sauvegardes et transferts

**Inconvénients** :

- ❌ Performances moindres que le stockage bloc (LVM)
- ❌ Overhead du système de fichiers

**Cas d'usage** :

- Stockage d'images ISO et templates
- Sauvegardes
- Partage de données entre nœuds (avec NFS)

> [!example] Ajout d'un directory
> 
> ```bash
> # Créer un point de montage
> mkdir -p /mnt/data_storage
> 
> # Ajouter dans Proxmox
> pvesm add dir data_dir --path /mnt/data_storage
> ```

---

### NFS (Network File System)

**Description** : Protocole de partage de fichiers en réseau permettant le stockage partagé entre plusieurs nœuds.

**Caractéristiques** :

- Stockage partagé entre nœuds du cluster
- Live migration possible
- Nécessite un serveur NFS
- Dépendant du réseau

**Avantages** :

- ✅ Stockage partagé pour cluster
- ✅ Live migration des VMs
- ✅ Centralisation du stockage
- ✅ Facilite les sauvegardes centralisées

**Inconvénients** :

- ❌ Performances dépendantes du réseau
- ❌ Point de défaillance unique (le serveur NFS)
- ❌ Nécessite une configuration réseau appropriée

**Cas d'usage** :

- Clusters Proxmox multi-nœuds
- Centralisation du stockage
- Environnements nécessitant la migration à chaud

> [!warning] Considérations réseau Pour des performances optimales, utilisez un réseau dédié de 10Gbps ou plus pour le trafic NFS.

```bash
# Ajouter un partage NFS
pvesm add nfs nfs_storage \
  --server 192.168.1.100 \
  --export /mnt/nfs_share \
  --content images,iso,vztmpl,backup
```

---

### iSCSI

**Description** : Protocole de stockage bloc sur IP permettant l'accès à des volumes de stockage distants.

**Caractéristiques** :

- Stockage bloc sur réseau
- Performances proches du stockage local
- Nécessite un serveur iSCSI (target)
- Complexité de configuration plus élevée

**Avantages** :

- ✅ Excellentes performances
- ✅ Protocole mature et standardisé
- ✅ Compatible avec le stockage SAN
- ✅ Permet le multipathing pour la redondance

**Inconvénients** :

- ❌ Configuration plus complexe
- ❌ Nécessite une infrastructure réseau de qualité
- ❌ Gestion des LUNs et initiateurs

**Cas d'usage** :

- Environnements entreprise avec SAN
- Besoin de performances réseau élevées
- Infrastructure de stockage centralisée

> [!info] iSCSI vs NFS iSCSI offre de meilleures performances car c'est un protocole bloc, mais NFS est plus simple à configurer et plus flexible pour le partage de fichiers.

```bash
# Ajouter un target iSCSI
pvesm add iscsi iscsi_storage \
  --portal 192.168.1.200 \
  --target iqn.2024-01.com.example:storage.target01
```

---

## Stockage local par défaut

Lors de l'installation, Proxmox crée automatiquement deux stockages locaux.

### local (Directory)

**Emplacement** : `/var/lib/vz`

**Content Types autorisés** :

- ISO images
- Container templates
- Backups
- Snippets

**Caractéristiques** :

- Basé sur le système de fichiers root (ext4)
- Utilisé pour les fichiers "légers" (ISO, templates, sauvegardes)
- Ne stocke pas les disques de VMs par défaut

```bash
# Vérifier la configuration
pvesm status --storage local

# Voir le contenu
ls -lh /var/lib/vz/
```

> [!tip] Organisation des répertoires
> 
> ```
> /var/lib/vz/
> ├── dump/          # Sauvegardes
> ├── images/        # Disques de VMs (si configuré)
> ├── template/
> │   ├── cache/     # Templates de conteneurs
> │   └── iso/       # Images ISO
> └── snippets/      # Snippets de configuration
> ```

---

### local-lvm (LVM-Thin)

**Emplacement** : Volume Group `pve`, Thin Pool `data`

**Content Types autorisés** :

- VM images (disques de VMs)
- Container volumes (disques de conteneurs)

**Caractéristiques** :

- Thin provisioning par défaut
- Performances optimales pour les disques de VMs
- Allocation dynamique de l'espace

```bash
# Vérifier le thin pool
lvs pve

# Voir les volumes logiques
lvs -a -o +devices | grep pve

# Vérifier l'utilisation
pvesm status --storage local-lvm
```

> [!warning] Surveillance de l'espace Avec le thin provisioning, surveillez régulièrement l'utilisation réelle pour éviter la saturation :
> 
> ```bash
> # Voir l'utilisation en pourcentage
> lvs -o lv_name,data_percent,metadata_percent pve
> ```

---

## Ajout d'un stockage

### Via l'interface web

1. **Naviguer vers Datacenter > Storage**
2. **Cliquer sur "Add"**
3. **Choisir le type de stockage**
4. **Remplir les paramètres requis**
5. **Sélectionner les Content Types**
6. **Valider**

> [!example] Paramètres communs
> 
> - **ID** : Identifiant unique du stockage
> - **Content** : Types de contenu autorisés
> - **Nodes** : Nœuds ayant accès au stockage
> - **Enable** : Activation du stockage
> - **Shared** : Stockage partagé entre nœuds

---

### Via la ligne de commande

Tous les types de stockage peuvent être ajoutés via la commande `pvesm`.

**Syntaxe générale** :

```bash
pvesm add <type> <storage_id> [options]
```

**Exemples pratiques** :

```bash
# 1. Ajouter un répertoire local
pvesm add dir backup_storage \
  --path /mnt/backups \
  --content backup,iso \
  --maxfiles 5

# 2. Ajouter un partage NFS
pvesm add nfs shared_storage \
  --server 192.168.1.50 \
  --export /export/proxmox \
  --content images,iso,vztmpl,backup \
  --options vers=4.2

# 3. Ajouter un stockage LVM
pvesm add lvm vm_storage \
  --vgname vg_fast \
  --content images \
  --shared 0

# 4. Ajouter un LVM-Thin
pvesm add lvmthin vm_thin_storage \
  --vgname vg_data \
  --thinpool thin_pool \
  --content images

# 5. Ajouter un target iSCSI
pvesm add iscsi san_storage \
  --portal 10.0.0.100:3260 \
  --target iqn.2024-01.com.storage:lun1
```

**Options courantes** :

|Option|Description|Exemple|
|---|---|---|
|`--content`|Types de contenu autorisés|`images,iso,backup`|
|`--nodes`|Nœuds ayant accès|`node1,node2`|
|`--disable`|Désactiver le stockage|Flag booléen|
|`--shared`|Stockage partagé|`0` ou `1`|
|`--maxfiles`|Nombre max de sauvegardes|`5`|
|`--prune-backups`|Rétention des sauvegardes|`keep-last=3`|

> [!tip] Vérification Après ajout, vérifiez toujours le stockage :
> 
> ```bash
> # Lister tous les stockages
> pvesm status
> 
> # Détails d'un stockage spécifique
> pvesm status --storage <storage_id>
> 
> # Tester l'accès
> pvesm list <storage_id>
> ```

**Modification d'un stockage existant** :

```bash
# Modifier les options
pvesm set <storage_id> --content images,backup

# Désactiver temporairement
pvesm set <storage_id> --disable 1

# Réactiver
pvesm set <storage_id> --disable 0
```

**Suppression d'un stockage** :

```bash
# Supprimer (attention, ne supprime pas les données)
pvesm remove <storage_id>
```

> [!warning] Attention à la suppression La commande `pvesm remove` supprime uniquement la configuration du stockage dans Proxmox, pas les données physiques. Assurez-vous que le stockage ne contient plus de VMs actives avant suppression.

---

## Content Types

Les content types définissent quel type de données peut être stocké sur un storage particulier.

### Types disponibles

|Content Type|Description|Extensions|
|---|---|---|
|**images**|Disques de VMs KVM|`.raw`, `.qcow2`, `.vmdk`|
|**rootdir**|Volumes root de conteneurs|Répertoires|
|**vztmpl**|Templates de conteneurs LXC|`.tar.gz`, `.tar.xz`|
|**iso**|Images ISO|`.iso`, `.img`|
|**backup**|Fichiers de sauvegarde|`.vma`, `.tar`, `.tar.gz`, `.tar.lz4`|
|**snippets**|Snippets de configuration|`.yaml`, `.sh`|

### Correspondance Storage/Content Types

> [!info] Compatibilité Tous les types de stockage ne supportent pas tous les content types.

|Type de Storage|images|rootdir|vztmpl|iso|backup|snippets|
|---|---|---|---|---|---|---|
|**Directory**|✅|✅|✅|✅|✅|✅|
|**LVM**|✅|✅|❌|❌|❌|❌|
|**LVM-Thin**|✅|✅|❌|❌|❌|❌|
|**NFS**|✅|✅|✅|✅|✅|✅|
|**iSCSI**|✅|❌|❌|❌|❌|❌|

### Configuration des Content Types

```bash
# Voir les content types actuels
pvesm status --storage <storage_id>

# Modifier les content types autorisés
pvesm set <storage_id> --content images,iso,backup

# Autoriser tous les types (pour Directory/NFS)
pvesm set <storage_id> --content images,rootdir,vztmpl,iso,backup,snippets
```

### Bonnes pratiques par Content Type

**Images (Disques de VMs)** :

- Privilégier LVM-Thin ou LVM pour les performances
- NFS acceptable pour le stockage partagé
- Éviter Directory sur disque mécanique pour la production

**ISO** :

- Directory ou NFS suffisant
- Privilégier le stockage local pour éviter le trafic réseau lors de l'installation

**Backups** :

- Directory recommandé (facilite l'accès aux fichiers)
- NFS pour centralisation
- Prévoir suffisamment d'espace (backups volumineux)

**Templates de conteneurs** :

- Directory ou NFS
- Stockage partagé pratique pour clusters

> [!example] Configuration typique
> 
> ```bash
> # Stockage pour VMs (performances)
> pvesm add lvmthin vm_storage \
>   --vgname vg_ssd \
>   --thinpool vm_pool \
>   --content images
> 
> # Stockage pour ISO et templates (capacité)
> pvesm add dir media_storage \
>   --path /mnt/media \
>   --content iso,vztmpl
> 
> # Stockage pour backups (capacité + partage)
> pvesm add nfs backup_storage \
>   --server nas.local \
>   --export /backups \
>   --content backup \
>   --maxfiles 10
> ```

---

## Bonnes pratiques

### 🎯 Planification du stockage

> [!tip] Règle d'or Séparez les types de données selon leurs besoins en performance et en capacité.

**Architecture recommandée** :

```
📦 Stockage Haute Performance (SSD/NVMe)
  └── LVM-Thin : Disques de VMs critiques

📦 Stockage Capacité (HDD)
  ├── Directory : ISO, templates
  └── NFS : Backups partagés

📦 Stockage Réseau (SAN/NAS)
  └── NFS/iSCSI : VMs moins critiques, stockage partagé
```

### 💾 Gestion de l'espace

```bash
# Monitorer l'utilisation régulièrement
pvesm status

# Vérifier les thin pools (risque de saturation)
lvs -o lv_name,data_percent,metadata_percent

# Nettoyer les vieilles sauvegardes
pvesm set <storage_id> --prune-backups keep-last=5,keep-weekly=4
```

> [!warning] Surveillance du thin provisioning Ne jamais surprovisionner plus de 150-200% de l'espace physique disponible pour éviter les saturations critiques.

### 🔒 Sécurité et redondance

**Sauvegardes** :

- Toujours sur un stockage différent du stockage principal
- Préférer un emplacement distant ou hors ligne
- Tester régulièrement les restaurations

**Snapshots** :

- Utiliser LVM-Thin pour des snapshots efficaces
- Ne pas considérer les snapshots comme des sauvegardes
- Supprimer les snapshots anciens (ils consomment de l'espace)

### ⚡ Performance

**Pour les VMs critiques** :

- LVM ou LVM-Thin sur SSD/NVMe
- Cache `writeback` pour meilleures performances (avec UPS)
- Discard/TRIM activé pour les SSD

**Pour le stockage réseau** :

- Réseau dédié >= 10Gbps
- Jumbo frames (MTU 9000) si possible
- Liens agrégés (LACP) pour la bande passante

```bash
# Optimiser un disque VM sur LVM-Thin
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,cache=writeback,discard=on,ssd=1
```

### 📊 Organisation

**Conventions de nommage** :

```bash
# Exemples clairs et cohérents
vm_ssd_storage    # VMs sur SSD
vm_hdd_storage    # VMs sur HDD
nfs_backup        # Backups NFS
local_iso         # ISO locaux
```

**Limitation d'accès** :

```bash
# Restreindre aux nœuds spécifiques
pvesm set <storage_id> --nodes node1,node2

# Utile pour stockage local non partagé
```

### 🔄 Maintenance

**Vérifications régulières** :

```bash
# Script de monitoring quotidien
#!/bin/bash
echo "=== État des stockages ==="
pvesm status

echo -e "\n=== Thin pools ==="
lvs -o lv_name,data_percent,metadata_percent pve

echo -e "\n=== Espace disque ==="
df -h | grep -E 'vz|mnt'
```

**Nettoyage périodique** :

- Supprimer les ISO inutilisés
- Archiver les anciennes sauvegardes
- Supprimer les snapshots obsolètes
- Vérifier les disques orphelins

> [!tip] Automatisation Utilisez les options `--prune-backups` et `--maxfiles` pour automatiser la rotation des sauvegardes :
> 
> ```bash
> pvesm set backup_storage --prune-backups keep-last=7,keep-weekly=4,keep-monthly=3
> ```

---

### 📝 Récapitulatif des commandes essentielles

```bash
# Lister les stockages
pvesm status

# Détails d'un stockage
pvesm status --storage <id>

# Ajouter un stockage
pvesm add <type> <id> [options]

# Modifier un stockage
pvesm set <id> [options]

# Supprimer un stockage
pvesm remove <id>

# Lister le contenu
pvesm list <id>

# Vérifier l'espace disponible
pvesm status | column -t
```

---

> [!success] Points clés à retenir
> 
> - **Choisissez le bon type** : LVM-Thin pour VMs, Directory pour ISO/backups, NFS pour partage
> - **Surveillez l'espace** : Surtout avec le thin provisioning
> - **Séparez les usages** : Performance vs capacité, critique vs non-critique
> - **Testez vos sauvegardes** : Une sauvegarde non testée n'est pas une sauvegarde
> - **Documentez** : Gardez une trace de votre architecture de stockage