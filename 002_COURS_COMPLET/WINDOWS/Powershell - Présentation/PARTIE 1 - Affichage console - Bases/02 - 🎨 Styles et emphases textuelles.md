

> [!info] Vue d'ensemble Cette partie du cours explore les techniques avancées pour styliser et embellir le texte affiché en console PowerShell. Vous apprendrez à utiliser les séquences ANSI pour créer du texte gras, souligné, italique, intégrer des émojis, et créer des effets visuels comme le clignotement, tout en gérant la compatibilité entre différentes versions de PowerShell.

---

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

## 🔤 Séquences ANSI pour les styles de texte

### Pourquoi utiliser les séquences ANSI ?

Les séquences ANSI permettent de contrôler finement l'apparence du texte en console, offrant des possibilités bien au-delà de la simple coloration. Elles permettent de créer des interfaces console professionnelles et agréables à lire en ajoutant des emphases visuelles qui guident l'attention de l'utilisateur.

> [!info] PowerShell 7+ requis Les séquences ANSI pour les styles textuels (gras, souligné, italique) fonctionnent nativement à partir de PowerShell 7. PowerShell 5.1 nécessite des techniques alternatives.

### Syntaxe des séquences ANSI

Les séquences ANSI commencent par le caractère d'échappement ESC (code ASCII 27 ou `0x1B`) suivi de `[`, des codes de style, et se terminent par `m`.

