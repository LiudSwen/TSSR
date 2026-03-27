

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

## 🔧 Add-Type pour charger les bibliothèques

### Pourquoi charger System.Windows.Forms ?

PowerShell n'a pas accès par défaut aux classes .NET nécessaires pour créer des interfaces graphiques Windows Forms. Il faut explicitement charger ces assemblies dans la session PowerShell.

> [!info] Assemblies nécessaires
> 
> - **System.Windows.Forms** : Contient tous les contrôles GUI (boutons, zones de texte, etc.)
> - **System.Drawing** : Gère les éléments graphiques (couleurs, polices, images, positionnement)

### Syntaxe de base

```powershell
# Méthode recommandée : charger les deux assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Alternative : charger en une seule ligne (moins lisible)
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
```

### Vérification du chargement

```powershell
# Vérifier si l'assembly est chargée
[System.AppDomain]::CurrentDomain.GetAssemblies() | 
    Where-Object { $_.GetName().Name -like "*Windows.Forms*" }

# Test rapide : créer un objet Form
$form = New-Object System.Windows.Forms.Form
if ($form) {
    Write-Host "✓ WinForms chargé correctement" -ForegroundColor Green
    $form.Dispose()
}
```

### Aliases et raccourcis

```powershell
# Après chargement, utilisation simplifiée avec New-Object
$form = New-Object System.Windows.Forms.Form
$button = New-Object System.Windows.Forms.Button

# Ou avec l'accélérateur de type (plus rapide)
$form = [System.Windows.Forms.Form]::new()
$button = [System.Windows.Forms.Button]::new()
```

> [!tip] Bonne pratique Placez toujours les `Add-Type` au début de votre script, avant toute utilisation de classes WinForms. Cela évite les erreurs de type non trouvé.

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> **Erreur** : "Unable to find type [System.Windows.Forms.Form]"
> 
> - **Cause** : Assembly non chargée
> - **Solution** : Vérifier que `Add-Type` est exécuté avant utilisation
> 
> **Erreur** : Script lent au démarrage
> 
> - **Cause** : Chargement répété des assemblies
> - **Solution** : Ne charger qu'une seule fois par session

### Quand charger les assemblies ?

|Scénario|Recommandation|
|---|---|
|Script unique|Au début du script|
|Module PowerShell|Dans le fichier .psm1|
|Session interactive|Une fois au démarrage de la session|
|Script appelé plusieurs fois|Vérifier si déjà chargé (optionnel)|

```powershell
# Exemple de chargement conditionnel (optionnel, généralement non nécessaire)
if (-not ([System.Management.Automation.PSTypeName]'System.Windows.Forms.Form').Type) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
}
```

---

## 🏗️ Architecture WinForms

### Modèle hiérarchique

Windows Forms utilise une architecture basée sur une **hiérarchie de contrôles** où chaque élément peut contenir d'autres éléments.

```powershell
# Structure hiérarchique typique
Application
    └── Form (Fenêtre principale)
            └── Panel (Conteneur)
                    ├── Button (Contrôle)
                    ├── TextBox (Contrôle)
                    └── Label (Contrôle)
```

> [!info] Concepts clés
> 
> - **Form** : La fenêtre principale, conteneur racine
> - **Controls** : Tous les éléments visuels (boutons, zones de texte, etc.)
> - **Container Controls** : Contrôles pouvant contenir d'autres contrôles (Panel, GroupBox, TabControl)

### Structure de base d'une application WinForms

```powershell
# 1. Charger les assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 2. Créer la fenêtre principale (Form)
$form = New-Object System.Windows.Forms.Form
$form.Text = "Ma première application"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"

# 3. Créer des contrôles
$button = New-Object System.Windows.Forms.Button
$button.Text = "Cliquez-moi"
$button.Location = New-Object System.Drawing.Point(150, 100)
$button.Size = New-Object System.Drawing.Size(100, 30)

# 4. Ajouter les contrôles à la fenêtre
$form.Controls.Add($button)

# 5. Afficher la fenêtre (bloquant)
$form.ShowDialog()

# 6. Nettoyage (optionnel)
$form.Dispose()
```

### Hiérarchie de classes principales

