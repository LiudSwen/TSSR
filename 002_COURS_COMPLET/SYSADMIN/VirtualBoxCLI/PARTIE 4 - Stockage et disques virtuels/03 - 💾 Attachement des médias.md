

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

## Introduction

L'attachement de médias dans VirtualBox permet de connecter des disques durs virtuels, des CD/DVD (ISO), et d'autres périphériques de stockage à vos machines virtuelles. Cette opération s'effectue via la commande `storageattach`, qui établit le lien entre un contrôleur de stockage et un fichier média physique.

> [!info] Prérequis Avant d'attacher un média, vous devez avoir créé un contrôleur de stockage sur votre VM (SATA, IDE, SCSI, etc.). L'attachement se fait toujours sur un contrôleur existant.

---

## La commande storageattach

### 🎯 Syntaxe de base

```bash
VBoxManage storageattach <nom-vm|uuid> \
    --storagectl <nom-contrôleur> \
    --port <numéro-port> \
    --device <numéro-device> \
    --type <type-média> \
    --medium <chemin-fichier|none|emptydrive|additions>
```

### 📋 Paramètres essentiels

|Paramètre|Description|Valeurs possibles|
|---|---|---|
|`--storagectl`|Nom du contrôleur cible|Nom défini lors de la création|
|`--port`|Numéro du port sur le contrôleur|0, 1, 2, ... (dépend du contrôleur)|
|`--device`|Numéro du device sur le port|0 ou 1 (généralement)|
|`--type`|Type de média à attacher|`hdd`, `dvddrive`, `fdd`|
|`--medium`|Fichier ou action|Chemin, `none`, `emptydrive`, `additions`|

### 💡 Exemples pratiques

**Attacher un disque dur virtuel :**

```bash
VBoxManage storageattach "MaVM" \
    --storagectl "SATA Controller" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/home/user/VMs/disque.vdi"
```

**Attacher une ISO (CD/DVD) :**

```bash
VBoxManage storageattach "MaVM" \
    --storagectl "IDE Controller" \
    --port 1 \
    --device 0 \
    --type dvddrive \
    --medium "/home/user/ISOs/ubuntu-22.04.iso"
```

**Attacher les Guest Additions :**

```bash
VBoxManage storageattach "MaVM" \
    --storagectl "IDE Controller" \
    --port 1 \
    --device 0 \
    --type dvddrive \
    --medium additions
```

> [!tip] Astuce Le mot-clé `additions` charge automatiquement l'ISO des Guest Additions fourni par VirtualBox, sans avoir à spécifier le chemin complet.

---

## Ports et devices

### 🔌 Comprendre les ports et devices

Chaque contrôleur de stockage possède plusieurs **ports**, et chaque port peut avoir plusieurs **devices**. Cette architecture permet de connecter plusieurs médias sur un même contrôleur.

```
Contrôleur SATA
├── Port 0
│   ├── Device 0 → disque système
│   └── Device 1 → (généralement inutilisé)
├── Port 1
│   └── Device 0 → disque de données
└── Port 2
    └── Device 0 → autre disque
```

### 📊 Limites selon le type de contrôleur

|Type de contrôleur|Ports max|Devices par port|Usage typique|
|---|---|---|---|
|**IDE**|2|2|4 médias max (ancien standard)|
|**SATA**|30|1|Disques modernes|
|**SCSI**|16|1|Serveurs, performance|
|**SAS**|8|1|Entreprise|
|**Floppy**|1|2|Disquettes (obsolète)|

### 🎯 Convention de numérotation

> [!warning] Important
> 
> - Les ports commencent à **0**
> - Les devices commencent à **0**
> - Pour SATA, on utilise généralement device 0 uniquement

**Exemples de configuration IDE classique :**

```bash
# Port 0, Device 0 → Master Primary (disque principal)
--port 0 --device 0

# Port 0, Device 1 → Slave Primary (second disque)
--port 0 --device 1

# Port 1, Device 0 → Master Secondary (lecteur CD/DVD)
--port 1 --device 0

# Port 1, Device 1 → Slave Secondary (second lecteur)
--port 1 --device 1
```

**Configuration SATA moderne :**

```bash
# Premier disque SATA
--port 0 --device 0

# Deuxième disque SATA
--port 1 --device 0

# Troisième disque SATA
--port 2 --device 0
```

