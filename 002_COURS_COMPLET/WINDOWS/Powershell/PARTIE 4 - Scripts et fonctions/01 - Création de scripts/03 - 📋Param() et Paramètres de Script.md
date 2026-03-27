
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

## 🎯 Introduction

Les paramètres permettent de rendre vos scripts PowerShell **dynamiques** et **réutilisables**. Au lieu de coder des valeurs en dur, vous créez des scripts qui acceptent des entrées, comme les cmdlets natives de PowerShell.

> [!info] Pourquoi utiliser des paramètres ?
> 
> - **Flexibilité** : Un même script peut traiter différentes données
> - **Professionnalisme** : Vos scripts se comportent comme des cmdlets natives
> - **Sécurité** : Validation automatique des entrées
> - **Maintenance** : Code plus propre et plus facile à modifier

---

## 📦 Le bloc Param()

Le bloc `param()` **doit être la première instruction** de votre script (après les commentaires et les directives).

### Syntaxe de base

```powershell
param(
    # Vos paramètres ici
)

# Reste du script
```

### Exemple complet

```powershell
<#
.SYNOPSIS
    Script de démonstration
#>

param(
    [string]$Nom,
    [int]$Age
)

Write-Host "Bonjour $Nom, vous avez $Age ans."
```

> [!warning] Position obligatoire Le bloc `param()` doit être en première position dans le script, sinon PowerShell génère une erreur. Seuls les commentaires d'aide peuvent le précéder.

---

## 🔤 Déclaration de paramètres

### Syntaxe simple

```powershell
param(
    $Parametre1,
    $Parametre2,
    $Parametre3
)
```

### Avec types

```powershell
param(
    [string]$Nom,
    [int]$Age,
    [datetime]$DateNaissance
)
```

### Appel du script

```powershell
# Ordre positionnel
.\MonScript.ps1 "Alice" 30

# Nommé (recommandé)
.\MonScript.ps1 -Nom "Alice" -Age 30

# Mélange
.\MonScript.ps1 "Alice" -Age 30
```

> [!tip] Bonnes pratiques
> 
> - Utilisez toujours des **noms explicites** pour vos paramètres
> - Préférez la notation **nommée** pour la clarté
> - Utilisez le **PascalCase** pour les noms de paramètres

---

## 🎨 Paramètres typés

PowerShell supporte le **typage fort** pour contrôler le type de données acceptées.

### Types courants

|Type|Description|Exemple|
|---|---|---|
|`[string]`|Chaîne de caractères|`"Texte"`|
|`[int]`|Entier 32 bits|`42`|
|`[long]`|Entier 64 bits|`9999999999`|
|`[double]`|Nombre décimal|`3.14`|
|`[bool]`|Booléen|`$true`, `$false`|
|`[datetime]`|Date et heure|`Get-Date`|
|`[array]`|Tableau|`@(1,2,3)`|
|`[hashtable]`|Table de hachage|`@{Cle="Valeur"}`|
|`[switch]`|Commutateur|`-Force`|

### Exemple avec différents types

```powershell
param(
    [string]$Serveur,           # Nom du serveur
    [int]$Port = 80,            # Port réseau
    [datetime]$DateDebut,       # Date de début
    [string[]]$Utilisateurs,    # Tableau de chaînes
    [hashtable]$Configuration   # Table de configuration
)
```

### Conversion automatique

```powershell
param(
    [int]$Nombre
)

# PowerShell convertit automatiquement
.\Script.ps1 -Nombre "42"  # "42" → 42
.\Script.ps1 -Nombre "3.9" # 3.9 → 4 (arrondi)
```

> [!warning] Erreurs de type Si la conversion échoue, PowerShell génère une erreur :
> 
> ```powershell
> .\Script.ps1 -Nombre "abc"
> # Erreur : Cannot convert value "abc" to type "System.Int32"
> ```

---

## ⚠️ Paramètres obligatoires

Utilisez l'attribut `[Parameter(Mandatory)]` pour exiger un paramètre.

### Syntaxe

```powershell
param(
    [Parameter(Mandatory)]
    [string]$CheminFichier,
    
    [Parameter(Mandatory=$true)]  # Équivalent
    [string]$Destination
)
```

### Comportement

