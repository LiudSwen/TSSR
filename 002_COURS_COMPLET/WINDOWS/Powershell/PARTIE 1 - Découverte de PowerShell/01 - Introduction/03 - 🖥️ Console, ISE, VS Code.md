

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

## 🔷 Windows PowerShell Console

La **Console PowerShell** est l'environnement natif de PowerShell, héritée de l'invite de commandes Windows. C'est l'interface la plus légère et la plus rapide pour exécuter des commandes PowerShell.

### Caractéristiques principales

**Accès :**

- Windows + R → `powershell` → Entrée
- Menu Démarrer → Windows PowerShell
- Fichier `powershell.exe` dans `C:\Windows\System32\WindowsPowerShell\v1.0\`

**Avantages :**

- ✅ Démarrage ultra-rapide
- ✅ Consommation minimale de ressources
- ✅ Disponible par défaut sur tous les Windows modernes
- ✅ Parfaite pour l'exécution de commandes ponctuelles

**Limitations :**

- ❌ Interface basique sans coloration syntaxique avancée
- ❌ Pas de complétion intelligente du code
- ❌ Aucun outil de débogage intégré
- ❌ Édition de scripts limitée

### Configuration de la console

```powershell
# Modifier les couleurs de la console
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Green"
Clear-Host

# Personnaliser le titre de la fenêtre
$Host.UI.RawUI.WindowTitle = "PowerShell - Session Admin"

# Configurer la taille du buffer
$pshost = Get-Host
$pswindow = $pshost.UI.RawUI
$newsize = $pswindow.BufferSize
$newsize.Height = 3000
$newsize.Width = 120
$pswindow.BufferSize = $newsize
```

> [!tip] Astuce de productivité Utilisez `F8` dans la console pour afficher l'historique des commandes avec une interface de sélection interactive.

> [!warning] Attention La console PowerShell classique utilise l'encodage legacy Windows. Pour travailler avec UTF-8, préférez Windows Terminal ou définissez `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`.

---

## 🔷 PowerShell ISE

**PowerShell ISE** (Integrated Scripting Environment) est l'IDE officiel de Microsoft pour PowerShell, conçu spécifiquement pour le développement de scripts.

### Interface et fonctionnalités

L'ISE propose une interface graphique divisée en trois panneaux :

- **Panneau de script** : éditeur de code avec numérotation des lignes
- **Panneau de console** : zone d'exécution interactive
- **Panneau de commandes** : explorateur de cmdlets avec recherche

**Accès :**

- Menu Démarrer → Windows PowerShell ISE
- Console → `ise` ou `powershell_ise.exe`

### Fonctionnalités clés

#### Éditeur de script

```powershell
# L'ISE offre la coloration syntaxique automatique
Get-Process | Where-Object {$_.CPU -gt 100} | 
    Select-Object Name, CPU, WorkingSet |
    Sort-Object CPU -Descending

# Raccourcis utiles dans l'ISE
# F5 : Exécuter le script entier
# F8 : Exécuter uniquement la sélection
# Ctrl+J : Insérer un snippet
# Ctrl+M : Démarrer/arrêter un nouveau onglet PowerShell
```

> [!example] Fonctionnalités de l'éditeur
> 
> - **IntelliSense basique** : complétion automatique des cmdlets et paramètres
> - **Snippets intégrés** : modèles de code réutilisables (Ctrl+J)
> - **Multi-onglets** : travail sur plusieurs scripts simultanément
> - **Indentation automatique** : formatage du code
> - **Recherche et remplacement** : avec support des expressions régulières

#### Débogage intégré

```powershell
# Points d'arrêt (breakpoints)
function Test-Debug {
    param($Number)
    
    $result = 0
    # Placer un breakpoint sur la ligne suivante (F9)
    for ($i = 1; $i -le $Number; $i++) {
        $result += $i
    }
    return $result
}

# Commandes de débogage disponibles
# F9 : Ajouter/supprimer un breakpoint
# F5 : Continuer l'exécution
# F10 : Passer à la ligne suivante (step over)
# F11 : Entrer dans la fonction (step into)
# Shift+F11 : Sortir de la fonction (step out)
```

#### Explorateur de commandes

L'ISE inclut un explorateur qui liste toutes les cmdlets disponibles avec :

- Recherche par nom ou module
- Filtrage par verbe et nom
- Insertion automatique dans le script
- Documentation contextuelle

### Limitations de l'ISE

> [!warning] Limitations importantes
> 
> **Fin du développement :**
> 
> - ❌ Plus de nouvelles fonctionnalités depuis PowerShell 5.1
> - ❌ Ne supporte **pas** PowerShell Core (6.x+)
> - ❌ Fonctionne uniquement avec Windows PowerShell 5.1
> 
> **Limitations techniques :**
> 
> - ❌ Pas de support Git intégré
> - ❌ IntelliSense limité par rapport aux IDE modernes
> - ❌ Pas d'extensions ou de personnalisation avancée
> - ❌ Interface non personnalisable (thèmes limités)
> - ❌ Performances faibles sur les gros fichiers
> - ❌ Pas de support pour les modules modernes PSReadLine

### Configuration de l'ISE

```powershell
# Personnaliser l'apparence de l'ISE
$psISE.Options.FontSize = 12
$psISE.Options.FontName = "Consolas"

# Définir les couleurs
$psISE.Options.TokenColors["Command"] = "#0000FF"
$psISE.Options.TokenColors["String"] = "#8B0000"

# Ajouter des addons personnalisés
$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Mon Script",
    {Get-Date},
    "Ctrl+Alt+D"
)

# Sauvegarder le profil ISE
if (!(Test-Path $profile.CurrentUserCurrentHost)) {
    New-Item -Path $profile.CurrentUserCurrentHost -Type File -Force
}
```

> [!info] Quand utiliser l'ISE ? L'ISE reste pertinent pour :
> 
> - ✅ Apprentissage de PowerShell (interface intuitive)
> - ✅ Scripts simples avec Windows PowerShell 5.1
> - ✅ Environnements où VS Code n'est pas installable
> - ✅ Besoin d'un explorateur de commandes graphique

---

## 🔷 Visual Studio Code

**Visual Studio Code** (VS Code) est devenu l'environnement recommandé par Microsoft pour le développement PowerShell moderne. C'est un éditeur open-source, extensible et multi-plateforme.

### Installation et configuration

#### Installation de VS Code

1. **Télécharger VS Code** : https://code.visualstudio.com/
2. **Installer l'extension PowerShell** :
    - Ouvrir VS Code
    - Ctrl+Shift+X pour ouvrir les extensions
    - Rechercher "PowerShell"
    - Installer l'extension officielle de Microsoft

```powershell
# Installation automatique via Winget
winget install Microsoft.VisualStudioCode

