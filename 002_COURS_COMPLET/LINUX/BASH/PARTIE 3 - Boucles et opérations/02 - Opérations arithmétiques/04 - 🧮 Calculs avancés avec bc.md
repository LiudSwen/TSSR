

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

## Introduction à bc

> [!info] Qu'est-ce que bc ? **bc** (Basic Calculator) est un calculateur en ligne de commande qui permet d'effectuer des calculs arithmétiques avec **précision arbitraire**, notamment des **nombres décimaux**. Contrairement aux opérateurs arithmétiques natifs de Bash qui ne gèrent que les entiers, bc est indispensable pour les calculs scientifiques et financiers.

### Pourquoi utiliser bc ?

Les expansions arithmétiques Bash (`$(( ))` et `$[ ]`) ne supportent que les **entiers**. Dès que vous avez besoin de :

- Nombres décimaux (virgule flottante)
- Fonctions mathématiques (trigonométrie, logarithmes, etc.)
- Précision contrôlée
- Calculs complexes

**→ bc devient votre outil de référence.**

> [!example] Limitation de Bash vs bc
> 
> ```bash
> # Bash - Perte de précision
> echo $((10 / 3))  # Résultat : 3
> 
> # bc - Précision décimale
> echo "10 / 3" | bc -l  # Résultat : 3.33333333333333333333
> ```

---

## Syntaxe de base avec bc

### Méthode par pipe

La syntaxe la plus courante consiste à envoyer l'expression via un **pipe** :

```bash
echo "expression_mathématique" | bc
```

> [!example] Exemples de base
> 
> ```bash
> # Addition
> echo "15 + 27" | bc
> # Résultat : 42
> 
> # Division décimale
> echo "22 / 7" | bc
> # Résultat : 3 (sans option -l, bc tronque)
> 
> # Puissance
> echo "2 ^ 10" | bc
> # Résultat : 1024
> 
> # Modulo
> echo "17 % 5" | bc
> # Résultat : 2
> 
> # Expression complexe
> echo "(100 + 50) * 3 / 2" | bc
> # Résultat : 225
> ```

### Opérateurs supportés

|Opérateur|Fonction|Exemple|
|---|---|---|
|`+`|Addition|`5 + 3` → 8|
|`-`|Soustraction|`10 - 4` → 6|
|`*`|Multiplication|`7 * 6` → 42|
|`/`|Division|`20 / 4` → 5|
|`%`|Modulo (reste)|`17 % 5` → 2|
|`^`|Puissance|`2 ^ 8` → 256|
|`( )`|Parenthèses|`(5 + 3) * 2` → 16|

> [!warning] Attention à l'échappement Dans certains shells, les caractères `*` et `()` peuvent nécessiter un échappement ou des guillemets pour éviter l'expansion du shell.

### Utilisation avec des variables

```bash
# Stocker le résultat dans une variable
resultat=$(echo "125 * 8" | bc)
echo "Résultat : $resultat"

# Avec des variables Bash
a=15
b=7
resultat=$(echo "$a + $b" | bc)
echo "Somme : $resultat"

# Expression plus complexe
prix=19.99
quantite=5
tva=0.20
total=$(echo "$prix * $quantite * (1 + $tva)" | bc)
echo "Total TTC : $total"
```

---

## Option -l pour la bibliothèque mathématique

L'option `-l` (library) charge la **bibliothèque mathématique standard** de bc, qui :

- Active les calculs en **virgule flottante**
- Définit automatiquement `scale=20` (20 décimales de précision)
- Rend disponibles les fonctions mathématiques avancées

```bash
echo "expression" | bc -l
```

> [!example] Comparaison avec et sans -l
> 
> ```bash
> # Sans -l : résultat entier
> echo "10 / 3" | bc
> # Résultat : 3
> 
> # Avec -l : résultat décimal (20 décimales par défaut)
> echo "10 / 3" | bc -l
> # Résultat : 3.33333333333333333333
> 
> # Division complexe
> echo "22 / 7" | bc -l
> # Résultat : 3.14285714285714285714
> ```

### Cas d'usage typiques

