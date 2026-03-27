
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

Les tests numériques en bash permettent de comparer des valeurs entières dans les structures conditionnelles. Bash propose deux approches principales : les opérateurs de test traditionnels utilisés avec `[ ]` ou `[[ ]]`, et la syntaxe arithmétique moderne `(( ))`.

> [!info] Pourquoi c'est important Les tests numériques sont essentiels pour :
> 
> - Contrôler les boucles (compteurs, limites)
> - Valider des entrées utilisateur
> - Vérifier des codes de retour
> - Implémenter de la logique conditionnelle basée sur des calculs

---

## Les opérateurs de test classiques

### Vue d'ensemble

Les opérateurs de test classiques s'utilisent avec `[ ]` (commande `test`) ou `[[ ]]` (mot-clé bash étendu). Ils sont hérités des shells POSIX.

|Opérateur|Signification|Équivalent mathématique|
|---|---|---|
|`-eq`|égal à (equal)|`==` ou `=`|
|`-ne`|différent de (not equal)|`!=`|
|`-lt`|inférieur à (less than)|`<`|
|`-gt`|supérieur à (greater than)|`>`|
|`-le`|inférieur ou égal (less or equal)|`<=`|
|`-ge`|supérieur ou égal (greater or equal)|`>=`|

### Syntaxe de base

```bash
# Avec [ ] (commande test)
if [ $nombre -eq 10 ]; then
    echo "Le nombre est égal à 10"
fi

# Avec [[ ]] (préféré en bash moderne)
if [[ $nombre -eq 10 ]]; then
    echo "Le nombre est égal à 10"
fi
```

> [!warning] Espaces obligatoires Les espaces autour des crochets et des opérateurs sont **obligatoires** :
> 
> - ✅ `[ $a -eq 10 ]`
> - ❌ `[$a -eq 10]`
> - ❌ `[ $a-eq 10 ]`

### Exemples pratiques

```bash
#!/bin/bash

age=25

# Test d'égalité
if [[ $age -eq 25 ]]; then
    echo "Vous avez exactement 25 ans"
fi

# Test de différence
if [[ $age -ne 30 ]]; then
    echo "Vous n'avez pas 30 ans"
fi

# Test inférieur à
if [[ $age -lt 30 ]]; then
    echo "Vous avez moins de 30 ans"
fi

# Test supérieur à
if [[ $age -gt 18 ]]; then
    echo "Vous êtes majeur"
fi

# Test inférieur ou égal
if [[ $age -le 25 ]]; then
    echo "Vous avez 25 ans ou moins"
fi

# Test supérieur ou égal
if [[ $age -ge 18 ]]; then
    echo "Accès autorisé (18+)"
fi
```

### Combinaison de tests

```bash
#!/bin/bash

score=75

# ET logique avec &&
if [[ $score -ge 50 && $score -lt 80 ]]; then
    echo "Mention Assez Bien"
fi

# OU logique avec ||
if [[ $score -lt 10 || $score -gt 90 ]]; then
    echo "Score extrême"
fi

# Négation avec !
if [[ ! $score -eq 100 ]]; then
    echo "Score non parfait"
fi
```

> [!tip] Préférer [[ ]] à [ ] `[[ ]]` est plus robuste car :
> 
> - Pas besoin de quoter les variables
> - Supporte `&&` et `||` directement
> - Meilleure gestion des erreurs

---

## Comparaison arithmétique avec (( ))

### Présentation

La syntaxe `(( ))` est une extension bash moderne qui permet d'évaluer des expressions arithmétiques. Elle est plus intuitive et puissante que les opérateurs classiques.

### Avantages de (( ))

- Syntaxe proche des langages de programmation classiques
- Pas besoin de `$` devant les variables
- Supporte les opérateurs mathématiques standards : `<`, `>`, `<=`, `>=`, `==`, `!=`
- Permet des calculs complexes dans la même expression
- Code de retour : 0 si vrai (expression ≠ 0), 1 si faux (expression = 0)

### Syntaxe

