

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

## 🎯 Templates et Clonage

### Pourquoi utiliser des templates ?

Les templates permettent de créer rapidement des VMs identiques sans réinstaller le système à chaque fois. C'est essentiel pour :

- **Environnements de développement homogènes** : toute l'équipe travaille sur la même configuration
- **Tests en masse** : déployer rapidement plusieurs instances pour des tests de charge
- **Déploiement d'infrastructures** : créer des clusters (Kubernetes, Hadoop, etc.)
- **Gain de temps** : éviter les installations répétitives

### Création d'une VM template

Avant de cloner, vous devez créer une VM "maître" parfaitement configurée :

```bash
# 1. Créer et installer votre VM de base
VBoxManage createvm --name "Ubuntu-Template" --ostype Ubuntu_64 --register
VBoxManage modifyvm "Ubuntu-Template" --memory 2048 --cpus 2 --vram 128
VBoxManage createhd --filename ~/VirtualBox\ VMs/Ubuntu-Template/Ubuntu-Template.vdi --size 20480

# 2. Après installation du système, préparer la VM pour le clonage
# Nettoyer l'historique, les logs, les clés SSH, etc.
```

> [!tip] Préparation du template Avant de cloner, exécutez ces commandes dans la VM template :
> 
> ```bash
> # Nettoyer les logs
> sudo rm -rf /var/log/*
> 
> # Supprimer l'historique bash
> history -c && rm ~/.bash_history
> 
> # Supprimer les clés SSH (elles seront régénérées)
> sudo rm -rf /etc/ssh/ssh_host_*
> 
> # Nettoyer le cache
> sudo apt clean
> ```

### Types de clonage

VirtualBox propose deux types de clones :

|Type|Description|Espace disque|Usage|
|---|---|---|---|
|**Full Clone**|Copie complète et indépendante|Proportionnel à la taille du disque source|Production, VMs isolées|
|**Linked Clone**|Partage le disque de base, delta dans un nouveau fichier|Minimal (seulement les différences)|Développement, tests rapides|

#### Clonage complet (Full Clone)

```bash
# Syntaxe de base
VBoxManage clonevm "Ubuntu-Template" --name "Ubuntu-Production-01" --register

# Avec options avancées
VBoxManage clonevm "Ubuntu-Template" \
  --name "Ubuntu-Production-01" \
  --basefolder ~/VirtualBox\ VMs/Production \
  --register \
  --mode all
```

> [!info] Option `--mode`
> 
> - `machine` : clone uniquement les paramètres de la VM
> - `machineandchildren` : clone la VM et ses snapshots enfants
> - `all` : clone tout (snapshots complets)

#### Clonage lié (Linked Clone)

```bash
# Nécessite un snapshot de la VM source
VBoxManage snapshot "Ubuntu-Template" take "BaseSnapshot"

# Créer le linked clone
VBoxManage clonevm "Ubuntu-Template" \
  --snapshot "BaseSnapshot" \
  --name "Ubuntu-Dev-01" \
  --options link \
  --register
```

> [!warning] Dépendance des Linked Clones Un linked clone dépend de la VM source. Si vous supprimez la VM template ou le snapshot de base, tous les linked clones deviendront inutilisables !

### Clonage en masse avec script

```bash
#!/bin/bash

# Configuration
TEMPLATE="Ubuntu-Template"
PREFIX="Ubuntu-Server"
COUNT=5
BASE_FOLDER=~/VirtualBox\ VMs/Cluster

# Boucle de clonage
for i in $(seq 1 $COUNT); do
    VM_NAME="${PREFIX}-$(printf %02d $i)"
    
    echo "🔄 Clonage de $VM_NAME..."
    
    VBoxManage clonevm "$TEMPLATE" \
      --name "$VM_NAME" \
      --basefolder "$BASE_FOLDER" \
      --register
    
    echo "✅ $VM_NAME créé avec succès"
done

echo "🎉 Clonage de $COUNT VMs terminé !"
```

### Modification des adresses MAC

Après clonage, il est crucial de changer les adresses MAC pour éviter les conflits réseau :

```bash
# Générer une nouvelle adresse MAC pour chaque interface réseau
VBoxManage modifyvm "Ubuntu-Server-01" \
  --macaddress1 auto

# Ou spécifier une adresse MAC personnalisée
VBoxManage modifyvm "Ubuntu-Server-02" \
  --macaddress1 080027ABCDEF
```

> [!tip] Génération automatique L'option `auto` génère une adresse MAC valide dans le range VirtualBox (08:00:27:xx:xx:xx)

### Export/Import de templates

Pour partager des templates entre machines :

```bash
# Export au format OVA (Open Virtualization Archive)
VBoxManage export "Ubuntu-Template" \
  --output ~/Templates/ubuntu-template.ova \
  --manifest \
  --options nomacs

# Import sur une autre machine
VBoxManage import ~/Templates/ubuntu-template.ova \
  --vsys 0 \
  --vmname "Ubuntu-Template-Imported"
```

> [!info] Option `--options nomacs` Empêche l'inclusion des adresses MAC dans l'export, permettant leur régénération automatique à l'import

---

## 🌐 Configuration Réseau Automatique

### Modes réseau en déploiement masse

Lors d'un déploiement en masse, le choix du mode réseau est crucial :

|Mode|Usage|Avantages|Inconvénients|
|---|---|---|---|
|**NAT**|VMs isolées avec Internet|Simple, pas de config|VMs ne communiquent pas entre elles|
|**Bridged**|VMs sur le réseau physique|Comme des machines réelles|Consomme des IPs du réseau local|
|**Internal Network**|Réseau privé entre VMs|Isolation totale|Pas d'accès Internet|
|**Host-Only**|Communication VMs ↔ Host|Contrôle total|Configuration manuelle requise|
|**NAT Network**|NAT partagé avec communication inter-VMs|Internet + communication|Configuration du réseau NAT nécessaire|

### Configuration NAT Network (recommandé pour clusters)

Le NAT Network combine les avantages du NAT et de l'Internal Network :

```bash
# Créer un réseau NAT
VBoxManage natnetwork add \
  --netname ClusterNetwork \
  --network "10.0.10.0/24" \
  --enable \
  --dhcp on

# Configurer le port forwarding pour SSH (optionnel)
VBoxManage natnetwork modify ClusterNetwork \
  --port-forward-4 "ssh-vm1:tcp:[]:2201:[10.0.10.10]:22"

# Lister les réseaux NAT
VBoxManage natnetwork list
```

### Assignation automatique des IPs

#### Avec DHCP

