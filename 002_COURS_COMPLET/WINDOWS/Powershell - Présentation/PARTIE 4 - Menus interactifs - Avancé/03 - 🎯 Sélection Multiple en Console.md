

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

La sélection multiple en console permet aux utilisateurs de choisir plusieurs éléments dans une liste de manière interactive. C'est particulièrement utile pour :

- Sélectionner plusieurs fichiers à traiter
- Choisir plusieurs options de configuration
- Activer/désactiver plusieurs fonctionnalités simultanément
- Créer des interfaces utilisateur plus flexibles

> [!info] Pourquoi utiliser la sélection multiple ? Contrairement aux menus simples où l'utilisateur choisit une seule option, la sélection multiple offre plus de flexibilité en permettant de combiner plusieurs choix. Cela améliore l'expérience utilisateur et réduit le nombre d'interactions nécessaires.

---

## ✅ Cases à cocher simulées

Les cases à cocher en console sont simulées à l'aide de caractères spéciaux qui représentent visuellement l'état sélectionné ou non.

### Caractères recommandés

```powershell
# Symboles pour les cases à cocher
$symboleCocheVide = "[ ]"    # Case non cochée
$symboleCochePleine = "[X]"  # Case cochée
$symboleCochePleine = "[✓]"  # Alternative avec coche
$symboleCochePleine = "[●]"  # Alternative avec point
```

> [!tip] Compatibilité des caractères Les caractères Unicode (✓, ●) peuvent ne pas s'afficher correctement dans tous les terminaux. Testez sur votre environnement cible ou utilisez simplement `[X]` pour une compatibilité maximale.

### Structure de données pour les états

Pour gérer l'état de sélection de chaque élément, utilisez un tableau d'objets ou un hashtable :

```powershell
# Méthode 1 : Tableau d'objets personnalisés
$options = @(
    [PSCustomObject]@{ Nom = "Option 1"; Selectionne = $false }
    [PSCustomObject]@{ Nom = "Option 2"; Selectionne = $false }
    [PSCustomObject]@{ Nom = "Option 3"; Selectionne = $false }
)

# Méthode 2 : Hashtable (plus simple pour accès direct)
$etatsSelection = @{}
$listeOptions = @("Option 1", "Option 2", "Option 3")
foreach ($option in $listeOptions) {
    $etatsSelection[$option] = $false
}
```

### Fonction d'affichage avec cases à cocher

```powershell
function Afficher-MenuAvecCoches {
    param(
        [Parameter(Mandatory)]
        [array]$Options,
        
        [Parameter(Mandatory)]
        [hashtable]$EtatsSelection,
        
        [int]$IndexCurseur
    )
    
    Clear-Host
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Sélectionnez vos options (Espace pour cocher)" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $option = $Options[$i]
        
        # Symbole de sélection
        $coche = if ($EtatsSelection[$option]) { "[X]" } else { "[ ]" }
        
        # Indicateur de curseur
        $curseur = if ($i -eq $IndexCurseur) { ">" } else { " " }
        
        # Couleur selon l'état
        $couleur = if ($i -eq $IndexCurseur) { "Yellow" } else { "White" }
        
        Write-Host "$curseur $coche $option" -ForegroundColor $couleur
    }
    
    Write-Host ""
    Write-Host "─────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "↑↓: Naviguer | Espace: Cocher | Entrée: Valider" -ForegroundColor Gray
}
```

> [!example] Rendu visuel
> 
> ```
> ═══════════════════════════════════════
>   Sélectionnez vos options (Espace pour cocher)
> ═══════════════════════════════════════
> 
> > [X] Option 1
>   [ ] Option 2
>   [X] Option 3
> 
> ─────────────────────────────────────
> ↑↓: Naviguer | Espace: Cocher | Entrée: Valider
> ```

---

## ⌨️ Sélection avec barre d'espace

La gestion de la touche espace permet à l'utilisateur de cocher/décocher des éléments de manière intuitive.

### Détection de la touche espace

