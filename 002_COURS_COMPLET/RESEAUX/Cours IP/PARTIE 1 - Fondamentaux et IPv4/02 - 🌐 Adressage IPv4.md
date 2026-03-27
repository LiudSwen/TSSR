

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

L'adressage IPv4 (Internet Protocol version 4) est le système fondamental qui permet d'identifier de manière unique chaque équipement connecté à un réseau TCP/IP. Chaque adresse IPv4 est comparable à une adresse postale numérique qui permet d'acheminer les données vers leur destination.

> [!info] Pourquoi IPv4 est important IPv4 est encore aujourd'hui le protocole d'adressage le plus utilisé sur Internet, malgré l'émergence progressive d'IPv6. Comprendre IPv4 est essentiel pour tout professionnel des réseaux.

---

## 📊 Format décimal pointé

### Structure de base

Une adresse IPv4 est composée de **4 octets** (32 bits au total) représentés en notation décimale pointée.

**Format général :**

```
X.X.X.X
```

Où chaque X représente un octet (8 bits) avec une valeur comprise entre **0 et 255**.

### Exemples d'adresses valides

```
192.168.1.1
10.0.0.254
172.16.45.100
8.8.8.8
```

### Décomposition d'une adresse

Prenons l'exemple de **192.168.1.1** :

|Octet|Valeur décimale|Position|
|---|---|---|
|1er octet|192|Partie réseau (souvent)|
|2e octet|168|Partie réseau (souvent)|
|3e octet|1|Partie hôte ou réseau|
|4e octet|1|Partie hôte|

> [!tip] Astuce de mémorisation Pensez à une adresse IPv4 comme à 4 nombres séparés par des points, chacun entre 0 et 255. Si un nombre dépasse 255, l'adresse n'est pas valide.

> [!warning] Erreurs courantes
> 
> - **300.168.1.1** ❌ (300 > 255)
> - **192.168.1** ❌ (seulement 3 octets)
> - **192.168.1.1.5** ❌ (5 octets)
> - **192.168.-1.1** ❌ (valeur négative)

### Pourquoi ce format ?

Le format décimal pointé a été choisi pour sa **lisibilité humaine**. Il est beaucoup plus facile de mémoriser `192.168.1.1` que sa version binaire `11000000.10101000.00000001.00000001`.

---

## 🔢 Notation binaire

### Conversion décimal ↔ binaire

Chaque octet d'une adresse IPv4 peut être représenté en binaire sur 8 bits.

**Valeurs des positions binaires :**

|Position|128|64|32|16|8|4|2|1|
|---|---|---|---|---|---|---|---|---|
|Bit|2⁷|2⁶|2⁵|2⁴|2³|2²|2¹|2⁰|

### Exemple de conversion : 192 en binaire

```
192 = 128 + 64 + 0 + 0 + 0 + 0 + 0 + 0
    = 1    1   0   0   0   0   0   0
    = 11000000
```

### Conversions complètes d'adresses

**Exemple 1 : 192.168.1.1**

|Décimal|Binaire|
|---|---|
|192|11000000|
|168|10101000|
|1|00000001|
|1|00000001|

**Adresse complète en binaire :**

```
11000000.10101000.00000001.00000001
```

**Exemple 2 : 10.0.0.254**

|Décimal|Binaire|
|---|---|
|10|00001010|
|0|00000000|
|0|00000000|
|254|11111110|

**Adresse complète en binaire :**

```
00001010.00000000.00000000.11111110
```

### Méthode rapide de conversion décimal → binaire

1. Commencez par le bit le plus à gauche (128)
2. Si le nombre est ≥ à la valeur du bit, mettez 1 et soustrayez
3. Sinon, mettez 0
4. Passez au bit suivant et répétez

> [!example] Exemple : Convertir 172 en binaire
> 
> ```
> 172 >= 128 ? Oui → 1, reste 44
> 44 >= 64 ? Non → 0
> 44 >= 32 ? Oui → 1, reste 12
> 12 >= 16 ? Non → 0
> 12 >= 8 ? Oui → 1, reste 4
> 4 >= 4 ? Oui → 1, reste 0
> 0 >= 2 ? Non → 0
> 0 >= 1 ? Non → 0
> 
> Résultat : 10101100
> ```

