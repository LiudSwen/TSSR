

## 📚 Table des matières

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

## 🎯 Introduction

La saisie utilisateur est un élément fondamental de l'interactivité dans les scripts PowerShell. Une saisie bien conçue améliore l'expérience utilisateur, réduit les erreurs et rend vos scripts plus robustes et professionnels.

> [!info] Pourquoi améliorer les saisies utilisateur ?
> 
> - **Prévention des erreurs** : La validation évite les données incorrectes
> - **Sécurité** : Le masquage protège les informations sensibles
> - **Ergonomie** : Les valeurs par défaut accélèrent l'utilisation
> - **Fiabilité** : Les timeouts empêchent les scripts de bloquer indéfiniment

---

## 🔍 Read-Host avec validation

### Concept de base

`Read-Host` est la cmdlet standard pour capturer une entrée utilisateur. La validation consiste à vérifier que la saisie respecte certains critères avant de continuer l'exécution du script.

### Syntaxe simple

```powershell
# Saisie basique
$nom = Read-Host "Entrez votre nom"

# Saisie avec message (Prompt)
$age = Read-Host -Prompt "Quel est votre âge ?"
```

### Validation avec boucles

La méthode la plus courante consiste à utiliser une boucle `do-while` ou `while` pour redemander la saisie jusqu'à ce qu'elle soit valide.

```powershell
# Validation - Ne pas laisser vide
do {
    $nom = Read-Host "Entrez votre nom (obligatoire)"
} while ([string]::IsNullOrWhiteSpace($nom))

Write-Host "Nom enregistré : $nom" -ForegroundColor Green
```

```powershell
# Validation - Réponse Oui/Non
do {
    $reponse = Read-Host "Voulez-vous continuer ? (O/N)"
    $reponse = $reponse.ToUpper()
} while ($reponse -ne 'O' -and $reponse -ne 'N')

if ($reponse -eq 'O') {
    Write-Host "Suite du traitement..." -ForegroundColor Green
}
```

### Validation avec compteur de tentatives

```powershell
# Limite le nombre de tentatives à 3
$tentatives = 0
$maxTentatives = 3
$saisieValide = $false

while (-not $saisieValide -and $tentatives -lt $maxTentatives) {
    $valeur = Read-Host "Entrez un nombre entre 1 et 10"
    
    if ($valeur -match '^\d+$' -and [int]$valeur -ge 1 -and [int]$valeur -le 10) {
        $saisieValide = $true
        Write-Host "✓ Saisie acceptée : $valeur" -ForegroundColor Green
    }
    else {
        $tentatives++
        $restant = $maxTentatives - $tentatives
        if ($restant -gt 0) {
            Write-Host "✗ Saisie invalide. Il vous reste $restant tentative(s)" -ForegroundColor Yellow
        }
    }
}

if (-not $saisieValide) {
    Write-Host "✗ Nombre maximal de tentatives atteint. Abandon." -ForegroundColor Red
    exit
}
```

> [!tip] Astuce : Validation élégante Utilisez une fonction dédiée pour réutiliser facilement votre logique de validation dans tout votre script.

```powershell
function Get-ValidatedInput {
    param(
        [string]$Prompt,
        [scriptblock]$ValidationScript,
        [string]$ErrorMessage = "Saisie invalide, veuillez réessayer"
    )
    
    do {
        $input = Read-Host $Prompt
        $isValid = & $ValidationScript $input
        
        if (-not $isValid) {
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    } while (-not $isValid)
    
    return $input
}

# Utilisation
$email = Get-ValidatedInput -Prompt "Entrez votre email" `
    -ValidationScript { param($e) $e -match '^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$' } `
    -ErrorMessage "Format d'email invalide"
```

---

## 🔒 Masquage de mot de passe

### Read-Host -AsSecureString

Le paramètre `-AsSecureString` permet de masquer la saisie à l'écran (affichage d'astérisques) et stocke le résultat dans un objet `SecureString`, qui est chiffré en mémoire.

```powershell
# Saisie sécurisée d'un mot de passe
$motDePasse = Read-Host "Entrez votre mot de passe" -AsSecureString

# Le résultat est un objet SecureString
Write-Host "Type : $($motDePasse.GetType().Name)"  # Affiche : SecureString
```

