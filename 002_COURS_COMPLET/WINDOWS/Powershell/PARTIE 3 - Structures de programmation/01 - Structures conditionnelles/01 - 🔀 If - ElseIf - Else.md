

## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 2  # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```
---

## 🎯 Introduction

Les structures conditionnelles `if`, `elseif` et `else` permettent d'exécuter différents blocs de code en fonction de conditions spécifiques. C'est l'un des piliers fondamentaux de la programmation et du scripting PowerShell.

> [!info] Pourquoi c'est important Les structures conditionnelles permettent à vos scripts de prendre des décisions intelligentes, d'adapter leur comportement selon le contexte, et de gérer différents scénarios automatiquement.

**Utilisations courantes :**

- Vérifier l'existence d'un fichier avant de le traiter
- Tester les permissions d'un utilisateur
- Valider des entrées utilisateur
- Gérer différents environnements (Dev, Test, Production)
- Implémenter une logique métier complexe

---

## 🔹 Syntaxe de base `if`

La structure `if` évalue une condition et exécute un bloc de code si cette condition est vraie (`$true`).

### Syntaxe minimale

```powershell
if (condition) {
    # Code à exécuter si la condition est vraie
}
```

### Exemple simple

```powershell
$age = 25

if ($age -ge 18) {
    Write-Host "Vous êtes majeur" -ForegroundColor Green
}
```

> [!tip] Astuce Même si votre bloc ne contient qu'une seule ligne, utilisez toujours les accolades `{}`. Cela améliore la lisibilité et évite les erreurs lors de futures modifications.

### Conditions booléennes directes

```powershell
$estActif = $true

if ($estActif) {
    Write-Host "Le service est actif"
}

# Vérifier l'inverse
if (-not $estActif) {
    Write-Host "Le service est inactif"
}

# Syntaxe alternative avec !
if (!$estActif) {
    Write-Host "Le service est inactif"
}
```

---

## ⚖️ Conditions et opérateurs de comparaison

PowerShell propose une syntaxe unique pour les opérateurs de comparaison, différente de nombreux autres langages.

### Tableau des opérateurs principaux

|Opérateur|Description|Exemple|Résultat|
|---|---|---|---|
|`-eq`|Égal à|`5 -eq 5`|`$true`|
|`-ne`|Différent de|`5 -ne 3`|`$true`|
|`-gt`|Supérieur à|`10 -gt 5`|`$true`|
|`-ge`|Supérieur ou égal à|`5 -ge 5`|`$true`|
|`-lt`|Inférieur à|`3 -lt 5`|`$true`|
|`-le`|Inférieur ou égal à|`5 -le 5`|`$true`|

### Opérateurs de comparaison de chaînes

|Opérateur|Description|Sensible à la casse|Exemple|
|---|---|---|---|
|`-like`|Correspondance avec wildcards|Non|`"Hello" -like "h*"` → `$true`|
|`-notlike`|Pas de correspondance|Non|`"Hello" -notlike "bye*"` → `$true`|
|`-match`|Correspondance regex|Non|`"abc123" -match "\d+"` → `$true`|
|`-notmatch`|Pas de correspondance regex|Non|`"abc" -notmatch "\d+"` → `$true`|
|`-contains`|Tableau contient élément|Non|`@(1,2,3) -contains 2` → `$true`|
|`-in`|Élément dans tableau|Non|`2 -in @(1,2,3)` → `$true`|

> [!warning] Sensibilité à la casse Par défaut, les opérateurs de comparaison de chaînes ne sont **pas sensibles à la casse**. Pour une comparaison sensible à la casse, ajoutez le préfixe `c` : `-ceq`, `-clike`, `-cmatch`, etc.

```powershell
# Insensible à la casse (défaut)
"Hello" -eq "hello"  # $true

# Sensible à la casse
"Hello" -ceq "hello"  # $false
"Hello" -ceq "Hello"  # $true
```

### Exemples pratiques

```powershell
# Comparaison numérique
$note = 15
if ($note -ge 10) {
    Write-Host "Admis !" -ForegroundColor Green
}

# Comparaison de chaînes
$nom = "Dupont"
if ($nom -eq "Dupont") {
    Write-Host "Utilisateur reconnu"
}

# Utilisation de -like avec wildcards
$fichier = "rapport_2024.xlsx"
if ($fichier -like "*.xlsx") {
    Write-Host "C'est un fichier Excel"
}

# Utilisation de -match avec regex
$email = "user@example.com"
if ($email -match "^[\w\.-]+@[\w\.-]+\.\w+$") {
    Write-Host "Format email valide"
}

# Vérification d'appartenance
$role = "Admin"
if ($role -in @("Admin", "SuperAdmin", "Root")) {
    Write-Host "Accès privilégié accordé"
}
```

