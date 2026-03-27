
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

## 🎯 Introduction

Les opérateurs de comparaison en PowerShell permettent de tester des conditions, comparer des valeurs, et filtrer des données. Contrairement à d'autres langages qui utilisent des symboles comme '==', `>`, `<`, PowerShell utilise des mnémoniques lisibles comme `-eq`, `-gt`, `-lt`.

> [!info] Pourquoi cette syntaxe ? PowerShell a choisi des opérateurs textuels pour éviter les ambiguïtés avec les redirections shell (`>`, `<`) et améliorer la lisibilité du code.

**Résultat des comparaisons** : Tous les opérateurs retournent un booléen (`$true` ou `$false`).

---

## ⚖️ Opérateurs d'égalité

### `-eq` (Equal - Égal)

Teste si deux valeurs sont égales.

```powershell
# Comparaisons simples
5 -eq 5           # $true
"hello" -eq "hello"  # $true
"Hello" -eq "hello"  # $true (insensible à la casse par défaut)

# Utilisation dans des conditions
$age = 25
if ($age -eq 25) {
    Write-Host "Vous avez 25 ans"
}

# Avec des variables
$expected = "Succès"
$result = "Succès"
$result -eq $expected  # $true
```

### `-ne` (Not Equal - Différent)

Teste si deux valeurs sont différentes.

```powershell
10 -ne 5          # $true
"chat" -ne "chien"  # $true
"test" -ne "test"   # $false

# Filtrage dans des collections
$services = Get-Service
$services | Where-Object {$_.Status -ne "Running"}  # Services non démarrés
```

### `-ceq` et `-cne` (Case-sensitive)

Versions sensibles à la casse des opérateurs d'égalité.

```powershell
# Version insensible (défaut)
"Hello" -eq "hello"   # $true

# Version sensible
"Hello" -ceq "hello"  # $false
"Hello" -ceq "Hello"  # $true

# Différent sensible
"Test" -cne "test"    # $true
"Test" -cne "Test"    # $false
```

> [!warning] Attention aux types PowerShell tente de convertir automatiquement les types. `"5" -eq 5` retourne `$true` car la chaîne est convertie en nombre.

---

## 🔢 Opérateurs de comparaison numérique

### `-gt` (Greater Than - Supérieur)

```powershell
10 -gt 5          # $true
3 -gt 10          # $false
5 -gt 5           # $false

# Utilisation pratique
$diskSpace = (Get-PSDrive C).Free / 1GB
if ($diskSpace -gt 10) {
    Write-Host "Espace disque suffisant : $diskSpace GB"
}
```

### `-ge` (Greater or Equal - Supérieur ou égal)

```powershell
10 -ge 10         # $true
10 -ge 5          # $true
5 -ge 10          # $false

# Validation d'âge
$age = 18
if ($age -ge 18) {
    Write-Host "Accès autorisé"
}
```

### `-lt` (Less Than - Inférieur)

```powershell
5 -lt 10          # $true
10 -lt 5          # $false
5 -lt 5           # $false

# Vérification de limites
$errorCount = 3
if ($errorCount -lt 5) {
    Write-Host "Nombre d'erreurs acceptable"
}
```

### `-le` (Less or Equal - Inférieur ou égal)

```powershell
5 -le 10          # $true
10 -le 10         # $true
15 -le 10         # $false

# Limitation de ressources
$cpuUsage = 85
if ($cpuUsage -le 90) {
    Write-Host "CPU dans les limites acceptables"
}
```

> [!tip] Comparaisons de chaînes Ces opérateurs fonctionnent aussi avec des chaînes (ordre alphabétique) :
> 
> ```powershell
> "apple" -lt "banana"  # $true
> "zebra" -gt "alpha"   # $true
> ```

---

## 🎯 Opérateurs de correspondance

### `-like` (Correspondance avec wildcards)

Permet des correspondances de motifs simples avec `*` (zéro ou plusieurs caractères) et `?` (un caractère).

