

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

## Qu'est-ce que PowerShell

PowerShell est un **shell en ligne de commande** et un **environnement de scripting** développé par Microsoft. Il constitue une évolution majeure par rapport aux shells traditionnels en proposant une approche moderne, orientée objet, pour l'administration système et l'automatisation.

> [!info] Versions de PowerShell
> 
> - **Windows PowerShell** (v1.0 à v5.1) : Version intégrée à Windows, basée sur .NET Framework
> - **PowerShell Core** (v6.x et v7.x+) : Version moderne, multiplateforme, open-source, basée sur .NET Core/.NET

---

## Définition et objectifs

### 🎯 Objectifs principaux

PowerShell a été conçu avec plusieurs objectifs clés :

#### 1. **Unifier l'administration système**

PowerShell vise à fournir un outil unique pour gérer l'ensemble de l'écosystème Microsoft et au-delà. Avant PowerShell, chaque produit Microsoft (Exchange, Active Directory, SQL Server, etc.) avait ses propres outils d'administration.

#### 2. **Faciliter l'automatisation**

L'objectif est de rendre l'automatisation accessible aux administrateurs systèmes, pas seulement aux développeurs. La syntaxe est conçue pour être lisible et cohérente.

#### 3. **Améliorer la productivité**

Grâce à la découverte intuitive des commandes, l'autocomplétion avancée et la cohérence de la syntaxe, PowerShell réduit considérablement le temps nécessaire pour accomplir des tâches administratives.

#### 4. **Offrir un langage puissant mais accessible**

PowerShell combine la puissance d'un langage de programmation complet avec la simplicité d'utilisation d'un shell interactif.

> [!tip] Philosophie PowerShell "Faire en sorte que les tâches simples restent simples, et que les tâches complexes deviennent possibles"

### 📊 Caractéristiques définissantes

|Caractéristique|Description|
|---|---|
|**Orienté objet**|Manipulation d'objets .NET plutôt que de texte brut|
|**Syntaxe cohérente**|Convention Verbe-Nom pour toutes les commandes|
|**Pipeline puissant**|Passage d'objets complets entre commandes|
|**Extensible**|Modules et snap-ins pour étendre les fonctionnalités|
|**Scriptable**|Du simple one-liner aux scripts complexes|
|**Découvrable**|Système d'aide intégré et autocomplétion intelligente|

---

## Shell orienté objet vs shells textuels

### 🔄 Paradigme fondamental

La différence majeure entre PowerShell et les shells traditionnels (cmd.exe, bash, zsh) réside dans la **nature des données manipulées**.

#### Shells traditionnels (cmd, bash)

```bash
# Dans bash, tout est du texte
ls -la | grep ".txt" | wc -l
# Chaque commande reçoit du texte et produit du texte
# Nécessite du parsing pour extraire l'information
```

**Problèmes du paradigme textuel :**

- Parsing complexe et fragile
- Dépendance au format de sortie
- Perte d'information structurée
- Difficile de manipuler des données complexes

#### PowerShell - Approche objet

```powershell
# Dans PowerShell, on manipule des objets
Get-ChildItem | Where-Object Extension -eq ".txt" | Measure-Object
# Chaque commande reçoit des objets et produit des objets
# Accès direct aux propriétés et méthodes
```

**Avantages du paradigme objet :**

- Accès direct aux propriétés (pas de parsing)
- Conservation de toute l'information
- Manipulation intuitive des données structurées
- IntelliSense et autocomplétion riches

### 📝 Exemple comparatif concret

**Objectif :** Obtenir la taille totale des fichiers .log d'un dossier

#### Avec bash (approche textuelle)

```bash
# Approche bash - parsing de texte
ls -l *.log | awk '{sum += $5} END {print sum}'
# Fragile : dépend du format exact de ls
# Difficile à lire et maintenir
```

#### Avec PowerShell (approche objet)

