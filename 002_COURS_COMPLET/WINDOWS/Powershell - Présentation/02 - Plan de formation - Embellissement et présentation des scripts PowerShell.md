

---

📘 PARTIE 1 : Affichage console - Bases Fichier Obsidian suggéré : `powershell-affichage-console-bases.md`

**Sujets à couvrir :**

1. Gestion des couleurs
    - Write-Host et ses paramètres -ForegroundColor / -BackgroundColor
    - Les 16 couleurs de base
    - $Host.UI.RawUI pour personnalisation avancée
    - Réinitialisation des couleurs
2. Styles et emphases textuelles
    - Séquences ANSI pour texte gras, souligné, italique (PowerShell 7+)
    - Support des émojis en console
    - Texte clignotant pour alertes critiques
    - Compatibilité entre versions PowerShell
3. Boîtes et encadrements
    - Fonction Write-Box personnalisée
    - Boîtes avec titre
    - Boîtes multi-lignes
    - Largeur automatique vs fixe
    - Styles prédéfinis (info, warning, error, success)
4. Bannières et headers
    - Bannières ASCII art
    - Générateurs de titres stylisés
    - Séparateurs décoratifs
    - En-têtes de scripts professionnels

---

📘 PARTIE 2 : Affichage console - Avancé Fichier Obsidian suggéré : `powershell-affichage-console-avance.md`

**Sujets à couvrir :**

1. Caractères Unicode et bordures
    - Table des caractères de bordure (simple, double, arrondi)
    - Symboles utiles (flèches, puces, icônes)
    - Encodage et [Console]::OutputEncoding
    - Compatibilité avec différents terminaux
2. Formatage de texte
    - Alignement (gauche, droite, centré)
    - Padding et espacement
    - String.PadLeft() / PadRight()
    - Largeur de la console ($Host.UI.RawUI.WindowSize.Width)
3. Effacement et positionnement
    - Clear-Host
    - Positionnement du curseur avec [Console]::SetCursorPosition()
    - Effacement de lignes spécifiques
    - Sauvegarde et restauration de position
4. Tableaux et listes formatés
    - Format-Table personnalisé
    - Création de tableaux ASCII
    - Colonnes alignées
    - En-têtes stylisés

---

📘 PARTIE 3 : Menus interactifs - Bases Fichier Obsidian suggéré : `powershell-menus-interactifs-bases.md`

**Sujets à couvrir :**

1. Menus basiques structurés
    - Fonctions pour dessiner des bordures
    - Affichage de titres encadrés
    - Liste d'options formatée
    - Gestion de la saisie utilisateur
2. Saisie utilisateur améliorée
    - Read-Host avec validation
    - Masquage de mot de passe (Read-Host -AsSecureString)
    - Saisie avec valeur par défaut
    - Validation de format (email, numérique, etc.)
    - Timeout sur les saisies
3. Éléments visuels avancés
    - Barres de progression avec Write-Progress
    - Indicateurs de statut (✓, ✗, ⚠)
    - Animations simples (spinner, dots)
    - Messages de confirmation stylisés
4. Formulaires en console
    - Champs multiples
    - Validation en temps réel
    - Résumé avant validation
    - Annulation et modification

---

📘 PARTIE 4 : Menus interactifs - Avancé Fichier Obsidian suggéré : `powershell-menus-interactifs-avance.md`

**Sujets à couvrir :**

1. Navigation au clavier
    - $Host.UI.RawUI.ReadKey()
    - Détection des touches fléchées
    - Surlignage de l'option sélectionnée
    - Boucle de navigation