```powershell
# Lecture de la touche pressée
$touche = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Vérification de la barre d'espace
if ($touche.Character -eq ' ') {
    # Basculer l'état de sélection
    $etatsSelection[$options[$indexCurseur]] = -not $etatsSelection[$options[$indexCurseur]]
}
```

> [!info] Différence entre Character et VirtualKeyCode
> 
> - `$touche.Character` : Le caractère réel (utilisez pour Espace, Entrée)
> - `$touche.VirtualKeyCode` : Le code de la touche (utilisez pour flèches, Échap)

### Basculement de l'état

Le basculement (toggle) inverse l'état booléen actuel :

```powershell
# Basculer un booléen
$etatsSelection[$option] = -not $etatsSelection[$option]

# Équivalent à :
if ($etatsSelection[$option]) {
    $etatsSelection[$option] = $false
} else {
    $etatsSelection[$option] = $true
}
```

### Boucle de sélection complète

```powershell
function Obtenir-SelectionMultiple {
    param(
        [Parameter(Mandatory)]
        [array]$Options
    )
    
    # Initialisation des états
    $etatsSelection = @{}
    foreach ($option in $Options) {
        $etatsSelection[$option] = $false
    }
    
    $indexCurseur = 0
    $continuer = $true
    
    while ($continuer) {
        # Affichage du menu
        Afficher-MenuAvecCoches -Options $Options -EtatsSelection $etatsSelection -IndexCurseur $indexCurseur
        
        # Lecture de la touche
        $touche = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($touche.VirtualKeyCode) {
            38 {  # Flèche Haut
                $indexCurseur--
                if ($indexCurseur -lt 0) { $indexCurseur = $Options.Count - 1 }
            }
            40 {  # Flèche Bas
                $indexCurseur++
                if ($indexCurseur -ge $Options.Count) { $indexCurseur = 0 }
            }
            32 {  # Barre d'espace
                $optionCourante = $Options[$indexCurseur]
                $etatsSelection[$optionCourante] = -not $etatsSelection[$optionCourante]
            }
            13 {  # Entrée
                $continuer = $false
            }
            27 {  # Échap (optionnel)
                return $null  # Annulation
            }
        }
    }
    
    # Retourner les options sélectionnées
    return $Options | Where-Object { $etatsSelection[$_] }
}
```

> [!warning] Gestion de VirtualKeyCode 32 Le code virtuel 32 correspond à la barre d'espace, mais `$touche.Character -eq ' '` est plus lisible et fiable pour détecter l'espace.

---

## 📊 Affichage des éléments sélectionnés

Il existe plusieurs façons d'afficher les éléments actuellement sélectionnés pendant l'interaction.

### Compteur de sélection

Affichez un compteur en temps réel :

```powershell
function Afficher-MenuAvecCompteur {
    param(
        [Parameter(Mandatory)]
        [array]$Options,
        
        [Parameter(Mandatory)]
        [hashtable]$EtatsSelection,
        
        [int]$IndexCurseur
    )
    
    # Compter les sélections
    $nombreSelections = ($EtatsSelection.Values | Where-Object { $_ }).Count
    
    Clear-Host
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Sélection multiple" -ForegroundColor Cyan
    Write-Host "  ($nombreSelections/$($Options.Count) sélectionné(s))" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Affichage des options...
}
```

### Liste des sélections en pied de page

Affichez les éléments sélectionnés en bas du menu :

```powershell
# Après l'affichage des options
$selections = $Options | Where-Object { $EtatsSelection[$_] }

Write-Host ""
if ($selections.Count -gt 0) {
    Write-Host "Sélectionné(s) : " -ForegroundColor Green -NoNewline
    Write-Host ($selections -join ", ") -ForegroundColor White
} else {
    Write-Host "Aucune sélection" -ForegroundColor DarkGray
}
```

### Indicateur visuel renforcé

Utilisez des couleurs différentes pour les éléments sélectionnés :

