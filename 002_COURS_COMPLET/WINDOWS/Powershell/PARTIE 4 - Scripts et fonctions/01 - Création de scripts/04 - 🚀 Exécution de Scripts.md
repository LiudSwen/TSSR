

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

## 🖥️ Exécution depuis la console

### Pourquoi c'est important

L'exécution de scripts depuis la console PowerShell est la méthode la plus directe pour lancer vos automatisations. Contrairement aux commandes simples, les scripts nécessitent une syntaxe spécifique pour être exécutés correctement.

### Méthodes d'exécution

#### Méthode 1 : Chemin complet avec `.\`

```powershell
# Depuis le répertoire contenant le script
.\MonScript.ps1

# Exemple concret
PS C:\Scripts> .\Backup-Database.ps1
```

#### Méthode 2 : Chemin absolu

```powershell
# Chemin complet vers le script
C:\Scripts\MonScript.ps1

# Avec espaces dans le chemin
& "C:\Mes Scripts\MonScript.ps1"
```

#### Méthode 3 : Depuis un autre répertoire

```powershell
# Exécuter un script sans changer de répertoire
& "D:\Projets\Scripts\Deploy.ps1"

# Ou en naviguant d'abord
Set-Location C:\Scripts
.\MonScript.ps1
```

> [!info] Information importante PowerShell n'exécute **jamais** un script simplement en tapant son nom (même s'il est dans le répertoire courant). Cette sécurité évite l'exécution accidentelle de scripts malveillants.

> [!warning] Erreur courante
> 
> ```powershell
> PS C:\Scripts> MonScript.ps1
> # ❌ Erreur : Le terme 'MonScript.ps1' n'est pas reconnu
> 
> PS C:\Scripts> .\MonScript.ps1
> # ✅ Correct : Utilisation de .\
> ```

### Extension .ps1

```powershell
# L'extension .ps1 est obligatoire
.\MonScript.ps1  # ✅ Correct
.\MonScript      # ❌ Ne fonctionnera pas

# Même si le fichier existe sans extension
Get-ChildItem MonScript  # Peut exister
.\MonScript              # Ne s'exécutera pas
```

> [!tip] Astuce Pro Utilisez la touche **Tab** pour l'autocomplétion des noms de scripts. Tapez les premières lettres puis Tab pour compléter automatiquement.

---

## 📂 Chemins relatifs vs absolus

### Comprendre les différences

|Type|Description|Exemple|Avantage|Inconvénient|
|---|---|---|---|---|
|**Absolu**|Chemin complet depuis la racine|`C:\Scripts\MonScript.ps1`|Fonctionne de partout|Difficile à déplacer|
|**Relatif**|Chemin depuis la position actuelle|`.\MonScript.ps1` ou `..\Autre\Script.ps1`|Portable|Dépend du répertoire courant|

### Chemins absolus

```powershell
# Chemin absolu classique
C:\Scripts\Production\Deploy.ps1

# Avec variable d'environnement
$env:USERPROFILE\Documents\Scripts\Backup.ps1

# Chemin UNC (réseau)
\\Serveur\Partage\Scripts\Maintenance.ps1

# Utilisation dans un script
$scriptPath = "C:\Scripts\MonScript.ps1"
& $scriptPath
```

> [!example] Exemple concret
> 
> ```powershell
> # Script qui doit toujours pointer vers le même emplacement
> $logPath = "C:\Logs\Application\app.log"
> $configPath = "C:\Config\app.config"
> 
> # Utile pour les services ou tâches planifiées
> & "C:\Scripts\Production\MaintenanceQuotidienne.ps1"
> ```

### Chemins relatifs

```powershell
# Depuis le répertoire courant
.\MonScript.ps1

# Répertoire parent
..\AutreScript.ps1

# Deux niveaux au-dessus
..\..\Config\Setup.ps1

# Sous-dossier
.\Utils\Helper.ps1
```

#### Symboles des chemins relatifs

```powershell
# . = Répertoire courant
Set-Location C:\Scripts
.\Test.ps1  # Équivaut à C:\Scripts\Test.ps1

# .. = Répertoire parent
Set-Location C:\Scripts\Production
..\Dev\Test.ps1  # Équivaut à C:\Scripts\Dev\Test.ps1

# Navigation complexe
..\..\Autre\Dossier\Script.ps1
```

> [!example] Exemple : Structure de projet
> 
> ```powershell
> # Structure :
> # C:\Projet\
> # ├── Scripts\
> # │   ├── Main.ps1
> # │   └── Utils\
> # │       └── Helper.ps1
> # └── Config\
> #     └── settings.json
> 
> # Depuis Main.ps1 :
> .\Utils\Helper.ps1           # Accéder à Helper
> ..\Config\settings.json      # Accéder à la config
> 
> # Depuis Helper.ps1 :
> ..\..\Config\settings.json   # Accéder à la config
> ```

### Résoudre les chemins en absolu

```powershell
# Convertir un chemin relatif en absolu
$relativePath = ".\MonScript.ps1"
$absolutePath = Resolve-Path $relativePath
Write-Host $absolutePath

# Obtenir le répertoire du script en cours d'exécution
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Script situé dans : $scriptDir"

# Construire un chemin relatif au script
$configFile = Join-Path $scriptDir "config.json"
```

> [!tip] Bonne pratique Dans les scripts destinés à être déplacés, utilisez toujours `$PSScriptRoot` pour référencer des fichiers relatifs au script :
> 
> ```powershell
> # Au lieu de :
> $config = Get-Content ".\config.json"
> 
> # Préférez :
> $config = Get-Content "$PSScriptRoot\config.json"
> ```

> [!warning] Piège du répertoire courant
> 
> ```powershell
> # Le répertoire courant peut ne PAS être celui du script
> Set-Location C:\Temp
> & "C:\Scripts\MonScript.ps1"
> 
> # Dans MonScript.ps1 :
> Get-Location  # Retourne C:\Temp (pas C:\Scripts)
> 
> # Solution :
> Set-Location $PSScriptRoot
> ```

---

## 🔧 Opérateur d'appel `&`

### Pourquoi l'utiliser

L'opérateur `&` (call operator) permet d'exécuter des commandes ou scripts dont le chemin est stocké dans une variable ou contient des espaces.

### Syntaxe de base

```powershell
# Exécuter une commande depuis une variable
$commande = "Get-Process"
& $commande

# Exécuter un script depuis une variable
$script = "C:\Scripts\MonScript.ps1"
& $script

# Avec un chemin contenant des espaces
& "C:\Mes Scripts\Mon Script.ps1"
```

> [!info] Quand l'utiliser
> 
> - Quand le chemin du script est dans une variable
> - Quand le chemin contient des espaces
> - Pour construire des appels dynamiques
> - Dans les boucles qui exécutent plusieurs scripts

### Cas d'usage avancés

#### Exécution dynamique de scripts

```powershell
# Liste de scripts à exécuter
$scripts = @(
    "C:\Scripts\Backup.ps1",
    "C:\Scripts\Cleanup.ps1",
    "C:\Scripts\Report.ps1"
)

# Exécution en boucle
foreach ($script in $scripts) {
    Write-Host "Exécution de : $script"
    & $script
}
```

#### Avec des arguments

```powershell
# Script avec arguments
$script = "C:\Scripts\Deploy.ps1"
$env = "Production"
$version = "2.1.5"

& $script -Environment $env -Version $version

# Ou avec un tableau d'arguments
$args = @("-Environment", "Production", "-Version", "2.1.5")
& $script @args
```

#### Construction dynamique de commandes

```powershell
# Sélection de commande selon condition
$operation = "Backup"
$command = if ($operation -eq "Backup") {
    "C:\Scripts\Backup.ps1"
} else {
    "C:\Scripts\Restore.ps1"
}

& $command -Database "Production"
```

> [!example] Exemple : Launcher de scripts
> 
> ```powershell
> # Menu de sélection de scripts
> $choix = Read-Host @"
> Choisissez un script :
> 1. Backup
> 2. Maintenance
> 3. Rapport
> "@
> 
> $scripts = @{
>     "1" = "C:\Scripts\Backup.ps1"
>     "2" = "C:\Scripts\Maintenance.ps1"
>     "3" = "C:\Scripts\Generate-Report.ps1"
> }
> 
> if ($scripts.ContainsKey($choix)) {
>     Write-Host "Exécution du script..."
>     & $scripts[$choix]
> } else {
>     Write-Warning "Choix invalide"
> }
> ```

### Différence avec l'invocation directe

