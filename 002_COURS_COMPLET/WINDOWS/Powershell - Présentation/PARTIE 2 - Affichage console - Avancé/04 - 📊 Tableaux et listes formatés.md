

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

## 🎯 Format-Table personnalisé

### Pourquoi Format-Table ?

`Format-Table` est la cmdlet native de PowerShell pour afficher des données tabulaires. Elle offre un contrôle précis sur l'apparence des colonnes, l'alignement, et la largeur, transformant des objets bruts en présentations professionnelles.

> [!info] Quand l'utiliser
> 
> - Affichage de résultats de requêtes (processus, services, fichiers)
> - Comparaison de données structurées
> - Rapports lisibles dans la console
> - Tableaux de bord en temps réel

### Syntaxe de base

```powershell
# Syntaxe simple
Get-Process | Format-Table -Property Name, CPU, Memory

# Syntaxe avec alias (ft)
Get-Service | ft Name, Status, StartType

# Avec AutoSize pour ajuster automatiquement les colonnes
Get-ChildItem | Format-Table Name, Length, LastWriteTime -AutoSize
```

### Personnalisation avancée des colonnes

```powershell
# Colonnes personnalisées avec expressions calculées
Get-Process | Format-Table -Property @{
    Label = "Processus"
    Expression = {$_.Name}
    Width = 30
    Alignment = "Left"
}, @{
    Label = "Mémoire (MB)"
    Expression = {[math]::Round($_.WorkingSet / 1MB, 2)}
    Width = 15
    Alignment = "Right"
}, @{
    Label = "CPU %"
    Expression = {$_.CPU}
    Width = 10
    Alignment = "Right"
}

# Utilisation de FormatString pour les formats numériques
Get-Process | Format-Table Name, @{
    Label = "Mémoire"
    Expression = {$_.WorkingSet / 1MB}
    FormatString = "{0:N2} MB"
}, @{
    Label = "CPU"
    Expression = {$_.CPU}
    FormatString = "{0:N3} s"
}
```

> [!tip] Astuces de personnalisation
> 
> - **Label** : Nom affiché dans l'en-tête
> - **Expression** : Script block qui calcule la valeur
> - **Width** : Largeur fixe de la colonne (en caractères)
> - **Alignment** : "Left", "Right", ou "Center"
> - **FormatString** : Format .NET pour les valeurs (N2 = 2 décimales, P0 = pourcentage, etc.)

### Groupement de données

```powershell
# Grouper par une propriété
Get-Service | Sort-Object Status | Format-Table -GroupBy Status

# Groupement avec en-tête personnalisé
Get-Process | Sort-Object Company | Format-Table -GroupBy @{
    Label = "Éditeur"
    Expression = {if ($_.Company) {$_.Company} else {"Non spécifié"}}
}
```

### Masquage et sélection des colonnes

```powershell
# Afficher toutes les propriétés (attention à la largeur)
Get-Process | Format-Table * -Wrap

# Sélectionner des colonnes spécifiques
Get-Process | Format-Table Name, Id, CPU, WorkingSet -AutoSize

# Masquer les en-têtes (-HideTableHeaders)
1..5 | ForEach-Object {
    [PSCustomObject]@{Num = $_; Carré = $_ * $_}
} | Format-Table -HideTableHeaders
```

> [!warning] Pièges courants
> 
> - **Format-Table coupe la sortie** : Utilisez `-AutoSize` ou spécifiez des largeurs
> - **Trop de colonnes** : La console peut tronquer, préférez `-Wrap` ou réduisez les colonnes
> - **Performance** : `Format-Table` consomme toutes les données avant d'afficher, évitez sur de très gros volumes
> - **Pipeline** : `Format-Table` termine le pipeline, aucune manipulation n'est possible après

### Bonnes pratiques

```powershell
# ✅ BON : AutoSize pour des données courtes
Get-Process | Select-Object -First 10 | Format-Table -AutoSize

# ✅ BON : Largeurs fixes pour des rapports reproductibles
$rapport | Format-Table @{L="ID";E={$_.Id};W=5}, @{L="Nom";E={$_.Name};W=25}

# ❌ MAUVAIS : Format-Table au milieu du pipeline
Get-Process | Format-Table Name, CPU | Where-Object {$_.CPU -gt 10} # Ne fonctionne pas !

# ✅ BON : Filtrer AVANT Format-Table
Get-Process | Where-Object {$_.CPU -gt 10} | Format-Table Name, CPU
```

---

## 🎨 Création de tableaux ASCII

### Pourquoi des tableaux ASCII ?

Les tableaux ASCII offrent une présentation visuelle immédiate avec des bordures et des séparateurs, idéaux pour des rapports, des logs, ou des affichages structurés qui doivent être copiés ou archivés.

> [!info] Avantages
> 
> - Lisibilité maximale même dans des fichiers texte
> - Compatibilité universelle (logs, emails, documentation)
> - Esthétique professionnelle
> - Pas de dépendance à des cmdlets ou modules

### Fonction de base pour tableaux ASCII

