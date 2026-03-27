

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

## 🎯 Introduction à la configuration réseau {#introduction}

La configuration réseau sous Windows peut se faire de deux manières principales :

- **Manuellement** via l'interface graphique ou les lignes de commande
- **Automatiquement** via un serveur DHCP

> [!info] Pourquoi configurer manuellement ?
> 
> - **Serveurs** : nécessitent une IP fixe pour être accessibles de manière constante
> - **Équipements réseau** : routeurs, switchs, imprimantes partagées
> - **Dépannage** : isoler des problèmes réseau
> - **Environnements sans DHCP** : réseaux isolés ou sécurisés

---

## 🔧 Configuration IP statique {#config-ip-statique}

### IPv4 statique {#ipv4-statique}

#### Via l'interface graphique

**Chemin d'accès** :

1. Panneau de configuration → Réseau et Internet → Centre Réseau et partage
2. Clic sur votre connexion → Propriétés
3. Sélectionner "Protocole Internet version 4 (TCP/IPv4)" → Propriétés

**Paramètres à configurer** :

|Paramètre|Description|Exemple|
|---|---|---|
|**Adresse IP**|Identifiant unique sur le réseau|192.168.1.100|
|**Masque de sous-réseau**|Définit la taille du réseau|255.255.255.0|
|**Passerelle par défaut**|Routeur vers l'extérieur|192.168.1.1|
|**DNS préféré**|Serveur de résolution de noms|8.8.8.8|
|**DNS auxiliaire**|Serveur DNS de secours|8.8.4.4|

> [!example] Exemple de configuration typique
> 
> ```
> Adresse IP : 192.168.1.50
> Masque : 255.255.255.0
> Passerelle : 192.168.1.1
> DNS préféré : 192.168.1.1 (routeur local)
> DNS auxiliaire : 8.8.8.8 (Google)
> ```

#### Via PowerShell/CMD (netsh)

**Syntaxe de base** :

```bash
# Afficher les interfaces réseau
netsh interface ipv4 show interfaces

# Configuration complète d'une interface
netsh interface ipv4 set address name="Ethernet" static 192.168.1.100 255.255.255.0 192.168.1.1

# Ajouter un serveur DNS
netsh interface ipv4 set dns name="Ethernet" static 8.8.8.8
netsh interface ipv4 add dns name="Ethernet" 8.8.4.4 index=2
```

**Décomposition de la commande** :

```bash
netsh interface ipv4 set address name="NOM_INTERFACE" static [ADRESSE_IP] [MASQUE] [PASSERELLE]
```

- `name="Ethernet"` : nom de l'interface (utiliser guillemets si espaces)
- `static` : indique une configuration manuelle
- `[ADRESSE_IP]` : l'IP à attribuer
- `[MASQUE]` : le masque de sous-réseau
- `[PASSERELLE]` : l'IP du routeur

> [!tip] Astuce : trouver le nom exact de votre interface
> 
> ```bash
> netsh interface show interface
> # ou
> ipconfig /all
> ```

#### Via PowerShell (cmdlets natifs)

**Méthode moderne recommandée** :

```powershell
# Lister les interfaces
Get-NetAdapter

# Configuration IP statique
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.100 -PrefixLength 24 -DefaultGateway 192.168.1.1

# Configuration DNS
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("8.8.8.8","8.8.4.4")
```

> [!info] Notation CIDR `-PrefixLength 24` équivaut à un masque `255.255.255.0`
> 
> - /24 = 255.255.255.0
> - /16 = 255.255.0.0
> - /8 = 255.0.0.0

---

### IPv6 statique {#ipv6-statique}

#### Pourquoi IPv6 ?

IPv6 résout la pénurie d'adresses IPv4 et apporte des améliorations :

- Espace d'adressage quasi-infini (128 bits vs 32 bits)
- Configuration automatique (SLAAC)
- Sécurité intégrée (IPsec obligatoire)
- Pas de NAT nécessaire

> [!warning] Coexistence IPv4/IPv6 La plupart des réseaux utilisent le **dual-stack** (IPv4 et IPv6 simultanément). Ne désactivez pas IPv6 sauf nécessité absolue.

#### Via l'interface graphique

**Chemin identique à IPv4** :

1. Propriétés de la connexion
2. Sélectionner "Protocole Internet version 6 (TCP/IPv6)"

**Paramètres IPv6** :

