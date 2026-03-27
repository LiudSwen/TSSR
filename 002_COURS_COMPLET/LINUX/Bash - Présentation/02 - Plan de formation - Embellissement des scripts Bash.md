

📘 PARTIE 1 : Couleurs, Unicode et formatage de base Fichier Obsidian suggéré : `01-bases-formatage-bash.md`

**Sujets à couvrir :**

1. Les codes ANSI et séquences d'échappement
    
    - Structure des codes ANSI (`\e[`, `\033[`, `\x1b[`)
    - Syntaxe des séquences de couleur
    - Codes de réinitialisation
2. Couleurs de texte et de fond
    
    - Les 8 couleurs de base (30-37 pour texte, 40-47 pour fond)
    - Les couleurs brillantes/lumineuses (90-97, 100-107)
    - Couleurs 256 couleurs (`38;5;N`, `48;5;N`)
    - Couleurs RGB/True Color (`38;2;R;G;B`, `48;2;R;G;B`)
3. Styles de texte
    
    - Gras, souligné, italique
    - Inversé, barré, clignotant
    - Combinaison de styles et couleurs
4. Caractères Unicode
    
    - Encodage UTF-8 et vérification du support
    - Configuration locale (LANG, LC_ALL)
    - Box Drawing simple (─│┌┐└┘├┤┬┴┼)
    - Box Drawing double (═║╔╗╚╝╠╣╦╩╬)
    - Box Drawing mixte (simple + double)
    - Coins arrondis (╭╮╰╯)
    - Lignes épaisses et fines
    - Symboles de statut (✓ ✗ ⚠ ℹ ⚙ ⏳ ⚡)
    - Flèches (→ ← ↑ ↓ ↔ ⇒ ⇐ ▶ ◀ ▲ ▼)
    - Formes géométriques (■ □ ● ○ ◆ ◇ ▪ ▫)
    - Symboles de progression (▏▎▍▌▋▊▉█ ░▒▓█)
    - Symboles mathématiques et autres (± × ÷ ≈ ≠ ≤ ≥ π ∞)
    - Test de compatibilité du terminal
5. Contrôle du curseur et de l'affichage
    
    - Déplacement du curseur (haut, bas, gauche, droite)
    - Positionnement absolu du curseur (`\e[y;xH` et `\e[y;xf`)
    - Sauvegarde et restauration de position (`\e[s` et `\e[u`)
    - Affichage et masquage du curseur (`\e[?25h` et `\e[?25l`)
    - Effacement de l'écran complet (`clear`, `\e[2J`)
    - Effacement de ligne (complète, jusqu'à la fin, jusqu'au début)
    - Effacement du curseur à la fin de l'écran
    - Défilement de la fenêtre (scroll up/down)
    - Commandes tput pour portabilité
6. Bonnes pratiques et compatibilité
    
    - Vérification du support des couleurs (`tput colors`)
    - Test du support Unicode
    - Variables globales pour les codes couleur
    - Constantes pour les caractères Unicode
    - Fonctions wrapper pour la portabilité
    - Option --no-color pour désactiver les couleurs
    - Détection du type de terminal (TERM)
    - Compatibilité bash vs sh
    - Gestion des terminaux non-interactifs
    - Reset complet à la fin du script

---

📘 PARTIE 2 : Mise en page et présentation des scripts Fichier Obsidian suggéré : `02-mise-en-page-presentation.md`

**Sujets à couvrir :**

1. Fonctions de dessin et encadrement
    
    - Fonction pour créer un cadre simple (single box)
    - Fonction pour créer un cadre double (double box)
    - Fonction pour créer un cadre avec coins arrondis
    - Fonction pour encadrer du texte (titre centré)
    - Fonction pour encadrer du texte multi-lignes
    - Gestion de la largeur dynamique (adaptation au contenu)
    - Gestion de la largeur fixe avec padding
    - Bordures avec titre intégré dans la bordure supérieure
    - Fonction pour créer des panneaux (panels)
