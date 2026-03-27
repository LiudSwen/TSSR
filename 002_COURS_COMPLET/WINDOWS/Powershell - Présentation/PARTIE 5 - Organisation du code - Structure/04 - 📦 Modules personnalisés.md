

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

## 🎯 Introduction aux modules

Les modules PowerShell sont des packages réutilisables qui encapsulent des fonctions, cmdlets, variables et alias. Ils permettent d'organiser, partager et distribuer du code de manière professionnelle.

> [!info] Pourquoi créer des modules personnalisés ?
> 
> - **Réutilisabilité** : Écrire une fois, utiliser partout
> - **Organisation** : Regrouper des fonctions par thème/domaine
> - **Distribution** : Faciliter le partage avec d'autres utilisateurs
> - **Maintenance** : Versioning et mises à jour centralisées
> - **Encapsulation** : Contrôler ce qui est exposé publiquement

### Types de modules

|Type|Extension|Description|
|---|---|---|
|**Script Module**|`.psm1`|Module écrit en PowerShell (le plus courant)|
|**Binary Module**|`.dll`|Module compilé en C#|
|**Manifest Module**|`.psd1`|Module défini par un manifeste|
|**Dynamic Module**|N/A|Module créé en mémoire avec `New-Module`|

> [!tip] Recommandation Pour la plupart des besoins, un **Script Module** (.psm1) avec un **Manifest** (.psd1) est le choix idéal.

---

## 📄 Structure d'un module (.psm1)

Le fichier `.psm1` est le cœur de votre module. Il contient le code PowerShell qui sera chargé lors de l'import.

### Structure de base

```powershell
# MonModule.psm1
# Description du module et informations de l'auteur

#region Variables privées
$Script:ConfigPath = "$PSScriptRoot\config.json"
$Script:LogFile = "$env:TEMP\MonModule.log"
#endregion

#region Fonctions privées
function Write-Log {
    [CmdletBinding()]
    param(
        [string]$Message,
        [ValidateSet('Info','Warning','Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp [$Level] $Message" | Out-File -FilePath $Script:LogFile -Append
}
#endregion

#region Fonctions publiques
function Get-UserData {
    <#
    .SYNOPSIS
        Récupère les données utilisateur.
    .DESCRIPTION
        Cette fonction récupère et formate les données utilisateur
        depuis Active Directory.
    .PARAMETER Username
        Nom d'utilisateur à rechercher
    .EXAMPLE
        Get-UserData -Username "jdupont"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Username
    )
    
    Write-Log "Récupération des données pour $Username"
    
    # Code de la fonction...
    
    return $userData
}

function Set-UserData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Username,
        [hashtable]$Properties
    )
    
    Write-Log "Mise à jour des données pour $Username"
    
    # Code de la fonction...
}
#endregion

#region Initialisation du module
Write-Log "Module MonModule chargé"
#endregion
```

### Organisation recommandée

```powershell
# MonModule.psm1

#region Configuration et variables du module
$Script:ModuleVersion = '1.0.0'
$Script:ModuleRoot = $PSScriptRoot

# Variables de configuration accessibles dans tout le module
$Script:DefaultTimeout = 30
$Script:MaxRetries = 3
#endregion

#region Classes (PowerShell 5.0+)
class UserAccount {
    [string]$Username
    [string]$Email
    [datetime]$CreatedDate
    
    UserAccount([string]$user, [string]$mail) {
        $this.Username = $user
        $this.Email = $mail
        $this.CreatedDate = Get-Date
    }
}
#endregion

#region Énumérations
enum AccountStatus {
    Active
    Disabled
    Locked
    Expired
}
#endregion

#region Fonctions utilitaires privées
function Test-AdminPrivilege {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function ConvertTo-SafePath {
    param([string]$Path)
    return $Path -replace '[<>:"|?*]', '_'
}
#endregion

#region Fonctions publiques
function Get-ModuleInfo {
    [CmdletBinding()]
    param()
    
    [PSCustomObject]@{
        Name = 'MonModule'
        Version = $Script:ModuleVersion
        Root = $Script:ModuleRoot
        LoadedAt = Get-Date
    }
}
#endregion

#region Initialisation et nettoyage
# Code exécuté lors du chargement du module
if (Test-AdminPrivilege) {
    Write-Verbose "Module chargé avec privilèges administrateur"
}

# Enregistrement d'une action lors du déchargement du module
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    Write-Verbose "Nettoyage du module MonModule"
    # Libérer des ressources, fermer des connexions, etc.
}
#endregion
```

> [!warning] Attention à la portée (scope)
> 
> - `$Script:Variable` : Accessible dans tout le module
> - `$Private:Variable` : Accessible uniquement dans la fonction courante
> - `$Variable` : Portée locale par défaut
> - N'utilisez JAMAIS `$Global:` dans un module (pollution de l'environnement)

### Bonnes pratiques pour les fichiers .psm1

> [!tip] Organisation du code
> 
> 1. **Utilisez des regions** pour structurer visuellement le code
> 2. **Séparez clairement** fonctions publiques et privées
> 3. **Documentez** chaque fonction publique avec comment-based help
> 4. **Préfixez** les fonctions privées (ex: `_InternalFunction`)
> 5. **Limitez** le code d'initialisation au strict nécessaire

### Chargement conditionnel

```powershell
# Charger des fonctions uniquement sur certaines versions de PowerShell
if ($PSVersionTable.PSVersion.Major -ge 7) {
    . "$PSScriptRoot\Functions\ModernFeatures.ps1"
}

# Charger des fonctions selon le système d'exploitation
if ($IsWindows) {
    . "$PSScriptRoot\Functions\Windows-Specific.ps1"
} elseif ($IsLinux) {
    . "$PSScriptRoot\Functions\Linux-Specific.ps1"
}

# Dot-sourcing de fichiers de fonctions
Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" | ForEach-Object {
    . $_.FullName
}
```

