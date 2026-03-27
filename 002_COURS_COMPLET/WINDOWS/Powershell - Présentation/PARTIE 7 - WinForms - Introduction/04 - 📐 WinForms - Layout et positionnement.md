

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

## 🎯 Introduction au positionnement {#introduction}

Le positionnement des contrôles dans WinForms est l'un des aspects les plus critiques pour créer des interfaces utilisateur professionnelles et responsive. PowerShell offre plusieurs approches pour organiser les éléments visuels, chacune ayant ses avantages et cas d'usage spécifiques.

> [!info] Pourquoi c'est important
> 
> - Une interface mal organisée est difficile à utiliser et peu professionnelle
> - Le redimensionnement de fenêtre peut casser votre mise en page si elle n'est pas bien conçue
> - Différentes résolutions d'écran nécessitent des layouts adaptatifs
> - La maintenance du code est plus facile avec la bonne méthode de positionnement

### Les 5 méthodes principales

1. **Positionnement absolu** : Contrôle manuel précis (Location, Size)
2. **Anchor** : Maintien des distances par rapport aux bords lors du redimensionnement
3. **Dock** : Remplissage automatique d'un espace
4. **FlowLayoutPanel** : Flux automatique des contrôles
5. **TableLayoutPanel** : Grille structurée

---

## 📍 Positionnement absolu {#positionnement-absolu}

Le positionnement absolu consiste à définir manuellement la position et la taille exactes de chaque contrôle en pixels.

### 🔧 Propriétés fondamentales

#### Location - Position du contrôle

```powershell
# Syntaxe basique
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(50, 30)
# Le bouton sera positionné à 50 pixels du bord gauche et 30 pixels du bord haut

# Alternative avec assignation directe
$button.Left = 50
$button.Top = 30

# Récupération des valeurs
$posX = $button.Location.X
$posY = $button.Location.Y
```

> [!example] Exemple complet
> 
> ```powershell
> Add-Type -AssemblyName System.Windows.Forms
> 
> $form = New-Object System.Windows.Forms.Form
> $form.Text = "Positionnement absolu"
> $form.Size = New-Object System.Drawing.Size(400, 300)
> 
> # Bouton en haut à gauche
> $btnTopLeft = New-Object System.Windows.Forms.Button
> $btnTopLeft.Text = "Haut Gauche"
> $btnTopLeft.Location = New-Object System.Drawing.Point(10, 10)
> $btnTopLeft.Size = New-Object System.Drawing.Size(100, 30)
> 
> # Bouton centré
> $btnCenter = New-Object System.Windows.Forms.Button
> $btnCenter.Text = "Centré"
> $btnCenter.Location = New-Object System.Drawing.Point(150, 135)
> $btnCenter.Size = New-Object System.Drawing.Size(100, 30)
> 
> # Bouton en bas à droite
> $btnBottomRight = New-Object System.Windows.Forms.Button
> $btnBottomRight.Text = "Bas Droite"
> $btnBottomRight.Location = New-Object System.Drawing.Point(290, 230)
> $btnBottomRight.Size = New-Object System.Drawing.Size(100, 30)
> 
> $form.Controls.AddRange(@($btnTopLeft, $btnCenter, $btnBottomRight))
> $form.ShowDialog()
> ```

#### Size - Dimensions du contrôle

```powershell
# Définir la taille
$button.Size = New-Object System.Drawing.Size(120, 40)
# Largeur : 120 pixels, Hauteur : 40 pixels

# Alternative
$button.Width = 120
$button.Height = 40

# Auto-ajustement au contenu (pour certains contrôles)
$label = New-Object System.Windows.Forms.Label
$label.Text = "Texte très long qui nécessite plus d'espace"
$label.AutoSize = $true  # S'adapte automatiquement
```

### 📐 Calculs de positionnement

```powershell
# Centrer un contrôle horizontalement
$button.Left = ($form.ClientSize.Width - $button.Width) / 2

# Centrer verticalement
$button.Top = ($form.ClientSize.Height - $button.Height) / 2

# Positionner à droite avec marge
$button.Left = $form.ClientSize.Width - $button.Width - 10

# Positionner en bas avec marge
$button.Top = $form.ClientSize.Height - $button.Height - 10

# Espacer plusieurs contrôles verticalement
$spacing = 10
$label1.Top = 20
$textbox1.Top = $label1.Bottom + $spacing
$label2.Top = $textbox1.Bottom + $spacing
$textbox2.Top = $label2.Bottom + $spacing
```

> [!tip] Astuce - ClientSize vs Size
> 
> - **Size** : Dimensions totales incluant la bordure et la barre de titre
> - **ClientSize** : Zone utilisable à l'intérieur (recommandé pour les calculs)
> 
> ```powershell
> # Bon
> $center = $form.ClientSize.Width / 2
> 
> # Moins précis
> $center = $form.Size.Width / 2
> ```

### ⚠️ Avantages et inconvénients

|Avantages|Inconvénients|
|---|---|
|✅ Contrôle pixel-perfect|❌ Pas responsive au redimensionnement|
|✅ Simple à comprendre|❌ Difficile à maintenir avec beaucoup de contrôles|
|✅ Idéal pour designs fixes|❌ Problèmes avec différentes résolutions/DPI|
|✅ Pas de conteneurs nécessaires|❌ Repositionnement manuel nécessaire|

> [!warning] Pièges courants
> 
> - **Oublier ClientSize** : Utiliser `Size` au lieu de `ClientSize` crée des décalages
> - **Hardcoder les positions** : Rend impossible l'adaptation à différentes tailles d'écran
> - **Ignorer les DPI** : Sur des écrans haute résolution, les pixels peuvent être trop petits
> - **Positions négatives** : Peuvent rendre des contrôles invisibles

---

## ⚓ Anchor - Ancrage aux bords {#anchor}