```powershell
# Approche PowerShell - manipulation d'objets
Get-ChildItem -Filter "*.log" | 
    Measure-Object -Property Length -Sum | 
    Select-Object -ExpandProperty Sum

# Ou de manière plus concise
(Get-ChildItem *.log | Measure-Object Length -Sum).Sum
```

> [!example] Anatomie d'un objet PowerShell
> 
> ```powershell
> # Chaque fichier est un objet FileInfo avec :
> $file = Get-Item "exemple.txt"
> 
> # Propriétés accessibles directement
> $file.Name          # "exemple.txt"
> $file.Length        # 1024 (taille en octets)
> $file.LastWriteTime # DateTime object
> $file.Extension     # ".txt"
> 
> # Méthodes disponibles
> $file.Delete()      # Supprimer le fichier
> $file.MoveTo("C:\nouveau\chemin")
> ```

### 🆚 Tableau comparatif

|Aspect|Shells textuels|PowerShell|
|---|---|---|
|**Type de données**|Chaînes de caractères|Objets .NET|
|**Pipeline**|Texte → Texte|Objet → Objet|
|**Accès aux données**|Parsing/Regex requis|Propriétés directes|
|**Fiabilité**|Format dépendant|Structure garantie|
|**Complexité**|Augmente avec parsing|Reste constante|
|**Information**|Peut être perdue|Complètement préservée|

> [!warning] Piège courant Les débutants tentent souvent de parser le texte de sortie de PowerShell comme avec bash. C'est une erreur ! Utilisez toujours les propriétés des objets.
> 
> ```powershell
> # ❌ Mauvais - parsing de texte
> Get-Process | Out-String | Select-String "chrome"
> 
> # ✅ Bon - filtrage d'objets
> Get-Process | Where-Object Name -like "*chrome*"
> ```

---

## Intégration .NET

### 🔗 PowerShell et le Framework .NET

PowerShell est construit **au-dessus** du framework .NET, ce qui lui confère une puissance considérable. Chaque commande PowerShell retourne des objets .NET natifs.

#### Relation avec .NET

```powershell
# PowerShell utilise directement les classes .NET
[System.DateTime]::Now  # Classe .NET DateTime
[System.Math]::PI       # Classe .NET Math
[System.IO.File]::ReadAllText("C:\fichier.txt")
```

> [!info] .NET Framework vs .NET Core
> 
> - **Windows PowerShell (5.1)** : Utilise .NET Framework 4.x (Windows uniquement)
> - **PowerShell Core/7+** : Utilise .NET Core/.NET 5+ (multiplateforme)

### 🎁 Bénéfices de l'intégration .NET

#### 1. **Accès complet aux bibliothèques .NET**

```powershell
# Utilisation de classes .NET directement
$web = New-Object System.Net.WebClient
$content = $web.DownloadString("https://example.com")

# Ou avec des accélérateurs de type
$date = [DateTime]::Parse("2024-12-10")
$guid = [Guid]::NewGuid()
```

#### 2. **Types de données riches**

PowerShell hérite de tous les types .NET :

```powershell
# Types primitifs
[int]$nombre = 42
[string]$texte = "Hello"
[bool]$vrai = $true

# Types complexes
[DateTime]$maintenant = Get-Date
[System.Collections.ArrayList]$liste = @()
[System.Text.RegularExpressions.Regex]$regex = "\d+"
```

#### 3. **Méthodes et propriétés natives**

```powershell
# Toutes les méthodes .NET sont disponibles
$chaine = "Bonjour le monde"
$chaine.ToUpper()           # "BONJOUR LE MONDE"
$chaine.Contains("monde")   # True
$chaine.Split(" ")          # ["Bonjour", "le", "monde"]

# Propriétés
$chaine.Length              # 16
```

#### 4. **Interopérabilité**

