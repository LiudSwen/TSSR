

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

## 🎯 Introduction à Invoke-Command

`Invoke-Command` est la cmdlet centrale du PowerShell Remoting. Elle permet d'exécuter des commandes ou des scripts sur des machines distantes de manière simple et efficace.

> [!info] Pourquoi utiliser Invoke-Command ?
> 
> - **Administration centralisée** : Gérer plusieurs serveurs depuis une seule console
> - **Automatisation** : Déployer des configurations ou collecter des informations à grande échelle
> - **Efficacité** : Exécution parallèle sur plusieurs machines simultanément
> - **Flexibilité** : Supporte des commandes simples, des scripts complexes et des sessions persistantes

### Quand l'utiliser ?

- ✅ Exécuter une commande sur un ou plusieurs serveurs distants
- ✅ Collecter des informations de plusieurs machines
- ✅ Déployer des configurations
- ✅ Automatiser des tâches administratives répétitives
- ✅ Exécuter des scripts sans les copier manuellement

---

## 📝 Syntaxe de base

```powershell
Invoke-Command [-ComputerName] <String[]>
               [-ScriptBlock] <ScriptBlock>
               [-Credential <PSCredential>]
               [-ThrottleLimit <Int32>]
               [<AutresParamètresCommuns>]
```

### Paramètres principaux

|Paramètre|Description|Obligatoire|
|---|---|---|
|`-ComputerName`|Nom(s) de l'ordinateur cible|Oui (ou `-Session`)|
|`-ScriptBlock`|Code PowerShell à exécuter|Oui (ou `-FilePath`)|
|`-Credential`|Identifiants d'authentification|Non|
|`-ArgumentList`|Arguments à passer au ScriptBlock|Non|
|`-Session`|Session PSSession existante|Non|
|`-FilePath`|Chemin vers un script à exécuter|Non|

> [!warning] Prérequis
> 
> - PowerShell Remoting doit être activé sur les machines cibles (via `Enable-PSRemoting`)
> - Règles firewall appropriées
> - Droits administratifs (généralement requis)

---

## 💻 Exécution simple sur une machine distante

La forme la plus basique consiste à exécuter une commande sur une seule machine.

```powershell
# Lister les services sur Server01
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-Service }

# Obtenir la version de PowerShell
Invoke-Command -ComputerName Server01 -ScriptBlock { $PSVersionTable }

# Vérifier l'espace disque
Invoke-Command -ComputerName Server01 -ScriptBlock { 
    Get-PSDrive C | Select-Object Used, Free 
}
```

> [!example] Exemple avec authentification
> 
> ```powershell
> # Demander les identifiants et exécuter une commande
> $cred = Get-Credential
> Invoke-Command -ComputerName Server01 `
>                -Credential $cred `
>                -ScriptBlock { Get-EventLog -LogName System -Newest 10 }
> ```

### Points importants

- Le code dans `{ }` (ScriptBlock) s'exécute **sur la machine distante**
- Les variables locales ne sont **pas automatiquement** transférées
- Le résultat est désérialisé et retourné à la machine locale

---

## 🌐 Exécution sur plusieurs ordinateurs

L'une des grandes forces d'`Invoke-Command` est sa capacité à exécuter des commandes sur plusieurs machines **en parallèle**.

```powershell
# Tableau de serveurs
$servers = "Server01", "Server02", "Server03"

# Exécution sur tous les serveurs
Invoke-Command -ComputerName $servers -ScriptBlock {
    Get-Service -Name WinRM | Select-Object Name, Status
}
```

> [!tip] Parallélisme par défaut Par défaut, `Invoke-Command` exécute les commandes sur **32 machines en parallèle**. Vous pouvez modifier ce comportement avec `-ThrottleLimit`.

### Contrôler le parallélisme

