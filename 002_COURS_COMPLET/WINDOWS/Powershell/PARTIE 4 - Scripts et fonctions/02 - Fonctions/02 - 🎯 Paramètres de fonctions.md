

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

## 🌟 Introduction

Les paramètres de fonctions en PowerShell permettent de créer des fonctions réutilisables et flexibles. Contrairement aux scripts autonomes, les fonctions sont chargées en mémoire et peuvent être appelées plusieurs fois dans une même session. La gestion des paramètres est donc cruciale pour créer des fonctions professionnelles et maintenables.

> [!info] Pourquoi utiliser des paramètres dans les fonctions ?
> 
> - **Réutilisabilité** : Une même fonction peut traiter différentes données
> - **Clarté** : Les paramètres documentent les entrées attendues
> - **Validation** : PowerShell peut vérifier automatiquement les types et valeurs
> - **Flexibilité** : Support de valeurs par défaut, paramètres optionnels, etc.

---

## 📦 Le bloc param()

Le bloc `param()` est la méthode recommandée pour déclarer les paramètres d'une fonction. Il doit toujours être placé en premier dans le corps de la fonction, juste après l'accolade ouvrante.

### Structure de base

```powershell
function Nom-Fonction {
    param(
        [Type]$Parametre1,
        [Type]$Parametre2 = "ValeurParDefaut",
        [Type]$Parametre3
    )
    
    # Corps de la fonction
}
```

### Exemple concret

```powershell
function Get-UserInfo {
    param(
        [string]$UserName,
        [string]$Domain = "CONTOSO",
        [int]$MaxResults = 10
    )
    
    Write-Host "Recherche de $UserName dans le domaine $Domain"
    Write-Host "Limite : $MaxResults résultats"
}

# Appels possibles
Get-UserInfo -UserName "jdupont"
Get-UserInfo -UserName "jdupont" -Domain "FABRIKAM"
Get-UserInfo -UserName "jdupont" -MaxResults 20
```

> [!example] Déclaration avec attributs
> 
> ```powershell
> function Send-Report {
>     param(
>         [Parameter(Mandatory=$true)]
>         [string]$EmailTo,
>         
>         [Parameter(Mandatory=$false)]
>         [ValidateSet("PDF", "HTML", "CSV")]
>         [string]$Format = "PDF",
>         
>         [switch]$IncludeCharts
>     )
>     
>     Write-Host "Envoi du rapport au format $Format vers $EmailTo"
>     if ($IncludeCharts) {
>         Write-Host "Avec graphiques inclus"
>     }
> }
> ```

### Placement du bloc param()