```powershell
function New-AsciiTable {
    param(
        [Parameter(Mandatory)]
        [object[]]$Data,
        
        [string[]]$Properties,
        
        [char]$BorderChar = '─',
        [char]$VerticalChar = '│',
        [char]$CornerChar = '┼'
    )
    
    # Sélectionner les propriétés à afficher
    if (-not $Properties) {
        $Properties = $Data[0].PSObject.Properties.Name
    }
    
    # Calculer les largeurs maximales pour chaque colonne
    $columnWidths = @{}
    foreach ($prop in $Properties) {
        $maxWidth = $prop.Length
        foreach ($item in $Data) {
            $value = $item.$prop.ToString()
            if ($value.Length -gt $maxWidth) {
                $maxWidth = $value.Length
            }
        }
        $columnWidths[$prop] = $maxWidth
    }
    
    # Fonction helper pour créer une ligne de séparation
    function Get-Separator {
        param([string]$Position) # "Top", "Middle", "Bottom"
        
        $left = switch ($Position) {
            "Top"    { "┌" }
            "Middle" { "├" }
            "Bottom" { "└" }
        }
        $right = switch ($Position) {
            "Top"    { "┐" }
            "Middle" { "┤" }
            "Bottom" { "┘" }
        }
        $cross = switch ($Position) {
            "Top"    { "┬" }
            "Middle" { "┼" }
            "Bottom" { "┴" }
        }
        
        $segments = foreach ($prop in $Properties) {
            $BorderChar * ($columnWidths[$prop] + 2)
        }
        
        return $left + ($segments -join $cross) + $right
    }
    
    # Ligne supérieure
    Write-Host (Get-Separator "Top") -ForegroundColor Cyan
    
    # En-tête
    $headerParts = foreach ($prop in $Properties) {
        " {0,-$($columnWidths[$prop])} " -f $prop
    }
    Write-Host "$VerticalChar$($headerParts -join $VerticalChar)$VerticalChar" -ForegroundColor Yellow
    
    # Ligne de séparation après l'en-tête
    Write-Host (Get-Separator "Middle") -ForegroundColor Cyan
    
    # Données
    foreach ($item in $Data) {
        $rowParts = foreach ($prop in $Properties) {
            $value = if ($null -ne $item.$prop) { $item.$prop.ToString() } else { "" }
            " {0,-$($columnWidths[$prop])} " -f $value
        }
        Write-Host "$VerticalChar$($rowParts -join $VerticalChar)$VerticalChar"
    }
    
    # Ligne inférieure
    Write-Host (Get-Separator "Bottom") -ForegroundColor Cyan
}

# Exemple d'utilisation
$data = @(
    [PSCustomObject]@{Nom="Alice"; Age=30; Ville="Paris"}
    [PSCustomObject]@{Nom="Bob"; Age=25; Ville="Lyon"}
    [PSCustomObject]@{Nom="Charlie"; Age=35; Ville="Marseille"}
)

New-AsciiTable -Data $data
```

> [!example] Résultat
> 
> ```
> ┌─────────┬─────┬───────────┐
> │ Nom     │ Age │ Ville     │
> ├─────────┼─────┼───────────┤
> │ Alice   │ 30  │ Paris     │
> │ Bob     │ 25  │ Lyon      │
> │ Charlie │ 35  │ Marseille │
> └─────────┴─────┴───────────┘
> ```

### Styles de bordures disponibles

```powershell
# Style simple (ASCII pur)
function New-SimpleTable {
    param([object[]]$Data, [string[]]$Properties)
    
    $chars = @{
        TopLeft = "+"
        TopRight = "+"
        BottomLeft = "+"
        BottomRight = "+"
        Horizontal = "-"
        Vertical = "|"
        Cross = "+"
    }
    
    # ... Même logique avec ces caractères
}

# Style double bordure
$doubleChars = @{
    TopLeft = "╔"
    TopRight = "╗"
    BottomLeft = "╚"
    BottomRight = "╝"
    Horizontal = "═"
    Vertical = "║"
    TopCross = "╦"
    MiddleCross = "╬"
    BottomCross = "╩"
}

# Style arrondi
$roundedChars = @{
    TopLeft = "╭"
    TopRight = "╮"
    BottomLeft = "╰"
    BottomRight = "╯"
    Horizontal = "─"
    Vertical = "│"
    Cross = "┼"
}
```

> [!tip] Caractères Unicode utiles
> 
> |Style|Caractères|Usage|
> |---|---|---|
> |Simple|`+ - │`|Compatibilité maximale|
> |Ligne simple|`┌ ┐ └ ┘ ─ │ ┼`|Moderne et léger|
> |Ligne double|`╔ ╗ ╚ ╝ ═ ║ ╬`|Emphase forte|
> |Arrondi|`╭ ╮ ╰ ╯ ─ │`|Style doux|

### Tableau avec couleurs conditionnelles

```powershell
function New-ColoredAsciiTable {
    param(
        [object[]]$Data,
        [string[]]$Properties,
        [scriptblock]$ColorCondition
    )
    
    # ... En-têtes et séparateurs identiques ...
    
    # Données avec couleurs conditionnelles
    foreach ($item in $Data) {
        $color = if ($ColorCondition) {
            & $ColorCondition $item
        } else {
            "White"
        }
        
        $rowParts = foreach ($prop in $Properties) {
            " {0,-$($columnWidths[$prop])} " -f $item.$prop
        }
        Write-Host "│$($rowParts -join '│')│" -ForegroundColor $color
    }
}

# Exemple avec coloration
$processus = Get-Process | Select-Object -First 10 Name, CPU, WorkingSet

New-ColoredAsciiTable -Data $processus -ColorCondition {
    param($row)
    if ($row.CPU -gt 10) { "Red" }
    elseif ($row.CPU -gt 5) { "Yellow" }
    else { "Green" }
}
```

