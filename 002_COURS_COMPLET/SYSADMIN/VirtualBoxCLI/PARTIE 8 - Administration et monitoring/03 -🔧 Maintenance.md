

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

La maintenance régulière de VirtualBox est essentielle pour garantir des performances optimales et éviter l'accumulation de fichiers inutiles. Cette partie couvre les opérations de maintenance courantes que vous devrez effectuer pour maintenir votre environnement de virtualisation propre et efficace.

> [!info] Pourquoi la maintenance ?
> 
> - Libère de l'espace disque
> - Améliore les performances des VMs
> - Prévient les problèmes de corruption
> - Facilite la gestion des sauvegardes

---

## Propriétés système

### Afficher les propriétés système

La commande `list systemproperties` permet de consulter l'ensemble des paramètres globaux de VirtualBox.

```bash
VBoxManage list systemproperties
```

> [!example] Informations retournées Cette commande affiche des informations cruciales comme :
> 
> - Le dossier par défaut des machines virtuelles
> - Le dossier des snapshots
> - Le dossier des fichiers de configuration
> - Les limites système (RAM max, CPU max)
> - Les chemins des extensions VirtualBox

### Sortie typique

```bash
# Exemple de sortie
Default machine folder:          /home/user/VirtualBox VMs
Default hard disk format:        VDI
VRDE auth library:               VBoxAuth
Webservice auth. library:        VBoxAuth
Remote desktop ExtPack:          Oracle VM VirtualBox Extension Pack
Log history count:               3
Default frontend:                GUI/Qt
Default audio driver:            PulseAudio
```

> [!tip] Astuce de filtrage Vous pouvez filtrer la sortie avec `grep` pour cibler une information spécifique :
> 
> ```bash
> VBoxManage list systemproperties | grep "machine folder"
> ```

### Modifier les propriétés système

Certaines propriétés peuvent être modifiées avec la commande `setproperty`.

```bash
# Syntaxe générale
VBoxManage setproperty <nom_propriété> <valeur>

# Changer le dossier par défaut des VMs
VBoxManage setproperty machinefolder /chemin/vers/nouveau/dossier

# Définir le format de disque par défaut
VBoxManage setproperty defaulthardiskformat VDI

# Modifier le nombre de logs conservés
VBoxManage setproperty loghistorycount 5
```

> [!warning] Attention aux chemins Assurez-vous que le nouveau dossier existe et dispose des permissions appropriées avant de modifier les chemins par défaut.

---

## Chemins par défaut

### Structure des dossiers VirtualBox

VirtualBox utilise plusieurs dossiers pour organiser ses fichiers. Comprendre cette structure est essentiel pour la maintenance.

|Type de fichier|Chemin par défaut (Linux)|Description|
|---|---|---|
|Machines virtuelles|`~/VirtualBox VMs/`|Contient les VMs et leurs fichiers|
|Configuration globale|`~/.config/VirtualBox/`|Paramètres de VirtualBox|
|Logs|`~/VirtualBox VMs/<VM>/Logs/`|Fichiers journaux des VMs|
|Snapshots|`~/VirtualBox VMs/<VM>/Snapshots/`|Images des snapshots|

### Consulter les chemins actuels

```bash
# Afficher tous les chemins
VBoxManage list systemproperties | grep -i "folder\|path"

# Chemin spécifique d'une VM
VBoxManage showvminfo "MaVM" | grep "Config file"
```

### Modifier les chemins par défaut

```bash
# Changer le dossier des machines
VBoxManage setproperty machinefolder "/data/virtualbox/vms"

# Changer le dossier des snapshots (pour une VM spécifique)
VBoxManage modifyvm "MaVM" --snapshotfolder "/data/snapshots/MaVM"
```

> [!tip] Bonne pratique : séparation des disques Pour de meilleures performances, placez :
> 
> - Les VMs sur un SSD rapide
> - Les snapshots et sauvegardes sur un HDD de stockage

> [!warning] Déplacement de VMs existantes Si vous changez le dossier par défaut, les VMs existantes ne sont PAS déplacées automatiquement. Vous devez les déplacer manuellement avec `VBoxManage movevm`.

---

## Nettoyage des médias orphelins

### Qu'est-ce qu'un média orphelin ?

