

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

## 🎯 Introduction au Registre comme PSDrive

Le registre Windows est une base de données hiérarchique qui stocke les paramètres de configuration du système d'exploitation et des applications. PowerShell traite le registre comme un **système de fichiers virtuel** grâce au concept de **PSDrive** (PowerShell Drive).

> [!info] Qu'est-ce qu'un PSDrive ? Un PSDrive est un point de montage qui permet d'accéder à différentes sources de données (registre, système de fichiers, certificats, etc.) avec la même syntaxe que pour naviguer dans des dossiers.

### Pourquoi utiliser PowerShell pour le Registre ?

- **Automatisation** : Modifier plusieurs clés en une seule commande
- **Lecture à distance** : Accéder au registre de machines distantes
- **Scripting** : Intégrer des modifications du registre dans des scripts de déploiement
- **Sécurité** : Effectuer des modifications avec traçabilité

### Vérifier les PSDrives disponibles

```powershell
# Lister tous les PSDrives disponibles
Get-PSDrive

# Filtrer uniquement les PSDrives du registre
Get-PSDrive | Where-Object { $_.Provider -like "*Registry*" }
```

> [!example] Résultat typique
> 
> ```
> Name    Used (GB)  Free (GB)  Provider    Root
> ----    ---------  ---------  --------    ----
> HKCU                          Registry    HKEY_CURRENT_USER
> HKLM                          Registry    HKEY_LOCAL_MACHINE
> ```

---

## 🏛️ Les Ruches Principales

Le registre Windows est organisé en **ruches** (hives), qui sont des groupes de clés de haut niveau. Chaque ruche a un rôle spécifique.

### HKLM: (HKEY_LOCAL_MACHINE)

```powershell
# Accéder à HKLM
Set-Location HKLM:
```

> [!info] Caractéristiques de HKLM
> 
> - **Portée** : Configuration globale de la machine
> - **Contenu** : Paramètres système, pilotes, services, logiciels installés
> - **Permissions** : Nécessite généralement des droits administrateur pour modification
> - **Persistance** : Affecte tous les utilisateurs de la machine

**Sous-clés importantes :**

|Sous-clé|Description|
|---|---|
|`SOFTWARE`|Configuration des applications installées|
|`SYSTEM`|Configuration système, services, pilotes|
|`HARDWARE`|Informations sur le matériel détecté au démarrage|
|`SAM`|Security Account Manager (comptes utilisateurs)|
|`SECURITY`|Politiques de sécurité|

```powershell
# Explorer les logiciels installés
Get-ChildItem "HKLM:\SOFTWARE"

# Accéder aux services système
Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services"
```

### HKCU: (HKEY_CURRENT_USER)

```powershell
# Accéder à HKCU
Set-Location HKCU:
```

> [!info] Caractéristiques de HKCU
> 
> - **Portée** : Configuration spécifique à l'utilisateur actuel
> - **Contenu** : Préférences utilisateur, paramètres d'applications
> - **Permissions** : L'utilisateur peut généralement modifier ses propres paramètres
> - **Persistance** : Affecte uniquement l'utilisateur connecté

**Sous-clés importantes :**

|Sous-clé|Description|
|---|---|
|`SOFTWARE`|Préférences des applications pour cet utilisateur|
|`Environment`|Variables d'environnement de l'utilisateur|
|`Control Panel`|Paramètres du Panneau de configuration|
|`Keyboard Layout`|Configuration du clavier|
|`Network`|Lecteurs réseau mappés|

```powershell
# Variables d'environnement utilisateur
Get-ChildItem "HKCU:\Environment"

# Préférences du bureau
Get-ChildItem "HKCU:\Control Panel\Desktop"
```

### HKCR: (HKEY_CLASSES_ROOT)

> [!warning] PSDrive non monté par défaut HKCR n'est pas automatiquement disponible comme PSDrive. Il faut le créer manuellement.

```powershell
# Créer le PSDrive HKCR
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

# Utiliser HKCR
Set-Location HKCR:
```

> [!info] Caractéristiques de HKCR
> 
> - **Portée** : Associations de fichiers et informations COM
> - **Contenu** : Extensions de fichiers, types MIME, classes COM
> - **Nature** : Vue fusionnée de `HKLM:\SOFTWARE\Classes` et `HKCU:\SOFTWARE\Classes`
> - **Utilité** : Gérer les applications par défaut pour ouvrir les fichiers