> [!example] Exemple complet
> 
> ```bash
> # Créer une VM avec plusieurs disques
> VBoxManage createvm --name "MultiDisque" --register
> VBoxManage storagectl "MultiDisque" --name "SATA" --add sata
> 
> # Disque système sur port 0
> VBoxManage storageattach "MultiDisque" \
>     --storagectl "SATA" \
>     --port 0 --device 0 \
>     --type hdd \
>     --medium "/path/system.vdi"
> 
> # Disque de données sur port 1
> VBoxManage storageattach "MultiDisque" \
>     --storagectl "SATA" \
>     --port 1 --device 0 \
>     --type hdd \
>     --medium "/path/data.vdi"
> 
> # ISO d'installation sur port 2
> VBoxManage storageattach "MultiDisque" \
>     --storagectl "SATA" \
>     --port 2 --device 0 \
>     --type dvddrive \
>     --medium "/path/install.iso"
> ```

---

## Mode passthrough

### 🚀 Qu'est-ce que le passthrough ?

Le **passthrough** permet à la VM d'accéder directement à un périphérique physique (CD/DVD) du système hôte, sans passer par la couche de virtualisation. Cela améliore les performances et permet certaines opérations bas niveau.

### ⚙️ Activation du passthrough

```bash
VBoxManage storageattach "MaVM" \
    --storagectl "IDE Controller" \
    --port 1 \
    --device 0 \
    --type dvddrive \
    --medium /dev/sr0 \
    --passthrough on
```

### 📊 Comparaison avec/sans passthrough

|Caractéristique|Sans passthrough|Avec passthrough|
|---|---|---|
|**Accès**|Via VirtualBox|Direct au matériel|
|**Performance**|Bonne|Excellente|
|**Commandes SCSI**|Limitées|Complètes|
|**Gravure CD/DVD**|Non supporté|Supporté|
|**Sécurité**|Plus isolé|Moins isolé|

> [!warning] Précautions
> 
> - Le passthrough nécessite des permissions appropriées sur l'hôte
> - Sous Linux, l'utilisateur doit appartenir au groupe `cdrom` ou `optical`
> - Peut causer des conflits si l'hôte utilise le périphérique simultanément

### 💡 Cas d'usage typiques

**Gravure de CD/DVD depuis la VM :**

```bash
VBoxManage storageattach "BurnerVM" \
    --storagectl "IDE" \
    --port 1 --device 0 \
    --type dvddrive \
    --medium /dev/sr0 \
    --passthrough on
```

**Lecture de disques protégés :**

Certains CD/DVD avec protection anti-copie nécessitent le passthrough pour fonctionner correctement.

> [!tip] Astuce Pour lister les lecteurs physiques disponibles sur votre système :
> 
> ```bash
> # Linux
> ls -l /dev/sr*
> ls -l /dev/cdrom
> 
> # Vérifier les permissions
> groups  # Vérifiez que vous êtes dans 'cdrom'
> ```

---

## Médias temporaires et immutables

### 🔄 Types de médias

VirtualBox supporte plusieurs modes d'attachement qui modifient le comportement des disques virtuels :

|Mode|Comportement|Cas d'usage|
|---|---|---|
|**Normal**|Lecture/écriture persistante|Usage standard|
|**Immutable**|Les modifications sont annulées à l'arrêt|Tests, démonstrations|
|**Writethrough**|Écriture directe sans cache|Performance critique|
|**Shareable**|Partageable entre VMs|Clustering|
|**Readonly**|Lecture seule|Distribution de données|
|**Multiattach**|Attachement multiple simultané|Cas avancés|

### 🔒 Médias immutables

Les disques **immutables** créent automatiquement un disque différentiel temporaire pour toutes les écritures. À l'arrêt de la VM, ce disque différentiel est supprimé et le disque original reste intact.

**Configurer un disque immutable :**

```bash
# D'abord, modifier le type du média
VBoxManage modifymedium disk "/path/disque.vdi" --type immutable

# Puis l'attacher normalement
VBoxManage storageattach "MaVM" \
    --storagectl "SATA" \
    --port 0 --device 0 \
    --type hdd \
    --medium "/path/disque.vdi"
```

> [!info] Fonctionnement Lorsque vous démarrez la VM, VirtualBox crée automatiquement un fichier de différences (snapshot). Toutes vos modifications vont dans ce fichier. À l'arrêt, VirtualBox vous demande si vous voulez conserver ou rejeter les changements.

### 🎯 Médias temporaires avec `emptydrive`

Le mot-clé `emptydrive` simule un lecteur vide (sans média inséré) :

```bash
VBoxManage storageattach "MaVM" \
    --storagectl "IDE Controller" \
    --port 1 --device 0 \
    --type dvddrive \
    --medium emptydrive
```

**Différence avec `none` :**

- `emptydrive` : le lecteur existe mais est vide (comme un lecteur CD sans disque)
- `none` : le lecteur n'existe pas du tout (détaché)

### 💾 Mode writethrough

En mode **writethrough**, les écritures sont effectuées directement sur le disque sans passer par le cache de VirtualBox :

