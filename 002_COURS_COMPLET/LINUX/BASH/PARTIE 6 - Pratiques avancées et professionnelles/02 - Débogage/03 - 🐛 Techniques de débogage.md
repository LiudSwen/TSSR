

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

## 🎯 Introduction au débogage

Le débogage est une compétence essentielle pour identifier et corriger les erreurs dans vos scripts Bash. Contrairement aux langages compilés, Bash s'exécute ligne par ligne, ce qui rend le débogage à la fois plus simple (pas de compilation) et plus complexe (erreurs découvertes à l'exécution).

> [!info] Pourquoi déboguer en Bash ?
> 
> - Identifier les valeurs de variables à des moments précis
> - Comprendre le flux d'exécution du script
> - Détecter les erreurs logiques non visibles
> - Tracer les problèmes dans des scripts complexes
> - Faciliter la maintenance et l'évolution du code

---

## 🔍 Tracer l'exécution avec echo

### Principe de base

La commande `echo` est l'outil de débogage le plus simple et le plus universel en Bash. Elle permet d'afficher des messages à des points stratégiques pour suivre l'exécution du script.

```bash
#!/bin/bash

echo "Début du script"

# Traitement quelconque
result=$((5 + 3))

echo "Calcul effectué"

# Suite du script
echo "Fin du script"
```

### Techniques avancées avec echo

#### Ajout de marqueurs visuels

```bash
#!/bin/bash

echo "=========================================="
echo "DÉBUT: Traitement des fichiers"
echo "=========================================="

for file in *.txt; do
    echo "  → Traitement: $file"
    # Opérations sur le fichier
done

echo "=========================================="
echo "FIN: Traitement terminé"
echo "=========================================="
```

#### Traçage avec numéros de ligne

```bash
#!/bin/bash

echo "[LIGNE $LINENO] Initialisation"
variable="valeur"

echo "[LIGNE $LINENO] Variable assignée"

if [[ -n "$variable" ]]; then
    echo "[LIGNE $LINENO] Condition vraie"
fi
```

#### Messages de debug conditionnels

```bash
#!/bin/bash

DEBUG=true  # Activer/désactiver le mode debug

if [[ "$DEBUG" == true ]]; then
    echo "[DEBUG] Script démarré à $(date)"
fi

# Code principal
resultat=$((10 * 5))

if [[ "$DEBUG" == true ]]; then
    echo "[DEBUG] Résultat du calcul: $resultat"
fi
```

> [!tip] Astuce professionnelle Utilisez `>&2` pour envoyer les messages de debug vers stderr, ce qui permet de séparer les sorties normales des messages de debug :
> 
> ```bash
> echo "[DEBUG] Message de débogage" >&2
> ```

> [!warning] Pièges à éviter
> 
> - N'oubliez pas de retirer ou désactiver les `echo` de debug en production
> - Évitez de déboguer dans des boucles à forte itération (risque de surcharge)
> - Les `echo` peuvent ralentir considérablement l'exécution

---

## 📊 Affichage de variables

### Affichage simple

```bash
#!/bin/bash

nom="Alice"
age=30

echo "Variable nom: $nom"
echo "Variable age: $age"
```

### Affichage formaté et détaillé

#### Avec étiquettes claires

```bash
#!/bin/bash

utilisateur="bob"
chemin="/home/bob/documents"
compteur=42

echo "=== État des variables ==="
echo "Utilisateur    : $utilisateur"
echo "Chemin         : $chemin"
echo "Compteur       : $compteur"
echo "=========================="
```

#### Affichage du type et du contenu

```bash
#!/bin/bash

# Afficher la valeur et la longueur
texte="Bonjour le monde"
echo "Valeur: $texte"
echo "Longueur: ${#texte} caractères"

# Afficher si la variable est vide
if [[ -z "$texte" ]]; then
    echo "Variable vide"
else
    echo "Variable non vide"
fi
```

### Affichage de variables complexes

#### Tableaux

```bash
#!/bin/bash

fruits=("pomme" "banane" "orange")

echo "=== Contenu du tableau ==="
echo "Tous les éléments: ${fruits[@]}"
echo "Nombre d'éléments: ${#fruits[@]}"
echo "Premier élément: ${fruits[0]}"
echo "Dernier élément: ${fruits[-1]}"

# Afficher avec les indices
for i in "${!fruits[@]}"; do
    echo "  fruits[$i] = ${fruits[$i]}"
done
```

#### Variables d'environnement

```bash
#!/bin/bash

echo "=== Variables système ==="
echo "PATH: $PATH"
echo "HOME: $HOME"
echo "USER: $USER"
echo "PWD: $PWD"
echo "SHELL: $SHELL"
```

### Techniques avancées d'inspection

