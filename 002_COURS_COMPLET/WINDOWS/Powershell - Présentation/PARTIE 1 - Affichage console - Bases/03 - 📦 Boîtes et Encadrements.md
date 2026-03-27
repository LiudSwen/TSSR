

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

## 🎯 Introduction

Les boîtes et encadrements permettent de structurer visuellement l'affichage console pour mettre en évidence des informations importantes. Contrairement aux simples couleurs de texte, les boîtes créent des sections délimitées qui attirent naturellement l'œil et organisent le contenu.

> [!info] Pourquoi utiliser des boîtes ?
> 
> - **Hiérarchisation visuelle** : Distinguer les messages critiques du flux normal
> - **Professionnalisme** : Donner un aspect soigné aux scripts d'administration
> - **Lisibilité** : Faciliter le scan visuel des informations importantes
> - **Contexte** : Grouper des informations liées ensemble

> [!warning] Quand les utiliser
> 
> - Messages d'erreur ou avertissements critiques
> - Résumés de résultats d'opérations
> - Bannières de début/fin de script
> - Sections de configuration ou paramètres
> 
> **À éviter** : Surutilisation dans des boucles ou logs verbeux (impact performance)

---

## 🛠️ Fonction Write-Box personnalisée

### Concept de base

Une boîte simple est composée de caractères Unicode pour dessiner les bordures. Les caractères les plus courants sont :

|Caractère|Unicode|Usage|
|---|---|---|
|`─`|U+2500|Ligne horizontale|
|`│`|U+2502|Ligne verticale|
|`┌`|U+250C|Coin supérieur gauche|
|`┐`|U+2510|Coin supérieur droit|
|`└`|U+2514|Coin inférieur gauche|
|`┘`|U+2518|Coin inférieur droit|

### Fonction Write-Box simple

```powershell
function Write-Box {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ConsoleColor]$ForegroundColor = 'White',
        [ConsoleColor]$BackgroundColor = $host.UI.RawUI.BackgroundColor
    )
    
    # Calculer la largeur de la boîte
    $width = $Message.Length + 2  # +2 pour les espaces intérieurs
    
    # Bordure supérieure
    $topBorder = "┌" + ("─" * $width) + "┐"
    
    # Ligne de contenu avec espaces
    $content = "│ $Message │"
    
    # Bordure inférieure
    $bottomBorder = "└" + ("─" * $width) + "┘"
    
    # Affichage
    Write-Host $topBorder -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    Write-Host $content -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    Write-Host $bottomBorder -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
}

# Utilisation
Write-Box "Opération terminée avec succès"
```

**Résultat** :

```
┌───────────────────────────────────┐
│ Opération terminée avec succès    │
└───────────────────────────────────┘
```

> [!tip] Caractères alternatifs Pour un style plus simple (compatible avec tous les terminaux) :
> 
> - `+`, `-`, `|` pour les bordures ASCII classiques
> - `╔`, `═`, `║`, `╗`, `╚`, `╝` pour un style double ligne
> - `╭`, `─`, `│`, `╮`, `╰`, `╯` pour un style arrondi

### Fonction avec padding configurable

```powershell
function Write-Box {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [int]$PaddingLeft = 1,
        [int]$PaddingRight = 1,
        [int]$PaddingTop = 0,
        [int]$PaddingBottom = 0,
        
        [ConsoleColor]$ForegroundColor = 'White'
    )
    
    # Créer les espaces de padding
    $leftPad = " " * $PaddingLeft
    $rightPad = " " * $PaddingRight
    
    # Largeur totale
    $contentWidth = $Message.Length + $PaddingLeft + $PaddingRight
    
    # Bordures
    $topBorder = "┌" + ("─" * $contentWidth) + "┐"
    $bottomBorder = "└" + ("─" * $contentWidth) + "┘"
    $emptyLine = "│" + (" " * $contentWidth) + "│"
    
    # Affichage
    Write-Host $topBorder -ForegroundColor $ForegroundColor
    
    # Padding supérieur
    for ($i = 0; $i -lt $PaddingTop; $i++) {
        Write-Host $emptyLine -ForegroundColor $ForegroundColor
    }
    
    # Contenu
    Write-Host "│$leftPad$Message$rightPad│" -ForegroundColor $ForegroundColor
    
    # Padding inférieur
    for ($i = 0; $i -lt $PaddingBottom; $i++) {
        Write-Host $emptyLine -ForegroundColor $ForegroundColor
    }
    
    Write-Host $bottomBorder -ForegroundColor $ForegroundColor
}

# Utilisation avec padding
Write-Box "Message important" -PaddingLeft 3 -PaddingRight 3 -PaddingTop 1 -PaddingBottom 1
```

**Résultat** :