La propriété `Anchor` maintient la distance d'un contrôle par rapport aux bords de son conteneur lors du redimensionnement.

### 🔧 Fonctionnement

```powershell
# Valeurs possibles
[System.Windows.Forms.AnchorStyles]::Top
[System.Windows.Forms.AnchorStyles]::Bottom
[System.Windows.Forms.AnchorStyles]::Left
[System.Windows.Forms.AnchorStyles]::Right
[System.Windows.Forms.AnchorStyles]::None

# Par défaut : Top, Left
$button.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
```

### 📊 Comportements selon les ancrages

#### Ancrage simple

```powershell
# Ancré en haut à gauche (défaut) - Position fixe
$btn.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left

# Ancré en haut à droite - Reste collé au coin supérieur droit
$btn.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right

# Ancré en bas à gauche - Descend avec le bas de la fenêtre
$btn.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

# Ancré en bas à droite - Coin inférieur droit
$btn.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
```

#### Ancrage étendu (redimensionnement)

```powershell
# S'étire horizontalement
$textbox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

# S'étire verticalement
$listbox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

# S'étire dans les deux dimensions
$panel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
```

> [!example] Exemple - Interface adaptative
> 
> ```powershell
> Add-Type -AssemblyName System.Windows.Forms
> 
> $form = New-Object System.Windows.Forms.Form
> $form.Text = "Démonstration Anchor"
> $form.Size = New-Object System.Drawing.Size(500, 400)
> 
> # Barre de titre fixe en haut
> $labelTitle = New-Object System.Windows.Forms.Label
> $labelTitle.Text = "Ma superbe application"
> $labelTitle.Location = New-Object System.Drawing.Point(10, 10)
> $labelTitle.Size = New-Object System.Drawing.Size(200, 20)
> $labelTitle.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
> 
> # Zone de texte qui s'étire horizontalement et verticalement
> $textbox = New-Object System.Windows.Forms.TextBox
> $textbox.Multiline = $true
> $textbox.Location = New-Object System.Drawing.Point(10, 40)
> $textbox.Size = New-Object System.Drawing.Size(460, 270)
> $textbox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
> 
> # Bouton OK ancré en bas à droite
> $btnOk = New-Object System.Windows.Forms.Button
> $btnOk.Text = "OK"
> $btnOk.Location = New-Object System.Drawing.Point(395, 320)
> $btnOk.Size = New-Object System.Drawing.Size(75, 30)
> $btnOk.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
> 
> # Bouton Annuler ancré en bas à droite
> $btnCancel = New-Object System.Windows.Forms.Button
> $btnCancel.Text = "Annuler"
> $btnCancel.Location = New-Object System.Drawing.Point(310, 320)
> $btnCancel.Size = New-Object System.Drawing.Size(75, 30)
> $btnCancel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
> 
> $form.Controls.AddRange(@($labelTitle, $textbox, $btnOk, $btnCancel))
> $form.ShowDialog()
> ```

### 🎯 Cas d'usage typiques

```powershell
# Barre d'outils en haut qui s'étire
$toolbar.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

# Barre de statut en bas qui s'étire
$statusbar.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

# Panneau latéral qui s'étire verticalement
$sidebar.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

# Zone de contenu principale qui occupe tout l'espace
$mainPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

# Boutons de dialogue en bas à droite
$btnAction.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
```

> [!tip] Astuce - Raccourci pour tous les côtés
> 
> ```powershell
> # Au lieu de
> $control.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
> 
> # Utilisez
> $control.Anchor = [System.Windows.Forms.AnchorStyles]::Top, [System.Windows.Forms.AnchorStyles]::Bottom, [System.Windows.Forms.AnchorStyles]::Left, [System.Windows.Forms.AnchorStyles]::Right
> ```

### ⚠️ Pièges courants

> [!warning] Attention
> 
> - **Conflits avec Dock** : Ne pas combiner Anchor et Dock sur le même contrôle
> - **Taille minimum** : Anchor ne garantit pas une taille minimum, définir `MinimumSize` si nécessaire
> - **Ordre d'ajout** : Les contrôles ancrés doivent être ajoutés dans le bon ordre pour éviter les chevauchements
> - **Calculs initiaux** : Les positions/tailles initiales déterminent les marges, bien les définir avant d'ancrer

```powershell
# Bon : définir MinimumSize pour éviter les contrôles trop petits
$form.MinimumSize = New-Object System.Drawing.Size(400, 300)

# Bon : ordre logique d'ajout
$form.Controls.Add($toolbarTop)      # Haut
$form.Controls.Add($sidebarLeft)     # Gauche
$form.Controls.Add($mainContent)     # Centre
$form.Controls.Add($statusBarBottom) # Bas
```

---

## 🔒 Dock - Remplissage {#dock}

La propriété `Dock` fait qu'un contrôle remplit complètement un bord ou toute la zone de son conteneur.

### 🔧 Valeurs possibles

```powershell
[System.Windows.Forms.DockStyle]::None    # Pas d'ancrage (défaut)
[System.Windows.Forms.DockStyle]::Top     # Remplit le haut
[System.Windows.Forms.DockStyle]::Bottom  # Remplit le bas
[System.Windows.Forms.DockStyle]::Left    # Remplit la gauche
[System.Windows.Forms.DockStyle]::Right   # Remplit la droite
[System.Windows.Forms.DockStyle]::Fill    # Remplit tout l'espace restant
```

### 📐 Comportements selon les styles

#### Dock sur les bords

