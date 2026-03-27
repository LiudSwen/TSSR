# 

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

## 🎯 Options de démarrage

Les options de démarrage permettent de contrôler précisément comment et quand vos machines virtuelles démarrent, particulièrement important dans un environnement de production.

### Boot Order

Le boot order définit l'ordre dans lequel la VM tente de démarrer depuis différents périphériques.

> [!info] Pourquoi c'est important Le boot order détermine la séquence de démarrage de votre VM. Utile pour installer un OS depuis ISO, démarrer en mode rescue, ou optimiser le temps de démarrage en évitant la détection de périphériques inutiles.

#### Configuration via l'interface web

**Navigation :** VM → Options → Boot Order

Les périphériques disponibles :

- **disk (scsi0, virtio0, etc.)** : Disques virtuels
- **cdrom (ide2)** : Lecteur CD/DVD virtuel
- **network (net0)** : Boot PXE
- **efidisk** : Disque EFI (pour UEFI)

#### Configuration via CLI

```bash
# Afficher la configuration actuelle
qm config <vmid>

# Définir l'ordre de démarrage (disk en premier, puis cdrom)
qm set <vmid> --boot order=scsi0;ide2

# Boot uniquement depuis le disque (plus rapide)
qm set <vmid> --boot order=scsi0

# Boot réseau en premier (PXE boot)
qm set <vmid> --boot order=net0;scsi0
```

> [!example] Cas d'usage pratique
> 
> ```bash
> # Installation : ISO en premier
> qm set 100 --boot order=ide2;scsi0
> 
> # Après installation : disk seulement
> qm set 100 --boot order=scsi0
> ```

> [!tip] Astuce de performance Limitez le boot order aux périphériques strictement nécessaires. Une VM de production n'a généralement besoin que du disque principal, ce qui accélère le démarrage.

---

### Autostart

L'autostart permet aux VM de démarrer automatiquement lorsque le nœud Proxmox démarre.

> [!info] Pourquoi c'est important Essentiel pour les services critiques qui doivent être disponibles immédiatement après un redémarrage du serveur, comme des serveurs DNS, DHCP, ou des services d'infrastructure.

#### Configuration de base

**Via l'interface web :** VM → Options → Start at boot

**Via CLI :**

```bash
# Activer l'autostart
qm set <vmid> --onboot 1

# Désactiver l'autostart
qm set <vmid> --onboot 0

# Vérifier le statut
qm config <vmid> | grep onboot
```

---

### Delay et Priority

Ces paramètres contrôlent l'ordre et le timing du démarrage automatique des VM.

#### Startup Order (Priority)

Définit l'ordre de démarrage des VM (valeur plus basse = démarre en premier).

```bash
# VM prioritaire (démarre en premier)
qm set <vmid> --startup order=1

# VM normale
qm set <vmid> --startup order=10

# VM basse priorité
qm set <vmid> --startup order=100
```

#### Startup Delay

Temps d'attente (en secondes) avant de démarrer la VM suivante.

```bash
# Attendre 30 secondes avant de démarrer la VM suivante
qm set <vmid> --startup order=1,up=30

# Configuration complète : ordre, délai avant, délai après arrêt
qm set <vmid> --startup order=2,up=60,down=30
```

**Paramètres de startup :**

- **order** : Ordre de démarrage (1-10000)
- **up** : Délai en secondes avant de démarrer la VM suivante
- **down** : Délai en secondes après l'arrêt de cette VM

> [!example] Scénario d'infrastructure
> 
> ```bash
> # 1. Serveur de base de données (démarre en premier)
> qm set 100 --onboot 1 --startup order=1,up=60
> 
> # 2. Serveur d'application (attend que la DB soit prête)
> qm set 101 --onboot 1 --startup order=2,up=30
> 
> # 3. Serveur web (démarre en dernier)
> qm set 102 --onboot 1 --startup order=3,up=0
> ```

> [!warning] Attention aux dépendances Le délai `up` n'attend pas que les services soient réellement prêts, seulement que la VM ait démarré. Pour des dépendances complexes, utilisez des scripts de healthcheck dans vos VM.

> [!tip] Bonnes pratiques
> 
> - **Services d'infrastructure** (DNS, DHCP) : order=1-5
> - **Bases de données** : order=10-20
> - **Applications** : order=30-50
> - **Services frontend** : order=60+
> - Laissez 30-60 secondes de délai pour les services critiques

#### Vérifier la configuration globale

```bash
# Lister toutes les VM avec leur configuration de démarrage
for vm in $(qm list | awk 'NR>1 {print $1}'); do
  echo "VM $vm:"
  qm config $vm | grep -E "onboot|startup"
done
```

---

## ☁️ Cloud-init

Cloud-init est un outil de configuration automatique des VM au premier démarrage, largement utilisé dans les environnements cloud.

### Concept et utilité

