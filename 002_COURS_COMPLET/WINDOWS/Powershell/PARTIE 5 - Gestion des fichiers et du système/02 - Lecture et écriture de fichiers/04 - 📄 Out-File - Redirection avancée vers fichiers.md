

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

`Out-File` est la cmdlet PowerShell dédiée à la redirection de sortie vers des fichiers. Contrairement aux opérateurs de redirection simples (`>` et `>>`), `Out-File` offre un contrôle granulaire sur l'encodage, la largeur des lignes, et la protection contre l'écrasement accidentel de fichiers.

> [!info] Pourquoi utiliser Out-File ?
> 
> - **Contrôle précis** de l'encodage du fichier de sortie
> - **Gestion de la largeur** pour éviter la troncature des données
> - **Protection** contre l'écrasement accidentel
> - **Flexibilité** dans le mode d'écriture (écrasement ou ajout)

---

## Syntaxe de base

```powershell
# Syntaxe minimale
Get-Process | Out-File -FilePath "C:\processes.txt"

# Syntaxe complète
Get-Process | Out-File -FilePath "C:\processes.txt" `
                       -Encoding utf8 `
                       -Width 200 `
                       -Append `
                       -NoClobber
```

> [!example] Exemple simple
> 
> ```powershell
> # Exporter la liste des services dans un fichier
> Get-Service | Out-File -FilePath "C:\services.txt"
> ```

---

## Le paramètre -FilePath

Le paramètre `-FilePath` (ou son alias `-Path`) spécifie le chemin complet ou relatif du fichier de destination.

```powershell
# Chemin absolu
Get-Process | Out-File -FilePath "C:\Logs\processes.txt"

# Chemin relatif
Get-Process | Out-File -FilePath ".\logs\processes.txt"

# Utilisation de variables
$outputPath = "C:\Reports\daily_$(Get-Date -Format 'yyyy-MM-dd').txt"
Get-Process | Out-File -FilePath $outputPath

# Avec alias -Path
Get-Process | Out-File -Path "C:\output.txt"
```

> [!tip] Création automatique de répertoires Si le répertoire parent n'existe pas, `Out-File` génère une erreur. Créez-le au préalable :
> 
> ```powershell
> $directory = "C:\Logs\Reports"
> if (-not (Test-Path $directory)) {
>     New-Item -ItemType Directory -Path $directory -Force
> }
> Get-Process | Out-File -FilePath "$directory\output.txt"
> ```

---

## L'encodage avec -Encoding

Le paramètre `-Encoding` définit l'encodage de caractères utilisé pour écrire le fichier. C'est crucial pour la compatibilité avec d'autres systèmes et applications.

### Encodages disponibles

|Encodage|Description|Usage recommandé|
|---|---|---|
|`utf8`|UTF-8 sans BOM|Fichiers texte modernes, compatibilité Linux/Mac|
|`utf8BOM`|UTF-8 avec BOM|Fichiers nécessitant une détection explicite UTF-8|
|`utf8NoBOM`|UTF-8 sans BOM (alias de utf8)|Même usage que utf8|
|`unicode`|UTF-16 LE avec BOM|Compatibilité Windows|
|`ascii`|ASCII 7-bits|Fichiers sans caractères spéciaux|
|`utf32`|UTF-32|Rarement utilisé, fichiers volumineux|
|`bigendianunicode`|UTF-16 BE|Systèmes big-endian|

```powershell
# UTF-8 sans BOM (recommandé pour la plupart des cas)
Get-Content "C:\data.txt" | Out-File -FilePath "C:\output.txt" -Encoding utf8

# UTF-8 avec BOM
Get-Process | Out-File -FilePath "C:\processes.txt" -Encoding utf8BOM

# ASCII pour compatibilité maximale
Get-Date | Out-File -FilePath "C:\date.txt" -Encoding ascii

# Unicode UTF-16 (par défaut dans les anciennes versions)
Get-Service | Out-File -FilePath "C:\services.txt" -Encoding unicode
```

> [!warning] Encodage par défaut Dans PowerShell 5.1, l'encodage par défaut est `unicode` (UTF-16). Dans PowerShell 7+, l'encodage par défaut est `utf8NoBOM`. Spécifiez toujours l'encodage explicitement pour éviter les surprises.

> [!example] Gestion des caractères accentués
> 
> ```powershell
> # Données avec accents
> "Voici des données accentuées : été, café, naïve" | 
>     Out-File -FilePath "C:\accents.txt" -Encoding utf8
> 
> # Vérification
> Get-Content "C:\accents.txt" -Encoding utf8
> ```

