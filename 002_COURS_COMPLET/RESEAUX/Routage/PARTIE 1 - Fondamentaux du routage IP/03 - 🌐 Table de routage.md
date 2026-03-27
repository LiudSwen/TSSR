

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

## 🎯 Introduction au routage IP

Le routage IP est le processus fondamental qui permet aux paquets de données de voyager d'un réseau à un autre à travers Internet ou tout autre réseau interconnecté. Un routeur utilise une **table de routage** pour prendre des décisions sur le chemin que doit emprunter chaque paquet.

> [!info] Rôle du routage Le routage détermine le **meilleur chemin** pour acheminer un paquet IP depuis sa source jusqu'à sa destination, en se basant sur l'adresse IP de destination contenue dans l'en-tête du paquet.

### Processus de décision

Lorsqu'un routeur reçoit un paquet :

1. Il examine l'adresse IP de destination
2. Il consulte sa table de routage
3. Il détermine l'interface de sortie appropriée
4. Il transmet le paquet vers le prochain saut (next hop)

---

## 📊 Structure d'une table de routage

Une table de routage est une base de données structurée qui contient toutes les informations nécessaires pour acheminer les paquets. Chaque entrée (route) dans la table comporte plusieurs champs essentiels.

### Composants d'une entrée de routage

|Champ|Description|Exemple|
|---|---|---|
|**Réseau de destination**|Adresse réseau et masque CIDR|`192.168.10.0/24`|
|**Next hop (prochain saut)**|Adresse IP du routeur suivant|`10.0.0.1`|
|**Interface de sortie**|Port physique ou logique de sortie|`eth0`, `GigabitEthernet0/0`|
|**Métrique**|Coût de la route (distance administrative)|`1`, `110`|
|**Source**|Origine de la route|`C` (connecté), `S` (statique), `O` (OSPF)|

### Visualisation d'une table de routage

```bash
# Afficher la table de routage sous Linux
ip route show

# Exemple de sortie :
default via 192.168.1.1 dev eth0 proto static metric 100
10.0.0.0/8 via 172.16.0.1 dev eth1 proto static metric 50
172.16.0.0/24 dev eth1 proto kernel scope link src 172.16.0.10
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.100
```

```bash
# Afficher la table de routage sur Cisco
show ip route

# Exemple de sortie :
# Codes: C - connected, S - static, O - OSPF, R - RIP
#        D - EIGRP, EX - EIGRP external, i - IS-IS
#
# Gateway of last resort is 192.168.1.1 to network 0.0.0.0
#
# S*   0.0.0.0/0 [1/0] via 192.168.1.1
# C    192.168.10.0/24 is directly connected, GigabitEthernet0/0
# S    10.0.0.0/8 [1/0] via 172.16.0.1
# O    172.30.0.0/16 [110/20] via 172.16.0.5, 00:15:32, GigabitEthernet0/1
```

> [!tip] Astuce de lecture Les codes de préfixe (C, S, O, R, etc.) indiquent rapidement l'origine de chaque route. Cela permet de diagnostiquer rapidement les problèmes de routage.

### Champs additionnels importants

**Distance administrative (AD)** : Valeur de fiabilité de la source de routage. Plus elle est basse, plus la source est considérée comme fiable.

|Source de route|Distance administrative par défaut (Cisco)|
|---|---|
|Interface connectée|0|
|Route statique|1|
|EIGRP (interne)|90|
|OSPF|110|
|RIP|120|
|EIGRP (externe)|170|

**Métrique** : Coût calculé par le protocole de routage pour atteindre la destination. Chaque protocole a sa propre méthode de calcul (nombre de sauts pour RIP, bande passante pour OSPF, etc.).

> [!warning] Attention à la confusion Ne confondez pas distance administrative et métrique. La distance administrative sert à choisir entre différentes sources de routes pour une même destination, tandis que la métrique sert à choisir le meilleur chemin au sein d'un même protocole.

---

## 🔀 Types d'entrées de routage

