

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

## 🎯 Introduction

La navigation au clavier dans les menus PowerShell permet de créer des interfaces utilisateur professionnelles et intuitives. Au lieu de demander à l'utilisateur de taper un numéro, vous lui offrez la possibilité de naviguer avec les flèches directionnelles, comme dans n'importe quelle application moderne.

> [!info] Pourquoi utiliser la navigation au clavier ?
> 
> - **Meilleure expérience utilisateur** : Plus intuitive et rapide
> - **Moins d'erreurs** : Pas de risque de saisie incorrecte
> - **Interface professionnelle** : Apparence moderne et soignée
> - **Accessibilité** : Navigation familière pour tous les utilisateurs

---

## ⌨️ Navigation au clavier

### Comprendre $Host.UI.RawUI.ReadKey()

La méthode `ReadKey()` est le cœur de la navigation au clavier. Elle permet de capturer les touches pressées en temps réel, sans attendre la validation par Entrée.

> [!info] Qu'est-ce que RawUI ? `RawUI` (Raw User Interface) donne accès aux fonctionnalités de bas niveau de la console PowerShell, permettant de contrôler finement l'affichage et la saisie.

**Syntaxe de base :**

```powershell
# Capturer une touche pressée
$touche = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
```

**Paramètres de ReadKey() :**

|Paramètre|Description|
|---|---|
|`NoEcho`|N'affiche pas la touche pressée à l'écran|
|`IncludeKeyDown`|Capture l'appui sur la touche (pas le relâchement)|
|`AllowCtrlC`|Permet Ctrl+C pour interrompre|
|`IncludeKeyUp`|Capture le relâchement de la touche|

**Structure de l'objet retourné :**

```powershell
$touche = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Propriétés importantes :
$touche.VirtualKeyCode    # Code numérique de la touche
$touche.Character         # Caractère correspondant (si applicable)
$touche.ControlKeyState   # État des touches de modification (Ctrl, Alt, Shift)
```

> [!example] Exemple pratique
> 
> ```powershell
> Write-Host "Appuyez sur une touche..."
> $touche = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
> 
> Write-Host "Code virtuel : $($touche.VirtualKeyCode)"
> Write-Host "Caractère : $($touche.Character)"
> ```

---

### Détection des touches fléchées

Les touches fléchées sont identifiées par leurs codes virtuels (VirtualKeyCode). Voici les codes essentiels à connaître :

**Codes des touches directionnelles :**

```powershell
# Codes VirtualKeyCode des touches fléchées
$KEY_UP    = 38    # Flèche haut
$KEY_DOWN  = 40    # Flèche bas
$KEY_LEFT  = 37    # Flèche gauche
$KEY_RIGHT = 39    # Flèche droite
$KEY_ENTER = 13    # Entrée
$KEY_ESC   = 27    # Échap
```

**Fonction de détection des touches :**

```powershell
function Get-KeyPress {
    # Capture la touche sans l'afficher
    $touche = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Retourne un objet avec les informations utiles
    return @{
        Code      = $touche.VirtualKeyCode
        Character = $touche.Character
        IsUp      = $touche.VirtualKeyCode -eq 38
        IsDown    = $touche.VirtualKeyCode -eq 40
        IsEnter   = $touche.VirtualKeyCode -eq 13
        IsEscape  = $touche.VirtualKeyCode -eq 27
    }
}
```

> [!example] Exemple d'utilisation
> 
> ```powershell
> Write-Host "Utilisez les flèches ou Entrée pour valider..."
> 
> $touche = Get-KeyPress
> 
> if ($touche.IsUp) {
>     Write-Host "Vous avez appuyé sur Flèche Haut"
> }
> elseif ($touche.IsDown) {
>     Write-Host "Vous avez appuyé sur Flèche Bas"
> }
> elseif ($touche.IsEnter) {
>     Write-Host "Validation !"
> }
> ```

> [!warning] Attention aux terminaux non-standards Certains terminaux ou émulateurs peuvent avoir des codes de touches différents. Testez toujours votre script dans l'environnement cible.

---

### Surlignage de l'option sélectionnée

Le surlignage visuel est essentiel pour indiquer à l'utilisateur quelle option est actuellement sélectionnée. On utilise les couleurs de fond et de texte pour créer cet effet.

**Technique de base :**

```powershell
function Show-MenuOption {
    param(
        [string]$Text,
        [bool]$IsSelected
    )
    
    if ($IsSelected) {
        # Option sélectionnée : texte noir sur fond blanc
        Write-Host "  > $Text" -ForegroundColor Black -BackgroundColor White
    }
    else {
        # Option normale : texte par défaut
        Write-Host "    $Text"
    }
}
```

**Affichage d'un menu complet :**

