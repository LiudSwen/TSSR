

## Table des matières

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

La documentation d'un script Bash est **essentielle** pour assurer sa maintenabilité, sa compréhension par d'autres développeurs (ou par vous-même dans 6 mois), et son utilisation correcte. Un script bien documenté est un script professionnel qui inspire confiance.

> [!info] Pourquoi documenter ?
> 
> - **Maintenabilité** : Facilite les modifications futures
> - **Collaboration** : Permet à d'autres de comprendre et utiliser votre code
> - **Mémoire** : Vous aide à vous rappeler de vos choix de conception
> - **Professionnalisme** : Marque d'un code de qualité

---

## 📝 En-tête de script

L'en-tête est la **carte d'identité** de votre script. Il doit apparaître en tout début de fichier, juste après le shebang.

### Structure recommandée

```bash
#!/bin/bash

#############################################################################
# Script Name   : backup_database.sh
# Description   : Sauvegarde automatique de bases de données MySQL
# Author        : Jean Dupont
# Email         : jean.dupont@example.com
# Date Created  : 2024-01-15
# Last Modified : 2024-03-20
# Version       : 1.2.3
# Usage         : ./backup_database.sh [OPTIONS] DATABASE_NAME
# License       : MIT
# Repository    : https://github.com/user/repo
#############################################################################
```

### Éléments clés

|Élément|Description|Obligatoire|
|---|---|---|
|**Script Name**|Nom du fichier script|✅ Oui|
|**Description**|Objectif principal en une ligne|✅ Oui|
|**Author**|Nom du créateur|✅ Oui|
|**Date Created**|Date de création initiale|✅ Oui|
|**Last Modified**|Dernière modification|⚠️ Recommandé|
|**Version**|Numéro de version (semver)|⚠️ Recommandé|
|**Usage**|Syntaxe d'utilisation rapide|✅ Oui|
|**Email**|Contact du mainteneur|⭕ Optionnel|
|**License**|Type de licence|⭕ Optionnel|
|**Repository**|Lien vers le dépôt|⭕ Optionnel|

> [!tip] Versionning sémantique Utilisez le format MAJOR.MINOR.PATCH :
> 
> - **MAJOR** : Changements incompatibles
> - **MINOR** : Nouvelles fonctionnalités compatibles
> - **PATCH** : Corrections de bugs

### En-tête minimal

Pour les scripts simples, un en-tête allégé suffit :

```bash
#!/bin/bash
#
# backup_database.sh - Sauvegarde automatique des bases MySQL
# Auteur: Jean Dupont - 2024-01-15
# Usage: ./backup_database.sh DATABASE_NAME
#
```

---

## 💬 Commentaires explicatifs

Les commentaires expliquent **pourquoi** le code fait ce qu'il fait, pas **ce qu'il** fait (le code doit être suffisamment clair pour ça).

### Principes directeurs

> [!warning] Quand commenter ?
> 
> - **OUI** : Logique complexe, décisions non évidentes, cas particuliers
> - **NON** : Code évident, redondance avec les noms de variables
> - **JAMAIS** : Commentaires obsolètes ou trompeurs

### Exemples de bons commentaires

```bash
# Utilise un timeout de 30s car certaines BDD sont lentes à répondre
timeout 30 mysql -e "SHOW DATABASES"

# Conversion nécessaire : date ISO -> timestamp Unix pour compatibilité
timestamp=$(date -d "$iso_date" +%s)

# On ignore les tables système (_sys, _log) car non critiques
tables=$(mysql -e "SHOW TABLES" | grep -v "^_")

# Workaround : sleep nécessaire pour éviter un race condition
# avec le processus parent (bug #1234)
sleep 0.5
```

### Exemples de mauvais commentaires

```bash
# ❌ Redondant
# Assigne la valeur 5 à la variable count
count=5

# ❌ Évident
# Boucle sur les fichiers
for file in *.txt; do

# ❌ Obsolète (le code a changé mais pas le commentaire)
# Supprime les fichiers .log
rm -f *.bak  # ← Le commentaire ne correspond plus !

# ❌ Commente du code inutilisé (supprimez-le plutôt)
# old_backup_function() {
#     echo "Ancienne méthode"
# }
```

### Commentaires de section

Pour structurer les scripts longs :

```bash
#==============================================================================
# CONFIGURATION
#==============================================================================

DB_HOST="localhost"
DB_USER="backup_user"

#==============================================================================
# FONCTIONS UTILITAIRES
#==============================================================================

log_info() { ... }
log_error() { ... }

#==============================================================================
# LOGIQUE PRINCIPALE
#==============================================================================

main() { ... }
```

### Commentaires TODO

```bash
# TODO: Ajouter la gestion des bases PostgreSQL
# FIXME: Le parsing échoue avec les noms contenant des espaces
# HACK: Solution temporaire en attendant le correctif upstream
# NOTE: Cette fonction sera dépréciée en v2.0
# XXX: Code dangereux, à revoir absolument
```

> [!tip] Convention Utilisez des tags standardisés (TODO, FIXME, HACK, NOTE, XXX) pour faciliter la recherche avec `grep -r "TODO:" .`

---

## 📖 Documentation des fonctions

Chaque fonction non triviale doit être documentée selon un format structuré.

### Format standard

