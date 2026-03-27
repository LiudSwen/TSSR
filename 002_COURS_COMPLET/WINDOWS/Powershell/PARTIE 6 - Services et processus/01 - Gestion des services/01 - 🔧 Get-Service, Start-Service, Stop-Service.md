

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

## 🎯 Introduction aux Services Windows

Les **services Windows** sont des applications qui s'exécutent en arrière-plan du système d'exploitation, sans interface utilisateur visible. Ils sont essentiels au fonctionnement du système (serveur web, base de données, antivirus, etc.).

PowerShell offre trois cmdlets principales pour gérer ces services :

- `Get-Service` : consulter l'état des services
- `Start-Service` : démarrer des services
- `Stop-Service` : arrêter des services

> [!info] Pourquoi gérer les services via PowerShell ?
> 
> - **Automatisation** : scriptage des tâches répétitives
> - **Gestion à distance** : administration de serveurs distants
> - **Efficacité** : manipulation rapide sans interface graphique
> - **Flexibilité** : filtrage et traitement avancés

---

## 📊 Get-Service - Consultation des services

### Qu'est-ce que Get-Service ?

`Get-Service` permet d'interroger et d'afficher les services Windows installés sur une machine. C'est votre outil de diagnostic principal.

### Syntaxe de base

```powershell
Get-Service
```

Cette commande sans paramètre liste **tous les services** du système, qu'ils soient en cours d'exécution ou arrêtés.

### 🔍 Filtrage par nom de service

#### Recherche exacte

```powershell
# Rechercher un service spécifique par son nom
Get-Service -Name "Spooler"

# Rechercher plusieurs services
Get-Service -Name "Spooler", "W32Time", "BITS"
```

> [!tip] Astuce Le paramètre `-Name` accepte un tableau de noms, ce qui permet de récupérer plusieurs services en une seule commande.

#### Recherche avec wildcards (caractères génériques)

PowerShell accepte les wildcards pour des recherches flexibles :

|Wildcard|Signification|Exemple|
|---|---|---|
|`*`|N'importe quelle chaîne de caractères|`"Win*"` (tous les services commençant par Win)|
|`?`|Un seul caractère|`"W?nRM"` (WinRM, W3nRM, etc.)|

```powershell
# Tous les services commençant par "Win"
Get-Service -Name "Win*"

# Tous les services contenant "SQL"
Get-Service -Name "*SQL*"

# Services se terminant par "Service"
Get-Service -Name "*Service"
```

> [!example] Exemple pratique Pour trouver tous les services liés à Windows Update :
> 
> ```powershell
> Get-Service -Name "*update*"
> ```

### 🏷️ Filtrage par nom d'affichage

Le **nom d'affichage** (DisplayName) est le nom "lisible" du service, différent du nom technique.

```powershell
# Recherche par nom d'affichage
Get-Service -DisplayName "Print Spooler"

# Avec wildcards
Get-Service -DisplayName "*Windows Update*"
```

> [!warning] Différence Name vs DisplayName
> 
> - **Name** : nom technique court (ex: `Spooler`)
> - **DisplayName** : nom descriptif long (ex: `Print Spooler`)
> 
> Pour identifier un service dans un script, préférez toujours **Name** car il est invariant.

### 📋 Propriétés des objets Service

Chaque service retourné par `Get-Service` est un objet avec plusieurs propriétés :

|Propriété|Description|Valeurs possibles|
|---|---|---|
|**Name**|Nom technique du service|Chaîne de caractères|
|**DisplayName**|Nom d'affichage|Chaîne de caractères|
|**Status**|État actuel|Running, Stopped, Paused|
|**StartType**|Mode de démarrage|Automatic, Manual, Disabled|

#### Afficher toutes les propriétés

```powershell
# Voir toutes les propriétés d'un service
Get-Service -Name "Spooler" | Format-List *

# Sélectionner des propriétés spécifiques
Get-Service -Name "Spooler" | Select-Object Name, DisplayName, Status, StartType
```

