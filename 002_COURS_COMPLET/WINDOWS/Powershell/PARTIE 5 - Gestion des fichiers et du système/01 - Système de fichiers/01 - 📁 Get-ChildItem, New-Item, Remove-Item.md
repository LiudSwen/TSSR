

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

## 🎯 Introduction

Les cmdlets **Get-ChildItem**, **New-Item** et **Remove-Item** constituent la triade fondamentale pour la gestion du système de fichiers en PowerShell. Ces commandes remplacent avantageusement les commandes traditionnelles de l'invite de commandes (dir, mkdir, del) en offrant une puissance et une flexibilité supérieures.

> [!info] Pourquoi ces cmdlets sont essentielles
> 
> - **Get-ChildItem** : Exploration et listage avec filtrage avancé
> - **New-Item** : Création d'éléments avec gestion fine
> - **Remove-Item** : Suppression sécurisée et contrôlée

---

## 🔍 Get-ChildItem - Lister et Explorer

### Concept et utilité

`Get-ChildItem` (alias : `gci`, `ls`, `dir`) est la cmdlet de référence pour explorer le système de fichiers. Elle retourne des objets représentant les fichiers et dossiers, permettant ainsi une manipulation avancée via le pipeline PowerShell.

> [!tip] Quand utiliser Get-ChildItem ?
> 
> - Lister le contenu d'un répertoire
> - Rechercher des fichiers selon des critères spécifiques
> - Analyser l'arborescence complète d'un dossier
> - Récupérer des métadonnées (taille, date, attributs)

### Syntaxe de base

```powershell
# Syntaxe simple
Get-ChildItem [-Path] <String[]>

# Syntaxe complète
Get-ChildItem [-Path] <String[]> [-Filter <String>] [-Include <String[]>] 
              [-Exclude <String[]>] [-Recurse] [-Depth <Int32>] 
              [-Force] [-Name] [-Attributes <FileAttributes>]
```

### Paramètre -Path et -LiteralPath

Le paramètre `-Path` accepte les caractères génériques (wildcards), tandis que `-LiteralPath` traite le chemin littéralement.

```powershell
# Avec -Path (par défaut) - accepte les wildcards
Get-ChildItem -Path "C:\Users\*\Documents"
Get-ChildItem "C:\Temp\*.txt"  # -Path est positionnel

# Avec -LiteralPath - pas d'interprétation des caractères spéciaux
Get-ChildItem -LiteralPath "C:\Temp\[Test].txt"  # Cherche exactement [Test].txt
```

> [!warning] Piège courant Si votre chemin contient des crochets `[]` ou autres caractères wildcards dans le nom, utilisez `-LiteralPath` pour éviter une interprétation non désirée.

### Filtres : -Filter, -Include, -Exclude

Ces paramètres permettent de cibler précisément les éléments recherchés.

```powershell
# -Filter : Le plus rapide, appliqué au niveau du fournisseur
Get-ChildItem -Path "C:\Logs" -Filter "*.log"

# -Include : Filtrage côté PowerShell (plus lent mais plus flexible)
Get-ChildItem -Path "C:\Scripts" -Include "*.ps1", "*.psm1"

# -Exclude : Exclure des éléments
Get-ChildItem -Path "C:\Data" -Exclude "temp*", "*.bak"

# Combinaison Include/Exclude
Get-ChildItem -Path "C:\Code" -Include "*.cs" -Exclude "*Test.cs"
```

> [!tip] Astuce performance Privilégiez `-Filter` pour de meilleurs performances sur de grandes arborescences. `-Include` et `-Exclude` sont plus flexibles mais plus lents car le filtrage s'effectue après la récupération.

**Tableau comparatif des filtres :**

|Paramètre|Performance|Wildcards multiples|Appliqué par|
|---|---|---|---|
|`-Filter`|⚡ Rapide|❌ Non|Fournisseur système|
|`-Include`|🐌 Lent|✅ Oui|PowerShell|
|`-Exclude`|🐌 Lent|✅ Oui|PowerShell|

### Récursivité avec -Recurse

Le paramètre `-Recurse` explore tous les sous-dossiers de manière récursive.

```powershell
# Lister tous les fichiers .txt dans l'arborescence complète
Get-ChildItem -Path "C:\Projects" -Filter "*.txt" -Recurse

# Trouver tous les fichiers de configuration
Get-ChildItem -Path "C:\Program Files" -Include "*.config", "*.ini" -Recurse

# Compter le nombre total de fichiers
(Get-ChildItem -Path "C:\Data" -File -Recurse).Count
```