---

## Ajouter du contenu avec -Append

Le paramètre `-Append` permet d'ajouter du contenu à la fin d'un fichier existant au lieu de l'écraser.

```powershell
# Première écriture (crée ou écrase le fichier)
Get-Date | Out-File -FilePath "C:\log.txt"

# Ajout de contenu
"Nouvelle entrée" | Out-File -FilePath "C:\log.txt" -Append

# Ajout multiple
Get-Process | Out-File -FilePath "C:\log.txt" -Append
Get-Service | Out-File -FilePath "C:\log.txt" -Append
```

> [!example] Création d'un fichier de log
> 
> ```powershell
> $logFile = "C:\Logs\application.log"
> 
> # Fonction pour ajouter une entrée de log
> function Write-Log {
>     param([string]$Message)
>     $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
>     "$timestamp - $Message" | Out-File -FilePath $logFile -Append -Encoding utf8
> }
> 
> # Utilisation
> Write-Log "Application démarrée"
> Write-Log "Traitement en cours"
> Write-Log "Application terminée"
> ```

> [!warning] Attention à l'encodage avec -Append Assurez-vous d'utiliser le même encodage lors de l'ajout :
> 
> ```powershell
> # Première écriture en UTF-8
> "Ligne 1" | Out-File -FilePath "C:\data.txt" -Encoding utf8
> 
> # Ajout avec le même encodage
> "Ligne 2" | Out-File -FilePath "C:\data.txt" -Append -Encoding utf8
> ```

---
## Tee-Object - Dupliquer vers fichier et console

`Tee-Object` (alias : `tee`) permet de **dupliquer** le flux du pipeline : il envoie les données **à la fois** vers un fichier **et** vers la sortie standard (console ou pipeline suivant).

Le nom vient de la forme en "T" d'un tuyau qui divise le flux en deux directions.

### Syntaxe de base

```powershell
# Afficher dans la console ET sauvegarder dans un fichier
Get-Process | Tee-Object -FilePath "processes.txt"

# Version courte avec l'alias
Get-Service | tee services.txt

# Via le pipeline avec une chaîne
"Texte important" | Tee-Object -FilePath "log.txt"
```

> [!info] Comportement par défaut Par défaut, `Tee-Object` **écrase** le fichier existant (comme `Out-File` sans `-Append`).

### Ajouter au fichier avec -Append

Pour ajouter au lieu d'écraser, utilisez le paramètre `-Append`.

```powershell
# Ajouter à un fichier existant
Get-Date | Tee-Object -FilePath "logs.txt" -Append

# Logging continu
"Début du processus" | Tee-Object "script.log" -Append
Get-ChildItem C:\Temp | Tee-Object "script.log" -Append
"Fin du processus" | Tee-Object "script.log" -Append
```

### Affichage ET sauvegarde simultanés

L'intérêt principal de `Tee-Object` est de voir les résultats à l'écran tout en les sauvegardant.

```powershell
# Voir les processus ET les sauvegarder
Get-Process | Where-Object CPU -gt 100 | Tee-Object "heavy-processes.txt"

# Afficher les erreurs système ET les logger
Get-EventLog -LogName System -EntryType Error -Newest 10 | 
    Tee-Object "errors.txt"

# Pipeline avec traitement après sauvegarde
Get-Service | 
    Tee-Object "all-services.txt" | 
    Where-Object Status -eq "Running" | 
    Select-Object Name, DisplayName
```

> [!tip] Continuer le pipeline Contrairement à `Out-File`, `Tee-Object` ne termine pas le pipeline. Vous pouvez continuer à traiter les données après la sauvegarde.

### Sauvegarder dans une variable avec -Variable

`Tee-Object` peut aussi dupliquer vers une **variable** au lieu d'un fichier.

```powershell
# Sauvegarder dans une variable ET continuer le pipeline
Get-Process | Tee-Object -Variable allProcesses | Where-Object CPU -gt 50

# Maintenant $allProcesses contient tous les processus
$allProcesses.Count

# Utile pour garder une trace avant filtrage
Get-ChildItem C:\Logs | 
    Tee-Object -Variable allFiles | 
    Where-Object Extension -eq ".log" |
    Remove-Item

# On peut toujours consulter $allFiles pour voir ce qui a été supprimé
```

