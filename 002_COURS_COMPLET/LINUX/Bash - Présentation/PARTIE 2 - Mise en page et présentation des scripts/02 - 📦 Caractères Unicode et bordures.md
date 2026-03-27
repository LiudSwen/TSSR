

> [!abstract] Vue d'ensemble Les caractères Unicode Box Drawing permettent de créer des interfaces visuelles élégantes directement dans le terminal. Cette partie explore tous les styles de bordures disponibles et comment les utiliser efficacement dans vos scripts Bash.

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

## 🎯 Introduction aux Box Drawing

### Qu'est-ce que le Box Drawing ?

Les caractères Box Drawing sont un ensemble de caractères Unicode (U+2500 à U+257F) conçus spécifiquement pour dessiner des cadres, des tableaux et des diagrammes en mode texte.

> [!info] Pourquoi utiliser Box Drawing ?
> 
> - **Compatibilité** : Fonctionne dans tous les terminaux modernes
> - **Léger** : Aucune dépendance externe nécessaire
> - **Professionnel** : Donne un aspect soigné à vos scripts
> - **Lisibilité** : Structure visuellement l'information

### Support Unicode en Bash

```bash
# Vérifier le support Unicode de votre terminal
echo $LANG  # Devrait contenir UTF-8

# Forcer l'encodage UTF-8 si nécessaire
export LANG=fr_FR.UTF-8
export LC_ALL=fr_FR.UTF-8
```

> [!warning] Attention à l'encodage Assurez-vous toujours que votre script commence par `#!/bin/bash` et que votre terminal est configuré en UTF-8. Sans cela, les caractères s'afficheront incorrectement.

---

## ─ Bordures simples

### Caractères de base

Les bordures simples sont les plus couramment utilisées pour leur clarté et leur légèreté visuelle.

| Caractère | Unicode | Description        | Nom                 |
| :-------: | :-----: | :----------------- | :------------------ |
|     ─     | U+2500  | Ligne horizontale  | HORIZONTAL          |
|     │     | U+2502  | Ligne verticale    | VERTICAL            |
|     ┌     | U+250C  | Coin haut-gauche   | DOWN RIGHT          |
|     ┐     | U+2510  | Coin haut-droit    | DOWN LEFT           |
|     └     | U+2514  | Coin bas-gauche    | UP RIGHT            |
|     ┘     | U+2518  | Coin bas-droit     | UP LEFT             |
|     ├     | U+251C  | T-jonction gauche  | VERTICAL RIGHT      |
|     ┤     | U+2524  | T-jonction droite  | VERTICAL LEFT       |
|     ┬     | U+252C  | T-jonction haut    | DOWN HORIZONTAL     |
|     ┴     | U+2534  | T-jonction bas     | UP HORIZONTAL       |
|     ┼     | U+253C  | Croix/intersection | VERTICAL HORIZONTAL |

### Set complet pour copier-coller

```bash
# Bordures simples - Variables
SIMPLE_H="─"    # U+2500 - Horizontale
SIMPLE_V="│"    # U+2502 - Verticale
SIMPLE_TL="┌"   # U+250C - Coin haut-gauche
SIMPLE_TR="┐"   # U+2510 - Coin haut-droit
SIMPLE_BL="└"   # U+2514 - Coin bas-gauche
SIMPLE_BR="┘"   # U+2518 - Coin bas-droit
SIMPLE_VR="├"   # U+251C - T-jonction gauche
SIMPLE_VL="┤"   # U+2524 - T-jonction droite
SIMPLE_DH="┬"   # U+252C - T-jonction haut
SIMPLE_UH="┴"   # U+2534 - T-jonction bas
SIMPLE_VH="┼"   # U+253C - Croix

# Ensemble complet en une ligne pour copier
# ─│┌┐└┘├┤┬┴┼
```

### Exemple pratique : Cadre simple

```bash
#!/bin/bash

# Fonction pour créer un cadre simple
draw_simple_box() {
    local text="$1"
    local width=${#text}
    local padding=2
    local total_width=$((width + padding * 2))
    
    # Ligne du haut
    echo -n "┌"
    printf '─%.0s' $(seq 1 $total_width)
    echo "┐"
    
    # Contenu
    echo "│$(printf "%*s" $padding "")${text}$(printf "%*s" $padding "")│"
    
    # Ligne du bas
    echo -n "└"
    printf '─%.0s' $(seq 1 $total_width)
    echo "┘"
}

# Utilisation
draw_simple_box "Bienvenue dans mon script"
```

**Résultat :**

```
┌──────────────────────────────┐
│  Bienvenue dans mon script  │
└──────────────────────────────┘
```

> [!tip] Astuce pour les dimensions dynamiques Utilisez `${#variable}` pour obtenir la longueur d'une chaîne et adapter automatiquement la taille de votre cadre.

### Tableau avec séparateurs

```bash
#!/bin/bash

# Tableau avec bordures simples
print_table_header() {
    echo "┌──────────┬──────────┬──────────┐"
    echo "│ Colonne1 │ Colonne2 │ Colonne3 │"
    echo "├──────────┼──────────┼──────────┤"
}

print_table_row() {
    printf "│ %-8s │ %-8s │ %-8s │\n" "$1" "$2" "$3"
}

print_table_footer() {
    echo "└──────────┴──────────┴──────────┘"
}

# Utilisation
print_table_header
print_table_row "Données1" "Données2" "Données3"
print_table_row "Test" "123" "ABC"
print_table_footer
```

---

## ═ Bordures doubles

### Caractères de base

Les bordures doubles donnent un aspect plus formel et permettent de hiérarchiser l'information.

|Caractère|Unicode|Description|Nom|
|:-:|:-:|:--|:--|
|═|U+2550|Ligne horizontale double|DOUBLE HORIZONTAL|
|║|U+2551|Ligne verticale double|DOUBLE VERTICAL|
|╔|U+2554|Coin haut-gauche double|DOUBLE DOWN RIGHT|
|╗|U+2557|Coin haut-droit double|DOUBLE DOWN LEFT|
|╚|U+255A|Coin bas-gauche double|DOUBLE UP RIGHT|
|╝|U+255D|Coin bas-droit double|DOUBLE UP LEFT|
|╠|U+2560|T-jonction gauche double|DOUBLE VERTICAL RIGHT|
|╣|U+2563|T-jonction droite double|DOUBLE VERTICAL LEFT|
|╦|U+2566|T-jonction haut double|DOUBLE DOWN HORIZONTAL|
|╩|U+2569|T-jonction bas double|DOUBLE UP HORIZONTAL|
|╬|U+256C|Croix double|DOUBLE VERTICAL HORIZONTAL|

### Set complet pour copier-coller

