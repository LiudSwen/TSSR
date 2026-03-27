

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

Les paramètres de fonction en Bash permettent de passer des informations à vos fonctions pour les rendre réutilisables et flexibles. Contrairement à d'autres langages, Bash n'utilise pas de déclaration formelle des paramètres dans la signature de la fonction. À la place, il utilise des variables spéciales pour accéder aux arguments passés.

> [!info] Pourquoi c'est important
> 
> - Rendre vos fonctions réutilisables avec différentes valeurs
> - Créer des scripts modulaires et maintenables
> - Valider les entrées utilisateur
> - Construire des interfaces en ligne de commande robustes

---

## Les arguments positionnels

### `$1`, `$2`, `$3`, etc.

Les arguments passés à une fonction sont accessibles via des variables numérotées. `$1` représente le premier argument, `$2` le deuxième, et ainsi de suite.

> [!example] Syntaxe de base
> 
> ```bash
> ma_fonction() {
>     echo "Premier argument : $1"
>     echo "Deuxième argument : $2"
>     echo "Troisième argument : $3"
> }
> 
> # Appel de la fonction
> ma_fonction "Bonjour" "le" "monde"
> ```
> 
> **Sortie :**
> 
> ```
> Premier argument : Bonjour
> Deuxième argument : le
> Troisième argument : monde
> ```

### Caractéristiques importantes

|Aspect|Description|
|---|---|
|**Portée**|Les paramètres sont locaux à la fonction|
|**Numérotation**|Commence à `$1` (pas `$0` qui est le nom du script)|
|**Limite**|Au-delà de `$9`, utiliser `${10}`, `${11}`, etc.|
|**Type**|Toujours des chaînes de caractères|

> [!example] Utilisation avec accolades pour les nombres > 9
> 
> ```bash
> fonction_nombreux_args() {
>     echo "Argument 1 : $1"
>     echo "Argument 10 : ${10}"
>     echo "Argument 15 : ${15}"
> }
> 
> fonction_nombreux_args a b c d e f g h i j k l m n o
> ```

### Cas d'usage pratique

```bash
creer_utilisateur() {
    local nom=$1
    local prenom=$2
    local email=$3
    
    echo "Création de l'utilisateur :"
    echo "  Nom : $nom"
    echo "  Prénom : $prenom"
    echo "  Email : $email"
    
    # Suite du traitement...
}

creer_utilisateur "Dupont" "Jean" "jean.dupont@example.com"
```

> [!tip] Astuce : Utiliser des variables locales Assignez les paramètres à des variables locales avec des noms explicites pour améliorer la lisibilité de votre code.

---

## Le nombre d'arguments : `$#`

La variable `$#` contient le nombre total d'arguments passés à la fonction.

> [!example] Utilisation de base
> 
> ```bash
> afficher_nombre_args() {
>     echo "Vous avez passé $# argument(s)"
> }
> 
> afficher_nombre_args un deux trois
> # Sortie : Vous avez passé 3 argument(s)
> ```

### Applications pratiques

#### 1. Validation du nombre d'arguments

```bash
diviser() {
    if [ $# -ne 2 ]; then
        echo "Erreur : cette fonction nécessite exactement 2 arguments"
        echo "Usage : diviser <dividende> <diviseur>"
        return 1
    fi
    
    local dividende=$1
    local diviseur=$2
    
    if [ "$diviseur" -eq 0 ]; then
        echo "Erreur : division par zéro"
        return 1
    fi
    
    echo $(( dividende / diviseur ))
}
```

#### 2. Fonctions à arguments variables

```bash
calculer_moyenne() {
    if [ $# -eq 0 ]; then
        echo "Erreur : aucun nombre fourni"
        return 1
    fi
    
    local somme=0
    local nombre=$#
    
    for valeur in "$@"; do
        somme=$((somme + valeur))
    done
    
    echo "scale=2; $somme / $nombre" | bc
}

calculer_moyenne 10 20 30 40 50
# Sortie : 30.00
```