```powershell
# Barre d'outils en haut
$toolbar = New-Object System.Windows.Forms.Panel
$toolbar.Height = 50
$toolbar.Dock = [System.Windows.Forms.DockStyle]::Top
$toolbar.BackColor = [System.Drawing.Color]::LightGray

# Barre de statut en bas
$statusbar = New-Object System.Windows.Forms.Panel
$statusbar.Height = 30
$statusbar.Dock = [System.Windows.Forms.DockStyle]::Bottom
$statusbar.BackColor = [System.Drawing.Color]::LightBlue

# Panneau latéral gauche
$sidebar = New-Object System.Windows.Forms.Panel
$sidebar.Width = 200
$sidebar.Dock = [System.Windows.Forms.DockStyle]::Left
$sidebar.BackColor = [System.Drawing.Color]::LightYellow

# Panneau latéral droit
$properties = New-Object System.Windows.Forms.Panel
$properties.Width = 250
$properties.Dock = [System.Windows.Forms.DockStyle]::Right
$properties.BackColor = [System.Drawing.Color]::LightCoral
```

#### Dock Fill - Remplissage total

```powershell
# Zone de contenu qui remplit l'espace restant
$mainContent = New-Object System.Windows.Forms.Panel
$mainContent.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainContent.BackColor = [System.Drawing.Color]::White

# IMPORTANT : L'ordre d'ajout des contrôles détermine ce qui est "restant"
```

> [!example] Exemple - Layout d'application classique
> 
> ```powershell
> Add-Type -AssemblyName System.Windows.Forms
> 
> $form = New-Object System.Windows.Forms.Form
> $form.Text = "Application avec Dock"
> $form.Size = New-Object System.Drawing.Size(800, 600)
> 
> # Menu / Toolbar en haut (ajouté en premier)
> $toolbar = New-Object System.Windows.Forms.Panel
> $toolbar.Dock = [System.Windows.Forms.DockStyle]::Top
> $toolbar.Height = 40
> $toolbar.BackColor = [System.Drawing.Color]::FromArgb(64, 64, 64)
> 
> $btnNew = New-Object System.Windows.Forms.Button
> $btnNew.Text = "Nouveau"
> $btnNew.Location = New-Object System.Drawing.Point(5, 5)
> $btnNew.Size = New-Object System.Drawing.Size(80, 30)
> $toolbar.Controls.Add($btnNew)
> 
> # Barre de statut en bas (ajoutée en deuxième)
> $statusBar = New-Object System.Windows.Forms.Panel
> $statusBar.Dock = [System.Windows.Forms.DockStyle]::Bottom
> $statusBar.Height = 25
> $statusBar.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
> 
> $lblStatus = New-Object System.Windows.Forms.Label
> $lblStatus.Text = "Prêt"
> $lblStatus.Location = New-Object System.Drawing.Point(5, 3)
> $lblStatus.AutoSize = $true
> $statusBar.Controls.Add($lblStatus)
> 
> # Explorateur de fichiers à gauche (ajouté en troisième)
> $treeView = New-Object System.Windows.Forms.TreeView
> $treeView.Dock = [System.Windows.Forms.DockStyle]::Left
> $treeView.Width = 200
> 
> # Propriétés à droite (ajouté en quatrième)
> $propertiesPanel = New-Object System.Windows.Forms.Panel
> $propertiesPanel.Dock = [System.Windows.Forms.DockStyle]::Right
> $propertiesPanel.Width = 250
> $propertiesPanel.BackColor = [System.Drawing.Color]::FromArgb(250, 250, 250)
> 
> # Zone de contenu principale (ajoutée en dernier - remplit l'espace restant)
> $textBox = New-Object System.Windows.Forms.TextBox
> $textBox.Multiline = $true
> $textBox.Dock = [System.Windows.Forms.DockStyle]::Fill
> $textBox.Font = New-Object System.Drawing.Font("Consolas", 10)
> 
> # Ordre d'ajout CRITIQUE
> $form.Controls.Add($textBox)           # Fill en dernier
> $form.Controls.Add($propertiesPanel)   # Right avant Fill
> $form.Controls.Add($treeView)          # Left avant Fill
> $form.Controls.Add($statusBar)         # Bottom avant tout
> $form.Controls.Add($toolbar)           # Top avant tout
> 
> $form.ShowDialog()
> ```

### 🎯 Ordre Z et priorité

> [!info] Comprendre l'ordre Z (Z-Order) L'ordre dans lequel vous ajoutez les contrôles docké détermine quelle zone ils occupent :
> 
> 1. Les contrôles ajoutés **en dernier** sont affichés **au premier plan**
> 2. Pour Dock, l'ordre d'ajout détermine quel espace est "déjà pris"
> 3. Règle : Ajoutez les bordures (Top/Bottom/Left/Right) **avant** le Fill

```powershell
# CORRECT : Top/Bottom d'abord, puis Left/Right, puis Fill
$form.Controls.Add($contentFill)    # Dernier ajouté = remplit ce qui reste
$form.Controls.Add($panelRight)     
$form.Controls.Add($panelLeft)
$form.Controls.Add($statusBottom)
$form.Controls.Add($toolbarTop)     # Premier ajouté = plus prioritaire

# INCORRECT : mauvais ordre
$form.Controls.Add($toolbarTop)
$form.Controls.Add($contentFill)    # Remplira tout sauf la toolbar !
$form.Controls.Add($statusBottom)   # N'aura pas d'espace
```

### 🔄 Combinaison avec d'autres propriétés

```powershell
# Dock avec taille minimum
$sidebar.Dock = [System.Windows.Forms.DockStyle]::Left
$sidebar.Width = 200
$sidebar.MinimumSize = New-Object System.Drawing.Size(150, 0)

# Dock avec padding pour espacement
$panel.Dock = [System.Windows.Forms.DockStyle]::Fill
$panel.Padding = New-Object System.Windows.Forms.Padding(10)  # Marge intérieure de 10px

# Dock avec splitter pour ajustement manuel
$splitter = New-Object System.Windows.Forms.Splitter
$splitter.Dock = [System.Windows.Forms.DockStyle]::Left
$splitter.Width = 3
# Ajouter après le panneau gauche et avant le contenu principal
```

