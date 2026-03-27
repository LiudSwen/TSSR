

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

Les tests sur chaînes de caractères permettent de vérifier des conditions sur du texte : présence, égalité, correspondance à un motif, etc. Ces opérations sont fondamentales pour valider des entrées utilisateur, parser des fichiers ou contrôler le flux d'exécution d'un script.

> [!info] Pourquoi tester des chaînes ?
> 
> - Validation des arguments de script
> - Vérification de la présence de données
> - Comparaison de contenu (noms de fichiers, versions, etc.)
> - Pattern matching pour l'analyse de texte
> - Filtrage et traitement conditionnel

---

## 🔍 Test de vide/non-vide

### `-z` : Tester si une chaîne est vide

L'option `-z` (zero length) retourne vrai si la chaîne est vide ou non définie.

```bash
#!/bin/bash

nom=""

if [ -z "$nom" ]; then
    echo "Le nom est vide"
fi

# Exemples pratiques
fichier=""
if [ -z "$fichier" ]; then
    echo "Erreur : aucun fichier spécifié"
    exit 1
fi

# Avec une variable non définie
if [ -z "$variable_inexistante" ]; then
    echo "Variable vide ou non définie"  # Affichera ce message
fi
```

> [!warning] Attention aux guillemets ! Toujours mettre des guillemets autour de la variable : `[ -z "$var" ]` Sans guillemets, si la variable est vide, la commande devient `[ -z ]` ce qui peut causer des erreurs.

### `-n` : Tester si une chaîne est non-vide

L'option `-n` (non-zero length) retourne vrai si la chaîne contient au moins un caractère.

```bash
#!/bin/bash

nom="Alice"

if [ -n "$nom" ]; then
    echo "Le nom est défini : $nom"
fi

# Validation d'argument
if [ -n "$1" ]; then
    echo "Premier argument reçu : $1"
else
    echo "Aucun argument fourni"
fi

# Vérification avant traitement
reponse="oui"
if [ -n "$reponse" ]; then
    echo "Réponse enregistrée : $reponse"
fi
```

> [!tip] Astuce : test implicite Dans Bash, une chaîne non vide est considérée comme "vraie" :
> 
> ```bash
> if [ "$nom" ]; then
>     echo "Équivalent à -n"
> fi
> ```

### Comparaison `-z` vs `-n`

|Test|Chaîne vide `""`|Chaîne `"text"`|Variable non définie|
|---|---|---|---|
|`-z`|✅ Vrai|❌ Faux|✅ Vrai|
|`-n`|❌ Faux|✅ Vrai|❌ Faux|

```bash
#!/bin/bash

var=""

# Les deux sont équivalents mais -z est plus explicite
if [ -z "$var" ]; then
    echo "Chaîne vide (avec -z)"
fi

if [ ! -n "$var" ]; then
    echo "Chaîne vide (avec ! -n)"
fi
```

---

## ⚖️ Test d'égalité et inégalité

### `=` et `==` : Égalité stricte

Les opérateurs `=` et `==` testent l'égalité exacte entre deux chaînes (sensible à la casse).

```bash
#!/bin/bash

# = est POSIX standard, == est une extension Bash
nom="Alice"

if [ "$nom" = "Alice" ]; then
    echo "Bienvenue Alice"
fi

# == fonctionne aussi (syntaxe Bash)
if [ "$nom" == "Alice" ]; then
    echo "Même résultat avec =="
fi

# Comparaison avec variable
attendu="success"
resultat="success"

if [ "$resultat" = "$attendu" ]; then
    echo "Test réussi"
fi
```

> [!example] Cas d'usage pratique
> 
> ```bash
> #!/bin/bash
> # Validation de réponse utilisateur
> 
> read -p "Continuer ? (oui/non) : " reponse
> 
> if [ "$reponse" = "oui" ]; then
>     echo "Continuation du script..."
> elif [ "$reponse" = "non" ]; then
>     echo "Arrêt du script"
>     exit 0
> else
>     echo "Réponse invalide"
>     exit 1
> fi
> ```

### `!=` : Inégalité

L'opérateur `!=` teste si deux chaînes sont différentes.

```bash
#!/bin/bash

statut="erreur"

if [ "$statut" != "ok" ]; then
    echo "Statut anormal détecté : $statut"
fi

# Filtrage
fichier="rapport.txt"
if [ "$fichier" != "config.conf" ]; then
    echo "Ce n'est pas le fichier de configuration"
fi

# Validation d'exclusion
utilisateur="guest"
if [ "$utilisateur" != "root" ]; then
    echo "Accès limité pour $utilisateur"
fi
```

### Sensibilité à la casse