#### Utiliser set pour afficher toutes les variables

```bash
#!/bin/bash

# Afficher uniquement les variables personnalisées
echo "=== Variables du script ==="
set | grep -E "^[a-z_]+" | head -20
```

#### Afficher avec declare

```bash
#!/bin/bash

# Déclarer des variables typées
declare -i nombre=42
declare -r constante="fixe"
declare -a tableau=("a" "b" "c")

# Afficher les variables avec leurs attributs
echo "=== Variables déclarées ==="
declare -p nombre
declare -p constante
declare -p tableau
```

> [!example] Exemple pratique de debug de variables
> 
> ```bash
> #!/bin/bash
> 
> fonction_calcul() {
>     local a=$1
>     local b=$2
>     
>     echo "[DEBUG] Entrée fonction: a=$a, b=$b" >&2
>     
>     local resultat=$((a + b))
>     
>     echo "[DEBUG] Résultat calculé: $resultat" >&2
>     
>     echo "$resultat"
> }
> 
> valeur=$(fonction_calcul 10 20)
> echo "Valeur finale: $valeur"
> ```

> [!tip] Astuce pour les variables non définies Utilisez `${variable:-défaut}` pour afficher une valeur par défaut si la variable est vide :
> 
> ```bash
> echo "Utilisateur: ${USER:-'non défini'}"
> ```

---

## ⏸️ Points d'arrêt avec read

### Principe du point d'arrêt

La commande `read` permet de suspendre l'exécution du script jusqu'à ce que l'utilisateur appuie sur Entrée. C'est l'équivalent d'un breakpoint dans un débogueur.

```bash
#!/bin/bash

echo "Avant le point d'arrêt"
variable="test"

read -p "Point d'arrêt - Appuyez sur Entrée pour continuer..."

echo "Après le point d'arrêt"
echo "Variable: $variable"
```

### Points d'arrêt conditionnels

```bash
#!/bin/bash

DEBUG=true

for i in {1..10}; do
    resultat=$((i * 2))
    
    # Point d'arrêt uniquement en mode debug
    if [[ "$DEBUG" == true && $i -eq 5 ]]; then
        echo "=== Point d'arrêt atteint ==="
        echo "Itération: $i"
        echo "Résultat: $resultat"
        read -p "Continuer ? (Entrée) "
    fi
done
```

### Points d'arrêt avec inspection

```bash
#!/bin/bash

point_arret() {
    local message="$1"
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║         POINT D'ARRÊT                  ║"
    echo "╚════════════════════════════════════════╝"
    echo "Message: $message"
    echo "Ligne: ${BASH_LINENO[0]}"
    echo ""
    echo "Variables locales:"
    local
    echo ""
    read -p "→ Appuyez sur Entrée pour continuer..."
    echo ""
}

# Utilisation
compteur=0
nom="test"

point_arret "Avant la boucle"

for i in {1..3}; do
    compteur=$((compteur + i))
done

point_arret "Après la boucle"
```

### Points d'arrêt avec options

```bash
#!/bin/bash

point_arret_avance() {
    echo ""
    echo "=== DÉBOGUEUR ==="
    echo "c) Continuer"
    echo "v) Afficher les variables"
    echo "q) Quitter"
    echo -n "Choix: "
    
    read -n 1 choix
    echo ""
    
    case "$choix" in
        c|C)
            echo "Continue..."
            ;;
        v|V)
            echo "Variables:"
            set | grep -E "^[a-z_]+" | head -10
            point_arret_avance  # Rappel récursif
            ;;
        q|Q)
            echo "Arrêt du script"
            exit 0
            ;;
        *)
            echo "Choix invalide"
            point_arret_avance
            ;;
    esac
}

# Utilisation
x=10
y=20

point_arret_avance
```

### Point d'arrêt avec timeout

```bash
#!/bin/bash

# Continue automatiquement après 10 secondes
read -t 10 -p "Point d'arrêt (auto-continue dans 10s)..."
if [[ $? -eq 0 ]]; then
    echo "Continué manuellement"
else
    echo "Timeout - continuation automatique"
fi
```

> [!warning] Attention en production Les points d'arrêt `read` sont excellents pour le développement, mais :
> 
> - Ne les laissez jamais dans un script de production
> - Ils bloquent l'exécution indéfiniment sans interaction
> - Utilisez une variable globale DEBUG pour les activer/désactiver

> [!tip] Astuce pour le debug rapide Créez un alias dans votre `.bashrc` :
> 
> ```bash
> alias bp='read -p "⏸️  Point d arrêt - Entrée pour continuer..."'
> ```
> 
> Utilisez simplement `bp` dans vos scripts pour ajouter rapidement un breakpoint.

---

