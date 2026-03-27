

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

La restauration est l'étape cruciale qui valide l'utilité d'une stratégie de sauvegarde. Proxmox offre plusieurs méthodes de restauration adaptées à différents scénarios : récupération complète d'une VM/CT, extraction de fichiers individuels, ou migration vers un autre nœud du cluster.

> [!info] Pourquoi maîtriser la restauration ? Une sauvegarde non testée est une sauvegarde inexistante. La capacité à restaurer rapidement et correctement vos machines virtuelles est essentielle pour garantir la continuité de service et minimiser les temps d'arrêt en cas d'incident.

---

## Restauration complète

La restauration complète recrée une VM ou un conteneur à partir d'une sauvegarde, avec toutes ses configurations et données.

### Via l'interface web

**Étapes de restauration :**

1. **Accéder aux sauvegardes** :
    
    - Sélectionnez votre stockage de sauvegarde dans l'arborescence
    - Cliquez sur "Backups" dans le menu
    - Localisez la sauvegarde à restaurer
2. **Lancer la restauration** :
    
    - Sélectionnez la sauvegarde
    - Cliquez sur "Restore"
    - Choisissez le VMID (nouvel ID ou ID existant)
3. **Configurer les options** :
    
    - **Storage** : où restaurer les disques
    - **Unique** : générer de nouvelles adresses MAC
    - **Start after restore** : démarrer automatiquement après restauration
    - **Override settings** : modifier la configuration pendant la restauration

> [!example] Exemple de restauration Pour restaurer la VM 100 avec un nouvel ID 150 :
> 
> - Sélectionnez la sauvegarde `vzdump-qemu-100-...`
> - VMID : 150
> - Cochez "Unique" pour éviter les conflits réseau
> - Sélectionnez le stockage cible
> - Validez

### Via la ligne de commande

**Restauration d'une VM (KVM) :**

```bash
# Restauration basique
qmrestore /var/lib/vz/dump/vzdump-qemu-100-2024_12_24-12_00_00.vma.zst 150

# Restauration avec options spécifiques
qmrestore /var/lib/vz/dump/vzdump-qemu-100-2024_12_24-12_00_00.vma.zst 150 \
  --storage local-lvm \
  --unique 1

# Restauration avec personnalisation
qmrestore /var/lib/vz/dump/vzdump-qemu-100-2024_12_24-12_00_00.vma.zst 150 \
  --storage local-lvm \
  --unique 1 \
  --pool Production \
  --bwlimit 50000
```

**Restauration d'un conteneur (LXC) :**

```bash
# Restauration basique
pct restore 250 /var/lib/vz/dump/vzdump-lxc-200-2024_12_24-12_00_00.tar.zst

# Restauration avec stockage spécifique
pct restore 250 /var/lib/vz/dump/vzdump-lxc-200-2024_12_24-12_00_00.tar.zst \
  --storage local-lvm

# Restauration avec configuration réseau
pct restore 250 /var/lib/vz/dump/vzdump-lxc-200-2024_12_24-12_00_00.tar.zst \
  --storage local-lvm \
  --hostname newct \
  --net0 name=eth0,bridge=vmbr0,ip=192.168.1.150/24,gw=192.168.1.1
```

### Options de restauration

**Options communes :**

|Option|Description|Usage|
|---|---|---|
|`--storage`|Stockage de destination|Obligatoire si différent de l'origine|
|`--unique`|Génère de nouvelles adresses MAC/UUID|Évite les conflits réseau|
|`--bwlimit`|Limite de bande passante (Ko/s)|Évite de saturer le réseau|
|`--pool`|Pool de ressources|Organisation logique|
|`--force`|Force l'écrasement|**Attention : destructif !**|

**Options spécifiques VM (qmrestore) :**

```bash
# Restauration sur un stockage différent pour chaque disque
qmrestore backup.vma.zst 150 \
  --storage local-lvm \
  --scsi0 ssd-storage:0 \
  --scsi1 hdd-storage:0

# Restauration avec modification de la bande passante
qmrestore backup.vma.zst 150 \
  --bwlimit 100000  # 100 Mo/s
```

**Options spécifiques CT (pct restore) :**

```bash
# Restauration avec configuration réseau personnalisée
pct restore 250 backup.tar.zst \
  --hostname web-server-02 \
  --password \
  --net0 name=eth0,bridge=vmbr1,ip=10.0.0.50/24

# Restauration avec modification des ressources
pct restore 250 backup.tar.zst \
  --cores 4 \
  --memory 4096 \
  --rootfs local-lvm:20
```

