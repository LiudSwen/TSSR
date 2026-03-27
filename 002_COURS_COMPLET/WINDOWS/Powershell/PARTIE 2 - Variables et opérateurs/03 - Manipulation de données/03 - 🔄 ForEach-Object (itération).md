

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

`ForEach-Object` est une cmdlet PowerShell conçue pour **traiter des objets un par un dans un pipeline**. Contrairement à d'autres structures d'itération, elle s'intègre naturellement dans le flux de données PowerShell et permet de transformer, filtrer ou agir sur chaque élément reçu.

> [!info] Pourquoi utiliser ForEach-Object ?
> 
> - **Efficacité mémoire** : traite les objets au fur et à mesure sans les stocker tous en mémoire
> - **Intégration pipeline** : s'insère naturellement dans les chaînes de commandes
> - **Streaming** : commence à produire des résultats avant la fin du traitement
> - **Flexibilité** : permet des opérations simples ou complexes sur chaque élément

> [!example] Cas d'usage typiques
> 
> - Transformer des propriétés d'objets
> - Effectuer des opérations sur des fichiers
> - Appeler des méthodes sur chaque objet
> - Exécuter des commandes pour chaque élément d'une collection

---

## 📝 Syntaxe de base

`ForEach-Object` accepte un **bloc de script** qui sera exécuté pour chaque objet reçu dans le pipeline.

### Syntaxe complète

```powershell
ForEach-Object [-Process] <ScriptBlock[]>
               [-Begin <ScriptBlock>]
               [-End <ScriptBlock>]
               [-RemainingScripts <ScriptBlock[]>]
               [-InputObject <PSObject>]
```

### Syntaxe simplifiée (la plus courante)

```powershell
# Forme longue
Get-Process | ForEach-Object { $_.Name }

# Forme abrégée avec alias
Get-Process | foreach { $_.Name }
Get-Process | % { $_.Name }

# Forme ultra-courte (PowerShell 3.0+)
Get-Process | ForEach-Object Name
```

> [!tip] Alias courants
> 
> - `foreach` (attention à ne pas confondre avec l'instruction `foreach`)
> - `%` (pratique pour les one-liners)

### Exemples de base

```powershell
# Afficher les noms des processus
Get-Process | ForEach-Object { Write-Host $_.ProcessName }

# Multiplier chaque nombre par 2
1..10 | ForEach-Object { $_ * 2 }

# Convertir des noms en majuscules
'alice', 'bob', 'charlie' | ForEach-Object { $_.ToUpper() }

# Obtenir la taille des fichiers
Get-ChildItem | ForEach-Object { $_.Length }
```

---

## 💡 La variable `$_` dans le contexte

`$_` (aussi appelée `$PSItem` depuis PowerShell 3.0) représente **l'objet courant** dans le pipeline.

### Comprendre `$_`

```powershell
# $_ représente chaque nombre dans la séquence
1..5 | ForEach-Object { 
    Write-Host "Nombre courant : $_"
    Write-Host "Carré : $($_ * $_)"
}

# Sortie :
# Nombre courant : 1
# Carré : 1
# Nombre courant : 2
# Carré : 4
# ...
```

### Accéder aux propriétés et méthodes

```powershell
# Accéder aux propriétés d'un objet
Get-Service | ForEach-Object {
    "Service : $($_.Name) - État : $($_.Status)"
}

# Appeler des méthodes
Get-Process | ForEach-Object {
    $_.Kill()  # ⚠️ Termine tous les processus !
}

# Utiliser $PSItem (équivalent à $_)
1..3 | ForEach-Object {
    Write-Host "Valeur avec `$_ : $_"
    Write-Host "Valeur avec `$PSItem : $PSItem"
}
```

> [!warning] Portée de `$_` `$_` n'existe que **dans le bloc de script** de `ForEach-Object`. En dehors, elle est vide ou contient une ancienne valeur.

### Manipulation complexe

```powershell
# Créer des objets personnalisés
Get-Process | ForEach-Object {
    [PSCustomObject]@{
        Nom = $_.ProcessName
        PID = $_.Id
        Memoire_MB = [math]::Round($_.WorkingSet64 / 1MB, 2)
        CPU_Sec = [math]::Round($_.TotalProcessorTime.TotalSeconds, 2)
    }
} | Format-Table

