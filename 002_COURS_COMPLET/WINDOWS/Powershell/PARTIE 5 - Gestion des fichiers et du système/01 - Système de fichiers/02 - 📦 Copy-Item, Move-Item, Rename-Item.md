
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

## 🔄 Copy-Item - Copier des fichiers et dossiers {#copy-item}

### Pourquoi utiliser Copy-Item ?

`Copy-Item` permet de dupliquer des fichiers et dossiers de manière précise et contrôlée. Contrairement à une simple copie manuelle, cette cmdlet offre des options avancées pour le filtrage, la gestion des conflits et l'automatisation de tâches répétitives.

### Syntaxe de base

```powershell
Copy-Item -Path <source> -Destination <destination> [options]
```

### Copie simple de fichiers

```powershell
# Copier un fichier unique
Copy-Item -Path "C:\Documents\rapport.docx" -Destination "D:\Backup\"

# Copier avec un nouveau nom
Copy-Item -Path "C:\Documents\rapport.docx" -Destination "D:\Backup\rapport_backup.docx"

# Copier vers le répertoire courant
Copy-Item -Path "C:\Documents\rapport.docx" -Destination ".\"
```

> [!tip] **Astuce** Si vous omettez le nom du fichier dans `-Destination`, PowerShell conserve le nom d'origine.

### Copie de dossiers avec `-Recurse`

Pour copier un dossier et tout son contenu, le paramètre `-Recurse` est **indispensable**.

```powershell
# Copier un dossier complet (contenu + sous-dossiers)
Copy-Item -Path "C:\Projets\MonProjet" -Destination "D:\Backup\" -Recurse

# Sans -Recurse : seul le dossier vide est créé !
Copy-Item -Path "C:\Projets\MonProjet" -Destination "D:\Backup\"  # ⚠️ Dossier vide
```

> [!warning] **Piège courant** Sans `-Recurse`, seule la structure du dossier parent est copiée, mais pas son contenu. Cela crée un dossier vide à la destination.

### Le paramètre `-Destination` et les chemins

```powershell
# Destination = dossier existant → copie DANS ce dossier
Copy-Item -Path "C:\file.txt" -Destination "D:\Backup\"
# Résultat : D:\Backup\file.txt

# Destination = chemin complet avec nom → copie AVEC ce nom
Copy-Item -Path "C:\file.txt" -Destination "D:\Backup\newfile.txt"
# Résultat : D:\Backup\newfile.txt

# Destination = dossier inexistant → RENOMME le fichier/dossier
Copy-Item -Path "C:\Documents" -Destination "D:\Archives" -Recurse
# Résultat : D:\Archives\ (contient le contenu de Documents)
```

> [!info] **Comportement important** Si la destination n'existe pas, PowerShell considère que c'est le nouveau nom de l'élément copié, pas un dossier à créer.

### Écraser avec `-Force`

Par défaut, `Copy-Item` échoue si le fichier existe déjà à la destination.

```powershell
# Tentative de copie sur un fichier existant
Copy-Item -Path "C:\file.txt" -Destination "D:\file.txt"
# Erreur : "Le fichier existe déjà"

# Forcer l'écrasement
Copy-Item -Path "C:\file.txt" -Destination "D:\file.txt" -Force
# Succès : le fichier existant est remplacé
```

> [!warning] **Attention** `-Force` écrase sans demander confirmation. Utilisez-le avec prudence ou combinez-le avec `-WhatIf` pour tester.

### Filtrage avec `-Filter`, `-Include`, `-Exclude`

Ces paramètres permettent de sélectionner précisément quels fichiers copier.

#### `-Filter` (le plus performant)

```powershell
# Copier uniquement les fichiers .txt
Copy-Item -Path "C:\Documents\*" -Destination "D:\Backup\" -Filter "*.txt"

# Copier tous les fichiers commençant par "rapport"
Copy-Item -Path "C:\Documents\*" -Destination "D:\Backup\" -Filter "rapport*"
```

> [!tip] **Performance** `-Filter` est appliqué au niveau du provider (système de fichiers), ce qui le rend plus rapide que `-Include` ou `-Exclude`.

#### `-Include` (filtre après récupération)

```powershell
# Copier plusieurs types de fichiers
Copy-Item -Path "C:\Documents\*" -Destination "D:\Backup\" -Include "*.txt", "*.docx" -Recurse

# Attention : -Include nécessite un wildcard dans -Path !
Copy-Item -Path "C:\Documents\*" -Destination "D:\Backup\" -Include "*.pdf"  # ✅
Copy-Item -Path "C:\Documents" -Destination "D:\Backup\" -Include "*.pdf"    # ❌ Ne fonctionne pas
```

#### `-Exclude` (exclure des éléments)

