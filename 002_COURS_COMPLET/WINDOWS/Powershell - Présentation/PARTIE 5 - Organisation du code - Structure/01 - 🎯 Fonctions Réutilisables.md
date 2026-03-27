

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

## 🎨 Créer des fonctions d'affichage

### Pourquoi créer des fonctions d'affichage ?

Les fonctions d'affichage permettent de **standardiser** la présentation des messages dans vos scripts. Au lieu de répéter du code de mise en forme partout, vous centralisez la logique d'affichage en un seul endroit.

**Avantages** :

- **Cohérence visuelle** : tous les messages suivent le même format
- **Maintenance facilitée** : modifier l'affichage à un seul endroit
- **Réutilisabilité** : utilisable dans tous vos scripts
- **Lisibilité du code** : le script principal reste concentré sur la logique métier

---

### Anatomie d'une fonction d'affichage basique

```powershell
function Write-InfoMessage {
    param (
        [string]$Message
    )
    
    Write-Host "ℹ️  INFO: $Message" -ForegroundColor Cyan
}

# Utilisation
Write-InfoMessage "Traitement en cours..."
```

> [!info] Structure de base Une fonction d'affichage simple contient :
> 
> - Un nom descriptif (`Write-InfoMessage`)
> - Un ou plusieurs paramètres (le message à afficher)
> - Une logique de formatage (couleurs, emojis, préfixes)

---

### Fonction d'affichage avancée avec plusieurs niveaux

```powershell
function Write-StatusMessage {
    <#
    .SYNOPSIS
    Affiche un message formaté selon son niveau de sévérité
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    # Définition des styles par niveau
    switch ($Level) {
        'Info' {
            $icon = "ℹ️"
            $color = 'Cyan'
            $prefix = "INFO"
        }
        'Success' {
            $icon = "✅"
            $color = 'Green'
            $prefix = "SUCCESS"
        }
        'Warning' {
            $icon = "⚠️"
            $color = 'Yellow'
            $prefix = "WARNING"
        }
        'Error' {
            $icon = "❌"
            $color = 'Red'
            $prefix = "ERROR"
        }
    }
    
    # Construction et affichage du message
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $icon $prefix : $Message" -ForegroundColor $color
}

# Exemples d'utilisation
Write-StatusMessage "Démarrage du script" -Level Info
Write-StatusMessage "Fichier traité avec succès" -Level Success
Write-StatusMessage "Mémoire faible détectée" -Level Warning
Write-StatusMessage "Impossible d'accéder au fichier" -Level Error
```

> [!example] Résultat visuel
> 
> ```
> [14:32:15] ℹ️  INFO : Démarrage du script
> [14:32:16] ✅ SUCCESS : Fichier traité avec succès
> [14:32:17] ⚠️  WARNING : Mémoire faible détectée
> [14:32:18] ❌ ERROR : Impossible d'accéder au fichier
> ```

---

### Fonction d'affichage avec barre de progression

```powershell
function Write-ProgressBar {
    param (
        [int]$Current,
        [int]$Total,
        [string]$Activity = "Traitement en cours"
    )
    
    $percent = [math]::Round(($Current / $Total) * 100)
    
    Write-Progress -Activity $Activity `
                   -Status "$Current/$Total éléments traités" `
                   -PercentComplete $percent
}

# Utilisation dans une boucle
$files = Get-ChildItem -Path "C:\Data"
for ($i = 0; $i -lt $files.Count; $i++) {
    Write-ProgressBar -Current ($i + 1) -Total $files.Count -Activity "Traitement des fichiers"
    # Traitement du fichier...
    Start-Sleep -Milliseconds 200
}
```

---

### Fonction d'affichage de bannière

```powershell
function Show-Banner {
    param (
        [string]$Title,
        [string]$Version = "1.0",
        [string]$Author = $env:USERNAME
    )
    
    $width = 60
    $border = "=" * $width
    
    Write-Host ""
    Write-Host $border -ForegroundColor Magenta
    Write-Host (" " * (($width - $Title.Length) / 2) + $Title) -ForegroundColor Cyan
    Write-Host $border -ForegroundColor Magenta
    Write-Host " Version : $Version" -ForegroundColor Gray
    Write-Host " Auteur  : $Author" -ForegroundColor Gray
    Write-Host " Date    : $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor Gray
    Write-Host $border -ForegroundColor Magenta
    Write-Host ""
}

# Utilisation
Show-Banner -Title "SCRIPT DE SAUVEGARDE" -Version "2.3" -Author "Admin"
```

> [!tip] Astuce visuelle Utilisez des caractères spéciaux pour créer des séparateurs visuels :
> 
> - `=` pour des lignes épaisses
> - `-` pour des lignes fines
> - `#` pour des blocs de titre
> - Combinez avec des couleurs pour un impact maximal

---

## 🏷️ Comment bien nommer ses fonctions

### Convention de nommage PowerShell : Verbe-Nom