> [!warning] Attention aux performances `-Recurse` peut être très lent sur de grandes arborescences (millions de fichiers). Testez d'abord sur un sous-ensemble ou utilisez `-Depth` pour limiter la profondeur.

### Contrôler la profondeur avec -Depth

Le paramètre `-Depth` limite le nombre de niveaux de sous-dossiers explorés.

```powershell
# Explorer uniquement le dossier courant (Depth 0)
Get-ChildItem -Path "C:\Projects" -Depth 0

# Explorer jusqu'à 2 niveaux de profondeur
Get-ChildItem -Path "C:\Projects" -Recurse -Depth 2

# Comparaison visuelle
Get-ChildItem "C:\Data" -Recurse -Depth 1  # Data\SubFolder1
Get-ChildItem "C:\Data" -Recurse -Depth 2  # Data\SubFolder1\SubFolder2
```

> [!example] Cas d'usage pratique Idéal pour explorer la structure d'un projet sans descendre dans les dossiers de dépendances (node_modules, vendor, etc.).

### Afficher les fichiers cachés avec -Force

Par défaut, `Get-ChildItem` masque les fichiers et dossiers cachés ou système. `-Force` les rend visibles.

```powershell
# Sans -Force : fichiers visibles uniquement
Get-ChildItem -Path "C:\Users\Username"

# Avec -Force : fichiers cachés et système inclus
Get-ChildItem -Path "C:\Users\Username" -Force

# Lister uniquement les fichiers cachés
Get-ChildItem -Path "C:\Users\Username" -Force -Attributes Hidden
```

> [!info] Attributs spéciaux Les fichiers avec les attributs Hidden ou System sont masqués par défaut. `-Force` les révèle tous.

### Propriétés des objets retournés

`Get-ChildItem` retourne des objets `FileInfo` (fichiers) et `DirectoryInfo` (dossiers) riches en propriétés.

```powershell
# Afficher toutes les propriétés d'un fichier
Get-ChildItem "C:\Temp\test.txt" | Get-Member

# Propriétés courantes
$file = Get-ChildItem "C:\Temp\test.txt"
$file.Name           # Nom du fichier
$file.FullName       # Chemin complet
$file.Extension      # Extension (.txt)
$file.Length         # Taille en octets
$file.LastWriteTime  # Date de dernière modification
$file.Attributes     # Attributs (ReadOnly, Hidden, etc.)
$file.Directory      # Dossier parent
$file.CreationTime   # Date de création

# Utilisation pratique : trier par taille
Get-ChildItem "C:\Logs" | Sort-Object Length -Descending | Select-Object Name, Length

# Afficher les fichiers modifiés dans les 7 derniers jours
Get-ChildItem "C:\Data" -Recurse | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }
```

**Principales propriétés :**

|Propriété|Type|Description|
|---|---|---|
|`Name`|String|Nom du fichier/dossier|
|`FullName`|String|Chemin complet absolu|
|`Extension`|String|Extension du fichier|
|`Length`|Int64|Taille en octets (fichiers uniquement)|
|`LastWriteTime`|DateTime|Date dernière modification|
|`CreationTime`|DateTime|Date de création|
|`Attributes`|FileAttributes|Attributs du fichier|
|`Directory`|DirectoryInfo|Dossier parent|
|`PSIsContainer`|Boolean|True si c'est un dossier|

### Les alias : ls, dir, gci

PowerShell offre plusieurs alias pour faciliter la transition depuis d'autres shells.

```powershell
# Ces trois commandes sont équivalentes
Get-ChildItem C:\Temp
gci C:\Temp
ls C:\Temp
dir C:\Temp

# Vérifier les alias disponibles
Get-Alias -Definition Get-ChildItem
```

> [!tip] Bonne pratique Dans les scripts, privilégiez le nom complet `Get-ChildItem` pour la lisibilité. Les alias sont parfaits en ligne de commande interactive.

### Exemples avancés

