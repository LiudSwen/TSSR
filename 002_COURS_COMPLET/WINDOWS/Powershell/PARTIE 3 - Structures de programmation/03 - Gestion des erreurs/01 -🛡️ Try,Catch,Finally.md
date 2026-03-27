

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

## 🎯 Introduction

La gestion des erreurs en PowerShell permet de contrôler le flux d'exécution lorsque des problèmes surviennent. Au lieu de laisser un script s'arrêter brutalement, `Try/Catch/Finally` offre un mécanisme robuste pour intercepter, traiter et récupérer des erreurs.

> [!info] Pourquoi utiliser Try/Catch/Finally ?
> 
> - **Robustesse** : Empêche l'arrêt brutal du script
> - **Contrôle** : Permet de décider comment réagir aux erreurs
> - **Maintenance** : Facilite le débogage et la journalisation
> - **Fiabilité** : Garantit le nettoyage des ressources

---

## 📦 Structure Try/Catch/Finally

### Anatomie complète

```powershell
try {
    # Code susceptible de générer des erreurs
    # Bloc d'exécution normale
}
catch [TypeException1] {
    # Gestion spécifique pour TypeException1
}
catch [TypeException2] {
    # Gestion spécifique pour TypeException2
}
catch {
    # Gestion générale pour toutes les autres erreurs
}
finally {
    # Code qui s'exécute TOUJOURS
    # Nettoyage et libération de ressources
}
```

> [!warning] Condition préalable Pour que `catch` intercepte les erreurs, celles-ci doivent être des **erreurs bloquantes** (terminating errors). Utilisez `-ErrorAction Stop` pour forcer ce comportement si nécessaire.

### Exemple simple

```powershell
try {
    $resultat = 10 / 0  # Division par zéro
    Write-Host "Résultat : $resultat"
}
catch {
    Write-Host "❌ Une erreur s'est produite : $($_.Exception.Message)"
}
```

---

## 🔍 Le Bloc Try

### Principe

Le bloc `try` contient le code à exécuter qui pourrait potentiellement générer des erreurs. C'est la zone "surveillée".

```powershell
try {
    # Code à risque
    $fichier = Get-Content "C:\inexistant.txt" -ErrorAction Stop
    $nombre = [int]"texte"
    $connexion = New-Object System.Data.SqlClient.SqlConnection
}
```

### Quand utiliser Try ?

|Situation|Utiliser Try ?|
|---|---|
|Opérations sur fichiers|✅ Oui|
|Connexions réseau/BDD|✅ Oui|
|Conversions de types|✅ Oui|
|Appels API externes|✅ Oui|
|Calculs simples|⚠️ Selon contexte|
|Assignations de variables|❌ Généralement non|

> [!tip] Astuce de portée Utilisez `try` uniquement autour du code susceptible d'échouer, pas pour l'ensemble du script. Cela facilite l'identification de la source des erreurs.

---

## 🎣 Le Bloc Catch

### Capture générale

La forme la plus simple capture **toutes** les exceptions :

```powershell
try {
    Get-Item "C:\inexistant.txt" -ErrorAction Stop
}
catch {
    Write-Host "Erreur capturée : $($_.Exception.Message)"
}
```

### Capture par type d'exception

Vous pouvez cibler des types d'erreurs spécifiques pour un traitement adapté :

```powershell
try {
    $contenu = Get-Content "C:\données.json" -ErrorAction Stop
    $objet = $contenu | ConvertFrom-Json
}
catch [System.IO.FileNotFoundException] {
    Write-Host "📁 Le fichier n'existe pas"
    # Créer le fichier avec des valeurs par défaut
    "{}" | Out-File "C:\données.json"
}
catch [System.ArgumentException] {
    Write-Host "⚠️ Format JSON invalide"
    # Logger l'erreur pour analyse
}
catch {
    Write-Host "❌ Erreur inattendue : $($_.Exception.GetType().FullName)"
}
```

### Captures multiples spécifiques

L'ordre des blocs `catch` est important : **du plus spécifique au plus général**.

```powershell
try {
    $nombre = [int](Read-Host "Entrez un nombre")
    $resultat = 100 / $nombre
    Write-Host "Résultat : $resultat"
}
catch [System.DivideByZeroException] {
    Write-Host "➗ Division par zéro détectée"
}
catch [System.FormatException] {
    Write-Host "🔤 Le format n'est pas un nombre valide"
}
catch [System.OverflowException] {
    Write-Host "📊 Le nombre est trop grand"
}
catch {
    Write-Host "❓ Erreur non gérée : $($_.Exception.Message)"
}
```