```powershell
# Voir l'association pour les fichiers .txt
Get-Item "HKCR:\.txt"

# Explorer les protocoles URL
Get-ChildItem "HKCR:" | Where-Object { $_.Name -match "^HKEY.*\\http$" }
```

### HKU: (HKEY_USERS)

```powershell
# Créer le PSDrive HKU
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS

# Lister tous les profils utilisateur chargés
Get-ChildItem HKU:
```

> [!info] Caractéristiques de HKU
> 
> - **Portée** : Tous les profils utilisateurs chargés
> - **Contenu** : Configuration de chaque utilisateur (équivalent à leur HKCU)
> - **SID** : Chaque utilisateur est identifié par son Security Identifier
> - **Utilité** : Modifier les paramètres de plusieurs utilisateurs simultanément

```powershell
# Identifier le SID de l'utilisateur actuel
$currentSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

# Accéder aux paramètres d'un utilisateur spécifique
Get-ChildItem "HKU:\$currentSID\Software"
```

### HKCC: (HKEY_CURRENT_CONFIG)

```powershell
# Créer le PSDrive HKCC
New-PSDrive -Name HKCC -PSProvider Registry -Root HKEY_CURRENT_CONFIG
```

> [!info] Caractéristiques de HKCC
> 
> - **Portée** : Profil matériel actuel
> - **Contenu** : Configuration matérielle utilisée au démarrage
> - **Nature** : Lien symbolique vers `HKLM:\SYSTEM\CurrentControlSet\Hardware Profiles\Current`
> - **Utilité** : Rarement utilisé directement

---

## 🧭 Navigation avec Set-Location

La navigation dans le registre utilise les mêmes commandes que pour le système de fichiers.

### Syntaxe de base

```powershell
# Syntaxe complète
Set-Location -Path "HKLM:\SOFTWARE\Microsoft"

# Alias cd (plus court)
cd HKLM:\SOFTWARE\Microsoft

# Alias chdir (style CMD)
chdir HKCU:\Environment
```

### Navigation relative et absolue

```powershell
# Chemin absolu (depuis la racine)
Set-Location "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"

# Navigation relative (depuis la position actuelle)
cd .\Run        # Descendre d'un niveau
cd ..           # Remonter d'un niveau
cd ..\..        # Remonter de deux niveaux

# Revenir à la racine du PSDrive
cd HKLM:\
```

> [!tip] Astuce de navigation Utilisez `Push-Location` et `Pop-Location` pour sauvegarder et restaurer votre position :
> 
> ```powershell
> # Sauvegarder la position actuelle
> Push-Location
> cd HKLM:\SOFTWARE\Classes
> # ... faire des opérations ...
> # Revenir à la position sauvegardée
> Pop-Location
> ```

### Obtenir le chemin actuel

```powershell
# Afficher le chemin complet actuel
Get-Location

# Sauvegarder le chemin dans une variable
$currentPath = Get-Location
Write-Host "Position actuelle : $currentPath"

# Afficher uniquement le chemin (sans l'objet)
(Get-Location).Path
```

> [!example] Exemple de navigation complète
> 
> ```powershell
> # Démarrer dans C:\
> Set-Location C:\
> 
> # Aller dans le registre
> Set-Location HKLM:\
> 
> # Descendre dans SOFTWARE
> cd SOFTWARE
> 
> # Descendre dans Microsoft
> cd Microsoft
> 
> # Vérifier la position
> Get-Location
> # Résultat : HKLM:\SOFTWARE\Microsoft
> 
> # Remonter à HKLM:\SOFTWARE
> cd ..
> ```

---

## 📂 Lister les Clés avec Get-ChildItem

`Get-ChildItem` (alias `ls`, `dir`, `gci`) permet de lister le contenu d'une clé de registre.

### Syntaxe de base

```powershell
# Lister les sous-clés de la position actuelle
Get-ChildItem

# Lister les sous-clés d'un chemin spécifique
Get-ChildItem "HKLM:\SOFTWARE"

# Alias courts
ls HKLM:\SOFTWARE
dir HKCU:\Environment
gci "HKLM:\SYSTEM\CurrentControlSet\Services"
```

### Options de filtrage

