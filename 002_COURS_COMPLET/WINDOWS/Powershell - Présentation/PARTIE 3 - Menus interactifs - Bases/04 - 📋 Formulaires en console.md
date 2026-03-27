

## Table des matières

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

## 🎯 Introduction aux formulaires en console {#introduction}

Un formulaire en console est une séquence de saisies utilisateur permettant de collecter plusieurs informations de manière structurée et interactive. Contrairement aux menus qui proposent des choix prédéfinis, les formulaires permettent la saisie libre tout en garantissant la qualité des données grâce à la validation.

> [!info] Quand utiliser les formulaires en console ?
> 
> - Configuration d'applications nécessitant plusieurs paramètres
> - Création d'utilisateurs, de comptes ou d'objets avec propriétés multiples
> - Saisie de données structurées (coordonnées, informations système, etc.)
> - Scripts d'installation ou d'initialisation
> - Toute situation nécessitant la collecte de données variées avant traitement

---

## 📝 Champs multiples {#champs-multiples}

### Concept fondamental

Un formulaire avec champs multiples organise la collecte de données en séquence logique. Chaque champ représente une information spécifique, et l'ensemble forme un objet cohérent.

### Structure de base

```powershell
# Structure d'un formulaire simple avec plusieurs champs
function New-UserForm {
    Clear-Host
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "   CRÉATION D'UN NOUVEL UTILISATEUR" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Initialisation d'un objet pour stocker les données
    $userData = @{
        Nom = ""
        Prenom = ""
        Email = ""
        Departement = ""
        Telephone = ""
    }
    
    # Collecte séquentielle des informations
    $userData.Nom = Read-Host "Nom"
    $userData.Prenom = Read-Host "Prénom"
    $userData.Email = Read-Host "Email"
    $userData.Departement = Read-Host "Département"
    $userData.Telephone = Read-Host "Téléphone"
    
    return $userData
}

# Utilisation
$nouvelUtilisateur = New-UserForm
```

### Formulaire avec affichage progressif

```powershell
function New-EnhancedUserForm {
    Clear-Host
    
    # En-tête du formulaire
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   FORMULAIRE D'INSCRIPTION UTILISATEUR  ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Hashtable pour stocker les données
    $formData = @{}
    
    # Champ 1 : Nom
    Write-Host "[1/5] " -ForegroundColor Yellow -NoNewline
    Write-Host "Information personnelle" -ForegroundColor White
    $formData.Nom = Read-Host "  → Nom de famille"
    
    # Champ 2 : Prénom
    $formData.Prenom = Read-Host "  → Prénom"
    Write-Host ""
    
    # Champ 3 : Email
    Write-Host "[2/5] " -ForegroundColor Yellow -NoNewline
    Write-Host "Contact" -ForegroundColor White
    $formData.Email = Read-Host "  → Adresse email"
    $formData.Telephone = Read-Host "  → Téléphone (optionnel)"
    Write-Host ""
    
    # Champ 4 : Département
    Write-Host "[3/5] " -ForegroundColor Yellow -NoNewline
    Write-Host "Organisation" -ForegroundColor White
    $formData.Departement = Read-Host "  → Département"
    $formData.Service = Read-Host "  → Service"
    Write-Host ""
    
    # Champ 5 : Rôle
    Write-Host "[4/5] " -ForegroundColor Yellow -NoNewline
    Write-Host "Permissions" -ForegroundColor White
    Write-Host "  Rôles disponibles : Utilisateur, Manager, Administrateur" -ForegroundColor DarkGray
    $formData.Role = Read-Host "  → Rôle"
    Write-Host ""
    
    # Champ 6 : Notes
    Write-Host "[5/5] " -ForegroundColor Yellow -NoNewline
    Write-Host "Informations complémentaires" -ForegroundColor White
    $formData.Notes = Read-Host "  → Notes (optionnel)"
    
    return $formData
}
```

> [!tip] Astuces pour organiser les champs
> 
> - Regroupez les champs par thématique logique (identité, contact, etc.)
> - Utilisez des indicateurs de progression ([1/5], [2/5]...)
> - Indiquez clairement les champs optionnels
> - Ajoutez des descriptions courtes sous forme de hint
> - Séparez visuellement les groupes de champs avec des lignes vides

### Formulaire avec champs conditionnels

