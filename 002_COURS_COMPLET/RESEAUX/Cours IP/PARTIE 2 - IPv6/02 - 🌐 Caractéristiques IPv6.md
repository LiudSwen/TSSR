

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

## 🔷 Structure de l'en-tête IPv6 simplifiée

### Vue d'ensemble

L'en-tête IPv6 a été entièrement repensé pour être plus simple et plus efficace que son prédécesseur IPv4. Alors que l'en-tête IPv4 contient entre 12 et 14 champs (avec options), **l'en-tête IPv6 ne contient que 8 champs obligatoires** pour une taille fixe de **40 octets**.

> [!info] Pourquoi c'est important Cette simplification permet aux routeurs de traiter les paquets plus rapidement car :
> 
> - La taille fixe élimine le besoin de calculer la longueur de l'en-tête
> - Moins de champs = moins de vérifications à effectuer
> - Les fonctions optionnelles sont déplacées dans des en-têtes d'extension séparés

### Structure détaillée de l'en-tête IPv6

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version| Traffic Class |           Flow Label                  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Payload Length        |  Next Header  |   Hop Limit   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                                                               +
|                                                               |
+                         Source Address                        +
|                                                               |
+                                                               +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                                                               +
|                                                               |
+                      Destination Address                      +
|                                                               |
+                                                               +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

### Les 8 champs de l'en-tête IPv6

|Champ|Taille|Description|
|---|---|---|
|**Version**|4 bits|Toujours `6` pour IPv6|
|**Traffic Class**|8 bits|Équivalent du champ ToS en IPv4, utilisé pour la QoS (Quality of Service)|
|**Flow Label**|20 bits|Identifie les flux nécessitant un traitement spécial (nouveau en IPv6)|
|**Payload Length**|16 bits|Longueur des données après l'en-tête (max 65 535 octets)|
|**Next Header**|8 bits|Indique le type d'en-tête suivant (extension ou protocole de couche supérieure)|
|**Hop Limit**|8 bits|Équivalent du TTL en IPv4, décrémenter à chaque saut|
|**Source Address**|128 bits|Adresse IPv6 source|
|**Destination Address**|128 bits|Adresse IPv6 destination|

> [!example] Exemple de capture
> 
> ```
> Version: 6
> Traffic Class: 0x00 (DSCP: CS0, ECN: Not-ECT)
> Flow Label: 0x00000
> Payload Length: 32 octets
> Next Header: TCP (6)
> Hop Limit: 64
> Source: 2001:db8::1
> Destination: 2001:db8::2
> ```

### Comparaison IPv4 vs IPv6

|Caractéristique|IPv4|IPv6|
|---|---|---|
|Taille de l'en-tête|20-60 octets (variable)|40 octets (fixe)|
|Nombre de champs|12-14|8|
|Checksum|Oui (vérifié à chaque routeur)|Non (supprimé)|
|Options|Dans l'en-tête principal|En-têtes d'extension séparés|
|Fragmentation|Routeurs et source|Source uniquement|

> [!tip] Astuce performance La suppression du checksum de l'en-tête IPv6 améliore les performances des routeurs car ils n'ont plus besoin de recalculer ce champ à chaque saut (le TTL/Hop Limit change, donc le checksum devait être recalculé en IPv4).

### Champs supprimés par rapport à IPv4

Ces champs IPv4 ont été **supprimés** en IPv6 :

- **Header Length (IHL)** : inutile car la taille est fixe à 40 octets
- **Identification, Flags, Fragment Offset** : déplacés dans l'en-tête d'extension Fragment
- **Header Checksum** : supprimé pour améliorer les performances
- **Options** : remplacées par les en-têtes d'extension

