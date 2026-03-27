

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

## 🎯 Introduction aux modules PowerShell

Un **module PowerShell** est un package réutilisable contenant des cmdlets, des fonctions, des variables et d'autres ressources. Les modules permettent d'organiser et de partager du code de manière structurée.

> [!info] Pourquoi utiliser des modules ?
> 
> - **Organisation** : Regrouper des fonctionnalités liées ensemble
> - **Réutilisabilité** : Partager du code entre scripts et projets
> - **Maintenance** : Mettre à jour le code à un seul endroit
> - **Performance** : Charger uniquement ce dont vous avez besoin

### Types de modules

|Type|Description|Extension|
|---|---|---|
|**Script Module**|Fichiers .psm1 contenant des fonctions|`.psm1`|
|**Binary Module**|Assemblages .NET compilés|`.dll`|
|**Manifest Module**|Fichiers de métadonnées|`.psd1`|
|**Dynamic Module**|Créés en mémoire avec `New-Module`|N/A|

---

## 🔍 Get-Module - Découvrir les modules

La cmdlet `Get-Module` permet de **lister et inspecter les modules** disponibles ou chargés dans votre session PowerShell.

### Syntaxe de base

```powershell
Get-Module [[-Name] <String[]>] [-All] [-ListAvailable] [-Refresh]
```

### 📌 Utilisation principale

#### Lister les modules chargés en session

```powershell
# Afficher tous les modules actuellement chargés
Get-Module

# Résultat typique :
# ModuleType Version    Name
# ---------- -------    ----
# Manifest   7.0.0.0    Microsoft.PowerShell.Management
# Manifest   7.0.0.0    Microsoft.PowerShell.Utility
```

> [!tip] Quand utiliser cette commande ?
> 
> - Pour vérifier quels modules sont actuellement actifs
> - Pour diagnostiquer des problèmes de performances (trop de modules chargés)
> - Pour voir les versions chargées en cas de conflit

#### Lister les modules disponibles sur le système

```powershell
# Afficher tous les modules installés (mais pas forcément chargés)
Get-Module -ListAvailable

# Rechercher un module spécifique
Get-Module -ListAvailable -Name "ActiveDirectory"

# Rechercher avec wildcard
Get-Module -ListAvailable -Name "*Azure*"
```

> [!info] Différence importante
> 
> - **Sans `-ListAvailable`** : Modules chargés en mémoire
> - **Avec `-ListAvailable`** : Modules installés sur le disque (disponibles au chargement)

### 🎛️ Paramètres essentiels

#### `-Name` : Filtrer par nom

```powershell
# Rechercher un module spécifique
Get-Module -Name "Microsoft.PowerShell.Utility"

# Utiliser des wildcards
Get-Module -ListAvailable -Name "Microsoft.*"

# Rechercher plusieurs modules
Get-Module -Name "PSReadLine", "PowerShellGet"
```

#### `-All` : Afficher toutes les versions

```powershell
# Par défaut, seule la version la plus récente est affichée
Get-Module -ListAvailable -Name "PowerShellGet"

# Afficher toutes les versions installées
Get-Module -ListAvailable -Name "PowerShellGet" -All
```

> [!warning] Attention aux versions multiples Avoir plusieurs versions d'un même module peut causer des conflits. Utilisez `-All` pour les détecter et nettoyer les anciennes versions.

#### `-Refresh` : Actualiser le cache

```powershell
# Forcer la re-détection des modules disponibles
Get-Module -ListAvailable -Refresh
```

> [!tip] Quand utiliser `-Refresh` ?
> 
> - Après l'installation d'un nouveau module
> - Si `Get-Module -ListAvailable` ne trouve pas un module que vous venez d'installer
> - Pour mettre à jour le cache sans redémarrer PowerShell

### 📊 Propriétés importantes

