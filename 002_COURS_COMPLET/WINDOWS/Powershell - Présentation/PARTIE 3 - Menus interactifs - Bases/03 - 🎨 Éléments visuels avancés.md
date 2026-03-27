

> [!info] Objectif de cette partie Maîtriser les techniques d'affichage avancées pour créer des scripts PowerShell professionnels et informatifs : barres de progression, indicateurs de statut, animations et messages de confirmation stylisés.

---

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

## Barres de progression avec Write-Progress

### 🎯 Pourquoi utiliser Write-Progress ?

Les barres de progression sont essentielles pour :

- **Informer l'utilisateur** de l'avancement d'une tâche longue
- **Éviter l'impression de blocage** lors d'opérations qui prennent du temps
- **Donner une estimation** du temps restant
- **Améliorer l'expérience utilisateur** avec un retour visuel professionnel

> [!tip] Quand l'utiliser ? Dès qu'une opération prend plus de 3-5 secondes, ou lors de traitements en boucle (fichiers, utilisateurs, etc.).

### 📐 Syntaxe de base

```powershell
Write-Progress -Activity "Description de l'activité" `
               -Status "État actuel" `
               -PercentComplete 50
```

#### Paramètres principaux

|Paramètre|Type|Description|
|---|---|---|
|`-Activity`|String|Titre principal de la barre (obligatoire)|
|`-Status`|String|Message de statut détaillé|
|`-PercentComplete`|Int (0-100)|Pourcentage d'avancement|
|`-CurrentOperation`|String|Opération en cours (sous le statut)|
|`-SecondsRemaining`|Int|Temps restant estimé en secondes|
|`-Id`|Int|Identifiant unique (pour barres multiples)|
|`-ParentId`|Int|ID du parent (pour barres imbriquées)|
|`-Completed`|Switch|Ferme/masque la barre de progression|

### 💡 Exemple simple - Traitement de fichiers

```powershell
# Récupérer une liste de fichiers
$fichiers = Get-ChildItem -Path "C:\Logs" -Filter "*.log"
$total = $fichiers.Count
$compteur = 0

foreach ($fichier in $fichiers) {
    $compteur++
    
    # Calculer le pourcentage
    $pourcentage = ($compteur / $total) * 100
    
    # Afficher la progression
    Write-Progress -Activity "Traitement des fichiers logs" `
                   -Status "Fichier $compteur sur $total : $($fichier.Name)" `
                   -PercentComplete $pourcentage `
                   -CurrentOperation "Analyse en cours..."
    
    # Simuler un traitement
    Start-Sleep -Milliseconds 500
}

# Fermer la barre de progression
Write-Progress -Activity "Traitement des fichiers logs" -Completed
```

### 🔄 Barres de progression imbriquées

Pour des opérations à plusieurs niveaux, utilisez des IDs différents :

```powershell
$dossiers = Get-ChildItem -Path "C:\Data" -Directory
$totalDossiers = $dossiers.Count
$compteurDossier = 0

foreach ($dossier in $dossiers) {
    $compteurDossier++
    $pctDossier = ($compteurDossier / $totalDossiers) * 100
    
    # Barre principale (ID 0)
    Write-Progress -Id 0 `
                   -Activity "Analyse des dossiers" `
                   -Status "Dossier $compteurDossier/$totalDossiers : $($dossier.Name)" `
                   -PercentComplete $pctDossier
    
    # Traiter les fichiers dans ce dossier
    $fichiers = Get-ChildItem -Path $dossier.FullName -File
    $totalFichiers = $fichiers.Count
    $compteurFichier = 0
    
    foreach ($fichier in $fichiers) {
        $compteurFichier++
        $pctFichier = ($compteurFichier / $totalFichiers) * 100
        
        # Barre secondaire (ID 1, ParentId 0)
        Write-Progress -Id 1 `
                       -ParentId 0 `
                       -Activity "Traitement des fichiers" `
                       -Status "Fichier $compteurFichier/$totalFichiers" `
                       -PercentComplete $pctFichier
        
        # Traitement du fichier
        Start-Sleep -Milliseconds 200
    }
    
    # Fermer la barre secondaire
    Write-Progress -Id 1 -Completed
}

# Fermer la barre principale
Write-Progress -Id 0 -Completed
```

### ⏱️ Estimation du temps restant

```powershell
$items = 1..100
$total = $items.Count
$debut = Get-Date

for ($i = 0; $i -lt $total; $i++) {
    # Calculer le temps écoulé et estimer le temps restant
    $tempsEcoule = (Get-Date) - $debut
    $tempsParItem = $tempsEcoule.TotalSeconds / ($i + 1)
    $itemsRestants = $total - ($i + 1)
    $tempsRestant = [int]($tempsParItem * $itemsRestants)
    
    Write-Progress -Activity "Traitement des éléments" `
                   -Status "Élément $($i+1) sur $total" `
                   -PercentComplete (($i + 1) / $total * 100) `
                   -SecondsRemaining $tempsRestant
    
    # Simuler un traitement
    Start-Sleep -Milliseconds 100
}

