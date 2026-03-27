

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

## Introduction

Ces trois cmdlets forment le trio essentiel pour **l'analyse et la manipulation de données** dans PowerShell. Ils permettent de transformer des collections d'objets bruts en informations structurées et exploitables.

> [!info] Pourquoi ces cmdlets sont essentiels
> 
> - **Sort-Object** : Ordonne vos données pour une meilleure lisibilité et analyse
> - **Measure-Object** : Calcule des statistiques (sommes, moyennes, comptages)
> - **Group-Object** : Regroupe et catégorise vos données pour identifier des patterns

Ces cmdlets fonctionnent en **pipeline** et peuvent être combinés pour des analyses complexes.

---

## Sort-Object - Tri et organisation

### 🎯 Concept et utilité

`Sort-Object` permet de **trier une collection d'objets** selon une ou plusieurs propriétés. C'est indispensable pour :

- Rendre les résultats lisibles (ordre alphabétique, chronologique)
- Identifier les valeurs extrêmes (plus grand, plus petit)
- Préparer des données pour des traitements ultérieurs

### 📝 Syntaxe de base

```powershell
Sort-Object [-Property] <string[]> [-Descending] [-Unique] [-CaseSensitive]
```

### 🔤 Tri simple - Croissant et décroissant

```powershell
# Tri croissant (par défaut)
Get-Process | Sort-Object CPU

# Tri décroissant
Get-Process | Sort-Object CPU -Descending

# Tri alphabétique sur les noms
Get-Service | Sort-Object Name

# Tri inversé sur les noms
Get-ChildItem | Sort-Object Name -Descending
```

> [!tip] Raccourci Vous pouvez utiliser l'alias `sort` au lieu de `Sort-Object`
> 
> ```powershell
> Get-Process | sort CPU -Descending
> ```

### 📊 Tri sur propriétés multiples

Vous pouvez trier selon **plusieurs critères** en spécifiant plusieurs propriétés. Le tri s'effectue dans l'ordre des propriétés spécifiées.

```powershell
# Tri par statut, puis par nom
Get-Service | Sort-Object Status, Name

# Fichiers : tri par extension, puis par taille décroissante
Get-ChildItem | Sort-Object Extension, @{Expression="Length"; Descending=$true}

# Processus : tri par priorité, puis par CPU
Get-Process | Sort-Object PriorityClass, CPU -Descending
```

> [!example] Exemple pratique
> 
> ```powershell
> # Services : d'abord les arrêtés, puis les démarrés, triés par nom
> Get-Service | Sort-Object @{Expression="Status"; Descending=$true}, Name
> ```

### 🧮 Tri sur propriétés calculées

Les **propriétés calculées** permettent de trier selon des valeurs dérivées ou transformées.

```powershell
# Tri par taille en Ko (au lieu d'octets)
Get-ChildItem | Sort-Object @{Expression={$_.Length / 1KB}}

# Tri par longueur du nom
Get-Process | Sort-Object @{Expression={$_.Name.Length}}

# Tri par âge des fichiers (plus récents en premier)
Get-ChildItem | Sort-Object @{Expression={$_.LastWriteTime}; Descending=$true}
```

**Syntaxe d'une propriété calculée :**

```powershell
@{
    Expression = { <script block> }  # Calcul de la valeur
    Descending = $true/$false        # Optionnel : ordre de tri
}
```

> [!warning] Attention aux performances Les propriétés calculées sont **plus lentes** car elles doivent être évaluées pour chaque objet. Utilisez-les uniquement quand nécessaire.

### 🎯 Paramètre -Unique

Le paramètre `-Unique` élimine les **doublons** après le tri.

```powershell
# Extensions de fichiers uniques
Get-ChildItem | Sort-Object Extension -Unique

# Noms de processus uniques
Get-Process | Sort-Object Name -Unique

# Valeurs uniques avec tri décroissant
1,3,2,3,1,2,5,4 | Sort-Object -Unique -Descending
# Résultat : 5,4,3,2,1
```

> [!tip] Comparaison avec Select-Object -Unique
> 
> - `Sort-Object -Unique` : **Trie puis déduplique**
> - `Select-Object -Unique` : Déduplique sans trier (garde le premier)
> 
> ```powershell
> # Sort-Object -Unique : résultat trié
> 3,1,2,1,3 | Sort-Object -Unique  # 1,2,3
> 
> # Select-Object -Unique : ordre d'origine
> 3,1,2,1,3 | Select-Object -Unique  # 3,1,2
> ```

### 🔠 Sensibilité à la casse

