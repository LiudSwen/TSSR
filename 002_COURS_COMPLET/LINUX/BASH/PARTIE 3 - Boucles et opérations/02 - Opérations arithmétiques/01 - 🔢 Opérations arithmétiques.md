

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

L'expansion arithmétique `$(( ))` est le mécanisme principal pour effectuer des calculs en Bash. Contrairement aux commandes externes comme `expr` ou `bc`, elle est intégrée au shell et donc beaucoup plus rapide et efficace.

> [!info] Pourquoi utiliser $(( )) ?
> 
> - **Performance** : Pas de processus externe à lancer
> - **Simplicité** : Syntaxe claire et naturelle
> - **Intégration** : Fonctionne directement avec les variables du shell
> - **Portabilité** : Standard POSIX, disponible partout

---

## 🧮 Expansion arithmétique $(( ))

### Syntaxe de base

L'expansion arithmétique s'écrit entre doubles parenthèses : `$(( expression ))`

```bash
# Calcul simple
resultat=$((5 + 3))
echo $resultat  # Affiche : 8

# Utilisation directe dans echo
echo "La somme est : $((10 + 20))"  # Affiche : La somme est : 30

# Dans une condition
if ((nombre > 10)); then
    echo "Nombre supérieur à 10"
fi

# Affectation directe (sans $)
((resultat = 15 * 2))
echo $resultat  # Affiche : 30
```

> [!tip] Deux formes d'utilisation
> 
> - `$(( expression ))` : Expansion qui retourne une valeur (à utiliser avec `$`)
> - `(( expression ))` : Évaluation simple sans expansion (pour affectations et tests)

---

### Opérateurs arithmétiques de base

Les opérateurs mathématiques classiques sont disponibles :

|Opérateur|Description|Exemple|Résultat|
|---|---|---|---|
|`+`|Addition|`$((5 + 3))`|8|
|`-`|Soustraction|`$((10 - 4))`|6|
|`*`|Multiplication|`$((6 * 7))`|42|
|`/`|Division entière|`$((15 / 4))`|3|
|`%`|Modulo (reste)|`$((15 % 4))`|3|
|`**`|Puissance|`$((2 ** 8))`|256|

```bash
# Exemples pratiques
a=10
b=3

somme=$((a + b))
difference=$((a - b))
produit=$((a * b))
quotient=$((a / b))        # Division entière : 3
reste=$((a % b))           # Reste de la division : 1
puissance=$((a ** b))      # 10^3 = 1000

echo "Somme: $somme"
echo "Différence: $difference"
echo "Produit: $produit"
echo "Quotient: $quotient"
echo "Reste: $reste"
echo "Puissance: $puissance"
```

> [!warning] Division entière uniquement Bash ne gère que les entiers. `$((10 / 3))` donne `3`, pas `3.333...` Pour des calculs avec décimales, il faut utiliser `bc` ou `awk`.

#### Ordre de priorité des opérations

Les opérations suivent les règles mathématiques classiques :

```bash
# La multiplication est prioritaire
echo $((2 + 3 * 4))      # Affiche : 14 (pas 20)

# Utilisation des parenthèses pour forcer l'ordre
echo $(((2 + 3) * 4))    # Affiche : 20

# Ordre de priorité (du plus au moins prioritaire)
# 1. Parenthèses ()
# 2. Puissance **
# 3. Multiplication *, Division /, Modulo %
# 4. Addition +, Soustraction -

calcul=$((2 + 3 * 4 ** 2 - 10 / 2))
# Évaluation : 2 + 3 * 16 - 5 = 2 + 48 - 5 = 45
echo $calcul  # Affiche : 45
```

---

### Opérateurs de bits

Bash supporte les opérations au niveau des bits, utiles pour les manipulations binaires.

