

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

## Introduction à modifyvm

### 🎯 Qu'est-ce que `modifyvm` ?

La commande `modifyvm` est l'outil principal pour configurer tous les paramètres d'une machine virtuelle existante. Elle permet de modifier le matériel virtuel, les paramètres de démarrage, et de nombreuses autres options sans passer par l'interface graphique.

> [!info] Quand utiliser `modifyvm` ?
> 
> - Pour configurer une VM avant son premier démarrage
> - Pour ajuster les ressources allouées (RAM, CPU, VRAM)
> - Pour automatiser la configuration de plusieurs VMs
> - Pour modifier des paramètres avancés non accessibles facilement en GUI

### 📐 Syntaxe de base

```bash
VBoxManage modifyvm <nom-vm|uuid-vm> <paramètre> <valeur>
```

> [!warning] État de la VM La plupart des paramètres ne peuvent être modifiés que lorsque la VM est **éteinte** (état `poweroff`). Certains paramètres spécifiques peuvent être modifiés à chaud, mais c'est l'exception.

### 🔍 Vérifier l'état actuel d'une VM

```bash
# Afficher tous les paramètres d'une VM
VBoxManage showvminfo "MaVM"

# Afficher uniquement les informations essentielles
VBoxManage showvminfo "MaVM" --machinereadable
```

---

## Mémoire RAM et Processeurs

### 💾 Configuration de la RAM

La RAM détermine la quantité de mémoire vive disponible pour la VM. C'est l'un des paramètres les plus critiques pour les performances.

#### Syntaxe

```bash
# Définir la RAM (en Mo)
VBoxManage modifyvm "MaVM" --memory 4096

# Vérifier la RAM allouée
VBoxManage showvminfo "MaVM" | grep "Memory size"
```

> [!example] Exemples de configurations recommandées
> 
> |Type de VM|RAM recommandée|Usage|
> |---|---|---|
> |Serveur léger|512-1024 Mo|Serveur web basique, tests|
> |Linux Desktop|2048-4096 Mo|Ubuntu, Fedora, Mint|
> |Windows 10/11|4096-8192 Mo|Usage standard|
> |Développement|8192-16384 Mo|IDE, compilation, conteneurs|

> [!warning] Limites importantes
> 
> - Ne jamais allouer plus de 50% de la RAM physique de l'hôte
> - Laisser au minimum 2-4 Go à l'OS hôte
> - La RAM allouée est **réservée** au démarrage de la VM

#### Configuration avancée de la RAM

```bash
# Activer PAE/NX (Physical Address Extension)
# Permet d'adresser plus de 4 Go sur systèmes 32 bits
VBoxManage modifyvm "MaVM" --pae on

# Activer Large Pages (améliore performances)
# Nécessite droits admin sur l'hôte
VBoxManage modifyvm "MaVM" --largepages on

# Activer le ballooning de mémoire
# Permet l'ajustement dynamique de la RAM
VBoxManage modifyvm "MaVM" --pagefusion on
```

### 🖥️ Configuration des Processeurs

#### Nombre de CPUs virtuels

```bash
# Définir le nombre de cœurs CPU (vCPUs)
VBoxManage modifyvm "MaVM" --cpus 4

# Limiter l'utilisation CPU à un pourcentage
# Ici: limite à 75% de chaque CPU alloué
VBoxManage modifyvm "MaVM" --cpuexecutioncap 75
```

> [!tip] Bonnes pratiques pour les CPUs
> 
> - Ne pas allouer plus de vCPUs que de cœurs physiques disponibles
> - Pour un hôte avec 8 cœurs, allouer maximum 4-6 vCPUs
> - Les performances ne s'améliorent pas toujours avec plus de vCPUs
> - Certaines applications mono-thread ne bénéficient pas de plusieurs cœurs

#### Fonctionnalités CPU avancées

```bash
# Activer l'accélération matérielle (VT-x/AMD-V)
# Indispensable pour de bonnes performances
VBoxManage modifyvm "MaVM" --hwvirtex on

# Activer les pages imbriquées (Nested Paging)
# Améliore considérablement les performances
VBoxManage modifyvm "MaVM" --nestedpaging on

# Exposer les instructions PAE/NX au guest
VBoxManage modifyvm "MaVM" --pae on

# Définir la priorité CPU de la VM
# Valeurs: 1 (basse) à 100 (haute)
VBoxManage modifyvm "MaVM" --cpu-profile "host"
```

#### Topologie CPU

