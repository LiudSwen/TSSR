

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

## 🔧 SLAAC (Stateless Address Autoconfiguration)

### 📖 Définition et principe

SLAAC est un mécanisme d'**auto-configuration stateless** (sans état) permettant aux hôtes IPv6 de générer automatiquement leurs adresses IPv6 sans serveur DHCP. Le routeur annonce simplement le préfixe réseau, et chaque hôte construit son adresse complète.

> [!info] Pourquoi SLAAC ?
> 
> - **Simplicité** : Pas besoin de serveur DHCP
> - **Décentralisation** : Chaque hôte gère sa propre adresse
> - **Plug-and-play** : Configuration automatique au démarrage

### 🔄 Processus SLAAC

1. **Génération de l'adresse link-local** (fe80::/10)
    - L'interface utilise son adresse MAC pour créer l'identifiant d'interface (EUI-64 ou aléatoire)
2. **Écoute des Router Advertisement (RA)**
    - Le routeur envoie périodiquement des RA contenant le préfixe réseau
3. **Construction de l'adresse globale**
    - Préfixe réseau (du RA) + Identifiant d'interface = Adresse IPv6 complète
4. **Vérification de l'unicité (DAD)**
    - L'hôte vérifie que l'adresse n'est pas déjà utilisée

### 🛠️ Configuration sur Cisco

```bash
# Configuration du routeur pour activer SLAAC
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 address 2001:db8:acad:1::1/64
Router(config-if)# ipv6 nd prefix 2001:db8:acad:1::/64
Router(config-if)# no ipv6 nd managed-config-flag  # DHCPv6 stateful désactivé
Router(config-if)# no ipv6 nd other-config-flag    # DHCPv6 stateless désactivé

# Vérification des paramètres RA
Router# show ipv6 interface GigabitEthernet0/0

# Sur un hôte Linux
# Vérifier la configuration automatique
ip -6 addr show
# L'adresse globale devrait être générée automatiquement
```

### 📊 Format EUI-64

L'identifiant d'interface peut être généré via EUI-64 à partir de l'adresse MAC :

|Étape|Description|Exemple|
|---|---|---|
|MAC d'origine|Adresse MAC 48 bits|`00:1A:2B:3C:4D:5E`|
|Insertion FFFE|Insertion de FFFE au milieu|`00:1A:2B:FF:FE:3C:4D:5E`|
|Inversion bit U/L|Inverser le 7ème bit|`02:1A:2B:FF:FE:3C:4D:5E`|
|Résultat|Identifiant 64 bits|`021A:2BFF:FE3C:4D5E`|

```bash
# Forcer l'utilisation d'EUI-64 sur Cisco
Router(config-if)# ipv6 address 2001:db8:acad:1::/64 eui-64

# Désactiver EUI-64 et utiliser un identifiant aléatoire (privacy extensions)
# Sur Linux
sysctl -w net.ipv6.conf.eth0.use_tempaddr=2
```

> [!warning] Préoccupation de confidentialité EUI-64 expose l'adresse MAC de l'hôte, permettant le suivi de l'appareil. Les systèmes modernes utilisent des **adresses temporaires aléatoires** (RFC 4941) pour préserver la vie privée.

> [!tip] Bonne pratique
> 
> - **Serveurs** : Utiliser des adresses statiques ou EUI-64 pour la stabilité
> - **Clients** : Activer les privacy extensions pour la confidentialité

### ⚠️ Pièges courants

- **Pas d'information DNS** : SLAAC ne fournit pas les serveurs DNS (utiliser RDNSS ou DHCPv6 stateless)
- **Pas de gestion centralisée** : Difficile de contrôler quelles adresses sont attribuées
- **Sécurité** : Vulnérable aux faux Router Advertisements (utiliser RA Guard)

---

## 📋 DHCPv6 (Stateful et Stateless)

### 📖 Vue d'ensemble

DHCPv6 est le protocole DHCP adapté pour IPv6. Il existe en **deux modes** selon les besoins de configuration.

|Mode|Description|Adresse IP|Autres infos|
|---|---|---|---|
|**Stateful**|Le serveur attribue l'adresse IPv6 complète|✅ Oui|✅ Oui (DNS, etc.)|
|**Stateless**|L'hôte utilise SLAAC pour l'adresse|❌ Non|✅ Oui (DNS, etc.)|

> [!info] Quand utiliser DHCPv6 ?
> 
> - **Stateful** : Besoin de contrôle centralisé des adresses (entreprise, traçabilité)
> - **Stateless** : SLAAC pour l'adresse, DHCPv6 juste pour DNS/NTP/etc.

### 🔄 DHCPv6 Stateful

Le serveur DHCPv6 gère l'attribution complète des adresses IPv6.

#### Processus DORA modifié (SARR)

1. **Solicit** : Le client envoie un message de découverte (multicast ff02::1:2)
2. **Advertise** : Les serveurs DHCPv6 répondent avec leurs offres
3. **Request** : Le client demande une adresse à un serveur spécifique
4. **Reply** : Le serveur confirme et attribue l'adresse

