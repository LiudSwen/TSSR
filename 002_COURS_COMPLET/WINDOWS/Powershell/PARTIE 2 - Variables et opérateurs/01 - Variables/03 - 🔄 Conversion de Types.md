

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

La conversion de types en PowerShell est l'opération qui consiste à transformer une valeur d'un type de données vers un autre. PowerShell étant un langage dynamiquement typé, il effectue automatiquement de nombreuses conversions, mais il est souvent nécessaire de contrôler précisément ces transformations pour éviter les erreurs et garantir un comportement prévisible.

> [!info] Pourquoi la conversion de types est-elle importante ?
> 
> - **Interopérabilité** : Facilite l'échange de données entre différentes commandes et systèmes
> - **Validation** : Assure que les données sont dans le format attendu
> - **Performance** : Optimise le traitement en utilisant le type approprié
> - **Fiabilité** : Évite les comportements inattendus dus aux conversions automatiques

---

## 🔀 Conversion Implicite vs Explicite

### Conversion Implicite

PowerShell effectue automatiquement des conversions de types lorsqu'il estime que c'est nécessaire et sans risque de perte de données.

```powershell
# PowerShell convertit automatiquement la chaîne en nombre
$nombre = 5
$resultat = $nombre + "10"  # "10" est converti en 10
Write-Host $resultat  # Affiche : 15

# Conversion dans les comparaisons
$age = "25"
if ($age -gt 18) {  # "25" est converti en nombre pour la comparaison
    Write-Host "Majeur"
}

# Concaténation avec conversion automatique
$texte = "Nombre : " + 42  # 42 est converti en "42"
Write-Host $texte  # Affiche : Nombre : 42
```

> [!warning] Attention aux conversions implicites Les conversions automatiques peuvent produire des résultats inattendus. Par exemple, `"5" + 10` donnera `"510"` (concaténation) et non `15` (addition).

### Conversion Explicite

La conversion explicite force PowerShell à transformer une valeur vers un type spécifique, offrant un contrôle total sur l'opération.

```powershell
# Forcer la conversion vers un type spécifique
$texte = "123"
$nombre = [int]$texte  # Conversion explicite vers int
Write-Host $nombre  # Affiche : 123

# Éviter l'ambiguïté
$valeur1 = "5"
$valeur2 = 10
$resultat = [int]$valeur1 + $valeur2  # Force l'addition numérique
Write-Host $resultat  # Affiche : 15
```

> [!tip] Quand utiliser la conversion explicite ?
> 
> - Lorsque vous voulez garantir un type spécifique
> - Pour éviter les ambiguïtés dans les opérations
> - Lors de la manipulation de données externes (fichiers, API, saisie utilisateur)
> - Pour améliorer la lisibilité et la maintenabilité du code

---

## 🎭 Cast de Types avec `[type]`

Le cast de types utilise la syntaxe `[type]$variable` pour convertir explicitement une valeur. C'est la méthode la plus courante et recommandée en PowerShell.

### Syntaxe de Base

```powershell
# Syntaxe générale
[TypeCible]$variable

# Exemples simples
[int]"42"        # Convertit la chaîne "42" en entier 42
[string]100      # Convertit le nombre 100 en chaîne "100"
[bool]1          # Convertit 1 en $true
[datetime]"2024-01-15"  # Convertit la chaîne en objet DateTime
```

### Cast Multiple et Chaîné

```powershell
# Cast dans une affectation
$prix = [decimal]"19.99"
$quantite = [int]"5"

# Cast dans une expression
$total = [decimal]$prix * $quantite
Write-Host "Total : $total"  # Affiche : Total : 99.95

# Cast chaîné (rare mais possible)
$valeur = [string][int]"42.7"  # Convertit "42.7" en int (42), puis en string ("42")
```

### Cast avec des Variables Typées

```powershell
# Déclarer une variable avec un type spécifique
[int]$compteur = 0
[string]$nom = "Alice"
[datetime]$dateNaissance = "1990-05-15"

# Le type est maintenant forcé pour toutes les affectations futures
$compteur = "10"  # Sera automatiquement converti en int 10
$compteur = "abc"  # ERREUR : impossible de convertir "abc" en int
```

