
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

La boucle `for` est une structure de contrôle fondamentale en PowerShell qui permet d'exécuter un bloc de code un nombre déterminé de fois. Elle est particulièrement adaptée lorsque vous connaissez à l'avance le nombre d'itérations ou lorsque vous devez travailler avec des indices numériques.

> [!info] Quand utiliser `for` ?
> 
> - Parcourir une collection en utilisant des indices
> - Effectuer un nombre précis d'itérations
> - Naviguer dans un tableau avec un contrôle fin sur l'index
> - Implémenter des algorithmes nécessitant des compteurs

---

## Syntaxe de la boucle for

La syntaxe complète de la boucle `for` en PowerShell suit le modèle classique des langages de type C :

```powershell
for (<Initialisation>; <Condition>; <Itération>) {
    # Code à exécuter
}
```

**Exemple basique :**

```powershell
for ($i = 0; $i -lt 5; $i++) {
    Write-Host "Itération numéro $i"
}
```

**Résultat :**

```
Itération numéro 0
Itération numéro 1
Itération numéro 2
Itération numéro 3
Itération numéro 4
```

> [!warning] Point d'attention Les trois composantes (initialisation, condition, itération) sont séparées par des **points-virgules** (`;`), pas des virgules.

### Composantes optionnelles

Techniquement, toutes les composantes sont optionnelles, mais cela peut créer des boucles infinies :

```powershell
# Boucle infinie (à éviter sans condition d'arrêt interne)
for (;;) {
    Write-Host "Boucle infinie"
    # Il faut un break quelque part !
}
```

---

## Initialisation, condition, itération

### 🔹 Initialisation

L'initialisation définit la valeur de départ de la variable de contrôle. Elle est exécutée **une seule fois** au début de la boucle.

```powershell
# Initialisation simple
for ($i = 0; $i -lt 3; $i++) { }

# Initialisation à partir d'une variable
$debut = 10
for ($i = $debut; $i -lt 15; $i++) {
    Write-Host $i
}

# Initialisation multiple (séparées par des virgules)
for ($i = 0, $j = 10; $i -lt 5; $i++, $j--) {
    Write-Host "i = $i, j = $j"
}
```

### 🔹 Condition

La condition est évaluée **avant chaque itération**. Si elle retourne `$true`, le bloc de code s'exécute. Si elle retourne `$false`, la boucle se termine.

```powershell
# Condition simple
for ($i = 0; $i -lt 10; $i++) { }  # i inférieur à 10

# Condition avec opérateur différent
for ($i = 10; $i -ge 0; $i--) { }  # i supérieur ou égal à 0

# Condition complexe
for ($i = 0; $i -lt 100 -and $i -ne 50; $i++) {
    Write-Host $i  # S'arrête à 50
}
```

> [!tip] Opérateurs de comparaison courants
> 
> - `-lt` : inférieur à (less than)
> - `-le` : inférieur ou égal (less or equal)
> - `-gt` : supérieur à (greater than)
> - `-ge` : supérieur ou égal (greater or equal)
> - `-eq` : égal à (equal)
> - `-ne` : différent de (not equal)

### 🔹 Itération

L'itération définit comment la variable de contrôle change à chaque passage. Elle est exécutée **après chaque itération** du bloc de code.

```powershell
# Incrémentation standard
for ($i = 0; $i -lt 10; $i++) { }  # +1 à chaque tour

# Décrémentation
for ($i = 10; $i -ge 0; $i--) { }  # -1 à chaque tour

# Incrémentation personnalisée
for ($i = 0; $i -lt 100; $i += 5) {
    Write-Host $i  # 0, 5, 10, 15, ...
}

# Itération multiplicative
for ($i = 1; $i -lt 1000; $i *= 2) {
    Write-Host $i  # 1, 2, 4, 8, 16, 32, ...
}
```

---

## Compteurs et indices

### Utilisation comme compteur simple

