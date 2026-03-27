

## 📚 Table des matières

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

## 🎓 Introduction à Select-Object

`Select-Object` est l'un des cmdlets les plus puissants et polyvalents de PowerShell. Il permet de **filtrer, transformer et façonner** les données qui transitent dans le pipeline.

> [!info] Pourquoi utiliser Select-Object ?
> 
> - **Performance** : Limite les données en mémoire en ne gardant que ce qui est nécessaire
> - **Lisibilité** : Affiche uniquement les informations pertinentes
> - **Transformation** : Calcule de nouvelles propriétés à la volée
> - **Déduplication** : Élimine les doublons d'un jeu de données

> [!warning] À ne pas confondre `Select-Object` sélectionne des **propriétés** (colonnes), tandis que `Where-Object` filtre des **objets** (lignes).

---

## 📋 Sélection de propriétés

### Syntaxe de base

```powershell
# Sélectionner des propriétés spécifiques
Get-Process | Select-Object -Property Name, Id, CPU

# Forme abrégée (alias 'select')
Get-Process | select Name, Id, CPU

# Le paramètre -Property est optionnel
Get-Process | Select-Object Name, Id, CPU
```

### Pourquoi sélectionner des propriétés ?

Par défaut, PowerShell n'affiche qu'un sous-ensemble de propriétés. `Select-Object` vous permet de :

- Contrôler exactement quelles propriétés afficher
- Réduire la quantité de données en mémoire
- Préparer des données pour l'export (CSV, JSON, etc.)

### Exemples pratiques

```powershell
# Services : nom et statut uniquement
Get-Service | Select-Object Name, Status

# Fichiers : nom, taille et date de modification
Get-ChildItem | Select-Object Name, Length, LastWriteTime

# Utilisateurs AD : nom complet et email
Get-ADUser -Filter * | Select-Object Name, EmailAddress
```

> [!tip] Astuce : Découvrir toutes les propriétés Pour voir TOUTES les propriétés disponibles d'un objet :
> 
> ```powershell
> Get-Process | Select-Object -Property * | Get-Member
> # ou plus simple :
> Get-Process | Get-Member -MemberType Property
> ```

### Utilisation du wildcard (*)

```powershell
# Toutes les propriétés
Get-Process | Select-Object *

# Toutes les propriétés commençant par "P"
Get-Process | Select-Object P*

# Combinaison de wildcards et propriétés spécifiques
Get-Process | Select-Object Name, *Memory*, CPU
```

---

## 🧮 Propriétés calculées

Les **propriétés calculées** (Calculated Properties) permettent de créer de nouvelles colonnes basées sur des calculs, des transformations ou des combinaisons de propriétés existantes.

### Structure complète

```powershell
@{
    Name = 'NomDeLaNouvelleColonne'
    Expression = { $_.Propriete * 2 }  # Code à exécuter
}
```

### Alias disponibles

PowerShell accepte plusieurs syntaxes équivalentes :

|Élément|Alias acceptés|
|---|---|
|`Name`|`n`, `l`, `Label`|
|`Expression`|`e`, `expr`|

```powershell
# Ces trois syntaxes sont identiques :
@{Name='Total'; Expression={$_.Prix * $_.Quantite}}
@{n='Total'; e={$_.Prix * $_.Quantite}}
@{l='Total'; e={$_.Prix * $_.Quantite}}
```

> [!info] La variable automatique $_ Dans l'Expression, `$_` représente l'objet actuel dans le pipeline. C'est l'équivalent de "this" dans d'autres langages.

### Exemples fondamentaux

```powershell
# Convertir la taille en Mo
Get-ChildItem | Select-Object Name, 
    @{n='SizeMB'; e={[math]::Round($_.Length / 1MB, 2)}}

# Calculer l'âge d'un fichier en jours
Get-ChildItem | Select-Object Name,
    @{n='AgeDays'; e={(Get-Date) - $_.LastWriteTime | Select-Object -ExpandProperty Days}}

# Combiner plusieurs propriétés
Get-Process | Select-Object 
    @{n='ProcessInfo'; e={"$($_.Name) (PID: $($_.Id))"}}
```

### Exemples avancés