```bash
# Configurer la topologie: sockets × cœurs × threads
# Exemple: 2 sockets, 2 cœurs par socket = 4 vCPUs total
VBoxManage modifyvm "MaVM" --cpus 4 --cpu-profile "host"

# Activer le hotplugging CPU (ajouter/retirer CPU à chaud)
# Fonctionne uniquement avec certains OS invités
VBoxManage modifyvm "MaVM" --cpuhotplug on
```

> [!warning] Piège courant : Over-allocation Allouer 8 vCPUs à une VM sur un hôte 4 cœurs causera des contentions et des performances **pires** qu'avec 2-4 vCPUs. Le système d'exploitation invité attendra constamment que les cœurs physiques se libèrent.

---

## Firmware (BIOS/EFI)

### 🔧 Types de Firmware

VirtualBox propose deux types de firmware pour démarrer les VMs:

|Firmware|Description|Usage|
|---|---|---|
|**BIOS**|Firmware traditionnel, Legacy|Anciens OS, compatibilité maximale|
|**EFI**|Firmware moderne, UEFI|Windows 8+, Linux modernes, Secure Boot|

#### Configuration du type de firmware

```bash
# Utiliser le BIOS classique (par défaut)
VBoxManage modifyvm "MaVM" --firmware bios

# Utiliser EFI (UEFI)
VBoxManage modifyvm "MaVM" --firmware efi

# Utiliser EFI avec support 32 bits
VBoxManage modifyvm "MaVM" --firmware efi32

# Utiliser EFI avec support 64 bits
VBoxManage modifyvm "MaVM" --firmware efi64
```

> [!info] Quand choisir EFI ?
> 
> - Installation de Windows 10/11 moderne
> - Systèmes Linux récents (Ubuntu 20.04+, Fedora 30+)
> - Besoin de disques > 2 To (GPT requis)
> - Utilisation du Secure Boot
> - Boot plus rapide

> [!warning] Attention au changement de firmware Changer le firmware après l'installation de l'OS invité peut rendre la VM **non-démarrable**. Le type de firmware doit être choisi **avant** l'installation.

### 🔐 Secure Boot

Le Secure Boot est une fonctionnalité UEFI qui vérifie la signature numérique des chargeurs de démarrage.

```bash
# Activer le Secure Boot (nécessite EFI)
VBoxManage modifyvm "MaVM" --firmware efi
VBoxManage modifyvm "MaVM" --secureBoot on

# Désactiver le Secure Boot
VBoxManage modifyvm "MaVM" --secureBoot off
```

> [!tip] Cas d'usage du Secure Boot
> 
> - Tests de compatibilité pour distributions Linux
> - Simulation d'environnements Windows sécurisés
> - Validation de drivers signés

### ⚡ Options avancées du BIOS/EFI

```bash
# Activer/désactiver le logo VirtualBox au démarrage
VBoxManage modifyvm "MaVM" --bioslogoimagepath ""

# Définir l'ordre de recherche PXE (boot réseau)
VBoxManage modifyvm "MaVM" --biosbootmenu menuonly

# Activer le mode APIC (Advanced Programmable Interrupt Controller)
# Nécessaire pour les OS multiprocesseurs
VBoxManage modifyvm "MaVM" --ioapic on

# Configurer le temps système de la VM
# Utiliser l'heure de l'hôte (recommandé)
VBoxManage modifyvm "MaVM" --rtcuseutc on
```

---

## Boot Order

### 🚀 Ordre de démarrage

L'ordre de démarrage détermine la séquence dans laquelle la VM cherche un système d'exploitation à charger.

#### Configuration de base

```bash
# Définir l'ordre de démarrage
# boot1 = premier périphérique, boot4 = quatrième
# Valeurs possibles: none, floppy, dvd, disk, net

# Exemple 1: DVD puis disque dur
VBoxManage modifyvm "MaVM" --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Exemple 2: Disque dur uniquement (après installation)
VBoxManage modifyvm "MaVM" --boot1 disk --boot2 none --boot3 none --boot4 none

# Exemple 3: Boot réseau (PXE) puis disque dur
VBoxManage modifyvm "MaVM" --boot1 net --boot2 disk --boot3 none --boot4 none
```

