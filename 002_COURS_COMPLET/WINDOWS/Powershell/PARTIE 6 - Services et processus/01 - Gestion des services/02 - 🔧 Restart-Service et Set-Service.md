

## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 3 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## 🔄 Restart-Service - Redémarrage de services

### Concept et utilité

`Restart-Service` permet de redémarrer un service Windows en effectuant un **arrêt complet suivi d'un démarrage**. Cette commande est essentielle pour :

- **Appliquer des modifications de configuration** : Après avoir changé un fichier de configuration, un redémarrage force le service à recharger ses paramètres
- **Résoudre des problèmes de stabilité** : Un service qui ne répond plus ou qui fonctionne mal peut être remis à zéro
- **Libérer des ressources** : Redémarrer un service libère la mémoire et les handles de fichiers qu'il utilise
- **Mettre à jour des dépendances** : Après une mise à jour de DLL ou de composants, le redémarrage charge les nouvelles versions

> [!info] Différence avec Stop-Service puis Start-Service `Restart-Service` effectue l'arrêt et le démarrage dans une seule opération atomique, ce qui garantit la cohérence et simplifie le code. Il gère également automatiquement le délai d'attente entre l'arrêt et le démarrage.

### Syntaxe de base

```powershell
Restart-Service [-Name] <String[]> 
    [-Force] 
    [-PassThru] 
    [-Include <String[]>] 
    [-Exclude <String[]>] 
    [-WhatIf] 
    [-Confirm]
```

**Forme minimale** :

```powershell
Restart-Service "NomDuService"
```

### Paramètres principaux

|Paramètre|Type|Description|
|---|---|---|
|`-Name`|String[]|Nom(s) du/des service(s) à redémarrer (accepte les wildcards)|
|`-DisplayName`|String[]|Nom d'affichage du service (alternative à -Name)|
|`-Force`|Switch|Force le redémarrage même si le service a des dépendances|
|`-PassThru`|Switch|Retourne un objet représentant le service après l'opération|
|`-WhatIf`|Switch|Simule l'action sans l'exécuter (très utile pour tester)|
|`-Confirm`|Switch|Demande confirmation avant d'exécuter|

> [!warning] Droits administrateur Le redémarrage de services nécessite des **privilèges administrateur**. Lancez PowerShell en tant qu'administrateur pour exécuter ces commandes.

### Exemples pratiques

#### Redémarrage simple

```powershell
# Redémarrer le service Spooler (impression)
Restart-Service -Name Spooler

# Redémarrer en utilisant le nom d'affichage
Restart-Service -DisplayName "Print Spooler"
```

#### Redémarrage avec confirmation

```powershell
# Demander confirmation avant de redémarrer
Restart-Service -Name wuauserv -Confirm

# Simuler le redémarrage sans l'exécuter (test)
Restart-Service -Name wuauserv -WhatIf
```

#### Redémarrage forcé avec dépendances

```powershell
# Forcer le redémarrage même si d'autres services dépendent de celui-ci
Restart-Service -Name W3SVC -Force

# Exemple : IIS a souvent des services dépendants
# Sans -Force, PowerShell refuserait le redémarrage
```

#### Redémarrage avec gestion du retour

```powershell
# Récupérer l'objet service après redémarrage
$service = Restart-Service -Name Spooler -PassThru

# Afficher le statut après redémarrage
Write-Host "Service $($service.DisplayName) est maintenant : $($service.Status)"
```

#### Redémarrage multiple avec wildcard

```powershell
# Redémarrer tous les services dont le nom commence par "Windows"
Restart-Service -Name "Windows*" -Force

# Redémarrer tous les services sauf certains
Restart-Service -Name "App*" -Exclude "AppXSvc"
```

#### Redémarrage avec timeout personnalisé

```powershell
# Script avec gestion du timeout
$serviceName = "MyService"
$timeout = 30 # secondes

try {
    Restart-Service -Name $serviceName -ErrorAction Stop
    
    # Attendre que le service soit complètement démarré
    $service = Get-Service -Name $serviceName
    $service.WaitForStatus('Running', (New-TimeSpan -Seconds $timeout))
    
    Write-Host "✓ Service redémarré avec succès" -ForegroundColor Green
}
catch [System.ServiceProcess.TimeoutException] {
    Write-Warning "⚠ Le service n'a pas démarré dans les $timeout secondes"
}
catch {
    Write-Error "✗ Erreur lors du redémarrage : $_"
}
```