```powershell
# Afficher toutes les propriétés d'un module
Get-Module -Name "Microsoft.PowerShell.Utility" | Format-List *

# Propriétés clés :
# - Name          : Nom du module
# - Version       : Version du module
# - ModuleType    : Type (Script, Binary, Manifest)
# - Path          : Chemin du fichier .psd1 ou .psm1
# - ExportedCommands : Cmdlets/fonctions disponibles
# - Author        : Auteur du module
# - Description   : Description du module
# - CompanyName   : Société/organisation
```

#### Exemples d'inspection

```powershell
# Lister toutes les commandes exportées par un module
(Get-Module -Name "Microsoft.PowerShell.Utility").ExportedCommands

# Afficher uniquement le chemin d'installation
(Get-Module -ListAvailable -Name "PSReadLine").Path

# Compter le nombre de cmdlets dans un module
(Get-Module -Name "Microsoft.PowerShell.Management").ExportedCommands.Count

# Filtrer les modules par auteur
Get-Module -ListAvailable | Where-Object { $_.Author -like "*Microsoft*" }
```

### 💡 Cas d'usage pratiques

```powershell
# Vérifier si un module est chargé
if (Get-Module -Name "ActiveDirectory") {
    Write-Host "Module Active Directory est chargé"
} else {
    Write-Host "Module non chargé"
}

# Trouver la version d'un module chargé
$version = (Get-Module -Name "PSReadLine").Version
Write-Host "Version de PSReadLine : $version"

# Lister tous les modules importés automatiquement
Get-Module | Where-Object { $_.ModuleType -eq "Manifest" }

# Afficher les modules avec leurs chemins
Get-Module -ListAvailable | Select-Object Name, Version, Path | Format-Table -AutoSize
```

> [!example] Exemple : Audit des modules
> 
> ```powershell
> # Créer un rapport des modules disponibles
> Get-Module -ListAvailable | 
>     Select-Object Name, Version, Author, Description |
>     Export-Csv -Path "C:\Temp\ModulesInventory.csv" -NoTypeInformation
> ```

---

## 📥 Import-Module - Charger les modules

La cmdlet `Import-Module` permet de **charger un module en mémoire** pour rendre ses commandes disponibles dans la session active.

### Syntaxe de base

```powershell
Import-Module [-Name] <String[]> [-Force] [-Global] [-Prefix <String>] 
              [-RequiredVersion <Version>] [-MinimumVersion <Version>]
```

### 📌 Utilisation principale

#### Import simple

```powershell
# Importer un module par son nom
Import-Module -Name "ActiveDirectory"

# Importer plusieurs modules à la fois
Import-Module -Name "PSReadLine", "PowerShellGet"

# Import implicite (fonctionne également)
Import-Module ActiveDirectory
```

> [!info] Auto-import PowerShell charge automatiquement les modules lors de la première utilisation d'une commande. Cependant, l'import explicite est recommandé pour :
> 
> - **Performances** : Éviter le délai au premier appel
> - **Contrôle** : Spécifier une version précise
> - **Scripts** : Garantir la disponibilité des commandes
> - **Compatibilité** : Support de PowerShell 2.0

#### Importer depuis un chemin spécifique

```powershell
# Importer un module depuis un fichier .psd1 ou .psm1
Import-Module -Name "C:\MonModule\MonModule.psd1"

# Importer depuis un répertoire
Import-Module -Name "C:\MesModules\MonModule"
```

### 🎛️ Paramètres essentiels

#### `-Force` : Forcer le rechargement

```powershell
# Recharger un module déjà importé (utile après modification)
Import-Module -Name "MonModule" -Force
```

> [!tip] Quand utiliser `-Force` ?
> 
> - Après avoir modifié le code d'un module en développement
> - Pour recharger une nouvelle version d'un module
> - Pour résoudre des problèmes de cache
> - Lorsque vous obtenez une erreur "module déjà chargé"

#### `-Prefix` : Ajouter un préfixe aux commandes

