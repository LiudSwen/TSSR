

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

## 🎯 Introduction aux sessions persistantes

Les sessions persistantes PowerShell (PSSession) représentent des connexions réutilisables et durables vers des ordinateurs distants. Contrairement aux commandes ponctuelles avec `Invoke-Command` qui créent et détruisent une connexion à chaque exécution, les sessions persistantes maintiennent un état continu.

> [!info] Différence clé
> 
> - **Sans session** : Chaque `Invoke-Command` = nouvelle connexion → exécution → fermeture
> - **Avec session** : Connexion une fois → multiples commandes → fermeture explicite

### 🤔 Quand utiliser des sessions persistantes ?

|Situation|Session persistante ?|
|---|---|
|Exécuter une seule commande|❌ Non (overhead inutile)|
|Exécuter plusieurs commandes successives|✅ Oui|
|Préserver des variables entre commandes|✅ Oui|
|Importer des modules sur machine distante|✅ Oui|
|Script long avec multiples interactions|✅ Oui|
|Parallélisme sur plusieurs machines|✅ Oui|

---

## 🔧 New-PSSession : Créer des sessions

`New-PSSession` est la cmdlet principale pour établir des sessions persistantes vers un ou plusieurs ordinateurs distants.

### Syntaxe de base

```powershell
New-PSSession -ComputerName <string[]> [paramètres]
```

### 📝 Paramètres principaux

#### `-ComputerName`

Spécifie le ou les ordinateurs cibles. Accepte un tableau pour créer plusieurs sessions simultanément.

```powershell
# Session unique
$session = New-PSSession -ComputerName Server01

# Sessions multiples
$sessions = New-PSSession -ComputerName Server01, Server02, Server03

# Avec tableau de noms
$servers = @("Web01", "Web02", "DB01")
$sessions = New-PSSession -ComputerName $servers
```

#### `-Credential`

Définit les identifiants d'authentification pour la connexion distante.

```powershell
# Demander interactivement
$cred = Get-Credential
$session = New-PSSession -ComputerName Server01 -Credential $cred

# Avec identifiants pré-créés
$securePass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("Domain\Admin", $securePass)
$session = New-PSSession -ComputerName Server01 -Credential $cred
```

> [!warning] Sécurité Ne jamais stocker de mots de passe en clair dans les scripts. Utiliser des coffres-forts (Credential Manager, Azure Key Vault) ou des fichiers chiffrés.

#### `-Name`

Attribue un nom personnalisé à la session pour faciliter son identification.

```powershell
$session = New-PSSession -ComputerName Server01 -Name "SessionProduction"

# Récupérer la session par son nom
Get-PSSession -Name "SessionProduction"
```

> [!tip] Convention de nommage Utilisez des noms descriptifs incluant le rôle ou l'environnement : `"WebServer-Production"`, `"DB-DevEnvironment"`, etc.

#### `-ConfigurationName`

Spécifie l'endpoint de configuration à utiliser sur la machine distante.

```powershell
# Utiliser une configuration personnalisée
$session = New-PSSession -ComputerName Server01 -ConfigurationName "MyCustomEndpoint"

# Configuration Microsoft.PowerShell par défaut (explicite)
$session = New-PSSession -ComputerName Server01 -ConfigurationName "Microsoft.PowerShell"
```

> [!info] À quoi servent les configurations ? Les configurations définissent les permissions, les modules disponibles, et les restrictions de la session distante. Elles permettent de créer des environnements d'exécution personnalisés et sécurisés.

#### `-SessionOption`

Permet de définir des options avancées via un objet `PSSessionOption`.

```powershell
# Créer des options personnalisées
$options = New-PSSessionOption -SkipCACheck -SkipCNCheck -IdleTimeout 7200000

# Créer session avec options
$session = New-PSSession -ComputerName Server01 -SessionOption $options
```

### 🎁 Objet PSSession retourné

`New-PSSession` retourne un objet de type `PSSession` contenant les informations sur la connexion établie.

```powershell
$session = New-PSSession -ComputerName Server01

# Propriétés importantes
$session.ComputerName    # Nom de l'ordinateur
$session.State           # État : Opened, Closed, Broken, Disconnected
$session.Availability    # Disponibilité : Available, Busy
$session.Id              # Identifiant numérique unique
$session.Name            # Nom de la session
$session.ConfigurationName  # Configuration utilisée
```

> [!example] Vérifier l'état d'une session
> 
> ```powershell
> if ($session.State -eq "Opened" -and $session.Availability -eq "Available") {
>     Write-Host "Session prête à l'emploi"
> }
> ```

---

## ⚡ Avantages des sessions persistantes

### 1. 🚀 Performance optimisée

Chaque connexion distante implique un overhead de négociation, d'authentification et d'initialisation. Les sessions persistantes éliminent ce coût répété.