Un média orphelin est un fichier de disque virtuel (VDI, VMDK, VHD) qui n'est plus attaché à aucune machine virtuelle mais reste enregistré dans VirtualBox.

> [!info] Causes courantes
> 
> - Suppression d'une VM sans supprimer ses disques
> - Clonage de VMs
> - Snapshots supprimés incorrectement
> - Tests et expérimentations

### Lister les médias enregistrés

```bash
# Lister tous les disques durs virtuels
VBoxManage list hdds

# Lister les DVDs virtuels
VBoxManage list dvds

# Lister les disquettes virtuelles
VBoxManage list floppies
```

> [!example] Sortie typique pour un disque
> 
> ```
> UUID:           a1b2c3d4-e5f6-7890-abcd-ef1234567890
> Parent UUID:    base
> State:          created
> Type:           normal (base)
> Location:       /home/user/VirtualBox VMs/Ubuntu/Ubuntu.vdi
> Storage format: VDI
> Capacity:       20480 MBytes
> ```

### Identifier les médias orphelins

```bash
# Script pour détecter les médias orphelins
# Affiche les disques non attachés à une VM
VBoxManage list hdds | grep -A 10 "UUID" | grep -B 1 "In use by VMs:"
```

> [!tip] Méthode manuelle
> 
> 1. Listez tous les disques : `VBoxManage list hdds`
> 2. Pour chaque UUID, vérifiez s'il est utilisé :
> 
> ```bash
> VBoxManage showhdinfo <UUID> | grep "In use by VMs"
> ```
> 
> 3. Si vide, c'est un orphelin

### Supprimer un média orphelin

```bash
# Supprimer un disque de la base de données VirtualBox (sans supprimer le fichier)
VBoxManage closemedium disk <UUID>

# Supprimer un disque ET le fichier physique
VBoxManage closemedium disk <UUID> --delete
```

> [!warning] Prudence avec --delete L'option `--delete` supprime définitivement le fichier du disque dur. Assurez-vous de ne plus en avoir besoin !

### Nettoyage complet des médias inaccessibles

```bash
# Lister les médias inaccessibles
VBoxManage list hdds | grep -i "inaccessible"

# Supprimer tous les médias inaccessibles (script bash)
for uuid in $(VBoxManage list hdds | grep "^UUID:" | awk '{print $2}'); do
    if VBoxManage showhdinfo "$uuid" 2>&1 | grep -q "VBOX_E_OBJECT_NOT_FOUND"; then
        echo "Suppression de $uuid"
        VBoxManage closemedium disk "$uuid" 2>/dev/null
    fi
done
```

> [!tip] Maintenance préventive Exécutez ce nettoyage régulièrement (par exemple, mensuellement) pour éviter l'accumulation de médias orphelins.

---

## Compact et optimisation

### Pourquoi compacter ?

Les disques virtuels à allocation dynamique (thin provisioned) grossissent au fil du temps mais ne rétrécissent pas automatiquement quand vous supprimez des fichiers. Le compactage permet de récupérer cet espace.

> [!info] Économies d'espace typiques
> 
> - Après installation/désinstallation de logiciels : 10-30%
> - Après suppression de fichiers volumineux : 20-50%
> - Sur des VMs anciennes jamais compactées : jusqu'à 60%

### Préparation avant compactage

#### Sur une VM Linux/Unix

```bash
# 1. Supprimer les caches et fichiers temporaires
sudo apt clean              # Ubuntu/Debian
sudo yum clean all          # CentOS/RHEL
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# 2. Remplir l'espace libre avec des zéros
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY

# 3. Éteindre la VM
sudo shutdown -h now
```

#### Sur une VM Windows

```powershell
# 1. Nettoyer le disque avec l'outil Windows
cleanmgr /d C:

# 2. Défragmenter (optionnel, pour disques VDI)
defrag C: /U /V

# 3. Remplir l'espace libre avec des zéros
# Télécharger SDelete de Microsoft Sysinternals
sdelete -z C:

# 4. Éteindre la VM
shutdown /s /t 0
```

> [!warning] Temps de traitement Le remplissage avec des zéros peut prendre de 10 minutes à plusieurs heures selon la taille du disque et l'espace libre.

### Compacter un disque VDI