> [!tip] Astuce - Splitters pour interfaces ajustables
> 
> ```powershell
> # Panneau gauche redimensionnable
> $leftPanel.Dock = [System.Windows.Forms.DockStyle]::Left
> $form.Controls.Add($leftPanel)
> 
> # Splitter pour redimensionner
> $splitter = New-Object System.Windows.Forms.Splitter
> $splitter.Dock = [System.Windows.Forms.DockStyle]::Left
> $splitter.BackColor = [System.Drawing.Color]::Gray
> $form.Controls.Add($splitter)
> 
> # Contenu principal
> $mainPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
> $form.Controls.Add($mainPanel)
> ```

### ⚠️ Avantages et inconvénients

|Avantages|Inconvénients|
|---|---|
|✅ Parfait pour layouts d'application|❌ Moins de contrôle précis|
|✅ Responsive automatiquement|❌ Ordre d'ajout critique|
|✅ Idéal pour panneaux et barres|❌ Peut être déroutant au début|
|✅ Code minimal|❌ Difficile à mixer avec positionnement absolu|

> [!warning] Pièges courants
> 
> - **Oublier l'ordre** : Ajouter Fill avant les bordures rend les bordures invisibles
> - **Conflit avec Size** : Width/Height sont ignorés pour certaines directions (Width ignoré pour Dock.Left)
> - **Mélanger avec Anchor** : Dock remplace complètement Anchor
> - **Pas de marge automatique** : Utiliser Padding ou Margin pour l'espacement

---

## 🌊 FlowLayoutPanel {#flowlayoutpanel}

Le `FlowLayoutPanel` dispose automatiquement ses contrôles enfants en flux, comme du texte qui passe à la ligne.

### 🔧 Création et configuration

```powershell
$flowPanel = New-Object System.Windows.Forms.FlowLayoutPanel

# Direction du flux
$flowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight  # Défaut
$flowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$flowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::RightToLeft
$flowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::BottomUp

# Retour à la ligne automatique
$flowPanel.WrapContents = $true   # Passe à la ligne (défaut)
$flowPanel.WrapContents = $false  # Pas de retour à la ligne

# Auto-scroll si contenu trop grand
$flowPanel.AutoScroll = $true
```

### 📐 Propriétés de flux

#### FlowDirection - Direction du flux

```powershell
# Horizontal de gauche à droite (typique pour boutons)
$flowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight

# Vertical de haut en bas (typique pour menus)
$flowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown

# De droite à gauche (pour langues RTL)
$flowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::RightToLeft

# De bas en haut (rare)
$flowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::BottomUp
```

#### WrapContents - Retour à la ligne

```powershell
# Avec retour à la ligne (responsive)
$flowPanel.WrapContents = $true
# Les contrôles passent à la ligne suivante si pas assez de place

# Sans retour à la ligne
$flowPanel.WrapContents = $false
# Les contrôles continuent hors écran (nécessite AutoScroll)
```

> [!example] Exemple - Barre d'outils responsive
> 
> ```powershell
> Add-Type -AssemblyName System.Windows.Forms
> 
> $form = New-Object System.Windows.Forms.Form
> $form.Text = "FlowLayoutPanel - Toolbar"
> $form.Size = New-Object System.Drawing.Size(600, 400)
> 
> # FlowPanel pour la barre d'outils
> $toolbar = New-Object System.Windows.Forms.FlowLayoutPanel
> $toolbar.Dock = [System.Windows.Forms.DockStyle]::Top
> $toolbar.Height = 80
> $toolbar.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
> $toolbar.WrapContents = $true
> $toolbar.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
> $toolbar.Padding = New-Object System.Windows.Forms.Padding(5)
> 
> # Ajouter plusieurs boutons
> $buttonNames = @("Nouveau", "Ouvrir", "Enregistrer", "Couper", "Copier", "Coller", "Annuler", "Refaire", "Rechercher", "Remplacer")
> 
> foreach ($name in $buttonNames) {
>     $btn = New-Object System.Windows.Forms.Button
>     $btn.Text = $name
>     $btn.Size = New-Object System.Drawing.Size(80, 30)
>     $btn.Margin = New-Object System.Windows.Forms.Padding(2)
>     $toolbar.Controls.Add($btn)
> }
> 
> $form.Controls.Add($toolbar)
> $form.ShowDialog()
> # Redimensionnez la fenêtre : les boutons se réorganisent automatiquement !
> ```

### 🎯 Cas d'usage typiques

#### Galerie d'images ou tuiles

```powershell
$gallery = New-Object System.Windows.Forms.FlowLayoutPanel
$gallery.Dock = [System.Windows.Forms.DockStyle]::Fill
$gallery.AutoScroll = $true
$gallery.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$gallery.WrapContents = $true
$gallery.Padding = New-Object System.Windows.Forms.Padding(10)

# Ajouter des vignettes
1..20 | ForEach-Object {
    $picBox = New-Object System.Windows.Forms.PictureBox
    $picBox.Size = New-Object System.Drawing.Size(100, 100)
    $picBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $picBox.Margin = New-Object System.Windows.Forms.Padding(5)
    $picBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    $gallery.Controls.Add($picBox)
}
```

#### Liste de tags ou badges

```powershell
$tagsPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$tagsPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$tagsPanel.WrapContents = $true
$tagsPanel.AutoSize = $true
$tagsPanel.Padding = New-Object System.Windows.Forms.Padding(5)

$tags = @("PowerShell", "WinForms", "C#", "Python", "Azure", "Docker", "Git")
foreach ($tag in $tags) {
    $lblTag = New-Object System.Windows.Forms.Label
    $lblTag.Text = $tag
    $lblTag.AutoSize = $true
    $lblTag.BackColor = [System.Drawing.Color]::LightBlue
    $lblTag.Padding = New-Object System.Windows.Forms.Padding(5, 2, 5, 2)
    $lblTag.Margin = New-Object System.Windows.Forms.Padding(3)
    $lblTag.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $tagsPanel.Controls.Add($lblTag)
}
```

