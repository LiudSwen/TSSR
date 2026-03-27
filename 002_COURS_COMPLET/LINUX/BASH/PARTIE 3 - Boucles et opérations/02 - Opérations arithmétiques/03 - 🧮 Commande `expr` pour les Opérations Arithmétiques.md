

## 📚 Table des matières

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

## 🎯 Introduction à `expr`

La commande `expr` (expression evaluator) est l'une des **méthodes historiques** pour effectuer des calculs arithmétiques en Bash. Bien qu'elle soit aujourd'hui considérée comme obsolète au profit de syntaxes plus modernes, elle reste largement présente dans les scripts existants pour des raisons de **compatibilité**.

> [!info] Contexte historique `expr` était la principale méthode pour faire des calculs avant l'introduction de `$(( ))` et `let`. Elle est toujours utilisée dans certains systèmes Unix très anciens ou pour maintenir la compatibilité POSIX stricte.

### Pourquoi apprendre `expr` ?

- **Maintenance de code existant** : De nombreux scripts anciens utilisent `expr`
- **Compatibilité POSIX** : Fonctionne sur tous les shells compatibles POSIX
- **Compréhension historique** : Aide à comprendre l'évolution du scripting Bash
- **Scripts portables** : Utile pour des scripts devant tourner sur des systèmes très variés

---

## 📝 Syntaxe de base

La commande `expr` suit une syntaxe particulière qui peut sembler déroutante au premier abord :

```bash
expr expression
```

> [!example] Exemple simple
> 
> ```bash
> resultat=$(expr 5 + 3)
> echo $resultat  # Affiche : 8
> ```

### Structure d'une commande `expr`

```bash
# Forme générale
expr operande1 operateur operande2

# Capture du résultat
variable=$(expr operande1 operateur operande2)

# Utilisation directe (affiche le résultat)
expr 10 - 4  # Affiche : 6
```

> [!warning] Capture obligatoire `expr` affiche son résultat sur la sortie standard. Pour l'utiliser dans un script, vous devez **obligatoirement** capturer le résultat avec `$()` ou des backticks `` ` ` ``.

---

## ➕ Opérations arithmétiques

`expr` supporte les opérations arithmétiques de base :

|Opération|Opérateur|Exemple|Résultat|
|---|---|---|---|
|Addition|`+`|`expr 5 + 3`|`8`|
|Soustraction|`-`|`expr 10 - 4`|`6`|
|Multiplication|`\*`|`expr 6 \* 7`|`42`|
|Division entière|`/`|`expr 20 / 3`|`6`|
|Modulo (reste)|`%`|`expr 20 % 3`|`2`|

> [!example] Exemples pratiques
> 
> ```bash
> # Addition
> somme=$(expr 15 + 27)
> echo "15 + 27 = $somme"  # Affiche : 15 + 27 = 42
> 
> # Soustraction
> difference=$(expr 100 - 42)
> echo "100 - 42 = $difference"  # Affiche : 100 - 42 = 58
> 
> # Multiplication (noter l'échappement de *)
> produit=$(expr 8 \* 9)
> echo "8 × 9 = $produit"  # Affiche : 8 × 9 = 72
> 
> # Division entière
> quotient=$(expr 25 / 4)
> echo "25 ÷ 4 = $quotient"  # Affiche : 25 ÷ 4 = 6
> 
> # Modulo (reste de la division)
> reste=$(expr 25 % 4)
> echo "25 mod 4 = $reste"  # Affiche : 25 mod 4 = 1
> ```

### Calculs avec des variables

```bash
a=10
b=3

# Utilisation de variables
somme=$(expr $a + $b)
produit=$(expr $a \* $b)
division=$(expr $a / $b)
modulo=$(expr $a % $b)

echo "Somme: $somme"      # 13
echo "Produit: $produit"  # 30
echo "Division: $division" # 3
echo "Modulo: $modulo"    # 1
```

> [!warning] Division par zéro `expr` génère une erreur si vous tentez de diviser par zéro :
> 
> ```bash
> expr 10 / 0  # Erreur : expr: division by zero
> ```

---

## 📏 Règles d'espacement

L'une des particularités les plus importantes de `expr` est l'**obligation d'espacement**.

> [!warning] Espaces obligatoires Chaque opérande et opérateur **DOIT** être séparé par des espaces. C'est une source fréquente d'erreurs !

