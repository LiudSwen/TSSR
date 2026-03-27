

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

## 🎯 Introduction au scope

Le **scope** (portée) définit la durée de vie et la visibilité d'une variable dans votre script. Comprendre les scopes est essentiel pour éviter les conflits de noms, les effets de bord indésirables et créer du code maintenable.

> [!info] Pourquoi c'est important
> 
> - Évite les modifications accidentelles de variables
> - Permet l'encapsulation du code
> - Facilite le débogage
> - Rend le code plus prévisible et testable

### Hiérarchie des scopes

PowerShell utilise une hiérarchie de scopes imbriqués :

```
Global
  ├── Script
  │     ├── Function (Local)
  │     │     └── Block (Local)
  │     └── Function (Local)
  └── Module
```

> [!warning] Règle de résolution PowerShell recherche les variables du scope le plus proche vers le plus éloigné. Si une variable n'est pas trouvée dans le scope local, il remonte la hiérarchie.

---

## 🏠 Variables locales

Les variables locales sont créées par défaut dans le scope courant (fonction, bloc scriptblock, ou script).

### Syntaxe

```powershell
# Déclaration simple (locale par défaut)
$userName = "Alice"
$counter = 0

# Explicite (rarement nécessaire)
$local:tempValue = "Temporaire"
```

### Caractéristiques

- **Durée de vie** : Existe uniquement pendant l'exécution du bloc/fonction
- **Visibilité** : Accessible uniquement dans le scope courant et les scopes enfants
- **Héritage** : Les scopes enfants peuvent lire mais pas modifier (sauf $using: dans certains contextes)

### Exemple pratique

```powershell
function Test-LocalScope {
    # Variable locale à la fonction
    $message = "Je suis locale"
    
    # Bloc enfant peut la lire
    & {
        Write-Host $message  # ✅ Fonctionne : lecture OK
        $message = "Modifiée dans le bloc"  # Crée une NOUVELLE variable locale au bloc
    }
    
    Write-Host $message  # Affiche : "Je suis locale" (non modifiée)
}

Test-LocalScope
# Write-Host $message  # ❌ Erreur : $message n'existe pas ici
```

> [!tip] Astuce Par défaut, préférez toujours les variables locales. C'est le principe du **scope le plus restreint possible**.

### Pièges courants

```powershell
# ❌ PIÈGE : Penser qu'on modifie la variable parente
function Increment-Counter {
    $counter = 0  # Variable locale si $counter n'existe pas en global
    
    1..5 | ForEach-Object {
        $counter++  # Modifie la variable LOCALE au ForEach-Object !
    }
    
    Write-Host $counter  # Affiche 0, pas 5 !
}

# ✅ SOLUTION : Utiliser une variable du bon scope
function Increment-CounterFixed {
    $counter = 0
    
    1..5 | ForEach-Object {
        $script:counter++  # Ou utiliser un accumulateur différent
    }
    
    Write-Host $counter
}
```

---

## 🌍 Variables globales

Les variables globales existent pendant toute la session PowerShell et sont accessibles partout.

### Syntaxe

```powershell
# Déclaration explicite
$global:appName = "MonApplication"
$global:debugMode = $true

# Utilisation
function Show-AppInfo {
    Write-Host "Application : $global:appName"
    if ($global:debugMode) {
        Write-Host "Mode debug activé"
    }
}
```

### Caractéristiques

- **Durée de vie** : Toute la session PowerShell
- **Visibilité** : Accessible depuis n'importe quel script, fonction ou module
- **Risque** : Peut être modifiée accidentellement de n'importe où

### Cas d'usage légitimes

```powershell
# Configuration globale de l'application
$global:Config = @{
    Version = "1.0.0"
    LogPath = "C:\Logs\app.log"
    MaxRetries = 3
}

# Compteurs partagés
$global:RequestCount = 0

# Cache partagé
$global:UserCache = @{}

function Initialize-Application {
    Write-Host "Initialisation de $($global:Config.Version)"
    # ...
}
```

> [!warning] Attention Les variables globales créent des dépendances cachées et rendent le code difficile à tester. Utilisez-les avec parcimonie.

### Bonnes pratiques

```powershell
# ✅ BON : Préfixe conventionnel pour identifier les globales
$global:APP_Config = @{}
$global:APP_State = @{}

# ✅ BON : Initialisation centralisée
function Initialize-GlobalVariables {
    $global:APP_Config = Get-Content "config.json" | ConvertFrom-Json
    $global:APP_LogLevel = "Info"
}

# ❌ MAUVAIS : Variables globales sans préfixe
$global:data = @()  # Nom trop générique, risque de collision
$global:temp = ""   # Pourrait interférer avec d'autres scripts
```

---

## 📜 Variables de script

Les variables de script sont visibles dans tout le fichier `.ps1` courant, mais pas en dehors.

### Syntaxe

```powershell
# Au début du script
$script:connectionString = "Server=localhost;Database=MyDB"
$script:maxAttempts = 3
$script:initialized = $false

function Connect-Database {
    if (-not $script:initialized) {
        # Utilise la variable de script
        Write-Host "Connexion : $script:connectionString"
        $script:initialized = $true
    }
}

function Get-Data {
    if ($script:initialized) {
        # Toutes les fonctions du script y ont accès
        Write-Host "Récupération des données..."
    }
}
```

### Caractéristiques

