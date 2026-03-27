

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

## 🆕 New-NetIPAddress

### Vue d'ensemble

La cmdlet `New-NetIPAddress` permet de configurer une adresse IP statique sur une interface réseau. Elle remplace l'utilisation de l'interface graphique ou de la commande `netsh` classique.

> [!info] Pourquoi utiliser une IP statique ? Les adresses IP statiques sont essentielles pour :
> 
> - Les serveurs (DNS, Web, bases de données)
> - Les équipements réseau (routeurs, switches managés)
> - Les imprimantes et périphériques partagés
> - Les environnements sans serveur DHCP

### Syntaxe de base

```powershell
New-NetIPAddress -InterfaceAlias "Nom de l'interface" `
                 -IPAddress "192.168.1.100" `
                 -PrefixLength 24 `
                 -DefaultGateway "192.168.1.1"
```

### Paramètres obligatoires

|Paramètre|Description|Exemple|
|---|---|---|
|`-InterfaceAlias`|Nom de l'interface réseau|`"Ethernet"`, `"Wi-Fi"`|
|`-InterfaceIndex`|Index numérique de l'interface (alternative)|`12`|
|`-IPAddress`|Adresse IP à configurer|`"192.168.1.100"`|
|`-PrefixLength`|Masque de sous-réseau en notation CIDR|`24` (pour /24 = 255.255.255.0)|

> [!warning] Interface obligatoire Vous DEVEZ spécifier soit `-InterfaceAlias` soit `-InterfaceIndex`. Pour connaître le nom exact de votre interface, utilisez `Get-NetAdapter`.

### Paramètres optionnels importants

#### DefaultGateway

```powershell
# Configuration avec passerelle par défaut
New-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "10.0.0.50" `
                 -PrefixLength 8 `
                 -DefaultGateway "10.0.0.1"
```

> [!tip] Passerelle par défaut Sans passerelle, votre machine ne pourra communiquer qu'avec son réseau local. La passerelle est indispensable pour accéder à Internet ou d'autres réseaux.

#### AddressFamily

```powershell
# Configuration IPv4 explicite
New-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "192.168.1.100" `
                 -PrefixLength 24 `
                 -AddressFamily IPv4

# Configuration IPv6
New-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "2001:db8::1" `
                 -PrefixLength 64 `
                 -AddressFamily IPv6
```

#### Type

```powershell
# Type d'adresse (Unicast par défaut)
New-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "192.168.1.100" `
                 -PrefixLength 24 `
                 -Type Unicast  # Autres valeurs: Anycast, Multicast
```

### Exemples pratiques

#### Configuration réseau complète d'un serveur

```powershell
# Étape 1 : Identifier l'interface
Get-NetAdapter

# Étape 2 : Configurer l'IP statique
New-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "192.168.10.10" `
                 -PrefixLength 24 `
                 -DefaultGateway "192.168.10.1"

# Étape 3 : Configurer les serveurs DNS (voir section DNS)
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
                           -ServerAddresses "8.8.8.8","8.8.4.4"
```

> [!example] Configuration d'entreprise typique
> 
> ```powershell
> # Serveur dans le réseau 172.16.0.0/16
> New-NetIPAddress -InterfaceAlias "Ethernet0" `
>                  -IPAddress "172.16.5.20" `
>                  -PrefixLength 16 `
>                  -DefaultGateway "172.16.0.1"
> ```

#### Adresses IP multiples sur une même interface

```powershell
# IP principale
New-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "192.168.1.10" `
                 -PrefixLength 24 `
                 -DefaultGateway "192.168.1.1"

# IP secondaire (sans passerelle pour éviter les conflits)
New-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "192.168.1.11" `
                 -PrefixLength 24
```

> [!warning] Une seule passerelle par défaut Ne spécifiez `-DefaultGateway` que pour l'adresse IP principale. Plusieurs passerelles par défaut sur la même interface causeraient des conflits de routage.

### Conversion masque de sous-réseau

Pour comprendre la notation CIDR (`-PrefixLength`) :

|CIDR|Masque décimal|Nombre d'hôtes|
|---|---|---|
|/8|255.0.0.0|16 777 214|
|/16|255.255.0.0|65 534|
|/24|255.255.255.0|254|
|/25|255.255.255.128|126|
|/26|255.255.255.192|62|
|/27|255.255.255.224|30|
|/30|255.255.255.252|2|

### Validation après configuration

```powershell
# Vérifier la configuration IP
Get-NetIPAddress -InterfaceAlias "Ethernet" | Format-Table

# Vérifier la passerelle
Get-NetRoute -InterfaceAlias "Ethernet" | Where-Object DestinationPrefix -eq "0.0.0.0/0"

# Tester la connectivité locale
Test-Connection -ComputerName "192.168.1.1" -Count 4

# Tester la connectivité Internet
Test-Connection -ComputerName "8.8.8.8" -Count 4
```

> [!tip] Script de validation complet
> 
> ```powershell
> $Interface = "Ethernet"
> Write-Host "=== Configuration réseau de $Interface ===" -ForegroundColor Cyan
> Get-NetIPAddress -InterfaceAlias $Interface | Select-Object IPAddress, PrefixLength
> Get-NetRoute -InterfaceAlias $Interface | Where-Object DestinationPrefix -eq "0.0.0.0/0"
> Get-DnsClientServerAddress -InterfaceAlias $Interface
> ```

### Pièges courants

> [!warning] Erreur : "The object already exists" Si une IP statique existe déjà sur l'interface, vous devez d'abord la supprimer avec `Remove-NetIPAddress` avant d'en créer une nouvelle, ou utiliser `Set-NetIPAddress` pour la modifier.

> [!warning] Connexion distante coupée Si vous configurez une IP sur une connexion RDP/SSH à distance, assurez-vous que la nouvelle IP est accessible depuis votre poste, sinon vous perdrez la connexion !

> [!warning] Conflit avec DHCP `New-NetIPAddress` ne désactive pas automatiquement DHCP. Si DHCP est actif, il peut y avoir des conflits. Vérifiez avec `Get-NetIPConfiguration`.

---

## 🗑️ Remove-NetIPAddress

### Vue d'ensemble

`Remove-NetIPAddress` supprime une adresse IP configurée sur une interface réseau. Cette cmdlet est utilisée pour nettoyer les configurations ou revenir à DHCP.

### Syntaxe de base

```powershell
# Supprimer une IP spécifique
Remove-NetIPAddress -IPAddress "192.168.1.100" -Confirm:$false

