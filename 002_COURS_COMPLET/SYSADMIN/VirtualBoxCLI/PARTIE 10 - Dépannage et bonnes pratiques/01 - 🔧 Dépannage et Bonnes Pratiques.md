

> [!info] Vue d'ensemble Cette section couvre le dépannage des problèmes courants rencontrés avec VirtualBox en ligne de commande. Vous apprendrez à diagnostiquer, analyser et résoudre les erreurs les plus fréquentes.

---

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

## 🚨 Erreurs fréquentes et solutions

### Erreur : "VBOX_E_INVALID_OBJECT_STATE"

> [!warning] Symptôme Cette erreur apparaît généralement lorsqu'on tente d'effectuer une opération sur une VM dans un état incompatible.

**Cause principale** : Tentative de modifier une VM en cours d'exécution ou dans un état transitoire.

```bash
# ❌ Erreur typique
VBoxManage modifyvm "MaVM" --memory 4096
# Error: The machine 'MaVM' is already locked for a session (or being unlocked)

# ✅ Solution : Vérifier l'état avant modification
VBoxManage showvminfo "MaVM" --machinereadable | grep "VMState="

# Si la VM est en cours d'exécution, l'arrêter d'abord
VBoxManage controlvm "MaVM" poweroff
# Attendre quelques secondes
sleep 3
# Puis modifier
VBoxManage modifyvm "MaVM" --memory 4096
```

> [!tip] Astuce Utilisez toujours `--machinereadable` pour scripter la vérification d'état de manière fiable.

---

### Erreur : "VERR_VMX_NO_VMX" ou "VERR_SVM_NO_SVM"

> [!warning] Symptôme Impossible de démarrer une VM 64 bits ou avec virtualisation matérielle.

**Causes possibles** :

- Virtualisation matérielle désactivée dans le BIOS/UEFI
- Hyper-V activé sous Windows (conflit)
- CPU ne supportant pas VT-x/AMD-V

```bash
# Vérifier si VT-x/AMD-V est disponible
VBoxManage list hostinfo | grep -i "virtualization"

# Sous Linux, vérifier le support CPU
grep -E 'vmx|svm' /proc/cpuinfo

# Vérifier si une VM nécessite la virtualisation matérielle
VBoxManage showvminfo "MaVM" | grep "Hardware virtualization"
```

**Solutions** :

1. Activer VT-x/AMD-V dans le BIOS
2. Sous Windows : désactiver Hyper-V

```bash
# Vérifier l'état Hyper-V (PowerShell admin)
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

# Désactiver Hyper-V (nécessite redémarrage)
bcdedit /set hypervisorlaunchtype off
```

---

### Erreur : "VERR_ACCESS_DENIED"

> [!warning] Symptôme Accès refusé lors d'opérations sur les fichiers VDI ou configuration.

```bash
# ❌ Erreur typique
VBoxManage startvm "MaVM"
# Error: VERR_ACCESS_DENIED

# ✅ Solution : Vérifier les permissions
# Sous Linux/Mac
ls -l ~/VirtualBox\ VMs/MaVM/
# Le fichier doit appartenir à votre utilisateur

# Corriger les permissions si nécessaire
chmod 600 ~/VirtualBox\ VMs/MaVM/*.vdi
chmod 644 ~/VirtualBox\ VMs/MaVM/*.vbox

# Sous Windows (PowerShell admin)
icacls "C:\Users\User\VirtualBox VMs\MaVM" /grant %USERNAME%:F /T
```

> [!tip] Piège courant Ce problème survient souvent après avoir copié une VM ou exécuté VirtualBox avec sudo/admin par erreur.

---

### Erreur : "UUID already exists"

> [!warning] Symptôme Lors de l'import ou du clonage, conflit d'UUID de disque.

```bash
# ❌ Erreur lors de l'ajout d'un disque copié
VBoxManage storageattach "MaVM" --storagectl "SATA" --port 0 \
  --device 0 --type hdd --medium /path/to/copied.vdi
# Error: UUID {xxx-xxx-xxx} of the medium already exists

# ✅ Solution : Changer l'UUID du disque
VBoxManage internalcommands sethduuid /path/to/copied.vdi

# Ou cloner correctement le disque
VBoxManage clonemedium disk source.vdi destination.vdi

# Vérifier l'UUID assigné
VBoxManage showhdinfo /path/to/copied.vdi | grep UUID
```

---

### Erreur : "NS_ERROR_FAILURE"

> [!warning] Symptôme Erreur générique lors d'opérations diverses.

**Causes multiples** : Configuration corrompue, verrouillage de fichier, problème de réseau.

```bash
# Diagnostic général
# 1. Vérifier l'intégrité de la VM
VBoxManage showvminfo "MaVM" > /dev/null 2>&1
echo $?  # Si différent de 0, configuration corrompue

# 2. Vérifier les fichiers verrouillés
find ~/VirtualBox\ VMs/MaVM/ -name "*.lock"

# 3. Nettoyer les sessions inaccessibles
VBoxManage list vms | grep "inaccessible"
# Si des VMs inaccessibles apparaissent :
VBoxManage unregistervm {UUID} --delete

# 4. Recréer la configuration VirtualBox (dernier recours)
# Sous Linux/Mac
mv ~/.config/VirtualBox/VirtualBox.xml ~/.config/VirtualBox/VirtualBox.xml.backup
# Sous Windows
# Renommer %USERPROFILE%\.VirtualBox\VirtualBox.xml
```

