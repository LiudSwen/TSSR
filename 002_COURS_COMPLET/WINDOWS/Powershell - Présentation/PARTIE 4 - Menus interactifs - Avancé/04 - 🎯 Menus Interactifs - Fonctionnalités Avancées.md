

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

## 🎮 Raccourcis clavier personnalisés

### Pourquoi utiliser des raccourcis personnalisés ?

Les raccourcis clavier permettent aux utilisateurs expérimentés de naviguer rapidement dans vos scripts sans passer par les menus traditionnels. Cela améliore considérablement l'efficacité et l'expérience utilisateur pour les tâches répétitives.

> [!info] Cas d'usage
> 
> - Scripts d'administration système utilisés quotidiennement
> - Outils de déploiement avec actions fréquentes
> - Interfaces de gestion de serveurs
> - Tableaux de bord d'opérations

### Implémentation des raccourcis

```powershell
# Fonction de détection des raccourcis clavier
function Read-KeyWithShortcut {
    param(
        [hashtable]$Shortcuts  # Table des raccourcis : Key = Touche, Value = Action
    )
    
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Vérification des modificateurs (Ctrl, Alt, Shift)
    $hasCtrl = $key.ControlKeyState -band [System.ConsoleModifiers]::Control
    $hasAlt = $key.ControlKeyState -band [System.ConsoleModifiers]::Alt
    $hasShift = $key.ControlKeyState -band [System.ConsoleModifiers]::Shift
    
    # Construction de la clé de raccourci
    $shortcutKey = ""
    if ($hasCtrl) { $shortcutKey += "Ctrl+" }
    if ($hasAlt) { $shortcutKey += "Alt+" }
    if ($hasShift) { $shortcutKey += "Shift+" }
    $shortcutKey += $key.Character
    
    # Vérification si le raccourci existe
    if ($Shortcuts.ContainsKey($shortcutKey)) {
        return @{
            Type = "Shortcut"
            Action = $Shortcuts[$shortcutKey]
            Key = $key
        }
    }
    
    return @{
        Type = "Normal"
        Key = $key
    }
}
```

### Exemple complet avec menu et raccourcis

```powershell
function Show-MenuWithShortcuts {
    # Définition des raccourcis
    $shortcuts = @{
        "Ctrl+N" = "New"
        "Ctrl+O" = "Open"
        "Ctrl+S" = "Save"
        "Ctrl+Q" = "Quit"
        "F5" = "Refresh"
        "Alt+H" = "Help"
    }
    
    do {
        Clear-Host
        Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║      GESTIONNAIRE DE FICHIERS         ║" -ForegroundColor Cyan
        Write-Host "╠════════════════════════════════════════╣" -ForegroundColor Cyan
        Write-Host "║                                        ║" -ForegroundColor Cyan
        Write-Host "║  1. Nouveau fichier     [Ctrl+N]      ║" -ForegroundColor White
        Write-Host "║  2. Ouvrir fichier      [Ctrl+O]      ║" -ForegroundColor White
        Write-Host "║  3. Sauvegarder         [Ctrl+S]      ║" -ForegroundColor White
        Write-Host "║  4. Rafraîchir          [F5]          ║" -ForegroundColor White
        Write-Host "║  5. Aide                [Alt+H]       ║" -ForegroundColor White
        Write-Host "║  0. Quitter             [Ctrl+Q]      ║" -ForegroundColor Yellow
        Write-Host "║                                        ║" -ForegroundColor Cyan
        Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        
        # Lecture avec gestion des raccourcis
        $input = Read-KeyWithShortcut -Shortcuts $shortcuts
        
        # Traitement selon le type d'entrée
        if ($input.Type -eq "Shortcut") {
            $choice = $input.Action
            Write-Host "`nRaccourci détecté : $($input.Action)" -ForegroundColor Green
            Start-Sleep -Milliseconds 500
        } else {
            $choice = $input.Key.Character
        }
        
        # Exécution des actions
        switch ($choice) {
            {$_ -in '1', 'New'} { 
                Write-Host "`n✓ Création d'un nouveau fichier..." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }
            {$_ -in '2', 'Open'} { 
                Write-Host "`n✓ Ouverture d'un fichier..." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }
            {$_ -in '3', 'Save'} { 
                Write-Host "`n✓ Sauvegarde..." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }
            {$_ -in '4', 'Refresh'} { 
                Write-Host "`n↻ Rafraîchissement..." -ForegroundColor Cyan
                Start-Sleep -Seconds 1
            }
            {$_ -in '5', 'Help'} { 
                Show-ContextHelp
                Read-Host "`nAppuyez sur Entrée pour continuer"
            }
            {$_ -in '0', 'Quit'} { 
                Write-Host "`n✓ Au revoir !" -ForegroundColor Yellow
                return
            }
        }
    } while ($true)
}
```

> [!tip] Astuce : Affichage dynamique des raccourcis Affichez toujours les raccourcis à côté des options de menu pour améliorer la découvrabilité. Utilisez une notation cohérente comme `[Ctrl+X]`.

> [!warning] Attention aux conflits Certains raccourcis peuvent être interceptés par le terminal ou l'OS :
> 
> - `Ctrl+C` : interruption du script (à éviter)
> - `Ctrl+V` : coller (peut causer des problèmes)
> - `Ctrl+Z` : suspension (sous Linux)

### Gestion avancée des combinaisons de touches

```powershell
function Get-KeyCombination {
    param(
        [switch]$AllowMultipleModifiers  # Autorise Ctrl+Alt+Touche, etc.
    )
    
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Détection des modificateurs
    $modifiers = @()
    
    if ($key.ControlKeyState -band [System.ConsoleModifiers]::Control) {
        $modifiers += "Ctrl"
    }
    if ($key.ControlKeyState -band [System.ConsoleModifiers]::Alt) {
        $modifiers += "Alt"
    }
    if ($key.ControlKeyState -band [System.ConsoleModifiers]::Shift) {
        $modifiers += "Shift"
    }
    
    # Construction du résultat
    $result = @{
        Character = $key.Character
        VirtualKeyCode = $key.VirtualKeyCode
        Modifiers = $modifiers
        CombinationString = ""
    }
    
    # Création de la chaîne de combinaison
    if ($modifiers.Count -gt 0) {
        $result.CombinationString = ($modifiers -join "+") + "+" + $key.Character
    } else {
        $result.CombinationString = $key.Character
    }
    
    return $result
}