- **Durée de vie** : Pendant l'exécution du script
- **Visibilité** : Tout le script `.ps1`, y compris toutes ses fonctions
- **Isolation** : Non accessible depuis d'autres scripts (sauf dot-sourcing)

### Cas d'usage typiques

```powershell
# Configuration interne du script
$script:logFile = "C:\Logs\script-$(Get-Date -Format 'yyyyMMdd').log"
$script:verbose = $false

# État partagé entre fonctions
$script:processedFiles = @()
$script:errorCount = 0

# Connexions réutilisables
$script:sqlConnection = $null
$script:apiSession = $null

function Write-Log {
    param($Message)
    Add-Content -Path $script:logFile -Value "$(Get-Date) - $Message"
}

function Process-File {
    param($FilePath)
    
    Write-Log "Traitement de $FilePath"
    $script:processedFiles += $FilePath
    
    # Logique de traitement...
}

function Get-Statistics {
    @{
        ProcessedFiles = $script:processedFiles.Count
        ErrorCount = $script:errorCount
    }
}
```

> [!tip] Recommandation Les variables `$script:` sont le meilleur choix pour partager des données entre fonctions d'un même script sans polluer le scope global.

### Comparaison Local vs Script

```powershell
function Test-Scopes {
    # Variable locale à la fonction
    $localVar = "Locale"
    
    # Variable de script
    $script:scriptVar = "Script"
    
    function Inner-Function {
        Write-Host $localVar      # ✅ Lit la variable parente
        Write-Host $script:scriptVar  # ✅ Lit la variable de script
        
        $localVar = "Modifiée"    # Crée une nouvelle variable locale
        $script:scriptVar = "Modifiée"  # ✅ Modifie réellement la variable de script
    }
    
    Inner-Function
    
    Write-Host $localVar          # Affiche "Locale"
    Write-Host $script:scriptVar  # Affiche "Modifiée"
}
```

---

## 🔧 Variables d'environnement

Les variables d'environnement sont partagées avec le système d'exploitation et persistent selon leur scope.

### Syntaxe de lecture

```powershell
# Méthode 1 : Drive Env:
$Env:USERNAME
$Env:COMPUTERNAME
$Env:PATH

# Méthode 2 : .NET
[Environment]::GetEnvironmentVariable("USERNAME")

# Lister toutes les variables
Get-ChildItem Env:
```

### Syntaxe de modification

```powershell
# Modification pour la session en cours uniquement
$Env:MY_APP_CONFIG = "C:\Config\app.json"

# Modification permanente (utilisateur)
[Environment]::SetEnvironmentVariable(
    "MY_APP_CONFIG",
    "C:\Config\app.json",
    [EnvironmentVariableTarget]::User
)

# Modification permanente (machine - nécessite admin)
[Environment]::SetEnvironmentVariable(
    "MY_APP_CONFIG",
    "C:\Config\app.json",
    [EnvironmentVariableTarget]::Machine
)
```

### Les trois scopes d'environnement

|Scope|Description|Durée de vie|Droits requis|
|---|---|---|---|
|**Process**|Session PowerShell actuelle|Fin du processus|Aucun|
|**User**|Utilisateur actuel|Permanent (profil utilisateur)|Utilisateur|
|**Machine**|Tous les utilisateurs|Permanent (système)|Administrateur|

### Exemples pratiques

```powershell
# Configuration d'application
function Initialize-AppEnvironment {
    $Env:APP_NAME = "MonApp"
    $Env:APP_VERSION = "1.0.0"
    $Env:APP_LOG_LEVEL = "Debug"
}

# Utilisation dans le script
function Write-AppLog {
    param($Message)
    
    if ($Env:APP_LOG_LEVEL -eq "Debug") {
        Write-Host "[$Env:APP_NAME v$Env:APP_VERSION] $Message"
    }
}

# Vérification de configuration
function Test-Prerequisites {
    $required = @("JAVA_HOME", "MAVEN_HOME", "NODE_PATH")
    
    foreach ($var in $required) {
        if (-not (Test-Path "Env:$var")) {
            Write-Warning "Variable manquante : $var"
            return $false
        }
    }
    return $true
}
```

### Manipulation du PATH

```powershell
# Ajouter un chemin temporairement
$Env:PATH += ";C:\MonApp\bin"

# Ajouter de manière permanente (utilisateur)
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$newPath = "$currentPath;C:\MonApp\bin"
[Environment]::SetEnvironmentVariable("PATH", $newPath, "User")

# Fonction helper pour ajouter au PATH
function Add-ToPath {
    param(
        [string]$Path,
        [EnvironmentVariableTarget]$Scope = "Process"
    )
    
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", $Scope)
    
    if ($currentPath -notlike "*$Path*") {
        $newPath = "$currentPath;$Path"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, $Scope)
        Write-Host "✅ Ajouté au PATH : $Path"
    } else {
        Write-Host "ℹ️ Déjà dans le PATH : $Path"
    }
}
```

> [!warning] Attention avec les modifications permanentes
> 
> - Les changements User/Machine nécessitent un redémarrage de l'application pour être visibles
> - Toujours vérifier si la valeur n'existe pas déjà avant d'ajouter
> - Documenter clairement les variables d'environnement utilisées

### Conventions de nommage

```powershell
# ✅ BON : Préfixe spécifique à l'application
$Env:MYAPP_CONFIG_PATH = "..."
$Env:MYAPP_LOG_LEVEL = "..."
$Env:MYAPP_API_KEY = "..."

# ❌ MAUVAIS : Noms trop génériques
$Env:CONFIG = "..."
$Env:DEBUG = "..."
```