PowerShell utilise une convention stricte : **Verbe-Nom** (PascalCase)

```powershell
# ✅ CORRECT
Get-UserData
Set-Configuration
Test-Connection
Write-LogEntry
New-BackupFile

# ❌ INCORRECT
GetUserData          # Pas de tiret
get-userdata         # Pas en PascalCase
getUserData          # CamelCase non conforme
Retrieve-User-Data   # Trop de tirets
```

> [!warning] Convention obligatoire Le format `Verbe-Nom` n'est pas qu'une recommandation. PowerShell contient une liste de verbes approuvés. Utilisez `Get-Verb` pour voir la liste complète.

---

### Les verbes PowerShell approuvés

PowerShell catégorise les verbes par type d'action :

|Catégorie|Verbes courants|Usage|
|---|---|---|
|**Commune**|Get, Set, New, Remove|Manipulation d'objets|
|**Communication**|Connect, Disconnect, Send, Receive|Connexions réseau/API|
|**Données**|Backup, Restore, Export, Import|Gestion de données|
|**Diagnostic**|Test, Trace, Measure, Debug|Tests et mesures|
|**Lifecycle**|Start, Stop, Restart, Suspend|Gestion de processus|
|**Sécurité**|Grant, Revoke, Protect, Unprotect|Permissions et sécurité|

```powershell
# Voir tous les verbes approuvés
Get-Verb | Format-Table -AutoSize

# Rechercher des verbes spécifiques
Get-Verb -Verb Write*
Get-Verb -Group Data
```

---

### Choisir le bon verbe pour votre fonction

```powershell
# 📥 Récupération de données
Get-ConfigurationFile      # Récupère et retourne
Read-LogFile              # Lit du contenu

# 💾 Modification de données
Set-UserPermission        # Modifie une valeur existante
Update-DatabaseRecord     # Met à jour avec nouvelle version
Add-ItemToCollection      # Ajoute à une collection

# ✨ Création
New-BackupDirectory       # Crée un nouvel objet
Register-EventHandler     # Enregistre/crée une relation

# 🗑️ Suppression
Remove-TemporaryFile      # Supprime un objet
Clear-CacheDirectory      # Vide un contenant (mais le garde)
Unregister-Service        # Annule un enregistrement

# 🔍 Vérification
Test-PathExists           # Vérifie et retourne bool
Confirm-UserInput         # Demande confirmation

# 📝 Affichage (non-standard mais courant)
Write-StatusMessage       # Affiche à l'écran
Show-ProgressBar          # Présente visuellement
```

> [!info] Verbe "Write" vs "Output"
> 
> - `Write-*` : affiche à l'écran (Write-Host, Write-Output)
> - `Out-*` : redirige vers une destination (Out-File, Out-Null)

---

### Nommer le substantif (Nom)

Le nom doit être **spécifique** et **descriptif** :

```powershell
# ✅ BON : spécifique et clair
Get-SqlConnectionString
Test-WebServiceAvailability
ConvertTo-JsonConfiguration
Export-CsvReport

# ⚠️ MOINS BON : trop vague
Get-Data                  # Quelles données ?
Process-Items             # Quels items ? Quel traitement ?
Do-Stuff                  # Trop générique
```

**Règles pour le nom** :

- Utilisez le **singulier** (sauf pour les collections évidentes)
- Soyez **descriptif** sans être verbeux
- Évitez les **abréviations** sauf si elles sont universelles (SQL, CSV, JSON)

```powershell
# Singulier vs Pluriel
Get-User                  # ✅ Récupère UN utilisateur
Get-UserList              # ✅ Récupère UNE LISTE d'utilisateurs

# Clarté vs Verbosité
Get-Cfg                   # ❌ Trop abrégé
Get-Configuration         # ✅ Clair
Get-ConfigurationFileFromServerWithValidation  # ❌ Trop verbeux
```

---

### Fonctions privées vs publiques

Préfixez les fonctions internes avec un trait de soulignement ou un nom de module :

```powershell
# ✅ Fonction publique (exportée)
function Get-SystemReport {
    # Accessible aux utilisateurs du module
}

# ✅ Fonction privée (helper interne)
function _FormatReportData {
    # Utilisée uniquement en interne
}

# ✅ Alternative : préfixe de module
function MyModule_ValidateInput {
    # Indique clairement l'appartenance
}
```

> [!tip] Organisation recommandée Placez toutes les fonctions privées au début du script, suivies des fonctions publiques. Cela rend la structure immédiatement claire.

---

### Anti-patterns à éviter

```powershell
# ❌ Verbe non standard
function Grab-Data { }           # Utilisez Get
function Fetch-Results { }       # Utilisez Get
function Retrieve-Information { } # Utilisez Get

# ❌ Pas de verbe
function UserData { }            # Manque Get-
function ConfigFile { }          # Manque Get- ou Set-

# ❌ Noms de variables comme noms de fonctions
function $MyFunction { }         # Syntaxe invalide

# ❌ Caractères spéciaux
function Get-User@Data { }       # Caractères interdits
function Get/User/Data { }       # Slashes interdits
```

