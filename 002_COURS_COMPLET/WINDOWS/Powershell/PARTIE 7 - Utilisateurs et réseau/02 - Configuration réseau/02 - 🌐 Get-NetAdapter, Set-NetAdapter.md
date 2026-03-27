

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

## Introduction

Les cmdlets **Get-NetAdapter** et **Set-NetAdapter** constituent le cœur de la gestion des adaptateurs réseau sous Windows. Un adaptateur réseau (ou carte réseau) est l'interface matérielle ou virtuelle qui permet à votre système de communiquer sur un réseau. Ces commandes permettent d'interroger l'état des adaptateurs, de les configurer et de les gérer efficacement.

> [!info] Pourquoi c'est important La gestion des adaptateurs réseau est essentielle pour le diagnostic de problèmes de connectivité, l'optimisation des performances réseau, et l'administration de systèmes Windows. Ces cmdlets remplacent avantageusement les anciennes commandes comme `ipconfig` ou `netsh` pour de nombreuses tâches.

---

## Get-NetAdapter - Consultation des adaptateurs

La cmdlet `Get-NetAdapter` permet de lister et d'obtenir des informations détaillées sur tous les adaptateurs réseau présents sur le système, qu'ils soient physiques ou virtuels.

### Syntaxe de base

```powershell
# Liste tous les adaptateurs réseau
Get-NetAdapter

# Liste avec toutes les propriétés
Get-NetAdapter | Format-List *

# Affichage tabulaire détaillé
Get-NetAdapter | Format-Table -AutoSize
```

> [!example] Exemple de sortie standard
> 
> ```powershell
> Name                      InterfaceDescription                    ifIndex Status       MacAddress             LinkSpeed
> ----                      --------------------                    ------- ------       ----------             ---------
> Ethernet                  Intel(R) Ethernet Connection            12      Up           00-1A-2B-3C-4D-5E      1 Gbps
> Wi-Fi                     Qualcomm Atheros Wireless               8       Disconnected 00-AA-BB-CC-DD-EE      0 bps
> ```

---

### Propriétés principales

Chaque adaptateur réseau possède de nombreuses propriétés qui décrivent son état et sa configuration. Voici les plus importantes :

#### 📌 Name (Alias d'interface)

Le nom convivial de l'adaptateur, utilisé pour l'identifier dans les commandes PowerShell.

```powershell
# Obtenir un adaptateur spécifique par son nom
Get-NetAdapter -Name "Ethernet"

# Utiliser le nom dans d'autres commandes
Get-NetAdapter -Name "Wi-Fi" | Select-Object Status, LinkSpeed
```

#### 📌 InterfaceDescription

Description technique complète de l'adaptateur, généralement fournie par le fabricant. C'est le nom du pilote de périphérique.

```powershell
# Filtrer par description d'interface
Get-NetAdapter | Where-Object InterfaceDescription -like "*Intel*"
```

#### 📌 Status

L'état actuel de l'adaptateur. Les valeurs possibles sont :

|Status|Signification|
|---|---|
|**Up**|L'adaptateur est actif et connecté|
|**Down**|L'adaptateur est désactivé|
|**Disconnected**|L'adaptateur est actif mais aucun câble/signal n'est détecté|

```powershell
# Afficher uniquement les adaptateurs actifs
Get-NetAdapter | Where-Object Status -eq "Up"

# Compter les adaptateurs par état
Get-NetAdapter | Group-Object Status
```

> [!warning] Attention à la différence Un adaptateur peut être "Up" (activé dans Windows) mais "Disconnected" (pas de connexion physique). Ces deux états sont différents et importants pour le diagnostic.

#### 📌 MacAddress

L'adresse MAC (Media Access Control) unique de l'adaptateur. C'est un identifiant matériel sur 48 bits, généralement présenté en notation hexadécimale.

```powershell
# Afficher les adresses MAC
Get-NetAdapter | Select-Object Name, MacAddress

# Vérifier si une adresse MAC existe
Get-NetAdapter | Where-Object MacAddress -eq "00-1A-2B-3C-4D-5E"
```

> [!tip] Astuce L'adresse MAC est utilisée pour l'identification unique des périphériques sur un réseau local. Elle est essentielle pour le filtrage MAC, le Wake-on-LAN, et le diagnostic réseau.

