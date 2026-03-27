

> [!info] Vue d'ensemble Cette partie explore l'utilisation des caractères Unicode décoratifs pour créer des interfaces visuellement riches dans vos scripts Bash. Ces caractères permettent de structurer, séparer et embellir vos affichages sans dépendre de bibliothèques externes.

---

## 📑 Table des matières

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

## 🔲 Blocs et ombrages

### Pourquoi utiliser les blocs ?

Les caractères de bloc permettent de créer des barres de progression, des visualisations de données, des arrière-plans et des effets d'ombrage sans nécessiter de graphismes complexes.

### Caractères disponibles

|Caractère|Code Unicode|Nom|Utilisation typique|
|---|---|---|---|
|█|U+2588|Bloc plein|Barres pleines, fond solide|
|▓|U+2593|Ombre dense|Progression à 75%|
|▒|U+2592|Ombre moyenne|Progression à 50%|
|░|U+2591|Ombre légère|Progression à 25%|
|▀|U+2580|Demi-bloc supérieur|Graphiques en demi-hauteur|
|▄|U+2584|Demi-bloc inférieur|Graphiques en demi-hauteur|
|▌|U+258C|Demi-bloc gauche|Bordures gauches|
|▐|U+2590|Demi-bloc droit|Bordures droites|

### Syntaxe de base

```bash
#!/bin/bash

# Affichage simple de blocs
echo "█ Bloc plein"
echo "▓ Ombre dense"
echo "▒ Ombre moyenne"
echo "░ Ombre légère"

# Combinaison de blocs pour créer des dégradés
echo "█▓▒░ Dégradé de gauche à droite"
echo "░▒▓█ Dégradé de droite à gauche"
```

### Exemple pratique : Barre de progression

```bash
#!/bin/bash

# Fonction pour afficher une barre de progression
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    # Construction de la barre
    printf "\r["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%%" "$percentage"
}

# Simulation d'un téléchargement
echo "Téléchargement en cours..."
for i in $(seq 0 100); do
    progress_bar "$i" 100
    sleep 0.05
done
echo -e "\n✓ Téléchargement terminé !"
```

### Exemple avancé : Graphique en barres

```bash
#!/bin/bash

# Affichage d'un graphique en barres horizontales
display_chart() {
    local -n data=$1  # Référence au tableau associatif
    local max_value=0
    local max_width=50
    
    # Trouver la valeur maximale
    for value in "${data[@]}"; do
        ((value > max_value)) && max_value=$value
    done
    
    echo "╔════════════════════════════════════════════════════╗"
    echo "║           Statistiques d'utilisation              ║"
    echo "╠════════════════════════════════════════════════════╣"
    
    # Afficher chaque barre
    for key in "${!data[@]}"; do
        local value=${data[$key]}
        local bar_length=$((value * max_width / max_value))
        local bar=$(printf "%${bar_length}s" | tr ' ' '█')
        printf "║ %-15s %s %3d%% ║\n" "$key" "$bar" "$value"
    done
    
    echo "╚════════════════════════════════════════════════════╝"
}

# Exemple d'utilisation
declare -A stats=(
    ["CPU"]=75
    ["RAM"]=60
    ["Disque"]=45
    ["Réseau"]=90
)

display_chart stats
```

> [!tip] Astuce - Demi-blocs Les demi-blocs (▀ ▄) permettent de doubler la résolution verticale de vos graphiques en affichant deux points de données par ligne de texte.

### Exemple : Histogramme vertical

```bash
#!/bin/bash

# Création d'un histogramme vertical compact
vertical_histogram() {
    local -a values=("$@")
    local max_height=10
    
    # Normalisation des valeurs
    local max_val=0
    for val in "${values[@]}"; do
        ((val > max_val)) && max_val=$val
    done
    
    # Affichage de haut en bas
    for ((row = max_height; row > 0; row--)); do
        for val in "${values[@]}"; do
            local normalized=$((val * max_height / max_val))
            if ((normalized >= row)); then
                printf "█ "
            else
                printf "  "
            fi
        done
        echo
    done
    
    # Affichage des valeurs
    for val in "${values[@]}"; do
        printf "%d " "$val"
    done
    echo
}

# Exemple d'utilisation
echo "Ventes mensuelles :"
vertical_histogram 45 67 89 56 78 90 34 67
```

> [!warning] Attention à l'encodage Assurez-vous que votre terminal et votre script utilisent l'encodage UTF-8. Ajoutez `export LANG=fr_FR.UTF-8` si nécessaire.

---

## 🔺 Triangles et flèches

### Pourquoi utiliser les triangles et flèches ?

Les flèches et triangles sont essentiels pour :

- Indiquer des directions et des flux
- Créer des menus de navigation
- Signaler des changements d'état
- Structurer des hiérarchies visuelles

### Caractères disponibles

|Caractère|Code Unicode|Nom|Utilisation typique|
|---|---|---|---|
|▲|U+25B2|Triangle haut|Tri ascendant, augmentation|
|▼|U+25BC|Triangle bas|Tri descendant, diminution|
|◄|U+25C4|Triangle gauche|Navigation précédente|
|►|U+25BA|Triangle droit|Navigation suivante, lecture|
|→|U+2192|Flèche droite|Progression, résultat|
|←|U+2190|Flèche gauche|Retour, annulation|
|↑|U+2191|Flèche haut|Upload, amélioration|
|↓|U+2193|Flèche bas|Download, dégradation|
|⇒|U+21D2|Double flèche droite|Implication forte|
|⇐|U+21D0|Double flèche gauche|Implication inverse|

