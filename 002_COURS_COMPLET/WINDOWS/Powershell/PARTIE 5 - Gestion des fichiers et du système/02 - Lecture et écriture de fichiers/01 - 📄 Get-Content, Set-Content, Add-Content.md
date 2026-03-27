

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

Les cmdlets `*-Content` constituent la famille principale pour manipuler le contenu de fichiers texte en PowerShell. Ces commandes permettent de lire, écrire, ajouter ou vider le contenu de fichiers de manière simple et efficace.

> [!info] Pourquoi utiliser `*-Content` ?
> 
> - **Simplicité** : Syntaxe intuitive pour les opérations courantes
> - **Flexibilité** : Gestion automatique des encodages et formats
> - **Pipeline-friendly** : S'intègrent parfaitement dans les pipelines PowerShell
> - **Multiplateforme** : Fonctionnent sur Windows, Linux et macOS

---

## Get-Content - Lecture de fichiers

`Get-Content` (alias : `gc`, `cat`, `type`) lit le contenu d'un fichier et le retourne ligne par ligne sous forme de tableau de chaînes.

### Lecture basique

```powershell
# Lecture simple d'un fichier
Get-Content -Path "C:\logs\app.log"

# Avec l'alias (plus court)
gc "C:\logs\app.log"

# Lecture et affichage
Get-Content "config.txt" | ForEach-Object { Write-Host $_ }
```

> [!example] Exemple pratique
> 
> ```powershell
> # Lire un fichier de configuration et chercher une valeur
> $config = Get-Content "app.config"
> $database = $config | Where-Object { $_ -match "DatabaseConnection" }
> ```

### Limiter le nombre de lignes

PowerShell offre deux paramètres pour limiter la lecture : `-TotalCount` (du début) et `-Tail` (de la fin).

```powershell
# Lire les 10 premières lignes (équivalent de "head" sous Unix)
Get-Content "large-file.txt" -TotalCount 10

# Lire les 20 dernières lignes (équivalent de "tail" sous Unix)
Get-Content "app.log" -Tail 20

# Alias plus courts
gc "file.txt" -First 5    # Alias de -TotalCount
gc "file.txt" -Last 15    # Alias de -Tail
```

> [!tip] Astuce de performance Utiliser `-TotalCount` ou `-Tail` est **beaucoup plus rapide** que lire tout le fichier puis filtrer avec `Select-Object`, surtout pour les gros fichiers (plusieurs Go).

### Optimisation des performances

Le paramètre `-ReadCount` contrôle combien de lignes sont envoyées dans le pipeline à la fois.

```powershell
# Valeur par défaut : 1 ligne à la fois (peut être lent)
Get-Content "large.txt" | ForEach-Object { Process-Line $_ }

# Envoyer par blocs de 100 lignes (plus rapide)
Get-Content "large.txt" -ReadCount 100 | ForEach-Object { 
    # $_ contient maintenant un tableau de 100 lignes
    foreach ($line in $_) {
        Process-Line $line
    }
}

# Lire tout d'un coup (valeur 0)
Get-Content "medium.txt" -ReadCount 0 | ForEach-Object {
    # $_ contient toutes les lignes en un seul tableau
    Write-Host "Total de $($_.Count) lignes"
}
```

> [!warning] Attention à la mémoire `-ReadCount 0` charge tout le fichier en mémoire. À éviter pour les fichiers de plusieurs centaines de Mo ou plus.

### Gestion des encodages

Le paramètre `-Encoding` spécifie comment interpréter les octets du fichier.

```powershell
# Lecture avec encodage UTF8
Get-Content "utf8-file.txt" -Encoding UTF8

# Lecture avec encodage ASCII
Get-Content "ascii-file.txt" -Encoding ASCII

# Encodages disponibles
Get-Content "file.txt" -Encoding UTF8
Get-Content "file.txt" -Encoding UTF7
Get-Content "file.txt" -Encoding UTF32
Get-Content "file.txt" -Encoding Unicode      # UTF16-LE
Get-Content "file.txt" -Encoding BigEndianUnicode  # UTF16-BE
Get-Content "file.txt" -Encoding ASCII
Get-Content "file.txt" -Encoding Default      # Encodage système
Get-Content "file.txt" -Encoding OEM          # Page de code OEM
```

> [!example] Cas pratique : Fichier avec accents
> 
> ```powershell
> # Si les accents s'affichent mal
> Get-Content "français.txt" -Encoding UTF8
> 
> # Pour un vieux fichier DOS
> Get-Content "old-dos.txt" -Encoding OEM
> ```

