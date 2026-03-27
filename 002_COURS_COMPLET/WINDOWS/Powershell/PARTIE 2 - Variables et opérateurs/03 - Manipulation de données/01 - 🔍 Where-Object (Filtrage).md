

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

## 🎯 Introduction au filtrage

`Where-Object` est une cmdlet fondamentale de PowerShell qui permet de **filtrer des objets** dans le pipeline en fonction de conditions spécifiques. C'est l'équivalent d'un `WHERE` en SQL ou d'un `filter()` dans d'autres langages.

> [!info] Pourquoi utiliser Where-Object ?
> 
> - Réduire un ensemble de données à ce qui vous intéresse vraiment
> - Éviter de traiter des objets inutiles dans le pipeline
> - Créer des requêtes précises et ciblées
> - Améliorer la lisibilité de vos scripts

> [!tip] Quand l'utiliser ?
> 
> - Filtrer des fichiers, processus, services, utilisateurs, etc.
> - Sélectionner uniquement les objets qui remplissent certains critères
> - Isoler des éléments problématiques (ex: processus consommant trop de mémoire)

---

## 📝 Syntaxe de base

`Where-Object` possède plusieurs syntaxes, de la plus verbale à la plus compacte.

### Syntaxe complète

```powershell
Get-Process | Where-Object -Property Name -EQ -Value "notepad"
```

> [!info] Composants
> 
> - `-Property` : la propriété à évaluer
> - `-EQ` : l'opérateur de comparaison (Equal)
> - `-Value` : la valeur à comparer

### Alias et raccourcis

```powershell
# Alias courants de Where-Object
Get-Process | Where -Property Name -EQ -Value "notepad"
Get-Process | ? -Property Name -EQ -Value "notepad"  # ? est l'alias le plus court
```

> [!warning] Attention aux alias L'alias `?` est pratique en ligne de commande interactive, mais il est recommandé d'utiliser `Where-Object` dans les scripts pour la clarté et la maintenabilité.

### Opérateurs de comparaison disponibles

|Paramètre|Signification|Exemple|
|---|---|---|
|`-EQ`|Égal (Equal)|`Name -EQ "notepad"`|
|`-NE`|Différent (Not Equal)|`Status -NE "Running"`|
|`-GT`|Supérieur (Greater Than)|`CPU -GT 100`|
|`-GE`|Supérieur ou égal|`Memory -GE 1024`|
|`-LT`|Inférieur (Less Than)|`Priority -LT 5`|
|`-LE`|Inférieur ou égal|`Threads -LE 10`|
|`-Like`|Correspondance avec wildcards|`Name -Like "power*"`|
|`-NotLike`|Non correspondance|`Name -NotLike "system*"`|
|`-Match`|Expression régulière|`Name -Match "^[A-Z]"`|
|`-NotMatch`|Non correspondance regex|`Path -NotMatch "\\temp\\"`|
|`-Contains`|Contient (pour tableaux)|`$array -Contains "value"`|
|`-In`|Est dans (pour tableaux)|`$value -In $array`|

---

## 🔧 Utilisation avec bloc de script

La syntaxe avec bloc de script `{}` est la plus flexible et la plus utilisée. Elle permet d'écrire des expressions de filtrage complexes.

### Syntaxe du script block

```powershell
Get-Process | Where-Object { $_.CPU -gt 10 }
```

> [!info] Structure
> 
> - `Where-Object` suivi d'un espace
> - Bloc de script entre accolades `{ }`
> - Expression booléenne retournant `$true` ou `$false`
> - Les objets pour lesquels l'expression retourne `$true` sont conservés

### Exemples avec script block

```powershell
# Filtrer les processus avec plus de 100 MB de mémoire
Get-Process | Where-Object { $_.WorkingSet -gt 100MB }

# Filtrer les fichiers modifiés dans les 7 derniers jours
Get-ChildItem | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }

# Filtrer les services arrêtés
Get-Service | Where-Object { $_.Status -eq "Stopped" }

# Filtrer avec opérateurs de chaîne
Get-Process | Where-Object { $_.Name -like "power*" }
```

> [!tip] Avantages du script block
> 
> - Syntaxe plus naturelle et lisible
> - Permet d'utiliser tous les opérateurs PowerShell
> - Possibilité d'écrire des expressions complexes
> - Peut appeler des méthodes et fonctions

---

## 💡 Variable $_ et $PSItem

Dans le bloc de script de `Where-Object`, vous devez référencer l'objet en cours de traitement. PowerShell fournit deux variables automatiques pour cela.

### $_ - La variable classique

`$_` (prononcez "dollar underscore") représente l'**objet actuel** dans le pipeline.

```powershell
# $_ représente chaque processus individuellement
Get-Process | Where-Object { $_.CPU -gt 5 }

# $_ représente chaque fichier
Get-ChildItem | Where-Object { $_.Length -gt 1MB }

# Accès aux propriétés avec $_
Get-Service | Where-Object { $_.DisplayName -like "*Windows*" }
```

