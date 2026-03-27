

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

Cette section couvre deux cmdlets essentielles pour interroger et diagnostiquer la configuration IP d'un système Windows. Ces commandes constituent la base de tout travail d'administration réseau en PowerShell et remplacent avantageusement les outils classiques comme `ipconfig`.

> [!info] Pourquoi ces cmdlets ?
> 
> - **Get-NetIPAddress** : Interrogation granulaire des adresses IP avec filtrage avancé
> - **Get-NetIPConfiguration** : Vue d'ensemble rapide de la configuration réseau complète
> 
> Contrairement aux outils textuels traditionnels, ces cmdlets retournent des objets PowerShell facilement manipulables et scriptables.

---

## Get-NetIPAddress

### Vue d'ensemble

`Get-NetIPAddress` est la cmdlet de référence pour lister et examiner toutes les adresses IP configurées sur un système. Elle fournit des informations détaillées sur chaque adresse, son origine, son état et ses propriétés.

> [!tip] Quand l'utiliser ?
> 
> - Inventaire des adresses IP configurées
> - Vérification de la configuration DHCP vs statique
> - Diagnostic de problèmes d'adressage
> - Filtrage d'adresses spécifiques pour automatisation
> - Audit de configuration réseau

### Syntaxe et paramètres

```powershell
Get-NetIPAddress [[-IPAddress] <String[]>]
                 [-InterfaceIndex <UInt32[]>]
                 [-InterfaceAlias <String[]>]
                 [-AddressFamily {IPv4 | IPv6}]
                 [-Type {Unicast | Anycast}]
                 [-PrefixLength <Byte[]>]
                 [-PrefixOrigin {Manual | WellKnown | DHCP | RouterAdvertisement}]
                 [-SuffixOrigin {Manual | WellKnown | DHCP | Link | Random}]
                 [-AddressState {Invalid | Tentative | Duplicate | Deprecated | Preferred}]
                 [-IncludeAllCompartments]
                 [<CommonParameters>]
```

#### Paramètres principaux

|Paramètre|Description|Exemple|
|---|---|---|
|`-IPAddress`|Adresse IP spécifique à rechercher|`Get-NetIPAddress -IPAddress "192.168.1.100"`|
|`-InterfaceAlias`|Nom de l'interface réseau|`Get-NetIPAddress -InterfaceAlias "Ethernet"`|
|`-InterfaceIndex`|Index numérique de l'interface|`Get-NetIPAddress -InterfaceIndex 12`|
|`-AddressFamily`|Famille d'adresses (IPv4/IPv6)|`Get-NetIPAddress -AddressFamily IPv4`|
|`-Type`|Type d'adresse (Unicast/Anycast)|`Get-NetIPAddress -Type Unicast`|
|`-PrefixOrigin`|Origine de l'adresse|`Get-NetIPAddress -PrefixOrigin DHCP`|

### Propriétés des adresses IP

Chaque objet retourné contient des propriétés riches permettant une analyse approfondie :

#### Propriétés d'identification

```powershell
# Exemple de sortie
Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4

# Propriétés clés :
# - IPAddress        : L'adresse IP elle-même (ex: 192.168.1.100)
# - InterfaceAlias   : Nom convivial de l'interface (ex: "Ethernet")
# - InterfaceIndex   : Index numérique unique de l'interface (ex: 12)
# - AddressFamily    : IPv4 ou IPv6
```

> [!example] Identification d'interface
> 
> ```powershell
> # Récupérer l'index d'une interface pour l'utiliser ailleurs
> $ethIndex = (Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4).InterfaceIndex
> ```

#### Propriétés de configuration

**PrefixLength** : Masque de sous-réseau en notation CIDR

```powershell
# PrefixLength = 24 équivaut à un masque 255.255.255.0
# PrefixLength = 16 équivaut à un masque 255.255.0.0
# PrefixLength = 8 équivaut à un masque 255.0.0.0

Get-NetIPAddress | Select-Object IPAddress, PrefixLength
```

**Type** : Nature de l'adresse

- **Unicast** : Adresse standard pour communication point-à-point (le plus courant)
- **Anycast** : Adresse partagée par plusieurs nœuds (rare en environnement Windows standard)

