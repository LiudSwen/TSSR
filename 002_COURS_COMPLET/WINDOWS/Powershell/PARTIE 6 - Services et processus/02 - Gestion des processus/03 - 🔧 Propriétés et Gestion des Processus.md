

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

## 🏷️ Propriétés d'identification

Les propriétés d'identification permettent de localiser et reconnaître un processus de manière unique dans le système.

### Id (PID - Process Identifier)

Le PID est un **identifiant numérique unique** attribué à chaque processus au démarrage. C'est la méthode la plus fiable pour identifier un processus.

```powershell
# Obtenir le PID d'un processus
Get-Process -Name "chrome" | Select-Object Id, Name

# Accéder directement au PID avec la notation point
$process = Get-Process -Name "notepad"
$process.Id
```

> [!info] Pourquoi le PID est-il unique ? Le système d'exploitation garantit qu'aucun deux processus actifs ne partagent le même PID. Lorsqu'un processus se termine, son PID peut être réutilisé pour un nouveau processus.

### Name et ProcessName

Ces deux propriétés contiennent le nom du processus, **sans l'extension .exe**.

```powershell
# Name et ProcessName sont identiques
Get-Process | Select-Object Name, ProcessName | Format-Table

# Filtrer par nom
Get-Process -Name "explorer"
```

> [!tip] Astuce Utilisez `Name` ou `ProcessName` indifféremment - ils retournent la même valeur. `Name` est plus court et donc préféré.

### Path (chemin complet)

La propriété `Path` contient le **chemin absolu** de l'exécutable du processus.

```powershell
# Obtenir le chemin d'exécution
Get-Process -Name "chrome" | Select-Object Name, Path

# Vérifier l'emplacement d'un processus
$proc = Get-Process -Name "svchost" | Select-Object -First 1
$proc.Path
```

> [!warning] Attention aux processus système Certains processus système (comme `svchost`, `System`) peuvent avoir une propriété `Path` vide ou `$null`. Cela est normal pour les processus kernel.

```powershell
# Filtrer uniquement les processus avec un chemin valide
Get-Process | Where-Object { $_.Path } | Select-Object Name, Path
```

---

## 💾 Propriétés de ressources système

Ces propriétés permettent de **monitorer la consommation de ressources** par les processus. Elles sont essentielles pour diagnostiquer les problèmes de performance.

### CPU (temps processeur)

La propriété `CPU` représente le **temps total processeur** utilisé par le processus depuis son démarrage, exprimé en secondes.

```powershell
# Afficher le temps CPU utilisé
Get-Process | Select-Object Name, CPU | Sort-Object CPU -Descending

# Temps CPU formaté
Get-Process | Select-Object Name, @{Name="CPU(s)";Expression={[math]::Round($_.CPU, 2)}}
```

> [!info] Comprendre le temps CPU Un processus avec CPU = 120 signifie qu'il a utilisé 120 secondes de temps processeur. Sur un système multi-cœurs, ce temps peut s'accumuler plus rapidement.

### WorkingSet / WS (mémoire physique)

Le `WorkingSet` représente la **quantité de mémoire RAM physique** actuellement utilisée par le processus, en octets.

```powershell
# Afficher la mémoire en octets
Get-Process | Select-Object Name, WorkingSet

# Convertir en Mo (plus lisible)
Get-Process | Select-Object Name, @{Name="Mémoire(Mo)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}

# Alternative courte : WS
Get-Process | Select-Object Name, WS
```

> [!tip] Conversion en unités lisibles La mémoire est toujours exprimée en octets. Divisez par 1KB, 1MB ou 1GB pour une lecture facile.

### VirtualMemorySize / VM (mémoire virtuelle)

