

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

Le nommage des variables est crucial en Bash pour plusieurs raisons :

- **Lisibilité** : Un bon nommage rend le code immédiatement compréhensible
- **Maintenabilité** : Facilite les modifications et la collaboration
- **Éviter les conflits** : Prévient les collisions avec les variables système
- **Débogage** : Simplifie l'identification des problèmes

> [!info] Pourquoi c'est important Contrairement à d'autres langages, Bash n'a pas de système de typage strict ni de portée de variables complexe. Le nommage devient donc votre principal outil d'organisation et de documentation du code.

---

## 📐 Conventions de nommage

### Règles de base

En Bash, les noms de variables doivent respecter ces règles syntaxiques :

```bash
# ✅ Valide
nom_variable=valeur
_variable_privee=valeur
variable123=valeur
VAR_CONSTANTE=valeur

# ❌ Invalide
123variable=valeur        # Ne peut pas commencer par un chiffre
nom-variable=valeur       # Les tirets ne sont pas autorisés
nom variable=valeur       # Les espaces ne sont pas autorisés
nom.variable=valeur       # Les points ne sont pas autorisés
```

> [!warning] Caractères autorisés Seuls les caractères alphanumériques (a-z, A-Z, 0-9) et le underscore (_) sont autorisés. Le nom doit commencer par une lettre ou un underscore.

### Hiérarchie des conventions

|Type de variable|Convention|Exemple|
|---|---|---|
|Variables système|MAJUSCULES|`PATH`, `HOME`, `USER`|
|Constantes utilisateur|MAJUSCULES|`MAX_RETRIES`, `DB_HOST`|
|Variables globales|snake_case minuscules|`user_name`, `config_file`|
|Variables locales|snake_case minuscules|`temp_file`, `loop_counter`|
|Variables temporaires|préfixe `_`|`_tmp`, `_result`|

---

## 🔒 MAJUSCULES pour constantes

Les constantes sont des variables dont la valeur ne doit pas changer durant l'exécution du script.

### Pourquoi utiliser les MAJUSCULES ?

- **Visibilité** : Identifie immédiatement les valeurs qui ne doivent pas être modifiées
- **Convention universelle** : Reconnue dans la plupart des langages
- **Évite les modifications accidentelles** : Signal visuel clair pour les développeurs

### Syntaxe et utilisation

```bash
#!/bin/bash

# Déclaration de constantes en début de script
readonly MAX_RETRIES=3
readonly TIMEOUT_SECONDS=30
readonly API_BASE_URL="https://api.example.com"
readonly LOG_DIR="/var/log/myapp"

# Utilisation
echo "URL de base : $API_BASE_URL"
echo "Timeout configuré : ${TIMEOUT_SECONDS}s"

# Tentative de modification (provoque une erreur)
MAX_RETRIES=5  # bash: MAX_RETRIES: readonly variable
```

> [!tip] Utilisation de `readonly` Combinez les MAJUSCULES avec le mot-clé `readonly` pour garantir l'immutabilité de vos constantes.

### Constantes vs variables d'environnement

```bash
# Variables d'environnement système (déjà en MAJUSCULES)
echo "$HOME"      # /home/user
echo "$PATH"      # /usr/bin:/bin:...
echo "$USER"      # username

# Vos constantes (n'entrent pas en conflit)
readonly APP_NAME="MonApplication"
readonly MAX_CONNECTIONS=100

# Constantes exportées (deviennent des variables d'environnement)
export readonly DATABASE_URL="postgresql://localhost/db"
```

> [!warning] Attention aux collisions Évitez de nommer vos constantes comme les variables système courantes : `PATH`, `HOME`, `IFS`, `PWD`, etc.

### Exemples pratiques

```bash
#!/bin/bash

# Configuration de l'application
readonly APP_VERSION="1.2.3"
readonly APP_NAME="BackupManager"
readonly CONFIG_FILE="/etc/${APP_NAME,,}.conf"  # ${APP_NAME,,} = minuscules

# Limites et seuils
readonly MAX_FILE_SIZE_MB=100
readonly MIN_DISK_SPACE_GB=10
readonly RETRY_DELAY_SECONDS=5

# Codes de sortie
readonly EXIT_SUCCESS=0
readonly EXIT_ERROR_CONFIG=1
readonly EXIT_ERROR_NETWORK=2
readonly EXIT_ERROR_PERMISSION=3

# Utilisation dans le code
if [[ $file_size_mb -gt $MAX_FILE_SIZE_MB ]]; then
    echo "Erreur : fichier trop volumineux (max: ${MAX_FILE_SIZE_MB}MB)"
    exit $EXIT_ERROR_CONFIG
fi
```