```powershell
# ❌ MAUVAIS : 5 connexions distinctes (lent)
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-Service }
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-Process }
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-EventLog -LogName System -Newest 10 }
Invoke-Command -ComputerName Server01 -ScriptBlock { Test-Connection google.com }
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-Disk }

# ✅ BON : 1 connexion, 5 commandes (rapide)
$session = New-PSSession -ComputerName Server01
Invoke-Command -Session $session -ScriptBlock { Get-Service }
Invoke-Command -Session $session -ScriptBlock { Get-Process }
Invoke-Command -Session $session -ScriptBlock { Get-EventLog -LogName System -Newest 10 }
Invoke-Command -Session $session -ScriptBlock { Test-Connection google.com }
Invoke-Command -Session $session -ScriptBlock { Get-Disk }
Remove-PSSession -Session $session
```

> [!tip] Gain de performance Sur un réseau local, économie de 1-2 secondes par commande. Sur WAN ou avec latence élevée, le gain peut atteindre 5-10 secondes par commande.

### 2. 💾 État préservé entre commandes

Les variables, fonctions et modules importés persistent durant toute la durée de vie de la session.

#### Persistance des variables

```powershell
$session = New-PSSession -ComputerName Server01

# Définir des variables
Invoke-Command -Session $session -ScriptBlock { 
    $serverName = $env:COMPUTERNAME
    $startTime = Get-Date
    $counter = 0
}

# Les variables existent toujours
Invoke-Command -Session $session -ScriptBlock { 
    $counter++
    Write-Output "Serveur: $serverName, Démarré: $startTime, Compteur: $counter"
}

# Encore accessibles
Invoke-Command -Session $session -ScriptBlock { 
    $counter++
    Write-Output "Compteur maintenant: $counter"  # Affiche 2
}

Remove-PSSession -Session $session
```

> [!info] Portée locale Les variables définies dans une session distante restent isolées de votre session locale. Elles n'existent que sur la machine distante.

#### Persistance des modules

```powershell
$session = New-PSSession -ComputerName Server01

# Importer un module une seule fois
Invoke-Command -Session $session -ScriptBlock { 
    Import-Module ActiveDirectory
}

# Utiliser les cmdlets du module dans toutes les commandes suivantes
Invoke-Command -Session $session -ScriptBlock { 
    Get-ADUser -Filter * | Select-Object -First 5
}

Invoke-Command -Session $session -ScriptBlock { 
    Get-ADComputer -Filter "OperatingSystem -like '*Server*'"
}

Remove-PSSession -Session $session
```

### 3. 🔄 Réutilisabilité de la connexion

Une fois créée, une session peut être utilisée par n'importe quelle commande acceptant le paramètre `-Session`.

```powershell
$session = New-PSSession -ComputerName Server01

# Différentes commandes utilisant la même session
Invoke-Command -Session $session -ScriptBlock { Get-Service W3SVC }
Copy-Item -Path "C:\Local\file.txt" -Destination "C:\Remote\" -ToSession $session
Enter-PSSession -Session $session  # Mode interactif
# ... commandes interactives ...
Exit-PSSession

Remove-PSSession -Session $session
```

### 4. 🎮 Gestion explicite du cycle de vie

Vous contrôlez précisément quand les ressources sont allouées et libérées.

```powershell
# Création contrôlée
$session = New-PSSession -ComputerName Server01

try {
    # Utilisation de la session
    $result = Invoke-Command -Session $session -ScriptBlock { 
        Get-EventLog -LogName System -Newest 100 
    }
    
    # Traiter les résultats localement
    $errors = $result | Where-Object { $_.EntryType -eq "Error" }
    
} finally {
    # Nettoyage garanti
    Remove-PSSession -Session $session
}
```

---

## 🛠️ Gestion du cycle de vie des sessions

### Get-PSSession : Lister les sessions

`Get-PSSession` permet d'inventorier toutes les sessions actives, locales ou distantes.

#### Syntaxe de base

```powershell
# Toutes les sessions de l'utilisateur actuel
Get-PSSession

# Sessions vers un ordinateur spécifique
Get-PSSession -ComputerName Server01

# Session par nom
Get-PSSession -Name "SessionProduction"

# Session par ID
Get-PSSession -Id 5

# Toutes les sessions (local + distant)
Get-PSSession -ComputerName *
```

#### Propriétés utiles

```powershell
$sessions = Get-PSSession

# Afficher informations détaillées
$sessions | Select-Object Id, Name, ComputerName, State, Availability, ConfigurationName

# Filtrer par état
$sessions | Where-Object { $_.State -eq "Opened" }

# Sessions inactives depuis longtemps
$sessions | Where-Object { $_.IdleTimeout -lt (Get-Date).AddMinutes(-30) }
```

> [!example] Audit des sessions
> 
> ```powershell
> # Créer rapport des sessions actives
> Get-PSSession | Format-Table -AutoSize Id, Name, ComputerName, 
>     @{Name="État";Expression={$_.State}},
>     @{Name="Durée";Expression={(Get-Date) - $_.Runspace.ConnectionInfo.IdleTimeout}}
> ```

### Remove-PSSession : Fermer les sessions

`Remove-PSSession` termine proprement les sessions et libère les ressources associées.

```powershell
# Fermer une session spécifique
Remove-PSSession -Session $session

# Fermer par ID
Remove-PSSession -Id 5

# Fermer par nom
Remove-PSSession -Name "SessionProduction"

# Fermer toutes les sessions vers un ordinateur
Get-PSSession -ComputerName Server01 | Remove-PSSession

# Fermer TOUTES les sessions
Get-PSSession | Remove-PSSession
```