Write-Progress -Activity "Traitement des éléments" -Completed
```

> [!warning] Pièges courants
> 
> - **Oublier `-Completed`** : La barre reste affichée même après la fin du script
> - **Calculs incorrects** : Vérifier que le pourcentage est entre 0 et 100
> - **Trop d'appels** : Dans des boucles très rapides, limiter les mises à jour (ex: tous les 10 items)
> - **Division par zéro** : Toujours vérifier que `$total` n'est pas zéro

> [!tip] Optimisation pour les grandes boucles
> 
> ```powershell
> # Mettre à jour seulement tous les 10 éléments
> if ($compteur % 10 -eq 0 -or $compteur -eq $total) {
>     Write-Progress -Activity "..." -PercentComplete (...)
> }
> ```

---

## Indicateurs de statut

### 🎯 Pourquoi utiliser des indicateurs visuels ?

Les indicateurs de statut permettent de :

- **Communiquer rapidement** le résultat d'une opération
- **Améliorer la lisibilité** des logs et résultats
- **Standardiser l'affichage** des succès/échecs/avertissements
- **Rendre le script plus professionnel**

### ✅ Symboles Unicode courants

```powershell
# Définir les symboles comme constantes
$symboles = @{
    Succes      = [char]0x2713  # ✓
    Echec       = [char]0x2717  # ✗
    Avertissement = [char]0x26A0  # ⚠
    Info        = [char]0x1F6C8  # 🛈
    Fleche      = [char]0x27A4  # ➤
    Horloge     = [char]0x23F1  # ⏱
    Engrenage   = [char]0x2699  # ⚙
    Etoile      = [char]0x2605  # ★
    Coche       = [char]0x2611  # ☑
    Croix       = [char]0x2612  # ☒
}

# Exemples d'utilisation
Write-Host "$($symboles.Succes) Opération réussie" -ForegroundColor Green
Write-Host "$($symboles.Echec) Opération échouée" -ForegroundColor Red
Write-Host "$($symboles.Avertissement) Attention requise" -ForegroundColor Yellow
```

### 🎨 Fonction d'affichage de statut

```powershell
function Write-Status {
    <#
    .SYNOPSIS
    Affiche un message avec un indicateur de statut coloré
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Success','Error','Warning','Info','Processing')]
        [string]$Type,
        
        [switch]$NoNewLine
    )
    
    # Définir les symboles et couleurs
    $config = @{
        Success = @{
            Symbole = [char]0x2713
            Couleur = 'Green'
        }
        Error = @{
            Symbole = [char]0x2717
            Couleur = 'Red'
        }
        Warning = @{
            Symbole = [char]0x26A0
            Couleur = 'Yellow'
        }
        Info = @{
            Symbole = [char]0x1F6C8
            Couleur = 'Cyan'
        }
        Processing = @{
            Symbole = [char]0x2699
            Couleur = 'Gray'
        }
    }
    
    $setup = $config[$Type]
    
    # Afficher avec couleur
    Write-Host "$($setup.Symbole) " -ForegroundColor $setup.Couleur -NoNewline
    
    if ($NoNewLine) {
        Write-Host $Message -NoNewline
    } else {
        Write-Host $Message
    }
}

# Exemples d'utilisation
Write-Status -Message "Connexion établie avec succès" -Type Success
Write-Status -Message "Fichier introuvable" -Type Error
Write-Status -Message "Espace disque faible" -Type Warning
Write-Status -Message "Démarrage du traitement..." -Type Info
Write-Status -Message "Traitement en cours" -Type Processing
```

### 📊 Tableau de résultats avec indicateurs

```powershell
function Show-ResultTable {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Results
    )
    
    $symboles = @{
        OK = [char]0x2713
        KO = [char]0x2717
    }
    
    Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host "  RÉSULTATS DE L'OPÉRATION" -NoNewline -ForegroundColor White
    Write-Host (" " * 32) -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╠═══════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
    
    foreach ($result in $Results) {
        $symbole = if ($result.Success) { $symboles.OK } else { $symboles.KO }
        $couleur = if ($result.Success) { 'Green' } else { 'Red' }
        
        Write-Host "║ " -NoNewline -ForegroundColor Cyan
        Write-Host $symbole -NoNewline -ForegroundColor $couleur
        Write-Host " $($result.Item.PadRight(52))" -NoNewline
        Write-Host "║" -ForegroundColor Cyan
    }
    
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

# Exemple d'utilisation
$resultats = @(
    @{Item = "Copie des fichiers"; Success = $true}
    @{Item = "Vérification des permissions"; Success = $true}
    @{Item = "Connexion à la base de données"; Success = $false}
    @{Item = "Nettoyage des logs"; Success = $true}
)