> [!example] Structure de dossiers avancée
> 
> ```
> MonModule/
> ├── MonModule.psm1          # Point d'entrée principal
> ├── MonModule.psd1          # Manifeste
> ├── Public/                 # Fonctions exportées
> │   ├── Get-UserData.ps1
> │   └── Set-UserData.ps1
> ├── Private/                # Fonctions internes
> │   ├── Write-Log.ps1
> │   └── Test-Connection.ps1
> ├── Classes/                # Classes PowerShell
> │   └── UserAccount.ps1
> ├── Resources/              # Fichiers de ressources
> │   ├── config.json
> │   └── templates/
> └── Tests/                  # Tests Pester
>     └── MonModule.Tests.ps1
> ```

---

## 📋 Manifeste de module (.psd1)

Le manifeste est un fichier de métadonnées qui décrit votre module. Il est essentiel pour la distribution et la gestion des versions.

### Création d'un manifeste

```powershell
# Créer un nouveau manifeste
New-ModuleManifest -Path .\MonModule.psd1 `
    -Author "Votre Nom" `
    -CompanyName "Votre Entreprise" `
    -RootModule "MonModule.psm1" `
    -ModuleVersion "1.0.0" `
    -Description "Description de votre module" `
    -PowerShellVersion "5.1" `
    -FunctionsToExport @('Get-UserData', 'Set-UserData') `
    -CmdletsToExport @() `
    -VariablesToExport @() `
    -AliasesToExport @()
```

### Anatomie complète d'un manifeste

```powershell
@{
    # Métadonnées principales
    RootModule = 'MonModule.psm1'
    ModuleVersion = '1.2.3'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    
    # Informations sur l'auteur
    Author = 'Jean Dupont'
    CompanyName = 'Ma Société'
    Copyright = '(c) 2025 Ma Société. Tous droits réservés.'
    
    # Description
    Description = @"
Ce module fournit des outils pour la gestion des utilisateurs Active Directory.
Il inclut des fonctions pour créer, modifier et supprimer des comptes.
"@
    
    # Version minimale de PowerShell requise
    PowerShellVersion = '5.1'
    
    # Modules requis (dépendances)
    RequiredModules = @(
        @{ModuleName='ActiveDirectory'; ModuleVersion='1.0.0.0'}
    )
    
    # Assemblies .NET requis
    RequiredAssemblies = @('System.DirectoryServices.dll')
    
    # Fichiers à inclure avec le module
    FileList = @(
        'MonModule.psm1',
        'MonModule.psd1',
        'README.md',
        'LICENSE.txt'
    )
    
    # Exports explicites (RECOMMANDÉ)
    FunctionsToExport = @(
        'Get-UserData',
        'Set-UserData',
        'Remove-UserData',
        'Test-UserExists'
    )
    
    CmdletsToExport = @()      # Aucune cmdlet binaire
    VariablesToExport = @()    # Aucune variable exportée
    AliasesToExport = @()      # Ou @('gud', 'sud') si vous avez des alias
    
    # Données privées (informations supplémentaires)
    PrivateData = @{
        PSData = @{
            # Tags pour la recherche dans PowerShell Gallery
            Tags = @('ActiveDirectory', 'Users', 'Management', 'Automation')
            
            # URL du projet
            ProjectUri = 'https://github.com/votrecompte/MonModule'
            
            # URL de la licence
            LicenseUri = 'https://github.com/votrecompte/MonModule/blob/main/LICENSE.txt'
            
            # URL de l'icône
            IconUri = 'https://raw.githubusercontent.com/votrecompte/MonModule/main/icon.png'
            
            # Notes de version
            ReleaseNotes = @"
Version 1.2.3
- Ajout de la fonction Test-UserExists
- Correction de bug dans Set-UserData
- Amélioration des performances
"@
            
            # Modules préinstallés (prerelease)
            Prerelease = ''
            
            # Exigences de licence
            RequireLicenseAcceptance = $false
            
            # URI externe pour l'aide
            ExternalModuleDependencies = @()
        }
    }
    
    # Scripts à exécuter lors du chargement/déchargement
    # ScriptsToProcess = @('Initialize.ps1')
    
    # Formats de données (fichiers .ps1xml)
    # FormatsToProcess = @('MonModule.Format.ps1xml')
    
    # Types de données (fichiers .ps1xml)
    # TypesToProcess = @('MonModule.Types.ps1xml')
    
    # Modules imbriqués
    # NestedModules = @('HelperModule.psm1')
    
    # URI d'aide
    HelpInfoURI = 'https://docs.votresite.com/MonModule'
    
    # Préfixe par défaut pour les commandes
    # DefaultCommandPrefix = 'MM'
}
```

### Propriétés importantes du manifeste

|Propriété|Description|Obligatoire|
|---|---|---|
|`RootModule`|Fichier .psm1 principal|Oui|
|`ModuleVersion`|Version du module (SemVer)|Oui|
|`GUID`|Identifiant unique du module|Oui|
|`Author`|Nom de l'auteur|Recommandé|
|`Description`|Description du module|Recommandé|
|`PowerShellVersion`|Version minimale de PS|Recommandé|
|`FunctionsToExport`|Fonctions publiques|**CRITIQUE**|
|`RequiredModules`|Dépendances|Si nécessaire|