# Ou via Chocolatey
choco install vscode

# Installer l'extension PowerShell via CLI
code --install-extension ms-vscode.powershell
```

#### Configuration de base

```json
// settings.json - Configuration recommandée pour PowerShell
{
    "powershell.integratedConsole.focusConsoleOnExecute": false,
    "powershell.codeFormatting.preset": "OTBS",
    "powershell.codeFormatting.autoCorrectAliases": true,
    "powershell.scriptAnalysis.enable": true,
    "powershell.integratedConsole.showOnStartup": false,
    "editor.formatOnSave": true,
    "files.encoding": "utf8",
    "files.autoSave": "afterDelay",
    "[powershell]": {
        "editor.defaultFormatter": "ms-vscode.powershell",
        "editor.tabSize": 4,
        "editor.insertSpaces": true
    }
}
```

### Fonctionnalités avancées

#### IntelliSense intelligent

VS Code offre l'IntelliSense le plus avancé pour PowerShell :

```powershell
# IntelliSense contextuel
Get-Process | Where-Object {
    # IntelliSense suggère les propriétés de System.Diagnostics.Process
    $_.CPU -gt 50
} | ForEach-Object {
    # IntelliSense suggère les méthodes disponibles
    $_.Kill()
}

# Complétion des chemins
Get-ChildItem "C:\Windows\Sys" # Tab → suggère System32, SysWOW64, etc.

# Complétion des paramètres avec aide contextuelle
Get-Service -Name "w*" -ComputerName # IntelliSense affiche tous les paramètres disponibles
```

> [!tip] Raccourcis IntelliSense
> 
> - `Ctrl+Space` : forcer l'affichage de l'IntelliSense
> - `Ctrl+Shift+Space` : afficher l'aide des paramètres
> - `F12` : aller à la définition d'une fonction
> - `Alt+F12` : aperçu de la définition

#### Débogage avancé

```powershell
# Configuration de lancement (launch.json)
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "PowerShell: Lancer le script actuel",
            "type": "PowerShell",
            "request": "launch",
            "script": "${file}",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "PowerShell: Attacher au processus",
            "type": "PowerShell",
            "request": "attach",
            "processId": "${command:PickPSHostProcess}"
        }
    ]
}
```

**Fonctionnalités de débogage :**

|Fonctionnalité|Raccourci|Description|
|---|---|---|
|Points d'arrêt|F9|Breakpoint simple|
|Breakpoint conditionnel|Clic droit sur ligne|S'arrête si condition vraie|
|Logpoints|Clic droit sur ligne|Log sans arrêter l'exécution|
|Exécution|F5|Démarre le débogage|
|Pas à pas|F10|Step over|
|Entrer dans|F11|Step into|
|Sortir de|Shift+F11|Step out|
|Continuer|F5|Continue jusqu'au prochain breakpoint|

```powershell
# Exemple avec breakpoint conditionnel
function Compute-Values {
    param($Items)
    
    foreach ($item in $Items) {
        $result = $item * 2
        # Breakpoint conditionnel : $result -gt 100
        Write-Host "Result: $result"
    }
}
```

#### Analyse de code PSScriptAnalyzer

VS Code intègre PSScriptAnalyzer pour l'analyse statique du code :

```powershell
# PSScriptAnalyzer identifie automatiquement :
# - Erreurs de syntaxe
# - Mauvaises pratiques
# - Problèmes de performance
# - Violations de conventions de nommage

# Exemple d'avertissements détectés
function bad-function {  # ❌ Nom non conforme (PascalCase requis)
    $a = Get-Process     # ⚠️ Variable non utilisée
    Write-Host "test"     # ⚠️ Préférer Write-Output
}

# Configuration personnalisée (PSScriptAnalyzerSettings.psd1)
@{
    Severity = @('Error', 'Warning')
    ExcludeRules = @('PSAvoidUsingWriteHost')
    IncludeRules = @('PSUseConsistentIndentation', 'PSUseConsistentWhitespace')
    Rules = @{
        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = 'space'
            IndentationSize = 4
        }
    }
}
```

#### Intégration Git

```powershell
# VS Code offre une intégration Git complète
# Panneau Source Control : Ctrl+Shift+G

# Opérations disponibles visuellement :
# - Voir les modifications (diff)
# - Staging de fichiers
# - Commits
# - Push/Pull
# - Gestion des branches
# - Résolution de conflits

# Extensions Git recommandées :
# - GitLens : historique détaillé, blame inline
# - Git Graph : visualisation de l'arbre Git
# - Git History : parcourir l'historique
```

#### Gestion multi-fichiers et workspace

```powershell
# VS Code excelle dans la gestion de projets complexes
# Structure typique d'un projet PowerShell :

📁 MonModule/
├── 📁 Public/              # Fonctions exportées
│   ├── Get-MyData.ps1
│   └── Set-MyData.ps1
├── 📁 Private/             # Fonctions internes
│   └── Helper.ps1
├── 📁 Tests/               # Tests Pester
│   └── Module.Tests.ps1
├── MonModule.psd1          # Manifeste
├── MonModule.psm1          # Module principal
└── README.md