```powershell
# Compter de 1 à 10
for ($compteur = 1; $compteur -le 10; $compteur++) {
    Write-Host "Compte : $compteur"
}
```

### Accès aux éléments d'un tableau par index

C'est l'un des cas d'usage les plus courants de la boucle `for` :

```powershell
$fruits = @("Pomme", "Banane", "Orange", "Fraise", "Kiwi")

for ($i = 0; $i -lt $fruits.Count; $i++) {
    Write-Host "Fruit $($i + 1) : $($fruits[$i])"
}
```

**Résultat :**

```
Fruit 1 : Pomme
Fruit 2 : Banane
Fruit 3 : Orange
Fruit 4 : Fraise
Fruit 5 : Kiwi
```

> [!tip] Astuce : Utiliser la propriété Count ou Length
> 
> - Pour les tableaux : `.Count` ou `.Length` (équivalents)
> - Attention : certaines collections utilisent uniquement `.Count`

### Parcours inverse d'un tableau

```powershell
$nombres = @(10, 20, 30, 40, 50)

for ($i = $nombres.Count - 1; $i -ge 0; $i--) {
    Write-Host $nombres[$i]
}
```

**Résultat :**

```
50
40
30
20
10
```

### Utilisation d'indices calculés

```powershell
$mots = @("PowerShell", "est", "un", "langage", "puissant")

# Parcourir seulement les éléments pairs
for ($i = 0; $i -lt $mots.Count; $i += 2) {
    Write-Host $mots[$i]
}
```

**Résultat :**

```
PowerShell
un
puissant
```

> [!example] Exemple pratique : Comparaison élément par élément
> 
> ```powershell
> $liste1 = @(1, 2, 3, 4, 5)
> $liste2 = @(1, 2, 9, 4, 5)
> 
> for ($i = 0; $i -lt $liste1.Count; $i++) {
>     if ($liste1[$i] -ne $liste2[$i]) {
>         Write-Host "Différence à l'index $i : $($liste1[$i]) vs $($liste2[$i])"
>     }
> }
> ```

---

## Boucles imbriquées

Les boucles `for` peuvent être imbriquées pour créer des structures multidimensionnelles ou parcourir des matrices.

### Exemple simple : Table de multiplication

```powershell
for ($i = 1; $i -le 5; $i++) {
    for ($j = 1; $j -le 5; $j++) {
        $resultat = $i * $j
        Write-Host "$i x $j = $resultat"
    }
    Write-Host "---"
}
```

### Matrice bidimensionnelle

```powershell
# Créer une matrice 3x3
$matrice = @(
    @(1, 2, 3),
    @(4, 5, 6),
    @(7, 8, 9)
)

# Parcourir la matrice
for ($ligne = 0; $ligne -lt $matrice.Count; $ligne++) {
    for ($colonne = 0; $colonne -lt $matrice[$ligne].Count; $colonne++) {
        Write-Host "[$ligne,$colonne] = $($matrice[$ligne][$colonne])" -NoNewline
        Write-Host " " -NoNewline
    }
    Write-Host ""  # Nouvelle ligne
}
```

### Pyramide de caractères

```powershell
$hauteur = 5

for ($i = 1; $i -le $hauteur; $i++) {
    # Espaces avant
    for ($j = 0; $j -lt ($hauteur - $i); $j++) {
        Write-Host " " -NoNewline
    }
    # Étoiles
    for ($k = 0; $k -lt (2 * $i - 1); $k++) {
        Write-Host "*" -NoNewline
    }
    Write-Host ""  # Nouvelle ligne
}
```

**Résultat :**

```
    *
   ***
  *****
 *******
*********
```

> [!warning] Attention à la complexité Les boucles imbriquées augmentent exponentiellement la complexité. Une boucle double avec 100 itérations chacune = 10 000 exécutions du code interne !

---

## Break et Continue

Ces mots-clés permettent de contrôler finement le flux d'exécution de la boucle.

### 🛑 Break : Sortir de la boucle

