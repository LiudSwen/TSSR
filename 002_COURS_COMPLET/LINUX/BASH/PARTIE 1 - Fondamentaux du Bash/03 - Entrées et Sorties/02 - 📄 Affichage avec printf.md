

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

La commande `printf` est un outil puissant pour l'affichage formaté en Bash. Contrairement à `echo`, elle offre un contrôle précis sur la mise en forme de la sortie, ce qui la rend indispensable pour créer des rapports structurés, des tableaux alignés, ou des sorties numériques précises.

> [!info] Pourquoi utiliser printf ?
> 
> - **Contrôle total** sur le format d'affichage
> - **Portabilité** garantie entre différents systèmes
> - **Précision** pour les nombres flottants
> - **Alignement** et mise en forme de tableaux
> - **Compatibilité** avec le printf du langage C

---

## 📐 Syntaxe de base

La syntaxe générale de `printf` suit ce modèle :

```bash
printf "chaîne_de_format" argument1 argument2 ...
```

> [!example] Exemple simple
> 
> ```bash
> printf "Bonjour %s\n" "monde"
> # Affiche : Bonjour monde
> ```

### Composants de la syntaxe

1. **Chaîne de format** : Contient le texte littéral et les spécificateurs de format (commençant par `%`)
2. **Arguments** : Valeurs qui remplacent les spécificateurs de format dans l'ordre

```bash
# Plusieurs arguments
printf "%s a %d ans\n" "Alice" 30
# Affiche : Alice a 30 ans
```

> [!warning] Caractère de retour à la ligne Contrairement à `echo`, `printf` **n'ajoute pas** automatiquement de retour à la ligne. Il faut utiliser explicitement `\n`.

### Séquences d'échappement courantes

|Séquence|Description|
|---|---|
|`\n`|Retour à la ligne|
|`\t`|Tabulation|
|`\\`|Antislash littéral|
|`\"`|Guillemet double|
|`\r`|Retour chariot|

```bash
printf "Ligne 1\nLigne 2\n"
printf "Colonne1\tColonne2\n"
```

---

## 🔤 Spécificateurs de format

Les spécificateurs de format définissent comment les arguments seront affichés. Ils commencent tous par le symbole `%`.

### %s - Chaîne de caractères (string)

Le spécificateur le plus universel, il accepte n'importe quel type de donnée et l'affiche comme du texte.

```bash
printf "%s\n" "Texte"
printf "%s\n" 123        # Affiche aussi : 123
printf "%s\n" 45.67      # Affiche aussi : 45.67

# Plusieurs chaînes
printf "%s %s %s\n" "Un" "Deux" "Trois"
# Affiche : Un Deux Trois
```

> [!tip] Usage recommandé Utilisez `%s` par défaut pour du texte simple. C'est le plus sûr et le plus flexible.

### %d - Nombre entier décimal (integer)

Affiche un nombre entier en base 10. Les valeurs non entières sont tronquées.

```bash
printf "%d\n" 42
# Affiche : 42

printf "%d\n" 3.14
# Affiche : 3 (partie décimale ignorée)

printf "%d\n" "abc"
# Affiche : 0 (texte converti en 0)
```

> [!example] Avec des variables
> 
> ```bash
> age=25
> printf "Âge : %d ans\n" $age
> # Affiche : Âge : 25 ans
> ```

### %f - Nombre à virgule flottante (float)

Affiche un nombre décimal. Par défaut, 6 chiffres après la virgule sont affichés.

```bash
printf "%f\n" 3.14159
# Affiche : 3.141590

printf "%f\n" 10
# Affiche : 10.000000

printf "%f\n" 2.5e3
# Affiche : 2500.000000
```

### %e et %E - Notation scientifique (exponentielle)

```bash
printf "%e\n" 1234.5
# Affiche : 1.234500e+03

printf "%E\n" 1234.5
# Affiche : 1.234500E+03 (majuscule)
```

