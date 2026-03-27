

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

## Introduction

L'affichage console est l'une des opérations les plus courantes en PowerShell, mais aussi l'une des plus coûteuses en termes de performance. Chaque appel à `Write-Host` ou `Write-Output` peut ralentir considérablement votre script, particulièrement dans les boucles ou lors de l'affichage de grandes quantités de données.

> [!info] Pourquoi optimiser l'affichage ?
> 
> - L'écriture console est 10 à 100 fois plus lente que les opérations en mémoire
> - Les scripts avec affichage intensif peuvent prendre plusieurs secondes voire minutes
> - Une bonne optimisation améliore l'expérience utilisateur et la réactivité

---

## 1. StringBuilder pour concaténation

### 📖 Concept

Le **StringBuilder** est une classe .NET optimisée pour la construction de chaînes de caractères par ajouts successifs. Contrairement à la concaténation classique avec `+` ou `+=`, le StringBuilder modifie un buffer interne sans créer de nouvelles instances de chaînes à chaque opération.

### 🎯 Pourquoi l'utiliser ?

**Problème avec la concaténation classique :**

- Chaque opération `$string += "texte"` crée une nouvelle chaîne en mémoire
- L'ancienne chaîne est marquée pour garbage collection
- Pour 1000 ajouts, cela crée 1000 objets temporaires en mémoire

**Avantage du StringBuilder :**

- Un seul buffer redimensionnable
- Modifications en place sans allocation multiple
- Performance jusqu'à 100x supérieure pour les grandes chaînes

### 💻 Syntaxe et utilisation

```powershell
# ❌ MAUVAISE PRATIQUE - Concaténation lente
$resultat = ""
foreach ($i in 1..1000) {
    $resultat += "Ligne $i`n"  # Crée 1000 objets String
}
Write-Host $resultat

# ✅ BONNE PRATIQUE - StringBuilder
$sb = New-Object System.Text.StringBuilder

foreach ($i in 1..1000) {
    [void]$sb.AppendLine("Ligne $i")  # Modification en place
}

# Affichage final
Write-Host $sb.ToString()
```

### 🔧 Méthodes principales

```powershell
# Créer un StringBuilder
$sb = New-Object System.Text.StringBuilder

# Ou avec capacité initiale (évite les redimensionnements)
$sb = New-Object System.Text.StringBuilder(10000)

# Ajouter du texte
[void]$sb.Append("Texte sans retour ligne")
[void]$sb.AppendLine("Texte avec retour ligne")

# Ajouter avec format
[void]$sb.AppendFormat("Valeur : {0}", $variable)

# Insérer à une position
[void]$sb.Insert(0, "Au début : ")

# Remplacer du texte
[void]$sb.Replace("ancien", "nouveau")

# Supprimer une portion
[void]$sb.Remove(0, 5)  # Supprime 5 caractères depuis position 0

# Obtenir la chaîne finale
$texteComplet = $sb.ToString()

# Vider le StringBuilder (réutilisation)
[void]$sb.Clear()
```

> [!tip] Astuce : [void] pour supprimer la sortie Les méthodes de StringBuilder retournent l'objet lui-même. Utilisez `[void]` ou `$null =` pour éviter l'affichage involontaire :
> 
> ```powershell
> [void]$sb.Append("texte")        # Recommandé
> $null = $sb.Append("texte")      # Alternative
> $sb.Append("texte") | Out-Null   # Plus lent, à éviter
> ```

### 📊 Comparaison de performance

```powershell
# Test de performance
$iterations = 5000

# Méthode 1 : Concaténation classique
Measure-Command {
    $texte = ""
    1..$iterations | ForEach-Object {
        $texte += "Ligne $_`n"
    }
} | Select-Object TotalSeconds

# Méthode 2 : StringBuilder
Measure-Command {
    $sb = New-Object System.Text.StringBuilder
    1..$iterations | ForEach-Object {
        [void]$sb.AppendLine("Ligne $_")
    }
    $texte = $sb.ToString()
} | Select-Object TotalSeconds

# Résultat typique :
# Concaténation : 15-20 secondes
# StringBuilder : 0.1-0.2 secondes (100x plus rapide)
```

### ⚠️ Pièges courants

```powershell
# ❌ Oublier [void] pollue la sortie
$sb = New-Object System.Text.StringBuilder
$sb.Append("Texte")  # Affiche l'objet StringBuilder

# ❌ Convertir trop tôt en String
$sb = New-Object System.Text.StringBuilder
foreach ($i in 1..100) {
    $texte = $sb.ToString()  # Conversion inutile à chaque itération
    [void]$sb.AppendLine("Ligne $i")
}

# ✅ Convertir une seule fois à la fin
$sb = New-Object System.Text.StringBuilder
foreach ($i in 1..100) {
    [void]$sb.AppendLine("Ligne $i")
}
$texte = $sb.ToString()  # Conversion finale
```

### 💡 Cas d'usage recommandés

|Situation|Recommandation|
|---|---|
|Moins de 10 ajouts|Concaténation classique acceptable|
|10-100 ajouts|StringBuilder recommandé|
|Plus de 100 ajouts|StringBuilder obligatoire|
|Construction HTML/XML|StringBuilder + capacité initiale|
|Logs en boucle|StringBuilder avec AppendLine|
|Rapport final|StringBuilder puis Write-Host unique|

---

## 2. Limitation des Write-Host

### 📖 Concept

`Write-Host` est une cmdlet qui écrit directement dans la console, en contournant le pipeline PowerShell. Bien qu'utile pour l'affichage utilisateur, elle est très coûteuse en performance et doit être utilisée avec parcimonie.

### 🎯 Pourquoi limiter Write-Host ?

**Coûts de Write-Host :**

- Chaque appel interrompt l'exécution pour afficher
- Synchronisation avec le buffer console
- Pas de buffering automatique
- Impact multiplicatif dans les boucles

**Impact en chiffres :**

```powershell
# Test : 10000 Write-Host
Measure-Command {
    1..10000 | ForEach-Object {
        Write-Host "Ligne $_"
    }
}
# Résultat : 5-10 secondes

