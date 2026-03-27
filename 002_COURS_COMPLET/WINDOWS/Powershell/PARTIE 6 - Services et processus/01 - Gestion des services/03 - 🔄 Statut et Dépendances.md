

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

## 🎯 États de service

Les services Windows peuvent se trouver dans différents états qui reflètent leur cycle de vie. Comprendre ces états est essentiel pour diagnostiquer les problèmes et gérer correctement les services.

### Liste complète des états

|État|Description|Signification|
|---|---|---|
|**Running**|Service en cours d'exécution|Le service fonctionne normalement|
|**Stopped**|Service arrêté|Le service n'est pas actif|
|**Paused**|Service en pause|Le service est suspendu temporairement|
|**StartPending**|Démarrage en cours|Le service est en train de démarrer|
|**StopPending**|Arrêt en cours|Le service est en train de s'arrêter|
|**ContinuePending**|Reprise en cours|Le service sort de l'état Paused|
|**PausePending**|Mise en pause en cours|Le service est en train d'être mis en pause|

### Vérifier l'état d'un service

```powershell
# État simple
Get-Service -Name "Spooler" | Select-Object Name, Status

# État détaillé avec tous les états possibles
Get-Service | Where-Object { $_.Status -ne "Running" }

# Vérifier un état spécifique
$service = Get-Service -Name "Spooler"
if ($service.Status -eq "Running") {
    Write-Host "Le service est en cours d'exécution" -ForegroundColor Green
}
```

> [!info] États transitoires Les états se terminant par "Pending" (StartPending, StopPending, etc.) sont des états transitoires. Si un service reste bloqué dans un de ces états, cela indique généralement un problème.

### Surveiller les changements d'état

```powershell
# Attendre qu'un service soit complètement démarré
$service = Get-Service -Name "Spooler"
$service.WaitForStatus("Running", [TimeSpan]::FromSeconds(30))

# Surveiller l'état avec timeout personnalisé
try {
    $service.WaitForStatus("Stopped", [TimeSpan]::FromSeconds(10))
    Write-Host "Service arrêté avec succès"
} catch {
    Write-Warning "Le service n'a pas pu s'arrêter dans le délai imparti"
}
```

> [!warning] Timeout important Toujours définir un timeout lors de l'utilisation de `WaitForStatus()` pour éviter un blocage infini si le service ne change jamais d'état.

### Filtrer par état

```powershell
# Tous les services arrêtés
Get-Service | Where-Object { $_.Status -eq "Stopped" }

# Services en état anormal (ni Running ni Stopped)
Get-Service | Where-Object { 
    $_.Status -notin @("Running", "Stopped") 
}

# Services bloqués en état Pending
Get-Service | Where-Object { 
    $_.Status -like "*Pending" 
} | Select-Object Name, Status, DisplayName
```

> [!tip] Astuce diagnostic Les services en état "Pending" depuis longtemps peuvent indiquer un blocage. Utilisez cette commande pour les détecter rapidement.

---

## ⚙️ Types de démarrage (StartType)

Le type de démarrage (StartType) détermine comment et quand un service démarre avec Windows. C'est un paramètre crucial pour l'administration système.

### Les quatre types principaux

|StartType|Comportement|Utilisation typique|
|---|---|---|
|**Automatic**|Démarre au boot système|Services critiques (réseau, sécurité)|
|**Automatic (Delayed Start)**|Démarre 2 min après le boot|Services non-critiques mais nécessaires|
|**Manual**|Démarre uniquement sur demande|Services occasionnels|
|**Disabled**|Ne peut pas démarrer|Services désactivés pour sécurité/performance|

### Vérifier le type de démarrage

```powershell
# Type de démarrage d'un service
Get-Service -Name "Spooler" | Select-Object Name, StartType, Status

# Lister tous les services automatiques
Get-Service | Where-Object { $_.StartType -eq "Automatic" } | 
    Format-Table Name, DisplayName, Status

# Services avec démarrage différé
Get-CimInstance -ClassName Win32_Service | 
    Where-Object { $_.StartMode -eq "Auto" -and $_.DelayedAutoStart -eq $true } |
    Select-Object Name, DisplayName, State
```

> [!info] Démarrage différé Le type "Automatic (Delayed Start)" n'est pas directement visible avec `Get-Service`. Il faut utiliser `Get-CimInstance` et vérifier la propriété `DelayedAutoStart`.

### Modifier le type de démarrage

```powershell
# Passer un service en démarrage automatique
Set-Service -Name "Spooler" -StartupType Automatic

# Passer en démarrage manuel
Set-Service -Name "Spooler" -StartupType Manual

# Désactiver un service
Set-Service -Name "Spooler" -StartupType Disabled

# Activer le démarrage différé (nécessite sc.exe)
sc.exe config "Spooler" start=delayed-auto
```

> [!warning] Attention avec Disabled Un service désactivé ne peut pas être démarré, même manuellement, tant qu'il n'est pas réactivé. Cela peut causer des problèmes si d'autres services en dépendent.

### Démarrage différé en détail

