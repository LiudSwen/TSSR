

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

## 🎯 Introduction à getopts

`getopts` est une commande builtin de Bash qui permet de parser les options courtes (de type `-a`, `-b`, `-c`) passées en argument à un script. C'est l'outil standard pour gérer les options de manière propre et professionnelle.

> [!info] Pourquoi utiliser getopts ?
> 
> - **Standardisation** : Respecte les conventions Unix/Linux
> - **Simplicité** : Gère automatiquement le parsing
> - **Robustesse** : Détecte les erreurs d'utilisation
> - **Portable** : Disponible dans tous les shells POSIX

> [!warning] Limitation `getopts` ne gère que les options **courtes** (ex: `-v`, `-f file`). Pour les options longues (`--verbose`, `--file=name`), il faut utiliser `getopt` (avec un 't' final) ou parser manuellement.

---

## 📝 Syntaxe de getopts

```bash
getopts "optstring" variable_name
```

**Composants :**

- `optstring` : Chaîne définissant les options acceptées
- `variable_name` : Variable qui recevra chaque option trouvée

### Structure de l'optstring

```bash
"abc:d:ef"
```

|Caractère|Signification|
|---|---|
|`a`|Option `-a` sans argument|
|`b`|Option `-b` sans argument|
|`c:`|Option `-c` **avec** argument obligatoire|
|`d:`|Option `-d` **avec** argument obligatoire|
|`e`|Option `-e` sans argument|
|`f`|Option `-f` sans argument|

> [!tip] Le deux-points (:) Le `:` après une lettre indique que cette option **nécessite un argument**. Sans `:`, l'option n'accepte pas d'argument.

---

## ✅ Options sans argument

Les options sans argument sont les plus simples : elles agissent comme des drapeaux booléens (activé/désactivé).

### Exemple basique

```bash
#!/bin/bash

verbose=false
debug=false

while getopts "vd" opt; do
    case $opt in
        v)
            verbose=true
            ;;
        d)
            debug=true
            ;;
    esac
done

# Utilisation
if $verbose; then
    echo "Mode verbose activé"
fi

if $debug; then
    echo "Mode debug activé"
fi
```

**Utilisation du script :**

```bash
./script.sh -v      # Active verbose
./script.sh -d      # Active debug
./script.sh -vd     # Active les deux (options combinées)
./script.sh -v -d   # Active les deux (options séparées)
```

> [!example] Cas d'usage réels
> 
> - `-v` : Mode verbose (afficher plus d'informations)
> - `-q` : Mode quiet (silencieux)
> - `-f` : Mode force (forcer une action)
> - `-r` : Mode récursif
> - `-h` : Afficher l'aide

---

## 📦 Options avec argument

Les options avec argument permettent de passer des valeurs supplémentaires. On ajoute `:` après la lettre dans l'optstring.

### Syntaxe

```bash
getopts "f:o:n:" opt
#         ↑ ↑ ↑
#         Ces options nécessitent un argument
```

### Exemple complet

```bash
#!/bin/bash

input_file=""
output_file=""
iterations=1

while getopts "f:o:n:" opt; do
    case $opt in
        f)
            input_file="$OPTARG"
            ;;
        o)
            output_file="$OPTARG"
            ;;
        n)
            iterations="$OPTARG"
            ;;
    esac
done

echo "Fichier d'entrée : $input_file"
echo "Fichier de sortie : $output_file"
echo "Nombre d'itérations : $iterations"
```

**Utilisation :**

```bash
./script.sh -f input.txt -o output.txt -n 5
./script.sh -f input.txt -ooutput.txt -n5     # Espaces optionnels
```

> [!tip] Espacement L'espace entre l'option et son argument est **optionnel** :
> 
> - `-f fichier.txt` ✅
> - `-ffichier.txt` ✅

---

## 🔢 Variables OPTARG et OPTIND

`getopts` utilise deux variables spéciales automatiquement mises à jour.

### OPTARG

Contient la **valeur de l'argument** de l'option courante.

```bash
while getopts "f:n:" opt; do
    case $opt in
        f)
            # OPTARG contient le nom du fichier
            echo "Fichier : $OPTARG"
            ;;
        n)
            # OPTARG contient le nombre
            echo "Nombre : $OPTARG"
            ;;
    esac
done
```

> [!info] Quand OPTARG est défini `OPTARG` n'est défini **que pour les options avec argument** (celles suivies de `:` dans l'optstring).

### OPTIND