> [!tip] Wildcards vs Regex
> 
> - `-like` utilise des wildcards simples : `*` (plusieurs caractères), `?` (un caractère)
> - `-match` utilise des expressions régulières complètes pour des patterns plus complexes

---

## 🔄 Bloc `else` pour alternative

Le bloc `else` permet d'exécuter du code lorsque la condition `if` est **fausse**.

### Syntaxe

```powershell
if (condition) {
    # Code si la condition est vraie
} else {
    # Code si la condition est fausse
}
```

### Exemples

```powershell
# Vérification simple
$age = 16

if ($age -ge 18) {
    Write-Host "Accès autorisé" -ForegroundColor Green
} else {
    Write-Host "Accès refusé - Vous devez avoir 18 ans" -ForegroundColor Red
}
```

```powershell
# Vérification d'existence de fichier
$cheminFichier = "C:\Data\config.json"

if (Test-Path $cheminFichier) {
    $config = Get-Content $cheminFichier | ConvertFrom-Json
    Write-Host "Configuration chargée avec succès"
} else {
    Write-Host "Fichier de configuration introuvable !" -ForegroundColor Yellow
    Write-Host "Utilisation de la configuration par défaut"
    # Créer une configuration par défaut
}
```

> [!example] Cas d'usage typique Le pattern `if-else` est idéal pour les décisions binaires : oui/non, existe/n'existe pas, actif/inactif, etc.

---

## 🔗 Chaînage avec `elseif`

Le mot-clé `elseif` permet de tester plusieurs conditions séquentiellement. Dès qu'une condition est vraie, le bloc correspondant est exécuté et les autres sont ignorés.

### Syntaxe

```powershell
if (condition1) {
    # Code si condition1 est vraie
} elseif (condition2) {
    # Code si condition1 est fausse et condition2 est vraie
} elseif (condition3) {
    # Code si condition1 et condition2 sont fausses et condition3 est vraie
} else {
    # Code si toutes les conditions sont fausses
}
```

> [!warning] Attention à l'orthographe C'est `elseif` en **un seul mot** en PowerShell, pas `else if` (deux mots).

### Exemple : système de notation

```powershell
$note = 14

if ($note -ge 16) {
    $mention = "Très bien"
    $couleur = "Green"
} elseif ($note -ge 14) {
    $mention = "Bien"
    $couleur = "Cyan"
} elseif ($note -ge 12) {
    $mention = "Assez bien"
    $couleur = "Yellow"
} elseif ($note -ge 10) {
    $mention = "Passable"
    $couleur = "DarkYellow"
} else {
    $mention = "Insuffisant"
    $couleur = "Red"
}

Write-Host "Note : $note/20 - Mention : $mention" -ForegroundColor $couleur
```

### Exemple : gestion des extensions de fichiers

```powershell
$fichier = "document.pdf"
$extension = [System.IO.Path]::GetExtension($fichier)

if ($extension -eq ".pdf") {
    Write-Host "📄 Document PDF détecté"
    # Traitement spécifique PDF
} elseif ($extension -in @(".doc", ".docx")) {
    Write-Host "📝 Document Word détecté"
    # Traitement spécifique Word
} elseif ($extension -in @(".xls", ".xlsx")) {
    Write-Host "📊 Tableur Excel détecté"
    # Traitement spécifique Excel
} elseif ($extension -in @(".jpg", ".jpeg", ".png", ".gif")) {
    Write-Host "🖼️ Image détectée"
    # Traitement spécifique images
} else {
    Write-Host "❓ Type de fichier non reconnu : $extension"
}
```

> [!tip] Ordre des conditions L'ordre des conditions `elseif` est important ! Les conditions sont évaluées de haut en bas, et seul le premier bloc dont la condition est vraie sera exécuté. Placez les conditions les plus spécifiques en premier.

---

## 🔺 Conditions multiples et imbriquées

### Conditions imbriquées

Vous pouvez imbriquer des structures `if` pour gérer des logiques plus complexes.

```powershell
$age = 25
$permis = $true

if ($age -ge 18) {
    if ($permis) {
        Write-Host "✅ Vous pouvez conduire" -ForegroundColor Green
    } else {
        Write-Host "❌ Vous devez obtenir votre permis" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Vous êtes trop jeune pour conduire" -ForegroundColor Red
}
```

### Alternative plus lisible avec opérateurs logiques

Dans de nombreux cas, les opérateurs logiques permettent d'éviter l'imbrication excessive.

```powershell
$age = 25
$permis = $true

if ($age -ge 18 -and $permis) {
    Write-Host "✅ Vous pouvez conduire" -ForegroundColor Green
} else {
    Write-Host "❌ Conditions non remplies pour conduire" -ForegroundColor Red
}
```