```powershell
# Importer avec un préfixe pour éviter les conflits de noms
Import-Module -Name "ActiveDirectory" -Prefix "AD"

# Les commandes deviennent : Get-ADUser devient Get-ADUser (pas de changement)
# Mais si vous importez un module personnalisé :
Import-Module -Name "MonModule" -Prefix "Custom"
# Get-User devient Get-CustomUser
```

> [!example] Cas d'usage du préfixe
> 
> ```powershell
> # Importer deux modules avec des commandes similaires
> Import-Module -Name "ModuleA" -Prefix "A"
> Import-Module -Name "ModuleB" -Prefix "B"
> 
> # Maintenant vous pouvez utiliser :
> Get-AUser   # Du ModuleA
> Get-BUser   # Du ModuleB
> ```

#### `-RequiredVersion` : Spécifier une version exacte

```powershell
# Charger une version spécifique d'un module
Import-Module -Name "PowerShellGet" -RequiredVersion "2.2.5"

# Utile pour la compatibilité avec des scripts existants
Import-Module -Name "Az.Accounts" -RequiredVersion "2.10.0"
```

> [!warning] Gestion des versions Si la version spécifiée n'est pas installée, vous obtiendrez une erreur. Vérifiez d'abord avec `Get-Module -ListAvailable -All`.

#### `-MinimumVersion` : Version minimale requise

```powershell
# Importer la version la plus récente >= 2.0
Import-Module -Name "PowerShellGet" -MinimumVersion "2.0"
```

#### `-MaximumVersion` : Version maximale acceptée

```powershell
# Importer une version <= 3.0 (exclut 3.1, 4.0, etc.)
Import-Module -Name "PowerShellGet" -MaximumVersion "3.0"
```

#### `-Global` : Portée globale

```powershell
# Importer dans la portée globale (disponible partout)
Import-Module -Name "MonModule" -Global

# Sans -Global, le module est limité à la portée actuelle
```

> [!info] Différence de portée
> 
> - **Sans `-Global`** : Module disponible uniquement dans la portée actuelle (script, fonction)
> - **Avec `-Global`** : Module disponible dans toute la session, y compris les fonctions et scripts enfants

### 💡 Cas d'usage pratiques

#### Import conditionnel dans un script

```powershell
# Vérifier et importer si nécessaire
if (-not (Get-Module -Name "ActiveDirectory")) {
    try {
        Import-Module -Name "ActiveDirectory" -ErrorAction Stop
        Write-Host "Module Active Directory chargé avec succès"
    }
    catch {
        Write-Error "Impossible de charger le module : $_"
        exit 1
    }
}
```

#### Import avec gestion d'erreurs

```powershell
# Tenter d'importer avec fallback
try {
    Import-Module -Name "Az.Accounts" -MinimumVersion "2.0" -ErrorAction Stop
}
catch {
    Write-Warning "Version récente non trouvée, import de la version disponible"
    Import-Module -Name "Az.Accounts"
}
```

#### Import multiple avec vérification

```powershell
# Liste de modules requis
$requiredModules = @("PSReadLine", "PowerShellGet", "PackageManagement")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Error "Module $module n'est pas installé"
    }
    else {
        Import-Module -Name $module -Force
        Write-Host "✓ $module importé"
    }
}
```

### 🔧 Configuration de l'auto-import

```powershell
# Vérifier si l'auto-import est activé (par défaut = True)
$PSModuleAutoLoadingPreference

# Désactiver l'auto-import
$PSModuleAutoLoadingPreference = 'None'

# Réactiver l'auto-import
$PSModuleAutoLoadingPreference = 'All'

# Import automatique uniquement pour les modules manifestes
$PSModuleAutoLoadingPreference = 'ModuleQualified'
```

> [!warning] Impact de la désactivation Si vous désactivez l'auto-import avec `$PSModuleAutoLoadingPreference = 'None'`, vous devrez importer manuellement tous les modules avec `Import-Module`.

---

## 📂 Chemins de modules