# Exemple d'utilisation
Write-Host "Appuyez sur une combinaison de touches..."
$combo = Get-KeyCombination
Write-Host "Vous avez appuyé sur : $($combo.CombinationString)" -ForegroundColor Cyan
```

---

## ❓ Help contextuelle (F1)

### Pourquoi implémenter une aide contextuelle ?

L'aide contextuelle permet aux utilisateurs de comprendre instantanément les options disponibles sans quitter le menu ou consulter une documentation externe. C'est essentiel pour les scripts complexes ou destinés à plusieurs utilisateurs.

> [!info] Avantages
> 
> - Réduit la courbe d'apprentissage
> - Diminue les erreurs d'utilisation
> - Améliore l'autonomie des utilisateurs
> - Professionnalise votre script

### Structure d'un système d'aide contextuelle

```powershell
# Base de données d'aide contextuelle
$HelpDatabase = @{
    "MainMenu" = @{
        Title = "Menu Principal"
        Description = "Gestionnaire de fichiers et configurations"
        Options = @{
            "1" = "Crée un nouveau fichier de configuration vierge"
            "2" = "Ouvre un fichier existant pour modification"
            "3" = "Sauvegarde les modifications en cours"
            "4" = "Actualise la liste des fichiers disponibles"
        }
        Examples = @(
            "Pour créer un nouveau fichier, appuyez sur 1 ou Ctrl+N",
            "Utilisez F5 pour rafraîchir la liste à tout moment"
        )
    }
    "ConfigMenu" = @{
        Title = "Menu de Configuration"
        Description = "Paramètres avancés du système"
        Options = @{
            "1" = "Configure les paramètres réseau (IP, DNS, Gateway)"
            "2" = "Définit les règles de pare-feu"
            "3" = "Gère les certificats SSL/TLS"
        }
        Warnings = @(
            "⚠ Les modifications réseau peuvent couper la connexion",
            "⚠ Sauvegardez avant de modifier les certificats"
        )
    }
}