#### Propriétés étendues avec Get-WmiObject

Pour obtenir plus d'informations (chemin de l'exécutable, compte d'exécution, etc.) :

```powershell
Get-WmiObject Win32_Service -Filter "Name='Spooler'" | Select-Object Name, PathName, StartName
```

> [!info] Note `Get-WmiObject` et `Get-CimInstance` donnent accès à des propriétés supplémentaires non disponibles avec `Get-Service`.

### 🎯 Filtrage par statut

Filtrer les services selon leur état d'exécution :

```powershell
# Services en cours d'exécution
Get-Service | Where-Object {$_.Status -eq "Running"}

# Services arrêtés
Get-Service | Where-Object {$_.Status -eq "Stopped"}

# Services en pause
Get-Service | Where-Object {$_.Status -eq "Paused"}
```

#### Combinaison de critères

```powershell
# Services arrêtés avec démarrage automatique (potentiellement problématique)
Get-Service | Where-Object {$_.Status -eq "Stopped" -and $_.StartType -eq "Automatic"}

# Services Windows en cours d'exécution
Get-Service -Name "Win*" | Where-Object {$_.Status -eq "Running"}
```

> [!tip] Astuce pour l'analyse Cette dernière commande est utile pour détecter des services qui devraient tourner mais sont arrêtés, ce qui peut indiquer un problème.

### 📊 Exemples d'utilisation avancée

#### Compter les services par état

```powershell
# Nombre de services en cours d'exécution
(Get-Service | Where-Object {$_.Status -eq "Running"}).Count

# Statistiques globales
Get-Service | Group-Object Status | Select-Object Name, Count
```

#### Export des services vers CSV

```powershell
# Exporter tous les services dans un fichier CSV
Get-Service | Select-Object Name, DisplayName, Status, StartType | Export-Csv -Path "C:\services.csv" -NoTypeInformation
```

#### Surveillance de services critiques

```powershell
# Vérifier l'état de services critiques
$criticalServices = @("Spooler", "W32Time", "WinRM")
Get-Service -Name $criticalServices | Where-Object {$_.Status -ne "Running"}
```

---

## ▶️ Start-Service - Démarrage des services

### Qu'est-ce que Start-Service ?

`Start-Service` permet de démarrer un ou plusieurs services Windows arrêtés. C'est l'équivalent de cliquer sur "Démarrer" dans l'interface graphique des services.

> [!warning] Droits administrateur requis Le démarrage de services nécessite des **privilèges administrateur**. Lancez PowerShell en tant qu'administrateur :
> 
> - Clic droit sur PowerShell → "Exécuter en tant qu'administrateur"
> - Sinon, vous obtiendrez une erreur d'accès refusé

### Syntaxe de base

```powershell
Start-Service -Name "NomDuService"
```

### 🚀 Démarrage simple

```powershell
# Démarrer le service Print Spooler
Start-Service -Name "Spooler"

# Démarrer plusieurs services
Start-Service -Name "Spooler", "W32Time"
```

> [!info] Comportement par défaut `Start-Service` retourne immédiatement après avoir initié le démarrage, **sans attendre** que le service soit complètement démarré.

### 🔄 Paramètre -PassThru

Par défaut, `Start-Service` ne retourne aucun objet. Le paramètre `-PassThru` permet d'obtenir l'objet service en sortie.

```powershell
# Démarrer un service et récupérer l'objet
$service = Start-Service -Name "Spooler" -PassThru

# Afficher le statut après démarrage
$service | Select-Object Name, Status
```

> [!tip] Utilité de -PassThru Permet de :
> 
> - Vérifier que le service a bien démarré
> - Enchaîner d'autres opérations sur le service
> - Logger ou auditer les actions

### 📦 Gestion des dépendances

Certains services dépendent d'autres services pour fonctionner. PowerShell gère automatiquement ces dépendances.

#### Afficher les dépendances d'un service