> [!warning] Important Un `SecureString` n'affiche pas le mot de passe en clair même si vous tentez de l'afficher avec `Write-Host`. C'est voulu pour la sécurité !

### Conversion SecureString vers texte clair

Parfois, vous devez convertir le `SecureString` en texte clair pour l'utiliser (par exemple, pour une authentification).

```powershell
# Méthode pour convertir SecureString en texte clair
$motDePasse = Read-Host "Entrez votre mot de passe" -AsSecureString

# Conversion en texte clair (à utiliser avec précaution)
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($motDePasse)
$motDePasseClair = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Utilisation
Write-Host "Mot de passe saisi : $motDePasseClair"

# IMPORTANT : Libérer la mémoire pour la sécurité
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
```

> [!warning] Sécurité critique Ne convertissez un `SecureString` en texte clair que lorsque c'est absolument nécessaire. Ne loguez jamais un mot de passe en clair dans un fichier ou à l'écran en production !

### Validation d'un mot de passe sécurisé

```powershell
function Get-SecurePassword {
    param(
        [int]$MinLength = 8
    )
    
    do {
        $password = Read-Host "Entrez un mot de passe (min. $MinLength caractères)" -AsSecureString
        
        # Convertir temporairement pour valider la longueur
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
        $plainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        $length = $plainText.Length
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        
        if ($length -lt $MinLength) {
            Write-Host "✗ Le mot de passe doit contenir au moins $MinLength caractères" -ForegroundColor Red
            $isValid = $false
        }
        else {
            $isValid = $true
        }
    } while (-not $isValid)
    
    return $password
}

# Utilisation
$mdp = Get-SecurePassword -MinLength 10
Write-Host "✓ Mot de passe accepté" -ForegroundColor Green
```

### Créer des credentials

Les `SecureString` sont souvent utilisés pour créer des objets `PSCredential` pour l'authentification.

```powershell
# Saisie complète d'un credential
$username = Read-Host "Nom d'utilisateur"
$password = Read-Host "Mot de passe" -AsSecureString

# Création d'un objet PSCredential
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

# Utilisation dans une commande
# Invoke-Command -ComputerName "Serveur01" -Credential $credential -ScriptBlock { Get-Process }
```

---

## 💡 Saisie avec valeur par défaut

### Pourquoi utiliser des valeurs par défaut ?

Les valeurs par défaut améliorent l'ergonomie en permettant à l'utilisateur de simplement appuyer sur Entrée pour accepter une valeur courante ou recommandée.

### Implémentation basique

```powershell
# Méthode simple avec affichage de la valeur par défaut
$defaut = "C:\Logs"
$chemin = Read-Host "Entrez le chemin de destination [$defaut]"

# Si l'utilisateur n'entre rien, utiliser la valeur par défaut
if ([string]::IsNullOrWhiteSpace($chemin)) {
    $chemin = $defaut
}

Write-Host "Chemin utilisé : $chemin" -ForegroundColor Cyan
```

### Fonction réutilisable avec valeur par défaut