> [!example] Exemple Pratique : Traitement de Données CSV
> 
> ```powershell
> # Lecture d'un fichier CSV avec conversion appropriée
> $donnees = Import-Csv "ventes.csv"
> 
> foreach ($ligne in $donnees) {
>     # Les données CSV sont toujours des chaînes, on les convertit
>     $prix = [decimal]$ligne.Prix
>     $quantite = [int]$ligne.Quantite
>     $date = [datetime]$ligne.Date
>     
>     $montant = $prix * $quantite
>     Write-Host "Vente du $date : $montant €"
> }
> ```

---

## 🔧 Méthodes de Conversion .NET

PowerShell étant construit sur .NET, tous les objets disposent de méthodes de conversion héritées du framework .NET.

### `.ToString()` - Conversion vers String

La méthode universelle pour convertir n'importe quel objet en chaîne de caractères.

```powershell
# Conversion simple
$nombre = 42
$texte = $nombre.ToString()  # "42"

# Avec formatage
$prix = 1234.56
$prixFormate = $prix.ToString("C2")  # "1 234,56 €" (selon la culture locale)
$prixUS = $prix.ToString("C2", [System.Globalization.CultureInfo]"en-US")  # "$1,234.56"

# Formatage de dates
$date = Get-Date
$dateFormatee = $date.ToString("dd/MM/yyyy")  # "10/12/2025"
$dateComplete = $date.ToString("dddd dd MMMM yyyy à HH:mm")  # "mercredi 10 décembre 2025 à 14:30"

# Formatage de nombres
$valeur = 1234567.89
$valeur.ToString("N2")   # "1 234 567,89" (avec séparateurs de milliers)
$valeur.ToString("F4")   # "1234567,8900" (4 décimales fixes)
$valeur.ToString("P1")   # "123 456 789,0%" (pourcentage avec 1 décimale)
```

### `.ToInt32()`, `.ToDouble()`, etc.

Méthodes spécifiques pour les conversions numériques.

```powershell
# Conversion vers entier
$texte = "42"
$nombre = $texte.ToInt32($null)  # Équivalent à [int]$texte

# Attention : ces méthodes ne sont pas disponibles sur les chaînes PowerShell
# Il faut utiliser [Convert] ou les casts
```

### Autres Méthodes de Conversion

```powershell
# .ToUpper() et .ToLower() pour les chaînes
$nom = "Jean Dupont"
$nomMajuscule = $nom.ToUpper()    # "JEAN DUPONT"
$nomMinuscule = $nom.ToLower()    # "jean dupont"

# .ToCharArray() pour convertir une chaîne en tableau de caractères
$mot = "Bonjour"
$lettres = $mot.ToCharArray()  # @('B', 'o', 'n', 'j', 'o', 'u', 'r')

# .GetType() pour connaître le type d'un objet
$variable = 42
$type = $variable.GetType()  # System.Int32
Write-Host "Type : $($type.Name)"  # Affiche : Type : Int32
```

> [!tip] Astuce : Formatage avec l'Opérateur `-f` PowerShell offre un opérateur de formatage très puissant :
> 
> ```powershell
> $nom = "Alice"
> $age = 30
> $message = "Bonjour {0}, vous avez {1} ans" -f $nom, $age
> # Affiche : Bonjour Alice, vous avez 30 ans
> 
> # Avec formatage numérique
> $prix = 1234.567
> "{0:C2}" -f $prix  # "1 234,57 €"
> "{0:N2}" -f $prix  # "1 234,57"
> "{0:P1}" -f ($prix/10000)  # "12,3%"
> ```

---

## 📊 Types de Cast Courants

### `[int]` - Entier 32 bits

```powershell
# Conversions valides
[int]"42"           # 42
[int]"  123  "      # 123 (espaces ignorés)
[int]42.9           # 42 (troncature, pas d'arrondi)
[int]$true          # 1
[int]$false         # 0

# Limites
$min = [int]::MinValue  # -2147483648
$max = [int]::MaxValue  # 2147483647

# Erreurs courantes
[int]"abc"          # ERREUR : format invalide
[int]"42.5abc"      # ERREUR : caractères non numériques
[int]3000000000     # ERREUR : dépassement de capacité (trop grand pour int)
```