> [!warning] Pas de -FilePath et -Variable ensemble Vous ne pouvez pas utiliser `-FilePath` et `-Variable` en même temps. Choisissez l'un ou l'autre.

### Cas d'usage pratiques

#### Logging avec visibilité

```powershell
# Script avec affichage ET log automatique
function Process-Data {
    "Début du traitement..." | Tee-Object "process.log" -Append
    
    $result = Get-ChildItem C:\Data -Recurse | 
        Tee-Object "process.log" -Append |
        Measure-Object
    
    "Fichiers traités : $($result.Count)" | Tee-Object "process.log" -Append
}
```

#### Debugging intermédiaire

```powershell
# Voir les données à chaque étape du pipeline
Get-Service |
    Tee-Object "1-all-services.txt" |
    Where-Object Status -eq "Running" |
    Tee-Object "2-running-services.txt" |
    Select-Object Name, DisplayName |
    Tee-Object "3-filtered-output.txt"
```

#### Sauvegarde avant traitement destructif

```powershell
# Garder une copie avant de modifier
Get-Content "config.txt" |
    Tee-Object "config-backup.txt" |
    ForEach-Object { $_.Replace("old", "new") } |
    Set-Content "config.txt"
```

### Encodage avec -Encoding

Comme `Out-File`, vous pouvez spécifier l'encodage du fichier de sortie.

```powershell
# Spécifier l'encodage
Get-Process | Tee-Object -FilePath "processes.txt" -Encoding UTF8

# Encodages disponibles
"Texte accentué" | Tee-Object "file.txt" -Encoding ASCII
"Texte accentué" | Tee-Object "file.txt" -Encoding Unicode
"Texte accentué" | Tee-Object "file.txt" -Encoding UTF8
```

### Tee-Object vs Out-File

|Critère|Tee-Object|Out-File|
|---|---|---|
|**Continue le pipeline**|✅ Oui|❌ Non (termine)|
|**Affiche à l'écran**|✅ Oui|❌ Non|
|**Sauvegarde dans fichier**|✅ Oui|✅ Oui|
|**Sauvegarde dans variable**|✅ Oui|❌ Non|
|**Paramètre -Append**|✅ Oui|✅ Oui|
|**Contrôle de largeur**|❌ Non|✅ Oui (-Width)|

```powershell
# Out-File : sauvegarde SEULEMENT (pas d'affichage)
Get-Process | Out-File "processes.txt"
# Rien ne s'affiche à l'écran

# Tee-Object : sauvegarde ET affiche
Get-Process | Tee-Object "processes.txt"
# Les processus s'affichent à l'écran ET sont sauvegardés
```

> [!example] Cas pratique : Script avec rapport
> 
> ```powershell
> # Générer un rapport visible ET sauvegardé
> $rapport = Get-Date | Tee-Object "rapport.txt"
> "" | Tee-Object "rapport.txt" -Append
> 
> "=== État des services ===" | Tee-Object "rapport.txt" -Append
> Get-Service | 
>     Group-Object Status | 
>     Select-Object Name, Count |
>     Tee-Object "rapport.txt" -Append
> 
> "" | Tee-Object "rapport.txt" -Append
> "=== Espace disque ===" | Tee-Object "rapport.txt" -Append
> Get-PSDrive -PSProvider FileSystem | 
>     Select-Object Name, Used, Free |
>     Tee-Object "rapport.txt" -Append
> ```

### Combinaison avec Write-Host

Si vous voulez utiliser `Write-Host` pour l'affichage coloré tout en sauvegardant, combinez les deux.

```powershell
# Afficher en couleur ET sauvegarder en texte brut
$data = Get-Service | Where-Object Status -eq "Running"

# Sauvegarder d'abord
$data | Tee-Object "services.txt" | Out-Null

# Puis afficher en couleur
$data | ForEach-Object {
    Write-Host $_.Name -ForegroundColor Green
}
```

> [!tip] Quand utiliser Tee-Object ? Utilisez `Tee-Object` quand vous avez besoin de :
> 
> - Voir les résultats en temps réel tout en les sauvegardant
> - Continuer à traiter les données après la sauvegarde
> - Débugger un pipeline complexe en sauvegardant les étapes intermédiaires
> - Garder une trace avant un traitement destructif

---  

## Contrôler la largeur avec -Width

Le paramètre `-Width` définit le nombre maximum de caractères par ligne avant un retour à la ligne automatique. La valeur par défaut est généralement 80 caractères.