```powershell
# Trouver les 10 plus gros fichiers
Get-ChildItem "C:\Data" -File -Recurse | 
    Sort-Object Length -Descending | 
    Select-Object -First 10 Name, @{N='SizeMB';E={[math]::Round($_.Length/1MB,2)}}

# Lister les dossiers vides
Get-ChildItem "C:\Projects" -Directory -Recurse | 
    Where-Object { (Get-ChildItem $_.FullName).Count -eq 0 }

# Fichiers par extension avec comptage
Get-ChildItem "C:\Code" -File -Recurse | 
    Group-Object Extension | 
    Sort-Object Count -Descending | 
    Select-Object Name, Count

# Fichiers non modifiés depuis plus d'un an
Get-ChildItem "C:\Archives" -File -Recurse | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddYears(-1) }
```

> [!warning] Pièges courants
> 
> - **Oublier `-File` ou `-Directory`** : Sans précision, Get-ChildItem retourne les deux types
> - **Utiliser Include sans Recurse** : `-Include` nécessite souvent `-Recurse` ou un wildcard dans `-Path`
> - **Performance sur réseau** : `-Recurse` sur des partages réseau peut être extrêmement lent

---

## ✨ New-Item - Créer des Éléments

### Concept et utilité

`New-Item` permet de créer différents types d'éléments : fichiers, dossiers, liens symboliques, jonctions, et même des éléments dans les providers PowerShell (registre, certificats, etc.).

> [!info] Pourquoi utiliser New-Item ?
> 
> - Création scriptée et automatisée
> - Gestion fine des attributs dès la création
> - Support de multiples types d'éléments
> - Création de chemins complets en une seule commande

### Syntaxe de base

```powershell
# Syntaxe simple
New-Item [-Path] <String[]> [-ItemType <String>]

# Syntaxe complète
New-Item [-Path] <String[]> [-ItemType <String>] [-Value <Object>] 
         [-Force] [-Credential <PSCredential>]
```

### Création de fichiers avec -ItemType File

```powershell
# Créer un fichier vide
New-Item -Path "C:\Temp\test.txt" -ItemType File

# Avec contenu initial via -Value
New-Item -Path "C:\Temp\config.txt" -ItemType File -Value "Configuration initiale"

# Créer plusieurs fichiers d'un coup
New-Item -Path "C:\Logs\log1.txt", "C:\Logs\log2.txt", "C:\Logs\log3.txt" -ItemType File

# Utilisation du pipeline
1..5 | ForEach-Object { New-Item -Path "C:\Data\file$_.txt" -ItemType File }
```

> [!warning] Fichier existant Par défaut, `New-Item` génère une erreur si le fichier existe déjà. Utilisez `-Force` pour écraser ou capturez l'erreur avec `-ErrorAction SilentlyContinue`.

### Création de dossiers avec -ItemType Directory

```powershell
# Créer un dossier simple
New-Item -Path "C:\Projects\MonProjet" -ItemType Directory

# Créer plusieurs dossiers
New-Item -Path "C:\Dev\Frontend", "C:\Dev\Backend", "C:\Dev\Database" -ItemType Directory

# Structure de projet complète
$base = "C:\Projects\WebApp"
"src", "tests", "docs", "config" | ForEach-Object {
    New-Item -Path "$base\$_" -ItemType Directory
}
```

> [!tip] Alias pratique `mkdir` est un alias de `New-Item -ItemType Directory` pour les habitués de Linux/Unix.

```powershell
# Ces deux commandes sont équivalentes
New-Item -Path "C:\Temp\Dossier" -ItemType Directory
mkdir "C:\Temp\Dossier"
```

### Paramètre -Force pour créer le chemin complet

`-Force` crée automatiquement tous les dossiers parents manquants dans le chemin.

```powershell
# Sans -Force : erreur si C:\Projects n'existe pas
New-Item -Path "C:\Projects\SubFolder\DeepFolder\file.txt" -ItemType File

# Avec -Force : crée toute l'arborescence automatiquement
New-Item -Path "C:\Projects\SubFolder\DeepFolder\file.txt" -ItemType File -Force

# Création d'une structure complexe en une commande
New-Item -Path "C:\App\Config\Dev\Logs\Archive\2024" -ItemType Directory -Force
```

> [!example] Cas d'usage Très utile dans les scripts d'installation ou de déploiement où la structure de dossiers doit être garantie.

### Paramètre -Value pour le contenu initial

Le paramètre `-Value` permet d'initialiser le contenu d'un fichier lors de sa création.