```bash
# Bordures doubles - Variables
DOUBLE_H="═"    # U+2550 - Horizontale
DOUBLE_V="║"    # U+2551 - Verticale
DOUBLE_TL="╔"   # U+2554 - Coin haut-gauche
DOUBLE_TR="╗"   # U+2557 - Coin haut-droit
DOUBLE_BL="╚"   # U+255A - Coin bas-gauche
DOUBLE_BR="╝"   # U+255D - Coin bas-droit
DOUBLE_VR="╠"   # U+2560 - T-jonction gauche
DOUBLE_VL="╣"   # U+2563 - T-jonction droite
DOUBLE_DH="╦"   # U+2566 - T-jonction haut
DOUBLE_UH="╩"   # U+2569 - T-jonction bas
DOUBLE_VH="╬"   # U+256C - Croix

# Ensemble complet en une ligne pour copier
# ═║╔╗╚╝╠╣╦╩╬
```

### Exemple : Boîte de dialogue importante

```bash
#!/bin/bash

draw_double_box() {
    local title="$1"
    local message="$2"
    local width=50
    
    # En-tête
    echo -n "╔"
    printf '═%.0s' $(seq 1 $width)
    echo "╗"
    
    # Titre centré
    local title_padding=$(( (width - ${#title}) / 2 ))
    printf "║%*s%s%*s║\n" $title_padding "" "$title" $((width - title_padding - ${#title})) ""
    
    # Séparateur
    echo -n "╠"
    printf '═%.0s' $(seq 1 $width)
    echo "╣"
    
    # Message
    printf "║ %-$((width-1))s║\n" "$message"
    
    # Pied
    echo -n "╚"
    printf '═%.0s' $(seq 1 $width)
    echo "╝"
}

# Utilisation
draw_double_box "⚠ ATTENTION" "Cette opération est irréversible !"
```

> [!example] Quand utiliser les bordures doubles ?
> 
> - Boîtes de dialogue critiques
> - En-têtes de sections importantes
> - Encadrement de résultats finaux
> - Séparation nette entre différents niveaux d'information

### Grille double pour données structurées

```bash
#!/bin/bash

# Grille avec séparateurs doubles
print_double_grid() {
    echo "╔════════════╦════════════╦════════════╗"
    echo "║   Nom      ║   Âge      ║   Ville    ║"
    echo "╠════════════╬════════════╬════════════╣"
    printf "║ %-10s ║ %-10s ║ %-10s ║\n" "Alice" "30" "Paris"
    printf "║ %-10s ║ %-10s ║ %-10s ║\n" "Bob" "25" "Lyon"
    echo "╚════════════╩════════════╩════════════╝"
}

print_double_grid
```

---

## ━ Bordures épaisses/lourdes

### Caractères de base

Les bordures épaisses (heavy/bold) créent un impact visuel fort, idéal pour les titres et alertes.

|Caractère|Unicode|Description|Nom|
|:-:|:-:|:--|:--|
|━|U+2501|Ligne horizontale épaisse|HEAVY HORIZONTAL|
|┃|U+2503|Ligne verticale épaisse|HEAVY VERTICAL|
|┏|U+250F|Coin haut-gauche épais|HEAVY DOWN RIGHT|
|┓|U+2513|Coin haut-droit épais|HEAVY DOWN LEFT|
|┗|U+2517|Coin bas-gauche épais|HEAVY UP RIGHT|
|┛|U+251B|Coin bas-droit épais|HEAVY UP LEFT|
|┣|U+2523|T-jonction gauche épaisse|HEAVY VERTICAL RIGHT|
|┫|U+252B|T-jonction droite épaisse|HEAVY VERTICAL LEFT|
|┳|U+2533|T-jonction haut épaisse|HEAVY DOWN HORIZONTAL|
|┻|U+253B|T-jonction bas épaisse|HEAVY UP HORIZONTAL|
|╋|U+254B|Croix épaisse|HEAVY VERTICAL HORIZONTAL|

### Set complet pour copier-coller

```bash
# Bordures épaisses - Variables
HEAVY_H="━"     # U+2501 - Horizontale
HEAVY_V="┃"     # U+2503 - Verticale
HEAVY_TL="┏"    # U+250F - Coin haut-gauche
HEAVY_TR="┓"    # U+2513 - Coin haut-droit
HEAVY_BL="┗"    # U+2517 - Coin bas-gauche
HEAVY_BR="┛"    # U+251B - Coin bas-droit
HEAVY_VR="┣"    # U+2523 - T-jonction gauche
HEAVY_VL="┫"    # U+252B - T-jonction droite
HEAVY_DH="┳"    # U+2533 - T-jonction haut
HEAVY_UH="┻"    # U+253B - T-jonction bas
HEAVY_VH="╋"    # U+254B - Croix

# Ensemble complet en une ligne pour copier
# ━┃┏┓┗┛┣┫┳┻╋
```

### Exemple : Bannière d'alerte

```bash
#!/bin/bash

draw_heavy_alert() {
    local message="$1"
    local width=60
    
    # Bordure supérieure
    echo -n "┏"
    printf '━%.0s' $(seq 1 $width)
    echo "┓"
    
    # Espacement
    printf "┃%*s┃\n" $width ""
    
    # Message centré
    local padding=$(( (width - ${#message}) / 2 ))
    printf "┃%*s%s%*s┃\n" $padding "" "$message" $((width - padding - ${#message})) ""
    
    # Espacement
    printf "┃%*s┃\n" $width ""
    
    # Bordure inférieure
    echo -n "┗"
    printf '━%.0s' $(seq 1 $width)
    echo "┛"
}

# Utilisation
draw_heavy_alert "🚨 ERREUR CRITIQUE : Système surchargé 🚨"
```

> [!info] Impact visuel Les bordures épaisses attirent immédiatement l'œil. Utilisez-les avec parcimonie pour ne pas surcharger l'interface.

### Menu avec bordures épaisses

```bash
#!/bin/bash

draw_heavy_menu() {
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo "┃      MENU PRINCIPAL          ┃"
    echo "┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫"
    echo "┃  1. Démarrer le service      ┃"
    echo "┃  2. Arrêter le service       ┃"
    echo "┃  3. Voir les logs            ┃"
    echo "┃  4. Configuration            ┃"
    echo "┃  5. Quitter                  ┃"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
}

draw_heavy_menu
```

---

## ╭ Bordures arrondies

### Caractères disponibles

Les bordures arrondies adoucissent l'apparence et donnent un look moderne.

| Caractère | Unicode | Description                    | Nom                  |
| :-------: | :-----: | :----------------------------- | :------------------- |
|     ╭     | U+256D  | Coin haut-gauche arrondi       | LIGHT ARC DOWN RIGHT |
|     ╮     | U+256E  | Coin haut-droit arrondi        | LIGHT ARC DOWN LEFT  |
|     ╯     | U+256F  | Coin bas-droit arrondi         | LIGHT ARC UP LEFT    |
|     ╰     | U+2570  | Coin bas-gauche arrondi        | LIGHT ARC UP RIGHT   |
|     ─     | U+2500  | Ligne horizontale (à combiner) | HORIZONTAL           |
|     │     | U+2502  | Ligne verticale (à combiner)   | VERTICAL             |
|     ├     | U+251C  | T-jonction gauche              | VERTICAL RIGHT       |
|     ┤     | U+2524  | T-jonction droite              | VERTICAL LEFT        |
|     ┬     | U+252C  | T-jonction haut                | DOWN HORIZONTAL      |
|     ┴     | U+2534  | T-jonction bas                 | UP HORIZONTAL        |
|     ┼     | U+253C  | Croix/intersection             | VERTICAL HORIZONTAL  |