```powershell
function New-ConditionalForm {
    $formData = @{}
    
    Clear-Host
    Write-Host "═══ FORMULAIRE DE CONFIGURATION ═══`n" -ForegroundColor Cyan
    
    # Choix du type
    Write-Host "Type de configuration :" -ForegroundColor Yellow
    Write-Host "  1. Configuration simple"
    Write-Host "  2. Configuration avancée"
    $choix = Read-Host "`nVotre choix"
    
    $formData.TypeConfig = $choix
    
    # Champs communs
    Write-Host "`n--- Paramètres généraux ---" -ForegroundColor Green
    $formData.NomProjet = Read-Host "Nom du projet"
    $formData.Description = Read-Host "Description"
    
    # Champs conditionnels selon le type
    if ($choix -eq "2") {
        Write-Host "`n--- Paramètres avancés ---" -ForegroundColor Magenta
        $formData.NiveauVerbose = Read-Host "Niveau de verbosité (1-5)"
        $formData.PathLog = Read-Host "Chemin des logs"
        $formData.MaxThreads = Read-Host "Nombre max de threads"
        
        # Sous-condition
        $enableCache = Read-Host "Activer le cache ? (O/N)"
        if ($enableCache -eq "O") {
            $formData.CachePath = Read-Host "  → Chemin du cache"
            $formData.CacheExpiration = Read-Host "  → Durée d'expiration (heures)"
        }
    }
    
    return $formData
}
```

> [!example] Exemple de champs avec types variés
> 
> ```powershell
> # Formulaire avec différents types de données
> $config = @{}
> 
> # Texte simple
> $config.Nom = Read-Host "Nom"
> 
> # Nombre
> [int]$config.Port = Read-Host "Port"
> 
> # Chemin (avec validation existence)
> $config.CheminFichier = Read-Host "Chemin du fichier"
> 
> # Liste de valeurs
> $config.Tags = (Read-Host "Tags (séparés par des virgules)") -split ","
> 
> # Mot de passe sécurisé
> $config.MotDePasse = Read-Host "Mot de passe" -AsSecureString
> 
> # Booléen
> $reponse = Read-Host "Activer cette option ? (O/N)"
> $config.OptionActive = ($reponse -eq "O")
> ```

---

## ✅ Validation en temps réel {#validation-temps-reel}

### Pourquoi valider en temps réel ?

La validation immédiate permet de corriger les erreurs au moment de la saisie plutôt qu'à la fin du formulaire, améliorant l'expérience utilisateur et réduisant les frustrations.

### Boucle de validation simple

```powershell
function Get-ValidatedInput {
    param(
        [string]$Prompt,
        [scriptblock]$ValidationRule,
        [string]$ErrorMessage = "Valeur invalide. Réessayez."
    )
    
    do {
        $input = Read-Host $Prompt
        $isValid = & $ValidationRule $input
        
        if (-not $isValid) {
            Write-Host "  ❌ $ErrorMessage" -ForegroundColor Red
        }
    } while (-not $isValid)
    
    return $input
}

# Utilisation avec différentes règles de validation
$email = Get-ValidatedInput -Prompt "Email" `
    -ValidationRule { param($value) $value -match '^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$' } `
    -ErrorMessage "Format d'email invalide (ex: user@domain.com)"

$age = Get-ValidatedInput -Prompt "Âge" `
    -ValidationRule { param($value) $value -match '^\d+$' -and [int]$value -ge 18 -and [int]$value -le 120 } `
    -ErrorMessage "L'âge doit être un nombre entre 18 et 120"
