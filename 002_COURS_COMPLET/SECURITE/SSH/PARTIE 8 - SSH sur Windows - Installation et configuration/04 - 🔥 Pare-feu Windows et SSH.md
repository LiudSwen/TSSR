

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

## 🛡️ Introduction au pare-feu Windows

Le pare-feu Windows (Windows Defender Firewall) est un système de sécurité qui contrôle le trafic réseau entrant et sortant de votre machine. Pour permettre les connexions SSH, il est essentiel de configurer correctement les règles de pare-feu.

> [!info] Pourquoi configurer le pare-feu pour SSH ? Par défaut, le pare-feu Windows bloque toutes les connexions entrantes non autorisées. Même si vous installez OpenSSH Server, vous devez explicitement autoriser le trafic sur le port SSH (22 par défaut) pour que les clients distants puissent se connecter.

### 🎯 Concepts clés

|Concept|Description|
|---|---|
|**Profil réseau**|Domaine, Privé ou Public - détermine le niveau de sécurité|
|**Règle entrante**|Contrôle les connexions qui arrivent vers votre machine|
|**Règle sortante**|Contrôle les connexions initiées depuis votre machine|
|**Port SSH**|22 par défaut (TCP)|
|**Action**|Autoriser ou Bloquer le trafic|

---

## 🔐 Règles de pare-feu pour SSH

### Types de règles nécessaires

Pour un fonctionnement complet de SSH, vous devez comprendre deux types de règles :

**1. Règle entrante (Inbound)** - Pour le **serveur SSH**

- Permet aux clients distants de se connecter à votre machine
- Port : TCP 22 (ou port personnalisé)
- Nécessaire si vous voulez accepter des connexions SSH

**2. Règle sortante (Outbound)** - Pour le **client SSH**

- Généralement autorisée par défaut
- Permet à votre machine de se connecter à des serveurs distants
- Rarement besoin de la modifier

> [!warning] Attention aux profils réseau Les règles de pare-feu s'appliquent différemment selon le profil réseau actif :
> 
> - **Domaine** : Réseau d'entreprise avec contrôleur de domaine
> - **Privé** : Réseau domestique ou de confiance
> - **Public** : Réseau non sécurisé (café, aéroport, etc.)
> 
> Il est recommandé d'autoriser SSH uniquement sur les profils Domaine et Privé.

### Paramètres de règle recommandés

```
Nom : OpenSSH Server (sshd)
Direction : Entrante
Action : Autoriser
Protocole : TCP
Port local : 22
Port distant : Tous
Profils : Domaine, Privé (éviter Public)
Programme : C:\Windows\System32\OpenSSH\sshd.exe
```

---

## 🖥️ Configuration via GUI

### Méthode 1 : Pare-feu Windows Defender avec sécurité avancée

#### Étape 1 : Ouvrir le pare-feu avancé

```bash
# Plusieurs façons d'accéder au pare-feu avancé :

# Option 1 : Via Exécuter (Win + R)
wf.msc

# Option 2 : Via le Panneau de configuration
# Panneau de configuration > Système et sécurité > Pare-feu Windows Defender
# Cliquer sur "Paramètres avancés" dans le volet gauche

# Option 3 : Via PowerShell
Start-Process wf.msc
```

#### Étape 2 : Créer une règle entrante

1. Dans le volet gauche, cliquez sur **"Règles de trafic entrant"**
2. Dans le volet droit, cliquez sur **"Nouvelle règle..."**
3. Assistant de création de règle :

**Page 1 - Type de règle :**

```
○ Programme
● Port         <-- Sélectionner cette option
○ Prédéfinie
○ Personnalisée
```

**Page 2 - Protocole et ports :**

```
Protocole : TCP
Ports locaux spécifiques : 22
```

**Page 3 - Action :**

```
● Autoriser la connexion
○ Autoriser la connexion si elle est sécurisée
○ Bloquer la connexion
```

**Page 4 - Profil :**

```
☑ Domaine
☑ Privé
☐ Public      <-- Décocher pour plus de sécurité
```

**Page 5 - Nom :**

```
Nom : OpenSSH Server (sshd)
Description : Autoriser les connexions SSH entrantes sur le port 22
```

