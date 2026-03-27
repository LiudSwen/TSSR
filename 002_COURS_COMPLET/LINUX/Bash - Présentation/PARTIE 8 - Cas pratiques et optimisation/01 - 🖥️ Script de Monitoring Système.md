

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

## 🎯 Introduction au monitoring visuel {#introduction}

Un script de monitoring système doit présenter les informations de manière **claire**, **concise** et **immédiatement compréhensible**. L'embellissement visuel n'est pas qu'une question d'esthétique : il améliore la lisibilité et permet d'identifier rapidement les problèmes critiques.

> [!info] Objectifs d'un bon monitoring visuel
> 
> - **Hiérarchisation** : Les informations importantes ressortent visuellement
> - **Codes couleur** : Vert = OK, Jaune = Attention, Rouge = Critique
> - **Mise à jour en temps réel** : Rafraîchissement sans flood du terminal
> - **Lisibilité** : Utilisation de tableaux et séparateurs

---

## 🎨 Affichage coloré des statuts {#affichage-coloré}

### Pourquoi coloriser les statuts ?

Les couleurs permettent une **identification instantanée** de l'état du système. Un administrateur peut voir d'un coup d'œil si quelque chose nécessite son attention, sans avoir à lire chaque ligne en détail.

### Codes couleurs ANSI

```bash
# Définition des couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'  # No Color - réinitialise la couleur

# Styles supplémentaires
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'  # À utiliser avec parcimonie !
```

> [!warning] Attention à la compatibilité Tous les terminaux ne supportent pas tous les codes ANSI. Les codes de base (couleurs simples) fonctionnent partout, mais certains effets comme le clignotement peuvent ne pas être supportés.

### Fonction de statut intelligent

Créons une fonction qui affiche automatiquement le bon statut avec la bonne couleur :

```bash
#!/bin/bash

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Fonction d'affichage de statut
# Usage: print_status "Nom du service" $valeur $seuil_warning $seuil_critical
print_status() {
    local label="$1"
    local value="$2"
    local warning_threshold="$3"
    local critical_threshold="$4"
    local status_icon
    local status_color
    
    # Déterminer le statut
    if (( $(echo "$value >= $critical_threshold" | bc -l) )); then
        status_icon="✗"
        status_color="$RED"
        status_text="CRITIQUE"
    elif (( $(echo "$value >= $warning_threshold" | bc -l) )); then
        status_icon="⚠"
        status_color="$YELLOW"
        status_text="ATTENTION"
    else
        status_icon="✓"
        status_color="$GREEN"
        status_text="OK"
    fi
    
    # Affichage formaté
    printf "${status_color}[%s]${NC} %-30s : %6.2f%% - %s\n" \
        "$status_icon" "$label" "$value" "$status_text"
}

# Exemples d'utilisation
cpu_usage=45.3
mem_usage=78.2
disk_usage=92.1

print_status "Utilisation CPU" $cpu_usage 70 90
print_status "Utilisation Mémoire" $mem_usage 80 95
print_status "Utilisation Disque" $disk_usage 85 95
```

> [!example] Résultat attendu
> 
> ```
> [✓] Utilisation CPU               :  45.30% - OK
> [⚠] Utilisation Mémoire           :  78.20% - ATTENTION
> [✗] Utilisation Disque            :  92.10% - CRITIQUE
> ```

### Fonction de statut binaire

Pour les services en cours d'exécution (actif/inactif) :

```bash
# Fonction pour statut binaire (service running/stopped)
print_service_status() {
    local service_name="$1"
    local is_running="$2"  # 0 = running, 1 = stopped
    
    if [ "$is_running" -eq 0 ]; then
        printf "${GREEN}[●]${NC} %-30s : ${GREEN}ACTIF${NC}\n" "$service_name"
    else
        printf "${RED}[○]${NC} %-30s : ${RED}ARRÊTÉ${NC}\n" "$service_name"
    fi
}

# Exemple avec systemctl
systemctl is-active --quiet nginx
print_service_status "Nginx" $?

systemctl is-active --quiet postgresql
print_service_status "PostgreSQL" $?
```

> [!tip] Astuce : Icônes unicode Utilisez des icônes Unicode pour améliorer la lisibilité :
> 
> - ✓ ✗ : Succès/Échec
> - ⚠ : Avertissement
> - ● ○ : Actif/Inactif
> - ↑ ↓ : Montée/Descente
> - 🔴 🟡 🟢 : Feux tricolores (si votre terminal supporte les emojis)

---

## 📊 Tableaux de métriques {#tableaux-métriques}

### Pourquoi utiliser des tableaux ?

Les tableaux permettent d'**aligner les données** et de créer une **structure visuelle claire**. Ils facilitent la comparaison entre différentes métriques et rendent le monitoring plus professionnel.