> [!warning] Piège courant Ne confondez pas "Payload Length" avec "Total Length" d'IPv4 :
> 
> - IPv4 Total Length = en-tête + données
> - IPv6 Payload Length = données uniquement (sans l'en-tête de 40 octets)

---

## 🔗 En-têtes d'extension

### Concept fondamental

Les **en-têtes d'extension** (Extension Headers) sont l'une des innovations majeures d'IPv6. Au lieu d'inclure toutes les fonctionnalités optionnelles dans l'en-tête principal, IPv6 utilise une architecture modulaire où chaque fonction optionnelle est implémentée dans un en-tête séparé.

> [!info] Pourquoi c'est important Cette approche permet :
> 
> - De garder l'en-tête principal simple et rapide à traiter
> - D'ajouter des fonctionnalités uniquement quand nécessaire
> - D'étendre le protocole sans modifier l'en-tête de base
> - Aux routeurs d'ignorer les en-têtes non pertinents

### Structure en chaîne

Les en-têtes d'extension forment une **chaîne** grâce au champ "Next Header" :

```
+----------+    +----------+    +----------+    +----------+
| En-tête  | -> | En-tête  | -> | En-tête  | -> | Données  |
| IPv6     |    | Ext. 1   |    | Ext. 2   |    | (TCP)    |
+----------+    +----------+    +----------+    +----------+
Next Hdr=43     Next Hdr=60     Next Hdr=6      
(Routing)       (Dest Opt)      (TCP)
```

> [!example] Exemple de chaînage
> 
> ```
> IPv6 Header
>   Next Header: 43 (Routing Header)
>   
> Routing Header
>   Next Header: 60 (Destination Options)
>   
> Destination Options Header
>   Next Header: 6 (TCP)
>   
> TCP Segment
> ```

### Types d'en-têtes d'extension

IPv6 définit 6 types principaux d'en-têtes d'extension :

|Type|Valeur|Nom|Usage|
|---|---|---|---|
|0|Hop-by-Hop Options|Options traitées par chaque routeur||
|43|Routing|Spécifier un chemin de routage||
|44|Fragment|Informations de fragmentation||
|50|ESP|Encapsulating Security Payload (IPSec)||
|51|AH|Authentication Header (IPSec)||
|60|Destination Options|Options pour le destinataire final||

> [!warning] Ordre obligatoire Quand plusieurs en-têtes d'extension sont présents, ils DOIVENT apparaître dans cet ordre spécifique (RFC 8200) :
> 
> 1. IPv6 Header
> 2. Hop-by-Hop Options
> 3. Destination Options (pour routeurs intermédiaires)
> 4. Routing
> 5. Fragment
> 6. Authentication Header
> 7. Encapsulating Security Payload
> 8. Destination Options (pour destination finale)
> 9. Protocole de couche supérieure (TCP, UDP, ICMPv6...)

### Détail des principaux en-têtes d'extension

#### 1. Hop-by-Hop Options (Type 0)

Contient des options qui doivent être examinées par **chaque routeur** sur le chemin.

```
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Next Header  |  Hdr Ext Len  |                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               +
|                                                               |
.                           Options                             .
.                                                               .
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

> [!example] Utilisation typique : Router Alert L'option Router Alert (Type 5) indique aux routeurs qu'ils doivent examiner le paquet en détail. Utilisé par MLD (Multicast Listener Discovery) et RSVP.

> [!warning] Impact sur les performances Cet en-tête ralentit le traitement car chaque routeur doit l'examiner. À utiliser avec parcimonie.

#### 2. Routing Header (Type 43)

Permet à la source de spécifier une liste de routeurs par lesquels le paquet doit passer.

```
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Next Header  | Hdr Ext Len   | Routing Type  | Segments Left |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
.                       Type-specific data                      .
.                                                               .
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

- **Segments Left** : nombre de segments restants avant la destination finale
- **Routing Type** : type de routage (Type 0 obsolète pour raisons de sécurité)

> [!warning] Sécurité Le Routing Header Type 0 est obsolète (RFC 5095) car il permettait des attaques par amplification. Les routeurs modernes le rejettent.

#### 3. Fragment Header (Type 44)

Utilisé uniquement par la **source** pour fragmenter les paquets trop grands.

```
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Next Header  |   Reserved    |      Fragment Offset    |Res|M|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Identification                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

- **Fragment Offset** : position du fragment dans le paquet original (unités de 8 octets)
- **M Flag** : More Fragments (1 = plus de fragments, 0 = dernier fragment)
- **Identification** : identifie tous les fragments d'un même paquet original

> [!tip] Astuce Pour éviter la fragmentation, utilisez Path MTU Discovery (PMTUD) qui découvre la MTU minimale sur le chemin.

#### 4. Destination Options (Type 60)

Contient des options destinées uniquement au **destinataire final** du paquet.

```
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Next Header  |  Hdr Ext Len  |                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               +
|                                                               |
.                           Options                             .
.                                                               .
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

> [!info] Note Cet en-tête peut apparaître **deux fois** dans un paquet :
> 
> - Une fois avant le Routing Header (pour routeurs intermédiaires)
> - Une fois après (pour destination finale uniquement)

### Traitement par les routeurs

Comportement des routeurs face aux en-têtes d'extension :

|En-tête|Traitement par routeurs intermédiaires|
|---|---|
|Hop-by-Hop|✅ DOIT examiner|
|Routing|✅ DOIT examiner|
|Fragment|❌ Ignore (sauf si reassembly nécessaire)|
|Destination Options (avant Routing)|✅ DOIT examiner|
|Destination Options (après)|❌ Ignore|
|AH/ESP|❌ Ignore (traité en bout de chaîne IPSec)|

> [!tip] Optimisation Les routeurs modernes peuvent traiter les paquets sans en-têtes d'extension en "fast path" (traitement matériel rapide), mais doivent basculer en "slow path" (traitement logiciel) quand des en-têtes d'extension sont présents.

### Pièges courants

> [!warning] Problèmes de compatibilité
> 
> - Certains firewalls et routeurs anciens bloquent ou suppriment les paquets avec en-têtes d'extension
> - Peut causer des problèmes de connectivité (le paquet est silencieusement jeté)
> - Solutions : éviter les en-têtes d'extension quand possible, ou utiliser des tunnels

> [!warning] Limitation de taille La combinaison en-tête IPv6 + en-têtes d'extension ne doit pas dépasser la MTU du premier lien (généralement 1500 octets pour Ethernet). Au-delà, la source doit fragmenter.

---

## 📡 Absence de broadcast

### Concept fondamental

IPv6 a **complètement éliminé** le concept de broadcast présent en IPv4. À la place, IPv6 utilise exclusivement le **multicast** pour communiquer avec plusieurs destinataires simultanément.

> [!info] Pourquoi ce changement ? Le broadcast IPv4 posait plusieurs problèmes :
> 
> - **Performance** : tous les hôtes du réseau devaient traiter chaque paquet broadcast, même s'ils n'étaient pas concernés
> - **Scalabilité** : dans un grand réseau, le broadcast générait une charge excessive
> - **Sécurité** : le broadcast facilitait certaines attaques (scan de réseau, DoS)
> - **Inefficacité** : impossible de cibler un sous-groupe spécifique d'hôtes

### Comparaison IPv4 vs IPv6

|Besoin|IPv4|IPv6|
|---|---|---|
|Communiquer avec tous les hôtes du lien local|Broadcast (255.255.255.255)|Multicast all-nodes (ff02::1)|
|Communiquer avec tous les routeurs|Broadcast + filtrage|Multicast all-routers (ff02::2)|
|Résolution d'adresse MAC|ARP broadcast|NDP multicast (Solicited-node)|
|Découverte de services|Broadcast|Multicast spécifique|

### Adresses multicast de remplacement

IPv6 définit des adresses multicast spéciales pour remplacer les fonctions du broadcast :

#### Adresses multicast bien connues

|Adresse|Portée|Usage|
|---|---|---|
|**ff02::1**|Link-local|Tous les nœuds du lien (équivalent broadcast)|
|**ff02::2**|Link-local|Tous les routeurs du lien|
|**ff02::5**|Link-local|Tous les routeurs OSPF|
|**ff02::6**|Link-local|Tous les routeurs OSPF designated|
|**ff02::9**|Link-local|Tous les routeurs RIP|
|**ff02::a**|Link-local|Tous les routeurs EIGRP|
|**ff02::1:2**|Link-local|Tous les serveurs DHCP|

> [!example] Exemple : Ping vers tous les hôtes En IPv4 (broadcast) :
> 
> ```bash
> ping 192.168.1.255  # Broadcast sur le réseau
> ```
> 
> En IPv6 (multicast) :
> 
> ```bash
> ping6 ff02::1%eth0  # Multicast vers tous les nœuds
> # Le %eth0 précise l'interface (obligatoire pour link-local)
> ```

### Solicited-Node Multicast : le remplacement intelligent d'ARP

L'une des innovations majeures est l'adresse **Solicited-Node Multicast** qui remplace l'ARP broadcast de manière beaucoup plus efficace.

#### Formation de l'adresse Solicited-Node

Pour chaque adresse unicast IPv6 qu'un hôte possède, il rejoint automatiquement un groupe multicast solicited-node calculé ainsi :

```
Adresse solicited-node = ff02::1:ff + (24 derniers bits de l'adresse unicast)
```

> [!example] Exemple de calcul Si l'adresse IPv6 est : `2001:db8::abcd:ef12:3456:7890`
> 
> Les 24 derniers bits sont : `56:7890` (6 chiffres hexadécimaux = 24 bits)
> 
> L'adresse solicited-node sera : `ff02::1:ff56:7890`

#### Avantage par rapport au broadcast ARP

```
IPv4 - Résolution ARP (BROADCAST) :
┌─────────┐                                    ┌─────────┐
│ Hôte A  │ ───────────────────────────────> │ Hôte B  │
└─────────┘    "Qui a l'IP X.X.X.X ?"         └─────────┘
     │                                              │
     │ BROADCAST vers TOUS                          │
     ↓                                              ↓
┌─────────┐                                    ┌─────────┐
│ Hôte C  │ ← Doit traiter (CPU interrompu)   │ Hôte D  │
└─────────┘                                    └─────────┘
     ↓                                              ↓
   [...] Tous les hôtes sont impactés


IPv6 - Neighbor Discovery (MULTICAST) :
┌─────────┐                                    ┌─────────┐
│ Hôte A  │ ──────────────────────────────> │ Hôte B  │
└─────────┘   Multicast vers ff02::1:ffXX    └─────────┘
     │        (seulement hôtes concernés)         │
     │                                            │
     │                                            ↓
┌─────────┐                                    Reçoit 
│ Hôte C  │ ← Carte réseau filtre, CPU        (membre du
└─────────┘   non sollicité                    groupe)
     │                                              
   Ignoré au niveau matériel
```

> [!tip] Avantage performance Avec le solicited-node multicast :
> 
> - Seuls les hôtes possédant les 24 derniers bits identiques écoutent
> - Les autres cartes réseau filtrent au niveau matériel (pas d'interruption CPU)
> - Probabilité de collision : 1/16 777 216 (2^24)

### Impact sur les protocoles réseau

#### 1. DHCP devient DHCPv6

```bash
# IPv4 - DHCP Discover (broadcast)
Src: 0.0.0.0
Dst: 255.255.255.255  # Broadcast

# IPv6 - DHCPv6 Solicit (multicast)
Src: fe80::client
Dst: ff02::1:2  # Multicast "All DHCP servers"
```

#### 2. Découverte de routeur

```bash
# IPv4 - ICMP Router Discovery (broadcast ou multicast)
Dst: 224.0.0.1 ou broadcast

# IPv6 - Router Solicitation (multicast)
Dst: ff02::2  # Multicast "All routers"
```

#### 3. Neighbor Discovery Protocol (NDP)

Le NDP remplace plusieurs fonctions IPv4 :

|Fonction|IPv4|IPv6 (NDP)|
|---|---|---|
|Résolution adresse MAC|ARP (broadcast)|Neighbor Solicitation (multicast)|
|Détection d'adresse dupliquée|ARP gratuit (broadcast)|DAD avec NS (multicast)|
|Découverte de routeurs|ICMP Router Discovery|Router Advertisement (multicast)|
|Redirection|ICMP Redirect|NDP Redirect|

> [!example] Exemple complet de résolution d'adresse Hôte A (2001:db8::1) veut communiquer avec Hôte B (2001:db8::2)
> 
> **Étape 1** - Neighbor Solicitation :
> 
> ```
> Src: 2001:db8::1
> Dst: ff02::1:ff00:2  # Solicited-node de ::2
> Type: ICMPv6 Neighbor Solicitation
> Target: 2001:db8::2
> ```
> 
> **Étape 2** - Neighbor Advertisement :
> 
> ```
> Src: 2001:db8::2
> Dst: 2001:db8::1  # Unicast vers le demandeur
> Type: ICMPv6 Neighbor Advertisement
> Target: 2001:db8::2
> MAC: aa:bb:cc:dd:ee:ff
> ```

### Bénéfices de l'absence de broadcast

> [!tip] Avantages multiples
> 
> 1. **Performance** : les hôtes non concernés ne sont pas interrompus
> 2. **Scalabilité** : fonctionne mieux dans les grands réseaux
> 3. **Économie d'énergie** : les appareils en veille profonde ne sont pas réveillés inutilement
> 4. **Sécurité** : plus difficile de scanner un réseau (pas de ping broadcast)
> 5. **Flexibilité** : possibilité de créer des groupes multicast personnalisés

### Pièges courants

> [!warning] Outils de diagnostic Certains outils réseau habitués au broadcast IPv4 ne fonctionnent plus en IPv6 :
> 
> ```bash
> # IPv4 - Ping broadcast pour découvrir les hôtes
> ping 192.168.1.255  # Répond tous les hôtes
> 
> # IPv6 - Équivalent (mais comportement différent)
> ping6 ff02::1%eth0  # Certains hôtes peuvent ne pas répondre
> # (Windows désactive la réponse par défaut pour raisons de sécurité)
> ```

> [!warning] Configuration firewall Les règles firewall doivent autoriser le multicast nécessaire :
> 
> ```bash
> # Autoriser NDP (indispensable)
> ip6tables -A INPUT -p ipv6-icmp --icmpv6-type neighbor-solicitation -j ACCEPT
> ip6tables -A INPUT -p ipv6-icmp --icmpv6-type neighbor-advertisement -j ACCEPT
> ip6tables -A INPUT -p ipv6-icmp --icmpv6-type router-advertisement -j ACCEPT
> 
> # Autoriser multicast all-nodes (optionnel selon besoins)
> ip6tables -A INPUT -d ff02::1 -j ACCEPT
> ```

---

## ✂️ Fragmentation par la source uniquement

### Concept fondamental

En IPv6, **seul l'hôte source peut fragmenter** les paquets. Les routeurs intermédiaires n'ont **jamais** le droit de fragmenter un paquet, contrairement à IPv4 où n'importe quel routeur pouvait le faire.

> [!info] Pourquoi ce changement ? La fragmentation par les routeurs en IPv4 posait plusieurs problèmes :
> 
> - **Performance** : la fragmentation consomme beaucoup de ressources CPU sur les routeurs
> - **Complexité** : gestion difficile des fragments dans les firewalls et NAT
> - **Attaques** : les fragments pouvaient être utilisés pour contourner les règles de sécurité
> - **Perte de paquets** : si un seul fragment est perdu, tout le paquet doit être retransmis

### Comparaison IPv4 vs IPv6

|Aspect|IPv4|IPv6|
|---|---|---|
|Qui peut fragmenter ?|Source ET routeurs|Source UNIQUEMENT|
|En-tête de fragmentation|Dans l'en-tête IP principal|En-tête d'extension séparé (Type 44)|
|MTU minimale|68 octets|1280 octets|
|Réaction si paquet trop grand|Routeur fragmente|Routeur envoie ICMPv6 "Packet Too Big"|
|Flag "Don't Fragment"|Optionnel (DF)|Implicite (toujours actif)|

### Processus de fragmentation IPv6

#### Schéma du processus

```
┌──────────────┐
│   Source     │
│  Hôte A      │
└──────┬───────┘
       │ 1. Paquet de 2000 octets
       │    MTU locale = 1500
       ↓
  Fragmentation
  par la source
       │
       ├──> Fragment 1 (1280 octets)
       ├──> Fragment 2 (720 octets)
       │
       ↓
┌──────────────┐
│  Routeur R1  │  MTU = 1500
└──────┬───────┘  ✅ Transmet sans modifier
       │
       ↓
┌──────────────┐
│  Routeur R2  │  MTU = 1280
└──────┬───────┘  ❌ Ne peut PAS fragmenter !
       │          Si paquet > 1280 :
       │          Envoie ICMPv6 Packet Too Big
       ↓
┌──────────────┐
│ Destination  │
│   Hôte B     │  Réassemble les fragments
└──────────────┘
```

### MTU minimale : 1280 octets

IPv6 garantit qu'**aucun lien ne peut avoir une MTU inférieure à 1280 octets**.

> [!info] Pourquoi 1280 ?
> 
> - C'est suffisant pour la plupart des paquets de contrôle et données
> - Permet de transporter un en-tête IPv6 (40) + en-tête Fragment (8) + 1232 octets de données
> - Évite la fragmentation excessive sur les petits liens

> [!warning] Conséquence importante Si un lien a une MTU < 1280 octets, il DOIT implémenter la **fragmentation et réassemblage de couche liaison** pour donner l'illusion d'une MTU de 1280 au niveau IPv6.

### En-tête d'extension Fragment

Quand la source doit fragmenter, elle ajoute un en-tête d'extension Fragment (Type 44) :

```
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Next Header  |   Reserved    |      Fragment Offset    |Res|M|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Identification                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

**Champs** :

- **Next Header** (8 bits) : type de l'en-tête suivant
- **Reserved** (8 bits) : réservé, mis à 0
- **Fragment Offset** (13 bits) : position du fragment (multiples de 8 octets)
- **Res** (2 bits) : réservé, mis à 0
- **M Flag** (1 bit) : More Fragments (1 = plus de fragments suivent, 0 = dernier)
- **Identification** (32 bits) : identifiant unique du paquet fragmenté

> [!example] Exemple de fragmentation Paquet original de 3000 octets à envoyer avec MTU = 1500
> 
> **Fragment 1** :
> 
> ```
> IPv6 Header (40 octets)
> Fragment Header (8 octets)
>   Next Header: TCP (6)
>   Fragment Offset: 0
>   M Flag: 1 (plus de fragments)
>   Identification: 0x12345678
> Payload: 1452 octets de données TCP
> Total: 1500 octets
> ```
> 
> **Fragment 2** :
> 
> ```
> IPv6 Header (40 octets)
> Fragment Header (8 octets)
>   Next Header: TCP (6)
>   Fragment Offset: 181 (1452/8 = 181.5 arrondi à 181)
>   M Flag: 0 (dernier fragment)
>   Identification: 0x12345678
> Payload: 1548 octets restants
> Total: 1596 octets
> ```

### Path MTU Discovery (PMTUD)

Pour éviter la fragmentation, IPv6 utilise obligatoirement le **Path MTU Discovery** qui découvre la MTU minimale sur le chemin entre source et destination.

#### Fonctionnement de PMTUD

```
┌──────────┐                                              ┌──────────┐
│ Source   │                                              │  Dest    │
│  MTU:    │                                              │  MTU:    │
│  1500    │                                              │  1500    │
└────┬─────┘                                              └────┬─────┘
     │                                                         │
     │ 1. Envoie paquet de 1500 octets                        │
     ├──────────────────────────────────>                     │
     │                                   ┌──────────┐         │
     │                                   │ Routeur  │         │
     │                                   │ MTU: 1280│         │
     │                                   └────┬─────┘         │
     │                                        │               │
     │ 2. Paquet trop grand (1500 > 1280)    │               │
     │    Routeur drop le paquet              │               │
     │                                        │               │
     │ 3. ICMPv6 Packet Too Big              │               │
     │    MTU = 1280                          │               │
     │ <──────────────────────────────────────┘               │
     │                                                        │
     │ 4. Source met en cache: MTU vers dest = 1280         │
     │                                                        │
     │ 5. Renvoie avec paquets de 1280 octets max           │
     ├──────────────────────────────────────────────────────>│
     │                                                        │
```

> [!tip] Optimisation La source conserve la MTU découverte en cache pendant 10 minutes minimum. Si le chemin change, un nouveau ICMPv6 "Packet Too Big" réinitialise la découverte.

#### Message ICMPv6 Packet Too Big

```
Type: 2 (Packet Too Big)
Code: 0
MTU: 1280 (MTU du lien qui a rejeté le paquet)
+ Autant du paquet original que possible
```

> [!example] Exemple avec tcpdump
> 
> ```bash
> # Paquet original trop grand
> 2001:db8::1 > 2001:db8::2: ICMP6, echo request, length 2000
> 
> # Réponse du routeur
> 2001:db8::254 > 2001:db8::1: ICMP6, packet too big, mtu 1280
> 
> # Retransmission avec bonne taille
> 2001:db8::1 > 2001:db8::2: ICMP6, echo request, length 1280
> ```

### Comportement des routeurs

Quand un routeur IPv6 reçoit un paquet trop grand pour le lien suivant :

1. **Drop le paquet** (ne fragmente jamais)
2. **Envoie un ICMPv6 Type 2** "Packet Too Big" à la source
3. **Inclut la MTU** du lien problématique dans le message
4. **Log l'événement** (optionnel, selon configuration)

> [!warning] Problème de firewall Si les messages ICMPv6 "Packet Too Big" sont bloqués par un firewall, le PMTUD échoue et la connexion peut rester bloquée (phénomène appelé "PMTUD black hole").
> 
> **Solution** : Toujours autoriser les ICMPv6 Type 2 dans les firewalls :
> 
> ```bash
> ip6tables -A INPUT -p ipv6-icmp --icmpv6-type packet-too-big -j ACCEPT
> ip6tables -A OUTPUT -p ipv6-icmp --icmpv6-type packet-too-big -j ACCEPT
> ip6tables -A FORWARD -p ipv6-icmp --icmpv6-type packet-too-big -j ACCEPT
> ```

### Réassemblage des fragments

Le **destinataire final** est responsable du réassemblage :

1. **Réception** : stocke les fragments dans un buffer
2. **Identification** : utilise le champ "Identification" pour grouper les fragments
3. **Ordonnancement** : utilise "Fragment Offset" pour ordonner
4. **Timeout** : 60 secondes maximum pour recevoir tous les fragments
5. **Reconstruction** : réassemble le paquet original si tous les fragments sont reçus
6. **Échec** : si timeout ou fragments manquants, envoie ICMPv6 "Fragment reassembly time exceeded"

> [!example] États des fragments en mémoire
> 
> ```
> Identification: 0x12345678
> Fragment 0 (offset 0, M=1): ✅ Reçu
> Fragment 1 (offset 181, M=1): ❌ Manquant
> Fragment 2 (offset 362, M=0): ✅ Reçu
> 
> Timer: 45 secondes écoulées / 60
> État: En attente du fragment 1
> ```

### Pièges courants

> [!warning] Fragmentation et NAT La fragmentation pose des problèmes avec les firewalls stateful et NAT :
> 
> - Le **premier fragment** contient les ports TCP/UDP
> - Les **fragments suivants** n'ont pas ces informations
> - Le firewall peut bloquer les fragments suivants s'il ne fait pas de suivi d'état de fragmentation

> [!warning] Attaques par fragmentation Les fragments peuvent être utilisés pour des attaques :
> 
> - **Fragment overlap** : fragments qui se chevauchent pour exploiter des bugs de réassemblage
> - **Tiny fragments** : fragments de 8 octets pour saturer les buffers
> - **Timeout abuse** : envoi de premiers fragments sans les suivants pour épuiser la mémoire
> 
> **Protection** : limiter le nombre de fragments simultanés acceptés par destination

> [!tip] Bonnes pratiques
> 
> 1. **Éviter la fragmentation** autant que possible en utilisant PMTUD
> 2. **Utiliser TCP** qui gère automatiquement la MSS (Maximum Segment Size)
> 3. **Pour UDP** : limiter la taille des datagrammes à 1280 octets
> 4. **Autoriser ICMPv6 Type 2** dans tous les firewalls
> 5. **Monitorer** les messages "Packet Too Big" pour détecter les problèmes de MTU

### Comparaison pratique : envoi de gros fichier

**IPv4** :

```
Source envoie 10 000 octets
  ↓
Routeur 1 fragmente en 7 paquets (MTU 1500)
  ↓
Routeur 2 refragmente en 40 paquets (MTU 576)
  ↓
Destination réassemble 40 fragments
= Overhead énorme, performance dégradée
```

**IPv6** :

```
Source découvre MTU = 576 via PMTUD
  ↓
Source fragmente directement en paquets de 576 octets
  ↓
Routeurs transmettent sans modification
  ↓
Destination réassemble
= Fragmentation optimale dès le départ
```

---

## 🔒 IPSec intégré

### Concept fondamental

IPv6 a été conçu dès l'origine avec **IPSec intégré** comme partie obligatoire du protocole. IPSec (Internet Protocol Security) fournit l'authentification, l'intégrité et la confidentialité au niveau de la couche réseau.

> [!info] Pourquoi c'est important Avec IPSec intégré :
> 
> - **Sécurité native** : chaque paquet peut être authentifié et/ou chiffré
> - **Transparence** : les applications n'ont pas besoin de gérer la sécurité
> - **Interopérabilité** : standard universel pour les VPN et connexions sécurisées
> - **Protection de bout en bout** : de la source à la destination, indépendamment des réseaux traversés

> [!warning] Clarification importante Bien qu'IPSec soit défini comme **obligatoire** dans les premières spécifications IPv6 (RFC 2460), la RFC 6434 a assoupli cette exigence en le rendant **recommandé mais non obligatoire**. Cependant, IPSec reste une fonctionnalité centrale et fortement intégrée à IPv6.

### Les deux protocoles IPSec en IPv6

IPSec utilise deux protocoles principaux, implémentés comme **en-têtes d'extension** en IPv6 :

#### 1. Authentication Header (AH) - Type 51

Fournit l'**authentification** et l'**intégrité** des données, mais **pas de confidentialité**.

```
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
| Next Header   | Payload Len   |          RESERVED             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                 Security Parameters Index (SPI)               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Sequence Number Field                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                Authentication Data (variable)                 |
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

**Caractéristiques AH** :

- ✅ Authentifie l'expéditeur
- ✅ Garantit l'intégrité (détecte les modifications)
- ✅ Protège contre le replay (avec numéro de séquence)
- ✅ Protège l'en-tête IPv6 complet (sauf champs mutables)
- ❌ Ne chiffre pas les données (tout reste lisible)

> [!example] Usage typique AH Utilisé quand on veut garantir l'authenticité et l'intégrité sans masquer le contenu :
> 
> - Communications entre systèmes de confiance
> - Environnements où le chiffrement est interdit ou non nécessaire
> - Signature de paquets de contrôle

#### 2. Encapsulating Security Payload (ESP) - Type 50

Fournit la **confidentialité** (chiffrement), l'**authentification** et l'**intégrité**.

```
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|               Security Parameters Index (SPI)                 |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                      Sequence Number                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Payload Data (variable)                    |
~                                                               ~
|                                                               |
+               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|               |     Padding (0-255 octets)                    |
+-+-+-+-+-+-+-+-+               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                               |  Pad Length   | Next Header   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Integrity Check Value-ICV   (variable)                |
~                                                               ~
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

**Caractéristiques ESP** :

- ✅ Chiffre les données (confidentialité)
- ✅ Authentifie l'expéditeur
- ✅ Garantit l'intégrité
- ✅ Protège contre le replay
- ⚠️ Ne protège PAS l'en-tête IPv6 externe (visible en clair)

> [!tip] ESP est le plus utilisé Dans la pratique, ESP est largement préféré à AH car :
> 
> - Il offre toutes les fonctions d'AH + le chiffrement
> - Il est plus flexible (authentification optionnelle)
> - Il fonctionne mieux avec NAT
> - La plupart des cas d'usage nécessitent la confidentialité

### Modes d'opération IPSec

IPSec peut fonctionner en deux modes :

#### Mode Transport

Protège uniquement la **charge utile** (payload), l'en-tête IPv6 reste en clair.

```
AVANT IPSec:
+------------+-------------------+
| IPv6 Hdr   | TCP/UDP + Données |
+------------+-------------------+

APRÈS IPSec Transport (ESP):
+------------+------------+------------------------+---------+
| IPv6 Hdr   | ESP Header | TCP/UDP + Données      | ESP     |
| (original) |            | (CHIFFRÉS)             | Trailer |
+------------+------------+------------------------+---------+
                          ↑                         ↑
                          Authentifié et chiffré
```

**Usage** : communication de bout en bout entre deux hôtes

> [!example] Cas d'usage Transport
> 
> - VPN client-à-site (road warrior)
> - Communication sécurisée entre deux serveurs
> - Protection d'un protocole spécifique (exemple : sécuriser SSH)

#### Mode Tunnel

Encapsule **tout le paquet IPv6 original** dans un nouveau paquet IPv6.

```
AVANT IPSec:
+------------+-------------------+
| IPv6 Hdr   | TCP/UDP + Données |
+------------+-------------------+

APRÈS IPSec Tunnel (ESP):
+-------------+------------+--------------------------------+---------+
| Nouvel      | ESP Header | IPv6 Hdr | TCP/UDP + Données | ESP     |
| IPv6 Hdr    |            | original | (TOUT CHIFFRÉ)    | Trailer |
+-------------+------------+--------------------------------+---------+
                           ↑                                ↑
                           Authentifié et chiffré
```

**Usage** : VPN site-à-site, passerelles de sécurité

> [!example] Cas d'usage Tunnel
> 
> - VPN site-à-site entre deux réseaux d'entreprise
> - Tunnels entre routeurs/firewalls
> - Masquage de la topologie réseau interne

### Comparaison AH vs ESP

|Caractéristique|AH|ESP|
|---|---|---|
|Authentification|✅ Oui|✅ Oui (optionnel)|
|Intégrité|✅ Oui|✅ Oui|
|Confidentialité|❌ Non|✅ Oui|
|Protège en-tête IPv6|✅ Oui|❌ Non (sauf mode tunnel)|
|Compatibilité NAT|❌ Problématique|✅ Meilleure (NAT-T)|
|Performance|Meilleure|Légèrement plus lent|
|Usage courant|Rare|✅ Standard|

### Algorithmes de chiffrement et authentification

IPv6/IPSec supporte de nombreux algorithmes :

#### Chiffrement (pour ESP)

|Algorithme|Taille clé|Sécurité|Performance|
|---|---|---|---|
|**AES-128**|128 bits|Excellent|Très rapide|
|**AES-256**|256 bits|Excellent|Rapide|
|**ChaCha20**|256 bits|Excellent|Très rapide (mobile)|
|3DES|168 bits|⚠️ Obsolète|Lent|

#### Authentification (pour AH et ESP)

|Algorithme|Taille|Sécurité|Performance|
|---|---|---|---|
|**HMAC-SHA256**|256 bits|Excellent|Rapide|
|**HMAC-SHA512**|512 bits|Excellent|Moyen|
|HMAC-SHA1|160 bits|⚠️ Déconseillé|Rapide|
|HMAC-MD5|128 bits|❌ Obsolète|Rapide|

> [!tip] Recommandation actuelle (2024) Configuration recommandée :
> 
> - **Chiffrement** : AES-256-GCM ou ChaCha20-Poly1305
> - **Authentification** : SHA-256 ou SHA-384
> - **Échange de clés** : IKEv2 avec groupes DH 14+ (2048 bits minimum)

### Security Association (SA)

Pour utiliser IPSec, les deux parties doivent établir une **Security Association** (SA) qui définit :

- **SPI** (Security Parameters Index) : identifiant unique de la SA
- **Algorithmes** de chiffrement et authentification
- **Clés** cryptographiques
- **Mode** (transport ou tunnel)
- **Durée de vie** de la SA

> [!info] Base de données IPSec Chaque nœud IPv6 avec IPSec maintient deux bases :
> 
> - **SAD** (Security Association Database) : les SA actives
> - **SPD** (Security Policy Database) : les règles de sécurité

### Établissement des SA : IKE

Le protocole **IKE** (Internet Key Exchange) établit automatiquement les SA.

#### IKEv2 - Version recommandée

```
Phase 1 - IKE_SA_INIT :
Initiateur                               Répondeur
    |                                         |
    |  HDR, SAi1, KEi, Ni                    |
    |──────────────────────────────────────>│
    |                                         │
    |            HDR, SAr1, KEr, Nr          │
    │<──────────────────────────────────────│
    
Phase 2 - IKE_AUTH :
    │  HDR, SK {IDi, AUTH, SAi2, TSi, TSr}  │
    │──────────────────────────────────────>│
    │                                         │
    │  HDR, SK {IDr, AUTH, SAr2, TSi, TSr}  │
    │<──────────────────────────────────────│
    
= SA établies, trafic sécurisé
```

**Avantages IKEv2** :

- 4 messages seulement (vs 9 pour IKEv1)
- Détection de NAT intégrée
- MOBIKE pour mobilité
- Authentification multiple (certificats, PSK, EAP)

> [!example] Configuration strongSwan (IKEv2)
> 
> ```bash
> # /etc/ipsec.conf
> conn ipv6-tunnel
>     keyexchange=ikev2
>     left=2001:db8::1
>     leftsubnet=2001:db8:1::/64
>     right=2001:db8::2
>     rightsubnet=2001:db8:2::/64
>     ike=aes256-sha256-modp2048!
>     esp=aes256gcm16-sha256!
>     type=tunnel
>     auto=start
> ```

### Intégration IPv6 native

Contrairement à IPv4 où IPSec est un ajout, en IPv6 :

1. **En-têtes d'extension** : AH et ESP sont des en-têtes d'extension natifs
2. **Ordre standardisé** : position définie dans la chaîne d'en-têtes
3. **Processing simplifié** : les routeurs savent gérer ces en-têtes
4. **Interopérabilité** : tous les OS modernes supportent IPSec/IPv6

> [!info] Ordre des en-têtes avec IPSec
> 
> ```
> IPv6 Header
>   ↓
> Hop-by-Hop Options (optionnel)
>   ↓
> Routing Header (optionnel)
>   ↓
> Fragment Header (optionnel)
>   ↓
> Authentication Header (AH) ← IPSec
>   ↓
> Encapsulating Security Payload (ESP) ← IPSec
>   ↓
> Destination Options (optionnel)
>   ↓
> Upper Layer (TCP, UDP, ICMPv6...)
> ```

### Applications pratiques

#### 1. VPN site-à-site

```
[Réseau A]──[Gateway A]═══IPSec Tunnel═══[Gateway B]──[Réseau B]
2001:db8:a::/48         2001:db8:b::/48

Configuration : Mode tunnel, ESP, AES-256-GCM
```

#### 2. VPN nomade (road warrior)

```
[Laptop]═══IPSec═══[VPN Gateway]───[Réseau entreprise]
  Mobile          2001:db8::gate    2001:db8:corp::/48

Configuration : Mode transport, ESP, IKEv2, EAP-TLS
```

#### 3. Sécurisation BGP

```
[Routeur A]═══IPSec═══[Routeur B]
              ↑
         BGP over IPSec
         
Configuration : Mode transport, AH ou ESP, certificats
```

### Performance et overhead

IPSec ajoute de l'overhead au paquet :

|Mode|En-tête|Taille overhead|
|---|---|---|
|**AH Transport**|AH Header|~24 octets|
|**ESP Transport**|ESP Header + Trailer|~50-60 octets|
|**ESP Tunnel**|Nouvel IPv6 + ESP|~90-100 octets|

> [!tip] Impact performance
> 
> - **Latence** : +1-5ms selon le chiffrement
> - **Débit** : -5-15% selon le hardware (avec accélération matérielle, impact minimal)
> - **CPU** : AES-NI sur CPU modernes = impact négligeable

### Pièges courants

> [!warning] MTU et IPSec IPSec ajoute de l'overhead, réduisant la MTU effective :
> 
> ```
> MTU Ethernet = 1500
> - IPv6 Header = 40
> - ESP overhead ≈ 50
> = MTU effective ≈ 1410 octets pour les données applicatives
> ```
> 
> **Solution** : Ajuster la MSS TCP ou utiliser des MTU jumbo frames

> [!warning] Firewall et IPSec Les firewalls doivent autoriser :
> 
> - **UDP 500** : IKE/ISAKMP
> - **UDP 4500** : NAT-Traversal (IPSec over UDP)
> - **Protocol 50** : ESP
> - **Protocol 51** : AH
> 
> ```bash
> ip6tables -A INPUT -p esp -j ACCEPT
> ip6tables -A INPUT -p ah -j ACCEPT
> ip6tables -A INPUT -p udp --dport 500 -j ACCEPT
> ip6tables -A INPUT -p udp --dport 4500 -j ACCEPT
> ```

> [!warning] NAT et IPSec
> 
> - **AH** : incompatible avec NAT (protège les adresses IP)
> - **ESP** : nécessite NAT-T (NAT Traversal) en mode transport
> - **Mode tunnel** : fonctionne mieux avec NAT

### Vérification d'IPSec actif

```bash
# Vérifier les SA actives
ip xfrm state

# Exemple de sortie
src 2001:db8::1 dst 2001:db8::2
	proto esp spi 0xc1234567 reqid 1 mode transport
	replay-window 32 
	auth-trunc hmac(sha256) 0x... 128
	enc cbc(aes) 0x...
	
# Vérifier les politiques
ip xfrm policy

# Statistiques IPSec
ip -s xfrm state
```

### Bonnes pratiques IPSec

> [!tip] Recommandations
> 
> 1. **Préférer ESP à AH** : plus flexible et compatible
> 2. **Utiliser IKEv2** : plus moderne et performant qu'IKEv1
> 3. **Chiffrement moderne** : AES-256-GCM ou ChaCha20-Poly1305
> 4. **Renouvellement automatique** : lifetime < 8 heures
> 5. **Perfect Forward Secrecy** : activer le rekey avec nouveaux DH
> 6. **Monitoring** : surveiller les SA expirées et erreurs
> 7. **MTU** : ajuster pour compenser l'overhead IPSec

---

## 📚 Récapitulatif

### Points clés à retenir

|Caractéristique|Détail|Avantage|
|---|---|---|
|**En-tête simplifié**|8 champs, 40 octets fixes|Performance des routeurs|
|**En-têtes d'extension**|Architecture modulaire|Flexibilité et extensibilité|
|**Pas de broadcast**|Multicast uniquement|Efficacité et scalabilité|
|**Fragmentation source**|Routeurs ne fragmentent jamais|Performance et sécurité|
|**IPSec intégré**|AH et ESP natifs|Sécurité de bout en bout|

### Tableau comparatif global IPv4 vs IPv6

|Aspect|IPv4|IPv6|
|---|---|---|
|Taille en-tête|20-60 octets (variable)|40 octets (fixe)|
|Checksum|Oui|Non|
|Fragmentation|Source + routeurs|Source uniquement|
|Broadcast|Oui|Non (multicast)|
|IPSec|Optionnel|Recommandé/intégré|
|Options|Dans en-tête|En-têtes d'extension|
|MTU minimale|68 octets|1280 octets|

### Implications pour l'administration réseau

> [!tip] Ce qu'il faut retenir pour l'administration
> 
> **Configuration** :
> 
> - Autoriser ICMPv6 Type 2 (Packet Too Big) dans les firewalls
> - Activer le multicast pour NDP, Router Advertisement, DHCPv6
> - Configurer IPSec pour les communications sensibles
> 
> **Monitoring** :
> 
> - Surveiller les messages "Packet Too Big" (problèmes MTU)
> - Vérifier les SA IPSec actives et leur renouvellement
> - Observer le trafic multicast (ne doit pas être excessif)
> 
> **Troubleshooting** :
> 
> - Problème de connectivité → vérifier MTU et PMTUD
> - Lenteur → vérifier si fragmentation excessive
> - Échec VPN → vérifier ports IKE et protocoles ESP/AH
> - NDP ne fonctionne pas → vérifier multicast et ICMPv6

---

_Ce cours couvre les caractéristiques techniques fondamentales d'IPv6. Ces concepts sont essentiels pour comprendre le fonctionnement du protocole et ses différences avec IPv4._