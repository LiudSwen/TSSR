

## 📚 Table des matières

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

## 🎯 Introduction

Le nommage cohérent en PowerShell n'est pas qu'une question d'esthétique : c'est un pilier fondamental pour créer du code maintenable, lisible et professionnel. PowerShell impose des conventions strictes qui facilitent la découverte des commandes et la collaboration entre développeurs.

> [!info] Pourquoi le nommage est crucial
> 
> - **Découvrabilité** : Un bon nommage permet de deviner les commandes disponibles
> - **Maintenabilité** : Code plus facile à comprendre et à modifier
> - **Standardisation** : Cohérence avec l'écosystème PowerShell
> - **Auto-documentation** : Les noms révèlent l'intention du code

---

## 🔧 Convention Verb-Noun pour les fonctions

PowerShell impose une convention **Verb-Noun** (Verbe-Nom) pour toutes les fonctions et cmdlets. Cette structure garantit une cohérence dans tout l'écosystème PowerShell.

### 📖 Syntaxe de base

```powershell
# Structure obligatoire : Verbe-Nom
function Get-UserData { }
function Set-Configuration { }
function Remove-TempFiles { }

# ❌ INCORRECT - Ne suit pas la convention
function GetUser { }
function data_processor { }
function DoStuff { }
```

### 🎯 Pourquoi utiliser cette convention ?

1. **Cohérence** : Toutes les commandes PowerShell suivent ce modèle
2. **Lisibilité** : Le verbe indique l'action, le nom indique la cible
3. **IntelliSense** : Les IDE peuvent suggérer automatiquement
4. **Organisation** : Facilite le regroupement logique des commandes

### 💡 Exemples pratiques

```powershell
# Gestion d'utilisateurs
function Get-ActiveUser {
    # Récupère les utilisateurs actifs
    Get-ADUser -Filter {Enabled -eq $true}
}

function New-UserAccount {
    param([string]$Username, [string]$Email)
    # Crée un nouveau compte utilisateur
    New-ADUser -Name $Username -EmailAddress $Email
}

function Remove-InactiveUser {
    param([int]$DaysInactive = 90)
    # Supprime les utilisateurs inactifs depuis X jours
    Get-ADUser -Filter * | Where-Object {
        $_.LastLogonDate -lt (Get-Date).AddDays(-$DaysInactive)
    } | Remove-ADUser
}
```

> [!tip] Astuce Utilisez `Get-Command -Verb Get` pour voir toutes les commandes utilisant un verbe spécifique et vous inspirer de leur structure.

> [!warning] Piège courant Ne créez pas de fonctions avec des verbes non approuvés. PowerShell génère un avertissement qui peut être capturé par les outils d'analyse de code.

---

## ✅ Verbes approuvés (Get-Verb)

PowerShell maintient une liste officielle de verbes approuvés pour garantir la cohérence. Ces verbes sont regroupés par catégories selon leur fonction.

### 📋 Commande Get-Verb

```powershell
# Afficher tous les verbes approuvés
Get-Verb

# Rechercher un verbe spécifique
Get-Verb -Verb Get

# Filtrer par groupe
Get-Verb | Where-Object Group -eq "Common"

# Rechercher des verbes par pattern
Get-Verb | Where-Object Verb -like "*Set*"
```

### 📊 Catégories principales de verbes

|Catégorie|Description|Exemples|
|---|---|---|
|**Common**|Actions courantes|`Get`, `Set`, `New`, `Remove`, `Add`|
|**Data**|Manipulation de données|`Compare`, `Convert`, `Export`, `Import`|
|**Lifecycle**|Gestion du cycle de vie|`Start`, `Stop`, `Restart`, `Suspend`|
|**Security**|Opérations de sécurité|`Grant`, `Revoke`, `Protect`, `Unprotect`|
|**Diagnostic**|Débogage et tests|`Test`, `Debug`, `Measure`, `Trace`|

### 🎯 Verbes les plus utilisés

```powershell
# COMMON - Actions de base
Get-Process      # Récupérer des informations
Set-Variable     # Définir une valeur
New-Item         # Créer un élément
Remove-File      # Supprimer un élément
Add-Content      # Ajouter du contenu

# DATA - Manipulation
Convert-Path     # Convertir un format
Export-Csv       # Exporter des données
Import-Module    # Importer des ressources
Join-Path        # Joindre des éléments

# LIFECYCLE - Contrôle
Start-Service    # Démarrer un processus
Stop-Process     # Arrêter un processus
Restart-Computer # Redémarrer un système
Enable-Feature   # Activer une fonctionnalité

# SECURITY - Protection
Grant-Permission # Accorder des droits
Block-Access     # Bloquer l'accès
Unlock-File      # Déverrouiller une ressource

# DIAGNOSTIC - Analyse
Test-Connection  # Tester la connectivité
Measure-Command  # Mesurer la performance
Debug-Process    # Déboguer un processus
```

### 💡 Comment choisir le bon verbe

