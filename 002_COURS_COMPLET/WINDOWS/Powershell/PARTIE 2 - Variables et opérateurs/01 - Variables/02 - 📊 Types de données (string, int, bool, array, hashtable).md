

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

## 🔤 String (chaînes de caractères)

### Pourquoi c'est important

Les chaînes de caractères sont omniprésentes en PowerShell : noms de fichiers, messages, logs, commandes dynamiques. Maîtriser leurs subtilités permet d'écrire du code plus lisible, performant et moins sujet aux erreurs.

### Guillemets simples vs doubles

PowerShell fait une distinction fondamentale entre les deux types de guillemets :

```powershell
# Guillemets simples : littéral (pas d'interprétation)
$name = 'Alice'
$message1 = 'Bonjour $name'
Write-Host $message1  # Affiche : Bonjour $name

# Guillemets doubles : interprétation des variables
$message2 = "Bonjour $name"
Write-Host $message2  # Affiche : Bonjour Alice
```

> [!tip] Quand utiliser quoi ?
> 
> - **Guillemets simples** : par défaut, pour les chaînes statiques (plus performant)
> - **Guillemets doubles** : quand vous avez besoin d'interpolation de variables ou de caractères d'échappement

### Interpolation de variables

L'interpolation permet d'insérer directement des variables et même des expressions dans une chaîne :

```powershell
$user = "Bob"
$age = 30

# Interpolation simple
$info = "L'utilisateur $user a $age ans"

# Interpolation avec expressions (utiliser $(...))
$info2 = "Dans 5 ans, $user aura $($age + 5) ans"

# Accès aux propriétés d'objets
$file = Get-Item "C:\temp\test.txt"
$message = "Le fichier $($file.Name) fait $($file.Length) octets"
```

> [!warning] Piège courant
> 
> ```powershell
> # ❌ Ceci ne fonctionne pas comme attendu
> $result = "2 + 2 = $2 + 2"  # Affiche : 2 + 2 = $2 + 2
> 
> # ✅ Utiliser $(...) pour les expressions
> $result = "2 + 2 = $(2 + 2)"  # Affiche : 2 + 2 = 4
> ```

### Caractères d'échappement