> [!tip] Prévention Sauvegardez régulièrement les fichiers `.vbox` de vos VMs importantes.

---

## 🚀 Problèmes de démarrage

### La VM ne démarre pas - Diagnostic méthodique

> [!example] Approche systématique Suivez ces étapes dans l'ordre pour diagnostiquer un problème de démarrage.

#### Étape 1 : Vérifier l'état de la VM

```bash
# Obtenir l'état actuel
VBoxManage showvminfo "MaVM" --machinereadable | grep "VMState="

# États possibles et signification :
# - poweroff : éteinte normalement
# - saved : état sauvegardé
# - aborted : arrêt brutal précédent
# - stuck : bloquée (problème)
# - running : déjà en cours d'exécution
```

#### Étape 2 : Vérifier les fichiers essentiels

```bash
# Vérifier l'existence et l'accès aux fichiers
VM_DIR=~/VirtualBox\ VMs/MaVM

# Fichier de configuration
test -r "$VM_DIR/MaVM.vbox" && echo "Config OK" || echo "Config manquante/inaccessible"

# Disque dur virtuel
test -r "$VM_DIR/MaVM.vdi" && echo "Disque OK" || echo "Disque manquant/inaccessible"

# Vérifier l'intégrité du disque
VBoxManage showmediuminfo "$VM_DIR/MaVM.vdi"
```

#### Étape 3 : Nettoyer les sessions bloquées

```bash
# Libérer une session verrouillée
VBoxManage startvm "MaVM" --type emergencystop

# Attendre que le processus se termine
sleep 2

# Supprimer les fichiers de verrouillage si présents
rm -f ~/VirtualBox\ VMs/MaVM/*.lock 2>/dev/null
```

#### Étape 4 : Tenter un démarrage en mode debug

```bash
# Démarrer avec sortie détaillée
VBoxManage startvm "MaVM" --type gui --debug

# Ou en mode headless avec logs verbeux
VBoxManage startvm "MaVM" --type headless --debug-command-line \
  --start-running --dbg-enabled --dbg-auto-start
```

---

### Erreur de boot - "No bootable medium found"

> [!warning] Symptôme La VM démarre mais affiche "No bootable medium found" ou "FATAL: No bootable medium found!"

```bash
# Vérifier l'ordre de démarrage
VBoxManage showvminfo "MaVM" | grep "Boot"

# Modifier l'ordre de démarrage (disk, dvd, net, floppy)
VBoxManage modifyvm "MaVM" --boot1 disk --boot2 dvd --boot3 none --boot4 none

# Vérifier les contrôleurs de stockage
VBoxManage showvminfo "MaVM" | grep -A 20 "Storage Controller"

# Vérifier qu'un disque est bien attaché
VBoxManage showvminfo "MaVM" | grep "SATA.*vdi"

# Si aucun disque n'est attaché, l'attacher
VBoxManage storageattach "MaVM" --storagectl "SATA Controller" \
  --port 0 --device 0 --type hdd --medium /path/to/disk.vdi
```

---

### La VM démarre puis se fige

> [!warning] Symptôme La VM commence à démarrer mais se bloque pendant le boot du système d'exploitation.

**Causes possibles** :

- Ressources insuffisantes (RAM/CPU)
- Problème avec les Guest Additions
- Conflit d'ACPI
- Disque corrompu

```bash
# 1. Augmenter les ressources
VBoxManage modifyvm "MaVM" --memory 2048 --cpus 2

# 2. Désactiver temporairement l'ACPI pour tester
VBoxManage modifyvm "MaVM" --acpi off

# 3. Activer le mode PAE si nécessaire (pour certains OS 32 bits)
VBoxManage modifyvm "MaVM" --pae on

# 4. Modifier le chipset si problème avec PIIX3
VBoxManage modifyvm "MaVM" --chipset ich9

# 5. Vérifier l'intégrité du disque
VBoxManage showmediuminfo disk /path/to/disk.vdi | grep State
# State devrait être "created" et non "inaccessible"

# 6. En dernier recours : démarrer en mode sans échec
# Dépend de l'OS invité, mais généralement :
# - Pour Windows : appuyer sur F8 au démarrage
# - Pour Linux : éditer GRUB et ajouter "single" ou "1"
```

> [!tip] Astuce de dépannage Créez un snapshot avant les modifications importantes pour pouvoir revenir en arrière rapidement.

---

## 🌐 Conflits réseau

### Impossible de pinguer la VM ou l'hôte

> [!info] Diagnostic réseau Les problèmes réseau dépendent fortement du mode réseau utilisé (NAT, Bridged, Host-only, etc.).

#### Vérifier la configuration réseau actuelle

```bash
# Afficher la configuration réseau complète
VBoxManage showvminfo "MaVM" | grep -i "nic"

# Exemple de sortie :
# NIC 1: MAC: 080027XXXXXX, Attachment: NAT, Cable connected: on
```

#### Tableau des modes réseau et troubleshooting

|Mode réseau|VM → Hôte|VM → Internet|VM → VM|Cas d'usage|Dépannage|
|---|---|---|---|---|---|
|**NAT**|❌ Non|✅ Oui|❌ Non|Navigation web simple|Vérifier redirection de ports|
|**NAT Network**|❌ Non|✅ Oui|✅ Oui|VMs doivent communiquer|Vérifier même réseau NAT|
|**Bridged**|✅ Oui|✅ Oui|✅ Oui|VM comme machine du réseau|Vérifier interface bridgée|
|**Host-only**|✅ Oui|❌ Non|✅ Oui|Isolation sécurisée|Vérifier configuration DHCP|
|**Internal**|❌ Non|❌ Non|✅ Oui|Réseau privé entre VMs|Vérifier même réseau interne|