---

## 🔒 Constantes avec Set-Variable

Les constantes sont des variables en lecture seule qui ne peuvent pas être modifiées ou supprimées accidentellement.

### Syntaxe

```powershell
# Constante simple (ReadOnly)
Set-Variable -Name "MaxConnections" -Value 10 -Option ReadOnly

# Constante vraiment constante (Constant - ne peut pas être supprimée)
Set-Variable -Name "AppVersion" -Value "1.0.0" -Option Constant

# Avec scope explicite
Set-Variable -Name "DatabaseName" -Value "Production" -Option ReadOnly -Scope Script

# Avec description
Set-Variable -Name "ApiEndpoint" -Value "https://api.example.com" `
    -Option ReadOnly `
    -Description "Point d'entrée de l'API principale"
```

### Différences entre ReadOnly et Constant

|Option|Peut être modifiée|Peut être supprimée|Usage typique|
|---|---|---|---|
|**ReadOnly**|❌ Non|✅ Oui (avec -Force)|Configuration qui peut changer entre versions|
|**Constant**|❌ Non|❌ Non|Valeurs vraiment immuables (version, constantes mathématiques)|

### Exemples pratiques

```powershell
# Configuration d'application
function Initialize-Constants {
    # Version de l'application (vraiment constante)
    Set-Variable -Name "APP_VERSION" -Value "2.1.0" -Option Constant -Scope Script
    
    # Limites configurables (ReadOnly)
    Set-Variable -Name "MAX_RETRY_COUNT" -Value 3 -Option ReadOnly -Scope Script
    Set-Variable -Name "TIMEOUT_SECONDS" -Value 30 -Option ReadOnly -Scope Script
    
    # Chemins critiques
    Set-Variable -Name "CONFIG_FILE" -Value "C:\Config\app.json" -Option ReadOnly -Scope Script
    Set-Variable -Name "LOG_DIRECTORY" -Value "C:\Logs" -Option ReadOnly -Scope Script
    
    # Constantes métier
    Set-Variable -Name "TAX_RATE" -Value 0.20 -Option Constant -Scope Script
    Set-Variable -Name "MAX_FILE_SIZE_MB" -Value 100 -Option Constant -Scope Script
}

# Utilisation
function Process-Transaction {
    param($Amount)
    
    $totalWithTax = $Amount * (1 + $TAX_RATE)
    Write-Host "Total avec taxes : $totalWithTax €"
}

# Tentative de modification
# $APP_VERSION = "3.0.0"  # ❌ Erreur : Cannot overwrite variable AppVersion
```

### Gestion avancée

```powershell
# Vérifier si une variable est constante
function Test-IsConstant {
    param([string]$Name)
    
    $var = Get-Variable -Name $Name -ErrorAction SilentlyContinue
    if ($var) {
        return $var.Options -band [System.Management.Automation.ScopedItemOptions]::Constant
    }
    return $false
}

# Supprimer une variable ReadOnly (si nécessaire)
function Remove-ReadOnlyVariable {
    param([string]$Name)
    
    Remove-Variable -Name $Name -Force -ErrorAction SilentlyContinue
}

# Lister toutes les constantes du script
function Get-ScriptConstants {
    Get-Variable -Scope Script | Where-Object {
        $_.Options -band [System.Management.Automation.ScopedItemOptions]::ReadOnly -or
        $_.Options -band [System.Management.Automation.ScopedItemOptions]::Constant
    } | Select-Object Name, Value, Options
}
```

> [!tip] Bonnes pratiques
> 
> - Utilisez **Constant** pour les valeurs qui ne changeront JAMAIS (version, constantes mathématiques)
> - Utilisez **ReadOnly** pour la configuration qui peut changer entre environnements
> - Nommez en MAJUSCULES avec underscores : `$MAX_CONNECTIONS`, `$API_KEY`
> - Initialisez toutes les constantes dans une fonction dédiée au début du script

### Cas d'usage typiques

```powershell
# Constantes mathématiques ou scientifiques
Set-Variable -Name "PI" -Value 3.14159265359 -Option Constant
Set-Variable -Name "GOLDEN_RATIO" -Value 1.618033988749 -Option Constant

# Codes d'erreur
Set-Variable -Name "ERROR_FILE_NOT_FOUND" -Value 1001 -Option Constant
Set-Variable -Name "ERROR_NETWORK_TIMEOUT" -Value 1002 -Option Constant
Set-Variable -Name "ERROR_INVALID_CONFIG" -Value 1003 -Option Constant

# Configuration critique
Set-Variable -Name "ENCRYPTION_ALGORITHM" -Value "AES256" -Option Constant
Set-Variable -Name "MIN_PASSWORD_LENGTH" -Value 12 -Option ReadOnly

# Chemins système
Set-Variable -Name "SYSTEM_ROOT" -Value $env:SystemRoot -Option ReadOnly
Set-Variable -Name "TEMP_DIRECTORY" -Value $env:TEMP -Option ReadOnly
```

---

## 🎨 Enum pour valeurs prédéfinies

Les enums permettent de définir un ensemble de valeurs nommées et typées, idéales pour les états, options, ou catégories.

### Syntaxe de base

