

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

## 🔰 Introduction

Les fonctions en PowerShell permettent d'encapsuler du code réutilisable dans des blocs nommés. Elles constituent un élément fondamental de la programmation modulaire et facilitent la maintenance, la lisibilité et la réutilisation du code.

> [!info] Pourquoi utiliser des fonctions ?
> 
> - **Réutilisabilité** : Écrivez une fois, utilisez plusieurs fois
> - **Lisibilité** : Code mieux organisé et plus compréhensible
> - **Maintenance** : Corrections et améliorations centralisées
> - **Testabilité** : Isolation des fonctionnalités pour les tests
> - **Abstraction** : Masquez la complexité derrière une interface simple

---

## 📝 Syntaxe de déclaration `function`

### Structure de base

La déclaration d'une fonction en PowerShell utilise le mot-clé `function` suivi du nom et d'un bloc de code entre accolades.

```powershell
# Syntaxe minimale
function Nom-Fonction {
    # Code de la fonction
}

# Exemple simple
function Say-Hello {
    Write-Host "Bonjour !"
}
```

### Syntaxe complète

```powershell
function Verb-Noun {
    [CmdletBinding()]  # Optionnel : active les fonctionnalités avancées
    param(
        # Paramètres (sera vu dans une autre partie)
    )
    
    begin {
        # Bloc d'initialisation (optionnel)
    }
    
    process {
        # Bloc de traitement principal
    }
    
    end {
        # Bloc de finalisation (optionnel)
    }
}
```

> [!tip] Astuce Pour des fonctions simples, vous pouvez omettre les blocs `begin`, `process` et `end`. Le code sera alors exécuté dans le bloc `end` par défaut.

### Fonction avec retour de valeur

```powershell
function Get-Square {
    param($Number)
    return $Number * $Number
}

# Ou de manière plus idiomatique en PowerShell
function Get-Square {
    param($Number)
    $Number * $Number  # Le résultat est automatiquement retourné
}
```

> [!warning] Attention au `return` En PowerShell, tout ce qui est émis sur le pipeline est retourné. Le mot-clé `return` interrompt l'exécution mais n'est pas obligatoire pour retourner une valeur.

---

## 🏷️ Convention de nommage Verb-Noun

### Principe fondamental

PowerShell utilise une convention de nommage stricte : **Verbe-Nom** (en anglais). Cette convention améliore la cohérence et la découvrabilité des commandes.

```powershell
# ✅ Correct
function Get-UserInfo { }
function Set-Configuration { }
function Remove-TempFile { }
function Test-Connection { }

# ❌ Incorrect
function UserInfo { }
function ConfigSet { }
function DeleteTemp { }
function CheckConnection { }
```

### Verbes approuvés

PowerShell maintient une liste de verbes approuvés que vous pouvez consulter :

```powershell
# Afficher tous les verbes approuvés
Get-Verb

# Rechercher des verbes spécifiques
Get-Verb -Verb Get, Set, Remove
```

**Catégories principales de verbes :**

|Catégorie|Verbes courants|Usage|
|---|---|---|
|**Common**|Get, Set, New, Remove|Opérations CRUD de base|
|**Data**|Convert, Export, Import|Manipulation de données|
|**Lifecycle**|Start, Stop, Restart|Gestion du cycle de vie|
|**Diagnostic**|Test, Measure, Debug|Tests et diagnostics|
|**Security**|Lock, Unlock, Protect|Opérations de sécurité|

### Exemples pratiques

```powershell
# Opérations sur les fichiers
function Get-LogFile { }      # Récupérer
function New-LogFile { }      # Créer
function Remove-LogFile { }   # Supprimer
function Clear-LogFile { }    # Vider le contenu

# Opérations sur les services
function Start-CustomService { }
function Stop-CustomService { }
function Restart-CustomService { }
function Test-ServiceHealth { }

# Opérations de conversion
function Convert-JsonToXml { }
function Export-DataToCsv { }
function Import-ConfigFromFile { }
```