```bash
# Activer DHCP sur le réseau NAT
VBoxManage natnetwork modify ClusterNetwork --dhcp on

# Attacher les VMs au réseau NAT
for i in {1..5}; do
    VBoxManage modifyvm "Ubuntu-Server-$(printf %02d $i)" \
      --nic1 natnetwork \
      --nat-network1 ClusterNetwork
done
```

#### Avec IPs statiques

Script de configuration réseau post-clonage :

```bash
#!/bin/bash

# Configuration
BASE_IP="10.0.10"
START_IP=10
NETMASK="255.255.255.0"
GATEWAY="10.0.10.1"
DNS="8.8.8.8"

# Fonction pour configurer une VM
configure_network() {
    VM_NAME=$1
    IP_SUFFIX=$2
    IP="${BASE_IP}.${IP_SUFFIX}"
    
    # Créer le script de configuration réseau
    cat > /tmp/netconfig-${VM_NAME}.sh << EOF
#!/bin/bash
# Configuration réseau pour ${VM_NAME}

# Pour Ubuntu/Debian avec netplan
cat > /etc/netplan/01-netcfg.yaml << NETPLAN
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
        - ${IP}/24
      gateway4: ${GATEWAY}
      nameservers:
        addresses: [${DNS}]
NETPLAN

netplan apply
EOF
    
    # Copier et exécuter dans la VM (nécessite Guest Additions)
    VBoxManage guestcontrol "${VM_NAME}" \
      copyto /tmp/netconfig-${VM_NAME}.sh /tmp/netconfig.sh \
      --username root --password votrepassword
    
    VBoxManage guestcontrol "${VM_NAME}" \
      run /bin/bash -- bash /tmp/netconfig.sh \
      --username root --password votrepassword
}

# Configurer chaque VM
for i in {1..5}; do
    VM_NAME="Ubuntu-Server-$(printf %02d $i)"
    IP_SUFFIX=$((START_IP + i - 1))
    configure_network "$VM_NAME" "$IP_SUFFIX"
    echo "✅ $VM_NAME configuré avec IP ${BASE_IP}.${IP_SUFFIX}"
done
```

> [!warning] Prérequis Guest Additions La commande `guestcontrol` nécessite que VirtualBox Guest Additions soit installé dans la VM

### Configuration de multiples interfaces réseau

Pour des architectures complexes (par exemple, réseau de gestion + réseau de données) :

```bash
#!/bin/bash

VM_NAME="Ubuntu-Server-01"

# Interface 1 : NAT Network (Internet + communication inter-VMs)
VBoxManage modifyvm "$VM_NAME" \
  --nic1 natnetwork \
  --nat-network1 ClusterNetwork

# Interface 2 : Internal Network (réseau de stockage privé)
VBoxManage modifyvm "$VM_NAME" \
  --nic2 intnet \
  --intnet2 StorageNetwork

# Interface 3 : Host-Only (administration depuis l'hôte)
VBoxManage modifyvm "$VM_NAME" \
  --nic3 hostonly \
  --hostonlyadapter3 vboxnet0
```

### Port Forwarding automatisé

Pour accéder à des services spécifiques sur chaque VM :

```bash
#!/bin/bash

BASE_PORT=8080
SSH_BASE_PORT=2200

for i in {1..5}; do
    VM_NAME="Ubuntu-Server-$(printf %02d $i)"
    HTTP_PORT=$((BASE_PORT + i - 1))
    SSH_PORT=$((SSH_BASE_PORT + i))
    
    # Port forwarding HTTP
    VBoxManage modifyvm "$VM_NAME" \
      --natpf1 "http,tcp,,$HTTP_PORT,,80"
    
    # Port forwarding SSH
    VBoxManage modifyvm "$VM_NAME" \
      --natpf1 "ssh,tcp,,$SSH_PORT,,22"
    
    echo "✅ $VM_NAME : HTTP → localhost:$HTTP_PORT, SSH → localhost:$SSH_PORT"
done
```

> [!example] Résultat
> 
> - Ubuntu-Server-01 : HTTP sur port 8080, SSH sur port 2201
> - Ubuntu-Server-02 : HTTP sur port 8081, SSH sur port 2202
> - etc.

### Création de réseaux Host-Only

```bash
# Créer un réseau Host-Only
VBoxManage hostonlyif create

# Configurer l'interface (sous Linux/macOS)
VBoxManage hostonlyif ipconfig vboxnet0 \
  --ip 192.168.56.1 \
  --netmask 255.255.255.0

# Activer le serveur DHCP
VBoxManage dhcpserver add \
  --ifname vboxnet0 \
  --ip 192.168.56.1 \
  --netmask 255.255.255.0 \
  --lowerip 192.168.56.100 \
  --upperip 192.168.56.200 \
  --enable
```

---

## 🏭 Provisioning de VMs Multiples

### Workflow de provisioning complet

Le provisioning comprend plusieurs étapes automatisables :

1. **Clonage** de la VM template
2. **Configuration matérielle** (CPU, RAM, réseau)
3. **Démarrage** de la VM
4. **Configuration système** via Guest Additions
5. **Installation de logiciels** et configuration applicative
6. **Vérification** et tests

### Script de provisioning complet