> [!warning] Limitations des tableaux ASCII
> 
> - **Largeur de console** : Les tableaux larges seront tronqués ou wrappés
> - **Performance** : Calculer les largeurs et construire les lignes est plus lent que `Format-Table`
> - **Unicode** : Certains terminaux anciens n'affichent pas correctement les caractères spéciaux
> - **Données volumineuses** : Évitez pour des milliers de lignes

---

## 📐 Colonnes alignées

### Pourquoi l'alignement compte ?

L'alignement correct des colonnes améliore drastiquement la lisibilité : nombres à droite, texte à gauche, et tout bien espacé crée une présentation professionnelle et facile à scanner visuellement.

> [!info] Règles d'alignement standard
> 
> - **Texte** : Aligné à gauche
> - **Nombres** : Alignés à droite
> - **Dates** : Alignées à gauche ou droite selon le format
> - **Booléens** : Centrés
> - **En-têtes** : Généralement alignés comme les données

### Alignement avec Format-Table

```powershell
# Alignement explicite par colonne
Get-Process | Select-Object -First 5 | Format-Table @{
    Label = "Nom du processus"
    Expression = {$_.Name}
    Alignment = "Left"
    Width = 25
}, @{
    Label = "ID"
    Expression = {$_.Id}
    Alignment = "Right"
    Width = 8
}, @{
    Label = "Mémoire (MB)"
    Expression = {[math]::Round($_.WorkingSet / 1MB, 2)}
    Alignment = "Right"
    Width = 12
}, @{
    Label = "Priorité"
    Expression = {$_.PriorityClass}
    Alignment = "Center"
    Width = 15
}
```

### Fonction d'alignement personnalisée

```powershell
function Format-AlignedColumn {
    param(
        [string]$Value,
        [int]$Width,
        [ValidateSet("Left", "Right", "Center")]
        [string]$Alignment = "Left",
        [char]$PadChar = ' '
    )
    
    $Value = $Value.ToString()
    
    # Tronquer si trop long
    if ($Value.Length -gt $Width) {
        return $Value.Substring(0, $Width - 3) + "..."
    }
    
    # Calculer le padding nécessaire
    $padding = $Width - $Value.Length
    
    switch ($Alignment) {
        "Left" {
            return $Value.PadRight($Width, $PadChar)
        }
        "Right" {
            return $Value.PadLeft($Width, $PadChar)
        }
        "Center" {
            $leftPad = [math]::Floor($padding / 2)
            $rightPad = $padding - $leftPad
            return (' ' * $leftPad) + $Value + (' ' * $rightPad)
        }
    }
}

# Exemple d'utilisation
$nom = Format-AlignedColumn -Value "Alice" -Width 20 -Alignment Left
$age = Format-AlignedColumn -Value "30" -Width 5 -Alignment Right
$statut = Format-AlignedColumn -Value "Actif" -Width 10 -Alignment Center

Write-Host "$nom | $age | $statut"
```

### Tableau multi-colonnes avec alignement précis

```powershell
function Show-AlignedTable {
    param(
        [Parameter(Mandatory)]
        [object[]]$Data,
        
        [Parameter(Mandatory)]
        [hashtable[]]$ColumnDefinitions
        # Format: @{Name="PropName"; Header="Display"; Width=10; Align="Right"}
    )
    
    # Afficher les en-têtes
    $headerLine = foreach ($col in $ColumnDefinitions) {
        Format-AlignedColumn -Value $col.Header -Width $col.Width -Alignment $col.Align
    }
    Write-Host ($headerLine -join " │ ") -ForegroundColor Cyan
    
    # Ligne de séparation
    $separator = foreach ($col in $ColumnDefinitions) {
        "─" * $col.Width
    }
    Write-Host ($separator -join "─┼─") -ForegroundColor DarkGray
    
    # Afficher les données
    foreach ($item in $Data) {
        $rowLine = foreach ($col in $ColumnDefinitions) {
            $value = $item.($col.Name)
            if ($null -eq $value) { $value = "" }
            Format-AlignedColumn -Value $value -Width $col.Width -Alignment $col.Align
        }
        Write-Host ($rowLine -join " │ ")
    }
}

# Exemple avec plusieurs types d'alignement
$employes = @(
    [PSCustomObject]@{Nom="Alice Martin"; Poste="Développeur"; Salaire=45000; Actif=$true}
    [PSCustomObject]@{Nom="Bob Durant"; Poste="Manager"; Salaire=65000; Actif=$true}
    [PSCustomObject]@{Nom="Charlie Petit"; Poste="Analyste"; Salaire=38000; Actif=$false}
)

$colonnes = @(
    @{Name="Nom"; Header="Employé"; Width=20; Align="Left"}
    @{Name="Poste"; Header="Fonction"; Width=15; Align="Left"}
    @{Name="Salaire"; Header="Salaire (€)"; Width=12; Align="Right"}
    @{Name="Actif"; Header="Statut"; Width=8; Align="Center"}
)

Show-AlignedTable -Data $employes -ColumnDefinitions $colonnes
```

> [!tip] Astuces d'alignement
> 
> - **Détection automatique** : Alignez les nombres à droite en testant si `$value -is [int]` ou `$value -is [double]`
> - **Padding uniforme** : Ajoutez 1-2 espaces de marge dans chaque colonne pour aérer
> - **Troncature intelligente** : Utilisez `...` à la fin des valeurs tronquées
> - **Monospace** : Ces techniques ne fonctionnent que dans des polices monospace (console standard)