```powershell
# Créer un fichier avec du contenu
New-Item -Path "C:\Temp\readme.txt" -ItemType File -Value "Ceci est un fichier de test"

# Contenu multiligne avec here-string
$contenu = @"
Configuration Application
Version: 1.0
Date: $(Get-Date)
"@
New-Item -Path "C:\Config\app.conf" -ItemType File -Value $contenu -Force

# Créer un script PowerShell avec du code
$script = @"
# Script généré automatiquement
Write-Host "Hello from generated script"
Get-Date
"@
New-Item -Path "C:\Scripts\auto.ps1" -ItemType File -Value $script -Force
```

> [!info] Encodage du fichier Par défaut, PowerShell utilise UTF-8 avec BOM. Pour un contrôle précis de l'encodage, utilisez plutôt `Set-Content` ou `Out-File` après la création.

### Liens symboliques et jonctions

`New-Item` peut créer des liens symboliques (symlinks) et des jonctions de dossiers.

```powershell
# Créer un lien symbolique vers un fichier
New-Item -Path "C:\Shortcuts\config.lnk" -ItemType SymbolicLink -Value "C:\App\config.xml"

# Créer un lien symbolique vers un dossier
New-Item -Path "C:\Dev\CurrentProject" -ItemType SymbolicLink -Value "C:\Projects\WebApp2024"

# Créer une jonction (junction) - spécifique Windows
New-Item -Path "C:\Data\Archive" -ItemType Junction -Value "D:\OldData\Archives"
```

**Différences entre types de liens :**

|Type|Cible|Système de fichiers|Réseau|Permissions|
|---|---|---|---|---|
|SymbolicLink|Fichier ou dossier|NTFS requis|❌ Non|Requiert droits admin|
|Junction|Dossier uniquement|NTFS requis|❌ Non|Pas besoin admin|
|HardLink|Fichier uniquement|Même volume|❌ Non|Pas besoin admin|

```powershell
# Vérifier qu'un élément est un lien
$item = Get-Item "C:\Dev\CurrentProject"
$item.LinkType  # Retourne SymbolicLink, Junction, HardLink ou $null
$item.Target    # Affiche la cible du lien
```

> [!warning] Permissions nécessaires La création de liens symboliques nécessite des privilèges administrateur sur Windows (sauf si le mode développeur est activé). Les jonctions n'ont pas cette restriction.

### Exemples pratiques

```powershell
# Créer une structure de projet complète
$projectRoot = "C:\Projects\MonApp"
$folders = @(
    "src\controllers",
    "src\models",
    "src\views",
    "tests\unit",
    "tests\integration",
    "docs",
    "config"
)
$folders | ForEach-Object {
    New-Item -Path "$projectRoot\$_" -ItemType Directory -Force
}

# Créer des fichiers de configuration par défaut
$configs = @{
    "config\app.json" = '{"name":"MonApp","version":"1.0.0"}'
    "config\database.json" = '{"host":"localhost","port":5432}'
    ".gitignore" = "node_modules/`n*.log`n.env"
}
$configs.GetEnumerator() | ForEach-Object {
    New-Item -Path "$projectRoot\$($_.Key)" -ItemType File -Value $_.Value -Force
}

# Créer des fichiers de log datés
$logPath = "C:\Logs\$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -Path $logPath -ItemType Directory -Force
New-Item -Path "$logPath\application.log" -ItemType File -Value "Log started at $(Get-Date)`n"
```

> [!tip] Bonne pratique Utilisez toujours `-Force` dans les scripts automatisés pour garantir que la structure existe, même si certains éléments sont déjà créés.

---

## 🗑️ Remove-Item - Supprimer des Éléments

### Concept et utilité

`Remove-Item` (alias : `rm`, `del`, `erase`, `rd`, `rmdir`) supprime des fichiers, dossiers et autres éléments du système de fichiers ou des providers PowerShell.

> [!warning] Attention danger ! `Remove-Item` est destructif et **irréversible** (pas de corbeille par défaut). Toujours vérifier avec `-WhatIf` avant d'exécuter sur des données importantes.

### Syntaxe de base

```powershell
# Syntaxe simple
Remove-Item [-Path] <String[]>

# Syntaxe complète
Remove-Item [-Path] <String[]> [-Filter <String>] [-Include <String[]>] 
            [-Exclude <String[]>] [-Recurse] [-Force] [-Confirm] [-WhatIf]
```

### Suppression de fichiers

```powershell
# Supprimer un fichier simple
Remove-Item -Path "C:\Temp\test.txt"

# Supprimer plusieurs fichiers
Remove-Item -Path "C:\Logs\log1.txt", "C:\Logs\log2.txt"