```powershell
# Largeur par défaut (80 caractères)
Get-Process | Out-File -FilePath "C:\processes.txt"

# Augmenter la largeur pour éviter la troncature
Get-Process | Out-File -FilePath "C:\processes.txt" -Width 200

# Largeur illimitée
Get-Process | Out-File -FilePath "C:\processes.txt" -Width ([int]::MaxValue)

# Largeur réduite
Get-Content "C:\long_lines.txt" | Out-File -FilePath "C:\wrapped.txt" -Width 50
```

> [!info] Pourquoi la largeur est importante ? Par défaut, PowerShell formate la sortie pour une largeur de console standard (80 caractères). Si vos données contiennent des lignes plus longues, elles seront tronquées ou mal formatées. Utilisez `-Width` pour préserver l'intégralité des données.

> [!example] Exportation de tableaux larges
> 
> ```powershell
> # Sans -Width : données tronquées
> Get-Process | Select-Object Name, Id, CPU, WorkingSet, Path | 
>     Out-File -FilePath "C:\processes_truncated.txt"
> 
> # Avec -Width : toutes les données visibles
> Get-Process | Select-Object Name, Id, CPU, WorkingSet, Path | 
>     Out-File -FilePath "C:\processes_complete.txt" -Width 300
> ```

> [!tip] Largeur recommandée pour les données structurées Pour éviter tout problème de troncature :
> 
> ```powershell
> # Largeur "illimitée" pour les exports de données
> Get-Process | Out-File -FilePath "C:\data.txt" -Width 1000
> 
> # Ou utiliser la valeur maximale
> Get-Process | Out-File -FilePath "C:\data.txt" -Width ([int]::MaxValue)
> ```

---

## Protéger les fichiers avec -NoClobber

Le paramètre `-NoClobber` empêche l'écrasement d'un fichier existant. Si le fichier existe déjà, PowerShell génère une erreur au lieu de le remplacer.

```powershell
# Sans -NoClobber : écrase le fichier existant
Get-Process | Out-File -FilePath "C:\processes.txt"

# Avec -NoClobber : erreur si le fichier existe
Get-Process | Out-File -FilePath "C:\processes.txt" -NoClobber

# Message d'erreur typique :
# Out-File : The file 'C:\processes.txt' already exists.
```

> [!example] Protection contre l'écrasement accidentel
> 
> ```powershell
> # Script de sauvegarde sécurisé
> $backupFile = "C:\Backups\config_backup.txt"
> 
> try {
>     Get-Content "C:\config.ini" | 
>         Out-File -FilePath $backupFile -NoClobber -ErrorAction Stop
>     Write-Host "Sauvegarde créée avec succès"
> }
> catch {
>     Write-Warning "Le fichier de sauvegarde existe déjà. Aucune action effectuée."
> }
> ```

> [!tip] Création de fichiers horodatés pour éviter les conflits
> 
> ```powershell
> # Ajouter un horodatage au nom du fichier
> $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
> $outputFile = "C:\Logs\report_$timestamp.txt"
> 
> # Pas besoin de -NoClobber car le nom est unique
> Get-Process | Out-File -FilePath $outputFile
> ```

---

## Différence avec > et >>

PowerShell propose des opérateurs de redirection simples (`>` et `>>`) qui sont des raccourcis pour `Out-File`.

### Tableau comparatif

|Fonctionnalité|`>`|`>>`|`Out-File`|
|---|---|---|---|
|Écrase le fichier|✅|❌|✅ (par défaut)|
|Ajoute au fichier|❌|✅|✅ (avec `-Append`)|
|Contrôle de l'encodage|❌|❌|✅|
|Contrôle de la largeur|❌|❌|✅|
|Protection -NoClobber|❌|❌|✅|
|Syntaxe courte|✅|✅|❌|

### Exemples de comparaison

```powershell
# Opérateur > : écrase le fichier
Get-Process > C:\processes.txt

# Équivalent avec Out-File
Get-Process | Out-File -FilePath "C:\processes.txt"

# Opérateur >> : ajoute au fichier
Get-Service >> C:\processes.txt

# Équivalent avec Out-File
Get-Service | Out-File -FilePath "C:\processes.txt" -Append
```

> [!warning] Limitations des opérateurs > et >>
> 
> ```powershell
> # Problème : encodage non contrôlable avec >
> "Caractères accentués : été" > C:\data.txt
> # Encodage par défaut utilisé (peut causer des problèmes)
> 
> # Solution : utiliser Out-File avec encodage explicite
> "Caractères accentués : été" | Out-File -FilePath "C:\data.txt" -Encoding utf8
> ```

