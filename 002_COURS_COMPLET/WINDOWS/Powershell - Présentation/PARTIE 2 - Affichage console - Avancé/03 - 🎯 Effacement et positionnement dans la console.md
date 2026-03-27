

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

## 🧹 Clear-Host

### Concept et utilité

`Clear-Host` est la commande native PowerShell pour effacer complètement le contenu de la console. Elle réinitialise l'affichage et repositionne le curseur en haut à gauche.

> [!info] Alias courants
> 
> - `cls` (style DOS/CMD)
> - `clear` (style Unix/Linux)
> 
> Tous ces alias pointent vers `Clear-Host`.

### Pourquoi l'utiliser ?

- **Améliorer la lisibilité** : Nettoyer l'écran avant d'afficher de nouvelles informations importantes
- **Créer des interfaces utilisateur** : Rafraîchir l'affichage dans des menus interactifs
- **Séparer visuellement** : Marquer le début d'une nouvelle étape dans un script
- **Réduire l'encombrement visuel** : Éviter que l'utilisateur soit distrait par des informations obsolètes

### Syntaxe et utilisation

```powershell
# Méthode standard
Clear-Host

# Avec les alias
cls
clear

# Effacement avant affichage d'un titre
Clear-Host
Write-Host "═══════════════════════════════" -ForegroundColor Cyan
Write-Host "    SCRIPT DE MAINTENANCE" -ForegroundColor Yellow
Write-Host "═══════════════════════════════" -ForegroundColor Cyan
```

### Exemple pratique : Menu avec effacement

```powershell
function Show-Menu {
    Clear-Host
    Write-Host "`n╔════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     MENU PRINCIPAL         ║" -ForegroundColor Cyan
    Write-Host "╠════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║  1. Option A               ║" -ForegroundColor White
    Write-Host "║  2. Option B               ║" -ForegroundColor White
    Write-Host "║  3. Quitter                ║" -ForegroundColor White
    Write-Host "╚════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# À chaque itération, l'écran est nettoyé
do {
    Show-Menu
    $choix = Read-Host "Votre choix"
} while ($choix -ne "3")
```

> [!warning] Comportement dans l'ISE Dans PowerShell ISE, `Clear-Host` efface uniquement la sortie visible, pas l'historique. Le comportement diffère légèrement de la console standard.

> [!tip] Astuce professionnelle Évitez d'abuser de `Clear-Host` dans les scripts automatisés ou les logs. L'effacement systématique peut masquer des informations importantes pour le débogage.

---

## 🎯 Positionnement du curseur

### Concept fondamental

Le positionnement du curseur permet de placer le texte à des coordonnées précises (X, Y) dans la console, créant ainsi des interfaces structurées sans effacer tout l'écran.

> [!info] Système de coordonnées
> 
> - **X (Left)** : Position horizontale, commence à 0 (gauche)
> - **Y (Top)** : Position verticale, commence à 0 (haut)
> - L'origine (0, 0) est le coin supérieur gauche

### Pourquoi utiliser le positionnement ?

- **Mise à jour dynamique** : Actualiser une partie spécifique de l'écran sans tout redessiner
- **Tableaux de bord** : Créer des dashboards avec sections fixes
- **Animations** : Déplacer des éléments à l'écran
- **Formulaires** : Positionner des champs de saisie de manière précise

### Syntaxe détaillée

```powershell
# Méthode principale
[Console]::SetCursorPosition(X, Y)

# Exemples de positionnement
[Console]::SetCursorPosition(0, 0)     # Coin supérieur gauche
[Console]::SetCursorPosition(10, 5)    # Colonne 10, ligne 5
[Console]::SetCursorPosition(0, 10)    # Début de la ligne 10

# Récupération de la position actuelle
$posX = [Console]::CursorLeft
$posY = [Console]::CursorTop
```

### Exemple : Affichage structuré

```powershell
# Création d'un tableau de bord simple
Clear-Host