> [!warning] Limitation des bordures arrondies Les caractères arrondis n'existent que pour les coins. Il faut les combiner avec des lignes simples (─ et │) pour créer des cadres complets.

### Set complet pour copier-coller

```bash
# Coins arrondis
ROUNDED_TL="╭"  # U+256D - Haut-gauche
ROUNDED_TR="╮"  # U+256E - Haut-droit
ROUNDED_BL="╰"  # U+2570 - Bas-gauche
ROUNDED_BR="╯"  # U+256F - Bas-droit

# Lignes (à utiliser avec les coins arrondis)
ROUNDED_H="─"   # U+2500 - Horizontale
ROUNDED_V="│"   # U+2502 - Verticale

# Jonctions (utiliser les jonctions simples)
ROUNDED_VR="├"  # U+251C - T-jonction gauche
ROUNDED_VL="┤"  # U+2524 - T-jonction droite
ROUNDED_DH="┬"  # U+252C - T-jonction haut
ROUNDED_UH="┴"  # U+2534 - T-jonction bas
ROUNDED_VH="┼"  # U+253C - Croix

# Ensemble complet en une ligne pour copier
# ╭─╮│╰╯├┤┬┴┼
```

### Exemple : Cadre moderne

```bash
#!/bin/bash

draw_rounded_box() {
    local text="$1"
    local width=${#text}
    local padding=2
    local total_width=$((width + padding * 2))
    
    # Ligne du haut avec coins arrondis
    echo -n "╭"
    printf '─%.0s' $(seq 1 $total_width)
    echo "╮"
    
    # Contenu
    echo "│$(printf "%*s" $padding "")${text}$(printf "%*s" $padding "")│"
    
    # Ligne du bas avec coins arrondis
    echo -n "╰"
    printf '─%.0s' $(seq 1 $total_width)
    echo "╯"
}

# Utilisation
draw_rounded_box "Interface moderne"
```

### Notification stylée

```bash
#!/bin/bash

show_notification() {
    local icon="$1"
    local title="$2"
    local message="$3"
    
    echo "╭────────────────────────────────────────╮"
    printf "│ %s  %-35s │\n" "$icon" "$title"
    echo "├────────────────────────────────────────┤"
    printf "│  %-37s │\n" "$message"
    echo "╰────────────────────────────────────────╯"
}

# Exemples
show_notification "✓" "Succès" "Opération terminée avec succès"
show_notification "ℹ" "Information" "3 mises à jour disponibles"
show_notification "⚠" "Avertissement" "Espace disque faible (15% restant)"
```

> [!tip] Design moderne Les bordures arrondies sont parfaites pour les notifications, les tooltips et les éléments d'interface destinés aux utilisateurs finaux.

---

## ┄ Bordures pointillées et tirets

### Caractères disponibles

Les bordures pointillées et en tirets permettent de créer des séparateurs visuels subtils.

|Caractère|Unicode|Description|Nom|
|:-:|:-:|:--|:--|
|┄|U+2504|Triple tiret horizontal léger|LIGHT TRIPLE DASH HORIZONTAL|
|┅|U+2505|Triple tiret horizontal épais|HEAVY TRIPLE DASH HORIZONTAL|
|┆|U+2506|Triple tiret vertical léger|LIGHT TRIPLE DASH VERTICAL|
|┇|U+2507|Triple tiret vertical épais|HEAVY TRIPLE DASH VERTICAL|
|┈|U+2508|Quadruple tiret horizontal léger|LIGHT QUADRUPLE DASH HORIZONTAL|
|┉|U+2509|Quadruple tiret horizontal épais|HEAVY QUADRUPLE DASH HORIZONTAL|
|┊|U+250A|Quadruple tiret vertical léger|LIGHT QUADRUPLE DASH VERTICAL|
|┋|U+250B|Quadruple tiret vertical épais|HEAVY QUADRUPLE DASH VERTICAL|

### Set complet pour copier-coller

```bash
# Bordures pointillées/tirets - Variables
DASH_H_LIGHT3="┄"   # U+2504 - Triple tiret horizontal léger
DASH_H_HEAVY3="┅"   # U+2505 - Triple tiret horizontal épais
DASH_V_LIGHT3="┆"   # U+2506 - Triple tiret vertical léger
DASH_V_HEAVY3="┇"   # U+2507 - Triple tiret vertical épais
DASH_H_LIGHT4="┈"   # U+2508 - Quadruple tiret horizontal léger
DASH_H_HEAVY4="┉"   # U+2509 - Quadruple tiret horizontal épais
DASH_V_LIGHT4="┊"   # U+250A - Quadruple tiret vertical léger
DASH_V_HEAVY4="┋"   # U+250B - Quadruple tiret vertical épais

# Ensemble complet en une ligne pour copier
# ┄┅┆┇┈┉┊┋

# Note : Pour créer des cadres, combiner avec les coins simples
# Coins à utiliser : ┌┐└┘ (simples) ou ╭╮╰╯ (arrondis)
```

> [!info] Utilisation des bordures pointillées Les bordures pointillées n'ont pas de coins dédiés. Combinez-les avec les coins des bordures simples (┌┐└┘) ou arrondies (╭╮╰╯) pour créer des cadres complets.

### Exemple : Séparateurs de sections

```bash
#!/bin/bash

# Séparateur léger pour sous-sections
light_separator() {
    printf '┄%.0s' $(seq 1 50)
    echo
}

# Séparateur moyen pour sections
medium_separator() {
    printf '┈%.0s' $(seq 1 50)
    echo
}

# Séparateur épais pour sections principales
heavy_separator() {
    printf '┅%.0s' $(seq 1 50)
    echo
}

# Utilisation dans un rapport
echo "RAPPORT D'ANALYSE"
heavy_separator
echo "Section 1 : Résumé"
medium_separator
echo "  1.1 Introduction"
light_separator
echo "  Contenu..."
echo
echo "  1.2 Méthodologie"
light_separator
echo "  Contenu..."
```

### Cadre avec bordures pointillées

```bash
#!/bin/bash

draw_dashed_box() {
    local text="$1"
    local width=40
    
    # Bordure supérieure en tirets
    printf '┈%.0s' $(seq 1 $((width + 2)))
    echo
    
    # Contenu avec bordures verticales pointillées
    printf "┊ %-${width}s ┊\n" "$text"
    
    # Bordure inférieure en tirets
    printf '┈%.0s' $(seq 1 $((width + 2)))
    echo
}

# Utilisation pour des notes ou commentaires
draw_dashed_box "Note : Ce contenu est optionnel"
```