```powershell
# Enum simple
enum LogLevel {
    Debug
    Info
    Warning
    Error
    Critical
}

# Enum avec valeurs explicites
enum HttpStatusCode {
    OK = 200
    Created = 201
    BadRequest = 400
    Unauthorized = 401
    NotFound = 404
    InternalServerError = 500
}

# Enum avec flag (combinable avec opérateurs binaires)
[Flags()]
enum FilePermissions {
    None = 0
    Read = 1
    Write = 2
    Execute = 4
    Delete = 8
}
```

### Utilisation dans les fonctions

```powershell
enum ProcessingStatus {
    Pending
    InProgress
    Completed
    Failed
    Cancelled
}

function Start-Task {
    param(
        [string]$TaskName,
        [ProcessingStatus]$InitialStatus = [ProcessingStatus]::Pending
    )
    
    Write-Host "Tâche '$TaskName' créée avec le statut : $InitialStatus"
    
    return @{
        Name = $TaskName
        Status = $InitialStatus
        StartTime = Get-Date
    }
}

# Utilisation avec autocomplétion
$task = Start-Task -TaskName "Backup" -InitialStatus Pending
$task.Status = [ProcessingStatus]::InProgress  # Type-safe
```

### Validation de paramètres

```powershell
enum Environment {
    Development
    Staging
    Production
}

function Deploy-Application {
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Version,
        
        [Environment]$TargetEnvironment  # Validation automatique !
    )
    
    # Si l'utilisateur entre une valeur invalide, PowerShell génère une erreur
    Write-Host "Déploiement de v$Version vers $TargetEnvironment"
    
    # Switch sur l'enum
    switch ($TargetEnvironment) {
        ([Environment]::Development) { 
            Write-Host "Mode développement - Tests activés"
        }
        ([Environment]::Production) { 
            Write-Host "⚠️ Mode production - Validation stricte"
        }
    }
}

# Appels valides
Deploy-Application -Version "1.0.0" -TargetEnvironment Development
Deploy-Application -Version "1.0.0" -TargetEnvironment Production

# ❌ Appel invalide
# Deploy-Application -Version "1.0.0" -TargetEnvironment "Local"  # Erreur !
```

### Enums avec Flags (combinables)

```powershell
[Flags()]
enum UserRoles {
    None = 0
    Read = 1
    Write = 2
    Delete = 4
    Admin = 8
    SuperAdmin = 16
}

function Test-Permission {
    param(
        [UserRoles]$UserRole,
        [UserRoles]$RequiredPermission
    )
    
    # Opérateur -band (bitwise AND)
    return ($UserRole -band $RequiredPermission) -eq $RequiredPermission
}

# Combinaison de permissions
$editorRole = [UserRoles]::Read -bor [UserRoles]::Write  # Opérateur -bor (bitwise OR)
$adminRole = [UserRoles]::Read -bor [UserRoles]::Write -bor [UserRoles]::Delete

Write-Host "Éditeur peut écrire ? $(Test-Permission -UserRole $editorRole -RequiredPermission Write)"
Write-Host "Éditeur peut supprimer ? $(Test-Permission -UserRole $editorRole -RequiredPermission Delete)"
```

### Conversion et casting

```powershell
enum Priority {
    Low = 1
    Medium = 2
    High = 3
    Critical = 4
}

# String vers Enum
$priorityString = "High"
$priority = [Priority]$priorityString
Write-Host $priority  # Affiche : High

# Enum vers Int
[int]$priority  # Retourne : 3

# Int vers Enum
$priorityValue = 2
$priority = [Priority]$priorityValue
Write-Host $priority  # Affiche : Medium

# Obtenir tous les noms
[Enum]::GetNames([Priority])  # @("Low", "Medium", "High", "Critical")

# Obtenir toutes les valeurs
[Enum]::GetValues([Priority])  # @(1, 2, 3, 4)
```

### Exemples pratiques complets

```powershell
# Système de logging avec enum
enum LogLevel {
    Debug = 0
    Info = 1
    Warning = 2
    Error = 3
    Critical = 4
}

$script:CurrentLogLevel = [LogLevel]::Info

function Write-Log {
    param(
        [string]$Message,
        [LogLevel]$Level = [LogLevel]::Info
    )
    
    # Ne log que si le niveau est suffisant
    if ([int]$Level -ge [int]$script:CurrentLogLevel) {
        $color = switch ($Level) {
            ([LogLevel]::Debug) { "Gray" }
            ([LogLevel]::Info) { "White" }
            ([LogLevel]::Warning) { "Yellow" }
            ([LogLevel]::Error) { "Red" }
            ([LogLevel]::Critical) { "DarkRed" }
        }
        
        Write-Host "[$Level] $Message" -ForegroundColor $color
    }
}

# Utilisation
Write-Log "Application démarrée" -Level Info
Write-Log "Détail de débogage" -Level Debug  # Ne s'affiche pas (niveau trop bas)
Write-Log "Attention !" -Level Warning
Write-Log "Erreur critique !" -Level Critical
```

```powershell
# État de machine à états
enum TaskState {
    Created
    Queued
    Running
    Paused
    Completed
    Failed
    Cancelled
}

class Task {
    [string]$Name
    [TaskState]$State
    [datetime]$CreatedAt
    
    Task([string]$name) {
        $this.Name = $name
        $this.State = [TaskState]::Created
        $this.CreatedAt = Get-Date
    }
    
    [void]Start() {
        if ($this.State -ne [TaskState]::Created -and $this.State -ne [TaskState]::Queued) {
            throw "Impossible de démarrer une tâche en état $($this.State)"
        }
        $this.State = [TaskState]::Running
    }
    
    [void]Complete() {
        if ($this.State -ne [TaskState]::Running) {
            throw "Impossible de compléter une tâche qui n'est pas en cours"
        }
        $this.State = [TaskState]::Completed
    }
}

$task = [Task]::new("MonBackup")
$task.Start()
$task.Complete()
Write-Host "État final : $($task.State)"
```