```powershell
# Limiter à 10 machines simultanées
Invoke-Command -ComputerName $servers `
               -ThrottleLimit 10 `
               -ScriptBlock { Get-Process }

# Exécution séquentielle (une à la fois)
Invoke-Command -ComputerName $servers `
               -ThrottleLimit 1 `
               -ScriptBlock { Restart-Service Spooler }
```

### Lecture depuis un fichier

```powershell
# Lire les noms de serveurs depuis un fichier
$servers = Get-Content "C:\servers.txt"

Invoke-Command -ComputerName $servers -ScriptBlock {
    # Récupérer l'uptime de chaque serveur
    $os = Get-CimInstance Win32_OperatingSystem
    $uptime = (Get-Date) - $os.LastBootUpTime
    [PSCustomObject]@{
        Computer = $env:COMPUTERNAME
        UptimeDays = [math]::Round($uptime.TotalDays, 2)
    }
}
```

> [!warning] Gestion des échecs Si une machine est inaccessible, elle génère une erreur mais n'interrompt pas l'exécution sur les autres machines.

---

## 📦 Passage d'arguments

Pour utiliser des variables locales dans le ScriptBlock distant, il existe deux méthodes principales.

### Méthode 1 : `-ArgumentList` (Compatible toutes versions)

```powershell
# Définir une variable locale
$serviceName = "WinRM"

# Passer en argument
Invoke-Command -ComputerName Server01 `
               -ScriptBlock { 
                   param($svc)
                   Get-Service -Name $svc 
               } `
               -ArgumentList $serviceName
```

> [!example] Passage de plusieurs arguments
> 
> ```powershell
> $service = "Spooler"
> $status = "Running"
> 
> Invoke-Command -ComputerName Server01 -ScriptBlock {
>     param($svc, $stat)
>     Get-Service -Name $svc | Where-Object Status -eq $stat
> } -ArgumentList $service, $status
> ```

### Méthode 2 : `$using:` (PowerShell 3.0+)

Plus moderne et plus lisible, la syntaxe `$using:` permet d'accéder directement aux variables locales.

```powershell
$serviceName = "WinRM"

# Utilisation directe avec $using:
Invoke-Command -ComputerName Server01 -ScriptBlock {
    Get-Service -Name $using:serviceName
}
```

> [!tip] Avantages de $using:
> 
> - ✅ Code plus lisible et maintenable
> - ✅ Pas besoin de `param()` dans le ScriptBlock
> - ✅ Moins de risques d'erreur d'ordre des paramètres

```powershell
# Exemple avec plusieurs variables
$logName = "System"
$newestCount = 50

Invoke-Command -ComputerName Server01, Server02 -ScriptBlock {
    Get-EventLog -LogName $using:logName -Newest $using:newestCount
}
```

### Tableau comparatif

|Méthode|Avantages|Inconvénients|
|---|---|---|
|`-ArgumentList`|Compatible PS 2.0+|Code moins lisible, ordre des paramètres important|
|`$using:`|Lisible, intuitif|Requiert PS 3.0+|

> [!warning] Piège courant `$using:` ne fonctionne **que** dans `Invoke-Command`. N'essayez pas de l'utiliser dans des fonctions locales.

---

## 🔗 Sessions persistantes

Par défaut, `Invoke-Command` crée une nouvelle connexion pour chaque exécution. Pour des commandes multiples sur la même machine, utilisez des **sessions persistantes** (PSSession).

### Création et utilisation de sessions

```powershell
# Créer une session
$session = New-PSSession -ComputerName Server01

# Utiliser la session
Invoke-Command -Session $session -ScriptBlock {
    Get-Service WinRM
}

# Réutiliser la même session (connexion déjà établie)
Invoke-Command -Session $session -ScriptBlock {
    Get-Process | Select-Object -First 5
}

# Fermer la session
Remove-PSSession $session
```

> [!info] Avantages des sessions persistantes
> 
> - **Performance** : Pas de reconnexion à chaque commande
> - **Contexte préservé** : Les variables et fonctions restent en mémoire
> - **Efficacité** : Réduction de la charge réseau et CPU

