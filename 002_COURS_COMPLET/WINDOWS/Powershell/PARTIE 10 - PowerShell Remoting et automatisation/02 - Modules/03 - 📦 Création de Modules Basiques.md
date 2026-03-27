

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

## 🎯 Introduction aux modules

Les modules PowerShell sont des packages réutilisables qui regroupent des fonctions, cmdlets, variables et alias. Ils permettent d'organiser et de partager du code de manière structurée et maintenable.

> [!info] Pourquoi créer des modules ?
> 
> - **Réutilisabilité** : Partager du code entre projets et équipes
> - **Organisation** : Structurer logiquement vos fonctions
> - **Distribution** : Déployer facilement sur plusieurs machines
> - **Maintenance** : Gérer les versions et mises à jour
> - **Isolation** : Éviter les conflits de nommage

---

## 🏗️ Structure d'un module

### Architecture de base

Un module PowerShell suit une structure de dossiers standardisée :

```
MonModule/
├── MonModule.psm1           # Fichier module script (obligatoire)
├── MonModule.psd1           # Manifeste (optionnel mais recommandé)
├── Public/                  # Fonctions exportées (optionnel)
│   ├── Get-Data.ps1
│   └── Set-Data.ps1
├── Private/                 # Fonctions internes (optionnel)
│   └── Internal-Helper.ps1
├── Resources/               # Ressources additionnelles (optionnel)
│   ├── Config.json
│   └── Templates/
└── Tests/                   # Tests Pester (optionnel)
    └── MonModule.Tests.ps1
```

> [!warning] Convention de nommage Le nom du dossier, du fichier .psm1 et du fichier .psd1 doivent être **identiques** pour que PowerShell charge automatiquement le module.

### Emplacement des modules

PowerShell recherche les modules dans les chemins définis par `$env:PSModulePath` :

```powershell
# Afficher les chemins de recherche
$env:PSModulePath -split ';'

# Chemins par défaut :
# C:\Users\<User>\Documents\PowerShell\Modules     # Utilisateur courant
# C:\Program Files\PowerShell\Modules              # Tous les utilisateurs
# C:\Windows\System32\WindowsPowerShell\v1.0\Modules  # Modules système
```

> [!tip] Astuce de développement Pendant le développement, placez votre module dans `$HOME\Documents\PowerShell\Modules` pour un accès rapide sans droits administrateur.

---

## 📄 Module script (.psm1)

Le fichier `.psm1` est le cœur du module. Il contient le code PowerShell exécutable : fonctions, alias, variables.

### Structure basique

```powershell
# MonModule.psm1

# Variables du module
$script:ModuleRoot = $PSScriptRoot
$script:ConfigPath = Join-Path $ModuleRoot "config.json"

# Fonction publique
function Get-UserInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Username
    )
    
    Write-Verbose "Recherche de l'utilisateur : $Username"
    # Logique de la fonction...
}

# Fonction privée (helper)
function Internal-ValidateUser {
    param([string]$User)
    # Logique interne...
}

# Export explicite des fonctions publiques
Export-ModuleMember -Function Get-UserInfo
```

### Export des membres

Par défaut, **toutes les fonctions** sont exportées. Pour contrôler ce qui est visible :

```powershell
# Exporter uniquement des fonctions spécifiques
Export-ModuleMember -Function Get-UserInfo, Set-UserInfo

# Exporter des fonctions et des alias
Export-ModuleMember -Function Get-Data -Alias gd

# Exporter des variables
Export-ModuleMember -Variable ModuleVersion

# Ne rien exporter explicitement (tout est exporté par défaut)
# Si Export-ModuleMember n'est pas appelé
```

> [!warning] Comportement par défaut Si vous n'utilisez **aucun** `Export-ModuleMember`, toutes les fonctions sont exportées automatiquement. Dès que vous utilisez un seul `Export-ModuleMember`, seuls les éléments explicitement exportés seront disponibles.

### Variables de portée

```powershell
# Variable privée au module (non accessible de l'extérieur)
$script:InternalCounter = 0

# Variable exportée (accessible après import)
$PublicSetting = "Valeur"
Export-ModuleMember -Variable PublicSetting

# Variable accessible uniquement dans la fonction
function Test {
    $local:TempValue = 10
}
```