---

## 🔽 minuscules pour variables locales

Les variables locales sont des variables à portée limitée, généralement utilisées dans des fonctions.

### Pourquoi utiliser les minuscules ?

- **Distinction claire** : Différencie immédiatement les variables locales des constantes
- **Portée limitée** : Indique visuellement que la variable a une durée de vie courte
- **Évite les conflits** : Réduit les risques de collision avec les variables système

### Syntaxe avec `local`

```bash
#!/bin/bash

# Variable globale
user_count=0

calculate_discount() {
    # Variables locales (visibles uniquement dans cette fonction)
    local base_price=$1
    local discount_rate=0.15
    local final_price
    
    final_price=$(echo "$base_price * (1 - $discount_rate)" | bc)
    echo "$final_price"
}

# Utilisation
price=$(calculate_discount 100)
echo "Prix final : $price"

# discount_rate n'existe pas ici
echo "$discount_rate"  # Affiche : (vide)
```

> [!info] Le mot-clé `local` `local` limite la portée d'une variable à la fonction où elle est déclarée. Sans `local`, toutes les variables sont globales en Bash.

### Variables globales en minuscules

```bash
#!/bin/bash

# Variables globales du script (minuscules avec snake_case)
script_dir=$(dirname "$0")
log_file="/var/log/app.log"
user_home="$HOME"
temp_dir="/tmp/myapp_$$"  # $$ = PID du script

process_file() {
    local input_file=$1
    local line_count
    
    # Accès aux variables globales
    echo "Traitement depuis : $script_dir"
    
    # Variable locale
    line_count=$(wc -l < "$input_file")
    echo "Nombre de lignes : $line_count"
}

# Nettoyage
cleanup() {
    rm -rf "$temp_dir"
}

trap cleanup EXIT
```

### Bonnes pratiques de portée

```bash
#!/bin/bash

# ✅ Bon : variables locales bien définies
find_user() {
    local username=$1
    local user_id
    local user_group
    
    user_id=$(id -u "$username" 2>/dev/null)
    user_group=$(id -gn "$username" 2>/dev/null)
    
    if [[ -n $user_id ]]; then
        echo "User: $username (ID: $user_id, Group: $user_group)"
        return 0
    fi
    return 1
}

# ❌ Mauvais : pollution de l'espace global
find_user_bad() {
    username=$1        # Variable globale !
    user_id=$(id -u "$username" 2>/dev/null)
    # username reste accessible après la fonction
}
```

> [!tip] Toujours utiliser `local` Prenez l'habitude de déclarer toutes les variables de fonction avec `local`. Cela évite les bugs difficiles à détecter liés aux variables globales.

---

## 🐍 snake_case vs camelCase

Le choix de la convention de nommage impacte la lisibilité et la cohérence du code.

### snake_case (recommandé en Bash)

Le snake_case utilise des underscores pour séparer les mots, tous en minuscules.

```bash
#!/bin/bash

# snake_case pour les variables
user_full_name="Jean Dupont"
database_connection_string="postgresql://localhost/mydb"
max_retry_count=3
is_debug_enabled=false

# Facile à lire dans les expressions
if [[ $is_debug_enabled == true ]]; then
    echo "Mode debug activé"
fi

# Cohérent avec les variables système
echo "$HOME"          # système
echo "$user_home"     # votre variable
```

**Avantages du snake_case :**

- Convention standard dans l'écosystème Unix/Linux
- Compatible avec les variables shell existantes
- Bonne lisibilité, même pour les noms longs
- Pas de confusion avec la casse

### camelCase (moins courant en Bash)

Le camelCase met en majuscule la première lettre de chaque mot (sauf le premier).

```bash
#!/bin/bash

# camelCase pour les variables
userFullName="Jean Dupont"
databaseConnectionString="postgresql://localhost/mydb"
maxRetryCount=3
isDebugEnabled=false

# Lecture dans les expressions
if [[ $isDebugEnabled == true ]]; then
    echo "Mode debug activé"
fi
```

**Inconvénients du camelCase en Bash :**

- Moins courant dans les scripts shell
- Peut créer de la confusion avec les variables système (en MAJUSCULES)
- Moins lisible dans certains contextes (variables longues)

### Tableau comparatif