# Recherche dans tous les fichiers : Ctrl+Shift+F
# Navigation entre fichiers : Ctrl+P
# Aller au symbole : Ctrl+Shift+O
# Rechercher symbole dans workspace : Ctrl+T
```

### Extensions recommandées

|Extension|Fonctionnalité|
|---|---|
|**PowerShell**|Support officiel PowerShell (obligatoire)|
|**PSScriptAnalyzer**|Analyse de code (inclus dans extension PowerShell)|
|**PowerShell Pro Tools**|Outils pro (conversion EXE, GUI designer)|
|**vscode-icons**|Icônes pour fichiers .ps1, .psm1, .psd1|
|**Bracket Pair Colorizer 2**|Colorisation des accolades|
|**Error Lens**|Affichage inline des erreurs|
|**Code Spell Checker**|Vérification orthographique|
|**Todo Tree**|Suivi des TODO/FIXME|
|**Better Comments**|Commentaires colorés|

```powershell
# Installation d'extensions via CLI
code --install-extension ms-vscode.powershell
code --install-extension irongeek.vscode-ps-debugger
code --install-extension formulahendry.code-runner
```

### Avantages pour le développement

> [!tip] Pourquoi VS Code est l'environnement recommandé
> 
> **Performance :**
> 
> - ✅ Rapide même avec de gros fichiers
> - ✅ Gestion efficace de projets multi-fichiers
> - ✅ Consommation mémoire raisonnable
> 
> **Compatibilité :**
> 
> - ✅ Support de PowerShell 5.1, 7.x et versions futures
> - ✅ Multi-plateforme (Windows, Linux, macOS)
> - ✅ Support de tous les formats de fichiers
> 
> **Productivité :**
> 
> - ✅ IntelliSense ultra-performant
> - ✅ Refactoring de code
> - ✅ Recherche et remplacement avancés
> - ✅ Terminal intégré avec onglets multiples
> - ✅ Snippets personnalisables
> - ✅ Extensions infinies

```powershell
# Snippets personnalisés (powershell.json)
{
    "Advanced Function": {
        "prefix": "func-adv",
        "body": [
            "function ${1:Verb-Noun} {",
            "    [CmdletBinding()]",
            "    param(",
            "        [Parameter(Mandatory=\\$true)]",
            "        [string]\\$${2:ParameterName}",
            "    )",
            "    ",
            "    begin {",
            "        Write-Verbose 'Starting ${1:Verb-Noun}'",
            "    }",
            "    ",
            "    process {",
            "        ${3:# Code here}",
            "    }",
            "    ",
            "    end {",
            "        Write-Verbose 'Completed ${1:Verb-Noun}'",
            "    }",
            "}"
        ],
        "description": "Fonction avancée avec structure complète"
    }
}
```

### Configuration avancée

```json
// settings.json - Configuration professionnelle
{
    // PowerShell
    "powershell.integratedConsole.startInBackground": true,
    "powershell.developer.waitForSessionFileTimeoutSeconds": 60,
    "powershell.startAsLoginShell.osx": true,
    
    // Éditeur
    "editor.formatOnType": true,
    "editor.formatOnPaste": true,
    "editor.minimap.enabled": true,
    "editor.rulers": [80, 120],
    "editor.bracketPairColorization.enabled": true,
    "editor.guides.bracketPairs": true,
    
    // Terminal
    "terminal.integrated.defaultProfile.windows": "PowerShell",
    "terminal.integrated.profiles.windows": {
        "PowerShell": {
            "source": "PowerShell",
            "icon": "terminal-powershell"
        },
        "PowerShell 7": {
            "path": "C:\\Program Files\\PowerShell\\7\\pwsh.exe",
            "icon": "terminal-powershell"
        }
    },
    
    // Fichiers
    "files.associations": {
        "*.ps1xml": "xml",
        "*.psd1": "powershell",
        "*.psm1": "powershell"
    },
    
    // Sécurité
    "security.workspace.trust.enabled": true
}
```

---

## 🔷 Windows Terminal et alternatives

**Windows Terminal** est le terminal moderne de Microsoft qui peut héberger plusieurs shells, dont PowerShell, CMD, et WSL.

### Windows Terminal

#### Installation

```powershell
# Via Microsoft Store (recommandé)
# Rechercher "Windows Terminal"

# Via Winget
winget install Microsoft.WindowsTerminal

# Via Chocolatey
choco install microsoft-windows-terminal
```

#### Caractéristiques principales

**Fonctionnalités modernes :**

- ✅ Onglets multiples
- ✅ Panneaux divisés (split panes)
- ✅ Support GPU pour le rendu
- ✅ Support Unicode et emoji complet
- ✅ Thèmes et transparence
- ✅ Raccourcis clavier personnalisables

```json
// settings.json - Configuration Windows Terminal
{
    "defaultProfile": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
    "profiles": {
        "defaults": {
            "fontFace": "Cascadia Code PL",
            "fontSize": 11,
            "colorScheme": "One Half Dark",
            "useAcrylic": true,
            "acrylicOpacity": 0.9
        },
        "list": [
            {
                "guid": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
                "name": "PowerShell",
                "source": "Windows.Terminal.PowershellCore",
                "startingDirectory": "%USERPROFILE%",
                "icon": "ms-appx:///ProfileIcons/{574e775e-4f2a-5b96-ac1e-a2962a402336}.png"
            }
        ]
    },
    "schemes": [
        {
            "name": "One Half Dark",
            "background": "#282C34",
            "foreground": "#DCDFE4"
        }
    ],
    "actions": [
        { "command": "duplicateTab", "keys": "ctrl+shift+d" },
        { "command": { "action": "splitPane", "split": "horizontal" }, "keys": "alt+shift+-" },
        { "command": { "action": "splitPane", "split": "vertical" }, "keys": "alt+shift+plus" }
    ]
}
```

#### Raccourcis utiles

|Raccourci|Action|
|---|---|
|`Ctrl+Shift+T`|Nouvel onglet|
|`Ctrl+Shift+W`|Fermer l'onglet|
|`Ctrl+Tab`|Onglet suivant|
|`Alt+Shift+D`|Dupliquer l'onglet|
|`Alt+Shift+-`|Split horizontal|
|`Alt+Shift++`|Split vertical|
|`Alt+↑↓←→`|Naviguer entre splits|
|`Ctrl+Shift+P`|Palette de commandes|

#### Avantages pour PowerShell

```powershell
# Support UTF-8 natif
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
"✓ Emoji et caractères Unicode : 你好 🚀 ✨"

# Rendu rapide grâce au GPU
Measure-Command {
    1..1000 | ForEach-Object { Write-Host "Line $_" }
}
# Beaucoup plus rapide qu'avec la console legacy

# Profils personnalisés pour différents usages
# - PowerShell Admin (élevé)
# - PowerShell Standard
# - PowerShell 7
# - Azure Cloud Shell
```

> [!tip] Configuration avancée Windows Terminal supporte les thèmes Oh My Posh pour personnaliser le prompt PowerShell avec des informations Git, durée d'exécution, etc.

### Alternatives populaires

#### ConEmu / Cmder

**ConEmu** est un émulateur de console Windows avancé avec multiplexage de terminaux.

```powershell
# Installation
choco install conemu

