

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

## 🎯 Introduction à VBoxManage {#introduction}

`VBoxManage` est l'interface en ligne de commande de VirtualBox qui permet de gérer l'ensemble du cycle de vie des machines virtuelles. Cette partie se concentre sur la création et l'enregistrement des VMs.

> [!info] Pourquoi utiliser la CLI ?
> 
> - **Automatisation** : Créer des scripts pour déployer plusieurs VMs identiques
> - **Reproductibilité** : Documenter exactement la configuration d'une VM
> - **Contrôle avancé** : Accéder à des options non disponibles dans l'interface graphique
> - **Administration à distance** : Gérer des VMs sans interface graphique

---

## 🔧 Création d'une VM avec createvm {#createvm}

### Concept de base

La commande `createvm` initialise une nouvelle machine virtuelle dans VirtualBox. Elle crée un fichier de définition XML (`.vbox`) qui contient toutes les métadonnées de la VM.

> [!warning] Attention `createvm` ne crée que la **définition** de la VM. Elle ne configure pas le stockage, la mémoire, ou le réseau. Ces éléments seront configurés via d'autres commandes (qui seront vues dans d'autres parties du cours).

### Syntaxe de base

```bash
VBoxManage createvm --name <nom_vm> [options]
```

### Options principales

|Option|Description|Obligatoire|
|---|---|---|
|`--name`|Nom de la VM (identifiant unique)|✅ Oui|
|`--ostype`|Type de système d'exploitation|❌ Non (défaut: Other)|
|`--register`|Enregistre automatiquement la VM|❌ Non|
|`--basefolder`|Dossier de stockage de la VM|❌ Non (défaut: ~/VirtualBox VMs)|
|`--uuid`|UUID personnalisé pour la VM|❌ Non (généré automatiquement)|
|`--group`|Groupe(s) d'appartenance|❌ Non|

### Exemples pratiques

#### Exemple 1 : Création minimale

```bash
# Crée une VM nommée "MaVM" sans l'enregistrer
VBoxManage createvm --name "MaVM"
```

> [!example] Résultat Crée le fichier `/home/user/VirtualBox VMs/MaVM/MaVM.vbox` mais la VM n'apparaît pas encore dans VirtualBox.

#### Exemple 2 : Création avec enregistrement automatique

```bash
# Crée et enregistre immédiatement la VM
VBoxManage createvm --name "UbuntuServer" --ostype "Ubuntu_64" --register
```

> [!tip] Bonne pratique Utilisez `--register` lors de la création pour éviter une étape supplémentaire, sauf si vous voulez modifier le fichier `.vbox` manuellement avant l'enregistrement.

#### Exemple 3 : Organisation avec dossier personnalisé

```bash
# Crée une VM dans un dossier spécifique
VBoxManage createvm --name "WebServer" \
  --ostype "Debian_64" \
  --basefolder "/data/vms" \
  --register
```

Résultat : La VM sera créée dans `/data/vms/WebServer/`

#### Exemple 4 : Organisation par groupes

```bash
# Crée une VM dans un groupe logique
VBoxManage createvm --name "DB-Prod" \
  --ostype "RedHat_64" \
  --group "/Production/Databases" \
  --register
```

> [!info] Groupes multiples Une VM peut appartenir à plusieurs groupes :
> 
> ```bash
> --group "/Production,/Databases,/Critical"
> ```

---

## ⚙️ Paramètres de base {#parametres-base}

### Le nom de la VM (--name)

Le nom est l'identifiant principal de votre VM dans VirtualBox.

> [!warning] Règles de nommage
> 
> - Doit être **unique** dans votre installation VirtualBox
> - Évitez les caractères spéciaux complexes
> - Les espaces sont autorisés mais nécessitent des guillemets
> - Sensible à la casse (MaVM ≠ mavm)

```bash
# ✅ Valide
VBoxManage createvm --name "Ubuntu Server 22.04"
VBoxManage createvm --name "web-server-01"

# ❌ À éviter (mais techniquement valide)
VBoxManage createvm --name "Server@#2024!"
```

### Le type d'OS (--ostype)

Définit le type de système d'exploitation que vous prévoyez d'installer. Cela influence les paramètres par défaut optimaux pour la VM.

**Impact du ostype :**

- Quantité de mémoire recommandée
- Type de contrôleur de disque par défaut
- Activation de certaines fonctionnalités (PAE, ACPI, etc.)
- Icône affichée dans l'interface

