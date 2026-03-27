

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

La validation des entrées est une étape **cruciale** dans la robustesse d'un script Bash. Elle permet de :

- **Prévenir les erreurs** avant qu'elles ne se produisent
- **Sécuriser** le script contre des données malveillantes
- **Améliorer l'expérience utilisateur** avec des messages clairs
- **Faciliter le débogage** en détectant les problèmes tôt

> [!warning] Principe de base **Ne jamais faire confiance aux entrées utilisateur.** Toujours valider, toujours vérifier.

---

## ✅ Vérification d'arguments

### Vérifier le nombre d'arguments

La première validation consiste à s'assurer que le script reçoit le bon nombre d'arguments.

```bash
#!/bin/bash

# Vérifier qu'on a exactement 2 arguments
if [ $# -ne 2 ]; then
    echo "Erreur: Ce script nécessite exactement 2 arguments" >&2
    echo "Usage: $0 <fichier_source> <fichier_destination>" >&2
    exit 1
fi

source="$1"
destination="$2"
```

> [!info] Variable `$#` `$#` contient le nombre d'arguments passés au script (sans compter `$0` qui est le nom du script).

### Vérifier un nombre minimum/maximum d'arguments

```bash
#!/bin/bash

# Au moins 1 argument
if [ $# -lt 1 ]; then
    echo "Erreur: Au moins un argument requis" >&2
    exit 1
fi

# Maximum 3 arguments
if [ $# -gt 3 ]; then
    echo "Erreur: Trop d'arguments (maximum 3)" >&2
    exit 1
fi

# Ou combiné avec une plage
if [ $# -lt 1 ] || [ $# -gt 3 ]; then
    echo "Erreur: Le script accepte entre 1 et 3 arguments" >&2
    exit 1
fi
```

### Vérifier la présence d'arguments optionnels

```bash
#!/bin/bash

fichier="$1"

# Vérifier si un deuxième argument (optionnel) existe
if [ -n "$2" ]; then
    mode="$2"
else
    mode="lecture"  # Valeur par défaut
fi

echo "Traitement de $fichier en mode $mode"
```

> [!tip] Test `-n` vs `-z`
> 
> - `-n "$var"` : vrai si la variable est non-vide
> - `-z "$var"` : vrai si la variable est vide

---

## 🔍 Tests de validité

### Valider les types de données

#### Vérifier qu'un argument est un nombre

```bash
#!/bin/bash

nombre="$1"

# Méthode 1: Avec une regex
if ! [[ "$nombre" =~ ^[0-9]+$ ]]; then
    echo "Erreur: '$nombre' n'est pas un nombre entier positif" >&2
    exit 1
fi

# Méthode 2: Avec un test arithmétique
if ! [ "$nombre" -eq "$nombre" ] 2>/dev/null; then
    echo "Erreur: '$nombre' n'est pas un nombre" >&2
    exit 1
fi

# Méthode 3: Avec case (pour des motifs simples)
case "$nombre" in
    ''|*[!0-9]*)
        echo "Erreur: '$nombre' n'est pas un nombre" >&2
        exit 1
        ;;
esac
```

> [!example] Exemples de regex pour nombres
> 
> ```bash
> ^[0-9]+$           # Entier positif
> ^-?[0-9]+$         # Entier (positif ou négatif)
> ^[0-9]+\.[0-9]+$   # Décimal positif
> ^-?[0-9]*\.?[0-9]+$ # Décimal (positif ou négatif)
> ```

#### Vérifier qu'un argument est une email

```bash
#!/bin/bash

email="$1"

# Regex simple pour email (pas exhaustive mais pratique)
if ! [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Erreur: '$email' n'est pas une adresse email valide" >&2
    exit 1
fi
```

#### Vérifier qu'un argument est dans une liste de valeurs

```bash
#!/bin/bash

mode="$1"

# Vérifier que le mode est valide
case "$mode" in
    debug|info|warning|error)
        echo "Mode '$mode' accepté"
        ;;
    *)
        echo "Erreur: Mode invalide '$mode'" >&2
        echo "Modes acceptés: debug, info, warning, error" >&2
        exit 1
        ;;
esac
```

### Valider les fichiers et répertoires

#### Vérifier l'existence et les permissions