```

### Validation avec messages d'aide

```powershell
function Get-ValidatedEmail {
    Write-Host "`nAdresse email" -ForegroundColor Yellow
    Write-Host "  Format attendu : utilisateur@domaine.com" -ForegroundColor DarkGray
    
    do {
        $email = Read-Host "  → Email"
        
        if ([string]::IsNullOrWhiteSpace($email)) {
            Write-Host "  ❌ L'email ne peut pas être vide" -ForegroundColor Red
            $isValid = $false
        }
        elseif ($email -notmatch '^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$') {
            Write-Host "  ❌ Format invalide. Exemple valide : jean.dupont@entreprise.fr" -ForegroundColor Red
            $isValid = $false
        }
        else {
            Write-Host "  ✓ Email valide" -ForegroundColor Green
            $isValid = $true
        }
    } while (-not $isValid)
    
    return $email
}
```

### Validation complexe avec plusieurs règles

```powershell
function Get-ValidatedPassword {
    Write-Host "`nMot de passe" -ForegroundColor Yellow
    Write-Host "  Règles :" -ForegroundColor DarkGray
    Write-Host "    • Minimum 8 caractères" -ForegroundColor DarkGray
    Write-Host "    • Au moins une majuscule" -ForegroundColor DarkGray
    Write-Host "    • Au moins un chiffre" -ForegroundColor DarkGray
    Write-Host "    • Au moins un caractère spécial (@#$%^&+=!)" -ForegroundColor DarkGray
    
    do {
        $password = Read-Host "  → Mot de passe" -AsSecureString
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
        )
        
        # Vérifications multiples
        $checks = @{
            Longueur = $plainPassword.Length -ge 8
            Majuscule = $plainPassword -cmatch '[A-Z]'
            Chiffre = $plainPassword -match '[0-9]'
            Special = $plainPassword -match '[@#$%^&+=!]'
        }
        
        # Affichage des règles respectées/non respectées
        Write-Host ""
        foreach ($rule in $checks.Keys) {
            if ($checks[$rule]) {
                Write-Host "  ✓ $rule" -ForegroundColor Green
            } else {
                Write-Host "  ✗ $rule" -ForegroundColor Red
            }
        }
        
        $isValid = ($checks.Values -notcontains $false)
        
        if (-not $isValid) {
            Write-Host "`n  Veuillez corriger les points ci-dessus`n" -ForegroundColor Yellow
        }
        
    } while (-not $isValid)
    
    return $password
}
```

### Validation avec suggestions

```powershell
function Get-ValidatedDepartment {
    # Liste des départements valides
    $validDepartments = @("IT", "RH", "Finance", "Marketing", "Ventes", "Production")
    
    Write-Host "`nDépartement" -ForegroundColor Yellow
    Write-Host "  Départements disponibles : $($validDepartments -join ', ')" -ForegroundColor DarkGray
    
    do {
        $dept = Read-Host "  → Département"
        
        # Recherche exacte (insensible à la casse)
        $match = $validDepartments | Where-Object { $_ -eq $dept }
        
        if ($match) {
            Write-Host "  ✓ Département valide : $match" -ForegroundColor Green
            return $match
        }
        
        # Recherche de suggestions si pas de correspondance exacte
        $suggestions = $validDepartments | Where-Object { $_ -like "*$dept*" }
        
        if ($suggestions) {
            Write-Host "  ❌ Département invalide. Vouliez-vous dire :" -ForegroundColor Red
            $suggestions | ForEach-Object { Write-Host "     • $_" -ForegroundColor Yellow }
        } else {
            Write-Host "  ❌ Département invalide. Départements disponibles :" -ForegroundColor Red
            $validDepartments | ForEach-Object { Write-Host "     • $_" -ForegroundColor Yellow }
        }
        
    } while ($true)
}
```

> [!warning] Attention aux boucles infinies
> 
> - Toujours fournir une condition de sortie claire
> - Permettre à l'utilisateur d'annuler si nécessaire (voir section Annulation)
> - Éviter les validations trop strictes qui bloquent l'utilisateur
> - Tester tous les cas limites (valeurs vides, caractères spéciaux, etc.)

### Validation avec tentatives limitées

```powershell
function Get-ValidatedInputWithRetry {
    param(
        [string]$Prompt,
        [scriptblock]$ValidationRule,
        [string]$ErrorMessage,
        [int]$MaxAttempts = 3
    )
    
    $attempts = 0
    
    do {
        $attempts++
        $input = Read-Host $Prompt
        $isValid = & $ValidationRule $input
        
        if (-not $isValid) {
            Write-Host "  ❌ $ErrorMessage" -ForegroundColor Red
            
            if ($attempts -lt $MaxAttempts) {
                Write-Host "  Tentative $attempts/$MaxAttempts" -ForegroundColor Yellow
            } else {
                Write-Host "  Nombre maximum de tentatives atteint." -ForegroundColor Red
                $useDefault = Read-Host "  Utiliser la valeur par défaut ? (O/N)"
                if ($useDefault -eq "O") {
                    return $null  # Indique l'utilisation de la valeur par défaut
                }
                $attempts = 0  # Réinitialiser pour continuer
            }
        }
    } while (-not $isValid)
    
    return $input
}
```

---

## 📊 Résumé avant validation {#resume-validation}

### Pourquoi afficher un résumé ?

Le résumé permet à l'utilisateur de vérifier toutes les informations saisies avant validation finale, évitant ainsi les erreurs et donnant la possibilité de modifier des données sans tout recommencer.

### Résumé simple et structuré

```powershell
function Show-FormSummary {
    param(
        [hashtable]$FormData
    )
    
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║        RÉCAPITULATIF DES DONNÉES        ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Green
    
    # Affichage des données sous forme de tableau
    foreach ($key in $FormData.Keys | Sort-Object) {
        $value = $FormData[$key]
        
        # Gestion des valeurs vides
        if ([string]::IsNullOrWhiteSpace($value)) {
            $value = "(non renseigné)"
            $color = "DarkGray"
        } else {
            $color = "White"
        }
        
        # Formatage avec alignement
        Write-Host ("{0,-20} : " -f $key) -ForegroundColor Cyan -NoNewline
        Write-Host $value -ForegroundColor $color
    }
    
    Write-Host "`n" + ("─" * 50) + "`n"
}

# Utilisation dans un formulaire
$userData = New-EnhancedUserForm
Show-FormSummary -FormData $userData