#### 📌 LinkSpeed

La vitesse de connexion actuelle de l'adaptateur. Exprimée en bits par seconde (bps), elle indique la bande passante disponible.

```powershell
# Afficher les vitesses de connexion
Get-NetAdapter | Select-Object Name, LinkSpeed, Status

# Identifier les adaptateurs gigabit
Get-NetAdapter | Where-Object LinkSpeed -like "*Gbps*"
```

Valeurs courantes :

- **10 Mbps** : Ancien Ethernet
- **100 Mbps** : Fast Ethernet
- **1 Gbps** : Gigabit Ethernet (standard actuel)
- **10 Gbps** : 10 Gigabit Ethernet (serveurs, datacenters)
- **0 bps** : Aucune connexion active

#### 📌 MediaType

Le type de média physique utilisé par l'adaptateur.

```powershell
# Afficher les types de média
Get-NetAdapter | Select-Object Name, MediaType
```

Valeurs typiques :

- **802.3** : Ethernet filaire
- **Native 802.11** : Wi-Fi
- **Unspecified** : Adaptateurs virtuels

#### 📌 PhysicalMediaType

Type de média physique plus détaillé, spécifiant la technologie exacte.

```powershell
# Explorer les types de média physique
Get-NetAdapter | Select-Object Name, PhysicalMediaType | Format-Table -AutoSize
```

---

### Filtrage et identification

PowerShell offre de puissantes capacités de filtrage pour cibler précisément les adaptateurs souhaités.

#### Filtrage par adaptateurs physiques

```powershell
# Afficher uniquement les adaptateurs physiques (exclut virtuels)
Get-NetAdapter -Physical

# Comparaison : tous vs physiques seulement
Write-Host "Tous les adaptateurs:" -ForegroundColor Cyan
Get-NetAdapter | Measure-Object | Select-Object -ExpandProperty Count

Write-Host "Adaptateurs physiques:" -ForegroundColor Cyan
Get-NetAdapter -Physical | Measure-Object | Select-Object -ExpandProperty Count
```

> [!info] Adaptateurs physiques vs virtuels L'option `-Physical` exclut les adaptateurs créés par des logiciels comme Hyper-V, VirtualBox, Docker, ou les connexions VPN. C'est utile pour se concentrer sur le matériel réel.

#### Filtrage par nom avec wildcards

Le paramètre `-Name` accepte les caractères génériques (wildcards) pour des recherches flexibles.

```powershell
# Tous les adaptateurs Ethernet
Get-NetAdapter -Name "Ethernet*"

# Tous les adaptateurs Wi-Fi
Get-NetAdapter -Name "*Wi-Fi*"

# Pattern matching complexe
Get-NetAdapter -Name "vEthernet*"  # Adaptateurs Hyper-V
```

> [!tip] Wildcards PowerShell
> 
> - `*` : Correspond à zéro ou plusieurs caractères
> - `?` : Correspond à exactement un caractère
> - `[abc]` : Correspond à l'un des caractères spécifiés

#### Identification d'adaptateurs spécifiques

##### 🔌 Adaptateurs Ethernet

```powershell
# Par nom
Get-NetAdapter -Name "Ethernet*"

# Par type de média
Get-NetAdapter | Where-Object MediaType -eq "802.3"

# Par description
Get-NetAdapter | Where-Object InterfaceDescription -like "*Ethernet*"
```

##### 📡 Adaptateurs Wi-Fi

```powershell
# Par nom courant
Get-NetAdapter -Name "*Wi-Fi*"

# Par type de média
Get-NetAdapter | Where-Object MediaType -eq "Native 802.11"

# Par description courante
Get-NetAdapter | Where-Object InterfaceDescription -like "*Wireless*"
```

##### 💻 Adaptateurs virtuels

```powershell
# Adaptateurs Hyper-V
Get-NetAdapter -Name "vEthernet*"

# Tous les adaptateurs non-physiques
Get-NetAdapter | Where-Object { -not $_.Physical }

# Adaptateurs VPN (exemple)
Get-NetAdapter | Where-Object InterfaceDescription -like "*VPN*"
```

##### 🔵 Adaptateurs Bluetooth

```powershell
# Par description
Get-NetAdapter | Where-Object InterfaceDescription -like "*Bluetooth*"

# Par nom de connexion réseau
Get-NetAdapter -Name "*Bluetooth*"
```

