
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

## 🏗️ Structure d'un script basique

### Pourquoi scripter rsync ?

Lancer manuellement des commandes rsync répétitives est fastidieux et source d'erreurs. Un script permet de :

- **Automatiser** : Exécution programmée sans intervention
- **Standardiser** : Même commande, mêmes options à chaque fois
- **Tracer** : Conserver un historique des sauvegardes
- **Notifier** : Alerter en cas de problème

### Anatomie d'un script de base

```bash
#!/bin/bash
# Script de sauvegarde rsync basique
# Description : Sauvegarde du répertoire /home vers /backup

# Configuration
SOURCE="/home/"
DESTINATION="/backup/home/"
OPTIONS="-avh --progress --delete"

# Exécution
echo "=== Début de la sauvegarde ==="
echo "Source : $SOURCE"
echo "Destination : $DESTINATION"
echo "Date : $(date '+%Y-%m-%d %H:%M:%S')"

rsync $OPTIONS "$SOURCE" "$DESTINATION"

echo "=== Sauvegarde terminée ==="
```

> [!tip] Shebang et permissions
> 
> - La première ligne `#!/bin/bash` indique l'interpréteur à utiliser
> - Rendez le script exécutable : `chmod +x backup.sh`
> - Lancez-le avec : `./backup.sh`

### Script avec structure améliorée

```bash
#!/bin/bash
#==============================================================================
# SCRIPT DE SAUVEGARDE RSYNC
#==============================================================================
# Auteur    : Votre nom
# Date      : 2026-01-25
# Version   : 1.0
# Description : Sauvegarde quotidienne des données utilisateurs
#==============================================================================

#------------------------------------------------------------------------------
# CONFIGURATION
#------------------------------------------------------------------------------
SOURCE="/home/"
DESTINATION="/backup/home/"
RSYNC_OPTIONS="-avh --delete --delete-excluded"

# Exclusions
EXCLUDE_LIST=(
    ".cache"
    "*.tmp"
    "*.log"
    ".Trash"
)

#------------------------------------------------------------------------------
# FONCTION PRINCIPALE
#------------------------------------------------------------------------------
main() {
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           SAUVEGARDE RSYNC - $(date '+%Y-%m-%d')            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Construction des options d'exclusion
    EXCLUDE_OPTS=""
    for pattern in "${EXCLUDE_LIST[@]}"; do
        EXCLUDE_OPTS="$EXCLUDE_OPTS --exclude='$pattern'"
    done
    
    # Affichage des paramètres
    echo "Source      : $SOURCE"
    echo "Destination : $DESTINATION"
    echo "Options     : $RSYNC_OPTIONS $EXCLUDE_OPTS"
    echo ""
    echo "Démarrage à $(date '+%H:%M:%S')..."
    echo "----------------------------------------"
    
    # Exécution de rsync
    eval rsync $RSYNC_OPTIONS $EXCLUDE_OPTS "$SOURCE" "$DESTINATION"
    
    echo "----------------------------------------"
    echo "Terminé à $(date '+%H:%M:%S')"
}

#------------------------------------------------------------------------------
# LANCEMENT
#------------------------------------------------------------------------------
main
```

> [!example] Points clés de cette structure
> 
> - **En-tête documenté** : Qui, quoi, quand
> - **Section configuration** : Variables centralisées
> - **Fonction main** : Logique principale isolée
> - **Affichage informatif** : L'utilisateur sait ce qui se passe

---

## 📝 Gestion des logs

### Pourquoi journaliser ?

Les logs sont essentiels pour :

- **Traçabilité** : Savoir ce qui s'est passé et quand
- **Débogage** : Identifier la source d'un problème
- **Audit** : Prouver qu'une sauvegarde a eu lieu
- **Statistiques** : Analyser la volumétrie et la durée

### Redirection simple vers un fichier

