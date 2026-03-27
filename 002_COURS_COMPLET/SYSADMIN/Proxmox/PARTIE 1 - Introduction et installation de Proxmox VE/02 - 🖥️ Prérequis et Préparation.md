

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

## 🔧 Configuration matérielle {#configuration-matérielle}

### Pourquoi c'est important ?

La configuration matérielle détermine les performances et les capacités de votre infrastructure de virtualisation. Une machine sous-dimensionnée limitera le nombre de VMs que vous pourrez exécuter simultanément et leurs performances. À l'inverse, un matériel adapté garantit une expérience fluide et évolutive.

### Configuration minimale

Cette configuration permet de faire fonctionner Proxmox VE et de créer quelques machines virtuelles légères, idéale pour des tests ou un apprentissage :

|Composant|Spécification minimale|
|---|---|
|**CPU**|Processeur 64 bits (x86-64) avec 1 cœur|
|**RAM**|2 Go (système) + 512 Mo par VM|
|**Stockage**|32 Go (espace disque)|
|**Réseau**|1 carte réseau Gigabit|
|**Écran**|Résolution 1024x768 pour l'installation|

> [!warning] Attention La configuration minimale est vraiment juste pour des tests. En production ou pour un usage sérieux, elle sera rapidement saturée.

### Configuration recommandée pour production

Cette configuration offre de meilleures performances et permet d'héberger plusieurs VMs avec confort :

|Composant|Spécification recommandée|Justification|
|---|---|---|
|**CPU**|Processeur multi-cœurs moderne (4+ cœurs)|Permet l'exécution simultanée de plusieurs VMs|
|**RAM**|16 Go minimum (32-64 Go idéal)|Plus de RAM = plus de VMs et meilleures performances|
|**Stockage**|128 Go SSD pour système + stockage séparé pour VMs|Les SSD accélèrent considérablement les I/O|
|**Réseau**|2+ cartes réseau Gigabit ou 10 GbE|Séparation du trafic management/VM et redondance|
|**RAID**|Contrôleur RAID matériel ou ZFS|Redondance et protection des données|

> [!tip] Astuce Pro Pour du stockage haute performance, privilégiez des SSD NVMe en RAID 1 ou utilisez ZFS avec plusieurs disques. Cela améliore drastiquement les temps de réponse des VMs.

### Composants optionnels mais utiles

**Carte de gestion à distance (IPMI/iLO/iDRAC)** : Permet d'administrer le serveur même quand il est éteint ou planté. Indispensable en production.

**UPS (Onduleur)** : Protège contre les coupures de courant et permet un arrêt propre des VMs en cas de panne électrique prolongée.

**Stockage réseau (NAS/SAN)** : Pour centraliser le stockage et faciliter la migration de VMs entre plusieurs hôtes Proxmox.

> [!example] Exemple de configuration type **Serveur Home Lab / PME** :
> 
> - CPU : Intel Xeon E-2288G (8 cœurs) ou AMD Ryzen 9 5950X
> - RAM : 64 Go DDR4 ECC
> - Stockage : 2x 500 Go NVMe en RAID 1 (système) + 4x 2 To SATA SSD en RAID 10 (VMs)
> - Réseau : 2x 1 GbE + 1x 10 GbE (optionnel)
> - IPMI intégré

---

## 🎯 Compatibilité CPU (Intel VT-x / AMD-V) {#compatibilité-cpu}

### Qu'est-ce que la virtualisation matérielle ?

La virtualisation matérielle (Hardware-assisted Virtualization) est une technologie intégrée aux processeurs modernes qui permet d'exécuter des machines virtuelles avec des performances quasi-natives. Sans cette technologie, la virtualisation serait beaucoup plus lente car elle nécessiterait une émulation logicielle.

**Technologies selon le fabricant** :

- **Intel** : VT-x (Virtualization Technology)
- **AMD** : AMD-V (anciennement Pacifica)