|Portée|Mot-clé|Visibilité|
|---|---|---|
|Module|`$script:`|Toutes les fonctions du module|
|Fonction|`$local:` ou rien|Fonction courante uniquement|
|Globale|`$global:`|Toute la session (⚠️ à éviter)|

---

## 📋 Manifeste de module (.psd1)

Le manifeste est un fichier de métadonnées qui décrit votre module. Bien qu'optionnel, il est **fortement recommandé** pour les modules professionnels.

### Création d'un manifeste

```powershell
# Créer un nouveau manifeste
New-ModuleManifest -Path .\MonModule.psd1 `
    -RootModule 'MonModule.psm1' `
    -ModuleVersion '1.0.0' `
    -Author 'Votre Nom' `
    -CompanyName 'Votre Entreprise' `
    -Description 'Description de votre module' `
    -PowerShellVersion '5.1' `
    -FunctionsToExport @('Get-UserInfo', 'Set-UserInfo') `
    -CmdletsToExport @() `
    -VariablesToExport @() `
    -AliasesToExport @('gui')
```

### Anatomie complète d'un manifeste

```powershell
@{
    # Identification du module
    RootModule = 'MonModule.psm1'
    ModuleVersion = '1.2.3'
    GUID = 'a1b2c3d4-e5f6-7890-ab12-cd34ef567890'  # Identifiant unique
    
    # Informations sur l'auteur
    Author = 'Jean Dupont'
    CompanyName = 'MonEntreprise'
    Copyright = '(c) 2025 MonEntreprise. Tous droits réservés.'
    
    # Description
    Description = 'Module pour la gestion des utilisateurs Active Directory'
    
    # Version minimum de PowerShell requise
    PowerShellVersion = '5.1'
    
    # Modules requis (dépendances)
    RequiredModules = @(
        @{ModuleName='ActiveDirectory'; ModuleVersion='1.0.0.0'}
    )
    
    # Assemblies .NET requis
    RequiredAssemblies = @('System.DirectoryServices.dll')
    
    # Scripts à exécuter avant l'import du module
    ScriptsToProcess = @('Init-Environment.ps1')
    
    # Fonctions à exporter (wildcards acceptés)
    FunctionsToExport = @('Get-*', 'Set-*', 'New-*', 'Remove-*')
    
    # Cmdlets à exporter (pour modules binaires)
    CmdletsToExport = @()
    
    # Variables à exporter
    VariablesToExport = @('ModuleConfig')
    
    # Alias à exporter
    AliasesToExport = @('gui', 'sui')
    
    # Métadonnées supplémentaires pour PowerShell Gallery
    PrivateData = @{
        PSData = @{
            Tags = @('ActiveDirectory', 'Users', 'Management')
            LicenseUri = 'https://github.com/user/repo/LICENSE'
            ProjectUri = 'https://github.com/user/repo'
            IconUri = 'https://github.com/user/repo/icon.png'
            ReleaseNotes = 'Version 1.2.3: Ajout de la fonction Get-UserDetail'
        }
    }
}
```

### Propriétés importantes

> [!info] ModuleVersion Utilisez le **versioning sémantique** : `MAJOR.MINOR.PATCH`
> 
> - **MAJOR** : Changements incompatibles avec les versions précédentes
> - **MINOR** : Ajout de fonctionnalités rétrocompatibles
> - **PATCH** : Corrections de bugs

> [!example] Exemple de versioning
> 
> - `1.0.0` : Version initiale
> - `1.1.0` : Ajout d'une nouvelle fonction
> - `1.1.1` : Correction d'un bug
> - `2.0.0` : Modification du nom d'un paramètre (breaking change)

### Exports avec wildcards

```powershell
# Exporter toutes les fonctions commençant par Get-, Set-, New-, Remove-
FunctionsToExport = @('Get-*', 'Set-*', 'New-*', 'Remove-*')

# Exporter toutes les fonctions
FunctionsToExport = '*'

# N'exporter aucune fonction
FunctionsToExport = @()
```