---

### Problème : NAT ne fonctionne pas

```bash
# Vérifier la configuration NAT
VBoxManage showvminfo "MaVM" | grep "NIC 1"

# Si NAT mais pas d'accès Internet depuis la VM :

# 1. Vérifier que le câble virtuel est connecté
VBoxManage modifyvm "MaVM" --cableconnected1 on

# 2. Reconfigurer l'adaptateur en NAT
VBoxManage modifyvm "MaVM" --nic1 nat

# 3. Configurer le DNS dans la VM (depuis l'invité)
# Pour tester, utiliser les DNS publics : 8.8.8.8 ou 1.1.1.1

# 4. Vérifier les règles de redirection de port si nécessaire
VBoxManage showvminfo "MaVM" | grep "NIC.*Rule"

# Ajouter une redirection SSH par exemple
VBoxManage modifyvm "MaVM" --natpf1 "ssh,tcp,,2222,,22"
# Format : "nom,protocole,ip_hote,port_hote,ip_invite,port_invite"
```

> [!warning] Piège NAT En mode NAT standard, la VM n'est pas accessible depuis l'hôte sans redirection de ports explicite.

---

### Problème : Bridged ne fonctionne pas

```bash
# 1. Lister les interfaces réseau de l'hôte disponibles
VBoxManage list bridgedifs

# 2. Configurer correctement l'interface bridgée
# Remplacer "eth0" par votre interface active (wlan0, enp0s3, etc.)
VBoxManage modifyvm "MaVM" --nic1 bridged --bridgeadapter1 "eth0"

# Sous Windows, l'interface peut avoir un nom long :
VBoxManage modifyvm "MaVM" --nic1 bridged \
  --bridgeadapter1 "Intel(R) Ethernet Connection"

# 3. Vérifier que le câble est connecté
VBoxManage modifyvm "MaVM" --cableconnected1 on

# 4. Vérifier le mode promiscuous (parfois nécessaire)
VBoxManage modifyvm "MaVM" --nicpromisc1 allow-all
```

**Problèmes courants en bridged** :

- Pare-feu de l'hôte bloquant le trafic
- Routeur ne donnant pas d'IP DHCP aux VMs
- Interface WiFi ne supportant pas le bridging (limitation matérielle)

> [!tip] Alternative WiFi Si le bridging ne fonctionne pas sur WiFi, utilisez NAT Network ou Host-only avec partage de connexion.

---

### Problème : Host-only sans connectivité

```bash
# 1. Vérifier l'existence des réseaux Host-only
VBoxManage list hostonlyifs

# Si aucun réseau n'existe, en créer un
VBoxManage hostonlyif create
# Note l'interface créée, ex: vboxnet0

# 2. Configurer l'IP et le DHCP pour le réseau Host-only
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0

# 3. Activer le serveur DHCP
VBoxManage dhcpserver add --ifname vboxnet0 \
  --ip 192.168.56.1 \
  --netmask 255.255.255.0 \
  --lowerip 192.168.56.100 \
  --upperip 192.168.56.200 \
  --enable

# 4. Attacher la VM au réseau Host-only
VBoxManage modifyvm "MaVM" --nic1 hostonly --hostonlyadapter1 vboxnet0

# 5. Vérifier la configuration DHCP du serveur
VBoxManage list dhcpservers
```

---

### Configuration multi-adaptateurs

> [!example] Cas d'usage : VM accessible depuis l'hôte ET avec accès Internet

```bash
# Configurer deux adaptateurs réseau :
# - NIC1 en NAT pour Internet
# - NIC2 en Host-only pour accès depuis l'hôte

# Adaptateur 1 : NAT pour Internet
VBoxManage modifyvm "MaVM" --nic1 nat --cableconnected1 on

# Adaptateur 2 : Host-only pour communication hôte
VBoxManage modifyvm "MaVM" --nic2 hostonly \
  --hostonlyadapter2 vboxnet0 \
  --cableconnected2 on

# Vérifier la configuration
VBoxManage showvminfo "MaVM" | grep "NIC [12]"
```

**Configuration dans la VM (Linux invité)** :

```bash
# Vérifier les interfaces
ip addr show

# Configuration typique à obtenir :
# - enp0s3 : pour NAT (accès Internet)
# - enp0s8 : pour Host-only (IP 192.168.56.x)

# Si pas d'IP sur enp0s8, activer DHCP
sudo dhclient enp0s8

# Ou configuration statique
sudo ip addr add 192.168.56.50/24 dev enp0s8
sudo ip link set enp0s8 up
```

---

## ⚡ Problèmes de performance

### La VM est extrêmement lente

> [!warning] Diagnostic de performance Les problèmes de performance peuvent avoir de multiples causes. Procédez méthodiquement.

#### Vérifications de base

```bash
# 1. Vérifier les ressources allouées
VBoxManage showvminfo "MaVM" | grep -E "Memory|CPU|Graphics|acceleration"

# Sorties importantes :
# Memory size: doit être suffisant (2048+ MB recommandé)
# Number of CPUs: au moins 2 pour un usage fluide
# VT-x/AMD-V: enabled (crucial pour les performances)
# Nested Paging: enabled (important)
# Graphics Controller: VMSVGA ou VBoxSVGA
# 3D Acceleration: peut améliorer l'interface graphique
```

#### Optimisations recommandées