# Caractéristiques :
# - Onglets et splits
# - Macros et automatisation
# - Intégration Far Manager
# - Thèmes personnalisables
```

**Cmder** est basé sur ConEmu avec une configuration préétablie.

> [!info] Utilisation ConEmu et Cmder sont moins actifs depuis l'arrivée de Windows Terminal. Ils restent valables pour Windows 7/8 ou besoins spécifiques.

#### Terminus

**Terminus** est un terminal moderne multi-plateforme avec de nombreuses fonctionnalités.

```powershell
# Installation
winget install Eugeny.Terminus

# Caractéristiques distinctives :
# - Interface élégante et moderne
# - Plugins et extensions
# - Synchronisation de configuration
# - Support SSH intégré
# - Gestionnaire de connexions
```

#### Hyper

**Hyper** est un terminal construit avec Electron, extensible via JavaScript.

```powershell
# Installation
choco install hyper

# Points forts :
# - Extensions JavaScript/CSS
# - Thèmes communautaires
# - Interface minimaliste
# - Multi-plateforme
```

> [!warning] Performance Hyper peut être plus lent que Windows Terminal en raison d'Electron. À utiliser si l'extensibilité JavaScript est prioritaire.

---

## 🔷 Comparaison des environnements

### Tableau récapitulatif

|Critère|Console|ISE|VS Code|Windows Terminal|
|---|---|---|---|---|
|**Vitesse de démarrage**|⭐⭐⭐⭐⭐|⭐⭐⭐|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|
|**IntelliSense**|❌|⭐⭐|⭐⭐⭐⭐⭐|❌|
|**Débogage**|❌|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|❌|
|**Édition de scripts**|⭐|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|⭐|
|**Support PS 7+**|✅|❌|✅|✅|
|**Multi-plateforme**|❌|❌|✅|Partiel|
|**Gestion projet**|❌|⭐⭐|⭐⭐⭐⭐⭐|❌|
|**Personnalisation**|⭐⭐|⭐⭐|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|
|**Consommation RAM**|Faible|Moyenne|Moyenne|Faible|
|**Intégration Git**|❌|❌|⭐⭐⭐⭐⭐|⭐|

### Cas d'usage recommandés

> [!example] Console PowerShell **Utiliser pour :**
> 
> - Exécution rapide de commandes ponctuelles
> - Scripts d'administration système simples
> - Tâches automatisées via planificateur
> - Environnements serveurs sans GUI
> - Connexion à distance via PowerShell Remoting

> [!example] PowerShell ISE **Utiliser pour :**
> 
> - Apprentissage de PowerShell (interface guidée)
> - Scripts Windows PowerShell 5.1 simples
> - Environnements legacy sans VS Code
> - Besoin de l'explorateur de commandes graphique
> - **Ne plus utiliser pour nouveaux projets**

> [!example] Visual Studio Code **Utiliser pour :**
> 
> - ✅ **Tous les nouveaux projets PowerShell**
> - Développement de modules et scripts complexes
> - Projets multi-fichiers
> - Collaboration avec gestion de versions (Git)
> - Scripts PowerShell 7+ et cross-platform
> - Développement professionnel

> [!example] Windows Terminal **Utiliser pour :**
> 
> - Travail quotidien en ligne de commande
> - Besoin de plusieurs shells simultanés
> - Interface moderne et personnalisable
> - Intégration avec WSL, Azure Cloud Shell
> - Alternative à la console legacy

### Choix selon le profil

```powershell
# Administrateur système
# → Windows Terminal + VS Code
# Terminal pour les tâches quotidiennes, VS Code pour les scripts

# Développeur PowerShell
# → VS Code exclusivement
# Environnement complet pour le développement

# Débutant PowerShell
# → ISE pour débuter, puis VS Code
# ISE pour apprendre l'interface, migration rapide vers VS Code

# Automatisation serveur
# → Console PowerShell
# Légèreté et disponibilité universelle

# DevOps / CI/CD
# → VS Code + Windows Terminal
# VS Code pour le développement, Terminal pour les tests
```

### Migration ISE → VS Code

```powershell
# Reproduire l'expérience ISE dans VS Code

# 1. Installer l'extension ISE Mode
code --install-extension ms-vscode.powershell-preview

# 2. Activer le mode ISE dans les paramètres
# Ctrl+, → Rechercher "ISE Mode" → Cocher l'option

# 3. Raccourcis ISE dans VS Code
# F5 : Exécuter le script (comme ISE)
# F8 : Exécuter la sélection (comme ISE)
# Ctrl+F5 : Exécuter sans débogage

# 4. Affichage similaire
# Vue → Apparence → Afficher le panneau (console en bas)
# Vue → Apparence → Disposition → Inverser
```

> [!tip] Transition en douceur L'extension PowerShell pour VS Code propose un "ISE Mode" qui reproduit les raccourcis et le comportement de l'ISE pour faciliter la transition.

---

## 📊 Résumé des environnements

### Évolution recommandée

```
Débutant
   ├── ISE (apprentissage)
   └── Console (commandes simples)
          ↓
Intermédiaire
   ├── VS Code (scripts)
   └── Windows Terminal (quotidien)
          ↓
Avancé
   └── VS Code + Windows Terminal + Extensions
```

### Check-list installation professionnelle

```powershell
# Configuration optimale pour un environnement professionnel

# 1. Installer PowerShell 7+
winget install Microsoft.PowerShell

# 2. Installer Windows Terminal
winget install Microsoft.WindowsTerminal

# 3. Installer VS Code
winget install Microsoft.VisualStudioCode

# 4. Installer les extensions VS Code essentielles
code --install-extension ms-vscode.powershell
code --install-extension eamodio.gitlens
code --install-extension pkief.material-icon-theme

# 5. Configurer Git (si développement de modules)
git config --global user.name "Votre Nom"
git config --global user.email "votre@email.com"

# 6. Installer des modules utiles
Install-Module -Name PSReadLine -Force -SkipPublisherCheck
Install-Module -Name Pester -Force

# 7. Configurer le profil PowerShell
if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force
}
notepad $PROFILE