```bash
# Configuration serveur DHCPv6 stateful sur Cisco
Router(config)# ipv6 dhcp pool DHCPv6-POOL
Router(config-dhcpv6)# address prefix 2001:db8:acad:1::/64
Router(config-dhcpv6)# dns-server 2001:4860:4860::8888
Router(config-dhcpv6)# domain-name exemple.com

Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 address 2001:db8:acad:1::1/64
Router(config-if)# ipv6 dhcp server DHCPv6-POOL
Router(config-if)# ipv6 nd managed-config-flag     # Flag M=1 (stateful)
Router(config-if)# ipv6 nd prefix default no-autoconfig  # Désactiver SLAAC

# Vérification
Router# show ipv6 dhcp pool
Router# show ipv6 dhcp binding
```

```bash
# Configuration client sur Linux
# dhclient -6 utilise DHCPv6 stateful si le flag M=1
dhclient -6 -v eth0

# Vérifier l'adresse obtenue
ip -6 addr show eth0
```

> [!example] Flags dans Router Advertisement
> 
> - **M flag (Managed)** = 1 : Utiliser DHCPv6 stateful pour obtenir l'adresse
> - **O flag (Other)** = 1 : Utiliser DHCPv6 stateless pour infos supplémentaires

### 🔄 DHCPv6 Stateless

L'hôte utilise SLAAC pour son adresse, mais DHCPv6 pour obtenir DNS, domaine, etc.

```bash
# Configuration DHCPv6 stateless sur Cisco
Router(config)# ipv6 dhcp pool DHCPv6-STATELESS
Router(config-dhcpv6)# dns-server 2001:4860:4860::8888
Router(config-dhcpv6)# dns-server 2001:4860:4860::8844
Router(config-dhcpv6)# domain-name exemple.com

Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 address 2001:db8:acad:1::1/64
Router(config-if)# ipv6 dhcp server DHCPv6-STATELESS
Router(config-if)# no ipv6 nd managed-config-flag   # M=0 (pas stateful)
Router(config-if)# ipv6 nd other-config-flag        # O=1 (stateless)

# Vérification
Router# show ipv6 dhcp pool
Router# show ipv6 interface GigabitEthernet0/0
```

### 📡 DHCPv6 Relay

Comme en IPv4, un agent relay transmet les messages DHCPv6 entre clients et serveurs sur différents segments.

```bash
# Configuration DHCPv6 relay sur routeur intermédiaire
Router(config)# interface GigabitEthernet0/1
Router(config-if)# ipv6 dhcp relay destination 2001:db8:acad:2::10
Router(config-if)# ipv6 nd managed-config-flag

# Vérification
Router# show ipv6 dhcp interface
```

> [!warning] Adresses multicast DHCPv6
> 
> - **ff02::1:2** : All DHCPv6 relay agents et serveurs (lien-local)
> - **ff05::1:3** : All DHCPv6 serveurs (site-local)

### 🔐 DHCPv6 Prefix Delegation (PD)

Permet à un routeur client (ex: box internet) d'obtenir un préfixe entier pour son réseau interne.

```bash
# Sur le serveur ISP
Router(config)# ipv6 dhcp pool PD-POOL
Router(config-dhcpv6)# prefix-delegation pool PD-PREFIX lifetime 3600 600
Router(config)# ipv6 local pool PD-PREFIX 2001:db8::/48 56

# Sur le routeur client (CPE)
Router(config)# interface GigabitEthernet0/0  # WAN
Router(config-if)# ipv6 address autoconfig default
Router(config-if)# ipv6 dhcp client pd PREFIX-FROM-ISP

Router(config)# interface GigabitEthernet0/1  # LAN
Router(config-if)# ipv6 address PREFIX-FROM-ISP ::1/64
```

> [!tip] Astuce Le Prefix Delegation est essentiel pour les déploiements résidentiels IPv6, où l'ISP délègue un /56 ou /48 au CPE.

---

## 🔍 Neighbor Discovery Protocol (NDP)

### 📖 Définition et rôle

NDP est un protocole fondamental d'IPv6 qui **remplace ARP, ICMP Router Discovery et ICMP Redirect** d'IPv4. Il utilise des messages ICMPv6 pour gérer les interactions entre nœuds.

> [!info] Fonctions principales de NDP
> 
> 1. **Résolution d'adresse** (remplace ARP)
> 2. **Découverte de routeurs**
> 3. **Détection d'adresses dupliquées (DAD)**
> 4. **Détection d'inaccessibilité de voisins**
> 5. **Redirection de routes**

### 📨 Messages NDP (ICMPv6)

|Type|Code ICMPv6|Usage|Adresse destination|
|---|---|---|---|
|**Router Solicitation (RS)**|133|Demander les RA immédiatement|ff02::2 (all-routers)|
|**Router Advertisement (RA)**|134|Annoncer la présence du routeur + préfixe|ff02::1 (all-nodes)|
|**Neighbor Solicitation (NS)**|135|Résolution d'adresse, DAD, vérification|Solicited-node multicast|
|**Neighbor Advertisement (NA)**|136|Réponse aux NS|Unicast ou ff02::1|
|**Redirect**|137|Indiquer un meilleur routeur|Unicast|

### 🔗 Résolution d'adresse (remplace ARP)

Processus pour découvrir l'adresse MAC correspondant à une IPv6.