```powershell
# Voir les services dont dépend un service
Get-Service -Name "W32Time" | Select-Object -ExpandProperty ServicesDependedOn

# Voir les services qui dépendent d'un service
Get-Service -Name "LanmanServer" | Select-Object -ExpandProperty DependentServices
```

#### Démarrage avec gestion automatique des dépendances

```powershell
# Start-Service démarre automatiquement les services dépendants nécessaires
Start-Service -Name "W32Time"
# Si W32Time dépend d'autres services arrêtés, ils seront démarrés en premier
```

> [!example] Exemple concret Si vous démarrez le service "Serveur" (LanmanServer), tous ses services dépendants nécessaires seront automatiquement démarrés.

### ⏱️ Vérifier le démarrage effectif

```powershell
# Démarrer un service et attendre qu'il soit vraiment "Running"
Start-Service -Name "Spooler"
Start-Sleep -Seconds 2
$status = (Get-Service -Name "Spooler").Status

if ($status -eq "Running") {
    Write-Host "Service démarré avec succès" -ForegroundColor Green
} else {
    Write-Host "Échec du démarrage" -ForegroundColor Red
}
```

### 🔧 Démarrage conditionnel

Démarrer uniquement si le service est arrêté :

```powershell
$service = Get-Service -Name "Spooler"

if ($service.Status -ne "Running") {
    Start-Service -Name "Spooler"
    Write-Host "Service démarré"
} else {
    Write-Host "Service déjà en cours d'exécution"
}
```

### 📊 Exemples avancés

#### Démarrer tous les services arrêtés d'un type spécifique

```powershell
# Démarrer tous les services Windows arrêtés avec démarrage automatique
Get-Service -Name "Win*" | Where-Object {$_.Status -eq "Stopped" -and $_.StartType -eq "Automatic"} | Start-Service
```

#### Script de démarrage avec gestion d'erreurs

```powershell
$serviceName = "Spooler"

try {
    Start-Service -Name $serviceName -ErrorAction Stop
    Write-Host "✓ Service $serviceName démarré avec succès" -ForegroundColor Green
}
catch {
    Write-Host "✗ Erreur lors du démarrage de $serviceName : $($_.Exception.Message)" -ForegroundColor Red
}
```

---

## ⏹️ Stop-Service - Arrêt des services

### Qu'est-ce que Stop-Service ?

`Stop-Service` permet d'arrêter un ou plusieurs services Windows en cours d'exécution. Utilisez-le pour libérer des ressources, effectuer de la maintenance, ou résoudre des problèmes.

> [!warning] Droits administrateur requis Comme pour `Start-Service`, l'arrêt de services nécessite des **privilèges administrateur**.

### Syntaxe de base

```powershell
Stop-Service -Name "NomDuService"
```

### 🛑 Arrêt simple

```powershell
# Arrêter le service Print Spooler
Stop-Service -Name "Spooler"

# Arrêter plusieurs services
Stop-Service -Name "Spooler", "BITS"
```

### 💪 Paramètre -Force

Certains services ont des **services dépendants** actifs. Par défaut, PowerShell refuse de les arrêter pour éviter de casser des dépendances.

```powershell
# Tentative d'arrêt d'un service avec dépendants (échoue)
Stop-Service -Name "LanmanServer"
# Erreur : Impossible d'arrêter le service car d'autres services en dépendent

# Arrêt forcé (arrête aussi les services dépendants)
Stop-Service -Name "LanmanServer" -Force
```

> [!warning] Attention avec -Force L'utilisation de `-Force` arrête **tous les services dépendants** sans avertissement. Assurez-vous de comprendre l'impact avant de l'utiliser sur des services critiques.

#### Visualiser les services qui seront impactés

```powershell
# Voir les services dépendants avant d'arrêter
$service = Get-Service -Name "LanmanServer"
$service.DependentServices

# Arrêter après vérification
if ($service.DependentServices.Count -gt 0) {
    Write-Host "⚠️ Attention : $($service.DependentServices.Count) service(s) dépendant(s) seront arrêtés"
    $service.DependentServices | Select-Object Name, DisplayName
}
```