### %x et %X - Hexadécimal

```bash
printf "%x\n" 255
# Affiche : ff

printf "%X\n" 255
# Affiche : FF (majuscule)

printf "0x%X\n" 255
# Affiche : 0xFF
```

### %o - Octal

```bash
printf "%o\n" 8
# Affiche : 10

printf "%o\n" 64
# Affiche : 100
```

### %% - Symbole pourcentage littéral

```bash
printf "Taux : %d%%\n" 75
# Affiche : Taux : 75%
```

---

## 📏 Contrôle de la largeur et de la précision

Le véritable pouvoir de `printf` réside dans sa capacité à contrôler précisément l'affichage avec des modificateurs de largeur et de précision.

### Syntaxe complète d'un spécificateur

```
%[drapeaux][largeur][.précision]type
```

### Largeur minimale

Définit le nombre minimum de caractères à afficher. Si la valeur est plus courte, des espaces sont ajoutés.

```bash
printf "%10s\n" "abc"
#        abc (7 espaces avant)

printf "%10d\n" 42
#         42 (8 espaces avant)

printf "%10f\n" 3.14
#   3.140000 (2 espaces avant)
```

> [!example] Alignement de colonnes
> 
> ```bash
> printf "%10s %10s\n" "Nom" "Âge"
> printf "%10s %10d\n" "Alice" 30
> printf "%10s %10d\n" "Bob" 25
> # Affiche :
> #        Nom        Âge
> #      Alice         30
> #        Bob         25
> ```

### Alignement à gauche avec le drapeau `-`

Par défaut, l'alignement est à droite. Le drapeau `-` inverse cela.

```bash
printf "%-10s|\n" "abc"
# abc       | (espaces après)

printf "%-10d|\n" 42
# 42        | (espaces après)
```

> [!example] Comparaison d'alignement
> 
> ```bash
> # Alignement à droite (défaut)
> printf "|%10s|\n" "Test"
> # |      Test|
> 
> # Alignement à gauche
> printf "|%-10s|\n" "Test"
> # |Test      |
> ```

### Précision pour les nombres flottants

La précision contrôle le nombre de chiffres après la virgule pour `%f`.

```bash
printf "%.2f\n" 3.14159
# Affiche : 3.14

printf "%.4f\n" 3.14159
# Affiche : 3.1416 (arrondi)

printf "%.0f\n" 3.14159
# Affiche : 3
```

### Combinaison largeur et précision

```bash
printf "%10.2f\n" 3.14159
#       3.14 (largeur 10, 2 décimales)

printf "%-10.2f|\n" 3.14159
# 3.14      | (aligné à gauche)
```

### Précision pour les chaînes

La précision limite le nombre de caractères affichés.

```bash
printf "%.5s\n" "Bonjour"
# Affiche : Bonjo (5 premiers caractères)

printf "%10.5s\n" "Bonjour"
#      Bonjo (largeur 10, max 5 caractères)
```

### Remplissage avec des zéros - drapeau `0`

```bash
printf "%05d\n" 42
# Affiche : 00042

printf "%08.2f\n" 3.14
# Affiche : 00003.14
```

> [!warning] Attention Le drapeau `0` ne fonctionne pas avec l'alignement à gauche `-`.

### Affichage du signe - drapeaux `+` et

```bash
# Drapeau + : toujours afficher le signe
printf "%+d\n" 42
# Affiche : +42

printf "%+d\n" -42
# Affiche : -42

# Drapeau espace : espace pour les positifs
printf "% d\n" 42
# Affiche :  42 (avec espace)

printf "% d\n" -42
# Affiche : -42 (pas d'espace)
```

### Tableau récapitulatif des drapeaux

|Drapeau|Description|Exemple|
|---|---|---|
|`-`|Alignement à gauche|`%-10s`|
|`+`|Toujours afficher le signe|`%+d`|
|(espace)|Espace pour les positifs|`% d`|
|`0`|Remplir avec des zéros|`%05d`|
|`#`|Forme alternative (0x pour hexa)|`%#x`|