> [!warning] Écrasement de VM existante L'option `--force` permet d'écraser une VM/CT existante, mais **toutes les données actuelles seront perdues**. Utilisez cette option uniquement si vous êtes certain de votre action.

> [!tip] Astuce - Validation avant restauration Vérifiez toujours le contenu d'une sauvegarde avant restauration :
> 
> ```bash
> # Pour une VM
> qmrestore backup.vma.zst 999 --dryrun
> 
> # Lister le contenu d'une sauvegarde
> tar -tzf backup.tar.zst | head -20
> ```

---

## Restauration de fichiers

Parfois, vous n'avez besoin que de quelques fichiers spécifiques plutôt que d'une restauration complète. Proxmox permet d'extraire des fichiers individuels depuis une sauvegarde.

### Montage d'une sauvegarde

**Pour les conteneurs LXC :**

Les sauvegardes LXC sont des archives tar compressées, donc relativement faciles à manipuler.

```bash
# Créer un répertoire de montage
mkdir -p /mnt/restore

# Extraire la sauvegarde
tar -xzf /var/lib/vz/dump/vzdump-lxc-200-2024_12_24-12_00_00.tar.zst -C /mnt/restore

# Naviguer dans les fichiers
cd /mnt/restore
ls -la

# Après extraction, les fichiers sont dans /mnt/restore/
```

**Pour les VM (KVM) :**

Les sauvegardes de VM utilisent le format VMA (Proxmox VM Archive) qui nécessite des outils spécifiques.

```bash
# Extraire le contenu VMA
vma extract /var/lib/vz/dump/vzdump-qemu-100-2024_12_24-12_00_00.vma.zst /mnt/restore

# Monter l'image disque extraite
# D'abord, identifier les partitions
kpartx -av /mnt/restore/disk-scsi0.raw

# Monter la partition désirée
mount /dev/mapper/loop0p1 /mnt/disk

# Accéder aux fichiers
cd /mnt/disk
```

> [!info] Format VMA Le format VMA encapsule les disques VM et leurs configurations. L'outil `vma` permet d'extraire ces données sans restaurer complètement la VM.

### Extraction de fichiers spécifiques

**Méthode directe pour LXC :**

```bash
# Extraire uniquement un fichier spécifique
tar -xzf backup.tar.zst -C /tmp ./etc/nginx/nginx.conf

# Extraire un répertoire complet
tar -xzf backup.tar.zst -C /tmp ./var/www/html/

# Lister le contenu sans extraire
tar -tzf backup.tar.zst | grep "nginx"
```

**Méthode pour VM avec vma :**

```bash
# 1. Extraire la sauvegarde VMA
vma extract backup.vma.zst /tmp/vm-extract

# 2. Monter le disque avec guestmount (libguestfs)
guestmount -a /tmp/vm-extract/disk-scsi0.raw -m /dev/sda1 /mnt/vmfiles --ro

# 3. Copier les fichiers nécessaires
cp -a /mnt/vmfiles/etc/apache2/apache2.conf /root/recovered/

# 4. Démonter
guestunmount /mnt/vmfiles
```

**Alternative avec virt-copy-out :**

```bash
# Copier un fichier directement depuis l'image disque
virt-copy-out -a /tmp/vm-extract/disk-scsi0.raw /etc/passwd /tmp/

# Copier un répertoire complet
virt-copy-out -a /tmp/vm-extract/disk-scsi0.raw /var/log /tmp/logs/
```

> [!tip] Astuce - libguestfs Installez les outils libguestfs pour manipuler facilement les images disque :
> 
> ```bash
> apt install libguestfs-tools
> ```

### Restauration sélective

**Scénario : restaurer uniquement certains disques d'une VM**

```bash
# Extraire la configuration de la sauvegarde
vzdump extract /var/lib/vz/dump/backup.vma.zst /tmp/config

# Examiner la configuration
cat /tmp/config/qemu-server.conf

# Restaurer avec sélection de disques
qmrestore backup.vma.zst 150 \
  --storage local-lvm \
  --scsi0 local-lvm:0  # Restaure uniquement scsi0
  # Les autres disques ne seront pas restaurés
```

**Restauration partielle de conteneur :**

