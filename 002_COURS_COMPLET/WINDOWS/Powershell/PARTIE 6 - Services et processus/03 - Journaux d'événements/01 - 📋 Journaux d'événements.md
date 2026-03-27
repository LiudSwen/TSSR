

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

## 🎯 Introduction aux journaux d'événements

Les journaux d'événements Windows sont essentiels pour :

- **Diagnostiquer** les problèmes système et applicatifs
- **Auditer** les activités de sécurité
- **Surveiller** les performances et erreurs
- **Investiguer** les incidents de sécurité

> [!info] Contexte historique `Get-EventLog` est la cmdlet historique pour accéder aux journaux d'événements Windows classiques. Elle ne fonctionne qu'avec les journaux traditionnels Windows et ne peut pas accéder aux nouveaux journaux introduits avec Vista/2008.

---

## 📖 Get-EventLog - Cmdlet classique

### 🗂️ Journaux disponibles

Windows maintient plusieurs journaux d'événements standards accessibles via `Get-EventLog` :

|Journal|Description|Cas d'usage|
|---|---|---|
|**Application**|Événements applicatifs|Erreurs d'applications, logs métier|
|**System**|Événements système|Démarrages, services, pilotes|
|**Security**|Événements de sécurité|Connexions, modifications de droits|
|**Setup**|Installation de Windows|Mises à jour, installations|

> [!example] Lister tous les journaux disponibles
> 
> ```powershell
> # Obtenir la liste complète des journaux accessibles
> Get-EventLog -List
> 
> # Résultat typique :
> #   Max(K) Retain OverflowAction        Entries Log
> #   ------ ------ --------------        ------- ---
> #   20,480      0 OverwriteAsNeeded      15,234 Application
> #   20,480      0 OverwriteAsNeeded       8,567 System
> #  196,608      0 OverwriteAsNeeded      45,123 Security
> ```

### ⚙️ Paramètres principaux

#### `-LogName` : Spécifier le journal

Le paramètre obligatoire pour cibler un journal spécifique.

```powershell
# Récupérer tous les événements du journal System
Get-EventLog -LogName System

# Récupérer les événements Application
Get-EventLog -LogName Application

# Alias court (LogName est positionnel)
Get-EventLog System
```

#### `-Newest` : Limiter le nombre d'événements

Récupère uniquement les N événements les plus récents.

```powershell
# Obtenir les 10 derniers événements du journal System
Get-EventLog -LogName System -Newest 10

# Les 50 derniers événements d'erreur
Get-EventLog -LogName Application -Newest 50 -EntryType Error
```

> [!tip] Performance Utilisez toujours `-Newest` pour limiter les résultats lors de tests. Les journaux peuvent contenir des dizaines de milliers d'événements.

#### `-After` et `-Before` : Plage temporelle

Filtrer les événements par période.

```powershell
# Événements des dernières 24 heures
Get-EventLog -LogName System -After (Get-Date).AddDays(-1)

# Événements d'une période spécifique
$debut = Get-Date "2024-12-01"
$fin = Get-Date "2024-12-15"
Get-EventLog -LogName Application -After $debut -Before $fin

# Événements de la semaine dernière
Get-EventLog -LogName Security -After (Get-Date).AddDays(-7) -Before (Get-Date)
```

> [!warning] Attention aux performances Filtrer par date peut être lent sur de gros journaux. Combinez avec `-Newest` quand possible.

#### `-EntryType` : Filtrer par type d'événement

Cinq types d'événements disponibles :

```powershell
# Uniquement les erreurs
Get-EventLog -LogName Application -EntryType Error

# Erreurs et avertissements
Get-EventLog -LogName System -EntryType Error,Warning

# Types disponibles :
# - Error         : Erreurs significatives
# - Warning       : Avertissements (problèmes potentiels)
# - Information   : Événements informatifs
# - SuccessAudit  : Audits de sécurité réussis
# - FailureAudit  : Audits de sécurité échoués
```