> [!warning] Position obligatoire Le bloc `param()` doit TOUJOURS être le premier élément du corps de la fonction. Aucun code ne peut le précéder (sauf les commentaires d'aide).

```powershell
# ✅ CORRECT
function Get-Data {
    param([string]$Path)
    $content = Get-Content $Path
    return $content
}

# ❌ INCORRECT
function Get-Data {
    $date = Get-Date  # Code avant param()
    param([string]$Path)  # ERREUR !
    return Get-Content $Path
}

# ✅ CORRECT avec commentaire d'aide
function Get-Data {
    <#
    .SYNOPSIS
    Récupère des données
    #>
    param([string]$Path)
    return Get-Content $Path
}
```

---

## 🔄 Paramètres positionnels vs nommés

PowerShell supporte deux façons de passer des arguments aux fonctions : par position ou par nom.

### Paramètres positionnels

Par défaut, les paramètres peuvent être passés dans l'ordre de déclaration sans spécifier leur nom.

```powershell
function Copy-FileWithLog {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$LogPath = "C:\Logs\copy.log"
    )
    
    Copy-Item $Source $Destination
    Add-Content $LogPath "Copié : $Source -> $Destination"
}

# Appel positionnel (dans l'ordre)
Copy-FileWithLog "C:\file.txt" "D:\backup\file.txt"

# Appel nommé (dans n'importe quel ordre)
Copy-FileWithLog -Destination "D:\backup\file.txt" -Source "C:\file.txt"

# Mixte
Copy-FileWithLog "C:\file.txt" -LogPath "C:\custom.log" -Destination "D:\backup\file.txt"
```

### Contrôler la position des paramètres

```powershell
function New-User {
    param(
        [Parameter(Position=0)]
        [string]$FirstName,
        
        [Parameter(Position=1)]
        [string]$LastName,
        
        [Parameter(Position=2)]
        [string]$Email
    )
    
    Write-Host "Création de l'utilisateur : $FirstName $LastName ($Email)"
}

# Appel positionnel explicite
New-User "Jean" "Dupont" "jean.dupont@contoso.com"
```

### Désactiver les paramètres positionnels

```powershell
function Remove-UserAccount {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        
        [switch]$Force
    )
    
    # Cette fonction EXIGE des paramètres nommés
    Write-Host "Suppression du compte : $UserName"
}

# ❌ ERREUR - paramètre positionnel non autorisé
# Remove-UserAccount "jdupont"

# ✅ CORRECT
Remove-UserAccount -UserName "jdupont" -Force
```

> [!tip] Quand utiliser les paramètres positionnels ?
> 
> - **Utilisez positionnels** : pour 1-3 paramètres évidents et fréquemment utilisés
> - **Privilégiez nommés** : pour les fonctions avec beaucoup de paramètres ou des paramètres ambigus
> - **Désactivez positionnels** : pour les actions critiques (suppression, modification) où la clarté est essentielle

|Aspect|Positionnels|Nommés|
|---|---|---|
|Syntaxe|Plus courte|Plus explicite|
|Lisibilité|Bonne si peu de paramètres|Toujours claire|
|Maintenance|Fragile si ordre change|Robuste|
|Usage recommandé|Commandes simples et fréquentes|Commandes complexes ou critiques|

---

## 🔗 Application des concepts de paramètres de scripts

Tous les concepts de paramètres utilisés dans les scripts PowerShell s'appliquent également aux fonctions.

### Attributs Parameter

```powershell
function Set-ServerConfig {
    param(
        # Paramètre obligatoire
        [Parameter(Mandatory=$true)]
        [string]$ServerName,
        
        # Paramètre obligatoire avec message personnalisé
        [Parameter(Mandatory=$true, HelpMessage="Entrez le chemin du fichier de config")]
        [string]$ConfigPath,
        
        # Paramètre avec validation
        [Parameter(Mandatory=$false)]
        [ValidateRange(1, 100)]
        [int]$MaxConnections = 50,
        
        # Paramètre qui accepte l'input pipeline
        [Parameter(ValueFromPipeline=$true)]
        [string]$ComputerName
    )
    
    process {
        Write-Host "Configuration de $ServerName"
        Write-Host "Fichier : $ConfigPath"
        Write-Host "Max connexions : $MaxConnections"
    }
}
```

### Validation des paramètres

Tous les attributs de validation fonctionnent dans les fonctions :

```powershell
function New-NetworkShare {
    param(
        # Validation de pattern
        [ValidatePattern('^\\\\[a-zA-Z0-9]+\\[a-zA-Z0-9]+$')]
        [string]$SharePath,
        
        # Validation d'ensemble
        [ValidateSet("Read", "Write", "FullControl")]
        [string]$Permission = "Read",
        
        # Validation de longueur
        [ValidateLength(1, 15)]
        [string]$ShareName,
        
        # Validation de script personnalisé
        [ValidateScript({
            Test-Path $_ -PathType Container
        })]
        [string]$LocalPath,
        
        # Validation de plage
        [ValidateRange(1, 1000)]
        [int]$MaxUsers = 100,
        
        # Validation non-null/non-vide
        [ValidateNotNullOrEmpty()]
        [string]$Description
    )
    
    Write-Host "Création du partage $ShareName"
}
```

### Types de paramètres avancés

```powershell
function Process-Data {
    param(
        # Switch parameter (booléen)
        [switch]$Verbose,
        
        # Tableau
        [string[]]$Computers = @("Server01", "Server02"),
        
        # Hashtable
        [hashtable]$Settings = @{},
        
        # Type .NET spécifique
        [System.IO.FileInfo]$InputFile,
        
        # Type nullable
        [Nullable[int]]$Timeout,
        
        # PSCredential
        [System.Management.Automation.PSCredential]$Credential
    )
    
    if ($Verbose) {
        Write-Host "Mode verbose activé"
    }
    
    foreach ($computer in $Computers) {
        Write-Host "Traitement de $computer"
    }
}
```

### Paramètres dynamiques

> [!info] Les paramètres dynamiques permettent d'ajouter des paramètres conditionnellement en fonction d'autres paramètres ou du contexte d'exécution. Ils sont mentionnés ici pour référence mais leur implémentation avancée dépasse le périmètre de cette section.

```powershell
function Get-ServiceInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("Local", "Remote")]
        [string]$Target,
        
        [string]$ServiceName
    )
    
    # Si Target="Remote", un paramètre -ComputerName serait ajouté dynamiquement
    # (Implémentation via DynamicParam{} - concept avancé)
}
```

---

## 🎲 La variable automatique $args

La variable `$args` est un tableau automatique qui contient tous les arguments non déclarés passés à une fonction. Elle est utile pour des fonctions simples ou pour transmettre des arguments à d'autres commandes.

### Utilisation de base

```powershell
function Write-ColoredText {
    # Pas de bloc param() - tous les arguments vont dans $args
    Write-Host $args -ForegroundColor Cyan
}

Write-ColoredText "Bonjour" "le" "monde"
# Affiche : Bonjour le monde (en cyan)

# $args contient : @("Bonjour", "le", "monde")
```

### Accès aux éléments de $args

```powershell
function Show-Arguments {
    Write-Host "Nombre d'arguments : $($args.Count)"
    Write-Host "Premier argument : $($args[0])"
    Write-Host "Dernier argument : $($args[-1])"
    
    Write-Host "`nTous les arguments :"
    for ($i = 0; $i -lt $args.Count; $i++) {
        Write-Host "  [$i] = $($args[$i])"
    }
}

