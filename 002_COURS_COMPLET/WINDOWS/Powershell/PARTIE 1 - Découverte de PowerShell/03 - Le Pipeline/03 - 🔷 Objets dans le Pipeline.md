
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

## 🎯 Nature des objets transmis

### Qu'est-ce qu'un objet dans le pipeline ?

PowerShell diffère fondamentalement des shells traditionnels (comme Bash) : au lieu de transmettre du texte brut entre les commandes, PowerShell transmet des **objets .NET structurés**.

> [!info] Pourquoi c'est important Cette approche orientée objet permet de manipuler directement les propriétés et méthodes sans avoir à parser du texte, rendant les scripts plus robustes et maintenables.

### Types d'objets transmis

Chaque cmdlet retourne un type d'objet spécifique :

```powershell
# Get-Process retourne des objets System.Diagnostics.Process
Get-Process

# Get-Service retourne des objets System.ServiceProcess.ServiceController
Get-Service

# Get-ChildItem retourne des objets System.IO.FileInfo ou DirectoryInfo
Get-ChildItem
```

### Différence fondamentale avec les shells textuels

```powershell
# ❌ Shell traditionnel (Bash) : manipulation de texte
# ps aux | grep chrome | awk '{print $2}'

# ✅ PowerShell : manipulation d'objets
Get-Process chrome | Select-Object -Property Id, Name, CPU
```

> [!example] Exemple concret
> 
> ```powershell
> # L'objet Process contient déjà toutes les informations structurées
> $proc = Get-Process notepad
> $proc.Id          # Accès direct à l'ID du processus
> $proc.WorkingSet  # Utilisation mémoire
> $proc.StartTime   # Date de démarrage
> ```

---

## 🏗️ Propriétés et méthodes disponibles

### Structure d'un objet PowerShell

Chaque objet possède :

- **Propriétés** : données stockées dans l'objet
- **Méthodes** : actions que l'objet peut effectuer

```powershell
# Accès aux propriétés avec la notation point
$service = Get-Service wuauserv
$service.Name        # Propriété
$service.Status      # Propriété

# Appel de méthodes avec ()
$service.Start()     # Méthode
$service.Stop()      # Méthode
```

### Types de propriétés courants

|Type de propriété|Description|Exemple|
|---|---|---|
|**ScriptProperty**|Propriété calculée dynamiquement|CPU, WorkingSet|
|**NoteProperty**|Propriété simple ajoutée|Propriétés personnalisées|
|**AliasProperty**|Alias vers une autre propriété|Size → Length|
|**Property**|Propriété native de l'objet .NET|Name, Id|

```powershell
# Exemple avec un fichier
$file = Get-Item "C:\temp\test.txt"

# Propriétés natives
$file.Name           # test.txt
$file.Length         # Taille en octets
$file.CreationTime   # Date de création

# Propriétés calculées
$file.FullName       # Chemin complet
```

### Méthodes communes

```powershell
# Méthodes sur les chaînes de caractères
$text = "PowerShell"
$text.ToUpper()         # POWERSHELL
$text.ToLower()         # powershell
$text.Substring(0, 5)   # Power
$text.Replace("Shell", "Script")  # PowerScript

# Méthodes sur les processus
$process = Get-Process notepad
$process.Kill()         # Termine le processus
$process.Refresh()      # Actualise les données
```

> [!warning] Attention aux méthodes destructives Certaines méthodes modifient l'état du système (comme `Kill()`, `Start()`, `Stop()`). Utilisez-les avec précaution.

---

## 💲 Variables automatiques `$_` et `$PSItem`

### Qu'est-ce que `$_` ?

`$_` est une **variable automatique** qui représente l'objet courant dans le pipeline. Elle est disponible uniquement à l'intérieur de blocs de script comme `ForEach-Object`, `Where-Object`, ou dans certaines expressions.

```powershell
# $_ représente chaque processus un par un
Get-Process | Where-Object { $_.CPU -gt 10 }

# Équivalent avec $PSItem (plus lisible)
Get-Process | Where-Object { $PSItem.CPU -gt 10 }
```