```bash
#!/bin/bash

# ============================================
# Configuration globale
# ============================================
TEMPLATE_VM="Ubuntu-Template"
VM_PREFIX="WebServer"
VM_COUNT=3
BASE_FOLDER=~/VirtualBox\ VMs/WebCluster

# Ressources matérielles
MEMORY=2048
CPUS=2
VRAM=16

# Configuration réseau
NAT_NETWORK="WebClusterNet"
NETWORK_BASE="10.0.20"
GATEWAY="10.0.20.1"

# Credentials pour Guest Control
VM_USER="admin"
VM_PASSWORD="votrepassword"

# ============================================
# Création du réseau NAT
# ============================================
echo "🌐 Création du réseau NAT..."
VBoxManage natnetwork add \
  --netname "$NAT_NETWORK" \
  --network "${NETWORK_BASE}.0/24" \
  --enable \
  --dhcp off 2>/dev/null || echo "Réseau déjà existant"

# ============================================
# Boucle de provisioning
# ============================================
for i in $(seq 1 $VM_COUNT); do
    VM_NAME="${VM_PREFIX}-$(printf %02d $i)"
    VM_IP="${NETWORK_BASE}.$((10 + i))"
    
    echo ""
    echo "=========================================="
    echo "🚀 Provisioning de $VM_NAME"
    echo "=========================================="
    
    # -----------------------------------------
    # 1. Clonage
    # -----------------------------------------
    echo "📋 Clonage depuis $TEMPLATE_VM..."
    VBoxManage clonevm "$TEMPLATE_VM" \
      --name "$VM_NAME" \
      --basefolder "$BASE_FOLDER" \
      --register
    
    # -----------------------------------------
    # 2. Configuration matérielle
    # -----------------------------------------
    echo "⚙️  Configuration matérielle..."
    VBoxManage modifyvm "$VM_NAME" \
      --memory $MEMORY \
      --cpus $CPUS \
      --vram $VRAM \
      --macaddress1 auto
    
    # -----------------------------------------
    # 3. Configuration réseau
    # -----------------------------------------
    echo "🌐 Configuration réseau..."
    VBoxManage modifyvm "$VM_NAME" \
      --nic1 natnetwork \
      --nat-network1 "$NAT_NETWORK"
    
    # Port forwarding SSH unique
    SSH_PORT=$((2200 + i))
    VBoxManage modifyvm "$VM_NAME" \
      --natpf1 "ssh,tcp,,$SSH_PORT,,22"
    
    # Port forwarding HTTP unique
    HTTP_PORT=$((8080 + i - 1))
    VBoxManage modifyvm "$VM_NAME" \
      --natpf1 "http,tcp,,$HTTP_PORT,,80"
    
    # -----------------------------------------
    # 4. Démarrage
    # -----------------------------------------
    echo "▶️  Démarrage de la VM..."
    VBoxManage startvm "$VM_NAME" --type headless
    
    # Attendre que la VM soit complètement démarrée
    echo "⏳ Attente du démarrage complet (60s)..."
    sleep 60
    
    # -----------------------------------------
    # 5. Configuration système
    # -----------------------------------------
    echo "🔧 Configuration IP statique..."
    
    # Créer le script de configuration réseau
    cat > /tmp/netconfig-${VM_NAME}.sh << EOF
#!/bin/bash
# Configuration réseau statique

cat > /etc/netplan/01-netcfg.yaml << NETPLAN
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
        - ${VM_IP}/24
      gateway4: ${GATEWAY}
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
NETPLAN

netplan apply

# Mise à jour du hostname
hostnamectl set-hostname ${VM_NAME}
EOF
    
    # Exécution dans la VM
    VBoxManage guestcontrol "$VM_NAME" \
      copyto /tmp/netconfig-${VM_NAME}.sh /tmp/netconfig.sh \
      --username "$VM_USER" --password "$VM_PASSWORD"
    
    VBoxManage guestcontrol "$VM_NAME" \
      run /usr/bin/sudo -- bash /tmp/netconfig.sh \
      --username "$VM_USER" --password "$VM_PASSWORD"
    
    # -----------------------------------------
    # 6. Installation de logiciels
    # -----------------------------------------
    echo "📦 Installation de Nginx..."
    
    VBoxManage guestcontrol "$VM_NAME" \
      run /usr/bin/sudo -- apt update \
      --username "$VM_USER" --password "$VM_PASSWORD"
    
    VBoxManage guestcontrol "$VM_NAME" \
      run /usr/bin/sudo -- apt install -y nginx \
      --username "$VM_USER" --password "$VM_PASSWORD"
    
    # -----------------------------------------
    # 7. Configuration applicative
    # -----------------------------------------
    echo "🎨 Configuration de la page d'accueil..."
    
    cat > /tmp/index-${VM_NAME}.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>${VM_NAME}</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; }
        h1 { color: #0066cc; }
    </style>
</head>
<body>
    <h1>${VM_NAME}</h1>
    <p>IP: ${VM_IP}</p>
    <p>HTTP Port: ${HTTP_PORT}</p>
    <p>SSH Port: ${SSH_PORT}</p>
</body>
</html>
EOF
    
    VBoxManage guestcontrol "$VM_NAME" \
      copyto /tmp/index-${VM_NAME}.html /var/www/html/index.html \
      --username "$VM_USER" --password "$VM_PASSWORD"
    
    # -----------------------------------------
    # 8. Finalisation
    # -----------------------------------------
    echo "✅ $VM_NAME provisionné avec succès !"
    echo "   - IP interne: $VM_IP"
    echo "   - HTTP: http://localhost:$HTTP_PORT"
    echo "   - SSH: ssh -p $SSH_PORT $VM_USER@localhost"
    
done

# ============================================
# Résumé
# ============================================
echo ""
echo "=========================================="
echo "🎉 Provisioning terminé !"
echo "=========================================="
echo ""
echo "VMs créées :"
for i in $(seq 1 $VM_COUNT); do
    VM_NAME="${VM_PREFIX}-$(printf %02d $i)"
    HTTP_PORT=$((8080 + i - 1))
    SSH_PORT=$((2200 + i))
    echo "  $VM_NAME → http://localhost:$HTTP_PORT (SSH: $SSH_PORT)"
done
echo ""
```

> [!tip] Personnalisation Adaptez les variables en haut du script selon vos besoins : nombre de VMs, ressources, réseau, etc.

### Provisioning sans Guest Additions (alternative)

Si Guest Additions n'est pas disponible, utilisez SSH :

```bash
#!/bin/bash

# Fonction pour exécuter des commandes via SSH
ssh_exec() {
    VM_NAME=$1
    SSH_PORT=$2
    COMMAND=$3
    
    sshpass -p "$VM_PASSWORD" ssh \
      -o StrictHostKeyChecking=no \
      -p "$SSH_PORT" \
      "${VM_USER}@localhost" \
      "$COMMAND"
}

# Exemple d'utilisation
ssh_exec "WebServer-01" 2201 "sudo apt update && sudo apt install -y nginx"
```

> [!warning] Sécurité L'utilisation de `sshpass` avec des mots de passe en clair n'est pas recommandée en production. Préférez l'authentification par clé SSH.

### Provisioning parallèle

Pour accélérer le provisioning de nombreuses VMs :

```bash
#!/bin/bash

# Fonction de provisioning
provision_vm() {
    i=$1
    # ... (même code que précédemment)
}

# Lancement en parallèle
for i in $(seq 1 $VM_COUNT); do
    provision_vm $i &
done

# Attendre la fin de tous les processus
wait

echo "✅ Provisioning parallèle terminé !"
```

> [!warning] Limites des ressources Le provisioning parallèle consomme beaucoup de ressources. Limitez le nombre de VMs en parallèle selon votre machine.

### Validation post-provisioning

```bash
#!/bin/bash

echo "🔍 Validation du cluster..."

for i in $(seq 1 $VM_COUNT); do
    VM_NAME="${VM_PREFIX}-$(printf %02d $i)"
    HTTP_PORT=$((8080 + i - 1))
    
    # Test HTTP
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$HTTP_PORT)
    
    if [ "$HTTP_CODE" == "200" ]; then
        echo "✅ $VM_NAME : HTTP OK"
    else
        echo "❌ $VM_NAME : HTTP FAILED (code $HTTP_CODE)"
    fi
    
    # Test ping interne (nécessite accès à la VM)
    VM_IP="${NETWORK_BASE}.$((10 + i))"
    if VBoxManage guestcontrol "$VM_NAME" \
       run /bin/ping -- -c 1 "$GATEWAY" \
       --username "$VM_USER" --password "$VM_PASSWORD" &>/dev/null; then
        echo "✅ $VM_NAME : Network OK"
    else
        echo "❌ $VM_NAME : Network FAILED"
    fi
done
```

