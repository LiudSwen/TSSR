

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

## 🔖 Extension .ps1

L'extension `.ps1` est l'extension standard pour les scripts PowerShell. Cette convention permet au système d'exploitation et aux éditeurs de reconnaître automatiquement le type de fichier et d'appliquer la coloration syntaxique appropriée.

> [!info] Pourquoi .ps1 ? Le "1" dans `.ps1` fait référence à PowerShell version 1, la première version du langage. Bien que PowerShell soit aujourd'hui en version 7+, l'extension est restée `.ps1` pour des raisons de compatibilité.

### Caractéristiques importantes

- **Reconnaissance automatique** : Les fichiers `.ps1` sont automatiquement associés à PowerShell
- **Exécution** : Peuvent être exécutés directement ou via l'interpréteur PowerShell
- **Sécurité** : Soumis à la politique d'exécution de scripts (Execution Policy)
- **Portabilité** : Fonctionnent sur Windows, Linux et macOS avec PowerShell Core

> [!warning] Politique d'exécution Par défaut sur Windows, l'exécution de scripts PowerShell peut être restreinte. Vous devrez peut-être ajuster la politique d'exécution avec `Set-ExecutionPolicy`.

---

## ✏️ Création et édition de fichiers

### Créer un fichier .ps1

Il existe plusieurs méthodes pour créer un script PowerShell :

```powershell
# Méthode 1 : Avec New-Item
New-Item -Path "MonScript.ps1" -ItemType File

# Méthode 2 : Avec Out-File
"# Mon premier script" | Out-File -FilePath "MonScript.ps1"

# Méthode 3 : Avec Set-Content
Set-Content -Path "MonScript.ps1" -Value "# Mon premier script"

# Méthode 4 : Redirection simple
"# Mon premier script" > MonScript.ps1
```

### Éditeurs recommandés

|Éditeur|Avantages|Utilisation|
|---|---|---|
|**Visual Studio Code**|Intellisense, débogage, extensions|Développement professionnel|
|**PowerShell ISE**|Intégré à Windows, simple|Scripts rapides sur Windows|
|**Notepad++**|Léger, coloration syntaxique|Édition rapide|
|**vim/nano**|Ligne de commande, universel|Administration serveur|

> [!tip] VS Code avec PowerShell Extension Pour une expérience optimale, installez l'extension "PowerShell" dans VS Code. Elle offre l'autocomplétion, le débogage intégré, et l'analyse de code en temps réel.

### Éditer un fichier existant

```powershell
# Ouvrir dans l'éditeur par défaut
notepad MonScript.ps1

# Ouvrir dans VS Code (si installé)
code MonScript.ps1

# Ouvrir dans PowerShell ISE
ise MonScript.ps1

# Lire le contenu
Get-Content MonScript.ps1

# Ajouter du contenu à la fin
Add-Content -Path "MonScript.ps1" -Value "Write-Host 'Nouvelle ligne'"
```

---

## 🔤 Encodage de fichiers

L'encodage est crucial en PowerShell car un mauvais encodage peut causer des problèmes d'affichage de caractères ou même empêcher l'exécution du script.

### UTF-8 avec BOM (recommandé)

> [!info] Qu'est-ce que le BOM ? Le BOM (Byte Order Mark) est une signature de 3 octets placée au début d'un fichier UTF-8 pour indiquer l'encodage. PowerShell Windows le préfère pour une compatibilité maximale.

```powershell
# Créer un fichier avec UTF-8 BOM
$content = "Write-Host 'Bonjour PowerShell 🚀'"
$utf8WithBom = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText("MonScript.ps1", $content, $utf8WithBom)

# Méthode alternative avec Out-File (ajoute BOM par défaut sur Windows)
$content | Out-File -FilePath "MonScript.ps1" -Encoding UTF8
```

### Autres encodages

```powershell
# UTF-8 sans BOM (PowerShell Core par défaut)
$content | Out-File -FilePath "MonScript.ps1" -Encoding utf8NoBOM

# ASCII (caractères anglais uniquement)
$content | Out-File -FilePath "MonScript.ps1" -Encoding ASCII

# Unicode (UTF-16 LE)
$content | Out-File -FilePath "MonScript.ps1" -Encoding Unicode
```