> [!tip] Avantages des Enums
> 
> - **Type-safety** : Empêche les valeurs invalides
> - **Autocomplétion** : IntelliSense dans les IDEs
> - **Lisibilité** : Code autodocumenté
> - **Refactoring** : Changements centralisés
> - **Performance** : Comparaisons entières rapides

---

## 📊 Comparaison des portées

### Tableau récapitulatif

|Type|Scope|Durée de vie|Visibilité|Cas d'usage|Syntaxe|
|---|---|---|---|---|---|
|**Local**|Fonction/Bloc|Exécution du bloc|Bloc + enfants|Par défaut, données temporaires|`$var` ou `$local:var`|
|**Script**|Fichier .ps1|Exécution du script|Tout le script|État partagé entre fonctions|`$script:var`|
|**Global**|Session|Toute la session|Partout|Configuration globale (rare)|`$global:var`|
|**Environment**|Selon le scope|Selon le scope|Système + PowerShell|Config système, intégration OS|`$Env:VAR`|
|**Constant**|Selon déclaration|Selon le scope|Selon le scope|Valeurs immuables|`Set-Variable -Option Constant`|
|**ReadOnly**|Selon déclaration|Selon le scope|Selon le scope|Config protégée|`Set-Variable -Option ReadOnly`|
|**Enum**|Type|Permanent (type)|Partout après définition|Valeurs prédéfinies typées|`enum Name { ... }`|

### Arbre de décision : Quel scope choisir ?

```
Est-ce une valeur qui ne change JAMAIS ?
├─ Oui → Enum (si ensemble fini) ou Constant
└─ Non ↓

Est-ce partagé entre plusieurs fonctions du script ?
├─ Oui → $script:variable
└─ Non ↓

Est-ce utilisé dans toute la session PowerShell ?
├─ Oui → $global:variable (avec préfixe !)
└─ Non ↓

Est-ce lié au système d'exploitation ?
├─ Oui → $Env:VARIABLE
└─ Non ↓

→ Variable locale (par défaut)
```

---

## ✅ Bonnes pratiques

### 1. Principe du scope minimum

```powershell
# ✅ BON
function Process-Data {
    $tempResult = Calculate-Something  # Local : juste ce qui est nécessaire
    return $tempResult
}

# ❌ MAUVAIS
$global:tempResult = $null  # Pollution du scope global
function Process-Data {
    $global:tempResult = Calculate-Something
}
```

### 2. Nommage explicite des scopes non-locaux

```powershell
# ✅ BON : On voit immédiatement que c'est global
$global:APP_Configuration = @{}
$script:connectionPool = @()

# ❌ MAUVAIS : Ambigu
$configuration = @{}  # Local ? Script ? Global ?
```

### 3. Initialisation centralisée

```powershell
# ✅ BON : Tout au même endroit
function Initialize-ScriptVariables {
    $script:logPath = "C:\Logs\script.log"
    $script:processedCount = 0
    $script:errorList = @()
    
    Set-Variable -Name "MAX_RETRIES" -Value 3 -Option ReadOnly -Scope Script
    Set-Variable -Name "TIMEOUT_MS" -Value 5000 -Option ReadOnly -Scope Script
}

Initialize-ScriptVariables

# ❌ MAUVAIS : Variables éparpillées
$script:logPath = "..."  # Ligne 10
function Something { $script:count = 0 }  # Ligne 50
$script:errors = @()  # Ligne 120
```

### 4. Documentation des variables partagées

```powershell
<#
.SYNOPSIS
    Script de traitement de fichiers

.DESCRIPTION
    Variables de script utilisées :
    - $script:processedFiles : Liste des fichiers traités
    - $script:errorCount : Nombre d'erreurs rencontrées
    - $script:startTime : Heure de début du traitement
    
    Constantes :
    - MAX_FILE_SIZE : Taille maximale de fichier (100 MB)
    - ALLOWED_EXTENSIONS : Extensions autorisées (.txt, .csv, .json)
#>

# Initialisation
$script:processedFiles = @()
$script:errorCount = 0
$script:startTime = Get-Date

Set-Variable -Name "MAX_FILE_SIZE" -Value 104857600 -Option Constant -Scope Script
Set-Variable -Name "ALLOWED_EXTENSIONS" -Value @(".txt", ".csv", ".json") -Option Constant -Scope Script
```

### 5. Éviter les effets de bord

```powershell
# ✅ BON : Fonction pure, pas d'effet de bord
function Get-FullName {
    param($FirstName, $LastName)
    return "$FirstName $LastName"
}

# ❌ MAUVAIS : Modifie une variable externe
$script:fullName = ""
function Get-FullName {
    param($FirstName, $LastName)
    $script:fullName = "$FirstName $LastName"  # Effet de bord
}
```

### 6. Préférer les retours aux modifications

