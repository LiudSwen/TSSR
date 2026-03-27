

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

## 🎯 Introduction au scripting VirtualBox {#introduction}

> [!info] Pourquoi scripter VirtualBox ? Le scripting permet d'automatiser la création, la configuration et la gestion de machines virtuelles. Au lieu de répéter manuellement les mêmes commandes, un script peut déployer des environnements complets en quelques secondes.

### Avantages du scripting

- **Reproductibilité** : Créez des VMs identiques à chaque fois
- **Gain de temps** : Automatisez les tâches répétitives
- **Documentation** : Le script devient une documentation vivante
- **Gestion à grande échelle** : Déployez plusieurs VMs simultanément

### Choix du langage

|Langage|Système|Avantages|
|---|---|---|
|Bash|Linux/macOS|Natif, puissant, intégration système|
|PowerShell|Windows|Moderne, orienté objet, gestion erreurs avancée|

---

## 🏗️ Scripts de création automatique de VMs {#création-automatique}

### Structure de base d'un script Bash

```bash
#!/bin/bash
# Script de création d'une VM VirtualBox

# Configuration de la VM
VM_NAME="MaVM"
VM_OS_TYPE="Ubuntu_64"
VM_RAM=2048
VM_VRAM=128
VM_CPUS=2
VM_DISK_SIZE=20480

# Création de la VM
VBoxManage createvm --name "$VM_NAME" --ostype "$VM_OS_TYPE" --register

# Configuration matérielle
VBoxManage modifyvm "$VM_NAME" \
    --memory "$VM_RAM" \
    --vram "$VM_VRAM" \
    --cpus "$VM_CPUS" \
    --boot1 dvd \
    --boot2 disk \
    --boot3 none \
    --boot4 none

# Création du disque dur
VBoxManage createhd --filename "$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi" \
    --size "$VM_DISK_SIZE" \
    --format VDI

# Ajout d'un contrôleur SATA
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" \
    --add sata --controller IntelAhci

# Attachement du disque
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" \
    --port 0 --device 0 --type hdd \
    --medium "$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"

echo "✅ VM $VM_NAME créée avec succès"
```

> [!tip] Astuce - Backslash pour la lisibilité Le caractère `\` permet de continuer une commande sur plusieurs lignes, rendant le script plus lisible. Assurez-vous qu'aucun espace ne suit le backslash.

### Structure équivalente en PowerShell

```powershell
# Script de création d'une VM VirtualBox

# Configuration de la VM
$VM_NAME = "MaVM"
$VM_OS_TYPE = "Ubuntu_64"
$VM_RAM = 2048
$VM_VRAM = 128
$VM_CPUS = 2
$VM_DISK_SIZE = 20480

# Création de la VM
& VBoxManage createvm --name $VM_NAME --ostype $VM_OS_TYPE --register

# Configuration matérielle
& VBoxManage modifyvm $VM_NAME `
    --memory $VM_RAM `
    --vram $VM_VRAM `
    --cpus $VM_CPUS `
    --boot1 dvd `
    --boot2 disk `
    --boot3 none `
    --boot4 none

# Création du disque dur
$VmPath = "$env:USERPROFILE\VirtualBox VMs\$VM_NAME"
& VBoxManage createhd --filename "$VmPath\$VM_NAME.vdi" `
    --size $VM_DISK_SIZE `
    --format VDI

# Ajout d'un contrôleur SATA
& VBoxManage storagectl $VM_NAME --name "SATA Controller" `
    --add sata --controller IntelAhci

# Attachement du disque
& VBoxManage storageattach $VM_NAME --storagectl "SATA Controller" `
    --port 0 --device 0 --type hdd `
    --medium "$VmPath\$VM_NAME.vdi"