### `[string]` - Chaîne de Caractères

```powershell
# Conversion universelle
[string]42          # "42"
[string]$true       # "True"
[string]@(1,2,3)    # "1 2 3" (tableau converti avec espaces)

# Conversion d'objets complexes
$date = Get-Date
[string]$date       # Représentation textuelle de la date

# Attention avec les tableaux
$tableau = @(1, 2, 3)
[string]$tableau    # "1 2 3" (jointure avec espaces)
$tableau -join ","  # "1,2,3" (meilleur contrôle)
```

### `[datetime]` - Date et Heure

```powershell
# Formats reconnus automatiquement
[datetime]"2024-01-15"                    # 15/01/2024 00:00:00
[datetime]"15/01/2024"                    # 15/01/2024 00:00:00
[datetime]"January 15, 2024"              # 15/01/2024 00:00:00
[datetime]"2024-01-15 14:30:00"           # 15/01/2024 14:30:00

# Formats ISO 8601
[datetime]"2024-01-15T14:30:00"           # Format standard
[datetime]"2024-01-15T14:30:00Z"          # UTC

# Opérations sur les dates
$date1 = [datetime]"2024-01-15"
$date2 = [datetime]"2024-01-10"
$difference = $date1 - $date2              # TimeSpan de 5 jours
Write-Host $difference.Days                # 5

# Composants de date
$maintenant = Get-Date
[datetime]::Now                            # Date et heure actuelles
[datetime]::Today                          # Aujourd'hui à 00:00:00
[datetime]::UtcNow                         # Date et heure UTC actuelles
```

### `[bool]` - Booléen

```powershell
# Valeurs considérées comme $false
[bool]0             # $false
[bool]""            # $false (chaîne vide)
[bool]$null         # $false

# Valeurs considérées comme $true
[bool]1             # $true
[bool]-1            # $true (tout nombre non nul)
[bool]"texte"       # $true (toute chaîne non vide)
[bool]@()           # $false (tableau vide)
[bool]@(1)          # $true (tableau non vide)

# Usage dans les conditions
$valeur = "texte"
if ([bool]$valeur) {
    Write-Host "La valeur n'est pas vide"
}
```

### `[decimal]` - Décimal Haute Précision

```powershell
# Pour les calculs financiers précis
[decimal]"19.99"                  # 19.99
[decimal]123.456789               # 123.456789

# Précision supérieure à [double]
$prixUnitaire = [decimal]19.99
$quantite = 3
$total = $prixUnitaire * $quantite  # 59.97 (précis)

# Limites
$min = [decimal]::MinValue  # -79228162514264337593543950335
$max = [decimal]::MaxValue  # 79228162514264337593543950335
```

### `[double]` et `[float]` - Nombres à Virgule Flottante

```powershell
# [double] : précision double (par défaut)
[double]"3.14159"               # 3.14159
[double]"1.23e10"               # 12300000000 (notation scientifique)

# [float] : précision simple (moins précis, plus rapide)
[float]"3.14159"                # 3.14159 (précision réduite)

# Comparaison de précision
$d = [double]1.23456789012345678  # Environ 15-17 chiffres significatifs
$f = [float]1.23456789012345678   # Environ 7 chiffres significatifs

# Valeurs spéciales
[double]::PositiveInfinity      # Infini positif
[double]::NegativeInfinity      # Infini négatif
[double]::NaN                   # Not a Number

# Test de valeurs spéciales
$resultat = 1.0 / 0.0
[double]::IsInfinity($resultat)   # $true
[double]::IsNaN(0.0 / 0.0)        # $true
```

### `[array]` - Tableau

```powershell
# Conversion vers tableau
[array]"texte"                  # @("texte") - tableau à un élément
[array]42                       # @(42)
[array]@(1,2,3)                 # @(1,2,3) - déjà un tableau
[array]$null                    # @() - tableau vide

# Forcer la création d'un tableau
$variable = [array]("élément unique")  # Garantit que c'est un tableau

# Cas d'usage
function Get-Items {
    $resultat = Get-Process | Select-Object -First 1
    return [array]$resultat  # Force le retour d'un tableau même avec un seul élément
}
```