```powershell
# Copier tout sauf les fichiers temporaires
Copy-Item -Path "C:\Documents\*" -Destination "D:\Backup\" -Exclude "*.tmp", "*.temp" -Recurse

# Exclure des dossiers spécifiques
Copy-Item -Path "C:\Projets\*" -Destination "D:\Backup\" -Exclude "node_modules", "bin" -Recurse
```

#### Tableau comparatif

|Paramètre|Application|Performance|Syntaxe wildcard requise|
|---|---|---|---|
|`-Filter`|Au niveau provider|⚡ Rapide|Oui dans `-Path`|
|`-Include`|Après récupération|🐢 Plus lent|Oui dans `-Path`|
|`-Exclude`|Après récupération|🐢 Plus lent|Oui dans `-Path`|

### Préservation des attributs

Par défaut, `Copy-Item` préserve les attributs de fichiers (lecture seule, caché, etc.) mais **pas** les dates de modification originales.

```powershell
# Copie standard (nouvelle date de création)
Copy-Item -Path "C:\file.txt" -Destination "D:\file.txt"

# Vérifier les attributs copiés
Get-Item "D:\file.txt" | Select-Object Name, Attributes, LastWriteTime

# Les attributs (ReadOnly, Hidden, etc.) sont préservés
# Mais la date de modification devient la date de copie
```

> [!info] **Limitation** Pour conserver les dates originales, vous devez les restaurer manuellement après la copie avec `Set-ItemProperty`.

### Exemples pratiques avancés

```powershell
# Backup d'un projet en excluant les fichiers inutiles
Copy-Item -Path "C:\Projets\MonApp\*" `
          -Destination "D:\Backup\MonApp\" `
          -Recurse `
          -Exclude "*.log", "*.tmp", "bin", "obj", "node_modules" `
          -Force

# Copier uniquement les fichiers modifiés aujourd'hui
Get-ChildItem -Path "C:\Documents" -Recurse | 
    Where-Object { $_.LastWriteTime.Date -eq (Get-Date).Date } | 
    Copy-Item -Destination "D:\Today\" -Force

# Copier avec confirmation pour chaque fichier
Copy-Item -Path "C:\Important\*" -Destination "D:\Backup\" -Recurse -Confirm

# Test de copie sans exécution réelle (simulation)
Copy-Item -Path "C:\Docs\*" -Destination "D:\Backup\" -Recurse -WhatIf
```

---

## 🚚 Move-Item - Déplacer des éléments {#move-item}

### Pourquoi utiliser Move-Item ?

`Move-Item` déplace des fichiers et dossiers d'un emplacement à un autre. C'est l'équivalent d'un "couper-coller" qui supprime l'élément de sa source après l'avoir placé à destination.

### Syntaxe de base

```powershell
Move-Item -Path <source> -Destination <destination> [options]
```

### Déplacement simple de fichiers

```powershell
# Déplacer un fichier
Move-Item -Path "C:\Documents\rapport.docx" -Destination "D:\Archives\"

# Déplacer avec un nouveau nom
Move-Item -Path "C:\Documents\rapport.docx" -Destination "D:\Archives\rapport_2024.docx"

# Déplacer vers le répertoire parent
Move-Item -Path "C:\Projets\Temp\file.txt" -Destination "..\file.txt"
```

### Déplacement de dossiers complets

Contrairement à `Copy-Item`, `Move-Item` **n'a pas besoin** de `-Recurse` car il déplace l'ensemble de l'élément.

```powershell
# Déplacer un dossier complet (avec tout son contenu)
Move-Item -Path "C:\Projets\OldProject" -Destination "D:\Archives\"

# Le dossier OldProject et tout son contenu sont déplacés
# Résultat : D:\Archives\OldProject\

# Déplacer et renommer simultanément
Move-Item -Path "C:\Projets\OldProject" -Destination "D:\Archives\Project_2023"
```

> [!info] **Différence avec Copy-Item** `Move-Item` n'utilise jamais `-Recurse` car il déplace toujours l'élément entier. Le paramètre serait superflu.

### Renommage implicite

`Move-Item` peut servir à renommer un fichier/dossier en le "déplaçant" dans le même répertoire.

```powershell
# Renommer un fichier (déplacement dans le même dossier)
Move-Item -Path "C:\Documents\ancien_nom.txt" -Destination "C:\Documents\nouveau_nom.txt"

# Renommer un dossier
Move-Item -Path "C:\Projets\ProjetV1" -Destination "C:\Projets\ProjetV2"
```

> [!tip] **Astuce** Bien que `Move-Item` puisse renommer, `Rename-Item` est plus explicite et recommandé pour cette tâche.

### Écraser avec `-Force`

Par défaut, `Move-Item` échoue si la destination existe déjà.

```powershell
# Tentative de déplacement vers un fichier existant
Move-Item -Path "C:\file.txt" -Destination "D:\file.txt"
# Erreur : "Le fichier existe déjà"