```
System.Object
    └── System.ComponentModel.Component
            └── System.Windows.Forms.Control (classe de base)
                    ├── System.Windows.Forms.ButtonBase
                    │       └── System.Windows.Forms.Button
                    ├── System.Windows.Forms.TextBoxBase
                    │       └── System.Windows.Forms.TextBox
                    ├── System.Windows.Forms.Label
                    ├── System.Windows.Forms.ContainerControl
                    │       ├── System.Windows.Forms.Form
                    │       └── System.Windows.Forms.Panel
                    └── ... (autres contrôles)
```

> [!example] Propriétés héritées Tous les contrôles héritent de `Control` et partagent donc des propriétés communes :
> 
> - `Text` : Texte affiché
> - `Size` : Dimensions (largeur, hauteur)
> - `Location` : Position (X, Y)
> - `Visible` : Visibilité
> - `Enabled` : État activé/désactivé
> - `BackColor`, `ForeColor` : Couleurs

### Collection Controls

Chaque conteneur possède une collection `Controls` pour gérer ses enfants :

```powershell
# Ajouter un contrôle
$form.Controls.Add($button)

# Ajouter plusieurs contrôles
$form.Controls.AddRange(@($button1, $button2, $label))

# Supprimer un contrôle
$form.Controls.Remove($button)

# Accéder aux contrôles
$form.Controls[0]  # Premier contrôle
$form.Controls.Count  # Nombre de contrôles

# Parcourir tous les contrôles
foreach ($control in $form.Controls) {
    Write-Host "Contrôle : $($control.GetType().Name)"
}
```

### Organisation visuelle

> [!tip] Positionnement des contrôles Deux approches principales :
> 
> **1. Positionnement absolu** (manuel)
> 
> ```powershell
> $button.Location = New-Object System.Drawing.Point(50, 100)
> $button.Size = New-Object System.Drawing.Size(120, 30)
> ```
> 
> **2. Ancrage et amarrage** (automatique)
> 
> ```powershell
> $button.Dock = [System.Windows.Forms.DockStyle]::Top
> $button.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor 
>                  [System.Windows.Forms.AnchorStyles]::Right
> ```

### Architecture événementielle

WinForms repose sur un **modèle événementiel** : l'application réagit aux actions utilisateur.

```powershell
# Structure : Événement → Gestionnaire → Action

# 1. Créer un gestionnaire (ScriptBlock)
$button_Click = {
    [System.Windows.Forms.MessageBox]::Show("Bouton cliqué !")
}

# 2. Attacher le gestionnaire à l'événement
$button.Add_Click($button_Click)

# Alternative : définition inline
$button.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Action effectuée")
})
```

> [!info] Événements courants
> 
> - `Click` : Clic sur un contrôle
> - `Load` : Chargement de la fenêtre
> - `FormClosing` : Fermeture de la fenêtre
> - `TextChanged` : Modification de texte
> - `KeyPress` : Touche pressée
> - `MouseEnter`, `MouseLeave` : Survol souris

### Pièges architecturaux

> [!warning] Erreurs à éviter
> 
> **1. Oublier d'ajouter les contrôles à la Form**
> 
> ```powershell
> # ❌ Mauvais : le bouton ne sera pas visible
> $button = New-Object System.Windows.Forms.Button
> $form.ShowDialog()
> 
> # ✓ Bon
> $form.Controls.Add($button)
> $form.ShowDialog()
> ```
> 
> **2. Modifier les contrôles après ShowDialog()**
> 
> ```powershell
> # ❌ Mauvais : ShowDialog() est bloquant
> $form.ShowDialog()
> $button.Text = "Nouveau texte"  # Ne sera jamais exécuté
> 
> # ✓ Bon : modifications avant ou dans les événements
> $button.Text = "Nouveau texte"
> $form.ShowDialog()
> ```

---

## ♻️ Cycle de vie d'une application GUI

### Phases du cycle de vie

```
1. CRÉATION
   └── Instanciation des objets (Form, Controls)

2. INITIALISATION
   └── Configuration des propriétés
   └── Ajout des contrôles
   └── Attachement des événements

3. AFFICHAGE
   └── ShowDialog() ou Show()
   └── Déclenchement de l'événement Load

4. BOUCLE D'ÉVÉNEMENTS
   └── Application.Run() (implicite)
   └── Traitement des interactions utilisateur
   └── Exécution des gestionnaires d'événements

5. FERMETURE
   └── Événement FormClosing (annulable)
   └── Événement FormClosed

6. NETTOYAGE
   └── Dispose() des ressources
```