### Pourquoi comprendre la notation binaire ?

> [!info] Importance pratique
> 
> - **Calculs de sous-réseaux** : Les masques de sous-réseau fonctionnent au niveau binaire
> - **Optimisation réseau** : Comprendre le binaire aide à visualiser les plages d'adresses
> - **Dépannage** : Certains problèmes réseau nécessitent une analyse binaire

> [!tip] Valeurs courantes à mémoriser
> 
> |Décimal|Binaire|Usage fréquent|
> |---|---|---|
> |0|00000000|Début de plage|
> |128|10000000|Milieu de plage|
> |192|11000000|Classe C|
> |255|11111111|Broadcast|

---

## 🏛️ Classes d'adresses

Le système de classes d'adresses IPv4 a été créé pour organiser l'espace d'adressage. Bien que ce système soit aujourd'hui obsolète au profit du **CIDR** (Classless Inter-Domain Routing), il reste important à comprendre.

### Vue d'ensemble des classes

|Classe|Premier octet|Plage|Réseau par défaut|Hôtes/réseau|Usage|
|---|---|---|---|---|---|
|A|0-127|0.0.0.0 - 127.255.255.255|/8|16 777 214|Très grands réseaux|
|B|128-191|128.0.0.0 - 191.255.255.255|/16|65 534|Réseaux moyens|
|C|192-223|192.0.0.0 - 223.255.255.255|/24|254|Petits réseaux|
|D|224-239|224.0.0.0 - 239.255.255.255|N/A|N/A|Multicast|
|E|240-255|240.0.0.0 - 255.255.255.255|N/A|N/A|Expérimental|

### Classe A

**Caractéristiques :**

- Premier bit toujours à **0** en binaire : `0xxxxxxx`
- Premier octet : **1 à 126** (0 et 127 réservés)
- Masque par défaut : **255.0.0.0** ou **/8**
- Format : **R.H.H.H** (R = Réseau, H = Hôte)

**Nombre d'adresses :**

- Réseaux possibles : 126 (2⁷ - 2)
- Hôtes par réseau : 16 777 214 (2²⁴ - 2)

> [!example] Exemples de réseaux Classe A
> 
> - 10.0.0.0/8 (privé)
> - 12.0.0.0/8
> - 56.0.0.0/8
> - 102.0.0.0/8

**Structure binaire :**

```
Classe A : 0xxxxxxx.xxxxxxxx.xxxxxxxx.xxxxxxxx
           └─ Réseau ─┘└───── Hôtes ──────────┘
```

### Classe B

**Caractéristiques :**

- Deux premiers bits : **10** en binaire : `10xxxxxx`
- Premier octet : **128 à 191**
- Masque par défaut : **255.255.0.0** ou **/16**
- Format : **R.R.H.H**

**Nombre d'adresses :**

- Réseaux possibles : 16 384 (2¹⁴)
- Hôtes par réseau : 65 534 (2¹⁶ - 2)

> [!example] Exemples de réseaux Classe B
> 
> - 172.16.0.0/16 (privé)
> - 130.45.0.0/16
> - 155.200.0.0/16
> - 191.255.0.0/16

**Structure binaire :**

```
Classe B : 10xxxxxx.xxxxxxxx.xxxxxxxx.xxxxxxxx
           └──── Réseau ────┘└──── Hôtes ─────┘
```

### Classe C

**Caractéristiques :**

- Trois premiers bits : **110** en binaire : `110xxxxx`
- Premier octet : **192 à 223**
- Masque par défaut : **255.255.255.0** ou **/24**
- Format : **R.R.R.H**

**Nombre d'adresses :**

- Réseaux possibles : 2 097 152 (2²¹)
- Hôtes par réseau : 254 (2⁸ - 2)

> [!example] Exemples de réseaux Classe C
> 
> - 192.168.1.0/24 (privé)
> - 200.50.100.0/24
> - 210.123.45.0/24
> - 223.255.255.0/24

**Structure binaire :**

```
Classe C : 110xxxxx.xxxxxxxx.xxxxxxxx.xxxxxxxx
           └──────── Réseau ────────┘└─ Hôtes ┘
```

### Classe D (Multicast)

**Caractéristiques :**

