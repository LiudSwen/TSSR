
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

## 🎯 Introduction à la gestion des processus {#introduction}

> [!info] Qu'est-ce qu'un processus ? Un processus est une instance d'un programme en cours d'exécution. Chaque application lancée sur votre système crée un ou plusieurs processus. PowerShell permet de consulter, surveiller et gérer ces processus de manière programmatique.

**Pourquoi gérer les processus ?**

- Surveiller l'utilisation des ressources système (CPU, mémoire)
- Identifier les applications qui ralentissent le système
- Automatiser l'arrêt de processus problématiques
- Obtenir des informations détaillées sur les applications en cours
- Créer des scripts de monitoring et d'administration

---

## 📊 Get-Process - Consultation des processus {#get-process}

`Get-Process` est la cmdlet fondamentale pour obtenir des informations sur les processus en cours d'exécution.

### 📝 Lister tous les processus {#lister-processus}

```powershell
# Obtenir tous les processus en cours
Get-Process

# Affichage formaté en tableau
Get-Process | Format-Table -AutoSize

# Affichage formaté en liste pour plus de détails
Get-Process | Format-List
```

> [!example] Exemple de sortie
> 
> ```
> Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
> -------  ------    -----      -----     ------     --  -- -----------
>     459      18     2088       5344       0.23   1234   1 chrome
>     234      12     1456       3890       0.15   5678   1 explorer
>     156       8      892       2134       0.05   9012   0 svchost
> ```

> [!tip] Astuce de lisibilité Utilisez `Format-Table -AutoSize` pour adapter automatiquement la largeur des colonnes au contenu.

### 🔍 Filtrage par nom {#filtrage-nom}

```powershell
# Obtenir un processus spécifique par nom
Get-Process -Name "chrome"

# Plusieurs processus (sans guillemets ni extension)
Get-Process -Name chrome, firefox, edge

# Utilisation de wildcards (caractères génériques)
Get-Process -Name "chrome*"
Get-Process -Name "*host"

# Filtrage avec Where-Object (plus flexible)
Get-Process | Where-Object {$_.Name -like "svc*"}
```

> [!warning] Pièges courants
> 
> - Ne pas inclure l'extension `.exe` dans le nom
> - Les noms de processus sont sensibles à la casse sur certains systèmes
> - Un même programme peut avoir plusieurs processus (ex: Chrome avec onglets multiples)

```powershell
# ❌ Incorrect
Get-Process -Name "chrome.exe"

# ✅ Correct
Get-Process -Name "chrome"
```

### 🔢 Filtrage par ID {#filtrage-id}

```powershell
# Obtenir un processus par son ID (PID)
Get-Process -Id 1234

# Plusieurs processus par ID
Get-Process -Id 1234, 5678, 9012

# Combiner avec d'autres commandes
$pids = 1234, 5678
Get-Process -Id $pids
```

> [!info] Quand utiliser l'ID ? L'ID de processus (PID) est unique à un moment donné. C'est utile quand :
> 
> - Plusieurs processus ont le même nom
> - Vous devez cibler précisément une instance
> - Vous automatisez des scripts basés sur des événements système

```powershell
# Exemple pratique : obtenir le PID d'un processus puis l'utiliser
$chrome = Get-Process -Name chrome | Select-Object -First 1
Get-Process -Id $chrome.Id
```

### 📦 Propriétés des objets processus {#proprietes}

Chaque objet processus retourné par `Get-Process` contient de nombreuses propriétés exploitables.

#### Propriétés principales

|Propriété|Description|Type|
|---|---|---|
|`Id`|Identifiant unique du processus (PID)|Int32|
|`Name`|Nom du processus (sans .exe)|String|
|`CPU`|Temps CPU total utilisé (en secondes)|Double|
|`WorkingSet`|Mémoire physique utilisée (en octets)|Int64|
|`StartTime`|Date et heure de démarrage|DateTime|
|`Path`|Chemin complet de l'exécutable|String|
|`Company`|Nom de l'entreprise (métadonnées)|String|