# Supprimer toutes les IPs d'une interface
Remove-NetIPAddress -InterfaceAlias "Ethernet" -Confirm:$false
```

### Paramètres principaux

|Paramètre|Description|Exemple|
|---|---|---|
|`-IPAddress`|Adresse IP à supprimer|`"192.168.1.100"`|
|`-InterfaceAlias`|Interface concernée|`"Ethernet"`|
|`-InterfaceIndex`|Index de l'interface (alternative)|`12`|
|`-Confirm`|Demande confirmation ($true par défaut)|`-Confirm:$false`|
|`-AddressFamily`|IPv4 ou IPv6|`IPv4`|

### Exemples pratiques

#### Suppression simple avec confirmation

```powershell
# PowerShell demandera confirmation
Remove-NetIPAddress -IPAddress "192.168.1.100"
```

#### Suppression sans confirmation (scripts automatisés)

```powershell
# Utile pour les scripts automatisés
Remove-NetIPAddress -IPAddress "192.168.1.100" -Confirm:$false
```

#### Supprimer toutes les IPs d'une interface

```powershell
# Supprimer toutes les configurations IPv4 d'une interface
Remove-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 -Confirm:$false
```

> [!warning] Impact sur la connectivité Supprimer l'adresse IP coupera immédiatement toute connexion réseau sur cette interface. Soyez prudent avec les connexions distantes !

#### Retour à DHCP après suppression

```powershell
# 1. Supprimer l'IP statique
Remove-NetIPAddress -InterfaceAlias "Ethernet" -Confirm:$false

# 2. Réactiver DHCP
Set-NetIPInterface -InterfaceAlias "Ethernet" -Dhcp Enabled

# 3. Renouveler le bail DHCP
Restart-NetAdapter -Name "Ethernet"
```

### Suppression sélective

#### Supprimer uniquement les IPs secondaires

```powershell
# Lister toutes les IPs de l'interface
$IPs = Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4

# Garder seulement la première (principale), supprimer les autres
$IPs | Select-Object -Skip 1 | ForEach-Object {
    Remove-NetIPAddress -IPAddress $_.IPAddress -Confirm:$false
}
```

#### Supprimer par plage d'adresses

```powershell
# Supprimer toutes les IPs du réseau 192.168.1.x
Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { $_.IPAddress -like "192.168.1.*" } |
    Remove-NetIPAddress -Confirm:$false
```

### Gestion des erreurs

```powershell
# Suppression sécurisée avec gestion d'erreur
try {
    Remove-NetIPAddress -IPAddress "192.168.1.100" -Confirm:$false -ErrorAction Stop
    Write-Host "Adresse IP supprimée avec succès" -ForegroundColor Green
}
catch {
    Write-Host "Erreur : $_" -ForegroundColor Red
}
```

### Précautions pour connexions distantes

> [!warning] Connexion RDP/SSH à distance **NE JAMAIS** supprimer l'IP d'une machine distante sans avoir :
> 
> 1. Une autre méthode d'accès (console physique, iLO, IPMI)
> 2. Un script de rollback automatique
> 3. Une configuration DHCP de secours
> 
> Vous risquez de perdre définitivement l'accès à la machine !

#### Script de sécurité pour changement distant

```powershell
# Script avec rollback automatique après 30 secondes
$OldIP = "192.168.1.100"
$NewIP = "192.168.1.200"
$Interface = "Ethernet"

# Tâche de rollback
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument @"
Remove-NetIPAddress -IPAddress '$NewIP' -Confirm:`$false
New-NetIPAddress -InterfaceAlias '$Interface' -IPAddress '$OldIP' -PrefixLength 24
"@
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(30)
Register-ScheduledTask -TaskName "NetworkRollback" -Action $Action -Trigger $Trigger

# Changement d'IP
Remove-NetIPAddress -IPAddress $OldIP -Confirm:$false
New-NetIPAddress -InterfaceAlias $Interface -IPAddress $NewIP -PrefixLength 24

# Si ça marche, annuler le rollback
# Unregister-ScheduledTask -TaskName "NetworkRollback" -Confirm:$false
```

### Impact sur les services réseau

> [!info] Services affectés par la suppression d'IP La suppression d'une adresse IP peut affecter :
> 
> - **Serveurs Web/FTP** : services liés à l'IP supprimée
> - **Partages réseau** : SMB/CIFS basés sur l'IP
> - **Licences logicielles** : certaines sont liées à l'adresse MAC/IP
> - **Firewall** : règles basées sur l'IP source
> - **VPN** : tunnels configurés avec l'IP supprimée

---

## ⚙️ Set-NetIPAddress

### Vue d'ensemble

`Set-NetIPAddress` modifie les propriétés d'une adresse IP existante sans avoir à la supprimer et la recréer. Plus élégant et sûr que `Remove` + `New`.

### Syntaxe de base

```powershell
Set-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "192.168.1.100" `
                 -PrefixLength 16