```bash
#!/bin/bash

fichier="$1"

# Vérifier que le fichier existe
if [ ! -e "$fichier" ]; then
    echo "Erreur: '$fichier' n'existe pas" >&2
    exit 1
fi

# Vérifier que c'est un fichier (pas un répertoire)
if [ ! -f "$fichier" ]; then
    echo "Erreur: '$fichier' n'est pas un fichier" >&2
    exit 1
fi

# Vérifier qu'on peut le lire
if [ ! -r "$fichier" ]; then
    echo "Erreur: Pas de permission de lecture sur '$fichier'" >&2
    exit 1
fi

# Vérifier qu'on peut écrire
if [ ! -w "$fichier" ]; then
    echo "Erreur: Pas de permission d'écriture sur '$fichier'" >&2
    exit 1
fi

# Vérifier qu'il n'est pas vide
if [ ! -s "$fichier" ]; then
    echo "Attention: '$fichier' est vide" >&2
fi
```

> [!info] Tests de fichiers courants
> 
> |Test|Signification|
> |---|---|
> |`-e`|Le fichier existe|
> |`-f`|C'est un fichier régulier|
> |`-d`|C'est un répertoire|
> |`-L`|C'est un lien symbolique|
> |`-r`|Readable (lisible)|
> |`-w`|Writable (modifiable)|
> |`-x`|Executable|
> |`-s`|Le fichier existe et n'est pas vide|

#### Vérifier le format d'un fichier

```bash
#!/bin/bash

fichier="$1"

# Vérifier l'extension
if [[ ! "$fichier" =~ \.txt$ ]]; then
    echo "Erreur: Le fichier doit avoir l'extension .txt" >&2
    exit 1
fi

# Vérifier le type MIME (nécessite 'file')
type_mime=$(file -b --mime-type "$fichier")
if [ "$type_mime" != "text/plain" ]; then
    echo "Erreur: Le fichier doit être un fichier texte" >&2
    echo "Type détecté: $type_mime" >&2
    exit 1
fi
```

### Valider des chemins

```bash
#!/bin/bash

chemin="$1"

# Vérifier qu'il n'y a pas de caractères dangereux
if [[ "$chemin" =~ [;\|\&\$\`] ]]; then
    echo "Erreur: Caractères interdits dans le chemin" >&2
    exit 1
fi

# Vérifier qu'on ne remonte pas l'arborescence de façon suspecte
if [[ "$chemin" =~ \.\./\.\. ]]; then
    echo "Erreur: Chemin suspect détecté" >&2
    exit 1
fi

# Convertir en chemin absolu pour plus de sécurité
chemin_absolu=$(realpath "$chemin" 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Erreur: Impossible de résoudre le chemin '$chemin'" >&2
    exit 1
fi
```

### Valider des URLs

```bash
#!/bin/bash

url="$1"

# Vérifier qu'elle commence par http:// ou https://
if ! [[ "$url" =~ ^https?:// ]]; then
    echo "Erreur: L'URL doit commencer par http:// ou https://" >&2
    exit 1
fi

# Vérifier le format général (basique)
if ! [[ "$url" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
    echo "Erreur: Format d'URL invalide" >&2
    exit 1
fi
```

---

## 💬 Messages d'erreur clairs

### Anatomie d'un bon message d'erreur

Un message d'erreur efficace doit contenir :

1. **Le type de problème** (erreur, avertissement)
2. **Ce qui s'est mal passé** (description claire)
3. **Comment corriger** (si possible)

```bash
#!/bin/bash

fichier="$1"

if [ ! -f "$fichier" ]; then
    # ❌ Mauvais message
    echo "Erreur"
    
    # ✅ Bon message
    echo "Erreur: Le fichier '$fichier' n'existe pas" >&2
    echo "Vérifiez le chemin et réessayez" >&2
    exit 1
fi
```

> [!warning] Redirection vers stderr Toujours rediriger les messages d'erreur vers stderr avec `>&2`. Cela permet de séparer les sorties normales des erreurs.

### Messages d'erreur informatifs