> [!warning] Ordre des Catch Placez toujours les exceptions spécifiques **avant** le catch générique. Un catch générique en premier intercepterait toutes les erreurs.

### Types d'exceptions courants

|Type d'exception|Quand elle survient|
|---|---|
|`System.IO.FileNotFoundException`|Fichier introuvable|
|`System.IO.DirectoryNotFoundException`|Dossier introuvable|
|`System.UnauthorizedAccessException`|Permissions insuffisantes|
|`System.Net.WebException`|Erreur réseau/HTTP|
|`System.Management.Automation.ItemNotFoundException`|Item PowerShell introuvable|
|`System.InvalidOperationException`|Opération non valide dans l'état actuel|
|`System.ArgumentException`|Argument invalide|
|`System.FormatException`|Format de données incorrect|

---

## 🧹 Le Bloc Finally

### Exécution garantie

Le bloc `finally` s'exécute **TOUJOURS**, qu'une erreur se produise ou non. C'est l'endroit idéal pour le nettoyage.

```powershell
$connexion = $null
try {
    $connexion = New-Object System.Data.SqlClient.SqlConnection
    $connexion.ConnectionString = "Server=localhost;Database=test;"
    $connexion.Open()
    
    # Opérations sur la base de données
}
catch {
    Write-Host "❌ Erreur de connexion : $($_.Exception.Message)"
}
finally {
    if ($connexion -and $connexion.State -eq 'Open') {
        $connexion.Close()
        Write-Host "🔒 Connexion fermée"
    }
}
```

### Libération de ressources

Le bloc `finally` garantit que les ressources sont libérées même en cas d'erreur :

```powershell
$fichier = $null
try {
    $fichier = [System.IO.File]::Open("C:\data.txt", 'Open', 'Read')
    $lecteur = New-Object System.IO.StreamReader($fichier)
    $contenu = $lecteur.ReadToEnd()
}
catch {
    Write-Host "Erreur de lecture : $($_.Exception.Message)"
}
finally {
    if ($lecteur) { $lecteur.Dispose() }
    if ($fichier) { $fichier.Dispose() }
    Write-Host "✅ Ressources libérées"
}
```

> [!tip] Finally vs Try seul Même sans bloc `catch`, vous pouvez utiliser `try/finally` pour garantir le nettoyage tout en laissant l'erreur se propager.

```powershell
try {
    $verrou = Acquire-Lock
    # Opérations critiques
}
finally {
    Release-Lock $verrou  # S'exécute même si erreur
}
```

### Cas d'usage du Finally

|Ressource|Action dans Finally|
|---|---|
|Connexions BDD|`.Close()` ou `.Dispose()`|
|Fichiers ouverts|`.Close()` ou `.Dispose()`|
|Connexions réseau|Fermeture du socket|
|Verrous|Libération du lock|
|Variables temporaires|Nettoyage mémoire|
|Journalisation|Écriture du log final|

---

## 🔧 Variable $_ et Propriétés d'Exception

### La variable $_

Dans un bloc `catch`, la variable automatique `$_` représente l'objet d'erreur complet.

```powershell
try {
    Get-Item "C:\inexistant.txt" -ErrorAction Stop
}
catch {
    Write-Host "Type : $($_.Exception.GetType().FullName)"
    Write-Host "Message : $($_.Exception.Message)"
    Write-Host "Ligne : $($_.InvocationInfo.ScriptLineNumber)"
}
```

### Propriétés importantes

#### Exception.Message

Le message d'erreur descriptif :

```powershell
catch {
    Write-Host $_.Exception.Message
    # Ex: "Cannot find path 'C:\inexistant.txt' because it does not exist."
}
```

#### Exception.GetType()

Le type exact de l'exception :

```powershell
catch {
    $typeErreur = $_.Exception.GetType().FullName
    Write-Host "Type d'erreur : $typeErreur"
    # Ex: System.Management.Automation.ItemNotFoundException
}
```

#### InvocationInfo

Informations sur l'emplacement de l'erreur :

```powershell
catch {
    Write-Host "Script : $($_.InvocationInfo.ScriptName)"
    Write-Host "Ligne : $($_.InvocationInfo.ScriptLineNumber)"
    Write-Host "Commande : $($_.InvocationInfo.Line.Trim())"
}
```

#### Exception.InnerException

Exception sous-jacente (si elle existe) :

```powershell
catch {
    if ($_.Exception.InnerException) {
        Write-Host "Cause racine : $($_.Exception.InnerException.Message)"
    }
}
```