```bash
#------------------------------------------------------------------------------
# Fonction: backup_database
# Description: Crée une sauvegarde compressée d'une base de données MySQL
# 
# Arguments:
#   $1 - database_name (string, requis): Nom de la base à sauvegarder
#   $2 - output_dir (string, optionnel): Répertoire de destination
#        Par défaut: /var/backups/mysql
#
# Retour:
#   0 - Succès
#   1 - Erreur de connexion à la base
#   2 - Erreur d'écriture du fichier
#   3 - Base de données inexistante
#
# Variables globales:
#   DB_HOST - Lecture: Serveur MySQL à contacter
#   DB_USER - Lecture: Utilisateur MySQL
#   BACKUP_COUNT - Modification: Incrémenté à chaque sauvegarde
#
# Exemple:
#   backup_database "myapp_prod" "/backup/daily"
#   backup_database "testdb"
#
# Note:
#   Nécessite mysqldump >= 5.7 et gzip installés
#------------------------------------------------------------------------------
backup_database() {
    local database_name="${1:?Database name required}"
    local output_dir="${2:-/var/backups/mysql}"
    
    # ... implémentation ...
}
```

### Sections de la documentation

|Section|Description|Obligatoire|
|---|---|---|
|**Fonction**|Nom de la fonction|✅ Oui|
|**Description**|Objectif en 1-2 phrases|✅ Oui|
|**Arguments**|Chaque paramètre détaillé|✅ Si paramètres|
|**Retour**|Codes de retour possibles|✅ Oui|
|**Variables globales**|Variables lues/modifiées|⚠️ Si applicable|
|**Exemple**|Un ou plusieurs exemples|⚠️ Recommandé|
|**Note**|Prérequis, limitations|⭕ Si nécessaire|

### Format condensé

Pour les fonctions simples :

```bash
# validate_email: Vérifie qu'une chaîne est un email valide
# Usage: validate_email "user@domain.com"
# Retour: 0 si valide, 1 sinon
validate_email() {
    [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}
```

### Documentation des arguments

Soyez **précis** sur les types et contraintes :

```bash
# Arguments:
#   $1 - port (integer, requis): Port TCP entre 1 et 65535
#   $2 - timeout (integer, optionnel): Délai en secondes (défaut: 30)
#   $3 - protocol (string, optionnel): 'tcp' ou 'udp' (défaut: tcp)
#   $4 - retry (boolean, optionnel): true/false (défaut: false)
```

> [!example] Astuce pour les valeurs par défaut Indiquez toujours la valeur par défaut des paramètres optionnels dans la documentation

---

## 🎬 Exemples d'utilisation

Les exemples d'utilisation sont **cruciaux** : ils montrent concrètement comment utiliser le script ou la fonction.

### Exemples simples

```bash
#------------------------------------------------------------------------------
# Exemples d'utilisation:
#
# 1. Sauvegarde basique:
#    $ ./backup_database.sh production_db
#
# 2. Sauvegarde avec destination personnalisée:
#    $ ./backup_database.sh production_db /mnt/nas/backups
#
# 3. Mode verbose avec logging:
#    $ ./backup_database.sh -v --log=/var/log/backup.log production_db
#
# 4. Sauvegarde multiple:
#    $ for db in db1 db2 db3; do ./backup_database.sh "$db"; done
#------------------------------------------------------------------------------
```

### Exemples avancés avec cas d'usage

```bash
#------------------------------------------------------------------------------
# Cas d'usage typiques:
#
# A. Sauvegarde quotidienne automatisée (cron):
#    # Dans /etc/cron.daily/mysql-backup
#    #!/bin/bash
#    /opt/scripts/backup_database.sh --compress=gzip --retention=7 myapp_db
#
# B. Sauvegarde avant migration:
#    $ ./backup_database.sh --format=sql --no-compress legacy_db
#    $ # Migration...
#    $ ./restore_database.sh legacy_db backup_YYYYMMDD.sql
#
# C. Sauvegarde de toutes les bases:
#    $ mysql -e "SHOW DATABASES" | grep -v "^_" | while read db; do
#        ./backup_database.sh "$db" || echo "Échec: $db"
#      done
#
# D. Sauvegarde avec notification email:
#    $ ./backup_database.sh prod_db && \
#      echo "Backup OK" | mail -s "DB Backup" admin@example.com
#------------------------------------------------------------------------------
```

### Exemples de sortie

Montrez ce à quoi s'attendre :

```bash
#------------------------------------------------------------------------------
# Exemple de sortie:
#
# $ ./backup_database.sh -v myapp_db
# [2024-03-20 14:30:15] INFO: Démarrage de la sauvegarde de 'myapp_db'
# [2024-03-20 14:30:15] INFO: Connexion à localhost:3306
# [2024-03-20 14:30:17] INFO: Dump de la base (234 tables)...
# [2024-03-20 14:32:48] INFO: Compression en cours...
# [2024-03-20 14:33:12] INFO: Sauvegarde créée: myapp_db_20240320_143015.sql.gz (1.2 GB)
# [2024-03-20 14:33:12] INFO: Nettoyage des anciennes sauvegardes (rétention: 7 jours)
# [2024-03-20 14:33:12] INFO: Succès
#------------------------------------------------------------------------------
```

> [!tip] Exemples testables Les exemples doivent être **copiables-collables** et fonctionner tels quels

---

## ❓ Section --help

La section `--help` est l'interface utilisateur principale de votre script. Elle doit être complète, claire et formatée.

### Structure complète