|Opérateur|Description|Exemple|Résultat (binaire)|
|---|---|---|---|
|`&`|ET bit à bit|`$((12 & 10))`|8 (1100 & 1010 = 1000)|
|`\|`|OU bit à bit|`$((12 \| 10))`|14 (1100 \| 1010 = 1110)|
|`^`|XOR bit à bit|`$((12 ^ 10))`|6 (1100 ^ 1010 = 0110)|
|`~`|NON bit à bit|`$((~10))`|-11 (complément à 2)|
|`<<`|Décalage à gauche|`$((5 << 2))`|20 (101 << 2 = 10100)|
|`>>`|Décalage à droite|`$((20 >> 2))`|5 (10100 >> 2 = 101)|

```bash
# Exemples pratiques

# ET bit à bit : utile pour tester des flags
flags=7    # 0111 en binaire
masque=3   # 0011 en binaire
resultat=$((flags & masque))
echo $resultat  # Affiche : 3 (0011)

# OU bit à bit : utile pour combiner des flags
flag1=4    # 0100
flag2=2    # 0010
combine=$((flag1 | flag2))
echo $combine  # Affiche : 6 (0110)

# XOR : utile pour basculer des bits
valeur=5   # 0101
masque=3   # 0011
bascule=$((valeur ^ masque))
echo $bascule  # Affiche : 6 (0110)

# Décalage à gauche : équivaut à multiplier par 2^n
nombre=5
decale=$((nombre << 2))  # 5 * 2^2 = 20
echo $decale

# Décalage à droite : équivaut à diviser par 2^n
nombre=20
decale=$((nombre >> 2))  # 20 / 2^2 = 5
echo $decale
```

> [!example] Cas d'usage : Gestion de permissions
> 
> ```bash
> # Définition des permissions (style Unix)
> READ=4    # 100 en binaire
> WRITE=2   # 010 en binaire
> EXEC=1    # 001 en binaire
> 
> # Combiner des permissions
> permissions=$((READ | WRITE))  # 110 = 6
> 
> # Vérifier une permission
> if ((permissions & READ)); then
>     echo "Permission de lecture accordée"
> fi
> 
> # Retirer une permission
> permissions=$((permissions & ~WRITE))  # Retire l'écriture
> ```

---

### Incrémentation et décrémentation

Les opérateurs `++` et `--` permettent d'augmenter ou diminuer une variable de 1.

#### Pré-incrémentation vs Post-incrémentation

```bash
# Post-incrémentation (i++) : utilise puis incrémente
i=5
echo $((i++))  # Affiche : 5 (valeur avant incrémentation)
echo $i        # Affiche : 6 (valeur après)

# Pré-incrémentation (++i) : incrémente puis utilise
i=5
echo $((++i))  # Affiche : 6 (valeur après incrémentation)
echo $i        # Affiche : 6

# Post-décrémentation (i--)
i=5
echo $((i--))  # Affiche : 5
echo $i        # Affiche : 4

# Pré-décrémentation (--i)
i=5
echo $((--i))  # Affiche : 4
echo $i        # Affiche : 4
```

> [!info] Différence clé
> 
> - **Pré-incrémentation** (`++i`) : modifie **puis** retourne la nouvelle valeur
> - **Post-incrémentation** (`i++`) : retourne la valeur actuelle **puis** modifie

#### Utilisation dans les boucles

```bash
# Compteur simple
compteur=0
while ((compteur < 5)); do
    echo "Tour $compteur"
    ((compteur++))
done

# Dans une boucle for style C
for ((i=0; i<10; i++)); do
    echo "Itération $i"
done

# Décrémentation pour parcourir à l'envers
for ((i=10; i>0; i--)); do
    echo "Compte à rebours : $i"
done
```

> [!tip] Forme compacte
> 
> ```bash
> # Au lieu de :
> compteur=$((compteur + 1))
> 
> # Utilisez simplement :
> ((compteur++))
> ```

---

### Affectation combinée

Les opérateurs d'affectation combinée permettent de modifier une variable en une seule opération.