- Quatre premiers bits : **1110** en binaire : `1110xxxx`
- Premier octet : **224 à 239**
- Pas de masque de sous-réseau
- Utilisée pour le **multicast** (diffusion à plusieurs destinations)

> [!info] Usage du multicast Le multicast permet d'envoyer un seul paquet à plusieurs destinataires simultanément. Utilisé pour la vidéo en streaming, les protocoles de routage, etc.

> [!example] Adresses multicast courantes
> 
> - 224.0.0.1 : Tous les hôtes du segment local
> - 224.0.0.2 : Tous les routeurs du segment local
> - 224.0.0.5 : Tous les routeurs OSPF
> - 239.x.x.x : Multicast à portée administrative

### Classe E (Expérimental)

**Caractéristiques :**

- Quatre premiers bits : **1111** en binaire : `1111xxxx`
- Premier octet : **240 à 255**
- Réservée pour un usage futur et expérimental
- **Non utilisable** pour l'adressage normal

> [!warning] Classe E inutilisable Les adresses de classe E ne doivent jamais être attribuées à des équipements réseau. Elles sont réservées par l'IANA.

### Identification rapide de la classe

> [!tip] Méthode rapide Regardez le **premier octet** de l'adresse :
> 
> - **1-126** → Classe A
> - **128-191** → Classe B
> - **192-223** → Classe C
> - **224-239** → Classe D (Multicast)
> - **240-255** → Classe E (Expérimental)

### Limites du système de classes

> [!warning] Système obsolète Le système de classes est **rigide** et **inefficace** :
> 
> - Une classe C (254 hôtes) peut être trop petite
> - Une classe B (65 534 hôtes) peut être trop grande
> - Gaspillage massif d'adresses IPv4
> 
> C'est pourquoi le **CIDR** (notation /XX) est maintenant utilisé pour permettre un découpage plus flexible.

---

## 🔐 Adresses privées vs publiques

### Concept fondamental

Les adresses IPv4 sont divisées en deux catégories principales :

- **Adresses publiques** : Routables sur Internet, uniques mondialement
- **Adresses privées** : Non routables sur Internet, réutilisables dans différents réseaux privés

> [!info] Pourquoi cette distinction ? Avec seulement 4,3 milliards d'adresses IPv4 disponibles et des milliards d'équipements connectés, les adresses privées permettent de réutiliser les mêmes plages dans différents réseaux locaux, économisant ainsi les adresses publiques.

### Adresses privées (RFC 1918)

Le **RFC 1918** définit trois plages d'adresses réservées à un usage privé :

|Classe|Plage d'adresses|Notation CIDR|Nombre d'adresses|
|---|---|---|---|
|A|10.0.0.0 - 10.255.255.255|10.0.0.0/8|16 777 216|
|B|172.16.0.0 - 172.31.255.255|172.16.0.0/12|1 048 576|
|C|192.168.0.0 - 192.168.255.255|192.168.0.0/16|65 536|

#### Plage 10.0.0.0/8 (Classe A)

**Caractéristiques :**

- La plus grande plage privée
- Idéale pour les grandes entreprises
- Permet de créer de nombreux sous-réseaux

> [!example] Utilisation typique
> 
> ```
> Entreprise multinationale :
> - Siège social : 10.0.0.0/16
> - Filiale Europe : 10.1.0.0/16
> - Filiale Asie : 10.2.0.0/16
> - Filiale Amérique : 10.3.0.0/16
> - VPN utilisateurs : 10.100.0.0/16
> ```

#### Plage 172.16.0.0/12 (Classe B)

**Caractéristiques :**

- 16 réseaux de classe B contigus (172.16.0.0 à 172.31.0.0)
- Bon compromis taille/flexibilité
- Utilisée par les entreprises moyennes

> [!example] Utilisation typique
> 
> ```
> Entreprise moyenne :
> - Réseau LAN principal : 172.16.0.0/16
> - Réseau DMZ : 172.17.0.0/24
> - Réseau Wi-Fi invités : 172.18.0.0/24
> - Réseau IoT : 172.19.0.0/24
> ```

#### Plage 192.168.0.0/16 (Classe C)

**Caractéristiques :**

- 256 réseaux de classe C (192.168.0.0 à 192.168.255.0)
- La plus utilisée dans les réseaux domestiques
- Standard des box Internet et routeurs grand public