```powershell
# Sans opérateur & (interprété comme chaîne)
$script = "Get-Process"
$script                    # Affiche "Get-Process" (texte)

# Avec opérateur & (exécuté)
& $script                  # Exécute la commande Get-Process

# Chemin direct (fonctionne sans &)
.\MonScript.ps1           # ✅ Fonctionne

# Depuis une variable (nécessite &)
$path = ".\MonScript.ps1"
$path                      # ❌ Affiche juste le texte
& $path                    # ✅ Exécute le script
```

> [!warning] Erreur fréquente
> 
> ```powershell
> # Ceci ne fonctionne PAS :
> $script = ".\MonScript.ps1"
> $script  # Affiche juste le texte, n'exécute rien
> 
> # Solution :
> & $script  # Utiliser l'opérateur &
> ```

> [!tip] Astuce : Chemins avec espaces
> 
> ```powershell
> # Avec espaces, toujours utiliser des guillemets ET &
> & "C:\Program Files\Mon App\script.ps1"
> 
> # Ou avec variable
> $path = "C:\Program Files\Mon App\script.ps1"
> & $path
> ```

---

## 🔄 Dot Sourcing

### Qu'est-ce que le dot sourcing ?

Le dot sourcing est une méthode d'exécution qui charge le contenu d'un script dans la **portée actuelle** au lieu de créer une nouvelle portée isolée.

### Syntaxe

```powershell
# Syntaxe du dot sourcing
. .\MonScript.ps1

# Notez l'espace après le point
. .\Functions.ps1  # ✅ Correct
..\Functions.ps1   # ❌ Incorrect (pas d'espace)
```

> [!warning] Attention à la syntaxe
> 
> ```powershell
> # CORRECT - Il y a un espace après le point
> . .\script.ps1
> ↑ ↑
> │ └─ Chemin du script
> └─── Opérateur dot source
> 
> # INCORRECT - Pas d'espace
> ..\script.ps1  # Ceci est un chemin relatif, pas du dot sourcing
> ```

### Différence avec l'exécution normale

#### Tableau comparatif

|Aspect|Exécution normale `.\script.ps1`|Dot sourcing `. .\script.ps1`|
|---|---|---|
|**Portée**|Nouvelle portée isolée|Portée actuelle (partagée)|
|**Variables**|Locales au script|Disponibles après exécution|
|**Fonctions**|Inaccessibles après|Disponibles après exécution|
|**Usage principal**|Scripts autonomes|Bibliothèques de fonctions|
|**Isolation**|Forte|Aucune|

#### Démonstration pratique

```powershell
# Fichier : Functions.ps1
$message = "Hello from Functions"
function Get-Greeting {
    param($name)
    "Bonjour, $name!"
}

# ═══════════════════════════════════════
# SANS dot sourcing (exécution normale)
# ═══════════════════════════════════════
.\Functions.ps1

# Tentative d'accès
$message              # ❌ Variable non trouvée
Get-Greeting "Alice"  # ❌ Fonction non trouvée

# ═══════════════════════════════════════
# AVEC dot sourcing
# ═══════════════════════════════════════
. .\Functions.ps1

# Accès réussi
$message              # ✅ "Hello from Functions"
Get-Greeting "Alice"  # ✅ "Bonjour, Alice!"
```

### Cas d'usage du dot sourcing

#### 1. Bibliothèques de fonctions

```powershell
# Fichier : Utils.ps1
function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append "C:\Logs\app.log"
}

function Get-SystemInfo {
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        OS = (Get-CimInstance Win32_OperatingSystem).Caption
        Memory = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
    }
}

# ════════════════════════════════════
# Script principal
# ════════════════════════════════════
# Charger les fonctions utilitaires
. .\Utils.ps1

# Utiliser les fonctions
Write-Log "Application démarrée"
$info = Get-SystemInfo
Write-Log "Système : $($info.OS)"
```

#### 2. Fichiers de configuration

```powershell
# Fichier : Config.ps1
$ServerName = "SQL-PROD-01"
$DatabaseName = "CustomerDB"
$ConnectionString = "Server=$ServerName;Database=$DatabaseName;Integrated Security=True"
$MaxRetries = 3
$Timeout = 30

# ════════════════════════════════════
# Script principal
# ════════════════════════════════════
. .\Config.ps1

# Variables de configuration disponibles
Write-Host "Connexion à : $ServerName"
Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT TOP 1 * FROM Users"
```

#### 3. Modules personnels légers

```powershell
# Fichier : DatabaseHelpers.ps1
function Connect-Database {
    param($ConnectionString)
    # Logique de connexion
}

function Invoke-DatabaseQuery {
    param($Query, $Connection)
    # Logique d'exécution
}

function Disconnect-Database {
    param($Connection)
    # Logique de déconnexion
}

# ════════════════════════════════════
# Utilisation
# ════════════════════════════════════
. .\DatabaseHelpers.ps1

$conn = Connect-Database -ConnectionString $cs
$results = Invoke-DatabaseQuery -Query "SELECT * FROM Users" -Connection $conn
Disconnect-Database -Connection $conn
```

> [!example] Structure de projet avec dot sourcing
> 
> ```powershell
> # Structure :
> # C:\Projet\
> # ├── Main.ps1
> # ├── Config\
> # │   └── Settings.ps1
> # └── Lib\
> #     ├── Logger.ps1
> #     └── Database.ps1
> 
> # Dans Main.ps1 :
> . .\Config\Settings.ps1
> . .\Lib\Logger.ps1
> . .\Lib\Database.ps1
> 
> # Toutes les fonctions et variables sont maintenant disponibles
> Write-Log "Application démarrée"
> Connect-Database -Server $ServerName
> ```

### Portée des variables et fonctions

#### Hiérarchie des portées

```powershell
# Script : TestScope.ps1
$global:globalVar = "Global"
$script:scriptVar = "Script"
$localVar = "Local"

function Test-Scope {
    $functionVar = "Function"
    Write-Host "Dans la fonction :"
    Write-Host "  Global: $global:globalVar"
    Write-Host "  Script: $script:scriptVar"
    Write-Host "  Local: $localVar"        # ❌ Non accessible
    Write-Host "  Function: $functionVar"
}

# ════════════════════════════════════
# Exécution normale
# ════════════════════════════════════
.\TestScope.ps1
Test-Scope  # ❌ Fonction non trouvée (portée différente)

# ════════════════════════════════════
# Dot sourcing
# ════════════════════════════════════
. .\TestScope.ps1
Test-Scope  # ✅ Fonction disponible
$localVar   # ✅ Variable disponible
```

#### Modificateurs de portée

```powershell
# Dans un script dot-sourcé
$local:maVariable = "Local"      # Visible uniquement dans la portée actuelle
$script:maVariable = "Script"    # Visible dans tout le script
$global:maVariable = "Global"    # Visible partout, même après le script

# Exemple pratique
. {
    $global:config = @{
        Server = "PROD-01"
        Database = "Main"
    }
    
    function Get-Config {
        $global:config
    }
}

# Variables et fonctions globales disponibles
$config.Server      # ✅ "PROD-01"
Get-Config          # ✅ Fonctionne
```

> [!tip] Bonne pratique : Préfixes de fonctions
> 
> ```powershell
> # Utilisez des préfixes pour éviter les conflits de noms
> 
> # Dans DatabaseLib.ps1
> function DbLib-Connect { }
> function DbLib-Query { }
> function DbLib-Disconnect { }
> 
> # Dans LoggerLib.ps1
> function Log-Write { }
> function Log-Error { }
> function Log-Archive { }
> 
> # Pas de conflit lors du dot sourcing
> . .\DatabaseLib.ps1
> . .\LoggerLib.ps1
> ```

> [!warning] Attention aux collisions
> 
> ```powershell
> # Lib1.ps1
> function Get-Data { "Données de Lib1" }
> 
> # Lib2.ps1
> function Get-Data { "Données de Lib2" }
> 
> # Collision !
> . .\Lib1.ps1
> Get-Data  # "Données de Lib1"
> 
> . .\Lib2.ps1
> Get-Data  # "Données de Lib2" (écrase la première)
> ```

### Cas où NE PAS utiliser le dot sourcing

```powershell
# ❌ Scripts qui modifient l'environnement de façon destructive
. .\CleanupAll.ps1  # Pourrait supprimer des variables importantes

# ❌ Scripts qui changent la localisation
. .\NavigateToFolder.ps1  # Changerait votre dossier actuel

# ❌ Scripts longs ou complexes
. .\ComplexProcessing.ps1  # Mieux vaut une portée isolée

# ✅ Préférez l'exécution normale pour ces cas
.\CleanupAll.ps1
.\NavigateToFolder.ps1
.\ComplexProcessing.ps1
```

---

## 📥 Passage d'arguments au script

### Méthodes de passage d'arguments

Il existe plusieurs façons de passer des informations à un script PowerShell, chacune adaptée à des situations différentes.

### Méthode 1 : Arguments positionnels ($args)