Show-ResultTable -Results $resultats
```

> [!example] Indicateurs contextuels
> 
> ```powershell
> # Afficher un indicateur selon la valeur
> $usage = 85
> $indicateur = switch ($usage) {
>     {$_ -lt 50} { [char]0x2713; 'Green' }
>     {$_ -ge 50 -and $_ -lt 80} { [char]0x26A0; 'Yellow' }
>     default { [char]0x2717; 'Red' }
> }
> Write-Host "$($indicateur[0]) Utilisation disque : $usage%" -ForegroundColor $indicateur[1]
> ```

> [!warning] Compatibilité des symboles Unicode
> 
> - Tous les symboles Unicode ne s'affichent pas dans toutes les consoles
> - Tester sur PowerShell classique ET Windows Terminal
> - Prévoir des alternatives ASCII si nécessaire : `+`, `-`, `!`, `*`

---

## Animations simples

### 🎯 Pourquoi utiliser des animations ?

Les animations apportent :

- **Un retour visuel dynamique** pendant les opérations longues
- **L'impression d'activité** au lieu d'un blocage
- **Une touche de professionnalisme** et de modernité
- **Une alternative** aux barres de progression pour les durées indéterminées

> [!info] Quand privilégier les animations ?
> 
> - Lorsque la durée de l'opération est **inconnue**
> - Pour des tâches de **connexion ou d'attente réseau**
> - Pendant des **traitements asynchrones**
> - Quand l'espace d'affichage est **limité**

### 🔄 Spinner rotatif

```powershell
function Show-Spinner {
    <#
    .SYNOPSIS
    Affiche un spinner animé pendant l'exécution d'un script block
    #>
    param(
        [Parameter(Mandatory=$true)]
        [ScriptBlock]$ScriptBlock,
        
        [string]$Message = "Traitement en cours",
        
        [ValidateSet('Line','Dots','Arrow','Star','Circle')]
        [string]$Style = 'Line'
    )
    
    # Définir les différents styles de spinner
    $spinners = @{
        Line   = @('|', '/', '-', '\')
        Dots   = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
        Arrow  = @('←', '↖', '↑', '↗', '→', '↘', '↓', '↙')
        Star   = @('✶', '✸', '✹', '✺', '✹', '✷')
        Circle = @('◐', '◓', '◑', '◒')
    }
    
    $frames = $spinners[$Style]
    $index = 0
    
    # Créer un job pour exécuter le script en arrière-plan
    $job = Start-Job -ScriptBlock $ScriptBlock
    
    # Masquer le curseur
    [Console]::CursorVisible = $false
    
    try {
        # Animer tant que le job n'est pas terminé
        while ($job.State -eq 'Running') {
            $frame = $frames[$index % $frames.Count]
            
            # Afficher le spinner (écraser la ligne)
            Write-Host "`r$frame $Message" -NoNewline -ForegroundColor Cyan
            
            Start-Sleep -Milliseconds 100
            $index++
        }
        
        # Effacer la ligne du spinner
        Write-Host "`r$(' ' * ($Message.Length + 5))`r" -NoNewline
        
        # Récupérer le résultat
        $result = Receive-Job -Job $job -Wait
        Remove-Job -Job $job
        
        return $result
        
    } finally {
        # Réafficher le curseur
        [Console]::CursorVisible = $true
    }
}

# Exemple d'utilisation
$resultat = Show-Spinner -Message "Connexion au serveur..." -Style Dots -ScriptBlock {
    Start-Sleep -Seconds 3
    return "Connexion établie"
}

Write-Host "✓ $resultat" -ForegroundColor Green
```

### ⏳ Animation de points de suspension

```powershell
function Show-LoadingDots {
    param(
        [Parameter(Mandatory=$true)]
        [ScriptBlock]$ScriptBlock,
        
        [string]$Message = "Chargement",
        
        [int]$MaxDots = 3
    )
    
    $job = Start-Job -ScriptBlock $ScriptBlock
    $dotCount = 0
    
    [Console]::CursorVisible = $false
    
    try {
        while ($job.State -eq 'Running') {
            $dots = '.' * ($dotCount % ($MaxDots + 1))
            $spaces = ' ' * ($MaxDots - ($dotCount % ($MaxDots + 1)))
            
            Write-Host "`r$Message$dots$spaces" -NoNewline -ForegroundColor Yellow
            
            Start-Sleep -Milliseconds 400
            $dotCount++
        }
        
        Write-Host "`r$(' ' * ($Message.Length + $MaxDots + 2))`r" -NoNewline
        
        $result = Receive-Job -Job $job -Wait
        Remove-Job -Job $job
        
        return $result
        
    } finally {
        [Console]::CursorVisible = $true
    }
}

# Exemple
$data = Show-LoadingDots -Message "Récupération des données" -ScriptBlock {
    Start-Sleep -Seconds 5
    return Get-Process | Select-Object -First 10
}
```

### 🌊 Barre de progression ASCII animée

```powershell
function Show-ProgressBar {
    param(
        [int]$Total,
        [int]$Current,
        [int]$BarLength = 40,
        [char]$CompletedChar = '█',
        [char]$RemainingChar = '░'
    )
    
    $percent = [math]::Round(($Current / $Total) * 100)
    $completed = [math]::Round(($Current / $Total) * $BarLength)
    $remaining = $BarLength - $completed
    
    $bar = ($CompletedChar.ToString() * $completed) + ($RemainingChar.ToString() * $remaining)
    
    Write-Host "`r[$bar] $percent% ($Current/$Total)" -NoNewline
    
    if ($Current -eq $Total) {
        Write-Host ""  # Nouvelle ligne à la fin
    }
}

# Exemple d'utilisation
Write-Host "Téléchargement en cours :" -ForegroundColor Cyan
for ($i = 1; $i -le 50; $i++) {
    Show-ProgressBar -Total 50 -Current $i
    Start-Sleep -Milliseconds 100
}
Write-Host "✓ Téléchargement terminé!" -ForegroundColor Green
```

### 🎭 Animation de transition

```powershell
function Show-Transition {
    param(
        [string]$FromText,
        [string]$ToText,
        [int]$Steps = 10
    )
    
    [Console]::CursorVisible = $false
    
    try {
        # Fondu sortant
        for ($i = $Steps; $i -ge 0; $i--) {
            $opacity = [char](0x2591 + ($i % 3))  # ░ ▒ ▓
            Write-Host "`r$FromText $($opacity * 3)" -NoNewline
            Start-Sleep -Milliseconds 50
        }
        
        # Effacer
        Write-Host "`r$(' ' * ($FromText.Length + 5))`r" -NoNewline
        Start-Sleep -Milliseconds 200
        
        # Fondu entrant
        for ($i = 0; $i -le $Steps; $i++) {
            $opacity = [char](0x2593 - ($i % 3))  # ▓ ▒ ░
            Write-Host "`r$ToText $($opacity * 3)" -NoNewline
            Start-Sleep -Milliseconds 50
        }
        
        Write-Host "`r$ToText      "
        
    } finally {
        [Console]::CursorVisible = $true
    }
}

# Exemple
Show-Transition -FromText "Initialisation..." -ToText "✓ Système prêt"
```

> [!tip] Performances des animations
> 
> - Limiter la fréquence de rafraîchissement (100-400ms minimum)
> - Utiliser `Write-Host` avec `-NoNewline` et `\r` pour écraser la ligne
> - Masquer le curseur avec `[Console]::CursorVisible = $false`
> - Toujours restaurer le curseur dans un bloc `finally`

> [!warning] Limitations
> 
> - Les animations consomment des ressources CPU (légèrement)
> - Peuvent causer des problèmes dans les scripts automatisés ou les logs
> - Ne fonctionnent pas bien dans PowerShell ISE (utiliser Windows Terminal)
> - Éviter dans les scripts destinés à être exécutés en arrière-plan

---

## Messages de confirmation stylisés

### 🎯 Pourquoi soigner les confirmations ?

Les messages de confirmation sont cruciaux pour :

- **Prévenir les erreurs** en demandant une validation explicite
- **Clarifier les conséquences** d'une action avant son exécution
- **Améliorer la confiance** de l'utilisateur dans le script
- **Respecter les bonnes pratiques** d'interaction utilisateur

### ✋ Confirmation basique avec Read-Host

```powershell
function Request-Confirmation {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [string]$DefaultChoice = 'N'
    )
    
    $choices = if ($DefaultChoice -eq 'Y') { '[O/n]' } else { '[o/N]' }
    
    Write-Host "`n⚠ " -NoNewline -ForegroundColor Yellow
    Write-Host $Message -ForegroundColor White
    $reponse = Read-Host "   Continuer ? $choices"
    
    if ([string]::IsNullOrWhiteSpace($reponse)) {
        $reponse = $DefaultChoice
    }
    
    return ($reponse -match '^[oO]$')
}