```powershell
# Sans le paramètre obligatoire
.\Script.ps1

# PowerShell demande la valeur :
# cmdlet Script.ps1 at command pipeline position 1
# Supply values for the following parameters:
# CheminFichier:
```

> [!example] Exemple complet
> 
> ```powershell
> param(
>     [Parameter(Mandatory)]
>     [string]$NomUtilisateur,
>     
>     [string]$Departement = "IT"  # Optionnel avec défaut
> )
> 
> Write-Host "Création de l'utilisateur : $NomUtilisateur"
> Write-Host "Département : $Departement"
> ```

---

## 🎯 Valeurs par défaut

Assignez des valeurs par défaut pour rendre les paramètres optionnels.

### Syntaxe

```powershell
param(
    [string]$Serveur = "localhost",
    [int]$Port = 8080,
    [string]$Protocole = "https"
)
```

### Exemple pratique

```powershell
param(
    [string]$CheminLog = "C:\Logs\app.log",
    [int]$NiveauVerbose = 1,
    [bool]$EnvoyerEmail = $false
)

Write-Host "Log dans : $CheminLog"
Write-Host "Niveau : $NiveauVerbose"
```

### Appel avec valeurs par défaut

```powershell
# Utilise toutes les valeurs par défaut
.\Script.ps1

# Remplace uniquement Port
.\Script.ps1 -Port 9090

# Remplace plusieurs paramètres
.\Script.ps1 -Serveur "prod.example.com" -Protocole "http"
```

> [!tip] Valeurs par défaut dynamiques Vous pouvez utiliser des expressions :
> 
> ```powershell
> param(
>     [string]$DateDuJour = (Get-Date -Format "yyyy-MM-dd"),
>     [string]$NomFichier = "backup_$(Get-Date -Format 'yyyyMMdd').zip"
> )
> ```

---

## 🏷️ Attributs de paramètres

Les attributs enrichissent les paramètres avec des métadonnées et des comportements spéciaux.

### Mandatory

Force l'utilisateur à fournir une valeur.

```powershell
param(
    [Parameter(Mandatory)]
    [string]$Utilisateur
)
```

---

### Position

Définit l'ordre positionnel des paramètres.

```powershell
param(
    [Parameter(Position=0)]
    [string]$Source,
    
    [Parameter(Position=1)]
    [string]$Destination
)

# Appel positionnel
.\Script.ps1 "C:\Source" "D:\Dest"
```

> [!info] Position par défaut Sans spécifier `Position`, PowerShell assigne automatiquement les positions dans l'ordre de déclaration.

---

### ValueFromPipeline

Permet d'accepter des valeurs depuis le pipeline.

```powershell
param(
    [Parameter(ValueFromPipeline)]
    [string]$NomFichier
)

process {
    Write-Host "Traitement de : $NomFichier"
}

# Utilisation
Get-ChildItem *.txt | .\Script.ps1
```

> [!warning] Bloc Process requis Avec `ValueFromPipeline`, utilisez le bloc `process {}` pour traiter chaque élément du pipeline.

---

### ValueFromPipelineByPropertyName

Lie les paramètres aux propriétés d'objets du pipeline.

```powershell
param(
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$Name,
    
    [Parameter(ValueFromPipelineByPropertyName)]
    [long]$Length
)

process {
    Write-Host "$Name : $Length octets"
}

# Les propriétés Name et Length sont automatiquement liées
Get-ChildItem | .\Script.ps1
```

---

### HelpMessage

Affiche un message d'aide lorsque le paramètre est requis.

```powershell
param(
    [Parameter(
        Mandatory,
        HelpMessage="Entrez le chemin complet du fichier à traiter"
    )]
    [string]$CheminFichier
)

# Si l'utilisateur tape !? à l'invite, le message s'affiche
```

### Combinaison d'attributs

```powershell
param(
    [Parameter(
        Mandatory,
        Position=0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName,
        HelpMessage="Nom de l'ordinateur distant"
    )]
    [string]$ComputerName
)
```

---

## ✅ Validation de paramètres

Les attributs de validation contrôlent les valeurs **avant** l'exécution du script.

### ValidateSet

Restreint aux valeurs d'une liste prédéfinie.

```powershell
param(
    [ValidateSet("Dev", "Test", "Prod")]
    [string]$Environnement
)

# Valide
.\Script.ps1 -Environnement "Prod"

# Invalide - PowerShell affiche les options valides
.\Script.ps1 -Environnement "Production"
```

