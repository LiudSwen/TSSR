

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

PowerShell possède un système de sortie unique qui le distingue des autres langages. Contrairement aux langages traditionnels où seules les instructions explicites produisent des valeurs de retour, PowerShell capture automatiquement **tout objet non assigné** dans le pipeline. Cette caractéristique fondamentale influence profondément la manière dont on écrit des fonctions et gère les sorties.

> [!info] Principe fondamental En PowerShell, une fonction peut retourner des données de trois manières :
> 
> - Via l'instruction `return`
> - Par sortie implicite (objets non capturés)
> - Via `Write-Output`

---

## 📤 L'instruction `return`

### Qu'est-ce que `return` ?

L'instruction `return` permet de **terminer immédiatement l'exécution** d'une fonction, d'un script ou d'un bloc de code et de retourner optionnellement une valeur au pipeline.

### Syntaxe

```powershell
return
return $valeur
return $valeur1, $valeur2, $valeur3
```

### Comportement détaillé

```powershell
function Test-Return {
    Write-Host "Début de la fonction"
    
    if ($true) {
        return "Valeur retournée"
    }
    
    # Ce code ne sera JAMAIS exécuté
    Write-Host "Cette ligne est inaccessible"
}

$resultat = Test-Return
# Affiche : "Début de la fonction"
# $resultat contient : "Valeur retournée"
```

> [!warning] Return termine l'exécution Toute instruction placée après un `return` dans le même bloc de code ne sera jamais exécutée. C'est une sortie **immédiate**.

### Return sans valeur

```powershell
function Test-Validation {
    param($Age)
    
    if ($Age -lt 18) {
        Write-Host "Âge insuffisant" -ForegroundColor Red
        return  # Sort de la fonction sans valeur
    }
    
    Write-Host "Validation réussie" -ForegroundColor Green
    # Le reste du traitement continue...
}

Test-Validation -Age 15
# Affiche "Âge insuffisant" et s'arrête
```

> [!tip] Return comme contrôle de flux `return` sans valeur est très utile pour sortir prématurément d'une fonction après une validation ou une condition d'erreur.

---

## 🌊 Sortie implicite

### Le concept de sortie implicite

En PowerShell, **tout objet qui n'est pas capturé dans une variable** devient automatiquement une sortie de la fonction et est envoyé dans le pipeline.

```powershell
function Get-Nombres {
    1          # Sortie implicite
    2          # Sortie implicite
    3          # Sortie implicite
}

$resultats = Get-Nombres
# $resultats contient : @(1, 2, 3)
```

### Exemples de sorties implicites

```powershell
function Analyse-Fichiers {
    # Sortie implicite
    Get-ChildItem -Path C:\Temp
    
    # Sortie implicite
    "Analyse terminée"
    
    # Sortie implicite d'un calcul
    10 + 20
}

$tout = Analyse-Fichiers
# $tout contient : tous les fichiers + la chaîne + le nombre 30
```

### Pièges courants avec la sortie implicite

```powershell
function Traiter-Donnees {
    param($Valeur)
    
    # ATTENTION : ceci produit une sortie implicite !
    $Valeur * 2
    
    # Sortie explicite voulue
    return "Traitement terminé"
}

$resultat = Traiter-Donnees -Valeur 5
# $resultat contient : @(10, "Traitement terminé")
# Vous avez 2 valeurs au lieu d'une !
```

> [!warning] Sortie involontaire Les sorties implicites sont la source n°1 de bugs dans les fonctions PowerShell. Une simple expression non capturée devient une sortie !

### Comment éviter les sorties implicites non désirées

```powershell
function Traiter-Donnees-Correct {
    param($Valeur)
    
    # Capturer dans une variable pour éviter la sortie
    $calcul = $Valeur * 2
    
    # Rediriger vers $null
    $null = $Valeur * 2
    
    # Utiliser [void]
    [void]($Valeur * 2)
    
    # Pipe vers Out-Null
    $Valeur * 2 | Out-Null
    
    # Seule sortie voulue
    return "Traitement terminé"
}
```

> [!tip] $null vs [void] vs Out-Null
> 
> - `$null =` : rapide et lisible
> - `[void]()` : très rapide, pour les méthodes .NET
> - `Out-Null` : plus lent mais fonctionne avec le pipeline

---

## 🔀 Différence entre return et Write-Output

### Tableau comparatif

|Aspect|`return`|`Write-Output`|
|---|---|---|
|Termine la fonction|✅ Oui|❌ Non|
|Envoie au pipeline|✅ Oui|✅ Oui|
|Peut être utilisé plusieurs fois|❌ Non (termine)|✅ Oui|
|Performance|Rapide|Rapide|
|Usage recommandé|Sortie finale|Sortie multiple/progressive|

### Exemples comparatifs