### Exemple complexe : validation d'utilisateur

```powershell
$utilisateur = "jdupont"
$motDePasse = "SecureP@ss123"
$estActif = $true
$tentatives = 2

if ($utilisateur -ne "" -and $motDePasse -ne "") {
    if ($estActif) {
        if ($tentatives -lt 3) {
            # Vérification des credentials (simplifié)
            if ($utilisateur -eq "jdupont" -and $motDePasse -eq "SecureP@ss123") {
                Write-Host "✅ Connexion réussie" -ForegroundColor Green
            } else {
                Write-Host "❌ Identifiants incorrects" -ForegroundColor Red
            }
        } else {
            Write-Host "🔒 Compte temporairement verrouillé" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⛔ Compte désactivé" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ Identifiant et mot de passe requis" -ForegroundColor Yellow
}
```

> [!warning] Éviter l'imbrication excessive Plus de 3 niveaux d'imbrication rendent le code difficile à lire et maintenir. Privilégiez les opérateurs logiques, la refactorisation en fonctions, ou le pattern "early return".

### Pattern "Early Return" pour réduire l'imbrication

```powershell
function Test-Connexion {
    param($utilisateur, $motDePasse, $estActif, $tentatives)
    
    # Vérifications progressives avec retours anticipés
    if ($utilisateur -eq "" -or $motDePasse -eq "") {
        Write-Host "⚠️ Identifiant et mot de passe requis" -ForegroundColor Yellow
        return
    }
    
    if (-not $estActif) {
        Write-Host "⛔ Compte désactivé" -ForegroundColor Red
        return
    }
    
    if ($tentatives -ge 3) {
        Write-Host "🔒 Compte temporairement verrouillé" -ForegroundColor Yellow
        return
    }
    
    # Vérification finale
    if ($utilisateur -eq "jdupont" -and $motDePasse -eq "SecureP@ss123") {
        Write-Host "✅ Connexion réussie" -ForegroundColor Green
    } else {
        Write-Host "❌ Identifiants incorrects" -ForegroundColor Red
    }
}
```

---

## 📐 Bonnes pratiques de lisibilité

### 1. Indentation cohérente

```powershell
# ✅ BON : Indentation claire
if ($condition) {
    Write-Host "Niveau 1"
    if ($autreCondition) {
        Write-Host "Niveau 2"
    }
}

# ❌ MAUVAIS : Pas d'indentation
if ($condition) {
Write-Host "Niveau 1"
if ($autreCondition) {
Write-Host "Niveau 2"
}
}
```

> [!tip] Standard d'indentation Utilisez 4 espaces par niveau d'indentation (norme PowerShell). Configurez votre éditeur pour convertir les tabulations en espaces.

### 2. Accolades systématiques

```powershell
# ✅ BON : Toujours utiliser des accolades
if ($x -gt 10) {
    Write-Host "X est grand"
}

# ❌ ÉVITER : Sans accolades (bien que valide)
if ($x -gt 10) Write-Host "X est grand"
```

### 3. Position des accolades

PowerShell accepte deux styles. Choisissez-en un et restez cohérent.

```powershell
# Style K&R (accolade ouvrante sur la même ligne) - RECOMMANDÉ
if ($condition) {
    # Code
} else {
    # Code
}

# Style Allman (accolade ouvrante sur nouvelle ligne)
if ($condition)
{
    # Code
}
else
{
    # Code
}
```

> [!tip] Convention recommandée Le style K&R est plus courant dans la communauté PowerShell et plus compact visuellement.

### 4. Espacement et lisibilité

```powershell
# ✅ BON : Espacement clair
if ($age -ge 18 -and $permis -eq $true) {
    Write-Host "Autorisé"
}

# ❌ MOINS LISIBLE : Trop compact
if($age-ge18-and$permis-eq$true){Write-Host "Autorisé"}
```

### 5. Nommer explicitement les conditions complexes

```powershell
# ✅ BON : Conditions nommées
$estMajeur = $age -ge 18
$possedePermis = $permis -eq $true
$aAssurance = $assurance -ne $null

if ($estMajeur -and $possedePermis -and $aAssurance) {
    Write-Host "Peut louer un véhicule"
}

# ❌ MOINS LISIBLE : Condition complexe en ligne
if ($age -ge 18 -and $permis -eq $true -and $assurance -ne $null) {
    Write-Host "Peut louer un véhicule"
}
```

### 6. Commentaires judicieux

```powershell
# Vérifier si l'utilisateur a les droits administrateur
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Exécution en tant qu'administrateur" -ForegroundColor Green
} else {
    Write-Host "Droits administrateur requis !" -ForegroundColor Red
    exit
}
```