### Syntaxe de base

```bash
#!/bin/bash

# Affichage de différentes flèches
echo "→ Étape suivante"
echo "← Retour en arrière"
echo "↑ Téléverser"
echo "↓ Télécharger"
echo "⇒ Résultat final"

# Navigation
echo "◄ Précédent | Suivant ►"
```

### Exemple pratique : Menu de navigation

```bash
#!/bin/bash

# Menu interactif avec flèches
show_menu() {
    local selected=1
    local options=("Installer" "Configurer" "Désinstaller" "Quitter")
    
    while true; do
        clear
        echo "╔══════════════════════════════════╗"
        echo "║      Menu Principal              ║"
        echo "╠══════════════════════════════════╣"
        
        for i in "${!options[@]}"; do
            local index=$((i + 1))
            if [ $index -eq $selected ]; then
                echo "║ ► ${options[$i]}"
            else
                echo "║   ${options[$i]}"
            fi
        done
        
        echo "╚══════════════════════════════════╝"
        echo ""
        echo "↑/↓ : Naviguer | Entrée : Sélectionner"
        
        read -rsn1 key
        case "$key" in
            A) ((selected > 1)) && ((selected--)) ;;  # Flèche haut
            B) ((selected < ${#options[@]})) && ((selected++)) ;;  # Flèche bas
            "") echo "Vous avez sélectionné : ${options[$((selected-1))]}" 
                read -p "Appuyez sur Entrée..." 
                [ "${options[$((selected-1))]}" = "Quitter" ] && break ;;
        esac
    done
}

show_menu
```

### Exemple : Indicateurs d'état

```bash
#!/bin/bash

# Fonction pour afficher l'évolution d'une métrique
show_trend() {
    local label=$1
    local old_value=$2
    local new_value=$3
    
    local diff=$((new_value - old_value))
    local arrow=""
    local color=""
    
    if ((diff > 0)); then
        arrow="↑"
        color="\e[32m"  # Vert
    elif ((diff < 0)); then
        arrow="↓"
        color="\e[31m"  # Rouge
    else
        arrow="→"
        color="\e[33m"  # Jaune
    fi
    
    printf "%-15s : %s%s %+d%s\e[0m (%d → %d)\n" \
        "$label" "$color" "$arrow" "$diff" "%" "$old_value" "$new_value"
}

# Exemple d'utilisation
echo "═══════════════════════════════════════════"
echo "  Évolution des performances (semaine)"
echo "═══════════════════════════════════════════"
show_trend "Vitesse" 85 92
show_trend "Latence" 45 38
show_trend "Erreurs" 12 12
show_trend "Disponibilité" 99 97
```

### Exemple avancé : Diagramme de flux

```bash
#!/bin/bash

# Représentation d'un pipeline de traitement
show_pipeline() {
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║          Pipeline de traitement des données       ║"
    echo "╠═══════════════════════════════════════════════════╣"
    echo "║                                                   ║"
    echo "║   ┌─────────┐   ┌──────────┐   ┌─────────┐      ║"
    echo "║   │ Entrée  │ → │ Filtrage │ → │ Sortie  │      ║"
    echo "║   └─────────┘   └──────────┘   └─────────┘      ║"
    echo "║        │              │              ↓           ║"
    echo "║        ↓              ↓         ┌─────────┐      ║"
    echo "║   ┌─────────┐   ┌──────────┐   │  Base   │      ║"
    echo "║   │ Validé  │   │  Log     │   │  Données│      ║"
    echo "║   └─────────┘   └──────────┘   └─────────┘      ║"
    echo "║                                                   ║"
    echo "╚═══════════════════════════════════════════════════╝"
}

show_pipeline
```

> [!tip] Astuce - Flèches composées Combinez plusieurs caractères de flèches pour créer des effets visuels : `→→→` pour l'emphase, `↑↓` pour les échanges bidirectionnels.

---

## ⬢ Formes géométriques

### Pourquoi utiliser les formes géométriques ?

Les formes géométriques servent à :

- Créer des puces et des listes structurées
- Indiquer des états (coché/décoché)
- Marquer des éléments importants
- Organiser visuellement l'information

### Caractères disponibles

|Caractère|Code Unicode|Nom|Utilisation typique|
|---|---|---|---|
|●|U+25CF|Cercle plein|Puce active, sélectionné|
|○|U+25CB|Cercle vide|Puce inactive, non sélectionné|
|◆|U+25C6|Losange plein|Point important, warning|
|◇|U+25C7|Losange vide|Information secondaire|
|■|U+25A0|Carré plein|Case cochée|
|□|U+25A1|Carré vide|Case non cochée|
|▪|U+25AA|Petit carré plein|Sous-puce|
|▫|U+25AB|Petit carré vide|Sous-puce inactive|

### Syntaxe de base

```bash
#!/bin/bash

# Utilisation simple des formes
echo "● Point principal"
echo "○ Point secondaire"
echo "■ Tâche complétée"
echo "□ Tâche à faire"
echo "◆ Attention importante"
echo "◇ Note facultative"
```

### Exemple pratique : Liste de tâches

