

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

La mesure de la longueur d'une chaîne de caractères est une opération fondamentale en programmation Bash. Elle permet de :

- **Valider des entrées utilisateur** (vérifier qu'un mot de passe a une longueur minimale)
- **Contrôler des flux de traitement** (ignorer les chaînes vides)
- **Formater des sorties** (ajuster l'alignement)
- **Détecter des erreurs** (s'assurer qu'une variable n'est pas vide)

Bash offre une syntaxe native simple et efficace pour obtenir cette information sans avoir besoin de commandes externes.

---

## 📐 La syntaxe `${#variable}`

### Principe de base

La syntaxe `${#variable}` retourne le nombre de caractères contenus dans la variable.

> [!info] Syntaxe
> 
> ```bash
> ${#nom_de_variable}
> ```
> 
> Cette expansion renvoie la longueur de la chaîne stockée dans `nom_de_variable`.

### Exemples fondamentaux

```bash
#!/bin/bash

# Exemple simple
prenom="Alice"
echo ${#prenom}  # Affiche : 5

# Avec des espaces
phrase="Bonjour le monde"
echo ${#phrase}  # Affiche : 16 (les espaces comptent)

# Avec des caractères spéciaux
texte="C'est l'été! 🌞"
echo ${#texte}  # La longueur dépend de l'encodage des emojis
```

> [!example] Exemple pratique : Validation de longueur
> 
> ```bash
> #!/bin/bash
> 
> username="john_doe"
> 
> # Vérifier que le nom d'utilisateur a entre 3 et 20 caractères
> longueur=${#username}
> 
> if [ $longueur -ge 3 ] && [ $longueur -le 20 ]; then
>     echo "Nom d'utilisateur valide (${longueur} caractères)"
> else
>     echo "Le nom doit contenir entre 3 et 20 caractères"
> fi
> ```

### Caractéristiques importantes

|Aspect|Comportement|
|---|---|
|**Espaces**|Comptés comme des caractères normaux|
|**Tabulations**|Comptées comme un seul caractère|
|**Sauts de ligne**|Comptés dans la longueur|
|**Caractères spéciaux**|Comptés (attention à l'encodage UTF-8)|
|**Chaîne vide**|Retourne 0|

```bash
#!/bin/bash

# Les espaces comptent
texte="   "
echo ${#texte}  # Affiche : 3

# Saut de ligne
multiligne="ligne1
ligne2"
echo ${#multiligne}  # Inclut le caractère de saut de ligne

# Tabulation
avec_tab="avant	après"
echo ${#avec_tab}  # La tabulation compte pour 1
```

---

## 🔀 Utilisation dans les conditions

### Tests conditionnels classiques

La longueur d'une chaîne est fréquemment utilisée dans les structures conditionnelles pour contrôler le flux d'exécution.

> [!tip] Structure typique
> 
> ```bash
> if [ ${#variable} -operator valeur ]; then
>     # Actions
> fi
> ```

#### Opérateurs de comparaison numérique

```bash
#!/bin/bash

mot_de_passe="SecurePass123"
longueur=${#mot_de_passe}

# Égalité
if [ $longueur -eq 13 ]; then
    echo "Exactement 13 caractères"
fi

# Inégalité
if [ $longueur -ne 10 ]; then
    echo "Différent de 10 caractères"
fi

# Supérieur ou égal
if [ $longueur -ge 8 ]; then
    echo "Au moins 8 caractères"
fi

# Inférieur
if [ $longueur -lt 20 ]; then
    echo "Moins de 20 caractères"
fi
```

> [!warning] Attention aux guillemets Dans les tests, il est recommandé d'utiliser des guillemets autour des variables si elles peuvent être vides :
> 
> ```bash
> if [ "${#variable}" -gt 0 ]; then
>     echo "Variable non vide"
> fi
> ```

### Conditions composées

```bash
#!/bin/bash

login="user123"
longueur=${#login}

# ET logique (&&)
if [ $longueur -ge 5 ] && [ $longueur -le 15 ]; then
    echo "Longueur acceptable"
fi

# OU logique (||)
if [ $longueur -lt 3 ] || [ $longueur -gt 20 ]; then
    echo "Longueur invalide"
    exit 1
fi
```

### Syntaxe alternative avec double crochets

```bash
#!/bin/bash

# Avec [[ ]] (plus moderne et robuste)
texte="exemple"

if [[ ${#texte} -gt 5 ]]; then
    echo "Plus de 5 caractères"
fi

# Combinaison sans && externe
if [[ ${#texte} -ge 3 && ${#texte} -le 10 ]]; then
    echo "Entre 3 et 10 caractères"
fi
```

> [!info] Différence `[ ]` vs `[[ ]]`
> 
> - `[[ ]]` est spécifique à Bash et offre plus de fonctionnalités
> - Pas besoin de guillemets pour les variables
> - Support des opérateurs `&&` et `||` à l'intérieur des crochets
> - Meilleure gestion des erreurs

### Cas pratiques

#### Validation d'un mot de passe

```bash
#!/bin/bash

read -sp "Entrez votre mot de passe : " password
echo

longueur=${#password}

if [ $longueur -lt 8 ]; then
    echo "❌ Mot de passe trop court (minimum 8 caractères)"
    exit 1
elif [ $longueur -gt 64 ]; then
    echo "❌ Mot de passe trop long (maximum 64 caractères)"
    exit 1
else
    echo "✅ Longueur du mot de passe acceptable"
fi
```

#### Vérification de champ requis

```bash
#!/bin/bash

read -p "Nom : " nom
read -p "Email : " email

# Vérifier que les champs ne sont pas vides
if [ ${#nom} -eq 0 ] || [ ${#email} -eq 0 ]; then
    echo "Erreur : Tous les champs sont obligatoires"
    exit 1
fi

echo "Informations enregistrées"
```

---

## 🔍 Gestion des chaînes vides

### Détection d'une chaîne vide

Une chaîne vide a une longueur de 0. C'est le moyen le plus fiable de détecter si une variable est vide.

```bash
#!/bin/bash

# Variable vide
vide=""
echo ${#vide}  # Affiche : 0

# Test de chaîne vide
if [ ${#vide} -eq 0 ]; then
    echo "La variable est vide"
fi
```

> [!tip] Méthode recommandée Utiliser `${#variable} -eq 0` est plus explicite et robuste que `[ -z "$variable" ]` pour vérifier qu'une chaîne est vide.

### Différence entre vide et non définie

```bash
#!/bin/bash

# Variable non définie
echo ${#variable_inexistante}  # Affiche : 0

# Variable définie mais vide
variable_vide=""
echo ${#variable_vide}  # Affiche : 0

# Variable avec espaces uniquement
variable_espaces="   "
echo ${#variable_espaces}  # Affiche : 3 (pas vide !)
```

> [!warning] Variable non définie Une variable non définie est traitée comme une chaîne vide par `${#variable}`. Si vous devez distinguer les deux cas, utilisez `${variable+x}` pour tester l'existence.

### Gestion des espaces

```bash
#!/bin/bash

# Entrée utilisateur avec espaces
read -p "Entrez quelque chose : " input

# Supprimer les espaces de début et fin (trim)
input_trimmed=$(echo "$input" | xargs)

# Comparer les longueurs
if [ ${#input} -ne ${#input_trimmed} ]; then
    echo "Des espaces ont été supprimés"
fi

# Vérifier si la chaîne trimée est vide
if [ ${#input_trimmed} -eq 0 ]; then
    echo "Aucune donnée saisie"
fi
```

### Validation d'entrées utilisateur

```bash
#!/bin/bash

function valider_champ() {
    local valeur="$1"
    local nom_champ="$2"
    
    # Vérifier la longueur
    if [ ${#valeur} -eq 0 ]; then
        echo "❌ Le champ '$nom_champ' ne peut pas être vide"
        return 1
    fi
    
    return 0
}

# Utilisation
read -p "Prénom : " prenom
valider_champ "$prenom" "Prénom" || exit 1

read -p "Nom : " nom
valider_champ "$nom" "Nom" || exit 1

echo "✅ Tous les champs sont remplis"
```

---

## ⚠️ Pièges courants

### 1. Variables non initialisées

```bash
#!/bin/bash

# ❌ Mauvais : la variable n'existe pas
if [ ${#ma_variable} -gt 0 ]; then
    echo "Ceci s'affiche jamais car longueur = 0"
fi

# ✅ Bon : initialiser ou tester l'existence
ma_variable="${ma_variable:-}"  # Initialiser à vide si non définie
if [ ${#ma_variable} -gt 0 ]; then
    echo "Variable non vide"
fi
```

### 2. Oublier le symbole `$` lors de la comparaison

```bash
#!/bin/bash

texte="bonjour"

# ❌ Erreur : oubli du $
if [ {#texte} -gt 5 ]; then  # Erreur de syntaxe
    echo "Test"
fi

# ✅ Correct
if [ ${#texte} -gt 5 ]; then
    echo "Plus de 5 caractères"
fi
```

### 3. Confusion avec les tableaux

```bash
#!/bin/bash

# Pour les tableaux, ${#array} donne le nombre d'éléments
tableau=("un" "deux" "trois")
echo ${#tableau}  # Affiche : 2 (longueur de "un", premier élément)
echo ${#tableau[@]}  # Affiche : 3 (nombre d'éléments)

# Pour la longueur d'un élément spécifique
echo ${#tableau[1]}  # Affiche : 4 (longueur de "deux")
```

> [!warning] Tableaux vs chaînes
> 
> - `${#variable}` : longueur d'une chaîne OU longueur du premier élément d'un tableau
> - `${#array[@]}` : nombre d'éléments dans un tableau
> - `${#array[i]}` : longueur de l'élément à l'index i

### 4. Caractères multi-octets (UTF-8)

```bash
#!/bin/bash

# Attention avec les caractères accentués et emojis
texte="café"
echo ${#texte}  # Peut afficher 4 ou 5 selon l'encodage

emoji="🎉"
echo ${#emoji}  # Longueur variable selon la façon dont Bash compte

# Pour compter les caractères visibles avec UTF-8
longueur_visuelle=$(echo -n "$texte" | wc -m)
echo $longueur_visuelle
```

### 5. Variables avec espaces dans les tests

```bash
#!/bin/bash

# ❌ Risqué sans guillemets si la variable peut être vide
variable=""
if [ ${#variable} -eq 0 ]; then  # Peut causer une erreur dans certains cas
    echo "Vide"
fi

# ✅ Plus sûr avec guillemets
if [ "${#variable}" -eq 0 ]; then
    echo "Vide"
fi

# ✅ Encore mieux avec [[ ]]
if [[ ${#variable} -eq 0 ]]; then
    echo "Vide"
fi
```

---

## ✅ Bonnes pratiques

### 1. Nommage clair des variables de longueur

```bash
#!/bin/bash

# ✅ Bon : variable explicite
texte="exemple"
longueur_texte=${#texte}

if [ $longueur_texte -gt 5 ]; then
    echo "Traitement..."
fi

# Plutôt que de répéter ${#texte} partout
```

### 2. Valider tôt, échouer rapidement

```bash
#!/bin/bash

function traiter_fichier() {
    local nom_fichier="$1"
    
    # Valider immédiatement
    if [ ${#nom_fichier} -eq 0 ]; then
        echo "Erreur : nom de fichier requis" >&2
        return 1
    fi
    
    # Suite du traitement...
    echo "Traitement de $nom_fichier"
}
```

### 3. Messages d'erreur informatifs

```bash
#!/bin/bash

read -p "Code postal : " code_postal
longueur=${#code_postal}

if [ $longueur -ne 5 ]; then
    # ✅ Message clair avec la longueur actuelle
    echo "Erreur : le code postal doit contenir 5 chiffres (actuellement : $longueur)"
    exit 1
fi
```

### 4. Utiliser des constantes pour les limites

```bash
#!/bin/bash

# Constantes en majuscules
readonly MIN_PASSWORD_LENGTH=8
readonly MAX_PASSWORD_LENGTH=64
readonly MIN_USERNAME_LENGTH=3
readonly MAX_USERNAME_LENGTH=20

# Utilisation claire
read -p "Nom d'utilisateur : " username

if [ ${#username} -lt $MIN_USERNAME_LENGTH ]; then
    echo "Le nom d'utilisateur doit contenir au moins $MIN_USERNAME_LENGTH caractères"
    exit 1
fi

if [ ${#username} -gt $MAX_USERNAME_LENGTH ]; then
    echo "Le nom d'utilisateur ne peut pas dépasser $MAX_USERNAME_LENGTH caractères"
    exit 1
fi
```

### 5. Fonctions de validation réutilisables

```bash
#!/bin/bash

# Fonction générique de validation de longueur
valider_longueur() {
    local valeur="$1"
    local min="$2"
    local max="$3"
    local nom_champ="$4"
    
    local longueur=${#valeur}
    
    if [ $longueur -lt $min ]; then
        echo "❌ $nom_champ : minimum $min caractères (actuel : $longueur)" >&2
        return 1
    fi
    
    if [ $longueur -gt $max ]; then
        echo "❌ $nom_champ : maximum $max caractères (actuel : $longueur)" >&2
        return 1
    fi
    
    return 0
}

# Utilisation
read -p "Pseudo : " pseudo
valider_longueur "$pseudo" 3 15 "Pseudo" || exit 1

read -p "Bio : " bio
valider_longueur "$bio" 10 200 "Biographie" || exit 1

echo "✅ Validation réussie"
```

---

## 💡 Astuces avancées

### 1. Comparaison de longueurs de plusieurs variables

```bash
#!/bin/bash

prenom="Alice"
nom="Dupont"

# Trouver le champ le plus long
if [ ${#prenom} -gt ${#nom} ]; then
    max_longueur=${#prenom}
else
    max_longueur=${#nom}
fi

echo "Longueur maximale : $max_longueur"
```

### 2. Boucle avec condition sur la longueur

```bash
#!/bin/bash

# Demander jusqu'à obtenir une entrée valide
while true; do
    read -p "Entrez un mot de passe (min 8 caractères) : " -s password
    echo
    
    if [ ${#password} -ge 8 ]; then
        echo "✅ Mot de passe accepté"
        break
    else
        echo "❌ Trop court. Réessayez."
    fi
done
```

### 3. Calculer la longueur moyenne

```bash
#!/bin/bash

mots=("chat" "chien" "oiseau" "poisson")
total=0

for mot in "${mots[@]}"; do
    total=$((total + ${#mot}))
done

moyenne=$((total / ${#mots[@]}))
echo "Longueur moyenne : $moyenne caractères"
```

### 4. Formater avec padding basé sur la longueur

```bash
#!/bin/bash

# Aligner à droite sur 10 caractères
afficher_avec_padding() {
    local texte="$1"
    local largeur=10
    local longueur=${#texte}
    local padding=$((largeur - longueur))
    
    if [ $padding -gt 0 ]; then
        printf "%${padding}s%s\n" "" "$texte"
    else
        echo "$texte"
    fi
}

afficher_avec_padding "A"
afficher_avec_padding "ABC"
afficher_avec_padding "ABCDEFGHIJ"
```

### 5. Vérification de format avec longueur

```bash
#!/bin/bash

# Valider un numéro de téléphone français
valider_telephone() {
    local numero="$1"
    
    # Supprimer les espaces et tirets
    numero_clean=$(echo "$numero" | tr -d ' -')
    
    # Vérifier la longueur (10 chiffres)
    if [ ${#numero_clean} -ne 10 ]; then
        echo "❌ Numéro invalide : doit contenir 10 chiffres"
        return 1
    fi
    
    # Vérifier que c'est uniquement des chiffres
    if [[ ! "$numero_clean" =~ ^[0-9]+$ ]]; then
        echo "❌ Numéro invalide : chiffres uniquement"
        return 1
    fi
    
    echo "✅ Numéro valide : $numero_clean"
    return 0
}

# Test
valider_telephone "06 12 34 56 78"
valider_telephone "01-23-45-67-89"
valider_telephone "123"  # Trop court
```

### 6. Longueur dynamique dans les scripts

```bash
#!/bin/bash

# Ajuster le comportement selon la longueur d'entrée
traiter_texte() {
    local texte="$1"
    local longueur=${#texte}
    
    if [ $longueur -le 50 ]; then
        # Texte court : affichage direct
        echo "Texte : $texte"
    elif [ $longueur -le 200 ]; then
        # Texte moyen : affichage avec retour à la ligne
        echo "Texte :"
        echo "$texte" | fold -w 50
    else
        # Texte long : sauvegarde dans un fichier
        echo "$texte" > texte_long.txt
        echo "Texte trop long, sauvegardé dans texte_long.txt"
    fi
}

# Utilisation
traiter_texte "Court"
traiter_texte "Un texte de longueur moyenne qui sera formaté avec des retours à la ligne"
traiter_texte "$(cat un_tres_long_fichier.txt)"
```

---

## 🎯 Résumé

La syntaxe `${#variable}` permet de mesurer efficacement la longueur d'une chaîne en Bash :

|Utilisation|Syntaxe|Résultat|
|---|---|---|
|Longueur simple|`${#var}`|Nombre de caractères|
|Dans un test|`[ ${#var} -gt 5 ]`|Condition booléenne|
|Chaîne vide|`[ ${#var} -eq 0 ]`|Détection de vide|
|Avec validation|`if [[ ${#var} -ge 3 && ${#var} -le 10 ]]`|Plage de longueur|

**Points clés à retenir :**

- ✅ Utilisez `${#variable}` pour obtenir la longueur
- ✅ Testez avec `-eq`, `-lt`, `-gt`, `-le`, `-ge`
- ✅ Une chaîne vide a une longueur de 0
- ✅ Préférez `[[ ]]` pour plus de robustesse
- ⚠️ Attention aux caractères UTF-8 multi-octets
- ⚠️ Distinguez longueur de chaîne et taille de tableau