# 8. Vérifier l'installation
pwsh --version
code --version
```

> [!tip] Profil PowerShell de démarrage Ajoutez ces lignes à votre `$PROFILE` pour une expérience optimale :
> 
> ```powershell
> # Importer PSReadLine pour l'auto-complétion améliorée
> Import-Module PSReadLine
> Set-PSReadLineOption -PredictionSource History
> Set-PSReadLineOption -PredictionViewStyle ListView
> 
> # Alias utiles
> Set-Alias -Name ll -Value Get-ChildItem
> Set-Alias -Name grep -Value Select-String
> 
> # Fonction pour ouvrir VS Code dans le dossier courant
> function code. { code $PWD }
> ```

---

## 🎯 Différences entre environnements d'exécution

### Architecture et moteur PowerShell

Tous les environnements exécutent le même **moteur PowerShell** mais avec des interfaces différentes :

```powershell
# Le moteur PowerShell reste identique
# Ce qui change : l'interface, les outils de développement, l'expérience utilisateur

# Vérifier la version du moteur dans chaque environnement
$PSVersionTable

Name                           Value
----                           -----
PSVersion                      7.4.0
PSEdition                      Core
GitCommitId                    7.4.0
OS                             Microsoft Windows 10.0.22631
Platform                       Win32NT
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0
```

### Différences de comportement

#### Gestion des encodages

```powershell
# Console PowerShell (Legacy)
# Utilise l'encodage système par défaut (souvent CP850 ou Windows-1252)
[Console]::OutputEncoding
# Résultat : System.Text.SBCSCodePageEncoding

# Problème avec les caractères spéciaux
"Caractères accentués : é à ç" | Out-File test.txt
Get-Content test.txt  # Peut afficher incorrectement

# Windows Terminal + PowerShell 7
# UTF-8 par défaut
[Console]::OutputEncoding
# Résultat : System.Text.UTF8Encoding

# Solution : forcer UTF-8 dans la console legacy
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

#### Rendu graphique et performance

```powershell
# Test de performance du rendu
Measure-Command {
    1..5000 | ForEach-Object {
        Write-Host "Ligne $_" -ForegroundColor Green
    }
}

# Console Legacy : ~15-20 secondes
# Windows Terminal : ~2-3 secondes (GPU accelerated)
# VS Code Terminal : ~3-5 secondes
```

> [!info] Accélération GPU Windows Terminal utilise DirectX pour le rendu, ce qui le rend significativement plus rapide pour afficher de grandes quantités de texte.

#### Variables d'environnement spécifiques

```powershell
# Dans VS Code avec l'extension PowerShell
$psEditor  # Objet disponible uniquement dans VS Code
# Permet d'interagir avec l'éditeur VS Code

# Exemple : obtenir le chemin du fichier ouvert
$psEditor.GetEditorContext().CurrentFile.Path

# Ouvrir un fichier dans VS Code depuis PowerShell
$psEditor.Workspace.OpenFile("C:\Scripts\monscript.ps1")

# Dans PowerShell ISE
$psISE  # Objet disponible uniquement dans ISE
$psISE.CurrentFile.Editor.InsertText("# Mon code")
$psISE.CurrentFile.Save()
```

### Compatibilité des scripts entre environnements

#### Scripts portables

```powershell
# Bonnes pratiques pour des scripts compatibles tous environnements

function Write-ColorMessage {
    [CmdletBinding()]
    param(
        [string]$Message,
        [ConsoleColor]$Color = 'White'
    )
    
    # Détection de l'environnement
    if ($host.Name -eq 'ConsoleHost') {
        # Console standard
        Write-Host $Message -ForegroundColor $Color
    }
    elseif ($host.Name -eq 'Windows PowerShell ISE Host') {
        # ISE
        Write-Host $Message -ForegroundColor $Color
    }
    elseif ($host.Name -eq 'Visual Studio Code Host') {
        # VS Code
        Write-Host $Message -ForegroundColor $Color
    }
    else {
        # Fallback pour autres environnements
        Write-Output $Message
    }
}

# Détection de l'interface graphique
function Test-InteractiveSession {
    [Environment]::UserInteractive -and 
    -not [Environment]::GetCommandLineArgs().Contains('-NonInteractive')
}

if (Test-InteractiveSession) {
    Write-ColorMessage "Session interactive détectée" -Color Green
} else {
    Write-Output "Exécution en mode non-interactif"
}
```

#### Gestion des chemins et séparateurs

```powershell
# Utiliser Join-Path pour la portabilité cross-platform
# Mauvais (dépend de l'OS)
$path = "C:\Users\John\Documents\script.ps1"

# Bon (portable)
$path = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\script.ps1"

# PowerShell 7+ : opérateur portable
$path = $env:USERPROFILE, "Documents", "script.ps1" -join [IO.Path]::DirectorySeparatorChar

# Ou encore mieux avec PowerShell 6+
$path = Join-Path $env:USERPROFILE "Documents" "script.ps1"
```

### Sécurité et politique d'exécution

```powershell
# La politique d'exécution s'applique différemment selon l'environnement

# Vérifier la politique actuelle
Get-ExecutionPolicy -List

Scope          ExecutionPolicy
-----          ---------------
MachinePolicy  Undefined
UserPolicy     Undefined
Process        Undefined
CurrentUser    RemoteSigned
LocalMachine   Restricted

# Dans VS Code
# Les scripts ouverts dans l'éditeur ne sont PAS soumis à ExecutionPolicy
# Car ils sont considérés comme "édités" et non "téléchargés"

# Dans la Console
# ExecutionPolicy s'applique strictement
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Bypass temporaire pour un script
powershell.exe -ExecutionPolicy Bypass -File "C:\Scripts\monscript.ps1"

# Dans ISE
# Même comportement qu'en Console pour l'exécution de fichiers
```

> [!warning] Sécurité Ne jamais utiliser `Set-ExecutionPolicy Unrestricted` de façon permanente. Préférez `RemoteSigned` qui autorise les scripts locaux mais protège contre les scripts téléchargés non signés.

### Limitations spécifiques par environnement

#### Console PowerShell

```powershell
# Limitations connues :

# 1. Pas de coloration syntaxique en temps réel
Get-Process | Where-Object {$_.CPU -gt 100}
# Tout s'affiche en blanc sur fond bleu/noir

# 2. Historique limité (50 commandes par défaut)
(Get-PSReadLineOption).MaximumHistoryCount  # 4096 par défaut avec PSReadLine

# 3. Pas de complétion intelligente sans PSReadLine
# Tab completion basique uniquement

# 4. Buffer de sortie limité (9999 lignes max par défaut)
$host.UI.RawUI.BufferSize
# Height: 9999, Width: 120

# Solution : augmenter le buffer
$buffer = $host.UI.RawUI.BufferSize
$buffer.Height = 30000
$host.UI.RawUI.BufferSize = $buffer
```