```powershell
# Wildcards de base
"Hello World" -like "Hello*"      # $true
"Test123" -like "Test*"           # $true
"PowerShell" -like "*Shell"       # $true
"PowerShell" -like "*power*"      # $true (insensible à la casse)

# Wildcard ? (un seul caractère)
"test1" -like "test?"             # $true
"test12" -like "test?"            # $false
"test1" -like "test??"            # $false

# Filtrage de fichiers
Get-ChildItem | Where-Object {$_.Name -like "*.txt"}

# Recherche d'utilisateurs
Get-ADUser -Filter * | Where-Object {$_.Name -like "Jean*"}
```

### `-notlike`

Inverse de `-like`.

```powershell
"Hello" -notlike "Goodbye*"       # $true
"test.txt" -notlike "*.log"       # $true

# Exclusion de fichiers
Get-ChildItem | Where-Object {$_.Name -notlike "*.tmp"}
```

### `-match` (Correspondance avec regex)

Utilise les expressions régulières pour des motifs complexes.

```powershell
# Motifs simples
"test123" -match "\d+"            # $true (contient des chiffres)
"abc" -match "\d+"                # $false

# Email
"user@domain.com" -match "@"      # $true
"user@domain.com" -match "^[\w.-]+@[\w.-]+\.\w+$"  # $true (email valide)

# Capture de groupes avec $Matches
"Server01" -match "Server(\d+)"
$Matches[1]                       # "01"

"IP: 192.168.1.1" -match "(\d+\.){3}\d+"
$Matches[0]                       # "192.168.1.1"

# Validation de format
$phone = "06-12-34-56-78"
if ($phone -match "^\d{2}-\d{2}-\d{2}-\d{2}-\d{2}$") {
    Write-Host "Format de téléphone valide"
}
```

### `-notmatch`

Inverse de `-match`.

```powershell
"abc" -notmatch "\d"              # $true (pas de chiffres)
"test123" -notmatch "^\d+$"       # $true (pas que des chiffres)

# Filtrage de logs
Get-Content "app.log" | Where-Object {$_ -notmatch "^DEBUG"}
```

> [!example] Différence entre -like et -match
> 
> |Opérateur|Syntaxe|Cas d'usage|
> |---|---|---|
> |`-like`|Wildcards (`*`, `?`)|Motifs simples, noms de fichiers|
> |`-match`|Regex|Motifs complexes, validation de format|
> 
> ```powershell
> # -like : simple
> "test.txt" -like "*.txt"      # $true
> 
> # -match : puissant
> "test.txt" -match "\.txt$"    # $true
> "test_123.txt" -match "test_\d+\.txt"  # $true
> ```

---

## 📦 Opérateurs de contenance

### `-contains` et `-notcontains`

Teste si une collection contient un élément spécifique.

```powershell
# Collections simples
$fruits = @("pomme", "banane", "orange")
$fruits -contains "pomme"         # $true
$fruits -contains "kiwi"          # $false
$fruits -notcontains "kiwi"       # $true

# Vérification de rôles
$roles = @("Admin", "User", "Guest")
if ($roles -contains "Admin") {
    Write-Host "Droits administrateur détectés"
}

# Avec des nombres
$numbers = 1..10
$numbers -contains 5              # $true
$numbers -contains 15             # $false

# Attention : sensible au type
$numbers = @(1, 2, 3)
$numbers -contains "1"            # $false (string vs int)
```

> [!warning] Collection à gauche L'opérateur `-contains` nécessite que la **collection soit à gauche** :
> 
> ```powershell
> # ✅ Correct
> @("a", "b", "c") -contains "a"
> 
> # ❌ Incorrect
> "a" -contains @("a", "b", "c")
> ```

### `-in` et `-notin`

Inverse syntaxique de `-contains` - l'élément est à gauche.

```powershell
# Syntaxe inversée
"pomme" -in @("pomme", "banane", "orange")    # $true
"kiwi" -notin @("pomme", "banane", "orange")  # $true

# Plus lisible dans certains cas
$status = "Running"
if ($status -in @("Running", "Started")) {
    Write-Host "Service actif"
}

# Validation d'entrée
$choice = Read-Host "Choisir (A/B/C)"
if ($choice -in @("A", "B", "C")) {
    Write-Host "Choix valide"
} else {
    Write-Host "Choix invalide"
}
```

