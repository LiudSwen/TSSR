

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

## Introduction aux contrôleurs de stockage

Les **contrôleurs de stockage** (storage controllers) sont des interfaces virtuelles qui permettent à une VM de gérer ses périphériques de stockage (disques durs, lecteurs CD/DVD, etc.). Chaque type de contrôleur émule un matériel spécifique et possède ses propres caractéristiques en termes de performance et de compatibilité.

> [!info] Pourquoi c'est important
> 
> - Les contrôleurs déterminent la **performance d'accès au stockage** de votre VM
> - Certains OS nécessitent des **types de contrôleurs spécifiques** pour booter
> - Le choix du contrôleur impacte la **compatibilité** avec les systèmes d'exploitation invités
> - Une mauvaise configuration peut empêcher le démarrage de la VM

> [!tip] Quand configurer les contrôleurs
> 
> - Lors de la **création initiale** d'une VM pour optimiser les performances
> - Quand vous ajoutez des **disques supplémentaires**
> - Pour résoudre des **problèmes de compatibilité** avec l'OS invité
> - Lors de la **migration** d'une VM depuis un autre hyperviseur

---

## Types de contrôleurs

### IDE (Integrated Drive Electronics)

Le contrôleur **IDE** est l'un des plus anciens standards de connexion de disques. Il est largement compatible mais offre des performances limitées.

**Caractéristiques :**

- Maximum **4 périphériques** (2 canaux × 2 périphériques)
- Vitesse limitée (mode PIO ou DMA)
- Excellente compatibilité avec les anciens OS
- Utilisé principalement pour les lecteurs CD/DVD

**Cas d'usage :**

- Émulation de systèmes anciens (Windows 95/98, DOS)
- Lecteurs CD/DVD virtuels
- Quand la compatibilité prime sur la performance

> [!example] Exemple de configuration IDE
> 
> ```bash
> # Ajouter un contrôleur IDE
> VBoxManage storagectl "MaVM" --name "IDE Controller" \
>   --add ide \
>   --controller PIIX4
> ```

### SATA (Serial ATA)

**SATA** est le standard moderne pour les disques durs et SSD. Il offre un bon équilibre entre performance et compatibilité.

**Caractéristiques :**

- Jusqu'à **30 ports** par contrôleur dans VirtualBox
- Support du **hot-plugging** (ajout à chaud)
- Bonnes performances
- Compatible avec la plupart des OS modernes (Windows 7+, Linux récents)

**Cas d'usage :**

- Configuration par défaut pour les VM modernes
- Disques système et disques de données
- Quand vous avez besoin de plusieurs disques

> [!example] Exemple de configuration SATA
> 
> ```bash
> # Ajouter un contrôleur SATA
> VBoxManage storagectl "MaVM" --name "SATA Controller" \
>   --add sata \
>   --controller IntelAhci \
>   --portcount 4 \
>   --bootable on
> ```

### SCSI (Small Computer System Interface)

**SCSI** est un standard professionnel utilisé dans les environnements serveurs. VirtualBox émule plusieurs types de contrôleurs SCSI.

**Caractéristiques :**

- Haute performance
- Support de nombreux périphériques (16 avec LsiLogic)
- Utilisé dans les environnements virtualisés professionnels
- Nécessite parfois des pilotes spécifiques dans l'OS invité

**Types de contrôleurs SCSI disponibles :**

|Contrôleur|Périphériques max|Usage typique|
|---|---|---|
|LsiLogic|16|VMs Linux, serveurs|
|BusLogic|16|Anciens systèmes Windows|
|LsiLogic SAS|255|Environnements haute performance|

**Cas d'usage :**

- VMs serveurs nécessitant haute performance
- Migration depuis VMware (utilise LsiLogic)
- Configuration multi-disques avancée

> [!example] Exemple de configuration SCSI
> 
> ```bash
> # Ajouter un contrôleur SCSI LsiLogic
> VBoxManage storagectl "MaVM" --name "SCSI Controller" \
>   --add scsi \
>   --controller LsiLogic \
>   --bootable on
> ```

### NVMe (Non-Volatile Memory Express)

**NVMe** est le protocole le plus récent pour les SSD modernes, offrant les meilleures performances.

**Caractéristiques :**

- **Performances maximales** (latence minimale)
- Émulation de SSD de dernière génération
- Nécessite un OS invité récent (Windows 10+, Linux 4.4+)
- Limité à quelques périphériques par contrôleur

