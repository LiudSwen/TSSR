
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

## 🎯 Introduction au chaînage

Le chaînage de commandes est une fonctionnalité fondamentale de PowerShell qui permet de combiner plusieurs commandes pour créer des flux de traitement puissants et efficaces. Au lieu d'exécuter des commandes isolées, vous pouvez faire circuler des données d'une commande à l'autre, transformant progressivement vos résultats.

> [!info] Pourquoi le chaînage ?
> 
> - **Efficacité** : Traite les données en une seule opération fluide
> - **Lisibilité** : Express votre intention de manière naturelle et séquentielle
> - **Performance** : Évite de stocker des résultats intermédiaires inutiles
> - **Puissance** : Combine des opérations simples pour obtenir des résultats complexes

---

## 🔧 Syntaxe de chaînage

### Pipeline (|)

Le pipeline est l'opérateur de chaînage principal en PowerShell. Il transmet la sortie d'une commande comme entrée à la commande suivante.

```powershell
# Syntaxe de base
Commande1 | Commande2 | Commande3

# Exemple concret
Get-Process | Where-Object CPU -gt 100 | Sort-Object CPU -Descending
```

> [!example] Comment fonctionne le pipeline ?
> 
> ```powershell
> # Chaque étape transforme les données
> Get-ChildItem                    # Récupère tous les fichiers
>   | Where-Object Length -gt 1MB  # Filtre les fichiers > 1MB
>   | Select-Object Name, Length   # Sélectionne uniquement nom et taille
>   | Sort-Object Length           # Trie par taille
> ```

**Caractéristiques importantes du pipeline :**

|Aspect|Description|
|---|---|
|**Type de données**|Transmet des objets .NET complets (pas juste du texte)|
|**Traitement**|Élément par élément (streaming)|
|**Direction**|Toujours de gauche à droite|
|**Variables**|Accessible via `$_` ou `$PSItem` dans la commande suivante|

### Opérateurs de chaînage logique

PowerShell propose également des opérateurs pour enchaîner l'exécution conditionnelle de commandes :

```powershell
# ET logique (&&) - Exécute la commande suivante SI la précédente réussit
Commande1 && Commande2

# OU logique (||) - Exécute la commande suivante SI la précédente échoue
Commande1 || Commande2

# Point-virgule (;) - Exécute toujours la commande suivante
Commande1 ; Commande2
```

> [!warning] Disponibilité Les opérateurs `&&` et `||` sont disponibles à partir de PowerShell 7.0+. Pour les versions antérieures, utilisez des blocs conditionnels.

**Exemples d'utilisation :**

```powershell
# Crée un dossier ET y navigue (seulement si la création réussit)
New-Item -Path "C:\Temp\Test" -ItemType Directory && Set-Location "C:\Temp\Test"

# Tente de lire un fichier OU affiche un message d'erreur
Get-Content "config.txt" || Write-Host "Fichier introuvable, utilisation des valeurs par défaut"

# Exécute plusieurs commandes séquentiellement (indépendamment du résultat)
Get-Date ; Get-Location ; Get-Host
```

---

## 📝 Exemples simples de pipelines

Voici des exemples progressifs pour comprendre le pipeline :

### Exemple 1 : Filtrage simple

```powershell
# Liste les processus qui utilisent plus de 100 MB de mémoire
Get-Process | Where-Object WorkingSet -gt 100MB
```

### Exemple 2 : Filtrage et tri

```powershell
# Liste les 10 processus qui consomment le plus de CPU
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
```

### Exemple 3 : Transformation des données

```powershell
# Liste les fichiers avec leur taille en MB
Get-ChildItem | Select-Object Name, @{Name="TailleMB"; Expression={[math]::Round($_.Length / 1MB, 2)}}
```

### Exemple 4 : Agrégation

```powershell
# Calcule l'espace total utilisé par les fichiers .log
Get-ChildItem -Filter "*.log" | Measure-Object -Property Length -Sum
```