# Test : 1 Write-Host final
Measure-Command {
    $sb = New-Object System.Text.StringBuilder
    1..10000 | ForEach-Object {
        [void]$sb.AppendLine("Ligne $_")
    }
    Write-Host $sb.ToString()
}
# Résultat : 0.2-0.5 secondes (20x plus rapide)
```

### 💻 Stratégies d'optimisation

#### ✅ Stratégie 1 : Accumuler puis afficher

```powershell
# ❌ MAUVAIS - Write-Host à chaque itération
foreach ($fichier in Get-ChildItem) {
    Write-Host "Traitement de $($fichier.Name)..." -ForegroundColor Green
    # ... traitement ...
}

# ✅ BON - Accumuler les messages
$messages = [System.Collections.Generic.List[string]]::new()
foreach ($fichier in Get-ChildItem) {
    $messages.Add("Traitement de $($fichier.Name)...")
    # ... traitement ...
}
Write-Host ($messages -join "`n") -ForegroundColor Green
```

#### ✅ Stratégie 2 : Affichage conditionnel

```powershell
# ❌ MAUVAIS - Affichage systématique
foreach ($item in 1..10000) {
    Write-Host "Traitement de l'item $item"
    # ... traitement ...
}

# ✅ BON - Affichage tous les N éléments
$total = 10000
foreach ($item in 1..$total) {
    if ($item % 100 -eq 0) {  # Affiche tous les 100 items
        Write-Host "Progression : $item/$total ($(($item/$total*100).ToString('0.0'))%)"
    }
    # ... traitement ...
}
```

#### ✅ Stratégie 3 : Mode verbeux optionnel

```powershell
# Affichage contrôlé par paramètre
param(
    [switch]$Verbose
)

function Process-Data {
    param($data)
    
    foreach ($item in $data) {
        # Traitement
        $result = $item * 2
        
        # Affichage uniquement si demandé
        if ($Verbose) {
            Write-Host "Item $item -> Résultat : $result"
        }
    }
}

# Utilisation
Process-Data -data (1..1000)              # Rapide, pas d'affichage
Process-Data -data (1..1000) -Verbose     # Lent mais informatif
```

### 🔄 Alternatives à Write-Host

```powershell
# Write-Output : sortie dans le pipeline (plus rapide)
Write-Output "Ce texte peut être capturé ou redirigé"

# Write-Verbose : pour les détails de débogage
Write-Verbose "Détails de traitement" -Verbose

# Write-Information : pour les messages informatifs (PS 5+)
Write-Information "Information importante" -InformationAction Continue

# Progression avec Write-Progress (ne bloque pas la console)
1..100 | ForEach-Object {
    Write-Progress -Activity "Traitement" -Status "Item $_" -PercentComplete $_
    Start-Sleep -Milliseconds 50
}
```

### 📊 Tableau comparatif

|Cmdlet|Performance|Pipeline|Couleurs|Cas d'usage|
|---|---|---|---|---|
|`Write-Host`|⚠️ Lent|❌ Non|✅ Oui|Affichage utilisateur final|
|`Write-Output`|✅ Rapide|✅ Oui|❌ Non|Retour de données|
|`Write-Verbose`|✅ Rapide|❌ Non|❌ Non|Débogage optionnel|
|`Write-Information`|✅ Rapide|✅ Oui|❌ Non|Logs structurés|
|`Write-Progress`|✅ Rapide|❌ Non|✅ Oui|Barres de progression|

> [!warning] Piège avec Write-Output dans les fonctions `Write-Output` dans une fonction retourne des valeurs, pas seulement de l'affichage :
> 
> ```powershell
> function Get-Data {
>     Write-Output "Message de débogage"  # ❌ Fait partie du retour !
>     return 42
> }
> 
> $resultat = Get-Data  # $resultat contient ["Message de débogage", 42]
> 
> # Solution : utiliser Write-Verbose ou Write-Information
> function Get-Data {
>     Write-Verbose "Message de débogage"
>     return 42
> }
> ```

### 💡 Bonnes pratiques

```powershell
# ✅ Pattern recommandé pour scripts utilisateur
param([switch]$Quiet)

function Write-UserMessage {
    param([string]$Message, [string]$Color = "White")
    if (-not $Quiet) {
        Write-Host $Message -ForegroundColor $Color
    }
}

# Utilisation dans le script
$resultats = @()
foreach ($item in $data) {
    $resultat = Process-Item $item
    $resultats += $resultat
    
    # Affichage groupé tous les 100 items
    if ($resultats.Count % 100 -eq 0) {
        Write-UserMessage "Traité : $($resultats.Count) items" -Color Green
    }
}