```bash
VBoxManage modifymedium disk "/path/disque.vdi" --type writethrough
```

> [!warning] Attention Le mode writethrough peut réduire les performances mais garantit que les données sont immédiatement écrites sur le disque physique.

### 👥 Mode shareable (multi-attach)

Les disques **shareable** peuvent être attachés simultanément à plusieurs VMs :

```bash
VBoxManage modifymedium disk "/path/disque-partage.vdi" --type shareable
```

> [!warning] Danger Ce mode nécessite un système de fichiers clustering (GFS, OCFS2) dans les VMs. Sans cela, vous risquez une corruption majeure des données !

### 📖 Média en lecture seule

```bash
VBoxManage modifymedium disk "/path/disque.vdi" --type readonly

VBoxManage storageattach "MaVM" \
    --storagectl "SATA" \
    --port 1 --device 0 \
    --type hdd \
    --medium "/path/disque.vdi"
```

> [!example] Exemple pratique : VM de test jetable
> 
> ```bash
> # Créer un disque de base propre
> VBoxManage createmedium disk --filename base.vdi --size 20000
> 
> # Le rendre immutable
> VBoxManage modifymedium disk base.vdi --type immutable
> 
> # Créer une VM de test
> VBoxManage createvm --name "TestVM" --register
> VBoxManage storagectl "TestVM" --name "SATA" --add sata
> 
> # Attacher le disque immutable
> VBoxManage storageattach "TestVM" \
>     --storagectl "SATA" \
>     --port 0 --device 0 \
>     --type hdd \
>     --medium base.vdi
> 
> # Chaque démarrage de TestVM partira d'un état propre
> # Toutes les modifications seront perdues à l'arrêt
> ```

---

## Détachement de médias

### 🔌 Détacher un média

Pour détacher un média d'une VM, utilisez `--medium none` :

```bash
VBoxManage storageattach "MaVM" \
    --storagectl "SATA Controller" \
    --port 0 \
    --device 0 \
    --medium none
```

> [!info] Différence importante
> 
> - `--medium none` : détache complètement le device (libère le slot)
> - `--medium emptydrive` : garde le lecteur mais le vide (pour CD/DVD)

### 🔄 Changer de média à la volée

Pour remplacer une ISO par une autre sans redémarrer la VM :

```bash
# Éjecter l'ISO actuelle
VBoxManage storageattach "MaVM" \
    --storagectl "IDE Controller" \
    --port 1 --device 0 \
    --medium emptydrive

# Insérer la nouvelle ISO
VBoxManage storageattach "MaVM" \
    --storagectl "IDE Controller" \
    --port 1 --device 0 \
    --type dvddrive \
    --medium "/path/nouvelle.iso"
```

> [!tip] Astuce Vous pouvez changer l'ISO d'un lecteur CD/DVD même quand la VM est en cours d'exécution. Pratique pour installer plusieurs logiciels sans redémarrage !

### 🗑️ Supprimer complètement un slot

```bash
# Détacher ET supprimer le slot du contrôleur
VBoxManage storageattach "MaVM" \
    --storagectl "SATA" \
    --port 2 \
    --device 0 \
    --medium none \
    --type hdd
```

### 📋 Vérifier les attachements actuels

Pour voir tous les médias attachés à une VM :

```bash
VBoxManage showvminfo "MaVM" | grep -A 5 "Storage"
```

Ou de manière plus détaillée :

```bash
VBoxManage showvminfo "MaVM" --machinereadable | grep "^Storage"
```

> [!example] Exemple : Script de nettoyage
> 
> ```bash
> #!/bin/bash
> # Détacher tous les médias d'une VM
> 
> VM_NAME="MaVM"
> 
> # Détacher tous les ports SATA (0 à 29)
> for port in {0..29}; do
>     VBoxManage storageattach "$VM_NAME" \
>         --storagectl "SATA" \
>         --port $port \
>         --device 0 \
>         --medium none 2>/dev/null
> done
> 
> # Détacher tous les ports IDE
> for port in {0..1}; do
>     for device in {0..1}; do
>         VBoxManage storageattach "$VM_NAME" \
>             --storagectl "IDE" \
>             --port $port \
>             --device $device \
>             --medium none 2>/dev/null
>     done
> done
> 
> echo "Tous les médias ont été détachés de $VM_NAME"
> ```

---

## Pièges courants

### ⚠️ Erreurs fréquentes et solutions

**1. Erreur : "VERR_PDM_MEDIA_LOCKED"**

```
Le média est verrouillé par une autre VM ou processus
```

**Solution :**

```bash
# Vérifier quelle VM utilise le média
VBoxManage list hdds | grep -B 5 "disque.vdi"

# Arrêter la VM qui l'utilise
VBoxManage controlvm "AutreVM" poweroff

# Ou détacher le média de l'autre VM d'abord
```