|Critère|snake_case|camelCase|
|---|---|---|
|Lisibilité|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|
|Convention Unix/Linux|⭐⭐⭐⭐⭐|⭐⭐|
|Compatibilité système|⭐⭐⭐⭐⭐|⭐⭐⭐|
|Usage courant en Bash|⭐⭐⭐⭐⭐|⭐⭐|

> [!tip] Recommandation Privilégiez le **snake_case** pour vos scripts Bash. C'est la convention la plus répandue et la mieux adaptée à l'écosystème shell.

### Cohérence dans un projet

```bash
#!/bin/bash

# ✅ Bon : convention cohérente (snake_case)
user_name="alice"
user_email="alice@example.com"
user_home_dir="/home/alice"
is_user_active=true

# ❌ Mauvais : mélange de conventions
user_name="alice"
userEmail="alice@example.com"     # camelCase
USER_HOME_DIR="/home/alice"       # MAJUSCULES
is-user-active=true               # kebab-case (invalide !)
```

> [!warning] Choisissez une convention et respectez-la Le mélange de conventions dans un même script ou projet rend le code difficile à maintenir et source d'erreurs.

---

## 📝 Noms descriptifs

Un bon nom de variable doit exprimer clairement son contenu et son usage.

### Principes de nommage descriptif

**1. Privilégier la clarté à la brièveté**

```bash
# ❌ Mauvais : noms trop courts, peu clairs
f="/tmp/data"
n=10
d=$(date)
u="alice"

# ✅ Bon : noms descriptifs
temp_file="/tmp/data"
max_attempts=10
current_date=$(date)
username="alice"
```

**2. Utiliser des noms qui décrivent le contenu**

```bash
# ❌ Mauvais : noms génériques
data="192.168.1.1"
value=true
result="/var/log"

# ✅ Bon : noms spécifiques
server_ip="192.168.1.1"
is_authenticated=true
log_directory="/var/log"
```

**3. Inclure le type dans le nom si nécessaire**

```bash
# Pour les booléens : is_, has_, can_, should_
is_valid=true
has_permission=false
can_write=true
should_retry=false

# Pour les compteurs : count, number, total
file_count=0
user_number=42
total_lines=1000

# Pour les listes/tableaux : suffixe _list, _array
user_list=("alice" "bob" "charlie")
error_codes=(1 2 3 4 5)

# Pour les chemins : suffixe _dir, _file, _path
config_file="/etc/app.conf"
backup_dir="/var/backups"
script_path="$0"
```

### Contexte et verbosité

```bash
#!/bin/bash

# ✅ Bon : noms adaptés au contexte
check_disk_space() {
    local partition=$1
    local threshold_percent=90
    local current_usage
    
    current_usage=$(df -h "$partition" | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [[ $current_usage -gt $threshold_percent ]]; then
        echo "Attention : partition $partition à ${current_usage}%"
        return 1
    fi
    return 0
}

# Dans une boucle simple : noms courts acceptables
for file in *.txt; do
    echo "Traitement : $file"
done

# Mais pour un traitement complexe : noms descriptifs
for config_file in /etc/app/*.conf; do
    backup_filename="${config_file}.backup.$(date +%Y%m%d)"
    validation_result=$(validate_config "$config_file")
    
    if [[ $validation_result == "ok" ]]; then
        cp "$config_file" "$backup_filename"
    fi
done
```

### Conventions spécifiques

**Variables booléennes**

```bash
# Préfixes recommandés : is_, has_, can_, should_, will_, need_
is_running=true
is_file_exists=false
has_root_access=true
has_network_connection=false
can_execute=true
should_backup=false
will_restart=true
needs_update=false
```

**Variables temporaires**

```bash
# Préfixe underscore pour indiquer un usage temporaire
_tmp_file=$(mktemp)
_backup_date=$(date +%Y%m%d)
_old_value="$current_value"

# Nettoyage à la fin
cleanup() {
    rm -f "$_tmp_file"
}
trap cleanup EXIT
```

**Variables de configuration**

```bash
# Suffixe _config, _setting, ou préfixe config_
readonly DATABASE_CONFIG="/etc/db.conf"
readonly max_connections_setting=100
readonly config_reload_interval=300

# Ou regrouper avec un préfixe commun
readonly db_host="localhost"
readonly db_port=5432
readonly db_name="myapp"
readonly db_user="admin"
```

### Exemples comparatifs

