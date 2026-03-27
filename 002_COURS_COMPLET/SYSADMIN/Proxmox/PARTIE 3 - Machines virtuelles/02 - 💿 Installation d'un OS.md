

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

## 📀 Montage de l'ISO

### Qu'est-ce qu'un ISO et pourquoi le monter ?

Une image ISO est un fichier contenant l'intégralité d'un système d'exploitation prêt à être installé. Dans Proxmox, monter une ISO revient à insérer un CD/DVD virtuel dans le lecteur de votre VM, permettant ainsi de démarrer sur l'installateur du système d'exploitation.

> [!info] Stockage des ISO dans Proxmox Les fichiers ISO doivent être stockés dans un espace de stockage Proxmox configuré pour accepter ce type de contenu (généralement `local` ou un stockage dédié).

### Télécharger et uploader une ISO

#### Via l'interface web

1. **Naviguer vers le stockage** : Dans l'arborescence de gauche, sélectionnez votre nœud Proxmox > `local (nom-du-noeud)` > `ISO Images`
    
2. **Uploader l'ISO** :
    
    - Cliquez sur `Upload`
    - Sélectionnez votre fichier ISO depuis votre ordinateur
    - Cliquez sur `Upload`

> [!tip] Téléchargement direct Vous pouvez aussi utiliser `Download from URL` pour télécharger directement une ISO depuis un lien HTTP/HTTPS, ce qui évite de passer par votre machine locale.

#### Via la ligne de commande (SSH)

```bash
# Se connecter au serveur Proxmox via SSH
ssh root@ip-du-serveur

# Naviguer vers le répertoire des ISO
cd /var/lib/vz/template/iso/

# Télécharger une ISO directement
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso

# Ou utiliser curl
curl -O https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso

# Vérifier la présence du fichier
ls -lh
```

> [!warning] Espace disque Vérifiez toujours l'espace disponible avant de télécharger une ISO, certaines peuvent être volumineuses (plusieurs Go).

### Attacher l'ISO à une VM

#### Pendant la création de la VM

Lors de la création d'une VM via l'assistant, l'étape "OS" vous permet de sélectionner directement l'ISO à utiliser :

1. Sélectionnez `Use CD/DVD disc image file (iso)`
2. Choisissez le stockage contenant vos ISO
3. Sélectionnez l'ISO dans la liste déroulante

#### Sur une VM existante

```bash
# Via l'interface web
1. Sélectionnez votre VM
2. Cliquez sur "Hardware"
3. Double-cliquez sur "CD/DVD Drive"
4. Sélectionnez l'ISO souhaitée
5. Cliquez sur "OK"
```

```bash
# Via la ligne de commande
qm set <VMID> --ide2 local:iso/nom-de-votre-iso.iso,media=cdrom

# Exemple concret
qm set 100 --ide2 local:iso/ubuntu-22.04.3-live-server-amd64.iso,media=cdrom
```

### Ordre de boot

Pour que la VM démarre sur l'ISO, il faut configurer l'ordre de boot :

1. Allez dans l'onglet `Options` de votre VM
2. Double-cliquez sur `Boot Order`
3. Cochez le lecteur CD/DVD (`ide2` ou `sata0` selon votre configuration)
4. Placez-le en première position avec les flèches
5. Validez

> [!tip] Boot temporaire Pour un boot unique sur ISO sans modifier l'ordre permanent, utilisez le bouton `Start` avec maintien du clic, puis sélectionnez `Start with media override`.

---

## 🪟 Installation Windows

### Préparation de l'installation

#### Télécharger l'ISO Windows

> [!info] Sources officielles Téléchargez toujours vos ISO Windows depuis le site officiel de Microsoft pour garantir l'authenticité et la sécurité.