### $PSItem - L'alternative moderne

`$PSItem` est un alias plus explicite de `$_`, introduit pour améliorer la lisibilité.

```powershell
# Équivalent avec $PSItem
Get-Process | Where-Object { $PSItem.CPU -gt 5 }

# Plus lisible dans les scripts complexes
Get-ChildItem | Where-Object { 
    $PSItem.Extension -eq ".txt" -and 
    $PSItem.Length -lt 10KB 
}
```

> [!info] $_ vs $PSItem
> 
> - Les deux sont **strictement équivalents**
> - `$_` est plus court et plus courant
> - `$PSItem` est plus explicite et recommandé pour les scripts partagés
> - Choisissez selon votre préférence, mais soyez cohérent

### Accès aux propriétés et méthodes

```powershell
# Accès aux propriétés
Get-Process | Where-Object { $_.Name -eq "notepad" }

# Accès aux propriétés imbriquées
Get-Process | Where-Object { $_.StartInfo.FileName -like "*system32*" }

# Appel de méthodes
Get-ChildItem | Where-Object { $_.Name.ToUpper().StartsWith("A") }

# Propriétés calculées
Get-Process | Where-Object { ($_.WorkingSet / 1MB) -gt 100 }
```

---

## ⚡ Script block simplifié

PowerShell 3.0+ offre une syntaxe encore plus concise pour les filtrages simples.

### Syntaxe simplifiée

```powershell
# Syntaxe complète avec script block
Get-Process | Where-Object { $_.CPU -gt 10 }

# Syntaxe simplifiée (sans accolades ni $_)
Get-Process | Where-Object CPU -gt 10
```

> [!info] Caractéristiques
> 
> - Pas besoin d'accolades `{}`
> - Pas besoin de `$_` ou `$PSItem`
> - Nom de la propriété directement après `Where-Object`
> - Opérateur de comparaison
> - Valeur à comparer

### Exemples de syntaxe simplifiée

```powershell
# Filtrer par égalité
Get-Service | Where-Object Status -eq "Running"

# Filtrer avec -like
Get-Process | Where-Object Name -like "power*"

# Filtrer avec comparaison numérique
Get-ChildItem | Where-Object Length -gt 1MB

# Filtrer avec -match
Get-Process | Where-Object ProcessName -match "^s"
```

### Tableau comparatif

|Syntaxe script block|Syntaxe simplifiée|
|---|---|
|`Where-Object { $_.CPU -gt 10 }`|`Where-Object CPU -gt 10`|
|`Where-Object { $_.Status -eq "Running" }`|`Where-Object Status -eq "Running"`|
|`Where-Object { $_.Name -like "power*" }`|`Where-Object Name -like "power*"`|

> [!warning] Limitations de la syntaxe simplifiée
> 
> - Fonctionne uniquement pour les **comparaisons simples** (une seule condition)
> - Ne peut pas combiner plusieurs conditions avec `-and` / `-or`
> - Ne peut pas appeler de méthodes ou faire des calculs
> - Pour tout ce qui est complexe, utilisez le script block

---

## 🔗 Combinaison de conditions

Pour des filtrages plus sophistiqués, vous devez combiner plusieurs conditions avec les opérateurs logiques.

### Opérateurs logiques

|Opérateur|Signification|Exemple|
|---|---|---|
|`-and`|ET logique (toutes les conditions doivent être vraies)|`$_.CPU -gt 10 -and $_.Name -like "power*"`|
|`-or`|OU logique (au moins une condition vraie)|`$_.Status -eq "Running" -or $_.Status -eq "Paused"`|
|`-not` ou `!`|NON logique (inverse la condition)|`-not ($_.CPU -gt 100)` ou `!($_.CPU -gt 100)`|
|`-xor`|OU exclusif (une seule des deux vraie)|`$_.A -xor $_.B`|

### Exemples avec -and

```powershell
# Processus consommant beaucoup de CPU ET de mémoire
Get-Process | Where-Object { 
    $_.CPU -gt 10 -and $_.WorkingSet -gt 100MB 
}

# Fichiers .txt de plus de 1KB
Get-ChildItem | Where-Object { 
    $_.Extension -eq ".txt" -and $_.Length -gt 1KB 
}

# Services arrêtés ET en démarrage automatique
Get-Service | Where-Object { 
    $_.Status -eq "Stopped" -and $_.StartType -eq "Automatic" 
}
```

### Exemples avec -or