> [!example] Cas d'usage des bordures pointillées
> 
> - Séparation visuelle légère sans couper le flux de lecture
> - Indication de contenu optionnel ou secondaire
> - Bordures de zones de commentaires
> - Délimitation de sections moins importantes

---

## 🔀 Bordures mixtes

### Combinaisons simple/double

Les bordures mixtes combinent différents styles pour créer une hiérarchie visuelle sophistiquée.

|Caractère|Unicode|Description|Usage|
|:-:|:-:|:--|:--|
|╒|U+2552|Double haut, simple droite|Coin haut-gauche mixte|
|╓|U+2553|Simple haut, double droite|Coin haut-gauche mixte alt|
|╕|U+2555|Double haut, simple gauche|Coin haut-droit mixte|
|╖|U+2556|Simple haut, double gauche|Coin haut-droit mixte alt|
|╘|U+2558|Double bas, simple droite|Coin bas-gauche mixte|
|╙|U+2559|Simple bas, double droite|Coin bas-gauche mixte alt|
|╛|U+255B|Double bas, simple gauche|Coin bas-droit mixte|
|╜|U+255C|Simple bas, double gauche|Coin bas-droit mixte alt|
|╞|U+255E|Double vert, simple horiz|T-jonction gauche mixte|
|╟|U+255F|Simple vert, double horiz|T-jonction gauche mixte alt|
|╡|U+2561|Double vert, simple horiz|T-jonction droite mixte|
|╢|U+2562|Simple vert, double horiz|T-jonction droite mixte alt|
|╤|U+2564|Double haut, simple bas|T-jonction haut mixte|
|╥|U+2565|Simple haut, double bas|T-jonction haut mixte alt|
|╧|U+2567|Double bas, simple haut|T-jonction bas mixte|
|╨|U+2568|Simple bas, double haut|T-jonction bas mixte alt|
|╪|U+256A|Double vert, simple horiz|Croix mixte|
|╫|U+256B|Simple vert, double horiz|Croix mixte alt|

### Set complet pour copier-coller

```bash
# Bordures mixtes simple/double - Coins
MIXED_TL_1="╒"  # U+2552 - Double haut, simple droite
MIXED_TL_2="╓"  # U+2553 - Simple haut, double droite
MIXED_TR_1="╕"  # U+2555 - Double haut, simple gauche
MIXED_TR_2="╖"  # U+2556 - Simple haut, double gauche
MIXED_BL_1="╘"  # U+2558 - Double bas, simple droite
MIXED_BL_2="╙"  # U+2559 - Simple bas, double droite
MIXED_BR_1="╛"  # U+255B - Double bas, simple gauche
MIXED_BR_2="╜"  # U+255C - Simple bas, double gauche

# Bordures mixtes - Jonctions
MIXED_VR_1="╞"  # U+255E - Double vert, simple horiz
MIXED_VR_2="╟"  # U+255F - Simple vert, double horiz
MIXED_VL_1="╡"  # U+2561 - Double vert, simple horiz
MIXED_VL_2="╢"  # U+2562 - Simple vert, double horiz
MIXED_DH_1="╤"  # U+2564 - Double haut, simple bas
MIXED_DH_2="╥"  # U+2565 - Simple haut, double bas
MIXED_UH_1="╧"  # U+2567 - Double bas, simple haut
MIXED_UH_2="╨"  # U+2568 - Simple bas, double haut
MIXED_VH_1="╪"  # U+256A - Double vert, simple horiz
MIXED_VH_2="╫"  # U+256B - Simple vert, double horiz

# Ensemble complet en une ligne pour copier (version 1 : double haut/bas)
# ╒╕╘╛╞╡╤╧╪

# Ensemble complet en une ligne pour copier (version 2 : double vert)
# ╓╖╙╜╟╢╥╨╫
```

### Combinaisons simple/épais

```bash
# Bordures mixtes simple/épais - Caractères supplémentaires
MIXED_LIGHT_HEAVY_DL="┍"  # U+250D - Bas light, droite heavy
MIXED_HEAVY_LIGHT_DR="┎"  # U+250E - Bas heavy, droite light
MIXED_HEAVY_DR="┏"        # U+250F - Heavy (pour référence)
MIXED_LIGHT_HEAVY_DL2="┑" # U+2511 - Bas light, gauche heavy
MIXED_HEAVY_LIGHT_DL="┒"  # U+2512 - Bas heavy, gauche light
MIXED_LIGHT_HEAVY_UR="┕"  # U+2515 - Haut light, droite heavy
MIXED_HEAVY_LIGHT_UR="┖"  # U+2516 - Haut heavy, droite light
MIXED_LIGHT_HEAVY_UL="┙"  # U+2519 - Haut light, gauche heavy
MIXED_HEAVY_LIGHT_UL="┚"  # U+251A - Haut heavy, gauche light

# Jonctions mixtes simple/épais
MIXED_HEAVY_VR="┠"   # U+2520 - Vertical heavy, right light
MIXED_DOWN_HEAVY="┡"  # U+2521 - Down heavy, horizontal light
MIXED_UP_HEAVY="┢"    # U+2522 - Up heavy, horizontal light
MIXED_HEAVY_VL="┨"   # U+2528 - Vertical heavy, left light
MIXED_DOWN_HEAVY_L="┩" # U+2529 - Down heavy, left light
MIXED_UP_HEAVY_L="┪"  # U+252A - Up heavy, left light
MIXED_HEAVY_DH="┯"   # U+252F - Down heavy, horizontal light
MIXED_HEAVY_UH="┷"   # U+2537 - Up heavy, horizontal light
MIXED_HEAVY_VH="┿"   # U+253F - Vertical heavy, horizontal light
MIXED_HV_HEAVY="╂"   # U+2542 - Horizontal heavy, vertical light

# Ensemble en une ligne pour copier (coins mixtes)
# ┍┎┑┒┕┖┙┚

# Ensemble en une ligne pour copier (jonctions mixtes)
# ┠┡┢┨┩┪┯┷┿╂
```

### Exemple : En-tête double avec contenu simple

```bash
#!/bin/bash

draw_mixed_box_v1() {
    local title="$1"
    local content="$2"
    local width=50
    
    # En-tête avec double bordure
    echo -n "╔"
    printf '═%.0s' $(seq 1 $width)
    echo "╗"
    
    printf "║ %-$((width-1))s║\n" "$title"
    
    # Transition double vers simple
    echo -n "╠"
    printf '═%.0s' $(seq 1 $width)
    echo "╣"
    
    # Contenu avec bordure simple
    printf "║ %-$((width-1))s║\n" "$content"
    
    # Pied simple
    echo -n "╚"
    printf '═%.0s' $(seq 1 $width)
    echo "╝"
}

draw_mixed_box_v1 "CONFIGURATION SYSTÈME" "Mode : Production | Version : 2.1.4"
```