### ✅ Syntaxe correcte

```bash
expr 5 + 3    # Correct : espaces autour du +
expr 10 - 2   # Correct : espaces autour du -
expr 4 \* 6   # Correct : espaces autour du *
```

### ❌ Syntaxes incorrectes

```bash
expr 5+3      # ERREUR : pas d'espaces
expr 10 -2    # ERREUR : vu comme un nombre négatif
expr 4*6      # ERREUR : * interprété par le shell
expr 5 + 3 + 2  # ERREUR : expr n'accepte qu'une seule opération
```

> [!example] Démonstration des erreurs
> 
> ```bash
> # Sans espaces
> expr 5+3
> # Sortie : 5+3 (traité comme une chaîne, pas un calcul)
> 
> # Avec espaces (correct)
> expr 5 + 3
> # Sortie : 8
> ```

### Pourquoi ces espaces ?

`expr` parse ses arguments un par un. Sans espaces, `5+3` est vu comme **un seul argument** (une chaîne de caractères) et non comme trois arguments distincts (`5`, `+`, `3`).

---

## 🛡️ Échappement des opérateurs

Certains caractères ont une signification spéciale pour le shell et doivent être **échappés** ou **quotés**.

### Opérateurs nécessitant un échappement

|Opérateur|Raison|Échappement|
|---|---|---|
|`*`|Expansion de fichiers|`\*` ou `'*'`|
|`<`|Redirection|`\<` ou `'<'`|
|`>`|Redirection|`\>` ou `'>'`|
|`&`|Exécution en arrière-plan|`\&` ou `'&'`|
|`\|`|Pipe|`\|
|`( )`|Sous-shell|`\( \)` ou `'(' ')'`|

> [!example] Échappement du caractère de multiplication
> 
> ```bash
> # FAUX : le shell remplace * par la liste des fichiers
> resultat=$(expr 6 * 7)
> # Si vous avez des fichiers dans le répertoire, cela génère une erreur
> 
> # CORRECT : échappement avec backslash
> resultat=$(expr 6 \* 7)
> echo $resultat  # Affiche : 42
> 
> # CORRECT : utilisation de quotes simples
> resultat=$(expr 6 '*' 7)
> echo $resultat  # Affiche : 42
> ```

### Méthodes d'échappement

```bash
# Méthode 1 : Backslash
produit=$(expr 5 \* 4)

# Méthode 2 : Quotes simples autour de l'opérateur
produit=$(expr 5 '*' 4)

# Méthode 3 : Quotes simples autour de toute l'expression
produit=$(expr '5 * 4')  # Attention : pas d'expansion de variables ici !
```

> [!tip] Astuce L'utilisation de `\*` est la plus courante car elle permet l'expansion des variables tout en échappant l'opérateur.

---

## ⚠️ Limitations de `expr`

`expr` présente plusieurs limitations importantes qui expliquent pourquoi elle est aujourd'hui délaissée :

### 1. Arithmétique entière uniquement

```bash
# Pas de nombres décimaux
resultat=$(expr 5.5 + 2.3)
# Erreur : expr: non-integer argument

# Division toujours entière
resultat=$(expr 7 / 2)
echo $resultat  # Affiche : 3 (pas 3.5)
```

> [!info] Alternative pour les décimaux Pour les calculs avec décimaux, il faut utiliser `bc` (mais cela dépasse le cadre de cette partie).

### 2. Une seule opération à la fois

```bash
# IMPOSSIBLE avec expr
resultat=$(expr 5 + 3 * 2)  # Erreur de syntaxe

# Il faut imbriquer les commandes
temp=$(expr 3 \* 2)
resultat=$(expr 5 + $temp)
echo $resultat  # Affiche : 11

# Ou en une ligne (moins lisible)
resultat=$(expr 5 + $(expr 3 \* 2))
echo $resultat  # Affiche : 11
```

### 3. Syntaxe verbeuse

```bash
# Avec expr (lourd)
a=10
b=5
c=2
resultat=$(expr $(expr $a + $b) \* $c)

# Comparaison avec la syntaxe moderne (plus simple)
resultat=$(( (a + b) * c ))
```

### 4. Performances médiocres

`expr` est une **commande externe**, ce qui signifie :

- Chaque appel crée un nouveau processus
- Plus lent que les opérations intégrées au shell
- Impact significatif dans les boucles

```bash
# Lent : 1000 processus créés
for i in {1..1000}; do
    result=$(expr $i + 1)
