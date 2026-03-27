

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

Les mécanismes de valeurs par défaut en Bash permettent de gérer élégamment les variables non définies ou vides. Ces opérateurs sont essentiels pour rendre vos scripts robustes et éviter les comportements imprévus lorsqu'une variable n'a pas la valeur attendue.

> [!info] Pourquoi c'est important
> 
> - Évite les erreurs dues aux variables non initialisées
> - Rend le code plus lisible et maintenable
> - Permet de définir des configurations par défaut
> - Facilite la gestion des paramètres optionnels

---

## Les quatre syntaxes principales

### `${var:-default}` - Valeur par défaut

**Utilisation** : Retourne la valeur par défaut si la variable est vide ou non définie, **sans modifier** la variable originale.

#### Syntaxe

```bash
${variable:-valeur_par_defaut}
```

#### Explication détaillée

- Si `variable` est définie et non vide → retourne sa valeur
- Si `variable` est vide ou non définie → retourne `valeur_par_defaut`
- La variable `variable` reste inchangée dans tous les cas

#### Exemples pratiques

```bash
# Variable non définie
echo "${nom:-Anonyme}"  # Affiche: Anonyme
echo "$nom"             # Affiche: (rien, variable toujours vide)

# Variable définie
nom="Alice"
echo "${nom:-Anonyme}"  # Affiche: Alice

# Variable vide
nom=""
echo "${nom:-Anonyme}"  # Affiche: Anonyme
```

> [!example] Cas d'usage typique
> 
> ```bash
> # Configuration avec valeur par défaut
> port="${PORT:-8080}"
> host="${HOST:-localhost}"
> 
> echo "Serveur démarré sur $host:$port"
> # Si PORT et HOST ne sont pas définis, utilise localhost:8080
> ```

#### Quand l'utiliser

- Pour fournir des valeurs de secours temporaires
- Dans des commandes où vous ne voulez pas modifier la variable
- Pour des configurations avec des défauts raisonnables

---

### `${var:=default}` - Assignation par défaut

**Utilisation** : Assigne la valeur par défaut à la variable si elle est vide ou non définie, puis retourne cette valeur.

#### Syntaxe

```bash
${variable:=valeur_par_defaut}
```

#### Explication détaillée

- Si `variable` est définie et non vide → retourne sa valeur
- Si `variable` est vide ou non définie → l'assigne à `valeur_par_defaut` ET retourne cette valeur
- La variable est **modifiée définitivement** si elle était vide/non définie

#### Exemples pratiques

```bash
# Variable non définie
echo "${nom:=Anonyme}"  # Affiche: Anonyme
echo "$nom"             # Affiche: Anonyme (la variable a été assignée)

# Variable déjà définie
nom="Alice"
echo "${nom:=Anonyme}"  # Affiche: Alice (pas de modification)

# Variable vide
nom=""
echo "${nom:=Anonyme}"  # Affiche: Anonyme (la variable est maintenant "Anonyme")
```

> [!example] Cas d'usage typique
> 
> ```bash
> # Initialisation avec persistance
> : ${CONFIG_FILE:=/etc/app/config.conf}
> : ${LOG_LEVEL:=INFO}
> 
> # Les variables sont maintenant définies pour tout le script
> echo "Configuration chargée depuis: $CONFIG_FILE"
> echo "Niveau de log: $LOG_LEVEL"
> ```

> [!tip] Astuce avec les deux-points Le `:` (commande nulle) est souvent utilisé pour assigner sans afficher :
> 
> ```bash
> : ${VAR:=default}  # Assigne sans output
> ```

#### Quand l'utiliser

- Pour initialiser des variables de configuration au début d'un script
- Quand vous voulez que la valeur par défaut persiste
- Pour des variables qui seront réutilisées plusieurs fois

---

### `${var:?message}` - Erreur si vide

**Utilisation** : Affiche un message d'erreur et termine le script si la variable est vide ou non définie.

#### Syntaxe

```bash
${variable:?message_erreur}
```

#### Explication détaillée

- Si `variable` est définie et non vide → retourne sa valeur
- Si `variable` est vide ou non définie → affiche le message d'erreur sur stderr et termine le script avec le code 1
- C'est un mécanisme de validation stricte