```powershell
# Par défaut : insensible à la casse
"z", "A", "b", "Z" | Sort-Object
# Résultat : A, b, z, Z

# Sensible à la casse : majuscules avant minuscules
"z", "A", "b", "Z" | Sort-Object -CaseSensitive
# Résultat : A, Z, b, z
```

### ⚡ Pièges courants

> [!warning] Tri de nombres stockés comme texte
> 
> ```powershell
> # PROBLÈME : tri alphabétique au lieu de numérique
> "10", "2", "1", "20" | Sort-Object
> # Résultat incorrect : 1, 10, 2, 20
> 
> # SOLUTION : convertir en nombres
> "10", "2", "1", "20" | Sort-Object {[int]$_}
> # Résultat correct : 1, 2, 10, 20
> ```

> [!warning] Tri sur des propriétés nulles Les valeurs `$null` sont toujours placées **en premier** (même avec `-Descending`)
> 
> ```powershell
> # Exclure les valeurs nulles avant le tri
> Get-Process | Where-Object CPU | Sort-Object CPU -Descending
> ```

### 💡 Astuces avancées

**Tri stable** : `Sort-Object` préserve l'ordre relatif des éléments égaux.

```powershell
# L'ordre initial est conservé pour les éléments de même valeur
1,2,3,1,2,3 | ForEach-Object {[PSCustomObject]@{Value=$_; Original=$_}} | 
    Sort-Object Value
```

**Tri personnalisé avec comparateur** :

```powershell
# Tri par ordre de priorité personnalisé
$priorityOrder = @{
    "Critique" = 1
    "Élevé" = 2
    "Moyen" = 3
    "Faible" = 4
}

$tickets | Sort-Object @{Expression={$priorityOrder[$_.Priorité]}}
```

---

## Measure-Object - Calculs et statistiques

### 🎯 Concept et utilité

`Measure-Object` permet de calculer des **statistiques** sur une collection d'objets. Il est essentiel pour :

- Compter des éléments
- Calculer des sommes, moyennes, min/max
- Analyser du texte (lignes, mots, caractères)
- Obtenir des métriques rapides sur vos données

### 📝 Syntaxe de base

```powershell
Measure-Object [-Property] <string> [-Sum] [-Average] [-Maximum] [-Minimum] 
    [-Line] [-Word] [-Character]
```

### 🔢 Comptage simple

```powershell
# Compter le nombre d'objets
Get-Process | Measure-Object
# Résultat : Count : 127

# Compter les fichiers d'un dossier
Get-ChildItem | Measure-Object
# Résultat : Count : 45

# Compter avec Where-Object
Get-Service | Where-Object Status -eq "Running" | Measure-Object
# Résultat : Count : 89
```

> [!tip] Accéder à la valeur du comptage
> 
> ```powershell
> # Stocker le résultat
> $count = (Get-Process | Measure-Object).Count
> 
> # Afficher uniquement le nombre
> (Get-ChildItem | Measure-Object).Count
> ```

### ➕ Somme avec -Sum

Le paramètre `-Sum` calcule la **somme totale** d'une propriété numérique.

```powershell
# Somme de la taille de tous les fichiers (en octets)
Get-ChildItem | Measure-Object -Property Length -Sum

# Somme du CPU utilisé par tous les processus
Get-Process | Measure-Object -Property CPU -Sum

# Somme des pages mémoire
Get-Process | Measure-Object -Property WorkingSet -Sum
```

**Exemple avec résultat :**

```powershell
Get-ChildItem | Measure-Object -Property Length -Sum

# Count    : 45
# Average  :
# Sum      : 15234567
# Maximum  :
# Minimum  :
# Property : Length
```

> [!example] Conversion d'unités
> 
> ```powershell
> # Taille totale en Mo
> $totalBytes = (Get-ChildItem -Recurse | Measure-Object -Property Length -Sum).Sum
> $totalMB = [math]::Round($totalBytes / 1MB, 2)
> Write-Host "Taille totale : $totalMB Mo"
> ```

### 📊 Moyenne avec -Average

```powershell
# Taille moyenne des fichiers
Get-ChildItem | Measure-Object -Property Length -Average

# CPU moyen des processus
Get-Process | Measure-Object -Property CPU -Average

# Mémoire moyenne utilisée
Get-Process | Measure-Object -Property WorkingSet -Average
```

> [!tip] Combiner plusieurs statistiques
> 
> ```powershell
> # Obtenir Count, Sum et Average en une seule commande
> Get-ChildItem | Measure-Object -Property Length -Sum -Average
> 
> # Résultat :
> # Count    : 45
> # Average  : 338545.93
> # Sum      : 15234567
> ```