```powershell
# Filtrer par nom (avec wildcards)
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\*Version*"

# Filtrer avec Where-Object
Get-ChildItem "HKLM:\SOFTWARE" | Where-Object { $_.Name -like "*Microsoft*" }

# Lister uniquement les N premiers résultats
Get-ChildItem "HKLM:\SOFTWARE" | Select-Object -First 10
```

### Navigation récursive

```powershell
# Lister TOUTES les sous-clés (attention : peut être très long)
Get-ChildItem "HKLM:\SOFTWARE\Microsoft" -Recurse

# Limiter la profondeur de récursion
Get-ChildItem "HKLM:\SOFTWARE\Microsoft" -Recurse -Depth 2

# Compter le nombre total de sous-clés
(Get-ChildItem "HKLM:\SOFTWARE\Microsoft" -Recurse).Count
```

> [!warning] Attention à la récursion Utiliser `-Recurse` sur des clés de haut niveau comme `HKLM:\SOFTWARE` peut prendre plusieurs minutes et retourner des milliers de résultats. Limitez toujours la profondeur ou filtrez les résultats.

### Affichage détaillé

```powershell
# Affichage en liste avec détails
Get-ChildItem "HKLM:\SOFTWARE\Microsoft" | Format-List

# Affichage en tableau compact
Get-ChildItem "HKLM:\SOFTWARE\Microsoft" | Format-Table -AutoSize

# Sélectionner des propriétés spécifiques
Get-ChildItem "HKLM:\SOFTWARE\Microsoft" | 
    Select-Object Name, SubKeyCount, ValueCount
```

### Propriétés des clés

```powershell
# Obtenir les propriétés complètes d'une clé
Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" | 
    Select-Object *
```

> [!info] Propriétés principales d'une clé
> 
> - **Name** : Nom complet (chemin) de la clé
> - **PSChildName** : Nom court de la clé
> - **SubKeyCount** : Nombre de sous-clés
> - **ValueCount** : Nombre de valeurs (entrées) dans la clé
> - **Property** : Liste des noms des valeurs

---

## 🌳 Structure Hiérarchique du Registre

Le registre Windows suit une structure arborescente stricte composée de **clés** et **valeurs**.

### Anatomie d'une clé de registre

```
HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion
│
├── Clé parente : HKLM:\SOFTWARE\Microsoft\Windows
├── Nom de la clé : CurrentVersion
│
├── Sous-clés (SubKeys) :
│   ├── Run
│   ├── RunOnce
│   ├── Uninstall
│   └── ...
│
└── Valeurs (Values/Properties) :
    ├── ProgramFilesDir = "C:\Program Files"
    ├── CommonFilesDir = "C:\Program Files\Common Files"
    └── ...
```

### Différence entre Clés et Valeurs

|Aspect|Clé (Key)|Valeur (Value/Property)|
|---|---|---|
|**Nature**|Conteneur (dossier)|Donnée (fichier)|
|**Fonction**|Organise la hiérarchie|Stocke l'information|
|**Commande**|`Get-ChildItem`|`Get-ItemProperty`|
|**Peut contenir**|Sous-clés et valeurs|Une seule donnée typée|

> [!example] Exemple concret
> 
> ```
> HKCU:\Control Panel\Desktop
> ├── [CLÉ] WindowMetrics
> ├── [VALEUR] Wallpaper = "C:\Windows\Web\Wallpaper\..."
> └── [VALEUR] ScreenSaveActive = "1"
> ```

### Visualiser la structure

```powershell
# Afficher la structure d'une clé
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" | 
    Select-Object PSChildName, SubKeyCount, ValueCount

# Afficher les valeurs d'une clé (nous verrons Get-ItemProperty dans une autre section)
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
```

### Profondeur et organisation

```powershell
# Compter les niveaux de profondeur d'un chemin
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$depth = ($path -split '\\').Count - 1
Write-Host "Profondeur : $depth niveaux"

# Parcourir la hiérarchie niveau par niveau
function Show-RegistryTree {
    param($Path, $Depth = 0)
    
    $indent = "  " * $Depth
    $items = Get-ChildItem $Path -ErrorAction SilentlyContinue
    
    foreach ($item in $items) {
        Write-Host "$indent$($item.PSChildName)"
        if ($Depth -lt 2) {  # Limiter à 2 niveaux
            Show-RegistryTree -Path $item.PSPath -Depth ($Depth + 1)
        }
    }
}

# Utiliser la fonction
Show-RegistryTree "HKLM:\SOFTWARE\Microsoft\Windows"
```