# Exemple d'utilisation
if (Request-Confirmation -Message "Cette action va supprimer 150 fichiers") {
    Write-Host "✓ Action confirmée" -ForegroundColor Green
    # Exécuter l'action
} else {
    Write-Host "✗ Action annulée" -ForegroundColor Red
    return
}
```

### 🎨 Confirmation encadrée stylisée

```powershell
function Show-ConfirmationBox {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Title,
        
        [Parameter(Mandatory=$true)]
        [string[]]$Messages,
        
        [ValidateSet('Warning','Danger','Info')]
        [string]$Type = 'Warning',
        
        [string]$DefaultChoice = 'N'
    )
    
    # Configurer les couleurs selon le type
    $config = @{
        Warning = @{ Color = 'Yellow'; Icon = '⚠' }
        Danger  = @{ Color = 'Red'; Icon = '⚡' }
        Info    = @{ Color = 'Cyan'; Icon = 'ℹ' }
    }
    
    $setup = $config[$Type]
    $color = $setup.Color
    $icon = $setup.Icon
    
    # Calculer la largeur de la boîte
    $maxLength = ($Messages | Measure-Object -Property Length -Maximum).Maximum
    $width = [math]::Max($maxLength, $Title.Length) + 4
    $width = [math]::Max($width, 50)
    
    # Afficher la boîte
    Write-Host ""
    Write-Host "╔$('═' * $width)╗" -ForegroundColor $color
    Write-Host "║ $icon " -NoNewline -ForegroundColor $color
    Write-Host $Title.PadRight($width - 3) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor $color
    Write-Host "╠$('═' * $width)╣" -ForegroundColor $color
    
    foreach ($msg in $Messages) {
        Write-Host "║ " -NoNewline -ForegroundColor $color
        Write-Host $msg.PadRight($width - 1) -NoNewline -ForegroundColor Gray
        Write-Host "║" -ForegroundColor $color
    }
    
    Write-Host "╚$('═' * $width)╝" -ForegroundColor $color
    Write-Host ""
    
    # Demander confirmation
    $choices = if ($DefaultChoice -eq 'Y') { '[O/n]' } else { '[o/N]' }
    Write-Host "Confirmer l'action ? $choices : " -NoNewline -ForegroundColor White
    
    $reponse = Read-Host
    if ([string]::IsNullOrWhiteSpace($reponse)) {
        $reponse = $DefaultChoice
    }
    
    return ($reponse -match '^[oO]$')
}