### 📈 Minimum et Maximum

```powershell
# Plus petit et plus grand fichier
Get-ChildItem | Measure-Object -Property Length -Minimum -Maximum

# Processus utilisant le moins et le plus de CPU
Get-Process | Measure-Object -Property CPU -Minimum -Maximum

# Toutes les statistiques
Get-ChildItem | Measure-Object -Property Length -Sum -Average -Minimum -Maximum
```

**Résultat complet :**

```powershell
Count    : 45
Average  : 338545.93
Sum      : 15234567
Maximum  : 5234890
Minimum  : 128
Property : Length
```

### 🎯 Propriété à mesurer

Le paramètre `-Property` spécifie **quelle propriété** mesurer.

```powershell
# Mesurer la propriété CPU
Get-Process | Measure-Object -Property CPU -Average

# Mesurer la propriété Length (taille)
Get-ChildItem | Measure-Object -Property Length -Sum

# Mesurer WorkingSet (mémoire utilisée)
Get-Process | Measure-Object -Property WorkingSet -Sum
```

> [!warning] Propriétés nulles ou non numériques `Measure-Object` **ignore automatiquement** les valeurs `$null` et non numériques.
> 
> ```powershell
> # Si certains processus n'ont pas de CPU, ils sont ignorés
> Get-Process | Measure-Object -Property CPU -Sum
> ```

### 📝 Statistiques sur le texte

`Measure-Object` peut analyser du **contenu textuel** avec `-Line`, `-Word`, `-Character`.

```powershell
# Compter les lignes d'un fichier
Get-Content script.ps1 | Measure-Object -Line

# Compter lignes, mots et caractères
Get-Content document.txt | Measure-Object -Line -Word -Character

# Analyser une chaîne de caractères
"Bonjour le monde PowerShell" | Measure-Object -Character -Word
```

**Résultat :**

```powershell
Lines      : 0
Words      : 4
Characters : 28
Property   :
```

> [!example] Exemple pratique - Analyse de logs
> 
> ```powershell
> # Compter le nombre de lignes d'erreur dans un log
> Get-Content app.log | Where-Object {$_ -match "ERROR"} | Measure-Object -Line
> 
> # Statistiques complètes sur un fichier texte
> $stats = Get-Content README.md | Measure-Object -Line -Word -Character
> Write-Host "Lignes : $($stats.Lines)"
> Write-Host "Mots : $($stats.Words)"
> Write-Host "Caractères : $($stats.Characters)"
> ```

### ⚡ Pièges courants

> [!warning] Oublier -Property pour les statistiques
> 
> ```powershell
> # INCORRECT : ne spécifie pas la propriété
> Get-ChildItem | Measure-Object -Sum
> # Erreur : pas de propriété spécifiée
> 
> # CORRECT : spécifier la propriété
> Get-ChildItem | Measure-Object -Property Length -Sum
> ```

> [!warning] Mesurer des collections vides
> 
> ```powershell
> # Si aucun résultat, Count = 0
> Get-Process -Name "InexistantProcess" -ErrorAction SilentlyContinue | 
>     Measure-Object
> # Résultat : Count : 0
> ```

### 💡 Astuces avancées

**Mesures multiples en une fois :**

```powershell
# Créer un rapport complet
$report = Get-ChildItem -Recurse | Measure-Object -Property Length -Sum -Average -Minimum -Maximum

[PSCustomObject]@{
    NombreFichiers = $report.Count
    TailleTotal = "$([math]::Round($report.Sum / 1MB, 2)) Mo"
    TailleMoyenne = "$([math]::Round($report.Average / 1KB, 2)) Ko"
    PlusGrand = "$([math]::Round($report.Maximum / 1MB, 2)) Mo"
    PlusPetit = "$($report.Minimum) octets"
}
```

**Mesurer plusieurs propriétés :**

```powershell
# Vous ne pouvez mesurer qu'UNE propriété à la fois
# Pour plusieurs propriétés, répétez la commande
$cpuStats = Get-Process | Measure-Object -Property CPU -Sum -Average
$memStats = Get-Process | Measure-Object -Property WorkingSet -Sum -Average
```

---

## Group-Object - Regroupement et analyse

### 🎯 Concept et utilité

`Group-Object` **regroupe des objets** selon une propriété commune. C'est l'équivalent PowerShell d'un "GROUP BY" SQL. Utilisez-le pour :

- Catégoriser vos données
- Compter les occurrences de chaque valeur
- Identifier des patterns et distributions
- Analyser des logs ou des données métier

### 📝 Syntaxe de base

