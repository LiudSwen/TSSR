

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

## 🎯 Introduction aux VMs dans Proxmox {#introduction}

Les **machines virtuelles (VM)** dans Proxmox sont des environnements informatiques complets émulés par l'hyperviseur. Contrairement aux conteneurs, les VMs disposent de leur propre noyau et peuvent exécuter n'importe quel système d'exploitation (Windows, Linux, BSD, etc.).

> [!info] Pourquoi utiliser des VMs ?
> 
> - **Isolation complète** : chaque VM a son propre noyau
> - **Compatibilité universelle** : tous les OS sont supportés
> - **Sécurité renforcée** : isolation matérielle virtuelle
> - **Flexibilité** : migration, snapshots, backups

---

## 🧙 L'assistant de création de VM {#assistant-creation}

### Accès à l'assistant

L'assistant de création s'ouvre via l'interface web Proxmox :

1. Sélectionnez un nœud dans l'arborescence
2. Cliquez sur **"Create VM"** (bouton bleu en haut à droite)
3. L'assistant s'ouvre en mode multi-étapes

> [!tip] Navigation dans l'assistant
> 
> - Utilisez **"Next"** pour valider chaque étape
> - Vous pouvez revenir en arrière avec **"Previous"**
> - **"Finish"** crée la VM sans la démarrer
> - **"Start after created"** lance automatiquement la VM

### Organisation de l'assistant

L'assistant suit un workflow logique en 7 étapes :

|Étape|Nom|Objectif|
|---|---|---|
|1|General|Identification de la VM|
|2|OS|Source d'installation|
|3|System|Type de firmware et machine|
|4|Disks|Configuration du stockage|
|5|CPU|Allocation des processeurs|
|6|Memory|Allocation de la RAM|
|7|Network|Configuration réseau|

> [!warning] Paramètres non modifiables Certains paramètres (comme le type de machine ou BIOS) sont difficiles à modifier après création. Réfléchissez bien avant de valider.

---

## 📝 Paramètres généraux (General) {#parametres-generaux}

### VM ID (VMID)

L'identifiant unique de la machine virtuelle dans Proxmox.

**Caractéristiques :**

- Numéro entier entre **100 et 999999999**
- **Unique** sur l'ensemble du cluster
- Utilisé dans les commandes CLI (`qm start 100`)
- Ne peut pas être modifié après création

> [!example] Convention de numérotation recommandée
> 
> ```
> 100-199 : VMs de production
> 200-299 : VMs de développement
> 300-399 : VMs de test
> 400-499 : Templates
> 500-599 : VMs temporaires
> ```

### Name (Nom)

Le nom descriptif de la VM, affiché dans l'interface.

**Règles :**

- Caractères alphanumériques, tirets et underscores
- **Pas d'espaces** (utiliser `-` ou `_`)
- Sensible à la casse
- Maximum 63 caractères

> [!tip] Bonnes pratiques de nommage
> 
> - Format : `role-os-environnement-numero`
> - Exemple : `web-debian12-prod-01`
> - Inclure l'OS et la version pour faciliter l'identification
> - Utiliser un suffixe numérique pour les VM similaires

### Resource Pool

Permet de regrouper des VMs pour faciliter la gestion des permissions et l'organisation.

**Utilisation :**

- Limiter la bande passante pour des VMs non-critiques
- Éviter qu'une VM sature le réseau
- Garantir une répartition équitable
- Simuler des conditions réseau dégradées (tests)

> [!example] Exemples de limitation
> 
> ```
> VM backup/réplication  : 50 MB/s
> VM développement       : 10 MB/s
> VM test réseau         : 1 MB/s
> VM production          : Pas de limite
> ```

> [!info] Granularité La limite s'applique séparément en upload et download. Pour limiter les deux directions, configurez la limite sur l'interface.

### Multiqueue

Nombre de queues réseau parallèles pour améliorer les performances.

**Fonctionnement :**

- Chaque queue peut être traitée par un CPU différent
- Réduit les goulets d'étranglement réseau
- Améliore le débit sur charges élevées

**Configuration :**