```powershell
# Dans la boucle d'affichage
for ($i = 0; $i -lt $Options.Count; $i++) {
    $option = $Options[$i]
    $coche = if ($EtatsSelection[$option]) { "[X]" } else { "[ ]" }
    $curseur = if ($i -eq $IndexCurseur) { ">" } else { " " }
    
    # Couleur selon état de sélection ET curseur
    if ($i -eq $IndexCurseur) {
        $couleurTexte = "Yellow"
        $couleurCoche = if ($EtatsSelection[$option]) { "Green" } else { "White" }
    } else {
        $couleurTexte = "White"
        $couleurCoche = if ($EtatsSelection[$option]) { "Green" } else { "DarkGray" }
    }
    
    Write-Host "$curseur " -ForegroundColor $couleurTexte -NoNewline
    Write-Host "$coche " -ForegroundColor $couleurCoche -NoNewline
    Write-Host "$option" -ForegroundColor $couleurTexte
}
```

> [!tip] Expérience utilisateur Combinez plusieurs indicateurs pour une meilleure lisibilité :
> 
> - Compteur global (en haut)
> - Couleurs différenciées (dans la liste)
> - Liste récapitulative (en bas)

---

## ✔️ Validation de la sélection multiple

La validation permet de s'assurer que l'utilisateur a effectué une sélection conforme aux règles métier.

### Validation du nombre de sélections

```powershell
function Obtenir-SelectionMultipleAvecValidation {
    param(
        [Parameter(Mandatory)]
        [array]$Options,
        
        [int]$Minimum = 0,
        [int]$Maximum = [int]::MaxValue
    )
    
    # ... code de sélection ...
    
    # Validation avant de sortir
    while ($continuer) {
        # ... gestion des touches ...
        
        if ($touche.VirtualKeyCode -eq 13) {  # Entrée
            $selections = $Options | Where-Object { $etatsSelection[$_] }
            $compte = $selections.Count
            
            # Vérification du minimum
            if ($compte -lt $Minimum) {
                Write-Host ""
                Write-Host "⚠ Veuillez sélectionner au moins $Minimum option(s)" -ForegroundColor Red
                Start-Sleep -Seconds 2
                continue
            }
            
            # Vérification du maximum
            if ($compte -gt $Maximum) {
                Write-Host ""
                Write-Host "⚠ Vous ne pouvez sélectionner plus de $Maximum option(s)" -ForegroundColor Red
                Start-Sleep -Seconds 2
                continue
            }
            
            $continuer = $false
        }
    }
    
    return $selections
}
```

### Confirmation avant validation

Demandez une confirmation explicite :

```powershell
# Après détection de la touche Entrée
$selections = $Options | Where-Object { $etatsSelection[$_] }

Clear-Host
Write-Host "Validation de la sélection" -ForegroundColor Cyan
Write-Host "─────────────────────────────" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Vous avez sélectionné :" -ForegroundColor White
foreach ($sel in $selections) {
    Write-Host "  • $sel" -ForegroundColor Green
}
Write-Host ""
Write-Host "Confirmer ? (O/N) : " -ForegroundColor Yellow -NoNewline

$confirmation = Read-Host
if ($confirmation -match '^[oO]$') {
    return $selections
} else {
    # Retour au menu
    continue
}
```

### Message de validation dynamique

Adaptez le message selon le contexte :

```powershell
function Afficher-MessageValidation {
    param(
        [int]$NombreSelections,
        [int]$Minimum,
        [int]$Maximum
    )
    
    $messageEtat = ""
    $couleur = "Gray"
    
    if ($NombreSelections -eq 0) {
        $messageEtat = "Aucune sélection"
        $couleur = "DarkGray"
    }
    elseif ($NombreSelections -lt $Minimum) {
        $messageEtat = "Minimum requis : $Minimum"
        $couleur = "Red"
    }
    elseif ($NombreSelections -gt $Maximum) {
        $messageEtat = "Maximum autorisé : $Maximum"
        $couleur = "Red"
    }
    else {
        $messageEtat = "✓ Sélection valide"
        $couleur = "Green"
    }
    
    Write-Host $messageEtat -ForegroundColor $couleur
}
```