```powershell
function Read-HostWithDefault {
    param(
        [string]$Prompt,
        [string]$DefaultValue
    )
    
    # Afficher le prompt avec la valeur par défaut
    $fullPrompt = "$Prompt [$DefaultValue]"
    $input = Read-Host $fullPrompt
    
    # Retourner la valeur par défaut si vide
    if ([string]::IsNullOrWhiteSpace($input)) {
        return $DefaultValue
    }
    else {
        return $input
    }
}

# Utilisation
$serveur = Read-HostWithDefault -Prompt "Nom du serveur" -DefaultValue "localhost"
$port = Read-HostWithDefault -Prompt "Port" -DefaultValue "8080"

Write-Host "`nConfiguration :" -ForegroundColor Green
Write-Host "  Serveur : $serveur"
Write-Host "  Port    : $port"
```

### Valeur par défaut avec validation

```powershell
function Get-ValidatedInputWithDefault {
    param(
        [string]$Prompt,
        [string]$DefaultValue,
        [scriptblock]$ValidationScript,
        [string]$ErrorMessage = "Saisie invalide"
    )
    
    $isValid = $false
    
    do {
        $fullPrompt = "$Prompt [$DefaultValue]"
        $input = Read-Host $fullPrompt
        
        # Utiliser la valeur par défaut si vide
        if ([string]::IsNullOrWhiteSpace($input)) {
            $input = $DefaultValue
        }
        
        # Valider
        $isValid = & $ValidationScript $input
        
        if (-not $isValid) {
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    } while (-not $isValid)
    
    return $input
}

# Exemple : Port réseau avec valeur par défaut et validation
$port = Get-ValidatedInputWithDefault `
    -Prompt "Port du serveur" `
    -DefaultValue "80" `
    -ValidationScript { param($p) $p -match '^\d+$' -and [int]$p -ge 1 -and [int]$p -le 65535 } `
    -ErrorMessage "Le port doit être un nombre entre 1 et 65535"

Write-Host "Port configuré : $port" -ForegroundColor Green
```

> [!tip] Astuce : Choix multiples avec défaut Pour des choix prédéfinis, affichez les options et marquez celle par défaut.

```powershell
function Select-OptionWithDefault {
    param(
        [string]$Prompt,
        [string[]]$Options,
        [int]$DefaultIndex = 0
    )
    
    Write-Host "`n$Prompt" -ForegroundColor Cyan
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $marker = if ($i -eq $DefaultIndex) { ">" } else { " " }
        Write-Host "  $marker [$($i+1)] $($Options[$i])"
    }
    
    $choix = Read-Host "`nVotre choix [défaut: $($DefaultIndex+1)]"
    
    if ([string]::IsNullOrWhiteSpace($choix)) {
        return $Options[$DefaultIndex]
    }
    
    $index = [int]$choix - 1
    if ($index -ge 0 -and $index -lt $Options.Count) {
        return $Options[$index]
    }
    else {
        Write-Host "Choix invalide, utilisation de la valeur par défaut" -ForegroundColor Yellow
        return $Options[$DefaultIndex]
    }
}

# Utilisation
$environnement = Select-OptionWithDefault `
    -Prompt "Sélectionnez l'environnement" `
    -Options @("Développement", "Test", "Production") `
    -DefaultIndex 0

Write-Host "`nEnvironnement sélectionné : $environnement" -ForegroundColor Green
```

---

## ✅ Validation de format

### Validation numérique

```powershell
# Vérifier qu'une saisie est un nombre
do {
    $nombre = Read-Host "Entrez un nombre entier"
    $isNumeric = $nombre -match '^\d+$'
    
    if (-not $isNumeric) {
        Write-Host "✗ Veuillez entrer uniquement des chiffres" -ForegroundColor Red
    }
} while (-not $isNumeric)

$nombreEntier = [int]$nombre
Write-Host "✓ Nombre valide : $nombreEntier" -ForegroundColor Green
```

```powershell
# Nombre avec plage de valeurs
do {
    $age = Read-Host "Entrez votre âge (0-120)"
    
    if ($age -match '^\d+$') {
        $ageInt = [int]$age
        $isValid = $ageInt -ge 0 -and $ageInt -le 120
        
        if (-not $isValid) {
            Write-Host "✗ L'âge doit être entre 0 et 120" -ForegroundColor Red
        }
    }
    else {
        Write-Host "✗ Veuillez entrer un nombre valide" -ForegroundColor Red
        $isValid = $false
    }
} while (-not $isValid)

Write-Host "✓ Âge enregistré : $ageInt ans" -ForegroundColor Green
```

### Validation d'email

```powershell
# Validation basique d'email avec regex
do {
    $email = Read-Host "Entrez votre adresse email"
    $isValidEmail = $email -match '^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'
    
    if (-not $isValidEmail) {
        Write-Host "✗ Format d'email invalide" -ForegroundColor Red
    }
} while (-not $isValidEmail)

Write-Host "✓ Email valide : $email" -ForegroundColor Green
```

> [!info] Explication du pattern regex
> 
> - `^` : Début de la chaîne
> - `[\w-\.]+` : Un ou plusieurs caractères alphanumériques, tirets ou points
> - `@` : Le symbole arobase obligatoire
> - `([\w-]+\.)+` : Un ou plusieurs groupes de caractères suivis d'un point (domaine)
> - `[\w-]{2,4}$` : Extension du domaine (2 à 4 caractères)

### Validation d'URL

```powershell
# Validation d'URL HTTP/HTTPS
do {
    $url = Read-Host "Entrez une URL"
    $isValidUrl = $url -match '^https?://[\w\-\.]+(:\d+)?(/.*)?$'
    
    if (-not $isValidUrl) {
        Write-Host "✗ URL invalide. Format attendu : http(s)://domaine.com" -ForegroundColor Red
    }
} while (-not $isValidUrl)

