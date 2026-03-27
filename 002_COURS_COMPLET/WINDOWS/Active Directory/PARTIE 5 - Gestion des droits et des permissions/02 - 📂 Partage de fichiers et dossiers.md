

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

Le partage de fichiers et dossiers dans un environnement Active Directory permet aux utilisateurs d'accéder à des ressources réseau de manière centralisée et sécurisée. Cette fonctionnalité repose sur deux mécanismes de sécurité distincts mais complémentaires : les **permissions de partage** (Share Permissions) et les **permissions NTFS**.

> [!info] Pourquoi c'est important La maîtrise des partages réseau est essentielle pour :
> 
> - Permettre la collaboration entre utilisateurs et groupes
> - Centraliser les données d'entreprise
> - Appliquer une politique de sécurité cohérente
> - Faciliter les sauvegardes et la gestion des données

---

## Création de partages réseau

### 📌 Qu'est-ce qu'un partage réseau ?

Un partage réseau (ou partage SMB/CIFS) est un dossier local sur un serveur qui est rendu accessible via le réseau selon un chemin UNC (Universal Naming Convention) : `\\NomServeur\NomPartage`.

### 🛠️ Méthodes de création

#### Via l'interface graphique (GUI)

**Étape 1 : Accéder aux propriétés du dossier**

1. Clic droit sur le dossier à partager
2. Sélectionner **Propriétés**
3. Onglet **Partage**
4. Cliquer sur **Partage avancé...**

**Étape 2 : Configurer le partage**

1. Cocher **Partager ce dossier**
2. Définir le **Nom du partage** (par défaut = nom du dossier)
3. Ajouter un **Commentaire** (optionnel, description du partage)
4. Définir le **Nombre limite d'utilisateurs simultanés** (par défaut = illimité)
5. Cliquer sur **Autorisations** pour configurer les permissions de partage

> [!tip] Astuce - Partages masqués Ajouter un `$` à la fin du nom du partage le rend invisible dans l'explorateur réseau. Exemple : `Compta$` est accessible via `\\Serveur\Compta$` mais n'apparaît pas dans la liste des partages.

#### Via PowerShell

```powershell
# Créer un partage simple
New-SmbShare -Name "Documents" -Path "D:\Partages\Documents" -FullAccess "Tout le monde"

# Créer un partage avec description
New-SmbShare -Name "Projets" -Path "D:\Partages\Projets" `
    -Description "Dossiers de projets d'entreprise" `
    -FullAccess "DOMAINE\Admins du domaine" `
    -ChangeAccess "DOMAINE\Utilisateurs"

# Créer un partage masqué avec limite d'utilisateurs
New-SmbShare -Name "Confidential$" -Path "D:\Partages\Confidentiel" `
    -ConcurrentUserLimit 10 `
    -FullAccess "DOMAINE\Direction"

# Lister tous les partages existants
Get-SmbShare

# Obtenir les détails d'un partage spécifique
Get-SmbShare -Name "Documents"

# Modifier les permissions d'un partage existant
Grant-SmbShareAccess -Name "Documents" -AccountName "DOMAINE\Marketing" -AccessRight Change

# Révoquer l'accès
Revoke-SmbShareAccess -Name "Documents" -AccountName "DOMAINE\Invites" -Force