```
┌─────────────────────────┐
│                         │
│   Message important     │
│                         │
└─────────────────────────┘
```

---

## 🏷️ Boîtes avec titre

Les boîtes avec titre permettent d'identifier rapidement le type d'information contenue.

### Titre centré

```powershell
function Write-BoxWithTitle {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [Parameter(Mandatory)]
        [string]$Message,
        
        [int]$Width = 50,
        [ConsoleColor]$TitleColor = 'Cyan',
        [ConsoleColor]$BoxColor = 'White'
    )
    
    # S'assurer que la largeur peut contenir le titre
    $minWidth = $Title.Length + 6  # Espace pour "[ Titre ]"
    if ($Width -lt $minWidth) { $Width = $minWidth }
    
    # Créer le titre formaté avec crochets
    $titleFormatted = "[ $Title ]"
    $titleLength = $titleFormatted.Length
    
    # Calculer le padding pour centrer le titre
    $remainingSpace = $Width - $titleLength
    $leftPadding = [math]::Floor($remainingSpace / 2)
    $rightPadding = $remainingSpace - $leftPadding
    
    # Bordure supérieure avec titre intégré
    $topBorder = "┌" + ("─" * $leftPadding)
    
    # Afficher la bordure supérieure et le titre
    Write-Host $topBorder -NoNewline -ForegroundColor $BoxColor
    Write-Host $titleFormatted -NoNewline -ForegroundColor $TitleColor
    Write-Host ("─" * $rightPadding) -NoNewline -ForegroundColor $BoxColor
    Write-Host "┐" -ForegroundColor $BoxColor
    
    # Ligne de contenu
    $contentPadding = $Width - $Message.Length - 2
    $leftContentPad = [math]::Floor($contentPadding / 2)
    $rightContentPad = $contentPadding - $leftContentPad
    
    $content = "│" + (" " * $leftContentPad) + $Message + (" " * $rightContentPad) + "│"
    Write-Host $content -ForegroundColor $BoxColor
    
    # Bordure inférieure
    $bottomBorder = "└" + ("─" * $Width) + "┘"
    Write-Host $bottomBorder -ForegroundColor $BoxColor
}

# Utilisation
Write-BoxWithTitle -Title "CONFIGURATION" -Message "Chargement des paramètres..." -Width 50
```

**Résultat** :

```
┌──────────────[ CONFIGURATION ]───────────────┐
│        Chargement des paramètres...          │
└──────────────────────────────────────────────┘
```

### Titre aligné à gauche

```powershell
function Write-BoxWithLeftTitle {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [Parameter(Mandatory)]
        [string]$Message,
        
        [int]$Width = 50,
        [ConsoleColor]$TitleColor = 'Yellow',
        [ConsoleColor]$BoxColor = 'Gray'
    )
    
    $titleFormatted = " $Title "
    $titleLength = $titleFormatted.Length
    $remainingDashes = $Width - $titleLength - 1
    
    # Bordure supérieure avec titre à gauche
    Write-Host "┌" -NoNewline -ForegroundColor $BoxColor
    Write-Host $titleFormatted -NoNewline -ForegroundColor $TitleColor -BackgroundColor DarkGray
    Write-Host ("─" * $remainingDashes) -NoNewline -ForegroundColor $BoxColor
    Write-Host "┐" -ForegroundColor $BoxColor
    
    # Contenu
    $contentPadding = $Width - $Message.Length
    Write-Host "│ $Message$(" " * ($contentPadding - 1))│" -ForegroundColor $BoxColor
    
    # Bordure inférieure
    Write-Host ("└" + ("─" * $Width) + "┘") -ForegroundColor $BoxColor
}

# Utilisation
Write-BoxWithLeftTitle -Title "INFO" -Message "Connexion établie" -Width 40
```

**Résultat** :

```
┌ INFO ──────────────────────────────────┐
│ Connexion établie                      │
└────────────────────────────────────────┘
```

---

## 📄 Boîtes multi-lignes

Pour afficher plusieurs lignes de texte dans une même boîte.

### Fonction multi-lignes avec tableau

