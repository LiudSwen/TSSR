

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

Le routage IP est le processus fondamental qui permet aux paquets de données de traverser un réseau de leur source vers leur destination. Chaque routeur prend des décisions indépendantes pour chaque paquet, sans maintenir de notion de "session" ou de "flux".

> [!info] Principe fondamental Le routage IP fonctionne selon le principe du **"next-hop"** : chaque routeur détermine uniquement le prochain saut (next hop) vers lequel envoyer le paquet, sans connaître l'intégralité du chemin.

---

## 📦 Processus de routage paquet par paquet

### Principe du routage sans état

Le routage IP est un processus **sans état** (stateless), ce qui signifie que :

- Chaque paquet est traité indépendamment
- Le routeur ne garde pas en mémoire les paquets précédents
- Deux paquets consécutifs d'une même communication peuvent emprunter des chemins différents

### Étapes du processus de routage

Lorsqu'un routeur reçoit un paquet IP, il suit ce processus :

```
1. Réception du paquet sur une interface
   ↓
2. Vérification de l'intégrité (checksum de l'en-tête)
   ↓
3. Extraction de l'adresse IP de destination
   ↓
4. Consultation de la table de routage
   ↓
5. Détermination de l'interface de sortie et du next-hop
   ↓
6. Décrémentation du TTL
   ↓
7. Recalcul du checksum de l'en-tête
   ↓
8. Encapsulation de couche 2 (nouvelle trame)
   ↓
9. Transmission sur l'interface de sortie
```

> [!example] Exemple concret Un paquet arrive sur l'interface Gi0/0 d'un routeur avec l'IP destination 192.168.50.100. Le routeur :
> 
> - Vérifie que le paquet n'est pas corrompu
> - Consulte sa table de routage
> - Trouve que 192.168.50.0/24 est accessible via Gi0/1 et le next-hop 10.0.0.2
> - Transmet le paquet encapsulé dans une nouvelle trame Ethernet vers 10.0.0.2

### Indépendance des décisions

> [!warning] Point important Chaque routeur prend sa décision de routage de manière **autonome et locale**. Il ne connaît pas :
> 
> - L'origine exacte du paquet
> - La destination finale complète du chemin
> - Les décisions prises par les routeurs précédents ou suivants

Cette indépendance permet :

- ✅ La scalabilité des réseaux
- ✅ La résilience (adaptation automatique aux pannes)
- ✅ La simplicité du protocole
- ❌ Mais peut causer des boucles de routage sans protocoles de routage appropriés

---

## 🗂️ Recherche dans la table de routage

### Structure de la table de routage

La table de routage contient des **entrées de route** avec les informations suivantes :

|Champ|Description|Exemple|
|---|---|---|
|**Réseau destination**|Réseau cible (avec masque)|192.168.10.0/24|
|**Masque de sous-réseau**|Définit la taille du réseau|255.255.255.0 ou /24|
|**Next-hop**|Adresse IP du prochain routeur|10.0.0.1|
|**Interface de sortie**|Interface physique à utiliser|Gi0/1, eth0|
|**Métrique**|Coût de la route|10, 110, 1|
|**Distance administrative**|Fiabilité de la source|1 (connecté), 110 (OSPF)|

### Algorithme de recherche : Longest Prefix Match

Le routeur utilise l'algorithme du **Longest Prefix Match** (correspondance du préfixe le plus long) :

```
1. Comparer l'IP destination avec chaque entrée de la table
2. Appliquer le masque de sous-réseau à l'IP destination
3. Identifier toutes les correspondances possibles
4. Choisir la route avec le masque le PLUS LONG (le plus spécifique)
5. Si plusieurs routes ont le même masque, utiliser la distance administrative
6. Si égalité, utiliser la métrique
```

> [!example] Exemple de Longest Prefix Match Table de routage :
> 
> ```
> 10.0.0.0/8       via 192.168.1.1
> 10.1.0.0/16      via 192.168.1.2
> 10.1.2.0/24      via 192.168.1.3
> 0.0.0.0/0        via 192.168.1.254  (route par défaut)
> ```
> 
> Pour un paquet vers **10.1.2.50** :
> 
> - ✅ Correspond à 10.0.0.0/8 (8 bits communs)
> - ✅ Correspond à 10.1.0.0/16 (16 bits communs)
> - ✅ Correspond à 10.1.2.0/24 (24 bits communs) ← **Route choisie !**
> - ✅ Correspond à 0.0.0.0/0 (0 bits, correspond à tout)