## 📝 Logs dans fichiers

### Principe du logging dans fichiers

Écrire les logs dans des fichiers permet de conserver une trace persistante de l'exécution, utile pour l'analyse post-mortem et la surveillance.

```bash
#!/bin/bash

LOG_FILE="/tmp/mon_script.log"

# Écrire dans le fichier de log
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script démarré" >> "$LOG_FILE"

# Code du script
resultat=$((5 * 10))

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Calcul effectué: $resultat" >> "$LOG_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script terminé" >> "$LOG_FILE"
```

### Redirection vers fichier de log

#### Redirection simple

```bash
#!/bin/bash

LOG_FILE="script.log"

# Rediriger toute la sortie standard vers le fichier
exec > "$LOG_FILE"

echo "Ce message ira dans le fichier"
echo "Début du traitement: $(date)"

# Le script continue...
for i in {1..5}; do
    echo "Itération $i"
done
```

#### Redirection double (stdout + stderr)

```bash
#!/bin/bash

LOG_FILE="script.log"

# Rediriger stdout et stderr vers le fichier
exec > "$LOG_FILE" 2>&1

echo "Message normal"
echo "Message d'erreur" >&2
ls fichier_inexistant  # L'erreur ira aussi dans le log
```

#### Conservation de la sortie console

```bash
#!/bin/bash

LOG_FILE="script.log"

# Dupliquer la sortie: fichier ET console
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "Ce message apparaît dans le terminal ET dans le fichier"
```

### Gestion de fichiers de log

#### Rotation des logs

```bash
#!/bin/bash

LOG_FILE="application.log"
MAX_SIZE=$((10 * 1024 * 1024))  # 10 MB

# Vérifier la taille du fichier
if [[ -f "$LOG_FILE" ]]; then
    size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null)
    
    if [[ $size -gt $MAX_SIZE ]]; then
        # Rotation: renommer l'ancien fichier
        timestamp=$(date '+%Y%m%d_%H%M%S')
        mv "$LOG_FILE" "${LOG_FILE}.${timestamp}"
        echo "Log roté vers ${LOG_FILE}.${timestamp}"
    fi
fi

# Continuer à écrire dans le nouveau fichier
echo "[$(date)] Nouveau message" >> "$LOG_FILE"
```

#### Archivage automatique

```bash
#!/bin/bash

LOG_DIR="/var/log/mon_app"
LOG_FILE="$LOG_DIR/current.log"
ARCHIVE_DIR="$LOG_DIR/archives"

# Créer les répertoires si nécessaire
mkdir -p "$ARCHIVE_DIR"

# Archiver le log du jour précédent
if [[ -f "$LOG_FILE" ]]; then
    # Vérifier si le fichier date d'hier
    file_date=$(date -r "$LOG_FILE" '+%Y-%m-%d' 2>/dev/null || stat -c%y "$LOG_FILE" | cut -d' ' -f1)
    today=$(date '+%Y-%m-%d')
    
    if [[ "$file_date" != "$today" ]]; then
        # Compresser et archiver
        gzip -c "$LOG_FILE" > "$ARCHIVE_DIR/log_${file_date}.log.gz"
        > "$LOG_FILE"  # Vider le fichier actuel
    fi
fi
```

### Formats de log structurés

#### Format avec horodatage précis

```bash
#!/bin/bash

log_to_file() {
    local message="$1"
    local logfile="${2:-/tmp/script.log}"
    
    # Format: [YYYY-MM-DD HH:MM:SS.mmm] message
    echo "[$(date '+%Y-%m-%d %H:%M:%S.%3N')] $message" >> "$logfile"
}

log_to_file "Démarrage de l'application"
log_to_file "Connexion établie"
```

#### Format avec niveau et contexte

```bash
#!/bin/bash

LOG_FILE="app.log"

log_entry() {
    local level="$1"
    local message="$2"
    local script_name=$(basename "$0")
    local line_number="${BASH_LINENO[0]}"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] [$script_name:$line_number] $message" >> "$LOG_FILE"
}

log_entry "INFO" "Application démarrée"
log_entry "ERROR" "Fichier non trouvé"
```

### Logs séparés par type

```bash
#!/bin/bash

INFO_LOG="info.log"
ERROR_LOG="error.log"
DEBUG_LOG="debug.log"

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" >> "$INFO_LOG"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$ERROR_LOG"
}

log_debug() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] DEBUG: $1" >> "$DEBUG_LOG"
}

# Utilisation
log_info "Traitement démarré"
log_debug "Variable x = 42"
log_error "Échec de connexion"
```

> [!warning] Gestion de l'espace disque
> 
> - Surveillez la taille des fichiers de log pour éviter de saturer le disque
> - Mettez en place une rotation automatique
> - Utilisez la compression pour les archives
> - Définissez une politique de rétention (ex: garder 30 jours)