---

## 📚 Documentation avec comment-based help

### Qu'est-ce que le comment-based help ?

Le **comment-based help** est un système de documentation intégré à PowerShell. Il transforme des commentaires structurés en aide accessible via `Get-Help`.

**Avantages** :

- **Documentation au plus près du code**
- **Aide interactive** pour les utilisateurs
- **Standard PowerShell** reconnu partout
- **IntelliSense** enrichi dans les IDE

---

### Structure minimale d'une aide

```powershell
function Get-ServiceStatus {
    <#
    .SYNOPSIS
    Récupère l'état d'un service Windows
    
    .DESCRIPTION
    Cette fonction interroge le système pour obtenir l'état actuel
    d'un service Windows spécifié par son nom.
    
    .PARAMETER ServiceName
    Le nom du service Windows à interroger
    
    .EXAMPLE
    Get-ServiceStatus -ServiceName "wuauserv"
    #>
    
    param (
        [string]$ServiceName
    )
    
    Get-Service -Name $ServiceName
}
```

> [!info] Balises essentielles
> 
> - `.SYNOPSIS` : résumé court (une ligne)
> - `.DESCRIPTION` : description détaillée
> - `.PARAMETER` : documentation de chaque paramètre
> - `.EXAMPLE` : exemples d'utilisation

---

### Aide complète avec toutes les balises

```powershell
function Backup-UserData {
    <#
    .SYNOPSIS
    Crée une sauvegarde des données utilisateur
    
    .DESCRIPTION
    Cette fonction effectue une sauvegarde complète des données d'un utilisateur
    vers un emplacement spécifié. Elle supporte plusieurs formats de compression
    et peut inclure ou exclure des types de fichiers spécifiques.
    
    La fonction crée automatiquement un horodatage dans le nom du fichier de
    sauvegarde et vérifie l'intégrité après la création.
    
    .PARAMETER UserName
    Le nom de l'utilisateur dont les données doivent être sauvegardées.
    Ce paramètre est obligatoire.
    
    .PARAMETER DestinationPath
    Le chemin où la sauvegarde sera stockée.
    Par défaut : C:\Backups
    
    .PARAMETER CompressionLevel
    Le niveau de compression à appliquer (None, Fast, Optimal).
    Par défaut : Optimal
    
    .PARAMETER IncludeDocuments
    Inclut le dossier Documents dans la sauvegarde.
    Activé par défaut.
    
    .EXAMPLE
    Backup-UserData -UserName "jdupont"
    
    Sauvegarde toutes les données de l'utilisateur jdupont vers C:\Backups
    avec compression optimale.
    
    .EXAMPLE
    Backup-UserData -UserName "jdupont" -DestinationPath "D:\Archives" -CompressionLevel Fast
    
    Sauvegarde rapide des données vers un emplacement personnalisé.
    
    .EXAMPLE
    Backup-UserData -UserName "jdupont" -IncludeDocuments:$false
    
    Sauvegarde sans inclure le dossier Documents.
    
    .INPUTS
    String
    Vous pouvez passer un nom d'utilisateur via le pipeline.
    
    .OUTPUTS
    System.IO.FileInfo
    Retourne l'objet FileInfo du fichier de sauvegarde créé.
    
    .NOTES
    Auteur      : Jean Martin
    Version     : 2.1
    Dernière MAJ: 2025-01-15
    Nécessite   : PowerShell 5.1 ou supérieur
    
    .LINK
    https://docs.example.com/backup-userdata
    
    .LINK
    Restore-UserData
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$UserName,
        
        [Parameter(Mandatory = $false)]
        [string]$DestinationPath = "C:\Backups",
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('None', 'Fast', 'Optimal')]
        [string]$CompressionLevel = 'Optimal',
        
        [Parameter(Mandatory = $false)]
        [switch]$IncludeDocuments = $true
    )
    
    # Code de la fonction...
}
```

---

### Balises principales du comment-based help

|Balise|Utilité|Obligatoire|
|---|---|---|
|`.SYNOPSIS`|Résumé court (une ligne)|✅ Oui|
|`.DESCRIPTION`|Description détaillée|✅ Oui|
|`.PARAMETER`|Documentation d'un paramètre|✅ Pour chaque param|
|`.EXAMPLE`|Exemple d'utilisation|⭐ Fortement recommandé|
|`.INPUTS`|Type d'objets acceptés en pipeline|⚪ Optionnel|
|`.OUTPUTS`|Type d'objets retournés|⚪ Optionnel|
|`.NOTES`|Informations supplémentaires|⚪ Optionnel|
|`.LINK`|Liens vers ressources externes|⚪ Optionnel|

---

### Placement du bloc d'aide

Le bloc d'aide peut être placé à **trois endroits** :