```bash
# Exemple : créer une VM Windows 11
VBoxManage createvm --name "Win11-Dev" --ostype "Windows11_64"
```

> [!tip] Comment choisir le bon ostype ? Utilisez le type le plus spécifique possible. Par exemple :
> 
> - Préférez `Ubuntu_64` à `Linux_64`
> - Préférez `Windows11_64` à `Windows_64`
> 
> Cela garantit les meilleures optimisations automatiques.

### L'UUID (--uuid)

Chaque VM possède un identifiant unique universel (UUID) généré automatiquement.

```bash
# Laisser VirtualBox générer l'UUID (recommandé)
VBoxManage createvm --name "MaVM" --register

# Spécifier un UUID personnalisé (rare)
VBoxManage createvm --name "MaVM" \
  --uuid "a5b2c3d4-e5f6-7890-abcd-ef1234567890" \
  --register
```

> [!warning] Quand spécifier un UUID ? Uniquement pour des cas très spécifiques :
> 
> - Migration depuis un autre hyperviseur
> - Restauration d'une configuration précise
> - Scripts d'automatisation nécessitant des UUIDs prévisibles
> 
> **Dans 99% des cas, laissez VirtualBox générer l'UUID automatiquement.**

### Le dossier de base (--basefolder)

Définit où seront stockés les fichiers de la VM.

```bash
# Utilise le dossier par défaut (~VirtualBox VMs/)
VBoxManage createvm --name "MaVM" --register

# Dossier personnalisé
VBoxManage createvm --name "MaVM" \
  --basefolder "/mnt/stockage-vms" \
  --register
```

**Structure créée :**

```
/mnt/stockage-vms/
└── MaVM/
    ├── MaVM.vbox          # Fichier de configuration
    ├── MaVM.vbox-prev     # Sauvegarde de la config précédente
    └── Logs/              # Logs de la VM
```

> [!tip] Bonnes pratiques de stockage
> 
> - Utilisez un disque avec beaucoup d'espace pour `--basefolder`
> - Préférez des SSD pour de meilleures performances
> - Évitez les dossiers synchronisés (Dropbox, OneDrive) qui peuvent corrompre les VMs
> - Pensez aux sauvegardes : le dossier contient TOUTE la VM

### Les groupes (--group)

Les groupes permettent d'organiser logiquement vos VMs dans l'interface VirtualBox.

```bash
# Groupe simple
VBoxManage createvm --name "WebApp" \
  --group "/Development" \
  --register

# Groupes imbriqués
VBoxManage createvm --name "API-Server" \
  --group "/Production/Backend/APIs" \
  --register

# Groupes multiples
VBoxManage createvm --name "Test-DB" \
  --group "/Testing,/Databases,/Temporary" \
  --register
```

**Visualisation dans VirtualBox :**

```
📁 Development
  └── 🖥️ WebApp
📁 Production
  └── 📁 Backend
      └── 📁 APIs
          └── 🖥️ API-Server
```

> [!info] Organisation recommandée Créez une hiérarchie qui reflète votre infrastructure :
> 
> - Par environnement : `/Dev`, `/Test`, `/Prod`
> - Par projet : `/ProjetA`, `/ProjetB`
> - Par fonction : `/WebServers`, `/Databases`, `/LoadBalancers`

---

## 🐧 Types de systèmes d'exploitation {#os-types}

### Lister tous les types disponibles

```bash
# Affiche la liste complète des ostypes supportés
VBoxManage list ostypes
```

### Principales familles d'OS

#### 🪟 Windows

|ostype|Description|
|---|---|
|`Windows11_64`|Windows 11 (64-bit)|
|`Windows10_64`|Windows 10 (64-bit)|
|`Windows2022_64`|Windows Server 2022|
|`Windows2019_64`|Windows Server 2019|
|`Windows2016_64`|Windows Server 2016|
|`Windows81_64`|Windows 8.1 (64-bit)|
|`Windows7_64`|Windows 7 (64-bit)|

```bash
# Exemple Windows
VBoxManage createvm --name "Win11-Pro" \
  --ostype "Windows11_64" \
  --register
```

#### 🐧 Linux

|ostype|Description|
|---|---|
|`Ubuntu_64`|Ubuntu (64-bit, toutes versions)|
|`Debian_64`|Debian (64-bit)|
|`RedHat_64`|Red Hat Enterprise Linux (64-bit)|
|`Fedora_64`|Fedora (64-bit)|
|`ArchLinux_64`|Arch Linux (64-bit)|
|`Oracle_64`|Oracle Linux (64-bit)|
|`Linux_64`|Linux générique (64-bit)|