```bash
# Exemple de résolution d'adresse
# Hôte A veut communiquer avec 2001:db8:acad:1::2

# 1. A envoie un Neighbor Solicitation (NS)
#    Source: 2001:db8:acad:1::1
#    Destination: ff02::1:ff00:2 (solicited-node multicast)
#    Question: "Qui a l'adresse 2001:db8:acad:1::2 ?"

# 2. B répond avec un Neighbor Advertisement (NA)
#    Source: 2001:db8:acad:1::2
#    Destination: 2001:db8:acad:1::1
#    Réponse: "C'est moi, mon MAC est 00:1A:2B:3C:4D:5E"

# Visualiser la table de voisinage (équivalent de la table ARP)
Router# show ipv6 neighbors

# Sur Linux
ip -6 neigh show
```

> [!example] Adresse Solicited-Node Multicast Pour l'adresse `2001:db8:acad:1::AB:CDEF`, l'adresse solicited-node est : `ff02::1:ff:AB:CDEF` (ff02::1:ff + derniers 24 bits)

### 🔄 Neighbor Unreachability Detection (NUD)

NDP surveille la joignabilité des voisins via un système d'états.

```
INCOMPLETE → REACHABLE → STALE → DELAY → PROBE → (REACHABLE ou suppression)
```

|État|Description|
|---|---|
|**INCOMPLETE**|NS envoyé, en attente de NA|
|**REACHABLE**|Voisin confirmé joignable récemment|
|**STALE**|Plus de confirmation récente, mais toujours utilisé|
|**DELAY**|Tentative de reconfirmation|
|**PROBE**|Envoi actif de NS pour vérifier|

```bash
# Forcer une vérification d'accessibilité
Router# clear ipv6 neighbors

# Paramétrer les timers NUD
Router(config-if)# ipv6 nd reachable-time 30000  # en millisecondes
Router(config-if)# ipv6 nd ns-interval 1000      # intervalle entre NS
```

> [!warning] Différence avec ARP
> 
> - **ARP** : Cache statique, timeouts fixes
> - **NDP** : Détection dynamique d'inaccessibilité, reconfirmation active

### 🛡️ Sécurité NDP

NDP est vulnérable aux attaques (spoofing, DoS). Solutions :

```bash
# RA Guard : Bloquer les RA non autorisés sur ports d'accès
Switch(config)# ipv6 nd raguard policy HOST-POLICY
Switch(config-nd-raguard)# device-role host

Switch(config)# interface range GigabitEthernet1/0/1-24
Switch(config-if-range)# ipv6 nd raguard attach-policy HOST-POLICY

# DHCP Guard : Bloquer les réponses DHCPv6 non autorisées
Switch(config)# ipv6 dhcp guard policy DHCP-GUARD-POLICY
Switch(config-dhcp-guard)# device-role client

Switch(config)# interface range GigabitEthernet1/0/1-24
Switch(config-if-range)# ipv6 dhcp guard attach-policy DHCP-GUARD-POLICY

# IPv6 Source Guard : Vérifier l'adresse source
Switch(config)# ipv6 source-guard policy SOURCE-GUARD-POLICY
Switch(config-sisf-sourceguard)# deny global-autoconf

Switch(config)# interface GigabitEthernet1/0/5
Switch(config-if)# ipv6 source-guard attach-policy SOURCE-GUARD-POLICY
```

> [!tip] SEcure Neighbor Discovery (SEND) RFC 3971 définit SEND qui utilise des signatures cryptographiques, mais son déploiement reste limité.

---

## 📢 Router Advertisement et Router Solicitation

### 📖 Router Advertisement (RA)

Les RA sont des messages ICMPv6 type 134 envoyés périodiquement par les routeurs pour annoncer leur présence et fournir des paramètres de configuration.

#### Contenu d'un RA

```
┌─────────────────────────────────────┐
│  Router Advertisement (ICMPv6 134)  │
├─────────────────────────────────────┤
│ • Cur Hop Limit (TTL par défaut)    │
│ • M flag (Managed - DHCPv6 stateful)│
│ • O flag (Other - DHCPv6 stateless) │
│ • Router Lifetime                   │
│ • Reachable Time                    │
│ • Retrans Timer                     │
│ • Options:                          │
│   - Prefix Information              │
│   - MTU                             │
│   - Source Link-Layer Address       │
│   - RDNSS (Recursive DNS)           │
└─────────────────────────────────────┘
```

### 📡 Configuration des Router Advertisements

```bash
# Configuration basique des RA
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 address 2001:db8:acad:1::1/64
Router(config-if)# ipv6 nd prefix 2001:db8:acad:1::/64

# Modifier l'intervalle des RA (200 secondes par défaut)
Router(config-if)# ipv6 nd ra interval 100  # min: 4s, max: 1800s
Router(config-if)# ipv6 nd ra lifetime 1800  # durée de validité du routeur

# Configurer le MTU annoncé
Router(config-if)# ipv6 nd mtu 1500

# Configurer le Hop Limit (TTL)
Router(config-if)# ipv6 nd hop-limit 64

# Désactiver les RA sur une interface (ex: WAN)
Router(config-if)# ipv6 nd ra suppress all

# Annoncer les serveurs DNS via RDNSS (RFC 8106)
Router(config-if)# ipv6 nd ra dns server 2001:4860:4860::8888 lifetime 3600
```