---

## 🔀 Conditions complexes avec opérateurs logiques

Les opérateurs logiques permettent de combiner plusieurs conditions pour créer des tests sophistiqués.

### Opérateurs logiques disponibles

|Opérateur|Description|Exemple|Résultat|
|---|---|---|---|
|`-and`|ET logique (toutes les conditions doivent être vraies)|`$true -and $true`|`$true`|
|`-or`|OU logique (au moins une condition doit être vraie)|`$true -or $false`|`$true`|
|`-xor`|OU exclusif (une seule condition doit être vraie)|`$true -xor $false`|`$true`|
|`-not`|NON logique (inverse la condition)|`-not $false`|`$true`|
|`!`|NON logique (alias de `-not`)|`!$false`|`$true`|

### Opérateur `-and`

Toutes les conditions doivent être vraies.

```powershell
$age = 25
$permis = $true
$casierVierge = $true

if ($age -ge 21 -and $permis -and $casierVierge) {
    Write-Host "✅ Éligible pour location de véhicule de luxe"
}
```

### Opérateur `-or`

Au moins une condition doit être vraie.

```powershell
$role = "Développeur"

if ($role -eq "Admin" -or $role -eq "SuperAdmin" -or $role -eq "Développeur") {
    Write-Host "✅ Accès au serveur de développement accordé"
}

# Alternative plus élégante avec -in
if ($role -in @("Admin", "SuperAdmin", "Développeur")) {
    Write-Host "✅ Accès au serveur de développement accordé"
}
```

### Opérateur `-xor` (OU exclusif)

Une seule condition doit être vraie (pas les deux).

```powershell
$modeDebug = $true
$modeProduction = $false

if ($modeDebug -xor $modeProduction) {
    Write-Host "✅ Configuration valide - un seul mode actif"
} else {
    Write-Host "❌ Erreur : les deux modes ne peuvent être actifs simultanément"
}
```

### Opérateur `-not` ou `!`

Inverse la valeur booléenne.

```powershell
$fichierExiste = Test-Path "C:\temp\data.txt"

if (-not $fichierExiste) {
    Write-Host "Le fichier n'existe pas, création en cours..."
    New-Item -Path "C:\temp\data.txt" -ItemType File
}

# Syntaxe alternative avec !
if (!$fichierExiste) {
    Write-Host "Le fichier n'existe pas"
}
```

### Combinaison d'opérateurs et priorité

Les parenthèses permettent de contrôler l'ordre d'évaluation.

```powershell
$age = 25
$experience = 8
$diplome = "Master"
$certification = $true

# Sans parenthèses - peut être ambigu
if ($age -ge 23 -and $experience -ge 5 -or $diplome -eq "Master" -and $certification) {
    Write-Host "Condition satisfaite"
}

# Avec parenthèses - intention claire
if (($age -ge 23 -and $experience -ge 5) -or ($diplome -eq "Master" -and $certification)) {
    Write-Host "✅ Profil senior validé"
}
```

> [!warning] Priorité des opérateurs L'ordre de priorité est : `-not` (!) > `-and` > `-or` > `-xor`. Utilisez **toujours des parenthèses** pour rendre vos intentions explicites et éviter les erreurs.

### Exemple complexe : validation de politique de mot de passe

```powershell
$motDePasse = "SecureP@ss2024"
$longueurMin = 12
$contientMajuscule = $motDePasse -cmatch "[A-Z]"
$contientMinuscule = $motDePasse -cmatch "[a-z]"
$contientChiffre = $motDePasse -cmatch "\d"
$contientSpecial = $motDePasse -match "[@#$%^&*()_+\-=\[\]{}|;:,.<>?]"
$longueurOK = $motDePasse.Length -ge $longueurMin

if ($longueurOK -and $contientMajuscule -and $contientMinuscule -and $contientChiffre -and $contientSpecial) {
    Write-Host "✅ Mot de passe conforme à la politique de sécurité" -ForegroundColor Green
} else {
    Write-Host "❌ Mot de passe non conforme" -ForegroundColor Red
    
    # Détail des manquements
    if (-not $longueurOK) { Write-Host "  - Doit contenir au moins $longueurMin caractères" }
    if (-not $contientMajuscule) { Write-Host "  - Doit contenir au moins une majuscule" }
    if (-not $contientMinuscule) { Write-Host "  - Doit contenir au moins une minuscule" }
    if (-not $contientChiffre) { Write-Host "  - Doit contenir au moins un chiffre" }
    if (-not $contientSpecial) { Write-Host "  - Doit contenir au moins un caractère spécial" }
}
```

### Conditions avec tests d'existence