```powershell
function Show-Menu {
    param(
        [string[]]$Options,
        [int]$SelectedIndex
    )
    
    # Efface l'écran ou repositionne le curseur
    Clear-Host
    
    Write-Host "`n=== MENU PRINCIPAL ===`n" -ForegroundColor Cyan
    
    # Affiche chaque option
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $isSelected = ($i -eq $SelectedIndex)
        Show-MenuOption -Text $Options[$i] -IsSelected $isSelected
    }
    
    Write-Host "`n[↑↓] Naviguer  [Entrée] Valider  [Échap] Quitter" -ForegroundColor DarkGray
}
```

> [!tip] Amélioration visuelle Ajoutez des emojis ou des caractères spéciaux pour un rendu encore plus professionnel :
> 
> ```powershell
> if ($IsSelected) {
>     Write-Host "  ► $Text" -ForegroundColor Black -BackgroundColor Cyan
> }
> else {
>     Write-Host "    $Text" -ForegroundColor Gray
> }
> ```

**Variantes de style :**

```powershell
# Style 1 : Inversion de couleurs
function Style-Inverse {
    param($Text, $IsSelected)
    if ($IsSelected) {
        Write-Host " > $Text " -ForegroundColor White -BackgroundColor Blue
    } else {
        Write-Host "   $Text"
    }
}

# Style 2 : Encadrement
function Style-Box {
    param($Text, $IsSelected)
    if ($IsSelected) {
        Write-Host " ┌─────────────────┐" -ForegroundColor Cyan
        Write-Host " │ $Text │" -ForegroundColor Cyan
        Write-Host " └─────────────────┘" -ForegroundColor Cyan
    } else {
        Write-Host "   $Text"
    }
}

# Style 3 : Indicateur coloré
function Style-Indicator {
    param($Text, $IsSelected)
    if ($IsSelected) {
        Write-Host " ● " -ForegroundColor Green -NoNewline
        Write-Host "$Text" -ForegroundColor White
    } else {
        Write-Host " ○ " -ForegroundColor DarkGray -NoNewline
        Write-Host "$Text" -ForegroundColor Gray
    }
}
```

---

### Boucle de navigation complète

La boucle de navigation gère l'interaction utilisateur de manière fluide et réactive. Elle combine tous les éléments précédents.

**Structure complète d'un menu navigable :**

```powershell
function Show-InteractiveMenu {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Options,
        
        [string]$Title = "Menu"
    )
    
    # Index de l'option actuellement sélectionnée
    $selectedIndex = 0
    $confirmed = $false
    
    # Boucle principale de navigation
    while (-not $confirmed) {
        # Affiche le menu avec la sélection actuelle
        Clear-Host
        Write-Host "`n╔════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║  $Title".PadRight(33) + "║" -ForegroundColor Cyan
        Write-Host "╚════════════════════════════════╝`n" -ForegroundColor Cyan
        
        # Affiche toutes les options
        for ($i = 0; $i -lt $Options.Count; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "  ► " -NoNewline -ForegroundColor Green
                Write-Host "$($Options[$i])" -ForegroundColor Black -BackgroundColor White
            }
            else {
                Write-Host "    $($Options[$i])" -ForegroundColor Gray
            }
        }
        
        # Instructions
        Write-Host "`n  [↑/↓] Naviguer  [Entrée] Valider  [Échap] Annuler`n" -ForegroundColor DarkGray
        
        # Capture la touche
        $touche = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        # Traite l'action en fonction de la touche
        switch ($touche.VirtualKeyCode) {
            38 {  # Flèche Haut
                $selectedIndex--
                if ($selectedIndex -lt 0) {
                    $selectedIndex = $Options.Count - 1  # Boucle vers le bas
                }
            }
            40 {  # Flèche Bas
                $selectedIndex++
                if ($selectedIndex -ge $Options.Count) {
                    $selectedIndex = 0  # Boucle vers le haut
                }
            }
            13 {  # Entrée
                $confirmed = $true
            }
            27 {  # Échap
                return $null  # Annulation
            }
        }
    }
    
    # Retourne l'option sélectionnée
    return @{
        Index = $selectedIndex
        Value = $Options[$selectedIndex]
    }
}
```

**Utilisation du menu :**

```powershell
# Définir les options
$options = @(
    "Démarrer le service",
    "Arrêter le service",
    "Redémarrer le service",
    "Afficher le statut",
    "Quitter"
)

# Afficher le menu et récupérer le choix
$choix = Show-InteractiveMenu -Options $options -Title "Gestion des services"