```bash
#!/bin/bash

# Fonction pour afficher une checklist
show_checklist() {
    local -a tasks=(
        "true:Installer les dépendances"
        "true:Configurer l'environnement"
        "false:Exécuter les tests"
        "false:Déployer en production"
    )
    
    echo "╔════════════════════════════════════════╗"
    echo "║      Liste des tâches du projet       ║"
    echo "╠════════════════════════════════════════╣"
    
    for task in "${tasks[@]}"; do
        local status="${task%%:*}"
        local description="${task#*:}"
        
        if [ "$status" = "true" ]; then
            echo "║ ■ $description"
        else
            echo "║ □ $description"
        fi
    done
    
    echo "╚════════════════════════════════════════╝"
}

show_checklist
```

### Exemple : Menu à choix multiples

```bash
#!/bin/bash

# Menu avec sélection multiple
multi_select_menu() {
    local -a options=("Python" "JavaScript" "Go" "Rust" "Java")
    local -a selected=(false false false false false)
    local current=0
    
    while true; do
        clear
        echo "╔══════════════════════════════════════╗"
        echo "║  Sélectionnez vos langages favoris   ║"
        echo "╠══════════════════════════════════════╣"
        
        for i in "${!options[@]}"; do
            local checkbox="□"
            [ "${selected[$i]}" = "true" ] && checkbox="■"
            
            if [ $i -eq $current ]; then
                echo "║ ► $checkbox ${options[$i]}"
            else
                echo "║   $checkbox ${options[$i]}"
            fi
        done
        
        echo "╠══════════════════════════════════════╣"
        echo "║ Espace: Cocher/Décocher              ║"
        echo "║ Entrée: Valider                      ║"
        echo "╚══════════════════════════════════════╝"
        
        read -rsn1 key
        case "$key" in
            A) ((current > 0)) && ((current--)) ;;  # Haut
            B) ((current < ${#options[@]} - 1)) && ((current++)) ;;  # Bas
            " ") # Espace - toggle selection
                if [ "${selected[$current]}" = "true" ]; then
                    selected[$current]=false
                else
                    selected[$current]=true
                fi
                ;;
            "") # Entrée - valider
                clear
                echo "Langages sélectionnés :"
                for i in "${!options[@]}"; do
                    [ "${selected[$i]}" = "true" ] && echo "  ● ${options[$i]}"
                done
                break
                ;;
        esac
    done
}

multi_select_menu
```

### Exemple avancé : Indicateurs de statut

```bash
#!/bin/bash

# Fonction pour afficher le statut des services
show_service_status() {
    declare -A services=(
        ["Apache"]="running"
        ["MySQL"]="running"
        ["Redis"]="stopped"
        ["Nginx"]="error"
        ["Docker"]="running"
    )
    
    echo "╔═══════════════════════════════════════════╗"
    echo "║        État des services système          ║"
    echo "╠═══════════════════════════════════════════╣"
    
    for service in "${!services[@]}"; do
        local status="${services[$service]}"
        local icon color
        
        case "$status" in
            "running")
                icon="●"
                color="\e[32m"  # Vert
                ;;
            "stopped")
                icon="○"
                color="\e[33m"  # Jaune
                ;;
            "error")
                icon="◆"
                color="\e[31m"  # Rouge
                ;;
        esac
        
        printf "║ %b%-15s%b %b%-10s%b ║\n" \
            "$color" "$icon $service" "\e[0m" \
            "$color" "$status" "\e[0m"
    done
    
    echo "╠═══════════════════════════════════════════╣"
    echo "║ Légende :                                 ║"
    echo "║   \e[32m● En fonctionnement\e[0m                      ║"
    echo "║   \e[33m○ Arrêté\e[0m                                ║"
    echo "║   \e[31m◆ Erreur\e[0m                                ║"
    echo "╚═══════════════════════════════════════════╝"
}

show_service_status
```

> [!tip] Astuce - Hiérarchie visuelle Utilisez différentes tailles de formes pour créer des niveaux d'indentation :
> 
> ```bash
> ● Niveau 1
>   ▪ Sous-niveau 1.1
>   ▪ Sous-niveau 1.2
> ● Niveau 2
>   ▪ Sous-niveau 2.1
> ```

---

## ➖ Séparateurs et lignes

### Pourquoi utiliser les séparateurs ?

Les séparateurs permettent de :

- Structurer visuellement le contenu
- Délimiter des sections logiques
- Créer des titres et des en-têtes
- Améliorer la lisibilité globale

### Caractères disponibles

|Caractère|Code Unicode|Nom|Utilisation typique|
|---|---|---|---|
|―|U+2015|Tiret horizontal|Séparateur épais|
|─|U+2500|Ligne horizontale fine|Bordures de boîtes|
|═|U+2550|Double ligne horizontale|Séparateurs importants|
|•|U+2022|Puce|Liste à puces|
|·|U+00B7|Point médian|Sous-séparateur, espacement|
|※|U+203B|Marque de référence|Note importante|

### Syntaxe de base

```bash
#!/bin/bash

# Création de séparateurs simples
echo "═══════════════════════════════════════════════"
echo "         Section principale"
echo "═══════════════════════════════════════════════"

echo ""
echo "───────────────────────────────────────────────"
echo "         Sous-section"
echo "───────────────────────────────────────────────"
```

### Exemple pratique : Création de titres

```bash
#!/bin/bash

# Fonction pour créer des titres stylisés
print_title() {
    local title=$1
    local width=${2:-50}
    local char=${3:-"═"}
    
    # Ligne supérieure
    printf "%${width}s\n" | tr ' ' "$char"
    
    # Titre centré
    local padding=$(( (width - ${#title}) / 2 ))
    printf "%${padding}s%s\n" "" "$title"
    
    # Ligne inférieure
    printf "%${width}s\n" | tr ' ' "$char"
}

# Utilisation
print_title "RAPPORT MENSUEL" 60 "═"
echo ""
print_title "Statistiques générales" 60 "─"
```