### Lecture en chaîne unique

Par défaut, `Get-Content` retourne un tableau de lignes. Le paramètre `-Raw` lit tout en une seule chaîne.

```powershell
# Lecture normale (tableau de lignes)
$lines = Get-Content "file.txt"
$lines.GetType()  # System.Object[] (tableau)

# Lecture en chaîne unique
$content = Get-Content "file.txt" -Raw
$content.GetType()  # System.String

# Utile pour les fichiers JSON, XML, etc.
$json = Get-Content "config.json" -Raw | ConvertFrom-Json
```

> [!tip] Quand utiliser `-Raw` ?
> 
> - Fichiers JSON/XML à parser
> - Recherche de motifs multi-lignes avec regex
> - Fichiers binaires encodés en texte (Base64)
> - Quand la structure ligne par ligne n'a pas d'importance

### Surveillance en temps réel

Le paramètre `-Wait` surveille le fichier et affiche les nouvelles lignes en temps réel (comme `tail -f` sous Unix).

```powershell
# Surveiller un fichier de log en continu
Get-Content "C:\logs\app.log" -Wait

# Surveiller seulement les 10 dernières lignes au départ
Get-Content "C:\logs\app.log" -Tail 10 -Wait

# Avec filtre en temps réel
Get-Content "app.log" -Wait | Where-Object { $_ -match "ERROR" }
```

> [!warning] Arrêt de la surveillance Utilisez `Ctrl+C` pour arrêter la surveillance. Le processus continue indéfiniment sinon.

> [!example] Monitoring de logs
> 
> ```powershell
> # Surveiller plusieurs types d'erreurs avec couleurs
> Get-Content "app.log" -Wait | ForEach-Object {
>     if ($_ -match "ERROR") { 
>         Write-Host $_ -ForegroundColor Red 
>     }
>     elseif ($_ -match "WARNING") { 
>         Write-Host $_ -ForegroundColor Yellow 
>     }
>     else { 
>         Write-Host $_ 
>     }
> }
> ```

---

## Set-Content - Écriture de fichiers

`Set-Content` (alias : `sc`) écrit du contenu dans un fichier, **en écrasant le contenu existant**.

### Écriture basique

```powershell
# Écrire une chaîne simple
Set-Content -Path "output.txt" -Value "Hello World"

# Écrire plusieurs lignes
Set-Content "multi.txt" -Value "Ligne 1", "Ligne 2", "Ligne 3"

# Via le pipeline
"Contenu" | Set-Content "file.txt"

# Écrire le résultat d'une commande
Get-Process | Out-String | Set-Content "processes.txt"
```

> [!warning] Écrasement du contenu `Set-Content` **remplace complètement** le contenu existant. Si vous voulez ajouter, utilisez `Add-Content`.

### Création automatique

Si le fichier n'existe pas, `Set-Content` le crée automatiquement (avec les dossiers parents si nécessaire avec `-Force`).

```powershell
# Crée le fichier s'il n'existe pas
Set-Content "nouveau.txt" -Value "Premier contenu"

# Crée les dossiers manquants ET le fichier
Set-Content "C:\Logs\2024\01\app.log" -Value "Log entry" -Force
```

> [!tip] Création de structure Utilisez `-Force` pour créer toute l'arborescence en une commande sans vérifier l'existence préalable.

### Gestion de l'encodage

Comme `Get-Content`, `-Encoding` contrôle le format de sortie.

```powershell
# Écriture en UTF8 (recommandé pour la compatibilité)
Set-Content "utf8.txt" -Value "Texte avec accents : éèêë" -Encoding UTF8

# Écriture en ASCII (attention aux caractères spéciaux)
Set-Content "ascii.txt" -Value "Simple text" -Encoding ASCII

# Écriture en Unicode (UTF16)
Set-Content "unicode.txt" -Value "Données" -Encoding Unicode
```

> [!info] Encodage par défaut Sur PowerShell 5.1 (Windows), l'encodage par défaut est UTF16-LE. Sur PowerShell 7+, c'est UTF8 sans BOM. Spécifiez toujours `-Encoding` pour la portabilité.

### Forcer l'écriture

Le paramètre `-Force` permet d'écrire dans des fichiers read-only ou cachés.

```powershell
# Écriture normale (échoue si read-only)
Set-Content "protected.txt" -Value "Nouveau contenu"
# Erreur : Accès refusé

# Forcer l'écriture
Set-Content "protected.txt" -Value "Nouveau contenu" -Force
# Fonctionne même si read-only
```

