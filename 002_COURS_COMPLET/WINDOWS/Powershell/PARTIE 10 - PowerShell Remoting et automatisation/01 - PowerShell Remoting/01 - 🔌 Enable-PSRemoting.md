

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

## 🎯 Introduction

**Enable-PSRemoting** est la cmdlet qui active PowerShell Remoting sur une machine Windows. Elle permet de gérer des ordinateurs distants via PowerShell en configurant automatiquement tous les composants nécessaires à la communication à distance.

> [!info] Pourquoi utiliser Enable-PSRemoting ?
> 
> - Gérer plusieurs serveurs depuis une seule console
> - Automatiser des tâches d'administration à distance
> - Exécuter des scripts sur des machines distantes
> - Centraliser la gestion de l'infrastructure Windows

> [!warning] À savoir Enable-PSRemoting modifie des paramètres système critiques et nécessite des privilèges administrateur. C'est une opération à effectuer en connaissance de cause.

---

## 🔍 Concept et fonctionnement

PowerShell Remoting s'appuie sur **WS-Management** (WSMan), un protocole standardisé basé sur SOAP qui utilise HTTP/HTTPS pour la communication. Microsoft implémente ce protocole via le service **WinRM** (Windows Remote Management).

### Architecture de base

```
Machine locale (Client)          Machine distante (Serveur)
    PowerShell                        Service WinRM
       ↓                                    ↑
   WSMan Client    ←→ [HTTP/HTTPS] ←→  Listener WinRM
                      Port 5985/5986
```

### Flux de communication

1. Le client établit une connexion au listener WinRM distant
2. L'authentification est effectuée (Kerberos/NTLM)
3. Le trafic est chiffré
4. Les commandes sont sérialisées en XML et envoyées
5. Le serveur exécute les commandes dans une session PowerShell
6. Les résultats sont renvoyés au client

---

## ⚙️ Configuration automatique

Lorsque vous exécutez `Enable-PSRemoting`, PowerShell effectue automatiquement plusieurs opérations critiques :

### 1. Service WinRM

```powershell
# Démarre le service WinRM
Start-Service WinRM

# Configure le démarrage automatique
Set-Service WinRM -StartupType Automatic
```

> [!tip] Le service WinRM doit être en cours d'exécution en permanence pour que PowerShell Remoting fonctionne.

### 2. Création des listeners

La cmdlet crée automatiquement deux types de listeners :

|Type|Port|Protocole|Usage|
|---|---|---|---|
|HTTP|5985|Non chiffré (mais authentifié)|Par défaut, réseaux de confiance|
|HTTPS|5986|Chiffré avec certificat SSL|Recommandé pour Internet|

```powershell
# Vérifier les listeners créés
Get-WSManInstance -ResourceURI winrm/config/listener -Enumerate
```

### 3. Configuration du firewall

Des règles de pare-feu sont automatiquement créées pour autoriser le trafic WinRM :

- **Règle entrante** : Autorise les connexions sur les ports 5985/5986
- **Profils concernés** : Domaine et Privé par défaut
- **Nom de la règle** : "Windows Remote Management (HTTP-In)"

```powershell
# Vérifier les règles de firewall
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" | Select-Object Name, Enabled, Profile
```

### 4. Configuration des endpoints

PowerShell crée des **endpoints** (ou session configurations) qui définissent l'environnement d'exécution pour les sessions distantes :

- `Microsoft.PowerShell` : Configuration par défaut
- `Microsoft.PowerShell.Workflow` : Pour les workflows
- `Microsoft.PowerShell32` : Pour les sessions 32-bit

> [!example] Exemple de configuration
> 
> ```powershell
> # Voir toutes les configurations de session
> Get-PSSessionConfiguration
> ```

---

## 🚀 Exécution et syntaxe

### Syntaxe de base

```powershell
# Activation standard avec confirmation
Enable-PSRemoting

# Activation sans confirmation (recommandé pour les scripts)
Enable-PSRemoting -Force

# Activation sur un réseau public (non recommandé en production)
Enable-PSRemoting -SkipNetworkProfileCheck -Force
```

### Paramètres principaux