### Exemple : Sections avec puces

```bash
#!/bin/bash

# Affichage structuré avec différents niveaux de puces
show_structured_list() {
    echo "╔═══════════════════════════════════════════════╗"
    echo "║          Fonctionnalités du système           ║"
    echo "╠═══════════════════════════════════════════════╣"
    echo "║                                               ║"
    echo "║ • Authentification                            ║"
    echo "║   · Connexion par email                       ║"
    echo "║   · Connexion OAuth                           ║"
    echo "║   · Double authentification                   ║"
    echo "║                                               ║"
    echo "║ • Gestion des utilisateurs                    ║"
    echo "║   · Création de profils                       ║"
    echo "║   · Modification des permissions              ║"
    echo "║   · Export des données                        ║"
    echo "║                                               ║"
    echo "║ • Rapports et statistiques                    ║"
    echo "║   · Tableaux de bord                          ║"
    echo "║   · Export PDF/Excel                          ║"
    echo "║   · Planification automatique                 ║"
    echo "║                                               ║"
    echo "╚═══════════════════════════════════════════════╝"
}

show_structured_list
```

### Exemple avancé : Séparateurs contextuels

```bash
#!/bin/bash

# Fonction pour créer des séparateurs avec contexte
create_separator() {
    local type=$1
    local width=${2:-70}
    
    case "$type" in
        "section")
            printf "%${width}s\n" | tr ' ' '═'
            ;;
        "subsection")
            printf "%${width}s\n" | tr ' ' '─'
            ;;
        "info")
            printf "※ %$((width-2))s ※\n" | tr ' ' '·'
            ;;
        "warning")
            printf "▲ %$((width-2))s ▲\n" | tr ' ' '─'
            ;;
    esac
}

# Fonction pour afficher un document structuré
display_report() {
    clear
    
    create_separator "section"
    echo "                     RAPPORT D'ACTIVITÉ"
    create_separator "section"
    echo ""
    
    create_separator "subsection"
    echo "1. Résumé exécutif"
    create_separator "subsection"
    echo "Les objectifs du trimestre ont été atteints à 95%."
    echo ""
    
    create_separator "info"
    echo "※ NOTE: Les données sont basées sur les 3 derniers mois"
    create_separator "info"
    echo ""
    
    create_separator "subsection"
    echo "2. Métriques principales"
    create_separator "subsection"
    echo "  • Utilisateurs actifs : 12,543 (+15%)"
    echo "  • Temps de réponse moyen : 245ms (-8%)"
    echo "  • Taux de disponibilité : 99.97%"
    echo ""
    
    create_separator "warning"
    echo "▲ ATTENTION: Budget restant pour Q4 : 35%"
    create_separator "warning"
}

display_report
```

### Exemple : En-têtes de logs

```bash
#!/bin/bash

# Fonction pour logger avec séparateurs
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO")
            echo "[$timestamp] • $message"
            ;;
        "WARNING")
            echo "[$timestamp] ◆ $message"
            ;;
        "ERROR")
            echo "───────────────────────────────────────"
            echo "[$timestamp] ■ ERREUR: $message"
            echo "───────────────────────────────────────"
            ;;
        "SECTION")
            echo ""
            echo "═══════════════════════════════════════"
            echo "  $message"
            echo "═══════════════════════════════════════"
            ;;
    esac
}

# Exemple d'utilisation
log_message "SECTION" "Démarrage de l'application"
log_message "INFO" "Chargement de la configuration"
log_message "INFO" "Connexion à la base de données établie"
log_message "WARNING" "Limite de mémoire à 75%"
log_message "ERROR" "Impossible de se connecter au service externe"
```

> [!tip] Astuce - Longueur dynamique Calculez la largeur du terminal pour des séparateurs adaptatifs :
> 
> ```bash
> width=$(tput cols)
> printf "%${width}s\n" | tr ' ' '─'
> ```

---

## ✅ Bonnes pratiques

### Cohérence visuelle

> [!info] Principe de cohérence Établissez une convention visuelle pour votre projet et respectez-la dans tous vos scripts.

```bash
#!/bin/bash

# Conventions établies
readonly CHAR_SUCCESS="●"
readonly CHAR_ERROR="◆"
readonly CHAR_INFO="○"
readonly CHAR_SEPARATOR="═"
readonly CHAR_SUBSEPARATOR="─"

# Utilisation cohérente
echo "$CHAR_SUCCESS Installation réussie"
echo "$CHAR_ERROR Erreur de connexion"
echo "$CHAR_INFO Pour plus d'informations, consultez le manuel"
```

### Performance et compatibilité

> [!warning] Attention à la compatibilité Tous les terminaux ne supportent pas parfaitement Unicode. Testez sur différents environnements.

