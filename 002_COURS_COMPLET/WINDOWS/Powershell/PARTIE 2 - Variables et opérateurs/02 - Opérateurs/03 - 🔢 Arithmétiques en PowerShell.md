
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

Les opérations arithmétiques sont fondamentales en PowerShell pour manipuler des nombres, calculer des valeurs, et effectuer des transformations de données. PowerShell utilise les opérateurs arithmétiques standards, tout en offrant des comportements spécifiques selon les types de données manipulés.

> [!info] Types numériques en PowerShell PowerShell supporte plusieurs types numériques : `[int]` (entier 32 bits), `[long]` (entier 64 bits), `[double]` (nombre à virgule flottante), `[decimal]` (précision décimale). Le type est généralement déterminé automatiquement.

---

## Opérateurs arithmétiques de base

### Addition (+)

L'opérateur `+` additionne deux valeurs numériques.

**Syntaxe :**

```powershell
$resultat = $valeur1 + $valeur2
```

**Exemples :**

```powershell
# Addition simple
$somme = 5 + 3
Write-Host $somme  # Affiche : 8

# Addition de variables
$a = 10
$b = 20
$total = $a + $b
Write-Host $total  # Affiche : 30

# Addition avec nombres décimaux
$prix1 = 19.99
$prix2 = 25.50
$totalPrix = $prix1 + $prix2
Write-Host $totalPrix  # Affiche : 45.49

# Addition multiple
$resultat = 1 + 2 + 3 + 4 + 5
Write-Host $resultat  # Affiche : 15
```

> [!tip] Conversion automatique PowerShell convertit automatiquement les types compatibles. Par exemple, additionner un entier et un double produit un double.

---

### Soustraction (-)

L'opérateur `-` soustrait la seconde valeur de la première.

**Syntaxe :**

```powershell
$resultat = $valeur1 - $valeur2
```

**Exemples :**

```powershell
# Soustraction simple
$difference = 10 - 3
Write-Host $difference  # Affiche : 7

# Soustraction de variables
$stock = 100
$vendus = 35
$restant = $stock - $vendus
Write-Host $restant  # Affiche : 65

# Soustraction avec nombres négatifs
$temp1 = 5
$temp2 = -3
$difference = $temp1 - $temp2
Write-Host $difference  # Affiche : 8 (5 - (-3) = 5 + 3)

# Négation d'un nombre
$positif = 42
$negatif = -$positif
Write-Host $negatif  # Affiche : -42
```

---

### Multiplication (*)

L'opérateur `*` multiplie deux valeurs.

**Syntaxe :**

```powershell
$resultat = $valeur1 * $valeur2
```

**Exemples :**

```powershell
# Multiplication simple
$produit = 6 * 7
Write-Host $produit  # Affiche : 42

# Calcul de surface
$largeur = 5
$longueur = 8
$surface = $largeur * $longueur
Write-Host "Surface : $surface m²"  # Affiche : Surface : 40 m²

# Multiplication avec décimaux
$prixUnitaire = 12.50
$quantite = 3
$total = $prixUnitaire * $quantite
Write-Host $total  # Affiche : 37.5

# Calcul de pourcentage
$montant = 200
$pourcentage = 0.15
$taxe = $montant * $pourcentage
Write-Host $taxe  # Affiche : 30
```

> [!example] Multiplication de chaînes L'opérateur `*` peut aussi répéter une chaîne : `"Ha" * 3` donne `"HaHaHa"`

---

### Division (/)

L'opérateur `/` divise la première valeur par la seconde.

**Syntaxe :**

```powershell
$resultat = $valeur1 / $valeur2
```

**Exemples :**

```powershell
# Division simple
$quotient = 10 / 2
Write-Host $quotient  # Affiche : 5

# Division avec reste décimal
$resultat = 10 / 3
Write-Host $resultat  # Affiche : 3.33333333333333

# Calcul de moyenne
$total = 450
$nombre = 6
$moyenne = $total / $nombre
Write-Host $moyenne  # Affiche : 75

# Division par nombre décimal
$distance = 100
$temps = 2.5
$vitesse = $distance / $temps
Write-Host "$vitesse km/h"  # Affiche : 40 km/h
```

> [!warning] Division par zéro La division par zéro génère une erreur. Vérifiez toujours que le diviseur n'est pas nul.
> 
> ```powershell
> if ($diviseur -ne 0) {
>     $resultat = $dividende / $diviseur
> }
> ```

---

### Modulo (%)

L'opérateur `%` retourne le reste de la division entière.

**Syntaxe :**

```powershell
$reste = $valeur1 % $valeur2
```

**Exemples :**