---

## 🛣️ Chemins de Registre

Les chemins de registre suivent des conventions spécifiques qui diffèrent légèrement des chemins de fichiers.

### Formats de chemins

#### Format PowerShell (PSDrive)

```powershell
# Format recommandé avec PSDrive
HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion

# Format avec Get-Item/Get-ChildItem
Get-Item "HKLM:\SOFTWARE\Microsoft"
```

#### Format Win32 (Registry::)

```powershell
# Format avec provider explicite
Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft

# Équivalent avec Get-Item
Get-Item "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft"
```

#### Format .NET / API Windows

```powershell
# Format utilisé par les APIs .NET et Windows
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion

# Attention : ce format ne fonctionne PAS directement avec les cmdlets PowerShell
# Il faut le convertir en format PowerShell
```

### Conversion entre formats

```powershell
# Convertir du format Win32 vers PSDrive
$win32Path = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft"
$psdrivePath = $win32Path -replace "HKEY_LOCAL_MACHINE", "HKLM:" `
                          -replace "HKEY_CURRENT_USER", "HKCU:"

# Convertir du format PSDrive vers Win32
$psdrivePath = "HKLM:\SOFTWARE\Microsoft"
$win32Path = $psdrivePath -replace "HKLM:\\", "HKEY_LOCAL_MACHINE\" `
                          -replace "HKCU:\\", "HKEY_CURRENT_USER\"
```

### Caractères spéciaux dans les chemins

```powershell
# Échapper les espaces avec guillemets
Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

# Chemins avec caractères spéciaux
Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

# Utiliser des backticks pour échapper (rarement nécessaire)
Get-Item HKLM:\SOFTWARE\Microsoft\`Windows`
```

> [!tip] Astuce - Utiliser Tab pour l'auto-complétion PowerShell supporte l'auto-complétion avec Tab dans le registre :
> 
> ```powershell
> cd HKLM:\SOFT[TAB]       # Complète en SOFTWARE
> cd .\Micro[TAB]          # Complète en Microsoft
> ```

### Chemins relatifs vs absolus

```powershell
# Chemin ABSOLU : depuis la racine du PSDrive
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"

# Chemin RELATIF : depuis la position actuelle
Set-Location "HKLM:\SOFTWARE\Microsoft"
Get-ChildItem ".\Windows\CurrentVersion"  # .\ indique position actuelle

# Remonter avec ..
Set-Location "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
Get-ChildItem "..\..\"  # Remonte à HKLM:\SOFTWARE\Microsoft
```

### Construction dynamique de chemins

```powershell
# Concaténer des chemins
$base = "HKLM:\SOFTWARE"
$software = "Microsoft\Windows"
$fullPath = Join-Path $base $software

# Avec variables
$ruche = "HKLM:"
$chemin = "SOFTWARE\Microsoft\Windows\CurrentVersion"
$completePath = "$ruche\$chemin"

# Tester l'existence d'un chemin
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion") {
    Write-Host "Le chemin existe"
}
```

---

## ⚠️ Pièges Courants

### 1. Confusion entre clés et valeurs

```powershell
# ❌ FAUX : Get-ChildItem ne retourne PAS les valeurs
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"

# ✅ CORRECT : Pour lire les valeurs, utiliser Get-ItemProperty
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
```

> [!warning] Rappel important
> 
> - `Get-ChildItem` → Liste les **sous-clés**
> - `Get-ItemProperty` → Liste les **valeurs** (vu dans une autre section)

### 2. Permissions insuffisantes

```powershell
# ❌ Erreur courante : tentative de modification sans droits admin
Set-Location "HKLM:\SOFTWARE"
# Access denied si pas administrateur