```bash
#!/bin/bash

# Test de compatibilité Unicode
test_unicode_support() {
    local test_chars="█▓▒░●○■□"
    echo "Test d'affichage: $test_chars"
    echo "Si les caractères s'affichent correctement, Unicode est supporté."
    
    # Vérification de l'encodage
    if [ "$LANG" != *"UTF-8"* ]; then
        echo "⚠ Warning: L'encodage n'est pas UTF-8"
        echo "   Exécutez: export LANG=fr_FR.UTF-8"
    fi
}

# Fonction de fallback
display_with_fallback() {
    local use_unicode=${USE_UNICODE:-true}
    
    if [ "$use_unicode" = "true" ]; then
        echo "● Succès"
        echo "◆ Erreur"
        echo "○ Information"
    else
        echo "[OK] Succès"
        echo "[!!] Erreur"
        echo "[--] Information"
    fi
}
```

### Accessibilité

> [!tip] Pensez à l'accessibilité Ne vous fiez pas uniquement aux formes pour transmettre l'information. Ajoutez du texte descriptif.

```bash
#!/bin/bash

# Bon exemple - Information explicite
echo "● [SUCCÈS] Opération terminée avec succès"
echo "◆ [ERREUR] Échec de la connexion au serveur"
echo "○ [INFO] Mise à jour disponible"

# Mauvais exemple - Information uniquement visuelle
echo "●"  # Qu'est-ce que cela signifie ?
echo "◆"  # Pas clair sans contexte
```

### Organisation du code

```bash
#!/bin/bash

# ═══════════════════════════════════════════════════
#  Configuration des caractères décoratifs
# ═══════════════════════════════════════════════════

# Blocs et ombrages
readonly BLOCK_FULL="█"
readonly BLOCK_DENSE="▓"
readonly BLOCK_MEDIUM="▒"
readonly BLOCK_LIGHT="░"

# Flèches
readonly ARROW_RIGHT="→"
readonly ARROW_LEFT="←"
readonly ARROW_UP="↑"
readonly ARROW_DOWN="↓"

# Formes
readonly CIRCLE_FULL="●"
readonly CIRCLE_EMPTY="○"
readonly SQUARE_FULL="■"
readonly SQUARE_EMPTY="□"

# Séparateurs
readonly SEP_DOUBLE="═"
readonly SEP_SINGLE="─"
readonly BULLET="•"

# ═══════════════════════════════════════════════════
#  Fonctions utilitaires
# ═══════════════════════════════════════════════════

# Fonction pour créer une ligne de séparation
separator() {
    local char=${1:-$SEP_DOUBLE}
    local width=${2:-$(tput cols)}
    printf "%${width}s\n" | tr ' ' "$char"
}

# Fonction pour afficher un message avec icône
print_status() {
    local type=$1
    local message=$2
    
    case "$type" in
        "success") echo "${CIRCLE_FULL} ${message}" ;;
        "error")   echo "${SQUARE_FULL} ${message}" ;;
        "info")    echo "${CIRCLE_EMPTY} ${message}" ;;
        "arrow")   echo "${ARROW_RIGHT} ${message}" ;;
    esac
}

# Fonction pour créer un titre avec bordures
print_section_title() {
    local title=$1
    separator "$SEP_DOUBLE"
    echo "  $title"
    separator "$SEP_DOUBLE"
}
```

### Éviter les problèmes de copier-coller

> [!warning] Problème courant Certains éditeurs ou terminaux peuvent mal interpréter les caractères Unicode lors du copier-coller.

```bash
#!/bin/bash

# Solution : Définir les caractères en variables hexadécimales
readonly BLOCK_FULL=\u2588'
readonly ARROW_RIGHT=\u2192'
readonly CIRCLE_FULL=\u25CF'

# Alternative : Utiliser printf
BLOCK_FULL=$(printf '\u2588')
ARROW_RIGHT=$(printf '\u2192')
CIRCLE_FULL=$(printf '\u25CF')

# Utilisation
echo "Progression : ${BLOCK_FULL}${BLOCK_FULL}${BLOCK_FULL}"
echo "Direction ${ARROW_RIGHT} Suivant"
echo "${CIRCLE_FULL} Élément actif"
```

### Optimisation des performances

> [!tip] Optimisation Pour des affichages fréquents (comme des barres de progression), précalculez les chaînes de caractères.

```bash
#!/bin/bash

# Pré-génération de barres pour éviter les calculs répétitifs
generate_bar_patterns() {
    local max_width=100
    
    # Génération des patterns une seule fois
    for ((i=0; i<=max_width; i++)); do
        BARS_FULL[$i]=$(printf "%${i}s" | tr ' ' '█')
        BARS_EMPTY[$i]=$(printf "%${i}s" | tr ' ' '░')
    done
}

# Fonction de barre de progression optimisée
fast_progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    # Utilisation des barres précalculées
    printf "\r[%s%s] %3d%%" \
        "${BARS_FULL[$filled]}" \
        "${BARS_EMPTY[$empty]}" \
        "$((current * 100 / total))"
}

# Initialisation
declare -a BARS_FULL
declare -a BARS_EMPTY
generate_bar_patterns

# Utilisation rapide
for i in {1..100}; do
    fast_progress_bar "$i" 100
    sleep 0.01
done
echo ""
```

### Documentation et maintenabilité