#### Menu vertical dynamique

```powershell
$menuPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$menuPanel.Dock = [System.Windows.Forms.DockStyle]::Left
$menuPanel.Width = 150
$menuPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$menuPanel.WrapContents = $false
$menuPanel.AutoScroll = $true

$menuItems = @("Dashboard", "Utilisateurs", "Paramètres", "Rapports", "Aide")
foreach ($item in $menuItems) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $item
    $btn.Width = 140
    $btn.Height = 40
    $btn.Margin = New-Object System.Windows.Forms.Padding(5)
    $menuPanel.Controls.Add($btn)
}
```

### 🔧 Contrôle du positionnement des enfants

```powershell
# Padding du conteneur (marge intérieure)
$flowPanel.Padding = New-Object System.Windows.Forms.Padding(10)  # 10px partout
$flowPanel.Padding = New-Object System.Windows.Forms.Padding(5, 10, 5, 10)  # Gauche, Haut, Droite, Bas

# Margin des contrôles enfants (espacement entre eux)
$button.Margin = New-Object System.Windows.Forms.Padding(5)  # 5px partout
$button.Margin = New-Object System.Windows.Forms.Padding(0, 0, 10, 0)  # 10px à droite uniquement

# AutoSize pour s'adapter au contenu
$flowPanel.AutoSize = $true
$flowPanel.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
```

> [!tip] Astuce - Alignement dans FlowLayoutPanel FlowLayoutPanel n'a pas de propriété d'alignement direct, mais vous pouvez :
> 
> ```powershell
> # Centrer en ajoutant des panels vides avant/après
> # Ou utiliser TableLayoutPanel pour un meilleur contrôle de l'alignement
> 
> # Alternative : définir la largeur exacte du FlowPanel
> $flowPanel.Width = 400
> $flowPanel.WrapContents = $false
> # Centrer les boutons en calculant leur position
> ```

### ⚠️ Avantages et inconvénients

|Avantages|Inconvénients|
|---|---|
|✅ Disposition automatique|❌ Pas de contrôle précis du positionnement|
|✅ Responsive au redimensionnement|❌ Pas d'alignement sophistiqué|
|✅ Idéal pour collections dynamiques|❌ Performance avec beaucoup de contrôles|
|✅ Facile à implémenter|❌ Espacement uniforme seulement|

> [!warning] Pièges courants
> 
> - **Taille des enfants** : Si les contrôles n'ont pas de taille définie, ils peuvent être invisibles
> - **WrapContents = false sans AutoScroll** : Les contrôles disparaissent hors écran
> - **Oublier Margin** : Les contrôles se collent sans espacement
> - **AutoSize du panel** : Peut causer des problèmes avec Dock

---

## 📊 TableLayoutPanel {#tablelayoutpanel}

Le `TableLayoutPanel` organise les contrôles dans une grille de lignes et colonnes, comme un tableau HTML.

### 🔧 Création et configuration de base

```powershell
$tablePanel = New-Object System.Windows.Forms.TableLayoutPanel

# Définir le nombre de colonnes et lignes
$tablePanel.ColumnCount = 3
$tablePanel.RowCount = 2

# Dimensionnement automatique
$tablePanel.AutoSize = $true
$tablePanel.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
```

### 📐 Configuration des colonnes et lignes

#### Styles de dimensionnement

```powershell
# Types de dimensionnement disponibles
[System.Windows.Forms.SizeType]::Absolute   # Taille fixe en pixels
[System.Windows.Forms.SizeType]::Percent    # Pourcentage de l'espace disponible
[System.Windows.Forms.SizeType]::AutoSize   # S'adapte au contenu

# Ajouter des styles de colonnes
$tablePanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 30)))
$tablePanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 70)))

# Ajouter des styles de lignes
$tablePanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 30)))
$tablePanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
```