> [!warning] Attention `$#` compte uniquement les arguments explicitement passés. Les arguments vides (`""`) sont comptés, mais l'absence totale d'argument donne 0.

---

## Tous les arguments : `$@` et `$*`

Ces deux variables spéciales permettent d'accéder à tous les arguments en une fois, mais avec des différences importantes.

### Tableau comparatif

|Variable|Entre guillemets|Sans guillemets|Usage recommandé|
|---|---|---|---|
|`$@`|Arguments séparés : `"$1" "$2" "$3"`|Expansion en mots : `$1 $2 $3`|**Presque toujours préféré**|
|`$*`|Un seul mot : `"$1 $2 $3"`|Expansion en mots : `$1 $2 $3`|Rarement utilisé|

### `$@` - La solution recommandée

> [!example] Utilisation de `"$@"`
> 
> ```bash
> afficher_arguments() {
>     echo "Nombre d'arguments : $#"
>     echo "Liste des arguments :"
>     
>     local compteur=1
>     for arg in "$@"; do
>         echo "  $compteur: $arg"
>         ((compteur++))
>     done
> }
> 
> afficher_arguments "un" "deux trois" "quatre"
> ```
> 
> **Sortie :**
> 
> ```
> Nombre d'arguments : 3
> Liste des arguments :
>   1: un
>   2: deux trois
>   3: quatre
> ```

### `$*` - Comportement particulier

> [!example] Différence entre `"$@"` et `"$*"`
> 
> ```bash
> tester_expansion() {
>     echo "=== Avec \"\$@\" ==="
>     for arg in "$@"; do
>         echo "[$arg]"
>     done
>     
>     echo ""
>     echo "=== Avec \"\$*\" ==="
>     for arg in "$*"; do
>         echo "[$arg]"
>     done
> }
> 
> tester_expansion "arg1" "arg2" "arg3"
> ```
> 
> **Sortie :**
> 
> ```
> === Avec "$@" ===
> [arg1]
> [arg2]
> [arg3]
> 
> === Avec "$*" ===
> [arg1 arg2 arg3]
> ```

### Cas d'usage : Passer des arguments à une autre commande

```bash
# Fonction wrapper pour grep avec options personnalisées
mon_grep() {
    # Ajoute des options par défaut et passe tous les arguments
    grep --color=auto -n "$@"
}

# Utilisation
mon_grep "pattern" fichier.txt
mon_grep -i "pattern" fichier1.txt fichier2.txt
```

### Transfert d'arguments vers une autre fonction

```bash
logger() {
    local niveau=$1
    shift  # Retire le premier argument
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$niveau] $*"
}

info() {
    logger "INFO" "$@"
}

erreur() {
    logger "ERREUR" "$@"
}

info "Démarrage de l'application"
erreur "Connexion échouée" "Impossible de joindre le serveur"
```

> [!tip] Astuce : shift avec `$@` Utilisez `shift` pour "consommer" des arguments, ce qui déplace `$2` vers `$1`, `$3` vers `$2`, etc. Très utile pour traiter les options avant les arguments.

---

## Vérification du nombre d'arguments

La validation des arguments est cruciale pour créer des fonctions robustes.

### Stratégies de validation

#### 1. Nombre exact d'arguments

```bash
concatener() {
    if [ $# -ne 2 ]; then
        echo "Erreur : exactement 2 arguments requis" >&2
        echo "Usage : concatener <chaine1> <chaine2>" >&2
        return 1
    fi
    
    echo "${1}${2}"
}
```

#### 2. Nombre minimum d'arguments

```bash
trouver_maximum() {
    if [ $# -lt 1 ]; then
        echo "Erreur : au moins 1 nombre requis" >&2
        return 1
    fi
    
    local max=$1
    shift
    
    for nombre in "$@"; do
        if [ "$nombre" -gt "$max" ]; then
            max=$nombre
        fi
    done
    
    echo "$max"
}

trouver_maximum 5 12 3 8 15 2
# Sortie : 15
```