```powershell
# Fonction pour activer le démarrage différé
function Set-ServiceDelayedStart {
    param(
        [Parameter(Mandatory)]
        [string]$ServiceName,
        [bool]$DelayedStart = $true
    )
    
    $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='$ServiceName'"
    
    if ($service) {
        # Modifier le type de démarrage
        if ($DelayedStart) {
            sc.exe config $ServiceName start=delayed-auto
            Write-Host "Service $ServiceName configuré en démarrage automatique différé"
        } else {
            Set-Service -Name $ServiceName -StartupType Automatic
            Write-Host "Service $ServiceName configuré en démarrage automatique immédiat"
        }
    }
}

# Utilisation
Set-ServiceDelayedStart -ServiceName "Spooler" -DelayedStart $true
```

### Bonnes pratiques pour StartType

```powershell
# Audit des services configurés en Automatic
Get-Service | Where-Object { 
    $_.StartType -eq "Automatic" -and $_.Status -ne "Running" 
} | Select-Object Name, DisplayName, Status |
    Format-Table -AutoSize

# Cette commande révèle les services qui devraient tourner mais sont arrêtés
```

> [!tip] Optimisation du démarrage Utilisez "Automatic (Delayed Start)" pour les services non-critiques afin d'accélérer le boot. Cela réduit la charge lors du démarrage système.

---

## 🔗 Dépendances de services

Les services Windows peuvent dépendre les uns des autres. Comprendre ces dépendances est crucial pour éviter les erreurs lors du démarrage ou de l'arrêt des services.

### Deux types de dépendances

**DependentServices** : Services qui dépendent du service actuel

- Si vous arrêtez ce service, ces services dépendants seront également arrêtés
- C'est la relation "parent vers enfants"

**ServicesDependedOn** : Services dont le service actuel dépend

- Le service actuel ne peut démarrer que si ces services sont déjà démarrés
- C'est la relation "enfant vers parents"

### Visualiser les dépendances

```powershell
# Voir les services qui dépendent du service actuel
$service = Get-Service -Name "LanmanServer"
$service.DependentServices | Select-Object Name, DisplayName, Status

# Voir les services dont dépend le service actuel
$service.ServicesDependedOn | Select-Object Name, DisplayName, Status

# Vue complète des dépendances
Get-Service -Name "LanmanServer" | Select-Object Name, 
    @{N="Dépendances requises"; E={$_.ServicesDependedOn.Name -join ", "}},
    @{N="Services dépendants"; E={$_.DependentServices.Name -join ", "}}
```

> [!example] Exemple concret Le service "LanmanServer" (Serveur) a souvent le service "Browser" comme service dépendant. Si vous arrêtez LanmanServer, Browser sera également arrêté.

### Propriété RequiredServices

```powershell
# RequiredServices est un alias pour ServicesDependedOn
$service = Get-Service -Name "Spooler"

# Ces deux commandes donnent le même résultat
$service.ServicesDependedOn
$service.RequiredServices

# Vérifier si toutes les dépendances sont démarrées
$allDependenciesRunning = $service.RequiredServices | 
    Where-Object { $_.Status -ne "Running" } |
    Measure-Object | Select-Object -ExpandProperty Count

if ($allDependenciesRunning -eq 0) {
    Write-Host "Toutes les dépendances sont en cours d'exécution"
} else {
    Write-Warning "Certaines dépendances ne sont pas démarrées"
}
```

### Vérifier avant de démarrer un service

```powershell
function Start-ServiceWithDependencies {
    param([string]$ServiceName)
    
    $service = Get-Service -Name $ServiceName
    
    # Vérifier les dépendances
    $stoppedDeps = $service.ServicesDependedOn | 
        Where-Object { $_.Status -ne "Running" }
    
    if ($stoppedDeps) {
        Write-Host "Démarrage des dépendances requises..." -ForegroundColor Yellow
        foreach ($dep in $stoppedDeps) {
            Write-Host "  - Démarrage de $($dep.Name)..."
            Start-Service -Name $dep.Name
        }
    }
    
    # Démarrer le service principal
    Write-Host "Démarrage de $ServiceName..." -ForegroundColor Green
    Start-Service -Name $ServiceName
}

# Utilisation
Start-ServiceWithDependencies -ServiceName "Spooler"
```

### Arrêter un service avec dépendances

```powershell
# Arrêter avec force (arrête aussi les services dépendants)
Stop-Service -Name "LanmanServer" -Force

# Vérifier d'abord les services dépendants
$service = Get-Service -Name "LanmanServer"
if ($service.DependentServices.Count -gt 0) {
    Write-Warning "Les services suivants seront également arrêtés :"
    $service.DependentServices | ForEach-Object { 
        Write-Host "  - $($_.DisplayName)" 
    }
    
    $confirmation = Read-Host "Continuer ? (O/N)"
    if ($confirmation -eq "O") {
        Stop-Service -Name "LanmanServer" -Force
    }
}
```

> [!warning] Impact de l'arrêt L'arrêt d'un service avec l'option `-Force` arrêtera automatiquement tous les services dépendants sans avertissement supplémentaire. Toujours vérifier `DependentServices` avant.

---

## 🔍 Analyse de chaîne de dépendances