```bash
show_help() {
    cat << 'EOF'
Usage: backup_database.sh [OPTIONS] DATABASE_NAME

Description:
  Crée une sauvegarde compressée d'une base de données MySQL avec rotation
  automatique des anciennes sauvegardes.

Arguments:
  DATABASE_NAME          Nom de la base de données à sauvegarder (requis)

Options:
  -h, --help            Affiche cette aide et quitte
  -v, --verbose         Mode verbeux (affiche les détails)
  -q, --quiet           Mode silencieux (erreurs uniquement)
  -V, --version         Affiche la version et quitte
  -n, --dry-run         Simule l'exécution sans effectuer d'actions

Configuration:
  -H, --host HOST       Serveur MySQL (défaut: localhost)
  -u, --user USER       Utilisateur MySQL (défaut: root)
  -p, --password PASS   Mot de passe MySQL (⚠️  peu sécurisé, utilisez .my.cnf)
  -P, --port PORT       Port MySQL (défaut: 3306)

Sauvegarde:
  -o, --output DIR      Répertoire de destination (défaut: /var/backups/mysql)
  -c, --compress TYPE   Type de compression: gzip|bzip2|xz (défaut: gzip)
  -r, --retention DAYS  Nombre de jours de rétention (défaut: 7)
  -f, --format FORMAT   Format de sortie: sql|csv (défaut: sql)
  
  --no-compress         Désactive la compression
  --no-rotation         Désactive la rotation des anciennes sauvegardes
  --tables TABLE1,...   Sauvegarde uniquement les tables spécifiées

Exemples:
  # Sauvegarde simple
  backup_database.sh production_db

  # Sauvegarde avec options
  backup_database.sh -v --compress=xz -r 30 production_db

  # Sauvegarde de tables spécifiques
  backup_database.sh --tables=users,orders myapp_db

  # Sauvegarde vers un NAS distant
  backup_database.sh -o /mnt/nas/backups production_db

  # Simulation sans exécution
  backup_database.sh --dry-run production_db

Codes de retour:
  0     Succès
  1     Erreur générale
  2     Erreur de connexion à la base
  3     Erreur d'écriture
  4     Base de données inexistante
  5     Arguments invalides

Variables d'environnement:
  MYSQL_HOST            Serveur MySQL (écrasé par --host)
  MYSQL_USER            Utilisateur MySQL (écrasé par --user)
  MYSQL_PASSWORD        Mot de passe MySQL (écrasé par --password)
  BACKUP_DIR            Répertoire de sauvegarde (écrasé par --output)

Fichiers de configuration:
  ~/.my.cnf             Configuration MySQL utilisateur
  /etc/mysql/my.cnf     Configuration MySQL système

Notes:
  - Nécessite mysqldump >= 5.7
  - L'utilisateur doit avoir les droits SELECT et LOCK TABLES
  - En cas d'erreur réseau, jusqu'à 3 tentatives sont effectuées
  - Les sauvegardes sont nommées: {database}_{YYYYMMDD_HHMMSS}.sql.gz

Auteur: Jean Dupont <jean.dupont@example.com>
Version: 1.2.3
License: MIT
Bug reports: https://github.com/user/repo/issues

EOF
}

# Gestion de l'option --help
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -V|--version)
        echo "backup_database.sh version 1.2.3"
        exit 0
        ;;
esac
```

### Sections d'une aide complète

|Section|Contenu|Obligatoire|
|---|---|---|
|**Usage**|Syntaxe de base|✅ Oui|
|**Description**|Objectif du script|✅ Oui|
|**Arguments**|Arguments positionnels|✅ Si applicable|
|**Options**|Toutes les options avec description|✅ Oui|
|**Exemples**|3-5 exemples concrets|✅ Oui|
|**Codes de retour**|Liste des exit codes|⚠️ Recommandé|
|**Variables d'env**|Variables utilisées|⚠️ Si applicable|
|**Fichiers de config**|Chemins des configs|⭕ Si applicable|
|**Notes**|Prérequis, limitations|⚠️ Recommandé|
|**Auteur**|Contact du mainteneur|⭕ Optionnel|

### Formatage de l'aide

> [!tip] Conventions typographiques
> 
> - **MAJUSCULES** : Valeurs à remplacer (DATABASE_NAME, HOST)
> - `[OPTIONS]` : Éléments optionnels
> - `<requis>` : Éléments obligatoires
> - `|` : Alternatives (gzip|bzip2)
> - `...` : Répétition possible

### Aide courte vs aide longue

```bash
show_usage() {
    echo "Usage: $0 [OPTIONS] DATABASE_NAME"
    echo "Tapez '$0 --help' pour plus d'informations."
}

show_help() {
    show_usage
    cat << 'EOF'

Description détaillée complète...
EOF
}

# Appel selon le cas
if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
fi
```

### Coloration de l'aide (optionnel)

```bash
show_help() {
    local BOLD='\033[1m'
    local GREEN='\033[0;32m'
    local CYAN='\033[0;36m'
    local NC='\033[0m' # No Color
    
    cat << EOF
${BOLD}Usage:${NC} backup_database.sh [OPTIONS] DATABASE_NAME

${BOLD}Options:${NC}
  ${GREEN}-h, --help${NC}            Affiche cette aide
  ${GREEN}-v, --verbose${NC}         Mode verbeux
  
${BOLD}Exemples:${NC}
  ${CYAN}backup_database.sh production_db${NC}
  ${CYAN}backup_database.sh -v --compress=xz mydb${NC}

EOF
}
```

> [!warning] Attention à la portabilité La coloration peut ne pas fonctionner sur tous les terminaux. Testez ou rendez-la optionnelle avec `--color=auto`

---

## 📐 Format standardisé

Adopter un format standardisé assure la **cohérence** entre vos scripts et facilite la maintenance.

### Conventions de nommage

```bash
# ✅ Bonnes pratiques
database_name="mydb"              # Variables: snake_case
MAX_RETRIES=3                     # Constantes: UPPER_SNAKE_CASE
backup_database() { ... }         # Fonctions: snake_case
readonly DB_HOST="localhost"      # Constantes readonly

# ❌ À éviter
DatabaseName="mydb"               # PascalCase non standard en Bash
maxRetries=3                      # camelCase non standard
BACKUP-DATABASE() { ... }         # Tirets dans les noms
```

### Organisation du script

Structure standardisée recommandée :

