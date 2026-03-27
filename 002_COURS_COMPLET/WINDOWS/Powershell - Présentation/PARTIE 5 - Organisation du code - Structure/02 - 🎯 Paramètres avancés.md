

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

## 🔧 Le bloc param() détaillé

Le bloc `param()` est la première chose qui doit apparaître dans votre script (après les commentaires d'aide). Il définit l'interface de votre script avec l'utilisateur.

### Syntaxe de base

```powershell
param(
    [Type]$NomParametre1,
    [Type]$NomParametre2,
    [Type]$NomParametre3 = "ValeurParDefaut"
)
```

### Positionnement dans le script

```powershell
<# 
.SYNOPSIS
    Description courte du script
#>

param(
    # Les paramètres viennent ici
)

# Le reste du code vient après
Write-Host "Début du script..."
```

> [!info] Ordre d'apparition L'ordre correct dans un script PowerShell est :
> 
> 1. Commentaires d'aide (`<# ... #>`)
> 2. Bloc `param()`
> 3. Code du script

### Typage des paramètres

Le typage permet de contrôler quel type de données peut être accepté :

```powershell
param(
    [string]$Nom,                    # Chaîne de caractères
    [int]$Age,                       # Nombre entier
    [bool]$EstActif,                 # Booléen (vrai/faux)
    [datetime]$DateNaissance,        # Date et heure
    [System.IO.FileInfo]$Fichier,    # Objet fichier
    [array]$ListeElements,           # Tableau
    [hashtable]$Configuration        # Table de hachage
)
```

> [!warning] Conversion automatique PowerShell tente automatiquement de convertir les valeurs fournies vers le type spécifié. Si la conversion échoue, une erreur est générée.

---

## ✅ Paramètres obligatoires vs optionnels

Par défaut, tous les paramètres sont **optionnels**. Pour rendre un paramètre obligatoire, utilisez l'attribut `[Parameter(Mandatory)]`.

### Paramètres obligatoires

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$NomUtilisateur,
    
    [Parameter(Mandatory)]  # $true est implicite
    [string]$MotDePasse
)
```

> [!example] Comportement Si l'utilisateur ne fournit pas un paramètre obligatoire, PowerShell lui demandera de le saisir interactivement :
> 
> ```
> cmdlet Script.ps1 at command pipeline position 1
> Supply values for the following parameters:
> NomUtilisateur:
> ```

### Paramètres optionnels avec message personnalisé

```powershell
param(
    [Parameter(Mandatory=$true, HelpMessage="Entrez le nom du serveur à surveiller")]
    [string]$NomServeur
)
```

### Combinaison obligatoire/optionnel

```powershell
param(
    # Obligatoire
    [Parameter(Mandatory)]
    [string]$Source,
    
    # Optionnels avec valeurs par défaut
    [string]$Destination = "C:\Backup",
    [int]$NombreJours = 7,
    
    # Optionnel sans valeur par défaut
    [string]$Email
)
```

> [!tip] Bonne pratique Placez les paramètres obligatoires en premier dans votre bloc `param()` pour une meilleure lisibilité.

---

## 🛡️ Validation des paramètres

PowerShell offre plusieurs attributs de validation pour contrôler les valeurs acceptées **avant** l'exécution du code principal.

### [ValidateSet] - Liste de valeurs autorisées

Restreint le paramètre à une liste prédéfinie de valeurs :

```powershell
param(
    [Parameter(Mandatory)]
    [ValidateSet("Production", "Test", "Developpement")]
    [string]$Environnement,
    
    [ValidateSet("Erreur", "Avertissement", "Information", "Verbose")]
    [string]$NiveauLog = "Information"
)

# Utilisation
# ✅ .\Script.ps1 -Environnement Production
# ❌ .\Script.ps1 -Environnement Preprod  # Erreur !
```

> [!info] Autocomplétion Avec `ValidateSet`, PowerShell propose automatiquement les valeurs valides via la touche Tab (autocomplétion).

### [ValidateRange] - Plage de valeurs numériques

Limite un nombre à une plage définie :

```powershell
param(
    [Parameter(Mandatory)]
    [ValidateRange(1, 100)]
    [int]$Pourcentage,
    
    [ValidateRange(1024, 65535)]
    [int]$Port = 8080,
    
    [ValidateRange(1, [int]::MaxValue)]
    [int]$NombreIterations = 10
)