> [!example] Exemple pratique : Inventaire complet
> 
> ```powershell
> # Script d'inventaire des adaptateurs par type
> Write-Host "`n=== INVENTAIRE DES ADAPTATEURS RÉSEAU ===" -ForegroundColor Green
> 
> Write-Host "`nAdaptateurs Ethernet:" -ForegroundColor Cyan
> Get-NetAdapter | Where-Object MediaType -eq "802.3" | Select-Object Name, Status, LinkSpeed
> 
> Write-Host "`nAdaptateurs Wi-Fi:" -ForegroundColor Cyan
> Get-NetAdapter | Where-Object MediaType -eq "Native 802.11" | Select-Object Name, Status, LinkSpeed
> 
> Write-Host "`nAdaptateurs Virtuels:" -ForegroundColor Cyan
> Get-NetAdapter | Where-Object { -not $_.Physical } | Select-Object Name, InterfaceDescription
> ```

---

### Statistiques d'interface

La cmdlet `Get-NetAdapterStatistics` fournit des statistiques détaillées sur l'utilisation de chaque adaptateur réseau.

#### Syntaxe et utilisation

```powershell
# Statistiques de tous les adaptateurs
Get-NetAdapterStatistics

# Statistiques d'un adaptateur spécifique
Get-NetAdapterStatistics -Name "Ethernet"

# Combinaison avec Get-NetAdapter
Get-NetAdapter -Name "Ethernet" | Get-NetAdapterStatistics
```

#### Propriétés des statistiques

```powershell
# Afficher toutes les statistiques
Get-NetAdapterStatistics -Name "Ethernet" | Format-List *

# Sélection des métriques importantes
Get-NetAdapterStatistics | Select-Object Name,
    @{N='Reçus (MB)';E={[math]::Round($_.ReceivedBytes/1MB,2)}},
    @{N='Envoyés (MB)';E={[math]::Round($_.SentBytes/1MB,2)}},
    ReceivedUnicastPackets,
    SentUnicastPackets,
    ReceivedDiscardedPackets,
    OutboundDiscardedPackets
```

Statistiques principales :

|Propriété|Description|
|---|---|
|**ReceivedBytes**|Octets totaux reçus|
|**SentBytes**|Octets totaux envoyés|
|**ReceivedUnicastPackets**|Paquets unicast reçus|
|**SentUnicastPackets**|Paquets unicast envoyés|
|**ReceivedDiscardedPackets**|Paquets reçus rejetés|
|**OutboundDiscardedPackets**|Paquets sortants rejetés|
|**ReceivedPacketErrors**|Erreurs de réception|
|**OutboundPacketErrors**|Erreurs d'envoi|

> [!example] Exemple : Monitoring du trafic réseau
> 
> ```powershell
> # Fonction pour afficher le trafic en temps réel
> function Watch-NetworkTraffic {
>     param([string]$AdapterName = "Ethernet")
>     
>     $stats1 = Get-NetAdapterStatistics -Name $AdapterName
>     Start-Sleep -Seconds 1
>     $stats2 = Get-NetAdapterStatistics -Name $AdapterName
>     
>     $receivedRate = ($stats2.ReceivedBytes - $stats1.ReceivedBytes)
>     $sentRate = ($stats2.SentBytes - $stats1.SentBytes)
>     
>     [PSCustomObject]@{
>         Adaptateur = $AdapterName
>         'Réception (KB/s)' = [math]::Round($receivedRate/1KB, 2)
>         'Envoi (KB/s)' = [math]::Round($sentRate/1KB, 2)
>     }
> }
> 
> # Utilisation
> Watch-NetworkTraffic -AdapterName "Ethernet"
> ```

> [!tip] Diagnostic de problèmes Les compteurs **ReceivedDiscardedPackets** et **ReceivedPacketErrors** sont essentiels pour identifier des problèmes matériels ou de configuration. Un nombre élevé peut indiquer :
> 
> - Câble défectueux
> - Conflit de vitesse/duplex
> - Pilote obsolète
> - Surcharge du système

---

## Set-NetAdapter - Modification de configuration

La cmdlet `Set-NetAdapter` permet de modifier la configuration des adaptateurs réseau. Elle nécessite des privilèges administrateur et peut affecter la connectivité réseau.

> [!warning] Droits administrateur requis Toutes les opérations avec `Set-NetAdapter` nécessitent une exécution de PowerShell en tant qu'administrateur. Sans quoi, vous recevrez une erreur d'accès refusé.

### Syntaxe de base

```powershell
# Syntaxe générale
Set-NetAdapter -Name "NomAdaptateur" -ParametreAModifier ValeurNouvelle