`break` interrompt immédiatement la boucle et passe à l'instruction suivante après la boucle.

```powershell
# Chercher un nombre spécifique
$nombres = @(5, 12, 8, 23, 15, 30, 7)

for ($i = 0; $i -lt $nombres.Count; $i++) {
    if ($nombres[$i] -eq 23) {
        Write-Host "Nombre 23 trouvé à l'index $i"
        break
    }
}
Write-Host "Recherche terminée"
```

**Résultat :**

```
Nombre 23 trouvé à l'index 3
Recherche terminée
```

### Break avec des boucles imbriquées

Par défaut, `break` ne sort que de la boucle la plus proche :

```powershell
for ($i = 0; $i -lt 3; $i++) {
    for ($j = 0; $j -lt 3; $j++) {
        Write-Host "i=$i, j=$j"
        if ($j -eq 1) { break }
    }
}
```

Pour sortir de plusieurs niveaux, utilisez des **labels** :

```powershell
:externe for ($i = 0; $i -lt 3; $i++) {
    :interne for ($j = 0; $j -lt 3; $j++) {
        Write-Host "i=$i, j=$j"
        if ($i -eq 1 -and $j -eq 1) {
            break externe  # Sort des deux boucles
        }
    }
}
Write-Host "Fin"
```

### ⏭️ Continue : Passer à l'itération suivante

`continue` saute le reste du code dans l'itération actuelle et passe directement à l'itération suivante.

```powershell
# Afficher seulement les nombres impairs
for ($i = 0; $i -lt 10; $i++) {
    if ($i % 2 -eq 0) {
        continue  # Sauter les nombres pairs
    }
    Write-Host $i
}
```

**Résultat :**

```
1
3
5
7
9
```

### Cas pratique : Traitement avec exclusions

```powershell
$fichiers = @("document.txt", "image.jpg", "script.ps1", "temp.tmp", "data.csv")

for ($i = 0; $i -lt $fichiers.Count; $i++) {
    # Ignorer les fichiers temporaires
    if ($fichiers[$i] -like "*.tmp") {
        continue
    }
    
    # Arrêter si on trouve un script
    if ($fichiers[$i] -like "*.ps1") {
        Write-Host "Script trouvé, arrêt du traitement"
        break
    }
    
    Write-Host "Traitement de : $($fichiers[$i])"
}
```

> [!tip] Bonnes pratiques
> 
> - Utilisez `break` pour arrêter une recherche dès qu'un élément est trouvé
> - Utilisez `continue` pour filtrer des éléments sans interrompre la boucle
> - Préférez des conditions claires plutôt qu'un abus de `break`/`continue`

---

## Cas d'usage typiques

### 1️⃣ Traitement par lots (batching)

```powershell
$elements = 1..100
$tailleBloc = 10

for ($i = 0; $i -lt $elements.Count; $i += $tailleBloc) {
    $fin = [Math]::Min($i + $tailleBloc, $elements.Count)
    $bloc = $elements[$i..($fin - 1)]
    
    Write-Host "Traitement du bloc $($i/$tailleBloc + 1) : $($bloc.Count) éléments"
    # Traitement du bloc...
}
```

### 2️⃣ Génération de séquences

```powershell
# Suite de Fibonacci
$n = 10
$fib = @(0, 1)

for ($i = 2; $i -lt $n; $i++) {
    $fib += $fib[$i - 1] + $fib[$i - 2]
}

Write-Host "Les $n premiers nombres de Fibonacci :"
$fib
```

### 3️⃣ Manipulation de chaînes caractère par caractère

```powershell
$texte = "PowerShell"
$inverse = ""

for ($i = $texte.Length - 1; $i -ge 0; $i--) {
    $inverse += $texte[$i]
}

Write-Host "Texte inversé : $inverse"
```

### 4️⃣ Synchronisation de deux collections