Contient l'**index** du prochain argument à traiter dans `$@`.

```bash
#!/bin/bash

while getopts "ab:" opt; do
    case $opt in
        a) echo "Option -a trouvée" ;;
        b) echo "Option -b avec valeur : $OPTARG" ;;
    esac
done

# Décaler pour accéder aux arguments non-option
shift $((OPTIND - 1))

echo "Arguments restants : $@"
```

**Utilisation :**

```bash
./script.sh -a -b valeur fichier1 fichier2
# Sortie :
# Option -a trouvée
# Option -b avec valeur : valeur
# Arguments restants : fichier1 fichier2
```

> [!tip] Utilité de OPTIND `OPTIND` permet de séparer les **options** (ex: `-a -b`) des **arguments positionnels** (ex: fichiers, chemins). Utilisez `shift $((OPTIND - 1))` pour accéder aux arguments restants.

### Tableau récapitulatif

|Variable|Type|Contenu|
|---|---|---|
|`$opt`|Chaîne|Lettre de l'option courante (`a`, `b`, `c`, etc.)|
|`$OPTARG`|Chaîne|Valeur de l'argument de l'option (si option avec `:`)|
|`$OPTIND`|Entier|Index du prochain argument à traiter (commence à 1)|

---

## ⚠️ Gestion d'erreurs

`getopts` offre deux modes de gestion d'erreurs selon le premier caractère de l'optstring.

### Mode par défaut (verbeux)

Sans `:` au début, `getopts` affiche des messages d'erreur automatiquement.

```bash
#!/bin/bash

while getopts "ab:" opt; do
    case $opt in
        a) echo "Option -a" ;;
        b) echo "Option -b : $OPTARG" ;;
        \?)
            echo "Option invalide"
            exit 1
            ;;
    esac
done
```

**Test :**

```bash
./script.sh -z
# Sortie automatique de getopts :
# ./script.sh: illegal option -- z
# Puis notre message :
# Option invalide
```

### Mode silencieux (recommandé)

En préfixant l'optstring par `:`, on désactive les messages automatiques et on gère tout manuellement.

```bash
#!/bin/bash

while getopts ":ab:c:" opt; do
#                ↑ 
#    Le : initial active le mode silencieux
    case $opt in
        a)
            echo "Option -a activée"
            ;;
        b)
            echo "Option -b avec valeur : $OPTARG"
            ;;
        c)
            echo "Option -c avec valeur : $OPTARG"
            ;;
        :)
            # Option nécessitant un argument mais aucun fourni
            echo "Erreur : l'option -$OPTARG nécessite un argument" >&2
            exit 1
            ;;
        \?)
            # Option inconnue
            echo "Erreur : option -$OPTARG inconnue" >&2
            exit 1
            ;;
    esac
done
```

**Tests :**

```bash
./script.sh -z          # Option inconnue
# Erreur : option -z inconnue

./script.sh -b          # Argument manquant
# Erreur : l'option -b nécessite un argument

./script.sh -b test     # OK
# Option -b avec valeur : test
```

> [!warning] Les deux cas spéciaux
> 
> - `\?` : Option inconnue détectée
> - `:` : Argument manquant pour une option qui en requiert un
> 
> Dans les deux cas, `$OPTARG` contient la lettre de l'option problématique.

### Tableau des codes d'erreur

|Pattern|Condition|$opt|$OPTARG|
|---|---|---|---|
|Lettre normale|Option valide trouvée|Lettre de l'option|Argument si requis|
|`:`|Argument manquant|`:`|Lettre de l'option|
|`\?`|Option inconnue|`?`|Lettre de l'option|

---

## 🔄 Boucle de traitement

La structure typique d'utilisation de `getopts` suit ce pattern :

### Structure complète