```powershell
# Statut coloré avec emoji
Get-Service | Select-Object Name,
    @{n='StatusIcon'; e={
        if ($_.Status -eq 'Running') {'✅ Running'}
        else {'⛔ Stopped'}
    }}

# Calculs multiples dans une expression
Get-Process | Select-Object Name,
    @{n='MemoryInfo'; e={
        $mb = [math]::Round($_.WorkingSet / 1MB, 2)
        "$mb MB"
    }}

# Propriété conditionnelle complexe
Get-Process | Select-Object Name,
    @{n='Priority'; e={
        switch ($_.PriorityClass) {
            'High'     {'🔴 Haute'}
            'Normal'   {'🟢 Normale'}
            'Low'      {'🔵 Basse'}
            default    {'⚪ Inconnue'}
        }
    }}
```

### Plusieurs propriétés calculées

```powershell
Get-ChildItem | Select-Object Name,
    @{n='SizeMB'; e={[math]::Round($_.Length / 1MB, 2)}},
    @{n='SizeKB'; e={[math]::Round($_.Length / 1KB, 2)}},
    @{n='IsLarge'; e={$_.Length -gt 10MB}},
    @{n='Extension'; e={$_.Extension.ToUpper()}}
```

> [!warning] Pièges courants
> 
> - **Oublier les accolades** : `e={...}` et non `e=...`
> - **Oublier `$_`** : Dans l'expression, utilisez toujours `$_.Propriete`
> - **Virgules** : N'oubliez pas les virgules entre les propriétés
> - **Quotes** : Utilisez des quotes simples `'Name'` pour les noms de propriétés

### Performance avec les propriétés calculées

```powershell
# ❌ MAUVAIS : Appel répété de Get-Date
Get-ChildItem | Select-Object Name,
    @{n='Age'; e={(Get-Date) - $_.LastWriteTime}}

# ✅ BON : Stocker Get-Date une seule fois
$now = Get-Date
Get-ChildItem | Select-Object Name,
    @{n='Age'; e={$now - $_.LastWriteTime}}
```

---

## 🔢 Sélection des premiers/derniers éléments

`Select-Object` permet de limiter le nombre d'objets retournés avec `-First` et `-Last`.

### Paramètres disponibles

```powershell
# Les N premiers éléments
Select-Object -First 5

# Les N derniers éléments
Select-Object -Last 3

# Sauter les N premiers (combinable avec -First/-Last)
Select-Object -Skip 10 -First 5  # Éléments 11 à 15
```

### Exemples pratiques

```powershell
# Les 5 processus les plus gourmands en CPU
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, CPU

# Les 10 fichiers les plus récents
Get-ChildItem | Sort-Object LastWriteTime -Descending | Select-Object -First 10

# Les 3 derniers événements du journal
Get-EventLog -LogName System -Newest 100 | Select-Object -Last 3

# Pagination : éléments 21 à 30
Get-Process | Select-Object -Skip 20 -First 10
```

> [!tip] Astuce : Combinaison avec Sort-Object Pour obtenir les "Top N", combinez toujours avec `Sort-Object` :
> 
> ```powershell
> # Top 5 des plus gros fichiers
> Get-ChildItem | Sort-Object Length -Descending | Select-Object -First 5
> ```

### Différence avec -Newest/-Oldest

```powershell
# Select-Object : position dans le pipeline
Get-Process | Select-Object -First 5  # Les 5 premiers traités

# -Newest : pour certains cmdlets spécifiques (Get-EventLog, etc.)
Get-EventLog -LogName System -Newest 5  # Les 5 plus récents

# -First s'applique APRÈS le tri
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5
```

> [!warning] Attention à l'ordre `-First` et `-Last` s'appliquent APRÈS tous les filtres et tris précédents dans le pipeline.

---

## 🔄 Suppression de doublons

Le paramètre `-Unique` élimine les doublons basés sur les propriétés sélectionnées.

### Syntaxe

```powershell
# Supprimer les doublons sur toutes les propriétés sélectionnées
Select-Object -Property Name, Type -Unique

# Forme courte
Select-Object Name, Type -Unique
```

### Exemples pratiques

```powershell
# Liste unique des extensions de fichiers
Get-ChildItem -Recurse | Select-Object -ExpandProperty Extension -Unique

# Processus uniques par nom (ignore les doublons)
Get-Process | Select-Object Name -Unique

# Combinaisons uniques de propriétés
Get-Service | Select-Object Status, StartType -Unique
```

### Comment fonctionne -Unique ?