# En-tête fixe
[Console]::SetCursorPosition(0, 0)
Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Cyan
[Console]::SetCursorPosition(0, 1)
Write-Host "║        MONITORING SYSTÈME             ║" -ForegroundColor Cyan
[Console]::SetCursorPosition(0, 2)
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan

# Informations positionnées
[Console]::SetCursorPosition(2, 4)
Write-Host "CPU:" -ForegroundColor Yellow -NoNewline
[Console]::SetCursorPosition(15, 4)
Write-Host "45%" -ForegroundColor Green

[Console]::SetCursorPosition(2, 5)
Write-Host "Mémoire:" -ForegroundColor Yellow -NoNewline
[Console]::SetCursorPosition(15, 5)
Write-Host "72%" -ForegroundColor Yellow

[Console]::SetCursorPosition(2, 6)
Write-Host "Disque:" -ForegroundColor Yellow -NoNewline
[Console]::SetCursorPosition(15, 6)
Write-Host "23%" -ForegroundColor Green

# Repositionner le curseur pour la suite
[Console]::SetCursorPosition(0, 10)
```

### Exemple avancé : Mise à jour dynamique

```powershell
# Compteur qui se met à jour au même endroit
Clear-Host
Write-Host "Progression du traitement :" -ForegroundColor Cyan

$posX = 0
$posY = 2

for ($i = 1; $i -le 100; $i++) {
    # Positionner le curseur pour la mise à jour
    [Console]::SetCursorPosition($posX, $posY)
    
    # Effacer la ligne avec des espaces puis réécrire
    Write-Host (" " * 50) -NoNewline
    [Console]::SetCursorPosition($posX, $posY)
    
    # Afficher le nouveau pourcentage
    Write-Host "$i% " -NoNewline -ForegroundColor Green
    Write-Host ("█" * ($i / 2)) -NoNewline -ForegroundColor Green
    
    Start-Sleep -Milliseconds 50
}

[Console]::SetCursorPosition(0, 4)
Write-Host "`nTerminé !" -ForegroundColor Green
```

> [!warning] Limites de la fenêtre console Les coordonnées ne peuvent pas dépasser les dimensions actuelles de la console. Vérifiez les limites avec :
> 
> ```powershell
> $largeur = [Console]::WindowWidth
> $hauteur = [Console]::WindowHeight
> ```

> [!tip] Astuce : Centrage de texte
> 
> ```powershell
> function Write-Centered {
>     param([string]$Text)
>     $x = ([Console]::WindowWidth - $Text.Length) / 2
>     [Console]::SetCursorPosition($x, [Console]::CursorTop)
>     Write-Host $Text
> }
> ```

---

## 🗑️ Effacement de lignes spécifiques

### Concept et utilité

L'effacement de lignes spécifiques permet de supprimer ou remplacer du contenu à un endroit précis sans tout réinitialiser. C'est essentiel pour les mises à jour partielles d'interface.

> [!info] Principe de fonctionnement PowerShell ne possède pas de commande native pour effacer une ligne. On utilise donc le positionnement du curseur combiné à l'écriture d'espaces pour "effacer" visuellement.

### Pourquoi effacer des lignes spécifiques ?

- **Performance** : Plus rapide que de tout redessiner
- **Expérience utilisateur** : Évite les clignotements et scintillements
- **Préservation du contexte** : Garder les informations statiques visibles
- **Mise à jour ciblée** : Actualiser uniquement les données changeantes

### Technique d'effacement

```powershell
# Méthode 1 : Effacement simple avec espaces
function Clear-Line {
    param(
        [int]$LineNumber,
        [int]$StartColumn = 0
    )
    
    # Positionner le curseur
    [Console]::SetCursorPosition($StartColumn, $LineNumber)
    
    # Écrire des espaces sur toute la largeur
    $espaces = " " * ([Console]::WindowWidth - $StartColumn)
    Write-Host $espaces -NoNewline
    
    # Repositionner le curseur au début de la ligne
    [Console]::SetCursorPosition($StartColumn, $LineNumber)
}