# Supprimer tous les fichiers .log
Remove-Item -Path "C:\Logs\*.log"

# Supprimer avec filtre
Remove-Item -Path "C:\Temp\*" -Include "*.tmp", "*.bak"
```

### Suppression de dossiers avec -Recurse

Pour supprimer un dossier non vide, le paramètre `-Recurse` est **obligatoire**.

```powershell
# Erreur : dossier non vide sans -Recurse
Remove-Item -Path "C:\OldProject"  # ❌ Génère une erreur

# Correct : suppression récursive
Remove-Item -Path "C:\OldProject" -Recurse

# Supprimer plusieurs dossiers et leur contenu
Remove-Item -Path "C:\Temp\Folder1", "C:\Temp\Folder2" -Recurse

# Supprimer tous les sous-dossiers nommés "bin" ou "obj"
Get-ChildItem -Path "C:\Projects" -Directory -Recurse -Include "bin", "obj" | 
    Remove-Item -Recurse -Force
```

> [!warning] Danger : -Recurse `-Recurse` supprime **tout** le contenu du dossier sans confirmation. Utilisez toujours `-WhatIf` ou `-Confirm` pour vérifier avant.

### Paramètre -Force pour les attributs read-only

`-Force` permet de supprimer des fichiers en lecture seule ou avec des attributs système/cachés.

```powershell
# Sans -Force : erreur si le fichier est en lecture seule
Remove-Item -Path "C:\Protected\readonly.txt"  # ❌ Erreur

# Avec -Force : supprime même les fichiers protégés
Remove-Item -Path "C:\Protected\readonly.txt" -Force

# Supprimer un dossier système caché
Remove-Item -Path "C:\HiddenFolder" -Recurse -Force

# Forcer la suppression de fichiers verrouillés (attention !)
Get-ChildItem "C:\Temp" -File | Remove-Item -Force -ErrorAction SilentlyContinue
```

> [!info] Fichiers verrouillés `-Force` ne peut pas supprimer un fichier actuellement ouvert par un processus. Utilisez des outils comme Handle.exe de Sysinternals pour identifier et libérer les handles.

### Paramètre -Confirm pour confirmation interactive

`-Confirm` demande une confirmation avant chaque suppression.

```powershell
# Confirmation pour chaque élément
Remove-Item -Path "C:\Data\*" -Recurse -Confirm

# PowerShell demande : "Êtes-vous sûr de vouloir effectuer cette action ?"
# Options : [O] Oui  [T] Oui pour Tout  [N] Non  [P] Non pour Tout  [S] Suspendre
```

> [!tip] Sécurité recommandée Ajoutez `-Confirm` lors de suppressions massives ou sur des données sensibles. Vous pouvez répondre "Oui pour Tout" pour accélérer après vérification du premier élément.

### Paramètre -WhatIf pour simulation

`-WhatIf` simule l'exécution sans rien supprimer réellement. **Indispensable** pour tester vos commandes.

```powershell
# Simuler la suppression
Remove-Item -Path "C:\OldData" -Recurse -WhatIf

# Output : "Que se passerait-il si : Performing the operation "Remove Directory" 
# on target "C:\OldData"."

# Tester une suppression complexe
Get-ChildItem "C:\Logs" -File -Recurse | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | 
    Remove-Item -WhatIf

# Comparer ce qui serait supprimé
$toDelete = Get-ChildItem "C:\Archives" -Recurse | Where-Object { $_.Length -eq 0 }
$toDelete | Remove-Item -WhatIf  # Vérifier d'abord
# $toDelete | Remove-Item -Force  # Exécuter ensuite si OK
```

> [!example] Workflow de sécurité
> 
> 1. Écrire la commande avec `-WhatIf`
> 2. Vérifier la liste des éléments à supprimer
> 3. Remplacer `-WhatIf` par `-Force` ou `-Confirm` une fois validé

### Suppression sécurisée : bonnes pratiques

```powershell
# ❌ DANGER : Suppression brutale
Remove-Item -Path "C:\Data\*" -Recurse -Force

# ✅ SÉCURISÉ : Vérification puis suppression
# Étape 1 : Lister ce qui sera supprimé
$items = Get-ChildItem "C:\Data" -Recurse
$items | Select-Object FullName, Length, LastWriteTime | Out-GridView

# Étape 2 : Simulation
$items | Remove-Item -WhatIf

# Étape 3 : Suppression avec confirmation
$items | Remove-Item -Confirm