---

## ⚖️ Différences avec echo

Comprendre les différences entre `printf` et `echo` est essentiel pour choisir le bon outil.

### Tableau comparatif

|Caractéristique|printf|echo|
|---|---|---|
|Retour à la ligne automatique|❌ Non (`\n` requis)|✅ Oui (par défaut)|
|Formatage avancé|✅ Oui (spécificateurs)|❌ Non|
|Portabilité|✅ Excellente|⚠️ Variable selon les versions|
|Interprétation des séquences|✅ Toujours|⚠️ Dépend de `-e`|
|Contrôle de la précision|✅ Oui|❌ Non|
|Alignement de colonnes|✅ Oui|❌ Difficile|
|Simplicité d'usage|⚠️ Plus complexe|✅ Plus simple|

### Exemples de comparaison

#### Affichage simple

```bash
# echo - simple et direct
echo "Bonjour"

# printf - nécessite \n
printf "Bonjour\n"
```

#### Séquences d'échappement

```bash
# echo sans -e : affiche littéralement
echo "Ligne1\nLigne2"
# Affiche : Ligne1\nLigne2

# echo avec -e : interprète les séquences
echo -e "Ligne1\nLigne2"
# Affiche :
# Ligne1
# Ligne2

# printf : toujours interpréter
printf "Ligne1\nLigne2\n"
# Affiche :
# Ligne1
# Ligne2
```

> [!warning] Problème de portabilité avec echo Le comportement de `echo` varie selon les systèmes :
> 
> - Certains `echo` interprètent `\n` par défaut
> - D'autres nécessitent `-e`
> - `echo -e` n'existe pas partout
> 
> **Solution** : Utilisez `printf` pour une portabilité garantie.

#### Formatage de nombres

```bash
# echo : pas de contrôle
echo "Prix : 3.14159"
# Affiche : Prix : 3.14159

# printf : contrôle précis
printf "Prix : %.2f €\n" 3.14159
# Affiche : Prix : 3.14 €
```

#### Alignement de tableaux

```bash
# Avec echo : difficile et pas aligné
echo "Nom Age"
echo "Alice 30"
echo "Bob 25"

# Avec printf : parfaitement aligné
printf "%-10s %5s\n" "Nom" "Age"
printf "%-10s %5d\n" "Alice" 30
printf "%-10s %5d\n" "Bob" 25
# Affiche :
# Nom          Age
# Alice         30
# Bob           25
```

### Quand utiliser echo vs printf ?

> [!tip] Utilisez `echo` quand...
> 
> - Vous affichez du texte simple
> - Vous voulez un retour à la ligne automatique
> - La portabilité n'est pas critique
> - Vous écrivez des scripts simples

> [!tip] Utilisez `printf` quand...
> 
> - Vous avez besoin de formatage précis
> - Vous créez des tableaux ou rapports
> - Vous manipulez des nombres avec précision
> - La portabilité est importante
> - Vous traduisez du code C en Bash

---

## 🚨 Pièges courants

### 1. Oublier le `\n`

```bash
# ❌ Mauvais : pas de retour à la ligne
printf "Ligne 1"
printf "Ligne 2"
# Affiche : Ligne 1Ligne 2

# ✅ Bon : avec \n
printf "Ligne 1\n"
printf "Ligne 2\n"
```

### 2. Nombre d'arguments insuffisant

```bash
# ❌ Mauvais : manque un argument
printf "%s %d\n" "Alice"
# Affiche : Alice 0 (0 par défaut)

# ✅ Bon : tous les arguments fournis
printf "%s %d\n" "Alice" 30
```

> [!info] Comportement avec trop d'arguments `printf` réutilise la chaîne de format si plus d'arguments sont fournis :
> 
> ```bash
> printf "%s\n" "A" "B" "C"
> # Affiche :
> # A
> # B
> # C
> ```