```powershell
# Filtrer uniquement les adresses unicast
Get-NetIPAddress -Type Unicast -AddressFamily IPv4
```

#### Propriétés d'origine

**PrefixOrigin** : Comment l'adresse a été obtenue

|Valeur|Signification|
|---|---|
|`Manual`|Configurée manuellement (statique)|
|`DHCP`|Attribuée par un serveur DHCP|
|`WellKnown`|Adresse réservée (ex: loopback 127.0.0.1)|
|`RouterAdvertisement`|Obtenue via RA (IPv6)|

```powershell
# Identifier toutes les adresses DHCP
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.PrefixOrigin -eq "DHCP"}

# Identifier toutes les adresses statiques
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.PrefixOrigin -eq "Manual"}
```

**SuffixOrigin** : Origine de la partie hôte de l'adresse

|Valeur|Signification|
|---|---|
|`Manual`|Configurée manuellement|
|`DHCP`|Attribuée par DHCP|
|`Link`|Générée automatiquement (APIPA, ex: 169.254.x.x)|
|`Random`|Générée aléatoirement (IPv6 privacy extensions)|
|`WellKnown`|Adresse réservée|

> [!warning] Adresses APIPA Si `SuffixOrigin = Link` et l'adresse est en 169.254.x.x, cela indique un échec DHCP. Le système a auto-assigné une adresse APIPA (Automatic Private IP Addressing).

#### Propriétés d'état

**AddressState** : État actuel de l'adresse

|État|Description|
|---|---|
|`Preferred`|Adresse valide et utilisable (état normal)|
|`Tentative`|Adresse en cours de validation (DAD - Duplicate Address Detection)|
|`Duplicate`|Conflit d'adresse détecté|
|`Deprecated`|Adresse encore valide mais déconseillée (transition)|
|`Invalid`|Adresse invalide ou expirée|

```powershell
# Vérifier qu'aucune adresse n'est en état problématique
Get-NetIPAddress | Where-Object {$_.AddressState -ne "Preferred"} | 
    Select-Object IPAddress, InterfaceAlias, AddressState
```

**ValidLifetime et PreferredLifetime** : Durées de vie (surtout IPv6 et DHCP)

```powershell
# Afficher les durées de vie des adresses
Get-NetIPAddress -AddressFamily IPv4 | 
    Select-Object IPAddress, ValidLifetime, PreferredLifetime

# ValidLifetime   : Temps restant avant expiration totale
# PreferredLifetime : Temps restant avant dépréciation
```

> [!info] TimeSpan Ces valeurs sont des objets TimeSpan. Une valeur de `[TimeSpan]::MaxValue` (9999+ jours) indique généralement une configuration statique sans expiration.

### Filtrage et recherche

#### Filtrer les adresses loopback vs physiques

```powershell
# Exclure le loopback (127.0.0.1 et ::1)
Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.IPAddress -ne "127.0.0.1"}

# Méthode plus robuste : exclure toutes les adresses WellKnown
Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.PrefixOrigin -ne "WellKnown"}
```

#### Filtrer les adresses statiques vs DHCP

```powershell
# Adresses configurées manuellement (statiques)
Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.PrefixOrigin -eq "Manual"} |
    Select-Object IPAddress, InterfaceAlias, PrefixLength

# Adresses DHCP
Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.PrefixOrigin -eq "DHCP"} |
    Select-Object IPAddress, InterfaceAlias, PrefixLength, ValidLifetime
```

#### Identifier les problèmes de configuration

```powershell
# Détecter les adresses APIPA (échec DHCP)
Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.IPAddress -like "169.254.*"} |
    Select-Object IPAddress, InterfaceAlias, PrefixOrigin, SuffixOrigin

# Détecter les conflits d'adresses
Get-NetIPAddress | 
    Where-Object {$_.AddressState -eq "Duplicate"} |
    Format-Table IPAddress, InterfaceAlias, AddressState -AutoSize
```

### Cas d'usage pratiques

#### Inventaire complet de configuration