Write-Host "✅ VM $VM_NAME créée avec succès" -ForegroundColor Green
```

> [!warning] Attention - Opérateur d'appel PowerShell En PowerShell, utilisez `&` devant `VBoxManage` pour l'exécuter correctement. Le backtick `` ` `` sert de caractère de continuation de ligne (équivalent du `\` en Bash).

### Script avancé avec fonctions

```bash
#!/bin/bash

# Fonction de création de VM
create_vm() {
    local vm_name=$1
    local os_type=$2
    local ram=$3
    local disk_size=$4
    
    echo "🔧 Création de la VM : $vm_name"
    
    # Création et enregistrement
    VBoxManage createvm --name "$vm_name" --ostype "$os_type" --register
    
    # Configuration
    VBoxManage modifyvm "$vm_name" \
        --memory "$ram" \
        --vram 128 \
        --cpus 2 \
        --nic1 nat
    
    # Disque dur
    local vm_path="$HOME/VirtualBox VMs/$vm_name"
    VBoxManage createhd --filename "$vm_path/$vm_name.vdi" \
        --size "$disk_size" --format VDI
    
    # Contrôleur et attachement
    VBoxManage storagectl "$vm_name" --name "SATA" --add sata
    VBoxManage storageattach "$vm_name" --storagectl "SATA" \
        --port 0 --device 0 --type hdd --medium "$vm_path/$vm_name.vdi"
    
    echo "✅ VM $vm_name créée"
}

# Utilisation de la fonction
create_vm "DevVM" "Ubuntu_64" 2048 20480
create_vm "TestVM" "Ubuntu_64" 4096 30720
```

> [!example] Exemple - Fonctions réutilisables Les fonctions permettent de réutiliser le même code avec différents paramètres. Cela évite les duplications et rend le script plus maintenable.

---

## 🔄 Boucles et conditions {#boucles-conditions}

### Boucles for en Bash

```bash
#!/bin/bash

# Créer plusieurs VMs avec une boucle
for i in {1..5}; do
    vm_name="VM-${i}"
    echo "Création de $vm_name"
    
    VBoxManage createvm --name "$vm_name" --ostype "Ubuntu_64" --register
    VBoxManage modifyvm "$vm_name" --memory 1024 --vram 128
    
    echo "✅ $vm_name créée"
done
```

### Boucles avec liste de valeurs

```bash
#!/bin/bash

# Liste de VMs à créer
vm_list=("Dev" "Test" "Prod")

for vm in "${vm_list[@]}"; do
    echo "Configuration de VM-$vm"
    
    VBoxManage createvm --name "VM-$vm" --ostype "Ubuntu_64" --register
    
    # Configuration spécifique selon le nom
    if [ "$vm" = "Prod" ]; then
        VBoxManage modifyvm "VM-$vm" --memory 4096 --cpus 4
    else
        VBoxManage modifyvm "VM-$vm" --memory 2048 --cpus 2
    fi
done
```

### Conditions if-else en Bash

```bash
#!/bin/bash

VM_NAME="MaVM"

# Vérifier si la VM existe déjà
if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
    echo "⚠️  La VM $VM_NAME existe déjà"
    echo "Voulez-vous la supprimer ? (o/n)"
    read -r response
    
    if [ "$response" = "o" ]; then
        VBoxManage unregistervm "$VM_NAME" --delete
        echo "🗑️  VM supprimée"
    else
        echo "❌ Opération annulée"
        exit 1
    fi
fi

echo "✅ Création de la nouvelle VM"
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register
```

> [!tip] Astuce - Test de condition `grep -q` permet de tester silencieusement la présence d'une chaîne. Le code de retour ($?) sera 0 si trouvé, 1 sinon.

### Boucles en PowerShell

```powershell
# Boucle ForEach-Object
1..5 | ForEach-Object {
    $vmName = "VM-$_"
    Write-Host "Création de $vmName"
    
    & VBoxManage createvm --name $vmName --ostype "Ubuntu_64" --register
    & VBoxManage modifyvm $vmName --memory 1024 --vram 128
}

# Boucle foreach avec tableau
$vmList = @("Dev", "Test", "Prod")

foreach ($vm in $vmList) {
    Write-Host "Configuration de VM-$vm"
    
    & VBoxManage createvm --name "VM-$vm" --ostype "Ubuntu_64" --register
    
    if ($vm -eq "Prod") {
        & VBoxManage modifyvm "VM-$vm" --memory 4096 --cpus 4
    } else {
        & VBoxManage modifyvm "VM-$vm" --memory 2048 --cpus 2
    }
}
```

### Conditions if-else en PowerShell

```powershell
$VM_NAME = "MaVM"

# Vérifier si la VM existe
$vmExists = & VBoxManage list vms | Select-String -Pattern "^""$VM_NAME"""

if ($vmExists) {
    Write-Host "⚠️  La VM $VM_NAME existe déjà" -ForegroundColor Yellow
    $response = Read-Host "Voulez-vous la supprimer ? (o/n)"
    
    if ($response -eq "o") {
        & VBoxManage unregistervm $VM_NAME --delete
        Write-Host "🗑️  VM supprimée" -ForegroundColor Red
    } else {
        Write-Host "❌ Opération annulée" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Création de la nouvelle VM" -ForegroundColor Green
& VBoxManage createvm --name $VM_NAME --ostype "Ubuntu_64" --register
```

### Boucle while

```bash
#!/bin/bash

# Attendre que la VM démarre complètement
VM_NAME="MaVM"
MAX_WAIT=60
counter=0

echo "⏳ Démarrage de la VM..."
VBoxManage startvm "$VM_NAME" --type headless

while [ $counter -lt $MAX_WAIT ]; do
    state=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "VMState=" | cut -d'"' -f2)
    
    if [ "$state" = "running" ]; then
        echo "✅ VM démarrée avec succès"
        break
    fi
    
    echo "Attente... ($counter/$MAX_WAIT secondes)"
    sleep 1
    ((counter++))
done

if [ $counter -eq $MAX_WAIT ]; then
    echo "❌ Timeout : la VM n'a pas démarré"
    exit 1
fi
```

---

## ⚠️ Gestion des erreurs et codes retour {#gestion-erreurs}

### Codes de retour en Bash

> [!info] Comprendre les codes de retour Chaque commande Unix/Linux retourne un code : 0 pour succès, 1-255 pour erreur. La variable `$?` contient le code de retour de la dernière commande exécutée.

```bash
#!/bin/bash

VM_NAME="TestVM"

# Exécuter une commande et vérifier le code retour
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register

if [ $? -eq 0 ]; then
    echo "✅ VM créée avec succès"
else
    echo "❌ Erreur lors de la création de la VM"
    exit 1
fi
```

### Mode strict en Bash

```bash
#!/bin/bash

# Mode strict : arrêt immédiat en cas d'erreur
set -e  # Exit si une commande échoue
set -u  # Exit si une variable non définie est utilisée
set -o pipefail  # Exit si une commande dans un pipe échoue

VM_NAME="StrictVM"

echo "Création de la VM en mode strict"
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register

# Si cette ligne est atteinte, tout s'est bien passé
echo "✅ Toutes les commandes ont réussi"
```

> [!warning] Attention - Mode strict Avec `set -e`, le script s'arrête dès qu'une commande échoue. C'est utile pour éviter les effets de cascade, mais peut être trop strict dans certains cas. Utilisez `set +e` temporairement pour désactiver ce comportement.

### Gestion d'erreur avancée en Bash

```bash
#!/bin/bash

# Fonction de gestion d'erreur
handle_error() {
    local exit_code=$1
    local line_number=$2
    local command=$3
    
    echo "❌ ERREUR à la ligne $line_number"
    echo "   Commande : $command"
    echo "   Code de sortie : $exit_code"
    
    # Nettoyage éventuel
    cleanup
    
    exit "$exit_code"
}

# Fonction de nettoyage
cleanup() {
    echo "🧹 Nettoyage en cours..."
    # Supprimer les VMs temporaires, etc.
}

# Trap pour capturer les erreurs
trap 'handle_error $? $LINENO "$BASH_COMMAND"' ERR

# Script principal
VM_NAME="ErrorHandlingVM"

echo "Début du script"
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register
VBoxManage modifyvm "$VM_NAME" --memory 2048

echo "✅ Script terminé avec succès"
```

> [!tip] Astuce - Trap ERR La commande `trap` permet d'intercepter les erreurs et d'exécuter une fonction de nettoyage. C'est particulièrement utile pour libérer des ressources ou supprimer des fichiers temporaires.

### Gestion d'erreur en PowerShell

```powershell
# Configuration stricte
$ErrorActionPreference = "Stop"  # Arrêt en cas d'erreur

$VM_NAME = "TestVM"

try {
    Write-Host "Création de la VM..."
    & VBoxManage createvm --name $VM_NAME --ostype "Ubuntu_64" --register
    
    if ($LASTEXITCODE -ne 0) {
        throw "Échec de la création de la VM (code: $LASTEXITCODE)"
    }
    
    Write-Host "Configuration de la VM..."
    & VBoxManage modifyvm $VM_NAME --memory 2048
    
    if ($LASTEXITCODE -ne 0) {
        throw "Échec de la configuration de la VM (code: $LASTEXITCODE)"
    }
    
    Write-Host "✅ VM créée avec succès" -ForegroundColor Green
    
} catch {
    Write-Host "❌ ERREUR : $_" -ForegroundColor Red
    
    # Nettoyage en cas d'erreur
    Write-Host "🧹 Nettoyage..." -ForegroundColor Yellow
    & VBoxManage unregistervm $VM_NAME --delete 2>$null
    
    exit 1
    
} finally {
    Write-Host "Fin du script"
}
```

> [!example] Exemple - Try-Catch-Finally PowerShell offre une gestion d'erreur structurée. Le bloc `finally` s'exécute toujours, que l'opération réussisse ou échoue, idéal pour le nettoyage.

### Validation et pré-vérifications

```bash
#!/bin/bash

# Fonction de validation
validate_environment() {
    echo "🔍 Validation de l'environnement..."
    
    # Vérifier que VBoxManage est disponible
    if ! command -v VBoxManage &> /dev/null; then
        echo "❌ VBoxManage n'est pas installé"
        exit 1
    fi
    
    # Vérifier l'espace disque disponible (au moins 20 GB)
    available_space=$(df -BG "$HOME" | tail -1 | awk '{print $4}' | sed 's/G//')
    if [ "$available_space" -lt 20 ]; then
        echo "❌ Espace disque insuffisant : ${available_space}GB (minimum 20GB requis)"
        exit 1
    fi
    
    # Vérifier que la VM n'existe pas déjà
    if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
        echo "❌ La VM $VM_NAME existe déjà"
        exit 1
    fi
    
    echo "✅ Validation réussie"
}

VM_NAME="ValidatedVM"

validate_environment
# Le reste du script...
```

---

## 📦 Variables et paramètres {#variables-paramètres}

### Variables d'environnement en Bash

```bash
#!/bin/bash

# Variables de configuration globales
export VBOX_VM_DIR="$HOME/VirtualBox VMs"
export VBOX_ISO_DIR="$HOME/ISOs"
export DEFAULT_RAM=2048
export DEFAULT_CPUS=2

# Utilisation dans le script
VM_NAME="EnvVM"
vm_path="$VBOX_VM_DIR/$VM_NAME"

echo "📁 Répertoire des VMs : $VBOX_VM_DIR"
echo "💿 Répertoire des ISOs : $VBOX_ISO_DIR"

VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register
VBoxManage modifyvm "$VM_NAME" --memory "$DEFAULT_RAM" --cpus "$DEFAULT_CPUS"
```

### Paramètres de ligne de commande en Bash

```bash
#!/bin/bash

# Script avec paramètres : ./script.sh nom_vm type_os ram cpus

# Vérifier le nombre d'arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <nom_vm> <type_os> [ram] [cpus]"
    echo "Exemple: $0 MaVM Ubuntu_64 2048 2"
    exit 1
fi

# Récupération des paramètres
VM_NAME=$1
OS_TYPE=$2
RAM=${3:-2048}        # Valeur par défaut : 2048
CPUS=${4:-2}          # Valeur par défaut : 2

echo "🔧 Configuration :"
echo "  Nom : $VM_NAME"
echo "  OS : $OS_TYPE"
echo "  RAM : ${RAM}MB"
echo "  CPUs : $CPUS"

# Création de la VM
VBoxManage createvm --name "$VM_NAME" --ostype "$OS_TYPE" --register
VBoxManage modifyvm "$VM_NAME" --memory "$RAM" --cpus "$CPUS"

echo "✅ VM créée avec les paramètres fournis"
```

> [!tip] Astuce - Valeurs par défaut La syntaxe `${variable:-valeur_defaut}` permet de définir une valeur par défaut si la variable est vide ou non définie. Très utile pour les paramètres optionnels.

### Options avec getopts en Bash

```bash
#!/bin/bash

# Valeurs par défaut
VM_NAME=""
OS_TYPE="Ubuntu_64"
RAM=2048
CPUS=2
VERBOSE=false

# Fonction d'aide
show_help() {
    cat << EOF
Usage: $0 -n nom_vm [-o os_type] [-m ram] [-c cpus] [-v]

Options:
    -n    Nom de la VM (obligatoire)
    -o    Type d'OS (défaut: Ubuntu_64)
    -m    RAM en MB (défaut: 2048)
    -c    Nombre de CPUs (défaut: 2)
    -v    Mode verbeux
    -h    Afficher cette aide

Exemple:
    $0 -n MaVM -o Ubuntu_64 -m 4096 -c 4 -v
EOF
}

# Parser les options
while getopts "n:o:m:c:vh" opt; do
    case $opt in
        n) VM_NAME="$OPTARG" ;;
        o) OS_TYPE="$OPTARG" ;;
        m) RAM="$OPTARG" ;;
        c) CPUS="$OPTARG" ;;
        v) VERBOSE=true ;;
        h) show_help; exit 0 ;;
        \?) echo "Option invalide: -$OPTARG" >&2; show_help; exit 1 ;;
    esac