> [!warning] Utilisation de `-Force` `-Force` contourne les protections. Utilisez-le consciemment et vérifiez que vous avez les permissions nécessaires.

### Écriture de tableaux

Quand vous passez un tableau, `Set-Content` écrit chaque élément sur une ligne séparée.

```powershell
# Tableau de chaînes
$data = @("Ligne 1", "Ligne 2", "Ligne 3")
Set-Content "array.txt" -Value $data
# Résultat : 3 lignes dans le fichier

# Tableaux d'objets (convertis en chaînes)
$users = @("Alice", "Bob", "Charlie")
Set-Content "users.txt" -Value $users

# Objets complexes (utilisez Out-String)
$processes = Get-Process | Select-Object -First 5
$processes | Out-String | Set-Content "processes.txt"
```

> [!example] Export de données formatées
> 
> ```powershell
> # Export d'une liste de services
> Get-Service | 
>     Select-Object Name, Status | 
>     Format-Table -AutoSize | 
>     Out-String | 
>     Set-Content "services.txt"
> ```

---

## Add-Content - Ajout de contenu

`Add-Content` (alias : `ac`) ajoute du contenu **à la fin** d'un fichier existant, sans écraser.

### Ajout basique

```powershell
# Ajouter une ligne à un fichier existant
Add-Content -Path "log.txt" -Value "Nouvelle entrée de log"

# Ajouter plusieurs lignes
Add-Content "notes.txt" -Value "Note 1", "Note 2", "Note 3"

# Via le pipeline
"Ligne supplémentaire" | Add-Content "file.txt"
```

> [!info] Création si inexistant Si le fichier n'existe pas, `Add-Content` le crée (comme `Set-Content`), puis y ajoute le contenu.

### Ajouter des sorties de commandes

`Add-Content` est particulièrement utile pour rediriger des résultats de commandes dans des fichiers.

```powershell
# Ajouter la sortie d'une commande dans un fichier
Get-Process | Out-String | Add-Content "processes.txt"

# Ajouter des informations système
Get-ComputerInfo | Select-Object CsName, OsArchitecture, OsVersion | 
    Out-String | Add-Content "system-info.txt"

# Ajouter une liste de services
Get-Service | Where-Object Status -eq "Running" | 
    Format-Table Name, DisplayName | Out-String | Add-Content "services.txt"

# Ajouter des résultats filtrés
Get-ChildItem -Path C:\Logs -Filter "*.log" | 
    Select-Object Name, Length, LastWriteTime | 
    ConvertTo-Csv -NoTypeInformation | 
    Add-Content "fichiers-logs.csv"
```

> [!tip] Out-String est votre ami Utilisez `Out-String` pour convertir des objets PowerShell en texte lisible avant de les ajouter avec `Add-Content`. Sans cela, vous risquez d'obtenir des sorties comme `System.Object[]`.

### Encodage et caractères spéciaux

Par défaut, `Add-Content` utilise l'encodage du système. Vous pouvez le spécifier explicitement.

```powershell
# Spécifier l'encodage
Add-Content -Path "utf8file.txt" -Value "Caractères accentués : é à ç" -Encoding UTF8

# Encodages disponibles
Add-Content "file.txt" -Value "Texte" -Encoding ASCII
Add-Content "file.txt" -Value "Texte" -Encoding Unicode
Add-Content "file.txt" -Value "Texte" -Encoding UTF8
Add-Content "file.txt" -Value "Texte" -Encoding UTF32

# Ajouter une ligne vide
Add-Content "file.txt" -Value ""

# Ajouter du contenu avec tabulations
Add-Content "data.txt" -Value "Colonne1`tColonne2`tColonne3"
```

### Gestion des sauts de ligne

```powershell
# Par défaut, Add-Content ajoute un saut de ligne après chaque valeur
Add-Content "file.txt" -Value "Ligne 1"
Add-Content "file.txt" -Value "Ligne 2"
# Résultat : deux lignes distinctes

# Ajouter plusieurs lignes d'un coup
$texte = @"
Première ligne
Deuxième ligne
Troisième ligne
"@
Add-Content "file.txt" -Value $texte

# Sans saut de ligne à la fin (astuce)
$content = Get-Content "file.txt" -Raw
$content += "Suite sur la même ligne"
Set-Content "file.txt" -Value $content -NoNewline
```

### Logging et journalisation

`Add-Content` est parfait pour créer des logs applicatifs.