2. Centrage et alignement
    
    - Calcul de la largeur du terminal (`tput cols`, `$COLUMNS`)
    - Calcul de la hauteur du terminal (`tput lines`)
    - Fonction de centrage horizontal
    - Fonction de centrage vertical
    - Alignement à droite
    - Alignement à gauche avec padding
    - Fonction de padding dynamique
    - Espacement vertical (lignes vides)
    - Gestion du texte trop long (truncate, wrap)
3. En-têtes et séparateurs
    
    - Création de banners (ASCII art)
    - Banners avec figlet/toilet (si disponible)
    - Lignes de séparation simples (─────)
    - Lignes de séparation décoratives avec symboles
    - Titres encadrés (avec bordures)
    - Titres avec soulignement
    - Sections avec icônes et numérotation
    - Headers avec informations système (date, heure, user)
    - Footers de fin de script
4. Barres de progression
    
    - Barre de progression simple avec caractères ASCII ([#### ])
    - Barre de progression avec caractères Unicode (█▓▒░)
    - Barre de progression avec blocs partiels (▏▎▍▌▋▊▉█)
    - Barre avec pourcentage affiché
    - Barre avec compteur (X/Y)
    - Spinner/roue de chargement (⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏)
    - Animation de progression en temps réel
    - Barre de progression avec temps estimé
    - Multi-barres de progression
    - Fonction réutilisable de progression
5. Messages et notifications
    
    - Messages d'information avec icône (ℹ)
    - Messages de succès avec icône (✓)
    - Messages d'avertissement avec icône (⚠)
    - Messages d'erreur avec icône (✗)
    - Messages de debug avec icône
    - Boîtes de message encadrées simples
    - Boîtes de message encadrées doubles
    - Messages avec retour à la ligne automatique (word wrap)
    - Messages multi-paragraphes
    - Logs formatés avec horodatage
    - Niveaux de log colorés (INFO, WARN, ERROR, DEBUG, TRACE)
    - Fonction de logging dans fichier + stdout
    - Verbosité configurable (quiet, normal, verbose)
6. Prompts interactifs stylisés
    
    - Demandes de confirmation (Oui/Non, Y/N)
    - Demandes avec valeur par défaut
    - Saisie utilisateur avec prompt coloré
    - Saisie de mot de passe (masqué)
    - Validation des entrées (regex, type)
    - Boucle de ressaisie en cas d'erreur
    - Menu de sélection simple en mode texte (numéroté)
    - Menu avec navigation par touches
    - Sélection multiple (checkbox style texte)
    - Indicateurs visuels de sélection (▶, •)
    - Timeout sur les prompts
    - Validation avec feedback visuel immédiat

---

📘 PARTIE 3 : Interface TUI avec Whiptail Fichier Obsidian suggéré : `03-interface-whiptail.md`

**Sujets à couvrir :**

1. Introduction à Whiptail
    
    - Présentation et cas d'usage
    - Installation et vérification de disponibilité
    - Avantages et limitations
    - Compatibilité et portabilité
2. Syntaxe et options de base
    
    - Structure d'une commande Whiptail
    - Options communes (--title, --backtitle)
    - Gestion de la hauteur et largeur
    - Codes de retour et gestion des erreurs
3. Boîtes de dialogue informatives
    
    - Message box (--msgbox)
    - Info box (--infobox)
    - Différences entre msgbox et infobox
    - Cas d'usage et exemples
4. Boîtes de dialogue interactives
    
    - Yes/No box (--yesno)
    - Input box (--inputbox)
    - Password box (--passwordbox)
    - Récupération et validation des valeurs
5. Menus et listes de sélection
    
    - Menu simple (--menu)
    - Radio list (--radiolist)
    - Check list (--checklist)
    - Construction dynamique de menus
    - Gestion des sélections multiples
6. Widgets avancés
    
    - Gauge (--gauge) pour les barres de progression
    - Mise à jour dynamique du gauge
    - Text box (--textbox) pour afficher des fichiers
    - Paramètres de scroll et navigation
7. Techniques avancées avec Whiptail
    
    - Chaînage de dialogues
    - Validation et boucles de saisie
    - Gestion des annulations
    - Adaptation responsive de la taille

---

📘 PARTIE 4 : Interface TUI avec Dialog Fichier Obsidian suggéré : `04-interface-dialog.md`

**Sujets à couvrir :**

1. Introduction à Dialog
    
    - Présentation et historique
    - Différences avec Whiptail
    - Installation et vérification
    - Quand choisir Dialog plutôt que Whiptail
2. Configuration et personnalisation
    
    - Fichier de configuration (.dialogrc)
    - Variables d'environnement Dialog
    - Options globales de comportement
    - Paramètres par défaut
3. Syntaxe et options de base
    
    - Structure d'une commande Dialog
    - Options communes (--title, --backtitle, --colors)
    - Gestion de la hauteur et largeur (auto-sizing)
    - Codes de retour et gestion des erreurs
4. Widgets de dialogue de base
    
    - Message box (--msgbox)
    - Info box (--infobox)
    - Yes/No box (--yesno et --defaultno)
    - Pause box (--pause)
5. Widgets de saisie utilisateur
    
    - Input box (--inputbox)
    - Password box (--passwordbox)
    - Text box (--textbox)
    - Edit box (--editbox)
    - Différences entre textbox et editbox
6. Widgets de sélection
    
    - Menu (--menu)
    - Radio list (--radiolist)
    - Check list (--checklist)
    - Build list (--buildlist)
    - Tree view (--treeview)
7. Formulaires et saisie complexe
    
    - Form (--form) pour formulaires multi-champs
    - Password form (--passwordform)
    - Mixed form (--mixedform)
    - Configuration des champs et validation
8. Widgets de progression et suivi
    
    - Gauge (--gauge)
    - Mixed gauge (--mixedgauge)
    - Progress box (--progressbox)
    - Tail box (--tailbox et --tailboxbg)
    - Programmation box (--programbox)
9. Widgets de sélection avancés
    
    - Calendar (--calendar)
    - Time box (--timebox)
    - File selection (--fselect)
    - Directory selection (--dselect)
10. Personnalisation visuelle
    
    - Couleurs personnalisées (codes ANSI dans --colors)
    - Thèmes et schémas de couleurs
    - Boutons personnalisés (--ok-label, --cancel-label, etc.)
    - Largeur des boutons et espacement
11. Options avancées et astuces
    
    - Navigation par touches et raccourcis
    - Aide contextuelle (--help-button)
    - Extra button (--extra-button)
    - Mode sans ombre (--no-shadow)
    - ASCII lines pour compatibilité
    - Mode batch et scripting automatisé

---

📘 PARTIE 5 : Interface graphique avec Zenity Fichier Obsidian suggéré : `05-interface-zenity.md`

**Sujets à couvrir :**

1. Introduction à Zenity
    
    - Présentation et philosophie GTK
    - Installation et prérequis (environnement graphique)
    - Avantages de l'interface graphique
    - Cas d'usage et limitations
    - Différences fondamentales avec Whiptail/Dialog
2. Options communes et syntaxe de base
    
    - Structure d'une commande Zenity
    - Options générales (--title, --width, --height)
    - Window icon et modal
    - Timeout et auto-close
    - Codes de retour
3. Dialogues d'information et de notification
    
    - Info (--info)
    - Warning (--warning)
    - Error (--error)
    - Question (--question)
    - Notification système (--notification)
4. Saisie utilisateur simple
    
    - Entry (--entry) pour saisie simple
    - Entry avec masquage (--hide-text) pour mots de passe
    - Entry avec texte par défaut
    - Validation des entrées
5. Formulaires complexes
    
    - Forms (--forms) pour multi-champs
    - Ajout de champs (--add-entry, --add-password, --add-calendar)
    - Séparateurs de colonnes
    - Récupération et parsing des données
6. Widgets de sélection de valeurs
    
    - Scale (--scale) pour sélecteur numérique
    - Configuration min, max, step, value
    - Affichage de la valeur
    - Utilisation pour pourcentages et niveaux
7. Sélection de fichiers et dossiers
    
    - File selection (--file-selection) pour fichiers
    - Mode save (--save) pour enregistrement
    - Mode multiple (--multiple) pour sélection multiple
    - Directory mode (--directory) pour dossiers
    - Filtres de fichiers (--file-filter)
    - Séparateur pour sélections multiples
8. Sélection de dates et couleurs
    
    - Calendar (--calendar) pour sélection de date
    - Format de date et configuration
    - Day, month, year par défaut
    - Color selection (--color-selection) pour couleurs
    - Affichage des couleurs sélectionnées
    - Format hexadécimal
9. Listes et tableaux
    
    - List (--list) pour affichage de données
    - Configuration des colonnes (--column)
    - Types de colonnes (text, numeric, image)
    - Mode radiolist et checklist
    - Éditable lists
    - Séparateur de colonnes et parsing
10. Barres de progression
    
    - Progress (--progress) de base
    - Mise à jour via pipe ou stdin
    - Pulsate mode pour progression indéterminée
    - Auto-close et no-cancel
    - Pourcentage et texte de progression
    - Time remaining
11. Affichage de texte
    
    - Text info (--text-info) pour fichiers texte
    - Mode éditable (--editable)
    - Checkbox de confirmation
    - Font selection pour typographie
    - HTML mode si supporté
12. Options avancées et intégration
    
    - Timeout automatique
    - Attach to parent window
    - Display et screen selection
    - Icônes personnalisées
    - Combinaison de plusieurs dialogues
    - Intégration dans des environnements de bureau
    - Gestion des thèmes GTK

---

📘 PARTIE 6 : Bibliothèque de fonctions et projet pratique Fichier Obsidian suggéré : `06-bibliotheque-et-projet.md`

**Sujets à couvrir :**

1. Architecture d'une bibliothèque de fonctions
    
    - Organisation en fichier séparé
    - Sourcing et chargement dans les scripts
    - Documentation interne (commentaires)
    - Namespace et conventions de nommage
    - Versioning de la bibliothèque
2. Fonctions de base réutilisables
    
    - Fonctions de couleurs (print_success, print_error, etc.)
    - Fonctions de dessin (draw_box, draw_line, etc.)
    - Fonctions de centrage et alignement
    - Fonction de logging avec niveaux
    - Fonction de formatage de timestamp
3. Détection et abstraction des TUI
    
    - Fonction de détection d'outils disponibles
    - Ordre de priorité (Zenity > Dialog > Whiptail > Texte)
    - Fonction de fallback automatique
    - Variables globales pour l'outil sélectionné
4. Wrappers universels pour dialogues
    
    - Wrapper pour msgbox/info
    - Wrapper pour yesno/question
    - Wrapper pour input/entry
    - Wrapper pour menu/list
    - Wrapper pour progress/gauge
    - Gestion des différences de syntaxe
5. Gestion des erreurs et compatibilité
    
    - Vérification des dépendances au démarrage
    - Messages d'erreur cohérents et clairs
    - Mode debug et verbose
    - Logging des erreurs
    - Gestion des signaux (trap EXIT, INT, TERM)
6. Structure d'un script professionnel
    
    - Shebang et options set (set -euo pipefail)
    - Variables globales et configuration
    - Constantes et chemins
    - Sourcing de la bibliothèque
    - Organisation du code en fonctions
    - Fonction main() et point d'entrée
7. Projet : Menu principal interactif
    
    - Détection automatique du meilleur TUI
    - Menu principal avec plusieurs options
    - Navigation entre sections
    - Breadcrumb et retour arrière
    - Option de sortie avec confirmation
8. Projet : Formulaire de configuration
    
    - Collecte d'informations utilisateur (nom, email, etc.)
    - Validation des entrées (regex, longueur, format)
    - Messages d'erreur contextuels
    - Récapitulatif des informations
    - Confirmation avant enregistrement
    - Sauvegarde dans un fichier de config
9. Projet : Script d'installation avec feedback
    
    - Liste des étapes d'installation
    - Affichage de progression en temps réel
    - Logs détaillés des opérations
    - Gestion des erreurs et rollback
    - Messages de succès/échec par étape
    - Résumé final avec statistiques
10. Bonnes pratiques finales
    
    - Tests de compatibilité multi-environnements
    - Documentation utilisateur (--help)
    - Portabilité du code (bash vs sh)
    - Performance et optimisation
    - Maintenance et évolutivité
    - Exemples d'utilisation dans le script