### Gestion des valeurs nulles et vides

```powershell
function Format-SafeValue {
    param(
        [object]$Value,
        [string]$NullDisplay = "N/A",
        [string]$EmptyDisplay = "—"
    )
    
    if ($null -eq $Value) {
        return $NullDisplay
    }
    
    $strValue = $Value.ToString().Trim()
    if ([string]::IsNullOrEmpty($strValue)) {
        return $EmptyDisplay
    }
    
    return $strValue
}

# Intégrer dans le tableau
$rowLine = foreach ($col in $ColumnDefinitions) {
    $value = Format-SafeValue -Value $item.($col.Name)
    Format-AlignedColumn -Value $value -Width $col.Width -Alignment $col.Align
}
```

> [!warning] Pièges d'alignement
> 
> - **Polices proportionnelles** : L'alignement échoue dans des éditeurs avec polices variables
> - **Caractères spéciaux** : Les émojis et caractères larges faussent le calcul de largeur
> - **Encodage** : Certains caractères Unicode occupent plus d'espace visuel
> - **Redimensionnement** : Les tableaux fixes deviennent illisibles si la console est trop étroite

---

## 🎯 En-têtes stylisés

### Pourquoi styliser les en-têtes ?

Des en-têtes bien mis en valeur guident l'œil, structurent l'information, et donnent un aspect professionnel à vos scripts. Ils servent de repères visuels instantanés dans des sorties longues.

> [!info] Objectifs des en-têtes stylisés
> 
> - **Hiérarchie visuelle** : Différencier les niveaux d'information
> - **Séparation** : Délimiter clairement les sections
> - **Branding** : Donner une identité visuelle à vos scripts
> - **Navigation** : Faciliter le scan rapide de la sortie

### En-têtes simples avec bordures

```powershell
function Write-SectionHeader {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [ConsoleColor]$Color = "Cyan",
        [char]$BorderChar = "═",
        [int]$Width = 60
    )
    
    # Bordure supérieure
    Write-Host ($BorderChar * $Width) -ForegroundColor $Color
    
    # Titre centré
    $padding = [math]::Max(0, ($Width - $Title.Length - 2) / 2)
    $centeredTitle = (" " * $padding) + $Title
    Write-Host $centeredTitle -ForegroundColor $Color
    
    # Bordure inférieure
    Write-Host ($BorderChar * $Width) -ForegroundColor $Color
    Write-Host ""
}

# Utilisation
Write-SectionHeader -Title "RAPPORT SYSTÈME" -Color Yellow
Write-SectionHeader -Title "Processus actifs" -Color Cyan -BorderChar "─"
```

### En-têtes avec icônes et couleurs

```powershell
function Write-StyledHeader {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [string]$Icon = "●",
        [ConsoleColor]$TitleColor = "White",
        [ConsoleColor]$IconColor = "Cyan",
        [ConsoleColor]$BorderColor = "DarkGray",
        [string]$BorderStyle = "double" # "simple", "double", "heavy"
    )
    
    $chars = switch ($BorderStyle) {
        "simple" { @{Top="─"; Left="│"; Corner="┌┐└┘"} }
        "double" { @{Top="═"; Left="║"; Corner="╔╗╚╝"} }
        "heavy"  { @{Top="━"; Left="┃"; Corner="┏┓┗┛"} }
    }
    
    $width = $Title.Length + 8
    $topBorder = $chars.Corner[0] + ($chars.Top * ($width - 2)) + $chars.Corner[1]
    $bottomBorder = $chars.Corner[2] + ($chars.Top * ($width - 2)) + $chars.Corner[3]
    
    Write-Host $topBorder -ForegroundColor $BorderColor
    Write-Host $chars.Left -NoNewline -ForegroundColor $BorderColor
    Write-Host " $Icon " -NoNewline -ForegroundColor $IconColor
    Write-Host $Title -NoNewline -ForegroundColor $TitleColor
    Write-Host " $Icon " -NoNewline -ForegroundColor $IconColor
    Write-Host $chars.Left -ForegroundColor $BorderColor
    Write-Host $bottomBorder -ForegroundColor $BorderColor
    Write-Host ""
}

# Exemples d'utilisation
Write-StyledHeader -Title "ANALYSE EN COURS" -Icon "⚙" -TitleColor Yellow
Write-StyledHeader -Title "RÉSULTATS" -Icon "✓" -TitleColor Green -BorderStyle "heavy"
Write-StyledHeader -Title "ERREUR DÉTECTÉE" -Icon "✗" -TitleColor Red -IconColor Red
```

### En-têtes avec gradient et effets

```powershell
function Write-GradientHeader {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [ConsoleColor[]]$ColorGradient = @("DarkBlue", "Blue", "Cyan", "White")
    )
    
    $width = 70
    $border = "═" * $width
    
    # Afficher le titre avec un gradient de couleurs
    Write-Host $border -ForegroundColor $ColorGradient[0]
    
    $titlePadding = [math]::Floor(($width - $Title.Length) / 2)
    Write-Host (" " * $titlePadding) -NoNewline
    
    # Colorer chaque caractère avec le gradient
    for ($i = 0; $i -lt $Title.Length; $i++) {
        $colorIndex = [math]::Floor($i / $Title.Length * ($ColorGradient.Length - 1))
        Write-Host $Title[$i] -NoNewline -ForegroundColor $ColorGradient[$colorIndex]
    }
    Write-Host ""
    
    Write-Host $border -ForegroundColor $ColorGradient[-1]
    Write-Host ""
}

# Exemple
Write-GradientHeader -Title "TABLEAU DE BORD SYSTÈME"
```