```bash
# Calcul de moyenne
notes="15 12 18 14"
somme=$(echo "$notes" | tr ' ' '+' | bc)
moyenne=$(echo "$somme / 4" | bc -l)
echo "Moyenne : $moyenne"

# Conversion de devises
montant_euros=100
taux_change=1.0856
montant_dollars=$(echo "$montant_euros * $taux_change" | bc -l)
echo "$montant_euros EUR = $montant_dollars USD"

# Calcul de pourcentage
valeur=850
total=1000
pourcentage=$(echo "scale=2; ($valeur / $total) * 100" | bc -l)
echo "Pourcentage : $pourcentage%"
```

> [!tip] Astuce L'option `-l` est presque toujours recommandée pour les scripts réels, sauf si vous avez spécifiquement besoin d'une division entière.

---

## Gestion de la précision avec scale

La variable spéciale `scale` contrôle le **nombre de décimales** dans les résultats.

### Syntaxe

```bash
echo "scale=N; expression" | bc
```

Où `N` est le nombre de décimales souhaité.

> [!info] Valeur par défaut
> 
> - Sans `-l` : `scale=0` (entiers uniquement)
> - Avec `-l` : `scale=20` (20 décimales)

### Exemples d'utilisation

```bash
# 2 décimales (idéal pour l'argent)
echo "scale=2; 10 / 3" | bc
# Résultat : 3.33

# 5 décimales
echo "scale=5; 22 / 7" | bc
# Résultat : 3.14285

# 10 décimales
echo "scale=10; 1 / 3" | bc
# Résultat : .3333333333

# Aucune décimale (comportement par défaut)
echo "scale=0; 10 / 3" | bc
# Résultat : 3
```

### Scale dans des calculs complexes

```bash
# Calcul financier précis
capital=1000
taux=0.05
annees=10
montant=$(echo "scale=2; $capital * (1 + $taux) ^ $annees" | bc -l)
echo "Montant après $annees ans : $montant €"

# Calcul d'aire avec précision scientifique
rayon=5.75
aire=$(echo "scale=6; 3.141592653589793 * $rayon ^ 2" | bc)
echo "Aire du cercle : $aire"

# Combinaison de scale et -l
echo "scale=4; sqrt(2)" | bc -l
# Résultat : 1.4142
```

> [!warning] Scale s'applique différemment selon les opérations
> 
> - **Division** : scale détermine le nombre de décimales du résultat
> - **Multiplication/Addition** : scale définit le minimum, mais le résultat peut avoir plus de décimales
> - **Fonctions** : scale contrôle la précision de sortie

```bash
# Exemple de comportement
echo "scale=2; 1.5 * 1.5" | bc
# Résultat : 2.25 (pas tronqué à 2.00)

echo "scale=2; 10 / 3" | bc
# Résultat : 3.33 (tronqué à 2 décimales)
```

---

## Fonctions mathématiques avancées

Avec l'option `-l`, bc fournit des **fonctions mathématiques** puissantes.

### Fonctions disponibles

|Fonction|Description|Exemple|
|---|---|---|
|`sqrt(x)`|Racine carrée|`sqrt(16)` → 4|
|`s(x)`|Sinus (radians)|`s(1.5708)` → 1|
|`c(x)`|Cosinus (radians)|`c(3.14159)` → -1|
|`a(x)`|Arctangente|`a(1)` → 0.7854|
|`l(x)`|Logarithme naturel (ln)|`l(2.71828)` → 1|
|`e(x)`|Exponentielle (e^x)|`e(1)` → 2.71828|

> [!info] Note sur les angles Les fonctions trigonométriques utilisent des **radians**, pas des degrés. Pour convertir : `radians = degrés * π / 180`

### Exemples pratiques

```bash
# Racine carrée
echo "scale=4; sqrt(2)" | bc -l
# Résultat : 1.4142

# Calcul de π avec arctangente
# π = 4 * arctan(1)
pi=$(echo "scale=10; 4 * a(1)" | bc -l)
echo "Pi : $pi"
# Résultat : 3.1415926532

# Sinus de 30° (π/6 radians)
echo "scale=4; s(3.14159 / 6)" | bc -l
# Résultat : 0.5000

# Logarithme naturel
echo "scale=5; l(10)" | bc -l
# Résultat : 2.30258

# Exponentielle
echo "scale=5; e(2)" | bc -l
# Résultat : 7.38905
```