|Paramètre|Description|Usage|
|---|---|---|
|`-Force`|Supprime toutes les demandes de confirmation|Scripts automatisés|
|`-SkipNetworkProfileCheck`|Autorise sur réseaux publics|Laptops, environnements de test|
|`-Confirm`|Demande confirmation explicite|Exécution interactive|
|`-WhatIf`|Simule l'exécution sans modifications|Tests préalables|

> [!example] Exemple pratique
> 
> ```powershell
> # Activation complète en une commande
> Enable-PSRemoting -Force -SkipNetworkProfileCheck
> 
> # Vérifier ce qui serait fait sans l'exécuter
> Enable-PSRemoting -WhatIf
> ```

### Élévation des privilèges

```powershell
# Vérifier si vous êtes administrateur
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "Cette commande nécessite des privilèges administrateur"
    # Redémarrer PowerShell en tant qu'administrateur
    Start-Process powershell -Verb RunAs -ArgumentList "-Command Enable-PSRemoting -Force"
}
```

---

## 📋 Prérequis techniques

### Versions Windows compatibles

|Système d'exploitation|Version minimale|PowerShell minimum|
|---|---|---|
|Windows Server|2008|2.0|
|Windows Vista|SP1|2.0|
|Windows 7/8/10/11|Toutes|2.0+ (5.1+ recommandé)|

### Vérifications préalables

```powershell
# 1. Vérifier la version de PowerShell
$PSVersionTable.PSVersion

# 2. Vérifier les privilèges administrateur
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# 3. Vérifier si WinRM est disponible
Get-Service WinRM

# 4. Vérifier le profil réseau (Domaine/Privé recommandé)
Get-NetConnectionProfile | Select-Object Name, NetworkCategory
```

> [!warning] Profil réseau Public Par défaut, Enable-PSRemoting échoue sur un profil réseau Public pour des raisons de sécurité. Utilisez `-SkipNetworkProfileCheck` uniquement si vous comprenez les risques.

### Exigences réseau

- **Ports ouverts** : 5985 (HTTP) et/ou 5986 (HTTPS)
- **Résolution DNS** : Les noms d'hôtes doivent être résolvables
- **Connectivité réseau** : Pas de blocage par pare-feu intermédiaire
- **Domaine Active Directory** : Recommandé mais pas obligatoire

---

## ✅ Vérification de la configuration

### 1. Test de base avec Test-WSMan

```powershell
# Tester la configuration locale
Test-WSMan

# Tester une machine distante
Test-WSMan -ComputerName "Server01"

# Sortie attendue :
# wsmid           : http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd
# ProtocolVersion : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd
# ProductVendor   : Microsoft Corporation
# ProductVersion  : OS: 10.0.19041 SP: 0.0 Stack: 3.0
```

> [!tip] Test-WSMan est votre premier outil de diagnostic Si cette commande échoue, WinRM n'est pas correctement configuré ou accessible.

### 2. Vérification du service WinRM

```powershell
# Statut détaillé du service
Get-Service WinRM | Select-Object Name, Status, StartType, DisplayName

# Vérifier les dépendances
Get-Service WinRM -DependentServices

# Historique des événements WinRM
Get-WinEvent -LogName "Microsoft-Windows-WinRM/Operational" -MaxEvents 20
```

### 3. Configurations de session PowerShell

```powershell
# Lister toutes les configurations
Get-PSSessionConfiguration | Select-Object Name, Permission, Enabled

# Détails d'une configuration spécifique
Get-PSSessionConfiguration -Name "Microsoft.PowerShell" | Format-List *
```

> [!example] Sortie typique
> 
> ```
> Name              : Microsoft.PowerShell
> Permission        : BUILTIN\Administrators AccessAllowed
> Enabled           : True
> RunAsUser         : 
> MaxShellsPerUser  : 25
> MaxMemoryPerShell : 2147483647
> ```

### 4. Test de session interactive

```powershell
# Tester une session locale
Enter-PSSession -ComputerName localhost

# Tester une session distante
Enter-PSSession -ComputerName "Server01" -Credential (Get-Credential)

# Une fois connecté, vous devriez voir le prompt changer :
# [Server01]: PS C:\Users\Admin\Documents>
```