### Exemple complet du cycle

```powershell
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === PHASE 1 : CRÉATION ===
Write-Host "1. Création de la fenêtre..."
$form = New-Object System.Windows.Forms.Form

# === PHASE 2 : INITIALISATION ===
Write-Host "2. Initialisation..."
$form.Text = "Cycle de vie d'une application"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"

$button = New-Object System.Windows.Forms.Button
$button.Text = "Fermer"
$button.Location = New-Object System.Drawing.Point(150, 100)
$form.Controls.Add($button)

# Événement Load (phase 3)
$form.Add_Load({
    Write-Host "3. Fenêtre chargée (événement Load)"
})

# Événement Click (phase 4 - boucle)
$button.Add_Click({
    Write-Host "4. Bouton cliqué dans la boucle d'événements"
    $form.Close()
})

# Événement FormClosing (phase 5 - début fermeture)
$form.Add_FormClosing({
    param($sender, $e)
    Write-Host "5a. Fermeture en cours (FormClosing)..."
    
    # Possibilité d'annuler la fermeture
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Voulez-vous vraiment fermer ?",
        "Confirmation",
        [System.Windows.Forms.MessageBoxButtons]::YesNo
    )
    
    if ($result -eq [System.Windows.Forms.DialogResult]::No) {
        $e.Cancel = $true  # Annule la fermeture
        Write-Host "Fermeture annulée"
    }
})

# Événement FormClosed (phase 5 - fermeture confirmée)
$form.Add_FormClosed({
    Write-Host "5b. Fenêtre fermée (FormClosed)"
})

# === PHASE 3-5 : AFFICHAGE et BOUCLE ===
Write-Host "Affichage de la fenêtre..."
$result = $form.ShowDialog()

# === PHASE 6 : NETTOYAGE ===
Write-Host "6. Nettoyage des ressources..."
$form.Dispose()
Write-Host "Application terminée"
```

### Méthodes d'affichage

|Méthode|Comportement|Usage|
|---|---|---|
|`ShowDialog()`|**Modale** : bloque l'exécution jusqu'à fermeture|Dialogues, formulaires de saisie|
|`Show()`|**Non-modale** : continue l'exécution|Fenêtres secondaires, notifications|

```powershell
# ShowDialog() - Bloquant (modal)
$form = New-Object System.Windows.Forms.Form
$result = $form.ShowDialog()  # Le script attend ici
Write-Host "Fenêtre fermée, résultat : $result"
$form.Dispose()

# Show() - Non-bloquant (modeless)
$form = New-Object System.Windows.Forms.Form
$form.Show()  # Le script continue immédiatement
Write-Host "Cette ligne s'affiche tout de suite"
# Important : garder le script actif avec Application.Run()
[System.Windows.Forms.Application]::Run($form)
```

> [!warning] Piège avec Show() Si vous utilisez `Show()`, le script continue et peut se terminer avant que l'utilisateur n'interagisse. Il faut soit :
> 
> - Utiliser `[System.Windows.Forms.Application]::Run($form)`
> - Garder une boucle active
> - Utiliser `ShowDialog()` à la place

### Valeurs de retour (DialogResult)

```powershell
# Configurer le résultat d'un bouton
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Annuler"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

# Définir les boutons Accept/Cancel de la Form
$form.AcceptButton = $okButton  # Activé avec Entrée
$form.CancelButton = $cancelButton  # Activé avec Échap

$form.Controls.AddRange(@($okButton, $cancelButton))

# Récupérer le résultat
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "Utilisateur a cliqué OK"
} elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
    Write-Host "Utilisateur a annulé"
}
```

> [!info] Valeurs DialogResult disponibles
> 
> - `OK`, `Cancel`, `Yes`, `No`
> - `Abort`, `Retry`, `Ignore`
> - `None` (par défaut si pas défini)

### Gestion du nettoyage