> [!example] Utilisation typique
> 
> ```
> Réseau domestique :
> - Box Internet : 192.168.1.0/24
> - PC fixe : 192.168.1.10
> - Ordinateur portable : 192.168.1.20
> - Smartphone : 192.168.1.30
> - Imprimante : 192.168.1.100
> ```

### Adresses publiques

**Caractéristiques :**

- Attribuées par les **RIR** (Regional Internet Registries)
- Uniques sur Internet
- Routables globalement
- Coûteuses et rares

**Répartition géographique des RIR :**

- **ARIN** : Amérique du Nord
- **RIPE NCC** : Europe, Moyen-Orient, Asie centrale
- **APNIC** : Asie-Pacifique
- **LACNIC** : Amérique latine et Caraïbes
- **AFRINIC** : Afrique

> [!example] Exemples d'adresses publiques
> 
> - 8.8.8.8 (DNS Google)
> - 1.1.1.1 (DNS Cloudflare)
> - 142.250.74.110 (Google.com)
> - 151.101.1.140 (Reddit.com)

### NAT : Le pont entre privé et public

Le **NAT** (Network Address Translation) permet aux équipements avec des adresses privées d'accéder à Internet via une adresse publique unique.

**Fonctionnement simplifié :**

```
Réseau privé                 Routeur NAT              Internet
192.168.1.10  ────────→  [Traduction]  ────────→  203.0.113.5
192.168.1.20  ────────→  [203.0.113.5] ────────→  Serveur web
192.168.1.30  ────────→                ────────→
```

> [!info] Avantages du NAT
> 
> - **Économie d'adresses** : Un réseau entier partage une seule IP publique
> - **Sécurité** : Les équipements internes sont masqués
> - **Flexibilité** : Changement facile de fournisseur d'accès

### Tableau récapitulatif

|Critère|Adresses privées|Adresses publiques|
|---|---|---|
|Routabilité Internet|❌ Non|✅ Oui|
|Unicité|Réutilisables|Uniques mondialement|
|Coût|Gratuit|Payant (via FAI/RIR)|
|Attribution|Libre|RIR → FAI → Client|
|NAT requis|✅ Oui|❌ Non|
|Usage typique|Réseaux locaux|Serveurs publics|

> [!warning] Erreur courante Ne confondez pas adresses privées et adresses locales. Une adresse privée peut être utilisée sur plusieurs sites distants interconnectés par VPN, tandis qu'une adresse locale est spécifique à un segment réseau.

> [!tip] Bonnes pratiques
> 
> - Utilisez **10.0.0.0/8** pour les grandes infrastructures
> - Utilisez **172.16.0.0/12** pour les réseaux d'entreprise
> - Utilisez **192.168.0.0/16** pour les petits réseaux et domiciles
> - Documentez votre plan d'adressage pour éviter les chevauchements
> - Réservez des plages pour la croissance future

---

## 🎯 Adresses spéciales

Certaines adresses IPv4 ont des significations et des usages particuliers. Il est crucial de les connaître pour éviter les erreurs de configuration.

### Adresse de loopback (127.0.0.0/8)

**Plage complète :** 127.0.0.0 à 127.255.255.255

**Adresse principale :** **127.0.0.1** (localhost)

> [!info] Usage L'adresse de loopback permet à un équipement de communiquer avec lui-même. Les paquets envoyés à cette adresse ne quittent jamais l'équipement.

**Applications courantes :**

- Tests de la pile TCP/IP locale
- Services écoutant uniquement en local (bases de données, serveurs de développement)
- Diagnostics réseau

> [!example] Utilisation pratique
> 
> ```bash
> # Tester si la pile TCP/IP fonctionne
> ping 127.0.0.1
> 
> # Se connecter à un serveur web local
> http://127.0.0.1:8080
> 
> # Accès base de données locale
> mysql -h 127.0.0.1 -u root
> ```

> [!tip] Astuce Toute la plage 127.x.x.x fonctionne en loopback, pas seulement 127.0.0.1. Vous pouvez utiliser 127.0.0.2, 127.1.2.3, etc.

### Adresse réseau

**Définition :** Première adresse d'un sous-réseau, tous les bits hôte à **0**.

**Signification :** Identifie le réseau lui-même, **non attribuable** à un équipement.