> [!example] Exemple - Formulaire de saisie
> 
> ```powershell
> Add-Type -AssemblyName System.Windows.Forms
> 
> $form = New-Object System.Windows.Forms.Form
> $form.Text = "Formulaire avec TableLayoutPanel"
> $form.Size = New-Object System.Drawing.Size(500, 300)
> $form.Padding = New-Object System.Windows.Forms.Padding(10)
> 
> # Créer le TableLayoutPanel
> $tablePanel = New-Object System.Windows.Forms.TableLayoutPanel
> $tablePanel.Dock = [System.Windows.Forms.DockStyle]::Fill
> $tablePanel.ColumnCount = 2
> $tablePanel.RowCount = 5
> 
> # Colonne 1 : Labels (30%)
> $tablePanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 30))) | Out-Null
> # Colonne 2 : TextBoxes (70%)
> $tablePanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 70))) | Out-Null
> 
> # Lignes avec hauteur automatique
> 1..4 | ForEach-Object {
>     $tablePanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize))) | Out-Null
> }
> # Dernière ligne pour les boutons (hauteur fixe)
> $tablePanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 40))) | Out-Null
> 
> # Ligne 0 : Nom
> $lblNom = New-Object System.Windows.Forms.Label
> $lblNom.Text = "Nom :"
> $lblNom.Anchor = [System.Windows.Forms.AnchorStyles]::Right
> $lblNom.AutoSize = $true
> $tablePanel.Controls.Add($lblNom, 0, 0)
> 
> $txtNom = New-Object System.Windows.Forms.TextBox
> $txtNom.Dock = [System.Windows.Forms.DockStyle]::Fill
> $tablePanel.Controls.Add($txtNom, 1, 0)
> 
> # Ligne 1 : Prénom
> $lblPrenom = New-Object System.Windows.Forms.Label
> $lblPrenom.Text = "Prénom :"
> $lblPrenom.Anchor = [System.Windows.Forms.AnchorStyles]::Right
> $lblPrenom.AutoSize = $true
> $tablePanel.Controls.Add($lblPrenom, 0, 1)
> 
> $txtPrenom = New-Object System.Windows.Forms.TextBox
> $txtPrenom.Dock = [System.Windows.Forms.DockStyle]::Fill
> $tablePanel.Controls.Add($txtPrenom, 1, 1)
> 
> # Ligne 2 : Email
> $lblEmail = New-Object System.Windows.Forms.Label
> $lblEmail.Text = "Email :"
> $lblEmail.Anchor = [System.Windows.Forms.AnchorStyles]::Right
> $lblEmail.AutoSize = $true
> $tablePanel.Controls.Add($lblEmail, 0, 2)
> 
> $txtEmail = New-Object System.Windows.Forms.TextBox
> $txtEmail.Dock = [System.Windows.Forms.DockStyle]::Fill
> $tablePanel.Controls.Add($txtEmail, 1, 2)
> 
> # Ligne 3 : Téléphone
> $lblTel = New-Object System.Windows.Forms.Label
> $lblTel.Text = "Téléphone :"
> $lblTel.Anchor = [System.Windows.Forms.AnchorStyles]::Right
> $lblTel.AutoSize = $true
> $tablePanel.Controls.Add($lblTel, 0, 3)
> 
> $txtTel = New-Object System.Windows.Forms.TextBox
> $txtTel.Dock = [System.Windows.Forms.DockStyle]::Fill
> $tablePanel.Controls.Add($txtTel, 1, 3)
> 
> # Ligne 4 : Boutons (occupe 2 colonnes)
> $panelButtons = New-Object System.Windows.Forms.FlowLayoutPanel
> $panelButtons.FlowDirection = [System.Windows.Forms.FlowDirection]::RightToLeft
> $panelButtons.Dock = [System.Windows.Forms.DockStyle]::Fill
> 
> $btnOk = New-Object System.Windows.Forms.Button
> $btnOk.Text = "OK"
> $btnOk.Size = New-Object System.Drawing.Size(75, 30)
> $panelButtons.Controls.Add($btnOk)
> 
> $btnCancel = New-Object System.Windows.Forms.Button
> $btnCancel.Text = "Annuler"
> $btnCancel.Size = New-Object System.Drawing.Size(75, 30)
> $panelButtons.Controls.Add($btnCancel)
> 
> $tablePanel.Controls.Add($panelButtons, 0, 4)
> $tablePanel.SetColumnSpan($panelButtons, 2)  # Occupe 2 colonnes
> 
> $form.Controls.Add($tablePanel)
> $form.ShowDialog()
> ```

### 🎯 Positionnement dans la grille

#### Ajouter des contrôles

```powershell
# Méthode 1 : Spécifier colonne et ligne lors de l'ajout
$tablePanel.Controls.Add($control, $column, $row)

# Méthode 2 : Définir après ajout
$tablePanel.Controls.Add($control)
$tablePanel.SetColumn($control, $column)
$tablePanel.SetRow($control, $row)

# Exemple
$label = New-Object System.Windows.Forms.Label
$label.Text = "Mon label"
$tablePanel.Controls.Add($label, 0, 0)  # Colonne 0, Ligne 0
```

#### Fusion de cellules (Span)

```powershell
# Fusionner plusieurs colonnes
$tablePanel.SetColumnSpan($control, 2)  # Occupe 2 colonnes

# Fusionner plusieurs lignes
$tablePanel.SetRowSpan($control, 3)  # Occupe 3 lignes

# Exemple : En-tête qui occupe toute la largeur
$header = New-Object System.Windows.Forms.Label
$header.Text = "Titre du formulaire"
$header.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$header.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$header.Dock = [System.Windows.Forms.DockStyle]::Fill
$tablePanel.Controls.Add($header, 0, 0)
$tablePanel.SetColumnSpan($header, 3)  # Occupe les 3 colonnes
```

### 🔧 Configuration avancée

#### CellBorderStyle - Bordures des cellules

```powershell
# Afficher les bordures (utile pour le débogage)
$tablePanel.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$tablePanel.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Inset
$tablePanel.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Outset
$tablePanel.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::None  # Défaut
```

#### GrowStyle - Comportement d'ajout dynamique

```powershell
# Ajouter des lignes automatiquement si nécessaire
$tablePanel.GrowStyle = [System.Windows.Forms.TableLayoutPanelGrowStyle]::AddRows

# Ajouter des colonnes automatiquement
$tablePanel.GrowStyle = [System.Windows.Forms.TableLayoutPanelGrowStyle]::AddColumns

# Ne pas grandir automatiquement (défaut)
$tablePanel.GrowStyle = [System.Windows.Forms.TableLayoutPanelGrowStyle]::FixedSize
```

### 📊 Exemples de layouts courants

#### Layout de dashboard (3x2)

```powershell
$dashboard = New-Object System.Windows.Forms.TableLayoutPanel
$dashboard.Dock = [System.Windows.Forms.DockStyle]::Fill
$dashboard.ColumnCount = 3
$dashboard.RowCount = 2
$dashboard.Padding = New-Object System.Windows.Forms.Padding(5)

# 3 colonnes égales
1..3 | ForEach-Object {
    $dashboard.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 33.33))) | Out-Null
}

# 2 lignes égales
1..2 | ForEach-Object {
    $dashboard.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 50))) | Out-Null
}

# Ajouter 6 panneaux
for ($row = 0; $row -lt 2; $row++) {
    for ($col = 0; $col -lt 3; $col++) {
        $panel = New-Object System.Windows.Forms.Panel
        $panel.Dock = [System.Windows.Forms.DockStyle]::Fill
        $panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $panel.Margin = New-Object System.Windows.Forms.Padding(3)
        $dashboard.Controls.Add($panel, $col, $row)
    }
}
```

#### Layout maître-détail

