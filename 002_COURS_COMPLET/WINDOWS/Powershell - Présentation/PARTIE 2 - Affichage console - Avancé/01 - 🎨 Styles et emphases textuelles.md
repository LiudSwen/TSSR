

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

Les caractères Unicode permettent de créer des interfaces console visuellement attractives et professionnelles. Contrairement aux caractères ASCII basiques, Unicode offre une palette étendue de symboles pour dessiner des cadres, afficher des icônes, et améliorer la lisibilité de vos scripts.

> [!info] Pourquoi utiliser Unicode ?
> 
> - **Professionnalisme** : Des menus et interfaces plus soignés
> - **Clarté visuelle** : Séparation claire des sections
> - **Expressivité** : Communication d'informations avec des icônes
> - **Compatibilité moderne** : Fonctionne sur tous les terminaux récents

---

## 📦 Table des caractères de bordure

### Bordures simples

Les bordures simples utilisent des traits fins, idéales pour des interfaces légères et discrètes.

```powershell
# Caractères de bordure simple (Box Drawing Light)
$BorderLight = @{
    TopLeft     = '┌'  # U+250C
    TopRight    = '┐'  # U+2510
    BottomLeft  = '└'  # U+2514
    BottomRight = '┘'  # U+2518
    Horizontal  = '─'  # U+2500
    Vertical    = '│'  # U+2502
    CrossLeft   = '├'  # U+251C (T gauche)
    CrossRight  = '┤'  # U+2524 (T droit)
    CrossTop    = '┬'  # U+252C (T haut)
    CrossBottom = '┴'  # U+2534 (T bas)
    Cross       = '┼'  # U+253C (Croix)
}

# Exemple d'utilisation : Créer un cadre simple
function Show-SimpleBox {
    param([string]$Text, [int]$Width = 40)
    
    $b = $BorderLight
    $padding = $Width - $Text.Length - 2
    $leftPad = [Math]::Floor($padding / 2)
    $rightPad = $padding - $leftPad
    
    Write-Host "$($b.TopLeft)$($b.Horizontal * $Width)$($b.TopRight)"
    Write-Host "$($b.Vertical)$(' ' * $leftPad)$Text$(' ' * $rightPad)$($b.Vertical)"
    Write-Host "$($b.BottomLeft)$($b.Horizontal * $Width)$($b.BottomRight)"
}

Show-SimpleBox "Mon Titre"
```

**Résultat visuel :**

```
┌────────────────────────────────────────┐
│              Mon Titre                 │
└────────────────────────────────────────┘
```

### Bordures doubles

Les bordures doubles sont plus imposantes, parfaites pour mettre en évidence des sections importantes.

```powershell
# Caractères de bordure double (Box Drawing Double)
$BorderDouble = @{
    TopLeft     = '╔'  # U+2554
    TopRight    = '╗'  # U+2557
    BottomLeft  = '╚'  # U+255A
    BottomRight = '╝'  # U+255D
    Horizontal  = '═'  # U+2550
    Vertical    = '║'  # U+2551
    CrossLeft   = '╠'  # U+2560
    CrossRight  = '╣'  # U+2563
    CrossTop    = '╦'  # U+2566
    CrossBottom = '╩'  # U+2569
    Cross       = '╬'  # U+256C
}

# Exemple : Titre avec bordure double
function Show-DoubleTitle {
    param([string]$Title, [int]$Width = 50)
    
    $b = $BorderDouble
    $padding = $Width - $Title.Length - 2
    $leftPad = [Math]::Floor($padding / 2)
    $rightPad = $padding - $leftPad
    
    Write-Host "$($b.TopLeft)$($b.Horizontal * $Width)$($b.TopRight)" -ForegroundColor Cyan
    Write-Host "$($b.Vertical)$(' ' * $leftPad)$Title$(' ' * $rightPad)$($b.Vertical)" -ForegroundColor Cyan
    Write-Host "$($b.BottomLeft)$($b.Horizontal * $Width)$($b.BottomRight)" -ForegroundColor Cyan
}

Show-DoubleTitle "SECTION IMPORTANTE"
```

### Bordures arrondies

Les bordures arrondies offrent un look moderne et doux, idéales pour les applications contemporaines.

```powershell
# Caractères de bordure arrondie (Box Drawing Light Arc)
$BorderRounded = @{
    TopLeft     = '╭'  # U+256D
    TopRight    = '╮'  # U+256E
    BottomLeft  = '╰'  # U+2570
    BottomRight = '╯'  # U+256F
    Horizontal  = '─'  # U+2500
    Vertical    = '│'  # U+2502
    # Note: Les bordures arrondies n'ont pas de caractères d'intersection dédiés
    # On utilise les intersections standard (simple) pour maintenir la cohérence
    CrossLeft   = '├'  # U+251C
    CrossRight  = '┤'  # U+2524
    CrossTop    = '┬'  # U+252C
    CrossBottom = '┴'  # U+2534
    Cross       = '┼'  # U+253C
}

# Exemple : Menu avec bordures arrondies
function Show-RoundedMenu {
    param([string[]]$Items)
    
    $b = $BorderRounded
    $maxLength = ($Items | Measure-Object Length -Maximum).Maximum
    $width = $maxLength + 4
    
    Write-Host "$($b.TopLeft)$($b.Horizontal * $width)$($b.TopRight)"
    
    foreach ($item in $Items) {
        $spaces = $width - $item.Length - 2
        Write-Host "$($b.Vertical) $item$(' ' * $spaces) $($b.Vertical)"
    }
    
    Write-Host "$($b.BottomLeft)$($b.Horizontal * $width)$($b.BottomRight)"
}

Show-RoundedMenu @("Option 1", "Option 2", "Option 3")
```

### Autres styles de bordures

