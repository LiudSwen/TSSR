

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

## Introduction

La gestion des erreurs est cruciale dans PowerShell pour créer des scripts robustes et prévisibles. Le paramètre `-ErrorAction` et la variable `$ErrorActionPreference` permettent de contrôler finement le comportement de PowerShell face aux erreurs.

> [!info] Pourquoi c'est important Par défaut, PowerShell affiche les erreurs mais continue l'exécution. Cette approche peut masquer des problèmes graves dans vos scripts. Maîtriser `-ErrorAction` vous permet de décider exactement comment votre script doit réagir face aux erreurs.

---

## Le paramètre -ErrorAction

`-ErrorAction` est un **paramètre commun** disponible sur presque toutes les cmdlets PowerShell. Il contrôle le comportement de la cmdlet lorsqu'elle rencontre une erreur non-terminante.

### Syntaxe de base

```powershell
# Syntaxe générale
Get-Command -ErrorAction <Valeur>

# Exemple concret
Get-Item "C:\FichierInexistant.txt" -ErrorAction SilentlyContinue
```

> [!tip] Astuce Vous pouvez utiliser l'alias `-EA` au lieu de `-ErrorAction` pour gagner du temps : `Get-Item $path -EA Stop`

### Quand l'utiliser

- **Dans les scripts de production** : pour gérer proprement les erreurs attendues
- **En exploration** : pour masquer temporairement des erreurs connues
- **Dans les fonctions** : pour permettre aux appelants de contrôler le comportement
- **Pour le débogage** : pour forcer l'arrêt sur toute erreur

---

## Les valeurs d'ErrorAction

PowerShell propose 5 valeurs pour `-ErrorAction`, chacune avec un comportement spécifique.

### Tableau comparatif

|Valeur|Affiche l'erreur|Continue l'exécution|Ajoute à $Error|Cas d'usage|
|---|---|---|---|---|
|`Continue`|✅ Oui|✅ Oui|✅ Oui|Comportement par défaut|
|`SilentlyContinue`|❌ Non|✅ Oui|✅ Oui|Masquer les erreurs connues|
|`Stop`|✅ Oui|❌ Non|✅ Oui|Scripts critiques|
|`Inquire`|✅ Oui|⏸️ Pause|✅ Oui|Débogage interactif|
|`Ignore`|❌ Non|✅ Oui|❌ Non|Ignorer complètement|

### 1. Continue (valeur par défaut)

Affiche l'erreur en rouge et continue l'exécution du script.

```powershell
# Comportement par défaut
Get-Item "C:\Inexistant1.txt"
Get-Item "C:\Inexistant2.txt"
Write-Host "Script terminé"

# Résultat :
# Erreur affichée pour Inexistant1.txt
# Erreur affichée pour Inexistant2.txt
# "Script terminé" s'affiche
```

> [!example] Cas d'usage Utile pour les opérations non critiques où vous voulez voir les erreurs mais continuer le traitement (ex: parcourir une liste de fichiers où certains peuvent être manquants).

### 2. SilentlyContinue

Masque l'erreur mais continue l'exécution. L'erreur est quand même enregistrée dans `$Error`.

```powershell
# L'erreur est masquée
Get-Item "C:\Inexistant.txt" -ErrorAction SilentlyContinue
Write-Host "Aucune erreur affichée"

# Vérifier si une erreur s'est produite
if ($Error[0]) {
    Write-Host "Une erreur s'est produite mais a été masquée"
}
```

> [!warning] Attention `SilentlyContinue` masque l'affichage mais **l'erreur reste dans `$Error`**. Pour un vrai nettoyage, utilisez `Ignore`.

> [!example] Cas d'usage
> 
> - Tester l'existence d'un fichier sans déclencher d'erreur visuelle
> - Masquer des erreurs attendues dans des boucles
> - Scripts avec sortie propre pour l'utilisateur final

```powershell
# Exemple pratique : test d'existence
$fichier = Get-Item "C:\config.txt" -EA SilentlyContinue
if ($fichier) {
    Write-Host "Fichier trouvé"
} else {
    Write-Host "Fichier absent, utilisation des valeurs par défaut"
}
```

### 3. Stop

Convertit l'erreur non-terminante en **erreur terminante**. Arrête immédiatement l'exécution et peut être capturée par `try/catch`.