```powershell
# Processus notepad OU chrome
Get-Process | Where-Object { 
    $_.Name -eq "notepad" -or $_.Name -eq "chrome" 
}

# Fichiers .txt OU .log
Get-ChildItem | Where-Object { 
    $_.Extension -eq ".txt" -or $_.Extension -eq ".log" 
}

# Services en cours d'exécution OU en pause
Get-Service | Where-Object { 
    $_.Status -eq "Running" -or $_.Status -eq "Paused" 
}
```

### Exemples avec -not

```powershell
# Processus qui ne sont PAS "Idle"
Get-Process | Where-Object { -not ($_.Name -eq "Idle") }

# Fichiers qui ne sont PAS des .txt
Get-ChildItem | Where-Object { -not ($_.Extension -eq ".txt") }

# Équivalent avec l'opérateur !
Get-Process | Where-Object { !($_.Name -eq "Idle") }

# Utiliser -ne est souvent plus simple
Get-Process | Where-Object { $_.Name -ne "Idle" }
```

### Combinaisons complexes avec parenthèses

```powershell
# (A ET B) OU C
Get-Process | Where-Object { 
    ($_.CPU -gt 10 -and $_.WorkingSet -gt 100MB) -or 
    $_.Name -eq "critical"
}

# A ET (B OU C)
Get-Service | Where-Object { 
    $_.Status -eq "Stopped" -and 
    ($_.StartType -eq "Automatic" -or $_.StartType -eq "Manual")
}

# Conditions multiples avec parenthèses pour la lisibilité
Get-ChildItem | Where-Object {
    (
        $_.Extension -eq ".txt" -or 
        $_.Extension -eq ".log" -or 
        $_.Extension -eq ".csv"
    ) -and 
    $_.Length -gt 1KB -and 
    $_.LastWriteTime -gt (Get-Date).AddDays(-30)
}
```

> [!tip] Conseil pour la lisibilité
> 
> - Utilisez des **retours à la ligne** pour les conditions longues
> - Indentez correctement les sous-conditions
> - Utilisez des **parenthèses** pour clarifier l'ordre d'évaluation
> - Les parenthèses forcent l'évaluation en priorité

---

## 🚀 Performance : Where-Object vs .Where()

PowerShell offre deux approches pour le filtrage : `Where-Object` (cmdlet) et `.Where()` (méthode). Leurs performances diffèrent significativement.

### Where-Object (cmdlet pipeline)

`Where-Object` traite les objets **un par un** dans le pipeline, au fur et à mesure.

```powershell
# Traitement par streaming
Get-Process | Where-Object { $_.CPU -gt 10 }
```

> [!info] Caractéristiques
> 
> - **Streaming** : traite chaque objet immédiatement
> - Commence à retourner des résultats sans attendre la fin
> - Mémoire minimale : ne charge pas tout en mémoire
> - Idéal pour de gros volumes de données
> - Syntaxe plus lisible et PowerShell-idiomatique

### .Where() (méthode de collection)

La méthode `.Where()` **charge d'abord tous les objets en mémoire**, puis les filtre en une seule opération.

```powershell
# Traitement par batch
(Get-Process).Where({ $_.CPU -gt 10 })

# Notez les parenthèses autour de Get-Process
```

> [!info] Caractéristiques
> 
> - **Batch processing** : attend d'avoir tous les objets
> - Charge tout en mémoire avant de filtrer
> - Plus rapide sur des collections complètes (déjà en mémoire)
> - Syntaxe .NET plus directe
> - Consomme plus de mémoire

### Comparaison de performance

```powershell
# Test avec 1000 processus fictifs
Measure-Command {
    1..10000 | ForEach-Object { [PSCustomObject]@{ID=$_; Value=$_*2} } | 
    Where-Object { $_.Value -gt 5000 }
}
# Résultat : ~200-300ms (streaming)

Measure-Command {
    (1..10000 | ForEach-Object { [PSCustomObject]@{ID=$_; Value=$_*2} }).
    Where({ $_.Value -gt 5000 })
}
# Résultat : ~150-250ms (batch, légèrement plus rapide)
```

### Tableau comparatif

|Critère|Where-Object|.Where()|
|---|---|---|
|**Performance**|Bon pour streaming|Excellent pour collections complètes|
|**Mémoire**|Faible (streaming)|Élevée (tout en mémoire)|
|**Lisibilité**|⭐⭐⭐⭐⭐ Idiomatique PowerShell|⭐⭐⭐ Syntaxe .NET|
|**Gros volumes**|✅ Recommandé|⚠️ Risque mémoire|
|**Petits volumes**|✅ Très bien|✅ Légèrement plus rapide|
|**Pipeline**|✅ Natif|⚠️ Nécessite parenthèses|

### Syntaxe avancée de .Where()

La méthode `.Where()` offre des modes supplémentaires :