```bash
# Extraire la sauvegarde complète
tar -xzf backup.tar.zst -C /tmp/ct-extract

# Copier sélectivement dans un conteneur existant
pct enter 250

# Depuis l'intérieur du conteneur
cp -a /tmp/ct-extract/var/www/html/* /var/www/html/
chown -R www-data:www-data /var/www/html
```

> [!warning] Attention aux permissions Lors de la restauration manuelle de fichiers, vérifiez toujours :
> 
> - Les propriétaires (owner/group)
> - Les permissions (chmod)
> - Les contextes SELinux si applicable
> - Les attributs étendus (xattr)

> [!example] Cas d'usage - Base de données corrompue Vous avez une VM avec une base de données corrompue mais les fichiers applicatifs sont intacts :
> 
> 1. Extrayez uniquement le répertoire `/var/lib/mysql` depuis la sauvegarde
> 2. Arrêtez le service MySQL
> 3. Remplacez les fichiers corrompus
> 4. Redémarrez le service
> 
> Cette approche est plus rapide qu'une restauration complète.

---

## Restauration sur un autre nœud

La restauration sur un nœud différent est cruciale pour la migration, la répartition de charge ou la récupération après sinistre.

### Transfert de sauvegardes

**Méthodes de transfert :**

**1. Stockage partagé (recommandé) :**

Si vos nœuds partagent un stockage commun (NFS, Ceph, etc.), les sauvegardes sont naturellement accessibles.

```bash
# Configuration d'un stockage NFS partagé
pvesm add nfs shared-backup \
  --server 192.168.1.100 \
  --export /backup \
  --content backup

# La restauration est directe depuis n'importe quel nœud
qmrestore /mnt/pve/shared-backup/dump/backup.vma.zst 150
```

**2. Transfert via SCP/rsync :**

```bash
# Depuis le nœud source
scp /var/lib/vz/dump/backup.vma.zst root@node2:/var/lib/vz/dump/

# Ou avec rsync pour reprendre en cas d'interruption
rsync -avP --partial \
  /var/lib/vz/dump/backup.vma.zst \
  root@node2:/var/lib/vz/dump/

# Avec limitation de bande passante
rsync -avP --partial --bwlimit=50000 \
  /var/lib/vz/dump/backup.vma.zst \
  root@node2:/var/lib/vz/dump/
```

**3. Transfert direct avec restauration (efficace) :**

```bash
# Pipe direct depuis un nœud vers l'autre
ssh root@node1 "cat /var/lib/vz/dump/backup.vma.zst" | \
  qmrestore - 150 --storage local-lvm

# Avec compression à la volée
ssh root@node1 "cat /var/lib/vz/dump/backup.vma" | \
  zstd -c - | \
  ssh root@node2 "qmrestore - 150 --storage local-lvm"
```

### Migration inter-nœuds

**Restauration basique sur un nouveau nœud :**

```bash
# Sur le nœud de destination
qmrestore /var/lib/vz/dump/backup.vma.zst 150 \
  --storage local-lvm \
  --unique 1

# Vérifier la configuration réseau
qm config 150

# Adapter si nécessaire
qm set 150 --net0 virtio,bridge=vmbr0
```

**Restauration avec adaptation du stockage :**

```bash
# Si les noms de stockage diffèrent entre nœuds
# Nœud 1 : storage "ssd-pool"
# Nœud 2 : storage "nvme-pool"

qmrestore backup.vma.zst 150 \
  --storage nvme-pool  # Mapper vers le stockage équivalent
```

**Gestion des ressources spécifiques au nœud :**

```bash
# Restauration avec adaptation réseau
qmrestore backup.vma.zst 150 \
  --storage local-lvm \
  --unique 1

# Reconfigurer après restauration
qm set 150 \
  --net0 virtio,bridge=vmbr1 \
  --cores 8 \
  --numa 1  # Si le nouveau nœud a une architecture NUMA différente
```

### Considérations réseau et stockage

**Compatibilité réseau :**

|Aspect|Considération|Solution|
|---|---|---|
|Bridge réseau|Nom différent entre nœuds|Reconfigurer avec `qm set` ou `pct set`|
|VLAN|Configuration VLAN différente|Adapter les tags VLAN|
|Adresses MAC|Conflits possibles|Utiliser `--unique` lors de la restauration|
|Adresses IP|IP déjà utilisée sur le nouveau réseau|Reconfigurer avant démarrage|

**Compatibilité stockage :**