```powershell
$chemin = "C:\Logs"
$fichierLog = "$chemin\app.log"

# Vérifier que le dossier existe ET que le fichier n'existe pas
if ((Test-Path $chemin) -and (-not (Test-Path $fichierLog))) {
    Write-Host "Création du fichier de log..."
    New-Item -Path $fichierLog -ItemType File
}

# Vérifier que ni le dossier ni le fichier n'existent
if (-not (Test-Path $chemin) -and -not (Test-Path $fichierLog)) {
    Write-Host "Initialisation complète nécessaire"
    New-Item -Path $chemin -ItemType Directory
    New-Item -Path $fichierLog -ItemType File
}
```

---

## 💡 Exemples pratiques

### Exemple 1 : Vérification de service Windows

```powershell
$nomService = "wuauserv"  # Service Windows Update
$service = Get-Service -Name $nomService -ErrorAction SilentlyContinue

if ($service) {
    if ($service.Status -eq "Running") {
        Write-Host "✅ Le service $nomService est en cours d'exécution" -ForegroundColor Green
    } elseif ($service.Status -eq "Stopped") {
        Write-Host "⚠️ Le service $nomService est arrêté" -ForegroundColor Yellow
        Write-Host "Démarrage du service..."
        Start-Service -Name $nomService
    } else {
        Write-Host "⏸️ Le service $nomService est dans l'état : $($service.Status)" -ForegroundColor Cyan
    }
} else {
    Write-Host "❌ Le service $nomService n'existe pas sur ce système" -ForegroundColor Red
}
```

### Exemple 2 : Gestion d'espace disque

```powershell
$lecteur = "C:"
$disque = Get-PSDrive $lecteur
$pourcentageLibre = ($disque.Free / $disque.Used) * 100
$goLibre = [math]::Round($disque.Free / 1GB, 2)

Write-Host "Espace libre sur $lecteur : $goLibre Go ($([math]::Round($pourcentageLibre, 2))%)"

if ($pourcentageLibre -lt 10) {
    Write-Host "🔴 CRITIQUE : Espace disque très faible !" -ForegroundColor Red
    Write-Host "Action immédiate requise !" -ForegroundColor Red
} elseif ($pourcentageLibre -lt 20) {
    Write-Host "🟠 AVERTISSEMENT : Espace disque faible" -ForegroundColor Yellow
    Write-Host "Envisagez un nettoyage prochainement" -ForegroundColor Yellow
} elseif ($pourcentageLibre -lt 50) {
    Write-Host "🟡 INFO : Espace disque correct" -ForegroundColor Cyan
} else {
    Write-Host "🟢 OK : Espace disque suffisant" -ForegroundColor Green
}
```

### Exemple 3 : Validation d'adresse email

```powershell
function Test-EmailValide {
    param([string]$email)
    
    # Vérifications de base
    if ([string]::IsNullOrWhiteSpace($email)) {
        Write-Host "❌ Email vide" -ForegroundColor Red
        return $false
    }
    
    if ($email -notmatch "@") {
        Write-Host "❌ Email doit contenir @" -ForegroundColor Red
        return $false
    }
    
    # Regex simplifiée pour validation email
    $regexEmail = "^[\w\.-]+@[\w\.-]+\.\w{2,}$"
    
    if ($email -match $regexEmail) {
        $parties = $email -split "@"
        $domaine = $parties[1]
        
        # Vérifications supplémentaires
        if ($domaine -like "*..*") {
            Write-Host "❌ Domaine invalide (points consécutifs)" -ForegroundColor Red
            return $false
        }
        
        if ($email.Length -gt 254) {
            Write-Host "❌ Email trop long (max 254 caractères)" -ForegroundColor Red
            return $false
        }
        
        Write-Host "✅ Email valide : $email" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Format email invalide" -ForegroundColor Red
        return $false
    }
}

# Tests
Test-EmailValide "utilisateur@example.com"
Test-EmailValide "invalid.email"
Test-EmailValide "user@domain..com"
```

### Exemple 4 : Copie de sauvegarde intelligente