Write-Host "✓ URL valide : $url" -ForegroundColor Green
```

### Validation de chemin de fichier

```powershell
# Vérifier qu'un chemin existe
do {
    $chemin = Read-Host "Entrez le chemin d'un dossier"
    $existe = Test-Path $chemin -PathType Container
    
    if (-not $existe) {
        Write-Host "✗ Le dossier n'existe pas" -ForegroundColor Red
    }
} while (-not $existe)

Write-Host "✓ Dossier valide : $chemin" -ForegroundColor Green
```

```powershell
# Validation avec création optionnelle
do {
    $chemin = Read-Host "Entrez le chemin de destination"
    $existe = Test-Path $chemin
    
    if (-not $existe) {
        $creer = Read-Host "Le dossier n'existe pas. Le créer ? (O/N)"
        if ($creer -eq 'O') {
            try {
                New-Item -Path $chemin -ItemType Directory -Force | Out-Null
                Write-Host "✓ Dossier créé avec succès" -ForegroundColor Green
                $existe = $true
            }
            catch {
                Write-Host "✗ Impossible de créer le dossier : $_" -ForegroundColor Red
            }
        }
    }
    else {
        $existe = $true
    }
} while (-not $existe)

Write-Host "✓ Chemin validé : $chemin" -ForegroundColor Green
```

### Validation de date

```powershell
# Validation de date au format JJ/MM/AAAA
do {
    $dateStr = Read-Host "Entrez une date (JJ/MM/AAAA)"
    
    try {
        $date = [DateTime]::ParseExact($dateStr, "dd/MM/yyyy", $null)
        $isValid = $true
        Write-Host "✓ Date valide : $($date.ToString('dddd dd MMMM yyyy'))" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Format de date invalide. Utilisez JJ/MM/AAAA" -ForegroundColor Red
        $isValid = $false
    }
} while (-not $isValid)
```

### Validation d'adresse IP

```powershell
# Validation IPv4
do {
    $ip = Read-Host "Entrez une adresse IP"
    
    # Pattern regex pour IPv4
    $pattern = '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    $isValid = $ip -match $pattern
    
    if (-not $isValid) {
        Write-Host "✗ Adresse IP invalide. Format : xxx.xxx.xxx.xxx (0-255)" -ForegroundColor Red
    }
} while (-not $isValid)

Write-Host "✓ IP valide : $ip" -ForegroundColor Green
```

### Table récapitulative des patterns courants

|Type de validation|Pattern Regex|Exemple|
|---|---|---|
|Nombre entier|`^\d+$`|123|
|Nombre décimal|`^\d+([.,]\d+)?$`|12.34|
|Email|`^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`|user@example.com|
|Téléphone FR|`^0[1-9](\d{2}){4}$`|0612345678|
|Code postal FR|`^\d{5}$`|75001|
|URL|`^https?://[\w\-\.]+`|https://example.com|
|IPv4|`^(\d{1,3}\.){3}\d{1,3}$`|192.168.1.1|

---

## ⏱️ Timeout sur les saisies

### Pourquoi utiliser un timeout ?

Un timeout évite qu'un script reste bloqué indéfiniment en attente d'une saisie utilisateur, particulièrement utile dans les scripts automatisés ou les tâches planifiées.

> [!warning] Limitation de Read-Host `Read-Host` ne possède pas de paramètre natif pour gérer un timeout. Il faut utiliser des techniques alternatives.

### Méthode 1 : Utilisation de System.Console

```powershell
function Read-HostWithTimeout {
    param(
        [string]$Prompt,
        [int]$TimeoutSeconds = 30,
        [string]$DefaultValue = ""
    )
    
    Write-Host "$Prompt (Timeout: ${TimeoutSeconds}s)" -NoNewline
    Write-Host " [$DefaultValue] " -ForegroundColor Yellow -NoNewline
    
    $endTime = (Get-Date).AddSeconds($TimeoutSeconds)
    $input = ""
    
    while ((Get-Date) -lt $endTime) {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            
            if ($key.Key -eq 'Enter') {
                Write-Host ""
                break
            }
            elseif ($key.Key -eq 'Backspace') {
                if ($input.Length -gt 0) {
                    $input = $input.Substring(0, $input.Length - 1)
                    Write-Host "`b `b" -NoNewline
                }
            }
            else {
                $input += $key.KeyChar
                Write-Host $key.KeyChar -NoNewline
            }
        }
        
        Start-Sleep -Milliseconds 50
    }
    
    if ([string]::IsNullOrEmpty($input)) {
        Write-Host "`nTimeout atteint. Utilisation de la valeur par défaut : $DefaultValue" -ForegroundColor Yellow
        return $DefaultValue
    }
    
    return $input
}

