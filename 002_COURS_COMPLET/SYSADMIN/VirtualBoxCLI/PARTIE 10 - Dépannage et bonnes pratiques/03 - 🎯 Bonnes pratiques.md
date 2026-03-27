

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

## 🗂️ Organisation des VMs

### Pourquoi organiser ses VMs ?

Une bonne organisation permet de maintenir un environnement propre, facilite la gestion à long terme et réduit les risques d'erreurs lors des opérations en ligne de commande.

### Structure de répertoires recommandée

```bash
# Structure type
~/VirtualBox/
├── Production/
│   ├── web-server-01/
│   ├── database-01/
│   └── proxy-01/
├── Development/
│   ├── dev-ubuntu/
│   ├── dev-windows/
│   └── test-environment/
├── Templates/
│   ├── ubuntu-base/
│   └── debian-base/
├── ISOs/
│   ├── ubuntu-22.04.iso
│   └── debian-12.iso
└── Snapshots/
    └── backups/
```

> [!tip] Astuce Définissez un répertoire par défaut pour toutes vos VMs avec :
> 
> ```bash
> VBoxManage setproperty machinefolder "/chemin/vers/VirtualBox"
> ```

### Groupes de VMs

Les groupes permettent de catégoriser vos machines virtuelles pour une meilleure lisibilité.

```bash
# Créer un groupe lors de la création d'une VM
VBoxManage createvm --name "web-server" --groups "/Production/Web" --register

# Ajouter une VM existante à un groupe
VBoxManage modifyvm "ma-vm" --groups "/Development,/Testing"

# Lister les VMs par groupe
VBoxManage list vms | grep "/Production"

# Démarrer toutes les VMs d'un groupe (via script)
for vm in $(VBoxManage list vms | grep "/Production" | cut -d'"' -f2); do
    VBoxManage startvm "$vm" --type headless
done
```

> [!info] Hiérarchie des groupes Les groupes peuvent être hiérarchiques en utilisant le séparateur `/` : `/Production/Web/Frontend`

### Environnements séparés

|Environnement|Usage|Caractéristiques|
|---|---|---|
|**Production**|Déploiement final|Stabilité, performances, backups réguliers|
|**Development**|Développement actif|Snapshots fréquents, ressources limitées|
|**Testing**|Tests et validation|Environnement jetable, facile à recréer|
|**Templates**|Machines de base|Configurations minimales, sources pour clonage|

> [!warning] Attention Ne mélangez jamais les VMs de production avec les environnements de test pour éviter les confusions et les erreurs de manipulation.

---

## 🏷️ Naming conventions

### Importance d'une convention de nommage

Des noms cohérents facilitent l'identification rapide des VMs, l'automatisation via scripts et réduisent les erreurs humaines.

### Convention recommandée

```
[environnement]-[type]-[fonction]-[numéro]
```

**Exemples :**

```bash
prod-web-frontend-01
prod-db-postgresql-01
dev-app-nodejs-01
test-web-nginx-02
tpl-ubuntu-2204-base
```

### Composants de la convention

|Composant|Description|Exemples|
|---|---|---|
|**Environnement**|Type d'environnement|`prod`, `dev`, `test`, `staging`, `tpl`|
|**Type**|Catégorie technique|`web`, `db`, `app`, `proxy`, `cache`|
|**Fonction**|Rôle spécifique|`nginx`, `mysql`, `redis`, `nodejs`|
|**Numéro**|Index ou version|`01`, `02`, `v2`|

```bash
# Exemples de création avec convention
VBoxManage createvm --name "prod-web-nginx-01" --ostype "Ubuntu_64" --register
VBoxManage createvm --name "dev-db-postgres-01" --ostype "Debian_64" --register
VBoxManage createvm --name "test-app-python-01" --ostype "Linux_64" --register
```

### Conventions pour différents objets

**Snapshots :**

```bash
# Convention : YYYYMMDD-HHMM-description
VBoxManage snapshot "prod-web-01" take "20241226-1430-pre-update"
VBoxManage snapshot "dev-app-01" take "20241226-working-state"
```

**Disques virtuels :**

```bash
# Convention : nom-vm-type-taille.format
prod-web-nginx-01-system-50GB.vdi
prod-db-mysql-01-data-200GB.vdi
dev-app-nodejs-01-system-30GB.vdi
```

**Snapshots internes :**

```bash
# Convention descriptive avec contexte
pre-migration-v2
after-security-patches
before-major-upgrade
feature-branch-testing
```

> [!tip] Astuce pour les scripts Utilisez des noms prévisibles pour faciliter l'automatisation :
> 
> ```bash
> # Script qui démarre toutes les VMs de production
> for vm in $(VBoxManage list vms | grep "prod-" | cut -d'"' -f2); do
>     VBoxManage startvm "$vm" --type headless
> done
> ```

> [!warning] Caractères à éviter Évitez les espaces, caractères spéciaux et accents dans les noms. Privilégiez : lettres minuscules, chiffres, tirets `-` et underscores `_`.

---

## 📝 Documentation

### Pourquoi documenter ?

La documentation est essentielle pour la maintenance à long terme, le transfert de connaissances et le dépannage rapide.

### Documentation au niveau de la VM

Utilisez les champs de description et les propriétés personnalisées :