```powershell
function Write-MultiLineBox {
    param(
        [Parameter(Mandatory)]
        [string[]]$Lines,
        
        [string]$Title = "",
        [int]$Width = 60,
        [ConsoleColor]$Color = 'White'
    )
    
    # Trouver la ligne la plus longue pour ajuster la largeur
    $maxLineLength = ($Lines | Measure-Object -Property Length -Maximum).Maximum
    if ($maxLineLength + 4 -gt $Width) {
        $Width = $maxLineLength + 4
    }
    
    # Bordure supérieure
    if ($Title) {
        $titleFormatted = "[ $Title ]"
        $leftPad = 2
        $rightPad = $Width - $titleFormatted.Length - $leftPad
        
        Write-Host "┌" -NoNewline -ForegroundColor $Color
        Write-Host ("─" * $leftPad) -NoNewline -ForegroundColor $Color
        Write-Host $titleFormatted -NoNewline -ForegroundColor Cyan
        Write-Host ("─" * $rightPad) -NoNewline -ForegroundColor $Color
        Write-Host "┐" -ForegroundColor $Color
    } else {
        Write-Host ("┌" + ("─" * $Width) + "┐") -ForegroundColor $Color
    }
    
    # Lignes de contenu
    foreach ($line in $Lines) {
        $padding = $Width - $line.Length - 2
        Write-Host "│ $line$(" " * $padding) │" -ForegroundColor $Color
    }
    
    # Bordure inférieure
    Write-Host ("└" + ("─" * $Width) + "┘") -ForegroundColor $Color
}

# Utilisation
$resultats = @(
    "Fichiers traités : 1,234"
    "Erreurs rencontrées : 3"
    "Durée d'exécution : 12.5s"
    "Statut : TERMINÉ"
)

Write-MultiLineBox -Lines $resultats -Title "RÉSUMÉ D'EXÉCUTION"
```

**Résultat** :

```
┌──[ RÉSUMÉ D'EXÉCUTION ]────────────────────────────────┐
│ Fichiers traités : 1,234                               │
│ Erreurs rencontrées : 3                                │
│ Durée d'exécution : 12.5s                              │
│ Statut : TERMINÉ                                       │
└────────────────────────────────────────────────────────┘
```

### Gestion du retour à la ligne automatique

```powershell
function Write-BoxWithWrap {
    param(
        [Parameter(Mandatory)]
        [string]$Text,
        
        [int]$MaxWidth = 60,
        [ConsoleColor]$Color = 'White'
    )
    
    # Diviser le texte en mots
    $words = $Text -split '\s+'
    $lines = @()
    $currentLine = ""
    
    foreach ($word in $words) {
        $testLine = if ($currentLine) { "$currentLine $word" } else { $word }
        
        if ($testLine.Length -le ($MaxWidth - 4)) {
            $currentLine = $testLine
        } else {
            if ($currentLine) { $lines += $currentLine }
            $currentLine = $word
        }
    }
    
    if ($currentLine) { $lines += $currentLine }
    
    # Afficher avec la fonction multi-lignes
    Write-MultiLineBox -Lines $lines -Width $MaxWidth -Color $Color
}

# Utilisation
$longText = "Ceci est un texte très long qui sera automatiquement découpé en plusieurs lignes pour s'adapter à la largeur maximale spécifiée de la boîte."
Write-BoxWithWrap -Text $longText -MaxWidth 50
```

---

## 📏 Largeur automatique vs fixe

### Comparaison des approches

|Approche|Avantages|Inconvénients|Usage|
|---|---|---|---|
|**Automatique**|S'adapte au contenu, économie d'espace|Tailles variables, moins aligné|Messages ponctuels|
|**Fixe**|Alignement parfait, prévisible|Peut tronquer ou gaspiller l'espace|Tableaux, dashboards|

### Fonction avec mode hybride

```powershell
function Write-SmartBox {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ValidateSet('Auto', 'Fixed', 'Min')]
        [string]$WidthMode = 'Auto',
        
        [int]$Width = 60,
        [int]$MinWidth = 20,
        [ConsoleColor]$Color = 'White'
    )
    
    # Calculer la largeur selon le mode
    $actualWidth = switch ($WidthMode) {
        'Auto' {
            # Largeur = longueur du message + padding
            $Message.Length + 4
        }
        'Fixed' {
            # Largeur fixe imposée
            $Width
        }
        'Min' {
            # Largeur automatique avec minimum
            $calculated = $Message.Length + 4
            if ($calculated -lt $MinWidth) { $MinWidth } else { $calculated }
        }
    }
    
    # Gestion du texte trop long en mode Fixed
    if ($WidthMode -eq 'Fixed' -and $Message.Length -gt ($actualWidth - 4)) {
        $Message = $Message.Substring(0, $actualWidth - 7) + "..."
    }
    
    # Affichage
    $topBorder = "┌" + ("─" * $actualWidth) + "┐"
    $padding = $actualWidth - $Message.Length - 2
    $leftPad = [math]::Floor($padding / 2)
    $rightPad = $padding - $leftPad
    $content = "│" + (" " * $leftPad) + $Message + (" " * $rightPad) + "│"
    $bottomBorder = "└" + ("─" * $actualWidth) + "┘"
    
    Write-Host $topBorder -ForegroundColor $Color
    Write-Host $content -ForegroundColor $Color
    Write-Host $bottomBorder -ForegroundColor $Color
}

# Exemples
Write-Host "`n=== Mode Auto ===`n"
Write-SmartBox "Court" -WidthMode Auto
Write-SmartBox "Message beaucoup plus long" -WidthMode Auto

Write-Host "`n=== Mode Fixed ===`n"
Write-SmartBox "Court" -WidthMode Fixed -Width 40
Write-SmartBox "Message beaucoup plus long" -WidthMode Fixed -Width 40

Write-Host "`n=== Mode Min ===`n"
Write-SmartBox "Court" -WidthMode Min -MinWidth 30
Write-SmartBox "Message beaucoup plus long" -WidthMode Min -MinWidth 30
```