# Utilisation
$nom = Read-HostWithTimeout -Prompt "Entrez votre nom" -TimeoutSeconds 10 -DefaultValue "Utilisateur"
Write-Host "`nNom utilisé : $nom" -ForegroundColor Green
```

### Méthode 2 : Jobs en arrière-plan (plus simple)

```powershell
function Read-HostTimeout {
    param(
        [string]$Prompt,
        [int]$TimeoutSeconds = 30,
        [string]$DefaultValue = ""
    )
    
    # Créer un job qui attend la saisie
    $job = Start-Job -ScriptBlock {
        param($p)
        Read-Host $p
    } -ArgumentList $Prompt
    
    # Attendre avec timeout
    $completed = Wait-Job $job -Timeout $TimeoutSeconds
    
    if ($completed) {
        $result = Receive-Job $job
        Remove-Job $job
        return $result
    }
    else {
        Stop-Job $job
        Remove-Job $job
        Write-Host "`nTimeout atteint. Utilisation de la valeur par défaut." -ForegroundColor Yellow
        return $DefaultValue
    }
}

# Utilisation
Write-Host "Vous avez 10 secondes pour saisir..." -ForegroundColor Cyan
$reponse = Read-HostTimeout -Prompt "Continuer ? (O/N)" -TimeoutSeconds 10 -DefaultValue "O"
Write-Host "Réponse : $reponse" -ForegroundColor Green
```

> [!info] Avantages et inconvénients des méthodes **Méthode Console** : Plus de contrôle, affichage en temps réel, mais code plus complexe **Méthode Jobs** : Plus simple à implémenter, mais l'affichage du prompt peut être moins fluide

### Timeout avec compte à rebours visuel

```powershell
function Read-HostWithCountdown {
    param(
        [string]$Prompt,
        [int]$TimeoutSeconds = 30,
        [string]$DefaultValue = ""
    )
    
    $job = Start-Job -ScriptBlock {
        param($p)
        Read-Host $p
    } -ArgumentList $Prompt
    
    $secondsLeft = $TimeoutSeconds
    
    while ($secondsLeft -gt 0) {
        Write-Host "`r$Prompt [Timeout: ${secondsLeft}s] " -NoNewline -ForegroundColor Cyan
        
        $completed = Wait-Job $job -Timeout 1
        
        if ($completed) {
            Write-Host ""
            $result = Receive-Job $job
            Remove-Job $job
            return $result
        }
        
        $secondsLeft--
    }
    
    Stop-Job $job
    Remove-Job $job
    Write-Host "`n✗ Timeout ! Valeur par défaut utilisée : $DefaultValue" -ForegroundColor Yellow
    return $DefaultValue
}

# Utilisation
$choix = Read-HostWithCountdown -Prompt "Choisir l'environnement (Dev/Prod)" `
                                 -TimeoutSeconds 15 `
                                 -DefaultValue "Dev"
Write-Host "Environnement : $choix" -ForegroundColor Green
```

### Timeout pour confirmation critique

```powershell
function Get-ConfirmationWithTimeout {
    param(
        [string]$Message,
        [int]$TimeoutSeconds = 10
    )
    
    Write-Host "`n$Message" -ForegroundColor Yellow
    Write-Host "Cette action nécessite une confirmation dans les ${TimeoutSeconds} secondes." -ForegroundColor Yellow
    
    $reponse = Read-HostTimeout -Prompt "Confirmer ? (OUI pour continuer)" `
                                -TimeoutSeconds $TimeoutSeconds `
                                -DefaultValue "NON"
    
    return ($reponse -eq "OUI")
}

# Utilisation dans un script de suppression
Write-Host "Préparation de la suppression de 150 fichiers..." -ForegroundColor Red