> [!tip] Astuce : Règle basée sur le programme Pour plus de sécurité, créez plutôt une règle basée sur le programme :
> 
> - Type de règle : **Programme**
> - Chemin : `C:\Windows\System32\OpenSSH\sshd.exe`
> 
> Cela garantit que seul le service SSH officiel peut utiliser cette règle.

#### Étape 3 : Vérifier la règle créée

1. Dans **"Règles de trafic entrant"**, recherchez votre règle
2. Double-cliquez pour voir les propriétés
3. Vérifiez que la règle est **activée** (case cochée verte)

### Méthode 2 : Via les paramètres Windows

> [!warning] Limitation Les paramètres Windows offrent une interface simplifiée mais moins de contrôle que le pare-feu avancé. Cette méthode est déconseillée pour SSH.

```
Paramètres > Réseau et Internet > Pare-feu Windows Defender
> Autoriser une application via le pare-feu
```

---

## ⚡ Configuration via PowerShell

La configuration via PowerShell est plus rapide et reproductible, idéale pour l'automatisation.

### Commandes de base

#### Créer une règle SSH entrante

```powershell
# Règle simple basée sur le port
New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" `
                    -DisplayName "OpenSSH Server (sshd)" `
                    -Description "Autoriser connexions SSH entrantes" `
                    -Enabled True `
                    -Direction Inbound `
                    -Protocol TCP `
                    -LocalPort 22 `
                    -Action Allow `
                    -Profile Domain,Private

# Règle plus sécurisée basée sur le programme
New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" `
                    -DisplayName "OpenSSH Server (sshd)" `
                    -Description "Autoriser connexions SSH entrantes via sshd.exe" `
                    -Enabled True `
                    -Direction Inbound `
                    -Protocol TCP `
                    -LocalPort 22 `
                    -Program "C:\Windows\System32\OpenSSH\sshd.exe" `
                    -Action Allow `
                    -Profile Domain,Private
```

> [!info] Explication des paramètres
> 
> - **-Name** : Identifiant unique de la règle (utilisé pour la gestion)
> - **-DisplayName** : Nom affiché dans l'interface graphique
> - **-Enabled** : True pour activer, False pour désactiver
> - **-Direction** : Inbound (entrante) ou Outbound (sortante)
> - **-Protocol** : TCP, UDP, ICMPv4, etc.
> - **-LocalPort** : Port sur votre machine (22 pour SSH)
> - **-Program** : Chemin vers l'exécutable autorisé
> - **-Action** : Allow (autoriser) ou Block (bloquer)
> - **-Profile** : Domain, Private, Public (séparés par des virgules)

#### Règle avec restriction d'adresse IP

Pour limiter l'accès SSH à certaines adresses IP :

```powershell
# Autoriser SSH uniquement depuis un réseau local
New-NetFirewallRule -Name "OpenSSH-Server-LAN-Only" `
                    -DisplayName "OpenSSH Server (LAN uniquement)" `
                    -Enabled True `
                    -Direction Inbound `
                    -Protocol TCP `
                    -LocalPort 22 `
                    -RemoteAddress 192.168.1.0/24 `
                    -Action Allow `
                    -Profile Private

# Autoriser SSH depuis plusieurs adresses spécifiques
New-NetFirewallRule -Name "OpenSSH-Server-Specific-IPs" `
                    -DisplayName "OpenSSH Server (IPs autorisées)" `
                    -Enabled True `
                    -Direction Inbound `
                    -Protocol TCP `
                    -LocalPort 22 `
                    -RemoteAddress 192.168.1.100,192.168.1.101,10.0.0.50 `
                    -Action Allow `
                    -Profile Domain,Private
```

> [!tip] Sécurité renforcée Limiter les adresses IP autorisées est une excellente pratique de sécurité, surtout si vous connaissez les machines qui doivent se connecter.

#### Modifier une règle existante

```powershell
# Désactiver une règle
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Enabled False

# Activer une règle
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Enabled True

# Changer le port
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -LocalPort 2222

# Modifier les profils réseau
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Profile Domain

# Ajouter une description
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" `
                    -Description "Règle SSH modifiée le $(Get-Date)"
