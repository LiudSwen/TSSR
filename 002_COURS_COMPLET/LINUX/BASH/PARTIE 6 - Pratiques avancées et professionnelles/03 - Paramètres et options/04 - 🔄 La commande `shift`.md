

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

La commande `shift` est un outil puissant pour manipuler les arguments positionnels dans les scripts Bash. Elle permet de "décaler" les paramètres vers la gauche, facilitant ainsi le traitement séquentiel d'un nombre variable d'arguments.

> [!info] Pourquoi utiliser `shift` ?
> - Traiter un nombre inconnu d'arguments
> - Simplifier les boucles de traitement d'arguments
> - Améliorer la lisibilité du code
> - Gérer des options et des arguments de manière élégante

---

## 🧩 Concept fondamental

### Principe de fonctionnement

`shift` déplace tous les paramètres positionnels d'une position vers la gauche :
- `$2` devient `$1`
- `$3` devient `$2`
- etc.
- `$1` disparaît (est "consommé")
- `$#` est décrémenté

```bash
#!/bin/bash
# Avant shift
echo "Avant : $1 $2 $3"  # arg1 arg2 arg3

shift

# Après shift
echo "Après : $1 $2 $3"  # arg2 arg3 (vide)
```

> [!example] Exemple visuel
> ```
> Initial : ./script.sh pomme banane cerise orange
> $1=pomme  $2=banane  $3=cerise  $4=orange  $#=4
> 
> Après shift :
> $1=banane  $2=cerise  $3=orange  $4=(vide)  $#=3
> 
> Après shift 2 :
> $1=orange  $2=(vide)  $3=(vide)  $4=(vide)  $#=1
> ```

---

## 📖 Syntaxe et utilisation

### Syntaxe de base

```bash
shift [n]
```

- **Sans argument** : décale d'1 position (équivaut à `shift 1`)
- **Avec n** : décale de n positions

### Exemples simples

```bash
#!/bin/bash

# shift simple
echo "Premier argument : $1"
shift
echo "Nouveau premier : $1"

# shift multiple
echo "Arguments restants : $#"
shift 2
echo "Après shift 2 : $#"
```

### Vérification avant shift

```bash
#!/bin/bash

# Toujours vérifier qu'il reste des arguments
if [ $# -gt 0 ]; then
    shift
else
    echo "Aucun argument à décaler"
fi

# Vérifier avant un shift multiple
if [ $# -ge 3 ]; then
    shift 3
else
    echo "Pas assez d'arguments pour shift 3"
fi
```

> [!warning] Attention aux erreurs
> Si vous tentez `shift n` avec moins de n arguments disponibles, Bash affichera un message d'erreur :
> ```
> bash: shift: shift count out of range
> ```

---

## 🔨 Cas d'usage pratiques

### 1. Extraction du premier argument

```bash
#!/bin/bash
# script_action.sh

action="$1"
shift  # On retire l'action des arguments

case "$action" in
    add)
        echo "Ajout de : $@"
        ;;
    remove)
        echo "Suppression de : $@"
        ;;
    list)
        echo "Liste : $@"
        ;;
    *)
        echo "Action inconnue : $action"
        exit 1
        ;;
esac

# Utilisation :
# ./script_action.sh add fichier1.txt fichier2.txt
# -> Ajout de : fichier1.txt fichier2.txt
```

### 2. Traitement d'options puis d'arguments

```bash
#!/bin/bash

# Variables pour les options
verbose=false
output=""

# Traitement des options
while [ $# -gt 0 ]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift  # Consommer l'option
            ;;
        -o|--output)
            output="$2"
            shift 2  # Consommer l'option ET sa valeur
            ;;
        -*)
            echo "Option inconnue : $1"
            exit 1
            ;;
        *)
            # Premier argument non-option : fin des options
            break
            ;;
    esac
done

# Les arguments restants sont dans $@
echo "Verbose: $verbose"
echo "Output: $output"
echo "Fichiers: $@"

# Utilisation :
# ./script.sh -v -o resultat.txt fichier1 fichier2
```

### 3. Menu interactif

```bash
#!/bin/bash

# Traiter chaque argument comme une commande
while [ $# -gt 0 ]; do
    cmd="$1"
    shift
    
    case "$cmd" in
        start)
            echo "Démarrage du service..."
            ;;
        stop)
            echo "Arrêt du service..."
            ;;
        restart)
            echo "Redémarrage..."
            ;;
        *)
            echo "Commande inconnue : $cmd"
            ;;
    esac
done

# Utilisation :
# ./script.sh start stop restart
```

---

## 🔁 Shift avec boucles

### Boucle while classique

```bash
#!/bin/bash

# Traiter tous les arguments un par un
while [ $# -gt 0 ]; do
    echo "Traitement de : $1"
    # ... faire quelque chose avec $1 ...
    shift  # Passer à l'argument suivant
done
```

> [!tip] Pattern le plus courant
> Cette construction `while [ $# -gt 0 ]` + `shift` est le pattern standard pour traiter tous les arguments de manière séquentielle.