### Fonctions composées

```bash
# Calcul d'hypoténuse (théorème de Pythagore)
a=3
b=4
hypotenuse=$(echo "scale=4; sqrt($a^2 + $b^2)" | bc -l)
echo "Hypoténuse : $hypotenuse"
# Résultat : 5.0000

# Distance entre deux points
x1=0; y1=0
x2=3; y2=4
distance=$(echo "scale=4; sqrt(($x2-$x1)^2 + ($y2-$y1)^2)" | bc -l)
echo "Distance : $distance"

# Calcul d'une formule physique (énergie cinétique)
masse=75  # kg
vitesse=10  # m/s
energie=$(echo "scale=2; 0.5 * $masse * $vitesse^2" | bc)
echo "Énergie cinétique : $energie J"
```

> [!tip] Créer des fonctions personnalisées bc permet de définir des fonctions réutilisables dans un here document (voir section suivante).

---

## Here documents avec bc

Pour des **calculs complexes** ou **multiples opérations**, les **here documents** offrent une syntaxe plus lisible et puissante.

### Syntaxe de base

```bash
bc << EOF
scale=4
expression1
expression2
EOF
```

Ou avec capture du résultat :

```bash
resultat=$(bc -l << EOF
scale=4
expression
EOF
)
```

> [!example] Exemple simple
> 
> ```bash
> bc << EOF
> scale=2
> a = 100
> b = 25
> a + b
> a - b
> a * b
> a / b
> EOF
> ```
> 
> Sortie :
> 
> ```
> 125
> 75
> 2500
> 4.00
> ```

### Définir et utiliser des variables

```bash
resultat=$(bc -l << EOF
scale=4
# Définir des variables
rayon = 5
pi = 4 * a(1)

# Calculs
circonference = 2 * pi * rayon
aire = pi * rayon ^ 2

# Afficher les résultats
circonference
aire
EOF
)

echo "Résultats : $resultat"
```

### Créer des fonctions personnalisées

bc permet de définir des fonctions avec la syntaxe `define nom(paramètres) { corps }`.

```bash
bc -l << EOF
scale=4

# Définir une fonction pour calculer l'aire d'un cercle
define aire_cercle(r) {
    return 4 * a(1) * r * r
}

# Définir une fonction pour le volume d'une sphère
define volume_sphere(r) {
    return (4/3) * 4 * a(1) * r * r * r
}

# Utiliser les fonctions
aire_cercle(5)
volume_sphere(3)
EOF
```

> [!example] Fonction de conversion température
> 
> ```bash
> temperature_f=98.6
> 
> celsius=$(bc -l << EOF
> scale=2
> 
> # Fonction Fahrenheit vers Celsius
> define f_to_c(f) {
>     return (f - 32) * 5 / 9
> }
> 
> f_to_c($temperature_f)
> EOF
> )
> 
> echo "$temperature_f°F = $celsius°C"
> ```

### Calculs multiples avec structure

```bash
# Script de calcul financier
capital=10000
taux_annuel=5
duree_mois=36

bc -l << EOF
scale=2

# Variables
capital = $capital
taux_annuel = $taux_annuel / 100
taux_mensuel = taux_annuel / 12
duree = $duree_mois

# Calcul de la mensualité (formule d'amortissement)
mensualite = capital * (taux_mensuel * (1 + taux_mensuel)^duree) / ((1 + taux_mensuel)^duree - 1)

# Calcul du coût total
cout_total = mensualite * duree
interets = cout_total - capital

# Afficher les résultats
print "Mensualité : ", mensualite, "\n"
print "Coût total : ", cout_total, "\n"
print "Intérêts : ", interets, "\n"
EOF
```

### Boucles et structures de contrôle

bc supporte des structures de contrôle basiques :