### `[hashtable]` - Table de Hachage

```powershell
# Conversion depuis PSCustomObject
$objet = [PSCustomObject]@{
    Nom = "Alice"
    Age = 30
}
$hash = [hashtable]$objet  # ERREUR : conversion directe impossible

# Conversion manuelle nécessaire
$hash = @{}
$objet.PSObject.Properties | ForEach-Object {
    $hash[$_.Name] = $_.Value
}

# Création directe
$personne = @{
    Nom = "Alice"
    Age = 30
    Ville = "Paris"
}
```

### `[xml]` - Document XML

```powershell
# Conversion depuis une chaîne XML
$xmlTexte = @"
<personne>
    <nom>Alice</nom>
    <age>30</age>
</personne>
"@

$xml = [xml]$xmlTexte
$xml.personne.nom  # "Alice"
$xml.personne.age  # "30"

# Chargement depuis un fichier
$xmlFichier = [xml](Get-Content "data.xml")
```

> [!info] Tableau de Correspondance des Types
> 
> |Type PowerShell|Type .NET|Plage/Description|
> |---|---|---|
> |`[int]`|System.Int32|-2 147 483 648 à 2 147 483 647|
> |`[long]`|System.Int64|±9 quintillions|
> |`[decimal]`|System.Decimal|28-29 chiffres significatifs|
> |`[double]`|System.Double|±5.0e-324 à ±1.7e308|
> |`[float]`|System.Single|±1.5e-45 à ±3.4e38|
> |`[string]`|System.String|Chaîne de caractères Unicode|
> |`[char]`|System.Char|Caractère Unicode unique|
> |`[bool]`|System.Boolean|$true ou $false|
> |`[datetime]`|System.DateTime|01/01/0001 à 31/12/9999|
> |`[array]`|System.Array|Tableau d'objets|

---

## ⚠️ Gestion des Erreurs de Conversion

Les conversions de types peuvent échouer si les données ne sont pas compatibles. PowerShell offre plusieurs mécanismes pour gérer ces situations.

### Erreurs de Conversion Standard

```powershell
# Conversion qui échoue
try {
    $nombre = [int]"abc"  # ERREUR : impossible de convertir "abc"
} catch {
    Write-Host "Erreur de conversion : $_"
}

# Dépassement de capacité
try {
    $grand = [int]5000000000  # ERREUR : trop grand pour int32
} catch {
    Write-Host "Nombre trop grand pour int32, utilisez [long]"
}

# Format de date invalide
try {
    $date = [datetime]"35/15/2024"  # ERREUR : date invalide
} catch {
    Write-Host "Format de date invalide"
}
```

### Utilisation de `-as` pour des Conversions Sûres

L'opérateur `-as` effectue une conversion et retourne `$null` en cas d'échec au lieu de générer une erreur.

```powershell
# Conversion sûre avec -as
$nombre = "123" -as [int]      # 123
$invalide = "abc" -as [int]    # $null (pas d'erreur)

# Test de validité
$input = "abc"
$converted = $input -as [int]
if ($null -eq $converted) {
    Write-Host "Conversion impossible : $input n'est pas un nombre"
} else {
    Write-Host "Nombre valide : $converted"
}

# Avec les dates
$dateTexte = "2024-13-45"  # Date invalide
$date = $dateTexte -as [datetime]
if ($null -eq $date) {
    Write-Host "Date invalide"
}
```

### Try-Catch pour Gestion Avancée

```powershell
# Fonction robuste avec gestion d'erreur
function ConvertTo-SafeInt {
    param([string]$Value)
    
    try {
        return [int]$Value
    } catch [System.FormatException] {
        Write-Warning "Format invalide : $Value n'est pas un nombre"
        return $null
    } catch [System.OverflowException] {
        Write-Warning "Dépassement : $Value est trop grand"
        return $null
    } catch {
        Write-Warning "Erreur inattendue : $_"
        return $null
    }
}

# Utilisation
$resultat = ConvertTo-SafeInt "42"      # 42
$resultat = ConvertTo-SafeInt "abc"     # $null avec warning
$resultat = ConvertTo-SafeInt "9999999999"  # $null avec warning
```