```powershell
# Bordures épaisses (Heavy)
$BorderHeavy = @{
    TopLeft     = '┏'  # U+250F
    TopRight    = '┓'  # U+2513
    BottomLeft  = '┗'  # U+2517
    BottomRight = '┛'  # U+251B
    Horizontal  = '━'  # U+2501
    Vertical    = '┃'  # U+2503
    CrossLeft   = '┣'  # U+2523
    CrossRight  = '┫'  # U+252B
    CrossTop    = '┳'  # U+2533
    CrossBottom = '┻'  # U+253B
    Cross       = '╋'  # U+254B
}

# Bordures mixtes (Double horizontal, simple vertical)
$BorderMixedDoubleH = @{
    TopLeft     = '╒'  # U+2552
    TopRight    = '╕'  # U+2555
    BottomLeft  = '╘'  # U+2558
    BottomRight = '╛'  # U+255B
    Horizontal  = '═'  # U+2550
    Vertical    = '│'  # U+2502
    CrossLeft   = '╞'  # U+255E
    CrossRight  = '╡'  # U+2561
    CrossTop    = '╤'  # U+2564
    CrossBottom = '╧'  # U+2567
    Cross       = '╪'  # U+256A
}

# Bordures mixtes (Simple horizontal, double vertical)
$BorderMixedDoubleV = @{
    TopLeft     = '╓'  # U+2553
    TopRight    = '╖'  # U+2556
    BottomLeft  = '╙'  # U+2559
    BottomRight = '╜'  # U+255C
    Horizontal  = '─'  # U+2500
    Vertical    = '║'  # U+2551
    CrossLeft   = '╟'  # U+255F
    CrossRight  = '╢'  # U+2562
    CrossTop    = '╥'  # U+2565
    CrossBottom = '╨'  # U+2568
    Cross       = '╫'  # U+256B
}

# Bordures à doubles lignes (Double line arc - moins utilisé)
$BorderDoubleArc = @{
    TopLeft     = '╔'  # U+2554
    TopRight    = '╗'  # U+2557
    BottomLeft  = '╚'  # U+255A
    BottomRight = '╝'  # U+255D
    Horizontal  = '═'  # U+2550
    Vertical    = '║'  # U+2551
    CrossLeft   = '╠'  # U+2560
    CrossRight  = '╣'  # U+2563
    CrossTop    = '╦'  # U+2566
    CrossBottom = '╩'  # U+2569
    Cross       = '╬'  # U+256C
}

# Bordures en pointillés (Dashed)
$BorderDashed = @{
    Horizontal2 = '╌'  # U+254C (tirets courts)
    Horizontal3 = '┄'  # U+2504 (tirets moyens)
    Horizontal4 = '┈'  # U+2508 (tirets longs)
    Vertical2   = '╎'  # U+254E
    Vertical3   = '┆'  # U+2506
    Vertical4   = '┊'  # U+250A
}

# Bordures en pointillés épais (Heavy Dashed)
$BorderHeavyDashed = @{
    Horizontal2 = '╍'  # U+254D
    Horizontal3 = '┅'  # U+2505
    Horizontal4 = '┉'  # U+2509
    Vertical2   = '╏'  # U+254F
    Vertical3   = '┇'  # U+2507
    Vertical4   = '┋'  # U+250B
}

# Bordures ASCII (fallback pour compatibilité maximale)
$BorderAscii = @{
    TopLeft     = '+'
    TopRight    = '+'
    BottomLeft  = '+'
    BottomRight = '+'
    Horizontal  = '-'
    Vertical    = '|'
    CrossLeft   = '+'
    CrossRight  = '+'
    CrossTop    = '+'
    CrossBottom = '+'
    Cross       = '+'
}
```

**Tableau comparatif des styles :**

|Style|Coins|Lignes|Usage recommandé|Visuel|
|---|---|---|---|---|
|**Simple**|┌┐└┘|─│|Interface générale, menus|Léger et discret|
|**Double**|╔╗╚╝|═║|Titres importants, alertes|Fort impact visuel|
|**Arrondi**|╭╮╰╯|─│|Design moderne, UI conviviale|Doux et élégant|
|**Épais**|┏┓┗┛|━┃|Avertissements critiques|Très visible|
|**Mixte H**|╒╕╘╛|═│|En-têtes de tableaux|Élégant pour données|
|**Mixte V**|╓╖╙╜|─║|Colonnes importantes|Vertical accentué|
|**Pointillé**|N/A|╌╎|Séparateurs légers|Subtil|
|**ASCII**|++++|-\||Compatibilité maximale|Universel|

> [!tip] Astuce de sélection
> 
> - **Simple** : Interfaces légères, menus secondaires
> - **Double** : Titres principaux, alertes importantes
> - **Arrondi** : Applications modernes, interfaces conviviales
> - **Épais** : Avertissements, sections critiques
> - **Mixte** : Tableaux de données, grilles

---

## ✨ Symboles utiles

### Flèches

Les flèches sont essentielles pour indiquer des directions, des progressions ou des relations.

```powershell
# Collection de flèches Unicode
$Arrows = @{
    # Flèches simples
    Up          = '↑'  # U+2191
    Down        = '↓'  # U+2193
    Left        = '←'  # U+2190
    Right       = '→'  # U+2192
    UpDown      = '↕'  # U+2195
    LeftRight   = '↔'  # U+2194
    
    # Flèches doubles
    DoubleUp    = '⇑'  # U+21D1
    DoubleDown  = '⇓'  # U+21D3
    DoubleLeft  = '⇐'  # U+21D0
    DoubleRight = '⇒'  # U+21D2
    
    # Flèches courbes
    CurveRight  = '↪'  # U+21AA
    CurveLeft   = '↩'  # U+21A9
    Return      = '↵'  # U+21B5
    
    # Flèches triangulaires
    TriangleUp    = '▲'  # U+25B2
    TriangleDown  = '▼'  # U+25BC
    TriangleLeft  = '◄'  # U+25C4
    TriangleRight = '►'  # U+25BA
}

# Exemple : Menu de navigation
function Show-NavigationMenu {
    $a = $Arrows
    Write-Host "`n$($a.TriangleRight) Menu Principal" -ForegroundColor Cyan
    Write-Host "  $($a.Right) Option 1"
    Write-Host "  $($a.Right) Option 2"
    Write-Host "  $($a.Right) Option 3"
    Write-Host "`n$($a.Return) Retour" -ForegroundColor Yellow
}

# Exemple : Indicateur de progression
function Show-ProgressIndicator {
    param([int]$Current, [int]$Total)
    
    $a = $Arrows
    $percent = [Math]::Round(($Current / $Total) * 100)
    
    if ($Current -lt $Total) {
        Write-Host "$($a.DoubleRight) Progression: $Current/$Total ($percent%)" -ForegroundColor Yellow
    } else {
        Write-Host "$($a.DoubleRight) Terminé: $Total/$Total (100%)" -ForegroundColor Green
    }
}
```

### Puces et marqueurs

Les puces permettent de créer des listes visuellement claires et organisées.

```powershell
# Collection de puces et marqueurs
$Bullets = @{
    # Puces de base
    Dot         = '•'  # U+2022 (puce standard)
    Circle      = '○'  # U+25CB (cercle vide)
    FilledCircle = '●'  # U+25CF (cercle plein)
    Square      = '□'  # U+25A1 (carré vide)
    FilledSquare = '■'  # U+25A0 (carré plein)
    Diamond     = '◇'  # U+25C7 (losange vide)
    FilledDiamond = '◆'  # U+25C6 (losange plein)
    
    # Marqueurs spéciaux
    Star        = '★'  # U+2605 (étoile pleine)
    EmptyStar   = '☆'  # U+2606 (étoile vide)
    Check       = '✓'  # U+2713 (coche)
    Cross       = '✗'  # U+2717 (croix)
    HeavyCheck  = '✔'  # U+2714 (coche épaisse)
    HeavyCross  = '✘'  # U+2718 (croix épaisse)
    
    # Numéros cerclés
    One         = '①'  # U+2460
    Two         = '②'  # U+2461
    Three       = '③'  # U+2462
    Four        = '④'  # U+2463
    Five        = '⑤'  # U+2464
}