### En-têtes de tableau avec sous-titres

```powershell
function Write-TableHeader {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [string]$Subtitle,
        [string[]]$ColumnHeaders,
        [int[]]$ColumnWidths,
        [ConsoleColor]$TitleColor = "Yellow",
        [ConsoleColor]$HeaderColor = "Cyan"
    )
    
    # Titre principal
    $totalWidth = ($ColumnWidths | Measure-Object -Sum).Sum + ($ColumnWidths.Count - 1) * 3
    $border = "═" * $totalWidth
    
    Write-Host $border -ForegroundColor $TitleColor
    
    $titlePadding = [math]::Floor(($totalWidth - $Title.Length) / 2)
    Write-Host (" " * $titlePadding) -NoNewline
    Write-Host $Title -ForegroundColor $TitleColor -BackgroundColor Black
    
    if ($Subtitle) {
        $subtitlePadding = [math]::Floor(($totalWidth - $Subtitle.Length) / 2)
        Write-Host (" " * $subtitlePadding) -NoNewline
        Write-Host $Subtitle -ForegroundColor DarkGray
    }
    
    Write-Host $border -ForegroundColor $TitleColor
    Write-Host ""
    
    # En-têtes de colonnes
    $headerLine = for ($i = 0; $i -lt $ColumnHeaders.Count; $i++) {
        Format-AlignedColumn -Value $ColumnHeaders[$i] -Width $ColumnWidths[$i] -Alignment Center
    }
    Write-Host ($headerLine -join " │ ") -ForegroundColor $HeaderColor
    
    $separator = for ($i = 0; $i -lt $ColumnWidths.Count; $i++) {
        "─" * $ColumnWidths[$i]
    }
    Write-Host ($separator -join "─┼─") -ForegroundColor DarkGray
}

# Exemple d'utilisation
Write-TableHeader `
    -Title "RAPPORT DE PERFORMANCE" `
    -Subtitle "Généré le $(Get-Date -Format 'dd/MM/yyyy à HH:mm')" `
    -ColumnHeaders @("Processus", "CPU %", "Mémoire (MB)", "Statut") `
    -ColumnWidths @(25, 10, 15, 12)
```

### En-têtes avec encadrement complet

```powershell
function Write-BoxedHeader {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [string[]]$Lines,
        [ConsoleColor]$Color = "Cyan",
        [int]$Padding = 2
    )
    
    # Calculer la largeur nécessaire
    $allText = @($Title) + $Lines
    $maxLength = ($allText | Measure-Object -Property Length -Maximum).Maximum
    $boxWidth = $maxLength + ($Padding * 2) + 2
    
    # Dessiner la boîte
    Write-Host ("╔" + ("═" * ($boxWidth - 2)) + "╗") -ForegroundColor $Color
    
    # Titre
    $titlePadding = [math]::Floor(($boxWidth - 2 - $Title.Length) / 2)
    Write-Host "║" -NoNewline -ForegroundColor $Color
    Write-Host (" " * $titlePadding) -NoNewline
    Write-Host $Title -NoNewline -ForegroundColor White
    Write-Host (" " * ($boxWidth - 2 - $titlePadding - $Title.Length)) -NoNewline
    Write-Host "║" -ForegroundColor $Color
    
    # Ligne de séparation
    if ($Lines.Count -gt 0) {
        Write-Host ("╟" + ("─" * ($boxWidth - 2)) + "╢") -ForegroundColor $Color
    }
    
    # Lignes supplémentaires
    foreach ($line in $Lines) {
        Write-Host "║" -NoNewline -ForegroundColor $Color
        Write-Host (" " * $Padding) -NoNewline
        Write-Host $line.PadRight($maxLength) -NoNewline
        Write-Host (" " * $Padding) -NoNewline
        Write-Host "║" -ForegroundColor $Color
    }
    
    # Bordure inférieure
    Write-Host ("╚" + ("═" * ($boxWidth - 2)) + "╝") -ForegroundColor $Color
    Write-Host ""
}

# Exemple avec contexte
Write-BoxedHeader -Title "SYSTÈME DE MONITORING" -Lines @(
    "Serveur : $env:COMPUTERNAME",
    "Utilisateur : $env:USERNAME",
    "Date : $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
) -Color Green
```

> [!tip] Astuces pour les en-têtes
> 
> - **Cohérence** : Utilisez le même style d'en-tête dans tout votre script
> - **Hiérarchie** : Variez les styles (double bordure pour titre principal, simple pour sous-sections)
> - **Espacement** : Ajoutez toujours une ligne vide après un en-tête pour aérer
> - **Largeur adaptative** : Calculez la largeur en fonction du contenu ou de la console
> - **Contexte** : Incluez des informations utiles (date, machine, utilisateur) dans les sous-titres

### Templates d'en-têtes réutilisables