> [!warning] FunctionsToExport est crucial Si vous n'utilisez pas `FunctionsToExport` explicitement, PowerShell exportera **toutes** les fonctions du module, y compris les fonctions privées. Cela :
> 
> - Pollue le namespace de l'utilisateur
> - Expose des fonctions internes qui ne devraient pas être publiques
> - Ralentit l'import du module
> 
> **Toujours spécifier explicitement les fonctions à exporter !**

### Mise à jour d'un manifeste existant

```powershell
# Lire le manifeste actuel
$manifest = Import-PowerShellDataFile -Path .\MonModule.psd1

# Mettre à jour la version
Update-ModuleManifest -Path .\MonModule.psd1 `
    -ModuleVersion "1.3.0" `
    -ReleaseNotes "Ajout de nouvelles fonctionnalités"

# Ajouter une fonction à exporter
$currentFunctions = $manifest.FunctionsToExport
$currentFunctions += 'New-SpecialFunction'

Update-ModuleManifest -Path .\MonModule.psd1 `
    -FunctionsToExport $currentFunctions
```

> [!tip] Validation du manifeste
> 
> ```powershell
> # Vérifier que le manifeste est valide
> Test-ModuleManifest -Path .\MonModule.psd1
> 
> # Importer et inspecter
> $module = Import-Module .\MonModule.psd1 -PassThru
> $module | Format-List *
> ```

---

## 🔐 Export-ModuleMember

`Export-ModuleMember` contrôle ce qui est visible de l'extérieur du module. C'est le mécanisme d'encapsulation de PowerShell.

### Syntaxe et utilisation

```powershell
Export-ModuleMember [-Function] <string[]>
Export-ModuleMember [-Cmdlet] <string[]>
Export-ModuleMember [-Variable] <string[]>
Export-ModuleMember [-Alias] <string[]>
```

### Comportement par défaut

> [!warning] Comprendre le comportement par défaut Si vous n'utilisez **PAS** `Export-ModuleMember` dans votre .psm1 :
> 
> - **TOUTES** les fonctions sont exportées
> - **AUCUNE** variable n'est exportée
> - **AUCUN** alias n'est exporté
> 
> Si vous utilisez `Export-ModuleMember` **UNE SEULE FOIS** :
> 
> - **SEULS** les éléments spécifiés sont exportés
> - Tout le reste devient privé

### Exemples d'utilisation

```powershell
# 1. Exporter uniquement des fonctions spécifiques
Export-ModuleMember -Function 'Get-UserData', 'Set-UserData'

# 2. Exporter avec wildcards
Export-ModuleMember -Function 'Get-*', 'Set-*', 'Test-*'

# 3. Exporter fonctions ET alias
Export-ModuleMember -Function 'Get-UserData' -Alias 'gud', 'GetUser'

# 4. Exporter des variables (rare, généralement déconseillé)
Export-ModuleMember -Variable 'ModuleVersion', 'ModuleAuthor'

# 5. Exporter tout d'un type spécifique
Export-ModuleMember -Function * -Alias *

# 6. Ne rien exporter (module utilitaire chargé par d'autres modules)
Export-ModuleMember -Function @()
```

### Export-ModuleMember vs Manifeste

> [!info] Deux méthodes, une préférence Vous avez deux façons de contrôler les exports :
> 
> **Méthode 1 : Dans le .psm1 avec Export-ModuleMember**
> 
> ```powershell
> # À la fin de MonModule.psm1
> Export-ModuleMember -Function 'Get-UserData', 'Set-UserData'
> ```
> 
> **Méthode 2 : Dans le .psd1 avec FunctionsToExport**
> 
> ```powershell
> # Dans MonModule.psd1
> FunctionsToExport = @('Get-UserData', 'Set-UserData')
> ```
> 
> **Recommandation** : Utilisez le manifeste (.psd1) car :
> 
> - Plus facile à maintenir
> - Centralise les métadonnées
> - Obligatoire pour publier sur PowerShell Gallery
> - Meilleure pratique de l'industrie

### Cas d'usage avancés

```powershell
# Pattern : Export conditionnel selon la version de PowerShell
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # Fonctions disponibles uniquement sur PS 7+
    Export-ModuleMember -Function 'Get-UserData', 'Set-UserData', 'Invoke-ParallelTask'
} else {
    # Version limitée pour PS 5.1
    Export-ModuleMember -Function 'Get-UserData', 'Set-UserData'
}

# Pattern : Export conditionnel selon le système d'exploitation
$functionsToExport = @('Get-UserData', 'Set-UserData')

if ($IsWindows) {
    $functionsToExport += 'Get-WindowsSpecificData'
} elseif ($IsLinux) {
    $functionsToExport += 'Get-LinuxSpecificData'
}

Export-ModuleMember -Function $functionsToExport
```

### Gestion des alias dans le module

```powershell
# Dans MonModule.psm1

function Get-UserData {
    [CmdletBinding()]
    param([string]$Username)
    # Code...
}

function Set-UserData {
    [CmdletBinding()]
    param([string]$Username)
    # Code...
}

# Créer des alias pour les fonctions
New-Alias -Name 'gud' -Value 'Get-UserData'
New-Alias -Name 'sud' -Value 'Set-UserData'
New-Alias -Name 'GetUser' -Value 'Get-UserData'

# Exporter fonctions et alias
Export-ModuleMember -Function 'Get-UserData', 'Set-UserData' `
                    -Alias 'gud', 'sud', 'GetUser'
```

> [!tip] Convention de nommage des alias
> 
> - **2-4 lettres** : Alias courts pour usage interactif (ex: `gud`, `gcm`)
> - **Abréviations** : Versions raccourcies lisibles (ex: `GetUser`)
> - **Évitez** : Les alias dans les scripts de production
> - **Documentez** : Tous les alias dans le help de la fonction

### Pièges courants