### Boucle avec traitement par paires

```bash
#!/bin/bash

# Traiter des arguments par paires (clé=valeur)
while [ $# -gt 1 ]; do
    key="$1"
    value="$2"
    
    echo "$key = $value"
    
    shift 2  # Avancer de 2 positions
done

# Vérifier s'il reste un argument impair
if [ $# -eq 1 ]; then
    echo "Attention : argument orphelin : $1"
fi

# Utilisation :
# ./script.sh nom Alice age 30 ville Paris
# -> nom = Alice
# -> age = 30
# -> ville = Paris
```

### Boucle avec condition complexe

```bash
#!/bin/bash

count=0
while [ $# -gt 0 ]; do
    count=$((count + 1))
    
    echo "Argument $count : $1"
    
    # Condition spéciale : arrêter si on trouve "--"
    if [ "$1" = "--" ]; then
        shift
        echo "Fin des options, arguments restants : $@"
        break
    fi
    
    shift
done
```

---

## 📦 Traitement d'arguments variables

### Séparer options et arguments

```bash
#!/bin/bash

# Collecte des options
options=()
arguments=()

while [ $# -gt 0 ]; do
    case "$1" in
        -*)
            # C'est une option
            options+=("$1")
            shift
            ;;
        *)
            # C'est un argument
            arguments+=("$1")
            shift
            ;;
    esac
done

echo "Options : ${options[@]}"
echo "Arguments : ${arguments[@]}"

# Utilisation :
# ./script.sh -v -x file1 file2 -d file3
# -> Options : -v -x -d
# -> Arguments : file1 file2 file3
```

### Compteur d'arguments traités

```bash
#!/bin/bash

processed=0
errors=0

while [ $# -gt 0 ]; do
    if process_file "$1"; then
        processed=$((processed + 1))
    else
        errors=$((errors + 1))
    fi
    shift
done

echo "Traités : $processed"
echo "Erreurs : $errors"
```

### Groupement d'arguments

```bash
#!/bin/bash

# Grouper les arguments jusqu'à un séparateur
group=()

while [ $# -gt 0 ]; do
    if [ "$1" = "," ]; then
        # Traiter le groupe
        echo "Groupe : ${group[@]}"
        group=()
        shift
    else
        # Ajouter au groupe
        group+=("$1")
        shift
    fi
done

# Ne pas oublier le dernier groupe
if [ ${#group[@]} -gt 0 ]; then
    echo "Dernier groupe : ${group[@]}"
fi

# Utilisation :
# ./script.sh a b c , d e , f
# -> Groupe : a b c
# -> Groupe : d e
# -> Dernier groupe : f
```

### Traitement avec valeur par défaut

```bash
#!/bin/bash

# Fonction qui nécessite au moins N arguments
process_command() {
    local cmd="$1"
    shift
    
    local min_args=2
    if [ $# -lt $min_args ]; then
        echo "Erreur : $cmd nécessite au moins $min_args arguments"
        return 1
    fi
    
    # Traiter les arguments
    while [ $# -gt 0 ]; do
        echo "  - $1"
        shift
    done
}

# Utilisation
process_command "copier" fichier1.txt fichier2.txt fichier3.txt
```

---

## ⚠️ Pièges courants

### 1. Shift sur des arguments vides

```bash
# ❌ PROBLÈME
while [ $# -gt 0 ]; do
    shift 2  # Si $# = 1, erreur !
done

# ✅ SOLUTION
while [ $# -gt 1 ]; do
    shift 2
done
# Gérer le cas où $# = 1
if [ $# -eq 1 ]; then
    echo "Argument restant : $1"
fi
```

### 2. Oublier de sauvegarder un argument avant shift

```bash
# ❌ PROBLÈME
if [ "$1" = "-o" ]; then
    shift
    output="$1"  # $1 est maintenant le fichier, pas l'option !
fi

# ✅ SOLUTION
if [ "$1" = "-o" ]; then
    shift
    output="$1"  # Maintenant c'est correct
    shift        # Ne pas oublier de décaler à nouveau
fi
```

### 3. Shift dans une sous-fonction

```bash
# ⚠️ ATTENTION
process_args() {
    while [ $# -gt 0 ]; do
        echo "$1"
        shift  # Shift les arguments de la FONCTION, pas du script
    done
}

# Les arguments du script principal ne sont pas affectés
process_args "$@"
echo "Arguments du script : $@"  # Toujours présents !
```

> [!warning] Portée de shift
> `shift` n'affecte que les arguments du contexte actuel (script ou fonction). Il ne modifie pas les arguments du niveau parent.

### 4. Utiliser $@ après plusieurs shifts

```bash
#!/bin/bash

# Extraire les 2 premiers arguments
arg1="$1"
arg2="$2"
shift 2

# ✅ CORRECT : $@ contient tous les arguments restants
echo "Arguments restants : $@"

# ❌ ERREUR : on ne peut plus accéder à arg1 et arg2 via $1 et $2
echo "Premier argument : $1"  # C'est maintenant l'ancien $3 !
```