> [!tip] Choix du verbe approprié
> 
> - **Get** : Récupération sans modification
> - **Set** : Modification d'une propriété existante
> - **New** : Création d'un nouvel objet
> - **Remove** : Suppression complète
> - **Clear** : Suppression du contenu (l'objet reste)
> - **Test** : Vérification retournant un booléen

> [!warning] Verbes non approuvés Si vous utilisez un verbe non approuvé, PowerShell émettra un avertissement. Pour le supprimer, utilisez `[Diagnostics.CodeAnalysis.SuppressMessageAttribute()]` ou respectez la convention.

---

## 🧱 Bloc de code de la fonction

### Structure des blocs

Une fonction PowerShell peut contenir jusqu'à trois blocs d'exécution distincts :

```powershell
function Process-Data {
    begin {
        # Exécuté UNE FOIS au début
        Write-Host "Initialisation..."
        $total = 0
    }
    
    process {
        # Exécuté POUR CHAQUE objet du pipeline
        Write-Host "Traitement de $_"
        $total += $_
    }
    
    end {
        # Exécuté UNE FOIS à la fin
        Write-Host "Total: $total"
    }
}
```

### Quand utiliser chaque bloc ?

|Bloc|Exécution|Usage typique|
|---|---|---|
|`begin`|Une fois au début|Initialisation de variables, connexions, validation|
|`process`|Pour chaque input|Traitement des objets du pipeline|
|`end`|Une fois à la fin|Nettoyage, résumés, fermeture de connexions|

### Exemples concrets

**Fonction simple (un seul bloc implicite) :**

```powershell
function Get-Greeting {
    param($Name)
    "Bonjour, $Name !"
}
```

**Fonction avec traitement pipeline :**

```powershell
function Format-CustomOutput {
    begin {
        Write-Host "=== Début du traitement ===" -ForegroundColor Green
        $count = 0
    }
    
    process {
        $count++
        Write-Host "[$count] $_" -ForegroundColor Yellow
    }
    
    end {
        Write-Host "=== Fin : $count éléments traités ===" -ForegroundColor Green
    }
}

# Utilisation
1..5 | Format-CustomOutput
```

**Fonction avec gestion d'erreurs :**

```powershell
function Get-FileContent {
    param($Path)
    
    begin {
        Write-Verbose "Vérification des prérequis..."
    }
    
    process {
        try {
            if (Test-Path $Path) {
                Get-Content $Path
            } else {
                Write-Error "Fichier introuvable : $Path"
            }
        }
        catch {
            Write-Error "Erreur de lecture : $_"
        }
    }
    
    end {
        Write-Verbose "Opération terminée."
    }
}
```

> [!info] Bloc par défaut Si vous n'utilisez pas les blocs `begin`, `process`, `end`, tout le code est placé dans le bloc `end` par défaut.

> [!tip] Astuce de performance Utilisez le bloc `begin` pour les opérations coûteuses qui ne doivent être effectuées qu'une seule fois (connexions, chargement de données, etc.)

---

## 📞 Appel de fonction

### Syntaxe d'appel

PowerShell offre plusieurs façons d'appeler une fonction, mais la syntaxe recommandée est celle des cmdlets.

```powershell
# ✅ Syntaxe PowerShell (recommandée)
Get-Greeting -Name "Alice"
Get-Greeting "Alice"  # Le nom du paramètre peut être omis si non ambigu

# ✅ Avec paramètres nommés
Get-UserInfo -Username "Bob" -Detailed

# ❌ Syntaxe à éviter (style C/JavaScript)
Get-Greeting("Alice")  # Passe le tableau ("Alice") comme un seul argument !
```

> [!warning] Piège courant : Les parenthèses
> 
> ```powershell
> # ❌ ERREUR : Crée un tableau avec un élément
> Get-Greeting("Alice")
> 
> # ✅ CORRECT : Passe deux arguments séparés
> Get-Greeting "Alice" "Bonjour"
> 
> # ✅ CORRECT : Avec paramètres nommés
> Get-Greeting -Name "Alice" -Greeting "Bonjour"
> ```

### Appel avec le pipeline

```powershell
# Passer des données via le pipeline
1..10 | Get-Square

# Chaîner plusieurs fonctions
Get-ChildItem | Get-FileSize | Sort-Object -Descending

# Utiliser ForEach-Object pour appeler une fonction
$users | ForEach-Object { Get-UserDetails -Username $_.Name }
```

### Appel avec splatting

Le splatting permet de passer plusieurs paramètres de manière structurée :

```powershell
function Send-Email {
    param($To, $Subject, $Body)
    # Code d'envoi
}

# Splatting avec hashtable
$params = @{
    To      = "user@example.com"
    Subject = "Test"
    Body    = "Ceci est un test"
}
Send-Email @params  # Notez le @ au lieu de $
```

### Appel avec valeurs de retour

```powershell
# Capture du résultat
$result = Get-Square -Number 5
Write-Host "Le carré est : $result"

# Utilisation directe
if (Test-Connection -Server "google.com") {
    Write-Host "Connexion OK"
}

# Capture de multiples valeurs
$files = Get-CustomFiles
foreach ($file in $files) {
    # Traitement
}
```

> [!tip] Astuce : Appel silencieux Pour appeler une fonction sans afficher le résultat :
> 
> ```powershell
> $null = Get-Greeting
> [void](Get-Greeting)
> Get-Greeting | Out-Null
> ```

---

## 💻 Fonctions dans scripts vs fonctions interactives

### Fonctions dans un script

Lorsque vous définissez des fonctions dans un fichier `.ps1`, elles sont chargées au moment de l'exécution du script.

**Exemple : `MyScript.ps1`**

```powershell
# Définition des fonctions
function Get-Timestamp {
    Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

function Write-Log {
    param($Message)
    $timestamp = Get-Timestamp
    Write-Host "[$timestamp] $Message"
}

# Code principal du script
Write-Log "Début du script"
# ... autres opérations ...
Write-Log "Fin du script"
```

**Exécution :**

```powershell
.\MyScript.ps1
```

> [!info] Portée dans un script Les fonctions définies dans un script ne sont disponibles que pendant l'exécution de ce script, sauf si vous les exportez ou utilisez le dot-sourcing.

### Fonctions interactives (console)

Dans la console PowerShell, vous pouvez définir des fonctions à la volée :

```powershell
# Définition interactive
PS> function Quick-Test { "Ceci est un test" }

# Utilisation immédiate
PS> Quick-Test
Ceci est un test

# La fonction reste disponible dans la session
PS> Quick-Test
Ceci est un test
```

### Dot-sourcing : Charger des fonctions dans la session

Le dot-sourcing (`. .\script.ps1`) exécute un script dans la portée actuelle, rendant ses fonctions disponibles :

**Fichier `Functions.ps1` :**

```powershell
function Get-SystemInfo {
    [PSCustomObject]@{
        OS       = $PSVersionTable.OS
        PSVersion = $PSVersionTable.PSVersion
        Computer  = $env:COMPUTERNAME
    }
}

function Get-DiskSpace {
    Get-PSDrive -PSProvider FileSystem | 
        Select-Object Name, @{N='Size(GB)';E={[math]::Round($_.Used/1GB,2)}}
}
```

**Utilisation :**

```powershell
# ❌ Exécution normale : fonctions non disponibles après
.\Functions.ps1
Get-SystemInfo  # Erreur : commande introuvable

# ✅ Dot-sourcing : fonctions disponibles dans la session
. .\Functions.ps1
Get-SystemInfo  # ✅ Fonctionne !
Get-DiskSpace   # ✅ Fonctionne !
```

### Modules : Approche professionnelle

Pour une distribution et une réutilisation optimales, créez un module :

**Structure :**

```
MonModule/
├── MonModule.psm1    # Fichier de module
└── MonModule.psd1    # Manifeste (optionnel)
```

**`MonModule.psm1` :**

```powershell
function Get-CustomData {
    # Code de la fonction
}

function Set-CustomData {
    # Code de la fonction
}

# Exporter les fonctions publiques
Export-ModuleMember -Function Get-CustomData, Set-CustomData
```

**Utilisation :**

```powershell
# Importer le module
Import-Module .\MonModule\MonModule.psm1

# Utiliser les fonctions
Get-CustomData
```

### Comparaison

|Méthode|Portée|Persistance|Usage recommandé|
|---|---|---|---|
|**Script normal**|Script uniquement|Session du script|Scripts autonomes|
|**Console**|Session actuelle|Jusqu'à fermeture|Tests rapides, prototypage|
|**Dot-sourcing**|Session actuelle|Jusqu'à fermeture|Charger des utilitaires|
|**Module**|Selon import|Selon import|Distribution, réutilisation|

> [!tip] Bonne pratique
> 
> - **Tests/prototypage** : Console interactive
> - **Scripts personnels** : Dot-sourcing de fichiers de fonctions
> - **Distribution** : Modules PowerShell

---

## 🎯 Portée des fonctions

### Concept de portée (Scope)

La portée détermine où une fonction ou une variable est visible et accessible. PowerShell utilise un système de portées hiérarchiques.

### Hiérarchie des portées

```
Global (Session PowerShell)
    ↓
Script (Fichier .ps1)
    ↓
Local (Fonction ou bloc)
    ↓
Private (Non héritable)
```

### Portée par défaut

```powershell
# Portée globale (définie dans la console)
function Global-Function {
    "Je suis globale"
}

# Portée script (définie dans un fichier .ps1)
function Script-Function {
    "Je suis dans le script"
}

# Portée locale (définie dans une fonction)
function Parent-Function {
    function Local-Function {
        "Je suis locale à Parent-Function"
    }
    Local-Function  # ✅ Accessible ici
}
Local-Function  # ❌ Non accessible ici
```

### Modificateurs de portée explicites

PowerShell permet de spécifier explicitement la portée avec les préfixes :

```powershell
function Test-Scope {
    # Variable locale (par défaut)
    $local:localVar = "Locale"
    
    # Variable de portée script
    $script:scriptVar = "Script"
    
    # Variable de portée globale
    $global:globalVar = "Globale"
    
    # Variable privée (non héritée par les fonctions enfants)
    $private:privateVar = "Privée"
}
```

### Exemples de portée de fonctions

**Exemple 1 : Fonction locale non accessible :**

```powershell
function Outer {
    function Inner {
        "Fonction interne"
    }
    Inner  # ✅ Fonctionne
}

Outer
Inner  # ❌ Erreur : Inner n'existe pas dans cette portée
```

**Exemple 2 : Fonction globale accessible partout :**

```powershell
function Test-Scope {
    # Définir une fonction globale depuis une fonction
    function global:My-GlobalFunction {
        "Je suis accessible partout"
    }
}

Test-Scope
My-GlobalFunction  # ✅ Accessible !
```

**Exemple 3 : Portée script :**

**`Script.ps1` :**

```powershell
# Fonction de portée script
function script:Internal-Helper {
    "Aide interne"
}

function Public-Function {
    Internal-Helper  # ✅ Accessible dans le script
}

Public-Function
Internal-Helper  # ✅ Accessible dans le script

# Après exécution du script, Internal-Helper n'est plus accessible
```

### Interaction avec les variables

Les fonctions héritent des variables des portées parentes :

```powershell
$global:myVar = "Global"

function Test-Inheritance {
    # Lecture de la variable globale
    Write-Host "Valeur : $myVar"
    
    # Modification locale (crée une nouvelle variable locale)
    $myVar = "Local"
    Write-Host "Valeur locale : $myVar"
}

Test-Inheritance
Write-Host "Valeur globale : $myVar"  # Toujours "Global"

function Test-GlobalModification {
    # Modification explicite de la variable globale
    $global:myVar = "Modifiée"
}

Test-GlobalModification
Write-Host "Valeur globale : $myVar"  # Maintenant "Modifiée"
```

### Bonnes pratiques de portée

> [!tip] Recommandations
> 
> 1. **Par défaut, utilisez la portée locale** : Plus sûr et plus prévisible
> 2. **Limitez l'utilisation de la portée globale** : Peut créer des effets de bord
> 3. **Préférez les paramètres et retours** : Au lieu de variables globales
> 4. **Utilisez la portée script pour les helpers internes** : Encapsulation dans un fichier
> 5. **Documentez les fonctions qui modifient la portée globale** : Évitez les surprises

### Tableau récapitulatif

|Portée|Visibilité|Durée de vie|Usage|
|---|---|---|---|
|**Local**|Fonction/bloc actuel|Fin de la fonction|Par défaut, variables temporaires|
|**Script**|Tout le script|Fin du script|Helpers internes, état du script|
|**Global**|Toute la session|Fin de la session|Configuration globale (à limiter)|
|**Private**|Fonction actuelle uniquement|Fin de la fonction|Données sensibles, encapsulation forte|

> [!warning] Attention aux effets de bord Modifier des variables ou définir des fonctions dans la portée globale peut créer des conflits et des bugs difficiles à tracer. Privilégiez toujours la portée la plus restreinte possible.

---

## 🎓 Pièges courants et bonnes pratiques

### ❌ Pièges à éviter

**1. Utiliser des parenthèses pour les appels**

```powershell
# ❌ ERREUR
Get-Greeting("Alice")  # Passe un tableau comme premier argument

# ✅ CORRECT
Get-Greeting -Name "Alice"
Get-Greeting "Alice"
```

**2. Oublier le verbe approuvé**

```powershell
# ❌ Déconseillé
function CheckConnection { }

# ✅ Recommandé
function Test-Connection { }
```

**3. Modifier des variables globales sans le vouloir**

```powershell
# ❌ Effet de bord non intentionnel
function Update-Data {
    $data = "Nouvelle valeur"  # Si $data est globale, elle est écrasée !
}

# ✅ Explicite
function Update-Data {
    $local:data = "Nouvelle valeur"  # Variable locale
}
```

**4. Ne pas gérer le pipeline correctement**

```powershell
# ❌ N'accepte pas le pipeline
function Get-Square {
    param($Number)
    $Number * $Number
}

# ✅ Accepte le pipeline
function Get-Square {
    param(
        [Parameter(ValueFromPipeline)]
        $Number
    )
    process {
        $Number * $Number
    }
}
```

### ✅ Bonnes pratiques

**1. Nommage cohérent**

```powershell
# ✅ Convention Verb-Noun
function Get-UserProfile { }
function Set-UserProfile { }
function Test-UserExists { }
```

**2. Documentation intégrée**

```powershell
function Get-SystemReport {
    <#
    .SYNOPSIS
    Génère un rapport système
    
    .DESCRIPTION
    Cette fonction collecte des informations système et génère un rapport détaillé
    
    .EXAMPLE
    Get-SystemReport
    
    .EXAMPLE
    Get-SystemReport -Detailed
    #>
    # Code de la fonction
}
```

**3. Utiliser les blocs appropriés**

```powershell
# ✅ Structure claire pour le traitement pipeline
function Process-Items {
    begin {
        $results = @()
    }
    process {
        $results += $_ | Transform-Item
    }
    end {
        $results | Format-Output
    }
}
```

**4. Retour de données structurées**

```powershell
# ✅ Retourne un objet personnalisé
function Get-UserInfo {
    [PSCustomObject]@{
        Name     = "Alice"
        Age      = 30
        Department = "IT"
    }
}
```

---

## 🎯 Points clés à retenir

> [!info] Résumé
> 
> - Les fonctions PowerShell utilisent le mot-clé `function` et suivent la convention **Verb-Noun**
> - Trois blocs possibles : `begin` (init), `process` (pipeline), `end` (finalisation)
> - L'appel se fait **sans parenthèses** : `Get-Data -Param "value"`
> - Le dot-sourcing (`. .\script.ps1`) charge les fonctions dans la session courante
> - La portée détermine où les fonctions sont accessibles : local, script, global, private
> - Privilégiez la portée la plus restreinte et évitez les effets de bord globaux

---

_Cours créé pour Obsidian - PowerShell 5.1+_