### Vérifier l'encodage d'un fichier

```powershell
# Lire les premiers octets pour détecter le BOM
$bytes = Get-Content -Path "MonScript.ps1" -Encoding Byte -TotalCount 3
if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    Write-Host "UTF-8 avec BOM détecté"
}
```

> [!warning] Pièges courants
> 
> - Les éditeurs différents peuvent utiliser des encodages différents par défaut
> - Les caractères spéciaux (é, à, ç, emojis) nécessitent UTF-8
> - Les scripts créés sur Linux peuvent manquer le BOM nécessaire sur Windows

> [!tip] Bonnes pratiques d'encodage
> 
> - **Windows PowerShell** : UTF-8 avec BOM
> - **PowerShell Core (cross-platform)** : UTF-8 avec ou sans BOM fonctionne
> - Configurez votre éditeur pour utiliser UTF-8 avec BOM par défaut
> - Ajoutez un commentaire en début de script précisant l'encodage attendu

---

## 🏗️ Structure de base d'un script

Un script PowerShell bien structuré suit généralement cette organisation :

```powershell
<#
.SYNOPSIS
    Courte description du script

.DESCRIPTION
    Description détaillée de ce que fait le script

.PARAMETER NomParametre
    Description du paramètre

.EXAMPLE
    .\MonScript.ps1 -NomParametre "valeur"
    Description de cet exemple

.NOTES
    Auteur: Votre Nom
    Date: 2025-01-15
    Version: 1.0
#>

# ============================================================================
# DÉCLARATION DES PARAMÈTRES
# ============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$NomParametre,
    
    [Parameter(Mandatory=$false)]
    [int]$OptionNumérique = 10
)

# ============================================================================
# VARIABLES GLOBALES ET CONFIGURATION
# ============================================================================

$ErrorActionPreference = "Stop"  # Arrêter en cas d'erreur
$VerbosePreference = "Continue"   # Afficher les messages verbeux

# Constantes
$CHEMIN_LOG = "C:\Logs\script.log"
$VERSION = "1.0.0"

# ============================================================================
# FONCTIONS
# ============================================================================

function Write-Log {
    <#
    .SYNOPSIS
        Écrit un message dans le fichier de log
    #>
    param([string]$Message)
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $CHEMIN_LOG -Append
}

# ============================================================================
# SCRIPT PRINCIPAL
# ============================================================================

try {
    Write-Log "Début du script"
    Write-Verbose "Traitement en cours..."
    
    # Votre code principal ici
    Write-Host "Paramètre reçu: $NomParametre"
    
    Write-Log "Script terminé avec succès"
    exit 0  # Code de sortie succès
}
catch {
    Write-Log "ERREUR: $_"
    Write-Error "Une erreur est survenue: $_"
    exit 1  # Code de sortie erreur
}
finally {
    # Code de nettoyage exécuté dans tous les cas
    Write-Verbose "Nettoyage terminé"
}
```

### Sections essentielles

> [!example] En-tête de documentation Le bloc `<#...#>` au début utilise la syntaxe "Comment-Based Help". Il permet d'obtenir de l'aide avec `Get-Help .\MonScript.ps1`.

**1. Documentation (Comment-Based Help)**

- Obligatoire pour les scripts professionnels
- Accessible via `Get-Help`
- Suit une syntaxe structurée avec des mots-clés (.SYNOPSIS, .DESCRIPTION, etc.)

**2. Paramètres**

- Définis avec le bloc `param()`
- Peuvent être obligatoires ou optionnels
- Supportent la validation et les valeurs par défaut

**3. Configuration**

- Variables de préférence (`$ErrorActionPreference`, etc.)
- Constantes globales (en MAJUSCULES par convention)
- Chemins et paramètres de configuration

**4. Fonctions**

- Regroupent la logique réutilisable
- Documentées avec leur propre help
- Placées avant le code principal

**5. Script principal**

- Logique d'exécution dans un bloc `try-catch-finally`
- Gestion des erreurs centralisée
- Codes de sortie explicites (`exit`)