```powershell
$noms = @("Alice", "Bob", "Charlie")
$ages = @(25, 30, 35)

for ($i = 0; $i -lt $noms.Count; $i++) {
    Write-Host "$($noms[$i]) a $($ages[$i]) ans"
}
```

### 5️⃣ Modification d'éléments en place

```powershell
$nombres = @(1, 2, 3, 4, 5)

# Doubler chaque nombre
for ($i = 0; $i -lt $nombres.Count; $i++) {
    $nombres[$i] = $nombres[$i] * 2
}

Write-Host $nombres  # 2 4 6 8 10
```

### 6️⃣ Recherche avec condition complexe

```powershell
$utilisateurs = @(
    @{Nom="Alice"; Age=25; Actif=$true},
    @{Nom="Bob"; Age=30; Actif=$false},
    @{Nom="Charlie"; Age=35; Actif=$true}
)

for ($i = 0; $i -lt $utilisateurs.Count; $i++) {
    if ($utilisateurs[$i].Actif -and $utilisateurs[$i].Age -gt 25) {
        Write-Host "Utilisateur trouvé : $($utilisateurs[$i].Nom)"
        break
    }
}
```

> [!example] Exemple avancé : Rotation de tableau
> 
> ```powershell
> function Rotate-Array {
>     param($array, $positions)
>     
>     $longueur = $array.Count
>     $rotation = $positions % $longueur
>     $resultat = @() * $longueur
>     
>     for ($i = 0; $i -lt $longueur; $i++) {
>         $nouvelIndex = ($i + $rotation) % $longueur
>         $resultat[$nouvelIndex] = $array[$i]
>     }
>     
>     return $resultat
> }
> 
> $original = @(1, 2, 3, 4, 5)
> $rotated = Rotate-Array $original 2
> Write-Host $rotated  # 4 5 1 2 3
> ```

---

## Performance vs Foreach

### Comparaison des approches

|Critère|`for`|`foreach` / `ForEach-Object`|
|---|---|---|
|**Accès par index**|✅ Natif|❌ Nécessite manipulation|
|**Modification en place**|✅ Simple|⚠️ Complexe|
|**Lisibilité**|⚠️ Moyenne|✅ Excellente|
|**Performance (grandes collections)**|✅ Rapide|⚠️ Variable|
|**Contrôle du flux**|✅ Total (indices)|⚠️ Limité|

### Benchmarks typiques

```powershell
$tableau = 1..10000

# Mesure avec for
$tempsFor = Measure-Command {
    for ($i = 0; $i -lt $tableau.Count; $i++) {
        $x = $tableau[$i] * 2
    }
}

# Mesure avec foreach (instruction)
$tempsForeach = Measure-Command {
    foreach ($item in $tableau) {
        $x = $item * 2
    }
}

# Mesure avec ForEach-Object (pipeline)
$tempsForEachObject = Measure-Command {
    $tableau | ForEach-Object { $_ * 2 }
}

Write-Host "for : $($tempsFor.TotalMilliseconds) ms"
Write-Host "foreach : $($tempsForeach.TotalMilliseconds) ms"
Write-Host "ForEach-Object : $($tempsForEachObject.TotalMilliseconds) ms"
```

**Résultats typiques :**

- `for` : ~5-10 ms
- `foreach` : ~5-10 ms (similaire)
- `ForEach-Object` : ~50-100 ms (plus lent, overhead du pipeline)

> [!info] Interprétation des résultats
> 
> - `for` et `foreach` (instruction) ont des performances similaires
> - `ForEach-Object` (cmdlet pipeline) est plus lent mais plus flexible
> - Pour les petites collections (<1000 éléments), la différence est négligeable

### Quand utiliser `for` plutôt que `foreach` ?

#### ✅ Utilisez `for` quand :

1. **Vous avez besoin de l'index** :

```powershell
for ($i = 0; $i -lt $array.Count; $i++) {
    Write-Host "Index $i : $($array[$i])"
}
```

2. **Vous devez modifier le tableau en place** :