# Filtrage et transformation combinés
Get-ChildItem -File | ForEach-Object {
    if ($_.Length -gt 1MB) {
        [PSCustomObject]@{
            Fichier = $_.Name
            Taille_MB = [math]::Round($_.Length / 1MB, 2)
            Ancien = $_.CreationTime -lt (Get-Date).AddDays(-30)
        }
    }
}
```

---

## 🎭 Blocs Begin, Process et End

`ForEach-Object` peut utiliser trois blocs distincts pour structurer le traitement :

|Bloc|Exécution|Usage typique|
|---|---|---|
|**Begin**|Une fois **avant** le premier objet|Initialisation de variables, connexions|
|**Process**|Une fois **pour chaque** objet|Traitement principal|
|**End**|Une fois **après** le dernier objet|Finalisation, résumés, nettoyage|

### Syntaxe avec les trois blocs

```powershell
Get-Process | ForEach-Object `
    -Begin { 
        Write-Host "=== Démarrage du traitement ===" 
        $compteur = 0
    } `
    -Process { 
        $compteur++
        Write-Host "Processus $compteur : $($_.ProcessName)"
    } `
    -End { 
        Write-Host "=== Fin : $compteur processus traités ===" 
    }
```

### Exemple pratique : calcul de statistiques

```powershell
Get-ChildItem -File | ForEach-Object `
    -Begin {
        $totalTaille = 0
        $nombreFichiers = 0
        $fichiersPlusGros = $null
        $taillePlusGrosse = 0
    } `
    -Process {
        $nombreFichiers++
        $totalTaille += $_.Length
        
        if ($_.Length -gt $taillePlusGrosse) {
            $taillePlusGrosse = $_.Length
            $fichiersPlusGros = $_.Name
        }
    } `
    -End {
        Write-Host "Nombre de fichiers : $nombreFichiers"
        Write-Host "Taille totale : $([math]::Round($totalTaille / 1MB, 2)) MB"
        Write-Host "Taille moyenne : $([math]::Round(($totalTaille / $nombreFichiers) / 1KB, 2)) KB"
        Write-Host "Plus gros fichier : $fichiersPlusGros ($([math]::Round($taillePlusGrosse / 1MB, 2)) MB)"
    }
```

> [!tip] Quand utiliser chaque bloc ?
> 
> - **Begin** : initialiser des compteurs, ouvrir des connexions, afficher des en-têtes
> - **Process** : logique de traitement principale (obligatoire)
> - **End** : afficher des totaux, fermer des connexions, générer des rapports

### Traitement de fichier ligne par ligne

```powershell
Get-Content .\logs.txt | ForEach-Object `
    -Begin {
        $erreurs = 0
        $warnings = 0
        $infos = 0
    } `
    -Process {
        if ($_ -match 'ERROR') { $erreurs++ }
        elseif ($_ -match 'WARNING') { $warnings++ }
        elseif ($_ -match 'INFO') { $infos++ }
    } `
    -End {
        Write-Host "Résumé du fichier de logs :"
        Write-Host "  Erreurs : $erreurs"
        Write-Host "  Warnings : $warnings"
        Write-Host "  Infos : $infos"
    }
```

---

## 🔀 Différence avec la boucle `foreach`

Bien qu'ils semblent similaires, `ForEach-Object` (cmdlet) et `foreach` (instruction) ont des comportements très différents.

### Comparaison

|Critère|`ForEach-Object` (cmdlet)|`foreach` (instruction)|
|---|---|---|
|**Type**|Cmdlet PowerShell|Instruction de langage|
|**Pipeline**|✅ S'intègre dans le pipeline|❌ Requiert une collection complète|
|**Mémoire**|✅ Streaming (objet par objet)|❌ Charge tout en mémoire|
|**Syntaxe**|`|ForEach-Object { }`|
|**Performance**|Plus lent pour petites collections|Plus rapide pour collections en mémoire|
|**Alias**|`foreach`, `%`|`foreach` (mot-clé)|
|**Blocs Begin/End**|✅ Disponibles|❌ Non disponibles|

### Exemples comparatifs

```powershell
# ForEach-Object - Traitement dans le pipeline
Get-Process | ForEach-Object { $_.Name }

# foreach - Instruction de boucle classique
$processes = Get-Process
foreach ($proc in $processes) {
    $proc.Name
}
```

### Quand utiliser l'un ou l'autre ?

> [!example] Utilisez `ForEach-Object` quand :
> 
> - Vous travaillez dans un pipeline
> - Vous avez de grandes collections (économie mémoire)
> - Vous voulez commencer le traitement avant d'avoir tous les objets
> - Vous avez besoin des blocs Begin/End

> [!example] Utilisez `foreach` quand :
> 
> - Vous avez déjà une collection en mémoire
> - La performance pure est critique
> - Vous avez besoin de `break` ou `continue`
> - Le code est plus lisible avec cette syntaxe

### Exemple de performance

```powershell
# Collection de 10 000 éléments
$collection = 1..10000

# Mesure avec ForEach-Object
Measure-Command {
    $collection | ForEach-Object { $_ * 2 }
}
# Temps : ~500-800 ms

# Mesure avec foreach
Measure-Command {
    foreach ($item in $collection) { $item * 2 }
}
# Temps : ~50-100 ms

# ⚠️ Mais si la collection vient d'un pipeline...
Measure-Command {
    1..10000 | ForEach-Object { $_ * 2 }
}
# ForEach-Object est le seul choix logique ici !
```

