

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

La conversion de casse (case conversion) en Bash permet de modifier la capitalisation des caractères d'une chaîne de caractères directement dans le shell, sans avoir besoin d'outils externes comme `tr` ou `awk`.

> [!info] Disponibilité Ces fonctionnalités sont disponibles depuis **Bash 4.0** (2009). Vérifiez votre version avec `bash --version`.

### Pourquoi utiliser les conversions de casse natives ?

- **Performance** : Plus rapides que les commandes externes
- **Portabilité** : Pas de dépendance à des outils externes
- **Simplicité** : Syntaxe concise et lisible
- **Efficacité** : Pas de création de sous-processus

---

## 📖 Syntaxe générale

Les conversions de casse utilisent la syntaxe d'expansion de paramètres de Bash :

```bash
${variable[opérateur][pattern]}
```

|Opérateur|Action|
|---|---|
|`^^`|Convertit tout en MAJUSCULES|
|`,,`|Convertit tout en minuscules|
|`^`|Capitalise le premier caractère|
|`,`|Met le premier caractère en minuscule|
|`^^[pattern]`|Convertit en majuscules selon un pattern|
|`,,[pattern]`|Convertit en minuscules selon un pattern|

---

## 🔠 Conversion en majuscules

### Tout en majuscules : `${var^^}`

Convertit **tous** les caractères alphabétiques en majuscules.

```bash
#!/bin/bash

texte="bonjour le monde"
majuscules="${texte^^}"

echo "$majuscules"  # Affiche : BONJOUR LE MONDE
```

> [!example] Exemples pratiques
> 
> ```bash
> # Normaliser un nom de fichier
> fichier="readme.txt"
> echo "${fichier^^}"  # README.TXT
> 
> # Constantes d'environnement
> env_var="database_host"
> echo "${env_var^^}"  # DATABASE_HOST
> 
> # Codes pays
> pays="france"
> echo "${pays^^}"  # FRANCE
> ```

### Avec pattern : `${var^^[pattern]}`

Convertit en majuscules uniquement les caractères qui correspondent au pattern.

```bash
#!/bin/bash

texte="bonjour123monde"

# Convertir uniquement les voyelles en majuscules
echo "${texte^^[aeiou]}"  # bOnjOUr123mOndE

# Convertir uniquement les consonnes
echo "${texte^^[bcdfghjklmnpqrstvwxyz]}"  # BoNJouR123MoNDe

# Convertir une plage de caractères
texte2="abc123xyz"
echo "${texte2^^[a-m]}"  # ABC123xyz
```