```bash
bc << EOF
# Boucle for
for (i = 1; i <= 5; i++) {
    i * i
}

# Condition if
x = 10
if (x > 5) {
    print "x est grand\n"
}

# Boucle while
n = 1
while (n <= 3) {
    print "Itération ", n, "\n"
    n = n + 1
}
EOF
```

> [!tip] Astuce pour scripts complexes Pour les calculs très complexes nécessitant de nombreuses lignes, créez un **fichier bc séparé** et exécutez-le :
> 
> ```bash
> bc -l calculs.bc
> # ou
> bc -l < calculs.bc
> ```

---

## Pièges courants et bonnes pratiques

### ⚠️ Piège 1 : Oublier -l pour les décimales

```bash
# ❌ Mauvais : résultat tronqué
echo "10 / 3" | bc
# Résultat : 3

# ✅ Bon : résultat décimal
echo "10 / 3" | bc -l
# Résultat : 3.33333333333333333333
```

### ⚠️ Piège 2 : Espaces dans les expressions

```bash
# ❌ Attention avec les variables non quotées
a=5
b=3
echo $a + $b | bc  # Peut ne pas fonctionner selon le contexte

# ✅ Toujours quoter l'expression
echo "$a + $b" | bc
```

### ⚠️ Piège 3 : Scale ne s'applique pas uniformément

```bash
# La multiplication garde plus de décimales que scale
echo "scale=2; 1.111 * 1.111" | bc
# Résultat : 1.234321 (pas 1.23)

# Pour forcer le tronquage, diviser par 1
echo "scale=2; (1.111 * 1.111) / 1" | bc
# Résultat : 1.23
```

### ⚠️ Piège 4 : Nombres commençant par 0

```bash
# ❌ bc interprète les nombres commençant par 0 en base 8 (octal)
echo "010 + 5" | bc
# Résultat : 13 (car 010 en octal = 8 en décimal)

# ✅ Éviter les zéros non significatifs
echo "10 + 5" | bc
# Résultat : 15
```

### ⚠️ Piège 5 : Fonctions trigonométriques en degrés

```bash
# ❌ Mauvais : utiliser des degrés directement
echo "s(45)" | bc -l
# Résultat : 0.85090352453... (sin(45 radians) ≠ sin(45°))

# ✅ Bon : convertir en radians
degres=45
echo "scale=4; s($degres * 4 * a(1) / 180)" | bc -l
# Résultat : 0.7071 (sin(45°) correct)
```

### ✅ Bonnes pratiques

> [!tip] Recommandations
> 
> 1. **Toujours utiliser -l** pour les calculs décimaux (sauf besoin spécifique)
> 2. **Définir scale explicitement** au début de vos expressions
> 3. **Quoter les expressions** avec des variables : `"$a + $b"`
> 4. **Stocker π dans une variable** si utilisé souvent : `pi=$(echo "4*a(1)" | bc -l)`
> 5. **Utiliser here documents** pour les calculs complexes (lisibilité)
> 6. **Commenter vos formules** dans les here documents
> 7. **Tester avec des valeurs connues** avant de lancer sur des données réelles

### Exemple de script bien structuré

```bash
#!/bin/bash

# Script de calcul d'intérêts composés
capital=1000
taux=5
annees=10

resultat=$(bc -l << EOF
# Configuration
scale=2

# Variables
c = $capital
t = $taux / 100
n = $annees

# Formule des intérêts composés : C * (1 + t)^n
montant_final = c * (1 + t) ^ n
interets = montant_final - c

# Retourner le montant final
montant_final
EOF
)

echo "Capital initial : $capital €"
echo "Taux : $taux%"
echo "Durée : $annees ans"
echo "Montant final : $resultat €"
```

---

> [!success] Récapitulatif
> 
> - **bc** est l'outil de référence pour les calculs décimaux en Bash
> - **Syntaxe pipe** : `echo "expression" | bc`
> - **Option -l** : active les décimales et fonctions mathématiques
> - **scale** : contrôle la précision des résultats
> - **Fonctions** : sqrt, s, c, a, l, e disponibles avec -l
> - **Here documents** : idéaux pour calculs complexes et fonctions personnalisées

---

_Fin de la section sur bc_