### Validation Avant Conversion

```powershell
# Validation avec expressions régulières
function Test-NumericString {
    param([string]$Value)
    return $Value -match '^\d+$'  # Vérifie que c'est uniquement des chiffres
}

$input = "123"
if (Test-NumericString $input) {
    $nombre = [int]$input
    Write-Host "Nombre valide : $nombre"
} else {
    Write-Host "Pas un nombre valide"
}

# Validation de date
function Test-DateString {
    param([string]$Value)
    $date = $null
    return [datetime]::TryParse($Value, [ref]$date)
}

if (Test-DateString "2024-01-15") {
    Write-Host "Date valide"
}
```

> [!example] Exemple Pratique : Saisie Utilisateur Robuste
> 
> ```powershell
> function Get-SafeUserInput {
>     param(
>         [string]$Prompt,
>         [type]$ExpectedType
>     )
>     
>     do {
>         $input = Read-Host $Prompt
>         $converted = $input -as $ExpectedType
>         
>         if ($null -eq $converted) {
>             Write-Host "Entrée invalide. Type attendu : $($ExpectedType.Name)" -ForegroundColor Red
>         }
>     } while ($null -eq $converted)
>     
>     return $converted
> }
> 
> # Utilisation
> $age = Get-SafeUserInput "Entrez votre âge" ([int])
> $dateNaissance = Get-SafeUserInput "Entrez votre date de naissance" ([datetime])
> ```

---

## 🏗️ Classe Convert et Méthodes .NET

La classe `[System.Convert]` de .NET offre des méthodes de conversion avancées avec plus d'options et de contrôle.

### Méthodes de Base

```powershell
# Conversions numériques
[System.Convert]::ToInt32("42")        # 42
[System.Convert]::ToDouble("3.14")     # 3.14
[System.Convert]::ToDecimal("19.99")   # 19.99

# Conversion avec base numérique
[System.Convert]::ToInt32("1010", 2)   # 10 (binaire vers décimal)
[System.Convert]::ToInt32("FF", 16)    # 255 (hexadécimal vers décimal)
[System.Convert]::ToString(255, 2)     # "11111111" (décimal vers binaire)
[System.Convert]::ToString(255, 16)    # "ff" (décimal vers hexadécimal)

# Conversion booléenne
[System.Convert]::ToBoolean("true")    # $true
[System.Convert]::ToBoolean(1)         # $true
[System.Convert]::ToBoolean("yes")     # ERREUR : seuls "true"/"false" sont acceptés
```

### TryParse - Conversion Sécurisée

Les méthodes `TryParse` tentent une conversion et retournent un booléen indiquant le succès.

```powershell
# Pattern TryParse pour les entiers
$input = "123"
$resultat = 0
$success = [int]::TryParse($input, [ref]$resultat)

if ($success) {
    Write-Host "Conversion réussie : $resultat"
} else {
    Write-Host "Conversion échouée"
}

# TryParse avec dates
$dateInput = "2024-01-15"
$date = [datetime]::MinValue
if ([datetime]::TryParse($dateInput, [ref]$date)) {
    Write-Host "Date valide : $date"
}

# TryParse avec double
$input = "3.14"
$nombre = 0.0
if ([double]::TryParse($input, [ref]$nombre)) {
    Write-Host "Nombre : $nombre"
}
```

### TryParse avec Culture Spécifique

```powershell
# Conversion avec culture française
$prixFr = "1 234,56"
$prix = 0.0
$cultureFr = [System.Globalization.CultureInfo]"fr-FR"
$success = [double]::TryParse(
    $prixFr, 
    [System.Globalization.NumberStyles]::Any,
    $cultureFr,
    [ref]$prix
)

if ($success) {
    Write-Host "Prix : $prix"  # 1234.56
}

# Conversion avec culture américaine
$prixUS = "1,234.56"
$cultureUS = [System.Globalization.CultureInfo]"en-US"
$success = [double]::TryParse(
    $prixUS,
    [System.Globalization.NumberStyles]::Any,
    $cultureUS,
    [ref]$prix
)
```