```bash
#!/bin/bash

nombre="$1"

# Message avec contexte
if ! [[ "$nombre" =~ ^[0-9]+$ ]]; then
    echo "Erreur: Argument invalide" >&2
    echo "  Attendu: un nombre entier positif" >&2
    echo "  Reçu: '$nombre'" >&2
    exit 1
fi

# Message avec suggestion
port="$2"
if [ "$port" -lt 1024 ]; then
    echo "Erreur: Le port $port est dans la plage privilégiée (< 1024)" >&2
    echo "Suggestion: Utilisez un port >= 1024 ou exécutez avec sudo" >&2
    exit 1
fi
```

### Codes de sortie significatifs

Utilisez des codes de sortie différents pour différents types d'erreurs :

```bash
#!/bin/bash

# Codes de sortie
readonly ERR_ARGS=1        # Erreur d'arguments
readonly ERR_FILE=2        # Erreur de fichier
readonly ERR_NETWORK=3     # Erreur réseau
readonly ERR_PERMISSION=4  # Erreur de permission

fichier="$1"

# Pas d'arguments
if [ $# -eq 0 ]; then
    echo "Erreur: Aucun fichier spécifié" >&2
    exit $ERR_ARGS
fi

# Fichier inexistant
if [ ! -e "$fichier" ]; then
    echo "Erreur: Fichier '$fichier' introuvable" >&2
    exit $ERR_FILE
fi

# Pas de permission
if [ ! -r "$fichier" ]; then
    echo "Erreur: Pas de permission de lecture sur '$fichier'" >&2
    exit $ERR_PERMISSION
fi
```

> [!tip] Convention des codes de sortie
> 
> - `0` : Succès
> - `1` : Erreur générale
> - `2` : Mauvaise utilisation (arguments invalides)
> - `126` : Commande trouvée mais non exécutable
> - `127` : Commande introuvable
> - `128+n` : Signal fatal (n = numéro du signal)

### Fonction d'erreur réutilisable

```bash
#!/bin/bash

# Fonction pour afficher des erreurs de façon cohérente
error() {
    local message="$1"
    local code="${2:-1}"  # Code par défaut: 1
    
    echo "❌ Erreur: $message" >&2
    exit "$code"
}

# Fonction pour les avertissements
warning() {
    echo "⚠️  Avertissement: $1" >&2
}

# Utilisation
fichier="$1"
[ $# -eq 0 ] && error "Aucun fichier spécifié" 2
[ ! -f "$fichier" ] && error "Fichier '$fichier' introuvable"
[ ! -s "$fichier" ] && warning "Le fichier '$fichier' est vide"
```

---

## 📖 Usage et aide --help

### Structure d'un message d'aide

Un bon message d'aide doit contenir :

1. **Nom et description** du script
2. **Syntaxe** d'utilisation
3. **Arguments** obligatoires et optionnels
4. **Options** disponibles
5. **Exemples** d'utilisation

```bash
#!/bin/bash

show_help() {
    cat << EOF
Nom: backup.sh - Script de sauvegarde automatique

Usage: $0 [OPTIONS] <source> <destination>

Description:
    Sauvegarde les fichiers de <source> vers <destination>
    avec horodatage et compression optionnelle.

Arguments:
    source          Répertoire source à sauvegarder
    destination     Répertoire de destination

Options:
    -c, --compress  Compresser l'archive (gzip)
    -v, --verbose   Mode verbeux
    -h, --help      Afficher cette aide
    -V, --version   Afficher la version

Exemples:
    $0 /home/user/documents /backup
    $0 --compress --verbose /var/www /backup/web
    $0 -cv ~/photos /media/backup

Codes de sortie:
    0    Succès
    1    Erreur d'arguments
    2    Erreur d'accès fichier
    3    Erreur de sauvegarde

EOF
}

# Vérifier si --help ou -h est passé
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi
```

> [!tip] Utiliser `cat << EOF` Cette syntaxe (heredoc) permet d'écrire du texte multi-lignes de façon lisible sans multiplier les `echo`.

### Aide contextuelle

```bash
#!/bin/bash

show_usage() {
    echo "Usage: $0 [OPTIONS] <fichier>"
    echo "Utilisez '$0 --help' pour plus d'informations"
}

# Si mauvais arguments, afficher usage court
if [ $# -eq 0 ]; then
    echo "Erreur: Aucun argument fourni" >&2
    show_usage >&2
    exit 1
fi
```

### Afficher la version