done

# Vérifier que le nom est fourni
if [ -z "$VM_NAME" ]; then
    echo "❌ Le nom de la VM est obligatoire"
    show_help
    exit 1
fi

# Mode verbeux
if [ "$VERBOSE" = true ]; then
    echo "🔍 Mode verbeux activé"
    echo "Configuration : VM=$VM_NAME, OS=$OS_TYPE, RAM=${RAM}MB, CPUs=$CPUS"
fi

# Création de la VM
echo "Création de $VM_NAME..."
VBoxManage createvm --name "$VM_NAME" --ostype "$OS_TYPE" --register
VBoxManage modifyvm "$VM_NAME" --memory "$RAM" --cpus "$CPUS"

echo "✅ VM créée avec succès"
```

> [!example] Exemple - getopts `getopts` est l'outil standard pour parser les options de ligne de commande en Bash. Les deux-points après une lettre indiquent que l'option attend un argument.

### Variables et paramètres en PowerShell

```powershell
# Script avec paramètres nommés et validation
param(
    [Parameter(Mandatory=$true, HelpMessage="Nom de la VM")]
    [ValidateNotNullOrEmpty()]
    [string]$VMName,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Ubuntu_64", "Windows10_64", "Debian_64")]
    [string]$OSType = "Ubuntu_64",
    
    [Parameter(Mandatory=$false)]
    [ValidateRange(512, 32768)]
    [int]$RAM = 2048,
    
    [Parameter(Mandatory=$false)]
    [ValidateRange(1, 8)]
    [int]$CPUs = 2,
    
    [switch]$Verbose
)

