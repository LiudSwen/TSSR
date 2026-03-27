

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

## Introduction

La gestion du service OpenSSH sous Windows est essentielle pour contrôler le serveur SSH et garantir sa disponibilité. Windows traite OpenSSH comme un service système standard, ce qui permet une gestion flexible via l'interface graphique ou PowerShell.

> [!info] Pourquoi gérer le service OpenSSH ?
> 
> - **Contrôle de la disponibilité** : Démarrer/arrêter le serveur selon vos besoins
> - **Sécurité** : Désactiver le service quand il n'est pas nécessaire
> - **Automatisation** : Configurer le démarrage automatique au boot
> - **Maintenance** : Redémarrer le service après modification de configuration

---

## Services Windows (services.msc)

### Accès à l'interface graphique des services

L'outil `services.msc` est l'interface graphique native de Windows pour gérer tous les services système.

#### Méthodes d'accès

**Méthode 1 : Via la commande Exécuter**

```bash
# Appuyez sur Win + R, puis tapez :
services.msc
```

**Méthode 2 : Via le menu Démarrer**

- Recherchez "Services" dans le menu Démarrer
- Cliquez sur "Services" (application de bureau)

**Méthode 3 : Via le Gestionnaire des tâches**

- Ouvrez le Gestionnaire des tâches (Ctrl + Shift + Esc)
- Onglet "Services" → Bouton "Ouvrir les Services"

### Localisation du service OpenSSH

Une fois dans `services.msc`, vous devez identifier le service OpenSSH :

> [!example] Services OpenSSH à rechercher
> 
> - **OpenSSH SSH Server** : Le serveur SSH (sshd)
> - **OpenSSH Authentication Agent** : Agent pour la gestion des clés (ssh-agent)

Les services sont classés par ordre alphabétique dans la liste.

### Actions disponibles dans l'interface graphique

#### Démarrer le service

1. Faites un clic droit sur **OpenSSH SSH Server**
2. Sélectionnez **Démarrer**
3. Le statut passe à "En cours d'exécution"

#### Arrêter le service

1. Clic droit sur le service
2. Sélectionnez **Arrêter**
3. Le statut devient vide (service arrêté)

#### Redémarrer le service

1. Clic droit sur le service
2. Sélectionnez **Redémarrer**

> [!tip] Quand redémarrer le service ? Redémarrez le service OpenSSH après :
> 
> - Modification du fichier `sshd_config`
> - Ajout/suppression de clés autorisées
> - Changement des paramètres de sécurité

#### Propriétés du service

Double-cliquez sur le service pour accéder aux propriétés détaillées :

|Onglet|Description|
|---|---|
|**Général**|Type de démarrage, état actuel, chemin de l'exécutable|
|**Connexion**|Compte utilisé pour exécuter le service|
|**Récupération**|Actions en cas d'échec du service|
|**Dépendances**|Services dont dépend OpenSSH|

---

## Gestion via PowerShell

PowerShell offre une approche plus puissante et scriptable pour gérer les services OpenSSH.

### Commandes de base

#### Lister les services OpenSSH

```powershell
# Afficher tous les services OpenSSH
Get-Service -Name *ssh*

# Sortie exemple :
# Status   Name               DisplayName
# ------   ----               -----------
# Stopped  ssh-agent          OpenSSH Authentication Agent
# Running  sshd               OpenSSH SSH Server
```

#### Obtenir des informations détaillées

```powershell
# Informations détaillées sur le serveur SSH
Get-Service -Name sshd | Format-List *

# Informations sur l'agent SSH
Get-Service -Name ssh-agent | Select-Object Name, Status, StartType
```

> [!info] Noms des services
> 
> - **sshd** : Serveur SSH (SSH Daemon)
> - **ssh-agent** : Agent d'authentification SSH

### Démarrer et arrêter les services

#### Démarrer un service

```powershell
# Démarrer le serveur SSH
Start-Service sshd

# Démarrer l'agent SSH
Start-Service ssh-agent

# Vérification immédiate du démarrage
Start-Service sshd -PassThru
```

> [!warning] Privilèges administrateur requis Toutes les commandes de gestion de service nécessitent une session PowerShell en tant qu'administrateur.