done

# Rapide : calcul interne au shell
for i in {1..1000}; do
    result=$((i + 1))
done
```

### 5. Gestion des erreurs limitée

```bash
# expr renvoie un code de retour, mais le message d'erreur va sur stderr
resultat=$(expr 10 / 0 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Erreur de calcul"
fi
```

---

## 🚨 Pièges courants

### Piège 1 : Oubli des espaces

```bash
# FAUX
x=$(expr 5+3)      # Résultat : "5+3" (chaîne)

# CORRECT
x=$(expr 5 + 3)    # Résultat : 8
```

### Piège 2 : Oubli de l'échappement du *

```bash
# FAUX (si des fichiers existent dans le répertoire)
x=$(expr 5 * 3)

# CORRECT
x=$(expr 5 \* 3)
```

### Piège 3 : Tentative de calculs complexes

```bash
# FAUX : plusieurs opérations
x=$(expr 2 + 3 * 4)  # Erreur

# CORRECT : imbrication
x=$(expr 2 + $(expr 3 \* 4))  # Résultat : 14
```

### Piège 4 : Variables non expansées dans les quotes

```bash
a=5
b=3

# FAUX : les variables ne sont pas expansées
x=$(expr '$a + $b')  # Erreur : non-integer argument

# CORRECT : pas de quotes ou quotes doubles
x=$(expr $a + $b)    # Résultat : 8
x=$(expr "$a" + "$b")  # Résultat : 8
```

### Piège 5 : Confusion avec les nombres négatifs

```bash
# FAUX : -3 est interprété comme une option
x=$(expr 5 + -3)  # Peut causer une erreur

# CORRECT : utiliser des parenthèses (mais nécessite une expression complexe)
x=$(expr 5 + \( 0 - 3 \))
# Ou plus simple avec des variables
negatif=-3
x=$(expr 5 + $negatif)  # Résultat : 2
```

---

## ✅ Bonnes pratiques

### 1. Préférer les syntaxes modernes

> [!tip] Recommandation Utilisez `$(( ))` pour les nouveaux scripts. Réservez `expr` à la maintenance de code ancien ou aux contraintes de compatibilité stricte.

```bash
# Ancien style (éviter)
resultat=$(expr $a + $b)

# Style moderne (recommandé)
resultat=$((a + b))
```

### 2. Toujours échapper l'astérisque

```bash
# Bonne habitude : toujours \* avec expr
produit=$(expr $a \* $b)
```

### 3. Vérifier les codes de retour

```bash
# Capturer les erreurs
if ! resultat=$(expr $a / $b 2>/dev/null); then
    echo "Erreur dans le calcul"
    exit 1
fi
```

### 4. Documenter l'utilisation d'expr

```bash
# Si vous devez utiliser expr, expliquez pourquoi
# Utilisation de expr pour compatibilité POSIX stricte
resultat=$(expr $valeur1 + $valeur2)
```

### 5. Tester avec des valeurs limites

```bash
# Toujours tester :
# - Division par zéro
# - Nombres négatifs
# - Grands nombres
# - Chaînes vides
```

---

## 🎓 Résumé

La commande `expr` est une **méthode historique** pour effectuer des calculs arithmétiques en Bash. Ses caractéristiques principales :

**Points clés à retenir :**

- Syntaxe : `expr operande1 operateur operande2`
- **Espaces obligatoires** entre tous les éléments
- **Échappement nécessaire** pour `*` et autres caractères spéciaux
- **Arithmétique entière uniquement**
- **Une seule opération** par commande
- Commande externe (performances limitées)

**Quand utiliser `expr` :**

- ✅ Maintenance de scripts anciens
- ✅ Compatibilité POSIX stricte
- ✅ Systèmes Unix très anciens

**Quand éviter `expr` :**

- ❌ Nouveaux scripts (préférer `$(( ))`)
- ❌ Calculs avec décimaux
- ❌ Expressions complexes
- ❌ Boucles intensives

> [!info] Évolution `expr` fait partie de l'histoire du scripting Bash. Bien que toujours fonctionnelle, elle a été largement supplantée par des syntaxes plus modernes et plus performantes.

---

_Cours rédigé pour Obsidian - Bash Scripting_