> [!warning] Piège courant Ne confondez pas l'**alias** `foreach` (qui pointe vers `ForEach-Object`) avec l'**instruction** `foreach`. Dans un pipeline, vous utilisez toujours la cmdlet.

---

## 🔗 Utilisation dans le pipeline

`ForEach-Object` brille particulièrement dans les pipelines complexes où elle permet de transformer et enrichir les données.

### Chaînage de transformations

```powershell
# Pipeline simple
Get-Service | 
    ForEach-Object { $_.Name } |
    Where-Object { $_ -match '^W' } |
    Sort-Object

# Pipeline complexe avec transformation
Get-Process |
    Where-Object { $_.WorkingSet64 -gt 100MB } |
    ForEach-Object {
        [PSCustomObject]@{
            Nom = $_.ProcessName
            PID = $_.Id
            Memoire_GB = [math]::Round($_.WorkingSet64 / 1GB, 2)
            Priorite = $_.BasePriority
        }
    } |
    Sort-Object Memoire_GB -Descending |
    Select-Object -First 10 |
    Format-Table -AutoSize
```

### Appels de méthodes en cascade

```powershell
# Manipuler des chaînes
'hello', 'world', 'powershell' |
    ForEach-Object { $_.ToUpper() } |
    ForEach-Object { $_.Replace('O', '0') } |
    ForEach-Object { "*** $_ ***" }

# Sortie :
# *** HELL0 ***
# *** W0RLD ***
# *** P0WERSHELL ***
```

### Traitement conditionnel dans le pipeline

```powershell
Get-ChildItem | ForEach-Object {
    if ($_.PSIsContainer) {
        "📁 Dossier : $($_.Name)"
    } else {
        "📄 Fichier : $($_.Name) - $([math]::Round($_.Length / 1KB, 2)) KB"
    }
}
```

### Enrichissement d'objets

```powershell
# Ajouter des propriétés calculées
Get-Process | ForEach-Object {
    $_ | Add-Member -NotePropertyName 'Memoire_MB' `
                    -NotePropertyValue ([math]::Round($_.WorkingSet64 / 1MB, 2)) `
                    -PassThru
} | Select-Object ProcessName, Id, Memoire_MB | Format-Table
```

### Pipeline avec plusieurs ForEach-Object

```powershell
# Chaque ForEach-Object traite le résultat du précédent
1..5 | 
    ForEach-Object { $_ * 2 } |        # [2, 4, 6, 8, 10]
    ForEach-Object { $_ + 10 } |       # [12, 14, 16, 18, 20]
    ForEach-Object { "Valeur : $_" }   # Affichage formaté
```

---

## ⚡ Performance et cas d'usage

La performance de `ForEach-Object` dépend fortement du contexte d'utilisation.

### Analyse de performance

```powershell
# Test 1 : Petite collection (100 éléments)
$petite = 1..100

Measure-Command { $petite | ForEach-Object { $_ * 2 } }
# ~15-30 ms

Measure-Command { foreach ($i in $petite) { $i * 2 } }
# ~2-5 ms
# ✅ foreach est 5-10x plus rapide

# Test 2 : Grande collection (100 000 éléments)
$grande = 1..100000

Measure-Command { $grande | ForEach-Object { $_ * 2 } }
# ~5-8 secondes

Measure-Command { foreach ($i in $grande) { $i * 2 } }
# ~0.5-1 seconde
# ✅ foreach reste beaucoup plus rapide

# Test 3 : Streaming depuis une source externe
Measure-Command {
    Get-ChildItem -Recurse | ForEach-Object { $_.FullName }
}
# ForEach-Object commence immédiatement
# foreach devrait d'abord collecter TOUS les fichiers
```

### Quand privilégier ForEach-Object ?

> [!tip] Cas favorables à ForEach-Object
> 
> 1. **Pipeline existant** : données provenant d'une cmdlet
> 2. **Grandes sources** : fichiers volumineux, résultats de requêtes
> 3. **Streaming requis** : besoin de résultats progressifs
> 4. **Intégration** : chaînage avec d'autres cmdlets
> 5. **Lisibilité** : pipelines PowerShell idiomatiques

### Optimisations possibles

```powershell
# ❌ Lent : ForEach-Object avec opérations complexes
Get-ChildItem -Recurse | ForEach-Object {
    $hash = Get-FileHash $_.FullName
    [PSCustomObject]@{
        Fichier = $_.Name
        Hash = $hash.Hash
    }
}

# ✅ Meilleur : Utiliser le pipeline natif
Get-ChildItem -Recurse | Get-FileHash | ForEach-Object {
    [PSCustomObject]@{
        Fichier = Split-Path $_.Path -Leaf
        Hash = $_.Hash
    }
}

# ✅ Encore meilleur : Éviter ForEach-Object si possible
Get-ChildItem -Recurse | 
    Get-FileHash | 
    Select-Object @{N='Fichier'; E={Split-Path $_.Path -Leaf}}, Hash
```