```powershell
# Vue détaillée de toutes les interfaces physiques IPv4
Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.PrefixOrigin -ne "WellKnown"} |
    Select-Object IPAddress, 
                  InterfaceAlias, 
                  PrefixLength, 
                  PrefixOrigin, 
                  AddressState |
    Format-Table -AutoSize
```

#### Export pour documentation

```powershell
# Créer un rapport CSV de configuration IP
Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.PrefixOrigin -ne "WellKnown"} |
    Select-Object @{N='Adresse IP';E={$_.IPAddress}},
                  @{N='Interface';E={$_.InterfaceAlias}},
                  @{N='Masque CIDR';E={$_.PrefixLength}},
                  @{N='Type';E={$_.PrefixOrigin}},
                  @{N='État';E={$_.AddressState}} |
    Export-Csv -Path "C:\Inventory\IPConfig.csv" -Encoding UTF8 -NoTypeInformation
```

#### Vérification avant modification

```powershell
# Vérifier la configuration actuelle avant changement
$currentIP = Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 |
    Where-Object {$_.PrefixOrigin -ne "WellKnown"}

if ($currentIP.PrefixOrigin -eq "DHCP") {
    Write-Host "Interface actuellement en DHCP" -ForegroundColor Yellow
    Write-Host "Adresse actuelle : $($currentIP.IPAddress)/$($currentIP.PrefixLength)"
} else {
    Write-Host "Interface en configuration statique" -ForegroundColor Green
    Write-Host "Adresse : $($currentIP.IPAddress)/$($currentIP.PrefixLength)"
}
```

---

## Get-NetIPConfiguration

### Vue d'ensemble

`Get-NetIPConfiguration` offre une vue d'ensemble consolidée de la configuration réseau par interface. C'est l'équivalent moderne et orienté objet de la commande `ipconfig`, avec l'avantage de retourner des objets PowerShell structurés.

> [!tip] Quand l'utiliser ?
> 
> - Diagnostic rapide de connectivité
> - Vue d'ensemble de la configuration réseau
> - Vérification de passerelles et DNS
> - Scripts de validation de configuration
> - Alternative moderne à `ipconfig`

### Syntaxe et paramètres

```powershell
Get-NetIPConfiguration [[-InterfaceAlias] <String[]>]
                       [-InterfaceIndex <UInt32[]>]
                       [-Detailed]
                       [-All]
                       [<CommonParameters>]
```

#### Paramètres clés

|Paramètre|Description|Comportement|
|---|---|---|
|`-InterfaceAlias`|Cibler une interface spécifique|Filtre par nom d'interface|
|`-InterfaceIndex`|Cibler par index numérique|Filtre par index|
|`-Detailed`|Informations complètes|Ajoute détails supplémentaires|
|`-All`|Toutes les interfaces|Inclut interfaces désactivées|

> [!info] Comportement par défaut Sans paramètres, `Get-NetIPConfiguration` affiche uniquement les interfaces ayant une passerelle par défaut configurée (généralement les interfaces actives connectées).

### Informations retournées

#### Vue standard

```powershell
Get-NetIPConfiguration

# Retourne pour chaque interface :
# - InterfaceAlias        : Nom de l'interface
# - InterfaceIndex        : Index numérique
# - InterfaceDescription  : Description matérielle
# - IPv4Address           : Adresse(s) IPv4
# - IPv6DefaultGateway    : Passerelle IPv6
# - IPv4DefaultGateway    : Passerelle IPv4
# - DNSServer             : Serveurs DNS configurés
```

#### Vue détaillée avec -Detailed

```powershell
Get-NetIPConfiguration -Detailed

# Informations supplémentaires :
# - NetProfile            : Profil réseau (domaine, privé, public)
# - IPv6LinkLocalAddress  : Adresse link-local IPv6
# - NetAdapter            : Objet adaptateur réseau complet
# - Toutes les adresses IP (pas seulement la principale)
# - DHCPv4Enabled         : État du client DHCP
# - ConnectionProfile     : Détails du profil de connexion
```