# Exemple : Liste avec différents niveaux
function Show-HierarchicalList {
    $b = $Bullets
    Write-Host "`n$($b.FilledCircle) Tâche principale" -ForegroundColor Cyan
    Write-Host "  $($b.Circle) Sous-tâche 1" -ForegroundColor White
    Write-Host "    $($b.Dot) Détail 1"
    Write-Host "    $($b.Dot) Détail 2"
    Write-Host "  $($b.Circle) Sous-tâche 2" -ForegroundColor White
    Write-Host "    $($b.Dot) Détail 3"
}

# Exemple : Checklist avec statuts
function Show-Checklist {
    param([hashtable[]]$Tasks)
    
    $b = $Bullets
    Write-Host "`n=== Liste de tâches ===" -ForegroundColor Cyan
    
    foreach ($task in $Tasks) {
        $icon = if ($task.Done) { $b.HeavyCheck } else { $b.Square }
        $color = if ($task.Done) { "Green" } else { "Gray" }
        Write-Host "$icon $($task.Name)" -ForegroundColor $color
    }
}

# Utilisation
$myTasks = @(
    @{ Name = "Installer PowerShell 7"; Done = $true }
    @{ Name = "Configurer l'encodage"; Done = $true }
    @{ Name = "Créer le script"; Done = $false }
    @{ Name = "Tester le script"; Done = $false }
)

Show-Checklist -Tasks $myTasks
```

### Icônes et symboles

```powershell
# Collection d'icônes utiles
$Icons = @{
    # Symboles système
    Gear        = '⚙'  # U+2699 (paramètres)
    Warning     = '⚠'  # U+26A0 (avertissement)
    Info        = 'ℹ'  # U+2139 (information)
    Question    = '?'  # U+003F (question)
    Hourglass   = '⌛' # U+231B (sablier)
    Clock       = '🕐' # U+1F550 (horloge)
    
    # Documents et fichiers
    File        = '📄' # U+1F4C4
    Folder      = '📁' # U+1F4C1
    Document    = '📃' # U+1F4C3
    Page        = '📄' # U+1F4C4
    
    # Communication
    Mail        = '✉'  # U+2709
    Phone       = '☎'  # U+260E
    Message     = '💬' # U+1F4AC
    
    # Symboles mathématiques
    Plus        = '➕' # U+2795
    Minus       = '➖' # U+2796
    Multiply    = '✖'  # U+2716
    Divide      = '➗' # U+2797
    Equals      = '='  # U+003D
    
    # Symboles de progressions
    Spinner     = @('⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏')  # Braille spinner
}

# Exemple : Messages avec icônes
function Write-IconMessage {
    param(
        [string]$Message,
        [ValidateSet('Info','Warning','Error','Success','Question')]
        [string]$Type = 'Info'
    )
    
    $icon = switch ($Type) {
        'Info'     { 'ℹ' }
        'Warning'  { '⚠' }
        'Error'    { '✘' }
        'Success'  { '✔' }
        'Question' { '?' }
    }
    
    $color = switch ($Type) {
        'Info'     { 'Cyan' }
        'Warning'  { 'Yellow' }
        'Error'    { 'Red' }
        'Success'  { 'Green' }
        'Question' { 'Magenta' }
    }
    
    Write-Host "$icon $Message" -ForegroundColor $color
}

# Utilisation
Write-IconMessage "Opération réussie" -Type Success
Write-IconMessage "Attention : Fichier volumineux" -Type Warning
Write-IconMessage "Erreur de connexion" -Type Error
```

### Symboles d'état

```powershell
# Symboles pour indiquer des états
$Status = @{
    # États de validation
    Success     = '✔'  # U+2714
    Failed      = '✘'  # U+2718
    Pending     = '⏳' # U+23F3
    InProgress  = '⟳'  # U+27F3
    Skipped     = '⊘'  # U+2298
    
    # Niveaux de priorité
    Critical    = '🔴' # U+1F534 (rouge)
    High        = '🟠' # U+1F7E0 (orange)
    Medium      = '🟡' # U+1F7E1 (jaune)
    Low         = '🟢' # U+1F7E2 (vert)
    
    # États binaires
    Enabled     = '●'  # U+25CF
    Disabled    = '○'  # U+25CB
    On          = '■'  # U+25A0
    Off         = '□'  # U+25A1
}

# Exemple : Rapport d'état de services
function Show-ServiceStatus {
    param([hashtable[]]$Services)
    
    $s = $Status
    Write-Host "`n=== État des services ===" -ForegroundColor Cyan
    
    foreach ($service in $Services) {
        $icon = switch ($service.Status) {
            'Running' { $s.Success }
            'Stopped' { $s.Failed }
            'Starting' { $s.InProgress }
            default { $s.Pending }
        }
        
        $color = switch ($service.Status) {
            'Running' { 'Green' }
            'Stopped' { 'Red' }
            'Starting' { 'Yellow' }
            default { 'Gray' }
        }
        
        Write-Host "$icon $($service.Name): $($service.Status)" -ForegroundColor $color
    }
}

# Utilisation
$services = @(
    @{ Name = "WebServer"; Status = "Running" }
    @{ Name = "Database"; Status = "Running" }
    @{ Name = "EmailService"; Status = "Stopped" }
    @{ Name = "BackupService"; Status = "Starting" }
)