# Traiter le choix
if ($null -ne $choix) {
    Write-Host "`n✓ Vous avez sélectionné : $($choix.Value)" -ForegroundColor Green
    
    switch ($choix.Index) {
        0 { Start-Service -Name "MonService" }
        1 { Stop-Service -Name "MonService" }
        2 { Restart-Service -Name "MonService" }
        3 { Get-Service -Name "MonService" }
        4 { exit }
    }
}
else {
    Write-Host "`n✗ Opération annulée" -ForegroundColor Yellow
}
```

> [!tip] Optimisation du rafraîchissement Pour éviter le scintillement lors du rafraîchissement, utilisez `[Console]::SetCursorPosition(0,0)` au lieu de `Clear-Host` pour les menus à rafraîchissement rapide.

**Version optimisée sans scintillement :**

```powershell
function Show-InteractiveMenuOptimized {
    param(
        [string[]]$Options,
        [string]$Title = "Menu"
    )
    
    $selectedIndex = 0
    $confirmed = $false
    
    # Affichage initial
    [Console]::CursorVisible = $false  # Cache le curseur
    Clear-Host
    
    while (-not $confirmed) {
        # Repositionne le curseur en haut
        [Console]::SetCursorPosition(0, 0)
        
        # Affiche le titre
        Write-Host "`n╔════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║  $Title".PadRight(33) + "║" -ForegroundColor Cyan
        Write-Host "╚════════════════════════════════╝`n" -ForegroundColor Cyan
        
        # Affiche les options
        for ($i = 0; $i -lt $Options.Count; $i++) {
            $line = if ($i -eq $selectedIndex) {
                "  ► $($Options[$i])".PadRight(50)
            } else {
                "    $($Options[$i])".PadRight(50)
            }
            
            if ($i -eq $selectedIndex) {
                Write-Host $line -ForegroundColor Black -BackgroundColor White
            } else {
                Write-Host $line -ForegroundColor Gray
            }
        }
        
        Write-Host "`n  [↑/↓] Naviguer  [Entrée] Valider  [Échap] Annuler".PadRight(50) -ForegroundColor DarkGray
        
        # Gestion des touches
        $touche = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($touche.VirtualKeyCode) {
            38 { $selectedIndex = ($selectedIndex - 1 + $Options.Count) % $Options.Count }
            40 { $selectedIndex = ($selectedIndex + 1) % $Options.Count }
            13 { $confirmed = $true }
            27 { 
                [Console]::CursorVisible = $true
                return $null 
            }
        }
    }
    
    [Console]::CursorVisible = $true  # Réaffiche le curseur
    
    return @{
        Index = $selectedIndex
        Value = $Options[$selectedIndex]
    }
}
```

---

## ⚠️ Pièges courants et bonnes pratiques

> [!warning] Gestion du curseur N'oubliez jamais de rétablir la visibilité du curseur avec `[Console]::CursorVisible = $true`, même en cas d'erreur. Utilisez des blocs `try/finally` pour garantir cela.

```powershell
try {
    [Console]::CursorVisible = $false
    # Votre code de menu ici
}
finally {
    [Console]::CursorVisible = $true
}
```

> [!warning] Bouclage des indices Utilisez l'opérateur modulo `%` pour faire boucler proprement les indices :
> 
> ```powershell
> # Au lieu de :
> if ($index -lt 0) { $index = $max }
> 
> # Préférez :
> $index = ($index + $max) % $max  # Pour tous les cas
> ```

> [!warning] Compatibilité des terminaux Testez toujours vos menus dans PowerShell Console, Windows Terminal, et VS Code Terminal. Les comportements peuvent varier.

**Bonnes pratiques essentielles :**

|Pratique|Raison|
|---|---|
|**Toujours valider $Options.Count**|Évite les erreurs sur des tableaux vides|
|**Utiliser des constantes pour les codes de touches**|Rend le code plus lisible et maintenable|
|**Prévoir une option de sortie (Échap)**|Améliore l'expérience utilisateur|
|**Afficher les instructions**|L'utilisateur doit savoir comment naviguer|
|**Gérer Ctrl+C proprement**|Permet d'interrompre le script si nécessaire|
|**Vérifier $Host.UI.RawUI**|Certains environnements ne le supportent pas|

**Vérification de compatibilité :**

```powershell
function Test-InteractiveCapability {
    if ($null -eq $Host.UI.RawUI) {
        Write-Warning "Ce terminal ne supporte pas l'interface interactive"
        return $false
    }
    
    try {
        $test = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return $true
    }
    catch {
        Write-Warning "Impossible de lire les touches dans ce terminal"
        return $false
    }
}