### Gestion des erreurs

```powershell
# Vérifier si le service existe avant de redémarrer
if (Get-Service -Name "MonService" -ErrorAction SilentlyContinue) {
    Restart-Service -Name "MonService"
    Write-Host "Service redémarré"
} else {
    Write-Warning "Le service n'existe pas"
}

# Gestion complète avec try-catch
try {
    Restart-Service -Name "MonService" -ErrorAction Stop
    Write-Host "✓ Redémarrage réussi" -ForegroundColor Green
}
catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
    Write-Error "Erreur de service : $($_.Exception.Message)"
}
catch {
    Write-Error "Erreur inattendue : $_"
}
```

### Bonnes pratiques

> [!tip] Conseils d'utilisation
> 
> - **Toujours utiliser `-WhatIf`** avant d'exécuter sur un système de production
> - **Vérifier l'existence du service** avec `Get-Service` avant de le redémarrer
> - **Utiliser `-Force` avec précaution** car cela peut affecter les services dépendants
> - **Implémenter un timeout** pour éviter les blocages indéfinis
> - **Logger les redémarrages** dans un fichier pour traçabilité

> [!warning] Pièges courants
> 
> - Ne pas confondre le **nom du service** (-Name) avec le **nom d'affichage** (-DisplayName)
> - Le service doit être à l'état "Running" ou "Stopped" pour être redémarré (pas "Paused")
> - Les services avec dépendances peuvent nécessiter `-Force` ou échouer
> - Un redémarrage peut prendre du temps, ne pas supposer qu'il est instantané

---

## ⚙️ Set-Service - Configuration de services

### Concept et utilité

`Set-Service` permet de **modifier la configuration d'un service Windows** sans nécessairement le redémarrer. Cette commande est utilisée pour :

- **Changer le mode de démarrage** : Automatic, Manual, Disabled
- **Modifier les informations affichées** : DisplayName, Description
- **Changer le statut** : Démarrer ou arrêter le service
- **Configurer les identifiants** : Compte utilisateur sous lequel le service s'exécute
- **Définir les dépendances** : Services dont dépend le service configuré

> [!info] Persistance des modifications Contrairement à `Start-Service` ou `Stop-Service`, les modifications effectuées par `Set-Service` sont **permanentes** et persistent après le redémarrage du système.

### Syntaxe de base

```powershell
Set-Service [-Name] <String>
    [-DisplayName <String>]
    [-Description <String>]
    [-StartupType <ServiceStartMode>]
    [-Status <String>]
    [-Credential <PSCredential>]
    [-Force]
    [-PassThru]
    [-WhatIf]
    [-Confirm]
```

**Forme minimale** :

```powershell
Set-Service -Name "NomDuService" -StartupType Automatic
```

### Paramètres principaux

|Paramètre|Type|Description|
|---|---|---|
|`-Name`|String|Nom du service à configurer (obligatoire)|
|`-DisplayName`|String|Nouveau nom d'affichage du service|
|`-Description`|String|Nouvelle description du service|
|`-StartupType`|ServiceStartMode|Mode de démarrage : `Automatic`, `Manual`, `Disabled`, `AutomaticDelayedStart`|
|`-Status`|String|État souhaité : `Running`, `Stopped`, `Paused`|
|`-Credential`|PSCredential|Identifiants pour exécuter le service|
|`-Force`|Switch|Force l'arrêt si `-Status Stopped` et que des services dépendent de lui|
|`-PassThru`|Switch|Retourne l'objet service après modification|

> [!warning] Droits administrateur requis Toutes les modifications de configuration de service nécessitent des **privilèges administrateur**.

### Exemples pratiques

#### Modification du type de démarrage

```powershell
# Définir un service en démarrage automatique
Set-Service -Name "wuauserv" -StartupType Automatic

# Définir en démarrage manuel
Set-Service -Name "Spooler" -StartupType Manual

# Désactiver complètement un service
Set-Service -Name "Fax" -StartupType Disabled

# Démarrage automatique différé (démarrage après les services critiques)
Set-Service -Name "BITS" -StartupType AutomaticDelayedStart
```

> [!info] Types de démarrage
> 
> - **Automatic** : Démarre au boot du système
> - **AutomaticDelayedStart** : Démarre ~2 minutes après le boot (moins de charge au démarrage)
> - **Manual** : Démarre uniquement quand sollicité
> - **Disabled** : Ne peut pas être démarré