```powershell
for ($i = 0; $i -lt $nombres.Count; $i++) {
    $nombres[$i] = $nombres[$i] * 2  # Modification directe
}
```

3. **Vous voulez un contrôle précis sur l'itération** :

```powershell
# Parcourir de 2 en 2
for ($i = 0; $i -lt $array.Count; $i += 2) {
    # Traitement
}
```

4. **Vous devez parcourir à l'envers** :

```powershell
for ($i = $array.Count - 1; $i -ge 0; $i--) {
    # Traitement inverse
}
```

#### ✅ Utilisez `foreach` quand :

1. **Vous parcourez simplement une collection** :

```powershell
foreach ($item in $collection) {
    Write-Host $item
}
```

2. **La lisibilité est prioritaire** :

```powershell
# Plus clair avec foreach
foreach ($user in $users) {
    Write-Host $user.Name
}
```

3. **Vous n'avez pas besoin de l'index** :

```powershell
foreach ($fichier in $fichiers) {
    Remove-Item $fichier
}
```

### Optimisations pour `for`

```powershell
# ❌ Moins efficace : Count appelé à chaque itération
for ($i = 0; $i -lt $array.Count; $i++) { }

# ✅ Plus efficace : Count stocké une fois
$count = $array.Count
for ($i = 0; $i -lt $count; $i++) { }

# ✅ Encore mieux : décrémenter (comparaison à 0 plus rapide)
for ($i = $array.Count - 1; $i -ge 0; $i--) { }
```

> [!tip] Règle générale
> 
> - Pour la clarté : `foreach`
> - Pour l'index ou les modifications : `for`
> - Pour les pipelines complexes : `ForEach-Object`
> - Pour la performance maximale sur grandes collections : `for` ou `foreach` (instruction)

### Pièges de performance courants

#### ❌ Évitez les opérations coûteuses dans la condition

```powershell
# Mauvais : fonction appelée à chaque test
for ($i = 0; $i -lt (Get-HeavyComputation); $i++) { }

# Bon : calculer une fois
$limite = Get-HeavyComputation
for ($i = 0; $i -lt $limite; $i++) { }
```

#### ❌ Évitez les modifications de collection pendant l'itération

```powershell
# Dangereux : modifier pendant l'itération
for ($i = 0; $i -lt $items.Count; $i++) {
    if ($condition) {
        $items.RemoveAt($i)  # Décale les indices !
    }
}

# Solution : itérer à l'envers pour les suppressions
for ($i = $items.Count - 1; $i -ge 0; $i--) {
    if ($condition) {
        $items.RemoveAt($i)
    }
}
```

---

## 🎯 Récapitulatif

### Points clés à retenir

1. **Syntaxe** : `for (init; condition; itération) { code }`
2. **Trois composantes** : initialisation (1 fois), condition (avant chaque tour), itération (après chaque tour)
3. **Accès par index** : idéal pour manipuler des tableaux avec `.Count`
4. **Boucles imbriquées** : possibles mais attention à la complexité
5. **Contrôle** : `break` sort, `continue` passe au suivant
6. **Performance** : similaire à `foreach` pour les instructions, supérieur à `ForEach-Object`

### Tableau de décision rapide

|Situation|Utilisez|
|---|---|
|Parcours simple sans index|`foreach`|
|Besoin de l'index|`for`|
|Modification en place|`for`|
|Pipeline de transformations|`ForEach-Object`|
|Parcours inverse|`for`|
|Contrôle précis sur l'itération|`for`|
|Lisibilité maximale|`foreach`|

> [!warning] Erreurs fréquentes à éviter
> 
> - Oublier que les indices commencent à 0
> - Utiliser `-le` au lieu de `-lt` avec `.Count` (provoque un dépassement)
> - Modifier une collection pendant qu'on la parcourt
> - Créer des boucles infinies par erreur dans la condition
> - Abuser des boucles imbriquées (privilégier des fonctions)