```powershell
# Afficher toutes les propriétés disponibles
Get-Process | Get-Member -MemberType Property

# Sélectionner des propriétés spécifiques
Get-Process | Select-Object Id, Name, CPU, WorkingSet

# Afficher les propriétés avec calculs personnalisés
Get-Process | Select-Object Name, 
    @{Name="CPU(s)"; Expression={$_.CPU}},
    @{Name="Mem(MB)"; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}
```

#### Propriétés de ressources détaillées

```powershell
# Handles : nombre de descripteurs système
Get-Process | Select-Object Name, Handles | Sort-Object Handles -Descending

# Threads : nombre de threads d'exécution
Get-Process | Select-Object Name, Threads | Sort-Object Threads -Descending

# NPM (Non-Paged Memory) : mémoire non paginable en Ko
Get-Process | Select-Object Name, NPM | Sort-Object NPM -Descending

# PM (Paged Memory) : mémoire paginable en Ko
Get-Process | Select-Object Name, PM | Sort-Object PM -Descending

# WS (Working Set) : ensemble de travail (mémoire physique) en Ko
Get-Process | Select-Object Name, WS | Sort-Object WS -Descending

# VM (Virtual Memory) : mémoire virtuelle en Ko
Get-Process | Select-Object Name, VM | Sort-Object VM -Descending
```

> [!info] Comprendre les métriques mémoire
> 
> - **WorkingSet (WS)** : Mémoire physique (RAM) actuellement utilisée
> - **Paged Memory (PM)** : Mémoire pouvant être transférée sur disque
> - **Non-Paged Memory (NPM)** : Mémoire toujours en RAM (critique)
> - **Virtual Memory (VM)** : Espace d'adressage total (RAM + fichier d'échange)

#### Propriétés temporelles et d'identification

```powershell
# StartTime : quand le processus a démarré
Get-Process | Where-Object {$_.StartTime} | 
    Select-Object Name, StartTime | 
    Sort-Object StartTime -Descending

# Calculer le temps d'exécution
Get-Process | Where-Object {$_.StartTime} | 
    Select-Object Name, 
    @{Name="Uptime"; Expression={(Get-Date) - $_.StartTime}}

# Path : chemin de l'exécutable
Get-Process | Where-Object {$_.Path} | 
    Select-Object Name, Path

# Company : informations de l'éditeur
Get-Process | Where-Object {$_.Company} | 
    Select-Object Name, Company | 
    Sort-Object Company
```

> [!warning] Propriétés potentiellement nulles Certaines propriétés peuvent être `$null` ou inaccessibles :
> 
> - `StartTime` : peut être absent pour les processus système
> - `Path` : inaccessible pour certains processus protégés
> - `Company` : dépend des métadonnées de l'exécutable

```powershell
# Filtrer les processus avec Path disponible
Get-Process | Where-Object {$_.Path -ne $null}

# Gérer les valeurs nulles avec prudence
Get-Process | ForEach-Object {
    if ($_.StartTime) {
        "$($_.Name) started at $($_.StartTime)"
    }
}
```

### 👤 Processus pour utilisateur spécifique {#processus-utilisateur}

```powershell
# Obtenir le propriétaire de chaque processus (nécessite WMI)
Get-Process | ForEach-Object {
    $owner = (Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)").GetOwner()
    [PSCustomObject]@{
        Name = $_.Name
        Id = $_.Id
        Owner = "$($owner.Domain)\$($owner.User)"
    }
}

# Version simplifiée avec filtrage
$username = $env:USERNAME
Get-WmiObject Win32_Process | 
    Where-Object {(($_.GetOwner()).User) -eq $username} | 
    Select-Object ProcessId, Name
```

> [!info] Combinaison Get-Process et WMI `Get-Process` ne fournit pas directement l'utilisateur propriétaire. Il faut combiner avec `Get-WmiObject Win32_Process` pour obtenir cette information.

