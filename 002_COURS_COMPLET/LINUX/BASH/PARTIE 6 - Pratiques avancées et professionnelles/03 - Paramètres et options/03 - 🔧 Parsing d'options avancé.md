

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

Le parsing d'options avancé permet de créer des scripts Bash avec des interfaces utilisateur sophistiquées, similaires aux commandes système standards. Cette approche va au-delà de `getopts` et offre une flexibilité totale pour gérer :

- Des options longues (`--verbose`, `--output`)
- Des combinaisons d'options courtes et longues
- Des formats variés (`--option=valeur` ou `--option valeur`)
- Des arguments positionnels après les options

> [!info] Pourquoi utiliser le parsing avancé ?
> 
> - **Lisibilité** : Les options longues sont plus explicites (`--help` vs `-h`)
> - **Flexibilité** : Permet d'accepter plusieurs formats d'entrée
> - **Compatibilité** : Correspond aux conventions des outils modernes (git, docker, etc.)
> - **Maintenance** : Facilite l'ajout de nouvelles options sans conflits

---

## 📝 Options longues avec case

### Principe de base

Le parsing manuel avec `case` permet de gérer des options longues que `getopts` ne supporte pas nativement. On itère sur `$@` et on analyse chaque argument.

### Syntaxe de base

```bash
#!/bin/bash

# Initialisation des variables
verbose=false
output_file=""

# Boucle de parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose)
            verbose=true
            shift  # Passe à l'argument suivant
            ;;
        --output)
            output_file="$2"  # La valeur est dans l'argument suivant
            shift 2  # Saute l'option ET sa valeur
            ;;
        --help)
            echo "Usage: $0 [--verbose] [--output FILE]"
            exit 0
            ;;
        *)
            echo "Option inconnue: $1"
            exit 1
            ;;
    esac
done

# Utilisation des options
if $verbose; then
    echo "Mode verbose activé"
fi

if [[ -n "$output_file" ]]; then
    echo "Fichier de sortie: $output_file"
fi
```

> [!example] Exemple d'utilisation
> 
> ```bash
> ./script.sh --verbose --output resultat.txt
> # Mode verbose activé
> # Fichier de sortie: resultat.txt
> ```

### Explication détaillée

|Élément|Description|
|---|---|
|`while [[ $# -gt 0 ]]`|Continue tant qu'il reste des arguments|
|`shift`|Décale les arguments (supprime `$1`, `$2` devient `$1`)|
|`shift 2`|Décale de 2 positions (pour option + valeur)|
|`$1`|Argument actuel analysé|
|`$2`|Argument suivant (valeur potentielle)|
|`*)`|Cas par défaut (option inconnue)|

### Structure avancée avec validation

```bash
#!/bin/bash

verbose=false
output_file=""
log_level="INFO"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose|-v)
            verbose=true
            shift
            ;;
        --output|-o)
            if [[ -z "$2" ]] || [[ "$2" == --* ]]; then
                echo "Erreur: --output nécessite un argument" >&2
                exit 1
            fi
            output_file="$2"
            shift 2
            ;;
        --log-level)
            if [[ "$2" =~ ^(DEBUG|INFO|WARN|ERROR)$ ]]; then
                log_level="$2"
                shift 2
            else
                echo "Erreur: log-level invalide (DEBUG|INFO|WARN|ERROR)" >&2
                exit 1
            fi
            ;;
        --help|-h)
            cat << EOF
Usage: $0 [OPTIONS]

Options:
  -v, --verbose        Active le mode verbose
  -o, --output FILE    Fichier de sortie
  --log-level LEVEL    Niveau de log (DEBUG|INFO|WARN|ERROR)
  -h, --help           Affiche cette aide
EOF
            exit 0
            ;;
        -*)
            echo "Option inconnue: $1" >&2
            echo "Utilisez --help pour voir les options disponibles" >&2
            exit 1
            ;;
        *)
            echo "Argument inattendu: $1" >&2
            exit 1
            ;;
    esac
done
```

> [!warning] Validation importante Toujours vérifier que :
> 
> - Une option avec valeur a bien un argument suivant
> - L'argument suivant n'est pas une autre option (`--*`)
> - Les valeurs attendues respectent le format requis

---

## 🔀 Combinaison d'options courtes et longues

### Supporter les deux formats

Offrir des options courtes ET longues améliore l'expérience utilisateur : les courtes pour la rapidité, les longues pour la clarté.