#### PowerShell ISE

```powershell
# Limitations importantes :

# 1. Ne supporte PAS PowerShell Core/7+
# Reste bloqué sur Windows PowerShell 5.1

# 2. Pas de PSReadLine
# Pas d'historique prédictif ni de complétion avancée

# 3. Pas de support pour certains modules modernes
Import-Module Microsoft.PowerShell.ConsoleGuiTools  # ❌ Erreur dans ISE

# 4. Performances limitées sur gros fichiers (>5000 lignes)
# L'éditeur devient lent

# 5. Pas de support pour les caractères ANSI
Write-Host "`e[31mTexte rouge`e[0m"  # Ne s'affiche pas correctement dans ISE

# 6. Console intégrée limitée
# Pas de split horizontal/vertical
# Pas d'onglets multiples dans la console
```

#### Visual Studio Code

```powershell
# Limitations et considérations :

# 1. Consommation mémoire plus élevée
# VS Code charge tout l'environnement Electron + Extensions
# Minimum ~200-300 MB de RAM

# 2. Démarrage plus lent que la console
# Mais compense avec la productivité

# 3. Nécessite configuration initiale
# Extension PowerShell obligatoire
# Configuration settings.json

# 4. Dépendance aux extensions
# Si l'extension PowerShell plante, l'IntelliSense disparaît

# Vérifier le statut de l'extension PowerShell
# Palette de commandes (Ctrl+Shift+P) → "PowerShell: Show Session Menu"
```

#### Windows Terminal

```powershell
# Limitations :

# 1. C'est uniquement un émulateur de terminal
# Pas d'éditeur de code intégré
# Pas de débogueur
# Pas d'IntelliSense

# 2. Configuration en JSON
# Pas d'interface graphique pour tous les paramètres
# Nécessite édition manuelle du settings.json

# 3. Nécessite Windows 10 1903+ / Windows 11
# Pas disponible sur Windows 7/8

# 4. Profils multiples peuvent créer confusion
# Bien organiser ses profils PowerShell 5.1 vs 7
```

---

## 🔧 Optimisation et personnalisation avancée

### Profil PowerShell universel

```powershell
# Créer un profil qui fonctionne dans tous les environnements

# Emplacement du profil selon l'environnement
# Console : $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# ISE : $HOME\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1
# VS Code : $HOME\Documents\PowerShell\Microsoft.VSCode_profile.ps1

# Profil universel recommandé :
# $PROFILE.CurrentUserAllHosts
# S'applique à tous les hosts PowerShell

# Contenu du profil universel
# ============================================

# Détection de l'environnement
$InVSCode = $host.Name -eq 'Visual Studio Code Host'
$InISE = $host.Name -eq 'Windows PowerShell ISE Host'
$InConsole = $host.Name -eq 'ConsoleHost'

# Configuration PSReadLine (si disponible)
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    
    # Raccourcis clavier
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

# Alias personnalisés
Set-Alias -Name ll -Value Get-ChildItem -Option AllScope
Set-Alias -Name grep -Value Select-String -Option AllScope
Set-Alias -Name touch -Value New-Item -Option AllScope

# Fonctions utiles
function prompt {
    $location = Get-Location
    $drive = $location.Drive.Name
    $path = $location.Path.Replace($location.Drive.Root, '')
    
    Write-Host "PS " -NoNewline -ForegroundColor Cyan
    Write-Host "$drive`:\" -NoNewline -ForegroundColor Yellow
    Write-Host "$path" -NoNewline -ForegroundColor Green
    
    # Intégration Git (si dans un repo)
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitBranch = git branch --show-current 2>$null
        if ($gitBranch) {
            Write-Host " ($gitBranch)" -NoNewline -ForegroundColor Magenta
        }
    }
    
    return "> "
}

function Get-CommandHistory {
    Get-Content (Get-PSReadLineOption).HistorySavePath
}

function Clear-CommandHistory {
    Remove-Item (Get-PSReadLineOption).HistorySavePath
    Write-Host "Historique effacé" -ForegroundColor Green
}

function Update-PowerShellHelp {
    Write-Host "Mise à jour de l'aide PowerShell..." -ForegroundColor Cyan
    Update-Help -ErrorAction SilentlyContinue -Force
    Write-Host "Mise à jour terminée" -ForegroundColor Green
}

# Message de bienvenue
Write-Host "PowerShell $($PSVersionTable.PSVersion) - $($host.Name)" -ForegroundColor Cyan

# Spécifique à VS Code
if ($InVSCode) {
    Write-Host "Extensions VS Code actives" -ForegroundColor Green
}

# Spécifique à ISE
if ($InISE) {
    Write-Host "Mode ISE - Considérez la migration vers VS Code" -ForegroundColor Yellow
}
```

### Thèmes et apparence

#### Windows Terminal - Thèmes personnalisés

```json
// Thème Dark+ (inspiré de VS Code)
{
    "name": "Dark+",
    "black": "#000000",
    "red": "#cd3131",
    "green": "#0dbc79",
    "yellow": "#e5e510",
    "blue": "#2472c8",
    "purple": "#bc3fbc",
    "cyan": "#11a8cd",
    "white": "#e5e5e5",
    "brightBlack": "#666666",
    "brightRed": "#f14c4c",
    "brightGreen": "#23d18b",
    "brightYellow": "#f5f543",
    "brightBlue": "#3b8eea",
    "brightPurple": "#d670d6",
    "brightCyan": "#29b8db",
    "brightWhite": "#ffffff",
    "background": "#1e1e1e",
    "foreground": "#cccccc",
    "selectionBackground": "#264f78",
    "cursorColor": "#ffffff"
}

// Thème Dracula
{
    "name": "Dracula",
    "black": "#21222c",
    "red": "#ff5555",
    "green": "#50fa7b",
    "yellow": "#f1fa8c",
    "blue": "#bd93f9",
    "purple": "#ff79c6",
    "cyan": "#8be9fd",
    "white": "#f8f8f2",
    "brightBlack": "#6272a4",
    "brightRed": "#ff6e6e",
    "brightGreen": "#69ff94",
    "brightYellow": "#ffffa5",
    "brightBlue": "#d6acff",
    "brightPurple": "#ff92df",
    "brightCyan": "#a4ffff",
    "brightWhite": "#ffffff",
    "background": "#282a36",
    "foreground": "#f8f8f2",
    "selectionBackground": "#44475a",
    "cursorColor": "#f8f8f2"
}