### Pourquoi c'est indispensable ?

Proxmox VE utilise KVM (Kernel-based Virtual Machine) comme hyperviseur, qui requiert impérativement la virtualisation matérielle. Sans VT-x ou AMD-V activé, vous ne pourrez pas créer de machines virtuelles.

> [!info] Information Depuis environ 2010, pratiquement tous les processeurs Intel et AMD supportent la virtualisation matérielle. Le problème se situe souvent au niveau du BIOS/UEFI où elle peut être désactivée par défaut.

### Vérifier la compatibilité du CPU

#### Sous Linux (avant installation)

```bash
# Vérifier si le CPU supporte la virtualisation
lscpu | grep Virtualization

# Résultat attendu :
# Virtualization:      VT-x         (pour Intel)
# Virtualization:      AMD-V        (pour AMD)

# Méthode alternative avec /proc/cpuinfo
egrep -o '(vmx|svm)' /proc/cpuinfo | sort | uniq

# Résultat attendu :
# vmx    (pour Intel VT-x)
# svm    (pour AMD-V)
```

#### Sous Windows

```bash
# Ouvrir PowerShell en administrateur
systeminfo | findstr /i "Hyper-V"

# Si Hyper-V est présent, la virtualisation est active
# Sinon, vérifier dans le Gestionnaire des tâches > Performance > CPU
# Rechercher la ligne "Virtualisation : Activée"
```

> [!warning] Attention aux conflits Si vous avez Hyper-V activé sous Windows et que vous souhaitez utiliser Proxmox en dual-boot ou sur une machine, vous devrez désactiver Hyper-V car les deux hyperviseurs ne peuvent pas coexister sur le même matériel.

### Activer la virtualisation dans le BIOS/UEFI

Si la vérification montre que la virtualisation n'est pas active, vous devez l'activer dans le BIOS/UEFI :

**Procédure générale** :

1. Redémarrez l'ordinateur
2. Appuyez sur la touche d'accès au BIOS (généralement `F2`, `Del`, `F10`, ou `Esc` selon le fabricant)
3. Naviguez vers les options de CPU ou Advanced
4. Cherchez l'option :
    - **Intel** : "Intel Virtualization Technology", "Intel VT-x", "Vanderpool Technology"
    - **AMD** : "AMD-V", "SVM Mode", "Secure Virtual Machine"
5. Activez l'option (Enabled)
6. Sauvegardez et quittez (généralement `F10`)

**Noms d'options selon les fabricants** :

|Fabricant|Emplacement typique|Nom de l'option|
|---|---|---|
|Dell|Advanced > CPU Configuration|Virtualization Technology|
|HP|System Configuration > Virtualization Technology|Intel VT / AMD-V|
|Lenovo|Config > CPU|Intel VT-x / AMD-V|
|ASUS|Advanced > CPU Configuration|Intel Virtualization Technology|
|MSI|OC > CPU Features|Intel VT-d / AMD-V|
|Supermicro|Chipset|Intel VT-d / AMD IOMMU|

> [!tip] Astuce Prenez une photo de votre écran BIOS avec votre smartphone pour documenter les paramètres. Cela vous aidera si vous devez reconfigurer plus tard.

### Technologies complémentaires

**Intel VT-d / AMD IOMMU** : Permet le passthrough PCIe, c'est-à-dire d'assigner directement un périphérique physique (carte graphique, contrôleur réseau) à une VM. Très utile pour des VMs gaming ou des configurations spécialisées.

**Intel EPT / AMD RVI** : Améliore les performances de la gestion mémoire dans les VMs. Généralement activé automatiquement si VT-x/AMD-V est activé.

> [!example] Exemple pratique Sur un serveur Dell PowerEdge, l'activation se fait ainsi :
> 
> 1. Démarrage > F2 pour entrer dans le BIOS
> 2. System BIOS > Processor Settings
> 3. Activer "Virtualization Technology"
> 4. Activer "VT for Direct I/O" (pour le passthrough)
> 5. F10 pour sauvegarder