|Paramètre|Description|Exemple|
|---|---|---|
|**Adresse IPv6**|Identifiant 128 bits|2001:db8:85a3::8a2e:370:7334|
|**Longueur du préfixe**|Équivalent du masque|64|
|**Passerelle par défaut**|Routeur IPv6|fe80::1|
|**DNS préféré**|Serveur DNS IPv6|2001:4860:4860::8888|

#### Via netsh

```bash
# Configuration IPv6 statique
netsh interface ipv6 set address "Ethernet" 2001:db8:1::100/64

# Ajouter une passerelle par défaut
netsh interface ipv6 add route ::/0 "Ethernet" fe80::1

# Configuration DNS IPv6
netsh interface ipv6 set dns "Ethernet" static 2001:4860:4860::8888
netsh interface ipv6 add dns "Ethernet" 2001:4860:4860::8844 index=2
```

#### Via PowerShell

```powershell
# Configuration IPv6
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "2001:db8:1::100" -PrefixLength 64 -DefaultGateway "fe80::1"

# DNS IPv6
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("2001:4860:4860::8888","2001:4860:4860::8844")
```

> [!example] Exemple d'adresses IPv6 courantes
> 
> ```
> Adresse link-local : fe80::1234:5678:90ab:cdef/64 (auto-générée)
> Adresse globale : 2001:db8:1::100/64 (routée sur Internet)
> Loopback : ::1 (équivalent de 127.0.0.1)
> ```

---

## 🔄 Configuration via DHCP {#config-dhcp}

### Principe du DHCP

DHCP (Dynamic Host Configuration Protocol) attribue automatiquement :

- Une adresse IP
- Un masque de sous-réseau
- Une passerelle par défaut
- Des serveurs DNS
- D'autres paramètres (domaine, serveur NTP, etc.)

> [!info] Processus DHCP en 4 étapes (DORA)
> 
> 1. **Discover** : le client cherche un serveur DHCP
> 2. **Offer** : le serveur propose une configuration
> 3. **Request** : le client demande cette configuration
> 4. **Acknowledge** : le serveur confirme l'attribution

### Activation du DHCP

#### Via l'interface graphique

1. Propriétés de la connexion → TCP/IPv4
2. Sélectionner "Obtenir une adresse IP automatiquement"
3. Sélectionner "Obtenir les adresses des serveurs DNS automatiquement"

#### Via netsh

```bash
# Activer DHCP pour IPv4
netsh interface ipv4 set address name="Ethernet" dhcp

# Activer DHCP pour DNS
netsh interface ipv4 set dns name="Ethernet" dhcp

# Activer DHCP pour IPv6
netsh interface ipv6 set address "Ethernet" dhcp
netsh interface ipv6 set dns "Ethernet" dhcp
```

#### Via PowerShell

```powershell
# Passer en DHCP pour IPv4
Set-NetIPInterface -InterfaceAlias "Ethernet" -Dhcp Enabled

# Passer en DHCP pour DNS
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
```

### Gestion du bail DHCP

```bash
# Libérer l'adresse IP actuelle
ipconfig /release

# Renouveler le bail DHCP
ipconfig /renew

# Afficher les détails du bail
ipconfig /all
```

> [!tip] Astuce : renouvellement rapide Utilisez `ipconfig /release && ipconfig /renew` pour forcer un renouvellement complet en une seule commande.

---

## 💻 Commandes réseau essentielles {#commandes-reseau}

### ipconfig {#ipconfig}

**Commande de base pour afficher et gérer la configuration réseau**

#### Syntaxe et options principales

```bash
# Affichage simple
ipconfig

# Affichage détaillé
ipconfig /all

# Libérer l'adresse IP
ipconfig /release [interface]

# Renouveler l'adresse IP
ipconfig /renew [interface]

# Vider le cache DNS
ipconfig /flushdns

# Afficher le cache DNS
ipconfig /displaydns

# Enregistrer le nom de la machine dans le DNS
ipconfig /registerdns
```

#### Interprétation de la sortie

**Sortie typique d'un `ipconfig /all`** :