```powershell
# Script : SimpleScript.ps1
Write-Host "Premier argument : $($args[0])"
Write-Host "Deuxième argument : $($args[1])"
Write-Host "Tous les arguments : $args"
Write-Host "Nombre d'arguments : $($args.Count)"

# Exécution
.\SimpleScript.ps1 "Bonjour" "Monde"
# Sortie :
# Premier argument : Bonjour
# Deuxième argument : Monde
# Tous les arguments : Bonjour Monde
# Nombre d'arguments : 2
```

> [!info] Variable $args
> 
> - `$args` est un tableau automatique contenant tous les arguments
> - Les arguments sont accessibles par index : `$args[0]`, `$args[1]`, etc.
> - Utile pour des scripts simples sans validation complexe

#### Boucle sur les arguments

```powershell
# Script : ProcessFiles.ps1
Write-Host "Traitement de $($args.Count) fichiers :"
foreach ($file in $args) {
    Write-Host "  - $file"
    # Traitement du fichier
}

# Exécution
.\ProcessFiles.ps1 file1.txt file2.txt file3.txt
```

### Méthode 2 : Paramètres nommés (param)

```powershell
# Script : Deploy.ps1
param(
    [string]$Environment,
    [string]$Version,
    [bool]$Backup = $true
)

Write-Host "Déploiement :"
Write-Host "  Environnement : $Environment"
Write-Host "  Version : $Version"
Write-Host "  Backup : $Backup"

# Exécution avec paramètres nommés
.\Deploy.ps1 -Environment "Production" -Version "2.1.5" -Backup $false

# Ou avec ordre positionnel
.\Deploy.ps1 "Production" "2.1.5" $false
```

#### Paramètres avec types et validation

```powershell
# Script : Advanced.ps1
param(
    # Paramètre obligatoire avec type
    [Parameter(Mandatory=$true)]
    [string]$ServerName,
    
    # Paramètre avec valeurs limitées
    [Parameter(Mandatory=$true)]
    [ValidateSet("Dev", "Test", "Production")]
    [string]$Environment,
    
    # Paramètre numérique avec plage
    [ValidateRange(1, 100)]
    [int]$Timeout = 30,
    
    # Paramètre avec pattern
    [ValidatePattern("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")]
    [string]$IPAddress,
    
    # Switch (booléen simplifié)
    [switch]$Force
)

# Exécution
.\Advanced.ps1 -ServerName "SRV-01" -Environment "Production" -IPAddress "192.168.1.10" -Force
```

> [!example] Exemple complet de validation
> 
> ```powershell
> # Script : Backup-Database.ps1
> param(
>     [Parameter(Mandatory=$true, HelpMessage="Nom de la base de données")]
>     [ValidateNotNullOrEmpty()]
>     [string]$DatabaseName,
>     
>     [Parameter(Mandatory=$false)]
>     [ValidateScript({Test-Path $_})]
>     [string]$BackupPath = "C:\Backups",
>     
>     [ValidateRange(1, 30)]
>     [int]$RetentionDays = 7,
>     
>     [switch]$Compress
> )
> 
> Write-Host "Sauvegarde de $DatabaseName"
> Write-Host "Destination : $BackupPath"
> Write-Host "Rétention : $RetentionDays jours"
> Write-Host "Compression : $Compress"
> ```

### Méthode 3 : Splatting

Le splatting permet de passer des paramètres sous forme de hashtable, très utile pour les appels complexes.

```powershell
# Définir les paramètres dans une hashtable
$params = @{
    ServerName = "SRV-PROD-01"
    Environment = "Production"
    Version = "2.1.5"
    Backup = $true
    Timeout = 60
}

# Passer tous les paramètres avec @
.\Deploy.ps1 @params

# Équivalent à :
.\Deploy.ps1 -ServerName "SRV-PROD-01" -Environment "Production" -Version "2.1.5" -Backup $true -Timeout 60
```

#### Splatting avec modifications dynamiques

```powershell
# Base de paramètres
$baseParams = @{
    ServerName = "SRV-01"
    DatabaseName = "CustomerDB"
    Timeout = 30
}

# Ajouter des paramètres conditionnellement
if ($needBackup) {
    $baseParams.Add('Backup', $true)
    $baseParams.Add('BackupPath', 'C:\Backups')
}

if ($isProduction) {
    $baseParams['Environment'] = 'Production'
    $baseParams['LogLevel'] = 'Verbose'
}

# Exécuter avec tous les paramètres
.\Database-Operation.ps1 @baseParams
```

> [!tip] Avantage du splatting
> 
> - Code plus lisible pour les appels avec nombreux paramètres
> - Facilite la construction dynamique de paramètres
> - Permet la réutilisation de jeux de paramètres
> - Simplifie les tests et le débogage

### Paramètres avancés

#### CmdletBinding pour comportement avancé

```powershell
# Script : Professional.ps1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Name,
    
    [Parameter(ValueFromPipeline=$true)]
    [string[]]$InputFiles
)

begin {
    Write-Verbose "Initialisation du script"
    $processedCount = 0
}

process {
    foreach ($file in $InputFiles) {
        Write-Verbose "Traitement de : $file"
        $processedCount++
    }
}

end {
    Write-Verbose "Traitement terminé : $processedCount fichiers"
}

# Exécution avec -Verbose (disponible grâce à CmdletBinding)
.\Professional.ps1 -Name "Test" -Verbose

# Utilisation du pipeline
Get-ChildItem *.txt | .\Professional.ps1 -Name "Batch"
```

#### Jeux de paramètres (Parameter Sets)

```powershell
# Script : Connect-System.ps1
param(
    # Jeu de paramètres "ByName"
    [Parameter(ParameterSetName="ByName", Mandatory=$true)]
    [string]$ComputerName,
    
    # Jeu de paramètres "ByIP"
    [Parameter(ParameterSetName="ByIP", Mandatory=$true)]
    [string]$IPAddress,
    
    # Paramètre commun aux deux jeux
    [Parameter(Mandatory=$false)]
    [PSCredential]$Credential
)

if ($PSCmdlet.ParameterSetName -eq "ByName") {
    Write-Host "Connexion par nom : $ComputerName"
} else {
    Write-Host "Connexion par IP : $IPAddress"
}

# Exécution (un seul jeu à la fois)
.\Connect-System.ps1 -ComputerName "SRV-01"      # ✅ Valide
.\Connect-System.ps1 -IPAddress "192.168.1.10"   # ✅ Valide
.\Connect-System.ps1 -ComputerName "SRV-01" -IPAddress "192.168.1.10"  # ❌ Erreur
```

### Aide et documentation

```powershell
# Script avec aide complète
<#
.SYNOPSIS
    Effectue un backup de base de données

.DESCRIPTION
    Ce script sauvegarde une base de données SQL Server avec options
    de compression et de rétention personnalisables.

.PARAMETER DatabaseName
    Nom de la base de données à sauvegarder

.PARAMETER BackupPath
    Chemin de destination du backup

.PARAMETER RetentionDays
    Nombre de jours de rétention des backups

.EXAMPLE
    .\Backup-Database.ps1 -DatabaseName "CustomerDB"
    Backup simple avec paramètres par défaut

.EXAMPLE
    .\Backup-Database.ps1 -DatabaseName "CustomerDB" -BackupPath "D:\Backups" -RetentionDays 14
    Backup avec chemin et rétention personnalisés

.NOTES
    Auteur: Votre Nom
    Version: 1.0
    Dernière modification: 2025-12-10
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$DatabaseName,
    
    [string]$BackupPath = "C:\Backups",
    
    [int]$RetentionDays = 7
)

# Afficher l'aide
Get-Help .\Backup-Database.ps1 -Full
Get-Help .\Backup-Database.ps1 -Examples
```

> [!tip] Bonnes pratiques pour les paramètres
> 
> - Toujours définir des valeurs par défaut raisonnables
> - Utiliser la validation pour éviter les erreurs
> - Documenter chaque paramètre avec l'aide
> - Préférer les switches pour les booléens simples
> - Utiliser [CmdletBinding()] pour un comportement professionnel

---

## 🌐 Exécution à distance

### Vue d'ensemble

PowerShell Remoting permet d'exécuter des commandes et scripts sur des ordinateurs distants via le protocole WS-Management (WSMan) ou SSH.

### Prérequis pour PowerShell Remoting

```powershell
# Sur la machine CIBLE (à configurer une seule fois)
Enable-PSRemoting -Force

# Vérifier le service WinRM
Get-Service WinRM

# Vérifier la configuration
Get-PSSessionConfiguration

# Tester la connectivité
Test-WSMan -ComputerName "SRV-01"
```