> [!warning] Nettoyage important Les sessions non fermées consomment des ressources sur les machines locales et distantes. Toujours fermer les sessions inutilisées, surtout dans des scripts automatisés.

#### Pattern try-finally

```powershell
$session = $null
try {
    $session = New-PSSession -ComputerName Server01
    
    # Opérations avec la session
    Invoke-Command -Session $session -ScriptBlock { Get-Process }
    
} catch {
    Write-Error "Erreur lors de l'utilisation de la session : $_"
    
} finally {
    # Garantir la fermeture même en cas d'erreur
    if ($session) {
    Invoke-Command -Session $session -ScriptBlock { Get-Service }
    Remove-PSSession -Session $session
} else {
    Write-Error "Impossible de créer la session"
}
```

### 4. Ne pas gérer les sessions déconnectées

```powershell
# ❌ MAUVAIS : Laisser sessions déconnectées accumuler
$session = New-PSSession -ComputerName Server01
Disconnect-PSSession -Session $session
# ... session jamais reconnectée ni fermée

# ✅ BON : Nettoyer les sessions déconnectées
$disconnected = Get-PSSession -ComputerName Server01 | 
    Where-Object { $_.State -eq "Disconnected" }

foreach ($session in $disconnected) {
    Write-Host "Session déconnectée trouvée : $($session.Name) - ID $($session.Id)"
    
    # Décider de reconnecter ou supprimer
    $age = (Get-Date) - $session.IdleTimestamp
    if ($age.TotalHours -gt 24) {
        Remove-PSSession -Session $session
        Write-Host "  → Supprimée (trop ancienne)"
    } else {
        Connect-PSSession -Session $session
        Write-Host "  → Reconnectée"
    }
}
```

### 5. Utiliser sessions pour commandes uniques

```powershell
# ❌ MAUVAIS : Overhead inutile pour une seule commande
$session = New-PSSession -ComputerName Server01
Invoke-Command -Session $session -ScriptBlock { Get-Service }
Remove-PSSession -Session $session

# ✅ BON : Invoke-Command direct pour commande unique
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-Service }
```

> [!tip] Règle générale Session persistante uniquement si vous exécutez 2+ commandes ou avez besoin de préserver l'état.

### 6. Mélanger sessions et -ComputerName

```powershell
$session = New-PSSession -ComputerName Server01

# ❌ Incohérent : Crée nouvelle connexion au lieu d'utiliser la session
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-Process }

# ✅ Cohérent : Utilise la session existante
Invoke-Command -Session $session -ScriptBlock { Get-Process }

Remove-PSSession -Session $session
```

### 7. Ne pas vérifier l'état de la session avant utilisation

```powershell
$session = New-PSSession -ComputerName Server01

# ... temps passe, connexion peut se rompre ...

# ❌ Supposer que la session est toujours valide
Invoke-Command -Session $session -ScriptBlock { Get-Service }

# ✅ Vérifier l'état avant utilisation
if ($session.State -eq "Opened" -and $session.Availability -eq "Available") {
    Invoke-Command -Session $session -ScriptBlock { Get-Service }
} elseif ($session.State -eq "Broken") {
    Write-Warning "Session rompue, recréation nécessaire"
    Remove-PSSession -Session $session -ErrorAction SilentlyContinue
    $session = New-PSSession -ComputerName Server01
} elseif ($session.State -eq "Disconnected") {
    Write-Host "Reconnexion de la session..."
    Connect-PSSession -Session $session
}
```

### 8. Ignorer les limites de sessions simultanées

```powershell
# ❌ Peut échouer si limite atteinte (défaut : 5 par utilisateur)
$sessions = @()
for ($i = 1; $i -le 20; $i++) {
    $sessions += New-PSSession -ComputerName Server01
}

# ✅ Gérer les limites ou augmenter la limite sur le serveur
# Via commande sur le serveur :
# Set-Item WSMan:\localhost\Shell\MaxShellsPerUser -Value 25

# Ou réutiliser sessions existantes
$session = New-PSSession -ComputerName Server01
for ($i = 1; $i -le 20; $i++) {
    Invoke-Command -Session $session -ScriptBlock { 
        # Traitement
    }
}
Remove-PSSession -Session $session
```

### 9. Fuites mémoire avec variables dans sessions

```powershell
$session = New-PSSession -ComputerName Server01

# ❌ Accumulation de données dans la session
for ($i = 1; $i -le 1000; $i++) {
    Invoke-Command -Session $session -ScriptBlock {
        param($Index)
        # Cette variable s'accumule
        $global:results += "Résultat $Index"
    } -ArgumentList $i
}

# ✅ Nettoyer ou éviter accumulation
for ($i = 1; $i -le 1000; $i++) {
    $result = Invoke-Command -Session $session -ScriptBlock {
        param($Index)
        # Traiter et retourner immédiatement
        "Résultat $Index"
    } -ArgumentList $i
    
    # Traiter localement
    Process-Result $result
}

Remove-PSSession -Session $session
```

### 10. Oublier les différences de fuseaux horaires