**Cas d'usage :**

- VMs nécessitant les meilleures performances I/O
- Émulation de matériel moderne
- Tests de développement avec NVMe

> [!warning] Attention Le support NVMe nécessite que la VM soit configurée en **EFI** (pas de BIOS classique) et que l'OS invité supporte ce protocole.

> [!example] Exemple de configuration NVMe
> 
> ```bash
> # Ajouter un contrôleur NVMe
> VBoxManage storagectl "MaVM" --name "NVMe Controller" \
>   --add pcie \
>   --controller NVMe \
>   --bootable on
> ```

### Floppy

Le contrôleur **Floppy** émule un lecteur de disquettes, principalement pour des raisons de compatibilité historique.

**Caractéristiques :**

- Maximum **1 contrôleur** avec **2 lecteurs**
- Capacité standard 1.44 MB
- Rarement utilisé aujourd'hui

**Cas d'usage :**

- Émulation de très anciens systèmes (DOS, Windows 3.x)
- Tests de compatibilité legacy
- Boot depuis images disquettes pour certains utilitaires

> [!example] Exemple de configuration Floppy
> 
> ```bash
> # Ajouter un contrôleur Floppy
> VBoxManage storagectl "MaVM" --name "Floppy Controller" \
>   --add floppy
> ```

---

## Gestion avec storagectl

La commande `VBoxManage storagectl` permet de créer, configurer et supprimer les contrôleurs de stockage d'une VM.

### Ajout de contrôleurs

**Syntaxe générale :**

```bash
VBoxManage storagectl <vmname> --name <nom_contrôleur> \
  --add <type> \
  --controller <modèle> \
  [options supplémentaires]
```

**Paramètres essentiels :**

|Paramètre|Description|Valeurs possibles|
|---|---|---|
|`--name`|Nom unique du contrôleur|Chaîne de caractères|
|`--add`|Type de bus|`ide`, `sata`, `scsi`, `floppy`, `sas`, `pcie`|
|`--controller`|Modèle de contrôleur|Dépend du type (voir ci-dessous)|

**Modèles de contrôleurs par type :**

```bash
# IDE
--controller PIIX3      # Contrôleur IDE Intel PIIX3 (défaut)
--controller PIIX4      # Contrôleur IDE Intel PIIX4
--controller ICH6       # Contrôleur IDE Intel ICH6

# SATA
--controller IntelAhci  # Contrôleur AHCI Intel (standard moderne)

# SCSI
--controller LsiLogic   # LSI Logic Parallel SCSI
--controller BusLogic   # BusLogic SCSI
--controller LsiLogicSas # LSI Logic SAS

# NVMe
--controller NVMe       # Contrôleur NVMe
```

> [!example] Exemples d'ajout de contrôleurs
> 
> ```bash
> # Ajouter un contrôleur SATA nommé "SATA"
> VBoxManage storagectl "MaVM" --name "SATA" \
>   --add sata \
>   --controller IntelAhci
> 
> # Ajouter un contrôleur IDE pour CD/DVD
> VBoxManage storagectl "MaVM" --name "IDE" \
>   --add ide \
>   --controller PIIX4
> 
> # Ajouter un contrôleur SCSI haute performance
> VBoxManage storagectl "MaVM" --name "SCSI" \
>   --add scsi \
>   --controller LsiLogicSas
> 
> # Ajouter un contrôleur NVMe
> VBoxManage storagectl "MaVM" --name "NVMe" \
>   --add pcie \
>   --controller NVMe
> ```

### Configuration des contrôleurs

Lors de l'ajout, vous pouvez spécifier plusieurs options de configuration :

**Options principales :**

```bash
--portcount <nombre>        # Nombre de ports (SATA uniquement, 1-30)
--bootable <on|off>         # Le contrôleur est-il bootable ?
--hostiocache <on|off>      # Utiliser le cache I/O de l'hôte
```

> [!example] Configuration complète d'un contrôleur
> 
> ```bash
> # Contrôleur SATA avec 4 ports, bootable, sans cache hôte
> VBoxManage storagectl "MaVM" --name "SATA" \
>   --add sata \
>   --controller IntelAhci \
>   --portcount 4 \
>   --bootable on \
>   --hostiocache off
> ```

> [!info] À propos du portcount
> 
> - Ne s'applique qu'aux contrôleurs **SATA**
> - Définit le nombre de **ports disponibles** pour attacher des disques
> - Valeur par défaut : **30**
> - Un port = un emplacement pour un disque/CD