```powershell
# Méthode 1 : Dispose() manuel (recommandé avec ShowDialog)
$form = New-Object System.Windows.Forms.Form
$form.ShowDialog()
$form.Dispose()  # Libère les ressources

# Méthode 2 : Using (PowerShell 5.0+, pas toujours compatible WinForms)
# Préférer Dispose() manuel pour WinForms

# Méthode 3 : Dispose automatique dans FormClosed
$form.Add_FormClosed({
    $form.Dispose()
})

# Nettoyage de ressources lourdes
$image = [System.Drawing.Image]::FromFile("C:\image.png")
$pictureBox.Image = $image
# ... utilisation ...
$image.Dispose()  # Important pour les images/fichiers
```

> [!tip] Bonne pratique Toujours appeler `Dispose()` sur :
> 
> - Les Forms après utilisation
> - Les images chargées (`System.Drawing.Image`)
> - Les ressources graphiques (Brushes, Pens)
> - Les objets utilisant des fichiers

### Événements du cycle de vie

```powershell
# Ordre chronologique des événements principaux

# 1. Avant affichage
$form.Add_HandleCreated({ Write-Host "Handle Windows créé" })

# 2. Chargement
$form.Add_Load({ Write-Host "Fenêtre chargée" })

# 3. Première apparition
$form.Add_Shown({ Write-Host "Fenêtre affichée pour la première fois" })

# 4. Activation/Désactivation
$form.Add_Activated({ Write-Host "Fenêtre activée (focus)" })
$form.Add_Deactivate({ Write-Host "Fenêtre désactivée (perte focus)" })

# 5. Fermeture
$form.Add_FormClosing({
    param($sender, $e)
    Write-Host "Fermeture en cours (peut être annulée)"
    # $e.Cancel = $true  # Pour annuler
})

$form.Add_FormClosed({ Write-Host "Fenêtre fermée (irréversible)" })

# 6. Destruction
$form.Add_HandleDestroyed({ Write-Host "Handle Windows détruit" })
```

---

## 🧵 Thread principal et événements

### Qu'est-ce que le thread principal ?

En WinForms, **toutes les interactions GUI doivent se faire sur le thread principal** (UI thread). C'est une contrainte fondamentale de Windows.

> [!info] Concept de thread UI
> 
> - **Thread principal** : Le thread qui crée et gère l'interface graphique
> - **Boucle de messages** : Traite les événements Windows (clics, frappes clavier, etc.)
> - **Synchronisation** : Tout accès aux contrôles doit être synchronisé avec ce thread

```powershell
# ShowDialog() démarre automatiquement la boucle de messages
$form.ShowDialog()  # Entre dans Application.Run() implicitement

# Équivalent explicite avec Show()
$form.Show()
[System.Windows.Forms.Application]::Run($form)
```

### Boucle d'événements (Message Loop)

```
┌─────────────────────────────────────────┐
│     BOUCLE D'ÉVÉNEMENTS (infinie)      │
├─────────────────────────────────────────┤
│  1. Attendre un événement Windows       │
│     (clic, touche, mouvement souris...)  │
│          ↓                               │
│  2. Récupérer l'événement de la queue   │
│          ↓                               │
│  3. Identifier le contrôle cible        │
│          ↓                               │
│  4. Appeler le gestionnaire approprié   │
│          ↓                               │
│  5. Retour à l'étape 1                  │
└─────────────────────────────────────────┘
```

### Modèle événementiel en PowerShell

```powershell
# Structure d'un événement WinForms
$controle.Add_NomEvenement({
    param($sender, $e)
    
    # $sender : l'objet qui a déclenché l'événement
    # $e : paramètres de l'événement (EventArgs)
    
    # Votre code ici
})
```

> [!example] Exemple complet
> 
> ```powershell
> $button = New-Object System.Windows.Forms.Button
> $button.Text = "Cliquez-moi"
> 
> $button.Add_Click({
>     param($sender, $e)
>     
>     # $sender est le bouton lui-même
>     $sender.Text = "Cliqué !"
>     $sender.BackColor = [System.Drawing.Color]::Green
>     
>     # Accès aux autres contrôles de la form
>     $form.Text = "Action effectuée"
> })
> ```

### Événements courants et leurs paramètres