# ✅ -Pourcentage 75
# ❌ -Pourcentage 150  # Erreur : valeur hors plage
```

### [ValidatePattern] - Expression régulière

Valide le format d'une chaîne avec une regex :

```powershell
param(
    # Adresse email simple
    [ValidatePattern("^[\w\.-]+@[\w\.-]+\.\w+$")]
    [string]$Email,
    
    # Adresse IP
    [ValidatePattern("^(\d{1,3}\.){3}\d{1,3}$")]
    [string]$AdresseIP,
    
    # Code postal français
    [ValidatePattern("^\d{5}$")]
    [string]$CodePostal,
    
    # Numéro de téléphone français
    [ValidatePattern("^0[1-9](\d{2}){4}$")]
    [string]$Telephone
)
```

> [!warning] Messages d'erreur Les messages d'erreur de `ValidatePattern` peuvent être cryptiques. Ajoutez un `HelpMessage` pour guider l'utilisateur.

### [ValidateLength] - Longueur de chaîne

Contrôle la longueur minimale et maximale d'une chaîne :

```powershell
param(
    # Minimum 3 caractères, maximum 20
    [ValidateLength(3, 20)]
    [string]$NomUtilisateur,
    
    # Minimum 8 caractères (pas de maximum)
    [ValidateLength(8, [int]::MaxValue)]
    [string]$MotDePasse
)
```

### [ValidateCount] - Nombre d'éléments dans un tableau

```powershell
param(
    # Entre 1 et 5 serveurs
    [ValidateCount(1, 5)]
    [string[]]$Serveurs,
    
    # Au moins 2 emails
    [ValidateCount(2, [int]::MaxValue)]
    [string[]]$Destinataires
)

# Utilisation
# .\Script.ps1 -Serveurs "SRV01", "SRV02", "SRV03"
```

### [ValidateScript] - Validation personnalisée

Pour des validations complexes, utilisez un script :

```powershell
param(
    # Le chemin doit exister
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$DossierSource,
    
    # Le fichier doit être un .csv
    [ValidateScript({
        if ($_ -notmatch "\.csv$") {
            throw "Le fichier doit avoir l'extension .csv"
        }
        return $true
    })]
    [string]$FichierCSV,
    
    # L'espace disque doit être suffisant (> 1GB)
    [ValidateScript({
        $drive = Get-PSDrive -Name ($_.Substring(0,1))
        if ($drive.Free -lt 1GB) {
            throw "Espace disque insuffisant sur le lecteur $($drive.Name)"
        }
        return $true
    })]
    [string]$Destination
)
```

> [!tip] Variable $_ Dans `ValidateScript`, `$_` représente la valeur du paramètre à valider.

### [ValidateNotNullOrEmpty] - Non vide

Empêche les valeurs nulles ou vides :

```powershell
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$NomServeur,
    
    [ValidateNotNullOrEmpty()]
    [string[]]$ListeFichiers
)
```

### Combinaison de validations

Vous pouvez cumuler plusieurs validations :

```powershell
param(
    [Parameter(Mandatory, HelpMessage="Nom d'utilisateur Windows valide")]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(3, 20)]
    [ValidatePattern("^[a-zA-Z][a-zA-Z0-9_-]*$")]
    [string]$NomUtilisateur
)
```

> [!example] Tableau de comparaison

|Validation|Usage|Exemple|
|---|---|---|
|`ValidateSet`|Liste fermée de valeurs|Environnements, statuts, choix fixes|
|`ValidateRange`|Plage numérique|Pourcentages, ports, âges|
|`ValidatePattern`|Format spécifique|Emails, IPs, codes postaux|
|`ValidateLength`|Longueur de texte|Mots de passe, identifiants|
|`ValidateCount`|Nombre d'éléments|Listes avec min/max|
|`ValidateScript`|Validation complexe|Existence de fichiers, logique métier|
|`ValidateNotNullOrEmpty`|Valeur non vide|Champs requis|

---

## 🔘 Paramètres de type Switch

Les **switches** sont des paramètres booléens qui ne nécessitent pas de valeur. Leur simple présence signifie `$true`, leur absence signifie `$false`.

### Syntaxe de base

```powershell
param(
    [switch]$Force,
    [switch]$Verbose,
    [switch]$Recursif
)

# Utilisation
if ($Force) {
    Write-Host "Mode forcé activé"
}

if ($Recursif) {
    # Traitement récursif
}
```

### Appel du script

```powershell
# Sans switch (valeur = $false)
.\Script.ps1

# Avec switch (valeur = $true)
.\Script.ps1 -Force -Verbose

# Forme explicite (rarement utilisée)
.\Script.ps1 -Force:$true
.\Script.ps1 -Force:$false
```

### Cas d'usage typiques

```powershell
param(
    [Parameter(Mandatory)]
    [string]$CheminSource,
    
    [string]$CheminDestination = ".\Backup",
    
    # Forcer l'écrasement sans confirmation
    [switch]$Force,
    
    # Afficher des détails supplémentaires
    [switch]$Verbose,
    
    # Mode simulation (ne fait rien réellement)
    [switch]$WhatIf,
    
    # Traiter les sous-dossiers
    [switch]$Recursif
)

# Exemple d'utilisation dans le code
if ($Force -or (Test-Path $CheminDestination) -eq $false) {
    Copy-Item -Path $CheminSource -Destination $CheminDestination
} else {
    Write-Warning "La destination existe. Utilisez -Force pour écraser."
}