```powershell
# ✅ CORRECT - Utilise des verbes approuvés
function Get-SystemHealth {
    # Récupère l'état du système
}

function Test-NetworkConnection {
    # Teste la connexion réseau
}

function Enable-Logging {
    # Active la journalisation
}

# ❌ INCORRECT - Verbes non approuvés
function Retrieve-Data { }     # Utiliser Get-Data
function Check-Status { }      # Utiliser Test-Status
function Activate-Feature { }  # Utiliser Enable-Feature
```

> [!example] Exemple complet
> 
> ```powershell
> # Vérifier si un verbe est approuvé
> function Test-VerbApproval {
>     param([string]$VerbToTest)
>     
>     $approvedVerbs = Get-Verb | Select-Object -ExpandProperty Verb
>     
>     if ($approvedVerbs -contains $VerbToTest) {
>         Write-Host "✅ '$VerbToTest' est un verbe approuvé" -ForegroundColor Green
>     } else {
>         Write-Host "❌ '$VerbToTest' n'est PAS approuvé" -ForegroundColor Red
>         Write-Host "Suggestions :" -ForegroundColor Yellow
>         Get-Verb | Where-Object Verb -like "*$VerbToTest*" | Format-Table
>     }
> }
> 
> # Test
> Test-VerbApproval -VerbToTest "Get"      # ✅ Approuvé
> Test-VerbApproval -VerbToTest "Retrieve" # ❌ Non approuvé
> ```

> [!warning] Avertissements du système Si vous utilisez un verbe non approuvé, PowerShell génère un avertissement lors de l'import du module. Cela n'empêche pas l'exécution mais signale une non-conformité aux standards.

> [!tip] Créer vos propres conventions Pour des modules internes, vous pouvez documenter des extensions de verbes, mais restez cohérent et documentez-les clairement dans votre équipe.

---

## 📦 Noms de variables explicites

Les variables doivent être auto-documentées : leur nom doit révéler immédiatement leur contenu et leur usage.

### 📖 Syntaxe et conventions

```powershell
# ✅ CORRECT - Noms explicites et clairs
$userName = "JohnDoe"
$emailAddress = "john@example.com"
$isActive = $true
$connectionTimeout = 30
$maxRetryAttempts = 3

# ❌ INCORRECT - Noms cryptiques ou trop courts
$u = "JohnDoe"
$ea = "john@example.com"
$flag = $true
$t = 30
$n = 3
```

### 🎯 Règles de nommage des variables

1. **Utiliser des noms complets** : Évitez les abréviations sauf si universelles
2. **Révéler le type** : Le nom doit suggérer le type de données
3. **Contexte clair** : Le nom doit être compréhensible hors contexte
4. **Pas de bruit** : Évitez les préfixes inutiles comme `my`, `the`, `temp`

### 💡 Conventions par type de données

```powershell
# Booléens - Préfixer avec is, has, can, should
$isEnabled = $true
$hasPermission = $false
$canExecute = $true
$shouldRetry = $false

# Collections - Utiliser le pluriel
$users = @()
$connections = @()
$errorMessages = @()

# Compteurs et indices - Suffixer avec Count, Index, Number
$userCount = 10
$currentIndex = 0
$pageNumber = 1
$retryCount = 0

# Dates et temps - Suffixer avec Date, Time, DateTime
$creationDate = Get-Date
$lastLoginTime = (Get-Date).AddHours(-2)
$expirationDateTime = (Get-Date).AddDays(30)

# Chemins et fichiers - Suffixer avec Path, File, Directory
$configFilePath = "C:\Config\app.json"
$logDirectory = "C:\Logs"
$backupFile = "backup_20241211.zip"

# Objets complexes - Nom descriptif de l'entité
$currentUser = Get-ADUser -Identity "jdoe"
$serverConnection = New-Object System.Data.SqlClient.SqlConnection
$httpResponse = Invoke-WebRequest -Uri "https://api.example.com"
```

### 🔍 Variables de boucle

```powershell
# Variables de boucle descriptives
foreach ($user in $users) {
    Write-Host $user.Name
}

foreach ($file in $files) {
    Copy-Item $file.FullName -Destination $backupDirectory
}

# Pour les boucles simples, $i, $j sont acceptables
for ($i = 0; $i -lt 10; $i++) {
    # Traitement simple
}

# Mais préférez des noms explicites pour la clarté
for ($currentPage = 1; $currentPage -le $totalPages; $currentPage++) {
    Get-PageData -Page $currentPage
}
```

### 📋 Variables de paramètres

```powershell
function Connect-Database {
    param(
        [string]$ServerName,           # Nom explicite du serveur
        [int]$Port = 1433,             # Port avec valeur par défaut
        [string]$DatabaseName,         # Nom de la base de données
        [PSCredential]$Credential,     # Identifiants d'authentification
        [int]$TimeoutSeconds = 30      # Timeout en secondes
    )
    
    # Le nom des paramètres documente leur usage
    $connectionString = "Server=$ServerName,$Port;Database=$DatabaseName;Timeout=$TimeoutSeconds"
}
```

> [!warning] Piège : Noms trop longs Il existe un équilibre à trouver. `$userEmailAddressFromActiveDirectoryQuery` est trop verbeux. `$userEmail` suffit généralement.

> [!tip] Astuce : Cohérence dans le contexte Dans une fonction traitant des utilisateurs, `$name` peut suffire. Dans un contexte plus large, préférez `$userName`.

