
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

## 🎓 Introduction

La **portée** (scope) d'une variable définit où cette variable est accessible et visible dans votre code PowerShell. Comprendre les portées est essentiel pour :

- Éviter les conflits de noms entre variables
- Protéger vos données contre des modifications accidentelles
- Structurer votre code de manière propre et maintenable
- Optimiser l'utilisation de la mémoire

> [!info] Principe fondamental PowerShell utilise un système de portées hiérarchiques. Une portée enfant peut accéder aux variables de sa portée parente, mais pas l'inverse.

---

## 🔍 Les différentes portées

PowerShell propose quatre niveaux de portée principaux, organisés hiérarchiquement :

```
Global (Session entière)
  ↓
Script (Fichier .ps1)
  ↓
Local (Bloc courant)
  ↓
Private (Uniquement le bloc actuel, non héritable)
```

### Portée locale (Local)

La portée **locale** est la portée par défaut. Elle représente le contexte d'exécution actuel.

#### 📖 Caractéristiques

- C'est la portée par défaut quand vous créez une variable
- Limitée au bloc de code où elle est définie (fonction, script, bloc scriptblock)
- Les portées enfants héritent des variables locales parentes
- Se termine à la fin du bloc d'exécution

#### 💻 Syntaxe et exemples

```powershell
# Variable locale par défaut
$nom = "Alice"

# Explicitement locale (identique)
$local:nom = "Alice"

# Dans une fonction
function Test-Local {
    $resultat = "Variable locale"  # Accessible uniquement dans cette fonction
    Write-Host $resultat
}

Test-Local
# Write-Host $resultat  # ❌ Erreur : $resultat n'existe pas ici
```

#### 🔄 Héritage des portées locales

```powershell
$niveau1 = "Niveau 1"

function Fonction-Parent {
    $niveau2 = "Niveau 2"
    Write-Host "Dans Parent: $niveau1"  # ✅ Accès à la portée parente
    
    function Fonction-Enfant {
        $niveau3 = "Niveau 3"
        Write-Host "Dans Enfant: $niveau1"  # ✅ Accès au grand-parent
        Write-Host "Dans Enfant: $niveau2"  # ✅ Accès au parent
    }
    
    Fonction-Enfant
    # Write-Host $niveau3  # ❌ Pas d'accès à la portée enfant
}

Fonction-Parent
```

> [!tip] Astuce Utilisez la portée locale par défaut pour toutes vos variables temporaires. C'est la pratique la plus sûre.

---

### Portée de script (Script)

La portée **script** est limitée au fichier de script (.ps1) en cours d'exécution.

#### 📖 Caractéristiques

- Accessible partout dans le fichier de script
- Partagée entre toutes les fonctions du même script
- Isolée des autres scripts
- Persiste pendant toute l'exécution du script

#### 💻 Syntaxe et exemples

```powershell
# Fichier: MonScript.ps1

# Variable de script
$script:configuration = @{
    Serveur = "localhost"
    Port = 8080
}

function Initialiser-Config {
    # Modification de la variable de script
    $script:configuration.Serveur = "192.168.1.100"
}

function Afficher-Config {
    # Lecture de la variable de script
    Write-Host "Serveur: $($script:configuration.Serveur)"
    Write-Host "Port: $($script:configuration.Port)"
}

Initialiser-Config
Afficher-Config
```

#### 🎯 Cas d'usage typiques

```powershell
# Configuration partagée dans le script
$script:LogPath = "C:\Logs\application.log"
$script:MaxRetries = 3

function Write-Log {
    param($Message)
    Add-Content -Path $script:LogPath -Value "$(Get-Date) - $Message"
}

function Get-DataWithRetry {
    param($Url)
    
    for ($i = 0; $i -lt $script:MaxRetries; $i++) {
        try {
            return Invoke-RestMethod -Uri $Url
        }
        catch {
            Write-Log "Tentative $($i+1) échouée"
        }
    }
}
```

> [!warning] Attention Les variables de script ne sont PAS partagées entre différents fichiers .ps1, même s'ils sont appelés l'un depuis l'autre via dot-sourcing.

---

### Portée globale (Global)