#### StackTrace

Trace complète de l'appel :

```powershell
catch {
    Write-Host "Stack Trace :"
    Write-Host $_.Exception.StackTrace
}
```

### Exemple complet d'analyse d'erreur

```powershell
try {
    $fichier = Get-Content "C:\config.xml" -ErrorAction Stop
    [xml]$xml = $fichier
}
catch {
    $erreur = @{
        Type      = $_.Exception.GetType().FullName
        Message   = $_.Exception.Message
        Ligne     = $_.InvocationInfo.ScriptLineNumber
        Commande  = $_.InvocationInfo.Line.Trim()
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    # Journalisation structurée
    $erreur | ConvertTo-Json | Out-File "C:\logs\erreurs.log" -Append
    
    Write-Host "❌ Erreur détectée à la ligne $($erreur.Ligne)"
    Write-Host "   Type : $($erreur.Type)"
    Write-Host "   Message : $($erreur.Message)"
}
```

---

## 💥 Throw - Lever des Exceptions

### Principe du Throw

`throw` permet de lever manuellement une exception, interrompant l'exécution normale.

```powershell
function Diviser {
    param($a, $b)
    
    if ($b -eq 0) {
        throw "Division par zéro interdite"
    }
    
    return $a / $b
}

try {
    $resultat = Diviser 10 0
}
catch {
    Write-Host "Erreur : $($_.Exception.Message)"
}
```

### Throw avec message simple

```powershell
$age = -5

if ($age -lt 0) {
    throw "L'âge ne peut pas être négatif"
}
```

### Throw avec objet exception

Vous pouvez lever des types d'exceptions spécifiques :

```powershell
function Valider-Email {
    param([string]$email)
    
    if ($email -notmatch '^[\w\.-]+@[\w\.-]+\.\w+$') {
        $exception = New-Object System.ArgumentException("Format email invalide")
        throw $exception
    }
}

try {
    Valider-Email "email.invalide"
}
catch [System.ArgumentException] {
    Write-Host "⚠️ Validation échouée : $($_.Exception.Message)"
}
```

### Throw pour réutilisation

Vous pouvez relancer une exception après traitement partiel :

```powershell
try {
    try {
        Get-Item "C:\secret.txt" -ErrorAction Stop
    }
    catch {
        Write-Host "📝 Erreur loguée dans le système"
        # Log l'erreur puis la relance
        throw
    }
}
catch {
    Write-Host "❌ Erreur capturée au niveau supérieur"
}
```

> [!warning] Throw vs Write-Error
> 
> - `throw` : Arrête l'exécution (erreur bloquante)
> - `Write-Error` : Affiche une erreur mais continue (erreur non-bloquante)

### Utilisation dans les fonctions

```powershell
function Connect-Database {
    param([string]$serveur)
    
    if ([string]::IsNullOrWhiteSpace($serveur)) {
        throw "Le paramètre 'serveur' est obligatoire"
    }
    
    if (-not (Test-Connection $serveur -Count 1 -Quiet)) {
        throw "Impossible de joindre le serveur $serveur"
    }
    
    # Connexion...
}

try {
    Connect-Database -serveur ""
}
catch {
    Write-Host "Échec de connexion : $($_.Exception.Message)"
}
```

---

## 🎨 Exceptions Personnalisées

### Créer une classe d'exception

PowerShell 5.0+ permet de créer des classes d'exception personnalisées :

```powershell
class ValidationException : System.Exception {
    [string]$Champ
    [object]$ValeurInvalide
    
    ValidationException([string]$message, [string]$champ, [object]$valeur) : base($message) {
        $this.Champ = $champ
        $this.ValeurInvalide = $valeur
    }
}

function Valider-Utilisateur {
    param($utilisateur)
    
    if ($utilisateur.Age -lt 18) {
        throw [ValidationException]::new(
            "L'utilisateur doit être majeur",
            "Age",
            $utilisateur.Age
        )
    }
}

try {
    $user = @{ Nom = "Alice"; Age = 16 }
    Valider-Utilisateur $user
}
catch [ValidationException] {
    Write-Host "❌ Validation échouée"
    Write-Host "   Champ : $($_.Exception.Champ)"
    Write-Host "   Valeur : $($_.Exception.ValeurInvalide)"
    Write-Host "   Message : $($_.Exception.Message)"
}
```

### Exception avec ErrorRecord personnalisé

Pour les versions antérieures ou plus de contrôle :

