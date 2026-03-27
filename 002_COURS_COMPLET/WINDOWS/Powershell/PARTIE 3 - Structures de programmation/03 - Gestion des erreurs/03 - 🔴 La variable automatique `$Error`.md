

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

La variable automatique `$Error` est un mécanisme fondamental de PowerShell qui conserve un historique complet de toutes les erreurs survenues durant la session active. Cette collection permet une analyse post-mortem, un débogage avancé et la mise en place de systèmes de logging robustes.

> [!info] Qu'est-ce qu'une variable automatique ? Les variables automatiques sont créées et maintenues automatiquement par PowerShell. `$Error` en fait partie, aux côtés de `$PSVersionTable`, `$HOME`, `$PWD`, etc. Vous n'avez pas besoin de les initialiser.

**Pourquoi `$Error` est important :**

- 📊 Historique complet des erreurs de la session
- 🔍 Débogage facilité avec contexte détaillé
- 📝 Création de logs d'erreurs personnalisés
- 🛠️ Analyse des échecs dans les scripts complexes

---

## 🗂️ Comprendre la variable `$Error`

### Nature de `$Error`

`$Error` est un **tableau (array)** qui fonctionne comme une **pile LIFO** (Last In, First Out) : les erreurs les plus récentes sont ajoutées au début du tableau.

```powershell
# Vérifier le type de $Error
$Error.GetType()
# TypeName: System.Collections.ArrayList

# Obtenir le nombre total d'erreurs dans l'historique
$Error.Count
```

> [!warning] Limite de capacité Par défaut, `$Error` conserve un maximum de **256 erreurs**. Les plus anciennes sont automatiquement supprimées lorsque cette limite est atteinte. Cette limite est configurable via `$MaximumErrorCount`.

### Comportement automatique

Chaque fois qu'une erreur se produit dans PowerShell (qu'elle soit gérée ou non par un bloc `try-catch`), elle est **automatiquement ajoutée** à `$Error[0]`.

```powershell
# Génération d'une erreur volontaire
Get-Item "C:\FichierInexistant.txt"

# L'erreur est immédiatement disponible
$Error[0]
# Affiche l'erreur complète qui vient de se produire
```

---

## 🔢 Structure et accès aux erreurs

### Accès par index

Les erreurs sont accessibles via leur index dans le tableau, l'index `0` correspondant à l'erreur la plus récente.

```powershell
# Erreur la plus récente
$Error[0]

# Deuxième erreur la plus récente
$Error[1]

# Dernière erreur (la plus ancienne)
$Error[-1]

# Les 5 erreurs les plus récentes
$Error[0..4]
```

> [!tip] Astuce : Vérifier la présence d'erreurs Avant d'accéder à `$Error[0]`, vérifiez toujours que le tableau n'est pas vide avec `if ($Error.Count -gt 0)` pour éviter une erreur d'index.

### Itération sur les erreurs

Vous pouvez parcourir toutes les erreurs avec des boucles classiques :

```powershell
# Parcourir toutes les erreurs
foreach ($err in $Error) {
    Write-Host "Erreur: $($err.Exception.Message)" -ForegroundColor Red
}

# Filtrer les erreurs d'un type spécifique
$Error | Where-Object { $_.Exception -is [System.IO.FileNotFoundException] }
```

### Recherche et filtrage

```powershell
# Trouver toutes les erreurs contenant un mot-clé
$Error | Where-Object { $_.Exception.Message -like "*accès refusé*" }

# Compter les erreurs d'un type particulier
($Error | Where-Object { $_.CategoryInfo.Category -eq "ObjectNotFound" }).Count

# Grouper les erreurs par type
$Error | Group-Object { $_.Exception.GetType().Name }
```

---

## 🔍 Propriétés des objets d'erreur

Chaque erreur dans `$Error` est un objet `ErrorRecord` avec de nombreuses propriétés exploitables.

### Hiérarchie des propriétés principales

|Propriété|Description|Exemple d'usage|
|---|---|---|
|`.Exception`|L'objet exception .NET sous-jacent|Message d'erreur, type d'exception|
|`.ErrorDetails`|Informations supplémentaires|Messages personnalisés|
|`.InvocationInfo`|Contexte d'exécution|Ligne, script, commande|
|`.TargetObject`|Objet ayant causé l'erreur|Chemin de fichier, objet manipulé|
|`.CategoryInfo`|Catégorie de l'erreur|Type et raison|

### 🔴 `.Exception` - L'exception sous-jacente

Cette propriété contient l'exception .NET complète qui a déclenché l'erreur.

