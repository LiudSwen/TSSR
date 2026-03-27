

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

Les menus interactifs constituent la base d'une interface utilisateur conviviale pour vos scripts PowerShell. Au lieu de passer des paramètres en ligne de commande, l'utilisateur peut naviguer visuellement dans les options disponibles.

> [!info] Pourquoi créer des menus ?
> 
> - **Accessibilité** : L'utilisateur n'a pas besoin de connaître tous les paramètres
> - **Guidage** : Réduit les erreurs en présentant clairement les options valides
> - **Professionnalisme** : Donne une apparence soignée à vos scripts
> - **Réutilisabilité** : Une fois créées, vos fonctions de menu peuvent être réutilisées

> [!tip] Quand utiliser des menus ?
> 
> - Scripts destinés à des utilisateurs non techniques
> - Outils d'administration avec multiples fonctionnalités
> - Scripts interactifs nécessitant plusieurs choix successifs
> - Situations où les paramètres sont nombreux ou complexes

---

## 🖼️ Fonctions pour dessiner des bordures

Les bordures permettent de délimiter visuellement les sections de votre menu et d'améliorer la lisibilité.

### Caractères de bordure

PowerShell utilise Unicode, vous pouvez donc employer des caractères spéciaux pour créer des bordures élégantes :

|Style|Coins|Horizontale|Verticale|Exemple|
|---|---|---|---|---|
|Simple|`+`|`-`|`|`|
|Double|`╔ ╗ ╚ ╝`|`═`|`║`|`╔═══╗`|
|Simple arrondi|`╭ ╮ ╰ ╯`|`─`|`│`|`╭───╮`|
|Mixte|`┌ ┐ └ ┘`|`─`|`│`|`┌───┐`|

### Fonction de bordure supérieure

```powershell
function Show-TopBorder {
    param(
        [int]$Width = 60,
        [string]$Style = "double"
    )
    
    # Définition des caractères selon le style
    switch ($Style) {
        "simple" {
            $left = "+"
            $right = "+"
            $line = "-"
        }
        "double" {
            $left = "╔"
            $right = "╗"
            $line = "═"
        }
        "rounded" {
            $left = "╭"
            $right = "╮"
            $line = "─"
        }
        default {
            $left = "┌"
            $right = "┐"
            $line = "─"
        }
    }
    
    # Construction de la bordure
    Write-Host "$left$($line * ($Width - 2))$right" -ForegroundColor Cyan
}
```

### Fonction de bordure inférieure

```powershell
function Show-BottomBorder {
    param(
        [int]$Width = 60,
        [string]$Style = "double"
    )
    
    switch ($Style) {
        "simple" {
            $left = "+"
            $right = "+"
            $line = "-"
        }
        "double" {
            $left = "╚"
            $right = "╝"
            $line = "═"
        }
        "rounded" {
            $left = "╰"
            $right = "╯"
            $line = "─"
        }
        default {
            $left = "└"
            $right = "┘"
            $line = "─"
        }
    }
    
    Write-Host "$left$($line * ($Width - 2))$right" -ForegroundColor Cyan
}
```

### Fonction de ligne vide avec bordures

```powershell
function Show-EmptyLine {
    param(
        [int]$Width = 60,
        [string]$Style = "double"
    )
    
    switch ($Style) {
        "simple" { $border = "|" }
        "double" { $border = "║" }
        default { $border = "│" }
    }
    
    Write-Host "$border$(' ' * ($Width - 2))$border" -ForegroundColor Cyan
}
```

> [!example] Utilisation des bordures
> 
> ```powershell
> Show-TopBorder -Width 50 -Style "double"
> Show-EmptyLine -Width 50 -Style "double"
> Write-Host "║" -NoNewline -ForegroundColor Cyan
> Write-Host "    Contenu du menu" -NoNewline
> Write-Host (' ' * 26) -NoNewline
> Write-Host "║" -ForegroundColor Cyan
> Show-EmptyLine -Width 50 -Style "double"
> Show-BottomBorder -Width 50 -Style "double"
> ```

> [!tip] Astuce - Largeur dynamique Vous pouvez calculer automatiquement la largeur nécessaire en fonction du contenu le plus long :
> 
> ```powershell
> $options = @("Option courte", "Option avec un texte très long", "Autre")
> $maxLength = ($options | Measure-Object -Property Length -Maximum).Maximum
> $width = $maxLength + 10  # Ajout de marge
> ```

---

## 📋 Affichage de titres encadrés