> [!info] `$PSItem` vs `$_` `$PSItem` est un alias de `$_` introduit pour améliorer la lisibilité du code. Ils sont strictement identiques et interchangeables.

### Contextes d'utilisation

#### 1. Avec `Where-Object` (filtrage)

```powershell
# Filtrer les services en cours d'exécution
Get-Service | Where-Object { $_.Status -eq 'Running' }

# Filtrer les fichiers de plus de 1 Mo
Get-ChildItem | Where-Object { $_.Length -gt 1MB }
```

#### 2. Avec `ForEach-Object` (itération)

```powershell
# Afficher le nom de chaque processus en majuscules
Get-Process | ForEach-Object { $_.Name.ToUpper() }

# Arrêter tous les processus Chrome
Get-Process chrome | ForEach-Object { $_.Kill() }
```

#### 3. Avec `Select-Object` (propriétés calculées)

```powershell
# Créer une propriété calculée
Get-Process | Select-Object Name, 
    @{Name='MemoryMB'; Expression={ $_.WorkingSet / 1MB }}
```

#### 4. Dans les switch statements

```powershell
1..5 | ForEach-Object {
    switch ($_) {
        {$_ -le 2} { "Petit: $_" }
        {$_ -gt 2} { "Grand: $_" }
    }
}
```

### Bonnes pratiques

> [!tip] Quand utiliser `$_` vs `$PSItem`
> 
> - Utilisez `$_` pour du code rapide ou interactif
> - Utilisez `$PSItem` dans les scripts partagés pour plus de clarté
> - Restez cohérent dans un même script

```powershell
# ✅ Bon : court et clair
Get-Process | Where-Object { $_.CPU -gt 10 }

# ✅ Bon : explicite dans un script complexe
Get-Process | Where-Object { 
    $PSItem.CPU -gt 10 -and 
    $PSItem.WorkingSet -gt 100MB 
}
```

> [!warning] Piège courant : scope de `$_` `$_` n'est disponible QUE dans le bloc de script où il est défini. Il ne persiste pas en dehors.
> 
> ```powershell
> # ❌ Erreur : $_ n'existe pas ici
> Get-Process
> Write-Host $_.Name
> 
> # ✅ Correct : $_ existe dans le bloc ForEach-Object
> Get-Process | ForEach-Object { Write-Host $_.Name }
> ```

---

## 🔍 Inspection des objets avec Get-Member

### Rôle de `Get-Member`

`Get-Member` est LA cmdlet essentielle pour découvrir ce qu'on peut faire avec un objet. Elle révèle toutes les propriétés et méthodes disponibles.

```powershell
# Syntaxe de base
Get-Process | Get-Member

# Alias courants
Get-Process | gm
```

### Structure de la sortie

```powershell
Get-Service | Get-Member

# Sortie :
#   TypeName: System.ServiceProcess.ServiceController
#
# Name              MemberType    Definition
# ----              ----------    ----------
# Name              Property      string Name {get;set;}
# Status            Property      System.ServiceProcess.ServiceControllerStatus Status {get;}
# Start             Method        void Start()
# Stop              Method        void Stop()
```

### Filtrage par type de membre

```powershell
# Afficher uniquement les propriétés
Get-Process | Get-Member -MemberType Property

# Afficher uniquement les méthodes
Get-Process | Get-Member -MemberType Method

# Afficher les propriétés et méthodes
Get-Process | Get-Member -MemberType Property,Method
```

### Types de membres

|MemberType|Description|Exemple|
|---|---|---|
|**Property**|Propriété native|`Name`, `Id`, `Status`|
|**ScriptProperty**|Propriété calculée|`CPU`, `WorkingSet`|
|**Method**|Méthode d'action|`Kill()`, `Start()`, `Stop()`|
|**NoteProperty**|Propriété ajoutée|Propriétés personnalisées|
|**AliasProperty**|Alias de propriété|`Size` → `Length`|

### Recherche de membres spécifiques

```powershell
# Rechercher les membres contenant "memory"
Get-Process | Get-Member *memory*

# Rechercher une méthode précise
Get-Process | Get-Member -Name Kill

# Voir les détails d'un membre
Get-Process | Get-Member -Name WorkingSet | Format-List
```