2. Menus multi-niveaux
    - Sous-menus imbriqués
    - Breadcrumb (fil d'Ariane)
    - Navigation Retour/Quitter
    - État global du menu
    - Historique de navigation
3. Sélection multiple en console
    - Cases à cocher simulées
    - Sélection avec barre d'espace
    - Affichage des éléments sélectionnés
    - Validation de la sélection multiple
4. Interactivité avancée
    - Raccourcis clavier personnalisés
    - Help contextuelle (touche F1)
    - Auto-complétion personnalisée
    - Recherche dans les menus

---

📘 PARTIE 5 : Organisation du code - Structure Fichier Obsidian suggéré : `powershell-organisation-code-structure.md`

**Sujets à couvrir :**

1. Fonctions réutilisables
    - Créer des fonctions d'affichage
    - Comment bien nommer ses fonctions
    - Documentation avec comment-based help
    - Return vs Write-Output
2. Paramètres avancés
    - param() block détaillé
    - Paramètres obligatoires vs optionnels
    - Validation des paramètres ([ValidateSet], [ValidateRange], [ValidatePattern])
    - Paramètres par switch
    - Valeurs par défaut
    - Help automatique avec Get-Help
3. Variables et scope
    - Variables globales vs locales
    - Variables de script ($script:)
    - Variables d'environnement
    - Constantes avec Set-Variable -Option ReadOnly
    - Enum pour valeurs prédéfinies
4. Modules personnels
    - Structure d'un module (.psm1)
    - Manifeste de module (.psd1)
    - Export-ModuleMember
    - Import et utilisation
    - Versioning de modules

---

📘 PARTIE 6 : Organisation du code - Qualité Fichier Obsidian suggéré : `powershell-organisation-code-qualite.md`

**Sujets à couvrir :**

1. Gestion des erreurs propre
    - Try/Catch/Finally avec affichage personnalisé
    - Messages d'erreur formatés
    - $ErrorActionPreference
    - Throw vs Write-Error
    - ErrorRecord et propriétés
2. Logging et débogage
    - Système de logs structuré
    - Niveaux de log (Debug, Info, Warning, Error)
    - Rotation des logs
    - Write-Verbose et Write-Debug
    - Transcription de session (Start-Transcript)
    - Horodatage et formatage
3. Fichiers de configuration
    - Séparation des paramètres visuels
    - Import de fichiers .psd1
    - Hashtables de configuration
    - Thèmes personnalisables
    - Variables de configuration centralisées
4. Patterns de conception
    - Pattern Builder (construction d'objets complexes)
    - Pattern Factory (création d'objets)
    - Séparation des responsabilités
    - DRY (Don't Repeat Yourself)

---

📘 PARTIE 7 : WinForms - Introduction Fichier Obsidian suggéré : `powershell-winforms-introduction.md`

**Sujets à couvrir :**

1. Console vs GUI
    - Quand utiliser une interface console
    - Quand utiliser une interface graphique
    - Avantages et inconvénients de chaque approche
    - Cas d'usage typiques
2. Introduction à Windows Forms
    - Add-Type pour charger System.Windows.Forms et System.Drawing
    - Architecture WinForms
    - Cycle de vie d'une application GUI
    - Thread principal et événements
3. Première fenêtre basique
    - Création d'un objet Form
    - Propriétés essentielles (Text, Size, StartPosition)
    - ShowDialog() vs Show()
    - Fermeture et retour de valeur
4. Layout et positionnement
    - Positionnement absolu (Location, Size)
    - Anchor (ancrage aux bords)
    - Dock (remplissage)
    - FlowLayoutPanel
    - TableLayoutPanel

---

📘 PARTIE 8 : WinForms - Composants de base Fichier Obsidian suggéré : `powershell-winforms-composants-base.md`

**Sujets à couvrir :**

1. Propriétés de la fenêtre
    - Icône personnalisée
    - Taille minimale/maximale
    - Bordures et style
    - Position à l'écran
    - Topmost et autres options
2. Button (Bouton)
    - Création et positionnement
    - Text, Size, Location
    - Événement Click
    - Boutons par défaut (AcceptButton, CancelButton)
    - Images sur boutons
3. Label (Étiquette)
    - Affichage de texte
    - AutoSize vs taille fixe
    - Alignement du texte
    - Police et couleurs
    - Label multi-lignes
4. TextBox (Zone de texte)
    - Saisie simple ligne
    - Multiline et ScrollBars
    - PasswordChar pour mots de passe
    - Événements TextChanged, KeyPress
    - MaxLength et validation
5. Validation et accessibilité
    - Tab order (TabIndex)
    - Validation de formulaires
    - Focus automatique
    - Tooltips (ToolTip component)
    - Shortcuts clavier (& dans le texte)

---

📘 PARTIE 9 : WinForms - Listes et sélections Fichier Obsidian suggéré : `powershell-winforms-listes-selections.md`

**Sujets à couvrir :**

1. ListBox
    - Création et ajout d'éléments
    - Modes de sélection (Single, MultiSimple, MultiExtended)
    - SelectedItem et SelectedItems
    - SelectedIndex et SelectedIndices
    - Événements SelectedIndexChanged
    - Tri et manipulation
2. ComboBox
    - Création et ajout d'éléments
    - Styles (DropDown, DropDownList, Simple)
    - AutoCompleteMode et AutoCompleteSource
    - SelectedItem vs Text
    - Événements SelectedIndexChanged et TextChanged
3. CheckBox
    - Création et positionnement
    - Propriété Checked
    - ThreeState et CheckState
    - Événement CheckedChanged
    - Apparence (Normal vs Button)
4. RadioButton
    - Création et groupement
    - GroupBox pour organisation visuelle
    - Panel pour groupes multiples
    - Propriété Checked
    - Événement CheckedChanged
    - Sélection par défaut
5. CheckedListBox
    - Combinaison ListBox + CheckBox
    - CheckOnClick
    - GetItemChecked() et SetItemChecked()
    - CheckedItems vs Items
6. GroupBox et Panel
    - Regroupement visuel de contrôles
    - Différences GroupBox vs Panel
    - Bordures et titres
    - Utilisation pour RadioButton

---

📘 PARTIE 10 : WinForms - Affichage de données Fichier Obsidian suggéré : `powershell-winforms-affichage-donnees.md`

**Sujets à couvrir :**

1. DataGridView - Configuration de base
    - Chargement de données (DataSource)
    - Colonnes automatiques vs manuelles
    - AutoSizeColumnsMode
    - SelectionMode (FullRowSelect, CellSelect)
    - ReadOnly et AllowUserToAddRows
2. DataGridView - Manipulation avancée
    - Personnalisation des colonnes (HeaderText, Width, Visible)
    - Style des cellules (couleurs, format)
    - Tri et filtrage
    - Ajout et suppression de lignes
    - Événements (CellClick, CellValueChanged, SelectionChanged)
    - Export vers CSV
3. TreeView
    - Création d'arborescence
    - TreeNode et Nodes
    - Ajout de nœuds enfants
    - Expansion et collapse
    - SelectedNode
    - Événements (AfterSelect, BeforeExpand)
    - Images dans les nœuds
4. ListView
    - Modes d'affichage (Details, List, LargeIcon, SmallIcon)
    - Colonnes en mode Details
    - ListViewItem et SubItems
    - Sélection et CheckBoxes
    - Tri par colonnes
    - Événements ItemSelectionChanged
5. PictureBox
    - Affichage d'images
    - SizeMode (Normal, StretchImage, Zoom, CenterImage)
    - Chargement depuis fichier
    - Chargement depuis ressources
    - Image vs BackgroundImage

---

📘 PARTIE 11 : WinForms - Contrôles avancés Fichier Obsidian suggéré : `powershell-winforms-controles-avances.md`

**Sujets à couvrir :**

1. ProgressBar
    - Création et propriétés (Minimum, Maximum, Value)
    - Styles (Blocks, Continuous, Marquee)
    - Mise à jour dans une boucle
    - Refresh() et DoEvents()
    - PerformStep()
2. StatusStrip
    - Création et positionnement (Dock Bottom)
    - ToolStripStatusLabel
    - ToolStripProgressBar
    - Alignement et Spring
    - Séparateurs (ToolStripSeparator)
    - Mise à jour dynamique
3. MenuStrip et ToolStrip
    - MenuStrip pour barre de menus
    - ToolStripMenuItem et sous-menus
    - Shortcuts (ShortcutKeys)
    - ToolStrip pour barre d'outils
    - ToolStripButton et ToolStripComboBox
    - Images dans les menus et barres d'outils
4. TabControl
    - Création d'onglets
    - TabPage et ajout de contrôles
    - SelectedTab et SelectedIndex
    - Événement SelectedIndexChanged
    - Apparence et position des onglets
5. NotifyIcon
    - Icône dans la zone de notification
    - ContextMenuStrip pour menu contextuel
    - BalloonTip pour notifications
    - Événements (Click, DoubleClick)
    - Visible et ShowBalloonTip()
6. Timer
    - Création et configuration
    - Interval (en millisecondes)
    - Événement Tick
    - Start() et Stop()
    - Utilisation pour mise à jour périodique

---

📘 PARTIE 12 : WinForms - Dialogues et fenêtres Fichier Obsidian suggéré : `powershell-winforms-dialogues-fenetres.md`

**Sujets à couvrir :**

1. MessageBox personnalisé
    - MessageBox.Show() et ses surcharges
    - Boutons (OK, OKCancel, YesNo, etc.)
    - Icônes (Information, Warning, Error, Question)
    - Bouton par défaut
    - Récupération du résultat (DialogResult)
2. OpenFileDialog
    - Création et configuration
    - Filter pour types de fichiers
    - Multiselect
    - InitialDirectory
    - ShowDialog() et FileName/FileNames
3. SaveFileDialog
    - Configuration similaire à OpenFileDialog
    - DefaultExt et AddExtension
    - OverwritePrompt
    - FileName et récupération du chemin
4. FolderBrowserDialog
    - Sélection de dossier
    - Description et RootFolder
    - ShowNewFolderButton
    - SelectedPath
5. ColorDialog et FontDialog
    - ColorDialog pour sélection de couleur
    - FontDialog pour sélection de police
    - Color et Font sélectionnés
    - Application aux contrôles
6. Fenêtres modales personnalisées
    - Création de formulaires de dialogue
    - DialogResult pour retour de valeur
    - AcceptButton et CancelButton
    - Passage de données entre fenêtres
    - Owner pour fenêtre parente
7. SplashScreen
    - Écran de démarrage
    - FormBorderStyle None
    - BackgroundImage
    - Timer pour fermeture automatique
    - TopMost et StartPosition CenterScreen

---

📘 PARTIE 13 : WPF - Introduction Fichier Obsidian suggéré : `powershell-wpf-introduction.md`

**Sujets à couvrir :**

1. WPF vs WinForms
    - Avantages de WPF (design moderne, XAML, binding)
    - Inconvénients (complexité, courbe d'apprentissage)
    - Quand choisir WPF plutôt que WinForms
    - Performance et rendu
2. XAML - Syntaxe de base
    - Qu'est-ce que XAML
    - Structure d'un fichier XAML
    - Éléments et attributs
    - Namespaces XML
    - Commentaires en XAML
3. Chargement XAML en PowerShell
    - Add-Type pour PresentationFramework
    
    - Lecture depuis fichier externe
    - XAML en here-string
    - Gestion des erreurs de parsing
4. Première fenêtre WPF
    - Création d'une Window
    - Propriétés de base (Title, Width, Height)
    - ShowDialog() pour affichage
    - Accès aux éléments XAML depuis PowerShell
5. Styles et Resources
    - Définition de styles XAML
    - ResourceDictionary
    - StaticResource vs DynamicResource
    - Styles inline vs styles partagés
    - Thèmes et apparence

---

📘 PARTIE 14 : WPF - Composants et Binding Fichier Obsidian suggéré : `powershell-wpf-composants-binding.md`

**Sujets à couvrir :**

1. Composants WPF essentiels
    - Button, Label, TextBox en WPF
    - Grid, StackPanel, DockPanel pour layout
    - Border et Padding
    - Événements Click et TextChanged
2. Data Binding - Concept fondamental
    - Qu'est-ce que le binding
    - Binding en XAML vs code-behind
    - Mode (OneWay, TwoWay, OneTime)
    - UpdateSourceTrigger
    - Path et ElementName
3. INotifyPropertyChanged
    - Interface pour notification de changement
    - Implémentation en PowerShell
    - PropertyChanged event
    - Mise à jour automatique de l'UI
4. ObservableCollection
    - Collection avec notification de changement
    - Add, Remove, Clear
    - Binding à ListBox ou DataGrid
    - Mise à jour automatique de l'UI
5. Commands et MVVM simplifié
    - Concept de Command
    - ICommand interface
    - RelayCommand simple
    - Binding de commandes aux boutons
    - Séparation logique/présentation
6. Animations de base
    - Storyboard en XAML
    - DoubleAnimation pour propriétés numériques
    - ColorAnimation
    - Duration et AutoReverse
    - Triggers pour animations automatiques

---

📘 PARTIE 15 : Optimisation et performance Fichier Obsidian suggéré : `powershell-optimisation-performance.md`

**Sujets à couvrir :**

1. Performance d'affichage console
    - StringBuilder pour concaténation
    - Limitation des Write-Host
    - Buffering de sortie
    - [Console]::Write vs Write-Host
    - Out-String vs Out-Default
2. Optimisation GUI
    - SuspendLayout() et ResumeLayout()
    - BeginUpdate() et EndUpdate() pour ListBox/ComboBox
    - DoubleBuffered pour éviter le flickering
    - Chargement asynchrone de données
3. Responsive design console
    - Détection de la taille de fenêtre
    - Adaptation dynamique du layout
    - Gestion du redimensionnement
    - Breakpoints pour différentes largeurs
    - Test sur différentes résolutions
4. Profilage et benchmarking
    - Measure-Command pour mesurer le temps
    - Stopwatch pour chronométrage précis
    - Identification des goulots d'étranglement
    - Optimisation ciblée

---

📘 PARTIE 16 : Internationalisation et thèmes Fichier Obsidian suggéré : `powershell-internationalisation-themes.md`

**Sujets à couvrir :**

1. Fichiers de ressources multilingues
    - Structure des fichiers de langue (.psd1)
    - Séparation du texte et du code
    - Chargement conditionnel par langue
    - Fallback sur langue par défaut
2. Détection de la culture système
    - $PSCulture et $PSUICulture
    - Get-Culture et Get-UICulture
    - [System.Globalization.CultureInfo]
    - Détection automatique vs choix manuel
3. Systèmes de thèmes
    - Thème clair vs thème sombre
    - Fichiers de configuration de thème
    - Application dynamique de thème
    - Prévisualisation de thèmes
4. Profils utilisateur
    - Sauvegarde des préférences utilisateur
    - Fichier de configuration personnel
    - Chargement au démarrage
    - Réinitialisation aux valeurs par défaut

---

📘 PARTIE 17 : Intégration système et cross-platform Fichier Obsidian suggéré : `powershell-integration-systeme.md`

**Sujets à couvrir :**

1. Notifications Windows
    - Toast notifications (Windows 10/11)
    - BurntToast module
    - Notifications personnalisées
    - Actions dans les notifications
2. Intégration système Windows
    - Création de shortcuts (.lnk)
    - Icônes personnalisées (.ico)
    - Menu contextuel Windows (ajout d'entrées)
    - Tâches planifiées pour scripts
3. Scripts cross-platform
    - Détection de l'OS ($IsWindows, $IsMacOS, $IsLinux)
    - Compatibilité PowerShell 5 vs 7
    - Chemins cross-platform (Join-Path, [System.IO.Path])
    - Alternatives aux commandes Windows-only
    - Test sur différentes plateformes
4. Sécurité et signature
    - Signature de scripts (Set-AuthenticodeSignature)
    - Certificats de code
    - ExecutionPolicy et son impact
    - Get-ExecutionPolicy et Set-ExecutionPolicy
    - Protection des credentials (SecureString, PSCredential)

---

📘 PARTIE 18 : Packaging et déploiement Fichier Obsidian suggéré : `powershell-packaging-deploiement.md`

**Sujets à couvrir :**

1. Conversion en exécutable
    - PS2EXE pour convertir .ps1 en .exe
    - Options de compilation
    - Icône personnalisée
    - Mode console vs fenêtre
    - Gestion des dépendances embarquées
2. Création d'installeurs
    - Inno Setup pour créer des installeurs
    - Structure d'un script Inno Setup
    - Installation de fichiers et dossiers
    - Raccourcis bureau et menu Démarrer
    - Désinstallation propre
3. Scripts auto-contenus
    - Embedding de ressources
    - Modules embarqués dans le script
    - Détection et installation de dépendances
    - Mode portable (sans installation)
4. Gestion des dépendances
    - PSDepend pour déclaration de dépendances
    - Install-Module automatisé
    - Vérification de modules requis
    - Versions minimales requises
5. Versioning et mises à jour
    - Numérotation sémantique (SemVer)
    - Changelog et notes de version
    - Vérification de mise à jour automatique
    - Auto-update mechanism simple