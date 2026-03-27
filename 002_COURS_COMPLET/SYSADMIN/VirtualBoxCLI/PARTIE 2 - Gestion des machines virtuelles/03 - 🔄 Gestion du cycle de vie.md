

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

## 📋 Lister les VMs (`list`)

### Pourquoi c'est important

La commande `list` est votre point d'entrée pour connaître l'état de votre infrastructure virtuelle. Elle permet de visualiser rapidement toutes les machines disponibles, leur état d'exécution, et les types de systèmes supportés.

### Syntaxe de base

```bash
VBoxManage list <type>
```

### Types de listage disponibles

#### 1. Lister toutes les VMs enregistrées

```bash
VBoxManage list vms
```

**Sortie typique :**

```
"Ubuntu-Server" {a1b2c3d4-e5f6-7890-abcd-ef1234567890}
"Windows-10-Dev" {b2c3d4e5-f6a7-8901-bcde-f12345678901}
"Debian-Test" {c3d4e5f6-a7b8-9012-cdef-123456789012}
```

> [!info] Format de sortie Chaque ligne affiche le nom de la VM suivi de son UUID (identifiant unique universel) entre accolades. L'UUID est l'identifiant absolu de la machine.

#### 2. Lister uniquement les VMs en cours d'exécution

```bash
VBoxManage list runningvms
```

**Exemple :**

```
"Ubuntu-Server" {a1b2c3d4-e5f6-7890-abcd-ef1234567890}
```

> [!tip] Astuce shell Compter rapidement les VMs actives :
> 
> ```bash
> VBoxManage list runningvms | wc -l
> ```

#### 3. Lister les types de systèmes d'exploitation supportés

```bash
VBoxManage list ostypes
```

**Extrait de sortie :**

```
ID:          Ubuntu_64
Description: Ubuntu (64-bit)
Family ID:   Linux
Family Desc: Linux
64 bit:      true

ID:          Windows10_64
Description: Windows 10 (64-bit)
Family ID:   Windows
Family Desc: Microsoft Windows
64 bit:      true
```

> [!info] Utilité Cette liste est essentielle lors de la création d'une VM pour spécifier correctement le paramètre `--ostype`.

### Autres types de listage utiles

```bash
# Lister les disques durs virtuels
VBoxManage list hdds

# Lister les DVDs enregistrés
VBoxManage list dvds

# Lister les groupes de VMs
VBoxManage list groups

# Lister les informations système de l'hôte
VBoxManage list hostinfo

# Lister les réseaux Host-Only
VBoxManage list hostonlyifs

# Lister les réseaux Bridge disponibles
VBoxManage list bridgedifs
```

### Cas d'usage pratiques

**Script de monitoring :**

```bash
#!/bin/bash
# Afficher un résumé de l'infrastructure

echo "=== VMs totales ==="
VBoxManage list vms | wc -l

echo "=== VMs actives ==="
VBoxManage list runningvms

echo "=== Disques virtuels ==="
VBoxManage list hdds | grep "^Location:" | wc -l
```

> [!warning] Attention aux performances Sur des systèmes avec beaucoup de VMs, `list hdds` peut être lent car il analyse tous les fichiers de disques virtuels.

---

## 🔍 Afficher les informations détaillées (`showvminfo`)

### Pourquoi c'est important

`showvminfo` est l'équivalent d'un "scanner médical" pour votre VM. Elle révèle absolument tous les paramètres de configuration, de l'UUID au réseau en passant par les snapshots et les dossiers partagés.

### Syntaxe de base

```bash
VBoxManage showvminfo <vm-name|uuid>
```

### Options principales

```bash
# Affichage standard (lisible par l'humain)
VBoxManage showvminfo "Ubuntu-Server"

# Format machine-readable (pour scripts)
VBoxManage showvminfo "Ubuntu-Server" --machinereadable

# Afficher aussi les logs
VBoxManage showvminfo "Ubuntu-Server" --log 0
```

### Exemple de sortie (format standard)

```
Name:                        Ubuntu-Server
Groups:                      /
Guest OS:                    Ubuntu (64-bit)
UUID:                        a1b2c3d4-e5f6-7890-abcd-ef1234567890
Config file:                 /home/user/VirtualBox VMs/Ubuntu-Server/Ubuntu-Server.vbox
Snapshot folder:             /home/user/VirtualBox VMs/Ubuntu-Server/Snapshots
Log folder:                  /home/user/VirtualBox VMs/Ubuntu-Server/Logs
Hardware UUID:               a1b2c3d4-e5f6-7890-abcd-ef1234567890
Memory size:                 2048MB
Page Fusion:                 disabled
VRAM size:                   16MB
CPU exec cap:                100%
Number of CPUs:              2
```

### Exemple de sortie (format machine-readable)

```bash
VBoxManage showvminfo "Ubuntu-Server" --machinereadable
```

```
name="Ubuntu-Server"
groups="/"
ostype="Ubuntu_64"
UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890"
memory=2048
vram=16
cpus=2
VMState="running"
```