> [!example] Comparaison avant/après
> 
> ```powershell
> # ❌ AVANT - Difficile à comprendre
> $u = Get-ADUser -Filter *
> $c = 0
> foreach ($x in $u) {
>     if ($x.Enabled) { $c++ }
> }
> 
> # ✅ APRÈS - Intention claire
> $allUsers = Get-ADUser -Filter *
> $activeUserCount = 0
> foreach ($user in $allUsers) {
>     if ($user.Enabled) {
>         $activeUserCount++
>     }
> }
> ```

---

## 🔤 CamelCase vs snake_case

PowerShell suit des conventions de casse strictes qui diffèrent selon le type d'élément nommé. La compréhension de ces conventions est essentielle pour écrire du code idiomatique.

### 📖 PascalCase (UpperCamelCase)

Utilisé pour les fonctions, cmdlets et classes. Chaque mot commence par une majuscule, sans séparateur.

```powershell
# ✅ CORRECT - PascalCase pour les fonctions
function Get-UserData { }
function Start-BackupProcess { }
function Test-NetworkConnection { }
function Convert-CsvToJson { }

# ✅ CORRECT - PascalCase pour les classes
class DatabaseConnection {
    [string]$ServerName
    [int]$Port
    
    [void]Connect() { }
}

# ❌ INCORRECT
function get-userdata { }
function Get-user-data { }
function getUserData { }
```

### 📖 camelCase (lowerCamelCase)

Utilisé pour les variables et les paramètres. Premier mot en minuscule, mots suivants avec majuscule initiale.

```powershell
# ✅ CORRECT - camelCase pour les variables
$userName = "JohnDoe"
$emailAddress = "john@example.com"
$isConnected = $true
$maxRetryCount = 5
$connectionTimeout = 30

# ✅ CORRECT - camelCase pour les propriétés de classe
class User {
    [string]$firstName
    [string]$lastName
    [string]$emailAddress
    [bool]$isActive
}

# ❌ INCORRECT
$UserName = "JohnDoe"      # Devrait être camelCase
$user_name = "JohnDoe"     # Pas de snake_case
$USERNAME = "JohnDoe"      # Réservé aux constantes
```

### 📖 snake_case

**Non utilisé en PowerShell**. Cette convention (mots séparés par des underscores) est courante en Python mais évitée en PowerShell.

```powershell
# ❌ ÉVITER - snake_case n'est pas idiomatique en PowerShell
$user_name = "John"
$email_address = "john@example.com"
function get_user_data { }

# ✅ PRÉFÉRER - camelCase ou PascalCase selon le contexte
$userName = "John"
$emailAddress = "john@example.com"
function Get-UserData { }
```

### 🎯 Tableau récapitulatif

|Type d'élément|Convention|Exemple|
|---|---|---|
|**Fonctions/Cmdlets**|PascalCase|`Get-UserData`|
|**Classes**|PascalCase|`DatabaseConnection`|
|**Variables**|camelCase|`$userName`|
|**Paramètres**|PascalCase|`param([string]$UserName)`|
|**Propriétés de classe**|camelCase|`[string]$firstName`|
|**Constantes**|UPPERCASE|`$MAX_TIMEOUT`|
|**Variables automatiques**|PascalCase|`$PSVersionTable`|

### 💡 Cas spécial : Paramètres de fonction

Les paramètres utilisent **PascalCase** pour la cohérence avec les cmdlets natifs, même s'ils sont techniquement des variables.

```powershell
# ✅ CORRECT - Paramètres en PascalCase
function Get-UserData {
    param(
        [string]$UserName,        # PascalCase
        [string]$EmailAddress,    # PascalCase
        [switch]$IncludeInactive  # PascalCase
    )
    
    # À l'intérieur, utiliser camelCase pour les variables locales
    $currentUser = Get-ADUser -Identity $UserName
    $isActive = $currentUser.Enabled
}

# ❌ INCORRECT - Paramètres en camelCase
function Get-UserData {
    param(
        [string]$userName,
        [string]$emailAddress
    )
}
```

### 🔍 Exceptions et variables spéciales

```powershell
# Variables automatiques PowerShell - PascalCase prédéfini
$PSVersionTable
$PSScriptRoot
$PSCommandPath
$PSBoundParameters
$ErrorActionPreference

# Variables communes - Suivre la casse par défaut
$true, $false, $null  # Toujours en minuscules

# Variables de pipeline
$_ # Variable automatique (pas de règle de casse)
$PSItem # Alias de $_ en PascalCase
```

> [!warning] Piège : Mélange de conventions Ne mélangez pas les conventions dans un même script. Choisissez camelCase pour vos variables et restez cohérent dans tout votre code.

> [!tip] Migration de code Python/Ruby Si vous migrez du code d'autres langages utilisant snake_case, une recherche/remplacement systématique des underscores peut aider à la transition.

> [!example] Comparaison multi-langages
> 
> ```powershell
> # Python (snake_case)
> user_name = "John"
> email_address = "john@example.com"
> 
> # JavaScript (camelCase)
> const userName = "John";
> const emailAddress = "john@example.com";
> 
> # PowerShell (camelCase pour variables)
> $userName = "John"
> $emailAddress = "john@example.com"
> 
> # PowerShell (PascalCase pour fonctions)
> function Get-UserData { }
> ```