### 🎯 Prefix Information Option

L'option de préfixe dans les RA contient des informations cruciales :

```bash
# Configuration détaillée du préfixe
Router(config-if)# ipv6 nd prefix 2001:db8:acad:1::/64 14400 14400

# Syntaxe complète
Router(config-if)# ipv6 nd prefix <prefix/length> 
    <valid-lifetime> <preferred-lifetime> 
    [no-advertise] [off-link] [no-autoconfig]

# Exemples d'options
# Préfixe sans auto-configuration (force DHCPv6)
Router(config-if)# ipv6 nd prefix 2001:db8:acad:1::/64 14400 14400 no-autoconfig

# Préfixe off-link (ne pas utiliser ce préfixe sur ce lien)
Router(config-if)# ipv6 nd prefix 2001:db8:acad:2::/64 14400 14400 off-link

# Ne pas annoncer ce préfixe dans les RA
Router(config-if)# ipv6 nd prefix default no-advertise
```

|Paramètre|Description|Valeur typique|
|---|---|---|
|**Valid Lifetime**|Durée totale de validité de l'adresse|2592000s (30j)|
|**Preferred Lifetime**|Durée pendant laquelle l'adresse est préférée|604800s (7j)|
|**L flag**|On-link : préfixe sur ce lien|1|
|**A flag**|Autonomous : SLAAC autorisé|1|

> [!warning] Preferred vs Valid
> 
> - **Preferred** : L'adresse est utilisée pour les nouvelles connexions
> - **Deprecated** : L'adresse est encore valide mais non préférée (entre preferred et valid)
> - **Invalid** : L'adresse ne doit plus être utilisée (après valid)

### 📞 Router Solicitation (RS)

Les RS permettent aux hôtes de demander des RA immédiatement au lieu d'attendre l'annonce périodique.

```bash
# Un hôte envoie un RS quand :
# - L'interface IPv6 est activée
# - L'hôte a besoin de configuration réseau immédiate

# Message RS (ICMPv6 type 133)
# Source: adresse link-local ou ::
# Destination: ff02::2 (all-routers multicast)

# Les routeurs répondent avec un RA unicast ou multicast

# Désactiver la réponse aux RS (routeur en mode passif)
Router(config-if)# ipv6 nd ra suppress all

# Vérifier les statistiques RA/RS
Router# show ipv6 interface GigabitEthernet0/0
# Affiche : ND DAD enabled, RA interval, RS received, RA sent, etc.
```

### 🎛️ Flags M et O dans les RA

Ces flags contrôlent le comportement DHCP des clients.

|M flag|O flag|Comportement client|
|---|---|---|
|0|0|**SLAAC pur** - Auto-configuration complète|
|0|1|**SLAAC + DHCPv6 stateless** - Adresse via SLAAC, infos via DHCPv6|
|1|0|**DHCPv6 stateful** - Tout via DHCPv6 (rare)|
|1|1|**DHCPv6 stateful** - Tout via DHCPv6 + infos supplémentaires|

```bash
# Scénario 1 : SLAAC pur
Router(config-if)# no ipv6 nd managed-config-flag    # M=0
Router(config-if)# no ipv6 nd other-config-flag      # O=0

# Scénario 2 : SLAAC + DHCPv6 stateless (RECOMMANDÉ pour DNS)
Router(config-if)# no ipv6 nd managed-config-flag    # M=0
Router(config-if)# ipv6 nd other-config-flag         # O=1

# Scénario 3 : DHCPv6 stateful complet
Router(config-if)# ipv6 nd managed-config-flag       # M=1
Router(config-if)# ipv6 nd prefix default no-autoconfig  # Désactiver SLAAC
```

> [!tip] Bonne pratique **SLAAC + DHCPv6 stateless (M=0, O=1)** est le choix optimal pour la plupart des réseaux :
> 
> - Simplicité de SLAAC pour les adresses
> - DHCPv6 pour DNS, domaine, NTP
> - Pas de serveur DHCPv6 complexe nécessaire

### 🔍 Débogage et vérification

```bash
# Capturer les RA/RS
Router# debug ipv6 nd
Router# debug ipv6 icmp

# Vérifier le contenu des RA envoyés
Router# show ipv6 interface GigabitEthernet0/0

# Sur Linux - écouter les RA
rdisc6 eth0

# Capturer avec tcpdump
tcpdump -i eth0 -vv icmp6 and 'ip6[40] == 134'  # RA
tcpdump -i eth0 -vv icmp6 and 'ip6[40] == 133'  # RS

# Wireshark : Filtre "icmpv6.type == 134 || icmpv6.type == 133"
```

---

## 🔒 Duplicate Address Detection (DAD)

### 📖 Principe et fonctionnement

DAD est un mécanisme **obligatoire** d'IPv6 qui garantit qu'une adresse est unique sur le lien avant son utilisation. Il utilise NDP pour vérifier l'unicité.

> [!info] Pourquoi DAD ?
> 
> - IPv6 permet l'auto-configuration, donc risque de collision
> - Détecte les adresses dupliquées avant qu'elles ne causent des problèmes
> - Évite les conflits IP comme en IPv4

### 🔄 Processus DAD