> [!tip] Parsing avec grep Le format machine-readable est idéal pour extraire des informations spécifiques :
> 
> ```bash
> # Récupérer uniquement l'état de la VM
> VBoxManage showvminfo "Ubuntu-Server" --machinereadable | grep "^VMState"
> 
> # Récupérer la RAM
> VBoxManage showvminfo "Ubuntu-Server" --machinereadable | grep "^memory="
> ```

### Informations clés à surveiller

#### État de la VM

```bash
State:                       running (since 2024-12-14T10:30:00.000000000)
```

Valeurs possibles : `poweroff`, `running`, `paused`, `saved`, `aborted`

#### Configuration réseau

```bash
NIC 1:                       MAC: 080027A1B2C3, Attachment: NAT, Cable connected: on, Trace: off
NIC 1 Settings:              MTU: 0, Socket (send: 64, receive: 64), TCP Window (send:64, receive: 64)
```

#### Snapshots

```bash
Snapshots:

   Name: Pre-Update (UUID: b2c3d4e5-f6a7-8901-bcde-f12345678901)
      Description: Before system upgrade
      
   Name: Clean Install (UUID: c3d4e5f6-a7b8-9012-cdef-123456789012) *
```

> [!info] Snapshot actuel L'astérisque (*) indique le snapshot actuellement utilisé.

### Cas d'usage pratiques

**Script de diagnostic :**

```bash
#!/bin/bash
VM_NAME="$1"

echo "=== État de la VM ==="
VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "^VMState"

echo "=== Ressources ==="
VBoxManage showvminfo "$VM_NAME" --machinereadable | grep -E "^(memory|cpus|vram)="

echo "=== Réseau ==="
VBoxManage showvminfo "$VM_NAME" | grep -A 5 "NIC 1:"
```

**Vérifier si une VM existe :**

```bash
if VBoxManage showvminfo "MaVM" &>/dev/null; then
    echo "La VM existe"
else
    echo "La VM n'existe pas"
fi
```

> [!warning] Attention aux noms avec espaces Toujours entourer le nom de la VM de guillemets :
> 
> ```bash
> # ✅ Correct
> VBoxManage showvminfo "Windows 10 Dev"
> 
> # ❌ Incorrect
> VBoxManage showvminfo Windows 10 Dev
> ```

---

## 🧬 Cloner une VM (`clonevm`)

### Pourquoi c'est important

Le clonage permet de dupliquer une VM existante pour créer des environnements de test, des templates, ou des déploiements multiples sans reconfigurer chaque paramètre manuellement. C'est un gain de temps considérable.

### Syntaxe de base

```bash
VBoxManage clonevm <vm-name|uuid> --name <nouveau-nom> [options]
```

### Options essentielles

|Option|Description|Valeurs|
|---|---|---|
|`--name`|Nom de la VM clonée (obligatoire)|Chaîne de caractères|
|`--register`|Enregistrer automatiquement la VM clonée|Flag sans valeur|
|`--mode`|Type de clonage|`machine`, `machinechildren`, `all`|
|`--options`|Options de clonage avancées|`link`, `keepallmacs`, `keepnatmacs`, `keepdisknames`, `keephwuuids`|
|`--snapshot`|Cloner depuis un snapshot spécifique|Nom ou UUID du snapshot|
|`--basefolder`|Dossier de destination|Chemin absolu|

### Types de clonage (`--mode`)

#### 1. Clone complet (`machine`) - Par défaut

```bash
VBoxManage clonevm "Ubuntu-Server" \
    --name "Ubuntu-Server-Clone" \
    --register
```

> [!info] Clone complet Copie uniquement l'état actuel de la VM, sans les snapshots. Crée de nouveaux fichiers de disques indépendants.

#### 2. Clone avec snapshots enfants (`machinechildren`)

```bash
VBoxManage clonevm "Ubuntu-Server" \
    --name "Ubuntu-Server-Clone" \
    --mode machinechildren \
    --register
```

> [!info] Inclusion partielle Clone l'état actuel et tous les snapshots qui sont des enfants de l'état actuel.

#### 3. Clone complet avec tous les snapshots (`all`)

```bash
VBoxManage clonevm "Ubuntu-Server" \
    --name "Ubuntu-Server-Clone" \
    --mode all \
    --register
```

> [!info] Clone intégral Clone la VM avec l'intégralité de l'arbre de snapshots. Utile pour conserver l'historique complet.

### Options de clonage avancées (`--options`)

#### Clone lié (Linked Clone)

```bash
VBoxManage clonevm "Ubuntu-Server" \
    --name "Ubuntu-Dev-1" \
    --snapshot "Clean-Install" \
    --options link \
    --register
```

> [!tip] Économie d'espace Un clone lié partage les disques virtuels avec la VM source et ne stocke que les différences (delta). Extrêmement rapide et économe en espace disque.

> [!warning] Dépendance La VM source ne doit pas être supprimée, sinon le clone lié devient inutilisable.