# Utilisation
Clear-Line -LineNumber 5
```

```powershell
# Méthode 2 : Effacement avec longueur spécifique
function Clear-LineSegment {
    param(
        [int]$X,
        [int]$Y,
        [int]$Length = 50
    )
    
    [Console]::SetCursorPosition($X, $Y)
    Write-Host (" " * $Length) -NoNewline
    [Console]::SetCursorPosition($X, $Y)
}

# Utilisation pour effacer 30 caractères à partir de la colonne 10, ligne 3
Clear-LineSegment -X 10 -Y 3 -Length 30
```

### Exemple pratique : Horloge mise à jour

```powershell
function Show-LiveClock {
    param([int]$DurationSeconds = 30)
    
    Clear-Host
    Write-Host "╔════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    HORLOGE EN DIRECT   ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    $clockLine = 4
    $startTime = Get-Date
    
    while (((Get-Date) - $startTime).TotalSeconds -lt $DurationSeconds) {
        # Effacer la ligne de l'horloge
        [Console]::SetCursorPosition(0, $clockLine)
        Write-Host (" " * 50) -NoNewline
        
        # Afficher l'heure actuelle
        [Console]::SetCursorPosition(5, $clockLine)
        $temps = Get-Date -Format "HH:mm:ss"
        Write-Host "🕐 $temps" -ForegroundColor Green -NoNewline
        
        Start-Sleep -Seconds 1
    }
    
    [Console]::SetCursorPosition(0, 6)
    Write-Host "`nHorloge arrêtée." -ForegroundColor Yellow
}

# Lancer l'horloge pendant 30 secondes
Show-LiveClock -DurationSeconds 30
```

### Exemple : Effacement multiple pour un tableau

```powershell
function Update-StatusBoard {
    param(
        [int]$StartLine = 5,
        [hashtable]$Statuts
    )
    
    $ligne = $StartLine
    
    foreach ($service in $Statuts.Keys) {
        # Effacer la ligne existante
        [Console]::SetCursorPosition(0, $ligne)
        Write-Host (" " * 60) -NoNewline
        
        # Réécrire avec les nouvelles données
        [Console]::SetCursorPosition(2, $ligne)
        Write-Host "$service :" -ForegroundColor Cyan -NoNewline
        
        [Console]::SetCursorPosition(25, $ligne)
        $couleur = if ($Statuts[$service] -eq "OK") { "Green" } else { "Red" }
        Write-Host $Statuts[$service] -ForegroundColor $couleur
        
        $ligne++
    }
}

# Exemple d'utilisation
Clear-Host
Write-Host "═══ STATUT DES SERVICES ═══`n" -ForegroundColor Yellow

$statuts = @{
    "Service Web"      = "OK"
    "Base de données"  = "OK"
    "Service Mail"     = "ERREUR"
    "API REST"         = "OK"
}

Update-StatusBoard -StartLine 3 -Statuts $statuts

Start-Sleep -Seconds 2