```bash
#!/bin/bash

# 1. Initialisation des variables
verbose=false
output_file=""
config_file=""

# 2. Fonction d'aide
usage() {
    cat << EOF
Usage : $0 [OPTIONS] [FICHIERS...]

OPTIONS :
    -v          Mode verbose
    -o FILE     Fichier de sortie
    -c FILE     Fichier de configuration
    -h          Afficher cette aide

EXEMPLES :
    $0 -v -o output.txt fichier1.txt
    $0 -c config.ini -o resultat.log
EOF
    exit 1
}

# 3. Boucle getopts
while getopts ":vo:c:h" opt; do
    case $opt in
        v)
            verbose=true
            ;;
        o)
            output_file="$OPTARG"
            ;;
        c)
            config_file="$OPTARG"
            # Validation de l'existence du fichier
            if [[ ! -f "$config_file" ]]; then
                echo "Erreur : fichier '$config_file' introuvable" >&2
                exit 1
            fi
            ;;
        h)
            usage
            ;;
        :)
            echo "Erreur : -$OPTARG nécessite un argument" >&2
            usage
            ;;
        \?)
            echo "Erreur : option -$OPTARG inconnue" >&2
            usage
            ;;
    esac
done

# 4. Décalage pour accéder aux arguments positionnels
shift $((OPTIND - 1))

# 5. Validation des arguments
if [[ $# -eq 0 ]]; then
    echo "Erreur : au moins un fichier requis" >&2
    usage
fi

# 6. Traitement principal
if $verbose; then
    echo "Configuration :"
    echo "  - Output : ${output_file:-stdout}"
    echo "  - Config : ${config_file:-aucun}"
    echo "  - Fichiers : $@"
fi

# Traiter chaque fichier
for file in "$@"; do
    if $verbose; then
        echo "Traitement de $file..."
    fi
    # ... traitement ...
done
```

### Flux de traitement

```
┌─────────────────────┐
│ Initialisation      │
│ des variables       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Boucle while        │
│ getopts             │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ case pour chaque    │
│ option              │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ shift $((OPTIND-1)) │
│ Récupérer args      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Validation et       │
│ traitement          │
└─────────────────────┘
```

> [!tip] Bonnes pratiques dans la boucle
> 
> 1. **Toujours** valider les arguments critiques (existence de fichiers, format de nombres)
> 2. Fournir une option `-h` pour l'aide
> 3. Utiliser le mode silencieux (`:` au début)
> 4. Rediriger les erreurs vers stderr (`>&2`)
> 5. Utiliser des codes de sortie appropriés (`exit 1` pour les erreurs)

---

## 🚨 Pièges courants

### 1. Oublier le deux-points pour les options avec argument

```bash
# ❌ FAUX
while getopts "f" opt; do
    case $opt in
        f) file="$OPTARG" ;;  # OPTARG sera vide !
    esac
done

# ✅ CORRECT
while getopts "f:" opt; do
    case $opt in
        f) file="$OPTARG" ;;
    esac
done
```

### 2. Ne pas gérer les erreurs

```bash
# ❌ FAUX - Pas de gestion d'erreur
while getopts "ab:" opt; do
    case $opt in
        a) echo "A" ;;
        b) echo "B: $OPTARG" ;;
        # Que se passe-t-il si option inconnue ?
    esac
done

# ✅ CORRECT - Mode silencieux avec gestion
while getopts ":ab:" opt; do
    case $opt in
        a) echo "A" ;;
        b) echo "B: $OPTARG" ;;
        :) echo "Erreur: -$OPTARG nécessite un argument" >&2; exit 1 ;;
        \?) echo "Erreur: option -$OPTARG inconnue" >&2; exit 1 ;;
    esac
done
```

### 3. Ne pas décaler après getopts

```bash
# ❌ FAUX - Les options restent dans $@
while getopts "a" opt; do
    case $opt in
        a) echo "Option A" ;;
    esac
done

for file in "$@"; do
    echo "Fichier: $file"  # Affichera aussi -a !
done

# ✅ CORRECT - Décalage pour nettoyer
while getopts "a" opt; do
    case $opt in
        a) echo "Option A" ;;
    esac
done

shift $((OPTIND - 1))  # Retire les options traitées

for file in "$@"; do
    echo "Fichier: $file"  # N'affiche que les vrais fichiers
done
```

### 4. Réutiliser getopts sans réinitialiser OPTIND

```bash
# ❌ FAUX - Dans une fonction appelée plusieurs fois
function process() {
    while getopts "a" opt; do
        # ...
    done
    # OPTIND garde sa valeur !
}

# ✅ CORRECT - Réinitialiser OPTIND
function process() {
    local OPTIND=1  # Reset pour cette fonction
    while getopts "a" opt; do
        # ...
    done
}
```

### 5. Citation incorrecte de $OPTARG

```bash
# ❌ RISQUÉ - Fichiers avec espaces posent problème
file=$OPTARG

# ✅ CORRECT - Toujours citer
file="$OPTARG"
```

---

## ✨ Bonnes pratiques

### 1. Structure standard