#### Exemples pratiques

```bash
# Variable non définie
echo "${utilisateur:?Erreur: utilisateur requis}"
# Affiche: bash: utilisateur: Erreur: utilisateur requis
# Le script s'arrête immédiatement

# Variable définie
utilisateur="alice"
echo "${utilisateur:?Erreur: utilisateur requis}"
# Affiche: alice (pas d'erreur)

# Sans message personnalisé
echo "${port:?}"
# Affiche: bash: port: parameter null or not set
```

> [!example] Cas d'usage typique
> 
> ```bash
> #!/bin/bash
> 
> # Validation des paramètres obligatoires
> DATABASE="${1:?Erreur: Nom de la base de données requis}"
> USERNAME="${2:?Erreur: Nom d'utilisateur requis}"
> 
> # Si un paramètre manque, le script s'arrête immédiatement
> echo "Connexion à $DATABASE avec l'utilisateur $USERNAME"
> ```

> [!warning] Attention
> 
> - Le script se termine automatiquement (exit 1)
> - Ne peut pas être intercepté avec un simple `if`
> - Utilisez un `set +e` si vous voulez capturer l'erreur

#### Quand l'utiliser

- Pour valider les paramètres obligatoires d'un script
- Pour les variables critiques qui ne doivent jamais être vides
- Dans les scripts où un échec précoce est préférable à un comportement incorrect

---

### `${var:+alternative}` - Valeur alternative

**Utilisation** : Retourne une valeur alternative si la variable est définie et non vide, sinon retourne rien.

#### Syntaxe

```bash
${variable:+valeur_alternative}
```

#### Explication détaillée

- Si `variable` est définie et non vide → retourne `valeur_alternative`
- Si `variable` est vide ou non définie → retourne rien (chaîne vide)
- C'est l'inverse logique de `:-`

#### Exemples pratiques

```bash
# Variable définie
debug="true"
echo "Mode${debug:+ DEBUG activé}"  # Affiche: Mode DEBUG activé

# Variable non définie
unset debug
echo "Mode${debug:+ DEBUG activé}"  # Affiche: Mode

# Utilisation avec des flags
verbose=""
commande ls ${verbose:+-v}  # Sans -v si verbose est vide
verbose="yes"
commande ls ${verbose:+-v}  # Avec -v si verbose est défini
```

> [!example] Cas d'usage typique
> 
> ```bash
> # Construction conditionnelle de commandes
> VERBOSE=""
> DEBUG="true"
> 
> # Exécution avec options conditionnelles
> ./app \
>   ${VERBOSE:+--verbose} \
>   ${DEBUG:+--debug} \
>   --output result.txt
> 
> # Si DEBUG est défini, la commande devient:
> # ./app --debug --output result.txt
> ```

> [!example] Affichage conditionnel
> 
> ```bash
> # Messages conditionnels
> WARNING="Attention aux erreurs"
> SUCCESS="Opération réussie"
> 
> echo "Résultat: ${SUCCESS:+✓ $SUCCESS}${WARNING:+ ⚠ $WARNING}"
> ```

#### Quand l'utiliser

- Pour ajouter des options conditionnelles à une commande
- Pour construire des messages dynamiques
- Pour activer des fonctionnalités optionnelles
- Dans les wrappers de commandes

---

## Différence avec/sans deux-points

La présence ou l'absence des deux-points (`:`) change le comportement face aux variables vides.

### Comparaison des comportements

|Syntaxe|Variable non définie|Variable vide (`""`)|Variable définie|
|---|---|---|---|
|`${var-default}`|Utilise default|Utilise valeur vide|Utilise valeur|
|`${var:-default}`|Utilise default|Utilise default|Utilise valeur|
|`${var=default}`|Assigne default|Utilise valeur vide|Utilise valeur|
|`${var:=default}`|Assigne default|Assigne default|Utilise valeur|
|`${var?error}`|Erreur|Utilise valeur vide|Utilise valeur|
|`${var:?error}`|Erreur|Erreur|Utilise valeur|
|`${var+alt}`|Retourne vide|Retourne alt|Retourne alt|
|`${var:+alt}`|Retourne vide|Retourne vide|Retourne alt|

### Démonstration pratique