L'analyse de la chaîne complète de dépendances permet de comprendre l'impact global du démarrage ou de l'arrêt d'un service.

### Fonction récursive pour explorer les dépendances

```powershell
function Get-ServiceDependencyTree {
    param(
        [string]$ServiceName,
        [int]$Level = 0,
        [System.Collections.ArrayList]$Visited = @()
    )
    
    # Éviter les boucles infinies
    if ($Visited -contains $ServiceName) {
        return
    }
    $Visited.Add($ServiceName) | Out-Null
    
    $indent = "  " * $Level
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    
    if (-not $service) {
        Write-Host "$indent❌ Service non trouvé: $ServiceName" -ForegroundColor Red
        return
    }
    
    # Afficher le service actuel
    $statusIcon = if ($service.Status -eq "Running") { "✅" } else { "⚠️" }
    Write-Host "$indent$statusIcon $($service.DisplayName) [$($service.Status)]" -ForegroundColor $(
        if ($service.Status -eq "Running") { "Green" } else { "Yellow" }
    )
    
    # Explorer les dépendances
    if ($service.ServicesDependedOn.Count -gt 0) {
        Write-Host "$indent  └─ Dépend de:" -ForegroundColor Cyan
        foreach ($dep in $service.ServicesDependedOn) {
            Get-ServiceDependencyTree -ServiceName $dep.Name -Level ($Level + 2) -Visited $Visited
        }
    }
}

# Utilisation
Get-ServiceDependencyTree -ServiceName "Spooler"
```

### Mapper toutes les dépendances (ascendantes et descendantes)

```powershell
function Get-FullServiceDependencyMap {
    param([string]$ServiceName)
    
    $service = Get-Service -Name $ServiceName
    
    Write-Host "`n=== Carte complète des dépendances pour $($service.DisplayName) ===`n" -ForegroundColor Cyan
    
    # Dépendances ascendantes (ce dont le service dépend)
    Write-Host "📌 Services requis (ce service ne peut démarrer sans eux):" -ForegroundColor Yellow
    if ($service.ServicesDependedOn.Count -eq 0) {
        Write-Host "  Aucune dépendance requise" -ForegroundColor Gray
    } else {
        foreach ($dep in $service.ServicesDependedOn) {
            $status = if ($dep.Status -eq "Running") { "✅" } else { "❌" }
            Write-Host "  $status $($dep.DisplayName) [$($dep.Status)]"
        }
    }
    
    Write-Host ""
    
    # Dépendances descendantes (services qui dépendent de celui-ci)
    Write-Host "📌 Services dépendants (seront arrêtés si ce service s'arrête):" -ForegroundColor Yellow
    if ($service.DependentServices.Count -eq 0) {
        Write-Host "  Aucun service dépendant" -ForegroundColor Gray
    } else {
        foreach ($dep in $service.DependentServices) {
            $status = if ($dep.Status -eq "Running") { "✅" } else { "❌" }
            Write-Host "  $status $($dep.DisplayName) [$($dep.Status)]"
        }
    }
}

# Utilisation
Get-FullServiceDependencyMap -ServiceName "LanmanServer"
```

### Détecter les dépendances cassées

```powershell
# Trouver les services dont les dépendances ne sont pas satisfaites
Get-Service | ForEach-Object {
    $service = $_
    $brokenDeps = $service.ServicesDependedOn | 
        Where-Object { $_.Status -ne "Running" }
    
    if ($brokenDeps -and $service.Status -eq "Running") {
        [PSCustomObject]@{
            Service = $service.Name
            DisplayName = $service.DisplayName
            Status = $service.Status
            BrokenDependencies = ($brokenDeps.Name -join ", ")
        }
    }
} | Format-Table -AutoSize
```

> [!tip] Diagnostic avancé Cette commande identifie les services qui tournent malgré des dépendances arrêtées, ce qui peut indiquer des problèmes de configuration ou des services qui ont démarré dans le désordre.

### Visualiser la chaîne d'impact

```powershell
function Get-ServiceImpactChain {
    param(
        [string]$ServiceName,
        [string]$Action  # "Start" ou "Stop"
    )
    
    $service = Get-Service -Name $ServiceName
    
    Write-Host "`n=== Impact de l'action '$Action' sur $($service.DisplayName) ===`n" -ForegroundColor Cyan
    
    if ($Action -eq "Stop") {
        # Montrer tous les services qui seront arrêtés
        if ($service.DependentServices.Count -gt 0) {
            Write-Host "⚠️  Les services suivants seront ARRÊTÉS :" -ForegroundColor Red
            foreach ($dep in $service.DependentServices) {
                Write-Host "  ❌ $($dep.DisplayName) [$($dep.Status)]"
            }
        } else {
            Write-Host "✅ Aucun autre service ne sera affecté" -ForegroundColor Green
        }
    }
    elseif ($Action -eq "Start") {
        # Montrer tous les services qui doivent être démarrés avant
        $stoppedDeps = $service.ServicesDependedOn | 
            Where-Object { $_.Status -ne "Running" }
        
        if ($stoppedDeps) {
            Write-Host "⚠️  Les services suivants doivent d'abord être DÉMARRÉS :" -ForegroundColor Yellow
            foreach ($dep in $stoppedDeps) {
                Write-Host "  🔄 $($dep.DisplayName) [$($dep.Status)]"
            }
        } else {
            Write-Host "✅ Toutes les dépendances sont satisfaites" -ForegroundColor Green
        }
    }
}

