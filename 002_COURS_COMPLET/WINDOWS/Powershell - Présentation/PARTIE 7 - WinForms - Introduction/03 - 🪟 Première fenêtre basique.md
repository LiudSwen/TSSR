

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

## Introduction

La classe `Form` est l'élément fondamental de toute interface graphique WinForms. Elle représente une fenêtre Windows complète avec sa barre de titre, ses bordures, et ses boutons de contrôle (réduire, agrandir, fermer).

> [!info] Pourquoi apprendre cela ? Créer une fenêtre basique est la première étape pour construire n'importe quelle interface graphique en PowerShell. Comprendre les propriétés essentielles et les méthodes d'affichage vous permettra de contrôler précisément le comportement de vos applications.

---

## Création d'un objet Form

### Syntaxe de base

```powershell
# Chargement de l'assembly WinForms
Add-Type -AssemblyName System.Windows.Forms

# Création d'une nouvelle fenêtre
$form = New-Object System.Windows.Forms.Form
```

### Exemple complet minimal

```powershell
Add-Type -AssemblyName System.Windows.Forms

# Création de la fenêtre
$form = New-Object System.Windows.Forms.Form

# Affichage de la fenêtre
$form.ShowDialog()
```

> [!example] Résultat Ce code crée et affiche une fenêtre vide avec les valeurs par défaut : titre "Form1", taille 300x300 pixels, positionnée aléatoirement à l'écran.

### Pourquoi utiliser New-Object ?

`New-Object` est la cmdlet PowerShell standard pour instancier des objets .NET. Dans le cas de WinForms, elle crée une instance de la classe `System.Windows.Forms.Form` qui hérite de toutes ses propriétés et méthodes.

> [!tip] Astuce Vous pouvez stocker votre Form dans n'importe quelle variable, mais `$form` ou `$mainForm` sont des conventions courantes pour la lisibilité.

---

## Propriétés essentielles

### Text - Le titre de la fenêtre

La propriété `Text` définit le texte affiché dans la barre de titre de la fenêtre.

```powershell
$form = New-Object System.Windows.Forms.Form
$form.Text = "Mon Application PowerShell"
```

> [!info] Utilité Le titre est la première chose que voit l'utilisateur. Il doit être descriptif et indiquer clairement la fonction de la fenêtre.

**Exemples de bonnes pratiques :**

```powershell
# ✅ Descriptif et professionnel
$form.Text = "Gestionnaire de Comptes Utilisateurs"

# ✅ Avec version
$form.Text = "MonApp v2.1.3"

# ❌ Trop vague
$form.Text = "Form1"
```

---

### Size - Dimensions de la fenêtre

La propriété `Size` définit la largeur et la hauteur de la fenêtre en pixels.

```powershell
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(800, 600)
```

**Syntaxe alternative :**

```powershell
# Avec Width et Height séparément
$form.Width = 800
$form.Height = 600
```

> [!warning] Attention aux dimensions Les dimensions incluent la barre de titre et les bordures. La zone cliente (zone utilisable) sera légèrement plus petite.

#### Tableau des tailles courantes

|Type d'application|Largeur|Hauteur|Usage|
|---|---|---|---|
|Dialogue simple|400-500|200-300|Formulaire de saisie rapide|
|Fenêtre standard|800-1000|600-700|Application complète|
|Plein écran|Screen.Width|Screen.Height|Dashboard, monitoring|
|Compact|300-400|150-250|Notification, alerte|

**Exemple avec calcul dynamique :**

```powershell
# Fenêtre qui prend 80% de l'écran
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$form.Width = $screen.Width * 0.8
$form.Height = $screen.Height * 0.8
```

---

### StartPosition - Position initiale

La propriété `StartPosition` contrôle où la fenêtre apparaît lors de son affichage.

```powershell
$form = New-Object System.Windows.Forms.Form
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
```

#### Valeurs disponibles