```
1. Attribution d'adresse (SLAAC, statique, DHCPv6)
   ↓
2. L'adresse passe en état TENTATIVE
   ↓
3. Envoi de Neighbor Solicitation (NS)
   • Source: :: (adresse non spécifiée)
   • Destination: solicited-node multicast de l'adresse testée
   • Target: L'adresse à vérifier
   ↓
4. Écoute pendant 1 seconde
   ↓
5a. Aucune réponse → Adresse VALIDE
5b. Neighbor Advertisement reçu → DUPLICATE détecté
```

#### Détail du message NS pour DAD

```bash
# Neighbor Solicitation pour DAD
ICMPv6 Type: 135 (Neighbor Solicitation)
Source IPv6: :: (unspecified)
Destination IPv6: ff02::1:ff:XX:XXXX (solicited-node multicast)
Target Address: 2001:db8:acad:1::A (adresse à vérifier)
Options: (aucune, car source est ::)

# Si quelqu'un a déjà cette adresse, il répond avec NA
ICMPv6 Type: 136 (Neighbor Advertisement)
Source IPv6: 2001:db8:acad:1::A
Destination IPv6: ff02::1 (all-nodes)
Target Address: 2001:db8:acad:1::A
Flags: Override=1, Solicited=0
```

### ⚙️ Configuration et gestion DAD

```bash
# DAD est activé par défaut sur toutes les interfaces IPv6
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 address 2001:db8:acad:1::1/64

# Vérifier l'état DAD
Router# show ipv6 interface GigabitEthernet0/0
# Output indique : "ND DAD enabled, number of DAD attempts: 1"

# Modifier le nombre de tentatives DAD (par défaut 1)
Router(config-if)# ipv6 nd dad attempts 3

# Désactiver DAD (NON RECOMMANDÉ, sauf cas spécifiques)
Router(config-if)# ipv6 nd dad attempts 0

# Voir les adresses et leur état
Router# show ipv6 interface brief
# [TENTATIVE] apparaît pendant le DAD
# Puis disparaît quand l'adresse est validée
```

### 🕐 Timeline DAD

```bash
T=0s    : Configuration de l'adresse
          État: TENTATIVE
          
T=0s    : Envoi de NS #1 (si dad attempts ≥ 1)
          
T=1s    : Timeout, envoi de NS #2 (si dad attempts ≥ 2)
          
T=2s    : Timeout, envoi de NS #3 (si dad attempts ≥ 3)
          
T=3s    : Si aucune réponse
          État: VALID (adresse utilisable)
          
À tout moment : Si NA reçu
          État: DUPLICATE (adresse INUTILISABLE)
```

> [!warning] Impact du DAD
> 
> - **Délai de démarrage** : 1 à 3 secondes avant que l'adresse soit utilisable
> - **Interruption temporaire** : Pendant DAD, pas de communication sur cette adresse

### 🚨 Détection de duplicate

Lorsqu'un duplicate est détecté :

```bash
# Message système typique
%IPV6-4-DUPLICATE: Duplicate address 2001:DB8:ACAD:1::1 on GigabitEthernet0/0

# L'adresse passe en état DUPLICATE
Router# show ipv6 interface GigabitEthernet0/0
# Output: Global unicast address(es):
#   2001:DB8:ACAD:1::1, subnet is 2001:DB8:ACAD:1::/64 [DUP]

# L'interface désactive cette adresse
# Elle ne peut plus être utilisée

# Résolution : 
# 1. Identifier l'autre hôte utilisant cette adresse
Router# show ipv6 neighbors
# 2. Modifier l'une des deux adresses
```

### 🔍 Cas particuliers

#### DAD sur les adresses link-local

```bash
# Les adresses link-local (fe80::/10) passent aussi par DAD
# C'est la PREMIÈRE vérification au démarrage de l'interface

Router(config-if)# no shutdown
# 1. Génération de l'adresse link-local fe80::...
# 2. DAD sur cette link-local
# 3. Si succès, l'interface peut être utilisée pour IPv6
# 4. Ensuite, génération des adresses globales
# 5. DAD sur chaque adresse globale

# Voir l'état de la link-local
Router# show ipv6 interface GigabitEthernet0/0
# Rechercher : "link-local address is FE80::... [TENTATIVE]" puis "[VALID]"
```

#### DAD et adresses anycast

```bash
# Les adresses anycast SAUTENT le processus DAD
# Car par définition, plusieurs nœuds peuvent avoir la même anycast

Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 address 2001:db8:acad:1::99/128 anycast

# Aucun DAD n'est effectué pour cette adresse
# Elle est immédiatement VALID
```

#### Optimized DAD (RFC 4429)

```bash
# Dans les réseaux point-à-point, DAD peut être optimisé
# Car il n'y a que 2 nœuds sur le lien

Router(config)# interface Serial0/0/0
Router(config-if)# ipv6 address 2001:db8:acad:12::1/64

# Sur les liens point-à-point, certains OS skip DAD
# ou utilisent un DAD simplifié
```

### 🛡️ Sécurité DAD

DAD est vulnérable aux attaques DoS :