### ⚠️ Confirmation pour services critiques

Certains services sont critiques pour le système. Il est prudent de demander confirmation avant leur arrêt.

```powershell
# Arrêt avec confirmation
Stop-Service -Name "Spooler" -Confirm

# Désactiver la confirmation (dans un script automatisé)
Stop-Service -Name "Spooler" -Confirm:$false
```

> [!tip] Bonnes pratiques
> 
> - Utilisez `-Confirm` pour les services critiques dans les scripts interactifs
> - Utilisez `-WhatIf` pour simuler l'action sans l'exécuter réellement

### 🔍 Paramètre -WhatIf (simulation)

Tester ce qui se passerait sans réellement arrêter le service :

```powershell
# Simulation d'arrêt
Stop-Service -Name "Spooler" -WhatIf
# Affiche : "Que se passe-t-il si : Performing the operation "Stop-Service" on target "Print Spooler (Spooler)"."
```

### 🔄 Gestion des services dépendants

#### Lister les dépendants

```powershell
# Services qui dépendent de LanmanServer
$dependents = (Get-Service -Name "LanmanServer").DependentServices
$dependents | Format-Table Name, DisplayName, Status
```

#### Arrêt en cascade contrôlé

```powershell
$serviceName = "LanmanServer"
$service = Get-Service -Name $serviceName

# Arrêter d'abord les dépendants
foreach ($dependent in $service.DependentServices) {
    if ($dependent.Status -eq "Running") {
        Write-Host "Arrêt de $($dependent.DisplayName)..."
        Stop-Service -Name $dependent.Name
    }
}

# Puis arrêter le service principal
Stop-Service -Name $serviceName
Write-Host "Service $serviceName arrêté"
```

### ⏱️ Vérification de l'arrêt

```powershell
# Arrêter et vérifier
Stop-Service -Name "Spooler"
Start-Sleep -Seconds 2

$status = (Get-Service -Name "Spooler").Status
if ($status -eq "Stopped") {
    Write-Host "✓ Service arrêté avec succès" -ForegroundColor Green
} else {
    Write-Host "⚠️ Le service n'est pas complètement arrêté : $status" -ForegroundColor Yellow
}
```

### 📊 Exemples avancés

#### Arrêt de tous les services d'une catégorie

```powershell
# Arrêter tous les services non-Microsoft en cours d'exécution
Get-Service | Where-Object {$_.Status -eq "Running" -and $_.DisplayName -notlike "*Microsoft*"} | Stop-Service -Force
```

#### Script d'arrêt avec gestion d'erreurs

```powershell
$serviceName = "Spooler"

try {
    $service = Get-Service -Name $serviceName -ErrorAction Stop
    
    if ($service.Status -eq "Running") {
        Stop-Service -Name $serviceName -Force -ErrorAction Stop
        Write-Host "✓ Service $serviceName arrêté avec succès" -ForegroundColor Green
    } else {
        Write-Host "ℹ️ Service $serviceName déjà arrêté" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "✗ Erreur : $($_.Exception.Message)" -ForegroundColor Red
}
```

#### Arrêt temporisé avec timeout

```powershell
# Arrêter un service avec timeout de 30 secondes
$serviceName = "Spooler"
Stop-Service -Name $serviceName

$timeout = 30
$elapsed = 0

while ((Get-Service -Name $serviceName).Status -ne "Stopped" -and $elapsed -lt $timeout) {
    Start-Sleep -Seconds 1
    $elapsed++
}

if ((Get-Service -Name $serviceName).Status -eq "Stopped") {
    Write-Host "Service arrêté en $elapsed secondes"
} else {
    Write-Host "Timeout : le service n'a pas pu être arrêté dans les $timeout secondes"
}
```

---

## ⚠️ Pièges courants et bonnes pratiques