> [!warning] Validation côté serveur Si votre script est appelé par d'autres scripts ou automatisé, validez toujours les entrées même après la sélection interactive.

---

## 🎨 Exemple complet et intégré

Voici une fonction complète et réutilisable pour la sélection multiple :

```powershell
function Get-MultipleChoice {
    <#
    .SYNOPSIS
        Menu de sélection multiple interactif
    
    .PARAMETER Options
        Liste des options disponibles
    
    .PARAMETER Titre
        Titre du menu
    
    .PARAMETER Minimum
        Nombre minimum de sélections requises
    
    .PARAMETER Maximum
        Nombre maximum de sélections autorisées
    
    .PARAMETER PreSelection
        Liste des options pré-sélectionnées
    
    .EXAMPLE
        $choix = Get-MultipleChoice -Options @("Service1", "Service2", "Service3") -Titre "Services à démarrer" -Minimum 1
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Options,
        
        [string]$Titre = "Sélection multiple",
        
        [int]$Minimum = 0,
        
        [int]$Maximum = [int]::MaxValue,
        
        [string[]]$PreSelection = @()
    )
    
    # Initialisation des états
    $etatsSelection = @{}
    foreach ($option in $Options) {
        $etatsSelection[$option] = $option -in $PreSelection
    }
    
    $indexCurseur = 0
    $continuer = $true
    $messageErreur = ""
    
    while ($continuer) {
        # Calcul du nombre de sélections
        $nombreSelections = ($etatsSelection.Values | Where-Object { $_ }).Count
        
        # Affichage
        Clear-Host
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "  $Titre" -ForegroundColor Cyan
        Write-Host "  ($nombreSelections/$($Options.Count) sélectionné(s))" -ForegroundColor $(
            if ($nombreSelections -ge $Minimum -and $nombreSelections -le $Maximum) { "Green" } else { "Red" }
        )
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        
        # Options
        for ($i = 0; $i -lt $Options.Count; $i++) {
            $option = $Options[$i]
            $coche = if ($etatsSelection[$option]) { "[X]" } else { "[ ]" }
            $curseur = if ($i -eq $IndexCurseur) { ">" } else { " " }
            
            if ($i -eq $IndexCurseur) {
                $couleurTexte = "Yellow"
                $couleurCoche = if ($etatsSelection[$option]) { "Green" } else { "White" }
            } else {
                $couleurTexte = "White"
                $couleurCoche = if ($etatsSelection[$option]) { "Green" } else { "DarkGray" }
            }
            
            Write-Host "$curseur " -ForegroundColor $couleurTexte -NoNewline
            Write-Host "$coche " -ForegroundColor $couleurCoche -NoNewline
            Write-Host "$option" -ForegroundColor $couleurTexte
        }
        
        # Pied de page
        Write-Host ""
        Write-Host "─────────────────────────────────────" -ForegroundColor DarkGray
        
        # Message d'erreur si présent
        if ($messageErreur) {
            Write-Host "⚠ $messageErreur" -ForegroundColor Red
            Write-Host ""
        }
        
        # Instructions
        Write-Host "↑↓: Naviguer | " -ForegroundColor Gray -NoNewline
        Write-Host "Espace: " -ForegroundColor White -NoNewline
        Write-Host "Cocher | " -ForegroundColor Gray -NoNewline
        Write-Host "Entrée: " -ForegroundColor White -NoNewline
        Write-Host "Valider | " -ForegroundColor Gray -NoNewline
        Write-Host "Échap: " -ForegroundColor White -NoNewline
        Write-Host "Annuler" -ForegroundColor Gray
        
        # Lecture de la touche
        $touche = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $messageErreur = ""
        
        switch ($touche.VirtualKeyCode) {
            38 {  # Flèche Haut
                $indexCurseur--
                if ($indexCurseur -lt 0) { $indexCurseur = $Options.Count - 1 }
            }
            40 {  # Flèche Bas
                $indexCurseur++
                if ($indexCurseur -ge $Options.Count) { $indexCurseur = 0 }
            }
            32 {  # Barre d'espace
                $optionCourante = $Options[$indexCurseur]
                $nouvelEtat = -not $etatsSelection[$optionCourante]
                
                # Vérification du maximum avant de cocher
                if ($nouvelEtat -and $nombreSelections -ge $Maximum) {
                    $messageErreur = "Maximum de $Maximum sélection(s) atteint"
                } else {
                    $etatsSelection[$optionCourante] = $nouvelEtat
                }
            }
            13 {  # Entrée
                # Validation
                if ($nombreSelections -lt $Minimum) {
                    $messageErreur = "Veuillez sélectionner au moins $Minimum option(s)"
                }
                elseif ($nombreSelections -gt $Maximum) {
                    $messageErreur = "Vous ne pouvez sélectionner plus de $Maximum option(s)"
                }
                else {
                    $continuer = $false
                }
            }
            27 {  # Échap
                return $null
            }
        }
    }
    
    # Retour des sélections
    return $Options | Where-Object { $etatsSelection[$_] }
}

# Utilisation
$services = @(
    "IIS",
    "SQL Server",
    "Redis",
    "RabbitMQ",
    "Elasticsearch"
)

$selections = Get-MultipleChoice -Options $services -Titre "Choisir les services à démarrer" -Minimum 1 -Maximum 3

if ($selections) {
    Write-Host "`nServices sélectionnés :" -ForegroundColor Green
    $selections | ForEach-Object { Write-Host "  • $_" -ForegroundColor White }
} else {
    Write-Host "`nOpération annulée" -ForegroundColor Yellow
}
```

> [!example] Cas d'usage avancés Cette fonction peut être adaptée pour :
> 
> - Sélection de fichiers dans un dossier
> - Choix de modules à installer/désinstaller
> - Configuration de permissions utilisateurs
> - Sélection de paramètres de sauvegarde

---

## ⚠️ Pièges courants

### 1. Gestion incorrecte de l'état

```powershell
# ❌ INCORRECT - Référence perdue
$option = $Options[$i]
$etatsSelection[$i] = -not $etatsSelection[$i]  # Index au lieu de valeur