```powershell
# Données de départ
$data = @(
    [PSCustomObject]@{Name='Alice'; Age=30}
    [PSCustomObject]@{Name='Bob'; Age=25}
    [PSCustomObject]@{Name='Alice'; Age=30}  # Doublon exact
    [PSCustomObject]@{Name='Alice'; Age=35}  # Nom identique, âge différent
)

# Sans -Unique : 4 résultats
$data | Select-Object Name, Age

# Avec -Unique sur Name et Age : 3 résultats (supprime ligne 3)
$data | Select-Object Name, Age -Unique

# Unique sur Name uniquement : 2 résultats
$data | Select-Object Name -Unique
```

> [!info] Comparaison avec Get-Unique
> 
> - `Select-Object -Unique` : Fonctionne sur des données non triées
> - `Get-Unique` : Nécessite des données triées au préalable
> 
> ```powershell
> # Select-Object -Unique : pas besoin de tri
> 1,3,2,3,1,2 | Select-Object -Unique  # 1,3,2
> 
> # Get-Unique : nécessite un tri
> 1,3,2,3,1,2 | Sort-Object | Get-Unique  # 1,2,3
> ```

### Cas d'usage typiques

```powershell
# Liste des types de services uniques
Get-Service | Select-Object ServiceType -Unique

# Extensions de fichiers présentes dans un dossier
Get-ChildItem -Recurse | 
    Select-Object @{n='Ext'; e={$_.Extension.ToLower()}} -Unique |
    Sort-Object Ext

# Noms de processus uniques avec leur nombre d'instances
Get-Process | Group-Object Name | 
    Select-Object Name, Count |
    Sort-Object Count -Descending
```

> [!tip] Performance Pour de gros volumes de données, `-Unique` peut être lent. Considérez `Sort-Object | Get-Unique` ou `Group-Object` comme alternatives.

---

## 📤 Expansion de propriétés

`-ExpandProperty` permet d'extraire directement les **valeurs** d'une propriété plutôt que l'objet complet.

### Différence clé : avec vs sans expansion

```powershell
# SANS -ExpandProperty : retourne un objet avec la propriété
Get-Process | Select-Object -First 1 Name
# Résultat : @{Name='ApplicationFrameHost'}

# AVEC -ExpandProperty : retourne directement la valeur
Get-Process | Select-Object -First 1 -ExpandProperty Name
# Résultat : ApplicationFrameHost (juste le texte)
```

### Syntaxe

```powershell
Select-Object -ExpandProperty NomPropriete

# Peut être combiné avec d'autres propriétés (mais déconseillé)
Select-Object -ExpandProperty Name -Property Id  # Comportement inattendu !
```

> [!warning] Une seule propriété à la fois `-ExpandProperty` ne fonctionne qu'avec UNE SEULE propriété. Si vous avez besoin de plusieurs valeurs, n'utilisez pas `-ExpandProperty`.

### Cas d'usage essentiels

#### 1. Obtenir une liste simple de valeurs

```powershell
# Noms de tous les services (tableau de strings)
Get-Service | Select-Object -ExpandProperty Name

# Tous les chemins de fichiers
Get-ChildItem | Select-Object -ExpandProperty FullName

# Liste d'adresses IP
Get-NetIPAddress | Select-Object -ExpandProperty IPAddress
```

#### 2. Utilisation dans des variables

```powershell
# ❌ MAUVAIS : retourne des objets
$names = Get-Process | Select-Object Name
$names[0]  # Retourne : @{Name='chrome'}

# ✅ BON : retourne des valeurs
$names = Get-Process | Select-Object -ExpandProperty Name
$names[0]  # Retourne : chrome
```

#### 3. Accéder à des propriétés imbriquées

```powershell
# Les propriétés imbriquées sont des objets
Get-Process | Select-Object -First 1 StartInfo  
# Retourne un objet ProcessStartInfo complet

# Expansion pour accéder aux sous-propriétés
Get-Process | Select-Object -First 1 -ExpandProperty StartInfo |
    Select-Object FileName, Arguments
```

#### 4. Utilisation avec des collections

```powershell
# Un processus a une collection de modules
(Get-Process chrome)[0].Modules  # Collection d'objets Module

# Extraire juste les noms des modules
(Get-Process chrome)[0] | 
    Select-Object -ExpandProperty Modules |
    Select-Object -ExpandProperty ModuleName
```

### Exemples pratiques