### Combinaisons simple/épais

```bash
#!/bin/bash

draw_mixed_box_v2() {
    local title="$1"
    local width=45
    
    # Bordure épaisse en haut
    echo -n "┏"
    printf '━%.0s' $(seq 1 $width)
    echo "┓"
    
    printf "┃ %-$((width-1))s┃\n" "$title"
    
    # Transition épais vers simple avec caractères mixtes
    echo -n "┡"  # U+2521 : Down heavy and right light
    printf '─%.0s' $(seq 1 $width)
    echo "┩"  # U+2529 : Down heavy and left light
    
    # Contenu avec bordure simple
    printf "│ %-$((width-1))s│\n" "Option 1 : Activé"
    printf "│ %-$((width-1))s│\n" "Option 2 : Désactivé"
    printf "│ %-$((width-1))s│\n" "Option 3 : Automatique"
    
    # Pied simple
    echo -n "└"
    printf '─%.0s' $(seq 1 $width)
    echo "┘"
}

draw_mixed_box_v2 "⚙ PARAMÈTRES"
```

> [!tip] Hiérarchie visuelle avec bordures mixtes Utilisez des bordures épaisses ou doubles pour les éléments importants (titres, en-têtes) et des bordures simples pour le contenu secondaire. Cela guide naturellement l'œil de l'utilisateur.

### Tableau avec en-tête mixte

```bash
#!/bin/bash

draw_mixed_table() {
    # En-tête avec double bordure
    echo "╔════════════╦════════════╦════════════╗"
    echo "║   Serveur  ║   Status   ║    CPU     ║"
    echo "╠════════════╬════════════╬════════════╣"
    
    # Données avec bordure simple à l'intérieur
    printf "║ %-10s ║ %-10s ║ %-10s ║\n" "web-01" "✓ En ligne" "45%"
    printf "║ %-10s ║ %-10s ║ %-10s ║\n" "web-02" "✓ En ligne" "38%"
    printf "║ %-10s ║ %-10s ║ %-10s ║\n" "db-01" "⚠ Lent" "92%"
    
    # Pied double
    echo "╚════════════╩════════════╩════════════╝"
}

draw_mixed_table
```

---

## 🎨 Création de cadres complets

### Fonction universelle de cadre

```bash
#!/bin/bash

# Fonction générique pour créer des cadres avec n'importe quel style
draw_box() {
    local style="$1"      # simple, double, heavy, rounded
    local title="$2"
    local content="$3"
    local width="${4:-50}"
    
    # Définition des caractères selon le style
    case "$style" in
        "simple")
            local h="─" v="│" tl="┌" tr="┐" bl="└" br="┘"
            local vr="├" vl="┤" dh="┬" uh="┴"
            ;;
        "double")
            local h="═" v="║" tl="╔" tr="╗" bl="╚" br="╝"
            local vr="╠" vl="╣" dh="╦" uh="╩"
            ;;
        "heavy")
            local h="━" v="┃" tl="┏" tr="┓" bl="┗" br="┛"
            local vr="┣" vl="┫" dh="┳" uh="┻"
            ;;
        "rounded")
            local h="─" v="│" tl="╭" tr="╮" bl="╰" br="╯"
            local vr="├" vl="┤" dh="┬" uh="┴"
            ;;
        *)
            echo "Style non reconnu : $style"
            return 1
            ;;
    esac
    
    # Construction du cadre
    echo -n "$tl"
    printf "${h}%.0s" $(seq 1 $width)
    echo "$tr"
    
    # Titre si présent
    if [[ -n "$title" ]]; then
        printf "$v %-$((width-1))s$v\n" "$title"
        echo -n "$vr"
        printf "${h}%.0s" $(seq 1 $width)
        echo "$vl"
    fi
    
    # Contenu
    while IFS= read -r line; do
        printf "$v %-$((width-1))s$v\n" "$line"
    done <<< "$content"
    
    # Pied
    echo -n "$bl"
    printf "${h}%.0s" $(seq 1 $width)
    echo "$br"
}

# Exemples d'utilisation
draw_box "simple" "Info" "Ceci est un message simple"
echo
draw_box "double" "Important" "Ceci est un message important"
echo
draw_box "heavy" "Alerte" "Ceci est une alerte critique"
echo
draw_box "rounded" "Note" "Ceci est une note moderne"
```

### Cadre avec en-tête et pied personnalisés

```bash
#!/bin/bash

draw_complete_frame() {
    local header="$1"
    local body="$2"
    local footer="$3"
    local width=60
    
    # En-tête avec bordure épaisse
    echo -n "┏"
    printf '━%.0s' $(seq 1 $width)
    echo "┓"
    
    # Titre centré
    local header_padding=$(( (width - ${#header}) / 2 ))
    printf "┃%*s%s%*s┃\n" $header_padding "" "$header" $((width - header_padding - ${#header})) ""
    
    # Séparateur de transition
    echo -n "┠"
    printf '─%.0s' $(seq 1 $width)
    echo "┨"
    
    # Corps avec bordure simple
    echo "$body" | while IFS= read -r line; do
        printf "│ %-$((width-1))s│\n" "$line"
    done
    
    # Séparateur avant pied
    echo -n "┠"
    printf '─%.0s' $(seq 1 $width)
    echo "┨"
    
    # Pied
    printf "┃ %-$((width-1))s┃\n" "$footer"
    
    # Bordure inférieure épaisse
    echo -n "┗"
    printf '━%.0s' $(seq 1 $width)
    echo "┛"
}

# Utilisation
body_text="Processus démarré avec succès
PID : 12345
Mémoire utilisée : 128 MB
CPU : 12%"

draw_complete_frame "🚀 RAPPORT D'EXÉCUTION" "$body_text" "Status : OK | Durée : 2.3s"
```

### Fenêtre modale avec boutons

```bash
#!/bin/bash

draw_modal_dialog() {
    local title="$1"
    local message="$2"
    local width=50
    
    # Cadre principal avec bordures doubles
    echo -n "╔"
    printf '═%.0s' $(seq 1 $width)
    echo "╗"
    
    # Titre
    local padding=$(( (width - ${#title}) / 2 ))
    printf "║%*s%s%*s║\n" $padding "" "$title" $((width - padding - ${#title})) ""
    
    # Séparateur
    echo -n "╠"
    printf '═%.0s' $(seq 1 $width)
    echo "╣"
    
    # Message (gérer plusieurs lignes)
    printf "║%*s║\n" $width ""
    echo "$message" | fold -w $((width - 4)) | while IFS= read -r line; do
        printf "║  %-$((width-2))s║\n" "$line"
    done
    printf "║%*s║\n" $width ""
    
    # Séparateur avant boutons
    echo -n "╠"
    printf '═%.0s' $(seq 1 $width)
    echo "╣"
    
    # Boutons centrés
    local buttons="[ OK ]    [ Annuler ]"
    local btn_padding=$(( (width - ${#buttons}) / 2 ))
    printf "║%*s%s%*s║\n" $btn_padding "" "$buttons" $((width - btn_padding - ${#buttons})) ""
    
    # Pied
    echo -n "╚"
    printf '═%.0s' $(seq 1 $width)
    echo "╝"
}

# Utilisation
draw_modal_dialog "⚠ Confirmation requise" "Êtes-vous sûr de vouloir supprimer ces fichiers ? Cette action est irréversible."
```