```bash
#!/bin/bash

# ═══════════════════════════════════════════════════
#  Script de démonstration - Caractères Unicode
#  
#  Ce script utilise les conventions visuelles suivantes:
#    ● (U+25CF) = Succès / État actif
#    ◆ (U+25C6) = Avertissement / Important
#    ○ (U+25CB) = Information / État inactif
#    ■ (U+25A0) = Erreur / Case cochée
#    □ (U+25A1) = À faire / Case non cochée
#    → (U+2192) = Progression / Action
#    ═ (U+2550) = Séparateur principal
#    ─ (U+2500) = Séparateur secondaire
#
#  Encodage requis: UTF-8
#  Testé sur: Bash 4.4+, Zsh 5.8+
# ═══════════════════════════════════════════════════

# Configuration des caractères avec description
readonly ICON_SUCCESS="●"    # Opération réussie
readonly ICON_ERROR="◆"      # Erreur critique
readonly ICON_INFO="○"       # Information générale
readonly ICON_TODO="□"       # Tâche à faire
readonly ICON_DONE="■"       # Tâche complétée

# Exemple d'utilisation documentée
display_task_status() {
    local task_name=$1
    local is_complete=$2
    
    if [ "$is_complete" = "true" ]; then
        echo "${ICON_DONE} ${task_name}"
    else
        echo "${ICON_TODO} ${task_name}"
    fi
}
```

### Gestion des erreurs

```bash
#!/bin/bash

# Vérification de l'environnement
check_unicode_environment() {
    local errors=0
    
    # Vérification de l'encodage
    if [[ "$LANG" != *"UTF-8"* ]] && [[ "$LC_ALL" != *"UTF-8"* ]]; then
        echo "⚠ Avertissement: L'encodage UTF-8 n'est pas détecté"
        echo "  Encodage actuel: ${LANG:-non défini}"
        echo "  Solution: export LANG=fr_FR.UTF-8"
        ((errors++))
    fi
    
    # Test d'affichage
    local test_display="█▓▒░●○■□→←"
    echo "Test d'affichage Unicode: $test_display"
    
    read -p "Les caractères s'affichent-ils correctement? (o/n): " response
    if [[ "$response" != "o" ]]; then
        echo "✗ Votre terminal ne supporte pas correctement Unicode"
        echo "  Utilisez un terminal moderne (GNOME Terminal, iTerm2, etc.)"
        ((errors++))
    fi
    
    return $errors
}

# Fonction avec gestion d'erreur
safe_unicode_display() {
    if ! check_unicode_environment; then
        echo "Passage en mode ASCII de secours..."
        USE_UNICODE=false
    else
        echo "✓ Mode Unicode activé"
        USE_UNICODE=true
    fi
}
```

### Tableaux de référence rapide

```bash
#!/bin/bash

# Fonction pour afficher un guide de référence
show_unicode_reference() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║               GUIDE DE RÉFÉRENCE - UNICODE BASH               ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  BLOCS ET OMBRAGES                                            ║
║  ─────────────────                                            ║
║  █  U+2588  Bloc plein           (Barre 100%)                 ║
║  ▓  U+2593  Ombre dense          (Barre 75%)                  ║
║  ▒  U+2592  Ombre moyenne        (Barre 50%)                  ║
║  ░  U+2591  Ombre légère         (Barre 25%)                  ║
║  ▀  U+2580  Demi-bloc supérieur  (Graphique haute résolution) ║
║  ▄  U+2584  Demi-bloc inférieur  (Graphique haute résolution) ║
║                                                               ║
║  FLÈCHES ET DIRECTIONS                                        ║
║  ─────────────────────                                        ║
║  →  U+2192  Flèche droite        (Suivant, progression)       ║
║  ←  U+2190  Flèche gauche        (Retour, annulation)         ║
║  ↑  U+2191  Flèche haut          (Upload, amélioration)       ║
║  ↓  U+2193  Flèche bas           (Download, diminution)       ║
║  ⇒  U+21D2  Double flèche        (Résultat, implication)      ║
║  ▲  U+25B2  Triangle haut        (Tri ascendant)              ║
║  ▼  U+25BC  Triangle bas         (Tri descendant)             ║
║  ►  U+25BA  Triangle droit       (Lecture, sélection active)  ║
║                                                               ║
║  FORMES GÉOMÉTRIQUES                                          ║
║  ───────────────────                                          ║
║  ●  U+25CF  Cercle plein         (Actif, succès)              ║
║  ○  U+25CB  Cercle vide          (Inactif, info)              ║
║  ■  U+25A0  Carré plein          (Coché, erreur)              ║
║  □  U+25A1  Carré vide           (Non coché, à faire)         ║
║  ◆  U+25C6  Losange plein        (Avertissement)              ║
║  ◇  U+25C7  Losange vide         (Note)                       ║
║                                                               ║
║  SÉPARATEURS                                                  ║
║  ───────────                                                  ║
║  ═  U+2550  Double ligne         (Titre principal)            ║
║  ─  U+2500  Ligne simple         (Sous-titre)                 ║
║  •  U+2022  Puce                 (Liste)                      ║
║  ·  U+00B7  Point médian         (Sous-liste)                 ║
║  ※  U+203B  Marque référence     (Note importante)            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

EXEMPLES D'UTILISATION :

1. Barre de progression
   [█████████░░░░░░░] 60%

2. Menu de navigation
   ► Option 1
     Option 2
     Option 3

3. Liste de tâches
   ■ Tâche complétée
   □ Tâche en attente

4. Indicateurs d'état
   ● Service actif
   ○ Service inactif
   ◆ Avertissement

5. Flux de données
   Entrée → Traitement → Sortie

CONSEILS :
• Utilisez toujours UTF-8 : export LANG=fr_FR.UTF-8
• Testez sur différents terminaux
• Préférez les variables pour faciliter la maintenance
• Ajoutez des alternatives ASCII pour la compatibilité

EOF
}

# Affichage du guide
show_unicode_reference
```

---

