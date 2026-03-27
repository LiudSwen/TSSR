

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

La gestion des couleurs dans la console PowerShell permet de créer des scripts plus lisibles, intuitifs et professionnels. Un affichage coloré aide à hiérarchiser l'information, attirer l'attention sur les éléments importants et améliorer l'expérience utilisateur.

> [!info] Pourquoi utiliser les couleurs ?
> 
> - **Hiérarchisation visuelle** : Distinguer titres, messages, erreurs et succès
> - **Amélioration de la lisibilité** : Réduire la fatigue visuelle lors de longues sessions
> - **Feedback utilisateur** : Indiquer clairement l'état d'une opération (succès, erreur, avertissement)
> - **Professionnalisme** : Donner un aspect soigné à vos scripts

---

## Write-Host et ses paramètres

`Write-Host` est la commande principale pour afficher du texte coloré dans la console PowerShell. Contrairement à `Write-Output`, elle écrit directement dans la console et ne retourne rien dans le pipeline.

### Syntaxe de base

```powershell
Write-Host "Votre message" -ForegroundColor <Couleur> -BackgroundColor <Couleur>
```

### Les paramètres essentiels

|Paramètre|Description|Exemple|
|---|---|---|
|`-ForegroundColor`|Définit la couleur du texte|`Red`, `Green`, `Yellow`|
|`-BackgroundColor`|Définit la couleur de fond|`Black`, `DarkBlue`, `White`|
|`-NoNewline`|N'ajoute pas de saut de ligne après le texte|Utile pour affichages sur une même ligne|
|`-Separator`|Définit le séparateur entre plusieurs objets|Par défaut : espace|

### Exemples pratiques

```powershell
# Message d'erreur en rouge
Write-Host "ERREUR : Fichier introuvable" -ForegroundColor Red

# Message de succès en vert
Write-Host "✓ Opération réussie" -ForegroundColor Green

# Avertissement en jaune sur fond noir
Write-Host "⚠ Attention : Espace disque faible" -ForegroundColor Yellow -BackgroundColor Black

# Texte sans saut de ligne
Write-Host "Chargement" -NoNewline -ForegroundColor Cyan
Write-Host "..." -ForegroundColor Cyan

# Combinaison de couleurs sur une même ligne
Write-Host "Status: " -NoNewline -ForegroundColor White
Write-Host "ACTIF" -ForegroundColor Green
```

> [!tip] Astuce : Raccourcir les noms de paramètres PowerShell accepte les noms de paramètres abrégés :
> 
> ```powershell
> Write-Host "Message" -F Green -B Black
> # Équivalent à :
> Write-Host "Message" -ForegroundColor Green -BackgroundColor Black
> ```

> [!warning] Attention à Write-Host `Write-Host` écrit directement dans la console et ne peut pas être capturé ou redirigé. Pour des scripts qui doivent retourner des données, préférez `Write-Output` ou `Write-Information` (mais ces commandes ont des options de coloration limitées).

---

## Les 16 couleurs de base

PowerShell offre 16 couleurs standard pour la console, divisées en couleurs normales et leurs variantes sombres.

### Tableau des couleurs disponibles

|Couleur|Variante sombre|Usage recommandé|
|---|---|---|
|`White`|`Gray`|Texte normal, informations générales|
|`Black`|`DarkGray`|Fond, texte secondaire|
|`Red`|`DarkRed`|Erreurs critiques, alertes|
|`Green`|`DarkGreen`|Succès, validations|
|`Yellow`|`DarkYellow`|Avertissements, attention|
|`Blue`|`DarkBlue`|Informations, en-têtes|
|`Magenta`|`DarkMagenta`|Éléments spéciaux, debug|
|`Cyan`|`DarkCyan`|Liens, références|

### Démonstration de toutes les couleurs

```powershell
# Script pour afficher toutes les couleurs disponibles
$couleurs = @(
    'Black', 'DarkBlue', 'DarkGreen', 'DarkCyan',
    'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray',
    'DarkGray', 'Blue', 'Green', 'Cyan',
    'Red', 'Magenta', 'Yellow', 'White'
)

Write-Host "`n=== Palette de couleurs PowerShell ===" -ForegroundColor Cyan

foreach ($couleur in $couleurs) {
    # Affichage sur fond noir
    Write-Host "$couleur".PadRight(15) -ForegroundColor $couleur -NoNewline
    Write-Host " | " -NoNewline
    
    # Affichage sur fond blanc
    Write-Host "$couleur".PadRight(15) -ForegroundColor $couleur -BackgroundColor White
}
```

### Convention de nommage pour la lisibilité

```powershell
# Créer un système de couleurs cohérent
function Show-Success { 
    param($Message)
    Write-Host "✓ $Message" -ForegroundColor Green 
}

function Show-Error { 
    param($Message)
    Write-Host "✗ $Message" -ForegroundColor Red 
}