Les titres encadrés permettent de mettre en valeur l'en-tête de votre menu et de le rendre immédiatement identifiable.

### Fonction de titre centré

```powershell
function Show-Title {
    param(
        [string]$Title,
        [int]$Width = 60,
        [string]$Style = "double",
        [ConsoleColor]$TitleColor = "Yellow",
        [ConsoleColor]$BorderColor = "Cyan"
    )
    
    # Caractères de bordure selon le style
    switch ($Style) {
        "simple" { $border = "|" }
        "double" { $border = "║" }
        default { $border = "│" }
    }
    
    # Calcul du padding pour centrer le titre
    $availableSpace = $Width - 2  # Espace sans les bordures
    $padding = [math]::Max(0, ($availableSpace - $Title.Length) / 2)
    $leftPadding = ' ' * [math]::Floor($padding)
    $rightPadding = ' ' * [math]::Ceiling($padding)
    
    # Affichage du titre centré
    Write-Host $border -NoNewline -ForegroundColor $BorderColor
    Write-Host $leftPadding -NoNewline
    Write-Host $Title -NoNewline -ForegroundColor $TitleColor
    Write-Host $rightPadding -NoNewline
    Write-Host $border -ForegroundColor $BorderColor
}
```

### Fonction de séparateur

```powershell
function Show-Separator {
    param(
        [int]$Width = 60,
        [string]$Style = "double"
    )
    
    switch ($Style) {
        "simple" {
            $left = "+"
            $right = "+"
            $line = "-"
        }
        "double" {
            $left = "╠"
            $right = "╣"
            $line = "═"
        }
        default {
            $left = "├"
            $right = "┤"
            $line = "─"
        }
    }
    
    Write-Host "$left$($line * ($Width - 2))$right" -ForegroundColor Cyan
}
```

### Fonction d'en-tête complet

```powershell
function Show-MenuHeader {
    param(
        [string]$Title,
        [string]$Subtitle = "",
        [int]$Width = 60,
        [string]$Style = "double"
    )
    
    Show-TopBorder -Width $Width -Style $Style
    Show-EmptyLine -Width $Width -Style $Style
    Show-Title -Title $Title -Width $Width -Style $Style -TitleColor Yellow
    
    if ($Subtitle) {
        Show-Title -Title $Subtitle -Width $Width -Style $Style -TitleColor Gray
    }
    
    Show-EmptyLine -Width $Width -Style $Style
    Show-Separator -Width $Width -Style $Style
}
```

> [!example] Exemple d'en-tête complet
> 
> ```powershell
> Clear-Host
> Show-MenuHeader -Title "MENU PRINCIPAL" -Subtitle "Gestion des utilisateurs" -Width 50
> ```
> 
> Résultat :
> 
> ```
> ╔════════════════════════════════════════════════╗
> ║                                                ║
> ║               MENU PRINCIPAL                   ║
> ║           Gestion des utilisateurs             ║
> ║                                                ║
> ╠════════════════════════════════════════════════╣
> ```

---

## 📝 Liste d'options formatée

L'affichage des options de manière claire et structurée est essentiel pour guider l'utilisateur dans sa navigation.

### Fonction d'affichage d'une option

```powershell
function Show-Option {
    param(
        [string]$Number,
        [string]$Description,
        [int]$Width = 60,
        [string]$Style = "double",
        [ConsoleColor]$NumberColor = "Green",
        [ConsoleColor]$TextColor = "White"
    )
    
    switch ($Style) {
        "simple" { $border = "|" }
        "double" { $border = "║" }
        default { $border = "│" }
    }
    
    # Format de l'option : "  [1] Description"
    $optionText = "  [$Number] $Description"
    
    # Calcul du padding pour aligner à droite
    $availableSpace = $Width - 2
    $padding = ' ' * [math]::Max(0, $availableSpace - $optionText.Length)
    
    # Affichage
    Write-Host $border -NoNewline -ForegroundColor Cyan
    Write-Host "  [" -NoNewline
    Write-Host $Number -NoNewline -ForegroundColor $NumberColor
    Write-Host "] " -NoNewline
    Write-Host $Description -NoNewline -ForegroundColor $TextColor
    Write-Host $padding -NoNewline
    Write-Host $border -ForegroundColor Cyan
}
```

### Fonction d'affichage d'une liste d'options