> [!warning] Erreurs fréquentes avec Export-ModuleMember
> 
> **Piège 1 : Export-ModuleMember au mauvais endroit**
> 
> ```powershell
> # ❌ INCORRECT - À l'intérieur d'une fonction
> function Get-UserData {
>     Export-ModuleMember -Function 'Get-UserData'
> }
> 
> # ✅ CORRECT - Au niveau du module
> function Get-UserData { ... }
> Export-ModuleMember -Function 'Get-UserData'
> ```
> 
> **Piège 2 : Utiliser Export-ModuleMember avec un manifeste**
> 
> ```powershell
> # Si vous avez un .psd1 avec FunctionsToExport,
> # Export-ModuleMember dans le .psm1 est IGNORÉ
> # Le manifeste a priorité !
> ```
> 
> **Piège 3 : Oublier les wildcards**
> 
> ```powershell
> # ❌ Ceci exporte LITTÉRALEMENT la chaîne "Get-*"
> Export-ModuleMember -Function "Get-*"
> 
> # ✅ Utilisez un array ou des paramètres séparés
> Export-ModuleMember -Function Get-*
> ```

---

## 📥 Import et utilisation

Une fois votre module créé, il faut savoir comment l'importer et l'utiliser efficacement.

### Emplacement des modules

PowerShell recherche les modules dans des emplacements spécifiques définis par `$env:PSModulePath` :

```powershell
# Voir tous les chemins de modules
$env:PSModulePath -split [IO.Path]::PathSeparator

# Emplacements standards :
# Windows :
#   C:\Users\<User>\Documents\PowerShell\Modules     (Utilisateur)
#   C:\Program Files\PowerShell\Modules              (Tous les utilisateurs)
#   C:\Windows\System32\WindowsPowerShell\v1.0\Modules (Système)
# 
# Linux/Mac :
#   ~/.local/share/powershell/Modules                (Utilisateur)
#   /usr/local/share/powershell/Modules             (Tous les utilisateurs)
```

### Installation manuelle d'un module

```powershell
# Structure requise :
# $ModulePath\MonModule\
#   ├── MonModule.psd1
#   ├── MonModule.psm1
#   └── (autres fichiers)

# Copier votre module dans un emplacement standard
$modulePath = "$HOME\Documents\PowerShell\Modules\MonModule"
New-Item -Path $modulePath -ItemType Directory -Force

Copy-Item -Path "C:\Dev\MonModule\*" -Destination $modulePath -Recurse

# Vérifier que PowerShell trouve le module
Get-Module -ListAvailable -Name MonModule
```

> [!tip] Structure d'installation Le nom du **dossier** doit correspondre au nom du **module** (sans extension) :
> 
> ```
> ✅ Correct :
> Modules\MonModule\MonModule.psd1
> 
> ❌ Incorrect :
> Modules\MonModule_v1\MonModule.psd1
> Modules\MyModules\MonModule.psd1
> ```

### Import basique

```powershell
# Import simple (recherche automatique dans $env:PSModulePath)
Import-Module MonModule

# Import depuis un chemin spécifique
Import-Module "C:\Dev\MonModule\MonModule.psd1"

# Import avec information détaillée
Import-Module MonModule -Verbose

# Import et retourner l'objet module
$module = Import-Module MonModule -PassThru
$module | Get-Member
```

### Import automatique

> [!info] Auto-chargement des modules Depuis PowerShell 3.0, les modules sont chargés automatiquement quand vous utilisez une de leurs commandes :
> 
> ```powershell
> # Pas besoin de Import-Module si le module est dans $env:PSModulePath
> Get-UserData -Username "jdupont"  # Le module sera chargé automatiquement
> ```
> 
> Désactiver l'auto-import :
> 
> ```powershell
> $PSModuleAutoLoadingPreference = 'None'
> ```

### Options d'import avancées

```powershell
# Import avec préfixe (évite les conflits de noms)
Import-Module MonModule -Prefix "MM"
# Les fonctions deviennent : Get-MMUserData, Set-MMUserData

# Import avec contrainte de version
Import-Module MonModule -RequiredVersion "1.2.0"
Import-Module MonModule -MinimumVersion "1.0.0"
Import-Module MonModule -MaximumVersion "2.0.0"

# Import partiel (seulement certaines fonctions)
Import-Module MonModule -Function 'Get-UserData', 'Set-UserData'

# Import en mode restreint (pas d'exécution de code d'initialisation)
Import-Module MonModule -DisableNameChecking

# Import global (disponible pour toutes les sessions)
Import-Module MonModule -Global

# Import avec portée limitée
Import-Module MonModule -Scope Local

# Import et forcer le rechargement (écraser version en mémoire)
Import-Module MonModule -Force
```

### Vérifier et gérer les modules importés

```powershell
# Lister tous les modules chargés
Get-Module

# Lister tous les modules disponibles (pas forcément chargés)
Get-Module -ListAvailable

# Obtenir des informations sur un module spécifique
Get-Module MonModule | Format-List *

# Voir les commandes exportées par un module
Get-Command -Module MonModule

# Voir la version d'un module chargé
(Get-Module MonModule).Version

# Décharger un module
Remove-Module MonModule

# Décharger et recharger (utile en développement)
Remove-Module MonModule -ErrorAction SilentlyContinue
Import-Module MonModule -Force
```

### Utilisation dans les scripts