Show-Arguments "alpha" "beta" "gamma"
# Affiche :
# Nombre d'arguments : 3
# Premier argument : alpha
# Dernier argument : gamma
# 
# Tous les arguments :
#   [0] = alpha
#   [1] = beta
#   [2] = gamma
```

### Combinaison param() et $args

Les paramètres déclarés sont extraits en premier, le reste va dans `$args` :

```powershell
function Copy-MultipleFiles {
    param(
        [string]$Destination
    )
    
    Write-Host "Destination : $Destination"
    Write-Host "Fichiers à copier :"
    
    foreach ($file in $args) {
        Write-Host "  - $file"
        # Copy-Item $file $Destination
    }
}

Copy-MultipleFiles -Destination "C:\Backup" "file1.txt" "file2.txt" "file3.txt"
# Destination : C:\Backup
# Fichiers à copier :
#   - file1.txt
#   - file2.txt
#   - file3.txt
```

### Transmission d'arguments à d'autres commandes

Un cas d'usage courant est de créer des wrappers autour de commandes existantes :

```powershell
function Invoke-CommandWithLogging {
    param(
        [string]$LogFile = "C:\Logs\commands.log"
    )
    
    # $args contient la commande et ses arguments
    $commandString = $args -join " "
    Add-Content $LogFile "$(Get-Date) - Exécution : $commandString"
    
    # Exécute la commande avec tous ses arguments
    & $args[0] $args[1..($args.Count-1)]
}

# Exemple d'utilisation
Invoke-CommandWithLogging Get-Process -Name "powershell"
# Log : 12/10/2025 10:30:00 - Exécution : Get-Process -Name powershell
# Puis exécute : Get-Process -Name "powershell"
```

### Splatting de $args

```powershell
function Invoke-WithRetry {
    param(
        [int]$MaxAttempts = 3
    )
    
    $attempt = 1
    $success = $false
    
    while (-not $success -and $attempt -le $MaxAttempts) {
        try {
            Write-Host "Tentative $attempt/$MaxAttempts..."
            # Splatte tous les arguments restants vers la commande
            & $args[0] @args[1..($args.Count-1)]
            $success = $true
        }
        catch {
            Write-Warning "Échec : $_"
            $attempt++
            Start-Sleep -Seconds 2
        }
    }
}