Les comparaisons avec `=` et `!=` sont sensibles à la casse.

```bash
#!/bin/bash

mot1="Bash"
mot2="bash"

if [ "$mot1" = "$mot2" ]; then
    echo "Identiques"
else
    echo "Différents (casse différente)"  # Affichera ceci
fi

# Pour comparer sans tenir compte de la casse
mot1_lower="${mot1,,}"  # Convertir en minuscules
mot2_lower="${mot2,,}"

if [ "$mot1_lower" = "$mot2_lower" ]; then
    echo "Identiques (ignorant la casse)"
fi
```

> [!warning] Attention aux espaces Les espaces autour de `=` sont importants dans `[ ]` :
> 
> ```bash
> [ "$a"="$b" ]    # ❌ ERREUR : pas d'espaces
> [ "$a" = "$b" ]  # ✅ CORRECT
> ```

---

## 📊 Ordre lexicographique

### Utilisation de `<` et `>` avec `[[ ]]`

Les opérateurs `<` et `>` permettent de comparer des chaînes selon l'ordre alphabétique (lexicographique).

> [!warning] Important : syntaxe `[[ ]]` requise Les opérateurs `<` et `>` ne fonctionnent **qu'avec la double crochet** `[[ ]]`. Avec `[ ]`, ils seraient interprétés comme des redirections !

```bash
#!/bin/bash

# Comparaison alphabétique simple
mot1="apple"
mot2="banana"

if [[ "$mot1" < "$mot2" ]]; then
    echo "$mot1 vient avant $mot2 alphabétiquement"
fi

# Ordre inverse
if [[ "zebra" > "aardvark" ]]; then
    echo "zebra vient après aardvark"
fi
```

### Tri et comparaison de versions

```bash
#!/bin/bash

# Comparer des noms
prenom1="Alice"
prenom2="Bob"

if [[ "$prenom1" < "$prenom2" ]]; then
    echo "$prenom1 vient en premier dans l'ordre alphabétique"
fi

# Attention : comparaison lexicographique ≠ numérique
version1="10.2"
version2="9.8"

if [[ "$version1" < "$version2" ]]; then
    echo "Comparaison lexicographique : $version1 < $version2"  # Affichera ceci !
    echo "Car '1' < '9' en ASCII"
fi

# Pour comparer des versions numériques, utiliser d'autres méthodes
```

> [!example] Tri de liste de noms
> 
> ```bash
> #!/bin/bash
> 
> nom_utilisateur="Martin"
> premier_autorise="Alice"
> dernier_autorise="Zoe"
> 
> if [[ "$nom_utilisateur" > "$premier_autorise" ]] && 
>    [[ "$nom_utilisateur" < "$dernier_autorise" ]]; then
>     echo "$nom_utilisateur est dans la plage autorisée"
> fi
> ```

### Ordre ASCII et Unicode

L'ordre lexicographique suit la table ASCII/Unicode :

```bash
#!/bin/bash

# Chiffres < Majuscules < Minuscules dans ASCII
if [[ "9" < "A" ]]; then
    echo "Les chiffres viennent avant les lettres majuscules"
fi

if [[ "Z" < "a" ]]; then
    echo "Les majuscules viennent avant les minuscules"
fi

# Attention aux caractères spéciaux
if [[ "fichier_1" < "fichier-2" ]]; then
    echo "_ (underscore) vient après - (tiret) en ASCII"
fi
```

> [!tip] Astuce : LC_COLLATE Le comportement peut varier selon la locale système. Pour un tri prévisible :
> 
> ```bash
> LC_COLLATE=C
> # Force l'ordre ASCII strict
> ```

---

## 🔎 Expressions régulières

### Opérateur `=~` avec `[[ ]]`

L'opérateur `=~` permet de tester si une chaîne correspond à une expression régulière (regex).

> [!info] Syntaxe exclusive `[[ ]]` Les regex avec `=~` ne fonctionnent **qu'avec** `[[ ]]`, jamais avec `[ ]`.

```bash
#!/bin/bash

email="user@example.com"

# Vérifier le format basique d'un email
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Format d'email valide"
else
    echo "Format d'email invalide"
fi
```

### Syntaxe et exemples de regex

```bash
#!/bin/bash

# Vérifier si une chaîne contient des chiffres
texte="Commande123"
if [[ "$texte" =~ [0-9] ]]; then
    echo "Contient des chiffres"
fi

# Début de chaîne (^)
fichier="test.txt"
if [[ "$fichier" =~ ^test ]]; then
    echo "Commence par 'test'"
fi

# Fin de chaîne ($)
if [[ "$fichier" =~ \.txt$ ]]; then
    echo "Se termine par .txt"
fi

# Quantificateurs
code="ABC123"
if [[ "$code" =~ ^[A-Z]{3}[0-9]{3}$ ]]; then
    echo "Format : 3 lettres majuscules + 3 chiffres"
fi
```