```powershell
# Collection de templates d'en-têtes prêts à l'emploi
$HeaderTemplates = @{
    Success = @{
        Icon = "✓"
        Color = "Green"
        BorderStyle = "double"
    }
    Error = @{
        Icon = "✗"
        Color = "Red"
        BorderStyle = "heavy"
    }
    Warning = @{
        Icon = "⚠"
        Color = "Yellow"
        BorderStyle = "simple"
    }
    Info = @{
        Icon = "ℹ"
        Color = "Cyan"
        BorderStyle = "simple"
    }
    Process = @{
        Icon = "⚙"
        Color = "Blue"
        BorderStyle = "double"
    }
}

function Write-TemplatedHeader {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [ValidateSet("Success", "Error", "Warning", "Info", "Process")]
        [string]$Template = "Info"
    )
    
    $config = $HeaderTemplates[$Template]
    Write-StyledHeader -Title $Title -Icon $config.Icon -TitleColor $config.Color -BorderStyle $config.BorderStyle
}

# Utilisation simple
Write-TemplatedHeader -Title "OPÉRATION RÉUSSIE" -Template Success
Write-TemplatedHeader -Title "ERREUR CRITIQUE" -Template Error
Write-TemplatedHeader -Title "TRAITEMENT EN COURS" -Template Process
```

### En-têtes animés (pour scripts interactifs)

```powershell
function Write-AnimatedHeader {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [int]$AnimationSpeed = 50
    )
    
    $frames = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
    $width = $Title.Length + 10
    
    # Animation d'apparition
    for ($i = 0; $i -lt 8; $i++) {
        $cursorPos = $host.UI.RawUI.CursorPosition
        Write-Host (" " * $width) -NoNewline
        $host.UI.RawUI.CursorPosition = $cursorPos
        
        Write-Host "$($frames[$i % $frames.Length]) " -NoNewline -ForegroundColor Cyan
        Write-Host $Title -NoNewline -ForegroundColor White
        Write-Host " $($frames[$i % $frames.Length])" -ForegroundColor Cyan
        
        Start-Sleep -Milliseconds $AnimationSpeed
    }
    
    # Affichage final
    $cursorPos = $host.UI.RawUI.CursorPosition
    Write-Host (" " * $width) -NoNewline
    $host.UI.RawUI.CursorPosition = $cursorPos
    
    Write-Host ("═" * $width) -ForegroundColor Cyan
    $padding = [math]::Floor(($width - $Title.Length) / 2)
    Write-Host (" " * $padding) -NoNewline
    Write-Host $Title -ForegroundColor White
    Write-Host ("═" * $width) -ForegroundColor Cyan
    Write-Host ""
}

# Pour un effet d'attente pendant un traitement
Write-AnimatedHeader -Title "CHARGEMENT DES DONNÉES"
```

### En-têtes avec informations système contextuelles

```powershell
function Write-SystemHeader {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [switch]$IncludeSystemInfo,
        [switch]$IncludeTimestamp,
        [ConsoleColor]$Color = "Cyan"
    )
    
    $width = 80
    $lines = @()
    
    # Ligne de titre principale
    $lines += "═" * $width
    $titlePadding = [math]::Floor(($width - $Title.Length) / 2)
    $titleLine = (" " * $titlePadding) + $Title
    
    Write-Host $lines[0] -ForegroundColor $Color
    Write-Host $titleLine -ForegroundColor White
    
    # Informations contextuelles
    if ($IncludeSystemInfo -or $IncludeTimestamp) {
        Write-Host ("─" * $width) -ForegroundColor DarkGray
        
        if ($IncludeSystemInfo) {
            $computerInfo = "Ordinateur: $env:COMPUTERNAME | Utilisateur: $env:USERNAME"
            $infoPadding = [math]::Floor(($width - $computerInfo.Length) / 2)
            Write-Host (" " * $infoPadding) -NoNewline
            Write-Host $computerInfo -ForegroundColor Gray
        }
        
        if ($IncludeTimestamp) {
            $timestamp = "Généré le $(Get-Date -Format 'dd/MM/yyyy à HH:mm:ss')"
            $timePadding = [math]::Floor(($width - $timestamp.Length) / 2)
            Write-Host (" " * $timePadding) -NoNewline
            Write-Host $timestamp -ForegroundColor Gray
        }
    }
    
    Write-Host ("═" * $width) -ForegroundColor $Color
    Write-Host ""
}

# Exemple avec contexte complet
Write-SystemHeader -Title "RAPPORT D'ANALYSE SYSTÈME" -IncludeSystemInfo -IncludeTimestamp
```

### Combinaison : En-tête + Tableau complet