# Fonction d'affichage de l'aide
function Show-ContextHelp {
    param(
        [string]$MenuContext = "MainMenu"  # Contexte actuel du menu
    )
    
    $help = $HelpDatabase[$MenuContext]
    
    if (-not $help) {
        Write-Host "`n❌ Aucune aide disponible pour ce contexte." -ForegroundColor Red
        return
    }
    
    Clear-Host
    
    # En-tête
    Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              📖 AIDE CONTEXTUELLE                  ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Titre et description
    Write-Host "📌 $($help.Title)" -ForegroundColor Yellow
    Write-Host $help.Description -ForegroundColor White
    Write-Host ""
    
    # Options disponibles
    if ($help.Options) {
        Write-Host "🔹 Options disponibles :" -ForegroundColor Cyan
        Write-Host "─────────────────────────" -ForegroundColor DarkGray
        foreach ($option in $help.Options.GetEnumerator() | Sort-Object Name) {
            Write-Host "  $($option.Key) → " -NoNewline -ForegroundColor Yellow
            Write-Host $option.Value -ForegroundColor White
        }
        Write-Host ""
    }
    
    # Exemples d'utilisation
    if ($help.Examples) {
        Write-Host "💡 Exemples :" -ForegroundColor Green
        Write-Host "─────────────" -ForegroundColor DarkGray
        foreach ($example in $help.Examples) {
            Write-Host "  • $example" -ForegroundColor Gray
        }
        Write-Host ""
    }
    
    # Avertissements
    if ($help.Warnings) {
        Write-Host "⚠️  Avertissements :" -ForegroundColor Red
        Write-Host "──────────────────" -ForegroundColor DarkGray
        foreach ($warning in $help.Warnings) {
            Write-Host "  $warning" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    Write-Host "─────────────────────────────────────────────────────" -ForegroundColor DarkGray
}
```

### Intégration dans un menu interactif

```powershell
function Show-MenuWithHelp {
    param(
        [string]$MenuContext = "MainMenu"
    )
    
    do {
        Clear-Host
        Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║         MENU PRINCIPAL                 ║" -ForegroundColor Cyan
        Write-Host "╠════════════════════════════════════════╣" -ForegroundColor Cyan
        Write-Host "║                                        ║" -ForegroundColor Cyan
        Write-Host "║  1. Nouveau fichier                   ║" -ForegroundColor White
        Write-Host "║  2. Ouvrir fichier                    ║" -ForegroundColor White
        Write-Host "║  3. Sauvegarder                       ║" -ForegroundColor White
        Write-Host "║  4. Rafraîchir                        ║" -ForegroundColor White
        Write-Host "║  0. Quitter                           ║" -ForegroundColor Yellow
        Write-Host "║                                        ║" -ForegroundColor Cyan
        Write-Host "║  [F1] Aide                            ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        
        # Détection de la touche avec support F1
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        # Vérification si F1 est pressée (VirtualKeyCode 112)
        if ($key.VirtualKeyCode -eq 112) {
            Show-ContextHelp -MenuContext $MenuContext
            Read-Host "`nAppuyez sur Entrée pour revenir au menu"
            continue
        }
        
        $choice = $key.Character
        
        switch ($choice) {
            '1' { Write-Host "`n✓ Action 1..." -ForegroundColor Green; Start-Sleep -Seconds 1 }
            '2' { Write-Host "`n✓ Action 2..." -ForegroundColor Green; Start-Sleep -Seconds 1 }
            '3' { Write-Host "`n✓ Action 3..." -ForegroundColor Green; Start-Sleep -Seconds 1 }
            '4' { Write-Host "`n↻ Rafraîchissement..." -ForegroundColor Cyan; Start-Sleep -Seconds 1 }
            '0' { Write-Host "`n✓ Au revoir !" -ForegroundColor Yellow; return }
        }
    } while ($true)
}
```

> [!tip] Astuce : Aide multi-niveaux Pour des menus complexes, créez une hiérarchie d'aide avec navigation entre sections :
> 
> ```powershell
> $help.RelatedTopics = @("ConfigMenu", "AdvancedMenu")
> ```

### Aide dynamique basée sur le contexte

```powershell
function Get-DynamicHelp {
    param(
        [string]$CurrentSelection,  # Option actuellement sélectionnée
        [hashtable]$SystemState     # État actuel du système
    )
    
    $helpText = switch ($CurrentSelection) {
        '1' {
            if ($SystemState.HasUnsavedChanges) {
                "⚠ Attention : Vous avez des modifications non sauvegardées qui seront perdues."
            } else {
                "Créer un nouveau fichier de configuration."
            }
        }
        '2' {
            $fileCount = $SystemState.AvailableFiles.Count
            "Ouvrir l'un des $fileCount fichiers disponibles."
        }
        '3' {
            if ($SystemState.CurrentFile) {
                "Sauvegarder les modifications de : $($SystemState.CurrentFile)"
            } else {
                "⚠ Aucun fichier ouvert actuellement."
            }
        }
    }
    
    return $helpText
}

# Exemple d'utilisation dans un menu
$systemState = @{
    HasUnsavedChanges = $true
    CurrentFile = "config.xml"
    AvailableFiles = @("config1.xml", "config2.xml")
}

Write-Host "`n💡 " -NoNewline -ForegroundColor Cyan
Write-Host (Get-DynamicHelp -CurrentSelection '3' -SystemState $systemState)
```

> [!warning] Piège courant : Surcharge d'informations Ne surchargez pas l'aide avec trop de détails. L'aide contextuelle doit être concise. Pour les informations détaillées, créez une documentation séparée accessible via une option dédiée.

---

## ✨ Auto-complétion personnalisée

### Qu'est-ce que l'auto-complétion ?

L'auto-complétion permet aux utilisateurs de saisir rapidement des valeurs en leur proposant des suggestions basées sur le contexte, l'historique ou des données prédéfinies. C'est particulièrement utile pour les noms de fichiers, chemins, commandes ou valeurs fréquentes.

> [!info] Cas d'usage
> 
> - Saisie de chemins de fichiers longs
> - Sélection de serveurs dans une liste
> - Choix de paramètres de configuration
> - Entrée de commandes fréquentes

### Implémentation basique de l'auto-complétion

```powershell
function Read-InputWithCompletion {
    param(
        [string[]]$CompletionList,     # Liste des suggestions
        [string]$Prompt = "Entrez une valeur",
        [int]$MinCharsForCompletion = 1 # Nombre minimum de caractères avant suggestions
    )
    
    Write-Host "$Prompt : " -NoNewline -ForegroundColor Cyan
    
    $input = ""
    $cursorPosition = 0
    $suggestions = @()
    $selectedSuggestion = -1
    
    while ($true) {
        # Lecture d'une touche
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($key.VirtualKeyCode) {
            13 {  # Entrée
                Write-Host ""
                if ($selectedSuggestion -ge 0 -and $suggestions.Count -gt 0) {
                    return $suggestions[$selectedSuggestion]
                }
                return $input
            }
            
            9 {  # Tab - Cycle dans les suggestions
                if ($suggestions.Count -gt 0) {
                    $selectedSuggestion = ($selectedSuggestion + 1) % $suggestions.Count
                    
                    # Effacement de la ligne
                    Write-Host ("`r" + (" " * 100) + "`r") -NoNewline
                    Write-Host "$Prompt : " -NoNewline -ForegroundColor Cyan
                    Write-Host $suggestions[$selectedSuggestion] -NoNewline -ForegroundColor Yellow
                    
                    $input = $suggestions[$selectedSuggestion]
                }
            }
            
            8 {  # Backspace
                if ($input.Length -gt 0) {
                    $input = $input.Substring(0, $input.Length - 1)
                    Write-Host "`b `b" -NoNewline
                    
                    # Mise à jour des suggestions
                    if ($input.Length -ge $MinCharsForCompletion) {
                        $suggestions = $CompletionList | Where-Object { $_ -like "$input*" }
                        $selectedSuggestion = -1
                    } else {
                        $suggestions = @()
                    }
                }
            }
            
            default {  # Caractère normal
                if ($key.Character -match '[a-zA-Z0-9_\-\.\\/]') {
                    $input += $key.Character
                    Write-Host $key.Character -NoNewline
                    
                    # Calcul des suggestions
                    if ($input.Length -ge $MinCharsForCompletion) {
                        $suggestions = $CompletionList | Where-Object { $_ -like "$input*" }
                        $selectedSuggestion = -1
                        
                        # Affichage du nombre de suggestions
                        if ($suggestions.Count -gt 0) {
                            $savedPos = $host.UI.RawUI.CursorPosition
                            Write-Host " ($($suggestions.Count) suggestion(s))" -NoNewline -ForegroundColor DarkGray
                            $host.UI.RawUI.CursorPosition = $savedPos
                        }
                    }
                }
            }
        }
    }
}

# Exemple d'utilisation
$serverList = @(
    "srv-web-01.domain.com",
    "srv-web-02.domain.com",
    "srv-db-01.domain.com",
    "srv-db-02.domain.com",
    "srv-app-01.domain.com"
)

$selectedServer = Read-InputWithCompletion -CompletionList $serverList -Prompt "Sélectionnez un serveur"
Write-Host "Serveur sélectionné : $selectedServer" -ForegroundColor Green
```

### Auto-complétion avec affichage de suggestions

```powershell
function Read-InputWithSuggestionBox {
    param(
        [string[]]$CompletionList,
        [string]$Prompt = "Entrez une valeur",
        [int]$MaxSuggestionsDisplayed = 5
    )
    
    $input = ""
    $suggestions = @()
    $selectedIndex = 0
    
    # Sauvegarde de la position initiale du curseur
    $startPosition = $host.UI.RawUI.CursorPosition
    
    function Show-Suggestions {
        param($CurrentInput, $CurrentSuggestions, $SelectedIndex)
        
        # Nettoyage de la zone de suggestions
        $currentPos = $host.UI.RawUI.CursorPosition
        for ($i = 1; $i -le $MaxSuggestionsDisplayed + 2; $i++) {
            $host.UI.RawUI.CursorPosition = @{X=0; Y=$currentPos.Y + $i}
            Write-Host (" " * $host.UI.RawUI.WindowSize.Width) -NoNewline
        }
        
        # Retour à la position
        $host.UI.RawUI.CursorPosition = $currentPos
        
        if ($CurrentSuggestions.Count -gt 0) {
            Write-Host "`n╔══ Suggestions ══" -ForegroundColor DarkCyan
            
            $displayCount = [Math]::Min($CurrentSuggestions.Count, $MaxSuggestionsDisplayed)
            for ($i = 0; $i -lt $displayCount; $i++) {
                if ($i -eq $SelectedIndex) {
                    Write-Host "║ ► " -NoNewline -ForegroundColor Yellow
                    Write-Host $CurrentSuggestions[$i] -ForegroundColor Yellow
                } else {
                    Write-Host "║   " -NoNewline -ForegroundColor DarkCyan
                    Write-Host $CurrentSuggestions[$i] -ForegroundColor Gray
                }
            }
            
            if ($CurrentSuggestions.Count -gt $MaxSuggestionsDisplayed) {
                Write-Host "║   ... ($($CurrentSuggestions.Count - $MaxSuggestionsDisplayed) de plus)" -ForegroundColor DarkGray
            }
            
            Write-Host "╚═════════════════" -ForegroundColor DarkCyan
        }
        
        # Retour à la ligne d'entrée
        $host.UI.RawUI.CursorPosition = $currentPos
    }
    
    Write-Host "$Prompt : " -NoNewline -ForegroundColor Cyan
    $inputStartPos = $host.UI.RawUI.CursorPosition
    
    while ($true) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($key.VirtualKeyCode) {
            13 {  # Entrée
                # Nettoyage de l'affichage
                for ($i = 0; $i -le $MaxSuggestionsDisplayed + 3; $i++) {
                    Write-Host ""
                }
                
                if ($suggestions.Count -gt 0 -and $selectedIndex -ge 0) {
                    return $suggestions[$selectedIndex]
                }
                return $input
            }
            
            38 {  # Flèche haut
                if ($suggestions.Count -gt 0) {
                    $selectedIndex = [Math]::Max(0, $selectedIndex - 1)
                    Show-Suggestions -CurrentInput $input -CurrentSuggestions $suggestions -SelectedIndex $selectedIndex
                }
            }
            
            40 {  # Flèche bas
                if ($suggestions.Count -gt 0) {
                    $selectedIndex = [Math]::Min($suggestions.Count - 1, $selectedIndex + 1)
                    Show-Suggestions -CurrentInput $input -CurrentSuggestions $suggestions -SelectedIndex $selectedIndex
                }
            }
            
            9 {  # Tab - Compléter avec la suggestion sélectionnée
                if ($suggestions.Count -gt 0) {
                    $input = $suggestions[$selectedIndex]
                    
                    # Réaffichage de l'entrée
                    $host.UI.RawUI.CursorPosition = $inputStartPos
                    Write-Host (" " * 50) -NoNewline
                    $host.UI.RawUI.CursorPosition = $inputStartPos
                    Write-Host $input -NoNewline -ForegroundColor Yellow
                    
                    # Mise à jour des suggestions
                    $suggestions = $CompletionList | Where-Object { $_ -like "$input*" }
                    $selectedIndex = 0
                    Show-Suggestions -CurrentInput $input -CurrentSuggestions $suggestions -SelectedIndex $selectedIndex
                }
            }
            
            8 {  # Backspace
                if ($input.Length -gt 0) {
                    $input = $input.Substring(0, $input.Length - 1)
                    Write-Host "`b `b" -NoNewline
                    
                    $suggestions = $CompletionList | Where-Object { $_ -like "$input*" }
                    $selectedIndex = 0
                    Show-Suggestions -CurrentInput $input -CurrentSuggestions $suggestions -SelectedIndex $selectedIndex
                }
            }
            
            default {
                if ($key.Character -match '[a-zA-Z0-9_\-\.\\/: ]') {
                    $input += $key.Character
                    Write-Host $key.Character -NoNewline
                    
                    $suggestions = $CompletionList | Where-Object { $_ -like "$input*" }
                    $selectedIndex = 0
                    Show-Suggestions -CurrentInput $input -CurrentSuggestions $suggestions -SelectedIndex $selectedIndex
                }
            }
        }
    }
}
```

> [!tip] Astuce : Auto-complétion intelligente Combinez plusieurs sources pour l'auto-complétion :
> 
> - Historique des valeurs précédemment saisies
> - Valeurs courantes du système (fichiers, processus)
> - Suggestions basées sur la fréquence d'utilisation

### Auto-complétion avec fuzzy matching

```powershell
function Get-FuzzyMatch {
    param(
        [string]$Pattern,
        [string[]]$List,
        [int]$MaxResults = 10
    )
    
    # Suppression des espaces et conversion en minuscules
    $pattern = $Pattern.ToLower() -replace '\s', ''
    $patternChars = $pattern.ToCharArray()
    
    $matches = @()
    
    foreach ($item in $List) {
        $itemLower = $item.ToLower()
        $score = 0
        $lastIndex = -1
        $matched = $true
        
        # Vérification si tous les caractères du pattern sont présents dans l'ordre
        foreach ($char in $patternChars) {
            $index = $itemLower.IndexOf($char, $lastIndex + 1)
            if ($index -eq -1) {
                $matched = $false
                break
            }
            
            # Calcul du score (favorise les matches consécutifs)
            if ($index -eq $lastIndex + 1) {
                $score += 10  # Bonus pour caractères consécutifs
            } else {
                $score += 1
            }
            
            # Bonus si début de mot
            if ($index -eq 0 -or $itemLower[$index - 1] -in @('-', '_', ' ', '.')) {
                $score += 5
            }
            
            $lastIndex = $index
        }
        
        if ($matched) {
            $matches += [PSCustomObject]@{
                Value = $item
                Score = $score
            }
        }
    }
    
    # Tri par score décroissant et retour des meilleurs résultats
    return ($matches | Sort-Object Score -Descending | Select-Object -First $MaxResults).Value
}

# Exemple d'utilisation avec fuzzy matching
function Read-InputWithFuzzyCompletion {
    param(
        [string[]]$CompletionList,
        [string]$Prompt = "Recherche"
    )
    
    Write-Host "$Prompt : " -NoNewline -ForegroundColor Cyan
    $input = ""
    
    while ($true) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        if ($key.VirtualKeyCode -eq 13) {  # Entrée
            Write-Host ""
            return $input
        } elseif ($key.VirtualKeyCode -eq 8) {  # Backspace
            if ($input.Length -gt 0) {
                $input = $input.Substring(0, $input.Length - 1)
                Write-Host "`b `b" -NoNewline
                
                # Affichage des suggestions fuzzy
                if ($input.Length -gt 0) {
                    $fuzzyMatches = Get-FuzzyMatch -Pattern $input -List $CompletionList -MaxResults 5
                    Write-Host "`n  → " -NoNewline -ForegroundColor DarkGray
                    Write-Host ($fuzzyMatches -join ", ") -ForegroundColor DarkYellow
                    Write-Host "`r$Prompt : $input" -NoNewline -ForegroundColor Cyan
                }
            }
        } else {
            if ($key.Character -match '[a-zA-Z0-9_\-]') {
                $input += $key.Character
                Write-Host $key.Character -NoNewline
                
                # Affichage des suggestions fuzzy
                $fuzzyMatches = Get-FuzzyMatch -Pattern $input -List $CompletionList -MaxResults 5
                if ($fuzzyMatches.Count -gt 0) {
                    $savedPos = $host.UI.RawUI.CursorPosition
                    Write-Host "`n  → " -NoNewline -ForegroundColor DarkGray
                    Write-Host ($fuzzyMatches -join ", ") -ForegroundColor DarkYellow
                    $host.UI.RawUI.CursorPosition = $savedPos
                }
            }
        }
    }
}