```bash
# Ajouter une description
VBoxManage modifyvm "prod-web-01" --description "Serveur web Nginx
Production - Frontend principal
Version: Ubuntu 22.04 LTS
Contact: equipe-ops@example.com
Créé: 2024-12-26"

# Consulter la description
VBoxManage showvminfo "prod-web-01" | grep Description

# Ajouter des propriétés personnalisées
VBoxManage setextradata "prod-web-01" "Project" "Site-E-commerce"
VBoxManage setextradata "prod-web-01" "Owner" "Jean Dupont"
VBoxManage setextradata "prod-web-01" "LastMaintenance" "2024-12-20"
VBoxManage setextradata "prod-web-01" "BackupSchedule" "Daily-3AM"

# Lire les propriétés
VBoxManage getextradata "prod-web-01" "Project"
VBoxManage getextradata "prod-web-01" enumerate
```

### Fichier de documentation externe

Créez un fichier README pour chaque VM importante :

```bash
# Exemple de structure README.md
~/VirtualBox/Production/web-server-01/README.md
```

**Contenu type :**

```markdown
# prod-web-nginx-01

## Informations générales
- **Environnement** : Production
- **OS** : Ubuntu 22.04 LTS
- **Rôle** : Serveur web frontend
- **IP** : 192.168.1.10
- **Créé le** : 2024-12-26
- **Responsable** : Équipe DevOps

## Configuration
- RAM : 4096 MB
- CPU : 2 cores
- Disque : 50 GB (système) + 100 GB (données)
- Réseau : Bridged (enp0s3)

## Snapshots importants
- `pre-migration-v2` : Avant migration version 2.0
- `working-baseline` : Configuration stable validée

## Accès et credentials
- User SSH : `admin`
- Port SSH : 22
- Clé SSH : `/path/to/key.pem`

## Dépendances
- Base de données : prod-db-postgres-01
- Cache : prod-cache-redis-01

## Notes de maintenance
- Backup automatique : Tous les jours à 3h00
- Dernière mise à jour : 2024-12-20
- Prochaine maintenance : 2025-01-15
```

### Inventaire global

Maintenez un fichier d'inventaire central :

```bash
# Script pour générer un inventaire
#!/bin/bash
echo "# Inventaire VirtualBox - $(date)" > inventory.md
echo "" >> inventory.md

VBoxManage list vms | while read line; do
    vm_name=$(echo $line | cut -d'"' -f2)
    echo "## $vm_name" >> inventory.md
    
    # Récupérer les infos principales
    VBoxManage showvminfo "$vm_name" --machinereadable | \
        grep -E "name|memory|cpus|ostype" >> inventory.md
    
    echo "" >> inventory.md
done
```

### Documentation des snapshots

Toujours documenter les snapshots avec des descriptions claires :

```bash
# Bon : description explicite
VBoxManage snapshot "prod-web-01" take "before-nginx-upgrade-1.24" \
    --description "État avant upgrade Nginx 1.22 -> 1.24
Date: 2024-12-26
Raison: Upgrade majeur Nginx
État: Testé et validé en dev
Rollback prévu si: erreurs 5xx > 1%"

# Mauvais : description vague
VBoxManage snapshot "prod-web-01" take "backup1"
```

> [!tip] Script de documentation automatique Créez un script qui documente automatiquement lors des opérations critiques :
> 
> ```bash
> #!/bin/bash
> vm_name=$1
> operation=$2
> 
> # Créer snapshot avec documentation
> timestamp=$(date +%Y%m%d-%H%M)
> desc="Automated snapshot before $operation
> Created: $(date)
> User: $(whoami)
> Hostname: $(hostname)"
> 
> VBoxManage snapshot "$vm_name" take "${timestamp}-${operation}" \
>     --description "$desc"
> ```

---

## 💾 Stratégies de backup

### Types de backups

|Type|Méthode|Avantages|Inconvénients|
|---|---|---|---|
|**Export OVA**|Format standardisé|Portable, compatible|Lent, volumineux|
|**Clone complet**|Copie de VM|Rapide à restaurer|Espace disque important|
|**Snapshots**|État instantané|Rapide, peu d'espace|Ne protège pas contre panne disque|
|**Disque seul**|Copie VDI/VMDK|Granulaire|Nécessite reconfiguration|

### Backup complet : Export OVA/OVF

L'export crée une archive portable de la VM complète.

```bash
# Export complet en OVA (archive unique)
VBoxManage export "prod-web-01" \
    --output "/backup/prod-web-01-$(date +%Y%m%d).ova" \
    --options manifest,iso \
    --vsys 0 \
    --product "Production Web Server" \
    --vendor "Mon Entreprise" \
    --version "1.0"

# Export en OVF (plusieurs fichiers)
VBoxManage export "prod-web-01" \
    --output "/backup/prod-web-01-$(date +%Y%m%d).ovf"

# Options d'export
# --options manifest : Ajoute un fichier de vérification
# --options iso : Inclut les ISO attachés
# --options nomacs : Supprime les adresses MAC
```

> [!info] Format OVA vs OVF
> 
> - **OVA** : Archive unique, facile à transférer
> - **OVF** : Plusieurs fichiers (descripteur + disques), plus flexible pour modifications

### Backup par clonage

Le clonage crée une copie complète et indépendante de la VM.