```powershell
# En-tête d'un script utilisant votre module

#Requires -Modules MonModule
#Requires -Version 5.1

<#
.SYNOPSIS
    Script de traitement des utilisateurs
.DESCRIPTION
    Utilise le module MonModule pour gérer les utilisateurs AD
#>

[CmdletBinding()]
param()

# Import explicite si nécessaire
Import-Module MonModule -ErrorAction Stop

try {
    # Utilisation des fonctions du module
    $users = Get-UserData -Username "jdupont"
    Set-UserData -Username "jdupont" -Properties @{Title='Manager'}
    
    Write-Output "Traitement terminé avec succès"
}
catch {
    Write-Error "Erreur lors du traitement : $_"
    exit 1
}
```

### Configuration du profil PowerShell

```powershell
# Ajouter ceci à votre $PROFILE pour charger automatiquement des modules

# Vérifier si le profil existe
if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force
}

# Éditer le profil
notepad $PROFILE

# Contenu suggéré :
# Import automatique de vos modules personnels
Import-Module MonModule -DisableNameChecking

# Ajouter un chemin personnalisé au PSModulePath
$customPath = "C:\MesModules"
if ($env:PSModulePath -notlike "*$customPath*") {
    $env:PSModulePath += ";$customPath"
}

# Créer des alias personnalisés
Set-Alias -Name gud -Value Get-UserData
```

> [!warning] Attention avec les profils
> 
> - Le code dans `$PROFILE` s'exécute à chaque démarrage de PowerShell
> - Évitez le code lent qui ralentirait le démarrage
> - Testez les imports pour éviter les erreurs répétitives
> - Utilisez `-ErrorAction SilentlyContinue` pour les imports optionnels

### Dépendances de modules

```powershell
# Dans votre MonModule.psd1
RequiredModules = @(
    'ActiveDirectory',
    @{ModuleName='PSLogging'; ModuleVersion='1.0.0'}
)

# PowerShell charge automatiquement les dépendances lors de l'import
Import-Module MonModule
# ActiveDirectory et PSLogging sont aussi chargés automatiquement
```

### Développement et test de modules

```powershell
# Workflow de développement :

# 1. Créer/modifier votre module
code "$HOME\Documents\PowerShell\Modules\MonModule\MonModule.psm1"

# 2. Recharger le module après modifications
Remove-Module MonModule -ErrorAction SilentlyContinue
Import-Module MonModule -Force -Verbose

# 3. Tester les fonctions
Get-UserData -Username "test" -Verbose

# 4. Vérifier les exports
Get-Command -Module MonModule

# Astuce : Créer une fonction de rechargement rapide
function Reload-MonModule {
    Remove-Module MonModule -ErrorAction SilentlyContinue
    Import-Module MonModule -Force -Verbose
    Get-Command -Module MonModule
}
```

> [!tip] Outil de développement : PSScriptAnalyzer
> 
> ```powershell
> # Installer l'analyseur de code
> Install-Module -Name PSScriptAnalyzer -Scope CurrentUser
> 
> # Analyser votre module pour détecter les problèmes
> Invoke-ScriptAnalyzer -Path ".\MonModule.psm1" -Recurse
> 
> # Corriger automatiquement certains problèmes
> Invoke-ScriptAnalyzer -Path ".\MonModule.psm1" -Fix
> ```

---

## 🔢 Versioning de modules

Le versioning est crucial pour la maintenance, les mises à jour et la compatibilité de vos modules.

### Semantic Versioning (SemVer)

PowerShell suit la convention **Semantic Versioning** pour les versions de modules : `MAJOR.MINOR.PATCH`

```
Version : 1.2.3
          │ │ └─── PATCH : Corrections de bugs (rétrocompatible)
          │ └───── MINOR : Nouvelles fonctionnalités (rétrocompatible)
          └─────── MAJOR : Changements cassants (non rétrocompatible)
```

> [!info] Règles du Semantic Versioning
> 
> - **MAJOR (1.0.0 → 2.0.0)** : Changements incompatibles avec les versions précédentes
>     - Suppression de fonctions publiques
>     - Modification de paramètres obligatoires
>     - Changement du comportement par défaut
> - **MINOR (1.0.0 → 1.1.0)** : Ajout de fonctionnalités rétrocompatibles
>     - Nouvelles fonctions publiques
>     - Nouveaux paramètres optionnels
>     - Améliorations de performance
> - **PATCH (1.0.0 → 1.0.1)** : Corrections de bugs uniquement
>     - Corrections de bugs
>     - Petites améliorations internes
>     - Mise à jour de documentation

### Définir la version dans le manifeste

```powershell
# Dans MonModule.psd1
@{
    ModuleVersion = '1.2.3'
    
    # Pour les versions préliminaires (prerelease)
    PrivateData = @{
        PSData = @{
            Prerelease = 'alpha'  # Version complète : 1.2.3-alpha
            # Prerelease = 'beta'
            # Prerelease = 'rc1'   (release candidate)
        }
    }
}
```

### Historique des versions

```powershell
# Documenter les changements dans le manifeste
@{
    ModuleVersion = '2.1.0'
    
    PrivateData = @{
        PSData = @{
            ReleaseNotes = @"
## Version 2.1.0 (2025-01-15)

### Nouveautés
- Ajout de la fonction Test-UserConnection
- Support de PowerShell 7.4+
- Nouveau paramètre -Timeout pour Get-UserData

### Améliorations
- Performance de Set-UserData améliorée de 40%
- Meilleure gestion des erreurs réseau
- Logs plus détaillés en mode -Verbose

### Corrections
- Correction du bug #42 : timeout non respecté
- Fix de la validation des emails
- Correction de fuite mémoire dans les longues sessions

### Changements cassants (Breaking Changes)
- Aucun

### Déprécations
- Le paramètre -LegacyMode sera supprimé en version 3.0.0
"@
        }
    }
}
```