> [!tip] Choix du mode
> 
> - **Auto** : Pour des messages de longueur variable sans contrainte de mise en page
> - **Fixed** : Pour créer des colonnes ou aligner plusieurs boîtes
> - **Min** : Pour garantir une largeur minimale tout en restant flexible

---

## 🎨 Styles prédéfinis

Créer des styles visuels cohérents pour différents types de messages.

### Fonction avec styles intégrés

```powershell
function Write-StyledBox {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Question', 'Custom')]
        [string]$Style = 'Info',
        
        [ConsoleColor]$CustomColor,
        [string]$CustomIcon,
        [int]$Width = 60
    )
    
    # Définition des styles
    $styles = @{
        Info = @{
            Color = 'Cyan'
            Icon = 'ℹ'
            Prefix = 'INFO'
        }
        Success = @{
            Color = 'Green'
            Icon = '✓'
            Prefix = 'SUCCÈS'
        }
        Warning = @{
            Color = 'Yellow'
            Icon = '⚠'
            Prefix = 'ATTENTION'
        }
        Error = @{
            Color = 'Red'
            Icon = '✗'
            Prefix = 'ERREUR'
        }
        Question = @{
            Color = 'Magenta'
            Icon = '?'
            Prefix = 'QUESTION'
        }
    }
    
    # Sélectionner le style
    if ($Style -eq 'Custom') {
        $currentStyle = @{
            Color = $CustomColor
            Icon = $CustomIcon
            Prefix = ''
        }
    } else {
        $currentStyle = $styles[$Style]
    }
    
    # Formater le message avec icône
    $fullMessage = "$($currentStyle.Icon) $Message"
    $messageLength = $fullMessage.Length
    
    # Construire la boîte
    $topBorder = "┌" + ("─" * 2) + "[ $($currentStyle.Prefix) ]" + ("─" * ($Width - $currentStyle.Prefix.Length - 6)) + "┐"
    
    $padding = $Width - $messageLength - 2
    $leftPad = [math]::Floor($padding / 2)
    $rightPad = $padding - $leftPad
    $content = "│" + (" " * $leftPad) + $fullMessage + (" " * $rightPad) + "│"
    
    $bottomBorder = "└" + ("─" * $Width) + "┘"
    
    # Affichage avec couleur
    Write-Host $topBorder -ForegroundColor $currentStyle.Color
    Write-Host $content -ForegroundColor $currentStyle.Color
    Write-Host $bottomBorder -ForegroundColor $currentStyle.Color
}

# Exemples d'utilisation
Write-StyledBox -Message "Connexion à la base de données établie" -Style Info
Write-Host ""
Write-StyledBox -Message "Sauvegarde terminée avec succès" -Style Success
Write-Host ""
Write-StyledBox -Message "Espace disque faible (< 10%)" -Style Warning
Write-Host ""
Write-StyledBox -Message "Impossible d'accéder au fichier" -Style Error
Write-Host ""
Write-StyledBox -Message "Voulez-vous continuer ?" -Style Question
```

**Résultat** :

```
┌──[ INFO ]────────────────────────────────────────────┐
│        ℹ Connexion à la base de données établie    │
└──────────────────────────────────────────────────────┘

┌──[ SUCCÈS ]──────────────────────────────────────────┐
│        ✓ Sauvegarde terminée avec succès             │
└──────────────────────────────────────────────────────┘

┌──[ ATTENTION ]───────────────────────────────────────┐
│        ⚠ Espace disque faible (< 10%)              │
└──────────────────────────────────────────────────────┘

┌──[ ERREUR ]──────────────────────────────────────────┐
│        ✗ Impossible d'accéder au fichier            │
└──────────────────────────────────────────────────────┘

┌──[ QUESTION ]────────────────────────────────────────┐
│        ? Voulez-vous continuer ?                     │
└──────────────────────────────────────────────────────┘
```

### Styles avec bordures doubles