```powershell
# Fonction réutilisable pour obtenir les processus d'un utilisateur
function Get-UserProcess {
    param([string]$UserName)
    
    Get-WmiObject Win32_Process | 
        Where-Object {(($_.GetOwner()).User) -eq $UserName} |
        ForEach-Object {
            Get-Process -Id $_.ProcessId -ErrorAction SilentlyContinue
        }
}

# Utilisation
Get-UserProcess -UserName "john.doe"
```

### 📈 Tri par utilisation des ressources {#tri-ressources}

```powershell
# Top 10 processus par utilisation CPU
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, Id

# Top 10 processus par utilisation mémoire (WorkingSet)
Get-Process | Sort-Object WorkingSet -Descending | 
    Select-Object -First 10 Name, 
    @{Name="Mem(MB)"; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}

# Top 10 processus par nombre de handles
Get-Process | Sort-Object Handles -Descending | 
    Select-Object -First 10 Name, Handles, Id

# Top 10 processus par nombre de threads
Get-Process | Sort-Object Threads -Descending | 
    Select-Object -First 10 Name, Threads, Id
```

> [!tip] Monitoring continu Créez un script de surveillance qui s'exécute périodiquement :

```powershell
# Script de monitoring (boucle infinie avec pause)
while ($true) {
    Clear-Host
    Write-Host "=== Top 5 Processus CPU ===" -ForegroundColor Green
    Get-Process | Sort-Object CPU -Descending | 
        Select-Object -First 5 Name, 
        @{Name="CPU(s)"; Expression={[math]::Round($_.CPU, 2)}}, 
        @{Name="Mem(MB)"; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}
    
    Write-Host "`n=== Top 5 Processus Mémoire ===" -ForegroundColor Cyan
    Get-Process | Sort-Object WorkingSet -Descending | 
        Select-Object -First 5 Name, 
        @{Name="Mem(MB)"; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}
    
    Start-Sleep -Seconds 5
}
```

> [!example] Exporter les données pour analyse
> 
> ```powershell
> # Export CSV pour analyse ultérieure
> Get-Process | Select-Object Name, Id, CPU, WorkingSet, Handles | 
>     Export-Csv -Path "processus_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation
> 
> # Export JSON
> Get-Process | Select-Object Name, Id, CPU, WorkingSet | 
>     ConvertTo-Json | Out-File "processus.json"
> ```

### 🧩 Modules chargés {#modules-charges}

```powershell
# Lister tous les modules chargés par un processus
Get-Process -Name "chrome" -Module

# Filtrer les modules par nom
Get-Process -Name "explorer" -Module | Where-Object {$_.ModuleName -like "*shell*"}

# Obtenir le chemin des DLL chargées
Get-Process -Id 1234 -Module | Select-Object ModuleName, FileName

# Compter le nombre de modules chargés
(Get-Process -Name "chrome" -Module).Count
```

> [!info] Qu'est-ce qu'un module ? Les modules sont les DLL (Dynamic Link Libraries) et fichiers exécutables chargés en mémoire par un processus. Ils fournissent des fonctionnalités supplémentaires au programme.

```powershell
# Analyser les modules d'un processus
$process = Get-Process -Name "notepad" -Module
$process | Group-Object Company | Select-Object Count, Name

# Identifier les modules Microsoft vs tiers
Get-Process -Name "chrome" -Module | 
    Select-Object ModuleName, Company | 
    Group-Object Company | 
    Sort-Object Count -Descending
```

> [!warning] Permissions requises L'accès aux modules peut nécessiter des privilèges élevés pour certains processus système. Exécutez PowerShell en tant qu'administrateur si nécessaire.

```powershell
# Gestion des erreurs pour processus protégés
try {
    Get-Process -Name "csrss" -Module -ErrorAction Stop
} catch {
    Write-Warning "Impossible d'accéder aux modules : privilèges insuffisants"
}
```

### 📄 Informations de version de fichier {#version-info}

```powershell
# Obtenir les informations de version du fichier exécutable
Get-Process -Name "notepad" -FileVersionInfo

# Propriétés spécifiques de version
Get-Process -Name "chrome" -FileVersionInfo | 
    Select-Object FileName, FileVersion, ProductVersion, CompanyName

