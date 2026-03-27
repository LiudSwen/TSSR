

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

## 🎯 Introduction à IPv6

IPv6 (Internet Protocol version 6) est la nouvelle génération du protocole Internet, conçu pour remplacer IPv4. Avec l'épuisement des adresses IPv4, IPv6 offre un espace d'adressage considérablement élargi.

> [!info] Pourquoi IPv6 ?
> 
> - **Espace d'adressage immense** : 2^128 adresses (340 undécillions)
> - **Simplification du routage** : En-têtes optimisés
> - **Sécurité intégrée** : IPsec natif
> - **Auto-configuration** : SLAAC (Stateless Address Autoconfiguration)

---

## 🔢 Format hexadécimal

### Structure de base

Une adresse IPv6 est composée de **128 bits**, représentés en notation hexadécimale.

> [!example] Structure
> 
> ```
> xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx
> ```
> 
> - **8 groupes** de 16 bits chacun
> - Chaque groupe contient **4 chiffres hexadécimaux** (0-9, a-f)
> - Les groupes sont séparés par des **deux-points** `:`

### Exemple détaillé

```bash
2001:0db8:85a3:0000:0000:8a2e:0370:7334
│    │    │    │    │    │    │    │
└────┴────┴────┴────┴────┴────┴────┴──── 8 groupes de 16 bits
```

> [!tip] Astuce Contrairement à IPv4 qui utilise le décimal (base 10), IPv6 utilise l'hexadécimal (base 16) pour réduire la longueur de l'adresse écrite.

### Correspondance bits/hex

|Hexadécimal|Binaire|Décimal|
|---|---|---|
|0|0000|0|
|1|0001|1|
|a|1010|10|
|f|1111|15|

---

## ✂️ Règles de notation et compression

Pour simplifier l'écriture des adresses IPv6, plusieurs règles de compression existent.

### Règle 1 : Suppression des zéros initiaux

Les zéros au début de chaque groupe peuvent être omis.

> [!example] Exemples de compression des zéros initiaux
> 
> ```bash
> # Adresse complète
> 2001:0db8:0000:0042:0000:8a2e:0370:7334
> 
> # Zéros initiaux supprimés
> 2001:db8:0:42:0:8a2e:370:7334
> ```

> [!warning] Attention On ne peut supprimer que les zéros **initiaux** d'un groupe, pas les zéros de fin :
> 
> - `0042` → `42` ✅
> - `4200` → `4200` (pas de simplification possible) ❌

### Règle 2 : Compression des groupes de zéros consécutifs

Une séquence de groupes composés uniquement de zéros peut être remplacée par **deux deux-points** `::`.

> [!example] Compression de groupes de zéros
> 
> ```bash
> # Avant compression
> 2001:0db8:0000:0000:0000:0000:0000:0001
> 
> # Après suppression des zéros initiaux
> 2001:db8:0:0:0:0:0:1
> 
> # Après compression maximale
> 2001:db8::1
> ```

> [!warning] Règle critique La compression `::` ne peut être utilisée **qu'une seule fois** dans une adresse IPv6. Sinon, il serait impossible de déterminer le nombre de groupes de zéros compressés.
> 
> ```bash
> # ❌ INCORRECT
> 2001::db8::1
> 
> # ✅ CORRECT (choisir la plus longue séquence)
> 2001:0:0:0:db8:0:0:1 → 2001::db8:0:0:1
> ```

### Exemples de compression

|Adresse non compressée|Adresse compressée|Explication|
|---|---|---|
|`2001:0db8:0000:0000:0000:0000:0000:0001`|`2001:db8::1`|Suppression des zéros initiaux + compression|
|`fe80:0000:0000:0000:0204:61ff:fe9d:f156`|`fe80::204:61ff:fe9d:f156`|Compression au début|
|`ff02:0000:0000:0000:0000:0000:0000:0001`|`ff02::1`|Compression de 6 groupes de zéros|
|`0000:0000:0000:0000:0000:0000:0000:0001`|`::1`|Adresse de loopback|
|`0000:0000:0000:0000:0000:0000:0000:0000`|`::`|Adresse non spécifiée|

