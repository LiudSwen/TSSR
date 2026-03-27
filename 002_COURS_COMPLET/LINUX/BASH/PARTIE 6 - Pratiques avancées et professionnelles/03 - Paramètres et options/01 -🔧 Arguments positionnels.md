

> [!info] Vue d'ensemble Les paramètres positionnels permettent aux scripts Bash de recevoir des données au moment de leur exécution. Cette partie couvre la manipulation des arguments `$1`, `$2`, etc., leur validation et la création de messages d'aide clairs.

---

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

## 🎯 Arguments positionnels

### Qu'est-ce qu'un argument positionnel ?

Les arguments positionnels sont les valeurs passées à un script lors de son exécution. Ils sont numérotés dans l'ordre où ils apparaissent sur la ligne de commande.

```bash
./mon_script.sh argument1 argument2 argument3
#               $1        $2        $3
```

> [!tip] Pourquoi c'est important Les arguments positionnels rendent vos scripts réutilisables et flexibles. Au lieu de coder des valeurs en dur, vous permettez à l'utilisateur de les spécifier à l'exécution.

### Variables spéciales liées aux arguments

|Variable|Description|Exemple|
|---|---|---|
|`$0`|Nom du script|`./mon_script.sh`|
|`$1` à `$9`|Arguments 1 à 9|Premier argument = `$1`|
|`${10}`|Arguments 10 et au-delà|Dixième argument = `${10}`|
|`$#`|Nombre total d'arguments|Si 3 args → `$# = 3`|
|`$*`|Tous les arguments (un seul mot)|`"$1 $2 $3"`|
|`$@`|Tous les arguments (mots séparés)|`"$1" "$2" "$3"`|

---

## 🔍 Accès aux arguments

### Arguments de 1 à 9

Pour les 9 premiers arguments, l'accès est direct avec la notation `$n` :

```bash
#!/bin/bash

# Script simple avec 3 arguments
echo "Premier argument : $1"
echo "Deuxième argument : $2"
echo "Troisième argument : $3"
```

**Exécution :**

```bash
./script.sh Alice Bob Charlie
# Sortie :
# Premier argument : Alice
# Deuxième argument : Bob
# Troisième argument : Charlie
```

### Arguments à partir de 10

> [!warning] Limite de la notation simple Au-delà de `$9`, la notation simple ne fonctionne plus. `$10` sera interprété comme `${1}0`, c'est-à-dire le premier argument suivi du caractère `0`.

**Solution : utiliser les accolades `${n}`**

```bash
#!/bin/bash

echo "Dixième argument : ${10}"
echo "Onzième argument : ${11}"
echo "Vingtième argument : ${20}"
```

**Exécution :**

```bash
./script.sh a b c d e f g h i j k l m n o p q r s t
# Sortie :
# Dixième argument : j
# Onzième argument : k
# Vingtième argument : t
```

> [!tip] Bonne pratique Pour la cohérence du code, certains développeurs utilisent systématiquement `${1}` au lieu de `$1`, même pour les premiers arguments.

### Accès à tous les arguments

**Différence entre `$*` et `$@` :**

```bash
#!/bin/bash

echo "Avec \$* :"
for arg in "$*"; do
    echo "  - $arg"
done

echo "Avec \$@ :"
for arg in "$@"; do
    echo "  - $arg"
done
```

**Exécution :**

```bash
./script.sh un deux trois
# Sortie :
# Avec $* :
#   - un deux trois           # Un seul élément
# Avec $@ :
#   - un                      # Trois éléments distincts
#   - deux
#   - trois
```

> [!info] Explication
> 
> - `"$*"` : Tous les arguments en une seule chaîne (séparés par le premier caractère de `$IFS`, généralement un espace)
> - `"$@"` : Chaque argument comme une chaîne séparée (préserve les espaces dans les arguments)

**Recommandation :** Utilisez presque toujours `"$@"` pour préserver l'intégrité des arguments.

---

## ✅ Vérification de présence

### Pourquoi vérifier les arguments ?