#### Arrêter un service

```powershell
# Arrêter le serveur SSH
Stop-Service sshd

# Arrêter proprement avec confirmation
Stop-Service sshd -Force

# Arrêter et vérifier
Stop-Service sshd -PassThru
```

#### Redémarrer un service

```powershell
# Redémarrer le serveur SSH
Restart-Service sshd

# Redémarrer avec sortie de confirmation
Restart-Service sshd -PassThru -Verbose
```

### Gestion avancée avec PowerShell

#### Démarrer plusieurs services simultanément

```powershell
# Démarrer serveur et agent en même temps
Start-Service sshd, ssh-agent

# Avec vérification
'sshd', 'ssh-agent' | ForEach-Object {
    Start-Service $_ -PassThru
}
```

#### Vérifier si un service est en cours d'exécution

```powershell
# Méthode 1 : Test simple
$service = Get-Service sshd
if ($service.Status -eq 'Running') {
    Write-Host "SSH est actif" -ForegroundColor Green
} else {
    Write-Host "SSH est inactif" -ForegroundColor Red
}

# Méthode 2 : Test avec action
if ((Get-Service sshd).Status -ne 'Running') {
    Start-Service sshd
    Write-Host "Service SSH démarré"
}
```

#### Attendre qu'un service soit complètement démarré

```powershell
# Démarrer et attendre la fin du démarrage
Start-Service sshd
Wait-Service sshd -Status Running -Timeout 30

# Avec gestion d'erreur
try {
    Start-Service sshd
    Wait-Service sshd -Status Running -Timeout 10
    Write-Host "Service démarré avec succès"
} catch {
    Write-Error "Échec du démarrage du service SSH"
}
```

---

## Configuration du démarrage automatique

Le type de démarrage détermine comment le service se comporte au démarrage de Windows.

### Types de démarrage disponibles

|Type|Comportement|Utilisation recommandée|
|---|---|---|
|**Automatic**|Démarre automatiquement au boot|Serveur SSH permanent|
|**Automatic (Delayed Start)**|Démarre après le boot (2 min)|Évite surcharge au démarrage|
|**Manual**|Démarre uniquement sur demande|Usage occasionnel|
|**Disabled**|Ne peut pas être démarré|Désactivation complète|

### Configuration via services.msc

1. Double-cliquez sur **OpenSSH SSH Server**
2. Onglet **Général**
3. Dans **Type de démarrage**, sélectionnez :
    - **Automatique** pour un démarrage immédiat
    - **Automatique (différé)** pour un démarrage retardé
    - **Manuel** pour un démarrage à la demande
4. Cliquez sur **Appliquer** puis **OK**

> [!tip] Démarrage différé recommandé Pour un serveur SSH, le **démarrage automatique différé** est souvent préférable. Il permet au système d'initialiser complètement avant de démarrer SSH, évitant les conflits potentiels.

### Configuration via PowerShell

#### Définir le type de démarrage

```powershell
# Démarrage automatique
Set-Service -Name sshd -StartupType Automatic

# Démarrage automatique différé
Set-Service -Name sshd -StartupType AutomaticDelayedStart

# Démarrage manuel
Set-Service -Name sshd -StartupType Manual

# Désactiver le service
Set-Service -Name sshd -StartupType Disabled
```

#### Vérifier le type de démarrage actuel

```powershell
# Afficher le type de démarrage
Get-Service sshd | Select-Object Name, StartType

# Affichage détaillé
Get-CimInstance -ClassName Win32_Service -Filter "Name='sshd'" | 
    Select-Object Name, StartMode, State
```

#### Configuration complète en une commande

```powershell
# Configurer en automatique et démarrer immédiatement
Set-Service -Name sshd -StartupType Automatic -Status Running

# Équivalent avec vérification
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd
Get-Service sshd
```

### Script de configuration automatisée