|Opérateur|Équivalent à|Description|
|---|---|---|
|`+=`|`x = x + y`|Ajouter puis assigner|
|`-=`|`x = x - y`|Soustraire puis assigner|
|`*=`|`x = x * y`|Multiplier puis assigner|
|`/=`|`x = x / y`|Diviser puis assigner|
|`%=`|`x = x % y`|Modulo puis assigner|
|`**=`|`x = x ** y`|Puissance puis assigner|
|`&=`|`x = x & y`|ET bit à bit puis assigner|
|`\|=`|`x = x \| y`|OU bit à bit puis assigner|
|`^=`|`x = x ^ y`|XOR puis assigner|
|`<<=`|`x = x << y`|Décalage gauche puis assigner|
|`>>=`|`x = x >> y`|Décalage droite puis assigner|

```bash
# Exemples d'utilisation

# Addition
score=100
((score += 50))      # score = score + 50
echo $score          # Affiche : 150

# Soustraction
vie=100
((vie -= 25))        # vie = vie - 25
echo $vie            # Affiche : 75

# Multiplication
prix=10
((prix *= 3))        # prix = prix * 3
echo $prix           # Affiche : 30

# Division
total=100
((total /= 4))       # total = total / 4
echo $total          # Affiche : 25

# Modulo
nombre=17
((nombre %= 5))      # nombre = nombre % 5
echo $nombre         # Affiche : 2

# Puissance
base=2
((base **= 5))       # base = base ** 5
echo $base           # Affiche : 32

# Opérateurs de bits
flags=7
((flags &= 3))       # flags = flags & 3
echo $flags          # Affiche : 3
```

> [!example] Cas pratique : Calcul de statistiques
> 
> ```bash
> # Calcul d'une moyenne progressive
> total=0
> count=0
> 
> for valeur in 10 20 30 40 50; do
>     ((total += valeur))
>     ((count++))
> done
> 
> moyenne=$((total / count))
> echo "Moyenne : $moyenne"  # Affiche : Moyenne : 30
> ```

---

### Variables sans $ dans $(( ))

À l'intérieur de `$(( ))`, vous pouvez référencer des variables **sans le symbole `$`**.

```bash
# Avec $ (fonctionne)
a=10
b=5
resultat=$(($a + $b))
echo $resultat  # Affiche : 15

# Sans $ (recommandé dans $(( )))
resultat=$((a + b))
echo $resultat  # Affiche : 15

# Les deux formes sont identiques dans ce contexte
x=7
y=3
echo $((x * y))    # Affiche : 21
echo $(($x * $y))  # Affiche : 21 (identique)
```

> [!tip] Préférez la forme sans $
> 
> - Plus lisible
> - Moins de caractères
> - Convention standard en Bash

#### Cas où le $ peut être utile

```bash
# Expansion de variable contenant un nom de variable
var_name="nombre"
nombre=42

# Avec $ pour l'indirection
echo $((${!var_name} + 10))  # Affiche : 52

# Variables avec caractères spéciaux dans le nom
declare -A tableau
tableau[clé]=10

# Nécessite $ pour les tableaux associatifs
echo $((${tableau[clé]} + 5))  # Affiche : 15
```

#### Déclaration et utilisation simultanées

```bash
# Vous pouvez assigner et utiliser en même temps
((total = 0))
((total = total + 10))  # total vaut maintenant 10

# Ou de manière plus compacte
((total = a = 5, b = 10, a + b))
echo $total  # Affiche : 15

# Affectations multiples avec l'opérateur virgule
((x = 1, y = 2, z = x + y))
echo "$x $y $z"  # Affiche : 1 2 3
```

> [!warning] Variables non initialisées Dans un contexte arithmétique, une variable non initialisée vaut **0** :
> 
> ```bash
> unset var  # Variable non définie
> echo $((var + 5))  # Affiche : 5 (var vaut 0)
> 
> # Cela peut causer des bugs silencieux !
> resultat=$((valeur_inexistante * 10))
> echo $resultat  # Affiche : 0 (pas d'erreur)
> ```

---

## ⚠️ Pièges courants

### 1. Division par zéro

```bash
# ❌ Erreur : division par zéro
a=10
b=0
resultat=$((a / b))  # Erreur : division by 0 (error token is "0")

# ✅ Toujours vérifier avant de diviser
if ((b != 0)); then
    resultat=$((a / b))
else
    echo "Erreur : division par zéro impossible"
fi
```