```
Carte Ethernet Ethernet :

   Suffixe DNS propre à la connexion. . . : mondomaine.local
   Description. . . . . . . . . . . . . . : Intel(R) Ethernet Connection
   Adresse physique . . . . . . . . . . . : 00-1A-2B-3C-4D-5E
   DHCP activé. . . . . . . . . . . . . . : Oui
   Configuration automatique activée. . . : Oui
   Adresse IPv4. . . . . . . . . . . . . .: 192.168.1.100(préféré)
   Masque de sous-réseau. . . . . . . . . : 255.255.255.0
   Bail obtenu. . . . . . . . . . . . . . : mercredi 11 décembre 2024 10:30:00
   Bail expirant. . . . . . . . . . . . . : jeudi 12 décembre 2024 10:30:00
   Passerelle par défaut. . . . . . . . . : 192.168.1.1
   Serveur DHCP . . . . . . . . . . . . . : 192.168.1.1
   Serveurs DNS. . .  . . . . . . . . . . : 192.168.1.1
```

**Éléments clés à vérifier** :

|Élément|Signification|Importance|
|---|---|---|
|**Adresse physique**|Adresse MAC de la carte|Identification unique|
|**DHCP activé**|Mode d'attribution IP|Diagnostique la config|
|**Adresse IPv4**|IP actuelle de la machine|Connectivité réseau|
|**Passerelle par défaut**|Routeur vers Internet|Accès externe|
|**Serveurs DNS**|Résolution des noms|Navigation web|

> [!warning] Adresses APIPA (169.254.x.x) Si vous voyez une adresse commençant par 169.254, cela signifie :
> 
> - Le client n'a pas trouvé de serveur DHCP
> - Configuration automatique privée activée
> - **Pas d'accès Internet possible**

---

### netsh {#netsh}

**Outil puissant pour configurer tous les aspects réseau en ligne de commande**

#### Structure de netsh

```bash
netsh [contexte] [sous-contexte] [commande] [paramètres]
```

**Contextes principaux** :

- `interface` : configuration des interfaces réseau
- `wlan` : configuration Wi-Fi
- `firewall` : pare-feu Windows
- `advfirewall` : pare-feu avancé

#### Commandes interface IPv4

```bash
# Lister toutes les interfaces
netsh interface ipv4 show interfaces

# Afficher la configuration d'une interface
netsh interface ipv4 show config name="Ethernet"

# Afficher les adresses IP
netsh interface ipv4 show addresses

# Afficher la table de routage
netsh interface ipv4 show route

# Afficher les DNS configurés
netsh interface ipv4 show dnsservers
```

#### Configuration avancée

**Ajouter une adresse IP secondaire** :

```bash
# Ajouter une IP supplémentaire sur la même interface
netsh interface ipv4 add address "Ethernet" 192.168.1.101 255.255.255.0
```

**Modifier la métrique d'interface** :

```bash
# Définir la priorité de l'interface (plus faible = prioritaire)
netsh interface ipv4 set interface "Ethernet" metric=10
```

**Configuration de routes statiques** :

```bash
# Ajouter une route statique
netsh interface ipv4 add route 10.0.0.0/8 "Ethernet" 192.168.1.254

# Supprimer une route
netsh interface ipv4 delete route 10.0.0.0/8 "Ethernet"
```

#### Commandes interface IPv6

```bash
# Afficher la configuration IPv6
netsh interface ipv6 show config

# Afficher les adresses IPv6
netsh interface ipv6 show addresses

# Afficher les voisins IPv6 (équivalent ARP)
netsh interface ipv6 show neighbors

# Désactiver/activer IPv6 sur une interface
netsh interface ipv6 set interface "Ethernet" disable
netsh interface ipv6 set interface "Ethernet" enable
```

#### Gestion des profils réseau

**Exporter une configuration** :

```bash
# Exporter la configuration complète
netsh -c interface dump > C:\config_reseau.txt

# Restaurer depuis un fichier
netsh -f C:\config_reseau.txt
```

> [!tip] Sauvegarde avant modifications Exportez toujours votre configuration avant des changements importants :
> 
> ```bash
> netsh -c interface dump > backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%.txt
> ```

#### Réinitialisation réseau complète

```bash
# Réinitialiser Winsock (pile réseau)
netsh winsock reset

# Réinitialiser TCP/IP IPv4
netsh int ipv4 reset

# Réinitialiser TCP/IP IPv6
netsh int ipv6 reset

# Réinitialiser le pare-feu
netsh advfirewall reset
```

> [!warning] Redémarrage nécessaire Après ces commandes de réinitialisation, un redémarrage est généralement requis pour une prise en compte complète.

#### Mode interactif