> [!info] Qu'est-ce que Cloud-init ? Cloud-init est un standard de l'industrie pour l'initialisation des instances cloud. Il permet de configurer automatiquement les VM au premier démarrage : utilisateurs, réseau, clés SSH, packages, scripts personnalisés, etc.

**Avantages :**

- ✅ Configuration automatisée et reproductible
- ✅ Déploiement rapide de VM identiques
- ✅ Idéal pour l'Infrastructure as Code
- ✅ Support de la majorité des distributions Linux
- ✅ Configuration réseau dynamique

**Cas d'usage :**

- Déploiement de templates
- Environnements de développement standardisés
- Infrastructure éphémère
- Scaling horizontal

---

### Configuration

Cloud-init nécessite un support intégré dans l'image de la VM. La plupart des distributions modernes incluent cloud-init par défaut.

#### Activer Cloud-init

**Via l'interface web :** VM → Hardware → Add → CloudInit Drive

**Via CLI :**

```bash
# Créer un lecteur cloud-init (nécessaire avant toute configuration)
qm set <vmid> --ide2 local-lvm:cloudinit

# Ou sur un autre bus
qm set <vmid> --scsi2 local-lvm:cloudinit
```

> [!warning] Prérequis important Le lecteur Cloud-init doit être ajouté AVANT de pouvoir utiliser les paramètres cloud-init. C'est un disque virtuel spécial qui contient les métadonnées de configuration.

---

#### Paramètres disponibles

##### 1. Utilisateur et authentification

```bash
# Définir l'utilisateur par défaut
qm set <vmid> --ciuser username

# Ajouter un mot de passe (sera hashé)
qm set <vmid> --cipassword "SecurePassword123"

# Ajouter des clés SSH publiques
qm set <vmid> --sshkeys ~/.ssh/id_rsa.pub

# Ou directement depuis un fichier
qm set <vmid> --sshkeys /path/to/keys.pub
```

> [!tip] Sécurité des clés SSH Pour plusieurs clés, créez un fichier avec une clé par ligne :
> 
> ```bash
> cat > /tmp/ssh-keys.txt << EOF
> ssh-rsa AAAAB3NzaC1... user1@host
> ssh-ed25519 AAAAC3NzaC... user2@host
> EOF
> qm set <vmid> --sshkeys /tmp/ssh-keys.txt
> ```

##### 2. Configuration réseau

```bash
# Configuration IP statique
qm set <vmid> --ipconfig0 ip=192.168.1.100/24,gw=192.168.1.1

# Configuration DHCP
qm set <vmid> --ipconfig0 ip=dhcp

# Configuration IPv6
qm set <vmid> --ipconfig0 ip6=2001:db8::100/64,gw6=2001:db8::1

# Configuration dual-stack
qm set <vmid> --ipconfig0 ip=192.168.1.100/24,gw=192.168.1.1,ip6=dhcp

# Configuration multi-interfaces
qm set <vmid> --ipconfig0 ip=192.168.1.100/24,gw=192.168.1.1
qm set <vmid> --ipconfig1 ip=10.0.0.100/24
```

##### 3. DNS et hostname

```bash
# Configurer le hostname
qm set <vmid> --name web-server-01

# Configurer les serveurs DNS
qm set <vmid> --nameserver "8.8.8.8 8.8.4.4"

# Configurer le domaine de recherche
qm set <vmid> --searchdomain "example.com"

# Configuration complète
qm set <vmid> --name db-server \
  --nameserver "1.1.1.1 1.0.0.1" \
  --searchdomain "internal.example.com"
```

##### 4. Scripts personnalisés

Cloud-init peut exécuter des scripts au démarrage via des "user-data".

```bash
# Créer un fichier user-data
cat > /tmp/userdata.yml << 'EOF'
#cloud-config
package_update: true
package_upgrade: true
packages:
  - nginx
  - git
  - htop
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
  - echo "Hello from cloud-init" > /var/www/html/index.html
EOF

# Appliquer le user-data
qm set <vmid> --cicustom "user=local:snippets/userdata.yml"
```

> [!info] Stockage des snippets Les fichiers user-data doivent être stockés dans le répertoire snippets de votre stockage Proxmox. Par défaut : `/var/lib/vz/snippets/`

---

#### Configuration complète exemple

```bash
# VM ID
VMID=200

# Ajouter le lecteur cloud-init
qm set $VMID --ide2 local-lvm:cloudinit

# Configuration utilisateur
qm set $VMID --ciuser admin
qm set $VMID --cipassword "StrongP@ssw0rd"
qm set $VMID --sshkeys ~/.ssh/id_rsa.pub

# Configuration réseau
qm set $VMID --ipconfig0 ip=192.168.1.200/24,gw=192.168.1.1
qm set $VMID --nameserver "1.1.1.1 8.8.8.8"
qm set $VMID --searchdomain "lab.local"

# Hostname
qm set $VMID --name app-server-01

# Vérifier la configuration
qm cloudinit dump $VMID user
```