```powershell
function Show-OptionList {
    param(
        [hashtable]$Options,
        [int]$Width = 60,
        [string]$Style = "double"
    )
    
    # Tri des clés pour affichage ordonné
    $sortedKeys = $Options.Keys | Sort-Object
    
    foreach ($key in $sortedKeys) {
        Show-Option -Number $key -Description $Options[$key] -Width $Width -Style $Style
    }
}
```

### Fonction d'option de sortie

```powershell
function Show-ExitOption {
    param(
        [string]$ExitKey = "0",
        [string]$ExitText = "Quitter",
        [int]$Width = 60,
        [string]$Style = "double"
    )
    
    Show-EmptyLine -Width $Width -Style $Style
    Show-Option -Number $ExitKey -Description $ExitText -Width $Width -Style $Style -NumberColor Red
}
```

> [!example] Exemple de liste d'options
> 
> ```powershell
> $menuOptions = @{
>     "1" = "Créer un utilisateur"
>     "2" = "Modifier un utilisateur"
>     "3" = "Supprimer un utilisateur"
>     "4" = "Lister les utilisateurs"
> }
> 
> Show-EmptyLine -Width 50
> Show-OptionList -Options $menuOptions -Width 50
> Show-ExitOption -Width 50
> ```

> [!tip] Options avec icônes Vous pouvez enrichir vos options avec des emojis ou des symboles Unicode :
> 
> ```powershell
> $menuOptions = @{
>     "1" = "➕ Créer un utilisateur"
>     "2" = "✏️ Modifier un utilisateur"
>     "3" = "🗑️ Supprimer un utilisateur"
>     "4" = "📋 Lister les utilisateurs"
> }
> ```

---

## ⌨️ Gestion de la saisie utilisateur

La gestion de la saisie utilisateur est le cœur de l'interactivité de votre menu. Elle doit être robuste et gérer les erreurs élégantes.

### Fonction de prompt basique

```powershell
function Get-MenuChoice {
    param(
        [string]$Prompt = "Votre choix",
        [int]$Width = 60,
        [string]$Style = "double"
    )
    
    switch ($Style) {
        "simple" { $border = "|" }
        "double" { $border = "║" }
        default { $border = "│" }
    }
    
    Show-EmptyLine -Width $Width -Style $Style
    
    # Affichage du prompt
    Write-Host $border -NoNewline -ForegroundColor Cyan
    Write-Host "  $Prompt : " -NoNewline -ForegroundColor Yellow
    
    # Lecture de la saisie
    $choice = Read-Host
    
    return $choice
}
```

### Fonction de validation de la saisie

```powershell
function Test-ValidChoice {
    param(
        [string]$Choice,
        [array]$ValidChoices
    )
    
    return $ValidChoices -contains $Choice
}
```

### Fonction de saisie avec validation

```powershell
function Get-ValidatedChoice {
    param(
        [array]$ValidChoices,
        [string]$Prompt = "Votre choix",
        [int]$Width = 60,
        [string]$Style = "double",
        [int]$MaxAttempts = 3
    )
    
    $attempt = 0
    
    do {
        $choice = Get-MenuChoice -Prompt $Prompt -Width $Width -Style $Style
        
        if (Test-ValidChoice -Choice $choice -ValidChoices $ValidChoices) {
            return $choice
        }
        
        $attempt++
        
        if ($attempt -lt $MaxAttempts) {
            Show-ErrorMessage -Message "Choix invalide. Veuillez réessayer." -Width $Width -Style $Style
        }
        
    } while ($attempt -lt $MaxAttempts)
    
    Show-ErrorMessage -Message "Trop de tentatives invalides. Retour au menu." -Width $Width -Style $Style
    return $null
}
```

### Fonction d'affichage d'erreur

```powershell
function Show-ErrorMessage {
    param(
        [string]$Message,
        [int]$Width = 60,
        [string]$Style = "double"
    )
    
    switch ($Style) {
        "simple" { $border = "|" }
        "double" { $border = "║" }
        default { $border = "│" }
    }
    
    Show-EmptyLine -Width $Width -Style $Style
    
    Write-Host $border -NoNewline -ForegroundColor Cyan
    Write-Host "  ❌ " -NoNewline -ForegroundColor Red
    Write-Host $Message -NoNewline -ForegroundColor Red
    
    $padding = ' ' * [math]::Max(0, ($Width - 2) - $Message.Length - 4)
    Write-Host $padding -NoNewline
    Write-Host $border -ForegroundColor Cyan
    
    Start-Sleep -Seconds 2
}
```

### Fonction de confirmation