---

## 🔒 Constantes en majuscules

Les constantes sont des valeurs qui ne doivent pas changer pendant l'exécution du script. PowerShell n'a pas de type `const` natif comme d'autres langages, mais des conventions et mécanismes permettent de les gérer.

### 📖 Convention UPPERCASE avec underscores

```powershell
# ✅ CORRECT - Constantes en MAJUSCULES avec underscores
$MAX_RETRY_ATTEMPTS = 3
$DEFAULT_TIMEOUT = 30
$API_BASE_URL = "https://api.example.com"
$CONFIG_FILE_PATH = "C:\Config\app.json"
$DATABASE_CONNECTION_STRING = "Server=localhost;Database=MyDB"

# ❌ INCORRECT - Ne respecte pas la convention
$maxRetryAttempts = 3      # Ressemble à une variable normale
$DefaultTimeout = 30       # Pas assez distinctif
$api-base-url = "..."      # Tirets interdits
```

### 🔐 Variables en lecture seule avec Set-Variable

Pour créer de vraies constantes immuables, utilisez `Set-Variable` avec l'option `-Option ReadOnly` ou `Constant`.

```powershell
# Création d'une variable en lecture seule
Set-Variable -Name "MAX_CONNECTIONS" -Value 100 -Option ReadOnly

# Tentative de modification - GÉNÈRE UNE ERREUR
$MAX_CONNECTIONS = 200  # Erreur : Cannot overwrite variable MAX_CONNECTIONS

# Création d'une constante (encore plus restrictive)
Set-Variable -Name "PI_VALUE" -Value 3.14159 -Option Constant

# Impossible de supprimer une constante
Remove-Variable -Name "PI_VALUE"  # Erreur : Cannot remove constant
```

### 📊 Différences ReadOnly vs Constant

|Caractéristique|ReadOnly|Constant|
|---|---|---|
|**Modification**|Impossible|Impossible|
|**Suppression**|Possible avec `-Force`|Impossible|
|**Portée**|Session ou script|Session uniquement|
|**Usage recommandé**|Configurations|Valeurs mathématiques|

```powershell
# ReadOnly - Peut être supprimée avec -Force
Set-Variable -Name "CONFIG_PATH" -Value "C:\Config" -Option ReadOnly
Remove-Variable -Name "CONFIG_PATH" -Force  # ✅ Réussit avec -Force

# Constant - Impossible à supprimer
Set-Variable -Name "MAX_VALUE" -Value 999 -Option Constant
Remove-Variable -Name "MAX_VALUE" -Force  # ❌ Erreur même avec -Force
```

### 💡 Constantes dans les modules

```powershell
# Dans un module (.psm1)
Set-Variable -Name "MODULE_VERSION" -Value "1.0.0" -Option Constant -Scope Script
Set-Variable -Name "MODULE_NAME" -Value "MyModule" -Option Constant -Scope Script
Set-Variable -Name "DEFAULT_LOG_PATH" -Value "C:\Logs" -Option ReadOnly -Scope Script

function Get-ModuleInfo {
    # Les constantes sont accessibles dans toutes les fonctions
    Write-Host "Module: $MODULE_NAME v$MODULE_VERSION"
    Write-Host "Logs: $DEFAULT_LOG_PATH"
}
```

### 🎯 Organisation des constantes

```powershell
# Grouper les constantes au début du script
# ============================================
# CONSTANTES DE CONFIGURATION
# ============================================
$MAX_RETRY_ATTEMPTS = 3
$CONNECTION_TIMEOUT_SECONDS = 30
$DEFAULT_PAGE_SIZE = 50

# ============================================
# CONSTANTES DE CHEMINS
# ============================================
$LOG_DIRECTORY = "C:\Logs"
$CONFIG_FILE = "C:\Config\settings.json"
$BACKUP_PATH = "C:\Backups"

# ============================================
# CONSTANTES D'API
# ============================================
$API_BASE_URL = "https://api.example.com"
$API_VERSION = "v2"
$API_KEY = "your-api-key-here"  # À externaliser en production

# ============================================
# CODE PRINCIPAL
# ============================================
function Start-Application {
    # Utilisation des constantes
    $logFile = Join-Path $LOG_DIRECTORY "app.log"
    # ...
}
```

### 🔍 Constantes vs variables d'environnement

```powershell
# Variables d'environnement - Pour configuration système
$env:APP_CONFIG_PATH = "C:\Config"
$env:MAX_THREADS = "10"

# Constantes - Pour valeurs internes au script
Set-Variable -Name "INTERNAL_BUFFER_SIZE" -Value 1024 -Option Constant

# Les constantes sont préférables car :
# 1. Typées et validées
# 2. Portée limitée au script
# 3. Protection contre modification accidentelle
```

> [!warning] Piège : Constantes et portée Les constantes créées avec `-Option Constant` ne peuvent pas avoir une portée `-Scope Global`. Elles sont limitées à la session ou au script actuel.