```powershell
# Modulo simple
$reste = 10 % 3
Write-Host $reste  # Affiche : 1 (10 = 3*3 + 1)

# Vérifier si un nombre est pair
$nombre = 42
if ($nombre % 2 -eq 0) {
    Write-Host "$nombre est pair"
}

# Vérifier si un nombre est impair
$nombre = 17
if ($nombre % 2 -eq 1) {
    Write-Host "$nombre est impair"
}

# Cycle de valeurs (utile pour les index circulaires)
$index = 25
$tailleCycle = 7
$position = $index % $tailleCycle
Write-Host $position  # Affiche : 4 (25 = 7*3 + 4)

# Vérifier la divisibilité
$nombre = 100
if ($nombre % 10 -eq 0) {
    Write-Host "$nombre est divisible par 10"
}
```

> [!tip] Usages courants du modulo
> 
> - Déterminer la parité (pair/impair)
> - Créer des cycles répétitifs
> - Extraire des chiffres spécifiques
> - Vérifier la divisibilité

---

## Opérateurs d'affectation

### Affectation simple (=)

L'opérateur `=` assigne une valeur à une variable.

**Syntaxe :**

```powershell
$variable = valeur
```

**Exemples :**

```powershell
# Affectation simple
$age = 25
$nom = "Alice"
$actif = $true

# Affectation d'un résultat de calcul
$somme = 10 + 5

# Affectation multiple (en une ligne)
$x = $y = $z = 0

# Affectation depuis une autre variable
$original = 100
$copie = $original
```

> [!info] L'affectation retourne une valeur En PowerShell, l'affectation retourne la valeur assignée, ce qui permet des constructions comme `if ($x = Get-Value) { ... }`

---

### Affectations composées (+=, -=, *=, /=)

Les opérateurs composés combinent une opération arithmétique avec une affectation.

**Syntaxe :**

```powershell
$variable += valeur  # Équivaut à : $variable = $variable + valeur
$variable -= valeur  # Équivaut à : $variable = $variable - valeur
$variable *= valeur  # Équivaut à : $variable = $variable * valeur
$variable /= valeur  # Équivaut à : $variable = $variable / valeur
```

**Exemples :**

```powershell
# Addition composée (+=)
$total = 100
$total += 50
Write-Host $total  # Affiche : 150

# Accumulation dans une boucle
$somme = 0
1..10 | ForEach-Object { $somme += $_ }
Write-Host $somme  # Affiche : 55

# Soustraction composée (-=)
$stock = 200
$stock -= 35
Write-Host $stock  # Affiche : 165

# Multiplication composée (*=)
$valeur = 5
$valeur *= 3
Write-Host $valeur  # Affiche : 15

# Division composée (/=)
$nombre = 100
$nombre /= 4
Write-Host $nombre  # Affiche : 25

# Modulo composé (%=)
$nombre = 17
$nombre %= 5
Write-Host $nombre  # Affiche : 2
```

> [!tip] Lisibilité et performance Les opérateurs composés rendent le code plus concis et légèrement plus performant car la variable n'est évaluée qu'une seule fois.

**Tableau récapitulatif :**

|Opérateur|Équivalent long|Exemple|Résultat|
|---|---|---|---|
|`+=`|`$x = $x + 5`|`$x = 10; $x += 5`|`15`|
|`-=`|`$x = $x - 3`|`$x = 10; $x -= 3`|`7`|
|`*=`|`$x = $x * 2`|`$x = 10; $x *= 2`|`20`|
|`/=`|`$x = $x / 2`|`$x = 10; $x /= 2`|`5`|
|`%=`|`$x = $x % 3`|`$x = 10; $x %= 3`|`1`|

---

## Incrémentation et décrémentation

### Opérateurs ++ et --

Ces opérateurs augmentent ou diminuent une variable de 1.

**Syntaxe :**

```powershell
$variable++  # Post-incrémentation
++$variable  # Pré-incrémentation
$variable--  # Post-décrémentation
--$variable  # Pré-décrémentation
```

**Exemples :**

```powershell
# Incrémentation simple
$compteur = 0
$compteur++
Write-Host $compteur  # Affiche : 1

# Décrémentation simple
$vies = 3
$vies--
Write-Host $vies  # Affiche : 2

# Usage dans une boucle
$i = 0
while ($i -lt 5) {
    Write-Host "Itération $i"
    $i++
}

# Compte à rebours
$countdown = 10
while ($countdown -gt 0) {
    Write-Host $countdown
    $countdown--
    Start-Sleep -Seconds 1
}
Write-Host "Décollage !"
```

---

### Pré-incrémentation vs Post-incrémentation