```

#### Supprimer une règle

```powershell
# Supprimer par nom
Remove-NetFirewallRule -Name "OpenSSH-Server-In-TCP"

# Supprimer toutes les règles SSH (attention !)
Remove-NetFirewallRule -DisplayName "*OpenSSH*"

# Avec confirmation
Remove-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Confirm
```

### Script d'installation complet

Voici un script PowerShell complet pour configurer le pare-feu SSH :

```powershell
# Script de configuration pare-feu SSH
# Exécuter en tant qu'administrateur

# Paramètres
$RuleName = "OpenSSH-Server-In-TCP"
$DisplayName = "OpenSSH Server (sshd)"
$SSHPort = 22
$SSHPath = "C:\Windows\System32\OpenSSH\sshd.exe"

# Vérifier si la règle existe déjà
$ExistingRule = Get-NetFirewallRule -Name $RuleName -ErrorAction SilentlyContinue

if ($ExistingRule) {
    Write-Host "Règle existante détectée. Suppression..." -ForegroundColor Yellow
    Remove-NetFirewallRule -Name $RuleName
}

# Créer la nouvelle règle
Write-Host "Création de la règle pare-feu SSH..." -ForegroundColor Green

New-NetFirewallRule -Name $RuleName `
                    -DisplayName $DisplayName `
                    -Description "Autoriser connexions SSH entrantes sur port $SSHPort" `
                    -Enabled True `
                    -Direction Inbound `
                    -Protocol TCP `
                    -LocalPort $SSHPort `
                    -Program $SSHPath `
                    -Action Allow `
                    -Profile Domain,Private `
                    -ErrorAction Stop

Write-Host "✓ Règle pare-feu créée avec succès !" -ForegroundColor Green

# Afficher la règle créée
Get-NetFirewallRule -Name $RuleName | Format-List Name, DisplayName, Enabled, Direction, Action
```

> [!example] Utilisation du script
> 
> ```powershell
> # Enregistrer le script dans ssh-firewall-setup.ps1
> # Exécuter avec privilèges administrateur :
> .\ssh-firewall-setup.ps1
> ```

---

## ✅ Vérification des règles

### Via PowerShell

#### Lister toutes les règles SSH

```powershell
# Afficher toutes les règles contenant "SSH"
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*SSH*"} | 
    Format-Table Name, DisplayName, Enabled, Direction, Action

# Afficher les détails d'une règle spécifique
Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" | Format-List *

# Afficher avec les informations de port
Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" | 
    Get-NetFirewallPortFilter

# Afficher avec les profils réseau
Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" | 
    Get-NetFirewallProfile
```

#### Vérifier l'état d'une règle

```powershell
# Vérifier si une règle est activée
$Rule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP"
if ($Rule.Enabled -eq "True") {
    Write-Host "✓ La règle est activée" -ForegroundColor Green
} else {
    Write-Host "✗ La règle est désactivée" -ForegroundColor Red
}

# Vérifier tous les paramètres importants
Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" | 
    Select-Object Name, DisplayName, Enabled, Direction, Action, Profile
```

#### Script de vérification complet

```powershell
# Script de diagnostic pare-feu SSH

Write-Host "`n=== Diagnostic Pare-feu SSH ===" -ForegroundColor Cyan

# 1. Vérifier l'existence de la règle
$RuleName = "OpenSSH-Server-In-TCP"
$Rule = Get-NetFirewallRule -Name $RuleName -ErrorAction SilentlyContinue

if (-not $Rule) {
    Write-Host "✗ Aucune règle SSH trouvée !" -ForegroundColor Red
    exit
}

# 2. Afficher l'état de la règle
Write-Host "`nÉtat de la règle :" -ForegroundColor Yellow
$Rule | Format-List Name, DisplayName, Enabled, Direction, Action

# 3. Afficher les détails du port
Write-Host "Configuration du port :" -ForegroundColor Yellow
$Rule | Get-NetFirewallPortFilter | Format-List Protocol, LocalPort

# 4. Afficher les profils réseau
Write-Host "Profils réseau :" -ForegroundColor Yellow
$Rule | Get-NetFirewallProfile | Format-List Profile