```powershell
$session = New-PSSession -ComputerName ServerAmerique

# ❌ Comparaisons de dates incorrectes
Invoke-Command -Session $session -ScriptBlock {
    $remoteTime = Get-Date
    # $remoteTime peut être dans un fuseau différent
}

# ✅ Utiliser UTC pour comparaisons
$localUTC = (Get-Date).ToUniversalTime()
$remoteUTC = Invoke-Command -Session $session -ScriptBlock {
    (Get-Date).ToUniversalTime()
}

$timeDiff = $remoteUTC - $localUTC
Write-Host "Différence de temps : $($timeDiff.TotalSeconds) secondes"

Remove-PSSession -Session $session
```

---

## 🎯 Bonnes pratiques récapitulatives

> [!tip] Checklist des bonnes pratiques
> 
> **Création de sessions :**
> 
> - ✓ Utiliser sessions persistantes uniquement pour multiples commandes
> - ✓ Toujours nommer les sessions importantes avec `-Name`
> - ✓ Vérifier la création avec gestion d'erreurs
> - ✓ Utiliser `-Credential` pour authentification explicite
> 
> **Utilisation :**
> 
> - ✓ Vérifier `State` et `Availability` avant utilisation
> - ✓ Passer variables locales via `-ArgumentList`
> - ✓ Initialiser l'environnement distant une seule fois
> - ✓ Traiter les résultats localement quand possible
> 
> **Fermeture :**
> 
> - ✓ Toujours fermer avec `Remove-PSSession`
> - ✓ Utiliser `try-finally` pour garantir nettoyage
> - ✓ Nettoyer sessions déconnectées régulièrement
> - ✓ Monitorer avec `Get-PSSession`
> 
> **Performance :**
> 
> - ✓ Réutiliser sessions pour commandes multiples
> - ✓ Ajuster `ThrottleLimit` selon infrastructure
> - ✓ Utiliser parallélisme pour opérations sur multiples serveurs
> - ✓ Éviter accumulation de données dans sessions

---

## 📊 Tableau récapitulatif des cmdlets

|Cmdlet|Usage principal|Retour|
|---|---|---|
|`New-PSSession`|Créer session persistante|Objet PSSession|
|`Get-PSSession`|Lister sessions existantes|PSSession[]|
|`Remove-PSSession`|Fermer et détruire session|Void|
|`Disconnect-PSSession`|Déconnecter sans fermer|PSSession|
|`Connect-PSSession`|Reconnecter session déconnectée|PSSession|
|`Invoke-Command -Session`|Exécuter commande dans session|Objets retournés|
|`Enter-PSSession -Session`|Mode interactif dans session|N/A|
|`New-PSSessionOption`|Créer options avancées|PSSessionOption|

---

## 🔍 Scénarios d'utilisation avancés

### Scénario 1 : Déploiement d'application sur ferme de serveurs

```powershell
# Liste des serveurs web
$webServers = @("Web01", "Web02", "Web03", "Web04")

# Créer sessions vers tous les serveurs
$sessions = New-PSSession -ComputerName $webServers

try {
    # Étape 1 : Arrêter services
    Write-Host "Arrêt des services..." -ForegroundColor Yellow
    Invoke-Command -Session $sessions -ScriptBlock {
        Stop-Service W3SVC -Force
    }
    
    # Étape 2 : Copier fichiers
    Write-Host "Copie des fichiers..." -ForegroundColor Yellow
    foreach ($session in $sessions) {
        Copy-Item -Path "C:\Deploy\Application\*" `
                  -Destination "C:\inetpub\wwwroot\" `
                  -ToSession $session `
                  -Recurse -Force
    }
    
    # Étape 3 : Mettre à jour configuration
    Write-Host "Configuration..." -ForegroundColor Yellow
    Invoke-Command -Session $sessions -ScriptBlock {
        param($ConfigData)
        $ConfigData | Out-File "C:\inetpub\wwwroot\web.config" -Force
    } -ArgumentList $configurationXml
    
    # Étape 4 : Redémarrer services
    Write-Host "Redémarrage des services..." -ForegroundColor Yellow
    Invoke-Command -Session $sessions -ScriptBlock {
        Start-Service W3SVC
    }
    
    # Vérification
    $status = Invoke-Command -Session $sessions -ScriptBlock {
        @{
            Server = $env:COMPUTERNAME
            ServiceStatus = (Get-Service W3SVC).Status
            AppPoolStatus = (Get-WebAppPoolState "DefaultAppPool").Value
        }
    }
    
    $status | Format-Table Server, ServiceStatus, AppPoolStatus
    
    Write-Host "Déploiement terminé !" -ForegroundColor Green
    
} catch {
    Write-Error "Erreur lors du déploiement : $_"
    
} finally {
    # Nettoyer toutes les sessions
    Remove-PSSession -Session $sessions
}
```

### Scénario 2 : Surveillance continue avec session longue durée

