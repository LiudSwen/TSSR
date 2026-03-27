

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

## 🔗 Rôle de la couche réseau

### Modèle OSI

La couche réseau correspond à la **couche 3** du modèle OSI (Open Systems Interconnection). Elle se situe entre la couche liaison de données (couche 2) et la couche transport (couche 4).

> [!info] Position dans le modèle OSI
> 
> - **Couche 7** : Application
> - **Couche 6** : Présentation
> - **Couche 5** : Session
> - **Couche 4** : Transport
> - **Couche 3** : Réseau ← **IP opère ici**
> - **Couche 2** : Liaison de données
> - **Couche 1** : Physique

### Modèle TCP/IP

Dans le modèle TCP/IP (plus simplifié), la couche réseau est appelée **couche Internet** et correspond également à l'endroit où opère le protocole IP.

> [!info] Position dans le modèle TCP/IP
> 
> - **Couche 4** : Application
> - **Couche 3** : Transport
> - **Couche 2** : Internet ← **IP opère ici**
> - **Couche 1** : Accès réseau

### Fonctions principales

La couche réseau assure plusieurs fonctions essentielles :

#### 1. **Adressage logique**

- Attribution d'adresses IP uniques aux équipements
- Identification de l'expéditeur et du destinataire
- Indépendance par rapport aux adresses physiques (MAC)

#### 2. **Routage**

- Détermination du meilleur chemin pour acheminer les paquets
- Passage d'un réseau à un autre via des routeurs
- Utilisation de tables de routage et d'algorithmes de routage

#### 3. **Encapsulation**

- Les données de la couche transport sont encapsulées dans des paquets IP
- Ajout d'un en-tête contenant les informations de routage
- Le paquet devient l'unité de données de la couche réseau

#### 4. **Fragmentation et réassemblage**

- Division des paquets trop volumineux pour les réseaux intermédiaires
- Réassemblage des fragments à destination
- Adaptation à la MTU (Maximum Transmission Unit) de chaque réseau

#### 5. **Gestion des erreurs**

- Détection de certaines erreurs via des checksums
- Signalement des problèmes (via ICMP par exemple)
- Pas de correction d'erreurs (c'est le rôle de la couche transport)