```powershell
# 1️⃣ AVANT la déclaration de fonction (recommandé)
<#
.SYNOPSIS
Description de la fonction
#>
function Get-Data {
    param($Path)
}

# 2️⃣ AU DÉBUT du corps de fonction
function Get-Data {
    <#
    .SYNOPSIS
    Description de la fonction
    #>
    param($Path)
}

# 3️⃣ APRÈS le corps de fonction (moins courant)
function Get-Data {
    param($Path)
    # Code...
}
<#
.SYNOPSIS
Description de la fonction
#>
```

> [!tip] Placement recommandé Placez l'aide **avant** la fonction. C'est plus visible et respecte la convention standard.

---

### Documenter les paramètres avec précision

```powershell
function Copy-SecureFile {
    <#
    .PARAMETER SourcePath
    Chemin complet du fichier source à copier.
    Accepte les chemins UNC et les chemins locaux.
    Exemple : C:\Data\file.txt ou \\server\share\file.txt
    
    .PARAMETER DestinationPath
    Chemin complet de la destination.
    Si le dossier n'existe pas, il sera créé automatiquement.
    
    .PARAMETER Overwrite
    Force l'écrasement du fichier de destination s'il existe déjà.
    Par défaut, la fonction échoue si le fichier existe.
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ })]
        [string]$SourcePath,
        
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath,
        
        [Parameter(Mandatory = $false)]
        [switch]$Overwrite
    )
}
```

**Éléments à inclure dans la documentation d'un paramètre** :

- **Description** : à quoi sert ce paramètre ?
- **Format attendu** : type, format, exemples
- **Valeurs par défaut** : si applicable
- **Contraintes** : valeurs acceptées, validations
- **Comportement** : impact sur la fonction

---

### Exemples multiples et progressifs

Les exemples doivent être **progressifs** : du simple au complexe.

```powershell
<#
.EXAMPLE
Get-UserReport -UserName "jdupont"

Génère un rapport basique pour l'utilisateur jdupont.

.EXAMPLE
Get-UserReport -UserName "jdupont" -Detailed

Génère un rapport détaillé incluant toutes les propriétés.

.EXAMPLE
Get-UserReport -UserName "jdupont" -Detailed -ExportPath "C:\Reports\user.html"

Génère un rapport détaillé et l'exporte au format HTML.

.EXAMPLE
"jdupont", "amartin", "pdubois" | Get-UserReport -ExportPath "C:\Reports"

Génère des rapports pour plusieurs utilisateurs via le pipeline.

.EXAMPLE
Get-ADUser -Filter {Department -eq "IT"} | Get-UserReport -Detailed

Combine avec d'autres cmdlets pour traiter un groupe d'utilisateurs.
#>
```

> [!example] Structure d'un bon exemple
> 
> 1. **Commande** : syntaxe exacte à utiliser
> 2. **Ligne vide** : séparation visuelle
> 3. **Explication** : ce que fait la commande et résultat attendu

---

### Consulter l'aide de votre fonction

Une fois documentée, votre fonction devient accessible via `Get-Help` :

```powershell
# Aide de base
Get-Help Backup-UserData

# Aide détaillée
Get-Help Backup-UserData -Detailed

# Exemples uniquement
Get-Help Backup-UserData -Examples

# Aide complète
Get-Help Backup-UserData -Full

# Paramètres uniquement
Get-Help Backup-UserData -Parameter *
```

---

### Notes et métadonnées

La section `.NOTES` est utile pour les **métadonnées** :

```powershell
<#
.NOTES
===================================================================
INFORMATIONS GÉNÉRALES
===================================================================
Nom du fichier  : Backup-System.ps1
Auteur          : Jean Martin (jean.martin@entreprise.fr)
Créé le         : 2024-03-15
Modifié le      : 2025-01-20
Version         : 3.2.1

===================================================================
PRÉREQUIS
===================================================================
- PowerShell 5.1 ou supérieur
- Droits administrateur requis
- Module ActiveDirectory (optionnel)
- Espace disque minimum : 10 GB

===================================================================
COMPATIBILITÉ
===================================================================
Testé sur       : Windows Server 2019, 2022
                  Windows 10, 11 (Pro/Enterprise)
Non compatible  : PowerShell Core (limitation du module utilisé)

===================================================================
CHANGELOG
===================================================================
3.2.1 (2025-01-20)
  - Correction : gestion des chemins avec espaces
  - Ajout : validation de l'espace disque avant sauvegarde

3.2.0 (2024-12-10)
  - Nouvelle fonctionnalité : support du chiffrement AES-256
  - Amélioration : performances de compression (+40%)

3.1.0 (2024-09-05)
  - Ajout : support des sauvegardes incrémentales
===================================================================
#>
```

> [!warning] Limite des .NOTES Les `.NOTES` ne sont pas structurées par PowerShell. Organisez-les clairement pour qu'elles restent lisibles.

---

### Liens vers la documentation externe