La propriété `VirtualMemorySize` indique la **quantité de mémoire virtuelle** allouée au processus (RAM + fichier d'échange).

```powershell
# Comparer mémoire physique et virtuelle
Get-Process | Select-Object Name, 
    @{Name="RAM(Mo)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}},
    @{Name="Virtuelle(Mo)";Expression={[math]::Round($_.VirtualMemorySize / 1MB, 2)}}
```

> [!info] Mémoire physique vs virtuelle
> 
> - **WorkingSet (RAM)** : mémoire réellement présente dans la RAM
> - **VirtualMemory** : mémoire totale (RAM + swap/pagefile)
> 
> Un processus peut avoir beaucoup de mémoire virtuelle mais peu de mémoire physique si une partie est "swappée" sur le disque.

### PrivateMemorySize / PM (mémoire privée)

La mémoire privée est la **quantité de mémoire utilisée exclusivement** par ce processus, non partagée avec d'autres.

```powershell
# Afficher la mémoire privée
Get-Process | Select-Object Name, @{Name="Privée(Mo)";Expression={[math]::Round($_.PrivateMemorySize / 1MB, 2)}}
```

### PagedMemorySize et NonpagedSystemMemorySize (NPM)

- **PagedMemorySize** : mémoire qui peut être déplacée vers le fichier d'échange
- **NonpagedSystemMemorySize** : mémoire qui doit **toujours rester en RAM** (critique)

```powershell
# Afficher les deux types de mémoire
Get-Process | Select-Object Name,
    @{Name="Paged(Ko)";Expression={[math]::Round($_.PagedMemorySize / 1KB, 2)}},
    @{Name="NonPaged(Ko)";Expression={[math]::Round($_.NonpagedSystemMemorySize / 1KB, 2)}}
```

> [!info] Quand surveiller la NonPaged Memory ? Une consommation élevée de NonPaged Memory peut indiquer un driver défectueux ou une fuite mémoire kernel. Cette mémoire ne peut pas être swappée et réduit la RAM disponible.

### Tableau comparatif des propriétés mémoire

|Propriété|Alias|Description|Peut être swappée ?|
|---|---|---|---|
|WorkingSet|WS|RAM physique actuellement utilisée|Partiellement|
|VirtualMemorySize|VM|Total RAM + swap alloué|Oui|
|PrivateMemorySize|PM|Mémoire exclusive au processus|Oui|
|PagedMemorySize|-|Mémoire pouvant aller sur disque|Oui|
|NonpagedSystemMemorySize|NPM|Mémoire devant rester en RAM|Non|

---

## ⏱️ Propriétés temporelles

Les propriétés temporelles permettent de **suivre l'activité dans le temps** et identifier depuis combien de temps un processus tourne.

### StartTime (heure de démarrage)

La propriété `StartTime` contient la **date et heure exactes** du démarrage du processus.

```powershell
# Afficher l'heure de démarrage
Get-Process | Select-Object Name, StartTime

# Calculer depuis combien de temps le processus tourne
Get-Process | Select-Object Name, StartTime, 
    @{Name="Durée";Expression={(Get-Date) - $_.StartTime}}

# Format plus lisible de la durée
Get-Process | Select-Object Name, 
    @{Name="Actif depuis";Expression={
        $uptime = (Get-Date) - $_.StartTime
        "{0}j {1}h {2}min" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
    }}
```

> [!warning] Processus système sans StartTime Certains processus système critiques (comme `Idle` ou `System`) n'ont pas de `StartTime` défini car ils démarrent avec le kernel.

### TotalProcessorTime

Le temps processeur **total cumulé** depuis le démarrage du processus.

```powershell
# Afficher le temps processeur total
Get-Process | Select-Object Name, TotalProcessorTime

# Format lisible
Get-Process | Select-Object Name,
    @{Name="TempsCPU";Expression={
        "{0:D2}:{1:D2}:{2:D2}" -f $_.TotalProcessorTime.Hours, 
                                   $_.TotalProcessorTime.Minutes, 
                                   $_.TotalProcessorTime.Seconds
    }}
```

### UserProcessorTime

Le temps processeur utilisé en **mode utilisateur** (par opposition au mode kernel).

```powershell
# Comparer temps utilisateur et temps total
Get-Process | Select-Object Name,
    @{Name="User(s)";Expression={[math]::Round($_.UserProcessorTime.TotalSeconds, 2)}},
    @{Name="Total(s)";Expression={[math]::Round($_.TotalProcessorTime.TotalSeconds, 2)}}
```

> [!info] Mode utilisateur vs mode kernel
> 
> - **UserProcessorTime** : temps passé à exécuter le code de l'application
> - **PrivilegedProcessorTime** : temps passé à exécuter du code système (kernel)
> - **TotalProcessorTime** = User + Privileged

---

## 📊 Autres propriétés utiles

### Handles (nombre de handles)

Un handle est une **référence vers une ressource système** (fichier, clé de registre, socket, etc.).

```powershell
# Afficher le nombre de handles
Get-Process | Select-Object Name, Handles | Sort-Object Handles -Descending

# Identifier les processus avec beaucoup de handles
Get-Process | Where-Object { $_.Handles -gt 1000 } | 
    Select-Object Name, Handles, WorkingSet
```

> [!warning] Fuite de handles Un nombre croissant de handles au fil du temps peut indiquer une **fuite de ressources** (resource leak) dans l'application.

### Threads (nombre de threads)

Le nombre de **threads d'exécution** actifs dans le processus.

```powershell
# Afficher le nombre de threads
Get-Process | Select-Object Name, Threads

# Processus multi-threadés
Get-Process | Where-Object { $_.Threads.Count -gt 50 } |
    Select-Object Name, @{Name="NbThreads";Expression={$_.Threads.Count}}
```

> [!info] Performance et threads Plus un processus a de threads, plus il peut traiter d'opérations en parallèle. Mais trop de threads peut causer des problèmes de contention et réduire les performances.

### MainWindowTitle

Le titre de la **fenêtre principale** du processus (vide si pas d'interface graphique).

```powershell
# Afficher les fenêtres ouvertes
Get-Process | Where-Object { $_.MainWindowTitle } | 
    Select-Object Name, MainWindowTitle

# Trouver une fenêtre spécifique
Get-Process | Where-Object { $_.MainWindowTitle -like "*Chrome*" }
```

> [!tip] Automatisation d'interface Utilisez `MainWindowTitle` pour identifier et manipuler des fenêtres spécifiques dans vos scripts.

### Company, Product, ProductVersion

Métadonnées de l'exécutable (si définies dans les propriétés du fichier).

```powershell
# Afficher les informations produit
Get-Process | Select-Object Name, Company, Product, ProductVersion | 
    Where-Object { $_.Company } | Format-Table

# Identifier tous les processus Microsoft
Get-Process | Where-Object { $_.Company -like "*Microsoft*" }
```

### PriorityClass (priorité)

La **classe de priorité** du processus détermine l'allocation de temps CPU.

```powershell
# Afficher les priorités
Get-Process | Select-Object Name, PriorityClass

# Filtrer par priorité
Get-Process | Where-Object { $_.PriorityClass -eq "High" }
```

Les classes de priorité disponibles :

- `Idle` : priorité la plus basse
- `BelowNormal`
- `Normal` : priorité par défaut
- `AboveNormal`
- `High`
- `RealTime` : priorité maximale (réservé au système)

> [!warning] Modifier la priorité avec précaution Modifier la priorité d'un processus peut affecter la stabilité du système. La priorité `RealTime` est déconseillée pour les applications utilisateur.

---

## 🔨 Méthodes des objets processus

Les objets processus possèdent des **méthodes** permettant d'interagir avec eux directement.

### .Kill() - Terminer un processus

La méthode `Kill()` **force l'arrêt immédiat** du processus.

```powershell
# Méthode 1 : Utiliser Kill()
$process = Get-Process -Name "notepad"
$process.Kill()

# Méthode 2 : Via le pipe
Get-Process -Name "notepad" | ForEach-Object { $_.Kill() }

# Terminer plusieurs instances
Get-Process -Name "chrome" | ForEach-Object { $_.Kill() }
```

> [!warning] Kill() vs Stop-Process
> 
> - `Kill()` : arrêt brutal, **aucune sauvegarde**, données potentiellement perdues
> - `Stop-Process` : peut être plus contrôlé avec des paramètres
> 
> Utilisez `Kill()` uniquement pour les processus qui ne répondent plus.

### .WaitForExit() - Attendre la fin

La méthode `WaitForExit()` **bloque l'exécution** jusqu'à ce que le processus se termine.

```powershell
# Démarrer un processus et attendre sa fin
$process = Start-Process "notepad.exe" -PassThru
Write-Host "Processus démarré, en attente..."
$process.WaitForExit()
Write-Host "Processus terminé !"

# Attendre avec timeout (en millisecondes)
$process = Start-Process "notepad.exe" -PassThru
if ($process.WaitForExit(5000)) {
    Write-Host "Processus terminé dans les 5 secondes"
} else {
    Write-Host "Timeout : processus toujours actif"
    $process.Kill()
}
```

> [!tip] Utilisation dans les scripts `WaitForExit()` est essentiel pour synchroniser des scripts qui lancent des programmes externes et doivent attendre leur complétion.

### .CloseMainWindow() - Fermeture propre

La méthode `CloseMainWindow()` envoie un message de fermeture à la fenêtre, permettant au processus de **sauvegarder et se terminer proprement**.

```powershell
# Fermeture propre d'une application
$process = Get-Process -Name "notepad"
$process.CloseMainWindow()

# Vérifier si la fermeture a réussi
if ($process.CloseMainWindow()) {
    Write-Host "Fenêtre fermée avec succès"
    $process.WaitForExit(5000)
} else {
    Write-Host "Impossible de fermer la fenêtre, utilisation de Kill()"
    $process.Kill()
}
```

> [!info] Différence entre CloseMainWindow() et Kill()
> 
> - **CloseMainWindow()** : demande polie de fermeture, l'application peut sauvegarder
> - **Kill()** : arrêt forcé, aucune sauvegarde possible
> 
> Tentez toujours `CloseMainWindow()` en premier, et utilisez `Kill()` seulement si nécessaire.

```powershell
# Pattern de fermeture sécurisée
$process = Get-Process -Name "notepad"
if (-not $process.CloseMainWindow()) {
    Start-Sleep -Seconds 2
    if (-not $process.HasExited) {
        $process.Kill()
    }
}
```

---

## 📈 Surveillance de performance

La surveillance de performance permet d'observer l'évolution des ressources en temps réel.

### Surveillance continue

```powershell
# Surveiller un processus spécifique en boucle
while ($true) {
    $proc = Get-Process -Name "chrome" -ErrorAction SilentlyContinue
    if ($proc) {
        Clear-Host
        $proc | Select-Object Name, 
            @{Name="CPU(s)";Expression={[math]::Round($_.CPU, 2)}},
            @{Name="RAM(Mo)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}},
            Handles, Threads | Format-Table
    }
    Start-Sleep -Seconds 2
}
```

### Surveillance avec historique

```powershell
# Collecter des données sur 30 secondes
$samples = @()
for ($i = 0; $i -lt 10; $i++) {
    $proc = Get-Process -Name "chrome" -ErrorAction SilentlyContinue
    if ($proc) {
        $samples += [PSCustomObject]@{
            Time = Get-Date -Format "HH:mm:ss"
            CPU = [math]::Round($proc.CPU, 2)
            RAM_Mo = [math]::Round($proc.WorkingSet / 1MB, 2)
        }
    }
    Start-Sleep -Seconds 3
}
$samples | Format-Table
```

### Surveiller plusieurs processus

```powershell
# Dashboard de surveillance
function Show-ProcessDashboard {
    param([string[]]$ProcessNames)
    
    while ($true) {
        Clear-Host
        Write-Host "=== Dashboard de surveillance ===" -ForegroundColor Cyan
        Write-Host "Appuyez sur Ctrl+C pour quitter`n"
        
        foreach ($name in $ProcessNames) {
            $procs = Get-Process -Name $name -ErrorAction SilentlyContinue
            if ($procs) {
                Write-Host ">>> $name :" -ForegroundColor Yellow
                $procs | Select-Object Id,
                    @{Name="CPU(s)";Expression={[math]::Round($_.CPU, 2)}},
                    @{Name="RAM(Mo)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}},
                    Handles | Format-Table
            }
        }
        Start-Sleep -Seconds 3
    }
}

# Utilisation
Show-ProcessDashboard -ProcessNames "chrome", "code", "firefox"
```

> [!tip] Surveillance avancée Pour une surveillance plus avancée et visuelle, utilisez `Performance Monitor` (perfmon.exe) ou des outils comme `Process Explorer`.

---

## 🔍 Identification de processus gourmands

Identifier rapidement les processus qui consomment le plus de ressources est crucial pour diagnostiquer les problèmes de performance.

### Top processus par CPU

```powershell
# Top 10 processus CPU
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 |
    Select-Object Name, Id,
        @{Name="CPU(s)";Expression={[math]::Round($_.CPU, 2)}},
        @{Name="RAM(Mo)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}} |
    Format-Table

# Processus utilisant plus de X secondes de CPU
$seuil = 60
Get-Process | Where-Object { $_.CPU -gt $seuil } |
    Sort-Object CPU -Descending |
    Select-Object Name, Id, @{Name="CPU(s)";Expression={[math]::Round($_.CPU, 2)}}
```

### Top processus par mémoire

```powershell
# Top 10 processus RAM
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 |
    Select-Object Name, Id,
        @{Name="RAM(Mo)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}},
        @{Name="RAM(%)";Expression={
            [math]::Round(($_.WorkingSet / (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory) * 100, 2)
        }} |
    Format-Table

# Processus utilisant plus de X Mo de RAM
$seuilMo = 500
Get-Process | Where-Object { ($_.WorkingSet / 1MB) -gt $seuilMo } |
    Sort-Object WorkingSet -Descending |
    Select-Object Name, @{Name="RAM(Mo)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}
```

### Analyse combinée des ressources

```powershell
# Identifier les processus problématiques (CPU + RAM élevés)
Get-Process | 
    Select-Object Name, Id,
        @{Name="CPU(s)";Expression={[math]::Round($_.CPU, 2)}},
        @{Name="RAM(Mo)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}},
        @{Name="Score";Expression={
            # Score combiné : CPU + RAM
            $cpu = if ($_.CPU) { $_.CPU } else { 0 }
            $ram = $_.WorkingSet / 1MB
            [math]::Round($cpu + $ram, 2)
        }} |
    Sort-Object Score -Descending |
    Select-Object -First 15 |
    Format-Table
```

### Rapport complet de ressources

```powershell
# Fonction d'analyse complète
function Get-ProcessResourceReport {
    param(
        [int]$TopCount = 10
    )
    
    $totalRAM = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
    
    Write-Host "`n=== Rapport d'utilisation des ressources ===" -ForegroundColor Cyan
    Write-Host "RAM totale : $([math]::Round($totalRAM, 2)) Go`n" -ForegroundColor Green
    
    # Top CPU
    Write-Host ">>> TOP $TopCount - Utilisation CPU :" -ForegroundColor Yellow
    Get-Process | Sort-Object CPU -Descending | Select-Object -First $TopCount |
        Select-Object Name, @{Name="CPU(s)";Expression={[math]::Round($_.CPU, 2)}} |
        Format-Table
    
    # Top RAM
    Write-Host ">>> TOP $TopCount - Utilisation RAM :" -ForegroundColor Yellow
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First $TopCount |
        Select-Object Name, 
            @{Name="RAM(Mo)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}},
            @{Name="RAM(%)";Expression={[math]::Round(($_.WorkingSet / 1GB / $totalRAM) * 100, 2)}} |
        Format-Table
    
    # Top Handles
    Write-Host ">>> TOP $TopCount - Nombre de Handles :" -ForegroundColor Yellow
    Get-Process | Sort-Object Handles -Descending | Select-Object -First $TopCount |
        Select-Object Name, Handles |
        Format-Table
}

# Utilisation
Get-ProcessResourceReport -TopCount 5
```

### Alertes sur seuils

```powershell
# Script de surveillance avec alertes
function Watch-ProcessThresholds {
    param(
        [int]$CPUThreshold = 60,      # secondes
        [int]$RAMThresholdMB = 1000,  # Mo
        [int]$CheckIntervalSec = 5
    )
    
    Write-Host "Surveillance active - Seuils : CPU > $CPUThreshold s, RAM > $RAMThresholdMB Mo" -ForegroundColor Green
    
    while ($true) {
        $alerts = Get-Process | Where-Object {
            $_.CPU -gt $CPUThreshold -or ($_.WorkingSet / 1MB) -gt $RAMThresholdMB
        }
        
        if ($alerts) {
            Clear-Host
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ALERTES DÉTECTÉES :" -ForegroundColor Red
            $alerts | Select-Object Name, Id,
                @{Name="CPU(s)";Expression={[math]::Round($_.CPU, 2)}},
                @{Name="RAM(Mo)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}} |
                Format-Table
        }
        
        Start-Sleep -Seconds $CheckIntervalSec
    }
}

# Utilisation
Watch-ProcessThresholds -CPUThreshold 30 -RAMThresholdMB 500
```

### Recherche de fuites mémoire

```powershell
# Détecter une augmentation continue de mémoire
function Test-MemoryLeak {
    param(
        [string]$ProcessName,
        [int]$DurationMinutes = 5,
        [int]$SampleIntervalSec = 30
    )
    
    $samples = @()
    $iterations = ($DurationMinutes * 60) / $SampleIntervalSec
    
    Write-Host "Surveillance de '$ProcessName' pendant $DurationMinutes minutes..." -ForegroundColor Cyan
    
    for ($i = 0; $i -lt $iterations; $i++) {
        $proc = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if ($proc) {
            $samples += [PSCustomObject]@{
                Time = Get-Date
                RAMMo = [math]::Round($proc.WorkingSet / 1MB, 2)
            }
            Write-Host "[$i/$iterations] RAM : $($samples[-1].RAMMo) Mo"
        }
        Start-Sleep -Seconds $SampleIntervalSec
    }
    
    # Analyse de tendance
    if ($samples.Count -gt 2) {
        $first = $samples[0].RAMMo
        $last = $samples[-1].RAMMo
        $increase = $last - $first
        $percentIncrease = ($increase / $first) * 100
        
        Write-Host "`n=== Résultats ===" -ForegroundColor Yellow
        Write-Host "RAM initiale : $first Mo"
        Write-Host "RAM finale : $last Mo"
        Write-Host "Augmentation : $([math]::Round($increase, 2)) Mo ($([math]::Round($percentIncrease, 2))%)"
        
        if ($percentIncrease -gt 20) {
            Write-Host "ALERTE : Fuite mémoire potentielle détectée !" -ForegroundColor Red
        }
    }
}

# Utilisation
Test-MemoryLeak -ProcessName "chrome" -DurationMinutes 3
```

> [!tip] Bonnes pratiques de surveillance
> 
> - Surveillez régulièrement les processus critiques pour votre application
> - Établissez des baselines (valeurs normales) pour vos processus
> - Automatisez la collecte de métriques pour analyse historique
> - Utilisez des seuils d'alerte adaptés à votre environnement

> [!warning] Performance de la surveillance La surveillance elle-même consomme des ressources. Évitez les intervalles trop courts (< 1 seconde) et limitez le nombre de processus surveillés simultanément.

---

## 📝 Pièges courants et bonnes pratiques

### Piège 1 : Propriétés NULL

```powershell
# ❌ Mauvais : peut causer une erreur
Get-Process | Where-Object { $_.CPU -gt 10 }

# ✅ Bon : gérer les valeurs NULL
Get-Process | Where-Object { $_.CPU -and $_.CPU -gt 10 }
```

### Piège 2 : Unités de mesure

```powershell
# ❌ Mauvais : difficile à lire
Get-Process | Select-Object Name, WorkingSet

# ✅ Bon : convertir en unités lisibles
Get-Process | Select-Object Name, 
    @{Name="RAM(Mo)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}
```

### Piège 3 : Accès aux processus protégés

```powershell
# ❌ Erreur : accès refusé aux processus système
Get-Process -Id 4 | Select-Object Path

# ✅ Bon : gérer les erreurs
Get-Process -Id 4 -ErrorAction SilentlyContinue | 
    Select-Object Name, Path
```

### Bonnes pratiques générales

1. **Toujours utiliser -ErrorAction** pour gérer les processus qui peuvent se terminer pendant l'exécution
2. **Formater les données** pour une meilleure lisibilité (conversions Mo/Go)
3. **Documenter les seuils** utilisés dans vos scripts de surveillance
4. **Préférer CloseMainWindow() à Kill()** pour une fermeture propre
5. **Tester les scripts** sur des processus non critiques avant utilisation en production