```powershell
# Fonction de logging simple
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Add-Content "app.log"
}

# Utilisation
Write-Log "Application démarrée"
Write-Log "Connexion utilisateur : admin"
Write-Log "Erreur de connexion base de données"

# Log avec niveau
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content "app.log" -Value "[$timestamp] [$Level] $Message"
}
```

> [!example] Cas pratique : Journal d'exécution
> 
> ```powershell
> # Script avec logging automatique
> $logFile = "C:\Logs\backup-$(Get-Date -Format 'yyyyMMdd').log"
> 
> "Début de la sauvegarde" | Add-Content $logFile
> 
> try {
>     Copy-Item -Path "C:\Data" -Destination "D:\Backup" -Recurse
>     "Sauvegarde réussie" | Add-Content $logFile
> }
> catch {
>     "ERREUR : $($_.Exception.Message)" | Add-Content $logFile
> }
> 
> "Fin de la sauvegarde" | Add-Content $logFile
> ```

### Paramètres avancés

```powershell
# -Force : crée le chemin complet si nécessaire
Add-Content -Path "C:\Logs\2024\app.log" -Value "Log" -Force

# -NoNewline : n'ajoute pas de saut de ligne (PowerShell 5.0+)
Add-Content "file.txt" -Value "Texte" -NoNewline
Add-Content "file.txt" -Value " suite" -NoNewline

# -Stream : utiliser des flux de données alternatifs (NTFS)
Add-Content "file.txt" -Value "Métadonnées" -Stream "Info"

# -PassThru : retourne le contenu ajouté
$ajout = Add-Content "file.txt" -Value "Test" -PassThru
```

### Cas d'usage pratiques

#### Agrégation de fichiers

```powershell
# Combiner plusieurs fichiers en un seul
Get-ChildItem "C:\Reports\*.txt" | ForEach-Object {
    Get-Content $_.FullName | Add-Content "rapport-complet.txt"
    # Ajouter un séparateur
    "`n--- Fin de $($_.Name) ---`n" | Add-Content "rapport-complet.txt"
}
```

#### Export de résultats avec horodatage

```powershell
# Ajouter un rapport journalier
$rapport = @"

=== Rapport du $(Get-Date -Format 'dd/MM/yyyy à HH:mm') ===
Serveurs actifs : $(Get-Service | Where-Object Status -eq 'Running' | Measure-Object | Select-Object -ExpandProperty Count)
Espace disque C: : $((Get-PSDrive C).Free / 1GB -as [int]) GB libres
"@
Add-Content "rapport-quotidien.txt" -Value $rapport
```

#### CSV incrémental

```powershell
# Ajouter des données à un CSV existant (sans ré-écrire l'en-tête)
$nouveauUtilisateur = [PSCustomObject]@{
    Nom = "Dupont"
    Prenom = "Jean"
    Service = "IT"
}

# Première fois : créer le fichier avec en-tête
if (-not (Test-Path "users.csv")) {
    $nouveauUtilisateur | Export-Csv "users.csv" -NoTypeInformation
} else {
    # Ajouter sans en-tête
    $nouveauUtilisateur | ConvertTo-Csv -NoTypeInformation | 
        Select-Object -Skip 1 | Add-Content "users.csv"
}
```

### Comparaison avec autres cmdlets

|Cmdlet|Comportement|
|---|---|
|`Set-Content`|**Écrase** le fichier|
|`Add-Content`|**Ajoute** à la fin|
|`Out-File`|Écrase par défaut, `-Append` pour ajouter|
|`>`|Écrase le fichier|
|`>>`|Ajoute à la fin (équivalent à `Add-Content`)|

```powershell
# Ces commandes sont équivalentes :
Add-Content "file.txt" -Value "Texte"
"Texte" >> file.txt
Out-File -FilePath "file.txt" -InputObject "Texte" -Append
```

> [!warning] Performance Pour ajouter beaucoup de lignes, il est plus performant de construire un tableau puis de faire un seul `Add-Content` plutôt que plusieurs appels successifs.
> 
> ```powershell
> # Lent (500 appels)
> 1..500 | ForEach-Object { Add-Content "file.txt" -Value "Ligne $_" }
> 
> # Rapide (1 seul appel)
> $lignes = 1..500 | ForEach-Object { "Ligne $_" }
> Add-Content "file.txt" -Value $lignes
> ```