```powershell
# Script complet pour configurer SSH au démarrage
# Exécuter en tant qu'administrateur

# Fonction de vérification
function Configure-SSHAutoStart {
    try {
        # Vérifier si le service existe
        $service = Get-Service sshd -ErrorAction Stop
        
        # Configurer en démarrage automatique différé
        Set-Service -Name sshd -StartupType AutomaticDelayedStart
        Write-Host "✓ Type de démarrage configuré : Automatique (différé)" -ForegroundColor Green
        
        # Démarrer le service si nécessaire
        if ($service.Status -ne 'Running') {
            Start-Service sshd
            Write-Host "✓ Service SSH démarré" -ForegroundColor Green
        }
        
        # Afficher le statut final
        $finalStatus = Get-Service sshd | Select-Object Name, Status, StartType
        Write-Host "`nStatut final :" -ForegroundColor Cyan
        $finalStatus | Format-Table -AutoSize
        
    } catch {
        Write-Error "Erreur lors de la configuration : $_"
    }
}

# Exécution
Configure-SSHAutoStart
```

> [!warning] Impact sur les performances Un service en démarrage automatique consomme des ressources même s'il n'est pas utilisé. Sur un poste client, préférez le **démarrage manuel** si vous n'utilisez SSH qu'occasionnellement.

---

## Vérification du statut

La vérification régulière du statut permet de s'assurer que le service fonctionne correctement.

### Vérification via services.msc

Dans l'interface `services.msc`, le statut s'affiche dans la colonne **État** :

- **(vide)** : Service arrêté
- **En cours d'exécution** : Service actif
- **Démarrage en cours...** : En train de démarrer
- **Arrêt en cours...** : En train de s'arrêter

### Vérification via PowerShell

#### Commandes de base

```powershell
# Statut simple
Get-Service sshd

# Statut détaillé
Get-Service sshd | Format-List *

# Affichage personnalisé
Get-Service sshd | Select-Object Name, DisplayName, Status, StartType
```

#### Vérification avec code de sortie

```powershell
# Test du statut pour scripts
if ((Get-Service sshd).Status -eq 'Running') {
    Write-Host "✓ SSH actif" -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ SSH inactif" -ForegroundColor Red
    exit 1
}
```

#### Vérification de l'écoute réseau

```powershell
# Vérifier que SSH écoute sur le port 22
Get-NetTCPConnection -LocalPort 22 -State Listen -ErrorAction SilentlyContinue

# Version détaillée
Get-NetTCPConnection -LocalPort 22 | 
    Select-Object LocalAddress, LocalPort, State, OwningProcess

# Afficher le processus associé
$connections = Get-NetTCPConnection -LocalPort 22 -ErrorAction SilentlyContinue
if ($connections) {
    $process = Get-Process -Id $connections[0].OwningProcess
    Write-Host "SSH écoute sur le port 22 (PID: $($process.Id), $($process.Name))"
} else {
    Write-Host "Aucun service n'écoute sur le port 22" -ForegroundColor Yellow
}
```

> [!tip] Port par défaut SSH utilise par défaut le port **22** pour les connexions TCP. Si le service est actif mais que personne n'écoute sur ce port, il y a probablement un problème de configuration.

### Script de diagnostic complet

```powershell
# Script de vérification complète du statut SSH
function Get-SSHStatus {
    Write-Host "`n=== Diagnostic SSH Windows ===" -ForegroundColor Cyan
    
    # 1. Statut du service
    Write-Host "`n[1] Statut du service" -ForegroundColor Yellow
    $service = Get-Service sshd -ErrorAction SilentlyContinue
    if ($service) {
        $service | Format-Table Name, DisplayName, Status, StartType -AutoSize
    } else {
        Write-Host "  ✗ Service non installé" -ForegroundColor Red
        return
    }
    
    # 2. Écoute réseau
    Write-Host "[2] Écoute réseau (port 22)" -ForegroundColor Yellow
    $listening = Get-NetTCPConnection -LocalPort 22 -State Listen -ErrorAction SilentlyContinue
    if ($listening) {
        Write-Host "  ✓ SSH écoute sur le port 22" -ForegroundColor Green
        $listening | Format-Table LocalAddress, LocalPort, State -AutoSize
    } else {
        Write-Host "  ✗ Aucune écoute sur le port 22" -ForegroundColor Red
    }
    
    # 3. Processus en cours
    Write-Host "[3] Processus SSH" -ForegroundColor Yellow
    $sshProcess = Get-Process sshd -ErrorAction SilentlyContinue
    if ($sshProcess) {
        Write-Host "  ✓ Processus actif" -ForegroundColor Green
        $sshProcess | Format-Table Id, ProcessName, StartTime, CPU -AutoSize
    } else {
        Write-Host "  ✗ Aucun processus sshd actif" -ForegroundColor Red
    }
    
    # 4. Règles de pare-feu
    Write-Host "[4] Règles de pare-feu" -ForegroundColor Yellow
    $fwRules = Get-NetFirewallRule -DisplayName "*OpenSSH*" -ErrorAction SilentlyContinue
    if ($fwRules) {
        $fwRules | Format-Table DisplayName, Enabled, Direction -AutoSize
    } else {
        Write-Host "  ⚠ Aucune règle de pare-feu trouvée" -ForegroundColor Yellow
    }
    
    # 5. Résumé
    Write-Host "`n=== Résumé ===" -ForegroundColor Cyan
    if ($service.Status -eq 'Running' -and $listening) {
        Write-Host "✓ SSH est opérationnel et prêt à accepter des connexions" -ForegroundColor Green
    } else {
        Write-Host "✗ SSH n'est pas complètement opérationnel" -ForegroundColor Red
        if ($service.Status -ne 'Running') {
            Write-Host "  → Démarrez le service : Start-Service sshd" -ForegroundColor Yellow
        }
    }
}