```bash
#!/bin/bash
#
# [EN-TÊTE DU SCRIPT]
#

#==============================================================================
# CONFIGURATION ET CONSTANTES
#==============================================================================

set -euo pipefail  # Mode strict

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.2.3"

# Constantes métier
readonly DEFAULT_BACKUP_DIR="/var/backups/mysql"
readonly MAX_RETRIES=3

#==============================================================================
# VARIABLES GLOBALES
#==============================================================================

verbose=false
dry_run=false
backup_count=0

#==============================================================================
# FONCTIONS UTILITAIRES
#==============================================================================

log_info() { ... }
log_error() { ... }
die() { ... }

#==============================================================================
# FONCTIONS DE VALIDATION
#==============================================================================

validate_database_name() { ... }
validate_output_dir() { ... }

#==============================================================================
# FONCTIONS MÉTIER
#==============================================================================

backup_database() { ... }
rotate_backups() { ... }

#==============================================================================
# PARSING DES ARGUMENTS
#==============================================================================

parse_args() { ... }

#==============================================================================
# FONCTION PRINCIPALE
#==============================================================================

main() {
    parse_args "$@"
    
    # Logique principale ici
    
    exit 0
}

#==============================================================================
# POINT D'ENTRÉE
#==============================================================================

# Exécute main uniquement si le script est appelé directement
# (permet de sourcer le script pour les tests)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Standards de formatage

#### Indentation et espacement

```bash
# ✅ Bon: indentation de 4 espaces
if [[ -f "$file" ]]; then
    echo "File exists"
    process_file "$file"
fi

# ❌ Mauvais: tabulations ou 2 espaces
if [[ -f "$file" ]]; then
  echo "File exists"
	process_file "$file"
fi
```

#### Guillemets et expansions

```bash
# ✅ Toujours quoter les variables
echo "User: $username"
rm -f "$temp_file"
find "$directory" -name "*.log"

# ✅ Sauf pour les tableaux et l'expansion de globs intentionnelle
files=(*.txt)
echo "${files[@]}"

# ❌ Variables non quotées (risque d'injection)
echo User: $username
rm -f $temp_file
```

#### Longueur des lignes

```bash
# ✅ Lignes < 80-100 caractères
mysqldump --host="$db_host" \
          --user="$db_user" \
          --password="$db_pass" \
          --single-transaction \
          "$database_name" > "$output_file"

# ✅ Alternative pour les tableaux
local options=(
    "--host=$db_host"
    "--user=$db_user"
    "--single-transaction"
)
mysqldump "${options[@]}" "$database_name" > "$output_file"
```

### Template de script standardisé

```bash
#!/bin/bash
#############################################################################
# Script Name   : script_template.sh
# Description   : Template de script Bash standardisé
# Author        : Votre Nom
# Date Created  : $(date +%Y-%m-%d)
# Version       : 1.0.0
#############################################################################

set -euo pipefail
IFS=$'\n\t'

#==============================================================================
# CONSTANTES
#==============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.0.0"

#==============================================================================
# FONCTIONS UTILITAIRES
#==============================================================================

log_info() {
    echo "[INFO] $*" >&2
}

log_error() {
    echo "[ERROR] $*" >&2
}

die() {
    log_error "$*"
    exit 1
}

show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Description de votre script.

Options:
  -h, --help     Affiche cette aide
  -v, --version  Affiche la version

Exemples:
  $SCRIPT_NAME
  $SCRIPT_NAME --help

EOF
}

#==============================================================================
# FONCTION PRINCIPALE
#==============================================================================

main() {
    # Gestion des arguments
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "$SCRIPT_NAME version $VERSION"
            exit 0
            ;;
        "")
            # Logique du script ici
            log_info "Script démarré"
            ;;
        *)
            die "Option invalide: $1. Utilisez --help pour l'aide."
            ;;
    esac
}

#==============================================================================
# POINT D'ENTRÉE
#==============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