```powershell
# Liste des utilisateurs pour un export simple
Get-ADUser -Filter * | Select-Object -ExpandProperty Name | Out-File users.txt

# Toutes les adresses MAC du système
Get-NetAdapter | Select-Object -ExpandProperty MacAddress

# Commandes disponibles d'un module
Get-Command -Module ActiveDirectory | 
    Select-Object -ExpandProperty Name |
    Sort-Object

# Copier uniquement les noms de fichiers
$files = Get-ChildItem -Filter *.log | Select-Object -ExpandProperty Name
$files | ForEach-Object { Copy-Item $_ -Destination C:\Backup\ }
```

> [!tip] Quand utiliser -ExpandProperty ? Utilisez `-ExpandProperty` quand vous avez besoin :
> 
> - D'un tableau simple de valeurs (pas d'objets)
> - De passer des valeurs à d'autres commandes qui attendent des strings/nombres
> - D'exporter vers du texte simple
> - D'itérer sur des valeurs pures dans une boucle

### Piège courant

```powershell
# ❌ ERREUR : Tente d'utiliser plusieurs propriétés
Get-Process | Select-Object -ExpandProperty Name, Id
# Error: Cannot convert value...

# ✅ SOLUTION 1 : N'expandez pas
Get-Process | Select-Object Name, Id

# ✅ SOLUTION 2 : Expandez une seule, sélectionnez les autres
Get-Process | Select-Object -ExpandProperty Name -Property Id
# Note : Comportement parfois inattendu, évitez cette syntaxe
```

---

## ❌ Exclusion de propriétés

`-ExcludeProperty` permet de sélectionner toutes les propriétés **sauf** celles spécifiées.

### Syntaxe

```powershell
# Sélectionner tout sauf certaines propriétés
Select-Object -Property * -ExcludeProperty Prop1, Prop2

# Forme courte
Select-Object * -ExcludeProperty Prop1, Prop2
```

### Exemples pratiques

```powershell
# Tous les détails d'un processus sauf les handles
Get-Process | Select-Object * -ExcludeProperty Handles, HandleCount

# Informations de fichier sans les dates
Get-ChildItem | Select-Object * -ExcludeProperty *Time*

# Service sans les propriétés de dépendances
Get-Service | Select-Object * -ExcludeProperty *Dependent*, *Required*
```

### Cas d'usage typiques

#### 1. Nettoyer l'affichage

```powershell
# Trop d'informations inutiles
Get-Process | Select-Object *
# Des dizaines de propriétés !

# Exclure le bruit
Get-Process | Select-Object * -ExcludeProperty __*, PS*, Company, Product
```

#### 2. Préparer des exports

```powershell
# Export CSV sans propriétés système
Get-ADUser -Filter * -Properties * |
    Select-Object * -ExcludeProperty PropertyNames, PropertyCount, Added*, Modified* |
    Export-Csv users.csv -NoTypeInformation
```

#### 3. Éviter les erreurs de conversion

```powershell
# Certaines propriétés ne s'exportent pas bien en JSON
Get-Service |
    Select-Object * -ExcludeProperty RequiredServices, DependentServices |
    ConvertTo-Json
```

### Utilisation avec des wildcards

```powershell
# Exclure toutes les propriétés de temps
Get-ChildItem | Select-Object * -ExcludeProperty *Time*

# Exclure tout ce qui commence par "PS"
Get-Process | Select-Object * -ExcludeProperty PS*

# Exclure plusieurs patterns
Get-ADUser -Filter * -Properties * |
    Select-Object * -ExcludeProperty *SID*, *GUID*, DistinguishedName
```

> [!info] Ordre d'exécution
> 
> 1. PowerShell sélectionne d'abord `-Property` (si spécifié)
> 2. Puis applique `-ExcludeProperty` sur le résultat
> 
> ```powershell
> # Sélectionne Name, Id, CPU puis retire CPU
> Select-Object Name, Id, CPU -ExcludeProperty CPU
> # Résultat : Name, Id uniquement
> ```

> [!warning] Limitation `-ExcludeProperty` ne fonctionne qu'avec `-Property *` (explicite ou implicite). Vous ne pouvez pas exclure d'une sélection spécifique :
> 
> ```powershell
> # ❌ Ne fonctionne pas comme attendu
> Select-Object Name, Id, CPU -ExcludeProperty CPU
> 
> # ✅ Correct
> Select-Object * -ExcludeProperty CPU
> ```

### Comparaison avec sélection positive