> [!example] Exemples d'adresses réseau
> 
> - Réseau 192.168.1.0/24 → Adresse réseau : **192.168.1.0**
> - Réseau 10.0.0.0/8 → Adresse réseau : **10.0.0.0**
> - Réseau 172.16.50.0/24 → Adresse réseau : **172.16.50.0**
> - Réseau 192.168.1.128/25 → Adresse réseau : **192.168.1.128**

**Calcul en binaire :**

```
Réseau 192.168.1.0/24 :
IP : 11000000.10101000.00000001.00000000
                                └─ Tous les bits hôte à 0
```

> [!warning] Erreur fréquente Ne jamais attribuer l'adresse réseau à un équipement. Par exemple, ne configurez jamais un PC avec l'IP 192.168.1.0 dans le réseau 192.168.1.0/24.

### Adresse de broadcast

**Définition :** Dernière adresse d'un sous-réseau, tous les bits hôte à **1**.

**Signification :** Permet d'envoyer un message à **tous les hôtes** du réseau local simultanément.

> [!example] Exemples d'adresses de broadcast
> 
> - Réseau 192.168.1.0/24 → Broadcast : **192.168.1.255**
> - Réseau 10.0.0.0/8 → Broadcast : **10.255.255.255**
> - Réseau 172.16.50.0/24 → Broadcast : **172.16.50.255**
> - Réseau 192.168.1.128/25 → Broadcast : **192.168.1.255**

**Calcul en binaire :**

```
Réseau 192.168.1.0/24 :
Broadcast : 11000000.10101000.00000001.11111111
                                        └─ Tous les bits hôte à 1
```

**Types de broadcast :**

|Type|Adresse|Portée|
|---|---|---|
|Broadcast limité|255.255.255.255|Segment local uniquement|
|Broadcast dirigé|X.X.X.255 (ex: 192.168.1.255)|Réseau spécifique|

> [!info] Utilisation du broadcast
> 
> - Protocoles de découverte (ARP, DHCP)
> - Wake-on-LAN
> - Annonces de services
> - Protocoles de routage (RIP)

> [!warning] Sécurité Les broadcasts peuvent être utilisés pour des attaques (smurf attack). De nombreux routeurs bloquent les broadcasts dirigés par défaut.

### Adresse d'hôte

**Définition :** Toute adresse entre l'adresse réseau et l'adresse de broadcast.

**Caractéristiques :**

- Attribuable aux équipements (ordinateurs, serveurs, routeurs, etc.)
- Unique dans le sous-réseau
- Utilisable pour la communication

**Calcul du nombre d'hôtes disponibles :**

```
Nombre d'hôtes = 2^(nombre de bits hôte) - 2
```

> [!example] Calcul pour 192.168.1.0/24
> 
> ```
> Masque /24 = 24 bits réseau, 8 bits hôte
> Hôtes disponibles = 2^8 - 2 = 256 - 2 = 254
> 
> Plage utilisable :
> - Première adresse hôte : 192.168.1.1
> - Dernière adresse hôte : 192.168.1.254
> - Adresse réseau : 192.168.1.0 (non utilisable)
> - Adresse broadcast : 192.168.1.255 (non utilisable)
> ```

> [!tip] Conventions d'attribution Bien qu'il n'y ait pas de règle stricte, voici des conventions courantes :
> 
> - **192.168.1.1** : Passerelle par défaut (routeur/box)
> - **192.168.1.2-50** : Adresses statiques (serveurs, imprimantes)
> - **192.168.1.51-200** : Pool DHCP (attribution automatique)
> - **192.168.1.201-254** : Réserve pour extension

### Adresse 0.0.0.0

**Significations multiples selon le contexte :**

1. **Route par défaut** : Représente "toute destination"

```bash
# Route par défaut vers la passerelle 192.168.1.1
ip route add 0.0.0.0/0 via 192.168.1.1
```

2. **Écoute sur toutes les interfaces** : Un service écoute sur toutes les IP de l'équipement

```bash
# Serveur web écoutant sur toutes les interfaces
Listen 0.0.0.0:80
```

3. **Adresse non configurée** : L'équipement n'a pas encore d'adresse (DHCP en cours)