# Supprimer un partage
Remove-SmbShare -Name "Documents" -Force
```

> [!example] Exemple pratique Création d'un partage pour le service RH avec accès restreint :
> 
> ```powershell
> New-SmbShare -Name "RH" -Path "D:\Partages\RH" `
>     -Description "Documents du service Ressources Humaines" `
>     -FullAccess "DOMAINE\RH_Managers" `
>     -ChangeAccess "DOMAINE\RH_Employees" `
>     -ReadAccess "DOMAINE\Direction"
> ```

### 📊 Paramètres importants

|Paramètre|Description|Valeur par défaut|
|---|---|---|
|**Name**|Nom du partage (visible sur le réseau)|Nom du dossier|
|**Path**|Chemin local du dossier|-|
|**Description**|Description du partage|Vide|
|**ConcurrentUserLimit**|Nombre max d'utilisateurs simultanés|Illimité|
|**FullAccess**|Contrôle total (Lecture + Modification + Suppression)|Administrateurs|
|**ChangeAccess**|Modification (Lecture + Écriture)|-|
|**ReadAccess**|Lecture seule|-|

---

## Permissions de partage vs permissions NTFS

### 🔐 Les deux couches de sécurité

Dans Windows, l'accès à un fichier partagé est contrôlé par **deux systèmes de permissions distincts** qui s'appliquent successivement :

1. **Permissions de partage** (Share Permissions) : contrôle l'accès via le réseau
2. **Permissions NTFS** : contrôle l'accès au système de fichiers (local et réseau)

> [!warning] Règle d'or La permission **la plus restrictive** entre les deux s'applique toujours. Si Share = Lecture et NTFS = Contrôle total → l'utilisateur aura uniquement **Lecture**.

### 📋 Permissions de partage (Share Permissions)

Les permissions de partage sont **simples** et limitées à trois niveaux :

|Permission|Droits accordés|Usage typique|
|---|---|---|
|**Lecture** (Read)|Lire les fichiers et dossiers|Accès consultation uniquement|
|**Modification** (Change)|Lire, créer, modifier, supprimer|Accès utilisateurs standards|
|**Contrôle total** (Full Control)|Tous les droits + modification des permissions|Administrateurs du partage|

> [!info] Caractéristiques des permissions de partage
> 
> - S'appliquent **uniquement** lors de l'accès réseau (via `\\Serveur\Partage`)
> - **Ne s'appliquent pas** lors d'un accès local direct
> - Sont **simples** mais **peu granulaires**
> - Sont héritées sur l'ensemble du contenu du partage

### 🔧 Permissions NTFS

Les permissions NTFS sont **avancées** et offrent un contrôle très granulaire :

#### Permissions de base NTFS

|Permission|Description|Droits inclus|
|---|---|---|
|**Contrôle total**|Tous les droits possibles|Tout|
|**Modification**|Lire, écrire, modifier, supprimer des fichiers|Tout sauf permissions et propriété|
|**Lecture et exécution**|Lire et exécuter des programmes|Lecture + exécution|
|**Lecture**|Voir le contenu des fichiers et dossiers|Affichage uniquement|
|**Écriture**|Créer des fichiers et sous-dossiers|Création seulement|
|**Permissions spéciales**|Combinaison personnalisée|Variable|

#### Permissions avancées NTFS (sélection)

Les permissions avancées permettent un contrôle ultra-précis :

- **Parcourir le dossier / Exécuter le fichier**
- **Afficher le contenu du dossier / Lire les données**
- **Lire les attributs** et **Lire les attributs étendus**
- **Créer des fichiers / Écrire des données**
- **Créer des dossiers / Ajouter des données**
- **Écrire les attributs** et **Écrire les attributs étendus**
- **Supprimer les sous-dossiers et les fichiers**
- **Supprimer**
- **Lire les autorisations**
- **Modifier les autorisations**
- **Appropriation** (prendre possession)

> [!tip] Accès aux permissions avancées Clic droit sur dossier → Propriétés → Sécurité → Avancé → Ajouter/Modifier

### 🔄 Interaction entre les deux types de permissions

```
Accès réseau (\\Serveur\Partage\Fichier.txt)
    ↓
1. Vérification des permissions de PARTAGE
    ↓
2. Vérification des permissions NTFS
    ↓