### Capture de groupes avec `BASH_REMATCH`

Bash stocke les correspondances de groupes dans le tableau `BASH_REMATCH`.

```bash
#!/bin/bash

date="2024-03-15"

# Extraire année, mois, jour
if [[ "$date" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})$ ]]; then
    echo "Date valide"
    echo "Année  : ${BASH_REMATCH[1]}"
    echo "Mois   : ${BASH_REMATCH[2]}"
    echo "Jour   : ${BASH_REMATCH[3]}"
    echo "Complet: ${BASH_REMATCH[0]}"
fi
```

> [!example] Validation d'adresse IP
> 
> ```bash
> #!/bin/bash
> 
> ip="192.168.1.1"
> 
> # Regex simplifiée pour IPv4
> regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
> 
> if [[ "$ip" =~ $regex ]]; then
>     echo "Format IP valide (vérification basique)"
>     # Note : ne valide pas que chaque octet est ≤ 255
> else
>     echo "Format IP invalide"
> fi
> ```

### Patterns regex courants

|Pattern|Description|Exemple|
|---|---|---|
|`^`|Début de chaîne|`^Bonjour`|
|`$`|Fin de chaîne|`\.log$`|
|`.`|N'importe quel caractère|`a.c` → "abc", "a1c"|
|`*`|0 ou plusieurs fois|`ab*c` → "ac", "abc", "abbc"|
|`+`|1 ou plusieurs fois|`ab+c` → "abc", "abbc"|
|`?`|0 ou 1 fois|`colou?r` → "color", "colour"|
|`[abc]`|Un caractère parmi a, b, c|`[aeiou]`|
|`[^abc]`|Aucun de ces caractères|`[^0-9]`|
|`{n}`|Exactement n fois|`[0-9]{3}`|
|`{n,m}`|Entre n et m fois|`[a-z]{2,5}`|
|`\|`|OU logique|`chat\|chien`|
|`()`|Groupe de capture|`([0-9]+)`|

```bash
#!/bin/bash

# Exemples pratiques

# Numéro de téléphone français
tel="06 12 34 56 78"
if [[ "$tel" =~ ^0[1-9]\ ([0-9]{2}\ ){4}$ ]]; then
    echo "Numéro valide"
fi

# URL HTTP/HTTPS
url="https://example.com/page"
if [[ "$url" =~ ^https?://[a-zA-Z0-9.-]+\.[a-z]{2,}(/.*)?$ ]]; then
    echo "URL valide"
fi

# Code postal français
cp="75001"
if [[ "$cp" =~ ^[0-9]{5}$ ]]; then
    echo "Code postal valide"
fi
```

> [!warning] Échappement des caractères spéciaux Dans les regex Bash, certains caractères doivent être échappés avec `\` :
> 
> - Point littéral : `\.` (sinon `.` = n'importe quel caractère)
> - Caractères spéciaux : `\(`, `\)`, `\[`, `\]`, `\{`, `\}`

---

## 🎨 Wildcards et patterns

### Globbing patterns avec `[[ ]]`

Les wildcards (ou globs) permettent des correspondances de motifs simplifiées, similaires à celles utilisées pour les fichiers.

```bash
#!/bin/bash

fichier="rapport_2024.pdf"

# Wildcard * (0 ou plusieurs caractères)
if [[ "$fichier" == *.pdf ]]; then
    echo "C'est un fichier PDF"
fi

# Wildcard ? (exactement 1 caractère)
code="A1B2"
if [[ "$code" == ???? ]]; then
    echo "Code de 4 caractères"
fi

# Classes de caractères [...]
if [[ "$code" == [A-Z][0-9]* ]]; then
    echo "Commence par une lettre majuscule puis un chiffre"
fi
```

### Différence entre wildcards et regex

|Caractère|Wildcard (glob)|Regex|Exemple wildcard|Exemple regex|
|---|---|---|---|---|
|`*`|0+ caractères|0+ du précédent|`*.txt`|`a*` → "a", "aa"|
|`?`|1 caractère exact|0 ou 1 du précédent|`file?.txt`|`a?` → "a", ""|
|`.`|Point littéral|N'importe quel caractère|`file.txt`|`a.c` → "abc"|
|`[abc]`|Un parmi a,b,c|Un parmi a,b,c|`[abc]*`|`[abc]+`|

```bash
#!/bin/bash

nom="fichier.txt"

# Avec wildcard (==)
if [[ "$nom" == *.txt ]]; then
    echo "Wildcard : se termine par .txt"