```bash
# Exemples Linux
VBoxManage createvm --name "Ubuntu-Server" \
  --ostype "Ubuntu_64" \
  --register

VBoxManage createvm --name "CentOS-8" \
  --ostype "RedHat_64" \
  --register
```

#### 🍎 macOS

|ostype|Description|
|---|---|
|`MacOS_64`|macOS (64-bit)|
|`MacOS1013_64`|macOS 10.13 High Sierra|
|`MacOS1015_64`|macOS 10.15 Catalina|

> [!warning] Limitations macOS La virtualisation de macOS n'est légalement autorisée que sur du matériel Apple. Des restrictions techniques s'appliquent également.

#### 🔧 Autres systèmes

|ostype|Description|
|---|---|
|`FreeBSD_64`|FreeBSD (64-bit)|
|`OpenBSD_64`|OpenBSD (64-bit)|
|`Solaris11_64`|Oracle Solaris 11 (64-bit)|
|`Other_64`|Système non listé (64-bit)|

### Variantes 32-bit vs 64-bit

Chaque ostype existe généralement en version 32-bit (sans suffix) et 64-bit (suffix `_64`).

```bash
# 32-bit
VBoxManage createvm --name "WinXP-Old" --ostype "WindowsXP"

# 64-bit (recommandé pour les systèmes modernes)
VBoxManage createvm --name "Ubuntu-Modern" --ostype "Ubuntu_64"
```

> [!tip] Quelle version choisir ?
> 
> - **64-bit** : Pour tous les systèmes modernes (recommandé)
> - **32-bit** : Uniquement pour des systèmes legacy ou si votre CPU ne supporte pas la virtualisation 64-bit

### Rechercher un ostype spécifique

```bash
# Filtrer les ostypes contenant "ubuntu"
VBoxManage list ostypes | grep -i ubuntu

# Filtrer les ostypes Windows
VBoxManage list ostypes | grep -i windows
```

### Format de sortie de `list ostypes`

```bash
ID:          Ubuntu_64
Description: Ubuntu (64-bit)
Family ID:   Linux
Family Desc: Linux
64 bit:      true
```

> [!info] Comprendre les informations
> 
> - **ID** : Valeur à utiliser avec `--ostype`
> - **Description** : Nom lisible du système
> - **Family ID** : Famille du système (Linux, Windows, etc.)
> - **64 bit** : Indique si c'est une version 64-bit

---

## 📝 Gestion du registre : registervm et unregistervm {#register}

### Concept du registre VirtualBox

Le **registre** VirtualBox est une base de données interne qui liste toutes les VMs connues. Une VM doit être enregistrée pour apparaître dans l'interface et être utilisable.

```
Fichier .vbox créé → VM existe sur le disque
         ↓
   registervm appliqué → VM visible dans VirtualBox
```

### registervm : Enregistrer une VM

#### Quand utiliser registervm ?

- Vous avez créé une VM sans l'option `--register`
- Vous avez copié une VM depuis un autre système
- Vous avez restauré une VM depuis une sauvegarde
- Vous voulez réimporter une VM précédemment supprimée

#### Syntaxe

```bash
VBoxManage registervm <chemin_vers_fichier.vbox>
```

#### Exemples

```bash
# Cas 1 : Enregistrer une VM créée sans --register
VBoxManage createvm --name "TestVM" --ostype "Ubuntu_64"
# La VM existe maintenant sur le disque mais n'est pas visible
VBoxManage registervm "/home/user/VirtualBox VMs/TestVM/TestVM.vbox"
# Maintenant la VM apparaît dans VirtualBox

# Cas 2 : Importer une VM copiée depuis un autre ordinateur
VBoxManage registervm "/mnt/backup/OldVM/OldVM.vbox"

# Cas 3 : Enregistrer plusieurs VMs via un script
for vm in /data/vms/*/*.vbox; do
    VBoxManage registervm "$vm"
done
```

> [!tip] Astuce Le chemin vers le fichier `.vbox` doit être absolu ou relatif valide. Vérifiez toujours que le fichier existe avant d'essayer de l'enregistrer.

#### Vérifier l'enregistrement