```powershell
$source = "C:\Data\projet"
$destination = "D:\Backups\projet_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$tailleMaxGo = 10

if (-not (Test-Path $source)) {
    Write-Host "❌ Dossier source introuvable : $source" -ForegroundColor Red
    exit
}

# Calculer la taille du dossier source
$tailleSource = (Get-ChildItem -Path $source -Recurse -File | Measure-Object -Property Length -Sum).Sum
$tailleSourceGo = [math]::Round($tailleSource / 1GB, 2)

Write-Host "Taille du dossier source : $tailleSourceGo Go"

if ($tailleSourceGo -gt $tailleMaxGo) {
    Write-Host "⚠️ Le dossier dépasse la limite de $tailleMaxGo Go" -ForegroundColor Yellow
    $reponse = Read-Host "Continuer quand même ? (O/N)"
    
    if ($reponse -ne "O") {
        Write-Host "Opération annulée" -ForegroundColor Yellow
        exit
    }
}

# Vérifier l'espace disponible sur la destination
$lecteurDest = (Get-Item $destination.Substring(0,2)).PSDrive
$espaceLibreGo = [math]::Round($lecteurDest.Free / 1GB, 2)

if ($espaceLibreGo -lt $tailleSourceGo) {
    Write-Host "❌ Espace insuffisant sur $($lecteurDest.Name):" -ForegroundColor Red
    Write-Host "   Requis : $tailleSourceGo Go / Disponible : $espaceLibreGo Go" -ForegroundColor Red
    exit
}

Write-Host "✅ Démarrage de la copie..." -ForegroundColor Green
Copy-Item -Path $source -Destination $destination -Recurse
Write-Host "✅ Sauvegarde terminée : $destination" -ForegroundColor Green
```

### Exemple 5 : Vérification de conformité système

```powershell
$rapportConformite = @()

# Vérifier la version de PowerShell
$versionPS = $PSVersionTable.PSVersion
if ($versionPS.Major -ge 5) {
    $rapportConformite += "✅ PowerShell version OK ($versionPS)"
} else {
    $rapportConformite += "❌ PowerShell version insuffisante ($versionPS) - Version 5+ requise"
}

# Vérifier les droits administrateur
$estAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($estAdmin) {
    $rapportConformite += "✅ Exécution avec droits administrateur"
} else {
    $rapportConformite += "⚠️ Exécution sans droits administrateur"
}

# Vérifier l'espace disque C:
$disqueC = Get-PSDrive C
$pourcentageLibre = ($disqueC.Free / $disqueC.Used) * 100
if ($pourcentageLibre -ge 20) {
    $rapportConformite += "✅ Espace disque C: suffisant ($([math]::Round($pourcentageLibre, 2))%)"
} else {
    $rapportConformite += "❌ Espace disque C: critique ($([math]::Round($pourcentageLibre, 2))%)"
}

# Vérifier la connexion réseau
$connexionInternet = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet
if ($connexionInternet) {
    $rapportConformite += "✅ Connexion Internet active"
} else {
    $rapportConformite += "❌ Pas de connexion Internet"
}

# Afficher le rapport
Write-Host "`n=== RAPPORT DE CONFORMITÉ ===" -ForegroundColor Cyan
foreach ($ligne in $rapportConformite) {
    if ($ligne -like "*✅*") {
        Write-Host $ligne -ForegroundColor Green
    } elseif ($ligne -like "*❌*") {
        Write-Host $ligne -ForegroundColor Red
    } else {
        Write-Host $ligne -ForegroundColor Yellow
    }
}
```

### Exemple 6 : Traitement de fichiers par lot

```powershell
$dossierSource = "C:\Documents\Images"
$dossierDestination = "C:\Documents\Images_Triees"

# Créer les sous-dossiers si nécessaire
$ssDossiers = @{
    "Petites" = "$dossierDestination\Petites"
    "Moyennes" = "$dossierDestination\Moyennes"
    "Grandes" = "$dossierDestination\Grandes"
    "TresGrandes" = "$dossierDestination\TresGrandes"
}

foreach ($dossier in $ssDossiers.Values) {
    if (-not (Test-Path $dossier)) {
        New-Item -Path $dossier -ItemType Directory | Out-Null
    }
}

# Traiter chaque fichier
$fichiers = Get-ChildItem -Path $dossierSource -File -Include *.jpg, *.png, *.gif

foreach ($fichier in $fichiers) {
    $tailleKo = [math]::Round($fichier.Length / 1KB, 2)
    
    if ($tailleKo -lt 100) {
        $destination = $ssDossiers["Petites"]
        $categorie = "Petite"
    } elseif ($tailleKo -lt 500) {
        $destination = $ssDossiers["Moyennes"]
        $categorie = "Moyenne"
    } elseif ($tailleKo -lt 2000) {
        $destination = $ssDossiers["Grandes"]
        $categorie = "Grande"
    } else {
        $destination = $ssDossiers["TresGrandes"]
        $categorie = "Très grande"
    }
    
    Write-Host "📁 $($fichier.Name) ($tailleKo Ko) → $categorie" -ForegroundColor Cyan
    Copy-Item -Path $fichier.FullName -Destination $destination
}

Write-Host "`n✅ Traitement terminé !" -ForegroundColor Green
```

### Exemple 7 : Menu interactif

```powershell
function Show-Menu {
    Clear-Host
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "     MENU PRINCIPAL" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Afficher les informations système"
    Write-Host "2. Vérifier l'espace disque"
    Write-Host "3. Lister les services arrêtés"
    Write-Host "4. Nettoyer les fichiers temporaires"
    Write-Host "5. Quitter"
    Write-Host ""
}