```powershell
# Message d'erreur lisible
$Error[0].Exception.Message

# Type exact de l'exception
$Error[0].Exception.GetType().FullName
# Exemple: System.Management.Automation.ItemNotFoundException

# Exception interne (si elle existe)
$Error[0].Exception.InnerException

# Stack trace de l'exception
$Error[0].Exception.StackTrace
```

> [!example] Exemple pratique
> 
> ```powershell
> try {
>     Get-Content "C:\Inexistant.txt"
> } catch {
>     # Accès direct via $Error
>     Write-Host "Type: $($Error[0].Exception.GetType().Name)"
>     Write-Host "Message: $($Error[0].Exception.Message)"
> }
> ```

### 📄 `.ErrorDetails` - Détails supplémentaires

Contient des informations additionnelles, souvent utilisées pour des messages personnalisés.

```powershell
# Message détaillé (peut être null)
$Error[0].ErrorDetails.Message

# Message recommandé (suggestion de résolution)
$Error[0].ErrorDetails.RecommendedAction
```

> [!info] Quand `.ErrorDetails` est utile Cette propriété est particulièrement riche pour les erreurs provenant de modules tiers ou de commandes distantes qui ajoutent des métadonnées explicatives.

### 📍 `.InvocationInfo` - Contexte d'invocation

Fournit le contexte complet de l'endroit où l'erreur s'est produite.

```powershell
# Nom de la commande qui a échoué
$Error[0].InvocationInfo.MyCommand.Name

# Numéro de ligne dans le script
$Error[0].InvocationInfo.ScriptLineNumber

# Chemin complet du script
$Error[0].InvocationInfo.ScriptName

# Ligne exacte de code
$Error[0].InvocationInfo.Line

# Position dans la ligne
$Error[0].InvocationInfo.OffsetInLine
```

> [!tip] Utilisation en production `.InvocationInfo` est crucial pour créer des logs détaillés indiquant exactement où une erreur s'est produite dans vos scripts de production.

**Exemple d'utilisation complète :**

```powershell
$err = $Error[0]
Write-Host "Erreur dans le script: $($err.InvocationInfo.ScriptName)"
Write-Host "À la ligne: $($err.InvocationInfo.ScriptLineNumber)"
Write-Host "Commande: $($err.InvocationInfo.Line.Trim())"
Write-Host "Message: $($err.Exception.Message)"
```

### 🎯 `.TargetObject` - Objet cible

L'objet ou la valeur qui était manipulé(e) au moment de l'erreur.

```powershell
# Objet concerné par l'erreur
$Error[0].TargetObject
# Exemple: "C:\FichierInexistant.txt" pour une erreur Get-Item

# Type de l'objet cible
$Error[0].TargetObject.GetType()
```

> [!example] Cas pratique
> 
> ```powershell
> # Tentative sur plusieurs fichiers
> $fichiers = @("fichier1.txt", "fichier2.txt", "fichier3.txt")
> foreach ($f in $fichiers) {
>     try {
>         Get-Content $f -ErrorAction Stop
>     } catch {
>         Write-Host "Échec sur: $($Error[0].TargetObject)"
>     }
> }
> ```

### 📊 `.CategoryInfo` - Catégorie de l'erreur

Classification standardisée de l'erreur par PowerShell.

```powershell
# Catégorie principale
$Error[0].CategoryInfo.Category
# Exemples: ObjectNotFound, PermissionDenied, InvalidOperation

# Activité en cours
$Error[0].CategoryInfo.Activity
# Exemple: "Get-Item"

# Raison de l'erreur
$Error[0].CategoryInfo.Reason
# Exemple: "ItemNotFoundException"

# Objet cible (string)
$Error[0].CategoryInfo.TargetName
```

**Table des catégories courantes :**

|Catégorie|Signification|
|---|---|
|`ObjectNotFound`|Ressource introuvable|
|`PermissionDenied`|Droits d'accès insuffisants|
|`InvalidOperation`|Opération invalide dans le contexte actuel|
|`InvalidArgument`|Paramètre incorrect|
|`ResourceExists`|Ressource déjà présente|
|`NotSpecified`|Erreur non catégorisée|

---

## 🛠️ Gestion et manipulation de `$Error`

### Vider l'historique des erreurs

Il est souvent nécessaire de réinitialiser `$Error`, notamment dans les scripts de test ou pour isoler des sections de code.

```powershell
# Méthode recommandée : vider complètement
$Error.Clear()

# Vérification
$Error.Count
# Résultat: 0
```

> [!warning] Attention au timing `$Error.Clear()` supprime **toutes** les erreurs de la session. Assurez-vous d'avoir sauvegardé ou traité les erreurs importantes avant de vider l'historique.