> [!tip] Bonnes pratiques
> 
> - Utilisez des chemins absolus pour les fichiers de log
> - Vérifiez les permissions d'écriture avant de logger
> - Incluez toujours un horodatage dans vos logs
> - Utilisez `>>` (append) plutôt que `>` (overwrite) pour ne pas perdre les logs précédents

---

## 🔧 Fonction de logging personnalisée

### Fonction de base

```bash
#!/bin/bash

log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message"
}

# Utilisation
log "Script démarré"
log "Traitement en cours"
log "Script terminé"
```

### Fonction avec sortie fichier et console

```bash
#!/bin/bash

LOG_FILE="/tmp/script.log"

log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] $message"
    
    # Afficher dans le terminal
    echo "$log_entry"
    
    # Écrire dans le fichier
    echo "$log_entry" >> "$LOG_FILE"
}

# Utilisation
log "Message visible partout"
```

### Fonction avec niveaux de log

```bash
#!/bin/bash

LOG_FILE="application.log"

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Format: [timestamp] [LEVEL] message
    local log_entry="[$timestamp] [$level] $message"
    
    echo "$log_entry" | tee -a "$LOG_FILE"
}

# Utilisation
log "INFO" "Application démarrée"
log "WARNING" "Mémoire faible"
log "ERROR" "Connexion échouée"
```

### Fonction avancée avec couleurs

```bash
#!/bin/bash

LOG_FILE="app.log"

# Codes couleur ANSI
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Entrée de log sans couleur pour le fichier
    local log_entry="[$timestamp] [$level] $message"
    echo "$log_entry" >> "$LOG_FILE"
    
    # Affichage avec couleur dans le terminal
    case "$level" in
        "ERROR")
            echo -e "${RED}[$timestamp] [$level] $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}[$timestamp] [$level] $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[$timestamp] [$level] $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}[$timestamp] [$level] $message${NC}"
            ;;
        *)
            echo "[$timestamp] [$level] $message"
            ;;
    esac
}

# Utilisation
log "INFO" "Démarrage du système"
log "SUCCESS" "Connexion établie"
log "WARNING" "Cache non trouvé"
log "ERROR" "Échec de l'authentification"
```

### Fonction avec contexte enrichi

```bash
#!/bin/bash

LOG_FILE="detailed.log"

log() {
    local level="$1"
    shift
    local message="$*"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    local script_name=$(basename "$0")
    local function_name="${FUNCNAME[1]}"
    local line_number="${BASH_LINENO[0]}"
    local pid=$$
    
    # Format détaillé
    local log_entry="[$timestamp] [$level] [$script_name:$function_name:$line_number] [PID:$pid] $message"
    
    echo "$log_entry" >> "$LOG_FILE"
    echo "$log_entry"
}

ma_fonction() {
    log "INFO" "Fonction appelée"
    # Code de la fonction
}

log "INFO" "Script principal"
ma_fonction
```

### Fonction avec gestion d'erreur intégrée

```bash
#!/bin/bash

LOG_FILE="app.log"

log() {
    local level="$1"
    shift
    local message="$*"
    
    # Vérifier si le fichier est accessible en écriture
    if [[ ! -w "$(dirname "$LOG_FILE")" ]]; then
        echo "ERREUR: Impossible d'écrire dans $LOG_FILE" >&2
        return 1
    fi
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"
    
    # Tentative d'écriture avec gestion d'erreur
    if ! echo "$log_entry" >> "$LOG_FILE" 2>/dev/null; then
        echo "ERREUR: Échec d'écriture dans le log" >&2
        return 1
    fi
    
    echo "$log_entry"
    return 0
}

# Utilisation
log "INFO" "Message de test" || echo "Le logging a échoué"
```

### Fonction avec rotation intégrée

```bash
#!/bin/bash

LOG_FILE="rotating.log"
MAX_LOG_SIZE=$((5 * 1024 * 1024))  # 5 MB

rotate_log() {
    if [[ -f "$LOG_FILE" ]]; then
        local size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null)
        
        if [[ $size -gt $MAX_LOG_SIZE ]]; then
            local timestamp=$(date '+%Y%m%d_%H%M%S')
            mv "$LOG_FILE" "${LOG_FILE}.${timestamp}"
            gzip "${LOG_FILE}.${timestamp}" &
        fi
    fi
}

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Rotation si nécessaire
    rotate_log
    
    # Écriture du log
    local log_entry="[$timestamp] [$level] $message"
    echo "$log_entry" >> "$LOG_FILE"
    echo "$log_entry"
}

# Utilisation
log "INFO" "Message avec rotation automatique"
```