### 3. Guillemets manquants

```bash
# ❌ Mauvais : risque avec des espaces
printf %s "texte avec espaces"
# Peut causer des erreurs

# ✅ Bon : toujours entre guillemets
printf "%s" "texte avec espaces"
```

### 4. Confusion entre largeur et précision

```bash
# %10.2f signifie : largeur 10, précision 2
printf "%10.2f\n" 3.14159
#       3.14

# %2.10f signifie : largeur 2, précision 10
printf "%2.10f\n" 3.14159
# 3.1415900000 (la largeur est ignorée si trop petite)
```

### 5. Échappement de % dans la chaîne de format

```bash
# ❌ Mauvais : % seul cause une erreur
printf "Taux : 100%\n"

# ✅ Bon : doubler le %
printf "Taux : 100%%\n"
```

### 6. Types incompatibles

```bash
# Conversion de texte en nombre
printf "%d\n" "abc"
# Affiche : 0 (mais génère un avertissement)

printf "%.2f\n" "texte"
# Affiche : 0.00 (avec avertissement)
```

---

## ✅ Bonnes pratiques

### 1. Toujours mettre la chaîne de format entre guillemets doubles

```bash
# ✅ Bon
printf "%s\n" "$variable"

# ❌ Mauvais
printf %s\n $variable
```

### 2. Protéger les variables avec des guillemets

```bash
nom="Alice Bob"

# ❌ Mauvais : le mot-séparation pose problème
printf "%s\n" $nom
# Deux lignes affichées

# ✅ Bon : guillemets protègent la valeur
printf "%s\n" "$nom"
# Une seule ligne
```

### 3. Utiliser `%s` pour les valeurs non numériques

```bash
# ✅ Bon : sûr et flexible
printf "%s\n" "$variable_inconnue"

# ⚠️ Risqué : erreur si non numérique
printf "%d\n" "$variable_inconnue"
```

### 4. Définir la précision pour les flottants dans les calculs financiers

```bash
prix=19.99
tva=1.055

# ❌ Mauvais : trop de décimales
printf "%f\n" $(echo "$prix * $tva" | bc -l)
# 21.089450000000000000

# ✅ Bon : précision appropriée
printf "%.2f\n" $(echo "$prix * $tva" | bc -l)
# 21.09
```

### 5. Créer des fonctions réutilisables pour les tableaux

```bash
# Fonction pour afficher une ligne de tableau
print_row() {
    printf "| %-15s | %-10s | %8s |\n" "$1" "$2" "$3"
}

# Utilisation
print_row "Nom" "Ville" "Âge"
printf "+%s+%s+%s+\n" "$(printf '%.0s-' {1..17})" "$(printf '%.0s-' {1..12})" "$(printf '%.0s-' {1..10})"
print_row "Alice" "Paris" "30"
print_row "Bob" "Lyon" "25"
```

### 6. Documenter les formats complexes

```bash
# Format : Nom (15 car), Montant (8 car, 2 déc), Pourcentage (5 car, 1 déc)
printf "%-15s %8.2f %5.1f%%\n" "Produit A" 123.456 87.3
```

---

## 💡 Astuces avancées

### 1. Réutilisation de la chaîne de format

`printf` réutilise automatiquement sa chaîne de format pour les arguments excédentaires :

```bash
printf "%s\n" "A" "B" "C" "D"
# Affiche :
# A
# B
# C
# D
```

> [!tip] Application pratique Très utile pour afficher des listes :
> 
> ```bash
> printf "- %s\n" "Pomme" "Banane" "Orange"
> # Affiche :
> # - Pomme
> # - Banane
> # - Orange
> ```

### 2. Stocker la sortie dans une variable

```bash
resultat=$(printf "Valeur : %.2f" 3.14159)
echo "$resultat"
# Affiche : Valeur : 3.14
```