---

## 🔒 Sécurité

### Mécanismes d'authentification

PowerShell Remoting supporte plusieurs méthodes d'authentification, par ordre de préférence :

|Méthode|Sécurité|Contexte|Configuration|
|---|---|---|---|
|**Kerberos**|⭐⭐⭐⭐⭐|Domaine AD|Automatique|
|**NTLM**|⭐⭐⭐|Workgroup/Domaine|Fallback automatique|
|**Certificate**|⭐⭐⭐⭐|Tous|Configuration manuelle|
|**Basic**|⭐|Tous (déconseillé)|À éviter|

```powershell
# Vérifier les méthodes d'authentification activées
Get-Item WSMan:\localhost\Service\Auth\* | Select-Object Name, Value
```

> [!warning] Kerberos est toujours privilégié Dans un environnement de domaine, Kerberos est utilisé automatiquement. NTLM n'est utilisé qu'en fallback (par exemple, connexion par IP plutôt que par nom).

### Chiffrement du trafic

Tout le trafic PowerShell Remoting est **chiffré par défaut**, même sur HTTP (port 5985) :

- **Kerberos** : Chiffrement intégré au protocole
- **NTLM** : Chiffrement de session après authentification
- **HTTPS** : Chiffrement TLS supplémentaire

```powershell
# Vérifier le chiffrement
Get-Item WSMan:\localhost\Service\AllowUnencrypted
# Value devrait être False
```

### Configuration TrustedHosts (Workgroups)

Dans un environnement **sans domaine AD**, vous devez configurer TrustedHosts pour autoriser les connexions :

```powershell
# Ajouter un hôte spécifique
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "Server01"

# Ajouter plusieurs hôtes
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "Server01,Server02,Server03"

# Ajouter tous les hôtes (⚠️ DANGEREUX)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"

# Ajouter sans écraser la liste existante
$current = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$current,NewServer"

# Vérifier la configuration
Get-Item WSMan:\localhost\Client\TrustedHosts
```

> [!warning] TrustedHosts n'est PAS de l'authentification TrustedHosts indique simplement à votre machine d'accepter les connexions vers ces hôtes. Vous devez toujours vous authentifier avec des identifiants valides.

### Restrictions d'accès

```powershell
# Configurer les permissions sur un endpoint
Set-PSSessionConfiguration -Name "Microsoft.PowerShell" -ShowSecurityDescriptorUI

# Restreindre à un groupe spécifique
Set-PSSessionConfiguration -Name "Microsoft.PowerShell" -AccessMode Remote -SecurityDescriptorSddl "O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)"
```

> [!tip] Principe du moindre privilège Configurez toujours les permissions les plus restrictives possibles. Par défaut, seuls les administrateurs locaux peuvent se connecter.

---

## ❌ Désactivation

### Désactiver les endpoints (recommandé)

```powershell
# Désactive uniquement les endpoints de remoting
Disable-PSRemoting -Force

# Les sessions existantes continuent de fonctionner
# Les nouvelles sessions sont bloquées
```

> [!info] Disable-PSRemoting vs Stop-Service `Disable-PSRemoting` désactive uniquement les **endpoints PowerShell** mais laisse WinRM actif pour d'autres usages (comme WMI). C'est l'approche recommandée.

### Arrêter le service WinRM

```powershell
# Arrêter complètement WinRM
Stop-Service WinRM

# Désactiver le démarrage automatique
Set-Service WinRM -StartupType Disabled

# Vérification
Get-Service WinRM | Select-Object Status, StartType
```

> [!warning] Impact sur d'autres services Arrêter WinRM peut affecter d'autres fonctionnalités Windows qui en dépendent (WMI à distance, gestion SCCM, etc.).

### Suppression des règles de firewall

```powershell
# Désactiver les règles sans les supprimer
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"

# Supprimer complètement les règles
Remove-NetFirewallRule -Name "WINRM-HTTP-In-TCP"
```

---

## 🛠️ Configuration avancée

### Ports personnalisés