|Valeur|Description|Quand l'utiliser|
|---|---|---|
|`Manual`|Position définie par Location|Pour contrôle précis de la position|
|`CenterScreen`|Centre de l'écran principal|**Recommandé** - Meilleure expérience utilisateur|
|`WindowsDefaultLocation`|Position par défaut Windows|Rarement utilisé|
|`WindowsDefaultBounds`|Position et taille par défaut|Rarement utilisé|
|`CenterParent`|Centre de la fenêtre parente|Pour dialogues modaux|

> [!tip] Bonne pratique Utilisez toujours `CenterScreen` pour vos fenêtres principales, c'est le comportement attendu par les utilisateurs.

**Exemple avec position manuelle :**

```powershell
# Position manuelle (coin supérieur gauche)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$form.Location = New-Object System.Drawing.Point(100, 100)
```

---

### Exemple complet avec les trois propriétés

```powershell
Add-Type -AssemblyName System.Windows.Forms

# Création de la fenêtre
$form = New-Object System.Windows.Forms.Form

# Configuration des propriétés essentielles
$form.Text = "Gestionnaire de Scripts"
$form.Size = New-Object System.Drawing.Size(900, 650)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# Affichage
$form.ShowDialog()
```

> [!example] Résultat Une fenêtre de 900x650 pixels, centrée à l'écran, avec le titre "Gestionnaire de Scripts".

---

## ShowDialog() vs Show()

WinForms offre deux méthodes principales pour afficher une fenêtre, chacune avec un comportement très différent.

### ShowDialog() - Affichage modal

```powershell
$result = $form.ShowDialog()
```

**Caractéristiques :**

- ⛔ **Bloquant** : Le script s'arrête et attend que la fenêtre soit fermée
- 🔒 **Modal** : L'utilisateur ne peut pas interagir avec d'autres fenêtres de l'application
- ↩️ **Retourne une valeur** : DialogResult qui indique comment la fenêtre a été fermée
- 🎯 **Cas d'usage** : Dialogues, formulaires de saisie, confirmations

**Exemple avec gestion du retour :**

```powershell
$form = New-Object System.Windows.Forms.Form
$form.Text = "Confirmer l'action"

# Affichage modal
$result = $form.ShowDialog()

# Le code suivant ne s'exécute qu'APRÈS la fermeture de la fenêtre
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "Utilisateur a confirmé"
} else {
    Write-Host "Utilisateur a annulé"
}
```

> [!info] Comportement Tant que la fenêtre est ouverte, PowerShell reste "en pause" sur la ligne `ShowDialog()`. C'est idéal pour les interactions où vous avez besoin d'une réponse avant de continuer.

---

### Show() - Affichage non-modal

```powershell
$form.Show()
```

**Caractéristiques :**

- ✅ **Non-bloquant** : Le script continue immédiatement après l'affichage
- 🔓 **Non-modal** : L'utilisateur peut interagir avec d'autres fenêtres
- ⚠️ **Ne retourne rien** : Pas de DialogResult
- 🎯 **Cas d'usage** : Fenêtres de monitoring, dashboards, outils qui tournent en arrière-plan

**Exemple basique :**

```powershell
$form = New-Object System.Windows.Forms.Form
$form.Text = "Monitoring en temps réel"

# Affichage non-modal
$form.Show()

# Le code continue immédiatement ici
Write-Host "La fenêtre est affichée mais le script continue"

# PROBLÈME : Le script se termine et la fenêtre disparaît !
```

> [!warning] Piège courant avec Show() Si votre script se termine après `Show()`, la fenêtre disparaîtra immédiatement car le processus PowerShell se termine. Vous devez maintenir le script actif.

**Solution : Boucle d'application**

```powershell
Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Fenêtre persistante"
$form.Show()

# Boucle qui maintient l'application active
[System.Windows.Forms.Application]::Run($form)

# Le code ici ne s'exécute qu'après la fermeture de la fenêtre
Write-Host "Fenêtre fermée"
```

---

### Tableau comparatif