```powershell
# Mode par défaut (All) : tous les éléments qui correspondent
(Get-Process).Where({ $_.CPU -gt 10 })

# Mode First : s'arrête au premier élément trouvé
(Get-Process).Where({ $_.CPU -gt 10 }, 'First')

# Mode First avec limite : les N premiers
(Get-Process).Where({ $_.CPU -gt 10 }, 'First', 3)

# Mode Last : les derniers éléments
(Get-Process).Where({ $_.CPU -gt 10 }, 'Last', 5)

# Mode SkipUntil : ignore jusqu'à trouver la condition
(1..10).Where({ $_ -gt 5 }, 'SkipUntil')  # Retourne 6,7,8,9,10

# Mode Until : retourne jusqu'à trouver la condition
(1..10).Where({ $_ -gt 5 }, 'Until')  # Retourne 1,2,3,4,5

# Mode Split : divise en deux groupes [match, non-match]
(1..10).Where({ $_ -gt 5 }, 'Split')  # Retourne deux tableaux
```

> [!tip] Quand utiliser .Where() ?
> 
> - Collections **déjà en mémoire** (tableaux, résultats stockés)
> - Besoin des modes spéciaux (`First`, `Last`, `Split`)
> - Performance critique sur petits/moyens volumes
> - Scripts .NET-style où c'est plus naturel

> [!warning] Quand éviter .Where() ?
> 
> - Très gros volumes de données (risque mémoire)
> - Flux continu ou streaming
> - Scripts destinés à des débutants PowerShell
> - Quand Where-Object est déjà assez rapide

---

## 📊 Filtrage sur propriétés multiples

Souvent, vous devez filtrer sur plusieurs propriétés simultanément ou comparer des propriétés entre elles.

### Filtrage avec plusieurs propriétés indépendantes

```powershell
# Processus avec conditions sur trois propriétés
Get-Process | Where-Object {
    $_.CPU -gt 10 -and
    $_.WorkingSet -gt 50MB -and
    $_.Threads.Count -gt 20
}

# Services avec plusieurs critères
Get-Service | Where-Object {
    $_.Status -eq "Running" -and
    $_.StartType -eq "Automatic" -and
    $_.DisplayName -like "*Windows*"
}

# Fichiers avec extension, taille et date
Get-ChildItem | Where-Object {
    $_.Extension -in @(".txt", ".log", ".csv") -and
    $_.Length -gt 1KB -and
    $_.Length -lt 10MB -and
    $_.LastWriteTime -gt (Get-Date).AddDays(-7)
}
```

### Comparaison entre propriétés d'un même objet

```powershell
# Fichiers où la date de création diffère de la date de modification
Get-ChildItem | Where-Object {
    $_.CreationTime -ne $_.LastWriteTime
}

# Utilisateurs AD où le prénom et le nom sont identiques
Get-ADUser -Filter * | Where-Object {
    $_.GivenName -eq $_.Surname
}

# Processus utilisant plus de handles que de threads
Get-Process | Where-Object {
    $_.Handles -gt $_.Threads.Count
}
```

### Filtrage avec propriétés calculées

```powershell
# Fichiers dont la taille en MB dépasse leur âge en jours
Get-ChildItem | Where-Object {
    ($_.Length / 1MB) -gt ((Get-Date) - $_.CreationTime).Days
}

# Processus avec ratio CPU/Threads élevé
Get-Process | Where-Object {
    $_.Threads.Count -gt 0 -and
    ($_.CPU / $_.Threads.Count) -gt 5
}

# Services dont le nom est plus court que le nom d'affichage
Get-Service | Where-Object {
    $_.Name.Length -lt $_.DisplayName.Length
}
```

### Filtrage avec collections imbriquées

```powershell
# Processus ayant des threads avec ID pair
Get-Process | Where-Object {
    $_.Threads | Where-Object { $_.Id % 2 -eq 0 }
}

# Fichiers ayant des attributs spécifiques
Get-ChildItem | Where-Object {
    $_.Attributes -band [System.IO.FileAttributes]::Hidden
}

# Utilisateurs membres de groupes spécifiques
Get-ADUser -Filter * | Where-Object {
    (Get-ADPrincipalGroupMembership $_).Name -contains "Administrators"
}
```

### Utilisation de -in et -contains

```powershell
# Vérifier si une propriété est dans une liste
$allowedNames = @("notepad", "chrome", "firefox")
Get-Process | Where-Object { $_.Name -in $allowedNames }

# Vérifier si une liste contient une propriété
$criticalServices = @("wuauserv", "BITS", "WinDefend")
Get-Service | Where-Object { $criticalServices -contains $_.Name }

# Différence entre -in et -contains
# -in : $valeur -in $tableau (la valeur EST DANS le tableau)
# -contains : $tableau -contains $valeur (le tableau CONTIENT la valeur)

# Extensions autorisées
$validExtensions = @(".txt", ".log", ".csv", ".xml")
Get-ChildItem | Where-Object { $_.Extension -in $validExtensions }
```