# Forcer le remplacement
Move-Item -Path "C:\file.txt" -Destination "D:\file.txt" -Force
# Le fichier existant à la destination est remplacé
```

> [!warning] **Comportement destructeur** Avec `-Force`, le fichier de destination est **supprimé définitivement** et remplacé. Il n'y a pas de corbeille.

### Différences avec Cut/Paste manuel

|Opération|Move-Item|Cut/Paste (explorateur)|
|---|---|---|
|Vitesse|Instantané si même volume|Instantané si même volume|
|Entre volumes|Copie puis supprime|Copie puis supprime|
|Gestion d'erreurs|Retourne erreurs PowerShell|Dialogue Windows|
|Automatisation|✅ Scriptable|❌ Manuel uniquement|
|Confirmation|`-Confirm` disponible|Dialogue selon config|

```powershell
# Move-Item entre deux volumes (C: vers D:)
Move-Item -Path "C:\file.txt" -Destination "D:\file.txt"
# En réalité : copie vers D:\ puis supprime C:\file.txt

# Sur le même volume (C: vers C:)
Move-Item -Path "C:\Folder1\file.txt" -Destination "C:\Folder2\file.txt"
# Vraiment instantané : simple mise à jour de la table des fichiers
```

### Exemples pratiques avancés

```powershell
# Déplacer tous les fichiers .log vers un dossier d'archives
Get-ChildItem -Path "C:\App\logs\*.log" | 
    Move-Item -Destination "D:\Archives\Logs\" -Force

# Déplacer les fichiers de plus d'1 an
Get-ChildItem -Path "C:\Documents" -Recurse | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddYears(-1) } | 
    Move-Item -Destination "D:\Old\" -Force

# Organiser des fichiers par extension
Get-ChildItem -Path "C:\Downloads" | 
    ForEach-Object {
        $ext = $_.Extension.TrimStart('.')
        $destFolder = "C:\Organized\$ext"
        if (!(Test-Path $destFolder)) { New-Item -Path $destFolder -ItemType Directory }
        Move-Item -Path $_.FullName -Destination $destFolder
    }

# Déplacer avec confirmation
Move-Item -Path "C:\Important\*" -Destination "D:\Backup\" -Confirm
```

---

## ✏️ Rename-Item - Renommer des éléments {#rename-item}

### Pourquoi utiliser Rename-Item ?

`Rename-Item` est spécialisé dans le renommage de fichiers et dossiers. Il est plus explicite et lisible que `Move-Item` pour cette tâche, et offre des fonctionnalités puissantes pour le renommage en masse.

### Syntaxe de base

```powershell
Rename-Item -Path <chemin> -NewName <nouveau_nom>
```

### Renommage simple

```powershell
# Renommer un fichier
Rename-Item -Path "C:\Documents\ancien.txt" -NewName "nouveau.txt"

# Renommer un dossier
Rename-Item -Path "C:\Projets\ProjetV1" -NewName "ProjetV2"

# Utiliser le paramètre positionnel (plus court)
Rename-Item "C:\file.txt" "newfile.txt"
```

> [!warning] **Piège courant** `-NewName` attend **uniquement le nom**, pas un chemin complet. Pour déplacer ET renommer, utilisez `Move-Item`.

```powershell
# ❌ Incorrect - tente de créer un chemin invalide
Rename-Item -Path "C:\file.txt" -NewName "D:\newfile.txt"
# Erreur : impossible de renommer avec un chemin

# ✅ Correct - nom uniquement
Rename-Item -Path "C:\file.txt" -NewName "newfile.txt"

# ✅ Pour déplacer ET renommer, utilisez Move-Item
Move-Item -Path "C:\file.txt" -Destination "D:\newfile.txt"
```

### Renommage en masse avec pipeline

La vraie puissance de `Rename-Item` se révèle avec le pipeline et `Get-ChildItem`.

```powershell
# Ajouter un préfixe à tous les fichiers .txt
Get-ChildItem -Path "C:\Documents\*.txt" | 
    Rename-Item -NewName { "Backup_" + $_.Name }

# Résultat : file.txt → Backup_file.txt

# Ajouter un suffixe avant l'extension
Get-ChildItem -Path "C:\Photos\*.jpg" | 
    Rename-Item -NewName { $_.BaseName + "_2024" + $_.Extension }

# Résultat : photo.jpg → photo_2024.jpg

# Remplacer une chaîne dans tous les noms
Get-ChildItem -Path "C:\Docs\*" | 
    Rename-Item -NewName { $_.Name -replace "old", "new" }