### Sessions multiples

```powershell
# Créer des sessions vers plusieurs serveurs
$sessions = New-PSSession -ComputerName Server01, Server02, Server03

# Exécuter une commande sur toutes les sessions
Invoke-Command -Session $sessions -ScriptBlock {
    Get-Service Spooler
}

# Nettoyer toutes les sessions
Remove-PSSession $sessions
```

### Contexte préservé entre commandes

```powershell
$session = New-PSSession -ComputerName Server01

# Définir une variable dans la session distante
Invoke-Command -Session $session -ScriptBlock {
    $myVar = "Test123"
}

# Réutiliser la variable (elle existe toujours)
Invoke-Command -Session $session -ScriptBlock {
    Write-Output "La variable contient : $myVar"
}

Remove-PSSession $session
```

> [!tip] Bonne pratique Utilisez toujours `Remove-PSSession` pour libérer les ressources. Une session ouverte consomme de la mémoire sur le serveur distant.

### Gestion du cycle de vie

```powershell
# Vérifier les sessions actives
Get-PSSession

# Déconnecter une session (sans la fermer)
Disconnect-PSSession -Session $session

# Reconnecter à une session déconnectée
Connect-PSSession -Session $session

# Forcer la fermeture de toutes les sessions
Get-PSSession | Remove-PSSession
```

---

## 📄 Exécution de scripts distants

Au lieu d'un ScriptBlock, vous pouvez exécuter un **fichier script local** sur des machines distantes.

### Syntaxe avec `-FilePath`

```powershell
# Exécuter un script local sur une machine distante
Invoke-Command -ComputerName Server01 `
               -FilePath "C:\Scripts\MonScript.ps1"
```

> [!info] Fonctionnement
> 
> 1. Le script est **lu** depuis la machine locale
> 2. Il est **copié** temporairement sur la machine distante
> 3. Il est **exécuté** sur la machine distante
> 4. Les résultats sont **retournés** à la machine locale

### Script avec paramètres

```powershell
# Contenu de GetServiceInfo.ps1
param(
    [string]$ServiceName,
    [string]$ComputerName = $env:COMPUTERNAME
)

Get-Service -Name $ServiceName | 
    Select-Object Name, Status, StartType

# Exécution avec arguments
Invoke-Command -ComputerName Server01, Server02 `
               -FilePath "C:\Scripts\GetServiceInfo.ps1" `
               -ArgumentList "WinRM"
```

### Exécution sur plusieurs serveurs

```powershell
$servers = "Server01", "Server02", "Server03"

# Déployer et exécuter un script de configuration
Invoke-Command -ComputerName $servers `
               -FilePath "C:\Scripts\ConfigureIIS.ps1" `
               -ThrottleLimit 5
```

> [!warning] Chemins relatifs Le `-FilePath` doit pointer vers un chemin **local** à la machine qui exécute `Invoke-Command`. Les chemins relatifs sont résolus par rapport au répertoire de travail actuel.

### Comparaison ScriptBlock vs FilePath

|Aspect|`-ScriptBlock`|`-FilePath`|
|---|---|---|
|**Source**|Code inline|Fichier externe|
|**Lisibilité**|Bon pour code court|Meilleur pour code long|
|**Réutilisabilité**|Limitée|Excellente|
|**Versioning**|Difficile|Facile (fichier sous contrôle de version)|

---

## ⚙️ Options avancées

### Exécution en arrière-plan avec `-AsJob`

Pour des tâches longues, exécutez la commande en tant que **job** pour ne pas bloquer la console.

```powershell
# Lancer une commande longue en arrière-plan
$job = Invoke-Command -ComputerName Server01, Server02 -AsJob -ScriptBlock {
    # Tâche longue : sauvegarde, scan, etc.
    Start-Sleep -Seconds 30
    Get-Service
}