# Utilisation
Invoke-WithRetry -MaxAttempts 5 Test-Connection "www.google.com" -Count 1
```

> [!warning] Limitations de $args
> 
> - **Pas de validation automatique** : Aucune vérification de type ou de valeur
> - **Pas de documentation** : Les utilisateurs ne savent pas quels arguments sont attendus
> - **Pas d'IntelliSense** : Aucune aide contextuelle dans l'éditeur
> - **Maintenance difficile** : Le code est moins explicite
> 
> **Utilisez $args uniquement pour** :
> 
> - Des fonctions très simples
> - Des wrappers qui transmettent des arguments
> - Du code jetable ou des prototypes rapides

---

## 🎯 Splatting de paramètres

Le splatting est une technique qui permet de passer plusieurs paramètres à une fonction en utilisant une hashtable ou un tableau au lieu de les lister individuellement. Le symbole `@` remplace le `$` pour indiquer le splatting.

### Splatting avec une Hashtable

La méthode la plus courante utilise une hashtable pour les paramètres nommés :

```powershell
function New-ServerBackup {
    param(
        [string]$ServerName,
        [string]$BackupPath,
        [string]$BackupType = "Full",
        [switch]$Compress,
        [switch]$Verify
    )
    
    Write-Host "Sauvegarde de $ServerName"
    Write-Host "Destination : $BackupPath"
    Write-Host "Type : $BackupType"
    Write-Host "Compression : $Compress"
    Write-Host "Vérification : $Verify"
}

# Sans splatting (verbeux)
New-ServerBackup -ServerName "SQL01" -BackupPath "D:\Backups" -BackupType "Differential" -Compress -Verify

# Avec splatting (plus lisible)
$backupParams = @{
    ServerName  = "SQL01"
    BackupPath  = "D:\Backups"
    BackupType  = "Differential"
    Compress    = $true
    Verify      = $true
}
New-ServerBackup @backupParams
```

### Splatting avec un tableau

Pour les paramètres positionnels, utilisez un tableau :

```powershell
function Add-Numbers {
    param(
        [int]$First,
        [int]$Second,
        [int]$Third
    )
    
    return $First + $Second + $Third
}

# Sans splatting
$result = Add-Numbers 10 20 30

# Avec splatting
$numbers = @(10, 20, 30)
$result = Add-Numbers @numbers

Write-Host "Résultat : $result"  # 60
```

### Combinaison de splatting et paramètres directs

Vous pouvez combiner splatting et paramètres classiques :

```powershell
function Deploy-Application {
    param(
        [string]$AppName,
        [string]$Version,
        [string]$TargetServer,
        [string]$Environment,
        [switch]$RestartService
    )
    
    Write-Host "Déploiement de $AppName v$Version"
    Write-Host "Serveur : $TargetServer"
    Write-Host "Environnement : $Environment"
    Write-Host "Redémarrage : $RestartService"
}

# Paramètres communs dans une hashtable
$commonParams = @{
    AppName      = "WebApp"
    Version      = "2.5.1"
}

# Déploiement en DEV
Deploy-Application @commonParams -TargetServer "DEV-WEB01" -Environment "Development"

# Déploiement en PROD avec redémarrage
Deploy-Application @commonParams -TargetServer "PROD-WEB01" -Environment "Production" -RestartService
```

### Modification dynamique des paramètres

Le splatting permet de construire des paramètres dynamiquement :

```powershell
function Get-SystemInfo {
    param(
        [string]$ComputerName,
        [switch]$IncludeDisk,
        [switch]$IncludeMemory,
        [switch]$IncludeNetwork
    )
    
    Write-Host "=== Informations système de $ComputerName ==="
    
    if ($IncludeDisk) {
        Write-Host "Disques : [info]"
    }
    if ($IncludeMemory) {
        Write-Host "Mémoire : [info]"
    }
    if ($IncludeNetwork) {
        Write-Host "Réseau : [info]"
    }
}

# Construction dynamique basée sur la configuration
$config = @{
    Environment = "Production"
    DetailLevel = "High"
}

$params = @{
    ComputerName = "SERVER01"
}

