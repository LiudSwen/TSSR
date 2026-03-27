

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

## 🎯 Introduction au Pipeline

Le **pipeline** est l'un des concepts fondamentaux de PowerShell. Il permet de chaîner plusieurs commandes ensemble en faisant passer la sortie d'une commande comme entrée de la commande suivante.

> [!info] Définition Un pipeline est une séquence de commandes connectées par le symbole pipe (`|`), où chaque commande traite les données et les transmet à la commande suivante dans la chaîne.

### Pourquoi utiliser le pipeline ?

- **Efficacité** : Évite de stocker des résultats intermédiaires dans des variables
- **Lisibilité** : Crée un flux logique de traitement des données
- **Performance** : Les objets circulent directement en mémoire sans conversion
- **Productivité** : Permet de combiner des commandes simples pour créer des opérations complexes

> [!example] Exemple simple
> 
> ```powershell
> # Sans pipeline : approche verbeuse
> $processes = Get-Process
> $sortedProcesses = Sort-Object -InputObject $processes -Property CPU -Descending
> $topProcesses = Select-Object -InputObject $sortedProcesses -First 5
> 
> # Avec pipeline : approche concise et élégante
> Get-Process | Sort-Object CPU -Descending | Select-Object -First 5
> ```

---

## 🔧 Le symbole Pipe ( | )

Le **pipe** (`|`) est l'opérateur qui connecte les commandes dans un pipeline PowerShell.

### Syntaxe de base

```powershell
Commande1 | Commande2 | Commande3 | CommandeN
```

### Positionnement et espacement

```powershell
# ✅ Recommandé : espaces autour du pipe pour la lisibilité
Get-Service | Where-Object Status -eq 'Running'

# ✅ Également valide : sans espaces
Get-Service|Where-Object Status -eq 'Running'

# ✅ Sur plusieurs lignes pour les pipelines complexes
Get-Process |
    Where-Object CPU -gt 100 |
    Sort-Object WorkingSet -Descending |
    Select-Object -First 10
```

> [!tip] Astuce de formatage Pour les pipelines longs, placez chaque commande sur une nouvelle ligne avec le pipe à la fin de la ligne précédente ou au début de la ligne suivante. Cela améliore considérablement la lisibilité.

### Le pipe transfère des objets, pas du texte

```powershell
# PowerShell transfère des objets .NET complets
Get-Process | Get-Member  # Affiche toutes les propriétés et méthodes disponibles

# Chaque objet conserve ses propriétés et méthodes
Get-Process notepad | Stop-Process  # Stop-Process comprend l'objet Process reçu
```

---

## 🌊 Flux de données entre commandes

### Comment les données circulent

Lorsqu'une commande envoie des données dans un pipeline, PowerShell détermine automatiquement comment la commande suivante doit recevoir ces données.

```powershell
# Exemple de flux de données
Get-ChildItem C:\Temp |            # Génère des objets FileInfo et DirectoryInfo
    Where-Object Length -gt 1MB |   # Filtre les objets selon une condition
    Sort-Object LastWriteTime |     # Trie les objets restants
    Select-Object Name, Length      # Extrait des propriétés spécifiques
```

### Traitement élément par élément

PowerShell traite généralement les objets **un par un** dans le pipeline (streaming), pas en bloc.

```powershell
# Chaque processus est traité individuellement
Get-Process | ForEach-Object {
    Write-Host "Traitement de $($_.Name)..."
    $_  # Passe l'objet au suivant
}
```

> [!info] Mécanisme de liaison PowerShell utilise deux mécanismes principaux pour lier les paramètres :
> 
> - **ByValue** : L'objet entier est passé au paramètre qui accepte ce type d'objet
> - **ByPropertyName** : Les propriétés de l'objet sont mappées aux paramètres correspondants

### Exemple de liaison ByValue

```powershell
# Get-Process génère des objets [System.Diagnostics.Process]
# Stop-Process accepte des objets Process par le pipeline
Get-Process notepad | Stop-Process

# PowerShell fait automatiquement : Stop-Process -InputObject <ProcessObject>
```

### Exemple de liaison ByPropertyName