La portée **globale** est accessible partout dans la session PowerShell active.

#### 📖 Caractéristiques

- Accessible depuis n'importe quel script, fonction ou module
- Persiste pendant toute la durée de la session PowerShell
- Partagée entre tous les contextes d'exécution
- Doit être utilisée avec parcimonie

#### 💻 Syntaxe et exemples

```powershell
# Création d'une variable globale
$global:EnvironnementProd = $true

function Test-Environnement {
    if ($global:EnvironnementProd) {
        Write-Host "⚠️ Attention : Environnement de PRODUCTION !"
    }
}

# Accessible n'importe où dans la session
Test-Environnement
Write-Host $global:EnvironnementProd  # ✅ Fonctionne
```

#### 🔄 Persistance entre scripts

```powershell
# Script1.ps1
$global:CompteurGlobal = 0

function Incrementer-Compteur {
    $global:CompteurGlobal++
}

# Script2.ps1 (exécuté plus tard dans la même session)
function Afficher-Compteur {
    Write-Host "Compteur: $global:CompteurGlobal"
}

Incrementer-Compteur  # Depuis Script1
Afficher-Compteur     # Depuis Script2 - affichera 1
```

#### ⚠️ Comparaison Local vs Global

|Aspect|Local|Global|
|---|---|---|
|**Visibilité**|Limitée au bloc|Toute la session|
|**Durée de vie**|Fin du bloc|Fin de la session|
|**Pollution**|Aucune|Risque élevé|
|**Usage recommandé**|Par défaut|Exceptionnel|
|**Performance**|Optimale|Légèrement plus lent|

> [!warning] Danger des variables globales L'abus de variables globales peut créer des effets de bord imprévisibles et rendre le code difficile à maintenir. Préférez passer les données en paramètres.

---

### Portée privée (Private)

La portée **privée** est la plus restrictive : la variable n'est accessible que dans le bloc exact où elle est définie.

#### 📖 Caractéristiques

- Non accessible par les portées enfants
- Utile pour isoler complètement des données sensibles
- Empêche l'héritage automatique
- Nécessite une utilisation explicite du modificateur `$private:`

#### 💻 Syntaxe et exemples

```powershell
function Protection-Donnees {
    # Variable privée - NON héritable
    $private:motDePasse = "Secret123!"
    
    # Variable locale normale - héritable
    $utilisateur = "admin"
    
    function Fonction-Interne {
        Write-Host "Utilisateur: $utilisateur"  # ✅ Accessible (locale héritée)
        # Write-Host $motDePasse  # ❌ ERREUR : non accessible (privée)
    }
    
    Fonction-Interne
}

Protection-Donnees
```

#### 🔐 Cas d'usage : Sécurité

```powershell
function Connect-SecureAPI {
    param($Username)
    
    # Mot de passe privé - jamais exposé aux fonctions enfants
    $private:apiKey = Get-Content "C:\secure\api.key" -Raw
    
    # Configuration publique
    $baseUrl = "https://api.example.com"
    
    function Invoke-SecureRequest {
        param($Endpoint)
        
        # ❌ Impossible d'accéder à $apiKey ici
        # Doit être passé explicitement en paramètre si nécessaire
        Write-Host "URL: $baseUrl/$Endpoint"  # ✅ $baseUrl accessible
    }
    
    # Utilisation directe dans la fonction parente
    $headers = @{ "Authorization" = "Bearer $apiKey" }
    Invoke-RestMethod -Uri "$baseUrl/data" -Headers $headers
}
```

> [!tip] Quand utiliser Private ? Utilisez `$private:` pour les données sensibles (mots de passe, clés API, tokens) ou pour éviter toute pollution accidentelle des portées enfants.

---

## 🎛️ Modificateurs de portée

Les modificateurs permettent de spécifier explicitement la portée d'une variable.

### Syntaxe des modificateurs

```powershell
$<modificateur>:<nom_variable> = <valeur>
```

### Tableau récapitulatif

|Modificateur|Syntaxe|Portée|Héritable ?|
|---|---|---|---|
|**local**|`$local:var`|Bloc actuel|✅ Oui|
|**script**|`$script:var`|Fichier .ps1|✅ Oui|
|**global**|`$global:var`|Session|✅ Oui|
|**private**|`$private:var`|Bloc actuel|❌ Non|