```bash
# Syntaxe de base
VBoxManage modifymedium disk <UUID_ou_chemin> --compact

# Avec un chemin de fichier
VBoxManage modifymedium disk "/home/user/VirtualBox VMs/Ubuntu/Ubuntu.vdi" --compact

# Avec un UUID
VBoxManage modifymedium disk a1b2c3d4-e5f6-7890-abcd-ef1234567890 --compact
```

> [!tip] Suivi de progression Le compactage peut être long. VirtualBox affiche une barre de progression :
> 
> ```
> 0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
> ```

### Compacter un disque VMDK

Les disques VMDK nécessitent une approche différente selon leur type.

```bash
# Pour les VMDK à allocation dynamique
VBoxManage modifymedium disk <fichier.vmdk> --compact

# Pour les VMDK monolithiques (fichier unique)
# Le compactage est automatiquement géré
```

> [!warning] VMDK en mode split Les disques VMDK divisés en plusieurs fichiers (2GB split) ne peuvent pas être compactés directement. Il faut les convertir en VDI d'abord.

### Clonage vers un nouveau disque (optimisation maximale)

Pour une optimisation maximale, clonez le disque vers un nouveau fichier :

```bash
# Cloner un disque avec compactage
VBoxManage clonemedium disk "source.vdi" "destination.vdi" --format VDI

# Cloner et convertir le format
VBoxManage clonemedium disk "source.vmdk" "destination.vdi" --format VDI
```

> [!tip] Avantages du clonage
> 
> - Défragmente complètement le disque virtuel
> - Élimine toute fragmentation interne
> - Permet de changer de format (VMDK → VDI)
> - Crée un disque "propre" optimisé

### Script de compactage automatique

```bash
#!/bin/bash
# compact_all_vms.sh - Compacte tous les disques VDI

echo "=== Compactage automatique de tous les disques VDI ==="

# Lister tous les disques VDI
vdis=$(VBoxManage list hdds | grep "Location.*\.vdi" | awk '{print $2}')

for vdi in $vdis; do
    echo "Traitement de : $vdi"
    
    # Vérifier si le disque est utilisé par une VM en cours d'exécution
    uuid=$(VBoxManage showhdinfo "$vdi" | grep "^UUID:" | awk '{print $2}')
    in_use=$(VBoxManage showhdinfo "$uuid" | grep "In use by VMs:" | awk '{print $5}')
    
    if [ -z "$in_use" ] || [ "$in_use" = "none" ]; then
        echo "  → Compactage en cours..."
        VBoxManage modifymedium disk "$vdi" --compact
        echo "  → Terminé"
    else
        echo "  → IGNORÉ (utilisé par une VM en cours d'exécution)"
    fi
    echo ""
done

echo "=== Compactage terminé ==="
```

> [!warning] VMs en cours d'exécution Ne jamais compacter un disque attaché à une VM en cours d'exécution. Arrêtez toujours la VM d'abord.

### Optimisation des performances post-compactage

```bash
# Défragmenter le fichier VDI sur le système hôte (ext4)
# (Rarement nécessaire, mais peut aider sur des systèmes très fragmentés)
sudo e4defrag "/home/user/VirtualBox VMs/Ubuntu/Ubuntu.vdi"

# Vérifier l'intégrité du disque après compactage
VBoxManage showhdinfo <UUID> | grep -i "state\|format\|capacity"
```

---

## Sauvegarde et restauration

### Stratégies de sauvegarde

Il existe plusieurs approches pour sauvegarder vos VMs, chacune avec ses avantages et inconvénients.

|Méthode|Avantages|Inconvénients|Cas d'usage|
|---|---|---|---|
|Export OVA|Format standard, portable|Lent, volumineux|Migration vers autre hyperviseur|
|Clone de disque|Rapide, compact|Nécessite VirtualBox pour restaurer|Sauvegarde quotidienne|
|Snapshot|Instantané, pas de downtime|Ralentit la VM|Tests, points de restauration|
|Copie manuelle|Simple, complet|Requiert arrêt de la VM|Sauvegarde complète occasionnelle|

### Exporter une VM (format OVA/OVF)

```bash
# Export au format OVA (recommandé)
VBoxManage export "MaVM" --output "/backup/MaVM.ova"

# Export avec options de compression
VBoxManage export "MaVM" \
  --output "/backup/MaVM.ova" \
  --options manifest,iso,nomacs

# Export multiple VMs
VBoxManage export "VM1" "VM2" "VM3" \
  --output "/backup/multiple_vms.ova"
```