> [!tip] Auto-complétion `ValidateSet` active **l'auto-complétion** avec Tab dans la console !

---

### ValidateRange

Limite les valeurs numériques à un intervalle.

```powershell
param(
    [ValidateRange(1, 100)]
    [int]$Pourcentage,
    
    [ValidateRange(1024, 65535)]
    [int]$Port
)

# Valide
.\Script.ps1 -Pourcentage 75 -Port 8080

# Invalide
.\Script.ps1 -Pourcentage 150  # Erreur
```

---

### ValidatePattern

Valide selon une expression régulière.

```powershell
param(
    [ValidatePattern('^\d{5}$')]
    [string]$CodePostal,
    
    [ValidatePattern('^[A-Z]{2}\d{3}[A-Z]{2}$')]
    [string]$Plaque,
    
    [ValidatePattern('^\w+@\w+\.\w+$')]
    [string]$Email
)

# Valide
.\Script.ps1 -CodePostal "75001" -Email "user@example.com"

# Invalide
.\Script.ps1 -CodePostal "123"  # Erreur : doit être 5 chiffres
```

---

### ValidateScript

Exécute un script de validation personnalisé.

```powershell
param(
    [ValidateScript({
        Test-Path $_
    })]
    [string]$CheminFichier,
    
    [ValidateScript({
        $_ -gt 0 -and $_ % 2 -eq 0
    })]
    [int]$NombrePair
)

# $_ représente la valeur testée
```

#### Exemple avec message personnalisé

```powershell
param(
    [ValidateScript({
        if (Test-Path $_) {
            $true
        } else {
            throw "Le fichier '$_' n'existe pas."
        }
    })]
    [string]$Fichier
)
```

---

### ValidateNotNull

Interdit les valeurs `$null`.

```powershell
param(
    [ValidateNotNull()]
    [string]$Nom
)

# Invalide
.\Script.ps1 -Nom $null  # Erreur
```

---

### ValidateNotNullOrEmpty

Interdit `$null`, chaînes vides et tableaux vides.

```powershell
param(
    [ValidateNotNullOrEmpty()]
    [string]$Description,
    
    [ValidateNotNullOrEmpty()]
    [string[]]$Serveurs
)

# Invalide
.\Script.ps1 -Description ""  # Erreur
.\Script.ps1 -Serveurs @()    # Erreur
```

---

### ValidateLength

Contrôle la longueur des chaînes.

```powershell
param(
    [ValidateLength(3, 20)]
    [string]$NomUtilisateur,
    
    [ValidateLength(8, 128)]
    [string]$MotDePasse
)

# Valide
.\Script.ps1 -NomUtilisateur "alice" -MotDePasse "P@ssw0rd123"

# Invalide
.\Script.ps1 -NomUtilisateur "ab"  # Trop court
```

---

### ValidateCount

Contrôle le nombre d'éléments dans un tableau.

```powershell
param(
    [ValidateCount(1, 5)]
    [string[]]$Serveurs,
    
    [ValidateCount(2, 10)]
    [int[]]$Ports
)

# Valide
.\Script.ps1 -Serveurs "srv1","srv2" -Ports 80,443

# Invalide
.\Script.ps1 -Serveurs @()  # Trop peu d'éléments
```

---

### Combinaison de validations

```powershell
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(5, 50)]
    [ValidatePattern('^[a-zA-Z0-9_]+$')]
    [string]$Identifiant
)

# Toutes les validations doivent passer
```

> [!example] Exemple réaliste
> 
> ```powershell
> param(
>     [Parameter(Mandatory)]
>     [ValidateSet("Windows", "Linux", "MacOS")]
>     [string]$OS,
>     
>     [Parameter(Mandatory)]
>     [ValidateRange(1, 128)]
>     [int]$CPUs,
>     
>     [ValidateRange(1, 1024)]
>     [int]$RAM = 8,
>     
>     [ValidateScript({ Test-Path $_ })]
>     [string]$ConfigFile
> )
> 
> Write-Host "Configuration : $OS, $CPUs CPUs, $RAM GB RAM"
> ```

---

## 🔘 Paramètres Switch