### 3. Affichage de barres de progression

```bash
progress=75
filled=$((progress / 2))
empty=$((50 - filled))

printf "["
printf "%${filled}s" | tr ' ' '='
printf "%${empty}s" | tr ' ' ' '
printf "] %d%%\n" $progress
# Affiche : [=====================================            ] 75%
```

### 4. Conversion de base avec printf

```bash
# Décimal vers hexadécimal
printf "%x\n" 255      # ff

# Décimal vers octal
printf "%o\n" 64       # 100

# Hexadécimal vers décimal
printf "%d\n" 0xFF     # 255
```

### 5. Génération de rapports formatés

```bash
#!/bin/bash

printf "\n"
printf "╔══════════════════════════════════════╗\n"
printf "║      RAPPORT DE PERFORMANCE          ║\n"
printf "╚══════════════════════════════════════╝\n"
printf "\n"

printf "%-20s : %10.2f ms\n" "Temps d'exécution" 123.456
printf "%-20s : %10d\n" "Requêtes traitées" 1523
printf "%-20s : %10.1f%%\n" "Taux de réussite" 98.7
printf "\n"
```

### 6. Printf avec des variables dynamiques

```bash
largeur=20
precision=3
valeur=3.14159

printf "%${largeur}.${precision}f\n" $valeur
# Équivaut à : printf "%20.3f\n" $valeur
```

### 7. Tableaux alignés dynamiquement

```bash
# Données
declare -a noms=("Alice" "Bob" "Charlie")
declare -a ages=(30 25 35)
declare -a villes=("Paris" "Lyon" "Marseille")

# Calcul de la largeur maximale
max_nom=0
for nom in "${noms[@]}"; do
    [[ ${#nom} -gt $max_nom ]] && max_nom=${#nom}
done

# Affichage
printf "%-${max_nom}s | %4s | %s\n" "Nom" "Âge" "Ville"
printf "%${max_nom}s-+------+------------\n" | tr ' ' '-'

for i in "${!noms[@]}"; do
    printf "%-${max_nom}s | %4d | %s\n" "${noms[$i]}" "${ages[$i]}" "${villes[$i]}"
done
```

### 8. Formatage de nombres avec séparateurs de milliers

```bash
# Note : nécessite la locale appropriée
LC_NUMERIC=en_US.UTF-8 printf "%'d\n" 1234567
# Affiche : 1,234,567

LC_NUMERIC=fr_FR.UTF-8 printf "%'d\n" 1234567
# Affiche : 1 234 567
```

### 9. Création de lignes de séparation

```bash
# Ligne de 50 caractères '='
printf '=%.0s' {1..50}
printf "\n"

# Ligne de 30 caractères '-'
printf -- '-%.0s' {1..30}
printf "\n"
```

### 10. Couleurs dans le terminal avec printf

```bash
# Définition des couleurs ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Utilisation
printf "${RED}Erreur${NC} : %s\n" "Fichier introuvable"
printf "${GREEN}Succès${NC} : %s\n" "Opération terminée"
printf "${YELLOW}Attention${NC} : %s\n" "Espace disque faible"
```

---

> [!tip] 🎓 Résumé
> 
> - `printf` offre un contrôle précis sur le formatage de la sortie
> - Les spécificateurs principaux sont `%s` (string), `%d` (integer), `%f` (float)
> - La largeur et la précision permettent d'aligner et de formater les données
> - Toujours terminer avec `\n` (contrairement à `echo`)
> - Privilégier `printf` pour la portabilité et le formatage avancé
> - Utiliser `echo` pour l'affichage simple et rapide

> [!warning] ⚠️ Points de vigilance
> 
> - N'oubliez jamais le `\n` final
> - Protégez toujours vos variables avec des guillemets
> - Échappez le symbole `%` avec `%%`
> - Vérifiez la correspondance entre spécificateurs et arguments