```

### Paramètres modifiables

|Paramètre|Description|Exemple|
|---|---|---|
|`-PrefixLength`|Modifier le masque de sous-réseau|`24` → `16`|
|`-SkipAsSource`|Utiliser cette IP comme source ou non|`$true` / `$false`|
|`-ValidLifetime`|Durée de validité de l'adresse|`[TimeSpan]::FromDays(30)`|

> [!info] Limitations de Set-NetIPAddress Contrairement à ce qu'on pourrait penser, `Set-NetIPAddress` ne peut PAS modifier l'adresse IP elle-même. Pour changer l'IP, vous devez utiliser `Remove-NetIPAddress` puis `New-NetIPAddress`.

### Exemples pratiques

#### Modifier le masque de sous-réseau

```powershell
# Passer d'un /24 à un /16 (sans changer l'IP)
Set-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "192.168.1.100" `
                 -PrefixLength 16
```

#### Désactiver une IP comme source

```powershell
# Utile pour les IPs secondaires qui ne doivent pas être utilisées pour les connexions sortantes
Set-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "192.168.1.101" `
                 -SkipAsSource $true
```

> [!example] Cas d'usage : Multi-homing Dans un serveur avec plusieurs IPs, vous voulez que les connexions sortantes utilisent toujours l'IP principale (192.168.1.100) et jamais les IPs secondaires :
> 
> ```powershell
> # IP principale : utilisée pour les connexions sortantes
> Set-NetIPAddress -IPAddress "192.168.1.100" -SkipAsSource $false
> 
> # IPs secondaires : réception uniquement
> Set-NetIPAddress -IPAddress "192.168.1.101" -SkipAsSource $true
> Set-NetIPAddress -IPAddress "192.168.1.102" -SkipAsSource $true
> ```

#### Modification de la durée de vie (IPv6 surtout)

```powershell
# Définir une durée de validité de 7 jours
Set-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "2001:db8::1" `
                 -ValidLifetime (New-TimeSpan -Days 7)
```

### Changement complet d'IP (méthode recommandée)

```powershell
# Méthode propre pour changer d'IP complètement
$Interface = "Ethernet"
$OldIP = "192.168.1.100"
$NewIP = "192.168.1.200"

# Supprimer l'ancienne
Remove-NetIPAddress -InterfaceAlias $Interface -IPAddress $OldIP -Confirm:$false

# Créer la nouvelle
New-NetIPAddress -InterfaceAlias $Interface `
                 -IPAddress $NewIP `
                 -PrefixLength 24 `
                 -DefaultGateway "192.168.1.1"
```

---

## 🌐 Configuration DNS

### Vue d'ensemble

La configuration des serveurs DNS est indissociable de la configuration IP. Sans DNS, impossible de résoudre les noms de domaine en adresses IP.

### Set-DnsClientServerAddress

#### Syntaxe de base

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
                           -ServerAddresses "8.8.8.8","8.8.4.4"
```

### Paramètres principaux

|Paramètre|Description|Exemple|
|---|---|---|
|`-InterfaceAlias`|Interface à configurer|`"Ethernet"`|
|`-InterfaceIndex`|Index de l'interface (alternative)|`12`|
|`-ServerAddresses`|Liste des serveurs DNS|`"8.8.8.8","8.8.4.4"`|
|`-ResetServerAddresses`|Supprimer tous les DNS|(switch)|

### Exemples de configuration

#### DNS publics Google

```powershell
# DNS primaire et secondaire Google
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
                           -ServerAddresses "8.8.8.8","8.8.4.4"
```

#### DNS d'entreprise

```powershell
# DNS internes d'entreprise
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
                           -ServerAddresses "10.0.0.1","10.0.0.2"
```

#### Configuration mixte (DNS interne + externe)

```powershell
# DNS interne en primaire, DNS public en secondaire (fallback)
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
                           -ServerAddresses "192.168.1.1","8.8.8.8","1.1.1.1"
```

> [!tip] Ordre des serveurs DNS Le premier DNS de la liste est le serveur primaire. Windows essaiera les suivants uniquement si le primaire ne répond pas. L'ordre est donc important !

### DNS populaires

|Fournisseur|Primaire|Secondaire|Particularité|
|---|---|---|---|
|**Google**|8.8.8.8|8.8.4.4|Rapide, fiable, logs|
|**Cloudflare**|1.1.1.1|1.0.0.1|Rapide, privacy-focused|
|**Quad9**|9.9.9.9|149.112.112.112|Blocage malware|
|**OpenDNS**|208.67.222.222|208.67.220.220|Contrôle parental|

### Vérifier la configuration DNS

```powershell
# Voir les DNS configurés
Get-DnsClientServerAddress -InterfaceAlias "Ethernet"

# Tester la résolution DNS
Resolve-DnsName google.com

# Tester un serveur DNS spécifique
Resolve-DnsName google.com -Server 8.8.8.8
```

### Reset de la configuration DNS

#### Revenir au DNS automatique (DHCP)

```powershell
# Supprimer les DNS statiques et revenir au DHCP
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
```

#### Vider le cache DNS

```powershell
# Après un changement de DNS, vider le cache
Clear-DnsClientCache

# Vérifier que le cache est vide
Get-DnsClientCache
```

### Configuration complète réseau avec DNS

```powershell
# Script complet de configuration réseau
$Interface = "Ethernet"

# 1. Configuration IP statique
New-NetIPAddress -InterfaceAlias $Interface `
                 -IPAddress "192.168.1.50" `
                 -PrefixLength 24 `
                 -DefaultGateway "192.168.1.1"