> [!tip] Nommage des constantes Utilisez des noms verbeux pour les constantes : `$MAX_CONNECTION_RETRY_ATTEMPTS` est préférable à `$MAX_RETRY` car il est explicite.

> [!example] Cas d'usage : Configuration centralisée
> 
> ```powershell
> # Fichier de configuration : Config.ps1
> Set-Variable -Name "APP_NAME" -Value "MonApplication" -Option Constant
> Set-Variable -Name "APP_VERSION" -Value "2.1.0" -Option Constant
> Set-Variable -Name "MAX_LOG_SIZE_MB" -Value 100 -Option ReadOnly
> Set-Variable -Name "LOG_RETENTION_DAYS" -Value 30 -Option ReadOnly
> 
> # Dans le script principal
> . .\Config.ps1  # Dot-sourcing pour charger les constantes
> 
> Write-Host "$APP_NAME v$APP_VERSION"
> # Impossible de modifier APP_NAME ou APP_VERSION
> ```

---

## 🏷️ Préfixes pour éviter les conflits

Les préfixes sont essentiels pour éviter les collisions de noms, particulièrement dans les modules, les scripts partagés et les environnements multi-équipes.

### 📖 Préfixes de modules

Chaque module devrait avoir un préfixe unique pour ses fonctions exportées.

```powershell
# Module "CompanyTools" avec préfixe "CT"
function Get-CTUser { }
function Set-CTConfiguration { }
function Start-CTBackup { }

# Module "DatabaseUtils" avec préfixe "DB"
function Get-DBConnection { }
function Invoke-DBQuery { }
function Close-DBConnection { }

# Sans préfixe - Risque de conflit
function Get-User { }  # Lequel ? Azure, AD, Local ?
function Get-Connection { }  # Base de données, réseau, API ?
```

### 🎯 Stratégies de préfixes

|Type|Stratégie|Exemple|
|---|---|---|
|**Entreprise**|Acronyme ou code|`Get-ACMEUser` (ACME Corp)|
|**Projet**|Nom court du projet|`Get-CRMCustomer` (projet CRM)|
|**Équipe**|Code d'équipe|`Get-OPSServer` (équipe Ops)|
|**Technologie**|Plateforme cible|`Get-AZResource` (Azure)|

### 💡 Préfixes dans les modules PowerShell

```powershell
# Fichier .psd1 - Manifeste du module
@{
    ModuleVersion = '1.0.0'
    RootModule = 'MyModule.psm1'
    
    # Définir un préfixe par défaut
    DefaultCommandPrefix = 'My'
    
    FunctionsToExport = @(
        'Get-User',      # Devient Get-MyUser lors de l'import
        'Set-Config',    # Devient Set-MyConfig lors de l'import
        'Start-Process'  # Devient Start-MyProcess lors de l'import
    )
}

# Import du module avec préfixe
Import-Module MyModule -Prefix Custom  # Get-CustomUser, Set-CustomConfig
```

### 🔍 Préfixes pour variables internes

```powershell
# Dans un module complexe, préfixer les variables internes
$script:_moduleCache = @{}           # Variables privées avec _
$script:_configLoaded = $false
$script:_lastError = $null

# Variables publiques sans underscore
$script:ModuleVersion = "1.0.0"
$script:ModuleName = "MyModule"

function Get-InternalCache {
    # Les variables préfixées par _ sont clairement internes
    return $script:_moduleCache
}
```

### 📦 Éviter les conflits avec les cmdlets natives

```powershell
# ❌ DANGEREUX - Conflit avec cmdlet native
function Get-Process { }  # Masque Get-Process native
function Start-Service { }  # Masque Start-Service native

# ✅ CORRECT - Préfixe pour éviter le conflit
function Get-MyProcess { }
function Start-MyService { }

# Ou utiliser un nom plus spécifique
function Get-ApplicationProcess { }
function Start-CustomService { }
```

### 🎯 Préfixes pour les classes

```powershell
# Préfixer les classes pour éviter les collisions
class CTUser {
    [string]$UserName
    [string]$Email
}

class CTConnection {
    [string]$ServerName
    [int]$Port
}

# Sans préfixe - Risque de conflit
class User { }        # Trop générique
class Connection { }  # Conflit probable
```

### 💡 Préfixes dans les scripts d'équipe

```powershell
# Script de l'équipe DevOps - Préfixe "DO"
function Get-DOServerHealth {
    param([string]$ServerName)
    # Vérification santé serveur
}

function Start-DODeployment {
    param([string]$Environment)
    # Déploiement automatisé
}

# Script de l'équipe Security - Préfixe "SEC"
function Get-SECVulnerabilities {
    param([string]$Target)
    # Scan de vulnérabilités
}

function Block-SECThreat {
    param([string]$IPAddress)
    # Blocage automatique
}
```

### 🔐 Convention de nommage hiérarchique

```powershell
# Structure hiérarchique avec préfixes
# Entreprise-Domaine-Action-Cible

# ACME Corp > Azure > Gestion
function Get-ACMEAzureSubscription { }
function Set-ACMEAzureResourceGroup { }

# ACME Corp > Database > Maintenance
function Start-ACMEDBBackup { }
function Test-ACMEDBIntegrity { }

# ACME Corp > Security > Audit
function Get-ACMESecAuditLog { }
function Export-ACMESecReport { }
```