> [!example] Recherche d'erreurs critiques récentes
> 
> ```powershell
> # Toutes les erreurs des 3 derniers jours
> Get-EventLog -LogName System `
>              -EntryType Error `
>              -After (Get-Date).AddDays(-3) |
>     Select-Object TimeGenerated, Source, Message |
>     Format-Table -AutoSize
> ```

#### `-Source` : Filtrer par source

Cibler des événements d'une application ou service spécifique.

```powershell
# Événements d'une source spécifique
Get-EventLog -LogName Application -Source "MSSQLSERVER"

# Événements du service Disk
Get-EventLog -LogName System -Source "Disk"

# Voir toutes les sources disponibles
Get-EventLog -LogName Application | 
    Select-Object -ExpandProperty Source -Unique
```

#### `-InstanceId` et `-EventId` : Filtrer par ID d'événement

Rechercher des événements spécifiques par leur identifiant.

```powershell
# Événement spécifique (ex: Event ID 1000 = erreur application)
Get-EventLog -LogName Application -InstanceId 1000

# Plusieurs IDs
Get-EventLog -LogName System -InstanceId 7001,7002

# Note : -EventId est un alias de -InstanceId
Get-EventLog -LogName System -EventId 6008  # Arrêt inattendu
```

> [!info] InstanceId vs EventId Ces deux paramètres sont identiques dans `Get-EventLog`. `-EventId` est simplement un alias plus intuitif de `-InstanceId`.

---

### 📊 Propriétés des événements

Chaque événement retourné contient de nombreuses propriétés exploitables.

#### Propriétés principales

```powershell
# Voir toutes les propriétés disponibles
Get-EventLog -LogName System -Newest 1 | Get-Member -MemberType Property

# Propriétés les plus utilisées
Get-EventLog -LogName System -Newest 1 | 
    Select-Object EventID, TimeGenerated, EntryType, Source, Message
```

|Propriété|Description|Exemple|
|---|---|---|
|**EventID**|Identifiant numérique de l'événement|1000, 7001, 6008|
|**TimeGenerated**|Date et heure de génération|15/12/2024 14:30:15|
|**EntryType**|Type d'événement|Error, Warning, Information|
|**Source**|Application ou composant source|Disk, Service Control Manager|
|**Message**|Description détaillée|"Le service XXX s'est arrêté"|
|**Category**|Catégorie de l'événement|(0), (1), TaskCategory|
|**UserName**|Utilisateur associé|DOMAIN\User|
|**MachineName**|Nom de la machine|SERVEUR01|

#### Exemples d'utilisation des propriétés

```powershell
# Grouper les erreurs par source
Get-EventLog -LogName Application -EntryType Error -Newest 100 |
    Group-Object Source |
    Sort-Object Count -Descending |
    Select-Object Count, Name

# Analyser les événements par utilisateur
Get-EventLog -LogName Security -Newest 500 |
    Where-Object UserName -ne $null |
    Group-Object UserName |
    Select-Object Count, Name

# Timeline des erreurs critiques
Get-EventLog -LogName System -EntryType Error -Newest 50 |
    Select-Object TimeGenerated, EventID, Source, Message |
    Format-Table -AutoSize
```

> [!example] Rapport d'erreurs formaté
> 
> ```powershell
> # Créer un rapport lisible des erreurs récentes
> Get-EventLog -LogName Application -EntryType Error -Newest 20 |
>     Select-Object @{
>         Name='Date'; 
>         Expression={$_.TimeGenerated.ToString("yyyy-MM-dd HH:mm")}
>     },
>     @{Name='ID'; Expression={$_.EventID}},
>     Source,
>     @{Name='Description'; Expression={$_.Message.Substring(0,100) + "..."}} |
>     Format-Table -Wrap
> ```

---

### 🔍 Filtrage et recherche

#### Filtrage simple avec Where-Object