> [!info] -in vs -contains
> 
> - `-in` : vérifie si la **valeur de gauche** est dans le **tableau de droite**
> - `-contains` : vérifie si le **tableau de gauche** contient la **valeur de droite**
> - Résultat identique, mais syntaxe inversée
> - `-in` est souvent plus naturel : `$_.Name -in $liste`

---

## 💼 Exemples pratiques

Voici des scénarios réels d'utilisation de `Where-Object` dans l'administration système.

### Gestion des processus

```powershell
# Trouver les processus consommant beaucoup de ressources
Get-Process | Where-Object {
    $_.CPU -gt 100 -or $_.WorkingSet -gt 500MB
} | Select-Object Name, CPU, @{N="MemMB";E={[math]::Round($_.WS/1MB,2)}}

# Processus zombies (sans fenêtre et CPU = 0)
Get-Process | Where-Object {
    $_.MainWindowTitle -eq "" -and $_.CPU -eq 0
}

# Processus lancés par un utilisateur spécifique
Get-Process -IncludeUserName | Where-Object {
    $_.UserName -like "*DOMAIN\utilisateur*"
}

# Processus en cours depuis plus de 24 heures
Get-Process | Where-Object {
    (Get-Date) - $_.StartTime -gt (New-TimeSpan -Hours 24)
}
```

### Gestion des fichiers

```powershell
# Trouver les gros fichiers récents
Get-ChildItem -Recurse | Where-Object {
    !$_.PSIsContainer -and
    $_.Length -gt 100MB -and
    $_.LastWriteTime -gt (Get-Date).AddDays(-30)
} | Sort-Object Length -Descending

# Fichiers dupliqués potentiels (même nom, emplacements différents)
$files = Get-ChildItem -Recurse -File
$files | Where-Object {
    ($files | Where-Object Name -eq $_.Name).Count -gt 1
} | Group-Object Name

# Fichiers temporaires obsolètes
Get-ChildItem $env:TEMP -Recurse | Where-Object {
    !$_.PSIsContainer -and
    $_.LastAccessTime -lt (Get-Date).AddDays(-7)
}

# Fichiers avec noms suspects (caractères spéciaux)
Get-ChildItem | Where-Object {
    $_.Name -match "[^\w\s\.-]"
}
```

### Gestion des services

```powershell
# Services critiques arrêtés
$criticalServices = @("wuauserv", "BITS", "WinDefend", "EventLog")
Get-Service | Where-Object {
    $_.Name -in $criticalServices -and $_.Status -ne "Running"
}

# Services en démarrage automatique mais arrêtés (problème potentiel)
Get-Service | Where-Object {
    $_.StartType -eq "Automatic" -and $_.Status -eq "Stopped"
}

# Services avec dépendances non satisfaites
Get-Service | Where-Object {
    $_.Status -eq "Stopped" -and
    $_.DependentServices.Count -gt 0
}
```

### Gestion des événements Windows

```powershell
# Erreurs critiques dans les dernières 24h
Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddDays(-1) |
Where-Object {
    $_.EventID -in @(41, 1001, 6008)  # Erreurs critiques système
}

# Tentatives de connexion échouées
Get-EventLog -LogName Security | Where-Object {
    $_.EventID -eq 4625 -and
    $_.TimeGenerated -gt (Get-Date).AddHours(-1)
}

# Événements avec source spécifique
Get-EventLog -LogName Application | Where-Object {
    $_.Source -like "*SQL*" -and $_.EntryType -eq "Warning"
}
```

### Gestion réseau

```powershell
# Connexions réseau actives sur des ports spécifiques
Get-NetTCPConnection | Where-Object {
    $_.State -eq "Established" -and
    $_.RemotePort -in @(80, 443, 3389)
}

# Connexions suspectes (ports inhabituels)
Get-NetTCPConnection | Where-Object {
    $_.State -eq "Established" -and
    $_.RemotePort -gt 49152  # Ports éphémères
}

# Adaptateurs réseau actifs avec IP
Get-NetAdapter | Where-Object {
    $_.Status -eq "Up" -and
    (Get-NetIPAddress -InterfaceIndex $_.ifIndex).IPv4Address
}
```

### Administration Active Directory

```powershell
# Comptes utilisateurs inactifs depuis 90 jours
Get-ADUser -Filter * -Properties LastLogonDate | Where-Object {
    $_.Enabled -eq $true -and
    ($_.LastLogonDate -lt (Get-Date).AddDays(-90) -or $_.LastLogonDate -eq $null)
}

# Comptes avec mot de passe expiré
Get-ADUser -Filter * -Properties PasswordExpired, PasswordLastSet | Where-Object {
    $_.PasswordExpired -eq $true -and $_.Enabled -eq $true
}

# Ordinateurs obsolètes (pas de connexion depuis 6 mois)
Get-ADComputer -Filter * -Properties LastLogonDate | Where-Object {
    $_.LastLogonDate -lt (Get-Date).AddMonths(-6)
}
```