# ✅ CORRECT - Référence par valeur
$option = $Options[$i]
$etatsSelection[$option] = -not $etatsSelection[$option]
```

### 2. Rafraîchissement insuffisant

```powershell
# ❌ INCORRECT - Ancien compteur affiché
$nombreSelections = ($etatsSelection.Values | Where-Object { $_ }).Count
while ($continuer) {
    # Affichage utilisant $nombreSelections qui ne change jamais
}

# ✅ CORRECT - Recalcul à chaque itération
while ($continuer) {
    $nombreSelections = ($etatsSelection.Values | Where-Object { $_ }).Count
    # Affichage avec valeur à jour
}
```

### 3. Validation incomplète

```powershell
# ❌ INCORRECT - Validation uniquement sur Entrée
if ($touche.VirtualKeyCode -eq 13) {
    return $Options | Where-Object { $etatsSelection[$_] }
}

# ✅ CORRECT - Validation avec feedback
if ($touche.VirtualKeyCode -eq 13) {
    $selections = $Options | Where-Object { $etatsSelection[$_] }
    if ($selections.Count -lt $Minimum) {
        # Afficher erreur et continuer
        continue
    }
    return $selections
}
```

### 4. Oubli du cas d'annulation

```powershell
# ❌ INCORRECT - Aucun moyen d'annuler
while ($continuer) {
    # Seulement Entrée pour sortir
}

# ✅ CORRECT - Gestion d'Échap
if ($touche.VirtualKeyCode -eq 27) {
    return $null  # ou @() selon votre logique
}
```

### 5. Débordement de compteur

```powershell
# ❌ INCORRECT - Peut dépasser le maximum
$etatsSelection[$option] = -not $etatsSelection[$option]