function Show-Warning { 
    param($Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow 
}

function Show-Info { 
    param($Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan 
}

# Utilisation
Show-Success "Connexion établie"
Show-Error "Impossible de se connecter"
Show-Warning "Le certificat expire dans 7 jours"
Show-Info "Traitement en cours..."
```

> [!example] Exemple : Menu coloré
> 
> ```powershell
> function Show-Menu {
>     Clear-Host
>     Write-Host "`n╔════════════════════════════╗" -ForegroundColor Cyan
>     Write-Host "║    MENU PRINCIPAL          ║" -ForegroundColor Cyan
>     Write-Host "╚════════════════════════════╝" -ForegroundColor Cyan
>     Write-Host ""
>     Write-Host "  1. " -NoNewline -ForegroundColor White
>     Write-Host "Nouveau projet" -ForegroundColor Green
>     Write-Host "  2. " -NoNewline -ForegroundColor White
>     Write-Host "Ouvrir projet" -ForegroundColor Yellow
>     Write-Host "  3. " -NoNewline -ForegroundColor White
>     Write-Host "Quitter" -ForegroundColor Red
>     Write-Host ""
>     Write-Host "Votre choix : " -NoNewline -ForegroundColor Cyan
> }
> ```

---

## Personnalisation avancée avec $Host.UI.RawUI

Pour un contrôle plus fin des couleurs et de l'apparence de la console, PowerShell offre l'objet `$Host.UI.RawUI` qui permet de modifier les paramètres globaux de la console.

### Structure de $Host.UI.RawUI

```powershell
# Accéder aux propriétés de la console
$console = $Host.UI.RawUI

# Propriétés principales
$console.ForegroundColor  # Couleur de texte par défaut
$console.BackgroundColor  # Couleur de fond par défaut
$console.WindowTitle      # Titre de la fenêtre
$console.CursorSize       # Taille du curseur (1-100)
$console.BufferSize       # Taille du buffer
$console.WindowSize       # Taille de la fenêtre
```

### Modifier les couleurs par défaut

```powershell
# Sauvegarder les couleurs actuelles
$couleurTextOriginale = $Host.UI.RawUI.ForegroundColor
$couleurFondOriginale = $Host.UI.RawUI.BackgroundColor

# Appliquer un nouveau schéma de couleurs
$Host.UI.RawUI.ForegroundColor = "Green"
$Host.UI.RawUI.BackgroundColor = "Black"

Write-Host "Ce texte utilise les nouvelles couleurs par défaut"

# Restaurer les couleurs originales (important !)
$Host.UI.RawUI.ForegroundColor = $couleurTextOriginale
$Host.UI.RawUI.BackgroundColor = $couleurFondOriginale
```

### Personnalisation complète de la console

```powershell
function Set-ConsoleTheme {
    param(
        [string]$Theme = "Default"
    )
    
    switch ($Theme) {
        "Matrix" {
            $Host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.BackgroundColor = "Black"
            $Host.UI.RawUI.WindowTitle = "Matrix Mode"
        }
        "Hacker" {
            $Host.UI.RawUI.ForegroundColor = "Cyan"
            $Host.UI.RawUI.BackgroundColor = "Black"
            $Host.UI.RawUI.WindowTitle = "Hacker Terminal"
        }
        "Minimal" {
            $Host.UI.RawUI.ForegroundColor = "Gray"
            $Host.UI.RawUI.BackgroundColor = "Black"
            $Host.UI.RawUI.WindowTitle = "PowerShell"
        }
        "Classic" {
            $Host.UI.RawUI.ForegroundColor = "White"
            $Host.UI.RawUI.BackgroundColor = "DarkBlue"
            $Host.UI.RawUI.WindowTitle = "Windows PowerShell"
        }
        default {
            # Restaurer les valeurs par défaut
            $Host.UI.RawUI.ForegroundColor = "White"
            $Host.UI.RawUI.BackgroundColor = "Black"
            $Host.UI.RawUI.WindowTitle = "PowerShell"
        }
    }
    
    Clear-Host
    Write-Host "Thème '$Theme' appliqué !" -ForegroundColor Yellow
}

# Utilisation
Set-ConsoleTheme -Theme "Matrix"
```

### Créer une bannière de démarrage personnalisée

```powershell
function Show-StartupBanner {
    # Sauvegarder l'état actuel
    $originalFg = $Host.UI.RawUI.ForegroundColor
    $originalBg = $Host.UI.RawUI.BackgroundColor
    
    # Appliquer le style de la bannière
    $Host.UI.RawUI.ForegroundColor = "Cyan"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    
    Clear-Host
    
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════╗  "
    Write-Host "  ║                                           ║  "
    Write-Host "  ║     SYSTÈME DE GESTION - v2.0             ║  "
    Write-Host "  ║     PowerShell Advanced Script            ║  "
    Write-Host "  ║                                           ║  "
    Write-Host "  ╚═══════════════════════════════════════════╝  "
    Write-Host ""
    
    # Restaurer les couleurs
    $Host.UI.RawUI.ForegroundColor = $originalFg
    $Host.UI.RawUI.BackgroundColor = $originalBg
    
    # Afficher les informations système
    Write-Host "  Utilisateur : " -NoNewline -ForegroundColor Gray
    Write-Host "$env:USERNAME" -ForegroundColor Green
    Write-Host "  Machine     : " -NoNewline -ForegroundColor Gray
    Write-Host "$env:COMPUTERNAME" -ForegroundColor Green
    Write-Host "  Date        : " -NoNewline -ForegroundColor Gray
    Write-Host (Get-Date -Format "dd/MM/yyyy HH:mm") -ForegroundColor Green
    Write-Host ""
}
```

> [!tip] Astuce : Thèmes persistants Pour appliquer un thème à chaque démarrage de PowerShell, ajoutez votre fonction dans le profil PowerShell :
> 
> ```powershell
> # Éditer le profil
> notepad $PROFILE
> 
> # Ajouter dans le fichier :
> Set-ConsoleTheme -Theme "Matrix"
> ```

### Propriétés avancées de RawUI

```powershell
# Modifier le titre de la fenêtre dynamiquement
$Host.UI.RawUI.WindowTitle = "Script en cours : Backup-Database.ps1"

# Modifier la taille du curseur (utile pour les saisies)
$Host.UI.RawUI.CursorSize = 50  # 50% de la hauteur

# Obtenir les dimensions de la console
$largeur = $Host.UI.RawUI.WindowSize.Width
$hauteur = $Host.UI.RawUI.WindowSize.Height

Write-Host "Console : $largeur x $hauteur caractères"

# Exemple : Centrer un texte
function Write-Centered {
    param([string]$Text)
    
    $largeur = $Host.UI.RawUI.WindowSize.Width
    $espacesGauche = [Math]::Floor(($largeur - $Text.Length) / 2)
    $padding = " " * $espacesGauche
    
    Write-Host "$padding$Text"
}

Write-Centered "╔═════════════════╗"
Write-Centered "║  TEXTE CENTRÉ   ║"
Write-Centered "╚═════════════════╝"
```

> [!warning] Limitations de $Host.UI.RawUI
> 
> - Ne fonctionne que dans la console PowerShell native
> - Limité ou non disponible dans PowerShell ISE et certains IDE
> - Les modifications sont temporaires (durée de la session uniquement)
> - Vérifiez toujours la disponibilité : `if ($Host.UI.RawUI) { ... }`

---

## Réinitialisation des couleurs

Il est essentiel de réinitialiser les couleurs après les avoir modifiées pour éviter de perturber l'affichage de la console. Voici les différentes méthodes disponibles.

### Méthode 1 : Sauvegarde et restauration manuelle

```powershell
# Au début du script - Sauvegarder
$originalForeground = $Host.UI.RawUI.ForegroundColor
$originalBackground = $Host.UI.RawUI.BackgroundColor

# Modifications...
$Host.UI.RawUI.ForegroundColor = "Yellow"
$Host.UI.RawUI.BackgroundColor = "DarkBlue"

# Votre code ici...

# À la fin du script - Restaurer
$Host.UI.RawUI.ForegroundColor = $originalForeground
$Host.UI.RawUI.BackgroundColor = $originalBackground
```

### Méthode 2 : Utiliser un bloc try/finally

Cette méthode garantit la restauration même en cas d'erreur.

```powershell
# Sauvegarder les couleurs
$originalFg = $Host.UI.RawUI.ForegroundColor
$originalBg = $Host.UI.RawUI.BackgroundColor

try {
    # Modifier les couleurs
    $Host.UI.RawUI.ForegroundColor = "Cyan"
    $Host.UI.RawUI.BackgroundColor = "Black"
    
    # Votre code qui peut générer des erreurs
    Write-Host "Traitement en cours..."
    # ... opérations diverses ...
    
} finally {
    # Cette section s'exécute TOUJOURS, même en cas d'erreur
    $Host.UI.RawUI.ForegroundColor = $originalFg
    $Host.UI.RawUI.BackgroundColor = $originalBg
    Write-Host "Couleurs restaurées" -ForegroundColor Gray
}
```

### Méthode 3 : Fonction de réinitialisation complète

```powershell
function Reset-ConsoleColors {
    param(
        [switch]$ToDefault,
        [System.ConsoleColor]$ForegroundColor,
        [System.ConsoleColor]$BackgroundColor
    )
    
    if ($ToDefault) {
        # Réinitialiser aux valeurs par défaut de PowerShell
        $Host.UI.RawUI.ForegroundColor = "White"
        $Host.UI.RawUI.BackgroundColor = "Black"
        Write-Host "✓ Couleurs réinitialisées aux valeurs par défaut" -ForegroundColor Green
    }
    elseif ($ForegroundColor -or $BackgroundColor) {
        # Réinitialiser à des couleurs spécifiques
        if ($ForegroundColor) { 
            $Host.UI.RawUI.ForegroundColor = $ForegroundColor 
        }
        if ($BackgroundColor) { 
            $Host.UI.RawUI.BackgroundColor = $BackgroundColor 
        }
        Write-Host "✓ Couleurs personnalisées appliquées" -ForegroundColor Green
    }
    
    Clear-Host
}

# Utilisation
Reset-ConsoleColors -ToDefault
Reset-ConsoleColors -ForegroundColor Gray -BackgroundColor DarkBlue
```

### Méthode 4 : Classe de gestion des couleurs (Approche orientée objet)

```powershell
class ConsoleColorManager {
    [System.ConsoleColor]$OriginalForeground
    [System.ConsoleColor]$OriginalBackground
    [bool]$IsSaved = $false
    
    # Sauvegarder l'état actuel
    [void] Save() {
        $this.OriginalForeground = $Host.UI.RawUI.ForegroundColor
        $this.OriginalBackground = $Host.UI.RawUI.BackgroundColor
        $this.IsSaved = $true
    }
    
    # Restaurer l'état sauvegardé
    [void] Restore() {
        if ($this.IsSaved) {
            $Host.UI.RawUI.ForegroundColor = $this.OriginalForeground
            $Host.UI.RawUI.BackgroundColor = $this.OriginalBackground
        }
    }
    
    # Appliquer temporairement des couleurs
    [void] ApplyTemporary([System.ConsoleColor]$fg, [System.ConsoleColor]$bg) {
        if (-not $this.IsSaved) {
            $this.Save()
        }
        $Host.UI.RawUI.ForegroundColor = $fg
        $Host.UI.RawUI.BackgroundColor = $bg
    }
}

# Utilisation
$colorManager = [ConsoleColorManager]::new()
$colorManager.Save()

# Modifier temporairement
$colorManager.ApplyTemporary("Yellow", "DarkRed")
Write-Host "Message important en couleurs temporaires"

# Restaurer automatiquement
$colorManager.Restore()
Write-Host "Retour aux couleurs originales"
```

### Méthode 5 : Réinitialisation automatique avec Invoke-WithColors

```powershell
function Invoke-WithColors {
    param(
        [ScriptBlock]$ScriptBlock,
        [System.ConsoleColor]$ForegroundColor = "White",
        [System.ConsoleColor]$BackgroundColor = "Black"
    )
    
    # Sauvegarder
    $originalFg = $Host.UI.RawUI.ForegroundColor
    $originalBg = $Host.UI.RawUI.BackgroundColor
    
    try {
        # Appliquer
        $Host.UI.RawUI.ForegroundColor = $ForegroundColor
        $Host.UI.RawUI.BackgroundColor = $BackgroundColor
        
        # Exécuter le code fourni
        & $ScriptBlock
        
    } finally {
        # Restaurer automatiquement
        $Host.UI.RawUI.ForegroundColor = $originalFg
        $Host.UI.RawUI.BackgroundColor = $originalBg
    }
}

# Utilisation élégante
Invoke-WithColors -ForegroundColor Yellow -BackgroundColor DarkBlue {
    Write-Host "╔══════════════════════════╗"
    Write-Host "║   SECTION SPÉCIALE       ║"
    Write-Host "╚══════════════════════════╝"
    Write-Host ""
    Write-Host "Ce contenu s'affiche avec des couleurs spéciales"
    Write-Host "Les couleurs seront automatiquement restaurées"
}

Write-Host "Retour automatique aux couleurs normales" -ForegroundColor Green
```

> [!tip] Astuce : Réinitialisation rapide Pour une réinitialisation rapide pendant le développement :
> 
> ```powershell
> # Créer un alias court
> function rc { Reset-ConsoleColors -ToDefault }
> 
> # Utilisation :
> rc
> ```

> [!warning] Attention aux fermetures brutales Si un script se termine brutalement (Ctrl+C, erreur non gérée), les couleurs peuvent rester modifiées. Utilisez toujours des blocs `try/finally` pour les opérations critiques.

---

## Pièges courants

### 1. Oublier de restaurer les couleurs

```powershell
# ❌ MAUVAIS - Les couleurs restent modifiées
function Show-Error {
    $Host.UI.RawUI.ForegroundColor = "Red"
    Write-Host "Erreur critique !"
    # Oubli de restauration
}

# ✅ BON - Restauration systématique
function Show-Error {
    $originalColor = $Host.UI.RawUI.ForegroundColor
    try {
        $Host.UI.RawUI.ForegroundColor = "Red"
        Write-Host "Erreur critique !"
    } finally {
        $Host.UI.RawUI.ForegroundColor = $originalColor
    }
}
```

### 2. Utiliser Write-Host dans des fonctions retournant des données

```powershell
# ❌ MAUVAIS - Write-Host ne retourne rien
function Get-FileSize {
    param($Path)
    $size = (Get-Item $Path).Length
    Write-Host "Taille : $size octets" -ForegroundColor Green
    return $size  # Fonctionne, mais affichage perturbateur
}

$result = Get-FileSize "C:\test.txt"  # Affiche du texte ET retourne la valeur

# ✅ BON - Séparer affichage et retour de données
function Get-FileSize {
    param($Path, [switch]$Verbose)
    $size = (Get-Item $Path).Length
    
    if ($Verbose) {
        Write-Host "Taille : $size octets" -ForegroundColor Green
    }
    
    return $size
}

$result = Get-FileSize "C:\test.txt" -Verbose
```

### 3. Combiner des couleurs incompatibles

```powershell
# ❌ Illisible - Jaune sur blanc
Write-Host "Message important" -ForegroundColor Yellow -BackgroundColor White

# ✅ BON - Contraste suffisant
Write-Host "Message important" -ForegroundColor Yellow -BackgroundColor Black

# Fonction pour vérifier le contraste
function Test-ColorContrast {
    param(
        [System.ConsoleColor]$Foreground,
        [System.ConsoleColor]$Background
    )
    
    $combinaisonsIllisibles = @(
        @{ Fg = "Yellow"; Bg = "White" }
        @{ Fg = "White"; Bg = "Yellow" }
        @{ Fg = "Gray"; Bg = "White" }
        @{ Fg = "Black"; Bg = "DarkBlue" }
    )
    
    $estIllisible = $combinaisonsIllisibles | Where-Object {
        $_.Fg -eq $Foreground -and $_.Bg -eq $Background
    }
    
    if ($estIllisible) {
        Write-Warning "Combinaison de couleurs potentiellement illisible"
        return $false
    }
    return $true
}
```

### 4. Ne pas vérifier la disponibilité de $Host.UI.RawUI

```powershell
# ❌ MAUVAIS - Peut échouer dans certains environnements
$Host.UI.RawUI.ForegroundColor = "Green"

# ✅ BON - Vérification de disponibilité
if ($Host.UI.RawUI) {
    $Host.UI.RawUI.ForegroundColor = "Green"
} else {
    Write-Warning "Modification des couleurs non disponible dans cet environnement"
}

# Encore mieux : Fonction wrapper
function Set-ConsoleForegroundColor {
    param([System.ConsoleColor]$Color)
    
    if ($Host.Name -eq "ConsoleHost" -and $Host.UI.RawUI) {
        $Host.UI.RawUI.ForegroundColor = $Color
    } else {
        Write-Verbose "Couleurs non supportées : $($Host.Name)"
    }
}
```

### 5. Utiliser trop de couleurs (surcharge visuelle)

```powershell
# ❌ MAUVAIS - Trop de couleurs tue le message
Write-Host "Le " -ForegroundColor Red -NoNewline
Write-Host "fichier " -ForegroundColor Blue -NoNewline
Write-Host "a " -ForegroundColor Green -NoNewline
Write-Host "été " -ForegroundColor Yellow -NoNewline
Write-Host "créé " -ForegroundColor Magenta -NoNewline
Write-Host "avec " -ForegroundColor Cyan -NoNewline
Write-Host "succès" -ForegroundColor Red

# ✅ BON - Couleurs ciblées et cohérentes
Write-Host "Le fichier " -NoNewline -ForegroundColor Gray
Write-Host "config.xml" -NoNewline -ForegroundColor Cyan
Write-Host " a été créé avec succès" -ForegroundColor Green
```

### 6. Couleurs codées en dur dans tout le script

```powershell
# ❌ MAUVAIS - Couleurs dispersées et difficiles à maintenir
Write-Host "Erreur" -ForegroundColor Red
# ... 50 lignes plus loin ...
Write-Host "Autre erreur" -ForegroundColor DarkRed  # Incohérence !
# ... 100 lignes plus loin ...
Write-Host "Encore une erreur" -ForegroundColor Red

# ✅ BON - Centraliser les couleurs
$script:Colors = @{
    Error   = "Red"
    Warning = "Yellow"
    Success = "Green"
    Info    = "Cyan"
    Dim     = "Gray"
}

function Write-ColorMessage {
    param(
        [string]$Message,
        [ValidateSet("Error", "Warning", "Success", "Info", "Dim")]
        [string]$Type = "Info"
    )
    
    Write-Host $Message -ForegroundColor $script:Colors[$Type]
}

# Utilisation cohérente
Write-ColorMessage "Erreur de connexion" -Type Error
Write-ColorMessage "Fichier sauvegardé" -Type Success
Write-ColorMessage "Vérification en cours..." -Type Info
```

---

## Bonnes pratiques

### 1. Créer un système de couleurs cohérent

```powershell
# Définir une palette de couleurs au début du script
$script:Theme = @{
    # Messages système
    Error       = @{ Fg = "Red"; Bg = "Black" }
    Warning     = @{ Fg = "Yellow"; Bg = "Black" }
    Success     = @{ Fg = "Green"; Bg = "Black" }
    Info        = @{ Fg = "Cyan"; Bg = "Black" }
    
    # Éléments d'interface
    Title       = @{ Fg = "White"; Bg = "DarkBlue" }
    Header      = @{ Fg = "Cyan"; Bg = "Black" }
    Prompt      = @{ Fg = "White"; Bg = "Black" }
    Highlight   = @{ Fg = "Yellow"; Bg = "Black" }
    Dim         = @{ Fg = "Gray"; Bg = "Black" }
}

# Fonction utilitaire pour appliquer le thème
function Write-ThemedMessage {
    param(
        [string]$Message,
        [ValidateSet("Error", "Warning", "Success", "Info", "Title", "Header", "Prompt", "Highlight", "Dim")]
        [string]$Style,
        [switch]$NoNewline
    )
    
    $colors = $script:Theme[$Style]
    
    $params = @{
        Object          = $Message
        ForegroundColor = $colors.Fg
        BackgroundColor = $colors.Bg
        NoNewline       = $NoNewline
    }
    
    Write-Host @params
}
```

### 2. Utiliser des fonctions wrapper pour la cohérence

```powershell
# Créer des fonctions métier avec couleurs intégrées
function Write-SectionHeader {
    param([string]$Title)
    
    Write-Host "`n" # Ligne vide
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor White
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host ""
}

function Write-Progress {
    param(
        [string]$Activity,
        [int]$PercentComplete
    )
    
    $barLength = 40
    $completed = [Math]::Floor($barLength * $PercentComplete / 100)
    $remaining = $barLength - $completed
    
    Write-Host "`r" -NoNewline
    Write-Host "$Activity : [" -NoNewline -ForegroundColor White
    Write-Host ("█" * $completed) -NoNewline -ForegroundColor Green
    Write-Host ("░" * $remaining) -NoNewline -ForegroundColor DarkGray
    Write-Host "] $PercentComplete%" -NoNewline -ForegroundColor White
}

function Write-Step {
    param(
        [string]$Message,
        [switch]$Success,
        [switch]$Failed
    )
    
    if ($Success) {
        Write-Host "  ✓ " -NoNewline -ForegroundColor Green
        Write-Host $Message -ForegroundColor White
    }
    elseif ($Failed) {
        Write-Host "  ✗ " -NoNewline -ForegroundColor Red
        Write-Host $Message -ForegroundColor White
    }
    else {
        Write-Host "  ● " -NoNewline -ForegroundColor Cyan
        Write-Host $Message -ForegroundColor White
    }
}

# Exemple d'utilisation
Write-SectionHeader "Installation des modules"
Write-Step "Vérification des prérequis"
Write-Step "Module A installé" -Success
Write-Step "Module B échoué" -Failed
Write-Progress -Activity "Téléchargement" -PercentComplete 75
```

### 3. Gérer les environnements différents

```powershell
# Fonction pour détecter les capacités de l'environnement
function Get-ConsoleCapabilities {
    $capabilities = @{
        SupportsColors = $false
        SupportsRawUI  = $false
        HostName       = $Host.Name
        IsInteractive  = $Host.UI.SupportsVirtualTerminal
    }
    
    # Vérifier le support des couleurs
    if ($Host.UI -and $Host.UI.SupportsVirtualTerminal) {
        $capabilities.SupportsColors = $true
    }
    
    # Vérifier RawUI
    if ($Host.UI.RawUI) {
        $capabilities.SupportsRawUI = $true
    }
    
    return $capabilities
}

# Adapter le comportement selon l'environnement
$consoleCapabilities = Get-ConsoleCapabilities

function Write-AdaptiveMessage {
    param(
        [string]$Message,
        [System.ConsoleColor]$Color = "White"
    )
    
    if ($consoleCapabilities.SupportsColors) {
        Write-Host $Message -ForegroundColor $Color
    } else {
        Write-Output $Message  # Fallback sans couleurs
    }
}
```

### 4. Utiliser des templates pour les interfaces récurrentes

```powershell
# Template de boîte de dialogue
function Show-Dialog {
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Type = "Info"
    )
    
    # Définir les couleurs selon le type
    $typeColors = @{
        Info    = @{ Border = "Cyan"; Icon = "ℹ" }
        Warning = @{ Border = "Yellow"; Icon = "⚠" }
        Error   = @{ Border = "Red"; Icon = "✗" }
        Success = @{ Border = "Green"; Icon = "✓" }
    }
    
    $config = $typeColors[$Type]
    $width = 60
    
    # Afficher la boîte
    Write-Host ""
    Write-Host ("╔" + ("═" * ($width - 2)) + "╗") -ForegroundColor $config.Border
    
    # Titre centré
    $titlePadding = [Math]::Floor(($width - $Title.Length - 4) / 2)
    $titleLine = "║" + (" " * $titlePadding) + " $($config.Icon) $Title " + (" " * $titlePadding)
    if ($titleLine.Length -lt $width) {
        $titleLine += " " * ($width - $titleLine.Length - 1)
    }
    $titleLine += "║"
    Write-Host $titleLine -ForegroundColor $config.Border
    
    Write-Host ("╠" + ("═" * ($width - 2)) + "╣") -ForegroundColor $config.Border
    
    # Message (multi-lignes si nécessaire)
    $maxLineLength = $width - 6
    $words = $Message -split " "
    $currentLine = ""
    
    foreach ($word in $words) {
        if (($currentLine + $word).Length -le $maxLineLength) {
            $currentLine += "$word "
        } else {
            $paddedLine = "║  " + $currentLine.PadRight($maxLineLength) + "  ║"
            Write-Host $paddedLine -ForegroundColor $config.Border
            $currentLine = "$word "
        }
    }
    
    if ($currentLine.Trim()) {
        $paddedLine = "║  " + $currentLine.TrimEnd().PadRight($maxLineLength) + "  ║"
        Write-Host $paddedLine -ForegroundColor $config.Border
    }
    
    Write-Host ("╚" + ("═" * ($width - 2)) + "╝") -ForegroundColor $config.Border
    Write-Host ""
}

# Exemples d'utilisation
Show-Dialog -Title "Connexion réussie" -Message "Vous êtes maintenant connecté au serveur de production." -Type Success
Show-Dialog -Title "Attention" -Message "Cette action supprimera définitivement tous les fichiers. Êtes-vous certain de vouloir continuer ?" -Type Warning
Show-Dialog -Title "Erreur réseau" -Message "Impossible de se connecter au serveur. Vérifiez votre connexion internet." -Type Error
```

### 5. Documenter vos choix de couleurs

```powershell
<#
.SYNOPSIS
    Système de gestion avec interface colorée
    
.DESCRIPTION
    Ce script utilise un schéma de couleurs cohérent :
    
    COULEURS SYSTÈME :
    - Rouge (Red)      : Erreurs critiques, échecs d'opérations
    - Jaune (Yellow)   : Avertissements, actions nécessitant attention
    - Vert (Green)     : Succès, validations, confirmations
    - Cyan (Cyan)      : Informations générales, en-têtes
    - Gris (Gray)      : Texte secondaire, détails
    
    COULEURS INTERFACE :
    - Blanc (White)    : Texte principal, prompts utilisateur
    - Bleu foncé (DarkBlue) : Arrière-plans de titres
    - Magenta (Magenta): Éléments de débogage (si -Verbose)
    
.NOTES
    Testé sur : PowerShell 5.1, PowerShell 7.x
    Compatible : Console Windows, Windows Terminal, VS Code (partiellement)
#>
```

### 6. Prévoir des modes alternatifs (mode silencieux, mode verbose)

```powershell
param(
    [switch]$NoColor,      # Désactiver les couleurs
    [switch]$Verbose,      # Mode verbeux avec plus de détails
    [switch]$Quiet         # Mode silencieux
)

# Configuration globale
$script:Config = @{
    UseColors  = -not $NoColor
    IsVerbose  = $Verbose.IsPresent
    IsQuiet    = $Quiet.IsPresent
}

# Fonction d'affichage intelligente
function Write-SmartMessage {
    param(
        [string]$Message,
        [ValidateSet("Error", "Warning", "Success", "Info", "Verbose")]
        [string]$Level = "Info",
        [System.ConsoleColor]$Color = "White"
    )
    
    # Mode silencieux : n'afficher que les erreurs
    if ($script:Config.IsQuiet -and $Level -ne "Error") {
        return
    }
    
    # Mode verbose : afficher tout
    if ($Level -eq "Verbose" -and -not $script:Config.IsVerbose) {
        return
    }
    
    # Afficher avec ou sans couleurs
    if ($script:Config.UseColors) {
        $levelColors = @{
            Error   = "Red"
            Warning = "Yellow"
            Success = "Green"
            Info    = "Cyan"
            Verbose = "Magenta"
        }
        Write-Host $Message -ForegroundColor $levelColors[$Level]
    } else {
        Write-Output "[$Level] $Message"
    }
}

# Utilisation
Write-SmartMessage "Démarrage du script..." -Level Info
Write-SmartMessage "Connexion à la base de données..." -Level Verbose
Write-SmartMessage "Fichier créé avec succès" -Level Success
Write-SmartMessage "Espace disque faible" -Level Warning
Write-SmartMessage "Échec de l'opération" -Level Error
```

### 7. Créer une barre de progression réaliste et élégante

```powershell
function Show-ProgressBar {
    param(
        [string]$Activity,
        [int]$Current,
        [int]$Total,
        [int]$BarLength = 50
    )
    
    $percent = [Math]::Round(($Current / $Total) * 100)
    $completed = [Math]::Floor($BarLength * $Current / $Total)
    $remaining = $BarLength - $completed
    
    # Choisir la couleur selon le pourcentage
    $barColor = switch ($percent) {
        { $_ -lt 33 } { "Red" }
        { $_ -lt 66 } { "Yellow" }
        default { "Green" }
    }
    
    # Construire la barre
    Write-Host "`r" -NoNewline
    Write-Host "$Activity : [" -NoNewline -ForegroundColor White
    Write-Host ("█" * $completed) -NoNewline -ForegroundColor $barColor
    Write-Host ("─" * $remaining) -NoNewline -ForegroundColor DarkGray
    Write-Host "] " -NoNewline -ForegroundColor White
    Write-Host "$Current/$Total " -NoNewline -ForegroundColor Cyan
    Write-Host "($percent%)" -NoNewline -ForegroundColor White
}

# Exemple d'utilisation
for ($i = 1; $i -le 100; $i++) {
    Show-ProgressBar -Activity "Traitement des fichiers" -Current $i -Total 100
    Start-Sleep -Milliseconds 50
}
Write-Host "`n✓ Terminé !" -ForegroundColor Green
```

### 8. Tester votre palette avant déploiement

```powershell
function Test-ColorPalette {
    param([hashtable]$Theme)
    
    Write-Host "`n=== TEST DE LA PALETTE DE COULEURS ===" -ForegroundColor White
    Write-Host ""
    
    foreach ($style in $Theme.Keys) {
        $colors = $Theme[$style]
        
        Write-Host "Style : " -NoNewline -ForegroundColor White
        Write-Host $style.PadRight(15) -NoNewline -ForegroundColor Gray
        Write-Host "│ " -NoNewline
        
        Write-Host " Exemple de texte " -ForegroundColor $colors.Fg -BackgroundColor $colors.Bg
    }
    
    Write-Host ""
    Write-Host "Vérifiez la lisibilité de chaque combinaison" -ForegroundColor Yellow
    Write-Host ""
}

# Tester votre thème
Test-ColorPalette -Theme $script:Theme
```

> [!example] Exemple complet : Script avec bonnes pratiques
> 
> ```powershell
> <#
> .SYNOPSIS
>     Script de sauvegarde avec interface colorée professionnelle
> #>
> 
> param(
>     [string]$Source = "C:\Data",
>     [string]$Destination = "D:\Backup",
>     [switch]$NoColor
> )
> 
> # ========== CONFIGURATION DES COULEURS ==========
> $script:UseColors = -not $NoColor
> 
> $script:Theme = @{
>     Error   = "Red"
>     Warning = "Yellow"
>     Success = "Green"
>     Info    = "Cyan"
>     Dim     = "Gray"
> }
> 
> # ========== FONCTIONS UTILITAIRES ==========
> function Write-ColorMessage {
>     param(
>         [string]$Message,
>         [string]$Type = "Info"
>     )
>     
>     if ($script:UseColors) {
>         Write-Host $Message -ForegroundColor $script:Theme[$Type]
>     } else {
>         Write-Output "[$Type] $Message"
>     }
> }
> 
> function Write-Header {
>     param([string]$Title)
>     
>     $line = "=" * 60
>     Write-ColorMessage "`n$line" -Type Info
>     Write-ColorMessage "  $Title" -Type Info
>     Write-ColorMessage "$line`n" -Type Info
> }
> 
> # ========== SCRIPT PRINCIPAL ==========
> try {
>     Write-Header "SAUVEGARDE DE FICHIERS"
>     
>     Write-ColorMessage "Source      : $Source" -Type Dim
>     Write-ColorMessage "Destination : $Destination" -Type Dim
>     Write-Host ""
>     
>     # Vérifications
>     if (-not (Test-Path $Source)) {
>         Write-ColorMessage "✗ Le répertoire source n'existe pas" -Type Error
>         exit 1
>     }
>     
>     Write-ColorMessage "✓ Vérifications réussies" -Type Success
>     
>     # Traitement
>     Write-ColorMessage "⏳ Copie en cours..." -Type Info
>     Copy-Item -Path $Source -Destination $Destination -Recurse -Force
>     
>     Write-ColorMessage "`n✓ Sauvegarde terminée avec succès !" -Type Success
>     
> } catch {
>     Write-ColorMessage "`n✗ Erreur : $($_.Exception.Message)" -Type Error
>     exit 1
> }
> ```

> [!tip] Astuce finale : Profil PowerShell personnalisé Créez des alias et fonctions dans votre profil pour un usage quotidien :
> 
> ```powershell
> # Éditer le profil
> notepad $PROFILE
> 
> # Ajouter vos fonctions favorites
> function success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
> function error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
> function info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Cyan }
> function warn { param($msg) Write-Host "⚠ $msg" -ForegroundColor Yellow }
> 
> # Utilisation rapide
> success "Connexion établie"
> error "Fichier introuvable"
> info "Traitement en cours"
> warn "Certificat expiré"
> ```

---

## 🎯 Récapitulatif

### Points clés à retenir

1. **Write-Host** est l'outil principal pour afficher du texte coloré avec `-ForegroundColor` et `-BackgroundColor`
    
2. **Les 16 couleurs standard** offrent une palette suffisante pour la plupart des besoins
    
3. **$Host.UI.RawUI** permet une personnalisation avancée mais nécessite des précautions (sauvegarde/restauration)
    
4. **Toujours restaurer** les couleurs d'origine pour éviter de polluer l'environnement
    
5. **Utiliser des fonctions wrapper** pour maintenir la cohérence et faciliter la maintenance
    
6. **Tester la compatibilité** avec différents environnements (PowerShell ISE, VS Code, Windows Terminal)
    
7. **Privilégier la lisibilité** : moins de couleurs mais bien choisies vaut mieux qu'un arc-en-ciel illisible
    

### Checklist avant déploiement

- [ ] Les couleurs sont-elles cohérentes dans tout le script ?
- [ ] Les modifications de $Host.UI.RawUI sont-elles restaurées ?
- [ ] Le script fonctionne-t-il sans couleurs (mode `-NoColor`) ?
- [ ] Les combinaisons de couleurs sont-elles lisibles ?
- [ ] Le script gère-t-il les environnements non compatibles ?
- [ ] Les fonctions de couleur sont-elles documentées ?
- [ ] Un système de logging est-il en place pour les erreurs ?

---

> [!success] Félicitations ! Vous maîtrisez maintenant la gestion des couleurs en PowerShell. Vous pouvez créer des scripts professionnels avec une interface utilisateur claire et agréable.