```powershell
# Création d'un objet personnalisé avec une propriété Name
[PSCustomObject]@{Name = "notepad"} | Get-Process

# PowerShell mappe automatiquement : Get-Process -Name "notepad"
```

> [!tip] Vérifier la compatibilité du pipeline Utilisez `Get-Help` avec le paramètre `-Full` pour voir quels paramètres acceptent l'entrée du pipeline :
> 
> ```powershell
> Get-Help Stop-Process -Parameter InputObject
> Get-Help Stop-Process -Parameter Name
> ```

---

## ⚖️ Pipeline orienté objet vs Pipeline textuel

PowerShell se distingue radicalement des shells Unix/Linux par son approche orientée objet du pipeline.

### Comparaison fondamentale

|Aspect|PowerShell (Objets)|Unix/Linux (Texte)|
|---|---|---|
|**Type de données**|Objets .NET structurés|Flux de texte brut|
|**Propriétés**|Accès direct aux propriétés|Parsing avec awk, sed, cut|
|**Méthodes**|Méthodes disponibles sur les objets|Commandes externes uniquement|
|**Typage**|Fortement typé|Non typé (tout est texte)|
|**Manipulation**|Filtrage et tri natifs|Pipes multiples pour parser|

### Exemple PowerShell (orienté objet)

```powershell
# Obtenir les 5 processus consommant le plus de mémoire
Get-Process | 
    Sort-Object WorkingSet -Descending | 
    Select-Object -First 5 Name, 
        @{Name='MemoryMB'; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}

# Résultat structuré avec des colonnes nommées
# Name          MemoryMB
# ----          --------
# chrome        1024.50
# firefox       856.23
# ...
```

### Équivalent Unix/Linux (orienté texte)

```bash
# Parsing complexe nécessaire
ps aux | 
    awk '{print $11, $6}' | 
    sort -k2 -nr | 
    head -5 | 
    awk '{printf "%-20s %10.2f MB\n", $1, $2/1024}'

# Chaque étape manipule du texte brut
# Risque d'erreurs si le format change
```

### Avantages de l'approche objet

> [!example] Accès direct aux propriétés
> 
> ```powershell
> # PowerShell : accès direct et sûr
> $process = Get-Process chrome
> $process.CPU           # Propriété CPU
> $process.WorkingSet    # Propriété mémoire
> $process.Kill()        # Méthode Kill
> 
> # Pas besoin de parser du texte !
> ```

> [!example] Filtrage intelligent
> 
> ```powershell
> # PowerShell comprend les types de données
> Get-Process | Where-Object CPU -gt 100           # Comparaison numérique
> Get-Service | Where-Object Status -eq 'Running'  # Comparaison d'énumération
> Get-ChildItem | Where-Object LastWriteTime -gt (Get-Date).AddDays(-7)  # Comparaison de dates
> ```

### Pas besoin de formatage intermédiaire

```powershell
# Unix/Linux : formatage pour chaque commande
ps aux | grep chrome | awk '{print $2}' | xargs kill

# PowerShell : les objets gardent toutes leurs informations
Get-Process chrome | Stop-Process
# Pas de grep, awk, ou parsing nécessaire
```

---

## 🚀 Avantages du pipeline orienté objet

### 1. Simplicité et élégance

```powershell
# Opération complexe en une ligne lisible
Get-EventLog -LogName System -Newest 100 | 
    Where-Object EntryType -eq 'Error' | 
    Group-Object Source | 
    Sort-Object Count -Descending
```

> [!info] Explication Cette simple chaîne :
> 
> - Récupère les 100 derniers événements système
> - Filtre uniquement les erreurs
> - Groupe par source
> - Trie par fréquence
> 
> Tout cela sans parser une seule ligne de texte !

### 2. Sécurité et fiabilité

```powershell
# Les types sont préservés et vérifiés
Get-Process | Stop-Process  # ✅ PowerShell sait que ce sont des Process

# Tentative incorrecte détectée automatiquement
"notepad" | Stop-Process    # ⚠️ Erreur : String n'est pas un Process
```