```powershell
<#
.LINK
https://docs.microsoft.com/powershell/module/microsoft.powershell.management/get-service

.LINK
https://intranet.entreprise.fr/docs/backup-procedures

.LINK
Get-Service

.LINK
Restore-UserData
#>
```

**Types de liens à inclure** :

- Documentation officielle Microsoft
- Documentation interne de l'entreprise
- Cmdlets ou fonctions liées
- Articles de blog ou tutoriels

---

## 🔄 Return vs Write-Output

### Comprendre la différence fondamentale

PowerShell a **deux mécanismes** pour retourner des données :

|Mécanisme|Usage|Flux de sortie|
|---|---|---|
|`return`|Sort immédiatement de la fonction|Success (1)|
|`Write-Output`|Envoie au pipeline|Success (1)|

> [!info] Point clé Les deux envoient au **même flux** (Success Stream), mais `return` termine l'exécution de la fonction immédiatement.

---

### Return : sortie immédiate

`return` fait **deux choses** :

1. Envoie la valeur au pipeline
2. **Termine** l'exécution de la fonction

```powershell
function Get-FirstEvenNumber {
    param ([int[]]$Numbers)
    
    foreach ($num in $Numbers) {
        if ($num % 2 -eq 0) {
            return $num  # ⚠️ Sort immédiatement ici
        }
    }
    
    return $null  # Seulement si aucun nombre pair trouvé
}

# Utilisation
$result = Get-FirstEvenNumber -Numbers @(1, 3, 5, 8, 10, 12)
# $result = 8 (la fonction s'arrête au premier pair)
```

> [!warning] Piège courant `return` ne retourne **qu'une seule valeur** dans ce contexte. Si vous avez besoin de retourner plusieurs valeurs, utilisez une collection ou `Write-Output`.

---

### Write-Output : envoi au pipeline

`Write-Output` envoie des valeurs au pipeline **sans arrêter** la fonction :

```powershell
function Get-AllEvenNumbers {
    param ([int[]]$Numbers)
    
    foreach ($num in $Numbers) {
        if ($num % 2 -eq 0) {
            Write-Output $num  # ✅ Continue la boucle
        }
    }
}

# Utilisation
$results = Get-AllEvenNumbers -Numbers @(1, 2, 3, 4, 5, 6)
# $results = @(2, 4, 6)
```

---

### Sortie implicite : le comportement par défaut

En PowerShell, **toute valeur non capturée** est automatiquement envoyée au pipeline :

```powershell
function Get-ServerInfo {
    param ([string]$ServerName)
    
    # Ces trois lignes font LA MÊME CHOSE
    $ServerName                    # Sortie implicite ✅
    Write-Output $ServerName       # Sortie explicite ✅
    return $ServerName             # Sortie + terminaison ✅
}
```

> [!tip] Recommandation **Sortie implicite** : pour des fonctions simples et claires **Write-Output** : quand vous voulez être explicite sur l'envoi au pipeline **Return** : quand vous devez sortir prématurément de la fonction

---

### Retourner plusieurs valeurs

Il existe **plusieurs techniques** pour retourner plusieurs valeurs :

#### Technique 1 : Array ou ArrayList

```powershell
function Get-SystemData {
    $os = (Get-CimInstance Win32_OperatingSystem).Caption
    $cpu = (Get-CimInstance Win32_Processor).Name
    $ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    
    # Retourner un tableau
    return @($os, $cpu, $ram)
    
    # OU sortie implicite d'un array
    # @($os, $cpu, $ram)
}

# Déstructuration
$osInfo, $cpuInfo, $ramInfo = Get-SystemData
```

#### Technique 2 : Hashtable (recommandé)

```powershell
function Get-SystemData {
    $data = @{
        OperatingSystem = (Get-CimInstance Win32_OperatingSystem).Caption
        Processor = (Get-CimInstance Win32_Processor).Name
        MemoryGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
        Timestamp = Get-Date
    }
    
    return $data
}

# Utilisation
$info = Get-SystemData
Write-Host "OS: $($info.OperatingSystem)"
Write-Host "RAM: $($info.MemoryGB) GB"
```

> [!tip] Hashtable vs Array **Hashtable** : données nommées, plus lisible, accès par clé **Array** : ordre fixe, déstructuration simple, plus compact

#### Technique 3 : PSCustomObject (professionnel)

```powershell
function Get-SystemData {
    [PSCustomObject]@{
        OperatingSystem = (Get-CimInstance Win32_OperatingSystem).Caption
        Processor = (Get-CimInstance Win32_Processor).Name
        MemoryGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
        Timestamp = Get-Date
    }
}

# Utilisation (compatible avec le pipeline et Select-Object)
$info = Get-SystemData
$info | Select-Object OperatingSystem, MemoryGB
$info | Export-Csv -Path "system-info.csv"
```

> [!example] Avantage des PSCustomObject
> 
> - Compatible avec tous les cmdlets PowerShell
> - Fonctionne parfaitement avec `Format-Table`, `Export-Csv`, `ConvertTo-Json`
> - Propriétés typées et ordonnées
> - C'est la **méthode professionnelle** recommandée

