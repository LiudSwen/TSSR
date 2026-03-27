

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

L'extraction de sous-chaîne en Bash permet de récupérer une partie spécifique d'une chaîne de caractères sans avoir recours à des outils externes comme `cut`, `awk` ou `sed`. Cette technique native est particulièrement performante et élégante pour manipuler des chaînes dans vos scripts.

> [!info] Pourquoi utiliser l'extraction de sous-chaîne ?
> 
> - **Performance** : Pas de processus externe à lancer
> - **Portabilité** : Fonctionne dans tous les shells compatibles Bash
> - **Simplicité** : Syntaxe concise et lisible
> - **Polyvalence** : Gère facilement les cas complexes

**Cas d'usage typiques :**

- Extraire des dates ou timestamps
- Parser des chemins de fichiers
- Traiter des données formatées (CSV, logs)
- Manipuler des identifiants ou codes

---

## 📐 Syntaxe `${variable:offset}`

### Description

Cette syntaxe extrait une sous-chaîne à partir d'une position donnée (`offset`) jusqu'à la fin de la chaîne.

### Syntaxe de base

```bash
${variable:offset}
```

- **variable** : La variable contenant la chaîne source
- **offset** : Position de départ (commence à 0)

### Fonctionnement

```bash
texte="Bonjour le monde"
#       0123456789...

# Extraction depuis la position 8 jusqu'à la fin
echo "${texte:8}"
# Résultat : "le monde"

# Extraction depuis la position 0 (toute la chaîne)
echo "${texte:0}"
# Résultat : "Bonjour le monde"

# Extraction depuis la position 3
echo "${texte:3}"
# Résultat : "jour le monde"
```

> [!example] Exemple pratique : Extraire l'extension d'un fichier
> 
> ```bash
> fichier="document.pdf"
> 
> # Trouver la position du point
> # (Dans un vrai script, on utiliserait plutôt ${fichier##*.})
> extension="${fichier:9}"  # À partir de la position 9
> echo "Extension : $extension"
> # Résultat : "pdf"
> ```

### Cas particuliers

```bash
texte="Bash"

# Offset égal à la longueur de la chaîne
echo "${texte:4}"
# Résultat : "" (chaîne vide)

# Offset supérieur à la longueur
echo "${texte:10}"
# Résultat : "" (chaîne vide, pas d'erreur)
```

> [!warning] Attention aux espaces Les espaces dans la chaîne comptent comme des caractères !
> 
> ```bash
> texte="A B C"
> echo "${texte:2}"
> # Résultat : "B C" (l'espace est inclus)
> ```

---

## ✂️ Syntaxe `${variable:offset:length}`

### Description

Cette syntaxe extrait une sous-chaîne de longueur spécifique à partir d'une position donnée.

### Syntaxe complète

```bash
${variable:offset:length}
```

- **variable** : La variable contenant la chaîne source
- **offset** : Position de départ (commence à 0)
- **length** : Nombre de caractères à extraire

### Fonctionnement

```bash
texte="Bonjour le monde"
#       0123456789012345

# Extraire 7 caractères depuis la position 0
echo "${texte:0:7}"
# Résultat : "Bonjour"

# Extraire 2 caractères depuis la position 8
echo "${texte:8:2}"
# Résultat : "le"

# Extraire 5 caractères depuis la position 11
echo "${texte:11:5}"
# Résultat : "monde"
```

> [!example] Exemple pratique : Parser une date
> 
> ```bash
> date="2024-12-13"
> #      0123456789
> 
> annee="${date:0:4}"
> mois="${date:5:2}"
> jour="${date:8:2}"
> 
> echo "Année : $annee"   # 2024
> echo "Mois : $mois"     # 12
> echo "Jour : $jour"     # 13
> ```

### Gestion des débordements

```bash
texte="Bash"
#      0123

# Length dépasse la fin de la chaîne
echo "${texte:2:10}"
# Résultat : "sh" (s'arrête à la fin, pas d'erreur)

# Offset + length dépassent ensemble
echo "${texte:3:5}"
# Résultat : "h" (extrait ce qui est disponible)
```

