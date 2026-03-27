

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

La gestion des disques sous Windows Server est une compétence essentielle pour tout administrateur système. Elle permet d'organiser l'espace de stockage, d'optimiser les performances et de garantir la disponibilité des données. Windows propose deux interfaces principales : le Gestionnaire de disques (interface graphique) et diskpart (ligne de commande).

> [!info] Pourquoi c'est important Une bonne gestion des disques permet de :
> 
> - Organiser efficacement l'espace de stockage
> - Séparer le système des données utilisateurs
> - Optimiser les performances selon les besoins
> - Faciliter les opérations de maintenance et de sauvegarde
> - Étendre la capacité de stockage sans interruption de service

---

## Disques de base vs Disques dynamiques

### 🔹 Disques de base

Les disques de base sont le type de disque par défaut sous Windows. Ils utilisent une table de partition traditionnelle (MBR ou GPT).

**Caractéristiques :**

- Configuration par défaut lors de l'initialisation
- Support des partitions principales et étendues
- Compatible avec tous les systèmes d'exploitation Windows
- Maximum de 4 partitions principales (MBR) ou 128 (GPT)
- Possibilité de créer des partitions étendues avec lecteurs logiques (MBR uniquement)

**Structure MBR (Master Boot Record) :**

- Limite de 2 To par disque
- Maximum 4 partitions principales OU 3 principales + 1 étendue
- Compatible avec les anciens systèmes (BIOS)

**Structure GPT (GUID Partition Table) :**

- Support de disques jusqu'à 9,4 Zo (zettaoctets)
- Jusqu'à 128 partitions
- Requis pour les systèmes UEFI
- Plus fiable grâce à la redondance des informations de partition

> [!example] Cas d'usage des disques de base
> 
> - Serveurs avec configuration simple
> - Systèmes en dual-boot
> - Compatibilité maximale requise
> - La plupart des scénarios standard d'entreprise

### 🔹 Disques dynamiques

Les disques dynamiques offrent des fonctionnalités avancées de gestion du stockage, notamment la création de volumes étendus sur plusieurs disques.

**Caractéristiques :**

- Configuration avancée nécessitant une conversion
- Support de volumes simples, fractionnés, agrégés par bandes, en miroir et RAID-5
- Possibilité d'étendre des volumes sans redémarrage
- Non compatible avec Windows Home et certains systèmes d'exploitation

**Types de volumes dynamiques :**

|Type de volume|Description|Disques requis|Tolérance aux pannes|
|---|---|---|---|
|**Simple**|Volume sur un seul disque|1|Non|
|**Fractionné (Spanned)**|Volume étendu sur plusieurs disques|2-32|Non|
|**Agrégé par bandes (Striped/RAID-0)**|Données réparties sur plusieurs disques|2-32|Non (performances ↑)|
|**En miroir (Mirrored/RAID-1)**|Duplication des données|2|Oui|
|**RAID-5**|Données + parité réparties|3-32|Oui|

> [!warning] Limitations importantes
> 
> - Les disques dynamiques ne sont PAS supportés sur Windows 10/11 (uniquement lecture)
> - Microsoft recommande désormais d'utiliser les **espaces de stockage** plutôt que les disques dynamiques
> - Impossible de revenir à un disque de base sans perte de données (sauf si vide)
> - Non bootable sur les systèmes UEFI

### 🔄 Conversion entre types de disques

**De base vers dynamique :**

```powershell
# Via Gestionnaire de disques : clic droit > Convertir en disque dynamique
# Pas de perte de données
```

**De dynamique vers base :**

```powershell
# Nécessite de supprimer TOUS les volumes
# Perte totale des données sur le disque
# Sauvegarder avant !
```

> [!tip] Recommandation Microsoft Pour les nouvelles installations, privilégiez les disques de base avec GPT et utilisez les **Espaces de stockage** (Storage Spaces) pour les besoins avancés de redondance et de performances.

---

## Partitions et volumes

### 🔹 Différence entre partition et volume

**Partition :**