#### 3. Nombre dans une plage

```bash
formater_date() {
    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "Erreur : 1 à 3 arguments requis" >&2
        echo "Usage : formater_date <jour> [mois] [annee]" >&2
        return 1
    fi
    
    local jour=$1
    local mois=${2:-$(date +%m)}
    local annee=${3:-$(date +%Y)}
    
    printf "%02d/%02d/%04d\n" "$jour" "$mois" "$annee"
}
```

### Messages d'erreur efficaces

> [!info] Bonnes pratiques pour les messages d'erreur
> 
> - Redirigez vers stderr avec `>&2`
> - Indiquez le problème clairement
> - Fournissez un exemple d'utilisation correcte
> - Retournez un code d'erreur non nul

```bash
copier_fichier() {
    if [ $# -ne 2 ]; then
        cat >&2 << EOF
Erreur : nombre d'arguments incorrect (reçu: $#, attendu: 2)

Usage : copier_fichier <source> <destination>

Exemples :
    copier_fichier fichier.txt sauvegarde.txt
    copier_fichier /chemin/source.log /backup/
EOF
        return 1
    fi
    
    # Suite de la fonction...
}
```

---

## Arguments par défaut

Bash ne supporte pas nativement les arguments par défaut comme certains langages, mais vous pouvez les implémenter facilement.

### Techniques d'implémentation

#### 1. Expansion de paramètre avec valeur par défaut

```bash
# Syntaxe : ${variable:-valeur_par_defaut}
saluer() {
    local nom=${1:-"Utilisateur"}
    local salutation=${2:-"Bonjour"}
    
    echo "$salutation, $nom !"
}

saluer                        # Bonjour, Utilisateur !
saluer "Marie"                # Bonjour, Marie !
saluer "Paul" "Salut"         # Salut, Paul !
```

#### 2. Vérification conditionnelle

```bash
configurer_serveur() {
    local hote=$1
    local port=$2
    local timeout=$3
    
    # Valeurs par défaut
    [ -z "$hote" ] && hote="localhost"
    [ -z "$port" ] && port=8080
    [ -z "$timeout" ] && timeout=30
    
    echo "Configuration :"
    echo "  Hôte : $hote"
    echo "  Port : $port"
    echo "  Timeout : ${timeout}s"
}
```

#### 3. Pattern avec assignation conditionnelle

```bash
creer_backup() {
    local source=$1
    local destination=${2:-"./backup"}
    local compression=${3:-"gz"}
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    echo "Backup de $source vers $destination"
    echo "Format : .$compression"
    echo "Timestamp : $timestamp"
}
```

### Tableau des syntaxes d'expansion

|Syntaxe|Description|Exemple|
|---|---|---|
|`${var:-default}`|Utilise `default` si `var` est vide ou non définie|`${1:-"valeur"}`|
|`${var:=default}`|Assigne `default` à `var` si vide|`${config:=/etc/default}`|
|`${var:?erreur}`|Affiche erreur et quitte si `var` est vide|`${1:?Argument requis}`|
|`${var:+autre}`|Utilise `autre` si `var` est définie|`${DEBUG:+--verbose}`|

> [!example] Combinaison de techniques
> 
> ```bash
> deployer_application() {
>     local environnement=${1:?Environnement requis (dev/staging/prod)}
>     local version=${2:-"latest"}
>     local replicas=${3:-1}
>     local memoire=${4:-"512Mi"}
>     
>     # Validation de l'environnement
>     case "$environnement" in
>         dev|staging|prod)
>             echo "Déploiement sur $environnement"
>             ;;
>         *)
>             echo "Erreur : environnement invalide '$environnement'" >&2
>             return 1
>             ;;
>     esac
>     
>     echo "Version : $version"
>     echo "Replicas : $replicas"
>     echo "Mémoire : $memoire"
> }
> ```