---

## 📝 Fichiers de Configuration

### Format des fichiers de configuration

VirtualBox peut utiliser des fichiers de configuration pour standardiser le déploiement. Deux approches principales :

1. **Scripts Shell** : maximum de contrôle et flexibilité
2. **Fichiers YAML/JSON** : plus structurés et lisibles

### Structure d'un fichier de configuration YAML

```yaml
# vm-config.yaml
cluster:
  name: WebCluster
  template: Ubuntu-Template
  count: 3
  
network:
  type: natnetwork
  name: WebClusterNet
  subnet: 10.0.20.0/24
  dhcp: false
  
vms:
  - name: WebServer-01
    memory: 2048
    cpus: 2
    ip: 10.0.20.11
    ports:
      ssh: 2201
      http: 8080
      
  - name: WebServer-02
    memory: 2048
    cpus: 2
    ip: 10.0.20.12
    ports:
      ssh: 2202
      http: 8081
      
  - name: WebServer-03
    memory: 4096
    cpus: 4
    ip: 10.0.20.13
    ports:
      ssh: 2203
      http: 8082

software:
  packages:
    - nginx
    - curl
    - vim
  
  custom_scripts:
    - setup-webserver.sh
    - configure-firewall.sh
```

### Parser et utiliser le fichier YAML

```bash
#!/bin/bash

# Installer yq (parser YAML en CLI) si nécessaire
# sudo apt install yq

CONFIG_FILE="vm-config.yaml"

# Lire les valeurs depuis le YAML
TEMPLATE=$(yq eval '.cluster.template' $CONFIG_FILE)
VM_COUNT=$(yq eval '.cluster.count' $CONFIG_FILE)
NET_NAME=$(yq eval '.network.name' $CONFIG_FILE)
NET_SUBNET=$(yq eval '.network.subnet' $CONFIG_FILE)

echo "Configuration chargée depuis $CONFIG_FILE"
echo "Template: $TEMPLATE"
echo "Nombre de VMs: $VM_COUNT"
echo "Réseau: $NET_NAME ($NET_SUBNET)"

# Créer le réseau
VBoxManage natnetwork add \
  --netname "$NET_NAME" \
  --network "$NET_SUBNET" \
  --enable

# Boucle sur les VMs définies
for i in $(seq 0 $((VM_COUNT - 1))); do
    VM_NAME=$(yq eval ".vms[$i].name" $CONFIG_FILE)
    VM_MEMORY=$(yq eval ".vms[$i].memory" $CONFIG_FILE)
    VM_CPUS=$(yq eval ".vms[$i].cpus" $CONFIG_FILE)
    VM_IP=$(yq eval ".vms[$i].ip" $CONFIG_FILE)
    SSH_PORT=$(yq eval ".vms[$i].ports.ssh" $CONFIG_FILE)
    HTTP_PORT=$(yq eval ".vms[$i].ports.http" $CONFIG_FILE)
    
    echo ""
    echo "Provisioning $VM_NAME..."
    
    # Clonage
    VBoxManage clonevm "$TEMPLATE" --name "$VM_NAME" --register
    
    # Configuration
    VBoxManage modifyvm "$VM_NAME" \
      --memory $VM_MEMORY \
      --cpus $VM_CPUS \
      --nic1 natnetwork \
      --nat-network1 "$NET_NAME" \
      --macaddress1 auto \
      --natpf1 "ssh,tcp,,$SSH_PORT,,22" \
      --natpf1 "http,tcp,,$HTTP_PORT,,80"
    
    echo "✅ $VM_NAME configuré"
done
```

> [!tip] Installation de yq `yq` est un outil puissant pour parser YAML en ligne de commande :
> 
> ```bash
> # Ubuntu/Debian
> sudo apt install yq
> 
> # macOS
> brew install yq
> ```

### Fichier de configuration par VM (format INI)

```ini
# webserver-01.conf
[vm]
name=WebServer-01
template=Ubuntu-Template
memory=2048
cpus=2
vram=16

[network]
mode=natnetwork
network_name=WebClusterNet
ip=10.0.20.11
gateway=10.0.20.1
dns=8.8.8.8

[ports]
ssh=2201
http=8080
https=8443

[software]
packages=nginx,curl,vim,git
services=nginx

[custom]
hostname=web01.cluster.local
timezone=Europe/Paris
```

### Parser un fichier INI en Bash

```bash
#!/bin/bash

read_ini_section() {
    local file=$1
    local section=$2
    local key=$3
    
    awk -F '=' -v section="$section" -v key="$key" '
        $0 ~ "^\\[" section "\\]" { in_section=1; next }
        $0 ~ /^\[/ { in_section=0 }
        in_section && $1 == key { print $2; exit }
    ' "$file"
}

# Exemple d'utilisation
CONFIG_FILE="webserver-01.conf"

VM_NAME=$(read_ini_section "$CONFIG_FILE" "vm" "name")
VM_MEMORY=$(read_ini_section "$CONFIG_FILE" "vm" "memory")
VM_IP=$(read_ini_section "$CONFIG_FILE" "network" "ip")
PACKAGES=$(read_ini_section "$CONFIG_FILE" "software" "packages")

echo "Provisioning $VM_NAME..."
echo "Memory: $VM_MEMORY MB"
echo "IP: $VM_IP"
echo "Packages: $PACKAGES"

# Clonage et configuration
# ... (même logique que précédemment)
```

### Configuration centralisée avec variables d'environnement

```bash
# cluster.env
export CLUSTER_NAME="WebCluster"
export TEMPLATE_VM="Ubuntu-Template"
export BASE_FOLDER="$HOME/VirtualBox VMs/Clusters"

export DEFAULT_MEMORY=2048
export DEFAULT_CPUS=2
export DEFAULT_VRAM=16

export NETWORK_NAME="WebClusterNet"
export NETWORK_SUBNET="10.0.20.0/24"
export NETWORK_GATEWAY="10.0.20.1"

export VM_USER="admin"
export VM_PASSWORD="SecurePassword123"

export PACKAGES="nginx curl vim git htop"
```

Utilisation :