La position de l'opérateur détermine quand la valeur est modifiée par rapport à son utilisation dans une expression.

**Différence :**

```powershell
# POST-incrémentation (variable++)
# La valeur actuelle est utilisée, PUIS incrémentée
$x = 5
$y = $x++  # $y reçoit 5, puis $x devient 6
Write-Host "x = $x, y = $y"  # Affiche : x = 6, y = 5

# PRÉ-incrémentation (++variable)
# La variable est incrémentée, PUIS la nouvelle valeur est utilisée
$x = 5
$y = ++$x  # $x devient 6, puis $y reçoit 6
Write-Host "x = $x, y = $y"  # Affiche : x = 6, y = 6
```

**Exemples comparatifs :**

```powershell
# Post-décrémentation
$vies = 3
Write-Host "Il reste $($vies--) vies"  # Affiche : Il reste 3 vies
Write-Host "Maintenant : $vies vies"   # Affiche : Maintenant : 2 vies

# Pré-décrémentation
$vies = 3
Write-Host "Il reste $(--$vies) vies"  # Affiche : Il reste 2 vies
Write-Host "Maintenant : $vies vies"   # Affiche : Maintenant : 2 vies
```

> [!warning] Attention aux effets de bord Dans des expressions complexes, la différence entre pré et post peut créer des comportements inattendus. Privilégiez la clarté :
> 
> ```powershell
> # Moins clair
> $result = $array[$i++]
> 
> # Plus clair
> $result = $array[$i]
> $i++
> ```

**Tableau récapitulatif :**

|Opérateur|Nom|Moment de modification|Valeur retournée|
|---|---|---|---|
|`$x++`|Post-incrémentation|Après utilisation|Valeur avant incrémentation|
|`++$x`|Pré-incrémentation|Avant utilisation|Valeur après incrémentation|
|`$x--`|Post-décrémentation|Après utilisation|Valeur avant décrémentation|
|`--$x`|Pré-décrémentation|Avant utilisation|Valeur après décrémentation|

---

## Priorité des opérations

PowerShell respecte l'ordre mathématique standard pour l'évaluation des expressions (règle PEMDAS).

**Ordre de priorité (du plus au moins prioritaire) :**

1. **Parenthèses** `( )`
2. **Incrémentation/Décrémentation** `++`, `--`
3. **Négation unaire** `-`
4. **Multiplication, Division, Modulo** `*`, `/`, `%`
5. **Addition, Soustraction** `+`, `-`

**Exemples :**

```powershell
# Sans parenthèses : multiplication d'abord
$resultat = 5 + 3 * 2
Write-Host $resultat  # Affiche : 11 (3*2=6, puis 5+6=11)

# Avec parenthèses : addition d'abord
$resultat = (5 + 3) * 2
Write-Host $resultat  # Affiche : 16 (5+3=8, puis 8*2=16)

# Expression complexe
$resultat = 10 + 5 * 2 - 3
Write-Host $resultat  # Affiche : 17 (5*2=10, puis 10+10-3=17)

# Avec parenthèses pour clarifier
$resultat = 10 + (5 * 2) - 3
Write-Host $resultat  # Affiche : 17 (même résultat, mais intention claire)

# Opérations multiples
$resultat = (10 + 5) * (8 - 3) / 5
Write-Host $resultat  # Affiche : 15

# Division et modulo (même priorité, évaluation de gauche à droite)
$resultat = 20 / 4 * 2
Write-Host $resultat  # Affiche : 10 (20/4=5, puis 5*2=10)

# Négation unaire
$resultat = -5 * 2
Write-Host $resultat  # Affiche : -10

$resultat = -(5 + 3)
Write-Host $resultat  # Affiche : -8
```

**Tableau de priorité :**

|Priorité|Opérateurs|Description|Exemple|
|---|---|---|---|
|1|`( )`|Parenthèses|`(5 + 3) * 2`|
|2|`++`, `--`|Incrémentation/Décrémentation|`++$x`|
|3|`-` (unaire)|Négation|`-$x`|
|4|`*`, `/`, `%`|Multiplication, Division, Modulo|`5 * 2`|
|5|`+`, `-`|Addition, Soustraction|`5 + 3`|

> [!tip] Bonnes pratiques
> 
> - Utilisez des parenthèses pour rendre vos intentions explicites, même si elles ne sont pas nécessaires
> - Ne vous fiez pas uniquement à la mémorisation de la priorité
> - Un code clair avec parenthèses est préférable à un code concis mais ambigu

**Exemples de clarification :**