Il existe trois types principaux d'entrées dans une table de routage, chacun ayant ses caractéristiques et ses cas d'usage spécifiques.

### 1. Routes connectées (Connected - C)

Les routes connectées sont **automatiquement créées** lorsqu'une interface réseau est configurée avec une adresse IP et activée.

#### Caractéristiques

- Distance administrative : **0** (la plus fiable)
- Aucune configuration manuelle requise
- Représentent les réseaux directement attachés au routeur
- Supprimées automatiquement si l'interface est désactivée

#### Exemple pratique

```bash
# Configuration Cisco
interface GigabitEthernet0/0
 ip address 192.168.10.1 255.255.255.0
 no shutdown

# Cela crée automatiquement l'entrée :
# C    192.168.10.0/24 is directly connected, GigabitEthernet0/0
```

```bash
# Configuration Linux
sudo ip addr add 192.168.10.1/24 dev eth0
sudo ip link set eth0 up

# Vérifie la route connectée créée
ip route show
# 192.168.10.0/24 dev eth0 proto kernel scope link src 192.168.10.1
```

> [!example] Cas d'usage Un routeur avec 3 interfaces aura automatiquement 3 routes connectées, permettant la communication directe avec les hôtes sur ces 3 réseaux locaux.

### 2. Routes statiques (Static - S)

Les routes statiques sont **configurées manuellement** par l'administrateur réseau. Elles définissent explicitement le chemin vers un réseau de destination.

#### Caractéristiques

- Distance administrative : **1** (par défaut)
- Configuration manuelle obligatoire
- Ne s'adaptent pas automatiquement aux changements de topologie
- Prévisibles et consomment peu de ressources
- Idéales pour les petits réseaux ou les connexions point-à-point

#### Syntaxe de configuration

```bash
# Cisco IOS
ip route <réseau-destination> <masque> <next-hop | interface-sortie> [distance-admin]

# Exemples :
ip route 10.0.0.0 255.0.0.0 172.16.0.1          # Via next hop
ip route 192.168.20.0 255.255.255.0 GigabitEthernet0/1  # Via interface
ip route 172.30.0.0 255.255.0.0 10.0.0.5 50     # Avec AD personnalisée
```

```bash
# Linux
sudo ip route add <réseau-destination>/<préfixe> via <next-hop> dev <interface>

# Exemples :
sudo ip route add 10.0.0.0/8 via 172.16.0.1 dev eth1
sudo ip route add 192.168.20.0/24 dev eth2
```

> [!tip] Bonne pratique Pour les connexions critiques, utilisez des routes statiques en backup avec une distance administrative élevée (par exemple 250). Elles ne seront utilisées que si la route dynamique principale échoue (technique du **floating static route**).

#### Avantages et inconvénients

**Avantages :**