```bash
# Attaque : Un attaquant répond à tous les NS de DAD
# Résultat : Aucune adresse ne peut être configurée (DoS)

# Protection : SEcure Neighbor Discovery (SEND)
# Utilise des signatures cryptographiques (CGA - Cryptographically Generated Addresses)
# Mais déploiement très limité en pratique

# Alternative pratique : Sécurité physique du réseau
# - Port security sur les switches
# - RA Guard, DHCP Guard
# - Surveillance des logs pour détecter les duplicates anormaux
```

> [!tip] Surveillance DAD
> 
> ```bash
> # Activer les logs pour les duplicates
> Router(config)# logging console informational
> Router(config)# logging buffered informational
> 
> # Monitorer les événements DAD
> Router# show logging | include DUPLICATE
> 
> # Sur Linux, vérifier les logs système
> journalctl -k | grep -i "duplicate address"
> dmesg | grep -i "dad"
> ```

### 📊 États des adresses IPv6

Récapitulatif des états qu'une adresse peut avoir :

|État|Description|Utilisation|
|---|---|---|
|**TENTATIVE**|DAD en cours|❌ Non utilisable|
|**VALID/PREFERRED**|Adresse vérifiée et préférée|✅ Utilisée pour nouvelles connexions|
|**DEPRECATED**|Encore valide mais non préférée|⚠️ Connexions existantes seulement|
|**INVALID**|Lifetime expiré|❌ Ne doit plus être utilisée|
|**DUPLICATE**|Conflit détecté|❌ Désactivée|

```bash
# Voir tous les états sur une interface
Router# show ipv6 interface GigabitEthernet0/0

# Exemple de sortie :
# 2001:DB8:1::1/64 [VALID]
# 2001:DB8:1::2/64 [DEPRECATED] 
# 2001:DB8:1::3/64 [DUP]
# FE80::1 [VALID]

# Sur Linux
ip -6 addr show dev eth0
# Flags : tentative, deprecated, dadfailed
```

### ⚙️ DAD et performances

```bash
# Dans les grands réseaux, optimiser DAD pour réduire le délai

# Option 1 : Réduire le nombre de tentatives (trade-off sécurité)
Router(config-if)# ipv6 nd dad attempts 1  # Par défaut

# Option 2 : Sur liens dédiés point-à-point, désactiver DAD
Router(config-if)# ipv6 nd dad attempts 0
# ATTENTION : Uniquement si vous GARANTISSEZ l'unicité des adresses

# Option 3 : Utiliser des adresses statiques sur l'infrastructure
# Plus rapide que SLAAC car vous contrôlez l'unicité
Router(config-if)# ipv6 address 2001:db8::1/64
```

### 🔍 Débogage DAD

```bash
# Activer le debug pour voir le processus DAD en détail
Router# debug ipv6 nd
Router# debug ipv6 icmp

# Exemple de sortie debug :
# ICMPv6-ND: Sending NS for 2001:DB8:1::1 on GigabitEthernet0/0 (DAD)
# ICMPv6-ND: DAD: 2001:DB8:1::1 is unique on GigabitEthernet0/0

# Si duplicate détecté :
# ICMPv6-ND: Received NA for 2001:DB8:1::1 on GigabitEthernet0/0
# ICMPv6-ND: DAD: duplicate address 2001:DB8:1::1 on GigabitEthernet0/0

# Capturer les messages DAD avec tcpdump
tcpdump -i eth0 -vv 'icmp6 and ip6[40] == 135 and ip6[8:4] == 0'
# Filtre : NS (135) avec source :: (DAD)

# Wireshark : 
# Filtre : icmpv6.type == 135 && ipv6.src == ::
```

> [!warning] Pièges courants
> 
> - **Oublier DAD sur les VMs** : Les templates/clones peuvent avoir la même adresse link-local
> - **Dual-stack mal configuré** : IPv4 fonctionne mais IPv6 bloqué par DAD
> - **Équipements legacy** : Certains ne respectent pas DAD correctement
> - **Boucles réseau** : Peuvent causer de faux positifs DAD

> [!tip] Bonnes pratiques DAD
> 
> 1. **Laisser DAD activé** sauf cas très spécifique
> 2. **Monitorer les logs** pour détecter les duplicates
> 3. **Utiliser des adresses statiques** sur l'infrastructure critique
> 4. **Documenter les adresses** pour éviter les conflits manuels
> 5. **Tester après clonage** de VMs ou containers

---

## 🎯 Synthèse et comparaison

### 📊 Tableau récapitulatif des méthodes de configuration

|Méthode|Adresse IP|DNS|Autres infos|Serveur requis|Complexité|
|---|---|---|---|---|---|
|**SLAAC pur**|✅ Auto|❌ Non|❌ Non|Routeur seulement|⭐ Faible|
|**SLAAC + RDNSS**|✅ Auto|✅ RA|⚠️ Limité|Routeur seulement|⭐⭐ Faible|
|**SLAAC + DHCPv6 stateless**|✅ Auto|✅ DHCPv6|✅ Complet|Routeur + DHCPv6|⭐⭐⭐ Moyen|
|**DHCPv6 stateful**|✅ DHCPv6|✅ DHCPv6|✅ Complet|Routeur + DHCPv6|⭐⭐⭐⭐ Élevé|

### 🔄 Flux de configuration IPv6 complet