# Utilisation
if (Test-InteractiveCapability) {
    # Afficher le menu interactif
    Show-InteractiveMenu -Options $options
}
else {
    # Fallback vers un menu numéroté simple
    Show-SimpleMenu -Options $options
}
```

---

## 💡 Astuces avancées

### Navigation multi-colonnes

Pour les menus avec beaucoup d'options, utilisez une disposition en colonnes :

```powershell
function Show-MultiColumnMenu {
    param(
        [string[]]$Options,
        [int]$Columns = 2
    )
    
    $selectedIndex = 0
    $confirmed = $false
    
    while (-not $confirmed) {
        Clear-Host
        Write-Host "`n=== MENU ===" -ForegroundColor Cyan
        
        $rows = [Math]::Ceiling($Options.Count / $Columns)
        
        for ($row = 0; $row -lt $rows; $row++) {
            for ($col = 0; $col -lt $Columns; $col++) {
                $index = $row + ($col * $rows)
                if ($index -lt $Options.Count) {
                    $text = $Options[$index].PadRight(30)
                    
                    if ($index -eq $selectedIndex) {
                        Write-Host " ► $text" -NoNewline -ForegroundColor Black -BackgroundColor White
                    } else {
                        Write-Host "   $text" -NoNewline -ForegroundColor Gray
                    }
                }
            }
            Write-Host ""  # Nouvelle ligne
        }
        
        $touche = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($touche.VirtualKeyCode) {
            38 { $selectedIndex = [Math]::Max(0, $selectedIndex - 1) }
            40 { $selectedIndex = [Math]::Min($Options.Count - 1, $selectedIndex + 1) }
            37 { $selectedIndex = [Math]::Max(0, $selectedIndex - $rows) }  # Gauche
            39 { $selectedIndex = [Math]::Min($Options.Count - 1, $selectedIndex + $rows) }  # Droite
            13 { $confirmed = $true }
            27 { return $null }
        }
    }
    
    return $Options[$selectedIndex]
}
```

### Recherche rapide dans le menu

Permettez à l'utilisateur de taper des lettres pour filtrer/rechercher :

```powershell
$searchBuffer = ""
$lastKeyTime = [DateTime]::Now

# Dans la boucle de navigation
if ($touche.Character -match '[a-zA-Z0-9]') {
    # Réinitialise le buffer si plus de 2 secondes se sont écoulées
    if (([DateTime]::Now - $lastKeyTime).TotalSeconds -gt 2) {
        $searchBuffer = ""
    }
    
    $searchBuffer += $touche.Character
    $lastKeyTime = [DateTime]::Now
    
    # Recherche la première option correspondante
    for ($i = 0; $i -lt $Options.Count; $i++) {
        if ($Options[$i] -like "$searchBuffer*") {
            $selectedIndex = $i
            break
        }
    }
}
```

### Animation de sélection

Ajoutez une petite animation pour confirmer la sélection :

```powershell
function Confirm-Selection {
    param([string]$Text)
    
    for ($i = 0; $i -lt 3; $i++) {
        Write-Host "`r  ► $Text  " -ForegroundColor Green -BackgroundColor Black -NoNewline
        Start-Sleep -Milliseconds 150
        Write-Host "`r  ► $Text  " -ForegroundColor Black -BackgroundColor Green -NoNewline
        Start-Sleep -Milliseconds 150
    }
    Write-Host ""
}
```

### Sous-menus imbriqués

Créez une structure de navigation hiérarchique :

```powershell
function Show-NestedMenu {
    param(
        [hashtable]$MenuStructure,
        [string]$CurrentPath = ""
    )
    
    $options = $MenuStructure.Keys | Sort-Object
    $choice = Show-InteractiveMenu -Options $options -Title $CurrentPath
    
    if ($null -eq $choice) { return }
    
    $selected = $MenuStructure[$choice.Value]
    
    if ($selected -is [hashtable]) {
        # C'est un sous-menu
        Show-NestedMenu -MenuStructure $selected -CurrentPath "$CurrentPath > $($choice.Value)"
    }
    else {
        # C'est une action finale
        & $selected
    }
}

# Exemple d'utilisation
$menu = @{
    "Gestion des fichiers" = @{
        "Créer un fichier" = { New-Item -ItemType File }
        "Supprimer un fichier" = { Remove-Item }
    }
    "Gestion des services" = @{
        "Démarrer" = { Start-Service }
        "Arrêter" = { Stop-Service }
    }
    "Quitter" = { exit }
}

Show-NestedMenu -MenuStructure $menu
```

### Performance et grande liste d'options

Pour les menus avec 100+ options, optimisez l'affichage :

```powershell
# N'affiche qu'une fenêtre visible d'options
$visibleCount = 10  # Nombre d'options visibles à l'écran
$topIndex = [Math]::Max(0, $selectedIndex - [Math]::Floor($visibleCount / 2))
$bottomIndex = [Math]::Min($Options.Count, $topIndex + $visibleCount)

# Affiche uniquement la portion visible
for ($i = $topIndex; $i -lt $bottomIndex; $i++) {
    # Affichage...
}

# Indicateur de position
Write-Host "`n  [$($selectedIndex + 1)/$($Options.Count)]" -ForegroundColor DarkGray
```

---