**Pattern recommandé pour isoler des tests :**

```powershell
# Sauvegarder l'état actuel
$erreursPrecedentes = $Error.Clone()
$Error.Clear()

# Code à tester
Get-Item "C:\Test\Fichier.txt" -ErrorAction SilentlyContinue

# Analyser uniquement les nouvelles erreurs
if ($Error.Count -gt 0) {
    Write-Host "Le test a produit $($Error.Count) erreur(s)"
}

# Restaurer si nécessaire (rarement fait en pratique)
# $Error.Clear()
# $erreursPrecedentes | ForEach-Object { $Error.Add($_) }
```

### Limiter la taille de `$Error`

```powershell
# Voir la limite actuelle
$MaximumErrorCount
# Valeur par défaut: 256

# Modifier la limite (persiste pour la session)
$MaximumErrorCount = 100

# Réduire pour les scripts courts
$MaximumErrorCount = 50
```

> [!tip] Quand modifier `$MaximumErrorCount` Réduisez cette valeur dans les scripts courts pour économiser de la mémoire. Augmentez-la dans les sessions de débogage intensif où vous devez conserver un historique étendu.

### Exporter les erreurs

```powershell
# Exporter vers un fichier texte
$Error | Out-File "C:\Logs\erreurs_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Exporter en JSON pour analyse ultérieure
$Error | Select-Object Exception, InvocationInfo, TargetObject | 
    ConvertTo-Json -Depth 5 | 
    Out-File "C:\Logs\erreurs.json"

# Exporter uniquement les messages
$Error | ForEach-Object { $_.Exception.Message } | 
    Out-File "C:\Logs\messages_erreurs.txt"
```

---

## 🔬 Get-Error pour des détails étendus

### Introduction à Get-Error

`Get-Error` est une cmdlet disponible à partir de **PowerShell 7+** qui offre une vue enrichie et formatée de la dernière erreur.

> [!info] Disponibilité `Get-Error` n'existe pas dans Windows PowerShell 5.1. C'est une fonctionnalité exclusive de PowerShell Core 7 et versions ultérieures.

### Utilisation basique

```powershell
# Afficher la dernière erreur avec tous les détails
Get-Error

# Afficher une erreur spécifique
Get-Error -Newest 1

# Afficher les 3 dernières erreurs
Get-Error -Newest 3
```

### Informations supplémentaires fournies

`Get-Error` fournit automatiquement :

- ✅ Exception complète avec type
- ✅ Message d'erreur formaté
- ✅ Stack trace complète
- ✅ Informations de contexte
- ✅ Exception interne (si présente)

**Comparaison `$Error[0]` vs `Get-Error` :**

```powershell
# Générer une erreur
Get-Item "C:\Inexistant.txt"

# Approche classique (plus verbeuse)
Write-Host "Message: $($Error[0].Exception.Message)"
Write-Host "Type: $($Error[0].Exception.GetType().FullName)"
Write-Host "Script: $($Error[0].InvocationInfo.ScriptName)"

# Approche Get-Error (tout en un coup)
Get-Error
# Affiche automatiquement toutes ces informations de manière structurée
```

### Propriétés exploitables

```powershell
# Stocker le résultat pour exploitation
$detailErreur = Get-Error

# Accéder aux propriétés
$detailErreur.Exception
$detailErreur.CategoryInfo
$detailErreur.InvocationInfo
$detailErreur.ErrorDetails
```

> [!tip] Meilleure lisibilité `Get-Error` est idéal lors de sessions interactives de débogage car l'affichage est optimisé pour la console avec coloration et indentation.

---

## 📝 Logging et analyse d'erreurs

### Création d'un système de log simple

```powershell
function Write-ErrorLog {
    param(
        [string]$LogPath = "C:\Logs\script_errors.log"
    )
    
    if ($Error.Count -eq 0) {
        Write-Host "Aucune erreur à logger"
        return
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = @"
[$timestamp] ERREUR DÉTECTÉE
Type: $($Error[0].Exception.GetType().FullName)
Message: $($Error[0].Exception.Message)
Script: $($Error[0].InvocationInfo.ScriptName)
Ligne: $($Error[0].InvocationInfo.ScriptLineNumber)
Commande: $($Error[0].InvocationInfo.Line.Trim())
---------------------------------------------------
"@
    
    Add-Content -Path $LogPath -Value $logEntry
    Write-Host "Erreur loggée dans $LogPath" -ForegroundColor Yellow
}
```

**Utilisation :**