# Identification de l'adaptateur cible
Set-NetAdapter -Name "Ethernet" -MacAddress "00-11-22-33-44-55"

# Via pipeline
Get-NetAdapter -Name "Ethernet" | Set-NetAdapter -MacAddress "00-11-22-33-44-55"
```

---

### Paramètres modifiables

#### Modification de l'adresse MAC

Certains adaptateurs réseau permettent de modifier leur adresse MAC via logiciel (MAC address spoofing).

```powershell
# Changer l'adresse MAC (si supporté par le matériel)
Set-NetAdapter -Name "Ethernet" -MacAddress "00-11-22-33-44-55"

# Vérifier le changement
Get-NetAdapter -Name "Ethernet" | Select-Object Name, MacAddress
```

> [!warning] Support matériel variable Tous les adaptateurs ne supportent pas la modification de l'adresse MAC. Si le matériel ne le permet pas, vous recevrez une erreur. Les adaptateurs virtuels supportent généralement cette fonctionnalité.

> [!info] Format d'adresse MAC L'adresse MAC doit être spécifiée au format `XX-XX-XX-XX-XX-XX` ou `XX:XX:XX:XX:XX:XX` où chaque X est un chiffre hexadécimal (0-9, A-F).

#### Renommage d'adaptateur

Pour renommer un adaptateur, utilisez la cmdlet dédiée `Rename-NetAdapter`.

```powershell
# Renommer un adaptateur
Rename-NetAdapter -Name "Ethernet" -NewName "LAN-Principal"

# Avec confirmation
Rename-NetAdapter -Name "Wi-Fi" -NewName "WLAN-Bureau" -Confirm

# Via pipeline
Get-NetAdapter -Name "Ethernet 2" | Rename-NetAdapter -NewName "LAN-Secondaire"
```

> [!tip] Convention de nommage Utilisez des noms descriptifs et cohérents pour faciliter l'administration :
> 
> - `LAN-Principal`, `LAN-Backup` pour plusieurs connexions filaires
> - `WLAN-Bureau`, `WLAN-Invites` pour plusieurs Wi-Fi
> - `VPN-Entreprise` pour des connexions VPN

---

### Opérations de gestion

#### Activation d'un adaptateur

```powershell
# Activer un adaptateur désactivé
Enable-NetAdapter -Name "Ethernet"

# Activation avec confirmation
Enable-NetAdapter -Name "Wi-Fi" -Confirm

# Activer tous les adaptateurs désactivés
Get-NetAdapter | Where-Object Status -eq "Disabled" | Enable-NetAdapter
```

> [!example] Exemple : Réactivation après maintenance
> 
> ```powershell
> # Script de réactivation post-maintenance
> $adapter = "Ethernet"
> 
> Write-Host "Activation de l'adaptateur $adapter..." -ForegroundColor Yellow
> Enable-NetAdapter -Name $adapter -Confirm:$false
> 
> # Attendre que l'adaptateur soit complètement actif
> Start-Sleep -Seconds 3
> 
> # Vérifier l'état
> $status = (Get-NetAdapter -Name $adapter).Status
> if ($status -eq "Up") {
>     Write-Host "Adaptateur $adapter activé avec succès !" -ForegroundColor Green
> } else {
>     Write-Host "Adaptateur $adapter est actif mais statut: $status" -ForegroundColor Yellow
> }
> ```

#### Désactivation d'un adaptateur

```powershell
# Désactiver un adaptateur
Disable-NetAdapter -Name "Ethernet"

# Désactivation avec confirmation (recommandé)
Disable-NetAdapter -Name "Wi-Fi" -Confirm