- **Windows 11** : [microsoft.com/software-download/windows11](https://www.microsoft.com/software-download/windows11)
- **Windows 10** : [microsoft.com/software-download/windows10](https://www.microsoft.com/software-download/windows10)
- **Windows Server** : Via Visual Studio Subscriptions ou le portail entreprise Microsoft

#### ISO VirtIO pour les drivers

Windows nécessite des drivers spécifiques pour reconnaître les périphériques virtuels de Proxmox (disques VirtIO, carte réseau).

```bash
# Télécharger l'ISO VirtIO
cd /var/lib/vz/template/iso/
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
```

> [!warning] Drivers VirtIO obligatoires Sans les drivers VirtIO, Windows ne détectera pas le disque dur virtuel pendant l'installation si vous utilisez le bus SCSI ou VirtIO.

### Configuration recommandée de la VM

|Paramètre|Valeur recommandée|Justification|
|---|---|---|
|**Type d'OS**|Microsoft Windows|Active les optimisations spécifiques|
|**Version**|Selon votre Windows|Windows 10/11, Server 2019/2022...|
|**BIOS**|OVMF (UEFI)|Requis pour Windows 11, recommandé|
|**Machine**|q35|Architecture moderne, meilleur support|
|**SCSI Controller**|VirtIO SCSI single|Meilleures performances|
|**Disk Bus**|SCSI|Performances optimales|
|**Cache**|Write back|Bon compromis performance/sécurité|
|**Network Model**|VirtIO (paravirtualized)|Meilleures performances réseau|
|**CPU Type**|host|Expose toutes les instructions CPU|

> [!tip] TPM pour Windows 11 Windows 11 nécessite un module TPM 2.0. Dans Proxmox, ajoutez un TPM virtuel via `Hardware` > `Add` > `TPM State`.

### Processus d'installation

#### 1. Préparer les ISO nécessaires

```bash
# Attacher l'ISO Windows
qm set 100 --ide2 local:iso/Win11_English_x64.iso,media=cdrom

# Attacher l'ISO VirtIO en tant que second lecteur
qm set 100 --ide0 local:iso/virtio-win.iso,media=cdrom
```

Ou via l'interface web : ajoutez un second CD/DVD Drive dans `Hardware` > `Add` > `CD/DVD Drive`.

#### 2. Démarrer l'installation

1. **Démarrez la VM** et connectez-vous via la console
2. **Sélectionnez la langue**, le format horaire et le clavier
3. Cliquez sur `Install now`
4. **Entrez votre clé de produit** (ou `I don't have a product key`)
5. **Sélectionnez la version** de Windows à installer

#### 3. Charger les drivers VirtIO (étape critique)

Lorsque l'installateur demande où installer Windows :

1. Si aucun disque n'apparaît, cliquez sur `Load driver`
2. Cliquez sur `Browse`
3. Naviguez vers le lecteur contenant l'ISO VirtIO
4. Sélectionnez le dossier correspondant :
    - **Windows 11/10** : `E:\vioscsi\w10\amd64\` (ou w11)
    - **Windows Server 2022** : `E:\vioscsi\2k22\amd64\`
5. Cliquez sur `OK` puis `Next`
6. Le disque VirtIO devrait maintenant apparaître

> [!example] Structure de l'ISO VirtIO
> 
> ```
> virtio-win.iso
> ├── vioscsi/     # Driver de stockage SCSI
> ├── NetKVM/      # Driver réseau
> ├── viostor/     # Driver de stockage (ancien)
> ├── Balloon/     # Driver de ballooning mémoire
> └── guest-agent/ # Agent invité
> ```

#### 4. Continuer l'installation

1. **Sélectionnez votre disque** et cliquez sur `Next`
2. L'installation se déroule (15-30 minutes)
3. La VM redémarre plusieurs fois automatiquement
4. **Configurez Windows** : nom d'utilisateur, réseau, confidentialité...

> [!warning] Retirer l'ISO après installation Une fois Windows installé, pensez à retirer l'ISO Windows du lecteur virtuel pour éviter que la VM ne redémarre dessus.

### Installation des drivers VirtIO restants

Une fois Windows démarré :

1. **Ouvrez l'Explorateur de fichiers**
2. Double-cliquez sur le lecteur contenant l'ISO VirtIO
3. Lancez `virtio-win-gt-x64.exe` ou `virtio-win-guest-tools.exe`
4. Suivez l'assistant d'installation
5. Redémarrez la VM

Cela installera tous les drivers manquants : réseau, ballooning, services invités...

> [!tip] Vérification des drivers Ouvrez le Gestionnaire de périphériques (devmgmt.msc) pour vérifier qu'aucun périphérique n'a un point d'exclamation jaune.

### Optimisations post-installation

#### Désactiver Hyper-V (si non utilisé)

```powershell
# Dans PowerShell en tant qu'administrateur
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

Cela évite les conflits de virtualisation imbriquée si vous n'en avez pas besoin.

#### Activer le bureau à distance

```powershell
# Activer RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0

# Autoriser RDP dans le pare-feu
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

---

## 🐧 Installation Linux

### Choix de la distribution

Les distributions Linux les plus courantes dans Proxmox :

|Distribution|Usage typique|Particularités|
|---|---|---|
|**Ubuntu Server**|Usage général, facilité|LTS : support 5 ans|
|**Debian**|Stabilité maximale|Base de Proxmox lui-même|
|**Rocky Linux / AlmaLinux**|Serveurs d'entreprise|Clone RHEL, très stable|
|**Arch Linux**|Utilisateurs avancés|Rolling release, dernier kernel|
|**Alpine Linux**|Conteneurs, minimalisme|Très léger (quelques Mo)|

> [!tip] Template ou Container ? Pour Linux, considérez aussi l'utilisation de conteneurs LXC qui sont plus légers que les VM complètes. Nous ne les détaillons pas ici car ils appartiennent à une autre partie du cours.

### Configuration recommandée de la VM

|Paramètre|Valeur recommandée|Justification|
|---|---|---|
|**Type d'OS**|Linux|Active les optimisations|
|**Version**|Selon votre distribution|6.x kernel, 5.x kernel, etc.|
|**BIOS**|SeaBIOS ou OVMF|SeaBIOS pour la compatibilité|
|**Machine**|q35 ou i440fx|i440fx pour les anciennes distributions|
|**SCSI Controller**|VirtIO SCSI single|Performances optimales|
|**Disk Bus**|VirtIO Block|Natif sous Linux|
|**Network Model**|VirtIO (paravirtualized)|Support natif du kernel|
|**CPU Type**|host|Performances maximales|

> [!info] Drivers VirtIO sous Linux Contrairement à Windows, les drivers VirtIO sont intégrés nativement dans le kernel Linux moderne (> 2.6.25). Aucune ISO supplémentaire n'est nécessaire.

### Installation Ubuntu Server (exemple détaillé)

#### 1. Télécharger et monter l'ISO

```bash
# Télécharger Ubuntu Server 22.04 LTS
cd /var/lib/vz/template/iso/
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso

# Attacher à la VM
qm set 101 --ide2 local:iso/ubuntu-22.04.3-live-server-amd64.iso,media=cdrom
```

#### 2. Démarrer et installer

1. **Démarrez la VM** et connectez-vous à la console
2. Sélectionnez `Try or Install Ubuntu Server`
3. **Choisissez la langue** : English (recommandé pour les serveurs)
4. **Mise à jour de l'installateur** : Si proposé, acceptez
5. **Configuration clavier** : Sélectionnez votre layout

#### 3. Configuration réseau

L'installateur Ubuntu détecte automatiquement la carte réseau VirtIO.

- **DHCP** : Laissez par défaut si vous voulez une IP automatique
- **IP statique** : Sélectionnez la carte réseau, choisissez `Edit IPv4`, puis `Manual`

```
Subnet: 192.168.1.0/24
Address: 192.168.1.50
Gateway: 192.168.1.1
Name servers: 8.8.8.8,1.1.1.1
Search domains: (vide ou votre domaine)
```

#### 4. Configuration du proxy (optionnel)

Laissez vide si vous n'utilisez pas de proxy.

#### 5. Miroir d'archive

Laissez le miroir par défaut ou sélectionnez-en un proche géographiquement pour accélérer les téléchargements.

#### 6. Partitionnement du disque

**Option 1 : Automatique (recommandé pour débuter)**

- Sélectionnez `Use an entire disk`
- Choisissez votre disque virtuel
- Laissez `Set up this disk as an LVM group` coché

**Option 2 : Manuel (utilisateurs avancés)**

|Partition|Taille|Type|Point de montage|
|---|---|---|---|
|`/boot`|1 Go|ext4|/boot|
|`/`|20-50 Go|ext4 ou btrfs|/|
|`swap`|2-4 Go|swap|-|
|`/home`|Reste|ext4 ou btrfs|/home|

> [!tip] LVM recommandé Utiliser LVM permet de redimensionner facilement les partitions ultérieurement sans redémarrage.

#### 7. Configuration du profil

```
Your name: Administrateur Système
Your server's name: ubuntu-vm-01
Pick a username: admin
Choose a password: ******************
Confirm your password: ******************
```

> [!warning] Sécurité du mot de passe Utilisez un mot de passe robuste (12+ caractères, majuscules, minuscules, chiffres, symboles).

#### 8. Configuration SSH

- Cochez `Install OpenSSH server`
- **Import SSH identity** : Depuis GitHub/Launchpad (optionnel) ou `No` pour configurer manuellement plus tard

> [!tip] Sécuriser SSH dès l'installation Si vous importez une clé SSH, la connexion par mot de passe sera automatiquement désactivée pour plus de sécurité.

#### 9. Snaps populaires (optionnel)

Laissez décoché si vous préférez installer les paquets manuellement via `apt`.

#### 10. Installation en cours

L'installation se déroule (10-20 minutes selon la connexion). Une fois terminée :

- Sélectionnez `Reboot Now`
- Retirez l'ISO du lecteur virtuel

### Installation Debian (différences notables)

Debian utilise un installateur différent (d'installer) mais les concepts sont similaires :

1. **Choisissez** : `Install` (ou `Graphical install`)
2. **Langue, localisation, clavier**
3. **Nom de la machine** : debian-vm-01
4. **Domaine** : (vide ou votre domaine local)
5. **Mot de passe root** : À définir ou laisser vide pour utiliser sudo
6. **Utilisateur non-privilégié** : nom, identifiant, mot de passe
7. **Partitionnement** : Similaire à Ubuntu
8. **Miroir Debian** : Sélectionnez un miroir proche
9. **Sondage de popularité** : `Yes` ou `No` selon préférence
10. **Sélection des logiciels** :
    - [x] SSH server (indispensable pour un serveur)
    - [x] Standard system utilities
    - [ ] Desktop environment (sauf si besoin d'interface graphique)

### Installation CentOS/Rocky Linux/AlmaLinux (différences)

Ces distributions basées sur RHEL utilisent Anaconda comme installateur :

1. **Sélection de la langue**
2. **Résumé de l'installation** : Interface centralisée avec toutes les options
3. **Réseau et nom d'hôte** : Activez la carte réseau et configurez l'IP
4. **Installation source** : Local media (ISO)
5. **Sélection des logiciels** : `Server` ou `Minimal Install`
6. **Destination de l'installation** : Partitionnement automatique ou personnalisé
7. **Commencer l'installation**
8. **Définir le mot de passe root** pendant l'installation
9. **Créer un utilisateur** avec droits administrateur
10. **Redémarrer** une fois terminé

> [!info] Différence SELinux Ces distributions activent SELinux par défaut, un système de sécurité obligatoire. Familiarisez-vous avec les commandes `getenforce`, `setenforce`, et `audit2allow`.

### Post-installation Linux (toutes distributions)

#### Mise à jour du système

```bash
# Ubuntu/Debian
sudo apt update
sudo apt upgrade -y

# Rocky/AlmaLinux/CentOS
sudo dnf update -y

# Arch Linux
sudo pacman -Syu
```

#### Configuration du réseau statique (si besoin)

**Ubuntu/Debian (Netplan)**

```bash
# Éditer la configuration Netplan
sudo nano /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens18:  # Nom de votre interface
      dhcp4: no
      addresses:
        - 192.168.1.50/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

```bash
# Appliquer la configuration
sudo netplan apply
```

**Rocky/AlmaLinux (NetworkManager)**

```bash
# Définir l'IP statique
sudo nmcli con mod ens18 ipv4.addresses 192.168.1.50/24
sudo nmcli con mod ens18 ipv4.gateway 192.168.1.1
sudo nmcli con mod ens18 ipv4.dns "8.8.8.8 1.1.1.1"
sudo nmcli con mod ens18 ipv4.method manual

# Redémarrer la connexion
sudo nmcli con down ens18 && sudo nmcli con up ens18
```

#### Configurer le hostname

```bash
# Toutes distributions avec systemd
sudo hostnamectl set-hostname votre-nom-de-machine

# Vérifier
hostnamectl
```

#### Configurer le fuseau horaire

```bash
# Lister les fuseaux disponibles
timedatectl list-timezones

# Définir le fuseau
sudo timedatectl set-timezone Europe/Paris

# Vérifier
timedatectl
```

#### Synchronisation NTP (horloge)

```bash
# Ubuntu/Debian
sudo apt install systemd-timesyncd -y
sudo systemctl enable --now systemd-timesyncd

# Rocky/AlmaLinux
sudo dnf install chrony -y
sudo systemctl enable --now chronyd

# Vérifier la synchronisation
timedatectl
```

---

## 🔧 Drivers et agents (qemu-guest-agent)

### Qu'est-ce que QEMU Guest Agent ?

Le **QEMU Guest Agent** (qemu-ga) est un daemon qui s'exécute à l'intérieur de la VM et communique avec l'hyperviseur Proxmox. Il permet des opérations avancées qui ne sont pas possibles depuis l'extérieur de la VM.

### Fonctionnalités apportées par l'agent

|Fonctionnalité|Sans agent|Avec agent|
|---|---|---|
|**Shutdown propre**|ACPI (parfois ignoré)|Signal direct au système|
|**IP de la VM**|Invisible depuis Proxmox|Affichée dans l'interface|
|**Snapshot quiescé**|Risque d'incohérence|Freeze FS, cohérence garantie|
|**Heure synchronisée**|Peut dériver|Synchronisation automatique|
|**Exécution de commandes**|Impossible|Possible (API)|
|**Informations système**|Limitées|Complètes (hostname, OS, etc.)|

> [!warning] Agent indispensable pour les snapshots Sans l'agent, les snapshots peuvent capturer la VM dans un état incohérent (fichiers partiellement écrits), causant des corruptions.

### Installation sous Linux

#### Ubuntu/Debian

```bash
# Installation
sudo apt update
sudo apt install qemu-guest-agent -y

# Démarrer et activer le service
sudo systemctl start qemu-guest-agent
sudo systemctl enable qemu-guest-agent

# Vérifier le statut
sudo systemctl status qemu-guest-agent
```

#### Rocky Linux/AlmaLinux/CentOS

```bash
# Installation
sudo dnf install qemu-guest-agent -y

# Démarrer et activer le service
sudo systemctl start qemu-guest-agent
sudo systemctl enable qemu-guest-agent

# Vérifier le statut
sudo systemctl status qemu-guest-agent
```

#### Arch Linux

```bash
# Installation
sudo pacman -S qemu-guest-agent

# Démarrer et activer le service
sudo systemctl start qemu-guest-agent
sudo systemctl enable qemu-guest-agent
```

> [!tip] Agent préinstallé Sur certaines distributions Cloud, l'agent est préinstallé mais non activé. Vérifiez avec `systemctl status qemu-guest-agent` avant d'installer.

### Installation sous Windows

L'agent Windows est inclus dans l'ISO VirtIO que nous avons utilisé pour l'installation.

#### Via l'interface graphique

1. **Montez l'ISO VirtIO** sur la VM Windows
2. Ouvrez l'Explorateur de fichiers
3. Naviguez vers le lecteur VirtIO
4. Allez dans le dossier `guest-agent`
5. Exécutez `qemu-ga-x86_64.msi` (ou x86 pour un système 32 bits)
6. Suivez l'assistant d'installation
7. Le service démarre automatiquement

#### Via la ligne de commande (PowerShell)

```powershell
# Monter l'ISO VirtIO (depuis Proxmox)
# Puis dans Windows :

# Installer silencieusement
msiexec /i E:\guest-agent\qemu-ga-x86_64.msi /qn /norestart

# Vérifier le service
Get-Service QEMU-GA
```

> [!example] Sortie attendue
> 
> ```
> Status   Name               DisplayName
> ------   ----               -----------
> Running  QEMU-GA            QEMU Guest Agent
> ```

### Activation de l'agent dans Proxmox

Même après l'installation dans la VM, l'agent doit être activé côté Proxmox.

#### Via l'interface web

1. Sélectionnez votre VM
2. Allez dans l'onglet `Options`
3. Double-cliquez sur `QEMU Guest Agent`
4. Cochez `Use QEMU Guest Agent`
5. Cliquez sur `OK`
6. **Redémarrez la VM** pour que les changements prennent effet

#### Via la ligne de commande

```bash
# Activer l'agent
qm set <VMID> --agent enabled=1

# Exemple
qm set 100 --agent enabled=1

# Avec options avancées
qm set 100 --agent enabled=1,fstrim_cloned_disks=1
```

**Options disponibles :**

- `enabled=1` : Active l'agent
- `fstrim_cloned_disks=1` : Exécute fstrim après le clonage d'un disque
- `type=virtio` : Type de périphérique (virtio par défaut)

### Vérification du fonctionnement

#### Depuis Proxmox (interface web)

Une fois l'agent activé et la VM redémarrée :

1. Allez dans l'onglet `Summary` de votre VM
2. Vérifiez que l'**adresse IP** s'affiche
3. Le **hostname** devrait également apparaître
4. Dans l'onglet `Monitor`, vous pouvez voir plus d'informations système

#### Depuis la ligne de commande Proxmox

```bash
# Envoyer une commande ping à l'agent
qm agent <VMID> ping

# Obtenir les informations réseau
qm agent <VMID> network-get-interfaces

# Obtenir les informations système
qm agent <VMID> get-osinfo

# Obtenir l'heure de la VM
qm agent <VMID> get-time

# Exemples concrets
qm agent 100 ping
qm agent 100 get-osinfo
```

> [!example] Sortie de `qm agent 100 get-osinfo`
> 
> ```json
> {
>    "id" : "ubuntu",
>    "kernel-release" : "5.15.0-78-generic",
>    "kernel-version" : "#85-Ubuntu SMP...",
>    "machine" : "x86_64",
>    "name" : "Ubuntu",
>    "pretty-name" : "Ubuntu 22.04.3 LTS",
>    "version" : "22.04 (Jammy Jellyfish)",
>    "version-id" : "22.04"
> }
> ```

### Utilisation avancée de l'agent

#### Arrêt propre de la VM

```bash
# Avec l'agent, l'arrêt est beaucoup plus propre
qm shutdown <VMID>

# L'agent transmet le signal d'arrêt au système d'exploitation
# qui peut fermer proprement tous les services
```

#### Exécution de commandes dans la VM (API)

```bash
# Exécuter une commande simple
qm guest exec <VMID> -- <commande>

# Exemple : lister les processus
qm guest exec 100 -- ps aux

# Exemple : obtenir l'uptime
qm guest exec 100 -- uptime
```

> [!warning] Sécurité des commandes L'exécution de commandes via l'agent nécessite des permissions root côté Proxmox. Soyez prudent avec cette fonctionnalité.

#### Snapshots avec freeze du système de fichiers

Lorsque l'agent est actif, Proxmox peut demander au système de fichiers de se "figer" momentanément pendant la création d'un snapshot, garantissant la cohérence des données.

```bash
# Créer un snapshot (l'agent freeze automatiquement le FS)
qm snapshot <VMID> nom_du_snapshot --description "Description"

# Exemple
qm snapshot 100 avant_mise_a_jour --description "Avant upgrade kernel"
```

> [!info] Freeze du système de fichiers Le freeze est géré automatiquement par l'agent lors d'un snapshot. Aucune commande spéciale n'est nécessaire.

### Dépannage de l'agent

#### L'agent ne répond pas

**Vérifications côté VM :**

```bash
# Linux : vérifier le service
sudo systemctl status qemu-guest-agent

# Si arrêté, le redémarrer
sudo systemctl restart qemu-guest-agent

# Windows : vérifier le service
Get-Service QEMU-GA
Start-Service QEMU-GA
```

**Vérifications côté Proxmox :**

```bash
# Vérifier que l'agent est activé
qm config <VMID> | grep agent

# Devrait afficher : agent: 1

# Si absent, activer
qm set <VMID> --agent enabled=1
```

#### L'IP n'apparaît pas dans Proxmox

1. Vérifiez que l'agent est bien installé et démarré dans la VM
2. Vérifiez que l'option est activée dans Proxmox
3. Redémarrez la VM
4. Attendez 30-60 secondes que les informations remontent
5. Rafraîchissez la page web de Proxmox

#### L'agent ne démarre pas au boot (Linux)

```bash
# Réactiver le service
sudo systemctl enable qemu-guest-agent

# Vérifier qu'il est bien dans la liste des services activés
sudo systemctl list-unit-files | grep qemu-guest-agent
```

### Comparaison avec d'autres agents

|Agent|Système|Fonctions|Quand l'utiliser ?|
|---|---|---|---|
|**qemu-guest-agent**|Linux/Windows|Communication hyperviseur, snapshots, infos|**Toujours recommandé**|
|**VMware Tools**|VMware uniquement|Similaire à qemu-ga|Si vous êtes sur VMware|
|**VirtualBox Guest Additions**|VirtualBox uniquement|Similaire à qemu-ga|Si vous êtes sur VirtualBox|
|**cloud-init**|Linux|Provisioning initial (config réseau, users)|Pour les images cloud, complémentaire à qemu-ga|

> [!info] Complémentarité Cloud-init et qemu-guest-agent ne sont pas mutuellement exclusifs. Cloud-init sert au provisioning initial (première configuration), tandis que qemu-ga gère la communication continue avec l'hyperviseur.

### Bonnes pratiques avec l'agent

#### ✅ À faire

- **Installer l'agent systématiquement** sur toutes vos VM de production
- **Activer l'agent dans Proxmox** après l'installation dans la VM
- **Vérifier le fonctionnement** avec `qm agent <VMID> ping` après chaque installation
- **Utiliser les snapshots** avec l'agent activé pour garantir la cohérence des données
- **Mettre à jour l'agent** avec les mises à jour système régulières
- **Documenter** dans vos templates/procédures que l'agent doit être installé

#### ❌ À éviter

- Ne pas installer l'agent sur des VM de production (risque d'incohérence des snapshots)
- Désactiver l'agent sans raison valable
- Oublier de redémarrer la VM après activation de l'agent dans Proxmox
- Utiliser des versions obsolètes de l'agent (problèmes de compatibilité)
- Compter uniquement sur ACPI pour arrêter les VM (moins fiable)

### Cas d'usage avancés

#### Automatisation avec l'agent

L'agent permet d'automatiser certaines tâches via l'API Proxmox :

```bash
# Script de vérification automatique de l'état des VM
#!/bin/bash

for vmid in $(qm list | awk 'NR>1 {print $1}'); do
    echo "=== VM $vmid ==="
    qm agent $vmid ping 2>/dev/null && echo "Agent: OK" || echo "Agent: NOK"
    qm agent $vmid get-osinfo 2>/dev/null | grep "pretty-name" || echo "OS info: unavailable"
    echo ""
done
```

#### Snapshots avant mise à jour automatisée

```bash
#!/bin/bash
# Script de mise à jour sécurisée avec snapshot

VMID=$1
SNAP_NAME="avant_update_$(date +%Y%m%d_%H%M%S)"

# Créer un snapshot (l'agent freeze le FS automatiquement)
qm snapshot $VMID $SNAP_NAME --description "Snapshot automatique avant mise à jour"

# Exécuter la mise à jour dans la VM
qm guest exec $VMID -- apt update
qm guest exec $VMID -- apt upgrade -y

# Si erreur, possibilité de rollback
# qm rollback $VMID $SNAP_NAME
```

> [!tip] Snapshots et sauvegardes Les snapshots ne remplacent pas les sauvegardes complètes. Ils sont parfaits pour les tests et les retours arrière rapides, mais doivent être complétés par des backups réguliers.

### Alternatives et solutions de secours

#### Si l'agent ne peut pas être installé

Dans de rares cas (systèmes très anciens, OS exotiques), l'agent peut ne pas être disponible :

**Alternatives partielles :**

1. **Activer ACPI Shutdown** : Configuration par défaut, moins fiable mais fonctionnel
2. **Utiliser des scripts de monitoring externes** : SSH pour récupérer les infos
3. **Snapshots sans freeze** : Possibles mais risqués pour l'intégrité des données

```bash
# Forcer un snapshot sans attendre l'agent
qm snapshot <VMID> nom --vmstate 0
```

> [!warning] Cohérence des données Sans l'agent, les snapshots peuvent capturer un état incohérent (comme débrancher brutalement un ordinateur). Privilégiez toujours l'installation de l'agent.

---

## 🎯 Récapitulatif et points clés

### Montage d'ISO

|Méthode|Avantage|Inconvénient|
|---|---|---|
|**Upload via interface**|Simple, interface graphique|Lent pour gros fichiers|
|**Download from URL**|Direct, pas de transit local|Nécessite une URL directe|
|**wget/curl en SSH**|Rapide, scriptable|Nécessite accès SSH|

**Commande essentielle :**

```bash
qm set <VMID> --ide2 local:iso/fichier.iso,media=cdrom
```

### Installation Windows

**Points critiques :**

1. ✅ Télécharger l'ISO VirtIO **avant** de commencer
2. ✅ Attacher **deux** lecteurs CD : Windows + VirtIO
3. ✅ Charger les drivers vioscsi pendant l'installation
4. ✅ Installer virtio-win-guest-tools.exe après le premier boot
5. ✅ Configurer UEFI et TPM pour Windows 11

**Commandes clés :**

```bash
# Attacher Windows
qm set 100 --ide2 local:iso/Win11.iso,media=cdrom

# Attacher VirtIO
qm set 100 --ide0 local:iso/virtio-win.iso,media=cdrom

# Ajouter TPM pour Windows 11
qm set 100 --tpmstate0 local-lvm:1,version=v2.0
```

### Installation Linux

**Points critiques :**

1. ✅ Les drivers VirtIO sont **natifs** dans le kernel (rien à installer)
2. ✅ Choisir VirtIO Block pour les disques (meilleures performances)
3. ✅ Utiliser LVM pour la flexibilité
4. ✅ Installer OpenSSH pendant l'installation
5. ✅ Configurer l'IP statique si nécessaire (Netplan/NetworkManager)

**Commandes post-installation :**

```bash
# Mise à jour système
sudo apt update && sudo apt upgrade -y  # Ubuntu/Debian
sudo dnf update -y                       # Rocky/AlmaLinux

# Configuration hostname
sudo hostnamectl set-hostname ma-vm

# Configuration fuseau horaire
sudo timedatectl set-timezone Europe/Paris
```

### QEMU Guest Agent

**Pourquoi l'installer :**

- 🎯 **Snapshots cohérents** (freeze du système de fichiers)
- 🎯 **Shutdown propre** (signaux directs au système)
- 🎯 **Informations visibles** (IP, hostname, OS dans Proxmox)
- 🎯 **Synchronisation horaire** automatique
- 🎯 **API avancée** (exécution de commandes)

**Installation rapide :**

```bash
# Linux (Ubuntu/Debian)
sudo apt install qemu-guest-agent -y
sudo systemctl enable --now qemu-guest-agent

# Linux (Rocky/AlmaLinux)
sudo dnf install qemu-guest-agent -y
sudo systemctl enable --now qemu-guest-agent

# Windows
# Exécuter virtio-win-guest-tools.exe depuis l'ISO VirtIO

# Activation dans Proxmox
qm set <VMID> --agent enabled=1

# Vérification
qm agent <VMID> ping
```

> [!tip] Checklist post-installation Après chaque installation d'OS, vérifiez :
> 
> - ✅ La VM démarre correctement
> - ✅ Le réseau est fonctionnel (ping, DNS)
> - ✅ L'agent qemu-guest-agent est installé et actif
> - ✅ L'agent est activé côté Proxmox
> - ✅ L'IP et le hostname apparaissent dans l'interface Proxmox
> - ✅ Un snapshot de test crée et restore sans erreur
> - ✅ Les mises à jour système sont appliquées
> - ✅ SSH fonctionne (si installé)

---

## 🔍 Troubleshooting courant

### Problèmes lors de l'installation Windows

|Symptôme|Cause probable|Solution|
|---|---|---|
|Aucun disque détecté|Drivers VirtIO manquants|Charger drivers depuis `vioscsi\w1x\amd64`|
|Installation très lente|Bus de disque IDE au lieu de VirtIO|Recréer la VM avec SCSI/VirtIO|
|Pas de réseau après installation|Driver réseau non installé|Installer virtio-win-guest-tools.exe|
|Impossible de booter (Windows 11)|TPM manquant|Ajouter TPM virtuel dans Hardware|
|Écran noir au boot|UEFI mal configuré|Vérifier BIOS=OVMF et EFI disk présent|

### Problèmes lors de l'installation Linux

|Symptôme|Cause probable|Solution|
|---|---|---|
|Pas d'accès réseau|DHCP désactivé ou mal configuré|Vérifier Netplan/NetworkManager|
|Kernel panic au boot|Incompatibilité machine type|Changer q35 → i440fx ou vice-versa|
|Installation très lente|Bus de disque IDE|Utiliser VirtIO Block|
|Impossible de se connecter en SSH|Service non installé/démarré|`sudo systemctl enable --now sshd`|
|Partition root pleine|Mauvais partitionnement|Redimensionner avec LVM ou réinstaller|

### Problèmes avec l'agent

|Symptôme|Cause probable|Solution|
|---|---|---|
|`qm agent ping` échoue|Service arrêté dans la VM|`systemctl restart qemu-guest-agent`|
|IP n'apparaît pas|Agent non activé dans Proxmox|`qm set <VMID> --agent enabled=1`|
|Agent inaccessible après reboot|Service non enabled|`systemctl enable qemu-guest-agent`|
|Erreur "channel not found"|Option agent pas activée|Redémarrer la VM après activation|

---

## 💡 Astuces et optimisations

### Templates et clonage

Une fois votre OS installé et configuré (avec l'agent), vous pouvez créer un **template** pour accélérer les futures installations :

```bash
# 1. Préparer la VM (nettoyage, généralisation)
# 2. Convertir en template
qm template <VMID>

# 3. Cloner depuis le template
qm clone <VMID_TEMPLATE> <NOUVEAU_VMID> --name nouvelle-vm --full

# 4. Démarrer le clone
qm start <NOUVEAU_VMID>
```

> [!info] Sujet avancé La création et gestion des templates sera détaillée dans une autre partie du cours.

### Cloud-init pour l'automatisation

Pour Linux, l'utilisation de **cloud-init** permet de configurer automatiquement les VM clonées :

```bash
# Ajouter cloud-init à une VM
qm set <VMID> --ide2 local-lvm:cloudinit

# Configurer les paramètres
qm set <VMID> --ciuser admin --cipassword motdepasse --ipconfig0 ip=dhcp
```

> [!info] Sujet avancé Cloud-init sera abordé en détail dans la partie "Automatisation" du cours.

### Performance : tuning avancé

**Pour des VM haute performance :**

```bash
# Activer le cache write-back
qm set <VMID> --scsi0 local-lvm:vm-100-disk-0,cache=writeback

# Activer le discard/TRIM
qm set <VMID> --scsi0 local-lvm:vm-100-disk-0,discard=on

# CPU pinning (réservation de cœurs)
qm set <VMID> --cpu host --cores 4 --affinity 0,1,2,3
```

> [!warning] Expertise requise Ces optimisations nécessitent une compréhension approfondie de l'impact sur les performances et seront détaillées dans la partie "Optimisation avancée".

### Sécurité post-installation

**Durcissement de base (toutes VM) :**

```bash
# Linux : configuration SSH sécurisée
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Pare-feu de base
sudo ufw allow 22/tcp
sudo ufw enable

# Mises à jour automatiques de sécurité
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades
```

```powershell
# Windows : configuration du pare-feu
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Désactiver les services inutiles
Stop-Service -Name "RemoteRegistry" -Force
Set-Service -Name "RemoteRegistry" -StartupType Disabled

# Activer Windows Update automatique
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 4
```

> [!tip] Sécurité en couches La sécurité se construit en couches. L'installation sécurisée de l'OS n'est que la première étape. Pensez également au pare-feu Proxmox, à la séparation réseau (VLANs), et aux sauvegardes chiffrées.

---

## ✨ Conclusion

L'installation d'un système d'exploitation dans une VM Proxmox implique plusieurs étapes clés :

1. **Préparation** : Téléchargement et montage des ISO nécessaires
2. **Installation** : Processus spécifique à chaque OS (Windows nécessite des drivers supplémentaires, Linux est plus direct)
3. **Configuration post-installation** : Réseau, mises à jour, services
4. **Installation de l'agent** : **Indispensable** pour des snapshots fiables et une gestion optimale

L'agent QEMU Guest est particulièrement crucial : il transforme une VM basique en une VM pleinement intégrée à Proxmox, avec des fonctionnalités avancées de gestion et de sauvegarde.

**Prochaine étape recommandée :** Maintenant que vous savez installer des OS, apprenez à créer des templates pour accélérer le déploiement de nouvelles VM (sujet d'une autre partie du cours).