PowerShell recherche les modules dans des emplacements définis par la variable d'environnement `$env:PSModulePath`.

### 🗺️ Emplacements standard

```powershell
# Afficher tous les chemins de modules
$env:PSModulePath -split ';'

# Résultat typique sous Windows :
# C:\Users\VotreNom\Documents\PowerShell\Modules      (utilisateur)
# C:\Program Files\PowerShell\Modules                 (tous les utilisateurs)
# C:\Windows\System32\WindowsPowerShell\v1.0\Modules  (système)
```

|Emplacement|Description|Portée|
|---|---|---|
|`$HOME\Documents\PowerShell\Modules`|Modules de l'utilisateur actuel|Utilisateur|
|`C:\Program Files\PowerShell\Modules`|Modules partagés (PS 7+)|Tous les utilisateurs|
|`C:\Program Files\WindowsPowerShell\Modules`|Modules partagés (PS 5.1)|Tous les utilisateurs|
|`C:\Windows\System32\WindowsPowerShell\v1.0\Modules`|Modules système|Système|

> [!info] PowerShell 7 vs Windows PowerShell
> 
> - **PowerShell 7+** : Utilise `PowerShell\Modules`
> - **Windows PowerShell 5.1** : Utilise `WindowsPowerShell\Modules`
> - Les deux peuvent coexister sur le même système

### 🔧 Gérer les chemins de modules

#### Ajouter un chemin personnalisé (session actuelle)

```powershell
# Ajouter temporairement un nouveau chemin
$env:PSModulePath += ";C:\MesModulesPerso"

# Vérifier l'ajout
$env:PSModulePath -split ';'
```

#### Ajouter un chemin de manière permanente

```powershell
# Méthode 1 : Via le profil PowerShell
# Éditer le profil
notepad $PROFILE

# Ajouter cette ligne dans le profil :
$env:PSModulePath += ";C:\MesModulesPerso"

# Méthode 2 : Via les variables d'environnement système (Windows)
# Ouvrir : Système > Paramètres système avancés > Variables d'environnement
# Modifier la variable PSModulePath
```

> [!tip] Bonnes pratiques pour les chemins
> 
> - Utilisez le chemin utilisateur (`$HOME\Documents\PowerShell\Modules`) pour vos modules personnels
> - Utilisez `C:\Program Files\PowerShell\Modules` pour les modules partagés
> - Évitez de modifier les chemins système sauf si nécessaire

#### Retrouver l'emplacement d'un module

```powershell
# Afficher le chemin complet d'un module
(Get-Module -ListAvailable -Name "PSReadLine").Path

# Afficher le répertoire du module
Split-Path (Get-Module -ListAvailable -Name "PSReadLine").Path

# Ouvrir le dossier du module dans l'explorateur
explorer (Split-Path (Get-Module -ListAvailable -Name "PSReadLine").Path)
```

### 📁 Structure d'un module

Un module PowerShell suit généralement cette structure :

```
MonModule/
├── MonModule.psd1      # Manifest du module (métadonnées)
├── MonModule.psm1      # Fichier de script principal
├── Public/             # Fonctions exportées (optionnel)
│   ├── Get-Something.ps1
│   └── Set-Something.ps1
├── Private/            # Fonctions internes (optionnel)
│   └── Internal-Function.ps1
├── en-US/              # Fichiers d'aide (optionnel)
│   └── about_MonModule.help.txt
└── Tests/              # Tests Pester (optionnel)
    └── MonModule.Tests.ps1
```

> [!example] Exemple de contenu minimal **MonModule.psd1** (manifest) :
> 
> ```powershell
> @{
>     ModuleVersion = '1.0.0'
>     RootModule = 'MonModule.psm1'
>     Author = 'Votre Nom'
>     Description = 'Description du module'
>     FunctionsToExport = @('Get-Something', 'Set-Something')
> }
> ```
> 
> **MonModule.psm1** (script) :
> 
> ```powershell
> function Get-Something {
>     Write-Output "Voici quelque chose"
> }
> 
> function Set-Something {
>     param($Value)
>     Write-Output "Défini à : $Value"
> }
> 
> Export-ModuleMember -Function Get-Something, Set-Something
> ```