if (Get-ConfirmationWithTimeout -Message "⚠️ ATTENTION : Action irréversible !" -TimeoutSeconds 15) {
    Write-Host "✓ Confirmation reçue. Suppression en cours..." -ForegroundColor Green
    # Exécuter l'action
}
else {
    Write-Host "✗ Opération annulée ou timeout" -ForegroundColor Yellow
}
```

---

## ⚠️ Pièges courants

### 1. Ne pas valider les entrées vides

> [!warning] Piège Oublier de vérifier si l'utilisateur a simplement appuyé sur Entrée sans rien saisir.

```powershell
# ❌ MAUVAIS - Pas de validation
$nom = Read-Host "Votre nom"
Write-Host "Bonjour $nom"  # Affichera "Bonjour " si vide

# ✅ BON - Avec validation
do {
    $nom = Read-Host "Votre nom"
} while ([string]::IsNullOrWhiteSpace($nom))
Write-Host "Bonjour $nom"
```

### 2. Conversion de type sans vérification

> [!warning] Piège Convertir une saisie en nombre sans vérifier qu'elle est valide provoque des erreurs.

```powershell
# ❌ MAUVAIS - Crash si l'utilisateur entre du texte
$age = [int](Read-Host "Votre âge")

# ✅ BON - Validation avant conversion
do {
    $ageStr = Read-Host "Votre âge"
    $isValid = $ageStr -match '^\d+$'
    if (-not $isValid) {
        Write-Host "Entrez un nombre valide" -ForegroundColor Red
    }
} while (-not $isValid)
$age = [int]$ageStr
```

### 3. Oublier de nettoyer les SecureString

> [!warning] Piège mémoire Ne pas libérer la mémoire après conversion d'un SecureString peut laisser le mot de passe en clair en mémoire.

```powershell
# ❌ RISQUE - Le mot de passe reste en mémoire
$mdp = Read-Host "Mot de passe" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($mdp)
$plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
# Utilisation...

# ✅ BON - Libération de la mémoire
$mdp = Read-Host "Mot de passe" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($mdp)
$plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
# Utilisation...
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
```

### 4. Regex mal échappées ou trop permissives

> [!warning] Piège validation Une regex mal conçue peut accepter des données invalides ou rejeter des données valides.

```powershell
# ❌ TROP PERMISSIF - Accepte "user@com"
$email -match '@'

# ❌ TROP RESTRICTIF - Rejette "jean-paul@site.fr"
$email -match '^[a-z]+@[a-z]+\.[a-z]+$'