## 🎯 Pièges courants à éviter

### Piège 1 : Mauvaise gestion de la largeur

> [!warning] Problème de largeur de caractères Certains caractères Unicode occupent 2 colonnes au lieu d'une, ce qui peut désaligner vos affichages.

```bash
#!/bin/bash

# ❌ MAUVAIS - Ne prend pas en compte la largeur Unicode
bad_align() {
    printf "%-20s : %s\n" "Nom●●●" "Valeur"
    printf "%-20s : %s\n" "Description" "Autre valeur"
    # Les ● comptent pour plus d'une colonne !
}

# ✓ BON - Calcul correct de la largeur
good_align() {
    local text="Nom●●●"
    local visual_width=$(echo -n "$text" | wc -m)
    local padding=$((20 - visual_width))
    printf "%s%${padding}s : %s\n" "$text" "" "Valeur"
}
```

### Piège 2 : Caractères invisibles

```bash
#!/bin/bash

# ❌ MAUVAIS - Utilisation de caractères qui peuvent être invisibles
echo "Chargement en cours   "  # Espaces invisibles
echo "État: ​actif"  # Espace unicode zero-width

# ✓ BON - Utilisation de caractères visibles
echo "Chargement en cours..."
echo "État: ░░░ actif"
```

### Piège 3 : Sur-utilisation

```bash
#!/bin/bash

# ❌ MAUVAIS - Trop de décorations nuit à la lisibilité
echo "╔═══════════════════════════════════════╗"
echo "║ ◆◆◆ ATTENTION ◆◆◆                    ║"
echo "║ ●●● Information importante ●●●        ║"
echo "║ ►►► Cliquez ici ◄◄◄                  ║"
echo "╚═══════════════════════════════════════╝"

# ✓ BON - Utilisation modérée et ciblée
echo "╔═══════════════════════════════════════╗"
echo "║ ◆ ATTENTION                           ║"
echo "║   Information importante              ║"
echo "╚═══════════════════════════════════════╝"
```

---

## 💡 Astuces avancées

### Astuce 1 : Création de motifs complexes

```bash
#!/bin/bash

# Fonction pour créer un motif de damier
create_checkerboard() {
    local width=$1
    local height=$2
    local dark="▓"
    local light="░"
    
    for ((row=0; row<height; row++)); do
        for ((col=0; col<width; col++)); do
            if (( (row + col) % 2 == 0 )); then
                printf "%s" "$dark"
            else
                printf "%s" "$light"
            fi
        done
        echo
    done
}

# Utilisation
echo "Motif damier 10x5 :"
create_checkerboard 10 5
```

### Astuce 2 : Animation avec caractères Unicode

```bash
#!/bin/bash

# Animation de rotation
spinner_animation() {
    local pid=$1
    local delay=0.1
    local spinners=("◐" "◓" "◑" "◒")
    local i=0
    
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${spinners[$i]} Traitement en cours..."
        i=$(( (i + 1) % ${#spinners[@]} ))
        sleep "$delay"
    done
    
    printf "\r● Traitement terminé !   \n"
}

# Exemple d'utilisation
(sleep 3) &
spinner_animation $!
```

### Astuce 3 : Graphiques sparkline

```bash
#!/bin/bash

# Création de mini-graphiques en ligne (sparklines)
create_sparkline() {
    local -a values=("$@")
    local -a blocks=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
    
    # Trouver min et max
    local min=${values[0]}
    local max=${values[0]}
    for val in "${values[@]}"; do
        ((val < min)) && min=$val
        ((val > max)) && max=$val
    done
    
    local range=$((max - min))
    [ $range -eq 0 ] && range=1
    
    # Afficher le graphique
    for val in "${values[@]}"; do
        local normalized=$(( (val - min) * 7 / range ))
        printf "%s" "${blocks[$normalized]}"
    done
    echo
}

# Exemple d'utilisation
echo -n "CPU Usage (last 20s): "
create_sparkline 45 52 48 55 60 58 62 65 63 60 58 55 50 48 45 42 40 38 36 35

echo -n "Memory Usage:         "
create_sparkline 30 32 35 38 40 42 45 48 50 52 55 58 60 62 65 68 70 72 75 78
```

### Astuce 4 : Tableaux de données visuels

```bash
#!/bin/bash

# Création d'un tableau de données avec barres
display_data_table() {
    echo "╔═══════════════╦══════════════════════════════╦═══════╗"
    echo "║   Catégorie   ║         Visualisation        ║ Valeur║"
    echo "╠═══════════════╬══════════════════════════════╬═══════╣"
    
    local -A data=(
        ["Ventes"]=85
        ["Marketing"]=65
        ["Support"]=45
        ["R&D"]=92
    )
    
    for key in "${!data[@]}"; do
        local value=${data[$key]}
        local bar_length=$((value * 20 / 100))
        local bar=$(printf "%${bar_length}s" | tr ' ' '█')
        local empty=$(printf "%$((20 - bar_length))s" | tr ' ' '░')
        
        printf "║ %-13s ║ %s%s ║  %3d%% ║\n" \
            "$key" "$bar" "$empty" "$value"
    done
    
    echo "╚═══════════════╩══════════════════════════════╩═══════╝"
}

display_data_table
```

### Astuce 5 : Combinaison de caractères pour effets spéciaux