```powershell
# Session de monitoring longue durée
$monitorSession = New-PSSession -ComputerName Server01

# Initialiser environnement de monitoring
Invoke-Command -Session $monitorSession -ScriptBlock {
    $global:MonitoringData = @{
        StartTime = Get-Date
        Samples = @()
        Alerts = @()
    }
    
    function Add-Sample {
        param($Type, $Value)
        $global:MonitoringData.Samples += @{
            Timestamp = Get-Date
            Type = $Type
            Value = $Value
        }
    }
    
    function Get-MonitoringReport {
        [PSCustomObject]@{
            Duration = (Get-Date) - $global:MonitoringData.StartTime
            SampleCount = $global:MonitoringData.Samples.Count
            AlertCount = $global:MonitoringData.Alerts.Count
            LatestSamples = $global:MonitoringData.Samples | Select-Object -Last 10
        }
    }
}

# Boucle de monitoring (peut tourner pendant des heures)
try {
    for ($i = 0; $i -lt 1000; $i++) {
        # Collecter métriques
        Invoke-Command -Session $monitorSession -ScriptBlock {
            # CPU
            $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
            Add-Sample -Type "CPU" -Value $cpu
            
            # Mémoire
            $mem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
            Add-Sample -Type "Memory" -Value $mem
            
            # Alertes
            if ($cpu -gt 90) {
                $global:MonitoringData.Alerts += "CPU élevé: $cpu%"
            }
        }
        
        # Afficher rapport toutes les 10 itérations
        if ($i % 10 -eq 0) {
            $report = Invoke-Command -Session $monitorSession -ScriptBlock {
                Get-MonitoringReport
            }
            Write-Host "[$($report.Duration.ToString('hh\:mm\:ss'))] Échantillons: $($report.SampleCount) | Alertes: $($report.AlertCount)"
        }
        
        Start-Sleep -Seconds 5
    }
    
} finally {
    # Récupérer rapport final
    $finalReport = Invoke-Command -Session $monitorSession -ScriptBlock {
        Get-MonitoringReport
    }
    $finalReport | Export-Csv "monitoring_report.csv" -NoTypeInformation
    
    Remove-PSSession -Session $monitorSession
}
```

### Scénario 3 : Exécution de tâche longue avec déconnexion

```powershell
# Lancer traitement long avec possibilité de déconnexion
$session = New-PSSession -ComputerName Server01

# Démarrer traitement asynchrone
Invoke-Command -Session $session -ScriptBlock {
    $global:ProcessingJob = Start-Job -ScriptBlock {
        $results = @()
        
        # Traitement très long (plusieurs heures)
        for ($i = 1; $i -le 10000; $i++) {
            # Simulation de traitement complexe
            $result = Get-Random -Minimum 1 -Maximum 1000
            Start-Sleep -Milliseconds 500
            
            $results += @{
                Iteration = $i
                Result = $result
                Timestamp = Get-Date
            }
            
            # Progression
            if ($i % 100 -eq 0) {
                Write-Progress -Activity "Traitement" `
                               -Status "$i / 10000" `
                               -PercentComplete (($i / 10000) * 100)
            }
        }
        
        return $results
    }
    
    Write-Output "Job démarré : ID $($global:ProcessingJob.Id)"
}

# Option 1 : Rester connecté et surveiller
# Option 2 : Se déconnecter
Write-Host "Déconnexion de la session (traitement continue)..."
Disconnect-PSSession -Session $session

Write-Host "Vous pouvez fermer cette console. Le traitement continue sur le serveur."
Write-Host "Pour vérifier l'état plus tard, exécutez le script de reconnexion."

# --- PLUS TARD : Script de reconnexion ---

# Reconnecter à la session
$session = Get-PSSession -ComputerName Server01 | 
           Where-Object { $_.State -eq "Disconnected" } |
           Connect-PSSession

# Vérifier état du job
$jobStatus = Invoke-Command -Session $session -ScriptBlock {
    $job = $global:ProcessingJob
    
    @{
        State = $job.State
        HasMoreData = $job.HasMoreData
        StartTime = $job.PSBeginTime
        Duration = (Get-Date) - $job.PSBeginTime
    }
}

Write-Host "État du job : $($jobStatus.State)"
Write-Host "Durée : $($jobStatus.Duration.ToString('hh\:mm\:ss'))"

# Si terminé, récupérer résultats
if ($jobStatus.State -eq "Completed") {
    $results = Invoke-Command -Session $session -ScriptBlock {
        Receive-Job -Job $global:ProcessingJob
    }
    
    Write-Host "Traitement terminé ! $($results.Count) résultats récupérés."
    $results | Export-Csv "traitement_results.csv" -NoTypeInformation
    
    # Nettoyer
    Invoke-Command -Session $session -ScriptBlock {
        Remove-Job -Job $global:ProcessingJob
    }
}

Remove-PSSession -Session $session
```

---

## 🏁 Conclusion

Les sessions persistantes PowerShell avec `New-PSSession` sont un outil puissant pour gérer efficacement les interactions distantes. Elles offrent des avantages significatifs en termes de performance, de maintien d'état, et de flexibilité, particulièrement dans les scénarios impliquant plusieurs commandes ou des opérations longues.

**Points clés à retenir :**

- Utilisez sessions persistantes quand vous exécutez **2+ commandes** ou avez besoin de **préserver l'état**
- Toujours **fermer les sessions** avec `Remove-PSSession` pour libérer les ressources
- Exploitez les **sessions multiples** pour parallélisme sur plusieurs machines
- Gérez le **cycle de vie** avec Get/Remove/Disconnect/Connect-PSSession
- Configurez **options avancées** via `New-PSSessionOption` selon vos besoins
- Privilégiez le pattern **try-finally** pour garantir le nettoyage