fi

# Avec regex (=~)
if [[ "$nom" =~ \.txt$ ]]; then
    echo "Regex : se termine par .txt"
fi

# Différence importante
texte="aaaaaa"
if [[ "$texte" == a* ]]; then
    echo "Wildcard : commence par 'a' puis n'importe quoi"  # Match
fi

if [[ "$texte" =~ a* ]]; then
    echo "Regex : contient 0+ 'a'"  # Match aussi, mais sens différent !
fi
```

### Patterns avancés avec `[[ ]]`

```bash
#!/bin/bash

# Négation avec !
fichier="image.png"
if [[ "$fichier" != *.jpg ]]; then
    echo "Ce n'est pas un JPEG"
fi

# Alternatives avec |  (nécessite extglob)
shopt -s extglob  # Activer les patterns étendus

extension="txt"
if [[ "$extension" == @(txt|md|doc) ]]; then
    echo "Extension de document texte"
fi

# Aucun ou plusieurs : *(pattern)
nom="file123.txt"
if [[ "$nom" == file+([0-9]).txt ]]; then
    echo "Fichier avec au moins un chiffre"
fi
```

> [!tip] Options extglob Activer `extglob` pour des patterns avancés :
> 
> ```bash
> shopt -s extglob
> 
> # ?(pattern) : 0 ou 1 fois
> # *(pattern) : 0 ou plusieurs fois
> # +(pattern) : 1 ou plusieurs fois
> # @(pattern) : exactement 1 fois
> # !(pattern) : tout sauf ce pattern
> ```

### Cas d'usage pratiques

```bash
#!/bin/bash

# Filtrage d'extensions multiples
fichier="document.docx"

if [[ "$fichier" == *.@(doc|docx|odt) ]]; then
    echo "Document de traitement de texte"
fi

# Validation de format de fichier de backup
backup="data_2024-03-15_backup.tar.gz"

if [[ "$backup" == *_backup.tar.gz ]]; then
    echo "Fichier backup valide"
fi

# Vérification de préfixe variable
log="error_critical_system.log"

if [[ "$log" == error_*.log ]]; then
    echo "Log d'erreur détecté"
    # Traitement spécial
fi
```

> [!example] Script de tri de fichiers
> 
> ```bash
> #!/bin/bash
> 
> for fichier in *; do
>     if [[ "$fichier" == *.jpg ]] || [[ "$fichier" == *.png ]]; then
>         echo "Image : $fichier"
>     elif [[ "$fichier" == *.txt ]] || [[ "$fichier" == *.md ]]; then
>         echo "Texte : $fichier"
>     elif [[ "$fichier" == *.sh ]]; then
>         echo "Script : $fichier"
>     fi
> done
> ```

---

## 🔄 Comparaison des syntaxes

### `[ ]` vs `[[ ]]`

|Caractéristique|`[ ]` (POSIX)|`[[ ]]` (Bash)|
|---|---|---|
|**Portabilité**|✅ Tous les shells|❌ Bash/Zsh/Ksh|
|**Guillemets obligatoires**|✅ Oui|⚠️ Optionnels|
|**Opérateurs `<` `>`**|❌ Redirections|✅ Comparaison|
|**Regex `=~`**|❌ Non supporté|✅ Supporté|
|**Wildcards**|❌ Non supporté|✅ Supporté|
|**`&&` `||` internes**|
|**Word splitting**|✅ Oui (danger)|❌ Non|

```bash
#!/bin/bash

var="test"

# Syntaxe [ ] - POSIX
if [ "$var" = "test" ]; then
    echo "[ ] : guillemets obligatoires"
fi

# Syntaxe [[ ]] - Bash
if [[ $var = "test" ]]; then
    echo "[[ ]] : guillemets optionnels (mais recommandés)"
fi

# Regex : impossible avec [ ]
if [[ "$var" =~ ^te.t$ ]]; then
    echo "Regex fonctionne uniquement avec [[ ]]"
fi

# Opérateurs logiques intégrés avec [[ ]]
if [[ "$var" = "test" && -n "$var" ]]; then
    echo "Opérateurs && et || directement dans [[ ]]"
fi

# Équivalent avec [ ] (nécessite deux commandes)
if [ "$var" = "test" ] && [ -n "$var" ]; then
    echo "Avec [ ], on doit séparer les conditions"
fi
```

### Quand utiliser quelle syntaxe ?

> [!tip] Recommandations
> 
> - **Utilisez `[[ ]]`** si :
>     - Vous écrivez spécifiquement pour Bash
>     - Vous avez besoin de regex ou wildcards
>     - Vous voulez des conditions complexes simplifiées
> - **Utilisez `[ ]`** si :
>     - Vous visez la compatibilité POSIX
>     - Votre script doit tourner sur sh, dash, etc.
>     - Vous faites des tests simples

```bash
#!/bin/bash