```powershell
# Ambigu (fonctionne mais peu clair)
$prix = 100 + 50 * 1.2 - 10

# Clair (intention explicite)
$prix = 100 + (50 * 1.2) - 10

# Très clair (découpage en étapes)
$sousTotal = 50 * 1.2
$prix = 100 + $sousTotal - 10
```

---

## Opérations sur chaînes de caractères

L'opérateur `+` permet de concaténer des chaînes de caractères.

**Syntaxe :**

```powershell
$chaine = $chaine1 + $chaine2
```

**Exemples :**

```powershell
# Concaténation simple
$prenom = "Jean"
$nom = "Dupont"
$nomComplet = $prenom + " " + $nom
Write-Host $nomComplet  # Affiche : Jean Dupont

# Concaténation avec nombres (conversion automatique)
$message = "Vous avez " + 5 + " messages"
Write-Host $message  # Affiche : Vous avez 5 messages

# Concaténation multiple
$chemin = "C:" + "\" + "Users" + "\" + "Admin"
Write-Host $chemin  # Affiche : C:\Users\Admin

# Opérateur += pour ajouter à une chaîne existante
$texte = "Bonjour"
$texte += " tout"
$texte += " le"
$texte += " monde"
Write-Host $texte  # Affiche : Bonjour tout le monde

# Construction progressive dans une boucle
$liste = ""
1..5 | ForEach-Object {
    $liste += "Item $_"
    if ($_ -lt 5) { $liste += ", " }
}
Write-Host $liste  # Affiche : Item 1, Item 2, Item 3, Item 4, Item 5
```

> [!info] Interpolation de chaînes : alternative recommandée PowerShell offre l'interpolation avec des guillemets doubles, souvent plus lisible :
> 
> ```powershell
> $prenom = "Jean"
> $nom = "Dupont"
> $nomComplet = "$prenom $nom"  # Plus lisible
> ```

**Multiplication de chaînes :**

```powershell
# Répéter une chaîne
$separation = "-" * 50
Write-Host $separation  # Affiche : --------------------------------------------------

# Créer des motifs
$motif = "Ha" * 3
Write-Host $motif  # Affiche : HaHaHa

# Espacement
$espaces = " " * 10
$texte = $espaces + "Texte indenté"
Write-Host $texte  # Affiche :           Texte indenté

# Répétition avec variable
$nombre = 5
$etoiles = "*" * $nombre
Write-Host $etoiles  # Affiche : *****
```

> [!warning] Performance avec concaténation intensive Pour de nombreuses concaténations (ex: dans une boucle), utilisez plutôt un StringBuilder ou collectez dans un tableau :
> 
> ```powershell
> # Inefficace
> $resultat = ""
> 1..1000 | ForEach-Object { $resultat += "Item $_" }
> 
> # Efficace
> $items = 1..1000 | ForEach-Object { "Item $_" }
> $resultat = $items -join ""
> ```

---

## Opérations sur tableaux

L'opérateur `+` permet de combiner des tableaux.

**Syntaxe :**

```powershell
$nouveauTableau = $tableau1 + $tableau2
```

**Exemples :**

```powershell
# Concaténation de tableaux
$groupe1 = @("Alice", "Bob")
$groupe2 = @("Charlie", "David")
$tousLesNoms = $groupe1 + $groupe2
Write-Host $tousLesNoms  # Affiche : Alice Bob Charlie David

# Ajouter un élément à un tableau
$nombres = @(1, 2, 3)
$nombres = $nombres + 4
Write-Host $nombres  # Affiche : 1 2 3 4

# Ajouter plusieurs éléments
$fruits = @("Pomme", "Banane")
$fruits = $fruits + @("Orange", "Kiwi")
Write-Host $fruits  # Affiche : Pomme Banane Orange Kiwi

# Opérateur += pour ajouter à un tableau
$collection = @(1, 2, 3)
$collection += 4
$collection += @(5, 6)
Write-Host $collection  # Affiche : 1 2 3 4 5 6

# Combiner plusieurs tableaux
$tab1 = @(1, 2)
$tab2 = @(3, 4)
$tab3 = @(5, 6)
$combine = $tab1 + $tab2 + $tab3
Write-Host $combine  # Affiche : 1 2 3 4 5 6
```

**Multiplication de tableaux :**

```powershell
# Répéter un tableau
$base = @(1, 2, 3)
$repete = $base * 3
Write-Host $repete  # Affiche : 1 2 3 1 2 3 1 2 3

# Créer un tableau de valeurs identiques
$zeros = @(0) * 5
Write-Host $zeros  # Affiche : 0 0 0 0 0

# Initialisation avec répétition
$espaces = @(" ") * 10
```