```bash
# Clone complet (tous les disques)
VBoxManage clonevm "prod-web-01" \
    --name "backup-prod-web-01-$(date +%Y%m%d)" \
    --mode all \
    --register

# Clone avec snapshot (linked clone - gain d'espace)
VBoxManage clonevm "prod-web-01" \
    --snapshot "working-baseline" \
    --mode machine \
    --name "backup-prod-web-01-linked" \
    --options link \
    --register

# Clone sans enregistrement (pour stockage externe)
VBoxManage clonevm "prod-web-01" \
    --mode all \
    --name "backup-prod-web-01" \
    --basefolder "/media/backup-externe"
```

### Backup des disques virtuels

Sauvegarde granulaire des disques uniquement.

```bash
# Identifier les disques attachés
VBoxManage showvminfo "prod-web-01" | grep "vdi\|vmdk\|vhd"

# Cloner un disque spécifique
VBoxManage clonemedium disk \
    "/path/to/prod-web-01.vdi" \
    "/backup/prod-web-01-$(date +%Y%m%d).vdi" \
    --format VDI

# Cloner avec compression (gain d'espace)
VBoxManage clonemedium disk \
    "/path/to/prod-web-01.vdi" \
    "/backup/prod-web-01-compressed.vdi" \
    --format VDI \
    --variant Standard,Compressed
```

### Stratégie de backup 3-2-1

Implémentez la règle 3-2-1 pour une protection optimale :

- **3** copies de vos données
- **2** supports différents
- **1** copie hors site

```bash
#!/bin/bash
# Script de backup automatisé 3-2-1

VM_NAME="prod-web-01"
DATE=$(date +%Y%m%d)
LOCAL_BACKUP="/backup/local"
NAS_BACKUP="/mnt/nas/backup"
CLOUD_BACKUP="/mnt/cloud/backup"

# 1. Snapshot local (rapide)
VBoxManage snapshot "$VM_NAME" take "auto-backup-$DATE"

# 2. Export sur disque local
VBoxManage export "$VM_NAME" \
    --output "$LOCAL_BACKUP/${VM_NAME}-${DATE}.ova"

# 3. Copie sur NAS (support différent)
cp "$LOCAL_BACKUP/${VM_NAME}-${DATE}.ova" "$NAS_BACKUP/"

# 4. Copie cloud (hors site)
rclone copy "$LOCAL_BACKUP/${VM_NAME}-${DATE}.ova" "$CLOUD_BACKUP/"

# Nettoyage (garder 7 jours local, 30 jours NAS, 90 jours cloud)
find "$LOCAL_BACKUP" -name "${VM_NAME}-*.ova" -mtime +7 -delete
find "$NAS_BACKUP" -name "${VM_NAME}-*.ova" -mtime +30 -delete
```

### Planification des backups

**Fréquence recommandée :**

|Environnement|Snapshots|Export complet|Notes|
|---|---|---|---|
|**Production**|Avant chaque changement|Quotidien|Backups hors site hebdomadaires|
|**Development**|Quotidien|Hebdomadaire|Peut être moins strict|
|**Testing**|Optionnel|Optionnel|États reproductibles|
|**Templates**|Après chaque modification|Mensuel|Versions stables uniquement|

### Script de backup automatisé

```bash
#!/bin/bash
# backup-vm.sh - Script de backup complet

set -e  # Arrêt si erreur

VM_NAME=$1
BACKUP_DIR="/backup/virtualbox"
RETENTION_DAYS=30
LOG_FILE="/var/log/vbox-backup.log"

# Fonction de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Vérifications
if [ -z "$VM_NAME" ]; then
    log "ERROR: Nom de VM requis"
    exit 1
fi

# Vérifier que la VM existe
if ! VBoxManage showvminfo "$VM_NAME" &> /dev/null; then
    log "ERROR: VM '$VM_NAME' introuvable"
    exit 1
fi

# Créer le dossier de backup
BACKUP_PATH="$BACKUP_DIR/$(date +%Y/%m)"
mkdir -p "$BACKUP_PATH"

# Nom du backup
BACKUP_NAME="${VM_NAME}-$(date +%Y%m%d-%H%M)"

log "Début du backup de $VM_NAME"

# 1. Créer un snapshot
log "Création du snapshot..."
VBoxManage snapshot "$VM_NAME" take "backup-$BACKUP_NAME" \
    --description "Automated backup - $(date)" || {
    log "ERROR: Échec du snapshot"
    exit 1
}

# 2. Export OVA
log "Export en cours..."
VBoxManage export "$VM_NAME" \
    --output "$BACKUP_PATH/${BACKUP_NAME}.ova" \
    --options manifest || {
    log "ERROR: Échec de l'export"
    exit 1
}

# 3. Vérifier l'intégrité
log "Vérification de l'intégrité..."
if [ -f "$BACKUP_PATH/${BACKUP_NAME}.ova" ]; then
    SIZE=$(du -h "$BACKUP_PATH/${BACKUP_NAME}.ova" | cut -f1)
    log "Backup créé avec succès : $SIZE"
else
    log "ERROR: Fichier de backup introuvable"
    exit 1
fi

# 4. Nettoyage des anciens backups
log "Nettoyage des anciens backups..."
find "$BACKUP_DIR" -name "${VM_NAME}-*.ova" -mtime +$RETENTION_DAYS -delete
DELETED=$(find "$BACKUP_DIR" -name "${VM_NAME}-*.ova" -mtime +$RETENTION_DAYS | wc -l)
log "Supprimés : $DELETED anciens backups"

# 5. Nettoyage des anciens snapshots
log "Nettoyage des snapshots automatiques..."
VBoxManage snapshot "$VM_NAME" list | grep "backup-${VM_NAME}" | \
    head -n -5 | while read line; do
        SNAP_NAME=$(echo "$line" | sed 's/.*Name: \(.*\) (UUID.*/\1/')
        VBoxManage snapshot "$VM_NAME" delete "$SNAP_NAME" 2>/dev/null || true
done

log "Backup terminé avec succès"
```