```bash
#!/bin/bash

LOG_FILE="/var/log/rsync-backup.log"
SOURCE="/home/"
DESTINATION="/backup/home/"

# Redirection de toute la sortie vers le fichier log
{
    echo "=== Sauvegarde du $(date '+%Y-%m-%d %H:%M:%S') ==="
    rsync -avh --delete "$SOURCE" "$DESTINATION"
    echo "=== Fin de sauvegarde ==="
    echo ""
} >> "$LOG_FILE" 2>&1
```

> [!warning] Attention aux permissions Le fichier log doit être accessible en écriture. Pour `/var/log/`, le script doit souvent être exécuté en root ou via sudo.

### Système de logs rotatif

```bash
#!/bin/bash

#------------------------------------------------------------------------------
# CONFIGURATION DES LOGS
#------------------------------------------------------------------------------
LOG_DIR="/var/log/rsync"
LOG_FILE="$LOG_DIR/backup-$(date '+%Y-%m-%d').log"
LOG_RETENTION_DAYS=30

# Création du répertoire de logs si nécessaire
mkdir -p "$LOG_DIR"

#------------------------------------------------------------------------------
# FONCTION DE JOURNALISATION
#------------------------------------------------------------------------------
log_message() {
    local level="$1"
    shift
    local message="$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOG_FILE"
}

#------------------------------------------------------------------------------
# FONCTION DE NETTOYAGE DES VIEUX LOGS
#------------------------------------------------------------------------------
cleanup_old_logs() {
    log_message "INFO" "Nettoyage des logs de plus de $LOG_RETENTION_DAYS jours"
    find "$LOG_DIR" -name "backup-*.log" -type f -mtime +$LOG_RETENTION_DAYS -delete
}

#------------------------------------------------------------------------------
# SCRIPT PRINCIPAL
#------------------------------------------------------------------------------
log_message "INFO" "════════════════════════════════════════"
log_message "INFO" "Début de la sauvegarde"
log_message "INFO" "════════════════════════════════════════"

# Nettoyage des anciens logs
cleanup_old_logs

# Configuration
SOURCE="/home/"
DESTINATION="/backup/home/"

log_message "INFO" "Source: $SOURCE"
log_message "INFO" "Destination: $DESTINATION"

# Exécution avec capture dans le log
rsync -avh --delete --stats "$SOURCE" "$DESTINATION" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    log_message "SUCCESS" "Sauvegarde terminée avec succès"
else
    log_message "ERROR" "Erreur lors de la sauvegarde (code: $?)"
fi

log_message "INFO" "════════════════════════════════════════"
```

> [!tip] Astuces pour les logs
> 
> - **Utilisez `tee`** pour afficher ET enregistrer simultanément
> - **Datez vos fichiers** pour éviter qu'ils ne grossissent indéfiniment
> - **Nettoyez régulièrement** les anciens logs
> - **Utilisez des niveaux** : INFO, WARNING, ERROR, SUCCESS

### Logs avec statistiques détaillées

```bash
#!/bin/bash

LOG_FILE="/var/log/rsync/backup-detailed.log"
STATS_FILE="/var/log/rsync/stats-$(date '+%Y-%m-%d').txt"

# Sauvegarde avec statistiques complètes
{
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║  SAUVEGARDE RSYNC - $(date '+%Y-%m-%d %H:%M:%S')  ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    
    START_TIME=$(date +%s)
    
    rsync -avh --delete --stats --human-readable \
          /home/ /backup/home/ \
          2>&1
    
    EXIT_CODE=$?
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Durée totale : $DURATION secondes"
    echo "Code de sortie : $EXIT_CODE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
} | tee -a "$LOG_FILE" > "$STATS_FILE"
```

---

## ⚠️ Gestion des erreurs

### Pourquoi gérer les erreurs ?

Un script sans gestion d'erreur peut :

- Continuer silencieusement après un échec
- Laisser des sauvegardes incomplètes
- Ne pas alerter l'administrateur
- Corrompre des données