```powershell
# Créer un listener sur un port personnalisé (ex: 5555)
New-Item -Path WSMan:\localhost\Listener -Address * -Port 5555 -Transport HTTP

# Configurer le firewall pour le nouveau port
New-NetFirewallRule -Name "WinRM-Custom-Port" -DisplayName "Windows Remote Management (Custom Port)" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5555 -Action Allow

# Se connecter au port personnalisé
Enter-PSSession -ComputerName "Server01" -Port 5555
```

### Configuration HTTPS avec certificats

```powershell
# 1. Créer ou obtenir un certificat SSL
$cert = New-SelfSignedCertificate -DnsName "server01.domain.com" -CertStoreLocation "Cert:\LocalMachine\My"

# 2. Créer un listener HTTPS
New-Item -Path WSMan:\localhost\Listener -Address * -Transport HTTPS -Port 5986 -CertificateThumbprint $cert.Thumbprint -Force

# 3. Configurer le firewall
New-NetFirewallRule -Name "WinRM-HTTPS-In-TCP" -DisplayName "Windows Remote Management (HTTPS-In)" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

# 4. Se connecter en HTTPS
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck
Enter-PSSession -ComputerName "server01.domain.com" -UseSSL -SessionOption $sessionOption
```

> [!tip] Certificats en production Utilisez toujours des certificats signés par une autorité de certification de confiance en production, pas des certificats auto-signés.

### Quotas et limitations

```powershell
# Configurer les quotas de sessions
Set-Item WSMan:\localhost\Shell\MaxConcurrentUsers -Value 10
Set-Item WSMan:\localhost\Shell\MaxShellsPerUser -Value 5
Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB -Value 1024

# Configurer les timeouts
Set-Item WSMan:\localhost\Shell\IdleTimeout -Value 600000  # 10 minutes en ms

# Vérifier les quotas actuels
Get-ChildItem WSMan:\localhost\Shell | Select-Object Name, Value
```

### Configuration de session personnalisée

```powershell
# Créer une configuration de session limitée
$sessionConfig = @{
    SessionType = 'RestrictedRemoteServer'
    RunAsCredential = (Get-Credential)
    TransportOption = New-PSTransportOption -MaxSessions 50 -IdleTimeoutSec 600
}

Register-PSSessionConfiguration -Name "LimitedAccess" @sessionConfig

# Se connecter à la configuration personnalisée
Enter-PSSession -ComputerName "Server01" -ConfigurationName "LimitedAccess"
```

### Journalisation avancée

```powershell
# Activer la journalisation détaillée
Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpListener -Value $true

# Configurer les logs WinRM
wevtutil sl Microsoft-Windows-WinRM/Operational /e:true /ms:10485760

# Activer le logging PowerShell
$logPath = "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
New-Item -Path $logPath -Force
Set-ItemProperty -Path $logPath -Name "EnableScriptBlockLogging" -Value 1
```

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges fréquents

> [!warning] Piège n°1 : Profil réseau Public **Symptôme** : `Enable-PSRemoting` échoue avec "Unable to check the status of the firewall"
> 
> **Solution** :
> 
> ```powershell
> # Changer le profil réseau en Privé
> Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory Private
> 
> # OU utiliser -SkipNetworkProfileCheck (moins sûr)
> Enable-PSRemoting -SkipNetworkProfileCheck -Force
> ```

> [!warning] Piège n°2 : Double-hop (problème de délégation) **Symptôme** : Vous pouvez vous connecter à Server01, mais depuis Server01 vous ne pouvez pas accéder à Server02
> 
> **Explication** : Par défaut, vos identifiants ne sont pas délégués (CredSSP désactivé)
> 
> **Solution** : Ce sujet appartient à la délégation CredSSP qui sera traitée dans une autre partie du cours.

> [!warning] Piège n°3 : Connexion par IP sans TrustedHosts **Symptôme** : `Enter-PSSession -ComputerName 192.168.1.100` échoue avec une erreur d'authentification
> 
> **Solution** :
> 
> ```powershell
> Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.100"
> ```