**Configuration cron :**

```bash
# Éditer la crontab
crontab -e

# Backup quotidien à 2h du matin
0 2 * * * /usr/local/bin/backup-vm.sh prod-web-01

# Backup hebdomadaire le dimanche à 3h
0 3 * * 0 /usr/local/bin/backup-vm.sh prod-db-01
```

> [!warning] Attention aux VMs actives Pour un backup cohérent d'une VM en cours d'exécution, préférez :
> 
> 1. Utiliser les snapshots à chaud
> 2. Ou arrêter proprement la VM avant l'export
> 3. Ou utiliser les outils de backup du système d'exploitation invité

### Restauration depuis backup

```bash
# Restaurer depuis OVA/OVF
VBoxManage import "/backup/prod-web-01-20241226.ova" \
    --vsys 0 \
    --vmname "prod-web-01-restored"

# Restaurer depuis un clone
VBoxManage clonevm "backup-prod-web-01-20241226" \
    --name "prod-web-01" \
    --mode all \
    --register

# Restaurer depuis un snapshot
VBoxManage snapshot "prod-web-01" restore "backup-20241226"

# Restaurer un disque spécifique
VBoxManage storageattach "prod-web-01" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/backup/prod-web-01-20241226.vdi"
```

> [!tip] Test de restauration Testez régulièrement vos procédures de restauration pour vérifier que vos backups sont valides et restaurables.

---

## ⚡ Optimisation des performances

### Allocation des ressources

L'allocation optimale des ressources évite la sous-utilisation et la surcharge.

#### CPU (Processeurs virtuels)

```bash
# Définir le nombre de CPUs
VBoxManage modifyvm "ma-vm" --cpus 2

# Définir le CPU execution cap (limite de performance)
# 100% = 1 CPU complet, 200% = 2 CPUs complets
VBoxManage modifyvm "ma-vm" --cpuexecutioncap 75

# Activer PAE/NX (pour OS 32-bit avec >4GB RAM)
VBoxManage modifyvm "ma-vm" --pae on

# Activer les instructions CPU avancées
VBoxManage modifyvm "ma-vm" --hwvirtex on
VBoxManage modifyvm "ma-vm" --nestedpaging on
VBoxManage modifyvm "ma-vm" --vtxvpid on
```

> [!tip] Règle d'allocation CPU
> 
> - **VM légère** : 1-2 vCPUs
> - **VM standard** : 2-4 vCPUs
> - **VM intensive** : 4-8 vCPUs
> - Ne dépassez jamais le nombre de cœurs physiques réels de votre machine hôte

#### Mémoire RAM

```bash
# Définir la RAM (en MB)
VBoxManage modifyvm "ma-vm" --memory 4096

# Pour des charges spécifiques
VBoxManage modifyvm "vm-legere" --memory 1024      # 1 GB
VBoxManage modifyvm "vm-standard" --memory 4096    # 4 GB
VBoxManage modifyvm "vm-serveur" --memory 8192     # 8 GB
VBoxManage modifyvm "vm-database" --memory 16384   # 16 GB
```

**Recommandations RAM :**

|Type de VM|RAM minimum|RAM recommandée|Notes|
|---|---|---|---|
|Linux CLI|512 MB|1 GB|Sans interface graphique|
|Linux Desktop|2 GB|4 GB|Avec environnement graphique|
|Windows 10/11|4 GB|8 GB|Pour usage normal|
|Serveur Web|2 GB|4-8 GB|Selon le trafic|
|Base de données|4 GB|8-16 GB|Selon la taille des données|

> [!warning] Sur-allocation mémoire N'allouez jamais plus de 75% de la RAM physique de votre hôte pour éviter le swap excessif et les problèmes de performances.

### Optimisation du stockage

#### Choix du contrôleur et du type de disque

```bash
# Contrôleurs disponibles (par ordre de performance)
# 1. NVMe (le plus rapide, pour SSD)
VBoxManage storagectl "ma-vm" --name "NVMe" --add nvme

# 2. SATA (bon compromis, compatible)
VBoxManage storagectl "ma-vm" --name "SATA" --add sata

# 3. IDE (ancien, lent)
VBoxManage storagectl "ma-vm" --name "IDE" --add ide

# Attacher un disque avec le meilleur contrôleur
VBoxManage storageattach "ma-vm" \
    --storagectl "NVMe" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/path/to/disk.vdi"

# Activer le cache hôte (améliore les performances)
VBoxManage storagectl "ma-vm" --name "SATA" --hostiocache on

# Désactiver le cache I/O (pour bases de données)
VBoxManage storageattach "ma-vm" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/path/to/disk.vdi" \
    --nonrotational on \
    --discard on
```

> [!info] SSD vs HDD Pour un disque hôte SSD, utilisez :
> 
> ```bash
> VBoxManage storageattach "ma-vm" \
>     --storagectl "SATA" \
>     --port 0 \
>     --device 0 \
>     --type hdd \
>     --medium "/path/to/disk.vdi" \
>     --nonrotational on
> ```

#### Optimisation des disques virtuels

