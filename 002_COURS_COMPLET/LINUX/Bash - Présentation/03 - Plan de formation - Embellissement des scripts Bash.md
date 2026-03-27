

📘 PARTIE 1 : Les bases des couleurs en Bash Fichier Obsidian suggéré : `bash-couleurs-bases.md`

**Sujets à couvrir :**

1. Les codes ANSI et séquences d'échappement
    
    - Structure d'une séquence d'échappement (`\e[`, `\033[`, `\x1b[`)
    - Syntaxe de base des codes couleurs
    - Réinitialisation des styles (`\e[0m`)
2. Couleurs et styles de base
    
    - Couleurs de texte standard (30-37) et vives (90-97)
    - Couleurs de fond standard (40-47) et vives (100-107)
    - Combinaison texte + fond
    - Styles (gras, souligné, italique, inverse, barré, clignotant)

---

📘 PARTIE 2 : Organisation et bonnes pratiques Fichier Obsidian suggéré : `bash-couleurs-organisation.md`

**Sujets à couvrir :**

1. Définition de variables pour les couleurs
    
    - Création de variables globales
    - Nomenclature cohérente
    - Variables pour la réinitialisation
2. Fonctions d'affichage coloré
    
    - Fonction pour messages d'erreur
    - Fonction pour messages de succès
    - Fonction pour messages d'avertissement
    - Fonction pour messages d'information
3. Gestion de la compatibilité
    
    - Détection du support des couleurs
    - Variable `TERM`
    - Test avec `tput colors`
    - Mode dégradé sans couleurs

---

📘 PARTIE 3 : Caractères Unicode et bordures Fichier Obsidian suggéré : `bash-unicode-bordures.md`

**Sujets à couvrir :**

1. Encodage et support Unicode
    
    - Configuration UTF-8
    - Variable `LANG` et `LC_ALL`
    - Test de compatibilité Unicode
2. Tous les types de bordures Box Drawing
    
    - Bordures simples (─ │ ┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼)
    - Bordures doubles (═ ║ ╔ ╗ ╚ ╝ ╠ ╣ ╦ ╩ ╬)
    - Bordures épaisses/lourdes (━ ┃ ┏ ┓ ┗ ┛ ┣ ┫ ┳ ┻ ╋)
    - Bordures arrondies (╭ ╮ ╯ ╰)
    - Bordures pointillées/tirets (┄ ┅ ┆ ┇ ┈ ┉ ┊ ┋)
    - Bordures mixtes (simple/double, simple/épais)
    - Création de cadres avec chaque style
3. Autres caractères décoratifs
    
    - Blocs et ombrages (█ ▓ ▒ ░ ▀ ▄ ▌ ▐)
    - Triangles et flèches (▲ ▼ ◄ ► → ← ↑ ↓ ⇒ ⇐)
    - Formes géométriques (● ○ ◆ ◇ ■ □ ▪ ▫)
    - Séparateurs et lignes (― ─ ═ • · ※)

---

📘 PARTIE 4 : Icônes et symboles Fichier Obsidian suggéré : `bash-icones-symboles.md`

**Sujets à couvrir :**

1. Symboles et icônes de statut
    
    - Coches et croix (✓ ✗ ✔ ✘ ☑ ☒)
    - Succès/échec/avertissement (✓ ✗ ⚠ ⛔ ⚡)
    - En cours et attente (⟳ ⌛ ⏳ ⏸ ⏵)
    - Information (ℹ ⓘ ◉)
    - Points et puces (• ◦ ▪ ▫ ▸ ‣)
    - Étoiles (★ ☆ ✦ ✧ ✶)
2. Icônes techniques et emojis
    
    - Fichiers et dossiers (📁 📂 📄 📝 🗂)
    - Réseau et système (🌐 💻 🖥 ⚙ 🔧 🔨)
    - Actions (🔍 🔒 🔓 ⚡ 🔄 ✅ ❌)
    - Support et limites des emojis en terminal
    - Choix entre symboles Unicode et emojis

---

📘 PARTIE 5 : Mise en page et formatage avancé Fichier Obsidian suggéré : `bash-mise-en-page.md`

**Sujets à couvrir :**

1. Positionnement et manipulation du curseur
    
    - Déplacement du curseur (`\e[A`, `\e[B`, `\e[C`, `\e[D`)
    - Positionnement absolu (`\e[ligne;colonneH`)
    - Sauvegarde et restauration de position
    - Effacement de ligne et d'écran
    - Défilement
2. Barres de progression et indicateurs
    
    - Barre simple avec caractères ASCII
    - Barre avec caractères Unicode (█ ▓ ▒ ░)
    - Calcul de pourcentage et affichage dynamique
    - Mise à jour en temps réel sans nouvelle ligne
    - Spinners et animations d'attente (⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
3. Tableaux et structures de données
    
    - Calcul automatique de largeur de colonnes
    - Alignement du contenu (gauche, droite, centré)
    - En-têtes et séparateurs
    - Tableaux multilignes
    - Adaptation à la largeur du terminal

---

📘 PARTIE 6 : Composants réutilisables Fichier Obsidian suggéré : `bash-composants.md`

**Sujets à couvrir :**

1. Boîtes de message
    
    - Fonction de boîte simple
    - Adaptation automatique à la largeur
    - Titres et contenus
    - Styles selon le type de message
2. Menus interactifs
    
    - Liste de choix numérotés
    - Navigation avec flèches (avec `read`)
    - Mise en valeur de la sélection
    - Validation et retour
3. En-têtes et bannières
    
    - Bannière de démarrage de script
    - Informations de version et auteur
    - Cadres décoratifs
    - Séparateurs de sections
4. Indicateurs de chargement
    
    - Spinner rotatif
    - Points d'attente animés
    - Messages de progression
    - Gestion du timing

---

📘 PARTIE 7 : Outils et bibliothèques Fichier Obsidian suggéré : `bash-outils-bibliotheques.md`

**Sujets à couvrir :**

1. `tput` - Manipulation du terminal
    
    - Commandes principales (`setaf`, `setab`, `bold`, `sgr0`)
    - Avantages par rapport aux codes ANSI bruts
    - Portabilité entre terminaux
    - Obtention d'informations (`cols`, `lines`)
2. `figlet` et `toilet` - ASCII art
    
    - Installation et utilisation de base
    - Polices disponibles
    - Options de formatage
    - Combinaison avec couleurs
3. Bibliothèques Bash tierces
    
    - bashcolors / bash-colors
    - pretty-print functions
    - Intégration dans vos scripts
4. Générateurs en ligne
    
    - Générateurs de bannières ASCII
    - Tables de caractères Unicode
    - Prévisualisation de couleurs ANSI

---

📘 PARTIE 8 : Cas pratiques et optimisation Fichier Obsidian suggéré : `bash-cas-pratiques.md`

**Sujets à couvrir :**

1. Script de monitoring système
    
    - Affichage coloré des statuts
    - Tableaux de métriques
    - Alertes visuelles
    - Rafraîchissement périodique
2. Script d'installation/configuration
    
    - Étapes visuelles claires
    - Progression avec indicateurs
    - Gestion des erreurs visuelles
    - Résumé final formaté
3. Logs colorés et lisibles
    
    - Catégorisation par couleur
    - Timestamps formatés
    - Niveaux de verbosité
    - Filtrage visuel
4. Performance et bonnes pratiques
    
    - Éviter les appels répétitifs
    - Mise en cache des séquences
    - Impact sur la lisibilité
    - Quand ne PAS embellir
    - Respect de `--no-color` / options de désactivation