if ($Verbose) {
    Write-Host "Copie de $CheminSource vers $CheminDestination"
}

if ($WhatIf) {
    Write-Host "SIMULATION : Copy-Item $CheminSource -> $CheminDestination"
    return
}
```

> [!tip] Convention de nommage Les switches utilisent généralement des noms qui décrivent une action ou un état :
> 
> - Actions : `-Force`, `-Confirm`, `-Wait`, `-Recurse`
> - États : `-Enabled`, `-Active`, `-Quiet`, `-Silent`

### Switch avec validation

Bien que rare, vous pouvez ajouter des validations aux switches :

```powershell
param(
    [ValidateScript({
        if ($_ -and $env:USERNAME -ne "Admin") {
            throw "Le switch -Force nécessite des droits administrateur"
        }
        return $true
    })]
    [switch]$Force
)
```

---

## 🎯 Valeurs par défaut

Les valeurs par défaut permettent de rendre vos scripts plus conviviaux en définissant des comportements standards.

### Syntaxe

```powershell
param(
    [string]$Serveur = "localhost",
    [int]$Port = 8080,
    [string]$CheminLog = "C:\Logs\script.log",
    [array]$Extensions = @(".txt", ".log", ".csv")
)
```

### Valeurs par défaut dynamiques

Vous pouvez utiliser des expressions PowerShell :

```powershell
param(
    # Date du jour
    [datetime]$Date = (Get-Date),
    
    # Nom de l'utilisateur actuel
    [string]$Utilisateur = $env:USERNAME,
    
    # Dossier temporaire du système
    [string]$DossierTemp = $env:TEMP,
    
    # Nom de la machine
    [string]$NomMachine = $env:COMPUTERNAME,
    
    # Chemin du script actuel
    [string]$CheminScript = $PSScriptRoot,
    
    # Date formatée pour un nom de fichier
    [string]$Horodatage = (Get-Date -Format "yyyyMMdd_HHmmss")
)
```

### Valeurs par défaut conditionnelles

Pour des valeurs par défaut plus complexes, initialisez-les après le bloc `param()` :

```powershell
param(
    [string]$CheminSortie,
    [string]$NomFichier
)

# Définir des valeurs par défaut si non fournies
if (-not $CheminSortie) {
    $CheminSortie = Join-Path $PSScriptRoot "Sortie"
}

if (-not $NomFichier) {
    $NomFichier = "Export_$(Get-Date -Format 'yyyyMMdd').csv"
}

# Créer le dossier s'il n'existe pas
if (-not (Test-Path $CheminSortie)) {
    New-Item -ItemType Directory -Path $CheminSortie | Out-Null
}
```

> [!warning] Évaluation des valeurs par défaut Les valeurs par défaut dans `param()` sont évaluées **une seule fois** au démarrage du script, pas à chaque appel d'une fonction.

### Valeurs par défaut avec validation

```powershell
param(
    [ValidateSet("Production", "Test", "Dev")]
    [string]$Environnement = "Test",  # Par défaut : Test
    
    [ValidateRange(1, 100)]
    [int]$NombreThreads = 4,  # Par défaut : 4 threads
    
    [ValidatePattern("^[\w\.-]+@[\w\.-]+\.\w+$")]
    [string]$EmailAdmin = "admin@example.com"
)
```

### Tableaux et hashtables par défaut

```powershell
param(
    # Tableau par défaut
    [string[]]$Extensions = @(".txt", ".log", ".csv", ".xml"),
    
    # Hashtable par défaut
    [hashtable]$Configuration = @{
        Timeout = 30
        MaxRetry = 3
        EnableLogging = $true
    }
)

# Utilisation
foreach ($ext in $Extensions) {
    Write-Host "Recherche des fichiers $ext"
}

Write-Host "Timeout configuré : $($Configuration.Timeout) secondes"
```

> [!tip] Nullabilité Si un paramètre optionnel n'a **pas** de valeur par défaut, sa valeur sera `$null` si non fourni.

---

## 📖 Help automatique avec Get-Help

PowerShell peut générer une aide automatique pour vos scripts en utilisant des **commentaires structurés** placés avant le bloc `param()`.

### Syntaxe de base de l'aide

```powershell
<#
.SYNOPSIS
    Description courte du script (une ligne)

.DESCRIPTION
    Description détaillée de ce que fait le script,
    son fonctionnement et ses cas d'usage.

.PARAMETER NomParametre1
    Description du premier paramètre

.PARAMETER NomParametre2
    Description du deuxième paramètre

.EXAMPLE
    .\MonScript.ps1 -NomParametre1 "Valeur"
    Description de cet exemple

.EXAMPLE
    .\MonScript.ps1 -NomParametre1 "Valeur" -NomParametre2 42
    Description d'un deuxième exemple

.NOTES
    Auteur : Votre Nom
    Date : 2025-01-01
    Version : 1.0