### 💻 Exemples pratiques

```powershell
# Sans modificateur (local par défaut)
$compteur = 0

# Équivalent explicite
$local:compteur = 0

# Spécifier une portée différente
$script:compteur = 0    # Visible dans tout le script
$global:compteur = 0    # Visible dans toute la session
$private:compteur = 0   # Visible uniquement dans ce bloc
```

### 🔄 Modification d'une variable parente

```powershell
# Variable globale
$global:total = 0

function Ajouter-Valeur {
    param($Valeur)
    
    # Sans modificateur : crée une nouvelle variable LOCALE
    # $total = $total + $Valeur  # ❌ Ne modifie PAS la variable globale
    
    # Avec modificateur : modifie la variable globale
    $global:total = $global:total + $Valeur  # ✅ Modifie la globale
}

Ajouter-Valeur -Valeur 10
Write-Host $global:total  # Affiche : 10
```

> [!warning] Piège courant Sans modificateur, `$variable = ...` crée TOUJOURS une nouvelle variable locale, même si une variable du même nom existe dans une portée parente.

### 🎯 Accès en lecture vs écriture

```powershell
$script:configuration = "Config initiale"

function Test-Acces {
    # ✅ LECTURE : pas de modificateur nécessaire
    Write-Host $configuration  # Affiche : "Config initiale"
    
    # ❌ ÉCRITURE sans modificateur : crée une variable locale
    $configuration = "Config locale"
    Write-Host $configuration  # Affiche : "Config locale"
}

Test-Acces
Write-Host $script:configuration  # Affiche : "Config initiale" (inchangée!)

function Test-Modification {
    # ✅ ÉCRITURE avec modificateur : modifie la variable du script
    $script:configuration = "Config modifiée"
}

Test-Modification
Write-Host $script:configuration  # Affiche : "Config modifiée"
```

---

## 🔧 Variables dans les fonctions

Les fonctions créent automatiquement une nouvelle portée locale.

### 📖 Comportement par défaut

```powershell
# Variable dans la portée globale
$message = "Message global"

function Afficher-Message {
    # Accès en lecture à la variable parente
    Write-Host $message  # ✅ Affiche : "Message global"
    
    # Création d'une variable locale
    $resultat = "Traitement terminé"
}

Afficher-Message
# Write-Host $resultat  # ❌ Erreur : $resultat n'existe pas ici
```

### 🎯 Paramètres de fonction

Les paramètres sont TOUJOURS des variables locales à la fonction :

```powershell
function Calculer-Somme {
    param(
        [int]$Nombre1,  # Variable locale
        [int]$Nombre2   # Variable locale
    )
    
    $resultat = $Nombre1 + $Nombre2  # Variable locale
    return $resultat
}

$somme = Calculer-Somme -Nombre1 5 -Nombre2 3
# $Nombre1 et $Nombre2 n'existent pas ici
```

### 🔄 Modification de variables externes

```powershell
# ❌ Mauvaise pratique : modifier une variable globale
$global:compteur = 0

function Incrementer-Mauvais {
    $global:compteur++  # Modification d'état global
}

# ✅ Bonne pratique : retourner une valeur
function Incrementer-Bon {
    param([int]$Valeur)
    return $Valeur + 1
}

$compteur = 0
$compteur = Incrementer-Bon -Valeur $compteur
```

### 📦 Variables et blocs Begin/Process/End

```powershell
function Process-Data {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Item
    )
    
    begin {
        # Variables du bloc Begin : accessibles dans Process et End
        $script:total = 0
        $script:items = @()
    }
    
    process {
        # Accès aux variables du bloc Begin
        $script:total++
        $script:items += $Item
    }
    
    end {
        # Affichage final
        Write-Host "Total traité: $script:total"
        Write-Host "Items: $($script:items -join ', ')"
    }
}

"A", "B", "C" | Process-Data
```

> [!tip] Astuce pour les fonctions avancées Utilisez `$script:` dans les blocs Begin/Process/End pour partager des données entre les blocs, car chaque appel de Process est une portée séparée.