```powershell
$masterDetail = New-Object System.Windows.Forms.TableLayoutPanel
$masterDetail.Dock = [System.Windows.Forms.DockStyle]::Fill
$masterDetail.ColumnCount = 2
$masterDetail.RowCount = 1

# Colonne gauche (liste) : 300px fixes
$masterDetail.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 300))) | Out-Null
# Colonne droite (détails) : reste de l'espace
$masterDetail.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null

# Ligne : remplit toute la hauteur
$masterDetail.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null

# Liste à gauche
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Dock = [System.Windows.Forms.DockStyle]::Fill
$masterDetail.Controls.Add($listBox, 0, 0)

# Détails à droite
$detailsPanel = New-Object System.Windows.Forms.Panel
$detailsPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$masterDetail.Controls.Add($detailsPanel, 1, 0)
```

#### Grille de boutons (calculatrice)

```powershell
$calculator = New-Object System.Windows.Forms.TableLayoutPanel
$calculator.ColumnCount = 4
$calculator.RowCount = 5
$calculator.Dock = [System.Windows.Forms.DockStyle]::Fill

# Toutes les colonnes égales (25%)
1..4 | ForEach-Object {
    $calculator.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 25))) | Out-Null
}

# Toutes les lignes égales (20%)
1..5 | ForEach-Object {
    $calculator.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 20))) | Out-Null
}

$buttons = @(
    @("7", "8", "9", "/"),
    @("4", "5", "6", "*"),
    @("1", "2", "3", "-"),
    @("0", ".", "=", "+"),
    @("C", "CE", "←", "√")
)

for ($row = 0; $row -lt 5; $row++) {
    for ($col = 0; $col -lt 4; $col++) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = $buttons[$row][$col]
        $btn.Dock = [System.Windows.Forms.DockStyle]::Fill
        $btn.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
        $btn.Margin = New-Object System.Windows.Forms.Padding(2)
        $calculator.Controls.Add($btn, $col, $row)
    }
}
```

### 🎨 Alignement des contrôles dans les cellules

```powershell
# Les contrôles enfants peuvent utiliser Anchor pour s'aligner
$label = New-Object System.Windows.Forms.Label
$label.Text = "Aligné à droite"
$label.Anchor = [System.Windows.Forms.AnchorStyles]::Right
$label.AutoSize = $true

# Ou utiliser Dock pour remplir la cellule
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Dock = [System.Windows.Forms.DockStyle]::Fill

# Centrage avec AutoSize
$labelCentered = New-Object System.Windows.Forms.Label
$labelCentered.Text = "Centré"
$labelCentered.AutoSize = $true
$labelCentered.Anchor = [System.Windows.Forms.AnchorStyles]::None  # Centre dans la cellule
```

> [!tip] Astuce - Débogage de TableLayoutPanel
> 
> ```powershell
> # Activer les bordures pour visualiser la grille
> $tablePanel.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
> 
> # Colorer les cellules pour mieux voir
> $panel1.BackColor = [System.Drawing.Color]::LightBlue
> $panel2.BackColor = [System.Drawing.Color]::LightGreen
> $panel3.BackColor = [System.Drawing.Color]::LightYellow
> 
> # Désactiver les bordures en production
> $tablePanel.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::None
> ```

### ⚠️ Avantages et inconvénients

|Avantages|Inconvénients|
|---|---|
|✅ Structure claire et organisée|❌ Plus complexe à configurer|
|✅ Parfait pour formulaires|❌ Peut être verbeux en code|
|✅ Contrôle précis du dimensionnement|❌ Performance avec grandes grilles|
|✅ Fusion de cellules (span)|❌ Courbe d'apprentissage plus élevée|
|✅ Responsive avec les bons styles|❌ Difficile de changer la structure après|

> [!warning] Pièges courants
> 
> - **Index hors limites** : Vérifier que colonne/ligne existent avant d'ajouter un contrôle
> - **Oublier les styles** : Sans ColumnStyle/RowStyle, les dimensions peuvent être imprévisibles
> - **Percent sans totaliser 100%** : Peut causer des problèmes de layout
> - **Absolute + Percent mélangés** : Bien calculer l'espace restant
> - **SetColumnSpan après ajout** : Doit être appelé APRÈS Controls.Add()
> - **AutoSize du TablePanel** : Peut ne pas fonctionner si un contrôle enfant utilise Dock.Fill

---

## ⚖️ Comparaison des méthodes {#comparaison}

### 📊 Tableau comparatif

|Méthode|Complexité|Responsive|Cas d'usage idéal|Performance|
|---|---|---|---|---|
|**Positionnement absolu**|⭐ Facile|❌ Non|Prototypes rapides, layouts fixes|⭐⭐⭐ Excellente|
|**Anchor**|⭐⭐ Moyenne|✅ Oui|Interfaces simples adaptatives|⭐⭐⭐ Excellente|
|**Dock**|⭐⭐ Moyenne|✅ Oui|Applications avec panneaux, IDE|⭐⭐⭐ Excellente|
|**FlowLayoutPanel**|⭐ Facile|✅ Oui|Collections dynamiques, toolbars|⭐⭐ Bonne|
|**TableLayoutPanel**|⭐⭐⭐ Complexe|✅ Oui|Formulaires, grilles structurées|⭐⭐ Bonne|

### 🎯 Guide de choix

```powershell
# Utilisez le POSITIONNEMENT ABSOLU quand :
# - Vous créez un prototype rapide
# - La fenêtre a une taille fixe
# - Vous avez besoin d'un contrôle pixel-perfect
# - L'interface ne sera pas redimensionnée

# Utilisez ANCHOR quand :
# - Vous avez quelques contrôles simples
# - Vous voulez qu'ils suivent les bords lors du redimensionnement
# - Vous ne voulez pas de conteneurs supplémentaires
# - Interface simple mais adaptative

# Utilisez DOCK quand :
# - Vous créez une interface de type application (IDE, explorateur)
# - Vous avez des panneaux qui doivent remplir des zones
# - Vous voulez des barres d'outils, menus, status bars
# - Layout hiérarchique avec zones principales

# Utilisez FLOWLAYOUTPANEL quand :
# - Vous affichez une collection d'éléments similaires
# - Le nombre d'éléments est dynamique
# - Vous voulez un retour à la ligne automatique
# - Toolbar, galerie d'images, tags, badges

# Utilisez TABLELAYOUTPANEL quand :
# - Vous créez un formulaire de saisie
# - Vous avez besoin d'un alignement précis en grille
# - Vous voulez fusionner des cellules
# - Layout complexe mais structuré
```