### Exemple 5 : Export des résultats

```powershell
# Exporte la liste des services vers un CSV
Get-Service | Where-Object Status -eq "Running" | Export-Csv -Path "services.csv" -NoTypeInformation
```

> [!tip] Utiliser Format-* à la fin uniquement Les cmdlets `Format-Table`, `Format-List` etc. doivent toujours être en **dernière position** du pipeline car elles produisent des objets de formatage, pas les objets originaux.
> 
> ```powershell
> # ✅ Correct
> Get-Process | Where-Object CPU -gt 50 | Format-Table
> 
> # ❌ Incorrect - le Select-Object ne recevra pas d'objets utilisables
> Get-Process | Format-Table | Select-Object Name
> ```

---

## ⚡ Ordre d'exécution

PowerShell traite les pipelines **de gauche à droite**, mais de manière **streamée** (élément par élément).

### Traitement séquentiel

```powershell
# Ordre d'exécution :
Get-ChildItem          # 1. Récupère les fichiers (un par un)
  | Where-Object       # 2. Filtre chaque fichier au fur et à mesure
  | Sort-Object        # 3. Collecte tous les résultats puis trie
  | Select-Object      # 4. Prend les premiers résultats triés
```

> [!info] Streaming vs Collecte
> 
> - **Cmdlets de streaming** : Traite chaque objet immédiatement (`Where-Object`, `ForEach-Object`, `Select-Object`)
> - **Cmdlets de collecte** : Attendent tous les objets avant de traiter (`Sort-Object`, `Group-Object`, `Measure-Object`)

### Impact sur les performances

```powershell
# ⚡ Rapide - filtre avant de trier (moins d'objets à trier)
Get-ChildItem | Where-Object Length -gt 1MB | Sort-Object Length

# 🐌 Lent - trie tout avant de filtrer
Get-ChildItem | Sort-Object Length | Where-Object Length -gt 1MB
```

> [!tip] Optimisation Placez toujours les filtres (`Where-Object`) **avant** les opérations de collecte (`Sort-Object`, `Group-Object`) pour améliorer les performances.

### Gestion des erreurs dans le pipeline

```powershell
# Par défaut, une erreur n'interrompt pas le pipeline
Get-ChildItem | ForEach-Object {
    if ($_.Extension -eq ".txt") {
        throw "Erreur sur $($_.Name)"  # Continue avec les autres fichiers
    }
}

# Pour interrompre le pipeline sur erreur
$ErrorActionPreference = "Stop"
Get-ChildItem | ForEach-Object {
    if ($_.Extension -eq ".txt") {
        throw "Erreur sur $($_.Name)"  # Arrête tout
    }
}
```

---

## 🔄 Combinaison de multiples cmdlets

PowerShell devient vraiment puissant lorsqu'on combine plusieurs cmdlets pour créer des opérations complexes.

### Exemple : Analyse de fichiers

```powershell
# Pipeline complexe en une ligne
Get-ChildItem -Recurse | 
    Where-Object {$_.Extension -in @('.ps1', '.psm1', '.psd1')} |
    Group-Object Extension |
    Select-Object Name, Count, @{Name="TailleTotal"; Expression={($_.Group | Measure-Object Length -Sum).Sum}} |
    Sort-Object TailleTotal -Descending |
    Format-Table -AutoSize
```

**Décomposition de l'exemple :**

1. `Get-ChildItem -Recurse` : Récupère tous les fichiers récursivement
2. `Where-Object` : Filtre uniquement les fichiers PowerShell
3. `Group-Object Extension` : Groupe par extension
4. `Select-Object` : Crée une propriété calculée pour la taille totale
5. `Sort-Object` : Trie par taille décroissante
6. `Format-Table` : Affiche le résultat sous forme de tableau

### Exemple : Gestion de services