.LINK
    https://documentation.exemple.com
#>

param(
    [Parameter(Mandatory)]
    [string]$NomParametre1,
    
    [int]$NomParametre2 = 10
)
```

### Mots-clés disponibles

|Mot-clé|Description|Requis|
|---|---|---|
|`.SYNOPSIS`|Résumé court (1 ligne)|Recommandé|
|`.DESCRIPTION`|Description détaillée|Recommandé|
|`.PARAMETER`|Description d'un paramètre (un par paramètre)|Optionnel|
|`.EXAMPLE`|Exemple d'utilisation (plusieurs possibles)|Recommandé|
|`.INPUTS`|Types d'objets acceptés en pipeline|Optionnel|
|`.OUTPUTS`|Types d'objets retournés|Optionnel|
|`.NOTES`|Informations supplémentaires|Optionnel|
|`.LINK`|Lien vers documentation externe|Optionnel|
|`.COMPONENT`|Composant ou technologie utilisée|Optionnel|
|`.ROLE`|Rôle requis pour exécuter|Optionnel|
|`.FUNCTIONALITY`|Fonctionnalité générale|Optionnel|

### Exemple complet et professionnel

```powershell
<#
.SYNOPSIS
    Sauvegarde et compresse des fichiers journaux avec rotation automatique.

.DESCRIPTION
    Ce script parcourt un dossier de logs, compresse les fichiers anciens,
    et les déplace vers un répertoire d'archive. Il effectue une rotation
    automatique en supprimant les archives au-delà de la période de rétention.
    
    Le script supporte plusieurs formats de compression et peut envoyer
    un rapport par email à la fin de l'opération.

.PARAMETER CheminSource
    Chemin du dossier contenant les fichiers logs à traiter.
    Peut être un chemin local ou UNC.

.PARAMETER CheminArchive
    Chemin du dossier où stocker les archives compressées.
    Le dossier sera créé automatiquement s'il n'existe pas.

.PARAMETER JoursRetention
    Nombre de jours de rétention des archives.
    Les archives plus anciennes seront automatiquement supprimées.
    Valeur par défaut : 30 jours.

.PARAMETER FormatCompression
    Format de compression à utiliser.
    Valeurs acceptées : ZIP, 7Z, TAR
    Par défaut : ZIP

.PARAMETER EnvoyerEmail
    Active l'envoi d'un email de rapport à la fin du traitement.

.PARAMETER EmailDestinataire
    Adresse email du destinataire du rapport.
    Requis si -EnvoyerEmail est activé.

.EXAMPLE
    .\Backup-Logs.ps1 -CheminSource "C:\Logs" -CheminArchive "D:\Archives"
    
    Archive tous les logs de C:\Logs vers D:\Archives avec les paramètres par défaut.

.EXAMPLE
    .\Backup-Logs.ps1 -CheminSource "C:\Logs" -CheminArchive "D:\Archives" -JoursRetention 90 -FormatCompression 7Z
    
    Archive les logs avec une rétention de 90 jours et compression 7-Zip.

.EXAMPLE
    .\Backup-Logs.ps1 -CheminSource "C:\Logs" -CheminArchive "D:\Archives" -EnvoyerEmail -EmailDestinataire "admin@exemple.com"
    
    Archive les logs et envoie un rapport par email.

.INPUTS
    Aucun. Ce script n'accepte pas d'entrée par pipeline.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Retourne un objet contenant les statistiques de l'opération :
    - NombreFichiersTraites
    - TailleOriginale
    - TailleCompresse
    - TauxCompression

.NOTES
    Auteur : Jean Dupont
    Date de création : 2025-01-15
    Version : 2.1
    
    Prérequis :
    - PowerShell 5.1 ou supérieur
    - Module 7Zip4PowerShell (si utilisation du format 7Z)
    - Droits d'écriture sur les dossiers source et archive
    
    Changelog :
    - v2.1 : Ajout du support 7-Zip
    - v2.0 : Ajout de l'envoi d'email
    - v1.0 : Version initiale

.LINK
    https://docs.exemple.com/scripts/backup-logs

.LINK
    https://github.com/exemple/backup-logs

.COMPONENT
    Storage, Compression

.ROLE
    Administrator

.FUNCTIONALITY
    Archivage et rotation de fichiers journaux
#>

param(
    [Parameter(Mandatory, HelpMessage="Chemin du dossier source contenant les logs")]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$CheminSource,
    
    [Parameter(Mandatory)]
    [string]$CheminArchive,
    
    [ValidateRange(1, 3650)]
    [int]$JoursRetention = 30,
    
    [ValidateSet("ZIP", "7Z", "TAR")]
    [string]$FormatCompression = "ZIP",
    
    [switch]$EnvoyerEmail,
    
    [ValidatePattern("^[\w\.-]+@[\w\.-]+\.\w+$")]
    [string]$EmailDestinataire
)