```powershell
# Votre code qui peut générer des erreurs
Get-Item "C:\FichierInexistant.txt" -ErrorAction SilentlyContinue

# Logger si une erreur s'est produite
if ($Error.Count -gt 0) {
    Write-ErrorLog
}
```

### Log structuré avec métadonnées

```powershell
function Export-ErrorReport {
    param(
        [string]$OutputPath = "C:\Logs\error_report.csv"
    )
    
    $errorReport = $Error | ForEach-Object {
        [PSCustomObject]@{
            Timestamp      = Get-Date
            ErrorType      = $_.Exception.GetType().Name
            Message        = $_.Exception.Message
            Command        = $_.InvocationInfo.MyCommand.Name
            ScriptName     = $_.InvocationInfo.ScriptName
            LineNumber     = $_.InvocationInfo.ScriptLineNumber
            Category       = $_.CategoryInfo.Category
            TargetObject   = $_.TargetObject
        }
    }
    
    $errorReport | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "Rapport exporté: $OutputPath"
}
```

### Analyse statistique des erreurs

```powershell
# Statistiques par type d'erreur
$Error | Group-Object { $_.Exception.GetType().Name } | 
    Sort-Object Count -Descending | 
    Format-Table Name, Count -AutoSize

# Top 5 des commandes générant le plus d'erreurs
$Error | Group-Object { $_.InvocationInfo.MyCommand.Name } | 
    Sort-Object Count -Descending | 
    Select-Object -First 5 Name, Count

# Distribution des catégories
$Error | Group-Object { $_.CategoryInfo.Category } | 
    Format-Table Name, Count -AutoSize
```

> [!example] Exemple de rapport complet
> 
> ```powershell
> Write-Host "`n=== RAPPORT D'ERREURS ===" -ForegroundColor Cyan
> Write-Host "Total d'erreurs: $($Error.Count)"
> Write-Host "`nTop 3 des types d'erreurs:"
> $Error | Group-Object { $_.Exception.GetType().Name } | 
>     Sort-Object Count -Descending | 
>     Select-Object -First 3 | 
>     ForEach-Object { Write-Host "  - $($_.Name): $($_.Count)" }
> ```

---

## 🐛 Débogage avec les informations d'erreur

### Tracer l'origine d'une erreur

```powershell
function Trace-LastError {
    if ($Error.Count -eq 0) {
        Write-Host "Aucune erreur récente" -ForegroundColor Green
        return
    }
    
    $err = $Error[0]
    
    Write-Host "`n🔴 ANALYSE DE LA DERNIÈRE ERREUR" -ForegroundColor Red
    Write-Host "================================" -ForegroundColor Red
    
    Write-Host "`n📍 Localisation:"
    if ($err.InvocationInfo.ScriptName) {
        Write-Host "  Fichier: $($err.InvocationInfo.ScriptName)"
        Write-Host "  Ligne: $($err.InvocationInfo.ScriptLineNumber)"
        Write-Host "  Code: $($err.InvocationInfo.Line.Trim())"
    } else {
        Write-Host "  Commande interactive"
    }
    
    Write-Host "`n💥 Exception:"
    Write-Host "  Type: $($err.Exception.GetType().FullName)"
    Write-Host "  Message: $($err.Exception.Message)"
    
    Write-Host "`n🎯 Cible:"
    Write-Host "  Objet: $($err.TargetObject)"
    Write-Host "  Catégorie: $($err.CategoryInfo.Category)"
    
    if ($err.Exception.InnerException) {
        Write-Host "`n🔗 Exception interne:"
        Write-Host "  $($err.Exception.InnerException.Message)"
    }
}
```

### Déboguer avec des points d'arrêt conditionnels

```powershell
# Script avec débogage automatique sur erreur
function Invoke-WithErrorBreak {
    param([scriptblock]$ScriptBlock)
    
    $ErrorActionPreference = 'Stop'
    
    try {
        & $ScriptBlock
    } catch {
        Write-Host "`n⚠️ ERREUR INTERCEPTÉE - MODE DEBUG" -ForegroundColor Yellow
        
        # Afficher le contexte
        Trace-LastError
        
        # Option d'inspection interactive
        Write-Host "`nAppuyez sur Entrée pour continuer ou Ctrl+C pour arrêter..."
        Read-Host
    }
}
```

**Utilisation :**

```powershell
Invoke-WithErrorBreak {
    Get-Item "C:\Test\Fichier.txt"
    Get-Process "ProcessusInexistant"
}
```

### Capture des erreurs silencieuses

Certaines erreurs peuvent être supprimées par `-ErrorAction SilentlyContinue` mais restent dans `$Error`.

```powershell
# Capturer les erreurs même si elles sont silencées
$Error.Clear()