```powershell
# Sans -ErrorAction Stop
Get-Item "C:\Inexistant.txt"
Write-Host "Cette ligne s'exécute" # S'affiche

# Avec -ErrorAction Stop
Get-Item "C:\Inexistant.txt" -ErrorAction Stop
Write-Host "Cette ligne ne s'exécute JAMAIS" # Ne s'affiche pas
```

> [!example] Utilisation avec try/catch
> 
> ```powershell
> try {
>     Get-Item "C:\Inexistant.txt" -ErrorAction Stop
>     Write-Host "Traitement du fichier"
> }
> catch {
>     Write-Host "Erreur capturée : $($_.Exception.Message)"
>     # Gestion de l'erreur
> }
> ```

> [!tip] Bonne pratique Utilisez **toujours** `-ErrorAction Stop` dans les blocs `try/catch` pour les opérations critiques. Sans cela, `catch` ne capturera pas les erreurs non-terminantes.

### 4. Inquire

Affiche l'erreur et demande à l'utilisateur comment procéder (Continuer, Arrêter, Suspendre, etc.).

```powershell
Get-Item "C:\Inexistant.txt" -ErrorAction Inquire

# PowerShell affiche :
# Confirmer
# Voulez-vous continuer à effectuer cette action ?
# [O] Oui  [T] Oui pour tout  [A] Arrêter la commande  [S] Suspendre  [?] Aide (la valeur par défaut est « O ») :
```

> [!example] Cas d'usage
> 
> - Débogage interactif de scripts
> - Scripts de maintenance où l'opérateur doit valider chaque étape
> - Formation et démonstrations

> [!warning] Ne pas utiliser en production `Inquire` est inadapté pour les scripts automatisés car il nécessite une interaction humaine.

### 5. Ignore

Ignore complètement l'erreur : pas d'affichage ET pas d'ajout à `$Error`.

```powershell
# L'erreur est totalement ignorée
Get-Item "C:\Inexistant.txt" -ErrorAction Ignore

# $Error ne contient pas cette erreur
Write-Host "Erreurs enregistrées : $($Error.Count)"
```