# 2. Configuration DNS
Set-DnsClientServerAddress -InterfaceAlias $Interface `
                           -ServerAddresses "192.168.1.1","8.8.8.8"

# 3. Vérification
Write-Host "=== Configuration réseau ===" -ForegroundColor Cyan
Get-NetIPAddress -InterfaceAlias $Interface | Select-Object IPAddress, PrefixLength
Get-NetRoute -InterfaceAlias $Interface | Where-Object DestinationPrefix -eq "0.0.0.0/0"
Get-DnsClientServerAddress -InterfaceAlias $Interface

# 4. Tests de connectivité
Write-Host "`n=== Tests de connectivité ===" -ForegroundColor Cyan
Test-Connection -ComputerName "192.168.1.1" -Count 2 -Quiet
Test-Connection -ComputerName "google.com" -Count 2 -Quiet
Resolve-DnsName google.com | Select-Object Name, IPAddress
```

> [!example] Script de configuration serveur Windows
> 
> ```powershell
> # Configuration type pour un serveur Windows en DMZ
> $Config = @{
>     Interface = "Ethernet0"
>     IP = "172.16.10.20"
>     PrefixLength = 24
>     Gateway = "172.16.10.1"
>     DNS = @("172.16.1.10","172.16.1.11")  # DNS internes
> }
> 
> New-NetIPAddress -InterfaceAlias $Config.Interface `
>                  -IPAddress $Config.IP `
>                  -PrefixLength $Config.PrefixLength `
>                  -DefaultGateway $Config.Gateway
> 
> Set-DnsClientServerAddress -InterfaceAlias $Config.Interface `
>                            -ServerAddresses $Config.DNS
> ```

### Troubleshooting DNS

```powershell
# Diagnostiquer les problèmes DNS
Test-NetConnection -ComputerName google.com -InformationLevel Detailed

# Tester chaque serveur DNS configuré
$DNSServers = (Get-DnsClientServerAddress -InterfaceAlias "Ethernet").ServerAddresses
foreach ($DNS in $DNSServers) {
    Write-Host "Test du serveur DNS : $DNS" -ForegroundColor Yellow
    Resolve-DnsName google.com -Server $DNS -ErrorAction SilentlyContinue
}

# Vérifier le fichier hosts local (peut surcharger DNS)
Get-Content C:\Windows\System32\drivers\etc\hosts
```

> [!warning] Ordre de résolution DNS Windows résout les noms dans cet ordre :
> 
> 1. Cache DNS local (`Get-DnsClientCache`)
> 2. Fichier hosts (`C:\Windows\System32\drivers\etc\hosts`)
> 3. Serveurs DNS configurés
> 
> Si un nom ne se résout pas correctement, vérifiez ces trois niveaux !

---

## 🎯 Bonnes pratiques

### Documentation et traçabilité

```powershell
# Toujours documenter les changements
$ChangeLog = @"
Date : $(Get-Date -Format "yyyy-MM-dd HH:mm")
Interface : Ethernet
Ancienne IP : 192.168.1.100/24
Nouvelle IP : 192.168.1.200/24
Gateway : 192.168.1.1
DNS : 8.8.8.8, 8.8.4.4
Raison : Migration vers nouveau subnet
Effectué par : $env:USERNAME
"@

$ChangeLog | Out-File "C:\Logs\NetworkChanges.log" -Append
```

### Automatisation avec fonctions réutilisables

```powershell
function Set-StaticIP {
    param(
        [Parameter(Mandatory)]
        [string]$InterfaceAlias,
        
        [Parameter(Mandatory)]
        [string]$IPAddress,
        
        [Parameter(Mandatory)]
        [int]$PrefixLength,
        
        [Parameter(Mandatory)]
        [string]$Gateway,
        
        [string[]]$DNSServers = @("8.8.8.8","8.8.4.4")
    )
    
    # Supprimer les IPs existantes
    Remove-NetIPAddress -InterfaceAlias $InterfaceAlias -Confirm:$false -ErrorAction SilentlyContinue
    
    # Configurer la nouvelle IP
    New-NetIPAddress -InterfaceAlias $InterfaceAlias `
                     -IPAddress $IPAddress `
                     -PrefixLength $PrefixLength `
                     -DefaultGateway $Gateway
    
    # Configurer les DNS
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias `
                               -ServerAddresses $DNSServers
    
    Write-Host "Configuration réseau appliquée avec succès !" -ForegroundColor Green
}

# Utilisation
Set-StaticIP -InterfaceAlias "Ethernet" `
             -IPAddress "192.168.1.100" `
             -PrefixLength 24 `
             -Gateway "192.168.1.1" `
             -DNSServers "192.168.1.1","8.8.8.8"
```

### Vérification avant/après

```powershell
# Snapshot avant changement
$Before = Get-NetIPConfiguration | ConvertTo-Json

# Effectuer les changements
# ...

# Snapshot après changement
$After = Get-NetIPConfiguration | ConvertTo-Json