### Exemples pratiques

```powershell
# Découvrir ce qu'on peut faire avec un fichier
Get-Item "C:\temp\test.txt" | Get-Member

# Découvrir les méthodes sur une chaîne
"PowerShell" | Get-Member

# Découvrir les propriétés d'une date
Get-Date | Get-Member

# Voir le type exact d'un objet
(Get-Process)[0] | Get-Member
```

> [!tip] Astuce pour l'exploration Utilisez `Get-Member` systématiquement quand vous découvrez une nouvelle cmdlet. C'est le meilleur moyen d'apprendre ce qui est possible.

> [!example] Workflow d'exploration typique
> 
> ```powershell
> # 1. Obtenir un objet
> $obj = Get-Service wuauserv
> 
> # 2. Voir ses propriétés et méthodes
> $obj | Get-Member
> 
> # 3. Tester une propriété
> $obj.Status
> 
> # 4. Appeler une méthode
> $obj.GetType()
> ```

---

## 🛠️ Manipulation d'objets dans le pipeline

### Accès direct aux propriétés dans le pipeline

PowerShell permet d'accéder directement aux propriétés des objets qui transitent dans le pipeline :

```powershell
# Accès simple
Get-Process | Select-Object -ExpandProperty Name

# Version abrégée (membre de collection)
(Get-Process).Name
```

### Opérations sur les collections d'objets

```powershell
# Trier par une propriété
Get-Process | Sort-Object CPU -Descending

# Grouper par une propriété
Get-Process | Group-Object Company

# Mesurer des propriétés
Get-Process | Measure-Object WorkingSet -Sum -Average -Maximum
```

### Chaînage d'opérations

```powershell
# Pipeline complexe
Get-Process |
    Where-Object { $_.WorkingSet -gt 100MB } |
    Sort-Object CPU -Descending |
    Select-Object -First 10 Name, CPU, 
        @{N='MemoryMB'; E={[math]::Round($_.WorkingSet/1MB, 2)}}
```

> [!info] Pourquoi le chaînage est puissant Chaque cmdlet dans le pipeline reçoit les objets du précédent, les traite, et passe les résultats au suivant. Cela permet de construire des traitements complexes de manière lisible.

### Manipulation avancée avec ForEach-Object

```powershell
# Appeler une méthode sur chaque objet
Get-Process notepad | ForEach-Object { $_.Kill() }

# Transformation complexe
Get-ChildItem *.txt | ForEach-Object {
    $newName = $_.Name -replace '\.txt$', '.log'
    Rename-Item $_.FullName -NewName $newName
}
```

### Enrichissement d'objets

```powershell
# Ajouter une propriété à des objets existants
Get-Process | ForEach-Object {
    $_ | Add-Member -NotePropertyName 'MemoryGB' `
                   -NotePropertyValue ($_.WorkingSet / 1GB) `
                   -PassThru
}

# Création d'objets personnalisés
Get-ChildItem | ForEach-Object {
    [PSCustomObject]@{
        Nom = $_.Name
        Taille = $_.Length
        DateModif = $_.LastWriteTime
        Extension = $_.Extension
    }
}
```

---

## 🔄 Transformation d'objets

### Avec `Select-Object`

`Select-Object` permet de remodeler les objets en sélectionnant ou calculant des propriétés.

#### Sélection de propriétés

```powershell
# Sélectionner des propriétés spécifiques
Get-Process | Select-Object Name, Id, CPU

# Limiter le nombre d'objets
Get-Process | Select-Object -First 5
Get-Process | Select-Object -Last 3
Get-Process | Select-Object -Skip 10 -First 5
```

#### Propriétés calculées

```powershell
# Syntaxe complète
Get-Process | Select-Object Name,
    @{Name='MemoryMB'; Expression={$_.WorkingSet / 1MB}},
    @{Name='CPUSeconds'; Expression={$_.CPU}}

# Syntaxe abrégée (N pour Name, E pour Expression)
Get-Process | Select-Object Name,
    @{N='MemoryMB'; E={$_.WorkingSet / 1MB}}
```