> [!info] Configuration automatique `Enable-PSRemoting` effectue automatiquement :
> 
> - Démarre le service WinRM
> - Configure le firewall Windows
> - Crée les endpoints de session
> - Active l'authentification

### Méthodes d'exécution à distance

#### Méthode 1 : Invoke-Command (recommandée)

```powershell
# Commande simple sur une machine distante
Invoke-Command -ComputerName "SRV-01" -ScriptBlock {
    Get-Process | Where-Object CPU -gt 100
}

# Exécuter un script local sur une machine distante
Invoke-Command -ComputerName "SRV-01" -FilePath "C:\Scripts\Maintenance.ps1"

# Sur plusieurs machines simultanément
$servers = @("SRV-01", "SRV-02", "SRV-03")
Invoke-Command -ComputerName $servers -ScriptBlock {
    Get-Service -Name "W3SVC" | Restart-Service
}
```

#### Méthode 2 : Sessions persistantes (PSSession)

```powershell
# Créer une session
$session = New-PSSession -ComputerName "SRV-01"

# Exécuter plusieurs commandes dans la même session
Invoke-Command -Session $session -ScriptBlock {
    $data = Get-Process
    $filtered = $data | Where-Object CPU -gt 50
    $filtered | Export-Csv "C:\Temp\processes.csv"
}

# Vérifier les sessions ouvertes
Get-PSSession

# Fermer la session quand terminé
Remove-PSSession -Session $session
```

> [!tip] Avantage des sessions persistantes
> 
> - Réutilisation de la connexion (plus rapide)
> - Conservation du contexte entre commandes
> - Économie de ressources pour multiples opérations
> - Variables et état préservés

#### Passage d'arguments aux scripts distants

```powershell
# Méthode 1 : Variables dans le ScriptBlock avec -ArgumentList
Invoke-Command -ComputerName "SRV-01" -ScriptBlock {
    param($ServiceName, $Action)
    Get-Service -Name $ServiceName | & $Action
} -ArgumentList "W3SVC", {Restart-Service}

# Méthode 2 : Using scope (PowerShell 3.0+)
$serviceName = "W3SVC"
$logPath = "C:\Logs\service.log"

Invoke-Command -ComputerName "SRV-01" -ScriptBlock {
    $service = Get-Service -Name $using:serviceName
    "Status de $($using:serviceName) : $($service.Status)" | 
        Out-File $using:logPath
}

# Méthode 3 : Avec un script distant
Invoke-Command -ComputerName "SRV-01" -FilePath "C:\Scripts\Deploy.ps1" `
    -ArgumentList "Production", "2.1.5", $true
```

### Exécution sur plusieurs machines

```powershell
# Liste de serveurs
$servers = @("SRV-WEB-01", "SRV-WEB-02", "SRV-WEB-03")

# Exécution parallèle sur tous les serveurs
$results = Invoke-Command -ComputerName $servers -ScriptBlock {
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        Uptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
        Memory = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)
        DiskSpace = (Get-PSDrive C).Free / 1GB
    }
} -ErrorAction SilentlyContinue

# Afficher les résultats
$results | Format-Table -AutoSize

# Sauvegarder les résultats
$results | Export-Csv "ServerStatus.csv" -NoTypeInformation
```

> [!example] Exemple : Déploiement sur ferme de serveurs
> 
> ```powershell
> # Déploiement d'une application sur plusieurs serveurs web
> $webServers = @("WEB-01", "WEB-02", "WEB-03", "WEB-04")
> $deploymentPackage = "\\FileServer\Deployments\App_v2.1.zip"
> 
> # Créer des sessions pour tous les serveurs
> $sessions = New-PSSession -ComputerName $webServers
> 
> # Copier le package sur tous les serveurs
> foreach ($session in $sessions) {
>     Copy-Item -Path $deploymentPackage -Destination "C:\Temp\" -ToSession $session
> }
> 
> # Exécuter le déploiement en parallèle
> Invoke-Command -Session $sessions -ScriptBlock {
>     Stop-Service "W3SVC"
>     Expand-Archive "C:\Temp\App_v2.1.zip" -DestinationPath "C:\inetpub\wwwroot" -Force
>     Start-Service "W3SVC"
>     Remove-Item "C:\Temp\App_v2.1.zip"
> }
> 
> # Vérifier le statut
> Invoke-Command -Session $sessions -ScriptBlock {
>     [PSCustomObject]@{
>         Server = $env:COMPUTERNAME
>         WebService = (Get-Service W3SVC).Status
>         AppVersion = (Get-Content "C:\inetpub\wwwroot\version.txt")
>     }
> }
> 
> # Nettoyer les sessions
> Remove-PSSession -Session $sessions
> ```

### Authentification et sécurité

```powershell
# Avec des credentials spécifiques
$cred = Get-Credential -UserName "DOMAIN\Admin" -Message "Entrez le mot de passe"
Invoke-Command -ComputerName "SRV-01" -Credential $cred -ScriptBlock {
    Get-EventLog -LogName System -Newest 10
}

# Utiliser CredSSP pour double-hop (délégation)
# Sur la machine locale (une seule fois)
Enable-WSManCredSSP -Role Client -DelegateComputer "SRV-01"

# Sur le serveur distant (une seule fois)
Enable-WSManCredSSP -Role Server

# Exécution avec CredSSP
Invoke-Command -ComputerName "SRV-01" -Credential $cred `
    -Authentication CredSSP -ScriptBlock {
    # Peut maintenant accéder à d'autres ressources réseau
    Get-ChildItem "\\FileServer\Shared"
}
```

> [!warning] Problème du "Double-Hop" Par défaut, les credentials ne sont pas transmis depuis la machine distante vers une troisième machine :
> 
> ```powershell
> # Ceci NE fonctionnera PAS par défaut :
> Invoke-Command -ComputerName "SRV-01" -ScriptBlock {
>     Get-ChildItem "\\FileServer\Share"  # ❌ Accès refusé
> }
> 
> # Solutions :
> # 1. Utiliser CredSSP (voir ci-dessus)
> # 2. Utiliser Resource-Based Kerberos Constrained Delegation
> # 3. Copier les fichiers localement d'abord
> ```

### Gestion des erreurs à distance

```powershell
# Gérer les erreurs par serveur
$servers = @("SRV-01", "SRV-02", "SRV-INEXISTANT")

$results = Invoke-Command -ComputerName $servers -ScriptBlock {
    Get-Service "W3SVC"
} -ErrorAction SilentlyContinue -ErrorVariable remoteErrors

# Afficher les résultats réussis
$results | Format-Table

# Afficher les erreurs
foreach ($error in $remoteErrors) {
    Write-Warning "Erreur sur $($error.TargetObject) : $($error.Exception.Message)"
}

# Avec gestion avancée
$jobs = Invoke-Command -ComputerName $servers -ScriptBlock {
    try {
        $service = Get-Service "W3SVC" -ErrorAction Stop
        [PSCustomObject]@{
            Status = "Success"
            ServiceStatus = $service.Status
            Error = $null
        }
    } catch {
        [PSCustomObject]@{
            Status = "Failed"
            ServiceStatus = $null
            Error = $_.Exception.Message
        }
    }
} -AsJob

Wait-Job $jobs
Receive-Job $jobs
```

### Exécution asynchrone (Jobs)

```powershell
# Lancer des commandes en arrière-plan
$job = Invoke-Command -ComputerName "SRV-01" -ScriptBlock {
    # Opération longue
    Start-Sleep -Seconds 60
    Get-EventLog -LogName System -Newest 1000
} -AsJob

# Vérifier le statut
Get-Job -Id $job.Id

# Attendre la fin
Wait-Job -Job $job

# Récupérer les résultats
$results = Receive-Job -Job $job

# Nettoyer
Remove-Job -Job $job
```

> [!tip] Jobs multiples simultanés
> 
> ```powershell
> # Lancer plusieurs jobs en parallèle
> $servers = @("SRV-01", "SRV-02", "SRV-03")
> $jobs = @()
> 
> foreach ($server in $servers) {
>     $job = Invoke-Command -ComputerName $server -ScriptBlock {
>         # Opération longue
>         Get-HotFix | Where-Object InstalledOn -gt (Get-Date).AddDays(-30)
>     } -AsJob -JobName "Patches_$server"
>     $jobs += $job
> }
> 
> # Attendre que tous soient terminés
> Wait-Job -Job $jobs
> 
> # Récupérer tous les résultats
> $allResults = $jobs | Receive-Job
> 
> # Nettoyer
> $jobs | Remove-Job
> ```

---

## ⏰ Planification de tâches (Task Scheduler)

### Vue d'ensemble

Le Planificateur de tâches Windows permet d'exécuter automatiquement des scripts PowerShell selon un calendrier ou en réponse à des événements.

### Méthodes de création de tâches

