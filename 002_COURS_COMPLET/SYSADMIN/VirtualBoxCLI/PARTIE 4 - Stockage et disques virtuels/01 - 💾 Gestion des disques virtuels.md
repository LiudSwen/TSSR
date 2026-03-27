

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

La gestion des disques virtuels est l'une des fonctionnalités les plus importantes de VirtualBox. Les disques virtuels stockent le système d'exploitation, les applications et les données de vos machines virtuelles. VBoxManage offre un contrôle complet sur ces disques via la ligne de commande, permettant l'automatisation et la gestion avancée.

> [!info] Pourquoi gérer les disques en CLI ?
> 
> - **Automatisation** : scriptez la création et la gestion de multiples disques
> - **Performance** : opérations plus rapides sans interface graphique
> - **Contrôle précis** : accès à des options avancées non disponibles dans l'interface graphique
> - **Administration distante** : gérez vos disques via SSH

---

## 1. Création de disques virtuels - `createmedium`

La commande `createmedium` permet de créer des disques virtuels vierges qui pourront ensuite être attachés à des machines virtuelles.

### Formats de disques disponibles

VirtualBox supporte trois formats principaux de disques virtuels :

|Format|Extension|Caractéristiques|Usage recommandé|
|---|---|---|---|
|**VDI**|`.vdi`|Format natif VirtualBox, meilleure performance|Usage exclusif avec VirtualBox|
|**VMDK**|`.vmdk`|Format VMware, compatible multi-plateforme|Compatibilité avec VMware|
|**VHD**|`.vhd`|Format Microsoft Hyper-V|Compatibilité avec Hyper-V|

> [!tip] Conseil de choix Utilisez **VDI** si vous travaillez uniquement avec VirtualBox. C'est le format le plus optimisé et offre les meilleures performances.

### Tailles fixe vs dynamique

Un concept fondamental dans la gestion des disques virtuels est le choix entre allocation **fixe** et **dynamique** :

#### 🔹 Taille dynamique (par défaut)

- **Principe** : Le disque commence petit et grandit au fur et à mesure de l'utilisation
- **Avantages** :
    - Économie d'espace disque sur l'hôte
    - Création instantanée
    - Flexibilité
- **Inconvénients** :
    - Légère perte de performance (fragmentation)
    - Le disque peut grandir mais pas rétrécir automatiquement
    - Risque de remplir le disque hôte par surprise

#### 🔹 Taille fixe

- **Principe** : L'espace total est alloué immédiatement
- **Avantages** :
    - Meilleures performances (pas de fragmentation)
    - Pas de surprise sur l'espace utilisé
    - Idéal pour la production
- **Inconvénients** :
    - Création plus longue
    - Consomme immédiatement tout l'espace déclaré

> [!example] Cas d'usage
> 
> - **Dynamique** : environnements de test, développement, multiples VMs
> - **Fixe** : serveurs de production, bases de données, applications critiques

### Syntaxe et exemples

#### Syntaxe générale

```bash
VBoxManage createmedium disk \
  --filename <chemin> \
  --size <taille_en_MB> \
  --format <VDI|VMDK|VHD> \
  [--variant Standard|Fixed]
```

#### Paramètres détaillés

- `disk` : type de média (peut aussi être `dvd` ou `floppy`)
- `--filename` : chemin complet du fichier à créer
- `--size` : taille en **mégaoctets** (1 Go = 1024 Mo)
- `--format` : format du disque (VDI, VMDK, VHD)
- `--variant` :
    - `Standard` : allocation dynamique (défaut)
    - `Fixed` : allocation fixe

#### Exemples pratiques

**Créer un disque VDI dynamique de 50 Go**

```bash
VBoxManage createmedium disk \
  --filename "/home/user/VirtualBox/disks/ubuntu-disk.vdi" \
  --size 51200 \
  --format VDI
```

**Créer un disque VDI à taille fixe de 20 Go**

```bash
VBoxManage createmedium disk \
  --filename "/home/user/VirtualBox/disks/database.vdi" \
  --size 20480 \
  --format VDI \
  --variant Fixed
```

**Créer un disque VMDK pour compatibilité VMware**

```bash
VBoxManage createmedium disk \
  --filename "/home/user/VirtualBox/disks/shared-disk.vmdk" \
  --size 30720 \
  --format VMDK
```

**Créer un disque VHD pour Hyper-V**

```bash
VBoxManage createmedium disk \
  --filename "C:\VirtualBox\disks\hyperv-compat.vhd" \
  --size 40960 \
  --format VHD
```