> [!warning] Protection contre les erreurs PowerShell valide automatiquement que les types d'objets sont compatibles avec les commandes, évitant de nombreuses erreurs d'exécution.

### 3. Découvrabilité

```powershell
# Explorer les propriétés disponibles
Get-Process | Get-Member -MemberType Property

# Voir les méthodes disponibles
Get-Process | Get-Member -MemberType Method

# Comprendre ce qu'une commande accepte
Get-Help Stop-Process -Parameter InputObject
```

### 4. Performance

```powershell
# Les objets restent en mémoire, pas de sérialisation/désérialisation
Get-Process |                    # Objets Process en mémoire
    Where-Object CPU -gt 50 |    # Filtrage direct en mémoire
    Sort-Object WorkingSet       # Tri direct en mémoire

# Pas de conversion texte → objet → texte → objet comme en bash
```

### 5. Manipulation de données riche

```powershell
# Calculs complexes sans outils externes
Get-Process | 
    Measure-Object WorkingSet -Sum -Average -Maximum | 
    Select-Object @{
        Name = 'TotalMemoryGB'
        Expression = {[math]::Round($_.Sum / 1GB, 2)}
    }, @{
        Name = 'AverageMemoryMB'
        Expression = {[math]::Round($_.Average / 1MB, 2)}
    }
```

### 6. Formatage flexible en fin de pipeline

```powershell
# Les données restent structurées jusqu'au formatage final
Get-Process | 
    Sort-Object CPU -Descending | 
    Select-Object -First 5 |
    Format-Table Name, CPU, WorkingSet -AutoSize

# Ou export en CSV, JSON, XML...
Get-Process | 
    Select-Object Name, CPU | 
    Export-Csv processes.csv -NoTypeInformation
```

> [!tip] Règle d'or du formatage Ne formatez jamais (`Format-Table`, `Format-List`) au milieu d'un pipeline. Le formatage détruit la structure objet. Faites-le toujours en dernière étape ou pas du tout si vous continuez le traitement.

---

## ⚠️ Pièges courants

### 1. Formater trop tôt dans le pipeline

```powershell
# ❌ MAUVAIS : Format-Table détruit les objets
Get-Process | 
    Format-Table Name, CPU | 
    Where-Object CPU -gt 100  # Erreur : plus d'objets Process disponibles

# ✅ BON : Formater en dernier
Get-Process | 
    Where-Object CPU -gt 100 | 
    Format-Table Name, CPU
```

> [!warning] Format = Fin du pipeline Les cmdlets `Format-*` convertissent les objets en objets de formatage. Après cela, vous ne pouvez plus traiter les données originales.

### 2. Confondre objets et texte

```powershell
# ❌ MAUVAIS : Out-String convertit en texte
Get-Process | 
    Out-String | 
    Where-Object Name -eq 'chrome'  # Ne fonctionnera pas, ce sont des strings

# ✅ BON : Travailler avec les objets
Get-Process | 
    Where-Object Name -eq 'chrome'
```

### 3. Ne pas vérifier les types acceptés

```powershell
# ❌ Erreur potentielle
Get-Content computers.txt | Get-Service
# Get-Service n'accepte pas de strings par le pipeline ByValue

# ✅ BON : Utiliser le bon paramètre
Get-Content computers.txt | ForEach-Object {
    Get-Service -ComputerName $_
}
```

### 4. Oublier que certaines commandes attendent tous les objets

```powershell
# Sort-Object, Group-Object, Measure-Object collectent TOUS les objets avant de traiter
Get-ChildItem C:\ -Recurse | Sort-Object Length
# Attention : peut consommer beaucoup de mémoire sur de gros volumes
```

> [!info] Commandes bloquantes Certaines commandes doivent collecter tous les objets avant de produire une sortie :
> 
> - `Sort-Object`
> - `Group-Object`
> - `Measure-Object`
> 
> D'autres traitent en streaming : `Where-Object`, `ForEach-Object`, `Select-Object`

---

## ✅ Bonnes pratiques

### 1. Utiliser le pipeline plutôt que des variables intermédiaires