### Vérification du code de retour

```bash
#!/bin/bash

SOURCE="/home/"
DESTINATION="/backup/home/"

rsync -avh --delete "$SOURCE" "$DESTINATION"
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✓ Sauvegarde réussie"
    exit 0
elif [ $EXIT_CODE -eq 23 ]; then
    echo "⚠ Sauvegarde partielle : certains fichiers n'ont pas pu être transférés"
    exit 23
else
    echo "✗ Erreur lors de la sauvegarde (code: $EXIT_CODE)"
    exit $EXIT_CODE
fi
```

> [!info] Codes de retour rsync courants
> 
> |Code|Signification|
> |---|---|
> |0|Succès complet|
> |1|Erreur de syntaxe ou d'utilisation|
> |2|Incompatibilité de protocole|
> |3|Erreur dans la sélection de fichiers|
> |5|Erreur de démarrage du protocole|
> |10|Erreur dans le socket I/O|
> |11|Erreur I/O fichier|
> |23|Transfert partiel (certains fichiers non transférés)|
> |24|Disparition de fichiers source|
> |25|Nombre maximum d'erreurs atteint|

### Script avec gestion complète des erreurs

```bash
#!/bin/bash

#------------------------------------------------------------------------------
# MODE STRICT
#------------------------------------------------------------------------------
set -o errexit   # Arrête le script si une commande échoue
set -o nounset   # Arrête si une variable non définie est utilisée
set -o pipefail  # Propage les erreurs dans les pipes

#------------------------------------------------------------------------------
# CONFIGURATION
#------------------------------------------------------------------------------
SOURCE="/home/"
DESTINATION="/backup/home/"
LOG_FILE="/var/log/rsync/backup.log"
ADMIN_EMAIL="admin@example.com"

#------------------------------------------------------------------------------
# FONCTION DE LOG
#------------------------------------------------------------------------------
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" | tee -a "$LOG_FILE"
}

#------------------------------------------------------------------------------
# FONCTION D'ERREUR
#------------------------------------------------------------------------------
error_exit() {
    log "ERROR: $1"
    
    # Envoi d'email d'alerte (nécessite mailutils ou sendmail)
    if command -v mail &> /dev/null; then
        echo "Erreur de sauvegarde: $1" | mail -s "ALERTE Sauvegarde" "$ADMIN_EMAIL"
    fi
    
    exit "${2:-1}"  # Code de sortie 1 par défaut
}

#------------------------------------------------------------------------------
# FONCTION DE NETTOYAGE (trap)
#------------------------------------------------------------------------------
cleanup() {
    log "Nettoyage en cours..."
    # Actions de nettoyage si nécessaire
}

# Définir le trap pour nettoyer en cas d'interruption
trap cleanup EXIT INT TERM

#------------------------------------------------------------------------------
# VÉRIFICATIONS PRÉALABLES
#------------------------------------------------------------------------------
log "=== Début des vérifications ==="

# Vérifier que rsync est installé
if ! command -v rsync &> /dev/null; then
    error_exit "rsync n'est pas installé" 127
fi

# Vérifier que la source existe
if [ ! -d "$SOURCE" ]; then
    error_exit "Le répertoire source n'existe pas: $SOURCE" 2
fi

# Vérifier que la destination est accessible
if [ ! -d "$DESTINATION" ]; then
    log "WARNING: Création du répertoire de destination"
    mkdir -p "$DESTINATION" || error_exit "Impossible de créer $DESTINATION" 2
fi

# Vérifier l'espace disque disponible
REQUIRED_SPACE=$(du -sb "$SOURCE" | cut -f1)
AVAILABLE_SPACE=$(df -B1 "$DESTINATION" | tail -1 | awk '{print $4}')

if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    error_exit "Espace disque insuffisant (requis: $REQUIRED_SPACE, disponible: $AVAILABLE_SPACE)" 3
fi

log "✓ Vérifications terminées avec succès"

#------------------------------------------------------------------------------
# EXÉCUTION DE LA SAUVEGARDE
#------------------------------------------------------------------------------
log "=== Début de la sauvegarde ==="

rsync -avh --delete --stats "$SOURCE" "$DESTINATION" >> "$LOG_FILE" 2>&1
RSYNC_EXIT=$?

#------------------------------------------------------------------------------
# ANALYSE DU RÉSULTAT
#------------------------------------------------------------------------------
case $RSYNC_EXIT in
    0)
        log "✓ Sauvegarde réussie"
        ;;
    23)
        log "⚠ Sauvegarde partielle (certains fichiers ignorés)"
        ;;
    24)
        log "⚠ Fichiers source disparus pendant le transfert"
        ;;
    *)
        error_exit "Échec de la sauvegarde (code: $RSYNC_EXIT)" $RSYNC_EXIT
        ;;
esac

log "=== Fin de la sauvegarde ==="
exit $RSYNC_EXIT
```