# Résultat : old_file.txt → new_file.txt
```

> [!info] **Variables utiles dans le scriptblock**
> 
> - `$_.Name` : nom complet avec extension
> - `$_.BaseName` : nom sans extension
> - `$_.Extension` : extension (avec le point)
> - `$_.DirectoryName` : chemin du dossier parent

### Numérotation séquentielle

```powershell
# Renommer avec numéros séquentiels
$counter = 1
Get-ChildItem -Path "C:\Photos\*.jpg" | 
    Sort-Object LastWriteTime | 
    Rename-Item -NewName { 
        "Photo_{0:D3}.jpg" -f $counter++
    }

# Résultat : Photo_001.jpg, Photo_002.jpg, Photo_003.jpg, ...

# Avec date dans le nom
Get-ChildItem -Path "C:\Logs\*.log" | 
    Rename-Item -NewName { 
        "{0:yyyy-MM-dd}_{1}" -f $_.LastWriteTime, $_.Name 
    }

# Résultat : 2024-03-15_app.log
```

### Expressions régulières pour renommage avancé

```powershell
# Supprimer tous les espaces
Get-ChildItem -Path "C:\Files\*" | 
    Rename-Item -NewName { $_.Name -replace "\s+", "_" }

# Résultat : "mon fichier.txt" → "mon_fichier.txt"

# Extraire et réorganiser des parties du nom
Get-ChildItem -Path "C:\Docs\*" -Filter "*.txt" | 
    Rename-Item -NewName { 
        $_.Name -replace "(\d{4})-(\d{2})-(\d{2})", '$3-$2-$1'
    }

# Résultat : "2024-03-15-file.txt" → "15-03-2024-file.txt"

# Nettoyer les caractères invalides
Get-ChildItem -Path "C:\Downloads\*" | 
    Rename-Item -NewName { 
        $_.Name -replace '[<>:"/\\|?*]', ''
    }

# Supprime tous les caractères interdits dans les noms de fichiers Windows
```

> [!tip] **Regex courantes**
> 
> - `\s+` : un ou plusieurs espaces
> - `\d+` : un ou plusieurs chiffres
> - `[abc]` : un caractère parmi a, b ou c
> - `(groupe)` : capture pour réutilisation avec `$1`, `$2`, etc.

### Renommage en masse avec conditions

```powershell
# Renommer uniquement les fichiers de plus de 1 MB
Get-ChildItem -Path "C:\Files\*" | 
    Where-Object { $_.Length -gt 1MB } | 
    Rename-Item -NewName { "Large_" + $_.Name }

# Renommer selon l'extension
Get-ChildItem -Path "C:\Mixed\*" | 
    Rename-Item -NewName { 
        if ($_.Extension -eq ".tmp") { 
            $_.BaseName + "_temporary" + $_.Extension 
        } else { 
            $_.Name 
        }
    }

# Standardiser les extensions en minuscules
Get-ChildItem -Path "C:\Files\*" | 
    Rename-Item -NewName { 
        $_.BaseName + $_.Extension.ToLower() 
    }

# Résultat : file.TXT → file.txt
```

### Exemples pratiques avancés

```powershell
# Renommer avec horodatage pour éviter les conflits
Get-ChildItem -Path "C:\Backup\*" | 
    Rename-Item -NewName { 
        "{0}_{1:yyyyMMdd_HHmmss}{2}" -f $_.BaseName, (Get-Date), $_.Extension 
    }

# Normaliser les noms (minuscules, sans espaces)
Get-ChildItem -Path "C:\Docs\*" | 
    Rename-Item -NewName { 
        $_.Name.ToLower() -replace "\s+", "-" 
    }

# Extraire métadonnées et renommer (exemple avec images)
Get-ChildItem -Path "C:\Photos\*.jpg" | 
    ForEach-Object {
        $img = New-Object -ComObject Wia.ImageFile
        $img.LoadFile($_.FullName)
        $date = $img.Properties["DateTime"].Value
        Rename-Item -Path $_.FullName -NewName ("IMG_" + $date -replace "[:\s]", "_" + ".jpg")
    }

# Test avant renommage réel
Get-ChildItem -Path "C:\Files\*" | 
    Rename-Item -NewName { "New_" + $_.Name } -WhatIf
# Affiche ce qui serait fait sans l'exécuter
```

---

## 🗺️ Gestion des chemins relatifs et absolus {#chemins}

### Types de chemins

#### Chemins absolus

Un chemin absolu spécifie l'emplacement complet depuis la racine du système.

```powershell
# Chemins absolus Windows
"C:\Users\John\Documents\file.txt"
"D:\Backup\Projects\2024\"

# Chemins UNC (réseau)
"\\Server\Share\Folder\file.txt"