> [!warning] Ne pas confondre 0.0.0.0 n'est **pas** une adresse attribuable à un équipement pour communiquer sur le réseau.

### Adresse 255.255.255.255

**Usage :** Broadcast limité au segment local.

**Caractéristique :** Ne traverse **jamais** un routeur, reste sur le réseau local.

> [!example] Utilisation typique
> 
> - Requêtes DHCP initiales (DHCP Discover)
> - Certaines annonces de services réseau

### Adresses de documentation (RFC 5737)

Trois plages réservées pour la documentation et les exemples :

|Plage|Notation CIDR|Usage|
|---|---|---|
|192.0.2.0 - 192.0.2.255|192.0.2.0/24|TEST-NET-1|
|198.51.100.0 - 198.51.100.255|198.51.100.0/24|TEST-NET-2|
|203.0.113.0 - 203.0.113.255|203.0.113.0/24|TEST-NET-3|

> [!info] Pourquoi ces adresses ? Elles garantissent que les exemples dans la documentation ne risquent pas d'interférer avec de vraies adresses Internet.

> [!example] Utilisation dans ce cours
> 
> ```
> Exemple de configuration :
> - Réseau : 192.0.2.0/24
> - Passerelle : 192.0.2.1
> - Serveur : 192.0.2.10
> ```

### Adresse APIPA (169.254.0.0/16)

**Plage :** 169.254.0.0 à 169.254.255.255

**Usage :** Auto-configuration lorsqu'aucun serveur DHCP n'est disponible (RFC 3927).

> [!info] Fonctionnement Si un équipement configuré en DHCP ne reçoit pas de réponse, il s'auto-attribue une adresse dans cette plage et peut communiquer avec d'autres équipements en APIPA sur le même segment.

> [!warning] Signe de problème Si vous voyez une adresse 169.254.x.x sur votre équipement, cela signifie généralement :
> 
> - Le serveur DHCP est inaccessible
> - Le câble réseau est débranché
> - Un problème de configuration réseau

> [!example] Diagnostic sous Windows
> 
> ```bash
> ipconfig
> # Si vous voyez : 169.254.45.123
> # → Problème DHCP à résoudre
> ```

### Tableau récapitulatif des adresses spéciales

|Adresse|Type|Attribuable|Usage|
|---|---|---|---|
|0.0.0.0|Spéciale|❌|Route par défaut, écoute toutes interfaces|
|127.0.0.0/8|Loopback|❌|Communication interne à l'équipement|
|169.254.0.0/16|APIPA|⚠️|Auto-configuration sans DHCP|
|192.0.2.0/24|Documentation|❌|Exemples et documentation|
|255.255.255.255|Broadcast limité|❌|Diffusion segment local|
|X.X.X.0|Adresse réseau|❌|Identifie le réseau|
|X.X.X.255|Broadcast dirigé|❌|Diffusion vers réseau spécifique|
|X.X.X.1-254|Adresse hôte|✅|Équipements du réseau|

### Pièges courants avec les adresses spéciales

> [!warning] Erreurs fréquentes
> 
> **❌ Attribuer l'adresse réseau :**
> 
> ```
> PC : 192.168.1.0  # ERREUR : c'est l'adresse réseau
> ```
> 
> **❌ Attribuer l'adresse de broadcast :**
> 
> ```
> Serveur : 192.168.1.255  # ERREUR : c'est le broadcast
> ```
> 
> **❌ Oublier de réserver des adresses :**
> 
> ```
> Dans 192.168.1.0/24 :
> - Ne pas utiliser .0 (réseau)
> - Ne pas utiliser .255 (broadcast)
> - Réserver .1 pour la passerelle
> → Seulement 253 adresses disponibles pour les hôtes
> ```
> 
> **❌ Confusion entre broadcast limité et dirigé :**
> 
> ```
> 255.255.255.255  # Broadcast limité (ne traverse pas les routeurs)
> 192.168.1.255    # Broadcast dirigé (peut traverser selon config)
> ```

### Vérification d'adresse valide

Pour déterminer si une adresse est attribuable dans un réseau :

**Méthode :**

1. Identifier l'adresse réseau (première adresse)
2. Identifier l'adresse de broadcast (dernière adresse)
3. Vérifier que l'adresse est entre les deux