> [!example] Différence entre vues
> 
> ```powershell
> # Vue standard : synthétique, adresse IP principale
> Get-NetIPConfiguration -InterfaceAlias "Ethernet"
> 
> # Vue détaillée : toutes les adresses, état DHCP, profil réseau
> Get-NetIPConfiguration -InterfaceAlias "Ethernet" -Detailed
> ```

#### Afficher toutes les interfaces avec -All

```powershell
# Par défaut : uniquement interfaces avec passerelle
Get-NetIPConfiguration

# Avec -All : toutes les interfaces, même désactivées ou sans passerelle
Get-NetIPConfiguration -All
```

### Comparaison avec ipconfig

|Commande classique|Équivalent PowerShell|Avantage PS|
|---|---|---|
|`ipconfig`|`Get-NetIPConfiguration`|Objets manipulables|
|`ipconfig /all`|`Get-NetIPConfiguration -Detailed`|Filtrage et tri faciles|
|`ipconfig /renew`|`Restart-NetAdapter` ou `Renew-DhcpLease`|Actions ciblées|

```powershell
# Ipconfig traditionnel (sortie texte)
ipconfig

# Équivalent PowerShell moderne (objets)
Get-NetIPConfiguration | Format-Table InterfaceAlias, IPv4Address, IPv4DefaultGateway

# Ipconfig détaillé
ipconfig /all

# Équivalent PowerShell
Get-NetIPConfiguration -Detailed
```

> [!tip] Avantages de Get-NetIPConfiguration
> 
> - Filtrage : `Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null}`
> - Sélection : `Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address`
> - Export : `Get-NetIPConfiguration | Export-Csv ...`
> - Automatisation : Objets utilisables dans scripts et conditions

### Cas d'usage pratiques

#### Diagnostic rapide de connectivité

```powershell
# Vérification express de la configuration réseau
Get-NetIPConfiguration | 
    Select-Object InterfaceAlias, 
                  @{N='IPv4';E={$_.IPv4Address.IPAddress}},
                  @{N='Passerelle';E={$_.IPv4DefaultGateway.NextHop}},
                  @{N='DNS';E={($_.DNSServer.ServerAddresses | Where-Object {$_ -notlike "*:*"}) -join ', '}} |
    Format-Table -AutoSize
```

#### Identifier les interfaces sans passerelle

```powershell
# Trouver les interfaces configurées mais sans passerelle (potentiellement problématique)
Get-NetIPConfiguration -All | 
    Where-Object {$_.IPv4DefaultGateway -eq $null -and $_.IPv4Address -ne $null} |
    Select-Object InterfaceAlias, IPv4Address
```

> [!warning] Interfaces sans passerelle Une interface avec une adresse IP mais sans passerelle ne peut communiquer qu'en local sur son sous-réseau. Cela peut être voulu (réseau isolé) ou indiquer un problème de configuration.

#### Vérification de configuration DNS

```powershell
# Lister tous les serveurs DNS configurés
Get-NetIPConfiguration -All | 
    ForEach-Object {
        [PSCustomObject]@{
            Interface = $_.InterfaceAlias
            DNSServers = ($_.DNSServer.ServerAddresses -join ', ')
        }
    } | Format-Table -AutoSize
```

#### Export de configuration complète

```powershell
# Documentation de configuration pour audit
$config = Get-NetIPConfiguration -All | Select-Object InterfaceAlias,
    @{N='IPv4Address';E={$_.IPv4Address.IPAddress}},
    @{N='IPv4Gateway';E={$_.IPv4DefaultGateway.NextHop}},
    @{N='IPv6Address';E={$_.IPv6Address.IPAddress}},
    @{N='IPv6Gateway';E={$_.IPv6DefaultGateway.NextHop}},
    @{N='DNSServers';E={$_.DNSServer.ServerAddresses -join '; '}}

$config | Export-Csv -Path "C:\Reports\NetworkConfig_$(Get-Date -Format 'yyyyMMdd').csv" `
                     -Encoding UTF8 -NoTypeInformation
```

#### Comparaison profil réseau

```powershell
# Identifier le type de réseau (domaine, privé, public)
Get-NetIPConfiguration -Detailed | 
    Where-Object {$_.NetProfile -ne $null} |
    Select-Object InterfaceAlias, 
                  @{N='NetworkCategory';E={$_.NetProfile.NetworkCategory}},
                  @{N='Name';E={$_.NetProfile.Name}} |
    Format-Table -AutoSize