---

### Return dans différents contextes

#### Context 1 : Validation avec return anticipé

```powershell
function Start-BackupProcess {
    param ([string]$Path)
    
    # Validation - sortie anticipée
    if (-not (Test-Path $Path)) {
        Write-Error "Le chemin n'existe pas : $Path"
        return  # ⚠️ Termine la fonction immédiatement
    }
    
    # Suite du traitement uniquement si la validation passe
    Write-Host "Démarrage de la sauvegarde..."
    # ... code de sauvegarde ...
}
```

#### Context 2 : Recherche avec return dès trouvé

```powershell
function Find-ConfigFile {
    param ([string[]]$SearchPaths)
    
    foreach ($path in $SearchPaths) {
        $configPath = Join-Path $path "config.json"
        if (Test-Path $configPath) {
            return $configPath  # ✅ Trouvé, on arrête la recherche
        }
    }
    
    return $null  # Pas trouvé
}
```

#### Context 3 : Fonction booléenne

```powershell
function Test-ServiceRunning {
    param ([string]$ServiceName)
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    
    if ($null -eq $service) {
        return $false
    }
    
    return ($service.Status -eq 'Running')
}

# Utilisation dans une condition
if (Test-ServiceRunning -ServiceName "wuauserv") {
    Write-Host "Le service Windows Update est actif"
}
```

---

### Write-Output vs sortie implicite : quand utiliser quoi ?

#### Sortie implicite (recommandé pour la simplicité)

```powershell
function Get-FileCount {
    param ([string]$Path)
    
    $count = (Get-ChildItem -Path $Path).Count
    $count  # ✅ Sortie implicite - simple et clair
}
```

#### Write-Output (explicite)

```powershell
function Get-ProcessedItems {
    param ([string[]]$Items)
    
    foreach ($item in $Items) {
        $processed = $item.ToUpper()
        Write-Output $processed  # ✅ Explicite : on envoie au pipeline
    }
}
```

> [!info] Quand utiliser Write-Output ?
> 
> - Dans les **boucles** où vous générez plusieurs valeurs
> - Quand vous voulez être **explicite** sur l'envoi au pipeline
> - Pour la **clarté** dans du code complexe
> - Quand vous mélangez avec `Write-Host`, `Write-Verbose`, etc.

---

### Les pièges à éviter

#### Piège 1 : Return avec Write-Host

```powershell
# ❌ MAUVAIS : Write-Host n'envoie RIEN au pipeline
function Get-Data {
    $data = "Important"
    Write-Host $data  # Va à l'écran, PAS au pipeline
    return $data      # Ceci est retourné
}

$result = Get-Data
# $result contient "Important"
# Mais "Important" est AUSSI affiché à l'écran (pollution)
```

```powershell
# ✅ BON : Séparer affichage et retour
function Get-Data {
    $data = "Important"
    Write-Verbose "Récupération de : $data"  # Optionnel avec -Verbose
    return $data
}

$result = Get-Data -Verbose
```

> [!warning] Write-Host est toxique pour les fonctions `Write-Host` affiche directement à l'écran et **n'envoie rien au pipeline**. Utilisez-le uniquement pour les messages utilisateur, jamais pour les données à retourner.

---

#### Piège 2 : Sortie involontaire

```powershell
# ❌ MAUVAIS : Sortie non intentionnelle
function Process-Data {
    param ([int]$Value)
    
    $doubled = $Value * 2  # OK
    $doubled               # ⚠️ Sortie implicite non voulue !
    
    $result = $doubled + 10
    return $result
}

$output = Process-Data -Value 5
# $output contient DEUX valeurs : 10 et 20 !
```

```powershell
# ✅ BON : Capture ou suppression des sorties intermédiaires
function Process-Data {
    param ([int]$Value)
    
    $doubled = $Value * 2
    # Ne pas laisser $doubled seul sur une ligne
    
    $result = $doubled + 10
    return $result
}

$output = Process-Data -Value 5
# $output = 20
```

---

#### Piège 3 : Return dans Try/Catch

```powershell
# ⚠️ ATTENTION : Return dans Try
function Get-FileContent {
    param ([string]$Path)
    
    try {
        $content = Get-Content -Path $Path -ErrorAction Stop
        return $content  # ⚠️ Sort ici, Finally ne s'exécute pas encore
    }
    catch {
        Write-Error "Erreur : $_"
        return $null
    }
    finally {
        Write-Verbose "Nettoyage effectué"  # ✅ S'exécute même après return
    }
}
```

> [!info] Comportement de Finally Le bloc `finally` s'exécute **toujours**, même après un `return` dans `try` ou `catch`. Mais le `return` a déjà défini la valeur de retour.

---

#### Piège 4 : Multiple returns vs collection