> [!example] Exemple : 192.168.1.50 dans 192.168.1.0/24
> 
> ```
> Adresse réseau : 192.168.1.0
> Adresse à tester : 192.168.1.50
> Adresse broadcast : 192.168.1.255
> 
> 192.168.1.0 < 192.168.1.50 < 192.168.1.255
> → Adresse VALIDE et attribuable ✅
> ```

> [!example] Exemple : 192.168.1.0 dans 192.168.1.0/24
> 
> ```
> Adresse réseau : 192.168.1.0
> Adresse à tester : 192.168.1.0
> 
> 192.168.1.0 == 192.168.1.0
> → Adresse INVALIDE (c'est l'adresse réseau) ❌
> ```

---

## 🎓 Synthèse et bonnes pratiques

### Points clés à retenir

> [!tip] Mémo essentiel
> 
> **Format d'une adresse IPv4 :**
> 
> - 4 octets séparés par des points
> - Chaque octet : 0 à 255
> - 32 bits au total
> 
> **Classes principales :**
> 
> - Classe A : 1-126.x.x.x (grands réseaux)
> - Classe B : 128-191.x.x.x (réseaux moyens)
> - Classe C : 192-223.x.x.x (petits réseaux)
> 
> **Adresses privées (RFC 1918) :**
> 
> - 10.0.0.0/8 (classe A)
> - 172.16.0.0/12 (classe B)
> - 192.168.0.0/16 (classe C)
> 
> **Adresses à ne jamais attribuer :**
> 
> - Adresse réseau (tous bits hôte à 0)
> - Adresse broadcast (tous bits hôte à 1)
> - 127.0.0.0/8 (loopback)
> - 0.0.0.0

### Bonnes pratiques d'adressage

> [!tip] Recommandations professionnelles
> 
> **1. Planification :**
> 
> - Documentez votre plan d'adressage
> - Prévoyez de la croissance (ne utilisez pas 100% des adresses)
> - Utilisez une hiérarchie logique
> 
> **2. Organisation :**
> 
> - Réservez les premières adresses pour l'infrastructure (routeurs, switches)
> - Groupez les serveurs ensemble
> - Séparez les plages DHCP et statiques
> 
> **3. Sécurité :**
> 
> - Utilisez des adresses privées en interne
> - Documentez les adresses publiques
> - Évitez les plages prévisibles pour les services sensibles
> 
> **4. Standardisation :**
> 
> - Utilisez .1 pour les passerelles
> - Utilisez .254 pour les équipements d'infrastructure de secours
> - Maintenez une convention cohérente

### Exemple de plan d'adressage structuré

> [!example] Plan d'adressage type pour une entreprise
> 
> ```
> Réseau : 10.0.0.0/8
> 
> 10.0.0.0/16    - Siège social
>   10.0.0.0/24  - Management (routeurs, switches)
>   10.0.1.0/24  - Serveurs
>   10.0.10.0/23 - Postes utilisateurs (512 hôtes)
>   10.0.20.0/24 - Wi-Fi invités
>   10.0.30.0/24 - Imprimantes et périphériques
>   10.0.40.0/24 - IoT et domotique
> 
> 10.1.0.0/16    - Agence régionale 1
> 10.2.0.0/16    - Agence régionale 2
> 10.100.0.0/16  - VPN utilisateurs distants
> 10.200.0.0/16  - DMZ et services publics
> ```

### Conversion rapide : aide-mémoire binaire

> [!tip] Tableau de conversion rapide
> 
> |Décimal|Binaire|Décimal|Binaire|
> |---|---|---|---|
> |0|00000000|128|10000000|
> |1|00000001|192|11000000|
> |127|01111111|224|11100000|
> |255|11111111|240|11110000|
> |254|11111110|248|11111000|
> |252|11111100|252|11111100|

### Diagnostic rapide d'une adresse

Pour analyser rapidement une adresse IPv4, posez-vous ces questions :

> [!tip] Checklist d'analyse
> 
> ✅ **L'adresse est-elle valide ?**
> 
> - Chaque octet est entre 0 et 255
> - 4 octets séparés par des points
> 
> ✅ **Quelle est sa classe ?**
> 
> - Premier octet détermine la classe
> 
> ✅ **Est-elle privée ou publique ?**
> 
> - Vérifier RFC 1918 : 10.x, 172.16-31.x, 192.168.x
> 
> ✅ **Est-elle attribuable ?**
> 
> - Pas une adresse réseau
> - Pas une adresse broadcast
> - Pas dans une plage spéciale
> 
> ✅ **Est-elle cohérente avec le masque ?**
> 
> - Doit être dans la plage définie par le réseau/masque