```bash
#!/bin/bash

readonly VERSION="1.2.0"
readonly AUTHOR="Votre Nom"
readonly DATE="2024-12-16"

show_version() {
    cat << EOF
backup.sh version $VERSION
Auteur: $AUTHOR
Date: $DATE
Licence: MIT
EOF
}

# Option --version
if [ "$1" = "--version" ] || [ "$1" = "-V" ]; then
    show_version
    exit 0
fi
```

### Validation avec message d'aide intégré

```bash
#!/bin/bash

show_help() {
    cat << EOF
Usage: $0 <nombre>

Arguments:
    nombre    Un entier entre 1 et 100

EOF
}

# Aide automatique
[ "$1" = "--help" ] && { show_help; exit 0; }

# Validation avec aide
if [ $# -ne 1 ]; then
    echo "Erreur: Nombre d'arguments incorrect" >&2
    show_help >&2
    exit 1
fi

nombre="$1"

if ! [[ "$nombre" =~ ^[0-9]+$ ]]; then
    echo "Erreur: '$nombre' n'est pas un nombre valide" >&2
    show_help >&2
    exit 1
fi

if [ "$nombre" -lt 1 ] || [ "$nombre" -gt 100 ]; then
    echo "Erreur: Le nombre doit être entre 1 et 100" >&2
    show_help >&2
    exit 1
fi

echo "Nombre valide: $nombre"
```

---

## 🔐 Valeurs par défaut sécurisées

### Principe du "secure by default"

Toujours choisir des valeurs par défaut qui minimisent les risques :

```bash
#!/bin/bash

# ✅ Bonnes valeurs par défaut
readonly DEBUG="${DEBUG:-false}"           # Debug désactivé par défaut
readonly TIMEOUT="${TIMEOUT:-30}"          # Timeout raisonnable
readonly MAX_RETRIES="${MAX_RETRIES:-3}"   # Limite les tentatives
readonly BACKUP_DIR="${BACKUP_DIR:-/tmp/backup}"  # Répertoire sûr

# ❌ Mauvaises valeurs par défaut
# DEBUG="${DEBUG:-true}"      # Debug activé = fuite d'info
# TIMEOUT="${TIMEOUT:-9999}"  # Pas de limite = blocage
# BACKUP_DIR="${BACKUP_DIR:-/}"  # Répertoire dangereux
```

> [!warning] Valeurs par défaut dangereuses Évitez les valeurs par défaut qui pourraient :
> 
> - Exposer des informations sensibles
> - Modifier des fichiers système
> - Consommer trop de ressources
> - Permettre des accès non autorisés

### Utiliser des valeurs par défaut avec validation

```bash
#!/bin/bash

# Port avec valeur par défaut
port="${1:-8080}"

# Valider même si c'est la valeur par défaut
if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    echo "Erreur: Port invalide '$port'" >&2
    exit 1
fi

if [ "$port" -lt 1024 ] || [ "$port" -gt 65535 ]; then
    echo "Erreur: Le port doit être entre 1024 et 65535" >&2
    exit 1
fi

echo "Utilisation du port: $port"
```

### Valeurs par défaut depuis variables d'environnement

```bash
#!/bin/bash

# Priorité: 1. Argument, 2. Variable d'environnement, 3. Défaut
config_file="${1:-${CONFIG_FILE:-/etc/myapp/config.conf}}"

# Valider le fichier de config
if [ ! -f "$config_file" ]; then
    echo "Erreur: Fichier de configuration '$config_file' introuvable" >&2
    echo "Définissez CONFIG_FILE ou passez le chemin en argument" >&2
    exit 1
fi
```

### Créer des répertoires temporaires sécurisés

```bash
#!/bin/bash

# ❌ Dangereux: répertoire prévisible
# temp_dir="/tmp/monapp"

# ✅ Sécurisé: répertoire aléatoire
temp_dir=$(mktemp -d) || {
    echo "Erreur: Impossible de créer un répertoire temporaire" >&2
    exit 1
}

# Nettoyage automatique à la sortie
trap 'rm -rf "$temp_dir"' EXIT

echo "Répertoire temporaire: $temp_dir"
```