Les sessions persistantes transforment PowerShell Remoting d'un outil de commandes ponctuelles en une plateforme complète de gestion et d'automatisation distribuée. Remove-PSSession -Session $session } }

````

### Disconnect-PSSession : Déconnecter sans fermer

`Disconnect-PSSession` permet de se déconnecter d'une session tout en la laissant active sur la machine distante.

```powershell
# Créer et utiliser session
$session = New-PSSession -ComputerName Server01
Invoke-Command -Session $session -ScriptBlock { 
    $job = Start-Job -ScriptBlock { Start-Sleep 300 }
}

# Déconnecter (session continue à tourner)
Disconnect-PSSession -Session $session

# Vérifier l'état
Get-PSSession -ComputerName Server01  # State = Disconnected
````

> [!info] Cas d'usage
> 
> - Lancer des tâches longues et se déconnecter
> - Basculer entre machines (fermer laptop, reprendre sur bureau)
> - Économiser bande passante réseau temporairement
> - Scripts nécessitant plusieurs heures d'exécution

#### Comportement des sessions déconnectées

```powershell
# Session déconnectée
$session = Get-PSSession -ComputerName Server01 | Where-Object { $_.State -eq "Disconnected" }

# Les propriétés changent
$session.State          # Disconnected
$session.Availability   # None

# La session continue d'exister sur la machine distante
# Les scripts en cours continuent de s'exécuter
# Les variables et modules sont préservés
```

### Connect-PSSession : Reconnecter

`Connect-PSSession` permet de se reconnecter à une session précédemment déconnectée.

```powershell
# Reconnecter à une session existante
$session = Get-PSSession -ComputerName Server01 | Where-Object { $_.State -eq "Disconnected" }
Connect-PSSession -Session $session

# Vérifier reconnexion
$session.State          # Opened
$session.Availability   # Available

# Continuer à utiliser la session
Invoke-Command -Session $session -ScriptBlock { Get-Job }
```

> [!example] Scénario complet de déconnexion/reconnexion
> 
> ```powershell
> # Jour 1 : Lancer traitement long
> $session = New-PSSession -ComputerName Server01
> Invoke-Command -Session $session -ScriptBlock {
>     $job = Start-Job -ScriptBlock {
>         1..1000 | ForEach-Object {
>             Start-Sleep 10
>             Write-Output "Itération $_"
>         }
>     }
> }
> Disconnect-PSSession -Session $session
> 
> # Jour 2 : Reprendre le suivi
> $session = Get-PSSession -ComputerName Server01 | Connect-PSSession
> Invoke-Command -Session $session -ScriptBlock {
>     Get-Job | Receive-Job -Keep
> }
> ```

---

## 💼 Utilisation pratique des sessions

### Pattern de base : Créer, Utiliser, Fermer

Le workflow standard pour travailler avec des sessions :

```powershell
# 1. CRÉER
$session = New-PSSession -ComputerName Server01

# 2. UTILISER
Invoke-Command -Session $session -ScriptBlock { 
    Get-Service 
}

Invoke-Command -Session $session -ScriptBlock { 
    $var = 10 
}

Invoke-Command -Session $session -ScriptBlock { 
    $var  # Retourne 10
}

# 3. FERMER
Remove-PSSession -Session $session
```

### Utilisation avec Invoke-Command

Le paramètre `-Session` de `Invoke-Command` accepte un objet PSSession au lieu de `-ComputerName`.

```powershell
$session = New-PSSession -ComputerName Server01

# Passer la session à Invoke-Command
$result = Invoke-Command -Session $session -ScriptBlock {
    param($Path)
    Get-ChildItem -Path $Path
} -ArgumentList "C:\Logs"

Remove-PSSession -Session $session
```

> [!tip] Avantage de -Session vs -ComputerName Avec `-Session`, vous contrôlez explicitement la connexion. Avec `-ComputerName`, PowerShell crée/détruit automatiquement la connexion.

### Passage d'arguments et retour de données

```powershell
$session = New-PSSession -ComputerName Server01

# Définir variables locales
$localPath = "C:\Data"
$localFilter = "*.log"

# Les passer à la session distante
$remoteFiles = Invoke-Command -Session $session -ScriptBlock {
    param($Path, $Filter)
    Get-ChildItem -Path $Path -Filter $Filter
} -ArgumentList $localPath, $localFilter

# $remoteFiles contient maintenant les objets retournés
$remoteFiles | Select-Object Name, Length, LastWriteTime

Remove-PSSession -Session $session
```

### État partagé entre commandes

```powershell
$session = New-PSSession -ComputerName Server01

# Initialiser environnement distant
Invoke-Command -Session $session -ScriptBlock {
    # Importer modules nécessaires
    Import-Module ActiveDirectory
    
    # Définir variables globales
    $global:LogPath = "C:\Logs\script.log"
    $global:ErrorCount = 0
    
    # Définir fonctions utilitaires
    function Write-CustomLog {
        param($Message)
        Add-Content -Path $global:LogPath -Value "$(Get-Date) - $Message"
    }
}