---

## 💾 Stockage et réseau {#stockage-et-réseau}

### Architecture de stockage

Proxmox VE offre une grande flexibilité dans la gestion du stockage. Comprendre les différents types de stockage vous permettra de choisir la configuration optimale selon vos besoins.

#### Types de stockage supportés

|Type|Description|Usage recommandé|Performance|
|---|---|---|---|
|**Directory**|Système de fichiers local (ext4, xfs)|Stockage simple, images ISO|Moyenne|
|**LVM**|Logical Volume Manager|Disques locaux, snapshots rapides|Bonne|
|**LVM-thin**|LVM avec provisioning léger|Production, snapshots économes|Bonne|
|**ZFS**|Système de fichiers avancé|Haute disponibilité, intégrité données|Excellente|
|**Ceph**|Stockage distribué|Clusters multi-nœuds|Variable|
|**NFS**|Network File System|Stockage partagé, migrations live|Dépend du réseau|
|**iSCSI**|Stockage bloc réseau|SAN, performances réseau|Bonne à excellente|

> [!info] Terminologie
> 
> - **Thin provisioning** : Allocation dynamique de l'espace disque. Un disque de 100 Go n'occupe que l'espace réellement utilisé.
> - **Thick provisioning** : Allocation immédiate de tout l'espace. Un disque de 100 Go réserve immédiatement 100 Go.

#### Recommandations de stockage selon les cas d'usage

**Pour débuter / Home Lab** :

```bash
# Configuration simple avec Directory sur ext4
Disque 1 (SSD 256 Go) : Système Proxmox + VMs
Format : ext4
Montage : /var/lib/vz
```

**Pour la production** :

```bash
# Configuration avec séparation système/données
Disque 1 (SSD 128 Go) : Système Proxmox seul
Disques 2-3 (SSD 1 To) : ZFS Mirror pour VMs
Disques 4-7 (HDD 4 To) : ZFS RAIDZ1 pour backups

# Avantages :
# - Système isolé des données
# - ZFS assure l'intégrité des données
# - Snapshots instantanés
# - Compression automatique
```

> [!warning] Pièges à éviter
> 
> - Ne jamais utiliser de partage Windows (CIFS/SMB) pour stocker des disques de VMs en production : performances médiocres et risque de corruption
> - Éviter les clés USB pour du stockage de VMs : durée de vie limitée et performances insuffisantes
> - Ne pas sous-estimer les besoins en IOPS : un HDD 7200 RPM fait ~100 IOPS, un SSD SATA ~50 000 IOPS

### Planification du stockage

#### Calcul des besoins

**Formule de base** :

```
Espace nécessaire = (Système Proxmox) + (Somme des disques VMs) + (Snapshots) + (Templates) + (ISO) + (Backups) + (Marge 20%)

Exemple :
- Proxmox : 32 Go
- 5 VMs de 50 Go : 250 Go
- Snapshots (10% des VMs) : 25 Go
- Templates : 20 Go
- ISO : 30 Go
- Backups (1 par VM) : 250 Go
- Marge 20% : 121 Go
Total : ~728 Go → Prévoir 1 To minimum
```

> [!tip] Optimisation Utilisez thin provisioning pour les disques de VMs. Une VM avec un disque de 100 Go n'occupera que l'espace réellement écrit, permettant un sur-approvisionnement intelligent.

### Configuration réseau

#### Architectures réseau typiques

**Configuration minimale (1 interface)** :

```
eth0 (vmbr0)
├── Management Proxmox (172.16.0.10)
├── VMs réseau 1 (172.16.0.100-200)
└── Accès Internet

Avantage : Simple, économique
Inconvénient : Tout le trafic sur une seule interface
```

**Configuration recommandée (2+ interfaces)** :