// Thème Fallout 4
{
    "name": "Fallout 4 Terminal",
    "background": "#0C0C0C",
    "black": "#0C0C0C",
    "blue": "#0C0C0C",
    "brightBlack": "#26E476",
    "brightBlue": "#3B78FF",
    "brightCyan": "#61D6D6",
    "brightGreen": "#26E476",
    "brightPurple": "#B4009E",
    "brightRed": "#E74856",
    "brightWhite": "#26E476",
    "brightYellow": "#F9F1A5",
    "cursorColor": "#26E476",
    "cyan": "#26E476",
    "foreground": "#26E476",
    "green": "#26E476",
    "purple": "#881798",
    "red": "#C50F1F",
    "selectionBackground": "#26E476",
    "white": "#26E476",
    "yellow": "#C19C00"
}
```

#### VS Code - Thèmes recommandés pour PowerShell

```powershell
# Installation de thèmes populaires via CLI

# One Dark Pro
code --install-extension zhuangtongfa.material-theme

# Dracula Official
code --install-extension dracula-theme.theme-dracula

# Night Owl
code --install-extension sdras.night-owl

# Tokyo Night
code --install-extension enkia.tokyo-night

# Activation dans settings.json
"workbench.colorTheme": "One Dark Pro"
```

### Performances et optimisation

```powershell
# Optimisation du démarrage PowerShell

# 1. Profil léger
# Éviter de charger trop de modules au démarrage
# Import-Module uniquement ce qui est nécessaire

# Mauvais
Import-Module ActiveDirectory
Import-Module Az
Import-Module SqlServer
# Ralentit considérablement le démarrage

# Bon
# Charger à la demande avec fonction wrapper
function Get-ADUserInfo {
    if (-not (Get-Module ActiveDirectory)) {
        Import-Module ActiveDirectory
    }
    Get-ADUser @args
}

# 2. Compilation JIT
# PowerShell compile les scripts à la volée
# Utiliser des fonctions plutôt que des scripts répétés

# 3. PSReadLine - optimisation
Set-PSReadLineOption -MaximumHistoryCount 10000  # Augmenter si nécessaire
Set-PSReadLineOption -HistoryNoDuplicates  # Éviter doublons

# 4. Désactiver la télémétrie (optionnel)
$env:POWERSHELL_TELEMETRY_OPTOUT = 1

# 5. Mesurer le temps de chargement du profil
Measure-Command { . $PROFILE }
# Si > 2 secondes, optimiser le profil
```

---

## 📚 Cas pratiques et workflows

### Workflow développeur

```powershell
# Configuration optimale pour développer des modules PowerShell

# 1. Structure de projet dans VS Code
$projectRoot = "C:\Dev\MonModule"

# Créer la structure
New-Item -Path $projectRoot -ItemType Directory -Force
Set-Location $projectRoot

# Initialiser Git
git init
git config user.name "Votre Nom"
git config user.email "votre@email.com"

# Créer .gitignore
@"
*.ps1xml.bak
*.swp
*~
.DS_Store
bin/
obj/
*.user
*.suo
*.exe
"@ | Out-File .gitignore -Encoding utf8

# Structure du module
$folders = @('Public', 'Private', 'Tests', 'Docs')
$folders | ForEach-Object {
    New-Item -Path "$projectRoot\$_" -ItemType Directory -Force
}

# 2. Ouvrir dans VS Code
code $projectRoot

# 3. Configurer les tâches VS Code (.vscode/tasks.json)
$tasksConfig = @"
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Test Module",
            "type": "shell",
            "command": "Invoke-Pester",
            "args": ["-Path", "./Tests"],
            "problemMatcher": []
        },
        {
            "label": "Build Module",
            "type": "shell",
            "command": "./Build.ps1",
            "problemMatcher": []
        }
    ]
}
"@

New-Item -Path "$projectRoot\.vscode" -ItemType Directory -Force
$tasksConfig | Out-File "$projectRoot\.vscode\tasks.json" -Encoding utf8

# 4. Workflow de développement
# - Écrire le code dans VS Code
# - F5 pour tester
# - Ctrl+Shift+B pour exécuter les tâches
# - Terminal intégré pour Git
```

### Workflow administrateur système

```powershell
# Configuration pour administration quotidienne

# 1. Windows Terminal avec profils multiples
# - Profil "Admin" en mode élevé
# - Profil "Standard" pour tâches courantes
# - Profil "Remote" pour connexions à distance

# 2. Scripts d'administration dans VS Code
# Organiser par catégorie
$adminScripts = "C:\Admin\Scripts"
New-Item -Path $adminScripts -ItemType Directory -Force

# Structure recommandée
@"
C:\Admin\Scripts\
├── AD\              # Active Directory
├── Exchange\        # Exchange Server
├── Monitoring\      # Surveillance
├── Backup\          # Sauvegardes
├── Network\         # Réseau
└── Audit\           # Audits
"@

# 3. Alias pour accès rapide
function admin {
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoExit -Command cd C:\Admin\Scripts"
}

function edit-script {
    param($ScriptName)
    code "C:\Admin\Scripts\$ScriptName"
}

# 4. Logging centralisé
function Write-AdminLog {
    param(
        [string]$Message,
        [ValidateSet('Info','Warning','Error')]
        [string]$Level = 'Info'
    )
    
    $logPath = "C:\Admin\Logs\admin_$(Get-Date -Format 'yyyy-MM').log"
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp [$Level] $Message" | Out-File $logPath -Append
}
```

### Workflow DevOps / CI/CD

```powershell
# Intégration dans pipeline CI/CD

# 1. Tests automatisés avec Pester
# Tests/Module.Tests.ps1
Describe "Module Tests" {
    BeforeAll {
        Import-Module ./MonModule.psd1 -Force
    }
    
    It "Module should import successfully" {
        Get-Module MonModule | Should -Not -BeNullOrEmpty
    }
    
    It "All functions should have help" {
        $commands = Get-Command -Module MonModule
        foreach ($cmd in $commands) {
            Get-Help $cmd.Name | Should -Not -BeNullOrEmpty
        }
    }
}