### Surveillance système

```powershell
# Disques avec moins de 10% d'espace libre
Get-PSDrive -PSProvider FileSystem | Where-Object {
    $_.Free -and (($_.Free / $_.Used) * 100) -lt 10
}

# Processus avec fuites mémoire potentielles (mémoire croissante)
$baseline = Get-Process
Start-Sleep -Seconds 60
Get-Process | Where-Object {
    $original = $baseline | Where-Object Id -eq $_.Id
    $original -and ($_.WorkingSet - $original.WorkingSet) -gt 50MB
}
```

---

## ⚠️ Pièges courants et bonnes pratiques

### Piège 1 : Oublier les accolades dans le script block

```powershell
# ❌ INCORRECT - Erreur de syntaxe
Get-Process | Where-Object $_.CPU -gt 10

# ✅ CORRECT - Accolades nécessaires avec $_
Get-Process | Where-Object { $_.CPU -gt 10 }

# ✅ CORRECT - Syntaxe simplifiée (sans accolades)
Get-Process | Where-Object CPU -gt 10
```

### Piège 2 : Utiliser -eq au lieu de -like pour les wildcards

```powershell
# ❌ INCORRECT - -eq ne supporte pas les wildcards
Get-Process | Where-Object { $_.Name -eq "power*" }  # Ne trouve rien !

# ✅ CORRECT - Utiliser -like pour les wildcards
Get-Process | Where-Object { $_.Name -like "power*" }

# ✅ CORRECT - Utiliser -match pour les regex
Get-Process | Where-Object { $_.Name -match "^power" }
```

### Piège 3 : Confusion entre -contains et -like

```powershell
# ❌ INCORRECT - -contains est pour les tableaux, pas les chaînes
Get-Process | Where-Object { $_.Name -contains "note" }  # Ne fonctionne pas !

# ✅ CORRECT - Utiliser -like pour chercher dans une chaîne
Get-Process | Where-Object { $_.Name -like "*note*" }

# ✅ CORRECT - -contains pour vérifier si un élément est dans un tableau
$processes = @("notepad", "chrome", "firefox")
Get-Process | Where-Object { $processes -contains $_.Name }
```

### Piège 4 : Propriétés nulles non gérées

```powershell
# ❌ RISQUE - Erreur si CPU est null
Get-Process | Where-Object { $_.CPU -gt 10 }

# ✅ MEILLEUR - Vérifier null d'abord
Get-Process | Where-Object { $_.CPU -and $_.CPU -gt 10 }

# ✅ ALTERNATIVE - Utiliser -ne $null
Get-Process | Where-Object { $_.CPU -ne $null -and $_.CPU -gt 10 }
```

### Piège 5 : Mauvaise utilisation des parenthèses avec .Where()

```powershell
# ❌ INCORRECT - Oubli des parenthèses autour de Get-Process
Get-Process.Where({ $_.CPU -gt 10 })  # Erreur de syntaxe !

# ✅ CORRECT - Parenthèses obligatoires
(Get-Process).Where({ $_.CPU -gt 10 })

# ✅ ALTERNATIVE - Where-Object standard (plus lisible)
Get-Process | Where-Object { $_.CPU -gt 10 }
```

### Piège 6 : Filtrage inefficace (double filtrage)

```powershell
# ❌ INEFFICACE - Deux passages inutiles
Get-Process | Where-Object { $_.Name -like "power*" } | 
Where-Object { $_.CPU -gt 10 }

# ✅ MEILLEUR - Combiner en un seul Where-Object
Get-Process | Where-Object { 
    $_.Name -like "power*" -and $_.CPU -gt 10 
}

# 💡 Exception : parfois utile pour la clarté ou si les conditions sont complexes
Get-Process | 
    Where-Object { $_.WorkingSet -gt 100MB } |  # Premier filtre large
    Where-Object {  # Filtre plus coûteux uniquement sur le sous-ensemble
        (Get-Process -Id $_.Id).Threads.Count -gt 50
    }
```

### Piège 7 : Comparaison de chaînes sensible à la casse

```powershell
# ⚠️ ATTENTION - Par défaut, les opérateurs sont insensibles à la casse
Get-Process | Where-Object { $_.Name -eq "NOTEPAD" }  # Trouve "notepad"
Get-Process | Where-Object { $_.Name -eq "notepad" }  # Trouve "NOTEPAD"

# ✅ Pour forcer la casse (case-sensitive)
Get-Process | Where-Object { $_.Name -ceq "notepad" }  # Ne trouve que "notepad"

# 💡 Opérateurs sensibles à la casse : -ceq, -cne, -clike, -cmatch
Get-ChildItem | Where-Object { $_.Name -cmatch "^[A-Z]" }  # Commence par majuscule
```