# Affichage final
Write-UserMessage "`nTraitement terminé : $($resultats.Count) items" -Color Cyan
```

---

## 3. Buffering de sortie

### 📖 Concept

Le **buffering** (mise en tampon) consiste à accumuler les données en mémoire avant de les écrire d'un seul coup dans la console. Cela réduit le nombre d'appels système coûteux et améliore drastiquement les performances.

### 🎯 Pourquoi utiliser le buffering ?

**Sans buffering :**

- Chaque `Write-Host` = un appel au système d'exploitation
- Synchronisation console à chaque ligne
- Ralentissements visibles à l'écran

**Avec buffering :**

- Accumulation en mémoire (rapide)
- Un seul appel système pour tout afficher
- Affichage quasi instantané

### 💻 Techniques de buffering

#### ✅ Méthode 1 : Array ou List

```powershell
# Avec tableau classique
$buffer = @()
foreach ($i in 1..1000) {
    $buffer += "Ligne $i"  # ⚠️ Pas optimal (réallocation à chaque +=)
}
Write-Host ($buffer -join "`n")

# ✅ Avec List générique (meilleure performance)
$buffer = [System.Collections.Generic.List[string]]::new()
foreach ($i in 1..1000) {
    $buffer.Add("Ligne $i")  # Optimal (capacité dynamique)
}
Write-Host ($buffer -join "`n")
```

#### ✅ Méthode 2 : StringBuilder (recommandé pour gros volumes)

```powershell
# Pour de très grandes quantités de texte
$buffer = New-Object System.Text.StringBuilder(50000)  # Capacité initiale

foreach ($i in 1..10000) {
    [void]$buffer.AppendLine("Ligne $i avec du texte supplémentaire")
}

# Affichage unique
Write-Host $buffer.ToString()
```

#### ✅ Méthode 3 : Buffering par blocs

```powershell
# Buffering par blocs de N lignes (compromis mémoire/performance)
$tailleBloc = 100
$buffer = [System.Collections.Generic.List[string]]::new($tailleBloc)

foreach ($i in 1..10000) {
    $buffer.Add("Ligne $i")
    
    # Vider le buffer tous les 100 items
    if ($buffer.Count -eq $tailleBloc) {
        Write-Host ($buffer -join "`n")
        $buffer.Clear()
    }
}

# Afficher le reste
if ($buffer.Count -gt 0) {
    Write-Host ($buffer -join "`n")
}
```

### 🔧 Configuration du buffer console

```powershell
# Augmenter la taille du buffer console (évite le scrollback)
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(120, 9999)

# Désactiver le wrapping automatique pour performance
$host.PrivateData.ProgressForegroundColor = 'Yellow'

# Récupérer les informations du buffer
$bufferInfo = $host.UI.RawUI.BufferSize
Write-Host "Largeur : $($bufferInfo.Width)"
Write-Host "Hauteur : $($bufferInfo.Height)"
```

### 📊 Comparaison des méthodes

```powershell
# Test comparatif de performance
$iterations = 5000

# Méthode 1 : Sans buffering
$temps1 = Measure-Command {
    1..$iterations | ForEach-Object {
        Write-Host "Ligne $_"
    }
}

# Méthode 2 : Buffering avec Array
$temps2 = Measure-Command {
    $buffer = @()
    1..$iterations | ForEach-Object {
        $buffer += "Ligne $_"
    }
    Write-Host ($buffer -join "`n")
}

# Méthode 3 : Buffering avec List
$temps3 = Measure-Command {
    $buffer = [System.Collections.Generic.List[string]]::new()
    1..$iterations | ForEach-Object {
        $buffer.Add("Ligne $_")
    }
    Write-Host ($buffer -join "`n")
}

# Méthode 4 : StringBuilder
$temps4 = Measure-Command {
    $sb = New-Object System.Text.StringBuilder
    1..$iterations | ForEach-Object {
        [void]$sb.AppendLine("Ligne $_")
    }
    Write-Host $sb.ToString()
}

# Résultats typiques pour 5000 lignes :
# Sans buffering    : ~3-5 secondes
# Array +=          : ~2-3 secondes
# List.Add()        : ~0.1-0.2 secondes
# StringBuilder     : ~0.1-0.2 secondes
```

### ⚠️ Pièges courants

```powershell
# ❌ Buffer trop grand en mémoire
$buffer = @()
foreach ($i in 1..1000000) {
    $buffer += "Ligne $i avec beaucoup de texte..."  # Risque OutOfMemory
}

# ✅ Buffering par blocs pour limiter la mémoire
$tailleBloc = 1000
$buffer = [System.Collections.Generic.List[string]]::new($tailleBloc)
foreach ($i in 1..1000000) {
    $buffer.Add("Ligne $i avec beaucoup de texte...")
    if ($buffer.Count -eq $tailleBloc) {
        Write-Host ($buffer -join "`n")
        $buffer.Clear()
    }
}

# ❌ Oublier de vider le buffer final
foreach ($i in 1..150) {
    $buffer.Add("Ligne $i")
    if ($buffer.Count -eq 100) {
        Write-Host ($buffer -join "`n")
        $buffer.Clear()
    }
}
# Les 50 dernières lignes ne s'affichent jamais !