```powershell
function Get-UserConfirmation {
    param(
        [string]$Message = "Êtes-vous sûr ?",
        [int]$Width = 60,
        [string]$Style = "double"
    )
    
    switch ($Style) {
        "simple" { $border = "|" }
        "double" { $border = "║" }
        default { $border = "│" }
    }
    
    Show-EmptyLine -Width $Width -Style $Style
    
    Write-Host $border -NoNewline -ForegroundColor Cyan
    Write-Host "  ⚠️  " -NoNewline -ForegroundColor Yellow
    Write-Host $Message -NoNewline -ForegroundColor Yellow
    Write-Host " (O/N) : " -NoNewline
    
    $response = Read-Host
    
    return ($response -eq "O" -or $response -eq "o")
}
```

> [!example] Exemple de gestion de saisie complète
> 
> ```powershell
> $validChoices = @("1", "2", "3", "4", "0")
> $choice = Get-ValidatedChoice -ValidChoices $validChoices -Prompt "Sélectionnez une option" -Width 50
> 
> if ($choice) {
>     if ($choice -eq "3") {
>         $confirmed = Get-UserConfirmation -Message "Voulez-vous vraiment supprimer ?" -Width 50
>         if ($confirmed) {
>             # Exécuter l'action
>         }
>     }
> }
> ```

> [!warning] Attention à la casse Par défaut, PowerShell est sensible à la casse. Utilisez `-eq` pour une comparaison sensible à la casse, ou `-ieq` pour ignorer la casse :
> 
> ```powershell
> # Sensible à la casse
> if ($choice -eq "O") { }
> 
> # Insensible à la casse (recommandé pour les confirmations)
> if ($choice -ieq "O") { }
> ```

---

## 🎭 Menu complet - Exemple intégré

Voici un exemple complet qui intègre tous les éléments vus précédemment dans un menu fonctionnel.

```powershell
# Fonction principale du menu
function Show-MainMenu {
    param(
        [int]$Width = 60,
        [string]$Style = "double"
    )
    
    do {
        Clear-Host
        
        # En-tête
        Show-MenuHeader -Title "SYSTÈME DE GESTION" -Subtitle "Version 1.0" -Width $Width -Style $Style
        
        # Options
        Show-EmptyLine -Width $Width -Style $Style
        
        $options = @{
            "1" = "➕ Ajouter un élément"
            "2" = "✏️  Modifier un élément"
            "3" = "🗑️  Supprimer un élément"
            "4" = "📋 Afficher la liste"
            "5" = "⚙️  Paramètres"
        }
        
        Show-OptionList -Options $options -Width $Width -Style $Style
        Show-ExitOption -ExitKey "0" -ExitText "❌ Quitter" -Width $Width -Style $Style
        Show-EmptyLine -Width $Width -Style $Style
        
        # Pied de page
        Show-BottomBorder -Width $Width -Style $Style
        
        # Saisie utilisateur
        $validChoices = @("1", "2", "3", "4", "5", "0")
        $choice = Get-ValidatedChoice -ValidChoices $validChoices -Width $Width -Style $Style
        
        if ($choice) {
            # Traitement du choix
            switch ($choice) {
                "1" {
                    Clear-Host
                    Show-MenuHeader -Title "AJOUT D'ÉLÉMENT" -Width $Width -Style $Style
                    # Logique d'ajout ici
                    Write-Host "`n  ✅ Élément ajouté avec succès !`n" -ForegroundColor Green
                    Read-Host "  Appuyez sur Entrée pour continuer"
                }
                "2" {
                    Clear-Host
                    Show-MenuHeader -Title "MODIFICATION D'ÉLÉMENT" -Width $Width -Style $Style
                    # Logique de modification ici
                    Write-Host "`n  ✅ Élément modifié avec succès !`n" -ForegroundColor Green
                    Read-Host "  Appuyez sur Entrée pour continuer"
                }
                "3" {
                    $confirmed = Get-UserConfirmation -Message "Confirmer la suppression ?" -Width $Width -Style $Style
                    if ($confirmed) {
                        Clear-Host
                        Show-MenuHeader -Title "SUPPRESSION D'ÉLÉMENT" -Width $Width -Style $Style
                        # Logique de suppression ici
                        Write-Host "`n  ✅ Élément supprimé avec succès !`n" -ForegroundColor Green
                        Read-Host "  Appuyez sur Entrée pour continuer"
                    }
                }
                "4" {
                    Clear-Host
                    Show-MenuHeader -Title "LISTE DES ÉLÉMENTS" -Width $Width -Style $Style
                    # Logique d'affichage ici
                    Write-Host "`n  📋 Liste des éléments...`n" -ForegroundColor Cyan
                    Read-Host "  Appuyez sur Entrée pour continuer"
                }
                "5" {
                    Clear-Host
                    Show-MenuHeader -Title "PARAMÈTRES" -Width $Width -Style $Style
                    # Logique des paramètres ici
                    Write-Host "`n  ⚙️  Configuration des paramètres...`n" -ForegroundColor Cyan
                    Read-Host "  Appuyez sur Entrée pour continuer"
                }
                "0" {
                    $confirmed = Get-UserConfirmation -Message "Voulez-vous vraiment quitter ?" -Width $Width -Style $Style
                    if ($confirmed) {
                        Clear-Host
                        Write-Host "`n  👋 Au revoir !`n" -ForegroundColor Yellow
                        return
                    }
                }
            }
        }
        
    } while ($true)
}

# Lancement du menu
Show-MainMenu -Width 60 -Style "double"
```