#### Méthode 1 : Interface graphique (taskschd.msc)

> [!info] Étapes de création manuelle
> 
> 1. Ouvrir le Planificateur de tâches : `taskschd.msc`
> 2. Actions → Créer une tâche (de base ou avancée)
> 3. Configurer le déclencheur (trigger)
> 4. Configurer l'action avec PowerShell
> 5. Définir les conditions et paramètres

#### Méthode 2 : PowerShell (recommandée)

```powershell
# Créer une action PowerShell
$action = New-ScheduledTaskAction `
    -Execute "PowerShell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File C:\Scripts\Maintenance.ps1"

# Créer un déclencheur (tous les jours à 2h00)
$trigger = New-ScheduledTaskTrigger -Daily -At 2:00AM

# Définir les paramètres
$principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2)

# Créer la tâche
Register-ScheduledTask `
    -TaskName "Maintenance Quotidienne" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Description "Tâche de maintenance quotidienne"
```

### Types de déclencheurs

```powershell
# Déclencheur quotidien
$trigger1 = New-ScheduledTaskTrigger -Daily -At "3:00AM"

# Déclencheur hebdomadaire (lundi et vendredi)
$trigger2 = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Friday -At "6:00PM"

# Déclencheur au démarrage
$trigger3 = New-ScheduledTaskTrigger -AtStartup

# Déclencheur à la connexion
$trigger4 = New-ScheduledTaskTrigger -AtLogOn -User "DOMAIN\Username"

# Déclencheur unique (une seule fois)
$trigger5 = New-ScheduledTaskTrigger -Once -At "2025-12-31 23:59"

# Déclencheur répétitif (toutes les 15 minutes)
$trigger6 = New-ScheduledTaskTrigger -Once -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes 15) `
    -RepetitionDuration (New-TimeSpan -Days 1)

# Plusieurs déclencheurs pour une même tâche
$triggers = @($trigger1, $trigger2, $trigger3)
Register-ScheduledTask -TaskName "MultiTrigger" -Action $action -Trigger $triggers
```

> [!example] Exemple : Tâche de backup quotidienne
> 
> ```powershell
> # Configuration complète d'une tâche de backup
> $taskName = "Database Backup Quotidien"
> $scriptPath = "C:\Scripts\Backup-Database.ps1"
> 
> # Action avec arguments
> $action = New-ScheduledTaskAction `
>     -Execute "PowerShell.exe" `
>     -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -DatabaseName 'CustomerDB' -BackupPath 'D:\Backups'"
> 
> # Déclencheur : tous les jours à 1h00 du matin
> $trigger = New-ScheduledTaskTrigger -Daily -At "1:00AM"
> 
> # Exécution avec compte de service
> $principal = New-ScheduledTaskPrincipal `
>     -UserId "NT AUTHORITY\SYSTEM" `
>     -LogonType ServiceAccount `
>     -RunLevel Highest
> 
> # Paramètres avancés
> $settings = New-ScheduledTaskSettingsSet `
>     -AllowStartIfOnBatteries `
>     -DontStopIfGoingOnBatteries `
>     -StartWhenAvailable `
>     -RestartCount 3 `
>     -RestartInterval (New-TimeSpan -Minutes 1) `
>     -ExecutionTimeLimit (New-TimeSpan -Hours 4)
> 
> # Créer la tâche
> Register-ScheduledTask `
>     -TaskName $taskName `
>     -Action $action `
>     -Trigger $trigger `
>     -Principal $principal `
>     -Settings $settings `
>     -Description "Backup quotidien de la base CustomerDB avec rétention de 7 jours"
> ```

### Gestion des tâches existantes

```powershell
# Lister toutes les tâches
Get-ScheduledTask

# Trouver une tâche spécifique
Get-ScheduledTask -TaskName "Maintenance*"

# Obtenir les détails d'une tâche
Get-ScheduledTask -TaskName "Maintenance Quotidienne" | Get-ScheduledTaskInfo

# Exécuter une tâche manuellement
Start-ScheduledTask -TaskName "Maintenance Quotidienne"

# Désactiver une tâche
Disable-ScheduledTask -TaskName "Maintenance Quotidienne"

# Réactiver une tâche
Enable-ScheduledTask -TaskName "Maintenance Quotidienne"

# Supprimer une tâche
Unregister-ScheduledTask -TaskName "Maintenance Quotidienne" -Confirm:$false

# Modifier une tâche existante
$task = Get-ScheduledTask -TaskName "Maintenance Quotidienne"
$task.Triggers[0].StartBoundary = (Get-Date "3:00AM").ToString("s")
Set-ScheduledTask -InputObject $task
```

### Historique et logs

```powershell
# Voir l'historique d'exécution
Get-ScheduledTaskInfo -TaskName "Maintenance Quotidienne"

# Dernière exécution
$info = Get-ScheduledTaskInfo -TaskName "Maintenance Quotidienne"
Write-Host "Dernière exécution : $($info.LastRunTime)"
Write-Host "Résultat : $($info.LastTaskResult)"
Write-Host "Prochaine exécution : $($info.NextRunTime)"

# Codes de résultat courants
# 0x0       : Succès
# 0x1       : Appel de fonction incorrect
# 0x41301   : Tâche en cours d'exécution
# 0x41303   : Tâche n'a pas encore été exécutée
```

> [!info] Logs du planificateur Les événements sont enregistrés dans : **Event Viewer → Applications and Services Logs → Microsoft → Windows → TaskScheduler**

### Bonnes pratiques pour les tâches planifiées

#### Arguments PowerShell recommandés

```powershell
# Configuration optimale pour l'exécution
$action = New-ScheduledTaskAction `
    -Execute "PowerShell.exe" `
    -Argument @"
-NoProfile 
-NonInteractive 
-ExecutionPolicy Bypass 
-WindowStyle Hidden 
-File "C:\Scripts\MonScript.ps1"
"@
```