---

## 🗑️ Remove-Module - Décharger les modules

La cmdlet `Remove-Module` permet de **décharger un module de la session active** pour libérer de la mémoire ou résoudre des conflits.

### Syntaxe de base

```powershell
Remove-Module [-Name] <String[]> [-Force]
```

### 📌 Utilisation principale

```powershell
# Décharger un module spécifique
Remove-Module -Name "ActiveDirectory"

# Décharger plusieurs modules
Remove-Module -Name "PSReadLine", "PowerShellGet"

# Décharger tous les modules (rarement recommandé)
Get-Module | Remove-Module
```

### 🎛️ Paramètres

#### `-Force` : Forcer le déchargement

```powershell
# Forcer le retrait même si le module est utilisé
Remove-Module -Name "MonModule" -Force
```

> [!warning] Attention avec `-Force` Décharger un module avec `-Force` peut causer des erreurs si des commandes de ce module sont encore utilisées dans des scripts en cours d'exécution.

### 💡 Cas d'usage pratiques

#### Recharger un module après modification

```powershell
# Pattern de développement : Retirer puis réimporter
Remove-Module -Name "MonModule" -Force
Import-Module -Name "MonModule" -Force

# Version raccourcie
Import-Module -Name "MonModule" -Force  # Fait les deux automatiquement
```

#### Résoudre les conflits de commandes

```powershell
# Si deux modules exportent la même commande
Remove-Module -Name "ModuleConflictuel"
Import-Module -Name "ModulePréféré"
```

#### Libérer de la mémoire

```powershell
# Décharger les modules non utilisés
$modulesASupprimer = @("Module1", "Module2", "Module3")
foreach ($module in $modulesASupprimer) {
    if (Get-Module -Name $module) {
        Remove-Module -Name $module
        Write-Host "✓ $module déchargé"
    }
}
```

#### Nettoyer la session avant un test

```powershell
# Script de test : S'assurer d'un environnement propre
Get-Module | Where-Object { $_.Name -notlike "Microsoft.PowerShell.*" } | Remove-Module -Force
Write-Host "Session nettoyée, prête pour les tests"
```

### 🔄 Comparaison : Remove vs Import -Force

|Action|`Remove-Module` puis `Import-Module`|`Import-Module -Force`|
|---|---|---|
|Étapes|2 commandes distinctes|1 seule commande|
|Contrôle|Plus granulaire|Automatique|
|Usage|Débogage, nettoyage|Rechargement rapide|

```powershell
# Méthode 1 : Explicite
Remove-Module -Name "MonModule"
Import-Module -Name "MonModule"

# Méthode 2 : Raccourcie (fait la même chose)
Import-Module -Name "MonModule" -Force
```

---

## ✅ Bonnes pratiques

### 📋 Dans les scripts de production

```powershell
# ✓ BON : Import explicite avec gestion d'erreurs
try {
    Import-Module -Name "ActiveDirectory" -ErrorAction Stop
    Import-Module -Name "ExchangeOnlineManagement" -MinimumVersion "3.0" -ErrorAction Stop
}
catch {
    Write-Error "Modules requis non disponibles : $_"
    exit 1
}

# ✗ MAUVAIS : Compter sur l'auto-import
Get-ADUser -Filter *  # Peut échouer si module non disponible
```

### 🔍 Vérification avant utilisation

```powershell
# ✓ BON : Vérifier puis importer
$requiredModules = @("Module1", "Module2")
$missingModules = @()

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        $missingModules += $module
    }
}

if ($missingModules.Count -gt 0) {
    Write-Error "Modules manquants : $($missingModules -join ', ')"
    exit 1
}

# ✗ MAUVAIS : Import sans vérification
Import-Module -Name "ModulePeutEtreAbsent"  # Risque d'erreur
```