> [!warning] Performance avec tableaux Les tableaux PowerShell (`@()`) sont immutables. Chaque opération `+=` crée un nouveau tableau en mémoire. Pour de nombreuses additions, utilisez une ArrayList ou une List :
> 
> ```powershell
> # Inefficace pour nombreux ajouts
> $tableau = @()
> 1..1000 | ForEach-Object { $tableau += $_ }
> 
> # Efficace
> $liste = [System.Collections.ArrayList]@()
> 1..1000 | ForEach-Object { [void]$liste.Add($_) }
> ```

**Opérations arithmétiques élément par élément :**

```powershell
# Appliquer une opération à chaque élément
$nombres = @(1, 2, 3, 4, 5)
$doubles = $nombres | ForEach-Object { $_ * 2 }
Write-Host $doubles  # Affiche : 2 4 6 8 10

# Addition d'une constante à chaque élément
$prix = @(10, 20, 30)
$prixTTC = $prix | ForEach-Object { $_ * 1.2 }
Write-Host $prixTTC  # Affiche : 12 24 36
```

---

## Pièges courants et bonnes pratiques

### Pièges courants

> [!warning] Division par zéro
> 
> ```powershell
> # ❌ Erreur
> $resultat = 10 / 0
> 
> # ✅ Vérification préalable
> if ($diviseur -ne 0) {
>     $resultat = $dividende / $diviseur
> } else {
>     Write-Host "Division par zéro impossible"
> }
> ```

> [!warning] Conversion de types implicite
> 
> ```powershell
> # Attention : la conversion peut surprendre
> $a = "5"
> $b = 3
> Write-Host ($a + $b)  # Affiche : 53 (concaténation de chaînes)
> Write-Host ($b + $a)  # Affiche : 8 (addition numérique)
> 
> # Le premier opérande détermine le type d'opération
> ```

> [!warning] Précision des nombres décimaux
> 
> ```powershell
> # Les calculs avec [double] peuvent avoir des imprécisions
> $resultat = 0.1 + 0.2
> Write-Host $resultat  # Affiche : 0.30000000000000004
> 
> # Pour la précision financière, utilisez [decimal]
> $resultat = [decimal]0.1 + [decimal]0.2
> Write-Host $resultat  # Affiche : 0.3
> ```

> [!warning] Opérateurs sur tableaux et performance
> 
> ```powershell
> # ❌ Inefficace : crée un nouveau tableau à chaque itération
> $tableau = @()
> 1..10000 | ForEach-Object {
>     $tableau += $_
> }
> 
> # ✅ Efficace : collecte directe
> $tableau = 1..10000
> ```

> [!warning] Priorité des opérations
> 
> ```powershell
> # Sans parenthèses, peut être ambigu
> $resultat = 10 + 5 * 2  # = 20 (multiplication d'abord)
> 
> # Avec parenthèses, intention claire
> $resultat = (10 + 5) * 2  # = 30
> ```

### Bonnes pratiques

> [!tip] Utilisez des parenthèses pour la clarté
> 
> ```powershell
> # Moins clair
> $prix = base + taxe * taux - remise
> 
> # Plus clair
> $prix = base + (taxe * taux) - remise
> ```

> [!tip] Nommez vos variables de manière explicite
> 
> ```powershell
> # ❌ Peu clair
> $t = $p * $q
> 
> # ✅ Explicite
> $total = $prixUnitaire * $quantite
> ```

> [!tip] Gérez les cas limites
> 
> ```powershell
> # Vérifiez les valeurs avant les opérations critiques
> if ($null -ne $variable -and $variable -ne 0) {
>     $resultat = 100 / $variable
> }
> ```

> [!tip] Utilisez le bon type numérique
> 
> ```powershell
> # Pour des calculs financiers : [decimal]
> $prixTTC = [decimal]$prixHT * [decimal]1.20
> 
> # Pour des entiers : [int]
> $compteur = [int]$total / [int]$nombre
> 
> # Pour des calculs scientifiques : [double] (par défaut)
> $resultat = [Math]::Sqrt($nombre)
> ```

> [!tip] Astuces de calcul
> 
> ```powershell
> # Arrondir à 2 décimales
> $arrondi = [Math]::Round($nombre, 2)
> 
> # Valeur absolue
> $absolu = [Math]::Abs($nombre)
> 
> # Puissance
> $carre = [Math]::Pow($nombre, 2)
> 
> # Minimum et maximum
> $min = [Math]::Min($a, $b)
> $max = [Math]::Max($a, $b)
> ```

---

✨ **Maîtrisez les opérations arithmétiques pour manipuler efficacement les données numériques en PowerShell !**