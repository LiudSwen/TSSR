

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

## 🎭 Introduction

Les bannières et headers sont essentiels pour créer des scripts PowerShell professionnels et agréables à utiliser. Ils permettent de :

- **Identifier rapidement** le script et sa version
- **Structurer visuellement** la sortie console
- **Améliorer l'expérience utilisateur** avec une présentation soignée
- **Renforcer l'identité** de vos outils et scripts

> [!tip] Quand utiliser des bannières ?
> 
> - Scripts destinés à être utilisés par d'autres personnes
> - Outils d'administration système
> - Scripts de maintenance ou de déploiement
> - Interfaces en ligne de commande (CLI)

---

## 🖼️ Bannières ASCII Art

### Qu'est-ce que l'ASCII Art ?

L'ASCII Art consiste à créer des images et du texte stylisé en utilisant uniquement des caractères ASCII. C'est idéal pour créer des bannières mémorables dans vos scripts.

### Méthodes de création

#### Méthode 1 : Bannière simple avec Write-Host

```powershell
# Bannière simple avec bordures
function Show-SimpleBanner {
    param(
        [string]$Title = "Mon Script",
        [string]$Version = "1.0"
    )
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                        ║" -ForegroundColor Cyan
    Write-Host "║          $Title v$Version              ║" -ForegroundColor Yellow
    Write-Host "║                                        ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# Utilisation
Show-SimpleBanner -Title "PowerShell Manager" -Version "2.5"
```

> [!info] Caractères Unicode pour bordures PowerShell supporte l'Unicode, ce qui permet d'utiliser des caractères spéciaux :
> 
> - Simple : `─ │ ┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼`
> - Double : `═ ║ ╔ ╗ ╚ ╝ ╠ ╣ ╦ ╩ ╬`
> - Arrondi : `─ │ ╭ ╮ ╰ ╯`

#### Méthode 2 : Bannière ASCII Art complexe

```powershell
function Show-ASCIIBanner {
    $banner = @"
    ____                        _____ __         ____
   / __ \____ _      _____  ___/ ___// /_  ___  / / /
  / /_/ / __ \ | /| / / _ \/ __\__ \/ __ \/ _ \/ / / 
 / ____/ /_/ / |/ |/ /  __/ / ___/ / / / /  __/ / /  
/_/    \____/|__/|__/\___/_/ /____/_/ /_/\___/_/_/   
                                                      
"@
    
    Write-Host $banner -ForegroundColor Green
    Write-Host "Version 3.0 - Administration System" -ForegroundColor Gray
    Write-Host "═" * 60 -ForegroundColor DarkGray
    Write-Host ""
}

Show-ASCIIBanner
```

#### Méthode 3 : Bannière avec dégradé de couleurs

```powershell
function Show-GradientBanner {
    param([string]$Text = "POWERSHELL")
    
    $colors = @('DarkBlue', 'Blue', 'Cyan', 'White')
    $lines = @(
        "  ███████████████████████████  ",
        " ███                       ███ ",
		"███         $Text           ███",
        " ███                       ███ ",
        "  ███████████████████████████  "
    )
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $color = $colors[[Math]::Floor($i * $colors.Count / $lines.Count)]
        Write-Host $lines[$i] -ForegroundColor $color
    }
    Write-Host ""
}

Show-GradientBanner -Text "ADMIN TOOLS"
```

> [!warning] Attention aux polices console Tous les caractères ASCII Art ne s'affichent pas correctement dans toutes les polices. Testez votre bannière dans :
> 
> - PowerShell Console classique
> - Windows Terminal
> - VS Code Terminal
> - Différentes polices (Consolas, Cascadia Code, etc.)

### Bannières multilignes avec Here-String

```powershell
function Show-DetailedBanner {
    $banner = @"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███████╗    ║
║   ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗██╔════╝    ║
║   ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝███████╗    ║
║   ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗╚════██║    ║
║   ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║███████║    ║
║   ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚══════╝    ║
║                                                          ║
║              System Administration Suite                 ║
║                     Version 4.2.1                        ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
"@
    
    Write-Host $banner -ForegroundColor Cyan
}
```