#### Conserver les adresses MAC

```bash
# Conserver toutes les adresses MAC
VBoxManage clonevm "Ubuntu-Server" \
    --name "Ubuntu-Clone" \
    --options keepallmacs \
    --register

# Conserver uniquement les MAC des interfaces NAT
VBoxManage clonevm "Ubuntu-Server" \
    --name "Ubuntu-Clone" \
    --options keepnatmacs \
    --register
```

> [!warning] Conflits réseau Garder les mêmes adresses MAC peut causer des conflits si les deux VMs sont sur le même réseau. Par défaut, VirtualBox génère de nouvelles adresses MAC.

#### Conserver les noms de disques

```bash
VBoxManage clonevm "Ubuntu-Server" \
    --name "Ubuntu-Clone" \
    --options keepdisknames \
    --register
```

> [!info] Cas d'usage Utile si vous avez des scripts qui référencent des noms de disques spécifiques.

### Cloner depuis un snapshot spécifique

```bash
VBoxManage clonevm "Ubuntu-Server" \
    --snapshot "Pre-Update" \
    --name "Ubuntu-Rollback-Test" \
    --register
```

> [!example] Cas d'usage Créer une VM de test basée sur un état antérieur sans affecter la VM principale.

### Spécifier le dossier de destination

```bash
VBoxManage clonevm "Ubuntu-Server" \
    --name "Ubuntu-Production" \
    --basefolder "/mnt/vms/production" \
    --register
```

### Exemples pratiques complets

#### Créer un template et des clones liés

```bash
# 1. Créer et configurer une VM de base
VBoxManage createvm --name "Ubuntu-Template" --ostype Ubuntu_64 --register
# ... configuration complète ...

# 2. Créer un snapshot "clean" comme point de base
VBoxManage snapshot "Ubuntu-Template" take "Clean-Install"

# 3. Créer plusieurs clones liés pour différents usages
VBoxManage clonevm "Ubuntu-Template" \
    --snapshot "Clean-Install" \
    --name "Dev-1" \
    --options link \
    --register

VBoxManage clonevm "Ubuntu-Template" \
    --snapshot "Clean-Install" \
    --name "Dev-2" \
    --options link \
    --register
```

> [!tip] Architecture de template Cette approche est idéale pour créer rapidement plusieurs environnements de développement identiques.

#### Script de clonage automatisé

```bash
#!/bin/bash
SOURCE_VM="Ubuntu-Template"
CLONE_PREFIX="Dev-Environment"
NUM_CLONES=5

for i in $(seq 1 $NUM_CLONES); do
    CLONE_NAME="${CLONE_PREFIX}-${i}"
    
    echo "Création de ${CLONE_NAME}..."
    
    VBoxManage clonevm "$SOURCE_VM" \
        --name "$CLONE_NAME" \
        --snapshot "Clean-Install" \
        --options link \
        --register
        
    # Démarrer le clone
    VBoxManage startvm "$CLONE_NAME" --type headless
done
```

### Pièges courants

> [!warning] Clone sans `--register` Si vous oubliez `--register`, la VM est clonée mais n'apparaît pas dans `VBoxManage list vms`. Vous devrez l'enregistrer manuellement avec `registervm`.

> [!warning] Espace disque insuffisant Un clone complet duplique tous les disques virtuels. Vérifiez l'espace disponible avant de cloner de grosses VMs.

> [!warning] Clones liés et modifications Les modifications sur la VM source peuvent affecter les clones liés. Ne modifiez jamais la VM template après avoir créé des clones liés.

---

## 🗑️ Désinscrire et supprimer des VMs

### Pourquoi c'est important