---

## ✅ Bonnes pratiques

### 1. Toujours vérifier le nombre d'arguments

```bash
#!/bin/bash

# Vérification avant shift
if [ $# -ge 2 ]; then
    cmd="$1"
    arg="$2"
    shift 2
else
    echo "Usage : $0 <commande> <argument> [autres...]"
    exit 1
fi
```

### 2. Documenter les shifts complexes

```bash
#!/bin/bash

# Traitement des options avec leurs valeurs
while [ $# -gt 0 ]; do
    case "$1" in
        -o|--output)
            output="$2"
            shift 2  # Consommer l'option ET sa valeur
            ;;
        -v|--verbose)
            verbose=true
            shift    # Consommer uniquement l'option
            ;;
        *)
            shift    # Ignorer et passer au suivant
            ;;
    esac
done
```

### 3. Utiliser des fonctions pour encapsuler shift

```bash
#!/bin/bash

# Fonction réutilisable pour traiter des arguments
consume_args() {
    local n="$1"
    shift
    
    if [ $# -ge $n ]; then
        shift $n
        return 0
    else
        return 1
    fi
}

# Utilisation claire
if ! consume_args 2 "$@"; then
    echo "Pas assez d'arguments"
    exit 1
fi
```

### 4. Sauvegarder $@ si nécessaire

```bash
#!/bin/bash

# Sauvegarder les arguments originaux
original_args=("$@")

# Traiter avec shift
while [ $# -gt 0 ]; do
    echo "Traitement de $1"
    shift
done

# Les arguments originaux sont toujours disponibles
echo "Arguments initiaux : ${original_args[@]}"
```

---

## 💡 Astuces avancées

### 1. Shift conditionnel

```bash
#!/bin/bash

# Décaler seulement si une condition est remplie
while [ $# -gt 0 ]; do
    if [[ "$1" == *.txt ]]; then
        echo "Fichier texte : $1"
        shift  # Consommer uniquement les .txt
    else
        echo "Ignoré : $1"
        shift  # Passer au suivant sans traiter
    fi
done
```

### 2. Shift avec compteur

```bash
#!/bin/bash

# Compter combien d'arguments ont été traités
count=0

while [ $# -gt 0 ]; do
    echo "$((++count)). $1"
    shift
done

echo "Total : $count arguments traités"
```

### 3. Shift inverse (simulation)

```bash
#!/bin/bash

# Simuler un "unshift" en reconstruisant le tableau
args=("$@")
new_arg="nouveau"

# Ajouter en tête
args=("$new_arg" "${args[@]}")

# Maintenant args[0] = "nouveau", args[1] = ancien $1, etc.
echo "Arguments : ${args[@]}"
```

### 4. Shift avec set

```bash
#!/bin/bash

# Réinitialiser les arguments positionnels
original=("$@")

# Traiter avec shift
while [ $# -gt 0 ]; do
    echo "$1"
    shift
done

# Restaurer les arguments
set -- "${original[@]}"
echo "Restaurés : $@"
```

### 5. Combinaison shift et getopts

```bash
#!/bin/bash

# Traiter les options avec getopts
while getopts "vo:h" opt; do
    case $opt in
        v) verbose=true ;;
        o) output="$OPTARG" ;;
        h) show_help; exit 0 ;;
    esac
done

# Décaler pour atteindre les arguments non-options
shift $((OPTIND - 1))

# Maintenant $@ contient uniquement les arguments
echo "Fichiers à traiter : $@"
```

### 6. Performance avec shift

```bash
#!/bin/bash

# Pour de TRÈS nombreux arguments, utiliser un index est plus rapide
args=("$@")
for ((i=0; i<${#args[@]}; i++)); do
    echo "${args[$i]}"
done

# Plutôt que :
# while [ $# -gt 0 ]; do
#     echo "$1"
#     shift
# done
```

> [!tip] Optimisation
> Pour plus de 1000 arguments, préférer l'indexation directe à `shift` pour des raisons de performance.

---

## 📊 Tableau récapitulatif

| Commande | Effet | Cas d'usage |
|----------|-------|-------------|
| `shift` | Décale de 1 | Traitement séquentiel standard |
| `shift 2` | Décale de 2 | Options avec valeurs (`-o fichier`) |
| `shift n` | Décale de n | Ignorer les n premiers arguments |
| `shift $#` | Vide tous les arguments | Réinitialisation complète |

> [!example] Mémo rapide
> ```bash
> # Pattern le plus courant
> while [ $# -gt 0 ]; do
>     case "$1" in
>         -option) # Traiter; shift ;;
>         *) # Traiter; shift ;;
>     esac
> done
> ```

---

**🎓 Points clés à retenir :**
- `shift` décale les arguments vers la gauche et décrémente `$#`
- Toujours vérifier qu'il reste des arguments avant de shifter
- Utiliser `shift n` pour les options avec valeurs
- Combiner avec des boucles `while` pour un traitement flexible
- Sauvegarder `$@` si vous devez le réutiliser après des shifts