> [!tip] Astuce : Extraire les premiers caractères
> 
> ```bash
> texte="Anticonstitutionnellement"
> 
> # Les 5 premiers caractères
> echo "${texte:0:5}"
> # Résultat : "Antic"
> 
> # Alternative élégante
> echo "${texte::5}"  # Le :0 est optionnel !
> # Résultat : "Antic"
> ```

### Comparaison des deux syntaxes

|Syntaxe|Offset|Length|Résultat avec "Bonjour"|
|---|---|---|---|
|`${texte:3}`|3|jusqu'à la fin|"jour"|
|`${texte:3:2}`|3|2 caractères|"jo"|
|`${texte::4}`|0 (implicite)|4 caractères|"Bonj"|
|`${texte:0}`|0|jusqu'à la fin|"Bonjour"|

---

## ⬅️ Offset négatif (depuis la fin)

### Description

Un offset négatif permet d'extraire une sous-chaîne en comptant depuis la fin de la chaîne au lieu du début. C'est particulièrement utile pour récupérer les derniers caractères.

### Syntaxe avec offset négatif

```bash
${variable: -offset}          # Espace obligatoire avant le -
${variable: -offset:length}   # Avec longueur spécifique
```

> [!warning] Espace obligatoire ! L'espace avant le `-` est **obligatoire** pour éviter la confusion avec la syntaxe de valeur par défaut `${variable:-default}`

### Fonctionnement

```bash
texte="Bonjour le monde"
#       ...9876543210  (comptage depuis la fin)

# Extraire les 5 derniers caractères
echo "${texte: -5}"
# Résultat : "monde"

# Extraire les 8 derniers caractères
echo "${texte: -8}"
# Résultat : "le monde"

# Extraire tout sauf le dernier caractère
longueur=${#texte}
echo "${texte:0:$((longueur-1))}"
# Résultat : "Bonjour le mond"
```

> [!example] Exemple pratique : Vérifier l'extension d'un fichier
> 
> ```bash
> fichier="rapport.pdf"
> 
> # Extraire les 4 derniers caractères (.pdf)
> extension="${fichier: -4}"
> 
> if [[ "$extension" == ".pdf" ]]; then
>     echo "C'est un fichier PDF"
> fi
> ```

### Combinaison offset négatif + length

```bash
texte="Bonjour le monde"

# Depuis -8, extraire 2 caractères
echo "${texte: -8:2}"
# Résultat : "le"

# Depuis -5, extraire 3 caractères
echo "${texte: -5:3}"
# Résultat : "mon"

# Depuis -10, extraire jusqu'à la fin
echo "${texte: -10}"
# Résultat : "r le monde"
```

### Cas pratiques avancés

```bash
# Supprimer les N derniers caractères
texte="fichier.txt"
sans_extension="${texte:0: -4}"
echo "$sans_extension"
# Résultat : "fichier"

# Extraire le nom de fichier sans extension (alternative)
fichier="/chemin/vers/document.pdf"
nom="${fichier##*/}"           # document.pdf
nom_seul="${nom:0: -4}"        # document
echo "$nom_seul"
```

> [!tip] Astuce : Combinaison avec la longueur de chaîne
> 
> ```bash
> texte="Anticonstitutionnellement"
> longueur=${#texte}
> 
> # Extraire la seconde moitié
> milieu=$((longueur / 2))
> seconde_moitie="${texte:$milieu}"
> echo "$seconde_moitie"
> # Résultat : "tutionnellement"
> 
> # Extraire les 5 derniers sauf les 2 derniers
> echo "${texte: -7:5}"
> # Résultat : "llemen"
> ```

### Tableau récapitulatif

|Syntaxe|Description|Exemple avec "Bonjour"|
|---|---|---|
|`${texte: -3}`|3 derniers caractères|"our"|
|`${texte: -3:2}`|Depuis -3, prendre 2 caractères|"ou"|
|`${texte:0: -2}`|Tout sauf les 2 derniers|"Bonjo"|
|`${texte: -5:3}`|Depuis -5, prendre 3 caractères|"njo"|