# Toujours interprété de la même manière, peu importe le répertoire courant
Copy-Item -Path "C:\Source\file.txt" -Destination "D:\Dest\"
```

#### Chemins relatifs

Un chemin relatif est calculé par rapport au répertoire de travail actuel (`Get-Location`).

```powershell
# Si vous êtes dans C:\Users\John\

# Référence au répertoire courant
".\Documents\file.txt"         # C:\Users\John\Documents\file.txt
"file.txt"                      # C:\Users\John\file.txt

# Référence au répertoire parent
"..\Public\file.txt"            # C:\Users\Public\file.txt
"..\..\Program Files\"          # C:\Program Files\

# Descendre dans l'arborescence
"Documents\Projects\file.txt"   # C:\Users\John\Documents\Projects\file.txt
```

### Symboles spéciaux

|Symbole|Signification|Exemple|
|---|---|---|
|`.`|Répertoire courant|`.\file.txt`|
|`..`|Répertoire parent|`..\folder\`|
|`~`|Répertoire personnel|`~\Documents` (= `$HOME\Documents`)|
|`/` ou `\`|Séparateur de chemin|`folder\subfolder\file`|

```powershell
# Utilisation du tilde (~) pour HOME
Copy-Item -Path "C:\file.txt" -Destination "~\Desktop\"
# Équivalent à : C:\Users\<Utilisateur>\Desktop\

# Navigation relative
Set-Location "C:\Users\John\Documents"
Copy-Item -Path ".\file.txt" -Destination "..\Desktop\"
# Copie de C:\Users\John\Documents\file.txt vers C:\Users\John\Desktop\
```

### Résolution de chemins

```powershell
# Convertir un chemin relatif en absolu
Resolve-Path ".\Documents\file.txt"
# Retourne : C:\Users\John\Documents\file.txt

# Tester l'existence d'un chemin
Test-Path ".\file.txt"          # $true ou $false

# Obtenir le chemin absolu dans une variable
$absolutePath = (Resolve-Path ".\folder").Path
```

### Bonnes pratiques avec les chemins

```powershell
# ✅ Utiliser Join-Path pour construire des chemins portables
$folder = "C:\Base"
$file = "file.txt"
$fullPath = Join-Path -Path $folder -ChildPath $file
# Résultat : C:\Base\file.txt

# ✅ Éviter la concaténation manuelle
$badPath = $folder + "\" + $file  # ❌ Non portable, erreurs possibles

# ✅ Utiliser des chemins relatifs pour la portabilité des scripts
Copy-Item -Path ".\config.json" -Destination ".\backup\"
# Fonctionne peu importe où le script est exécuté

# ✅ Utiliser des guillemets pour les chemins avec espaces
Copy-Item -Path "C:\Mes Documents\file.txt" -Destination "D:\Backup\"
```

> [!warning] **Attention aux chemins relatifs dans les scripts** Le répertoire courant d'un script n'est pas forcément le dossier du script lui-même. Utilisez `$PSScriptRoot` pour référencer le dossier du script.

```powershell
# Obtenir le dossier du script en cours
$scriptFolder = $PSScriptRoot

# Construire un chemin relatif au script
$configFile = Join-Path -Path $scriptFolder -ChildPath "config.json"
Copy-Item -Path $configFile -Destination "C:\App\"
```

---

## 🎯 Wildcards et filtrage dans les opérations {#wildcards}

### Wildcards de base

Les wildcards (caractères génériques) permettent de cibler plusieurs fichiers avec un seul motif.

|Wildcard|Signification|Exemple|
|---|---|---|
|`*`|N'importe quel caractère, 0 à plusieurs fois|`*.txt` = tous les .txt|
|`?`|Un seul caractère|`file?.txt` = file1.txt, fileA.txt|
|`[abc]`|Un caractère parmi ceux listés|`file[123].txt` = file1.txt, file2.txt, file3.txt|
|`[a-z]`|Un caractère dans une plage|`file[a-c].txt` = filea.txt, fileb.txt, filec.txt|

```powershell
# Copier tous les fichiers .txt
Copy-Item -Path "C:\Docs\*.txt" -Destination "D:\Backup\"

# Copier les fichiers avec un caractère unique
Copy-Item -Path "C:\Logs\log?.txt" -Destination "D:\Archive\"
# Copie : log1.txt, logA.txt mais PAS log10.txt

# Copier les fichiers commençant par "report" et finissant par un chiffre
Copy-Item -Path "C:\Reports\report*[0-9].pdf" -Destination "D:\Reports\"
```

### Utilisation avancée des wildcards

```powershell
# Combiner plusieurs wildcards
Copy-Item -Path "C:\Data\2024*[0-9][0-9].csv" -Destination "D:\Archive\"
# Copie : 2024_01.csv, 2024-12.csv, 2024data99.csv