> [!tip] -contains vs -in Ces opérateurs sont équivalents mais avec une syntaxe inversée :
> 
> ```powershell
> # Identiques
> @(1,2,3) -contains 2
> 2 -in @(1,2,3)
> 
> # Choisir selon la lisibilité
> $validExtensions = @(".txt", ".log", ".csv")
> 
> # Style 1
> $validExtensions -contains $extension
> 
> # Style 2 (souvent plus lisible)
> $extension -in $validExtensions
> ```

---

## 🔄 Opérateurs de remplacement

### `-replace` (Remplacement avec regex)

Remplace du texte en utilisant des expressions régulières.

```powershell
# Remplacement simple
"Hello World" -replace "World", "PowerShell"  # "Hello PowerShell"

# Avec regex
"test123" -replace "\d+", "XXX"               # "testXXX"
"user@domain.com" -replace "@.*", "@newdomain.com"  # "user@newdomain.com"

# Suppression (remplacer par rien)
"  espaces  multiples  " -replace "\s+", " "  # " espaces multiples "
"test-file-name.txt" -replace "-", "_"        # "test_file_name.txt"

# Groupes de capture
"John Doe" -replace "(\w+) (\w+)", '$2, $1'   # "Doe, John"
"2024-12-10" -replace "(\d{4})-(\d{2})-(\d{2})", '$3/$2/$1'  # "10/12/2024"

# Nettoyage de données
$cleanText = "Prix: 1234,56 €" -replace "[^\d,]", ""  # "1234,56"

# Renommage de fichiers
Get-ChildItem *.txt | Rename-Item -NewName {$_.Name -replace " ", "_"}
```

> [!info] Différence avec -creplace `-creplace` est la version sensible à la casse :
> 
> ```powershell
> "Hello World" -replace "hello", "Hi"   # "Hi World"
> "Hello World" -creplace "hello", "Hi"  # "Hello World" (pas de match)
> ```

> [!example] Cas pratiques de -replace
> 
> ```powershell
> # Anonymisation
> $log = "User john.doe@company.com accessed file"
> $log -replace "\b[\w.-]+@[\w.-]+\.\w+\b", "[EMAIL]"
> 
> # Normalisation de chemins
> $path = "C:\Users\John\Documents"
> $path -replace "\\", "/"  # "C:/Users/John/Documents"
> 
> # Suppression de caractères spéciaux
> $filename = "Mon fichier (copie) [2024].txt"
> $filename -replace "[\[\]()]", ""  # "Mon fichier copie 2024.txt"
> ```

---

## 🔤 Sensibilité à la casse

Par défaut, PowerShell est **insensible à la casse** pour les chaînes. Pour forcer la sensibilité, préfixez l'opérateur avec `c`.

### Tableau récapitulatif

|Insensible|Sensible|Description|
|---|---|---|
|`-eq`|`-ceq`|Égal|
|`-ne`|`-cne`|Différent|
|`-like`|`-clike`|Correspondance wildcard|
|`-notlike`|`-cnotlike`|Pas de correspondance wildcard|
|`-match`|`-cmatch`|Correspondance regex|
|`-notmatch`|`-cnotmatch`|Pas de correspondance regex|
|`-replace`|`-creplace`|Remplacement|
|`-contains`|`-ccontains`|Contient|
|`-notcontains`|`-cnotcontains`|Ne contient pas|
|`-in`|`-cin`|Appartient à|
|`-notin`|`-cnotin`|N'appartient pas à|

### Exemples pratiques

```powershell
# Comparaison insensible (défaut)
"PowerShell" -eq "powershell"     # $true
"TEST" -like "test"               # $true
"Hello" -match "HELLO"            # $true

# Comparaison sensible
"PowerShell" -ceq "powershell"    # $false
"TEST" -clike "test"              # $false
"Hello" -cmatch "HELLO"           # $false

# Cas d'usage : validation stricte
$password = "SecretP@ssw0rd"
if ($password -cmatch "[A-Z]" -and $password -cmatch "[a-z]" -and $password -cmatch "\d") {
    Write-Host "Mot de passe complexe"
}

# Recherche sensible dans collections
$codes = @("ABC", "abc", "Abc")
$codes -contains "abc"            # $true (trouve n'importe quelle casse)
$codes -ccontains "abc"           # $true (trouve exactement "abc")
```