---

## 📦 Extraction de suffixe

### Description

Bash propose des opérateurs spéciaux pour extraire ou supprimer des suffixes (fins de chaîne) basés sur des motifs. Ces opérateurs sont complémentaires à l'extraction par position.

### Opérateurs de suppression de suffixe

```bash
${variable%pattern}   # Supprime le plus court suffixe correspondant
${variable%%pattern}  # Supprime le plus long suffixe correspondant
```

### Fonctionnement avec `%` (suppression minimale)

```bash
fichier="document.backup.tar.gz"

# Supprimer la plus petite correspondance de .*
echo "${fichier%.*}"
# Résultat : "document.backup.tar"
# (supprime seulement ".gz")

# Supprimer à partir de "backup"
echo "${fichier%backup*}"
# Résultat : "document."
```

### Fonctionnement avec `%%` (suppression maximale)

```bash
fichier="document.backup.tar.gz"

# Supprimer la plus grande correspondance de .*
echo "${fichier%%.*}"
# Résultat : "document"
# (supprime tout depuis le premier point)

# Supprimer à partir de "backup"
echo "${fichier%%backup*}"
# Résultat : "document."
# (identique au %, car il n'y a qu'une occurrence)
```

> [!example] Exemple pratique : Manipulation de noms de fichiers
> 
> ```bash
> fichier="rapport_2024.pdf"
> 
> # Supprimer l'extension
> nom_sans_ext="${fichier%.*}"
> echo "$nom_sans_ext"
> # Résultat : "rapport_2024"
> 
> # Extraire l'extension
> extension="${fichier##*.}"
> echo "$extension"
> # Résultat : "pdf"
> ```

### Opérateurs de suppression de préfixe (pour comparaison)

```bash
${variable#pattern}   # Supprime le plus court préfixe correspondant
${variable##pattern}  # Supprime le plus long préfixe correspondant
```

> [!info] Note sur préfixe vs suffixe
> 
> - `#` et `##` travaillent sur le **début** de la chaîne (préfixe)
> - `%` et `%%` travaillent sur la **fin** de la chaîne (suffixe)
> - Mnémotechnique : `#` vient avant `%` sur le clavier, comme préfixe vient avant suffixe

### Comparaison % vs %%

```bash
chemin="/home/user/documents/fichier.txt"

# Suppression minimale depuis la fin
echo "${chemin%/*}"
# Résultat : "/home/user/documents"
# (supprime "/fichier.txt")

# Suppression maximale depuis la fin
echo "${chemin%%/*}"
# Résultat : "" (chaîne vide)
# (supprime tout depuis le premier /)
```

### Tableau récapitulatif des opérateurs

|Opérateur|Position|Mode|Exemple avec "file.tar.gz"|
|---|---|---|---|
|`${var#*.}`|Début|Court|"tar.gz"|
|`${var##*.}`|Début|Long|"gz"|
|`${var%.*}`|Fin|Court|"file.tar"|
|`${var%%.*}`|Fin|Long|"file"|

### Cas d'usage avancés

```bash
# Extraire le nom de fichier d'un chemin complet
chemin="/var/log/system/app.log"
fichier="${chemin##*/}"
echo "$fichier"
# Résultat : "app.log"

# Extraire le répertoire parent
repertoire="${chemin%/*}"
echo "$repertoire"
# Résultat : "/var/log/system"

# Conversion d'extension
ancien="image.jpg"
nouveau="${ancien%.jpg}.png"
echo "$nouveau"
# Résultat : "image.png"

# Nettoyer les chemins avec double slash
chemin="/home//user///documents////file.txt"
propre="${chemin//\/\//\/}"  # Remplace // par /
echo "$propre"
# Résultat : "/home/user/documents/file.txt"
```

> [!tip] Astuce : Combiner extraction et suppression
> 
> ```bash
> fichier="archive.backup.2024.tar.gz"
> 
> # Obtenir le nom de base et l'extension complète
> base="${fichier%%.*}"        # "archive"
> ext_complete="${fichier#*.}" # "backup.2024.tar.gz"
> 
> echo "Base : $base"
> echo "Extensions : $ext_complete"
> ```