> [!info] Quand utiliser quoi ?
> 
> - **Utilisez `>` et `>>`** pour des scripts rapides et simples sans exigences particulières
> - **Utilisez `Out-File`** quand vous avez besoin de :
>     - Contrôler l'encodage
>     - Définir une largeur de ligne spécifique
>     - Protéger contre l'écrasement avec `-NoClobber`
>     - Garantir la compatibilité et la portabilité de vos scripts

---

## Out-File vs Set-Content

`Out-File` et `Set-Content` peuvent tous deux écrire dans des fichiers, mais ils fonctionnent différemment et ont des cas d'usage distincts.

### Différences fondamentales

|Aspect|`Out-File`|`Set-Content`|
|---|---|---|
|Nature|Cmdlet de sortie (Out-*)|Cmdlet de contenu (Content)|
|Formatage|Formate les objets comme à l'écran|Écrit les valeurs brutes|
|Largeur|Respecte `-Width`|Pas de gestion de largeur|
|Objets|Convertit objets en texte formaté|Convertit objets en chaînes simples|
|Usage principal|Rapports lisibles, logs formatés|Données brutes, configuration|

### Exemples de comparaison

```powershell
# Out-File : sortie formatée (comme à l'écran)
Get-Process | Select-Object -First 3 | Out-File -FilePath "C:\formatted.txt"
# Résultat : tableau formaté avec en-têtes et colonnes alignées

# Set-Content : valeurs brutes
Get-Process | Select-Object -First 3 | Set-Content -Path "C:\raw.txt"
# Résultat : représentation d'objets non formatée
```

> [!example] Comparaison pratique
> 
> ```powershell
> # Création d'objets de test
> $data = Get-Process | Select-Object -First 3 Name, CPU, WorkingSet
> 
> # Avec Out-File : sortie formatée et lisible
> $data | Out-File -FilePath "C:\outfile_result.txt" -Width 100
> # Contenu : tableau bien formaté avec colonnes alignées
> 
> # Avec Set-Content : représentation d'objets
> $data | Set-Content -Path "C:\setcontent_result.txt"
> # Contenu : objets sérialisés, moins lisible
> ```

### Cas d'usage recommandés

**Utilisez `Out-File` pour :**

- 📊 Créer des rapports lisibles par des humains
- 📋 Exporter des tableaux formatés
- 📝 Générer des logs avec mise en forme
- 🖥️ Capturer une sortie "comme à l'écran"

```powershell
# Rapport formaté
Get-Service | 
    Where-Object Status -eq "Running" | 
    Out-File -FilePath "C:\running_services.txt" -Width 150
```

**Utilisez `Set-Content` pour :**

- 📄 Écrire du texte brut sans formatage
- ⚙️ Créer ou modifier des fichiers de configuration
- 💾 Sauvegarder des données simples (chaînes, nombres)
- 🔄 Remplacer complètement le contenu d'un fichier

```powershell
# Fichier de configuration
$configContent = @"
ServerName=localhost
Port=8080
Timeout=30
"@
Set-Content -Path "C:\config.ini" -Value $configContent
```

> [!tip] Règle simple
> 
> - **Besoin de formatage et de lisibilité** → `Out-File`
> - **Besoin de données brutes et simples** → `Set-Content`

---

## Pièges courants

### 1. Oublier de spécifier l'encodage

```powershell
# ❌ Problème : encodage non défini
"Caractères spéciaux : é, à, ç" | Out-File -FilePath "C:\data.txt"
# L'encodage par défaut peut varier selon la version de PowerShell

# ✅ Solution : toujours spécifier l'encodage
"Caractères spéciaux : é, à, ç" | Out-File -FilePath "C:\data.txt" -Encoding utf8
```

### 2. Données tronquées par la largeur par défaut

```powershell
# ❌ Problème : données coupées à 80 caractères
Get-Process | Out-File -FilePath "C:\processes.txt"

# ✅ Solution : augmenter la largeur
Get-Process | Out-File -FilePath "C:\processes.txt" -Width 200
```

### 3. Confondre -Append et écrasement

```powershell
# ❌ Erreur : écrase les données précédentes
for ($i = 1; $i -le 5; $i++) {
    "Ligne $i" | Out-File -FilePath "C:\data.txt"
}
# Résultat : seule "Ligne 5" est dans le fichier

# ✅ Solution : utiliser -Append
"Ligne 1" | Out-File -FilePath "C:\data.txt"  # Première ligne
for ($i = 2; $i -le 5; $i++) {
    "Ligne $i" | Out-File -FilePath "C:\data.txt" -Append
}
```