# Mise à jour après réparation
$statuts["Service Mail"] = "OK"
Update-StatusBoard -StartLine 3 -Statuts $statuts
```

> [!warning] Attention aux caractères spéciaux Les emojis et caractères Unicode peuvent occuper plus d'une colonne. Cela peut décaler votre positionnement. Testez toujours avec les vrais contenus.

> [!tip] Fonction utilitaire réutilisable Créez une fonction générique dans votre profil PowerShell :
> 
> ```powershell
> function Clear-ConsoleLine {
>     param([int]$Line, [int]$Start = 0, [int]$Length = $null)
>     if ($null -eq $Length) { $Length = [Console]::WindowWidth - $Start }
>     [Console]::SetCursorPosition($Start, $Line)
>     Write-Host (" " * $Length) -NoNewline
>     [Console]::SetCursorPosition($Start, $Line)
> }
> ```

---

## 💾 Sauvegarde et restauration de position

### Concept fondamental

La sauvegarde et restauration de position du curseur permet d'effectuer des opérations d'affichage à différents endroits de l'écran, puis de revenir exactement au point de départ.

> [!info] Utilité principale Cette technique est cruciale pour créer des interfaces complexes où plusieurs zones doivent être mises à jour indépendamment sans perdre la position courante.

### Pourquoi sauvegarder la position ?

- **Interfaces multi-zones** : Mettre à jour un statut en haut tout en continuant l'affichage en bas
- **Logs avec en-tête fixe** : Ajouter des logs tout en maintenant un titre actualisé
- **Gestion d'événements** : Afficher une notification temporaire puis reprendre l'affichage normal
- **Débogage** : Afficher des valeurs de debug sans perturber le flux principal

### Techniques de sauvegarde

```powershell
# Méthode 1 : Variables simples
$savedX = [Console]::CursorLeft
$savedY = [Console]::CursorTop

# ... opérations diverses ...

# Restauration
[Console]::SetCursorPosition($savedX, $savedY)
```

```powershell
# Méthode 2 : Objet PSCustomObject
$savedPosition = [PSCustomObject]@{
    X = [Console]::CursorLeft
    Y = [Console]::CursorTop
}

# Restauration
[Console]::SetCursorPosition($savedPosition.X, $savedPosition.Y)
```

```powershell
# Méthode 3 : Fonctions réutilisables
function Save-CursorPosition {
    return @{
        Left = [Console]::CursorLeft
        Top = [Console]::CursorTop
    }
}

function Restore-CursorPosition {
    param([hashtable]$Position)
    [Console]::SetCursorPosition($Position.Left, $Position.Top)
}

# Utilisation
$pos = Save-CursorPosition
# ... opérations ...
Restore-CursorPosition -Position $pos
```

### Exemple pratique : Notification temporaire

```powershell
function Show-TemporaryNotification {
    param(
        [string]$Message,
        [int]$Line = 0,
        [int]$DurationSeconds = 3,
        [ConsoleColor]$Color = "Yellow"
    )
    
    # Sauvegarder la position actuelle
    $savedX = [Console]::CursorLeft
    $savedY = [Console]::CursorTop
    
    # Afficher la notification
    [Console]::SetCursorPosition(0, $Line)
    Write-Host (" " * [Console]::WindowWidth) -NoNewline  # Effacer la ligne
    [Console]::SetCursorPosition(0, $Line)
    Write-Host "⚠ $Message" -ForegroundColor $Color -NoNewline
    
    # Restaurer immédiatement pour ne pas bloquer le script
    [Console]::SetCursorPosition($savedX, $savedY)
    
    # Effacer la notification après un délai (en arrière-plan logique)
    Start-Sleep -Seconds $DurationSeconds
    
    $currentX = [Console]::CursorLeft
    $currentY = [Console]::CursorTop
    
    [Console]::SetCursorPosition(0, $Line)
    Write-Host (" " * [Console]::WindowWidth) -NoNewline
    [Console]::SetCursorPosition($currentX, $currentY)
}