```powershell
# Avec return
function Methode-Return {
    "Premier élément"
    return "Dernier élément"
    "Jamais exécuté"  # Code mort
}

$r1 = Methode-Return
# Résultat : @("Premier élément", "Dernier élément")

# Avec Write-Output
function Methode-WriteOutput {
    Write-Output "Premier élément"
    Write-Output "Deuxième élément"
    Write-Output "Troisième élément"
}

$r2 = Methode-WriteOutput
# Résultat : @("Premier élément", "Deuxième élément", "Troisième élément")
```

### Quand utiliser chacun ?

```powershell
# return : pour sortir immédiatement avec un résultat final
function Get-StatusCode {
    param($Response)
    
    if ($Response.StatusCode -eq 200) {
        return "OK"
    }
    
    if ($Response.StatusCode -eq 404) {
        return "Not Found"
    }
    
    return "Unknown"
}

# Write-Output : pour retourner progressivement plusieurs valeurs
function Get-LogsParJour {
    param($Logs)
    
    foreach ($log in $Logs) {
        if ($log.Date -eq (Get-Date).Date) {
            Write-Output $log
        }
    }
}
```

> [!info] Write-Output est souvent optionnel En pratique, `Write-Output` est rarement nécessaire car la sortie implicite fait le même travail. On l'utilise surtout pour la clarté du code.

---

## 📦 Retour de valeurs multiples

### Retour automatique sous forme de tableau

Lorsqu'une fonction produit plusieurs sorties, PowerShell les regroupe automatiquement dans un tableau.

```powershell
function Get-InfosSysteme {
    $env:COMPUTERNAME
    $env:USERNAME
    (Get-Date)
}

$infos = Get-InfosSysteme
# $infos est un tableau de 3 éléments
# $infos[0] = nom de l'ordinateur
# $infos[1] = nom d'utilisateur
# $infos[2] = date/heure
```

### Retour avec return

```powershell
function Get-Coordonnees {
    param($Latitude, $Longitude)
    
    return $Latitude, $Longitude
}

$coords = Get-Coordonnees -Latitude 48.8566 -Longitude 2.3522
# $coords contient : @(48.8566, 2.3522)

# Décomposition
$lat, $lon = Get-Coordonnees -Latitude 48.8566 -Longitude 2.3522
```

### Retour d'objets personnalisés (recommandé)

```powershell
function Get-UtilisateurInfo {
    param($Nom)
    
    # Créer un objet personnalisé
    [PSCustomObject]@{
        Nom = $Nom
        DateCreation = Get-Date
        Actif = $true
        Droits = @("Lecture", "Ecriture")
    }
}

$user = Get-UtilisateurInfo -Nom "Alice"
# Accès aux propriétés
$user.Nom           # "Alice"
$user.Droits        # @("Lecture", "Ecriture")
```

> [!tip] Retour d'objets PSCustomObject Pour des données structurées complexes, retourner un `[PSCustomObject]` est la meilleure pratique. C'est plus lisible et maintenable qu'un simple tableau.

### Retour de collections

```powershell
function Get-NombresPairs {
    param($Max)
    
    $resultats = @()
    
    for ($i = 0; $i -le $Max; $i += 2) {
        $resultats += $i
    }
    
    return $resultats
}

# Meilleure approche : sortie progressive
function Get-NombresPairs-Optimise {
    param($Max)
    
    for ($i = 0; $i -le $Max; $i += 2) {
        $i  # Sortie implicite progressive
    }
}

# Encore mieux avec Write-Output explicite pour la clarté
function Get-NombresPairs-Explicite {
    param($Max)
    
    for ($i = 0; $i -le $Max; $i += 2) {
        Write-Output $i
    }
}
```

> [!warning] Performance : évitez += dans les boucles Utiliser `+=` pour construire un tableau dans une boucle est inefficace car PowerShell recrée le tableau à chaque itération. Préférez la sortie progressive.

---

## 🔗 Gestion du pipeline dans les fonctions

### Blocs Begin, Process et End

PowerShell offre trois blocs spéciaux pour gérer le traitement des données en provenance du pipeline :

```powershell
function Traiter-Pipeline {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $InputObject
    )
    
    begin {
        # Exécuté UNE SEULE FOIS au début
        Write-Host "=== Début du traitement ===" -ForegroundColor Cyan
        $compteur = 0
    }
    
    process {
        # Exécuté POUR CHAQUE élément du pipeline
        Write-Host "Traitement de : $InputObject"
        $compteur++
        
        # Sortie vers le pipeline
        $InputObject * 2
    }
    
    end {
        # Exécuté UNE SEULE FOIS à la fin
        Write-Host "=== Fin : $compteur éléments traités ===" -ForegroundColor Cyan
    }
}

# Utilisation
1..5 | Traiter-Pipeline
```