```
┌─────────────────────────────────────────────────────────┐
│ 1. INTERFACE ACTIVÉE (no shutdown)                      │
└───────────────┬─────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────┐
│ 2. GÉNÉRATION ADRESSE LINK-LOCAL (fe80::/10)           │
│    • EUI-64 ou aléatoire                                │
│    • DAD sur link-local                                 │
└───────────────┬─────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────┐
│ 3. ENVOI ROUTER SOLICITATION (RS)                      │
│    • Destination : ff02::2 (all-routers)                │
│    • Demande RA immédiate                               │
└───────────────┬─────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────┐
│ 4. RÉCEPTION ROUTER ADVERTISEMENT (RA)                 │
│    • Préfixe réseau                                     │
│    • Flags M et O                                       │
│    • Lifetime, MTU, etc.                                │
└───────────────┬─────────────────────────────────────────┘
                │
        ┌───────┴───────┐
        │               │
        ▼               ▼
┌──────────────┐  ┌──────────────┐
│   M=0, O=0   │  │   M=1, O=?   │
│   M=0, O=1   │  │              │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ 5a. SLAAC    │  │ 5b. DHCPv6   │
│ Préfixe +    │  │ SOLICIT      │
│ Interface ID │  │ ADVERTISE    │
│ = Adresse    │  │ REQUEST      │
│              │  │ REPLY        │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌─────────────────────────────────────────────────────────┐
│ 6. DAD SUR ADRESSE GLOBALE                              │
│    • NS avec source ::                                  │
│    • Attente 1 seconde                                  │
└───────────────┬─────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────┐
│ 7. ADRESSE VALID - COMMUNICATION POSSIBLE               │
└─────────────────────────────────────────────────────────┘
```

### 🎛️ Guide de décision : Quelle méthode choisir ?

```bash
# Scénario 1 : Réseau domestique / PME simple
# → SLAAC pur ou SLAAC + RDNSS
# Avantages : Simple, aucun serveur à maintenir
# Inconvénients : Pas de traçabilité, pas de contrôle

Router(config-if)# ipv6 address 2001:db8:1::1/64
Router(config-if)# ipv6 nd ra dns server 2001:4860:4860::8888
Router(config-if)# no ipv6 nd managed-config-flag
Router(config-if)# no ipv6 nd other-config-flag

# Scénario 2 : Entreprise moyenne (RECOMMANDÉ)
# → SLAAC + DHCPv6 stateless
# Avantages : Équilibre entre simplicité et fonctionnalité
# Inconvénients : Nécessite un serveur DHCPv6 léger

Router(config-if)# ipv6 address 2001:db8:1::1/64
Router(config-if)# ipv6 dhcp server STATELESS-POOL
Router(config-if)# no ipv6 nd managed-config-flag
Router(config-if)# ipv6 nd other-config-flag

# Scénario 3 : Grande entreprise / Data center
# → DHCPv6 stateful
# Avantages : Contrôle total, traçabilité, gestion centralisée
# Inconvénients : Infrastructure DHCPv6 complexe

Router(config-if)# ipv6 dhcp server STATEFUL-POOL
Router(config-if)# ipv6 nd managed-config-flag
Router(config-if)# ipv6 nd prefix default no-autoconfig

# Scénario 4 : Serveurs / Infrastructure
# → Adresses statiques
# Avantages : Prévisible, stable, pas de dépendance
# Inconvénients : Configuration manuelle

Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 address 2001:db8:1::100/64
```

### ⚡ Messages ICMPv6 NDP - Référence rapide

|Message|Type|Code|Source|Destination|Usage principal|
|---|---|---|---|---|---|
|**RS**|133|0|Link-local ou ::|ff02::2|Demander RA|
|**RA**|134|0|Link-local|ff02::1 ou unicast|Annoncer routeur/préfixe|
|**NS**|135|0|Link-local ou ::|Solicited-node ou unicast|Résolution adresse, DAD, NUD|
|**NA**|136|0|Link-local|ff02::1 ou unicast|Réponse aux NS|
|**Redirect**|137|0|Link-local|Unicast|Redirection vers meilleur routeur|

### 🔐 Sécurité IPv6 - Checklist

```bash
# ✅ Activer RA Guard sur les ports d'accès
Switch(config-if)# ipv6 nd raguard attach-policy HOST-POLICY

# ✅ Activer DHCP Guard
Switch(config-if)# ipv6 dhcp guard attach-policy DHCP-GUARD-POLICY

# ✅ Activer IPv6 Source Guard
Switch(config-if)# ipv6 source-guard attach-policy SOURCE-GUARD-POLICY

# ✅ Filtrer le trafic ICMPv6 sensible (tout en autorisant NDP)
Router(config)# ipv6 access-list BLOCK-MALICIOUS-ICMPV6
Router(config-ipv6-acl)# permit icmp any any nd-na
Router(config-ipv6-acl)# permit icmp any any nd-ns
Router(config-ipv6-acl)# permit icmp any any router-advertisement
Router(config-ipv6-acl)# permit icmp any any router-solicitation
Router(config-ipv6-acl)# deny icmp any any
Router(config-ipv6-acl)# permit ipv6 any any

Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 traffic-filter BLOCK-MALICIOUS-ICMPV6 in

# ✅ Surveiller les logs pour détecter anomalies
Router(config)# logging buffered informational
Router(config)# logging console warnings

# ✅ Limiter le rate des ICMPv6
Router(config-if)# ipv6 nd ns-interval 1000
Router(config-if)# ipv6 nd reachable-time 30000
```