# Code du script...
```

### Utilisation de Get-Help

Une fois l'aide définie, les utilisateurs peuvent y accéder :

```powershell
# Aide courte
Get-Help .\MonScript.ps1

# Aide détaillée
Get-Help .\MonScript.ps1 -Detailed

# Aide complète (avec exemples)
Get-Help .\MonScript.ps1 -Full

# Uniquement les exemples
Get-Help .\MonScript.ps1 -Examples

# Uniquement un paramètre spécifique
Get-Help .\MonScript.ps1 -Parameter CheminSource

# Ouvrir l'aide dans une fenêtre séparée
Get-Help .\MonScript.ps1 -ShowWindow
```

### Aide en ligne

Vous pouvez aussi créer une aide en ligne :

```powershell
<#
.SYNOPSIS
    Mon super script

.DESCRIPTION
    Description détaillée

.LINK
    https://docs.exemple.com/mon-script
    
.EXTERNALHELP https://docs.exemple.com/mon-script/help.xml
#>
```

> [!info] Emplacement de l'aide Les commentaires d'aide peuvent être placés :
> 
> - Au début du script (avant `param()`) ← **Recommandé**
> - Juste avant la fonction
> - À la fin du script (après tout le code)

### Bonnes pratiques pour l'aide

> [!tip] Conseils rédactionnels
> 
> - **SYNOPSIS** : Une phrase courte et percutante (sujet + verbe + complément)
> - **DESCRIPTION** : Expliquez le "quoi" et le "pourquoi", pas seulement le "comment"
> - **PARAMETER** : Décrivez ce que représente le paramètre, pas son type (déjà visible)
> - **EXAMPLE** : Montrez des cas d'usage réels et progressifs (simple → complexe)
> - **NOTES** : Informations sur les prérequis, versions, auteur, changelog

> [!warning] Erreurs courantes
> 
> - Oublier de documenter un paramètre
> - Mettre des exemples qui ne fonctionnent pas
> - Description trop technique et peu claire
> - Absence d'exemples concrets

### Aide et paramètres

L'aide des paramètres peut aussi être intégrée directement :

```powershell
param(
    [Parameter(
        Mandatory,
        HelpMessage = "Entrez le nom du serveur à surveiller (ex: SRV-PROD-01)",
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
    )]
    [ValidateNotNullOrEmpty()]
    [string]$NomServeur
)
```

Lorsque l'utilisateur ne fournit pas le paramètre, PowerShell affiche le `HelpMessage` :

```
cmdlet Script.ps1 at command pipeline position 1
Supply values for the following parameters:
(Type !? for Help.)
NomServeur: !?
Entrez le nom du serveur à surveiller (ex: SRV-PROD-01)
NomServeur:
```

---

## 🎓 Pièges courants et bonnes pratiques

### ❌ Pièges à éviter

1. **Oublier le typage des paramètres**

```powershell
# Mauvais : pas de typage
param($Port)

# Bon : typage explicite
param([int]$Port)
```

2. **Validation trop permissive**

```powershell
# Mauvais : accepte n'importe quoi
param([string]$Email)

# Bon : validation du format
param(
    [ValidatePattern("^[\w\.-]+@[\w\.-]+\.\w+$")]
    [string]$Email
)
```

3. **Valeurs par défaut incohérentes avec la validation**

```powershell
# Mauvais : la valeur par défaut ne respecte pas la validation !
param(
    [ValidateRange(1, 10)]
    [int]$Nombre = 50  # ❌ Erreur au chargement du script
)

# Bon
param(
    [ValidateRange(1, 10)]
    [int]$Nombre = 5  # ✅ Valide
)
```

4. **Trop de paramètres obligatoires**

```powershell
# Mauvais : trop contraignant pour l'utilisateur
param(
    [Parameter(Mandatory)] [string]$Param1,
    [Parameter(Mandatory)] [string]$Param2,
    [Parameter(Mandatory)] [string]$Param3,
    [Parameter(Mandatory)] [string]$Param4,
    [Parameter(Mandatory)] [string]$Param5
)