> [!tip] Quand utiliser la sensibilité à la casse ?
> 
> - **Validation de mots de passe** : Exiger des majuscules et minuscules
> - **Codes ou identifiants** : "ID001" ≠ "id001"
> - **Chemins Unix/Linux** : Systèmes de fichiers sensibles à la casse
> - **Protocoles stricts** : HTTP headers, commandes SQL

---

## ⚠️ Pièges courants

### 1. Conversion automatique de types

```powershell
# ❌ Piège : comparaison string/number
"10" -eq 10                       # $true (conversion auto)
"010" -eq 10                      # $true (le 0 initial est ignoré)

# ✅ Solution : forcer le type
[string]10 -eq "10"               # $true
[int]"10" -eq 10                  # $true
```

### 2. Collections avec -eq

```powershell
# ❌ Comportement inattendu
$numbers = 1..10
$numbers -eq 5                    # Retourne 5, pas $true/$false !

# ✅ Utiliser -contains pour tester l'appartenance
$numbers -contains 5              # $true
```

### 3. Wildcard vs Regex

```powershell
# ❌ Confusion entre -like et -match
"test.txt" -like "test.txt"       # $true
"test.txt" -match "test.txt"      # $true (mais . = n'importe quel caractère en regex)
"testAtxt" -match "test.txt"      # $true (!!)

# ✅ Échapper les caractères spéciaux en regex
"test.txt" -match "test\.txt"     # $true (correct)
"testAtxt" -match "test\.txt"     # $false
```

### 4. $null dans les comparaisons

```powershell
# ❌ Comportements surprenants
$null -eq $null                   # $true
$null -eq ""                      # $false
$null -eq 0                       # $false

# ❌ Piège avec les collections
@() -contains $null               # $false
@($null) -contains $null          # $true

# ✅ Tester explicitement $null
$value = $null
if ($null -eq $value) {           # Mettre $null à gauche !
    Write-Host "Valeur nulle"
}
```

### 5. Regex non échappés avec -match

```powershell
# ❌ Caractères spéciaux en regex
"10.5" -match "10.5"              # $true (mais . = n'importe quel caractère)
"10X5" -match "10.5"              # $true (!!)

# ✅ Utiliser [regex]::Escape()
$literal = "10.5"
"10.5" -match [regex]::Escape($literal)    # $true
"10X5" -match [regex]::Escape($literal)    # $false
```

---

## ✅ Bonnes pratiques

### 1. Choisir le bon opérateur

```powershell
# ✅ -eq pour égalité exacte
$status -eq "Running"

# ✅ -like pour motifs simples
$filename -like "*.log"

# ✅ -match pour validation complexe
$email -match "^[\w.-]+@[\w.-]+\.\w+$"

# ✅ -contains pour appartenance
$validRoles -contains $userRole
```

### 2. Préférer -in pour la lisibilité

```powershell
# ✅ Plus lisible
if ($status -in @("Running", "Started", "Online")) {
    # ...
}

# Moins lisible
if (@("Running", "Started", "Online") -contains $status) {
    # ...
}
```

### 3. Mettre $null à gauche

```powershell
# ✅ Recommandé
if ($null -eq $variable) { }

# ❌ Peut causer des bugs
if ($variable -eq $null) { }
```

### 4. Utiliser les versions sensibles quand nécessaire

```powershell
# ✅ Pour codes, IDs, mots de passe
$productCode -ceq "ABC123"
$password -cmatch "^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$"
```

### 5. Commenter les regex complexes

```powershell
# ✅ Regex documentée
$pattern = @"
^                    # Début de ligne
(?=.*[A-Z])          # Au moins une majuscule
(?=.*[a-z])          # Au moins une minuscule
(?=.*\d)             # Au moins un chiffre
(?=.*[@#$%])         # Au moins un caractère spécial
.{8,}                # Au moins 8 caractères
$                    # Fin de ligne
"@

if ($password -match $pattern) {
    Write-Host "Mot de passe valide"
}
```