```bash
# Lister les stockages disponibles sur le nœud cible
pvesm status

# Vérifier la compatibilité des formats
# ZFS sur nœud1 → LVM sur nœud2 : OK
# Ceph sur nœud1 → Local sur nœud2 : OK
# Mais attention aux performances et fonctionnalités

# Restauration avec conversion de format
qmrestore backup.vma.zst 150 \
  --storage local-lvm \
  --format raw  # ou qcow2
```

**Script de migration automatisée :**

```bash
#!/bin/bash
# migration-restore.sh

SOURCE_NODE="node1"
TARGET_NODE="node2"
VMID_SOURCE=100
VMID_TARGET=150
BACKUP_PATH="/var/lib/vz/dump"

# 1. Créer une sauvegarde sur le nœud source
ssh root@$SOURCE_NODE "vzdump $VMID_SOURCE --compress zstd --mode snapshot"

# 2. Identifier la dernière sauvegarde
BACKUP_FILE=$(ssh root@$SOURCE_NODE "ls -t $BACKUP_PATH/vzdump-qemu-$VMID_SOURCE-*.vma.zst | head -1")

# 3. Transférer vers le nœud cible
rsync -avP --bwlimit=100000 \
  root@$SOURCE_NODE:$BACKUP_FILE \
  root@$TARGET_NODE:$BACKUP_PATH/

# 4. Restaurer sur le nœud cible
BACKUP_NAME=$(basename $BACKUP_FILE)
ssh root@$TARGET_NODE "qmrestore $BACKUP_PATH/$BACKUP_NAME $VMID_TARGET --storage local-lvm --unique 1"

# 5. Reconfigurer le réseau
ssh root@$TARGET_NODE "qm set $VMID_TARGET --net0 virtio,bridge=vmbr0"

echo "Migration terminée : VM $VMID_SOURCE → VM $VMID_TARGET sur $TARGET_NODE"
```

> [!warning] Attention à l'architecture CPU Lors de la restauration sur un nœud avec un processeur différent :
> 
> - Les VM peuvent ne pas démarrer si le CPU cible ne supporte pas les instructions du CPU source
> - Utilisez le type CPU "host" ou un type générique comme "qemu64"
> - Configurez `cpu: qemu64` si nécessaire

> [!tip] Astuce - Test de restauration Avant une migration importante :
> 
> 1. Testez la restauration avec `--dryrun` si disponible
> 2. Restaurez d'abord sur un VMID de test
> 3. Vérifiez le démarrage et la fonctionnalité
> 4. Seulement ensuite, procédez à la migration définitive

**Restauration dans un cluster :**

Si vos nœuds font partie d'un cluster Proxmox, la restauration est simplifiée :

```bash
# Les sauvegardes sur stockage partagé sont visibles depuis tous les nœuds
# Via l'interface web : sélectionnez simplement le nœud cible lors de la restauration

# En ligne de commande, spécifiez le nœud cible
pvesh create /nodes/node2/qemu/150/restore \
  -archive shared-backup:backup/vzdump-qemu-100-*.vma.zst \
  -storage local-lvm \
  -unique 1
```

---

## Bonnes pratiques

**Tester régulièrement les restaurations :**

```bash
# Créer un script de test de restauration mensuel
#!/bin/bash
# test-restore.sh

TEST_VMID=9999
BACKUP_DIR="/var/lib/vz/dump"

# Sélectionner une sauvegarde aléatoire
RANDOM_BACKUP=$(ls $BACKUP_DIR/*.vma.zst | shuf -n 1)

echo "Test de restauration : $RANDOM_BACKUP"

# Restaurer sur un VMID de test
qmrestore $RANDOM_BACKUP $TEST_VMID --storage local-lvm

# Démarrer et vérifier
qm start $TEST_VMID
sleep 60

# Vérifier que la VM répond
if qm status $TEST_VMID | grep -q "running"; then
    echo "✓ Test réussi"
else
    echo "✗ Test échoué"
fi

# Nettoyer
qm stop $TEST_VMID
qm destroy $TEST_VMID

# Enregistrer le résultat
echo "$(date): $RANDOM_BACKUP - OK" >> /var/log/restore-tests.log
```

**Documentation de la configuration :**

- Conservez une copie de la configuration de chaque VM/CT (`/etc/pve/qemu-server/*.conf` et `/etc/pve/lxc/*.conf`)
- Documentez les dépendances réseau et stockage
- Maintenez une liste des IP et noms d'hôtes