> [!warning] Attention aux chemins
> 
> - Utilisez toujours des **chemins absolus**, pas relatifs
> - Sous Windows, échappez les backslashes ou utilisez des guillemets
> - Créez les répertoires parents avant si nécessaire
> - Les extensions `.vdi`, `.vmdk`, `.vhd` doivent correspondre au format choisi

> [!tip] Astuce de calcul Pour convertir facilement des Go en Mo :
> 
> - 10 Go = 10 × 1024 = 10240 Mo
> - 50 Go = 50 × 1024 = 51200 Mo
> - 100 Go = 100 × 1024 = 102400 Mo

#### Vérifier la création

Après création, listez vos disques pour vérifier :

```bash
VBoxManage list hdds
```

Cette commande affiche tous les disques enregistrés avec leurs UUID, chemins, tailles et formats.

---

## 2. Modification de disques - `modifymedium`

La commande `modifymedium` permet de modifier les propriétés d'un disque existant, notamment sa taille et son occupation réelle sur le disque hôte.

### Redimensionnement de disques

Le redimensionnement permet d'**augmenter** la taille d'un disque virtuel existant. Cette opération est courante lorsqu'une VM manque d'espace.

> [!warning] Limitations importantes
> 
> - On ne peut qu'**augmenter** la taille, jamais la réduire avec VBoxManage
> - Le disque ne doit pas avoir de snapshots
> - Le disque ne doit pas être attaché à une VM en cours d'exécution
> - Seule la capacité du disque virtuel est étendue ; vous devrez ensuite **redimensionner la partition** depuis le système d'exploitation invité

#### Syntaxe

```bash
VBoxManage modifymedium disk <uuid|fichier> \
  --resize <nouvelle_taille_en_MB>
```

#### Exemples pratiques

**Augmenter un disque de 50 Go à 100 Go**

```bash
# Arrêtez d'abord la VM si elle tourne
VBoxManage controlvm "MaVM" poweroff

# Redimensionnez le disque
VBoxManage modifymedium disk \
  "/home/user/VirtualBox/disks/ubuntu-disk.vdi" \
  --resize 102400
```

**Utiliser l'UUID au lieu du chemin**

```bash
# Trouver l'UUID
VBoxManage list hdds | grep -A 5 "ubuntu-disk"

# Redimensionner avec UUID
VBoxManage modifymedium disk \
  a1b2c3d4-e5f6-7890-abcd-ef1234567890 \
  --resize 102400
```

> [!info] Après le redimensionnement Le disque virtuel est plus grand, mais le système d'exploitation ne voit pas encore l'espace supplémentaire. Vous devez :
> 
> 1. Démarrer la VM
> 2. Utiliser un outil de partitionnement (`gparted`, `fdisk`, ou Disk Management sous Windows)
> 3. Étendre la partition pour utiliser le nouvel espace

### Compactage de disques

Le compactage réduit la taille physique d'un disque à **allocation dynamique** sur le disque hôte, sans changer sa capacité virtuelle. C'est utile après avoir supprimé des fichiers dans la VM.

> [!info] Principe du compactage Quand vous supprimez des fichiers dans une VM, le disque virtuel ne rétrécit pas automatiquement. Le compactage récupère cet espace "libéré" en le rendant au disque hôte.

#### Processus de compactage

Le compactage se fait en **deux étapes** :

**Étape 1 : Zéroïser l'espace libre dans la VM invitée**

Avant de compacter, vous devez "marquer" l'espace libre en écrivant des zéros dessus :

**Sous Linux :**

```bash
# Remplir l'espace libre de zéros
sudo dd if=/dev/zero of=/tmp/zerofill bs=1M
# Attendre que le disque soit plein (c'est normal)
# Puis supprimer le fichier
sudo rm /tmp/zerofill
```

**Sous Windows :**

Téléchargez et utilisez `SDelete` de Sysinternals :

```cmd
sdelete.exe -z C:
```

**Étape 2 : Compacter depuis l'hôte**

```bash
VBoxManage modifymedium disk <uuid|fichier> --compact
```

#### Exemple complet

```bash
# 1. Dans la VM Linux invitée
sudo dd if=/dev/zero of=/tmp/zerofill bs=1M
sudo rm /tmp/zerofill
sudo shutdown -h now

# 2. Sur l'hôte, compacter le disque
VBoxManage modifymedium disk \
  "/home/user/VirtualBox/disks/ubuntu-disk.vdi" \
  --compact
```