# Affichage en mode verbeux
if ($Verbose) {
    Write-Host "🔍 Mode verbeux activé" -ForegroundColor Cyan
    Write-Host "Configuration : VM=$VMName, OS=$OSType, RAM=${RAM}MB, CPUs=$CPUs"
}

# Création de la VM
Write-Host "Création de $VMName..."
& VBoxManage createvm --name $VMName --ostype $OSType --register
& VBoxManage modifyvm $VMName --memory $RAM --cpus $CPUs

Write-Host "✅ VM créée avec succès" -ForegroundColor Green
```

> [!info] Validation PowerShell PowerShell offre des attributs de validation puissants : `ValidateNotNullOrEmpty`, `ValidateSet`, `ValidateRange`. Les erreurs sont détectées avant l'exécution du script.

### Fichier de configuration externe

```bash
#!/bin/bash

# config.conf
# VM_NAME="ConfigVM"
# OS_TYPE="Ubuntu_64"
# RAM=4096
# CPUS=4
# DISK_SIZE=50000

# Charger le fichier de configuration
CONFIG_FILE="${1:-config.conf}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Fichier de configuration introuvable : $CONFIG_FILE"
    exit 1
fi

# Sourcer le fichier (exécuter dans le contexte actuel)
source "$CONFIG_FILE"

echo "📄 Configuration chargée depuis $CONFIG_FILE"
echo "  VM : $VM_NAME"
echo "  OS : $OS_TYPE"
echo "  RAM : ${RAM}MB"
echo "  CPUs : $CPUS"

# Utiliser les variables
VBoxManage createvm --name "$VM_NAME" --ostype "$OS_TYPE" --register
VBoxManage modifyvm "$VM_NAME" --memory "$RAM" --cpus "$CPUS"

echo "✅ VM créée selon la configuration"
```

### Tableau associatif pour configuration

```bash
#!/bin/bash

# Déclaration d'un tableau associatif (Bash 4+)
declare -A vm_config=(
    [name]="AssocVM"
    [ostype]="Ubuntu_64"
    [memory]=2048
    [cpus]=2
    [vram]=128
    [disk_size]=20480
)

# Affichage de la configuration
echo "📋 Configuration de la VM :"
for key in "${!vm_config[@]}"; do
    echo "  $key: ${vm_config[$key]}"
done

# Création avec les valeurs du tableau
VBoxManage createvm \
    --name "${vm_config[name]}" \
    --ostype "${vm_config[ostype]}" \
    --register

VBoxManage modifyvm "${vm_config[name]}" \
    --memory "${vm_config[memory]}" \
    --cpus "${vm_config[cpus]}" \
    --vram "${vm_config[vram]}"

echo "✅ VM configurée avec succès"
```

---

## 📝 Logs et traçabilité {#logs-traçabilité}

### Logging basique en Bash

```bash
#!/bin/bash

# Configuration des logs
LOG_FILE="vm_creation_$(date +%Y%m%d_%H%M%S).log"
LOG_DIR="$HOME/vbox_logs"

# Créer le répertoire de logs
mkdir -p "$LOG_DIR"
LOG_PATH="$LOG_DIR/$LOG_FILE"

# Fonction de logging
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_PATH"
}

# Utilisation
log "INFO" "Début du script de création de VM"
log "INFO" "Fichier de log : $LOG_PATH"

VM_NAME="LoggedVM"

log "INFO" "Création de la VM : $VM_NAME"
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register >> "$LOG_PATH" 2>&1

if [ $? -eq 0 ]; then
    log "SUCCESS" "VM créée avec succès"
else
    log "ERROR" "Échec de la création de la VM"
    exit 1
fi

log "INFO" "Configuration de la VM"
VBoxManage modifyvm "$VM_NAME" --memory 2048 --cpus 2 >> "$LOG_PATH" 2>&1

log "INFO" "Script terminé"
```

> [!tip] Astuce - tee La commande `tee` permet d'afficher un message à l'écran tout en l'écrivant dans un fichier. L'option `-a` ajoute au fichier au lieu de l'écraser.

### Niveaux de log et couleurs

```bash
#!/bin/bash

LOG_FILE="vm_script.log"