# Wildcards dans les dossiers
Copy-Item -Path "C:\Projects\*\bin\*.dll" -Destination "D:\Libs\" -Recurse
# Copie toutes les DLL de tous les dossiers bin de tous les projets

# Exclure avec wildcards négatifs (via Where-Object)
Get-ChildItem -Path "C:\Files\*" | 
    Where-Object { $_.Name -notlike "*temp*" } | 
    Copy-Item -Destination "D:\Clean\"
```

### Différence entre wildcards et regex

```powershell
# Wildcard (simple, pour noms de fichiers)
Copy-Item -Path "C:\Files\*.txt" -Destination "D:\Backup\"

# Regex (avancé, pour filtrage complexe)
Get-ChildItem -Path "C:\Files\*" | 
    Where-Object { $_.Name -match "^\d{4}-\d{2}-\d{2}\.txt$" } | 
    Copy-Item -Destination "D:\Dated\"
# Copie uniquement les fichiers au format : 2024-03-15.txt
```

|Fonctionnalité|Wildcards|Regex|
|---|---|---|
|Simplicité|⭐⭐⭐|⭐|
|Puissance|⭐⭐|⭐⭐⭐|
|Support natif|`-Filter`, `-Include`, `-Exclude`|`-match`, `Select-String`|
|Usage typique|Noms de fichiers|Contenu, filtrage complexe|

### Filtrage combiné

```powershell
# Wildcards + filtrage par taille
Get-ChildItem -Path "C:\Files\*.log" | 
    Where-Object { $_.Length -gt 10MB } | 
    Copy-Item -Destination "D:\BigLogs\"

# Wildcards + filtrage par date + regex
Get-ChildItem -Path "C:\Docs\*.txt" | 
    Where-Object { 
        $_.LastWriteTime -gt (Get-Date).AddDays(-7) -and 
        $_.Name -match "^Report_\d{4}"
    } | 
    Copy-Item -Destination "D:\Recent\"

# Renommage avec wildcards et conditions
Get-ChildItem -Path "C:\Mixed\*" | 
    Where-Object { $_.Extension -in ".tmp", ".temp" } | 
    Rename-Item -NewName { $_.Name -replace "\.temp?$", ".backup" }
```

### Exemples pratiques combinés

```powershell
# Organiser des fichiers par type avec wildcards
@("*.docx", "*.pdf", "*.xlsx") | ForEach-Object {
    $ext = $_ -replace "\*\.", ""
    $destFolder = "C:\Organized\$ext"
    if (!(Test-Path $destFolder)) { New-Item -Path $destFolder -ItemType Directory }
    Copy-Item -Path "C:\Downloads\$_" -Destination $destFolder
}

# Backup intelligent avec filtrage multiple
Get-ChildItem -Path "C:\Project\*" -Recurse | 
    Where-Object { 
        $_.Extension -in ".cs", ".config", ".json" -and
        $_.DirectoryName -notlike "*\bin\*" -and
        $_.DirectoryName -notlike "*\obj\*"
    } | 
    Copy-Item -Destination { 
        Join-Path "D:\Backup" $_.FullName.Substring(11) 
    } -Force

# Renommage conditionnel avec wildcards
Get-ChildItem -Path "C:\Photos\IMG_*.jpg" | 
    Where-Object { $_.Length -lt 500KB } | 
    Rename-Item -NewName { "Small_" + $_.Name }

# Copie sélective avec exclusions multiples
Copy-Item -Path "C:\Project\*" -Destination "D:\Backup\" -Recurse `
    -Exclude "*.log", "*.tmp", "*.cache", "node_modules", ".git"
```

> [!tip] **Optimisation des wildcards** Placez les wildcards les plus restrictifs en premier pour améliorer les performances. Utilisez `-Filter` plutôt que `-Include` quand possible.

### Pièges courants avec les wildcards

```powershell
# ❌ Piège : wildcard sans chemin parent
Copy-Item -Path "*.txt" -Destination "D:\Backup\"  # Ne cherche que dans le dossier courant

# ✅ Solution : spécifier le chemin complet
Copy-Item -Path "C:\Docs\*.txt" -Destination "D:\Backup\"

# ❌ Piège : oublier -Recurse avec wildcards imbriqués
Copy-Item -Path "C:\Projects\*\*.config" -Destination "D:\Configs\"  # Ne copie rien

# ✅ Solution : utiliser -Recurse ou Get-ChildItem
Get-ChildItem -Path "C:\Projects\" -Filter "*.config" -Recurse | 
    Copy-Item -Destination "D:\Configs\"