```powershell
# Charger des assemblies .NET personnalisées
Add-Type -Path "C:\MonAssembly.dll"

# Créer des types .NET à la volée
Add-Type -TypeDefinition @"
public class MaClasse {
    public string Saluer(string nom) {
        return "Bonjour " + nom;
    }
}
"@

$obj = New-Object MaClasse
$obj.Saluer("PowerShell")  # "Bonjour PowerShell"
```

### 🔍 Exploration des objets .NET

PowerShell fournit des outils pour explorer les objets .NET :

```powershell
# Voir tous les membres (propriétés et méthodes)
Get-Date | Get-Member

# Filtrer par type de membre
Get-Date | Get-Member -MemberType Property
Get-Date | Get-Member -MemberType Method

# Voir le type .NET d'un objet
(Get-Date).GetType().FullName  # System.DateTime
```

> [!tip] Accélérateurs de type PowerShell fournit des raccourcis pour les types .NET courants :
> 
> |Accélérateur|Type .NET complet|
> |---|---|
> |`[int]`|`System.Int32`|
> |`[string]`|`System.String`|
> |`[bool]`|`System.Boolean`|
> |`[datetime]`|`System.DateTime`|
> |`[xml]`|`System.Xml.XmlDocument`|
> |`[regex]`|`System.Text.RegularExpressions.Regex`|

### ⚙️ Exemple pratique : Manipulation XML

```powershell
# Grâce à .NET, PowerShell manipule le XML nativement
[xml]$config = @"
<configuration>
    <server name="prod" ip="192.168.1.100"/>
    <server name="dev" ip="192.168.1.200"/>
</configuration>
"@

# Navigation intuitive dans la structure XML
$config.configuration.server | ForEach-Object {
    Write-Host "$($_.name): $($_.ip)"
}

# Modification
$config.configuration.server[0].ip = "192.168.1.150"
```

> [!warning] Attention aux versions Certaines classes .NET ne sont pas disponibles dans PowerShell Core si elles dépendent de fonctionnalités Windows-specific du .NET Framework.

---

## Cas d'usage principaux

PowerShell excelle dans plusieurs domaines. Voici les cas d'usage les plus courants.

### 1. 🖥️ Administration système Windows

PowerShell est l'outil privilégié pour gérer les systèmes Windows.

**Exemples :**

- Gestion des utilisateurs et groupes Active Directory
- Configuration des serveurs Windows
- Gestion des services et processus
- Administration du registre
- Gestion des mises à jour Windows

```powershell
# Exemples typiques d'administration Windows
Get-Service | Where-Object Status -eq "Running"
Get-EventLog -LogName System -Newest 100
Get-HotFix | Sort-Object InstalledOn -Descending
```

### 2. ☁️ Administration Cloud (Azure, AWS, Microsoft 365)

PowerShell est largement utilisé pour l'administration des services cloud.

**Modules disponibles :**

- **Az** : Azure Resource Manager
- **AzureAD** : Azure Active Directory
- **ExchangeOnlineManagement** : Exchange Online
- **Microsoft.Graph** : Microsoft Graph API
- **AWS.Tools** : Amazon Web Services

```powershell
# Gestion Azure
Connect-AzAccount
Get-AzVM | Where-Object PowerState -eq "VM running"

# Gestion Microsoft 365
Connect-MgGraph
Get-MgUser -Filter "department eq 'IT'"
```

### 3. 🤖 Automatisation et DevOps

PowerShell est un pilier de l'automatisation moderne.

**Applications :**

- Scripts de déploiement
- CI/CD pipelines (Azure DevOps, GitHub Actions)
- Configuration management
- Tâches planifiées et orchestration
- Tests automatisés (Pester)

```powershell
# Exemple : Déploiement automatisé
# Ce script pourrait faire partie d'un pipeline CI/CD
$app = "MonApplication"
$version = "1.2.3"

Stop-Service -Name $app
Copy-Item ".\build\*" -Destination "C:\Apps\$app" -Recurse -Force
Start-Service -Name $app

Write-Host "Déploiement de $app version $version terminé"
```