### Cas d'usage typiques

#### 1. Traitement de fichiers

```powershell
# Renommer des fichiers en masse
Get-ChildItem *.txt | ForEach-Object {
    $nouveauNom = $_.Name -replace '\.txt$', '_backup.txt'
    Rename-Item $_.FullName -NewName $nouveauNom
}

# Compresser des fichiers
Get-ChildItem *.log | ForEach-Object {
    Compress-Archive -Path $_.FullName -DestinationPath "$($_.BaseName).zip"
}
```

#### 2. Opérations réseau

```powershell
# Tester la connectivité sur plusieurs serveurs
'server1', 'server2', 'server3' | ForEach-Object {
    Test-Connection $_ -Count 1 -Quiet
}

# Interroger des services web
$urls = @('https://api1.com', 'https://api2.com')
$urls | ForEach-Object {
    try {
        Invoke-RestMethod -Uri "$_/status" -TimeoutSec 5
    } catch {
        Write-Warning "Échec pour $_"
    }
}
```

#### 3. Administration système

```powershell
# Arrêter des services spécifiques
Get-Service | 
    Where-Object { $_.Name -like 'Test*' } |
    ForEach-Object { 
        Stop-Service $_.Name -Force
        Write-Host "Service $($_.Name) arrêté"
    }

# Créer des utilisateurs en masse
Import-Csv .\utilisateurs.csv | ForEach-Object {
    New-LocalUser -Name $_.Username -Password (ConvertTo-SecureString $_.Password -AsPlainText -Force)
}
```

---

## 🚀 Paramètre `-Parallel` (PowerShell 7+)

PowerShell 7 introduit le paramètre `-Parallel` qui permet d'exécuter `ForEach-Object` en **parallèle** sur plusieurs threads.

### Syntaxe

```powershell
1..10 | ForEach-Object -Parallel {
    Start-Sleep -Seconds 1
    "Traité : $_"
} -ThrottleLimit 5
```

### Paramètres clés

|Paramètre|Description|Valeur par défaut|
|---|---|---|
|`-Parallel`|Active le traitement parallèle|-|
|`-ThrottleLimit`|Nombre max de threads simultanés|5|
|`-TimeoutSeconds`|Timeout pour chaque itération|Infini|
|`-AsJob`|Exécute comme background job|-|

### Exemple basique

```powershell
# Séquentiel (10 secondes)
Measure-Command {
    1..10 | ForEach-Object {
        Start-Sleep -Seconds 1
        "Élément $_"
    }
}
# Temps : ~10 secondes

# Parallèle (2 secondes avec ThrottleLimit 5)
Measure-Command {
    1..10 | ForEach-Object -Parallel {
        Start-Sleep -Seconds 1
        "Élément $_"
    } -ThrottleLimit 5
}
# Temps : ~2 secondes (5 threads × 2 vagues)
```

### Cas d'usage réels

#### Téléchargement parallèle

```powershell
$urls = @(
    'https://example.com/file1.zip',
    'https://example.com/file2.zip',
    'https://example.com/file3.zip',
    'https://example.com/file4.zip'
)

$urls | ForEach-Object -Parallel {
    $fileName = Split-Path $_ -Leaf
    Invoke-WebRequest -Uri $_ -OutFile "C:\Downloads\$fileName"
    Write-Host "Téléchargé : $fileName"
} -ThrottleLimit 3
```

#### Traitement de fichiers volumineux

```powershell
Get-ChildItem *.log | ForEach-Object -Parallel {
    $contenu = Get-Content $_.FullName
    $lignesErreur = $contenu | Where-Object { $_ -match 'ERROR' }
    
    [PSCustomObject]@{
        Fichier = $_.Name
        Erreurs = $lignesErreur.Count
    }
} -ThrottleLimit 4 | Format-Table
```

#### Ping parallèle de serveurs

```powershell
$serveurs = 1..254 | ForEach-Object { "192.168.1.$_" }

$resultats = $serveurs | ForEach-Object -Parallel {
    $ip = $_
    $ping = Test-Connection $ip -Count 1 -Quiet -TimeoutSeconds 1
    
    if ($ping) {
        [PSCustomObject]@{
            IP = $ip
            Statut = 'En ligne'
        }
    }
} -ThrottleLimit 50

$resultats | Format-Table
```

### Variables et portée

> [!warning] Accès aux variables externes Les scripts parallèles s'exécutent dans des **runspaces isolés**. Vous devez utiliser `$using:` pour accéder aux variables du scope parent.