```powershell
# ✅ BON : Retourne le résultat
function Calculate-Total {
    param($Items)
    
    $total = 0
    foreach ($item in $Items) {
        $total += $item.Price
    }
    return $total
}

$result = Calculate-Total -Items $orderItems

# ❌ MAUVAIS : Modifie une variable globale
$global:total = 0
function Calculate-Total {
    param($Items)
    foreach ($item in $Items) {
        $global:total += $item.Price
    }
}
Calculate-Total -Items $orderItems  # $global:total est modifié
```

### 7. Utiliser des enums pour les états

```powershell
# ✅ BON : Type-safe avec enum
enum ConnectionState {
    Disconnected
    Connecting
    Connected
    Error
}

$script:currentState = [ConnectionState]::Disconnected

# ❌ MAUVAIS : Strings magiques
$script:currentState = "disconnected"  # Risque de typo : "disconected", "Disconnected"
```

### 8. Protéger les valeurs critiques

```powershell
# ✅ BON : Configuration protégée
function Initialize-Config {
    Set-Variable -Name "DATABASE_SERVER" -Value "prod-db-01.contoso.com" -Option ReadOnly -Scope Script
    Set-Variable -Name "API_KEY" -Value $env:APP_API_KEY -Option ReadOnly -Scope Script
    Set-Variable -Name "ENCRYPTION_KEY" -Value (Get-SecureKey) -Option ReadOnly -Scope Script
}

# Impossible de modifier accidentellement
# $script:DATABASE_SERVER = "test-db"  # ❌ Erreur

# ❌ MAUVAIS : Valeurs critiques non protégées
$script:DATABASE_SERVER = "prod-db-01.contoso.com"
$script:API_KEY = $env:APP_API_KEY
# Risque de modification accidentelle dans le code
```

### 9. Convention de nommage cohérente

```powershell
# ✅ BON : Conventions claires
# Constantes : UPPER_SNAKE_CASE
Set-Variable -Name "MAX_CONNECTIONS" -Value 10 -Option Constant
Set-Variable -Name "DEFAULT_TIMEOUT" -Value 30 -Option Constant

# Variables de script : camelCase avec préfixe descriptif
$script:connectionPool = @()
$script:activeUsers = @()
$script:errorLog = @()

# Variables globales : UPPER_SNAKE_CASE avec préfixe APP_
$global:APP_CONFIG = @{}
$global:APP_STATE = "Running"

# Enums : PascalCase
enum ProcessingState { Idle; Busy; Error }

# ❌ MAUVAIS : Nommage incohérent
$script:ConnectionPool = @()  # PascalCase pour une variable
$script:active_users = @()    # snake_case
$global:config = @{}          # Minuscule sans préfixe
Set-Variable -Name "maxConnections" -Value 10 -Option Constant  # camelCase pour constante
```

### 10. Nettoyage et réinitialisation

```powershell
# ✅ BON : Fonction de nettoyage explicite
function Clear-ScriptState {
    $script:processedFiles = @()
    $script:errorCount = 0
    $script:connectionPool | ForEach-Object { $_.Close() }
    $script:connectionPool = @()
    
    Write-Host "✅ État du script réinitialisé"
}

# Utilisation
Clear-ScriptState

# ✅ BON : Pattern Initialize/Cleanup
function Initialize-Processing {
    $script:startTime = Get-Date
    $script:results = @()
}

function Complete-Processing {
    $duration = (Get-Date) - $script:startTime
    Write-Host "Traitement terminé en $($duration.TotalSeconds)s"
    
    # Export des résultats
    $script:results | Export-Csv "results.csv"
    
    # Nettoyage
    $script:results = @()
}
```

---

## 🎯 Pièges courants à éviter

### Piège 1 : Variables non initialisées

```powershell
# ❌ PROBLÈME : Variable utilisée avant initialisation
function Increment-Counter {
    $script:counter++  # Si $script:counter n'existe pas, valeur = 1 (au lieu de l'incrémenter)
}

# ✅ SOLUTION : Initialisation explicite
$script:counter = 0
function Increment-Counter {
    $script:counter++
}

# ✅ ALTERNATIVE : Vérification
function Increment-Counter {
    if ($null -eq $script:counter) {
        $script:counter = 0
    }
    $script:counter++
}
```

### Piège 2 : Modification involontaire dans les boucles

```powershell
# ❌ PROBLÈME : Variable créée dans chaque itération
$items = 1..5
foreach ($item in $items) {
    $result = $item * 2  # Nouvelle variable locale à chaque itération
}
# $result contient seulement la dernière valeur (10)

# ✅ SOLUTION : Variable initialisée avant la boucle
$results = @()
foreach ($item in $items) {
    $results += $item * 2
}
```

### Piège 3 : Confusion entre scopes dans les scriptblocks

```powershell
# ❌ PROBLÈME : $using: oublié dans les jobs
$script:counter = 0
1..5 | ForEach-Object -Parallel {
    $counter++  # ❌ Ne modifie PAS $script:counter !
}

# ✅ SOLUTION : Utiliser $using: pour les variables externes
$script:counter = 0
$syncHash = [hashtable]::Synchronized(@{ Counter = 0 })
1..5 | ForEach-Object -Parallel {
    $syncHash = $using:syncHash
    $syncHash.Counter++
}
$script:counter = $syncHash.Counter
```

### Piège 4 : Variables globales masquées