do {
    Show-Menu
    $choix = Read-Host "Sélectionnez une option (1-5)"
    
    if ($choix -eq "1") {
        Write-Host "`n📊 Informations système :" -ForegroundColor Green
        $os = Get-CimInstance Win32_OperatingSystem
        Write-Host "  Système : $($os.Caption)"
        Write-Host "  Version : $($os.Version)"
        Write-Host "  Uptime : $((Get-Date) - $os.LastBootUpTime)"
        Read-Host "`nAppuyez sur Entrée pour continuer"
        
    } elseif ($choix -eq "2") {
        Write-Host "`n💾 Espace disque :" -ForegroundColor Green
        Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } | ForEach-Object {
            $pourc = [math]::Round(($_.Free / $_.Used) * 100, 2)
            Write-Host "  $($_.Name): $pourc% libre"
        }
        Read-Host "`nAppuyez sur Entrée pour continuer"
        
    } elseif ($choix -eq "3") {
        Write-Host "`n🔴 Services arrêtés :" -ForegroundColor Green
        $servicesArretes = Get-Service | Where-Object { $_.Status -eq "Stopped" }
        if ($servicesArretes.Count -gt 0) {
            $servicesArretes | Select-Object -First 10 | ForEach-Object {
                Write-Host "  - $($_.DisplayName)"
            }
            Write-Host "`n  Total : $($servicesArretes.Count) services arrêtés"
        } else {
            Write-Host "  Aucun service arrêté"
        }
        Read-Host "`nAppuyez sur Entrée pour continuer"
        
    } elseif ($choix -eq "4") {
        Write-Host "`n🧹 Nettoyage des fichiers temporaires..." -ForegroundColor Green
        $tempPath = $env:TEMP
        $fichiers = Get-ChildItem -Path $tempPath -Recurse -File -ErrorAction SilentlyContinue
        $nombre = $fichiers.Count
        Write-Host "  $nombre fichiers temporaires trouvés"
        
        $confirmation = Read-Host "Voulez-vous les supprimer ? (O/N)"
        if ($confirmation -eq "O" -or $confirmation -eq "o") {
            Write-Host "  Suppression en cours..."
            # Logique de suppression ici
            Write-Host "  ✅ Nettoyage effectué" -ForegroundColor Green
        } else {
            Write-Host "  Opération annulée" -ForegroundColor Yellow
        }
        Read-Host "`nAppuyez sur Entrée pour continuer"
        
    } elseif ($choix -eq "5") {
        Write-Host "`n👋 Au revoir !" -ForegroundColor Cyan
        break
        
    } else {
        Write-Host "`n❌ Option invalide. Veuillez choisir entre 1 et 5." -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
    
} while ($true)
```

---

## 🎓 Pièges courants à éviter

### Piège 1 : Confusion entre `=` et `-eq`

```powershell
# ❌ ERREUR : = est pour l'affectation, pas la comparaison
if ($age = 18) {  # Ceci affecte 18 à $age et retourne toujours $true !
    Write-Host "Test"
}

# ✅ CORRECT : Utiliser -eq pour la comparaison
if ($age -eq 18) {
    Write-Host "Test"
}
```

### Piège 2 : Oublier la casse avec les chaînes

```powershell
$nom = "Dupont"

# ❌ Peut donner un résultat inattendu
if ($nom -eq "dupont") {  # $true car insensible à la casse par défaut
    Write-Host "Match"
}

# ✅ Si la casse est importante, utiliser -ceq
if ($nom -ceq "dupont") {  # $false car sensible à la casse
    Write-Host "Match exact"
}
```

### Piège 3 : Tester `$null` incorrectement

```powershell
$variable = $null

# ❌ INCORRECT : Place $null à gauche pour éviter les affectations accidentelles
if ($variable -eq $null) {
    Write-Host "Est null"
}

# ✅ MEILLEURE PRATIQUE : $null à gauche
if ($null -eq $variable) {
    Write-Host "Est null"
}

# ✅ ALTERNATIVE : Utiliser directement la variable
if (-not $variable) {
    Write-Host "Est null ou vide"
}
```

### Piège 4 : Confondre `-contains` et `-in`

```powershell
$liste = @("pomme", "banane", "orange")

# ❌ ERREUR : Ordre inversé
if ("pomme" -contains $liste) {  # Incorrect !
    Write-Host "Trouvé"
}

# ✅ CORRECT : -contains pour tableau.Contains(élément)
if ($liste -contains "pomme") {
    Write-Host "Trouvé"
}