> [!warning] Options set au début du script
> 
> - `set -o errexit` : Arrête le script dès qu'une commande échoue (attention aux commandes conditionnelles)
> - `set -o nounset` : Arrête si vous utilisez une variable non définie
> - `set -o pipefail` : Dans un pipeline, propage l'erreur de la première commande qui échoue

### Gestion d'erreurs avec retry (nouvelle tentative)

```bash
#!/bin/bash

#------------------------------------------------------------------------------
# FONCTION DE RETRY
#------------------------------------------------------------------------------
retry_rsync() {
    local max_attempts=3
    local timeout=5
    local attempt=1
    local exitCode=0
    
    while [ $attempt -le $max_attempts ]; do
        echo "Tentative $attempt/$max_attempts..."
        
        rsync -avh --timeout=300 "$@"
        exitCode=$?
        
        if [ $exitCode -eq 0 ]; then
            echo "✓ Succès"
            return 0
        fi
        
        echo "✗ Échec (code: $exitCode)"
        
        if [ $attempt -lt $max_attempts ]; then
            echo "Nouvelle tentative dans $timeout secondes..."
            sleep $timeout
            timeout=$((timeout * 2))  # Backoff exponentiel
        fi
        
        attempt=$((attempt + 1))
    done
    
    echo "✗ Échec après $max_attempts tentatives"
    return $exitCode
}

#------------------------------------------------------------------------------
# UTILISATION
#------------------------------------------------------------------------------
retry_rsync --delete /home/ backup.example.com:/backup/home/

if [ $? -ne 0 ]; then
    echo "La sauvegarde a échoué définitivement"
    exit 1
fi
```

> [!tip] Quand utiliser le retry ?
> 
> - **Sauvegardes distantes** : Connexions réseau instables
> - **Serveurs surchargés** : Le serveur peut temporairement refuser
> - **Montages réseau** : NFS/CIFS peuvent temporairement échouer
> - **Ne pas utiliser** pour des erreurs de permissions ou de syntaxe

---

## 🔧 Variables et paramètres

### Utilisation de variables

Les variables rendent votre script flexible et maintenable :

```bash
#!/bin/bash

#------------------------------------------------------------------------------
# VARIABLES DE CONFIGURATION
#------------------------------------------------------------------------------
# Chemins
SOURCE_DIR="/home/"
BACKUP_ROOT="/backup"
BACKUP_DIR="$BACKUP_ROOT/home-$(date '+%Y%m%d')"

# Options rsync
RSYNC_OPTS="-avh"
RSYNC_DELETE="--delete"
RSYNC_COMPRESS="-z"
RSYNC_STATS="--stats"

# Logs
LOG_DIR="/var/log/rsync"
LOG_FILE="$LOG_DIR/backup-$(date '+%Y-%m-%d').log"

# Rétention
RETENTION_DAYS=7

#------------------------------------------------------------------------------
# UTILISATION DES VARIABLES
#------------------------------------------------------------------------------
mkdir -p "$BACKUP_DIR"

rsync $RSYNC_OPTS $RSYNC_DELETE $RSYNC_COMPRESS $RSYNC_STATS \
      "$SOURCE_DIR" "$BACKUP_DIR" \
      >> "$LOG_FILE" 2>&1

# Nettoyage des anciennes sauvegardes
find "$BACKUP_ROOT" -maxdepth 1 -name "home-*" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;
```