# Exemple d'utilisation
Clear-Host
Write-Host "Traitement en cours..." -ForegroundColor Cyan
Write-Host "Ligne 1"
Write-Host "Ligne 2"
Show-TemporaryNotification -Message "Connexion établie !" -Line 0 -DurationSeconds 2
Write-Host "Ligne 3"
Write-Host "Ligne 4"
```

### Exemple avancé : Dashboard avec zones indépendantes

```powershell
function Show-MultiZoneDashboard {
    Clear-Host
    
    # Zone d'en-tête (lignes 0-2)
    [Console]::SetCursorPosition(0, 0)
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    [Console]::SetCursorPosition(0, 1)
    Write-Host "║       DASHBOARD MULTI-ZONES            ║" -ForegroundColor Cyan
    [Console]::SetCursorPosition(0, 2)
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    
    # Zone de statut (ligne 4)
    $statusLine = 4
    
    # Zone de logs (à partir de la ligne 6)
    $logStartLine = 6
    [Console]::SetCursorPosition(0, $logStartLine)
    Write-Host "--- Logs ---" -ForegroundColor Yellow
    
    # Simulation de traitement
    for ($i = 1; $i -le 10; $i++) {
        # Sauvegarder la position courante (dans les logs)
        $logX = [Console]::CursorLeft
        $logY = [Console]::CursorTop
        
        # Mettre à jour le statut en haut
        [Console]::SetCursorPosition(0, $statusLine)
        Write-Host (" " * 50) -NoNewline
        [Console]::SetCursorPosition(0, $statusLine)
        Write-Host "Status: Traitement $i/10 " -ForegroundColor Green -NoNewline
        $pourcentage = ($i / 10) * 100
        Write-Host "($pourcentage%)" -ForegroundColor Cyan
        
        # Restaurer la position dans les logs
        [Console]::SetCursorPosition($logX, $logY)
        
        # Ajouter une ligne de log
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Étape $i terminée" -ForegroundColor Gray
        
        Start-Sleep -Milliseconds 500
    }
    
    # Message final dans la zone de statut
    [Console]::SetCursorPosition(0, $statusLine)
    Write-Host (" " * 50) -NoNewline
    [Console]::SetCursorPosition(0, $statusLine)
    Write-Host "Status: ✓ Traitement terminé" -ForegroundColor Green
    
    # Positionner le curseur à la fin
    [Console]::SetCursorPosition(0, [Console]::CursorTop + 2)
}

Show-MultiZoneDashboard
```

### Exemple : Stack de positions (pour imbrication)

```powershell
# Gestion d'une pile de positions pour restaurations multiples
$script:CursorStack = New-Object System.Collections.Stack

function Push-CursorPosition {
    $position = @{
        Left = [Console]::CursorLeft
        Top = [Console]::CursorTop
    }
    $script:CursorStack.Push($position)
}

function Pop-CursorPosition {
    if ($script:CursorStack.Count -gt 0) {
        $position = $script:CursorStack.Pop()
        [Console]::SetCursorPosition($position.Left, $position.Top)
        return $true
    }
    return $false
}

# Exemple d'utilisation avec imbrication
Clear-Host
Write-Host "Début du traitement"

Push-CursorPosition  # Sauvegarde position 1
[Console]::SetCursorPosition(0, 5)
Write-Host "Information temporaire ligne 5" -ForegroundColor Yellow

Push-CursorPosition  # Sauvegarde position 2
[Console]::SetCursorPosition(0, 10)
Write-Host "Information temporaire ligne 10" -ForegroundColor Cyan

Pop-CursorPosition   # Retour à la position 2 (ligne 5)
Write-Host " [Mis à jour]" -ForegroundColor Green -NoNewline