### 4. Mélanger les encodages lors de l'ajout

```powershell
# ❌ Problème : encodages différents
"Ligne 1" | Out-File -FilePath "C:\data.txt" -Encoding utf8
"Ligne 2" | Out-File -FilePath "C:\data.txt" -Append -Encoding unicode
# Résultat : fichier corrompu

# ✅ Solution : encodage cohérent
"Ligne 1" | Out-File -FilePath "C:\data.txt" -Encoding utf8
"Ligne 2" | Out-File -FilePath "C:\data.txt" -Append -Encoding utf8
```

### 5. Ignorer les erreurs de chemin

```powershell
# ❌ Problème : le répertoire n'existe pas
Get-Process | Out-File -FilePath "C:\NonExistent\Folder\data.txt"
# Erreur : chemin introuvable

# ✅ Solution : créer le répertoire d'abord
$directory = "C:\NonExistent\Folder"
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}
Get-Process | Out-File -FilePath "$directory\data.txt"
```

---

## Bonnes pratiques

### 1. Toujours spécifier l'encodage explicitement

```powershell
# ✅ Bonne pratique
Get-Process | Out-File -FilePath "C:\data.txt" -Encoding utf8
```

### 2. Utiliser des variables pour les chemins

```powershell
# ✅ Code maintenable
$outputDir = "C:\Logs"
$outputFile = "$outputDir\report_$(Get-Date -Format 'yyyyMMdd').txt"

Get-Process | Out-File -FilePath $outputFile -Encoding utf8 -Width 200
```

### 3. Inclure un horodatage pour les fichiers de log

```powershell
# ✅ Évite les conflits
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = "C:\Logs\application_$timestamp.log"

Get-Process | Out-File -FilePath $logFile -Encoding utf8
```

### 4. Utiliser -NoClobber pour les opérations critiques

```powershell
# ✅ Protection contre l'écrasement accidentel
try {
    Get-Content "C:\important_data.txt" | 
        Out-File -FilePath "C:\backup.txt" -NoClobber -ErrorAction Stop
}
catch {
    Write-Warning "Fichier de sauvegarde déjà existant"
}
```

### 5. Combiner avec Test-Path pour la gestion de fichiers

```powershell
# ✅ Vérification avant écriture
$outputFile = "C:\data.txt"

if (Test-Path $outputFile) {
    # Le fichier existe : ajouter
    Get-Process | Out-File -FilePath $outputFile -Append -Encoding utf8
}
else {
    # Le fichier n'existe pas : créer
    Get-Process | Out-File -FilePath $outputFile -Encoding utf8
}
```

### 6. Utiliser une largeur suffisante pour les données structurées

```powershell
# ✅ Évite la troncature des données
Get-Process | 
    Select-Object Name, Id, CPU, WorkingSet, Path | 
    Out-File -FilePath "C:\processes.txt" -Width 300 -Encoding utf8
```

### 7. Créer des fonctions réutilisables

```powershell
# ✅ Fonction d'export standardisée
function Export-ToFile {
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject,
        
        [string]$FilePath,
        [string]$Encoding = "utf8",
        [int]$Width = 200,
        [switch]$Append
    )
    
    process {
        $params = @{
            FilePath = $FilePath
            Encoding = $Encoding
            Width = $Width
        }
        
        if ($Append) { $params['Append'] = $true }
        
        $InputObject | Out-File @params
    }
}

# Utilisation
Get-Process | Export-ToFile -FilePath "C:\processes.txt"
```

### 8. Documenter l'encodage utilisé

```powershell
# ✅ Documentation claire
# Ce fichier est encodé en UTF-8 sans BOM
$configData = @"
# Configuration file - UTF-8 encoding
Server=localhost
Port=8080
"@

$configData | Out-File -FilePath "C:\config.txt" -Encoding utf8
```

---

> [!tip] 💡 Astuce finale `Out-File` est votre outil de prédilection quand vous avez besoin d'un contrôle précis sur la façon dont les données sont écrites dans un fichier. Pour des opérations simples, les opérateurs `>` et `>>` sont suffisants, mais dès que vous travaillez avec des données importantes, des caractères spéciaux, ou que vous devez garantir un format spécifique, `Out-File` devient indispensable.