if ($config.DetailLevel -eq "High") {
    $params.IncludeDisk = $true
    $params.IncludeMemory = $true
    $params.IncludeNetwork = $true
}

Get-SystemInfo @params
```

### Splatting dans le pipeline

Le splatting est particulièrement utile lors du passage d'objets dans le pipeline :

```powershell
function Process-Users {
    param(
        [string]$FirstName,
        [string]$LastName,
        [string]$Department,
        [string]$Email
    )
    
    Write-Host "Traitement de $FirstName $LastName ($Department) - $Email"
}

# Liste d'utilisateurs
$users = @(
    @{ FirstName="Jean"; LastName="Dupont"; Department="IT"; Email="jean.dupont@contoso.com" }
    @{ FirstName="Marie"; LastName="Martin"; Department="RH"; Email="marie.martin@contoso.com" }
    @{ FirstName="Pierre"; LastName="Durand"; Department="Finance"; Email="pierre.durand@contoso.com" }
)

# Traitement avec splatting
foreach ($user in $users) {
    Process-Users @user
}
```

### Splatting avec des cmdlets PowerShell natives

Le splatting fonctionne avec toutes les commandes PowerShell :

```powershell
# Copy-Item avec splatting
$copyParams = @{
    Path        = "C:\Source\*"
    Destination = "D:\Backup"
    Recurse     = $true
    Force       = $true
    ErrorAction = "Stop"
}
Copy-Item @copyParams

# Get-ChildItem avec splatting
$searchParams = @{
    Path    = "C:\Logs"
    Filter  = "*.log"
    Recurse = $true
}
$logFiles = Get-ChildItem @searchParams

# Invoke-Command avec splatting
$remoteParams = @{
    ComputerName  = "SERVER01", "SERVER02", "SERVER03"
    ScriptBlock   = { Get-Service -Name "W3SVC" }
    Credential    = $cred
    ErrorAction   = "Continue"
}
Invoke-Command @remoteParams
```

> [!tip] Avantages du splatting
> 
> - **Lisibilité** : Code plus clair, surtout avec beaucoup de paramètres
> - **Réutilisabilité** : Définissez une fois, utilisez plusieurs fois
> - **Maintenance** : Modification facile des paramètres en un seul endroit
> - **Conditionnalité** : Ajoutez ou retirez facilement des paramètres selon les conditions
> - **Documentation** : Les hashtables documentent les valeurs de paramètres

> [!example] Pattern de configuration réutilisable
> 
> ```powershell
> # Fichier de configuration : config.ps1
> $DevEnvironment = @{
>     ServerName    = "DEV-SQL01"
>     BackupPath    = "D:\Backups\Dev"
>     MaxThreads    = 2
>     EnableLogging = $true
> }
> 
> $ProdEnvironment = @{
>     ServerName    = "PROD-SQL01"
>     BackupPath    = "E:\Backups\Prod"
>     MaxThreads    = 8
>     EnableLogging = $true
>     Compress      = $true
>     Encrypt       = $true
> }
> 
> # Script principal
> . .\config.ps1
> 
> function Start-Backup {
>     param(
>         [string]$ServerName,
>         [string]$BackupPath,
>         [int]$MaxThreads = 4,
>         [switch]$EnableLogging,
>         [switch]$Compress,
>         [switch]$Encrypt
>     )
>     # Logique de sauvegarde
> }
> 
> # Utilisation
> Start-Backup @DevEnvironment
> # ou
> Start-Backup @ProdEnvironment
> ```

---

## ⚠️ Pièges courants

### 1. Oubli du @ dans le splatting

```powershell
function Test-Param {
    param([string]$Name, [int]$Age)
    Write-Host "$Name a $Age ans"
}

$params = @{ Name="Jean"; Age=30 }

# ❌ ERREUR - utilise $ au lieu de @
Test-Param $params
# Tente de passer une hashtable comme premier paramètre positionnel

# ✅ CORRECT
Test-Param @params
```

### 2. Mélanger param() et $args de manière confuse

```powershell
# ❌ CONFUSION - difficile à comprendre
function Bad-Function {
    param([string]$First)
    
    Write-Host "Premier : $First"
    Write-Host "Reste : $args"
}