# Comparer (manuel ou automatisé)
Compare-Object ($Before | ConvertFrom-Json) ($After | ConvertFrom-Json)
```

---

## 💡 Astuces avancées

### Configuration par défaut pour toutes les interfaces

```powershell
# Appliquer des DNS à toutes les interfaces actives
Get-NetAdapter | Where-Object Status -eq "Up" | ForEach-Object {
    Set-DnsClientServerAddress -InterfaceAlias $_.Name `
                               -ServerAddresses "1.1.1.1","1.0.0.1"
}
```

### Export/Import de configuration

```powershell
# Exporter la configuration réseau
$NetConfig = Get-NetIPConfiguration | Select-Object InterfaceAlias, 
    @{N='IPv4Address';E={$_.IPv4Address.IPAddress}},
    @{N='IPv4Gateway';E={$_.IPv4DefaultGateway.NextHop}},
    @{N='DNSServers';E={$_.DNSServer.ServerAddresses}}

$NetConfig | Export-Csv "NetworkBackup.csv" -NoTypeInformation

# Importer et appliquer
$Config = Import-Csv "NetworkBackup.csv"
foreach ($C in $Config) {
    Set-StaticIP -InterfaceAlias $C.InterfaceAlias `
                 -IPAddress $C.IPv4Address `
                 -PrefixLength 24 `
                 -Gateway $C.IPv4Gateway `
                 -DNSServers ($C.DNSServers -split ',')
}
```

### Gestion d'erreurs robuste

```powershell
function Set-StaticIPSafe {
    param(
        [string]$Interface,
        [string]$IP,
        [int]$Prefix,
        [string]$Gateway
    )
    
    try {
        # Vérifier que l'interface existe
        $Adapter = Get-NetAdapter -Name $Interface -ErrorAction Stop
        if ($Adapter.Status -ne "Up") {
            throw "L'interface $Interface n'est pas active"
        }
        
        # Vérifier que l'IP est valide
        if (-not ([System.Net.IPAddress]::TryParse($IP, [ref]$null))) {
            throw "Adresse IP invalide : $IP"
        }
        
        # Appliquer la configuration
        New-NetIPAddress -InterfaceAlias $Interface `
                         -IPAddress $IP `
                         -PrefixLength $Prefix `
                         -DefaultGateway $Gateway `
                         -ErrorAction Stop
        
        Write-Host "✓ Configuration appliquée" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Erreur : $_" -ForegroundColor Red
        return $false
    }
    
    return $true
}
```

### Monitoring post-configuration

```powershell
# Script de monitoring continu
$Interface = "Ethernet"
$ExpectedIP = "192.168.1.100"

while ($true) {
    $CurrentIP = (Get-NetIPAddress -InterfaceAlias $Interface -AddressFamily IPv4).IPAddress
    
    if ($CurrentIP -ne $ExpectedIP) {
        Write-Warning "IP changée ! Attendue: $ExpectedIP, Actuelle: $CurrentIP"
        # Envoyer une alerte email, log, etc.
    }
    
    Start-Sleep -Seconds 60
}
```

---

> [!tip] Commandes de référence rapide
> 
> ```powershell
> # Lister les interfaces
> Get-NetAdapter
> 
> # Voir toutes les IPs configurées
> Get-NetIPAddress
> 
> # Voir la configuration complète
> Get-NetIPConfiguration
> 
> # Créer IP statique
> New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.100" -PrefixLength 24 -DefaultGateway "192.168.1.1"
> 
> # Modifier le masque
> Set-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.100" -PrefixLength 16
> 
> # Supprimer une IP
> Remove-NetIPAddress -IPAddress "192.168.1.100" -Confirm:$false
> 
> # Configurer DNS
> Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "8.8.8.8","8.8.4.4"
> 
> # Reset DNS
> Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
> 
> # Vider le cache DNS
> Clear-DnsClientCache
> ```

---

## 🔍 Pièges courants et solutions

### Piège 1 : Conflit avec DHCP

**Problème** : Après avoir configuré une IP statique, l'interface continue à obtenir une IP via DHCP.

```powershell
# ❌ Problème : DHCP toujours actif
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.100" -PrefixLength 24
# Résultat : 2 IPs sur la même interface (DHCP + statique)

# ✅ Solution : Désactiver DHCP explicitement
Set-NetIPInterface -InterfaceAlias "Ethernet" -Dhcp Disabled
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.100" -PrefixLength 24 -DefaultGateway "192.168.1.1"
```

### Piège 2 : Plusieurs passerelles par défaut

**Problème** : Ajouter plusieurs IPs avec des passerelles différentes.

```powershell
# ❌ Erreur classique
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.100" -PrefixLength 24 -DefaultGateway "192.168.1.1"
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.101" -PrefixLength 24 -DefaultGateway "192.168.1.1"
# Erreur : La passerelle existe déjà !

# ✅ Solution : Passerelle seulement pour l'IP principale
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.100" -PrefixLength 24 -DefaultGateway "192.168.1.1"
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.101" -PrefixLength 24  # Sans -DefaultGateway
```

### Piège 3 : Ordre des opérations pour changement d'IP

**Problème** : Essayer de modifier une IP qui existe déjà.

```powershell
# ❌ Erreur : L'objet existe déjà
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.200" -PrefixLength 24
# Erreur si une IP statique existe déjà sur l'interface

# ✅ Solution : Supprimer puis recréer
$Interface = "Ethernet"
$OldIP = (Get-NetIPAddress -InterfaceAlias $Interface -AddressFamily IPv4).IPAddress
Remove-NetIPAddress -InterfaceAlias $Interface -IPAddress $OldIP -Confirm:$false
New-NetIPAddress -InterfaceAlias $Interface -IPAddress "192.168.1.200" -PrefixLength 24 -DefaultGateway "192.168.1.1"
```

### Piège 4 : Perte de connexion lors de changements distants

**Problème** : Changer l'IP d'une machine distante et perdre la connexion.

```powershell
# ❌ Dangereux sur une connexion RDP
Remove-NetIPAddress -InterfaceAlias "Ethernet" -Confirm:$false
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "10.0.0.100" -PrefixLength 8
# Connexion perdue si la nouvelle IP n'est pas dans votre réseau !

# ✅ Solution : Script avec rollback automatique
$RollbackScript = @'
Start-Sleep -Seconds 60
$CurrentIP = (Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4).IPAddress
if ($CurrentIP -eq "10.0.0.100") {
    Remove-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "10.0.0.100" -Confirm:$false
    New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.100" -PrefixLength 24 -DefaultGateway "192.168.1.1"
}
'@

# Créer une tâche planifiée de rollback
Start-Job -ScriptBlock ([scriptblock]::Create($RollbackScript))

# Faire le changement
Remove-NetIPAddress -InterfaceAlias "Ethernet" -Confirm:$false
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "10.0.0.100" -PrefixLength 8 -DefaultGateway "10.0.0.1"

# Si ça marche, annuler le rollback
# Stop-Job -Name Job1
```

### Piège 5 : DNS ne se met pas à jour

**Problème** : Après avoir changé les serveurs DNS, les résolutions utilisent toujours les anciens.

```powershell
# ❌ Le cache DNS conserve les anciennes résolutions
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "1.1.1.1"
Resolve-DnsName google.com  # Utilise encore le cache

# ✅ Solution : Vider le cache DNS après changement
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "1.1.1.1","1.0.0.1"
Clear-DnsClientCache
ipconfig /flushdns  # Alternative
Resolve-DnsName google.com  # Maintenant utilise les nouveaux DNS
```

### Piège 6 : PrefixLength incorrect

**Problème** : Utiliser un masque incorrect qui empêche la communication.

```powershell
# ❌ Erreur : Masque trop restrictif
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.100" -PrefixLength 32
# /32 = 255.255.255.255 = UNE SEULE IP, aucun hôte dans le réseau !

# ✅ Solution : Utiliser le bon masque pour votre réseau
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.100" -PrefixLength 24  # /24 pour réseau de 254 hôtes
```

> [!warning] Tableau des masques courants
> 
> - **/32** : 1 seule IP (point-to-point uniquement)
> - **/30** : 4 IPs (2 utilisables) - liens point-to-point
> - **/24** : 256 IPs (254 utilisables) - réseau d'entreprise standard
> - **/16** : 65536 IPs (65534 utilisables) - grand réseau d'entreprise
> - **/8** : 16+ millions d'IPs - classe A

### Piège 7 : Interface mal identifiée

**Problème** : Nom d'interface incorrect ou ambigu.

```powershell
# ❌ Nom approximatif qui échoue
New-NetIPAddress -InterfaceAlias "Eth" -IPAddress "192.168.1.100" -PrefixLength 24
# Erreur : Interface introuvable

# ✅ Solution : Lister et utiliser le nom exact
Get-NetAdapter | Format-Table Name, Status, LinkSpeed
# Utiliser le nom EXACT tel qu'affiché
New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress "192.168.1.100" -PrefixLength 24

# Ou utiliser l'index (plus fiable)
$Index = (Get-NetAdapter -Name "Ethernet 2").ifIndex
New-NetIPAddress -InterfaceIndex $Index -IPAddress "192.168.1.100" -PrefixLength 24
```

---

## 📊 Comparaison des méthodes de configuration

|Méthode|Avantages|Inconvénients|Cas d'usage|
|---|---|---|---|
|**Interface graphique**|Visuel, intuitif|Lent, non scriptable|Postes clients, dépannage ponctuel|
|**netsh**|Compatible anciennes versions|Syntaxe complexe, obsolète|Systèmes legacy|
|**PowerShell**|Scriptable, moderne, puissant|Courbe d'apprentissage|Serveurs, automatisation, production|
|**DHCP**|Automatique, centralisé|Moins de contrôle|Postes clients, réseaux dynamiques|

---

## 🔧 Scripts pratiques prêts à l'emploi

### Script 1 : Configuration réseau complète avec validation

```powershell
function Deploy-StaticIPConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$InterfaceAlias,
        
        [Parameter(Mandatory)]
        [string]$IPAddress,
        
        [Parameter(Mandatory)]
        [int]$PrefixLength,
        
        [Parameter(Mandatory)]
        [string]$Gateway,
        
        [string[]]$DNSServers = @("8.8.8.8","8.8.4.4"),
        
        [switch]$ValidateConnectivity
    )
    
    Write-Host "`n=== Configuration réseau pour $InterfaceAlias ===" -ForegroundColor Cyan
    
    try {
        # 1. Vérification de l'interface
        Write-Host "[1/6] Vérification de l'interface..." -ForegroundColor Yellow
        $Adapter = Get-NetAdapter -Name $InterfaceAlias -ErrorAction Stop
        if ($Adapter.Status -ne "Up") {
            throw "L'interface $InterfaceAlias n'est pas active (Status: $($Adapter.Status))"
        }
        Write-Host "  ✓ Interface active" -ForegroundColor Green
        
        # 2. Désactivation DHCP
        Write-Host "[2/6] Désactivation de DHCP..." -ForegroundColor Yellow
        Set-NetIPInterface -InterfaceAlias $InterfaceAlias -Dhcp Disabled
        Write-Host "  ✓ DHCP désactivé" -ForegroundColor Green
        
        # 3. Suppression des IPs existantes
        Write-Host "[3/6] Nettoyage des IPs existantes..." -ForegroundColor Yellow
        Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "  ✓ IPs nettoyées" -ForegroundColor Green
        
        # 4. Configuration de l'IP statique
        Write-Host "[4/6] Configuration de l'IP statique..." -ForegroundColor Yellow
        New-NetIPAddress -InterfaceAlias $InterfaceAlias `
                         -IPAddress $IPAddress `
                         -PrefixLength $PrefixLength `
                         -DefaultGateway $Gateway `
                         -ErrorAction Stop | Out-Null
        Write-Host "  ✓ IP configurée : $IPAddress/$PrefixLength" -ForegroundColor Green
        
        # 5. Configuration DNS
        Write-Host "[5/6] Configuration des serveurs DNS..." -ForegroundColor Yellow
        Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias `
                                   -ServerAddresses $DNSServers `
                                   -ErrorAction Stop
        Clear-DnsClientCache
        Write-Host "  ✓ DNS configurés : $($DNSServers -join ', ')" -ForegroundColor Green
        
        # 6. Validation
        if ($ValidateConnectivity) {
            Write-Host "[6/6] Validation de la connectivité..." -ForegroundColor Yellow
            
            # Test gateway
            if (Test-Connection -ComputerName $Gateway -Count 2 -Quiet) {
                Write-Host "  ✓ Gateway accessible ($Gateway)" -ForegroundColor Green
            } else {
                Write-Warning "  ⚠ Gateway non accessible ($Gateway)"
            }
            
            # Test DNS
            try {
                $null = Resolve-DnsName google.com -ErrorAction Stop
                Write-Host "  ✓ Résolution DNS fonctionnelle" -ForegroundColor Green
            } catch {
                Write-Warning "  ⚠ Problème de résolution DNS"
            }
            
            # Test Internet
            if (Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet) {
                Write-Host "  ✓ Connectivité Internet OK" -ForegroundColor Green
            } else {
                Write-Warning "  ⚠ Pas de connectivité Internet"
            }
        } else {
            Write-Host "[6/6] Validation ignorée (utilisez -ValidateConnectivity)" -ForegroundColor Gray
        }
        
        Write-Host "`n=== Configuration terminée avec succès ===" -ForegroundColor Green
        
        # Afficher la configuration finale
        Write-Host "`nConfiguration finale :" -ForegroundColor Cyan
        Get-NetIPConfiguration -InterfaceAlias $InterfaceAlias | Format-List
        
    } catch {
        Write-Host "`n=== ERREUR lors de la configuration ===" -ForegroundColor Red
        Write-Host "Erreur : $_" -ForegroundColor Red
        Write-Host "`nRollback recommandé !" -ForegroundColor Yellow
        return $false
    }
    
    return $true
}