- Division physique d'un disque de base
- Définie dans la table de partition (MBR ou GPT)
- Contigüe (bloc d'espace continu)

**Volume :**

- Unité de stockage formatée accessible par le système
- Peut s'étendre sur plusieurs disques (volumes fractionnés)
- Reçoit une lettre de lecteur ou un point de montage

> [!info] En pratique Sur un disque de base, partition = volume dans la plupart des cas. La distinction devient importante avec les disques dynamiques.

### 🔹 Types de partitions (disques de base MBR)

**Partition principale :**

- Peut contenir un système d'exploitation
- Bootable
- Maximum 4 par disque MBR

**Partition étendue :**

- Conteneur pour les lecteurs logiques
- Une seule par disque
- Non formatée directement

**Lecteur logique :**

- Subdivision d'une partition étendue
- Formaté et utilisable
- Permet de dépasser la limite de 4 partitions

```
Exemple de configuration MBR :
┌─────────────────────────────────────────┐
│ Disque 0 (MBR)                          │
├──────────────┬──────────────────────────┤
│ Partition 1  │ Partition étendue        │
│ (Principale) │ ┌──────────┬──────────┐  │
│ C: (Système) │ │ Logique  │ Logique  │  │
│              │ │ D: (Data)│ E: (Data)│  │
└──────────────┴─┴──────────┴──────────┴──┘
```

### 🔹 Partition système vs Partition de démarrage

**Partition système (System Partition) :**

- Contient les fichiers de démarrage (bootloader)
- Généralement petite (100-500 Mo)
- Souvent cachée (sans lettre de lecteur)
- Peut être différente de C:

**Partition de démarrage (Boot Partition) :**

- Contient le système d'exploitation Windows
- Généralement C:
- Là où se trouve le dossier Windows

> [!example] Configuration typique
> 
> - Partition système : 500 Mo, EFI/UEFI, sans lettre
> - Partition de démarrage : C:, contient `C:\Windows`
> - Partition de données : D:, pour les fichiers utilisateurs

---

## Gestionnaire de disques

Le Gestionnaire de disques (Disk Management) est l'interface graphique principale pour administrer les disques sous Windows Server.

### 🔹 Accès au Gestionnaire de disques

```powershell
# Méthode 1 : Via la commande Exécuter
diskmgmt.msc

# Méthode 2 : Via Server Manager
# Server Manager > Tools > Computer Management > Disk Management

# Méthode 3 : Via le menu contextuel
# Clic droit sur "Ce PC" > Gérer > Gestion des disques
```

### 🔹 Interface du Gestionnaire de disques

L'interface se divise en deux sections :

**Zone supérieure :** Liste des volumes avec leurs propriétés

- Lettre de lecteur
- Système de fichiers
- Type de volume
- Capacité et espace libre
- État de santé

**Zone inférieure :** Représentation graphique des disques physiques

- Vue par disque avec les partitions
- Code couleur selon le type et l'état
- Espace non alloué visible

### 🔹 Opérations courantes

**Initialiser un nouveau disque :**

1. Clic droit sur le disque (état "Non initialisé")
2. Sélectionner "Initialiser le disque"
3. Choisir MBR ou GPT
4. Cliquer OK

```powershell
# Le choix entre MBR et GPT dépend de :
# - Taille du disque (> 2 To = GPT obligatoire)
# - Type de démarrage (UEFI = GPT recommandé)
# - Compatibilité requise (ancien système = MBR)
```

**Créer un volume simple :**

1. Clic droit sur l'espace non alloué
2. "Nouveau volume simple..."
3. Assistant de création :
    - Spécifier la taille
    - Attribuer une lettre de lecteur ou un point de montage
    - Formater (NTFS recommandé)
    - Donner un nom de volume

**Étendre un volume :**

1. Clic droit sur le volume à étendre
2. "Étendre le volume..."
3. Sélectionner l'espace disponible
4. Valider

> [!warning] Conditions pour étendre un volume
> 
> - Espace non alloué doit être adjacent (juste après le volume)
> - Volume formaté en NTFS ou ReFS
> - Pas possible sur la partition système en cours d'utilisation
> - Pour étendre vers la gauche ou sur un autre disque : conversion en disque dynamique nécessaire

**Réduire un volume :**

1. Clic droit sur le volume
2. "Réduire le volume..."
3. Spécifier la taille à libérer
4. Cliquer sur "Réduire"

> [!tip] Optimisation avant réduction
> 
> - Défragmenter le volume avant de le réduire
> - Désactiver temporairement la restauration système
> - Désactiver le fichier d'échange si possible Cela permet de récupérer plus d'espace lors de la réduction.

**Modifier la lettre de lecteur :**

1. Clic droit sur le volume
2. "Modifier la lettre de lecteur et les chemins d'accès..."
3. Modifier ou supprimer la lettre
4. Attention : peut casser des raccourcis et chemins codés en dur

**Formater un volume :**

1. Clic droit sur le volume
2. "Formater..."
3. Options :
    - Nom de volume
    - Système de fichiers (NTFS, ReFS, exFAT)
    - Taille d'unité d'allocation (par défaut recommandé)
    - Formatage rapide (coche recommandée sauf pour diagnostic)
    - Compression de fichiers (ralentit les performances)

> [!warning] Formatage = Perte de données Le formatage efface toutes les données du volume. Toujours sauvegarder avant !

### 🔹 États des disques et volumes

**États de disque :**

- **En ligne :** Fonctionnel et accessible
- **Hors connexion :** Inaccessible (conflit de signature, corruption)
- **Étranger :** Disque dynamique importé d'un autre système
- **Non initialisé :** Nouveau disque sans table de partition

**États de volume :**

- **Sain :** Fonctionnel
- **Sain (à risque) :** Problèmes d'E/S détectés
- **Échec :** Volume inaccessible ou endommagé
- **Échec de redondance :** RAID dégradé (miroir ou RAID-5)

---

## Montage de volumes

Le montage de volumes permet d'attacher un volume à un dossier vide plutôt que de lui attribuer une lettre de lecteur.

### 🔹 Pourquoi utiliser des points de montage ?

**Avantages :**

- Dépasse la limite de 26 lettres de lecteur (A-Z)
- Organisation logique des données (ex: `C:\Data\Archives`, `C:\Data\Backups`)
- Transparence pour les utilisateurs et applications
- Extension invisible de la capacité d'un volume
- Idéal pour les serveurs de fichiers avec nombreux volumes

**Cas d'usage :**

- Serveurs avec plus de 26 volumes
- Organisation hiérarchique des données
- Extension de la capacité d'un dossier spécifique
- Séparer les données sur différents disques physiques pour performances

### 🔹 Créer un point de montage

**Prérequis :**

- Dossier de montage doit être vide
- Sur un volume NTFS ou ReFS
- Permissions suffisantes

**Via le Gestionnaire de disques :**

1. Créer un dossier vide (ex: `C:\MountPoints\Archives`)
2. Clic droit sur le volume à monter
3. "Modifier la lettre de lecteur et les chemins d'accès..."
4. "Ajouter..."
5. Sélectionner "Monter dans le dossier NTFS vide suivant"
6. Parcourir et sélectionner le dossier
7. OK

**Via PowerShell :**

```powershell
# Créer le dossier de montage
New-Item -Path "C:\MountPoints\Archives" -ItemType Directory

# Monter le volume (remplacer par le bon volume)
# Option 1 : Si le volume a une lettre (ex: E:)
$volume = Get-Volume -DriveLetter E
$volume | Get-Partition | Add-PartitionAccessPath -AccessPath "C:\MountPoints\Archives"

# Option 2 : Par numéro de partition
Add-PartitionAccessPath -DiskNumber 1 -PartitionNumber 2 -AccessPath "C:\MountPoints\Archives"
```

### 🔹 Gérer les points de montage

**Lister les points de montage :**

```powershell
# Voir tous les chemins d'accès d'un volume
Get-Volume | Get-Partition | Select-Object DriveLetter, AccessPaths

# Voir les détails d'un point de montage spécifique
Get-Partition | Where-Object {$_.AccessPaths -like "*Archives*"}
```

**Supprimer un point de montage :**

```powershell
# Via PowerShell
Remove-PartitionAccessPath -DiskNumber 1 -PartitionNumber 2 -AccessPath "C:\MountPoints\Archives"

# Via Gestionnaire de disques
# Clic droit > Modifier la lettre... > Supprimer
```

> [!warning] Attention La suppression d'un point de montage ne supprime pas les données du volume, elle le rend juste inaccessible via ce chemin.

### 🔹 Combinaison lettre + point de montage

Un volume peut avoir :

- Une lettre de lecteur ET un ou plusieurs points de montage
- Uniquement des points de montage (aucune lettre)
- Uniquement une lettre de lecteur

> [!example] Configuration typique pour serveur de fichiers
> 
> ```
> C:\              (Système - Volume principal)
> C:\Data\
>   ├── Archives\  → Disque 1 (2 To) monté ici
>   ├── Backups\   → Disque 2 (4 To) monté ici
>   └── Projects\  → Disque 3 (1 To) monté ici
> ```
> 
> Les utilisateurs accèdent à `\\Serveur\Data\Archives` sans savoir que c'est un disque séparé.

---

## Commandes diskpart

**diskpart** est l'utilitaire en ligne de commande pour la gestion avancée des disques. Plus puissant que le Gestionnaire de disques, il est indispensable pour l'automatisation et le dépannage.

### 🔹 Lancement et navigation

```bash
# Lancer diskpart (nécessite des privilèges admin)
diskpart

# Une fois dans diskpart, le prompt change en "DISKPART>"
```

**Commandes de base :**

```bash
# Lister les disques
DISKPART> list disk

# Lister les volumes
DISKPART> list volume

# Lister les partitions (après avoir sélectionné un disque)
DISKPART> list partition

# Obtenir de l'aide
DISKPART> help
DISKPART> help <commande>  # Aide sur une commande spécifique
```

### 🔹 Sélection d'objets

Avant toute opération, il faut sélectionner le disque, volume ou partition cible.

```bash
# Sélectionner un disque
DISKPART> select disk 0        # Sélectionne le disque 0

# Sélectionner un volume
DISKPART> select volume 2      # Par numéro
DISKPART> select volume C      # Par lettre de lecteur

# Sélectionner une partition
DISKPART> select partition 1   # Nécessite d'avoir sélectionné un disque avant

# Vérifier la sélection actuelle
DISKPART> list disk            # L'élément sélectionné a un astérisque (*)
```

> [!tip] Vérification avant action Utilisez toujours `detail disk` ou `detail volume` pour confirmer que vous avez sélectionné le bon objet avant toute opération destructive.

### 🔹 Informations détaillées

```bash
# Détails sur le disque sélectionné
DISKPART> detail disk

# Détails sur le volume sélectionné
DISKPART> detail volume

# Détails sur la partition sélectionnée
DISKPART> detail partition
```

### 🔹 Initialisation et nettoyage de disques

**Nettoyer complètement un disque :**

```bash
# ATTENTION : Efface TOUT le disque !
DISKPART> select disk 1
DISKPART> clean

# Nettoyage sécurisé (écrase avec des zéros)
DISKPART> clean all   # Très long, mais plus sécurisé
```

> [!warning] Danger `clean` et `clean all` effacent TOUTES les données du disque sélectionné de façon irréversible. Vérifiez TOUJOURS deux fois le numéro du disque !

**Initialiser un disque :**

```bash
# Convertir en GPT (recommandé pour disques > 2 To)
DISKPART> convert gpt

# Convertir en MBR (pour compatibilité)
DISKPART> convert mbr
```

### 🔹 Création de partitions

**Créer une partition principale :**

```bash
# Sélectionner le disque
DISKPART> select disk 1

# Créer une partition utilisant tout l'espace libre
DISKPART> create partition primary

# Créer une partition de taille spécifique (en Mo)
DISKPART> create partition primary size=50000   # 50 Go

# La partition est créée mais non formatée
```

**Créer une partition étendue et des lecteurs logiques :**

```bash
# Sur un disque MBR uniquement
DISKPART> create partition extended

# Puis créer des lecteurs logiques
DISKPART> create partition logical size=20000
```

### 🔹 Formatage

```bash
# Sélectionner le volume à formater
DISKPART> select volume 3

# Formatage rapide en NTFS avec label
DISKPART> format fs=ntfs label="Données" quick

# Formatage complet (plus long)
DISKPART> format fs=ntfs label="Données"

# Autres systèmes de fichiers
DISKPART> format fs=refs label="Archive" quick
DISKPART> format fs=exfat label="USB" quick
```

**Options de format :**

- `fs=` : Système de fichiers (ntfs, refs, fat32, exfat)
- `label=` : Nom du volume
- `quick` : Formatage rapide (recommandé sauf diagnostic)
- `unit=` : Taille d'unité d'allocation (par défaut = recommandé)

### 🔹 Attribution de lettres de lecteur

```bash
# Sélectionner le volume
DISKPART> select volume 3

# Attribuer une lettre
DISKPART> assign letter=E

# Retirer la lettre de lecteur
DISKPART> remove letter=E

# Attribuer la prochaine lettre disponible
DISKPART> assign
```

### 🔹 Points de montage avec diskpart

```bash
# Créer un point de montage
DISKPART> select volume 3
DISKPART> assign mount="C:\MountPoints\Archives"

# Supprimer un point de montage
DISKPART> remove mount="C:\MountPoints\Archives"
```

### 🔹 Extension et réduction de volumes

```bash
# Sélectionner le volume à étendre
DISKPART> select volume C

# Étendre de 10 Go (10240 Mo)
DISKPART> extend size=10240

# Étendre avec tout l'espace disponible adjacent
DISKPART> extend

# Réduire un volume de 5 Go
DISKPART> shrink desired=5120

# Réduire au maximum possible
DISKPART> shrink querymax    # Affiche l'espace récupérable
DISKPART> shrink minimum=5120  # Réduction minimale spécifiée
```

### 🔹 Gestion des disques dynamiques

```bash
# Convertir un disque de base en dynamique
DISKPART> select disk 1
DISKPART> convert dynamic

# ATTENTION : Impossible de revenir en arrière sans perte de données

# Créer un volume simple sur disque dynamique
DISKPART> create volume simple size=50000 disk=1

# Créer un volume fractionné (spanned)
DISKPART> create volume simple size=100000 disk=1,2

# Créer un miroir (RAID-1)
DISKPART> add disk=2  # Après avoir sélectionné le volume à miroiter
```

### 🔹 Gestion des attributs

```bash
# Voir les attributs d'un volume
DISKPART> select volume C
DISKPART> attributes volume

# Mettre en lecture seule
DISKPART> attributes volume set readonly

# Enlever la lecture seule
DISKPART> attributes volume clear readonly

# Cacher le volume (pas de lettre automatique)
DISKPART> attributes volume set hidden

# Marquer comme partition système (EFI)
DISKPART> select partition 1
DISKPART> set id=c12a7328-f81f-11d2-ba4b-00a0c93ec93b
```

### 🔹 États et santé

```bash
# Mettre un disque hors ligne
DISKPART> select disk 1
DISKPART> offline disk

# Remettre en ligne
DISKPART> online disk

# Actualiser les informations (rescanner)
DISKPART> rescan

# Marquer un volume comme actif (bootable)
DISKPART> select partition 1
DISKPART> active
```

### 🔹 Scripts diskpart

Pour automatiser des tâches, vous pouvez créer des scripts diskpart.

**Créer un fichier script (ex: `init-disk.txt`) :**

```bash
select disk 1
clean
convert gpt
create partition primary
format fs=ntfs label="Données" quick
assign letter=E
```

**Exécuter le script :**

```powershell
diskpart /s C:\Scripts\init-disk.txt
```

> [!example] Script d'initialisation automatique Utile pour provisionner rapidement plusieurs serveurs avec la même configuration de disques.

### 🔹 Commandes PowerShell équivalentes

PowerShell offre des cmdlets modernes pour la gestion des disques :

```powershell
# Lister les disques
Get-Disk

# Initialiser un disque
Initialize-Disk -Number 1 -PartitionStyle GPT

# Créer une partition
New-Partition -DiskNumber 1 -Size 50GB -DriveLetter E

# Formater
Format-Volume -DriveLetter E -FileSystem NTFS -NewFileSystemLabel "Données"

# Étendre un volume
Resize-Partition -DriveLetter C -Size 100GB

# Tout en une ligne (pipeline)
Get-Disk 1 | Initialize-Disk -PartitionStyle GPT | 
    New-Partition -UseMaximumSize -DriveLetter E | 
    Format-Volume -FileSystem NTFS -NewFileSystemLabel "Données"
```

---

## Bonnes pratiques

### ✅ Organisation des disques

- **Séparer le système des données** : C: pour Windows, autres disques/volumes pour les données
- **Utiliser GPT** pour les nouveaux disques (sauf contraintes de compatibilité)
- **Prévoir de l'espace libre** pour étendre les volumes si nécessaire (10-20%)
- **Documenter la configuration** : tenir à jour un schéma des disques et leur usage

### ✅ Sécurité et fiabilité

- **Toujours vérifier** le disque/volume sélectionné avant toute opération destructive
- **Sauvegarder avant** toute modification importante (redimensionnement, conversion)
- **Tester la restauration** des sauvegardes régulièrement
- **Surveiller la santé** des disques avec les journaux d'événements et S.M.A.R.T.

### ✅ Performances

- **Aligner les partitions** : Les outils modernes le font automatiquement, mais vérifier sur d'anciennes installations
- **Choisir la bonne taille d'allocation** : Par défaut pour usage général, 64 Ko pour fichiers volumineux (vidéos, VMs)
- **Éviter la fragmentation** : Prévoir suffisamment d'espace libre (>15%)
- **Utiliser des disques dédiés** pour les bases de données et logs

### ✅ Utilisation de diskpart

- **Scripts pour automatisation** : Provisionner plusieurs serveurs de façon identique
- **Documenter les scripts** avec des commentaires
- **Tester dans un environnement de dev/test** avant la production
- **Préférer PowerShell** pour les nouvelles automatisations (plus moderne, plus flexible)

### ✅ Points de montage

- **Naming cohérent** : Utiliser une convention claire pour les dossiers de montage (ex: `C:\Mount\`, `C:\Volumes\`)
- **Documentation** : Maintenir une liste des points de montage et leur usage
- **Permissions** : Vérifier que les permissions NTFS sont correctes sur les dossiers montés
- **Sauvegardes** : S'assurer que les outils de backup traversent les points de montage

> [!warning] Pièges courants
> 
> - Oublier de sauvegarder avant une opération de redimensionnement
> - Convertir en dynamique sans comprendre les limitations
> - Utiliser `clean` sur le mauvais disque
> - Étendre un volume système en production sans test préalable
> - Supprimer une lettre de lecteur utilisée par des applications

> [!tip] Astuces d'expert
> 
> - Utilisez `list disk` dans diskpart pour identifier rapidement un disque par sa taille
> - Les volumes sans lettre sont utiles pour les partitions de récupération ou systèmes
> - Combinez diskpart avec un fichier réponse pour l'installation automatisée de Windows
> - PowerShell permet des opérations en masse sur plusieurs serveurs via PSRemoting

---

## 🎯 Points clés à retenir

- Les **disques de base** sont suffisants pour la plupart des besoins
- Les **disques dynamiques** sont obsolètes, préférer les Espaces de stockage
- **GPT** est le standard moderne pour les tables de partition
- Le **Gestionnaire de disques** est pratique pour les opérations ponctuelles
- **diskpart** et **PowerShell** sont essentiels pour l'automatisation
- Les **points de montage** permettent de dépasser la limite de 26 lecteurs
- Toujours **vérifier et sauvegarder** avant toute opération destructive