# Bon : paramètres obligatoires minimaux avec valeurs par défaut intelligentes
param(
    [Parameter(Mandatory)] [string]$Source,
    [string]$Destination = ".\Backup",
    [int]$JoursRetention = 7
)
```

### ✅ Bonnes pratiques

1. **Nommage clair et cohérent**

```powershell
# Utilisez des noms descriptifs avec PascalCase
param(
    [string]$CheminSource,        # ✅ Clair
    [string]$NomServeur,          # ✅ Descriptif
    [int]$NombreThreads           # ✅ Explicite
)
```

2. **Groupement logique**

```powershell
param(
    # === Paramètres d'entrée ===
    [Parameter(Mandatory)]
    [string]$CheminSource,
    
    [string]$CheminDestination = ".\Backup",
    
    # === Options de traitement ===
    [switch]$Recursif,
    [switch]$Force,
    
    # === Configuration ===
    [ValidateRange(1, 100)]
    [int]$NombreThreads = 4,
    
    [ValidateSet("Faible", "Normal", "Eleve")]
    [string]$Priorite = "Normal"
)
```

3. **Messages d'aide utiles**

```powershell
param(
    [Parameter(
        Mandatory,
        HelpMessage = "Chemin du dossier source (ex: C:\Data ou \\SERVEUR\Partage)"
    )]
    [ValidateScript({
        if (-not (Test-Path $_)) {
            throw "Le chemin '$_' n'existe pas. Vérifiez le chemin et réessayez."
        }
        return $true
    })]
    [string]$CheminSource
)
```

4. **Validation en cascade**

```powershell
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(3, 50)]
    [ValidatePattern("^[a-zA-Z0-9_-]+$")]
    [string]$NomProjet
)
```

5. **Documentation complète**

```powershell
<#
.SYNOPSIS
    Résumé court et percutant

.PARAMETER CheminSource
    Description claire avec exemples concrets
    
.EXAMPLE
    .\Script.ps1 -CheminSource "C:\Data"
    Exemple réaliste et fonctionnel
#>
```

---

## 🔍 Astuces avancées

### Paramètres mutuellement exclusifs avec ParameterSet

Utilisez les `ParameterSet` pour créer des groupes de paramètres exclusifs :

```powershell
param(
    # Recherche par ID
    [Parameter(Mandatory, ParameterSetName="ById")]
    [int]$Id,
    
    # Recherche par Nom
    [Parameter(Mandatory, ParameterSetName="ByName")]
    [string]$Nom,
    
    # Paramètre commun aux deux sets
    [Parameter()]
    [switch]$Verbose
)