```bash
# 1. Allouer plus de RAM (sans dépasser 50% de la RAM physique)
VBoxManage modifyvm "MaVM" --memory 4096

# 2. Allouer plus de CPUs (sans dépasser le nombre de cœurs physiques)
VBoxManage modifyvm "MaVM" --cpus 2

# 3. Activer VT-x/AMD-V et Nested Paging
VBoxManage modifyvm "MaVM" --hwvirtex on
VBoxManage modifyvm "MaVM" --nestedpaging on

# 4. Augmenter la mémoire vidéo (pour interface graphique)
VBoxManage modifyvm "MaVM" --vram 128

# 5. Activer l'accélération 3D (pour OS modernes avec GUI)
VBoxManage modifyvm "MaVM" --accelerate3d on

# 6. Activer PAE/NX (pour certains OS 32 bits)
VBoxManage modifyvm "MaVM" --pae on

# 7. Optimiser le contrôleur de stockage
# Utiliser SATA avec mise en cache Host
VBoxManage storagectl "MaVM" --name "SATA" --hostiocache on

# 8. Activer le mode AHCI pour le SATA
VBoxManage storagectl "MaVM" --name "SATA" --portcount 4 --bootable on
```

> [!tip] RAM optimale Formule recommandée : RAM VM = (RAM hôte - 2GB) / nombre de VMs simultanées. Minimum 2GB pour Linux léger, 4GB pour Windows 10/11.

---

### Le disque est lent - Optimisations I/O

```bash
# 1. Vérifier le type de disque
VBoxManage showmediuminfo disk /path/to/disk.vdi | grep "Type"
# Le type "normal" est recommandé pour les performances

# 2. Utiliser un disque à taille fixe plutôt que dynamique
# Les disques à taille fixe sont plus rapides mais prennent plus d'espace
# Lors de la création :
VBoxManage createmedium disk --filename fast.vdi \
  --size 20480 --variant Fixed

# 3. Activer le cache I/O hôte
VBoxManage storageattach "MaVM" --storagectl "SATA" \
  --port 0 --device 0 --type hdd --medium /path/to/disk.vdi \
  --mtype normal --nonrotational on --discard on

# 4. Optimiser le contrôleur SATA
VBoxManage storagectl "MaVM" --name "SATA" --hostiocache on

# 5. Activer le trim/discard pour les SSD
VBoxManage storageattach "MaVM" --storagectl "SATA" \
  --port 0 --device 0 --discard on --nonrotational on
```

#### Compacter un disque dynamique

```bash
# Si vous utilisez un disque dynamique qui a grandi, le compacter

# Étape 1 : Depuis l'invité, remplir l'espace libre avec des zéros
# Linux :
sudo dd if=/dev/zero of=/bigfile bs=1M; sudo rm /bigfile
# Windows : utiliser sdelete -z C:

# Étape 2 : Depuis l'hôte, compacter le disque
VBoxManage modifymedium disk /path/to/disk.vdi --compact
```

---

### Performance graphique faible

```bash
# 1. Augmenter la mémoire vidéo au maximum
VBoxManage modifyvm "MaVM" --vram 256

# 2. Changer le contrôleur graphique
# Tester différents contrôleurs selon l'OS invité :
VBoxManage modifyvm "MaVM" --graphicscontroller vmsvga  # Linux moderne
VBoxManage modifyvm "MaVM" --graphicscontroller vboxsvga  # Windows/Linux ancien
VBoxManage modifyvm "MaVM" --graphicscontroller vboxvga  # Très ancien

# 3. Activer l'accélération 3D (ne fonctionne pas avec tous les OS)
VBoxManage modifyvm "MaVM" --accelerate3d on

# 4. Activer l'accélération 2D (Windows uniquement)
VBoxManage modifyvm "MaVM" --accelerate2dvideo on

# 5. Configurer le nombre de moniteurs
VBoxManage modifyvm "MaVM" --monitorcount 1
```

> [!warning] Accélération 3D L'accélération 3D peut causer des problèmes d'affichage avec certains OS. Testez avec et sans pour comparer.

---

### Script de diagnostic de performance

```bash
#!/bin/bash
# Script de diagnostic des performances VirtualBox

VM_NAME="$1"

if [ -z "$VM_NAME" ]; then
    echo "Usage: $0 <nom_vm>"
    exit 1
fi

echo "=== Diagnostic de performance pour $VM_NAME ==="
echo

echo "--- Ressources allouées ---"
VBoxManage showvminfo "$VM_NAME" --machinereadable | grep -E "memory=|cpus=|vram="

echo
echo "--- Virtualisation matérielle ---"
VBoxManage showvminfo "$VM_NAME" --machinereadable | grep -E "hwvirtex=|nestedpaging=|pae="

echo
echo "--- Configuration graphique ---"
VBoxManage showvminfo "$VM_NAME" --machinereadable | grep -E "graphicscontroller=|accelerate3d=|vram="

echo
echo "--- Contrôleurs de stockage ---"
VBoxManage showvminfo "$VM_NAME" | grep -A 3 "Storage Controller"

echo
echo "--- Utilisation CPU/RAM actuelle (si VM en cours) ---"
VBoxManage metrics query "$VM_NAME" CPU/Load,RAM/Usage 2>/dev/null || echo "VM non démarrée"

echo
echo "=== Recommandations ==="
echo "1. RAM: Minimum 2GB (2048 MB), recommandé 4GB+"
echo "2. CPUs: 2+ pour usage fluide"
echo "3. VRAM: 128 MB minimum, 256 MB pour GUI"
echo "4. Virtualisation matérielle: DOIT être activée (hwvirtex=on)"
echo "5. Nested Paging: DOIT être activée (nestedpaging=on)"
```