> [!tip] Explication des arguments
> 
> - `-NoProfile` : Ne charge pas le profil utilisateur (plus rapide)
> - `-NonInteractive` : Mode non-interactif (pas d'attente de saisie)
> - `-ExecutionPolicy Bypass` : Ignore la politique d'exécution
> - `-WindowStyle Hidden` : Cache la fenêtre PowerShell
> - `-File` : Spécifie le script à exécuter

#### Logging dans les scripts planifiés

```powershell
# Script : Maintenance.ps1 (avec logging)
param(
    [string]$LogPath = "C:\Logs\Maintenance"
)

# Créer le dossier de logs si nécessaire
if (-not (Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}

# Fonction de logging
function Write-Log {
    param($Message, $Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = Join-Path $LogPath "maintenance_$(Get-Date -Format 'yyyyMMdd').log"
    "$timestamp [$Level] $Message" | Out-File -FilePath $logFile -Append
}

# Redirection des erreurs
$ErrorActionPreference = "Continue"

try {
    Write-Log "===== Début de la maintenance ====="
    
    # Votre code ici
    Write-Log "Opération 1 : Nettoyage des fichiers temporaires"
    Remove-Item "C:\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
    
    Write-Log "Opération 2 : Vérification des services"
    $services = Get-Service | Where-Object Status -eq "Stopped"
    Write-Log "Services arrêtés : $($services.Count)"
    
    Write-Log "===== Maintenance terminée avec succès =====" "SUCCESS"
    exit 0
    
} catch {
    Write-Log "ERREUR : $($_.Exception.Message)" "ERROR"
    Write-Log $_.ScriptStackTrace "ERROR"
    exit 1
}
```

#### Gestion des credentials

```powershell
# Option 1 : Exécution avec compte de service (recommandé)
$principal = New-ScheduledTaskPrincipal `
    -UserId "DOMAIN\ServiceAccount" `
    -LogonType Password `
    -RunLevel Highest

# Option 2 : Compte virtuel (pas de gestion de mot de passe)
$principal = New-ScheduledTaskPrincipal `
    -UserId "NT SERVICE\MyService" `
    -LogonType ServiceAccount

# Option 3 : Compte SYSTEM (privilèges élevés)
$principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest
```

> [!warning] Sécurité des credentials
> 
> - Ne jamais stocker de mots de passe en clair dans les scripts
> - Utiliser des comptes de service dédiés avec privilèges minimaux
> - Auditer régulièrement les tâches planifiées
> - Protéger les scripts avec des ACL appropriées

### Surveillance et maintenance

```powershell
# Script de surveillance des tâches
$tasks = Get-ScheduledTask | Where-Object State -eq "Ready"

foreach ($task in $tasks) {
    $info = Get-ScheduledTaskInfo -TaskName $task.TaskName
    
    # Vérifier si la tâche a échoué récemment
    if ($info.LastTaskResult -ne 0) {
        Write-Warning "La tâche '$($task.TaskName)' a échoué"
        Write-Warning "Code d'erreur : $($info.LastTaskResult)"
        Write-Warning "Dernière exécution : $($info.LastRunTime)"
        
        # Envoyer une alerte (email, Teams, etc.)
    }
    
    # Vérifier si la tâche est bloquée
    $runningTime = (Get-Date) - $info.LastRunTime
    if ($info.TaskState -eq "Running" -and $runningTime.TotalHours -gt 2) {
        Write-Warning "La tâche '$($task.TaskName)' semble bloquée"
        # Action corrective
    }
}
```

---

## 🔒 Droits d'exécution et sécurité

### Politique d'exécution (Execution Policy)

La politique d'exécution est un mécanisme de sécurité qui contrôle quels scripts PowerShell peuvent être exécutés.

#### Niveaux de politique

```powershell
# Voir la politique actuelle
Get-ExecutionPolicy

# Voir la politique pour tous les scopes
Get-ExecutionPolicy -List
```

|Politique|Description|Usage|
|---|---|---|
|**Restricted**|Aucun script autorisé (défaut sur clients)|Maximum de sécurité|
|**AllSigned**|Uniquement scripts signés numériquement|Environnements sécurisés|
|**RemoteSigned**|Scripts locaux OK, distants doivent être signés|Usage courant|
|**Unrestricted**|Tous scripts OK, avertissement pour distants|Développement|
|**Bypass**|Aucune restriction, aucun avertissement|Automation/CI-CD|
|**Undefined**|Pas de politique définie (hérite du parent)|-|

#### Scopes de la politique

```powershell
# Scopes disponibles (du plus spécifique au plus général)
# - Process       : Session PowerShell actuelle uniquement
# - CurrentUser   : Utilisateur actuel
# - LocalMachine  : Tous les utilisateurs de la machine

# Définir pour l'utilisateur actuel
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Définir pour la machine (nécessite admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

# Définir pour la session en cours uniquement
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

> [!example] Exemple de configuration recommandée
> 
> ```powershell
> # Configuration sécurisée pour un poste de travail
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> 
> # Vérification
> Get-ExecutionPolicy -List
> 
> # Résultat attendu :
> #         Scope ExecutionPolicy
> #         ----- ---------------
> # MachinePolicy       Undefined
> #    UserPolicy       Undefined
> #       Process       Undefined
> #   CurrentUser    RemoteSigned
> #  LocalMachine       Undefined
> ```

### Contournement temporaire de la politique

```powershell
# Méthode 1 : Bypass pour une session
powershell.exe -ExecutionPolicy Bypass -File "C:\Scripts\MonScript.ps1"

# Méthode 2 : Bypass pour un processus
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File C:\Scripts\MonScript.ps1"

# Méthode 3 : Lecture du contenu puis exécution
Get-Content "C:\Scripts\MonScript.ps1" | PowerShell.exe -NoProfile -

# Méthode 4 : Depuis une commande
PowerShell.exe -Command "& {Get-Process}"
```

> [!warning] Attention Le contournement de la politique d'exécution doit être utilisé avec précaution et uniquement pour des scripts de confiance. C'est une mesure de sécurité, pas une protection absolue.

### Déblocage de scripts téléchargés

```powershell
# Windows marque les fichiers téléchargés avec un "Zone Identifier"
# Pour exécuter un script téléchargé avec RemoteSigned :

# Débloquer un script spécifique
Unblock-File -Path "C:\Scripts\Downloaded.ps1"

# Débloquer tous les scripts d'un dossier
Get-ChildItem "C:\Scripts" -Recurse -Filter "*.ps1" | Unblock-File

# Vérifier si un fichier est bloqué
Get-Item "C:\Scripts\Downloaded.ps1" -Stream Zone.Identifier -ErrorAction SilentlyContinue
```

> [!tip] Automatisation du déblocage
> 
> ```powershell
> # Script pour débloquer automatiquement après téléchargement
> $downloadPath = "$env:USERPROFILE\Downloads"
> $scriptsToUnblock = Get-ChildItem $downloadPath -Filter "*.ps1" -Recurse
> 
> foreach ($script in $scriptsToUnblock) {
>     Write-Host "Déblocage de : $($script.Name)"
>     Unblock-File -Path $script.FullName
> }
> ```

### Signature numérique de scripts

La signature de scripts garantit l'authenticité et l'intégrité du code.

#### Obtenir un certificat de signature

```powershell
# Option 1 : Créer un certificat auto-signé (développement)
$cert = New-SelfSignedCertificate `
    -Subject "CN=PowerShell Code Signing" `
    -Type CodeSigningCert `
    -CertStoreLocation Cert:\CurrentUser\My

# Option 2 : Utiliser un certificat d'une autorité
# (Acheter auprès de DigiCert, GlobalSign, etc.)

# Voir les certificats de signature disponibles
Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
```

#### Signer un script

```powershell
# Obtenir le certificat
$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert | 
    Select-Object -First 1

# Signer le script
Set-AuthenticodeSignature -FilePath "C:\Scripts\MonScript.ps1" -Certificate $cert

# Vérifier la signature
Get-AuthenticodeSignature -FilePath "C:\Scripts\MonScript.ps1"

# Signer tous les scripts d'un dossier
Get-ChildItem "C:\Scripts" -Filter "*.ps1" -Recurse | 
    ForEach-Object {
        Set-AuthenticodeSignature -FilePath $_.FullName -Certificate $cert
    }
```

> [!info] Structure d'un script signé Un script signé contient un bloc de signature à la fin :
> 
> ```powershell
> # Votre code ici
> Write-Host "Script signé"
> 
> # SIG # Begin signature block
> # MIIFfwYJKoZIhvcNAQcCoIIFcDCCBWwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
> # ... (signature encodée en Base64) ...
> # SIG # End signature block
> ```

#### Validation des signatures

```powershell
# Vérifier une signature
$signature = Get-AuthenticodeSignature -FilePath "C:\Scripts\MonScript.ps1"

# Vérifier le statut
switch ($signature.Status) {
    "Valid" {
        Write-Host "✅ Signature valide" -ForegroundColor Green
        Write-Host "Signé par : $($signature.SignerCertificate.Subject)"
    }
    "NotSigned" {
        Write-Host "⚠️ Script non signé" -ForegroundColor Yellow
    }
    "HashMismatch" {
        Write-Host "❌ Script modifié après signature !" -ForegroundColor Red
    }
    "NotTrusted" {
        Write-Host "⚠️ Certificat non approuvé" -ForegroundColor Yellow
    }
}
```

### Permissions NTFS sur les scripts

```powershell
# Vérifier les permissions actuelles
Get-Acl "C:\Scripts\MonScript.ps1" | Format-List

# Voir les permissions détaillées
(Get-Acl "C:\Scripts\MonScript.ps1").Access | Format-Table IdentityReference, FileSystemRights, AccessControlType

# Définir des permissions restrictives (lecture seule pour utilisateurs)
$acl = Get-Acl "C:\Scripts\MonScript.ps1"

# Désactiver l'héritage
$acl.SetAccessRuleProtection($true, $false)

# Supprimer toutes les règles existantes
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) }

# Ajouter permissions pour Administrateurs (contrôle total)
$adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "BUILTIN\Administrators",
    "FullControl",
    "Allow"
)
$acl.AddAccessRule($adminRule)

# Ajouter permissions pour utilisateurs (lecture et exécution)
$userRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "BUILTIN\Users",
    "ReadAndExecute",
    "Allow"
)
$acl.AddAccessRule($userRule)

# Appliquer les permissions
Set-Acl -Path "C:\Scripts\MonScript.ps1" -AclObject $acl
```

> [!example] Exemple : Sécuriser un dossier de scripts
> 
> ```powershell
> # Sécuriser tous les scripts d'un dossier
> $scriptFolder = "C:\Scripts\Production"
> 
> # Permissions souhaitées
> $permissions = @(
>     @{
>         Identity = "BUILTIN\Administrators"
>         Rights = "FullControl"
>     },
>     @{
>         Identity = "DOMAIN\ScriptExecutors"
>         Rights = "ReadAndExecute"
>     },
>     @{
>         Identity = "DOMAIN\ScriptDevelopers"
>         Rights = "Modify"
>     }
> )
> 
> # Appliquer à tous les fichiers .ps1
> Get-ChildItem $scriptFolder -Filter "*.ps1" -Recurse | ForEach-Object {
>     $acl = Get-Acl $_.FullName
>     $acl.SetAccessRuleProtection($true, $false)
>     $acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) }
>     
>     foreach ($perm in $permissions) {
>         $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
>             $perm.Identity,
>             $perm.Rights,
>             "Allow"
>         )
>         $acl.AddAccessRule($rule)
>     }
>     
>     Set-Acl -Path $_.FullName -AclObject $acl
>     Write-Host "Sécurisé : $($_.Name)"
> }
> ```

### Contrôle d'accès basé sur les rôles (RBAC)

```powershell
# Vérifier l'appartenance à un groupe
function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    return $principal.IsInRole($adminRole)
}