# Codes de couleur ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Fonction de logging avec couleurs
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    case $level in
        ERROR)   color=$RED ;;
        SUCCESS) color=$GREEN ;;
        WARNING) color=$YELLOW ;;
        INFO)    color=$BLUE ;;
        *)       color=$NC ;;
    esac
    
    # Affichage avec couleur
    echo -e "${color}[$timestamp] [$level] $message${NC}"
    
    # Écriture dans le fichier (sans couleur)
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Utilisation
log "INFO" "Démarrage du script"
log "WARNING" "Vérification de l'espace disque"
log "SUCCESS" "Configuration validée"
log "ERROR" "Échec de connexion"
```

### Redirection complète de sortie

```bash
#!/bin/bash

LOG_FILE="vm_creation_full.log"

# Rediriger toute la sortie standard et d'erreur vers le fichier
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "============================================"
echo "Script de création de VM"
echo "Date : $(date)"
echo "============================================"

VM_NAME="RedirectedVM"

echo "Création de la VM : $VM_NAME"
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register

echo "Configuration de la VM"
VBoxManage modifyvm "$VM_NAME" --memory 2048 --cpus 2

echo "✅ VM créée et configurée"
echo "============================================"
```

> [!info] Redirection exec `exec` permet de rediriger toutes les sorties du script. Combiné avec `tee`, tout s'affiche à l'écran ET s'écrit dans le fichier.

### Logging avancé avec rotation

```bash
#!/bin/bash

LOG_DIR="$HOME/vbox_logs"
LOG_FILE="vm_script.log"
MAX_LOG_SIZE=10485760  # 10 MB en octets
MAX_LOG_FILES=5

# Fonction de rotation des logs
rotate_logs() {
    local log_path="$LOG_DIR/$LOG_FILE"
    
    if [ -f "$log_path" ]; then
        local file_size=$(stat -f%z "$log_path" 2>/dev/null || stat -c%s "$log_path" 2>/dev/null)
        
        if [ "$file_size" -gt "$MAX_LOG_SIZE" ]; then
            echo "🔄 Rotation du fichier de log (taille: $file_size octets)"
            
            # Supprimer le plus ancien
            rm -f "$log_path.$MAX_LOG_FILES"
            
            # Décaler les numéros
            for i in $(seq $((MAX_LOG_FILES - 1)) -1 1); do
                if [ -f "$log_path.$i" ]; then
                    mv "$log_path.$i" "$log_path.$((i + 1))"
                fi
            done
            
            # Archiver le fichier actuel
            mv "$log_path" "$log_path.1"
            gzip "$log_path.1"
        fi
    fi
}

# Fonction de logging
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_path="$LOG_DIR/$LOG_FILE"
    
    mkdir -p "$LOG_DIR"
    rotate_logs
    
    echo "[$timestamp] [$level] $message" >> "$log_path"
}

# Utilisation
log "INFO" "Script démarré"
log "INFO" "Création de la VM"
```

> [!warning] Attention - Compatibilité stat La commande `stat` diffère entre Linux (`-c%s`) et macOS (`-f%z`). Le script utilise une double commande avec `||` pour compatibilité.

### Logging en PowerShell

```powershell
# Configuration des logs
$LogDir = "$env:USERPROFILE\vbox_logs"
$LogFile = "vm_creation_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$LogPath = Join-Path $LogDir $LogFile

# Créer le répertoire
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

# Fonction de logging
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level,
        
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    # Couleur selon le niveau
    $Color = switch ($Level) {
        "INFO"    { "Cyan" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        "SUCCESS" { "Green" }
    }
    
    # Affichage avec couleur
    Write-Host $LogMessage -ForegroundColor $Color
    
    # Écriture dans le fichier
    Add-Content -Path $LogPath -Value $LogMessage
}

# Utilisation
Write-Log -Level "INFO" -Message "Début du script"
Write-Log -Level "INFO" -Message "Fichier de log : $LogPath"

$VM_NAME = "LoggedVM"

Write-Log -Level "INFO" -Message "Création de la VM : $VM_NAME"
& VBoxManage createvm --name $VM_NAME --ostype "Ubuntu_64" --register 2>&1 | 
    Add-Content -Path $LogPath

if ($LASTEXITCODE -eq 0) {
    Write-Log -Level "SUCCESS" -Message "VM créée avec succès"
} else {
    Write-Log -Level "ERROR" -Message "Échec de la création (code: $LASTEXITCODE)"
    exit 1
}

Write-Log -Level "INFO" -Message "Script terminé"
```

### Logging structuré JSON

```bash
#!/bin/bash

LOG_FILE="vm_operations.jsonl"  # JSON Lines format

# Fonction de logging JSON
log_json() {
    local level=$1
    local message=$2
    local vm_name=${3:-""}
    local operation=${4:-""}
    
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Créer l'objet JSON
    local json_log=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "level": "$level",
  "message": "$message",
  "vm_name": "$vm_name",
  "operation": "$operation",
  "script": "$0",
  "user": "$USER",
  "hostname": "$HOSTNAME"
}
EOF
)
    
    echo "$json_log" >> "$LOG_FILE"
}

# Utilisation
log_json "INFO" "Démarrage du script" "" "script_start"

VM_NAME="JsonLogVM"

log_json "INFO" "Création de la VM" "$VM_NAME" "create_vm"
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register

if [ $? -eq 0 ]; then
    log_json "SUCCESS" "VM créée avec succès" "$VM_NAME" "create_vm"
else
    log_json "ERROR" "Échec de la création" "$VM_NAME" "create_vm"
fi

log_json "INFO" "Fin du script" "" "script_end"
```

> [!example] Exemple - JSON Lines Le format JSONL (une ligne JSON par entrée) est idéal pour les logs. Il est facile à parser avec des outils comme `jq` et compatible avec les systèmes de centralisation de logs.

### Analyse de logs avec jq

```bash
#!/bin/bash

# Extraire toutes les erreurs
echo "❌ Erreurs trouvées :"
jq -r 'select(.level == "ERROR") | "\(.timestamp) - \(.message) - VM: \(.vm_name)"' \
    vm_operations.jsonl

# Compter les opérations par type
echo ""
echo "📊 Statistiques par opération :"
jq -r '.operation' vm_operations.jsonl | sort | uniq -c | sort -rn