```powershell
Group-Object [-Property] <string[]> [-NoElement] [-AsHashTable] [-AsString]
```

### 📦 Regroupement simple

```powershell
# Regrouper les processus par nom
Get-Process | Group-Object Name

# Regrouper les services par statut
Get-Service | Group-Object Status

# Regrouper les fichiers par extension
Get-ChildItem | Group-Object Extension
```

**Résultat typique :**

```powershell
Count Name                      Group
----- ----                      -----
    5 chrome                    {System.Diagnostics.Process, System.Diagnostics.Process...}
    3 explorer                  {System.Diagnostics.Process, System.Diagnostics.Process...}
    2 notepad                   {System.Diagnostics.Process, System.Diagnostics.Process}
```

### 🔍 Propriétés des groupes

Chaque groupe créé par `Group-Object` possède **trois propriétés principales** :

|Propriété|Description|Type|
|---|---|---|
|**Name**|Valeur de la propriété de regroupement|string|
|**Count**|Nombre d'objets dans le groupe|int|
|**Group**|Collection des objets du groupe|Object[]|

```powershell
# Stocker les résultats
$groups = Get-Service | Group-Object Status

# Accéder aux propriétés
foreach ($group in $groups) {
    Write-Host "Statut : $($group.Name)"
    Write-Host "Nombre : $($group.Count)"
    Write-Host "Services : $($group.Group.Name -join ', ')"
    Write-Host "---"
}
```

> [!example] Exemple pratique
> 
> ```powershell
> # Compter les fichiers par extension
> $extensions = Get-ChildItem | Group-Object Extension
> 
> foreach ($ext in $extensions) {
>     Write-Host "$($ext.Name) : $($ext.Count) fichiers"
> }
> 
> # Résultat :
> # .txt : 12 fichiers
> # .ps1 : 8 fichiers
> # .log : 23 fichiers
> ```

### ⚡ -NoElement pour les performances

Le paramètre `-NoElement` améliore les **performances** en n'incluant pas la propriété `Group` (qui contient tous les objets).

```powershell
# Sans -NoElement : inclut tous les objets (plus lent)
Get-Process | Group-Object Name

# Avec -NoElement : seulement Name et Count (plus rapide)
Get-Process | Group-Object Name -NoElement
```

**Résultat avec -NoElement :**

```powershell
Count Name
----- ----
    5 chrome
    3 explorer
    2 notepad
```

> [!tip] Quand utiliser -NoElement Utilisez `-NoElement` quand vous avez besoin **uniquement du comptage**, pas des objets eux-mêmes.
> 
> - ✅ Pour afficher des statistiques
> - ✅ Pour générer des rapports de comptage
> - ❌ Si vous devez manipuler les objets groupés ensuite

### 🗂️ Regroupement sur propriétés multiples

Vous pouvez regrouper selon **plusieurs propriétés** simultanément.

```powershell
# Regrouper par statut ET type de démarrage
Get-Service | Group-Object Status, StartType

# Regrouper fichiers par extension et premier caractère
Get-ChildItem | Group-Object Extension, @{Expression={$_.Name[0]}}
```

**Résultat :**

```powershell
Count Name
----- ----
   15 Running, Automatic
   34 Stopped, Manual
    8 Running, Manual
   12 Stopped, Disabled
```

### 🔑 -AsHashTable et -AsString

Le paramètre `-AsHashTable` retourne un **hashtable** au lieu d'un tableau d'objets, permettant un **accès direct** par clé.

```powershell
# Création d'une hashtable
$servicesByStatus = Get-Service | Group-Object Status -AsHashTable

# Accès direct par clé
$runningServices = $servicesByStatus["Running"]
$stoppedServices = $servicesByStatus["Stopped"]

Write-Host "Services en cours : $($runningServices.Count)"
```

**-AsString** : Force les clés à être des **strings** (utile pour éviter des problèmes de typage).

```powershell
# Sans -AsString : les nombres sont des Int32
$groups = 1,2,3,1,2,3 | Group-Object -AsHashTable
$groups[1]  # Fonctionne

# Avec -AsString : conversion en strings
$groups = 1,2,3,1,2,3 | Group-Object -AsHashTable -AsString
$groups["1"]  # Doit utiliser une string
```

> [!warning] Limites de -AsHashTable
> 
> - Vous perdez l'accès aux propriétés `Name` et `Count`
> - La hashtable contient directement les **tableaux d'objets**
> 
> ```powershell
> $ht = Get-Service | Group-Object Status -AsHashTable
> $ht["Running"]  # Retourne le tableau d'objets directement
> $ht["Running"].Count  # Compte des éléments
> ```