Show-ServiceStatus -Services $services
```

> [!example] Exemple complet : Dashboard système
> 
> ```powershell
> function Show-SystemDashboard {
>     $b = $BorderLight
>     $i = $Icons
>     $s = $Status
>     
>     # En-tête
>     Write-Host "`n$($b.TopLeft)$($b.Horizontal * 50)$($b.TopRight)" -ForegroundColor Cyan
>     Write-Host "$($b.Vertical) $($i.Gear) TABLEAU DE BORD SYSTÈME$((' ' * 24))$($b.Vertical)" -ForegroundColor Cyan
>     Write-Host "$($b.CrossLeft)$($b.Horizontal * 50)$($b.CrossRight)" -ForegroundColor Cyan
>     
>     # Statuts
>     Write-Host "$($b.Vertical) $($s.Success) CPU: 45%$((' ' * 34))$($b.Vertical)" -ForegroundColor Green
>     Write-Host "$($b.Vertical) $($s.Failed) Mémoire: 92%$((' ' * 28))$($b.Vertical)" -ForegroundColor Red
>     Write-Host "$($b.Vertical) $($s.Success) Disque: 60%$((' ' * 29))$($b.Vertical)" -ForegroundColor Green
>     
>     # Pied de page
>     Write-Host "$($b.BottomLeft)$($b.Horizontal * 50)$($b.BottomRight)" -ForegroundColor Cyan
> }
> ```

---

## ⚙️ Encodage et Configuration

### Configuration de l'encodage console

L'encodage est crucial pour l'affichage correct des caractères Unicode. Sans configuration appropriée, les caractères spéciaux apparaîtront comme des points d'interrogation ou des carrés.

```powershell
# Méthode 1 : Configuration basique (UTF-8)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Méthode 2 : Configuration avec InputEncoding également
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Méthode 3 : Forcer UTF-8 avec BOM (rarement nécessaire)
$utf8WithBom = New-Object System.Text.UTF8Encoding $true
[Console]::OutputEncoding = $utf8WithBom

# Méthode 4 : Configuration pour scripts Windows PowerShell 5.1
# À placer au début du script
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = 
    [System.Text.Encoding]::UTF8
```

> [!warning] Configuration persistante La configuration de l'encodage avec `[Console]::OutputEncoding` n'est valable que pour la session en cours. Pour une configuration permanente, ajoutez la commande à votre profil PowerShell.

```powershell
# Ajouter au profil PowerShell
if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force
}

Add-Content -Path $PROFILE -Value @'
# Configuration UTF-8 pour caractères Unicode
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
'@
```

### Détection de l'encodage actuel

```powershell
# Fonction pour afficher la configuration actuelle
function Get-ConsoleEncoding {
    Write-Host "=== Configuration d'encodage actuelle ===" -ForegroundColor Cyan
    Write-Host "Output Encoding: $([Console]::OutputEncoding.EncodingName)"
    Write-Host "Output CodePage: $([Console]::OutputEncoding.CodePage)"
    Write-Host "Input Encoding: $([Console]::InputEncoding.EncodingName)"
    Write-Host "Input CodePage: $([Console]::InputEncoding.CodePage)"
    Write-Host "`nScript OutputEncoding: $($OutputEncoding.EncodingName)" -ForegroundColor Yellow
}

# Test d'affichage Unicode
function Test-UnicodeDisplay {
    Write-Host "`n=== Test d'affichage Unicode ===" -ForegroundColor Cyan
    Write-Host "Bordures simples: ┌─┐│└┘"
    Write-Host "Bordures doubles: ╔═╗║╚╝"
    Write-Host "Bordures arrondies: ╭─╮│╰╯"
    Write-Host "Symboles: ✓ ✗ ★ ● ◆ ➜"
    Write-Host "Flèches: ← → ↑ ↓ ⇐ ⇒"
    Write-Host "Émojis: 📁 📄 ⚙ ⚠ ℹ"
    
    Write-Host "`nSi vous voyez des ? ou des □, l'encodage n'est pas correct." -ForegroundColor Yellow
}

# Exécution des tests
Get-ConsoleEncoding
Test-UnicodeDisplay
```

### UTF-8 BOM vs sans BOM

Le Byte Order Mark (BOM) est une séquence de bytes qui indique l'encodage du fichier.

```powershell
# Comparaison UTF-8 avec et sans BOM
$utfNoBom = [System.Text.UTF8Encoding]::new($false)  # Sans BOM (recommandé)
$utfWithBom = [System.Text.UTF8Encoding]::new($true) # Avec BOM

# Fonction pour sauvegarder avec encodage spécifique
function Save-ScriptWithEncoding {
    param(
        [string]$Content,
        [string]$Path,
        [bool]$UseBOM = $false
    )
    
    $encoding = if ($UseBOM) {
        [System.Text.UTF8Encoding]::new($true)
    } else {
        [System.Text.UTF8Encoding]::new($false)
    }
    
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
    
    Write-Host "Fichier sauvegardé avec UTF-8 $(if($UseBOM){'avec BOM'}else{'sans BOM'})" -ForegroundColor Green
}
```

|Aspect|UTF-8 sans BOM|UTF-8 avec BOM|
|---|---|---|
|**Taille**|Plus léger (pas de bytes supplémentaires)|+3 bytes au début du fichier|
|**Compatibilité**|Meilleure avec Linux/macOS|Meilleure avec anciens outils Windows|
|**PowerShell Core**|Recommandé|Accepté mais inutile|
|**Windows PowerShell 5.1**|Fonctionne|Peut aider à la détection|
|**Git**|Pas de conflit|Peut créer des différences artificielles|

> [!tip] Recommandation Utilisez **UTF-8 sans BOM** pour les nouveaux scripts PowerShell, car c'est le standard moderne et cela évite les problèmes avec les outils de versioning.

---

## 🖥️ Compatibilité avec différents terminaux

### Windows PowerShell vs PowerShell Core

```powershell
# Détection de la version de PowerShell
function Get-PowerShellVersion {
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        return "PowerShell Core/7+"
    } else {
        return "Windows PowerShell 5.1 ou inférieur"
    }
}

# Configuration adaptative selon la version
function Initialize-UnicodeSupport {
    $version = Get-PowerShellVersion
    Write-Host "Détecté: $version" -ForegroundColor Cyan
    
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        # PowerShell Core : UTF-8 par défaut, excellent support Unicode
        Write-Host "✓ Support Unicode natif activé" -ForegroundColor Green
    } else {
        # Windows PowerShell : Configuration manuelle nécessaire
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        [Console]::InputEncoding = [System.Text.Encoding]::UTF8
        $OutputEncoding = [System.Text.Encoding]::UTF8
        
        Write-Host "✓ Encodage UTF-8 configuré manuellement" -ForegroundColor Yellow
        Write-Host "  Note: Certains émojis peuvent ne pas s'afficher" -ForegroundColor Gray
    }
}
```

|Caractéristique|Windows PowerShell 5.1|PowerShell Core 7+|
|---|---|---|
|**Encodage par défaut**|Windows-1252 (Europe)|UTF-8|
|**Bordures Unicode**|✓ Après configuration|✓ Natif|
|**Émojis**|⚠ Limité|✓ Complet|
|**Polices requises**|Consolas, Courier New|Toutes polices modernes|
|**Configuration nécessaire**|Oui, manuelle|Non, automatique|

### Windows Terminal

Windows Terminal offre le meilleur support Unicode de tous les terminaux Windows.

```powershell
# Détection de Windows Terminal
function Test-WindowsTerminal {
    return $env:WT_SESSION -ne $null
}