### Dashboard complexe avec plusieurs styles

```bash
#!/bin/bash

draw_dashboard() {
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                    📊 TABLEAU DE BORD                      ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║                                                            ║"
    echo "║  ┌──────────────────┐  ┌──────────────────┐                ║"
    echo "║  │  CPU: 45%    ▓▓░░│  │  RAM: 78%   ▓▓▓▓░│                ║"
    echo "║  └──────────────────┘  └──────────────────┘                ║"
    echo "║                                                            ║"
    echo "║  ╭─────────────────────────────────────────────╮           ║"
    echo "║  │ Services actifs : 12/15                     │           ║"
    echo "║  │ Connexions : 1,234                          │           ║"
    echo "║  │ Uptime : 23j 14h 32m                        │           ║"
    echo "║  ╰─────────────────────────────────────────────╯           ║"
    echo "║                                                            ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║  Dernière mise à jour : $(date '+%Y-%m-%d %H:%M:%S')       ║"
    echo "╚════════════════════════════════════════════════════════════╝"
}

draw_dashboard
```

### Cadre avec scroll/contenu long

```bash
#!/bin/bash

draw_scrollable_frame() {
    local title="$1"
    local -n lines_ref=$2  # Référence au tableau de lignes
    local width=60
    local visible_lines=10
    
    # En-tête
    echo -n "┏"
    printf '━%.0s' $(seq 1 $width)
    echo "┓"
    printf "┃ %-$((width-1))s┃\n" "$title"
    echo -n "┡"
    printf '━%.0s' $(seq 1 $width)
    echo "┩"
    
    # Contenu (limité aux premières lignes visibles)
    local total=${#lines_ref[@]}
    local displayed=0
    
    for line in "${lines_ref[@]}"; do
        if (( displayed < visible_lines )); then
            printf "│ %-$((width-1))s│\n" "$line"
            ((displayed++))
        else
            break
        fi
    done
    
    # Indicateur de scroll si nécessaire
    if (( total > visible_lines )); then
        echo -n "├"
        printf '─%.0s' $(seq 1 $width)
        echo "┤"
        local remaining=$((total - visible_lines))
        printf "│ %-$((width-1))s│\n" "... $remaining ligne(s) supplémentaire(s) ↓"
    fi
    
    # Pied
    echo -n "└"
    printf '─%.0s' $(seq 1 $width)
    echo "┘"
}

# Utilisation
declare -a log_lines=(
    "2025-01-03 10:15:23 [INFO] Service démarré"
    "2025-01-03 10:15:24 [INFO] Connexion établie"
    "2025-01-03 10:16:01 [WARN] Charge CPU élevée"
    "2025-01-03 10:17:45 [INFO] Sauvegarde effectuée"
    "2025-01-03 10:18:12 [INFO] Cache vidé"
    "2025-01-03 10:19:03 [ERROR] Timeout de connexion"
    "2025-01-03 10:19:05 [INFO] Reconnexion en cours"
    "2025-01-03 10:19:08 [INFO] Connexion rétablie"
    "2025-01-03 10:20:00 [INFO] Tâche planifiée exécutée"
    "2025-01-03 10:21:15 [INFO] Mise à jour disponible"
    "2025-01-03 10:22:30 [INFO] Monitoring actif"
    "2025-01-03 10:23:45 [DEBUG] Paramètres chargés"
)

draw_scrollable_frame "📋 LOGS SYSTÈME" log_lines
```

---

## ⚡ Bonnes pratiques

### 1. Compatibilité des terminaux

> [!warning] Vérification essentielle Tous les terminaux ne supportent pas correctement les caractères Unicode. Toujours tester sur les environnements cibles.

```bash
#!/bin/bash

# Fonction pour tester le support Unicode
check_unicode_support() {
    if [[ "$LANG" != *"UTF-8"* ]] && [[ "$LC_ALL" != *"UTF-8"* ]]; then
        echo "⚠ Avertissement : L'encodage UTF-8 n'est pas configuré"
        echo "Définissez : export LANG=fr_FR.UTF-8"
        return 1
    fi
    
    # Test d'affichage
    echo "Test de rendu : ┌─┐ ╔═╗ ┏━┓ ╭─╮"
    echo "Si vous voyez des caractères corrompus, votre terminal ne supporte pas Unicode."
    return 0
}

check_unicode_support
```

### 2. Gestion de la largeur des caractères

> [!tip] Largeur des caractères Unicode La plupart des caractères Box Drawing ont une largeur de 1 unité, mais certains émojis ou caractères spéciaux peuvent avoir une largeur de 2. Utilisez `wcswidth` ou des fonctions bash pour calculer la largeur réelle.

```bash
#!/bin/bash

# Fonction pour calculer la largeur d'affichage d'une chaîne
get_display_width() {
    local str="$1"
    # Méthode simple : compter les caractères sans les séquences d'échappement
    echo "$str" | sed 's/\x1b\[[0-9;]*m//g' | wc -m
}

# Utilisation pour un alignement précis
align_text() {
    local text="$1"
    local width="$2"
    local current_width=$(get_display_width "$text")
    local padding=$((width - current_width))
    
    if (( padding > 0 )); then
        printf "%s%*s" "$text" $padding ""
    else
        echo "$text"
    fi
}
```

### 3. Performance et optimisation

> [!info] Optimisation des boucles Évitez de redessiner des cadres dans des boucles rapides. Pré-calculez les éléments statiques.

```bash
#!/bin/bash

# ❌ Mauvaise pratique : Redessiner à chaque itération
bad_practice() {
    for i in {1..100}; do
        clear
        echo "┌────────────────┐"
        echo "│ Progression: $i%│"
        echo "└────────────────┘"
        sleep 0.1
    done
}

# ✅ Bonne pratique : Utiliser des séquences d'échappement
good_practice() {
    echo "┌────────────────────┐"
    echo "│ Progression:       │"
    echo "└────────────────────┘"
    
    for i in {1..100}; do
        # Déplacer le curseur et mettre à jour uniquement le nombre
        echo -ne "\033[2;15H$i%"
        sleep 0.1
    done
    echo -e "\n"
}

# good_practice
```

### 4. Variables pour les styles réutilisables