> [!example] Utilisation du menu complet Copiez toutes les fonctions précédentes dans votre script, puis ajoutez la fonction `Show-MainMenu` et appelez-la. Vous obtiendrez un menu interactif complet et fonctionnel.

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges à éviter

> [!warning] Problème : Alignement incorrect **Cause** : Mauvais calcul de la largeur avec des caractères Unicode ou des emojis
> 
> ```powershell
> # ❌ Mauvais - Les emojis comptent pour 2 caractères
> $text = "✅ Option"
> $padding = ' ' * (50 - $text.Length)
> 
> # ✅ Bon - Utiliser une fonction de mesure
> function Get-DisplayLength {
>     param([string]$Text)
>     # Les emojis et certains caractères Unicode comptent double
>     $emojiPattern = '[^\u0000-\uFFFF]'
>     $emojiCount = ([regex]::Matches($Text, $emojiPattern)).Count
>     return $Text.Length + $emojiCount
> }
> ```

> [!warning] Problème : Boucle infinie **Cause** : Oubli de la condition de sortie ou mauvaise gestion du choix "0"
> 
> ```powershell
> # ❌ Mauvais
> do {
>     $choice = Get-MenuChoice
>     # Oubli de traiter le cas où choice = "0"
> } while ($choice -ne "0")  # Ne sortira jamais si on ne retourne pas
> 
> # ✅ Bon
> do {
>     $choice = Get-ValidatedChoice -ValidChoices $validChoices
>     if ($choice -eq "0") {
>         return  # Sortie explicite
>     }
> } while ($true)
> ```

> [!warning] Problème : Caractères mal affichés **Cause** : Encoding incorrect de la console
> 
> ```powershell
> # ✅ Ajoutez au début de votre script
> [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
> ```

### Bonnes pratiques

> [!tip] Utiliser des constantes pour les paramètres récurrents
> 
> ```powershell
> # En début de script
> $script:MenuWidth = 60
> $script:MenuStyle = "double"
> $script:MainColor = "Cyan"
> 
> # Dans les fonctions
> Show-TopBorder -Width $script:MenuWidth -Style $script:MenuStyle
> ```

> [!tip] Créer un module réutilisable Regroupez toutes vos fonctions de menu dans un fichier `.psm1` :
> 
> ```powershell
> # MenuFunctions.psm1
> function Show-TopBorder { ... }
> function Show-BottomBorder { ... }
> # ... autres fonctions
> 
> Export-ModuleMember -Function Show-*,Get-*
> ```
> 
> Puis importez-le dans vos scripts :
> 
> ```powershell
> Import-Module .\MenuFunctions.psm1
> Show-MainMenu
> ```

> [!tip] Tester sur différentes tailles de console
> 
> ```powershell
> # Vérifier la largeur de la console
> $consoleWidth = $Host.UI.RawUI.WindowSize.Width
> 
> if ($consoleWidth -lt 80) {
>     Write-Warning "Console trop étroite. Largeur minimale : 80 caractères"
>     $menuWidth = $consoleWidth - 5
> } else {
>     $menuWidth = 70
> }
> ```

> [!tip] Ajouter des raccourcis clavier
> 
> ```powershell
> function Get-MenuChoice {
>     param([string]$Prompt)
>     
>     Write-Host "$Prompt : " -NoNewline -ForegroundColor Yellow
>     
>     # Lecture d'une seule touche (pas besoin d'Entrée)
>     $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
>     $choice = $key.Character
>     
>     Write-Host $choice  # Afficher le choix
>     return $choice
> }
> ```