### 6. Utiliser des variables pour les collections

```powershell
# ✅ Plus maintenable
$validStatuses = @("Running", "Started", "Online")
if ($status -in $validStatuses) { }

# ❌ Difficile à maintenir
if ($status -in @("Running", "Started", "Online")) { }
```

---

## 🎓 Astuces avancées

### Combinaison d'opérateurs

```powershell
# ET logique avec -and
if (($age -ge 18) -and ($age -le 65)) {
    Write-Host "Âge valide"
}

# OU logique avec -or
if (($extension -eq ".txt") -or ($extension -eq ".log")) {
    Write-Host "Fichier texte"
}

# Négation avec -not ou !
if (-not ($status -eq "Running")) {
    Write-Host "Service arrêté"
}
```

### Filtrage avec Where-Object

```powershell
# Avec opérateurs
Get-Process | Where-Object {$_.CPU -gt 100}
Get-Service | Where-Object {$_.Status -ne "Running"}
Get-ChildItem | Where-Object {$_.Name -like "*.ps1"}

# Forme abrégée
Get-Process | Where CPU -gt 100
Get-Service | Where Status -ne "Running"
```

### Opérateurs dans Select-Object

```powershell
# Propriétés calculées
Get-Process | Select-Object Name, @{
    Name = "HighCPU"
    Expression = {$_.CPU -gt 100}
}

Get-ChildItem | Select-Object Name, @{
    Name = "IsLog"
    Expression = {$_.Extension -eq ".log"}
}
```

### Validation d'entrées utilisateur

```powershell
# Menu avec validation
do {
    $choice = Read-Host "Choisir (A/B/C/Q)"
} while ($choice -notin @("A", "B", "C", "Q"))

# Validation de format
do {
    $email = Read-Host "Email"
} while ($email -notmatch "^[\w.-]+@[\w.-]+\.\w+$")
```

---

## 📊 Tableau récapitulatif complet

|Catégorie|Opérateur|Description|Exemple|
|---|---|---|---|
|**Égalité**|`-eq` / `-ceq`|Égal|`5 -eq 5` → `$true`|
||`-ne` / `-cne`|Différent|`5 -ne 3` → `$true`|
|**Numérique**|`-gt` / `-cgt`|Supérieur|`10 -gt 5` → `$true`|
||`-ge` / `-cge`|Supérieur ou égal|`5 -ge 5` → `$true`|
||`-lt` / `-clt`|Inférieur|`3 -lt 10` → `$true`|
||`-le` / `-cle`|Inférieur ou égal|`5 -le 10` → `$true`|
|**Correspondance**|`-like` / `-clike`|Wildcard|`"test" -like "t*"` → `$true`|
||`-notlike` / `-cnotlike`|Pas wildcard|`"test" -notlike "a*"` → `$true`|
||`-match` / `-cmatch`|Regex|`"test123" -match "\d+"` → `$true`|
||`-notmatch` / `-cnotmatch`|Pas regex|`"abc" -notmatch "\d"` → `$true`|
|**Contenance**|`-contains` / `-ccontains`|Contient|`@(1,2,3) -contains 2` → `$true`|
||`-notcontains` / `-cnotcontains`|Ne contient pas|`@(1,2) -notcontains 5` → `$true`|
||`-in` / `-cin`|Appartient à|`2 -in @(1,2,3)` → `$true`|
||`-notin` / `-cnotin`|N'appartient pas|`5 -notin @(1,2,3)` → `$true`|
|**Remplacement**|`-replace` / `-creplace`|Remplacer|`"hi" -replace "h", "b"` → `"bi"`|

---

> [!tip] 💡 Mémo rapide
> 
> - **Égalité simple** : `-eq`, `-ne`
> - **Nombres** : `-gt`, `-ge`, `-lt`, `-le`
> - **Motifs simples** : `-like` avec `*` et `?`
> - **Motifs complexes** : `-match` avec regex
> - **Collections** : `-contains` (collection à gauche) ou `-in` (élément à gauche)
> - **Sensibilité** : Ajouter `c` devant l'opérateur (ex: `-ceq`)
> - **$null** : Toujours mettre à gauche dans les comparaisons