```powershell
# ❌ Verbeux et moins performant
$services = Get-Service
$runningServices = $services | Where-Object Status -eq 'Running'
$sortedServices = $runningServices | Sort-Object DisplayName
$sortedServices | Format-Table

# ✅ Concis et élégant
Get-Service | 
    Where-Object Status -eq 'Running' | 
    Sort-Object DisplayName | 
    Format-Table
```

### 2. Formatter le code pour la lisibilité

```powershell
# ✅ Pipeline complexe bien formaté
Get-EventLog -LogName Application -Newest 1000 |
    Where-Object {$_.EntryType -eq 'Error' -or $_.EntryType -eq 'Warning'} |
    Group-Object Source |
    Where-Object Count -gt 5 |
    Sort-Object Count -Descending |
    Select-Object Name, Count, @{
        Name = 'FirstOccurrence'
        Expression = {$_.Group[0].TimeGenerated}
    }
```

### 3. Utiliser les alias avec parcimonie

```powershell
# ❌ Scripts de production : éviter les alias
ls | ? Name -like "*.log" | % {$_.FullName}

# ✅ Scripts de production : noms complets
Get-ChildItem | 
    Where-Object Name -like "*.log" | 
    ForEach-Object {$_.FullName}

# ℹ️ Console interactive : aliases OK pour la rapidité
gci | ? Name -like "*.log" | % FullName
```

### 4. Tester les types d'objets avec Get-Member

```powershell
# Toujours vérifier ce qui circule dans le pipeline
Get-Process | Get-Member
Get-Service | Get-Member

# Identifier les propriétés et méthodes disponibles
Get-ChildItem | Get-Member | Where-Object MemberType -eq 'Property'
```

### 5. Utiliser -WhatIf pour les commandes destructives

```powershell
# Tester le pipeline avant d'exécuter
Get-Process notepad | Stop-Process -WhatIf

# Vérifier ce qui serait supprimé
Get-ChildItem *.tmp | Remove-Item -WhatIf
```

> [!tip] Astuce de débogage Ajoutez `| Get-Member` ou `| Format-List *` à n'importe quel point du pipeline pour inspecter ce qui circule.
> 
> ```powershell
> Get-Process | 
>     Where-Object CPU -gt 50 | 
>     Get-Member  # Voir ce qui est disponible à ce stade
> ```

### 6. Exploiter le streaming quand c'est possible

```powershell
# ✅ Traitement en streaming : efficace en mémoire
Get-ChildItem C:\Logs -Recurse |
    Where-Object Extension -eq '.log' |
    ForEach-Object {
        # Traitement fichier par fichier
        $_.FullName
    }

# ⚠️ Éviter de tout collecter si possible
$allFiles = Get-ChildItem C:\Logs -Recurse
# Tous les fichiers en mémoire d'un coup
```

### 7. Chaîner logiquement les opérations

```powershell
# ✅ Ordre logique : filtrer → trier → sélectionner → formater
Get-Process |                           # 1. Obtenir les données
    Where-Object CPU -gt 50 |           # 2. Filtrer (réduit le dataset)
    Sort-Object WorkingSet -Descending | # 3. Trier
    Select-Object -First 10 |           # 4. Limiter
    Format-Table Name, CPU, WorkingSet  # 5. Afficher
```

---

## 🎓 Résumé

Le pipeline PowerShell est un mécanisme puissant qui :

- **Connecte des commandes** avec le symbole `|`
- **Transfère des objets .NET** complets, pas du texte
- **Préserve les propriétés et méthodes** tout au long de la chaîne
- **Offre une approche supérieure** aux shells textuels traditionnels
- **Simplifie les opérations complexes** en combinant des commandes simples

> [!tip] Points clés à retenir
> 
> - Le pipeline PowerShell est orienté **objet**, pas texte
> - Formatez (`Format-*`) **toujours en dernière étape**
> - Utilisez `Get-Member` pour **explorer les objets**
> - Privilégiez le **pipeline** aux variables intermédiaires
> - Testez avec **-WhatIf** avant les opérations destructives

---

_Ce cours fait partie d'une série complète sur PowerShell. Maîtriser le pipeline est essentiel pour exploiter tout le potentiel de PowerShell._