### Explication du flux

```powershell
# Le pipeline envoie chaque élément un par un
# 1 → process → sortie 2
# 2 → process → sortie 4
# 3 → process → sortie 6
# 4 → process → sortie 8
# 5 → process → sortie 10
```

### Exemple pratique : filtrage dans le pipeline

```powershell
function Select-FichiersVolumineux {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $Fichier,
        
        [int]$TailleMinimumMB = 10
    )
    
    process {
        $tailleMB = $Fichier.Length / 1MB
        
        if ($tailleMB -ge $TailleMinimumMB) {
            # Retourner le fichier au pipeline
            $Fichier
        }
    }
}

# Utilisation
Get-ChildItem C:\Temp | Select-FichiersVolumineux -TailleMinimumMB 5
```

### Accumulation de données dans le pipeline

```powershell
function Get-Statistiques {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [int]$Nombre
    )
    
    begin {
        $somme = 0
        $compte = 0
        $min = [int]::MaxValue
        $max = [int]::MinValue
    }
    
    process {
        $somme += $Nombre
        $compte++
        
        if ($Nombre -lt $min) { $min = $Nombre }
        if ($Nombre -gt $max) { $max = $Nombre }
    }
    
    end {
        [PSCustomObject]@{
            Somme = $somme
            Compte = $compte
            Moyenne = $somme / $compte
            Min = $min
            Max = $max
        }
    }
}

# Utilisation
1..100 | Get-Statistiques
```

> [!info] Quand utiliser Begin/Process/End ?
> 
> - **begin** : initialisation de variables, ouverture de connexions
> - **process** : traitement de chaque élément du pipeline
> - **end** : calculs finaux, fermeture de ressources, sortie des résultats agrégés

---

## 🖥️ Write-Host vs Write-Output vs return

### Tableau comparatif complet

|Cmdlet/Instruction|Destination|Capturée dans variable|Transmise au pipeline|Utilisation|
|---|---|---|---|---|
|`Write-Output`|Pipeline|✅ Oui|✅ Oui|Sortie de données|
|`return`|Pipeline|✅ Oui|✅ Oui|Sortie finale + arrêt|
|`Write-Host`|Console uniquement|❌ Non|❌ Non|Affichage utilisateur|
|`Write-Verbose`|Console (si -Verbose)|❌ Non|❌ Non|Messages de debug|
|`Write-Warning`|Console (warnings)|❌ Non|❌ Non|Avertissements|
|`Write-Error`|Console (erreurs)|❌ Non|❌ Non|Messages d'erreur|

### Write-Host : affichage console uniquement

```powershell
function Demo-WriteHost {
    Write-Host "Ce message va à la console" -ForegroundColor Green
    Write-Host "Impossible de capturer ceci dans une variable"
    
    return "Seule cette valeur est capturée"
}

$resultat = Demo-WriteHost
# Affiche les messages Write-Host à l'écran
# $resultat contient uniquement : "Seule cette valeur est capturée"
```

> [!warning] Write-Host n'est PAS capturé `Write-Host` écrit directement sur la console et ne peut pas être capturé, redirigé ou transmis dans le pipeline. À utiliser uniquement pour l'affichage utilisateur.

### Exemple d'utilisation appropriée

```powershell
function Analyser-Disque {
    param($Chemin)
    
    # Message utilisateur (non capturé)
    Write-Host "Analyse en cours de $Chemin..." -ForegroundColor Cyan
    
    # Données de sortie (capturées)
    $fichiers = Get-ChildItem -Path $Chemin
    
    # Information détaillée (seulement si -Verbose)
    Write-Verbose "Trouvé $($fichiers.Count) fichiers"
    
    # Avertissement si nécessaire
    if ($fichiers.Count -gt 10000) {
        Write-Warning "Nombre élevé de fichiers détecté"
    }
    
    # Sortie de données
    return $fichiers
}

$resultats = Analyser-Disque -Path C:\Temp
# Les Write-Host s'affichent
# Les Write-Verbose ne s'affichent pas (sauf si -Verbose)
# Les Write-Warning s'affichent en jaune
# $resultats contient les fichiers
```

### Redirection des flux

PowerShell possède plusieurs flux de sortie numérotés :

```powershell
# Flux disponibles :
# 1 = Success (sortie standard, Write-Output)
# 2 = Error (Write-Error)
# 3 = Warning (Write-Warning)
# 4 = Verbose (Write-Verbose)
# 5 = Debug (Write-Debug)
# 6 = Information (Write-Information)

function Test-Flux {
    Write-Output "Sortie standard"      # Flux 1
    Write-Error "Message d'erreur"      # Flux 2
    Write-Warning "Avertissement"       # Flux 3
    Write-Verbose "Message verbeux"     # Flux 4
}

# Redirection des erreurs vers un fichier
Test-Flux 2> erreurs.txt

# Redirection de tous les flux
Test-Flux *> tout.txt

# Supprimer les avertissements
Test-Flux 3> $null
```