# Utilisation
Get-ServiceImpactChain -ServiceName "LanmanServer" -Action "Stop"
Get-ServiceImpactChain -ServiceName "Spooler" -Action "Start"
```

---

## 🛠️ Gestion des services en échec

Windows offre des mécanismes pour gérer automatiquement les services qui échouent. La compréhension de ces options est essentielle pour assurer la disponibilité des services critiques.

### Causes communes d'échec

- Dépendances non satisfaites
- Erreurs de configuration
- Ressources insuffisantes (mémoire, disque)
- Problèmes de permissions
- Corruption de fichiers
- Conflits de ports

### Vérifier l'état de santé d'un service

```powershell
# Obtenir les informations détaillées via WMI
$service = Get-CimInstance -ClassName Win32_Service -Filter "Name='Spooler'"

# Informations importantes
$service | Select-Object Name, State, Status, ExitCode, 
    ProcessId, StartMode, PathName

# ExitCode indique la raison de l'arrêt (0 = succès, autre = erreur)
if ($service.ExitCode -ne 0) {
    Write-Warning "Le service a rencontré une erreur (ExitCode: $($service.ExitCode))"
}
```

### Journaux d'événements

```powershell
# Consulter les erreurs récentes d'un service
Get-EventLog -LogName System -Source "Service Control Manager" -Newest 50 |
    Where-Object { $_.Message -like "*Spooler*" } |
    Select-Object TimeGenerated, EntryType, Message |
    Format-Table -Wrap

# Erreurs de service sur les dernières 24h
Get-EventLog -LogName System -After (Get-Date).AddDays(-1) |
    Where-Object { $_.Source -eq "Service Control Manager" -and $_.EntryType -eq "Error" } |
    Select-Object TimeGenerated, Message |
    Format-List
```

> [!tip] Diagnostic rapide Le journal "System" de Windows enregistre tous les événements liés aux services. Consultez-le en priorité lors d'un problème.

### Redémarrer un service en échec

```powershell
function Restart-FailedService {
    param(
        [string]$ServiceName,
        [int]$MaxAttempts = 3
    )
    
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            Write-Host "Tentative $i de $MaxAttempts..." -ForegroundColor Yellow
            
            # Arrêter proprement si en cours
            $service = Get-Service -Name $ServiceName
            if ($service.Status -ne "Stopped") {
                Stop-Service -Name $ServiceName -Force -ErrorAction Stop
                Start-Sleep -Seconds 2
            }
            
            # Démarrer le service
            Start-Service -Name $ServiceName -ErrorAction Stop
            $service.WaitForStatus("Running", [TimeSpan]::FromSeconds(30))
            
            Write-Host "✅ Service $ServiceName démarré avec succès" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Warning "Échec de la tentative $i : $($_.Exception.Message)"
            if ($i -lt $MaxAttempts) {
                Start-Sleep -Seconds 5
            }
        }
    }
    
    Write-Error "❌ Impossible de démarrer le service après $MaxAttempts tentatives"
    return $false
}