```bash
#!/bin/bash

# ❌ Mauvais : noms peu descriptifs
f="/etc/hosts"
c=0
t=$(mktemp)
r=1

while read line; do
    if [[ -n $line ]]; then
        c=$((c + 1))
        echo "$line" >> "$t"
    fi
done < "$f"

echo "Total: $c"
exit $r

# ✅ Bon : noms descriptifs et contextuels
hosts_file="/etc/hosts"
valid_entry_count=0
temp_filtered_file=$(mktemp)
exit_code_success=0

while read -r host_entry; do
    if [[ -n $host_entry ]]; then
        valid_entry_count=$((valid_entry_count + 1))
        echo "$host_entry" >> "$temp_filtered_file"
    fi
done < "$hosts_file"

echo "Nombre d'entrées valides : $valid_entry_count"
exit $exit_code_success
```

> [!tip] Règle d'or Si vous devez ajouter un commentaire pour expliquer ce que contient une variable, c'est que son nom n'est pas assez descriptif.

---

## ⚠️ Pièges courants

### 1. Variables non initialisées

```bash
# ❌ Danger : variable non initialisée
if [[ $user_confirmed == "yes" ]]; then
    delete_files
fi
# Si user_confirmed n'a jamais été défini, le test échoue silencieusement

# ✅ Solution : toujours initialiser
user_confirmed=""
# ou vérifier l'existence
if [[ -n ${user_confirmed:-} && $user_confirmed == "yes" ]]; then
    delete_files
fi
```

### 2. Collision avec les variables système

```bash
# ❌ Très mauvais : écrase une variable système
PATH="/usr/local/bin"  # Perd tout le reste du PATH !

# ✅ Bon : préfixe personnalisé
app_path="/usr/local/bin"
# Ou ajout au PATH existant
PATH="/usr/local/bin:$PATH"
```

> [!warning] Variables système à ne JAMAIS écraser `PATH`, `HOME`, `USER`, `SHELL`, `IFS`, `PWD`, `OLDPWD`, `LANG`, `LC_*`, `TERM`

### 3. Espaces dans les noms

```bash
# ❌ Invalide syntaxiquement
my variable="valeur"  # bash: my: command not found

# ✅ Correct
my_variable="valeur"
```

### 4. Noms trop similaires

```bash
# ❌ Confus : noms trop proches
user_file="/tmp/users.txt"
users_file="/tmp/users_list.txt"
user_files="/tmp/archives/"
# Lequel utiliser ? Confusion garantie !

# ✅ Clair : noms distincts
current_user_file="/tmp/active_user.txt"
all_users_list="/tmp/complete_users.txt"
user_archive_dir="/tmp/archives/"
```

### 5. Caractères spéciaux

```bash
# ❌ Invalide
user-name="alice"        # Le tiret est interprété comme soustraction
user.email="a@b.com"     # Le point n'est pas autorisé
user@host="data"         # @ n'est pas autorisé

# ✅ Valide
user_name="alice"
user_email="a@b.com"
user_at_host="data"
```

### 6. Variables globales cachées

```bash
#!/bin/bash

# ❌ Dangereux : fonction qui modifie une globale
counter=0

increment() {
    counter=$((counter + 1))  # Modifie la globale !
}

increment
echo $counter  # 1

# ✅ Meilleur : retourne la valeur
counter=0

increment() {
    local value=$1
    echo $((value + 1))
}

counter=$(increment $counter)
echo $counter  # 1
```

### 7. Cas sensible et cohérence

```bash
# ❌ Incohérent
UserName="alice"
username="bob"
USERNAME="charlie"
# Trois variables différentes !

# ✅ Cohérent
user_name="alice"
admin_name="bob"
default_username="charlie"
```

> [!warning] Bash est sensible à la casse `variable`, `Variable`, et `VARIABLE` sont trois variables distinctes. Maintenez une cohérence stricte dans votre casse.

---

## 🎯 Récapitulatif des bonnes pratiques

|Règle|À faire ✅|À éviter ❌|
|---|---|---|
|**Constantes**|`MAX_RETRIES=3` + `readonly`|`maxRetries=3`|
|**Variables locales**|`local user_name="alice"`|`UserName="alice"` (globale)|
|**Convention**|`snake_case` cohérent|Mélange de conventions|
|**Descriptif**|`backup_directory`|`dir`, `d`, `temp`|
|**Booléens**|`is_valid=true`|`valid=1`|
|**Système**|`app_path="/bin"`|`PATH="/bin"`|
|**Portée**|`local` dans fonctions|Tout en global|
|**Initialisation**|`count=0` dès le début|Variable non initialisée|

> [!tip] Astuce finale Créez un guide de style pour votre équipe ou projet et documentez vos conventions. La cohérence est plus importante que la convention choisie elle-même.