> [!tip] Changelog externe Pour des projets plus importants, maintenez un fichier `CHANGELOG.md` séparé :
> 
> ```markdown
> # Changelog
> 
> ## [2.1.0] - 2025-01-15
> ### Added
> - Test-UserConnection function
> - Support for PowerShell 7.4+
> 
> ### Changed
> - Improved Set-UserData performance by 40%
> 
> ### Fixed
> - Timeout parameter not working (#42)
> 
> ### Deprecated
> - LegacyMode parameter (will be removed in 3.0.0)
> ```

### Gestion des versions multiples

```powershell
# Installer une version spécifique
Install-Module MonModule -RequiredVersion "1.2.3"

# Lister toutes les versions installées
Get-Module MonModule -ListAvailable | Select-Object Name, Version

# Importer une version spécifique
Import-Module MonModule -RequiredVersion "1.2.3"
Import-Module MonModule -MinimumVersion "1.0.0"
Import-Module MonModule -MaximumVersion "2.0.0"

# Désinstaller une version spécifique
Uninstall-Module MonModule -RequiredVersion "1.0.0"

# Mettre à jour vers la dernière version
Update-Module MonModule
```

### Compatibilité et dépendances de versions

```powershell
# Dans MonModule.psd1

@{
    # Version minimale de PowerShell requise
    PowerShellVersion = '5.1'
    
    # Version maximale testée (informationnel)
    # PowerShellVersion = '7.4'
    
    # Modules requis avec versions spécifiques
    RequiredModules = @(
        @{
            ModuleName = 'ActiveDirectory'
            ModuleVersion = '1.0.0.0'  # Version exacte
        },
        @{
            ModuleName = 'PSLogging'
            RequiredVersion = '2.1.0'  # Version minimale acceptable
        },
        @{
            ModuleName = 'HelperModule'
            MaximumVersion = '3.0.0'   # Compatible jusqu'à cette version
        }
    )
    
    # Assemblies .NET requis
    RequiredAssemblies = @(
        'System.DirectoryServices.dll'
    )
    
    # Version de CLR .NET requise
    DotNetFrameworkVersion = '4.7.2'
    CLRVersion = '4.0'
}
```

### Stratégies de versioning

> [!example] Scénarios de mise à jour de version
> 
> **Scénario 1 : Ajout d'une nouvelle fonction**
> 
> ```powershell
> # Avant : Version 1.2.3
> function Get-UserData { ... }
> function Set-UserData { ... }
> 
> # Après : Version 1.3.0 (MINOR)
> function Get-UserData { ... }
> function Set-UserData { ... }
> function Test-UserExists { ... }  # ✅ Nouvelle fonction
> ```
> 
> **Scénario 2 : Ajout d'un paramètre optionnel**
> 
> ```powershell
> # Avant : Version 1.3.0
> function Get-UserData {
>     param([string]$Username)
> }
> 
> # Après : Version 1.4.0 (MINOR)
> function Get-UserData {
>     param(
>         [string]$Username,
>         [int]$Timeout = 30  # ✅ Nouveau paramètre optionnel
>     )
> }
> ```
> 
> **Scénario 3 : Modification d'un paramètre obligatoire**
> 
> ```powershell
> # Avant : Version 1.4.0
> function Get-UserData {
>     param(
>         [string]$Username,
>         [int]$Timeout = 30
>     )
> }
> 
> # Après : Version 2.0.0 (MAJOR) ⚠️
> function Get-UserData {
>     param(
>         [Parameter(Mandatory)]  # ❌ Changement cassant !
>         [string]$Username,
>         [Parameter(Mandatory)]  # ❌ Ancien optionnel devient obligatoire
>         [string]$Domain,
>         [int]$Timeout = 30
>     )
> }
> ```
> 
> **Scénario 4 : Correction de bug**
> 
> ```powershell
> # Avant : Version 2.0.0
> function Set-UserData {
>     # Bug : ne gère pas les erreurs réseau
>     Update-ADUser -Identity $Username
> }
> 
> # Après : Version 2.0.1 (PATCH)
> function Set-UserData {
>     # Fix : ajout de gestion d'erreurs
>     try {
>         Update-ADUser -Identity $Username -ErrorAction Stop
>     } catch {
>         Write-Error "Échec de mise à jour : $_"
>     }
> }
> ```

### Migration entre versions majeures

```powershell
# Gérer la dépréciation de fonctionnalités

# Version 2.x - Marquer comme déprécié
function Get-UserData {
    [CmdletBinding()]
    param(
        [string]$Username,
        [switch]$LegacyMode  # À supprimer en v3.0
    )
    
    if ($LegacyMode) {
        Write-Warning @"
Le paramètre -LegacyMode est déprécié et sera supprimé dans la version 3.0.0.
Veuillez mettre à jour vos scripts pour utiliser le nouveau comportement par défaut.
Documentation : https://docs.monmodule.com/migration-v3
"@
        # Ancien comportement
    }
    
    # Nouveau comportement par défaut
}

# Version 3.0 - Suppression définitive
function Get-UserData {
    [CmdletBinding()]
    param(
        [string]$Username
        # LegacyMode supprimé
    )
    
    # Seul le nouveau comportement reste
}
```

### Vérification de version dans le code

```powershell
# Vérifier la version du module au runtime
$moduleVersion = (Get-Module MonModule).Version

if ($moduleVersion -lt [version]"2.0.0") {
    throw "Ce script requiert MonModule version 2.0.0 ou supérieure"
}

# Compatibilité conditionnelle
$module = Get-Module MonModule
if ($module.Version -ge [version]"2.1.0") {
    # Utiliser les nouvelles fonctionnalités
    Test-UserConnection -Username "jdupont"
} else {
    # Fallback pour versions anciennes
    Write-Warning "Fonctionnalité non disponible avec cette version du module"
}
```