# 2. Script de build
# Build.ps1
param(
    [ValidateSet('Development','Production')]
    [string]$Configuration = 'Development'
)

Write-Host "Building module in $Configuration mode" -ForegroundColor Cyan

# Exécuter les tests
$testResults = Invoke-Pester -Path ./Tests -PassThru
if ($testResults.FailedCount -gt 0) {
    throw "Tests failed"
}

# Copier les fichiers dans le répertoire de sortie
$outputPath = "./Output/$Configuration"
New-Item -Path $outputPath -ItemType Directory -Force

Copy-Item -Path ./Public -Destination $outputPath -Recurse -Force
Copy-Item -Path ./Private -Destination $outputPath -Recurse -Force
Copy-Item -Path ./*.psd1 -Destination $outputPath -Force

Write-Host "Build completed successfully" -ForegroundColor Green

# 3. Intégration dans Azure DevOps / GitHub Actions
# .github/workflows/test.yml
@"
name: Test PowerShell Module

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Pester tests
        shell: pwsh
        run: |
          Install-Module Pester -Force -SkipPublisherCheck
          Invoke-Pester -Path ./Tests -OutputFormat NUnitXml -OutputFile testResults.xml
      - name: Publish test results
        uses: EnricoMi/publish-unit-test-result-action@v1
        if: always()
        with:
          files: testResults.xml
"@
```

> [!tip] Bonne pratique Toujours tester vos scripts dans plusieurs environnements (Console, VS Code, exécution non-interactive) pour assurer leur portabilité.

---

## 🎓 Résumé et recommandations finales

### Récapitulatif des environnements

|Environnement|Usage principal|Niveau recommandé|
|---|---|---|
|**Console PowerShell**|Commandes rapides, scripts automatisés|Débutant à Expert|
|**PowerShell ISE**|Apprentissage uniquement (legacy)|Débutant|
|**VS Code**|Développement professionnel|Intermédiaire à Expert|
|**Windows Terminal**|Interface quotidienne moderne|Tous niveaux|

### Parcours d'apprentissage recommandé

```
📍 Étape 1 : Démarrer
└── Console PowerShell OU PowerShell ISE
    └── Apprendre les cmdlets de base
    └── Exécuter des commandes simples

📍 Étape 2 : Progresser
└── Windows Terminal
    └── Interface moderne pour le quotidien
    └── Configuration personnalisée

📍 Étape 3 : Développer
└── Visual Studio Code
    └── Écriture de scripts complexes
    └── Développement de modules
    └── Intégration Git
    └── Débogage avancé

📍 Étape 4 : Maîtriser
└── VS Code + Windows Terminal + Automation
    └── Workflows optimisés
    └── CI/CD
    └── Collaboration d'équipe
```

### Checklist finale

> [!example] Environnement PowerShell optimal
> 
> ✅ **PowerShell 7+** installé ✅ **Windows Terminal** configuré avec profils personnalisés ✅ **VS Code** avec extension PowerShell ✅ **PSReadLine** pour historique prédictif ✅ **Git** configuré pour versioning ✅ **Profil PowerShell** optimisé et portable ✅ **Thème** adapté à vos préférences ✅ **Pester** pour les tests unitaires ✅ **PSScriptAnalyzer** pour la qualité du code ✅ **Backup** de vos configurations

### Commande finale de vérification

```powershell
# Script de vérification de l'environnement PowerShell

function Test-PowerShellEnvironment {
    Write-Host "`n=== Vérification de l'environnement PowerShell ===" -ForegroundColor Cyan
    
    # Version PowerShell
    Write-Host "`nVersion PowerShell:" -ForegroundColor Yellow
    $PSVersionTable.PSVersion
    
    # Environnement actuel
    Write-Host "`nEnvironnement actuel:" -ForegroundColor Yellow
    $host.Name
    
    # Modules importants
    Write-Host "`nModules clés:" -ForegroundColor Yellow
    $modules = @('PSReadLine', 'Pester', 'PSScriptAnalyzer')
    foreach ($module in $modules) {
        $installed = Get-Module -ListAvailable -Name $module
        if ($installed) {
            Write-Host "  ✓ $module $($installed.Version)" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $module (non installé)" -ForegroundColor Red
        }
    }
    
    # Profil PowerShell
    Write-Host "`nProfil PowerShell:" -ForegroundColor Yellow
    if (Test-Path $PROFILE) {
        Write-Host "  ✓ Profil configuré : $PROFILE" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Aucun profil (créer avec : New-Item $PROFILE -Force)" -ForegroundColor Red
    }
    
    # Politique d'exécution
    Write-Host "`nPolitique d'exécution:" -ForegroundColor Yellow
    Get-ExecutionPolicy -List | Format-Table
    
    # Git
    Write-Host "Git:" -ForegroundColor Yellow
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitVersion = git --version
        Write-Host "  ✓ $gitVersion" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Git non installé" -ForegroundColor Red
    }
    
    # VS Code
    Write-Host "Visual Studio Code:" -ForegroundColor Yellow
    if (Get-Command code -ErrorAction SilentlyContinue) {
        $codeVersion = code --version | Select-Object -First 1
        Write-Host "  ✓ Version $codeVersion" -ForegroundColor Green
    } else {
        Write-Host "  ✗ VS Code non installé" -ForegroundColor Red
    }
    
    Write-Host "`n=== Vérification terminée ===" -ForegroundColor Cyan
}

# Exécuter la vérification
Test-PowerShellEnvironment
```

---

## 🏁 Conclusion

Le choix de l'environnement PowerShell dépend de vos besoins :

- 🚀 **Pour débuter** : Console ou ISE pour l'apprentissage
- 💼 **Pour l'administration quotidienne** : Windows Terminal
- 🛠️ **Pour le développement** : Visual Studio Code (obligatoire)
- ⚡ **Pour l'automatisation** : Console en mode non-interactif

**L'environnement idéal combine :**

- **Windows Terminal** pour l'interface quotidienne
- **VS Code** pour l'édition et le développement
- **PowerShell 7+** pour bénéficier des dernières fonctionnalités

> [!tip] Conseil final Investissez du temps dans la configuration de votre environnement. Un bon environnement de travail améliore drastiquement votre productivité et votre plaisir à coder en PowerShell !