|Événement|Type EventArgs|Informations disponibles|
|---|---|---|
|`Click`|`EventArgs`|Basique (pas d'info spécifique)|
|`MouseClick`|`MouseEventArgs`|`Button`, `X`, `Y`, `Clicks`|
|`KeyPress`|`KeyPressEventArgs`|`KeyChar`, `Handled`|
|`KeyDown/KeyUp`|`KeyEventArgs`|`KeyCode`, `Modifiers`, `Alt`, `Control`, `Shift`|
|`TextChanged`|`EventArgs`|Basique|
|`FormClosing`|`FormClosingEventArgs`|`Cancel`, `CloseReason`|

```powershell
# Exemple avec MouseEventArgs
$form.Add_MouseClick({
    param($sender, $e)
    
    Write-Host "Clic à la position : $($e.X), $($e.Y)"
    Write-Host "Bouton utilisé : $($e.Button)"  # Left, Right, Middle
    Write-Host "Nombre de clics : $($e.Clicks)"  # 1 = simple, 2 = double
})

# Exemple avec KeyEventArgs
$textBox.Add_KeyDown({
    param($sender, $e)
    
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
        Write-Host "Entrée pressée"
        $e.Handled = $true  # Empêche le comportement par défaut
    }
    
    if ($e.Control -and $e.KeyCode -eq [System.Windows.Forms.Keys]::S) {
        Write-Host "Ctrl+S détecté (Sauvegarder)"
        $e.Handled = $true
    }
})
```

### Accès aux variables externes (portée)

> [!warning] Gestion des variables dans les ScriptBlocks Les gestionnaires d'événements sont des ScriptBlocks avec leur propre portée.

```powershell
# ❌ Problème : variable locale non accessible
function Create-Form {
    $compteur = 0
    $button = New-Object System.Windows.Forms.Button
    
    $button.Add_Click({
        $compteur++  # ❌ $compteur n'est pas modifié dans la fonction parent
        Write-Host $compteur
    })
}

# ✓ Solution 1 : Variable de portée script
$script:compteur = 0

$button.Add_Click({
    $script:compteur++
    Write-Host $script:compteur
})

# ✓ Solution 2 : Utiliser un objet partagé
$state = @{ Compteur = 0 }

$button.Add_Click({
    $state.Compteur++
    Write-Host $state.Compteur
})

# ✓ Solution 3 : Variable liée au contrôle (Tag)
$button.Tag = @{ Compteur = 0 }

$button.Add_Click({
    param($sender)
    $sender.Tag.Compteur++
    Write-Host $sender.Tag.Compteur
})
```

### Tâches longues et blocage du thread UI

> [!warning] Problème critique Si vous effectuez une opération longue dans un gestionnaire d'événements, **l'interface se fige** car le thread UI est occupé.

```powershell
# ❌ MAUVAIS : Bloque l'interface
$button.Add_Click({
    # Simulation d'une tâche longue
    Start-Sleep -Seconds 5  # L'interface est gelée pendant 5 secondes
    [System.Windows.Forms.MessageBox]::Show("Terminé")
})

# ✓ Solution 1 : RunspacePool (opérations asynchrones)
$button.Add_Click({
    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.Open()
    
    $ps = [powershell]::Create()
    $ps.Runspace = $runspace
    
    [void]$ps.AddScript({
        Start-Sleep -Seconds 5
        # Opération longue ici
    })
    
    # Exécution asynchrone
    $handle = $ps.BeginInvoke()
    
    # Vérifier périodiquement avec un Timer
})

# ✓ Solution 2 : BackgroundWorker (recommandé pour WinForms)
$backgroundWorker = New-Object System.ComponentModel.BackgroundWorker

$backgroundWorker.Add_DoWork({
    param($sender, $e)
    # Travail en arrière-plan (pas d'accès direct aux contrôles GUI)
    Start-Sleep -Seconds 5
    $e.Result = "Résultat du traitement"
})

$backgroundWorker.Add_RunWorkerCompleted({
    param($sender, $e)
    # Retour sur le thread UI (accès aux contrôles autorisé)
    [System.Windows.Forms.MessageBox]::Show("Terminé : $($e.Result)")
})

$button.Add_Click({
    if (-not $backgroundWorker.IsBusy) {
        $backgroundWorker.RunWorkerAsync()
    }
})
```

### Invoke et InvokeRequired (thread-safety)

Si vous devez modifier l'interface depuis un autre thread :

```powershell
# Fonction helper pour invoquer sur le thread UI
function Invoke-OnUIThread {
    param(
        [System.Windows.Forms.Control]$Control,
        [ScriptBlock]$Action
    )
    
    if ($Control.InvokeRequired) {
        # Nous sommes sur un thread différent, utiliser Invoke
        $Control.Invoke([Action]{
            & $Action
        })
    } else {
        # Déjà sur le thread UI
        & $Action
    }
}

# Utilisation
$backgroundWorker.Add_DoWork({
    Start-Sleep -Seconds 2
    
    # Mise à jour d'un contrôle depuis le background thread
    Invoke-OnUIThread -Control $textBox -Action {
        $textBox.Text = "Traitement terminé"
    }
})
```

> [!tip] Timer pour les mises à jour périodiques
> 
> ```powershell
> # Créer un Timer pour des actions répétées
> $timer = New-Object System.Windows.Forms.Timer
> $timer.Interval = 1000  # Millisecondes (1 seconde)
> 
> $timer.Add_Tick({
>     # Exécuté toutes les secondes sur le thread UI
>     $label.Text = Get-Date -Format "HH:mm:ss"
> })
> 
> $timer.Start()
> 
> # Arrêter le timer
> # $timer.Stop()
> # $timer.Dispose()
> ```

### Ordre d'exécution des événements

```powershell
# Certains événements se déclenchent dans un ordre précis

$textBox = New-Object System.Windows.Forms.TextBox

# 1. KeyDown (touche pressée)
$textBox.Add_KeyDown({ Write-Host "1. KeyDown" })

# 2. KeyPress (caractère généré)
$textBox.Add_KeyPress({ Write-Host "2. KeyPress" })

# 3. TextChanged (texte modifié)
$textBox.Add_TextChanged({ Write-Host "3. TextChanged" })

# 4. KeyUp (touche relâchée)
$textBox.Add_KeyUp({ Write-Host "4. KeyUp" })
```

### Suppression de gestionnaires d'événements

```powershell
# Attacher un gestionnaire
$handler = {
    [System.Windows.Forms.MessageBox]::Show("Clic détecté")
}
$button.Add_Click($handler)

# Supprimer le même gestionnaire
$button.Remove_Click($handler)

# ⚠️ Attention : le ScriptBlock doit être la même référence
# Cela ne fonctionnera PAS :
$button.Add_Click({ Write-Host "Test" })
$button.Remove_Click({ Write-Host "Test" })  # ❌ Référence différente
```

### Propagation et annulation d'événements

```powershell
# Annuler un événement FormClosing
$form.Add_FormClosing({
    param($sender, $e)
    
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Sauvegarder avant de quitter ?",
        "Confirmation",
        [System.Windows.Forms.MessageBoxButtons]::YesNoCancel
    )
    
    if ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        $e.Cancel = $true  # Annule la fermeture
    }
})

# Empêcher le comportement par défaut d'une touche
$textBox.Add_KeyPress({
    param($sender, $e)
    
    # Bloquer les caractères non-numériques
    if ($e.KeyChar -notmatch '[0-9]' -and $e.KeyChar -ne "`b") {
        $e.Handled = $true  # Annule l'entrée du caractère
    }
})
```

### Pièges courants avec les événements

> [!warning] Erreurs fréquentes
> 
> **1. Références circulaires**
> 
> ```powershell
> # ❌ Éviter les références au parent depuis le ScriptBlock
> $button.Add_Click({
>     $button.Text = "Cliqué"  # Référence externe
>     # Peut causer des fuites mémoire si non géré correctement
> })
> 
> # ✓ Mieux : utiliser $sender
> $button.Add_Click({
>     param($sender)
>     $sender.Text = "Cliqué"
> })
> ```
> 
> **2. Modification de collection pendant itération**
> 
> ```powershell
> # ❌ Erreur : modification pendant foreach
> foreach ($control in $form.Controls) {
>     $form.Controls.Remove($control)  # Exception !
> }
> 
> # ✓ Solution : copier la collection
> $controlsToRemove = @($form.Controls)
> foreach ($control in $controlsToRemove) {
>     $form.Controls.Remove($control)
> }
> ```
> 
> **3. Gestionnaires non supprimés**
> 
> ```powershell
> # Peut causer des fuites mémoire
> function Create-Window {
>     $form = New-Object System.Windows.Forms.Form
>     $timer = New-Object System.Windows.Forms.Timer
>     
>     $timer.Add_Tick({
>         # Ce gestionnaire garde $form en mémoire
>         $form.Text = Get-Date
>     })
>     
>     $form.ShowDialog()
>     # ✓ Important : nettoyer
>     $timer.Stop()
>     $timer.Dispose()
>     $form.Dispose()
> }
> ```

### Application.DoEvents() - À utiliser avec précaution

```powershell
# Permet de traiter les événements en attente pendant une opération longue
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Maximum = 100