```powershell
$prefixe = "Serveur"
$suffixe = "Production"

1..5 | ForEach-Object -Parallel {
    # ❌ Ceci ne fonctionnera pas
    # "$prefixe-$_-$suffixe"
    
    # ✅ Utiliser $using:
    "$using:prefixe-$_-$using:suffixe"
}

# Sortie :
# Serveur-1-Production
# Serveur-2-Production
# ...
```

### Précautions et limites

> [!warning] Attention aux ressources
> 
> - Chaque thread consomme de la mémoire
> - Trop de threads peuvent surcharger le système
> - Les opérations I/O intensives (disque, réseau) bénéficient le plus du parallélisme
> - Les calculs CPU légers peuvent être plus lents en parallèle (overhead)

```powershell
# ❌ Mauvais : trop de threads pour une opération simple
1..1000 | ForEach-Object -Parallel {
    $_ * 2
} -ThrottleLimit 100
# L'overhead du threading ralentit l'exécution

# ✅ Bon : opération I/O qui bénéficie du parallélisme
Get-ChildItem *.csv | ForEach-Object -Parallel {
    Import-Csv $_.FullName | Export-Csv "$($_.BaseName)_processed.csv"
} -ThrottleLimit 4
```

### Gestion des erreurs en parallèle

```powershell
$urls | ForEach-Object -Parallel {
    try {
        Invoke-WebRequest -Uri $_ -OutFile "C:\Temp\$(Split-Path $_ -Leaf)" -ErrorAction Stop
        Write-Host "✅ Succès : $_" -ForegroundColor Green
    } catch {
        Write-Host "❌ Échec : $_ - $($_.Exception.Message)" -ForegroundColor Red
    }
} -ThrottleLimit 5
```

---

## 📦 Exemples de traitement par lot

### Traitement de fichiers CSV

```powershell
# Importer et transformer des données
Import-Csv .\employes.csv | ForEach-Object {
    [PSCustomObject]@{
        NomComplet = "$($_.Prenom) $($_.Nom)"
        Email = "$($_.Prenom).$($_.Nom)@entreprise.com".ToLower()
        Departement = $_.Dept
        Salaire = [int]$_.Salaire
        Augmentation = [int]$_.Salaire * 1.05
    }
} | Export-Csv .\employes_traites.csv -NoTypeInformation
```

### Génération de rapports

```powershell
# Rapport sur l'utilisation du disque
Get-ChildItem -Path C:\ -Directory | ForEach-Object `
    -Begin {
        $rapport = @()
        Write-Host "=== Analyse des dossiers ===" -ForegroundColor Cyan
    } `
    -Process {
        $taille = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                   Measure-Object -Property Length -Sum).Sum
        
        $rapport += [PSCustomObject]@{
            Dossier = $_.Name
            Taille_GB = [math]::Round($taille / 1GB, 2)
            DateModif = $_.LastWriteTime
        }
        
        Write-Progress -Activity "Analyse en cours" -Status $_.Name
    } `
    -End {
        Write-Host "`n=== Rapport final ===" -ForegroundColor Cyan
        $rapport | Sort-Object Taille_GB -Descending | Format-Table -AutoSize
        
        $total = ($rapport | Measure-Object -Property Taille_GB -Sum).Sum
        Write-Host "Espace total utilisé : $total GB" -ForegroundColor Yellow
    }
```

### Traitement par lots avec progression

```powershell
$fichiers = Get-ChildItem *.txt
$total = $fichiers.Count
$compteur = 0

$fichiers | ForEach-Object {
    $compteur++
    $pourcentage = ($compteur / $total) * 100
    
    Write-Progress -Activity "Traitement des fichiers" `
                   -Status "Fichier $compteur sur $total" `
                   -PercentComplete $pourcentage
    
    # Traitement
    $contenu = Get-Content $_.FullName
    $contenu -replace 'ancien', 'nouveau' | Set-Content $_.FullName
    
    Start-Sleep -Milliseconds 100  # Simulation
}