```bash
# Créer un disque avec taille fixe (meilleures performances)
VBoxManage createmedium disk \
    --filename "/path/to/disk-fixed.vdi" \
    --size 51200 \
    --format VDI \
    --variant Fixed

# Créer un disque dynamique (économie d'espace)
VBoxManage createmedium disk \
    --filename "/path/to/disk-dynamic.vdi" \
    --size 51200 \
    --format VDI \
    --variant Standard

# Compacter un disque dynamique
# 1. D'abord, zéro-er l'espace libre dans la VM invitée
#    Linux: sudo dd if=/dev/zero of=/zero.file bs=1M; sudo rm /zero.file
#    Windows: sdelete -z C:

# 2. Puis compacter depuis l'hôte
VBoxManage modifymedium disk "/path/to/disk.vdi" --compact
```

**Comparaison Fixed vs Dynamic :**

|Type|Performances|Espace disque|Usage recommandé|
|---|---|---|---|
|**Fixed**|Excellentes|Occupe toute la taille|Production, bases de données|
|**Dynamic**|Bonnes|N'occupe que l'utilisé|Développement, tests|

### Accélération graphique

```bash
# Activer l'accélération 3D (pour VMs desktop)
VBoxManage modifyvm "ma-vm" --accelerate3d on

# Définir la mémoire vidéo (en MB)
VBoxManage modifyvm "ma-vm" --vram 128

# Activer l'accélération 2D (Windows uniquement)
VBoxManage modifyvm "ma-vm" --accelerate2dvideo on

# Pour serveurs (sans GUI)
VBoxManage modifyvm "serveur-vm" --graphicscontroller vmsvga
VBoxManage modifyvm "serveur-vm" --vram 16  # Minimum requis
```

> [!tip] Allocation VRAM
> 
> - **Serveur sans GUI** : 16 MB minimum
> - **Desktop léger** : 64-128 MB
> - **Desktop standard** : 128-256 MB
> - **Gaming/3D** : 256 MB (maximum)

### Optimisation réseau

```bash
# Choisir le bon type d'adaptateur
# virtio-net = le plus rapide (nécessite drivers)
VBoxManage modifyvm "ma-vm" --nictype1 virtio

# Autres types par ordre de performance
# - virtio: Le plus rapide (Linux moderne, Windows avec drivers)
# - 82540EM: Intel PRO/1000 MT Desktop (bon compromis)
# - 82545EM: Intel PRO/1000 MT Server (ancien)
# - Am79C973: AMD PCNet FAST III (très ancien)

# Activer le mode promiscuous pour certains usages
VBoxManage modifyvm "ma-vm" --nicpromisc1 allow-all

# Optimiser les performances avec plusieurs CPUs
VBoxManage modifyvm "ma-vm" --nictype1 virtio --cpus 2
```

### Paramètres système avancés

```bash
# Activer ACPI (recommandé)
VBoxManage modifyvm "ma-vm" --acpi on

# Activer IO APIC (nécessaire pour >1 CPU)
VBoxManage modifyvm "ma-vm" --ioapic on

# Activer UTC pour l'horloge (Linux)
VBoxManage modifyvm "ma-vm" --rtcuseutc on

# Désactiver l'USB si non nécessaire (gain de performances)
VBoxManage modifyvm "ma-vm" --usb off

# Désactiver l'audio si non nécessaire
VBoxManage modifyvm "ma-vm" --audio none
```

### Profils de performance par type de VM

**Serveur Web haute performance :**

```bash
VM_NAME="prod-web-01"

VBoxManage modifyvm "$VM_NAME" \
    --cpus 4 \
    --memory 8192 \
    --vram 16 \
    --graphicscontroller vmsvga \
    --acpi on \
    --ioapic on \
    --hwvirtex on \
    --nestedpaging on \
    --nictype1 virtio \
    --audio none \
    --usb off

VBoxManage storagectl "$VM_NAME" --name "NVMe" --add nvme --hostiocache on
```

**Machine de développement :**

```bash
VM_NAME="dev-ubuntu-01"

VBoxManage modifyvm "$VM_NAME" \
    --cpus 2 \
    --memory 4096 \
    --vram 128 \
    --accelerate3d on \
    --graphicscontroller vmsvga \
    --nictype1 virtio
```

**Base de données :**

```bash
VM_NAME="prod-db-01"

VBoxManage modifyvm "$VM_NAME" \
    --cpus 4 \
    --memory 16384 \
    --vram 16 \
    --graphicscontroller vmsvga \
    --acpi on \
    --ioapic on \
    --hwvirtex on \
    --nestedpaging on \
    --nictype1 virtio \
    --audio none \
    --usb off

# Disque avec cache désactivé pour intégrité des données
VBoxManage storageattach "$VM_NAME" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/path/to/db-disk.vdi" \
    --nonrotational on \
    --discard on
```

> [!tip] Monitoring des performances Surveillez les performances de vos VMs avec :
> 
> ```bash
> # Statistiques en temps réel
> VBoxManage metrics query "ma-vm"
> 
> # Statistiques détaillées CPU et RAM
> VBoxManage metrics collect --period 5 --samples 10 "ma-vm" CPU/Load/User,RAM/Usage/Used
> ```

---

## 💽 Gestion de l'espace disque

### Surveiller l'utilisation de l'espace

#### Lister les disques et leur taille