# ✅ Solution : Lancer PowerShell en tant qu'administrateur
# Clic droit > Exécuter en tant qu'administrateur
```

> [!tip] Vérifier si on est administrateur
> 
> ```powershell
> $isAdmin = ([Security.Principal.WindowsPrincipal] `
>     [Security.Principal.WindowsIdentity]::GetCurrent() `
> ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
> 
> if (-not $isAdmin) {
>     Write-Warning "Ce script nécessite des droits administrateur"
> }
> ```

### 3. Backslash vs Forward slash

```powershell
# ❌ FAUX : Forward slash ne fonctionne pas
Get-Item "HKLM:/SOFTWARE/Microsoft"

# ✅ CORRECT : Toujours utiliser backslash
Get-Item "HKLM:\SOFTWARE\Microsoft"
```

### 4. Oublier le deux-points après la ruche

```powershell
# ❌ FAUX : Manque le :
Get-Item "HKLM\SOFTWARE\Microsoft"

# ✅ CORRECT : Le : est obligatoire
Get-Item "HKLM:\SOFTWARE\Microsoft"
```

### 5. Navigation récursive trop large

```powershell
# ❌ DANGEREUX : Peut prendre 10+ minutes et saturer la mémoire
Get-ChildItem "HKLM:\SOFTWARE" -Recurse

# ✅ MIEUX : Limiter la profondeur
Get-ChildItem "HKLM:\SOFTWARE" -Recurse -Depth 2

# ✅ OPTIMAL : Cibler précisément
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows" -Recurse -Depth 1
```

### 6. Clés avec espaces non échappées

```powershell
# ❌ FAUX : Espaces non gérés
Get-Item HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion

# ✅ CORRECT : Utiliser des guillemets
Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
```

### 7. PSDrives non créés

```powershell
# ❌ ERREUR : HKCR n'existe pas par défaut
Get-ChildItem HKCR:\

# ✅ CORRECT : Créer le PSDrive d'abord
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
Get-ChildItem HKCR:\
```

### 8. Modification accidentelle du registre

```powershell
# ⚠️ DANGER : Toujours vérifier avant de modifier
# Ne jamais exécuter de commandes de modification sans comprendre leur impact

# ✅ BONNE PRATIQUE : Tester avec -WhatIf (vu dans une autre section)
# Set-ItemProperty -Path "..." -Name "..." -Value "..." -WhatIf
```

> [!warning] Sécurité du registre
> 
> - Toujours faire une sauvegarde avant modification
> - Tester d'abord sur une machine de test
> - Documenter chaque modification
> - Utiliser `-WhatIf` et `-Confirm` pour les opérations sensibles

---

## 💡 Astuces Pratiques

### Créer tous les PSDrives en une fois

```powershell
# Script à exécuter au démarrage de PowerShell
if (-not (Get-PSDrive -Name HKCR -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}
if (-not (Get-PSDrive -Name HKU -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
}
if (-not (Get-PSDrive -Name HKCC -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name HKCC -PSProvider Registry -Root HKEY_CURRENT_CONFIG | Out-Null
}

Write-Host "✅ Tous les PSDrives du registre sont maintenant disponibles"
```

### Ajouter au profil PowerShell

```powershell
# Éditer votre profil PowerShell
notepad $PROFILE

# Ajouter le script de création des PSDrives
# Sauvegarder et fermer
# Les PSDrives seront créés à chaque démarrage de PowerShell
```

### Rechercher une clé par nom

```powershell
# Rechercher toutes les clés contenant "Windows" dans SOFTWARE
Get-ChildItem "HKLM:\SOFTWARE" -Recurse -Depth 3 | 
    Where-Object { $_.PSChildName -like "*Windows*" } |
    Select-Object Name
```

### Explorer visuellement avec Out-GridView

```powershell
# Afficher les sous-clés dans une fenêtre interactive
Get-ChildItem "HKLM:\SOFTWARE\Microsoft" | Out-GridView -Title "Sous-clés Microsoft"

# Permet de filtrer, trier et sélectionner facilement
```

### Comparer deux clés

```powershell
# Comparer le contenu de deux clés similaires
$key1 = Get-ChildItem "HKLM:\SOFTWARE\Microsoft"
$key2 = Get-ChildItem "HKCU:\SOFTWARE\Microsoft"

Compare-Object $key1.PSChildName $key2.PSChildName
```

---

> [!tip] 🎯 Points clés à retenir
> 
> - Le registre est navigable comme un système de fichiers grâce aux PSDrives
> - `HKLM:` pour la configuration machine, `HKCU:` pour l'utilisateur
> - `Get-ChildItem` liste les **clés** (pas les valeurs)
> - `Set-Location` (ou `cd`) pour naviguer
> - Toujours utiliser des guillemets pour les chemins avec espaces
> - Les ruches HKCR, HKU et HKCC doivent être créées manuellement
> - Attention aux permissions : HKLM nécessite souvent des droits admin