> [!info] Différence avec SilentlyContinue
> 
> - **SilentlyContinue** : masque l'affichage mais enregistre dans `$Error`
> - **Ignore** : ne masque pas seulement, elle ignore totalement (pas d'ajout à `$Error`)

> [!example] Cas d'usage
> 
> - Opérations où les erreurs sont totalement attendues et sans conséquence
> - Scripts avec boucles intensives où `$Error` deviendrait trop volumineux
> - Nettoyage de ressources où l'échec est acceptable

```powershell
# Exemple : nettoyage de fichiers temporaires
$tempFiles = @("temp1.txt", "temp2.txt", "temp3.txt")
foreach ($file in $tempFiles) {
    # Peu importe si le fichier existe ou non
    Remove-Item "C:\Temp\$file" -ErrorAction Ignore
}
```

---

## La variable $ErrorActionPreference

`$ErrorActionPreference` définit le comportement **par défaut** pour toutes les erreurs non-terminantes dans la session ou le script en cours.

### Valeurs possibles

```powershell
# Valeurs identiques à -ErrorAction
$ErrorActionPreference = "Continue"           # Défaut
$ErrorActionPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$ErrorActionPreference = "Inquire"
$ErrorActionPreference = "Ignore"
```

### Vérifier la valeur actuelle

```powershell
# Afficher la préférence actuelle
$ErrorActionPreference

# Résultat typique : Continue
```

### Portée et modification

```powershell
# Sauvegarder la valeur originale
$originalPreference = $ErrorActionPreference

# Modifier pour la session
$ErrorActionPreference = "Stop"

# Toutes les erreurs deviennent terminantes
Get-Item "C:\Inexistant.txt"  # Arrête le script

# Restaurer la valeur originale
$ErrorActionPreference = $originalPreference
```

> [!warning] Attention à la portée globale Modifier `$ErrorActionPreference` affecte **toutes** les cmdlets suivantes dans la session. Pensez à la restaurer ou à limiter sa portée.

### Cas d'usage typiques

```powershell
# 1. Script strict : toute erreur arrête l'exécution
$ErrorActionPreference = "Stop"
try {
    # Votre code critique ici
    Get-Item "C:\Important.txt"
    Invoke-WebRequest "https://api.example.com"
}
catch {
    Write-Error "Erreur critique : $_"
    exit 1
}

# 2. Script de nettoyage : ignorer toutes les erreurs
$ErrorActionPreference = "Ignore"
Remove-Item "C:\Temp\*" -Recurse -Force
Remove-Item "C:\Logs\old_*" -Force

# 3. Script de diagnostic : examiner chaque erreur
$ErrorActionPreference = "Inquire"
Test-Connection "serveur1.local"
Test-Connection "serveur2.local"
```

---

## Portée de l'ErrorAction

L'ordre de priorité pour déterminer le comportement face aux erreurs est le suivant :

### Hiérarchie de priorité

1. **-ErrorAction sur la cmdlet** (priorité la plus haute)
2. **$ErrorActionPreference dans la portée locale**
3. **$ErrorActionPreference globale** (priorité la plus basse)

```powershell
# Exemple de hiérarchie
$ErrorActionPreference = "Continue"  # Niveau session

function Test-Portee {
    $ErrorActionPreference = "Stop"  # Niveau fonction
    
    # Cette erreur utilise Stop (niveau fonction)
    Get-Item "C:\Inexistant1.txt"
    
    # Cette erreur utilise SilentlyContinue (niveau cmdlet - prioritaire)
    Get-Item "C:\Inexistant2.txt" -ErrorAction SilentlyContinue
}

Test-Portee
```

### Portée dans les fonctions

```powershell
function Get-FichierSecurise {
    param(
        [string]$Chemin
    )
    
    # La fonction hérite de $ErrorActionPreference de l'appelant
    Get-Item $Chemin
}

# Appelant avec Stop
$ErrorActionPreference = "Stop"
Get-FichierSecurise "C:\Inexistant.txt"  # Arrête l'exécution

# Appelant avec SilentlyContinue
$ErrorActionPreference = "SilentlyContinue"
Get-FichierSecurise "C:\Inexistant.txt"  # Continue silencieusement
```

> [!tip] Bonnes pratiques pour les fonctions
> 
> ```powershell
> function Get-FichierAvecGestion {
>     [CmdletBinding()]
>     param(
>         [string]$Chemin
>     )
>     
>     # Respecter l'ErrorAction de l'appelant avec $PSCmdlet
>     try {
>         Get-Item $Chemin -ErrorAction Stop
>     }
>     catch {
>         # Propager selon la préférence de l'appelant
>         $PSCmdlet.WriteError($_)
>     }
> }
> ```

### Portée dans les scripts

```powershell
# Script.ps1
$ErrorActionPreference = "Stop"

# Toutes les cmdlets dans ce script utilisent Stop par défaut
Get-Item "C:\Fichier1.txt"
Get-Item "C:\Fichier2.txt" -ErrorAction Continue  # Override local

# Appel d'un autre script (hérite de la préférence)
.\AutreScript.ps1
```

---

## Erreurs terminantes vs non-terminantes

PowerShell distingue deux types d'erreurs fondamentalement différents.

### Erreurs non-terminantes (Non-Terminating Errors)

**Caractéristiques** :

- Génèrent un message d'erreur mais **continuent l'exécution**
- La plupart des erreurs de cmdlets sont non-terminantes
- **Ne peuvent pas** être capturées par `try/catch` (par défaut)
- Contrôlées par `-ErrorAction` et `$ErrorActionPreference`

```powershell
# Erreur non-terminante
Get-Item "C:\Inexistant.txt"  # Affiche l'erreur
Write-Host "Cette ligne s'exécute quand même"  # S'exécute

# Impossible à capturer sans modification
try {
    Get-Item "C:\Inexistant.txt"  # Erreur affichée
    Write-Host "Try continue"      # S'exécute
}
catch {
    Write-Host "Catch ne s'exécute PAS"  # Ne s'exécute JAMAIS
}
```

### Erreurs terminantes (Terminating Errors)

**Caractéristiques** :

- **Arrêtent immédiatement** l'exécution
- Peuvent être capturées par `try/catch`
- Générées par des erreurs graves (syntaxe, cmdlet inexistante, etc.)
- Générées par `-ErrorAction Stop`

```powershell
# Erreur terminante (cmdlet inexistante)
Get-CommandeInexistante  # ARRÊTE l'exécution

Write-Host "Cette ligne ne s'exécute JAMAIS"

# Capturable avec try/catch
try {
    Get-CommandeInexistante
}
catch {
    Write-Host "Erreur capturée : $($_.Exception.Message)"
}
```

### Tableau comparatif

|Aspect|Non-terminante|Terminante|
|---|---|---|
|**Exécution**|Continue après l'erreur|Arrête immédiatement|
|**try/catch**|❌ Non capturable (par défaut)|✅ Capturable|
|**Fréquence**|Très courante (cmdlets)|Plus rare|
|**-ErrorAction**|✅ Contrôlable|❌ Non contrôlable|
|**Exemples**|`Get-Item` fichier absent|Cmdlet inexistante, erreur de syntaxe|

### Exemples concrets

```powershell
# 1. Erreur non-terminante : fichier inexistant
Get-Content "C:\Inexistant.txt"
Write-Host "Suite de l'exécution"  # S'exécute

# 2. Erreur terminante : cmdlet inexistante
Get-FicheInexistante
Write-Host "Ne s'exécute JAMAIS"  # Ne s'exécute pas

# 3. Erreur non-terminante convertie en terminante
Get-Content "C:\Inexistant.txt" -ErrorAction Stop
Write-Host "Ne s'exécute JAMAIS"  # Ne s'exécute pas
```

---

## Conversion d'erreurs non-terminantes

La capacité de convertir des erreurs non-terminantes en terminantes est essentielle pour une gestion robuste des erreurs.

### Pourquoi convertir ?

> [!info] Raisons principales
> 
> - **Capture avec try/catch** : Les erreurs non-terminantes ne peuvent pas être capturées par défaut
> - **Arrêt immédiat** : Pour éviter que le script continue avec des données corrompues
> - **Logique de gestion** : Pour appliquer une logique de récupération spécifique

### Méthode 1 : -ErrorAction Stop (recommandée)

La méthode la plus explicite et lisible.

```powershell
try {
    # Convertir en terminante pour cette commande spécifique
    $fichier = Get-Item "C:\Important.txt" -ErrorAction Stop
    $contenu = Get-Content $fichier.FullName -ErrorAction Stop
    
    Write-Host "Fichier traité avec succès"
}
catch {
    Write-Error "Impossible de traiter le fichier : $($_.Exception.Message)"
    # Logique de récupération
}
```

> [!tip] Avantage Conversion ciblée et explicite. Chaque développeur comprend immédiatement l'intention.

### Méthode 2 : $ErrorActionPreference = "Stop"

Convertir toutes les erreurs dans une portée.

```powershell
function Get-DonneesDistantes {
    # Toutes les erreurs deviennent terminantes dans cette fonction
    $ErrorActionPreference = "Stop"
    
    try {
        $response = Invoke-WebRequest "https://api.example.com/data"
        $data = $response.Content | ConvertFrom-Json
        return $data
    }
    catch {
        Write-Warning "API inaccessible : $($_.Exception.Message)"
        return $null
    }
}
```

> [!warning] Attention Cette méthode affecte **toutes** les cmdlets dans la portée. Peut avoir des effets secondaires inattendus.

### Méthode 3 : Trap (ancienne approche)

Mécanisme de gestion d'erreurs moins utilisé aujourd'hui.

```powershell
trap {
    Write-Error "Erreur capturée dans trap : $_"
    continue  # ou break
}

Get-Item "C:\Inexistant.txt" -ErrorAction Stop
Write-Host "Après l'erreur"
```

> [!info] Note historique `trap` était utilisé avant l'introduction de `try/catch` en PowerShell 2.0. Privilégiez `try/catch` pour les scripts modernes.

### Exemples pratiques de conversion

#### Validation de prérequis

```powershell
function Start-ProcessusMetier {
    param([string]$CheminConfig)
    
    try {
        # Tous les prérequis doivent réussir
        $ErrorActionPreference = "Stop"
        
        $config = Get-Content $CheminConfig | ConvertFrom-Json
        $connexion = Test-Connection $config.Serveur -Count 1
        $service = Get-Service $config.ServiceNom
        
        if ($service.Status -ne "Running") {
            throw "Le service $($config.ServiceNom) n'est pas démarré"
        }
        
        Write-Host "Démarrage du processus métier..."
        # Logique métier ici
    }
    catch {
        Write-Error "Impossible de démarrer : $($_.Exception.Message)"
        return $false
    }
    
    return $true
}
```

#### Traitement par lots avec gestion d'erreur

```powershell
function Import-FichiersCSV {
    param([string[]]$Chemins)
    
    $resultats = @()
    
    foreach ($chemin in $Chemins) {
        try {
            # Convertir l'erreur pour ce fichier spécifique
            $data = Import-Csv $chemin -ErrorAction Stop
            
            $resultats += [PSCustomObject]@{
                Fichier = $chemin
                Lignes = $data.Count
                Statut = "Succès"
            }
        }
        catch {
            $resultats += [PSCustomObject]@{
                Fichier = $chemin
                Lignes = 0
                Statut = "Échec : $($_.Exception.Message)"
            }
        }
    }
    
    return $resultats
}
```

#### Pipeline avec gestion stricte

```powershell
# Convertir toutes les erreurs du pipeline
$ErrorActionPreference = "Stop"

try {
    Get-ChildItem "C:\Logs" -Filter "*.log" |
        Where-Object { $_.Length -gt 1MB } |
        ForEach-Object {
            Compress-Archive -Path $_.FullName -DestinationPath "$($_.FullName).zip"
            Remove-Item $_.FullName
        }
    
    Write-Host "Compression terminée avec succès"
}
catch {
    Write-Error "Échec de la compression : $_"
}
finally {
    $ErrorActionPreference = "Continue"  # Restaurer
}
```

---

## Pièges courants

### 1. Oublier -ErrorAction Stop dans try/catch

```powershell
# ❌ MAUVAIS : catch ne capturera jamais l'erreur
try {
    Get-Item "C:\Inexistant.txt"  # Erreur non-terminante
}
catch {
    Write-Host "Ce code ne s'exécute JAMAIS"
}

# ✅ BON : catch fonctionne
try {
    Get-Item "C:\Inexistant.txt" -ErrorAction Stop
}
catch {
    Write-Host "Erreur capturée correctement"
}
```

### 2. Confondre SilentlyContinue et Ignore

```powershell
# SilentlyContinue : l'erreur est dans $Error
Get-Item "C:\Inexistant.txt" -EA SilentlyContinue
Write-Host "Erreurs : $($Error.Count)"  # Compte augmente

# Ignore : l'erreur n'est PAS dans $Error
$Error.Clear()
Get-Item "C:\Inexistant.txt" -EA Ignore
Write-Host "Erreurs : $($Error.Count)"  # Reste à 0
```

### 3. Modifier $ErrorActionPreference sans la restaurer

```powershell
# ❌ MAUVAIS : modification permanente
function Process-Data {
    $ErrorActionPreference = "Stop"
    # Traitement...
    # Oubli de restaurer
}

Process-Data
# Toute la session est maintenant en mode Stop !

# ✅ BON : restauration systématique
function Process-Data {
    $originalEA = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Stop"
        # Traitement...
    }
    finally {
        $ErrorActionPreference = $originalEA
    }
}
```

### 4. Utiliser Inquire dans des scripts automatisés

```powershell
# ❌ MAUVAIS : script bloqué en attente d'interaction
$ErrorActionPreference = "Inquire"
Get-ChildItem "C:\Inexistant" -Recurse  # Script bloqué

# ✅ BON : Inquire uniquement pour le débogage manuel
if ($DebugMode) {
    $ErrorActionPreference = "Inquire"
} else {
    $ErrorActionPreference = "Stop"
}
```

### 5. Ne pas considérer les erreurs terminantes

```powershell
# ❌ MAUVAIS : -ErrorAction n'affecte pas les erreurs terminantes
Get-CommandeInexistante -ErrorAction SilentlyContinue
# L'erreur s'affiche quand même car elle est terminante

# ✅ BON : utiliser try/catch pour les erreurs terminantes
try {
    Get-CommandeInexistante
}
catch {
    Write-Host "Cmdlet inexistante"
}
```

---

## Bonnes pratiques

### 1. Soyez explicite dans les scripts de production

```powershell
# ✅ Excellent : intentions claires
try {
    $config = Get-Content "config.json" -ErrorAction Stop | ConvertFrom-Json
    $serveur = Connect-Server $config.Host -ErrorAction Stop
    
    # Traitement métier
}
catch {
    Write-Error "Échec de l'initialisation : $_"
    exit 1
}
```

### 2. Utilisez -ErrorAction Stop dans les try/catch

```powershell
# ✅ Pattern recommandé
try {
    $resultat = Invoke-Operation -ErrorAction Stop
}
catch {
    # Gestion de l'erreur
}

# ❌ Pattern inefficace (catch ne capture rien)
try {
    $resultat = Invoke-Operation  # Erreur non-terminante ignorée
}
catch {
    # Ne s'exécute jamais
}
```

### 3. Restaurez $ErrorActionPreference dans finally

```powershell
# ✅ Garantit la restauration même en cas d'erreur
$originalEA = $ErrorActionPreference
try {
    $ErrorActionPreference = "Stop"
    # Opérations critiques
}
catch {
    # Gestion d'erreur
}
finally {
    $ErrorActionPreference = $originalEA
}
```

### 4. Documentez les choix d'ErrorAction

```powershell
# ✅ Code auto-documenté
function Get-UserData {
    param([string]$Username)
    
    # SilentlyContinue car l'absence de fichier est un cas normal
    $profile = Get-Item "C:\Users\$Username\profile.json" -EA SilentlyContinue
    
    if (-not $profile) {
        # Créer un profil par défaut
        return New-DefaultProfile
    }
    
    # Stop car un profil corrompu est critique
    return Get-Content $profile.FullName -EA Stop | ConvertFrom-Json
}
```

### 5. Utilisez des fonctions wrapper pour cohérence

```powershell
# ✅ Centraliser la gestion des erreurs
function Get-SecureFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    try {
        if (-not (Test-Path $Path)) {
            throw "Le fichier '$Path' n'existe pas"
        }
        
        return Get-Item $Path -ErrorAction Stop
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

# Utilisation simple et cohérente
$fichier = Get-SecureFile "C:\config.txt"
```

### 6. Adaptez ErrorAction au contexte

```powershell
# ✅ ErrorAction adapté au besoin métier

# Script de validation strict
$ErrorActionPreference = "Stop"

# Nettoyage non critique
Remove-Item "C:\Temp\cache_*" -ErrorAction Ignore

# Test de connectivité où l'échec est informatif
$servers = @("srv1", "srv2", "srv3")
$results = $servers | ForEach-Object {
    $reachable = Test-Connection $_ -Count 1 -EA SilentlyContinue -Quiet
    [PSCustomObject]@{
        Serveur = $_
        Accessible = $reachable
    }
}
```

### 7. Combinez avec les variables automatiques

```powershell
# ✅ Utiliser $? et $LASTEXITCODE avec ErrorAction
function Invoke-ExternalCommand {
    param([string]$Command)
    
    # Exécuter la commande externe
    & $Command 2>&1 | Out-Null
    
    # Vérifier le résultat
    if (-not $?) {
        Write-Error "La commande a échoué (code $LASTEXITCODE)"
        return $false
    }
    
    return $true
}
```

---

## 🎯 Récapitulatif

|Concept|Utilisation|À retenir|
|---|---|---|
|**-ErrorAction**|Paramètre commun sur les cmdlets|Contrôle le comportement pour une cmdlet spécifique|
|**Continue**|Valeur par défaut|Affiche et continue|
|**SilentlyContinue**|Masquer les erreurs attendues|Masque mais enregistre dans `$Error`|
|**Stop**|Scripts critiques, try/catch|Convertit en erreur terminante|
|**Inquire**|Débogage interactif|Demande confirmation à l'utilisateur|
|**Ignore**|Nettoyage, opérations non critiques|Ignore totalement (pas dans `$Error`)|
|**$ErrorActionPreference**|Variable de session/script|Définit le comportement par défaut|
|**Erreurs non-terminantes**|Majorité des erreurs de cmdlets|Continuent l'exécution par défaut|
|**Erreurs terminantes**|Erreurs graves, -EA Stop|Arrêtent l'exécution, capturables par catch|

> [!tip] Règle d'or Dans un bloc `try/catch`, utilisez **toujours** `-ErrorAction Stop` sur les cmdlets dont vous voulez capturer les erreurs. Sans cela, le bloc `catch` ne s'exécutera jamais pour les erreurs non-terminantes.