> [!tip] Utilisation des patterns Les patterns suivent la syntaxe des expressions glob :
> 
> - `[aeiou]` : voyelles
> - `[a-z]` : toutes les minuscules
> - `[0-9]` : chiffres (pas d'effet sur la casse)
> - `[!aeiou]` : tout sauf les voyelles

---

## 🔡 Conversion en minuscules

### Tout en minuscules : `${var,,}`

Convertit **tous** les caractères alphabétiques en minuscules.

```bash
#!/bin/bash

texte="BONJOUR LE MONDE"
minuscules="${texte,,}"

echo "$minuscules"  # Affiche : bonjour le monde
```

> [!example] Exemples pratiques
> 
> ```bash
> # Normaliser une saisie utilisateur
> read -p "Entrez votre nom : " nom
> nom_normalise="${nom,,}"
> echo "Nom normalisé : $nom_normalise"
> 
> # Extensions de fichiers
> fichier="IMAGE.PNG"
> echo "${fichier,,}"  # image.png
> 
> # Comparaisons insensibles à la casse
> reponse="OUI"
> if [[ "${reponse,,}" == "oui" ]]; then
>     echo "Réponse positive"
> fi
> ```

### Avec pattern : `${var,,[pattern]}`

Convertit en minuscules uniquement les caractères qui correspondent au pattern.

```bash
#!/bin/bash

texte="BONJOUR123MONDE"

# Convertir uniquement les voyelles en minuscules
echo "${texte,,[AEIOU]}"  # BONJoUR123MoNDE

# Convertir uniquement certaines lettres
texte2="ABC123XYZ"
echo "${texte2,,[A-M]}"  # abc123XYZ
```

---

## 🎩 Capitalisation

### Premier caractère en majuscule : `${var^}`

Convertit uniquement le **premier caractère** en majuscule (le reste reste inchangé).

```bash
#!/bin/bash

texte="bonjour le monde"
capitalise="${texte^}"

echo "$capitalise"  # Affiche : Bonjour le monde
```

> [!warning] Attention `${var^}` ne convertit que le premier caractère. Les autres caractères conservent leur casse d'origine.

```bash
texte="bONjOuR"
echo "${texte^}"  # BONjOuR (et non "Bonjour")
```

> [!example] Usage typique
> 
> ```bash
> # Formater un nom propre
> prenom="jean"
> echo "${prenom^}"  # Jean
> 
> # Début de phrase
> phrase="voici une phrase."
> echo "${phrase^}"  # Voici une phrase.
> 
> # Titre avec première lettre capitalisée
> titre="guide bash avancé"
> echo "${titre^}"  # Guide bash avancé
> ```

### Avec pattern : `${var^[pattern]}`

Capitalise le premier caractère qui correspond au pattern.

```bash
#!/bin/bash

texte="123bonjour"
echo "${texte^}"          # 123bonjour (le 1 n'est pas alphabétique)
echo "${texte^[a-z]}"     # 123Bonjour (premier caractère alphabétique)

texte2="  bonjour"
echo "${texte2^[a-z]}"    # "  Bonjour"
```

### Premier caractère en minuscule : `${var,}`

Convertit uniquement le **premier caractère** en minuscule.

```bash
#!/bin/bash

texte="BONJOUR LE MONDE"
decapitalise="${texte,}"

echo "$decapitalise"  # Affiche : bONJOUR LE MONDE
```

> [!example] Exemples
> 
> ```bash
> # Conventions de nommage camelCase
> variable="NomVariable"
> echo "${variable,}"  # nomVariable
> 
> # Début de phrase en minuscule (style poétique)
> phrase="Le Soleil Brille"
> echo "${phrase,}"  # le Soleil Brille
> ```

### Avec pattern : `${var,[pattern]}`

Met en minuscule le premier caractère qui correspond au pattern.

```bash
#!/bin/bash

texte="123BONJOUR"
echo "${texte,[A-Z]}"  # 123bONJOUR
```

---

## 🎯 Patterns spécifiques

### Syntaxe des patterns

Les patterns utilisent la même syntaxe que les expressions glob de Bash.

```bash
#!/bin/bash

texte="Hello World 2024"

# Voyelles uniquement
echo "${texte^^[aeiouAEIOU]}"  # HEllO WOrld 2024

# Consonnes uniquement
echo "${texte,,[BCDFGHJKLMNPQRSTVWXYZ]}"  # hello world 2024

# Plages de caractères
echo "${texte^^[a-f]}"  # HEllo WorlD 2024
echo "${texte^^[n-z]}"  # Hello WORLD 2024
```

### Patterns avec négation

Utilisez `[!pattern]` pour inverser la sélection.

```bash
#!/bin/bash

texte="abc123xyz"

# Tout sauf les voyelles
echo "${texte^^[!aeiou]}"  # aBC123XYZ

# Tout sauf les chiffres (pas d'effet visible ici)
echo "${texte^^[!0-9]}"  # ABC123XYZ
```

> [!tip] Combiner patterns et conversions
> 
> ```bash
> # Convertir certaines lettres tout en gardant d'autres
> code="x1y2z3"
> echo "${code^^[xyz]}"  # X1Y2Z3
> 
> # Pattern complexe
> texte="Bonjour123Monde"
> echo "${texte^^[a-m]}"  # BoNJour123MoNDE
> ```

---

## 💼 Cas d'usage pratiques

### Normalisation de saisies utilisateur

```bash
#!/bin/bash

# Validation de réponse oui/non
read -p "Continuer ? (oui/non) : " reponse

case "${reponse,,}" in
    oui|o|y|yes)
        echo "On continue..."
        ;;
    non|n|no)
        echo "Arrêt du script"
        exit 0
        ;;
    *)
        echo "Réponse invalide"
        ;;
esac
```

### Génération de constantes

```bash
#!/bin/bash

# Convertir des noms de variables en constantes
config_file="database.conf"
const_name="${config_file^^}"
const_name="${const_name//./_}"  # Remplacer . par _

echo "const $const_name = 'config'"  # const DATABASE_CONF = 'config'
```

### Formatage de noms propres

```bash
#!/bin/bash

# Capitaliser chaque mot (Title Case simplifié)
formatage_titre() {
    local phrase="$1"
    local resultat=""
    
    for mot in $phrase; do
        resultat+="${mot^} "
    done
    
    echo "${resultat% }"  # Enlever l'espace final
}

titre="guide complet du bash"
echo "$(formatage_titre "$titre")"  # Guide Complet Du Bash
```

### Comparaisons insensibles à la casse

```bash
#!/bin/bash

# Comparer deux chaînes sans tenir compte de la casse
comparer_insensible() {
    local str1="${1,,}"
    local str2="${2,,}"
    
    [[ "$str1" == "$str2" ]]
}

if comparer_insensible "BASH" "bash"; then
    echo "Les chaînes sont identiques (casse ignorée)"
fi
```

### Normalisation d'extensions de fichiers

```bash
#!/bin/bash

# Traiter des fichiers selon leur extension
traiter_fichier() {
    local fichier="$1"
    local extension="${fichier##*.}"
    extension="${extension,,}"  # Normaliser en minuscules
    
    case "$extension" in
        jpg|jpeg|png|gif)
            echo "Fichier image : $fichier"
            ;;
        pdf|doc|docx)
            echo "Document : $fichier"
            ;;
        *)
            echo "Type inconnu : $fichier"
            ;;
    esac
}

traiter_fichier "photo.JPG"    # Fichier image : photo.JPG
traiter_fichier "rapport.PDF"  # Document : rapport.PDF
```

---

## ⚠️ Pièges courants

### Piège n°1 : Version de Bash

> [!warning] Compatibilité Les conversions de casse nécessitent **Bash 4.0+**. Sur macOS, la version par défaut est souvent Bash 3.2.

```bash
#!/bin/bash

# Vérifier la version avant utilisation
if ((BASH_VERSINFO[0] < 4)); then
    echo "Erreur : Bash 4.0+ requis" >&2
    exit 1
fi

# Code utilisant les conversions de casse
texte="bonjour"
echo "${texte^^}"
```

### Piège n°2 : Ne modifie pas la variable originale

```bash
#!/bin/bash

texte="bonjour"
echo "${texte^^}"  # Affiche : BONJOUR

echo "$texte"      # Affiche toujours : bonjour (inchangé)

# Pour modifier la variable :
texte="${texte^^}"
echo "$texte"      # Affiche : BONJOUR
```

### Piège n°3 : Comportement avec les caractères spéciaux

```bash
#!/bin/bash

# Les caractères accentués ne sont pas toujours bien gérés
texte="éléphant"
echo "${texte^^}"  # Peut afficher : éLéPHANT (é non converti)

# Solution : utiliser la locale correcte
export LC_ALL=fr_FR.UTF-8
echo "${texte^^}"  # ÉLÉPHANT
```

### Piège n°4 : Pattern vide

```bash
#!/bin/bash

texte="Bonjour"

# Pattern vide = pas de conversion
echo "${texte^^[]}"  # Bonjour (inchangé)

# Équivalent à ne rien faire
echo "${texte}"      # Bonjour
```

### Piège n°5 : Confusion entre `^` et `^^`

```bash
#!/bin/bash

texte="bonjour le monde"

echo "${texte^}"   # Bonjour le monde (premier caractère uniquement)
echo "${texte^^}"  # BONJOUR LE MONDE (tous les caractères)

# Ne confondez pas !
```

---

## 🚀 Astuces avancées

### Astuce n°1 : Conversion conditionnelle

```bash
#!/bin/bash

# Convertir en majuscules si variable non vide
texte="bonjour"
resultat="${texte:+${texte^^}}"
echo "$resultat"  # BONJOUR

texte=""
resultat="${texte:+${texte^^}}"
echo "$resultat"  # (vide)
```

### Astuce n°2 : Capitalisation de chaque mot

```bash
#!/bin/bash

# Fonction pour capitaliser tous les mots
capitaliser_tous_mots() {
    local phrase="$1"
    local resultat=""
    
    # Parcourir chaque mot
    while IFS= read -r mot; do
        resultat+="${mot^} "
    done < <(echo "$phrase" | tr ' ' '\n')
    
    echo "${resultat% }"
}

echo "$(capitaliser_tous_mots "bonjour le monde")"  # Bonjour Le Monde
```

### Astuce n°3 : Toggle case (inverser la casse)

```bash
#!/bin/bash

# Inverser la casse de chaque caractère
inverser_casse() {
    local texte="$1"
    local resultat=""
    local i
    
    for ((i=0; i<${#texte}; i++)); do
        local char="${texte:$i:1}"
        local lower="${char,,}"
        
        if [[ "$char" == "$lower" ]]; then
            resultat+="${char^^}"
        else
            resultat+="${char,,}"
        fi
    done
    
    echo "$resultat"
}

echo "$(inverser_casse "HeLLo WoRLd")"  # hEllO wOrlD
```

### Astuce n°4 : Conversion sélective avec tableaux

```bash
#!/bin/bash

# Convertir certains éléments d'un tableau
declare -a noms=("jean" "MARIE" "Paul" "SOPHIE")
declare -a noms_normalises=()

for nom in "${noms[@]}"; do
    # Première lettre en majuscule, reste en minuscules
    nom="${nom,,}"
    nom="${nom^}"
    noms_normalises+=("$nom")
done

echo "${noms_normalises[@]}"  # Jean Marie Paul Sophie
```

### Astuce n°5 : Performance avec grandes chaînes

```bash
#!/bin/bash

# Les conversions natives sont plus rapides que les outils externes
grande_chaine=$(cat fichier_texte.txt)

# Méthode native (rapide)
time echo "${grande_chaine^^}" > /dev/null

# Méthode externe tr (plus lente)
time echo "$grande_chaine" | tr '[:lower:]' '[:upper:]' > /dev/null
```

### Astuce n°6 : Slugification (création d'URL-friendly strings)

```bash
#!/bin/bash

# Créer un slug à partir d'un titre
slugify() {
    local texte="$1"
    
    # Mettre en minuscules
    texte="${texte,,}"
    
    # Remplacer espaces par tirets
    texte="${texte// /-}"
    
    # Supprimer caractères spéciaux (simplification)
    texte="${texte//[^a-z0-9-]/}"
    
    echo "$texte"
}

titre="Guide Complet du Bash 2024!"
echo "$(slugify "$titre")"  # guide-complet-du-bash-2024
```

---

## 📊 Tableau récapitulatif

|Opération|Syntaxe|Exemple|Résultat|
|---|---|---|---|
|Tout en majuscules|`${var^^}`|`var="hello"` → `${var^^}`|`HELLO`|
|Tout en minuscules|`${var,,}`|`var="HELLO"` → `${var,,}`|`hello`|
|Premier en majuscule|`${var^}`|`var="hello"` → `${var^}`|`Hello`|
|Premier en minuscule|`${var,}`|`var="HELLO"` → `${var,}`|`hELLO`|
|Majuscules avec pattern|`${var^^[aeiou]}`|`var="hello"` → `${var^^[eo]}`|`hEllO`|
|Minuscules avec pattern|`${var,,[AEIOU]}`|`var="HELLO"` → `${var,,[EO]}`|`HeLLo`|

---

> [!tip] Conseil final Les conversions de casse natives de Bash sont puissantes et performantes. Utilisez-les pour simplifier votre code et éviter les dépendances externes. Pensez toujours à vérifier la version de Bash disponible sur vos systèmes cibles.