```bash
# Entrer dans netsh en mode interactif
netsh

# Navigation dans les contextes
netsh> interface
netsh interface> ipv4
netsh interface ipv4> show config

# Quitter
netsh interface ipv4> exit
```

---

## 📁 Fichiers de configuration {#fichiers-config}

### Fichier hosts

**Emplacement** : `C:\Windows\System32\drivers\etc\hosts`

**Rôle** : Résolution de noms statique avant interrogation DNS

#### Structure du fichier

```bash
# Format : ADRESSE_IP    NOM_HOTE    [ALIAS]

# Loopback
127.0.0.1       localhost
::1             localhost

# Entrées personnalisées
192.168.1.50    serveur-web.local    web
192.168.1.51    serveur-db.local     database
10.0.0.100      printer.office

# Bloquer des sites (redirige vers localhost)
127.0.0.1       site-malveillant.com
127.0.0.1       publicite-invasive.net
```

> [!info] Priorité de résolution
> 
> 1. **Cache DNS** (en mémoire)
> 2. **Fichier hosts** (statique)
> 3. **Serveurs DNS** (dynamique)

**Cas d'usage** :

- Développement web (pointer un domaine vers un serveur local)
- Test de configuration avant modification DNS réelle
- Blocage de sites (publicités, malwares)
- Environnements sans DNS

> [!tip] Édition du fichier hosts
> 
> - Nécessite des **privilèges administrateur**
> - Utilisez `notepad` en tant qu'admin :
> 
> ```bash
> notepad C:\Windows\System32\drivers\etc\hosts
> ```
> 
> - Après modification, videz le cache DNS :
> 
> ```bash
> ipconfig /flushdns
> ```

---

### Registre Windows (configuration avancée)

**Emplacement** : `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{GUID}`

> [!warning] Manipulation du registre La modification directe du registre est risquée. Préférez netsh ou PowerShell. Créez toujours une sauvegarde avant modification.

#### Clés importantes

```
EnableDHCP              : 1 = DHCP activé, 0 = IP statique
IPAddress               : Adresse(s) IP configurée(s)
SubnetMask              : Masque(s) de sous-réseau
DefaultGateway          : Passerelle(s) par défaut
NameServer              : Serveurs DNS (séparés par des virgules)
DhcpIPAddress           : IP obtenue par DHCP
DhcpServer              : Adresse du serveur DHCP
Lease                   : Début du bail DHCP
LeaseTerminatesTime     : Fin du bail DHCP
```

#### Accéder à la configuration d'une interface

```powershell
# Lister les GUID des interfaces
Get-NetAdapter | Select-Object Name, InterfaceGuid

# Ouvrir le registre à cet emplacement
regedit
# Puis naviguer vers : HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{GUID}
```

---

### Fichiers de log réseau

**Logs DHCP (si serveur local)** : `C:\Windows\System32\DHCP\`

**Logs événements Windows** :

- Observateur d'événements → Journaux Windows → Système
- Filtrer sur la source "Tcpip" ou "DHCPClient"

```powershell
# Afficher les événements réseau récents
Get-EventLog -LogName System -Source "Tcpip" -Newest 50