```powershell
# Arrête tous les services non critiques qui consomment trop de mémoire
Get-Service |
    Where-Object Status -eq "Running" |
    ForEach-Object {
        $process = Get-Process -Name $_.Name -ErrorAction SilentlyContinue
        if ($process -and $process.WorkingSet -gt 500MB) {
            [PSCustomObject]@{
                Service = $_.Name
                Memory = [math]::Round($process.WorkingSet / 1MB, 2)
            }
        }
    } |
    Where-Object Service -notin @('Dhcp', 'DNS', 'W32Time') |
    Select-Object Service, Memory
```

### Exemple : Traitement de données CSV

```powershell
# Importe un CSV, filtre, calcule et exporte
Import-Csv "ventes.csv" |
    Where-Object {[datetime]$_.Date -ge (Get-Date).AddMonths(-3)} |
    Group-Object Region |
    ForEach-Object {
        [PSCustomObject]@{
            Region = $_.Name
            TotalVentes = ($_.Group | Measure-Object Montant -Sum).Sum
            Moyenne = ($_.Group | Measure-Object Montant -Average).Average
            NombreVentes = $_.Count
        }
    } |
    Sort-Object TotalVentes -Descending |
    Export-Csv "rapport_ventes.csv" -NoTypeInformation
```

> [!example] Utilisation de ForEach-Object pour transformations complexes `ForEach-Object` est essentiel pour créer des objets personnalisés ou effectuer des calculs complexes dans le pipeline :
> 
> ```powershell
> Get-Process | ForEach-Object {
>     [PSCustomObject]@{
>         Nom = $_.Name
>         PID = $_.Id
>         MemoireMB = [math]::Round($_.WorkingSet / 1MB, 2)
>         Priorite = $_.PriorityClass
>     }
> }
> ```

---

## ✨ Bonnes pratiques de lisibilité

### 1. Une cmdlet par ligne pour les pipelines complexes

```powershell
# ❌ Difficile à lire
Get-Process | Where-Object CPU -gt 50 | Sort-Object CPU -Descending | Select-Object -First 10 | Format-Table Name, CPU, WS

# ✅ Lisible et maintenable
Get-Process |
    Where-Object CPU -gt 50 |
    Sort-Object CPU -Descending |
    Select-Object -First 10 |
    Format-Table Name, CPU, WS
```

### 2. Indentation cohérente

```powershell
# Structure claire avec indentation
Get-ChildItem -Path "C:\Logs" -Recurse |
    Where-Object {
        $_.Extension -eq ".log" -and
        $_.LastWriteTime -lt (Get-Date).AddDays(-30)
    } |
    Group-Object Directory |
    ForEach-Object {
        [PSCustomObject]@{
            Dossier = $_.Name
            Nombre = $_.Count
            TailleTotal = ($_.Group | Measure-Object Length -Sum).Sum
        }
    }
```

### 3. Commentaires explicatifs

```powershell
# Nettoie les fichiers temporaires anciens
Get-ChildItem -Path $env:TEMP -Recurse |
    # Filtre les fichiers de plus de 7 jours
    Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-7)} |
    # Exclut les fichiers système ou cachés
    Where-Object {-not $_.Attributes.HasFlag([System.IO.FileAttributes]::System)} |
    # Supprime avec confirmation
    Remove-Item -Confirm
```

### 4. Variables intermédiaires pour clarté

```powershell
# ❌ Tout dans un pipeline peut être confus
Get-Process | Where-Object {$_.WorkingSet -gt 100MB -and $_.CPU -gt 60} | Sort-Object CPU -Descending

# ✅ Variables pour les seuils
$seuilMemoire = 100MB
$seuilCPU = 60

Get-Process |
    Where-Object {$_.WorkingSet -gt $seuilMemoire -and $_.CPU -gt $seuilCPU} |
    Sort-Object CPU -Descending
```

### 5. Utiliser des propriétés calculées nommées

```powershell
# ❌ Propriétés calculées non nommées
Get-ChildItem | Select-Object Name, @{N="Size";E={$_.Length / 1MB}}

# ✅ Noms complets et expressifs
Get-ChildItem | Select-Object Name, @{
    Name = "TailleEnMB"
    Expression = {[math]::Round($_.Length / 1MB, 2)}
}
```