> [!example] Workflow complet avec template
> 
> ```bash
> # 1. Télécharger une image cloud
> wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
> 
> # 2. Créer une VM template
> qm create 9000 --name ubuntu-cloud-template --memory 2048 --net0 virtio,bridge=vmbr0
> qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm
> qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
> qm set 9000 --ide2 local-lvm:cloudinit
> qm set 9000 --boot c --bootdisk scsi0
> qm set 9000 --serial0 socket --vga serial0
> qm template 9000
> 
> # 3. Cloner et configurer avec cloud-init
> qm clone 9000 201 --name web-server-01
> qm set 201 --ciuser admin --sshkeys ~/.ssh/id_rsa.pub
> qm set 201 --ipconfig0 ip=192.168.1.201/24,gw=192.168.1.1
> qm start 201
> ```

---

### Template Cloud-init

Les templates cloud-init permettent de déployer rapidement des VM préconfigurées.

#### Structure d'un user-data avancé

```yaml
#cloud-config

# Mise à jour système
package_update: true
package_upgrade: true

# Installation de packages
packages:
  - docker.io
  - docker-compose
  - nginx
  - certbot
  - fail2ban

# Création d'utilisateurs supplémentaires
users:
  - name: deploy
    groups: sudo, docker
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1...

# Configuration de fichiers
write_files:
  - path: /etc/nginx/sites-available/default
    content: |
      server {
        listen 80;
        server_name _;
        location / {
          proxy_pass http://localhost:3000;
        }
      }
    permissions: '0644'
  
  - path: /usr/local/bin/deploy.sh
    content: |
      #!/bin/bash
      cd /opt/app
      git pull
      docker-compose up -d
    permissions: '0755'

# Commandes à exécuter
runcmd:
  - systemctl enable docker
  - systemctl start docker
  - usermod -aG docker deploy
  - systemctl enable nginx
  - systemctl start nginx
  - ufw allow 22/tcp
  - ufw allow 80/tcp
  - ufw allow 443/tcp
  - ufw --force enable

# Configuration timezone
timezone: Europe/Paris

# Configuration locale
locale: fr_FR.UTF-8

# Redémarrage si nécessaire
power_state:
  mode: reboot
  condition: True
```

#### Appliquer le template

```bash
# Copier le fichier dans le stockage snippets
cp userdata.yml /var/lib/vz/snippets/

# Appliquer à une VM
qm set <vmid> --cicustom "user=local:snippets/userdata.yml"
```

> [!tip] Templates réutilisables Créez une bibliothèque de snippets pour différents types de serveurs :
> 
> - `webserver.yml` : NGINX, Certbot, firewall
> - `database.yml` : PostgreSQL, backups automatiques
> - `docker.yml` : Docker, Docker Compose, portainer
> - `monitoring.yml` : Prometheus, Grafana, node-exporter

---

#### Commandes utiles

```bash
# Afficher la configuration cloud-init générée
qm cloudinit dump <vmid> user
qm cloudinit dump <vmid> network
qm cloudinit dump <vmid> meta

# Régénérer l'ISO cloud-init (après modification)
qm cloudinit update <vmid>

# Vérifier que cloud-init est présent dans la VM (depuis la VM)
cloud-init status
cloud-init status --long

# Voir les logs cloud-init (depuis la VM)
cat /var/log/cloud-init.log
cat /var/log/cloud-init-output.log

# Nettoyer cloud-init pour re-tester (depuis la VM)
cloud-init clean
cloud-init clean --logs
```

> [!warning] Pièges courants
> 
> - Cloud-init s'exécute **une seule fois** au premier démarrage. Pour ré-exécuter, il faut nettoyer avec `cloud-init clean` depuis la VM
> - Le lecteur cloud-init doit être configuré **avant** les paramètres cloud-init
> - Les modifications de configuration nécessitent un `qm cloudinit update` pour régénérer l'ISO
> - Les mots de passe en clair dans `--cipassword` sont hashés mais visibles dans la configuration Proxmox

---

## 🔌 Périphériques

Le passthrough permet de donner un accès direct à des périphériques physiques de l'hôte à une machine virtuelle, offrant des performances natives.

### USB Passthrough

L'USB passthrough permet de connecter des périphériques USB de l'hôte directement à une VM.

> [!info] Cas d'usage
> 
> - Clés USB ou disques externes
> - Dongles de licence matérielle
> - Lecteurs de cartes à puce
> - Périphériques de sécurité (YubiKey, etc.)
> - Imprimantes, scanners

#### Méthode 1 : Passthrough par port USB

Connecte un port USB physique entier (tout ce qui est branché dedans).