# L'utilisateur DOIT choisir soit -Id SOIT -Nom, pas les deux
# ✅ .\Script.ps1 -Id 123
# ✅ .\Script.ps1 -Nom "Serveur01"
# ❌ .\Script.ps1 -Id 123 -Nom "Serveur01"  # Erreur !
```

### Accepter les valeurs du pipeline

```powershell
param(
    [Parameter(
        Mandatory,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [string]$NomFichier
)

# Permet : Get-ChildItem *.txt | .\Script.ps1
```

### Alias de paramètres

```powershell
param(
    [Parameter(Mandatory)]
    [Alias("Server", "ComputerName", "CN")]
    [string]$NomServeur
)

# Toutes ces syntaxes fonctionnent :
# -NomServeur "SRV01"
# -Server "SRV01"
# -ComputerName "SRV01"
# -CN "SRV01"
```

### Valeurs calculées avec getter/setter (propriété calculée)

Pour des validations ou transformations complexes, utilisez une variable privée :

```powershell
param()

# Variable privée
$_cheminNormalise = ""

# Propriété publique avec logique
$CheminSource = @{
    Get = { return $_cheminNormalise }
    Set = { 
        param($value)
        # Normalisation automatique du chemin
        $_cheminNormalise = (Resolve-Path $value).Path
    }
}

# Utilisation
$CheminSource.Set(".\data")
Write-Host $CheminSource.Get()  # Affiche le chemin complet normalisé
```

### Validation avec messages d'erreur personnalisés

```powershell
param(
    [ValidateScript({
        $disque = Get-PSDrive -Name ($_.Substring(0,1)) -ErrorAction SilentlyContinue
        if (-not $disque) {
            throw "Le lecteur '$($_.Substring(0,1)):' n'existe pas"
        }
        if ($disque.Free -lt 1GB) {
            throw "Espace insuffisant sur $($_.Substring(0,1)): (Disponible: $([math]::Round($disque.Free/1GB, 2)) GB)"
        }
        if (-not (Test-Path $_ -PathType Container)) {
            throw "Le dossier '$_' n'existe pas"
        }
        return $true
    })]
    [string]$Destination
)
```

### Paramètres dynamiques (avancé)

Pour créer des paramètres qui apparaissent selon certaines conditions :

```powershell
[CmdletBinding()]
param(
    [ValidateSet("Fichier", "Base", "API")]
    [string]$TypeSource = "Fichier"
)

DynamicParam {
    # Si TypeSource = "Fichier", ajouter le paramètre CheminFichier
    if ($TypeSource -eq "Fichier") {
        $attributs = New-Object System.Management.Automation.ParameterAttribute
        $attributs.Mandatory = $true
        
        $attributCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $attributCollection.Add($attributs)
        
        $paramCheminFichier = New-Object System.Management.Automation.RuntimeDefinedParameter(
            'CheminFichier', [string], $attributCollection
        )
        
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add('CheminFichier', $paramCheminFichier)
        
        return $paramDictionary
    }
}

# Le paramètre -CheminFichier n'existe QUE si -TypeSource "Fichier"
```

> [!warning] Complexité Les paramètres dynamiques sont puissants mais complexes. Utilisez-les uniquement si vraiment nécessaire.

### Splatting pour appeler avec de nombreux paramètres

Quand vous avez beaucoup de paramètres, utilisez le **splatting** :

```powershell
# Au lieu de :
.\Script.ps1 -CheminSource "C:\Data" -CheminDestination "D:\Backup" -JoursRetention 30 -FormatCompression "ZIP" -EnvoyerEmail -EmailDestinataire "admin@exemple.com"

# Utilisez :
$params = @{
    CheminSource = "C:\Data"
    CheminDestination = "D:\Backup"
    JoursRetention = 30
    FormatCompression = "ZIP"
    EnvoyerEmail = $true
    EmailDestinataire = "admin@exemple.com"
}

.\Script.ps1 @params  # Notez le @ au lieu du $
```

### Afficher les valeurs des paramètres (debug)

```powershell
param(
    [string]$Serveur,
    [int]$Port,
    [switch]$Force
)

# Afficher tous les paramètres et leurs valeurs
Write-Host "`n=== Paramètres reçus ===" -ForegroundColor Cyan
$PSBoundParameters.GetEnumerator() | ForEach-Object {
    Write-Host "  $($_.Key) = $($_.Value)" -ForegroundColor Yellow
}
Write-Host "========================`n" -ForegroundColor Cyan
```

---

## 📊 Résumé des attributs de validation

|Attribut|Syntaxe|Usage|
|---|---|---|
|**ValidateSet**|`[ValidateSet("A","B","C")]`|Valeurs prédéfinies uniquement|
|**ValidateRange**|`[ValidateRange(1, 100)]`|Nombres dans une plage|
|**ValidateLength**|`[ValidateLength(3, 20)]`|Longueur de chaîne|
|**ValidateCount**|`[ValidateCount(1, 5)]`|Nombre d'éléments dans tableau|
|**ValidatePattern**|`[ValidatePattern("^\d+$")]`|Format via regex|
|**ValidateScript**|`[ValidateScript({...})]`|Validation personnalisée|
|**ValidateNotNull**|`[ValidateNotNull()]`|Non null|
|**ValidateNotNullOrEmpty**|`[ValidateNotNullOrEmpty()]`|Non null ET non vide|

---

## 🎯 Checklist finale pour vos paramètres

Avant de finaliser votre script, vérifiez :

- [ ] **Tous les paramètres ont un type explicite** (`[string]`, `[int]`, etc.)
- [ ] **Les paramètres obligatoires sont clairement identifiés** avec `[Parameter(Mandatory)]`
- [ ] **Les validations appropriées sont en place** (Set, Range, Pattern, Script...)
- [ ] **Les valeurs par défaut sont cohérentes** avec les validations
- [ ] **L'aide est complète** (SYNOPSIS, DESCRIPTION, PARAMETER, EXAMPLE)
- [ ] **Les noms de paramètres sont clairs** et suivent PascalCase
- [ ] **Les switches sont utilisés** pour les options booléennes
- [ ] **Les paramètres sont ordonnés logiquement** (obligatoires d'abord)
- [ ] **Les messages HelpMessage sont informatifs** pour guider l'utilisateur
- [ ] **Le script a été testé** avec `Get-Help` pour vérifier l'aide

---

## 💡 Exemple de script complet et professionnel

Voici un exemple qui combine toutes les bonnes pratiques :

```powershell
<#
.SYNOPSIS
    Exporte les événements du journal Windows dans un fichier CSV.

.DESCRIPTION
    Ce script extrait les événements d'un journal Windows spécifié,
    les filtre selon le niveau de gravité et la période définie,
    puis les exporte dans un fichier CSV horodaté.
    
    Il supporte plusieurs journaux système et permet une filtration
    avancée par source et ID d'événement.

.PARAMETER NomJournal
    Nom du journal Windows à interroger.
    Valeurs acceptées : Application, System, Security, Setup

.PARAMETER CheminExport
    Dossier où créer le fichier CSV d'export.
    Le fichier sera nommé automatiquement avec la date.
    Par défaut : dossier du script

.PARAMETER NiveauGravite
    Niveau minimum de gravité des événements à exporter.
    Valeurs : Critique, Erreur, Avertissement, Information
    Par défaut : Avertissement

.PARAMETER JoursHistorique
    Nombre de jours d'historique à extraire (1-365).
    Par défaut : 7 jours

.PARAMETER Source
    Filtre optionnel sur la source des événements.
    Exemple : "Microsoft-Windows-PowerShell"

.PARAMETER IdEvenement
    Filtre optionnel sur un ID d'événement spécifique.

.PARAMETER OuvrirFichier
    Ouvre automatiquement le fichier CSV dans Excel après l'export.

.EXAMPLE
    .\Export-EventLog.ps1 -NomJournal Application
    
    Exporte les événements Application des 7 derniers jours (niveau Avertissement minimum).

.EXAMPLE
    .\Export-EventLog.ps1 -NomJournal System -NiveauGravite Erreur -JoursHistorique 30
    
    Exporte uniquement les erreurs du journal System des 30 derniers jours.

.EXAMPLE
    .\Export-EventLog.ps1 -NomJournal Application -Source "Microsoft-Windows-PowerShell" -OuvrirFichier
    
    Exporte les événements PowerShell et ouvre le fichier automatiquement.

.NOTES
    Auteur : Admin IT
    Version : 1.0
    Date : 2025-01-01
    
    Prérequis :
    - PowerShell 5.1+
    - Droits de lecture sur les journaux Windows
    - Excel (si utilisation de -OuvrirFichier)
#>

[CmdletBinding()]
param(
    # === Paramètres obligatoires ===
    [Parameter(
        Mandatory,
        HelpMessage = "Nom du journal à interroger (Application, System, Security, Setup)"
    )]
    [ValidateSet("Application", "System", "Security", "Setup")]
    [string]$NomJournal,
    
    # === Paramètres optionnels - Sortie ===
    [ValidateScript({
        if (-not (Test-Path $_ -PathType Container)) {
            throw "Le dossier '$_' n'existe pas"
        }
        return $true
    })]
    [string]$CheminExport = $PSScriptRoot,
    
    # === Paramètres optionnels - Filtres ===
    [ValidateSet("Critique", "Erreur", "Avertissement", "Information")]
    [string]$NiveauGravite = "Avertissement",
    
    [ValidateRange(1, 365)]
    [int]$JoursHistorique = 7,
    
    [ValidateNotNullOrEmpty()]
    [string]$Source,
    
    [ValidateRange(1, 65535)]
    [int]$IdEvenement,
    
    # === Options ===
    [switch]$OuvrirFichier
)

# Début du script
Write-Host "`n=== Export du journal Windows ===" -ForegroundColor Cyan
Write-Host "Journal       : $NomJournal"
Write-Host "Gravité min   : $NiveauGravite"
Write-Host "Période       : $JoursHistorique jours"

# Conversion du niveau de gravité en valeur numérique
$niveauxMap = @{
    "Critique"      = 1
    "Erreur"        = 2
    "Avertissement" = 3
    "Information"   = 4
}
$niveauNumeric = $niveauxMap[$NiveauGravite]

# Construction du filtre
$dateDebut = (Get-Date).AddDays(-$JoursHistorique)
$filtre = @{
    LogName = $NomJournal
    StartTime = $dateDebut
}

# Ajout des filtres optionnels
if ($PSBoundParameters.ContainsKey('Source')) {
    Write-Host "Source filtre : $Source"
}
if ($PSBoundParameters.ContainsKey('IdEvenement')) {
    $filtre['Id'] = $IdEvenement
    Write-Host "ID Événement  : $IdEvenement"
}

Write-Host "`nExtraction en cours..." -ForegroundColor Yellow

# Extraction des événements
try {
    $evenements = Get-WinEvent -FilterHashtable $filtre -ErrorAction Stop |
        Where-Object { $_.Level -le $niveauNumeric } |
        Select-Object TimeCreated, Level, Id, Message, ProviderName
    
    if ($Source) {
        $evenements = $evenements | Where-Object { $_.ProviderName -like "*$Source*" }
    }
    
    $nbEvenements = ($evenements | Measure-Object).Count
    
    if ($nbEvenements -eq 0) {
        Write-Warning "Aucun événement trouvé avec ces critères."
        return
    }
    
    Write-Host "✓ $nbEvenements événements trouvés" -ForegroundColor Green
    
    # Création du fichier CSV
    $nomFichier = "Export_${NomJournal}_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $cheminComplet = Join-Path $CheminExport $nomFichier
    
    $evenements | Export-Csv -Path $cheminComplet -NoTypeInformation -Encoding UTF8
    
    Write-Host "✓ Export créé : $cheminComplet" -ForegroundColor Green
    
    # Ouverture automatique si demandée
    if ($OuvrirFichier) {
        Start-Process $cheminComplet
        Write-Host "✓ Fichier ouvert dans Excel" -ForegroundColor Green
    }
    
} catch {
    Write-Error "Erreur lors de l'extraction : $_"
    exit 1
}

Write-Host "`n=== Terminé ===" -ForegroundColor Cyan
```

---

## 🎉 Conclusion

Vous maîtrisez maintenant les **paramètres avancés** de PowerShell ! Vous savez :

✅ Structurer un bloc `param()` complet et professionnel  
✅ Distinguer paramètres obligatoires et optionnels  
✅ Utiliser toutes les validations (Set, Range, Pattern, Script, etc.)  
✅ Créer des switches pour des options booléennes  
✅ Définir des valeurs par défaut intelligentes  
✅ Rédiger une aide complète avec Get-Help  
✅ Appliquer les bonnes pratiques et éviter les pièges courants

Vos scripts sont maintenant **robustes, documentés et faciles à utiliser** ! 🚀