### Fonction de création de tableau simple

```bash
#!/bin/bash

# Couleurs
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Fonction pour créer un séparateur de tableau
print_separator() {
    local width="$1"
    printf '+%s+\n' "$(printf '%0.s-' $(seq 1 $width))"
}

# Fonction pour afficher une ligne d'en-tête
print_header() {
    local width=70
    print_separator $width
    printf "| ${CYAN}${BOLD}%-68s${NC} |\n" "$1"
    print_separator $width
}

# Fonction pour afficher une ligne de données
print_row() {
    local label="$1"
    local value="$2"
    local unit="$3"
    printf "| %-30s | %15s %-20s |\n" "$label" "$value" "$unit"
}

# Exemple d'utilisation
print_header "MÉTRIQUES SYSTÈME"
print_row "Charge CPU" "23.5" "%"
print_row "Mémoire utilisée" "3.2" "GB / 8 GB"
print_row "Disque disponible" "127.8" "GB"
print_row "Uptime" "15 jours 7h" ""
print_separator 70
```

> [!example] Rendu du tableau
> 
> ```
> +----------------------------------------------------------------------+
> | MÉTRIQUES SYSTÈME                                                    |
> +----------------------------------------------------------------------+
> | Charge CPU                     |           23.5 %                    |
> | Mémoire utilisée               |            3.2 GB / 8 GB           |
> | Disque disponible              |          127.8 GB                  |
> | Uptime                         |    15 jours 7h                     |
> +----------------------------------------------------------------------+
> ```

### Tableau avancé avec alignement automatique

```bash
#!/bin/bash

# Fonction de tableau avec largeurs automatiques
print_table() {
    local -n headers=$1      # Référence au tableau d'en-têtes
    local -n data=$2         # Référence au tableau de données (2D)
    local -n widths=$3       # Référence au tableau des largeurs
    
    # Calculer la largeur totale
    local total_width=1  # Pour le '|' initial
    for w in "${widths[@]}"; do
        total_width=$((total_width + w + 3))  # +3 pour ' | '
    done
    
    # Ligne de séparation
    local separator="+"
    for w in "${widths[@]}"; do
        separator+="$(printf '%0.s-' $(seq 1 $((w + 2))))+"
    done
    
    # En-tête
    echo "$separator"
    printf "|"
    for i in "${!headers[@]}"; do
        printf " ${CYAN}${BOLD}%-${widths[$i]}s${NC} |" "${headers[$i]}"
    done
    echo
    echo "$separator"
    
    # Données
    local num_rows=$((${#data[@]} / ${#headers[@]}))
    for ((row=0; row<num_rows; row++)); do
        printf "|"
        for ((col=0; col<${#headers[@]}; col++)); do
            local idx=$((row * ${#headers[@]} + col))
            printf " %-${widths[$col]}s |" "${data[$idx]}"
        done
        echo
    done
    
    echo "$separator"
}

# Exemple d'utilisation
declare -a headers=("Partition" "Taille" "Utilisé" "Disponible" "Utilisation")
declare -a col_widths=(15 10 10 12 12)
declare -a table_data=(
    "/" "100G" "45G" "50G" "45%"
    "/home" "500G" "320G" "170G" "65%"
    "/var" "200G" "180G" "15G" "92%"
)

print_table headers table_data col_widths
```

### Tableau avec barres de progression

Ajoutons des barres visuelles pour représenter les pourcentages :

```bash
#!/bin/bash

# Fonction pour créer une barre de progression
progress_bar() {
    local percentage="$1"
    local width="${2:-20}"  # Largeur par défaut : 20 caractères
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    # Choisir la couleur selon le pourcentage
    local color
    if [ "$percentage" -ge 90 ]; then
        color="$RED"
    elif [ "$percentage" -ge 70 ]; then
        color="$YELLOW"
    else
        color="$GREEN"
    fi
    
    # Construire la barre
    printf "${color}["
    printf '%0.s█' $(seq 1 $filled)
    printf '%0.s░' $(seq 1 $empty)
    printf "]${NC} %3d%%" "$percentage"
}

# Fonction pour afficher une ligne avec barre
print_metric_with_bar() {
    local label="$1"
    local value="$2"
    printf "%-25s : " "$label"
    progress_bar "$value" 25
    echo
}

# Exemples
echo "=== UTILISATION DES RESSOURCES ==="
print_metric_with_bar "CPU" 45
print_metric_with_bar "RAM" 78
print_metric_with_bar "Disque /" 92
print_metric_with_bar "Disque /home" 34
```

> [!tip] Amélioration visuelle Vous pouvez utiliser différents caractères pour les barres :
> 
> - `█` `▓` `▒` `░` : Dégradé complet
> - `●` `○` : Points pleins/vides
> - `■` `□` : Carrés pleins/vides
> - `▰` `▱` : Barres horizontales