**Priorisation des restaurations :**

Définissez des RTO (Recovery Time Objective) par importance :

|Priorité|RTO|Type de VM|
|---|---|---|
|Critique|< 15 min|Serveurs de production essentiels|
|Haute|< 1 heure|Services importants|
|Moyenne|< 4 heures|Serveurs de développement|
|Basse|< 24 heures|Services non essentiels|

**Automatisation :**

```bash
# Script de restauration d'urgence
# emergency-restore.sh

#!/bin/bash

VMID=$1
BACKUP_LOCATION=$2

if [ -z "$VMID" ] || [ -z "$BACKUP_LOCATION" ]; then
    echo "Usage: $0 <VMID> <backup_file>"
    exit 1
fi

echo "🚨 RESTAURATION D'URGENCE 🚨"
echo "VMID: $VMID"
echo "Sauvegarde: $BACKUP_LOCATION"
echo ""
echo "Appuyez sur ENTER pour continuer ou CTRL+C pour annuler"
read

# Sauvegarder l'état actuel si la VM existe
if qm status $VMID &>/dev/null; then
    echo "VM existante détectée. Création d'une sauvegarde de sécurité..."
    vzdump $VMID --compress zstd --mode snapshot
fi

# Restaurer
echo "Restauration en cours..."
qmrestore $BACKUP_LOCATION $VMID --storage local-lvm --force

# Démarrer
echo "Démarrage de la VM..."
qm start $VMID

# Vérification
sleep 30
if qm status $VMID | grep -q "running"; then
    echo "✓ Restauration réussie. VM opérationnelle."
else
    echo "✗ Problème détecté. Vérifiez manuellement."
fi
```

---

## Pièges courants

**1. Espace disque insuffisant :**

```bash
# Toujours vérifier l'espace avant restauration
df -h /var/lib/vz

# Calculer l'espace nécessaire (taille décompressée ≈ 2-3x la taille compressée)
zstdcat backup.vma.zst | wc -c
```

**2. Conflits d'identifiants :**

```bash
# Éviter les conflits de VMID
qm list  # Lister les VMID existants avant restauration

# Éviter les conflits MAC/IP
qmrestore backup.vma.zst 150 --unique 1  # Toujours utiliser --unique
```

**3. Incompatibilités de version :**

> [!warning] Versions Proxmox différentes Restaurer une sauvegarde créée sur Proxmox 8.x vers Proxmox 7.x peut poser problème. Privilégiez toujours une restauration sur une version égale ou supérieure.

**4. Oubli de reconfiguration post-restauration :**

Checklist après restauration :

- [ ] Vérifier la configuration réseau (`qm config` / `pct config`)
- [ ] Vérifier les IP et noms d'hôtes
- [ ] Tester la connectivité réseau
- [ ] Vérifier les montages de stockage
- [ ] Contrôler les services critiques
- [ ] Valider les sauvegardes automatiques

**5. Restauration sur un stockage lent :**

```bash
# Si possible, restaurer sur un stockage rapide puis migrer
qmrestore backup.vma.zst 150 --storage ssd-pool

# Puis migrer vers stockage final
qm move-disk 150 scsi0 hdd-pool --delete
```

**6. Corruption de sauvegarde non détectée :**

```bash
# Toujours vérifier l'intégrité avant restauration
zstd -t backup.vma.zst

# Pour les archives tar
tar -tzf backup.tar.zst > /dev/null

# Comparer avec les checksums si disponibles
sha256sum backup.vma.zst
cat backup.vma.zst.sha256
```

> [!tip] Astuce - Restauration progressive Pour les très grandes VM :
> 
> 1. Restaurez d'abord sur un stockage rapide avec `--bwlimit` élevé
> 2. Vérifiez l'intégrité et le démarrage
> 3. Migrez ensuite vers le stockage final si nécessaire
> 
> Cette approche réduit le temps d'indisponibilité.

---

**🎯 Points clés à retenir :**

- La restauration complète recrée une VM/CT identique ou sur un nouvel ID
- L'extraction de fichiers permet une récupération granulaire sans restauration complète
- L'option `--unique` évite les conflits réseau lors de restaurations sur le même réseau
- Les restaurations inter-nœuds nécessitent une attention particulière au réseau et au stockage
- Testez régulièrement vos restaurations pour valider votre stratégie de sauvegarde
- Documentez vos procédures de restauration et maintenez-les à jour