> [!info] Write-Host ne peut pas être redirigé Depuis PowerShell 5.0, `Write-Host` utilise le flux Information (6) mais reste principalement destiné à l'affichage direct.

---

## ✅ Bonnes pratiques de sortie

### 1. Privilégier la sortie implicite pour la simplicité

```powershell
# ✅ BON : simple et clair
function Get-Double {
    param($Nombre)
    $Nombre * 2
}

# ⚠️ Acceptable mais verbeux
function Get-Double {
    param($Nombre)
    Write-Output ($Nombre * 2)
}

# ❌ MAUVAIS : return inutile ici
function Get-Double {
    param($Nombre)
    return $Nombre * 2
}
```

### 2. Utiliser return pour sortir prématurément

```powershell
# ✅ BON : return pour validation
function Get-Racine {
    param([double]$Nombre)
    
    if ($Nombre -lt 0) {
        Write-Error "Nombre négatif"
        return
    }
    
    [Math]::Sqrt($Nombre)
}
```

### 3. Éviter les sorties mixtes involontaires

```powershell
# ❌ MAUVAIS : sorties mixtes
function Process-Data {
    param($Data)
    
    "Debug: traitement..."  # Sortie involontaire !
    $result = $Data * 2
    $result
}

# ✅ BON : une seule sortie
function Process-Data {
    param($Data)
    
    Write-Verbose "Debug: traitement..."
    $result = $Data * 2
    $result
}
```

### 4. Retourner des objets structurés

```powershell
# ❌ MAUVAIS : tableau non structuré
function Get-UserData {
    param($Username)
    
    return "John", "Doe", "john@example.com"
}

# ✅ BON : objet structuré
function Get-UserData {
    param($Username)
    
    [PSCustomObject]@{
        FirstName = "John"
        LastName = "Doe"
        Email = "john@example.com"
    }
}
```

### 5. Supprimer les sorties indésirables

```powershell
# ❌ MAUVAIS : Add retourne une sortie
function Ajouter-Element {
    param($Liste, $Element)
    
    $Liste.Add($Element)  # Retourne True/False !
}

# ✅ BON : suppression de la sortie
function Ajouter-Element {
    param($Liste, $Element)
    
    [void]$Liste.Add($Element)
    # ou
    $null = $Liste.Add($Element)
    # ou
    $Liste.Add($Element) | Out-Null
}
```

### 6. Utiliser Write-Host uniquement pour l'interface utilisateur

```powershell
# ✅ BON : séparation claire
function Backup-Files {
    param($Source, $Destination)
    
    # Interface utilisateur
    Write-Host "Sauvegarde de $Source vers $Destination..." -ForegroundColor Green
    
    # Traitement
    $files = Copy-Item -Path $Source -Destination $Destination -PassThru
    
    # Sortie de données
    return $files
}
```

### 7. Documenter le type de sortie attendu

```powershell
function Get-SystemInfo {
    <#
    .SYNOPSIS
    Récupère les informations système
    
    .OUTPUTS
    PSCustomObject avec les propriétés :
    - ComputerName : string
    - OS : string
    - Memory : int64
    - Processors : int
    #>
    
    [OutputType([PSCustomObject])]
    param()
    
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        OS = (Get-CimInstance Win32_OperatingSystem).Caption
        Memory = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
        Processors = (Get-CimInstance Win32_Processor).Count
    }
}
```

> [!tip] Astuce : OutputType L'attribut `[OutputType()]` aide les outils d'analyse et la complétion automatique à comprendre ce que retourne votre fonction.

### 8. Gérer correctement le pipeline

```powershell
# ✅ BON : fonction compatible pipeline
function ConvertTo-Uppercase {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        [string]$Text
    )
    
    process {
        $Text.ToUpper()
    }
}

# Utilisation fluide
"hello", "world" | ConvertTo-Uppercase
```

---

## 📝 Résumé des points clés

> [!tip] À retenir absolument
> 
> 1. **Sortie implicite** : tout objet non capturé devient une sortie
> 2. **return** : termine immédiatement la fonction et retourne une valeur
> 3. **Write-Output** : envoie explicitement au pipeline (mais rarement nécessaire)
> 4. **Write-Host** : affichage console uniquement, non capturable
> 5. **Objets structurés** : préférez `[PSCustomObject]` aux tableaux simples
> 6. **Pipeline** : utilisez begin/process/end pour traiter les flux de données
> 7. **Suppression** : utilisez `$null =`, `[void]()` ou `Out-Null` pour éviter les sorties involontaires

---