### 📊 Exemples d'analyse de données

**Analyser les types de fichiers :**

```powershell
# Distribution des extensions
Get-ChildItem -Recurse | 
    Group-Object Extension | 
    Sort-Object Count -Descending |
    Select-Object Count, Name -First 10

# Résultat :
# Count Name
# ----- ----
#   234 .txt
#   156 .log
#    89 .ps1
```

**Analyser les événements Windows :**

```powershell
# Compter les événements par niveau (Erreur, Avertissement, Info)
Get-EventLog -LogName Application -Newest 1000 | 
    Group-Object EntryType | 
    Select-Object Count, Name
```

**Analyser les processus par entreprise :**

```powershell
# Regrouper les processus par éditeur
Get-Process | 
    Where-Object Company | 
    Group-Object Company -NoElement | 
    Sort-Object Count -Descending |
    Select-Object -First 5
```

**Distribution de la mémoire utilisée :**

```powershell
# Créer des tranches de mémoire
Get-Process | 
    Group-Object @{Expression={
        if ($_.WorkingSet -lt 10MB) { "< 10 Mo" }
        elseif ($_.WorkingSet -lt 50MB) { "10-50 Mo" }
        elseif ($_.WorkingSet -lt 100MB) { "50-100 Mo" }
        else { "> 100 Mo" }
    }} -NoElement |
    Sort-Object Name
```

### ⚡ Pièges courants

> [!warning] Regroupement sur des propriétés nulles Les valeurs `$null` sont regroupées ensemble sous une clé vide.
> 
> ```powershell
> # Exclure les valeurs nulles avant de regrouper
> Get-Process | Where-Object Company | Group-Object Company
> ```

> [!warning] Casse et regroupement Par défaut, `Group-Object` est **insensible à la casse**.
> 
> ```powershell
> "A", "a", "B", "b" | Group-Object
> # Résultat : 2 groupes (A+a, B+b)
> 
> # Pour tenir compte de la casse (nécessite une propriété calculée)
> "A", "a", "B", "b" | Group-Object @{Expression={$_}; CaseSensitive=$true}
> ```

### 💡 Astuces avancées

**Regroupement avec propriétés calculées complexes :**

```powershell
# Regrouper les fichiers par tranche de taille
Get-ChildItem | Group-Object @{
    Name = "TailleCategorie"
    Expression = {
        $kb = $_.Length / 1KB
        if ($kb -lt 1) { "Très petit (< 1 Ko)" }
        elseif ($kb -lt 100) { "Petit (1-100 Ko)" }
        elseif ($kb -lt 1024) { "Moyen (100 Ko - 1 Mo)" }
        else { "Grand (> 1 Mo)" }
    }
} -NoElement
```

**Créer un rapport de distribution :**

```powershell
# Rapport visuel de distribution
$groups = Get-Service | Group-Object Status -NoElement
$total = ($groups | Measure-Object -Property Count -Sum).Sum

foreach ($group in $groups) {
    $percentage = [math]::Round(($group.Count / $total) * 100, 1)
    $bar = "█" * [math]::Round($percentage / 2)
    Write-Host ("{0,-12} : {1,3} ({2,5}%) {3}" -f $group.Name, $group.Count, $percentage, $bar)
}

# Résultat :
# Running      :  89 ( 67.4%) ██████████████████████████████████
# Stopped      :  43 ( 32.6%) ████████████████
```

---

## Combinaisons pratiques

### 🔗 Enchaînements courants

Ces trois cmdlets sont souvent **combinés** pour des analyses complexes.

**Top 10 des processus les plus gourmands :**

```powershell
Get-Process | 
    Sort-Object WorkingSet -Descending | 
    Select-Object -First 10 Name, @{Name="Mémoire (Mo)"; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}
```

**Distribution et statistiques :**

```powershell
# Nombre de services par statut avec statistiques
Get-Service | 
    Group-Object Status | 
    ForEach-Object {
        [PSCustomObject]@{
            Statut = $_.Name
            Nombre = $_.Count
            Pourcentage = [math]::Round(($_.Count / (Get-Service).Count) * 100, 1)
        }
    } | 
    Sort-Object Nombre -Descending
```

**Analyse de fichiers complète :**