```

> [!info] Catégories réseau
> 
> - **Domain** : Réseau de domaine Active Directory
> - **Private** : Réseau privé (maison, bureau de confiance)
> - **Public** : Réseau public (règles firewall plus strictes)

---

## Pièges courants

### 1. Confusion entre interface alias et description

```powershell
# ❌ Mauvais : Utiliser la description au lieu de l'alias
Get-NetIPAddress -InterfaceAlias "Intel(R) Ethernet Connection"

# ✅ Bon : Utiliser l'alias correct
Get-NetIPAddress -InterfaceAlias "Ethernet"

# Pour trouver l'alias correct
Get-NetAdapter | Select-Object Name, InterfaceDescription
```

> [!warning] Alias vs Description
> 
> - **InterfaceAlias** (Name) : Nom court et modifiable (ex: "Ethernet", "Wi-Fi")
> - **InterfaceDescription** : Description matérielle longue (ex: "Intel(R) I219-V Gigabit Network Connection")
> 
> Toujours utiliser l'alias dans les commandes de configuration.

### 2. Oublier de filtrer les adresses loopback

```powershell
# ❌ Inclut le loopback 127.0.0.1 dans les résultats
Get-NetIPAddress -AddressFamily IPv4

# ✅ Exclure le loopback pour configuration réseau réelle
Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.PrefixOrigin -ne "WellKnown"}
```

### 3. Ne pas vérifier l'état de l'adresse

```powershell
# ❌ Utiliser une adresse sans vérifier son état
$ip = (Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4).IPAddress

# ✅ Vérifier que l'adresse est dans l'état Preferred
$ip = Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 | 
    Where-Object {$_.AddressState -eq "Preferred"} |
    Select-Object -ExpandProperty IPAddress
```

### 4. Confondre PrefixLength et masque de sous-réseau

```powershell
# ❌ Tentative d'utiliser un masque classique
Get-NetIPAddress | Where-Object {$_.SubnetMask -eq "255.255.255.0"}  # Propriété n'existe pas

# ✅ Utiliser PrefixLength (notation CIDR)
Get-NetIPAddress | Where-Object {$_.PrefixLength -eq 24}  # /24 = 255.255.255.0
```

> [!info] Conversion CIDR
> 
> - /8 = 255.0.0.0
> - /16 = 255.255.0.0
> - /24 = 255.255.255.0
> - /32 = 255.255.255.255 (hôte unique)

### 5. Ignorer les interfaces multiples

```powershell
# ❌ Suppose qu'il n'y a qu'une seule interface Ethernet
$ip = (Get-NetIPAddress -InterfaceAlias "Ethernet").IPAddress

# ✅ Gérer le cas de plusieurs adresses IP
$ips = Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 | 
    Where-Object {$_.PrefixOrigin -ne "WellKnown"}

if ($ips.Count -gt 1) {
    Write-Warning "Plusieurs adresses IP trouvées !"
    $ips | Select-Object IPAddress, PrefixOrigin
}
```

### 6. Utiliser Get-NetIPConfiguration sans filtres sur systèmes multi-interfaces

```powershell
# ❌ Sur un serveur avec 10 interfaces, obtient une sortie volumineuse
Get-NetIPConfiguration -All

# ✅ Cibler l'interface nécessaire
Get-NetIPConfiguration -InterfaceAlias "Ethernet Production"

# ✅ Ou filtrer sur critère spécifique
Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null}
```

---

## Bonnes pratiques

### 1. Toujours filtrer par AddressFamily dans les scripts

```powershell
# ✅ Explicite et prévisible
Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Ethernet"