> [!tip] Gérer Ctrl+C proprement
> 
> ```powershell
> try {
>     Show-MainMenu
> } catch {
>     if ($_.Exception -is [System.Management.Automation.PipelineStoppedException]) {
>         Clear-Host
>         Write-Host "`n  ⚠️  Menu interrompu par l'utilisateur`n" -ForegroundColor Yellow
>     } else {
>         throw
>     }
> } finally {
>     # Nettoyage si nécessaire
>     [Console]::CursorVisible = $true
> }
> ```

> [!tip] Créer des thèmes de couleurs
> 
> ```powershell
> $themes = @{
>     "Default" = @{
>         Border = "Cyan"
>         Title = "Yellow"
>         Option = "White"
>         Number = "Green"
>         Error = "Red"
>     }
>     "Dark" = @{
>         Border = "DarkGray"
>         Title = "White"
>         Option = "Gray"
>         Number = "DarkCyan"
>         Error = "DarkRed"
>     }
>     "Matrix" = @{
>         Border = "Green"
>         Title = "Green"
>         Option = "DarkGreen"
>         Number = "Green"
>         Error = "Red"
>     }
> }
> 
> function Set-MenuTheme {
>     param([string]$ThemeName = "Default")
>     $script:CurrentTheme = $themes[$ThemeName]
> }
> ```

### Optimisation des performances

> [!tip] Limiter les Clear-Host
> 
> ```powershell
> # ❌ À éviter - Trop de Clear-Host provoque des scintillements
> for ($i = 0; $i -lt 10; $i++) {
>     Clear-Host
>     Write-Host "Traitement $i..."
>     Start-Sleep -Milliseconds 100
> }
> 
> # ✅ Mieux - Utiliser la position du curseur
> [Console]::CursorVisible = $false
> for ($i = 0; $i -lt 10; $i++) {
>     [Console]::SetCursorPosition(0, 5)
>     Write-Host "Traitement $i/10" -NoNewline
>     Start-Sleep -Milliseconds 100
> }
> [Console]::CursorVisible = $true
> ```

> [!tip] Mettre en cache les bordures
> 
> ```powershell
> # Pré-calculer les bordures une seule fois
> $script:TopBorder = "╔$('═' * 58)╗"
> $script:BottomBorder = "╚$('═' * 58)╝"
> $script:EmptyLine = "║$(' ' * 58)║"
> 
> # Utilisation rapide
> Write-Host $script:TopBorder -ForegroundColor Cyan
> Write-Host $script:EmptyLine -ForegroundColor Cyan
> Write-Host $script:BottomBorder -ForegroundColor Cyan
> ```

---

> [!info] 💡 Points clés à retenir
> 
> - Les menus structurés améliorent considérablement l'expérience utilisateur
> - Les fonctions réutilisables permettent de créer rapidement des interfaces cohérentes
> - La validation de la saisie est essentielle pour éviter les erreurs
> - Les bordures et la mise en forme rendent vos scripts plus professionnels et agréables à utiliser
> - Pensez toujours à l'utilisateur final : clarté, guidage et gestion des erreurs
> - Testez vos menus sur différentes tailles de console et encodages

---

## 🎯 Checklist de création de menu

Avant de finaliser votre menu, vérifiez les points suivants :

- [ ] ✅ Les bordures s'affichent correctement (encodage UTF-8)
- [ ] ✅ Tous les textes sont alignés et centrés correctement
- [ ] ✅ La largeur du menu est cohérente partout
- [ ] ✅ Les choix invalides sont gérés avec des messages d'erreur clairs
- [ ] ✅ Une option de sortie est toujours disponible
- [ ] ✅ Les confirmations sont demandées pour les actions critiques
- [ ] ✅ Le menu se redessine après chaque action
- [ ] ✅ Les couleurs sont cohérentes et lisibles
- [ ] ✅ Le code est organisé en fonctions réutilisables
- [ ] ✅ Ctrl+C est géré proprement

---

> [!success] 🎉 Vous maîtrisez maintenant les bases des menus interactifs ! Vous êtes capable de créer des interfaces structurées, élégantes et fonctionnelles pour vos scripts PowerShell. Ces compétences constituent la fondation pour créer des outils d'administration professionnels et conviviaux.