---

## 🚨 Alertes visuelles {#alertes-visuelles}

### Types d'alertes

Les alertes doivent être **immédiatement visibles** et **proportionnelles à la gravité** du problème.

```bash
#!/bin/bash

# Couleurs et styles
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'
BOLD='\033[1m'
BLINK='\033[5m'

# Fonction d'alerte avec encadrement
alert_box() {
    local level="$1"    # info, warning, error, critical
    local message="$2"
    local icon color title
    
    case "$level" in
        info)
            icon="ℹ"
            color="$BLUE"
            title="INFORMATION"
            ;;
        warning)
            icon="⚠"
            color="$YELLOW"
            title="AVERTISSEMENT"
            ;;
        error)
            icon="✗"
            color="$RED"
            title="ERREUR"
            ;;
        critical)
            icon="⚠"
            color="${RED}${BLINK}"
            title="CRITIQUE"
            ;;
        success)
            icon="✓"
            color="$GREEN"
            title="SUCCÈS"
            ;;
    esac
    
    local width=60
    local msg_length=${#message}
    local padding=$(( (width - msg_length - 2) / 2 ))
    
    echo
    echo "${color}╔$(printf '═%.0s' $(seq 1 $width))╗${NC}"
    printf "${color}║${BOLD}%*s%-*s%*s${NC}${color}║${NC}\n" \
        $(( (width - ${#title}) / 2 + ${#title} )) "$title" \
        0 "" \
        $(( (width - ${#title}) / 2 ))
    echo "${color}╠$(printf '═%.0s' $(seq 1 $width))╣${NC}"
    printf "${color}║${NC} ${icon} %-$((width - 4))s ${color}║${NC}\n" "$message"
    echo "${color}╚$(printf '═%.0s' $(seq 1 $width))╝${NC}"
    echo
}

# Exemples d'alertes
alert_box "info" "Le système fonctionne normalement"
alert_box "warning" "Mémoire utilisée à 78% - Surveillance recommandée"
alert_box "error" "Échec de connexion à la base de données"
alert_box "critical" "Disque plein à 98% - Action immédiate requise !"
alert_box "success" "Sauvegarde complétée avec succès"
```

### Système de notification sonore

Pour les alertes critiques, ajoutez un signal sonore :

```bash
#!/bin/bash

# Fonction de notification avec son
notify_alert() {
    local level="$1"
    local message="$2"
    
    # Afficher l'alerte visuelle
    alert_box "$level" "$message"
    
    # Signal sonore pour les niveaux critiques
    case "$level" in
        critical)
            # 3 bips courts
            for i in {1..3}; do
                echo -e '\a'  # Bip système
                sleep 0.3
            done
            ;;
        error)
            # 1 bip long
            echo -e '\a'
            ;;
    esac
}
```

> [!warning] Attention aux bips Le signal sonore `\a` peut être désactivé sur certains systèmes ou être agaçant en production. Utilisez-le avec parcimonie et prévoyez une option pour le désactiver.

### Liste d'alertes avec horodatage

```bash
#!/bin/bash

# Fichier de log des alertes
ALERT_LOG="/tmp/system_alerts.log"

# Fonction pour logger et afficher une alerte
log_alert() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Logger dans le fichier
    echo "[$timestamp] [$level] $message" >> "$ALERT_LOG"
    
    # Afficher à l'écran
    alert_box "$level" "$message"
}

# Fonction pour afficher les dernières alertes
show_recent_alerts() {
    local num_lines="${1:-10}"
    
    echo
    echo "${CYAN}${BOLD}=== DERNIÈRES ALERTES ===${NC}"
    echo
    
    if [ -f "$ALERT_LOG" ]; then
        tail -n "$num_lines" "$ALERT_LOG" | while IFS= read -r line; do
            # Coloriser selon le niveau
            if [[ "$line" =~ CRITICAL ]]; then
                echo -e "${RED}${BLINK}$line${NC}"
            elif [[ "$line" =~ ERROR ]]; then
                echo -e "${RED}$line${NC}"
            elif [[ "$line" =~ WARNING ]]; then
                echo -e "${YELLOW}$line${NC}"
            else
                echo "$line"
            fi
        done
    else
        echo "Aucune alerte enregistrée"
    fi
    
    echo
}
```

> [!tip] Rotation des logs Pour éviter que le fichier de log ne devienne trop volumineux, implémentez une rotation :
> 
> ```bash
> # Garder seulement les 1000 dernières lignes
> if [ $(wc -l < "$ALERT_LOG") -gt 1000 ]; then
>     tail -n 1000 "$ALERT_LOG" > "${ALERT_LOG}.tmp"
>     mv "${ALERT_LOG}.tmp" "$ALERT_LOG"
> fi
> ```

---