```powershell
# Rapport détaillé par extension
Get-ChildItem -Recurse | 
    Group-Object Extension | 
    ForEach-Object {
        $stats = $_.Group | Measure-Object -Property Length -Sum -Average -Maximum -Minimum
        
        [PSCustomObject]@{
            Extension = if ($_.Name) { $_.Name } else { "(sans extension)" }
            NombreFichiers = $_.Count
            TailleTotal = "$([math]::Round($stats.Sum / 1MB, 2)) Mo"
            TailleMoyenne = "$([math]::Round($stats.Average / 1KB, 2)) Ko"
            PlusGrand = "$([math]::Round($stats.Maximum / 1MB, 2)) Mo"
            PlusPetit = "$($stats.Minimum) octets"
        }
    } | 
    Sort-Object NombreFichiers -Descending
```

**Top des erreurs dans les logs :**

```powershell
# Identifier les erreurs les plus fréquentes
Get-Content app.log | 
    Where-Object {$_ -match "ERROR"} | 
    ForEach-Object {($_ -split "ERROR:")[1].Trim()} | 
    Group-Object -NoElement | 
    Sort-Object Count -Descending | 
    Select-Object -First 10
```

### 🎯 Cas d'usage professionnels

**Audit de sécurité - Utilisateurs connectés :**

```powershell
# Analyser les sessions utilisateurs
Get-Process -IncludeUserName | 
    Where-Object UserName | 
    Group-Object UserName | 
    ForEach-Object {
        $cpuTotal = ($_.Group | Measure-Object -Property CPU -Sum).Sum
        $memTotal = ($_.Group | Measure-Object -Property WorkingSet -Sum).Sum
        
        [PSCustomObject]@{
            Utilisateur = $_.Name
            NombreProcessus = $_.Count
            CPUTotal = [math]::Round($cpuTotal, 2)
            MémoireTotal = "$([math]::Round($memTotal / 1GB, 2)) Go"
        }
    } | 
    Sort-Object CPUTotal -Descending
```

**Analyse de performance système :**

```powershell
# Processus groupés par priorité avec stats
Get-Process | 
    Group-Object PriorityClass | 
    ForEach-Object {
        $stats = $_.Group | Measure-Object -Property WorkingSet -Sum -Average
        
        [PSCustomObject]@{
            Priorité = $_.Name
            Nombre = $_.Count
            MémoireTotale = "$([math]::Round($stats.Sum / 1GB, 2)) Go"
            MémoireMoyenne = "$([math]::Round($stats.Average / 1MB, 2)) Mo"
        }
    } | 
    Sort-Object Priorité
```

**Gestion de l'espace disque :**

```powershell
# Top 20 des plus gros dossiers
Get-ChildItem -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue | 
    ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum
        
        [PSCustomObject]@{
            Dossier = $_.FullName
            Taille = $size
            TailleMo = [math]::Round($size / 1MB, 2)
        }
    } | 
    Sort-Object Taille -Descending | 
    Select-Object -First 20 Dossier, @{Name="Taille"; Expression={"$($_.TailleMo) Mo"}}
```

> [!tip] Optimisation des pipelines longs Pour des analyses complexes sur de gros volumes :
> 
> 1. Filtrez tôt avec `Where-Object`
> 2. Utilisez `-NoElement` si vous n'avez pas besoin des objets
> 3. Limitez les résultats avec `Select-Object -First`
> 4. Stockez les résultats intermédiaires dans des variables

---

> [!info] Résumé des cmdlets
> 
> - **Sort-Object** : Trie vos données selon une ou plusieurs propriétés
> - **Measure-Object** : Calcule des statistiques (comptage, somme, moyenne, min/max)
> - **Group-Object** : Regroupe les objets par propriété pour analyser la distribution
> 
> Ces trois cmdlets forment le **trio d'analyse** indispensable en PowerShell !

---

## 📌 Tableau récapitulatif

### Sort-Object

|Paramètre|Description|Exemple|
|---|---|---|
|`-Property`|Propriété(s) de tri|`Sort-Object Name`|
|`-Descending`|Tri décroissant|`Sort-Object CPU -Descending`|
|`-Unique`|Élimine les doublons|`Sort-Object Extension -Unique`|
|`-CaseSensitive`|Sensible à la casse|`Sort-Object Name -CaseSensitive`|
|Propriété calculée|Tri personnalisé|`Sort-Object @{Expression={$_.Length}}`|

### Measure-Object

|Paramètre|Description|Exemple|
|---|---|---|
|`-Property`|Propriété à mesurer|`Measure-Object -Property Length`|
|`-Sum`|Calcule la somme|`Measure-Object -Property Length -Sum`|
|`-Average`|Calcule la moyenne|`Measure-Object -Property CPU -Average`|
|`-Minimum`|Valeur minimale|`Measure-Object -Property Length -Minimum`|
|`-Maximum`|Valeur maximale|`Measure-Object -Property Length -Maximum`|
|`-Line`|Compte les lignes|`Measure-Object -Line`|
|`-Word`|Compte les mots|`Measure-Object -Word`|
|`-Character`|Compte les caractères|`Measure-Object -Character`|