### Modification des paramètres

Vous pouvez modifier un contrôleur existant en réutilisant la commande `storagectl` avec le même nom :

```bash
# Changer le nombre de ports SATA
VBoxManage storagectl "MaVM" --name "SATA" --portcount 6

# Désactiver le cache I/O de l'hôte
VBoxManage storagectl "MaVM" --name "SATA" --hostiocache off

# Activer/désactiver le bootable
VBoxManage storagectl "MaVM" --name "IDE" --bootable off
```

> [!tip] Astuce pour lister les contrôleurs Pour voir les contrôleurs existants d'une VM :
> 
> ```bash
> VBoxManage showvminfo "MaVM" | grep "Storage Controller"
> ```

### Suppression de contrôleurs

Pour supprimer un contrôleur, utilisez l'option `--remove` :

```bash
VBoxManage storagectl <vmname> --name <nom_contrôleur> --remove
```

> [!example] Exemples de suppression
> 
> ```bash
> # Supprimer un contrôleur SATA
> VBoxManage storagectl "MaVM" --name "SATA" --remove
> 
> # Supprimer un contrôleur IDE
> VBoxManage storagectl "MaVM" --name "IDE Controller" --remove
> ```

> [!warning] Attention avant de supprimer
> 
> - Vous **ne pouvez pas supprimer** un contrôleur qui a encore des disques attachés
> - Détachez d'abord tous les médias avec `storageattach --medium none`
> - La VM doit être **éteinte** pour supprimer un contrôleur
> - La suppression est **irréversible** (mais vous pouvez recréer le contrôleur)

---

## Paramètres avancés des contrôleurs

### Host I/O Cache

Le **Host I/O Cache** permet d'utiliser le cache du système hôte pour améliorer les performances d'I/O.

```bash
# Activer le cache hôte
VBoxManage storagectl "MaVM" --name "SATA" --hostiocache on

# Désactiver le cache hôte
VBoxManage storagectl "MaVM" --name "SATA" --hostiocache off
```

**Recommandations :**

|Scénario|Recommandation|Raison|
|---|---|---|
|Disques VDI/VMDK|`--hostiocache off`|VirtualBox a son propre cache|
|Disques RAW|`--hostiocache on`|Améliore les performances|
|SSD hôte|`--hostiocache off`|Latence déjà faible|
|HDD hôte|`--hostiocache on`|Compense la latence du disque|

> [!tip] Performance I/O Pour maximiser les performances :
> 
> - Utilisez **NVMe** ou **SATA** pour les disques système
> - Désactivez `hostiocache` avec des disques virtuels (VDI)
> - Activez `hostiocache` avec des disques physiques (RAW)
> - Évitez de mélanger IDE et SATA/NVMe sur la même VM

### Bootable

Le paramètre `--bootable` détermine si le BIOS/EFI peut booter depuis ce contrôleur.

```bash
# Rendre un contrôleur bootable
VBoxManage storagectl "MaVM" --name "SATA" --bootable on

# Rendre un contrôleur non-bootable
VBoxManage storagectl "MaVM" --name "IDE" --bootable off
```

> [!info] Ordre de boot
> 
> - Seuls les contrôleurs marqués `bootable on` sont consultés au démarrage
> - L'ordre de boot est défini séparément avec `modifyvm --boot1/2/3/4`
> - Typiquement : contrôleur système en `bootable on`, contrôleur CD/DVD optionnel

---

## Pièges courants et bonnes pratiques

### ❌ Pièges courants

**1. Confondre contrôleur et disque**

```bash
# ❌ ERREUR : Essayer d'attacher sans créer le contrôleur
VBoxManage storageattach "MaVM" --storagectl "SATA" ...
# Erreur si le contrôleur "SATA" n'existe pas

# ✅ CORRECT : D'abord créer le contrôleur
VBoxManage storagectl "MaVM" --name "SATA" --add sata --controller IntelAhci
# Ensuite attacher le disque
VBoxManage storageattach "MaVM" --storagectl "SATA" ...
```

**2. Essayer de supprimer un contrôleur avec des disques attachés**

```bash
# ❌ ERREUR : Supprimer sans détacher
VBoxManage storagectl "MaVM" --name "SATA" --remove
# Erreur si des disques sont encore attachés

# ✅ CORRECT : D'abord détacher tous les disques
VBoxManage storageattach "MaVM" --storagectl "SATA" --port 0 --device 0 --medium none
VBoxManage storagectl "MaVM" --name "SATA" --remove
```