# Version pour plusieurs processus
Get-Process chrome, firefox, edge -FileVersionInfo -ErrorAction SilentlyContinue | 
    Select-Object ProcessName, FileVersion, ProductVersion
```

> [!example] Propriétés FileVersionInfo disponibles
> 
> - `FileName` : Chemin complet du fichier
> - `FileVersion` : Version du fichier
> - `ProductVersion` : Version du produit
> - `FileDescription` : Description
> - `CompanyName` : Nom de la société
> - `LegalCopyright` : Informations de copyright
> - `OriginalFilename` : Nom original du fichier

```powershell
# Créer un rapport de versions installées
Get-Process | 
    Where-Object {$_.Path} | 
    ForEach-Object {
        try {
            $version = $_ | Select-Object -ExpandProperty FileVersionInfo -ErrorAction Stop
            [PSCustomObject]@{
                Process = $_.Name
                Version = $version.FileVersion
                Company = $version.CompanyName
                Path = $version.FileName
            }
        } catch {
            # Ignorer les processus sans info de version
        }
    } | Sort-Object Process -Unique
```

> [!tip] Vérifier les versions obsolètes Utilisez cette technique pour identifier les applications nécessitant des mises à jour :

```powershell
# Comparer les versions de Chrome installées
Get-Process -Name "chrome" -FileVersionInfo | 
    Select-Object -Unique FileVersion | 
    ForEach-Object {
        Write-Host "Version Chrome détectée : $($_.FileVersion)"
    }
```

---

## 🛑 Stop-Process - Arrêt des processus {#stop-process}

`Stop-Process` permet de terminer un ou plusieurs processus en cours d'exécution.

### ⚡ Arrêt basique {#arret-basique}

```powershell
# Arrêter un processus par nom
Stop-Process -Name "notepad"

# Arrêter un processus par ID
Stop-Process -Id 1234

# Arrêter tous les processus d'un même nom
Stop-Process -Name "chrome"
```

> [!warning] Arrêt immédiat `Stop-Process` termine le processus immédiatement sans sauvegarder les données non enregistrées. C'est l'équivalent de "Terminer la tâche" dans le Gestionnaire des tâches.

```powershell
# ⚠️ Attention : perte de données possible
Stop-Process -Name "winword"  # Word fermé sans sauvegarder !

# Alternative plus sûre pour les applications GUI
# (envoie un signal de fermeture normal)
(Get-Process -Name "notepad").CloseMainWindow()
```

### ⚙️ Options et paramètres {#options-parametres}

#### Paramètre -Force

```powershell
# Forcer l'arrêt de processus résistants
Stop-Process -Name "chrome" -Force

# Utile pour les processus qui ne répondent plus
Stop-Process -Id 5678 -Force
```

> [!info] Quand utiliser -Force ?
> 
> - Processus qui ne répondent plus (figés)
> - Processus avec fenêtres de confirmation
> - Arrêt garanti même si le processus résiste

#### Paramètre -PassThru

```powershell
# Retourner l'objet processus arrêté
$stopped = Stop-Process -Name "notepad" -PassThru
$stopped | Select-Object Name, Id, HasExited

# Utile pour la journalisation
Stop-Process -Name "chrome" -PassThru | ForEach-Object {
    Write-Host "Arrêt du processus $($_.Name) (ID: $($_.Id))"
}
```

> [!tip] Usage de -PassThru Par défaut, `Stop-Process` ne retourne rien. `-PassThru` est utile pour :
> 
> - Confirmer l'arrêt effectif
> - Logger les actions dans un script
> - Chaîner avec d'autres commandes

#### Paramètre -WhatIf

```powershell
# Simuler l'arrêt sans l'exécuter réellement
Stop-Process -Name "chrome" -WhatIf

# Affiche : "What if: Performing the operation "Stop-Process" on target "chrome (1234)""