> [!tip] Toujours utiliser `mktemp` `mktemp` crée des fichiers/répertoires avec des noms uniques et imprévisibles, évitant les problèmes de sécurité liés aux noms prévisibles.

### Valeurs par défaut pour les options booléennes

```bash
#!/bin/bash

# Initialiser toutes les options à false par défaut
verbose=false
debug=false
force=false

# Parser les options
while [ $# -gt 0 ]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        -d|--debug)
            debug=true
            shift
            ;;
        -f|--force)
            force=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Utilisation
$verbose && echo "Mode verbeux activé"
$debug && echo "Mode debug activé"
```

### Limites de sécurité

```bash
#!/bin/bash

# Limites par défaut sécurisées
readonly MAX_FILE_SIZE="${MAX_FILE_SIZE:-10485760}"  # 10 MB
readonly MAX_CONNECTIONS="${MAX_CONNECTIONS:-10}"
readonly TIMEOUT="${TIMEOUT:-30}"

fichier="$1"

# Vérifier la taille du fichier
if [ -f "$fichier" ]; then
    taille=$(stat -f%z "$fichier" 2>/dev/null || stat -c%s "$fichier" 2>/dev/null)
    
    if [ "$taille" -gt "$MAX_FILE_SIZE" ]; then
        echo "Erreur: Le fichier dépasse la taille maximale autorisée" >&2
        echo "  Taille: $taille octets" >&2
        echo "  Maximum: $MAX_FILE_SIZE octets" >&2
        exit 1
    fi
fi
```

---

## ⚠️ Pièges courants

### 1. Oublier de quoter les variables

```bash
# ❌ Dangereux
if [ -f $fichier ]; then
    # Si $fichier contient des espaces, cela échoue
fi

# ✅ Correct
if [ -f "$fichier" ]; then
    # Fonctionne même avec des espaces
fi
```

### 2. Ne pas vérifier les codes de sortie

```bash
# ❌ Dangereux
cd /un/repertoire
rm -rf *  # Peut supprimer dans le mauvais endroit !

# ✅ Correct
cd /un/repertoire || {
    echo "Erreur: Impossible d'accéder au répertoire" >&2
    exit 1
}
rm -rf *
```

### 3. Comparer des chaînes avec des opérateurs numériques

```bash
# ❌ Incorrect
if [ "$var" = "" ]; then  # Utilise = pour les chaînes

# ✅ Correct
if [ -z "$var" ]; then  # Test de chaîne vide approprié
```

### 4. Validation insuffisante des chemins

```bash
# ❌ Dangereux
fichier="$1"
cat "$fichier"  # Peut lire n'importe quel fichier !

# ✅ Correct
fichier="$1"

# Vérifier que le fichier est dans le répertoire autorisé
case "$fichier" in
    /chemin/autorise/*)
        cat "$fichier"
        ;;
    *)
        echo "Erreur: Accès refusé" >&2
        exit 1
        ;;
esac
```

### 5. Faire confiance aux entrées pour les noms de fichiers

```bash
# ❌ Dangereux
nom="$1"
touch "$nom"  # Si nom="../../etc/passwd", problème !

# ✅ Correct
nom="$1"

# Supprimer les caractères dangereux
nom_securise="${nom//[^a-zA-Z0-9._-]/}"

if [ "$nom" != "$nom_securise" ]; then
    echo "Erreur: Nom de fichier invalide" >&2
    exit 1
fi

touch "$nom_securise"
```

### 6. Ne pas gérer les variables non définies

```bash
#!/bin/bash

# ✅ Activez le mode strict
set -u  # Erreur si variable non définie

# Maintenant cela génère une erreur
echo "$variable_non_definie"  # Erreur !
```

---

## 🎯 Bonnes pratiques

### 1. Script de validation complet

Voici un exemple de script avec toutes les bonnes pratiques :