# 5. Vérifier le statut du service SSH
Write-Host "Statut du service SSH :" -ForegroundColor Yellow
Get-Service -Name sshd | Format-List Name, Status, StartType

# 6. Tester l'écoute sur le port
Write-Host "Ports en écoute :" -ForegroundColor Yellow
Get-NetTCPConnection -LocalPort 22 -State Listen -ErrorAction SilentlyContinue | 
    Format-Table LocalAddress, LocalPort, State

Write-Host "`n=== Fin du diagnostic ===`n" -ForegroundColor Cyan
```

### Via l'interface graphique

1. Ouvrir le pare-feu avancé : `wf.msc`
2. Cliquer sur **"Règles de trafic entrant"**
3. Rechercher votre règle SSH
4. Vérifier les indicateurs visuels :
    - ✅ Icône avec coche verte = règle activée et autorise le trafic
    - ⛔ Icône avec cercle rouge = règle activée et bloque le trafic
    - 🔘 Icône grisée = règle désactivée

### Tester la connectivité

#### Test local

```powershell
# Tester la connexion SSH locale
ssh localhost

# Ou spécifier le port
ssh -p 22 localhost

# Avec un utilisateur spécifique
ssh utilisateur@localhost
```

#### Test depuis une machine distante

```bash
# Depuis Linux/macOS ou Windows avec OpenSSH client
ssh utilisateur@adresse_ip_windows

# Tester avec verbose pour voir les détails
ssh -v utilisateur@adresse_ip_windows

# Tester uniquement la connexion au port (sans authentification)
telnet adresse_ip_windows 22

# Avec netcat
nc -zv adresse_ip_windows 22
```

#### Test du port avec PowerShell

```powershell
# Tester si le port 22 répond
Test-NetConnection -ComputerName localhost -Port 22

# Version détaillée
Test-NetConnection -ComputerName localhost -Port 22 -InformationLevel Detailed

# Depuis une machine distante (remplacer l'IP)
Test-NetConnection -ComputerName 192.168.1.100 -Port 22
```

> [!example] Sortie attendue d'un test réussi
> 
> ```
> ComputerName     : localhost
> RemoteAddress    : ::1
> RemotePort       : 22
> InterfaceAlias   : Loopback Pseudo-Interface 1
> SourceAddress    : ::1
> TcpTestSucceeded : True
> ```

---

## ⚠️ Pièges courants

### 1. Règle créée mais connexion toujours bloquée

**Problème** : La règle existe mais les connexions échouent

**Causes possibles :**

- La règle est désactivée
- Le profil réseau actif n'est pas autorisé dans la règle
- Une autre règle de blocage a priorité
- Le service SSH n'est pas démarré

**Solution :**

```powershell
# Vérifier et activer la règle
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Enabled True

# Vérifier le service
Get-Service sshd
Start-Service sshd

# Vérifier le profil réseau actuel
Get-NetConnectionProfile

# Lister toutes les règles SSH (y compris celles qui bloquent)
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*SSH*"} | 
    Format-Table Name, DisplayName, Enabled, Action
```

### 2. Règle appliquée au mauvais profil réseau

**Problème** : La règle fonctionne à la maison mais pas au bureau (ou inversement)

**Explication :** Windows utilise différents profils réseau selon le type de réseau détecté. Si votre règle n'autorise que le profil "Privé" mais que vous êtes sur un réseau "Public", la connexion sera bloquée.

**Solution :**

```powershell
# Vérifier le profil réseau actuel
Get-NetConnectionProfile | Format-List Name, InterfaceAlias, NetworkCategory

# Modifier la règle pour inclure tous les profils (déconseillé en production)
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Profile Any

# Ou changer le profil du réseau (si approprié)
Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory Private
```

> [!warning] Attention au profil Public Évitez d'autoriser SSH sur le profil Public sauf si absolument nécessaire. Les réseaux publics sont non sécurisés et exposent votre machine à des risques.

### 3. Port personnalisé non configuré

**Problème** : Vous avez changé le port SSH mais la règle pare-feu utilise toujours le port 22

**Solution :**

```powershell
# Si vous utilisez un port personnalisé (ex: 2222)
# Modifier la règle existante
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -LocalPort 2222