# Utilisation
Restart-FailedService -ServiceName "Spooler" -MaxAttempts 3
```

### Surveiller et relancer automatiquement

```powershell
# Script de surveillance continue
function Watch-ServiceHealth {
    param(
        [string[]]$ServiceNames,
        [int]$CheckIntervalSeconds = 60
    )
    
    Write-Host "Surveillance des services démarrée..." -ForegroundColor Cyan
    Write-Host "Services surveillés: $($ServiceNames -join ', ')" -ForegroundColor Gray
    Write-Host "Intervalle de vérification: $CheckIntervalSeconds secondes`n"
    
    while ($true) {
        foreach ($serviceName in $ServiceNames) {
            $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
            
            if (-not $service) {
                Write-Warning "Service $serviceName introuvable"
                continue
            }
            
            if ($service.Status -ne "Running" -and $service.StartType -ne "Disabled") {
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Write-Host "[$timestamp] ⚠️  Service $serviceName est $($service.Status)" -ForegroundColor Red
                
                try {
                    Write-Host "[$timestamp] 🔄 Tentative de redémarrage..." -ForegroundColor Yellow
                    Start-Service -Name $serviceName
                    Write-Host "[$timestamp] ✅ Service $serviceName redémarré" -ForegroundColor Green
                }
                catch {
                    Write-Host "[$timestamp] ❌ Échec: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
        
        Start-Sleep -Seconds $CheckIntervalSeconds
    }
}

# Utilisation (Ctrl+C pour arrêter)
Watch-ServiceHealth -ServiceNames @("Spooler", "wuauserv") -CheckIntervalSeconds 30
```

> [!warning] Script de surveillance Ce script tourne en boucle infinie. Utilisez-le dans une session dédiée ou transformez-le en tâche planifiée pour une surveillance permanente.

---

## 🔧 Service Recovery Options

Windows permet de configurer des actions automatiques en cas d'échec de service. Ces options sont cruciales pour maintenir la disponibilité des services critiques.

### Comprendre les actions de récupération

Windows peut effectuer automatiquement jusqu'à 3 actions successives en cas d'échec :

1. **Première défaillance** : Action à effectuer lors du premier échec
2. **Deuxième défaillance** : Action si le service échoue une deuxième fois
3. **Défaillances suivantes** : Action pour tous les échecs ultérieurs

**Actions disponibles** :

- **Ne rien faire** : Aucune action automatique
- **Redémarrer le service** : Tente de redémarrer automatiquement
- **Exécuter un programme** : Lance un script ou programme personnalisé
- **Redémarrer l'ordinateur** : Redémarre le système (pour services critiques)

### Consulter les options actuelles

```powershell
# Via sc.exe (outil natif Windows)
sc.exe qfailure "Spooler"

# Via PowerShell (plus lisible)
$service = Get-CimInstance -ClassName Win32_Service -Filter "Name='Spooler'"
$service | Select-Object Name, DisplayName, State, 
    @{N="Récupération activée"; E={$_.DesktopInteract}}
```

> [!info] Limitation PowerShell `Get-Service` ne donne pas accès aux options de récupération. Il faut utiliser `sc.exe` ou `Get-CimInstance` combiné avec les API Windows.

### Configurer les actions de récupération avec sc.exe

```powershell
# Configuration complète des options de récupération
# Syntaxe : sc.exe failure "ServiceName" reset= SECONDES actions= ACTION1/ACTION2/ACTION3 delay= MILLISECONDES

# Exemple 1 : Redémarrer le service après chaque échec
sc.exe failure "Spooler" reset= 86400 actions= restart/restart/restart delay= 60000

# Paramètres :
# - reset= 86400 : Réinitialiser le compteur d'échecs après 86400 secondes (24h)
# - actions= restart/restart/restart : Redémarrer à chaque fois
# - delay= 60000 : Attendre 60000 millisecondes (1 minute) avant de redémarrer
```

> [!warning] Syntaxe critique Avec `sc.exe`, l'espace après le `=` est **OBLIGATOIRE**. `reset=86400` ne fonctionnera pas, il faut `reset= 86400`.

### Configurations types de récupération

```powershell
# Configuration 1 : Service critique (ex: pare-feu, antivirus)
# Redémarrage immédiat, puis redémarrage, puis redémarrage de l'ordinateur
sc.exe failure "MpsSvc" reset= 86400 actions= restart/restart/reboot delay= 5000
sc.exe failureflag "MpsSvc" 1  # Activer le flag de récupération

# Configuration 2 : Service standard
# Deux redémarrages, puis ne rien faire
sc.exe failure "Spooler" reset= 3600 actions= restart/restart/ delay= 60000

# Configuration 3 : Service avec script personnalisé
# Première fois : redémarrage
# Deuxième fois : exécution d'un script
# Suivantes : ne rien faire
sc.exe failure "wuauserv" reset= 7200 actions= restart/run/ delay= 30000
sc.exe failureactions "wuauserv" actions= restart/30000/run/60000//0
sc.exe failurecommand "wuauserv" "C:\Scripts\RepairWindowsUpdate.ps1"
```

### Paramètres détaillés

|Paramètre|Valeurs|Description|
|---|---|---|
|**reset=**|Secondes|Temps avant réinitialisation du compteur (0 = jamais)|
|**actions=**|restart/run/reboot/|Actions séparées par `/` (vide = aucune action)|
|**delay=**|Millisecondes|Délai avant d'exécuter l'action|
|**reboot**|-|Redémarre l'ordinateur|
|**command=**|Chemin|Programme à exécuter avec l'action `run`|

### Fonction PowerShell pour configurer la récupération

```powershell
function Set-ServiceRecovery {
    param(
        [Parameter(Mandatory)]
        [string]$ServiceName,
        
        [ValidateSet("restart", "run", "reboot", "none")]
        [string]$FirstFailure = "restart",
        
        [ValidateSet("restart", "run", "reboot", "none")]
        [string]$SecondFailure = "restart",
        
        [ValidateSet("restart", "run", "reboot", "none")]
        [string]$SubsequentFailures = "restart",
        
        [int]$DelayMilliseconds = 60000,
        
        [int]$ResetPeriodSeconds = 86400,
        
        [string]$CommandToRun = ""
    )
    
    # Construire la chaîne d'actions
    $actionMap = @{
        "restart" = "restart"
        "run" = "run"
        "reboot" = "reboot"
        "none" = ""
    }
    
    $actions = "$($actionMap[$FirstFailure])/$($actionMap[$SecondFailure])/$($actionMap[$SubsequentFailures])"
    
    # Configurer les actions
    Write-Host "Configuration des actions de récupération pour $ServiceName..." -ForegroundColor Cyan
    $result = sc.exe failure $ServiceName reset= $ResetPeriodSeconds actions= $actions delay= $DelayMilliseconds
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Configuration appliquée avec succès" -ForegroundColor Green
        
        # Si une action "run" est configurée et qu'une commande est fournie
        if (($FirstFailure -eq "run" -or $SecondFailure -eq "run" -or $SubsequentFailures -eq "run") -and $CommandToRun) {
            sc.exe failurecommand $ServiceName $CommandToRun
            Write-Host "✅ Commande de récupération définie : $CommandToRun" -ForegroundColor Green
        }
    } else {
        Write-Error "❌ Échec de la configuration (Code: $LASTEXITCODE)"
    }
}

# Exemples d'utilisation
Set-ServiceRecovery -ServiceName "Spooler" `
    -FirstFailure restart `
    -SecondFailure restart `
    -SubsequentFailures restart `
    -DelayMilliseconds 60000 `
    -ResetPeriodSeconds 86400

# Avec script personnalisé
Set-ServiceRecovery -ServiceName "wuauserv" `
    -FirstFailure restart `
    -SecondFailure run `
    -SubsequentFailures none `
    -CommandToRun "C:\Scripts\RepairService.ps1" `
    -DelayMilliseconds 30000
```

### Vérifier la configuration de récupération

```powershell
function Get-ServiceRecovery {
    param([string]$ServiceName)
    
    Write-Host "`n=== Options de récupération pour $ServiceName ===`n" -ForegroundColor Cyan
    
    # Utiliser sc.exe pour obtenir les informations
    $output = sc.exe qfailure $ServiceName
    
    # Afficher la sortie formatée
    $output | ForEach-Object {
        if ($_ -match "RESET_PERIOD") {
            $_ -replace "RESET_PERIOD", "Période de réinitialisation"
        }
        elseif ($_ -match "FAILURE_ACTIONS") {
            $_ -replace "FAILURE_ACTIONS", "Actions en cas d'échec"
        }
        elseif ($_ -match "RESTART") {
            $_ -replace "RESTART", "▶️ REDÉMARRER"
        }
        else {
            $_
        }
    } | Write-Host
}

# Utilisation
Get-ServiceRecovery -ServiceName "Spooler"
```

### Réinitialiser le compteur d'échecs

```powershell
# Le compteur d'échecs peut être réinitialisé manuellement
sc.exe failure "Spooler" reset= 0

# Ou redéfinir avec une période de réinitialisation
sc.exe failure "Spooler" reset= 86400 actions= restart/restart/restart delay= 60000
```

> [!tip] Période de réinitialisation Une période de `reset= 0` signifie que le compteur ne sera jamais réinitialisé automatiquement. Pour les services critiques, utilisez plutôt 86400 (24h) ou 604800 (7 jours).

### Script complet de configuration pour services critiques

```powershell
function Set-CriticalServiceRecovery {
    param(
        [Parameter(Mandatory)]
        [string[]]$ServiceNames
    )
    
    foreach ($serviceName in $ServiceNames) {
        Write-Host "`n🔧 Configuration de $serviceName..." -ForegroundColor Cyan
        
        # Vérifier que le service existe
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if (-not $service) {
            Write-Warning "Service $serviceName introuvable, ignoré"
            continue
        }
        
        # Configuration agressive pour services critiques
        # 1ère échec : redémarrage après 5 secondes
        # 2ème échec : redémarrage après 10 secondes
        # Échecs suivants : redémarrage après 30 secondes
        # Réinitialisation du compteur après 1 heure
        
        sc.exe failure $serviceName reset= 3600 actions= restart/restart/restart delay= 5000
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Récupération configurée" -ForegroundColor Green
            
            # Modifier les délais individuels pour chaque action
            sc.exe failure $serviceName actions= restart/5000/restart/10000/restart/30000
            Write-Host "  ✅ Délais progressifs appliqués (5s/10s/30s)" -ForegroundColor Green
        } else {
            Write-Error "  ❌ Échec de configuration pour $serviceName"
        }
    }
    
    Write-Host "`n✅ Configuration terminée pour tous les services" -ForegroundColor Green
}

# Utilisation pour services critiques
Set-CriticalServiceRecovery -ServiceNames @(
    "MpsSvc",      # Pare-feu Windows
    "WinDefend",   # Windows Defender
    "EventLog",    # Journal d'événements
    "RpcSs"        # RPC
)
```

### Désactiver les actions de récupération

```powershell
# Supprimer toutes les actions de récupération
sc.exe failure "Spooler" reset= 0 actions= // delay= 0

# Ou simplement mettre des actions vides
sc.exe failure "Spooler" actions= /// 
```

### Bonnes pratiques pour la récupération

> [!tip] Recommandations **Services critiques** :
> 
> - Utilisez `restart/restart/reboot` avec des délais courts (5-30 secondes)
> - Période de reset courte (1-6 heures)
> 
> **Services standard** :
> 
> - Utilisez `restart/restart/none` avec des délais moyens (30-60 secondes)
> - Période de reset moyenne (12-24 heures)
> 
> **Services non-critiques** :
> 
> - Utilisez `restart/none/none` ou laissez sans configuration
> - Période de reset longue (24-48 heures)

### Surveiller les récupérations automatiques

```powershell
# Consulter les événements de récupération dans les logs
Get-EventLog -LogName System -Source "Service Control Manager" -Newest 100 |
    Where-Object { $_.Message -like "*action*" -or $_.Message -like "*recovery*" } |
    Select-Object TimeGenerated, EntryType, Message |
    Format-Table -Wrap

# Créer un rapport des services qui ont été récupérés
$recoveryEvents = Get-EventLog -LogName System -After (Get-Date).AddDays(-7) |
    Where-Object { 
        $_.Source -eq "Service Control Manager" -and 
        $_.Message -like "*recovery action*"
    }

if ($recoveryEvents) {
    Write-Host "`n⚠️  Services ayant nécessité une récupération (7 derniers jours):" -ForegroundColor Yellow
    $recoveryEvents | Group-Object { 
        $_.Message -replace '.*service (.*) entered.*','$1' 
    } | Select-Object Count, Name | Sort-Object Count -Descending |
        Format-Table -AutoSize
} else {
    Write-Host "`n✅ Aucune récupération de service détectée" -ForegroundColor Green
}
```

### Configuration avancée avec messages personnalisés

```powershell
# Configurer un message de redémarrage personnalisé (pour l'action reboot)
sc.exe failure "MpsSvc" reboot= "Le service de pare-feu critique a échoué. Redémarrage du système..."

# Vérifier le message
sc.exe qfailure "MpsSvc"
```

### Tableau récapitulatif des stratégies

|Type de service|1ère échec|2ème échec|Suivants|Délai|Reset|
|---|---|---|---|---|---|
|**Critique système**|Restart|Restart|Reboot|5-10s|1h|
|**Critique métier**|Restart|Restart|Restart|30s|6h|
|**Standard**|Restart|Restart|None|60s|24h|
|**Non-critique**|Restart|None|None|120s|48h|
|**Test/Dev**|None|None|None|-|-|

> [!warning] Action Reboot L'action `reboot` redémarre l'ordinateur entier. Utilisez-la uniquement pour des services absolument critiques dont l'échec rend le système inutilisable (pare-feu, RPC, etc.).

---

## 📊 Synthèse et cas pratiques

### Scénario 1 : Audit complet d'un service

```powershell
function Get-ServiceCompleteInfo {
    param([string]$ServiceName)
    
    $service = Get-Service -Name $ServiceName
    $cimService = Get-CimInstance -ClassName Win32_Service -Filter "Name='$ServiceName'"
    
    Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║      RAPPORT COMPLET - $($service.DisplayName.PadRight(30))    ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
    
    # Informations de base
    Write-Host "📋 INFORMATIONS DE BASE" -ForegroundColor Yellow
    Write-Host "   Nom: $($service.Name)"
    Write-Host "   Affichage: $($service.DisplayName)"
    Write-Host "   État: $($service.Status)" -ForegroundColor $(
        if ($service.Status -eq "Running") { "Green" } else { "Red" }
    )
    Write-Host "   Type de démarrage: $($service.StartType)"
    Write-Host "   Peut être arrêté: $($service.CanStop)"
    Write-Host "   Peut être mis en pause: $($service.CanPauseAndContinue)"
    
    # Dépendances
    Write-Host "`n🔗 DÉPENDANCES" -ForegroundColor Yellow
    Write-Host "   Services requis: $($service.ServicesDependedOn.Count)"
    if ($service.ServicesDependedOn.Count -gt 0) {
        $service.ServicesDependedOn | ForEach-Object {
            Write-Host "      - $($_.DisplayName) [$($_.Status)]"
        }
    }
    Write-Host "   Services dépendants: $($service.DependentServices.Count)"
    if ($service.DependentServices.Count -gt 0) {
        $service.DependentServices | ForEach-Object {
            Write-Host "      - $($_.DisplayName) [$($_.Status)]"
        }
    }
    
    # Informations système
    Write-Host "`n💻 INFORMATIONS SYSTÈME" -ForegroundColor Yellow
    Write-Host "   Chemin: $($cimService.PathName)"
    Write-Host "   PID: $($cimService.ProcessId)"
    Write-Host "   Compte: $($cimService.StartName)"
    Write-Host "   Code sortie: $($cimService.ExitCode)"
    
    # Options de récupération
    Write-Host "`n🔧 OPTIONS DE RÉCUPÉRATION" -ForegroundColor Yellow
    sc.exe qfailure $ServiceName | Select-Object -Skip 3 | ForEach-Object {
        Write-Host "   $_"
    }
    
    Write-Host ""
}

# Utilisation
Get-ServiceCompleteInfo -ServiceName "Spooler"
```

### Scénario 2 : Vérification avant maintenance

```powershell
function Test-ServiceMaintenanceReadiness {
    param([string]$ServiceName)
    
    $service = Get-Service -Name $ServiceName
    $issues = @()
    
    Write-Host "`n🔍 Vérification de l'état pour maintenance de $ServiceName...`n" -ForegroundColor Cyan
    
    # Vérifier l'état actuel
    if ($service.Status -ne "Running") {
        $issues += "⚠️  Le service n'est pas en cours d'exécution"
    } else {
        Write-Host "✅ Service en cours d'exécution" -ForegroundColor Green
    }
    
    # Vérifier les services dépendants
    if ($service.DependentServices.Count -gt 0) {
        $runningDeps = $service.DependentServices | Where-Object { $_.Status -eq "Running" }
        if ($runningDeps) {
            $issues += "⚠️  $($runningDeps.Count) service(s) dépendant(s) en cours d'exécution seront arrêtés"
            $runningDeps | ForEach-Object {
                Write-Host "   - $($_.DisplayName)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "✅ Aucun service dépendant" -ForegroundColor Green
    }
    
    # Vérifier les dépendances requises
    $stoppedDeps = $service.ServicesDependedOn | Where-Object { $_.Status -ne "Running" }
    if ($stoppedDeps) {
        $issues += "⚠️  Certaines dépendances ne sont pas démarrées"
        $stoppedDeps | ForEach-Object {
            Write-Host "   - $($_.DisplayName) [$($_.Status)]" -ForegroundColor Yellow
        }
    }
    
    # Résumé
    Write-Host ""
    if ($issues.Count -eq 0) {
        Write-Host "✅ RÉSULTAT : Le service est prêt pour la maintenance" -ForegroundColor Green
        return $true
    } else {
        Write-Host "⚠️  RÉSULTAT : $($issues.Count) point(s) d'attention détecté(s)" -ForegroundColor Yellow
        $issues | ForEach-Object { Write-Host $_ }
        return $false
    }
}

# Utilisation
Test-ServiceMaintenanceReadiness -ServiceName "LanmanServer"
```

### Scénario 3 : Configuration automatique des services critiques

```powershell
# Liste des services considérés comme critiques
$criticalServices = @(
    "MpsSvc",       # Pare-feu Windows
    "WinDefend",    # Windows Defender
    "EventLog",     # Journal d'événements
    "RpcSs",        # RPC
    "Dhcp",         # Client DHCP
    "Dnscache",     # Client DNS
    "LanmanServer", # Serveur
    "LanmanWorkstation" # Station de travail
)

Write-Host "🛡️  Configuration de la haute disponibilité pour services critiques...`n" -ForegroundColor Cyan

foreach ($serviceName in $criticalServices) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    
    if ($service) {
        Write-Host "Configuration de $($service.DisplayName)..." -ForegroundColor Yellow
        
        # S'assurer que le service est en démarrage automatique
        if ($service.StartType -ne "Automatic") {
            Set-Service -Name $serviceName -StartupType Automatic
            Write-Host "  ✅ StartType modifié en Automatic" -ForegroundColor Green
        }
        
        # Configurer les options de récupération
        sc.exe failure $serviceName reset= 3600 actions= restart/restart/restart delay= 5000 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Options de récupération configurées" -ForegroundColor Green
        }
        
        # Démarrer si arrêté
        if ($service.Status -ne "Running") {
            Start-Service -Name $serviceName -ErrorAction SilentlyContinue
            Write-Host "  ✅ Service démarré" -ForegroundColor Green
        }
        
        Write-Host ""
    }
}

Write-Host "✅ Configuration terminée pour tous les services critiques`n" -ForegroundColor Green
```

---

## 🎯 Points clés à retenir

> [!info] Récapitulatif
> 
> **États de service** :
> 
> - Les états "Pending" indiquent une transition en cours
> - Utilisez `WaitForStatus()` avec timeout pour attendre les changements d'état
> - Les services bloqués en "Pending" révèlent souvent des problèmes
> 
> **Types de démarrage** :
> 
> - `Automatic` démarre au boot, `Manual` sur demande, `Disabled` ne peut pas démarrer
> - `Automatic (Delayed Start)` optimise le démarrage système
> - Adaptez le StartType à l'importance du service
> 
> **Dépendances** :
> 
> - `ServicesDependedOn` = ce dont le service a besoin pour démarrer
> - `DependentServices` = ce qui sera arrêté si on arrête ce service
> - Toujours vérifier les dépendances avant d'arrêter un service
> 
> **Récupération** :
> 
> - Configurez des actions automatiques pour les services critiques
> - Utilisez des délais progressifs (5s → 10s → 30s)
> - L'action `reboot` est à réserver aux services absolument critiques
> - Surveillez les événements de récupération dans les journaux

---

## 🔍 Commandes essentielles

```powershell
# État et type de démarrage
Get-Service -Name "NomService" | Select-Object Name, Status, StartType

# Dépendances complètes
Get-Service -Name "NomService" | Select-Object Name, ServicesDependedOn, DependentServices

# Configuration récupération (redémarrage après 1 min, reset 24h)
sc.exe failure "NomService" reset= 86400 actions= restart/restart/restart delay= 60000

# Vérification récupération
sc.exe qfailure "NomService"

# Surveiller un service
Get-Service -Name "NomService" | Format-List *

# Analyser les dépendances récursivement
$s = Get-Service -Name "NomService"
$s.ServicesDependedOn | ForEach-Object { Get-Service $_.Name | Select Name, Status }
```

---

_Ce cours couvre les aspects essentiels de la gestion des statuts et dépendances des services PowerShell. Maîtriser ces concepts est fondamental pour l'administration système Windows._