> [!warning] Piège : Préfixes trop longs `Get-MyCompanyDepartmentProjectModuleUserData` est illisible. Limitez-vous à 2-4 caractères pour le préfixe.

> [!tip] Documentation des préfixes Maintenez un registre des préfixes utilisés dans votre organisation pour éviter les duplications.

> [!example] Résolution de conflits
> 
> ```powershell
> # Deux modules avec des fonctions similaires
> Import-Module ActiveDirectory
> Import-Module AzureAD
> 
> # Les deux ont Get-User
> Get-ADUser -Identity "jdoe"      # Active Directory
> Get-AzureADUser -ObjectId "..."  # Azure AD
> 
> # Sans préfixe, confusion garantie :
> Get-User  # Lequel sera appelé ?
> ```

---

## ✨ Noms significatifs et descriptifs

Le nommage descriptif est l'art de rendre le code auto-documenté. Un bon nom doit révéler l'intention, le contenu et l'usage sans nécessiter de commentaire explicatif.

### 📖 Principes fondamentaux

Un nom significatif doit répondre à trois questions :

1. **Pourquoi existe-t-il ?** (Son objectif)
2. **Que fait-il ?** (Sa fonction)
3. **Comment l'utiliser ?** (Son contexte d'usage)

```powershell
# ❌ MAUVAIS - Nécessite un commentaire pour comprendre
$d = 30  # Délai en jours

# ✅ BON - Auto-documenté
$accountExpirationDays = 30

# ❌ MAUVAIS - Abréviation cryptique
$usrLst = Get-ADUser -Filter *

# ✅ BON - Intention claire
$activeDirectoryUsers = Get-ADUser -Filter *

# ❌ MAUVAIS - Trop générique
$data = Import-Csv "file.csv"
$result = Process-Data $data

# ✅ BON - Contexte explicite
$employeeRecords = Import-Csv "employees.csv"
$validatedEmployeeRecords = Validate-EmployeeData $employeeRecords
```

### 🎯 Éviter les abréviations

Les abréviations rendent le code difficile à lire et peuvent être ambiguës.

```powershell
# ❌ ABRÉVIATIONS À ÉVITER
$usr      # user ou username ?
$cfg      # config ou configuration ?
$tmp      # temp, template ou temporary ?
$conn     # connection ou connector ?
$msg      # message ?
$num      # number ou numeric ?
$btn      # button (GUI) ?
$err      # error ?

# ✅ NOMS COMPLETS PRÉFÉRABLES
$currentUser
$applicationConfig
$temporaryFile
$databaseConnection
$errorMessage
$recordCount
$submitButton
$lastError

# ✅ EXCEPTIONS - Abréviations universellement reconnues
$id       # Identifier (universellement compris)
$url      # Uniform Resource Locator
$uri      # Uniform Resource Identifier
$html     # HyperText Markup Language
$json     # JavaScript Object Notation
$xml      # eXtensible Markup Language
$api      # Application Programming Interface
$guid     # Globally Unique Identifier
$cpu      # Central Processing Unit
$ram      # Random Access Memory
```

### 💡 Contexte et portée

La longueur du nom doit être proportionnelle à sa portée. Plus la portée est large, plus le nom doit être descriptif.

```powershell
# Portée LOCALE (fonction courte) - Noms courts acceptables
function Calculate-Total {
    param([array]$Items)
    
    $sum = 0  # Contexte clair, portée limitée
    foreach ($item in $Items) {
        $sum += $item.Price
    }
    return $sum
}

# Portée MODULE - Noms descriptifs obligatoires
$script:databaseConnectionPool = @{}
$script:applicationConfigurationSettings = @{}
$script:userSessionCache = @{}

# Portée GLOBALE - Noms très descriptifs et préfixés
$global:CompanyApplicationMaximumRetryAttempts = 5
$global:CompanyApplicationDefaultTimeoutSeconds = 30
```

### 🔍 Noms de fonctions descriptifs

```powershell
# ❌ VAGUE - Que fait exactement cette fonction ?
function Process-Data { }
function Handle-Items { }
function Do-Work { }
function Manage-Users { }

# ✅ DESCRIPTIF - L'action et la cible sont claires
function Convert-CsvToJson { }
function Archive-OldLogFiles { }
function Send-EmailNotification { }
function Validate-UserCredentials { }
function Export-DatabaseBackup { }
function Compress-LargeFiles { }
function Remove-DuplicateRecords { }
function Calculate-MonthlyRevenue { }

# ✅ TRÈS DESCRIPTIF - Contexte complet
function Send-WelcomeEmailToNewCustomers { }
function Archive-LogFilesOlderThanThirtyDays { }
function Export-ActiveDirectoryUsersToExcel { }
function Calculate-AverageResponseTimeByServer { }
```

### 📊 Noms révélant le type de données

Le nom doit suggérer le type de données qu'il contient.