---

## 📜 Variables dans les blocs de script

Les scriptblocks (`{ }`) créent une nouvelle portée locale.

### 📖 Scriptblocks simples

```powershell
# Variable dans la portée principale
$externe = "Valeur externe"

# Scriptblock : nouvelle portée
$monScript = {
    Write-Host $externe  # ✅ Accès en lecture
    $interne = "Valeur interne"
}

# Exécution du scriptblock
& $monScript

# Write-Host $interne  # ❌ Erreur : $interne n'existe pas ici
```

### 🔄 Scriptblocks avec Invoke-Command

```powershell
$couleur = "Bleu"

Invoke-Command -ScriptBlock {
    # ❌ $couleur n'est PAS accessible directement
    # Write-Host $couleur  # Erreur ou vide
    
    $locale = "Variable locale"
}

# Solution : utiliser -ArgumentList
Invoke-Command -ScriptBlock {
    param($CouleurPassee)
    Write-Host "Couleur: $CouleurPassee"
} -ArgumentList $couleur
```

### 🎯 Scriptblocks dans ForEach-Object

```powershell
$multiplicateur = 10

1..5 | ForEach-Object {
    # $_ : élément actuel du pipeline (automatique)
    # $multiplicateur : accessible depuis la portée parente
    $resultat = $_ * $multiplicateur
    Write-Host "Résultat: $resultat"
}
```

### 🔐 Closures : capture de variables

Les scriptblocks peuvent "capturer" les variables de leur portée de création :

```powershell
function New-Compteur {
    $count = 0
    
    # Le scriptblock capture $count
    return {
        $script:count++
        return $script:count
    }
}

$compteur1 = New-Compteur
$compteur2 = New-Compteur

& $compteur1  # 1
& $compteur1  # 2
& $compteur2  # 1 (compteur indépendant)
& $compteur1  # 3
```

### 📋 Scriptblocks avec Where-Object et autres cmdlets

```powershell
$seuil = 50

# Where-Object : accès aux variables parentes
$nombres = 1..100
$filtres = $nombres | Where-Object { $_ -gt $seuil }

# Select-Object avec expression calculée
$fichiers = Get-ChildItem
$prefixe = "Fichier_"

$fichiers | Select-Object @{
    Name = 'NomPersonnalise'
    Expression = { $prefixe + $_.Name }  # Accès à $prefixe
}
```

> [!warning] Attention aux portées avec Invoke-Command `Invoke-Command` (surtout avec `-ComputerName`) crée une portée complètement isolée. Vous devez utiliser `-ArgumentList` pour passer des variables.

---

## ⏳ Durée de vie des variables

La durée de vie d'une variable dépend de sa portée.

### 📊 Tableau des durées de vie

|Portée|Début|Fin|Exemple|
|---|---|---|---|
|**Private**|Création|Fin du bloc exact|Fonction termine|
|**Local**|Création|Fin du bloc|Fonction termine|
|**Script**|Première utilisation|Fin du script|Script termine|
|**Global**|Création|Fermeture de la session|Fermeture PowerShell|

### 💻 Exemple : cycle de vie complet

```powershell
# Début de la session PowerShell
$global:sessionId = [Guid]::NewGuid()  # Créée - vivra jusqu'à la fermeture

function Traiter-Donnees {
    # Script lancé
    $script:logFile = "C:\temp\log.txt"  # Vivra jusqu'à la fin du script
    
    function Operation-Interne {
        # Fonction appelée
        $local:tempData = Import-Csv "data.csv"  # Vivra jusqu'à la fin de la fonction
        $private:apiKey = Get-Secret  # Vivra jusqu'à la fin de la fonction
        
        # Traitement...
        
    } # ← Ici : $tempData et $apiKey sont détruites
    
    Operation-Interne
    
    # $tempData et $apiKey n'existent plus
    # $logFile existe toujours
    
} # ← Ici : $logFile est détruite

Traiter-Donnees

# Seule $sessionId existe encore
```

### 🔄 Garbage Collection