# ❌ Piège : wildcards dans -Destination
Copy-Item -Path "C:\file.txt" -Destination "D:\Backup\*.txt"  # Erreur !

# ✅ La destination ne supporte pas les wildcards
Copy-Item -Path "C:\file.txt" -Destination "D:\Backup\"
```

> [!warning] **Limitations importantes**
> 
> - Les wildcards ne fonctionnent que dans `-Path`, `-Filter`, `-Include` et `-Exclude`
> - `-Destination` n'accepte jamais de wildcards
> - `-Include` et `-Exclude` nécessitent un wildcard dans `-Path` pour fonctionner

### Cas d'usage pratiques finaux

```powershell
# Archivage mensuel avec filtrage complexe
$month = (Get-Date).ToString("yyyy-MM")
$archiveFolder = "D:\Archives\$month"
New-Item -Path $archiveFolder -ItemType Directory -Force

Get-ChildItem -Path "C:\Logs\" -Filter "*.log" | 
    Where-Object { 
        $_.LastWriteTime.Month -eq (Get-Date).Month -and
        $_.Length -gt 0
    } | 
    Move-Item -Destination $archiveFolder -Force

# Nettoyage intelligent avec wildcards
@("*.tmp", "*.log", "*.cache") | ForEach-Object {
    Get-ChildItem -Path "C:\Temp\" -Filter $_ -Recurse | 
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | 
        Remove-Item -Force
}

# Migration de projet avec renommage standardisé
Get-ChildItem -Path "C:\OldProject\" -Recurse | 
    Where-Object { $_.Extension -in ".cs", ".csproj", ".sln" } | 
    ForEach-Object {
        $newName = $_.Name -replace "OldProject", "NewProject"
        $relativePath = $_.FullName.Substring(14)  # Retire "C:\OldProject\"
        $destPath = Join-Path "D:\NewProject" (Split-Path $relativePath)
        
        if (!(Test-Path $destPath)) { 
            New-Item -Path $destPath -ItemType Directory -Force 
        }
        
        Copy-Item -Path $_.FullName -Destination (Join-Path $destPath $newName)
    }
```

---

## 🎯 Bonnes pratiques globales

### Sécurité et tests

```powershell
# Toujours tester avec -WhatIf avant des opérations de masse
Get-ChildItem -Path "C:\Important\*" | 
    Remove-Item -Recurse -WhatIf

# Utiliser -Confirm pour validation manuelle
Move-Item -Path "C:\Critical\*" -Destination "D:\Backup\" -Confirm

# Créer des logs d'opérations
$logFile = "C:\Scripts\operations_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Get-ChildItem -Path "C:\Source\" -Recurse | 
    ForEach-Object {
        try {
            Copy-Item -Path $_.FullName -Destination "D:\Backup\" -ErrorAction Stop
            Add-Content -Path $logFile -Value "SUCCESS: $($_.FullName)"
        } catch {
            Add-Content -Path $logFile -Value "ERROR: $($_.FullName) - $($_.Exception.Message)"
        }
    }
```

### Gestion d'erreurs robuste

```powershell
# Utiliser try/catch pour des opérations critiques
try {
    Copy-Item -Path "C:\Important\data.db" -Destination "D:\Backup\" -ErrorAction Stop
    Write-Host "Backup réussi" -ForegroundColor Green
} catch {
    Write-Host "Échec du backup: $($_.Exception.Message)" -ForegroundColor Red
    # Envoyer une alerte, logger l'erreur, etc.
}

# Vérifier l'espace disque avant de copier
$source = "C:\BigFolder"
$sourceSize = (Get-ChildItem -Path $source -Recurse | Measure-Object -Property Length -Sum).Sum
$destDrive = "D:"
$freeSpace = (Get-PSDrive -Name $destDrive.TrimEnd(':')).Free

if ($freeSpace -gt ($sourceSize * 1.1)) {  # 10% de marge
    Copy-Item -Path $source -Destination "$destDrive\Backup\" -Recurse
} else {
    Write-Warning "Espace insuffisant sur $destDrive"
}
```

### Performance et optimisation

```powershell
# Privilégier -Filter sur -Include pour les grandes opérations
# ✅ Rapide
Copy-Item -Path "C:\Logs\*" -Destination "D:\Backup\" -Filter "*.log"

# 🐢 Plus lent
Copy-Item -Path "C:\Logs\*" -Destination "D:\Backup\" -Include "*.log"

# Utiliser Robocopy pour les très gros volumes
# PowerShell n'est pas toujours optimal pour copier des To de données
Start-Process -FilePath "robocopy.exe" -ArgumentList "C:\Source D:\Dest /MIR /MT:8" -NoNewWindow -Wait