# ✅ Bon usage de [[ ]]
if [[ "$fichier" =~ \.log$ ]] && [[ -f "$fichier" ]]; then
    echo "Fichier log existant"
fi

# ✅ Bon usage de [ ] pour portabilité
if [ "$OS" = "Linux" ] && [ -d "/etc" ]; then
    echo "Système Linux avec /etc"
fi

# ❌ Erreur courante avec [ ]
fichier="mon fichier.txt"
if [ $fichier = "mon fichier.txt" ]; then  # ERREUR : word splitting
    echo "Ne s'affichera jamais"
fi

# ✅ Correction avec guillemets
if [ "$fichier" = "mon fichier.txt" ]; then
    echo "Correct avec [ ]"
fi

# ✅ Ou avec [[ ]] (plus permissif)
if [[ $fichier = "mon fichier.txt" ]]; then
    echo "Fonctionne aussi sans guillemets avec [[ ]]"
fi
```

---

## ⚠️ Pièges courants

### 1. Oublier les guillemets avec `[ ]`

```bash
#!/bin/bash

# ❌ DANGER
var=""
if [ $var = "" ]; then  # Devient : [ = "" ] → Erreur syntaxe
    echo "Ne s'exécutera jamais"
fi

# ✅ CORRECT
if [ "$var" = "" ]; then
    echo "Chaîne vide détectée"
fi

# Alternative avec [[ ]] (plus sûr)
if [[ $var = "" ]]; then
    echo "Pas d'erreur même sans guillemets"
fi
```

### 2. Confusion entre `=` et `==`

```bash
#!/bin/bash

# Dans [ ], seul = est POSIX standard
if [ "$var" = "test" ]; then  # ✅ Portable
    echo "POSIX"
fi

if [ "$var" == "test" ]; then  # ⚠️ Fonctionne en Bash mais non-POSIX
    echo "Extension Bash"
fi

# Dans [[ ]], les deux fonctionnent
if [[ "$var" = "test" ]]; then   # ✅
    echo "Fonctionne"
fi

if [[ "$var" == "test" ]]; then  # ✅
    echo "Fonctionne aussi"
fi
```

> [!tip] Recommandation Utilisez toujours `=` pour la cohérence et la portabilité.

### 3. Ordre lexicographique avec `[ ]`

```bash
#!/bin/bash

# ❌ ERREUR GRAVE avec [ ]
if [ "abc" < "xyz" ]; then
    echo "Ne s'affichera JAMAIS car < est une redirection !"
    # Crée un fichier "xyz" vide !
fi

# ✅ CORRECT avec [[ ]]
if [[ "abc" < "xyz" ]]; then
    echo "Comparaison lexicographique correcte"
fi
```

### 4. Espaces dans les comparaisons

```bash
#!/bin/bash

a="test"
b="test"

# ❌ ERREUR : pas d'espaces autour de =
if [ "$a"="$b" ]; then
    echo "Toujours vrai (erreur de syntaxe non détectée)"
fi

# ✅ CORRECT : espaces obligatoires
if [ "$a" = "$b" ]; then
    echo "Comparaison correcte"
fi
```

### 5. Regex sans stocker le pattern

```bash
#!/bin/bash

text="test123"

# ❌ Peut causer des problèmes si le pattern contient des espaces
if [[ "$text" =~ ^[a-z]+[0-9]+$ ]]; then
    echo "OK mais risqué"
fi

# ✅ MEILLEURE PRATIQUE : stocker le pattern
pattern='^[a-z]+[0-9]+$'
if [[ "$text" =~ $pattern ]]; then
    echo "Plus lisible et plus sûr"
fi

# Encore mieux avec nom explicite
regex_alphanum_pattern='^[a-z]+[0-9]+$'
if [[ "$text" =~ $regex_alphanum_pattern ]]; then
    echo "Pattern nommé pour la clarté"
fi
```

### 6. Comparaison de nombres avec opérateurs de chaînes

```bash
#!/bin/bash

# ❌ ERREUR : comparaison lexicographique, pas numérique
if [[ "10" > "9" ]]; then
    echo "FAUX ! '1' < '9' en ASCII"
else
    echo "Affichera ceci car '10' < '9' lexicographiquement"
fi

# ✅ CORRECT : utiliser les opérateurs numériques
if [ 10 -gt 9 ]; then
    echo "Comparaison numérique correcte"
fi
```

---

## ✅ Bonnes pratiques

### 1. Toujours mettre entre guillemets

```bash
#!/bin/bash