### 4. 📊 Reporting et analyse

PowerShell permet de collecter, analyser et formater des données.

**Cas d'usage :**

- Rapports d'audit système
- Collecte de métriques
- Analyse de logs
- Exports vers CSV, JSON, HTML, Excel

```powershell
# Rapport HTML des services critiques
Get-Service | 
    Where-Object StartType -eq "Automatic" |
    Select-Object Name, Status, StartType |
    ConvertTo-Html |
    Out-File "rapport-services.html"
```

### 5. 🔧 Gestion de configuration

PowerShell DSC (Desired State Configuration) permet la gestion déclarative de la configuration.

**Utilisation :**

- Maintenir un état désiré des serveurs
- Configuration as Code
- Drift detection et correction automatique
- Intégration avec Ansible, Chef, Puppet

### 6. 🔐 Sécurité et conformité

PowerShell est utilisé pour l'audit de sécurité et la conformité.

**Applications :**

- Scripts d'audit de sécurité
- Détection de configurations non conformes
- Gestion des permissions
- Analyse de vulnérabilités
- Forensics et investigation

```powershell
# Audit des comptes avec privilèges
Get-ADGroupMember "Domain Admins" | 
    Select-Object Name, SamAccountName |
    Export-Csv "audit-admins.csv"
```

### 7. 🔄 Migration et transformation de données

PowerShell facilite les migrations et transformations de données.

**Exemples :**

- Migration d'utilisateurs entre systèmes
- Transformation de fichiers en masse
- Nettoyage et normalisation de données
- Intégration entre systèmes hétérogènes

### 📊 Répartition des usages