# Tester un script avant exécution réelle
Get-Process | Where-Object {$_.CPU -gt 100} | Stop-Process -WhatIf
```

> [!tip] Bonnes pratiques de développement Utilisez toujours `-WhatIf` lors du développement de scripts d'automatisation pour éviter les arrêts accidentels.

```powershell
# Pattern de confirmation dans un script
function Stop-HighCPUProcesses {
    param([switch]$Confirm)
    
    $processes = Get-Process | Where-Object {$_.CPU -gt 100}
    
    if ($Confirm) {
        $processes | Stop-Process -WhatIf
    } else {
        $processes | Stop-Process -Force
    }
}

# Test
Stop-HighCPUProcesses -Confirm
```

#### Paramètre -Confirm

```powershell
# Demander confirmation avant chaque arrêt
Stop-Process -Name "chrome" -Confirm

# Combinaison avec filtrage
Get-Process | Where-Object {$_.WorkingSet -gt 500MB} | Stop-Process -Confirm
```

#### Gestion des erreurs

```powershell
# Ignorer les erreurs si processus introuvable
Stop-Process -Name "notepad" -ErrorAction SilentlyContinue

# Capturer les erreurs
try {
    Stop-Process -Name "systemprocess" -ErrorAction Stop
} catch {
    Write-Warning "Impossible d'arrêter le processus : $($_.Exception.Message)"
}

# Arrêter seulement si le processus existe
if (Get-Process -Name "notepad" -ErrorAction SilentlyContinue) {
    Stop-Process -Name "notepad"
}
```

### 🔢 Gestion des processus multiples {#processus-multiples}

```powershell
# Arrêter plusieurs processus par nom
Stop-Process -Name "chrome", "firefox", "edge"

# Arrêter tous les processus d'un type
Get-Process -Name "chrome" | Stop-Process

# Arrêter les processus consommant trop de ressources
Get-Process | Where-Object {$_.CPU -gt 100} | Stop-Process -Force

# Arrêter tous sauf le processus principal
Get-Process -Name "chrome" | 
    Sort-Object StartTime | 
    Select-Object -Skip 1 | 
    Stop-Process
```

> [!example] Script d'arrêt sélectif
> 
> ```powershell
> # Arrêter les processus Chrome sauf celui avec le plus d'utilisation CPU
> $chromeProcesses = Get-Process -Name "chrome"
> $topProcess = $chromeProcesses | Sort-Object CPU -Descending | Select-Object -First 1
> $chromeProcesses | Where-Object {$_.Id -ne $topProcess.Id} | Stop-Process
> ```

> [!warning] Arrêts en cascade Certains processus parents peuvent relancer automatiquement leurs processus enfants. Assurez-vous d'arrêter le processus parent en premier.

```powershell
# Identifier les relations parent-enfant
Get-WmiObject Win32_Process | 
    Select-Object ProcessId, ParentProcessId, Name |
    Where-Object {$_.Name -eq "chrome.exe"}

# Arrêter le processus parent en premier
$parentId = (Get-Process -Name "chrome" | Select-Object -First 1).Id
Stop-Process -Id $parentId -Force
```

### 🔐 Précautions et droits nécessaires {#precautions}

#### Processus système critiques

> [!warning] DANGER - Processus critiques N'arrêtez JAMAIS ces processus sous peine de plantage système :
> 
> - `csrss.exe` (Client/Server Runtime Subsystem)
> - `smss.exe` (Session Manager)
> - `wininit.exe` (Windows Initialization)
> - `services.exe` (Service Control Manager)
> - `lsass.exe` (Local Security Authority)

```powershell
# Liste de processus critiques à protéger
$criticalProcesses = @("csrss", "smss", "wininit", "services", "lsass", "winlogon")

# Fonction de sécurité
function Stop-ProcessSafely {
    param([string]$Name)
    
    if ($criticalProcesses -contains $Name) {
        Write-Error "INTERDIT : $Name est un processus système critique !"
        return
    }
    
    Stop-Process -Name $Name -Confirm
}

# Utilisation
Stop-ProcessSafely -Name "notepad"
```

#### Privilèges administrateur

```powershell
# Vérifier si exécuté en tant qu'administrateur
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Utilisation dans un script
if (-not (Test-Administrator)) {
    Write-Warning "Ce script nécessite des privilèges administrateur"
    Write-Host "Relancez PowerShell en tant qu'administrateur"
    exit
}