```bash
#!/bin/bash

# Charger la configuration
source cluster.env

echo "Configuration du cluster $CLUSTER_NAME"
echo "Template: $TEMPLATE_VM"
echo "Réseau: $NETWORK_NAME ($NETWORK_SUBNET)"

# Provisioning avec les variables
for i in {1..3}; do
    VM_NAME="${CLUSTER_NAME}-Node-$(printf %02d $i)"
    
    VBoxManage clonevm "$TEMPLATE_VM" --name "$VM_NAME" --register
    VBoxManage modifyvm "$VM_NAME" \
      --memory $DEFAULT_MEMORY \
      --cpus $DEFAULT_CPUS
    
    # ... suite du provisioning
done
```

> [!tip] Sécurité des credentials Ne commitez jamais les fichiers `.env` contenant des mots de passe dans Git. Ajoutez-les au `.gitignore` :
> 
> ```bash
> echo "*.env" >> .gitignore
> echo "cluster.env" >> .gitignore
> ```

### Templates de scripts avec substitution

```bash
#!/bin/bash

# Générer un script de configuration à partir d'un template
generate_config_script() {
    local template_file=$1
    local output_file=$2
    local vm_name=$3
    local vm_ip=$4
    local vm_hostname=$5
    
    sed -e "s/{{VM_NAME}}/$vm_name/g" \
        -e "s/{{VM_IP}}/$vm_ip/g" \
        -e "s/{{VM_HOSTNAME}}/$vm_hostname/g" \
        "$template_file" > "$output_file"
}

# Template de configuration réseau
cat > network-template.sh << 'EOF'
#!/bin/bash
# Configuration réseau pour {{VM_NAME}}

cat > /etc/netplan/01-netcfg.yaml << NETPLAN
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
        - {{VM_IP}}/24
      gateway4: 10.0.20.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
NETPLAN

netplan apply
hostnamectl set-hostname {{VM_HOSTNAME}}
EOF

# Génération pour chaque VM
for i in {1..3}; do
    VM_NAME="WebServer-$(printf %02d $i)"
    VM_IP="10.0.20.$((10 + i))"
    VM_HOSTNAME="web$(printf %02d $i).cluster.local"
    
    generate_config_script \
        "network-template.sh" \
        "/tmp/config-${VM_NAME}.sh" \
        "$VM_NAME" \
        "$VM_IP" \
        "$VM_HOSTNAME"
    
    echo "✅ Script généré pour $VM_NAME"
done
```

### Fichier de configuration JSON

```json
{
  "cluster": {
    "name": "WebCluster",
    "template": "Ubuntu-Template",
    "base_folder": "/home/user/VirtualBox VMs/Clusters"
  },
  "defaults": {
    "memory": 2048,
    "cpus": 2,
    "vram": 16
  },
  "network": {
    "type": "natnetwork",
    "name": "WebClusterNet",
    "subnet": "10.0.20.0/24",
    "gateway": "10.0.20.1",
    "dns": ["8.8.8.8", "1.1.1.1"]
  },
  "vms": [
    {
      "name": "WebServer-01",
      "memory": 2048,
      "cpus": 2,
      "ip": "10.0.20.11",
      "hostname": "web01.cluster.local",
      "ports": {
        "ssh": 2201,
        "http": 8080,
        "https": 8443
      },
      "packages": ["nginx", "curl", "vim"],
      "services": ["nginx"]
    },
    {
      "name": "WebServer-02",
      "memory": 2048,
      "cpus": 2,
      "ip": "10.0.20.12",
      "hostname": "web02.cluster.local",
      "ports": {
        "ssh": 2202,
        "http": 8081,
        "https": 8444
      },
      "packages": ["nginx", "curl", "vim"],
      "services": ["nginx"]
    }
  ],
  "provisioning": {
    "scripts": [
      "scripts/setup-base.sh",
      "scripts/configure-nginx.sh",
      "scripts/deploy-app.sh"
    ],
    "files": [
      {
        "source": "configs/nginx.conf",
        "destination": "/etc/nginx/nginx.conf"
      },
      {
        "source": "configs/app.conf",
        "destination": "/etc/app/config.conf"
      }
    ]
  }
}
```

### Parser JSON avec jq

```bash
#!/bin/bash

CONFIG_FILE="cluster-config.json"

# Vérifier que jq est installé
if ! command -v jq &> /dev/null; then
    echo "❌ jq n'est pas installé. Installez-le avec: sudo apt install jq"
    exit 1
fi

# Lire la configuration globale
CLUSTER_NAME=$(jq -r '.cluster.name' "$CONFIG_FILE")
TEMPLATE=$(jq -r '.cluster.template' "$CONFIG_FILE")
NET_NAME=$(jq -r '.network.name' "$CONFIG_FILE")
NET_SUBNET=$(jq -r '.network.subnet' "$CONFIG_FILE")

echo "📋 Configuration du cluster: $CLUSTER_NAME"
echo "📦 Template: $TEMPLATE"
echo "🌐 Réseau: $NET_NAME ($NET_SUBNET)"
echo ""

# Créer le réseau NAT
VBoxManage natnetwork add \
  --netname "$NET_NAME" \
  --network "$NET_SUBNET" \
  --enable 2>/dev/null || echo "Réseau existant"

# Compter le nombre de VMs
VM_COUNT=$(jq '.vms | length' "$CONFIG_FILE")

# Boucle sur chaque VM
for i in $(seq 0 $((VM_COUNT - 1))); do
    echo "=========================================="
    
    # Extraire les détails de la VM
    VM_NAME=$(jq -r ".vms[$i].name" "$CONFIG_FILE")
    VM_MEMORY=$(jq -r ".vms[$i].memory" "$CONFIG_FILE")
    VM_CPUS=$(jq -r ".vms[$i].cpus" "$CONFIG_FILE")
    VM_IP=$(jq -r ".vms[$i].ip" "$CONFIG_FILE")
    VM_HOSTNAME=$(jq -r ".vms[$i].hostname" "$CONFIG_FILE")
    SSH_PORT=$(jq -r ".vms[$i].ports.ssh" "$CONFIG_FILE")
    HTTP_PORT=$(jq -r ".vms[$i].ports.http" "$CONFIG_FILE")
    
    echo "🚀 Provisioning de $VM_NAME"
    echo "   IP: $VM_IP"
    echo "   SSH: localhost:$SSH_PORT"
    echo "   HTTP: localhost:$HTTP_PORT"
    
    # Clonage
    VBoxManage clonevm "$TEMPLATE" --name "$VM_NAME" --register
    
    # Configuration matérielle
    VBoxManage modifyvm "$VM_NAME" \
      --memory "$VM_MEMORY" \
      --cpus "$VM_CPUS" \
      --macaddress1 auto
    
    # Configuration réseau
    VBoxManage modifyvm "$VM_NAME" \
      --nic1 natnetwork \
      --nat-network1 "$NET_NAME" \
      --natpf1 "ssh,tcp,,$SSH_PORT,,22" \
      --natpf1 "http,tcp,,$HTTP_PORT,,80"
    
    # Extraire et installer les packages
    PACKAGES=$(jq -r ".vms[$i].packages | join(\" \")" "$CONFIG_FILE")
    echo "   Packages: $PACKAGES"
    
    echo "✅ $VM_NAME configuré"
    echo ""
done

echo "🎉 Provisioning de $VM_COUNT VMs terminé !"
```