|Critère|ShowDialog()|Show()|
|---|---|---|
|**Bloque le script**|✅ Oui|❌ Non|
|**Modal**|✅ Oui|❌ Non|
|**Retourne DialogResult**|✅ Oui|❌ Non|
|**Nécessite Application.Run()**|❌ Non|✅ Oui (souvent)|
|**Usage typique**|Dialogues, formulaires|Applications complètes|

### Quand utiliser quoi ?

> [!tip] Règle simple
> 
> - **ShowDialog()** : Quand vous avez besoin d'une réponse de l'utilisateur avant de continuer
> - **Show()** : Quand la fenêtre doit rester ouverte pendant que d'autres traitements se font

**Exemples de scénarios :**

```powershell
# ✅ Bon usage de ShowDialog()
$confirmForm = New-Object System.Windows.Forms.Form
$confirmForm.Text = "Supprimer le fichier ?"
$result = $confirmForm.ShowDialog()
if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
    Remove-Item "fichier.txt"
}

# ✅ Bon usage de Show()
$monitorForm = New-Object System.Windows.Forms.Form
$monitorForm.Text = "Surveillance CPU"
$monitorForm.Show()
[System.Windows.Forms.Application]::Run($monitorForm)
```

---

## Fermeture et retour de valeur

### Fermeture basique

La fenêtre peut être fermée de plusieurs façons :

```powershell
# 1. L'utilisateur clique sur le X
# (comportement par défaut)

# 2. Par code avec Close()
$form.Close()

# 3. Avec Dispose() (libère toutes les ressources)
$form.Dispose()
```

> [!info] Différence Close() vs Dispose()
> 
> - `Close()` : Ferme la fenêtre, mais l'objet reste en mémoire
> - `Dispose()` : Ferme ET libère toutes les ressources (mémoire, handles)

---

### DialogResult - Retour de valeur

Quand vous utilisez `ShowDialog()`, vous pouvez définir un `DialogResult` pour indiquer comment la fenêtre a été fermée.

#### Valeurs de DialogResult

```powershell
[System.Windows.Forms.DialogResult]::None       # Pas de résultat
[System.Windows.Forms.DialogResult]::OK         # OK/Valider
[System.Windows.Forms.DialogResult]::Cancel     # Annuler
[System.Windows.Forms.DialogResult]::Yes        # Oui
[System.Windows.Forms.DialogResult]::No         # Non
[System.Windows.Forms.DialogResult]::Abort      # Abandonner
[System.Windows.Forms.DialogResult]::Retry      # Réessayer
[System.Windows.Forms.DialogResult]::Ignore     # Ignorer
```

---

### Exemple complet avec boutons et DialogResult

```powershell
Add-Type -AssemblyName System.Windows.Forms

# Création de la fenêtre
$form = New-Object System.Windows.Forms.Form
$form.Text = "Confirmer la suppression"
$form.Size = New-Object System.Drawing.Size(400, 150)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# Bouton OK
$btnOK = New-Object System.Windows.Forms.Button
$btnOK.Text = "Supprimer"
$btnOK.Location = New-Object System.Drawing.Point(100, 70)
$btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($btnOK)

# Bouton Annuler
$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = "Annuler"
$btnCancel.Location = New-Object System.Drawing.Point(200, 70)
$btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.Controls.Add($btnCancel)

# Affichage et récupération du résultat
$result = $form.ShowDialog()

# Traitement selon le résultat
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "Suppression confirmée" -ForegroundColor Green
} else {
    Write-Host "Opération annulée" -ForegroundColor Yellow
}

# Nettoyage
$form.Dispose()
```

> [!example] Comportement Quand l'utilisateur clique sur un bouton avec un DialogResult défini, la fenêtre se ferme automatiquement et retourne cette valeur.

---

### Définir les boutons par défaut

Vous pouvez définir quel bouton est activé par défaut avec Enter et Escape :