# Continuer avec les opérations nécessitant des droits élevés
Stop-Process -Name "systemservice" -Force
```

> [!info] Quand les droits admin sont nécessaires ?
> 
> - Arrêter des processus système
> - Arrêter des processus d'autres utilisateurs
> - Accéder aux modules de processus protégés
> - Modifier la priorité de processus

#### Protection contre les arrêts accidentels

```powershell
# Script avec confirmation obligatoire
function Stop-ProcessWithConfirmation {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    
    $processes = Get-Process -Name $Name -ErrorAction SilentlyContinue
    
    if (-not $processes) {
        Write-Host "Aucun processus '$Name' trouvé"
        return
    }
    
    Write-Host "Processus trouvés :" -ForegroundColor Yellow
    $processes | Format-Table Id, Name, CPU, WorkingSet -AutoSize
    
    $response = Read-Host "Voulez-vous vraiment arrêter ces processus ? (O/N)"
    
    if ($response -eq "O") {
        $processes | Stop-Process -Force
        Write-Host "Processus arrêtés" -ForegroundColor Green
    } else {
        Write-Host "Opération annulée" -ForegroundColor Cyan
    }
}

# Utilisation
Stop-ProcessWithConfirmation -Name "chrome"
```

#### Logging et audit

```powershell
# Fonction avec journalisation complète
function Stop-ProcessWithLogging {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [string]$LogPath = "C:\Logs\ProcessStop.log"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $user = $env:USERNAME
    
    try {
        $processes = Get-Process -Name $Name -ErrorAction Stop
        
        foreach ($proc in $processes) {
            $logEntry = "$timestamp | USER: $user | STOP | Name: $($proc.Name) | ID: $($proc.Id) | CPU: $($proc.CPU)"
            Add-Content -Path $LogPath -Value $logEntry
            
            Stop-Process -Id $proc.Id -Force
        }
        
        Write-Host "Processus arrêtés et journalisés" -ForegroundColor Green
        
    } catch {
        $errorEntry = "$timestamp | USER: $user | ERROR | $($_.Exception.Message)"
        Add-Content -Path $LogPath -Value $errorEntry
        Write-Error $_.Exception.Message
    }
}

# Utilisation
Stop-ProcessWithLogging -Name "notepad"
```

> [!tip] Bonnes pratiques de sécurité
> 
> - Toujours vérifier que le processus ciblé est correct avant arrêt
> - Utiliser `-WhatIf` pour tester les scripts
> - Maintenir des logs d'audit des arrêts de processus
> - Éviter l'utilisation de wildcards avec `Stop-Process`
> - Préférer `CloseMainWindow()` pour les applications avec données non sauvegardées

---

## 🎓 Récapitulatif des commandes essentielles

```powershell
# CONSULTATION
Get-Process                                    # Tous les processus
Get-Process -Name "chrome"                     # Par nom
Get-Process -Id 1234                           # Par ID
Get-Process | Sort-Object CPU -Descending      # Tri par CPU
Get-Process -Name "chrome" -Module             # Modules chargés
Get-Process -Name "notepad" -FileVersionInfo   # Infos version

# ARRÊT
Stop-Process -Name "notepad"                   # Arrêt par nom
Stop-Process -Id 1234                          # Arrêt par ID
Stop-Process -Name "chrome" -Force             # Forcer l'arrêt
Stop-Process -Name "chrome" -WhatIf            # Simulation
Stop-Process -Name "chrome" -Confirm           # Avec confirmation

# COMBINAISONS UTILES
Get-Process | Where-Object {$_.CPU -gt 100} | Stop-Process -WhatIf
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10
```

---

> [!tip] 💡 Conseil final La gestion des processus est une compétence fondamentale en administration système. Pratiquez d'abord avec des processus non critiques (notepad, calculatrice) avant de manipuler des processus plus importants. Utilisez toujours `-WhatIf` lors de l'apprentissage !