> [!example] Fonction de log complète et réutilisable
> 
> ```bash
> #!/bin/bash
> 
> # Configuration
> LOG_FILE="${LOG_FILE:-/tmp/script.log}"
> LOG_LEVEL="${LOG_LEVEL:-INFO}"
> 
> # Niveaux de log (ordre de priorité)
> declare -A LOG_LEVELS=( ["DEBUG"]=0 ["INFO"]=1 ["WARNING"]=2 ["ERROR"]=3 )
> 
> log() {
>     local level="$1"
>     shift
>     local message="$*"
>     
>     # Vérifier si le niveau doit être loggé
>     if [[ ${LOG_LEVELS[$level]} -lt ${LOG_LEVELS[$LOG_LEVEL]} ]]; then
>         return 0
>     fi
>     
>     local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
>     local log_entry="[$timestamp] [$level] $message"
>     
>     echo "$log_entry" | tee -a "$LOG_FILE"
> }
> 
> # Raccourcis pratiques
> log_debug() { log "DEBUG" "$@"; }
> log_info() { log "INFO" "$@"; }
> log_warning() { log "WARNING" "$@"; }
> log_error() { log "ERROR" "$@"; }
> 
> # Utilisation
> log_debug "Détail technique"
> log_info "Information générale"
> log_warning "Attention requise"
> log_error "Erreur critique"
> ```

> [!tip] Réutilisation de fonctions de log Créez un fichier `logging.sh` contenant vos fonctions de log et sourcez-le dans vos scripts :
> 
> ```bash
> source /chemin/vers/logging.sh
> log "INFO" "Mon message"
> ```

---

## 📊 Niveaux de log

### Principe des niveaux de log

Les niveaux de log permettent de catégoriser les messages selon leur importance et de filtrer les informations affichées selon le contexte (développement, production, debug).

### Niveaux standard

|Niveau|Priorité|Usage|
|---|---|---|
|**DEBUG**|0|Informations détaillées pour le développement|
|**INFO**|1|Messages informatifs sur le déroulement normal|
|**WARNING**|2|Situations anormales mais non critiques|
|**ERROR**|3|Erreurs nécessitant attention|
|**CRITICAL**|4|Erreurs graves menaçant l'exécution|

### Implémentation basique

```bash
#!/bin/bash

LOG_LEVEL="INFO"

log_debug() {
    [[ "$LOG_LEVEL" == "DEBUG" ]] && echo "[DEBUG] $*"
}

log_info() {
    [[ "$LOG_LEVEL" =~ ^(DEBUG|INFO)$ ]] && echo "[INFO] $*"
}

log_warning() {
    [[ "$LOG_LEVEL" =~ ^(DEBUG|INFO|WARNING)$ ]] && echo "[WARNING] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Utilisation
log_debug "Valeur de x: 42"
log_info "Traitement démarré"
log_warning "Cache expiré"
log_error "Fichier non trouvé"
```

### Implémentation avec contrôle de niveau

```bash
#!/bin/bash

# Configuration du niveau de log global
LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Définition des niveaux avec priorités
declare -A LOG_PRIORITIES=(
    ["DEBUG"]=0
    ["INFO"]=1
    ["WARNING"]=2
    ["ERROR"]=3
    ["CRITICAL"]=4
)

should_log() {
    local message_level="$1"
    local current_priority=${LOG_PRIORITIES[$LOG_LEVEL]}
    local message_priority=${LOG_PRIORITIES[$message_level]}
    
    [[ $message_priority -ge $current_priority ]]
}

log() {
    local level="$1"
    shift
    local message="$*"
    
    if should_log "$level"; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] [$level] $message"
    fi
}

# Utilisation
log "DEBUG" "Détail technique"         # N'apparaît pas si LOG_LEVEL=INFO
log "INFO" "Opération normale"         # Apparaît
log "WARNING" "Attention nécessaire"   # Apparaît
log "ERROR" "Problème détecté"         # Apparaît
```

### Système complet avec couleurs et fichiers