#### Modification du nom et de la description

```powershell
# Changer le nom d'affichage
Set-Service -Name "wuauserv" -DisplayName "Service de mise à jour Windows personnalisé"

# Modifier la description
Set-Service -Name "MyService" -Description "Service personnalisé pour la gestion des données"

# Modifier les deux en même temps
Set-Service -Name "AppService" `
    -DisplayName "Application Service Manager" `
    -Description "Gère les processus de l'application principale"
```

#### Démarrer ou arrêter via Set-Service

```powershell
# Démarrer un service
Set-Service -Name "Spooler" -Status Running

# Arrêter un service
Set-Service -Name "Spooler" -Status Stopped

# Arrêter avec force (si des dépendances existent)
Set-Service -Name "W3SVC" -Status Stopped -Force
```

> [!tip] Préférer les cmdlets spécialisées Pour démarrer/arrêter des services, il est généralement préférable d'utiliser `Start-Service` et `Stop-Service` qui sont plus explicites et offrent de meilleures options de gestion d'erreurs.

#### Configuration complète d'un service

```powershell
# Configuration complète en une seule commande
Set-Service -Name "MyCustomService" `
    -DisplayName "Mon Service Personnalisé" `
    -Description "Service gérant les opérations personnalisées" `
    -StartupType Automatic `
    -Status Running `
    -PassThru | Format-List Name, DisplayName, Status, StartType
```

#### Modification avec vérification

```powershell
# Vérifier avant modification
$service = Get-Service -Name "Spooler"
Write-Host "État actuel : $($service.StartType)"

# Modifier
Set-Service -Name "Spooler" -StartupType Automatic -WhatIf

# Si tout est OK, exécuter sans -WhatIf
Set-Service -Name "Spooler" -StartupType Automatic

# Vérifier après modification
$service = Get-Service -Name "Spooler"
Write-Host "Nouvel état : $($service.StartType)"
```

### Configurations courantes

#### Désactiver un service inutilisé

```powershell
# Désactiver et arrêter un service en toute sécurité
$serviceName = "Fax"

# Arrêter d'abord
Stop-Service -Name $serviceName -ErrorAction SilentlyContinue

# Puis désactiver
Set-Service -Name $serviceName -StartupType Disabled

Write-Host "Service $serviceName désactivé"
```

#### Configurer un service pour le démarrage automatique

```powershell
# Configuration complète pour un service d'application
$serviceName = "MyAppService"

try {
    Set-Service -Name $serviceName `
        -StartupType Automatic `
        -ErrorAction Stop
    
    Start-Service -Name $serviceName -ErrorAction Stop
    
    Write-Host "✓ Service configuré et démarré" -ForegroundColor Green
}
catch {
    Write-Error "Erreur de configuration : $_"
}
```

#### Script de configuration de plusieurs services

```powershell
# Configuration en masse de plusieurs services
$servicesConfig = @(
    @{Name="Spooler"; StartupType="Automatic"},
    @{Name="BITS"; StartupType="AutomaticDelayedStart"},
    @{Name="Fax"; StartupType="Disabled"}
)

foreach ($config in $servicesConfig) {
    try {
        Set-Service -Name $config.Name -StartupType $config.StartupType -ErrorAction Stop
        Write-Host "✓ $($config.Name) configuré en $($config.StartupType)" -ForegroundColor Green
    }
    catch {
        Write-Warning "⚠ Erreur pour $($config.Name) : $_"
    }
}
```

#### Restaurer une configuration par défaut

```powershell
# Fonction pour restaurer un service à sa configuration d'origine
function Restore-ServiceDefaults {
    param(
        [string]$ServiceName,
        [string]$DefaultStartupType = "Automatic"
    )
    
    try {
        $service = Get-Service -Name $ServiceName -ErrorAction Stop
        
        Set-Service -Name $ServiceName -StartupType $DefaultStartupType
        
        if ($service.Status -eq 'Stopped' -and $DefaultStartupType -eq 'Automatic') {
            Start-Service -Name $ServiceName
        }
        
        Write-Host "✓ Service $ServiceName restauré" -ForegroundColor Green
    }
    catch {
        Write-Error "Impossible de restaurer $ServiceName : $_"
    }
}