```bash
# Syntaxe de base
if (( expression )); then
    # commandes
fi

# Exemples d'opérateurs
(( a == b ))    # égalité
(( a != b ))    # différence
(( a < b ))     # inférieur à
(( a > b ))     # supérieur à
(( a <= b ))    # inférieur ou égal
(( a >= b ))    # supérieur ou égal
```

### Exemples pratiques

```bash
#!/bin/bash

nombre=42

# Pas besoin de $ devant la variable
if (( nombre == 42 )); then
    echo "La réponse à tout"
fi

# Opérateurs mathématiques standards
if (( nombre < 50 )); then
    echo "Moins de 50"
fi

if (( nombre >= 40 )); then
    echo "Au moins 40"
fi

# Combinaisons logiques
if (( nombre > 30 && nombre < 50 )); then
    echo "Entre 30 et 50"
fi
```

### Expressions arithmétiques complexes

```bash
#!/bin/bash

a=10
b=20
c=5

# Calculs dans la condition
if (( a + c == 15 )); then
    echo "10 + 5 = 15"
fi

# Multiplication et division
if (( b / a == 2 )); then
    echo "20 / 10 = 2"
fi

# Modulo
if (( b % 3 == 2 )); then
    echo "20 modulo 3 = 2"
fi

# Expressions complexes
if (( (a + b) * c > 100 )); then
    echo "(10 + 20) * 5 = 150 > 100"
fi
```

### Incrémentation et décrémentation

```bash
#!/bin/bash

compteur=0

# Post-incrémentation
(( compteur++ ))
echo $compteur  # Affiche 1

# Pré-incrémentation
(( ++compteur ))
echo $compteur  # Affiche 2

# Addition composée
(( compteur += 5 ))
echo $compteur  # Affiche 7

# Autres opérateurs composés
(( compteur -= 2 ))  # Soustraction
(( compteur *= 3 ))  # Multiplication
(( compteur /= 2 ))  # Division
(( compteur %= 4 ))  # Modulo
```

> [!example] Exemple : Boucle avec compteur
> 
> ```bash
> #!/bin/bash
> 
> for (( i = 0; i < 10; i++ )); do
>     if (( i % 2 == 0 )); then
>         echo "$i est pair"
>     fi
> done
> ```

---

## Différences entre [ ] et (( ))

### Tableau comparatif

|Aspect|`[ ]` / `[[ ]]`|`(( ))`|
|---|---|---|
|**Syntaxe**|`-eq`, `-lt`, etc.|`==`, `<`, etc.|
|**Variables**|Besoin de `$`|Pas de `$` nécessaire|
|**Espaces**|Obligatoires autour des opérateurs|Flexibles|
|**Calculs**|Non supportés|Supportés|
|**Type**|Chaînes ou nombres|Nombres uniquement|
|**Portabilité**|POSIX (avec `[ ]`)|Bash spécifique|

### Exemples côte à côte

```bash
#!/bin/bash

x=10
y=20

# Avec [[ ]]
if [[ $x -lt $y ]]; then
    echo "x < y (méthode classique)"
fi

# Avec (( ))
if (( x < y )); then
    echo "x < y (méthode arithmétique)"
fi

# [[ ]] ne peut pas faire de calculs
# ❌ [[ $x + 5 -eq 15 ]]  # ERREUR

# (( )) peut faire des calculs
if (( x + 5 == 15 )); then
    echo "10 + 5 = 15"
fi
```

### Quand utiliser quoi ?

> [!tip] Guide de choix **Utilise `(( ))` quand :**
> 
> - Tu compares des nombres
> - Tu as besoin de calculs
> - Tu veux une syntaxe plus lisible
> - Le script est exclusivement pour bash
> 
> **Utilise `[[ ]]` avec `-eq`, `-lt`, etc. quand :**
> 
> - Tu as besoin de portabilité POSIX
> - Tu mélanges tests numériques et tests de chaînes
> - Tu travailles sur des systèmes avec des shells limités

---

## Pièges courants

### 1. Comparaison de chaînes vs nombres