# Les utilisateurs ne savent pas quels arguments vont où
Bad-Function "A" "B" "C"

# ✅ MIEUX - déclarez tous les paramètres attendus
function Good-Function {
    param(
        [string]$First,
        [string[]]$Others
    )
    
    Write-Host "Premier : $First"
    Write-Host "Autres : $($Others -join ', ')"
}

Good-Function -First "A" -Others "B", "C"
```

### 3. Types de paramètres incompatibles

```powershell
function Process-Number {
    param(
        [int]$Value
    )
    Write-Host "Valeur : $Value"
}

# ❌ ERREUR - chaîne non convertible en int
Process-Number -Value "abc"

# ✅ PowerShell convertit automatiquement si possible
Process-Number -Value "123"  # "123" -> 123 (OK)
```

### 4. Paramètres obligatoires sans valeur

```powershell
function New-Report {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Title
    )
    Write-Host "Rapport : $Title"
}

# ❌ Si appelé sans -Title, PowerShell demandera interactivement
# Ce qui peut bloquer des scripts automatisés
New-Report
# cmdlet New-Report at command pipeline position 1
# Supply values for the following parameters:
# Title:
```

### 5. Confusion entre switch et booléen

```powershell
function Enable-Feature {
    param([switch]$Enabled)
    
    Write-Host "Activé : $Enabled"
}

# ❌ ERREUR - tentative de passer $true comme valeur
Enable-Feature -Enabled $true  # Erreur de syntaxe

# ✅ CORRECT - avec switch
Enable-Feature -Enabled        # Paramètre présent = $true
Enable-Feature                 # Paramètre absent = $false

# ✅ Si vous avez besoin d'un booléen explicite
Enable-Feature -Enabled:$true  # Syntaxe spéciale pour switch
Enable-Feature -Enabled:$false
```

### 6. Splatting avec des clés qui n'existent pas

```powershell
function Deploy-App {
    param(
        [string]$AppName,
        [string]$Version
    )
    Write-Host "Déploiement de $AppName v$Version"
}

$params = @{
    AppName     = "WebApp"
    Version     = "1.0"
    Environment = "Production"  # ❌ Ce paramètre n'existe pas !
}

# ❌ ERREUR
Deploy-App @params
# A parameter cannot be found that matches parameter name 'Environment'.

# ✅ CORRECT - retirez les clés inutiles
$params.Remove('Environment')
Deploy-App @params
```

### 7. Modification du tableau $args

```powershell
function Test-Args {
    Write-Host "Arguments originaux : $args"
    
    # ❌ $args est read-only
    $args[0] = "Modifié"  # ERREUR !
    
    # ✅ Créez une copie si besoin de modifier
    $myArgs = @() + $args
    $myArgs[0] = "Modifié"
    Write-Host "Arguments modifiés : $myArgs"
}
```

---

## ✅ Bonnes pratiques

### 1. Toujours déclarer les paramètres attendus

```powershell
# ❌ MAUVAIS
function Get-Data {
    # Utilise $args implicitement
    $path = $args[0]
    $filter = $args[1]
}

# ✅ BON
function Get-Data {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [string]$Filter = "*"
    )
    # Code clair et documenté
}
```

### 2. Utilisez des types explicites

```powershell
# ❌ Pas de type = accepte n'importe quoi
function Calculate {
    param($Value)
    return $Value * 2
}

# ✅ Type explicite = validation automatique
function Calculate {
    param(
        [double]$Value
    )
    return $Value * 2
}
```

### 3. Fournissez des valeurs par défaut sensées

```powershell
function Get-LogFiles {
    param(
        [string]$Path = "$env:TEMP\Logs",
        [int]$DaysOld = 7,
        [string]$Pattern = "*.log"
    )
    
    Get-ChildItem -Path $Path -Filter $Pattern |
        Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-$DaysOld) }
}