PowerShell utilise le backtick (`` ` ``) comme caractère d'échappement :

```powershell
# Caractères spéciaux courants
$tab = "Colonne1`tColonne2"        # Tabulation
$newline = "Ligne 1`nLigne 2"       # Nouvelle ligne
$quote = "Il a dit `"Bonjour`""     # Guillemets doubles
$backslash = "Chemin: C:`\Users"    # Empêcher interprétation

# Autres caractères d'échappement utiles
$return = "Texte`r"                 # Retour chariot
$formfeed = "Page`f"                # Saut de page
$backtick = "Un backtick: ``"       # Backtick littéral
```

> [!info] Alternative aux caractères d'échappement Pour les chemins Windows, utilisez les guillemets simples ou les chaînes brutes :
> 
> ```powershell
> $path1 = 'C:\Users\Documents'      # Plus simple
> $path2 = "C:\Users\Documents"      # Fonctionne aussi
> ```

### Here-strings (chaînes multi-lignes)

Les here-strings permettent de gérer facilement du texte multi-lignes :

```powershell
# Here-string avec guillemets simples (littéral)
$script1 = @'
Ceci est du texte
    avec indentation préservée
$variables ne sont pas interprétées
"guillemets" et 'apostrophes' sans échappement
'@

# Here-string avec guillemets doubles (avec interpolation)
$user = "Admin"
$script2 = @"
Bonjour $user,
Voici votre rapport :
    - Connexions : $($connections.Count)
    - Statut : Actif
"@

# Cas d'usage typique : requêtes SQL
$query = @"
SELECT *
FROM Users
WHERE Department = 'IT'
  AND Active = 1
ORDER BY LastName
"@
```

> [!tip] Règles des here-strings
> 
> - Les délimiteurs `@'` et `'@` (ou `@"` et `"@`) doivent être seuls sur leur ligne
> - Le délimiteur de fermeture doit être en début de ligne (pas d'espaces avant)
> - Parfait pour : scripts SQL, JSON, XML, HTML, code embarqué

### Méthodes de manipulation

Les strings en PowerShell sont des objets .NET `System.String` avec de nombreuses méthodes :

```powershell
$text = "  PowerShell est Puissant  "

# Manipulation de casse
$text.ToUpper()           # "  POWERSHELL EST PUISSANT  "
$text.ToLower()           # "  powershell est puissant  "

# Suppression d'espaces
$text.Trim()              # "PowerShell est Puissant"
$text.TrimStart()         # "PowerShell est Puissant  "
$text.TrimEnd()           # "  PowerShell est Puissant"

# Remplacement
$text.Replace("Puissant", "Formidable")
$text.Replace(" ", "")    # Supprime tous les espaces

# Recherche
$text.Contains("Shell")   # $true
$text.StartsWith("  P")   # $true
$text.EndsWith("t  ")     # $true
$text.IndexOf("Shell")    # Position : 8

# Extraction
$text.Substring(2, 10)    # Extrait 10 caractères à partir de l'index 2
$text.Split(" ")          # Divise en tableau : @("", "", "PowerShell", "est", "Puissant", "", "")

# Longueur
$text.Length              # 28
```

> [!example] Exemple pratique : nettoyer un nom de fichier
> 
> ```powershell
> $filename = "  Mon Document (copie).txt  "
> $clean = $filename.Trim().Replace(" ", "_").Replace("(", "").Replace(")", "")
> # Résultat : "Mon_Document_copie.txt"
> 
> # Ou en utilisant -replace (regex)
> $clean2 = $filename.Trim() -replace '[\s\(\)]', '_'
> ```

> [!warning] Attention à l'immutabilité Les strings sont **immuables** en .NET. Chaque méthode retourne une **nouvelle** chaîne :
> 
> ```powershell
> $text = "bonjour"
> $text.ToUpper()    # Retourne "BONJOUR" mais ne modifie pas $text
> Write-Host $text   # Affiche toujours : bonjour
> 
> # ✅ Bon usage
> $text = $text.ToUpper()  # Réassigner pour conserver le changement
> ```

---

## 🔢 Int et types numériques

### Pourquoi c'est important

PowerShell gère automatiquement les types numériques, mais comprendre leurs différences est crucial pour éviter les erreurs de calcul, les dépassements de capacité et optimiser la mémoire.

### Types numériques disponibles

|Type|Alias|Plage|Usage typique|
|---|---|---|---|
|`[int]` ou `[int32]`|-|-2,147,483,648 à 2,147,483,647|Nombres entiers standards|
|`[long]` ou `[int64]`|-|-9.2×10¹⁸ à 9.2×10¹⁸|Grands nombres entiers|
|`[double]`|-|±5.0×10⁻³²⁴ à ±1.7×10³⁰⁸|Nombres à virgule flottante|
|`[decimal]`|-|±1.0×10⁻²⁸ à ±7.9×10²⁸|Calculs financiers précis|
|`[float]` ou `[single]`|-|±1.5×10⁻⁴⁵ à ±3.4×10³⁸|Calculs moins précis|
|`[byte]`|-|0 à 255|Données binaires|

### Déclaration et typage

```powershell
# PowerShell infère automatiquement le type
$a = 42                 # [int]
$b = 42.5               # [double]
$c = 42L                # [long] (suffixe L)
$d = 42.5d              # [decimal] (suffixe d)

# Typage explicite (cast)
[int]$age = 30
[double]$price = 19.99
[decimal]$precise = 0.1

# Vérifier le type
$a.GetType().Name       # Int32
```

> [!tip] Quand typer explicitement ?
> 
> - Pour forcer un type spécifique (éviter conversions automatiques)
> - Dans les fonctions (paramètres typés)
> - Pour la documentation du code
> - Quand la précision est critique

### Opérations arithmétiques de base

```powershell
# Opérateurs standards
$sum = 10 + 5           # Addition : 15
$diff = 10 - 5          # Soustraction : 5
$product = 10 * 5       # Multiplication : 50
$quotient = 10 / 5      # Division : 2
$remainder = 10 % 3     # Modulo (reste) : 1

# Opérateurs d'assignation combinés
$x = 10
$x += 5                 # $x = $x + 5 → 15
$x -= 3                 # $x = $x - 3 → 12
$x *= 2                 # $x = $x * 2 → 24
$x /= 4                 # $x = $x / 4 → 6
$x %= 4                 # $x = $x % 4 → 2

# Incrémentation/décrémentation
$count = 0
$count++                # Post-incrémentation : 1
++$count                # Pré-incrémentation : 2
$count--                # Post-décrémentation : 1
```

### Conversions et précision

```powershell
# Conversion implicite
$result = 10 / 3        # 3.33333333333333 (double)
$result = 10 / 4        # 2.5 (double)

# Conversion explicite
[int](10 / 3)           # 3 (troncature)
[Math]::Round(10/3, 2)  # 3.33 (arrondi à 2 décimales)

# Problème de précision avec double
$a = 0.1
$b = 0.2
$c = $a + $b            # 0.30000000000000004 (imprécision binaire !)

# Solution : utiliser decimal pour la précision
[decimal]$a = 0.1
[decimal]$b = 0.2
$c = $a + $b            # 0.3 (précis)
```

> [!warning] Piège : division d'entiers
> 
> ```powershell
> # ❌ Piège classique
> [int]$a = 10
> [int]$b = 3
> $result = $a / $b     # 3.33... (PowerShell convertit en double)
> 
> # Si vous voulez une division entière explicite
> [int]$result = $a / $b  # 3 (troncature)
> 
> # Ou utiliser [Math]::Floor() / Ceiling()
> [Math]::Floor($a / $b)  # 3
> ```

### Fonctions mathématiques utiles

```powershell
# Classe [Math] pour opérations avancées
[Math]::Abs(-42)        # Valeur absolue : 42
[Math]::Pow(2, 8)       # Puissance : 256
[Math]::Sqrt(144)       # Racine carrée : 12
[Math]::Round(3.7)      # Arrondi : 4
[Math]::Floor(3.7)      # Arrondi inf : 3
[Math]::Ceiling(3.2)    # Arrondi sup : 4
[Math]::Max(10, 20)     # Maximum : 20
[Math]::Min(10, 20)     # Minimum : 10

# Valeurs spéciales
[Math]::PI              # 3.14159265358979
[Math]::E               # 2.71828182845905
```

> [!example] Exemple pratique : calculer une taille en Go
> 
> ```powershell
> $sizeBytes = 5368709120
> $sizeGB = [Math]::Round($sizeBytes / 1GB, 2)
> Write-Host "Taille : $sizeGB Go"  # Taille : 5 Go
> ```

---

## ✅ Bool (booléens)

### Pourquoi c'est important

Les booléens sont au cœur de la logique conditionnelle. Comprendre comment PowerShell évalue les conditions permet d'écrire du code robuste et d'éviter des bugs subtils.

### Valeurs booléennes

```powershell
# Les deux seules valeurs booléennes
$true                   # Vrai
$false                  # Faux

# Déclaration explicite
[bool]$isActive = $true
[bool]$hasError = $false

# Résultat de comparaisons
$result = 5 -gt 3       # $true
$result = "A" -eq "B"   # $false
```

### Valeurs truthy et falsy

PowerShell convertit automatiquement les valeurs en booléen dans un contexte conditionnel :

```powershell
# Valeurs FALSY (évaluées comme $false)
if ($null) { }              # $null → $false
if (0) { }                  # 0 → $false
if ("") { }                 # Chaîne vide → $false
if (@()) { }                # Tableau vide → $false

# Valeurs TRUTHY (évaluées comme $true)
if (1) { }                  # Nombre non-zéro → $true
if (-5) { }                 # Nombre négatif → $true
if ("texte") { }            # Chaîne non-vide → $true
if (@(1, 2)) { }            # Tableau non-vide → $true
if (@{}) { }                # Hashtable vide → $true (attention !)
```

> [!warning] Pièges courants
> 
> ```powershell
> # ❌ Hashtable vide est TRUTHY
> $hash = @{}
> if ($hash) {
>     Write-Host "Ceci s'affiche !"  # S'exécute
> }
> 
> # ✅ Vérifier explicitement le contenu
> if ($hash.Count -gt 0) {
>     Write-Host "Hashtable contient des éléments"
> }
> 
> # ❌ Chaîne "0" est TRUTHY
> $value = "0"
> if ($value) {
>     Write-Host "Ceci s'affiche !"  # S'exécute car c'est une chaîne non-vide
> }
> 
> # ✅ Convertir en nombre d'abord
> if ([int]$value -ne 0) {
>     Write-Host "Non-zéro"
> }
> ```

### Opérateurs logiques

```powershell
# AND logique : vrai si les deux sont vrais
$a = $true -and $true   # $true
$b = $true -and $false  # $false

# OR logique : vrai si au moins un est vrai
$c = $true -or $false   # $true
$d = $false -or $false  # $false

# NOT logique : inverse la valeur
$e = -not $true         # $false
$f = !$false            # $true (! est un alias de -not)

# XOR logique : vrai si exactement un est vrai
$g = $true -xor $false  # $true
$h = $true -xor $true   # $false
```

### Court-circuit d'évaluation

PowerShell utilise l'évaluation en court-circuit pour optimiser les performances :

```powershell
# -and : arrête dès qu'une condition est fausse
$result = $false -and (1/0)  # Pas d'erreur ! (1/0 n'est pas évalué)

# -or : arrête dès qu'une condition est vraie
$result = $true -or (1/0)    # Pas d'erreur ! (1/0 n'est pas évalué)

# Exemple pratique
if ($user -ne $null -and $user.IsActive) {
    # Si $user est $null, $user.IsActive n'est jamais évalué
    # Évite une erreur "Cannot index into a null array"
}
```

> [!tip] Ordre des conditions Placez les conditions les plus rapides et les plus susceptibles d'échouer en premier :
> 
> ```powershell
> # ✅ Bon ordre (rapide et sûr)
> if ($cache -ne $null -and $cache.ContainsKey($key)) {
>     # Vérifie d'abord l'existence de $cache
> }
> 
> # ❌ Mauvais ordre (risque d'erreur)
> if ($cache.ContainsKey($key) -and $cache -ne $null) {
>     # Erreur si $cache est $null !
> }
> ```

### Opérateurs de comparaison retournant des booléens

```powershell
# Égalité / inégalité
5 -eq 5                 # $true (égal)
5 -ne 3                 # $true (non égal)

# Comparaisons numériques
10 -gt 5                # $true (greater than)
10 -ge 10               # $true (greater or equal)
3 -lt 5                 # $true (less than)
3 -le 3                 # $true (less or equal)

# Comparaisons de chaînes (insensible à la casse par défaut)
"ABC" -eq "abc"         # $true
"ABC" -ceq "abc"        # $false (case-sensitive avec 'c')

# Correspondance de motifs
"PowerShell" -like "*Shell"      # $true
"PowerShell" -match "^Power"     # $true (regex)

# Tests de contenu
@(1,2,3) -contains 2    # $true
2 -in @(1,2,3)          # $true
```

> [!example] Exemple pratique : validation complexe
> 
> ```powershell
> function Test-ValidUser {
>     param($user)
>     
>     return ($user -ne $null) -and 
>            ($user.Name -ne "") -and 
>            ($user.Age -ge 18) -and 
>            ($user.Email -match '^[\w\.-]+@[\w\.-]+\.\w+$')
> }
> ```

---

## 📦 Array (tableaux)

### Pourquoi c'est important

Les tableaux sont essentiels pour gérer des collections d'éléments. Comprendre leurs particularités en PowerShell (notamment leur immutabilité) permet d'éviter des pièges de performance et d'écrire du code efficace.

### Création de tableaux

```powershell
# Tableau vide
$empty = @()

# Tableau avec éléments
$numbers = @(1, 2, 3, 4, 5)
$names = @("Alice", "Bob", "Charlie")

# Syntaxe raccourcie (sans @())
$colors = "Red", "Green", "Blue"

# Tableau mixte (types différents)
$mixed = @(42, "texte", $true, (Get-Date))

# Tableau d'un seul élément (force le type tableau)
$single = @(1)          # Tableau avec 1 élément
$notArray = 1           # Juste un nombre (pas un tableau)

# Tableau via range
$range = 1..10          # @(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
$letters = 'A'..'E'     # @('A', 'B', 'C', 'D', 'E')
```

> [!tip] Forcer un tableau à un seul élément Utilisez `@()` pour garantir qu'une variable est toujours un tableau :
> 
> ```powershell
> $result = @(Get-Process | Where-Object {$_.Name -eq "chrome"})
> # Si 0 résultat : tableau vide
> # Si 1 résultat : tableau à 1 élément
> # Si N résultats : tableau à N éléments
> ```

### Accès aux éléments (index)

```powershell
$fruits = @("Pomme", "Banane", "Cerise", "Datte", "Fraise")

# Index positifs (commence à 0)
$fruits[0]              # "Pomme" (premier)
$fruits[2]              # "Cerise"

# Index négatifs (depuis la fin)
$fruits[-1]             # "Fraise" (dernier)
$fruits[-2]             # "Datte" (avant-dernier)

# Plages d'index
$fruits[1..3]           # @("Banane", "Cerise", "Datte")
$fruits[0,2,4]          # @("Pomme", "Cerise", "Fraise")

# Modification d'un élément
$fruits[1] = "Mangue"
# $fruits → @("Pomme", "Mangue", "Cerise", "Datte", "Fraise")
```

> [!warning] Index hors limites
> 
> ```powershell
> $arr = @(1, 2, 3)
> $arr[10]              # Retourne $null (pas d'erreur)
> $arr[10] = 5          # Erreur ! Ne peut pas assigner hors limites
> ```

### Ajout d'éléments (+=)

```powershell
$list = @(1, 2, 3)

# Ajout d'un élément
$list += 4              # @(1, 2, 3, 4)

# Ajout de plusieurs éléments
$list += 5, 6, 7        # @(1, 2, 3, 4, 5, 6, 7)

# Concaténation de tableaux
$more = @(8, 9)
$list += $more          # @(1, 2, 3, 4, 5, 6, 7, 8, 9)
```

> [!warning] Performance : += crée un NOUVEAU tableau L'opérateur `+=` est **très inefficace** pour de nombreux ajouts :
> 
> ```powershell
> # ❌ Mauvaise pratique (lent pour beaucoup d'éléments)
> $result = @()
> foreach ($i in 1..10000) {
>     $result += $i   # Crée 10 000 nouveaux tableaux !
> }
> 
> # ✅ Bonne pratique : utiliser ArrayList ou List<T>
> $result = [System.Collections.ArrayList]@()
> foreach ($i in 1..10000) {
>     [void]$result.Add($i)  # Beaucoup plus rapide
> }
> 
> # ✅ Ou laisser PowerShell gérer
> $result = 1..10000  # Crée directement le tableau
> ```

### Propriétés .Count et .Length

```powershell
$data = @(1, 2, 3, 4, 5)

# Nombre d'éléments
$data.Count             # 5
$data.Length            # 5 (identique à Count pour les tableaux)

# Vérification de tableau vide
if ($data.Count -eq 0) {
    Write-Host "Tableau vide"
}

# Piège avec tableau null
$null.Count             # $null (pas 0 !)
```

> [!tip] Vérification sûre d'un tableau vide
> 
> ```powershell
> # ✅ Méthode robuste
> if (-not $array -or $array.Count -eq 0) {
>     Write-Host "Null ou vide"
> }
> 
> # ✅ Alternative
> if (($array | Measure-Object).Count -eq 0) {
>     Write-Host "Vide"
> }
> ```

### Tableaux multidimensionnels

```powershell
# Tableau 2D (matrice)
$matrix = @(
    @(1, 2, 3),
    @(4, 5, 6),
    @(7, 8, 9)
)

# Accès aux éléments
$matrix[0][0]           # 1
$matrix[1][2]           # 6
$matrix[2][1]           # 8

# Modification
$matrix[0][1] = 99

# Parcours
foreach ($row in $matrix) {
    foreach ($cell in $row) {
        Write-Host $cell -NoNewline
    }
    Write-Host ""
}

# Tableau 2D typé .NET (plus performant)
$typed = New-Object 'int[,]' 3,3
$typed[0,0] = 1
$typed[1,1] = 5
```

> [!example] Exemple pratique : grille de jeu
> 
> ```powershell
> # Créer une grille 3x3 pour un jeu
> $board = @(
>     @(' ', ' ', ' '),
>     @(' ', ' ', ' '),
>     @(' ', ' ', ' ')
> )
> 
> # Placer un symbole
> $board[1][1] = 'X'
> 
> # Afficher la grille
> foreach ($row in $board) {
>     Write-Host ($row -join '|')
> }
> ```

### ArrayList pour performances

Quand vous devez ajouter/supprimer fréquemment des éléments, utilisez `ArrayList` :

```powershell
# Création
$list = [System.Collections.ArrayList]@()

# Ajout (retourne l'index, donc on utilise [void])
[void]$list.Add("Item1")
[void]$list.Add("Item2")
[void]$list.AddRange(@("Item3", "Item4"))

# Suppression
$list.Remove("Item2")           # Supprime par valeur
$list.RemoveAt(0)               # Supprime par index

# Insertion
$list.Insert(1, "InsertedItem")

# Accès comme un tableau normal
$list[0]
$list.Count

# Tri et recherche
$list.Sort()
$list.Contains("Item3")         # $true
$list.IndexOf("Item3")          # Position
```

> [!tip] Comparaison de performances
> 
> ```powershell
> # Test : 10 000 ajouts
> 
> # Array avec += : ~15 secondes
> Measure-Command {
>     $arr = @()
>     1..10000 | ForEach-Object { $arr += $_ }
> }
> 
> # ArrayList : ~0.02 secondes (750x plus rapide !)
> Measure-Command {
>     $list = [System.Collections.ArrayList]@()
>     1..10000 | ForEach-Object { [void]$list.Add($_) }
> }
> 
> # List<T> : ~0.01 secondes (encore plus rapide)
> Measure-Command {
>     $list = [System.Collections.Generic.List[int]]::new()
>     1..10000 | ForEach-Object { $list.Add($_) }
> }
> ```

### Méthodes utiles sur les tableaux

```powershell
$numbers = @(5, 2, 8, 1, 9, 3)

# Tri
$sorted = $numbers | Sort-Object        # @(1, 2, 3, 5, 8, 9)

# Filtrage
$filtered = $numbers | Where-Object { $_ -gt 5 }  # @(8, 9)

# Transformation
$doubled = $numbers | ForEach-Object { $_ * 2 }

# Recherche
$numbers -contains 8                    # $true
5 -in $numbers                          # $true

# Statistiques
($numbers | Measure-Object -Sum).Sum    # 28
($numbers | Measure-Object -Average).Average  # 4.66...
($numbers | Measure-Object -Maximum).Maximum  # 9

# Jointure en chaîne
$numbers -join ", "                     # "5, 2, 8, 1, 9, 3"
$numbers -join ""                       # "528193"

# Sélection unique
$dup = @(1, 2, 2, 3, 3, 3)
$unique = $dup | Select-Object -Unique  # @(1, 2, 3)
```

---

## 🗂️ Hashtable (tables de hachage)

### Pourquoi c'est important

Les hashtables permettent d'associer des clés à des valeurs, offrant un accès ultra-rapide aux données. Elles sont essentielles pour structurer des configurations, créer des lookups, et passer des paramètres nommés.

### Création de hashtables

```powershell
# Hashtable vide
$empty = @{}

# Hashtable avec des paires clé-valeur
$user = @{
    Name = "Alice"
    Age = 30
    City = "Paris"
}

# Hashtable sur plusieurs lignes (plus lisible)
$config = @{
    Server   = "db.example.com"
    Port     = 5432
    Database = "Production"
    Timeout  = 30
}

# Clés avec espaces ou caractères spéciaux
$data = @{
    "First Name" = "Bob"
    "E-mail" = "bob@example.com"
    "Score-2024" = 95
}
```

> [!info] Types de clés
> 
> - Les clés sont généralement des chaînes (strings)
> - Peuvent contenir espaces si entre guillemets
> - Sensibles à la casse par défaut (mais voir note ci-dessous)

### Paires clé-valeur

```powershell
$person = @{
    Name = "Charlie"
    Age = 25
    IsActive = $true
    Skills = @("PowerShell", "Python", "SQL")
    Address = @{
        Street = "123 Main St"
        City = "Lyon"
    }
}
```

> [!tip] Les valeurs peuvent être de n'importe quel type
> 
> - Nombres, chaînes, booléens
> - Tableaux
> - Autres hashtables (hashtables imbriquées)
> - Objets, dates, etc.

### Accès aux éléments

```powershell
$user = @{
    Name = "Alice"
    Age = 30
    City = "Paris"
}

# Notation par point (préférée quand possible)
$user.Name              # "Alice"
$user.Age               # 30

# Notation par crochets (nécessaire avec espaces/caractères spéciaux)
$user["Name"]           # "Alice"
$user["City"]           # "Paris"

# Clés avec espaces
$data = @{"First Name" = "Bob"}
$data."First Name"      # "Bob"
$data["First Name"]     # "Bob"

# Accès à une clé inexistante
$user.Country           # $null (pas d'erreur)
```

> [!warning] Sensibilité à la casse
> 
> ```powershell
> $hash = @{Name = "Alice"}
> 
> # Par défaut, PowerShell crée des hashtables INSENSIBLES à la casse
> $hash.name              # "Alice" (fonctionne)
> $hash.NAME              # "Alice" (fonctionne)
> 
> # Pour créer une hashtable sensible à la casse
> $caseSensitive = New-Object System.Collections.Hashtable
> $caseSensitive.Add("Name", "Alice")
> $caseSensitive.Add("name", "Bob")
> $caseSensitive.Name     # "Alice"
> $caseSensitive.name     # "Bob"
> ```

### Ajout et suppression de clés

```powershell
$config = @{
    Server = "localhost"
    Port = 8080
}

# Ajout de nouvelles clés
$config.Database = "TestDB"
$config["Timeout"] = 30
$config.Add("Retry", 3)

# Modification de valeurs existantes
$config.Port = 9090
$config["Server"] = "192.168.1.100"

# Suppression de clés
$config.Remove("Timeout")

# Vider toute la hashtable
$config.Clear()
```

> [!tip] Différence entre .Add() et affectation directe
> 
> ```powershell
> $hash = @{Key1 = "Value1"}
> 
> # ✅ Affectation directe : écrase si existe, crée sinon
> $hash.Key1 = "NewValue"     # Écrase
> $hash.Key2 = "Value2"       # Crée
> 
> # ⚠️ .Add() : erreur si la clé existe déjà
> $hash.Add("Key3", "Value3")  # OK
> $hash.Add("Key1", "Value")   # ERREUR !
> 
> # ✅ Bonne pratique : vérifier avant d'ajouter
> if (-not $hash.ContainsKey("Key4")) {
>     $hash.Add("Key4", "Value4")
> }
> ```

### Méthodes .Keys, .Values, .ContainsKey()

```powershell
$user = @{
    Name = "Alice"
    Age = 30
    City = "Paris"
    IsActive = $true
}

# Obtenir toutes les clés
$user.Keys              # Name, Age, City, IsActive

# Obtenir toutes les valeurs
$user.Values            # Alice, 30, Paris, True

# Vérifier l'existence d'une clé
$user.ContainsKey("Age")        # $true
$user.ContainsKey("Country")    # $false

# Vérifier l'existence d'une valeur
$user.ContainsValue("Paris")    # $true

# Nombre de paires clé-valeur
$user.Count             # 4
```

### Parcourir une hashtable

```powershell
$config = @{
    Server = "localhost"
    Port = 8080
    Database = "TestDB"
}

# Méthode 1 : foreach sur les clés
foreach ($key in $config.Keys) {
    $value = $config[$key]
    Write-Host "$key = $value"
}

# Méthode 2 : .GetEnumerator() (recommandé)
foreach ($item in $config.GetEnumerator()) {
    Write-Host "$($item.Key) = $($item.Value)"
}

# Méthode 3 : pipeline
$config.GetEnumerator() | ForEach-Object {
    Write-Host "$($_.Key) = $($_.Value)"
}
```

> [!warning] Modification pendant itération
> 
> ```powershell
> # ❌ Ne modifiez pas la hashtable pendant l'itération
> foreach ($key in $hash.Keys) {
>     $hash.Remove($key)  # ERREUR : Collection was modified
> }
> 
> # ✅ Créez une copie des clés d'abord
> $keysToRemove = @($hash.Keys)
> foreach ($key in $keysToRemove) {
>     $hash.Remove($key)  # OK
> }
> ```

### Hashtables imbriquées

```powershell
# Structure complexe
$organization = @{
    Name = "TechCorp"
    Departments = @{
        IT = @{
            Manager = "Alice"
            Employees = @("Bob", "Charlie")
            Budget = 500000
        }
        HR = @{
            Manager = "Diana"
            Employees = @("Eve", "Frank")
            Budget = 300000
        }
    }
}

# Accès aux éléments imbriqués
$organization.Departments.IT.Manager    # "Alice"
$organization.Departments.HR.Budget     # 300000
$organization.Departments.IT.Employees[0]  # "Bob"

# Modification
$organization.Departments.IT.Budget = 550000
```

> [!example] Exemple pratique : configuration d'application
> 
> ```powershell
> $appConfig = @{
>     Application = @{
>         Name = "MyApp"
>         Version = "1.0.0"
>     }
>     Database = @{
>         ConnectionString = "Server=localhost;Database=MyDB"
>         Timeout = 30
>     }
>     Logging = @{
>         Level = "Info"
>         Path = "C:\Logs\app.log"
>     }
> }
> 
> # Utilisation
> $dbTimeout = $appConfig.Database.Timeout
> $logPath = $appConfig.Logging.Path
> ```

### Hashtable ordonnée

Par défaut, les hashtables ne préservent pas l'ordre d'insertion. Utilisez `[ordered]` pour maintenir l'ordre :

```powershell
# Hashtable standard (ordre non garanti)
$standard = @{
    First = 1
    Second = 2
    Third = 3
}
$standard.Keys  # Ordre imprévisible

# Hashtable ordonnée
$ordered = [ordered]@{
    First = 1
    Second = 2
    Third = 3
}
$ordered.Keys   # Ordre préservé : First, Second, Third
```

> [!tip] Quand utiliser [ordered]
> 
> - Pour des fichiers de configuration lisibles
> - Quand l'ordre d'affichage est important
> - Pour générer du CSV ou JSON structuré
> - Légèrement moins performant, utilisez seulement si nécessaire

### Splatting avec hashtables

Les hashtables permettent de passer des paramètres nommés de manière élégante :

```powershell
# Sans splatting (long et peu lisible)
New-Item -Path "C:\Temp\test.txt" -ItemType File -Force -Value "Hello"

# Avec splatting (clair et maintenable)
$params = @{
    Path     = "C:\Temp\test.txt"
    ItemType = "File"
    Force    = $true
    Value    = "Hello"
}
New-Item @params  # Notez le @ au lieu de $

# Exemple avec Get-ChildItem
$searchParams = @{
    Path    = "C:\Windows"
    Filter  = "*.log"
    Recurse = $true
}
Get-ChildItem @searchParams
```

> [!tip] Avantages du splatting
> 
> - Code plus lisible
> - Paramètres facilement commentables
> - Réutilisable avec plusieurs commandes
> - Facilite les tests et le débogage

---

## 🎯 Autres types

### DateTime

Les dates et heures sont gérées par le type `[DateTime]` :

```powershell
# Obtenir la date/heure actuelle
$now = Get-Date

# Créer une date spécifique
$birthday = Get-Date "1990-05-15"
$meeting = Get-Date "2024-12-25 14:30:00"

# Formatage
$now.ToString("yyyy-MM-dd")                # "2024-11-20"
$now.ToString("dd/MM/yyyy HH:mm:ss")       # "20/11/2024 15:30:45"
Get-Date -Format "yyyy-MM-dd"              # Format raccourci

# Propriétés utiles
$now.Year               # 2024
$now.Month              # 11
$now.Day                # 20
$now.DayOfWeek          # Wednesday
$now.Hour               # 15
$now.Minute             # 30

# Calculs de dates
$tomorrow = $now.AddDays(1)
$lastWeek = $now.AddDays(-7)
$nextMonth = $now.AddMonths(1)
$nextYear = $now.AddYears(1)

# Différence entre dates
$duration = $meeting - $now
$duration.Days          # Nombre de jours
$duration.TotalHours    # Total en heures
```

> [!example] Exemple pratique : calculer l'âge
> 
> ```powershell
> $birthdate = Get-Date "1990-05-15"
> $today = Get-Date
> $age = $today.Year - $birthdate.Year
> if ($today.DayOfYear -lt $birthdate.DayOfYear) {
>     $age--
> }
> Write-Host "Âge : $age ans"
> ```

### PSCustomObject

`PSCustomObject` permet de créer des objets personnalisés structurés :

```powershell
# Création d'un objet simple
$person = [PSCustomObject]@{
    Name = "Alice"
    Age = 30
    City = "Paris"
}

# Accès aux propriétés
$person.Name            # "Alice"
$person.Age             # 30

# Création de plusieurs objets
$users = @(
    [PSCustomObject]@{Name="Alice"; Age=30; Role="Admin"}
    [PSCustomObject]@{Name="Bob"; Age=25; Role="User"}
    [PSCustomObject]@{Name="Charlie"; Age=35; Role="Manager"}
)

# Utilisation dans pipeline
$users | Where-Object {$_.Age -gt 28}
$users | Select-Object Name, Role
$users | Sort-Object Age
$users | Export-Csv "users.csv" -NoTypeInformation

# Ajout de propriétés après création
$person | Add-Member -MemberType NoteProperty -Name "Email" -Value "alice@example.com"
$person.Email           # "alice@example.com"
```

> [!tip] PSCustomObject vs Hashtable
> 
> |Aspect|Hashtable|PSCustomObject|
> |---|---|---|
> |Performance|Plus rapide pour lookups|Plus léger en mémoire|
> |Pipeline|Moins adapté|Excellent|
> |Export CSV/JSON|Nécessite conversion|Direct|
> |Ordre des propriétés|Nécessite [ordered]|Préservé|
> |Usage typique|Configurations, lookups|Données structurées, résultats|

### Collections spécialisées

PowerShell donne accès à de nombreux types de collections .NET :

```powershell
# List<T> - Liste générique typée
$list = [System.Collections.Generic.List[string]]::new()
$list.Add("Item1")
$list.Add("Item2")
$list.Remove("Item1")
$list.Count

# Queue - File FIFO (First In First Out)
$queue = [System.Collections.Queue]::new()
$queue.Enqueue("Premier")
$queue.Enqueue("Deuxième")
$first = $queue.Dequeue()       # "Premier"

# Stack - Pile LIFO (Last In First Out)
$stack = [System.Collections.Stack]::new()
$stack.Push("Premier")
$stack.Push("Deuxième")
$last = $stack.Pop()            # "Deuxième"

# Dictionary<TKey,TValue> - Dictionnaire typé
$dict = [System.Collections.Generic.Dictionary[string,int]]::new()
$dict.Add("Alice", 30)
$dict.Add("Bob", 25)
$dict["Alice"]                  # 30
$dict.ContainsKey("Bob")        # $true

# HashSet - Collection unique sans doublons
$set = [System.Collections.Generic.HashSet[string]]::new()
$set.Add("Item1")
$set.Add("Item2")
$set.Add("Item1")               # Retourne $false (déjà présent)
$set.Count                      # 2 (pas de doublons)
```

> [!tip] Quand utiliser chaque collection
> 
> - **List<T>** : alternative performante aux tableaux pour ajouts fréquents
> - **Queue** : traitement de tâches dans l'ordre d'arrivée
> - **Stack** : historique (undo/redo), parcours d'arborescence
> - **Dictionary<K,V>** : hashtable typée pour meilleure performance
> - **HashSet** : éliminer les doublons rapidement

### Conversion entre types

PowerShell permet de convertir facilement entre différents types :

```powershell
# String vers Number
[int]"123"              # 123
[double]"3.14"          # 3.14

# Number vers String
[string]42              # "42"
42.ToString()           # "42"

# String vers DateTime
[DateTime]"2024-12-25"

# Array vers ArrayList
$arr = @(1, 2, 3)
$arrayList = [System.Collections.ArrayList]$arr

# Hashtable vers PSCustomObject
$hash = @{Name="Alice"; Age=30}
$obj = [PSCustomObject]$hash

# PSCustomObject vers Hashtable
$hash2 = @{}
$obj.PSObject.Properties | ForEach-Object {
    $hash2[$_.Name] = $_.Value
}

# JSON vers Hashtable/PSCustomObject
$json = '{"Name":"Alice","Age":30}'
$object = $json | ConvertFrom-Json
$object.Name            # "Alice"

# Object vers JSON
$data = [PSCustomObject]@{Name="Bob"; Age=25}
$json = $data | ConvertTo-Json
```

> [!example] Exemple pratique : lire une configuration JSON
> 
> ```powershell
> # Fichier config.json contient :
> # {"Server":"localhost","Port":8080,"Debug":true}
> 
> $configJson = Get-Content "config.json" -Raw
> $config = $configJson | ConvertFrom-Json
> 
> # Accès aux propriétés
> $server = $config.Server
> $port = $config.Port
> 
> # Modification et sauvegarde
> $config.Port = 9090
> $config | ConvertTo-Json | Set-Content "config.json"
> ```

---

## 📝 Récapitulatif

### Choix du type selon le besoin

|Besoin|Type recommandé|
|---|---|
|Texte simple|`string`|
|Nombre entier|`int` ou `long`|
|Nombre décimal|`double` (standard) ou `decimal` (finance)|
|Vrai/Faux|`bool`|
|Liste d'éléments|`array` (lecture) ou `ArrayList` (modifiable)|
|Association clé-valeur|`hashtable`|
|Données structurées|`PSCustomObject`|
|Date et heure|`DateTime`|
|Collection performante|`List<T>` ou `Dictionary<K,V>`|

### Bonnes pratiques générales

> [!tip] Conseils essentiels
> 
> 1. **Immutabilité** : Les strings et arrays standards sont immutables en .NET
> 2. **Performance** : Utilisez `ArrayList` ou `List<T>` pour de nombreux ajouts
> 3. **Lisibilité** : Préférez `PSCustomObject` pour des données structurées
> 4. **Typage** : Typez explicitement pour la clarté et éviter les erreurs
> 5. **Null-safety** : Vérifiez toujours `$null` avant d'accéder aux propriétés

### Pièges à éviter

> [!warning] Erreurs courantes
> 
> - ❌ Utiliser `+=` sur de gros tableaux
> - ❌ Oublier que hashtables vides sont truthy
> - ❌ Ne pas vérifier `$null` avant accès aux membres
> - ❌ Modifier une collection pendant son itération
> - ❌ Confondre `0` (falsy) et `"0"` (truthy)
> - ❌ Utiliser `double` pour des calculs financiers précis