$confirmation = Read-Host "Ces informations sont-elles correctes ? (O/N)"
```

### Résumé avec catégories

```powershell
function Show-CategorizedSummary {
    param(
        [hashtable]$FormData
    )
    
    Clear-Host
    Write-Host "`n══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "     RÉCAPITULATIF DE L'INSCRIPTION" -ForegroundColor Cyan
    Write-Host "══════════════════════════════════════`n" -ForegroundColor Cyan
    
    # Catégorie : Informations personnelles
    Write-Host "┌─ INFORMATIONS PERSONNELLES" -ForegroundColor Yellow
    Write-Host "│"
    Write-Host "│  Nom complet : " -NoNewline; Write-Host "$($FormData.Prenom) $($FormData.Nom)" -ForegroundColor White
    Write-Host "│  Email       : " -NoNewline; Write-Host $FormData.Email -ForegroundColor White
    Write-Host "│  Téléphone   : " -NoNewline; Write-Host $(if($FormData.Telephone){"$($FormData.Telephone)"}else{"(non renseigné)"}) -ForegroundColor $(if($FormData.Telephone){"White"}else{"DarkGray"})
    Write-Host "│"
    
    # Catégorie : Organisation
    Write-Host "├─ ORGANISATION" -ForegroundColor Yellow
    Write-Host "│"
    Write-Host "│  Département : " -NoNewline; Write-Host $FormData.Departement -ForegroundColor White
    Write-Host "│  Service     : " -NoNewline; Write-Host $FormData.Service -ForegroundColor White
    Write-Host "│  Rôle        : " -NoNewline; Write-Host $FormData.Role -ForegroundColor White
    Write-Host "│"
    
    # Catégorie : Informations complémentaires
    if ($FormData.Notes) {
        Write-Host "└─ NOTES" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   $($FormData.Notes)" -ForegroundColor DarkGray
    } else {
        Write-Host "└─ Aucune note additionnelle" -ForegroundColor DarkGray
    }
    
    Write-Host "`n══════════════════════════════════════`n" -ForegroundColor Cyan
}
```

### Résumé avec indicateurs visuels

```powershell
function Show-EnhancedSummary {
    param(
        [hashtable]$FormData,
        [hashtable]$RequiredFields = @{}  # Champs obligatoires
    )
    
    Clear-Host
    Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║     VÉRIFICATION AVANT VALIDATION      ║" -ForegroundColor Magenta
    Write-Host "╚═══════════════════════════════════════╝`n" -ForegroundColor Magenta
    
    $allFieldsValid = $true
    $fieldCount = 0
    $filledCount = 0
    
    foreach ($key in $FormData.Keys | Sort-Object) {
        $fieldCount++
        $value = $FormData[$key]
        $isRequired = $RequiredFields[$key] -eq $true
        
        # Détermination du statut
        if ([string]::IsNullOrWhiteSpace($value)) {
            if ($isRequired) {
                $status = "❌"
                $statusColor = "Red"
                $allFieldsValid = $false
            } else {
                $status = "➖"
                $statusColor = "DarkGray"
            }
            $displayValue = "(vide)"
            $valueColor = "DarkGray"
        } else {
            $status = "✓"
            $statusColor = "Green"
            $displayValue = $value
            $valueColor = "White"
            $filledCount++
        }
        
        # Affichage
        Write-Host " $status " -ForegroundColor $statusColor -NoNewline
        Write-Host ("{0,-18}" -f $key) -ForegroundColor Cyan -NoNewline
        Write-Host " : " -NoNewline
        Write-Host $displayValue -ForegroundColor $valueColor
        
        if ($isRequired -and [string]::IsNullOrWhiteSpace($value)) {
            Write-Host "     ⚠ Champ obligatoire manquant" -ForegroundColor Yellow
        }
    }
    
    # Statistiques
    Write-Host "`n" + ("─" * 50)
    Write-Host " Progression : $filledCount/$fieldCount champs renseignés" -ForegroundColor $(if($allFieldsValid){"Green"}else{"Yellow"})
    
    if (-not $allFieldsValid) {
        Write-Host " ⚠ Certains champs obligatoires sont manquants" -ForegroundColor Red
    } else {
        Write-Host " ✓ Tous les champs obligatoires sont remplis" -ForegroundColor Green
    }
    
    Write-Host ("─" * 50) + "`n"
    
    return $allFieldsValid
}

# Utilisation
$requiredFields = @{
    Nom = $true
    Prenom = $true
    Email = $true
    Departement = $true
    Role = $true
}

$isValid = Show-EnhancedSummary -FormData $userData -RequiredFields $requiredFields
```

### Résumé avec comparaison avant/après (modification)

```powershell
function Show-ModificationSummary {
    param(
        [hashtable]$OldData,
        [hashtable]$NewData
    )
    
    Clear-Host
    Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║      RÉSUMÉ DES MODIFICATIONS          ║" -ForegroundColor Yellow
    Write-Host "╚═══════════════════════════════════════╝`n" -ForegroundColor Yellow
    
    $hasChanges = $false
    
    foreach ($key in $NewData.Keys | Sort-Object) {
        $oldValue = $OldData[$key]
        $newValue = $NewData[$key]
        
        if ($oldValue -ne $newValue) {
            $hasChanges = $true
            Write-Host " 🔄 " -ForegroundColor Yellow -NoNewline
            Write-Host ("{0,-15}" -f $key) -ForegroundColor Cyan
            Write-Host "     Avant : " -NoNewline; Write-Host $oldValue -ForegroundColor Red
            Write-Host "     Après : " -NoNewline; Write-Host $newValue -ForegroundColor Green
            Write-Host ""
        }
    }
    
    if (-not $hasChanges) {
        Write-Host " ℹ Aucune modification détectée" -ForegroundColor DarkGray
    }
    
    Write-Host "`n" + ("─" * 50) + "`n"
    
    return $hasChanges
}
```

> [!tip] Astuces pour les résumés efficaces
> 
> - Utilisez des couleurs différentes pour les valeurs remplies/vides
> - Groupez les informations par catégorie logique
> - Mettez en évidence les champs obligatoires manquants
> - Affichez des statistiques de complétion
> - Permettez la navigation directe vers les champs à modifier
> - Utilisez des icônes/symboles pour une identification rapide (✓, ❌, ⚠, ➖)

---

## ↩️ Annulation et modification {#annulation-modification}

### Annulation simple

```powershell
function New-CancellableForm {
    Write-Host "À tout moment, tapez 'Q' pour quitter sans sauvegarder`n" -ForegroundColor DarkGray
    
    $formData = @{}
    
    # Exemple avec un champ
    $input = Read-Host "Nom (Q pour quitter)"
    if ($input -eq "Q") {
        Write-Host "`n❌ Formulaire annulé" -ForegroundColor Red
        return $null
    }
    $formData.Nom = $input
    
    # ... autres champs avec même logique ...
    
    return $formData
}