# ✅ BON - Équilibré et fonctionnel
$email -match '^[\w\.-]+@[\w\.-]+\.\w{2,}$'
```

### 5. Boucles infinies sans échappatoire

> [!warning] Piège UX Une boucle de validation sans option de sortie peut frustrer l'utilisateur et bloquer le script.

```powershell
# ❌ MAUVAIS - Pas d'échappatoire
do {
    $valeur = Read-Host "Entrez un nombre"
} while ($valeur -notmatch '^\d+)
# L'utilisateur ne peut jamais annuler !

# ✅ BON - Avec option d'annulation
do {
    $valeur = Read-Host "Entrez un nombre (ou 'Q' pour quitter)"
    if ($valeur -eq 'Q') {
        Write-Host "Opération annulée" -ForegroundColor Yellow
        exit
    }
} while ($valeur -notmatch '^\d+)
```

### 6. Ne pas gérer la casse pour les réponses O/N

> [!warning] Piège ergonomie Les utilisateurs peuvent taper 'o', 'O', 'oui', etc. Il faut normaliser l'entrée.

```powershell
# ❌ MAUVAIS - Sensible à la casse
$reponse = Read-Host "Continuer ? (O/N)"
if ($reponse -eq 'O') { }  # Ne fonctionne pas si l'utilisateur tape 'o'

# ✅ BON - Insensible à la casse
$reponse = Read-Host "Continuer ? (O/N)"
$reponse = $reponse.ToUpper()
if ($reponse -eq 'O') { }
```

### 7. Messages d'erreur non informatifs

> [!warning] Piège communication Des messages vagues frustrent l'utilisateur qui ne sait pas ce qui est attendu.

```powershell
# ❌ MAUVAIS
Write-Host "Erreur" -ForegroundColor Red

# ✅ BON
Write-Host "✗ Format invalide. Entrez un email valide (exemple: user@domain.com)" -ForegroundColor Red
```

### 8. Timeout sans valeur par défaut

> [!warning] Piège automatisation Un timeout sans valeur par défaut rend le script inutilisable en mode automatisé.

```powershell
# ❌ RISQUÉ - Retourne une chaîne vide
$reponse = Read-HostTimeout -Prompt "Confirmer ?" -TimeoutSeconds 10

# ✅ BON - Comportement prévisible
$reponse = Read-HostTimeout -Prompt "Confirmer ?" -TimeoutSeconds 10 -DefaultValue "Non"
```

### 9. Oublier de trimmer les espaces

> [!warning] Piège validation Les espaces avant/après peuvent invalider des comparaisons ou des chemins.

```powershell
# ❌ MAUVAIS
$choix = Read-Host "Votre choix (A/B/C)"
if ($choix -eq 'A') { }  # Échoue si l'utilisateur tape "A " avec un espace

# ✅ BON
$choix = Read-Host "Votre choix (A/B/C)"
$choix = $choix.Trim().ToUpper()
if ($choix -eq 'A') { }
```

### 10. Valider après utilisation au lieu d'avant

> [!warning] Piège logique Utiliser une donnée avant de la valider peut causer des erreurs inattendues.

```powershell
# ❌ MAUVAIS - Utilise avant de valider
$chemin = Read-Host "Chemin du fichier"
Get-Content $chemin  # Plante si le fichier n'existe pas

# ✅ BON - Valide avant d'utiliser
do {
    $chemin = Read-Host "Chemin du fichier"
    $existe = Test-Path $chemin
    if (-not $existe) {
        Write-Host "✗ Fichier introuvable" -ForegroundColor Red
    }
} while (-not $existe)
Get-Content $chemin
```

---

## 💎 Bonnes pratiques récapitulatives

### Checklist de validation robuste

- ✅ **Toujours valider** : Ne jamais faire confiance à une saisie utilisateur
- ✅ **Messages clairs** : Indiquer exactement ce qui est attendu et pourquoi ça échoue
- ✅ **Valeurs par défaut** : Proposer des choix sensés pour améliorer l'UX
- ✅ **Option de sortie** : Permettre à l'utilisateur d'annuler (Q, ESC, etc.)
- ✅ **Limite de tentatives** : Éviter les boucles infinies frustrantes
- ✅ **Feedback visuel** : Utiliser les couleurs et symboles (✓, ✗, ⚠️)
- ✅ **Normalisation** : Trim(), ToUpper()/ToLower() pour les comparaisons
- ✅ **Sécurité** : Utiliser SecureString pour les données sensibles
- ✅ **Documentation** : Commenter les regex complexes et la logique de validation

### Modèle de fonction complète

```powershell
function Get-UserInput {
    <#
    .SYNOPSIS
        Fonction générique de saisie utilisateur avec validation complète
    
    .PARAMETER Prompt
        Le message affiché à l'utilisateur
    
    .PARAMETER DefaultValue
        Valeur par défaut si l'utilisateur appuie sur Entrée
    
    .PARAMETER ValidationScript
        ScriptBlock de validation personnalisée
    
    .PARAMETER ErrorMessage
        Message d'erreur si la validation échoue
    
    .PARAMETER MaxAttempts
        Nombre maximum de tentatives (0 = illimité)
    
    .PARAMETER IsSecure
        Si $true, masque la saisie (mot de passe)
    
    .PARAMETER AllowCancel
        Si $true, permet d'annuler avec 'Q'
    
    .EXAMPLE
        $age = Get-UserInput -Prompt "Votre âge" -ValidationScript {param($x) $x -match '^\d+}
    #>
    
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,
        
        [string]$DefaultValue = "",
        
        [scriptblock]$ValidationScript = {param($x) $true},
        
        [string]$ErrorMessage = "Saisie invalide. Veuillez réessayer.",
        
        [int]$MaxAttempts = 0,
        
        [switch]$IsSecure,
        
        [switch]$AllowCancel
    )
    
    $attempts = 0
    $isValid = $false
    
    # Construction du prompt complet
    $fullPrompt = $Prompt
    if ($DefaultValue) {
        $fullPrompt += " [$DefaultValue]"
    }
    if ($AllowCancel) {
        $fullPrompt += " (Q pour quitter)"
    }
    
    while (-not $isValid) {
        # Vérifier le nombre de tentatives
        if ($MaxAttempts -gt 0 -and $attempts -ge $MaxAttempts) {
            Write-Host "✗ Nombre maximum de tentatives atteint." -ForegroundColor Red
            return $null
        }
        
        # Saisie
        if ($IsSecure) {
            $secureInput = Read-Host $fullPrompt -AsSecureString
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureInput)
            $input = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        }
        else {
            $input = Read-Host $fullPrompt
        }
        
        # Trim et gestion annulation
        $input = $input.Trim()
        
        if ($AllowCancel -and $input -eq 'Q') {
            Write-Host "✗ Opération annulée par l'utilisateur" -ForegroundColor Yellow
            return $null
        }
        
        # Valeur par défaut si vide
        if ([string]::IsNullOrWhiteSpace($input) -and $DefaultValue) {
            $input = $DefaultValue
        }
        
        # Validation
        try {
            $isValid = & $ValidationScript $input
            
            if ($isValid) {
                Write-Host "✓ Saisie acceptée" -ForegroundColor Green
                return $input
            }
            else {
                $attempts++
                Write-Host "✗ $ErrorMessage" -ForegroundColor Red
                
                if ($MaxAttempts -gt 0) {
                    $remaining = $MaxAttempts - $attempts
                    Write-Host "   Tentatives restantes : $remaining" -ForegroundColor Yellow
                }
            }
        }
        catch {
            $attempts++
            Write-Host "✗ Erreur de validation : $_" -ForegroundColor Red
        }
    }
}

# ═══════════════════════════════════════════════════════════════
# EXEMPLES D'UTILISATION
# ═══════════════════════════════════════════════════════════════

# Exemple 1 : Email avec valeur par défaut
$email = Get-UserInput `
    -Prompt "Adresse email" `
    -DefaultValue "admin@example.com" `
    -ValidationScript {param($e) $e -match '^[\w\.-]+@[\w\.-]+\.\w{2,}} `
    -ErrorMessage "Format d'email invalide" `
    -MaxAttempts 3 `
    -AllowCancel

# Exemple 2 : Mot de passe sécurisé
$password = Get-UserInput `
    -Prompt "Mot de passe" `
    -IsSecure `
    -ValidationScript {param($p) $p.Length -ge 8} `
    -ErrorMessage "Le mot de passe doit contenir au moins 8 caractères" `
    -MaxAttempts 3

# Exemple 3 : Nombre avec plage
$port = Get-UserInput `
    -Prompt "Port serveur" `
    -DefaultValue "8080" `
    -ValidationScript {param($p) $p -match '^\d+ -and [int]$p -ge 1 -and [int]$p -le 65535} `
    -ErrorMessage "Le port doit être un nombre entre 1 et 65535" `
    -AllowCancel

# Exemple 4 : Choix Oui/Non
$continuer = Get-UserInput `
    -Prompt "Continuer l'installation ? (O/N)" `
    -DefaultValue "O" `
    -ValidationScript {param($r) $r.ToUpper() -in @('O','N')} `
    -ErrorMessage "Répondez par O (Oui) ou N (Non)"

if ($continuer.ToUpper() -eq 'O') {
    Write-Host "Installation en cours..." -ForegroundColor Cyan
}
```

---

## 🎯 Conclusion

La maîtrise de la saisie utilisateur améliorée transforme vos scripts PowerShell en outils professionnels et robustes. Les techniques présentées dans ce cours permettent de :

- **Prévenir les erreurs** grâce à une validation rigoureuse
- **Sécuriser les données sensibles** avec les SecureString
- **Améliorer l'expérience utilisateur** avec des valeurs par défaut intelligentes
- **Automatiser intelligemment** avec des timeouts et valeurs par défaut
- **Créer des scripts maintenables** avec des fonctions réutilisables

> [!tip] Conseil final Créez une bibliothèque de fonctions de saisie personnalisées que vous pourrez réutiliser dans tous vos projets. Cela vous fera gagner un temps considérable et garantira une expérience utilisateur cohérente.

---

**📘 Prochain module** : Nous aborderons la création de menus interactifs complets avec navigation, sous-menus et gestion avancée des choix utilisateur.