> [!tip] Bonne pratique Quand vous avez le choix, compressez toujours la **plus longue séquence** de zéros consécutifs pour obtenir l'adresse la plus courte possible.

### Notation avec préfixe

Comme en IPv4, on utilise la notation CIDR pour indiquer la longueur du préfixe réseau.

```bash
2001:db8:85a3::/64
│              │
│              └── Longueur du préfixe (64 bits)
└────────────────── Adresse réseau
```

> [!info] Standard courant
> 
> - **/64** : Préfixe réseau standard pour un segment
> - **/128** : Adresse d'hôte unique (équivalent à /32 en IPv4)
> - **/48** : Préfixe réseau pour une organisation

---

## 🎭 Types d'adresses

IPv6 définit trois types principaux d'adresses, contrairement à IPv4 qui en a deux (unicast et broadcast).

### Vue d'ensemble

|Type|Description|Utilisation|
|---|---|---|
|**Unicast**|Une interface unique|Communication point-à-point|
|**Multicast**|Groupe d'interfaces|Communication un-vers-plusieurs|
|**Anycast**|L'interface la plus proche|Redondance et load balancing|

> [!info] Différence avec IPv4 IPv6 **n'a pas d'adresse broadcast**. Cette fonctionnalité est remplacée par le multicast (par exemple, `ff02::1` pour tous les nœuds du lien local).

### Unicast

Une adresse unicast identifie **une seule interface**. Le paquet est délivré à cette interface spécifique.

```bash
2001:db8::1
│
└── Identifie une seule interface
```

**Cas d'usage** :

- Communication classique entre deux machines
- Navigation web, SSH, transfert de fichiers
- La majorité du trafic réseau

### Multicast

Une adresse multicast identifie **un groupe d'interfaces**. Le paquet est délivré à toutes les interfaces du groupe.

```bash
ff02::1
│
└── Tous les nœuds du lien local
```

> [!example] Adresses multicast courantes
> 
> - `ff02::1` : Tous les nœuds du lien local
> - `ff02::2` : Tous les routeurs du lien local
> - `ff02::1:2` : Tous les serveurs DHCP du lien local

**Cas d'usage** :

- Découverte de voisins (Neighbor Discovery)
- Protocoles de routage
- Diffusion de flux vidéo
- Remplace le broadcast IPv4

### Anycast

Une adresse anycast est assignée à **plusieurs interfaces** (généralement sur différents nœuds). Le paquet est délivré à **l'interface la plus proche** selon la métrique de routage.

```bash
2001:db8::1  ← Même adresse anycast
│
├── Serveur A (Paris)
├── Serveur B (Londres)
└── Serveur C (Berlin)
│
└── Le client se connecte automatiquement au serveur le plus proche
```

**Cas d'usage** :

- Serveurs DNS racines
- CDN (Content Delivery Network)
- Load balancing géographique
- Haute disponibilité

> [!warning] Particularité Les adresses anycast sont indiscernables des adresses unicast du point de vue de la syntaxe. C'est la **configuration du réseau** qui détermine qu'une adresse est anycast.

---

## 🏠 Adresses unicast

Les adresses unicast IPv6 se déclinent en plusieurs catégories selon leur portée et leur usage.

### Types d'adresses unicast

|Type|Préfixe|Portée|Usage|
|---|---|---|---|
|**Global Unicast**|`2000::/3`|Internet|Adresses publiques routables|
|**Link-Local**|`fe80::/10`|Lien local|Communication sur le même lien|
|**Unique Local**|`fc00::/7`|Site local|Adresses privées (équivalent RFC 1918)|

### Adresse globale (Global Unicast Address)

Les adresses globales sont **routables sur Internet**, équivalentes aux adresses IPv4 publiques.

```bash
2001:0db8:85a3:0000:0000:8a2e:0370:7334
│    │    │    │         │
│    │    │    │         └── Identifiant d'interface (64 bits)
│    │    │    └──────────── Identifiant de sous-réseau (16 bits)
│    │    └───────────────── Préfixe de site (16 bits)
│    └────────────────────── Préfixe ISP (variable)
└─────────────────────────── Préfixe global (3 bits: 001)
```