```bash
#!/bin/bash

# Définir des constantes pour les styles
readonly SIMPLE_TL="┌" SIMPLE_TR="┐" SIMPLE_BL="└" SIMPLE_BR="┘"
readonly SIMPLE_H="─" SIMPLE_V="│"

readonly DOUBLE_TL="╔" DOUBLE_TR="╗" DOUBLE_BL="╚" DOUBLE_BR="╝"
readonly DOUBLE_H="═" DOUBLE_V="║"

readonly HEAVY_TL="┏" HEAVY_TR="┓" HEAVY_BL="┗" HEAVY_BR="┛"
readonly HEAVY_H="━" HEAVY_V="┃"

readonly ROUNDED_TL="╭" ROUNDED_TR="╮" ROUNDED_BL="╰" ROUNDED_BR="╯"

# Fonction réutilisable avec style
draw_styled_line() {
    local style="$1"
    local width="$2"
    
    case "$style" in
        "simple") printf "${SIMPLE_H}%.0s" $(seq 1 $width) ;;
        "double") printf "${DOUBLE_H}%.0s" $(seq 1 $width) ;;
        "heavy")  printf "${HEAVY_H}%.0s" $(seq 1 $width) ;;
        *) printf "─%.0s" $(seq 1 $width) ;;
    esac
    echo
}
```

### 5. Gestion des erreurs et fallback

```bash
#!/bin/bash

# Fonction avec fallback ASCII si Unicode échoue
safe_draw_box() {
    local text="$1"
    local use_unicode="${2:-true}"
    
    if [[ "$use_unicode" == "true" ]] && check_unicode_support &>/dev/null; then
        # Version Unicode
        echo "┌────────────────────┐"
        printf "│ %-18s │\n" "$text"
        echo "└────────────────────┘"
    else
        # Fallback ASCII
        echo "+--------------------+"
        printf "| %-18s |\n" "$text"
        echo "+--------------------+"
    fi
}

# Utilisation
safe_draw_box "Mon message" true
```

### 6. Documentation et commentaires

> [!tip] Commentez vos caractères Unicode Les caractères Box Drawing peuvent être difficiles à lire dans le code source. Ajoutez des commentaires descriptifs.

```bash
#!/bin/bash

# Créer un cadre avec en-tête double et corps simple
draw_mixed_frame() {
    # ╔═══╗ Bordure double pour l'en-tête
    echo -n "╔"
    printf '═%.0s' $(seq 1 40)
    echo "╗"
    
    # ║   ║ Parois verticales doubles
    printf "║ %-39s║\n" "EN-TÊTE"
    
    # ╠═══╣ Séparateur mixte
    echo -n "╠"
    printf '═%.0s' $(seq 1 40)
    echo "╣"
    
    # │   │ Parois verticales simples pour le corps
    printf "║ %-39s║\n" "Contenu du message"
    
    # ╚═══╝ Bordure double pour le pied
    echo -n "╚"
    printf '═%.0s' $(seq 1 40)
    echo "╝"
}
```

### 7. Éviter les pièges courants

> [!warning] Pièges fréquents

**Piège 1 : Copier-coller depuis des sources externes**

```bash
# ❌ Les caractères peuvent être corrompus lors du copier-coller
echo "┌──┐"  # Peut devenir : â"Œâ"€â"€â"

# ✅ Utilisez des variables ou des codes Unicode explicites
TL=\u250C'  # ┌
H=\u2500'   # ─
TR=\u2510'  # ┐
echo "${TL}${H}${H}${TR}"
```

**Piège 2 : Oublier les largeurs variables**

```bash
# ❌ Mauvais : assume que tous les caractères ont largeur 1
wrong_padding() {
    local text="📊 Stats"  # L'emoji a largeur 2 !
    printf "│ %-20s │\n" "$text"  # Décalage !
}

# ✅ Correct : calculer la largeur réelle
correct_padding() {
    local text="📊 Stats"
    local visual_width=$(echo -n "$text" | wc -m)
    local padding=$((20 - visual_width))
    printf "│ %s%*s │\n" "$text" $padding ""
}
```

**Piège 3 : Mélanger les styles sans réfléchir**

```bash
# ❌ Incohérent visuellement
echo "╔════════════╗"
echo "│ Message    │"  # Mélange double/simple
echo "╚════════════╝"

# ✅ Cohérent
echo "╔════════════╗"
echo "║ Message    ║"  # Tout en double
echo "╚════════════╝"
```

### 8. Accessibilité et lisibilité

```bash
#!/bin/bash

# Fonction avec option de contraste élevé
draw_accessible_box() {
    local text="$1"
    local high_contrast="${2:-false}"
    
    if [[ "$high_contrast" == "true" ]]; then
        # Utiliser des bordures épaisses pour meilleure visibilité
        echo "┏━━━━━━━━━━━━━━━━━━━━┓"
        printf "┃ %-18s ┃\n" "$text"
        echo "┗━━━━━━━━━━━━━━━━━━━━┛"
    else
        # Bordures standard
        echo "┌────────────────────┐"
        printf "│ %-18s │\n" "$text"
        echo "└────────────────────┘"
    fi
}

# Pour utilisateurs avec déficience visuelle
draw_accessible_box "Message important" true
```

### 9. Tableaux de référence rapide

#### Référence rapide : Coins

|Style|Haut-gauche|Haut-droit|Bas-gauche|Bas-droit|
|:--|:-:|:-:|:-:|:-:|
|Simple|┌ (U+250C)|┐ (U+2510)|└ (U+2514)|┘ (U+2518)|
|Double|╔ (U+2554)|╗ (U+2557)|╚ (U+255A)|╝ (U+255D)|
|Épais|┏ (U+250F)|┓ (U+2513)|┗ (U+2517)|┛ (U+251B)|
|Arrondi|╭ (U+256D)|╮ (U+256E)|╰ (U+2570)|╯ (U+256F)|

#### Référence rapide : Lignes

|Style|Horizontale|Verticale|
|:--|:-:|:-:|
|Simple|─ (U+2500)|│ (U+2502)|
|Double|═ (U+2550)|║ (U+2551)|
|Épais|━ (U+2501)|┃ (U+2503)|

#### Référence rapide : Jonctions

|Type|Simple|Double|Épais|
|:--|:-:|:-:|:-:|
|T-gauche|├ (U+251C)|╠ (U+2560)|┣ (U+2523)|
|T-droite|┤ (U+2524)|╣ (U+2563)|┫ (U+252B)|
|T-haut|┬ (U+252C)|╦ (U+2566)|┳ (U+2533)|
|T-bas|┴ (U+2534)|╩ (U+2569)|┻ (U+253B)|
|Croix|┼ (U+253C)|╬ (U+256C)|╋ (U+254B)|

### 10. Template de fonction complète