```powershell
function Show-CompleteReport {
    param(
        [Parameter(Mandatory)]
        [string]$ReportTitle,
        
        [Parameter(Mandatory)]
        [object[]]$Data,
        
        [Parameter(Mandatory)]
        [hashtable[]]$Columns,
        
        [string]$Subtitle,
        [ConsoleColor]$HeaderColor = "Yellow"
    )
    
    # Calculer la largeur totale du rapport
    $totalWidth = ($Columns.Width | Measure-Object -Sum).Sum + ($Columns.Count - 1) * 3
    
    # En-tête principal du rapport
    Write-Host ""
    Write-Host ("╔" + ("═" * ($totalWidth - 2)) + "╗") -ForegroundColor $HeaderColor
    
    $titlePadding = [math]::Floor(($totalWidth - 2 - $ReportTitle.Length) / 2)
    Write-Host "║" -NoNewline -ForegroundColor $HeaderColor
    Write-Host (" " * $titlePadding) -NoNewline
    Write-Host $ReportTitle -NoNewline -ForegroundColor White
    Write-Host (" " * ($totalWidth - 2 - $titlePadding - $ReportTitle.Length)) -NoNewline
    Write-Host "║" -ForegroundColor $HeaderColor
    
    # Sous-titre si fourni
    if ($Subtitle) {
        Write-Host "║" -NoNewline -ForegroundColor $HeaderColor
        $subPadding = [math]::Floor(($totalWidth - 2 - $Subtitle.Length) / 2)
        Write-Host (" " * $subPadding) -NoNewline
        Write-Host $Subtitle -NoNewline -ForegroundColor DarkGray
        Write-Host (" " * ($totalWidth - 2 - $subPadding - $Subtitle.Length)) -NoNewline
        Write-Host "║" -ForegroundColor $HeaderColor
    }
    
    Write-Host ("╠" + ("═" * ($totalWidth - 2)) + "╣") -ForegroundColor $HeaderColor
    
    # En-têtes de colonnes
    Write-Host "║" -NoNewline -ForegroundColor $HeaderColor
    $headerLine = foreach ($col in $Columns) {
        Format-AlignedColumn -Value $col.Header -Width $col.Width -Alignment Center
    }
    Write-Host (" " + ($headerLine -join " │ ") + " ") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor $HeaderColor
    
    # Séparateur sous les en-têtes
    Write-Host "║" -NoNewline -ForegroundColor $HeaderColor
    $separator = foreach ($col in $Columns) {
        "─" * $col.Width
    }
    Write-Host (" " + ($separator -join "─┼─") + " ") -NoNewline -ForegroundColor DarkGray
    Write-Host "║" -ForegroundColor $HeaderColor
    
    # Données
    foreach ($item in $Data) {
        Write-Host "║" -NoNewline -ForegroundColor $HeaderColor
        $rowLine = foreach ($col in $Columns) {
            $value = $item.($col.Name)
            if ($null -eq $value) { $value = "" }
            Format-AlignedColumn -Value $value -Width $col.Width -Alignment $col.Align
        }
        Write-Host (" " + ($rowLine -join " │ ") + " ") -NoNewline
        Write-Host "║" -ForegroundColor $HeaderColor
    }
    
    # Pied du rapport
    Write-Host ("╚" + ("═" * ($totalWidth - 2)) + "╝") -ForegroundColor $HeaderColor
    Write-Host ""
    
    # Résumé
    $totalItems = $Data.Count
    Write-Host "Total: $totalItems élément(s)" -ForegroundColor Gray
    Write-Host ""
}

# Exemple d'utilisation complète
$processus = Get-Process | Select-Object -First 5 | ForEach-Object {
    [PSCustomObject]@{
        Nom = $_.Name
        PID = $_.Id
        Memoire = [math]::Round($_.WorkingSet / 1MB, 2)
        CPU = if ($_.CPU) { [math]::Round($_.CPU, 2) } else { 0 }
    }
}

$colonnes = @(
    @{Name="Nom"; Header="Processus"; Width=25; Align="Left"}
    @{Name="PID"; Header="ID"; Width=8; Align="Right"}
    @{Name="Memoire"; Header="Mémoire (MB)"; Width=15; Align="Right"}
    @{Name="CPU"; Header="CPU (s)"; Width=12; Align="Right"}
)

Show-CompleteReport `
    -ReportTitle "PROCESSUS SYSTÈME" `
    -Subtitle "Top 5 par utilisation mémoire" `
    -Data $processus `
    -Columns $colonnes `
    -HeaderColor Green
```

> [!example] Résultat attendu
> 
> ```
> ╔════════════════════════════════════════════════════════════╗
> ║                    PROCESSUS SYSTÈME                       ║
> ║            Top 5 par utilisation mémoire                   ║
> ╠════════════════════════════════════════════════════════════╣
> ║      Processus      │   ID   │  Mémoire (MB)  │  CPU (s)   ║
> ║ ────────────────────┼────────┼────────────────┼─────────── ║
> ║ chrome              │   1234 │         450.25 │     12.34  ║
> ║ explorer            │   5678 │         320.15 │      8.91  ║
> ║ code                │   9012 │         280.50 │     45.67  ║
> ║ firefox             │   3456 │         195.75 │      6.23  ║
> ║ powershell          │   7890 │          85.30 │      2.15  ║
> ╚════════════════════════════════════════════════════════════╝
> 
> Total: 5 élément(s)
> ```

> [!warning] Pièges des en-têtes stylisés
> 
> - **Largeur de console** : Vérifiez que vos en-têtes ne dépassent pas `$Host.UI.RawUI.WindowSize.Width`
> - **Compatibilité** : Certains terminaux (anciens CMD, PowerShell ISE) affichent mal les caractères Unicode
> - **Performances** : Les en-têtes animés peuvent ralentir les scripts avec beaucoup de sorties
> - **Redirection** : Les caractères spéciaux peuvent poser problème lors de la redirection vers des fichiers (utilisez `Out-File -Encoding UTF8`)
> - **Accessibilité** : Les lecteurs d'écran peuvent avoir du mal avec les tableaux ASCII complexes

### Bonnes pratiques générales

```powershell
# ✅ BON : Fonction réutilisable et configurable
function Write-ReportHeader {
    param($Title, $Color = "Cyan")
    Write-Host ("═" * 60) -ForegroundColor $Color
    Write-Host $Title.PadLeft(30 + $Title.Length/2) -ForegroundColor White
    Write-Host ("═" * 60) -ForegroundColor $Color
}