```powershell
# BOOLÉENS - Utiliser des préfixes interrogatifs
$isEnabled = $true
$hasPermission = $false
$canExecute = $true
$shouldRetry = $false
$wasSuccessful = $true
$doesExist = $false

# COLLECTIONS - Utiliser le pluriel
$users = @()
$servers = @()
$errorMessages = @()
$connectionStrings = @()

# COMPTEURS - Suffixer avec Count, Number, Total
$activeUserCount = 150
$pageNumber = 1
$totalRecords = 1000
$errorCount = 0
$attemptNumber = 3

# OBJETS SINGLETON - Nom au singulier
$currentUser = Get-ADUser -Identity "jdoe"
$primaryServer = Get-PrimaryServer
$activeConnection = $connectionPool[0]

# DICTIONNAIRES/HASHTABLES - Suffixer avec Map, Dictionary, Lookup
$userLookupTable = @{}
$configurationMap = @{}
$errorCodeDictionary = @{}

# DATES - Suffixer avec Date, Time, DateTime, Timestamp
$creationDate = Get-Date
$lastLoginTime = (Get-Date).AddHours(-2)
$expirationDateTime = (Get-Date).AddDays(30)
$eventTimestamp = [DateTimeOffset]::UtcNow
```

### 🎨 Noms révélant l'intention métier

```powershell
# ❌ TECHNIQUE - Révèle l'implémentation
function Get-DatabaseTable { }
function Update-FileSystem { }
function Query-RestEndpoint { }

# ✅ MÉTIER - Révèle l'intention
function Get-CustomerOrders { }
function Archive-CompletedProjects { }
function Retrieve-ProductInventory { }

# Exemple complet
# ❌ TECHNIQUE
function Execute-SqlQuery {
    param([string]$Query)
    # Exécution directe
}

# ✅ MÉTIER
function Get-EmployeeSalaryReport {
    param(
        [string]$Department,
        [DateTime]$StartDate,
        [DateTime]$EndDate
    )
    # L'implémentation (SQL) est un détail
    # Le nom révèle la valeur métier
}
```

### 💡 Conventions pour fonctions utilitaires

```powershell
# Fonctions de validation - Préfixer avec Test, Validate, Confirm
function Test-EmailFormat {
    param([string]$Email)
    return $Email -match '^[\w\.-]+@[\w\.-]+\.\w+
}

function Validate-RequiredFields {
    param([hashtable]$Data, [array]$RequiredFields)
    # Vérifie la présence des champs
}

function Confirm-UserConsent {
    param([string]$Message)
    # Demande confirmation utilisateur
}

# Fonctions de conversion - Utiliser Convert
function Convert-BytesToMegabytes {
    param([long]$Bytes)
    return [Math]::Round($Bytes / 1MB, 2)
}

function Convert-SecureStringToPlainText {
    param([SecureString]$SecureString)
    # Conversion sécurisée
}

# Fonctions de recherche - Utiliser Find, Search, Locate
function Find-FilesByExtension {
    param([string]$Path, [string]$Extension)
    Get-ChildItem -Path $Path -Filter "*.$Extension" -Recurse
}

function Search-LogForErrors {
    param([string]$LogPath, [DateTime]$Since)
    # Recherche d'erreurs dans les logs
}

# Fonctions de calcul - Utiliser Calculate, Compute
function Calculate-FileHashMd5 {
    param([string]$FilePath)
    (Get-FileHash -Path $FilePath -Algorithm MD5).Hash
}

function Compute-AverageLoadTime {
    param([array]$Measurements)
    ($Measurements | Measure-Object -Average).Average
}
```

### 🚀 Noms pour opérations asynchrones

```powershell
# Opérations asynchrones - Suffixer avec Async
function Start-BackupProcessAsync { }
function Invoke-ApiCallAsync { }
function Send-EmailAsync { }

# Jobs en arrière-plan - Suffixer avec Job
function Start-DataImportJob { }
function Get-ProcessingJobStatus { }
function Stop-RunningJob { }

# Événements et callbacks - Suffixer avec Handler, Callback
function Invoke-ErrorHandler { }
function Register-CompletionCallback { }
function On-ConnectionEstablished { }
```

### 📋 Anti-patterns à éviter

```powershell
# ❌ NOMS AVEC BRUIT (mots inutiles)
$theUserName = "John"        # "the" est inutile
$myVariable = 10             # "my" est évident
$tempData = @()              # "temp" est vague
$dataObject = @{}            # "object" est redondant
$userInfo = @{}              # "info" est trop générique

# ✅ NOMS ÉPURÉS
$userName = "John"
$retryCount = 10
$pendingOrders = @()
$userCredentials = @{}
$activeSession = @{}

# ❌ ENCODAGE DU TYPE DANS LE NOM (notation hongroise)
$strName = "John"            # Le type est évident
$intCount = 5
$arrUsers = @()
$boolIsActive = $true

# ✅ NOMS DESCRIPTIFS SANS TYPE
$name = "John"
$count = 5
$users = @()
$isActive = $true

# ❌ NOMS TROMPEURS
$userList = @{}              # C'est un hashtable, pas une liste
$getData = Set-Value         # Le nom suggère Get mais fait Set
$isEnabled = "yes"           # Devrait être un booléen

# ✅ NOMS PRÉCIS
$userDictionary = @{}
$updateValue = Set-Value
$enabledStatus = "yes"  # Ou mieux : $isEnabled = $true
```