```bash
# Lister toutes les VMs enregistrées
VBoxManage list vms

# Afficher les détails d'une VM spécifique
VBoxManage showvminfo "NomDeLaVM"
```

### unregistervm : Désenregistrer une VM

#### Concept

`unregistervm` retire une VM du registre VirtualBox. La VM n'apparaît plus dans l'interface, mais **les fichiers restent sur le disque**.

#### Syntaxe

```bash
VBoxManage unregistervm <nom_vm|uuid> [--delete]
```

#### Options

|Option|Description|
|---|---|
|_aucune_|Désenregistre la VM, conserve les fichiers|
|`--delete`|Désenregistre ET supprime tous les fichiers|

#### Exemples

```bash
# Cas 1 : Désenregistrer sans supprimer (VM cachée mais récupérable)
VBoxManage unregistervm "TestVM"
# Résultat : TestVM n'apparaît plus dans VirtualBox
# Fichiers toujours présents dans ~/VirtualBox VMs/TestVM/

# Cas 2 : Désenregistrer et supprimer complètement
VBoxManage unregistervm "TestVM" --delete
# Résultat : TestVM supprimée ET tous ses fichiers effacés

# Cas 3 : Utiliser l'UUID au lieu du nom
VBoxManage unregistervm {a5b2c3d4-e5f6-7890-abcd-ef1234567890} --delete
```

> [!warning] Attention avec --delete L'option `--delete` est **irréversible**. Elle supprime :
> 
> - Le fichier de configuration `.vbox`
> - Tous les disques virtuels (`.vdi`, `.vmdk`, etc.)
> - Les snapshots
> - Les logs
> 
> **Il n'y a pas de corbeille, pas de retour en arrière possible !**

#### Cas d'usage pratiques

**Scénario 1 : Nettoyer avant de réimporter**

```bash
# Désenregistrer une VM corrompue
VBoxManage unregistervm "VMCorrompue"
# Réparer manuellement les fichiers .vbox
# Réenregistrer la VM réparée
VBoxManage registervm "/path/to/VMCorrompue/VMCorrompue.vbox"
```

**Scénario 2 : Migration vers un autre dossier**

```bash
# 1. Désenregistrer (garde les fichiers)
VBoxManage unregistervm "MaVM"

# 2. Déplacer les fichiers
mv ~/VirtualBox\ VMs/MaVM /mnt/nouveau-disque/

# 3. Réenregistrer depuis le nouvel emplacement
VBoxManage registervm "/mnt/nouveau-disque/MaVM/MaVM.vbox"
```

**Scénario 3 : Suppression complète d'une VM de test**

```bash
# Tout supprimer en une commande
VBoxManage unregistervm "VM-Test-Temporaire" --delete
```

### Tableau récapitulatif

|Action|Commande|Fichiers conservés ?|VM visible ?|
|---|---|---|---|
|Créer sans enregistrer|`createvm`|✅ Oui|❌ Non|
|Créer avec enregistrement|`createvm --register`|✅ Oui|✅ Oui|
|Enregistrer existante|`registervm`|✅ Oui|✅ Oui|
|Désenregistrer|`unregistervm`|✅ Oui|❌ Non|
|Supprimer complètement|`unregistervm --delete`|❌ Non|❌ Non|

---

## 🎯 Pièges courants et bonnes pratiques

### ❌ Pièges à éviter

#### Piège 1 : Oublier --register

```bash
# ❌ Erreur fréquente
VBoxManage createvm --name "MaVM" --ostype "Ubuntu_64"
# Vous cherchez ensuite MaVM dans l'interface... elle n'y est pas !

# ✅ Solution
VBoxManage createvm --name "MaVM" --ostype "Ubuntu_64" --register
```

#### Piège 2 : Utiliser des noms non-uniques

```bash
# ❌ Échoue si "MaVM" existe déjà
VBoxManage createvm --name "MaVM" --register
# Error: Machine settings file already exists

# ✅ Vérifiez d'abord l'existence
VBoxManage list vms | grep "MaVM"
```

#### Piège 3 : Mauvais ostype

```bash
# ❌ Moins optimal
VBoxManage createvm --name "Ubuntu22" --ostype "Linux_64"

# ✅ Plus spécifique = meilleures optimisations
VBoxManage createvm --name "Ubuntu22" --ostype "Ubuntu_64"
```

#### Piège 4 : unregistervm --delete par erreur