> [!info] Plage d'adresses
> 
> - Préfixe : `2000::/3`
> - Plage réelle : `2000::` à `3fff:ffff:ffff:ffff:ffff:ffff:ffff:ffff`
> - Adresses actuellement allouées : commencent généralement par `2` ou `3`

**Structure typique** :

```bash
┌─────────────────┬──────────────────┬──────────────────────┐
│   Préfixe ISP   │  Identifiant de  │   Identifiant de     │
│   (48 bits)     │  sous-réseau     │   l'interface        │
│                 │   (16 bits)      │   (64 bits)          │
└─────────────────┴──────────────────┴──────────────────────┘
      /48                /64                  /128
```

> [!example] Exemple d'allocation
> 
> ```bash
> # Préfixe alloué par l'ISP
> 2001:db8:1234::/48
> 
> # Sous-réseaux possibles
> 2001:db8:1234:0001::/64  (VLAN 1)
> 2001:db8:1234:0002::/64  (VLAN 2)
> 2001:db8:1234:ffff::/64  (VLAN 65535)
> 
> # Adresse complète d'un hôte
> 2001:db8:1234:0001::1/64
> ```

**Cas d'usage** :

- Serveurs web publics
- Tout service accessible depuis Internet
- Communication inter-sites via Internet

### Adresse link-local

Les adresses link-local sont **automatiquement configurées** et **non routables**. Elles sont valides uniquement sur le lien local (segment réseau).

```bash
fe80::1234:5678:90ab:cdef
│   │
│   └── Les 54 bits suivants sont généralement à 0
└────── Préfixe link-local (10 bits: 1111111010)
```

> [!info] Caractéristiques
> 
> - Préfixe : `fe80::/10`
> - Format usuel : `fe80::/64` (les 54 bits suivants sont à 0)
> - **Obligatoire** sur toute interface IPv6 activée
> - **Non routable** au-delà du lien local

**Génération automatique** :

```bash
# Format EUI-64 (Modified EUI-64)
Adresse MAC : 00:1A:2B:3C:4D:5E

1. Insérer FF:FE au milieu
   00:1A:2B:FF:FE:3C:4D:5E

2. Inverser le 7ème bit (U/L bit)
   02:1A:2B:FF:FE:3C:4D:5E

3. Adresse link-local résultante
   fe80::21a:2bff:fe3c:4d5e
```

> [!tip] Adresses aléatoires Pour des raisons de confidentialité, les systèmes modernes génèrent souvent des **adresses temporaires aléatoires** plutôt que d'utiliser EUI-64 basé sur la MAC.

**Cas d'usage** :

- **Neighbor Discovery Protocol** (NDP)
- Communication entre routeurs sur le même lien
- Configuration automatique (SLAAC)
- Communication locale avant obtention d'une adresse globale

> [!warning] Zone ID obligatoire Lors de l'utilisation d'une adresse link-local pour se connecter, vous devez spécifier l'**interface** (Zone ID) :
> 
> ```bash
> ping fe80::1%eth0
>           └──── Zone ID (interface)
> ```

### Adresse unique local (Unique Local Address)

Les adresses unique local sont l'équivalent IPv6 des adresses privées RFC 1918 d'IPv4.

```bash
fd12:3456:7890:0001::1
│ │               │
│ │               └── Identifiant d'interface
│ └─────────────────── Identifiant global (40 bits, pseudo-aléatoire)
└───────────────────── Préfixe (7 bits: 1111110)
```

> [!info] Plages
> 
> - **Préfixe** : `fc00::/7`
> - **Utilisable** : `fd00::/8` (l bit à 1, génération locale)
> - **Non allouée** : `fc00::/8` (l bit à 0, allocation centrale - jamais utilisé)

**Structure** :

```bash
┌──────┬───┬──────────────┬────────────┬──────────────────┐
│ 7b   │ 1 │   40 bits    │  16 bits   │     64 bits      │
│ 1111 │ L │   Global ID  │  Subnet ID │  Interface ID    │
│ 110  │   │  (aléatoire) │            │                  │
└──────┴───┴──────────────┴────────────┴──────────────────┘
 Prefix  L=1                                               
```