# VMs créées avec succès
echo ""
echo "✅ VMs créées avec succès :"
jq -r 'select(.level == "SUCCESS" and .operation == "create_vm") | .vm_name' \
    vm_operations.jsonl
```

### Rapport d'exécution

```bash
#!/bin/bash

REPORT_FILE="vm_creation_report_$(date +%Y%m%d_%H%M%S).txt"

# Fonction de génération de rapport
generate_report() {
    local vm_name=$1
    local start_time=$2
    local end_time=$3
    local status=$4
    
    cat >> "$REPORT_FILE" << EOF
╔════════════════════════════════════════════════════════════════╗
║                    RAPPORT DE CRÉATION VM                      ║
╚════════════════════════════════════════════════════════════════╝

📋 Informations générales :
   • Nom de la VM      : $vm_name
   • Date de création  : $(date)
   • Utilisateur       : $USER
   • Hôte              : $HOSTNAME

⏱️  Temps d'exécution :
   • Début             : $start_time
   • Fin               : $end_time
   • Durée             : $((end_time - start_time)) secondes

📊 Statut :
   • Résultat          : $status

🔧 Configuration de la VM :
EOF

    # Ajouter les informations de la VM
    VBoxManage showvminfo "$vm_name" --machinereadable >> "$REPORT_FILE" 2>&1
    
    echo "" >> "$REPORT_FILE"
    echo "═══════════════════════════════════════════════════════════════" >> "$REPORT_FILE"
}

# Utilisation
VM_NAME="ReportVM"
START_TIME=$(date +%s)

log "INFO" "Début de création"

VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register
VBoxManage modifyvm "$VM_NAME" --memory 2048 --cpus 2

END_TIME=$(date +%s)

if [ $? -eq 0 ]; then
    STATUS="✅ SUCCÈS"
else
    STATUS="❌ ÉCHEC"
fi

generate_report "$VM_NAME" "$START_TIME" "$END_TIME" "$STATUS"

echo "📄 Rapport généré : $REPORT_FILE"
```

### Dashboard de surveillance (script de monitoring)

```bash
#!/bin/bash

# Script de monitoring en temps réel
monitor_vms() {
    while true; do
        clear
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              DASHBOARD VIRTUALBOX - $(date +%H:%M:%S)              ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        
        # Liste des VMs en cours d'exécution
        echo "🟢 VMs en cours d'exécution :"
        VBoxManage list runningvms | while read -r line; do
            vm_name=$(echo "$line" | cut -d'"' -f2)
            echo "   • $vm_name"
            
            # Obtenir l'utilisation CPU
            cpu=$(VBoxManage showvminfo "$vm_name" --machinereadable | grep "^CPUExecutionCap" | cut -d'=' -f2)
            echo "     CPU Cap: ${cpu}%"
        done
        
        echo ""
        echo "⚪ Total des VMs : $(VBoxManage list vms | wc -l)"
        echo "🟢 VMs actives   : $(VBoxManage list runningvms | wc -l)"
        
        echo ""
        echo "💾 Espace disque :"
        df -h "$HOME/VirtualBox VMs" | tail -1 | awk '{print "   Utilisé: "$3" / Disponible: "$4" ("$5")"}'
        
        echo ""
        echo "Appuyez sur Ctrl+C pour quitter"
        
        sleep 5
    done
}

# Lancer le monitoring
monitor_vms
```

> [!tip] Astuce - Monitoring en temps réel Ce script crée un dashboard qui se rafraîchit toutes les 5 secondes. Utile pour surveiller l'état des VMs pendant des opérations longues.

### Intégration avec syslog (Linux)

```bash
#!/bin/bash

# Fonction de logging vers syslog
log_to_syslog() {
    local level=$1
    local message=$2
    local vm_name=${3:-""}
    
    # Convertir le niveau en priorité syslog
    local priority
    case $level in
        ERROR)   priority="err" ;;
        WARNING) priority="warning" ;;
        INFO)    priority="info" ;;
        SUCCESS) priority="notice" ;;
        *)       priority="info" ;;
    esac
    
    # Envoyer à syslog
    logger -t "vbox-script" -p "user.$priority" "[$level] $message [VM: $vm_name]"
}

# Utilisation
VM_NAME="SyslogVM"

log_to_syslog "INFO" "Création de la VM" "$VM_NAME"
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register

if [ $? -eq 0 ]; then
    log_to_syslog "SUCCESS" "VM créée avec succès" "$VM_NAME"
else
    log_to_syslog "ERROR" "Échec de la création" "$VM_NAME"
fi

# Consultation des logs système
# sudo tail -f /var/log/syslog | grep vbox-script
```

---

## 🎯 Pièges courants et bonnes pratiques

### Piège : Guillemets et espaces

```bash
#!/bin/bash

# ❌ MAUVAIS - Sans guillemets
VM_NAME="Ma VM Test"
VBoxManage createvm --name $VM_NAME --ostype "Ubuntu_64" --register
# Erreur : interprété comme plusieurs arguments

# ✅ BON - Avec guillemets
VM_NAME="Ma VM Test"
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register
```

> [!warning] Attention - Toujours quoter les variables Utilisez toujours des guillemets autour des variables qui peuvent contenir des espaces. C'est une source d'erreur très fréquente.

### Piège : Chemins relatifs vs absolus

```bash
#!/bin/bash

# ❌ MAUVAIS - Chemin relatif
cd "/tmp"
VBoxManage createhd --filename "disk.vdi" --size 20480
# Le fichier sera créé dans /tmp, pas où vous le pensez

# ✅ BON - Chemin absolu
VM_DIR="$HOME/VirtualBox VMs/MaVM"
mkdir -p "$VM_DIR"
VBoxManage createhd --filename "$VM_DIR/disk.vdi" --size 20480
```

### Piège : Oublier de vérifier les codes retour

```bash
#!/bin/bash