# Exécution
Get-SSHStatus
```

### Surveillance continue

```powershell
# Surveiller le statut en temps réel (actualisation toutes les 5 secondes)
while ($true) {
    Clear-Host
    Write-Host "Surveillance SSH - $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
    Get-Service sshd | Format-Table Name, Status, StartType -AutoSize
    Get-NetTCPConnection -LocalPort 22 -State Listen -ErrorAction SilentlyContinue | 
        Format-Table LocalAddress, LocalPort, State -AutoSize
    Start-Sleep -Seconds 5
}
```

---

## Bonnes pratiques

### Sécurité

> [!warning] Recommandations de sécurité
> 
> - **N'activez le démarrage automatique** que si vous utilisez SSH régulièrement
> - **Arrêtez le service** quand vous ne l'utilisez pas pour réduire la surface d'attaque
> - **Surveillez les logs** du service dans l'Observateur d'événements Windows
> - **Configurez le pare-feu** pour limiter l'accès au port 22

### Maintenance

```powershell
# Vérification hebdomadaire automatisée
$checkScript = {
    $service = Get-Service sshd
    if ($service.Status -ne 'Running' -and $service.StartType -eq 'Automatic') {
        Start-Service sshd
        # Envoyer une alerte ou log l'événement
        Write-EventLog -LogName Application -Source "SSH Monitor" `
            -EntryType Warning -EventId 1001 `
            -Message "Service SSH redémarré automatiquement"
    }
}

# Créer une tâche planifiée pour exécuter ce script
```

### Performance

> [!tip] Optimisation des performances
> 
> - Utilisez **Automatic (Delayed Start)** pour éviter la surcharge au démarrage
> - Si vous utilisez rarement SSH, préférez le **démarrage manuel**
> - Surveillez l'utilisation mémoire du processus `sshd` avec `Get-Process sshd`

### Dépannage rapide

|Problème|Solution|
|---|---|
|Service ne démarre pas|Vérifiez les logs dans `Observateur d'événements` → `Applications et services` → `OpenSSH`|
|Port 22 déjà utilisé|Identifiez le processus : `Get-NetTCPConnection -LocalPort 22`|
|Accès refusé|Exécutez PowerShell en tant qu'administrateur|
|Service démarre puis s'arrête|Vérifiez la syntaxe du fichier `sshd_config`|

---

> [!info] Points clés à retenir
> 
> - **services.msc** : Interface graphique simple pour les opérations de base
> - **PowerShell** : Gestion avancée et automatisation
> - **Type de démarrage** : Choisissez selon votre usage (Automatic, Manual, Disabled)
> - **Vérification** : Testez toujours le statut et l'écoute réseau après modification
> - **Sécurité** : N'activez le service que quand nécessaire