```powershell
# ❌ PROBLÈME : Variable locale masque la globale
$global:userName = "Admin"

function Show-User {
    $userName = "Guest"  # Crée une variable locale qui masque la globale !
    Write-Host $userName  # Affiche "Guest"
}

Show-User
Write-Host $global:userName  # Affiche "Admin" (non modifié)

# ✅ SOLUTION : Être explicite sur le scope
function Update-User {
    $global:userName = "NewAdmin"  # Modifie explicitement la globale
}
```

### Piège 5 : Enums comme strings

```powershell
enum Status { Active; Inactive; Pending }

# ❌ PROBLÈME : Comparaison incorrecte
$currentStatus = [Status]::Active
if ($currentStatus -eq "Active") {  # ⚠️ Fonctionne mais fragile
    Write-Host "Actif"
}

# ✅ SOLUTION : Comparaison avec l'enum
if ($currentStatus -eq [Status]::Active) {
    Write-Host "Actif"
}

# ✅ ALTERNATIVE : Cast explicite
if ($currentStatus -eq ([Status]"Active")) {
    Write-Host "Actif"
}
```

### Piège 6 : Variables d'environnement non nettoyées

```powershell
# ❌ PROBLÈME : Pollution de l'environnement
function Test-Something {
    $Env:TEMP_DEBUG = "true"
    # ... code ...
    # Oubli de nettoyer !
}

# ✅ SOLUTION : Pattern Try/Finally
function Test-Something {
    $Env:TEMP_DEBUG = "true"
    try {
        # ... code ...
    }
    finally {
        Remove-Item Env:\TEMP_DEBUG -ErrorAction SilentlyContinue
    }
}
```

### Piège 7 : Constantes mal utilisées

```powershell
# ❌ PROBLÈME : Tentative de modification d'une constante
Set-Variable -Name "VERSION" -Value "1.0" -Option Constant
# Plus tard dans le code...
$VERSION = "2.0"  # ❌ ERREUR : Cannot overwrite variable

# ✅ SOLUTION : Utiliser ReadOnly si modification possible
Set-Variable -Name "VERSION" -Value "1.0" -Option ReadOnly
# Si vraiment nécessaire de changer :
Remove-Variable VERSION -Force
Set-Variable -Name "VERSION" -Value "2.0" -Option ReadOnly
```

---

## 📝 Exemples complets et patterns

### Pattern 1 : Configuration centralisée

```powershell
# Configuration avec différents types de variables
enum LogLevel { Debug; Info; Warning; Error }
enum Environment { Dev; Test; Prod }

# Constantes de l'application
Set-Variable -Name "APP_NAME" -Value "MonApplication" -Option Constant -Scope Script
Set-Variable -Name "APP_VERSION" -Value "1.0.0" -Option Constant -Scope Script

# Configuration en lecture seule
Set-Variable -Name "MAX_RETRIES" -Value 3 -Option ReadOnly -Scope Script
Set-Variable -Name "TIMEOUT_SECONDS" -Value 30 -Option ReadOnly -Scope Script

# État mutable du script
$script:currentEnvironment = [Environment]::Dev
$script:logLevel = [LogLevel]::Info
$script:statistics = @{
    Requests = 0
    Errors = 0
    StartTime = Get-Date
}

function Initialize-Application {
    param(
        [Environment]$Environment = [Environment]::Dev,
        [LogLevel]$LogLevel = [LogLevel]::Info
    )
    
    $script:currentEnvironment = $Environment
    $script:logLevel = $LogLevel
    
    Write-Host "🚀 $APP_NAME v$APP_VERSION initialisé"
    Write-Host "   Environnement : $Environment"
    Write-Host "   Niveau de log : $LogLevel"
}

function Write-AppLog {
    param(
        [string]$Message,
        [LogLevel]$Level = [LogLevel]::Info
    )
    
    if ([int]$Level -ge [int]$script:logLevel) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "[$timestamp] [$Level] $Message"
    }
}

# Utilisation
Initialize-Application -Environment Prod -LogLevel Warning
Write-AppLog "Application démarrée" -Level Info  # Ne s'affiche pas (niveau < Warning)
Write-AppLog "Attention !" -Level Warning  # S'affiche
```

### Pattern 2 : État de session avec cleanup

```powershell
# Variables de session
$script:activeConnections = @()
$script:sessionData = @{}
$script:isInitialized = $false

function Start-Session {
    if ($script:isInitialized) {
        Write-Warning "Session déjà initialisée"
        return
    }
    
    $script:activeConnections = @()
    $script:sessionData = @{
        StartTime = Get-Date
        User = $env:USERNAME
        Computer = $env:COMPUTERNAME
    }
    $script:isInitialized = $true
    
    Write-Host "✅ Session démarrée pour $($script:sessionData.User)"
}

function Add-Connection {
    param($Connection)
    
    if (-not $script:isInitialized) {
        throw "Session non initialisée. Appelez Start-Session d'abord."
    }
    
    $script:activeConnections += $Connection
    Write-Host "Connexion ajoutée. Total : $($script:activeConnections.Count)"
}

function Stop-Session {
    if (-not $script:isInitialized) {
        Write-Warning "Aucune session active"
        return
    }
    
    # Cleanup des connexions
    foreach ($conn in $script:activeConnections) {
        if ($conn.State -eq "Open") {
            $conn.Close()
        }
    }
    
    $duration = (Get-Date) - $script:sessionData.StartTime
    Write-Host "Session terminée après $($duration.TotalMinutes) minutes"
    
    # Réinitialisation
    $script:activeConnections = @()
    $script:sessionData = @{}
    $script:isInitialized = $false
}

# Utilisation avec garantie de cleanup
try {
    Start-Session
    
    # Votre code ici
    Add-Connection $myConnection
    
} finally {
    Stop-Session
}
```