---

## ⚠️ Pièges courants

### 1. Oublier l'espace avec l'offset négatif

```bash
texte="Bonjour"

# ❌ INCORRECT : Interprété comme valeur par défaut
echo "${texte:-5}"
# Résultat : "Bonjour" (car texte n'est pas vide)

# ✅ CORRECT : Espace obligatoire
echo "${texte: -5}"
# Résultat : "njour"
```

> [!warning] Confusion avec `${variable:-default}` Sans espace, `-` est interprété comme l'opérateur de valeur par défaut, pas comme un offset négatif !

### 2. Confusion entre offset et index

```bash
texte="Bash"
#      0123

# L'offset 0 pointe sur 'B'
# L'offset 1 pointe sur 'a'
# L'offset 2 pointe sur 's'
# L'offset 3 pointe sur 'h'

echo "${texte:1:1}"  # "a" (pas "B")
```

### 3. Guillemets et espaces

```bash
texte="Hello World"

# ❌ Sans guillemets : peut causer des problèmes
resultat=${texte:6}  # Fonctionne mais risqué
echo $resultat

# ✅ Avec guillemets : toujours plus sûr
resultat="${texte:6}"
echo "$resultat"
```

> [!tip] Bonne pratique Toujours utiliser des guillemets doubles autour des expansions de variables pour éviter les problèmes avec les espaces et les caractères spéciaux.

### 4. Length négatif non supporté

```bash
texte="Bonjour"

# ❌ ERREUR : length négatif invalide
# echo "${texte:2:-2}"  # Syntax error!

# ✅ CORRECT : Calculer la longueur
longueur=${#texte}
echo "${texte:2:$((longueur-4))}"
# Résultat : "njo"
```

### 5. Variables non initialisées

```bash
# ❌ Variable vide ou non définie
unset texte
echo "${texte:5}"
# Résultat : "" (chaîne vide, pas d'erreur mais résultat vide)

# ✅ Vérifier avant d'extraire
if [[ -n "$texte" ]]; then
    echo "${texte:5}"
else
    echo "Variable vide ou non définie"
fi
```

### 6. Caractères multi-octets (UTF-8)

```bash
texte="Café"  # é = 2 octets en UTF-8

# ⚠️ Peut donner des résultats inattendus
echo "${texte:3:1}"
# Résultat peut varier selon l'encodage

# Note : Bash compte en octets, pas en caractères
# Pour les caractères multi-octets, considérer des outils comme awk ou Python
```

### 7. Offset au-delà de la longueur

```bash
texte="Test"

# Pas d'erreur, mais chaîne vide
echo "${texte:100}"
# Résultat : ""

echo "${texte:100:50}"
# Résultat : ""
```

---

## ✨ Bonnes pratiques

### 1. Toujours utiliser des guillemets

```bash
# ✅ BIEN
texte="Hello World"
sous_chaine="${texte:6:5}"
echo "$sous_chaine"

# ❌ ÉVITER (fonctionne mais moins sûr)
sous_chaine=${texte:6:5}
echo $sous_chaine
```

### 2. Documenter les offsets magiques

```bash
# ✅ BIEN : Commentaire explicite
date="2024-12-13"
annee="${date:0:4}"   # Position 0, 4 caractères : YYYY
mois="${date:5:2}"    # Position 5, 2 caractères : MM
jour="${date:8:2}"    # Position 8, 2 caractères : DD

# Ou utiliser des constantes
OFFSET_ANNEE=0
LENGTH_ANNEE=4
annee="${date:$OFFSET_ANNEE:$LENGTH_ANNEE}"
```

### 3. Privilégier la lisibilité

```bash
fichier="document.txt"

# ✅ BIEN : Intention claire
nom_sans_extension="${fichier%.*}"

# ❌ MOINS CLAIR : Nécessite de compter
nom_sans_extension="${fichier:0:$((${#fichier}-4))}"
```