```bash
#!/bin/bash

#═══════════════════════════════════════════════════════════════════════════
# Template de fonction de cadre réutilisable et flexible
#═══════════════════════════════════════════════════════════════════════════

draw_universal_box() {
    local -n config=$1  # Référence associative pour configuration
    
    # Paramètres par défaut
    local style="${config[style]:-simple}"
    local width="${config[width]:-50}"
    local title="${config[title]:-}"
    local content="${config[content]:-}"
    local align="${config[align]:-left}"
    local padding="${config[padding]:-1}"
    
    # Sélection des caractères selon le style
    local h v tl tr bl br vr vl dh uh
    case "$style" in
        "simple")  h="─" v="│" tl="┌" tr="┐" bl="└" br="┘" vr="├" vl="┤" dh="┬" uh="┴" ;;
        "double")  h="═" v="║" tl="╔" tr="╗" bl="╚" br="╝" vr="╠" vl="╣" dh="╦" uh="╩" ;;
        "heavy")   h="━" v="┃" tl="┏" tr="┓" bl="┗" br="┛" vr="┣" vl="┫" dh="┳" uh="┻" ;;
        "rounded") h="─" v="│" tl="╭" tr="╮" bl="╰" br="╯" vr="├" vl="┤" dh="┬" uh="┴" ;;
        *) echo "Style invalide: $style" >&2; return 1 ;;
    esac
    
    # Bordure supérieure
    echo -n "$tl"
    printf "${h}%.0s" $(seq 1 $width)
    echo "$tr"
    
    # Titre (si présent)
    if [[ -n "$title" ]]; then
        local title_len=${#title}
        case "$align" in
            "center")
                local pad_left=$(( (width - title_len) / 2 ))
                local pad_right=$(( width - title_len - pad_left ))
                printf "$v%*s%s%*s$v\n" $pad_left "" "$title" $pad_right ""
                ;;
            "right")
                printf "$v%*s%s $v\n" $((width - title_len - 1)) "" "$title"
                ;;
            *)
                printf "$v %s%*s$v\n" "$title" $((width - title_len - 1)) ""
                ;;
        esac
        
        # Séparateur après titre
        echo -n "$vr"
        printf "${h}%.0s" $(seq 1 $width)
        echo "$vl"
    fi
    
    # Contenu
    if [[ -n "$content" ]]; then
        local effective_width=$((width - padding * 2))
        echo "$content" | fold -s -w $effective_width | while IFS= read -r line; do
            printf "$v%*s%-${effective_width}s%*s$v\n" $padding "" "$line" $padding ""
        done
    fi
    
    # Bordure inférieure
    echo -n "$bl"
    printf "${h}%.0s" $(seq 1 $width)
    echo "$br"
}

# Exemple d'utilisation avec configuration
declare -A box_config=(
    [style]="double"
    [width]=60
    [title]="📦 CONFIGURATION SYSTÈME"
    [content]="Serveur : Production-01
IP : 192.168.1.100
Status : Actif
Uptime : 15 jours"
    [align]="center"
    [padding]=2
)

draw_universal_box box_config
```

---

## 🎓 Récapitulatif

### Points clés à retenir

> [!success] Maîtrise des bordures Box Drawing
> 
> 1. **Choisissez le bon style** : Simple pour le quotidien, double pour l'importance, épais pour les alertes, arrondi pour la modernité
> 2. **Maintenez la cohérence** : Ne mélangez pas les styles sans raison visuelle claire
> 3. **Testez la compatibilité** : Vérifiez toujours l'encodage UTF-8 et le support du terminal
> 4. **Optimisez les performances** : Pré-calculez les éléments statiques, évitez les redraws inutiles
> 5. **Documentez votre code** : Les caractères Unicode sont difficiles à lire, commentez-les
> 6. **Prévoyez des fallbacks** : Ayez toujours une version ASCII de secours

### Cas d'usage recommandés

|Style|Usage optimal|Exemples|
|:--|:--|:--|
|**Simple**|Usage quotidien, logs, cadres légers|Notifications, messages info, tableaux standards|
|**Double**|Hiérarchie importante, sections critiques|En-têtes de rapports, boîtes de dialogue, résultats finaux|
|**Épais**|Alertes, titres marquants, warnings|Erreurs critiques, menus principaux, bannières|
|**Arrondi**|Interface moderne, notifications douces|Pop-ups, tooltips, éléments UI contemporains|
|**Pointillé**|Séparation légère, contenu optionnel|Notes, commentaires, sections secondaires|
|**Mixte**|Hiérarchie visuelle complexe|Dashboards, rapports structurés, interfaces multi-niveaux|

---

## 💡 Astuces avancées

### Combiner avec les couleurs

```bash
#!/bin/bash

# Cadre coloré avec bordures
colored_box() {
    local color="$1"  # red, green, blue, yellow
    local text="$2"
    
    case "$color" in
        "red")    local code="31" ;;
        "green")  local code="32" ;;
        "blue")   local code="34" ;;
        "yellow") local code="33" ;;
        *) local code="0" ;;
    esac
    
    echo -e "\e[${code}m┌────────────────────┐\e[0m"
    echo -e "\e[${code}m│\e[0m %-18s \e[${code}m│\e[0m" "$text"
    echo -e "\e[${code}m└────────────────────┘\e[0m"
}

# Usage
colored_box "green" "✓ Succès"
colored_box "red" "✗ Erreur"
```

### Animation de chargement

```bash
#!/bin/bash

loading_box() {
    local text="$1"
    local duration="${2:-5}"
    
    echo "╭────────────────────────────╮"
    printf "│ %-26s │\n" "$text"
    echo "├────────────────────────────┤"
    
    for i in $(seq 0 $duration); do
        local progress=$((i * 100 / duration))
        local filled=$((progress / 4))
        local empty=$((25 - filled))
        
        echo -ne "│ ["
        printf "▓%.0s" $(seq 1 $filled)
        printf "░%.0s" $(seq 1 $empty)
        printf "] %3d%% │\r" $progress
        
        sleep 1
    done
    
    echo -e "\n╰────────────────────────────╯"
}

# loading_box "Chargement en cours" 10
```

### Graphiques en ASCII art

```bash
#!/bin/bash

draw_bar_chart() {
    local -n data=$1
    local max_width=40
    
    # Trouver la valeur maximale
    local max_value=0
    for value in "${data[@]}"; do
        (( value > max_value )) && max_value=$value
    done
    
    echo "┌─────────────────────────────────────────────┐"
    echo "│          GRAPHIQUE EN BARRES                │"
    echo "├─────────────────────────────────────────────┤"
    
    local index=0
    for value in "${data[@]}"; do
        local bar_width=$((value * max_width / max_value))
        printf "│ %2d │" $((++index))
        printf "▓%.0s" $(seq 1 $bar_width)
        printf " %d\n" $value
    done
    
    echo "└─────────────────────────────────────────────┘"
}

# Exemple
declare -a chart_data=(45 78 23 91 67 34 89)
draw_bar_chart chart_data
```

---

**🎉 Vous maîtrisez maintenant les caractères Unicode Box Drawing en Bash !**

Ce cours vous a fourni toutes les bases et techniques avancées pour créer des interfaces textuelles élégantes et professionnelles dans vos scripts shell.