```bash
#!/bin/bash

force=false
recursive=false
directory=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force)
            force=true
            shift
            ;;
        -r|--recursive)
            recursive=true
            shift
            ;;
        -d|--directory)
            directory="$2"
            shift 2
            ;;
        -fr|-rf)  # Combinaison de flags courts
            force=true
            recursive=true
            shift
            ;;
        --help)
            echo "Usage: $0 [-f|--force] [-r|--recursive] [-d|--directory DIR]"
            exit 0
            ;;
        -*)
            echo "Option inconnue: $1" >&2
            exit 1
            ;;
        *)
            break  # Fin des options, début des arguments positionnels
            ;;
    esac
done

echo "Force: $force"
echo "Recursive: $recursive"
echo "Directory: ${directory:-none}"
```

> [!example] Appels équivalents
> 
> ```bash
> ./script.sh -f -r -d /tmp
> ./script.sh --force --recursive --directory /tmp
> ./script.sh -rf --directory /tmp
> ./script.sh --force -r -d /tmp
> ```

### Parsing sophistiqué des options courtes groupées

```bash
#!/bin/bash

# Fonction pour parser des options courtes groupées (-abc)
parse_short_options() {
    local opts="$1"
    opts="${opts#-}"  # Retire le premier tiret
    
    while [[ -n "$opts" ]]; do
        case "${opts:0:1}" in  # Premier caractère
            v)
                verbose=true
                ;;
            f)
                force=true
                ;;
            q)
                quiet=true
                ;;
            *)
                echo "Option courte inconnue: -${opts:0:1}" >&2
                return 1
                ;;
        esac
        opts="${opts:1}"  # Retire le premier caractère
    done
    return 0
}

verbose=false
force=false
quiet=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose)
            verbose=true
            shift
            ;;
        --force)
            force=true
            shift
            ;;
        --quiet)
            quiet=true
            shift
            ;;
        -[vfq]*)  # Options courtes groupées
            if ! parse_short_options "$1"; then
                exit 1
            fi
            shift
            ;;
        *)
            break
            ;;
    esac
done

echo "Verbose: $verbose, Force: $force, Quiet: $quiet"
```

> [!tip] Astuce Cette approche permet `./script.sh -vfq` au lieu de `./script.sh -v -f -q`

---

## 📦 Arguments restants après options

### Le pattern `--` (double tiret)

La convention POSIX utilise `--` pour marquer la fin des options et le début des arguments positionnels, même s'ils commencent par `-`.

```bash
#!/bin/bash

verbose=false
files=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        --)  # Fin explicite des options
            shift
            break  # Sort de la boucle, tout le reste va dans les arguments
            ;;
        -*)
            echo "Option inconnue: $1" >&2
            exit 1
            ;;
        *)
            break  # Premier argument non-option
            ;;
    esac
done

# Tous les arguments restants sont des fichiers
files=("$@")

echo "Verbose: $verbose"
echo "Fichiers: ${files[@]}"
```

> [!example] Utilisation avec --
> 
> ```bash
> ./script.sh -v -- -fichier-bizarre.txt --autre-fichier
> # Verbose: true
> # Fichiers: -fichier-bizarre.txt --autre-fichier
> 
> ./script.sh -v -fichier-bizarre.txt
> # Erreur: Option inconnue: -fichier-bizarre.txt
> ```

### Collecter les arguments positionnels

```bash
#!/bin/bash

action=""
targets=()
verbose=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Option inconnue: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$action" ]]; then
                action="$1"  # Premier argument = action
            else
                targets+=("$1")  # Autres arguments = cibles
            fi
            shift
            ;;
    esac
done

# Ajouter les arguments après -- aux cibles
targets+=("$@")

if [[ -z "$action" ]]; then
    echo "Erreur: action requise" >&2
    exit 1
fi

echo "Action: $action"
echo "Verbose: $verbose"
echo "Cibles: ${targets[@]}"
```

> [!example] Exemples d'usage
> 
> ```bash
> ./script.sh deploy -v app1 app2 app3
> # Action: deploy
> # Verbose: true
> # Cibles: app1 app2 app3
> 
> ./script.sh backup --verbose -- -special-dir /path/with/spaces
> # Action: backup
> # Verbose: true
> # Cibles: -special-dir /path/with/spaces
> ```

---

## ⚙️ Format --option=valeur

### Parsing du format avec égal

Ce format (`--output=file.txt`) est populaire et plus compact que `--output file.txt`.