---

## 📋 Lecture des logs

### Localisation des fichiers logs

> [!info] Emplacements des logs VirtualBox génère des logs détaillés pour chaque VM et pour le système global.

```bash
# Logs de la VM
# Linux/Mac :
~/VirtualBox\ VMs/MaVM/Logs/

# Windows :
# C:\Users\Username\VirtualBox VMs\MaVM\Logs\

# Structure typique des logs :
# - VBox.log       : log de la dernière session
# - VBox.log.1     : log de l'avant-dernière session
# - VBox.log.2     : log encore plus ancien
# - VBoxHardening.log : logs de sécurité (si applicable)
```

#### Accéder aux logs via CLI

```bash
# Afficher le chemin des logs d'une VM
VBoxManage showvminfo "MaVM" | grep "Log folder"

# Lire le log le plus récent
cat ~/VirtualBox\ VMs/MaVM/Logs/VBox.log

# Suivre le log en temps réel (pendant l'exécution)
tail -f ~/VirtualBox\ VMs/MaVM/Logs/VBox.log

# Chercher des erreurs dans le log
grep -i "error\|fail\|fatal" ~/VirtualBox\ VMs/MaVM/Logs/VBox.log
```

---

### Interpréter les logs - Messages importants

> [!example] Analyse des logs courants

#### Structure d'un log VirtualBox

```
00:00:00.123456 VirtualBox VM 7.0.x
00:00:00.234567 Guest OS type: 'Ubuntu_64'
00:00:01.345678 RAM: 4096MB
00:00:01.456789 CPU: 2 cores
...
```

Le format est : `HH:MM:SS.microsec Message`

---

#### Messages critiques à surveiller

```bash
# 1. Erreurs de démarrage
grep "NS_ERROR_FAILURE\|VERR_\|E_FAIL" VBox.log

# Exemple :
# 00:00:05.678901 ERROR [COM]: aRC=NS_ERROR_FAILURE (0x80004005)
# Indique un échec d'initialisation d'un composant

# 2. Problèmes de virtualisation matérielle
grep "VT-x\|AMD-V\|VERR_VMX\|VERR_SVM" VBox.log

# Exemple :
# 00:00:02.123456 HM: HMR3Init: Attempting fall back to NEM
# Indique que VT-x n'est pas disponible, passage en mode émulation (lent)

# 3. Erreurs de réseau
grep "NAT\|Host-only\|E1000\|PCnet" VBox.log

# Exemple :
# 00:00:10.234567 NAT: Failed to bind socket
# Problème de configuration réseau NAT

# 4. Problèmes de disque
grep "AHCI\|PIIX\|VD\|VERR_VD" VBox.log

# Exemple :
# 00:00:15.345678 VD: error VERR_FILE_NOT_FOUND opening image file
# Disque virtuel introuvable
```

---

#### Niveaux de log et verbosité

```bash
# Par défaut, VirtualBox log au niveau "default"
# Augmenter la verbosité pour debug approfondi

# Définir le niveau de log pour une VM
VBoxManage modifyvm "MaVM" --uartmode1 server /tmp/vbox-serial.log

# Ou utiliser des variables d'environnement (Linux/Mac)
export VBOX_RELEASE_LOG="+all.e.l.f"
export VBOX_RELEASE_LOG_DEST="file=/tmp/debug-vbox.log"
VBoxManage startvm "MaVM"

# Niveaux de log :
# .e   = errors (erreurs)
# .l   = flow/life (flux)
# .f   = flags (drapeaux)
# all  = tous les composants
```

> [!warning] Logs verbeux Les logs en mode debug deviennent très volumineux (plusieurs centaines de MB). Utilisez uniquement pour le dépannage.

---

### Recherche ciblée dans les logs

```bash
# Script de recherche rapide des problèmes courants
#!/bin/bash

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
    echo "Usage: $0 <chemin_vers_VBox.log>"
    exit 1
fi

echo "=== Analyse du log VirtualBox: $LOG_FILE ==="
echo

echo "--- Informations de base ---"
grep -m 1 "VirtualBox VM" "$LOG_FILE"
grep -m 1 "Guest OS" "$LOG_FILE"
grep -m 1 "RAM:" "$LOG_FILE"
grep -m 1 "CPU:" "$LOG_FILE"

echo
echo "--- Erreurs critiques ---"
grep -i "error\|fatal\|failed" "$LOG_FILE" | head -20

echo
echo "--- Problèmes de virtualisation matérielle ---"
grep -i "vt-x\|amd-v\|verr_vmx\|verr_svm\|nem" "$LOG_FILE"

echo
echo "--- Problèmes de stockage ---"
grep -i "ahci\|piix\|verr_vd\|disk" "$LOG_FILE" | grep -i "error\|fail"

echo
echo "--- Problèmes réseau ---"
grep -i "nat\|e1000\|pcnet\|nic" "$LOG_FILE" | grep -i "error\|fail"

echo
echo "--- Avertissements ---"
grep -i "warning" "$LOG_FILE" | head -10
```

**Utilisation** :

```bash
# Rendre le script exécutable
chmod +x analyze_vbox_log.sh

# Analyser le log le plus récent
./analyze_vbox_log.sh ~/VirtualBox\ VMs/MaVM/Logs/VBox.log
```

---

### Exemples de logs et leur signification