```bash
# Lister tous les disques enregistrés
VBoxManage list hdds

# Informations détaillées sur un disque spécifique
VBoxManage showmediuminfo disk "/path/to/disk.vdi"

# Afficher uniquement la taille
VBoxManage showmediuminfo disk "/path/to/disk.vdi" | grep "Capacity"

# Script pour lister tous les disques avec leurs tailles
#!/bin/bash
echo "=== Disques VirtualBox ==="
VBoxManage list hdds | grep -E "Location:|Capacity:" | \
while read -r line; do
    if [[ $line == Location:* ]]; then
        echo ""
        echo "$line"
    else
        echo "$line"
    fi
done
```

#### Identifier les gros consommateurs

```bash
# Trouver les plus gros disques
VBoxManage list hdds | grep -E "Location:|Capacity:" | \
paste - - | sort -k4 -h -r | head -10

# Taille totale utilisée par VirtualBox
du -sh ~/VirtualBox/

# Taille par VM
du -sh ~/VirtualBox/*/ | sort -h -r

# Détails par VM avec breakdown
for vm_dir in ~/VirtualBox/*/; do
    vm_name=$(basename "$vm_dir")
    total=$(du -sh "$vm_dir" | cut -f1)
    echo "VM: $vm_name - Taille totale: $total"
    du -sh "$vm_dir"/*.vdi "$vm_dir"/*.vmdk 2>/dev/null
    echo "---"
done
```

### Compactage des disques

Le compactage récupère l'espace libre des disques dynamiques.

#### Préparation dans la VM invitée

**Linux :**

```bash
# Remplir l'espace libre avec des zéros
sudo dd if=/dev/zero of=/zero.file bs=1M
sudo rm /zero.file

# Alternative avec zerofree (plus efficace)
# D'abord, démarrer en mode rescue ou single user
sudo zerofree -v /dev/sda1
```

**Windows :**

```cmd
# Télécharger SDelete de Microsoft Sysinternals
# https://docs.microsoft.com/sysinternals/downloads/sdelete

# Zéro-er l'espace libre sur C:
sdelete -z C:

# Pour tous les lecteurs
sdelete -z *:
```

#### Compactage depuis l'hôte

```bash
# Arrêter la VM d'abord
VBoxManage controlvm "ma-vm" poweroff

# Compacter le disque
VBoxManage modifymedium disk "/path/to/disk.vdi" --compact

# Vérifier le gain d'espace
ls -lh "/path/to/disk.vdi"
```

> [!warning] Important Le compactage ne fonctionne que sur les disques **dynamiques** (non Fixed). Pour un disque Fixed, vous devez le cloner en format dynamique d'abord.

#### Script de compactage automatisé

```bash
#!/bin/bash
# compact-all-vms.sh - Compacte tous les disques dynamiques

VBOX_DIR="$HOME/VirtualBox"

echo "=== Compactage des disques VirtualBox ==="
echo "Début: $(date)"
echo ""

# Parcourir tous les disques
VBoxManage list hdds | grep "Location:" | cut -d: -f2- | while read disk_path; do
    disk_path=$(echo "$disk_path" | xargs)  # Trim whitespace
    
    # Vérifier si le disque est dynamique
    variant=$(VBoxManage showmediuminfo disk "$disk_path" | grep "Variant:" | cut -d: -f2)
    
    if [[ "$variant" == *"dynamic"* ]]; then
        echo "Traitement: $disk_path"
        
        # Taille avant
        size_before=$(du -h "$disk_path" | cut -f1)
        echo "  Taille avant: $size_before"
        
        # Compactage
        if VBoxManage modifymedium disk "$disk_path" --compact; then
            # Taille après
            size_after=$(du -h "$disk_path" | cut -f1)
            echo "  Taille après: $size_after"
            echo "  ✓ Compactage réussi"
        else
            echo "  ✗ Échec du compactage"
        fi
        echo ""
    fi
done

echo "Fin: $(date)"
```

### Redimensionnement des disques

#### Agrandir un disque

```bash
# Agrandir un disque (taille en MB)
VBoxManage modifymedium disk "/path/to/disk.vdi" --resize 102400  # 100 GB

# Vérifier la nouvelle taille
VBoxManage showmediuminfo disk "/path/to/disk.vdi" | grep "Capacity"
```

> [!info] Après agrandissement L'espace supplémentaire est non alloué. Vous devez :
> 
> 1. Démarrer la VM
> 2. Utiliser un outil de partition (GParted, fdisk, Disk Management) pour étendre la partition
> 3. Étendre le système de fichiers si nécessaire

#### Réduire un disque

VirtualBox ne supporte pas la réduction directe. Il faut :

```bash
# 1. Créer un nouveau disque plus petit
VBoxManage createmedium disk \
    --filename "/path/to/new-disk.vdi" \
    --size 51200 \
    --format VDI

# 2. Démarrer la VM avec un Live CD (GParted)
# 3. Réduire la partition dans le disque original
# 4. Cloner vers le nouveau disque
VBoxManage clonemedium disk \
    "/path/to/old-disk.vdi" \
    "/path/to/new-disk.vdi"

# 5. Attacher le nouveau disque à la VM
VBoxManage storageattach "ma-vm" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/path/to/new-disk.vdi"

# 6. Supprimer l'ancien disque
VBoxManage closemedium disk "/path/to/old-disk.vdi" --delete
```

### Nettoyage et maintenance

#### Supprimer les snapshots inutiles