Pop-CursorPosition   # Retour à la position 1 (position initiale)
Write-Host "`nFin du traitement"
```

> [!warning] Gestion des erreurs Toujours vérifier que les coordonnées sont dans les limites de la console :
> 
> ```powershell
> function Safe-SetCursorPosition {
>     param([int]$X, [int]$Y)
>     $maxX = [Console]::WindowWidth - 1
>     $maxY = [Console]::WindowHeight - 1
>     $safeX = [Math]::Max(0, [Math]::Min($X, $maxX))
>     $safeY = [Math]::Max(0, [Math]::Min($Y, $maxY))
>     [Console]::SetCursorPosition($safeX, $safeY)
> }
> ```

> [!tip] Astuce : Wrapper de sauvegarde automatique
> 
> ```powershell
> function Invoke-WithSavedPosition {
>     param([scriptblock]$ScriptBlock)
>     $x = [Console]::CursorLeft
>     $y = [Console]::CursorTop
>     try {
>         & $ScriptBlock
>     } finally {
>         [Console]::SetCursorPosition($x, $y)
>     }
> }
> 
> # Usage
> Invoke-WithSavedPosition {
>     [Console]::SetCursorPosition(0, 0)
>     Write-Host "Message temporaire" -ForegroundColor Red
>     Start-Sleep -Seconds 1
> }
> # Le curseur revient automatiquement
> ```

---

## 🎓 Pièges courants et bonnes pratiques

### ⚠️ Pièges à éviter

|Piège|Problème|Solution|
|---|---|---|
|**Coordonnées hors limites**|Erreur si X/Y dépassent la taille de la fenêtre|Vérifier avec `WindowWidth` et `WindowHeight`|
|**Redimensionnement console**|Les positions deviennent invalides|Recalculer ou utiliser des positions relatives|
|**Caractères Unicode**|Décalage de colonnes imprévu|Compter les caractères réels et tester|
|**Clignotement excessif**|`Clear-Host` trop fréquent|Utiliser l'effacement ciblé à la place|
|**Oubli de `-NoNewline`**|Saut de ligne non désiré|Toujours utiliser `-NoNewline` pour positionnement précis|

### ✅ Bonnes pratiques

> [!tip] Recommandations professionnelles
> 
> 1. **Toujours sauvegarder** avant d'écrire à des positions arbitraires
> 2. **Centraliser les coordonnées** : Utiliser des variables pour les zones fixes
> 3. **Tester sur différentes tailles** de fenêtre console
> 4. **Utiliser des constantes** pour les lignes importantes (en-têtes, statuts)
> 5. **Créer des fonctions réutilisables** pour les opérations courantes
> 6. **Préférer l'effacement ciblé** au `Clear-Host` systématique
> 7. **Documenter les zones** d'affichage dans les scripts complexes

### 📝 Template de structure réutilisable

```powershell
# Définition des zones d'affichage
$ZONE_HEADER = 0
$ZONE_STATUS = 3
$ZONE_CONTENT = 5
$ZONE_FOOTER = [Console]::WindowHeight - 2

function Initialize-Display {
    Clear-Host
    # En-tête
    [Console]::SetCursorPosition(0, $ZONE_HEADER)
    Write-Host "═══ MON APPLICATION ═══" -ForegroundColor Cyan
    
    # Zone de contenu initiale
    [Console]::SetCursorPosition(0, $ZONE_CONTENT)
}

function Update-Status {
    param([string]$Message, [ConsoleColor]$Color = "Yellow")
    $saved = Save-CursorPosition
    [Console]::SetCursorPosition(0, $ZONE_STATUS)
    Write-Host (" " * [Console]::WindowWidth) -NoNewline
    [Console]::SetCursorPosition(0, $ZONE_STATUS)
    Write-Host "Status: $Message" -ForegroundColor $Color -NoNewline
    Restore-CursorPosition -Position $saved
}

# Utilisation
Initialize-Display
Update-Status "Prêt" -Color Green
Write-Host "Contenu principal ici..."
```

---

## 📚 Récapitulatif

|Technique|Usage|Performance|
|---|---|---|
|**Clear-Host**|Effacement total, réinitialisation|Rapide, mais clignotement|
|**SetCursorPosition**|Positionnement précis|Très rapide|
|**Effacement ciblé**|Mise à jour partielle|Optimal pour animations|
|**Sauvegarde/Restauration**|Interfaces multi-zones|Négligeable|

> [!success] Points clés à retenir
> 
> - `Clear-Host` pour les réinitialisations complètes, rarement dans les boucles
> - `[Console]::SetCursorPosition(X, Y)` pour le positionnement précis
> - Effacer avec des espaces pour les mises à jour ciblées
> - Toujours sauvegarder la position avant des modifications temporaires
> - Tester avec différentes tailles de fenêtre
> - Privilégier les fonctions réutilisables pour la maintenabilité