### Pattern 3 : Machine à états avec enum

```powershell
enum WorkflowState {
    NotStarted
    Initializing
    Processing
    Validating
    Completed
    Failed
}

# État du workflow
$script:workflowState = [WorkflowState]::NotStarted
$script:workflowData = @{}
$script:stateHistory = @()

function Set-WorkflowState {
    param([WorkflowState]$NewState)
    
    $oldState = $script:workflowState
    $script:workflowState = $NewState
    
    # Historique
    $script:stateHistory += @{
        From = $oldState
        To = $NewState
        Timestamp = Get-Date
    }
    
    Write-Host "État : $oldState → $NewState"
}

function Start-Workflow {
    if ($script:workflowState -ne [WorkflowState]::NotStarted) {
        throw "Le workflow est déjà démarré (état actuel : $script:workflowState)"
    }
    
    Set-WorkflowState -NewState Initializing
    
    try {
        # Initialisation
        $script:workflowData = @{
            StartTime = Get-Date
            Items = @()
        }
        
        Set-WorkflowState -NewState Processing
        
        # Traitement
        # ...
        
        Set-WorkflowState -NewState Validating
        
        # Validation
        # ...
        
        Set-WorkflowState -NewState Completed
        Write-Host "✅ Workflow terminé avec succès"
        
    } catch {
        Set-WorkflowState -NewState Failed
        Write-Error "❌ Échec du workflow : $_"
        throw
    }
}

function Get-WorkflowHistory {
    $script:stateHistory | ForEach-Object {
        [PSCustomObject]@{
            From = $_.From
            To = $_.To
            Timestamp = $_.Timestamp
            Duration = if ($_ -ne $script:stateHistory[-1]) {
                ($script:stateHistory[$script:stateHistory.IndexOf($_) + 1].Timestamp - $_.Timestamp).TotalSeconds
            } else { $null }
        }
    } | Format-Table -AutoSize
}
```

### Pattern 4 : Cache avec variables de script

```powershell
# Cache centralisé
$script:cache = @{}
Set-Variable -Name "CACHE_EXPIRATION_MINUTES" -Value 10 -Option ReadOnly -Scope Script

function Get-CachedData {
    param(
        [string]$Key,
        [scriptblock]$FetchFunction
    )
    
    # Vérifier le cache
    if ($script:cache.ContainsKey($Key)) {
        $cacheEntry = $script:cache[$Key]
        $age = (Get-Date) - $cacheEntry.Timestamp
        
        if ($age.TotalMinutes -lt $CACHE_EXPIRATION_MINUTES) {
            Write-Host "✅ Données trouvées en cache (âge : $($age.TotalSeconds)s)"
            return $cacheEntry.Data
        } else {
            Write-Host "⚠️ Cache expiré, rechargement..."
        }
    }
    
    # Récupérer les données fraîches
    Write-Host "🔄 Récupération des données..."
    $data = & $FetchFunction
    
    # Mettre en cache
    $script:cache[$Key] = @{
        Data = $data
        Timestamp = Get-Date
    }
    
    return $data
}

function Clear-Cache {
    param([string]$Key)
    
    if ($Key) {
        $script:cache.Remove($Key)
        Write-Host "Cache vidé pour : $Key"
    } else {
        $script:cache = @{}
        Write-Host "Cache entièrement vidé"
    }
}

# Utilisation
$users = Get-CachedData -Key "AllUsers" -FetchFunction {
    Get-ADUser -Filter * | Select-Object Name, Email
}
```

---

## 🎓 Récapitulatif final

### Ce qu'il faut retenir

> [!info] Points clés
> 
> 1. **Préférez le scope le plus restreint** : local par défaut
> 2. **`$script:` pour partager entre fonctions** d'un même fichier
> 3. **`$global:` avec parcimonie** et toujours préfixé
> 4. **Constantes pour valeurs immuables** : `Set-Variable -Option Constant`
> 5. **Enums pour ensembles de valeurs** : type-safe et autodocumenté
> 6. **Variables d'environnement pour intégration OS** : `$Env:`
> 7. **Initialisez et documentez** vos variables partagées

### Checklist avant de valider votre code

- [ ] Toutes les variables utilisent le scope approprié
- [ ] Les variables globales ont un préfixe explicite
- [ ] Les constantes sont en MAJUSCULES et protégées
- [ ] Les enums sont utilisés pour les états et catégories
- [ ] Les variables de script sont initialisées au début
- [ ] Aucune pollution du scope global
- [ ] Les variables critiques sont en ReadOnly/Constant
- [ ] Les noms sont cohérents et descriptifs
- [ ] Le cleanup est géré (try/finally si nécessaire)
- [ ] Les effets de bord sont minimisés

---

> [!tip] 💡 Astuce finale Quand vous hésitez sur le scope à utiliser, posez-vous ces questions :
> 
> - Cette variable sera-t-elle utilisée ailleurs ? → Élargir le scope
> - Cette valeur changera-t-elle ? → Variable ou ReadOnly
> - Cette valeur est-elle un ensemble fini ? → Enum
> - Cette valeur est-elle critique ? → ReadOnly/Constant
> 
> **Par défaut : Local, toujours local !**