```powershell
function Creer-GrosseVariable {
    # Grosse variable locale
    $grosseTableau = 1..1000000
    
    # Utilisation...
    
} # ← PowerShell libère automatiquement la mémoire

# Forcer le garbage collection (rarement nécessaire)
[System.GC]::Collect()
```

### 🎯 Variables qui persistent après un script

```powershell
# Dans un script MonScript.ps1

# ❌ Variable locale - disparaît après le script
$resultat = "Données"

# ✅ Variable globale - persiste dans la session
$global:resultatPersistant = "Données"

# Fin du script
```

Après exécution :

```powershell
.\MonScript.ps1
Write-Host $resultat  # ❌ N'existe pas
Write-Host $global:resultatPersistant  # ✅ Existe encore
```

### 🗑️ Suppression manuelle de variables

```powershell
# Créer une variable
$maVariable = "Test"

# Supprimer explicitement
Remove-Variable -Name maVariable

# Vérifier
Get-Variable -Name maVariable -ErrorAction SilentlyContinue  # Null

# Supprimer une variable globale
Remove-Variable -Name sessionId -Scope Global
```

> [!tip] Optimisation mémoire PowerShell gère automatiquement la mémoire. Vous n'avez généralement pas besoin de supprimer manuellement les variables, sauf pour les très gros objets ou les données sensibles.

---

## ⚠️ Pièges courants

### 1. Création accidentelle de variables locales

```powershell
# Piège le plus fréquent !
$script:compteur = 0

function Incrementer {
    # ❌ Crée une NOUVELLE variable locale
    $compteur = $compteur + 1  # $compteur locale = 0 + 1 = 1
}

Incrementer
Write-Host $script:compteur  # Affiche 0 (pas modifiée!)

# ✅ Solution
function Incrementer-Correct {
    $script:compteur = $script:compteur + 1
}
```

### 2. Confusion entre lecture et écriture

```powershell
$global:valeur = 10

function Test {
    # Lecture : ✅ pas besoin de modificateur
    if ($valeur -gt 5) {
        # Écriture : ❌ crée une locale si pas de modificateur
        $valeur = 20  # Variable locale !
    }
    Write-Host $valeur  # Affiche 20 (locale)
}

Test
Write-Host $global:valeur  # Affiche 10 (inchangée!)
```

### 3. Variables dans les pipelines

```powershell
$total = 0

# ❌ Ne fonctionne pas comme attendu
1..10 | ForEach-Object {
    $total += $_  # Modifie une copie locale dans certains contextes
}

# ✅ Solution : utilisez une variable de portée parente explicite
$script:total = 0
1..10 | ForEach-Object {
    $script:total += $_
}
```

### 4. Oubli de $using: dans les jobs

```powershell
$chemin = "C:\Data"

# ❌ Ne fonctionne pas dans un job distant
Start-Job -ScriptBlock {
    Get-ChildItem -Path $chemin  # $chemin est vide !
}

# ✅ Solution : $using:
Start-Job -ScriptBlock {
    Get-ChildItem -Path $using:chemin
}
```

### 5. Pollution de la portée globale

```powershell
# ❌ Mauvaise pratique : tout en global
function Traiter-Fichiers {
    $global:fichiers = Get-ChildItem
    $global:total = $fichiers.Count
    $global:taille = ($fichiers | Measure-Object Length -Sum).Sum
}

# ✅ Bonne pratique : retourner un objet
function Traiter-Fichiers {
    $fichiers = Get-ChildItem
    return [PSCustomObject]@{
        Total = $fichiers.Count
        Taille = ($fichiers | Measure-Object Length -Sum).Sum
    }
}
```

### 6. Variables dans les boucles imbriquées

```powershell
# ❌ Confusion de variables
for ($i = 0; $i -lt 3; $i++) {
    for ($i = 0; $i -lt 5; $i++) {  # Réutilise $i !
        Write-Host $i
    }
}

# ✅ Utiliser des noms différents
for ($i = 0; $i -lt 3; $i++) {
    for ($j = 0; $j -lt 5; $j++) {
        Write-Host "i=$i, j=$j"
    }
}
```

---

## ✅ Bonnes pratiques

### 1. Principe de la portée minimale