## 🔄 Rafraîchissement périodique {#rafraîchissement}

### Pourquoi rafraîchir l'affichage ?

Un monitoring efficace doit se **mettre à jour automatiquement** sans nécessiter d'intervention humaine. Le rafraîchissement permet de suivre l'évolution des métriques en temps réel.

### Méthode 1 : Effacement complet avec clear

La méthode la plus simple mais qui provoque un clignotement :

```bash
#!/bin/bash

# Fonction de monitoring simple
monitor_simple() {
    while true; do
        clear  # Efface tout l'écran
        
        echo "=== MONITORING SYSTÈME ==="
        date '+%Y-%m-%d %H:%M:%S'
        echo
        
        # Afficher les métriques
        echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
        echo "RAM: $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100}')"
        
        sleep 2  # Attendre 2 secondes
    done
}
```

> [!warning] Inconvénient du clear La commande `clear` efface tout l'écran et provoque un **clignotement désagréable**. Elle remet aussi le curseur en haut, ce qui peut être perturbant.

### Méthode 2 : Retour au début avec tput

Plus fluide, sans clignotement :

```bash
#!/bin/bash

# Fonction de monitoring avec tput
monitor_smooth() {
    # Sauvegarder la position initiale du curseur
    tput sc
    
    while true; do
        # Retourner à la position sauvegardée
        tput rc
        
        # Effacer depuis le curseur jusqu'à la fin de l'écran
        tput ed
        
        echo "=== MONITORING SYSTÈME ==="
        date '+%Y-%m-%d %H:%M:%S'
        echo
        
        # Vos métriques ici
        
        sleep 2
    done
}
```

> [!info] Commandes tput utiles
> 
> - `tput sc` : Sauvegarder la position du curseur
> - `tput rc` : Restaurer la position du curseur
> - `tput ed` : Effacer depuis le curseur jusqu'à la fin de l'écran
> - `tput clear` : Effacer tout l'écran (comme `clear`)
> - `tput cup Y X` : Déplacer le curseur à la ligne Y, colonne X
> - `tput civis` : Cacher le curseur
> - `tput cnorm` : Afficher le curseur

### Méthode 3 : Mise à jour sélective avec codes ANSI

La plus performante pour mettre à jour seulement certaines lignes :

```bash
#!/bin/bash

# Fonction pour déplacer le curseur
cursor_to() {
    local line="$1"
    local col="${2:-0}"
    printf '\033[%d;%dH' "$line" "$col"
}

# Fonction pour effacer une ligne
clear_line() {
    printf '\033[2K'
}

# Cacher le curseur
hide_cursor() {
    printf '\033[?25l'
}

# Afficher le curseur
show_cursor() {
    printf '\033[?25h'
}

# Fonction de monitoring avec mise à jour sélective
monitor_selective() {
    local line_cpu=5
    local line_mem=6
    local line_disk=7
    local line_time=2
    
    # Initialisation de l'affichage
    clear
    hide_cursor
    
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║            MONITORING SYSTÈME EN TEMPS RÉEL              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo
    echo "CPU  : "
    echo "RAM  : "
    echo "DISK : "
    
    # Piège pour restaurer le curseur à la sortie
    trap "show_cursor; exit" INT TERM
    
    while true; do
        # Mise à jour de l'heure
        cursor_to $line_time 10
        clear_line
        date '+%H:%M:%S'
        
        # Mise à jour CPU
        cursor_to $line_cpu 8
        clear_line
        local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
        printf "%.1f%% " "$cpu"
        progress_bar "${cpu%.*}" 20
        
        # Mise à jour RAM
        cursor_to $line_mem 8
        clear_line
        local mem=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100}')
        printf "%.1f%% " "$mem"
        progress_bar "${mem%.*}" 20
        
        # Mise à jour Disque
        cursor_to $line_disk 8
        clear_line
        local disk=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
        printf "%3d%% " "$disk"
        progress_bar "$disk" 20
        
        sleep 1
    done
}
```

> [!tip] Gestion propre de la sortie Utilisez toujours `trap` pour restaurer l'état du terminal en cas d'interruption (Ctrl+C) :
> 
> ```bash
> trap "tput cnorm; tput clear; exit" INT TERM EXIT
> ```

### Optimisation : Éviter les calculs inutiles