- Valeur recommandée : **Nombre de vCPUs** (jusqu'à 16)
- Exemple : VM avec 4 vCPUs → 4 queues

> [!warning] Prérequis
> 
> - Carte réseau **VirtIO** uniquement
> - Support dans l'OS invité (Linux 3.x+, Windows 10+)
> - Overhead mémoire : ~8 MB par queue

**Impact performance :**

```
1 queue  : Jusqu'à 1-2 Gbps
4 queues : Jusqu'à 8-10 Gbps
8 queues : Jusqu'à 15-20+ Gbps
```

### Firewall

Active le pare-feu Proxmox au niveau de l'interface.

**Caractéristiques :**

- Filtrage au niveau de l'hôte (avant la VM)
- Règles définies dans Proxmox
- Pas d'impact sur le pare-feu de la VM
- Peut coexister avec iptables/firewalld dans la VM

**Niveaux de configuration :**

1. **Datacenter** : Règles globales pour tout le cluster
2. **VM** : Règles spécifiques à la VM
3. **Interface** : Règles par interface réseau

> [!tip] Utilisation recommandée
> 
> - Activez pour une couche de sécurité supplémentaire
> - Définissez les règles via **VM → Firewall**
> - Combinez avec le pare-feu interne de la VM

### Disconnect

Déconnecte virtuellement le câble réseau.

**Effet :**

- L'interface existe mais n'a pas de "lien"
- Équivalent à débrancher un câble Ethernet
- La VM voit l'interface comme "no carrier"

**Cas d'usage :**

- Isolation temporaire de la VM
- Tests de résilience réseau
- Maintenance sans arrêter la VM
- Désactivation temporaire sans supprimer l'interface

> [!info] Différence avec suppression
> 
> - **Disconnect** : Interface présente mais inactive (réversible)
> - **Supprimer** : Interface disparaît complètement (nécessite redémarrage)

---

## 📊 Synthèse et bonnes pratiques {#synthese}

### ✅ Checklist de création d'une VM

#### Avant la création

- [ ] Définir le rôle et les besoins de la VM
- [ ] Choisir une convention de nommage cohérente
- [ ] Vérifier les ressources disponibles sur l'hôte
- [ ] Préparer l'ISO d'installation si nécessaire
- [ ] Déterminer le réseau de destination

#### Paramètres généraux

- [ ] VMID selon convention de numérotation
- [ ] Nom descriptif sans espaces
- [ ] Notes complètes pour documentation
- [ ] Resource pool si applicable

#### Configuration système

- [ ] **q35** comme type de machine (sauf cas spécial)
- [ ] **OVMF (UEFI)** pour OS modernes
- [ ] **VirtIO SCSI** comme contrôleur
- [ ] Activer **Qemu Agent**
- [ ] TPM si Windows 11

#### Configuration disque

- [ ] **VirtIO Block** pour meilleures performances
- [ ] Taille adaptée avec marge d'évolution
- [ ] **No cache** pour SSD, **Write through** pour HDD
- [ ] **Discard** activé si SSD
- [ ] **IO thread** pour charges I/O intensives
- [ ] **SSD emulation** si stockage SSD

#### Configuration CPU

- [ ] **1 socket** avec N cores (sauf contrainte licence)
- [ ] Type CPU : **host** (fixe) ou **x86-64-v2-AES** (migration)
- [ ] CPU Units par défaut sauf hiérarchisation
- [ ] NUMA pour VMs ≥ 8 vCPUs

#### Configuration mémoire

- [ ] RAM adaptée aux besoins + 20% marge
- [ ] Ballooning uniquement si nécessaire
- [ ] Minimum memory à 25-50% si ballooning actif
- [ ] Shares pour priorisation si besoin

#### Configuration réseau

- [ ] Bridge approprié (vmbr0 généralement)
- [ ] VLAN tag si segmentation
- [ ] **VirtIO** comme modèle
- [ ] MAC auto sauf cas spécifique
- [ ] Multiqueue = nombre de vCPUs
- [ ] Firewall activé pour sécurité

### 🎯 Configurations types recommandées

#### Serveur Linux léger

```
CPU     : 1 socket, 2 cores (x86-64-v2-AES)
RAM     : 2 GB
Disque  : 32 GB, VirtIO Block, No cache, Discard
Réseau  : VirtIO, multiqueue 2
Système : q35, OVMF, VirtIO SCSI, Qemu Agent
```

#### Serveur Windows moderne

```
CPU     : 1 socket, 4 cores (host)
RAM     : 8 GB
Disque  : 80 GB, VirtIO Block, No cache, Discard
Réseau  : VirtIO, multiqueue 4
Système : q35, OVMF + EFI, VirtIO SCSI, Qemu Agent, TPM
```

#### Base de données

```
CPU     : 1 socket, 8 cores (host), IO thread actif
RAM     : 16-32 GB, pas de ballooning
Disque  : Dédié, VirtIO Block, No cache, Discard
Réseau  : VirtIO, multiqueue 8
Système : q35, OVMF, VirtIO SCSI, Qemu Agent
```

#### VM de développement

```
CPU     : 1 socket, 2-4 cores (x86-64-v2-AES)
RAM     : 4-8 GB, ballooning OK (min 2GB)
Disque  : 40-60 GB, VirtIO Block
Réseau  : VirtIO, multiqueue = vCPUs
Système : q35, OVMF, VirtIO SCSI, Qemu Agent
```

### ⚠️ Erreurs courantes à éviter

|Erreur|Impact|Solution|
|---|---|---|
|Utiliser i440fx|Performances réduites|Toujours utiliser **q35**|
|SeaBIOS pour OS moderne|Perd fonctionnalités UEFI|Utiliser **OVMF**|
|Trop de sockets CPU|Surcoût licence|1 socket avec N cores|
|E1000 au lieu de VirtIO|Perte 50-80% performance|VirtIO + drivers|
|Pas de Qemu Agent|Perte de fonctionnalités|Installer dans la VM|
|Disque trop gros d'entrée|Gaspillage d'espace|Dimensionner juste + étendre|
|Ballooning sur DB|Performances instables|Désactiver pour VMs critiques|
|Write back cache|Risque perte données|No cache ou Write through|
|Oublier Discard sur SSD|Usure prématurée|Activer pour SSD|
|Pas de multiqueue|Goulet réseau|Activer = nombre vCPUs|

### 🚀 Optimisations avancées

#### Performance maximale

```
CPU Type        : host
Cache           : No cache (SSD)
IO thread       : Activé
Discard         : Activé
Multiqueue      : = vCPUs
SSD emulation   : Activé (si SSD réel)
```

#### Migration facile

```
CPU Type        : x86-64-v2-AES
Machine         : q35
BIOS            : OVMF
Éviter          : host, flags CPU personnalisés
```

#### Sécurité renforcée

```
Firewall        : Activé + règles restrictives
TPM             : Activé (Windows 11)
Secure Boot     : Pre-enroll keys
Agent           : Installé et actif
Réseau          : VLAN dédié
```

#### Efficacité ressources

```
Ballooning      : Activé (min 25%)
CPU Units       : Priorisé selon criticité
Shares          : Hiérarchisé
Thin provision  : Sur stockages compatibles
```

### 📝 Post-création immédiate

Après avoir créé la VM, effectuez ces étapes :

1. **Installer l'OS** via la console
2. **Installer qemu-guest-agent**
    
    ```bash
    # Debian/Ubuntuapt install qemu-guest-agent# RHEL/Rockydnf install qemu-guest-agent# Windows : virtio-win-guest-tools.exe
    ```
    
3. **Installer les drivers VirtIO** (Windows)
4. **Configurer le réseau** dans l'OS
5. **Mettre à jour le système**
6. **Configurer le hostname**
7. **Créer un snapshot** "post-installation"
8. **Documenter** dans les notes de la VM

### 🔧 Commandes CLI utiles

```bash
# Lister les VMs
qm list

# Créer une VM en CLI
qm create 100 --name test-vm --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0

# Démarrer une VM
qm start 100

# Arrêter proprement (nécessite qemu-agent)
qm shutdown 100

# Forcer l'arrêt
qm stop 100

# Obtenir le statut
qm status 100

# Afficher la configuration
qm config 100

# Modifier la configuration
qm set 100 --memory 4096

# Créer un snapshot
qm snapshot 100 snap1

# Cloner une VM
qm clone 100 101 --name clone-vm

# Supprimer une VM
qm destroy 100
```

### 📖 Récapitulatif des choix par défaut optimaux

Pour une **VM moderne standard** :

```yaml
Général:
  Machine: q35
  BIOS: OVMF (UEFI)
  
Système:
  SCSI Controller: VirtIO SCSI
  Qemu Agent: Activé
  Graphic: Default
  
Disque:
  Bus: VirtIO Block
  Cache: No cache
  Discard: Activé
  IO thread: Activé
  SSD emulation: Activé (si SSD)
  Backup: Include
  
CPU:
  Topology: 1 socket × N cores
  Type: x86-64-v2-AES (ou host si pas de migration)
  NUMA: Activé si ≥8 vCPUs
  
Mémoire:
  Ballooning: Désactivé (sauf contrainte ressources)
  
Réseau:
  Model: VirtIO
  Multiqueue: Nombre de vCPUs
  Firewall: Activé
```

---

> [!tip] 💡 Conseil final La création d'une VM est un processus réversible pour la plupart des paramètres. N'hésitez pas à expérimenter dans un environnement de test pour comprendre l'impact de chaque option. Les snapshots sont vos amis pour tester des modifications en toute sécurité.

- Délégation de droits à des utilisateurs/groupes
- Organisation logique (par projet, département, client)
- Optionnel lors de la création

> [!info] Création ultérieure Les resource pools se créent via **Datacenter → Permissions → Pools**

### Notes et description

Champ libre pour documenter la VM.

**Informations utiles à inclure :**

- Rôle et fonction de la VM
- Responsable technique
- Applications installées
- Date de création et historique
- Informations de contact

> [!example] Exemple de note structurée
> 
> ```markdown
> # Serveur Web Production
> - Responsable: Jean Dupont (j.dupont@example.com)
> - Applications: Nginx, PHP 8.2, MariaDB
> - Créé le: 2024-12-24
> - Backup: Quotidien à 2h00
> - Monitoring: Zabbix activé
> ```

---

## ⚙️ Configuration système (System) {#configuration-systeme}

### Graphic card (Carte graphique)

Définit le type de carte graphique virtuelle émulée.

|Type|Description|Usage recommandé|
|---|---|---|
|**Default**|VGA standard|Serveurs sans interface graphique|
|**VirtIO-GPU**|Accélération 3D virtuelle|Workstations Linux|
|**VMware compatible**|Compatible ESXi|Migration depuis VMware|
|**SPICE**|Protocole d'affichage distant|Bureaux virtuels avec SPICE client|

> [!tip] Choix optimal
> 
> - **Serveurs** : Default (suffisant pour console texte)
> - **Desktop Linux** : VirtIO-GPU
> - **Desktop Windows** : Default ou SPICE selon les besoins

### Machine type (Type de machine)

Définit le type de matériel virtuel émulé par QEMU.

**Options principales :**

#### i440fx (Ancien standard)

- Architecture PC traditionnelle
- Compatible avec tous les OS anciens
- Limite à 32 dispositifs PCI
- **Ne pas utiliser pour les nouvelles VMs**

#### q35 (Recommandé)

- Architecture moderne (depuis 2009)
- Support PCIe natif
- Plus de slots d'extension
- Meilleure performance
- **À privilégier systématiquement**

> [!warning] Choix définitif Le type de machine ne peut **pas** être modifié après création sans recréer la VM. Toujours choisir **q35** pour les nouvelles installations.

### BIOS (Firmware)

Définit le type de firmware utilisé au démarrage.

#### SeaBIOS (BIOS Legacy)

**Caractéristiques :**

- BIOS traditionnel 16-bit
- Compatible avec tous les OS
- Boot en mode Legacy/MBR
- Interface texte simple

**Quand l'utiliser :**

- OS très anciens (Windows 7, distributions Linux anciennes)
- Migrations de machines physiques Legacy
- Problèmes de compatibilité avec UEFI

#### OVMF (UEFI)

**Caractéristiques :**

- Firmware moderne 64-bit
- Interface graphique de boot
- Support GPT obligatoire
- Secure Boot disponible
- Meilleure performance

**Quand l'utiliser :**

- **Tous les OS modernes** (Windows 10/11, Linux récents)
- VMs nécessitant Secure Boot
- Disques > 2 TB
- **Recommandé par défaut**

> [!example] Configuration UEFI recommandée
> 
> ```
> BIOS: OVMF (UEFI)
> Add EFI Disk: ✓ (coché)
> EFI Storage: Même stockage que le disque principal
> Pre-Enroll keys: ✓ (pour Secure Boot sur Windows 11)
> ```

### SCSI Controller

Définit le contrôleur pour les disques SCSI/SATA.

|Contrôleur|Performance|Compatibilité|Usage|
|---|---|---|---|
|**VirtIO SCSI**|Excellente|Linux moderne, Windows avec drivers|**Recommandé**|
|**VirtIO SCSI (single)**|Excellente|Idem|Une seule queue I/O|
|**LSI 53C895A**|Moyenne|Universelle|OS anciens|
|**MegaRAID SAS**|Bonne|Bonne|Compatibilité RAID|

> [!tip] Choix optimal
> 
> - **Linux/Windows 10+** : VirtIO SCSI (meilleure performance)
> - **Windows ancien sans drivers** : LSI 53C895A
> - VirtIO nécessite l'installation de drivers sur Windows

### Qemu Agent

Agent installé dans la VM pour améliorer l'intégration avec Proxmox.

**Fonctionnalités offertes :**

- Arrêt propre de la VM (shutdown gracieux)
- Récupération de l'adresse IP
- Synchronisation de l'horloge
- Quiescing pour snapshots cohérents
- Exécution de commandes depuis l'hôte

**Installation :**

```bash
# Debian/Ubuntu
apt install qemu-guest-agent
systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent

# RHEL/CentOS/Rocky
dnf install qemu-guest-agent
systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent

# Windows
# Installer virtio-win-guest-tools.exe depuis le ISO virtio-win
```

> [!warning] Activation obligatoire Cocher **"Qemu Agent"** dans l'assistant ne suffit pas. Vous devez également **installer l'agent dans la VM** après son déploiement.

### TPM (Trusted Platform Module)

Module de sécurité virtuel pour le chiffrement et l'attestation.

**Caractéristiques :**

- Émulation TPM 2.0
- Requis pour Windows 11
- Stockage sécurisé des clés de chiffrement
- Support BitLocker

**Configuration :**

```
TPM State: Sélectionner un stockage
Version: 2.0
```

> [!info] Prérequis
> 
> - BIOS doit être en mode **UEFI**
> - Un stockage doit être configuré pour l'état TPM

---

## 💾 Configuration du disque (Disks) {#configuration-disque}

### Bus/Device (Type de contrôleur)

Définit comment le disque est connecté à la VM.

|Bus|Performance|Compatibilité|Cas d'usage|
|---|---|---|---|
|**VirtIO Block**|⭐⭐⭐⭐⭐|Moderne|**Recommandé** pour Linux/Windows 10+|
|**SCSI**|⭐⭐⭐⭐|Universelle|Bon compromis|
|**SATA**|⭐⭐⭐|Excellente|OS anciens, compatibilité maximale|
|**IDE**|⭐⭐|Maximale|OS très anciens uniquement|

> [!tip] Recommandation par OS
> 
> ```
> Linux moderne      → VirtIO Block
> Windows 10/11      → VirtIO Block (avec drivers)
> Windows 7/8        → SATA ou SCSI
> Windows XP         → IDE
> ```

### Storage (Stockage)

Sélection du backend de stockage Proxmox où créer le disque.

**Types de stockage disponibles :**

- **LVM** : Logical Volume Manager (performance)
- **LVM-Thin** : LVM avec thin provisioning
- **ZFS** : Système de fichiers avancé
- **Ceph** : Stockage distribué en cluster
- **Directory** : Répertoire simple
- **NFS** : Stockage réseau

> [!info] Impact du choix Le type de stockage influence :
> 
> - Les performances I/O
> - La disponibilité des snapshots
> - Les options de backup
> - La possibilité de thin provisioning

### Disk size (Taille du disque)

Taille allouée au disque virtuel.

**Considérations importantes :**

**Dimensionnement initial :**

```
OS seul :
- Linux serveur : 20-32 GB
- Windows Server : 60-80 GB
- Desktop Linux : 40-60 GB
- Desktop Windows : 80-120 GB

Avec applications :
- Ajouter 20-50% selon les besoins
- Privilégier plusieurs petits disques qu'un gros
```

> [!warning] Extension ultérieure
> 
> - Augmenter la taille est facile
> - Réduire la taille est **très difficile** voire impossible
> - Partir petit et étendre au besoin

### Cache mode

Définit la stratégie de cache disque entre l'hôte et la VM.

|Mode|Description|Usage|
|---|---|---|
|**No cache**|Pas de cache|Performance maximale avec stockage rapide|
|**Write through**|Cache lecture seule|Bon compromis sécurité/performance|
|**Write back**|Cache lecture/écriture|Performance max, risque perte données|
|**Direct sync**|I/O synchrones|Cohérence maximale|

> [!tip] Choix recommandé
> 
> - **Stockage SSD/NVMe** : No cache (le cache de l'hôte suffit)
> - **Stockage rotatif** : Write through
> - **Bases de données** : No cache ou Direct sync
> - **Write back** : À éviter sauf besoins spécifiques

### Discard (TRIM)

Active le support TRIM pour les SSD.

**Fonctionnement :**

- Informe le SSD des blocs libérés
- Améliore la longévité du SSD
- Optimise les performances
- Réduit l'usage du thin provisioning

> [!warning] Conditions requises
> 
> ```
> ✓ Stockage sous-jacent supporte TRIM
> ✓ Format de disque : raw ou qcow2
> ✓ Bus : SCSI ou VirtIO Block
> ✗ Ne fonctionne PAS avec IDE ou SATA
> ```

### IO thread

Dédie un thread par disque pour les opérations I/O.

**Avantages :**

- Meilleure parallélisation des I/O
- Réduit la latence
- Améliore les performances multi-disques

**Quand l'activer :**

- VMs avec charges I/O intensives
- Bases de données
- Serveurs de fichiers
- Plusieurs disques sur la VM

> [!info] Prérequis Nécessite le bus **VirtIO Block** ou **VirtIO SCSI**

### SSD emulation

Indique au système d'exploitation que le disque est un SSD.

**Effets :**

- L'OS adapte ses algorithmes d'ordonnancement
- Désactive les optimisations pour disques rotatifs
- Active TRIM automatiquement dans l'OS

> [!tip] Quand l'utiliser Activez uniquement si le stockage sous-jacent est **réellement un SSD**. Sinon, cela peut dégrader les performances.

### Backup option

Inclut ou exclut le disque des backups automatiques.

**Options :**

- **Include** : Le disque est sauvegardé
- **Exclude** : Le disque est ignoré

**Cas d'exclusion :**

- Disques de données temporaires
- Caches applicatifs
- Disques de swap
- Données facilement reconstructibles

> [!warning] Attention Un disque système doit **toujours** être inclus dans les backups.

---

## 🧠 Configuration CPU (CPU) {#configuration-cpu}

### Sockets, Cores, et vCPUs

Proxmox utilise une topologie CPU flexible basée sur trois paramètres.

**Définitions :**

- **Sockets** : Nombre de processeurs physiques virtuels
- **Cores** : Nombre de cœurs par socket
- **Total vCPUs** = Sockets × Cores

> [!example] Exemples de topologie
> 
> ```
> Configuration 1 : 1 socket, 4 cores = 4 vCPUs
> ├─ Socket 0
> │  ├─ Core 0
> │  ├─ Core 1
> │  ├─ Core 2
> │  └─ Core 3
> 
> Configuration 2 : 2 sockets, 2 cores = 4 vCPUs
> ├─ Socket 0
> │  ├─ Core 0
> │  └─ Core 1
> └─ Socket 1
>    ├─ Core 0
>    └─ Core 1
> ```

**Impact sur les licences :**

Certains logiciels (Windows Server, SQL Server, VMware) facturent par socket.

```
Exemple : Windows Server Standard
- 1 socket × 8 cores = 8 vCPUs → 1 licence
- 2 sockets × 4 cores = 8 vCPUs → 2 licences
```

> [!tip] Recommandation générale Privilégiez **1 socket avec N cores** sauf contrainte de licence ou performance spécifique.

### CPU Type (Type de processeur)

Définit le jeu d'instructions CPU visible par la VM.

**Types principaux :**

#### host

- **Caractéristiques** : Expose toutes les fonctionnalités du CPU physique
- **Avantages** : Performance maximale, fonctionnalités modernes
- **Inconvénients** : Migration limitée (nécessite CPU identique)
- **Usage** : VM fixes, pas de migration prévue

#### kvm64 (x86-64-v1)

- **Caractéristiques** : CPU 64-bit générique de base
- **Avantages** : Compatible avec tous les CPU 64-bit
- **Inconvénients** : Performances réduites
- **Usage** : Maximum de compatibilité

#### x86-64-v2-AES, v3, v4

- **Caractéristiques** : Niveaux progressifs de jeux d'instructions
- **Avantages** : Bon compromis performance/compatibilité
- **Inconvénients** : Nécessite CPU récent pour v3/v4
- **Usage** : Clusters homogènes récents

> [!info] Hiérarchie des niveaux
> 
> ```
> v1 (kvm64) : Base 2006 (SSE2)
>   ↓
> v2 : +2009 (SSE4.2, SSSE3)
>   ↓
> v3 : +2013 (AVX2, BMI2)
>   ↓
> v4 : +2017 (AVX512)
> ```

**Types spécifiques constructeur :**

- **EPYC** / **EPYC-v4** : Processeurs AMD serveur
- **Skylake-Server** : Processeurs Intel Xeon récents
- **Cascade Lake** : Intel Xeon 2ème/3ème gen

> [!tip] Choix optimal
> 
> ```
> Cluster homogène sans migration : host
> Cluster hétérogène avec migration : x86-64-v2-AES
> VM haute performance fixe : Type correspondant au CPU
> ```

### CPU Units

Définit la priorité relative du CPU entre les VMs (ordonnanceur CFS de Linux).

**Fonctionnement :**

- Valeur par défaut : **1024**
- Plage : 2 à 262144
- Plus la valeur est élevée, plus la VM obtient de temps CPU lors de la contention

**Calcul de la répartition :**

```
VM1 : 1024 units }
VM2 : 2048 units } → VM2 recevra 2× plus de CPU que VM1
VM3 : 512 units  }    VM3 recevra 0.5× le CPU de VM1
```

> [!info] Impact réel Ce paramètre n'a d'effet que lorsque le CPU de l'hôte est **saturé**. Si les ressources sont disponibles, toutes les VMs obtiennent ce dont elles ont besoin.

> [!example] Cas d'usage
> 
> ```
> VM Production critique    : 2048 units
> VM Production standard    : 1024 units (défaut)
> VM Dev/Test               : 512 units
> VM temporaire             : 256 units
> ```

### CPU limit

Limite le temps CPU maximum utilisable par la VM.

**Format :**

- Valeur décimale entre 0 et (nombre de cœurs)
- Exemple : 2.5 = maximum 2.5 cœurs utilisables

**Utilisation :**

- Empêcher une VM de monopoliser les ressources
- Garantir des ressources pour d'autres VMs
- Respect de licences limitées en CPU

> [!warning] À utiliser avec précaution Cette option **restreint artificiellement** les performances. À n'utiliser que si vraiment nécessaire (licences, isolation stricte).

### NUMA (Non-Uniform Memory Access)

Active la topologie NUMA pour les grandes VMs multi-socket.

**Fonctionnalités :**

- Améliore les performances des VMs avec beaucoup de vCPUs
- Réduit la latence d'accès mémoire
- Utile pour VMs ≥ 8 vCPUs sur hôtes NUMA

**Condition :**

- L'hôte doit avoir une architecture NUMA
- La VM doit avoir plusieurs sockets

> [!tip] Activation recommandée Activez NUMA pour les VMs ayant **8 vCPUs ou plus** sur des serveurs multi-socket.

### CPU flags personnalisés

Possibilité d'ajouter ou retirer des fonctionnalités CPU spécifiques.

**Syntaxe :**

```
+flag  : Ajouter une fonctionnalité
-flag  : Retirer une fonctionnalité
```

**Exemples courants :**

```
+aes           : Forcer AES-NI (chiffrement)
+pcid          : Améliorer performance TLB
-spectre-v2    : Désactiver mitigation Spectre
+md-clear      : Protection MDS
```

> [!warning] Utilisation avancée Ne modifiez ces flags que si vous comprenez parfaitement leur impact. Une mauvaise configuration peut rendre la VM instable ou non-bootable.

---

## 🐏 Configuration mémoire (Memory) {#configuration-memoire}

### Memory (RAM)

Quantité de RAM allouée à la VM en MiB (Mebibyte).

**Dimensionnement recommandé :**

|Type de VM|RAM minimale|RAM recommandée|
|---|---|---|
|Linux serveur minimal|512 MB|1-2 GB|
|Linux serveur standard|1 GB|2-4 GB|
|Windows Server|2 GB|4-8 GB|
|Desktop Linux|2 GB|4-8 GB|
|Desktop Windows|4 GB|8-16 GB|
|Base de données|4 GB|8-32+ GB|
|Serveur web|1 GB|2-8 GB|

**Calcul de l'overhead :**

Proxmox réserve de la mémoire supplémentaire pour la gestion de la VM :

```
Overhead = 256 MB + (nombre_vCPUs × 8 MB)

Exemple VM avec 4 vCPUs et 8 GB RAM :
- RAM VM : 8192 MB
- Overhead : 256 + (4 × 8) = 288 MB
- Total hôte : 8480 MB réservés
```

> [!warning] Éviter le surdimensionnement
> 
> - N'allouez pas toute la RAM de l'hôte
> - Conservez 10-20% libre pour l'hôte
> - RAM non utilisée par la VM reste "bloquée"
> - Utilisez le ballooning pour optimiser

### Minimum memory (RAM minimum)

RAM garantie minimale avec ballooning activé.

**Fonctionnement :**

- La VM démarre avec la RAM totale allouée
- Si l'hôte manque de mémoire, le balloon peut réduire jusqu'au minimum
- Le minimum doit être suffisant pour l'OS et services critiques

> [!example] Configuration type
> 
> ```
> VM serveur web avec 8 GB RAM :
> - Memory : 8192 MB
> - Minimum : 2048 MB (25%)
> 
> Permet de récupérer jusqu'à 6 GB si nécessaire
> tout en gardant le serveur fonctionnel
> ```

> [!info] Prérequis Le ballooning nécessite **qemu-guest-agent** installé dans la VM.

### Ballooning Device

Active le mécanisme de ballooning mémoire.

**Principe :**

1. Un driver "balloon" dans la VM communique avec l'hôte
2. L'hôte peut demander au balloon de "gonfler" (réclamer de la RAM)
3. La RAM libérée redevient disponible pour l'hôte
4. Le balloon peut "dégonfler" pour rendre la RAM à la VM

**Avantages :**

- ✅ Optimisation dynamique de la RAM
- ✅ Surallocation (overcommit) contrôlée
- ✅ Réponse aux pics de charge temporaires

**Inconvénients :**

- ❌ Légère overhead de performance
- ❌ Nécessite drivers dans la VM
- ❌ Peut causer des lenteurs si trop agressif

> [!tip] Quand l'utiliser
> 
> - Hôtes avec RAM limitée
> - Nombreuses VMs aux charges variables
> - Environnements de dev/test
> 
> **À éviter :**
> 
> - VMs critiques (bases de données)
> - Charges mémoire constantes et élevées
> - VMs temps-réel

### Shares

Priorité relative de la RAM entre les VMs lors de la contention mémoire.

**Valeurs :**

- Plage : 0 à 50000
- Défaut : 1000

**Utilisation similaire aux CPU Units :**

```
VM prioritaire    : 2000 shares → 2× plus de priorité
VM standard       : 1000 shares → priorité normale
VM non-critique   : 500 shares  → priorité basse
```

> [!info] Interaction avec ballooning Les shares influencent l'ordre et l'agressivité du ballooning. Les VMs avec plus de shares verront leur balloon activé en dernier.

---

## 🌐 Configuration réseau (Network) {#configuration-reseau}

### Bridge

Pont réseau auquel connecter l'interface virtuelle.

**Bridges par défaut :**

- **vmbr0** : Bridge principal (généralement connecté au réseau physique)
- **vmbr1, vmbr2...** : Bridges additionnels selon configuration

**Types de connexion :**

```
VM → vmbr0 → Interface physique → Réseau externe
     ↓
  vmbr1 → Réseau isolé entre VMs
     ↓
  vmbr2 → VLAN spécifique
```

> [!info] Création de bridges Les bridges se créent via **Node → Network** dans l'interface Proxmox.

### VLAN Tag

Identifiant VLAN (802.1Q) pour segmenter le réseau.

**Plage :** 1 à 4094

**Utilisation :**

```
VLAN 10 : Réseau de production
VLAN 20 : Réseau de développement
VLAN 30 : Réseau DMZ
VLAN 100 : Réseau de management
```

> [!warning] Prérequis
> 
> - Le switch physique doit être configuré pour ces VLANs
> - Le bridge doit être VLAN-aware
> - Laissez vide pour réseau non-taggé

### Model (Modèle de carte réseau)

Type de carte réseau virtuelle émulée.

|Modèle|Performance|Compatibilité|Usage|
|---|---|---|---|
|**VirtIO (paravirtualized)**|⭐⭐⭐⭐⭐|Moderne|**Recommandé**|
|**Intel E1000**|⭐⭐⭐|Excellente|OS anciens|
|**VMware vmxnet3**|⭐⭐⭐⭐|VMware|Migration VMware|
|**Realtek RTL8139**|⭐⭐|Universelle|Très vieux OS|

**Détails VirtIO :**

- Pilote paravirtualisé haute performance
- Jusqu'à 10× plus rapide que E1000
- Support multiqueue
- Nécessite drivers (inclus dans Linux, à installer sur Windows)

> [!tip] Choix recommandé
> 
> ```
> Linux moderne           → VirtIO
> Windows 10/11 + drivers → VirtIO
> Windows sans drivers    → Intel E1000
> Migration VMware        → vmxnet3
> ```

### MAC Address

Adresse MAC de l'interface réseau virtuelle.

**Génération :**

- **Automatique** : Proxmox génère une adresse unique
- **Manuelle** : Format `XX:XX:XX:XX:XX:XX`

**Préfixe Proxmox :** Les adresses auto-générées commencent par les octets réservés par Proxmox.

> [!example] Cas d'usage manuel
> 
> ```
> - Licence logicielle liée à une MAC
> - Migration depuis système physique
> - Intégration avec système de gestion réseau
> - Clonage avec MAC spécifique
> ```

> [!warning] Attention aux doublons Si vous définissez manuellement une MAC, assurez-vous qu'elle est **unique sur le réseau**.

### Rate limit (Limitation de bande passante)

Limite la vitesse de l'interface réseau.

**Format :**

- Valeur en MB/s (Megabytes par seconde)
- Exemple : `10` = 10 MB/s = 80 Mbps

**Utilisation :**