# Configuration optimale pour Windows Terminal
function Optimize-ForWindowsTerminal {
    if (Test-WindowsTerminal) {
        Write-Host "✓ Windows Terminal détecté" -ForegroundColor Green
        
        # Configuration recommandée
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        
        Write-Host "Fonctionnalités disponibles:" -ForegroundColor Cyan
        Write-Host "  • Support complet Unicode (émojis, ligatures)"
        Write-Host "  • Rendu GPU accéléré"
        Write-Host "  • Transparence et effets acrylic"
        Write-Host "  • Onglets multiples"
        
        return $true
    } else {
        Write-Host "⚠ Windows Terminal non détecté" -ForegroundColor Yellow
        Write-Host "  Recommandation: Installer Windows Terminal pour un meilleur support Unicode"
        return $false
    }
}
```

> [!info] Avantages de Windows Terminal
> 
> - **Rendu moderne** : Utilise DirectWrite pour un affichage net
> - **Polices ligature** : Support des polices comme Cascadia Code
> - **Émojis couleur** : Affichage complet des émojis
> - **Performance** : Accélération GPU pour le rendu
> - **Personnalisation** : Thèmes, arrière-plans, transparence

### VS Code Terminal

```powershell
# Détection du terminal VS Code
function Test-VSCodeTerminal {
    return $env:TERM_PROGRAM -eq 'vscode'
}

# Configuration pour VS Code
function Optimize-ForVSCode {
    if (Test-VSCodeTerminal) {
        Write-Host "✓ Terminal VS Code détecté" -ForegroundColor Green
        
        # Configuration UTF-8
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        
        Write-Host "Fonctionnalités disponibles:" -ForegroundColor Cyan
        Write-Host "  • Support Unicode complet"
        Write-Host "  • Intégration avec les paramètres VS Code"
        Write-Host "  • Thème synchronisé avec l'éditeur"
        Write-Host "  • Support des polices personnalisées"
        
        # Vérifier la police configurée
        Write-Host "`nPolices recommandées pour VS Code:" -ForegroundColor Yellow
        Write-Host "  • Cascadia Code (avec ligatures)"
        Write-Host "  • Fira Code"
        Write-Host "  • JetBrains Mono"
        Write-Host "  • Consolas (par défaut Windows)"
        
        return $true
    } else {
        return $false
    }
}
```

**Configuration recommandée dans settings.json de VS Code :**

```json
{
  "terminal.integrated.fontFamily": "Cascadia Code, Consolas, monospace",
  "terminal.integrated.fontSize": 12,
  "terminal.integrated.fontWeight": "normal",
  "terminal.integrated.fontWeightBold": "bold",
  "terminal.integrated.gpuAcceleration": "on"
}
```

### ConHost classique

Le terminal classique Windows (conhost.exe) a des limitations importantes.

```powershell
# Détection du ConHost classique
function Test-ClassicConHost {
    # ConHost n'a pas de variables d'environnement spécifiques
    # On détecte par élimination
    $isWT = Test-WindowsTerminal
    $isVSCode = Test-VSCodeTerminal
    
    return -not ($isWT -or $isVSCode)
}