### 🏎️ Optimisation des performances

```powershell
# ✓ BON : Importer uniquement les modules nécessaires au début
Import-Module -Name "ActiveDirectory"
# ... script qui utilise AD ...

# ✗ MAUVAIS : Importer dans une boucle
foreach ($user in $users) {
    Import-Module -Name "ActiveDirectory"  # ❌ Très inefficace !
    Get-ADUser $user
}
```

### 🔐 Sécurité et versions

```powershell
# ✓ BON : Spécifier les versions dans les environnements critiques
Import-Module -Name "Az.Accounts" -RequiredVersion "2.10.0"
Import-Module -Name "ExchangeOnlineManagement" -MinimumVersion "3.0"

# ✗ RISQUÉ : Version automatique en production
Import-Module -Name "Az.Accounts"  # Peut charger n'importe quelle version
```

### 🧹 Nettoyage et gestion de la mémoire

```powershell
# ✓ BON : Décharger les modules volumineux non utilisés
try {
    Import-Module -Name "ActiveDirectory"
    # ... traitement ...
}
finally {
    Remove-Module -Name "ActiveDirectory"  # Libère la mémoire
}

# ✓ BON : Dans les scripts longs avec plusieurs phases
Import-Module -Name "PhaseModule1"
# ... phase 1 ...
Remove-Module -Name "PhaseModule1"

Import-Module -Name "PhaseModule2"
# ... phase 2 ...
Remove-Module -Name "PhaseModule2"
```

### 📦 Organisation des modules personnalisés

```powershell
# ✓ BON : Structure claire
$modulePath = "$HOME\Documents\PowerShell\Modules\MonEntreprise"
New-Item -Path $modulePath -ItemType Directory -Force

# Créer un manifest propre
New-ModuleManifest -Path "$modulePath\MonEntreprise.psd1" `
    -ModuleVersion "1.0.0" `
    -Author "Votre Nom" `
    -Description "Outils de l'entreprise" `
    -FunctionsToExport @('Get-CompanyData', 'Set-CompanyConfig')
```

### ⚠️ Pièges à éviter

> [!warning] Conflits de noms
> 
> ```powershell
> # Problème : Deux modules avec des commandes identiques
> Import-Module -Name "ModuleA"  # Contient Get-User
> Import-Module -Name "ModuleB"  # Contient aussi Get-User
> Get-User  # Laquelle s'exécute ? Celle du dernier module importé
> 
> # Solution : Utiliser des préfixes
> Import-Module -Name "ModuleA" -Prefix "A"
> Import-Module -Name "ModuleB" -Prefix "B"
> Get-AUser  # Clairement du ModuleA
> Get-BUser  # Clairement du ModuleB
> ```

> [!warning] Versions multiples
> 
> ```powershell
> # Vérifier les versions multiples
> Get-Module -ListAvailable -Name "PowerShellGet" -All
> 
> # Si vous voyez plusieurs versions, nettoyez :
> # 1. Désinstaller les anciennes versions
> Uninstall-Module -Name "PowerShellGet" -RequiredVersion "2.0.0"
> 
> # 2. Garder uniquement la plus récente
> ```

### 📝 Documentation dans les scripts

```powershell
<#
.SYNOPSIS
    Script de gestion des utilisateurs AD
.DESCRIPTION
    Ce script nécessite le module ActiveDirectory version 1.0+
.NOTES
    Modules requis :
    - ActiveDirectory (>= 1.0.0)
    - ImportExcel (>= 7.0.0)
#>

#Requires -Modules @{ ModuleName="ActiveDirectory"; ModuleVersion="1.0.0" }

Import-Module -Name "ActiveDirectory" -ErrorAction Stop
Import-Module -Name "ImportExcel" -MinimumVersion "7.0" -ErrorAction Stop
```

---