---

**2. Erreur : "VBOX_E_OBJECT_NOT_FOUND"**

```
Le contrôleur spécifié n'existe pas
```

**Solution :**

```bash
# Lister les contrôleurs existants
VBoxManage showvminfo "MaVM" | grep "Storage Controller"

# Utiliser exactement le nom affiché (attention à la casse)
VBoxManage storageattach "MaVM" --storagectl "SATA Controller" ...
```

---

**3. Port/Device invalide**

```
Le port ou device spécifié dépasse les limites du contrôleur
```

**Solution :**

Respectez les limites de chaque type de contrôleur (voir tableau dans la section Ports et devices).

---

**4. Type de média incompatible**

```bash
# ERREUR : Attacher une ISO en tant que HDD
VBoxManage storageattach "MaVM" \
    --storagectl "SATA" \
    --port 0 --device 0 \
    --type hdd \
    --medium "ubuntu.iso"  # ❌ Mauvais type !
```

**Solution :**

```bash
# Utiliser le bon type
VBoxManage storageattach "MaVM" \
    --storagectl "IDE" \
    --port 1 --device 0 \
    --type dvddrive \  # ✅ Correct
    --medium "ubuntu.iso"
```

---

**5. Permissions insuffisantes pour le passthrough**

```
Accès refusé à /dev/sr0
```

**Solution :**

```bash
# Sous Linux, ajouter l'utilisateur au groupe cdrom
sudo usermod -aG cdrom $USER

# Se reconnecter pour appliquer les changements
# Ou utiliser :
newgrp cdrom
```

---

**6. Oublier de spécifier --type lors du détachement**

```bash
# ERREUR : VirtualBox ne sait pas quel type de slot libérer
VBoxManage storageattach "MaVM" \
    --storagectl "SATA" \
    --port 0 --device 0 \
    --medium none  # ❌ Incomplet !
```

**Solution :**

```bash
VBoxManage storageattach "MaVM" \
    --storagectl "SATA" \
    --port 0 --device 0 \
    --type hdd \  # ✅ Spécifier le type
    --medium none
```

> [!tip] Bonne pratique Toujours spécifier `--type` même lors du détachement pour éviter toute ambiguïté.

---

**7. Chemins avec espaces non échappés**

```bash
# ERREUR : Chemin avec espaces
VBoxManage storageattach "MaVM" \
    --medium /home/user/Mes Documents/disque.vdi  # ❌
```

**Solution :**

```bash
# Utiliser des guillemets
VBoxManage storageattach "MaVM" \
    --medium "/home/user/Mes Documents/disque.vdi"  # ✅
```

---

### 🎯 Bonnes pratiques récapitulatives

> [!tip] Conseils d'expert
> 
> 1. **Nomenclature cohérente** : Nommez vos contrôleurs de manière descriptive (`SATA-System`, `IDE-Optical`)
>     
> 2. **Organisation des ports** :
>     
>     - Port 0 : disque système
>     - Ports 1-5 : disques de données
>     - Derniers ports : lecteurs optiques
> 3. **Backup avant modification** : Toujours faire une copie des disques importants avant de changer leur type (immutable, writethrough, etc.)
>     
> 4. **Vérification systématique** : Après chaque attachement, utilisez `showvminfo` pour confirmer
>     
> 5. **Scripts d'automatisation** : Pour des configurations complexes, créez des scripts shell pour éviter les erreurs de frappe
>     
> 6. **Documentation** : Conservez un fichier texte décrivant l'architecture de stockage de chaque VM importante
>     

---

## 🎓 Résumé des commandes essentielles

```bash
# Attacher un disque dur
VBoxManage storageattach "VM" --storagectl "SATA" \
    --port 0 --device 0 --type hdd --medium disk.vdi

# Attacher une ISO
VBoxManage storageattach "VM" --storagectl "IDE" \
    --port 1 --device 0 --type dvddrive --medium ubuntu.iso

# Détacher un média
VBoxManage storageattach "VM" --storagectl "SATA" \
    --port 0 --device 0 --type hdd --medium none

# Lecteur vide
VBoxManage storageattach "VM" --storagectl "IDE" \
    --port 1 --device 0 --type dvddrive --medium emptydrive

# Passthrough activé
VBoxManage storageattach "VM" --storagectl "IDE" \
    --port 1 --device 0 --type dvddrive \
    --medium /dev/sr0 --passthrough on

# Rendre un disque immutable
VBoxManage modifymedium disk disk.vdi --type immutable

# Vérifier les attachements
VBoxManage showvminfo "VM" | grep -A 10 "Storage"
```

---

_Fin du cours sur l'attachement des médias VirtualBox CLI_ 🎉