```bash
#!/bin/bash

# Variables par défaut en haut
verbose=false
output=""

# Mode silencieux avec : au début
while getopts ":vo:h" opt; do
    case $opt in
        v) verbose=true ;;
        o) output="$OPTARG" ;;
        h) usage; exit 0 ;;
        :) echo "Erreur: -$OPTARG nécessite un argument" >&2; exit 1 ;;
        \?) echo "Erreur: option -$OPTARG inconnue" >&2; exit 1 ;;
    esac
done

shift $((OPTIND - 1))
```

### 2. Validation des arguments

```bash
while getopts ":n:f:" opt; do
    case $opt in
        n)
            # Valider que c'est un nombre
            if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                echo "Erreur: -n nécessite un nombre entier" >&2
                exit 1
            fi
            number="$OPTARG"
            ;;
        f)
            # Valider que le fichier existe
            if [[ ! -f "$OPTARG" ]]; then
                echo "Erreur: fichier '$OPTARG' introuvable" >&2
                exit 1
            fi
            file="$OPTARG"
            ;;
    esac
done
```

### 3. Fonction d'aide claire

```bash
usage() {
    cat << 'EOF'
Usage: script.sh [OPTIONS] fichiers...

Description:
    Ce script traite des fichiers avec diverses options.

OPTIONS:
    -v              Mode verbose
    -o FILE         Fichier de sortie (défaut: stdout)
    -n NUMBER       Nombre d'itérations (défaut: 1)
    -h              Afficher cette aide

EXEMPLES:
    script.sh -v fichier.txt
    script.sh -o output.log -n 5 *.txt
    script.sh -h

CODES DE RETOUR:
    0    Succès
    1    Erreur de syntaxe ou d'arguments
    2    Erreur d'exécution
EOF
    exit "${1:-0}"
}
```

### 4. Options combinées

```bash
# Les utilisateurs peuvent combiner les options sans argument
./script.sh -vdf fichier.txt
# Équivalent à :
./script.sh -v -d -f fichier.txt
```

### 5. Messages d'erreur sur stderr

```bash
# ✅ TOUJOURS rediriger les erreurs sur stderr
echo "Erreur: ..." >&2

# Avec exit code approprié
echo "Erreur: fichier manquant" >&2
exit 1
```

### 6. Variables locales dans les fonctions

```bash
function process_options() {
    local OPTIND=1  # Important si appelé plusieurs fois
    local verbose=false
    local output=""
    
    while getopts ":vo:" opt; do
        case $opt in
            v) verbose=true ;;
            o) output="$OPTARG" ;;
        esac
    done
    
    # Utiliser les variables locales
    if $verbose; then
        echo "Output: $output"
    fi
}
```

### 7. Valeurs par défaut explicites

```bash
# Définir des valeurs par défaut claires
output_file="${output_file:-/dev/stdout}"
iterations="${iterations:-1}"
config_file="${config_file:-$HOME/.config/myapp.conf}"
```

---

## 📊 Exemple complet et professionnel