> [!warning] Erreurs fréquentes
> 
> - Oublier `param()` au tout début du script (doit être la première instruction exécutable)
> - Ne pas gérer les erreurs avec `try-catch`
> - Variables non initialisées
> - Absence de documentation

---

## 🔧 Shebang et interpréteur

Le shebang (ou hashbang) est une ligne spéciale en début de fichier qui indique quel interpréteur doit exécuter le script. Bien que PowerShell n'utilise pas traditionnellement de shebang sur Windows, c'est essentiel pour la compatibilité cross-platform.

### Sur Linux et macOS

```powershell
#!/usr/bin/env pwsh

# Reste du script...
Write-Host "Script cross-platform"
```

> [!info] Pourquoi `/usr/bin/env pwsh` ?
> 
> - `#!/usr/bin/pwsh` → Chemin fixe (peut ne pas exister partout)
> - `#!/usr/bin/env pwsh` → Cherche `pwsh` dans le PATH (plus portable)

### Rendre un script exécutable (Linux/macOS)

```bash
# Donner les droits d'exécution
chmod +x MonScript.ps1

# Exécuter directement
./MonScript.ps1
```

### Sur Windows

Windows n'utilise pas de shebang mais se base sur l'association de fichiers :

```powershell
# Exécution explicite avec l'interpréteur
powershell.exe -File "MonScript.ps1"

# Avec PowerShell Core
pwsh -File "MonScript.ps1"

# Exécution directe (si Execution Policy le permet)
.\MonScript.ps1
```

### Vérifier l'interpréteur actuel

```powershell
# Version de PowerShell
$PSVersionTable

# Édition (Core ou Desktop)
$PSVersionTable.PSEdition

# Système d'exploitation
$PSVersionTable.OS

# Script pour détecter l'environnement
if ($PSVersionTable.PSEdition -eq "Core") {
    Write-Host "PowerShell Core détecté"
} else {
    Write-Host "Windows PowerShell détecté"
}

if ($IsLinux) {
    Write-Host "Exécution sur Linux"
} elseif ($IsMacOS) {
    Write-Host "Exécution sur macOS"
} elseif ($IsWindows) {
    Write-Host "Exécution sur Windows"
}
```

> [!tip] Script cross-platform complet
> 
> ```powershell
> #!/usr/bin/env pwsh
> 
> # Adaptation selon la plateforme
> if ($IsWindows) {
>     $separator = "\"
>     $tempPath = $env:TEMP
> } else {
>     $separator = "/"
>     $tempPath = "/tmp"
> }
> 
> Write-Host "Répertoire temporaire: $tempPath"
> ```

### Politique d'exécution (Windows uniquement)

```powershell
# Voir la politique actuelle
Get-ExecutionPolicy

# Politiques disponibles :
# - Restricted    : Aucun script (défaut)
# - AllSigned     : Scripts signés uniquement
# - RemoteSigned  : Scripts locaux + distants signés
# - Unrestricted  : Tous scripts (avec avertissement)
# - Bypass        : Aucune restriction

# Modifier pour l'utilisateur actuel
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Exécuter un script en bypassant temporairement
powershell.exe -ExecutionPolicy Bypass -File "MonScript.ps1"
```

> [!warning] Sécurité N'utilisez pas `Set-ExecutionPolicy Unrestricted` en production. Préférez `RemoteSigned` qui offre un bon équilibre sécurité/praticité.

---

## 📁 Organisation du code

Un code bien organisé est plus facile à maintenir, déboguer et réutiliser. Voici les principes d'organisation recommandés.

### Principe de responsabilité unique

Chaque fonction doit avoir une seule responsabilité claire :

```powershell
# ❌ Mauvais : fonction qui fait trop de choses
function Process-Data {
    $data = Import-Csv "data.csv"
    $data = $data | Where-Object {$_.Status -eq "Active"}
    $data | Export-Csv "result.csv"
    Send-MailMessage -To "admin@exemple.com" -Subject "Traitement terminé"
}

# ✅ Bon : fonctions spécialisées
function Import-DataFromCsv {
    param([string]$Path)
    return Import-Csv $Path
}

function Filter-ActiveData {
    param($Data)
    return $Data | Where-Object {$_.Status -eq "Active"}
}

function Export-DataToCsv {
    param($Data, [string]$Path)
    $Data | Export-Csv $Path
}

function Send-NotificationEmail {
    param([string]$Subject)
    Send-MailMessage -To "admin@exemple.com" -Subject $Subject
}
```