```powershell
function Write-DoubleBox {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ValidateSet('Success', 'Critical')]
        [string]$Emphasis = 'Success',
        
        [int]$Width = 60
    )
    
    $color = if ($Emphasis -eq 'Success') { 'Green' } else { 'Red' }
    
    # Caractères double ligne
    $topBorder = "╔" + ("═" * $Width) + "╗"
    
    $padding = $Width - $Message.Length - 2
    $leftPad = [math]::Floor($padding / 2)
    $rightPad = $padding - $leftPad
    $content = "║" + (" " * $leftPad) + $Message + (" " * $rightPad) + "║"
    
    $bottomBorder = "╚" + ("═" * $Width) + "╝"
    
    Write-Host $topBorder -ForegroundColor $color
    Write-Host $content -ForegroundColor $color
    Write-Host $bottomBorder -ForegroundColor $color
}

# Utilisation
Write-DoubleBox -Message "OPÉRATION RÉUSSIE" -Emphasis Success
Write-Host ""
Write-DoubleBox -Message "ERREUR CRITIQUE DÉTECTÉE" -Emphasis Critical
```

---

## ⚠️ Pièges courants

> [!warning] Encodage de la console Les caractères Unicode peuvent ne pas s'afficher correctement si l'encodage de la console n'est pas configuré.
> 
> **Solution** :
> 
> ```powershell
> [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
> $PSDefaultParameterValues['*:Encoding'] = 'utf8'
> ```

> [!warning] Calcul de largeur avec caractères spéciaux Les emojis et certains caractères Unicode comptent pour plus d'un caractère en largeur d'affichage.
> 
> **Problème** :
> 
> ```powershell
> $message = "🎉 Succès"
> $width = $message.Length  # Retourne 8 mais affiche comme 9 caractères
> ```
> 
> **Solution** : Tester manuellement ou éviter les emojis dans les calculs de largeur précis.

> [!warning] Performance dans les boucles Créer des boîtes dans des boucles serrées impacte significativement les performances.
> 
> **Mauvais** :
> 
> ```powershell
> foreach ($file in $files) {
>     Write-StyledBox "Traitement de $file" -Style Info
> }
> ```
> 
> **Bon** :
> 
> ```powershell
> foreach ($file in $files) {
>     Write-Host "Traitement de $file..." -ForegroundColor Cyan
> }
> # Une seule boîte à la fin
> Write-StyledBox "Traitement terminé : $($files.Count) fichiers" -Style Success
> ```

> [!warning] Largeur de console variable La largeur de la console peut varier selon l'environnement (PowerShell ISE, Terminal, VS Code).
> 
> **Solution** :
> 
> ```powershell
> $consoleWidth = $host.UI.RawUI.WindowSize.Width
> $maxBoxWidth = [math]::Min(80, $consoleWidth - 5)  # Marge de sécurité
> ```

> [!warning] Alignement avec texte coloré L'utilisation de `Write-Host` avec `-NoNewline` et différentes couleurs peut perturber l'alignement.
> 
> **Conseil** : Calculer toutes les longueurs AVANT de colorer, et utiliser des longueurs fixes.

---

## 💡 Astuces avancées

### Boîtes imbriquées

```powershell
function Write-NestedBox {
    param(
        [string]$OuterTitle,
        [string]$InnerTitle,
        [string]$Message,
        [int]$OuterWidth = 70
    )
    
    $innerWidth = $OuterWidth - 6  # Marge intérieure
    
    # Boîte externe - bordure supérieure
    Write-Host ("┌" + ("─" * 2) + "[ $OuterTitle ]" + ("─" * ($OuterWidth - $OuterTitle.Length - 6)) + "┐") -ForegroundColor Cyan
    Write-Host ("│" + (" " * $OuterWidth) + "│") -ForegroundColor Cyan
    
    # Boîte interne
    $innerTop = "│  ┌" + ("─" * 2) + "[ $InnerTitle ]" + ("─" * ($innerWidth - $InnerTitle.Length - 6)) + "┐" + (" " * 2) + "│"
    Write-Host $innerTop -ForegroundColor Cyan
    
    $padding = $innerWidth - $Message.Length - 2
    $innerContent = "│  │ $Message" + (" " * $padding) + "│" + (" " * 2) + "│"
    Write-Host $innerContent -ForegroundColor White
    
    $innerBottom = "│  └" + ("─" * $innerWidth) + "┘" + (" " * 2) + "│"
    Write-Host $innerBottom -ForegroundColor Cyan
    
    # Boîte externe - bordure inférieure
    Write-Host ("│" + (" " * $OuterWidth) + "│") -ForegroundColor Cyan
    Write-Host ("└" + ("─" * $OuterWidth) + "┘") -ForegroundColor Cyan
}

# Utilisation
Write-NestedBox -OuterTitle "SYSTÈME" -InnerTitle "Réseau" -Message "Connexion active : 192.168.1.100"
```

### Boîtes avec progression