# Évite de mélanger IPv4 et IPv6 dans les résultats
```

### 2. Utiliser des propriétés calculées pour la lisibilité

```powershell
# ✅ Créer des rapports clairs
Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.PrefixOrigin -ne "WellKnown"} |
    Select-Object @{N='Interface';E={$_.InterfaceAlias}},
                  @{N='IP Address';E={$_.IPAddress}},
                  @{N='Subnet';E={"/$($_.PrefixLength)"}},
                  @{N='Type';E={
                      switch ($_.PrefixOrigin) {
                          'Manual' {'Statique'}
                          'DHCP' {'DHCP'}
                          default {$_.PrefixOrigin}
                      }
                  }},
                  @{N='Status';E={$_.AddressState}} |
    Format-Table -AutoSize
```

### 3. Combiner Get-NetIPAddress et Get-NetIPConfiguration

```powershell
# ✅ Utiliser les forces de chaque cmdlet
# Get-NetIPConfiguration pour vue d'ensemble et DNS/passerelle
$config = Get-NetIPConfiguration -InterfaceAlias "Ethernet"

# Get-NetIPAddress pour détails d'adressage spécifiques
$addresses = Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 | 
    Where-Object {$_.PrefixOrigin -ne "WellKnown"}

# Rapport combiné
[PSCustomObject]@{
    Interface = $config.InterfaceAlias
    IPv4 = $addresses.IPAddress
    PrefixLength = $addresses.PrefixLength
    Gateway = $config.IPv4DefaultGateway.NextHop
    DNS = $config.DNSServer.ServerAddresses -join ', '
    Type = $addresses.PrefixOrigin
}
```

### 4. Gérer les erreurs gracieusement

```powershell
# ✅ Vérifier l'existence de l'interface
$interfaceExists = Get-NetAdapter -Name "Ethernet" -ErrorAction SilentlyContinue

if ($interfaceExists) {
    $ipConfig = Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 -ErrorAction Stop
    
    if ($ipConfig) {
        Write-Host "Configuration trouvée : $($ipConfig.IPAddress)"
    } else {
        Write-Warning "Aucune adresse IPv4 configurée sur Ethernet"
    }
} else {
    Write-Error "Interface Ethernet introuvable"
}
```

### 5. Documenter le contexte dans les scripts

```powershell
# ✅ Commenter l'intention
# Récupération de l'adresse IP primaire pour configuration firewall
$primaryIP = Get-NetIPAddress -InterfaceAlias "Ethernet LAN" -AddressFamily IPv4 | 
    Where-Object {
        $_.PrefixOrigin -ne "WellKnown" -and  # Exclure loopback
        $_.AddressState -eq "Preferred"        # Uniquement adresses actives
    } | 
    Select-Object -First 1 -ExpandProperty IPAddress

if (-not $primaryIP) {
    throw "Impossible de déterminer l'adresse IP primaire"
}
```

### 6. Utiliser -Detailed uniquement quand nécessaire

```powershell
# ❌ Gaspillage de ressources si information non nécessaire
Get-NetIPConfiguration -All -Detailed | Select-Object InterfaceAlias, IPv4Address

# ✅ Vue standard suffisante pour cas simple
Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address

# ✅ Detailed uniquement si profil réseau ou détails DHCP nécessaires
$config = Get-NetIPConfiguration -InterfaceAlias "Ethernet" -Detailed
$networkCategory = $config.NetProfile.NetworkCategory
```

### 7. Créer des fonctions réutilisables

```powershell
# ✅ Encapsuler la logique courante
function Get-PrimaryIPv4Address {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$InterfaceAlias
    )
    
    $ip = Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -ErrorAction Stop | 
        Where-Object {
            $_.PrefixOrigin -ne "WellKnown" -and 
            $_.AddressState -eq "Preferred"
        } | 
        Select-Object -First 1
    
    if (-not $ip) {
        throw "Aucune adresse IPv4 valide trouvée sur $InterfaceAlias"
    }
    
    return $ip
}

# Utilisation
$ethIP = Get-PrimaryIPv4Address -InterfaceAlias "Ethernet"
Write-Host "IP principale : $($ethIP.IPAddress)/$($ethIP.PrefixLength)"
```

---

> [!tip] Astuce finale Ces deux cmdlets forment la base de tout diagnostic réseau en PowerShell. Maîtriser leur utilisation et leurs propriétés permet de construire des scripts robustes et des outils d'automatisation fiables pour la gestion de configuration IP.