# ✅ ALTERNATIF : -in pour élément.In(tableau)
if ("pomme" -in $liste) {
    Write-Host "Trouvé"
}
```

### Piège 5 : Oublier `-ErrorAction` dans les tests

```powershell
# ❌ RISQUE : Si le service n'existe pas, génère une erreur visible
$service = Get-Service -Name "ServiceInexistant"
if ($service) {
    Write-Host "Service trouvé"
}

# ✅ CORRECT : Masquer l'erreur et tester le résultat
$service = Get-Service -Name "ServiceInexistant" -ErrorAction SilentlyContinue
if ($service) {
    Write-Host "Service trouvé"
} else {
    Write-Host "Service introuvable"
}
```

---

## 🔧 Astuces avancées

### Astuce 1 : Test de multiples valeurs avec tableau

```powershell
$statut = "En cours"

# Au lieu de multiples -or
if ($statut -eq "En cours" -or $statut -eq "Actif" -or $statut -eq "Démarré") {
    Write-Host "État positif"
}

# ✅ Plus élégant avec -in
if ($statut -in @("En cours", "Actif", "Démarré")) {
    Write-Host "État positif"
}
```

### Astuce 2 : Opérateur ternaire (PowerShell 7+)

```powershell
# Syntaxe classique
if ($age -ge 18) {
    $message = "Majeur"
} else {
    $message = "Mineur"
}

# ✅ PowerShell 7+ : Opérateur ternaire
$message = $age -ge 18 ? "Majeur" : "Mineur"
```

### Astuce 3 : Switch comme alternative à if/elseif multiples

```powershell
$extension = ".pdf"

# Si vous avez beaucoup de cas à tester, considérez switch
# (mais cela sera couvert dans une autre section du cours)
```

> [!info] Note Pour des tests sur de nombreuses valeurs distinctes, l'instruction `switch` (couverte dans une autre section) peut être plus appropriée que des chaînes `if-elseif`.

### Astuce 4 : Validation avec pattern matching

```powershell
$numeroTelephone = "06 12 34 56 78"

# Validation format téléphone français
if ($numeroTelephone -match "^0[1-9]([ .-]?\d{2}){4}$") {
    Write-Host "✅ Numéro de téléphone valide"
} else {
    Write-Host "❌ Format incorrect"
}

# Extraction avec groupes de capture
$email = "utilisateur@example.com"
if ($email -match "^(.+)@(.+)$") {
    $utilisateur = $matches[1]
    $domaine = $matches[2]
    Write-Host "Utilisateur : $utilisateur"
    Write-Host "Domaine : $domaine"
}
```

### Astuce 5 : Court-circuit d'évaluation

Les opérateurs `-and` et `-or` utilisent l'évaluation en court-circuit :

```powershell
# -and s'arrête dès qu'une condition est fausse
$fichier = $null
if ($fichier -ne $null -and $fichier.Length -gt 0) {
    # Si $fichier est null, la deuxième condition n'est pas évaluée
    # Évite une erreur "propriété Length sur objet null"
    Write-Host "Fichier non vide"
}

# -or s'arrête dès qu'une condition est vraie
if ((Test-Path $chemin1) -or (Test-Path $chemin2)) {
    # Si $chemin1 existe, $chemin2 n'est pas testé
    Write-Host "Au moins un chemin existe"
}
```

---

## 📝 Récapitulatif

Les structures conditionnelles `if`, `elseif` et `else` sont essentielles en PowerShell pour :

✅ **Prendre des décisions** basées sur des conditions  
✅ **Adapter le comportement** d'un script selon le contexte  
✅ **Valider des données** avant de les traiter  
✅ **Gérer différents scénarios** dans une seule logique  
✅ **Implémenter une logique métier** complexe

### Points clés à retenir

|Concept|Point essentiel|
|---|---|
|**Syntaxe**|`if (condition) { code }` avec accolades obligatoires|
|**Opérateurs**|`-eq`, `-ne`, `-gt`, `-lt`, `-ge`, `-le` pour les comparaisons|
|**Chaînage**|`elseif` (un seul mot) pour tester plusieurs conditions|
|**Alternative**|`else` pour le cas par défaut|
|**Logique**|`-and`, `-or`, `-not` pour combiner des conditions|
|**Lisibilité**|Indentation, parenthèses, noms explicites|
|**Casse**|Opérateurs insensibles à la casse par défaut (préfixe `c` pour sensible)|

> [!tip] Conseil final Privilégiez la **clarté** sur la **concision**. Un code lisible et bien structuré est toujours préférable à un code compact mais difficile à comprendre. Vos collègues (et vous-même dans 6 mois) vous remercieront !

---

**Navigation du cours** : Vous maîtrisez maintenant les structures conditionnelles de base en PowerShell ! 🎉