### 🎯 Checklist pour un bon nommage

> [!tip] Questions à se poser Avant de nommer une variable ou fonction, demandez-vous :
> 
> 1. **Le nom est-il prononçable ?** `Get-UsrPrfl` ❌ vs `Get-UserProfile` ✅
> 2. **Le nom peut-il être recherché ?** `$e` ❌ vs `$emailAddress` ✅
> 3. **Le nom évite-t-il les jeux de mots ?** `Kill-Process` ❌ vs `Stop-Process` ✅
> 4. **Le nom est-il cohérent ?** `Get-User` et `Fetch-Customer` ❌ vs `Get-User` et `Get-Customer` ✅
> 5. **Le nom ajoute-t-il du contexte significatif ?** `$data` ❌ vs `$customerData` ✅
> 6. **Le nom nécessite-t-il un commentaire pour être compris ?** Si oui, améliorez le nom

### 🔍 Exemple complet : Refactoring de nommage

```powershell
# ❌ AVANT - Nommage médiocre
function proc {
    param($d, $t)
    $r = @()
    $c = 0
    foreach ($i in $d) {
        if ($i.v -gt $t) {
            $r += $i
            $c++
        }
    }
    return @{res=$r; cnt=$c}
}

# ✅ APRÈS - Nommage descriptif
function Get-ItemsAboveThreshold {
    param(
        [array]$Items,
        [int]$ThresholdValue
    )
    
    $matchingItems = @()
    $matchCount = 0
    
    foreach ($item in $Items) {
        if ($item.Value -gt $ThresholdValue) {
            $matchingItems += $item
            $matchCount++
        }
    }
    
    return @{
        MatchingItems = $matchingItems
        MatchCount = $matchCount
    }
}

# Utilisation claire
$products = @(
    @{Name="Product A"; Value=150},
    @{Name="Product B"; Value=75},
    @{Name="Product C"; Value=200}
)

$result = Get-ItemsAboveThreshold -Items $products -ThresholdValue 100
Write-Host "Found $($result.MatchCount) products above threshold"
```

> [!warning] Piège du sur-nommage Il existe un équilibre à trouver. `$userEmailAddressFromActiveDirectoryQueryResultFilteredByDepartment` est excessif. Souvent, `$userEmail` ou `$departmentUserEmail` suffit selon le contexte.

> [!example] Comparaison : Code cryptique vs descriptif
> 
> ```powershell
> # ❌ Code cryptique
> $u = Get-ADUser -Filter * | ? {$_.e -eq $true} | select n, e, d
> $c = ($u | measure).Count
> Write-Host "$c u found"
> 
> # ✅ Code descriptif
> $enabledUsers = Get-ADUser -Filter * | 
>     Where-Object {$_.Enabled -eq $true} | 
>     Select-Object Name, EmailAddress, Department
> 
> $enabledUserCount = ($enabledUsers | Measure-Object).Count
> Write-Host "$enabledUserCount enabled users found"
> ```

---

## 🎓 Récapitulatif

Le nommage cohérent en PowerShell repose sur des conventions strictes et des principes de clarté :

### ✅ Points clés à retenir

1. **Convention Verb-Noun** : Toutes les fonctions utilisent le format `Verbe-Nom` (ex: `Get-UserData`)
    
2. **Verbes approuvés** : Utilisez uniquement les verbes de la liste `Get-Verb` pour garantir la cohérence
    
3. **Variables explicites** : Les noms de variables doivent révéler leur contenu et usage sans ambiguïté
    
4. **Casse appropriée** :
    
    - `PascalCase` pour fonctions et classes
    - `camelCase` pour variables
    - `UPPERCASE` pour constantes
5. **Constantes protégées** : Utilisez `Set-Variable -Option ReadOnly/Constant` pour les valeurs immuables
    
6. **Préfixes uniques** : Évitez les conflits de noms avec des préfixes de module cohérents
    
7. **Auto-documentation** : Un bon nom rend le commentaire inutile
    

### 📌 Règles d'or

> [!info] Les 5 commandements du nommage
> 
> 1. **Clarté avant brièveté** : Préférez `$customerEmailAddress` à `$custEmail`
> 2. **Cohérence absolue** : Même convention dans tout le code
> 3. **Conventions PowerShell** : Respectez les standards de la plateforme
> 4. **Intention révélée** : Le nom doit expliquer le "pourquoi", pas le "comment"
> 5. **Éviter les abréviations** : Sauf si universellement reconnues (ID, URL, API)

### 🚀 Bénéfices d'un bon nommage

- ✅ **Code lisible** : Compréhensible par n'importe qui
- ✅ **Maintenance facilitée** : Modifications rapides et sûres
- ✅ **Moins de bugs** : Clarté = moins d'erreurs d'interprétation
- ✅ **Collaboration efficace** : Équipe synchronisée sur les conventions
- ✅ **Documentation naturelle** : Le code s'explique de lui-même

---

> [!tip] Conseil final Le nommage est un investissement. Le temps passé à trouver le bon nom est récupéré à chaque lecture future du code. N'hésitez pas à renommer si un meilleur nom vous vient à l'esprit !

**Un code bien nommé est un code qui se lit comme une prose naturelle.** 📖