Write-Progress -Activity "Traitement des fichiers" -Completed
```

### Traitement conditionnel par lot

```powershell
Get-ChildItem | ForEach-Object {
    switch ($_.Extension) {
        '.txt' {
            Write-Host "📝 Fichier texte : $($_.Name)" -ForegroundColor Green
            # Traitement spécifique aux .txt
        }
        '.csv' {
            Write-Host "📊 Fichier CSV : $($_.Name)" -ForegroundColor Cyan
            # Traitement spécifique aux .csv
        }
        '.log' {
            Write-Host "📋 Fichier log : $($_.Name)" -ForegroundColor Yellow
            # Traitement spécifique aux .log
        }
        default {
            Write-Host "❓ Autre type : $($_.Name)" -ForegroundColor Gray
        }
    }
}
```

### Regroupement et agrégation

```powershell
# Grouper des processus par utilisation mémoire
Get-Process | ForEach-Object `
    -Begin {
        $categories = @{
            Faible = @()
            Moyen = @()
            Eleve = @()
        }
    } `
    -Process {
        $memoire = $_.WorkingSet64 / 1MB
        
        if ($memoire -lt 50) {
            $categories.Faible += $_.ProcessName
        } elseif ($memoire -lt 200) {
            $categories.Moyen += $_.ProcessName
        } else {
            $categories.Eleve += $_.ProcessName
        }
    } `
    -End {
        Write-Host "`n=== Répartition par utilisation mémoire ===" -ForegroundColor Cyan
        Write-Host "Faible (< 50 MB) : $($categories.Faible.Count) processus"
        Write-Host "Moyen (50-200 MB) : $($categories.Moyen.Count) processus"
        Write-Host "Élevé (> 200 MB) : $($categories.Eleve.Count) processus"
        
        Write-Host "`nTop 5 des gros consommateurs :" -ForegroundColor Yellow
        $categories.Eleve | Select-Object -First 5 | ForEach-Object { "  - $_" }
    }
```

---

## ⚠️ Pièges courants

### 1. Confusion entre `ForEach-Object` et `foreach`

```powershell
# ❌ Tentative d'utiliser foreach dans un pipeline
Get-Process | foreach ($proc in $_) { $proc.Name }
# Erreur : syntaxe invalide

# ✅ Correct
Get-Process | ForEach-Object { $_.Name }
```

### 2. Variable `$_` hors de portée

```powershell
# ❌ $_ n'existe pas en dehors du bloc
Get-Process | ForEach-Object { $_.Name }
Write-Host "Dernier processus : $_"  # $_ est vide ici !

# ✅ Stocker dans une variable
$dernier = Get-Process | ForEach-Object { $_ } | Select-Object -Last 1
Write-Host "Dernier processus : $($dernier.Name)"
```

### 3. Modification de collection pendant l'itération

```powershell
# ❌ Supprimer des fichiers pendant qu'on les parcourt peut causer des erreurs
Get-ChildItem *.tmp | ForEach-Object {
    Remove-Item $_.FullName  # Risqué si le pipeline n'est pas encore terminé
}

# ✅ Collecter d'abord, puis agir
$fichiers = Get-ChildItem *.tmp
$fichiers | ForEach-Object { Remove-Item $_.FullName }

# ✅ Ou utiliser directement Remove-Item
Get-ChildItem *.tmp | Remove-Item
```

### 4. Performance avec grandes collections

```powershell
# ❌ ForEach-Object inutile quand foreach est plus rapide
$nombres = 1..100000
$nombres | ForEach-Object { $_ * 2 }  # Lent

# ✅ Utiliser foreach pour les collections en mémoire
foreach ($n in $nombres) { $n * 2 }  # Beaucoup plus rapide
```

### 5. Oublier `-Parallel` nécessite `$using:`

```powershell
$seuil = 100

# ❌ La variable $seuil n'est pas accessible
1..10 | ForEach-Object -Parallel {
    if ($_ -gt $seuil) { "Grand" }  # $seuil est vide !
}

# ✅ Utiliser $using:
1..10 | ForEach-Object -Parallel {
    if ($_ -gt $using:seuil) { "Grand" }
}
```

### 6. Pipeline vide ou null

```powershell
# ❌ Ne vérifie pas si le pipeline contient des données
$null | ForEach-Object { Write-Host "Traitement de $_" }
# N'affiche rien mais n'indique pas d'erreur

# ✅ Vérifier avant de traiter
$donnees = Get-SomeData
if ($donnees) {
    $donnees | ForEach-Object { Write-Host "Traitement de $_" }
} else {
    Write-Warning "Aucune donnée à traiter"
}
```

### 7. Erreurs non gérées

```powershell
# ❌ Une erreur arrête tout le pipeline
Get-ChildItem | ForEach-Object {
    Get-Content $_.FullName  # Erreur si c'est un dossier
}

# ✅ Gérer les erreurs
Get-ChildItem | ForEach-Object {
    try {
        if (-not $_.PSIsContainer) {
            Get-Content $_.FullName -ErrorAction Stop
        }
    } catch {
        Write-Warning "Impossible de lire $($_.Name) : $($_.Exception.Message)"
    }
}
```

### 8. ThrottleLimit trop élevé

```powershell
# ❌ Trop de threads peuvent saturer le système
1..1000 | ForEach-Object -Parallel {
    Invoke-WebRequest "https://api.example.com/data/$_"
} -ThrottleLimit 500  # Mauvaise idée !