> [!example] Scénarios courants
> 
> **Installation d'un OS:**
> 
> ```bash
> # DVD en premier pour booter sur l'ISO d'installation
> VBoxManage modifyvm "MaVM" --boot1 dvd --boot2 disk
> ```
> 
> **Après installation:**
> 
> ```bash
> # Disque dur uniquement pour éviter les boot accidentels
> VBoxManage modifyvm "MaVM" --boot1 disk --boot2 none
> ```
> 
> **Serveur PXE:**
> 
> ```bash
> # Boot réseau pour déploiement automatisé
> VBoxManage modifyvm "MaVM" --boot1 net --boot2 disk
> ```

### 🎯 Stratégies de Boot Order

|Position|Périphérique|Usage typique|
|---|---|---|
|boot1|dvd|Phase d'installation|
|boot1|disk|Utilisation normale|
|boot1|net|Déploiement PXE, diskless|
|boot2|disk|Fallback après DVD/Net|
|boot3-4|none|Désactivé|

> [!tip] Astuce pour les tests Pendant la phase de test, garder l'ordre `dvd → disk` permet de rapidement réinstaller en attachant simplement un ISO au lecteur DVD virtuel.

> [!warning] Piège: DVD persistant Si vous laissez un ISO monté avec `boot1 dvd`, la VM bootera toujours dessus au lieu du disque installé. Pensez à :
> 
> - Soit démonter l'ISO après installation
> - Soit changer l'ordre de boot vers `disk` uniquement

---

## Carte Graphique et VRAM

### 🎨 Contrôleur Graphique

VirtualBox propose plusieurs contrôleurs graphiques avec des fonctionnalités différentes.

#### Types de contrôleurs

```bash
# VBoxVGA (par défaut, compatible)
VBoxManage modifyvm "MaVM" --graphicscontroller vboxvga

# VMSVGA (recommandé pour Linux/Windows modernes)
VBoxManage modifyvm "MaVM" --graphicscontroller vmsvga

# VBoxSVGA (compatible SVGA, pour anciens OS)
VBoxManage modifyvm "MaVM" --graphicscontroller vboxsvga

# None (pas d'accélération graphique)
VBoxManage modifyvm "MaVM" --graphicscontroller none
```

|Contrôleur|OS recommandés|Accélération 3D|Usage|
|---|---|---|---|
|**VBoxVGA**|Ancien Windows, DOS|Limitée|Compatibilité maximale|
|**VMSVGA**|Linux, Windows 7+|Oui|Recommandé par défaut|
|**VBoxSVGA**|Windows XP/Vista|Partielle|Legacy|
|**None**|Serveurs headless|Non|Sans interface graphique|

> [!info] Choix du contrôleur Pour la plupart des cas modernes, **VMSVGA** est le meilleur choix : bonnes performances, large compatibilité, et support de l'accélération 3D.

### 💫 VRAM (Video RAM)

La VRAM est la mémoire dédiée à l'affichage graphique de la VM.

```bash
# Définir la VRAM (en Mo)
# Minimum: 8 Mo, Maximum: 128 Mo
VBoxManage modifyvm "MaVM" --vram 128

# Vérifier la VRAM allouée
VBoxManage showvminfo "MaVM" | grep "VRAM"
```

> [!example] Recommandations VRAM
> 
> |Résolution / Usage|VRAM recommandée|
> |---|---|
> |1024×768 (basique)|16-32 Mo|
> |1920×1080 (Full HD)|64 Mo|
> |2560×1440 (2K)|128 Mo|
> |Multi-écrans|128 Mo|
> |Accélération 3D|128 Mo|

```bash
# Configuration optimale pour desktop moderne
VBoxManage modifyvm "MaVM" \
  --graphicscontroller vmsvga \
  --vram 128 \
  --accelerate3d on \
  --accelerate2dvideo on
```

### 🚀 Accélération Graphique

#### Accélération 3D

```bash
# Activer l'accélération 3D
VBoxManage modifyvm "MaVM" --accelerate3d on

# Désactiver l'accélération 3D
VBoxManage modifyvm "MaVM" --accelerate3d off
```

> [!warning] Limitations de l'accélération 3D
> 
> - Fonctionne mieux avec VMSVGA
> - Support partiel d'OpenGL et Direct3D
> - Ne remplace pas une vraie carte graphique
> - Peut causer des artefacts visuels sur certains OS
> - Non recommandé pour les jeux gourmands

#### Accélération 2D

```bash
# Activer l'accélération 2D vidéo
# Améliore la lecture de vidéos dans la VM
VBoxManage modifyvm "MaVM" --accelerate2dvideo on
```

### 🖥️ Configuration Multi-écrans

```bash
# Définir le nombre de moniteurs virtuels (1-8)
VBoxManage modifyvm "MaVM" --monitorcount 2

# Vérifier la configuration
VBoxManage showvminfo "MaVM" | grep "Monitor count"
```