> [!warning] Performance Spécifier explicitement les exports améliore les performances de chargement du module. Évitez `'*'` en production.

### Dépendances

```powershell
# Dépendance simple
RequiredModules = @('ActiveDirectory')

# Dépendances avec versions spécifiques
RequiredModules = @(
    @{ModuleName='ActiveDirectory'; ModuleVersion='1.0.0.0'},
    @{ModuleName='PnP.PowerShell'; RequiredVersion='1.12.0'}
)

# Modules imbriqués (chargés automatiquement)
NestedModules = @('Helper.psm1', 'Utilities.psm1')
```

---

## 🗂️ Organisation avancée

### Séparation Public/Private

Une organisation professionnelle sépare les fonctions publiques (API) des fonctions internes :

```
MonModule/
├── MonModule.psm1
├── MonModule.psd1
├── Public/
│   ├── Get-ADUserReport.ps1
│   ├── Set-ADUserProperty.ps1
│   └── New-ADUserBulk.ps1
└── Private/
    ├── Connect-DomainController.ps1
    ├── Test-ADUserExists.ps1
    └── Format-ADUserOutput.ps1
```

### Dot-sourcing automatique

Le fichier `.psm1` charge automatiquement tous les fichiers :

```powershell
# MonModule.psm1

# Charger toutes les fonctions privées
$PrivateFunctions = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Charger toutes les fonctions publiques
$PublicFunctions = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)

# Dot-sourcer tous les fichiers
foreach ($Function in @($PublicFunctions + $PrivateFunctions)) {
    try {
        . $Function.FullName
    }
    catch {
        Write-Error "Erreur lors du chargement de $($Function.FullName): $_"
    }
}

# Exporter uniquement les fonctions publiques
Export-ModuleMember -Function $PublicFunctions.BaseName
```

> [!tip] Avantages de cette organisation
> 
> - **Clarté** : Séparation nette entre API publique et code interne
> - **Maintenance** : Fichiers plus petits et ciblés
> - **Tests** : Facilite l'écriture de tests unitaires
> - **Collaboration** : Plusieurs développeurs peuvent travailler en parallèle

### Fichier de fonctions individuelles

```powershell
# Public/Get-ADUserReport.ps1

function Get-ADUserReport {
    <#
    .SYNOPSIS
        Génère un rapport des utilisateurs Active Directory
    
    .DESCRIPTION
        Cette fonction récupère les utilisateurs AD et génère un rapport
        formaté avec les informations principales
    
    .PARAMETER Department
        Filtrer par département
    
    .EXAMPLE
        Get-ADUserReport -Department "IT"
        Génère un rapport pour le département IT
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Department
    )
    
    # Implémentation...
}
```

### Ressources additionnelles

```powershell
# Charger un fichier de configuration JSON
$ConfigPath = Join-Path $PSScriptRoot "Resources\config.json"
$script:Config = Get-Content $ConfigPath | ConvertFrom-Json

# Utiliser dans une fonction
function Get-ModuleConfig {
    return $script:Config
}
```

---

## ✅ Bonnes pratiques

### 1. Nommage cohérent

```powershell
# ✅ BON : Verbe-Nom avec préfixe de module
function Get-ADUserReport { }
function Set-ADUserProperty { }
function New-ADUserBulk { }

# ❌ MAUVAIS : Nommage incohérent
function GetUsers { }
function SetUserProp { }
function CreateUsers { }
```

> [!info] Verbes approuvés Utilisez `Get-Verb` pour voir la liste des verbes approuvés par PowerShell. Principaux : `Get`, `Set`, `New`, `Remove`, `Add`, `Update`, `Test`, `Start`, `Stop`, `Enable`, `Disable`

### 2. Comment-Based Help

Documentez **toutes** vos fonctions publiques :