### ParseExact pour Formats Stricts

```powershell
# Date avec format strict
$dateTexte = "15/01/2024"
$format = "dd/MM/yyyy"
$culture = [System.Globalization.CultureInfo]::InvariantCulture

$date = [datetime]::ParseExact(
    $dateTexte,
    $format,
    $culture
)
Write-Host $date  # 15/01/2024 00:00:00

# TryParseExact pour format strict avec gestion d'erreur
$dateTexte = "2024-01-15 14:30:00"
$format = "yyyy-MM-dd HH:mm:ss"
$date = [datetime]::MinValue
$success = [datetime]::TryParseExact(
    $dateTexte,
    $format,
    $culture,
    [System.Globalization.DateTimeStyles]::None,
    [ref]$date
)

if ($success) {
    Write-Host "Date parsée : $date"
}
```

### Conversions Base64

```powershell
# Encodage en Base64
$texte = "Bonjour PowerShell"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($texte)
$base64 = [System.Convert]::ToBase64String($bytes)
Write-Host $base64  # "Qm9uam91ciBQb3dlclNoZWxs"

# Décodage depuis Base64
$bytes = [System.Convert]::FromBase64String($base64)
$texteDecoded = [System.Text.Encoding]::UTF8.GetString($bytes)
Write-Host $texteDecoded  # "Bonjour PowerShell"
```

> [!tip] Différences entre Cast et Convert
> 
> ```powershell
> # Cast avec [type] - rapide mais moins tolérant
> [int]"42"           # OK
> [int]"42.9"         # OK : troncature vers 42
> [int]"  42  "       # OK : espaces ignorés
> [int]"42abc"        # ERREUR
> 
> # Convert.ToInt32() - plus strict
> [Convert]::ToInt32("42")       # OK
> [Convert]::ToInt32("42.9")     # ERREUR : nécessite un entier exact
> [Convert]::ToInt32("  42  ")   # OK
> [Convert]::ToInt32("42abc")    # ERREUR
> 
> # TryParse - le plus sûr
> $resultat = 0
> [int]::TryParse("42.9", [ref]$resultat)  # Retourne $false sans erreur
> ```

---

## 🚧 Pièges Courants

### 1. Confusion entre Addition et Concaténation

```powershell
# Piège : le type du premier opérande détermine l'opération
$resultat1 = "5" + 10      # "510" (concaténation)
$resultat2 = 5 + "10"      # 15 (addition)
$resultat3 = "5" + "10"    # "510" (concaténation)

# Solution : forcer le type
$resultat = [int]"5" + 10  # 15 (addition garantie)
```

### 2. Troncature lors de la Conversion Float vers Int

```powershell
# Piège : pas d'arrondi, juste troncature
$valeur = 42.9
$entier = [int]$valeur     # 42 (pas 43!)

# Solution : utiliser l'arrondi explicite
$entier = [Math]::Round($valeur)    # 43
$entier = [Math]::Floor($valeur)    # 42 (arrondi vers le bas)
$entier = [Math]::Ceiling($valeur)  # 43 (arrondi vers le haut)
```

### 3. Perte de Précision avec Double

```powershell
# Piège : imprécisions des nombres flottants
$a = 0.1
$b = 0.2
$c = $a + $b
$c -eq 0.3  # $false ! (c vaut environ 0.30000000000000004)

# Solution : utiliser [decimal] pour les calculs précis
$a = [decimal]0.1
$b = [decimal]0.2
$c = $a + $b
$c -eq 0.3  # $true
```

### 4. Conversion de Dates Ambiguës

```powershell
# Piège : format de date dépendant de la culture
$date1 = [datetime]"01/02/2024"  # 01 février ou 02 janvier ?

# Solution : utiliser un format non ambigu
$date = [datetime]"2024-01-02"   # Format ISO : toujours YYYY-MM-DD

# Ou utiliser ParseExact
$date = [datetime]::ParseExact(
    "01/02/2024",
    "dd/MM/yyyy",
    [System.Globalization.CultureInfo]::InvariantCulture
)
```

