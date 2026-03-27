

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

## Introduction au démarrage des VMs

Le démarrage des machines virtuelles via VBoxManage offre une flexibilité considérable par rapport à l'interface graphique. Vous pouvez automatiser des workflows, démarrer des VMs à distance, ou intégrer VirtualBox dans des scripts d'orchestration.

> [!info] Pourquoi utiliser la CLI pour démarrer des VMs ?
> 
> - **Automatisation** : Intégration dans des scripts bash, cron jobs, ou pipelines CI/CD
> - **Démarrage headless** : Exécuter des VMs en arrière-plan sans interface graphique
> - **Administration distante** : Gérer des VMs sur des serveurs sans environnement graphique
> - **Performance** : Économiser des ressources en évitant l'interface graphique

---

## La commande startvm

La commande `VBoxManage startvm` est le point d'entrée principal pour démarrer une machine virtuelle. Elle accepte plusieurs modes d'exécution selon vos besoins.

### Syntaxe de base

```bash
VBoxManage startvm <nom-vm|uuid> --type <mode>
```

### Mode GUI (Graphique)

Le mode GUI lance la VM avec l'interface graphique complète de VirtualBox.

```bash
# Démarrage en mode GUI (interface graphique complète)
VBoxManage startvm "MaVM" --type gui

# Alternative : gui est le mode par défaut
VBoxManage startvm "MaVM"
```

> [!example] Cas d'usage du mode GUI
> 
> - Développement et tests nécessitant une interaction visuelle
> - Première configuration d'une VM
> - Débogage de problèmes graphiques
> - Utilisation interactive de la machine virtuelle

**Caractéristiques du mode GUI :**

- Ouvre une fenêtre avec l'affichage complet de la VM
- Permet l'accès à tous les menus VirtualBox
- Capture automatique du clavier et de la souris
- Consomme plus de ressources (processus graphique)

### Mode Headless (Sans interface)

Le mode headless démarre la VM en arrière-plan sans aucune interface graphique.

```bash
# Démarrage en mode headless
VBoxManage startvm "ServeurWeb" --type headless
```

> [!tip] Le mode headless est idéal pour les serveurs C'est le mode privilégié pour les environnements de production, les serveurs CI/CD, ou toute VM qui n'a pas besoin d'interface graphique.

**Avantages du mode headless :**

- **Économie de ressources** : Pas de processus graphique
- **Idéal pour les serveurs** : Pas besoin d'environnement X11
- **Stabilité** : Moins de dépendances système
- **Parfait pour SSH/RDP** : Accès distant via protocole réseau

**Accès à une VM headless :**

```bash
# Via SSH (si configuré dans la VM)
ssh utilisateur@ip-de-la-vm

# Via RDP (si VRDE activé)
rdesktop ip-de-la-vm:3389

# Via VBoxManage pour contrôler la VM
VBoxManage controlvm "ServeurWeb" poweroff
```

> [!warning] Attention avec le mode headless
> 
> - Assurez-vous d'avoir un moyen d'accès alternatif (SSH, RDP)
> - Vérifiez que la VM démarre correctement avant de l'utiliser en production
> - Configurez la redirection de ports si nécessaire pour l'accès réseau

### Mode SDL

Le mode SDL (Simple DirectMedia Layer) offre une interface graphique légère sans les menus VirtualBox.

```bash
# Démarrage en mode SDL
VBoxManage startvm "MaVM" --type sdl
```

**Caractéristiques du mode SDL :**

- Interface minimale sans barre de menus VirtualBox
- Plus léger que le mode GUI complet
- Capture directe du clavier et souris
- Plein écran facilité

> [!info] Quand utiliser SDL ?
> 
> - Besoin d'une interface graphique légère
> - Utilisation en plein écran
> - Systèmes avec peu de ressources
> - Alternative au mode GUI sur certains systèmes Linux

**Commandes spéciales en mode SDL :**

- `Right Ctrl + F` : Basculer en plein écran
- `Right Ctrl` : Libérer le clavier/souris
- `Right Ctrl + Q` : Quitter la VM

### Mode Separate (VBoxHeadless)

Le mode separate lance un processus VBoxHeadless distinct avec accès RDP.

```bash
# Démarrage en mode separate
VBoxManage startvm "MaVM" --type separate
```

**Différences avec headless standard :**

- Lance explicitement le processus `VBoxHeadless`
- Conçu pour l'accès distant via VRDE/RDP
- Peut être utilisé avec des frontends personnalisés

---

## Options de démarrage avancées

### Variables d'environnement

VirtualBox respecte certaines variables d'environnement qui affectent le démarrage.