```powershell
# Approche 1 : Sélection positive (recommandé si peu de propriétés)
Get-Process | Select-Object Name, Id, CPU

# Approche 2 : Exclusion (recommandé si beaucoup de propriétés voulues)
Get-Process | Select-Object * -ExcludeProperty Handles, Threads, Modules
```

> [!tip] Quelle approche choisir ?
> 
> - **Sélection positive** : Si vous savez exactement ce que vous voulez (3-5 propriétés)
> - **Exclusion** : Si vous voulez presque tout sauf quelques propriétés
> - **Performance** : La sélection positive est légèrement plus rapide

---

## 💡 Exemples de transformation de données

Cette section présente des cas réels de transformation et d'analyse de données avec `Select-Object`.

### Exemple 1 : Analyse des processus

```powershell
# Top 10 des processus par mémoire avec formatage
Get-Process |
    Sort-Object WorkingSet -Descending |
    Select-Object -First 10 Name,
        @{n='Memory (MB)'; e={[math]::Round($_.WorkingSet / 1MB, 2)}},
        @{n='CPU (s)'; e={[math]::Round($_.CPU, 2)}},
        @{n='Threads'; e={$_.Threads.Count}}
```

### Exemple 2 : Rapport de fichiers avancé

```powershell
# Analyse détaillée des fichiers d'un dossier
Get-ChildItem -File -Recurse |
    Select-Object Name,
        @{n='Size (MB)'; e={[math]::Round($_.Length / 1MB, 2)}},
        @{n='Age (Days)'; e={((Get-Date) - $_.LastWriteTime).Days}},
        @{n='Extension'; e={$_.Extension.ToUpper().TrimStart('.')}},
        @{n='Type'; e={
            if ($_.Length -gt 100MB) {'Très gros'}
            elseif ($_.Length -gt 10MB) {'Gros'}
            elseif ($_.Length -gt 1MB) {'Moyen'}
            else {'Petit'}
        }},
        @{n='IsRecent'; e={$_.LastWriteTime -gt (Get-Date).AddDays(-7)}}
```

### Exemple 3 : Consolidation de services

```powershell
# Statistiques des services par statut
Get-Service |
    Group-Object Status |
    Select-Object 
        @{n='Status'; e={$_.Name}},
        @{n='Count'; e={$_.Count}},
        @{n='Percentage'; e={[math]::Round(($_.Count / (Get-Service).Count) * 100, 2)}},
        @{n='Services'; e={($_.Group | Select-Object -ExpandProperty Name) -join ', '}}
```

### Exemple 4 : Transformation pour export CSV

```powershell
# Préparer des données pour Excel
Get-Process |
    Select-Object 
        @{n='Nom du processus'; e={$_.Name}},
        @{n='ID'; e={$_.Id}},
        @{n='Mémoire (Mo)'; e={[math]::Round($_.WorkingSet / 1MB, 2)}},
        @{n='CPU (%)'; e={
            $totalCPU = (Get-Process | Measure-Object CPU -Sum).Sum
            if ($totalCPU -gt 0) {
                [math]::Round(($_.CPU / $totalCPU) * 100, 2)
            } else { 0 }
        }},
        @{n='Démarré le'; e={$_.StartTime.ToString('dd/MM/yyyy HH:mm')}} |
    Export-Csv -Path rapport.csv -Encoding UTF8 -NoTypeInformation
```

### Exemple 5 : Nettoyage et déduplication

```powershell
# Obtenir les extensions uniques avec statistiques
Get-ChildItem -Recurse -File |
    Group-Object Extension |
    Select-Object 
        @{n='Extension'; e={$_.Name.ToUpper()}},
        @{n='Nombre'; e={$_.Count}},
        @{n='Taille totale (MB)'; e={
            [math]::Round(($_.Group | Measure-Object Length -Sum).Sum / 1MB, 2)
        }},
        @{n='Taille moyenne (KB)'; e={
            [math]::Round((($_.Group | Measure-Object Length -Average).Average) / 1KB, 2)
        }} |
    Sort-Object 'Taille totale (MB)' -Descending
```

### Exemple 6 : Pipeline complexe avec multiples transformations