```
eth0 (vmbr0) - Management
└── Interface admin Proxmox (192.168.1.10)

eth1 (vmbr1) - VMs Production
├── VMs publiques (10.0.10.x)
└── NAT/Routage vers Internet

eth2 (vmbr2) - Stockage (optionnel)
└── NFS/iSCSI (192.168.100.x)

Avantages : 
- Séparation du trafic
- Meilleures performances
- Sécurité accrue
```

> [!example] Exemple professionnel **Infrastructure PME avec 3 interfaces** :
> 
> - `vmbr0` (eth0) : VLAN 10 Management (192.168.10.x)
> - `vmbr1` (eth1) : VLAN 20 Production (10.0.20.x)
> - `vmbr2` (eth2) : VLAN 30 DMZ (10.0.30.x)
> - `vmbr3` (eth3) : Stockage dédié (192.168.100.x)

#### Configuration IP recommandée

**Pour le serveur Proxmox** :

- Utilisez une **IP fixe** (jamais de DHCP en production)
- Placez-le dans un réseau dédié management
- Configurez une passerelle pour les mises à jour
- Documentez les paramètres réseau

**Exemple de configuration IP** :

```bash
# Interface management Proxmox
IP : 192.168.1.10/24
Gateway : 192.168.1.1
DNS : 192.168.1.1, 8.8.8.8
Domaine : home.lab
```

> [!warning] Sécurité réseau
> 
> - Ne jamais exposer l'interface web Proxmox directement sur Internet
> - Utiliser un VPN ou un bastion pour l'administration à distance
> - Activer le pare-feu intégré de Proxmox
> - Changer le port SSH par défaut (22) pour un port personnalisé

#### Bande passante et performance

**Besoins réseau selon les usages** :

|Usage|Bande passante recommandée|
|---|---|
|Management seul|100 Mbps suffisant|
|VMs légères (web, DNS)|1 GbE recommandé|
|VMs avec trafic important|1-10 GbE|
|Stockage réseau (NFS/iSCSI)|10 GbE minimum|
|Cluster Proxmox (Corosync)|1-10 GbE dédié|

> [!tip] Optimisation réseau Pour du stockage réseau performant (NFS/iSCSI), utilisez des cartes réseau 10 GbE dédiées avec Jumbo Frames (MTU 9000) activés. Gain de performance : +30 à 40%.

---

## 📥 Téléchargement de l'ISO {#téléchargement-iso}

### Où télécharger Proxmox VE ?

Proxmox VE est disponible gratuitement sur le site officiel. L'ISO inclut tout le nécessaire pour une installation complète.