```bash
#!/bin/bash

# Cache des valeurs pour éviter les calculs répétés
declare -A metric_cache
cache_timeout=5  # Secondes avant recalcul

# Fonction pour obtenir une métrique avec cache
get_metric_cached() {
    local metric_name="$1"
    local metric_command="$2"
    local current_time=$(date +%s)
    
    # Vérifier si on a une valeur en cache
    if [[ -n "${metric_cache[$metric_name]}" ]]; then
        local cache_entry="${metric_cache[$metric_name]}"
        local cache_time="${cache_entry%%:*}"
        local cache_value="${cache_entry#*:}"
        
        # Si le cache est encore valide
        if (( current_time - cache_time < cache_timeout )); then
            echo "$cache_value"
            return
        fi
    fi
    
    # Calculer la nouvelle valeur
    local new_value=$(eval "$metric_command")
    metric_cache[$metric_name]="${current_time}:${new_value}"
    echo "$new_value"
}

# Exemple d'utilisation
while true; do
    cpu=$(get_metric_cached "cpu" "top -bn1 | grep 'Cpu(s)' | awk '{print \$2}'")
    echo "CPU: $cpu%"
    sleep 0.5  # Mise à jour rapide de l'affichage
done
```

> [!warning] Attention à la fréquence Ne rafraîchissez pas trop rapidement :
> 
> - **CPU** : Toutes les 1-2 secondes suffisent
> - **Mémoire** : Toutes les 2-5 secondes
> - **Disque** : Toutes les 5-10 secondes (change lentement)
> - **Réseau** : Toutes les 1 seconde pour le débit en temps réel

---

## 🎯 Script complet intégré {#script-complet}

Voici un script de monitoring complet qui intègre tous les concepts vus précédemment :