```bash
#!/bin/bash

# ❌ PIÈGE : Comparer des chaînes comme des nombres
chaine1="100"
chaine2="20"

# Avec (( )) : comparaison numérique correcte
if (( chaine1 > chaine2 )); then
    echo "100 > 20 (numérique)"  # ✅ Correct
fi

# Avec [[ ]] sans -gt : comparaison lexicographique
if [[ $chaine1 > $chaine2 ]]; then
    echo "Attention : comparaison alphabétique !"
    # "100" < "20" alphabétiquement car "1" < "2"
fi

# ✅ SOLUTION : Utiliser les bons opérateurs
if [[ $chaine1 -gt $chaine2 ]]; then
    echo "100 > 20 (numérique avec -gt)"  # ✅ Correct
fi
```

> [!warning] Attention aux comparaisons lexicographiques Avec `[[ ]]`, les opérateurs `<` et `>` font des comparaisons **alphabétiques**, pas numériques !
> 
> - Pour les nombres : utilise `-lt`, `-gt` ou `(( ))`
> - Pour les chaînes : utilise `<`, `>`

### 2. Variables non initialisées

```bash
#!/bin/bash

# ❌ Variable non définie
if (( count > 0 )); then
    echo "count est positif"
fi
# count est traité comme 0, pas d'erreur mais comportement surprenant

# ✅ SOLUTION : Initialiser ou vérifier
count=${count:-0}  # Valeur par défaut
if (( count > 0 )); then
    echo "count est positif"
fi

# Ou vérifier l'existence
if [[ -n $count ]] && (( count > 0 )); then
    echo "count existe et est positif"
fi
```

### 3. Espaces dans [ ]

```bash
#!/bin/bash

x=5

# ❌ ERREUR : Pas d'espaces
if [$x -eq 5]; then  # ERREUR de syntaxe
    echo "Jamais affiché"
fi

# ✅ CORRECT : Espaces obligatoires
if [ $x -eq 5 ]; then
    echo "x = 5"
fi

# (( )) est plus flexible avec les espaces
if ((x==5)); then  # OK
    echo "x = 5"
fi

if (( x == 5 )); then  # OK aussi, plus lisible
    echo "x = 5"
fi
```

### 4. Nombres décimaux

```bash
#!/bin/bash

# ❌ Bash ne supporte pas les décimaux nativement
decimal=3.14
if (( decimal > 3 )); then  # ERREUR
    echo "Jamais atteint"
fi

# ✅ SOLUTION : Utiliser bc ou awk pour les décimaux
if (( $(echo "$decimal > 3" | bc) )); then
    echo "3.14 > 3"
fi

# Ou multiplier pour éviter les décimaux
decimal_int=314  # 3.14 * 100
if (( decimal_int > 300 )); then
    echo "3.14 > 3.00"
fi
```

### 5. Codes de retour inversés

```bash
#!/bin/bash

# (( )) retourne 0 si l'expression est VRAIE (≠ 0)
# et 1 si l'expression est FAUSSE (= 0)

(( 5 > 3 ))
echo $?  # Affiche 0 (succès, vrai)

(( 2 > 8 ))
echo $?  # Affiche 1 (échec, faux)

# Cela peut être contre-intuitif !
resultat=0
if (( resultat )); then
    echo "Jamais affiché"  # 0 est faux en (( ))
fi

if (( resultat == 0 )); then
    echo "resultat est bien 0"  # ✅ Correct
fi
```

---

## Bonnes pratiques

### 1. Toujours utiliser (( )) pour l'arithmétique

```bash
#!/bin/bash

age=25

# ✅ BON : Syntaxe claire et moderne
if (( age >= 18 && age < 65 )); then
    echo "Âge adulte actif"
fi

# ❌ MOINS BON : Syntaxe verbale moins lisible
if [[ $age -ge 18 && $age -lt 65 ]]; then
    echo "Âge adulte actif"
fi
```

### 2. Quoter les variables dans [[ ]]

```bash
#!/bin/bash

# Même si [[ ]] est plus robuste que [ ], c'est une bonne pratique
nombre="42"

# ✅ BON : Habitude défensive
if [[ "$nombre" -eq 42 ]]; then
    echo "Réponse correcte"
fi

# Fonctionne aussi sans quotes avec [[ ]], mais moins sûr
if [[ $nombre -eq 42 ]]; then
    echo "Fonctionne mais moins recommandé"
fi
```