### 🔀 Combinaison des méthodes

Les méthodes de layout peuvent et doivent être combinées pour créer des interfaces sophistiquées :

> [!example] Exemple - Application complète
> 
> ```powershell
> # Structure principale avec Dock
> $mainPanel = New-Object System.Windows.Forms.Panel
> $mainPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
> 
> # Toolbar en haut avec FlowLayoutPanel
> $toolbar = New-Object System.Windows.Forms.FlowLayoutPanel
> $toolbar.Dock = [System.Windows.Forms.DockStyle]::Top
> $toolbar.Height = 40
> 
> # Formulaire à gauche avec TableLayoutPanel
> $formPanel = New-Object System.Windows.Forms.TableLayoutPanel
> $formPanel.Dock = [System.Windows.Forms.DockStyle]::Left
> $formPanel.Width = 300
> 
> # Zone de contenu avec Anchor
> $content = New-Object System.Windows.Forms.TextBox
> $content.Multiline = $true
> $content.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
> ```

### 💡 Bonnes pratiques générales

> [!tip] Conseils pour tous les layouts
> 
> 1. **Commencez simple** : Ne compliquez pas inutilement
> 2. **Testez le redimensionnement** : Toujours tester en redimensionnant la fenêtre
> 3. **Définissez MinimumSize** : Évitez les interfaces cassées à petite taille
> 4. **Utilisez Padding et Margin** : Pour des espacements propres
> 5. **Commentez votre structure** : Les layouts complexes sont difficiles à relire
> 6. **Prototypez d'abord** : Testez avec positionnement absolu, puis convertissez
> 7. **Un layout par responsabilité** : Divisez l'interface en zones logiques
> 8. **Pensez responsive** : Même si la fenêtre est "fixe", l'utilisateur peut avoir un DPI différent

### 🎨 Pattern de layout recommandé

```powershell
# Structure type d'une application professionnelle

# 1. Fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(900, 600)
$form.MinimumSize = New-Object System.Drawing.Size(600, 400)

# 2. Menu / Toolbar (Dock Top avec FlowLayoutPanel)
$toolbar = New-Object System.Windows.Forms.FlowLayoutPanel
$toolbar.Dock = [System.Windows.Forms.DockStyle]::Top
$toolbar.Height = 50
# ... ajouter boutons

# 3. Status Bar (Dock Bottom)
$statusBar = New-Object System.Windows.Forms.Panel
$statusBar.Dock = [System.Windows.Forms.DockStyle]::Bottom
$statusBar.Height = 25
# ... ajouter labels

# 4. Panneau latéral (Dock Left/Right avec TableLayoutPanel ou FlowLayoutPanel)
$sidebar = New-Object System.Windows.Forms.Panel
$sidebar.Dock = [System.Windows.Forms.DockStyle]::Left
$sidebar.Width = 200
# ... ajouter navigation

# 5. Zone de contenu principale (Dock Fill avec Anchor pour les contrôles internes)
$mainContent = New-Object System.Windows.Forms.Panel
$mainContent.Dock = [System.Windows.Forms.DockStyle]::Fill
# ... ajouter contenu avec Anchor ou TableLayoutPanel selon le besoin

# 6. Ordre d'ajout (CRITIQUE pour Dock)
$form.Controls.Add($mainContent)  # Fill en dernier
$form.Controls.Add($sidebar)      # Left/Right avant Fill
$form.Controls.Add($statusBar)    # Bottom avant autres
$form.Controls.Add($toolbar)      # Top en premier
```

---

## 🎓 Récapitulatif

### Points clés à retenir

> [!info] Les 5 piliers du positionnement WinForms
> 
> 1. **Positionnement absolu (Location, Size)** : Contrôle manuel précis mais pas responsive
> 2. **Anchor** : Maintient les distances aux bords, idéal pour interfaces simples adaptatives
> 3. **Dock** : Remplit des zones, parfait pour structures d'applications
> 4. **FlowLayoutPanel** : Flux automatique, excellent pour collections dynamiques
> 5. **TableLayoutPanel** : Grille structurée, optimal pour formulaires complexes

### Règles d'or

✅ **Toujours tester le redimensionnement** de vos fenêtres  
✅ **Définir MinimumSize** pour éviter les interfaces cassées  
✅ **Respecter l'ordre d'ajout** avec Dock (bordures avant Fill)  
✅ **Utiliser ClientSize** plutôt que Size pour les calculs  
✅ **Combiner les méthodes** pour des interfaces sophistiquées  
✅ **Commenter les layouts complexes** pour faciliter la maintenance

### Erreurs à éviter

❌ Mélanger Anchor et Dock sur le même contrôle  
❌ Oublier les Padding et Margin pour l'espacement  
❌ Hardcoder les positions sans penser au responsive  
❌ Utiliser Size au lieu de ClientSize  
❌ Ajouter Fill avant les bordures avec Dock  
❌ Oublier de tester sur différentes résolutions

---

> [!tip] Pour aller plus loin Maintenant que vous maîtrisez le positionnement, vous pouvez créer des interfaces professionnelles et adaptatives. La prochaine étape sera d'apprendre à gérer les événements et interactions pour rendre vos interfaces réactives et fonctionnelles.

**Bon courage pour vos projets WinForms ! 🚀**