```powershell
function Write-ProgressBox {
    param(
        [string]$Task,
        [int]$Percent,
        [int]$Width = 50
    )
    
    $barWidth = $Width - 10  # Espace pour le texte du pourcentage
    $filled = [math]::Floor($barWidth * $Percent / 100)
    $empty = $barWidth - $filled
    
    $progressBar = ("█" * $filled) + ("░" * $empty)
    
    Write-Host ("┌" + ("─" * $Width) + "┐") -ForegroundColor Gray
    Write-Host ("│ $Task" + (" " * ($Width - $Task.Length - 1)) + "│") -ForegroundColor White
    Write-Host ("│ [$progressBar] $Percent%" + (" " * ($Width - $barWidth - 6)) + "│") -ForegroundColor Cyan
    Write-Host ("└" + ("─" * $Width) + "┘") -ForegroundColor Gray
}

# Simulation
Write-ProgressBox -Task "Installation..." -Percent 35
```

### Cache de boîtes pré-calculées

Pour améliorer les performances, pré-calculer les boîtes répétitives :

```powershell
$script:BoxCache = @{}

function Get-CachedBox {
    param(
        [string]$Message,
        [string]$Style,
        [int]$Width
    )
    
    $key = "$Style|$Width|$Message"
    
    if (-not $script:BoxCache.ContainsKey($key)) {
        # Capturer la sortie de Write-StyledBox dans une variable
        $output = Write-StyledBox -Message $Message -Style $Style -Width $Width | Out-String
        $script:BoxCache[$key] = $output
    }
    
    Write-Host $script:BoxCache[$key] -NoNewline
}
```

### Boîtes avec sections multiples

```powershell
function Write-SectionBox {
    param(
        [hashtable]$Sections,  # @{ "Titre1" = "Contenu1"; "Titre2" = "Contenu2" }
        [int]$Width = 60,
        [ConsoleColor]$Color = 'White'
    )
    
    # Bordure supérieure
    Write-Host ("┌" + ("─" * $Width) + "┐") -ForegroundColor $Color
    
    $isFirst = $true
    foreach ($section in $Sections.GetEnumerator()) {
        # Séparateur entre sections (sauf pour la première)
        if (-not $isFirst) {
            Write-Host ("├" + ("─" * $Width) + "┤") -ForegroundColor $Color
        }
        $isFirst = $false
        
        # Titre de section
        $titlePadding = $Width - $section.Key.Length - 2
        Write-Host ("│ " + $section.Key + (" " * $titlePadding) + "│") -ForegroundColor Cyan
        
        # Contenu
        $contentPadding = $Width - $section.Value.Length - 4
        Write-Host ("│   " + $section.Value + (" " * $contentPadding) + " │") -ForegroundColor $Color
    }
    
    # Bordure inférieure
    Write-Host ("└" + ("─" * $Width) + "┘") -ForegroundColor $Color
}

# Utilisation
$infos = [ordered]@{
    "Système" = "Windows Server 2022"
    "Mémoire" = "16 GB RAM"
    "Processeur" = "Intel Xeon E5-2680"
    "Disque" = "500 GB SSD"
}

Write-SectionBox -Sections $infos -Width 50
```

**Résultat** :

```
┌──────────────────────────────────────────────────┐
│ Système                                          │
│   Windows Server 2022                            │
├──────────────────────────────────────────────────┤
│ Mémoire                                          │
│   16 GB RAM                                      │
├──────────────────────────────────────────────────┤
│ Processeur                                       │
│   Intel Xeon E5-2680                             │
├──────────────────────────────────────────────────┤
│ Disque                                           │
│   500 GB SSD                                     │
└──────────────────────────────────────────────────┘
```

### Boîtes avec alignement colonne

```powershell
function Write-ColumnBox {
    param(
        [hashtable]$Data,  # @{ "Clé1" = "Valeur1"; "Clé2" = "Valeur2" }
        [int]$Width = 60,
        [ConsoleColor]$Color = 'White'
    )
    
    # Trouver la longueur maximale des clés
    $maxKeyLength = ($Data.Keys | Measure-Object -Property Length -Maximum).Maximum
    $separator = " : "
    
    # Bordure supérieure
    Write-Host ("┌" + ("─" * $Width) + "┐") -ForegroundColor $Color
    
    foreach ($entry in $Data.GetEnumerator()) {
        $key = $entry.Key.PadRight($maxKeyLength)
        $value = $entry.Value
        $line = "$key$separator$value"
        
        $padding = $Width - $line.Length - 2
        Write-Host ("│ $line" + (" " * $padding) + " │") -ForegroundColor $Color
    }
    
    # Bordure inférieure
    Write-Host ("└" + ("─" * $Width) + "┘") -ForegroundColor $Color
}

# Utilisation
$config = [ordered]@{
    "Serveur" = "PROD-SQL-01"
    "Port" = "1433"
    "Base" = "ClientDB"
    "Utilisateur" = "sa_admin"
}

Write-ColumnBox -Data $config -Width 50
```