**Génération du Global ID** :

> [!example] Méthode recommandée (RFC 4193)
> 
> 1. Obtenir un timestamp NTP de 64 bits
> 2. Obtenir un identifiant EUI-64
> 3. Concaténer les deux valeurs
> 4. Calculer le SHA-1
> 5. Prendre les 40 bits de poids faible
> 
> ```bash
> # Exemple d'adresse générée
> fd12:3456:7890::/48
> ```

**Cas d'usage** :

- Réseau interne d'entreprise
- Communication inter-sites via VPN
- Lab et environnements de test
- Alternative aux adresses privées IPv4

> [!warning] Non routable sur Internet Comme les adresses privées IPv4, les ULA ne doivent **jamais être routées** sur Internet public. Elles nécessitent NAT66 ou un tunnel pour accéder à Internet.

**Comparaison avec IPv4** :

|IPv4|IPv6|Usage|
|---|---|---|
|`10.0.0.0/8`|`fd00::/8`|Réseau privé large|
|`172.16.0.0/12`|`fd00::/8`|Réseau privé moyen|
|`192.168.0.0/16`|`fd00::/8`|Réseau privé petit|

---

## ⚡ Adresses spéciales

IPv6 définit plusieurs adresses spéciales pour des fonctions système spécifiques.

### Adresse de loopback : `::1`

L'équivalent IPv6 de `127.0.0.1`.

```bash
::1  =  0000:0000:0000:0000:0000:0000:0000:0001
│
└── Adresse de loopback (localhost)
```