# Configuration pour ConHost classique
function Optimize-ForConHost {
    if (Test-ClassicConHost) {
        Write-Host "⚠ Console Windows classique détectée" -ForegroundColor Yellow
        
        # Configuration de base
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        [Console]::InputEncoding = [System.Text.Encoding]::UTF8
        
        Write-Host "`nLimitations connues:" -ForegroundColor Yellow
        Write-Host "  ✗ Pas d'émojis couleur"
        Write-Host "  ✗ Rendu lent avec beaucoup de caractères"
        Write-Host "  ✗ Polices limitées (Consolas, Courier New, Lucida Console)"
        Write-Host "  ⚠ Certains caractères Unicode peuvent ne pas s'afficher"
        
        Write-Host "`nRecommandation: Utilisez Windows Terminal pour une meilleure expérience" -ForegroundColor Cyan
        
        return $false
    }
    return $true
}
```

|Terminal|Support Unicode|Émojis|Performance|Recommandation|
|---|---|---|---|---|
|**Windows Terminal**|⭐⭐⭐⭐⭐|✓ Complet|Excellente|⭐ Recommandé|
|**VS Code Terminal**|⭐⭐⭐⭐|✓ Bon|Très bonne|✓ Excellent|
|**PowerShell ISE**|⭐⭐⭐|✗ Limité|Bonne|⚠ Déprécié|
|**ConHost classique**|⭐⭐|✗ Non|Moyenne|⚠ Éviter|
|**PowerShell Core**|⭐⭐⭐⭐⭐|✓ Complet|Excellente|⭐ Recommandé|

> [!example] Fonction de compatibilité universelle
> 
> ```powershell
> function Initialize-OptimalUnicodeSupport {
>     Write-Host "=== Configuration Unicode optimale ===" -ForegroundColor Cyan
>     
>     # Détection de l'environnement
>     $env = if (Test-WindowsTerminal) {
>         "Windows Terminal"
>     } elseif (Test-VSCodeTerminal) {
>         "VS Code"
>     } else {
>         "Console classique"
>     }
>     
>     Write-Host "Environnement: $env" -ForegroundColor Cyan
>     
>     # Configuration UTF-8
>     [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
>     [Console]::InputEncoding = [System.Text.Encoding]::UTF8
>     
>     # Test d'affichage
>     Write-Host "`nTest: ┌─┐ ║ ╔═╗ → ✓ ★" -ForegroundColor Green
>     
>     # Recommandations selon l'environnement
>     if ($env -eq "Console classique") {
>         Write-Host "`n⚠ Pour une meilleure expérience, installez Windows Terminal" -ForegroundColor Yellow
>     } else {
>         Write-Host "`n✓ Support Unicode optimal activé" -ForegroundColor Green
>     }
> }
> ```

---

## ⚠️ Pièges courants

### 1. Oubli de configuration de l'encodage

```powershell
# ❌ INCORRECT : Utiliser Unicode sans configurer l'encodage
function Show-BadBox {
    Write-Host "┌─────┐"
    Write-Host "│ Box │"
    Write-Host "└─────┘"
}
# Résultat: ?????? ou ??????

# ✓ CORRECT : Toujours configurer l'encodage d'abord
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Show-GoodBox {
    Write-Host "┌─────┐"
    Write-Host "│ Box │"
    Write-Host "└─────┘"
}
```

### 2. Mélange d'encodages dans les fichiers

```powershell
# ⚠ PROBLÈME : Fichier sauvegardé en ANSI mais contenant de l'Unicode
# Résultat: Caractères corrompus à la lecture

# ✓ SOLUTION : Toujours sauvegarder en UTF-8
$content = @"
function Show-Menu {
    Write-Host "┌────────┐"
    Write-Host "│  Menu  │"
    Write-Host "└────────┘"
}
"@

# Sauvegarde correcte en UTF-8 sans BOM
[System.IO.File]::WriteAllText(
    "C:\Scripts\Menu.ps1",
    $content,
    [System.Text.UTF8Encoding]::new($false)
)
```

### 3. Copier-coller depuis des sources non-UTF8

```powershell
# ⚠ PROBLÈME : Copier des caractères depuis Word ou des sites web
# peut introduire des caractères incompatibles

# ✓ SOLUTION : Définir les caractères directement avec leurs codes Unicode
$char = [char]0x2514  # └ (Unicode U+2514)
Write-Host $char

# Ou utiliser des hashtables de référence
$Borders = @{
    BottomLeft = [char]0x2514
    BottomRight = [char]0x2518
}
```

### 4. Problèmes avec les pipelines

```powershell
# ❌ INCORRECT : Les caractères Unicode peuvent être altérés dans les pipelines
function Get-Data {
    "┌─────┐"
    "│ Data│"
    "└─────┘"
}

Get-Data | Out-File "output.txt"  # Peut corrompre les caractères

# ✓ CORRECT : Spécifier l'encodage
Get-Data | Out-File "output.txt" -Encoding UTF8

# Encore mieux : Utiliser UTF8 sans BOM
Get-Data | Out-File "output.txt" -Encoding UTF8NoBOM  # PowerShell 6+
```

### 5. Largeur des caractères et alignement

```powershell
# ⚠ PROBLÈME : Certains caractères Unicode ont des largeurs différentes
function Show-MisalignedTable {
    Write-Host "Nom      │ Status"
    Write-Host "─────────┼─────────"
    Write-Host "Test     │ ✓"      # Le ✓ peut avoir une largeur double
    Write-Host "Service  │ ✗"
}

# ✓ SOLUTION : Utiliser des espaces supplémentaires ou PadRight
function Show-AlignedTable {
    $nameWidth = 10
    $statusWidth = 8
    
    Write-Host "$('Nom'.PadRight($nameWidth))│ Status"
    Write-Host "$('─' * $nameWidth)┼$('─' * $statusWidth)"
    Write-Host "$('Test'.PadRight($nameWidth))│ ✓  "
    Write-Host "$('Service'.PadRight($nameWidth))│ ✗  "
}
```

### 6. Compatibilité avec les redirections

```powershell
# ⚠ PROBLÈME : > et >> utilisent l'encodage par défaut du système
Write-Host "┌─────┐" > output.txt  # Peut utiliser ASCII/ANSI

# ✓ SOLUTION 1 : Utiliser Out-File avec encodage
Write-Host "┌─────┐" | Out-File output.txt -Encoding UTF8

# ✓ SOLUTION 2 : Utiliser Set-Content
"┌─────┐" | Set-Content output.txt -Encoding UTF8

# ✓ SOLUTION 3 : Configuration globale (PowerShell 5.1)
$PSDefaultParameterValues = @{
    'Out-File:Encoding' = 'UTF8'
    'Set-Content:Encoding' = 'UTF8'
}
```

---

## 💡 Bonnes pratiques

### 1. Initialisation systématique de l'encodage

```powershell
# Toujours en début de script
#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Pour PowerShell 5.1, configurer aussi $OutputEncoding
if ($PSVersionTable.PSVersion.Major -lt 6) {
    $OutputEncoding = [System.Text.Encoding]::UTF8
}
```

### 2. Utiliser des constantes pour les caractères

```powershell
# Créer un module de constantes réutilisable
$Script:BoxChars = @{
    # Bordures simples
    TL = '┌'; TR = '┐'; BL = '└'; BR = '┘'
    H = '─'; V = '│'
    
    # Bordures doubles
    DTL = '╔'; DTR = '╗'; DBL = '╚'; DBR = '╝'
    DH = '═'; DV = '║'
    
    # Intersections
    Cross = '┼'; CL = '├'; CR = '┤'; CT = '┬'; CB = '┴'
}

# Utilisation propre et maintenable
function New-SimpleBox {
    param([string]$Text, [int]$Width = 40)
    
    $b = $Script:BoxChars
    Write-Host "$($b.TL)$($b.H * $Width)$($b.TR)"
    Write-Host "$($b.V) $Text $($b.V)"
    Write-Host "$($b.BL)$($b.H * $Width)$($b.BR)"
}
```

### 3. Fonctions de fallback pour compatibilité

```powershell
# Fonction avec fallback ASCII si Unicode échoue
function Write-Separator {
    param(
        [int]$Length = 50,
        [switch]$UseAscii
    )
    
    if ($UseAscii -or $PSVersionTable.PSVersion.Major -lt 6) {
        Write-Host ('-' * $Length)
    } else {
        Write-Host ('─' * $Length)
    }
}

# Détection automatique du support Unicode
function Test-UnicodeSupport {
    try {
        $testChar = '┌'
        $originalEncoding = [Console]::OutputEncoding
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        
        # Teste si le caractère s'affiche correctement
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($testChar)
        [Console]::OutputEncoding = $originalEncoding
        
        return $bytes.Length -eq 3  # Les caractères box drawing sont sur 3 bytes en UTF-8
    } catch {
        return $false
    }
}

# Utilisation adaptative
$UseUnicode = Test-UnicodeSupport
Write-Separator -UseAscii:(-not $UseUnicode)
```

### 4. Gestion des largeurs de caractères

```powershell
# Fonction pour calculer la largeur réelle d'une chaîne
function Get-StringDisplayWidth {
    param([string]$Text)
    
    $width = 0
    foreach ($char in $Text.ToCharArray()) {
        # Les émojis et certains caractères asiatiques occupent 2 cellules
        $code = [int]$char
        if ($code -ge 0x1F300 -and $code -le 0x1F9FF) {
            $width += 2  # Émojis
        } elseif ($code -ge 0x4E00 -and $code -le 0x9FFF) {
            $width += 2  # Caractères chinois/japonais/coréens
        } else {
            $width += 1
        }
    }
    return $width
}

# Fonction d'alignement tenant compte de la largeur réelle
function Format-TableRow {
    param(
        [string]$Column1,
        [string]$Column2,
        [int]$Width1 = 20,
        [int]$Width2 = 20
    )
    
    $actualWidth1 = Get-StringDisplayWidth $Column1
    $padding1 = $Width1 - $actualWidth1
    
    $actualWidth2 = Get-StringDisplayWidth $Column2
    $padding2 = $Width2 - $actualWidth2
    
    "$Column1$(' ' * $padding1) │ $Column2$(' ' * $padding2)"
}
```

### 5. Documentation et exemples visuels

```powershell
# Inclure des exemples visuels dans les commentaires
<#
.SYNOPSIS
    Crée un menu avec bordures Unicode

.DESCRIPTION
    Affiche un menu formaté avec des bordures Unicode :
    
    ┌──────────────────┐
    │   Menu Options   │
    ├──────────────────┤
    │ 1. Option 1      │
    │ 2. Option 2      │
    │ 3. Quitter       │
    └──────────────────┘

.EXAMPLE
    Show-Menu -Title "Actions" -Items @("Démarrer", "Arrêter")
#>
function Show-Menu {
    param(
        [string]$Title,
        [string[]]$Items
    )
    
    # Implémentation...
}
```

### 6. Tests de compatibilité

```powershell
# Fonction de test complète
function Test-UnicodeCompatibility {
    Write-Host "`n=== Test de compatibilité Unicode ===" -ForegroundColor Cyan
    
    # 1. Encodage
    Write-Host "`n1. Encodage actuel:"
    Write-Host "   Output: $([Console]::OutputEncoding.EncodingName)"
    Write-Host "   Input: $([Console]::InputEncoding.EncodingName)"
    
    # 2. Terminal
    Write-Host "`n2. Environnement terminal:"
    if (Test-WindowsTerminal) {
        Write-Host "   ✓ Windows Terminal" -ForegroundColor Green
    } elseif (Test-VSCodeTerminal) {
        Write-Host "   ✓ VS Code Terminal" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Console classique" -ForegroundColor Yellow
    }
    
    # 3. Test d'affichage
    Write-Host "`n3. Test d'affichage:"
    Write-Host "   Bordures: ┌─┐│└┘ ╔═╗║╚╝"
    Write-Host "   Symboles: ✓ ✗ ★ ● ◆"
    Write-Host "   Flèches: ← → ↑ ↓ ⇒"
    
    # 4. Recommandations
    Write-Host "`n4. Recommandations:"
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        Write-Host "   ⚠ Utilisez PowerShell 7+ pour un meilleur support" -ForegroundColor Yellow
    } else {
        Write-Host "   ✓ Version PowerShell optimale" -ForegroundColor Green
    }
}
```

---

## 🔧 Astuces avancées

### 1. Création de cadres dynamiques avec titre

```powershell
function New-TitledBox {
    param(
        [string]$Title,
        [string[]]$Content,
        [ValidateSet('Simple','Double','Rounded')]
        [string]$Style = 'Simple'
    )
    
    # Sélection du style
    $borders = switch ($Style) {
        'Simple' {
            @{ TL='┌'; TR='┐'; BL='└'; BR='┘'; H='─'; V='│'; CL='├'; CR='┤' }
        }
        'Double' {
            @{ TL='╔'; TR='╗'; BL='╚'; BR='╝'; H='═'; V='║'; CL='╠'; CR='╣' }
        }
        'Rounded' {
            @{ TL='╭'; TR='╮'; BL='╰'; BR='╯'; H='─'; V='│'; CL='├'; CR='┤' }
        }
    }
    
    # Calcul de la largeur maximale
    $maxLength = ($Content + $Title | Measure-Object Length -Maximum).Maximum
    $width = $maxLength + 4  # Padding de 2 de chaque côté
    
    # Affichage du cadre avec titre
    $b = $borders
    
    # Ligne du haut avec titre
    $titlePadding = $width - $Title.Length - 2
    $leftPad = [Math]::Floor($titlePadding / 2)
    $rightPad = $titlePadding - $leftPad
    
    Write-Host "$($b.TL)$($b.H * $leftPad) $Title $($b.H * $rightPad)$($b.TR)" -ForegroundColor Cyan
    
    # Séparateur après le titre
    Write-Host "$($b.CL)$($b.H * $width)$($b.CR)" -ForegroundColor Cyan
    
    # Contenu
    foreach ($line in $Content) {
        $linePadding = $width - $line.Length - 2
        Write-Host "$($b.V) $line$(' ' * $linePadding) $($b.V)"
    }
    
    # Ligne du bas
    Write-Host "$($b.BL)$($b.H * $width)$($b.BR)" -ForegroundColor Cyan
}