```bash
# Définir le dossier home VirtualBox
export VBOX_USER_HOME="/chemin/vers/config"
VBoxManage startvm "MaVM"

# Augmenter la verbosité des logs
export VBOX_RELEASE_LOG_DEST="file=/tmp/vbox.log"
export VBOX_RELEASE_LOG="all"
VBoxManage startvm "MaVM" --type headless
```

> [!tip] Variables utiles pour le débogage
> 
> ```bash
> # Log détaillé
> VBOX_RELEASE_LOG="all.e.l.f"
> 
> # Destination du log
> VBOX_RELEASE_LOG_DEST="file=/var/log/vbox/vm.log"
> 
> # Flags de débogage
> VBOX_RELEASE_LOG_FLAGS="thread time"
> ```

### Démarrage avec vrde

VRDE (VirtualBox Remote Desktop Extension) permet l'accès distant via RDP.

```bash
# Activer VRDE avant le démarrage
VBoxManage modifyvm "MaVM" --vrde on --vrdeport 3390

# Démarrer en mode headless avec VRDE
VBoxManage startvm "MaVM" --type headless

# Connexion depuis un client RDP
rdesktop localhost:3390
```

**Configuration avancée VRDE :**

```bash
# Port spécifique
VBoxManage modifyvm "MaVM" --vrdeport 5000

# Authentification
VBoxManage modifyvm "MaVM" --vrdeauthtype external

# Adresse d'écoute
VBoxManage modifyvm "MaVM" --vrdeaddress 192.168.1.100

# Méthode de chiffrement
VBoxManage modifyvm "MaVM" --vrdeextpack default
```

### Paramètres de performance au démarrage

Bien que ces paramètres se configurent généralement avant le démarrage, ils influencent directement les performances.

```bash
# Configurer avant le démarrage
VBoxManage modifyvm "MaVM" \
    --cpus 4 \
    --memory 4096 \
    --vram 128 \
    --accelerate3d on \
    --ioapic on

# Puis démarrer
VBoxManage startvm "MaVM" --type headless
```

> [!warning] Ressources et démarrage
> 
> - Vérifiez que l'hôte dispose des ressources allouées
> - Une allocation excessive peut empêcher le démarrage
> - Les VMs headless consomment moins de VRAM

---

## Démarrage automatique

Le démarrage automatique permet de lancer des VMs au boot du système hôte, idéal pour les serveurs ou les environnements de développement.

### Configuration de l'autostart

```bash
# Activer l'autostart pour une VM
VBoxManage modifyvm "ServeurWeb" --autostart-enabled on

# Désactiver l'autostart
VBoxManage modifyvm "ServeurWeb" --autostart-enabled off

# Vérifier le statut
VBoxManage showvminfo "ServeurWeb" | grep "Autostart"
```

> [!info] Prérequis système Sur Linux, le service `vboxautostart-service` doit être installé et configuré. Sur Windows/macOS, la fonctionnalité est gérée par les services système VirtualBox.

### Politique de démarrage

Définissez le comportement au démarrage et à l'arrêt du système.

```bash
# Définir le délai de démarrage (en secondes)
VBoxManage modifyvm "ServeurWeb" --autostart-delay 10

# Politique d'arrêt du système hôte
# Options : poweroff, savestate, acpipowerbutton
VBoxManage modifyvm "ServeurWeb" --autostop-type acpipowerbutton
```

**Options de politique d'arrêt :**

|Politique|Description|Usage recommandé|
|---|---|---|
|`poweroff`|Extinction forcée immédiate|VMs de test, non critiques|
|`savestate`|Sauvegarde de l'état|Reprise rapide, perte possible de données réseau|
|`acpipowerbutton`|Signal ACPI (arrêt propre)|Production, arrêt gracieux|

> [!tip] Astuce pour l'arrêt propre `acpipowerbutton` est généralement le meilleur choix car il permet au système d'exploitation invité de s'arrêter proprement, fermant les applications et sauvegardant les données.

### Gestion du délai et de l'ordre

Contrôlez l'ordre et le timing du démarrage des VMs.

```bash
# Délai de démarrage : temps d'attente après le boot
VBoxManage modifyvm "BaseDonnees" --autostart-delay 0

# La VM suivante démarre 30 secondes après
VBoxManage modifyvm "ServeurApp" --autostart-delay 30

# La dernière démarre encore 20 secondes après
VBoxManage modifyvm "ServeurWeb" --autostart-delay 50
```

> [!example] Scénario : Stack applicative complète
> 
> ```bash
> # 1. Base de données démarre en premier
> VBoxManage modifyvm "MySQL-Server" \
>     --autostart-enabled on \
>     --autostart-delay 0 \
>     --autostop-type acpipowerbutton
> 
> # 2. Serveur applicatif 30s après
> VBoxManage modifyvm "Backend-API" \
>     --autostart-enabled on \
>     --autostart-delay 30 \
>     --autostop-type acpipowerbutton
> 
> # 3. Serveur web 60s après (total)
> VBoxManage modifyvm "Nginx-Frontend" \
>     --autostart-enabled on \
>     --autostart-delay 60 \
>     --autostop-type acpipowerbutton
> ```
> 
> Cette configuration garantit que chaque couche démarre dans le bon ordre avec le temps nécessaire pour l'initialisation.