Les paramètres `[switch]` sont des **booléens simplifiés** : leur présence = `$true`, leur absence = `$false`.

### Syntaxe de base

```powershell
param(
    [switch]$Force,
    [switch]$Verbose,
    [switch]$WhatIf
)

if ($Force) {
    Write-Host "Mode forcé activé"
}
```

### Utilisation

```powershell
# Active les switches
.\Script.ps1 -Force -Verbose

# Les switches sont optionnels
.\Script.ps1

# Désactive explicitement (rare)
.\Script.ps1 -Force:$false
```

### Exemple pratique

```powershell
param(
    [Parameter(Mandatory)]
    [string]$CheminFichier,
    
    [switch]$Recursif,
    [switch]$Force,
    [switch]$Silent
)

if (-not (Test-Path $CheminFichier)) {
    if (-not $Force) {
        Write-Error "Fichier inexistant. Utilisez -Force pour continuer."
        exit
    }
}

if ($Recursif) {
    Write-Host "Mode récursif activé"
}

if (-not $Silent) {
    Write-Host "Traitement en cours..."
}
```

### Différence avec [bool]

|Aspect|`[switch]`|`[bool]`|
|---|---|---|
|Valeur par défaut|`$false`|Doit être spécifié|
|Syntaxe|`-Force`|`-Force $true`|
|Usage|Drapeaux optionnels|Valeurs booléennes explicites|

> [!tip] Quand utiliser Switch ? Utilisez `[switch]` pour des **options on/off** simples comme `-Force`, `-Quiet`, `-Confirm`. Utilisez `[bool]` quand vous avez besoin d'une **valeur booléenne explicite**.

---

## 🔍 Variables spéciales

### $PSBoundParameters

Contient une **hashtable** des paramètres effectivement passés au script.

```powershell
param(
    [string]$Nom,
    [int]$Age,
    [string]$Ville = "Paris"
)

Write-Host "Paramètres fournis :"
$PSBoundParameters.GetEnumerator() | ForEach-Object {
    Write-Host "  $($_.Key) = $($_.Value)"
}
```

#### Appel

```powershell
.\Script.ps1 -Nom "Alice" -Age 30

# Affiche :
# Paramètres fournis :
#   Nom = Alice
#   Age = 30
# (Ville n'apparaît pas car elle utilise la valeur par défaut)
```

#### Cas d'usage

```powershell
# Vérifier si un paramètre a été fourni
if ($PSBoundParameters.ContainsKey('Ville')) {
    Write-Host "Ville explicitement définie : $Ville"
}

# Transmettre des paramètres à une autre fonction
function Fonction-Interne {
    param($Nom, $Age, $Ville)
    # ...
}

Fonction-Interne @PSBoundParameters  # Splatting
```

---

### $args

Tableau contenant **tous les arguments positionnels non liés**.

```powershell
param(
    [string]$Premier
)

Write-Host "Premier paramètre : $Premier"
Write-Host "Arguments supplémentaires : $args"
Write-Host "Nombre d'arguments : $($args.Count)"

# Parcourir les arguments
foreach ($arg in $args) {
    Write-Host "  - $arg"
}
```

#### Appel

```powershell
.\Script.ps1 "Valeur1" "Valeur2" "Valeur3"

# Affiche :
# Premier paramètre : Valeur1
# Arguments supplémentaires : Valeur2 Valeur3
# Nombre d'arguments : 2
#   - Valeur2
#   - Valeur3
```

#### Cas d'usage

```powershell
# Script acceptant un nombre variable d'arguments
param()

Write-Host "Fichiers à traiter :"
foreach ($fichier in $args) {
    if (Test-Path $fichier) {
        Write-Host "✓ $fichier"
    } else {
        Write-Host "✗ $fichier (inexistant)"
    }
}
```

---

### Différences clés

|Variable|Contenu|Usage|
|---|---|---|
|`$PSBoundParameters`|Paramètres **nommés** fournis|Vérifier les paramètres passés, splatting|
|`$args`|Arguments **positionnels** non liés|Paramètres variables, arguments flexibles|

> [!example] Exemple combiné
> 
> ```powershell
> param(
>     [string]$Action = "List"
> )
> 
> Write-Host "Action : $Action"
> Write-Host "Paramètres liés : $($PSBoundParameters.Count)"
> Write-Host "Arguments non liés : $($args.Count)"
> 
> if ($args.Count -gt 0) {
>     Write-Host "Cibles :"
>     $args | ForEach-Object { Write-Host "  - $_" }
> }
> ```