### Ordre logique des éléments

```powershell
# 1. DOCUMENTATION ET MÉTADONNÉES
<#.SYNOPSIS ... #>

# 2. PARAMÈTRES
param(...)

# 3. CONFIGURATION ET CONSTANTES
$ErrorActionPreference = "Stop"
$CONFIG_PATH = "config.json"

# 4. CLASSES (si nécessaire - concept avancé)
# ...

# 5. FONCTIONS UTILITAIRES (ordre alphabétique ou logique)
function Test-Prerequisites { }
function Write-Log { }

# 6. FONCTIONS MÉTIER (ordre d'appel recommandé)
function Initialize-Environment { }
function Process-MainTask { }
function Cleanup-Resources { }

# 7. SCRIPT PRINCIPAL
try {
    Initialize-Environment
    Process-MainTask
}
finally {
    Cleanup-Resources
}
```

### Nommage cohérent

> [!info] Convention Verb-Noun PowerShell utilise la convention **Verbe-Nom** pour les fonctions et cmdlets. Utilisez toujours des verbes approuvés (Get, Set, New, Remove, etc.).

```powershell
# Vérifier les verbes approuvés
Get-Verb

# ✅ Bonnes pratiques de nommage
function Get-UserData { }          # Récupérer des données
function Set-Configuration { }     # Définir une configuration
function New-Report { }            # Créer quelque chose
function Remove-TempFiles { }      # Supprimer
function Test-Connection { }       # Tester/vérifier
function Start-ProcessMonitor { }  # Démarrer un processus
function Stop-Service { }          # Arrêter

# ❌ À éviter
function GetData { }               # Pas de tiret
function Retrieve-Data { }         # Verbe non standard
function data_processor { }        # Style Python/C
```

### Conventions de nommage des variables

```powershell
# Constantes : MAJUSCULES avec underscores
$MAX_RETRY_COUNT = 3
$DEFAULT_TIMEOUT = 30

# Variables normales : PascalCase
$UserName = "admin"
$ConnectionString = "Server=..."

# Variables privées/internes : commencent par underscore
$_tempData = @()
$_internalCounter = 0

# Booléens : préfixe Is, Has, Can
$IsValid = $true
$HasPermission = $false
$CanConnect = Test-Connection "server"

# Collections : noms au pluriel
$Users = @()
$Files = Get-ChildItem
```

### Groupement logique avec régions

```powershell
#region Configuration
$CONFIG_FILE = "settings.json"
$LOG_PATH = "C:\Logs"
$MAX_THREADS = 4
#endregion

#region Fonctions utilitaires
function Write-Log {
    param([string]$Message)
    # ...
}

function Test-FileExists {
    param([string]$Path)
    # ...
}
#endregion

#region Traitement principal
try {
    # Code principal
}
catch {
    # Gestion d'erreur
}
#endregion
```

> [!tip] Les régions dans VS Code Dans VS Code, les régions `#region` / `#endregion` sont repliables, ce qui permet de masquer des sections de code et d'améliorer la lisibilité.

### Commentaires et documentation

```powershell
# ✅ Bon commentaire : explique le POURQUOI
# On utilise Start-Sleep car l'API a un rate limit de 10 req/min
Start-Sleep -Seconds 6

# ❌ Mauvais commentaire : explique le QUOI (déjà évident)
# Cette ligne affiche "Bonjour"
Write-Host "Bonjour"

# Documentation de fonction complète
function Get-SystemReport {
    <#
    .SYNOPSIS
        Génère un rapport système complet
    
    .DESCRIPTION
        Cette fonction collecte diverses informations système (CPU, RAM, disque)
        et les exporte dans un fichier HTML formaté.
    
    .PARAMETER OutputPath
        Chemin du fichier HTML de sortie
    
    .PARAMETER IncludeDiskInfo
        Inclure les informations sur les disques
    
    .EXAMPLE
        Get-SystemReport -OutputPath "C:\Reports\system.html"
        Génère un rapport basique
    
    .EXAMPLE
        Get-SystemReport -OutputPath "report.html" -IncludeDiskInfo
        Génère un rapport avec informations disques
    
    .NOTES
        Nécessite des droits administrateur pour certaines informations
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$OutputPath,
        
        [switch]$IncludeDiskInfo
    )
    
    # Implémentation...
}
```