---

## 📊 Tableaux de référence rapide

### Résumé des plages d'adresses

|Type|Plage|Usage|Routabilité Internet|
|---|---|---|---|
|Classe A privée|10.0.0.0/8|Réseaux privés|❌|
|Classe B privée|172.16.0.0/12|Réseaux privés|❌|
|Classe C privée|192.168.0.0/16|Réseaux privés|❌|
|Loopback|127.0.0.0/8|Tests locaux|❌|
|APIPA|169.254.0.0/16|Auto-config|❌|
|Documentation|192.0.2.0/24, etc.|Exemples|❌|
|Multicast|224.0.0.0/4|Diffusion multiple|Spécial|
|Autres|Reste|Adresses publiques|✅|

### Masques de sous-réseau par classe (par défaut)

|Classe|Masque décimal|Masque binaire|Notation CIDR|
|---|---|---|---|
|A|255.0.0.0|11111111.00000000.00000000.00000000|/8|
|B|255.255.0.0|11111111.11111111.00000000.00000000|/16|
|C|255.255.255.0|11111111.11111111.11111111.00000000|/24|

### Calcul rapide du nombre d'hôtes

|Bits hôte|Formule|Hôtes disponibles|Exemple de masque|
|---|---|---|---|
|8 bits|2⁸ - 2|254|/24|
|16 bits|2¹⁶ - 2|65 534|/16|
|24 bits|2²⁴ - 2|16 777 214|/8|

---

## 🔍 Astuces de dépannage

### Problèmes courants et solutions

> [!warning] Problème : Adresse 169.254.x.x **Cause :** Pas de serveur DHCP accessible
> 
> **Solutions :**
> 
> - Vérifier la connexion physique (câble, Wi-Fi)
> - Vérifier que le serveur DHCP fonctionne
> - Renouveler le bail DHCP
> - Configurer une IP statique temporairement

> [!warning] Problème : "Destination host unreachable" **Causes possibles :**
> 
> - Mauvaise configuration de passerelle
> - Adresse IP dans le mauvais sous-réseau
> - Problème de routage
> 
> **Vérifications :**
> 
> - Confirmer que l'IP et le masque sont cohérents
> - Vérifier que la passerelle est dans le même sous-réseau
> - Tester la connectivité locale (ping vers la passerelle)

> [!warning] Problème : Conflit d'adresse IP **Cause :** Deux équipements avec la même IP
> 
> **Solutions :**
> 
> - Utiliser des adresses statiques hors du pool DHCP
> - Vérifier les réservations DHCP
> - Scanner le réseau pour identifier les doublons

### Commandes de diagnostic essentielles

> [!example] Vérification de la configuration
> 
> ```bash
> # Windows
> ipconfig /all
> 
> # Linux / macOS
> ip addr show
> # ou
> ifconfig
> ```

> [!example] Test de connectivité
> 
> ```bash
> # Test loopback (pile TCP/IP locale)
> ping 127.0.0.1
> 
> # Test passerelle locale
> ping 192.168.1.1
> 
> # Test Internet
> ping 8.8.8.8
> ```

---

## 🎯 Conclusion

L'adressage IPv4 est le fondement de toute communication réseau TCP/IP. La compréhension des concepts suivants est essentielle :

- **Format décimal pointé** : 4 octets de 0 à 255
- **Représentation binaire** : Essentielle pour les calculs de sous-réseaux
- **Classes d'adresses** : Système historique mais important à connaître
- **Adresses privées/publiques** : Distinction cruciale pour l'architecture réseau
- **Adresses spéciales** : À ne jamais attribuer aux équipements

> [!info] Évolution vers IPv6 Bien qu'IPv4 reste omniprésent, IPv6 est progressivement déployé pour résoudre la pénurie d'adresses. Les concepts d'adressage IPv4 restent néanmoins fondamentaux et applicables.

---

_Cours créé pour Obsidian - Adressage IPv4 complet_