---

## Pièges courants

### 1. Oubli des guillemets autour de `$@`

> [!warning] Problème
> 
> ```bash
> # MAUVAIS - Les arguments avec espaces sont séparés
> mauvaise_fonction() {
>     for arg in $@; do  # Sans guillemets !
>         echo "[$arg]"
>     done
> }
> 
> mauvaise_fonction "un deux" "trois"
> # Sortie inattendue :
> # [un]
> # [deux]
> # [trois]
> ```

> [!tip] Solution
> 
> ```bash
> # BON - Préserve les arguments avec espaces
> bonne_fonction() {
>     for arg in "$@"; do  # Avec guillemets !
>         echo "[$arg]"
>     done
> }
> 
> bonne_fonction "un deux" "trois"
> # Sortie attendue :
> # [un deux]
> # [trois]
> ```

### 2. Confusion entre paramètres de script et de fonction

```bash
#!/bin/bash
# Script : mon_script.sh

ma_fonction() {
    # Dans la fonction, $1 réfère au premier argument de la fonction
    # PAS au premier argument du script !
    echo "Argument de la fonction : $1"
}

# Ici, $1 réfère au premier argument du script
echo "Argument du script : $1"

ma_fonction "argument_fonction"

# Exécution : ./mon_script.sh argument_script
# Sortie :
# Argument du script : argument_script
# Argument de la fonction : argument_fonction
```

### 3. Ne pas sauvegarder les arguments avant `shift`

> [!warning] Problème courant
> 
> ```bash
> traiter_options() {
>     # MAUVAIS - On perd l'accès aux arguments originaux après shift
>     while [ $# -gt 0 ]; do
>         case "$1" in
>             --verbose)
>                 verbose=true
>                 shift
>                 ;;
>             *)
>                 # Oops, on ne peut plus accéder à tous les arguments !
>                 break
>                 ;;
>         esac
>     done
> }
> ```

> [!tip] Meilleure approche
> 
> ```bash
> traiter_options() {
>     local verbose=false
>     local fichiers=()
>     
>     while [ $# -gt 0 ]; do
>         case "$1" in
>             --verbose)
>                 verbose=true
>                 shift
>                 ;;
>             --)
>                 shift
>                 fichiers+=("$@")
>                 break
>                 ;;
>             *)
>                 fichiers+=("$1")
>                 shift
>                 ;;
>         esac
>     done
>     
>     echo "Verbose : $verbose"
>     echo "Fichiers : ${fichiers[@]}"
> }
> ```

### 4. Tests numériques vs tests de chaînes

```bash
# MAUVAIS - Comparaison de chaînes pour des nombres
verifier_age() {
    if [ "$1" > "18" ]; then  # Comparaison lexicographique !
        echo "Majeur"
    fi
}

verifier_age 7  # Affiche "Majeur" car "7" > "18" en lexicographique !

# BON - Comparaison numérique
verifier_age() {
    if [ "$1" -gt 18 ]; then  # Comparaison numérique
        echo "Majeur"
    else
        echo "Mineur"
    fi
}
```

### 5. Arguments vides vs arguments manquants

```bash
tester_argument() {
    # Ces trois cas sont différents :
    
    # 1. Argument présent mais vide
    if [ -n "$1" ]; then
        echo "Argument non vide : '$1'"
    else
        echo "Argument vide ou manquant"
    fi
    
    # 2. Argument présent (même vide)
    if [ $# -gt 0 ]; then
        echo "Au moins un argument passé"
    fi
}

tester_argument ""       # Argument passé mais vide
tester_argument          # Aucun argument
tester_argument "texte"  # Argument non vide
```

---

## Bonnes pratiques

### 1. Documentation de fonction

