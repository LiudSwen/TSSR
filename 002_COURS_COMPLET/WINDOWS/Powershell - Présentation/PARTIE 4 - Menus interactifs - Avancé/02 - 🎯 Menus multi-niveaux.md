

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

## Introduction

Les menus multi-niveaux représentent une évolution naturelle des menus simples. Ils permettent d'organiser des fonctionnalités complexes de manière hiérarchique et intuitive. Cette approche est essentielle pour créer des scripts PowerShell qui gèrent de multiples domaines fonctionnels tout en restant accessibles et maintenables.

> [!info] Pourquoi des menus multi-niveaux ?
> 
> - **Organisation** : Regrouper logiquement des fonctionnalités connexes
> - **Scalabilité** : Gérer facilement des dizaines de fonctions sans surcharger l'interface
> - **Expérience utilisateur** : Navigation intuitive similaire aux applications professionnelles
> - **Maintenance** : Structure modulaire facilitant l'évolution du code

---

## Menus Multi-niveaux

### Concept fondamental

Un menu multi-niveaux est une structure arborescente où chaque menu peut contenir des actions ET d'autres menus. Cette hiérarchie permet de créer une navigation profonde sans complexifier chaque niveau individuel.

### Architecture de base

```powershell
# Structure globale d'un système de menus multi-niveaux
function Show-MainMenu {
    param(
        [string]$CurrentPath = "Menu Principal"
    )
    
    Clear-Host
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $CurrentPath" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. Gestion des Utilisateurs" -ForegroundColor White
    Write-Host "  2. Gestion des Serveurs" -ForegroundColor White
    Write-Host "  3. Rapports et Statistiques" -ForegroundColor White
    Write-Host "  4. Configuration" -ForegroundColor White
    Write-Host ""
    Write-Host "  0. Quitter" -ForegroundColor Red
    Write-Host ""
    
    $choice = Read-Host "Sélectionnez une option"
    
    switch ($choice) {
        "1" { Show-UserMenu -ParentPath $CurrentPath }
        "2" { Show-ServerMenu -ParentPath $CurrentPath }
        "3" { Show-ReportMenu -ParentPath $CurrentPath }
        "4" { Show-ConfigMenu -ParentPath $CurrentPath }
        "0" { return $false }  # Signal de sortie
        default { 
            Write-Host "Option invalide" -ForegroundColor Red
            Start-Sleep -Seconds 1
            Show-MainMenu -CurrentPath $CurrentPath
        }
    }
    
    return $true  # Continuer la boucle
}
```

> [!tip] Principe de récursivité Chaque fonction de menu peut appeler d'autres fonctions de menu, créant ainsi une structure récursive naturelle. Le paramètre `-ParentPath` permet de construire le fil d'Ariane progressivement.

### Boucle principale d'exécution

```powershell
# Point d'entrée du programme
function Start-MenuSystem {
    $continue = $true
    
    while ($continue) {
        $continue = Show-MainMenu
    }
    
    Write-Host "`n👋 Au revoir !" -ForegroundColor Green
}