### 5. Tableaux à Un Seul Élément

```powershell
# Piège : un tableau d'un élément peut être "déballé"
$tableau = @("élément")
$resultat = $tableau        # Devient juste "élément" (string)

# Solution : forcer le type tableau
$resultat = [array]$tableau  # Reste un tableau
$resultat = @() + $tableau   # Alternative
```

### 6. Conversion de `$null`

```powershell
# Comportements surprenants avec $null
[int]$null          # 0 (pas d'erreur!)
[string]$null       # "" (chaîne vide)
[bool]$null         # $false
[datetime]$null     # 01/01/0001 00:00:00

# Solution : toujours vérifier $null avant conversion
if ($null -ne $variable) {
    $nombre = [int]$variable
}
```

### 7. Conversion de Tableaux en String

```powershell
# Piège : conversion implicite avec espaces
$tableau = @(1, 2, 3)
$texte = [string]$tableau    # "1 2 3"

# Solution : utiliser -join pour contrôler le séparateur
$texte = $tableau -join ","  # "1,2,3"
$texte = $tableau -join ";"  # "1;2;3"
$texte = $tableau -join ""   # "123"
```

### 8. Comparaisons avec Conversions Implicites

```powershell
# Piège : comportement différent selon l'opérateur
"10" -eq 10         # $true (conversion implicite)
"10" -ceq 10        # $false (comparaison sensible à la casse, pas de conversion)

# Avec les tableaux
$nombres = @("1", "2", "3")
$nombres -contains 2        # $true (conversion implicite)
$nombres -ccontains 2       # $false (pas de conversion)

# Solution : être explicite
$nombres = @([int]"1", [int]"2", [int]"3")
$nombres -contains 2        # $true
```

---

## ✅ Bonnes Pratiques

### 1. Typer les Paramètres de Fonction

```powershell
# ❌ Mauvais : type non défini
function Calculer-Prix {
    param($PrixUnitaire, $Quantite)
    return $PrixUnitaire * $Quantite
}

# ✅ Bon : types explicites
function Calculer-Prix {
    param(
        [decimal]$PrixUnitaire,
        [int]$Quantite
    )
    return $PrixUnitaire * $Quantite
}

# PowerShell fera la conversion automatiquement et générera une erreur si impossible
Calculer-Prix -PrixUnitaire "19.99" -Quantite "3"  # Fonctionne : conversion auto
Calculer-Prix -PrixUnitaire "abc" -Quantite "3"    # Erreur claire : impossible de convertir
```

### 2. Utiliser `-as` pour les Conversions Non Critiques

```powershell
# ✅ Pour les conversions où $null est acceptable
$nombre = $input -as [int]
if ($null -ne $nombre) {
    # Traiter le nombre
}

# ✅ Pour les validations
if ($input -as [datetime]) {
    Write-Host "Date valide"
}
```

### 3. Préférer TryParse pour les Entrées Externes

```powershell
# ✅ Pour les données utilisateur, fichiers, API
function Import-DataFile {
    param([string]$Path)
    
    $lignes = Get-Content $Path
    $resultats = @()
    
    foreach ($ligne in $lignes) {
        $nombre = 0
        if ([int]::TryParse($ligne, [ref]$nombre)) {
            $resultats += $nombre
        } else {
            Write-Warning "Ligne ignorée (format invalide) : $ligne"
        }
    }
    
    return $resultats
}
```

### 4. Documenter les Conversions Non Évidentes

```powershell
# ✅ Ajouter des commentaires pour expliquer pourquoi
# Conversion en décimal pour éviter les erreurs d'arrondi dans les calculs financiers
$prixTotal = [decimal]$prixUnitaire * [int]$quantite

# Conversion de l'entrée utilisateur avec gestion d'erreur
$dateDebut = $input -as [datetime]
if ($null -eq $dateDebut) {
    $dateDebut = [datetime]::Today  # Par défaut : aujourd'hui
}
```

### 5. Utiliser les Types Appropriés selon le Contexte