---

## 🎓 Pièges courants

### 1. Ordre des attributs

```powershell
# ❌ Incorrect
param(
    [string]
    [Parameter(Mandatory)]
    $Nom
)

# ✅ Correct
param(
    [Parameter(Mandatory)]
    [string]
    $Nom
)
```

### 2. Validation sur $null

```powershell
# ❌ Ne valide pas $null
param(
    [ValidatePattern('^\d+$')]
    [string]$Nombre
)

# ✅ Empêche $null
param(
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('^\d+$')]
    [string]$Nombre
)
```

### 3. Switch vs Bool

```powershell
# ❌ Trop verbeux
param([bool]$Force)
.\Script.ps1 -Force $true

# ✅ Simple et clair
param([switch]$Force)
.\Script.ps1 -Force
```

### 4. Position des blocs param()

```powershell
# ❌ Erreur - code avant param()
$variable = "test"
param([string]$Nom)

# ✅ Correct
param([string]$Nom)
$variable = "test"
```

---

## 💡 Astuces avancées

### Paramètres mutuellement exclusifs

```powershell
param(
    [Parameter(ParameterSetName="ByName")]
    [string]$Nom,
    
    [Parameter(ParameterSetName="ById")]
    [int]$Id
)

# Permet soit -Nom soit -Id, mais pas les deux
```

### Alias de paramètres

```powershell
param(
    [Alias("ComputerName", "CN", "MachineName")]
    [string]$Serveur
)

# Tous ces appels sont équivalents :
.\Script.ps1 -Serveur "SRV01"
.\Script.ps1 -ComputerName "SRV01"
.\Script.ps1 -CN "SRV01"
```

### Splatting avec PSBoundParameters

```powershell
function Fonction-Parent {
    param(
        [string]$Param1,
        [int]$Param2,
        [switch]$Verbose
    )
    
    # Transmet tous les paramètres à la fonction enfant
    Fonction-Enfant @PSBoundParameters
}
```

### Paramètres dynamiques

```powershell
param(
    [string]$Type
)

# Charge des paramètres supplémentaires selon $Type
DynamicParam {
    if ($Type -eq "Serveur") {
        # Ajoute des paramètres spécifiques aux serveurs
    }
}
```

---

## 📊 Tableau récapitulatif des validations

|Validation|Usage|Exemple|
|---|---|---|
|`ValidateSet`|Liste de valeurs|`[ValidateSet("A","B","C")]`|
|`ValidateRange`|Intervalle numérique|`[ValidateRange(1,100)]`|
|`ValidatePattern`|Expression régulière|`[ValidatePattern('^\d{5}$')]`|
|`ValidateScript`|Test personnalisé|`[ValidateScript({Test-Path $_})]`|
|`ValidateNotNull`|Interdit $null|`[ValidateNotNull()]`|
|`ValidateNotNullOrEmpty`|Interdit $null et vide|`[ValidateNotNullOrEmpty()]`|
|`ValidateLength`|Longueur de chaîne|`[ValidateLength(3,20)]`|
|`ValidateCount`|Nombre d'éléments|`[ValidateCount(1,5)]`|

---

## ✨ Bonnes pratiques finales

> [!tip] Recommandations
> 
> 1. **Toujours typer** vos paramètres pour éviter les erreurs
> 2. **Valider les entrées** dès que possible (fail fast)
> 3. **Documenter** avec des HelpMessage clairs
> 4. **Utiliser des valeurs par défaut** sensées
> 5. **Préférer [switch]** aux [bool] pour les flags
> 6. **Tester** tous les cas limites de validation
> 7. **Utiliser ParameterSets** pour des logiques mutuellement exclusives

---

> [!info] Points clés à retenir
> 
> - Le bloc `param()` doit être **en première position**
> - Les **attributs** enrichissent les paramètres (Mandatory, Position, etc.)
> - Les **validations** contrôlent les données avant exécution
> - `[switch]` simplifie les paramètres booléens
> - `$PSBoundParameters` et `$args` offrent une flexibilité supplémentaire

---

_Fin du cours sur Param() et les paramètres de script_