# Événements DHCP
Get-EventLog -LogName System -Source "DHCPClient" -Newest 20
```

---

## ⚠️ Pièges courants et bonnes pratiques {#pieges-bonnes-pratiques}

### Pièges courants

> [!warning] Erreur 1 : Conflit d'adresses IP **Symptôme** : Message "Conflit d'adresse IP détecté"
> 
> **Causes** :
> 
> - Même IP attribuée à deux machines
> - IP statique dans la plage DHCP
> 
> **Solution** :
> 
> - Utiliser des plages IP statiques hors DHCP
> - Vérifier avec `arp -a` les adresses utilisées

> [!warning] Erreur 2 : Passerelle incorrecte **Symptôme** : Pas d'accès Internet mais réseau local OK
> 
> **Diagnostic** :
> 
> ```bash
> ping 192.168.1.1  # Passerelle - doit répondre
> ping 8.8.8.8      # Internet par IP - teste la passerelle
> ping google.com   # Par nom - teste DNS
> ```

> [!warning] Erreur 3 : DNS non fonctionnels **Symptôme** : Ping par IP fonctionne mais pas par nom
> 
> **Solution** :
> 
> ```bash
> # Tester la résolution DNS
> nslookup google.com
> 
> # Changer temporairement de DNS
> netsh interface ipv4 set dns "Ethernet" static 8.8.8.8
> ```

> [!warning] Erreur 4 : Mauvais masque de sous-réseau **Symptôme** : Certaines machines du réseau injoignables
> 
> **Explication** : Un masque /24 (255.255.255.0) sur un réseau /16 (255.255.0.0) limite la communication
> 
> **Vérification** :
> 
> - Assurez-vous que toutes les machines ont le même masque
> - Le masque doit correspondre à la taille du réseau

### Bonnes pratiques

> [!tip] 1. Documentation de la configuration
> 
> - Conservez un fichier texte avec toutes vos configurations IP
> - Notez les modifications apportées et leur date
> - Exportez régulièrement avec `netsh -c interface dump`

> [!tip] 2. Organisation des adresses IP
> 
> ```
> Exemple de plan d'adressage :
> 
> 192.168.1.1       - Routeur
> 192.168.1.2-49    - DHCP (48 adresses)
> 192.168.1.50-99   - Serveurs (IP fixes)
> 192.168.1.100-199 - Postes de travail fixes
> 192.168.1.200-254 - Réservé / Invités
> ```

> [!tip] 3. Tests systématiques après configuration
> 
> ```bash
> # 1. Tester la configuration locale
> ipconfig /all
> 
> # 2. Tester la passerelle
> ping 192.168.1.1
> 
> # 3. Tester un serveur externe par IP
> ping 8.8.8.8
> 
> # 4. Tester la résolution DNS
> ping google.com
> 
> # 5. Tester la connectivité web
> # Ouvrir un navigateur
> ```

> [!tip] 4. Sécurité
> 
> - Ne publiez jamais votre IP publique
> - Utilisez des plages privées (RFC 1918) :
>     - 10.0.0.0/8 (10.0.0.0 à 10.255.255.255)
>     - 172.16.0.0/12 (172.16.0.0 à 172.31.255.255)
>     - 192.168.0.0/16 (192.168.0.0 à 192.168.255.255)
> - Limitez l'accès au fichier hosts (privilèges admin)

> [!tip] 5. Performance
> 
> - Configurez plusieurs serveurs DNS (primaire et secondaire)
> - Utilisez des DNS rapides (Google 8.8.8.8, Cloudflare 1.1.1.1)
> - Ajustez les métriques d'interface si plusieurs connexions

> [!tip] 6. Scripts d'automatisation
> 
> ```powershell
> # Créer un script de basculement rapide
> # Fichier : switch_to_dhcp.ps1
> Set-NetIPInterface -InterfaceAlias "Ethernet" -Dhcp Enabled
> Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
> ipconfig /renew
> 
> # Fichier : switch_to_static.ps1
> New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.100 `
>     -PrefixLength 24 -DefaultGateway 192.168.1.1
> Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
>     -ServerAddresses ("192.168.1.1","8.8.8.8")
> ```

---

## 🎯 Résumé des commandes essentielles

```bash
# === VISUALISATION ===
ipconfig                              # Configuration basique
ipconfig /all                         # Configuration détaillée
netsh interface ipv4 show config      # Config IPv4 complète

# === CONFIGURATION STATIQUE ===
netsh interface ipv4 set address name="Ethernet" static 192.168.1.100 255.255.255.0 192.168.1.1
netsh interface ipv4 set dns name="Ethernet" static 8.8.8.8

# === BASCULER EN DHCP ===
netsh interface ipv4 set address name="Ethernet" dhcp
netsh interface ipv4 set dns name="Ethernet" dhcp

# === GESTION DHCP ===
ipconfig /release                     # Libérer le bail
ipconfig /renew                       # Renouveler le bail

# === DÉPANNAGE ===
ipconfig /flushdns                    # Vider cache DNS
netsh winsock reset                   # Réinitialiser la pile réseau
netsh int ip reset                    # Réinitialiser TCP/IP

# === SAUVEGARDE ===
netsh -c interface dump > backup.txt  # Sauvegarder config
netsh -f backup.txt                   # Restaurer config
```

---

**📌 Points clés à retenir :**

- La configuration peut être **graphique**, **netsh** ou **PowerShell**
- IP statique pour serveurs/équipements, DHCP pour clients
- Toujours tester après modification : ping gateway → ping 8.8.8.8 → ping google.com
- Fichier hosts permet résolution locale avant DNS
- Sauvegarder la config avant toute modification importante