**Résultat** :

```
┌────────────────────────────────────────────────┐
│ Serveur     : PROD-SQL-01                      │
│ Port        : 1433                             │
│ Base        : ClientDB                         │
│ Utilisateur : sa_admin                         │
└────────────────────────────────────────────────┘
```

### Boîtes adaptatives selon le terminal

```powershell
function Write-AdaptiveBox {
    param(
        [string]$Message,
        [ConsoleColor]$Color = 'White'
    )
    
    # Détecter la largeur de la console
    $consoleWidth = try {
        $host.UI.RawUI.WindowSize.Width
    } catch {
        80  # Valeur par défaut
    }
    
    # Adapter la largeur de la boîte
    $maxWidth = [math]::Min(80, $consoleWidth - 4)
    $messageLength = $Message.Length
    
    # Si le message est trop long, le couper
    if ($messageLength + 4 -gt $maxWidth) {
        $availableSpace = $maxWidth - 7  # -7 pour "... │"
        $Message = $Message.Substring(0, $availableSpace) + "..."
        $boxWidth = $maxWidth
    } else {
        $boxWidth = $messageLength + 4
    }
    
    # Afficher la boîte
    Write-Host ("┌" + ("─" * $boxWidth) + "┐") -ForegroundColor $Color
    $padding = $boxWidth - $Message.Length - 2
    Write-Host ("│ $Message" + (" " * $padding) + " │") -ForegroundColor $Color
    Write-Host ("└" + ("─" * $boxWidth) + "┘") -ForegroundColor $Color
}

# S'adapte automatiquement à la largeur du terminal
Write-AdaptiveBox "Ce message s'adaptera à votre terminal"
```

### Boîtes avec bordures arrondies

```powershell
function Write-RoundedBox {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [int]$Width = 50,
        [ConsoleColor]$Color = 'White'
    )
    
    # Caractères arrondis
    $topBorder = "╭" + ("─" * $Width) + "╮"
    $bottomBorder = "╰" + ("─" * $Width) + "╯"
    
    $padding = $Width - $Message.Length - 2
    $leftPad = [math]::Floor($padding / 2)
    $rightPad = $padding - $leftPad
    $content = "│" + (" " * $leftPad) + $Message + (" " * $rightPad) + "│"
    
    Write-Host $topBorder -ForegroundColor $Color
    Write-Host $content -ForegroundColor $Color
    Write-Host $bottomBorder -ForegroundColor $Color
}

# Utilisation
Write-RoundedBox "Style moderne avec coins arrondis" -Color Magenta
```

### Boîtes avec ombre

```powershell
function Write-ShadowBox {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [int]$Width = 50,
        [ConsoleColor]$BoxColor = 'White',
        [ConsoleColor]$ShadowColor = 'DarkGray'
    )
    
    $padding = $Width - $Message.Length - 2
    $leftPad = [math]::Floor($padding / 2)
    $rightPad = $padding - $leftPad
    
    # Bordure supérieure
    Write-Host ("┌" + ("─" * $Width) + "┐") -ForegroundColor $BoxColor
    
    # Contenu
    Write-Host ("│" + (" " * $leftPad) + $Message + (" " * $rightPad) + "│") -ForegroundColor $BoxColor -NoNewline
    Write-Host "▓" -ForegroundColor $ShadowColor
    
    # Bordure inférieure
    Write-Host ("└" + ("─" * $Width) + "┘") -ForegroundColor $BoxColor -NoNewline
    Write-Host "▓" -ForegroundColor $ShadowColor
    
    # Ligne d'ombre complète
    Write-Host (" " + ("▓" * ($Width + 2))) -ForegroundColor $ShadowColor
}

# Utilisation
Write-ShadowBox "Message avec effet d'ombre" -Width 40
```

### Fonction tout-en-un complète