```bash
# Lister les contrôleurs et ports USB
lsusb -t

# Identifier le bus et port
lsusb
# Exemple de sortie :
# Bus 001 Device 003: ID 058f:6387 Alcor Micro Corp. Flash Drive

# Ajouter le périphérique USB à la VM (par bus et port)
qm set <vmid> --usb0 host=001-003

# Ou utiliser l'interface web : Hardware → Add → USB Device
```

**Format :** `host=BUS-PORT`

> [!tip] Avantage de cette méthode Si vous débranchez et rebranchez le périphérique sur le même port, il sera automatiquement reconnecté à la VM.

#### Méthode 2 : Passthrough par ID vendeur/produit

Connecte un périphérique USB spécifique, quel que soit le port.

```bash
# Identifier le Vendor ID et Product ID
lsusb | grep "nom_du_peripherique"
# Exemple : Bus 001 Device 003: ID 058f:6387 Alcor Micro Corp.
# VendorID = 058f, ProductID = 6387

# Ajouter le périphérique par ID
qm set <vmid> --usb0 host=058f:6387

# Avec l'option USB3 pour de meilleures performances
qm set <vmid> --usb0 host=058f:6387,usb3=1
```

**Format :** `host=VENDOR:PRODUCT`

> [!warning] Limitations
> 
> - Le périphérique ne peut être utilisé que par une seule VM à la fois
> - Le périphérique ne sera plus accessible sur l'hôte Proxmox
> - Nécessite que la VM soit arrêtée pour ajouter/retirer des périphériques USB

#### Configuration avancée

```bash
# USB avec support USB3 (plus rapide)
qm set <vmid> --usb0 host=058f:6387,usb3=1

# Plusieurs périphériques USB (jusqu'à usb4)
qm set <vmid> --usb0 host=001-003
qm set <vmid> --usb1 host=001-004
qm set <vmid> --usb2 host=046d:c52b  # Logitech Unifying Receiver

# Retirer un périphérique USB
qm set <vmid> --delete usb0
```

> [!example] Exemple pratique : Dongle de licence
> 
> ```bash
> # 1. Identifier le dongle
> lsusb | grep -i sentinel
> # Bus 001 Device 005: ID 0529:0001 Aladdin Knowledge Systems
> 
> # 2. L'assigner à la VM
> qm set 100 --usb0 host=0529:0001,usb3=1
> 
> # 3. Démarrer la VM
> qm start 100
> 
> # 4. Vérifier dans la VM (Linux)
> lsusb
> ```

---

### PCI Passthrough

Le PCI passthrough donne un accès direct à un périphérique PCI/PCIe, offrant des performances quasi-natives.

> [!info] Cas d'usage courants
> 
> - **Cartes graphiques** (GPU) pour calcul, gaming, transcoding
> - **Cartes réseau** dédiées pour routeurs/firewalls virtuels
> - **Contrôleurs RAID** ou HBA pour stockage haute performance
> - **Cartes son** professionnelles
> - **Cartes de capture** vidéo

> [!warning] Prérequis matériels
> 
> - CPU supportant la virtualisation IOMMU (Intel VT-d ou AMD-Vi)
> - Carte mère supportant IOMMU
> - IOMMU activé dans le BIOS/UEFI
> - Groupes IOMMU appropriés

---

#### Étape 1 : Activer IOMMU

##### Vérifier le support IOMMU

```bash
# Pour Intel
grep -E "vmx|svm" /proc/cpuinfo

# Vérifier IOMMU dans dmesg
dmesg | grep -e DMAR -e IOMMU
```

##### Activer IOMMU au boot

Éditez le fichier GRUB :

```bash
nano /etc/default/grub
```

**Pour Intel :**

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
```

**Pour AMD :**

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt"
```

Options supplémentaires utiles :

- `iommu=pt` : Mode passthrough pour de meilleures performances
- `pcie_acs_override=downstream,multifunction` : Séparation des groupes IOMMU (utiliser avec précaution)

Appliquer les changements :

```bash
# Mettre à jour GRUB
update-grub

# Redémarrer
reboot
```

---

#### Étape 2 : Configurer les modules VFIO

Chargez les modules nécessaires :

```bash
# Éditer la configuration des modules
nano /etc/modules

# Ajouter ces lignes
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
```

Appliquer immédiatement :

```bash
# Charger les modules
modprobe vfio
modprobe vfio_iommu_type1
modprobe vfio_pci
modprobe vfio_virqfd

# Vérifier que les modules sont chargés
lsmod | grep vfio
```

---

#### Étape 3 : Identifier les périphériques PCI

```bash
# Lister tous les périphériques PCI
lspci -nn

# Exemple de sortie pour une carte graphique :
# 01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA102 [GeForce RTX 3080] [10de:2206] (rev a1)
# 01:00.1 Audio device [0403]: NVIDIA Corporation GA102 High Definition Audio Controller [10de:1aef] (rev a1)

# Identifier les groupes IOMMU
find /sys/kernel/iommu_groups/ -type l | sort -n -t / -k 5

# Voir les périphériques d'un groupe spécifique
ls -l /sys/kernel/iommu_groups/*/devices/*
```