#### Exemple 1 : VM qui ne démarre pas

```
00:00:05.123456 ERROR [COM]: aRC=NS_ERROR_FAILURE (0x80004005)
00:00:05.123789 ERROR [COM]: aText=Could not open the medium '/home/user/VirtualBox VMs/MaVM/MaVM.vdi'.
00:00:05.124012 ERROR [COM]: VD: error VERR_FILE_NOT_FOUND opening image file '/home/user/VirtualBox VMs/MaVM/MaVM.vdi'
```

**Diagnostic** : Le fichier VDI est introuvable ou déplacé.

**Solution** :

```bash
# Vérifier l'emplacement du disque
VBoxManage showvminfo "MaVM" | grep "vdi"

# Si le chemin est incorrect, détacher puis réattacher avec le bon chemin
VBoxManage storageattach "MaVM" --storagectl "SATA" \
  --port 0 --device 0 --medium none

VBoxManage storageattach "MaVM" --storagectl "SATA" \
  --port 0 --device 0 --type hdd --medium /chemin/correct/MaVM.vdi
```

---

#### Exemple 2 : Problème de virtualisation matérielle

```
00:00:02.456789 HM: HMR3Init: Attempting fall back to NEM: VT-x is not available
00:00:02.457123 HM: No hardware-assisted virtualization available
00:00:02.457456 NEM: WHvCapabilityCodeHypervisorPresent is FALSE! Make sure you have disabled Hyper-V
```

**Diagnostic** : VT-x désactivé ou Hyper-V en conflit (Windows).

**Solution** :

```bash
# Vérifier le support VT-x/AMD-V
VBoxManage list hostinfo | grep -i "virtualization"

# Si "Processor supports hardware virtualization: no"
# → Activer VT-x/AMD-V dans le BIOS

# Si sous Windows avec Hyper-V actif :
bcdedit /set hypervisorlaunchtype off
# Puis redémarrer

# Vérifier que la VM nécessite VT-x
VBoxManage showvminfo "MaVM" | grep "Hardware virtualization"

# Si pas absolument nécessaire, désactiver temporairement
VBoxManage modifyvm "MaVM" --hwvirtex off
```

---

#### Exemple 3 : Manque de mémoire

```
00:00:15.789012 GIM: Failed to setup TPR patching: VERR_NO_MEMORY
00:00:15.789345 VMM: Raising runtime error 'HostMemoryLow'
00:00:15.789678 GUI: Runtime error: Host system low on memory
```

**Diagnostic** : L'hôte n'a pas assez de RAM disponible.

**Solution** :

```bash
# Réduire la RAM allouée à la VM
VBoxManage modifyvm "MaVM" --memory 2048

# Fermer d'autres applications sur l'hôte

# Vérifier la RAM disponible sur l'hôte
free -h  # Linux
vm_stat  # Mac
# Ou Gestionnaire des tâches sous Windows
```

---

#### Exemple 4 : Problème réseau NAT

```
00:00:20.123456 NAT: Failed to bind socket to 0.0.0.0:2222: VERR_NET_ADDRESS_IN_USE
00:00:20.123789 NAT: Port forwarding rule 'ssh' failed
```

**Diagnostic** : Le port 2222 sur l'hôte est déjà utilisé par une autre application.

**Solution** :

```bash
# Vérifier quel processus utilise le port
# Linux/Mac :
sudo lsof -i :2222
# Windows :
netstat -ano | findstr :2222

# Changer le port de redirection
VBoxManage modifyvm "MaVM" --natpf1 delete "ssh"
VBoxManage modifyvm "MaVM" --natpf1 "ssh,tcp,,2223,,22"
```

---

### Logs système de l'invité

> [!tip] Logs complémentaires Les logs VirtualBox montrent les problèmes de l'hôte. Pour diagnostiquer des problèmes dans l'OS invité, consultez ses propres logs.

#### Accéder aux logs de l'invité depuis l'hôte

```bash
# Si Guest Additions installées, accès via dossiers partagés
# Monter un dossier partagé pour récupérer les logs de l'invité

# Créer un dossier partagé
VBoxManage sharedfolder add "MaVM" --name "logs_share" \
  --hostpath "/tmp/vm_logs" --automount

# Depuis l'invité Linux :
sudo mount -t vboxsf logs_share /mnt/share
sudo cp /var/log/syslog /mnt/share/
sudo cp /var/log/kern.log /mnt/share/

# Depuis l'invité Windows :
# Les logs sont dans l'Observateur d'événements
# Exporter les événements système vers le dossier partagé
```

#### Logs importants à vérifier dans l'invité

**Linux invité** :

```bash
# Logs système généraux
/var/log/syslog
/var/log/messages

# Logs du noyau
/var/log/kern.log
dmesg

# Logs des Guest Additions
/var/log/vboxadd-install.log
```

**Windows invité** :

- Observateur d'événements → Journaux Windows → Système
- Observateur d'événements → Journaux Windows → Application
- `C:\Windows\Logs\VBoxGuest\*`

---

### Activer les logs réseau détaillés

```bash
# Pour diagnostiquer des problèmes réseau complexes
# Activer le traçage pcap pour capturer le trafic réseau

# Activer la capture sur NIC1
VBoxManage modifyvm "MaVM" --nictrace1 on \
  --nictracefile1 /tmp/vm-nic1.pcap

# Démarrer la VM, reproduire le problème, puis arrêter

# Analyser la capture avec wireshark ou tcpdump
tcpdump -r /tmp/vm-nic1.pcap
# Ou ouvrir avec Wireshark pour analyse graphique

# Désactiver la capture
VBoxManage modifyvm "MaVM" --nictrace1 off
```