# ✅ Toujours
if [ -z "$variable" ]; then
    echo "Protection contre les variables vides"
fi

# ✅ Même pour les comparaisons
if [ "$var1" = "$var2" ]; then
    echo "Évite les problèmes de word splitting"
fi
```

### 2. Privilégier `[[ ]]` en Bash

```bash
#!/bin/bash

# ✅ Plus lisible et plus sûr
if [[ -n "$nom" && "$nom" =~ ^[A-Z] ]]; then
    echo "Nom non vide commençant par une majuscule"
fi

# vs avec [ ]
if [ -n "$nom" ] && [ "$nom" != "${nom#[A-Z]}" ]; then
    echo "Plus complexe et moins lisible"
fi
```

### 3. Utiliser des noms de variables explicites

```bash
#!/bin/bash

# ❌ Peu clair
if [[ "$s" =~ $p ]]; then
    echo "$s"
fi

# ✅ Clair et maintenable
email_pattern='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
user_input="test@example.com"

if [[ "$user_input" =~ $email_pattern ]]; then
    echo "Email valide : $user_input"
fi
```

### 4. Commenter les regex complexes

```bash
#!/bin/bash

# Pattern pour URL avec protocole, domaine et chemin optionnel
# ^https?://         : commence par http:// ou https://
# [a-zA-Z0-9.-]+     : nom de domaine (lettres, chiffres, points, tirets)
# \.[a-z]{2,}        : extension (.com, .fr, etc.)
# (/.*)?$            : chemin optionnel après le domaine
url_pattern='^https?://[a-zA-Z0-9.-]+\.[a-z]{2,}(/.*)?$'

if [[ "$url" =~ $url_pattern ]]; then
    echo "URL valide"
fi
```

### 5. Valider les entrées utilisateur

```bash
#!/bin/bash

# ✅ Validation robuste
read -p "Entrez votre âge : " age

# Vérifier non vide
if [[ -z "$age" ]]; then
    echo "Erreur : âge non fourni"
    exit 1
fi

# Vérifier que c'est un nombre
if ! [[ "$age" =~ ^[0-9]+$ ]]; then
    echo "Erreur : l'âge doit être un nombre"
    exit 1
fi

# Vérifier la plage
if [[ "$age" -lt 0 ]] || [[ "$age" -gt 150 ]]; then
    echo "Erreur : âge invalide"
    exit 1
fi

echo "Âge valide : $age ans"
```

### 6. Préférer les tests positifs

```bash
#!/bin/bash

# ❌ Double négation (confus)
if [ ! -z "$var" ]; then
    echo "Variable non vide"
fi

# ✅ Test positif (clair)
if [ -n "$var" ]; then
    echo "Variable non vide"
fi

# ❌ Logique inversée difficile à lire
if ! [[ "$statut" != "erreur" ]]; then
    echo "Confus"
fi

# ✅ Logique directe
if [[ "$statut" = "erreur" ]]; then
    echo "Clair"
fi
```

### 7. Utiliser des fonctions pour les validations répétées

```bash
#!/bin/bash

# ✅ Fonction réutilisable
valider_email() {
    local email="$1"
    local pattern='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}
    
    if [[ "$email" =~ $pattern ]]; then
        return 0  # Succès
    else
        return 1  # Échec
    fi
}

# Utilisation
if valider_email "user@example.com"; then
    echo "Email valide"
fi

if valider_email "invalid-email"; then
    echo "Email invalide"
fi
```

### 8. Gérer les cas limites

```bash
#!/bin/bash

nom="$1"

# ✅ Vérification complète
if [[ -z "$nom" ]]; then
    echo "Erreur : nom non fourni"
    exit 1
fi

# Vérifier les espaces uniquement
if [[ "$nom" =~ ^[[:space:]]*$ ]]; then
    echo "Erreur : nom ne peut pas être uniquement des espaces"
    exit 1
fi