### 2. Nombres à virgule

```bash
# ❌ Bash ne gère pas les décimales
prix=19.99  # Sera traité comme une chaîne

# Cette opération échoue
total=$((prix * 2))  # Erreur : invalid arithmetic operator

# ✅ Solution 1 : travailler en centimes
prix_centimes=1999  # 19.99€ en centimes
total=$((prix_centimes * 2))  # 3998 centimes
echo "$((total / 100)),$((total % 100))€"  # Affiche : 39,98€

# ✅ Solution 2 : utiliser bc pour les décimales
total=$(echo "19.99 * 2" | bc)
echo "$total€"  # Affiche : 39.98€
```

### 3. Débordement d'entier

```bash
# Les nombres sont limités par la taille des entiers signés (64 bits)
grand_nombre=$((2 ** 62))
echo $grand_nombre  # Fonctionne

tres_grand=$((2 ** 63))
echo $tres_grand  # Débordement ! Valeur négative
```

### 4. Espaces et syntaxe

```bash
# ❌ Attention aux espaces hors de $(( ))
resultat = $((5 + 3))  # Erreur de syntaxe

# ✅ Pas d'espace autour du =
resultat=$((5 + 3))

# ✅ Mais les espaces sont OK dans $(( ))
resultat=$(( 5 + 3 ))
resultat=$((5+3))  # Les deux fonctionnent
```

### 5. Confusion entre $(( )) et $( )

```bash
# $(( )) : expansion arithmétique
calcul=$((5 + 3))
echo $calcul  # Affiche : 8

# $( ) : substitution de commande
date=$(date +%Y)
echo $date  # Affiche : 2025

# ❌ Ne pas confondre
mauvais=$(5 + 3)  # Erreur : 5 n'est pas une commande
```

---

## ✅ Bonnes pratiques

### 1. Privilégier $(( )) aux commandes externes

```bash
# ❌ Inefficace (lance un processus externe)
resultat=$(expr 5 + 3)

# ✅ Rapide et intégré
resultat=$((5 + 3))
```

### 2. Utiliser des noms de variables explicites

```bash
# ❌ Peu clair
t=$((p * q * 1.2))  # Impossible sans bc de toute façon

# ✅ Explicite
prix_ht=100
quantite=5
taux_tva=20  # En pourcentage

# Calcul en centimes
prix_ttc=$(( (prix_ht * quantite * (100 + taux_tva)) / 100 ))
```

### 3. Commenter les calculs complexes

```bash
# Calcul de la distance euclidienne (sans racine carrée)
x1=10
y1=20
x2=40
y2=50

# Distance au carré = (x2-x1)² + (y2-y1)²
dx=$((x2 - x1))  # Différence en x
dy=$((y2 - y1))  # Différence en y
distance_carree=$((dx * dx + dy * dy))

echo "Distance² = $distance_carree"  # Affiche : 1800
```

### 4. Initialiser les variables

```bash
# ✅ Toujours initialiser les compteurs
compteur=0
total=0

while read ligne; do
    ((compteur++))
    ((total += ${#ligne}))  # Longueur de la ligne
done < fichier.txt

echo "Nombre de lignes : $compteur"
echo "Caractères totaux : $total"
```

### 5. Utiliser des constantes pour les valeurs magiques

```bash
# ❌ Nombre magique
if ((code == 0)); then
    echo "Succès"
fi

# ✅ Constante nommée
readonly SUCCES=0
readonly ERREUR=1

if ((code == SUCCES)); then
    echo "Succès"
fi
```

---

> [!tip] Astuce de performance Les opérations arithmétiques avec `$(( ))` sont **beaucoup plus rapides** que les commandes externes comme `expr` ou `bc`. Pour des scripts avec de nombreux calculs (boucles intensives), privilégiez toujours `$(( ))`.

> [!info] Compatibilité L'expansion arithmétique `$(( ))` est définie dans le standard POSIX et fonctionne dans tous les shells modernes (bash, zsh, ksh, dash). Les opérateurs de bits et `**` peuvent ne pas être disponibles dans les shells strictement POSIX.