# Exemple d'utilisation
$commands = @(
    "Get-Process",
    "Get-Service",
    "Get-Content",
    "Set-Content",
    "Start-Service",
    "Stop-Service",
    "Restart-Service"
)

$result = Read-InputWithFuzzyCompletion -CompletionList $commands -Prompt "Commande"
```

> [!warning] Performance avec grandes listes Le fuzzy matching peut être lent avec de grandes listes (1000+ éléments). Dans ce cas :
> 
> - Indexez les données au préalable
> - Limitez la recherche aux premiers caractères
> - Utilisez un cache pour les recherches répétées

---

## 🔍 Recherche dans les menus

### Pourquoi implémenter une recherche ?

Pour les menus comportant de nombreuses options (10+), une fonctionnalité de recherche permet aux utilisateurs de trouver rapidement ce qu'ils cherchent sans parcourir toute la liste. C'est particulièrement utile pour les menus de sélection de serveurs, fichiers, ou configurations.

> [!info] Quand l'utiliser ?
> 
> - Menus avec plus de 10 options
> - Listes dynamiques (serveurs, fichiers)
> - Configurations complexes
> - Catalogues de commandes ou actions

### Implémentation d'une barre de recherche

```powershell
function Show-SearchableMenu {
    param(
        [hashtable[]]$MenuItems,  # Format : @{Key="1"; Label="Option"; Action={...}}
        [string]$Title = "Menu",
        [string]$SearchPrompt = "Rechercher"
    )
    
    $searchTerm = ""
    $filteredItems = $MenuItems
    $selectedIndex = 0
    
    function Display-Menu {
        param($Items, $Search, $SelectedIdx)
        
        Clear-Host
        
        # En-tête
        Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║  $($Title.PadRight(48)) ║" -ForegroundColor Cyan
        Write-Host "╠════════════════════════════════════════════════════╣" -ForegroundColor Cyan
        Write-Host "║                                                    ║" -ForegroundColor Cyan
        
        # Barre de recherche
        Write-Host "║  🔍 " -NoNewline -ForegroundColor Cyan
        Write-Host "$SearchPrompt : " -NoNewline -ForegroundColor White
        Write-Host $Search -ForegroundColor Yellow
        Write-Host "║                                                    ║" -ForegroundColor Cyan
        Write-Host "╠════════════════════════════════════════════════════╣" -ForegroundColor Cyan
        
        # Affichage des résultats
        if ($Items.Count -eq 0) {
            Write-Host "║                                                    ║" -ForegroundColor Cyan
            Write-Host "║  ❌ Aucun résultat trouvé                         ║" -ForegroundColor Red
            Write-Host "║                                                    ║" -ForegroundColor Cyan
        } else {
            Write-Host "║  Résultats : $($Items.Count) élément(s)".PadRight(51) + "║" -ForegroundColor DarkGray
            Write-Host "║                                                    ║" -ForegroundColor Cyan
            
            # Affichage des options (max 10)
            $displayCount = [Math]::Min($Items.Count, 10)
            for ($i = 0; $i -lt $displayCount; $i++) {
                $item = $Items[$i]
                
                if ($i -eq $SelectedIdx) {
                    Write-Host "║  ► " -NoNewline -ForegroundColor Yellow
                    Write-Host "$($item.Key). $($item.Label)".PadRight(47) -NoNewline -ForegroundColor Yellow
                    Write-Host "║" -ForegroundColor Cyan
                } else {
                    Write-Host "║    " -NoNewline -ForegroundColor Cyan
                    Write-Host "$($item.Key). $($item.Label)".PadRight(47) -NoNewline -ForegroundColor White
                    Write-Host "║" -ForegroundColor Cyan
                }
            }
            
            if ($Items.Count -gt 10) {
                Write-Host "║    ... et $($Items.Count - 10) autre(s)".PadRight(51) + "║" -ForegroundColor DarkGray
            }
        }
        
        Write-Host "║                                                    ║" -ForegroundColor Cyan
        Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "💡 [↑↓] Naviguer | [Entrée] Sélectionner | [Échap] Quitter | [Backspace] Effacer" -ForegroundColor DarkGray
    }
    
    # Affichage initial
    Display-Menu -Items $filteredItems -Search $searchTerm -SelectedIdx $selectedIndex
    
    while ($true) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($key.VirtualKeyCode) {
            13 {  # Entrée - Sélection
                if ($filteredItems.Count -gt 0) {
                    $selectedItem = $filteredItems[$selectedIndex]
                    Clear-Host
                    Write-Host "✓ Sélection : $($selectedItem.Label)" -ForegroundColor Green
                    
                    # Exécution de l'action
                    if ($selectedItem.Action) {
                        & $selectedItem.Action
                    }
                    
                    Read-Host "`nAppuyez sur Entrée pour continuer"
                    Display-Menu -Items $filteredItems -Search $searchTerm -SelectedIdx $selectedIndex
                }
            }
            
            27 {  # Échap - Quitter
                return $null
            }
            
            38 {  # Flèche haut
                if ($filteredItems.Count -gt 0) {
                    $selectedIndex = [Math]::Max(0, $selectedIndex - 1)
                    Display-Menu -Items $filteredItems -Search $searchTerm -SelectedIdx $selectedIndex
                }
            }
            
            40 {  # Flèche bas
                if ($filteredItems.Count -gt 0) {
                    $selectedIndex = [Math]::Min($filteredItems.Count - 1, $selectedIndex + 1)
                    Display-Menu -Items $filteredItems -Search $searchTerm -SelectedIdx $selectedIndex
                }
            }
            
            8 {  # Backspace
                if ($searchTerm.Length -gt 0) {
                    $searchTerm = $searchTerm.Substring(0, $searchTerm.Length - 1)
                    
                    # Filtrage des items
                    if ($searchTerm -eq "") {
                        $filteredItems = $MenuItems
                    } else {
                        $filteredItems = $MenuItems | Where-Object {
                            $_.Label -like "*$searchTerm*" -or $_.Key -like "*$searchTerm*"
                        }
                    }
                    
                    $selectedIndex = 0
                    Display-Menu -Items $filteredItems -Search $searchTerm -SelectedIdx $selectedIndex
                }
            }
            
            default {  # Caractère de recherche
                if ($key.Character -match '[a-zA-Z0-9_\- ]') {
                    $searchTerm += $key.Character
                    
                    # Filtrage des items
                    $filteredItems = $MenuItems | Where-Object {
                        $_.Label -like "*$searchTerm*" -or $_.Key -like "*$searchTerm*"
                    }
                    
                    $selectedIndex = 0
                    Display-Menu -Items $filteredItems -Search $searchTerm -SelectedIdx $selectedIndex
                }
            }
        }
    }
}