Get-Item "C:\*" -ErrorAction SilentlyContinue

# Analyser les erreurs qui ont quand même eu lieu
Write-Host "Erreurs silencieuses capturées: $($Error.Count)"
$Error | ForEach-Object {
    Write-Host "  - $($_.Exception.Message)"
}
```

---

## ✅ Bonnes pratiques

### 1. Nettoyer `$Error` dans les scripts de test

```powershell
# Au début de chaque test
$Error.Clear()

# Votre code de test
# ...

# Assertions sur les erreurs
if ($Error.Count -gt 0) {
    throw "Le test a généré des erreurs inattendues"
}
```

### 2. Ne pas se fier uniquement à `$Error[0]`

> [!warning] Piège fréquent Dans un bloc `catch`, `$_` représente l'erreur actuelle. Mais `$Error[0]` peut pointer vers une erreur différente si d'autres erreurs se sont produites entre-temps.

```powershell
# ❌ INCORRECT - peut pointer vers une autre erreur
try {
    Get-Item "C:\Inexistant.txt"
} catch {
    # Si d'autres commandes ont échoué, $Error[0] peut ne pas être cette erreur
    Write-Host $Error[0].Exception.Message
}

# ✅ CORRECT - utiliser $_
try {
    Get-Item "C:\Inexistant.txt"
} catch {
    Write-Host $_.Exception.Message  # Toujours l'erreur actuelle
}
```

### 3. Sauvegarder avant de Clear

```powershell
# Pattern de sauvegarde
function Clear-ErrorWithBackup {
    if ($Error.Count -gt 0) {
        $global:LastErrorBackup = $Error.Clone()
        Write-Host "Sauvegarde de $($Error.Count) erreur(s)"
    }
    $Error.Clear()
}
```

### 4. Limiter l'analyse aux erreurs pertinentes

```powershell
# Filtrer par fenêtre temporelle (exemple avec horodatage personnalisé)
$startTime = Get-Date
# ... code ...
$recentErrors = $Error | Where-Object { 
    $_.InvocationInfo.ScriptName -and 
    (Get-Item $_.InvocationInfo.ScriptName).LastWriteTime -gt $startTime
}
```

### 5. Logger de manière asynchrone pour les scripts longs

```powershell
# Éviter de ralentir le script avec des écritures synchrones
$errorQueue = [System.Collections.Concurrent.ConcurrentQueue[object]]::new()

function Log-ErrorAsync {
    $errorQueue.Enqueue($Error[0])
}

# En fin de script
$errorQueue | ForEach-Object {
    # Écriture différée dans le log
}
```

### 6. Utiliser Get-Error en interactif, `$Error` en script

> [!tip] Règle d'usage
> 
> - **Sessions interactives / débogage** : Préférez `Get-Error` pour sa lisibilité
> - **Scripts de production** : Utilisez `$Error` avec accès direct aux propriétés pour plus de contrôle

### 7. Documenter les erreurs attendues

```powershell
# Indiquer clairement les erreurs normales
function Test-FileAccess {
    param([string]$Path)
    
    $Error.Clear()
    
    # Erreur attendue si le fichier n'existe pas
    $result = Get-Item $Path -ErrorAction SilentlyContinue
    
    if ($Error.Count -gt 0 -and $Error[0].CategoryInfo.Category -eq 'ObjectNotFound') {
        Write-Verbose "Erreur attendue: fichier introuvable"
        return $false
    }
    
    return $true
}
```

---

## 🎓 Récapitulatif

La variable `$Error` est un outil puissant pour :

- ✅ **Conserver l'historique** des erreurs de la session
- ✅ **Déboguer** avec un contexte complet (ligne, script, commande)
- ✅ **Logger** de manière structurée et automatisée
- ✅ **Analyser** les patterns d'erreurs dans les scripts complexes
- ✅ **Tester** en isolant et vérifiant les erreurs produites

**Points clés à retenir :**

|Concept|À retenir|
|---|---|
|`$Error[0]`|Dernière erreur (plus récente)|
|`$Error.Clear()`|Vider l'historique|
|`.Exception.Message`|Message d'erreur lisible|
|`.InvocationInfo`|Localisation précise de l'erreur|
|`Get-Error`|Vue enrichie (PS 7+)|
|`$MaximumErrorCount`|Limite du nombre d'erreurs conservées (défaut: 256)|

> [!tip] Conseil final Prenez l'habitude d'inspecter `$Error` après l'exécution de scripts complexes, même s'ils se sont terminés normalement. Des erreurs silencieuses peuvent révéler des problèmes potentiels.