### 🚫 Pièges à éviter

#### 1. Oublier les privilèges administrateur

```powershell
# ❌ Erreur fréquente
Start-Service -Name "Spooler"
# Erreur : Access Denied

# ✅ Solution : lancer PowerShell en administrateur
```

#### 2. Confondre Name et DisplayName

```powershell
# ❌ Incorrect
Get-Service -Name "Print Spooler"  # Pas de résultat

# ✅ Correct
Get-Service -Name "Spooler"        # Nom technique
# OU
Get-Service -DisplayName "Print Spooler"  # Nom d'affichage
```

#### 3. Ne pas gérer les dépendances

```powershell
# ❌ Peut échouer
Stop-Service -Name "LanmanServer"  # Erreur si services dépendants actifs

# ✅ Avec -Force ou vérification préalable
Stop-Service -Name "LanmanServer" -Force
```

#### 4. Ne pas vérifier l'état avant une action

```powershell
# ❌ Risqué
Start-Service -Name "Spooler"  # Et si déjà démarré ?

# ✅ Avec vérification
if ((Get-Service -Name "Spooler").Status -ne "Running") {
    Start-Service -Name "Spooler"
}
```

### ✅ Bonnes pratiques

#### 1. Toujours utiliser le nom technique (Name)

```powershell
# ✅ Préférez ceci
Get-Service -Name "Spooler"

# Plutôt que ceci
Get-Service -DisplayName "Print Spooler"
```

> [!tip] Pourquoi ? Le nom technique est invariant et ne dépend pas de la langue du système.

#### 2. Gérer les erreurs avec try-catch

```powershell
try {
    Start-Service -Name "MonService" -ErrorAction Stop
    Write-Host "Succès"
}
catch {
    Write-Host "Erreur : $($_.Exception.Message)"
    # Logger l'erreur, envoyer une alerte, etc.
}
```

#### 3. Utiliser -WhatIf pour tester

```powershell
# Tester avant d'exécuter sur des services critiques
Stop-Service -Name "ServiceCritique" -WhatIf
```

#### 4. Logger les actions importantes

```powershell
$logFile = "C:\Logs\services.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Start-Service -Name "Spooler"
Add-Content -Path $logFile -Value "$timestamp - Service Spooler démarré"
```

#### 5. Documenter les services critiques

```powershell
# Créer une liste de services critiques avec description
$criticalServices = @(
    @{Name="Spooler"; Description="Service d'impression"},
    @{Name="W32Time"; Description="Synchronisation horaire"},
    @{Name="WinRM"; Description="Gestion à distance"}
)

foreach ($svc in $criticalServices) {
    $status = (Get-Service -Name $svc.Name).Status
    Write-Host "$($svc.Description) ($($svc.Name)) : $status"
}
```

### 🔐 Sécurité et auditing

#### Vérifier qui peut modifier les services

```powershell
# Les modifications de services sont auditées dans les Event Logs
Get-EventLog -LogName System -Source "Service Control Manager" -Newest 50 | 
    Where-Object {$_.Message -like "*Spooler*"} | 
    Select-Object TimeGenerated, Message
```

#### Automatisation avec mesure de performance

```powershell
# Mesurer le temps de démarrage d'un service
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Start-Service -Name "Spooler"
$stopwatch.Stop()

Write-Host "Service démarré en $($stopwatch.ElapsedMilliseconds) ms"
```

---

> [!tip] 💡 Points clés à retenir
> 
> - **Get-Service** : consultation, filtrage par Name/DisplayName/Status, utilisation de wildcards
> - **Start-Service** : démarrage avec -PassThru, gestion auto des dépendances, droits admin requis
> - **Stop-Service** : arrêt avec -Force pour dépendants, -Confirm pour sécurité
> - Toujours utiliser le **nom technique** dans les scripts
> - Prévoir la **gestion d'erreurs** avec try-catch
> - Vérifier l'**état** avant d'agir