> [!tip] Utilisation multi-écrans
> 
> - Nécessite les Guest Additions installées dans la VM
> - Augmenter la VRAM en conséquence (64-128 Mo minimum)
> - Utile pour des workflows de développement ou productivité

### 📹 Mode d'affichage

```bash
# Mode scale (mise à l'échelle automatique)
VBoxManage setextradata "MaVM" GUI/ScaleFactor 1.5

# Désactiver la capture souris automatique
VBoxManage modifyvm "MaVM" --mouse usbtablet
```

> [!warning] Piège: VRAM insuffisante Une VRAM trop faible (8-16 Mo) avec une haute résolution (1920×1080) causera:
> 
> - Scintillement de l'écran
> - Artefacts graphiques
> - Impossibilité d'utiliser certaines résolutions
> - Erreurs lors de l'activation de l'accélération 3D

---

## Audio et USB

### 🔊 Configuration Audio

VirtualBox peut émuler différents contrôleurs audio pour la VM.

#### Activation de l'audio

```bash
# Activer l'audio
VBoxManage modifyvm "MaVM" --audio on

# Désactiver l'audio
VBoxManage modifyvm "MaVM" --audio off
```

#### Choix du driver audio (hôte)

Le driver audio dépend du système d'exploitation **hôte** (là où VirtualBox tourne).

```bash
# Linux (ALSA)
VBoxManage modifyvm "MaVM" --audiodriver alsa

# Linux (PulseAudio) - recommandé sur distributions modernes
VBoxManage modifyvm "MaVM" --audiodriver pulse

# macOS (CoreAudio)
VBoxManage modifyvm "MaVM" --audiodriver coreaudio

# Windows (DirectSound)
VBoxManage modifyvm "MaVM" --audiodriver dsound

# Windows (Windows Audio Session API) - recommandé Windows Vista+
VBoxManage modifyvm "MaVM" --audiodriver was
```

> [!tip] Quel driver choisir ?
> 
> - **Linux moderne**: PulseAudio (`pulse`)
> - **Linux ancien**: ALSA (`alsa`)
> - **Windows 10/11**: WASAPI (`was`)
> - **Windows 7/8**: DirectSound (`dsound`)
> - **macOS**: CoreAudio (`coreaudio`)

#### Contrôleur audio (invité)

Le contrôleur audio émule le matériel vu par l'OS **invité** (dans la VM).

```bash
# Intel HD Audio (recommandé, moderne)
VBoxManage modifyvm "MaVM" --audiocontroller hda

# Intel ICH AC97 (compatible, ancien)
VBoxManage modifyvm "MaVM" --audiocontroller ac97

# SoundBlaster 16 (très ancien, DOS/Windows 9x)
VBoxManage modifyvm "MaVM" --audiocontroller sb16
```

|Contrôleur|Compatibilité|Usage|
|---|---|---|
|**HDA**|Windows Vista+, Linux moderne|Recommandé par défaut|
|**AC97**|Windows XP, anciennes distributions|Legacy|
|**SB16**|DOS, Windows 95/98|Rétro-gaming|

#### Configuration complète audio

```bash
# Configuration optimale pour Linux hôte, Windows 10 invité
VBoxManage modifyvm "MaVM" \
  --audio on \
  --audiodriver pulse \
  --audiocontroller hda \
  --audioin on \
  --audioout on
```

```bash
# Activer entrée audio (microphone)
VBoxManage modifyvm "MaVM" --audioin on

# Activer sortie audio (haut-parleurs)
VBoxManage modifyvm "MaVM" --audioout on
```

> [!warning] Problèmes audio courants
> 
> - **Latence audio**: utiliser WASAPI sur Windows ou PulseAudio sur Linux
> - **Pas de son**: vérifier que le contrôleur est compatible avec l'OS invité
> - **Crépitements**: réduire la charge CPU de la VM ou augmenter la priorité

### 🔌 Configuration USB

VirtualBox supporte l'USB 1.1, 2.0 et 3.0 selon la version et les extensions installées.

#### Activation du contrôleur USB

```bash
# Activer USB 1.1 (OHCI)
VBoxManage modifyvm "MaVM" --usb on
VBoxManage modifyvm "MaVM" --usbohci on

# Activer USB 2.0 (EHCI) - nécessite Extension Pack
VBoxManage modifyvm "MaVM" --usbehci on

# Activer USB 3.0 (xHCI) - nécessite Extension Pack
VBoxManage modifyvm "MaVM" --usbxhci on

# Désactiver tous les contrôleurs USB
VBoxManage modifyvm "MaVM" --usb off
```