> [!example] Avantages des variables
> 
> - **Modification centralisée** : Changez une fois, effet partout
> - **Lisibilité** : Les noms explicites clarifient l'intention
> - **Réutilisabilité** : Calculez une fois, utilisez plusieurs fois
> - **Date dynamique** : Sauvegarde datée automatiquement

### Paramètres en ligne de commande

Rendre le script flexible avec des arguments :

```bash
#!/bin/bash

#------------------------------------------------------------------------------
# AIDE
#------------------------------------------------------------------------------
usage() {
    cat << EOF
Usage: $0 [OPTIONS] SOURCE DESTINATION

Options:
  -v, --verbose      Mode verbeux
  -d, --delete       Supprimer les fichiers de destination absents de la source
  -c, --compress     Activer la compression
  -n, --dry-run      Simulation (ne modifie rien)
  -h, --help         Afficher cette aide

Examples:
  $0 /home/ /backup/home/
  $0 -vdc /var/www/ user@server:/backup/www/
  $0 --dry-run /data/ /backup/data/
EOF
    exit 0
}

#------------------------------------------------------------------------------
# VARIABLES PAR DÉFAUT
#------------------------------------------------------------------------------
VERBOSE=false
DELETE=false
COMPRESS=false
DRY_RUN=false

#------------------------------------------------------------------------------
# ANALYSE DES ARGUMENTS
#------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--delete)
            DELETE=true
            shift
            ;;
        -c|--compress)
            COMPRESS=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Option inconnue: $1"
            usage
            ;;
        *)
            # Arguments positionnels (source et destination)
            if [ -z "$SOURCE" ]; then
                SOURCE="$1"
            elif [ -z "$DESTINATION" ]; then
                DESTINATION="$1"
            else
                echo "Trop d'arguments"
                usage
            fi
            shift
            ;;
    esac
done

#------------------------------------------------------------------------------
# VÉRIFICATION DES ARGUMENTS OBLIGATOIRES
#------------------------------------------------------------------------------
if [ -z "$SOURCE" ] || [ -z "$DESTINATION" ]; then
    echo "Erreur: SOURCE et DESTINATION sont obligatoires"
    usage
fi

#------------------------------------------------------------------------------
# CONSTRUCTION DES OPTIONS RSYNC
#------------------------------------------------------------------------------
RSYNC_OPTS="-a"

if [ "$VERBOSE" = true ]; then
    RSYNC_OPTS="$RSYNC_OPTS -v --progress"
fi

if [ "$DELETE" = true ]; then
    RSYNC_OPTS="$RSYNC_OPTS --delete"
fi

if [ "$COMPRESS" = true ]; then
    RSYNC_OPTS="$RSYNC_OPTS -z"
fi

if [ "$DRY_RUN" = true ]; then
    RSYNC_OPTS="$RSYNC_OPTS --dry-run"
    echo "=== MODE SIMULATION ==="
fi

#------------------------------------------------------------------------------
# EXÉCUTION
#------------------------------------------------------------------------------
echo "Source      : $SOURCE"
echo "Destination : $DESTINATION"
echo "Options     : $RSYNC_OPTS"
echo ""

rsync $RSYNC_OPTS "$SOURCE" "$DESTINATION"
```