```powershell
# Bouton activé avec la touche Enter
$form.AcceptButton = $btnOK

# Bouton activé avec la touche Escape
$form.CancelButton = $btnCancel
```

**Exemple complet :**

```powershell
Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Question"
$form.Size = New-Object System.Drawing.Size(350, 150)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# Bouton Oui
$btnYes = New-Object System.Windows.Forms.Button
$btnYes.Text = "Oui"
$btnYes.Location = New-Object System.Drawing.Point(80, 70)
$btnYes.DialogResult = [System.Windows.Forms.DialogResult]::Yes
$form.Controls.Add($btnYes)

# Bouton Non
$btnNo = New-Object System.Windows.Forms.Button
$btnNo.Text = "Non"
$btnNo.Location = New-Object System.Drawing.Point(170, 70)
$btnNo.DialogResult = [System.Windows.Forms.DialogResult]::No
$form.Controls.Add($btnNo)

# Touches par défaut
$form.AcceptButton = $btnYes  # Enter = Oui
$form.CancelButton = $btnNo   # Escape = Non

# Affichage
$result = $form.ShowDialog()

Write-Host "Réponse: $result"
$form.Dispose()
```

> [!tip] Ergonomie Définir `AcceptButton` et `CancelButton` améliore considérablement l'expérience utilisateur en permettant l'usage du clavier.

---

### Intercepter la fermeture

Vous pouvez intercepter l'événement de fermeture pour effectuer des actions ou annuler la fermeture :

```powershell
# Événement déclenché lors de la tentative de fermeture
$form.Add_FormClosing({
    param($sender, $e)
    
    # Demander confirmation
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Voulez-vous vraiment quitter ?",
        "Confirmation",
        [System.Windows.Forms.MessageBoxButtons]::YesNo
    )
    
    # Annuler la fermeture si l'utilisateur dit Non
    if ($result -eq [System.Windows.Forms.DialogResult]::No) {
        $e.Cancel = $true
    }
})
```

> [!warning] Usage modéré N'abusez pas de ce mécanisme, les utilisateurs n'aiment pas qu'on les empêche de fermer une fenêtre. Réservez-le aux cas où des données non sauvegardées pourraient être perdues.

---

## 🎯 Points clés à retenir

> [!tip] Récapitulatif
> 
> - **Form** est l'objet de base pour toute fenêtre WinForms
> - **Text**, **Size** et **StartPosition** sont les propriétés minimales à configurer
> - **ShowDialog()** pour les dialogues modaux (bloquant, retourne un résultat)
> - **Show()** pour les fenêtres non-modales (nécessite `Application.Run()`)
> - **DialogResult** permet de communiquer le résultat de la fermeture d'une fenêtre
> - Toujours appeler **Dispose()** pour libérer les ressources

---

## ⚠️ Pièges courants

> [!warning] Erreurs fréquentes
> 
> 1. **Oublier `Add-Type -AssemblyName System.Windows.Forms`** → Erreur "type not found"
> 2. **Utiliser `Show()` sans boucle d'application** → La fenêtre disparaît immédiatement
> 3. **Ne pas centrer la fenêtre** → Mauvaise expérience utilisateur
> 4. **Oublier `Dispose()`** → Fuite mémoire dans les scripts longs
> 5. **Confondre Close() et Dispose()** → Ressources non libérées

---

## 💡 Astuces professionnelles

```powershell
# Désactiver le bouton de maximisation
$form.MaximizeBox = $false

# Désactiver le bouton de minimisation
$form.MinimizeBox = $false

# Empêcher le redimensionnement
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

# Fenêtre toujours au premier plan
$form.TopMost = $true

# Icône personnalisée (nécessite un fichier .ico)
$form.Icon = New-Object System.Drawing.Icon("C:\chemin\vers\icone.ico")

# Définir une couleur de fond
$form.BackColor = [System.Drawing.Color]::WhiteSmoke
```

---

🎓 **Vous maîtrisez maintenant la création de fenêtres basiques en WinForms !**