# Ou créer une nouvelle règle
New-NetFirewallRule -Name "OpenSSH-Server-Custom-Port" `
                    -DisplayName "OpenSSH Server (Port 2222)" `
                    -Enabled True `
                    -Direction Inbound `
                    -Protocol TCP `
                    -LocalPort 2222 `
                    -Action Allow `
                    -Profile Domain,Private
```

### 4. Règles multiples contradictoires

**Problème** : Plusieurs règles SSH existent avec des paramètres différents

**Impact :** Les règles de blocage ont priorité sur les règles d'autorisation

**Solution :**

```powershell
# Lister TOUTES les règles SSH
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*SSH*"} | 
    Format-Table Name, DisplayName, Enabled, Action, Direction

# Supprimer les règles en double
Remove-NetFirewallRule -Name "nom_regle_en_double"

# Approche propre : tout supprimer et recréer
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*OpenSSH*"} | 
    Remove-NetFirewallRule

# Puis recréer une seule règle propre
```

### 5. Oubli de redémarrer le service après modification

**Problème** : Les modifications de configuration ne sont pas appliquées

**Solution :**

```powershell
# Redémarrer le service SSH après toute modification importante
Restart-Service sshd

# Vérifier que le service redémarre correctement
Get-Service sshd
```

### 6. Restrictions d'adresse IP trop strictes

**Problème** : Vous avez limité l'accès à certaines IP mais elles changent (DHCP)

**Solution :**

```powershell
# Utiliser des plages réseau plutôt que des IP fixes
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" `
                    -RemoteAddress 192.168.1.0/24

# Ou supprimer la restriction d'IP pour le réseau local
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -RemoteAddress Any
```

### 7. Pare-feu tiers installé

**Problème** : Vous avez configuré le pare-feu Windows mais un pare-feu tiers (Norton, McAfee, etc.) bloque aussi

**Solution :**

- Vérifier les logiciels de sécurité installés
- Configurer également le pare-feu tiers
- Ou désactiver le pare-feu tiers si le pare-feu Windows suffit

```powershell
# Lister les logiciels de sécurité installés
Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct | 
    Select-Object displayName, productState
```

---

## 🎯 Bonnes pratiques

> [!tip] Recommandations de sécurité
> 
> **1. Limiter les profils réseau**
> 
> - Autoriser SSH uniquement sur Domaine et Privé
> - Éviter le profil Public sauf nécessité absolue
> 
> **2. Utiliser des règles basées sur le programme**
> 
> - Plus sécurisé qu'une simple règle de port
> - Empêche d'autres programmes d'usurper le port
> 
> **3. Restreindre les adresses IP sources**
> 
> - Si possible, limiter aux réseaux de confiance
> - Utiliser des plages CIDR pour plus de flexibilité
> 
> **4. Documenter vos règles**
> 
> - Toujours remplir le champ Description
> - Noter la date et la raison de création
> 
> **5. Auditer régulièrement**
> 
> - Lister périodiquement toutes les règles SSH
> - Supprimer les règles obsolètes
> - Vérifier que seules les règles nécessaires sont activées
> 
> **6. Sauvegarder la configuration**
> 
> - Exporter les règles importantes
> - Conserver un script de recréation
> 
> **7. Utiliser PowerShell pour l'automatisation**
> 
> - Scripts reproductibles et versionnables
> - Déploiement facile sur plusieurs machines

---

## 📝 Résumé

Le pare-feu Windows est un élément essentiel de la sécurité SSH sur Windows. Les points clés à retenir :

|Aspect|Détail|
|---|---|
|**Règle nécessaire**|Entrante (Inbound) sur port TCP 22|
|**Méthodes de config**|GUI (wf.msc) ou PowerShell|
|**Profils recommandés**|Domain, Private (éviter Public)|
|**Type de règle**|Basée sur le programme (sshd.exe) de préférence|
|**Vérification**|Test-NetConnection et Get-NetFirewallRule|
|**Maintenance**|Auditer régulièrement, supprimer les doublons|

La configuration du pare-feu est souvent la cause principale des problèmes de connexion SSH sur Windows. Une compréhension solide de ces concepts vous permettra de diagnostiquer et résoudre rapidement les problèmes de connectivité.