3. Application de la permission LA PLUS RESTRICTIVE
```

> [!example] Exemples d'interactions
> 
> **Exemple 1 :**
> 
> - Permission de partage : **Modification**
> - Permission NTFS : **Lecture**
> - **Résultat** : Lecture (NTFS plus restrictif)
> 
> **Exemple 2 :**
> 
> - Permission de partage : **Lecture**
> - Permission NTFS : **Contrôle total**
> - **Résultat** : Lecture (Share plus restrictif)
> 
> **Exemple 3 :**
> 
> - Permission de partage : **Contrôle total**
> - Permission NTFS : **Contrôle total**
> - **Résultat** : Contrôle total (aucune restriction)

### 📊 Comparaison synthétique

|Critère|Permissions de partage|Permissions NTFS|
|---|---|---|
|**Portée**|Accès réseau uniquement|Local + Réseau|
|**Granularité**|3 niveaux (simple)|13+ permissions (avancé)|
|**Héritage**|Tout le partage|Configurable par dossier/fichier|
|**Système de fichiers**|Tous (FAT32, NTFS, etc.)|NTFS uniquement|
|**Complexité**|Facile|Complexe|
|**Usage recommandé**|Configuration large|Contrôle fin|

> [!warning] Piège courant Oublier de vérifier les permissions NTFS est l'erreur n°1 lors du dépannage d'accès refusé. Même si les permissions de partage sont correctes, les permissions NTFS peuvent bloquer l'accès !

### 🛠️ Configuration via PowerShell

```powershell
# Configurer les permissions de partage
Grant-SmbShareAccess -Name "Projets" -AccountName "DOMAINE\Equipe_Dev" -AccessRight Change -Force

# Vérifier les permissions de partage actuelles
Get-SmbShareAccess -Name "Projets"

# Configurer les permissions NTFS (nécessite le module NTFSSecurity ou icacls)
# Installation du module NTFSSecurity
Install-Module -Name NTFSSecurity -Force

# Ajouter une permission NTFS
Add-NTFSAccess -Path "D:\Partages\Projets" -Account "DOMAINE\Equipe_Dev" -AccessRights Modify

# Lister les permissions NTFS
Get-NTFSAccess -Path "D:\Partages\Projets"

# Utilisation d'icacls (outil natif Windows)
icacls "D:\Partages\Projets" /grant "DOMAINE\Equipe_Dev:(OI)(CI)M"
# (OI) = Héritage objets (fichiers)
# (CI) = Héritage conteneurs (dossiers)
# M = Modification
```

---

## Bonnes pratiques

### ✅ Stratégie de configuration recommandée

> [!tip] Règle d'or : Share large, NTFS précis
> 
> - **Permissions de partage** : Définir à **Contrôle total** pour "Tout le monde" ou un groupe large
> - **Permissions NTFS** : Définir les permissions précises selon les besoins réels
> 
> Cette approche simplifie la gestion et évite la confusion entre les deux couches.

### 🏗️ Architecture des partages

#### Organisation logique

```
\\Serveur\Partages
├── Commun$          (accessible à tous, lecture seule)
├── Services         (dossiers par service)
│   ├── RH
│   ├── Compta
│   ├── IT
│   └── Commercial
├── Projets          (dossiers par projet)
└── Directions$      (accès direction uniquement)
```

#### Conventions de nommage

- **Noms clairs et explicites** : éviter les abréviations obscures
- **Pas d'espaces** dans les noms (ou utiliser underscore `_`)
- **Partages masqués** : ajouter `$` pour les ressources administratives
- **Majuscules cohérentes** : choisir une convention et la maintenir

### 🔒 Sécurité

> [!warning] Attention aux permissions par défaut Le groupe "Tout le monde" inclut les utilisateurs anonymes dans certaines configurations anciennes. Préférer l'utilisation de **"Utilisateurs authentifiés"** ou de groupes AD spécifiques.

#### Principes de moindre privilège

1. **Accorder uniquement les droits nécessaires**
    
    - Lecture pour la consultation
    - Modification pour le travail quotidien
    - Contrôle total uniquement pour les administrateurs
2. **Utiliser des groupes AD** plutôt que des utilisateurs individuels
    
    - Facilite la gestion
    - Évite les oublis lors des départs
    - Permet une traçabilité claire
3. **Activer l'audit** sur les ressources sensibles
    
    - Tracer les accès et modifications
    - Détecter les comportements anormaux
    - Preuves en cas d'incident

```powershell
# Activer l'audit sur un dossier (nécessite GPO ou configuration locale)
$acl = Get-Acl "D:\Partages\Confidentiel"
$auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule(
    "DOMAINE\Utilisateurs",
    "ReadAndExecute,Modify,Delete",
    "ContainerInherit,ObjectInherit",
    "None",
    "Success,Failure"
)
$acl.AddAuditRule($auditRule)
Set-Acl "D:\Partages\Confidentiel" $acl
```

### 🗂️ Gestion des permissions NTFS

#### Utilisation de l'héritage

- **Activer l'héritage** par défaut pour simplifier la gestion
- **Désactiver l'héritage** uniquement pour des besoins spécifiques (dossiers sensibles)
- **Privilégier la configuration au niveau parent** plutôt que fichier par fichier

#### Groupes de permissions recommandés

Créer des groupes AD dédiés pour chaque ressource :

```
Ressource : \\Serveur\Projets\ProjetX
Groupes AD :
- GG_ProjetX_Lecture     (lecture seule)
- GG_ProjetX_Contrib     (modification)
- GG_ProjetX_Admin       (contrôle total)
```

> [!info] Convention de nommage des groupes
> 
> - **GG** = Groupe Global (pour les permissions)
> - **DL** = Groupe Local de domaine (pour l'organisation)
> - **U** = Groupe Universel (pour les environnements multi-domaines)

### 📈 Performance et disponibilité

#### Limitations

- **Limiter le nombre d'utilisateurs simultanés** sur les partages non critiques
- **Surveiller l'utilisation disque** pour éviter la saturation
- **Implémenter des quotas** si nécessaire

```powershell
# Définir un quota utilisateur sur un volume NTFS
fsutil quota modify C: 10737418240 12884901888 "DOMAINE\Utilisateur"
# 10 Go d'avertissement, 12 Go limite
```

#### Haute disponibilité

- **DFS** (Distributed File System) pour la réplication et la tolérance de panne
- **Sauvegarde régulière** via Windows Server Backup ou solution tierce
- **Clichés instantanés** (Volume Shadow Copy) pour récupération utilisateur

```powershell
# Activer les clichés instantanés sur un volume
vssadmin add shadowstorage /for=D: /on=D: /maxsize=20%
vssadmin create shadow /for=D:
```

### 🔍 Dépannage

#### Commandes utiles

```powershell
# Vérifier les partages accessibles depuis un poste client
net view \\NomServeur