> [!example] Transformations courantes
> 
> ```powershell
> # Convertir des tailles en unités lisibles
> Get-ChildItem | Select-Object Name,
>     @{N='SizeKB'; E={[math]::Round($_.Length/1KB, 2)}},
>     @{N='SizeMB'; E={[math]::Round($_.Length/1MB, 2)}}
> 
> # Calculer des âges
> Get-ChildItem | Select-Object Name,
>     @{N='DaysOld'; E={(Get-Date) - $_.CreationTime | Select-Object -Expand Days}}
> 
> # Formater des dates
> Get-Process | Select-Object Name,
>     @{N='Started'; E={$_.StartTime.ToString('yyyy-MM-dd HH:mm')}}
> ```

#### Expansion de propriétés

```powershell
# -ExpandProperty extrait uniquement les valeurs
Get-Process | Select-Object -ExpandProperty Name
# Sortie : chrome, notepad, powershell (juste les valeurs)

# Sans -ExpandProperty, garde la structure objet
Get-Process | Select-Object Name
# Sortie : objets avec propriété Name
```

### Avec `ForEach-Object`

`ForEach-Object` permet des transformations plus complexes avec un contrôle total.

```powershell
# Transformation simple
1..10 | ForEach-Object { $_ * 2 }

# Transformation d'objets
Get-Service | ForEach-Object {
    [PSCustomObject]@{
        ServiceName = $_.Name
        IsRunning = ($_.Status -eq 'Running')
        DisplayName = $_.DisplayName
    }
}
```

### Création d'objets personnalisés

```powershell
# Avec PSCustomObject (recommandé - plus performant)
$results = Get-ChildItem | ForEach-Object {
    [PSCustomObject]@{
        Fichier = $_.Name
        Taille = $_.Length
        Extension = $_.Extension
        Dossier = $_.Directory.Name
    }
}

# Avec New-Object (ancienne méthode)
$obj = New-Object PSObject -Property @{
    Name = "Test"
    Value = 42
}
```

> [!tip] Bonnes pratiques pour les propriétés calculées
> 
> - Utilisez des noms de propriétés clairs et descriptifs
> - Arrondissez les valeurs numériques pour la lisibilité
> - Formatez les dates selon vos besoins
> - Utilisez `[math]::Round()` pour contrôler la précision

---

## 🔎 Filtrage et sélection

### Avec `Where-Object`

`Where-Object` filtre les objets selon des conditions. Les objets qui remplissent la condition passent, les autres sont éliminés.

```powershell
# Syntaxe complète
Get-Process | Where-Object { $_.CPU -gt 10 }

# Syntaxe simplifiée (PowerShell 3.0+)
Get-Process | Where-Object CPU -gt 10

# Alias courant
Get-Process | where { $_.CPU -gt 10 }
Get-Process | ? { $_.CPU -gt 10 }
```

### Opérateurs de comparaison

|Opérateur|Description|Exemple|
|---|---|---|
|`-eq`|Égal|`$_.Status -eq 'Running'`|
|`-ne`|Différent|`$_.Status -ne 'Stopped'`|
|`-gt`|Plus grand|`$_.CPU -gt 10`|
|`-ge`|Plus grand ou égal|`$_.CPU -ge 10`|
|`-lt`|Plus petit|`$_.WorkingSet -lt 100MB`|
|`-le`|Plus petit ou égal|`$_.WorkingSet -le 100MB`|
|`-like`|Correspondance avec wildcards|`$_.Name -like 'chrome*'`|
|`-notlike`|Non correspondance|`$_.Name -notlike 'system*'`|
|`-match`|Regex|`$_.Name -match '^[A-Z]'`|
|`-notmatch`|Non regex|`$_.Name -notmatch '\d'`|
|`-contains`|Contient (pour collections)|`$services -contains 'wuauserv'`|
|`-in`|Est dans (pour collections)|`$_.Status -in 'Running','Stopped'`|

### Conditions multiples