# ✅ CORRECT - Vérification avant de cocher
$nouvelEtat = -not $etatsSelection[$option]
if ($nouvelEtat -and $nombreSelections -ge $Maximum) {
    # Afficher erreur, ne pas modifier l'état
} else {
    $etatsSelection[$option] = $nouvelEtat
}
```

---

## 💡 Bonnes pratiques

### 1. Rendez les contraintes visuellement claires

```powershell
# Affichez toujours les règles
Write-Host "Sélectionnez entre $Minimum et $Maximum option(s)" -ForegroundColor Gray

# Utilisez des couleurs pour indiquer la validité
$couleur = if ($nombreSelections -ge $Minimum -and $nombreSelections -le $Maximum) { 
    "Green" 
} else { 
    "Red" 
}
Write-Host "($nombreSelections sélectionné(s))" -ForegroundColor $couleur
```

### 2. Offrez des raccourcis pratiques

```powershell
# Ajoutez des touches supplémentaires utiles
switch ($touche.Character) {
    'a' {  # Sélectionner tout
        foreach ($opt in $Options) { $etatsSelection[$opt] = $true }
    }
    'n' {  # Désélectionner tout (none)
        foreach ($opt in $Options) { $etatsSelection[$opt] = $false }
    }
    'i' {  # Inverser la sélection
        foreach ($opt in $Options) { $etatsSelection[$opt] = -not $etatsSelection[$opt] }
    }
}
```

### 3. Sauvegardez les préférences utilisateur

```powershell
# Sauvegarde de la sélection
$selections | Export-Clixml -Path ".\derniereSelection.xml"

# Chargement comme pré-sélection
$preSelection = Import-Clixml -Path ".\derniereSelection.xml" -ErrorAction SilentlyContinue
$choix = Get-MultipleChoice -Options $options -PreSelection $preSelection
```

### 4. Groupez les options logiquement

```powershell
# Si beaucoup d'options, ajoutez des séparateurs visuels
$optionsGroupees = @(
    "─── Services Web ───",
    "IIS",
    "Nginx",
    "─── Bases de données ───",
    "SQL Server",
    "PostgreSQL"
)

# Gérez les séparateurs (non sélectionnables)
if ($option -match '^───') {
    Write-Host $option -ForegroundColor DarkCyan
    continue
}
```

### 5. Documentez les paramètres de validation

```powershell
<#
.PARAMETER Minimum
    Nombre minimum de sélections requises (défaut : 0)
    Utilisez 1 pour forcer au moins un choix

.PARAMETER Maximum
    Nombre maximum de sélections autorisées (défaut : illimité)
    Utile pour limiter les ressources ou contraintes métier
#>
```

### 6. Testez avec des listes de différentes tailles

```powershell
# Liste courte (2-5 éléments)
# Liste moyenne (6-15 éléments)
# Liste longue (15+ éléments) - envisagez le scrolling

if ($Options.Count -gt 20) {
    Write-Warning "Liste très longue détectée. Envisagez d'ajouter une fonctionnalité de recherche/filtre."
}
```

### 7. Gérez les cas limites élégamment

```powershell
# Liste vide
if ($Options.Count -eq 0) {
    Write-Host "Aucune option disponible" -ForegroundColor Yellow
    return @()
}

# Une seule option
if ($Options.Count -eq 1) {
    Write-Host "Une seule option disponible : $($Options[0])" -ForegroundColor Cyan
    return $Options
}

# Minimum égal au nombre d'options (tout sélectionner obligatoire)
if ($Minimum -eq $Options.Count) {
    Write-Host "Toutes les options sont obligatoires" -ForegroundColor Yellow
    return $Options
}
```

---

> [!tip] 💡 Astuce finale La sélection multiple enrichit considérablement l'expérience utilisateur. Investissez du temps dans les feedbacks visuels (couleurs, compteurs, messages) pour créer une interface intuitive et professionnelle. Les utilisateurs apprécieront la clarté et la réactivité de votre script.