```bash
#!/bin/bash
#
# backup.sh - Script de sauvegarde avec options
# Usage: backup.sh [OPTIONS] répertoires...
#

set -euo pipefail  # Mode strict

# ==============================================================================
# VARIABLES GLOBALES
# ==============================================================================

SCRIPT_NAME=$(basename "$0")
VERBOSE=false
DRY_RUN=false
OUTPUT_DIR="/tmp/backup"
COMPRESSION="gzip"
EXCLUDE_PATTERNS=()

# ==============================================================================
# FONCTIONS
# ==============================================================================

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] répertoires...

Crée une archive compressée des répertoires spécifiés.

OPTIONS:
    -v              Mode verbose
    -n              Mode dry-run (simulation)
    -o DIR          Répertoire de sortie (défaut: $OUTPUT_DIR)
    -c TYPE         Compression: gzip|bzip2|xz (défaut: gzip)
    -e PATTERN      Exclure un pattern (peut être répété)
    -h              Afficher cette aide

EXEMPLES:
    $SCRIPT_NAME -v -o /backups /home/user/docs
    $SCRIPT_NAME -c bzip2 -e "*.tmp" -e "*.log" /var/www
    $SCRIPT_NAME -n /etc  # Simulation

CODES DE RETOUR:
    0    Succès
    1    Erreur de syntaxe
    2    Erreur d'exécution
EOF
    exit "${1:-0}"
}

log() {
    if $VERBOSE; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
    fi
}

error() {
    echo "ERREUR: $*" >&2
    exit 2
}

# ==============================================================================
# PARSING DES OPTIONS
# ==============================================================================

while getopts ":vno:c:e:h" opt; do
    case $opt in
        v)
            VERBOSE=true
            log "Mode verbose activé"
            ;;
        n)
            DRY_RUN=true
            log "Mode dry-run activé"
            ;;
        o)
            OUTPUT_DIR="$OPTARG"
            # Créer le répertoire s'il n'existe pas
            if [[ ! -d "$OUTPUT_DIR" ]]; then
                mkdir -p "$OUTPUT_DIR" || error "Impossible de créer $OUTPUT_DIR"
            fi
            log "Répertoire de sortie: $OUTPUT_DIR"
            ;;
        c)
            case "$OPTARG" in
                gzip|bzip2|xz)
                    COMPRESSION="$OPTARG"
                    log "Compression: $COMPRESSION"
                    ;;
                *)
                    echo "Erreur: compression '$OPTARG' invalide" >&2
                    echo "Valeurs acceptées: gzip, bzip2, xz" >&2
                    exit 1
                    ;;
            esac
            ;;
        e)
            EXCLUDE_PATTERNS+=("$OPTARG")
            log "Exclusion ajoutée: $OPTARG"
            ;;
        h)
            usage 0
            ;;
        :)
            echo "Erreur: l'option -$OPTARG nécessite un argument" >&2
            usage 1
            ;;
        \?)
            echo "Erreur: option -$OPTARG inconnue" >&2
            usage 1
            ;;
    esac
done

# Décaler pour accéder aux répertoires
shift $((OPTIND - 1))

# ==============================================================================
# VALIDATION
# ==============================================================================

if [[ $# -eq 0 ]]; then
    echo "Erreur: au moins un répertoire requis" >&2
    usage 1
fi

# Vérifier que tous les répertoires existent
for dir in "$@"; do
    if [[ ! -d "$dir" ]]; then
        error "Répertoire inexistant: $dir"
    fi
done

# ==============================================================================
# TRAITEMENT PRINCIPAL
# ==============================================================================

log "Début de la sauvegarde"
log "Répertoires à sauvegarder: $*"

for dir in "$@"; do
    dir_name=$(basename "$dir")
    timestamp=$(date +'%Y%m%d_%H%M%S')
    
    case $COMPRESSION in
        gzip)  ext="tar.gz"; tar_opt="-z" ;;
        bzip2) ext="tar.bz2"; tar_opt="-j" ;;
        xz)    ext="tar.xz"; tar_opt="-J" ;;
    esac
    
    archive_name="${dir_name}_${timestamp}.${ext}"
    archive_path="${OUTPUT_DIR}/${archive_name}"
    
    # Construction des options d'exclusion
    exclude_opts=()
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        exclude_opts+=(--exclude="$pattern")
    done
    
    if $DRY_RUN; then
        echo "[DRY-RUN] Création de: $archive_path"
        echo "[DRY-RUN] Commande: tar -c${tar_opt}f \"$archive_path\" ${exclude_opts[*]} -C \"$(dirname "$dir")\" \"$(basename "$dir")\""
    else
        log "Création de l'archive: $archive_name"
        if tar -c${tar_opt}f "$archive_path" "${exclude_opts[@]}" -C "$(dirname "$dir")" "$(basename "$dir")"; then
            size=$(du -h "$archive_path" | cut -f1)
            log "Archive créée avec succès: $archive_name ($size)"
        else
            error "Échec de la création de l'archive pour $dir"
        fi
    fi
done

log "Sauvegarde terminée"
exit 0
```

**Utilisation du script complet :**

```bash
# Simple
./backup.sh /home/user/documents

# Avec options
./backup.sh -v -o /mnt/backups -c bzip2 /etc /var/www

# Avec exclusions
./backup.sh -e "*.log" -e "*.tmp" -e ".git" /home/user/project

# Test en dry-run
./backup.sh -vn -e "cache/*" /var/www
```

---

> [!tip] Résumé des points clés
> 
> - `getopts` parse automatiquement les options courtes (`-a`, `-b`)
> - Ajoutez `:` après une lettre pour indiquer qu'elle nécessite un argument
> - Préfixez l'optstring par `:` pour le mode silencieux (recommandé)
> - Utilisez `$OPTARG` pour récupérer la valeur des arguments
> - Utilisez `shift $((OPTIND - 1))` pour accéder aux arguments positionnels
> - Gérez toujours les cas d'erreur (`:` et `\?`)
> - Validez les arguments critiques (existence de fichiers, format)
> - Fournissez une aide claire avec `-h`