# Utilisation avec vérification du retour
$result = New-CancellableForm
if ($null -eq $result) {
    Write-Host "Opération annulée par l'utilisateur"
    return
}
```

### Fonction d'annulation réutilisable

```powershell
function Get-InputWithCancel {
    param(
        [string]$Prompt,
        [string]$CancelKeyword = "Q"
    )
    
    $input = Read-Host "$Prompt ($CancelKeyword pour annuler)"
    
    if ($input -eq $CancelKeyword) {
        throw "UserCancelled"
    }
    
    return $input
}

# Utilisation dans un formulaire
function New-SafeForm {
    try {
        $data = @{}
        
        Write-Host "`n💡 Tapez 'Q' à tout moment pour annuler`n" -ForegroundColor Cyan
        
        $data.Nom = Get-InputWithCancel -Prompt "Nom"
        $data.Prenom = Get-InputWithCancel -Prompt "Prénom"
        $data.Email = Get-InputWithCancel -Prompt "Email"
        
        return $data
    }
    catch {
        if ($_.Exception.Message -eq "UserCancelled") {
            Write-Host "`n⚠ Opération annulée par l'utilisateur" -ForegroundColor Yellow
            return $null
        }
        throw
    }
}
```

### Menu de modification après résumé

```powershell
function Edit-FormData {
    param(
        [hashtable]$FormData
    )
    
    do {
        Clear-Host
        Show-FormSummary -FormData $FormData
        
        Write-Host "OPTIONS :" -ForegroundColor Cyan
        Write-Host " [M] Modifier un champ"
        Write-Host " [V] Valider et continuer"
        Write-Host " [A] Annuler tout"
        Write-Host ""
        
        $choice = Read-Host "Votre choix"
        
        switch ($choice.ToUpper()) {
            "M" {
                Write-Host "`nChamps disponibles :" -ForegroundColor Yellow
                $i = 1
                $keys = $FormData.Keys | Sort-Object
                foreach ($key in $keys) {
                    Write-Host " [$i] $key : $($FormData[$key])" -ForegroundColor White
                    $i++
                }
                
                [int]$fieldChoice = Read-Host "`nNuméro du champ à modifier (0 pour annuler)"
                
                if ($fieldChoice -gt 0 -and $fieldChoice -le $keys.Count) {
                    $selectedKey = $keys[$fieldChoice - 1]
                    Write-Host "`nModification de : $selectedKey" -ForegroundColor Cyan
                    Write-Host "Valeur actuelle : $($FormData[$selectedKey])" -ForegroundColor DarkGray
                    $newValue = Read-Host "Nouvelle valeur"
                    $FormData[$selectedKey] = $newValue
                    Write-Host "✓ Champ modifié avec succès" -ForegroundColor Green
                    Start-Sleep -Seconds 1
                }
            }
            "V" {
                $confirmed = Read-Host "`nConfirmer la validation ? (O/N)"
                if ($confirmed -eq "O") {
                    return "Validated"
                }
            }
            "A" {
                $confirmCancel = Read-Host "`nÊtes-vous sûr de vouloir tout annuler ? (O/N)"
                if ($confirmCancel -eq "O") {
                    return "Cancelled"
                }
            }
        }
    } while ($true)
}