```bash
#!/bin/bash

# Mode strict
set -euo pipefail

# Constantes
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0.0"
readonly ERR_ARGS=1
readonly ERR_FILE=2

# Fonction d'aide
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] <fichier_source> <fichier_destination>

Description:
    Copie et valide un fichier texte.

Arguments:
    fichier_source        Fichier texte source
    fichier_destination   Fichier de destination

Options:
    -f, --force          Écraser la destination si elle existe
    -v, --verbose        Mode verbeux
    -h, --help           Afficher cette aide

Exemples:
    $SCRIPT_NAME input.txt output.txt
    $SCRIPT_NAME --force input.txt output.txt

EOF
}

# Fonction d'erreur
error() {
    echo "❌ Erreur: $1" >&2
    [ -n "${2:-}" ] && exit "$2"
    exit 1
}

# Fonction de validation de fichier texte
validate_text_file() {
    local file="$1"
    
    [ ! -e "$file" ] && error "Le fichier '$file' n'existe pas" $ERR_FILE
    [ ! -f "$file" ] && error "'$file' n'est pas un fichier" $ERR_FILE
    [ ! -r "$file" ] && error "Pas de permission de lecture sur '$file'" $ERR_FILE
    
    # Vérifier que c'est du texte
    if ! file -b --mime-type "$file" | grep -q "^text/"; then
        error "Le fichier '$file' n'est pas un fichier texte" $ERR_FILE
    fi
}

# Variables par défaut
force=false
verbose=false

# Parser les options
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            force=true
            shift
            ;;
        -v|--verbose)
            verbose=true
            shift
            ;;
        -*)
            error "Option inconnue: $1" $ERR_ARGS
            ;;
        *)
            break
            ;;
    esac
done

# Vérifier le nombre d'arguments
if [ $# -ne 2 ]; then
    echo "Erreur: Ce script nécessite exactement 2 arguments" >&2
    show_help >&2
    exit $ERR_ARGS
fi

source="$1"
destination="$2"

# Valider le fichier source
validate_text_file "$source"

# Vérifier la destination
if [ -e "$destination" ] && [ "$force" = false ]; then
    error "Le fichier '$destination' existe déjà (utilisez --force pour écraser)"
fi

# Effectuer la copie
$verbose && echo "Copie de '$source' vers '$destination'..."

if cp "$source" "$destination"; then
    $verbose && echo "✅ Copie réussie"
    exit 0
else
    error "Échec de la copie"
fi
```

### 2. Checklist de validation

Avant de considérer un script comme "prêt", vérifiez :

- [ ] Tous les arguments sont validés
- [ ] Les types de données sont vérifiés
- [ ] Les fichiers/répertoires sont testés
- [ ] Les messages d'erreur sont clairs et sur stderr
- [ ] Une aide (`--help`) est disponible
- [ ] Des valeurs par défaut sécurisées sont utilisées
- [ ] Les variables sont quotées
- [ ] `set -u` est activé (ou équivalent)
- [ ] Les codes de sortie sont appropriés
- [ ] Les cas limites sont gérés

### 3. Template de démarrage

```bash
#!/bin/bash

# Mode strict
set -euo pipefail

# === CONFIGURATION ===
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0.0"

# Codes d'erreur
readonly ERR_ARGS=1
readonly ERR_FILE=2

# === FONCTIONS ===

show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] <arguments>

Description:
    [Description de votre script]

Arguments:
    [Vos arguments]

Options:
    -h, --help    Afficher cette aide

EOF
}

error() {
    echo "❌ Erreur: $1" >&2
    exit "${2:-1}"
}

validate_arguments() {
    # Ajoutez vos validations ici
    :
}

# === PROGRAMME PRINCIPAL ===

# Aide
[ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ] && { show_help; exit 0; }

# Validation
validate_arguments "$@"

# Votre code ici
echo "Script exécuté avec succès"
```

### 4. Validation progressive

Structurez vos validations du plus général au plus spécifique :

```bash
#!/bin/bash

fichier="$1"

# 1. Vérifier la présence
[ -z "$fichier" ] && error "Aucun fichier spécifié"

# 2. Vérifier l'existence
[ ! -e "$fichier" ] && error "Le fichier n'existe pas"

# 3. Vérifier le type
[ ! -f "$fichier" ] && error "Ce n'est pas un fichier"

# 4. Vérifier les permissions
[ ! -r "$fichier" ] && error "Pas de permission de lecture"

# 5. Vérifier le contenu spécifique
if ! [[ "$fichier" =~ \.txt$ ]]; then
    error "Le fichier doit avoir l'extension .txt"
fi

# 6. Vérifier la taille
taille=$(stat -c%s "$fichier" 2>/dev/null || stat -f%z "$fichier" 2>/dev/null)
[ "$taille" -gt 10485760 ] && error "Le fichier dépasse 10 MB"

# Toutes les validations sont passées
echo "Fichier '$fichier' validé avec succès"
```