# Utilisation
Restore-ServiceDefaults -ServiceName "Spooler" -DefaultStartupType "Automatic"
```

### Bonnes pratiques

> [!tip] Recommandations
> 
> - **Documenter les changements** : Noter pourquoi un service a été désactivé ou modifié
> - **Utiliser `-WhatIf`** pour tester avant d'appliquer sur production
> - **Sauvegarder la configuration** : Exporter l'état actuel avec `Get-Service` avant modification
> - **Tester après modification** : Vérifier que le service fonctionne comme attendu
> - **Attention au démarrage automatique** : Ne pas tout mettre en Automatic, cela ralentit le boot

> [!warning] Erreurs courantes
> 
> - **Ne pas désactiver des services système critiques** (comme RpcSs, DcomLaunch)
> - **Vérifier les dépendances** avant de désactiver un service
> - **AutomaticDelayedStart** n'est pas supporté sur toutes les versions de Windows
> - Les modifications avec `-Status` peuvent échouer si le service est verrouillé
> - Certains services ne peuvent pas être modifiés (protégés par le système)

---

## 🔄 Comparaison et cas d'usage

### Quand utiliser Restart-Service vs Set-Service

|Situation|Commande|Raison|
|---|---|---|
|Appliquer un changement de config (fichier .config, .ini)|`Restart-Service`|Recharge les paramètres en mémoire|
|Service qui ne répond plus|`Restart-Service`|Réinitialise l'état du service|
|Changer le mode de démarrage|`Set-Service`|Modification permanente|
|Désactiver un service inutilisé|`Set-Service`|Configure l'état au boot|
|Après une mise à jour de DLL|`Restart-Service`|Charge les nouvelles versions|
|Modifier la description d'un service|`Set-Service`|Métadonnée, pas besoin de redémarrage|
|Libérer de la mémoire/ressources|`Restart-Service`|Nettoie les handles et la mémoire|

### Script combiné : Configuration + Redémarrage

```powershell
# Script complet de gestion d'un service
function Configure-AndRestartService {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServiceName,
        
        [ValidateSet('Automatic', 'Manual', 'Disabled', 'AutomaticDelayedStart')]
        [string]$StartupType,
        
        [switch]$RestartIfRunning
    )
    
    try {
        # Récupérer l'état actuel
        $service = Get-Service -Name $ServiceName -ErrorAction Stop
        Write-Host "État actuel : $($service.Status) - $($service.StartType)"
        
        # Configurer le type de démarrage si spécifié
        if ($StartupType) {
            Set-Service -Name $ServiceName -StartupType $StartupType -ErrorAction Stop
            Write-Host "✓ Type de démarrage changé en : $StartupType" -ForegroundColor Green
        }
        
        # Redémarrer si nécessaire
        if ($RestartIfRunning -and $service.Status -eq 'Running') {
            Write-Host "Redémarrage du service..." -ForegroundColor Yellow
            Restart-Service -Name $ServiceName -Force -ErrorAction Stop
            Write-Host "✓ Service redémarré" -ForegroundColor Green
        }
        
        # Afficher l'état final
        $service = Get-Service -Name $ServiceName
        Write-Host "`nÉtat final : $($service.Status) - $($service.StartType)" -ForegroundColor Cyan
    }
    catch {
        Write-Error "Erreur lors de la configuration : $_"
    }
}

# Exemples d'utilisation
Configure-AndRestartService -ServiceName "Spooler" -StartupType Automatic -RestartIfRunning
Configure-AndRestartService -ServiceName "BITS" -StartupType AutomaticDelayedStart
```

> [!example] Cas d'usage réel **Scénario** : Déploiement d'une nouvelle version d'application
> 
> ```powershell
> # 1. Arrêter le service
> Stop-Service -Name "MyAppService"
> 
> # 2. Déployer les fichiers (copie, etc.)
> # ... code de déploiement ...
> 
> # 3. Configurer pour démarrage automatique
> Set-Service -Name "MyAppService" -StartupType Automatic
> 
> # 4. Redémarrer
> Start-Service -Name "MyAppService"
> 
> # Vérification
> Get-Service -Name "MyAppService" | Select-Object Name, Status, StartType
> ```

---

## 🎯 Résumé des points clés

> [!info] À retenir
> 
> - **Restart-Service** = Action immédiate (stop + start)
> - **Set-Service** = Configuration permanente
> - Les deux nécessitent des droits administrateur
> - Toujours tester avec `-WhatIf` avant d'exécuter
> - Gérer les erreurs avec try-catch
> - Vérifier les dépendances avec `-Force` si nécessaire
> - Documenter les modifications pour maintenance future