# Désactiver tous les adaptateurs Wi-Fi
Get-NetAdapter -Name "*Wi-Fi*" | Disable-NetAdapter
```

> [!warning] Impact sur la connectivité La désactivation d'un adaptateur réseau coupe immédiatement toute connectivité associée. Si vous gérez un système à distance, **ne désactivez jamais l'adaptateur que vous utilisez pour la connexion** sous peine de perdre l'accès.

#### Confirmation recommandée

Le paramètre `-Confirm` est fortement recommandé pour éviter les modifications accidentelles.

```powershell
# Demande de confirmation avant désactivation
Disable-NetAdapter -Name "Ethernet" -Confirm

# Suppression de la confirmation (dangereux)
Disable-NetAdapter -Name "Ethernet" -Confirm:$false

# Configuration globale de confirmation
$ConfirmPreference = "High"  # Demande confirmation pour actions à haut risque
```

> [!tip] Bonne pratique Pour les scripts automatisés en environnement de production, utilisez `-Confirm:$false` uniquement après avoir testé le script en environnement de développement avec `-Confirm` ou `-WhatIf`.

#### Redémarrage d'un adaptateur

Le redémarrage d'un adaptateur peut résoudre certains problèmes de connectivité sans nécessiter un redémarrage complet du système.

```powershell
# Redémarrer un adaptateur
Restart-NetAdapter -Name "Ethernet"

# Avec confirmation
Restart-NetAdapter -Name "Wi-Fi" -Confirm

# Via pipeline
Get-NetAdapter -Name "Ethernet" | Restart-NetAdapter
```

> [!info] Qu'est-ce qu'un redémarrage d'adaptateur ? Le redémarrage effectue une désactivation suivie d'une réactivation de l'adaptateur. C'est l'équivalent de :
> 
> ```powershell
> Disable-NetAdapter -Name "Ethernet" -Confirm:$false
> Start-Sleep -Seconds 2
> Enable-NetAdapter -Name "Ethernet" -Confirm:$false
> ```

> [!example] Exemple : Redémarrage avec diagnostic
> 
> ```powershell
> function Restart-AdapterWithDiag {
>     param([string]$AdapterName)
>     
>     # État avant
>     Write-Host "`nÉtat avant redémarrage:" -ForegroundColor Cyan
>     Get-NetAdapter -Name $AdapterName | Select-Object Name, Status, LinkSpeed
>     
>     # Redémarrage
>     Write-Host "`nRedémarrage de $AdapterName..." -ForegroundColor Yellow
>     Restart-NetAdapter -Name $AdapterName -Confirm:$false
>     
>     # Attente de stabilisation
>     Start-Sleep -Seconds 5
>     
>     # État après
>     Write-Host "`nÉtat après redémarrage:" -ForegroundColor Cyan
>     Get-NetAdapter -Name $AdapterName | Select-Object Name, Status, LinkSpeed
> }
> 
> # Utilisation
> Restart-AdapterWithDiag -AdapterName "Ethernet"
> ```

---

### Considérations importantes

#### Impact sur la connectivité

Toute modification d'un adaptateur réseau peut temporairement ou définitivement affecter la connectivité.

> [!warning] Précautions critiques
> 
> - **Gestion à distance** : Ne jamais modifier l'adaptateur utilisé pour la connexion active
> - **Serveurs de production** : Planifier les modifications en fenêtre de maintenance
> - **Sauvegarde** : Noter la configuration actuelle avant toute modification
> - **Rollback** : Avoir un plan de restauration en cas de problème

```powershell
# Identifier l'adaptateur de connexion actif (pour éviter de le modifier)
Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object Name, InterfaceDescription

# Sauvegarder la configuration actuelle
$backup = Get-NetAdapter -Name "Ethernet" | Select-Object *
$backup | Export-Clixml -Path "C:\Backup\NetAdapter_Ethernet_$(Get-Date -Format 'yyyyMMdd_HHmmss').xml"
```

#### Tests après modification

Après toute modification d'adaptateur, effectuez des tests de connectivité.

```powershell
# Test de connectivité basique
Test-Connection -ComputerName 8.8.8.8 -Count 4

# Test de résolution DNS
Resolve-DnsName www.google.com

# Vérification de l'état de l'adaptateur
Get-NetAdapter -Name "Ethernet" | Select-Object Name, Status, LinkSpeed, MediaConnectionState