```powershell
# Événements contenant un mot-clé spécifique
Get-EventLog -LogName System -Newest 500 |
    Where-Object Message -like "*failed*"

# Événements d'une source ET d'un type spécifique
Get-EventLog -LogName Application -Newest 1000 |
    Where-Object {$_.Source -eq "MSSQLSERVER" -and $_.EntryType -eq "Error"}

# Événements entre certaines heures
Get-EventLog -LogName System -Newest 500 |
    Where-Object {
        $_.TimeGenerated.Hour -ge 8 -and 
        $_.TimeGenerated.Hour -le 18
    }
```

#### Recherches complexes

```powershell
# Recherche multi-critères
Get-EventLog -LogName Application -Newest 1000 |
    Where-Object {
        ($_.EntryType -eq "Error" -or $_.EntryType -eq "Warning") -and
        $_.TimeGenerated -gt (Get-Date).AddHours(-12) -and
        $_.Message -match "database|connection|timeout"
    } |
    Sort-Object TimeGenerated -Descending

# Détecter les événements répétitifs (même EventID multiples fois)
Get-EventLog -LogName System -Newest 500 |
    Group-Object EventID |
    Where-Object Count -gt 10 |
    Select-Object Count, Name,
        @{Name='Sample'; Expression={$_.Group[0].Message.Substring(0,80)}}
```

> [!tip] Expressions régulières Utilisez `-match` avec des regex pour des recherches puissantes dans les messages.

#### Statistiques et analyses

```powershell
# Compter les événements par type
Get-EventLog -LogName Application -Newest 1000 |
    Group-Object EntryType |
    Select-Object Count, Name

# Top 10 des sources génératrices d'erreurs
Get-EventLog -LogName System -EntryType Error -Newest 500 |
    Group-Object Source |
    Sort-Object Count -Descending |
    Select-Object -First 10 Count, Name

# Distribution horaire des événements
Get-EventLog -LogName System -Newest 1000 |
    Group-Object {$_.TimeGenerated.Hour} |
    Sort-Object Name |
    Select-Object @{Name='Heure'; Expression={$_.Name + "h"}}, Count
```

---

### 💾 Export d'événements

#### Export vers fichiers

```powershell
# Export CSV basique
Get-EventLog -LogName Application -Newest 100 |
    Select-Object TimeGenerated, EntryType, Source, EventID, Message |
    Export-Csv -Path "C:\Logs\AppEvents.csv" -NoTypeInformation -Encoding UTF8

# Export avec sélection de propriétés
Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddDays(-7) |
    Select-Object @{Name='Date'; Expression={$_.TimeGenerated}},
                  @{Name='Type'; Expression={$_.EntryType}},
                  @{Name='Source'; Expression={$_.Source}},
                  @{Name='EventID'; Expression={$_.EventID}},
                  @{Name='Message'; Expression={$_.Message}} |
    Export-Csv "C:\Logs\SystemErrors_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
```

#### Export HTML pour reporting

```powershell
# Rapport HTML formaté
Get-EventLog -LogName Application -EntryType Error -Newest 50 |
    Select-Object TimeGenerated, Source, EventID, Message |
    ConvertTo-Html -Title "Rapport d'erreurs Application" `
                   -PreContent "<h1>Erreurs Application - $(Get-Date)</h1>" |
    Out-File "C:\Reports\AppErrors.html"
```

#### Export JSON

```powershell
# Export JSON pour intégration avec d'autres outils
Get-EventLog -LogName System -Newest 100 |
    Select-Object TimeGenerated, EntryType, Source, EventID, Message |
    ConvertTo-Json -Depth 2 |
    Out-File "C:\Logs\SystemEvents.json" -Encoding UTF8