### Gestion des dépendances

```powershell
#Requires -Version 5.1
#Requires -Modules ActiveDirectory, ImportExcel
#Requires -RunAsAdministrator

# Vérification manuelle des prérequis
function Test-Prerequisites {
    $missing = @()
    
    # Vérifier PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        $missing += "PowerShell 5.1 ou supérieur requis"
    }
    
    # Vérifier modules
    $requiredModules = @("ActiveDirectory", "ImportExcel")
    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            $missing += "Module manquant: $module"
        }
    }
    
    if ($missing.Count -gt 0) {
        throw "Prérequis manquants:`n" + ($missing -join "`n")
    }
}
```

### Structure de projet pour scripts complexes

```
MonProjet/
├── MonScript.ps1              # Script principal
├── config/
│   ├── settings.json          # Configuration
│   └── credentials.xml        # Identifiants chiffrés
├── modules/
│   ├── Database.psm1          # Module base de données
│   └── Logging.psm1           # Module logging
├── lib/
│   └── ExternalLib.dll        # Bibliothèques externes
├── tests/
│   ├── Unit.Tests.ps1         # Tests unitaires
│   └── Integration.Tests.ps1  # Tests d'intégration
├── logs/
│   └── .gitkeep              # Dossier pour les logs
└── README.md                  # Documentation
```

> [!example] Charger des modules personnalisés
> 
> ```powershell
> # Dans MonScript.ps1
> $ModulePath = Join-Path $PSScriptRoot "modules"
> Import-Module (Join-Path $ModulePath "Database.psm1")
> Import-Module (Join-Path $ModulePath "Logging.psm1")
> ```

### Codes de sortie standardisés

```powershell
# Constantes de codes de sortie
$EXIT_SUCCESS = 0
$EXIT_ERROR_GENERAL = 1
$EXIT_ERROR_ARGS = 2
$EXIT_ERROR_PERMISSIONS = 3
$EXIT_ERROR_NOT_FOUND = 4

try {
    # Traitement...
    exit $EXIT_SUCCESS
}
catch {
    switch ($_.Exception.GetType().Name) {
        "UnauthorizedAccessException" {
            Write-Error "Permissions insuffisantes"
            exit $EXIT_ERROR_PERMISSIONS
        }
        "FileNotFoundException" {
            Write-Error "Fichier introuvable"
            exit $EXIT_ERROR_NOT_FOUND
        }
        default {
            Write-Error "Erreur: $_"
            exit $EXIT_ERROR_GENERAL
        }
    }
}
```

> [!tip] Astuces d'organisation
> 
> - **Un fichier = une responsabilité** : Ne mélangez pas différentes fonctionnalités dans un même fichier
> - **Fonctions courtes** : Idéalement moins de 50 lignes par fonction
> - **DRY (Don't Repeat Yourself)** : Factorisez le code dupliqué en fonctions
> - **Configuration externalisée** : Utilisez des fichiers JSON/XML pour la configuration
> - **Logs structurés** : Utilisez toujours le même format de log dans tout le script
> - **Variables $PSScriptRoot et $MyInvocation** : Pour des chemins relatifs au script

---

## 🎯 Résumé

Les fichiers `.ps1` sont le fondement de l'automatisation PowerShell. Une bonne maîtrise de leur structure, encodage, et organisation permet de créer des scripts robustes, maintenables et professionnels. Les points clés à retenir :

- ✅ Utiliser UTF-8 avec BOM pour la compatibilité maximale
- ✅ Inclure un shebang pour les scripts cross-platform
- ✅ Documenter avec Comment-Based Help
- ✅ Structurer le code de manière logique et cohérente
- ✅ Suivre les conventions de nommage PowerShell
- ✅ Gérer les erreurs avec try-catch-finally
- ✅ Utiliser des codes de sortie explicites