# Alternative : Sauvegarder la liste avant suppression
Get-ChildItem "C:\ToDelete" -Recurse | 
    Select-Object FullName, Length | 
    Export-Csv "C:\Logs\deleted_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
Remove-Item "C:\ToDelete" -Recurse -Force
```

### Gestion des erreurs

```powershell
# Continuer même en cas d'erreur (fichier verrouillé, permissions, etc.)
Remove-Item -Path "C:\Logs\*" -Recurse -Force -ErrorAction SilentlyContinue

# Capturer les erreurs dans une variable
Remove-Item -Path "C:\Files\*" -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable errors
if ($errors) {
    Write-Host "Erreurs rencontrées : $($errors.Count)"
    $errors | ForEach-Object { Write-Warning $_.Exception.Message }
}

# Try-Catch pour gestion personnalisée
try {
    Remove-Item -Path "C:\Critical\Data" -Recurse -Force -ErrorAction Stop
    Write-Host "Suppression réussie"
} catch {
    Write-Error "Échec de la suppression : $_"
    # Logique de récupération ou notification
}
```

### Exemples pratiques avancés

```powershell
# Supprimer les fichiers temporaires de plus de 7 jours
Get-ChildItem -Path $env:TEMP -File -Recurse -ErrorAction SilentlyContinue | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | 
    Remove-Item -Force -ErrorAction SilentlyContinue

# Nettoyer les dossiers bin/obj dans tous les projets
Get-ChildItem -Path "C:\Projects" -Directory -Recurse -Include "bin", "obj" | 
    Remove-Item -Recurse -Force -WhatIf  # Retirer -WhatIf après vérification

# Supprimer les fichiers vides
Get-ChildItem -Path "C:\Data" -File -Recurse | 
    Where-Object { $_.Length -eq 0 } | 
    Remove-Item -WhatIf

# Supprimer les doublons (par hash)
Get-ChildItem "C:\Downloads" -File | 
    Group-Object { (Get-FileHash $_.FullName).Hash } | 
    Where-Object { $_.Count -gt 1 } | 
    ForEach-Object { $_.Group | Select-Object -Skip 1 | Remove-Item -WhatIf }

# Libérer de l'espace : supprimer les plus gros fichiers anciens
Get-ChildItem "C:\Archives" -File -Recurse | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddMonths(-6) } | 
    Sort-Object Length -Descending | 
    Select-Object -First 20 | 
    Remove-Item -Confirm
```

> [!warning] Pièges courants
> 
> - **Oublier `-Recurse`** : Impossible de supprimer un dossier non vide
> - **Oublier `-Force`** : Échec sur les fichiers en lecture seule
> - **Ne pas tester avec `-WhatIf`** : Risque de suppression accidentelle de données critiques
> - **Utiliser des wildcards sans filtrage** : `Remove-Item C:\*` supprime TOUT !

### Sécurité : ne jamais supprimer sans vérification

```powershell
# ❌ NE JAMAIS FAIRE CECI
Remove-Item -Path "C:\*" -Recurse -Force  # Catastrophe !

# ✅ TOUJOURS FAIRE CECI
# 1. Analyser d'abord
Get-ChildItem -Path "C:\ToClean"

# 2. Simuler
Remove-Item -Path "C:\ToClean\*" -Recurse -WhatIf

# 3. Confirmer
Remove-Item -Path "C:\ToClean\*" -Recurse -Confirm

# 4. Ou forcer avec log
Remove-Item -Path "C:\ToClean\*" -Recurse -Force | 
    Tee-Object -FilePath "C:\Logs\deletion_$(Get-Date -Format 'yyyyMMdd').log"
```

---

## 🎓 Résumé des cmdlets

|Cmdlet|Usage principal|Paramètres clés|Danger|
|---|---|---|---|
|**Get-ChildItem**|Lister et explorer|`-Recurse`, `-Filter`, `-Force`|⚠️ Faible|
|**New-Item**|Créer fichiers/dossiers|`-ItemType`, `-Force`, `-Value`|⚠️ Faible|
|**Remove-Item**|Supprimer éléments|`-Recurse`, `-Force`, `-WhatIf`|🔴 Élevé|

> [!tip] Règle d'or
> 
> - **Get-ChildItem** : Explorez librement
> - **New-Item** : Créez avec `-Force` pour garantir la structure
> - **Remove-Item** : Toujours vérifier avec `-WhatIf` avant de supprimer

---