### Piège 8 : Oubli de l'opérateur -and/-or

```powershell
# ❌ INCORRECT - Syntaxe invalide
Get-Process | Where-Object { $_.CPU -gt 10 $_.Name -like "power*" }

# ✅ CORRECT - Utiliser -and explicitement
Get-Process | Where-Object { $_.CPU -gt 10 -and $_.Name -like "power*" }

# ✅ CORRECT - Séparer avec un retour à la ligne n'ajoute pas l'opérateur !
Get-Process | Where-Object { 
    $_.CPU -gt 10 -and  # -and toujours nécessaire
    $_.Name -like "power*" 
}
```

### Piège 9 : Confusion entre -eq et -match

```powershell
# ❌ INCORRECT - -eq ne supporte pas les regex
Get-Process | Where-Object { $_.Name -eq "^power.*" }  # Cherche littéralement "^power.*"

# ✅ CORRECT - Utiliser -match pour les expressions régulières
Get-Process | Where-Object { $_.Name -match "^power.*" }

# 💡 -eq : égalité stricte
# 💡 -like : wildcards (* et ?)
# 💡 -match : expressions régulières complètes
```

### Piège 10 : Filtrage sur des valeurs booléennes

```powershell
# ❌ INCORRECT - Comparaison inutile
Get-Service | Where-Object { $_.CanStop -eq $true }

# ✅ MEILLEUR - Utiliser directement la propriété booléenne
Get-Service | Where-Object { $_.CanStop }

# ✅ Pour les valeurs false
Get-Service | Where-Object { -not $_.CanStop }
# ou
Get-Service | Where-Object { !$_.CanStop }
```

---

## 🎯 Bonnes pratiques

### 1. Filtrez le plus tôt possible dans le pipeline

```powershell
# ❌ INEFFICACE - Récupère tout puis filtre
Get-ChildItem -Recurse | Where-Object { $_.Extension -eq ".txt" }

# ✅ MEILLEUR - Utiliser les paramètres natifs quand disponibles
Get-ChildItem -Recurse -Filter "*.txt"

# 💡 Principe : utilisez les filtres natifs avant Where-Object
Get-EventLog -LogName System -EntryType Error |  # Filtre natif
    Where-Object { $_.TimeGenerated -gt (Get-Date).AddHours(-1) }  # Filtre supplémentaire
```

### 2. Utilisez la syntaxe la plus appropriée au contexte

```powershell
# 💡 Script de production : syntaxe explicite
Get-Process | Where-Object { $_.CPU -gt 10 }

# 💡 Ligne de commande interactive : syntaxe courte acceptable
Get-Process | ? CPU -gt 10

# 💡 Scripts partagés : préférez Where-Object à l'alias ?
# ✅ Bon
Get-Service | Where-Object { $_.Status -eq "Running" }

# ⚠️ Moins bon pour scripts partagés
Get-Service | ? { $_.Status -eq "Running" }
```

### 3. Commentez les filtres complexes

```powershell
# ✅ BON - Commentaires pour la clarté
Get-Process | Where-Object {
    # Processus gourmands en ressources
    ($_.CPU -gt 50 -or $_.WorkingSet -gt 500MB) -and
    # Excluant les processus système critiques
    $_.Name -notin @("System", "Idle", "svchost") -and
    # En cours depuis plus d'une heure
    ((Get-Date) - $_.StartTime).TotalHours -gt 1
}
```

### 4. Gérez les propriétés nulles ou manquantes

```powershell
# ✅ Vérification défensive
Get-Process | Where-Object { 
    $_.StartTime -and 
    ((Get-Date) - $_.StartTime).TotalHours -gt 24 
}

# ✅ Utiliser -ne $null
Get-Process | Where-Object { 
    $_.CPU -ne $null -and $_.CPU -gt 10 
}

# ✅ Try-Catch pour propriétés complexes
Get-Process | Where-Object {
    try {
        $_.MainModule.FileName -like "*system32*"
    } catch {
        $false
    }
}
```

### 5. Optimisez pour la performance

```powershell
# ❌ LENT - Condition coûteuse évaluée pour chaque objet
Get-Process | Where-Object { 
    $_.CPU -gt (Get-Process | Measure-Object CPU -Average).Average 
}

# ✅ RAPIDE - Calculer une fois avant le filtrage
$avgCPU = (Get-Process | Measure-Object CPU -Average).Average
Get-Process | Where-Object { $_.CPU -gt $avgCPU }

# 💡 Sortez les calculs coûteux du bloc de script quand possible
```

### 6. Utilisez des variables pour les listes de valeurs

```powershell
# ✅ BON - Variable réutilisable et maintenable
$criticalServices = @("wuauserv", "BITS", "WinDefend", "EventLog")
Get-Service | Where-Object { $_.Name -in $criticalServices }

# 💡 Avantages :
# - Facile à maintenir
# - Réutilisable dans plusieurs filtres
# - Peut être chargé depuis un fichier de configuration
```