> [!info] Extension Pack requis Les contrôleurs USB 2.0 (EHCI) et USB 3.0 (xHCI) nécessitent l'installation du **VirtualBox Extension Pack**, téléchargeable gratuitement depuis le site officiel pour usage personnel.

#### Filtres USB

Les filtres USB permettent d'attacher automatiquement des périphériques USB à la VM.

```bash
# Ajouter un filtre USB
# --target : uuid de la VM
# --name : nom du filtre
# --vendorid : ID vendeur (format hexadécimal)
# --productid : ID produit (format hexadécimal)

VBoxManage usbfilter add 0 \
  --target "MaVM" \
  --name "Clé USB Kingston" \
  --vendorid 0951 \
  --productid 1666

# Lister les filtres USB d'une VM
VBoxManage showvminfo "MaVM" | grep -A 10 "USB Device Filters"

# Supprimer un filtre USB (par index)
VBoxManage usbfilter remove 0 --target "MaVM"
```

> [!example] Trouver les IDs USB
> 
> ```bash
> # Sur Linux
> lsusb
> # Résultat: Bus 001 Device 005: ID 0951:1666 Kingston Technology
> 
> # Sur Windows (PowerShell)
> Get-PnpDevice -Class USB | Select-Object InstanceId, FriendlyName
> ```

#### Configuration complète USB

```bash
# Configuration USB 3.0 complète avec filtre
VBoxManage modifyvm "MaVM" --usb on --usbxhci on

VBoxManage usbfilter add 0 \
  --target "MaVM" \
  --name "Imprimante HP" \
  --vendorid 03f0 \
  --productid 1234 \
  --remote no
```

### 🎛️ Options USB avancées

```bash
# Activer la tablette USB (améliore l'intégration souris)
# Recommandé pour l'utilisation desktop
VBoxManage modifyvm "MaVM" --mouse usbtablet

# Utiliser la souris PS/2 classique (serveurs, anciens OS)
VBoxManage modifyvm "MaVM" --mouse ps2

# Désactiver totalement l'USB (serveurs headless)
VBoxManage modifyvm "MaVM" --usb off
```

> [!tip] Tablette USB vs PS/2
> 
> - **USB Tablet** (recommandé): intégration transparente de la souris, pas besoin de "capturer" la souris
> - **PS/2 Mouse**: nécessite de capturer/libérer la souris avec une touche (Host key), mais plus compatible avec très anciens OS

### 📱 USB sur le réseau (USB/IP)

```bash
# Activer l'accès USB distant via VRDP
VBoxManage modifyvm "MaVM" --vrde on
VBoxManage modifyvm "MaVM" --vrdeport 3389
VBoxManage modifyvm "MaVM" --vrdeauthtype null

# Les périphériques USB pourront être attachés depuis le client RDP
```

> [!warning] Limitations USB
> 
> - Les périphériques USB peuvent être attachés soit à l'hôte, soit à la VM, **pas les deux simultanément**
> - Certains périphériques (claviers/souris Bluetooth) peuvent causer des problèmes
> - Les dongles de protection logicielle peuvent ne pas fonctionner correctement
> - Les performances USB 3.0 en virtualisation sont inférieures au natif

---

## 📌 Récapitulatif des commandes essentielles

```bash
# Configuration complète d'une VM desktop moderne
VBoxManage modifyvm "MaVM" \
  --memory 8192 \
  --cpus 4 \
  --vram 128 \
  --graphicscontroller vmsvga \
  --accelerate3d on \
  --firmware efi \
  --boot1 disk \
  --boot2 none \
  --audio on \
  --audiodriver pulse \
  --audiocontroller hda \
  --usb on \
  --usbxhci on \
  --mouse usbtablet

# Configuration d'un serveur sans interface graphique
VBoxManage modifyvm "MonServeur" \
  --memory 4096 \
  --cpus 2 \
  --vram 16 \
  --graphicscontroller none \
  --firmware bios \
  --boot1 disk \
  --audio off \
  --usb off
```

> [!tip] Bonnes pratiques générales
> 
> - Toujours vérifier l'état de la VM avant modification (`showvminfo`)
> - Garder une trace des commandes utilisées pour reproduire les configurations
> - Tester les modifications avant de les appliquer en production
> - Documenter les configurations spécifiques à vos besoins