Un script robuste doit toujours vérifier que les arguments requis sont présents avant de les utiliser, sinon vous risquez :

- Des erreurs cryptiques
- Un comportement inattendu
- Des opérations sur des valeurs vides

### Vérification basique du nombre d'arguments

```bash
#!/bin/bash

# Vérifier qu'au moins 2 arguments sont fournis
if [ $# -lt 2 ]; then
    echo "Erreur : Il faut au moins 2 arguments"
    exit 1
fi

echo "Traitement de : $1 et $2"
```

### Vérification d'un argument spécifique

```bash
#!/bin/bash

# Vérifier que le premier argument existe
if [ -z "$1" ]; then
    echo "Erreur : Le premier argument est manquant"
    exit 1
fi

# Vérifier que le deuxième argument existe
if [ -z "$2" ]; then
    echo "Erreur : Le deuxième argument est manquant"
    exit 1
fi

echo "Arguments valides : $1 et $2"
```

> [!info] Syntaxe `-z` Le test `[ -z "$variable" ]` retourne vrai si la variable est vide ou non définie.

### Vérification avec nombre exact d'arguments

```bash
#!/bin/bash

# Exiger exactement 3 arguments
if [ $# -ne 3 ]; then
    echo "Erreur : Ce script nécessite exactement 3 arguments"
    echo "Vous en avez fourni : $#"
    exit 1
fi

echo "Parfait ! Les 3 arguments sont : $1, $2, $3"
```

### Opérateurs de comparaison pour les nombres

|Opérateur|Signification|Exemple|
|---|---|---|
|`-eq`|Égal à|`[ $# -eq 3 ]`|
|`-ne`|Différent de|`[ $# -ne 0 ]`|
|`-lt`|Inférieur à|`[ $# -lt 5 ]`|
|`-le`|Inférieur ou égal|`[ $# -le 10 ]`|
|`-gt`|Supérieur à|`[ $# -gt 1 ]`|
|`-ge`|Supérieur ou égal|`[ $# -ge 2 ]`|

### Vérification avancée avec valeurs par défaut

```bash
#!/bin/bash

# Utiliser des valeurs par défaut si arguments manquants
nom="${1:-Utilisateur}"
age="${2:-0}"
ville="${3:-Inconnue}"

echo "Nom : $nom"
echo "Âge : $age"
echo "Ville : $ville"
```

**Exécution :**

```bash
./script.sh Alice 25
# Sortie :
# Nom : Alice
# Âge : 25
# Ville : Inconnue
```

> [!tip] Syntaxe `${var:-valeur}` Cette notation signifie : "Utiliser `$var` si elle existe et n'est pas vide, sinon utiliser `valeur`"

---

## 📖 Messages d'usage

### Importance des messages d'usage

Un bon message d'usage est essentiel pour :

- Guider l'utilisateur dans l'utilisation correcte du script
- Documenter les arguments attendus
- Éviter les erreurs d'utilisation
- Rendre votre script professionnel

### Structure d'un message d'usage basique

```bash
#!/bin/bash

usage() {
    echo "Usage: $0 <nom> <prénom> <age>"
    echo ""
    echo "Arguments:"
    echo "  nom      : Nom de famille"
    echo "  prénom   : Prénom"
    echo "  age      : Âge en années"
}

# Vérifier le nombre d'arguments
if [ $# -ne 3 ]; then
    usage
    exit 1
fi

# Suite du script...
echo "Bonjour $2 $1, vous avez $3 ans"
```

> [!example] Exemple d'exécution
> 
> ```bash
> ./script.sh
> # Sortie :
> # Usage: ./script.sh <nom> <prénom> <age>
> #
> # Arguments:
> #   nom      : Nom de famille
> #   prénom   : Prénom
> #   age      : Âge en années
> ```

### Message d'usage avancé avec options