# Peut être appelé sans paramètres avec un comportement raisonnable
Get-LogFiles
```

### 4. Validez les paramètres critiques

```powershell
function Remove-OldFiles {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (Test-Path $_ -PathType Container) {
                $true
            } else {
                throw "Le chemin '$_' n'existe pas ou n'est pas un dossier"
            }
        })]
        [string]$Path,
        
        [ValidateRange(1, 365)]
        [int]$DaysOld = 30
    )
    
    # Suppression sécurisée
    Get-ChildItem $Path |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$DaysOld) } |
        Remove-Item -Force
}
```

### 5. Utilisez des noms de paramètres clairs et cohérents

```powershell
# ❌ Noms inconsistants
function Copy-Data {
    param(
        $src,           # Abréviation
        $destination,   # Complet
        $dest2          # Confusion
    )
}

# ✅ Noms clairs et cohérents
function Copy-Data {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [string]$BackupPath
    )
}
```

### 6. Groupez les paramètres logiquement

```powershell
function New-UserAccount {
    param(
        # Informations utilisateur
        [Parameter(Mandatory=$true)]
        [string]$FirstName,
        
        [Parameter(Mandatory=$true)]
        [string]$LastName,
        
        [Parameter(Mandatory=$true)]
        [string]$Email,
        
        # Configuration du compte
        [string]$Department = "General",
        [string]$Manager,
        
        # Options de sécurité
        [switch]$RequirePasswordChange,
        [switch]$EnableMFA,
        
        # Paramètres techniques
        [string]$HomeDirectory,
        [string[]]$Groups = @("Domain Users")
    )
    
    # Création du compte
}
```

### 7. Documentez avec des commentaires d'aide

```powershell
function Backup-Database {
    <#
    .SYNOPSIS
    Effectue une sauvegarde de base de données
    
    .DESCRIPTION
    Cette fonction crée une sauvegarde complète ou différentielle
    d'une base de données SQL Server avec des options de compression
    et de vérification.
    
    .PARAMETER DatabaseName
    Nom de la base de données à sauvegarder
    
    .PARAMETER BackupPath
    Chemin où stocker le fichier de sauvegarde
    
    .PARAMETER BackupType
    Type de sauvegarde : Full, Differential ou Log
    
    .PARAMETER Compress
    Active la compression de la sauvegarde
    
    .EXAMPLE
    Backup-Database -DatabaseName "Customers" -BackupPath "D:\Backups"
    
    .EXAMPLE
    Backup-Database -DatabaseName "Orders" -BackupPath "D:\Backups" -BackupType Differential -Compress
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$DatabaseName,
        
        [Parameter(Mandatory=$true)]
        [string]$BackupPath,
        
        [ValidateSet("Full", "Differential", "Log")]
        [string]$BackupType = "Full",
        
        [switch]$Compress
    )
    
    Write-Host "Sauvegarde $BackupType de $DatabaseName vers $BackupPath"
}

# Les utilisateurs peuvent obtenir de l'aide avec :
# Get-Help Backup-Database -Full
```

### 8. Privilégiez le splatting pour les appels complexes

```powershell
# ❌ Difficile à lire
Invoke-Command -ComputerName "SERVER01" -ScriptBlock { Get-Service } -Credential $cred -Authentication Kerberos -ErrorAction Stop -Verbose

# ✅ Plus clair avec splatting
$invokeParams = @{
    ComputerName  = "SERVER01"
    ScriptBlock   = { Get-Service }
    Credential    = $cred
    Authentication = "Kerberos"
    ErrorAction   = "Stop"
    Verbose       = $true
}
Invoke-Command @invokeParams
```

### 9. Utilisez [CmdletBinding()] pour les fonctions avancées

```powershell
function Get-SystemReport {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$ComputerName,
        
        [string]$OutputPath = "C:\Reports"
    )
    
    begin {
        Write-Verbose "Initialisation du rapport système"
    }
    
    process {
        foreach ($computer in $ComputerName) {
            if ($PSCmdlet.ShouldProcess($computer, "Générer rapport système")) {
                Write-Verbose "Traitement de $computer"
                # Génération du rapport
            }
        }
    }
    
    end {
        Write-Verbose "Rapport terminé"
    }
}