```powershell
function Get-ADUserReport {
    <#
    .SYNOPSIS
        Génère un rapport des utilisateurs Active Directory
    
    .DESCRIPTION
        Cette fonction récupère les utilisateurs Active Directory
        selon des critères spécifiques et génère un rapport détaillé
        aux formats CSV, HTML ou JSON.
    
    .PARAMETER Department
        Département pour filtrer les utilisateurs
    
    .PARAMETER OutputFormat
        Format de sortie : CSV, HTML ou JSON
        Par défaut : CSV
    
    .PARAMETER Path
        Chemin de sauvegarde du rapport
        Si non spécifié, affiche à l'écran
    
    .EXAMPLE
        Get-ADUserReport -Department "IT"
        
        Génère un rapport CSV des utilisateurs du département IT
    
    .EXAMPLE
        Get-ADUserReport -Department "Finance" -OutputFormat HTML -Path "C:\Reports\finance.html"
        
        Génère un rapport HTML et le sauvegarde dans le fichier spécifié
    
    .NOTES
        Author: Jean Dupont
        Version: 1.2.0
        Date: 2025-01-15
    
    .LINK
        https://github.com/user/repo/wiki/Get-ADUserReport
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Department,
        
        [ValidateSet('CSV', 'HTML', 'JSON')]
        [string]$OutputFormat = 'CSV',
        
        [string]$Path
    )
    
    # Implémentation...
}
```

### 3. Versioning sémantique

Gérez les versions de votre module de manière cohérente :

```powershell
# Fichier ChangeLog.md
# MonModule ChangeLog

## [2.0.0] - 2025-01-15
### Breaking Changes
- Renommage du paramètre -Filter en -SearchFilter
- Suppression de la fonction obsolète Get-OldData

### Added
- Nouvelle fonction Get-ADUserDetail
- Support du pipeline pour Set-ADUserProperty

### Fixed
- Correction du bug #42 : erreur sur les caractères spéciaux

## [1.5.1] - 2024-12-10
### Fixed
- Correction de la validation des paramètres
```

### 4. Gestion des erreurs

```powershell
function Get-ADUserReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Department
    )
    
    try {
        # Validation
        if (-not (Test-ADDepartment -Name $Department)) {
            throw "Le département '$Department' n'existe pas"
        }
        
        # Logique principale
        $Users = Get-ADUser -Filter "Department -eq '$Department'" -ErrorAction Stop
        
        if ($Users.Count -eq 0) {
            Write-Warning "Aucun utilisateur trouvé dans le département '$Department'"
            return
        }
        
        # Traitement...
        return $Report
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Error "Erreur Active Directory : $_"
    }
    catch {
        Write-Error "Erreur inattendue : $_"
        throw
    }
}
```

### 5. Tests avec Pester

Créez des tests pour vos fonctions :

```powershell
# Tests/MonModule.Tests.ps1

Describe "Get-ADUserReport" {
    BeforeAll {
        Import-Module .\MonModule.psm1 -Force
    }
    
    Context "Paramètres" {
        It "Doit accepter un département valide" {
            { Get-ADUserReport -Department "IT" } | Should -Not -Throw
        }
        
        It "Doit rejeter un département vide" {
            { Get-ADUserReport -Department "" } | Should -Throw
        }
    }
    
    Context "Résultats" {
        It "Doit retourner des objets avec les propriétés attendues" {
            $Result = Get-ADUserReport -Department "IT"
            $Result[0].PSObject.Properties.Name | Should -Contain "Name"
            $Result[0].PSObject.Properties.Name | Should -Contain "Email"
        }
    }
}
```

### 6. Performances

```powershell
# ❌ LENT : Appels multiples
foreach ($User in $Users) {
    Get-ADUser -Identity $User
}

# ✅ RAPIDE : Requête unique
Get-ADUser -Filter "Department -eq 'IT'"

# ✅ RAPIDE : Pipeline
$Users | Get-ADUser
```

> [!warning] Pièges courants
> 
> - Ne pas utiliser `Get-ADUser` dans une boucle
> - Éviter les appels répétés à des services externes
> - Privilégier les filtres côté serveur
> - Utiliser `-Filter` plutôt que `Where-Object` pour filtrer après coup

---

## 📦 Distribution et déploiement

### Installation locale

```powershell
# Copier manuellement dans un chemin PSModulePath
Copy-Item -Path .\MonModule -Destination "$HOME\Documents\PowerShell\Modules\" -Recurse

# Vérifier l'installation
Get-Module -ListAvailable MonModule

# Importer le module
Import-Module MonModule
```