```bash
#!/bin/bash

usage() {
    cat << EOF
Usage: $0 [OPTIONS] <fichier_source> <fichier_destination>

Description:
  Copie un fichier avec options de sauvegarde et verbosité

Arguments obligatoires:
  fichier_source       Fichier à copier
  fichier_destination  Destination de la copie

Options:
  -v, --verbose       Mode verbeux
  -b, --backup        Créer une sauvegarde
  -h, --help          Afficher ce message d'aide

Exemples:
  $0 fichier.txt copie.txt
  $0 -v -b document.pdf sauvegarde/document.pdf
  $0 --help

EOF
}

# Afficher l'aide si demandé
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi

# Vérifier le minimum d'arguments
if [ $# -lt 2 ]; then
    echo "Erreur : Arguments manquants"
    echo ""
    usage
    exit 1
fi
```

> [!info] Technique `cat << EOF` Cette syntaxe (heredoc) permet d'écrire du texte multiligne de manière lisible. Tout le texte entre `<< EOF` et `EOF` sera affiché.

### Message d'usage avec formatage coloré

```bash
#!/bin/bash

# Définir les couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
${BLUE}═══════════════════════════════════════════════════════════${NC}
${GREEN}Usage:${NC} $0 [OPTIONS] <argument1> <argument2>

${YELLOW}Description:${NC}
  Ce script effectue une opération importante

${YELLOW}Arguments:${NC}
  ${GREEN}argument1${NC}    Premier argument (obligatoire)
  ${GREEN}argument2${NC}    Second argument (obligatoire)

${YELLOW}Options:${NC}
  ${GREEN}-h, --help${NC}      Afficher cette aide
  ${GREEN}-v, --verbose${NC}   Mode verbeux
  ${GREEN}-d, --debug${NC}     Mode débogage

${YELLOW}Exemples:${NC}
  $0 valeur1 valeur2
  $0 -v donnee1 donnee2
${BLUE}═══════════════════════════════════════════════════════════${NC}

EOF
}
```

### Pattern complet de validation

```bash
#!/bin/bash

usage() {
    cat << EOF
Usage: $0 <nom_utilisateur> <email> <age>

Crée un nouveau profil utilisateur

Arguments:
  nom_utilisateur    Nom d'utilisateur (3-20 caractères)
  email              Adresse email valide
  age                Âge (doit être un nombre positif)

EOF
}

# Fonction de validation
valider_arguments() {
    # Vérifier le nombre d'arguments
    if [ $# -ne 3 ]; then
        echo "Erreur : Nombre incorrect d'arguments ($# fournis, 3 requis)"
        usage
        exit 1
    fi
    
    # Vérifier que le nom d'utilisateur n'est pas vide
    if [ -z "$1" ]; then
        echo "Erreur : Le nom d'utilisateur ne peut pas être vide"
        exit 1
    fi
    
    # Vérifier que l'email contient un @
    if [[ ! "$2" =~ @.+ ]]; then
        echo "Erreur : Format d'email invalide"
        exit 1
    fi
    
    # Vérifier que l'âge est un nombre
    if ! [[ "$3" =~ ^[0-9]+$ ]]; then
        echo "Erreur : L'âge doit être un nombre entier positif"
        exit 1
    fi
}

# Appeler la validation
valider_arguments "$@"

# Si on arrive ici, les arguments sont valides
echo "Création du profil pour : $1 ($2), âge $3 ans"
```

---

## ⚠️ Pièges courants et bonnes pratiques

### Piège n°1 : Oublier les guillemets

> [!warning] Problème Sans guillemets, les arguments contenant des espaces seront divisés

```bash
# ❌ MAUVAIS
fichier=$1
echo "Traitement de" $fichier

# ✅ BON
fichier="$1"
echo "Traitement de $fichier"
```

**Exemple du problème :**

```bash
./script.sh "Mon Fichier.txt"
# Sans guillemets : $1 vaut "Mon", $2 vaut "Fichier.txt"
# Avec guillemets : $1 vaut "Mon Fichier.txt"
```

### Piège n°2 : Ne pas vérifier si les arguments existent

```bash
# ❌ MAUVAIS - Risque d'erreur
rm "$1"  # Si $1 est vide, peut supprimer le répertoire courant !

# ✅ BON - Toujours vérifier
if [ -z "$1" ]; then
    echo "Erreur : Aucun fichier spécifié"
    exit 1
fi
rm "$1"
```