```bash
#!/bin/bash

# Configuration
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-app.log}"
ENABLE_COLORS="${ENABLE_COLORS:-true}"

# Couleurs
declare -A COLORS=(
    ["DEBUG"]='\033[0;36m'      # Cyan
    ["INFO"]='\033[0;32m'       # Vert
    ["WARNING"]='\033[1;33m'    # Jaune
    ["ERROR"]='\033[0;31m'      # Rouge
    ["CRITICAL"]='\033[1;35m'   # Magenta
    ["RESET"]='\033[0m'         # Reset
)

# Niveaux
declare -A LOG_PRIORITIES=(
    ["DEBUG"]=0
    ["INFO"]=1
    ["WARNING"]=2
    ["ERROR"]=3
    ["CRITICAL"]=4
)

should_log() {
    local level="$1"
    [[ ${LOG_PRIORITIES[$level]} -ge ${LOG_PRIORITIES[$LOG_LEVEL]} ]]
}

log() {
    local level="$1"
    shift
    local message="$*"
    
    # Vérifier si on doit logger ce niveau
    if ! should_log "$level"; then
        return 0
    fi
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"
    
    # Écrire dans le fichier (sans couleur)
    echo "$log_entry" >> "$LOG_FILE"
    
    # Afficher dans le terminal (avec couleur si activé)
    if [[ "$ENABLE_COLORS" == "true" ]]; then
        local color="${COLORS[$level]}"
        local reset="${COLORS[RESET]}"
        echo -e "${color}${log_entry}${reset}"
    else
        echo "$log_entry"
    fi
}

# Fonctions de raccourci
log_debug() { log "DEBUG" "$@"; }
log_info() { log "INFO" "$@"; }
log_warning() { log "WARNING" "$@"; }
log_error() { log "ERROR" "$@"; }
log_critical() { log "CRITICAL" "$@"; }

# Exemple d'utilisation
log_debug "Variable x initialisée à 42"
log_info "Connexion à la base de données établie"
log_warning "Temps de réponse supérieur à 2 secondes"
log_error "Échec de l'authentification pour l'utilisateur bob"
log_critical "Mémoire insuffisante - arrêt du système"
```

### Changement dynamique du niveau

```bash
#!/bin/bash

LOG_LEVEL="INFO"

set_log_level() {
    local new_level="$1"
    
    # Vérifier que le niveau est valide
    if [[ -n "${LOG_PRIORITIES[$new_level]}" ]]; then
        LOG_LEVEL="$new_level"
        log "INFO" "Niveau de log changé à $new_level"
    else
        log "ERROR" "Niveau de log invalide: $new_level"
        return 1
    fi
}

# Utilisation
set_log_level "DEBUG"
log_debug "Ce message apparaît maintenant"

set_log_level "ERROR"
log_info "Ce message n'apparaît plus"
log_error "Ce message apparaît toujours"
```

### Niveaux avec contexte d'exécution

```bash
#!/bin/bash

# Adapter automatiquement le niveau selon l'environnement
if [[ -n "$PRODUCTION" ]]; then
    LOG_LEVEL="WARNING"
elif [[ -n "$STAGING" ]]; then
    LOG_LEVEL="INFO"
else
    LOG_LEVEL="DEBUG"  # Développement
fi

log() {
    local level="$1"
    shift
    local message="$*"
    
    if should_log "$level"; then
        local env_tag=""
        [[ -n "$PRODUCTION" ]] && env_tag="[PROD]"
        [[ -n "$STAGING" ]] && env_tag="[STAGING]"
        [[ -z "$env_tag" ]] && env_tag="[DEV]"
        
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] $env_tag [$level] $message"
    fi
}
```

### Filtrage par composant

```bash
#!/bin/bash

LOG_LEVEL="INFO"
LOG_COMPONENTS="${LOG_COMPONENTS:-*}"  # Par défaut, tous les composants

log_component() {
    local component="$1"
    local level="$2"
    shift 2
    local message="$*"
    
    # Vérifier si ce composant doit être loggé
    if [[ "$LOG_COMPONENTS" != "*" ]] && [[ ! "$LOG_COMPONENTS" =~ $component ]]; then
        return 0
    fi
    
    if should_log "$level"; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] [$component] [$level] $message"
    fi
}

# Utilisation
log_component "DATABASE" "INFO" "Connexion établie"
log_component "API" "WARNING" "Timeout dépassé"
log_component "CACHE" "DEBUG" "Clé non trouvée"

# Pour ne logger que certains composants:
# export LOG_COMPONENTS="DATABASE,API"
```

### Agrégation de statistiques par niveau

```bash
#!/bin/bash

# Compteurs
declare -A LOG_COUNTS=(
    ["DEBUG"]=0
    ["INFO"]=0
    ["WARNING"]=0
    ["ERROR"]=0
    ["CRITICAL"]=0
)

log() {
    local level="$1"
    shift
    local message="$*"
    
    # Incrémenter le compteur
    ((LOG_COUNTS[$level]++))
    
    if should_log "$level"; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] [$level] $message"
    fi
}

print_log_stats() {
    echo ""
    echo "=== Statistiques de log ==="
    for level in DEBUG INFO WARNING ERROR CRITICAL; do
        echo "$level: ${LOG_COUNTS[$level]}"
    done
    echo "=========================="
}

# À la fin du script
trap print_log_stats EXIT
```