> [!info] Installation de jq `jq` est un processeur JSON en ligne de commande très puissant :
> 
> ```bash
> # Ubuntu/Debian
> sudo apt install jq
> 
> # macOS
> brew install jq
> ```

### Fichier Makefile pour automatiser

```makefile
# Makefile pour gestion de cluster VirtualBox

# Variables
CONFIG_FILE = cluster-config.json
TEMPLATE_VM = Ubuntu-Template
CLUSTER_NAME = WebCluster

# Cibles
.PHONY: all create start stop destroy status clean

all: create start

# Créer toutes les VMs
create:
	@echo "📋 Création du cluster depuis $(CONFIG_FILE)..."
	@./scripts/provision-from-json.sh $(CONFIG_FILE)

# Démarrer toutes les VMs
start:
	@echo "▶️  Démarrage du cluster $(CLUSTER_NAME)..."
	@VBoxManage list vms | grep "$(CLUSTER_NAME)" | cut -d'"' -f2 | while read vm; do \
		echo "Démarrage de $vm..."; \
		VBoxManage startvm "$vm" --type headless; \
	done

# Arrêter toutes les VMs
stop:
	@echo "⏸️  Arrêt du cluster $(CLUSTER_NAME)..."
	@VBoxManage list runningvms | grep "$(CLUSTER_NAME)" | cut -d'"' -f2 | while read vm; do \
		echo "Arrêt de $vm..."; \
		VBoxManage controlvm "$vm" acpipowerbutton; \
	done

# Détruire toutes les VMs
destroy:
	@echo "🗑️  Destruction du cluster $(CLUSTER_NAME)..."
	@read -p "Êtes-vous sûr ? [y/N] " confirm; \
	if [ "$confirm" = "y" ]; then \
		VBoxManage list vms | grep "$(CLUSTER_NAME)" | cut -d'"' -f2 | while read vm; do \
			echo "Suppression de $vm..."; \
			VBoxManage controlvm "$vm" poweroff 2>/dev/null || true; \
			VBoxManage unregistervm "$vm" --delete; \
		done; \
	fi

# Afficher le statut
status:
	@echo "📊 État du cluster $(CLUSTER_NAME):"
	@VBoxManage list vms | grep "$(CLUSTER_NAME)" || echo "Aucune VM trouvée"
	@echo ""
	@echo "VMs en cours d'exécution:"
	@VBoxManage list runningvms | grep "$(CLUSTER_NAME)" || echo "Aucune VM en cours"

# Nettoyer les fichiers temporaires
clean:
	@echo "🧹 Nettoyage des fichiers temporaires..."
	@rm -f /tmp/netconfig-*.sh
	@rm -f /tmp/config-*.sh
	@rm -f /tmp/index-*.html

# Créer un snapshot de toutes les VMs
snapshot:
	@echo "📸 Création de snapshots..."
	@VBoxManage list vms | grep "$(CLUSTER_NAME)" | cut -d'"' -f2 | while read vm; do \
		echo "Snapshot de $vm..."; \
		VBoxManage snapshot "$vm" take "snapshot-$(date +%Y%m%d-%H%M%S)"; \
	done

# Aide
help:
	@echo "Makefile pour gestion de cluster VirtualBox"
	@echo ""
	@echo "Cibles disponibles:"
	@echo "  make create    - Créer toutes les VMs du cluster"
	@echo "  make start     - Démarrer toutes les VMs"
	@echo "  make stop      - Arrêter toutes les VMs"
	@echo "  make destroy   - Détruire toutes les VMs"
	@echo "  make status    - Afficher l'état du cluster"
	@echo "  make snapshot  - Créer un snapshot de toutes les VMs"
	@echo "  make clean     - Nettoyer les fichiers temporaires"
```

Utilisation :

```bash
# Créer et démarrer le cluster
make all

# Afficher le statut
make status

# Arrêter le cluster
make stop

# Créer des snapshots
make snapshot

# Détruire le cluster
make destroy
```

> [!tip] Avantages du Makefile
> 
> - Interface simple et mémorisable
> - Cibles réutilisables
> - Gestion d'erreurs intégrée
> - Documentation via `make help`

### Gestion des secrets et credentials

Pour éviter de stocker des mots de passe en clair :

```bash
#!/bin/bash

# secrets.sh.example (template à copier en secrets.sh)
# NE PAS COMMITTER secrets.sh dans Git !

export VM_USER="admin"
export VM_PASSWORD="VotreMotDePasse"
export SSH_KEY_PATH="~/.ssh/cluster_rsa"
export API_TOKEN="your-api-token-here"
```

Script de provisioning sécurisé :

```bash
#!/bin/bash

# Charger les secrets
if [ -f "secrets.sh" ]; then
    source secrets.sh
else
    echo "❌ Fichier secrets.sh introuvable !"
    echo "Copiez secrets.sh.example vers secrets.sh et configurez vos credentials"
    exit 1
fi

# Vérifier que les variables sont définies
if [ -z "$VM_USER" ] || [ -z "$VM_PASSWORD" ]; then
    echo "❌ Variables VM_USER ou VM_PASSWORD non définies !"
    exit 1
fi

# Provisioning avec les credentials chargés
echo "🔐 Credentials chargés depuis secrets.sh"

# ... reste du script de provisioning
```

Configuration Git :

```bash
# .gitignore
secrets.sh
*.env
*.password
cluster.env
```

> [!warning] Sécurité **Ne commitez JAMAIS de mots de passe ou tokens dans Git !**
> 
> - Utilisez des fichiers `.env` ou `secrets.sh` exclus du contrôle de version
> - Fournissez des fichiers `.example` avec des valeurs fictives
> - Documentez clairement quelles variables doivent être configurées

### Configuration avancée : Infrastructure as Code

Exemple de structure complète de projet :