### Automatisation du versioning

```powershell
# Script pour incrémenter automatiquement la version

function Update-ModuleVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath,
        
        [ValidateSet('Major','Minor','Patch')]
        [string]$VersionType = 'Patch',
        
        [string]$ReleaseNotes
    )
    
    # Lire le manifeste actuel
    $manifest = Import-PowerShellDataFile -Path $ManifestPath
    $currentVersion = [version]$manifest.ModuleVersion
    
    # Calculer la nouvelle version
    switch ($VersionType) {
        'Major' { 
            $newVersion = [version]::new($currentVersion.Major + 1, 0, 0) 
        }
        'Minor' { 
            $newVersion = [version]::new($currentVersion.Major, $currentVersion.Minor + 1, 0) 
        }
        'Patch' { 
            $newVersion = [version]::new($currentVersion.Major, $currentVersion.Minor, $currentVersion.Build + 1) 
        }
    }
    
    Write-Host "Mise à jour : $currentVersion → $newVersion"
    
    # Mettre à jour le manifeste
    Update-ModuleManifest -Path $ManifestPath `
        -ModuleVersion $newVersion.ToString() `
        -ReleaseNotes $ReleaseNotes
    
    Write-Host "✅ Version mise à jour avec succès" -ForegroundColor Green
}

# Utilisation :
# Update-ModuleVersion -ManifestPath ".\MonModule.psd1" -VersionType Minor -ReleaseNotes "Ajout de nouvelles fonctionnalités"
```

### Publication et distribution

```powershell
# Vérifier le module avant publication
Test-ModuleManifest -Path .\MonModule.psd1

# Publier sur PowerShell Gallery (nécessite un compte et une API key)
Publish-Module -Name MonModule -NuGetApiKey $apiKey -Verbose

# Publier sur un dépôt privé
Register-PSRepository -Name 'CompanyRepo' -SourceLocation 'https://nuget.company.com'
Publish-Module -Name MonModule -Repository 'CompanyRepo' -NuGetApiKey $apiKey

# Créer un package pour distribution manuelle
$publishPath = "C:\Publish\MonModule"
Copy-Item -Path ".\MonModule" -Destination $publishPath -Recurse

# Créer une archive
Compress-Archive -Path $publishPath -DestinationPath "MonModule_v1.2.3.zip"
```

> [!warning] Checklist avant publication Avant de publier une nouvelle version, vérifiez :
> 
> - ✅ Le manifeste est valide (`Test-ModuleManifest`)
> - ✅ Toutes les fonctions sont documentées (comment-based help)
> - ✅ Les tests Pester passent (si applicable)
> - ✅ Le CHANGELOG est à jour
> - ✅ La version suit le SemVer correctement
> - ✅ Les dépendances sont correctement spécifiées
> - ✅ Le README contient des exemples d'utilisation
> - ✅ La licence est claire (LICENSE.txt)

### Gestion de branches et tags Git

```powershell
# Convention de nommage des branches
# main/master    : Version stable actuelle
# develop        : Développement en cours
# release/v2.1.0 : Préparation de release
# hotfix/v2.0.1  : Correction urgente

# Créer un tag pour chaque version publiée
git tag -a v1.2.3 -m "Version 1.2.3 - Correction de bugs critiques"
git push origin v1.2.3

# Lister tous les tags (historique des versions)
git tag -l "v*"

# Revenir à une version spécifique
git checkout v1.2.3
```

---

## 📚 Récapitulatif et bonnes pratiques

### Structure recommandée d'un module complet

```
MonModule/
│
├── MonModule.psd1              # Manifeste (métadonnées)
├── MonModule.psm1              # Module principal (point d'entrée)
├── README.md                   # Documentation utilisateur
├── LICENSE.txt                 # Licence du module
├── CHANGELOG.md                # Historique des versions
│
├── Public/                     # Fonctions publiques (exportées)
│   ├── Get-UserData.ps1
│   ├── Set-UserData.ps1
│   └── Test-UserExists.ps1
│
├── Private/                    # Fonctions privées (internes)
│   ├── Write-Log.ps1
│   ├── Test-Connection.ps1
│   └── ConvertTo-SafePath.ps1
│
├── Classes/                    # Classes PowerShell (PS 5.0+)
│   └── UserAccount.ps1
│
├── Resources/                  # Ressources statiques
│   ├── config.json
│   ├── templates/
│   └── icons/
│
├── Tests/                      # Tests Pester
│   ├── MonModule.Tests.ps1
│   ├── Public.Tests.ps1
│   └── Private.Tests.ps1
│
├── Docs/                       # Documentation externe
│   ├── Getting-Started.md
│   ├── Advanced-Usage.md
│   └── API-Reference.md
│
└── Examples/                   # Scripts d'exemple
    ├── Example1-BasicUsage.ps1
    └── Example2-Advanced.ps1
```

### Checklist de développement