# Lancement
Start-MenuSystem
```

> [!warning] Gestion des boucles Attention à ne pas créer de boucles infinies. Chaque menu doit avoir une option de retour ou de sortie, et le système doit pouvoir propager le signal de sortie vers le haut de la hiérarchie.

---

## Sous-menus Imbriqués

### Implémentation d'un sous-menu

Les sous-menus suivent la même structure que le menu principal, mais héritent du contexte de navigation.

```powershell
function Show-UserMenu {
    param(
        [string]$ParentPath = "Menu Principal"
    )
    
    $currentPath = "$ParentPath > Gestion Utilisateurs"
    $continue = $true
    
    while ($continue) {
        Clear-Host
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "  $currentPath" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  1. Créer un utilisateur" -ForegroundColor White
        Write-Host "  2. Modifier un utilisateur" -ForegroundColor White
        Write-Host "  3. Supprimer un utilisateur" -ForegroundColor White
        Write-Host "  4. Lister les utilisateurs" -ForegroundColor White
        Write-Host "  5. Permissions avancées ➜" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "  0. ← Retour" -ForegroundColor Yellow
        Write-Host ""
        
        $choice = Read-Host "Sélectionnez une option"
        
        switch ($choice) {
            "1" { 
                Invoke-CreateUser
                Read-Host "Appuyez sur Entrée pour continuer"
            }
            "2" { 
                Invoke-ModifyUser
                Read-Host "Appuyez sur Entrée pour continuer"
            }
            "3" { 
                Invoke-DeleteUser
                Read-Host "Appuyez sur Entrée pour continuer"
            }
            "4" { 
                Invoke-ListUsers
                Read-Host "Appuyez sur Entrée pour continuer"
            }
            "5" { 
                # Appel d'un sous-menu encore plus profond
                Show-PermissionsMenu -ParentPath $currentPath
            }
            "0" { $continue = $false }  # Retour au menu parent
            default { 
                Write-Host "Option invalide" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}
```

### Sous-menu de niveau 3

```powershell
function Show-PermissionsMenu {
    param(
        [string]$ParentPath
    )
    
    $currentPath = "$ParentPath > Permissions"
    $continue = $true
    
    while ($continue) {
        Clear-Host
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "  $currentPath" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  1. Gérer les groupes" -ForegroundColor White
        Write-Host "  2. Gérer les rôles" -ForegroundColor White
        Write-Host "  3. Audit des permissions" -ForegroundColor White
        Write-Host ""
        Write-Host "  0. ← Retour" -ForegroundColor Yellow
        Write-Host ""
        
        $choice = Read-Host "Sélectionnez une option"
        
        switch ($choice) {
            "1" { 
                Invoke-ManageGroups
                Read-Host "Appuyez sur Entrée pour continuer"
            }
            "2" { 
                Invoke-ManageRoles
                Read-Host "Appuyez sur Entrée pour continuer"
            }
            "3" { 
                Invoke-PermissionsAudit
                Read-Host "Appuyez sur Entrée pour continuer"
            }
            "0" { $continue = $false }
            default { 
                Write-Host "Option invalide" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}
```

> [!example] Pattern récurrent Notez le pattern qui se répète :
> 
> 1. Paramètre `$ParentPath` en entrée
> 2. Construction du `$currentPath` local
> 3. Boucle `while` avec variable `$continue`
> 4. Option "0" pour sortir de la boucle
> 5. Appels récursifs aux sous-menus avec transmission du path

---

## Breadcrumb (Fil d'Ariane)

### Principe du fil d'Ariane

Le breadcrumb indique à l'utilisateur où il se trouve dans la hiérarchie des menus. C'est un élément crucial pour l'orientation dans une structure multi-niveaux.

### Implémentation simple

```powershell
function Show-MenuWithBreadcrumb {
    param(
        [string[]]$PathArray = @("Menu Principal")
    )
    
    Clear-Host
    
    # Construction du breadcrumb
    $breadcrumb = $PathArray -join " > "
    
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  📍 $breadcrumb" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    # ... reste du menu
}
```

### Breadcrumb avancé avec couleurs

```powershell
function Write-Breadcrumb {
    param(
        [string[]]$PathArray
    )
    
    Write-Host "  📍 " -NoNewline -ForegroundColor White
    
    for ($i = 0; $i -lt $PathArray.Count; $i++) {
        if ($i -eq $PathArray.Count - 1) {
            # Dernier élément en surbrillance
            Write-Host $PathArray[$i] -ForegroundColor Yellow
        } else {
            # Éléments intermédiaires
            Write-Host $PathArray[$i] -NoNewline -ForegroundColor Gray
            Write-Host " > " -NoNewline -ForegroundColor DarkGray
        }
    }
}

# Utilisation
function Show-UserMenu {
    param(
        [string[]]$PathArray = @("Menu Principal")
    )
    
    $currentPath = $PathArray + @("Gestion Utilisateurs")
    
    Clear-Host
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Breadcrumb -PathArray $currentPath
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    # ... reste du menu
    
    # Passage aux sous-menus
    # Show-PermissionsMenu -PathArray $currentPath
}
```

> [!tip] Avantages du tableau de path Utiliser un tableau plutôt qu'une chaîne permet :
> 
> - De séparer facilement les niveaux
> - D'appliquer des styles différents par niveau
> - De calculer facilement la profondeur de navigation
> - De gérer plus facilement l'historique

### Breadcrumb avec limitation de longueur

```powershell
function Write-CompactBreadcrumb {
    param(
        [string[]]$PathArray,
        [int]$MaxLength = 60
    )
    
    $breadcrumb = $PathArray -join " > "
    
    if ($breadcrumb.Length -gt $MaxLength) {
        # Afficher uniquement les 2 premiers et le dernier
        if ($PathArray.Count -gt 3) {
            $compact = "$($PathArray[0]) > ... > $($PathArray[-1])"
            Write-Host "  📍 $compact" -ForegroundColor Yellow
        } else {
            Write-Host "  📍 $breadcrumb" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  📍 $breadcrumb" -ForegroundColor Yellow
    }
}
```

---

## Navigation Retour/Quitter

### Distinction Retour vs Quitter

|Option|Fonction|Comportement|
|---|---|---|
|**Retour**|Navigation hiérarchique|Remonte d'un niveau dans les menus|
|**Quitter**|Sortie globale|Ferme complètement l'application|

### Implémentation standard

```powershell
function Show-MenuWithNavigation {
    param(
        [string[]]$PathArray = @("Menu Principal"),
        [switch]$IsRootMenu
    )
    
    $continue = $true
    
    while ($continue) {
        Clear-Host
        # ... affichage du menu ...
        
        Write-Host ""
        if ($IsRootMenu) {
            Write-Host "  Q. Quitter" -ForegroundColor Red
        } else {
            Write-Host "  0. ← Retour" -ForegroundColor Yellow
            Write-Host "  Q. ❌ Quitter l'application" -ForegroundColor Red
        }
        Write-Host ""
        
        $choice = Read-Host "Sélectionnez une option"
        
        switch ($choice) {
            # ... autres options ...
            "0" { 
                if (-not $IsRootMenu) {
                    $continue = $false  # Retour au menu parent
                }
            }
            "Q" { 
                $confirmQuit = Read-Host "Êtes-vous sûr de vouloir quitter ? (O/N)"
                if ($confirmQuit -eq "O") {
                    return "QUIT"  # Signal de sortie globale
                }
            }
        }
    }
    
    return "CONTINUE"
}
```

### Propagation du signal de sortie

```powershell
function Show-MainMenu {
    $result = Show-MenuWithNavigation -PathArray @("Menu Principal") -IsRootMenu
    return ($result -ne "QUIT")
}

function Show-SubMenu {
    param([string[]]$PathArray)
    
    $result = Show-MenuWithNavigation -PathArray ($PathArray + @("Sous-menu"))
    
    # Si signal QUIT, propager vers le haut
    if ($result -eq "QUIT") {
        return "QUIT"
    }
    
    return "CONTINUE"
}

# Boucle principale
function Start-MenuSystem {
    $continue = $true
    
    while ($continue) {
        $continue = Show-MainMenu
    }
}
```

> [!warning] Gestion cohérente Tous les menus doivent gérer le signal "QUIT" de manière uniforme pour éviter qu'un utilisateur ne se retrouve bloqué dans un sous-menu sans pouvoir sortir complètement de l'application.

### Confirmation de sortie optionnelle

```powershell
function Confirm-Exit {
    param(
        [string]$Message = "Êtes-vous sûr de vouloir quitter ?",
        [switch]$SkipConfirmation
    )
    
    if ($SkipConfirmation) {
        return $true
    }
    
    Write-Host ""
    Write-Host $Message -ForegroundColor Yellow
    Write-Host "  [O] Oui  [N] Non" -ForegroundColor Gray
    
    $response = Read-Host "Votre choix"
    return ($response -eq "O")
}

# Utilisation
if ($choice -eq "Q") {
    if (Confirm-Exit) {
        return "QUIT"
    }
}
```

---

## État Global du Menu

### Pourquoi gérer un état global ?

Un état global permet de :

- Conserver des informations entre les navigations
- Partager des données entre différents menus
- Mémoriser des préférences utilisateur
- Gérer des sessions ou des contextes

### Implémentation avec hashtable

```powershell
# Initialisation de l'état global
$Global:MenuState = @{
    CurrentUser = $env:USERNAME
    SessionStart = Get-Date
    LastAction = $null
    Settings = @{
        Theme = "Dark"
        Language = "FR"
        AutoSave = $true
    }
    Data = @{
        SelectedServer = $null
        FilterActive = $false
        RecentItems = @()
    }
}

function Show-MenuWithState {
    param(
        [hashtable]$State = $Global:MenuState
    )
    
    Clear-Host
    
    # Affichage d'informations contextuelles
    Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  Menu Principal                       ║" -ForegroundColor Cyan
    Write-Host "╠═══════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║  👤 Utilisateur: $($State.CurrentUser.PadRight(19)) ║" -ForegroundColor White
    Write-Host "║  🕐 Session: $(((Get-Date) - $State.SessionStart).ToString('hh\:mm\:ss').PadRight(23)) ║" -ForegroundColor Gray
    Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # ... reste du menu
}
```

### Gestion des préférences

```powershell
function Update-MenuState {
    param(
        [string]$Key,
        [object]$Value
    )
    
    # Mise à jour de l'état
    $Global:MenuState[$Key] = $Value
    
    # Optionnel : sauvegarde persistante
    $Global:MenuState.LastAction = @{
        Action = "StateUpdate"
        Key = $Key
        Timestamp = Get-Date
    }
}

function Get-MenuState {
    param(
        [string]$Key
    )
    
    return $Global:MenuState[$Key]
}

# Utilisation dans un menu
function Show-SettingsMenu {
    $currentTheme = Get-MenuState -Key "Settings"
    
    Write-Host "Thème actuel: $($currentTheme.Theme)" -ForegroundColor Cyan
    
    $newTheme = Read-Host "Nouveau thème (Dark/Light)"
    
    if ($newTheme -in @("Dark", "Light")) {
        $Global:MenuState.Settings.Theme = $newTheme
        Write-Host "✓ Thème mis à jour" -ForegroundColor Green
    }
}
```

### État avec contexte de sélection

```powershell
# Mémorisation de sélections entre menus
function Show-ServerSelectionMenu {
    param([hashtable]$State)
    
    # ... affichage de la liste des serveurs
    
    $selectedServer = Read-Host "Sélectionnez un serveur"
    
    # Stockage dans l'état global
    $State.Data.SelectedServer = $selectedServer
    
    Write-Host "✓ Serveur '$selectedServer' sélectionné" -ForegroundColor Green
    Write-Host "  Ce serveur sera utilisé dans les opérations suivantes" -ForegroundColor Gray
}

function Show-ServerActionsMenu {
    param([hashtable]$State)
    
    $server = $State.Data.SelectedServer
    
    if (-not $server) {
        Write-Host "⚠ Aucun serveur sélectionné" -ForegroundColor Yellow
        Write-Host "  Veuillez d'abord sélectionner un serveur" -ForegroundColor Gray
        Read-Host "Appuyez sur Entrée"
        return
    }
    
    Write-Host "Actions sur le serveur: $server" -ForegroundColor Cyan
    # ... actions spécifiques
}
```

> [!tip] Bonnes pratiques pour l'état global
> 
> - Initialiser tous les champs dès le départ
> - Utiliser des structures imbriquées claires (Settings, Data, etc.)
> - Ne jamais modifier l'état directement, passer par des fonctions
> - Documenter la structure de l'état dans un commentaire en-tête

### Sauvegarde et restauration de l'état

```powershell
function Save-MenuState {
    param(
        [hashtable]$State,
        [string]$FilePath = "$env:TEMP\MenuState.json"
    )
    
    try {
        # Conversion en JSON avec gestion des dates
        $stateToSave = $State.Clone()
        $stateToSave.SessionStart = $stateToSave.SessionStart.ToString("o")
        
        $stateToSave | ConvertTo-Json -Depth 10 | Set-Content -Path $FilePath
        Write-Host "✓ État sauvegardé" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Erreur lors de la sauvegarde: $_" -ForegroundColor Red
    }
}

function Restore-MenuState {
    param(
        [string]$FilePath = "$env:TEMP\MenuState.json"
    )
    
    if (Test-Path $FilePath) {
        try {
            $restored = Get-Content -Path $FilePath | ConvertFrom-Json -AsHashtable
            $restored.SessionStart = [DateTime]::Parse($restored.SessionStart)
            return $restored
        }
        catch {
            Write-Host "⚠ Impossible de restaurer l'état précédent" -ForegroundColor Yellow
            return $null
        }
    }
    
    return $null
}
```

---

## Historique de Navigation

### Concept de l'historique

L'historique de navigation permet de :

- Retracer le parcours de l'utilisateur
- Implémenter une navigation "Précédent" (différent de "Retour")
- Analyser les patterns d'utilisation
- Déboguer les problèmes de navigation

### Implémentation basique

```powershell
# Ajout à l'état global
$Global:MenuState.NavigationHistory = @()

function Add-NavigationEntry {
    param(
        [string]$MenuName,
        [string]$Action = "Enter"
    )
    
    $entry = @{
        Menu = $MenuName
        Action = $Action
        Timestamp = Get-Date
    }
    
    $Global:MenuState.NavigationHistory += $entry
    
    # Limitation de la taille de l'historique
    if ($Global:MenuState.NavigationHistory.Count -gt 50) {
        $Global:MenuState.NavigationHistory = $Global:MenuState.NavigationHistory[-50..-1]
    }
}

function Show-MenuWithHistory {
    param(
        [string]$MenuName
    )
    
    # Enregistrement de l'entrée dans le menu
    Add-NavigationEntry -MenuName $MenuName -Action "Enter"
    
    Clear-Host
    # ... affichage du menu
    
    # Enregistrement de la sortie
    Add-NavigationEntry -MenuName $MenuName -Action "Exit"
}
```

### Affichage de l'historique

```powershell
function Show-NavigationHistory {
    param(
        [int]$LastN = 10
    )
    
    Clear-Host
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  📜 Historique de Navigation" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $history = $Global:MenuState.NavigationHistory | Select-Object -Last $LastN
    
    if ($history.Count -eq 0) {
        Write-Host "  Aucun historique disponible" -ForegroundColor Gray
    } else {
        foreach ($entry in $history) {
            $time = $entry.Timestamp.ToString("HH:mm:ss")
            $icon = if ($entry.Action -eq "Enter") { "➜" } else { "←" }
            $color = if ($entry.Action -eq "Enter") { "Green" } else { "Yellow" }
            
            Write-Host "  [$time] " -NoNewline -ForegroundColor Gray
            Write-Host "$icon " -NoNewline -ForegroundColor $color
            Write-Host $entry.Menu -ForegroundColor White
        }
    }
    
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour continuer"
}
```

### Pile de navigation (Stack)

```powershell
# Utilisation d'une pile pour la navigation
$Global:NavigationStack = New-Object System.Collections.Generic.Stack[string]

function Push-NavigationStack {
    param([string]$MenuName)
    
    $Global:NavigationStack.Push($MenuName)
    Write-Verbose "Navigation: Entré dans '$MenuName' (Profondeur: $($Global:NavigationStack.Count))"
}

function Pop-NavigationStack {
    if ($Global:NavigationStack.Count -gt 0) {
        $menuName = $Global:NavigationStack.Pop()
        Write-Verbose "Navigation: Sorti de '$menuName' (Profondeur: $($Global:NavigationStack.Count))"
        return $menuName
    }
    return $null
}

function Get-CurrentNavigationDepth {
    return $Global:NavigationStack.Count
}

function Show-NavigationBreadcrumb {
    if ($Global:NavigationStack.Count -gt 0) {
        $path = $Global:NavigationStack.ToArray()
        [Array]::Reverse($path)
        Write-Host "  📍 " -NoNewline
        Write-Host ($path -join " > ") -ForegroundColor Yellow
    }
}
```

### Intégration dans un système de menus

```powershell
function Show-MenuWithNavStack {
    param(
        [string]$MenuName,
        [scriptblock]$MenuContent
    )
    
    # Empiler le menu actuel
    Push-NavigationStack -MenuName $MenuName
    
    $continue = $true
    while ($continue) {
        Clear-Host
        
        # Affichage du breadcrumb basé sur la pile
        Show-NavigationBreadcrumb
        
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "  $MenuName" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        
        # Exécution du contenu du menu
        & $MenuContent
        
        Write-Host ""
        Write-Host "  0. ← Retour" -ForegroundColor Yellow
        Write-Host ""
        
        $choice = Read-Host "Sélectionnez une option"
        
        if ($choice -eq "0") {
            $continue = $false
        }
    }
    
    # Dépiler à la sortie
    Pop-NavigationStack | Out-Null
}

# Exemple d'utilisation
function Start-Application {
    $Global:NavigationStack = New-Object System.Collections.Generic.Stack[string]
    
    Show-MenuWithNavStack -MenuName "Menu Principal" -MenuContent {
        Write-Host "  1. Sous-menu 1"
        Write-Host "  2. Sous-menu 2"
        # ...
    }
}
```

### Historique avec métadonnées

```powershell
function Add-DetailedNavigationEntry {
    param(
        [string]$MenuName,
        [string]$Action,
        [hashtable]$Metadata = @{}
    )
    
    $entry = [PSCustomObject]@{
        Menu = $MenuName
        Action = $Action
        Timestamp = Get-Date
        User = $env:USERNAME
        Depth = $Global:NavigationStack.Count
        Metadata = $Metadata
    }
    
    $Global:MenuState.NavigationHistory += $entry
}

# Utilisation avec métadonnées
Add-DetailedNavigationEntry -MenuName "Gestion Serveurs" -Action "Enter" -Metadata @{
    SelectedServer = $serverName
    FilterActive = $true
}
```

> [!example] Cas d'usage avancés L'historique détaillé permet de :
> 
> - Générer des rapports d'utilisation
> - Identifier les menus les plus utilisés
> - Détecter des problèmes de navigation (boucles, abandons)
> - Créer des analytics sur l'expérience utilisateur

---

## 🎓 Pièges Courants et Solutions

### Piège 1 : Boucles infinies dans la navigation

```powershell
# ❌ MAUVAIS : Pas de condition de sortie claire
function Show-BadMenu {
    while ($true) {  # Boucle infinie !
        # ... menu sans option de sortie
    }
}

# ✅ BON : Condition de sortie explicite
function Show-GoodMenu {
    $continue = $true
    while ($continue) {
        # ... menu
        if ($choice -eq "0") {
            $continue = $false  # Sortie contrôlée
        }
    }
}
```

### Piège 2 : Perte du contexte lors de la navigation

```powershell
# ❌ MAUVAIS : Contexte perdu entre les menus
function Show-ServerMenu {
    $server = "SRV-001"  # Variable locale
    Show-ActionsMenu  # Le sous-menu n'a pas accès à $server
}

# ✅ BON : Transmission du contexte
function Show-ServerMenu {
    param([hashtable]$State)
    
    $State.Data.SelectedServer = "SRV-001"
    Show-ActionsMenu -State $State  # Contexte transmis
}
```

### Piège 3 : Breadcrumb incohérent

```powershell
# ❌ MAUVAIS : Breadcrumb construit avec des chaînes
function Show-SubMenu {
    param([string]$Path)
    $newPath = $Path + " > Sous-menu"  # Difficile à manipuler
}

# ✅ BON : Breadcrumb avec tableau
function Show-SubMenu {
    param([string[]]$PathArray)
    $newPath = $PathArray + @("Sous-menu")  # Facile à manipuler
}
```

---

## 💡 Astuces Professionnelles

### Astuce 1 : Template de menu réutilisable

```powershell
function Invoke-MenuTemplate {
    param(
        [string]$Title,
        [hashtable]$Options,
        [string[]]$PathArray,
        [switch]$IsRoot
    )
    
    $continue = $true
    
    while ($continue) {
        Clear-Host
        
        # Breadcrumb
        Write-Host "  📍 " -NoNewline
        Write-Host ($PathArray -join " > ") -ForegroundColor Yellow
        
        # En-tête
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "  $Title" -ForegroundColor White
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        
        # Options du menu
        foreach ($key in $Options.Keys | Sort-Object) {
            Write-Host "  $key. $($Options[$key].Label)" -ForegroundColor White
        }
        
        Write-Host ""
        if (-not $IsRoot) {
            Write-Host "  0. ← Retour" -ForegroundColor Yellow
        }
        Write-Host "  Q. Quitter" -ForegroundColor Red
        Write-Host ""
        
        $choice = Read-Host "Sélectionnez une option"
        
        if ($Options.ContainsKey($choice)) {
            & $Options[$choice].Action
        }
        elseif ($choice -eq "0" -and -not $IsRoot) {
            $continue = $false
        }
        elseif ($choice -eq "Q") {
            if (Confirm-Exit) {
                return "QUIT"
            }
        }
        else {
            Write-Host "Option invalide" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
    
    return "CONTINUE"
}

# Exemple d'utilisation du template
$userMenuOptions = @{
    "1" = @{
        Label = "Créer un utilisateur"
        Action = { Invoke-CreateUser }
    }
    "2" = @{
        Label = "Lister les utilisateurs"
        Action = { Invoke-ListUsers }
    }
}

Invoke-MenuTemplate -Title "Gestion Utilisateurs" -Options $userMenuOptions -PathArray @("Menu Principal", "Utilisateurs")
```

### Astuce 2 : Indicateurs visuels de profondeur

```powershell
function Get-DepthIndicator {
    param([int]$Depth)
    
    $indicators = @("🔵", "🟢", "🟡", "🟠", "🔴")
    $icon = $indicators[[Math]::Min($Depth, $indicators.Count - 1)]
    
    return "$icon Niveau $Depth"
}

# Utilisation dans un menu
function Show-MenuWithDepth {
    param([string[]]$PathArray)
    
    $depth = $PathArray.Count
    $indicator = Get-DepthIndicator -Depth $depth
    
    Write-Host "  $indicator" -ForegroundColor Gray
    Write-Host "  📍 $($PathArray -join ' > ')" -ForegroundColor Yellow
}
```

### Astuce 3 : Mémorisation de la dernière action

```powershell
function Show-MenuWithLastAction {
    param([hashtable]$State)
    
    Clear-Host
    
    # Affichage de la dernière action
    if ($State.LastAction) {
        $timeSince = (Get-Date) - $State.LastAction.Timestamp
        Write-Host "  ℹ Dernière action: $($State.LastAction.Action)" -ForegroundColor Cyan
        Write-Host "    Il y a $($timeSince.TotalSeconds.ToString('0')) secondes" -ForegroundColor Gray
        Write-Host ""
    }
    
    # ... reste du menu
}
```

### Astuce 4 : Navigation rapide par raccourcis

```powershell
# Table de raccourcis globaux
$Global:MenuShortcuts = @{
    "H" = @{ Target = "Home"; Description = "Retour à l'accueil" }
    "S" = @{ Target = "Settings"; Description = "Paramètres" }
    "?" = @{ Target = "Help"; Description = "Aide" }
}

function Show-MenuWithShortcuts {
    # ... affichage du menu normal
    
    Write-Host ""
    Write-Host "  Raccourcis: " -NoNewline -ForegroundColor DarkGray
    Write-Host "[H] Accueil  [S] Paramètres  [?] Aide" -ForegroundColor Gray
    Write-Host ""
    
    $choice = Read-Host "Sélectionnez une option"
    
    # Gestion des raccourcis
    if ($Global:MenuShortcuts.ContainsKey($choice)) {
        $shortcut = $Global:MenuShortcuts[$choice]
        switch ($shortcut.Target) {
            "Home" { return "GOTO_HOME" }
            "Settings" { Show-SettingsMenu }
            "Help" { Show-HelpMenu }
        }
    }
}
```

### Astuce 5 : Cache des données fréquemment utilisées

```powershell
# Système de cache pour éviter les rechargements
$Global:MenuCache = @{
    UserList = @{
        Data = $null
        LastRefresh = $null
        TTL = (New-TimeSpan -Minutes 5)
    }
    ServerList = @{
        Data = $null
        LastRefresh = $null
        TTL = (New-TimeSpan -Minutes 10)
    }
}

function Get-CachedData {
    param(
        [string]$CacheKey,
        [scriptblock]$RefreshScript
    )
    
    $cache = $Global:MenuCache[$CacheKey]
    
    # Vérifier si le cache est valide
    if ($cache.Data -and $cache.LastRefresh) {
        $age = (Get-Date) - $cache.LastRefresh
        if ($age -lt $cache.TTL) {
            Write-Host "  📦 Données en cache (fraîcheur: $($age.TotalMinutes.ToString('0.0')) min)" -ForegroundColor DarkGray
            return $cache.Data
        }
    }
    
    # Rafraîchir le cache
    Write-Host "  🔄 Chargement des données..." -ForegroundColor Yellow
    $cache.Data = & $RefreshScript
    $cache.LastRefresh = Get-Date
    
    return $cache.Data
}

# Utilisation
function Show-UserListMenu {
    $users = Get-CachedData -CacheKey "UserList" -RefreshScript {
        Get-ADUser -Filter * | Select-Object Name, SamAccountName
    }
    
    $users | Format-Table -AutoSize
}
```

### Astuce 6 : Recherche dans les menus

```powershell
function Add-MenuSearch {
    param(
        [array]$MenuItems
    )
    
    Write-Host "  🔍 Recherche: " -NoNewline -ForegroundColor Cyan
    $searchTerm = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($searchTerm)) {
        return $MenuItems
    }
    
    $filtered = $MenuItems | Where-Object { $_.Label -like "*$searchTerm*" }
    
    if ($filtered.Count -eq 0) {
        Write-Host "  ⚠ Aucun résultat pour '$searchTerm'" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        return $MenuItems
    }
    
    Write-Host "  ✓ $($filtered.Count) résultat(s) trouvé(s)" -ForegroundColor Green
    return $filtered
}
```

### Astuce 7 : Modes de débogage

```powershell
# Variable globale de débogage
$Global:MenuDebugMode = $false

function Write-MenuDebug {
    param(
        [string]$Message,
        [hashtable]$Data = @{}
    )
    
    if ($Global:MenuDebugMode) {
        Write-Host "[DEBUG] $Message" -ForegroundColor Magenta
        if ($Data.Count -gt 0) {
            $Data.GetEnumerator() | ForEach-Object {
                Write-Host "  - $($_.Key): $($_.Value)" -ForegroundColor DarkMagenta
            }
        }
    }
}

function Show-MenuWithDebug {
    param([string]$MenuName)
    
    Write-MenuDebug -Message "Entering menu: $MenuName" -Data @{
        StackDepth = $Global:NavigationStack.Count
        StateKeys = $Global:MenuState.Keys -join ", "
    }
    
    # ... logique du menu
    
    Write-MenuDebug -Message "Exiting menu: $MenuName"
}

# Activation/Désactivation du mode debug
function Enable-MenuDebug { $Global:MenuDebugMode = $true }
function Disable-MenuDebug { $Global:MenuDebugMode = $false }
```

---

## 📊 Exemple Complet : Système de Menus Professionnel

Voici un exemple complet intégrant tous les concepts abordés :

```powershell
# ═══════════════════════════════════════════════════════════════════
# INITIALISATION GLOBALE
# ═══════════════════════════════════════════════════════════════════

$Global:MenuState = @{
    CurrentUser = $env:USERNAME
    SessionStart = Get-Date
    LastAction = $null
    Settings = @{
        Theme = "Dark"
        Language = "FR"
        ShowDebug = $false
    }
    Data = @{
        SelectedServer = $null
        SelectedUser = $null
    }
    NavigationHistory = @()
}

$Global:NavigationStack = New-Object System.Collections.Generic.Stack[string]

# ═══════════════════════════════════════════════════════════════════
# FONCTIONS UTILITAIRES
# ═══════════════════════════════════════════════════════════════════

function Write-MenuHeader {
    param(
        [string]$Title,
        [string[]]$PathArray
    )
    
    Clear-Host
    
    # Breadcrumb
    if ($PathArray.Count -gt 0) {
        Write-Host "  📍 " -NoNewline
        for ($i = 0; $i -lt $PathArray.Count; $i++) {
            if ($i -eq $PathArray.Count - 1) {
                Write-Host $PathArray[$i] -ForegroundColor Yellow
            } else {
                Write-Host "$($PathArray[$i]) > " -NoNewline -ForegroundColor Gray
            }
        }
    }
    
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor White
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Write-MenuFooter {
    param([switch]$IsRoot)
    
    Write-Host ""
    if (-not $IsRoot) {
        Write-Host "  0. ← Retour" -ForegroundColor Yellow
    }
    Write-Host "  Q. ❌ Quitter" -ForegroundColor Red
    Write-Host ""
}

function Add-NavigationEntry {
    param(
        [string]$MenuName,
        [string]$Action
    )
    
    $Global:MenuState.NavigationHistory += [PSCustomObject]@{
        Menu = $MenuName
        Action = $Action
        Timestamp = Get-Date
        Depth = $Global:NavigationStack.Count
    }
    
    # Limiter l'historique à 100 entrées
    if ($Global:MenuState.NavigationHistory.Count -gt 100) {
        $Global:MenuState.NavigationHistory = $Global:MenuState.NavigationHistory[-100..-1]
    }
}

function Confirm-Exit {
    Write-Host ""
    Write-Host "  ⚠ Êtes-vous sûr de vouloir quitter ?" -ForegroundColor Yellow
    Write-Host "    Toutes les données non sauvegardées seront perdues." -ForegroundColor Gray
    Write-Host ""
    $response = Read-Host "  Confirmer (O/N)"
    return ($response -eq "O")
}

# ═══════════════════════════════════════════════════════════════════
# MENUS PRINCIPAUX
# ═══════════════════════════════════════════════════════════════════

function Show-MainMenu {
    $menuName = "Menu Principal"
    $pathArray = @($menuName)
    $Global:NavigationStack.Push($menuName)
    Add-NavigationEntry -MenuName $menuName -Action "Enter"
    
    $continue = $true
    
    while ($continue) {
        Write-MenuHeader -Title $menuName -PathArray $pathArray
        
        # Informations de session
        $sessionDuration = (Get-Date) - $Global:MenuState.SessionStart
        Write-Host "  👤 Utilisateur: $($Global:MenuState.CurrentUser)" -ForegroundColor Gray
        Write-Host "  ⏱ Durée de session: $($sessionDuration.ToString('hh\:mm\:ss'))" -ForegroundColor Gray
        Write-Host ""
        
        # Options du menu
        Write-Host "  1. 👥 Gestion des Utilisateurs" -ForegroundColor White
        Write-Host "  2. 🖥 Gestion des Serveurs" -ForegroundColor White
        Write-Host "  3. 📊 Rapports et Statistiques" -ForegroundColor White
        Write-Host "  4. ⚙ Configuration" -ForegroundColor White
        Write-Host "  5. 📜 Historique de navigation" -ForegroundColor White
        
        Write-MenuFooter -IsRoot
        
        $choice = Read-Host "Sélectionnez une option"
        
        switch ($choice) {
            "1" { 
                $result = Show-UserMenu -ParentPath $pathArray
                if ($result -eq "QUIT") { $continue = $false }
            }
            "2" { 
                $result = Show-ServerMenu -ParentPath $pathArray
                if ($result -eq "QUIT") { $continue = $false }
            }
            "3" { 
                $result = Show-ReportMenu -ParentPath $pathArray
                if ($result -eq "QUIT") { $continue = $false }
            }
            "4" { 
                $result = Show-ConfigMenu -ParentPath $pathArray
                if ($result -eq "QUIT") { $continue = $false }
            }
            "5" {
                Show-NavigationHistory
            }
            "Q" {
                if (Confirm-Exit) {
                    $continue = $false
                }
            }
            default {
                Write-Host "  ❌ Option invalide" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
    
    Add-NavigationEntry -MenuName $menuName -Action "Exit"
    $Global:NavigationStack.Pop() | Out-Null
    
    return "QUIT"
}

function Show-UserMenu {
    param([string[]]$ParentPath)
    
    $menuName = "Gestion Utilisateurs"
    $pathArray = $ParentPath + @($menuName)
    $Global:NavigationStack.Push($menuName)
    Add-NavigationEntry -MenuName $menuName -Action "Enter"
    
    $continue = $true
    
    while ($continue) {
        Write-MenuHeader -Title $menuName -PathArray $pathArray
        
        # Affichage du contexte
        if ($Global:MenuState.Data.SelectedUser) {
            Write-Host "  📌 Utilisateur sélectionné: $($Global:MenuState.Data.SelectedUser)" -ForegroundColor Cyan
            Write-Host ""
        }
        
        Write-Host "  1. ➕ Créer un utilisateur" -ForegroundColor White
        Write-Host "  2. ✏ Modifier un utilisateur" -ForegroundColor White
        Write-Host "  3. 🗑 Supprimer un utilisateur" -ForegroundColor White
        Write-Host "  4. 📋 Lister les utilisateurs" -ForegroundColor White
        Write-Host "  5. 🔐 Permissions avancées ➜" -ForegroundColor Magenta
        
        Write-MenuFooter
        
        $choice = Read-Host "Sélectionnez une option"
        
        switch ($choice) {
            "1" {
                Write-Host "`n  ✓ Création d'utilisateur simulée" -ForegroundColor Green
                Read-Host "  Appuyez sur Entrée pour continuer"
            }
            "2" {
                Write-Host "`n  ✓ Modification d'utilisateur simulée" -ForegroundColor Green
                Read-Host "  Appuyez sur Entrée pour continuer"
            }
            "3" {
                Write-Host "`n  ✓ Suppression d'utilisateur simulée" -ForegroundColor Green
                Read-Host "  Appuyez sur Entrée pour continuer"
            }
            "4" {
                Write-Host "`n  Liste des utilisateurs (simulée)" -ForegroundColor Cyan
                Write-Host "  - User1, User2, User3..." -ForegroundColor Gray
                Read-Host "  Appuyez sur Entrée pour continuer"
            }
            "5" {
                $result = Show-PermissionsMenu -ParentPath $pathArray
                if ($result -eq "QUIT") { 
                    $continue = $false 
                    $returnValue = "QUIT"
                }
            }
            "0" {
                $continue = $false
            }
            "Q" {
                if (Confirm-Exit) {
                    $continue = $false
                    $returnValue = "QUIT"
                }
            }
            default {
                Write-Host "  ❌ Option invalide" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
    
    Add-NavigationEntry -MenuName $menuName -Action "Exit"
    $Global:NavigationStack.Pop() | Out-Null
    
    return if ($returnValue -eq "QUIT") { "QUIT" } else { "CONTINUE" }
}

function Show-PermissionsMenu {
    param([string[]]$ParentPath)
    
    $menuName = "Permissions Avancées"
    $pathArray = $ParentPath + @($menuName)
    $Global:NavigationStack.Push($menuName)
    Add-NavigationEntry -MenuName $menuName -Action "Enter"
    
    $continue = $true
    
    while ($continue) {
        Write-MenuHeader -Title $menuName -PathArray $pathArray
        
        # Indicateur de profondeur
        $depth = $pathArray.Count
        Write-Host "  🔵 Niveau de profondeur: $depth" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "  1. 👥 Gérer les groupes" -ForegroundColor White
        Write-Host "  2. 🎭 Gérer les rôles" -ForegroundColor White
        Write-Host "  3. 🔍 Audit des permissions" -ForegroundColor White
        
        Write-MenuFooter
        
        $choice = Read-Host "Sélectionnez une option"
        
        switch ($choice) {
            "1" {
                Write-Host "`n  ✓ Gestion des groupes (simulée)" -ForegroundColor Green
                Read-Host "  Appuyez sur Entrée pour continuer"
            }
            "2" {
                Write-Host "`n  ✓ Gestion des rôles (simulée)" -ForegroundColor Green
                Read-Host "  Appuyez sur Entrée pour continuer"
            }
            "3" {
                Write-Host "`n  ✓ Audit lancé (simulé)" -ForegroundColor Green
                Read-Host "  Appuyez sur Entrée pour continuer"
            }
            "0" {
                $continue = $false
            }
            "Q" {
                if (Confirm-Exit) {
                    $continue = $false
                    $returnValue = "QUIT"
                }
            }
            default {
                Write-Host "  ❌ Option invalide" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
    
    Add-NavigationEntry -MenuName $menuName -Action "Exit"
    $Global:NavigationStack.Pop() | Out-Null
    
    return if ($returnValue -eq "QUIT") { "QUIT" } else { "CONTINUE" }
}

function Show-ServerMenu {
    param([string[]]$ParentPath)
    
    $menuName = "Gestion Serveurs"
    $pathArray = $ParentPath + @($menuName)
    $Global:NavigationStack.Push($menuName)
    Add-NavigationEntry -MenuName $menuName -Action "Enter"
    
    $continue = $true
    
    while ($continue) {
        Write-MenuHeader -Title $menuName -PathArray $pathArray
        
        Write-Host "  1. 📡 État des serveurs" -ForegroundColor White
        Write-Host "  2. 🔄 Redémarrer un serveur" -ForegroundColor White
        Write-Host "  3. 📊 Métriques" -ForegroundColor White
        
        Write-MenuFooter
        
        $choice = Read-Host "Sélectionnez une option"
        
        switch ($choice) {
            "1" {
                Write-Host "`n  📊 État simulé des serveurs" -ForegroundColor Cyan
                Read-Host "  Appuyez sur Entrée pour continuer"
            }
            "2" {
                Write-Host "`n  🔄 Redémarrage simulé" -ForegroundColor Yellow
                Read-Host "  Appuyez sur Entrée pour continuer"
            }
            "3" {
                Write-Host "`n  📈 Métriques affichées (simulé)" -ForegroundColor Cyan
                Read-Host "  Appuyez sur Entrée pour continuer"
            }
            "0" {
                $continue = $false
            }
            "Q" {
                if (Confirm-Exit) {
                    $continue = $false
                    $returnValue = "QUIT"
                }
            }
            default {
                Write-Host "  ❌ Option invalide" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
    
    Add-NavigationEntry -MenuName $menuName -Action "Exit"
    $Global:NavigationStack.Pop() | Out-Null
    
    return if ($returnValue -eq "QUIT") { "QUIT" } else { "CONTINUE" }
}

function Show-ReportMenu {
    param([string[]]$ParentPath)
    
    Write-Host "`n  📊 Menu Rapports (non implémenté)" -ForegroundColor Gray
    Read-Host "  Appuyez sur Entrée pour continuer"
    return "CONTINUE"
}

function Show-ConfigMenu {
    param([string[]]$ParentPath)
    
    Write-Host "`n  ⚙ Menu Configuration (non implémenté)" -ForegroundColor Gray
    Read-Host "  Appuyez sur Entrée pour continuer"
    return "CONTINUE"
}

function Show-NavigationHistory {
    Clear-Host
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  📜 Historique de Navigation" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $history = $Global:MenuState.NavigationHistory | Select-Object -Last 20
    
    if ($history.Count -eq 0) {
        Write-Host "  Aucun historique disponible" -ForegroundColor Gray
    } else {
        foreach ($entry in $history) {
            $time = $entry.Timestamp.ToString("HH:mm:ss")
            $icon = if ($entry.Action -eq "Enter") { "➜" } else { "←" }
            $color = if ($entry.Action -eq "Enter") { "Green" } else { "Yellow"
            $indent = "  " * $entry.Depth
            
            Write-Host "  [$time] " -NoNewline -ForegroundColor Gray
            Write-Host "$icon " -NoNewline -ForegroundColor $color
            Write-Host "$indent$($entry.Menu)" -ForegroundColor White
        }
    }
    
    Write-Host ""
    Write-Host "  💡 Les 20 dernières navigations sont affichées" -ForegroundColor DarkGray
    Write-Host ""
    Read-Host "  Appuyez sur Entrée pour continuer"
}

# ═══════════════════════════════════════════════════════════════════
# POINT D'ENTRÉE
# ═══════════════════════════════════════════════════════════════════

function Start-MenuSystem {
    Write-Host ""
    Write-Host "  🚀 Démarrage du système de menus..." -ForegroundColor Cyan
    Start-Sleep -Seconds 1
    
    Show-MainMenu
    
    Clear-Host
    Write-Host ""
    Write-Host "  👋 Au revoir $($Global:MenuState.CurrentUser) !" -ForegroundColor Green
    Write-Host "  ⏱ Durée de session: $((Get-Date) - $Global:MenuState.SessionStart | Select-Object -ExpandProperty ToString('hh\:mm\:ss'))" -ForegroundColor Gray
    Write-Host ""
}

# Lancement du système
Start-MenuSystem
```

---

## 🎯 Points Clés à Retenir

> [!tip] Les 10 Commandements des Menus Multi-niveaux
> 
> 1. **Toujours** fournir une option de retour claire
> 2. **Transmettre** le contexte via des paramètres ou un état global
> 3. **Construire** le breadcrumb progressivement avec des tableaux
> 4. **Gérer** la propagation du signal "QUIT" vers le haut
> 5. **Limiter** la profondeur à 4-5 niveaux maximum
> 6. **Enregistrer** l'historique pour le débogage et l'analytics
> 7. **Utiliser** une pile (Stack) pour la navigation
> 8. **Valider** toutes les entrées utilisateur
> 9. **Confirmer** les actions destructives ou la sortie
> 10. **Maintenir** une structure cohérente entre tous les menus

---

## 📐 Architecture Recommandée

```
📦 Système de Menus Multi-niveaux
 ┣ 📂 État Global
 ┃ ┣ NavigationStack (pile)
 ┃ ┣ MenuState (hashtable)
 ┃ ┗ NavigationHistory (array)
 ┃
 ┣ 📂 Fonctions Utilitaires
 ┃ ┣ Write-MenuHeader
 ┃ ┣ Write-MenuFooter
 ┃ ┣ Write-Breadcrumb
 ┃ ┣ Add-NavigationEntry
 ┃ ┗ Confirm-Exit
 ┃
 ┣ 📂 Menus (Niveau 1)
 ┃ ┣ Show-MainMenu
 ┃ ┣ Show-UserMenu
 ┃ ┣ Show-ServerMenu
 ┃ ┗ Show-ConfigMenu
 ┃
 ┣ 📂 Sous-menus (Niveau 2+)
 ┃ ┣ Show-PermissionsMenu
 ┃ ┣ Show-RolesMenu
 ┃ ┗ Show-AuditMenu
 ┃
 ┗ 📂 Point d'Entrée
   ┗ Start-MenuSystem
```

---

## ✨ Conclusion

Les menus multi-niveaux sont une technique essentielle pour créer des interfaces PowerShell professionnelles et maintenables. En maîtrisant les concepts de navigation récursive, de gestion d'état, de breadcrumb et d'historique, vous pouvez créer des scripts qui rivalisent avec des applications graphiques en termes d'expérience utilisateur.

La clé du succès réside dans :

- Une **structure cohérente** à tous les niveaux
- Une **gestion rigoureuse** de l'état et du contexte
- Une **navigation intuitive** avec des indices visuels clairs
- Un **code modulaire** facile à maintenir et à étendre

Avec ces fondations solides, vous pouvez créer des systèmes de menus capables de gérer des dizaines de fonctionnalités tout en restant agréables à utiliser.