> [!warning] IP est un protocole non fiable IP ne garantit pas :
> 
> - La livraison des paquets (pas d'accusé de réception)
> - L'ordre d'arrivée des paquets
> - L'absence de duplication
> 
> Ces garanties sont assurées par des protocoles de couche supérieure comme TCP.

> [!tip] Principe de fonctionnement Imaginez IP comme un service postal : il prend votre lettre, y ajoute une adresse, et fait de son mieux pour la livrer. Mais il ne garantit pas qu'elle arrivera, ni quand elle arrivera, ni dans quel ordre si vous envoyez plusieurs lettres.

---

## ⚖️ Différence entre IPv4 et IPv6

### IPv4

**Internet Protocol version 4** est le protocole historique, déployé depuis les années 1980.

#### Caractéristiques principales

**Format d'adresse :**

- Adresse sur **32 bits** (4 octets)
- Notation décimale pointée : `192.168.1.1`
- Chaque octet varie de 0 à 255

**Espace d'adressage :**

- **4,3 milliards** d'adresses théoriques (2³²)
- En pratique, beaucoup moins à cause des adresses réservées
- Épuisement progressif depuis les années 2000

**Classes d'adresses :**

|Classe|Plage|Usage|Masque par défaut|
|---|---|---|---|
|A|0.0.0.0 - 127.255.255.255|Très grands réseaux|/8 (255.0.0.0)|
|B|128.0.0.0 - 191.255.255.255|Réseaux moyens|/16 (255.255.0.0)|
|C|192.0.0.0 - 223.255.255.255|Petits réseaux|/24 (255.255.255.0)|
|D|224.0.0.0 - 239.255.255.255|Multicast|-|
|E|240.0.0.0 - 255.255.255.255|Recherche|-|

> [!example] Exemples d'adresses IPv4
> 
> - `8.8.8.8` - DNS public de Google
> - `192.168.1.1` - Adresse privée typique d'une box
> - `127.0.0.1` - Localhost (boucle locale)
> - `10.0.0.1` - Adresse privée classe A

**Adresses privées (RFC 1918) :**

- `10.0.0.0/8` - 10.0.0.0 à 10.255.255.255
- `172.16.0.0/12` - 172.16.0.0 à 172.31.255.255
- `192.168.0.0/16` - 192.168.0.0 à 192.168.255.255

> [!tip] NAT pour pallier la pénurie Le NAT (Network Address Translation) permet à plusieurs appareils d'un réseau privé de partager une seule adresse IP publique. C'est la solution la plus courante pour économiser les adresses IPv4.

### IPv6

**Internet Protocol version 6** est la nouvelle version, conçue pour résoudre les limitations d'IPv4.

#### Caractéristiques principales

**Format d'adresse :**

- Adresse sur **128 bits** (16 octets)
- Notation hexadécimale avec séparateurs `:`
- Exemple : `2001:0db8:85a3:0000:0000:8a2e:0370:7334`

**Simplifications d'écriture :**

```
# Adresse complète
2001:0db8:0000:0000:0000:0000:0000:0001

# Suppression des zéros de tête
2001:db8:0:0:0:0:0:1

# Compression de groupes de zéros (::)
2001:db8::1

# Localhost IPv6
::1
```

> [!warning] Règle du :: La compression `::` ne peut être utilisée qu'une seule fois dans une adresse pour éviter l'ambiguïté.
> 
> ✅ Correct : `2001:db8::1:0:0:1` ❌ Incorrect : `2001:db8::1::1`

**Espace d'adressage :**

- **340 sextillions** d'adresses (2¹²⁸)
- Soit 340 282 366 920 938 463 463 374 607 431 768 211 456 adresses
- Suffisant pour attribuer des milliards d'adresses à chaque être humain

**Types d'adresses :**

|Type|Préfixe|Description|
|---|---|---|
|Unicast globale|2000::/3|Routables sur Internet|
|Link-local|fe80::/10|Communication sur le même lien|
|Unique local|fc00::/7|Équivalent des adresses privées IPv4|
|Multicast|ff00::/8|Communication de groupe|
|Loopback|::1/128|Boucle locale|

> [!example] Exemples d'adresses IPv6
> 
> - `2001:4860:4860::8888` - DNS public de Google
> - `fe80::1` - Adresse link-local
> - `::1` - Localhost
> - `ff02::1` - Tous les nœuds du lien local

**Avantages d'IPv6 :**

- ✅ Espace d'adressage quasi illimité
- ✅ Configuration automatique (SLAAC)
- ✅ Sécurité intégrée (IPsec obligatoire)
- ✅ Meilleur support du multicast
- ✅ Pas de fragmentation par les routeurs
- ✅ En-tête simplifié pour un routage plus efficace

### Tableau comparatif

|Caractéristique|IPv4|IPv6|
|---|---|---|
|**Taille d'adresse**|32 bits|128 bits|
|**Notation**|Décimale pointée|Hexadécimale avec `:`|
|**Nombre d'adresses**|~4,3 milliards|~340 sextillions|
|**Configuration**|Manuelle ou DHCP|Auto-configuration (SLAAC)|
|**Checksum en-tête**|Oui|Non|
|**Fragmentation**|Par routeurs|Uniquement source|
|**Broadcast**|Oui|Non (multicast à la place)|
|**IPsec**|Optionnel|Obligatoire|
|**Taille en-tête**|Variable (20-60 octets)|Fixe (40 octets)|
|**NAT**|Très courant|Pas nécessaire|
|**ARP**|Oui|Remplacé par NDP|
|**QoS**|Champ TOS|Meilleure gestion native|

> [!info] Coexistence IPv4/IPv6 Les deux protocoles coexistent actuellement grâce à plusieurs mécanismes :
> 
> - **Double pile** : un équipement gère IPv4 et IPv6 simultanément
> - **Tunneling** : encapsulation d'IPv6 dans IPv4 (6to4, Teredo)
> - **Translation** : conversion entre IPv4 et IPv6 (NAT64)

---

## 📦 Structure d'un paquet IP

### Paquet IPv4

Un paquet IPv4 est composé d'un **en-tête** et d'une **charge utile** (données).

#### Structure de l'en-tête IPv4

L'en-tête IPv4 fait au minimum **20 octets** et peut aller jusqu'à **60 octets** avec options.

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version|  IHL  |Type of Service|          Total Length         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Identification        |Flags|      Fragment Offset    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Time to Live |    Protocol   |         Header Checksum       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Source Address                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Destination Address                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options (si IHL > 5)                       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

#### Détail des champs

|Champ|Taille|Description|
|---|---|---|
|**Version**|4 bits|Version du protocole (4 pour IPv4)|
|**IHL**|4 bits|Longueur de l'en-tête en mots de 32 bits (min: 5 = 20 octets)|
|**Type of Service (TOS)**|8 bits|Qualité de service et priorité du paquet|
|**Total Length**|16 bits|Longueur totale du paquet (en-tête + données) en octets (max: 65535)|
|**Identification**|16 bits|Identifiant unique pour les fragments d'un même paquet|
|**Flags**|3 bits|Contrôle de fragmentation (DF, MF)|
|**Fragment Offset**|13 bits|Position du fragment dans le paquet original|
|**Time To Live (TTL)**|8 bits|Nombre de sauts maximum (décrementé à chaque routeur)|
|**Protocol**|8 bits|Protocole de couche supérieure (1=ICMP, 6=TCP, 17=UDP)|
|**Header Checksum**|16 bits|Somme de contrôle de l'en-tête uniquement|
|**Source Address**|32 bits|Adresse IP source|
|**Destination Address**|32 bits|Adresse IP de destination|
|**Options**|Variable|Options facultatives (rarement utilisées)|

#### Champs importants expliqués

**TTL (Time To Live) :**

- Valeur initiale typique : 64, 128 ou 255
- Décrementé de 1 à chaque passage dans un routeur
- Si TTL atteint 0, le paquet est détruit
- Évite les boucles infinies dans le réseau

> [!example] Utilisation du TTL La commande `traceroute` exploite le TTL en envoyant des paquets avec des TTL croissants (1, 2, 3...) pour identifier les routeurs sur le chemin.

**Flags de fragmentation :**

- **Bit 0** : Réservé (toujours 0)
- **Bit 1 (DF)** : Don't Fragment - interdit la fragmentation
- **Bit 2 (MF)** : More Fragments - indique qu'il y a d'autres fragments

**Protocol :** Indique le protocole encapsulé dans la charge utile :

- `1` : ICMP (Internet Control Message Protocol)
- `6` : TCP (Transmission Control Protocol)
- `17` : UDP (User Datagram Protocol)
- `41` : IPv6 (tunneling)
- `89` : OSPF (protocole de routage)

> [!tip] Analyser un paquet avec Wireshark Pour visualiser la structure d'un paquet IPv4 :
> 
> ```bash
> # Capturer le trafic sur l'interface eth0
> sudo tcpdump -i eth0 -w capture.pcap
> 
> # Ouvrir dans Wireshark pour analyse détaillée
> wireshark capture.pcap
> ```

**Checksum :**

- Calculé uniquement sur l'en-tête (pas les données)
- Recalculé à chaque routeur (car TTL change)
- Permet de détecter les erreurs de transmission

> [!warning] Fragmentation IPv4 La fragmentation peut être effectuée par n'importe quel routeur sur le chemin. Cependant :
> 
> - Elle réduit les performances
> - Un fragment perdu = paquet entier perdu
> - Peut poser des problèmes de sécurité
> 
> Bonne pratique : utiliser le flag DF et ajuster la taille des paquets (Path MTU Discovery).

### Paquet IPv6

L'en-tête IPv6 a été simplifié pour améliorer l'efficacité du routage.

#### Structure de l'en-tête IPv6

L'en-tête IPv6 fait **toujours 40 octets** (taille fixe).

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

#### Détail des champs

|Champ|Taille|Description|
|---|---|---|
|**Version**|4 bits|Version du protocole (6 pour IPv6)|
|**Traffic Class**|8 bits|Priorité et qualité de service (équivalent TOS d'IPv4)|
|**Flow Label**|20 bits|Identifie un flux pour un traitement spécial|
|**Payload Length**|16 bits|Taille de la charge utile (sans l'en-tête de 40 octets)|
|**Next Header**|8 bits|Type d'en-tête suivant ou protocole encapsulé|
|**Hop Limit**|8 bits|Équivalent du TTL d'IPv4|
|**Source Address**|128 bits|Adresse IPv6 source|
|**Destination Address**|128 bits|Adresse IPv6 de destination|

#### Différences clés avec IPv4

**Simplifications :**

- ❌ Pas de checksum d'en-tête (délégué aux couches supérieures/inférieures)
- ❌ Pas de champ IHL (taille fixe)
- ❌ Pas de fragmentation par les routeurs
- ❌ Pas de champ Options dans l'en-tête de base

**Nouveautés :**

- ✅ Flow Label pour la QoS
- ✅ Extension Headers (en-têtes d'extension)
- ✅ Taille fixe de 40 octets

> [!info] En-têtes d'extension IPv6 IPv6 utilise des en-têtes d'extension chainés pour les fonctionnalités optionnelles :
> 
> - **Hop-by-Hop Options** : Options traitées par chaque routeur
> - **Routing** : Routage source
> - **Fragment** : Fragmentation (uniquement par la source)
> - **Destination Options** : Options pour le destinataire
> - **Authentication (AH)** : Sécurité IPsec
> - **ESP** : Chiffrement IPsec
> 
> Chaque en-tête pointe vers le suivant via le champ "Next Header".

**Next Header :** Fonctionne comme le champ Protocol d'IPv4 :

- `6` : TCP
- `17` : UDP
- `58` : ICMPv6
- `0` : Hop-by-Hop Options
- `43` : Routing Header
- `44` : Fragment Header

**Hop Limit :**

- Identique au TTL d'IPv4
- Valeur initiale recommandée : 64
- Décrementé à chaque routeur

> [!tip] Fragmentation en IPv6 En IPv6, seul l'émetteur peut fragmenter. Le processus :
> 
> 1. L'émetteur découvre la MTU du chemin (Path MTU Discovery)
> 2. Si le paquet est trop grand, l'émetteur le fragmente
> 3. Un en-tête d'extension "Fragment" est ajouté
> 4. Le destinataire réassemble les fragments
> 
> Avantage : Les routeurs ne perdent pas de temps à fragmenter.

#### Comparaison visuelle des en-têtes

**Taille :**

- IPv4 : 20-60 octets (variable)
- IPv6 : 40 octets (fixe)

**Complexité :**

- IPv4 : 13 champs dans l'en-tête de base
- IPv6 : 8 champs dans l'en-tête de base

**Efficacité de traitement :**

- IPv6 est plus rapide à traiter (taille fixe, pas de checksum, pas de fragmentation intermédiaire)

> [!example] Voir un paquet IPv6
> 
> ```bash
> # Capturer uniquement du trafic IPv6
> sudo tcpdump -i eth0 ip6
> 
> # Ping IPv6 vers Google DNS
> ping6 2001:4860:4860::8888
> 
> # Afficher les routes IPv6
> ip -6 route show
> ```

---

## 🎯 Pièges courants

> [!warning] Confusions fréquentes
> 
> **1. Adresse IP vs Adresse MAC**
> 
> - L'adresse IP (couche 3) est logique et modifiable
> - L'adresse MAC (couche 2) est physique et gravée dans la carte réseau
> - IP sert au routage entre réseaux, MAC à la communication locale
> 
> **2. Masque de sous-réseau**
> 
> - Le masque définit quelle partie de l'adresse est le réseau
> - `/24` = `255.255.255.0` = 256 adresses (254 utilisables)
> - Ne pas confondre avec l'adresse de réseau ou de broadcast
> 
> **3. TTL ne mesure pas le temps**
> 
> - Malgré son nom "Time To Live"
> - C'est un compteur de sauts (hops), pas de secondes
> - Chaque routeur le décrémente de 1
> 
> **4. IPv6 n'est pas "juste plus long"**
> 
> - Architecture fondamentalement différente
> - Pas de NAT nécessaire, auto-configuration native
> - En-têtes d'extension au lieu d'options dans l'en-tête

---

## 💡 Bonnes pratiques

### Pour IPv4

✅ **Utiliser CIDR** plutôt que les classes d'adresses obsolètes

```
Ancien : Réseau de classe C avec masque 255.255.255.0
Moderne : 192.168.1.0/24 (notation CIDR)
```

✅ **Définir le flag DF** pour éviter la fragmentation problématique

```bash
# Ping avec DF et taille de paquet personnalisée
ping -M do -s 1472 google.com
```

✅ **Surveiller le TTL** pour détecter les problèmes de routage

```bash
# TTL faible = beaucoup de sauts ou problème
ping -c 1 google.com | grep ttl
```

### Pour IPv6

✅ **Activer IPv6** même si pas utilisé immédiatement

```bash
# Vérifier le support IPv6
cat /proc/sys/net/ipv6/conf/all/disable_ipv6
```

✅ **Utiliser la compression d'adresse** correctement

```
Complet : 2001:0db8:0000:0000:0000:0000:0000:0001
Compressé : 2001:db8::1
```

✅ **Comprendre les types d'adresses** avant de configurer

- Link-local : communication locale automatique
- Unique local : équivalent privé
- Global : routabilité Internet

### Général

✅ **Tester la connectivité** à plusieurs niveaux

```bash
# Couche 3 : IP
ping 8.8.8.8

# Couche 4 : TCP/UDP
telnet google.com 80

# Couche 7 : Application
curl https://google.com
```

✅ **Documenter la topologie** avec les adresses et masques ✅ **Prévoir la scalabilité** lors du choix d'un plan d'adressage ✅ **Implémenter progressivement IPv6** en double pile

---

## 🔍 Astuces

### Calculer rapidement les plages d'adresses

Pour un `/24` (masque 255.255.255.0) :

- **256 adresses totales**
- **254 adresses utilisables** (excluant réseau et broadcast)
- Premier hôte : `.1`
- Dernier hôte : `.254`
- Broadcast : `.255`

Pour un `/25` (masque 255.255.255.128) :

- **128 adresses par sous-réseau**
- **126 adresses utilisables**
- Deux sous-réseaux : `.0` et `.128`

> [!tip] Formule universelle Pour un `/n` :
> 
> - Nombre d'adresses = 2^(32-n)
> - Hôtes utilisables = 2^(32-n) - 2

### Identifier rapidement un type d'adresse IPv6

```
2xxx:xxxx:... → Global Unicast (routé Internet)
fd00::/8      → Unique Local (privé)
fe80::/10     → Link-Local (local au lien)
ff00::/8      → Multicast
::1           → Loopback
::            → Adresse non spécifiée
```

### Commandes de diagnostic rapides

```bash
# Afficher la configuration IP
ip addr show          # Linux
ipconfig /all         # Windows

# Tester la connectivité
ping -c 4 8.8.8.8    # IPv4
ping6 2001:4860:4860::8888  # IPv6

# Tracer le chemin
traceroute google.com         # Linux
traceroute6 google.com        # IPv6 Linux
tracert google.com            # Windows

# Analyser les paquets
sudo tcpdump -i eth0 -n icmp  # Capturer ICMP
sudo tcpdump -i eth0 -n ip6   # Capturer IPv6
```

### Convertir entre notations

**Masque décimal → CIDR :**

```
255.255.255.0   → /24
255.255.255.128 → /25
255.255.254.0   → /23
255.255.0.0     → /16
```

**CIDR → Nombre d'hôtes :**

```
/30 → 4 adresses (2 hôtes) - Liens point-à-point
/29 → 8 adresses (6 hôtes)
/28 → 16 adresses (14 hôtes)
/24 → 256 adresses (254 hôtes)
```

---

**✨ Vous maîtrisez maintenant les fondamentaux des protocoles IP !**