### Cas particuliers

#### Route par défaut (Default Gateway)

```
0.0.0.0/0  ou  ::/0 (IPv6)
```

> [!info] Route par défaut La route par défaut est utilisée quand **aucune autre route** ne correspond. Elle a le masque le plus court possible (0 bits).

#### Route directement connectée

```bash
# Réseau directement connecté sur une interface
192.168.1.0/24 dev eth0  proto kernel  scope link
```

> [!tip] Astuce Les réseaux directement connectés ont toujours la **distance administrative la plus faible** (0 ou 1), donc ils sont prioritaires.

#### Route statique vs dynamique

|Type|Distance administrative|Quand l'utiliser|
|---|---|---|
|**Connecté**|0-1|Automatique|
|**Statique**|1|Petits réseaux, routes spécifiques|
|**OSPF**|110|Réseaux moyens/grands|
|**RIP**|120|Réseaux simples|
|**BGP**|20 (eBGP) / 200 (iBGP)|Internet, AS multiples|

### Commandes de consultation

```bash
# Linux
ip route show
# ou
route -n

# Cisco IOS
show ip route

# Windows
route print
# ou
netsh interface ipv4 show route
```

> [!warning] Piège courant Si plusieurs routes ont le même préfixe ET la même distance administrative, le routeur utilise le **load balancing** (répartition de charge) ou choisit selon la métrique. Ne supposez jamais qu'une route spécifique sera toujours utilisée !

---

## ⏱️ Décrémentation du TTL

### Qu'est-ce que le TTL ?

Le **TTL (Time To Live)** est un champ de 8 bits dans l'en-tête IPv4 qui limite la durée de vie d'un paquet dans le réseau.

> [!info] Objectif du TTL Empêcher les paquets de circuler indéfiniment dans le réseau en cas de :
> 
> - Boucles de routage
> - Configuration incorrecte
> - Dysfonctionnement du réseau

### Fonctionnement

```
Valeur initiale (émetteur) : 64, 128, ou 255
     ↓
Routeur 1 : TTL = TTL - 1
     ↓
Routeur 2 : TTL = TTL - 1
     ↓
...
     ↓
Si TTL = 0 → Paquet SUPPRIMÉ
```

#### Processus détaillé

1. **À l'émission** : L'hôte source définit une valeur initiale (typiquement 64 ou 128)
2. **À chaque saut** : Le routeur décrémente le TTL de 1
3. **Avant décrémentation** : Si TTL = 1, le paquet sera supprimé
4. **TTL = 0** : Le routeur :
    - Supprime le paquet
    - Envoie un message ICMP "Time Exceeded" à l'émetteur
    - N'encapsule PAS le paquet original dans ICMP (juste les premiers octets)

> [!example] Exemple pratique
> 
> ```
> Source : 192.168.1.10 (TTL initial = 64)
>    ↓
> Routeur A : Reçoit TTL=64, envoie avec TTL=63
>    ↓
> Routeur B : Reçoit TTL=63, envoie avec TTL=62
>    ↓
> Routeur C : Reçoit TTL=62, envoie avec TTL=61
>    ↓
> Destination : 10.0.0.50 (reçoit TTL=61)
> ```

### Valeurs typiques de TTL

|Système d'exploitation|TTL par défaut|
|---|---|
|**Linux**|64|
|**Windows**|128|
|**Cisco IOS**|255|
|**macOS**|64|

> [!tip] Astuce pour l'identification On peut parfois identifier le système d'exploitation d'une machine distante en observant le TTL dans les réponses ping :
> 
> - TTL ≈ 64 → Probablement Linux/Unix
> - TTL ≈ 128 → Probablement Windows
> - TTL ≈ 255 → Probablement équipement réseau

### Utilisation du TTL : la commande traceroute

```bash
# Linux/macOS
traceroute 8.8.8.8

# Windows
tracert 8.8.8.8
```