```powershell
# ✅ [decimal] pour l'argent et les calculs précis
$prixHT = [decimal]19.99
$TVA = [decimal]0.20
$prixTTC = $prixHT * (1 + $TVA)

# ✅ [datetime] pour les dates
$dateDebut = [datetime]"2024-01-01"
$dateFin = [datetime]"2024-12-31"
$duree = $dateFin - $dateDebut

# ✅ [int] pour les compteurs et index
$compteur = [int]0
$index = [int]42

# ✅ [string] pour les identifiants et codes
$codeClient = [string]"CLI-001"
```

### 6. Valider Avant de Convertir les Données Critiques

```powershell
# ✅ Fonction de validation robuste
function Convert-ToSafeDecimal {
    param(
        [string]$Value,
        [decimal]$DefaultValue = 0
    )
    
    $result = 0.0
    if ([decimal]::TryParse($Value, [ref]$result)) {
        return $result
    } else {
        Write-Warning "Valeur invalide '$Value', utilisation de la valeur par défaut : $DefaultValue"
        return $DefaultValue
    }
}

# Utilisation
$prix = Convert-ToSafeDecimal $inputUtilisateur -DefaultValue 0.00
```

### 7. Gérer les Cultures pour l'Internationalisation

```powershell
# ✅ Utiliser InvariantCulture pour les formats standards
$date = [datetime]::ParseExact(
    "2024-01-15",
    "yyyy-MM-dd",
    [System.Globalization.CultureInfo]::InvariantCulture
)

# ✅ Ou utiliser la culture appropriée
$cultureFr = [System.Globalization.CultureInfo]"fr-FR"
$prix = [decimal]::Parse("1234,56", $cultureFr)
```

### 8. Tester les Conversions dans les Scripts Critiques

```powershell
# ✅ Ajouter des tests de validation
function Test-Conversions {
    # Test des conversions numériques
    $test1 = ([int]"42" -eq 42)
    $test2 = ([decimal]"19.99" -eq 19.99)
    
    # Test des conversions de dates
    $test3 = ([datetime]"2024-01-15").Year -eq 2024
    
    if ($test1 -and $test2 -and $test3) {
        Write-Host "✅ Tous les tests de conversion sont OK" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Échec des tests de conversion" -ForegroundColor Red
        return $false
    }
}
```

> [!tip] Récapitulatif des Méthodes de Conversion
> 
> |Méthode|Usage|Gestion Erreur|Performance|
> |---|---|---|---|
> |`[type]$var`|Cast direct, rapide|Exception|⚡⚡⚡ Très rapide|
> |`$var -as [type]`|Conversion sûre|Retourne $null|⚡⚡ Rapide|
> |`[Convert]::To*()`|Conversion .NET|Exception|⚡⚡ Rapide|
> |`[type]::TryParse()`|Le plus sûr|Retourne booléen|⚡ Moyen|
> |`[type]::Parse()`|Strict|Exception|⚡⚡ Rapide|
> |`.ToString()`|Vers string|Jamais d'erreur|⚡⚡⚡ Très rapide|

---

## 🎓 Récapitulatif

La conversion de types en PowerShell est un aspect fondamental qui offre flexibilité et contrôle sur la manipulation des données. En maîtrisant les différentes méthodes de conversion et en appliquant les bonnes pratiques, vous pouvez créer des scripts robustes, prévisibles et maintenables.

**Points clés à retenir :**

1. **Conversion implicite** : PowerShell convertit automatiquement, mais peut surprendre
2. **Cast `[type]`** : Méthode principale, rapide et directe
3. **Opérateur `-as`** : Conversion sûre qui retourne `$null` en cas d'échec
4. **TryParse** : Méthode la plus robuste pour les données externes
5. **Types appropriés** : Choisir `[decimal]` pour l'argent, `[datetime]` pour les dates, etc.
6. **Validation** : Toujours valider les données critiques avant conversion
7. **Gestion d'erreurs** : Utiliser `try-catch` ou `-as` selon le contexte

La maîtrise de ces concepts vous permettra d'écrire du code PowerShell plus fiable et professionnel.