# Utilisation dans un script
if (-not (Test-AdminRights)) {
    Write-Error "Ce script nécessite des droits administrateur"
    exit 1
}

# Vérifier l'appartenance à un groupe spécifique
function Test-GroupMembership {
    param([string]$GroupName)
    
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    
    try {
        $group = [System.Security.Principal.NTAccount]$GroupName
        return $principal.IsInRole($group)
    } catch {
        return $false
    }
}

# Exemple d'utilisation
if (-not (Test-GroupMembership "DOMAIN\DBAdmins")) {
    Write-Error "Accès refusé. Vous devez être membre du groupe DBAdmins"
    exit 1
}
```

### Élévation de privilèges (Run as Administrator)

```powershell
# Vérifier si le script s'exécute en mode élevé
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Ce script nécessite des privilèges administrateur"
    
    # Relancer le script avec élévation
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process PowerShell.exe -Verb RunAs -ArgumentList $arguments
    exit
}

# Le reste du script s'exécute avec privilèges élevés
Write-Host "Script s'exécutant avec privilèges administrateur"
```

> [!tip] Pattern de relance automatique
> 
> ```powershell
> # En-tête standard pour scripts nécessitant élévation
> #Requires -RunAsAdministrator
> 
> # Ou avec gestion manuelle :
> param(
>     [switch]$Elevated
> )
> 
> function Test-Administrator {
>     $user = [Security.Principal.WindowsIdentity]::GetCurrent()
>     $principal = New-Object Security.Principal.WindowsPrincipal($user)
>     return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
> }
> 
> if (-not (Test-Administrator)) {
>     if (-not $Elevated) {
>         Write-Host "Relance avec élévation..."
>         $newProcess = Start-Process PowerShell.exe `
>             -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevated" `
>             -Verb RunAs `
>             -PassThru
>         exit
>     } else {
>         Write-Error "Impossible d'obtenir les privilèges administrateur"
>         exit 1
>     }
> }
> 
> # Code principal avec privilèges élevés
> ```

### Journalisation et audit

```powershell
# Activer la transcription automatique
Start-Transcript -Path "C:\Logs\PowerShell\Session_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Votre code ici
Write-Host "Opérations effectuées..."

# Arrêter la transcription
Stop-Transcript

# ═══════════════════════════════════════════════════════════
# Configuration permanente de la transcription
# ═══════════════════════════════════════════════════════════

# Via GPO ou registre pour tous les utilisateurs
$transcriptPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription"

if (-not (Test-Path $transcriptPath)) {
    New-Item -Path $transcriptPath -Force
}

Set-ItemProperty -Path $transcriptPath -Name "EnableTranscripting" -Value 1
Set-ItemProperty -Path $transcriptPath -Name "OutputDirectory" -Value "C:\Logs\PowerShell"
Set-ItemProperty -Path $transcriptPath -Name "EnableInvocationHeader" -Value 1
```

#### Module Logging (Script Block Logging)

```powershell
# Activer le logging des blocs de script (audit détaillé)
$logPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"

if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -Force
}

Set-ItemProperty -Path $logPath -Name "EnableScriptBlockLogging" -Value 1
Set-ItemProperty -Path $logPath -Name "EnableScriptBlockInvocationLogging" -Value 1

# Les événements sont enregistrés dans :
# Event Viewer → Applications and Services Logs → Microsoft → Windows → PowerShell → Operational
```

> [!info] Types de logs PowerShell
> 
> 1. **Transcription** : Enregistre toutes les entrées/sorties de console
> 2. **Script Block Logging** : Enregistre l'exécution de chaque bloc de code
> 3. **Module Logging** : Enregistre l'utilisation de modules spécifiques
> 4. **Over-the-Shoulder Transcription** : Transcription protégée contre modification

### Protection contre l'exécution malveillante

#### Constrained Language Mode

```powershell
# Vérifier le mode de langage actuel
$ExecutionContext.SessionState.LanguageMode

# Modes disponibles :
# - FullLanguage        : Accès complet (par défaut)
# - ConstrainedLanguage : Restrictions de sécurité
# - RestrictedLanguage  : Très limité
# - NoLanguage          : Aucune commande autorisée

# Définir en mode contraint (nécessite configuration système)
# Via AppLocker ou Device Guard
```

#### Application Whitelisting

```powershell
# Vérifier si AppLocker est actif
Get-AppLockerPolicy -Effective

# Créer une règle AppLocker pour PowerShell
$rule = New-AppLockerPolicy -RuleType Publisher `
    -Path "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -User "Everyone" `
    -RuleNamePrefix "AllowPowerShell"

# Appliquer la politique (nécessite GPO en production)
Set-AppLockerPolicy -PolicyObject $rule
```

### Bonnes pratiques de sécurité

> [!tip] Checklist de sécurité pour scripts PowerShell
> 
> **Avant le déploiement :**
> 
> - ✅ Utiliser `Set-StrictMode -Version Latest` pour détecter les erreurs
> - ✅ Valider toutes les entrées utilisateur
> - ✅ Ne jamais stocker de credentials en clair
> - ✅ Utiliser des chemins absolus ou `$PSScriptRoot`
> - ✅ Implémenter une gestion d'erreurs robuste (`try/catch`)
> - ✅ Documenter les permissions requises
> - ✅ Tester avec un compte non-privilégié
> 
> **Pour la production :**
> 
> - ✅ Signer numériquement les scripts
> - ✅ Définir ExecutionPolicy à RemoteSigned minimum
> - ✅ Appliquer des permissions NTFS restrictives
> - ✅ Activer la transcription et le logging
> - ✅ Auditer régulièrement les scripts
> - ✅ Versionner les scripts (Git, SVN)
> - ✅ Séparer les credentials de la logique

#### Gestion sécurisée des credentials

```powershell
# ❌ MAUVAISE PRATIQUE - Ne jamais faire ceci
$username = "admin"
$password = "P@ssw0rd123"
$cred = New-Object System.Management.Automation.PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))

# ✅ BONNE PRATIQUE - Utiliser Get-Credential
$cred = Get-Credential -Message "Entrez vos identifiants"

# ✅ Stocker de manière sécurisée (chiffré pour l'utilisateur actuel)
$cred | Export-Clixml -Path "C:\Secure\cred.xml"

# Réutiliser plus tard
$cred = Import-Clixml -Path "C:\Secure\cred.xml"

# ✅ Utiliser Windows Credential Manager
Install-Module CredentialManager -Force
New-StoredCredential -Target "MonApp" -UserName "admin" -Password "P@ssw0rd123" -Persist LocalMachine

# Récupérer depuis Credential Manager
$cred = Get-StoredCredential -Target "MonApp"

# ✅ Utiliser Azure Key Vault (environnements cloud)
Install-Module Az.KeyVault
$secret = Get-AzKeyVaultSecret -VaultName "MonVault" -Name "AdminPassword"
$cred = New-Object System.Management.Automation.PSCredential("admin", $secret.SecretValue)
```

#### Validation des entrées

```powershell
# Script avec validation stricte
param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServerName,
    
    [Parameter(Mandatory=$true)]
    [ValidateRange(1, 65535)]
    [int]$Port,
    
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        if (Test-Connection -ComputerName $_ -Count 1 -Quiet) {
            $true
        } else {
            throw "Le serveur $_ n'est pas accessible"
        }
    })]
    [string]$TargetServer
)

# Nettoyer les entrées utilisateur
function Sanitize-Input {
    param([string]$Input)
    
    # Supprimer les caractères dangereux
    $sanitized = $Input -replace '[<>:"/\\|?*]', ''
    
    # Limiter la longueur
    if ($sanitized.Length -gt 255) {
        $sanitized = $sanitized.Substring(0, 255)
    }
    
    return $sanitized
}