### Repository interne

Configurez un repository privé pour votre organisation :

```powershell
# Enregistrer un repository interne (une seule fois)
Register-PSRepository -Name "CompanyRepo" `
    -SourceLocation "\\serveur\share\PSRepository" `
    -PublishLocation "\\serveur\share\PSRepository" `
    -InstallationPolicy Trusted

# Publier le module
Publish-Module -Name MonModule `
    -Repository CompanyRepo `
    -NuGetApiKey "VotreCléAPI"

# Installer depuis le repository
Install-Module -Name MonModule -Repository CompanyRepo
```

### PowerShell Gallery (public)

Pour partager publiquement votre module :

```powershell
# 1. Créer un compte sur PowerShellGallery.com et obtenir une clé API

# 2. Publier le module
Publish-Module -Name MonModule `
    -NuGetApiKey "VotreCléAPIGallery" `
    -Verbose

# 3. Les utilisateurs peuvent maintenant l'installer
Install-Module -Name MonModule -Scope CurrentUser
```

> [!warning] Avant de publier
> 
> - Testez votre module sur plusieurs environnements
> - Vérifiez que toutes les dépendances sont documentées
> - Assurez-vous que le manifeste est complet
> - Ajoutez une licence claire (MIT, Apache, etc.)
> - Documentez l'installation et l'utilisation dans un README

### Mise à jour de modules

```powershell
# Vérifier les mises à jour disponibles
Find-Module -Name MonModule -Repository CompanyRepo

# Mettre à jour vers la dernière version
Update-Module -Name MonModule

# Installer une version spécifique
Install-Module -Name MonModule -RequiredVersion 1.2.3
```

### Scripts d'installation automatisés

```powershell
# Install-MonModule.ps1

[CmdletBinding()]
param(
    [switch]$AllUsers
)

$ModuleName = "MonModule"
$SourcePath = "\\serveur\share\Modules\$ModuleName"

# Déterminer le chemin d'installation
if ($AllUsers) {
    $DestPath = "C:\Program Files\PowerShell\Modules\$ModuleName"
    # Nécessite des droits admin
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Installation pour tous les utilisateurs nécessite des droits administrateur"
    }
} else {
    $DestPath = "$HOME\Documents\PowerShell\Modules\$ModuleName"
}

# Créer le dossier si nécessaire
New-Item -Path $DestPath -ItemType Directory -Force | Out-Null

# Copier le module
Copy-Item -Path "$SourcePath\*" -Destination $DestPath -Recurse -Force

# Vérifier l'installation
if (Get-Module -ListAvailable -Name $ModuleName) {
    Write-Host "Module $ModuleName installé avec succès !" -ForegroundColor Green
} else {
    Write-Error "Échec de l'installation du module"
}
```

---

## 🎓 Récapitulatif

### Checklist de création d'un module

- [ ] Structure de dossiers créée (avec nom cohérent)
- [ ] Fichier `.psm1` avec fonctions et exports
- [ ] Fichier `.psd1` avec métadonnées complètes
- [ ] Organisation Public/Private pour les fonctions
- [ ] Comment-Based Help sur toutes les fonctions publiques
- [ ] Tests Pester écrits et validés
- [ ] Versioning sémantique appliqué
- [ ] ChangeLog maintenu à jour
- [ ] README avec instructions d'installation
- [ ] Module testé sur l'environnement cible

### Flux de travail type

1. **Développement** : Créer les fonctions dans Public/Private
2. **Documentation** : Ajouter l'aide et les exemples
3. **Test** : Écrire et exécuter les tests Pester
4. **Version** : Mettre à jour le numéro de version
5. **Publication** : Déployer sur le repository
6. **Maintenance** : Gérer les bugs et les évolutions

> [!tip] Pour aller plus loin Une fois à l'aise avec les modules basiques, explorez :
> 
> - Les modules binaires (C#)
> - Les classes PowerShell dans les modules
> - L'intégration continue (CI/CD) pour modules
> - La signature de code pour la sécurité