```bash
# Lister tous les snapshots d'une VM
VBoxManage snapshot "ma-vm" list --details

# Supprimer un snapshot spécifique
VBoxManage snapshot "ma-vm" delete "snapshot-name"

# Supprimer tous les snapshots (fusion avec disque de base)
VBoxManage snapshot "ma-vm" delete --all

# Script pour supprimer les snapshots de plus de 30 jours
#!/bin/bash
VM_NAME=$1
DAYS_OLD=30

VBoxManage snapshot "$VM_NAME" list --machinereadable | \
grep "SnapshotName" | cut -d'"' -f2 | while read snap; do
    # Récupérer la date du snapshot
    snap_date=$(VBoxManage snapshot "$VM_NAME" showvminfo "$snap" | \
                grep "Time stamp:" | cut -d: -f2- | xargs)
    
    # Logique de suppression basée sur la date
    # (nécessite parsing de date supplémentaire)
    echo "Snapshot: $snap - Date: $snap_date"
done
```

> [!warning] Attention aux snapshots Les snapshots occupent de l'espace disque et ralentissent les performances. Ne gardez que les snapshots nécessaires.

#### Supprimer les disques orphelins

```bash
# Lister les disques non attachés à une VM
VBoxManage list hdds | grep -B2 "In use by VMs:  none"

# Fermer et supprimer un disque orphelin
VBoxManage closemedium disk "/path/to/orphan-disk.vdi" --delete

# Script pour nettoyer tous les disques orphelins
#!/bin/bash
echo "=== Recherche de disques orphelins ==="

VBoxManage list hdds | grep "Location:" | cut -d: -f2- | while read disk; do
    disk=$(echo "$disk" | xargs)
    in_use=$(VBoxManage showmediuminfo disk "$disk" | grep "In use by VMs:")
    
    if [[ "$in_use" == *"none"* ]]; then
        echo "Disque orphelin trouvé: $disk"
        read -p "Supprimer? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            VBoxManage closemedium disk "$disk" --delete
            echo "✓ Supprimé"
        fi
    fi
done
```

#### Supprimer les logs anciens

```bash
# Les logs VirtualBox peuvent occuper de l'espace
# Ils sont situés dans le dossier de chaque VM

# Trouver tous les fichiers de log
find ~/VirtualBox -name "VBox.log*" -type f

# Supprimer les logs de plus de 30 jours
find ~/VirtualBox -name "VBox.log*" -type f -mtime +30 -delete

# Garder uniquement les 3 derniers logs par VM
for vm_dir in ~/VirtualBox/*/; do
    ls -t "$vm_dir"VBox.log* 2>/dev/null | tail -n +4 | xargs rm -f
done
```

### Déplacement de VMs pour libérer de l'espace

#### Déplacer une VM vers un autre disque

```bash
# Méthode 1: Clone vers nouveau emplacement
VBoxManage clonevm "ma-vm" \
    --name "ma-vm-moved" \
    --basefolder "/nouveau/chemin" \
    --mode all \
    --register

# Supprimer l'ancienne VM
VBoxManage unregistervm "ma-vm" --delete

# Renommer la nouvelle
VBoxManage modifyvm "ma-vm-moved" --name "ma-vm"

# Méthode 2: Déplacer manuellement (VM arrêtée)
# 1. Exporter la VM
VBoxManage export "ma-vm" --output "/tmp/ma-vm.ova"

# 2. Supprimer l'originale
VBoxManage unregistervm "ma-vm" --delete

# 3. Importer au nouvel emplacement
VBoxManage import "/tmp/ma-vm.ova" \
    --vsys 0 \
    --basefolder "/nouveau/chemin"
```

#### Déplacer uniquement les disques

```bash
# 1. Arrêter la VM
VBoxManage controlvm "ma-vm" poweroff

# 2. Détacher le disque
VBoxManage storageattach "ma-vm" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --medium none

# 3. Déplacer physiquement le fichier
mv "/ancien/chemin/disk.vdi" "/nouveau/chemin/disk.vdi"

# 4. Mettre à jour l'enregistrement
VBoxManage closemedium disk "/ancien/chemin/disk.vdi"
VBoxManage internalcommands sethduuid "/nouveau/chemin/disk.vdi"

# 5. Réattacher le disque
VBoxManage storageattach "ma-vm" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/nouveau/chemin/disk.vdi"
```

### Quotas et limites

#### Définir des limites de taille

```bash
# Créer un disque avec taille maximale limitée
VBoxManage createmedium disk \
    --filename "/path/to/limited-disk.vdi" \
    --size 51200 \
    --format VDI \
    --variant Standard

# Les disques dynamiques n'occuperont jamais plus que la taille définie
```

#### Monitoring automatisé de l'espace

```bash
#!/bin/bash
# monitor-disk-space.sh - Alertes si espace faible

THRESHOLD=90  # Pourcentage d'alerte
MAIL_TO="admin@example.com"

# Vérifier l'espace du dossier VirtualBox
vbox_usage=$(df -h ~/VirtualBox | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$vbox_usage" -gt "$THRESHOLD" ]; then
    echo "ALERTE: Espace disque VirtualBox à ${vbox_usage}%" | \
        mail -s "Alerte VirtualBox espace disque" "$MAIL_TO"
    
    # Log les plus gros consommateurs
    du -sh ~/VirtualBox/*/ | sort -h -r | head -10
fi

# Vérifier les disques individuels
VBoxManage list hdds | grep "Location:" | cut -d: -f2- | while read disk; do
    disk=$(echo "$disk" | xargs)
    size=$(VBoxManage showmediuminfo disk "$disk" | grep "Current size" | \
           awk '{print $4}')
    capacity=$(VBoxManage showmediuminfo disk "$disk" | grep "Capacity:" | \
               awk '{print $2}')
    
    # Calculer le pourcentage d'utilisation
    if [ -n "$size" ] && [ -n "$capacity" ]; then
        percent=$((size * 100 / capacity))
        if [ "$percent" -gt "$THRESHOLD" ]; then
            echo "Disque quasi plein: $disk (${percent}%)"
        fi
    fi
done
```