# ✅ Toujours vider le reste
if ($buffer.Count -gt 0) {
    Write-Host ($buffer -join "`n")
}
```

### 💡 Pattern complet optimisé

```powershell
function Write-BufferedOutput {
    param(
        [Parameter(Mandatory)]
        [string[]]$Lines,
        
        [int]$BufferSize = 100,
        
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    
    $buffer = [System.Collections.Generic.List[string]]::new($BufferSize)
    
    foreach ($line in $Lines) {
        $buffer.Add($line)
        
        if ($buffer.Count -eq $BufferSize) {
            Write-Host ($buffer -join "`n") -ForegroundColor $Color
            $buffer.Clear()
        }
    }
    
    # Vider le reste du buffer
    if ($buffer.Count -gt 0) {
        Write-Host ($buffer -join "`n") -ForegroundColor $Color
    }
}

# Utilisation
$donnees = 1..10000 | ForEach-Object { "Ligne de données numéro $_" }
Write-BufferedOutput -Lines $donnees -BufferSize 500 -Color Green
```

> [!tip] Astuce : Choisir la bonne taille de bloc
> 
> - Petits blocs (50-100) : Retour visuel fréquent, légère baisse de performance
> - Moyens blocs (500-1000) : Bon compromis pour la plupart des cas
> - Grands blocs (5000+) : Performance maximale, mais délai d'affichage
> - StringBuilder sans blocs : Pour rapports finaux ou exports

---

## 4. [Console]::Write vs Write-Host

### 📖 Concept

`[Console]::Write` est une méthode .NET statique qui écrit directement dans le buffer de la console, tandis que `Write-Host` est une cmdlet PowerShell avec plus de fonctionnalités mais aussi plus de surcharge.

### 🎯 Différences fondamentales

|Caractéristique|`[Console]::Write`|`Write-Host`|
|---|---|---|
|**Type**|Méthode .NET|Cmdlet PowerShell|
|**Performance**|✅ Très rapide|⚠️ Plus lent|
|**Couleurs**|✅ Via propriétés|✅ Via paramètres|
|**Formatage**|❌ Manuel|✅ Automatique|
|**Pipeline**|❌ Non|❌ Non|
|**Surcharge**|Minimale|Parsing des paramètres|

### 💻 Syntaxe et utilisation

#### [Console]::Write - Méthode directe

```powershell
# Écriture simple sans retour ligne
[Console]::Write("Texte")

# Écriture avec retour ligne
[Console]::WriteLine("Texte avec retour")

# Définir les couleurs (global)
[Console]::ForegroundColor = [ConsoleColor]::Green
[Console]::BackgroundColor = [ConsoleColor]::Black
[Console]::WriteLine("Texte vert sur fond noir")

# Réinitialiser les couleurs
[Console]::ResetColor()

# Méthodes utiles
[Console]::Clear()                    # Effacer la console
[Console]::Beep()                     # Son système
[Console]::SetCursorPosition(10, 5)   # Positionner le curseur
```

#### Write-Host - Cmdlet PowerShell

```powershell
# Écriture simple
Write-Host "Texte"

# Avec couleurs (paramètres)
Write-Host "Texte coloré" -ForegroundColor Green -BackgroundColor Black

# Sans retour ligne
Write-Host "Début" -NoNewline
Write-Host " - Fin"  # Affiche : Début - Fin

# Avec séparateur personnalisé
Write-Host "Item1" "Item2" "Item3" -Separator " | "
# Affiche : Item1 | Item2 | Item3
```

### 📊 Test de performance comparatif

```powershell
# Benchmark : 10000 écritures
$iterations = 10000

# Test 1 : [Console]::WriteLine
$temps1 = Measure-Command {
    1..$iterations | ForEach-Object {
        [Console]::WriteLine("Ligne $_")
    }
}

# Test 2 : Write-Host
$temps2 = Measure-Command {
    1..$iterations | ForEach-Object {
        Write-Host "Ligne $_"
    }
}

# Test 3 : [Console]::Write avec couleurs
$temps3 = Measure-Command {
    [Console]::ForegroundColor = [ConsoleColor]::Green
    1..$iterations | ForEach-Object {
        [Console]::WriteLine("Ligne $_")
    }
    [Console]::ResetColor()
}

# Test 4 : Write-Host avec couleurs
$temps4 = Measure-Command {
    1..$iterations | ForEach-Object {
        Write-Host "Ligne $_" -ForegroundColor Green
    }
}

# Résultats typiques :
# [Console]::WriteLine       : ~2-3 secondes
# Write-Host                 : ~5-7 secondes (2x plus lent)
# [Console]::WriteLine color : ~2-3 secondes
# Write-Host color           : ~6-8 secondes (2-3x plus lent)
```

### 🎨 Gestion des couleurs

```powershell
# ✅ Console - Couleurs optimales (changement global)
function Write-ColoredFast {
    param($Messages, $Color)
    
    $oldColor = [Console]::ForegroundColor
    [Console]::ForegroundColor = $Color
    
    foreach ($msg in $Messages) {
        [Console]::WriteLine($msg)
    }
    
    [Console]::ForegroundColor = $oldColor
}

# Utilisation
Write-ColoredFast -Messages (1..1000 | ForEach-Object { "Ligne $_" }) -Color Green

# ⚠️ Write-Host - Plus flexible mais plus lent
function Write-ColoredSlow {
    param($Messages, $Color)
    
    foreach ($msg in $Messages) {
        Write-Host $msg -ForegroundColor $Color
    }
}
```

### 🔧 Techniques avancées avec [Console]

```powershell
# Écriture à une position spécifique (tableau de bord)
function Write-AtPosition {
    param(
        [int]$X,
        [int]$Y,
        [string]$Text,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    
    $oldX = [Console]::CursorLeft
    $oldY = [Console]::CursorTop
    $oldColor = [Console]::ForegroundColor
    
    [Console]::SetCursorPosition($X, $Y)
    [Console]::ForegroundColor = $Color
    [Console]::Write($Text)
    
    [Console]::SetCursorPosition($oldX, $oldY)
    [Console]::ForegroundColor = $oldColor
}

# Tableau de bord en temps réel
[Console]::Clear()
Write-AtPosition -X 5  -Y 2  -Text "CPU: " -Color Cyan
Write-AtPosition -X 5  -Y 3  -Text "RAM: " -Color Cyan
Write-AtPosition -X 5  -Y 4  -Text "Disk:" -Color Cyan

for ($i = 0; $i -lt 100; $i++) {
    Write-AtPosition -X 11 -Y 2 -Text "$i%" -Color Green
    Write-AtPosition -X 11 -Y 3 -Text "$($i*2)MB" -Color Yellow
    Write-AtPosition -X 11 -Y 4 -Text "$($i/2)%" -Color Red
    Start-Sleep -Milliseconds 50
}
```

### 💡 Quand utiliser quoi ?

```powershell
# ✅ Utilisez [Console]::Write quand :
# - Performance critique (boucles, gros volumes)
# - Affichage répétitif avec mêmes couleurs
# - Besoin de contrôle précis du curseur
# - Écriture sans retour ligne

# ✅ Utilisez Write-Host quand :
# - Script simple et interactif
# - Couleurs changeantes à chaque ligne
# - Lisibilité du code prioritaire
# - Performance non critique

# Exemple : Barre de progression rapide avec [Console]
function Show-FastProgress {
    param([int]$Total)
    
    $width = 50
    $oldColor = [Console]::ForegroundColor
    
    for ($i = 0; $i -le $Total; $i++) {
        $percent = [int](($i / $Total) * 100)
        $filled = [int](($i / $Total) * $width)
        $empty = $width - $filled
        
        # Retour au début de la ligne
        [Console]::CursorLeft = 0
        
        # Barre de progression
        [Console]::ForegroundColor = [ConsoleColor]::Green
        [Console]::Write("[" + ("█" * $filled))
        [Console]::ForegroundColor = [ConsoleColor]::DarkGray
        [Console]::Write(("░" * $empty) + "]")
        [Console]::ForegroundColor = [ConsoleColor]::White
        [Console]::Write(" $percent%")
        
        Start-Sleep -Milliseconds 20
    }
    
    [Console]::ForegroundColor = $oldColor
    [Console]::WriteLine()
}

Show-FastProgress -Total 100
```

> [!warning] Attention aux redirections `[Console]::Write` écrit directement dans la console et ne peut pas être redirigé :
> 
> ```powershell
> [Console]::WriteLine("Test") > output.txt  # ❌ N'écrit PAS dans le fichier
> Write-Host "Test" 6> output.txt            # ✅ Peut être capturé (stream 6)
> ```

### ⚠️ Pièges courants

```powershell
# ❌ Mélanger [Console] et Write-Host peut causer des artefacts
[Console]::Write("Début")
Write-Host " - Milieu"  # Peut s'afficher sur une nouvelle ligne
[Console]::WriteLine(" - Fin")

# ✅ Rester cohérent dans une section
[Console]::Write("Début")
[Console]::Write(" - Milieu")
[Console]::WriteLine(" - Fin")

# ❌ Oublier de réinitialiser les couleurs
[Console]::ForegroundColor = [ConsoleColor]::Red
[Console]::WriteLine("Erreur!")
# Tout le reste s'affiche en rouge !

# ✅ Toujours réinitialiser
[Console]::ForegroundColor = [ConsoleColor]::Red
[Console]::WriteLine("Erreur!")
[Console]::ResetColor()
```

### 🎯 Pattern hybride optimisé

```powershell
# Combiner le meilleur des deux mondes
function Write-OptimizedOutput {
    param(
        [string[]]$Lines,
        [ConsoleColor]$Color = [ConsoleColor]::White,
        [switch]$UseHost  # Flag pour compatibilité
    )
    
    if ($UseHost) {
        # Mode compatible mais plus lent
        foreach ($line in $Lines) {
            Write-Host $line -ForegroundColor $Color
        }
    }
    else {
        # Mode haute performance
        $oldColor = [Console]::ForegroundColor
        [Console]::ForegroundColor = $Color
        
        foreach ($line in $Lines) {
            [Console]::WriteLine($line)
        }
        
        [Console]::ForegroundColor = $oldColor
    }
}

# Utilisation
$data = 1..5000 | ForEach-Object { "Ligne $_" }
Write-OptimizedOutput -Lines $data -Color Green  # Rapide avec [Console]
Write-OptimizedOutput -Lines $data -Color Green -UseHost  # Compatible mais lent
```

---

## 5. Out-String vs Out-Default

### 📖 Concept

`Out-String` et `Out-Default` sont deux cmdlets de formatage de sortie qui convertissent des objets en représentation textuelle, mais avec des comportements et des performances très différents.

### 🎯 Différences fondamentales

|Caractéristique|`Out-String`|`Out-Default`|
|---|---|---|
|**Fonction**|Convertit en String|Formate pour affichage|
|**Retour**|String (pipeline)|Void (affichage direct)|
|**Performance**|✅ Rapide|⚠️ Plus lent|
|**Contrôle**|✅ Total|❌ Limité|
|**Buffering**|✅ Possible|❌ Immédiat|
|**Capture**|✅ Oui|❌ Difficile|

### 💻 Out-String - Conversion en texte

#### Syntaxe de base

```powershell
# Conversion simple
$objets = Get-Process | Select-Object -First 5
$texte = $objets | Out-String

# Le texte peut être manipulé
Write-Host $texte
$texte.Length  # Nombre de caractères
$texte -split "`n"  # Tableau de lignes

# Paramètres utiles
$objets | Out-String -Width 200        # Largeur personnalisée
$objets | Out-String -Stream           # Une ligne par objet (plus rapide)
```

#### -Stream : Différence cruciale

```powershell
# Sans -Stream (comportement par défaut)
$processus = Get-Process | Select-Object -First 3
$texte = $processus | Out-String
$texte.GetType()  # System.String (UN seul string)

# Avec -Stream
$lignes = $processus | Out-String -Stream
$lignes.GetType()  # System.Object[] (tableau de strings)
$lignes.Count  # Nombre de lignes individuelles

# Exemple concret
Get-Process | Select-Object -First 5 | Out-String
# Retourne 1 string multi-lignes

Get-Process | Select-Object -First 5 | Out-String -Stream
# Retourne N strings (une par ligne)
```

### 💻 Out-Default - Affichage console

```powershell
# Out-Default est implicite
Get-Process  # Équivaut à : Get-Process | Out-Default

# Out-Default formate et affiche immédiatement
Get-Service | Where-Object Status -eq 'Running' | Out-Default

# On ne peut pas capturer Out-Default facilement
$resultat = Get-Process | Out-Default  # $resultat est vide !
```

> [!info] Out-Default implicite À la fin de chaque pipeline sans redirection explicite, PowerShell ajoute automatiquement `| Out-Default`. C'est pourquoi les objets s'affichent dans la console sans que vous ayez besoin de le demander.

### 📊 Performance : Out-String vs Out-Default

```powershell
# Test 1 : Out-Default (affichage direct)
Measure-Command {
    1..1000 | ForEach-Object {
        [PSCustomObject]@{
            ID = $_
            Valeur = "Item $_"
        } | Out-Default
    }
}
# Résultat : ~3-5 secondes (formatage + affichage pour chaque objet)

# Test 2 : Out-String puis affichage unique
Measure-Command {
    $objets = 1..1000 | ForEach-Object {
        [PSCustomObject]@{
            ID = $_
            Valeur = "Item $_"
        }
    }
    Write-Host ($objets | Out-String)
}
# Résultat : ~0.3-0.5 secondes (formatage groupé + 1 affichage)

# Test 3 : Out-String -Stream avec buffering
Measure-Command {
    $objets = 1..1000 | ForEach-Object {
        [PSCustomObject]@{
            ID = $_
            Valeur = "Item $_"
        }
    }
    $lignes = $objets | Out-String -Stream
    Write-Host ($lignes -join "`n")
}
# Résultat : ~0.2-0.4 secondes (optimal)
```

### 🔧 Cas d'usage détaillés

#### ✅ Out-String pour captures et manipulations

```powershell
# Capturer la sortie formatée pour logs
$rapport = Get-Service | Where-Object Status -eq 'Running' | 
           Select-Object Name, DisplayName, Status | 
           Out-String

# Sauvegarder dans un fichier
$rapport | Set-Content -Path "rapport_services.txt"

# Envoyer par email
Send-MailMessage -Body $rapport -Subject "Rapport Services" -To "admin@example.com"

# Analyser le contenu
if ($rapport -match "ServiceImportant") {
    Write-Host "Service trouvé !"
}
```

#### ✅ Out-String -Stream pour traitement ligne par ligne

```powershell
# Filtrer les lignes vides et en-têtes
$processus = Get-Process | Select-Object -First 10
$lignes = $processus | Out-String -Stream | 
          Where-Object { $_ -and $_.Trim() } |
          Where-Object { $_ -notmatch '^[\-\s]+
     }  # Exclure les séparateurs

foreach ($ligne in $lignes) {
    if ($ligne -match 'chrome') {
        Write-Host $ligne -ForegroundColor Yellow
    }
    else {
        Write-Host $ligne
    }
}
```

#### ✅ Out-Default pour scripts interactifs simples

```powershell
# Script interactif simple (Out-Default implicite)
Get-Service | Where-Object Status -eq 'Running'

# Affichage immédiat souhaité
Write-Host "Services en cours d'exécution :"
Get-Service | Where-Object Status -eq 'Running' | 
Format-Table Name, DisplayName -AutoSize
# Out-Default est appelé automatiquement
```

### 🎨 Contrôle du formatage avec Out-String

```powershell
# Contrôler la largeur de sortie
$services = Get-Service | Select-Object -First 5

# Largeur par défaut (console)
$texte1 = $services | Out-String
Write-Host "Largeur par défaut :"
Write-Host $texte1

# Largeur personnalisée (évite la troncature)
$texte2 = $services | Out-String -Width 200
Write-Host "`nLargeur 200 caractères :"
Write-Host $texte2

# Largeur minimale pour données denses
$texte3 = $services | Out-String -Width 80
Write-Host "`nLargeur 80 caractères :"
Write-Host $texte3
```

### 💡 Pattern optimal : Buffering avec Out-String

```powershell
function Export-FormattedData {
    param(
        [Parameter(ValueFromPipeline)]
        [object[]]$InputObject,
        
        [string]$FilePath,
        
        [int]$Width = 120,
        
        [switch]$Display
    )
    
    begin {
        $buffer = [System.Collections.Generic.List[object]]::new()
    }
    
    process {
        foreach ($item in $InputObject) {
            $buffer.Add($item)
        }
    }
    
    end {
        # Conversion en texte formaté
        $texte = $buffer | Out-String -Width $Width
        
        # Affichage si demandé
        if ($Display) {
            Write-Host $texte
        }
        
        # Export si chemin fourni
        if ($FilePath) {
            $texte | Set-Content -Path $FilePath
            Write-Host "Exporté vers : $FilePath" -ForegroundColor Green
        }
        
        # Retour de la string pour réutilisation
        return $texte
    }
}

# Utilisation
Get-Process | Select-Object -First 20 | 
Export-FormattedData -Display -FilePath "processus.txt" -Width 150
```

### ⚠️ Pièges courants

```powershell
# ❌ Out-Default dans une fonction ne retourne rien
function Get-DataBroken {
    Get-Process | Select-Object -First 5 | Out-Default
}
$resultat = Get-DataBroken  # $resultat est $null !

# ✅ Retourner les objets ou utiliser Out-String
function Get-DataFixed {
    Get-Process | Select-Object -First 5
    # Ou : Get-Process | Select-Object -First 5 | Out-String
}
$resultat = Get-DataFixed  # $resultat contient les objets

# ❌ Out-String sans -Stream peut être lourd
$grosTableau = 1..10000 | ForEach-Object { 
    [PSCustomObject]@{ID=$_; Data="x"*100} 
}
$texte = $grosTableau | Out-String  # Crée une énorme string en mémoire

# ✅ Utiliser -Stream pour traiter progressivement
$grosTableau | Out-String -Stream | ForEach-Object {
    if ($_ -match 'pattern') {
        Write-Host $_
    }
}
```

### 🔄 Comparaison avec d'autres cmdlets de sortie

```powershell
# Out-String : Conversion en texte
$texte = Get-Service | Out-String
$texte.GetType()  # System.String

# Out-File : Écriture directe dans un fichier
Get-Service | Out-File "services.txt"
# Équivalent à : Get-Service | Out-String | Set-Content "services.txt"

# Out-Null : Supprimer la sortie (performance)
1..1000 | ForEach-Object { Get-Process } | Out-Null  # Ne garde rien

# Out-GridView : Interface graphique (Windows uniquement)
Get-Service | Out-GridView

# ConvertTo-Json : Conversion en JSON (pas de formatage visuel)
$json = Get-Service | Select-Object -First 5 | ConvertTo-Json
```

### 📋 Tableau récapitulatif complet

|Cmdlet|Sortie|Performance|Pipeline|Cas d'usage|
|---|---|---|---|---|
|`Out-String`|String|✅ Rapide|✅ Oui|Capture formatée, logs, exports|
|`Out-String -Stream`|String[]|✅ Très rapide|✅ Oui|Traitement ligne par ligne|
|`Out-Default`|Console|⚠️ Lent|❌ Non|Affichage interactif simple|
|`Out-File`|Fichier|✅ Rapide|❌ Non|Sauvegarde directe|
|`Out-Null`|Rien|✅ Très rapide|❌ Non|Supprimer sortie|

### 💡 Bonnes pratiques finales

```powershell
# ✅ Pour logs et rapports : Out-String + buffering
$rapport = [System.Text.StringBuilder]::new()
[void]$rapport.AppendLine("=== RAPPORT SYSTÈME ===")
[void]$rapport.AppendLine((Get-Service | Where-Object Status -eq 'Running' | Out-String))
[void]$rapport.AppendLine((Get-Process | Select-Object -First 10 | Out-String))
Write-Host $rapport.ToString()

# ✅ Pour affichage progressif : Out-String -Stream
Get-Service | Out-String -Stream | ForEach-Object {
    if ($_ -match 'Running') {
        Write-Host $_ -ForegroundColor Green
    }
    elseif ($_ -match 'Stopped') {
        Write-Host $_ -ForegroundColor Red
    }
    else {
        Write-Host $_
    }
}

# ✅ Pour scripts interactifs simples : laisser Out-Default implicite
Write-Host "Services en cours :" -ForegroundColor Cyan
Get-Service | Where-Object Status -eq 'Running' | 
Format-Table Name, DisplayName -AutoSize

# ✅ Pour exports : Out-String avec largeur fixe
$data = Get-EventLog -LogName System -Newest 50
$data | Out-String -Width 200 | Set-Content "events.txt"
```

> [!tip] Astuce : Désactiver Out-Default pour performance Dans les fonctions qui retournent des données, évitez que Out-Default ne s'exécute :
> 
> ```powershell
> function Get-LargeDataset {
>     # Sans précaution, Out-Default formatte tout à l'écran
>     1..10000 | ForEach-Object { [PSCustomObject]@{ID=$_} }
> }
> 
> # Solution 1 : Capturer immédiatement
> $data = Get-LargeDataset  # Pas d'affichage, stockage direct
> 
> # Solution 2 : Rediriger vers Out-Null si pas besoin
> Get-LargeDataset | Out-Null
> 
> # Solution 3 : Assigner à $null
> $null = Get-LargeDataset
> ```

---

## 🎯 Synthèse et recommandations

### 📊 Guide de décision rapide

```powershell
# Choisir la bonne technique selon le contexte :

# Cas 1 : Petite quantité de données (< 100 lignes)
Get-Service | Format-Table  # Out-Default implicite, acceptable

# Cas 2 : Moyenne quantité (100-1000 lignes)
$data = Get-Process | Select-Object -First 500
Write-Host ($data | Out-String)  # Buffering simple

# Cas 3 : Grande quantité (1000-10000 lignes)
$sb = [System.Text.StringBuilder]::new()
Get-Process | ForEach-Object {
    [void]$sb.AppendLine("$($_.Name) - $($_.Id)")
}
Write-Host $sb.ToString()

# Cas 4 : Très grande quantité (10000+ lignes)
$buffer = [System.Collections.Generic.List[string]]::new(1000)
Get-Process | ForEach-Object {
    $buffer.Add("$($_.Name) - $($_.Id)")
    if ($buffer.Count -eq 1000) {
        Write-Host ($buffer -join "`n")
        $buffer.Clear()
    }
}
if ($buffer.Count -gt 0) { Write-Host ($buffer -join "`n") }

# Cas 5 : Performance critique maximale
[Console]::ForegroundColor = [ConsoleColor]::Green
Get-Process | ForEach-Object {
    [Console]::WriteLine("$($_.Name) - $($_.Id)")
}
[Console]::ResetColor()
```

### ⚡ Hiérarchie de performance (du plus lent au plus rapide)

1. ❌ **Très lent** : `Write-Host` dans une boucle avec couleurs
2. ⚠️ **Lent** : `Out-Default` pour chaque objet
3. ⚠️ **Moyen** : `Write-Host` avec buffering simple (`$string +=`)
4. ✅ **Rapide** : `Out-String` avec `Write-Host` unique
5. ✅ **Très rapide** : `StringBuilder` + `Write-Host` unique
6. ✅✅ **Optimal** : `[Console]::WriteLine` avec buffering par blocs
7. 🚀 **Maximum** : `[Console]::Write` avec gestion manuelle du buffer

### 💎 Pattern universel recommandé

```powershell
function Write-PerformantOutput {
    <#
    .SYNOPSIS
    Affiche des données de manière optimisée selon la quantité
    #>
    param(
        [Parameter(ValueFromPipeline)]
        [object[]]$InputObject,
        
        [ConsoleColor]$Color = [ConsoleColor]::White,
        
        [int]$BufferSize = 500,
        
        [switch]$UseConsoleAPI
    )
    
    begin {
        $buffer = [System.Collections.Generic.List[string]]::new($BufferSize)
        $oldColor = if ($UseConsoleAPI) { [Console]::ForegroundColor }
    }
    
    process {
        foreach ($item in $InputObject) {
            $buffer.Add($item.ToString())
            
            if ($buffer.Count -ge $BufferSize) {
                if ($UseConsoleAPI) {
                    [Console]::ForegroundColor = $Color
                    foreach ($line in $buffer) {
                        [Console]::WriteLine($line)
                    }
                }
                else {
                    Write-Host ($buffer -join "`n") -ForegroundColor $Color
                }
                $buffer.Clear()
            }
        }
    }
    
    end {
        if ($buffer.Count -gt 0) {
            if ($UseConsoleAPI) {
                [Console]::ForegroundColor = $Color
                foreach ($line in $buffer) {
                    [Console]::WriteLine($line)
                }
                [Console]::ForegroundColor = $oldColor
            }
            else {
                Write-Host ($buffer -join "`n") -ForegroundColor $Color
            }
        }
    }
}

# Utilisation
Get-Process | Select-Object Name, Id | Write-PerformantOutput -Color Green
1..10000 | Write-PerformantOutput -UseConsoleAPI -BufferSize 1000
```

### 🎓 Règles d'or à retenir

> [!warning] Les 5 commandements de la performance console
> 
> 1. **Minimiser les appels** : 1 Write-Host > 1000 Write-Host
> 2. **Bufferiser** : Accumuler en mémoire puis afficher
> 3. **StringBuilder** : Pour concaténations répétées (100+ fois)
> 4. **[Console]** : Pour performance maximale et contrôle fin
> 5. **Out-String** : Pour capturer du formatage sans ralentir

---

## 📚 Récapitulatif des concepts clés

### StringBuilder

- ✅ Pour concaténations répétées (> 100 fois)
- ✅ Capacité initiale pour éviter redimensionnements
- ✅ Toujours utiliser `[void]` pour masquer sortie

### Write-Host

- ⚠️ Lent mais pratique pour scripts interactifs
- ✅ À utiliser avec buffering (accumuler puis 1 affichage)
- ✅ Limiter ou conditionner dans les boucles

### Buffering

- ✅ List<string> pour accumuler (meilleur que array)
- ✅ Vider par blocs (500-1000) pour compromis mémoire/perf
- ✅ Ne pas oublier de vider le buffer final

### [Console] vs Write-Host

- ✅ `[Console]` pour performance critique
- ✅ Couleurs globales vs paramètres
- ⚠️ `[Console]` non redirectable

### Out-String vs Out-Default

- ✅ `Out-String` pour capturer formatage
- ✅ `-Stream` pour traitement ligne par ligne
- ⚠️ `Out-Default` affiche immédiatement (pas de capture)

---

_Fin du cours - Optimisation et performance de l'affichage console_