# Utilisation
New-TitledBox -Title "Configuration" -Style Rounded -Content @(
    "Serveur: localhost",
    "Port: 8080",
    "Status: Actif"
)
```

### 2. Tableaux complexes avec Unicode

```powershell
function New-UnicodeTable {
    param(
        [string[]]$Headers,
        [array]$Rows,
        [int[]]$ColumnWidths
    )
    
    $b = @{ TL='┌'; TR='┐'; BL='└'; BR='┘'; H='─'; V='│'
            CL='├'; CR='┤'; CT='┬'; CB='┴'; X='┼' }
    
    # Ligne du haut
    $topLine = $b.TL
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        $topLine += $b.H * ($ColumnWidths[$i] + 2)
        if ($i -lt $Headers.Count - 1) {
            $topLine += $b.CT
        }
    }
    $topLine += $b.TR
    Write-Host $topLine -ForegroundColor Cyan
    
    # En-têtes
    $headerLine = $b.V
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        $padding = $ColumnWidths[$i] - $Headers[$i].Length
        $headerLine += " $($Headers[$i])$(' ' * $padding) $($b.V)"
    }
    Write-Host $headerLine -ForegroundColor Yellow
    
    # Séparateur d'en-tête
    $sepLine = $b.CL
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        $sepLine += $b.H * ($ColumnWidths[$i] + 2)
        if ($i -lt $Headers.Count - 1) {
            $sepLine += $b.X
        }
    }
    $sepLine += $b.CR
    Write-Host $sepLine -ForegroundColor Cyan
    
    # Lignes de données
    foreach ($row in $Rows) {
        $dataLine = $b.V
        for ($i = 0; $i -lt $row.Count; $i++) {
            $padding = $ColumnWidths[$i] - $row[$i].Length
            $dataLine += " $($row[$i])$(' ' * $padding) $($b.V)"
        }
        Write-Host $dataLine
    }
    
    # Ligne du bas
    $bottomLine = $b.BL
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        $bottomLine += $b.H * ($ColumnWidths[$i] + 2)
        if ($i -lt $Headers.Count - 1) {
            $bottomLine += $b.CB
        }
    }
    $bottomLine += $b.BR
    Write-Host $bottomLine -ForegroundColor Cyan
}