### 4. Valider les données d'entrée

```bash
fonction_extraire() {
    local texte="$1"
    local offset="$2"
    local length="$3"
    
    # Vérifications
    if [[ -z "$texte" ]]; then
        echo "Erreur : chaîne vide" >&2
        return 1
    fi
    
    if [[ $offset -ge ${#texte} ]]; then
        echo "Erreur : offset trop grand" >&2
        return 1
    fi
    
    # Extraction sécurisée
    echo "${texte:$offset:$length}"
}
```

### 5. Combiner avec d'autres techniques

```bash
# Extraction + transformation
email="utilisateur@exemple.com"
nom_utilisateur="${email%@*}"           # "utilisateur"
nom_maj="${nom_utilisateur^^}"          # "UTILISATEUR"

# Extraction + validation
extension="${fichier##*.}"
if [[ "$extension" =~ ^(jpg|png|gif)$ ]]; then
    echo "Image valide"
fi
```

### 6. Utiliser des fonctions réutilisables

```bash
# Fonction pour extraire le nom de fichier sans extension
get_filename_without_ext() {
    local filepath="$1"
    local filename="${filepath##*/}"   # Supprimer le chemin
    echo "${filename%.*}"              # Supprimer l'extension
}

# Utilisation
nom=$(get_filename_without_ext "/chemin/vers/fichier.txt")
echo "$nom"  # "fichier"
```

### 7. Tester les cas limites

```bash
test_extraction() {
    local texte="$1"
    
    echo "Texte : '$texte'"
    echo "Longueur : ${#texte}"
    echo "Premiers 3 : '${texte:0:3}'"
    echo "Derniers 3 : '${texte: -3}'"
    echo "Tout sauf 1er : '${texte:1}'"
    echo "Tout sauf dernier : '${texte:0: -1}'"
}

# Tester avec différents cas
test_extraction "Test"
test_extraction ""
test_extraction "À"
```

### 8. Performance : extraction vs outils externes

```bash
# ✅ RAPIDE : Extraction native Bash
for i in {1..1000}; do
    result="${fichier:0:10}"
done

# ❌ LENT : Lancement de processus externes
for i in {1..1000}; do
    result=$(echo "$fichier" | cut -c1-10)
done
```

> [!tip] Astuce performance Les extractions de sous-chaînes natives sont 10 à 100 fois plus rapides que les outils externes comme `cut`, `awk`, ou `sed` car elles n'impliquent pas de création de processus.

### 9. Éviter les calculs complexes répétés

```bash
# ❌ INEFFICACE
for file in *.txt; do
    echo "${file:0:$((${#file}-4))}"
done

# ✅ EFFICACE
for file in *.txt; do
    echo "${file%.txt}"  # Plus simple et plus rapide
done
```

### 10. Documentation des patterns de suffixe/préfixe

```bash
# Créer des fonctions documentées pour les cas courants
strip_extension() {
    # Supprime l'extension d'un nom de fichier
    # Usage: strip_extension "fichier.txt"
    echo "${1%.*}"
}

get_extension() {
    # Extrait l'extension d'un nom de fichier
    # Usage: get_extension "fichier.txt"
    echo "${1##*.}"
}

get_dirname() {
    # Extrait le chemin du répertoire
    # Usage: get_dirname "/path/to/file"
    echo "${1%/*}"
}

get_basename() {
    # Extrait le nom de fichier
    # Usage: get_basename "/path/to/file"
    echo "${1##*/}"
}
```

---

> [!tip] 💡 Points clés à retenir
> 
> - `${var:offset}` : extrait depuis `offset` jusqu'à la fin
> - `${var:offset:length}` : extrait `length` caractères depuis `offset`
> - `${var: -n}` : extrait les `n` derniers caractères (espace obligatoire !)
> - `${var%pattern}` : supprime le plus court suffixe correspondant
> - `${var%%pattern}` : supprime le plus long suffixe correspondant
> - Toujours utiliser des guillemets pour la sécurité
> - L'extraction native est plus performante que les outils externes