### Format JSON pour analyse automatisée

```bash
#!/bin/bash

LOG_FORMAT="${LOG_FORMAT:-text}"  # text ou json

log() {
    local level="$1"
    shift
    local message="$*"
    
    if ! should_log "$level"; then
        return 0
    fi
    
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')  # ISO 8601
    
    if [[ "$LOG_FORMAT" == "json" ]]; then
        # Format JSON pour parsing automatique
        cat << EOF
{"timestamp":"$timestamp","level":"$level","message":"$message","pid":$,"script":"$(basename "$0")"}
EOF
    else
        # Format texte classique
        echo "[$timestamp] [$level] $message"
    fi
}

# Utilisation
# LOG_FORMAT=json ./script.sh | jq .
log "INFO" "Message au format JSON"
```

> [!example] Système complet de logging avec niveaux
> 
> ```bash
> #!/bin/bash
> 
> # === Configuration ===
> LOG_LEVEL="${LOG_LEVEL:-INFO}"
> LOG_FILE="${LOG_FILE:-/tmp/app.log}"
> 
> declare -A LOG_PRIORITIES=(["DEBUG"]=0 ["INFO"]=1 ["WARNING"]=2 ["ERROR"]=3)
> 
> # === Fonction principale ===
> log() {
>     local level="$1"
>     shift
>     
>     # Filtrer par priorité
>     [[ ${LOG_PRIORITIES[$level]} -lt ${LOG_PRIORITIES[$LOG_LEVEL]} ]] && return 0
>     
>     local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
>     local entry="[$timestamp] [$level] $*"
>     
>     echo "$entry" | tee -a "$LOG_FILE"
> }
> 
> # === Raccourcis ===
> debug() { log "DEBUG" "$@"; }
> info() { log "INFO" "$@"; }
> warn() { log "WARNING" "$@"; }
> error() { log "ERROR" "$@"; }
> 
> # === Utilisation ===
> debug "Initialisation des variables"
> info "Démarrage du traitement"
> warn "Fichier de config non trouvé, utilisation des valeurs par défaut"
> error "Échec de connexion au serveur"
> ```

> [!tip] Configuration via variables d'environnement Permettez aux utilisateurs de votre script de contrôler le logging :
> 
> ```bash
> # Développement avec debug complet
> LOG_LEVEL=DEBUG ./mon_script.sh
> 
> # Production avec uniquement les erreurs
> LOG_LEVEL=ERROR LOG_FILE=/var/log/prod.log ./mon_script.sh
> 
> # Format JSON pour monitoring
> LOG_FORMAT=json ./mon_script.sh | jq -r 'select(.level=="ERROR")'
> ```

> [!warning] Performance et niveaux de log
> 
> - Les messages DEBUG peuvent ralentir considérablement un script en production
> - Utilisez toujours le niveau approprié en production (WARNING ou ERROR)
> - Les logs excessifs peuvent saturer le disque rapidement
> - Considérez l'impact sur les performances avant de logger dans des boucles intensives

### Bonnes pratiques pour les niveaux de log

#### Quand utiliser chaque niveau

**DEBUG** 🔍

- Valeurs de variables intermédiaires
- Entrée/sortie de fonctions
- Détails d'algorithmes
- Informations utiles uniquement au développement

```bash
debug "Fonction calculate appelée avec a=$a, b=$b"
debug "Résultat intermédiaire: $result"
```

**INFO** ℹ️

- Événements normaux importants
- Étapes principales du traitement
- Succès d'opérations
- Démarrage/arrêt de services

```bash
info "Application démarrée avec succès"
info "Traitement de 150 fichiers terminé"
```

**WARNING** ⚠️

- Situations anormales mais gérées
- Valeurs par défaut utilisées
- Performances dégradées
- Comportements inattendus mais non bloquants

```bash
warn "Fichier de configuration non trouvé, utilisation des valeurs par défaut"
warn "Temps de réponse supérieur à la normale: ${response_time}s"
```

**ERROR** ❌

- Échecs d'opérations
- Erreurs récupérables
- Problèmes nécessitant attention
- Données manquantes ou invalides

```bash
error "Impossible de se connecter à la base de données"
error "Le fichier $file_path n'existe pas"
```

**CRITICAL** 🚨

- Erreurs fatales
- Impossibilité de continuer
- Corruption de données
- Situations nécessitant intervention immédiate

```bash
critical "Mémoire insuffisante - arrêt du programme"
critical "Corruption détectée dans $database_file"
```

### Exemple d'application complète