```bash
#!/bin/bash

output=""
timeout=30
config=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output=*)
            output="${1#*=}"  # Extrait tout après le =
            shift
            ;;
        --timeout=*)
            timeout="${1#*=}"
            if ! [[ "$timeout" =~ ^[0-9]+$ ]]; then
                echo "Erreur: timeout doit être un nombre" >&2
                exit 1
            fi
            shift
            ;;
        --config=*)
            config="${1#*=}"
            if [[ ! -f "$config" ]]; then
                echo "Erreur: fichier de config introuvable: $config" >&2
                exit 1
            fi
            shift
            ;;
        --help)
            cat << EOF
Usage: $0 [OPTIONS]

Options:
  --output=FILE      Fichier de sortie
  --timeout=SECONDS  Timeout en secondes (défaut: 30)
  --config=FILE      Fichier de configuration
EOF
            exit 0
            ;;
        *)
            echo "Option inconnue: $1" >&2
            exit 1
            ;;
    esac
done

echo "Output: ${output:-stdout}"
echo "Timeout: $timeout"
echo "Config: ${config:-none}"
```

> [!info] Extraction de valeur `${1#*=}` utilise la substitution de paramètre :
> 
> - `#` : supprime le préfixe le plus court
> - `*=` : motif = tout jusqu'au premier `=`
> - Résultat : tout après le `=`

### Support des deux formats (avec et sans égal)

```bash
#!/bin/bash

# Fonction pour extraire la valeur d'une option
get_option_value() {
    local option="$1"
    local next_arg="$2"
    
    if [[ "$option" == *=* ]]; then
        # Format --option=valeur
        echo "${option#*=}"
        return 0
    else
        # Format --option valeur
        if [[ -z "$next_arg" ]] || [[ "$next_arg" == --* ]]; then
            return 1  # Pas de valeur
        fi
        echo "$next_arg"
        return 2  # Indique qu'on doit shift 2
    fi
}

output=""
timeout=30

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output|--output=*)
            value=$(get_option_value "$1" "$2")
            ret=$?
            if [[ $ret -eq 1 ]]; then
                echo "Erreur: --output nécessite une valeur" >&2
                exit 1
            fi
            output="$value"
            [[ $ret -eq 2 ]] && shift 2 || shift
            ;;
        --timeout|--timeout=*)
            value=$(get_option_value "$1" "$2")
            ret=$?
            if [[ $ret -eq 1 ]]; then
                echo "Erreur: --timeout nécessite une valeur" >&2
                exit 1
            fi
            timeout="$value"
            [[ $ret -eq 2 ]] && shift 2 || shift
            ;;
        *)
            echo "Option inconnue: $1" >&2
            exit 1
            ;;
    esac
done

echo "Output: $output"
echo "Timeout: $timeout"
```

> [!example] Flexibilité maximale
> 
> ```bash
> ./script.sh --output=file.txt --timeout 60
> ./script.sh --output file.txt --timeout=60
> ./script.sh --output=file.txt --timeout=60
> # Tous ces appels sont valides !
> ```

### Pattern matching avancé pour --option=valeur

```bash
#!/bin/bash

database_url=""
log_level="INFO"
max_connections=100

while [[ $# -gt 0 ]]; do
    key="${1%%=*}"  # Tout avant le =
    value="${1#*=}"  # Tout après le =
    
    # Si pas de =, alors key et value sont identiques
    if [[ "$key" == "$value" ]]; then
        # Format --option valeur
        case "$1" in
            --database-url|--log-level|--max-connections)
                if [[ -z "$2" ]]; then
                    echo "Erreur: $1 nécessite une valeur" >&2
                    exit 1
                fi
                key="$1"
                value="$2"
                shift 2
                ;;
            *)
                echo "Option inconnue: $1" >&2
                exit 1
                ;;
        esac
    else
        # Format --option=valeur
        shift
    fi
    
    # Traitement unifié
    case "$key" in
        --database-url)
            database_url="$value"
            ;;
        --log-level)
            if [[ ! "$value" =~ ^(DEBUG|INFO|WARN|ERROR)$ ]]; then
                echo "Erreur: log-level invalide" >&2
                exit 1
            fi
            log_level="$value"
            ;;
        --max-connections)
            if [[ ! "$value" =~ ^[0-9]+$ ]]; then
                echo "Erreur: max-connections doit être un nombre" >&2
                exit 1
            fi
            max_connections="$value"
            ;;
    esac
done

echo "Database: $database_url"
echo "Log level: $log_level"
echo "Max connections: $max_connections"
```