# Bénéfices : -Verbose, -Debug, -ErrorAction, -WhatIf, -Confirm automatiques
```

### 10. Gérez les erreurs de paramètres gracieusement

```powershell
function Connect-RemoteServer {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerName,
        
        [ValidateRange(1, 65535)]
        [int]$Port = 3389,
        
        [PSCredential]$Credential
    )
    
    try {
        # Vérification supplémentaire
        if (-not (Test-Connection -ComputerName $ServerName -Count 1 -Quiet)) {
            throw "Impossible de joindre le serveur $ServerName"
        }
        
        Write-Host "Connexion à $ServerName sur le port $Port"
        # Logique de connexion
    }
    catch {
        Write-Error "Erreur de connexion : $_"
        return $null
    }
}
```

### 11. Créez des alias de paramètres pour la compatibilité

```powershell
function Get-UserInfo {
    param(
        [Parameter(Mandatory=$true)]
        [Alias("User", "Username", "Identity")]
        [string]$UserName,
        
        [Alias("DC", "Server")]
        [string]$DomainController = $env:LOGONSERVER
    )
    
    Write-Host "Recherche de $UserName sur $DomainController"
}

# Tous ces appels fonctionnent :
Get-UserInfo -UserName "jdupont"
Get-UserInfo -User "jdupont"
Get-UserInfo -Identity "jdupont"
```

### 12. Pattern : Fonction avec configuration externe

```powershell
# Fichier : AppConfig.psd1
@{
    DefaultTimeout    = 300
    MaxRetries       = 3
    LogPath          = "C:\Logs\App.log"
    EnableDebugMode  = $false
}

# Script principal
function Start-Application {
    param(
        [string]$ConfigFile = ".\AppConfig.psd1",
        [hashtable]$OverrideSettings = @{}
    )
    
    # Chargement de la configuration
    $config = Import-PowerShellDataFile -Path $ConfigFile
    
    # Application des overrides
    foreach ($key in $OverrideSettings.Keys) {
        $config[$key] = $OverrideSettings[$key]
    }
    
    # Utilisation avec splatting
    Start-AppProcess @config
}

# Utilisation normale
Start-Application

# Avec overrides
Start-Application -OverrideSettings @{ EnableDebugMode = $true; MaxRetries = 5 }
```

> [!tip] Checklist pour des paramètres de qualité
> 
> - ✅ Types explicites sur tous les paramètres
> - ✅ Validation appropriée (Range, Set, Script, Pattern)
> - ✅ Valeurs par défaut sensées
> - ✅ Paramètres obligatoires marqués comme tels
> - ✅ Noms clairs et cohérents (verbe-substantif)
> - ✅ Commentaires d'aide complets
> - ✅ Aliases pour la compatibilité si nécessaire
> - ✅ [CmdletBinding()] pour les fonctions avancées
> - ✅ Utilisation de splatting pour les appels complexes
> - ✅ Gestion d'erreurs robuste

---

## 🎓 Synthèse

Les paramètres de fonctions en PowerShell offrent une flexibilité et une puissance considérables :

|Concept|Usage principal|Avantage clé|
|---|---|---|
|**param()**|Déclaration formelle des paramètres|Clarté et validation|
|**Positionnels vs Nommés**|Flexibilité d'appel|Syntaxe concise ou explicite|
|**Validation**|Contrôle des entrées|Sécurité et fiabilité|
|**$args**|Arguments non déclarés|Simplicité pour wrappers|
|**Splatting**|Passage de multiples paramètres|Lisibilité et réutilisabilité|

> [!info] Points clés à retenir
> 
> 1. **Toujours privilégier param() sur $args** pour des fonctions réutilisables
> 2. **Utiliser des types explicites** pour éviter les erreurs
> 3. **Valider les entrées** avec les attributs appropriés
> 4. **Le splatting améliore la lisibilité** des appels complexes
> 5. **$args est utile uniquement** pour des cas spécifiques (wrappers, prototypes)
> 6. **Documenter avec Get-Help** via les commentaires d'aide

La maîtrise des paramètres de fonctions est essentielle pour créer des scripts PowerShell professionnels, maintenables et robustes. En combinant ces techniques, vous pouvez créer des fonctions qui rivalisent avec les cmdlets natives de PowerShell en termes de qualité et d'ergonomie.