```powershell
# ET logique avec -and
Get-Process | Where-Object { 
    $_.CPU -gt 10 -and $_.WorkingSet -gt 100MB 
}

# OU logique avec -or
Get-Service | Where-Object { 
    $_.Status -eq 'Running' -or $_.Status -eq 'Paused' 
}

# Négation avec -not ou !
Get-Process | Where-Object { -not $_.Responding }
Get-Process | Where-Object { !$_.Responding }

# Combinaisons complexes avec parenthèses
Get-Process | Where-Object { 
    ($_.CPU -gt 10 -or $_.WorkingSet -gt 100MB) -and 
    $_.Name -notlike 'system*'
}
```

### Filtrage avec patterns

```powershell
# Wildcards avec -like
Get-Process | Where-Object { $_.Name -like 'chrome*' }
Get-ChildItem | Where-Object { $_.Name -like '*.txt' }

# Regex avec -match
Get-Process | Where-Object { $_.Name -match '^[A-Z]{3,}' }
Get-ChildItem | Where-Object { $_.Name -match '\d{4}' }
```

### Sélection d'objets spécifiques

```powershell
# Premiers et derniers éléments
Get-Process | Select-Object -First 5
Get-Process | Select-Object -Last 3

# Ignorer des éléments
Get-Process | Select-Object -Skip 10 -First 5

# Objets uniques
Get-Process | Select-Object -Property Company -Unique
```

### Filtrage précoce vs tardif

> [!tip] Performance : filtrez tôt dans le pipeline
> 
> ```powershell
> # ❌ Moins performant : filtre après avoir tout traité
> Get-ChildItem -Recurse | Where-Object { $_.Extension -eq '.txt' }
> 
> # ✅ Plus performant : filtre directement par la cmdlet
> Get-ChildItem -Recurse -Filter *.txt
> ```

### Exemples pratiques

```powershell
# Services en cours avec mémoire élevée
Get-Service | Where-Object { 
    $_.Status -eq 'Running' 
} | Get-Process | Where-Object { 
    $_.WorkingSet -gt 100MB 
}

# Fichiers modifiés récemment
Get-ChildItem | Where-Object { 
    $_.LastWriteTime -gt (Get-Date).AddDays(-7) 
}

# Processus non-système avec CPU élevé
Get-Process | Where-Object { 
    $_.Company -ne 'Microsoft Corporation' -and 
    $_.CPU -gt 5 
}

# Fichiers par taille
Get-ChildItem | Where-Object { 
    $_.Length -gt 1MB -and $_.Length -lt 10MB 
}
```

> [!warning] Piège courant : null et propriétés manquantes Certains objets peuvent avoir des propriétés nulles. Gérez ces cas :
> 
> ```powershell
> # ❌ Peut générer des erreurs si Company est null
> Get-Process | Where-Object { $_.Company.Length -gt 5 }
> 
> # ✅ Mieux : vérifier null d'abord
> Get-Process | Where-Object { 
>     $_.Company -and $_.Company.Length -gt 5 
> }
> ```

---

## 🎓 Récapitulatif des concepts clés

> [!info] Points essentiels à retenir
> 
> **Nature des objets** :
> 
> - PowerShell transmet des objets .NET structurés, pas du texte
> - Chaque cmdlet retourne un type d'objet spécifique
> - Les objets ont des propriétés (données) et méthodes (actions)
> 
> **Variables automatiques** :
> 
> - `$_` et `$PSItem` représentent l'objet courant dans le pipeline
> - Disponibles dans `Where-Object`, `ForEach-Object`, et expressions similaires
> - Ne persistent pas en dehors du bloc de script
> 
> **Inspection** :
> 
> - `Get-Member` révèle toutes les propriétés et méthodes disponibles
> - Indispensable pour découvrir ce qu'on peut faire avec un objet
> 
> **Transformation** :
> 
> - `Select-Object` pour sélectionner et calculer des propriétés
> - `ForEach-Object` pour des transformations complexes
> - Propriétés calculées avec `@{Name='...'; Expression={...}}`
> 
> **Filtrage** :
> 
> - `Where-Object` filtre selon des conditions
> - Opérateurs : `-eq`, `-ne`, `-gt`, `-lt`, `-like`, `-match`
> - Conditions multiples avec `-and`, `-or`, `-not`
> - Filtrez tôt dans le pipeline pour de meilleures performances

---