---

## ⚠️ Pièges courants

### 1. Oublier le shift approprié

```bash
# ❌ MAUVAIS
case "$1" in
    --output)
        output="$2"
        shift  # ❌ On reste sur la valeur !
        ;;
esac

# ✅ BON
case "$1" in
    --output)
        output="$2"
        shift 2  # ✅ Passe l'option ET sa valeur
        ;;
esac
```

### 2. Ne pas valider la présence de valeur

```bash
# ❌ MAUVAIS
case "$1" in
    --output)
        output="$2"  # ❌ $2 peut être vide ou une autre option
        shift 2
        ;;
esac

# ✅ BON
case "$1" in
    --output)
        if [[ -z "$2" ]] || [[ "$2" == --* ]]; then
            echo "Erreur: --output nécessite une valeur" >&2
            exit 1
        fi
        output="$2"
        shift 2
        ;;
esac
```

### 3. Mauvaise gestion de --option=valeur vide

```bash
# ❌ MAUVAIS
case "$1" in
    --output=*)
        output="${1#*=}"  # ❌ --output= donne une chaîne vide !
        ;;
esac

# ✅ BON
case "$1" in
    --output=*)
        output="${1#*=}"
        if [[ -z "$output" ]]; then
            echo "Erreur: --output ne peut pas être vide" >&2
            exit 1
        fi
        ;;
esac
```

### 4. Ignorer les arguments après --

```bash
# ❌ MAUVAIS
while [[ $# -gt 0 ]]; do
    case "$1" in
        # ... options ...
        *)
            echo "Argument inconnu: $1" >&2
            exit 1  # ❌ Rejette tout argument positionnel !
            ;;
    esac
done

# ✅ BON
while [[ $# -gt 0 ]]; do
    case "$1" in
        # ... options ...
        --)
            shift
            break  # ✅ Sort pour traiter les arguments restants
            ;;
        *)
            break  # ✅ Ou simplement break pour débuter les positionnels
            ;;
    esac
done
```

### 5. Collision d'options courtes groupées

```bash
# ❌ MAUVAIS
case "$1" in
    -vf)
        verbose=true
        force=true
        shift
        ;;
    -fv)  # ❌ Il faut gérer toutes les permutations !
        verbose=true
        force=true
        shift
        ;;
esac

# ✅ BON - Utiliser une fonction de parsing
parse_short_options() {
    local opts="${1#-}"
    while [[ -n "$opts" ]]; do
        case "${opts:0:1}" in
            v) verbose=true ;;
            f) force=true ;;
        esac
        opts="${opts:1}"
    done
}
```

> [!warning] Attention à shift Un `shift` trop précoce ou manquant peut créer des bugs difficiles à diagnostiquer où les options sont mal interprétées.

---

## ✅ Bonnes pratiques

### 1. Structure modulaire avec fonctions

```bash
#!/bin/bash

# Variables globales
declare verbose=false
declare output_file=""
declare -a files=()

# Fonction d'aide
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [FILES...]

Options:
  -v, --verbose       Mode verbose
  -o, --output FILE   Fichier de sortie
  -h, --help          Affiche cette aide
EOF
}

# Fonction de validation
validate_options() {
    if [[ -n "$output_file" ]] && [[ ! -d "$(dirname "$output_file")" ]]; then
        echo "Erreur: répertoire de sortie inexistant" >&2
        return 1
    fi
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "Erreur: au moins un fichier requis" >&2
        return 1
    fi
    
    return 0
}

# Fonction de parsing
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                echo "Option inconnue: $1" >&2
                return 1
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Arguments restants
    files=("$@")
    return 0
}

# Main
main() {
    if ! parse_arguments "$@"; then
        show_help
        exit 1
    fi
    
    if ! validate_options; then
        exit 1
    fi
    
    # Logique du script...
    $verbose && echo "Traitement de ${#files[@]} fichier(s)..."
}

main "$@"
```

### 2. Messages d'erreur descriptifs

```bash
# ✅ BON - Messages clairs
if [[ -z "$output_file" ]]; then
    cat >&2 << EOF
Erreur: L'option --output est requise.

Exemples:
  $0 --output résultat.txt fichier1.txt fichier2.txt
  $0 -o résultat.txt --verbose -- -fichier-spécial.txt

Utilisez --help pour plus d'informations.
EOF
    exit 1
fi
```