> [!tip] Bonnes pratiques pour les paramètres
> 
> - **Fournir une aide** avec `-h` ou `--help`
> - **Valeurs par défaut** raisonnables
> - **Validation** des arguments avant exécution
> - **Messages clairs** en cas d'erreur

### Variables d'environnement et fichiers de configuration

Pour éviter de coder en dur des informations sensibles :

```bash
#!/bin/bash

#------------------------------------------------------------------------------
# CHARGEMENT DU FICHIER DE CONFIGURATION
#------------------------------------------------------------------------------
CONFIG_FILE="/etc/rsync/backup.conf"

if [ -f "$CONFIG_FILE" ]; then
    # Source le fichier de configuration
    source "$CONFIG_FILE"
else
    echo "Fichier de configuration non trouvé: $CONFIG_FILE"
    exit 1
fi

#------------------------------------------------------------------------------
# VÉRIFICATION DES VARIABLES REQUISES
#------------------------------------------------------------------------------
required_vars=("SOURCE_DIR" "BACKUP_DIR" "BACKUP_USER" "BACKUP_HOST")

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Erreur: Variable $var non définie dans $CONFIG_FILE"
        exit 1
    fi
done

#------------------------------------------------------------------------------
# UTILISATION DES VARIABLES DU FICHIER DE CONFIG
#------------------------------------------------------------------------------
rsync -avh --delete \
      "$SOURCE_DIR" \
      "${BACKUP_USER}@${BACKUP_HOST}:${BACKUP_DIR}"
```

**Fichier de configuration (`/etc/rsync/backup.conf`) :**

```bash
# Configuration de sauvegarde rsync

# Source
SOURCE_DIR="/home/"

# Destination distante
BACKUP_USER="backup"
BACKUP_HOST="backup.example.com"
BACKUP_DIR="/backups/home/"

# Options
RETENTION_DAYS=30
LOG_DIR="/var/log/rsync"

# Exclusions
EXCLUDE_PATTERNS=(
    ".cache"
    "*.tmp"
    ".local/share/Trash"
)
```

> [!warning] Sécurité des fichiers de configuration
> 
> - **Permissions restrictives** : `chmod 600 /etc/rsync/backup.conf`
> - **Pas de mots de passe** : Utilisez des clés SSH
> - **Propriétaire correct** : `chown root:root` pour les configs système

### Script modulaire avec fonctions

```bash
#!/bin/bash

#------------------------------------------------------------------------------
# CONFIGURATION
#------------------------------------------------------------------------------
CONFIG_FILE="/etc/rsync/backup.conf"
source "$CONFIG_FILE"

#------------------------------------------------------------------------------
# FONCTIONS UTILITAIRES
#------------------------------------------------------------------------------
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $@"
    exit 1
}

check_dependencies() {
    for cmd in rsync mail df; do
        if ! command -v $cmd &> /dev/null; then
            error "Commande requise non trouvée: $cmd"
        fi
    done
}

check_disk_space() {
    local required=$1
    local destination=$2
    local available=$(df -B1 "$destination" | tail -1 | awk '{print $4}')
    
    if [ "$available" -lt "$required" ]; then
        error "Espace insuffisant (requis: $required, dispo: $available)"
    fi
}

send_notification() {
    local status=$1
    local message=$2
    
    if [ "$ENABLE_EMAIL" = true ]; then
        echo "$message" | mail -s "Sauvegarde rsync: $status" "$ADMIN_EMAIL"
    fi
}

perform_backup() {
    log "Démarrage de la sauvegarde"
    
    rsync -avh --delete --stats \
          "$SOURCE_DIR" "$BACKUP_DIR" \
          >> "$LOG_FILE" 2>&1
    
    return $?
}

cleanup_old_backups() {
    log "Nettoyage des sauvegardes de plus de $RETENTION_DAYS jours"
    
    find "$BACKUP_ROOT" -name "backup-*" -type d -mtime +$RETENTION_DAYS -delete
}

#------------------------------------------------------------------------------
# PROGRAMME PRINCIPAL
#------------------------------------------------------------------------------
main() {
    log "=== Début du script de sauvegarde ==="
    
    check_dependencies
    
    REQUIRED_SPACE=$(du -sb "$SOURCE_DIR" | cut -f1)
    check_disk_space "$REQUIRED_SPACE" "$BACKUP_DIR"
    
    if perform_backup; then
        log "Sauvegarde réussie"
        send_notification "SUCCESS" "La sauvegarde s'est terminée avec succès"
        cleanup_old_backups
    else
        EXIT_CODE=$?
        log "Sauvegarde échouée (code: $EXIT_CODE)"
        send_notification "FAILURE" "La sauvegarde a échoué avec le code $EXIT_CODE"
        exit $EXIT_CODE
    fi
    
    log "=== Fin du script ==="
}

#------------------------------------------------------------------------------
# LANCEMENT
#------------------------------------------------------------------------------
main "$@"
```