# Exemple d'utilisation
$confirmation = Show-ConfirmationBox -Title "SUPPRESSION DE FICHIERS" `
    -Type Danger `
    -Messages @(
        "Action : Supprimer tous les fichiers temporaires",
        "Cible : C:\Temp\*.*",
        "Nombre de fichiers : 1,247",
        "Espace libéré : 3.2 GB"
    )

if ($confirmation) {
    Write-Host "✓ Opération confirmée - Démarrage..." -ForegroundColor Green
} else {
    Write-Host "✗ Opération annulée par l'utilisateur" -ForegroundColor Yellow
}
```

### 🔐 Confirmation avec code de sécurité

Pour les actions critiques, demander un code spécifique :

```powershell
function Request-SecureConfirmation {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Action,
        
        [string]$RequiredCode,
        
        [int]$MaxAttempts = 3
    )
    
    # Générer un code aléatoire si non fourni
    if ([string]::IsNullOrEmpty($RequiredCode)) {
        $RequiredCode = -join ((65..90) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
    }
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║ ⚡ " -NoNewline -ForegroundColor Red
    Write-Host "ACTION CRITIQUE - CONFIRMATION REQUISE" -NoNewline -ForegroundColor White
    Write-Host "          ║" -ForegroundColor Red
    Write-Host "╠════════════════════════════════════════════════════╣" -ForegroundColor Red
    Write-Host "║ " -NoNewline -ForegroundColor Red
    Write-Host $Action.PadRight(51) -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Red
    Write-Host "╠════════════════════════════════════════════════════╣" -ForegroundColor Red
    Write-Host "║ Pour confirmer, tapez le code : " -NoNewline -ForegroundColor Red
    Write-Host $RequiredCode -NoNewline -ForegroundColor Green
    Write-Host (" " * (51 - 33 - $RequiredCode.Length)) -NoNewline
    Write-Host "║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    
    $attempts = 0
    
    while ($attempts -lt $MaxAttempts) {
        $attempts++
        $remaining = $MaxAttempts - $attempts
        
        Write-Host "Code de confirmation " -NoNewline
        Write-Host "($remaining tentative(s) restante(s))" -NoNewline -ForegroundColor Gray
        Write-Host " : " -NoNewline
        $input = Read-Host
        
        if ($input -ceq $RequiredCode) {
            Write-Host "✓ Code correct - Action autorisée" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Code incorrect" -ForegroundColor Red
        }
    }
    
    Write-Host "`n✗ Nombre maximum de tentatives atteint - Action refusée" -ForegroundColor Red
    return $false
}

# Exemple d'utilisation
if (Request-SecureConfirmation -Action "Suppression définitive de la base de données PROD") {
    Write-Host "Exécution de l'action..." -ForegroundColor Yellow
    # Code critique ici
} else {
    Write-Host "Arrêt du script" -ForegroundColor Gray
    exit
}
```

### 📋 Confirmation avec résumé détaillé

```powershell
function Show-ActionSummary {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Details,
        
        [string]$ActionName = "Opération"
    )
    
    Write-Host "`n╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ 📋 RÉSUMÉ DE L'ACTION" -NoNewline -ForegroundColor White
    Write-Host (" " * 28) -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╠═══════════════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║ Action : " -NoNewline -ForegroundColor Cyan
    Write-Host $ActionName.PadRight(41) -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╠═══════════════════════════════════════════════════╣" -ForegroundColor Cyan
    
    foreach ($key in $Details.Keys) {
        $value = $Details[$key]
        Write-Host "║ " -NoNewline -ForegroundColor Cyan
        Write-Host "$key : " -NoNewline -ForegroundColor Gray
        Write-Host $value.ToString().PadRight(51 - $key.Length - 4) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
    }
    
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Demander confirmation
    Write-Host "Confirmer cette action ? [o/N] : " -NoNewline -ForegroundColor Yellow
    $reponse = Read-Host
    
    return ($reponse -match '^[oO])
}