for ($i = 0; $i -le 100; $i++) {
    $progressBar.Value = $i
    
    # Force le traitement des événements GUI
    [System.Windows.Forms.Application]::DoEvents()
    
    Start-Sleep -Milliseconds 50
}
```

> [!warning] Attention avec DoEvents()
> 
> - Peut causer des problèmes de réentrance (un événement déclenché pendant son propre traitement)
> - Préférer BackgroundWorker ou les approches asynchrones pour les opérations longues
> - Utile uniquement pour des cas simples où le contrôle total est garanti

### Communication entre contrôles

```powershell
# Méthode 1 : Références directes (variables de portée appropriée)
$script:textBox = New-Object System.Windows.Forms.TextBox
$script:label = New-Object System.Windows.Forms.Label

$button.Add_Click({
    $script:label.Text = $script:textBox.Text
})

# Méthode 2 : Via la Form parent
$button.Add_Click({
    param($sender)
    
    # Remonter à la Form parent
    $parentForm = $sender.FindForm()
    
    # Chercher un contrôle par nom
    $targetControl = $parentForm.Controls.Find("monTextBox", $true)
    if ($targetControl) {
        $targetControl[0].Text = "Modifié"
    }
})

# Méthode 3 : Via Tag (stockage de données)
$form.Tag = @{
    TextBox = $textBox
    Label = $label
}