### 3. Valider les entrées utilisateur

```bash
#!/bin/bash

read -p "Entrez un nombre : " input

# ✅ BON : Vérifier que c'est bien un nombre
if [[ $input =~ ^[0-9]+$ ]]; then
    if (( input > 100 )); then
        echo "Nombre supérieur à 100"
    fi
else
    echo "Erreur : '$input' n'est pas un nombre valide"
fi
```

### 4. Utiliser des constantes pour la lisibilité

```bash
#!/bin/bash

# ✅ BON : Définir des constantes
readonly AGE_MAJEUR=18
readonly AGE_SENIOR=65

age=25

if (( age >= AGE_MAJEUR && age < AGE_SENIOR )); then
    echo "Adulte actif"
fi

# Plus lisible que :
# if (( age >= 18 && age < 65 )); then
```

### 5. Commenter les conditions complexes

```bash
#!/bin/bash

score=75
bonus=10
malus=5

# ✅ BON : Commenter la logique
# Calcul du score final : score de base + bonus - malus
# Condition de réussite : score final >= 70
if (( score + bonus - malus >= 70 )); then
    echo "Test réussi"
fi
```

---

## Astuces avancées

### 1. Opérateur ternaire simulé

```bash
#!/bin/bash

age=25

# Simulation d'un opérateur ternaire
message=$(( age >= 18 ? 1 : 0 ))
[[ $message -eq 1 ]] && echo "Majeur" || echo "Mineur"

# Ou plus directement
(( age >= 18 )) && echo "Majeur" || echo "Mineur"
```

### 2. Comparaisons en cascade

```bash
#!/bin/bash

note=85

# Cascade de conditions pour les mentions
if (( note >= 90 )); then
    mention="Très Bien"
elif (( note >= 80 )); then
    mention="Bien"
elif (( note >= 70 )); then
    mention="Assez Bien"
elif (( note >= 60 )); then
    mention="Passable"
else
    mention="Insuffisant"
fi

echo "Mention : $mention"
```

### 3. Utiliser (( )) pour valider des entrées

```bash
#!/bin/bash

read -p "Port (1024-65535) : " port

# Validation en une ligne
if (( port >= 1024 && port <= 65535 )); then
    echo "Port valide : $port"
else
    echo "Port invalide"
    exit 1
fi
```

### 4. Combinaison avec les calculs

```bash
#!/bin/bash

# Calcul et test dans la même expression
total=0
for i in 1 2 3 4 5; do
    (( total += i ))
done

if (( total == 15 )); then
    echo "Somme de 1 à 5 = 15"
fi

# Incrémentation conditionnelle
compteur=0
for fichier in *.txt; do
    [[ -f $fichier ]] && (( compteur++ ))
done
echo "Nombre de fichiers .txt : $compteur"
```

### 5. Tests multiples optimisés

```bash
#!/bin/bash

valeur=50

# Au lieu de multiples if imbriqués
if (( valeur >= 0 && valeur <= 100 )); then
    case $((valeur / 10)) in
        0|1|2|3|4) echo "Faible" ;;
        5|6|7)     echo "Moyen" ;;
        8|9|10)    echo "Élevé" ;;
    esac
fi
```

### 6. Validation de plages

```bash
#!/bin/bash

# Fonction pour tester si un nombre est dans une plage
dans_plage() {
    local valeur=$1
    local min=$2
    local max=$3
    
    (( valeur >= min && valeur <= max ))
}

# Utilisation
if dans_plage 75 0 100; then
    echo "75 est entre 0 et 100"
fi
```

---

> [!tip] 💡 Résumé rapide
> 
> - **`-eq`, `-ne`, `-lt`, `-gt`, `-le`, `-ge`** : opérateurs classiques avec `[[ ]]`
> - **`(( ))`** : syntaxe moderne, plus intuitive, supporte les calculs
> - Toujours utiliser `(( ))` pour l'arithmétique pure
> - Attention aux comparaisons lexicographiques avec `<` et `>` dans `[[ ]]`
> - Bash ne supporte que les **entiers**, pas les décimaux