```
cluster-deployment/
├── configs/
│   ├── cluster-config.json       # Configuration principale
│   ├── network-config.yaml       # Configuration réseau
│   └── vm-definitions/           # Définitions individuelles
│       ├── webserver-01.ini
│       ├── webserver-02.ini
│       └── database-01.ini
├── scripts/
│   ├── provision.sh              # Script principal
│   ├── provision-from-json.sh    # Provisioning depuis JSON
│   ├── provision-from-yaml.sh    # Provisioning depuis YAML
│   ├── network-setup.sh          # Configuration réseau
│   └── lib/                      # Bibliothèques réutilisables
│       ├── parser.sh             # Fonctions de parsing
│       ├── vm-operations.sh      # Opérations VirtualBox
│       └── validation.sh         # Validation et tests
├── templates/
│   ├── network-config-template.sh
│   ├── nginx-config-template.conf
│   └── systemd-service-template.service
├── provisioning/
│   ├── base-setup.sh             # Configuration de base
│   ├── install-packages.sh       # Installation logiciels
│   └── configure-services.sh     # Configuration services
├── secrets.sh.example            # Template de secrets
├── Makefile                      # Automatisation
├── README.md                     # Documentation
└── .gitignore                    # Exclusions Git
```

### Script modulaire avec bibliothèques

```bash
#!/bin/bash
# scripts/provision.sh

# Charger les bibliothèques
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/parser.sh"
source "$SCRIPT_DIR/lib/vm-operations.sh"
source "$SCRIPT_DIR/lib/validation.sh"

# Charger les secrets
source "$SCRIPT_DIR/../secrets.sh"

# Charger la configuration
CONFIG_FILE="$SCRIPT_DIR/../configs/cluster-config.json"

# Valider la configuration
validate_config "$CONFIG_FILE"

# Extraire les informations
CLUSTER_NAME=$(get_json_value "$CONFIG_FILE" ".cluster.name")
TEMPLATE=$(get_json_value "$CONFIG_FILE" ".cluster.template")

# Créer le réseau
setup_network_from_config "$CONFIG_FILE"

# Provisionner les VMs
provision_vms_from_config "$CONFIG_FILE"

# Valider le déploiement
validate_cluster "$CLUSTER_NAME"

echo "✅ Déploiement terminé !"
```

```bash
# scripts/lib/vm-operations.sh

clone_vm() {
    local template=$1
    local vm_name=$2
    local folder=$3
    
    echo "📋 Clonage de $vm_name depuis $template..."
    
    VBoxManage clonevm "$template" \
      --name "$vm_name" \
      --basefolder "$folder" \
      --register
    
    if [ $? -eq 0 ]; then
        echo "✅ Clonage réussi"
        return 0
    else
        echo "❌ Échec du clonage"
        return 1
    fi
}

configure_vm_hardware() {
    local vm_name=$1
    local memory=$2
    local cpus=$3
    
    echo "⚙️  Configuration matérielle de $vm_name..."
    
    VBoxManage modifyvm "$vm_name" \
      --memory "$memory" \
      --cpus "$cpus" \
      --macaddress1 auto
}

configure_vm_network() {
    local vm_name=$1
    local network_name=$2
    local ssh_port=$3
    local http_port=$4
    
    echo "🌐 Configuration réseau de $vm_name..."
    
    VBoxManage modifyvm "$vm_name" \
      --nic1 natnetwork \
      --nat-network1 "$network_name" \
      --natpf1 "ssh,tcp,,$ssh_port,,22" \
      --natpf1 "http,tcp,,$http_port,,80"
}
```

### Logs et monitoring

```bash
#!/bin/bash

# Configuration des logs
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/provisioning-$(date +%Y%m%d-%H%M%S).log"

mkdir -p "$LOG_DIR"

# Fonction de logging
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO" "$@"
}

log_error() {
    log "ERROR" "$@"
}

log_success() {
    log "SUCCESS" "$@"
}

# Utilisation dans le script de provisioning
log_info "Début du provisioning du cluster"

for i in {1..3}; do
    VM_NAME="WebServer-$(printf %02d $i)"
    
    log_info "Provisioning de $VM_NAME..."
    
    if VBoxManage clonevm "Template" --name "$VM_NAME" --register; then
        log_success "$VM_NAME cloné avec succès"
    else
        log_error "Échec du clonage de $VM_NAME"
        continue
    fi
    
    # ... reste du provisioning
done

log_info "Provisioning terminé. Logs disponibles dans $LOG_FILE"
```

### Gestion des erreurs et rollback

```bash
#!/bin/bash

# Liste des VMs créées (pour rollback)
CREATED_VMS=()

# Fonction de nettoyage en cas d'erreur
cleanup_on_error() {
    echo ""
    echo "❌ Erreur détectée ! Rollback en cours..."
    
    for vm in "${CREATED_VMS[@]}"; do
        echo "🗑️  Suppression de $vm..."
        VBoxManage controlvm "$vm" poweroff 2>/dev/null || true
        VBoxManage unregistervm "$vm" --delete 2>/dev/null || true
    done
    
    echo "🧹 Rollback terminé"
    exit 1
}

# Configurer le trap pour attraper les erreurs
trap cleanup_on_error ERR

# Provisioning avec gestion d'erreur
set -e  # Arrêter le script en cas d'erreur

for i in {1..3}; do
    VM_NAME="WebServer-$(printf %02d $i)"
    
    echo "Provisioning de $VM_NAME..."
    
    # Clonage
    VBoxManage clonevm "Template" --name "$VM_NAME" --register
    CREATED_VMS+=("$VM_NAME")
    
    # Configuration
    VBoxManage modifyvm "$VM_NAME" --memory 2048 --cpus 2
    
    # Si une erreur se produit ici, cleanup_on_error sera appelé
    
    echo "✅ $VM_NAME provisionné"
done

# Désactiver le trap si tout s'est bien passé
trap - ERR

echo "🎉 Provisioning réussi de ${#CREATED_VMS[@]} VMs !"
```

> [!tip] Bonnes pratiques de gestion d'erreurs
> 
> - Utilisez `set -e` pour arrêter le script à la première erreur
> - Implémentez un système de rollback pour nettoyer en cas d'échec
> - Loguez toutes les opérations importantes
> - Validez les prérequis avant de commencer le provisioning

---

## 🎯 Pièges Courants et Bonnes Pratiques

### ⚠️ Pièges à éviter

1. **Adresses MAC identiques après clonage**
    
    ```bash
    # ❌ Mauvais : oublier de régénérer les MACs
    VBoxManage clonevm "Template" --name "VM1" --register
    
    # ✅ Bon : toujours régénérer
    VBoxManage clonevm "Template" --name "VM1" --register
    VBoxManage modifyvm "VM1" --macaddress1 auto
    ```
    
2. **Conflits d'adresses IP**
    
    - Toujours désactiver DHCP si vous utilisez des IPs statiques
    - Documenter le plan d'adressage IP
    - Valider qu'aucune IP n'est déjà utilisée