# Vérifier la longueur minimale
if [[ ${#nom} -lt 2 ]]; then
    echo "Erreur : nom trop court (minimum 2 caractères)"
    exit 1
fi

# Vérifier les caractères valides
if ! [[ "$nom" =~ ^[a-zA-Z\ \'-]+$ ]]; then
    echo "Erreur : nom contient des caractères invalides"
    exit 1
fi

echo "Nom valide : $nom"
```

### 9. Documenter les patterns complexes

```bash
#!/bin/bash

# ✅ Pattern documenté avec exemples
# Format attendu : CODE-NNNN (ex: PROD-1234, DEV-0001)
# - CODE : 3-4 lettres majuscules
# - NNNN : exactement 4 chiffres
code_pattern='^[A-Z]{3,4}-[0-9]{4}

code_produit="PROD-1234"

if [[ "$code_produit" =~ $code_pattern ]]; then
    echo "Code produit valide"
else
    echo "Code produit invalide"
    echo "Format attendu : XXX-9999 ou XXXX-9999"
    exit 1
fi
```

### 10. Éviter les effets de bord

```bash
#!/bin/bash

# ❌ Modification de la variable originale
texte="  espaces  "
texte_trim="${texte// /}"  # Modifie $texte dans l'esprit du code

# ✅ Créer une nouvelle variable
texte="  espaces  "
texte_sans_espaces="${texte// /}"
# $texte reste inchangé

# ✅ Utiliser local dans les fonctions
nettoyer_texte() {
    local input="$1"
    local output="${input// /}"
    echo "$output"
}

resultat=$(nettoyer_texte "test avec espaces")
```

---

## 📝 Tableau récapitulatif

### Tests de base

|Test|Syntaxe|Description|Exemple|
|---|---|---|---|
|Chaîne vide|`[ -z "$var" ]`|Vrai si vide ou non définie|`[ -z "" ]` → vrai|
|Chaîne non vide|`[ -n "$var" ]`|Vrai si contient au moins 1 caractère|`[ -n "text" ]` → vrai|
|Égalité|`[ "$a" = "$b" ]`|Vrai si identiques|`[ "cat" = "cat" ]` → vrai|
|Inégalité|`[ "$a" != "$b" ]`|Vrai si différentes|`[ "cat" != "dog" ]` → vrai|

### Tests avancés (avec `[[ ]]`)

|Test|Syntaxe|Description|Exemple|
|---|---|---|---|
|Ordre <|`[[ "$a" < "$b" ]]`|Ordre alphabétique|`[[ "abc" < "xyz" ]]` → vrai|
|Ordre >|`[[ "$a" > "$b" ]]`|Ordre alphabétique|`[[ "zebra" > "ant" ]]` → vrai|
|Regex|`[[ "$s" =~ pattern ]]`|Correspondance regex|`[[ "abc123" =~ [0-9]+ ]]` → vrai|
|Wildcard|`[[ "$s" == *.txt ]]`|Pattern matching|`[[ "file.txt" == *.txt ]]` → vrai|

### Opérateurs logiques

```bash
# Avec [[ ]]
[[ "$a" = "x" && "$b" = "y" ]]  # ET logique
[[ "$a" = "x" || "$b" = "y" ]]  # OU logique
[[ ! "$a" = "x" ]]              # Négation

# Avec [ ] (séparation obligatoire)
[ "$a" = "x" ] && [ "$b" = "y" ]  # ET
[ "$a" = "x" ] || [ "$b" = "y" ]  # OU
[ ! "$a" = "x" ]                  # Négation
```

---

## 🎯 Exemples pratiques complets

### Script de validation de formulaire

```bash
#!/bin/bash

# Fonction de validation d'email
valider_email() {
    local email="$1"
    local pattern='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}
    [[ "$email" =~ $pattern ]]
}

# Fonction de validation de téléphone
valider_telephone() {
    local tel="$1"
    # Format: 06 12 34 56 78 ou 06-12-34-56-78 ou 0612345678
    local pattern='^0[1-9]([\ \-]?[0-9]{2}){4}
    [[ "$tel" =~ $pattern ]]
}

# Fonction de validation de code postal
valider_code_postal() {
    local cp="$1"
    [[ "$cp" =~ ^[0-9]{5}$ ]]
}

# Lecture des données
read -p "Email : " email
read -p "Téléphone : " telephone
read -p "Code postal : " code_postal

# Validation
erreurs=0

if [[ -z "$email" ]]; then
    echo "❌ Email requis"
    ((erreurs++))
elif ! valider_email "$email"; then
    echo "❌ Email invalide"
    ((erreurs++))
else
    echo "✅ Email valide"
fi

if [[ -z "$telephone" ]]; then
    echo "❌ Téléphone requis"
    ((erreurs++))
elif ! valider_telephone "$telephone"; then
    echo "❌ Téléphone invalide"
    ((erreurs++))
else
    echo "✅ Téléphone valide"
fi

if [[ -z "$code_postal" ]]; then
    echo "❌ Code postal requis"
    ((erreurs++))
elif ! valider_code_postal "$code_postal"; then
    echo "❌ Code postal invalide (5 chiffres attendus)"
    ((erreurs++))
else
    echo "✅ Code postal valide"
fi

# Résultat
if [[ $erreurs -eq 0 ]]; then
    echo ""
    echo "🎉 Formulaire valide !"
    exit 0
else
    echo ""
    echo "⚠️  $erreurs erreur(s) détectée(s)"
    exit 1
fi
```

### Script d'analyse de logs

```bash
#!/bin/bash

fichier_log="$1"

if [[ -z "$fichier_log" ]]; then
    echo "Usage: $0 <fichier_log>"
    exit 1
fi

if [[ ! -f "$fichier_log" ]]; then
    echo "Erreur : fichier '$fichier_log' introuvable"
    exit 1
fi

# Compteurs
total=0
erreurs=0
warnings=0
infos=0

# Patterns de recherche
pattern_erreur='ERROR|FATAL|CRITICAL'
pattern_warning='WARN|WARNING'
pattern_info='INFO|DEBUG'

# Analyse ligne par ligne
while IFS= read -r ligne; do
    ((total++))
    
    # Vérifier le type de log
    if [[ "$ligne" =~ $pattern_erreur ]]; then
        ((erreurs++))
        echo "❌ $ligne"
    elif [[ "$ligne" =~ $pattern_warning ]]; then
        ((warnings++))
        # Afficher seulement si warnings critiques
        if [[ "$ligne" =~ "critical" ]]; then
            echo "⚠️  $ligne"
        fi
    elif [[ "$ligne" =~ $pattern_info ]]; then
        ((infos++))
    fi
done < "$fichier_log"

# Rapport final
echo ""
echo "════════════════════════════════"
echo "  RAPPORT D'ANALYSE"
echo "════════════════════════════════"
echo "Total de lignes : $total"
echo "Erreurs         : $erreurs"
echo "Warnings        : $warnings"
echo "Infos           : $infos"
echo "════════════════════════════════"

# Code de retour selon le résultat
if [[ $erreurs -gt 0 ]]; then
    echo "⚠️  Des erreurs ont été détectées"
    exit 1
elif [[ $warnings -gt 10 ]]; then
    echo "⚠️  Nombre élevé de warnings"
    exit 2
else
    echo "✅ Aucun problème majeur détecté"
    exit 0
fi
```

### Script de renommage intelligent

```bash
#!/bin/bash

# Renommer des fichiers selon un pattern
# Usage: ./rename.sh <pattern_recherche> <remplacement>

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <pattern> <remplacement>"
    echo "Exemple: $0 'old_' 'new_'"
    exit 1
fi

pattern="$1"
remplacement="$2"

# Vérifier que le pattern n'est pas vide
if [[ -z "$pattern" ]]; then
    echo "Erreur : le pattern ne peut pas être vide"
    exit 1
fi

fichiers_modifies=0

# Parcourir tous les fichiers du répertoire courant
for fichier in *; do
    # Ignorer les répertoires
    [[ -d "$fichier" ]] && continue
    
    # Vérifier si le nom contient le pattern
    if [[ "$fichier" == *"$pattern"* ]]; then
        # Créer le nouveau nom
        nouveau_nom="${fichier//$pattern/$remplacement}"
        
        # Vérifier que le nouveau nom est différent
        if [[ "$fichier" != "$nouveau_nom" ]]; then
            # Vérifier qu'un fichier avec ce nom n'existe pas déjà
            if [[ -e "$nouveau_nom" ]]; then
                echo "⚠️  Conflit : '$nouveau_nom' existe déjà, '$fichier' ignoré"
            else
                mv "$fichier" "$nouveau_nom"
                echo "✅ '$fichier' → '$nouveau_nom'"
                ((fichiers_modifies++))
            fi
        fi
    fi
done

# Rapport
echo ""
if [[ $fichiers_modifies -eq 0 ]]; then
    echo "Aucun fichier modifié"
else
    echo "✅ $fichiers_modifies fichier(s) renommé(s)"
fi
```

---

## 🎓 Points clés à retenir

> [!info] Synthèse
> 
> 1. **Toujours utiliser des guillemets** autour des variables avec `[ ]`
> 2. **Privilégier `[[ ]]`** pour les scripts Bash modernes
> 3. **Les regex nécessitent `[[ ]]`** et l'opérateur `=~`
> 4. **Les wildcards fonctionnent** avec `[[ ]]` et `==`
> 5. **`<` et `>` ne fonctionnent qu'avec `[[ ]]`** pour l'ordre lexicographique
> 6. **Stocker les patterns complexes** dans des variables nommées
> 7. **Valider systématiquement** les entrées utilisateur
> 8. **Documenter les regex complexes** avec des commentaires
> 9. **Utiliser des fonctions** pour les validations répétées
> 10. **Tester les cas limites** (vide, espaces, caractères spéciaux)

---

🎉 **Vous maîtrisez maintenant les tests sur chaînes en Bash !**