### Stratégies de gestion de l'espace à long terme

#### Rotation des environnements

```bash
# Supprimer les environnements de test expirés
find ~/VirtualBox/Testing -type d -mtime +7 -exec echo "À supprimer: {}" \;

# Archiver les VMs de développement inactives
for vm_dir in ~/VirtualBox/Development/*/; do
    vm_name=$(basename "$vm_dir")
    last_used=$(VBoxManage showvminfo "$vm_name" --machinereadable | \
                grep "lastStateChange" | cut -d'"' -f2)
    
    # Si non utilisée depuis 90 jours, archiver
    # (nécessite logique de comparaison de dates)
    echo "Vérification: $vm_name - Dernière utilisation: $last_used"
done
```

#### Utilisation de disques partagés

```bash
# Pour des bases communes (ex: systèmes d'exploitation)
# Créer un disque immutable partagé entre VMs
VBoxManage createmedium disk \
    --filename "/path/to/shared-base.vdi" \
    --size 20480 \
    --format VDI \
    --variant Fixed

# Le marquer comme immutable
VBoxManage modifymedium disk "/path/to/shared-base.vdi" --type immutable

# Attacher à plusieurs VMs (chacune aura son delta)
VBoxManage storageattach "vm1" --storagectl "SATA" --port 0 \
    --type hdd --medium "/path/to/shared-base.vdi"
VBoxManage storageattach "vm2" --storagectl "SATA" --port 0 \
    --type hdd --medium "/path/to/shared-base.vdi"
```

> [!tip] Dashboard d'espace disque Créez un script de monitoring global :
> 
> ```bash
> #!/bin/bash
> echo "=== Dashboard VirtualBox Espace Disque ==="
> echo ""
> echo "Espace total utilisé:"
> du -sh ~/VirtualBox
> echo ""
> echo "Top 10 VMs par taille:"
> du -sh ~/VirtualBox/*/ | sort -h -r | head -10
> echo ""
> echo "Disques dynamiques à compacter:"
> # Logique de détection des disques à compacter
> echo ""
> echo "Snapshots orphelins:"
> # Logique de détection des snapshots anciens
> ```

---

## 📊 Tableau récapitulatif des bonnes pratiques

|Catégorie|Pratique|Commande clé|Fréquence|
|---|---|---|---|
|**Organisation**|Groupes de VMs|`--groups "/Production"`|À la création|
|**Naming**|Convention cohérente|`prod-web-nginx-01`|Toujours|
|**Documentation**|Description VM|`--description`|À la création|
|**Backup**|Export OVA|`VBoxManage export`|Quotidien (prod)|
|**Backup**|Snapshots|`snapshot take`|Avant changements|
|**Performance**|Allocation CPU|`--cpus 2`|À la création|
|**Performance**|Allocation RAM|`--memory 4096`|À l'usage|
|**Espace**|Compactage|`--compact`|Mensuel|
|**Espace**|Nettoyage snapshots|`snapshot delete`|Hebdomadaire|

---

> [!tip] Checklist de mise en production d'une VM Avant de mettre une VM en production, vérifiez :
> 
> - ✅ Nom respecte la convention de nommage
> - ✅ Description et propriétés personnalisées remplies
> - ✅ Groupe assigné correctement
> - ✅ Ressources (CPU/RAM) optimisées
> - ✅ Disque de type Fixed pour performances
> - ✅ Backup automatisé configuré
> - ✅ Snapshot de référence créé
> - ✅ Documentation README créée
> - ✅ Monitoring d'espace disque en place

> [!example] Exemple de workflow complet
> 
> ```bash
> # 1. Créer la VM avec bonnes pratiques
> VM_NAME="prod-web-nginx-01"
> VBoxManage createvm --name "$VM_NAME" \
>     --groups "/Production/Web" \
>     --ostype "Ubuntu_64" \
>     --register
> 
> # 2. Configuration optimisée
> VBoxManage modifyvm "$VM_NAME" \
>     --memory 4096 \
>     --cpus 2 \
>     --vram 16 \
>     --acpi on \
>     --ioapic on \
>     --hwvirtex on \
>     --nestedpaging on \
>     --nictype1 virtio
> 
> # 3. Documentation
> VBoxManage modifyvm "$VM_NAME" --description "Production Web Server
> Version: Ubuntu 22.04 LTS
> Role: Nginx Frontend
> Owner: DevOps Team
> Created: $(date)"
> 
> VBoxManage setextradata "$VM_NAME" "Project" "E-commerce"
> VBoxManage setextradata "$VM_NAME" "Environment" "Production"
> 
> # 4. Snapshot de base
> VBoxManage snapshot "$VM_NAME" take "initial-config" \
>     --description "Configuration initiale validée"
> 
> # 5. Backup initial
> VBoxManage export "$VM_NAME" \
>     --output "/backup/${VM_NAME}-initial.ova"
> ```

---

**🎓 Fin de la partie : Bonnes pratiques**