```powershell
# ❌ Peut être confus
function Get-Numbers {
    return 1
    return 2  # ⚠️ Jamais atteint !
    return 3
}

# ✅ Pour retourner plusieurs valeurs
function Get-Numbers {
    1  # Sortie implicite
    2  # Sortie implicite
    3  # Sortie implicite
}

$numbers = Get-Numbers
# $numbers = @(1, 2, 3)
```

---

### Patterns recommandés selon le cas d'usage

#### Pattern 1 : Fonction de validation (booléenne)

```powershell
function Test-PortOpen {
    param (
        [string]$ComputerName,
        [int]$Port
    )
    
    try {
        $connection = Test-NetConnection -ComputerName $ComputerName -Port $Port -InformationLevel Quiet
        return $connection
    }
    catch {
        return $false
    }
}

# Utilisation
if (Test-PortOpen -ComputerName "server01" -Port 443) {
    Write-Host "Port accessible"
}
```

---

#### Pattern 2 : Fonction de transformation (pipeline)

```powershell
function ConvertTo-TitleCase {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Text
    )
    
    process {
        # Write-Output dans Process pour traiter le pipeline
        Write-Output (Get-Culture).TextInfo.ToTitleCase($Text.ToLower())
    }
}

# Utilisation avec pipeline
"hello world", "powershell scripting" | ConvertTo-TitleCase
```

> [!tip] Begin, Process, End
> 
> - `begin {}` : exécuté une fois au début
> - `process {}` : exécuté pour chaque élément du pipeline
> - `end {}` : exécuté une fois à la fin

---

#### Pattern 3 : Fonction de récupération (objet)

```powershell
function Get-DiskInfo {
    param (
        [string]$DriveLetter = "C:"
    )
    
    $disk = Get-PSDrive -Name $DriveLetter.TrimEnd(':')
    
    # Retourner un PSCustomObject structuré
    [PSCustomObject]@{
        Drive = $DriveLetter
        UsedGB = [math]::Round($disk.Used / 1GB, 2)
        FreeGB = [math]::Round($disk.Free / 1GB, 2)
        TotalGB = [math]::Round(($disk.Used + $disk.Free) / 1GB, 2)
        PercentFree = [math]::Round(($disk.Free / ($disk.Used + $disk.Free)) * 100, 2)
    }
}

# Utilisation
$info = Get-DiskInfo
$info | Format-Table
$info | Export-Csv -Path "disk-info.csv"
```

---

#### Pattern 4 : Fonction de traitement par lot (collection)

```powershell
function Get-LargeFiles {
    param (
        [string]$Path,
        [int]$MinSizeMB = 100
    )
    
    $files = Get-ChildItem -Path $Path -Recurse -File |
             Where-Object { $_.Length -gt ($MinSizeMB * 1MB) }
    
    foreach ($file in $files) {
        # Générer plusieurs objets
        [PSCustomObject]@{
            Name = $file.Name
            Path = $file.FullName
            SizeMB = [math]::Round($file.Length / 1MB, 2)
            LastModified = $file.LastWriteTime
        }
    }
}

# Utilisation
$largeFiles = Get-LargeFiles -Path "C:\Data" -MinSizeMB 50
$largeFiles | Sort-Object SizeMB -Descending | Format-Table
```

---

### Tableau récapitulatif : Return vs Write-Output

|Critère|Return|Write-Output|Sortie implicite|
|---|---|---|---|
|**Termine la fonction**|✅ Oui|❌ Non|❌ Non|
|**Envoie au pipeline**|✅ Oui|✅ Oui|✅ Oui|
|**Sortie multiple**|⚠️ Uniquement via array|✅ Oui (itératif)|✅ Oui (itératif)|
|**Lisibilité**|⭐⭐⭐ Claire|⭐⭐ Explicite|⭐⭐⭐ Naturelle|
|**Performance**|Identique|Identique|Identique|
|**Usage recommandé**|Validation, sortie précoce|Boucles, pipeline explicite|Fonctions simples|

---

### Bonnes pratiques finales

```powershell
# ✅ BONNE PRATIQUE : Fonction cohérente et prévisible
function Get-UserActivity {
    <#
    .SYNOPSIS
    Récupère l'activité d'un utilisateur
    
    .OUTPUTS
    PSCustomObject avec les propriétés UserName, LoginCount, LastLogin
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserName
    )
    
    # Validation en début de fonction
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$UserName'" -ErrorAction SilentlyContinue)) {
        Write-Error "Utilisateur introuvable : $UserName"
        return  # ✅ Sortie précoce en cas d'erreur
    }
    
    # Traitement
    $logs = Get-EventLog -LogName Security -InstanceId 4624 |
            Where-Object { $_.Message -like "*$UserName*" }
    
    # Retour structuré
    [PSCustomObject]@{
        UserName = $UserName
        LoginCount = $logs.Count
        LastLogin = ($logs | Select-Object -First 1).TimeGenerated
        Status = "Active"
    }
}
```