```powershell
function New-CustomException {
    param(
        [string]$Message,
        [string]$Category = 'OperationStopped',
        [object]$TargetObject = $null
    )
    
    $exception = New-Object System.Exception($Message)
    $errorRecord = New-Object System.Management.Automation.ErrorRecord(
        $exception,
        'CustomError',
        $Category,
        $TargetObject
    )
    
    return $errorRecord
}

function Traiter-Fichier {
    param([string]$chemin)
    
    if (-not (Test-Path $chemin)) {
        $erreur = New-CustomException -Message "Fichier introuvable : $chemin" `
                                       -Category 'ObjectNotFound' `
                                       -TargetObject $chemin
        throw $erreur
    }
}

try {
    Traiter-Fichier "C:\inexistant.txt"
}
catch {
    Write-Host "Type : $($_.CategoryInfo.Category)"
    Write-Host "Cible : $($_.TargetObject)"
    Write-Host "Message : $($_.Exception.Message)"
}
```

### Exceptions métier

```powershell
class BusinessException : System.Exception {
    [string]$Code
    [datetime]$Timestamp
    
    BusinessException([string]$message, [string]$code) : base($message) {
        $this.Code = $code
        $this.Timestamp = Get-Date
    }
}

function Process-Order {
    param($commande)
    
    if ($commande.Stock -lt $commande.Quantite) {
        throw [BusinessException]::new(
            "Stock insuffisant pour la commande",
            "ERR_STOCK_001"
        )
    }
}

try {
    $order = @{ Produit = "Widget"; Quantite = 100; Stock = 50 }
    Process-Order $order
}
catch [BusinessException] {
    Write-Host "🔴 Erreur métier [$($_.Exception.Code)]"
    Write-Host "   $($_.Exception.Message)"
    Write-Host "   Horodatage : $($_.Exception.Timestamp)"
    
    # Notification, rollback, etc.
}
```

---

## ✅ Bonnes Pratiques

### 1. Utilisez ErrorAction Stop

Les erreurs non-bloquantes ne sont pas capturées par `catch`. Forcez le comportement :

```powershell
# ❌ Mauvais - catch ne capturera pas l'erreur
try {
    Get-Item "C:\inexistant.txt"
}
catch {
    Write-Host "Jamais affiché"
}

# ✅ Bon
try {
    Get-Item "C:\inexistant.txt" -ErrorAction Stop
}
catch {
    Write-Host "Erreur capturée"
}
```

### 2. Captures spécifiques avant génériques

```powershell
# ✅ Bon ordre
try {
    # Code
}
catch [System.IO.FileNotFoundException] {
    # Spécifique
}
catch [System.IO.IOException] {
    # Moins spécifique
}
catch {
    # Générique
}
```

### 3. Ne capturez pas d'exceptions inutilement

```powershell
# ❌ Mauvais - try/catch sans raison
try {
    $nom = "Alice"
    $age = 30
}
catch {
    # Ces opérations ne peuvent pas échouer
}

# ✅ Bon - seulement pour le code à risque
$nom = "Alice"
$age = 30

try {
    $fichier = Get-Content $chemin -ErrorAction Stop
}
catch {
    # Gestion appropriée
}
```

### 4. Nettoyez toujours les ressources

```powershell
# ✅ Bon
$stream = $null
try {
    $stream = New-Object System.IO.FileStream("data.bin", 'Open')
    # Utilisation
}
finally {
    if ($stream) {
        $stream.Dispose()
    }
}
```

### 5. Journalisez les erreurs importantes

```powershell
function Write-ErrorLog {
    param($erreur)
    
    $logEntry = @{
        Timestamp = Get-Date
        Type      = $erreur.Exception.GetType().FullName
        Message   = $erreur.Exception.Message
        Script    = $erreur.InvocationInfo.ScriptName
        Line      = $erreur.InvocationInfo.ScriptLineNumber
    }
    
    $logEntry | Export-Csv "C:\logs\erreurs.csv" -Append -NoTypeInformation
}

try {
    # Opération critique
}
catch {
    Write-ErrorLog $_
    throw  # Relance l'erreur après log
}
```

### 6. Messages d'erreur explicites

```powershell
# ❌ Mauvais
catch {
    Write-Host "Erreur"
}

# ✅ Bon
catch {
    Write-Host "❌ Échec de la connexion à la base de données"
    Write-Host "   Serveur : $serveur"
    Write-Host "   Erreur : $($_.Exception.Message)"
    Write-Host "   Vérifiez les credentials et la connectivité réseau"
}
```