> [!info] Options d'export
> 
> - `manifest` : Crée un fichier de vérification d'intégrité
> - `iso` : Inclut les images ISO attachées
> - `nomacs` : Exclut les adresses MAC (utile pour le clonage)
> - `nomacsbutnat` : Conserve les MACs sauf pour les interfaces NAT

> [!tip] Vitesse d'export L'export peut être long (30 min à 2h pour une VM de 50 GB). Planifiez vos sauvegardes en dehors des heures de travail.

### Importer une VM sauvegardée

```bash
# Import simple
VBoxManage import "/backup/MaVM.ova"

# Import avec nouveau nom
VBoxManage import "/backup/MaVM.ova" \
  --vsys 0 --vmname "MaVM_Restauree"

# Import avec configuration personnalisée
VBoxManage import "/backup/MaVM.ova" \
  --vsys 0 \
  --vmname "MaVM_Restauree" \
  --memory 4096 \
  --cpus 2 \
  --unit 5 --disk "/custom/path/disk.vdi"
```

> [!example] Vérifier le contenu avant import
> 
> ```bash
> # Lister les détails d'un fichier OVA
> VBoxManage import "/backup/MaVM.ova" --dry-run
> ```

### Cloner une VM complète

Le clonage est plus rapide que l'export/import et préserve tous les paramètres.

```bash
# Clone complet avec nouveaux UUID
VBoxManage clonevm "VMSource" --name "VMClone" --register

# Clone avec génération de nouvelles adresses MAC
VBoxManage clonevm "VMSource" \
  --name "VMClone" \
  --options link \
  --register

# Clone linked (disque partagé avec la source)
VBoxManage clonevm "VMSource" \
  --name "VMClone" \
  --snapshot "MonSnapshot" \
  --options link \
  --register
```

> [!info] Types de clone
> 
> - **Clone complet** : Copie tout, indépendant de la source
> - **Linked clone** : Partage le disque de base, économise l'espace
> - **Clone de snapshot** : Clone à partir d'un état spécifique

> [!warning] Linked clones et sauvegardes Les linked clones dépendent du disque source. Si vous supprimez la VM source, le clone devient inutilisable.

### Sauvegarder uniquement les disques

```bash
# Cloner un disque virtuel
VBoxManage clonemedium disk \
  "source.vdi" \
  "/backup/source_backup.vdi" \
  --format VDI

# Cloner avec compression
VBoxManage clonemedium disk \
  "source.vdi" \
  "/backup/source_backup.vdi" \
  --format VDI \
  --variant Standard
```

> [!tip] Formats de compression
> 
> - `Standard` : Allocation dynamique (recommandé pour sauvegardes)
> - `Fixed` : Allocation fixe (plus rapide mais plus volumineux)
> - `Split2G` : Découpage en fichiers de 2 GB (pour FAT32)

### Sauvegarder la configuration d'une VM

```bash
# Exporter uniquement la configuration
VBoxManage showvminfo "MaVM" --machinereadable > "/backup/MaVM_config.txt"

# Sauvegarder le fichier de configuration XML
cp "$HOME/.config/VirtualBox/MaVM/MaVM.vbox" "/backup/MaVM.vbox.backup"
```

### Restaurer un disque

```bash
# 1. Créer une nouvelle VM
VBoxManage createvm --name "VM_Restauree" --register

# 2. Attacher le disque restauré
VBoxManage storagectl "VM_Restauree" \
  --name "SATA" \
  --add sata \
  --controller IntelAhci

VBoxManage storageattach "VM_Restauree" \
  --storagectl "SATA" \
  --port 0 \
  --device 0 \
  --type hdd \
  --medium "/backup/source_backup.vdi"

# 3. Configurer la VM (RAM, CPU, etc.)
VBoxManage modifyvm "VM_Restauree" --memory 2048 --cpus 2
```

### Script de sauvegarde automatisée