---

## 🛡️ Bonnes pratiques pour éviter les problèmes

### Checklist avant de démarrer une VM

> [!tip] Prévention La plupart des problèmes peuvent être évités avec des vérifications préalables.

```bash
#!/bin/bash
# Script de vérification pre-démarrage

VM_NAME="$1"

echo "=== Vérifications pré-démarrage pour $VM_NAME ==="

# 1. Vérifier que la VM existe
if ! VBoxManage list vms | grep -q "\"$VM_NAME\""; then
    echo "❌ VM '$VM_NAME' n'existe pas"
    exit 1
fi
echo "✓ VM existe"

# 2. Vérifier l'état de la VM
STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "VMState=" | cut -d'"' -f2)
if [ "$STATE" != "poweroff" ] && [ "$STATE" != "saved" ] && [ "$STATE" != "aborted" ]; then
    echo "❌ VM dans un état incompatible: $STATE"
    exit 1
fi
echo "✓ État de la VM: $STATE"

# 3. Vérifier que les fichiers de disque existent
DISK_PATH=$(VBoxManage showvminfo "$VM_NAME" | grep "\.vdi" | head -1 | sed 's/.*: //' | tr -d '()')
if [ ! -f "$DISK_PATH" ]; then
    echo "❌ Disque virtuel introuvable: $DISK_PATH"
    exit 1
fi
echo "✓ Disque virtuel accessible"

# 4. Vérifier la RAM disponible sur l'hôte
VM_RAM=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "memory=" | cut -d'=' -f2)
# Vérification simplifiée - adapter selon l'OS
echo "✓ RAM VM: ${VM_RAM}MB"

# 5. Vérifier la virtualisation matérielle
HW_VIRT=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "hwvirtex=" | cut -d'"' -f2)
if [ "$HW_VIRT" = "on" ]; then
    if ! VBoxManage list hostinfo | grep -q "Hardware virtualization.*Enabled"; then
        echo "⚠️  Virtualisation matérielle requise mais non disponible"
    else
        echo "✓ Virtualisation matérielle disponible"
    fi
fi

# 6. Vérifier les conflits de port (redirection NAT)
VBoxManage showvminfo "$VM_NAME" | grep "NIC.*Rule" | while read line; do
    PORT=$(echo "$line" | grep -oP 'host port = \K[0-9]+')
    if [ -n "$PORT" ]; then
        if lsof -i ":$PORT" >/dev/null 2>&1; then
            echo "⚠️  Port $PORT déjà utilisé"
        else
            echo "✓ Port $PORT disponible"
        fi
    fi
done

echo
echo "=== Vérifications terminées - Vous pouvez démarrer la VM ==="
```

---

### Maintenance régulière

```bash
# Script de maintenance hebdomadaire VirtualBox

echo "=== Maintenance VirtualBox ==="

# 1. Nettoyer les médias inaccessibles
echo "Nettoyage des médias orphelins..."
VBoxManage list hdds | grep "UUID:" | while read -r line; do
    UUID=$(echo "$line" | awk '{print $2}')
    if VBoxManage showmediuminfo disk "$UUID" 2>&1 | grep -q "VERR_FILE_NOT_FOUND"; then
        echo "Suppression du média inaccessible: $UUID"
        VBoxManage closemedium disk "$UUID" --delete 2>/dev/null
    fi
done

# 2. Compacter les disques dynamiques (si applicable)
echo "Compactage des disques dynamiques..."
VBoxManage list hdds | grep "Location:" | awk '{print $2}' | while read -r disk; do
    TYPE=$(VBoxManage showmediuminfo disk "$disk" | grep "Type:" | awk '{print $2}')
    if [ "$TYPE" = "normal" ]; then
        SIZE_BEFORE=$(du -h "$disk" | cut -f1)
        echo "Compactage de $disk (taille avant: $SIZE_BEFORE)..."
        VBoxManage modifymedium disk "$disk" --compact
    fi
done

# 3. Supprimer les anciennes snapshots (garder les 3 derniers)
echo "Nettoyage des anciens snapshots..."
VBoxManage list vms | cut -d'"' -f2 | while read -r vm; do
    SNAPSHOT_COUNT=$(VBoxManage snapshot "$vm" list 2>/dev/null | grep -c "Name:" || echo 0)
    if [ "$SNAPSHOT_COUNT" -gt 3 ]; then
        echo "VM '$vm' a $SNAPSHOT_COUNT snapshots (nettoyage manuel recommandé)"
    fi
done

# 4. Nettoyer les logs anciens (garder les 5 derniers)
echo "Nettoyage des anciens logs..."
find ~/VirtualBox\ VMs -name "VBox.log.*" -type f | sort -r | tail -n +6 | xargs rm -f 2>/dev/null

# 5. Vérifier les mises à jour VirtualBox
echo "Version actuelle de VirtualBox:"
VBoxManage --version

echo
echo "=== Maintenance terminée ==="
```

---

### Sauvegarde et récupération

> [!warning] Importance des sauvegardes Toujours avoir une stratégie de sauvegarde pour les VMs critiques.