# Test de la passerelle par défaut
$gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0").NextHop
Test-Connection -ComputerName $gateway -Count 2
```

> [!example] Script de validation post-modification
> 
> ```powershell
> function Test-NetworkConnectivity {
>     param([string]$AdapterName = "Ethernet")
>     
>     Write-Host "`n=== VALIDATION RÉSEAU ===" -ForegroundColor Green
>     
>     # 1. État de l'adaptateur
>     Write-Host "`n1. État de l'adaptateur:" -ForegroundColor Cyan
>     $adapter = Get-NetAdapter -Name $AdapterName
>     $adapter | Select-Object Name, Status, LinkSpeed | Format-Table
>     
>     # 2. Test de la passerelle
>     Write-Host "2. Test de la passerelle par défaut:" -ForegroundColor Cyan
>     $gateway = (Get-NetRoute -InterfaceAlias $AdapterName -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue).NextHop
>     if ($gateway) {
>         Test-Connection -ComputerName $gateway -Count 2 -Quiet
>     } else {
>         Write-Host "Aucune passerelle configurée" -ForegroundColor Yellow
>     }
>     
>     # 3. Test DNS
>     Write-Host "3. Test de résolution DNS:" -ForegroundColor Cyan
>     try {
>         Resolve-DnsName www.google.com -ErrorAction Stop | Out-Null
>         Write-Host "Résolution DNS : OK" -ForegroundColor Green
>     } catch {
>         Write-Host "Résolution DNS : ÉCHEC" -ForegroundColor Red
>     }
>     
>     # 4. Test Internet
>     Write-Host "4. Test de connectivité Internet:" -ForegroundColor Cyan
>     if (Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet) {
>         Write-Host "Connectivité Internet : OK" -ForegroundColor Green
>     } else {
>         Write-Host "Connectivité Internet : ÉCHEC" -ForegroundColor Red
>     }
> }
> 
> # Utilisation après modification
> Test-NetworkConnectivity -AdapterName "Ethernet"
> ```

#### Gestion des erreurs courantes

```powershell
# Exemple de gestion d'erreurs robuste
try {
    # Tentative de modification
    Set-NetAdapter -Name "Ethernet" -MacAddress "00-11-22-33-44-55" -ErrorAction Stop
    Write-Host "Modification réussie" -ForegroundColor Green
}
catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] {
    Write-Host "Erreur : L'adaptateur ne supporte pas cette modification" -ForegroundColor Red
}
catch [System.UnauthorizedAccessException] {
    Write-Host "Erreur : Privilèges administrateur requis" -ForegroundColor Red
}
catch {
    Write-Host "Erreur inattendue : $($_.Exception.Message)" -ForegroundColor Red
}
```

> [!tip] Piège courant : Noms d'adaptateurs Les noms d'adaptateurs sont sensibles à la casse et aux espaces. Utilisez toujours `Get-NetAdapter` pour confirmer le nom exact avant de le référencer dans des commandes de modification.
> 
> ```powershell
> # Mauvais (pourrait échouer)
> Set-NetAdapter -Name "ethernet" ...
> 
> # Bon (nom exact)
> Set-NetAdapter -Name "Ethernet" ...
> 
> # Meilleur (validation)
> $name = (Get-NetAdapter | Where-Object InterfaceDescription -like "*Intel*").Name
> Set-NetAdapter -Name $name ...
> ```

---

## 🎯 Points clés à retenir

> [!info] Résumé essentiel
> 
> - **Get-NetAdapter** est votre outil principal pour consulter l'état des adaptateurs réseau
> - Les propriétés Status, LinkSpeed, et MacAddress sont les plus utilisées au quotidien
> - **Get-NetAdapterStatistics** fournit des métriques essentielles pour le diagnostic et le monitoring
> - **Set-NetAdapter** requiert des privilèges administrateur et peut impacter la connectivité
> - Utilisez toujours `-Confirm` lors de modifications importantes
> - Testez systématiquement la connectivité après toute modification
> - Le filtrage avec `-Physical` et les wildcards permet de cibler précisément les adaptateurs

> [!warning] Sécurité et prudence
> 
> - Ne jamais modifier l'adaptateur utilisé pour la connexion active à distance
> - Sauvegarder la configuration avant toute modification majeure
> - Tester les scripts en environnement de développement avant la production
> - Planifier les modifications en fenêtre de maintenance pour les systèmes critiques