```bash
#!/bin/bash

#==============================================================================
# Script de Monitoring Système Avancé
# Description : Surveillance en temps réel avec affichage enrichi
# Usage : ./monitor.sh [--interval SECONDS] [--alert-threshold PERCENT]
#==============================================================================

# Configuration par défaut
REFRESH_INTERVAL=2
CPU_WARNING=70
CPU_CRITICAL=90
MEM_WARNING=80
MEM_CRITICAL=95
DISK_WARNING=85
DISK_CRITICAL=95

# Fichier de log des alertes
ALERT_LOG="/tmp/system_monitor_alerts.log"

# Couleurs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

#------------------------------------------------------------------------------
# Gestion du curseur et de l'affichage
#------------------------------------------------------------------------------

hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
cursor_to() { printf '\033[%d;%dH' "$1" "$2"; }
clear_line() { printf '\033[2K'; }
save_cursor() { printf '\033[s'; }
restore_cursor() { printf '\033[u'; }

#------------------------------------------------------------------------------
# Barre de progression colorée
#------------------------------------------------------------------------------

progress_bar() {
    local percentage="$1"
    local width="${2:-25}"
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    # Couleur selon le seuil
    local color
    if [ "$percentage" -ge "${3:-90}" ]; then
        color="$RED"
    elif [ "$percentage" -ge "${4:-70}" ]; then
        color="$YELLOW"
    else
        color="$GREEN"
    fi
    
    printf "${color}["
    printf '%0.s█' $(seq 1 $filled)
    printf '%0.s░' $(seq 1 $empty)
    printf "]${NC} %3d%%" "$percentage"
}

#------------------------------------------------------------------------------
# Récupération des métriques système
#------------------------------------------------------------------------------

get_cpu_usage() {
    top -bn2 -d 0.5 | grep "Cpu(s)" | tail -1 | awk '{print $2}' | cut -d'%' -f1
}

get_mem_usage() {
    free | grep Mem | awk '{printf "%.1f", $3/$2 * 100}'
}

get_mem_details() {
    free -h | grep Mem | awk '{print $3 " / " $2}'
}

get_disk_usage() {
    df / | tail -1 | awk '{print $5}' | sed 's/%//'
}

get_disk_details() {
    df -h / | tail -1 | awk '{print $3 " / " $2}'
}

get_load_average() {
    uptime | awk -F'load average:' '{print $2}' | xargs
}

get_uptime() {
    uptime -p | sed 's/up //'
}

get_process_count() {
    ps aux | wc -l
}

get_logged_users() {
    who | wc -l
}

#------------------------------------------------------------------------------
# Vérification et alerte
#------------------------------------------------------------------------------

check_threshold() {
    local metric_name="$1"
    local value="$2"
    local warning="$3"
    local critical="$4"
    
    if (( $(echo "$value >= $critical" | bc -l) )); then
        log_alert "CRITICAL" "$metric_name à ${value}% (Seuil: ${critical}%)"
        return 2
    elif (( $(echo "$value >= $warning" | bc -l) )); then
        log_alert "WARNING" "$metric_name à ${value}% (Seuil: ${warning}%)"
        return 1
    fi
    return 0
}

log_alert() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$ALERT_LOG"
}

#------------------------------------------------------------------------------
# Affichage de l'interface
#------------------------------------------------------------------------------

draw_header() {
    local width=75
    echo "${CYAN}╔$(printf '═%.0s' $(seq 1 $width))╗${NC}"
    printf "${CYAN}║${BOLD}%*s%-*s%*s${NC}${CYAN}║${NC}\n" \
        $((width/2 + 15)) "MONITORING SYSTÈME - " \
        0 "" \
        $((width/2 - 15)) "$(date '+%Y-%m-%d %H:%M:%S')"
    echo "${CYAN}╠$(printf '═%.0s' $(seq 1 $width))╣${NC}"
}

draw_footer() {
    local width=75
    echo "${CYAN}╚$(printf '═%.0s' $(seq 1 $width))╝${NC}"
}

draw_separator() {
    local width=75
    echo "${CYAN}╠$(printf '═%.0s' $(seq 1 $width))╣${NC}"
}

draw_metric_line() {
    local label="$1"
    local value="$2"
    local warning="$3"
    local critical="$4"
    
    printf "${CYAN}║${NC} %-20s : " "$label"
    progress_bar "${value%.*}" 30 "$critical" "$warning"
    printf " ${CYAN}║${NC}\n"
}

draw_info_line() {
    local label="$1"
    local value="$2"
    printf "${CYAN}║${NC} %-20s : %-50s ${CYAN}║${NC}\n" "$label" "$value"
}

#------------------------------------------------------------------------------
# Affichage des alertes récentes
#------------------------------------------------------------------------------

draw_recent_alerts() {
    echo "${CYAN}║${BOLD} ALERTES RÉCENTES${NC}                                                      ${CYAN}║${NC}"
    draw_separator
    
    if [ -f "$ALERT_LOG" ] && [ -s "$ALERT_LOG" ]; then
        local count=0
        tail -n 5 "$ALERT_LOG" | while IFS= read -r line; do
            # Extraire les composants
            local timestamp=$(echo "$line" | grep -oP '\[\K[^\]]+' | head -1)
            local level=$(echo "$line" | grep -oP '\]\s*\[\K[^\]]+')
            local message=$(echo "$line" | sed 's/.*\] //')
            
            # Coloriser selon le niveau
            local color
            case "$level" in
                CRITICAL) color="$RED" ;;
                WARNING) color="$YELLOW" ;;
                *) color="$WHITE" ;;
            esac
            
            # Tronquer le message si trop long
            if [ ${#message} -gt 45 ]; then
                message="${message:0:42}..."
            fi
            
            printf "${CYAN}║${NC} ${color}%-8s${NC} %-15s %-45s ${CYAN}║${NC}\n" \
                "$level" "${timestamp:11:8}" "$message"
            
            ((count++))
        done
        
        if [ $count -eq 0 ]; then
            printf "${CYAN}║${NC}   ${GREEN}✓ Aucune alerte récente${NC}%-43s ${CYAN}║${NC}\n" ""
        fi
    else
        printf "${CYAN}║${NC}   ${GREEN}✓ Aucune alerte récente${NC}%-43s ${CYAN}║${NC}\n" ""
    fi
}

#------------------------------------------------------------------------------
# Boucle principale de monitoring
#------------------------------------------------------------------------------

main_monitor() {
    # Préparation
    clear
    hide_cursor
    trap "show_cursor; clear; exit" INT TERM EXIT
    
    # Initialiser le fichier de log si nécessaire
    touch "$ALERT_LOG"
    
    while true; do
        # Retour en haut de l'écran
        cursor_to 1 1
        
        # En-tête
        draw_header
        
        # Section : Ressources système
        echo "${CYAN}║${BOLD} RESSOURCES SYSTÈME${NC}                                                    ${CYAN}║${NC}"
        draw_separator
        
        # CPU
        local cpu_usage=$(get_cpu_usage)
        draw_metric_line "CPU" "$cpu_usage" "$CPU_WARNING" "$CPU_CRITICAL"
        check_threshold "CPU" "$cpu_usage" "$CPU_WARNING" "$CPU_CRITICAL"
        
        # Mémoire
        local mem_usage=$(get_mem_usage)
        local mem_details=$(get_mem_details)
        draw_metric_line "Mémoire" "$mem_usage" "$MEM_WARNING" "$MEM_CRITICAL"
        draw_info_line "  └─ Détails" "$mem_details"
        check_threshold "Mémoire" "$mem_usage" "$MEM_WARNING" "$MEM_CRITICAL"
        
        # Disque
        local disk_usage=$(get_disk_usage)
        local disk_details=$(get_disk_details)
        draw_metric_line "Disque /" "$disk_usage" "$DISK_WARNING" "$DISK_CRITICAL"
        draw_info_line "  └─ Détails" "$disk_details"
        check_threshold "Disque /" "$disk_usage" "$DISK_WARNING" "$DISK_CRITICAL"
        
        draw_separator
        
        # Section : Informations système
        echo "${CYAN}║${BOLD} INFORMATIONS SYSTÈME${NC}                                                  ${CYAN}║${NC}"
        draw_separator
        
        draw_info_line "Charge moyenne" "$(get_load_average)"
        draw_info_line "Uptime" "$(get_uptime)"
        draw_info_line "Processus actifs" "$(get_process_count)"
        draw_info_line "Utilisateurs connectés" "$(get_logged_users)"
        
        draw_separator
        
        # Section : Alertes
        draw_recent_alerts
        
        # Pied de page
        draw_footer
        
        # Informations de contrôle
        echo
        printf "${CYAN}Rafraîchissement : ${WHITE}%ds${NC}  |  " "$REFRESH_INTERVAL"
        printf "${CYAN}Ctrl+C pour quitter${NC}\n"
        
        # Attendre avant le prochain rafraîchissement
        sleep "$REFRESH_INTERVAL"
    done
}

#------------------------------------------------------------------------------
# Gestion des arguments
#------------------------------------------------------------------------------

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Script de monitoring système avec interface enrichie

OPTIONS:
    -i, --interval SECONDS     Intervalle de rafraîchissement (défaut: 2s)
    -c, --cpu-warn PERCENT     Seuil d'avertissement CPU (défaut: 70%)
    -C, --cpu-crit PERCENT     Seuil critique CPU (défaut: 90%)
    -m, --mem-warn PERCENT     Seuil d'avertissement mémoire (défaut: 80%)
    -M, --mem-crit PERCENT     Seuil critique mémoire (défaut: 95%)
    -d, --disk-warn PERCENT    Seuil d'avertissement disque (défaut: 85%)
    -D, --disk-crit PERCENT    Seuil critique disque (défaut: 95%)
    -h, --help                 Afficher cette aide

EXEMPLES:
    $0                                 # Utiliser les valeurs par défaut
    $0 -i 5                            # Rafraîchir toutes les 5 secondes
    $0 -c 60 -C 80 -m 70 -M 90        # Personnaliser les seuils

EOF
    exit 0
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--interval)
                REFRESH_INTERVAL="$2"
                shift 2
                ;;
            -c|--cpu-warn)
                CPU_WARNING="$2"
                shift 2
                ;;
            -C|--cpu-crit)
                CPU_CRITICAL="$2"
                shift 2
                ;;
            -m|--mem-warn)
                MEM_WARNING="$2"
                shift 2
                ;;
            -M|--mem-crit)
                MEM_CRITICAL="$2"
                shift 2
                ;;
            -d|--disk-warn)
                DISK_WARNING="$2"
                shift 2
                ;;
            -D|--disk-crit)
                DISK_CRITICAL="$2"
                shift 2
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Option inconnue: $1"
                usage
                ;;
        esac
    done
}

#------------------------------------------------------------------------------
# Point d'entrée du script
#------------------------------------------------------------------------------

main() {
    parse_arguments "$@"
    
    # Vérifier les dépendances
    for cmd in bc awk free df top; do
        if ! command -v $cmd &> /dev/null; then
            echo "Erreur: La commande '$cmd' est requise mais non disponible"
            exit 1
        fi
    done
    
    # Lancer le monitoring
    main_monitor
}

# Exécution
main "$@"
```