### 5. Documenter les validations

```bash
#!/bin/bash

# Fonction avec documentation claire des validations
process_user_input() {
    local username="$1"
    
    # Validation 1: Pas vide
    if [ -z "$username" ]; then
        error "Le nom d'utilisateur ne peut pas être vide"
    fi
    
    # Validation 2: Longueur (3-20 caractères)
    local len=${#username}
    if [ "$len" -lt 3 ] || [ "$len" -gt 20 ]; then
        error "Le nom d'utilisateur doit contenir entre 3 et 20 caractères"
    fi
    
    # Validation 3: Format (lettres, chiffres, tirets, underscores)
    if ! [[ "$username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        error "Le nom d'utilisateur contient des caractères invalides"
    fi
    
    # Validation 4: Ne commence pas par un chiffre
    if [[ "$username" =~ ^[0-9] ]]; then
        error "Le nom d'utilisateur ne peut pas commencer par un chiffre"
    fi
    
    echo "Nom d'utilisateur '$username' validé"
}
```

### 6. Gérer les entrées interactives

```bash
#!/bin/bash

# Fonction pour lire une entrée avec validation
read_validated_input() {
    local prompt="$1"
    local validation_func="$2"
    local max_attempts=3
    local attempt=0
    local input
    
    while [ "$attempt" -lt "$max_attempts" ]; do
        read -p "$prompt: " input
        
        # Valider l'entrée
        if $validation_func "$input"; then
            echo "$input"
            return 0
        fi
        
        attempt=$((attempt + 1))
        if [ "$attempt" -lt "$max_attempts" ]; then
            echo "Entrée invalide. Il vous reste $((max_attempts - attempt)) tentative(s)." >&2
        fi
    done
    
    error "Nombre maximum de tentatives atteint"
}

# Fonction de validation d'email
validate_email() {
    local email="$1"
    [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# Utilisation
email=$(read_validated_input "Entrez votre email" validate_email)
echo "Email validé: $email"
```

### 7. Validation avec confirmation

```bash
#!/bin/bash

# Pour les actions dangereuses, demander confirmation
confirm_action() {
    local action="$1"
    local response
    
    echo "⚠️  Attention: Vous êtes sur le point de $action"
    read -p "Êtes-vous sûr ? (oui/non): " response
    
    case "$response" in
        oui|OUI|o|O|yes|YES|y|Y)
            return 0
            ;;
        *)
            echo "Action annulée" >&2
            return 1
            ;;
    esac
}

# Utilisation
fichier="$1"

if [ -f "$fichier" ]; then
    if confirm_action "supprimer le fichier '$fichier'"; then
        rm "$fichier"
        echo "✅ Fichier supprimé"
    else
        exit 1
    fi
fi
```

### 8. Validation en cascade

```bash
#!/bin/bash

# Valider plusieurs conditions liées
validate_database_config() {
    local host="$1"
    local port="$2"
    local username="$3"
    local password="$4"
    
    # Validation du host
    if [ -z "$host" ]; then
        error "Le host ne peut pas être vide"
    fi
    
    # Validation du port
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        error "Le port doit être un nombre"
    fi
    
    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        error "Le port doit être entre 1 et 65535"
    fi
    
    # Validation du username
    if [ -z "$username" ]; then
        error "Le nom d'utilisateur ne peut pas être vide"
    fi
    
    if [ ${#username} -lt 3 ]; then
        error "Le nom d'utilisateur doit contenir au moins 3 caractères"
    fi
    
    # Validation du password
    if [ -z "$password" ]; then
        error "Le mot de passe ne peut pas être vide"
    fi
    
    if [ ${#password} -lt 8 ]; then
        error "Le mot de passe doit contenir au moins 8 caractères"
    fi
    
    # Vérifier la complexité du mot de passe
    if ! [[ "$password" =~ [A-Z] ]]; then
        error "Le mot de passe doit contenir au moins une majuscule"
    fi
    
    if ! [[ "$password" =~ [0-9] ]]; then
        error "Le mot de passe doit contenir au moins un chiffre"
    fi
    
    echo "✅ Configuration validée"
}

# Utilisation
validate_database_config "localhost" "5432" "admin" "SecurePass123"
```