# Exemple d'utilisation
Deploy-StaticIPConfiguration -InterfaceAlias "Ethernet" `
                            -IPAddress "192.168.1.100" `
                            -PrefixLength 24 `
                            -Gateway "192.168.1.1" `
                            -DNSServers "192.168.1.1","8.8.8.8" `
                            -ValidateConnectivity
```

### Script 2 : Backup et restauration de configuration

```powershell
# Fonction de backup
function Backup-NetworkConfiguration {
    param(
        [string]$BackupPath = "C:\NetworkBackup"
    )
    
    if (-not (Test-Path $BackupPath)) {
        New-Item -Path $BackupPath -ItemType Directory | Out-Null
    }
    
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $BackupFile = Join-Path $BackupPath "NetworkConfig_$Timestamp.xml"
    
    $Config = Get-NetIPConfiguration | ForEach-Object {
        [PSCustomObject]@{
            InterfaceAlias = $_.InterfaceAlias
            InterfaceIndex = $_.InterfaceIndex
            IPv4Address = $_.IPv4Address.IPAddress
            IPv4PrefixLength = $_.IPv4Address.PrefixLength
            IPv4Gateway = $_.IPv4DefaultGateway.NextHop
            DNSServers = (Get-DnsClientServerAddress -InterfaceAlias $_.InterfaceAlias -AddressFamily IPv4).ServerAddresses
            DHCPEnabled = (Get-NetIPInterface -InterfaceAlias $_.InterfaceAlias -AddressFamily IPv4).Dhcp
        }
    }
    
    $Config | Export-Clixml -Path $BackupFile
    Write-Host "✓ Configuration sauvegardée : $BackupFile" -ForegroundColor Green
    return $BackupFile
}

# Fonction de restauration
function Restore-NetworkConfiguration {
    param(
        [Parameter(Mandatory)]
        [string]$BackupFile
    )
    
    if (-not (Test-Path $BackupFile)) {
        Write-Error "Fichier de backup introuvable : $BackupFile"
        return
    }
    
    $Config = Import-Clixml -Path $BackupFile
    
    foreach ($Interface in $Config) {
        Write-Host "Restauration de $($Interface.InterfaceAlias)..." -ForegroundColor Yellow
        
        try {
            # Nettoyer la configuration actuelle
            Remove-NetIPAddress -InterfaceAlias $Interface.InterfaceAlias -Confirm:$false -ErrorAction SilentlyContinue
            
            if ($Interface.DHCPEnabled -eq "Enabled") {
                # Restaurer DHCP
                Set-NetIPInterface -InterfaceAlias $Interface.InterfaceAlias -Dhcp Enabled
                Write-Host "  ✓ DHCP réactivé" -ForegroundColor Green
            } else {
                # Restaurer IP statique
                New-NetIPAddress -InterfaceAlias $Interface.InterfaceAlias `
                                -IPAddress $Interface.IPv4Address `
                                -PrefixLength $Interface.IPv4PrefixLength `
                                -DefaultGateway $Interface.IPv4Gateway `
                                -ErrorAction Stop | Out-Null
                
                # Restaurer DNS
                Set-DnsClientServerAddress -InterfaceAlias $Interface.InterfaceAlias `
                                          -ServerAddresses $Interface.DNSServers
                
                Write-Host "  ✓ Configuration statique restaurée" -ForegroundColor Green
            }
        } catch {
            Write-Host "  ✗ Erreur : $_" -ForegroundColor Red
        }
    }
    
    Write-Host "`n=== Restauration terminée ===" -ForegroundColor Green
}