# ✅ Limiter raisonnablement selon les ressources
1..1000 | ForEach-Object -Parallel {
    Invoke-WebRequest "https://api.example.com/data/$_"
} -ThrottleLimit 10  # Plus raisonnable
```

---

## ✨ Bonnes pratiques

### 1. Choisir la bonne approche

> [!tip] Arbre de décision
> 
> ```
> Données dans un pipeline ? 
>   ├─ Oui → ForEach-Object
>   └─ Non → Collection en mémoire ?
>       ├─ Oui → foreach (plus rapide)
>       └─ Non → ForEach-Object
> ```

### 2. Utiliser les alias avec discernement

```powershell
# ✅ OK pour les one-liners et tests rapides
Get-Process | % { $_.Name }

# ✅ Préférable dans les scripts partagés/production
Get-Process | ForEach-Object { $_.Name }

# 📝 Clarté > Concision dans le code de production
```

### 3. Structurer avec Begin/Process/End

```powershell
# ✅ Code bien structuré et maintenable
Get-ChildItem -File | ForEach-Object `
    -Begin {
        Write-Host "Début de l'analyse..." -ForegroundColor Cyan
        $resultats = @()
    } `
    -Process {
        $resultats += [PSCustomObject]@{
            Fichier = $_.Name
            Taille = $_.Length
        }
    } `
    -End {
        Write-Host "Analyse terminée : $($resultats.Count) fichiers" -ForegroundColor Green
        $resultats | Export-Csv -Path .\rapport.csv -NoTypeInformation
    }
```

### 4. Optimiser les pipelines

```powershell
# ❌ Plusieurs ForEach-Object inutiles
Get-Process | 
    ForEach-Object { $_ } |
    ForEach-Object { $_ } |
    ForEach-Object { $_.Name }

# ✅ Un seul suffit
Get-Process | ForEach-Object { $_.Name }

# ✅ Ou même mieux : utiliser Select-Object
Get-Process | Select-Object -ExpandProperty Name
```

### 5. Gérer les erreurs proprement

```powershell
# ✅ Gestion d'erreurs robuste
Get-ChildItem | ForEach-Object {
    try {
        $contenu = Get-Content $_.FullName -ErrorAction Stop
        # Traitement...
    } catch [System.UnauthorizedAccessException] {
        Write-Warning "Accès refusé : $($_.Name)"
    } catch {
        Write-Error "Erreur inattendue sur $($_.Name) : $_"
    }
}
```

### 6. Documenter les scripts complexes

```powershell
# ✅ Commentaires clairs pour la maintenance
Get-ChildItem -Recurse | ForEach-Object `
    -Begin {
        # Initialisation des compteurs pour le rapport final
        $compteurFichiers = 0
        $tailleTotal = 0
    } `
    -Process {
        # Traitement de chaque élément
        if (-not $_.PSIsContainer) {
            $compteurFichiers++
            $tailleTotal += $_.Length
            
            # Log pour le suivi de progression
            if ($compteurFichiers % 100 -eq 0) {
                Write-Verbose "Traité : $compteurFichiers fichiers"
            }
        }
    } `
    -End {
        # Génération du rapport
        Write-Host "Fichiers analysés : $compteurFichiers"
        Write-Host "Taille totale : $([math]::Round($tailleTotal / 1GB, 2)) GB"
    }
```

### 7. Utiliser `-Parallel` judicieusement

```powershell
# ✅ Bon cas d'usage : opérations I/O longues
$serveurs | ForEach-Object -Parallel {
    Test-Connection $_ -Count 1
} -ThrottleLimit 10

# ❌ Mauvais cas : calculs simples
1..100 | ForEach-Object -Parallel {
    $_ * 2  # L'overhead du threading ralentit l'exécution
}

# ✅ Version séquentielle plus rapide pour les calculs simples
1..100 | ForEach-Object { $_ * 2 }
```

### 8. Nommer les variables clairement

```powershell
# ❌ Pas clair
Get-Process | ForEach-Object {
    $x = $_.WorkingSet64 / 1MB
    if ($x -gt 100) { $_.Name }
}

# ✅ Noms explicites
Get-Process | ForEach-Object {
    $memoireMB = $_.WorkingSet64 / 1MB
    if ($memoireMB -gt 100) {
        Write-Output $_.Name
    }
}
```

### 9. Préférer les cmdlets natives quand possible

```powershell
# ❌ ForEach-Object inutile
Get-Process | ForEach-Object { $_.Name } | Sort-Object

# ✅ Select-Object fait le travail
Get-Process | Select-Object -ExpandProperty Name | Sort-Object

# ❌ Boucle manuelle
Get-Service | ForEach-Object {
    if ($_.Status -eq 'Running') { $_ }
}

# ✅ Where-Object est fait pour ça
Get-Service | Where-Object Status -eq 'Running'
```

### 10. Tester avec de petits échantillons

```powershell
# ✅ Tester d'abord sur un petit ensemble
Get-ChildItem -Recurse | 
    Select-Object -First 10 |  # Limiter pour les tests
    ForEach-Object {
        # Votre traitement complexe ici
    }