> [!example] Avantages d'un script modulaire
> 
> - **Réutilisabilité** : Les fonctions peuvent être appelées plusieurs fois
> - **Testabilité** : Chaque fonction peut être testée indépendamment
> - **Maintenabilité** : Code organisé et facile à modifier
> - **Clarté** : La fonction `main()` montre le flux principal

---

## 🎯 Pièges courants

|Piège|Problème|Solution|
|---|---|---|
|Variables non quotées|`$SOURCE` contenant des espaces casse le script|Toujours utiliser `"$VARIABLE"`|
|Pas de gestion d'erreur|Script continue après échec rsync|Vérifier `$?` ou utiliser `set -e`|
|Logs qui grossissent|Fichier log devient énorme|Rotation quotidienne + nettoyage|
|Chemins relatifs|Script se comporte différemment selon où il est lancé|Utiliser chemins absolus|
|Permissions insuffisantes|Script ne peut pas écrire les logs|Vérifier permissions ou utiliser sudo|
|Pas de test en dry-run|Erreur détectée trop tard|Tester avec `--dry-run` d'abord|

> [!warning] Sécurité des scripts
> 
> - **Ne jamais** stocker de mots de passe en clair dans le script
> - **Permissions** : `chmod 700` pour les scripts sensibles
> - **Propriétaire** : Appartenance à l'utilisateur qui l'exécute
> - **Validation** : Vérifier toutes les entrées utilisateur

---

## ✨ Astuces avancées

### 1. Verrou pour éviter les exécutions simultanées

```bash
LOCKFILE="/var/run/rsync-backup.lock"

if [ -f "$LOCKFILE" ]; then
    echo "Une sauvegarde est déjà en cours"
    exit 1
fi

touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

# Votre sauvegarde ici
rsync -avh /home/ /backup/home/
```

### 2. Barre de progression personnalisée

```bash
rsync -avh --progress /home/ /backup/home/ | \
    grep -oP '\d+%' | \
    while read -r percent; do
        echo -ne "Progression: $percent\r"
    done
echo ""
```

### 3. Sauvegarde avec horodatage dans le nom

```bash
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
BACKUP_DIR="/backup/home-$TIMESTAMP"

rsync -avh /home/ "$BACKUP_DIR"
ln -sfn "$BACKUP_DIR" /backup/home-latest
```

### 4. Statistiques en base de données

```bash
# Insertion dans SQLite
DURATION=$((END_TIME - START_TIME))
FILES_TRANSFERRED=$(grep "Number of files transferred" "$LOG_FILE" | awk '{print $5}')

sqlite3 /var/db/backup-stats.db <<EOF
INSERT INTO backups (date, duration, files, status)
VALUES ('$(date '+%Y-%m-%d %H:%M:%S')', $DURATION, $FILES_TRANSFERRED, 'SUCCESS');
EOF
```

---

**Vous maîtrisez maintenant la création de scripts de sauvegarde robustes avec rsync !** 🎉