# Utilisation
# Backup avant modification
$BackupFile = Backup-NetworkConfiguration

# ... faire des modifications ...

# Restaurer si nécessaire
# Restore-NetworkConfiguration -BackupFile $BackupFile
```

### Script 3 : Configuration multi-interfaces automatisée

```powershell
# Configuration de plusieurs interfaces à partir d'un fichier CSV
function Deploy-MultiInterfaceConfig {
    param(
        [Parameter(Mandatory)]
        [string]$ConfigFile
    )
    
    if (-not (Test-Path $ConfigFile)) {
        Write-Error "Fichier de configuration introuvable"
        return
    }
    
    $Configs = Import-Csv $ConfigFile
    
    foreach ($Config in $Configs) {
        Write-Host "`n=== Configuration de $($Config.InterfaceAlias) ===" -ForegroundColor Cyan
        
        Deploy-StaticIPConfiguration -InterfaceAlias $Config.InterfaceAlias `
                                    -IPAddress $Config.IPAddress `
                                    -PrefixLength $Config.PrefixLength `
                                    -Gateway $Config.Gateway `
                                    -DNSServers ($Config.DNSServers -split ';') `
                                    -ValidateConnectivity
        
        Start-Sleep -Seconds 2
    }
}

# Créer un fichier CSV exemple
$CSVContent = @"
InterfaceAlias,IPAddress,PrefixLength,Gateway,DNSServers
Ethernet,192.168.1.10,24,192.168.1.1,8.8.8.8;8.8.4.4
Ethernet2,10.0.0.10,8,10.0.0.1,10.0.0.1;8.8.8.8
"@

$CSVContent | Out-File "NetworkConfig.csv"

# Déployer la configuration
# Deploy-MultiInterfaceConfig -ConfigFile "NetworkConfig.csv"
```

### Script 4 : Monitoring et alerte

```powershell
function Start-NetworkMonitoring {
    param(
        [Parameter(Mandatory)]
        [string]$InterfaceAlias,
        
        [Parameter(Mandatory)]
        [string]$ExpectedIP,
        
        [int]$IntervalSeconds = 60,
        
        [string]$LogFile = "C:\Logs\NetworkMonitor.log"
    )
    
    Write-Host "Démarrage du monitoring de $InterfaceAlias..." -ForegroundColor Green
    Write-Host "IP attendue : $ExpectedIP" -ForegroundColor Green
    Write-Host "Appuyez sur Ctrl+C pour arrêter`n" -ForegroundColor Yellow
    
    $LogDir = Split-Path $LogFile -Parent
    if (-not (Test-Path $LogDir)) {
        New-Item -Path $LogDir -ItemType Directory | Out-Null
    }
    
    while ($true) {
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        try {
            $CurrentIP = (Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -ErrorAction Stop).IPAddress
            $Gateway = (Get-NetRoute -InterfaceAlias $InterfaceAlias | Where-Object DestinationPrefix -eq "0.0.0.0/0").NextHop
            $DNS = (Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4).ServerAddresses
            
            # Vérifier l'IP
            if ($CurrentIP -ne $ExpectedIP) {
                $Message = "[$Timestamp] ALERTE : IP changée ! Attendue: $ExpectedIP, Actuelle: $CurrentIP"
                Write-Host $Message -ForegroundColor Red
                $Message | Out-File $LogFile -Append
            } else {
                $Message = "[$Timestamp] OK : IP correcte ($CurrentIP)"
                Write-Host $Message -ForegroundColor Green
            }
            
            # Tester la connectivité
            if ($Gateway) {
                $GatewayTest = Test-Connection -ComputerName $Gateway -Count 1 -Quiet
                if (-not $GatewayTest) {
                    $Message = "[$Timestamp] ALERTE : Gateway inaccessible ($Gateway)"
                    Write-Host $Message -ForegroundColor Red
                    $Message | Out-File $LogFile -Append
                }
            }
            
        } catch {
            $Message = "[$Timestamp] ERREUR : $_"
            Write-Host $Message -ForegroundColor Red
            $Message | Out-File $LogFile -Append
        }
        
        Start-Sleep -Seconds $IntervalSeconds
    }
}

# Utilisation
# Start-NetworkMonitoring -InterfaceAlias "Ethernet" -ExpectedIP "192.168.1.100" -IntervalSeconds 30
```

---

## 🎓 Synthèse des commandes essentielles

### Commandes de consultation

```powershell
# Lister toutes les interfaces
Get-NetAdapter

# Voir les IPs configurées
Get-NetIPAddress

# Configuration complète réseau
Get-NetIPConfiguration

# Voir les routes (passerelles)
Get-NetRoute

# Voir les DNS
Get-DnsClientServerAddress

# Cache DNS
Get-DnsClientCache
```

### Commandes de configuration

```powershell
# Créer une IP statique complète
New-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "192.168.1.100" `
                 -PrefixLength 24 `
                 -DefaultGateway "192.168.1.1"

# Modifier le masque
Set-NetIPAddress -InterfaceAlias "Ethernet" `
                 -IPAddress "192.168.1.100" `
                 -PrefixLength 16

# Supprimer une IP
Remove-NetIPAddress -IPAddress "192.168.1.100" -Confirm:$false

# Configurer DNS
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
                           -ServerAddresses "8.8.8.8","8.8.4.4"

# Reset DNS (retour à DHCP)
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses

# Activer/Désactiver DHCP
Set-NetIPInterface -InterfaceAlias "Ethernet" -Dhcp Enabled
Set-NetIPInterface -InterfaceAlias "Ethernet" -Dhcp Disabled
```

### Commandes de diagnostic

```powershell
# Test de connectivité simple
Test-Connection -ComputerName "192.168.1.1" -Count 4

# Test de connectivité détaillé
Test-NetConnection -ComputerName "google.com" -InformationLevel Detailed

# Test de résolution DNS
Resolve-DnsName google.com

# Test d'un serveur DNS spécifique
Resolve-DnsName google.com -Server 8.8.8.8

# Vider le cache DNS
Clear-DnsClientCache
ipconfig /flushdns

# Renouveler l'IP DHCP
Restart-NetAdapter -Name "Ethernet"
ipconfig /renew
```

---

> [!success] Récapitulatif Vous maîtrisez maintenant la configuration réseau complète avec PowerShell :
> 
> ✅ **New-NetIPAddress** : Créer des configurations IP statiques ✅ **Set-NetIPAddress** : Modifier des configurations existantes  
> ✅ **Remove-NetIPAddress** : Supprimer proprement des IPs ✅ **Set-DnsClientServerAddress** : Gérer les serveurs DNS ✅ **Scripts avancés** : Automatisation, backup, monitoring ✅ **Bonnes pratiques** : Validation, sécurité, troubleshooting
> 
> Ces commandes sont essentielles pour l'administration système Windows moderne et remplacent avantageusement les anciens outils graphiques ou `netsh`.