**3. Utiliser le mauvais type de contrôleur pour l'OS**

```bash
# ❌ PROBLÉMATIQUE : NVMe sur un vieux Windows
VBoxManage storagectl "Win7VM" --name "NVMe" --add pcie --controller NVMe
# Windows 7 ne supporte pas NVMe nativement !

# ✅ CORRECT : SATA pour Windows 7
VBoxManage storagectl "Win7VM" --name "SATA" --add sata --controller IntelAhci
```

**4. Oublier le portcount pour SATA**

```bash
# ⚠️ ATTENTION : Par défaut portcount=30 (souvent inutile)
VBoxManage storagectl "MaVM" --name "SATA" --add sata --controller IntelAhci

# ✅ MEILLEUR : Spécifier le nombre réel de ports nécessaires
VBoxManage storagectl "MaVM" --name "SATA" --add sata --controller IntelAhci --portcount 2
```

### ✅ Bonnes pratiques

**1. Nommage cohérent des contrôleurs**

```bash
# Convention de nommage claire
VBoxManage storagectl "MaVM" --name "SATA_System" --add sata ...
VBoxManage storagectl "MaVM" --name "IDE_DVD" --add ide ...
VBoxManage storagectl "MaVM" --name "SCSI_Data" --add scsi ...
```

**2. Configuration adaptée à l'OS invité**

|OS Invité|Contrôleur recommandé|Bootable|Cache hôte|
|---|---|---|---|
|Windows 10/11|SATA ou NVMe|on|off|
|Windows 7/8|SATA|on|off|
|Linux moderne|SATA ou NVMe|on|off|
|Windows XP/2000|IDE ou SATA*|on|on|
|Serveurs|SCSI (LsiLogic)|on|off|

*SATA nécessite parfois l'installation de pilotes AHCI

**3. Optimisation des performances**

```bash
# Configuration haute performance pour Linux moderne
VBoxManage storagectl "LinuxVM" --name "NVMe" \
  --add pcie \
  --controller NVMe \
  --bootable on \
  --hostiocache off

# Configuration équilibrée pour Windows 10
VBoxManage storagectl "Win10VM" --name "SATA" \
  --add sata \
  --controller IntelAhci \
  --portcount 4 \
  --bootable on \
  --hostiocache off
```

**4. Séparation système/données**

```bash
# Contrôleur pour le disque système
VBoxManage storagectl "MaVM" --name "SATA_System" \
  --add sata \
  --controller IntelAhci \
  --portcount 1 \
  --bootable on

# Contrôleur pour les disques de données
VBoxManage storagectl "MaVM" --name "SATA_Data" \
  --add sata \
  --controller IntelAhci \
  --portcount 3 \
  --bootable off
```

> [!tip] Astuces de pro
> 
> - **Listez les contrôleurs existants** avant d'en ajouter : `VBoxManage showvminfo "MaVM"`
> - **Documentez votre configuration** : utilisez des noms de contrôleurs explicites
> - **Testez le boot** après modification : une mauvaise config peut empêcher le démarrage
> - **Pour la migration** : conservez les mêmes types de contrôleurs que la source
> - **Hot-plugging** : seul SATA le supporte, utile pour ajouter des disques à chaud

> [!warning] VM doit être éteinte Toutes les opérations `storagectl` nécessitent que la VM soit **complètement éteinte** (pas en pause, pas sauvegardée). Utilisez :
> 
> ```bash
> VBoxManage controlvm "MaVM" poweroff
> ```

---

## 📝 Récapitulatif des commandes essentielles

```bash
# Lister les contrôleurs d'une VM
VBoxManage showvminfo "MaVM" | grep "Storage Controller"

# Ajouter un contrôleur SATA (le plus courant)
VBoxManage storagectl "MaVM" --name "SATA" \
  --add sata --controller IntelAhci --portcount 4 --bootable on

# Ajouter un contrôleur IDE pour CD/DVD
VBoxManage storagectl "MaVM" --name "IDE" \
  --add ide --controller PIIX4

# Modifier le nombre de ports
VBoxManage storagectl "MaVM" --name "SATA" --portcount 8

# Supprimer un contrôleur (après avoir détaché les disques)
VBoxManage storagectl "MaVM" --name "SATA" --remove
```

---

**Fin du cours - Contrôleurs de stockage VirtualBox CLI** 🎓