```bash
# Script de sauvegarde d'une VM

VM_NAME="$1"
BACKUP_DIR="/chemin/vers/sauvegardes"
DATE=$(date +%Y%m%d_%H%M%S)

if [ -z "$VM_NAME" ]; then
    echo "Usage: $0 <nom_vm>"
    exit 1
fi

echo "=== Sauvegarde de $VM_NAME ==="

# 1. Vérifier que la VM est éteinte
STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "VMState=" | cut -d'"' -f2)
if [ "$STATE" != "poweroff" ]; then
    echo "❌ La VM doit être éteinte pour la sauvegarde"
    echo "État actuel: $STATE"
    exit 1
fi

# 2. Créer le dossier de sauvegarde
BACKUP_PATH="$BACKUP_DIR/${VM_NAME}_${DATE}"
mkdir -p "$BACKUP_PATH"

# 3. Exporter la VM (OVA)
echo "Export de la VM en format OVA..."
VBoxManage export "$VM_NAME" \
    --output "$BACKUP_PATH/${VM_NAME}.ova" \
    --options manifest,nomacs

# 4. Sauvegarder les snapshots si existants
if VBoxManage snapshot "$VM_NAME" list 2>/dev/null | grep -q "Name:"; then
    echo "Sauvegarde des informations de snapshots..."
    VBoxManage snapshot "$VM_NAME" list > "$BACKUP_PATH/snapshots_info.txt"
fi

# 5. Sauvegarder la configuration XML
echo "Sauvegarde de la configuration..."
cp ~/VirtualBox\ VMs/"$VM_NAME"/"$VM_NAME".vbox "$BACKUP_PATH/"

# 6. Créer un fichier de métadonnées
cat > "$BACKUP_PATH/backup_info.txt" << EOF
VM: $VM_NAME
Date: $DATE
Hôte: $(hostname)
VirtualBox Version: $(VBoxManage --version)
Taille totale: $(du -sh "$BACKUP_PATH" | cut -f1)
EOF

echo "✓ Sauvegarde terminée dans: $BACKUP_PATH"
echo "Taille: $(du -sh "$BACKUP_PATH" | cut -f1)"
```

**Restauration d'une sauvegarde** :

```bash
# Importer depuis une sauvegarde OVA
VBoxManage import /chemin/vers/sauvegarde/MaVM.ova

# Ou restaurer manuellement les fichiers VDI et VBOX
# puis enregistrer la VM :
VBoxManage registervm /chemin/vers/MaVM.vbox
```

---

### Surveillance et monitoring

```bash
# Surveiller les ressources d'une VM en cours d'exécution

# Activer les métriques
VBoxManage metrics setup --period 1 --samples 5

# Afficher les métriques en temps réel
VBoxManage metrics query "MaVM" CPU/Load/User,CPU/Load/Kernel,RAM/Usage/Used

# Surveiller continuellement (script)
#!/bin/bash
VM_NAME="$1"
while true; do
    clear
    echo "=== Surveillance de $VM_NAME ==="
    echo "Timestamp: $(date)"
    echo
    VBoxManage metrics query "$VM_NAME" \
        CPU/Load/User,CPU/Load/Kernel,RAM/Usage/Used,Disk/Usage/Used
    sleep 2
done
```

---

## 🎯 Récapitulatif des commandes essentielles de dépannage

```bash
# Vérification rapide de l'état
VBoxManage showvminfo "MaVM" --machinereadable | grep "VMState="

# Diagnostic complet
VBoxManage showvminfo "MaVM"

# Libérer une session bloquée
VBoxManage startvm "MaVM" --type emergencystop

# Vérifier les logs
tail -f ~/VirtualBox\ VMs/MaVM/Logs/VBox.log

# Rechercher des erreurs dans les logs
grep -i "error\|fail\|fatal" ~/VirtualBox\ VMs/MaVM/Logs/VBox.log

# Tester la connectivité réseau
VBoxManage showvminfo "MaVM" | grep -i "nic"

# Vérifier l'intégrité d'un disque
VBoxManage showmediuminfo disk /path/to/disk.vdi

# Changer l'UUID d'un disque en cas de conflit
VBoxManage internalcommands sethduuid /path/to/disk.vdi

# Optimisation des performances
VBoxManage modifyvm "MaVM" --memory 4096 --cpus 2 --hwvirtex on --nestedpaging on

# Compacter un disque dynamique
VBoxManage modifymedium disk /path/to/disk.vdi --compact

# Lister tous les problèmes potentiels
VBoxManage list systemproperties
```

---

## 💡 Points clés à retenir

> [!tip] Méthode de dépannage efficace
> 
> 1. **Identifier** : Reproduire le problème et noter les messages d'erreur exacts
> 2. **Isoler** : Vérifier un composant à la fois (réseau, stockage, mémoire...)
> 3. **Consulter** : Lire les logs VirtualBox pour des détails techniques
> 4. **Tester** : Appliquer une solution à la fois et vérifier le résultat
> 5. **Documenter** : Noter ce qui a fonctionné pour référence future

> [!warning] Erreurs à éviter
> 
> - Modifier plusieurs paramètres simultanément (impossible de savoir ce qui a corrigé)
> - Ignorer les logs (ils contiennent souvent la solution)
> - Ne pas sauvegarder avant des changements majeurs
> - Utiliser sudo/admin pour VirtualBox sans raison (cause des problèmes de permissions)
> - Allouer trop de ressources à une VM (dégrade les performances globales)

---

**🎓 Vous maîtrisez maintenant le dépannage VirtualBox CLI !**

Avec ces compétences, vous pouvez diagnostiquer et résoudre la majorité des problèmes rencontrés avec VirtualBox en ligne de commande. La clé est d'être méthodique et de toujours consulter les logs pour comprendre la cause profonde des problèmes.