La suppression de VMs nécessite de comprendre la différence entre "désenregistrer" (retirer de l'inventaire VirtualBox) et "supprimer" (détruire les fichiers). Une mauvaise manipulation peut laisser des fichiers orphelins ou supprimer accidentellement des données importantes.

### Désenregistrer une VM (`unregistervm`)

#### Syntaxe

```bash
VBoxManage unregistervm <vm-name|uuid> [--delete]
```

#### Désenregistrement simple (conservation des fichiers)

```bash
VBoxManage unregistervm "Ubuntu-Test"
```

> [!info] Effet La VM disparaît de l'inventaire VirtualBox (`list vms`), mais tous les fichiers (.vbox, .vdi, etc.) restent sur le disque. Utile pour déplacer une VM ou la réenregistrer plus tard.

#### Réenregistrer une VM

```bash
VBoxManage registervm "/chemin/vers/MaVM/MaVM.vbox"
```

> [!example] Cas d'usage Déplacer une VM vers un autre disque sans la recréer :
> 
> ```bash
> # 1. Désenregistrer
> VBoxManage unregistervm "MaVM"
> 
> # 2. Déplacer manuellement les fichiers
> mv "/home/user/VirtualBox VMs/MaVM" "/mnt/nouveau-disque/"
> 
> # 3. Réenregistrer
> VBoxManage registervm "/mnt/nouveau-disque/MaVM/MaVM.vbox"
> ```

### Suppression complète

#### Avec l'option `--delete`

```bash
VBoxManage unregistervm "Ubuntu-Test" --delete
```

> [!warning] Suppression définitive Cette commande :
> 
> - Désenregistre la VM de VirtualBox
> - Supprime **tous** les fichiers associés (disques virtuels, fichiers de configuration, logs, snapshots)
> - **Aucune confirmation n'est demandée**
> - **Aucun moyen de récupération** (sauf backups)

#### Suppression sélective

Si vous voulez supprimer uniquement certains éléments :

```bash
# 1. Désenregistrer sans supprimer
VBoxManage unregistervm "Ubuntu-Test"

# 2. Supprimer manuellement ce que vous voulez
rm -rf "/home/user/VirtualBox VMs/Ubuntu-Test"

# Ou supprimer uniquement les disques virtuels
VBoxManage closemedium disk "/path/to/disk.vdi" --delete
```

### Suppression des disques virtuels orphelins

#### Lister les disques enregistrés

```bash
VBoxManage list hdds
```

#### Fermer et supprimer un disque

```bash
# Fermer (désenregistrer) le disque
VBoxManage closemedium disk "/path/to/disk.vdi"

# Fermer ET supprimer le fichier
VBoxManage closemedium disk "/path/to/disk.vdi" --delete
```

> [!tip] Nettoyage des orphelins Après avoir supprimé plusieurs VMs, certains disques peuvent rester enregistrés dans VirtualBox. Utilisez cette commande pour faire le ménage.

### Script de suppression sécurisé

```bash
#!/bin/bash
VM_NAME="$1"

if [ -z "$VM_NAME" ]; then
    echo "Usage: $0 <vm-name>"
    exit 1
fi

# Vérifier que la VM existe
if ! VBoxManage showvminfo "$VM_NAME" &>/dev/null; then
    echo "Erreur: La VM '$VM_NAME' n'existe pas"
    exit 1
fi

# Vérifier l'état
STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "^VMState=" | cut -d'"' -f2)

if [ "$STATE" != "poweroff" ]; then
    echo "Erreur: La VM doit être éteinte (état actuel: $STATE)"
    exit 1
fi

# Demander confirmation
read -p "Supprimer définitivement '$VM_NAME' ? (oui/non): " CONFIRM

if [ "$CONFIRM" = "oui" ]; then
    echo "Suppression de '$VM_NAME'..."
    VBoxManage unregistervm "$VM_NAME" --delete
    echo "VM supprimée avec succès"
else
    echo "Opération annulée"
fi
```

### Cas d'usage pratiques

#### Nettoyer toutes les VMs d'un groupe

```bash
#!/bin/bash
GROUP_NAME="/TestGroup"

# Lister les VMs du groupe
VBoxManage list vms | grep "$GROUP_NAME" | while read line; do
    VM_NAME=$(echo "$line" | cut -d'"' -f2)
    echo "Suppression de $VM_NAME..."
    VBoxManage unregistervm "$VM_NAME" --delete
done
```

#### Supprimer uniquement les VMs éteintes

```bash
#!/bin/bash

VBoxManage list vms | cut -d'"' -f2 | while read VM_NAME; do
    STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "^VMState=" | cut -d'"' -f2)
    
    if [ "$STATE" = "poweroff" ]; then
        echo "Suppression de $VM_NAME (éteinte)..."
        VBoxManage unregistervm "$VM_NAME" --delete
    else
        echo "Conservation de $VM_NAME (état: $STATE)"
    fi
done
```

### Pièges courants

> [!warning] VM en cours d'exécution Vous ne pouvez pas supprimer une VM en cours d'exécution. Arrêtez-la d'abord :
> 
> ```bash
> VBoxManage controlvm "MaVM" poweroff
> VBoxManage unregistervm "MaVM" --delete
> ```

> [!warning] Disques partagés Si un disque virtuel est attaché à plusieurs VMs, sa suppression affectera toutes les VMs qui l'utilisent.

> [!warning] Snapshots `--delete` supprime aussi tous les snapshots. Assurez-vous de ne pas perdre d'états importants.

---

## 📦 Import/Export OVF/OVA

### Pourquoi c'est important

Les formats OVF (Open Virtualization Format) et OVA (Open Virtualization Archive) sont des standards de l'industrie pour empaqueter et distribuer des machines virtuelles. Ils permettent de déplacer des VMs entre différents hyperviseurs (VirtualBox, VMware, etc.) et de créer des appliances réutilisables.

### Différence entre OVF et OVA

|Format|Description|Structure|Cas d'usage|
|---|---|---|---|
|**OVF**|Open Virtualization Format|Dossier avec fichiers .ovf (XML), .vmdk/.vdi, .mf|Développement, modification possible|
|**OVA**|Open Virtualization Archive|Archive TAR unique|Distribution, portabilité|

> [!info] OVA = OVF compressé Un fichier OVA est simplement une archive TAR contenant les fichiers OVF. Plus facile à distribuer mais non modifiable sans extraction.

### Exporter une VM (`export`)

#### Syntaxe de base

```bash
VBoxManage export <vm-name|uuid> --output <fichier.ova> [options]
```

#### Export simple en OVA

```bash
VBoxManage export "Ubuntu-Server" --output ubuntu-server.ova
```

#### Export en OVF (format dossier)

```bash
VBoxManage export "Ubuntu-Server" --output ubuntu-server.ovf
```

> [!info] Détection automatique VirtualBox détecte automatiquement le format selon l'extension (.ova ou .ovf).

### Options d'export avancées

#### Définir les métadonnées

```bash
VBoxManage export "Ubuntu-Server" \
    --output ubuntu-server.ova \
    --product "Ubuntu Server" \
    --producturl "https://ubuntu.com" \
    --vendor "Canonical" \
    --vendorurl "https://canonical.com" \
    --version "22.04" \
    --description "Ubuntu Server 22.04 LTS pré-configuré" \
    --eulafile "/path/to/license.txt"
```

> [!tip] Métadonnées professionnelles Ces informations apparaissent lors de l'import et rendent votre appliance plus professionnelle.

#### Choisir le format de disque virtuel

```bash
# Export en VMDK (compatible VMware)
VBoxManage export "Ubuntu-Server" \
    --output ubuntu-server.ova \
    --vmdk all

# Export en format OVF 0.9 (ancienne version)
VBoxManage export "Ubuntu-Server" \
    --output ubuntu-server.ova \
    --legacy09

# Export en format OVF 1.0
VBoxManage export "Ubuntu-Server" \
    --output ubuntu-server.ova \
    --ovf10

# Export en format OVF 2.0
VBoxManage export "Ubuntu-Server" \
    --output ubuntu-server.ova \
    --ovf20
```

> [!tip] Compatibilité Utilisez `--ovf10` pour une compatibilité maximale avec d'autres hyperviseurs. OVF 2.0 offre plus de fonctionnalités mais est moins supporté.

#### Exporter plusieurs VMs en une appliance

```bash
VBoxManage export "WebServer" "DatabaseServer" \
    --output lamp-stack.ova \
    --description "Stack LAMP complète"
```

> [!example] Cas d'usage Créer des appliances multi-VM (ex: serveur web + base de données) pour des déploiements complets.

#### Manifeste et vérification d'intégrité

```bash
VBoxManage export "Ubuntu-Server" \
    --output ubuntu-server.ova \
    --manifest
```

> [!info] Fichier manifeste Génère un fichier .mf contenant les checksums SHA-256 de tous les fichiers, permettant de vérifier l'intégrité après transfert.

### Importer une appliance (`import`)

#### Syntaxe de base

```bash
VBoxManage import <fichier.ova|fichier.ovf> [options]
```

#### Import simple

```bash
VBoxManage import ubuntu-server.ova
```

#### Afficher les informations avant import (dry-run)

```bash
VBoxManage import ubuntu-server.ova --dry-run
```

**Sortie typique :**

```
Interpreting /home/user/ubuntu-server.ova...
OK.
Virtual system 0:
 0: Suggested OS type: "Ubuntu_64"
    (change with "--vsys 0 --ostype <type>"; use "list ostypes" to list all possible values)
 1: Suggested VM name "Ubuntu-Server"
    (change with "--vsys 0 --vmname <name>")
 2: Number of CPUs: 2
    (change with "--vsys 0 --cpus <n>")
 3: Guest memory: 2048 MB
    (change with "--vsys 0 --memory <MB>")
 4: Network adapter: orig NAT, config 3, extra slot=0;type=NAT
```

> [!tip] Planification Utilisez toujours `--dry-run` pour voir les paramètres par défaut avant l'import réel.

### Options d'import avancées

#### Modifier les paramètres lors de l'import

```bash
VBoxManage import ubuntu-server.ova \
    --vsys 0 \
    --vmname "Ubuntu-Production" \
    --cpus 4 \
    --memory 4096 \
    --basefolder "/mnt/vms" \
    --unit 4 --disk "/mnt/storage/ubuntu-disk.vdi"
```

> [!info] Paramètre `--vsys` `--vsys 0` désigne le premier système virtuel dans l'appliance (commence à 0). Nécessaire pour modifier les paramètres.

#### Tableau des options de modification

|Option|Description|Exemple|
|---|---|---|
|`--vmname`|Changer le nom de la VM|`--vmname "MaVM"`|
|`--basefolder`|Dossier de destination|`--basefolder "/mnt/vms"`|
|`--memory`|RAM en MB|`--memory 4096`|
|`--cpus`|Nombre de CPUs|`--cpus 4`|
|`--description`|Description|`--description "VM de test"`|
|`--eula accept`|Accepter la licence|`--eula accept`|
|`--unit X --disk`|Remplacer un disque|`--unit 4 --disk "/path/to/disk.vdi"`|
|`--unit X --ignore`|Ignorer un périphérique|`--unit 5 --ignore`|

#### Import sans enregistrement automatique

```bash
VBoxManage import ubuntu-server.ova --dry-run --options keepnatmacs
```

Options disponibles :

- `keepallmacs` : Conserver toutes les adresses MAC
- `keepnatmacs` : Conserver les MAC des interfaces NAT
- `importtovdi` : Convertir tous les disques en VDI

### Cas d'usage pratiques

#### Créer une appliance distribuable

```bash
#!/bin/bash
VM_NAME="Ubuntu-Server-Template"
OUTPUT_FILE="ubuntu-server-v1.0.ova"

# 1. Nettoyer la VM (supprimer logs, historique, etc.)
# ... commandes de nettoyage ...

# 2. Exporter avec métadonnées
VBoxManage export "$VM_NAME" \
    --output "$OUTPUT_FILE" \
    --product "Ubuntu Server Template" \
    --version "1.0" \
    --vendor "Votre Entreprise" \
    --vendorurl "https://example.com" \
    --description "Ubuntu Server 22.04 préconfiguré avec LAMP" \
    --manifest \
    --ovf10

# 3. Générer un checksum pour la distribution
sha256sum "$OUTPUT_FILE" > "${OUTPUT_FILE}.sha256"

echo "Appliance créée: $OUTPUT_FILE"
```

#### Import automatisé avec configuration

```bash
#!/bin/bash
OVA_FILE="$1"
VM_NAME="$2"
RAM_MB="${3:-2048}"
CPUS="${4:-2}"

echo "Import de $OVA_FILE..."

# Dry-run pour vérifier
VBoxManage import "$OVA_FILE" --dry-run

# Import réel avec configuration
VBoxManage import "$OVA_FILE" \
    --vsys 0 \
    --vmname "$VM_NAME" \
    --memory "$RAM_MB" \
    --cpus "$CPUS"

echo "VM $VM_NAME importée avec succès"
echo "RAM: ${RAM_MB}MB, CPUs: $CPUS"
```

#### Déploiement multiple d'une appliance

```bash
#!/bin/bash
OVA_FILE="ubuntu-server.ova"
BASE_NAME="WebServer"
NUM_INSTANCES=3

for i in $(seq 1 $NUM_INSTANCES); do
    VM_NAME="${BASE_NAME}-${i}"
    
    echo "Déploiement de $VM_NAME..."
    
    VBoxManage import "$OVA_FILE" \
        --vsys 0 \
        --vmname "$VM_NAME" \
        --basefolder "/mnt/vms/cluster"
    
    # Configuration post-import
    VBoxManage modifyvm "$VM_NAME" \
        --nic1 bridged \
        --bridgeadapter1 "eth0"
    
    echo "$VM_NAME déployé"
done
```

#### Migration entre hôtes VirtualBox

```bash
#!/bin/bash
# Sur l'hôte source
VM_NAME="Production-Server"

echo "Export de la VM..."
VBoxManage export "$VM_NAME" \
    --output "/tmp/${VM_NAME}.ova" \
    --manifest

echo "Transférez /tmp/${VM_NAME}.ova vers le nouvel hôte"
echo "Puis exécutez sur le nouvel hôte:"
echo "VBoxManage import ${VM_NAME}.ova"
```

### Vérification d'intégrité

#### Vérifier un manifeste

```bash
# Le fichier .mf contient les checksums
# VirtualBox vérifie automatiquement lors de l'import

# Vérification manuelle
sha256sum -c fichier.mf
```

#### Vérifier l'intégrité d'une OVA

```bash
# Lister le contenu d'une OVA (c'est un TAR)
tar -tvf ubuntu-server.ova

# Extraire une OVA
tar -xvf ubuntu-server.ova

# Cela crée les fichiers .ovf, .vmdk, .mf
```

### Format OVF détaillé

#### Structure d'un export OVF

```
ubuntu-server/
├── ubuntu-server.ovf          # Descripteur XML
├── ubuntu-server.mf            # Manifeste (checksums)
├── ubuntu-server-disk001.vmdk  # Disque virtuel
└── ubuntu-server-disk002.vmdk  # Autre disque (si applicable)
```

#### Contenu du fichier .ovf (extrait)

```xml
<?xml version="1.0"?>
<Envelope>
  <References>
    <File ovf:id="file1" ovf:href="ubuntu-server-disk001.vmdk"/>
  </References>
  <DiskSection>
    <Disk ovf:capacity="21474836480" 
          ovf:diskId="vmdisk1" 
          ovf:fileRef="file1"/>
  </DiskSection>
  <VirtualSystem ovf:id="Ubuntu-Server">
    <Name>Ubuntu-Server</Name>
    <Info>Ubuntu Server 22.04</Info>
    <OperatingSystemSection ovf:id="96">
      <Info>Ubuntu_64</Info>
    </OperatingSystemSection>
    <VirtualHardwareSection>
      <Item>
        <Caption>2 virtual CPU</Caption>
        <ResourceType>3</ResourceType>
        <VirtualQuantity>2</VirtualQuantity>
      </Item>
      <Item>
        <Caption>2048 MB memory</Caption>
        <ResourceType>4</ResourceType>
        <VirtualQuantity>2048</VirtualQuantity>
      </Item>
    </VirtualHardwareSection>
  </VirtualSystem>
</Envelope>
```

> [!info] Format XML Le fichier OVF est du XML lisible et modifiable (mais attention à ne pas corrompre la structure).

### Conversion entre formats

#### OVF vers OVA

```bash
# Méthode 1: Avec VBoxManage
VBoxManage import mon-fichier.ovf
VBoxManage export "MaVM" --output nouveau-fichier.ova

# Méthode 2: Avec tar (manuel)
tar -cvf nouveau-fichier.ova mon-fichier.ovf *.vmdk *.mf
```

#### OVA vers OVF

```bash
# Extraire l'archive TAR
tar -xvf mon-fichier.ova

# Les fichiers .ovf sont maintenant disponibles
```

### Compatibilité avec d'autres hyperviseurs

#### Export pour VMware

```bash
VBoxManage export "Ubuntu-Server" \
    --output ubuntu-server.ova \
    --vmdk all \
    --ovf10
```

> [!tip] Format VMDK VMware préfère le format VMDK pour les disques virtuels. L'option `--vmdk all` convertit automatiquement.

#### Import depuis VMware

```bash
# VMware exporte généralement en OVF
VBoxManage import vmware-export.ovf

# Ou convertir un VMDK VMware
VBoxManage clonehd source.vmdk target.vdi --format VDI
```

### Optimisation des exports

#### Compacter les disques avant export

```bash
# 1. Dans la VM invitée (Linux)
sudo dd if=/dev/zero of=/zerofile bs=1M
sudo rm /zerofile

# 2. Sur l'hôte
VBoxManage modifymedium disk "/path/to/disk.vdi" --compact

# 3. Export
VBoxManage export "Ubuntu-Server" --output ubuntu-server.ova
```

> [!tip] Réduction de taille Cette technique peut réduire significativement la taille de l'OVA en éliminant l'espace vide fragmenté.

#### Export sans snapshots

```bash
# Les exports n'incluent jamais les snapshots
# Seul l'état actuel est exporté

# Pour exporter depuis un snapshot spécifique:
# 1. Cloner depuis le snapshot
VBoxManage clonevm "Ubuntu-Server" \
    --snapshot "Clean-Install" \
    --name "Ubuntu-Server-Clean" \
    --register

# 2. Exporter le clone
VBoxManage export "Ubuntu-Server-Clean" --output ubuntu-clean.ova

# 3. Supprimer le clone
VBoxManage unregistervm "Ubuntu-Server-Clean" --delete
```

### Pièges courants

> [!warning] Chemins absolus dans OVF Les chemins de disques dans les fichiers OVF peuvent être absolus. Lors de l'import, VirtualBox les adapte automatiquement, mais des problèmes peuvent survenir avec des OVF créés manuellement.

> [!warning] Taille des exports Les exports OVA peuvent être très volumineux (plusieurs Go). Assurez-vous d'avoir suffisamment d'espace disque.

> [!warning] Métadonnées et licences Si vous distribuez une appliance, incluez toujours les informations de licence appropriées avec `--eulafile`.

> [!warning] Compatibilité OVF 2.0 OVF 2.0 n'est pas supporté par tous les hyperviseurs. Préférez OVF 1.0 (`--ovf10`) pour une compatibilité maximale.

> [!warning] Réseaux lors de l'import Les configurations réseau (notamment les réseaux Host-Only) peuvent ne pas exister sur l'hôte de destination. Vérifiez et adaptez après import.

### Script complet de migration

```bash
#!/bin/bash
# Script de migration complète d'une VM

set -e  # Arrêt en cas d'erreur

SOURCE_VM="$1"
DEST_HOST="$2"
DEST_USER="${3:-$USER}"

if [ -z "$SOURCE_VM" ] || [ -z "$DEST_HOST" ]; then
    echo "Usage: $0 <vm-name> <destination-host> [user]"
    exit 1
fi

EXPORT_FILE="/tmp/${SOURCE_VM}.ova"

echo "=== Migration de $SOURCE_VM vers $DEST_HOST ==="

# 1. Vérifier l'état de la VM
echo "Vérification de l'état..."
STATE=$(VBoxManage showvminfo "$SOURCE_VM" --machinereadable | grep "^VMState=" | cut -d'"' -f2)

if [ "$STATE" != "poweroff" ]; then
    echo "Arrêt de la VM..."
    VBoxManage controlvm "$SOURCE_VM" acpipowerbutton
    sleep 30
fi

# 2. Compacter le disque
echo "Compactage du disque..."
DISK=$(VBoxManage showvminfo "$SOURCE_VM" --machinereadable | grep "^SATA-0-0" | cut -d'"' -f4)
if [ -n "$DISK" ]; then
    VBoxManage modifymedium disk "$DISK" --compact
fi

# 3. Export
echo "Export en cours..."
VBoxManage export "$SOURCE_VM" \
    --output "$EXPORT_FILE" \
    --manifest \
    --ovf10

# 4. Vérifier le manifeste
echo "Vérification de l'intégrité..."
if [ ! -f "$EXPORT_FILE" ]; then
    echo "Erreur: Export échoué"
    exit 1
fi

# 5. Transfert SCP
echo "Transfert vers $DEST_HOST..."
scp "$EXPORT_FILE" "${DEST_USER}@${DEST_HOST}:/tmp/"

# 6. Import sur l'hôte distant
echo "Import sur l'hôte distant..."
ssh "${DEST_USER}@${DEST_HOST}" "VBoxManage import /tmp/$(basename $EXPORT_FILE)"

# 7. Nettoyage
echo "Nettoyage..."
rm "$EXPORT_FILE"
ssh "${DEST_USER}@${DEST_HOST}" "rm /tmp/$(basename $EXPORT_FILE)"

echo "=== Migration terminée avec succès ==="
```

---

## 🎯 Récapitulatif

### Commandes essentielles à retenir

|Opération|Commande|Usage principal|
|---|---|---|
|**Lister**|`VBoxManage list vms`|Vue d'ensemble des VMs|
|**Détails**|`VBoxManage showvminfo <vm>`|Diagnostic et configuration|
|**Cloner**|`VBoxManage clonevm <vm> --name <new>`|Duplication rapide|
|**Supprimer**|`VBoxManage unregistervm <vm> --delete`|Nettoyage complet|
|**Exporter**|`VBoxManage export <vm> --output <file.ova>`|Distribution/backup|
|**Importer**|`VBoxManage import <file.ova>`|Déploiement|

### Workflows recommandés

#### 1. Création de templates réutilisables

```
1. Créer et configurer une VM de base
2. Installer et configurer le système
3. Nettoyer (historique, logs, cache)
4. Créer un snapshot "Clean"
5. Exporter en OVA avec métadonnées
6. Créer des clones liés pour usage quotidien
```

#### 2. Déploiement d'environnements multiples

```
1. Importer l'appliance de base
2. Cloner avec modifications (RAM, CPU, réseau)
3. Démarrer et personnaliser chaque instance
4. Documenter la configuration
```

#### 3. Migration vers un nouvel hôte

```
1. Compacter les disques
2. Exporter en OVA avec manifeste
3. Vérifier l'intégrité (checksums)
4. Transférer vers le nouvel hôte
5. Importer et adapter la configuration réseau
6. Tester avant de supprimer l'original
```

### Bonnes pratiques

> [!tip] Organisation
> 
> - Utilisez des conventions de nommage claires (ex: `Projet-Environment-Version`)
> - Groupez les VMs liées avec `--groups`
> - Documentez les configurations dans les descriptions

> [!tip] Sauvegardes
> 
> - Exportez régulièrement les VMs critiques en OVA
> - Stockez les exports sur un support externe
> - Incluez toujours `--manifest` pour vérifier l'intégrité

> [!tip] Performance
> 
> - Utilisez des clones liés pour économiser l'espace disque
> - Compactez les disques régulièrement
> - Placez les VMs sur des disques SSD pour de meilleures performances

> [!tip] Sécurité
> 
> - Ne distribuez jamais d'OVA contenant des données sensibles
> - Nettoyez l'historique et les logs avant export
> - Utilisez des checksums pour vérifier l'intégrité des fichiers

---

## 📚 Synthèse des options importantes

### Options de `list`

```bash
vms              # Toutes les VMs
runningvms       # VMs en cours d'exécution
ostypes          # Types d'OS supportés
hdds             # Disques virtuels
groups           # Groupes de VMs
hostinfo         # Info système de l'hôte
```

### Options de `clonevm`

```bash
--name           # Nom du clone (obligatoire)
--register       # Enregistrer automatiquement
--mode           # machine | machinechildren | all
--snapshot       # Cloner depuis un snapshot
--options link   # Clone lié (économise l'espace)
--basefolder     # Destination personnalisée
```

### Options d'`export`

```bash
--output         # Fichier de sortie (.ova ou .ovf)
--manifest       # Ajouter les checksums
--ovf10/20       # Version du format OVF
--vmdk all       # Convertir en VMDK
--product        # Métadonnées produit
--description    # Description de l'appliance
```

### Options d'`import`

```bash
--dry-run        # Voir sans importer
--vsys 0         # Sélectionner le système virtuel
--vmname         # Changer le nom
--memory         # Modifier la RAM
--cpus           # Modifier les CPUs
--basefolder     # Destination personnalisée
```

---

_Ce cours couvre l'essentiel de la gestion du cycle de vie des VMs avec VirtualBox CLI. Maîtriser ces commandes vous permettra d'automatiser efficacement vos workflows de virtualisation._