# Utilisation complète
function Complete-FormWorkflow {
    # 1. Collecte des données
    $formData = New-EnhancedUserForm
    
    # 2. Affichage et modification
    $result = Edit-FormData -FormData $formData
    
    # 3. Traitement selon le résultat
    if ($result -eq "Validated") {
        Write-Host "`n✓ Données validées et enregistrées" -ForegroundColor Green
        # Traiter les données...
        return $formData
    }
    elseif ($result -eq "Cancelled") {
        Write-Host "`n❌ Opération annulée" -ForegroundColor Red
        return $null
    }
}
```

### Modification directe par nom de champ

```powershell
function Edit-FieldByName {
    param(
        [hashtable]$FormData
    )
    
    do {
        Clear-Host
        Show-FormSummary -FormData $FormData
        
        Write-Host "`nMODIFICATION RAPIDE" -ForegroundColor Cyan
        Write-Host "─────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "• Tapez le nom du champ à modifier"
        Write-Host "• Tapez 'OK' pour valider"
        Write-Host "• Tapez 'ANNULER' pour tout abandonner"
        Write-Host ""
        
        $fieldName = Read-Host "Champ à modifier"
        
        switch ($fieldName.ToUpper()) {
            "OK" {
                Write-Host "`n✓ Validation des données..." -ForegroundColor Green
                return "Validated"
            }
            "ANNULER" {
                $confirm = Read-Host "Confirmer l'annulation ? (O/N)"
                if ($confirm -eq "O") {
                    return "Cancelled"
                }
            }
            default {
                # Recherche du champ (insensible à la casse)
                $matchingKey = $FormData.Keys | Where-Object { $_ -eq $fieldName }
                
                if ($matchingKey) {
                    Write-Host "`nModification de : " -NoNewline
                    Write-Host $matchingKey -ForegroundColor Yellow
                    Write-Host "Valeur actuelle : " -NoNewline
                    Write-Host $FormData[$matchingKey] -ForegroundColor DarkGray
                    
                    $newValue = Read-Host "Nouvelle valeur"
                    
                    if (-not [string]::IsNullOrWhiteSpace($newValue)) {
                        $FormData[$matchingKey] = $newValue
                        Write-Host "✓ Modifié avec succès !" -ForegroundColor Green
                    } else {
                        Write-Host "✗ Modification annulée (valeur vide)" -ForegroundColor Yellow
                    }
                    
                    Start-Sleep -Seconds 1
                } else {
                    Write-Host "✗ Champ '$fieldName' introuvable" -ForegroundColor Red
                    Start-Sleep -Seconds 2
                }
            }
        }
    } while ($true)
}
```

### Workflow complet avec gestion d'erreur

```powershell
function Invoke-CompleteFormWorkflow {
    param(
        [string]$FormTitle = "FORMULAIRE"
    )
    
    try {
        # Étape 1 : Collecte des données
        Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║  $FormTitle" -ForegroundColor Cyan
        Write-Host "╚═══════════════════════════════════════╝`n" -ForegroundColor Cyan
        
        $formData = @{}
        
        # Collecte avec possibilité d'annulation
        try {
            $formData.Nom = Get-InputWithCancel -Prompt "Nom"
            $formData.Prenom = Get-InputWithCancel -Prompt "Prénom"
            $formData.Email = Get-ValidatedEmail
            $formData.Departement = Get-ValidatedDepartment
        }
        catch {
            if ($_.Exception.Message -eq "UserCancelled") {
                Write-Host "`n⚠ Saisie interrompue" -ForegroundColor Yellow
                return $null
            }
            throw
        }
        
        # Étape 2 : Résumé et validation
        $validated = $false
        
        do {
            $allFieldsValid = Show-EnhancedSummary -FormData $formData -RequiredFields @{
                Nom = $true
                Prenom = $true
                Email = $true
                Departement = $true
            }
            
            if (-not $allFieldsValid) {
                Write-Host "⚠ Veuillez remplir tous les champs obligatoires" -ForegroundColor Red
                Write-Host ""
            }
            
            Write-Host "ACTIONS DISPONIBLES :" -ForegroundColor Cyan
            Write-Host " [V] Valider et enregistrer" -ForegroundColor Green
            Write-Host " [M] Modifier un champ" -ForegroundColor Yellow
            Write-Host " [R] Recommencer depuis le début" -ForegroundColor Magenta
            Write-Host " [A] Annuler et quitter" -ForegroundColor Red
            Write-Host ""
            
            $action = Read-Host "Votre choix"
            
            switch ($action.ToUpper()) {
                "V" {
                    if ($allFieldsValid) {
                        Write-Host "`n✓ Enregistrement des données..." -ForegroundColor Green
                        Start-Sleep -Seconds 1
                        $validated = $true
                    } else {
                        Write-Host "`n✗ Impossible de valider : champs obligatoires manquants" -ForegroundColor Red
                        Start-Sleep -Seconds 2
                    }
                }
                "M" {
                    $result = Edit-FieldByName -FormData $formData
                    if ($result -eq "Validated") {
                        $validated = $true
                    }
                    elseif ($result -eq "Cancelled") {
                        Write-Host "`n❌ Formulaire annulé" -ForegroundColor Red
                        return $null
                    }
                }
                "R" {
                    $confirm = Read-Host "`nRecommencer effacera toutes les données. Confirmer ? (O/N)"
                    if ($confirm -eq "O") {
                        Write-Host "🔄 Redémarrage du formulaire..." -ForegroundColor Yellow
                        Start-Sleep -Seconds 1
                        return Invoke-CompleteFormWorkflow -FormTitle $FormTitle
                    }
                }
                "A" {
                    $confirm = Read-Host "`nÊtes-vous sûr de vouloir annuler ? (O/N)"
                    if ($confirm -eq "O") {
                        Write-Host "`n❌ Opération annulée" -ForegroundColor Red
                        return $null
                    }
                }
                default {
                    Write-Host "`n✗ Option invalide" -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            }
        } while (-not $validated)
        
        # Étape 3 : Confirmation finale
        Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║     DONNÉES ENREGISTRÉES AVEC SUCCÈS   ║" -ForegroundColor Green
        Write-Host "╚═══════════════════════════════════════╝`n" -ForegroundColor Green
        
        return $formData
    }
    catch {
        Write-Host "`n❌ ERREUR : $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Utilisation
$resultat = Invoke-CompleteFormWorkflow -FormTitle "INSCRIPTION UTILISATEUR"

if ($null -ne $resultat) {
    Write-Host "Données collectées avec succès !"
    # Traiter $resultat...
} else {
    Write-Host "Aucune donnée collectée."
}
```

### Sauvegarde automatique en cas d'interruption

```powershell
function New-FormWithAutosave {
    param(
        [string]$AutosavePath = "$env:TEMP\form_autosave.json"
    )
    
    # Récupération des données sauvegardées si elles existent
    if (Test-Path $AutosavePath) {
        $restore = Read-Host "`n💾 Une sauvegarde automatique a été trouvée. Restaurer ? (O/N)"
        if ($restore -eq "O") {
            $formData = Get-Content $AutosavePath | ConvertFrom-Json -AsHashtable
            Write-Host "✓ Données restaurées !" -ForegroundColor Green
            Start-Sleep -Seconds 1
        } else {
            $formData = @{}
            Remove-Item $AutosavePath -Force
        }
    } else {
        $formData = @{}
    }
    
    # Collecte avec sauvegarde automatique après chaque champ
    try {
        if (-not $formData.Nom) {
            $formData.Nom = Get-InputWithCancel -Prompt "Nom"
            $formData | ConvertTo-Json | Set-Content $AutosavePath
        }
        
        if (-not $formData.Prenom) {
            $formData.Prenom = Get-InputWithCancel -Prompt "Prénom"
            $formData | ConvertTo-Json | Set-Content $AutosavePath
        }
        
        if (-not $formData.Email) {
            $formData.Email = Get-InputWithCancel -Prompt "Email"
            $formData | ConvertTo-Json | Set-Content $AutosavePath
        }
        
        # Une fois terminé, supprimer la sauvegarde
        if (Test-Path $AutosavePath) {
            Remove-Item $AutosavePath -Force
        }
        
        return $formData
    }
    catch {
        Write-Host "`n💾 Progression sauvegardée automatiquement" -ForegroundColor Cyan
        throw
    }
}
```

> [!tip] Astuces pour annulation et modification
> 
> - Toujours indiquer clairement comment annuler (touche Q, commande ANNULER, etc.)
> - Demander confirmation avant d'annuler pour éviter les pertes accidentelles
> - Permettre la modification champ par champ plutôt que de tout recommencer
> - Implémenter une sauvegarde automatique pour les formulaires longs
> - Fournir une option "Recommencer" distincte de "Annuler"
> - Afficher un résumé des modifications avant validation finale

---

## ⚠️ Pièges courants et bonnes pratiques {#pieges-bonnes-pratiques}

### Pièges fréquents

|Piège|Impact|Solution|
|---|---|---|
|**Pas de validation**|Données incorrectes en base|Valider chaque champ avec des règles appropriées|
|**Validation trop stricte**|Utilisateur bloqué|Permettre des formats alternatifs, suggérer des corrections|
|**Pas d'échappatoire**|Boucle infinie frustrante|Toujours offrir une option d'annulation|
|**Perte de données**|Recommencer tout le formulaire|Implémenter sauvegarde auto ou permettre modification|
|**Messages d'erreur vagues**|Utilisateur confus|Indiquer exactement ce qui ne va pas et comment corriger|
|**Pas de résumé**|Erreurs non détectées|Afficher résumé complet avant validation finale|
|**Mots de passe en clair**|Faille de sécurité|Utiliser `-AsSecureString` pour les mots de passe|
|**Pas de feedback visuel**|Utilisateur perdu|Utiliser couleurs, icônes, barres de progression|

### Bonnes pratiques essentielles

> [!info] Structure et organisation
> 
> - **Grouper les champs par thématique** : regroupez les informations connexes ensemble
> - **Indiquer la progression** : montrez à l'utilisateur où il en est (étape 3/5)
> - **Ordre logique** : commencez par les informations simples, finissez par les complexes
> - **Champs optionnels clairement marqués** : indiquez "(optionnel)" ou utilisez des couleurs différentes

> [!info] Validation et feedback
> 
> - **Valider au plus tôt** : ne pas attendre la fin du formulaire pour signaler les erreurs
> - **Messages explicites** : "Format invalide : utilisez xxx@yyy.zzz" plutôt que "Erreur"
> - **Feedback positif** : confirmer visuellement les saisies correctes (✓)
> - **Suggestions intelligentes** : proposer des corrections pour les erreurs courantes

> [!info] Expérience utilisateur
> 
> - **Toujours permettre l'annulation** : avec confirmation pour éviter les accidents
> - **Modification facile** : ne pas forcer à tout recommencer pour une erreur
> - **Résumé avant validation** : afficher toutes les données collectées
> - **Sauvegarde pour formulaires longs** : éviter la perte de données en cas d'interruption

> [!info] Sécurité et fiabilité
> 
> - **Mots de passe sécurisés** : toujours utiliser `Read-Host -AsSecureString`
> - **Validation côté script** : ne jamais faire confiance à l'entrée utilisateur
> - **Gestion des erreurs** : try/catch autour du formulaire complet
> - **Échappement des caractères spéciaux** : si les données sont utilisées dans des commandes

### Template de formulaire complet

```powershell
<#
.SYNOPSIS
    Template de formulaire complet avec toutes les bonnes pratiques
#>

function New-ProductionReadyForm {
    [CmdletBinding()]
    param(
        [switch]$EnableAutosave
    )
    
    # Configuration
    $autosavePath = "$env:TEMP\form_autosave.json"
    $formData = @{}
    
    try {
        # En-tête
        Clear-Host
        Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║     FORMULAIRE PROFESSIONNEL           ║" -ForegroundColor Cyan
        Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host "`n💡 Tapez 'Q' à tout moment pour annuler`n" -ForegroundColor DarkGray
        
        # Restauration si autosave activé
        if ($EnableAutosave -and (Test-Path $autosavePath)) {
            $restore = Read-Host "💾 Données précédentes trouvées. Restaurer ? (O/N)"
            if ($restore -eq "O") {
                $formData = Get-Content $autosavePath | ConvertFrom-Json -AsHashtable
            }
        }
        
        # ═══════════════════════════════════════════════════════
        # SECTION 1 : Informations personnelles
        # ═══════════════════════════════════════════════════════
        Write-Host "┌─ SECTION 1/3 : Informations personnelles" -ForegroundColor Yellow
        Write-Host "│" -ForegroundColor Yellow
        
        # Nom avec validation
        if (-not $formData.Nom) {
            do {
                $nom = Read-Host "│  Nom"
                if ($nom -eq "Q") { throw "UserCancelled" }
                
                if ([string]::IsNullOrWhiteSpace($nom)) {
                    Write-Host "│  ✗ Le nom ne peut pas être vide" -ForegroundColor Red
                } elseif ($nom.Length -lt 2) {
                    Write-Host "│  ✗ Le nom doit contenir au moins 2 caractères" -ForegroundColor Red
                } else {
                    $formData.Nom = $nom
                    Write-Host "│  ✓ Nom validé" -ForegroundColor Green
                }
            } while ([string]::IsNullOrWhiteSpace($formData.Nom))
            
            if ($EnableAutosave) {
                $formData | ConvertTo-Json | Set-Content $autosavePath
            }
        }
        
        # Email avec validation regex
        if (-not $formData.Email) {
            do {
                $email = Read-Host "│  Email"
                if ($email -eq "Q") { throw "UserCancelled" }
                
                if ($email -match '^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}) {
                    $formData.Email = $email
                    Write-Host "│  ✓ Email validé" -ForegroundColor Green
                } else {
                    Write-Host "│  ✗ Format invalide. Ex: user@domain.com" -ForegroundColor Red
                }
            } while (-not $formData.Email)
            
            if ($EnableAutosave) {
                $formData | ConvertTo-Json | Set-Content $autosavePath
            }
        }
        
        Write-Host "└─" -ForegroundColor Yellow
        Write-Host ""
        
        # ═══════════════════════════════════════════════════════
        # RÉSUMÉ ET VALIDATION
        # ═══════════════════════════════════════════════════════
        do {
            Clear-Host
            Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "║         RÉCAPITULATIF FINAL             ║" -ForegroundColor Green
            Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Green
            
            foreach ($key in $formData.Keys | Sort-Object) {
                Write-Host " ✓ " -ForegroundColor Green -NoNewline
                Write-Host ("{0,-15} : " -f $key) -ForegroundColor Cyan -NoNewline
                Write-Host $formData[$key] -ForegroundColor White
            }
            
            Write-Host "`n" + ("─" * 50)
            Write-Host " [V] Valider   [M] Modifier   [A] Annuler" -ForegroundColor Yellow
            Write-Host ("─" * 50) + "`n"
            
            $choice = Read-Host "Votre choix"
            
            switch ($choice.ToUpper()) {
                "V" {
                    # Suppression de l'autosave si validation
                    if ($EnableAutosave -and (Test-Path $autosavePath)) {
                        Remove-Item $autosavePath -Force
                    }
                    
                    Write-Host "`n✓ Données validées avec succès !" -ForegroundColor Green
                    return $formData
                }
                "M" {
                    $fieldName = Read-Host "`nChamp à modifier"
                    if ($formData.ContainsKey($fieldName)) {
                        $newValue = Read-Host "Nouvelle valeur"
                        $formData[$fieldName] = $newValue
                        Write-Host "✓ Modifié !" -ForegroundColor Green
                        Start-Sleep -Seconds 1
                    } else {
                        Write-Host "✗ Champ introuvable" -ForegroundColor Red
                        Start-Sleep -Seconds 2
                    }
                }
                "A" {
                    $confirm = Read-Host "`nConfirmer l'annulation ? (O/N)"
                    if ($confirm -eq "O") {
                        throw "UserCancelled"
                    }
                }
            }
        } while ($true)
    }
    catch {
        if ($_.Exception.Message -eq "UserCancelled") {
            Write-Host "`n❌ Formulaire annulé par l'utilisateur" -ForegroundColor Red
            
            # Nettoyage de l'autosave
            if ($EnableAutosave -and (Test-Path $autosavePath)) {
                Remove-Item $autosavePath -Force
            }
            
            return $null
        }
        
        Write-Host "`n❌ ERREUR : $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# ═══════════════════════════════════════════════════════
# UTILISATION
# ═══════════════════════════════════════════════════════

# Formulaire simple
$data = New-ProductionReadyForm

# Formulaire avec autosave
$data = New-ProductionReadyForm -EnableAutosave

# Traitement des données
if ($null -ne $data) {
    Write-Host "`nDonnées reçues :" -ForegroundColor Cyan
    $data | Format-Table -AutoSize
} else {
    Write-Host "Aucune donnée collectée" -ForegroundColor Yellow
}
```

> [!warning] Points de vigilance critiques
> 
> - **Ne jamais bloquer l'utilisateur** dans une boucle infinie sans échappatoire
> - **Toujours nettoyer les ressources** (fichiers temporaires, autosave) en cas d'erreur
> - **Valider AVANT traitement** : ne jamais faire confiance aux données brutes
> - **Tester avec des données extrêmes** : chaînes vides, très longues, caractères spéciaux
> - **Documenter les formats attendus** : l'utilisateur doit savoir quoi saisir

---

## 🎓 Récapitulatif

Les formulaires en console PowerShell permettent de créer des interfaces de collecte de données professionnelles et robustes. Les points clés à retenir :

1. **Champs multiples** : Organisez la collecte en sections logiques avec progression claire
2. **Validation temps réel** : Corrigez les erreurs immédiatement avec messages explicites
3. **Résumé avant validation** : Affichez toutes les données pour vérification finale
4. **Annulation et modification** : Offrez toujours des options de retour et correction

Un formulaire bien conçu combine ces quatre éléments pour offrir une expérience utilisateur fluide, fiable et professionnelle.

---

**📚 Cours rédigé pour Obsidian - Embellissement et présentation des scripts PowerShell**