### Group-Object

|Paramètre|Description|Exemple|
|---|---|---|
|`-Property`|Propriété de regroupement|`Group-Object Status`|
|`-NoElement`|Sans la collection Group|`Group-Object Status -NoElement`|
|`-AsHashTable`|Retourne une hashtable|`Group-Object Status -AsHashTable`|
|`-AsString`|Clés en string|`Group-Object -AsHashTable -AsString`|

---

## 🎓 Bonnes pratiques

> [!tip] Optimisation des performances
> 
> 1. **Filtrez avant de trier** : `Where-Object` avant `Sort-Object` réduit les données à traiter
> 2. **Utilisez -NoElement** : Quand vous n'avez besoin que du comptage avec `Group-Object`
> 3. **Limitez les résultats** : Utilisez `Select-Object -First` après le tri plutôt que de trier toute la collection
> 4. **Évitez les propriétés calculées complexes** : Elles sont évaluées pour chaque objet
> 
> ```powershell
> # ❌ Moins efficace
> Get-Process | Sort-Object WorkingSet -Descending | Where-Object {$_.WorkingSet -gt 100MB}
> 
> # ✅ Plus efficace
> Get-Process | Where-Object {$_.WorkingSet -gt 100MB} | Sort-Object WorkingSet -Descending
> ```

> [!tip] Lisibilité et maintenance
> 
> - Utilisez des **propriétés calculées nommées** pour la clarté
> - **Stockez les résultats** dans des variables pour éviter les calculs répétés
> - **Commentez** les expressions complexes
> 
> ```powershell
> # Propriété calculée bien nommée
> Get-ChildItem | Sort-Object @{
>     Name = "TailleEnMo"
>     Expression = {$_.Length / 1MB}
>     Descending = $true
> }
> ```

> [!warning] Erreurs fréquentes à éviter
> 
> - **Ne pas spécifier -Property** avec Measure-Object quand nécessaire
> - **Trier des nombres stockés comme texte** sans conversion
> - **Oublier que Sort-Object -Unique trie** avant de dédupliquer
> - **Utiliser Group-Object sans -NoElement** sur de gros volumes quand ce n'est pas nécessaire
> - **Ne pas gérer les valeurs $null** dans les tris et regroupements

---

## 🚀 Aller plus loin

### Analyse de logs sophistiquée

```powershell
# Analyser un fichier de log avec toutes les techniques
$logAnalysis = Get-Content application.log | 
    Where-Object {$_ -match "\[(ERROR|WARNING|INFO)\]"} |
    ForEach-Object {
        if ($_ -match "\[(?<Level>ERROR|WARNING|INFO)\] (?<Timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) - (?<Message>.+)") {
            [PSCustomObject]@{
                Level = $Matches.Level
                Timestamp = [DateTime]$Matches.Timestamp
                Message = $Matches.Message
                Hour = ([DateTime]$Matches.Timestamp).Hour
            }
        }
    }

# Distribution par niveau
Write-Host "`n=== Distribution par niveau ===" -ForegroundColor Cyan
$logAnalysis | Group-Object Level -NoElement | Sort-Object Count -Descending

# Distribution par heure
Write-Host "`n=== Distribution par heure ===" -ForegroundColor Cyan
$logAnalysis | Group-Object Hour -NoElement | Sort-Object Name

# Top 5 des erreurs
Write-Host "`n=== Top 5 des erreurs ===" -ForegroundColor Cyan
$logAnalysis | 
    Where-Object Level -eq "ERROR" | 
    Group-Object Message -NoElement | 
    Sort-Object Count -Descending | 
    Select-Object -First 5