```bash
#!/bin/bash
# backup_vm.sh - Sauvegarde automatique d'une VM

VM_NAME="$1"
BACKUP_DIR="/backup/virtualbox"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/${VM_NAME}_${DATE}"

if [ -z "$VM_NAME" ]; then
    echo "Usage: $0 <nom_vm>"
    exit 1
fi

echo "=== Sauvegarde de $VM_NAME ==="

# Créer le dossier de sauvegarde
mkdir -p "$BACKUP_PATH"

# Vérifier si la VM est en cours d'exécution
STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "VMState=" | cut -d'"' -f2)

if [ "$STATE" != "poweroff" ]; then
    echo "Arrêt de la VM..."
    VBoxManage controlvm "$VM_NAME" acpipowerbutton
    
    # Attendre l'arrêt (max 60 secondes)
    for i in {1..60}; do
        STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "VMState=" | cut -d'"' -f2)
        if [ "$STATE" = "poweroff" ]; then
            break
        fi
        sleep 1
    done
fi

# Export de la VM
echo "Export en cours..."
VBoxManage export "$VM_NAME" \
  --output "$BACKUP_PATH/${VM_NAME}.ova" \
  --options manifest,iso

# Vérification
if [ $? -eq 0 ]; then
    echo "✓ Sauvegarde réussie : $BACKUP_PATH/${VM_NAME}.ova"
    
    # Nettoyer les anciennes sauvegardes (garder les 7 dernières)
    cd "$BACKUP_DIR"
    ls -t | grep "^${VM_NAME}_" | tail -n +8 | xargs -r rm -rf
    
    echo "✓ Anciennes sauvegardes nettoyées"
else
    echo "✗ Erreur lors de la sauvegarde"
    exit 1
fi

echo "=== Sauvegarde terminée ==="
```

> [!tip] Automatisation avec cron
> 
> ```bash
> # Sauvegarde quotidienne à 2h du matin
> 0 2 * * * /usr/local/bin/backup_vm.sh "ProductionVM" >> /var/log/vm_backup.log 2>&1
> ```

### Restauration complète

Pour restaurer une VM à partir d'une sauvegarde OVA :

```bash
# 1. Supprimer l'ancienne VM (si nécessaire)
VBoxManage unregistervm "MaVM" --delete

# 2. Importer la sauvegarde
VBoxManage import "/backup/MaVM_20241214.ova" --vsys 0 --vmname "MaVM"

# 3. Vérifier l'import
VBoxManage showvminfo "MaVM" | grep -i "state\|name"

# 4. Démarrer la VM
VBoxManage startvm "MaVM" --type headless
```

> [!warning] Vérification post-restauration Après une restauration, vérifiez toujours :
> 
> - La connectivité réseau (les MACs peuvent avoir changé)
> - Les chemins des dossiers partagés
> - Les périphériques USB attachés
> - Les licences logicielles liées au hardware

### Sauvegarde incrémentale avec snapshots

Pour des sauvegardes plus fréquentes avec moins d'espace :

```bash
# 1. Créer un snapshot
VBoxManage snapshot "MaVM" take "Backup_$(date +%Y%m%d)"

# 2. Lister les snapshots
VBoxManage snapshot "MaVM" list

# 3. Restaurer depuis un snapshot
VBoxManage snapshot "MaVM" restore "Backup_20241214"

# 4. Supprimer les anciens snapshots
VBoxManage snapshot "MaVM" delete "Backup_20241201"
```

> [!info] Snapshots vs Export
> 
> - **Snapshots** : Rapides, peu d'espace, mais nécessitent la VM source
> - **Export** : Lents, volumineux, mais complètement indépendants
> - Utilisez les snapshots pour les sauvegardes fréquentes, l'export pour les archives long terme

---

## 🎯 Points clés à retenir

- **Propriétés système** : Utilisez `list systemproperties` pour comprendre votre configuration VirtualBox
- **Chemins** : Organisez vos VMs avec des chemins logiques et cohérents
- **Nettoyage** : Supprimez régulièrement les médias orphelins pour économiser l'espace
- **Compactage** : Récupérez l'espace disque en compactant vos VDI après le nettoyage des VMs
- **Sauvegarde** : Adoptez une stratégie mixte (snapshots + exports périodiques)
- **Automatisation** : Créez des scripts pour automatiser les tâches répétitives

> [!tip] Routine de maintenance recommandée **Hebdomadaire** : Vérifier les médias orphelins **Mensuelle** : Compacter les disques des VMs principales **Trimestrielle** : Export complet des VMs critiques **Annuelle** : Révision et nettoyage complet de l'environnement VirtualBox