```powershell
# Structure générale d'une séquence ANSI
$esc = [char]27
$sequenceANSI = "$esc[<code>m"

# Ou en utilisant la notation hexadécimale
$sequenceANSI = "`e[<code>m"  # PowerShell 7+ uniquement
```

### Tableau des codes de style principaux

|Style|Code ANSI|Exemple|Réinitialisation|
|---|---|---|---|
|**Gras**|`1`|`$esc[1m`|`$esc[22m` ou `$esc[0m`|
|_Italique_|`3`|`$esc[3m`|`$esc[23m` ou `$esc[0m`|
|<u>Souligné</u>|`4`|`$esc[4m`|`$esc[24m` ou `$esc[0m`|
|Clignotant|`5`|`$esc[5m`|`$esc[25m` ou `$esc[0m`|
|Inversé|`7`|`$esc[7m`|`$esc[27m` ou `$esc[0m`|
|Barré|`9`|`$esc[9m`|`$esc[29m` ou `$esc[0m`|
|Réinitialiser tout|`0`|`$esc[0m`|N/A|

> [!tip] Code 0 universel Le code `0` réinitialise TOUS les styles et couleurs. C'est le moyen le plus sûr de revenir à un affichage normal.

### Exemples pratiques

#### Texte gras

```powershell
# PowerShell 7+
$esc = "`e"
Write-Host "${esc}[1mCe texte est en gras${esc}[0m"
Write-Host "${esc}[1mATTENTION :${esc}[0m Ceci est un message important"

# Alternative compatible PowerShell 5.1+
$esc = [char]27
Write-Host "${esc}[1mCe texte est en gras${esc}[0m"
```

> [!example] Sortie console **Ce texte est en gras** **ATTENTION :** Ceci est un message important

#### Texte souligné

```powershell
$esc = "`e"
Write-Host "${esc}[4mTexte souligné${esc}[0m"
Write-Host "Voici un ${esc}[4mlien important${esc}[0m dans le texte"
```

#### Texte italique

```powershell
$esc = "`e"
Write-Host "${esc}[3mTexte en italique${esc}[0m"
Write-Host "Note: ${esc}[3mCeci est une remarque${esc}[0m"
```

> [!warning] Support limité de l'italique L'italique n'est pas supporté par tous les terminaux. Sur Windows Terminal et les terminaux modernes, il fonctionne généralement bien. Sur la console PowerShell classique (conhost.exe), l'italique peut ne pas s'afficher ou être rendu autrement.

#### Combinaison de styles

Les styles peuvent être combinés en les séparant par des points-virgules :

```powershell
$esc = "`e"

# Gras + Souligné
Write-Host "${esc}[1;4mTexte gras et souligné${esc}[0m"

# Gras + Italique
Write-Host "${esc}[1;3mTexte gras et italique${esc}[0m"

# Gras + Souligné + Italique
Write-Host "${esc}[1;3;4mTexte avec tous les styles${esc}[0m"

# Combinaison avec couleurs (code 31 = rouge)
Write-Host "${esc}[1;31mTexte gras et rouge${esc}[0m"
```

#### Fonction utilitaire pour styliser

```powershell
function Write-StyledText {
    <#
    .SYNOPSIS
    Affiche du texte avec des styles ANSI
    
    .PARAMETER Text
    Le texte à afficher
    
    .PARAMETER Bold
    Applique le style gras
    
    .PARAMETER Italic
    Applique le style italique
    
    .PARAMETER Underline
    Applique le soulignement
    
    .PARAMETER Color
    Couleur du texte (Red, Green, Blue, Yellow, etc.)
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Text,
        
        [switch]$Bold,
        [switch]$Italic,
        [switch]$Underline,
        [string]$Color
    )
    
    $esc = "`e"
    $codes = @()
    
    # Ajout des codes de style
    if ($Bold) { $codes += "1" }
    if ($Italic) { $codes += "3" }
    if ($Underline) { $codes += "4" }
    
    # Ajout de la couleur si spécifiée
    $colorCodes = @{
        'Black' = '30'; 'Red' = '31'; 'Green' = '32'; 'Yellow' = '33'
        'Blue' = '34'; 'Magenta' = '35'; 'Cyan' = '36'; 'White' = '37'
    }
    
    if ($Color -and $colorCodes.ContainsKey($Color)) {
        $codes += $colorCodes[$Color]
    }
    
    # Construction de la séquence
    if ($codes.Count -gt 0) {
        $styleSequence = $codes -join ';'
        Write-Host "${esc}[${styleSequence}m${Text}${esc}[0m"
    } else {
        Write-Host $Text
    }
}

# Exemples d'utilisation adaptative
Write-StyledTextCompatible "Texte normal"
Write-StyledTextCompatible "Texte gras" -Bold
Write-StyledTextCompatible "Texte gras et rouge" -Bold -Color Red
Write-StyledTextCompatible "Texte basique" -ForceBasic -Color Green
```

### Wrapper pour compatibilité PowerShell 5.1 vs 7+

```powershell
function Initialize-ANSIEnvironment {
    <#
    .SYNOPSIS
    Configure l'environnement pour un support optimal des séquences ANSI
    #>
    
    # Détection de la version
    $isPwsh7 = $PSVersionTable.PSVersion.Major -ge 7
    
    # Configuration UTF-8 pour émojis (PowerShell 7+)
    if ($isPwsh7) {
        try {
            [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
            [Console]::InputEncoding = [System.Text.Encoding]::UTF8
        } catch {
            Write-Warning "Impossible de configurer l'encodage UTF-8"
        }
    }
    
    # Création d'une variable globale pour le caractère d'échappement
    if ($isPwsh7) {
        $global:ESC = "`e"
    } else {
        $global:ESC = [char]27
    }
    
    # Création de constantes de style pour faciliter l'usage
    $global:ANSI = @{
        # Styles
        Bold = "${global:ESC}[1m"
        Italic = "${global:ESC}[3m"
        Underline = "${global:ESC}[4m"
        Blink = "${global:ESC}[5m"
        Reverse = "${global:ESC}[7m"
        Strike = "${global:ESC}[9m"
        
        # Reset
        Reset = "${global:ESC}[0m"
        ResetBold = "${global:ESC}[22m"
        ResetItalic = "${global:ESC}[23m"
        ResetUnderline = "${global:ESC}[24m"
        
        # Couleurs texte
        Black = "${global:ESC}[30m"
        Red = "${global:ESC}[31m"
        Green = "${global:ESC}[32m"
        Yellow = "${global:ESC}[33m"
        Blue = "${global:ESC}[34m"
        Magenta = "${global:ESC}[35m"
        Cyan = "${global:ESC}[36m"
        White = "${global:ESC}[37m"
        
        # Couleurs vives
        BrightRed = "${global:ESC}[91m"
        BrightGreen = "${global:ESC}[92m"
        BrightYellow = "${global:ESC}[93m"
        BrightBlue = "${global:ESC}[94m"
        BrightMagenta = "${global:ESC}[95m"
        BrightCyan = "${global:ESC}[96m"
    }
    
    # Information sur l'environnement
    Write-Host "✓ Environnement ANSI initialisé" -ForegroundColor Green
    Write-Host "  PowerShell: $($PSVersionTable.PSVersion)"
    Write-Host "  Terminal: " -NoNewline
    
    if ($env:WT_SESSION) {
        Write-Host "Windows Terminal" -ForegroundColor Cyan
    } elseif ($env:TERM_PROGRAM -eq 'vscode') {
        Write-Host "VS Code" -ForegroundColor Cyan
    } else {
        Write-Host "Autre" -ForegroundColor Yellow
    }
}

# Initialisation au chargement du script
Initialize-ANSIEnvironment

# Exemples d'utilisation des constantes
Write-Host "${ANSI.Bold}${ANSI.Red}Texte gras et rouge${ANSI.Reset}"
Write-Host "${ANSI.Underline}${ANSI.Cyan}Texte souligné cyan${ANSI.Reset}"
Write-Host "${ANSI.Bold}${ANSI.BrightGreen}Succès!${ANSI.Reset}"
```

### Fonction avec fallback automatique

```powershell
function Write-Message {
    <#
    .SYNOPSIS
    Affiche un message avec fallback automatique selon les capacités du terminal
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ValidateSet('Success', 'Error', 'Warning', 'Info')]
        [string]$Type = 'Info',
        
        [switch]$UseEmoji
    )
    
    # Détection des capacités
    $isPwsh7 = $PSVersionTable.PSVersion.Major -ge 7
    $supportsEmoji = $isPwsh7 -and ($null -ne $env:WT_SESSION -or $env:TERM_PROGRAM -eq 'vscode')
    
    # Configuration selon le type
    $config = @{
        'Success' = @{
            Emoji = '✅'
            Symbol = '[OK]'
            Color = 'Green'
            ANSIColor = '32'
        }
        'Error' = @{
            Emoji = '❌'
            Symbol = '[ERROR]'
            Color = 'Red'
            ANSIColor = '31'
        }
        'Warning' = @{
            Emoji = '⚠️'
            Symbol = '[WARN]'
            Color = 'Yellow'
            ANSIColor = '33'
        }
        'Info' = @{
            Emoji = 'ℹ️'
            Symbol = '[INFO]'
            Color = 'Cyan'
            ANSIColor = '36'
        }
    }
    
    $cfg = $config[$Type]
    
    # Choix du préfixe
    if ($UseEmoji -and $supportsEmoji) {
        $prefix = $cfg.Emoji
    } else {
        $prefix = $cfg.Symbol
    }
    
    # Affichage avec ou sans ANSI
    try {
        if ($isPwsh7 -or $env:WT_SESSION) {
            $esc = if ($isPwsh7) { "`e" } else { [char]27 }
            Write-Host "${prefix} ${esc}[1;$($cfg.ANSIColor)m${Message}${esc}[0m"
        } else {
            Write-Host "${prefix} ${Message}" -ForegroundColor $cfg.Color
        }
    } catch {
        # Fallback ultime sans couleur
        Write-Host "${prefix} ${Message}"
    }
}

# Exemples d'utilisation multi-environnement
Write-Message "Opération réussie" -Type Success -UseEmoji
Write-Message "Fichier introuvable" -Type Error
Write-Message "Avertissement de compatibilité" -Type Warning
Write-Message "Information système" -Type Info -UseEmoji
```

---

## 💡 Pièges courants et bonnes pratiques

### ❌ Pièges à éviter

#### 1. Oublier de réinitialiser les styles

```powershell
# ❌ MAUVAIS - Le style continue après
$esc = "`e"
Write-Host "${esc}[1mTexte gras"
Write-Host "Ce texte reste gras!"

# ✅ BON - Toujours réinitialiser
Write-Host "${esc}[1mTexte gras${esc}[0m"
Write-Host "Ce texte est normal"
```

#### 2. Combiner incorrectement les styles

```powershell
# ❌ MAUVAIS - Styles séparés qui s'écrasent
$esc = "`e"
Write-Host "${esc}[1m${esc}[4mTexte${esc}[0m"  # Seul le dernier style s'applique

# ✅ BON - Combinaison avec point-virgule
Write-Host "${esc}[1;4mTexte${esc}[0m"
```

#### 3. Supposer le support d'italique partout

```powershell
# ❌ MAUVAIS - Pas de vérification
$esc = "`e"
Write-Host "${esc}[3mTexte italique${esc}[0m"  # Peut ne pas fonctionner

# ✅ BON - Avec détection
if ($env:WT_SESSION -or $env:TERM_PROGRAM -eq 'vscode') {
    Write-Host "${esc}[3mTexte italique${esc}[0m"
} else {
    Write-Host "${esc}[4mTexte souligné${esc}[0m"  # Alternative
}
```

#### 4. Abuser du clignotement

```powershell
# ❌ MAUVAIS - Trop de clignotement
Write-Host "${esc}[5mTous${esc}[0m ces ${esc}[5mmots${esc}[0m ${esc}[5mclignotent${esc}[0m"

# ✅ BON - Réservé aux alertes critiques
Write-Host "⚠️ ${esc}[1;31mALERTE CRITIQUE${esc}[0m : Système compromis"
```

#### 5. Mauvaise gestion de l'encodage UTF-8

```powershell
# ❌ MAUVAIS - Émojis sans configuration UTF-8
Write-Host "✅ Succès"  # Peut s'afficher comme ???

# ✅ BON - Configuration préalable
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "✅ Succès"
```

### ✅ Bonnes pratiques

#### 1. Créer des constantes réutilisables

```powershell
# Définir une fois, utiliser partout
$BOLD = "`e[1m"
$UNDERLINE = "`e[4m"
$RED = "`e[31m"
$GREEN = "`e[32m"
$RESET = "`e[0m"

# Usage simple et lisible
Write-Host "${BOLD}${RED}Erreur critique${RESET}"
Write-Host "${GREEN}Succès${RESET}"
```

#### 2. Encapsuler dans des fonctions

```powershell
# Créer des fonctions dédiées pour chaque type de message
function Write-Success { 
    param([string]$Message)
    Write-Host "`e[1;32m✅ ${Message}`e[0m" 
}

function Write-Error { 
    param([string]$Message)
    Write-Host "`e[1;31m❌ ${Message}`e[0m" 
}

# Usage propre
Write-Success "Fichier créé"
Write-Error "Connexion échouée"
```

#### 3. Utiliser des splats pour la lisibilité

```powershell
# Plus lisible avec splatting
$messageParams = @{
    Object = "Traitement en cours..."
    ForegroundColor = 'Yellow'
    NoNewline = $true
}
Write-Host @messageParams
```

#### 4. Tester la compatibilité au début du script

```powershell
# En-tête de script
#Requires -Version 5.1

# Vérification des capacités au démarrage
$script:SupportsANSI = $PSVersionTable.PSVersion.Major -ge 7 -or $env:WT_SESSION
$script:SupportsEmoji = $PSVersionTable.PSVersion.Major -ge 7

if (-not $script:SupportsANSI) {
    Write-Warning "Terminal classique détecté. Affichage basique activé."
}
```

#### 5. Documenter l'usage des émojis

```powershell
<#
.SYNOPSIS
Script de déploiement avec interface enrichie

.DESCRIPTION
Ce script utilise des émojis et des styles ANSI pour améliorer l'expérience utilisateur.

.NOTES
Requis:
- PowerShell 7+ pour les émojis
- Windows Terminal ou VS Code pour un affichage optimal
- Encodage UTF-8 configuré

Émojis utilisés:
- ✅ : Opération réussie
- ❌ : Erreur
- ⚠️ : Avertissement
- ⏳ : En cours
- 🚀 : Démarrage
#>
```

#### 6. Prévoir un mode "Plain"

```powershell
# Paramètre pour désactiver les styles
param(
    [switch]$PlainOutput
)

function Write-StyledMessage {
    param($Message, $Type)
    
    if ($PlainOutput) {
        Write-Host "[$Type] $Message"
    } else {
        # Version stylisée
        Write-Host "`e[1;32m✅ ${Message}`e[0m"
    }
}

# Usage
# .\script.ps1 -PlainOutput  # Pour logs ou scripts automatisés
```

#### 7. Gérer la largeur du terminal

```powershell
function Write-CenteredText {
    param([string]$Text)
    
    try {
        $width = $Host.UI.RawUI.WindowSize.Width
        $padding = [Math]::Max(0, ($width - $Text.Length) / 2)
        Write-Host ("{0}{1}" -f (' ' * $padding), $Text)
    } catch {
        # Fallback si impossible d'obtenir la largeur
        Write-Host $Text
    }
}
```

#### 8. Créer un module réutilisable

```powershell
# StyledOutput.psm1
function Write-Success {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "`e[1;32m✅ ${Message}`e[0m"
}

function Write-Error {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "`e[1;31m❌ ${Message}`e[0m"
}

function Write-Warning {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "`e[1;33m⚠️ ${Message}`e[0m"
}

function Write-Info {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "`e[1;36mℹ️ ${Message}`e[0m"
}

Export-ModuleMember -Function Write-Success, Write-Error, Write-Warning, Write-Info

# Usage dans vos scripts
Import-Module .\StyledOutput.psm1
Write-Success "Déploiement terminé"
```

### 🎯 Récapitulatif des recommandations

|Contexte|Recommandation|
|---|---|
|**Scripts automatisés**|Éviter les émojis, utiliser `-PlainOutput`|
|**Scripts interactifs**|Utiliser émojis et styles avec modération|
|**Alertes critiques**|Combiner couleur rouge, gras, et émoji ⚠️|
|**Messages de succès**|Vert + gras + ✅|
|**Logs**|Préférer Write-Information/Write-Verbose sans styles|
|**Compatibilité**|Toujours tester sur PowerShell 5.1 ET 7+|
|**Production**|Prévoir un fallback sans ANSI|
|**Développement**|Utiliser Windows Terminal ou VS Code|

> [!tip] Philosophie du style **"Less is more"** : Quelques styles bien placés ont plus d'impact qu'un arc-en-ciel de couleurs et d'effets. Utilisez les styles pour guider l'attention, pas pour décorer.

---

## 🎓 Synthèse du cours

Ce cours vous a présenté les techniques avancées de stylisation du texte en console PowerShell :

### Points clés à retenir

1. **Séquences ANSI** : Permettent un contrôle précis du style (gras, souligné, italique) via des codes d'échappement
2. **Émojis** : Enrichissent l'interface mais nécessitent PowerShell 7+ et UTF-8
3. **Clignotement** : À réserver aux alertes critiques, support limité selon les terminaux
4. **Compatibilité** : Toujours tester sur différentes versions et prévoir des fallbacks

### Checklist avant déploiement

- [ ] Tests effectués sur PowerShell 5.1 et 7+
- [ ] Tests sur Windows Terminal et console classique
- [ ] Encodage UTF-8 configuré pour les émojis
- [ ] Fallback prévu pour terminaux basiques
- [ ] Documentation des prérequis dans le script
- [ ] Mode `-PlainOutput` disponible pour automatisation
- [ ] Styles réinitialisés après chaque usage
- [ ] Utilisation modérée des effets visuels

> [!success] Vous maîtrisez maintenant Les techniques professionnelles de stylisation console qui rendront vos scripts PowerShell visuellement attrayants et faciles à utiliser, tout en restant compatibles avec différents environnements d'exécution. $styleSequence = $codes -join ';' Write-Host "${esc}[${styleSequence}m${Text}${esc}[0m" } else { Write-Host $Text } }

# Exemples d'utilisation

Write-StyledText "Texte normal" Write-StyledText "Texte gras" -Bold Write-StyledText "Texte gras et souligné" -Bold -Underline Write-StyledText "Erreur critique" -Bold -Color Red Write-StyledText "Succès" -Bold -Color Green Write-StyledText "Note importante" -Italic -Underline -Color Yellow

````

---

## 😊 Support des émojis en console

### Pourquoi utiliser des émojis ?

Les émojis permettent de rendre vos scripts plus expressifs et visuellement attrayants. Ils facilitent la reconnaissance rapide des types de messages (succès ✅, erreur ❌, avertissement ⚠️) et rendent l'interface plus moderne et conviviale.

> [!info] Prérequis pour les émojis
> - **PowerShell 7+** : Support natif complet des émojis Unicode
> - **Terminal moderne** : Windows Terminal, VS Code Terminal, ou terminaux supportant UTF-8
> - **Encodage UTF-8** : L'encodage de la console doit être configuré en UTF-8

### Configuration de l'encodage UTF-8

```powershell
# Vérifier l'encodage actuel
[Console]::OutputEncoding
[Console]::InputEncoding

# Définir l'encodage en UTF-8 pour la session courante
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Pour rendre permanent dans votre profil PowerShell
# Ajoutez ces lignes à $PROFILE
if ($PSVersionTable.PSVersion.Major -ge 7) {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
}
````

### Émojis courants et leurs usages

#### Tableau des émojis utiles pour les scripts

|Catégorie|Emoji|Code|Usage|
|---|---|---|---|
|**État**|✅|`U+2705`|Succès, validation|
||❌|`U+274C`|Erreur, échec|
||⚠️|`U+26A0`|Avertissement|
||ℹ️|`U+2139`|Information|
||⏳|`U+23F3`|En cours, attente|
||✔️|`U+2714`|Cochée, complété|
|**Actions**|🚀|`U+1F680`|Lancement, démarrage|
||🔄|`U+1F504`|Actualisation, rechargement|
||🗑️|`U+1F5D1`|Suppression|
||💾|`U+1F4BE`|Sauvegarde|
||📁|`U+1F4C1`|Dossier|
||📄|`U+1F4C4`|Fichier|
|**Système**|🔧|`U+1F527`|Configuration, outils|
||🔍|`U+1F50D`|Recherche|
||📊|`U+1F4CA`|Statistiques, données|
||🌐|`U+1F310`|Réseau, web|
||🔐|`U+1F510`|Sécurité, verrouillé|
||🎯|`U+1F3AF`|Objectif, cible|

### Exemples d'utilisation

#### Messages de statut avec émojis

```powershell
# Messages de base
Write-Host "✅ Opération réussie"
Write-Host "❌ Erreur lors du traitement"
Write-Host "⚠️ Attention: espace disque faible"
Write-Host "ℹ️ Information: 5 fichiers traités"

# Avec couleurs et styles
$esc = "`e"
Write-Host "${esc}[1;32m✅ Succès${esc}[0m : Fichier sauvegardé"
Write-Host "${esc}[1;31m❌ Erreur${esc}[0m : Connexion impossible"
Write-Host "${esc}[1;33m⚠️ Avertissement${esc}[0m : Mémoire > 80%"
```

#### Fonction de log enrichie avec émojis

```powershell
function Write-LogMessage {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ValidateSet('Success', 'Error', 'Warning', 'Info', 'Progress')]
        [string]$Type = 'Info'
    )
    
    $esc = "`e"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Configuration selon le type
    $config = @{
        'Success'  = @{ Emoji = '✅'; Color = '32'; Label = 'SUCCESS' }
        'Error'    = @{ Emoji = '❌'; Color = '31'; Label = 'ERROR  ' }
        'Warning'  = @{ Emoji = '⚠️'; Color = '33'; Label = 'WARNING' }
        'Info'     = @{ Emoji = 'ℹ️'; Color = '36'; Label = 'INFO   ' }
        'Progress' = @{ Emoji = '⏳'; Color = '35'; Label = 'PROGRESS' }
    }
    
    $cfg = $config[$Type]
    $emoji = $cfg.Emoji
    $color = $cfg.Color
    $label = $cfg.Label
    
    # Affichage formaté
    Write-Host "${emoji} " -NoNewline
    Write-Host "${esc}[${color}m[${label}]${esc}[0m " -NoNewline
    Write-Host "${esc}[90m${timestamp}${esc}[0m " -NoNewline
    Write-Host $Message
}

# Exemples d'utilisation
Write-LogMessage "Démarrage du script" -Type Info
Write-LogMessage "Connexion à la base de données" -Type Progress
Write-LogMessage "Données importées avec succès" -Type Success
Write-LogMessage "Le fichier config.xml est manquant" -Type Warning
Write-LogMessage "Échec de la connexion au serveur" -Type Error
```

#### Barre de progression avec émojis

```powershell
function Show-ProgressBar {
    param(
        [int]$Percent,
        [int]$Width = 30
    )
    
    $filledWidth = [math]::Floor($Width * $Percent / 100)
    $emptyWidth = $Width - $filledWidth
    
    $filled = "█" * $filledWidth
    $empty = "░" * $emptyWidth
    
    $esc = "`e"
    Write-Host "`r🚀 Progression: [${esc}[32m${filled}${esc}[0m${empty}] ${Percent}%" -NoNewline
}

# Simulation de progression
for ($i = 0; $i -le 100; $i += 5) {
    Show-ProgressBar -Percent $i
    Start-Sleep -Milliseconds 200
}
Write-Host "" # Retour à la ligne final
Write-Host "✅ Traitement terminé!"
```

#### Menu interactif avec émojis

```powershell
function Show-Menu {
    Clear-Host
    $esc = "`e"
    
    Write-Host ""
    Write-Host "${esc}[1;36m╔════════════════════════════════════╗${esc}[0m"
    Write-Host "${esc}[1;36m║${esc}[0m     🎯 ${esc}[1mMENU PRINCIPAL${esc}[0m          ${esc}[1;36m║${esc}[0m"
    Write-Host "${esc}[1;36m╚════════════════════════════════════╝${esc}[0m"
    Write-Host ""
    Write-Host "  📁 [1] Gérer les fichiers"
    Write-Host "  🔧 [2] Configuration"
    Write-Host "  📊 [3] Statistiques"
    Write-Host "  🌐 [4] Options réseau"
    Write-Host "  🚪 [5] Quitter"
    Write-Host ""
    Write-Host -NoNewline "  ➤ Votre choix: "
}
```

> [!tip] Astuce Utilisez les émojis de manière cohérente dans tout votre script. Créez un guide de style personnel pour maintenir la cohérence (ex: toujours ✅ pour succès, ❌ pour erreur).

---

## ⚠️ Texte clignotant pour alertes critiques

### Quand utiliser le clignotement ?

Le texte clignotant doit être réservé aux **alertes critiques** qui nécessitent une attention immédiate de l'utilisateur. Une utilisation excessive rend l'interface désagréable et dilue l'impact des véritables alertes.

> [!warning] Utilisation modérée recommandée Le clignotement peut être irritant et fatigant pour les yeux. Utilisez-le uniquement pour :
> 
> - Erreurs critiques bloquantes
> - Avertissements de sécurité majeurs
> - Actions irréversibles nécessitant confirmation
> - États d'urgence système

### Syntaxe du clignotement ANSI

```powershell
# Code ANSI pour texte clignotant
$esc = "`e"
$blink = "${esc}[5m"
$reset = "${esc}[0m"

Write-Host "${blink}TEXTE CLIGNOTANT${reset}"
```

> [!info] Support limité Le clignotement (code ANSI 5) n'est pas supporté par tous les terminaux :
> 
> - ✅ Supporté : Linux terminals (xterm, gnome-terminal), macOS Terminal
> - ❌ Non supporté : Windows Terminal, PowerShell ISE, Console Windows classique
> - ⚠️ Alternatif : VS Code Terminal (peut afficher en inversé plutôt que clignotant)

### Alternative : Clignotement simulé

Pour une compatibilité maximale, créez un effet de clignotement par rafraîchissement manuel :

```powershell
function Write-BlinkingText {
    param(
        [string]$Text,
        [int]$Duration = 5,  # Durée en secondes
        [string]$Color = 'Red'
    )
    
    $esc = "`e"
    $colorCodes = @{
        'Red' = '31'; 'Yellow' = '33'; 'Magenta' = '35'
    }
    $colorCode = $colorCodes[$Color]
    
    $endTime = (Get-Date).AddSeconds($Duration)
    $visible = $true
    
    # Sauvegarde de la position du curseur
    Write-Host "`n" -NoNewline
    
    while ((Get-Date) -lt $endTime) {
        # Retour au début de la ligne
        Write-Host "`r" -NoNewline
        
        if ($visible) {
            Write-Host "${esc}[1;${colorCode}m${Text}${esc}[0m" -NoNewline
        } else {
            Write-Host (" " * $Text.Length) -NoNewline
        }
        
        $visible = -not $visible
        Start-Sleep -Milliseconds 500
    }
    
    # Affichage final
    Write-Host "`r${esc}[1;${colorCode}m${Text}${esc}[0m"
}

# Exemple d'utilisation
Write-BlinkingText "⚠️ ALERTE CRITIQUE : Action irréversible!" -Duration 3 -Color Red
```

### Messages d'alerte avec clignotement

```powershell
function Show-CriticalAlert {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [switch]$RequireConfirmation
    )
    
    $esc = "`e"
    
    # Cadre d'alerte
    Write-Host ""
    Write-Host "${esc}[41m${esc}[1;37m╔══════════════════════════════════════════════════════╗${esc}[0m"
    Write-Host "${esc}[41m${esc}[1;37m║                 ⚠️  ALERTE CRITIQUE ⚠️                ║${esc}[0m"
    Write-Host "${esc}[41m${esc}[1;37m╚══════════════════════════════════════════════════════╝${esc}[0m"
    Write-Host ""
    
    # Message clignotant (simulation)
    for ($i = 0; $i -lt 3; $i++) {
        Write-Host "`r${esc}[1;31m${Message}${esc}[0m" -NoNewline
        Start-Sleep -Milliseconds 300
        Write-Host "`r$(' ' * $Message.Length)" -NoNewline
        Start-Sleep -Milliseconds 300
    }
    Write-Host "`r${esc}[1;31m${Message}${esc}[0m"
    Write-Host ""
    
    if ($RequireConfirmation) {
        Write-Host "${esc}[1;33m⚠️ Cette action est IRRÉVERSIBLE !${esc}[0m"
        Write-Host ""
        $confirmation = Read-Host "Tapez 'CONFIRMER' pour continuer"
        
        if ($confirmation -ne 'CONFIRMER') {
            Write-Host "${esc}[32m✅ Opération annulée${esc}[0m"
            return $false
        }
    }
    
    return $true
}

# Exemple d'utilisation
$confirmed = Show-CriticalAlert `
    -Message "Vous êtes sur le point de SUPPRIMER TOUTES LES DONNÉES" `
    -RequireConfirmation

if ($confirmed) {
    Write-Host "⏳ Exécution de l'opération..."
}
```

### Pattern d'alerte multi-niveaux

```powershell
function Write-Alert {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ValidateSet('Low', 'Medium', 'High', 'Critical')]
        [string]$Severity = 'Medium'
    )
    
    $esc = "`e"
    
    $config = @{
        'Low' = @{
            Emoji = 'ℹ️'
            Color = '36'  # Cyan
            Border = '─'
            Blink = $false
        }
        'Medium' = @{
            Emoji = '⚠️'
            Color = '33'  # Yellow
            Border = '─'
            Blink = $false
        }
        'High' = @{
            Emoji = '⚠️'
            Color = '33'  # Yellow bold
            Border = '═'
            Blink = $false
        }
        'Critical' = @{
            Emoji = '🚨'
            Color = '31'  # Red bold
            Border = '█'
            Blink = $true
        }
    }
    
    $cfg = $config[$Severity]
    $emoji = $cfg.Emoji
    $color = $cfg.Color
    $border = $cfg.Border
    
    # En-tête
    Write-Host ""
    Write-Host "${esc}[1;${color}m$($border * 60)${esc}[0m"
    Write-Host "${esc}[1;${color}m${emoji} ALERTE ${Severity.ToUpper()} ${emoji}${esc}[0m"
    Write-Host "${esc}[1;${color}m$($border * 60)${esc}[0m"
    
    # Message (avec effet pour critique)
    if ($cfg.Blink) {
        for ($i = 0; $i -lt 2; $i++) {
            Write-Host "`r${esc}[1;${color}m${Message}${esc}[0m" -NoNewline
            Start-Sleep -Milliseconds 400
            Write-Host "`r$(' ' * $Message.Length)" -NoNewline
            Start-Sleep -Milliseconds 400
        }
    }
    Write-Host "${esc}[1;${color}m${Message}${esc}[0m"
    
    Write-Host "${esc}[1;${color}m$($border * 60)${esc}[0m"
    Write-Host ""
}

# Exemples d'utilisation par niveau
Write-Alert "Mise à jour disponible" -Severity Low
Write-Alert "Espace disque faible (15% restant)" -Severity Medium
Write-Alert "Certificat SSL expire dans 7 jours" -Severity High
Write-Alert "ÉCHEC CRITIQUE : Connexion base de données perdue" -Severity Critical
```

---

## 🔄 Compatibilité entre versions PowerShell

### Différences entre PowerShell 5.1 et 7+

Les capacités de stylisation diffèrent significativement entre les versions de PowerShell et selon les terminaux utilisés.

#### Tableau de compatibilité

|Fonctionnalité|PowerShell 5.1|PowerShell 7+|Windows Terminal|Console classique|
|---|---|---|---|---|
|Séquences ANSI basiques|✅ (avec `[char]27`)|✅ (avec ``e`)|✅|⚠️ Limité|
|Texte gras|✅|✅|✅|❌|
|Texte souligné|✅|✅|✅|❌|
|Texte italique|⚠️|✅|✅|❌|
|Texte clignotant|❌|❌|❌|❌|
|Émojis Unicode|⚠️ Limité|✅|✅|⚠️ Limité|
|Couleurs 256|✅|✅|✅|❌|
|Couleurs RGB|⚠️|✅|✅|❌|

> [!warning] Console Windows classique La console Windows classique (conhost.exe) a un support limité des séquences ANSI. Windows Terminal est fortement recommandé pour une expérience optimale.

### Détection de l'environnement

```powershell
function Test-ANSISupport {
    <#
    .SYNOPSIS
    Teste le support ANSI du terminal actuel
    #>
    
    # Vérification de la version PowerShell
    $isPwsh7Plus = $PSVersionTable.PSVersion.Major -ge 7
    
    # Détection du terminal
    $terminalProgram = $env:TERM_PROGRAM
    $wtSession = $env:WT_SESSION
    
    # Windows Terminal
    $isWindowsTerminal = $null -ne $wtSession
    
    # VS Code Terminal
    $isVSCode = $terminalProgram -eq 'vscode'
    
    # Console classique Windows
    $isConhost = $Host.Name -eq 'ConsoleHost' -and -not $isWindowsTerminal
    
    [PSCustomObject]@{
        PowerShellVersion = $PSVersionTable.PSVersion
        SupportsPwsh7Features = $isPwsh7Plus
        IsWindowsTerminal = $isWindowsTerminal
        IsVSCode = $isVSCode
        IsClassicConsole = $isConhost
        RecommendedForANSI = $isWindowsTerminal -or $isVSCode
        SupportsEmojis = $isPwsh7Plus -and ($isWindowsTerminal -or $isVSCode)
        SupportsAdvancedStyles = -not $isConhost
    }
}

# Utilisation
$support = Test-ANSISupport
if (-not $support.SupportsAdvancedStyles) {
    Write-Warning "Terminal classique détecté. Certaines fonctionnalités peuvent ne pas s'afficher correctement."
    Write-Host "Recommandation: Utilisez Windows Terminal pour une meilleure expérience."
}
```

### Fonction de stylisation adaptative

```powershell
function Write-StyledTextCompatible {
    <#
    .SYNOPSIS
    Affiche du texte stylisé avec détection automatique de compatibilité
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Text,
        
        [switch]$Bold,
        [switch]$Italic,
        [switch]$Underline,
        [string]$Color,
        [switch]$ForceBasic  # Force un affichage basique sans styles
    )
    
    # Détection de l'environnement
    $isPwsh7 = $PSVersionTable.PSVersion.Major -ge 7
    $isModernTerminal = $null -ne $env:WT_SESSION -or $env:TERM_PROGRAM -eq 'vscode'
    
    # Si environnement basique ou ForceBasic activé
    if ($ForceBasic -or (-not $isPwsh7 -and -not $isModernTerminal)) {
        # Affichage simple avec Write-Host -ForegroundColor
        $params = @{ Object = $Text }
        
        if ($Color) {
            $params['ForegroundColor'] = $Color
        }
        
        Write-Host @params
        return
    }
    
    # Utilisation des séquences ANSI
    $esc = if ($isPwsh7) { "`e" } else { [char]27 }
    $codes = @()
    
    if ($Bold) { $codes += "1" }
    if ($Italic -and $isModernTerminal) { $codes += "3" }
    if ($Underline) { $codes += "4" }
    
    # Couleurs
    $colorCodes = @{
        'Black' = '30'; 'Red' = '31'; 'Green' = '32'; 'Yellow' = '33'
        'Blue' = '34'; 'Magenta' = '35'; 'Cyan' = '36'; 'White' = '37'
    }
    
    if ($Color -and $colorCodes.ContainsKey($Color)) {
        $codes += $colorCodes[$Color]
    }
    
    if ($codes.Count -gt 0) {
```