# Utilisation
New-UnicodeTable -Headers @("Nom", "Status", "CPU%") `
                 -Rows @(
                     @("Service1", "✓ Actif", "45"),
                     @("Service2", "✗ Arrêté", "0"),
                     @("Service3", "✓ Actif", "23")
                 ) `
                 -ColumnWidths @(15, 12, 8)
```

### 3. Barre de progression avec Unicode

```powershell
function Show-UnicodeProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [int]$Width = 40,
        [string]$Label = "Progression"
    )
    
    $percent = [Math]::Round(($Current / $Total) * 100)
    $filled = [Math]::Floor(($Current / $Total) * $Width)
    $empty = $Width - $filled
    
    # Caractères de progression
    $fillChar = '█'     # U+2588 (bloc plein)
    $emptyChar = '░'    # U+2591 (bloc léger)
    $leftCap = '▐'      # U+2590 (demi-bloc droit)
    $rightCap = '▌'     # U+258C (demi-bloc gauche)
    
    # Construction de la barre
    $bar = $leftCap + ($fillChar * $filled) + ($emptyChar * $empty) + $rightCap
    
    # Affichage
    $color = if ($percent -lt 33) { 'Red' }
             elseif ($percent -lt 66) { 'Yellow' }
             else { 'Green' }
    
    Write-Host "$Label : " -NoNewline
    Write-Host $bar -ForegroundColor $color -NoNewline
    Write-Host " $percent% ($Current/$Total)"
}

# Simulation de progression
for ($i = 0; $i -le 100; $i += 10) {
    Clear-Host
    Show-UnicodeProgressBar -Current $i -Total 100 -Label "Installation"
    Start-Sleep -Milliseconds 500
}
```

### 4. Spinner animé

```powershell
function Show-Spinner {
    param(
        [scriptblock]$Task,
        [string]$Message = "Traitement en cours"
    )
    
    # Différents styles de spinners
    $spinners = @{
        'Braille' = @('⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏')
        'Dots' = @('⣾','⣽','⣻','⢿','⡿','⣟','⣯','⣷')
        'Line' = @('-','\','|','/')
        'Arrow' = @('←','↖','↑','↗','→','↘','↓','↙')
    }
    
    $frames = $spinners['Braille']
    $i = 0
    
    # Job pour la tâche
    $job = Start-Job -ScriptBlock $Task
    
    # Animation pendant l'exécution
    while ($job.State -eq 'Running') {
        $frame = $frames[$i % $frames.Count]
        Write-Host "`r$frame $Message" -NoNewline -ForegroundColor Cyan
        $i++
        Start-Sleep -Milliseconds 100
    }
    
    # Résultat
    $result = Receive-Job -Job $job
    Remove-Job -Job $job
    
    Write-Host "`r✓ $Message - Terminé" -ForegroundColor Green
    
    return $result
}

# Utilisation
$result = Show-Spinner -Message "Téléchargement des données" -Task {
    Start-Sleep -Seconds 3
    return "Données téléchargées"
}
```

### 5. Bibliothèque de caractères complète

```powershell
# Module de caractères Unicode réutilisable
$Global:UnicodeChars = @{
    Borders = @{
        Light = @{
            TL='┌'; TR='┐'; BL='└'; BR='┘'; H='─'; V='│'
            CL='├'; CR='┤'; CT='┬'; CB='┴'; X='┼'
        }
        Double = @{
            TL='╔'; TR='╗'; BL='╚'; BR='╝'; H='═'; V='║'
            CL='╠'; CR='╣'; CT='╦'; CB='╩'; X='╬'
        }
        Rounded = @{
            TL='╭'; TR='╮'; BL='╰'; BR='╯'; H='─'; V='│'
        }
        Heavy = @{
            TL='┏'; TR='┓'; BL='┗'; BR='┛'; H='━'; V='┃'
        }
    }
    
    Arrows = @{
        Simple = @{ U='↑'; D='↓'; L='←'; R='→' }
        Double = @{ U='⇑'; D='⇓'; L='⇐'; R='⇒' }
        Triangle = @{ U='▲'; D='▼'; L='◄'; R='►' }
    }
    
    Bullets = @{
        Dot = '•'; Circle = '○'; Square = '□'
        FilledCircle = '●'; FilledSquare = '■'
        Star = '★'; EmptyStar = '☆'
        Check = '✓'; Cross = '✗'
        HeavyCheck = '✔'; HeavyCross = '✘'
    }
    
    Blocks = @{
        Full = '█'; Light = '░'; Medium = '▒'; Dark = '▓'
        Upper = '▀'; Lower = '▄'; Left = '▌'; Right = '▐'
    }
    
    Symbols = @{
        Gear = '⚙'; Warning = '⚠'; Info = 'ℹ'
        Success = '✓'; Error = '✗'; Pending = '⏳'
    }
}

# Fonction d'accès rapide
function Get-UnicodeChar {
    param(
        [Parameter(Mandatory)]
        [string]$Category,
        [Parameter(Mandatory)]
        [string]$Name
    )
    
    return $Global:UnicodeChars.$Category.$Name
}

# Utilisation
$border = Get-UnicodeChar -Category 'Borders' -Name 'Light'
Write-Host "$($border.TL)$($border.H * 20)$($border.TR)"
```

> [!tip] Astuce finale Créez votre propre module de caractères Unicode que vous pourrez importer dans tous vos scripts :
> 
> ```powershell
> # Dans UnicodeChars.psm1
> Export-ModuleMember -Variable UnicodeChars
> Export-ModuleMember -Function Get-UnicodeChar, New-TitledBox, Show-UnicodeProgressBar
> 
> # Dans vos scripts
> Import-Module .\UnicodeChars.psm1
> ```

---

_Fin du cours - Les caractères Unicode et bordures sont maintenant maîtrisés ! 🎨_