**Site officiel** : [https://www.proxmox.com/downloads](https://www.proxmox.com/downloads)

> [!info] Versions disponibles Proxmox VE suit un cycle de release régulier :
> 
> - **Version stable** : Pour la production (ex : 8.1)
> - **Version LTS** : Support long terme, mises à jour de sécurité prolongées
> - **Version test** : Pour les early adopters et tests (non recommandé en production)

### Processus de téléchargement

#### Étape 1 : Choisir la bonne version

```bash
# Dernière version stable (recommandée)
Proxmox VE 8.x ISO Installer

# Fichier typique :
proxmox-ve_8.1-1.iso
Taille : ~1.2 Go
```

**Critères de choix** :

- **Production** : Toujours la dernière version stable
- **Apprentissage** : Dernière version stable
- **Compatibilité matériel ancien** : Version N-1 si problèmes avec la dernière

#### Étape 2 : Télécharger l'ISO

Vous avez deux options :

**Téléchargement direct (HTTP)** :

```bash
# Via navigateur web : simple et rapide
Rendez-vous sur proxmox.com/downloads
Cliquez sur "ISO Installer"
Téléchargez le fichier .iso
```

**Téléchargement BitTorrent (recommandé pour connexions instables)** :

```bash
# Plus rapide et reprise possible en cas d'interruption
Téléchargez le fichier .torrent
Utilisez qBittorrent, Transmission ou tout client torrent
Avantage : vérifie automatiquement l'intégrité
```

> [!tip] Optimisation Le téléchargement par BitTorrent est souvent plus rapide et permet de reprendre après une coupure. De plus, il participe à la distribution communautaire de Proxmox.

#### Étape 3 : Vérifier l'intégrité de l'ISO

**Pourquoi vérifier ?** Un fichier ISO corrompu causera des erreurs d'installation difficiles à diagnostiquer. La vérification prend 30 secondes et peut vous épargner des heures de débogage.

**Méthode avec checksum** :

```bash
# Télécharger le fichier de checksums sur proxmox.com
wget https://enterprise.proxmox.com/iso/SHA256SUMS

# Vérifier l'ISO sous Linux
sha256sum proxmox-ve_8.1-1.iso

# Comparer le résultat avec celui du fichier SHA256SUMS
# Les deux doivent être IDENTIQUES

# Exemple de sortie :
# 9c7e8e8c0ea3f9d8... proxmox-ve_8.1-1.iso
```

**Sous Windows** :

```powershell
# Ouvrir PowerShell
certutil -hashfile proxmox-ve_8.1-1.iso SHA256

# Comparer manuellement avec le checksum du site
```

**Sous macOS** :

```bash
# Terminal
shasum -a 256 proxmox-ve_8.1-1.iso
```

> [!warning] Attention Si les checksums ne correspondent pas :
> 
> - Ne PAS installer, l'ISO est corrompu
> - Télécharger à nouveau l'ISO
> - Vérifier l'espace disque disponible
> - Essayer un autre miroir de téléchargement

### Préparation du média d'installation

Une fois l'ISO téléchargé et vérifié, vous devez créer un média bootable.

#### Option 1 : Clé USB bootable (recommandé)

**Outils recommandés** :

|Outil|OS|Avantages|
|---|---|---|
|**Rufus**|Windows|Rapide, interface simple, détection auto|
|**balenaEtcher**|Windows/Mac/Linux|Multi-plateforme, très simple|
|**dd**|Linux/Mac|Natif, aucune installation|
|**Ventoy**|Tous|Multi-boot, garde l'ISO intacte|

**Méthode avec Rufus (Windows)** :

```
1. Télécharger Rufus depuis rufus.ie
2. Insérer une clé USB (8 Go minimum)
3. ⚠️ Sauvegarder les données de la clé (sera effacée)
4. Lancer Rufus
5. Sélectionner la clé USB
6. Cliquer sur "Sélection" et choisir l'ISO Proxmox
7. Schéma de partition : GPT (pour UEFI) ou MBR (pour BIOS legacy)
8. Système de fichiers : laisser par défaut
9. Cliquer sur "Démarrer"
10. Attendre la fin de la création (~5 min)
```

**Méthode avec dd (Linux/Mac)** :

```bash
# ⚠️ ATTENTION : dd écrase tout sans confirmation
# Vérifier d'abord le nom de la clé USB

# Linux : identifier la clé
lsblk
# Repérer votre clé (ex : /dev/sdb)

# macOS : identifier la clé
diskutil list
# Repérer votre clé (ex : /dev/disk2)

# Démonter la clé (Linux)
sudo umount /dev/sdb*

# macOS
diskutil unmountDisk /dev/disk2

# Écrire l'ISO sur la clé
# Linux
sudo dd if=proxmox-ve_8.1-1.iso of=/dev/sdb bs=4M status=progress && sync

# macOS
sudo dd if=proxmox-ve_8.1-1.iso of=/dev/rdisk2 bs=4m && sync

# Attendre la fin (5-10 min selon la clé)
```

> [!warning] DANGER avec dd La commande `dd` est surnommée "Disk Destroyer" car elle écrase tout sans avertissement. Vérifiez TROIS FOIS le nom du périphérique (/dev/sdX). Une erreur et vous pourriez effacer votre disque système !

**Méthode avec Ventoy (multi-boot pratique)** :

```bash
# Avantage : gardez plusieurs ISO bootables sur une seule clé

1. Télécharger Ventoy depuis ventoy.net
2. Installer Ventoy sur la clé USB (opération unique)
3. Copier simplement les fichiers ISO sur la clé (comme des fichiers normaux)
4. Au boot, Ventoy affiche un menu pour choisir l'ISO
5. Pas besoin de recréer la clé à chaque nouveau système
```

#### Option 2 : CD/DVD (déconseillé)

Les DVD deviennent obsolètes, mais si vous n'avez pas le choix :

```bash
# Graver l'ISO avec :
# - Windows : outil intégré (clic droit > Graver l'image disque)
# - macOS : Utilitaire de disque
# - Linux : Brasero, K3b, ou xfburn

# Vitesse de gravure : x4 ou x8 maximum (plus fiable)
# Vérifier le disque après gravure
```

#### Option 3 : Boot réseau PXE (avancé)

Pour des déploiements multiples, le boot réseau est idéal mais nécessite une infrastructure :

```bash
# Prérequis :
- Serveur TFTP
- Serveur DHCP avec options PXE
- Serveur HTTP/FTP pour l'ISO

# Avantages :
- Pas de média physique
- Déploiement rapide sur plusieurs machines
- Automatisation possible

# Usage : infrastructure d'entreprise ou home lab avancé
```

> [!tip] Astuce professionnelle Gardez toujours une clé USB bootable Proxmox dans votre sac. En cas de panne serveur critique, vous pourrez réinstaller ou dépanner rapidement, même sans accès Internet.

### Après le téléchargement

**Checklist avant installation** :

- [ ] ISO téléchargé et checksum vérifié
- [ ] Média bootable créé (clé USB ou DVD)
- [ ] Sauvegarde des données importantes sur la machine cible
- [ ] Configuration matérielle vérifiée (CPU, RAM, stockage)
- [ ] Virtualisation matérielle activée dans le BIOS
- [ ] Plan d'adressage réseau préparé (IP fixe pour Proxmox)
- [ ] Accès physique ou distant (IPMI) au serveur

> [!example] Exemple de préparation complète **Avant d'installer sur un serveur Dell PowerEdge R740** :
> 
> 1. ISO Proxmox 8.1 téléchargé et vérifié ✓
> 2. Clé USB 16 Go créée avec Rufus ✓
> 3. BIOS configuré : VT-x activé, boot UEFI, boot order sur USB ✓
> 4. Configuration réseau planifiée :
>     - IP Management : 192.168.1.10/24
>     - Gateway : 192.168.1.1
>     - DNS : 192.168.1.1, 1.1.1.1
>     - Hostname : pve-prod-01.lab.local
> 5. RAID1 configuré sur les 2 SSD pour le système ✓
> 6. Connexion IPMI testée pour accès distant ✓
> 7. Documentation de l'infrastructure mise à jour ✓

---

## 🎯 Points clés à retenir

**Configuration matérielle** :

- Minimum : 2 Go RAM, 1 cœur, 32 Go stockage → tests uniquement
- Production : 16+ Go RAM, 4+ cœurs, SSD, double réseau
- La virtualisation matérielle (VT-x/AMD-V) est OBLIGATOIRE

**Stockage** :

- Séparer système et données des VMs
- ZFS recommandé pour la production
- Prévoir 20% de marge sur l'espace disque

**Réseau** :

- IP fixe obligatoire pour Proxmox
- Minimum 1 GbE, idéalement 2+ interfaces
- Séparer management, production et stockage

**Installation** :

- Toujours vérifier le checksum de l'ISO
- Clé USB bootable avec Rufus ou dd
- Activer VT-x/AMD-V dans le BIOS avant d'installer

> [!info] Prêt pour l'installation Vous avez maintenant tous les prérequis pour installer Proxmox VE. La partie suivante couvrira le processus d'installation détaillé pas à pas.