### Piège n°3 : Confusion $* vs $@

```bash
# ❌ MAUVAIS pour les arguments avec espaces
for arg in $*; do
    echo "$arg"
done

# ✅ BON - Préserve les espaces dans les arguments
for arg in "$@"; do
    echo "$arg"
done
```

### Piège n°4 : Oublier les accolades pour $10+

```bash
# ❌ MAUVAIS
echo $10  # Affiche ${1}0, pas le 10ème argument

# ✅ BON
echo ${10}
```

### Bonnes pratiques essentielles

> [!tip] Checklist pour un script robuste
> 
> 1. **Toujours** mettre les variables entre guillemets : `"$1"` au lieu de `$1`
> 2. **Toujours** vérifier `$#` avant d'accéder aux arguments
> 3. **Toujours** créer une fonction `usage()` claire
> 4. **Utiliser** `"$@"` plutôt que `"$*"` dans les boucles
> 5. **Valider** le type et le format des arguments si critique
> 6. **Donner** des messages d'erreur explicites
> 7. **Retourner** un code de sortie approprié (`exit 1` en cas d'erreur)

### Template de script complet

```bash
#!/bin/bash

# Configuration des couleurs (optionnel)
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m'

# Fonction d'usage
usage() {
    cat << EOF
Usage: $0 <argument1> <argument2>

Description courte du script

Arguments:
  argument1    Description de argument1
  argument2    Description de argument2

Options:
  -h, --help    Afficher cette aide

Exemples:
  $0 valeur1 valeur2

EOF
}

# Fonction d'erreur
error_exit() {
    echo -e "${RED}Erreur:${NC} $1" >&2
    exit 1
}

# Vérifier l'aide
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi

# Valider le nombre d'arguments
if [ $# -ne 2 ]; then
    error_exit "Nombre incorrect d'arguments (fournis: $#, requis: 2)"
fi

# Valider l'existence des arguments
[ -z "$1" ] && error_exit "Le premier argument est vide"
[ -z "$2" ] && error_exit "Le second argument est vide"

# Assigner les arguments à des variables nommées (bonne pratique)
arg1="$1"
arg2="$2"

# Corps principal du script
echo -e "${GREEN}Succès:${NC} Traitement de '$arg1' et '$arg2'"

# Code de sortie 0 pour succès
exit 0
```

### Astuces avancées

**Astuce 1 : Variables nommées pour la lisibilité**

```bash
# Au lieu de utiliser directement $1, $2, $3
nom_utilisateur="$1"
email="$2"
age="$3"

echo "Création du compte pour $nom_utilisateur"
```

**Astuce 2 : Shift pour consommer les arguments**

```bash
#!/bin/bash

# Traiter les arguments un par un
while [ $# -gt 0 ]; do
    echo "Traitement de : $1"
    shift  # Décale tous les arguments ($2 devient $1, etc.)
done
```

**Astuce 3 : Compter les arguments restants**

```bash
#!/bin/bash

echo "Nombre d'arguments au départ : $#"
shift 2  # Consommer les 2 premiers arguments
echo "Nombre d'arguments restants : $#"
echo "Prochain argument : $1"
```

---

## 📝 Résumé des points clés

|Concept|Syntaxe|Usage|
|---|---|---|
|Premier argument|`$1`|Accès direct|
|Argument 10+|`${10}`|Accolades obligatoires|
|Nombre d'arguments|`$#`|Vérification|
|Tous les arguments|`"$@"`|Itération recommandée|
|Vérifier si vide|`[ -z "$1" ]`|Validation|
|Message d'usage|`usage()`|Documentation|
|Code de sortie erreur|`exit 1`|Signaler un problème|

> [!success] Vous maîtrisez maintenant
> 
> - L'accès aux arguments positionnels de `$1` à `${n}`
> - La différence entre `$*` et `$@`
> - La validation des arguments avec les tests
> - La création de messages d'usage professionnels
> - Les pièges courants et comment les éviter