```powershell
function Write-Box {
    [CmdletBinding(DefaultParameterSetName='Simple')]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Message,
        
        [Parameter(ParameterSetName='Simple')]
        [Parameter(ParameterSetName='Styled')]
        [int]$Width = 60,
        
        [Parameter(ParameterSetName='Simple')]
        [ConsoleColor]$Color = 'White',
        
        [Parameter(ParameterSetName='Styled', Mandatory)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Question')]
        [string]$Style,
        
        [Parameter(ParameterSetName='Simple')]
        [Parameter(ParameterSetName='Styled')]
        [string]$Title,
        
        [Parameter(ParameterSetName='Simple')]
        [Parameter(ParameterSetName='Styled')]
        [ValidateSet('Simple', 'Double', 'Rounded', 'Bold')]
        [string]$BorderStyle = 'Simple',
        
        [Parameter(ParameterSetName='Simple')]
        [Parameter(ParameterSetName='Styled')]
        [switch]$Center
    )
    
    # Définir les caractères selon le style
    $borders = @{
        Simple = @{ TL='┌'; TR='┐'; BL='└'; BR='┘'; H='─'; V='│' }
        Double = @{ TL='╔'; TR='╗'; BL='╚'; BR='╝'; H='═'; V='║' }
        Rounded = @{ TL='╭'; TR='╮'; BL='╰'; BR='╯'; H='─'; V='│' }
        Bold = @{ TL='┏'; TR='┓'; BL='┗'; BR='┛'; H='━'; V='┃' }
    }
    
    $b = $borders[$BorderStyle]
    
    # Définir la couleur selon le style
    if ($PSCmdlet.ParameterSetName -eq 'Styled') {
        $styleColors = @{
            Info = 'Cyan'
            Success = 'Green'
            Warning = 'Yellow'
            Error = 'Red'
            Question = 'Magenta'
        }
        $Color = $styleColors[$Style]
        
        $icons = @{
            Info = 'ℹ'
            Success = '✓'
            Warning = '⚠'
            Error = '✗'
            Question = '?'
        }
        $Message = "$($icons[$Style]) $Message"
    }
    
    # Bordure supérieure avec titre optionnel
    if ($Title) {
        $titleFormatted = "[ $Title ]"
        $leftDashes = 2
        $rightDashes = $Width - $titleFormatted.Length - $leftDashes
        
        Write-Host "$($b.TL)" -NoNewline -ForegroundColor $Color
        Write-Host ($b.H * $leftDashes) -NoNewline -ForegroundColor $Color
        Write-Host $titleFormatted -NoNewline -ForegroundColor Cyan
        Write-Host ($b.H * $rightDashes) -NoNewline -ForegroundColor $Color
        Write-Host "$($b.TR)" -ForegroundColor $Color
    } else {
        Write-Host "$($b.TL)$($b.H * $Width)$($b.TR)" -ForegroundColor $Color
    }
    
    # Contenu
    if ($Center) {
        $padding = $Width - $Message.Length - 2
        $leftPad = [math]::Floor($padding / 2)
        $rightPad = $padding - $leftPad
        Write-Host "$($b.V)$(' ' * $leftPad)$Message$(' ' * $rightPad) $($b.V)" -ForegroundColor $Color
    } else {
        $padding = $Width - $Message.Length - 2
        Write-Host "$($b.V) $Message$(' ' * $padding) $($b.V)" -ForegroundColor $Color
    }
    
    # Bordure inférieure
    Write-Host "$($b.BL)$($b.H * $Width)$($b.BR)" -ForegroundColor $Color
}

# Exemples d'utilisation variés
Write-Box "Message simple"
Write-Box "Message centré" -Center
Write-Box "Avec titre" -Title "INFO" -BorderStyle Double
Write-Box "Style prédéfini" -Style Success -BorderStyle Rounded
Write-Box "Erreur critique" -Style Error -BorderStyle Bold -Title "ALERTE"
```

> [!tip] Fonction modulaire Cette fonction tout-en-un combine tous les concepts vus précédemment. Elle peut servir de base pour vos propres scripts et être étendue selon vos besoins spécifiques.

---

## 📚 Récapitulatif

Les boîtes et encadrements dans PowerShell permettent de :

✅ **Structurer visuellement** les sorties console pour améliorer la lisibilité ✅ **Hiérarchiser l'information** avec des styles différenciés (info, warning, error, success) ✅ **Professionnaliser** l'apparence des scripts d'administration et d'automatisation ✅ **Attirer l'attention** sur les messages critiques ou les résultats importants

**Points clés à retenir** :

|Concept|Usage recommandé|
|---|---|
|**Fonction Write-Box simple**|Base pour tous les encadrements personnalisés|
|**Titre dans bordure**|Identifier rapidement le type de message|
|**Multi-lignes**|Afficher des résultats détaillés ou résumés|
|**Largeur auto/fixe**|Auto pour flexibilité, fixe pour alignement|
|**Styles prédéfinis**|Cohérence visuelle dans tout le script|
|**Caractères Unicode**|Bordures élégantes (attention à l'encodage)|
|**Performance**|Éviter dans les boucles intensives|

Les boîtes sont particulièrement utiles pour :

- 🎯 Scripts interactifs avec l'utilisateur
- 📊 Rapports et dashboards console
- ⚙️ Scripts d'installation ou de configuration
- 🔧 Outils d'administration système
- 📝 Logs structurés et lisibles

Avec ces techniques, vous pouvez créer des interfaces console professionnelles et agréables qui facilitent la compréhension et l'utilisation de vos scripts PowerShell.