# Exemple d'utilisation
$details = @{
    "Serveur cible" = "SRV-PROD-01"
    "Base de données" = "ClientsDB"
    "Nombre de tables" = "47"
    "Taille estimée" = "2.8 GB"
    "Durée estimée" = "~15 minutes"
}

if (Show-ActionSummary -Details $details -ActionName "Sauvegarde de base de données") {
    Write-Host "✓ Démarrage de la sauvegarde..." -ForegroundColor Green
    # Exécuter la sauvegarde
} else {
    Write-Host "✗ Sauvegarde annulée" -ForegroundColor Red
}
```

### 🎯 Confirmation avec choix multiples

```powershell
function Show-ChoicePrompt {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Question,
        
        [Parameter(Mandatory=$true)]
        [array]$Choices,
        
        [int]$DefaultChoice = 0
    )
    
    Write-Host "`n╔═══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║ ❓ " -NoNewline -ForegroundColor Magenta
    Write-Host $Question.PadRight(47) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Magenta
    Write-Host "╠═══════════════════════════════════════════════════╣" -ForegroundColor Magenta
    
    for ($i = 0; $i -lt $Choices.Count; $i++) {
        $prefix = if ($i -eq $DefaultChoice) { "►" } else { " " }
        $style = if ($i -eq $DefaultChoice) { "Yellow" } else { "Gray" }
        
        Write-Host "║ $prefix " -NoNewline -ForegroundColor Magenta
        Write-Host "[$($i+1)] " -NoNewline -ForegroundColor Cyan
        Write-Host $Choices[$i].PadRight(44) -NoNewline -ForegroundColor $style
        Write-Host "║" -ForegroundColor Magenta
    }
    
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    
    do {
        Write-Host "Votre choix [1-$($Choices.Count)] " -NoNewline
        Write-Host "(défaut: $($DefaultChoice + 1))" -NoNewline -ForegroundColor Gray
        Write-Host " : " -NoNewline
        
        $input = Read-Host
        
        if ([string]::IsNullOrWhiteSpace($input)) {
            return $DefaultChoice
        }
        
        [int]$choice = 0
        if ([int]::TryParse($input, [ref]$choice)) {
            if ($choice -ge 1 -and $choice -le $Choices.Count) {
                return ($choice - 1)
            }
        }
        
        Write-Host "✗ Choix invalide, réessayez" -ForegroundColor Red
        
    } while ($true)
}

# Exemple d'utilisation
$choix = Show-ChoicePrompt -Question "Que souhaitez-vous faire ?" `
    -Choices @(
        "Sauvegarder la configuration",
        "Restaurer depuis une sauvegarde",
        "Réinitialiser aux paramètres par défaut",
        "Annuler"
    ) -DefaultChoice 0

switch ($choix) {
    0 { Write-Host "✓ Sauvegarde en cours..." -ForegroundColor Green }
    1 { Write-Host "✓ Restauration en cours..." -ForegroundColor Green }
    2 { Write-Host "⚠ Réinitialisation en cours..." -ForegroundColor Yellow }
    3 { Write-Host "✗ Opération annulée" -ForegroundColor Red }
}
```

### 💾 Confirmation avec aperçu des changements

```powershell
function Show-ChangePreview {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Changes,
        
        [string]$Title = "Aperçu des modifications"
    )
    
    Write-Host "`n╔═══════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║ 🔄 " -NoNewline -ForegroundColor Yellow
    Write-Host $Title.PadRight(47) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Yellow
    Write-Host "╠═══════════════════════════════════════════════════╣" -ForegroundColor Yellow
    
    foreach ($item in $Changes.Keys) {
        Write-Host "║ " -NoNewline -ForegroundColor Yellow
        Write-Host $item.PadRight(49) -NoNewline -ForegroundColor Cyan
        Write-Host "║" -ForegroundColor Yellow
        
        $change = $Changes[$item]
        
        # Ancienne valeur
        Write-Host "║   " -NoNewline -ForegroundColor Yellow
        Write-Host "Avant : " -NoNewline -ForegroundColor Red
        Write-Host $change.Before.PadRight(41) -NoNewline -ForegroundColor Gray
        Write-Host "║" -ForegroundColor Yellow
        
        # Nouvelle valeur
        Write-Host "║   " -NoNewline -ForegroundColor Yellow
        Write-Host "Après : " -NoNewline -ForegroundColor Green
        Write-Host $change.After.PadRight(41) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Yellow
        
        Write-Host "║" -NoNewline -ForegroundColor Yellow
        Write-Host (" " * 51) -NoNewline
        Write-Host "║" -ForegroundColor Yellow
    }
    
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Appliquer ces modifications ? [o/N] : " -NoNewline -ForegroundColor Yellow
    $reponse = Read-Host
    
    return ($reponse -match '^[oO])
}

# Exemple d'utilisation
$modifications = @{
    "Nom du serveur" = @{
        Before = "SRV-TEST-01"
        After = "SRV-PROD-01"
    }
    "Port HTTP" = @{
        Before = "8080"
        After = "80"
    }
    "SSL activé" = @{
        Before = "Non"
        After = "Oui"
    }
}