### 7. Ne masquez pas les erreurs

```powershell
# ❌ Mauvais - catch vide masque les problèmes
try {
    # Code
}
catch {
    # Rien - erreur silencieuse !
}

# ✅ Bon - au minimum logger
try {
    # Code
}
catch {
    Write-Warning "Erreur ignorée : $($_.Exception.Message)"
}
```

### 8. Validez les entrées tôt

```powershell
function Process-Data {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$chemin
    )
    
    # Validation supplémentaire
    if (-not (Test-Path $chemin)) {
        throw "Le fichier $chemin n'existe pas"
    }
    
    try {
        $data = Import-Csv $chemin -ErrorAction Stop
        # Traitement
    }
    catch {
        Write-Error "Erreur de traitement : $($_.Exception.Message)"
        throw
    }
}
```

### 9. Contexte dans les exceptions

```powershell
try {
    foreach ($serveur in $serveurs) {
        try {
            Test-Connection $serveur -Count 1 -ErrorAction Stop
        }
        catch {
            throw "Échec de connexion au serveur '$serveur': $($_.Exception.Message)"
        }
    }
}
catch {
    Write-Host $_.Exception.Message
    # Le message contient maintenant le contexte (nom du serveur)
}
```

### 10. Try/Catch dans les fonctions critiques

```powershell
function Invoke-CriticalOperation {
    [CmdletBinding()]
    param($parametres)
    
    try {
        Write-Verbose "Début de l'opération critique"
        
        # Étape 1
        $resultat1 = Step1 -ErrorAction Stop
        
        # Étape 2
        $resultat2 = Step2 $resultat1 -ErrorAction Stop
        
        Write-Verbose "Opération réussie"
        return $resultat2
    }
    catch {
        Write-Error "Échec de l'opération critique : $($_.Exception.Message)"
        
        # Rollback si nécessaire
        Restore-PreviousState
        
        throw
    }
}
```

> [!tip] Règle d'or Utilisez Try/Catch/Finally pour rendre votre code **robuste**, **prévisible** et **maintenable**. Chaque exception capturée doit avoir un traitement approprié.

---

## 🎯 Pièges Courants

### Piège 1 : Oublier ErrorAction Stop

```powershell
# ❌ L'erreur ne sera pas capturée
try {
    Get-Content "fichier_inexistant.txt"
}
catch {
    # Ne s'exécute jamais !
}
```

### Piège 2 : Catch trop générique en premier

```powershell
# ❌ Mauvais ordre
try {
    # Code
}
catch {
    # Capture tout - les catch suivants sont inutiles
}
catch [System.IO.IOException] {
    # Ne s'exécutera jamais !
}
```

### Piège 3 : Oublier Finally pour le nettoyage

```powershell
# ❌ La connexion peut rester ouverte en cas d'erreur
try {
    $conn.Open()
    # Opérations
    $conn.Close()  # Pas exécuté si erreur !
}
catch {
    Write-Host "Erreur"
}

# ✅ Correct avec Finally
try {
    $conn.Open()
    # Opérations
}
catch {
    Write-Host "Erreur"
}
finally {
    if ($conn) { $conn.Close() }
}
```

### Piège 4 : Utiliser $Error au lieu de $_

```powershell
# ❌ Confusion
catch {
    Write-Host $Error[0].Exception.Message  # Peut être une ancienne erreur
}

# ✅ Correct
catch {
    Write-Host $_.Exception.Message  # L'erreur actuelle
}
```

---

## 📊 Récapitulatif

|Bloc|Obligatoire|Exécution|Usage principal|
|---|---|---|---|
|`try`|✅ Oui|Toujours (jusqu'à erreur)|Code à surveiller|
|`catch`|⚠️ Optionnel|Si erreur dans try|Gestion d'erreur|
|`finally`|❌ Non|TOUJOURS|Nettoyage/libération|

> [!example] Template de démarrage
> 
> ```powershell
> try {
>     # Votre code à risque ici
>     $resultat = Do-Something -ErrorAction Stop
> }
> catch [TypeSpecifique] {
>     # Gestion spécifique
>     Write-Error "Erreur spécifique : $($_.Exception.Message)"
> }
> catch {
>     # Gestion générale
>     Write-Error "Erreur : $($_.Exception.Message)"
> }
> finally {
>     # Nettoyage
>     if ($ressource) { $ressource.Dispose() }
> }
> ```

---

_Cours complet sur la gestion des erreurs en PowerShell - Try/Catch/Finally_ 🛡️