```bash
#!/bin/bash

# ============================================
# Système de logging professionnel
# ============================================

set -euo pipefail

# === Configuration ===
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-/var/log/myapp/app.log}"
LOG_DIR=$(dirname "$LOG_FILE")

# Couleurs
declare -A COLORS=(
    ["DEBUG"]='\033[0;36m'
    ["INFO"]='\033[0;32m'
    ["WARNING"]='\033[1;33m'
    ["ERROR"]='\033[0;31m'
    ["CRITICAL"]='\033[1;35m'
    ["RESET"]='\033[0m'
)

# Niveaux
declare -A LOG_PRIORITIES=(
    ["DEBUG"]=0
    ["INFO"]=1
    ["WARNING"]=2
    ["ERROR"]=3
    ["CRITICAL"]=4
)

# === Initialisation ===
init_logging() {
    # Créer le répertoire de logs
    mkdir -p "$LOG_DIR" 2>/dev/null || {
        echo "ERREUR: Impossible de créer $LOG_DIR" >&2
        return 1
    }
    
    # Vérifier les permissions
    if [[ ! -w "$LOG_DIR" ]]; then
        echo "ERREUR: Pas de permission d'écriture dans $LOG_DIR" >&2
        return 1
    fi
    
    log "INFO" "Système de logging initialisé - Niveau: $LOG_LEVEL"
}

# === Fonction principale ===
log() {
    local level="$1"
    shift
    local message="$*"
    
    # Filtrer par niveau
    if [[ ${LOG_PRIORITIES[$level]} -lt ${LOG_PRIORITIES[$LOG_LEVEL]} ]]; then
        return 0
    fi
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local script_name=$(basename "$0")
    local line="${BASH_LINENO[0]}"
    
    # Format de log
    local log_entry="[$timestamp] [$level] [$script_name:$line] $message"
    
    # Écrire dans le fichier
    echo "$log_entry" >> "$LOG_FILE" 2>/dev/null
    
    # Afficher avec couleur
    local color="${COLORS[$level]}"
    local reset="${COLORS[RESET]}"
    echo -e "${color}${log_entry}${reset}"
    
    # Si CRITICAL, arrêter le script
    if [[ "$level" == "CRITICAL" ]]; then
        exit 1
    fi
}

# === Raccourcis ===
debug() { log "DEBUG" "$@"; }
info() { log "INFO" "$@"; }
warn() { log "WARNING" "$@"; }
error() { log "ERROR" "$@"; }
critical() { log "CRITICAL" "$@"; }

# === Programme principal ===
main() {
    init_logging || exit 1
    
    info "Démarrage de l'application"
    
    debug "Configuration chargée"
    debug "Variables d'environnement validées"
    
    # Simulation de traitement
    for i in {1..5}; do
        info "Traitement de l'élément $i/5"
        sleep 0.5
    done
    
    if [[ $((RANDOM % 2)) -eq 0 ]]; then
        warn "Certains éléments ont été ignorés"
    fi
    
    info "Traitement terminé avec succès"
}

# Exécution
main "$@"
```

> [!info] Résumé des niveaux de log
> 
> - **DEBUG**: Détails techniques pour le développement
> - **INFO**: Événements normaux et importants
> - **WARNING**: Anomalies non critiques
> - **ERROR**: Erreurs nécessitant attention
> - **CRITICAL**: Erreurs fatales arrêtant le programme
> 
> Utilisez `LOG_LEVEL` pour contrôler la verbosité selon l'environnement (DEBUG en dev, WARNING en prod).

---

## 🎓 Récapitulatif des techniques de débogage

Ce chapitre a couvert les techniques essentielles pour déboguer efficacement vos scripts Bash :

### 🔧 Outils de base

- **`echo`** : Outil simple et universel pour tracer l'exécution
- **Affichage de variables** : Inspection de l'état du programme à tout moment
- **`read`** : Points d'arrêt interactifs pour l'analyse pas à pas

### 📝 Techniques avancées

- **Logs dans fichiers** : Persistance et analyse post-mortem
- **Fonctions de logging** : Centralisation et cohérence
- **Niveaux de log** : Contrôle de la verbosité selon le contexte

### 💡 Stratégies de débogage efficaces

1. **Commencez simple** : Utilisez `echo` pour les problèmes rapides
2. **Structurez vos logs** : Adoptez un format cohérent dès le début
3. **Utilisez les niveaux** : Filtrez l'information selon vos besoins
4. **Pensez production** : Prévoyez la rotation et la gestion d'espace
5. **Automatisez** : Créez des fonctions réutilisables

> [!tip] Conseil final Le meilleur système de débogage est celui que vous utilisez réellement. Commencez avec des techniques simples et évoluez vers plus de sophistication au fur et à mesure de vos besoins. Un simple `echo` bien placé vaut mieux qu'un système de logging complexe jamais utilisé !

---

**📚 Fin du cours sur les techniques de débogage en BASH**