# ❌ MAUVAIS - Pas de vérification
VBoxManage createvm --name "VM1" --ostype "Ubuntu_64" --register
VBoxManage modifyvm "VM1" --memory 2048
# Continue même si la création échoue

# ✅ BON - Avec vérification
VBoxManage createvm --name "VM1" --ostype "Ubuntu_64" --register
if [ $? -ne 0 ]; then
    echo "❌ Erreur de création"
    exit 1
fi

VBoxManage modifyvm "VM1" --memory 2048
```

### Bonne pratique : Fonction de nettoyage

```bash
#!/bin/bash

# Variables de nettoyage
TEMP_VMS=()

# Fonction de nettoyage automatique
cleanup() {
    echo "🧹 Nettoyage en cours..."
    
    for vm in "${TEMP_VMS[@]}"; do
        if VBoxManage list vms | grep -q "\"$vm\""; then
            echo "Suppression de $vm"
            VBoxManage unregistervm "$vm" --delete 2>/dev/null
        fi
    done
}

# Appeler cleanup à la sortie du script
trap cleanup EXIT

# Création de VMs temporaires
VM_NAME="TempVM_$"  # $ = PID du script
TEMP_VMS+=("$VM_NAME")

VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register
# Si le script échoue ou est interrompu, cleanup sera appelé automatiquement
```

### Bonne pratique : Validation des entrées

```bash
#!/bin/bash

# Fonction de validation
validate_vm_name() {
    local name=$1
    
    # Vérifier que le nom n'est pas vide
    if [ -z "$name" ]; then
        echo "❌ Le nom ne peut pas être vide"
        return 1
    fi
    
    # Vérifier les caractères interdits
    if [[ "$name" =~ [^a-zA-Z0-9_-] ]]; then
        echo "❌ Le nom contient des caractères interdits"
        return 1
    fi
    
    # Vérifier la longueur
    if [ ${#name} -gt 50 ]; then
        echo "❌ Le nom est trop long (max 50 caractères)"
        return 1
    fi
    
    return 0
}

# Validation de la RAM
validate_ram() {
    local ram=$1
    
    if ! [[ "$ram" =~ ^[0-9]+$ ]]; then
        echo "❌ La RAM doit être un nombre"
        return 1
    fi
    
    if [ "$ram" -lt 512 ]; then
        echo "❌ RAM minimale : 512 MB"
        return 1
    fi
    
    return 0
}

# Utilisation
VM_NAME="MyVM@123"
if ! validate_vm_name "$VM_NAME"; then
    exit 1
fi

RAM=256
if ! validate_ram "$RAM"; then
    exit 1
fi
```

### Bonne pratique : Documentation inline

```bash
#!/bin/bash
###############################################################################
# Script de création automatique de VM VirtualBox
#
# Description:
#   Ce script crée et configure une machine virtuelle VirtualBox avec
#   des paramètres personnalisables via la ligne de commande.
#
# Usage:
#   ./create_vm.sh -n <nom> [-o <os>] [-m <ram>] [-c <cpus>]
#
# Auteur: Votre Nom
# Date: 2024-12-14
# Version: 1.0
#
# Exemples:
#   ./create_vm.sh -n DevVM -m 4096 -c 4
#   ./create_vm.sh -n TestVM -o Windows10_64
#
# Dépendances:
#   - VirtualBox 7.0+
#   - Bash 4.0+
###############################################################################

set -euo pipefail  # Mode strict

# Configuration par défaut
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_DIR="$HOME/vbox_logs"

# ... reste du script
```

> [!tip] Astuce - En-tête documenté Un bon en-tête de script facilite la maintenance et aide les autres utilisateurs. Incluez toujours : description, usage, exemples, dépendances.

---

## 🚀 Script complet : Exemple d'automatisation avancée

```bash
#!/bin/bash
###############################################################################
# Script avancé de création et configuration de VM VirtualBox
###############################################################################

set -euo pipefail

# ==================== CONFIGURATION ====================

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_DIR="$HOME/vbox_logs"
readonly LOG_FILE="$LOG_DIR/vm_creation_$(date +%Y%m%d_%H%M%S).log"

# Valeurs par défaut
DEFAULT_OS_TYPE="Ubuntu_64"
DEFAULT_RAM=2048
DEFAULT_CPUS=2
DEFAULT_DISK_SIZE=20480

# ==================== FONCTIONS ====================

# Logging
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p "$LOG_DIR"
    
    case $level in
        ERROR)   echo -e "\033[0;31m[$timestamp] [ERROR] $message\033[0m" ;;
        SUCCESS) echo -e "\033[0;32m[$timestamp] [SUCCESS] $message\033[0m" ;;
        WARNING) echo -e "\033[1;33m[$timestamp] [WARNING] $message\033[0m" ;;
        *)       echo -e "\033[0;34m[$timestamp] [INFO] $message\033[0m" ;;
    esac
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Affichage de l'aide
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME -n <nom> [OPTIONS]

Options obligatoires:
    -n <nom>        Nom de la VM

Options facultatives:
    -o <os>         Type d'OS (défaut: $DEFAULT_OS_TYPE)
    -m <ram>        RAM en MB (défaut: $DEFAULT_RAM)
    -c <cpus>       Nombre de CPUs (défaut: $DEFAULT_CPUS)
    -d <size>       Taille du disque en MB (défaut: $DEFAULT_DISK_SIZE)
    -i <iso>        Chemin vers l'ISO d'installation
    -v              Mode verbeux
    -h              Afficher cette aide

Exemples:
    $SCRIPT_NAME -n DevVM -m 4096 -c 4
    $SCRIPT_NAME -n TestVM -i ~/ISOs/ubuntu.iso -v

EOF
}

# Validation
validate_params() {
    if [ -z "$VM_NAME" ]; then
        log "ERROR" "Le nom de la VM est obligatoire"
        show_help
        exit 1
    fi
    
    if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
        log "ERROR" "Une VM nommée $VM_NAME existe déjà"
        exit 1
    fi
    
    if [ "$RAM" -lt 512 ]; then
        log "ERROR" "RAM minimale : 512 MB"
        exit 1
    fi
}