> [!tip] Checklist d'une bonne fonction
> 
> - ✅ Nom respectant la convention Verbe-Nom
> - ✅ Comment-based help complet
> - ✅ Paramètres validés
> - ✅ Retour cohérent et prévisible (un seul type)
> - ✅ Gestion d'erreurs appropriée
> - ✅ Sortie documentée dans `.OUTPUTS`

---

## 🎯 Récapitulatif global

### Ce que vous avez appris

1. **Créer des fonctions d'affichage réutilisables**
    
    - Standardiser l'apparence de vos messages
    - Gérer différents niveaux de gravité
    - Créer des bannières et barres de progression
2. **Nommer correctement vos fonctions**
    
    - Convention Verbe-Nom obligatoire
    - Utiliser les verbes approuvés PowerShell
    - Choisir des noms descriptifs et précis
3. **Documenter avec comment-based help**
    
    - Structure complète d'aide intégrée
    - Documentation accessible via Get-Help
    - Exemples progressifs et clairs
4. **Maîtriser Return vs Write-Output**
    
    - Return pour sortie précoce et validation
    - Write-Output pour génération multiple
    - Sortie implicite pour la simplicité
    - PSCustomObject pour les retours structurés

---

### Exemple complet intégrant tous les concepts

```powershell
function Get-SystemHealthReport {
    <#
    .SYNOPSIS
    Génère un rapport de santé système complet
    
    .DESCRIPTION
    Cette fonction analyse l'état du système (CPU, mémoire, disque, services)
    et génère un rapport structuré avec des indicateurs de santé.
    
    .PARAMETER ComputerName
    Nom de l'ordinateur à analyser. Par défaut : ordinateur local
    
    .PARAMETER IncludeServices
    Inclut l'analyse des services critiques
    
    .EXAMPLE
    Get-SystemHealthReport
    
    Génère un rapport pour l'ordinateur local.
    
    .EXAMPLE
    Get-SystemHealthReport -ComputerName "SERVER01" -IncludeServices
    
    Génère un rapport complet avec analyse des services.
    
    .OUTPUTS
    PSCustomObject avec les propriétés ComputerName, CPULoad, MemoryUsedPercent, etc.
    
    .NOTES
    Auteur : Équipe IT
    Version : 1.0
    Nécessite : PowerShell 5.1+
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ComputerName = $env:COMPUTERNAME,
        
        [Parameter(Mandatory = $false)]
        [switch]$IncludeServices
    )
    
    # Fonction d'affichage interne
    function Write-StatusMessage {
        param (
            [string]$Message,
            [ValidateSet('Info', 'Success', 'Warning', 'Error')]
            [string]$Level = 'Info'
        )
        
        $colors = @{
            Info = 'Cyan'
            Success = 'Green'
            Warning = 'Yellow'
            Error = 'Red'
        }
        
        Write-Host "[$Level] $Message" -ForegroundColor $colors[$Level]
    }
    
    # Validation
    if (-not (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet)) {
        Write-Error "Impossible de joindre $ComputerName"
        return  # Sortie précoce
    }
    
    Write-StatusMessage "Analyse de $ComputerName..." -Level Info
    
    # Collecte des données
    try {
        $cpu = (Get-Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue
        $memory = Get-CimInstance Win32_OperatingSystem
        $memUsedPercent = [math]::Round((($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / $memory.TotalVisibleMemorySize) * 100, 2)
        $disk = Get-PSDrive C
        $diskFreePercent = [math]::Round(($disk.Free / ($disk.Used + $disk.Free)) * 100, 2)
        
        Write-StatusMessage "Données collectées avec succès" -Level Success
    }
    catch {
        Write-Error "Erreur lors de la collecte : $_"
        return
    }
    
    # Construction du rapport
    $report = [PSCustomObject]@{
        ComputerName = $ComputerName
        Timestamp = Get-Date
        CPULoad = [math]::Round($cpu, 2)
        MemoryUsedPercent = $memUsedPercent
        DiskFreePercent = $diskFreePercent
        HealthStatus = "Unknown"
    }
    
    # Évaluation de la santé
    if ($cpu -lt 80 -and $memUsedPercent -lt 90 -and $diskFreePercent -gt 20) {
        $report.HealthStatus = "Healthy"
        Write-StatusMessage "Système en bonne santé" -Level Success
    }
    elseif ($cpu -lt 95 -and $memUsedPercent -lt 95 -and $diskFreePercent -gt 10) {
        $report.HealthStatus = "Warning"
        Write-StatusMessage "Attention requise" -Level Warning
    }
    else {
        $report.HealthStatus = "Critical"
        Write-StatusMessage "Intervention urgente nécessaire !" -Level Error
    }
    
    # Retour du rapport
    return $report
}

# Utilisation
$health = Get-SystemHealthReport -IncludeServices
$health | Format-List
```

---

> [!tip] Prochaine étape Maintenant que vous maîtrisez les fonctions réutilisables, vous êtes prêt à structurer des scripts complets avec une organisation professionnelle et une séparation claire des responsabilités.