```bash
# Description : Copie un fichier avec vérification et backup
# Usage : copier_secure <source> <destination> [options]
# Arguments :
#   $1 - Fichier source (requis)
#   $2 - Fichier destination (requis)
#   $3 - Options : --backup, --force (optionnel)
# Retour :
#   0 - Succès
#   1 - Erreur d'argument
#   2 - Erreur de copie
copier_secure() {
    # Implémentation...
}
```

### 2. Validation systématique des entrées

```bash
calculer() {
    # Vérifier le nombre d'arguments
    [ $# -eq 2 ] || {
        echo "Erreur : 2 arguments requis" >&2
        return 1
    }
    
    # Vérifier que ce sont des nombres
    [[ "$1" =~ ^[0-9]+$ ]] || {
        echo "Erreur : '$1' n'est pas un nombre" >&2
        return 1
    }
    
    [[ "$2" =~ ^[0-9]+$ ]] || {
        echo "Erreur : '$2' n'est pas un nombre" >&2
        return 1
    }
    
    # Traitement...
}
```

### 3. Nommage explicite avec variables locales

```bash
# MOINS LISIBLE
traiter() {
    echo "Traitement de $1 avec $2"
    cp "$1" "$2"
}

# PLUS LISIBLE
traiter() {
    local fichier_source=$1
    local repertoire_destination=$2
    
    echo "Traitement de $fichier_source avec $repertoire_destination"
    cp "$fichier_source" "$repertoire_destination"
}
```

### 4. Utiliser `readonly` pour les paramètres critiques

```bash
initialiser_config() {
    readonly CONFIG_FILE=$1
    readonly ENV=${2:-"production"}
    
    # Ces variables ne peuvent plus être modifiées
    echo "Configuration : $CONFIG_FILE"
    echo "Environnement : $ENV"
}
```

### 5. Pattern d'options et arguments

```bash
ma_commande() {
    local verbose=false
    local dry_run=false
    local fichiers=()
    
    # Parser les options
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            --)
                shift
                fichiers+=("$@")
                break
                ;;
            -*)
                echo "Option inconnue : $1" >&2
                return 1
                ;;
            *)
                fichiers+=("$1")
                shift
                ;;
        esac
    done
    
    # Utiliser les options et arguments
    $verbose && echo "Mode verbeux activé"
    $dry_run && echo "Mode simulation"
    
    for fichier in "${fichiers[@]}"; do
        echo "Traitement de : $fichier"
    done
}
```

### 6. Gestion des erreurs avec codes de retour

```bash
valider_email() {
    local email=$1
    
    [ -z "$email" ] && {
        echo "Erreur : email vide" >&2
        return 1
    }
    
    [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] || {
        echo "Erreur : format d'email invalide" >&2
        return 2
    }
    
    echo "Email valide : $email"
    return 0
}

# Utilisation avec gestion d'erreur
if valider_email "$1"; then
    echo "Validation réussie"
else
    code=$?
    echo "Échec de validation (code: $code)"
fi
```

### 7. Template de fonction complète

```bash
ma_fonction_complete() {
    # Documentation
    local description="Fait quelque chose d'utile"
    local usage="ma_fonction_complete <arg1> <arg2> [options]"
    
    # Validation des arguments
    if [ $# -lt 2 ]; then
        echo "Erreur : arguments insuffisants" >&2
        echo "Usage : $usage" >&2
        return 1
    fi
    
    # Déclaration des variables locales avec valeurs par défaut
    local argument1=$1
    local argument2=$2
    local option1=${3:-"defaut"}
    
    # Validation des valeurs
    [ -n "$argument1" ] || {
        echo "Erreur : argument1 vide" >&2
        return 1
    }
    
    # Logique métier
    echo "Traitement de $argument1 et $argument2 avec $option1"
    
    # Code de retour explicite
    return 0
}
```

> [!tip] Astuce finale Créez vos propres templates de fonctions réutilisables et adaptez-les selon vos besoins. La cohérence dans votre code facilite la maintenance et la collaboration.

---