```bash
# Sans deux-points (:-) teste uniquement si non définie
unset var
echo "${var-default}"   # Affiche: default

var=""
echo "${var-default}"   # Affiche: (rien - variable vide mais définie)

# Avec deux-points (:) teste si non définie OU vide
unset var
echo "${var:-default}"  # Affiche: default

var=""
echo "${var:-default}"  # Affiche: default (traite vide comme non défini)
```

> [!tip] Règle mnémotechnique
> 
> - **Avec `:`** → traite vide et non-défini de la même façon
> - **Sans `:`** → distingue vide de non-défini

> [!warning] Recommandation Dans la plupart des cas, utilisez la version **avec deux-points** (`:`) car une variable vide est rarement intentionnelle et devrait être traitée comme non définie.

---

## Cas d'usage pratiques

### 1. Configuration d'application

```bash
#!/bin/bash

# Initialisation avec valeurs par défaut
: ${APP_ENV:=production}
: ${APP_PORT:=3000}
: ${APP_HOST:=0.0.0.0}
: ${LOG_FILE:=/var/log/app.log}
: ${MAX_CONNECTIONS:=100}

echo "Démarrage de l'application"
echo "  Environnement: $APP_ENV"
echo "  Écoute sur: $APP_HOST:$APP_PORT"
echo "  Log: $LOG_FILE"
echo "  Connexions max: $MAX_CONNECTIONS"
```

### 2. Validation de paramètres

```bash
#!/bin/bash

# Paramètres obligatoires
SOURCE_DIR="${1:?Erreur: répertoire source requis}"
DEST_DIR="${2:?Erreur: répertoire destination requis}"

# Paramètres optionnels avec défauts
COMPRESSION="${3:-gzip}"
VERBOSE="${4:-false}"

echo "Sauvegarde de $SOURCE_DIR vers $DEST_DIR"
echo "Compression: $COMPRESSION"
```

### 3. Construction de commandes dynamiques

```bash
#!/bin/bash

VERBOSE=""
DRY_RUN="true"
FORCE=""

# Construction de la commande avec options conditionnelles
rsync \
  -avz \
  ${VERBOSE:+--verbose} \
  ${DRY_RUN:+--dry-run} \
  ${FORCE:+--force} \
  source/ destination/
```

### 4. Messages conditionnels

```bash
#!/bin/bash

SUCCESS=""
WARNING="Attention: mode test"
ERROR=""

echo "${SUCCESS:+✓ Succès}${WARNING:+⚠ $WARNING}${ERROR:+✗ $ERROR}"
```

### 5. Gestion de chemins

```bash
#!/bin/bash

# Utilise XDG_CONFIG_HOME ou ~/.config par défaut
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/myapp"

# Utilise XDG_DATA_HOME ou ~/.local/share par défaut
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/myapp"

# Création des répertoires si nécessaires
mkdir -p "$CONFIG_DIR" "$DATA_DIR"
```

---

## Pièges courants

### 1. Oublier les accolades

```bash
# ❌ INCORRECT
echo $var:-default  # Essaie d'exécuter une commande ":-default"

# ✅ CORRECT
echo ${var:-default}
```

### 2. Variables avec espaces

```bash
# ❌ Problème potentiel
file=${1:-mon fichier.txt}
cat $file  # Erreur: cat essaie d'ouvrir "mon" et "fichier.txt"

# ✅ CORRECT
file="${1:-mon fichier.txt}"
cat "$file"  # Correctement quoté
```

### 3. Utiliser `:=` dans une sous-shell

```bash
# ❌ N'affecte pas la variable du shell parent
echo "${var:=default}"  # var est assigné dans la sous-shell
echo "$var"             # var est vide dans le shell parent

# ✅ CORRECT
: ${var:=default}  # Assignation dans le shell courant
echo "$var"        # var contient "default"
```

### 4. Confusion entre `-` et `:-`

```bash
# Variable vide
empty=""

# Comportement différent
echo "${empty-default}"   # Affiche: (rien)
echo "${empty:-default}"  # Affiche: default

# Préférez toujours :- pour plus de sécurité
```

### 5. Erreur avec `${var:?}` non capturée