# Nettoyage en cas d'erreur
cleanup() {
    if [ $? -ne 0 ]; then
        log "WARNING" "Nettoyage après erreur..."
        if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
            VBoxManage unregistervm "$VM_NAME" --delete 2>/dev/null || true
        fi
    fi
}

# Création de la VM
create_vm() {
    log "INFO" "Création de la VM : $VM_NAME"
    
    VBoxManage createvm \
        --name "$VM_NAME" \
        --ostype "$OS_TYPE" \
        --register
    
    log "SUCCESS" "VM créée"
}

# Configuration
configure_vm() {
    log "INFO" "Configuration matérielle"
    
    VBoxManage modifyvm "$VM_NAME" \
        --memory "$RAM" \
        --vram 128 \
        --cpus "$CPUS" \
        --boot1 dvd \
        --boot2 disk \
        --boot3 none \
        --boot4 none \
        --nic1 nat \
        --audio none
    
    log "SUCCESS" "VM configurée"
}

# Création du disque
create_disk() {
    log "INFO" "Création du disque dur"
    
    local vm_path="$HOME/VirtualBox VMs/$VM_NAME"
    mkdir -p "$vm_path"
    
    VBoxManage createhd \
        --filename "$vm_path/$VM_NAME.vdi" \
        --size "$DISK_SIZE" \
        --format VDI
    
    VBoxManage storagectl "$VM_NAME" \
        --name "SATA Controller" \
        --add sata \
        --controller IntelAhci
    
    VBoxManage storageattach "$VM_NAME" \
        --storagectl "SATA Controller" \
        --port 0 \
        --device 0 \
        --type hdd \
        --medium "$vm_path/$VM_NAME.vdi"
    
    log "SUCCESS" "Disque créé et attaché"
}

# Attachement ISO
attach_iso() {
    if [ -n "$ISO_PATH" ]; then
        if [ ! -f "$ISO_PATH" ]; then
            log "ERROR" "Fichier ISO introuvable : $ISO_PATH"
            exit 1
        fi
        
        log "INFO" "Attachement de l'ISO"
        
        VBoxManage storagectl "$VM_NAME" \
            --name "IDE Controller" \
            --add ide
        
        VBoxManage storageattach "$VM_NAME" \
            --storagectl "IDE Controller" \
            --port 0 \
            --device 0 \
            --type dvddrive \
            --medium "$ISO_PATH"
        
        log "SUCCESS" "ISO attachée"
    fi
}

# Rapport final
generate_report() {
    log "INFO" "Génération du rapport"
    
    cat << EOF

╔════════════════════════════════════════════════════════════════╗
║                    VM CRÉÉE AVEC SUCCÈS                        ║
╚════════════════════════════════════════════════════════════════╝

📋 Nom          : $VM_NAME
🖥️  OS          : $OS_TYPE
💾 RAM          : ${RAM} MB
⚙️  CPUs        : $CPUS
💿 Disque       : ${DISK_SIZE} MB

📄 Log          : $LOG_FILE

🚀 Pour démarrer la VM :
   VBoxManage startvm "$VM_NAME"

═══════════════════════════════════════════════════════════════════

EOF
}

# ==================== MAIN ====================

# Variables
VM_NAME=""
OS_TYPE="$DEFAULT_OS_TYPE"
RAM="$DEFAULT_RAM"
CPUS="$DEFAULT_CPUS"
DISK_SIZE="$DEFAULT_DISK_SIZE"
ISO_PATH=""
VERBOSE=false

# Parser les options
while getopts "n:o:m:c:d:i:vh" opt; do
    case $opt in
        n) VM_NAME="$OPTARG" ;;
        o) OS_TYPE="$OPTARG" ;;
        m) RAM="$OPTARG" ;;
        c) CPUS="$OPTARG" ;;
        d) DISK_SIZE="$OPTARG" ;;
        i) ISO_PATH="$OPTARG" ;;
        v) VERBOSE=true ;;
        h) show_help; exit 0 ;;
        \?) show_help; exit 1 ;;
    esac
done

# Configuration du mode verbeux
if [ "$VERBOSE" = true ]; then
    set -x
fi

# Trap pour nettoyage
trap cleanup EXIT

# Exécution
log "INFO" "Démarrage du script"
log "INFO" "Fichier de log : $LOG_FILE"

validate_params
create_vm
configure_vm
create_disk
attach_iso

log "SUCCESS" "Opération terminée avec succès"
generate_report
```

> [!example] Exemple - Script production-ready Ce script complet intègre toutes les bonnes pratiques : logging, gestion d'erreurs, validation, nettoyage, documentation, et génération de rapports.

---

## 📚 Résumé des concepts clés

|Concept|Bash|PowerShell|
|---|---|---|
|**Variables**|`VAR="value"`|`$VAR = "value"`|
|**Paramètres**|`$1, $2, getopts`|`param()` avec validation|
|**Codes retour**|`$?`|`$LASTEXITCODE`|
|**Conditions**|`if [ ]; then; fi`|`if () { }`|
|**Boucles**|`for in; do; done`|`foreach () { }`|
|**Fonctions**|`function_name() { }`|`function Name { }`|
|**Logging**|`echo >> file`|`Add-Content`|
|**Erreurs**|`set -e`, `trap ERR`|`try-catch-finally`|

---

## 🎓 Points essentiels à retenir

> [!tip] 💡 Les fondamentaux du scripting VirtualBox
> 
> 1. **Toujours valider** les entrées et l'environnement avant d'exécuter des commandes
> 2. **Gérer les erreurs** systématiquement avec des codes retour et try-catch
> 3. **Logger toutes les opérations** pour faciliter le débogage et l'audit
> 4. **Utiliser des fonctions** pour la réutilisabilité et la lisibilité
> 5. **Implémenter un nettoyage** automatique en cas d'échec
> 6. **Documenter votre code** avec des commentaires et en-têtes clairs
> 7. **Tester vos scripts** dans un environnement sûr avant la production