# Traiter par lots pour éviter la surcharge mémoire
$batchSize = 100
$files = Get-ChildItem -Path "C:\Massive\" -Recurse
for ($i = 0; $i -lt $files.Count; $i += $batchSize) {
    $files[$i..($i + $batchSize - 1)] | Copy-Item -Destination "D:\Backup\" -Force
    Write-Progress -Activity "Copie en cours" -Status "$i/$($files.Count)" -PercentComplete (($i / $files.Count) * 100)
}
```

### Organisation et maintenabilité

```powershell
# Utiliser des fonctions réutilisables
function Backup-Folder {
    param(
        [string]$Source,
        [string]$Destination,
        [string[]]$ExcludeExtensions = @("*.tmp", "*.log")
    )
    
    if (!(Test-Path $Destination)) {
        New-Item -Path $Destination -ItemType Directory -Force | Out-Null
    }
    
    Get-ChildItem -Path $Source -Recurse | 
        Where-Object { $_.Extension -notin $ExcludeExtensions } | 
        ForEach-Object {
            $destPath = Join-Path $Destination $_.FullName.Substring($Source.Length)
            $destFolder = Split-Path $destPath
            
            if (!(Test-Path $destFolder)) {
                New-Item -Path $destFolder -ItemType Directory -Force | Out-Null
            }
            
            Copy-Item -Path $_.FullName -Destination $destPath -Force
        }
}

# Utilisation
Backup-Folder -Source "C:\Projects\MyApp" -Destination "D:\Backup\MyApp" -ExcludeExtensions @("*.obj", "*.pdb")
```

### Synthèse des paramètres communs

|Paramètre|Copy-Item|Move-Item|Rename-Item|Description|
|---|---|---|---|---|
|`-Path`|✅|✅|✅|Élément source|
|`-Destination`|✅|✅|❌|Emplacement cible|
|`-NewName`|❌|❌|✅|Nouveau nom uniquement|
|`-Recurse`|✅|❌|❌|Inclure sous-dossiers|
|`-Force`|✅|✅|✅|Écraser sans confirmation|
|`-Filter`|✅|✅|❌|Filtrage rapide|
|`-Include`|✅|✅|❌|Filtrage après récupération|
|`-Exclude`|✅|✅|❌|Exclusion de fichiers|
|`-WhatIf`|✅|✅|✅|Simulation sans exécution|
|`-Confirm`|✅|✅|✅|Demander confirmation|

---

## 📚 Résumé des points clés

> [!info] **Copy-Item**
> 
> - Duplique des fichiers et dossiers
> - Nécessite `-Recurse` pour copier le contenu des dossiers
> - `-Force` pour écraser les fichiers existants
> - `-Filter` est plus rapide que `-Include`/`-Exclude`
> - Préserve les attributs mais pas les dates originales

> [!info] **Move-Item**
> 
> - Déplace (coupe-colle) des fichiers et dossiers
> - Pas besoin de `-Recurse` (déplace toujours tout le contenu)
> - Peut servir à renommer dans le même dossier
> - Instantané sur le même volume, copie+suppression entre volumes
> - `-Force` écrase définitivement sans corbeille

> [!info] **Rename-Item**
> 
> - Spécialisé dans le renommage
> - `-NewName` accepte uniquement un nom, pas un chemin
> - Puissant avec pipeline pour renommage en masse
> - Support des scriptblocks pour transformations complexes
> - Idéal avec regex pour motifs avancés

> [!tip] **Chemins et wildcards**
> 
> - Chemins absolus : toujours depuis la racine (C:...)
> - Chemins relatifs : par rapport au dossier courant (., ..)
> - Wildcards : `*` (multiple), `?` (unique), `[abc]` (liste)
> - `-Filter` pour wildcards simples, regex pour filtrage avancé
> - Toujours tester avec `-WhatIf` avant les opérations de masse

---

## 🔍 Aide-mémoire rapide

```powershell
# Copier un fichier
Copy-Item "source.txt" "destination\"

# Copier un dossier complet
Copy-Item "C:\Folder" "D:\Backup\" -Recurse

# Déplacer avec écrasement
Move-Item "file.txt" "D:\Archive\" -Force

# Renommer un fichier
Rename-Item "old.txt" "new.txt"

# Renommage en masse
Get-ChildItem "*.txt" | Rename-Item -NewName { "Prefix_" + $_.Name }

# Copier seulement certains types
Copy-Item "C:\Docs\*" "D:\Backup\" -Include "*.docx", "*.pdf" -Recurse

# Tester sans exécuter
Move-Item "C:\Test\*" "D:\Archive\" -WhatIf

# Chemins relatifs
Copy-Item ".\file.txt" "..\parent\folder\"

# Wildcards avancés
Get-ChildItem "report[0-9][0-9].pdf" | Copy-Item -Destination "D:\Reports\"
```