# Exemple d'utilisation
$menuItems = @(
    @{Key="1"; Label="Créer un nouveau serveur web"; Action={Write-Host "Création serveur web..."}},
    @{Key="2"; Label="Configurer le serveur de base de données"; Action={Write-Host "Config BDD..."}},
    @{Key="3"; Label="Démarrer le service web"; Action={Write-Host "Démarrage web..."}},
    @{Key="4"; Label="Arrêter le service web"; Action={Write-Host "Arrêt web..."}},
    @{Key="5"; Label="Consulter les logs web"; Action={Write-Host "Affichage logs..."}},
    @{Key="6"; Label="Sauvegarder la configuration"; Action={Write-Host "Sauvegarde..."}},
    @{Key="7"; Label="Restaurer la configuration"; Action={Write-Host "Restauration..."}},
    @{Key="8"; Label="Créer une sauvegarde automatique"; Action={Write-Host "Config backup..."}},
    @{Key="9"; Label="Monitorer les performances"; Action={Write-Host "Monitoring..."}},
    @{Key="10"; Label="Générer un rapport"; Action={Write-Host "Génération rapport..."}}
)

Show-SearchableMenu -MenuItems $menuItems -Title "Gestionnaire de Serveurs"
```

### Recherche avec mise en évidence

```powershell
function Highlight-SearchTerm {
    param(
        [string]$Text,
        [string]$SearchTerm
    )
    
    if ([string]::IsNullOrEmpty($SearchTerm)) {
        return $Text
    }
    
    # Séparation du texte selon le terme recherché (insensible à la casse)
    $parts = $Text -split "(?i)($SearchTerm)"
    
    $result = ""
    foreach ($part in $parts) {
        if ($part -eq $SearchTerm -or $part -eq $SearchTerm.ToLower() -or $part -eq $SearchTerm.ToUpper()) {
            # Partie correspondant au terme recherché
            Write-Host $part -NoNewline -ForegroundColor Black -BackgroundColor Yellow
        } else {
            # Partie normale
            Write-Host $part -NoNewline -ForegroundColor White
        }
    }
}