```

> [!warning] Taille des exports Les messages d'événements peuvent être très longs. Tronquez-les si nécessaire pour réduire la taille des fichiers d'export.

#### Sauvegarde des journaux entiers

```powershell
# Sauvegarder un journal complet au format natif .evt
# (Nécessite des droits administrateur)
$BackupPath = "C:\Backup\Application_$(Get-Date -Format 'yyyyMMdd').evt"
wevtutil epl Application $BackupPath

# Alternative avec PowerShell (format personnalisé)
Get-EventLog -LogName Application |
    Export-Clixml "C:\Backup\Application_$(Get-Date -Format 'yyyyMMdd').xml"
```

---

### ⚠️ Limitations

> [!warning] Limitations importantes de Get-EventLog

`Get-EventLog` présente plusieurs limitations significatives :

#### 1. Journaux classiques uniquement

```powershell
# ✅ Fonctionne - Journal classique
Get-EventLog -LogName System

# ❌ Ne fonctionne PAS - Nouveau journal Vista/2008+
Get-EventLog -LogName "Microsoft-Windows-PowerShell/Operational"
# Erreur : Get-EventLog : Le journal 'Microsoft-Windows-PowerShell/Operational' 
#          n'existe pas sur l'ordinateur.
```

> [!info] Journaux accessibles Seuls les journaux classiques (Application, System, Security, Setup) et quelques journaux personnalisés anciens sont accessibles via `Get-EventLog`.

#### 2. Pas de filtrage XPath

Impossible d'utiliser des requêtes XPath avancées pour des filtrages complexes côté serveur.

```powershell
# Get-EventLog ne supporte pas de filtrage XPath
# Il faut filtrer en PowerShell après récupération (moins performant)
Get-EventLog -LogName System -Newest 1000 |
    Where-Object {$_.EventID -eq 1000 -and $_.Source -eq "Disk"}
```

#### 3. Performance sur gros volumes

```powershell
# ⚠️ Peut être très lent sur de gros journaux
Get-EventLog -LogName Security | 
    Where-Object Message -like "*failed*"

# ✅ Mieux : limiter d'abord avec -Newest
Get-EventLog -LogName Security -Newest 5000 |
    Where-Object Message -like "*failed*"
```

#### 4. Accès distant limité

```powershell
# L'accès distant nécessite WinRM et des configurations spécifiques
# Pas de paramètre -ComputerName natif fiable

# Alternative : utiliser Invoke-Command
Invoke-Command -ComputerName SERVEUR01 -ScriptBlock {
    Get-EventLog -LogName System -Newest 10
}
```

#### 5. Obsolescence

> [!info] Cmdlet obsolète Microsoft recommande d'utiliser `Get-WinEvent` pour les nouveaux scripts. `Get-EventLog` est maintenu uniquement pour la compatibilité ascendante.

---

## ✅ Bonnes pratiques

### 1. Toujours limiter les résultats

```powershell
# ❌ Mauvais : récupère potentiellement des milliers d'événements
Get-EventLog -LogName System

# ✅ Bon : limitation explicite
Get-EventLog -LogName System -Newest 100

# ✅ Bon : filtrage temporel
Get-EventLog -LogName System -After (Get-Date).AddDays(-1)
```

### 2. Combiner les filtres pour la performance

```powershell
# ⚠️ Moins performant : filtre après récupération
Get-EventLog -LogName Application -Newest 5000 |
    Where-Object EntryType -eq "Error"

# ✅ Plus performant : filtre natif
Get-EventLog -LogName Application -EntryType Error -Newest 1000
```

### 3. Gestion des erreurs

```powershell
# Toujours inclure la gestion d'erreurs
try {
    $events = Get-EventLog -LogName System -Newest 100 -ErrorAction Stop
    Write-Host "Récupération de $($events.Count) événements réussie"
} catch {
    Write-Warning "Impossible d'accéder au journal System : $_"
}

# Vérifier les droits d'accès (Security nécessite admin)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "L'accès au journal Security nécessite des privilèges administrateur"
}
```

### 4. Sélection des propriétés pertinentes

```powershell
# ❌ Récupère toutes les propriétés (mémoire)
$events = Get-EventLog -LogName System -Newest 1000