$button.Add_Click({
    param($sender)
    $data = $sender.FindForm().Tag
    $data.Label.Text = $data.TextBox.Text
})
```

### Événements personnalisés (avancé)

> [!tip] Créer ses propres événements Bien que rarement nécessaire en PowerShell WinForms, vous pouvez créer des événements personnalisés :
> 
> ```powershell
> # Définir un événement personnalisé
> $customControl = New-Object System.Windows.Forms.Panel
> 
> # Ajouter une méthode pour déclencher l'événement
> $customControl | Add-Member -MemberType ScriptMethod -Name "RaiseCustomEvent" -Value {
>     param($message)
>     
>     # Créer des EventArgs personnalisés
>     $eventArgs = New-Object PSObject -Property @{
>         Message = $message
>         Timestamp = Get-Date
>     }
>     
>     # Déclencher l'événement (simulation)
>     if ($this.CustomEventHandler) {
>         & $this.CustomEventHandler $this $eventArgs
>     }
> }
> 
> # Attacher un gestionnaire
> $customControl | Add-Member -MemberType NoteProperty -Name "CustomEventHandler" -Value {
>     param($sender, $e)
>     Write-Host "Événement reçu : $($e.Message) à $($e.Timestamp)"
> }
> 
> # Déclencher l'événement
> $customControl.RaiseCustomEvent("Test de l'événement personnalisé")
> ```

### Priorité et ordre de traitement

```powershell
# Les événements attachés en premier sont exécutés en premier
$button.Add_Click({ Write-Host "Gestionnaire 1" })
$button.Add_Click({ Write-Host "Gestionnaire 2" })
$button.Add_Click({ Write-Host "Gestionnaire 3" })

# Résultat du clic :
# Gestionnaire 1
# Gestionnaire 2
# Gestionnaire 3
```

> [!info] Délégation d'événements Contrairement à JavaScript/HTML, WinForms ne dispose pas de mécanisme natif de délégation d'événements (bubbling). Les événements ciblent directement le contrôle concerné.

### Déboguer les événements

```powershell
# Tracer tous les événements d'un contrôle
$button.Add_Click({
    param($sender, $e)
    Write-Host "=== Événement Click ===" -ForegroundColor Cyan
    Write-Host "Sender Type: $($sender.GetType().Name)"
    Write-Host "Sender Name: $($sender.Name)"
    Write-Host "Sender Text: $($sender.Text)"
    Write-Host "EventArgs Type: $($e.GetType().Name)"
    Write-Host "======================" -ForegroundColor Cyan
})