### Configuration système (Linux)

Sur Linux, le démarrage automatique nécessite une configuration supplémentaire.

**Étape 1 : Créer le fichier de configuration**

```bash
# Créer le répertoire de configuration
sudo mkdir -p /etc/vbox

# Créer le fichier de configuration
sudo nano /etc/vbox/autostart.cfg
```

**Contenu du fichier `/etc/vbox/autostart.cfg` :**

```ini
# Configuration de l'autostart VirtualBox
default_policy = deny

# Autoriser l'utilisateur 'vboxuser'
vboxuser = {
    allow = true
    startup_delay = 10
}

# Autoriser un autre utilisateur avec politique différente
autreuser = {
    allow = true
    startup_delay = 5
}
```

**Étape 2 : Configurer les permissions**

```bash
# Définir les permissions appropriées
sudo chown root:vboxusers /etc/vbox
sudo chmod 1775 /etc/vbox

# Permissions sur le fichier de config
sudo chown root:vboxusers /etc/vbox/autostart.cfg
sudo chmod 644 /etc/vbox/autostart.cfg
```

**Étape 3 : Configurer la base de données autostart**

```bash
# Définir le répertoire autostart pour l'utilisateur
VBoxManage setproperty autostartdbpath /etc/vbox
```

**Étape 4 : Activer le service (systemd)**

```bash
# Activer et démarrer le service
sudo systemctl enable vboxautostart-service
sudo systemctl start vboxautostart-service

# Vérifier le statut
sudo systemctl status vboxautostart-service
```

> [!warning] Sécurité et permissions
> 
> - Le répertoire `/etc/vbox` doit avoir le sticky bit (`1775`)
> - Seuls les utilisateurs autorisés dans `autostart.cfg` peuvent utiliser l'autostart
> - Les VMs s'exécutent avec les permissions de l'utilisateur propriétaire

**Script de vérification :**

```bash
#!/bin/bash
# Vérifier la configuration de l'autostart

echo "=== Configuration VirtualBox Autostart ==="

# Vérifier le service
echo -e "\n1. Statut du service:"
systemctl is-active vboxautostart-service

# Vérifier le chemin de la base de données
echo -e "\n2. Chemin autostart DB:"
VBoxManage list systemproperties | grep "Default machine folder"

# Lister les VMs avec autostart activé
echo -e "\n3. VMs avec autostart:"
VBoxManage list vms | while read vm; do
    vm_name=$(echo $vm | cut -d'"' -f2)
    autostart=$(VBoxManage showvminfo "$vm_name" --machinereadable | grep "autostart-enabled" | cut -d'=' -f2)
    if [ "$autostart" = "on" ]; then
        echo "  - $vm_name"
    fi
done

# Vérifier les permissions
echo -e "\n4. Permissions /etc/vbox:"
ls -ld /etc/vbox
ls -l /etc/vbox/autostart.cfg 2>/dev/null || echo "  Fichier autostart.cfg non trouvé"
```

---

## Pièges courants et bonnes pratiques

> [!warning] Erreurs fréquentes

**1. VM déjà démarrée**

```bash
# Erreur : "VBoxManage: error: The machine is already locked by a session"
# Vérifier l'état avant de démarrer
VBoxManage showvminfo "MaVM" --machinereadable | grep "VMState="

# Forcer l'arrêt si nécessaire
VBoxManage controlvm "MaVM" poweroff
```

**2. Ressources insuffisantes**

```bash
# Erreur au démarrage : "Unable to allocate and lock memory"
# Vérifier les ressources disponibles
free -h
# Réduire la mémoire allouée
VBoxManage modifyvm "MaVM" --memory 2048
```

**3. Mode headless sans accès distant**

```bash
# Ne pas démarrer en headless sans SSH ou RDP configuré !
# Toujours vérifier l'accès avant :

# Option 1 : SSH
ping -c 1 ip-de-la-vm
ssh utilisateur@ip-de-la-vm echo "OK"

# Option 2 : VRDE activé
VBoxManage showvminfo "MaVM" | grep VRDE
```

> [!tip] Bonnes pratiques

**1. Scripts de démarrage robustes**