> [!tip] Gains de compactage Le compactage peut récupérer beaucoup d'espace, surtout après :
> 
> - Désinstallation de gros logiciels
> - Suppression de logs volumineux
> - Nettoyage de caches et fichiers temporaires
> - Mise à jour du système (les anciens fichiers sont remplacés)

> [!warning] Attention
> 
> - Le compactage ne fonctionne **que sur les disques dynamiques**, pas les disques fixes
> - Le compactage peut prendre beaucoup de temps selon la taille du disque
> - Faites une sauvegarde avant un compactage important

#### Comparer avant/après

```bash
# Avant compactage
ls -lh /home/user/VirtualBox/disks/ubuntu-disk.vdi

# Après compactage
ls -lh /home/user/VirtualBox/disks/ubuntu-disk.vdi
```

---

## 3. Clonage de disques - `clonemedium`

Le clonage crée une copie complète d'un disque virtuel. C'est essentiel pour créer des sauvegardes, dupliquer des environnements ou créer des modèles (templates).

### Principe du clonage

Le clonage copie **toutes les données** du disque source vers un nouveau disque. Contrairement aux snapshots, le clone est **indépendant** du disque original.

### Syntaxe

```bash
VBoxManage clonemedium disk <source> <destination> \
  [--format VDI|VMDK|VHD] \
  [--variant Standard|Fixed]
```

### Paramètres

- `<source>` : UUID ou chemin du disque à cloner
- `<destination>` : chemin du nouveau disque
- `--format` : format du clone (peut différer de la source)
- `--variant` : type d'allocation (peut différer de la source)

### Exemples pratiques

**Clone simple (même format)**

```bash
VBoxManage clonemedium disk \
  "/home/user/VirtualBox/disks/ubuntu-disk.vdi" \
  "/home/user/VirtualBox/disks/ubuntu-disk-backup.vdi"
```

**Clone avec changement de format**

```bash
# Convertir un VDI en VMDK
VBoxManage clonemedium disk \
  "/home/user/VirtualBox/disks/ubuntu-disk.vdi" \
  "/home/user/VirtualBox/disks/ubuntu-disk.vmdk" \
  --format VMDK
```

**Clone avec changement d'allocation**

```bash
# Convertir un disque dynamique en fixe
VBoxManage clonemedium disk \
  "/home/user/VirtualBox/disks/ubuntu-disk.vdi" \
  "/home/user/VirtualBox/disks/ubuntu-disk-fixed.vdi" \
  --variant Fixed
```

**Clone avec nouveau format ET nouvelle allocation**

```bash
# Dynamique VDI → Fixe VMDK
VBoxManage clonemedium disk \
  "/home/user/VirtualBox/disks/source.vdi" \
  "/home/user/VirtualBox/disks/target.vmdk" \
  --format VMDK \
  --variant Fixed
```

> [!info] UUID et clones Chaque clone reçoit automatiquement un **nouvel UUID unique**. Cela permet d'attacher le clone et l'original à différentes VMs sans conflit.

### Cas d'usage du clonage

|Scénario|Méthode|
|---|---|
|**Sauvegarde complète**|Clone vers un disque externe|
|**Créer un template**|Clone d'une VM propre configurée|
|**Migration**|Clone vers un autre format pour un autre hyperviseur|
|**Tests destructifs**|Clone pour tester sans risque|
|**Distribution**|Clone optimisé (fixe) pour déploiement|

> [!tip] Optimisation de clones Pour créer un template optimal :
> 
> 1. Configurez une VM "golden master" avec le strict nécessaire
> 2. Nettoyez-la (logs, caches, historiques)
> 3. Zéroïsez l'espace libre
> 4. Clonez en format fixe pour les performances

> [!warning] Temps de clonage Le clonage copie toutes les données secteur par secteur. Pour un disque de 50 Go :
> 
> - Comptez 5-15 minutes selon votre disque
> - Assurez-vous d'avoir assez d'espace libre sur l'hôte
> - Le clone occupe autant d'espace que le disque source (ou plus si vous passez en fixe)

---

## 4. Fermeture et suppression - `closemedium`

La commande `closemedium` permet de retirer un disque du registre VirtualBox et optionnellement de le supprimer physiquement du système de fichiers.

### Différence entre fermeture et suppression

|Opération|Effet sur le registre|Effet sur le fichier|
|---|---|---|
|**Fermeture simple**|Disque retiré du registre VirtualBox|Fichier conservé sur le disque|
|**Suppression**|Disque retiré du registre VirtualBox|Fichier supprimé définitivement|