> [!tip] Générateurs en ligne Utilisez des outils en ligne pour créer votre ASCII Art :
> 
> - **patorjk.com/software/taag/** : Générateur de texte ASCII
> - **ascii-art-generator.org** : Conversion d'images
> - **textkool.com** : Styles variés

### Bonnes pratiques ASCII Art

```powershell
# ✅ BONNE PRATIQUE : Fonction réutilisable
function Show-Banner {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [string]$Subtitle = "",
        [string]$Version = "",
        [ConsoleColor]$Color = 'Cyan',
        [switch]$IncludeTimestamp
    )
    
    $width = 60
    $titleCentered = $Title.PadLeft(($width + $Title.Length) / 2).PadRight($width)
    
    Write-Host ("═" * $width) -ForegroundColor $Color
    Write-Host $titleCentered -ForegroundColor White
    
    if ($Subtitle) {
        $subtitleCentered = $Subtitle.PadLeft(($width + $Subtitle.Length) / 2).PadRight($width)
        Write-Host $subtitleCentered -ForegroundColor Gray
    }
    
    if ($Version) {
        Write-Host ("Version: $Version").PadLeft($width) -ForegroundColor DarkGray
    }
    
    if ($IncludeTimestamp) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host ("Exécuté le: $timestamp").PadLeft($width) -ForegroundColor DarkGray
    }
    
    Write-Host ("═" * $width) -ForegroundColor $Color
    Write-Host ""
}

# Utilisation
Show-Banner -Title "BACKUP SYSTEM" -Subtitle "Sauvegarde automatique" `
            -Version "2.1.0" -Color Green -IncludeTimestamp
```

---

## ✨ Générateurs de titres stylisés

### Titres avec encadrement dynamique

```powershell
function Write-StyledTitle {
    param(
        [Parameter(Mandatory)]
        [string]$Text,
        
        [ValidateSet('Single', 'Double', 'Thick', 'Dotted')]
        [string]$Style = 'Double',
        
        [ConsoleColor]$Color = 'White'
    )
    
    # Définition des caractères selon le style
    $styles = @{
        Single = @{ Top = '─'; Side = '│'; TL = '┌'; TR = '┐'; BL = '└'; BR = '┘' }
        Double = @{ Top = '═'; Side = '║'; TL = '╔'; TR = '╗'; BL = '╚'; BR = '╝' }
        Thick  = @{ Top = '━'; Side = '┃'; TL = '┏'; TR = '┓'; BL = '┗'; BR = '┛' }
        Dotted = @{ Top = '┄'; Side = '┆'; TL = '┌'; TR = '┐'; BL = '└'; BR = '┘' }
    }
    
    $chars = $styles[$Style]
    $width = $Text.Length + 4
    
    # Construction du titre
    Write-Host ($chars.TL + $chars.Top * $width + $chars.TR) -ForegroundColor $Color
    Write-Host ($chars.Side + "  $Text  " + $chars.Side) -ForegroundColor $Color
    Write-Host ($chars.BL + $chars.Top * $width + $chars.BR) -ForegroundColor $Color
}

# Exemples d'utilisation
Write-StyledTitle -Text "Configuration" -Style Single -Color Green
Write-StyledTitle -Text "Erreur Critique" -Style Double -Color Red
Write-StyledTitle -Text "Information" -Style Thick -Color Cyan
```

### Titres avec effet ombre

```powershell
function Write-ShadowTitle {
    param(
        [string]$Text,
        [ConsoleColor]$MainColor = 'White',
        [ConsoleColor]$ShadowColor = 'DarkGray'
    )
    
    Write-Host ""
    Write-Host "  $Text" -ForegroundColor $MainColor
    Write-Host "  $Text" -ForegroundColor $ShadowColor -NoNewline
    Write-Host "`r $Text" -ForegroundColor $MainColor
    Write-Host ""
}

Write-ShadowTitle -Text "PowerShell Manager" -MainColor Cyan
```

### Titres avec symboles et icônes

```powershell
function Write-IconTitle {
    param(
        [Parameter(Mandatory)]
        [string]$Text,
        
        [ValidateSet('Success', 'Error', 'Warning', 'Info', 'Question', 'Settings')]
        [string]$Icon = 'Info',
        
        [switch]$Centered
    )
    
    # Définition des icônes et couleurs
    $icons = @{
        Success  = @{ Symbol = '✓'; Color = 'Green' }
        Error    = @{ Symbol = '✗'; Color = 'Red' }
        Warning  = @{ Symbol = '⚠'; Color = 'Yellow' }
        Info     = @{ Symbol = 'ℹ'; Color = 'Cyan' }
        Question = @{ Symbol = '?'; Color = 'Magenta' }
        Settings = @{ Symbol = '⚙'; Color = 'White' }
    }
    
    $iconData = $icons[$Icon]
    $output = "$($iconData.Symbol) $Text"
    
    if ($Centered) {
        $width = $Host.UI.RawUI.WindowSize.Width
        $output = $output.PadLeft(($width + $output.Length) / 2)
    }
    
    Write-Host $output -ForegroundColor $iconData.Color
}

# Exemples
Write-IconTitle -Text "Opération réussie" -Icon Success
Write-IconTitle -Text "Erreur de connexion" -Icon Error
Write-IconTitle -Text "Configuration requise" -Icon Settings -Centered
```

### Titres avec bordures personnalisées

```powershell
function Write-CustomTitle {
    param(
        [string]$Text,
        [string]$BorderChar = '═',
        [int]$Padding = 5,
        [ConsoleColor]$TextColor = 'White',
        [ConsoleColor]$BorderColor = 'Cyan'
    )
    
    $totalWidth = $Text.Length + ($Padding * 2)
    $border = $BorderChar * $totalWidth
    $paddedText = (' ' * $Padding) + $Text + (' ' * $Padding)
    
    Write-Host ""
    Write-Host $border -ForegroundColor $BorderColor
    Write-Host $paddedText -ForegroundColor $TextColor
    Write-Host $border -ForegroundColor $BorderColor
    Write-Host ""
}

# Utilisation avec différents styles
Write-CustomTitle -Text "Analyse du système" -BorderChar "═" -BorderColor Green
Write-CustomTitle -Text "Avertissement" -BorderChar "▄" -BorderColor Yellow
Write-CustomTitle -Text "Résultats" -BorderChar "─" -BorderColor Cyan -Padding 10
```

> [!example] Titres combinés
> 
> ```powershell
> function Write-CompleteTitle {
>     param(
>         [string]$MainTitle,
>         [string]$SubTitle,
>         [string]$Icon = "⚡"
>     )
>     
>     Write-Host ""
>     Write-Host "  ╔═══════════════════════════════════╗" -ForegroundColor Cyan
>     Write-Host "  ║                                   ║" -ForegroundColor Cyan
>     Write-Host "  ║   $Icon $MainTitle" -ForegroundColor Yellow -NoNewline
>     Write-Host " " * (30 - $MainTitle.Length) -NoNewline
>     Write-Host "║" -ForegroundColor Cyan
>     
>     if ($SubTitle) {
>         Write-Host "  ║   " -ForegroundColor Cyan -NoNewline
>         Write-Host $SubTitle -ForegroundColor Gray -NoNewline
>         Write-Host " " * (32 - $SubTitle.Length) -NoNewline
>         Write-Host "║" -ForegroundColor Cyan
>     }
>     
>     Write-Host "  ║                                   ║" -ForegroundColor Cyan
>     Write-Host "  ╚═══════════════════════════════════╝" -ForegroundColor Cyan
>     Write-Host ""
> }
> ```

---

## ➖ Séparateurs décoratifs

### Séparateurs simples

```powershell
# Séparateur basique
function Write-Separator {
    param(
        [string]$Char = '─',
        [int]$Length = 80,
        [ConsoleColor]$Color = 'Gray'
    )
    
    Write-Host ($Char * $Length) -ForegroundColor $Color
}

# Utilisation
Write-Separator
Write-Separator -Char '═' -Color Cyan
Write-Separator -Char '•' -Length 40 -Color Yellow
```

### Séparateurs avec texte

```powershell
function Write-SeparatorWithText {
    param(
        [string]$Text,
        [string]$Char = '─',
        [int]$TotalWidth = 80,
        [ConsoleColor]$Color = 'Cyan'
    )
    
    $textWithSpaces = " $Text "
    $textLength = $textWithSpaces.Length
    $sideLength = [Math]::Floor(($TotalWidth - $textLength) / 2)
    
    $leftSide = $Char * $sideLength
    $rightSide = $Char * ($TotalWidth - $textLength - $sideLength)
    
    Write-Host $leftSide -ForegroundColor $Color -NoNewline
    Write-Host $textWithSpaces -ForegroundColor White -NoNewline
    Write-Host $rightSide -ForegroundColor $Color
}

# Exemples
Write-SeparatorWithText -Text "CONFIGURATION"
Write-SeparatorWithText -Text "Étape 1/5" -Char '═' -Color Green
Write-SeparatorWithText -Text "Résultats" -Char '•' -Color Yellow
```

### Séparateurs avec styles variés

```powershell
function Write-StyledSeparator {
    param(
        [ValidateSet('Light', 'Heavy', 'Double', 'Dotted', 'Wave', 'Stars')]
        [string]$Style = 'Light',
        
        [int]$Width = 80,
        [ConsoleColor]$Color = 'Gray'
    )
    
    $patterns = @{
        Light  = '─'
        Heavy  = '━'
        Double = '═'
        Dotted = '┄'
        Wave   = '≈'
        Stars  = '✦'
    }
    
    Write-Host ($patterns[$Style] * $Width) -ForegroundColor $Color
}

# Démonstration des styles
Write-StyledSeparator -Style Light
Write-StyledSeparator -Style Heavy -Color Cyan
Write-StyledSeparator -Style Double -Color Green
Write-StyledSeparator -Style Dotted -Color Yellow
Write-StyledSeparator -Style Wave -Color Magenta
Write-StyledSeparator -Style Stars -Color White
```

### Séparateurs de section

```powershell
function Write-SectionSeparator {
    param(
        [Parameter(Mandatory)]
        [string]$SectionTitle,
        
        [ValidateSet('Start', 'End', 'Between')]
        [string]$Position = 'Start',
        
        [ConsoleColor]$Color = 'Cyan'
    )
    
    $width = 80
    
    switch ($Position) {
        'Start' {
            Write-Host ""
            Write-Host ("╔" + "═" * ($width - 2) + "╗") -ForegroundColor $Color
            Write-Host ("║ " + $SectionTitle.PadRight($width - 4) + " ║") -ForegroundColor $Color
            Write-Host ("╠" + "═" * ($width - 2) + "╣") -ForegroundColor $Color
        }
        'End' {
            Write-Host ("╚" + "═" * ($width - 2) + "╝") -ForegroundColor $Color
            Write-Host ""
        }
        'Between' {
            Write-Host ("╟" + "─" * ($width - 2) + "╢") -ForegroundColor $Color
            Write-Host ("║ " + $SectionTitle.PadRight($width - 4) + " ║") -ForegroundColor $Color
            Write-Host ("╟" + "─" * ($width - 2) + "╢") -ForegroundColor $Color
        }
    }
}

# Exemple d'utilisation
Write-SectionSeparator -SectionTitle "INITIALISATION" -Position Start
Write-Host "Chargement des modules..." -ForegroundColor Gray
Write-SectionSeparator -SectionTitle "TRAITEMENT" -Position Between
Write-Host "Traitement en cours..." -ForegroundColor Gray
Write-SectionSeparator -Position End
```

> [!tip] Séparateurs adaptatifs
> 
> ```powershell
> # Séparateur qui s'adapte à la largeur de la console
> function Write-AdaptiveSeparator {
>     param(
>         [string]$Char = '─',
>         [ConsoleColor]$Color = 'Gray'
>     )
>     
>     $width = $Host.UI.RawUI.WindowSize.Width - 1
>     Write-Host ($Char * $width) -ForegroundColor $Color
> }
> ```

### Séparateurs avec gradient

```powershell
function Write-GradientSeparator {
    param(
        [ConsoleColor[]]$Colors = @('DarkBlue', 'Blue', 'Cyan'),
        [int]$Width = 80
    )
    
    $segmentSize = [Math]::Floor($Width / $Colors.Count)
    
    for ($i = 0; $i -lt $Colors.Count; $i++) {
        $length = if ($i -eq $Colors.Count - 1) { 
            $Width - ($segmentSize * $i) 
        } else { 
            $segmentSize 
        }
        Write-Host ('═' * $length) -ForegroundColor $Colors[$i] -NoNewline
    }
    Write-Host ""
}

# Exemples
Write-GradientSeparator
Write-GradientSeparator -Colors @('Red', 'Yellow', 'Green') -Width 60
```

---

## 📋 En-têtes de scripts professionnels

### Structure d'en-tête complète

```powershell
<#
.SYNOPSIS
    Gestion des sauvegardes système automatiques
    
.DESCRIPTION
    Ce script effectue des sauvegardes complètes ou incrémentielles
    du système avec compression et vérification d'intégrité.
    
.PARAMETER BackupType
    Type de sauvegarde : Full, Incremental ou Differential
    
.PARAMETER Destination
    Chemin de destination pour les fichiers de sauvegarde
    
.PARAMETER CompressionLevel
    Niveau de compression (0-9). Par défaut : 5
    
.EXAMPLE
    .\Backup-System.ps1 -BackupType Full -Destination "D:\Backups"
    Effectue une sauvegarde complète vers D:\Backups
    
.EXAMPLE
    .\Backup-System.ps1 -BackupType Incremental -CompressionLevel 9
    Sauvegarde incrémentielle avec compression maximale
    
.NOTES
    Nom du fichier : Backup-System.ps1
    Auteur        : Jean Dupont
    Prérequis     : PowerShell 5.1 ou supérieur
    Version       : 2.1.0
    Date          : 2024-01-15
    
.LINK
    https://github.com/monuser/backup-scripts
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Full', 'Incremental', 'Differential')]
    [string]$BackupType,
    
    [Parameter(Mandatory)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$Destination,
    
    [ValidateRange(0,9)]
    [int]$CompressionLevel = 5
)

# ═══════════════════════════════════════════════════════════
#  CONFIGURATION ET INITIALISATION
# ═══════════════════════════════════════════════════════════

$script:ScriptVersion = "2.1.0"
$script:ScriptName = "Backup-System"
$script:StartTime = Get-Date

# Affichage de la bannière
Show-ScriptBanner
```

> [!info] Comment-Based Help La section `<# ... #>` est appelée Comment-Based Help. Elle permet :
> 
> - D'obtenir de l'aide avec `Get-Help NomScript.ps1`
> - L'autocomplétion des paramètres
> - La documentation automatique du script

### Fonction d'en-tête réutilisable

```powershell
function Show-ScriptHeader {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptName,
        
        [Parameter(Mandatory)]
        [string]$Version,
        
        [string]$Author,
        [string]$Description,
        [hashtable]$Parameters,
        [switch]$IncludeSystemInfo
    )
    
    $width = 80
    
    # Bannière supérieure
    Write-Host ("╔" + "═" * ($width - 2) + "╗") -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan -NoNewline
    Write-Host " $ScriptName".PadRight($width - 2) -ForegroundColor Yellow -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan -NoNewline
    Write-Host " Version: $Version".PadRight($width - 2) -ForegroundColor Gray -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    
    if ($Author) {
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host " Auteur: $Author".PadRight($width - 2) -ForegroundColor Gray -NoNewline
        Write-Host "║" -ForegroundColor Cyan
    }
    
    Write-Host ("╠" + "═" * ($width - 2) + "╣") -ForegroundColor Cyan
    
    # Description
    if ($Description) {
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host " $Description".PadRight($width - 2) -ForegroundColor White -NoNewline
        Write-Host "║" -ForegroundColor Cyan
        Write-Host ("╠" + "═" * ($width - 2) + "╣") -ForegroundColor Cyan
    }
    
    # Paramètres
    if ($Parameters) {
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host " Paramètres actifs:".PadRight($width - 2) -ForegroundColor White -NoNewline
        Write-Host "║" -ForegroundColor Cyan
        
        foreach ($param in $Parameters.GetEnumerator()) {
            $line = "   • $($param.Key): $($param.Value)"
            Write-Host "║" -ForegroundColor Cyan -NoNewline
            Write-Host $line.PadRight($width - 2) -ForegroundColor Gray -NoNewline
            Write-Host "║" -ForegroundColor Cyan
        }
        Write-Host ("╠" + "═" * ($width - 2) + "╣") -ForegroundColor Cyan
    }
    
    # Informations système
    if ($IncludeSystemInfo) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $username = [Environment]::UserName
        $computer = $env:COMPUTERNAME
        
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host " Exécuté le: $timestamp".PadRight($width - 2) -ForegroundColor Gray -NoNewline
        Write-Host "║" -ForegroundColor Cyan
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host " Utilisateur: $username@$computer".PadRight($width - 2) -ForegroundColor Gray -NoNewline
        Write-Host "║" -ForegroundColor Cyan
    }
    
    # Bannière inférieure
    Write-Host ("╚" + "═" * ($width - 2) + "╝") -ForegroundColor Cyan
    Write-Host ""
}

# Exemple d'utilisation dans un script
$scriptParams = @{
    BackupType = $BackupType
    Destination = $Destination
    Compression = $CompressionLevel
}

Show-ScriptHeader -ScriptName "Système de Backup" `
                  -Version "2.1.0" `
                  -Author "Admin IT" `
                  -Description "Sauvegarde automatique avec compression" `
                  -Parameters $scriptParams `
                  -IncludeSystemInfo
```

### En-tête avec état d'exécution

```powershell
function Show-ExecutionHeader {
    param(
        [string]$ScriptName,
        [string]$Phase,
        [int]$CurrentStep,
        [int]$TotalSteps
    )
    
    $percentage = [Math]::Round(($CurrentStep / $TotalSteps) * 100)
    $barLength = 40
    $filledLength = [Math]::Round($barLength * $CurrentStep / $TotalSteps)
    $emptyLength = $barLength - $filledLength
    
    Clear-Host
    
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan -NoNewline
    Write-Host " $ScriptName".PadRight(54) -ForegroundColor Yellow -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╠════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan -NoNewline
    Write-Host " Phase actuelle: $Phase".PadRight(54) -ForegroundColor White -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan -NoNewline
    Write-Host " Progression: $CurrentStep/$TotalSteps ($percentage%)".PadRight(54) -ForegroundColor Gray -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan -NoNewline
    Write-Host " [" -ForegroundColor Gray -NoNewline
    Write-Host ("█" * $filledLength) -ForegroundColor Green -NoNewline
    Write-Host ("░" * $emptyLength) -ForegroundColor DarkGray -NoNewline
    Write-Host "]".PadRight(54 - $barLength - 2) -ForegroundColor Gray -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# Exemple d'utilisation
for ($i = 1; $i -le 5; $i++) {
    Show-ExecutionHeader -ScriptName "Installation des modules" `
                        -Phase "Téléchargement" `
                        -CurrentStep $i `
                        -TotalSteps 5
    Start-Sleep -Seconds 2
}
```

### En-tête avec logging

```powershell
function Initialize-ScriptWithLogging {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptName,
        
        [string]$LogPath = "$env:TEMP\Logs",
        [string]$Version = "1.0.0"
    )
    
    # Création du répertoire de logs
    if (-not (Test-Path $LogPath)) {
        New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile = Join-Path $LogPath "$ScriptName`_$timestamp.log"
    
    # Création du header
    $headerInfo = @{
        ScriptName = $ScriptName
        Version = $Version
        StartTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        User = [Environment]::UserName
        Computer = $env:COMPUTERNAME
        PSVersion = $PSVersionTable.PSVersion.ToString()
        LogFile = $logFile
    }
    
    # Affichage console
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                          ║" -ForegroundColor Cyan
    Write-Host "║  $($headerInfo.ScriptName) v$($headerInfo.Version)".PadRight(59) -ForegroundColor Yellow -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "║                                                          ║" -ForegroundColor Cyan
    Write-Host "╠══════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║  📅 Démarré le : $($headerInfo.StartTime)".PadRight(59) -ForegroundColor Gray -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "║  👤 Utilisateur: $($headerInfo.User)@$($headerInfo.Computer)".PadRight(59) -ForegroundColor Gray -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "║  📝 Log        : $logFile".PadRight(59) -ForegroundColor Gray -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Écriture dans le fichier log
    $logContent = @"
════════════════════════════════════════════════════════════
 $($headerInfo.ScriptName) - Log d'exécution
════════════════════════════════════════════════════════════
Version       : $($headerInfo.Version)
Date/Heure    : $($headerInfo.StartTime)
Utilisateur   : $($headerInfo.User)
Ordinateur    : $($headerInfo.Computer)
PowerShell    : $($headerInfo.PSVersion)
Fichier log   : $logFile
════════════════════════════════════════════════════════════

"@
    
    $logContent | Out-File -FilePath $logFile -Encoding UTF8
    
    return $logFile
}

# Utilisation
$logFile = Initialize-ScriptWithLogging -ScriptName "Deploy-Application" -Version "3.2.1"
```

### En-tête avec vérifications préalables

```powershell
function Show-PrerequisitesHeader {
    param(
        [string]$ScriptName,
        [hashtable]$Requirements
    )
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  🔍 Vérification des prérequis".PadRight(57) -ForegroundColor Yellow -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╠════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
    
    $allPassed = $true
    
    foreach ($req in $Requirements.GetEnumerator()) {
        $status = if ($req.Value) { "✓" } else { "✗"; $allPassed = $false }
        $color = if ($req.Value) { "Green" } else { "Red" }
        $statusText = if ($req.Value) { "OK" } else { "MANQUANT" }
        
        Write-Host "║  " -ForegroundColor Cyan -NoNewline
        Write-Host $status -ForegroundColor $color -NoNewline
        Write-Host " $($req.Key): " -ForegroundColor White -NoNewline
        Write-Host $statusText.PadRight(43 - $req.Key.Length) -ForegroundColor $color -NoNewline
        Write-Host "║" -ForegroundColor Cyan
    }
    
    Write-Host "╠════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
    
    if ($allPassed) {
        Write-Host "║  ✓ Tous les prérequis sont satisfaits".PadRight(57) -ForegroundColor Green -NoNewline
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "║  ✗ Certains prérequis sont manquants".PadRight(57) -ForegroundColor Red -NoNewline
        Write-Host "║" -ForegroundColor Cyan
    }
    
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    return $allPassed
}

# Exemple d'utilisation
$requirements = @{
    "PowerShell 5.1+" = ($PSVersionTable.PSVersion.Major -ge 5)
    "Module ActiveDirectory" = (Get-Module -ListAvailable -Name ActiveDirectory) -ne $null
    "Droits Administrateur" = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    "Connexion Internet" = (Test-Connection -ComputerName google.com -Count 1 -Quiet)
}

$canContinue = Show-PrerequisitesHeader -ScriptName "Script-Deploy" -Requirements $requirements

if (-not $canContinue) {
    Write-Host "❌ Impossible de continuer sans les prérequis." -ForegroundColor Red
    exit 1
}
```

> [!warning] Performances Les en-têtes élaborés avec de nombreux Write-Host peuvent ralentir le démarrage du script. Pour les scripts de production :
> 
> - Utilisez des en-têtes simples
> - Envisagez un paramètre `-Verbose` ou `-ShowBanner` pour les désactiver
> - Évitez les animations longues

### Template complet d'en-tête professionnel

```powershell
function New-ProfessionalHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [string]$Version = "1.0.0",
        [string]$Author,
        [string]$Company,
        [string]$Description,
        [hashtable]$Parameters,
        [string[]]$Tags,
        
        [switch]$ShowSystemInfo,
        [switch]$ShowTimestamp,
        [switch]$Minimal
    )
    
    if ($Minimal) {
        # Version minimaliste pour production
        Write-Host "═══ $Title v$Version ═══" -ForegroundColor Cyan
        return
    }
    
    $width = 70
    $border = "═" * $width
    
    # En-tête principal
    Write-Host ""
    Write-Host "╔$border╗" -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan -NoNewline
    Write-Host " $Title".PadRight($width) -ForegroundColor Yellow -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    
    # Version
    Write-Host "║" -ForegroundColor Cyan -NoNewline
    Write-Host " Version $Version".PadRight($width) -ForegroundColor Gray -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    
    # Auteur et entreprise
    if ($Author -or $Company) {
        $authorLine = ""
        if ($Author) { $authorLine += "Par $Author" }
        if ($Company) { 
            if ($authorLine) { $authorLine += " - " }
            $authorLine += $Company
        }
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host " $authorLine".PadRight($width) -ForegroundColor Gray -NoNewline
        Write-Host "║" -ForegroundColor Cyan
    }
    
    Write-Host "╠$border╣" -ForegroundColor Cyan
    
    # Description
    if ($Description) {
        $descLines = $Description -split "`n"
        foreach ($line in $descLines) {
            Write-Host "║" -ForegroundColor Cyan -NoNewline
            Write-Host " $line".PadRight($width) -ForegroundColor White -NoNewline
            Write-Host "║" -ForegroundColor Cyan
        }
        Write-Host "╠$border╣" -ForegroundColor Cyan
    }
    
    # Tags
    if ($Tags) {
        $tagString = ($Tags | ForEach-Object { "#$_" }) -join " "
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host " $tagString".PadRight($width) -ForegroundColor DarkCyan -NoNewline
        Write-Host "║" -ForegroundColor Cyan
        Write-Host "╠$border╣" -ForegroundColor Cyan
    }
    
    # Paramètres
    if ($Parameters -and $Parameters.Count -gt 0) {
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host " Configuration:".PadRight($width) -ForegroundColor White -NoNewline
        Write-Host "║" -ForegroundColor Cyan
        
        foreach ($param in $Parameters.GetEnumerator()) {
            $line = "  • $($param.Key): $($param.Value)"
            if ($line.Length -gt $width - 2) {
                $line = $line.Substring(0, $width - 5) + "..."
            }
            Write-Host "║" -ForegroundColor Cyan -NoNewline
            Write-Host $line.PadRight($width) -ForegroundColor Gray -NoNewline
            Write-Host "║" -ForegroundColor Cyan
        }
        Write-Host "╠$border╣" -ForegroundColor Cyan
    }
    
    # Informations système
    if ($ShowSystemInfo) {
        $psVersion = $PSVersionTable.PSVersion.ToString()
        $osVersion = [System.Environment]::OSVersion.VersionString
        
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host " Environnement:".PadRight($width) -ForegroundColor White -NoNewline
        Write-Host "║" -ForegroundColor Cyan
        
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host "  • PowerShell: $psVersion".PadRight($width) -ForegroundColor Gray -NoNewline
        Write-Host "║" -ForegroundColor Cyan
        
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host "  • Ordinateur: $env:COMPUTERNAME".PadRight($width) -ForegroundColor Gray -NoNewline
        Write-Host "║" -ForegroundColor Cyan
        
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host "  • Utilisateur: $([Environment]::UserName)".PadRight($width) -ForegroundColor Gray -NoNewline
        Write-Host "║" -ForegroundColor Cyan
        
        Write-Host "╠$border╣" -ForegroundColor Cyan
    }
    
    # Timestamp
    if ($ShowTimestamp) {
        $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
        Write-Host "║" -ForegroundColor Cyan -NoNewline
        Write-Host " Démarré le: $timestamp".PadRight($width) -ForegroundColor Gray -NoNewline
        Write-Host "║" -ForegroundColor Cyan
    }
    
    Write-Host "╚$border╝" -ForegroundColor Cyan
    Write-Host ""
}

# Exemple d'utilisation complète
New-ProfessionalHeader -Title "Système de Déploiement Automatisé" `
                       -Version "3.5.2" `
                       -Author "Jean Dupont" `
                       -Company "TechCorp Solutions" `
                       -Description "Déploiement et configuration automatique des applications`nAvec rollback et validation d'intégrité" `
                       -Parameters @{
                           Environment = "Production"
                           Target = "Serveurs Web"
                           Mode = "Automatique"
                       } `
                       -Tags @("deployment", "automation", "production") `
                       -ShowSystemInfo `
                       -ShowTimestamp
```

### Bonnes pratiques pour les en-têtes

> [!tip] Conseils de conception **DO** ✅
> 
> - Gardez les en-têtes concis et lisibles
> - Utilisez des couleurs cohérentes (Cyan/Yellow/Gray est un bon standard)
> - Incluez toujours la version du script
> - Ajoutez des informations de contact ou de support
> - Testez l'affichage dans différentes tailles de console
> 
> **DON'T** ❌
> 
> - N'utilisez pas trop de couleurs différentes (max 3-4)
> - Évitez les animations longues au démarrage
> - Ne surchargez pas avec trop d'informations
> - N'oubliez pas les utilisateurs avec des polices limitées
> - Ne rendez pas l'en-tête obligatoire (proposez -Quiet)

### Gestion des erreurs dans les en-têtes

```powershell
function Show-HeaderWithErrorHandling {
    param(
        [string]$Title,
        [scriptblock]$ValidationScript
    )
    
    try {
        # Affichage de l'en-tête
        Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║  $Title".PadRight(41) -ForegroundColor Yellow -NoNewline
        Write-Host "║" -ForegroundColor Cyan
        Write-Host "╠════════════════════════════════════════╣" -ForegroundColor Cyan
        
        # Exécution de la validation
        if ($ValidationScript) {
            Write-Host "║  Validation en cours...".PadRight(41) -ForegroundColor Gray -NoNewline
            Write-Host "║" -ForegroundColor Cyan
            
            $result = & $ValidationScript
            
            if ($result) {
                Write-Host "║  ✓ Validation réussie".PadRight(41) -ForegroundColor Green -NoNewline
            } else {
                Write-Host "║  ✗ Validation échouée".PadRight(41) -ForegroundColor Red -NoNewline
            }
            Write-Host "║" -ForegroundColor Cyan
        }
        
        Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        
    } catch {
        Write-Host "║  ⚠ Erreur lors de l'initialisation".PadRight(41) -ForegroundColor Red -NoNewline
        Write-Host "║" -ForegroundColor Cyan
        Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        throw
    }
}

# Utilisation
Show-HeaderWithErrorHandling -Title "Script de Backup" -ValidationScript {
    # Vérifications
    Test-Path "C:\Backup" -PathType Container
}
```

---

## 🎯 Synthèse des bonnes pratiques

### Récapitulatif des concepts clés

|Élément|Quand l'utiliser|Niveau de complexité|
|---|---|---|
|**Bannière ASCII simple**|Scripts personnels, outils internes|⭐ Facile|
|**Bannière ASCII Art**|Scripts partagés, outils professionnels|⭐⭐ Moyen|
|**Titres stylisés**|Sections importantes, rapports|⭐ Facile|
|**Séparateurs**|Organisation visuelle, sections|⭐ Facile|
|**En-têtes complets**|Scripts de production, documentation|⭐⭐⭐ Avancé|

### Checklist pour un bon en-tête

```powershell
# ✅ Checklist d'en-tête professionnel
<#
✓ Synopsis clair et concis
✓ Description détaillée
✓ Paramètres documentés avec exemples
✓ Informations de version et auteur
✓ Liens vers documentation/support
✓ Gestion des prérequis
✓ Affichage console soigné
✓ Option -Quiet pour désactiver l'affichage
✓ Logging approprié
✓ Validation avant exécution
#>
```

### Performance et optimisation

> [!warning] Impact sur les performances
> 
> ```powershell
> # ❌ MAUVAIS : Trop de Write-Host au démarrage
> for ($i = 0; $i -lt 100; $i++) {
>     Write-Host "." -NoNewline -ForegroundColor Cyan
>     Start-Sleep -Milliseconds 50
> }
> 
> # ✅ BON : Bannière simple et rapide
> Write-Host "═" * 50 -ForegroundColor Cyan
> Write-Host "Script démarré" -ForegroundColor Green
> Write-Host "═" * 50 -ForegroundColor Cyan
> ```

### Accessibilité

```powershell
# Fonction avec support de l'accessibilité
function Write-AccessibleHeader {
    param(
        [string]$Title,
        [switch]$NoColor  # Pour les terminaux sans support couleur
    )
    
    if ($NoColor) {
        Write-Host "=" * 50
        Write-Host $Title.ToUpper()
        Write-Host "=" * 50
    } else {
        Write-Host "═" * 50 -ForegroundColor Cyan
        Write-Host $Title -ForegroundColor Yellow
        Write-Host "═" * 50 -ForegroundColor Cyan
    }
}
```

### Module de bannières réutilisable

```powershell
# Sauvegardez ce module comme "BannerModule.psm1"

function New-Banner {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Text,
        
        [ValidateSet('Simple', 'Double', 'ASCII', 'Minimal')]
        [string]$Style = 'Double',
        
        [ConsoleColor]$Color = 'Cyan',
        [int]$Width = 60
    )
    
    switch ($Style) {
        'Simple' {
            Write-Host ("─" * $Width) -ForegroundColor $Color
            Write-Host $Text.PadLeft(($Width + $Text.Length) / 2) -ForegroundColor White
            Write-Host ("─" * $Width) -ForegroundColor $Color
        }
        'Double' {
            Write-Host ("═" * $Width) -ForegroundColor $Color
            Write-Host $Text.PadLeft(($Width + $Text.Length) / 2) -ForegroundColor White
            Write-Host ("═" * $Width) -ForegroundColor $Color
        }
        'ASCII' {
            # Votre code ASCII Art ici
        }
        'Minimal' {
            Write-Host ">>> $Text <<<" -ForegroundColor $Color
        }
    }
}

function New-Separator {
    [CmdletBinding()]
    param(
        [string]$Text,
        [string]$Char = '─',
        [int]$Width = 80,
        [ConsoleColor]$Color = 'Gray'
    )
    
    if ($Text) {
        $textWithSpaces = " $Text "
        $textLength = $textWithSpaces.Length
        $sideLength = [Math]::Floor(($Width - $textLength) / 2)
        
        Write-Host ($Char * $sideLength) -ForegroundColor $Color -NoNewline
        Write-Host $textWithSpaces -ForegroundColor White -NoNewline
        Write-Host ($Char * ($Width - $textLength - $sideLength)) -ForegroundColor $Color
    } else {
        Write-Host ($Char * $Width) -ForegroundColor $Color
    }
}

Export-ModuleMember -Function New-Banner, New-Separator

<#
UTILISATION:
Import-Module .\BannerModule.psm1
New-Banner -Text "Mon Application" -Style Double -Color Green
New-Separator -Text "Section 1" -Char "═"
#>
```

> [!success] Points clés à retenir
> 
> 1. **Simplicité avant tout** : Un en-tête simple et rapide vaut mieux qu'une animation complexe
> 2. **Cohérence** : Utilisez le même style dans tous vos scripts
> 3. **Flexibilité** : Proposez toujours une option pour désactiver les bannières (`-Quiet`)
> 4. **Documentation** : Les en-têtes doivent informer, pas seulement décorer
> 5. **Performance** : Testez l'impact sur le temps de démarrage du script

---

_📚 Ce cours fait partie de la série "Embellissement et présentation des scripts PowerShell"_