> [!example] Exemple d'exécution
> 
> ```bash
> # Monitoring standard
> ./monitor.sh
> 
> # Monitoring avec rafraîchissement plus lent
> ./monitor.sh --interval 5
> 
> # Monitoring avec seuils personnalisés
> ./monitor.sh -c 60 -C 85 -m 75 -M 90
> ```

### Points clés du script complet

Ce script intègre toutes les bonnes pratiques vues dans ce cours :

1. **Organisation modulaire** : Chaque fonctionnalité est dans sa propre fonction
2. **Gestion propre du terminal** : Curseur caché pendant l'exécution, restauré à la sortie
3. **Mise à jour fluide** : Utilisation de `cursor_to` pour éviter le clignotement
4. **Alertes intelligentes** : Vérification automatique des seuils avec historique
5. **Configuration flexible** : Arguments en ligne de commande pour personnaliser
6. **Affichage structuré** : Tableaux avec bordures, barres de progression colorées
7. **Gestion des erreurs** : Vérification des dépendances, trap pour la sortie propre

> [!tip] Personnalisation avancée Vous pouvez facilement étendre ce script pour :
> 
> - Surveiller des services spécifiques (nginx, postgresql, etc.)
> - Ajouter des métriques réseau (bande passante, connexions)
> - Envoyer des notifications par email ou webhook
> - Créer des graphiques avec gnuplot
> - Exporter les métriques vers un système de monitoring (Prometheus, InfluxDB)

### Variations possibles

**Version minimaliste (une ligne) :**

```bash
watch -n 2 -c 'echo -e "\033[1;36mCPU:\033[0m $(top -bn1 | grep Cpu | awk "{print \$2}")% | \033[1;36mRAM:\033[0m $(free | grep Mem | awk "{printf \"%.1f%%\", \$3/\$2*100}") | \033[1;36mDISK:\033[0m $(df / | tail -1 | awk "{print \$5}")"'
```