# Vérifier le statut
Get-Job

# Attendre la fin du job
Wait-Job $job

# Récupérer les résultats
Receive-Job $job

# Nettoyer
Remove-Job $job
```

> [!tip] Jobs vs exécution directe
> 
> - **Jobs** : Pour tâches longues, permet de continuer à travailler
> - **Direct** : Pour commandes rapides, résultats immédiats

### Sessions déconnectées avec `-InDisconnectedSession`

Créer une session qui continue à s'exécuter même après déconnexion.

```powershell
# Créer et déconnecter immédiatement
Invoke-Command -ComputerName Server01 `
               -InDisconnectedSession `
               -ScriptBlock {
                   # Tâche très longue
                   Start-Sleep -Seconds 3600
                   Get-EventLog -LogName System -Newest 1000
               }

# Lister les sessions déconnectées
Get-PSSession -ComputerName Server01

# Se reconnecter plus tard
$session = Get-PSSession -ComputerName Server01 | 
           Where-Object State -eq 'Disconnected'
Connect-PSSession $session

# Récupérer les résultats
Invoke-Command -Session $session -ScriptBlock { $myResults }
```

### Configuration d'endpoint avec `-ConfigurationName`

Utiliser un endpoint personnalisé (configuration de session).

```powershell
# Se connecter à un endpoint restreint
Invoke-Command -ComputerName Server01 `
               -ConfigurationName 'Microsoft.PowerShell.Workflow' `
               -ScriptBlock { Get-Command }
```

> [!info] Endpoints courants
> 
> - `Microsoft.PowerShell` : Endpoint par défaut
> - `Microsoft.PowerShell.Workflow` : Pour les workflows
> - `Microsoft.PowerShell32` : PowerShell 32-bit sur système 64-bit
> - Endpoints personnalisés créés via `Register-PSSessionConfiguration`

### Options de connexion avancées

```powershell
# Options de session personnalisées
$sessionOption = New-PSSessionOption -SkipCACheck `
                                      -SkipCNCheck `
                                      -MaxConnectionRetryCount 3

Invoke-Command -ComputerName Server01 `
               -SessionOption $sessionOption `
               -ScriptBlock { Get-Service }
```

---

## 📊 Gestion des résultats

Les objets retournés par `Invoke-Command` sont **désérialisés** et contiennent des métadonnées supplémentaires.

### Propriété PSComputerName

Chaque objet retourné inclut automatiquement le nom de la machine source.

```powershell
$results = Invoke-Command -ComputerName Server01, Server02 -ScriptBlock {
    Get-Service WinRM
}

# Afficher avec le nom de l'ordinateur
$results | Select-Object PSComputerName, Name, Status

# Filtrer par ordinateur
$results | Where-Object PSComputerName -eq 'Server01'
```

### Désérialisation des objets

> [!warning] Objets désérialisés Les objets retournés sont des **copies** désérialisées, pas les objets "vivants" originaux. Certaines méthodes peuvent ne plus fonctionner.

```powershell
# Objet local (méthodes disponibles)
$localService = Get-Service WinRM
$localService.Stop()  # ✅ Fonctionne