**Principe de fonctionnement** :

1. Envoi d'un paquet avec TTL=1 → Le premier routeur répond "Time Exceeded"
2. Envoi d'un paquet avec TTL=2 → Le deuxième routeur répond "Time Exceeded"
3. Envoi d'un paquet avec TTL=3 → Le troisième routeur répond "Time Exceeded"
4. Et ainsi de suite jusqu'à atteindre la destination

> [!example] Sortie traceroute
> 
> ```bash
> $ traceroute google.com
> traceroute to google.com (142.250.201.46), 30 hops max
>  1  192.168.1.1 (192.168.1.1)  2.456 ms
>  2  10.0.0.1 (10.0.0.1)  8.123 ms
>  3  89.2.0.1 (89.2.0.1)  12.789 ms
>  4  * * *  (routeur ne répond pas)
>  5  142.250.201.46 (142.250.201.46)  18.234 ms
> ```

> [!warning] Pièges courants
> 
> - **TTL trop faible** : Si la valeur initiale est trop basse, les paquets n'atteindront jamais les destinations éloignées
> - **Filtrage ICMP** : Certains routeurs ne renvoient pas de messages "Time Exceeded", ce qui rend traceroute incomplet
> - **Confusion avec TCP TTL** : Ne pas confondre avec le TTL DNS (durée de validité d'un enregistrement DNS)

### IPv6 : Hop Limit

En IPv6, le TTL est remplacé par le **Hop Limit**, qui fonctionne exactement de la même manière :

- Même principe de décrémentation
- Même valeur initiale typique (64)
- Même message ICMPv6 "Time Exceeded"

---

## ✂️ Fragmentation IP

### Pourquoi fragmenter ?

La fragmentation IP se produit lorsqu'un paquet IP est **trop grand** pour être transmis sur un lien réseau en une seule trame.

> [!info] MTU : Maximum Transmission Unit Le **MTU** est la taille maximale (en octets) d'une trame pouvant être transmise sur une liaison réseau sans fragmentation.
> 
> MTU standard Ethernet : **1500 octets**

### Quand la fragmentation se produit-elle ?

```
Paquet IP (2000 octets)
     ↓
Interface avec MTU 1500 octets
     ↓
FRAGMENTATION nécessaire !
```

Cas typiques :

- Paquet de 2000 octets → MTU Ethernet 1500 octets
- Tunnel VPN (encapsulation supplémentaire)
- Liaison PPPoE (MTU réduit à 1492 octets)
- Liaison avec MTU non standard

### Processus de fragmentation

#### Champs de l'en-tête IP utilisés

|Champ|Taille|Fonction|
|---|---|---|
|**Identification**|16 bits|Identifiant unique du paquet original|
|**Flags**|3 bits|DF (Don't Fragment), MF (More Fragments)|
|**Fragment Offset**|13 bits|Position du fragment dans le paquet original|

#### Flags de fragmentation

```
Bit 0 : Réservé (toujours 0)
Bit 1 : DF (Don't Fragment)
        0 = Fragmentation autorisée
        1 = Fragmentation interdite → Si nécessaire, paquet supprimé
Bit 2 : MF (More Fragments)
        0 = Dernier fragment (ou paquet non fragmenté)
        1 = D'autres fragments suivent
```

> [!example] Exemple de fragmentation Paquet original : 3000 octets de données (+ 20 octets d'en-tête IP) MTU : 1500 octets
> 
> **Fragment 1** :
> 
> - Taille : 1500 octets (1480 données + 20 en-tête)
> - Identification : 12345
> - MF = 1 (d'autres fragments suivent)
> - Offset = 0
> 
> **Fragment 2** :
> 
> - Taille : 1500 octets (1480 données + 20 en-tête)
> - Identification : 12345 (même ID)
> - MF = 1
> - Offset = 1480 (position dans le paquet original)
> 
> **Fragment 3** :
> 
> - Taille : 60 octets (40 données + 20 en-tête)
> - Identification : 12345 (même ID)
> - MF = 0 (dernier fragment)
> - Offset = 2960

### Réassemblage

> [!warning] Point critique Le **réassemblage** des fragments se fait **uniquement à la destination finale**, jamais sur les routeurs intermédiaires.

**Processus de réassemblage** :

1. La destination reçoit les fragments (éventuellement dans le désordre)
2. Elle les identifie grâce au champ "Identification"
3. Elle les ordonne grâce au "Fragment Offset"
4. Elle attend tous les fragments (MF=0 indique le dernier)
5. Elle reconstruit le paquet original
6. Timeout : Si tous les fragments n'arrivent pas dans un délai (généralement 60s), abandon

### Problèmes liés à la fragmentation

> [!warning] Inconvénients majeurs
> 
> 1. **Performance dégradée** : Overhead de traitement sur les routeurs et la destination
> 2. **Perte de fragments** : Si un seul fragment est perdu, tout le paquet est inutilisable
> 3. **Problèmes de sécurité** : Certains pare-feux bloquent les fragments
> 4. **Complexité** : Débogage difficile

### Path MTU Discovery (PMTUD)

Pour éviter la fragmentation, les hôtes modernes utilisent **Path MTU Discovery** :

```
1. L'émetteur envoie des paquets avec le flag DF=1 (Don't Fragment)
2. Si un routeur doit fragmenter, il supprime le paquet
3. Le routeur renvoie un message ICMP "Fragmentation Needed" avec le MTU requis
4. L'émetteur ajuste la taille de ses paquets en conséquence
5. Processus itératif jusqu'à trouver le MTU du chemin
```

> [!example] PMTUD en action
> 
> ```
> Source (MTU 1500) → Routeur A (MTU 1500) → Routeur B (MTU 1492) → Dest
> 
> 1. Source envoie 1500 octets, DF=1
> 2. Routeur B ne peut pas transmettre (MTU 1492)
> 3. Routeur B envoie ICMP "Fragmentation Needed, MTU=1492"
> 4. Source réduit ses paquets à 1492 octets
> 5. Communication réussie !
> ```

### Commandes de diagnostic

```bash
# Linux : Tester avec des paquets de taille spécifique
ping -M do -s 1472 8.8.8.8  # -M do = Don't Fragment, -s = taille

# Trouver le MTU du chemin
tracepath 8.8.8.8

# Afficher le MTU des interfaces locales
ip link show

# Windows : Ping avec Don't Fragment
ping -f -l 1472 8.8.8.8
```

> [!tip] Calcul de la taille de ping Taille du ping = MTU - 20 (en-tête IP) - 8 (en-tête ICMP)
> 
> Pour MTU 1500 : ping de 1472 octets maximum sans fragmentation

### IPv6 et fragmentation

> [!info] Différence majeure en IPv6 En **IPv6**, les routeurs intermédiaires ne peuvent **JAMAIS** fragmenter les paquets. Seul l'émetteur peut fragmenter.
> 
> - MTU minimum obligatoire : 1280 octets
> - Path MTU Discovery est **obligatoire**
> - Champ de fragmentation déplacé dans une extension header

### Bonnes pratiques

✅ **À faire** :

- Utiliser PMTUD (flag DF)
- Configurer correctement le MTU sur toutes les interfaces
- Surveiller les messages ICMP "Fragmentation Needed"
- Préférer des tailles de paquets adaptées (< 1400 octets pour la sécurité)

❌ **À éviter** :

- Bloquer tous les messages ICMP (empêche PMTUD)
- Ignorer les avertissements de fragmentation
- Utiliser des MTU non standard sans raison
- Compter sur la fragmentation pour les performances

---

## 🎓 Récapitulatif

Les fondamentaux du routage IP reposent sur quatre piliers essentiels :

1. **Routage paquet par paquet** : Traitement indépendant, décisions locales, absence d'état
2. **Table de routage** : Longest Prefix Match, hiérarchie des routes, distances administratives
3. **TTL** : Protection contre les boucles, outil de diagnostic (traceroute), décrémentation systématique
4. **Fragmentation** : Division des paquets trop grands, réassemblage à destination, préférer PMTUD

> [!tip] Règle d'or Un routeur ne connaît que son voisinage immédiat. Il fait confiance à sa table de routage pour prendre la meilleure décision locale, ce qui aboutit globalement au bon chemin grâce aux protocoles de routage.