- Contrôle total sur le routage
- Pas de bande passante consommée par les protocoles de routage
- Sécurité accrue (pas d'annonces de routes)
- Prévisibilité parfaite

**Inconvénients :**

- Pas de redondance automatique
- Maintenance manuelle fastidieuse sur de grands réseaux
- Pas d'adaptation aux pannes ou changements de topologie
- Erreurs de configuration possibles

> [!warning] Piège courant Une route statique mal configurée peut créer une boucle de routage ou un trou noir (black hole) où les paquets sont perdus. Vérifiez toujours que le next-hop est joignable avant de configurer une route statique.

### 3. Routes dynamiques (Dynamic)

Les routes dynamiques sont **apprises automatiquement** via des protocoles de routage dynamique comme OSPF, EIGRP, RIP, BGP, etc.

#### Caractéristiques

- Distance administrative variable selon le protocole
- Mises à jour automatiques en cas de changement de topologie
- Échange d'informations entre routeurs
- Convergence automatique après une panne
- Nécessitent des ressources (CPU, mémoire, bande passante)

#### Protocoles courants

**Protocoles IGP (Interior Gateway Protocol)** - pour le routage interne :

```bash
# OSPF (Open Shortest Path First)
# - Distance administrative : 110
# - Métrique : coût basé sur la bande passante
# - Protocole à état de liens

router ospf 1
 network 192.168.10.0 0.0.0.255 area 0
 network 172.16.0.0 0.0.255.255 area 1
```

```bash
# EIGRP (Enhanced Interior Gateway Routing Protocol)
# - Distance administrative : 90 (interne), 170 (externe)
# - Métrique : composite (bande passante, délai, fiabilité, charge)
# - Protocole hybride Cisco

router eigrp 100
 network 192.168.10.0 0.0.0.255
 network 172.16.0.0 0.0.255.255
```

```bash
# RIP (Routing Information Protocol)
# - Distance administrative : 120
# - Métrique : nombre de sauts (max 15)
# - Protocole à vecteur de distance (ancien, peu utilisé)

router rip
 version 2
 network 192.168.10.0
 network 172.16.0.0
```

**Protocoles EGP (Exterior Gateway Protocol)** - pour le routage entre systèmes autonomes :

```bash
# BGP (Border Gateway Protocol)
# - Distance administrative : 20 (eBGP), 200 (iBGP)
# - Utilisé pour l'interconnexion Internet
# - Très complexe, pour les grands réseaux

router bgp 65000
 neighbor 203.0.113.1 remote-as 65001
 network 192.168.10.0 mask 255.255.255.0
```

> [!info] Choix du protocole Le choix du protocole de routage dynamique dépend de la taille du réseau, de la topologie, du fabricant des équipements et des exigences de convergence. OSPF est le standard pour les réseaux d'entreprise modernes.

#### Avantages et inconvénients

**Avantages :**

- Adaptation automatique aux pannes
- Scalabilité pour les grands réseaux
- Redondance et équilibrage de charge
- Convergence rapide (selon le protocole)

**Inconvénients :**

- Consommation de ressources (CPU, RAM, bande passante)
- Complexité de configuration et de dépannage
- Temps de convergence (peut causer des interruptions temporaires)
- Possibilité de boucles de routage durant la convergence

### Combinaison des types de routes

Dans un réseau réel, on utilise souvent une **combinaison des trois types** :

- Routes connectées pour les réseaux locaux
- Routes statiques pour les connexions spécifiques et le backup
- Routes dynamiques pour le réseau principal

> [!example] Exemple de coexistence Un réseau d'entreprise peut utiliser OSPF pour l'ensemble du réseau interne, des routes statiques pour la connexion Internet et les sites distants peu importants, et bien sûr les routes connectées pour chaque interface configurée.

---

## 🎯 Préfixe le plus long (Longest Prefix Match)

Le **Longest Prefix Match (LPM)** est l'algorithme utilisé par les routeurs pour sélectionner la meilleure route lorsque plusieurs entrées correspondent à une même adresse IP de destination.

### Principe de fonctionnement

Lorsqu'un routeur doit acheminer un paquet :

1. Il compare l'adresse IP de destination avec **toutes** les entrées de la table de routage
2. Il identifie toutes les entrées dont le préfixe correspond
3. Il sélectionne l'entrée avec le **masque le plus spécifique** (le plus long)
4. Il transmet le paquet selon cette route

> [!info] Règle d'or **Plus le masque est long (plus le /XX est grand), plus la route est spécifique.** Une route /32 (un seul hôte) est plus spécifique qu'une /24 (256 adresses), qui est plus spécifique qu'une /16 (65536 adresses).

### Exemple détaillé

Imaginons cette table de routage :

```
Route A: 10.0.0.0/8        via 192.168.1.1
Route B: 10.1.0.0/16       via 192.168.2.1
Route C: 10.1.5.0/24       via 192.168.3.1
Route D: 10.1.5.100/32     via 192.168.4.1
Route E: 0.0.0.0/0         via 192.168.5.1 (route par défaut)
```

**Scénario 1 : Destination = 10.1.5.100**

- Route A correspond : `10.1.5.100` est dans `10.0.0.0/8` ✓
- Route B correspond : `10.1.5.100` est dans `10.1.0.0/16` ✓
- Route C correspond : `10.1.5.100` est dans `10.1.5.0/24` ✓
- Route D correspond : `10.1.5.100` est exactement `10.1.5.100/32` ✓
- Route E correspond : toutes les IP correspondent à `0.0.0.0/0` ✓

**Résultat** : Le routeur choisit la **Route D** car `/32` est le préfixe le plus long (le plus spécifique).

**Scénario 2 : Destination = 10.1.5.50**

- Route A correspond ✓
- Route B correspond ✓
- Route C correspond ✓
- Route D ne correspond pas : `10.1.5.50` ≠ `10.1.5.100` ✗
- Route E correspond ✓

**Résultat** : Le routeur choisit la **Route C** avec `/24`.

**Scénario 3 : Destination = 10.2.3.4**

- Route A correspond ✓
- Route B ne correspond pas : `10.2.x.x` n'est pas dans `10.1.0.0/16` ✗
- Route C ne correspond pas ✗
- Route D ne correspond pas ✗
- Route E correspond ✓

**Résultat** : Le routeur choisit la **Route A** avec `/8`.

**Scénario 4 : Destination = 172.16.0.1**

- Aucune route spécifique ne correspond
- Seule la Route E (route par défaut) correspond

**Résultat** : Le routeur utilise la **Route E**, la route par défaut.

### Visualisation binaire

Le LPM fonctionne en comparant les bits de l'adresse IP avec les bits du réseau défini par le masque.

```
Exemple : Destination 10.1.5.100 et Route 10.1.5.0/24

Destination:  00001010.00000001.00000101.01100100  (10.1.5.100)
Route:        00001010.00000001.00000101.00000000  (10.1.5.0)
Masque /24:   11111111.11111111.11111111.00000000

Comparaison : Les 24 premiers bits correspondent ✓
```

### Cas particulier : Routes de même longueur

Si deux routes ont **exactement la même longueur de préfixe**, le routeur utilise alors la **distance administrative** pour départager.

```bash
# Exemple avec deux routes /24 vers la même destination
ip route 172.16.10.0 255.255.255.0 10.0.0.1  # Route statique, AD = 1
O    172.16.10.0/24 [110/20] via 10.0.0.5    # Route OSPF, AD = 110

# Le routeur choisit la route statique (AD = 1 < 110)
```

> [!tip] Optimisation du routage Vous pouvez créer des routes plus spécifiques (/32, /30) pour forcer certains flux à emprunter un chemin particulier, tout en conservant une route générale (/24, /16) pour le reste du trafic.

### Exercice mental rapide

Avec cette table :

```
192.168.0.0/16    via A
192.168.1.0/24    via B
192.168.1.128/25  via C
```

Où iront ces paquets ?

- `192.168.1.200` → Via B (/24 est le plus long qui correspond)
- `192.168.1.150` → Via C (/25 correspond et est plus spécifique)
- `192.168.2.50` → Via A (seul /16 correspond)

> [!warning] Erreur fréquente Certains débutants pensent que le routeur s'arrête à la première route qui correspond. **Faux !** Le routeur évalue **toutes** les routes correspondantes et choisit celle avec le préfixe le plus long.

---

## 🚪 Route par défaut (Gateway of Last Resort)

La **route par défaut** (aussi appelée **default route** ou **gateway of last resort**) est une route spéciale qui correspond à **toutes les adresses IP** possibles. Elle est représentée par `0.0.0.0/0` ou `::/0` en IPv6.

### Rôle et importance

La route par défaut sert de **filet de sécurité** : si aucune route spécifique ne correspond à l'adresse de destination, le paquet est envoyé vers cette passerelle par défaut.

> [!info] Analogie Imaginez la table de routage comme un système de tri postal. Les routes spécifiques sont comme les adresses complètes avec code postal. La route par défaut est comme le centre de tri régional qui reçoit tout ce qui n'a pas d'adresse précise - il tentera ensuite de rediriger le courrier.

### Configuration de la route par défaut

#### Sur Cisco

```bash
# Méthode 1 : Via next-hop
ip route 0.0.0.0 0.0.0.0 192.168.1.1

# Méthode 2 : Via interface de sortie
ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/0

# Méthode 3 : Via next-hop + interface (recommandé pour les interfaces broadcast)
ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/0 192.168.1.1

# Vérification
show ip route
# S*   0.0.0.0/0 [1/0] via 192.168.1.1
# Le symbole * indique la gateway of last resort
```

#### Sur Linux

```bash
# Ajouter une route par défaut
sudo ip route add default via 192.168.1.1 dev eth0

# Ou avec la commande route (ancienne syntaxe)
sudo route add default gw 192.168.1.1 eth0

# Vérification
ip route show
# default via 192.168.1.1 dev eth0

# Rendre la route persistante (Ubuntu/Debian)
# Éditer /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
```

### Représentation dans la table

```bash
# Cisco
show ip route
Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
       O - OSPF, IA - OSPF inter area
       
Gateway of last resort is 192.168.1.1 to network 0.0.0.0

S*   0.0.0.0/0 [1/0] via 192.168.1.1
     10.0.0.0/8 is variably subnetted, 3 subnets, 2 masks
C       10.1.1.0/24 is directly connected, GigabitEthernet0/0
L       10.1.1.1/32 is directly connected, GigabitEthernet0/0
O       10.2.0.0/16 [110/20] via 10.1.1.2, 00:15:42, GigabitEthernet0/0
```

> [!tip] Symbole astérisque (*) L'astérisque `*` à côté de `S*` ou `O*` indique que cette route est la gateway of last resort active. Cela aide à identifier rapidement la route par défaut utilisée.

### Cas d'usage typiques

#### 1. Connexion Internet

La configuration la plus courante : tous les routeurs internes pointent vers le routeur de bordure, qui lui-même a une route par défaut vers l'Internet.

```bash
# Routeur de bordure d'entreprise
ip route 0.0.0.0 0.0.0.0 203.0.113.1  # Vers le FAI

# Routeurs internes
ip route 0.0.0.0 0.0.0.0 10.0.0.1     # Vers le routeur de bordure
```

#### 2. Topologie hub-and-spoke

Les sites distants (spokes) envoient tout leur trafic non-local vers le site central (hub).

```bash
# Configuration sur un routeur spoke
ip route 0.0.0.0 0.0.0.0 172.16.0.1   # Vers le hub central
```

#### 3. Réseau domestique

Votre box Internet possède une route par défaut vers le réseau du FAI.

```bash
# Configuration typique d'une box
default via 192.0.2.1 dev wan0  # Vers l'infrastructure du FAI
```

### Routes par défaut multiples

Un routeur peut avoir **plusieurs routes par défaut** de sources différentes (statique, OSPF, EIGRP, etc.). Le choix se fait selon :

1. **Distance administrative** (priorité à la source la plus fiable)
2. **Métrique** (si même AD, priorité au coût le plus faible)

```bash
# Exemple avec redondance
ip route 0.0.0.0 0.0.0.0 192.168.1.1              # Route primaire (AD=1)
ip route 0.0.0.0 0.0.0.0 192.168.2.1 250          # Route de backup (AD=250)

# La route via 192.168.2.1 ne sera utilisée que si 192.168.1.1 est inaccessible
```

> [!example] Floating static route Cette technique utilise une route statique avec une AD élevée (>200) comme backup. Elle ne devient active que si la route dynamique principale disparaît.

### Interaction avec le Longest Prefix Match

La route par défaut a le préfixe **le plus court possible** (`/0`), elle est donc toujours la **moins spécifique**.

```bash
# Table de routage simplifiée
0.0.0.0/0          via 192.168.1.1    # Route par défaut
10.0.0.0/8         via 172.16.0.1
10.1.0.0/16        via 172.16.0.2
10.1.5.0/24        via 172.16.0.3

# Destination 10.1.5.50 → utilise 10.1.5.0/24 (plus spécifique)
# Destination 10.2.0.1  → utilise 10.0.0.0/8
# Destination 8.8.8.8   → utilise 0.0.0.0/0 (route par défaut)
```

La route par défaut n'est utilisée que si **aucune autre route plus spécifique** ne correspond.

### Absence de route par défaut

Si un routeur n'a **pas de route par défaut** et reçoit un paquet pour une destination inconnue :

- Il **rejette le paquet**
- Il envoie un message ICMP "Destination Unreachable" à la source
- L'événement peut être consigné dans les logs

> [!warning] Piège classique Dans un réseau d'entreprise, oublier de configurer la route par défaut sur un routeur intermédiaire peut couper l'accès Internet pour tout un segment du réseau, même si le reste de la connectivité fonctionne.

### Route par défaut et sécurité

```bash
# Bonne pratique : Route par défaut + ACL pour contrôler le trafic sortant
ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/0 192.168.1.1

interface GigabitEthernet0/0
 ip access-group OUTBOUND_FILTER out

ip access-list extended OUTBOUND_FILTER
 permit tcp any any eq 80     # HTTP autorisé
 permit tcp any any eq 443    # HTTPS autorisé
 deny ip any any log          # Tout le reste est bloqué et logué
```

> [!tip] Optimisation Dans les grands réseaux, évitez de propager la route par défaut partout. Utilisez plutôt des routes spécifiques et ne configurez la route par défaut que là où c'est nécessaire (routeurs de bordure, équipements utilisateurs).

---

## 🔍 Synthèse et points clés

### Hiérarchie de décision du routage

```
1. Y a-t-il des routes qui correspondent à l'IP de destination ?
   ├─ NON → Rejeter le paquet (si pas de route par défaut)
   └─ OUI → Continuer

2. Quelle est la route avec le préfixe le plus long (LPM) ?
   └─ Sélectionner la route la plus spécifique

3. S'il y a plusieurs routes avec le même préfixe :
   ├─ Comparer la distance administrative (AD)
   ├─ Choisir la route avec l'AD la plus basse
   └─ Si même AD, comparer la métrique

4. Transmettre le paquet via l'interface/next-hop identifié
```

### Récapitulatif des types de routes

|Type|Code|AD|Avantages|Inconvénients|
|---|---|---|---|---|
|**Connectée**|C|0|Automatique, fiable|Limitée aux réseaux locaux|
|**Statique**|S|1|Contrôle total, prévisible|Pas d'adaptation automatique|
|**EIGRP**|D|90|Convergence rapide, efficace|Propriétaire Cisco|
|**OSPF**|O|110|Standard, scalable|Configuration complexe|
|**RIP**|R|120|Simple|Limité à 15 sauts, lent|
|**Externe**|EX, E|170-200|Interconnexion AS|Très complexe|

### Commandes essentielles

```bash
# Visualisation
show ip route                    # Cisco : afficher la table complète
show ip route [réseau]          # Cisco : afficher une route spécifique
ip route show                   # Linux : table de routage
ip route get [IP]               # Linux : quelle route pour cette IP ?

# Configuration Cisco
ip route [dest] [masque] [next-hop|interface] [AD]
no ip route [dest] [masque] [next-hop|interface]

# Configuration Linux
sudo ip route add [dest]/[préfixe] via [next-hop] dev [interface]
sudo ip route del [dest]/[préfixe]

# Dépannage
ping [IP]                       # Test de connectivité
traceroute [IP]                 # Tracer le chemin (tracert sur Windows)
show ip protocols               # Cisco : protocoles de routage actifs
```

> [!tip] Méthode de dépannage Pour diagnostiquer un problème de routage : (1) Vérifiez les routes connectées, (2) Testez la route par défaut, (3) Examinez les routes spécifiques, (4) Utilisez traceroute pour identifier où le trafic est bloqué.

---

Ce cours couvre les **fondamentaux du routage IP** nécessaires pour comprendre comment les paquets circulent dans un réseau. La maîtrise de la table de routage, du Longest Prefix Match et de la route par défaut est essentielle pour tout administrateur réseau.