**Format de l'ID PCI :** `DOMAIN:BUS:DEVICE.FUNCTION` (ex: `0000:01:00.0`) **Format de l'ID vendeur/produit :** `VENDOR:DEVICE` (ex: `10de:2206`)

> [!info] Groupes IOMMU Les périphériques dans un même groupe IOMMU doivent être passés ensemble à la VM. Un groupe bien isolé ne contient que le périphérique souhaité.

---

#### Étape 4 : Blacklister les drivers de l'hôte

Pour éviter que l'hôte Proxmox utilise le périphérique :

```bash
# Éditer la blacklist
nano /etc/modprobe.d/blacklist.conf

# Pour une carte NVIDIA
blacklist nouveau
blacklist nvidia
blacklist nvidiafb

# Pour une carte AMD
blacklist radeon
blacklist amdgpu

# Pour une carte Intel
blacklist i915

# Appliquer
update-initramfs -u -k all
```

---

#### Étape 5 : Lier le périphérique à VFIO

```bash
# Créer le fichier de configuration VFIO
nano /etc/modprobe.d/vfio.conf

# Ajouter les IDs vendeur:produit (séparés par des virgules)
# Exemple pour une RTX 3080 (VGA + Audio)
options vfio-pci ids=10de:2206,10de:1aef

# Ou pour plusieurs périphériques
options vfio-pci ids=10de:2206,10de:1aef,8086:15b8

# Mettre à jour initramfs
update-initramfs -u -k all

# Redémarrer
reboot
```

Vérifier après redémarrage :

```bash
# Le driver doit être vfio-pci
lspci -nnk -d 10de:2206

# Exemple de sortie correcte :
# 01:00.0 VGA compatible controller [0300]: NVIDIA Corporation [10de:2206]
#   Kernel driver in use: vfio-pci
#   Kernel modules: nouveau
```

---

#### Étape 6 : Ajouter le périphérique à la VM

**Via l'interface web :** Hardware → Add → PCI Device → Sélectionner le périphérique

Options importantes :

- ☑️ **All Functions** : Passe toutes les fonctions du périphérique
- ☑️ **Primary GPU** : Utiliser comme GPU principal (désactive le VGA Proxmox)
- ☑️ **ROM-Bar** : Activer pour les GPU (requis pour le boot)
- ☑️ **PCI-Express** : Expose le périphérique comme PCIe natif

**Via CLI :**

```bash
# Ajouter un périphérique PCI
qm set <vmid> --hostpci0 0000:01:00.0

# Avec options (GPU principal, toutes fonctions, PCIe)
qm set <vmid> --hostpci0 0000:01:00.0,pcie=1,x-vga=1,rombar=1

# Plusieurs périphériques PCI
qm set <vmid> --hostpci0 0000:01:00.0,pcie=1
qm set <vmid> --hostpci1 0000:02:00.0

# Retirer un périphérique
qm set <vmid> --delete hostpci0
```

**Options hostpci :**

|Option|Description|
|---|---|
|`pcie=1`|Expose comme PCIe (meilleure compatibilité GPU)|
|`x-vga=1`|Défini comme GPU primaire|
|`rombar=1`|Active la ROM du périphérique (nécessaire pour GPU)|
|`romfile=xxx`|Spécifie un fichier ROM personnalisé|

---

#### Configuration VM pour GPU Passthrough

Pour un passthrough GPU optimal :

```bash
# Configuration machine type et BIOS
qm set <vmid> --machine q35
qm set <vmid> --bios ovmf

# Ajouter un disque EFI (requis pour OVMF)
qm set <vmid> --efidisk0 local-lvm:1,format=raw,efitype=4m,pre-enrolled-keys=1

# CPU (host pour meilleures performances)
qm set <vmid> --cpu host

# Ajouter le GPU
qm set <vmid> --hostpci0 0000:01:00,pcie=1,x-vga=1,rombar=1

# Désactiver le VGA Proxmox
qm set <vmid> --vga none

# Ou garder un VGA en série pour l'accès console
qm set <vmid> --serial0 socket --vga serial0
```

> [!example] Configuration complète GPU Passthrough
> 
> ```bash
> VMID=300
> 
> # Création VM
> qm create $VMID --name "Gaming-VM" --memory 16384 --cores 8 --cpu host
> 
> # Type machine et BIOS
> qm set $VMID --machine q35 --bios ovmf
> 
> # Disque EFI
> qm set $VMID --efidisk0 local-lvm:1,format=raw,efitype=4m
> 
> # Disque système
> qm set $VMID --scsi0 local-lvm:120,format=raw
> 
> # Réseau
> qm set $VMID --net0 virtio,bridge=vmbr0
> 
> # GPU Passthrough (NVIDIA RTX 3080 - VGA + Audio)
> qm set $VMID --hostpci0 0000:01:00,pcie=1,x-vga=1,rombar=1
> 
> # VGA en série pour console de secours
> qm set $VMID --serial0 socket --vga serial0
> ```