# Éviter l'injection de commandes
$userInput = Sanitize-Input -Input $args[0]
# N'UTILISEZ JAMAIS : Invoke-Expression $userInput
```

> [!warning] Dangers d'Invoke-Expression
> 
> ```powershell
> # ❌ DANGEREUX - Ne jamais utiliser avec input utilisateur
> $userCommand = Read-Host "Entrez une commande"
> Invoke-Expression $userCommand  # Peut exécuter N'IMPORTE QUOI !
> 
> # ✅ SÉCURISÉ - Utiliser des alternatives
> switch ($userCommand) {
>     "status" { Get-Service }
>     "disk" { Get-PSDrive }
>     default { Write-Error "Commande non autorisée" }
> }
> ```

### Audit et conformité

```powershell
# Script d'audit de sécurité PowerShell
function Invoke-SecurityAudit {
    $report = @()
    
    # Vérifier la politique d'exécution
    $execPolicy = Get-ExecutionPolicy -List
    $report += [PSCustomObject]@{
        Check = "Execution Policy"
        CurrentUser = ($execPolicy | Where-Object Scope -eq "CurrentUser").ExecutionPolicy
        LocalMachine = ($execPolicy | Where-Object Scope -eq "LocalMachine").ExecutionPolicy
        Recommendation = "RemoteSigned ou AllSigned"
    }
    
    # Vérifier si la transcription est activée
    $transcriptionKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription"
    $transcriptionEnabled = $false
    if (Test-Path $transcriptionKey) {
        $transcriptionEnabled = (Get-ItemProperty -Path $transcriptionKey -Name "EnableTranscripting" -ErrorAction SilentlyContinue).EnableTranscripting -eq 1
    }
    $report += [PSCustomObject]@{
        Check = "Transcription Logging"
        Status = if ($transcriptionEnabled) { "Activé" } else { "Désactivé" }
        Recommendation = "Activé en production"
    }
    
    # Vérifier Script Block Logging
    $scriptBlockKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
    $scriptBlockEnabled = $false
    if (Test-Path $scriptBlockKey) {
        $scriptBlockEnabled = (Get-ItemProperty -Path $scriptBlockKey -Name "EnableScriptBlockLogging" -ErrorAction SilentlyContinue).EnableScriptBlockLogging -eq 1
    }
    $report += [PSCustomObject]@{
        Check = "Script Block Logging"
        Status = if ($scriptBlockEnabled) { "Activé" } else { "Désactivé" }
        Recommendation = "Activé pour audit complet"
    }
    
    # Vérifier les scripts non signés dans le dossier Scripts
    $unsignedScripts = Get-ChildItem "C:\Scripts" -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue | 
        Where-Object { (Get-AuthenticodeSignature $_.FullName).Status -ne "Valid" }
    
    $report += [PSCustomObject]@{
        Check = "Scripts non signés"
        Count = $unsignedScripts.Count
        Recommendation = "Signer tous les scripts en production"
    }
    
    return $report
}

# Exécuter l'audit
$auditResults = Invoke-SecurityAudit
$auditResults | Format-Table -AutoSize

# Exporter le rapport
$auditResults | Export-Csv "C:\Logs\PowerShell_SecurityAudit_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
```

---

## 📚 Récapitulatif

### Points clés à retenir

> [!tip] Exécution de base
> 
> - Toujours utiliser `.\` pour les scripts du répertoire courant
> - Utiliser `&` pour exécuter depuis des variables ou avec des espaces
> - Préférer les chemins absolus dans les tâches planifiées
> - Utiliser `$PSScriptRoot` pour les chemins relatifs au script

> [!tip] Dot Sourcing
> 
> - Utiliser `. .\script.ps1` pour charger des fonctions et variables
> - Idéal pour les bibliothèques de fonctions
> - Attention aux collisions de noms
> - Ne pas utiliser pour les scripts qui modifient l'environnement

> [!tip] Paramètres
> 
> - Définir des paramètres typés avec validation
> - Documenter avec l'aide (`<#...#>`)
> - Utiliser le splatting pour les appels complexes
> - Valider toutes les entrées utilisateur

> [!tip] Exécution à distance
> 
> - Utiliser `Invoke-Command` pour l'exécution ponctuelle
> - Utiliser `New-PSSession` pour les sessions persistantes
> - Attention au problème du double-hop
> - Gérer les erreurs par machine

> [!tip] Planification
> 
> - Utiliser PowerShell pour créer les tâches (reproductible)
> - Toujours inclure du logging dans les scripts planifiés
> - Utiliser des comptes de service dédiés
> - Surveiller l'historique d'exécution régulièrement

> [!tip] Sécurité
> 
> - Définir ExecutionPolicy à RemoteSigned minimum
> - Signer les scripts en production
> - Protéger les scripts avec des permissions NTFS
> - Activer la transcription et le logging
> - Ne jamais stocker de credentials en clair
> - Valider toutes les entrées utilisateur

### Commandes essentielles

```powershell
# Exécution
.\Script.ps1
& "C:\Path With Spaces\Script.ps1"
. .\Functions.ps1

# Remoting
Invoke-Command -ComputerName SRV -ScriptBlock { }
New-PSSession -ComputerName SRV
Enter-PSSession -ComputerName SRV

# Planification
New-ScheduledTaskTrigger -Daily -At 2:00AM
Register-ScheduledTask -TaskName "Task" -Action $action -Trigger $trigger
Get-ScheduledTask | Where-Object State -eq "Running"

# Sécurité
Get-ExecutionPolicy -List
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Unblock-File -Path .\Script.ps1
Set-AuthenticodeSignature -FilePath .\Script.ps1 -Certificate $cert
Get-Acl .\Script.ps1
```

---

## 🎯 Patterns courants

### Pattern : Script avec logging complet

```powershell
<#
.SYNOPSIS
    Template de script avec logging et gestion d'erreurs
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Environment,
    
    [string]$LogPath = "C:\Logs"
)

# Configuration
$ErrorActionPreference = "Stop"
$scriptName = $MyInvocation.MyCommand.Name
$logFile = Join-Path $LogPath "${scriptName}_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Fonction de logging
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$Level] $Message"
    
    # Écrire dans le fichier
    $logMessage | Out-File -FilePath $logFile -Append
    
    # Afficher en console avec couleur
    $color = switch ($Level) {
        "INFO" { "White" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        "SUCCESS" { "Green" }
    }
    Write-Host $logMessage -ForegroundColor $color
}

# Démarrer la transcription
Start-Transcript -Path "$LogPath\${scriptName}_transcript.log" -Append

try {
    Write-Log "===== Début du script ====="
    Write-Log "Environnement : $Environment"
    
    # Votre logique ici
    Write-Log "Opération 1 : En cours..." "INFO"
    # ...
    Write-Log "Opération 1 : Terminée" "SUCCESS"
    
    Write-Log "===== Script terminé avec succès =====" "SUCCESS"
    exit 0
    
} catch {
    Write-Log "ERREUR FATALE : $($_.Exception.Message)" "ERROR"
    Write-Log "Ligne : $($_.InvocationInfo.ScriptLineNumber)" "ERROR"
    Write-Log "Commande : $($_.InvocationInfo.Line)" "ERROR"
    exit 1
    
} finally {
    Stop-Transcript
}
```

### Pattern : Script exécutable à distance

```powershell
<#
.SYNOPSIS
    Script compatible exécution locale et distante
#>

param(
    [string[]]$ComputerName = $env:COMPUTERNAME,
    [PSCredential]$Credential
)

$scriptBlock = {
    param($Param1, $Param2)
    
    # Logique métier ici
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        Result = "Succès"
        Timestamp = Get-Date
    }
}

# Paramètres pour le script block
$params = @{
    Param1 = "Valeur1"
    Param2 = "Valeur2"
}

if ($ComputerName -eq $env:COMPUTERNAME) {
    # Exécution locale
    & $scriptBlock @params
} else {
    # Exécution distante
    $invokeParams = @{
        ComputerName = $ComputerName
        ScriptBlock = $scriptBlock
        ArgumentList = $params.Values
    }
    
    if ($Credential) {
        $invokeParams.Credential = $Credential
    }
    
    Invoke-Command @invokeParams
}
```

### Pattern : Tâche planifiée auto-installante

```powershell
<#
.SYNOPSIS
    Script qui crée sa propre tâche planifiée
#>

param(
    [switch]$Install,
    [switch]$Uninstall
)

$taskName = "Maintenance Automatique"
$scriptPath = $PSCommandPath

if ($Install) {
    Write-Host "Installation de la tâche planifiée..."
    
    $action = New-ScheduledTaskAction `
        -Execute "PowerShell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    
    $trigger = New-ScheduledTaskTrigger -Daily -At "2:00AM"
    
    $principal = New-ScheduledTaskPrincipal `
        -UserId "SYSTEM" `
        -LogonType ServiceAccount `
        -RunLevel Highest
    
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable
    
    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Force
    
    Write-Host "Tâche installée avec succès !" -ForegroundColor Green
    exit 0
}

if ($Uninstall) {
    Write-Host "Désinstallation de la tâche planifiée..."
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "Tâche désinstallée !" -ForegroundColor Green
    exit 0
}

# Logique normale du script
Write-Host "Exécution de la maintenance..."
# Votre code ici
```

---

**Fin du cours - Exécution de Scripts en PowerShell** 🎓