> [!info] Qu'est-ce que le registre ? VirtualBox maintient un registre interne de tous les disques qu'il connaît. Un disque peut exister physiquement mais être inconnu de VirtualBox, ou inversement être enregistré alors que le fichier a été supprimé manuellement.

### Syntaxe

```bash
VBoxManage closemedium disk <uuid|fichier> [--delete]
```

- Sans `--delete` : retire le disque du registre VirtualBox uniquement
- Avec `--delete` : retire ET supprime le fichier physique

### Exemples pratiques

**Fermeture simple (désinscrire sans supprimer)**

```bash
VBoxManage closemedium disk \
  "/home/user/VirtualBox/disks/old-disk.vdi"
```

Le fichier `old-disk.vdi` existe toujours sur le disque, mais VirtualBox ne le voit plus.

**Suppression complète**

```bash
VBoxManage closemedium disk \
  "/home/user/VirtualBox/disks/old-disk.vdi" \
  --delete
```

Le fichier est supprimé définitivement du système de fichiers.

**Utiliser l'UUID**

```bash
# Lister pour trouver l'UUID
VBoxManage list hdds

# Fermer avec UUID
VBoxManage closemedium disk \
  a1b2c3d4-e5f6-7890-abcd-ef1234567890 \
  --delete
```

### Préconditions

> [!warning] Avant de supprimer un disque
> 
> - Le disque **ne doit pas être attaché** à une VM
> - Le disque **ne doit pas avoir de snapshots** qui en dépendent
> - Le disque **ne doit pas être utilisé** comme disque différentiel par une autre VM
> - Assurez-vous de ne plus en avoir besoin (suppression définitive !)

### Vérifications avant suppression

```bash
# Vérifier les attachements
VBoxManage showvminfo "MaVM" | grep -i "old-disk"

# Lister les infos du disque
VBoxManage showmediuminfo disk \
  "/home/user/VirtualBox/disks/old-disk.vdi"
```

### Workflow de nettoyage complet

```bash
# 1. Détacher le disque de toutes les VMs
VBoxManage storageattach "MaVM" \
  --storagectl "SATA" \
  --port 1 \
  --device 0 \
  --medium none

# 2. Vérifier qu'il n'est plus utilisé
VBoxManage list hdds | grep "old-disk"

# 3. Supprimer
VBoxManage closemedium disk \
  "/home/user/VirtualBox/disks/old-disk.vdi" \
  --delete
```

> [!tip] Nettoyage des disques orphelins Si vous avez supprimé manuellement des fichiers .vdi mais qu'ils apparaissent encore dans le registre :
> 
> ```bash
> # Liste les disques "inaccessibles"
> VBoxManage list hdds | grep -i "inaccessible"
> 
> # Fermer un disque inaccessible par UUID
> VBoxManage closemedium disk <uuid>
> ```

### Gestion d'erreurs courantes

**Erreur : "Medium is still attached"**

```bash
# Solution : détacher d'abord
VBoxManage storageattach "MaVM" --storagectl "SATA" --port 0 --medium none
VBoxManage closemedium disk <uuid> --delete
```

**Erreur : "Medium has snapshots"**

```bash
# Solution : supprimer les snapshots ou fusionner
VBoxManage snapshot "MaVM" delete <snapshot-name>
# Puis réessayer la suppression
```

> [!warning] Suppression définitive L'option `--delete` supprime le fichier **sans passer par la corbeille**. Il n'y a pas de retour en arrière possible. Vérifiez deux fois avant de valider !

---

## 🎯 Récapitulatif des commandes essentielles

```bash
# Créer un disque dynamique
VBoxManage createmedium disk --filename "disk.vdi" --size 51200

# Créer un disque fixe
VBoxManage createmedium disk --filename "disk.vdi" --size 20480 --variant Fixed

# Redimensionner un disque
VBoxManage modifymedium disk "disk.vdi" --resize 102400

# Compacter un disque
VBoxManage modifymedium disk "disk.vdi" --compact

# Cloner un disque
VBoxManage clonemedium disk "source.vdi" "target.vdi"

# Supprimer un disque
VBoxManage closemedium disk "disk.vdi" --delete

# Lister tous les disques
VBoxManage list hdds
```

> [!tip] Bonnes pratiques générales
> 
> - **Nommez clairement** vos disques (ex: `ubuntu-22.04-system.vdi`)
> - **Organisez** vos disques dans des dossiers par projet/VM
> - **Sauvegardez** régulièrement via clonage
> - **Compactez** périodiquement les disques dynamiques
> - **Documentez** vos configurations dans des scripts
> - **Testez** toujours sur des copies avant des modifications importantes

---