# Capturer les exceptions dans les gestionnaires
$button.Add_Click({
    try {
        # Code potentiellement problématique
        $null = 1 / 0
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Erreur dans le gestionnaire : $_",
            "Erreur",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        Write-Host "Exception capturée : $_" -ForegroundColor Red
    }
})
```

---

## 📝 Résumé des concepts clés

### Add-Type

- Charger `System.Windows.Forms` et `System.Drawing` au début du script
- Les assemblies ne doivent être chargées qu'une fois par session
- Utiliser `New-Object` ou `::new()` après chargement

### Architecture WinForms

- Modèle hiérarchique : Form → Conteneurs → Contrôles
- Collection `Controls` pour gérer les enfants
- Tous les contrôles héritent de la classe `Control`
- Positionnement absolu ou avec Anchor/Dock

### Cycle de vie

- Phases : Création → Initialisation → Affichage → Boucle → Fermeture → Nettoyage
- `ShowDialog()` : modal (bloquant), `Show()` : non-modal
- Toujours appeler `Dispose()` pour libérer les ressources
- Événements du cycle : Load → Shown → Activated → FormClosing → FormClosed

### Thread et événements

- Toute interaction GUI se fait sur le thread principal (UI thread)
- Modèle événementiel : `Add_NomEvenement({ param($sender, $e) })`
- Éviter les opérations longues dans les gestionnaires (utiliser BackgroundWorker)
- `InvokeRequired` et `Invoke()` pour la thread-safety
- Timer pour les actions périodiques sur le thread UI

---

## 🎯 Points de vigilance

> [!warning] Checklist avant d'exécuter votre script
> 
> - ✅ Les assemblies sont chargées avec `Add-Type`
> - ✅ Les contrôles sont ajoutés à `$form.Controls`
> - ✅ Les événements sont attachés avant `ShowDialog()`
> - ✅ Les opérations longues utilisent BackgroundWorker
> - ✅ `Dispose()` est appelé après fermeture
> - ✅ Les variables partagées utilisent `$script:` ou des objets
> - ✅ Pas de modification de contrôles depuis d'autres threads sans `Invoke()`

---

## 💡 Astuces supplémentaires

### Débogage rapide

```powershell
# Afficher toutes les propriétés d'un contrôle
$button | Get-Member -MemberType Property

# Lister tous les événements disponibles
$button | Get-Member -MemberType Event

# Voir la hiérarchie des contrôles
function Show-ControlTree {
    param($Control, $Indent = 0)
    
    $spaces = "  " * $Indent
    Write-Host "$spaces- $($Control.GetType().Name) [$($Control.Name)]"
    
    foreach ($child in $Control.Controls) {
        Show-ControlTree -Control $child -Indent ($Indent + 1)
    }
}

Show-ControlTree -Control $form
```

### Prototypes rapides

```powershell
# Template minimal pour tester rapidement
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$f = New-Object System.Windows.Forms.Form
$f.Text = "Test"
$f.Size = New-Object System.Drawing.Size(300, 200)
$f.StartPosition = "CenterScreen"

# Ajoutez vos contrôles ici...

[void]$f.ShowDialog()
$f.Dispose()
```

### Performance

```powershell
# Suspendre le layout lors de l'ajout multiple de contrôles
$form.SuspendLayout()

for ($i = 0; $i -lt 100; $i++) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Bouton $i"
    $button.Location = New-Object System.Drawing.Point(10, ($i * 30))
    $form.Controls.Add($button)
}

$form.ResumeLayout()  # Recalcul du layout en une fois
```

### Raccourcis clavier globaux

```powershell
# Intercepter les touches au niveau de la Form
$form.KeyPreview = $true  # Important !

$form.Add_KeyDown({
    param($sender, $e)
    
    # Ctrl + N
    if ($e.Control -and $e.KeyCode -eq [System.Windows.Forms.Keys]::N) {
        Write-Host "Nouveau document"
        $e.Handled = $true
    }
    
    # F5
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::F5) {
        Write-Host "Actualiser"
        $e.Handled = $true
    }
    
    # Echap pour fermer
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
        $sender.Close()
    }
})
```

---

_Ce cours constitue la fondation pour créer des interfaces graphiques en PowerShell avec Windows Forms. Les concepts présentés (chargement des assemblies, architecture, cycle de vie, gestion des événements et du threading) sont essentiels pour tous vos futurs développements GUI._