### 3. Support de configuration par fichier

```bash
#!/bin/bash

config_file=""
verbose=false

# Parser les options pour trouver --config en premier
for arg in "$@"; do
    if [[ "$arg" == --config=* ]]; then
        config_file="${arg#*=}"
        break
    fi
done

# Charger le fichier de config si présent
if [[ -n "$config_file" ]]; then
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    else
        echo "Erreur: fichier de config introuvable: $config_file" >&2
        exit 1
    fi
fi

# Parser normalement (les options en ligne de commande écrasent le config)
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose)
            verbose=true
            shift
            ;;
        --config=*)
            shift  # Déjà traité
            ;;
        *)
            shift
            ;;
    esac
done
```

### 4. Documentation intégrée

```bash
#!/bin/bash

show_help() {
    cat << 'EOF'
Usage: deploy.sh [OPTIONS] <action> [targets...]

Déploie des applications vers différents environnements.

Actions:
  deploy        Déploie les applications
  rollback      Revient à la version précédente
  status        Affiche le statut des applications

Options:
  -v, --verbose              Mode verbose
  -e, --env ENVIRONMENT      Environnement (dev|staging|prod)
  -f, --force                Force le déploiement
  --timeout=SECONDS          Timeout (défaut: 300)
  --config=FILE              Fichier de configuration
  -h, --help                 Affiche cette aide

Exemples:
  # Déploiement simple
  deploy.sh deploy app1 app2

  # Déploiement en production avec timeout
  deploy.sh -e prod --timeout=600 deploy api frontend

  # Rollback avec confirmation désactivée
  deploy.sh --force rollback api

  # Fichiers avec noms spéciaux
  deploy.sh deploy -- -special-app --another-app
EOF
}
```

> [!tip] Astuce finale Utilisez `set -o errexit` et `set -o nounset` en début de script pour détecter les erreurs de parsing plus rapidement pendant le développement.

### 5. Template réutilisable

```bash
#!/bin/bash

set -o errexit   # Arrête si une commande échoue
set -o nounset   # Arrête si variable non définie
set -o pipefail  # Arrête si une commande dans un pipe échoue

# ============================================================================
# VARIABLES GLOBALES
# ============================================================================

declare SCRIPT_NAME
SCRIPT_NAME="$(basename "$0")"
declare -a POSITIONAL_ARGS=()

# Options par défaut
declare VERBOSE=false
declare DRY_RUN=false
declare OUTPUT_FILE=""

# ============================================================================
# FONCTIONS
# ============================================================================

show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] [ARGUMENTS...]

Description de votre script.

Options:
  -v, --verbose       Mode verbose
  -n, --dry-run       Simule sans exécuter
  -o, --output FILE   Fichier de sortie
  -h, --help          Affiche cette aide

Exemples:
  $SCRIPT_NAME --verbose fichier.txt
  $SCRIPT_NAME -n -o resultat.txt -- arg1 arg2
EOF
}

log() {
    $VERBOSE && echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    echo "Erreur: $*" >&2
    exit 1
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -o|--output)
                [[ -z "${2:-}" ]] && error "--output nécessite un argument"
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --)
                shift
                POSITIONAL_ARGS+=("$@")
                break
                ;;
            -*)
                error "Option inconnue: $1"
                ;;
            *)
                POSITIONAL_ARGS+=("$1")
                shift
                ;;
        esac
    done
}

validate_arguments() {
    if [[ ${#POSITIONAL_ARGS[@]} -eq 0 ]]; then
        error "Au moins un argument requis"
    fi
    
    # Autres validations...
    return 0
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    parse_arguments "$@"
    validate_arguments
    
    log "Démarrage avec ${#POSITIONAL_ARGS[@]} argument(s)"
    $DRY_RUN && log "Mode DRY-RUN activé"
    
    # Votre logique ici...
    
    log "Terminé avec succès"
}

main "$@"
```

---

> [!tip] 💡 Astuces finales
> 
> - **Testez avec shellcheck** : `shellcheck votre-script.sh` détecte les erreurs courantes
> - **Utilisez des variables en majuscules** pour les options globales (convention)
> - **Loggez dans stderr** (`>&2`) pour séparer les logs de la sortie réelle
> - **Documentez le format attendu** dans `--help` avec des exemples concrets
> - **Considérez `getopt` (GNU)** pour des besoins très avancés, mais attention à la portabilité