# Exemple d'utilisation
Write-Host "Résultat : " -NoNewline
Highlight-SearchTerm -Text "Serveur de base de données" -SearchTerm "base"
Write-Host ""
```

### Recherche avancée avec filtres

```powershell
function Show-AdvancedSearchMenu {
    param(
        [hashtable[]]$MenuItems,  # Items avec propriétés : Key, Label, Category, Tags
        [string]$Title = "Recherche Avancée"
    )
    
    $searchTerm = ""
    $categoryFilter = $null
    $tagFilter = @()
    $filteredItems = $MenuItems
    
    # Extraction des catégories uniques
    $categories = $MenuItems | ForEach-Object { $_.Category } | Select-Object -Unique | Sort-Object
    
    function Apply-Filters {
        param($Items, $Search, $Category, $Tags)
        
        $result = $Items
        
        # Filtre par terme de recherche
        if (-not [string]::IsNullOrEmpty($Search)) {
            $result = $result | Where-Object {
                $_.Label -like "*$Search*" -or $_.Key -like "*$Search*"
            }
        }
        
        # Filtre par catégorie
        if ($Category) {
            $result = $result | Where-Object { $_.Category -eq $Category }
        }
        
        # Filtre par tags
        if ($Tags.Count -gt 0) {
            $result = $result | Where-Object {
                $itemTags = $_.Tags
                $matchAll = $true
                foreach ($tag in $Tags) {
                    if ($itemTags -notcontains $tag) {
                        $matchAll = $false
                        break
                    }
                }
                $matchAll
            }
        }
        
        return $result
    }
    
    function Display-SearchMenu {
        Clear-Host
        
        Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║  $($Title.PadRight(48)) ║" -ForegroundColor Cyan
        Write-Host "╠════════════════════════════════════════════════════╣" -ForegroundColor Cyan
        
        # Affichage des filtres actifs
        Write-Host "║  🔍 Recherche : " -NoNewline -ForegroundColor Cyan
        Write-Host $searchTerm.PadRight(33) -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan
        
        Write-Host "║  📁 Catégorie : " -NoNewline -ForegroundColor Cyan
        $catDisplay = if ($categoryFilter) { $categoryFilter } else { "Toutes" }
        Write-Host $catDisplay.PadRight(33) -NoNewline -ForegroundColor $(if ($categoryFilter) { "Yellow" } else { "Gray" })
        Write-Host "║" -ForegroundColor Cyan
        
        Write-Host "║  🏷️  Tags      : " -NoNewline -ForegroundColor Cyan
        $tagDisplay = if ($tagFilter.Count -gt 0) { $tagFilter -join ", " } else { "Aucun" }
        Write-Host $tagDisplay.PadRight(33) -NoNewline -ForegroundColor $(if ($tagFilter.Count -gt 0) { "Yellow" } else { "Gray" })
        Write-Host "║" -ForegroundColor Cyan
        
        Write-Host "╠════════════════════════════════════════════════════╣" -ForegroundColor Cyan
        Write-Host "║  Résultats : $($filteredItems.Count) élément(s)".PadRight(51) + "║" -ForegroundColor White
        Write-Host "╠════════════════════════════════════════════════════╣" -ForegroundColor Cyan
        
        # Affichage des résultats
        if ($filteredItems.Count -eq 0) {
            Write-Host "║  ❌ Aucun résultat                                 ║" -ForegroundColor Red
        } else {
            $displayCount = [Math]::Min($filteredItems.Count, 8)
            for ($i = 0; $i -lt $displayCount; $i++) {
                $item = $filteredItems[$i]
                $line = "$($item.Key). $($item.Label)"
                Write-Host "║  $($line.PadRight(49))║" -ForegroundColor White
                
                # Affichage catégorie et tags
                $meta = "[$($item.Category)]"
                if ($item.Tags) {
                    $meta += " " + ($item.Tags -join ", ")
                }
                Write-Host "║     $($meta.PadRight(46))║" -ForegroundColor DarkGray
            }
            
            if ($filteredItems.Count -gt 8) {
                Write-Host "║     ... et $($filteredItems.Count - 8) autre(s)".PadRight(51) + "║" -ForegroundColor DarkGray
            }
        }
        
        Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host "`n💡 [F2] Catégorie | [F3] Tags | [Entrée] Sélectionner | [Échap] Quitter" -ForegroundColor DarkGray
    }
    
    Display-SearchMenu
    
    while ($true) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($key.VirtualKeyCode) {
            113 {  # F2 - Sélection de catégorie
                Write-Host "`n📁 Catégories disponibles :" -ForegroundColor Cyan
                Write-Host "0. Toutes" -ForegroundColor Gray
                for ($i = 0; $i -lt $categories.Count; $i++) {
                    Write-Host "$($i + 1). $($categories[$i])" -ForegroundColor White
                }
                
                $catChoice = Read-Host "`nChoisissez une catégorie"
                if ($catChoice -eq "0") {
                    $categoryFilter = $null
                } elseif ($catChoice -match '^\d+ -and [int]$catChoice -le $categories.Count) {
                    $categoryFilter = $categories[[int]$catChoice - 1]
                }
                
                $filteredItems = Apply-Filters -Items $MenuItems -Search $searchTerm -Category $categoryFilter -Tags $tagFilter
                Display-SearchMenu
            }
            
            27 {  # Échap
                return $null
            }
            
            8 {  # Backspace
                if ($searchTerm.Length -gt 0) {
                    $searchTerm = $searchTerm.Substring(0, $searchTerm.Length - 1)
                    $filteredItems = Apply-Filters -Items $MenuItems -Search $searchTerm -Category $categoryFilter -Tags $tagFilter
                    Display-SearchMenu
                }
            }
            
            default {
                if ($key.Character -match '[a-zA-Z0-9_\- ]') {
                    $searchTerm += $key.Character
                    $filteredItems = Apply-Filters -Items $MenuItems -Search $searchTerm -Category $categoryFilter -Tags $tagFilter
                    Display-SearchMenu
                }
            }
        }
    }
}
```

> [!tip] Astuce : Sauvegarde des recherches Pour les utilisateurs avancés, permettez la sauvegarde des recherches fréquentes :
> 
> ```powershell
> $savedSearches = @{
>     "web-servers" = @{Search="web"; Category="Serveurs"}
>     "db-config" = @{Search="base"; Category="Configuration"}
> }
> ```

> [!warning] Piège : Surcharge cognitive Ne multipliez pas les options de filtrage. 2-3 critères maximum (recherche + catégorie ou tags) suffisent pour la plupart des cas. Trop d'options rendent l'interface confuse.

### Recherche avec historique

```powershell
$script:SearchHistory = @()
$script:MaxHistorySize = 10