> [!info] Statistiques d'utilisation D'après différentes enquêtes auprès des administrateurs système :
> 
> - **60%** : Administration système Windows
> - **40%** : Cloud et services Microsoft 365
> - **35%** : Automatisation et scripting
> - **25%** : DevOps et CI/CD
> - **20%** : Reporting et analyse
> 
> _(Un administrateur utilise généralement PowerShell pour plusieurs cas d'usage)_

> [!tip] Quand ne PAS utiliser PowerShell PowerShell n'est pas toujours le meilleur choix :
> 
> - **Applications graphiques** : Utilisez C#, WPF, ou autre framework GUI
> - **Calculs haute performance** : C++, Rust ou langages compilés sont plus rapides
> - **Web backend** : Python (Django/Flask), Node.js, C# (ASP.NET) sont plus adaptés
> - **Scripts Linux/Unix** : Bash reste le standard, bien que PowerShell Core soit disponible

---

## PowerShell comme langage et shell

PowerShell possède une double nature unique : c'est à la fois un **shell interactif** pour l'administration en temps réel et un **langage de scripting complet** pour l'automatisation.

### 🖥️ PowerShell comme Shell interactif

#### Caractéristiques du mode shell

Le shell interactif permet l'exécution de commandes en temps réel avec retour immédiat.

```powershell
# Mode interactif - chaque ligne s'exécute immédiatement
PS C:\> Get-Process chrome
PS C:\> Get-Service | Where-Object Status -eq "Running"
PS C:\> $x = 42
PS C:\> $x * 2
84
```

**Fonctionnalités du shell :**

1. **Prompt interactif**
    
    - Affichage du chemin courant
    - Exécution immédiate
    - Historique des commandes (↑/↓)
2. **Autocomplétion (Tab)**
    
    ```powershell
    Get-Ser[Tab]     # Complète vers Get-Service
    Get-Service -N[Tab]  # Complète vers -Name
    ```
    
3. **Historique persistant**
    
    ```powershell
    Get-History              # Voir l'historique
    Invoke-History 5         # Réexécuter la commande #5
    ```
    
4. **Alias et raccourcis**
    
    ```powershell
    dir    # Alias de Get-ChildItem
    ls     # Aussi un alias de Get-ChildItem
    pwd    # Get-Location
    cd     # Set-Location
    ```
    

> [!example] Session shell typique
> 
> ```powershell
> # Navigation et exploration
> PS C:\> cd C:\Logs
> PS C:\Logs> ls *.log
> PS C:\Logs> Get-Content error.log -Tail 20
> 
> # Test rapide d'une commande
> PS C:\Logs> Get-Service bits | Select-Object Name, Status
> 
> # Assignation rapide
> PS C:\Logs> $date = Get-Date
> PS C:\Logs> $date.AddDays(-7)
> ```

### 📝 PowerShell comme Langage de scripting

#### Caractéristiques du langage

PowerShell offre toutes les fonctionnalités d'un langage de programmation moderne.

**Éléments du langage :**

1. **Variables et types**
    
    ```powershell
    $nom = "PowerShell"
    [int]$age = 15
    $liste = @(1, 2, 3, 4, 5)
    ```
    
2. **Structures de contrôle**
    
    ```powershell
    # Conditions
    if ($x -gt 10) { "Grand" } else { "Petit" }
    
    # Boucles
    foreach ($item in $liste) { Write-Host $item }
    while ($i -lt 10) { $i++ }
    ```
    
3. **Fonctions**
    
    ```powershell
    function Get-Square {
        param([int]$Number)
        return $Number * $Number
    }
    ```
    
4. **Gestion d'erreurs**
    
    ```powershell
    try {
        Get-Item "C:\inexistant.txt"
    }
    catch {
        Write-Error "Fichier introuvable"
    }
    ```
    
5. **Scripts réutilisables** (.ps1)
    
    ```powershell
    # deploy-app.ps1
    param(
        [string]$AppName,
        [string]$Version
    )
    
    Write-Host "Déploiement de $AppName v$Version"
    # ... logique de déploiement
    ```
    

### 🔄 Transition Shell → Script

PowerShell facilite la transition du mode interactif vers le scripting.

#### Workflow typique

1. **Expérimentation interactive**
    
    ```powershell
    # Tester dans le shell
    PS C:\> Get-Service | Where-Object Status -eq "Running"
    ```
    
2. **Sauvegarde dans un script**
    
    ```powershell
    # get-running-services.ps1
    Get-Service | 
        Where-Object Status -eq "Running" |
        Select-Object Name, DisplayName, StartType
    ```
    
3. **Ajout de paramètres**
    
    ```powershell
    # get-services.ps1
    param(
        [ValidateSet("Running", "Stopped")]
        [string]$Status = "Running"
    )
    
    Get-Service | 
        Where-Object Status -eq $Status |
        Select-Object Name, DisplayName, StartType
    ```
    
4. **Amélioration progressive**
    
    ```powershell
    # get-services.ps1 (version améliorée)
    param(
        [ValidateSet("Running", "Stopped")]
        [string]$Status = "Running",
        
        [string]$ExportPath
    )
    
    $services = Get-Service | 
        Where-Object Status -eq $Status |
        Select-Object Name, DisplayName, StartType
    
    if ($ExportPath) {
        $services | Export-Csv $ExportPath -NoTypeInformation
        Write-Host "Exporté vers $ExportPath"
    } else {
        $services
    }
    ```
    

> [!tip] Bonne pratique : Du simple au complexe Commencez toujours par tester vos commandes de manière interactive dans le shell. Une fois que ça fonctionne, transformez-les progressivement en script avec paramètres, validation et gestion d'erreurs.

### 📊 Comparaison Shell vs Langage

|Aspect|Mode Shell|Mode Script|
|---|---|---|
|**Utilisation**|Commandes ponctuelles|Automatisation répétable|
|**Complexité**|Simple, direct|Peut être très complexe|
|**Réutilisation**|Non (historique)|Oui (fichiers .ps1)|
|**Paramètres**|Saisis manuellement|Définis dans le script|
|**Gestion erreurs**|Manuel|try/catch, -ErrorAction|
|**Documentation**|Aucune|Commentaires, help|
|**Débogage**|Difficile|Breakpoints, debugging|

### 🎯 One-liners vs Scripts

PowerShell brille dans les deux approches.

#### One-liners (Shell)

Commandes puissantes en une seule ligne :

```powershell
# Trouver les 10 plus gros fichiers
Get-ChildItem -Recurse | Sort-Object Length -Descending | Select-Object -First 10

# Redémarrer les services arrêtés qui devraient tourner
Get-Service | Where-Object {$_.Status -eq "Stopped" -and $_.StartType -eq "Automatic"} | Start-Service

# Générer un rapport HTML
Get-Process | ConvertTo-Html -Property Name, CPU, Memory | Out-File rapport.html
```

#### Scripts structurés

Pour des tâches complexes et répétables :

```powershell
<#
.SYNOPSIS
    Nettoie les fichiers temporaires anciens
.DESCRIPTION
    Supprime les fichiers plus vieux que X jours dans les dossiers temp
.PARAMETER DaysOld
    Nombre de jours (défaut: 30)
.EXAMPLE
    .\Clean-TempFiles.ps1 -DaysOld 7
#>
param(
    [int]$DaysOld = 30,
    [switch]$WhatIf
)

$tempFolders = @(
    $env:TEMP,
    "C:\Windows\Temp"
)

$cutoffDate = (Get-Date).AddDays(-$DaysOld)

foreach ($folder in $tempFolders) {
    Write-Host "Nettoyage de $folder..."
    
    $files = Get-ChildItem $folder -Recurse -File | 
        Where-Object LastWriteTime -lt $cutoffDate
    
    if ($WhatIf) {
        Write-Host "Fichiers qui seraient supprimés: $($files.Count)"
    } else {
        $files | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-Host "Supprimés: $($files.Count) fichiers"
    }
}
```

> [!warning] Attention à la lisibilité Les one-liners sont puissants mais peuvent devenir illisibles. Si votre commande dépasse 2-3 pipes ou devient difficile à comprendre, envisagez de la transformer en script avec des variables intermédiaires.
> 
> ```powershell
> # ❌ Difficile à lire
> Get-ChildItem | Where-Object {$_.Extension -eq ".log" -and $_.LastWriteTime -lt (Get-Date).AddDays(-7)} | ForEach-Object {Remove-Item $_.FullName -Force}
> 
> # ✅ Plus clair
> $logs = Get-ChildItem -Filter "*.log"
> $cutoff = (Get-Date).AddDays(-7)
> $oldLogs = $logs | Where-Object LastWriteTime -lt $cutoff
> $oldLogs | Remove-Item -Force
> ```

### 🌟 Flexibilité unique

Cette double nature fait la force de PowerShell :

- **Apprentissage progressif** : Commencez simple dans le shell, progressez vers des scripts
- **Prototypage rapide** : Testez dans le shell, scriptez ensuite
- **Maintenance facilitée** : Du one-liner au script complet sans changer de syntaxe
- **Productivité maximale** : L'outil s'adapte à vos besoins

---

> [!success] Points clés à retenir
> 
> 1. **PowerShell est orienté objet** : Vous manipulez des objets .NET, pas du texte
> 2. **Intégration .NET profonde** : Accès à tout l'écosystème .NET et ses bibliothèques
> 3. **Polyvalent** : De l'administration système au DevOps, en passant par le cloud
> 4. **Double nature** : Shell interactif pour l'exploration, langage pour l'automatisation
> 5. **Évolutif** : Du simple one-liner au script complexe avec la même syntaxe

---

_PowerShell représente un changement de paradigme dans l'administration système, alliant la puissance d'un langage de programmation à la simplicité d'utilisation d'un shell interactif._