if (Show-ChangePreview -Changes $modifications -Title "Configuration du serveur web") {
    Write-Host "✓ Modifications appliquées avec succès" -ForegroundColor Green
} else {
    Write-Host "✗ Modifications annulées" -ForegroundColor Red
}
```

> [!tip] Astuce : Combiner les éléments Pour une expérience utilisateur optimale, combinez plusieurs éléments :
> 
> ```powershell
> # 1. Afficher un résumé
> Show-ActionSummary -Details $details -ActionName "Nettoyage"
> 
> # 2. Montrer un spinner pendant l'opération
> $result = Show-Spinner -Message "Nettoyage en cours" -ScriptBlock { ... }
> 
> # 3. Afficher le statut final
> Write-Status -Message "Nettoyage terminé : $result fichiers supprimés" -Type Success
> ```

> [!warning] Bonnes pratiques pour les confirmations
> 
> - **Toujours avoir une option par défaut** (généralement "Non" pour les actions destructives)
> - **Être explicite** sur les conséquences de l'action
> - **Limiter le nombre de confirmations** (éviter la "fatigue de confirmation")
> - **Pour les actions critiques**, utiliser un code de sécurité ou une confirmation en deux étapes
> - **Prévoir une option d'annulation** à tout moment

---

## 🎯 Bonnes pratiques générales

### Performance et optimisation

```powershell
# ❌ MAUVAIS : Trop de mises à jour
foreach ($item in 1..10000) {
    Write-Progress -Activity "Traitement" -PercentComplete ($item/10000*100)
}

# ✅ BON : Mise à jour tous les 100 items
foreach ($item in 1..10000) {
    if ($item % 100 -eq 0) {
        Write-Progress -Activity "Traitement" -PercentComplete ($item/10000*100)
    }
}
```

### Gestion du curseur

```powershell
# Toujours restaurer le curseur dans un bloc finally
function Show-AnimationSecurisee {
    [Console]::CursorVisible = $false
    try {
        # Animation ici
    }
    finally {
        [Console]::CursorVisible = $true
    }
}
```

### Compatibilité multiplateforme

```powershell
# Vérifier la compatibilité des symboles Unicode
function Get-SafeSymbol {
    param([string]$PreferredSymbol, [string]$FallbackSymbol)
    
    try {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        return $PreferredSymbol
    }
    catch {
        return $FallbackSymbol
    }
}

$checkmark = Get-SafeSymbol -PreferredSymbol ([char]0x2713) -FallbackSymbol "OK"
```

### Combinaison d'éléments

```powershell
# Exemple complet : Script de déploiement avec tous les éléments visuels
function Start-Deployment {
    param([string[]]$Servers)
    
    # 1. Confirmation avec résumé
    $details = @{
        "Serveurs cibles" = $Servers.Count
        "Liste" = ($Servers -join ", ")
        "Durée estimée" = "~30 minutes"
    }
    
    if (-not (Show-ActionSummary -Details $details -ActionName "Déploiement application")) {
        Write-Status -Message "Déploiement annulé par l'utilisateur" -Type Warning
        return
    }
    
    # 2. Barre de progression pour chaque serveur
    $total = $Servers.Count
    $current = 0
    
    foreach ($server in $Servers) {
        $current++
        
        Write-Progress -Id 0 `
                       -Activity "Déploiement sur les serveurs" `
                       -Status "Serveur $current/$total : $server" `
                       -PercentComplete (($current / $total) * 100)
        
        # 3. Spinner pour les opérations longues
        $result = Show-Spinner -Message "Connexion à $server" -ScriptBlock {
            # Simulation connexion
            Start-Sleep -Seconds 2
            return $true
        }
        
        if ($result) {
            Write-Status -Message "Connexion à $server établie" -Type Success
            
            # 4. Sous-progression pour les étapes
            $etapes = @("Copie des fichiers", "Installation", "Configuration", "Démarrage")
            for ($i = 0; $i -lt $etapes.Count; $i++) {
                Write-Progress -Id 1 -ParentId 0 `
                               -Activity "Déploiement sur $server" `
                               -Status $etapes[$i] `
                               -PercentComplete (($i / $etapes.Count) * 100)
                
                Start-Sleep -Seconds 1
            }
            Write-Progress -Id 1 -Completed
            
            Write-Status -Message "Déploiement sur $server terminé" -Type Success
        }
        else {
            Write-Status -Message "Échec de connexion à $server" -Type Error
        }
    }
    
    Write-Progress -Id 0 -Completed
    
    # 5. Résumé final
    Write-Host "`n╔═══════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║ ✓ DÉPLOIEMENT TERMINÉ" -NoNewline -ForegroundColor White
    Write-Host (" " * 28) -NoNewline
    Write-Host "║" -ForegroundColor Green
    Write-Host "╠═══════════════════════════════════════════════════╣" -ForegroundColor Green
    Write-Host "║ Serveurs déployés : $($Servers.Count)".PadRight(52) -NoNewline
    Write-Host "║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Green
}