3. **Permissions insuffisantes pour Guest Control**
    
    ```bash
    # S'assurer que l'utilisateur a les droits sudo
    VBoxManage guestcontrol "VM" run /usr/bin/sudo -- apt update \
      --username user --password pass
    ```
    
4. **Oublier les Guest Additions**
    
    - Sans Guest Additions, `guestcontrol` ne fonctionnera pas
    - Toujours les installer dans le template avant clonage
5. **Ressources insuffisantes sur l'hôte**
    
    ```bash
    # Vérifier les ressources disponibles avant provisioning
    free -h  # Mémoire
    df -h    # Disque
    nproc    # CPUs
    ```
    

### ✅ Bonnes pratiques

1. **Toujours valider la configuration avant provisioning**
    
    ```bash
    # Vérifier que le template existe
    if ! VBoxManage list vms | grep -q "Template"; then
        echo "❌ Template introuvable !"
        exit 1
    fi
    ```
    
2. **Utiliser des noms significatifs et structurés**
    
    ```bash
    # ✅ Bon
    VM_NAME="${CLUSTER_NAME}-${ROLE}-$(printf %02d $i)"
    # Exemple : WebCluster-Frontend-01
    
    # ❌ Mauvais
    VM_NAME="vm$i"
    ```
    
3. **Documenter le plan d'infrastructure**
    
    ```markdown
    ## Infrastructure WebCluster
    
    | VM | IP | Rôle | Ports |
    |----|-------|------|-------|
    | WebServer-01 | 10.0.20.11 | Frontend | 8080, 2201 |
    | WebServer-02 | 10.0.20.12 | Frontend | 8081, 2202 |
    | Database-01 | 10.0.20.20 | Backend | 3306, 2210 |
    ```
    
4. **Créer des snapshots avant modifications importantes**
    
    ```bash
    # Snapshot avant mise à jour
    VBoxManage snapshot "WebServer-01" take "pre-update-$(date +%Y%m%d)"
    ```
    
5. **Automatiser la validation post-déploiement**
    
    ```bash
    # Tests automatisés après provisioning
    ./scripts/validate-cluster.sh
    ```
    
6. **Versionner vos configurations**
    
    ```bash
    git add configs/ scripts/
    git commit -m "feat: add 2 new web servers to cluster"
    git tag -a v1.2.0 -m "Production deployment v1.2.0"
    ```
    

---

## 🔥 Astuces Avancées

### Provisioning conditionnel

```bash
# Provisionner uniquement si la VM n'existe pas déjà
if ! VBoxManage list vms | grep -q "$VM_NAME"; then
    echo "Création de $VM_NAME..."
    VBoxManage clonevm "$TEMPLATE" --name "$VM_NAME" --register
else
    echo "⚠️  $VM_NAME existe déjà, passage..."
fi
```

### Mise à jour en place (sans recréer)

```bash
#!/bin/bash

# Mettre à jour une VM existante sans la recréer
update_vm() {
    local vm_name=$1
    
    echo "🔄 Mise à jour de $vm_name..."
    
    # S'assurer que la VM est démarrée
    VBoxManage startvm "$vm_name" --type headless 2>/dev/null || true
    sleep 30
    
    # Exécuter les mises à jour
    VBoxManage guestcontrol "$vm_name" run /usr/bin/sudo -- apt update \
      --username "$VM_USER" --password "$VM_PASSWORD"
    
    VBoxManage guestcontrol "$vm_name" run /usr/bin/sudo -- apt upgrade -y \
      --username "$VM_USER" --password "$VM_PASSWORD"
    
    echo "✅ $vm_name mis à jour"
}

# Mettre à jour toutes les VMs du cluster
for vm in WebServer-{01..03}; do
    update_vm "$vm"
done
```

### Export de métriques

```bash
#!/bin/bash

# Collecter des métriques sur les VMs
echo "VM,État,CPU,Mémoire (MB)" > cluster-metrics.csv

VBoxManage list vms | grep "WebServer" | cut -d'"' -f2 | while read vm; do
    # État
    if VBoxManage list runningvms | grep -q "$vm"; then
        STATE="Running"
    else
        STATE="Stopped"
    fi
    
    # Configuration
    CPU=$(VBoxManage showvminfo "$vm" | grep "Number of CPUs" | awk '{print $4}')
    MEMORY=$(VBoxManage showvminfo "$vm" | grep "Memory size" | awk '{print $3}')
    
    echo "$vm,$STATE,$CPU,$MEMORY" >> cluster-metrics.csv
done

echo "📊 Métriques exportées dans cluster-metrics.csv"
```

### Déploiement Blue-Green

```bash
#!/bin/bash

# Déploiement Blue-Green : créer un nouveau cluster sans supprimer l'ancien

BLUE_CLUSTER="WebCluster-Blue"
GREEN_CLUSTER="WebCluster-Green"

# Déterminer quel cluster est actif
if VBoxManage list runningvms | grep -q "$BLUE_CLUSTER"; then
    ACTIVE="Blue"
    NEW="Green"
    NEW_CLUSTER=$GREEN_CLUSTER
else
    ACTIVE="Green"
    NEW="Blue"
    NEW_CLUSTER=$BLUE_CLUSTER
fi

echo "📘 Cluster actif : $ACTIVE"
echo "🆕 Création du nouveau cluster : $NEW"

# Créer le nouveau cluster
for i in {1..3}; do
    VM_NAME="${NEW_CLUSTER}-$(printf %02d $i)"
    # ... provisioning
done

echo "✅ Nouveau cluster $NEW créé"
echo "🔄 Basculer le trafic vers $NEW puis arrêter $ACTIVE manuellement"
```

---

## 📚 Résumé

Le déploiement en masse avec VirtualBox CLI permet de :

- 🎯 **Créer rapidement des environnements identiques** via templates et clonage
- 🌐 **Automatiser la configuration réseau** avec NAT Network et IPs statiques
- 🏭 **Provisionner des infrastructures complètes** via des scripts intelligents
- 📝 **Gérer la configuration comme du code** avec YAML, JSON ou INI
- 🔄 **Maintenir et mettre à jour** facilement des clusters de VMs
- ✅ **Valider et monitorer** les déploiements automatiquement

**Points clés à retenir** :

- Utilisez des **linked clones** pour économiser de l'espace en développement
- Optez pour **NAT Network** pour des clusters qui doivent communiquer
- **Automatisez tout** : clonage, configuration, déploiement, validation
- **Versionnez vos configurations** comme du code applicatif
- **Implémentez des rollbacks** pour gérer les erreurs
- **Documentez votre infrastructure** : plan IP, ports, rôles

Le déploiement en masse transforme VirtualBox en une véritable plateforme d'Infrastructure as Code (IaC), permettant de gérer des dizaines de VMs aussi facilement qu'une seule !