# Objet distant (désérialisé)
$remoteService = Invoke-Command -ComputerName Server01 -ScriptBlock {
    Get-Service WinRM
}
$remoteService.Stop()  # ❌ Ne fonctionne pas - objet désérialisé
```

### Format de sortie

```powershell
# Formater les résultats de plusieurs machines
Invoke-Command -ComputerName Server01, Server02 -ScriptBlock {
    Get-Process | Select-Object -First 3
} | Format-Table PSComputerName, ProcessName, CPU -AutoSize
```

### Exporter les résultats

```powershell
# Collecter et exporter vers CSV
Invoke-Command -ComputerName (Get-Content servers.txt) -ScriptBlock {
    Get-EventLog -LogName System -Newest 100 -EntryType Error
} | Export-Csv -Path "C:\Logs\SystemErrors.csv" -NoTypeInformation
```

> [!tip] Optimisation des résultats Si vous récupérez beaucoup de données, filtrez-les **sur la machine distante** (dans le ScriptBlock) plutôt que localement pour réduire le transfert réseau.
> 
> ```powershell
> # ✅ BON : Filtre distant
> Invoke-Command -ComputerName Server01 -ScriptBlock {
>     Get-Process | Where-Object CPU -gt 100
> }
> 
> # ❌ MOINS BON : Filtre local (transfert inutile)
> Invoke-Command -ComputerName Server01 -ScriptBlock {
>     Get-Process
> } | Where-Object CPU -gt 100
> ```

---

## ⚠️ Gestion des erreurs

### Paramètre `-ErrorAction`

Contrôler le comportement en cas d'erreur.

```powershell
# Continuer même en cas d'erreur
Invoke-Command -ComputerName Server01, Server02, ServerInexistant `
               -ErrorAction Continue `
               -ScriptBlock { Get-Service }

# Arrêter à la première erreur
Invoke-Command -ComputerName Server01, ServerInexistant `
               -ErrorAction Stop `
               -ScriptBlock { Get-Service }
```

### Erreurs par machine

Chaque machine peut réussir ou échouer indépendamment.

```powershell
$servers = "Server01", "ServerHS", "Server03"

$results = Invoke-Command -ComputerName $servers `
                          -ErrorAction SilentlyContinue `
                          -ErrorVariable remoteErrors `
                          -ScriptBlock { Get-Service WinRM }

# Afficher les machines qui ont réussi
$results | Select-Object PSComputerName, Name, Status

# Afficher les erreurs
$remoteErrors
```

### Bloc Try/Catch dans le ScriptBlock

```powershell
Invoke-Command -ComputerName Server01 -ScriptBlock {
    try {
        Stop-Service NonExistentService -ErrorAction Stop
        Write-Output "Service arrêté avec succès"
    }
    catch {
        Write-Warning "Erreur : $($_.Exception.Message)"
        # Logging ou action alternative
    }
}
```

### Collection des erreurs

```powershell
# Variable automatique $Error
$Error.Clear()  # Nettoyer les erreurs précédentes

Invoke-Command -ComputerName Server01, Server02 -ScriptBlock {
    Get-Service ServiceInexistant
}

# Analyser les erreurs
$Error | ForEach-Object {
    Write-Host "Erreur sur $($_.TargetObject) : $($_.Exception.Message)"
}
```

> [!warning] Gestion des connexions échouées Les machines inaccessibles génèrent des erreurs de connexion **avant** l'exécution du ScriptBlock. Utilisez `-ErrorAction SilentlyContinue` pour continuer malgré ces échecs.

---

## ✅ Bonnes pratiques

### 1. Toujours nettoyer les sessions

```powershell
# ✅ BON
$session = New-PSSession -ComputerName Server01
try {
    Invoke-Command -Session $session -ScriptBlock { Get-Service }
}
finally {
    Remove-PSSession $session
}

# ❌ MAUVAIS (session orpheline)
$session = New-PSSession -ComputerName Server01
Invoke-Command -Session $session -ScriptBlock { Get-Service }
# Oubli de Remove-PSSession
```

### 2. Privilégier les sessions pour plusieurs commandes

```powershell
# ❌ MAUVAIS : Reconnexion à chaque fois
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-Service }
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-Process }
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-EventLog -LogName System -Newest 10 }

# ✅ BON : Session réutilisée
$session = New-PSSession -ComputerName Server01
Invoke-Command -Session $session -ScriptBlock { Get-Service }
Invoke-Command -Session $session -ScriptBlock { Get-Process }
Invoke-Command -Session $session -ScriptBlock { Get-EventLog -LogName System -Newest 10 }
Remove-PSSession $session
```

### 3. Filtrer les données à la source