```bash
#!/bin/bash
# Script de démarrage sécurisé

VM_NAME="ServeurWeb"
MAX_RETRIES=3
RETRY_DELAY=5

start_vm() {
    local retry=0
    while [ $retry -lt $MAX_RETRIES ]; do
        echo "Tentative $((retry+1))/$MAX_RETRIES..."
        
        if VBoxManage startvm "$VM_NAME" --type headless 2>/dev/null; then
            echo "✓ VM démarrée avec succès"
            return 0
        fi
        
        retry=$((retry+1))
        [ $retry -lt $MAX_RETRIES ] && sleep $RETRY_DELAY
    done
    
    echo "✗ Échec du démarrage après $MAX_RETRIES tentatives"
    return 1
}

# Vérifier que la VM existe
if ! VBoxManage list vms | grep -q "\"$VM_NAME\""; then
    echo "✗ VM '$VM_NAME' introuvable"
    exit 1
fi

# Vérifier l'état actuel
VM_STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "VMState=" | cut -d'"' -f2)

case "$VM_STATE" in
    "running")
        echo "⚠ VM déjà en cours d'exécution"
        exit 0
        ;;
    "paused")
        echo "⚠ VM en pause, reprise..."
        VBoxManage controlvm "$VM_NAME" resume
        exit 0
        ;;
    *)
        start_vm
        ;;
esac
```

**2. Monitoring post-démarrage**

```bash
# Attendre que la VM soit complètement démarrée
wait_for_vm() {
    local vm_name=$1
    local timeout=120
    local elapsed=0
    
    echo "Attente du démarrage complet..."
    
    while [ $elapsed -lt $timeout ]; do
        # Vérifier si les Guest Additions répondent
        if VBoxManage guestproperty get "$vm_name" "/VirtualBox/GuestInfo/OS/Version" 2>/dev/null | grep -q "Value:"; then
            echo "✓ VM opérationnelle (${elapsed}s)"
            return 0
        fi
        
        sleep 2
        elapsed=$((elapsed+2))
    done
    
    echo "⚠ Timeout après ${timeout}s"
    return 1
}

VBoxManage startvm "MaVM" --type headless
wait_for_vm "MaVM"
```

**3. Gestion des logs**

```bash
# Conserver les logs de démarrage
LOG_DIR="/var/log/vbox"
mkdir -p "$LOG_DIR"

# Démarrage avec log
VBoxManage startvm "MaVM" --type headless 2>&1 | tee "$LOG_DIR/start-$(date +%Y%m%d-%H%M%S).log"

# Rotation des logs anciens
find "$LOG_DIR" -name "start-*.log" -mtime +7 -delete
```

**4. Autostart avec vérifications**

```bash
# Dans /etc/vbox/autostart.cfg
default_policy = deny

myuser = {
    allow = true
    startup_delay = 10
}

# Script personnalisé appelé au démarrage système
# /usr/local/bin/vbox-smart-start.sh
#!/bin/bash

# Vérifier les ressources avant de démarrer
AVAILABLE_RAM=$(free -m | awk '/^Mem:/{print $7}')
REQUIRED_RAM=4096

if [ $AVAILABLE_RAM -lt $REQUIRED_RAM ]; then
    logger "VBox: RAM insuffisante ($AVAILABLE_RAM < $REQUIRED_RAM), autostart annulé"
    exit 1
fi

# Démarrer uniquement si le réseau est prêt
ping -c 1 8.8.8.8 > /dev/null 2>&1 || {
    logger "VBox: Réseau non disponible, attente..."
    sleep 30
}

# Continuer avec le démarrage normal
```

> [!tip] Astuces de productivité

**Alias utiles :**

```bash
# Ajouter à ~/.bashrc ou ~/.zshrc

# Démarrage rapide
alias vstart='VBoxManage startvm'
alias vstarth='VBoxManage startvm --type headless'

# Démarrer plusieurs VMs en parallèle
vstart-all() {
    for vm in "$@"; do
        echo "Démarrage de $vm..."
        VBoxManage startvm "$vm" --type headless &
    done
    wait
    echo "✓ Toutes les VMs démarrées"
}

# Usage : vstart-all VM1 VM2 VM3
```

**Vérification rapide de l'état :**

```bash
# Fonction pour voir l'état de toutes les VMs
vms-status() {
    VBoxManage list vms | while read vm; do
        vm_name=$(echo $vm | cut -d'"' -f2)
        state=$(VBoxManage showvminfo "$vm_name" --machinereadable | grep "VMState=" | cut -d'"' -f2)
        printf "%-30s %s\n" "$vm_name" "$state"
    done
}
```

---

**💡 Points clés à retenir :**

- **Mode headless** est optimal pour les serveurs et l'automatisation
- **L'autostart** nécessite une configuration système sur Linux
- **Toujours** prévoir un accès alternatif (SSH/RDP) en mode headless
- **Vérifier** l'état avant de démarrer pour éviter les conflits
- **Utiliser** des scripts robustes avec gestion d'erreurs pour la production
- **Configurer** les délais d'autostart pour gérer les dépendances entre VMs