```bash
# ❌ Le script s'arrête brutalement
result=$(echo "${missing:?Variable requise}")
echo "Cette ligne ne s'exécute jamais"

# ✅ CORRECT - Valider avant
if [[ -z "$missing" ]]; then
  echo "Erreur: Variable requise" >&2
  exit 1
fi
result=$(echo "$missing")
```

### 6. Valeurs par défaut avec commandes

```bash
# ❌ La commande s'exécute même si la variable est définie
file="${INPUT:-$(find . -name "*.txt" | head -1)}"

# ✅ CORRECT - La commande ne s'exécute que si nécessaire
if [[ -z "$INPUT" ]]; then
  file=$(find . -name "*.txt" | head -1)
else
  file="$INPUT"
fi
```

---

## Astuces avancées

### 1. Valeurs par défaut imbriquées

```bash
# Plusieurs niveaux de défaut
port="${PORT:-${DEFAULT_PORT:-8080}}"

# Cherche dans plusieurs variables
config="${USER_CONFIG:-${SYSTEM_CONFIG:-/etc/app.conf}}"
```

### 2. Calculs dans les valeurs par défaut

```bash
# Expression arithmétique
threads="${THREADS:-$(($(nproc) * 2))}"

# Sous-commande
home="${HOME:-$(eval echo ~$USER)}"
```

### 3. Tableaux avec valeurs par défaut

```bash
# Attention: syntaxe différente pour les tableaux
declare -a colors=("${COLORS[@]}")
[[ ${#colors[@]} -eq 0 ]] && colors=("rouge" "vert" "bleu")

# Ou avec une fonction helper
default_if_empty() {
  local -n arr=$1
  shift
  [[ ${#arr[@]} -eq 0 ]] && arr=("$@")
}

declare -a my_array
default_if_empty my_array "valeur1" "valeur2"
```

### 4. Validation de format

```bash
# Valider et fournir un défaut
email="${EMAIL:-${USER}@localhost}"

# Validation avec pattern
port="${PORT:-8080}"
[[ ! "$port" =~ ^[0-9]+$ ]] && port=8080
```

### 5. Valeurs par défaut avec fonctions

```bash
# Fonction pour obtenir une valeur par défaut complexe
get_default_dir() {
  if [[ -d "/opt/app" ]]; then
    echo "/opt/app"
  elif [[ -d "$HOME/app" ]]; then
    echo "$HOME/app"
  else
    echo "/tmp/app"
  fi
}

APP_DIR="${APP_DIR:-$(get_default_dir)}"
```

### 6. Logging des valeurs par défaut

```bash
# Fonction helper avec logging
default_with_log() {
  local varname=$1
  local default=$2
  local current_value="${!varname}"
  
  if [[ -z "$current_value" ]]; then
    eval "$varname=\"$default\""
    echo "[INFO] $varname non défini, utilisation de: $default" >&2
  fi
}

default_with_log PORT 8080
default_with_log HOST "localhost"
```

### 7. Combinaison des opérateurs

```bash
# Valider puis assigner avec défaut
: ${USER:?Utilisateur requis}
: ${HOME:=/home/$USER}

# Alternative avec défaut puis validation
: ${CONFIG:=/etc/app.conf}
[[ ! -f "$CONFIG" ]] && { echo "Config non trouvée: $CONFIG" >&2; exit 1; }
```

### 8. Pattern pour scripts configurables

```bash
#!/bin/bash

# Chargement de fichier de config optionnel
[[ -f ~/.myapprc ]] && source ~/.myapprc
[[ -f ./.myapprc ]] && source ./.myapprc

# Puis valeurs par défaut pour les variables non définies
: ${DEBUG:=false}
: ${VERBOSE:=false}
: ${LOG_LEVEL:=INFO}
: ${OUTPUT_DIR:=./output}

# Les valeurs peuvent venir de:
# 1. Variables d'environnement
# 2. Fichiers de config
# 3. Valeurs par défaut ci-dessus
```

---

> [!tip] Résumé rapide
> 
> - `${var:-default}` → Utilise default si vide, ne modifie pas var
> - `${var:=default}` → Assigne default si vide, modifie var
> - `${var:?message}` → Erreur fatale si vide avec message
> - `${var:+alternative}` → Utilise alternative si défini
> 
> **Préférez toujours la version avec `:` pour traiter vide comme non-défini**