function Add-ToSearchHistory {
    param([string]$SearchTerm)
    
    if ([string]::IsNullOrEmpty($SearchTerm)) { return }
    
    # Suppression des doublons
    $script:SearchHistory = $script:SearchHistory | Where-Object { $_ -ne $SearchTerm }
    
    # Ajout en début de liste
    $script:SearchHistory = @($SearchTerm) + $script:SearchHistory
    
    # Limitation de la taille
    if ($script:SearchHistory.Count -gt $script:MaxHistorySize) {
        $script:SearchHistory = $script:SearchHistory[0..($script:MaxHistorySize - 1)]
    }
}

function Get-SearchHistory {
    return $script:SearchHistory
}

function Show-SearchHistory {
    if ($script:SearchHistory.Count -eq 0) {
        Write-Host "`n📜 Historique vide" -ForegroundColor Gray
        return $null
    }
    
    Write-Host "`n📜 Historique de recherche :" -ForegroundColor Cyan
    for ($i = 0; $i -lt $script:SearchHistory.Count; $i++) {
        Write-Host "  $($i + 1). $($script:SearchHistory[$i])" -ForegroundColor White
    }
    
    $choice = Read-Host "`nSélectionnez une recherche (0 pour annuler)"
    
    if ($choice -match '^\d+ -and [int]$choice -ge 1 -and [int]$choice -le $script:SearchHistory.Count) {
        return $script:SearchHistory[[int]$choice - 1]
    }
    
    return $null
}
```

---

## 🎓 Bonnes pratiques générales

### Combinaison des fonctionnalités

> [!example] Menu complet et professionnel Combinez toutes les fonctionnalités pour créer une expérience utilisateur optimale :
> 
> - **Raccourcis** pour les actions fréquentes
> - **F1** pour l'aide contextuelle
> - **Recherche** pour les longues listes
> - **Auto-complétion** pour la saisie rapide

### Cohérence de l'interface

|Élément|Standard recommandé|
|---|---|
|Aide|**F1**|
|Recherche|**Ctrl+F** ou **/**|
|Rafraîchir|**F5**|
|Quitter|**Échap** ou **Ctrl+Q**|
|Navigation|**↑↓** ou **hjkl**|
|Validation|**Entrée**|
|Annulation|**Échap**|

### Performance et réactivité

```powershell
# Évitez les Clear-Host répétés - utilisez le positionnement du curseur
function Update-MenuLine {
    param(
        [int]$Line,
        [string]$Text,
        [ConsoleColor]$Color = "White"
    )
    
    $currentPos = $host.UI.RawUI.CursorPosition
    $host.UI.RawUI.CursorPosition = @{X=0; Y=$Line}
    Write-Host (" " * $host.UI.RawUI.WindowSize.Width) -NoNewline
    $host.UI.RawUI.CursorPosition = @{X=0; Y=$Line}
    Write-Host $Text -ForegroundColor $Color
    $host.UI.RawUI.CursorPosition = $currentPos
}
```

> [!tip] Optimisation
> 
> - Évitez `Clear-Host` dans les boucles rapides
> - Utilisez le positionnement de curseur pour les mises à jour partielles
> - Mettez en cache les données statiques
> - Limitez les appels système coûteux

### Accessibilité

> [!info] Considérations d'accessibilité
> 
> - Fournissez toujours des alternatives clavier aux raccourcis souris
> - Utilisez des couleurs avec bon contraste
> - Évitez de vous fier uniquement à la couleur pour transmettre l'information
> - Proposez des options pour désactiver les animations
> - Documentez tous les raccourcis disponibles

---

## 📊 Récapitulatif

Ce cours a couvert les fonctionnalités avancées pour créer des menus PowerShell interactifs professionnels :

✅ **Raccourcis clavier** : Navigation rapide avec Ctrl, Alt, touches de fonction ✅ **Aide contextuelle (F1)** : Documentation intégrée avec hiérarchie et exemples ✅ **Auto-complétion** : Suggestions intelligentes avec fuzzy matching ✅ **Recherche dans les menus** : Filtrage en temps réel avec mise en évidence

Ces techniques transforment vos scripts en applications professionnelles avec une expérience utilisateur comparable aux outils commerciaux.