# Une fois validé, retirer la limitation
Get-ChildItem -Recurse | 
    ForEach-Object {
        # Votre traitement complexe ici
    }
```

---

## 🎯 Astuces avancées

### 1. Compteur personnalisé dans Process

```powershell
Get-ChildItem | ForEach-Object `
    -Begin { $i = 0 } `
    -Process { 
        $i++
        "[${i}] $($_.Name)"
    }
```

### 2. Combinaison avec Where-Object

```powershell
# Filtrage ET transformation dans le même pipeline
Get-Process | 
    Where-Object WorkingSet64 -gt 100MB |
    ForEach-Object {
        [PSCustomObject]@{
            Processus = $_.Name
            Memoire_GB = [math]::Round($_.WorkingSet64 / 1GB, 3)
        }
    } |
    Sort-Object Memoire_GB -Descending
```

### 3. Utiliser -PipelineVariable

```powershell
# Accéder à l'objet original plus loin dans le pipeline
Get-ChildItem | ForEach-Object -PipelineVariable fichier {
    Get-Content $_.FullName
} | Where-Object { $_ -match 'ERROR' } | ForEach-Object {
    "Erreur trouvée dans $($fichier.Name) : $_"
}
```

### 4. Technique du "splat" avec ForEach-Object

```powershell
# Paramètres dans une hashtable
$params = @{
    Begin = { $total = 0 }
    Process = { $total += $_ }
    End = { "Total : $total" }
}

1..100 | ForEach-Object @params
```

### 5. Créer des fonctions wrapper

```powershell
function Invoke-ParallelProcess {
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject,
        
        [scriptblock]$ScriptBlock,
        
        [int]$ThrottleLimit = 5
    )
    
    begin { $items = @() }
    process { $items += $InputObject }
    end {
        $items | ForEach-Object -Parallel $ScriptBlock -ThrottleLimit $ThrottleLimit
    }
}

# Utilisation
1..10 | Invoke-ParallelProcess -ScriptBlock {
    Start-Sleep -Seconds 1
    "Traité : $_"
}
```

### 6. Pattern "Try-Process-Finally" avec Begin/End

```powershell
Get-ChildItem | ForEach-Object `
    -Begin {
        # Setup (équivalent Try)
        $connexion = Connect-SomeService
    } `
    -Process {
        # Traitement principal
        Send-Data -Connection $connexion -Data $_
    } `
    -End {
        # Cleanup (équivalent Finally)
        Disconnect-SomeService -Connection $connexion
    }
```

### 7. Progress bar avancée

```powershell
$fichiers = Get-ChildItem -Recurse
$total = $fichiers.Count
$traites = 0

$fichiers | ForEach-Object {
    $traites++
    $pct = ($traites / $total) * 100
    
    Write-Progress -Activity "Traitement fichiers" `
                   -Status "$traites / $total - $($_.Name)" `
                   -PercentComplete $pct `
                   -SecondsRemaining (($total - $traites) * 0.5)
    
    # Votre traitement
    Start-Sleep -Milliseconds 500
}
```

### 8. Pattern de retry avec ForEach-Object

```powershell
$urls | ForEach-Object {
    $tentatives = 0
    $succes = $false
    
    while (-not $succes -and $tentatives -lt 3) {
        $tentatives++
        try {
            Invoke-WebRequest -Uri $_ -ErrorAction Stop
            $succes = $true
            Write-Host "✅ Succès pour $_ (tentative $tentatives)"
        } catch {
            Write-Warning "❌ Échec tentative $tentatives pour $_"
            Start-Sleep -Seconds (2 * $tentatives)
        }
    }
}
```

---

## 📚 Résumé

`ForEach-Object` est une cmdlet puissante et flexible pour le traitement d'objets dans le pipeline PowerShell :

|Aspect|Points clés|
|---|---|
|**Utilisation**|Traitement objet par objet dans un pipeline|
|**Variable**|`$_` ou `$PSItem` représente l'objet courant|
|**Structure**|Blocs optionnels Begin, Process (requis), End|
|**Performance**|Plus lent que `foreach` mais économe en mémoire|
|**Pipeline**|S'intègre naturellement dans les chaînes de commandes|
|**Parallélisme**|`-Parallel` disponible dans PowerShell 7+|
|**Alias**|`foreach`, `%`|

> [!tip] Quand utiliser ForEach-Object ?
> 
> - ✅ Données provenant d'un pipeline
> - ✅ Grandes collections (streaming)
> - ✅ Traitement progressif requis
> - ✅ Besoin de Begin/End
> - ❌ Collections en mémoire de taille modérée (préférer `foreach`)
> - ❌ Performance critique sur petits ensembles

---

**💡 En résumé** : `ForEach-Object` est l'outil de prédilection pour transformer et manipuler des données dans les pipelines PowerShell. Maîtrisez-le pour écrire des scripts élégants et efficaces !