```powershell
# Analyse complète avec plusieurs étapes
Get-ChildItem -Path C:\Logs -Filter *.log -Recurse |
    Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays(-30)} |
    Select-Object 
        @{n='Fichier'; e={$_.Name}},
        @{n='Dossier'; e={$_.DirectoryName}},
        @{n='Taille'; e={
            $size = $_.Length
            if ($size -gt 1GB) {"$([math]::Round($size / 1GB, 2)) GB"}
            elseif ($size -gt 1MB) {"$([math]::Round($size / 1MB, 2)) MB"}
            else {"$([math]::Round($size / 1KB, 2)) KB"}
        }},
        @{n='Dernière modif'; e={$_.LastWriteTime.ToString('dd/MM/yyyy')}},
        @{n='Ancienneté'; e={
            $days = ((Get-Date) - $_.LastWriteTime).Days
            if ($days -eq 0) {"Aujourd'hui"}
            elseif ($days -eq 1) {"Hier"}
            else {"Il y a $days jours"}
        }} |
    Sort-Object 'Dernière modif' -Descending |
    Select-Object -First 20
```

### Exemple 7 : Agrégation avec calculs

```powershell
# Statistiques de répertoires
Get-ChildItem -Directory |
    ForEach-Object {
        $files = Get-ChildItem -Path $_.FullName -Recurse -File
        [PSCustomObject]@{
            Dossier = $_.Name
            NombreFichiers = $files.Count
            TailleTotale = ($files | Measure-Object Length -Sum).Sum
            Extensions = ($files | Select-Object -ExpandProperty Extension -Unique) -join ', '
        }
    } |
    Select-Object Dossier, NombreFichiers,
        @{n='Taille (MB)'; e={[math]::Round($_.TailleTotale / 1MB, 2)}},
        Extensions |
    Sort-Object 'Taille (MB)' -Descending
```

### Exemple 8 : Transformation pour API/JSON

```powershell
# Préparer des données pour une API
Get-Service |
    Where-Object {$_.Status -eq 'Running'} |
    Select-Object 
        @{n='id'; e={$_.ServiceName}},
        @{n='displayName'; e={$_.DisplayName}},
        @{n='status'; e={$_.Status.ToString().ToLower()}},
        @{n='startType'; e={$_.StartType.ToString().ToLower()}},
        @{n='canStop'; e={$_.CanStop}} |
    ConvertTo-Json -Depth 2 |
    Out-File services.json
```

> [!tip] Bonnes pratiques pour les transformations
> 
> 1. **Commentez votre code** : Les propriétés calculées complexes méritent des explications
> 2. **Testez par étapes** : Construisez votre pipeline progressivement
> 3. **Optimisez** : Stockez les valeurs calculées souvent réutilisées dans des variables
> 4. **Formatez** : Utilisez des sauts de ligne pour la lisibilité des longues sélections
> 5. **Validez** : Vérifiez les types de données résultants avec `Get-Member`

---

## 📊 Récapitulatif des paramètres

|Paramètre|Utilité|Exemple|
|---|---|---|
|`-Property`|Sélectionner des propriétés spécifiques|`Select-Object Name, Id`|
|`-First`|Sélectionner les N premiers éléments|`Select-Object -First 10`|
|`-Last`|Sélectionner les N derniers éléments|`Select-Object -Last 5`|
|`-Skip`|Ignorer les N premiers éléments|`Select-Object -Skip 20 -First 10`|
|`-Unique`|Supprimer les doublons|`Select-Object Name -Unique`|
|`-ExpandProperty`|Extraire les valeurs d'une propriété|`Select-Object -ExpandProperty Name`|
|`-ExcludeProperty`|Exclure des propriétés|`Select-Object * -ExcludeProperty Id`|

---

## 🎯 Points clés à retenir

> [!info] L'essentiel sur Select-Object
> 
> - `Select-Object` transforme et façonne les données dans le pipeline
> - Les **propriétés calculées** permettent de créer de nouvelles colonnes à la volée
> - `-ExpandProperty` extrait des **valeurs pures** plutôt que des objets
> - `-Unique` élimine les doublons basés sur les propriétés sélectionnées
> - `-First` et `-Last` limitent le nombre de résultats (après tri)
> - Toujours utiliser `$_` dans les expressions de propriétés calculées

> [!warning] Erreurs fréquentes à éviter
> 
> - ❌ Oublier `$_` dans les propriétés calculées
> - ❌ Confondre `Select-Object` (colonnes) avec `Where-Object` (lignes)
> - ❌ Utiliser `-ExpandProperty` sur plusieurs propriétés
> - ❌ Oublier de trier avant d'utiliser `-First` pour un "Top N"
> - ❌ Utiliser `-ExcludeProperty` sans `-Property *`

---

_Cours créé pour Obsidian - PowerShell Select-Object_