> [!warning] Piège n°4 : Permissions insuffisantes sur les endpoints **Symptôme** : "Access Denied" lors de la connexion alors que l'utilisateur existe
> 
> **Solution** :
> 
> ```powershell
> # Ajouter des permissions à un endpoint
> Set-PSSessionConfiguration -Name Microsoft.PowerShell -ShowSecurityDescriptorUI
> ```

### Bonnes pratiques

✅ **Utiliser HTTPS en production**

```powershell
# Toujours privilégier HTTPS pour les environnements sensibles
Enable-PSRemoting -Force
New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbprint $thumbprint
```

✅ **Limiter TrustedHosts au strict nécessaire**

```powershell
# ❌ MAUVAIS
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"

# ✅ BON
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "Server01,Server02,Server03"
```

✅ **Configurer des timeouts appropriés**

```powershell
# Éviter les sessions zombies
Set-Item WSMan:\localhost\Shell\IdleTimeout -Value 300000  # 5 minutes
```

✅ **Utiliser des configurations de session personnalisées**

```powershell
# Créer des endpoints avec des permissions spécifiques
Register-PSSessionConfiguration -Name "HelpDesk" -RunAsCredential $credential
```

✅ **Monitorer les connexions**

```powershell
# Vérifier les sessions actives
Get-PSSession
Get-WSManInstance -ResourceURI winrm/config/service

# Surveiller les logs
Get-WinEvent -LogName "Microsoft-Windows-WinRM/Operational" -MaxEvents 50
```

✅ **Documenter votre configuration**

```powershell
# Exporter la configuration pour référence
Get-Item WSMan:\localhost\* -Recurse | Export-Clixml -Path "WSManConfig_$(Get-Date -Format 'yyyyMMdd').xml"
```

### Astuces de dépannage

🔍 **Diagnostic complet**

```powershell
# Script de diagnostic rapide
function Test-PSRemotingConfig {
    Write-Host "=== PowerShell Remoting Diagnostic ===" -ForegroundColor Cyan
    
    # Test 1 : Service WinRM
    Write-Host "`n1. Service WinRM :" -ForegroundColor Yellow
    Get-Service WinRM | Select-Object Status, StartType
    
    # Test 2 : Listeners
    Write-Host "`n2. Listeners WinRM :" -ForegroundColor Yellow
    Get-WSManInstance -ResourceURI winrm/config/listener -Enumerate
    
    # Test 3 : Firewall
    Write-Host "`n3. Règles Firewall :" -ForegroundColor Yellow
    Get-NetFirewallRule -Name "WINRM*" | Select-Object Name, Enabled, Direction
    
    # Test 4 : TrustedHosts
    Write-Host "`n4. TrustedHosts :" -ForegroundColor Yellow
    Get-Item WSMan:\localhost\Client\TrustedHosts
    
    # Test 5 : Configurations de session
    Write-Host "`n5. Session Configurations :" -ForegroundColor Yellow
    Get-PSSessionConfiguration | Select-Object Name, Enabled
    
    # Test 6 : Test de connexion
    Write-Host "`n6. Test de connexion locale :" -ForegroundColor Yellow
    Test-WSMan
}

Test-PSRemotingConfig
```

🔧 **Réinitialisation complète**

```powershell
# En cas de problème majeur, réinitialiser complètement
Disable-PSRemoting -Force
Stop-Service WinRM
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "" -Force
Enable-PSRemoting -Force
```

---

## 🎓 Résumé des points clés

|Aspect|Point essentiel|
|---|---|
|**Commande de base**|`Enable-PSRemoting -Force`|
|**Service**|WinRM doit être actif et en démarrage automatique|
|**Ports**|5985 (HTTP), 5986 (HTTPS)|
|**Authentification**|Kerberos en priorité, NTLM en fallback|
|**Sécurité**|Trafic toujours chiffré, même sur HTTP|
|**Workgroup**|Nécessite TrustedHosts des deux côtés|
|**Vérification**|`Test-WSMan` est votre meilleur ami|
|**Production**|Utilisez HTTPS avec certificats valides|

> [!tip] Prochaine étape logique Une fois Enable-PSRemoting configuré, vous pouvez créer des sessions distantes avec `New-PSSession`, `Enter-PSSession`, et `Invoke-Command` (sujets d'autres parties du cours).