> [!tip] Raccourcis acceptables Les raccourcis `N` (Name) et `E` (Expression) sont acceptables pour des scripts courts, mais privilégiez les noms complets dans du code partagé ou destiné à être maintenu.

---

## 📏 Utilisation du backtick pour lignes multiples

Le backtick (`` ` ``) est le caractère de continuation de ligne en PowerShell. Il permet de diviser une commande longue sur plusieurs lignes.

### Syntaxe de base

```powershell
# Le backtick doit être le DERNIER caractère de la ligne (pas d'espace après)
Get-Process `
    -Name "chrome" `
    -ErrorAction SilentlyContinue
```

> [!warning] Attention aux espaces Le backtick doit être le **dernier caractère** de la ligne. Un espace après le backtick causera une erreur.
> 
> ```powershell
> # ❌ Erreur - espace après le backtick
> Get-Process ` 
>     -Name "chrome"
> 
> # ✅ Correct
> Get-Process `
>     -Name "chrome"
> ```

### Alternatives au backtick

Le backtick peut être évité dans de nombreux cas grâce aux règles naturelles de continuation de PowerShell :

#### 1. Après un pipe (|)

```powershell
# Pas besoin de backtick après un pipe
Get-Process |
    Where-Object CPU -gt 50 |
    Sort-Object CPU -Descending
```

#### 2. À l'intérieur des parenthèses, crochets ou accolades

```powershell
# Pas besoin de backtick dans des structures ouvertes
$resultat = Get-ChildItem -Path (
    Join-Path -Path $env:USERPROFILE -ChildPath "Documents"
)

# Script blocks
Get-Process | Where-Object {
    $_.WorkingSet -gt 100MB -and
    $_.CPU -gt 50
}

# Tableaux
$extensions = @(
    ".ps1"
    ".psm1"
    ".psd1"
)
```

#### 3. Après certains opérateurs

```powershell
# Continuation naturelle après opérateurs
$message = "Ceci est une très longue chaîne " +
    "qui continue sur la ligne suivante " +
    "sans avoir besoin de backtick"
```

### Quand utiliser le backtick

Le backtick reste nécessaire dans certains cas :

```powershell
# Pour diviser une commande avec beaucoup de paramètres
New-Item `
    -Path "C:\Temp\Test" `
    -ItemType Directory `
    -Force `
    -ErrorAction SilentlyContinue `
    -Verbose

# Pour diviser une longue chaîne sans concaténation
$chemin = "C:\Program Files\Microsoft\Exchange Server\`
V15\Bin\ExSetup.exe"

# Dans des conditions complexes sans accolades
if ($valeur1 -gt 100 -and `
    $valeur2 -lt 50 -and `
    $valeur3 -eq "Active") {
    # Action
}
```

> [!tip] Préférez les alternatives Quand c'est possible, privilégiez :
> 
> - Le pipeline (`|`) plutôt que le backtick
> - Les accolades `{}` pour les conditions complexes
> - La méthode splatting pour les commandes avec beaucoup de paramètres
> 
> Le backtick est fragile (invisible, facilement cassé par un espace) et rend le code plus difficile à maintenir.

### Exemple : Splatting vs Backtick

```powershell
# ❌ Avec backtick - fragile
Copy-Item `
    -Path "C:\Source\fichier.txt" `
    -Destination "C:\Destination\" `
    -Force `
    -Recurse `
    -ErrorAction Stop

# ✅ Avec splatting - robuste et lisible
$parametres = @{
    Path = "C:\Source\fichier.txt"
    Destination = "C:\Destination\"
    Force = $true
    Recurse = $true
    ErrorAction = "Stop"
}
Copy-Item @parametres
```

---

## ⚠️ Pièges courants

### 1. Format-* au milieu du pipeline

```powershell
# ❌ Format-Table détruit les objets originaux
Get-Process | Format-Table | Where-Object CPU -gt 50  # Ne fonctionnera pas

# ✅ Format-* toujours en dernier
Get-Process | Where-Object CPU -gt 50 | Format-Table
```

### 2. Oublier que le pipeline traite des objets

```powershell
# ❌ Traite comme du texte
Get-Process | Select-String "chrome"  # Ne fonctionnera pas comme attendu

# ✅ Utilise les propriétés des objets
Get-Process | Where-Object Name -like "*chrome*"
```

### 3. Modification d'objets dans le pipeline

```powershell
# ⚠️ Attention : modifie les objets originaux
Get-ChildItem | ForEach-Object {
    $_.LastWriteTime = Get-Date  # Modifie le fichier réel !
}

# ✅ Crée de nouveaux objets
Get-ChildItem | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        DateModifiee = Get-Date
    }
}
```

### 4. Performance avec Where-Object vs .Where()

```powershell
# 🐌 Plus lent - cmdlet traditionnelle
$resultats = Get-Process | Where-Object CPU -gt 50