```powershell
# ❌ MAUVAIS : Transfert de toutes les données
Invoke-Command -ComputerName Server01 -ScriptBlock {
    Get-EventLog -LogName Application -Newest 10000
} | Where-Object EntryType -eq 'Error'

# ✅ BON : Filtrage distant
Invoke-Command -ComputerName Server01 -ScriptBlock {
    Get-EventLog -LogName Application -Newest 10000 -EntryType Error
}
```

### 4. Utiliser `-ThrottleLimit` intelligemment

```powershell
# Pour un grand nombre de serveurs, adapter le parallélisme
$servers = Get-Content "C:\1000servers.txt"

# ✅ BON : Limiter pour ne pas surcharger
Invoke-Command -ComputerName $servers `
               -ThrottleLimit 50 `
               -ScriptBlock { Get-Service }
```

### 5. Préférer `$using:` à `-ArgumentList` (PS 3.0+)

```powershell
$serviceName = "WinRM"

# ❌ FONCTIONNEL mais moins lisible
Invoke-Command -ComputerName Server01 -ScriptBlock {
    param($svc)
    Get-Service $svc
} -ArgumentList $serviceName

# ✅ MIEUX : Plus clair
Invoke-Command -ComputerName Server01 -ScriptBlock {
    Get-Service $using:serviceName
}
```

### 6. Gérer les erreurs de connexion

```powershell
# ✅ BON : Capture et logging des erreurs
$servers = "Server01", "Server02", "ServerHS"
$results = Invoke-Command -ComputerName $servers `
                          -ErrorAction SilentlyContinue `
                          -ErrorVariable connectionErrors `
                          -ScriptBlock { Get-Service }

# Traiter les succès
$results | Export-Csv "Success.csv"

# Logger les échecs
$connectionErrors | ForEach-Object {
    Add-Content "Errors.log" -Value "[$((Get-Date))] $($_.TargetObject) - $($_.Exception.Message)"
}
```

### 7. Utiliser des credentials sécurisés

```powershell
# ❌ MAUVAIS : Credentials en clair
$password = ConvertTo-SecureString "MotDePasse123" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("Admin", $password)

# ✅ MIEUX : Demander interactivement
$cred = Get-Credential

# ✅ MEILLEUR : Utiliser un coffre-fort de credentials
$cred = Get-StoredCredential -Target "ProdServers"
```

### 8. Documenter les ScriptBlocks complexes

```powershell
# ✅ BON : Code commenté et structuré
Invoke-Command -ComputerName $servers -ScriptBlock {
    # Collecter les informations système
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    
    # Calculer l'uptime
    $uptime = (Get-Date) - $os.LastBootUpTime
    
    # Retourner un objet structuré
    [PSCustomObject]@{
        Computer     = $env:COMPUTERNAME
        OS           = $os.Caption
        CPUModel     = $cpu.Name
        UptimeDays   = [math]::Round($uptime.TotalDays, 2)
        LastBoot     = $os.LastBootUpTime
    }
}
```

---

## 🎓 Récapitulatif

`Invoke-Command` est l'outil central du PowerShell Remoting :

- ✅ Exécution de commandes sur machines distantes
- ✅ Support d'exécution parallèle (jusqu'à 32 par défaut)
- ✅ Deux méthodes de passage d'arguments : `-ArgumentList` et `$using:`
- ✅ Sessions persistantes pour réutilisation avec `New-PSSession`
- ✅ Exécution de scripts locaux à distance avec `-FilePath`
- ✅ Options avancées : jobs, sessions déconnectées, endpoints personnalisés
- ✅ Métadonnées ajoutées aux résultats (`PSComputerName`)
- ✅ Gestion fine des erreurs par machine

> [!tip] Conseil final Commencez par des commandes simples sur une machine, puis augmentez progressivement la complexité : plusieurs machines, sessions persistantes, scripts externes. Testez toujours sur des environnements non-critiques avant de déployer en production.