> [!tip] Rotation de logs Pour éviter des fichiers de log trop volumineux, créez un nouveau fichier par jour (comme dans l'exemple ci-dessus) ou implémentez une rotation.


---

## Clear-Content - Vider un fichier

`Clear-Content` (alias : `clc`) vide le contenu d'un fichier **sans le supprimer**. Le fichier reste avec une taille de 0 octet.

```powershell
# Vider un fichier de log
Clear-Content -Path "app.log"

# Vider plusieurs fichiers
Clear-Content "log1.txt", "log2.txt", "log3.txt"

# Avec wildcards
Clear-Content "C:\Temp\*.tmp"

# Forcer pour les fichiers read-only
Clear-Content "protected.txt" -Force
```

> [!info] Différence avec Remove-Item
> 
> - `Clear-Content` : Vide le fichier (0 octet) mais le **conserve**
> - `Remove-Item` : **Supprime** complètement le fichier

> [!example] Cas d'usage
> 
> ```powershell
> # Réinitialiser un fichier de log au début de chaque jour
> $logFile = "C:\Logs\daily.log"
> 
> # Le matin, vider le log de la veille
> if ((Get-Date).Hour -eq 0) {
>     Clear-Content $logFile
>     "Nouveau jour - Log réinitialisé" | Add-Content $logFile
> }
> ```

---

## Comparaison des cmdlets

|Cmdlet|Action|Écrase ?|Crée si inexistant ?|Cas d'usage principal|
|---|---|---|---|---|
|`Get-Content`|Lecture|N/A|N/A|Lire et traiter des fichiers texte|
|`Set-Content`|Écriture|✅ Oui|✅ Oui|Créer ou remplacer complètement un fichier|
|`Add-Content`|Ajout|❌ Non|✅ Oui|Ajouter à un fichier existant (logs)|
|`Clear-Content`|Vider|✅ Oui|❌ Non|Réinitialiser un fichier sans le supprimer|

> [!tip] Choisir la bonne cmdlet
> 
> - **Lecture** : `Get-Content`
> - **Création ou remplacement complet** : `Set-Content`
> - **Ajout incrémental** : `Add-Content`
> - **Réinitialisation** : `Clear-Content`

---

## Gestion des encodages

Les encodages déterminent comment les caractères sont convertis en octets. Voici les principaux encodages et quand les utiliser.

### Encodages disponibles

|Encodage|Description|Quand l'utiliser|
|---|---|---|
|**UTF8**|Universel, compatible ASCII|**Par défaut recommandé**, interopérabilité maximale|
|**UTF8BOM**|UTF8 avec BOM (Byte Order Mark)|Windows apps anciennes qui nécessitent BOM|
|**UTF8NoBOM**|UTF8 sans BOM|Linux, macOS, apps modernes|
|**ASCII**|7 bits, caractères basiques uniquement|Fichiers simples sans accents, compatibilité maximale|
|**Unicode**|UTF16-LE (Little Endian)|Applications Windows qui nécessitent UTF16|
|**BigEndianUnicode**|UTF16-BE (Big Endian)|Systèmes Unix, réseaux|
|**UTF32**|4 octets par caractère|Rarement utilisé, texte avec emojis complexes|
|**Default**|Encodage système Windows|Applications Windows anciennes|
|**OEM**|Page de code DOS|Vieux fichiers DOS ou console|

### Exemples pratiques

```powershell
# Fichier avec caractères internationaux
$texte = "Français: éèêë, Español: ñáéíóú, Deutsch: äöüß"
Set-Content "international.txt" -Value $texte -Encoding UTF8

# Lire un vieux fichier DOS
Get-Content "old-msdos.txt" -Encoding OEM

# Fichier pour application Windows legacy
Set-Content "windows-app.config" -Value $config -Encoding Unicode

# Export pour Linux/macOS
Set-Content "unix-config.conf" -Value $settings -Encoding UTF8
```

> [!warning] Problèmes courants **Caractères bizarres (�, ?, carrés)** : Mauvais encodage
> 
> - Solution : Essayez UTF8, Unicode, ou OEM
> 
> **BOM indésirable** : Certains parsers (JSON, Linux) n'aiment pas le BOM
> 
> - Solution : Utilisez UTF8 (sans BOM) sur PowerShell 7+ ou UTF8NoBOM

### Détecter l'encodage d'un fichier

```powershell
# PowerShell ne détecte pas automatiquement l'encodage
# Vérification manuelle via BOM (Byte Order Mark)
$bytes = Get-Content "file.txt" -Encoding Byte -TotalCount 4

if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    Write-Host "UTF8 avec BOM"
}
elseif ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
    Write-Host "UTF16-LE (Unicode)"
}
elseif ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
    Write-Host "UTF16-BE (BigEndianUnicode)"
}
else {
    Write-Host "Probablement UTF8 sans BOM, ASCII, ou autre"
}
```

---

## Pièges courants et bonnes pratiques

### ❌ Piège 1 : Confondre Set-Content et Add-Content

```powershell
# MAUVAIS : Écrase tout le log à chaque fois
Get-Date | Set-Content "app.log"
# Le log ne contient que la dernière date

# BON : Ajoute au log
Get-Date | Add-Content "app.log"
# Le log accumule toutes les dates
```

### ❌ Piège 2 : Oublier l'encodage

```powershell
# MAUVAIS : Encodage par défaut (peut varier)
Set-Content "data.txt" -Value "Données avec accents"

# BON : Spécifier explicitement
Set-Content "data.txt" -Value "Données avec accents" -Encoding UTF8
```

> [!tip] Bonne pratique **Toujours spécifier `-Encoding UTF8`** pour une compatibilité maximale entre Windows, Linux et macOS.

### ❌ Piège 3 : Lire de gros fichiers en mémoire

```powershell
# MAUVAIS : Charge tout en mémoire (peut planter si 10 Go)
$allLines = Get-Content "huge.log"
foreach ($line in $allLines) {
    Process-Line $line
}

# BON : Traitement ligne par ligne via pipeline
Get-Content "huge.log" | ForEach-Object {
    Process-Line $_
}

# ENCORE MIEUX : Par blocs
Get-Content "huge.log" -ReadCount 1000 | ForEach-Object {
    foreach ($line in $_) {
        Process-Line $line
    }
}
```

### ❌ Piège 4 : Utiliser -Raw pour traiter ligne par ligne

```powershell
# MAUVAIS : -Raw charge tout en une chaîne
$content = Get-Content "file.txt" -Raw
$lines = $content -split "`n"  # Doit re-splitter manuellement

# BON : Lecture ligne par ligne par défaut
$lines = Get-Content "file.txt"
# $lines est déjà un tableau
```

### ✅ Bonne pratique : Gestion d'erreurs

```powershell
# Toujours gérer les erreurs de fichier
try {
    $content = Get-Content "config.json" -ErrorAction Stop
    $config = $content | ConvertFrom-Json
}
catch [System.IO.FileNotFoundException] {
    Write-Error "Fichier de configuration introuvable"
}
catch {
    Write-Error "Erreur de lecture : $($_.Exception.Message)"
}
```

### ✅ Bonne pratique : Vérifier l'existence

```powershell
# Vérifier avant de lire
if (Test-Path "data.txt") {
    $data = Get-Content "data.txt"
    # Traiter $data
}
else {
    Write-Warning "Fichier data.txt introuvable"
}
```

### ✅ Bonne pratique : Utiliser des chemins absolus

```powershell
# ÉVITER : Chemins relatifs (dépend du répertoire courant)
Get-Content "config.txt"

# PRÉFÉRER : Chemins absolus
Get-Content "C:\MyApp\config.txt"

# OU : Relatif au script
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Get-Content (Join-Path $scriptPath "config.txt")
```

### ✅ Bonne pratique : Nettoyage de logs

```powershell
# Fonction pour limiter la taille d'un log
function Limit-LogSize {
    param(
        [string]$LogPath,
        [int]$MaxLines = 1000
    )
    
    $lines = Get-Content $LogPath
    if ($lines.Count -gt $MaxLines) {
        # Garder seulement les N dernières lignes
        $lines | Select-Object -Last $MaxLines | Set-Content $LogPath
        Write-Host "Log tronqué à $MaxLines lignes"
    }
}

# Utilisation
Limit-LogSize -LogPath "app.log" -MaxLines 5000
```

---

> [!tip] 💡 Points clés à retenir
> 
> 1. **`Get-Content`** pour lire, `-Tail`/`-TotalCount` pour limiter, `-Wait` pour surveiller
> 2. **`Set-Content`** écrase, **`Add-Content`** ajoute, **`Clear-Content`** vide
> 3. **Toujours spécifier `-Encoding UTF8`** pour la portabilité
> 4. **Traiter les gros fichiers ligne par ligne** via pipeline, pas en mémoire
> 5. **`-Raw`** pour JSON/XML, lecture normale pour traitement ligne par ligne
> 6. **Gérer les erreurs** avec `try/catch` et vérifier l'existence avec `Test-Path`