# Utiliser l'environnement préparé
Invoke-Command -Session $session -ScriptBlock {
    Write-CustomLog "Démarrage du traitement"
    
    try {
        $users = Get-ADUser -Filter * -Properties Department
        Write-CustomLog "Récupéré $($users.Count) utilisateurs"
    } catch {
        $global:ErrorCount++
        Write-CustomLog "ERREUR : $_"
    }
}

# Vérifier résultats
$errorCount = Invoke-Command -Session $session -ScriptBlock { 
    $global:ErrorCount 
}
Write-Host "Erreurs détectées : $errorCount"

Remove-PSSession -Session $session
```

### Copie de fichiers avec sessions

Les cmdlets `Copy-Item` acceptent les paramètres `-ToSession` et `-FromSession`.

```powershell
$session = New-PSSession -ComputerName Server01

# Copier vers la machine distante
Copy-Item -Path "C:\Local\config.xml" -Destination "C:\Remote\" -ToSession $session

# Copier depuis la machine distante
Copy-Item -Path "C:\Remote\results.csv" -Destination "C:\Local\" -FromSession $session

# Copier un dossier entier
Copy-Item -Path "C:\Local\Data" -Destination "C:\Remote\" -ToSession $session -Recurse

Remove-PSSession -Session $session
```

---

## 🚦 Sessions multiples et parallélisme

### Créer plusieurs sessions simultanément

`New-PSSession` avec un tableau de noms d'ordinateurs crée toutes les sessions en parallèle.

```powershell
# Créer sessions vers plusieurs serveurs
$servers = @("Web01", "Web02", "Web03", "DB01")
$sessions = New-PSSession -ComputerName $servers

# Vérifier création
$sessions | Format-Table ComputerName, State, Id

# Résultat : 4 objets PSSession
```

### Exécuter commandes sur toutes les sessions

```powershell
$servers = @("Server01", "Server02", "Server03")
$sessions = New-PSSession -ComputerName $servers

# Exécuter sur TOUTES les sessions en parallèle
$results = Invoke-Command -Session $sessions -ScriptBlock {
    Get-Service | Where-Object { $_.Status -eq "Running" }
}

# Les résultats incluent PSComputerName
$results | Select-Object PSComputerName, Name, Status | Format-Table

Remove-PSSession -Session $sessions
```

> [!info] Parallélisme automatique Quand vous passez un tableau de sessions à `Invoke-Command`, PowerShell exécute la commande sur toutes les machines simultanément, pas séquentiellement.

### Pool de connexions géré

```powershell
# Créer pool de sessions
$sessionPool = @{}
$servers = @("Web01", "Web02", "DB01", "Cache01")

foreach ($server in $servers) {
    $sessionPool[$server] = New-PSSession -ComputerName $server
}

# Utiliser une session spécifique du pool
Invoke-Command -Session $sessionPool["Web01"] -ScriptBlock { Get-Process w3wp }

# Utiliser toutes les sessions Web
$webSessions = $sessionPool["Web01"], $sessionPool["Web02"]
Invoke-Command -Session $webSessions -ScriptBlock { Restart-Service W3SVC }

# Nettoyer tout le pool
$sessionPool.Values | Remove-PSSession
```

### Parallélisme contrôlé avec ThrottleLimit

Par défaut, `Invoke-Command` limite le parallélisme à 32 connexions simultanées. Vous pouvez modifier cette limite.

```powershell
$servers = 1..100 | ForEach-Object { "Server{0:D3}" -f $_ }
$sessions = New-PSSession -ComputerName $servers

# Exécuter sur 100 serveurs, mais max 10 simultanément
$results = Invoke-Command -Session $sessions -ThrottleLimit 10 -ScriptBlock {
    Get-CimInstance Win32_OperatingSystem
}

Remove-PSSession -Session $sessions
```

> [!tip] Choix du ThrottleLimit
> 
> - Réseau local rapide : 32-64
> - WAN ou connexions lentes : 5-10
> - Machines cibles faibles : 4-8
> - Trop élevé = surcharge réseau/CPU

### Gestion d'erreurs avec sessions multiples

```powershell
$servers = @("Server01", "ServerInexistant", "Server03")
$sessions = @()

# Créer sessions avec gestion d'erreurs
foreach ($server in $servers) {
    try {
        $session = New-PSSession -ComputerName $server -ErrorAction Stop
        $sessions += $session
        Write-Host "✓ Session créée vers $server" -ForegroundColor Green
    } catch {
        Write-Warning "✗ Impossible de créer session vers $server : $_"
    }
}

Write-Host "`n$($sessions.Count) sessions créées sur $($servers.Count) tentatives"

# Utiliser uniquement les sessions valides
if ($sessions.Count -gt 0) {
    $results = Invoke-Command -Session $sessions -ScriptBlock { 
        Get-Service 
    }
}

# Nettoyer
$sessions | Remove-PSSession
```

---

## ⚙️ Options avancées de session

### New-PSSessionOption : Personnaliser le comportement

`New-PSSessionOption` crée un objet d'options qui définit des paramètres avancés pour les sessions.

```powershell
# Créer objet d'options
$options = New-PSSessionOption