**Version avec dashboard multiple :**

```bash
# Diviser l'écran en plusieurs sections avec tmux
tmux new-session \; \
  split-window -h \; \
  split-window -v \; \
  select-pane -t 0 \; \
  send-keys './monitor.sh' C-m \; \
  select-pane -t 1 \; \
  send-keys 'htop' C-m \; \
  select-pane -t 2 \; \
  send-keys 'tail -f /var/log/syslog' C-m
```

---

## 📚 Récapitulatif des bonnes pratiques

### ✅ À faire

- **Utiliser des codes couleur cohérents** : Rouge = Danger, Jaune = Attention, Vert = OK
- **Cacher le curseur** pendant les rafraîchissements pour éviter le clignotement
- **Implémenter un trap** pour restaurer l'état du terminal à la sortie
- **Utiliser `cursor_to`** au lieu de `clear` pour un affichage fluide
- **Ajouter des barres de progression** pour visualiser les pourcentages
- **Logger les alertes** dans un fichier pour l'historique
- **Permettre la configuration** via arguments ou fichier de config
- **Vérifier les dépendances** avant l'exécution
- **Documenter le code** avec des commentaires clairs

### ❌ À éviter

- **Abuser de `clear`** : Provoque un clignotement désagréable
- **Rafraîchir trop rapidement** : Surcharge CPU et illisible (minimum 1 seconde)
- **Oublier le `trap`** : Le terminal reste dans un état bizarre après Ctrl+C
- **Utiliser trop de couleurs** : Devient confus et difficile à lire
- **Négliger les codes de sortie** : Toujours vérifier les erreurs des commandes
- **Laisser le curseur visible** : Donne un aspect non professionnel
- **Faire des calculs lourds** à chaque itération : Utiliser un cache si possible
- **Oublier `bc`** pour les calculs à virgule flottante

### 🎯 Cas d'usage recommandés

|Situation|Méthode recommandée|
|---|---|
|Dashboard simple|`watch -c` avec commandes basiques|
|Monitoring intermédiaire|Script avec `tput` et mise à jour complète|
|Monitoring avancé|Script avec `cursor_to` et mise à jour sélective|
|Monitoring distribué|Export vers système externe (Prometheus, etc.)|
|Debug rapide|One-liner avec `watch`|

### 🔧 Commandes essentielles à retenir

```bash
# Gestion du curseur
tput civis          # Cacher le curseur
tput cnorm          # Afficher le curseur
tput sc             # Sauvegarder position
tput rc             # Restaurer position
tput cup Y X        # Déplacer à ligne Y, colonne X

# Gestion de l'affichage
tput clear          # Effacer l'écran
tput ed             # Effacer depuis curseur jusqu'à fin
tput el             # Effacer la ligne courante

# Codes ANSI directs
printf '\033[H'     # Curseur en haut à gauche
printf '\033[2J'    # Effacer l'écran
printf '\033[K'     # Effacer jusqu'à fin de ligne
printf '\033[%d;%dH' Y X  # Déplacer curseur
```

### 💡 Astuces finales

1. **Test sur différents terminaux** : Certains codes peuvent ne pas fonctionner partout
2. **Mode dégradé** : Prévoir un fallback sans couleurs avec option `--no-color`
3. **Performance** : Limiter les appels système coûteux (top, ps, etc.)
4. **Accessibilité** : Ne pas se fier uniquement aux couleurs, ajouter des icônes
5. **Logs** : Toujours garder une trace écrite en plus de l'affichage visuel
6. **Tests** : Vérifier le comportement avec différentes tailles de terminal
7. **Documentation** : Commenter les calculs complexes et les seuils choisis

---

## 🎓 Synthèse

Ce cours vous a présenté les techniques essentielles pour créer des scripts de monitoring système professionnels et agréables à utiliser :

- **Affichage coloré** pour identifier rapidement les problèmes
- **Tableaux structurés** pour organiser l'information
- **Alertes visuelles** pour signaler les situations critiques
- **Rafraîchissement fluide** pour un suivi en temps réel
- **Script complet** intégrant toutes ces techniques

L'embellissement des scripts n'est pas qu'une question d'esthétique : c'est un outil puissant pour améliorer l'efficacité opérationnelle et réduire le temps de réaction face aux incidents système.

> [!success] Compétences acquises Vous êtes maintenant capable de créer des scripts de monitoring qui :
> 
> - Présentent l'information de manière claire et hiérarchisée
> - Attirent l'attention sur les éléments importants
> - Se mettent à jour en temps réel sans clignotement
> - Sont configurables et maintenables
> - Respectent les bonnes pratiques professionnelles