# Tester l'accès à un partage
Test-Path "\\Serveur\Partage"

# Afficher les sessions ouvertes sur le serveur
Get-SmbSession

# Afficher les fichiers ouverts
Get-SmbOpenFile

# Fermer une session spécifique
Close-SmbSession -SessionId 12345 -Force

# Vérifier les permissions effectives pour un utilisateur (GUI)
# Propriétés → Sécurité → Avancé → Onglet "Accès effectif"
```

> [!warning] Problèmes fréquents
> 
> **1. "Accès refusé" malgré les bonnes permissions**
> 
> - Vérifier que l'utilisateur est bien dans le groupe AD concerné
> - Vérifier l'héritage des permissions NTFS
> - Demander à l'utilisateur de se déconnecter/reconnecter (actualisation du jeton Kerberos)
> 
> **2. "Le partage n'apparaît pas"**
> 
> - Vérifier que le service "Serveur" est démarré
> - Vérifier le pare-feu (port 445 TCP)
> - Vérifier la découverte réseau sur le client
> 
> **3. "Performances lentes"**
> 
> - Vérifier la bande passante réseau
> - Désactiver l'indexation sur les gros volumes
> - Vérifier l'antivirus (exclusions nécessaires)

### 📝 Documentation

**Maintenir à jour :**

- Liste des partages et leur objectif
- Matrice des permissions (qui a accès à quoi)
- Procédures de demande d'accès
- Contacts des responsables de chaque ressource

> [!tip] Outil de documentation Utiliser un tableau Excel ou un système de ticketing (GLPI, JIRA) pour tracer les demandes et permissions accordées.

---

## 🎯 Points clés à retenir

1. **Deux couches de sécurité** : Share (réseau) + NTFS (système de fichiers)
2. **La permission la plus restrictive s'applique** toujours
3. **Bonne pratique** : Share large (Contrôle total), NTFS précis (groupes AD)
4. **Utiliser des groupes AD** pour gérer les permissions, jamais des utilisateurs individuels
5. **Noms de partage avec `$`** pour les rendre masqués
6. **Activer l'audit** sur les ressources sensibles
7. **Documentation** : toujours tracer qui a accès à quoi et pourquoi