### 9. Validation avec retour d'information détaillé

```bash
#!/bin/bash

# Fonction qui retourne des informations détaillées sur la validation
validate_password_strength() {
    local password="$1"
    local score=0
    local messages=()
    
    # Vérifier la longueur
    if [ ${#password} -ge 8 ]; then
        score=$((score + 1))
        messages+=("✅ Longueur suffisante (>= 8 caractères)")
    else
        messages+=("❌ Trop court (minimum 8 caractères)")
    fi
    
    # Vérifier la présence de majuscules
    if [[ "$password" =~ [A-Z] ]]; then
        score=$((score + 1))
        messages+=("✅ Contient des majuscules")
    else
        messages+=("❌ Aucune majuscule")
    fi
    
    # Vérifier la présence de minuscules
    if [[ "$password" =~ [a-z] ]]; then
        score=$((score + 1))
        messages+=("✅ Contient des minuscules")
    else
        messages+=("❌ Aucune minuscule")
    fi
    
    # Vérifier la présence de chiffres
    if [[ "$password" =~ [0-9] ]]; then
        score=$((score + 1))
        messages+=("✅ Contient des chiffres")
    else
        messages+=("❌ Aucun chiffre")
    fi
    
    # Vérifier la présence de caractères spéciaux
    if [[ "$password" =~ [^a-zA-Z0-9] ]]; then
        score=$((score + 1))
        messages+=("✅ Contient des caractères spéciaux")
    else
        messages+=("⚠️  Aucun caractère spécial (recommandé)")
    fi
    
    # Afficher les résultats
    echo "Force du mot de passe: $score/5"
    printf '%s\n' "${messages[@]}"
    
    # Retourner le succès ou l'échec
    [ "$score" -ge 3 ]
}

# Utilisation
password="MonMotDePasse123!"
if validate_password_strength "$password"; then
    echo "
Mot de passe accepté"
else
    echo "
Mot de passe trop faible, veuillez en choisir un plus fort" >&2
    exit 1
fi
```

### 10. Validation centralisée

```bash
#!/bin/bash

# Bibliothèque de validations réutilisables
is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

is_integer() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}

is_float() {
    [[ "$1" =~ ^-?[0-9]*\.?[0-9]+$ ]]
}

is_email() {
    [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

is_url() {
    [[ "$1" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]
}

is_ip() {
    [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
}

is_date() {
    # Format YYYY-MM-DD
    [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
}

is_alphanumeric() {
    [[ "$1" =~ ^[a-zA-Z0-9]+$ ]]
}

in_range() {
    local value="$1"
    local min="$2"
    local max="$3"
    
    is_number "$value" && [ "$value" -ge "$min" ] && [ "$value" -le "$max" ]
}

# Utilisation
value="42"

if is_number "$value"; then
    echo "'$value' est un nombre"
fi

if in_range "$value" 1 100; then
    echo "'$value' est entre 1 et 100"
fi

email="user@example.com"
if is_email "$email"; then
    echo "'$email' est un email valide"
fi
```

---

## 🎓 Résumé

La validation des entrées en Bash repose sur plusieurs piliers :

1. **Vérification systématique** : Ne jamais faire confiance aux données entrantes
2. **Messages clairs** : Informer l'utilisateur précisément du problème
3. **Sécurité par défaut** : Choisir des valeurs par défaut qui minimisent les risques
4. **Documentation** : Fournir une aide complète avec `--help`
5. **Codes de sortie** : Utiliser des codes appropriés pour différencier les erreurs

> [!tip] Règle d'or **Valider tôt, valider souvent, échouer rapidement**. Il vaut mieux détecter une erreur immédiatement que de la laisser se propager dans le script.

Un script robuste est un script qui :

- Anticipe les erreurs possibles
- Valide toutes les entrées
- Communique clairement avec l'utilisateur
- Échoue de manière prévisible et contrôlée
- Offre des valeurs par défaut sécurisées

La validation des entrées n'est pas une perte de temps : c'est un **investissement** qui rend vos scripts plus fiables, plus sûrs et plus maintenables. 🛡️