

---

📘 PARTIE 1 : Affichage et formatage en terminal Fichier Obsidian suggéré : `bash-affichage-terminal.md`

**Sujets à couvrir :**

1. Codes ANSI et couleurs
    
    - Syntaxe des codes ANSI (\033[XXm ou \e[XXm)
    - Couleurs de texte (30-37, 90-97)
    - Couleurs de fond (40-47, 100-107)
    - Attributs (gras, souligné, clignotant, inversé)
    - Réinitialisation avec \033[0m
2. Caractères Unicode et bordures
    
    - Table des caractères de bordure (simple, double, arrondi)
    - Symboles utiles (flèches, puces, icônes)
    - Configuration UTF-8 (LANG, LC_ALL)
    - Compatibilité entre terminaux
3. Formatage de texte
    
    - printf pour alignement et padding
    - Calcul de largeur du terminal avec tput cols
    - Centrage de texte
    - Colonnes avec column -t
    - Troncature de texte
4. Manipulation du terminal avec tput
    
    - tput clear pour effacer l'écran
    - tput cup pour positionner le curseur
    - tput civis/cnorm pour masquer/afficher curseur
    - tput cols/lines pour dimensions
    - Sauvegarde et restauration de position

---

📘 PARTIE 2 : Construction de menus interactifs Fichier Obsidian suggéré : `bash-menus-interactifs.md`

**Sujets à couvrir :**

1. Menus basiques avec select
    
    - Structure de base avec select
    - Personnalisation de PS3
    - Gestion des choix
    - Boucles et sorties
2. Menus personnalisés avec read
    
    - Fonction pour dessiner des bordures
    - Affichage de titres encadrés
    - Liste d'options formatée
    - Validation de saisie
3. Menus avec navigation au clavier
    
    - read avec -n1 -s pour lecture silencieuse
    - Détection des touches spéciales (flèches, Entrée, Échap)
    - Codes des touches fléchées
    - Surlignage de l'option active
    - Boucle de navigation
4. Éléments visuels avancés
    
    - Barres de progression manuelles
    - Spinners et animations
    - Indicateurs de statut (✓, ✗, ⚠)
    - Messages avec timestamps
    - Tableaux ASCII

---

📘 PARTIE 3 : Outils d'interface TUI Fichier Obsidian suggéré : `bash-outils-tui.md`

**Sujets à couvrir :**

1. dialog - Boîtes de dialogue
    
    - Installation et vérification
    - --msgbox pour messages
    - --yesno pour confirmations
    - --inputbox pour saisie
    - --menu pour menus
    - --checklist et --radiolist
    - Capture des valeurs de retour
2. whiptail - Alternative à dialog
    
    - Différences avec dialog
    - Syntaxe de base
    - Boîtes similaires à dialog
    - --gauge pour barres de progression
    - Redirection et capture
3. zenity - Interfaces graphiques simples
    
    - Disponibilité sur systèmes avec X11
    - --info, --warning, --error
    - --entry pour saisie
    - --file-selection
    - --progress avec pourcentage
    - --list pour listes
4. Autres outils TUI
    
    - fzf pour sélection floue
    - rofi pour menus
    - gum pour interfaces modernes
    - Intégration dans les scripts

---

📘 PARTIE 4 : Organisation et structure du code Fichier Obsidian suggéré : `bash-structure-code.md`

**Sujets à couvrir :**

1. Fonctions réutilisables
    
    - Déclaration de fonctions
    - Paramètres positionnels ($1, $2...)
    - Variables locales avec local
    - Valeurs de retour et exit codes
    - Bibliothèques de fonctions d'affichage
2. Sourcing et modules
    
    - source ou . pour inclure fichiers
    - Organisation en fichiers séparés
    - Chemin relatif vs absolu
    - dirname et basename
    - Structure de répertoires
3. Fichiers de configuration
    
    - Format de fichiers .conf
    - Parsing de fichiers clé=valeur
    - Fichiers .env
    - Variables d'environnement
    - Thèmes de couleurs externalisés
4. Gestion des erreurs et logs
    
    - set -e et set -u
    - trap pour gérer les erreurs
    - Fonctions de logging (info, warn, error)
    - Redirection vers fichiers de log
    - Rotation de logs
    - Codes de sortie standardisés

---

📘 PARTIE 5 : Techniques avancées Fichier Obsidian suggéré : `bash-techniques-avancees.md`

**Sujets à couvrir :**

1. Performance et optimisation
    
    - Éviter les commandes externes inutiles
    - Substitution de commandes $() vs ``
    - Here documents et here strings
    - Buffering de sortie
    - Arrays pour stocker données
2. Responsive design terminal
    
    - Détection de la taille avec $COLUMNS et $LINES
    - Réaction au signal SIGWINCH
    - Adaptation dynamique du layout
    - Breakpoints pour différentes largeurs
    - Mode dégradé pour petits terminaux
3. Compatibilité multi-systèmes
    
    - Détection du système (uname)
    - Différences GNU vs BSD
    - Commandes alternatives selon OS
    - Vérification des dépendances
    - Fallback si outils manquants
4. Internationalisation et accessibilité
    
    - Variables LANG et LC_*
    - Fichiers de traduction
    - gettext pour i18n
    - Mode sans couleurs (NO_COLOR)
    - Support lecteurs d'écran
    - Alternatives textuelles aux symboles

---

📘 PARTIE 6 : Distribution et déploiement Fichier Obsidian suggéré : `bash-distribution.md`

**Sujets à couvrir :**

1. Scripts portables
    
    - Shebang approprié (#!/usr/bin/env bash)
    - Vérification de la version Bash
    - Gestion des dépendances
    - Tests de compatibilité
    - Documentation des prérequis
2. Installation et configuration
    
    - Scripts d'installation
    - Ajout au PATH
    - Création de liens symboliques
    - Installation système vs utilisateur
    - Désinstallation propre
3. Packaging
    
    - Création de .deb (Debian/Ubuntu)
    - Création de .rpm (RedHat/Fedora)
    - Archives tar.gz avec install.sh
    - Makefiles simples
    - Gestion des permissions
4. Documentation et aide
    
    - Pages man personnalisées
    - --help et -h intégrés
    - README complet
    - Exemples d'utilisation
    - Changelog et versioning