> [!tip] Bonnes pratiques essentielles
> 
> **Structure et organisation :**
> 
> - ✅ Un module = un dossier avec le nom du module
> - ✅ Fichier .psd1 (manifeste) + .psm1 (code)
> - ✅ Séparer fonctions publiques et privées
> - ✅ Utiliser des regions pour organiser le code
> 
> **Exports et encapsulation :**
> 
> - ✅ Définir explicitement `FunctionsToExport` dans le manifeste
> - ✅ Ne jamais exporter de fonctions privées
> - ✅ Utiliser `$Script:` pour les variables du module
> - ✅ Éviter `$Global:` (pollution de l'environnement)
> 
> **Documentation :**
> 
> - ✅ Comment-based help pour toutes les fonctions publiques
> - ✅ README.md avec exemples d'utilisation
> - ✅ CHANGELOG.md pour l'historique
> - ✅ Exemples de code fonctionnels
> 
> **Versioning :**
> 
> - ✅ Suivre Semantic Versioning (MAJOR.MINOR.PATCH)
> - ✅ Documenter les breaking changes
> - ✅ Marquer les dépréciations avant suppression
> - ✅ Tagger chaque version dans Git
> 
> **Qualité :**
> 
> - ✅ Tester avec PSScriptAnalyzer
> - ✅ Écrire des tests Pester
> - ✅ Gérer les erreurs proprement
> - ✅ Valider les paramètres
> 
> **Publication :**
> 
> - ✅ Vérifier avec `Test-ModuleManifest`
> - ✅ Inclure une licence claire
> - ✅ Spécifier les dépendances exactes
> - ✅ Tester sur différentes versions de PowerShell

### Template de module minimal

```powershell
# MonModule.psm1 - Template minimal

#region Configuration
$Script:ModuleRoot = $PSScriptRoot
$Script:ModuleVersion = '1.0.0'
#endregion

#region Fonctions privées
function Write-ModuleLog {
    param([string]$Message)
    Write-Verbose "[$Script:ModuleVersion] $Message"
}
#endregion

#region Fonctions publiques
function Get-ModuleInfo {
    <#
    .SYNOPSIS
        Obtient les informations du module
    .DESCRIPTION
        Retourne les informations de base sur le module MonModule
    .EXAMPLE
        Get-ModuleInfo
        Affiche la version et le chemin du module
    #>
    [CmdletBinding()]
    param()
    
    [PSCustomObject]@{
        PSTypeName = 'MonModule.Info'
        Name = 'MonModule'
        Version = $Script:ModuleVersion
        Path = $Script:ModuleRoot
    }
}
#endregion

#region Initialisation
Write-ModuleLog "Module MonModule version $Script:ModuleVersion chargé"
#endregion

# Exports (ou utilisez FunctionsToExport dans le .psd1)
# Export-ModuleMember -Function 'Get-ModuleInfo'
```

```powershell
# MonModule.psd1 - Template minimal

@{
    RootModule = 'MonModule.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'  # New-Guid
    Author = 'Votre Nom'
    CompanyName = 'Votre Entreprise'
    Copyright = '(c) 2025. Tous droits réservés.'
    Description = 'Description de votre module'
    
    PowerShellVersion = '5.1'
    
    FunctionsToExport = @('Get-ModuleInfo')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    
    PrivateData = @{
        PSData = @{
            Tags = @('Utilitaire', 'Exemple')
            ProjectUri = 'https://github.com/votrecompte/MonModule'
            LicenseUri = 'https://github.com/votrecompte/MonModule/blob/main/LICENSE'
            ReleaseNotes = 'Version initiale 1.0.0'
        }
    }
}
```

### Pièges à éviter

> [!warning] Erreurs courantes à éviter
> 
> **❌ Ne pas spécifier FunctionsToExport**
> 
> ```powershell
> # Mauvais : exporte TOUT
> # (absent du .psd1)
> 
> # Bon : export explicite
> FunctionsToExport = @('Get-UserData', 'Set-UserData')
> ```
> 
> **❌ Utiliser des variables globales**
> 
> ```powershell
> # Mauvais
> $Global:MyData = "test"
> 
> # Bon
> $Script:MyData = "test"
> ```
> 
> **❌ Module et dossier avec des noms différents**
> 
> ```powershell
> # Mauvais
> Modules\MonModule_v1\MonModule.psd1
> 
> # Bon
> Modules\MonModule\MonModule.psd1
> ```
> 
> **❌ Oublier la gestion d'erreurs**
> 
> ```powershell
> # Mauvais
> function Get-UserData {
>     Get-ADUser $Username
> }
> 
> # Bon
> function Get-UserData {
>     try {
>         Get-ADUser $Username -ErrorAction Stop
>     }
>     catch {
>         Write-Error "Impossible de récupérer l'utilisateur : $_"
>         return $null
>     }
> }
> ```
> 
> **❌ Ne pas documenter les fonctions publiques**
> 
> ```powershell
> # Mauvais
> function Get-UserData { ... }
> 
> # Bon
> function Get-UserData {
>     <#
>     .SYNOPSIS
>         Description courte
>     .DESCRIPTION
>         Description détaillée
>     .EXAMPLE
>         Get-UserData -Username "jdupont"
>     #>
>     ...
> }
> ```

---

## 🎓 Conclusion

Vous maîtrisez maintenant les aspects fondamentaux de la création de modules PowerShell personnalisés :

- **📄 Structure de module (.psm1)** : Organisation du code, séparation public/privé, utilisation de regions
- **📋 Manifeste (.psd1)** : Métadonnées, dépendances, exports explicites
- **🔐 Export-ModuleMember** : Contrôle de l'encapsulation et des exports
- **📥 Import et utilisation** : Installation, chargement, gestion des versions
- **🔢 Versioning** : Semantic Versioning, gestion des releases, migration

Les modules sont la pierre angulaire d'une organisation professionnelle du code PowerShell. Ils permettent de créer des outils réutilisables, maintenables et distribuables facilement.

> [!tip] Prochaines étapes suggérées Pour aller plus loin dans votre maîtrise des modules :
> 
> - Explorez les tests unitaires avec Pester
> - Apprenez à publier sur PowerShell Gallery
> - Étudiez les modules de la communauté pour voir les bonnes pratiques
> - Créez vos propres modules pour automatiser vos tâches récurrentes

---

_📚 Cours sur l'embellissement et la présentation des scripts PowerShell_  
_Partie : Organisation du code - Modules personnels_