```bash
#!/bin/bash

# Création d'un effet de remplissage progressif
filling_effect() {
    local stages=("░" "▒" "▓" "█")
    local width=30
    
    echo "Initialisation du système..."
    
    for stage in "${stages[@]}"; do
        printf "\r["
        printf "%${width}s" | tr ' ' "$stage"
        printf "]"
        sleep 0.3
    done
    
    echo -e "\n✓ Système initialisé"
}

# Effet de pulsation
pulse_effect() {
    local message=$1
    local chars=("○" "◔" "◐" "◕" "●" "◕" "◐" "◔")
    
    for i in {1..3}; do
        for char in "${chars[@]}"; do
            printf "\r%s %s" "$char" "$message"
            sleep 0.05
        done
    done
    echo
}

# Exemples
filling_effect
pulse_effect "Connexion au serveur"
```

---

## 📊 Cas d'usage pratiques complets

### Cas 1 : Moniteur système élégant

```bash
#!/bin/bash

system_monitor() {
    clear
    
    # Fonction pour obtenir l'utilisation CPU
    get_cpu_usage() {
        top -bn1 | grep "Cpu(s)" | awk '{print int($2)}'
    }
    
    # Fonction pour obtenir l'utilisation mémoire
    get_mem_usage() {
        free | grep Mem | awk '{print int($3/$2 * 100)}'
    }
    
    # Fonction pour créer une barre colorée
    colored_bar() {
        local value=$1
        local width=40
        local filled=$((value * width / 100))
        local empty=$((width - filled))
        
        # Couleur selon le niveau
        if ((value < 60)); then
            color="\e[32m"  # Vert
        elif ((value < 80)); then
            color="\e[33m"  # Jaune
        else
            color="\e[31m"  # Rouge
        fi
        
        printf "%b" "$color"
        printf "%${filled}s" | tr ' ' '█'
        printf "\e[0m"
        printf "%${empty}s" | tr ' ' '░'
    }
    
    while true; do
        clear
        echo "╔════════════════════════════════════════════════════╗"
        echo "║          MONITEUR SYSTÈME EN TEMPS RÉEL            ║"
        echo "╠════════════════════════════════════════════════════╣"
        echo "║                                                    ║"
        
        cpu=$(get_cpu_usage)
        mem=$(get_mem_usage)
        
        printf "║ CPU    [$(colored_bar $cpu)] %3d%% ║\n" "$cpu"
        printf "║ Mémoire[$(colored_bar $mem)] %3d%% ║\n" "$mem"
        
        echo "║                                                    ║"
        echo "╠════════════════════════════════════════════════════╣"
        echo "║ État des services:                                 ║"
        echo "║   ● SSH       ● Apache     ○ MySQL                 ║"
        echo "║   ● Docker    ● Nginx      ● Redis                 ║"
        echo "╚════════════════════════════════════════════════════╝"
        
        sleep 2
    done
}

# Lancement du moniteur
# system_monitor
```

### Cas 2 : Installeur interactif professionnel

```bash
#!/bin/bash

professional_installer() {
    local steps=("Vérification système" "Téléchargement" "Installation" "Configuration" "Finalisation")
    local current_step=0
    
    clear
    echo "╔════════════════════════════════════════════════════╗"
    echo "║         ASSISTANT D'INSTALLATION v2.0              ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo ""
    
    for step in "${steps[@]}"; do
        ((current_step++))
        
        # Affichage de l'étape courante
        echo "──────────────────────────────────────────────────────"
        printf "Étape %d/%d : %s\n" "$current_step" "${#steps[@]}" "$step"
        echo "──────────────────────────────────────────────────────"
        
        # Barre de progression pour l'étape
        for i in {1..100}; do
            local bar_length=$((i * 40 / 100))
            local bar=$(printf "%${bar_length}s" | tr ' ' '█')
            local empty=$(printf "%$((40 - bar_length))s" | tr ' ' '░')
            printf "\r[%s%s] %3d%%" "$bar" "$empty" "$i"
            sleep 0.02
        done
        
        echo -e "\n● $step terminé\n"
        sleep 0.5
    done
    
    echo "╔════════════════════════════════════════════════════╗"
    echo "║  ✓ Installation terminée avec succès !             ║"
    echo "╚════════════════════════════════════════════════════╝"
}

# professional_installer
```

---

## 🎓 Récapitulatif

> [!tip] Points clés à retenir
> 
> 1. **Les caractères Unicode enrichissent vos scripts** sans dépendances externes
> 2. **Utilisez des variables** pour maintenir et modifier facilement vos caractères
> 3. **Testez la compatibilité** sur différents terminaux et environnements
> 4. **Restez cohérent** dans vos conventions visuelles
> 5. **N'en abusez pas** - la lisibilité prime sur l'esthétique
> 6. **Toujours fournir du contexte textuel** en plus des symboles visuels
> 7. **Vérifiez l'encodage UTF-8** avant d'utiliser ces caractères

```bash
# Template de démarrage recommandé
#!/bin/bash

# Configuration de l'environnement
export LANG=fr_FR.UTF-8

# Définition des constantes visuelles
readonly UI_SUCCESS="●"
readonly UI_ERROR="◆"
readonly UI_INFO="○"
readonly UI_SEPARATOR="═"
readonly UI_ARROW="→"

# Vérification de compatibilité
if [[ "$LANG" != *"UTF-8"* ]]; then
    echo "⚠ Attention: UTF-8 non détecté"
    exit 1
fi

# Votre code ici...
```

---

_Cours créé pour l'embellissement des scripts Bash - Partie: Caractères Unicode et bordures_