### 📝 Commandes de vérification essentielles

```bash
# === Sur Cisco IOS ===

# Voir toutes les adresses IPv6
Router# show ipv6 interface brief

# Détails complets d'une interface
Router# show ipv6 interface GigabitEthernet0/0

# Table de voisinage (équivalent ARP)
Router# show ipv6 neighbors

# Pools DHCPv6 et attributions
Router# show ipv6 dhcp pool
Router# show ipv6 dhcp binding

# Routes IPv6
Router# show ipv6 route

# Statistiques RA/RS/NS/NA
Router# show ipv6 interface GigabitEthernet0/0 | include RA|RS|NS|NA

# === Sur Linux ===

# Adresses IPv6
ip -6 addr show

# Table de voisinage
ip -6 neigh show

# Routes IPv6
ip -6 route show

# Écouter les RA
rdisc6 eth0

# Statistiques NDP
netstat -s -6 | grep -i icmp

# Configuration DHCPv6
cat /var/lib/dhcp/dhclient6.leases

# === Captures réseau ===

# Capturer tous les ICMPv6
tcpdump -i eth0 -vv icmp6

# Capturer uniquement RA
tcpdump -i eth0 -vv 'icmp6 and ip6[40] == 134'

# Capturer les NS pour DAD (source ::)
tcpdump -i eth0 -vv 'icmp6 and ip6[40] == 135 and ip6[8:4] == 0'
```

### 💡 Astuces de dépannage

> [!tip] Problème : Pas d'adresse IPv6 globale
> 
> ```bash
> # Vérifier :
> 1. Interface activée ? → show ipv6 interface brief
> 2. RA reçus ? → debug ipv6 nd
> 3. DAD bloqué ? → Chercher [TENTATIVE] ou [DUP]
> 4. Flags M/O corrects ? → show ipv6 interface
> 5. Serveur DHCPv6 joignable ? → ping ff02::1:2
> ```

> [!tip] Problème : Adresse DUPLICATE
> 
> ```bash
> # Identifier le coupable :
> 6. show ipv6 neighbors → Voir qui a l'adresse
> 7. Vérifier clones de VMs / containers
> 8. Vérifier config statique en double
> 9. Désactiver temporairement DAD pour debug :
>    Router(config-if)# ipv6 nd dad attempts 0
> ```

> [!tip] Problème : Pas de DNS
> 
> ```bash
> # Solutions par ordre de préférence :
> 10. RDNSS dans RA : ipv6 nd ra dns server ...
> 11. DHCPv6 stateless : M=0, O=1
> 12. Configuration manuelle : /etc/resolv.conf
> ```

> [!tip] Problème : Connectivité intermittente
> 
> ```bash
> # Suspecter NUD (Neighbor Unreachability Detection) :
> 13. show ipv6 neighbors → Chercher états STALE/PROBE
> 14. Ajuster timers :
>    Router(config-if)# ipv6 nd reachable-time 30000
>    Router(config-if)# ipv6 nd ns-interval 1000
> 15. Vérifier la bidirectionnalité des liens
> ```

---

## 🎓 Récapitulatif final

### Points clés à retenir

1. **SLAAC** = Auto-configuration simple, routeur annonce le préfixe, hôte génère son adresse
2. **DHCPv6** existe en deux modes : **stateful** (gère les adresses) et **stateless** (juste les infos)
3. **NDP** remplace ARP + ICMP Router Discovery, utilise 5 types de messages ICMPv6
4. **RA/RS** permettent la découverte de routeurs et l'annonce de paramètres de configuration
5. **DAD** garantit l'unicité des adresses avant utilisation (obligatoire, utilise NS/NA)

### Configuration type recommandée

```bash
# === Routeur d'entreprise (SLAAC + DHCPv6 stateless) ===

# Pool DHCPv6 stateless
Router(config)# ipv6 dhcp pool ENTREPRISE-STATELESS
Router(config-dhcpv6)# dns-server 2001:4860:4860::8888
Router(config-dhcpv6)# dns-server 2001:4860:4860::8844
Router(config-dhcpv6)# domain-name entreprise.local

# Interface LAN
Router(config)# interface GigabitEthernet0/0
Router(config-if)# description LAN Utilisateurs
Router(config-if)# ipv6 address 2001:db8:100:1::1/64
Router(config-if)# ipv6 dhcp server ENTREPRISE-STATELESS
Router(config-if)# no ipv6 nd managed-config-flag
Router(config-if)# ipv6 nd other-config-flag
Router(config-if)# ipv6 nd ra interval 200
Router(config-if)# ipv6 nd ra lifetime 1800

# Sécurité sur le switch d'accès
Switch(config)# ipv6 nd raguard policy HOST-POLICY
Switch(config-nd-raguard)# device-role host

Switch(config)# interface range GigabitEthernet1/0/1-24
Switch(config-if-range)# description Ports utilisateurs
Switch(config-if-range)# ipv6 nd raguard attach-policy HOST-POLICY
Switch(config-if-range)# ipv6 dhcp guard attach-policy DHCP-GUARD
```

---

**🎯 Fin du cours Configuration IPv6**