> [!tip] Utilisez ShellCheck Passez vos scripts dans [ShellCheck](https://www.shellcheck.net/) pour détecter automatiquement les problèmes de style et de sécurité

---

## ⚠️ Pièges courants

### Piège 1 : Documentation obsolète

```bash
# ❌ Le commentaire ne correspond plus au code
# Supprime tous les fichiers .log
rm -f *.bak  # Code modifié mais commentaire oublié

# ✅ Gardez la doc synchronisée
# Supprime tous les fichiers de backup
rm -f *.bak
```

> [!warning] Documentation dépassée Une documentation fausse est **pire** qu'une absence de documentation car elle induit en erreur

### Piège 2 : Sur-documentation

```bash
# ❌ Trop de commentaires évidents
# Initialise le compteur à 0
counter=0
# Boucle de 1 à 10
for i in {1..10}; do
    # Incrémente le compteur
    ((counter++))
done

# ✅ Commentez uniquement ce qui n'est pas évident
counter=0
# Compte les fichiers modifiés dans les 24 dernières heures
for file in *.txt; do
    [[ $(stat -c %Y "$file") -gt $(($(date +%s) - 86400)) ]] && ((counter++))
done
```

### Piège 3 : Aide incomplète

```bash
# ❌ Aide minimaliste inutile
show_help() {
    echo "Usage: $0 [options] file"
    echo "Options: -v, -h"
}

# ✅ Aide détaillée avec exemples
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] FILE

Description:
  Traite le fichier FILE selon les options spécifiées.

Options:
  -v, --verbose    Mode verbeux
  -h, --help       Affiche cette aide

Exemples:
  $0 data.txt
  $0 -v large_file.txt

EOF
}
```

### Piège 4 : Codes de retour non documentés

```bash
# ❌ Codes de retour mystérieux
function process() {
    [[ -f "$1" ]] || return 5
    grep -q "pattern" "$1" || return 7
    return 0
}

# ✅ Documentez tous les codes de retour
#------------------------------------------------------------------------------
# process: Traite un fichier selon un pattern
# Retour:
#   0 - Succès (pattern trouvé)
#   5 - Fichier inexistant
#   7 - Pattern non trouvé
#------------------------------------------------------------------------------
function process() {
    [[ -f "$1" ]] || return 5
    grep -q "pattern" "$1" || return 7
    return 0
}
```

### Piège 5 : Exemples non testés

```bash
# ❌ Exemple qui ne fonctionne pas
# Exemples:
#   backup_db.sh mydb /backup  # Ordre des arguments inversé !

# ✅ Testez vos exemples avant de les documenter
# Exemples:
#   backup_db.sh /backup mydb  # Correct
```

> [!tip] Validez vos exemples Copiez-collez vos exemples de documentation et testez-les réellement pour vous assurer qu'ils fonctionnent

### Piège 6 : Oublier de mettre à jour la version

```bash
# ❌ Modifications sans changement de version
# Version       : 1.0.0  (← jamais mis à jour depuis 2 ans)

# ✅ Incrémentez la version à chaque modification significative
# Version       : 1.2.3
# Last Modified : 2024-03-20
```

### Piège 7 : Pas de documentation des dépendances

```bash
# ❌ Dépendances non mentionnées
backup_database() {
    mysqldump ... | gzip ... | aws s3 cp ...  # Nécessite mysql, gzip, awscli
}

# ✅ Documentez toutes les dépendances
#------------------------------------------------------------------------------
# Dépendances requises:
#   - mysql-client >= 5.7
#   - gzip
#   - awscli >= 2.0
#
# Installation:
#   apt-get install mysql-client gzip awscli
#------------------------------------------------------------------------------
```

---

## 🎯 Récapitulatif

> [!info] Checklist de documentation Avant de finaliser un script, vérifiez :
> 
> - ✅ En-tête complet avec auteur, date, description, usage
> - ✅ Commentaires explicatifs pour la logique complexe
> - ✅ Documentation de chaque fonction (arguments, retour, exemples)
> - ✅ Section `--help` complète et formatée
> - ✅ Exemples d'utilisation réels et testés
> - ✅ Codes de retour documentés
> - ✅ Dépendances et prérequis listés
> - ✅ Format standardisé respecté (nommage, indentation, organisation)
> - ✅ Version incrémentée si modifications
> - ✅ Tests effectués sur les exemples

### Les 3 règles d'or de la documentation

|Règle|Description|
|---|---|
|🎯 **Clarté**|Écrivez pour quelqu'un qui découvre le code|
|🔄 **Maintenance**|Mettez à jour la doc en même temps que le code|
|💡 **Utilité**|Documentez le "pourquoi", pas le "quoi"|

---

## 📚 Exemple complet : Script documenté

Voici un exemple de script complet appliquant toutes les bonnes pratiques de documentation :

```bash
#!/bin/bash

#############################################################################
# Script Name   : mysql_backup.sh
# Description   : Sauvegarde automatique de bases MySQL avec rotation
# Author        : Jean Dupont
# Email         : jean.dupont@example.com
# Date Created  : 2024-01-15
# Last Modified : 2024-03-20
# Version       : 1.2.3
# Usage         : ./mysql_backup.sh [OPTIONS] DATABASE_NAME
# License       : MIT
# Repository    : https://github.com/user/mysql-backup-tool
#############################################################################

set -euo pipefail
IFS=\n\t'

#==============================================================================
# CONFIGURATION ET CONSTANTES
#==============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.2.3"

# Configuration par défaut
readonly DEFAULT_BACKUP_DIR="/var/backups/mysql"
readonly DEFAULT_RETENTION_DAYS=7
readonly DEFAULT_COMPRESS="gzip"
readonly MAX_RETRIES=3

#==============================================================================
# VARIABLES GLOBALES
#==============================================================================

# Options utilisateur
verbose=false
dry_run=false
db_host="localhost"
db_port=3306
db_user="${MYSQL_USER:-root}"
db_password="${MYSQL_PASSWORD:-}"
output_dir="${BACKUP_DIR:-$DEFAULT_BACKUP_DIR}"
retention_days="$DEFAULT_RETENTION_DAYS"
compress_type="$DEFAULT_COMPRESS"
no_rotation=false

# Statistiques
backup_count=0
total_size=0

#==============================================================================
# FONCTIONS UTILITAIRES
#==============================================================================

#------------------------------------------------------------------------------
# log_info: Affiche un message d'information
# Arguments:
#   $@ - Message à afficher
# Note: N'affiche rien en mode quiet
#------------------------------------------------------------------------------
log_info() {
    [[ "$verbose" == true ]] && echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $*" >&2
}

#------------------------------------------------------------------------------
# log_error: Affiche un message d'erreur
# Arguments:
#   $@ - Message d'erreur
# Note: Affiche toujours, même en mode quiet
#------------------------------------------------------------------------------
log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
}

#------------------------------------------------------------------------------
# die: Affiche une erreur et quitte le script
# Arguments:
#   $1 - Message d'erreur
#   $2 - Code de sortie (optionnel, défaut: 1)
# Retour: N'en a pas (quitte le script)
#------------------------------------------------------------------------------
die() {
    local message="$1"
    local exit_code="${2:-1}"
    log_error "$message"
    exit "$exit_code"
}

#------------------------------------------------------------------------------
# check_dependencies: Vérifie que les dépendances sont installées
# Dépendances requises:
#   - mysql/mysqldump (mysql-client >= 5.7)
#   - gzip (pour compression)
# Retour:
#   0 - Toutes les dépendances présentes
#   1 - Une ou plusieurs dépendances manquantes
#------------------------------------------------------------------------------
check_dependencies() {
    local missing=()
    
    command -v mysql >/dev/null 2>&1 || missing+=("mysql")
    command -v mysqldump >/dev/null 2>&1 || missing+=("mysqldump")
    
    case "$compress_type" in
        gzip)  command -v gzip >/dev/null 2>&1 || missing+=("gzip") ;;
        bzip2) command -v bzip2 >/dev/null 2>&1 || missing+=("bzip2") ;;
        xz)    command -v xz >/dev/null 2>&1 || missing+=("xz") ;;
    esac
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Dépendances manquantes: ${missing[*]}"
        log_error "Installez avec: apt-get install ${missing[*]}"
        return 1
    fi
    
    return 0
}

#==============================================================================
# FONCTIONS DE VALIDATION
#==============================================================================

#------------------------------------------------------------------------------
# validate_database_exists: Vérifie qu'une base de données existe
# Arguments:
#   $1 - database_name (string, requis): Nom de la base
# Retour:
#   0 - Base de données existe
#   1 - Base de données inexistante ou erreur de connexion
# Note: Utilise les variables globales db_host, db_user, db_password
#------------------------------------------------------------------------------
validate_database_exists() {
    local database_name="$1"
    local mysql_cmd="mysql -h $db_host -P $db_port -u $db_user"
    
    # Ajoute le mot de passe si fourni
    [[ -n "$db_password" ]] && mysql_cmd+=" -p$db_password"
    
    # Vérifie l'existence de la base (avec suppression des warnings password)
    if ! $mysql_cmd -e "USE $database_name" 2>/dev/null; then
        log_error "Base de données '$database_name' inexistante ou inaccessible"
        return 1
    fi
    
    log_info "Base de données '$database_name' validée"
    return 0
}

#------------------------------------------------------------------------------
# validate_output_dir: Vérifie et crée le répertoire de sortie si nécessaire
# Arguments:
#   $1 - directory (string, requis): Chemin du répertoire
# Retour:
#   0 - Répertoire existe et est accessible en écriture
#   1 - Impossible de créer ou d'accéder au répertoire
#------------------------------------------------------------------------------
validate_output_dir() {
    local directory="$1"
    
    # Crée le répertoire s'il n'existe pas (en mode dry-run aussi pour validation)
    if [[ ! -d "$directory" ]]; then
        log_info "Création du répertoire: $directory"
        if ! mkdir -p "$directory" 2>/dev/null; then
            log_error "Impossible de créer le répertoire: $directory"
            return 1
        fi
    fi
    
    # Vérifie les permissions d'écriture
    if [[ ! -w "$directory" ]]; then
        log_error "Pas de permission d'écriture sur: $directory"
        return 1
    fi
    
    log_info "Répertoire de sortie validé: $directory"
    return 0
}

#==============================================================================
# FONCTIONS MÉTIER
#==============================================================================

#------------------------------------------------------------------------------
# backup_database: Crée une sauvegarde d'une base de données
# Arguments:
#   $1 - database_name (string, requis): Nom de la base à sauvegarder
# Retour:
#   0 - Sauvegarde réussie
#   1 - Erreur lors de la sauvegarde
# Variables globales:
#   db_host, db_user, db_password - Lecture: Paramètres de connexion
#   output_dir - Lecture: Répertoire de destination
#   compress_type - Lecture: Type de compression
#   dry_run - Lecture: Mode simulation
#   backup_count - Modification: Incrémenté en cas de succès
#   total_size - Modification: Taille ajoutée
# Exemple:
#   backup_database "production_db"
#------------------------------------------------------------------------------
backup_database() {
    local database_name="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local filename="${database_name}_${timestamp}.sql"
    local output_file="${output_dir}/${filename}"
    
    # Ajoute l'extension selon le type de compression
    case "$compress_type" in
        gzip)  output_file+=".gz" ;;
        bzip2) output_file+=".bz2" ;;
        xz)    output_file+=".xz" ;;
    esac
    
    log_info "Démarrage sauvegarde: $database_name -> $output_file"
    
    # En mode dry-run, on simule seulement
    if [[ "$dry_run" == true ]]; then
        log_info "[DRY-RUN] Sauvegarde simulée de '$database_name'"
        return 0
    fi
    
    # Construction de la commande mysqldump
    local dump_cmd="mysqldump -h $db_host -P $db_port -u $db_user"
    [[ -n "$db_password" ]] && dump_cmd+=" -p$db_password"
    dump_cmd+=" --single-transaction --routines --triggers"
    dump_cmd+=" $database_name"
    
    # Ajout de la compression selon le type
    case "$compress_type" in
        gzip)  dump_cmd+=" | gzip -9" ;;
        bzip2) dump_cmd+=" | bzip2 -9" ;;
        xz)    dump_cmd+=" | xz -9" ;;
    esac
    
    # Exécution avec gestion des erreurs et retry
    local attempt=1
    while [[ $attempt -le $MAX_RETRIES ]]; do
        if eval "$dump_cmd > '$output_file' 2>/dev/null"; then
            local size=$(du -h "$output_file" | cut -f1)
            log_info "Sauvegarde réussie: $output_file ($size)"
            ((backup_count++))
            return 0
        else
            log_error "Tentative $attempt/$MAX_RETRIES échouée"
            ((attempt++))
            # Attend 5 secondes avant de réessayer (sauf dernière tentative)
            [[ $attempt -le $MAX_RETRIES ]] && sleep 5
        fi
    done
    
    log_error "Échec de la sauvegarde après $MAX_RETRIES tentatives"
    return 1
}

#------------------------------------------------------------------------------
# rotate_backups: Supprime les anciennes sauvegardes selon la rétention
# Arguments:
#   $1 - database_name (string, requis): Nom de la base
# Variables globales:
#   output_dir - Lecture: Répertoire des sauvegardes
#   retention_days - Lecture: Nombre de jours de rétention
#   dry_run - Lecture: Mode simulation
#   no_rotation - Lecture: Désactive la rotation si true
# Retour:
#   0 - Rotation effectuée
# Note: Utilise 'find' avec -mtime pour identifier les vieux fichiers
#------------------------------------------------------------------------------
rotate_backups() {
    local database_name="$1"
    
    [[ "$no_rotation" == true ]] && return 0
    
    log_info "Rotation des sauvegardes (rétention: $retention_days jours)"
    
    # Recherche des fichiers plus vieux que la rétention
    local pattern="${database_name}_*.sql*"
    local old_files=$(find "$output_dir" -name "$pattern" -type f -mtime "+$retention_days" 2>/dev/null)
    
    if [[ -z "$old_files" ]]; then
        log_info "Aucune sauvegarde à supprimer"
        return 0
    fi
    
    local count=0
    while IFS= read -r file; do
        if [[ "$dry_run" == true ]]; then
            log_info "[DRY-RUN] Suppression simulée: $file"
        else
            log_info "Suppression: $file"
            rm -f "$file"
        fi
        ((count++))
    done <<< "$old_files"
    
    log_info "$count sauvegarde(s) supprimée(s)"
    return 0
}

#==============================================================================
# AIDE ET VERSION
#==============================================================================

show_help() {
    cat << 'EOF'
Usage: mysql_backup.sh [OPTIONS] DATABASE_NAME

Description:
  Crée une sauvegarde compressée d'une base de données MySQL avec rotation
  automatique des anciennes sauvegardes selon la politique de rétention.

Arguments:
  DATABASE_NAME          Nom de la base de données à sauvegarder (requis)

Options générales:
  -h, --help            Affiche cette aide et quitte
  -V, --version         Affiche la version et quitte
  -v, --verbose         Mode verbeux (affiche les détails)
  -n, --dry-run         Simule l'exécution sans effectuer d'actions réelles

Configuration MySQL:
  -H, --host HOST       Serveur MySQL (défaut: localhost)
  -u, --user USER       Utilisateur MySQL (défaut: $MYSQL_USER ou root)
  -p, --password PASS   Mot de passe MySQL (⚠️  peu sécurisé, préférez .my.cnf)
  -P, --port PORT       Port MySQL (défaut: 3306)

Options de sauvegarde:
  -o, --output DIR      Répertoire de destination (défaut: /var/backups/mysql)
  -c, --compress TYPE   Type de compression: gzip|bzip2|xz|none (défaut: gzip)
  -r, --retention DAYS  Nombre de jours de rétention (défaut: 7)
  --no-rotation         Désactive la rotation des anciennes sauvegardes

Exemples:
  # Sauvegarde simple avec options par défaut
  mysql_backup.sh production_db

  # Sauvegarde avec compression xz et rétention de 30 jours
  mysql_backup.sh -v --compress=xz --retention=30 production_db

  # Sauvegarde vers un répertoire personnalisé
  mysql_backup.sh -o /mnt/nas/backups production_db

  # Simulation sans exécution réelle
  mysql_backup.sh --dry-run production_db

  # Sauvegarde avec connexion distante
  mysql_backup.sh -H db.example.com -u backup_user -p secret123 myapp_db

  # Sauvegarde sans compression et sans rotation
  mysql_backup.sh --compress=none --no-rotation archive_db

Codes de retour:
  0     Succès complet
  1     Erreur générale
  2     Erreur de connexion à MySQL
  3     Base de données inexistante
  4     Arguments invalides
  5     Dépendances manquantes

Variables d'environnement:
  MYSQL_HOST            Serveur MySQL par défaut (écrasé par --host)
  MYSQL_USER            Utilisateur MySQL par défaut (écrasé par --user)
  MYSQL_PASSWORD        Mot de passe MySQL (écrasé par --password)
  BACKUP_DIR            Répertoire de sauvegarde (écrasé par --output)

Fichiers de configuration:
  ~/.my.cnf             Configuration MySQL utilisateur (recommandé)
  /etc/mysql/my.cnf     Configuration MySQL système

Dépendances requises:
  - mysql-client >= 5.7 (mysql, mysqldump)
  - gzip (si --compress=gzip)
  - bzip2 (si --compress=bzip2)
  - xz (si --compress=xz)

Installation des dépendances:
  apt-get install mysql-client gzip bzip2 xz-utils    # Debian/Ubuntu
  yum install mysql gzip bzip2 xz                      # RHEL/CentOS

Notes importantes:
  - L'utilisateur MySQL doit avoir les droits SELECT et LOCK TABLES
  - En cas d'erreur réseau, jusqu'à 3 tentatives automatiques sont effectuées
  - Les sauvegardes sont nommées: {database}_{YYYYMMDD_HHMMSS}.sql.{ext}
  - La rotation utilise la date de modification du fichier (mtime)
  - En mode dry-run, toutes les validations sont effectuées

Sécurité:
  ⚠️  Évitez --password en ligne de commande (visible dans 'ps')
  ✅ Préférez un fichier ~/.my.cnf avec permissions 600:
     [client]
     user=backup_user
     password=secret123

Auteur: Jean Dupont <jean.dupont@example.com>
Version: 1.2.3
License: MIT
Bug reports: https://github.com/user/mysql-backup-tool/issues
Documentation: https://github.com/user/mysql-backup-tool/wiki

EOF
}

show_version() {
    echo "$SCRIPT_NAME version $VERSION"
    echo "Copyright (c) 2024 Jean Dupont"
    echo "License MIT: https://opensource.org/licenses/MIT"
}

#==============================================================================
# PARSING DES ARGUMENTS
#==============================================================================

#------------------------------------------------------------------------------
# parse_args: Parse les arguments de la ligne de commande
# Arguments:
#   $@ - Tous les arguments passés au script
# Variables globales:
#   Modifie toutes les variables d'options (verbose, db_host, etc.)
# Retour:
#   0 - Arguments valides
#   4 - Arguments invalides (quitte via die)
#------------------------------------------------------------------------------
parse_args() {
    local database_name=""
    
    # Pas d'arguments du tout
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    # Parse les options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -V|--version)
                show_version
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -n|--dry-run)
                dry_run=true
                verbose=true  # Active verbose automatiquement en dry-run
                shift
                ;;
            -H|--host)
                [[ -z "${2:-}" ]] && die "Option $1 nécessite un argument" 4
                db_host="$2"
                shift 2
                ;;
            -u|--user)
                [[ -z "${2:-}" ]] && die "Option $1 nécessite un argument" 4
                db_user="$2"
                shift 2
                ;;
            -p|--password)
                [[ -z "${2:-}" ]] && die "Option $1 nécessite un argument" 4
                db_password="$2"
                shift 2
                ;;
            -P|--port)
                [[ -z "${2:-}" ]] && die "Option $1 nécessite un argument" 4
                db_port="$2"
                shift 2
                ;;
            -o|--output)
                [[ -z "${2:-}" ]] && die "Option $1 nécessite un argument" 4
                output_dir="$2"
                shift 2
                ;;
            -c|--compress)
                [[ -z "${2:-}" ]] && die "Option $1 nécessite un argument" 4
                case "$2" in
                    gzip|bzip2|xz|none)
                        compress_type="$2"
                        ;;
                    *)
                        die "Type de compression invalide: $2 (utilisez: gzip|bzip2|xz|none)" 4
                        ;;
                esac
                shift 2
                ;;
            -r|--retention)
                [[ -z "${2:-}" ]] && die "Option $1 nécessite un argument" 4
                if [[ ! "$2" =~ ^[0-9]+$ ]]; then
                    die "Rétention invalide: $2 (doit être un nombre)" 4
                fi
                retention_days="$2"
                shift 2
                ;;
            --no-rotation)
                no_rotation=true
                shift
                ;;
            -*)
                die "Option inconnue: $1 (utilisez --help pour l'aide)" 4
                ;;
            *)
                # Premier argument sans option = nom de la base
                if [[ -z "$database_name" ]]; then
                    database_name="$1"
                    shift
                else
                    die "Argument inattendu: $1" 4
                fi
                ;;
        esac
    done
    
    # Vérifie que le nom de base est fourni
    if [[ -z "$database_name" ]]; then
        die "Nom de base de données requis (utilisez --help pour l'aide)" 4
    fi
    
    # Export pour utilisation dans les fonctions
    export DATABASE_NAME="$database_name"
}

#==============================================================================
# FONCTION PRINCIPALE
#==============================================================================

#------------------------------------------------------------------------------
# main: Point d'entrée principal du script
# Arguments:
#   $@ - Tous les arguments du script
# Retour:
#   0 - Succès
#   >0 - Code d'erreur spécifique
#------------------------------------------------------------------------------
main() {
    log_info "=== $SCRIPT_NAME v$VERSION ==="
    
    # Parse les arguments
    parse_args "$@"
    
    # Vérifie les dépendances
    check_dependencies || die "Dépendances manquantes" 5
    
    # Valide le répertoire de sortie
    validate_output_dir "$output_dir" || die "Répertoire de sortie invalide" 1
    
    # Valide que la base existe
    validate_database_exists "$DATABASE_NAME" || die "Base de données invalide" 3
    
    # Effectue la sauvegarde
    if backup_database "$DATABASE_NAME"; then
        log_info "✓ Sauvegarde terminée avec succès"
        
        # Rotation des anciennes sauvegardes
        rotate_backups "$DATABASE_NAME"
        
        log_info "=== Statistiques ==="
        log_info "Sauvegardes créées: $backup_count"
        log_info "Répertoire: $output_dir"
        
        exit 0
    else
        die "✗ Échec de la sauvegarde" 1
    fi
}

#==============================================================================
# POINT D'ENTRÉE
#==============================================================================

# Exécute main uniquement si le script est appelé directement
# (permet de sourcer le script pour les tests unitaires)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

---

## 🎓 Synthèse finale

La documentation d'un script Bash professionnel repose sur **six piliers essentiels** :

### 1. En-tête informatif 📋

- Identité du script (nom, auteur, version, date)
- Description claire de l'objectif
- Syntaxe d'utilisation rapide

### 2. Commentaires pertinents 💭

- Expliquent le "pourquoi", pas le "quoi"
- Placés uniquement où nécessaire
- Maintenus synchronisés avec le code

### 3. Fonctions documentées 📚

- Arguments et types détaillés
- Codes de retour explicites
- Exemples d'utilisation concrets

### 4. Aide complète --help ❓

- Syntaxe, options, exemples
- Codes de retour et variables d'environnement
- Dépendances et notes importantes

### 5. Format standardisé 📐

- Structure cohérente et prévisible
- Conventions de nommage respectées
- Organisation claire en sections

### 6. Maintenance continue 🔄

- Documentation mise à jour avec le code
- Version incrémentée à chaque modification
- Exemples testés et validés

> [!tip] La documentation est un investissement Le temps passé à documenter aujourd'hui est **multiplié par 10** en temps gagné demain lors de la maintenance, du débogage ou de la transmission du code.

**Un script bien documenté est un script professionnel qui inspire confiance et facilite la collaboration.**