# ✅ BON : Adaptation à la largeur de la console
$consoleWidth = $Host.UI.RawUI.WindowSize.Width - 2
Write-Host ("═" * $consoleWidth) -ForegroundColor Cyan

# ✅ BON : Gestion des erreurs pour caractères Unicode
try {
    Write-Host "╔═══╗" -ForegroundColor Cyan
} catch {
    Write-Host "+===+" -ForegroundColor Cyan # Fallback ASCII
}

# ❌ MAUVAIS : En-tête codé en dur
Write-Host "============================================"
Write-Host "          MON SUPER RAPPORT"
Write-Host "============================================"

# ❌ MAUVAIS : Largeur fixe qui dépasse la console
Write-Host ("═" * 120) # Risque de wrap sur petites consoles
```

---

## 🎓 Synthèse et cas d'usage

### Quand utiliser chaque technique ?

|Technique|Cas d'usage idéal|Avantages|Inconvénients|
|---|---|---|---|
|**Format-Table**|Affichage rapide de données structurées|Native, rapide, intégrée|Peu de contrôle visuel|
|**Tableaux ASCII**|Rapports archivables, logs, documentation|Très lisible, universel|Plus lent, nécessite du code|
|**Colonnes alignées**|Données mixtes (texte + nombres)|Lisibilité maximale|Requiert calcul manuel|
|**En-têtes stylisés**|Scripts interactifs, rapports formels|Impact visuel fort|Complexité accrue|

### Exemple complet : Rapport système professionnel

```powershell
function Get-SystemReport {
    # En-tête principal
    Write-SystemHeader -Title "RAPPORT SYSTÈME COMPLET" -IncludeSystemInfo -IncludeTimestamp
    
    # Section 1: Processus
    Write-TemplatedHeader -Title "PROCESSUS ACTIFS" -Template Process
    $processus = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5
    $processusData = $processus | ForEach-Object {
        [PSCustomObject]@{
            Nom = $_.Name
            PID = $_.Id
            Memoire = [math]::Round($_.WorkingSet / 1MB, 2)
            CPU = if ($_.CPU) { [math]::Round($_.CPU, 2) } else { 0 }
        }
    }
    
    $colonnesProc = @(
        @{Name="Nom"; Header="Processus"; Width=25; Align="Left"}
        @{Name="PID"; Header="ID"; Width=8; Align="Right"}
        @{Name="Memoire"; Header="Mémoire (MB)"; Width=15; Align="Right"}
        @{Name="CPU"; Header="CPU (s)"; Width=12; Align="Right"}
    )
    
    Show-AlignedTable -Data $processusData -ColumnDefinitions $colonnesProc
    
    # Section 2: Services
    Write-TemplatedHeader -Title "SERVICES CRITIQUES" -Template Info
    $services = Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object -First 5
    $servicesData = $services | ForEach-Object {
        [PSCustomObject]@{
            Nom = $_.Name
            Affichage = $_.DisplayName.Substring(0, [Math]::Min(30, $_.DisplayName.Length))
            Statut = $_.Status
            Type = $_.StartType
        }
    }
    
    $colonnesSvc = @(
        @{Name="Nom"; Header="Service"; Width=20; Align="Left"}
        @{Name="Affichage"; Header="Nom d'affichage"; Width=32; Align="Left"}
        @{Name="Statut"; Header="État"; Width=10; Align="Center"}
        @{Name="Type"; Header="Démarrage"; Width=12; Align="Left"}
    )
    
    Show-AlignedTable -Data $servicesData -ColumnDefinitions $colonnesSvc
    
    # Pied de rapport
    Write-Host ""
    Write-Host ("═" * 80) -ForegroundColor Green
    Write-Host "Rapport généré avec succès ✓" -ForegroundColor Green
    Write-Host ("═" * 80) -ForegroundColor Green
}

# Exécution
Get-SystemReport
```

> [!tip] Optimisations finales
> 
> - **Mise en cache** : Calculez les largeurs de colonnes une seule fois et réutilisez-les
> - **Lazy loading** : Pour de grandes quantités de données, affichez par batch
> - **Couleurs conditionnelles** : Utilisez des seuils pour colorer automatiquement (rouge si CPU > 80%, vert sinon)
> - **Export** : Prévoyez une option pour exporter en CSV ou HTML sans les caractères spéciaux
> - **Modularité** : Créez un module PowerShell avec toutes vos fonctions de formatage pour les réutiliser

---

## 📚 Récapitulatif

Vous maîtrisez maintenant :

✅ **Format-Table personnalisé**

- Colonnes calculées avec expressions
- Alignement et largeur précis
- Groupement et formatage avancé

✅ **Tableaux ASCII**

- Construction manuelle avec bordures
- Différents styles de caractères
- Tableaux colorés conditionnellement

✅ **Colonnes alignées**

- Fonctions d'alignement (gauche, droite, centré)
- Gestion des valeurs nulles
- Calcul automatique des largeurs

✅ **En-têtes stylisés**

- En-têtes avec bordures et icônes
- Templates réutilisables
- Rapports complets avec contexte

Ces techniques transforment vos scripts PowerShell en outils professionnels avec des sorties claires, structurées et visuellement engageantes. Adaptez-les à vos besoins spécifiques et créez votre propre bibliothèque de fonctions de formatage !