# Statistiques temporelles
Write-Host "`n=== Statistiques temporelles ===" -ForegroundColor Cyan
$timeStats = $logAnalysis | Measure-Object -Property Hour -Average -Minimum -Maximum
Write-Host "Heure moyenne : $([math]::Round($timeStats.Average, 2))h"
Write-Host "Première entrée : $($timeStats.Minimum)h"
Write-Host "Dernière entrée : $($timeStats.Maximum)h"
```

### Dashboard système interactif

```powershell
# Créer un rapport système complet
function Get-SystemDashboard {
    $report = @{}
    
    # Processus
    Write-Host "Analyse des processus..." -ForegroundColor Yellow
    $processes = Get-Process
    $report.ProcessCount = $processes.Count
    $report.TopProcesses = $processes | 
        Sort-Object WorkingSet -Descending | 
        Select-Object -First 5 Name, @{N="Mémoire(Mo)";E={[math]::Round($_.WorkingSet/1MB,2)}}
    
    # Services
    Write-Host "Analyse des services..." -ForegroundColor Yellow
    $services = Get-Service
    $report.ServiceStats = $services | Group-Object Status -NoElement
    
    # Disque
    Write-Host "Analyse du disque..." -ForegroundColor Yellow
    $files = Get-ChildItem C:\Users -Recurse -File -ErrorAction SilentlyContinue
    $report.FileCount = $files.Count
    $report.TotalSize = [math]::Round(($files | Measure-Object -Property Length -Sum).Sum / 1GB, 2)
    $report.TopExtensions = $files | 
        Group-Object Extension -NoElement | 
        Sort-Object Count -Descending | 
        Select-Object -First 5
    
    # Affichage
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║      DASHBOARD SYSTÈME - $(Get-Date -Format 'HH:mm')      ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    
    Write-Host "`n📊 Processus" -ForegroundColor Green
    Write-Host "   Total : $($report.ProcessCount)"
    Write-Host "   Top 5 :"
    $report.TopProcesses | Format-Table -AutoSize
    
    Write-Host "`n🔧 Services" -ForegroundColor Green
    foreach ($stat in $report.ServiceStats) {
        Write-Host "   $($stat.Name) : $($stat.Count)"
    }
    
    Write-Host "`n💾 Disque (C:\Users)" -ForegroundColor Green
    Write-Host "   Fichiers : $($report.FileCount)"
    Write-Host "   Taille totale : $($report.TotalSize) Go"
    Write-Host "   Top 5 extensions :"
    $report.TopExtensions | Format-Table -AutoSize
}

# Exécuter le dashboard
Get-SystemDashboard
```

### Analyse comparative

```powershell
# Comparer deux états du système
function Compare-SystemState {
    param(
        [string]$BeforeSnapshot,
        [string]$AfterSnapshot
    )
    
    $before = Import-Clixml $BeforeSnapshot
    $after = Import-Clixml $AfterSnapshot
    
    Write-Host "`n=== ANALYSE COMPARATIVE ===" -ForegroundColor Cyan
    
    # Différence de processus
    $newProcesses = Compare-Object -ReferenceObject $before.Processes -DifferenceObject $after.Processes -Property Name
    Write-Host "`nNouveaux processus : $($newProcesses.Count)"
    
    # Différence de services
    $serviceChanges = Compare-Object -ReferenceObject $before.Services -DifferenceObject $after.Services -Property Name, Status
    Write-Host "Changements de services : $($serviceChanges.Count)"
    
    # Analyse mémoire
    $memBefore = ($before.Processes | Measure-Object -Property WorkingSet -Sum).Sum
    $memAfter = ($after.Processes | Measure-Object -Property WorkingSet -Sum).Sum
    $memDiff = [math]::Round(($memAfter - $memBefore) / 1GB, 2)
    
    Write-Host "`nUtilisation mémoire : $(if($memDiff -gt 0){'+'})$memDiff Go"
}

# Créer un snapshot
function New-SystemSnapshot {
    param([string]$Path)
    
    $snapshot = @{
        Timestamp = Get-Date
        Processes = Get-Process | Select-Object Name, WorkingSet, CPU
        Services = Get-Service | Select-Object Name, Status
    }
    
    $snapshot | Export-Clixml $Path
    Write-Host "Snapshot créé : $Path" -ForegroundColor Green
}

# Usage
# New-SystemSnapshot -Path "C:\Temp\before.xml"
# # ... faire des modifications ...
# New-SystemSnapshot -Path "C:\Temp\after.xml"
# Compare-SystemState -BeforeSnapshot "C:\Temp\before.xml" -AfterSnapshot "C:\Temp\after.xml"
```

---

## 🎯 Points clés à retenir

> [!success] Maîtrise des cmdlets
> 
> - **Sort-Object** organise vos données pour une meilleure lisibilité et analyse
> - **Measure-Object** fournit des statistiques essentielles en une commande
> - **Group-Object** révèle les patterns et distributions dans vos données
> - Ces trois cmdlets **se combinent naturellement** dans le pipeline PowerShell
> - L'ordre des cmdlets dans le pipeline **impacte les performances**
> - Les propriétés calculées offrent une **flexibilité maximale** pour des analyses complexes

---

_Ce cours couvre l'ensemble des fonctionnalités de Sort-Object, Measure-Object et Group-Object pour vous permettre de devenir autonome dans l'analyse de données avec PowerShell._ 🚀