### 7. Formatez correctement les conditions longues

```powershell
# ✅ EXCELLENTE mise en forme
Get-ChildItem -Recurse | Where-Object {
    (
        # Extensions valides
        $_.Extension -in @(".txt", ".log", ".csv")
    ) -and (
        # Taille raisonnable
        $_.Length -gt 1KB -and $_.Length -lt 10MB
    ) -and (
        # Modifié récemment
        $_.LastWriteTime -gt (Get-Date).AddDays(-30)
    ) -and (
        # Pas dans des dossiers système
        $_.FullName -notmatch "Windows|Program Files"
    )
}
```

### 8. Testez vos filtres progressivement

```powershell
# 💡 Approche progressive pour déboguer

# Étape 1 : Voir toutes les données
Get-Process | Select-Object Name, CPU, WorkingSet

# Étape 2 : Ajouter un premier filtre
Get-Process | Where-Object { $_.CPU -gt 10 }

# Étape 3 : Ajouter conditions supplémentaires une par une
Get-Process | Where-Object { 
    $_.CPU -gt 10 -and $_.WorkingSet -gt 100MB 
}

# Étape 4 : Affiner jusqu'au résultat voulu
Get-Process | Where-Object { 
    $_.CPU -gt 10 -and 
    $_.WorkingSet -gt 100MB -and
    $_.Name -notlike "svchost*"
}
```

### 9. Documentez les seuils et valeurs magiques

```powershell
# ❌ Valeurs magiques non documentées
Get-Process | Where-Object { $_.WorkingSet -gt 524288000 }

# ✅ Constantes nommées et documentées
$memoryThresholdMB = 500  # 500 MB threshold for high memory processes
Get-Process | Where-Object { $_.WorkingSet -gt ($memoryThresholdMB * 1MB) }

# ✅ Avec commentaire contextuel
Get-Process | Where-Object { 
    # Alerte si utilisation mémoire > 500MB (seuil défini par l'équipe infra)
    $_.WorkingSet -gt 500MB 
}
```

### 10. Privilégiez la lisibilité à la concision excessive

```powershell
# ⚠️ CONCIS mais difficile à relire
Get-Process|?{$_.CPU-gt10-and$_.WS-gt100MB-and$_.Name-ne"Idle"}

# ✅ LISIBLE et maintenable
Get-Process | Where-Object {
    $_.CPU -gt 10 -and
    $_.WorkingSet -gt 100MB -and
    $_.Name -ne "Idle"
}

# 💡 Le code est lu beaucoup plus souvent qu'il n'est écrit
# 💡 Préférez la clarté pour vous et vos collègues
```

---

## 📚 Récapitulatif

### Points clés à retenir

> [!tip] Syntaxes disponibles
> 
> - **Script block** : `Where-Object { $_.Property -gt 10 }` (le plus flexible)
> - **Simplifiée** : `Where-Object Property -gt 10` (pour conditions simples)
> - **Méthode** : `(Get-Process).Where({ $_.CPU -gt 10 })` (performance sur collections)

> [!tip] Variables automatiques
> 
> - `$_` : objet actuel (classique, court)
> - `$PSItem` : objet actuel (moderne, explicite)
> - Les deux sont strictement équivalents

> [!tip] Opérateurs essentiels
> 
> - **Comparaison** : `-eq`, `-ne`, `-gt`, `-lt`, `-ge`, `-le`
> - **Patterns** : `-like`, `-notlike`, `-match`, `-notmatch`
> - **Collections** : `-in`, `-notin`, `-contains`, `-notcontains`
> - **Logiques** : `-and`, `-or`, `-not`, `-xor`

> [!tip] Performance
> 
> - `Where-Object` : streaming, faible mémoire, idéal pour gros volumes
> - `.Where()` : batch, plus rapide sur collections complètes en mémoire
> - Filtrez le plus tôt possible dans le pipeline

> [!warning] Pièges à éviter
> 
> - Oublier les accolades avec `$_`
> - Utiliser `-eq` au lieu de `-like` pour les wildcards
> - Confusion entre `-contains` (tableaux) et `-like` (chaînes)
> - Ne pas gérer les propriétés nulles
> - Valeurs magiques non documentées

> [!success] Bonnes pratiques
> 
> - Utilisez les filtres natifs des cmdlets quand disponibles
> - Commentez les conditions complexes
> - Formatez pour la lisibilité
> - Testez progressivement
> - Privilégiez la clarté à la concision excessive

---

**Maîtriser `Where-Object` est essentiel pour tout administrateur PowerShell. C'est l'outil de filtrage par excellence qui vous permet d'extraire exactement les données dont vous avez besoin, quand vous en avez besoin.**