> [!info] Caractéristiques
> 
> - Notation complète : `0000:0000:0000:0000:0000:0000:0000:0001`
> - Notation compressée : `::1`
> - Préfixe : `::1/128` (adresse d'hôte unique)
> - **Non routable**, trafic reste sur la machine locale

**Cas d'usage** :

```bash
# Test de la pile TCP/IP locale
ping ::1

# Serveur écoutant sur localhost
nc -l ::1 8080

# SSH local
ssh user@::1
```

> [!tip] Comparaison IPv4
> 
> - **IPv4** : `127.0.0.1/8` (16 millions d'adresses)
> - **IPv6** : `::1/128` (une seule adresse)

### Adresse non spécifiée : `::`

Représente l'absence d'adresse.

```bash
::  =  0000:0000:0000:0000:0000:0000:0000:0000
│
└── Tous les bits à zéro
```

> [!info] Caractéristiques

- Notation complète : `0000:0000:0000:0000:0000:0000:0000:0000`
- Notation compressée : `::`
- Équivalent IPv4 : `0.0.0.0`
- **Jamais assignée à une interface**

**Cas d'usage** :

1. **Adresse source** lors de l'initialisation :

```bash
# Une machine sans adresse IPv6 configurée envoie une requête
# Adresse source : ::
# Adresse destination : serveur DHCP
```

2. **Socket binding** (écoute sur toutes les interfaces) :

```bash
# Serveur écoutant sur toutes les interfaces IPv6
bind(sockfd, "::", 80);
```

3. **Route par défaut** :

```bash
# Route par défaut (0.0.0.0/0 en IPv4)
::/0 via fe80::1
```

> [!warning] Ne jamais utiliser comme destination L'adresse `::` ne doit **jamais** apparaître comme adresse de destination dans un paquet.

### Préfixe multicast : `ff00::/8`

Toutes les adresses multicast commencent par `ff`.

```bash
ff02::1
│ │ │
│ │ └── Identifiant de groupe
│ └──── Portée (scope)
└────── Préfixe multicast (8 bits: 11111111)
```

**Structure** :

```bash
┌────────┬────┬────┬─────────────────────────────┐
│ 8 bits │ 4b │ 4b │       112 bits              │
│   FF   │Flg │Scp │      Group ID               │
└────────┴────┴────┴─────────────────────────────┘
```

**Flags (4 bits)** :

- `0` : Permanent (adresse bien connue)
- `1` : Temporaire (dynamiquement assignée)

**Scope (4 bits)** :

|Code|Valeur|Portée|Description|
|---|---|---|---|
|1|Interface-local|`ff01::`|Interface elle-même|
|2|Link-local|`ff02::`|Lien local|
|4|Admin-local|`ff04::`|Périmètre administratif|
|5|Site-local|`ff05::`|Site|
|8|Organization|`ff08::`|Organisation|
|e|Global|`ff0e::`|Internet global|

> [!example] Adresses multicast courantes
> 
> ```bash
> # Tous les nœuds du lien local
> ff02::1
> 
> # Tous les routeurs du lien local
> ff02::2
> 
> # Tous les serveurs DHCP du lien local
> ff02::1:2
> 
> # mDNS (Multicast DNS)
> ff02::fb
> 
> # NTP
> ff02::101
> ```

**Cas d'usage** :

- **Neighbor Discovery** (découverte de voisins)
- **Router Advertisement** (annonce de routeur)
- Services de découverte (mDNS, LLMNR)
- Protocoles de routage multicast
- Streaming multicast

> [!info] Groupes sollicités (Solicited-Node) Adresse spéciale pour Neighbor Discovery :
> 
> ```bash
> ff02::1:ff00:0000/104
> 
> # Pour l'adresse 2001:db8::1234:5678
> # Adresse solicited-node : ff02::1:ff34:5678
> #                                └─────────┘
> #                          24 derniers bits de l'adresse
> ```

### Tableau récapitulatif des adresses spéciales

|Adresse|Type|Description|
|---|---|---|
|`::1/128`|Unicast|Loopback (localhost)|
|`::/128`|Unicast|Adresse non spécifiée|
|`::/0`|-|Route par défaut|
|`ff00::/8`|Multicast|Toutes les adresses multicast|
|`ff02::1`|Multicast|Tous les nœuds (link-local)|
|`ff02::2`|Multicast|Tous les routeurs (link-local)|
|`fe80::/10`|Unicast|Adresses link-local|
|`fc00::/7`|Unicast|Adresses unique local (privées)|
|`2000::/3`|Unicast|Adresses globales routables|

---

## 🎓 Résumé des concepts clés

> [!tip] Points essentiels à retenir
> 
> **Format** :
> 
> - 128 bits = 8 groupes de 16 bits en hexadécimal
> - Compression possible avec `::` (une seule fois)
> - Zéros initiaux supprimables
> 
> **Types d'adresses** :
> 
> - **Unicast** : un destinataire unique
> - **Multicast** : groupe de destinataires (remplace broadcast)
> - **Anycast** : le destinataire le plus proche
> 
> **Adresses unicast** :
> 
> - `2000::/3` : Global (publique, routable)
> - `fe80::/10` : Link-local (auto-configurée, non routable)
> - `fd00::/8` : Unique Local (privée)
> 
> **Adresses spéciales** :
> 
> - `::1` : Loopback
> - `::` : Non spécifiée
> - `ff00::/8` : Multicast

---

## 📊 Comparaison IPv4 vs IPv6

|Caractéristique|IPv4|IPv6|
|---|---|---|
|**Taille**|32 bits|128 bits|
|**Notation**|Décimale pointée|Hexadécimale avec `:`|
|**Espace d'adressage**|~4.3 milliards|~340 undécillions|
|**Loopback**|`127.0.0.1`|`::1`|
|**Non spécifiée**|`0.0.0.0`|`::`|
|**Privées**|`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`|`fc00::/7`|
|**Link-local**|`169.254.0.0/16`|`fe80::/10`|
|**Broadcast**|Oui|Non (remplacé par multicast)|
|**Configuration**|Manuelle ou DHCP|SLAAC, DHCPv6, manuelle|

---

> [!success] Maîtrise de l'adressage IPv6 Vous connaissez maintenant les fondamentaux de l'adressage IPv6, essentiels pour comprendre et configurer des réseaux modernes. La notation peut sembler complexe au début, mais avec la pratique, elle devient naturelle.