# Exécution
Start-Deployment -Servers @("SRV-WEB-01", "SRV-WEB-02", "SRV-WEB-03")
```

---

## 📚 Récapitulatif

### Tableau comparatif des techniques

|Technique|Usage idéal|Avantages|Inconvénients|
|---|---|---|---|
|**Write-Progress**|Opérations longues avec progression connue|Natif PowerShell, très clair|Pas adapté si durée inconnue|
|**Indicateurs de statut**|Affichage de résultats, logs|Simple, universel|Nécessite Unicode pour les symboles|
|**Spinner**|Opérations de durée inconnue|Retour visuel dynamique|Consomme du CPU, pas pour scripts automatisés|
|**Animations**|Transitions, attentes|Moderne, professionnel|Complexe à implémenter, compatibilité|
|**Confirmations**|Actions critiques ou destructives|Prévient les erreurs|Peut ralentir le workflow|

### Quand utiliser quoi ?

```powershell
# Durée CONNUE + traitement en boucle
→ Write-Progress

# Durée INCONNUE + opération réseau/attente
→ Spinner ou animations de points

# Affichage de RÉSULTATS d'opérations
→ Indicateurs de statut (✓, ✗, ⚠)

# Action DESTRUCTIVE ou CRITIQUE
→ Confirmation stylisée avec résumé

# Script AUTOMATISÉ (tâches planifiées, CI/CD)
→ Éviter animations, privilégier Write-Verbose/Write-Log
```

### Points clés à retenir

> [!important] Règles d'or
> 
> 1. **Toujours fermer les barres de progression** avec `-Completed`
> 2. **Restaurer le curseur** dans les blocs `finally`
> 3. **Limiter la fréquence de rafraîchissement** des animations (100-400ms)
> 4. **Tester la compatibilité** des symboles Unicode sur différentes consoles
> 5. **Adapter le niveau de détail** au contexte (interactif vs automatisé)
> 6. **Prévoir des alternatives ASCII** pour les symboles Unicode
> 7. **Ne pas abuser des confirmations** (fatigue utilisateur)
> 8. **Combiner les éléments** pour une expérience cohérente

---

## 🎨 Exemple de script complet

Voici un script qui intègre tous les éléments visuels abordés :

```powershell
<#
.SYNOPSIS
Script de maintenance système avec interface visuelle complète
#>

# Symboles
$symboles = @{
    Success = [char]0x2713
    Error   = [char]0x2717
    Warning = [char]0x26A0
    Info    = [char]0x1F6C8
}

function Write-Status {
    param([string]$Message, [string]$Type)
    $config = @{
        Success = 'Green'; Error = 'Red'; Warning = 'Yellow'; Info = 'Cyan'
    }
    Write-Host "$($symboles[$Type]) " -ForegroundColor $config[$Type] -NoNewline
    Write-Host $Message
}

# Afficher le header
Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     🔧 SCRIPT DE MAINTENANCE SYSTÈME              ║" -ForegroundColor White
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Confirmation
$details = @{
    "Actions" = "Nettoyage temp, logs, cache"
    "Impact" = "Espace libéré estimé : ~2GB"
    "Durée" = "~5 minutes"
}

Write-Host "`n📋 Résumé de l'opération :" -ForegroundColor Cyan
foreach ($key in $details.Keys) {
    Write-Host "  • $key : " -NoNewline -ForegroundColor Gray
    Write-Host $details[$key] -ForegroundColor White
}

Write-Host "`nContinuer ? [o/N] : " -NoNewline -ForegroundColor Yellow
if ((Read-Host) -notmatch '^[oO]) {
    Write-Status -Message "Opération annulée" -Type Warning
    exit
}

# Exécution avec progression
$taches = @(
    @{Nom="Nettoyage temp"; Dossier="C:\Windows\Temp"; Duree=2}
    @{Nom="Nettoyage cache"; Dossier="C:\Users\*\AppData\Local\Temp"; Duree=3}
    @{Nom="Rotation logs"; Dossier="C:\Logs"; Duree=1}
)

$total = $taches.Count
$current = 0

foreach ($tache in $taches) {
    $current++
    
    Write-Progress -Activity "Maintenance en cours" `
                   -Status "$($tache.Nom) ($current/$total)" `
                   -PercentComplete (($current / $total) * 100)
    
    Write-Host "`n⚙ " -NoNewline -ForegroundColor Gray
    Write-Host "$($tache.Nom)..." -NoNewline
    
    Start-Sleep -Seconds $tache.Duree
    
    Write-Host " " -NoNewline
    Write-Status -Message "Terminé" -Type Success
}

Write-Progress -Activity "Maintenance en cours" -Completed

# Résumé final
Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║ ✓ MAINTENANCE TERMINÉE AVEC SUCCÈS                ║" -ForegroundColor White
Write-Host "╠════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║ Espace libéré : 2.1 GB                            ║" -ForegroundColor Gray
Write-Host "║ Durée totale : 6 minutes                          ║" -ForegroundColor Gray
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
```

Ce cours vous permet maintenant de créer des scripts PowerShell visuellement attractifs et informatifs !