---

#### Dépannage PCI Passthrough

**Problème : "No IOMMU detected"**

```bash
# Vérifier que IOMMU est activé dans le BIOS
dmesg | grep -i iommu

# Vérifier la ligne de commande du kernel
cat /proc/cmdline
```

**Problème : "Device or resource busy"**

```bash
# Vérifier quel driver utilise le périphérique
lspci -nnk -d <vendor:device>

# Forcer l'unbind si nécessaire
echo "0000:01:00.0" > /sys/bus/pci/devices/0000:01:00.0/driver/unbind
```

**Problème : Écran noir avec GPU NVIDIA**

```bash
# Ajouter ces options au GPU dans la config VM
nano /etc/pve/qemu-server/<vmid>.conf

# Ajouter à la ligne hostpci0
args: -cpu host,kvm=off,hv_vendor_id=proxmox

# Ou via qm set
qm set <vmid> --args '-cpu host,kvm=off,hv_vendor_id=proxmox'
```

**Problème : Groupes IOMMU mal isolés**

```bash
# Option ACS Override (utiliser avec précaution)
nano /etc/default/grub

# Ajouter
GRUB_CMDLINE_LINUX_DEFAULT="... pcie_acs_override=downstream,multifunction"

update-grub && reboot
```

> [!warning] Sécurité et stabilité
> 
> - Le PCI passthrough contourne la couche de virtualisation et peut affecter la stabilité de l'hôte
> - Un périphérique passthrough mal configuré peut causer des kernel panics
> - Ne passez jamais le contrôleur de disque système de l'hôte
> - Testez dans un environnement de développement avant la production

> [!tip] Bonnes pratiques PCI Passthrough
> 
> - Privilégiez le passthrough de périphériques dans des groupes IOMMU isolés
> - Documentez les périphériques passthrough et leurs dépendances
> - Utilisez `machine=q35` pour le support PCIe moderne
> - Pour les GPU, utilisez OVMF (UEFI) plutôt que SeaBIOS
> - Gardez une interface console de secours (serial) en cas de problème GPU

---

## 📊 Limites de ressources

Les limites de ressources permettent de contrôler et restreindre l'utilisation des ressources système par les VM, essentiel pour le multi-tenancy et la stabilité.

### CPU Limits

Le CPU limit contrôle la quantité de temps CPU qu'une VM peut utiliser.

> [!info] Pourquoi limiter le CPU ?
> 
> - Empêcher qu'une VM monopolise les ressources CPU
> - Garantir un partage équitable entre VMs
> - Simuler des environnements avec ressources limitées
> - Contrôler les coûts dans un contexte de facturation

#### Configuration des limites CPU

```bash
# Définir une limite CPU (en unités, 1 = 100% d'un cœur)
qm set <vmid> --cpulimit 2

# Exemples :
# 0.5 = 50% d'un cœur
# 1 = 100% d'un cœur (1 cœur complet)
# 2 = 200% (2 cœurs complets)
# 4.5 = 450% (4 cœurs et demi)

# Retirer la limite
qm set <vmid> --cpulimit 0
```

**Via l'interface web :** VM → Options → CPU Limit

#### CPU Units (priorité relative)

Les CPU units définissent la priorité relative d'une VM dans la compétition pour le CPU (uniquement quand le CPU est surchargé).

```bash
# Définir les CPU units (défaut = 1024)
qm set <vmid> --cpuunits 2048

# VM haute priorité
qm set <vmid> --cpuunits 4096

# VM basse priorité
qm set <vmid> --cpuunits 512
```

**Comment ça fonctionne :**

- Si le CPU n'est pas saturé, toutes les VMs obtiennent ce qu'elles demandent
- Quand le CPU est saturé, les CPU units déterminent la proportion relative
- Une VM avec 2048 units aura 2× plus de CPU qu'une VM avec 1024 units

> [!example] Scénario de partage CPU
> 
> ```bash
> # VM Production (priorité haute)
> qm set 100 --cores 4 --cpuunits 4096
> 
> # VM Développement (priorité normale)
> qm set 101 --cores 4 --cpuunits 1024
> 
> # VM Test (priorité basse, limitée)
> qm set 102 --cores 2 --cpuunits 512 --cpulimit 1.5
> ```
> 
> Résultat : En cas de contention CPU, la VM 100 aura 4× plus de CPU que la VM 101, et 8× plus que la VM 102.

#### NUMA (Non-Uniform Memory Access)

Pour les serveurs multi-socket, NUMA optimise les performances en liant CPU et mémoire.

```bash
# Activer NUMA
qm set <vmid> --numa 1

# Désactiver NUMA
qm set <vmid> --numa 0
```