```powershell
# ✅ Préférez la portée la plus restrictive possible
function Process-Data {
    $local:data = Get-Data  # Local par défaut
    # Pas besoin de $private: sauf si vraiment sensible
}

# ❌ Évitez la portée globale sauf nécessité absolue
$global:toutEnGlobal = "Non!"
```

### 2. Nommage explicite pour les portées étendues

```powershell
# ✅ Nommage clair pour les variables de script
$script:AppConfiguration = @{}
$script:LogFilePath = "C:\Logs\app.log"

# ✅ Préfixe pour les variables globales
$global:APP_SessionId = [Guid]::NewGuid()
$global:APP_ConnectionPool = @{}
```

### 3. Documenter les variables partagées

```powershell
<#
.SYNOPSIS
    Script de traitement des commandes
.NOTES
    Variables de script utilisées:
    - $script:ConfigPath : Chemin du fichier de configuration
    - $script:RetryCount : Nombre de tentatives de connexion
#>

$script:ConfigPath = ".\config.json"
$script:RetryCount = 3
```

### 4. Utiliser des fonctions pures

```powershell
# ✅ Fonction pure : pas d'effet de bord
function Get-DoubleValue {
    param([int]$Value)
    return $Value * 2
}

# ❌ Fonction impure : modifie un état externe
$global:counter = 0
function Increment-Counter {
    $global:counter++
}
```

### 5. Passer par paramètres plutôt que par portée

```powershell
# ❌ Mauvaise pratique
$script:connexion = Connect-Database

function Query-Data {
    # Utilise directement $script:connexion
    Invoke-SqlQuery -Connection $script:connexion -Query "SELECT *"
}

# ✅ Bonne pratique
function Query-Data {
    param([System.Data.SqlClient.SqlConnection]$Connection)
    Invoke-SqlQuery -Connection $Connection -Query "SELECT *"
}

$connexion = Connect-Database
Query-Data -Connection $connexion
```

### 6. Nettoyer les variables sensibles

```powershell
function Connect-SecureService {
    $private:password = Get-Secret -Name "ServicePassword"
    
    try {
        # Utilisation du mot de passe
        Connect-Service -Password $password
    }
    finally {
        # Nettoyage sécurisé
        Remove-Variable -Name password -Scope Private -Force
    }
}
```

### 7. Grouper les variables de configuration

```powershell
# ✅ Regrouper dans un hashtable
$script:Config = @{
    Server = "localhost"
    Port = 8080
    Timeout = 30
    RetryCount = 3
}

# Accès facile et clair
$timeout = $script:Config.Timeout
```

### 8. Initialisation des variables de script

```powershell
# ✅ Bloc d'initialisation en début de script
# ===========================================
# CONFIGURATION DU SCRIPT
# ===========================================

$script:LogPath = "C:\Logs\$(Get-Date -Format 'yyyyMMdd').log"
$script:MaxRetries = 3
$script:TimeoutSeconds = 30

# ===========================================
# FONCTIONS
# ===========================================

function Write-Log { ... }
```

---

## 🎓 Résumé

### Points clés à retenir

1. **Portée par défaut** : Toujours locale sauf indication contraire
2. **Héritage** : Les portées enfants voient les parents (sauf private)
3. **Modificateurs obligatoires** : Pour modifier une variable parente en écriture
4. **Private** : Pour les données ultra-sensibles non héritables
5. **Global** : À utiliser avec parcimonie
6. **Script** : Idéal pour partager des données dans un fichier .ps1

### Hiérarchie des portées

```
Global (toute la session)
  └─ Script (fichier .ps1)
      └─ Local (fonction/bloc)
          └─ Private (non héritable)
```

### Tableau de décision

|Besoin|Portée recommandée|
|---|---|
|Variable temporaire dans une fonction|Local (défaut)|
|Configuration partagée dans un script|Script|
|Compteur/état global de l'application|Global (avec parcimonie)|
|Mot de passe / clé API|Private|
|Paramètre de fonction|Local (automatique)|

> [!tip] Règle d'or **Utilisez la portée la plus restrictive possible qui répond à vos besoins.**

---

_Cours rédigé pour PowerShell 7+ - Compatible PowerShell 5.1_