# Utiliser dans New-PSSession
$session = New-PSSession -ComputerName Server01 -SessionOption $options
```

### Paramètres d'options courants

#### Timeouts

```powershell
# Timeout d'inactivité (en millisecondes)
$options = New-PSSessionOption -IdleTimeout 3600000  # 1 heure

# Timeout d'opération
$options = New-PSSessionOption -OperationTimeout 300000  # 5 minutes

# Timeout d'ouverture de connexion
$options = New-PSSessionOption -OpenTimeout 60000  # 1 minute

# Combiner plusieurs options
$options = New-PSSessionOption `
    -IdleTimeout 7200000 `
    -OperationTimeout 600000 `
    -OpenTimeout 30000

$session = New-PSSession -ComputerName Server01 -SessionOption $options
```

> [!info] Valeurs par défaut
> 
> - IdleTimeout : 7200000ms (2 heures)
> - OperationTimeout : 180000ms (3 minutes)
> - OpenTimeout : 180000ms (3 minutes)

#### Culture et langue

```powershell
# Définir culture française
$options = New-PSSessionOption -Culture "fr-FR" -UICulture "fr-FR"

$session = New-PSSession -ComputerName Server01 -SessionOption $options

Invoke-Command -Session $session -ScriptBlock {
    Get-Date  # Format français
    Get-Culture  # fr-FR
}

Remove-PSSession -Session $session
```

#### Proxy

```powershell
# Configurer proxy pour connexion
$options = New-PSSessionOption `
    -ProxyAccessType IEConfig `  # Utiliser config Internet Explorer
    -ProxyAuthentication Negotiate

# Ou spécifier proxy explicite
$options = New-PSSessionOption `
    -ProxyAccessType Manual `
    -ProxyAddress "http://proxy.company.com:8080" `
    -ProxyCredential (Get-Credential)

$session = New-PSSession -ComputerName RemoteServer -SessionOption $options
```

#### Compression et encodage

```powershell
# Désactiver compression (utile pour debugging)
$options = New-PSSessionOption -NoCompression

# Spécifier mode de sortie
$options = New-PSSessionOption -OutputBufferingMode Block

$session = New-PSSession -ComputerName Server01 -SessionOption $options
```

#### Options de sécurité SSL/TLS

```powershell
# Pour environnements de test avec certificats auto-signés
$options = New-PSSessionOption `
    -SkipCACheck `         # Ignorer vérification autorité certification
    -SkipCNCheck `         # Ignorer vérification nom commun
    -SkipRevocationCheck   # Ignorer vérification révocation certificat

$session = New-PSSession -ComputerName Server01 -SessionOption $options -UseSSL
```

> [!warning] Sécurité N'utilisez `SkipCACheck`, `SkipCNCheck` et `SkipRevocationCheck` QUE dans des environnements de test. En production, validez toujours les certificats SSL.

### Configuration d'options réutilisable

```powershell
# Créer configuration standard pour votre environnement
$standardOptions = New-PSSessionOption `
    -IdleTimeout 7200000 `
    -OperationTimeout 600000 `
    -Culture "fr-FR" `
    -UICulture "fr-FR" `
    -NoCompression:$false

# Utiliser dans tous vos scripts
function New-StandardSession {
    param($ComputerName)
    
    New-PSSession `
        -ComputerName $ComputerName `
        -SessionOption $script:standardOptions
}

# Créer sessions avec options standard
$session1 = New-StandardSession -ComputerName Server01
$session2 = New-StandardSession -ComputerName Server02
```

---

## ⚠️ Pièges courants

### 1. Oublier de fermer les sessions

```powershell
# ❌ MAUVAIS : Sessions orphelines
for ($i = 1; $i -le 10; $i++) {
    $session = New-PSSession -ComputerName Server01
    Invoke-Command -Session $session -ScriptBlock { Get-Process }
    # Oubli de Remove-PSSession
}

# ✅ BON : Fermeture systématique
for ($i = 1; $i -le 10; $i++) {
    $session = New-PSSession -ComputerName Server01
    try {
        Invoke-Command -Session $session -ScriptBlock { Get-Process }
    } finally {
        Remove-PSSession -Session $session
    }
}
```

> [!warning] Impact
> 
> - Consommation mémoire sur machines locales et distantes
> - Limite de sessions simultanées atteinte (défaut : 5 par utilisateur)
> - Connexions réseau maintenues inutilement

### 2. Confondre portée locale et distante

```powershell
$session = New-PSSession -ComputerName Server01

$localVar = "Valeur locale"

# ❌ Cette variable n'existe PAS dans la session distante
Invoke-Command -Session $session -ScriptBlock {
    Write-Output $localVar  # $null ou erreur
}

# ✅ Passer explicitement avec -ArgumentList
Invoke-Command -Session $session -ScriptBlock {
    param($Value)
    Write-Output $Value
} -ArgumentList $localVar

Remove-PSSession -Session $session
```

### 3. Ignorer les erreurs de création de session

```powershell
# ❌ MAUVAIS : Pas de vérification
$session = New-PSSession -ComputerName ServeurInexistant
Invoke-Command -Session $session -ScriptBlock { Get-Service }  # Erreur !

# ✅ BON : Vérifier la session
$session = New-PSSession -ComputerName Server01 -ErrorAction SilentlyContinue

if ($session) {
```