> [!tip] Quand utiliser NUMA
> 
> - Serveurs avec plusieurs sockets CPU physiques
> - VMs avec beaucoup de mémoire (>32GB)
> - Applications sensibles à la latence mémoire (bases de données)

---

### Memory Ballooning

Le memory ballooning permet de récupérer dynamiquement la mémoire inutilisée d'une VM pour la donner à d'autres.

> [!info] Comment fonctionne le ballooning Un driver spécial dans la VM (virtio-balloon) peut "gonfler" un balloon qui prend de la mémoire à la VM et la rend à l'hôte. Quand la VM a besoin de plus de mémoire, le balloon se "dégonfle".

#### Configuration de base

```bash
# Définir la mémoire minimum (en MB)
qm set <vmid> --balloon 2048

# La VM aura entre 'balloon' (min) et 'memory' (max)
qm set <vmid> --memory 8192 --balloon 2048
# Cette VM peut utiliser entre 2GB (min) et 8GB (max)

# Désactiver le ballooning (balloon = memory)
qm set <vmid> --balloon 0
```

**Via l'interface web :** VM → Hardware → Memory → Ballooning Device

#### Partage de mémoire (Shares)

Les memory shares déterminent la priorité relative quand la mémoire de l'hôte est sous pression.

```bash
# Définir les shares (défaut = 1000)
qm set <vmid> --shares 2000

# VM haute priorité (garde sa mémoire)
qm set <vmid> --shares 3000

# VM basse priorité (perd sa mémoire en premier)
qm set <vmid> --shares 500
```

> [!example] Configuration mémoire complète
> 
> ```bash
> # Base de données (priorité haute, pas de ballooning)
> qm set 100 --memory 16384 --balloon 0 --shares 3000
> 
> # Application (ballooning modéré)
> qm set 101 --memory 8192 --balloon 4096 --shares 1500
> 
> # Développement (ballooning agressif)
> qm set 102 --memory 8192 --balloon 1024 --shares 500
> ```

#### Monitoring du ballooning

```bash
# Voir l'utilisation mémoire actuelle
qm status <vmid> --verbose

# Depuis l'hôte : voir la mémoire réelle utilisée
cat /proc/<pid>/status | grep VmRSS

# Depuis la VM : voir la mémoire disponible
free -h
cat /proc/meminfo
```

> [!warning] Limitations du ballooning
> 
> - Nécessite le driver virtio-balloon dans la VM (installé par défaut sur Linux moderne)
> - Peut causer des swaps dans la VM si trop agressif
> - Ne fonctionne pas bien avec les applications qui allouent toute leur mémoire au démarrage
> - Windows nécessite les VirtIO drivers

> [!tip] Bonnes pratiques ballooning
> 
> - Pour les bases de données : désactivez le ballooning (`--balloon 0`)
> - Pour les serveurs de production : `balloon` = 75% de `memory`
> - Pour les environnements de dev/test : ballooning agressif acceptable
> - Surveillez le swap dans les VMs avec ballooning activé
> - N'utilisez pas de ballooning si l'hôte a suffisamment de RAM

---

### Disk I/O Throttling

Le throttling d'I/O limite la bande passante et les IOPS des disques virtuels.

> [!info] Pourquoi limiter les I/O disque ?
> 
> - Empêcher qu'une VM sature le stockage partagé
> - Garantir des performances prévisibles pour les VMs critiques
> - Simuler des environnements avec I/O limités
> - Respecter les SLA de stockage

#### Limites disponibles

|Paramètre|Description|Unité|
|---|---|---|
|`mbps_rd`|Débit lecture|MB/s|
|`mbps_wr`|Débit écriture|MB/s|
|`mbps`|Débit total (lecture + écriture)|MB/s|
|`iops_rd`|IOPS lecture|opérations/s|
|`iops_wr`|IOPS écriture|opérations/s|
|`iops`|IOPS total|opérations/s|

#### Configuration des limites I/O

```bash
# Limiter le débit total à 100 MB/s
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,mbps=100

# Limiter séparément lecture et écriture
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,mbps_rd=150,mbps_wr=50

# Limiter les IOPS
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,iops=1000

# Combiner débit et IOPS
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,mbps=100,iops=2000

# Limites complexes
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,mbps_rd=200,mbps_wr=100,iops_rd=5000,iops_wr=2000
```

#### I/O Thread

Active un thread dédié pour les I/O du disque (améliore les performances).

```bash
# Activer iothread pour un disque
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,iothread=1

# Désactiver
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,iothread=0
```

> [!tip] Quand utiliser iothread
> 
> - VMs avec charge I/O élevée
> - Bases de données
> - Serveurs de fichiers
> - Toute VM où les I/O sont un goulot d'étranglement

#### Cache Policy

Définit comment les I/O disque sont mis en cache.