```bash
# ❌ DANGER : Suppression accidentelle irréversible
VBoxManage unregistervm "ProductionDB" --delete
# Tout est perdu, pas de retour en arrière !

# ✅ Soyez sûr ou faites d'abord une sauvegarde
cp -r ~/VirtualBox\ VMs/ProductionDB /backup/
VBoxManage unregistervm "ProductionDB" --delete
```

### ✅ Bonnes pratiques

#### 1. Convention de nommage cohérente

```bash
# Adoptez une convention et tenez-vous-y
# Format : <Projet>-<Role>-<Env>-<Num>
VBoxManage createvm --name "MyApp-Web-Prod-01" --ostype "Ubuntu_64" --register
VBoxManage createvm --name "MyApp-DB-Prod-01" --ostype "Ubuntu_64" --register
VBoxManage createvm --name "MyApp-Web-Dev-01" --ostype "Ubuntu_64" --register
```

#### 2. Organisation par groupes

```bash
# Créez une structure logique dès le début
VBoxManage createvm --name "WebApp-Prod" \
  --ostype "Ubuntu_64" \
  --group "/Production/WebServers" \
  --register
```

#### 3. Documenter vos VMs

```bash
# Ajoutez une description (commande vue dans d'autres parties)
VBoxManage createvm --name "API-Server" --ostype "Ubuntu_64" --register
# La description se fait via modifyvm (autre partie du cours)
```

#### 4. Script de création standardisé

```bash
#!/bin/bash
# create_vm.sh - Script de création standardisée

VM_NAME=$1
OS_TYPE=$2
VM_GROUP=$3

if [ -z "$VM_NAME" ] || [ -z "$OS_TYPE" ]; then
    echo "Usage: $0 <vm_name> <os_type> [group]"
    exit 1
fi

GROUP_OPT=""
if [ -n "$VM_GROUP" ]; then
    GROUP_OPT="--group $VM_GROUP"
fi

VBoxManage createvm \
    --name "$VM_NAME" \
    --ostype "$OS_TYPE" \
    $GROUP_OPT \
    --register

echo "✅ VM '$VM_NAME' créée avec succès"
```

Utilisation :

```bash
./create_vm.sh "WebServer-01" "Ubuntu_64" "/Production"
```

#### 5. Vérification avant suppression

```bash
# Script de suppression sécurisé
#!/bin/bash
VM_NAME=$1

echo "⚠️  Vous êtes sur le point de supprimer : $VM_NAME"
echo "Cette action est IRRÉVERSIBLE"
read -p "Tapez le nom de la VM pour confirmer : " CONFIRM

if [ "$CONFIRM" = "$VM_NAME" ]; then
    VBoxManage unregistervm "$VM_NAME" --delete
    echo "✅ VM supprimée"
else
    echo "❌ Annulé - les noms ne correspondent pas"
fi
```

---

## 🔍 Résumé des commandes essentielles

```bash
# Créer une VM (sans enregistrement)
VBoxManage createvm --name "MaVM" --ostype "Ubuntu_64"

# Créer et enregistrer en une seule commande (recommandé)
VBoxManage createvm --name "MaVM" --ostype "Ubuntu_64" --register

# Créer avec dossier et groupe personnalisés
VBoxManage createvm --name "MaVM" \
  --ostype "Ubuntu_64" \
  --basefolder "/data/vms" \
  --group "/Production" \
  --register

# Lister les types d'OS disponibles
VBoxManage list ostypes

# Enregistrer une VM existante
VBoxManage registervm "/path/to/MaVM/MaVM.vbox"

# Désenregistrer une VM (garde les fichiers)
VBoxManage unregistervm "MaVM"

# Supprimer complètement une VM
VBoxManage unregistervm "MaVM" --delete

# Lister toutes les VMs enregistrées
VBoxManage list vms

# Afficher les infos d'une VM
VBoxManage showvminfo "MaVM"
```

---

> [!success] Points clés à retenir
> 
> - `createvm` crée la **définition** de la VM, pas sa configuration complète
> - Utilisez toujours `--ostype` pour bénéficier des optimisations automatiques
> - `--register` permet d'enregistrer la VM immédiatement lors de sa création
> - Le registre VirtualBox est indépendant des fichiers sur le disque
> - `unregistervm` sans `--delete` permet de cacher temporairement une VM
> - `unregistervm --delete` est **irréversible** : toujours vérifier avant de l'utiliser
> - Adoptez des conventions de nommage et d'organisation dès le début