# ⚡ Plus rapide - méthode de collection
$resultats = (Get-Process).Where({$_.CPU -gt 50})
```

> [!info] Quand utiliser .Where() ? La méthode `.Where()` est plus rapide mais moins flexible. Utilisez-la pour des collections importantes et des filtres simples. Pour des opérations complexes ou des scripts lisibles, préférez `Where-Object`.

### 5. Erreurs silencieuses dans le pipeline

```powershell
# ⚠️ Les erreurs peuvent être masquées
Get-ChildItem | ForEach-Object {
    # Si une erreur survient, les autres fichiers continuent d'être traités
    Do-Something $_.FullName
}

# ✅ Gestion explicite des erreurs
Get-ChildItem | ForEach-Object {
    try {
        Do-Something $_.FullName
    } catch {
        Write-Warning "Erreur sur $($_.FullName): $_"
    }
}
```

### 6. Pipeline et variables automatiques

```powershell
# $_ représente l'objet en cours dans le pipeline
Get-Process | ForEach-Object {
    Write-Host $_.Name  # ✅ Correct
}

# ⚠️ $_ n'existe pas en dehors du pipeline
$processes = Get-Process
Write-Host $_.Name  # ❌ $_ est vide ici
```

---

## 💡 Astuces avancées

### Utiliser Tee-Object pour déboguer

```powershell
# Sauvegarde une copie des données à mi-pipeline pour analyse
Get-Process |
    Tee-Object -FilePath "debug.txt" |
    Where-Object CPU -gt 50 |
    Sort-Object CPU -Descending
```

### Pipeline avec groupes de commandes

```powershell
# Exécute plusieurs commandes pour chaque élément
Get-ChildItem *.txt | ForEach-Object {
    $contenu = Get-Content $_.FullName
    $lignes = $contenu.Count
    [PSCustomObject]@{
        Fichier = $_.Name
        NombreLignes = $lignes
        Taille = $_.Length
    }
}
```

### Utiliser -PipelineVariable pour référence

```powershell
# Garde une référence à un objet en amont du pipeline
Get-ChildItem -File -PipelineVariable fichier |
    Get-Content |
    Where-Object {$_ -match "ERROR"} |
    ForEach-Object {
        Write-Host "Erreur dans $($fichier.Name): $_"
    }
```

---

> [!tip] Points clés à retenir
> 
> - Le pipeline (`|`) est au cœur de PowerShell : il transmet des **objets**, pas du texte
> - Ordre d'exécution : **gauche → droite**, mais attention aux cmdlets de collecte
> - Optimisation : **filtrez tôt** avec `Where-Object` avant de trier ou grouper
> - Lisibilité : **une cmdlet par ligne** pour les pipelines complexes
> - Le backtick est fragile : **préférez les alternatives** (pipeline, accolades, splatting)
> - `Format-*` toujours **en dernier** : ces cmdlets détruisent les objets originaux