```bash
# Cache modes disponibles
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,cache=none        # Pas de cache (le plus sûr)
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,cache=writethrough # Cache lecture seulement
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,cache=writeback   # Cache lecture + écriture (plus rapide)
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,cache=directsync  # Pas de cache, sync direct
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,cache=unsafe      # Pas de sync (DANGER, très rapide)
```

**Modes de cache :**

|Mode|Performance|Sécurité|Cas d'usage|
|---|---|---|---|
|`none`|Moyenne|★★★★★|Production, données critiques|
|`writethrough`|Bonne|★★★★☆|Bon compromis général|
|`writeback`|Excellente|★★★☆☆|Dev/test, performances prioritaires|
|`directsync`|Faible|★★★★★|Transactions critiques|
|`unsafe`|Maximale|★☆☆☆☆|Tests uniquement, jamais en prod|

> [!warning] Cache "unsafe" Le mode `cache=unsafe` ne garantit AUCUNE persistance des données. À utiliser UNIQUEMENT pour des tests de performance ou des VMs jetables. Risque de corruption de données en cas de crash.

#### Discard/TRIM Support

Active le support TRIM pour les SSD (libère l'espace supprimé).

```bash
# Activer discard/TRIM
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,discard=on

# Désactiver
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,discard=off
```

> [!tip] Quand activer discard
> 
> - Stockage sur SSD
> - Thin provisioning
> - VMs qui suppriment beaucoup de fichiers
> - Attention : léger impact sur les performances

---

#### Exemple de configuration complète par profil

**Profil Base de données (haute performance, sécurité maximale) :**

```bash
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,\
  iothread=1,\
  cache=none,\
  discard=on,\
  mbps_rd=500,mbps_wr=300,\
  iops_rd=10000,iops_wr=5000
```

**Profil Serveur Web (équilibré) :**

```bash
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,\
  iothread=1,\
  cache=writethrough,\
  discard=on,\
  mbps=200,\
  iops=3000
```

**Profil Développement (performance maximale) :**

```bash
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,\
  iothread=1,\
  cache=writeback,\
  discard=on,\
  mbps=300,\
  iops=5000
```

**Profil Partage limité (multi-tenant) :**

```bash
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,\
  cache=none,\
  mbps_rd=50,mbps_wr=30,\
  iops_rd=500,iops_wr=300
```

---

#### Monitoring des I/O

```bash
# Voir les statistiques I/O en temps réel (depuis l'hôte)
iostat -x 1

# Surveiller une VM spécifique
watch -n 1 "qm status <vmid> --verbose"

# Depuis la VM : surveiller les I/O
iotop
dstat -d
vmstat 1
```

#### Vérifier les limites appliquées

```bash
# Voir la configuration complète du disque
qm config <vmid> | grep scsi0

# Afficher toute la config de la VM
cat /etc/pve/qemu-server/<vmid>.conf
```

> [!tip] Stratégie de limitation progressive Pour déterminer les bonnes limites :
> 
> 1. Démarrez sans limites et mesurez l'utilisation réelle
> 2. Identifiez les pics et la moyenne
> 3. Définissez des limites à 120-150% de l'utilisation normale
> 4. Surveillez et ajustez selon les besoins
> 
> ```bash
> # Mesurer pendant 1 heure
> sar -d 1 3600 > disk_stats.log
> 
> # Analyser les résultats
> grep "Average:" disk_stats.log
> ```

> [!warning] Pièges courants avec l'I/O throttling
> 
> - Des limites trop basses causent des timeouts et des erreurs d'application
> - Les limites IOPS sont plus critiques que le débit pour les bases de données
> - Le cache `writeback` peut masquer les problèmes de performance réels
> - Testez toujours les limites avant de les appliquer en production
> - Les bursts d'I/O peuvent dépasser temporairement les limites

---

## 🎓 Récapitulatif

Ce cours a couvert les options avancées des machines virtuelles Proxmox :

### ✅ Options de démarrage

- Boot order pour contrôler la séquence de démarrage
- Autostart pour le démarrage automatique au boot de l'hôte
- Startup delay et priority pour orchestrer le démarrage de l'infrastructure

### ✅ Cloud-init

- Configuration automatisée des VM au premier démarrage
- Gestion des utilisateurs, réseau, et packages
- Templates réutilisables pour un déploiement rapide

### ✅ Périphériques

- USB passthrough pour connecter des périphériques USB physiques
- PCI passthrough pour des performances natives (GPU, cartes réseau, etc.)
- Configuration IOMMU et isolation des groupes

### ✅ Limites de ressources

- CPU limits et units pour contrôler l'utilisation CPU
- Memory ballooning pour l'optimisation dynamique de la mémoire
- Disk I/O throttling pour garantir des performances équitables

Ces fonctionnalités avancées vous permettent de créer des environnements virtualisés sophistiqués, performants et parfaitement adaptés à vos besoins spécifiques.

---

_Cours généré pour Obsidian - Proxmox VE_