# ✅ Sélectionne uniquement ce qui est nécessaire
$events = Get-EventLog -LogName System -Newest 1000 |
    Select-Object TimeGenerated, EventID, Source, Message
```

### 5. Documentation et commentaires

```powershell
<#
.SYNOPSIS
    Analyse les erreurs applicatives des dernières 24h
.DESCRIPTION
    Récupère et analyse les erreurs du journal Application,
    génère des statistiques par source
.NOTES
    Nécessite : PowerShell 5.1+
    Droits : Utilisateur standard suffisant
#>
function Get-ApplicationErrorReport {
    $errors = Get-EventLog -LogName Application `
                           -EntryType Error `
                           -After (Get-Date).AddDays(-1)
    
    $errors | Group-Object Source | 
        Select-Object Count, Name |
        Sort-Object Count -Descending
}
```

---

## 🚫 Pièges courants

### 1. Confusion entre EventID et InstanceID

```powershell
# Ces deux paramètres sont identiques (alias)
Get-EventLog -LogName System -EventId 6008
Get-EventLog -LogName System -InstanceId 6008

# ⚠️ Attention : ne pas confondre avec la propriété Index
$event = Get-EventLog -LogName System -Newest 1
$event.Index        # Position dans le journal
$event.EventID      # Identifiant de l'événement
$event.InstanceId   # Même valeur que EventID
```

### 2. Oublier les droits nécessaires

```powershell
# ❌ Échoue si exécuté sans droits admin
Get-EventLog -LogName Security -Newest 10

# ✅ Vérifier les droits d'abord
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Get-EventLog -LogName Security -Newest 10
} else {
    Write-Warning "Droits administrateur requis pour le journal Security"
}
```

### 3. Mauvaise gestion des dates

```powershell
# ❌ Format de date ambigu
Get-EventLog -LogName System -After "01/12/2024"  # 1er déc ou 12 janv ?

# ✅ Format explicite
Get-EventLog -LogName System -After (Get-Date "2024-12-01")

# ✅ Ou avec des objets DateTime
$date = [DateTime]"2024-12-01 00:00:00"
Get-EventLog -LogName System -After $date
```

### 4. Négliger les performances

```powershell
# ❌ Très lent sur gros journaux
Get-EventLog -LogName Application |
    Where-Object {$_.Message -like "*erreur*"}

# ✅ Filtrer intelligemment
Get-EventLog -LogName Application -EntryType Error -Newest 1000 |
    Where-Object {$_.Message -like "*erreur*"}

# ✅ Encore mieux : cibler la période
Get-EventLog -LogName Application `
             -EntryType Error `
             -After (Get-Date).AddDays(-7) |
    Where-Object {$_.Message -like "*erreur*"}
```

### 5. Ignorer l'encodage dans les exports

```powershell
# ❌ Peut causer des problèmes d'accents
Get-EventLog -LogName System -Newest 100 |
    Export-Csv "events.csv"

# ✅ Spécifier l'encodage UTF8
Get-EventLog -LogName System -Newest 100 |
    Export-Csv "events.csv" -NoTypeInformation -Encoding UTF8
```

### 6. Recherche dans Message sans limiter d'abord

```powershell
# ❌ Peut traiter des dizaines de milliers d'événements
Get-EventLog -LogName System |
    Where-Object Message -match "error|fail"

# ✅ Limiter le périmètre de recherche
Get-EventLog -LogName System `
             -After (Get-Date).AddDays(-3) `
             -Newest 2000 |
    Where-Object Message -match "error|fail"
```

---

> [!tip] Astuce finale Bien que `Get-EventLog` soit fonctionnelle et simple, considérez l'apprentissage de `Get-WinEvent` pour vos futurs scripts. Elle offre plus de flexibilité, de performance, et accède à tous les journaux modernes de Windows.