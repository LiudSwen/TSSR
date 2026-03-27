
## 📚 Table des matières

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

## 🎯 Définition et rôle du routage

### Qu'est-ce que le routage ?

Le **routage** est le processus de sélection du meilleur chemin pour acheminer des paquets de données d'une source à une destination à travers un ou plusieurs réseaux interconnectés. C'est une fonction fondamentale qui opère au niveau de la **couche 3 (réseau)** du modèle OSI.

> [!info] Analogie Le routage fonctionne comme un système de navigation GPS pour les paquets réseau : il détermine quel chemin emprunter parmi plusieurs routes possibles pour atteindre la destination finale le plus efficacement possible.

### Rôle principal du routage

Le routage assure trois fonctions essentielles :

1. **Détermination du chemin optimal** : Choisir la meilleure route basée sur des métriques (distance, bande passante, latence, coût)
2. **Acheminement inter-réseaux** : Permettre la communication entre différents réseaux IP (LAN, WAN, Internet)
3. **Gestion de la topologie** : S'adapter dynamiquement aux changements du réseau (pannes, congestion, ajout/suppression de liens)

> [!example] Exemple concret Lorsque vous envoyez un email depuis votre ordinateur (192.168.1.10) vers un serveur distant (203.0.113.50), le routage :
> 
> - Identifie que la destination n'est pas dans votre réseau local
> - Envoie le paquet à la passerelle par défaut
> - Chaque routeur intermédiaire consulte sa table de routage
> - Le paquet traverse plusieurs réseaux jusqu'à atteindre le serveur

### Pourquoi le routage est-il indispensable ?

Sans routage, chaque appareil ne pourrait communiquer qu'avec les machines du même réseau local. Le routage permet :

- **L'interconnexion mondiale** : Base du fonctionnement d'Internet
- **La segmentation réseau** : Isolation et organisation logique des réseaux
- **L'évolutivité** : Connexion de millions de réseaux hétérogènes
- **La redondance** : Chemins alternatifs en cas de panne

> [!warning] Point crucial : Le routage nécessite que chaque paquet contienne l'adresse IP source ET destination. Sans ces informations, aucun routage n'est possible.

---

## 🔄 Différence entre routage et commutation

Bien que souvent confondus, le routage et la commutation sont deux processus distincts opérant à différents niveaux du modèle OSI.

### Commutation (Switching)

| Caractéristique      | Détails                                |
| -------------------- | -------------------------------------- |
| **Couche OSI**       | Couche 2 (Liaison de données)          |
| **Adressage**        | Adresses MAC (48 bits)                 |
| **Portée**           | Réseau local (LAN) uniquement          |
| **Mécanisme**        | Table CAM/MAC                          |
| **Décision**         | Basée sur l'adresse MAC de destination |
| **Broadcast domain** | Propagé                                |

La commutation déplace les trames Ethernet à l'intérieur d'un même réseau local en utilisant les adresses MAC.

```bash
# Exemple de table MAC d'un switch
Port    MAC Address          VLAN
----    -----------------    ----
Gi0/1   00:1A:2B:3C:4D:5E    10
Gi0/2   00:1A:2B:3C:4D:5F    10
Gi0/3   00:1A:2B:3C:4D:60    20
```

### Routage (Routing)

|Caractéristique|Détails|
|---|---|
|**Couche OSI**|Couche 3 (Réseau)|
|**Adressage**|Adresses IP (32 ou 128 bits)|
|**Portée**|Inter-réseaux (LAN, WAN, Internet)|
|**Mécanisme**|Table de routage|
|**Décision**|Basée sur l'adresse IP de destination|
|**Broadcast domain**|Segmenté|

Le routage déplace les paquets IP entre différents réseaux en utilisant les adresses IP.

```bash
# Exemple de table de routage simplifiée
Destination      Gateway          Interface
------------     -----------      ---------
192.168.1.0/24   0.0.0.0          eth0       # Directement connecté
10.0.0.0/8       192.168.1.254    eth0       # Via passerelle
0.0.0.0/0        203.0.113.1      eth1       # Route par défaut
```

### Comparaison directe

> [!example] Trajet d'un paquet complet Un paquet allant de PC1 (192.168.1.10) à Serveur (203.0.113.50) traverse :
> 
> 1. **Commutation** : PC1 → Switch local (MAC source/dest)
> 2. **Routage** : Switch → Routeur1 (IP source/dest)
> 3. **Commutation** : Routeur1 envoie vers l'interface WAN
> 4. **Routage** : À travers plusieurs routeurs Internet
> 5. **Commutation** : Dernier switch → Serveur

|Critère|Commutation|Routage|
|---|---|---|
|**Vitesse**|Très rapide (hardware)|Plus lent (peut être software)|
|**Intelligence**|Simple (lookup MAC)|Complexe (algorithmes, métriques)|
|**Évolutivité**|Limitée au LAN|Illimitée (Internet entier)|
|**Domaine de collision**|Sépare|N/A|
|**Domaine de broadcast**|Unifie|Sépare|

> [!tip] Astuce mémorisation **Switch = niveau 2 = MAC = même réseau**  
> **Router = niveau 3 = IP = entre réseaux**

---

## ⚔️ Routeur vs commutateur de niveau 3

Les commutateurs de niveau 3 (ou switches L3) brouillent la frontière entre commutation et routage en intégrant des fonctionnalités de routage.

### Routeur traditionnel

Un routeur est un équipement dédié au routage inter-réseaux.

**Caractéristiques principales :**

- **Fonction primaire** : Routage IP entre réseaux différents
- **Optimisation** : Traitement des protocoles de routage complexes
- **Fonctionnalités avancées** :
    - NAT/PAT (translation d'adresses)
    - VPN (tunnels chiffrés)
    - QoS avancée
    - Firewalling stateful
    - Contrôle de chemin granulaire
- **Performance** : Optimisé pour le routage, moins de ports
- **Prix** : Variable selon les fonctionnalités

> [!info] Usage typique Les routeurs sont privilégiés aux bordures de réseau (connexion WAN, Internet, interconnexion de sites) où les fonctionnalités avancées sont nécessaires.

### Commutateur de niveau 3 (Switch L3)

Un switch L3 est fondamentalement un switch avec capacités de routage IP intégrées.

**Caractéristiques principales :**

- **Fonction primaire** : Commutation à haute vitesse + routage inter-VLAN
- **Optimisation** : Commutation hardware (ASIC) avec routage accéléré
- **Fonctionnalités** :
    - Routage inter-VLAN très rapide
    - Protocoles de routage basiques (parfois avancés)
    - ACLs performantes
    - Agrégation de liens
- **Performance** : Très haute densité de ports, throughput élevé
- **Prix** : Souvent plus économique pour haute densité

> [!info] Usage typique Les switches L3 sont privilégiés au cœur du réseau et en distribution pour router efficacement le trafic entre nombreux VLANs.

### Comparaison technique

|Aspect|Routeur|Switch L3|
|---|---|---|
|**Architecture**|CPU + mémoire|ASIC + TCAM|
|**Ports**|2-48 ports|24-96+ ports|
|**Vitesse routage**|Software/hardware mixte|Hardware (ASIC)|
|**Latence**|Quelques microsecondes|Sub-microseconde|
|**Throughput**|Gbps - dizaines Gbps|Centaines Gbps - Tbps|
|**Protocoles routage**|Tous (BGP, OSPF, EIGRP...)|Basiques à avancés|
|**Fonctions WAN**|Oui (PPP, Frame Relay...)|Non ou limité|
|**NAT/VPN**|Oui, robuste|Limité ou absent|
|**Interfaces**|Hétérogènes (Eth, Serial, DSL)|Principalement Ethernet|

### Architecture de routage

```bash
# Configuration routage sur routeur Cisco
interface GigabitEthernet0/0
 ip address 192.168.1.1 255.255.255.0
 no shutdown

router ospf 1
 network 192.168.1.0 0.0.0.255 area 0
 network 10.0.0.0 0.255.255.255 area 1

# Configuration routage sur switch L3 Cisco
interface Vlan10
 ip address 192.168.10.1 255.255.255.0
 
interface Vlan20
 ip address 192.168.20.1 255.255.255.0

ip routing  # Active les fonctions de routage
```

> [!warning] Pièges courants
> 
> - **Oublier `ip routing`** sur un switch L3 Cisco : le routage reste désactivé
> - **Confondre SVI et interface physique** : les interfaces VLAN (SVI) sont logiques
> - **Limites des switches L3** : fonctionnalités WAN et sécurité avancées souvent absentes

### Quand utiliser l'un ou l'autre ?

**Utilisez un routeur quand :**

- Connexion à Internet ou WAN
- Besoin de NAT/PAT obligatoire
- VPN site-à-site requis
- Protocoles de routage complexes (BGP multi-AS)
- Contrôle de flux et politique avancée

**Utilisez un switch L3 quand :**

- Routage inter-VLAN dans le LAN
- Haute densité de ports nécessaire
- Performance maximale requise
- Agrégation de liens (LACP)
- Budget contraint avec beaucoup de ports

> [!tip] Architecture hybride Dans la plupart des réseaux d'entreprise modernes, on combine les deux :
> 
> - **Switch L3** au cœur pour routage inter-VLAN rapide
> - **Routeur** en périphérie pour connexions WAN/Internet et sécurité

---

## 🧠 Plan de données vs plan de contrôle

L'architecture des équipements réseau modernes sépare logiquement deux fonctions fondamentales : le plan de contrôle et le plan de données.

### Plan de contrôle (Control Plane)

Le plan de contrôle est le "cerveau" du routeur. Il prend les décisions sur comment router le trafic.

**Fonctions principales :**

- **Construction de la table de routage** : Exécution des protocoles de routage (OSPF, BGP, EIGRP...)
- **Apprentissage de la topologie** : Échange d'informations avec les routeurs voisins
- **Calcul des meilleurs chemins** : Application des algorithmes (Dijkstra, DUAL...)
- **Gestion des protocoles** : Traitement des messages de contrôle (Hello, LSA, Update...)
- **Maintenance de l'état** : Tables ARP, MAC, sessions...

**Caractéristiques :**

- Opère sur le **CPU** du routeur
- Processus **lent** (relatif) mais **intelligent**
- Trafic **occasionnel** (messages de protocole)
- Non impacté par le volume de trafic utilisateur

```bash
# Exemples de processus du plan de contrôle
- Échange de routes OSPF LSA entre routeurs
- Mise à jour BGP des préfixes Internet
- Keepalive HSRP/VRRP entre routeurs redondants
- Requêtes ARP pour résolution MAC
- Traitement SNMP pour supervision
```

> [!info] Analogie Le plan de contrôle est comme le bureau de planification d'une compagnie de transport : il étudie les cartes, calcule les itinéraires, communique avec d'autres bureaux, mais ne conduit jamais les camions lui-même.

### Plan de données (Data Plane / Forwarding Plane)

Le plan de données est le "muscle" du routeur. Il exécute les décisions de routage pour chaque paquet.

**Fonctions principales :**

- **Acheminement des paquets** : Forwarding basé sur la table de routage pré-calculée
- **Encapsulation/Décapsulation** : Modification des en-têtes L2/L3
- **Application des ACLs** : Filtrage basé sur les règles
- **QoS** : Marquage, classification, mise en file d'attente
- **Comptabilisation** : Statistiques de trafic

**Caractéristiques :**

- Opère sur **ASIC/matériel dédié** (ou CPU pour équipements bas de gamme)
- Processus **ultra-rapide** mais **simple**
- Trafic **intensif continu** (tous les paquets utilisateur)
- Performance critique pour le throughput

```bash
# Exemples de processus du plan de données
- Lookup dans la table de routage pour chaque paquet
- Réécriture des adresses MAC source/destination
- Décrémentation du TTL
- Calcul du checksum IP
- Application des règles QoS et ACL
- Compteurs de paquets/octets
```

> [!info] Analogie Le plan de données est comme les chauffeurs de camions : ils suivent les itinéraires préparés par le bureau, conduisent rapidement, et ne prennent pas de décisions stratégiques.

### Séparation et interaction

```
┌─────────────────────────────────────────────────────────┐
│                    PLAN DE CONTRÔLE                     │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │   Protocoles │  │  Algorithmes │  │    Tables    │   │
│  │   de routage │→ │  de routage  │→ │  de routage  │   │
│  │ OSPF/BGP/... │  │ Dijkstra/... │  │     RIB      │   │
│  └──────────────┘  └──────────────┘  └──────┬───────┘   │
│                                             │           │
│                                             ↓           │
└─────────────────────────────────────────────┼───────────┘
                                             │
                                   Installation des routes
                                             │
┌─────────────────────────────────────────────┼──────────┐
│                    PLAN DE DONNÉES          ↓          │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Réception  │→ │   Lookup     │→ │  Transmission│  │
│  │   du paquet  │  │     FIB      │  │   du paquet  │  │
│  │              │  │   (rapide)   │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Flux de fonctionnement :**

1. **Plan de contrôle** : Protocoles de routage échangent des informations
2. **Plan de contrôle** : Algorithme calcule les meilleurs chemins
3. **Plan de contrôle** : Résultats stockés dans la RIB (Routing Information Base)
4. **Interface** : Meilleures routes copiées vers la FIB (Forwarding Information Base)
5. **Plan de données** : Chaque paquet est routé selon la FIB

> [!warning] Distinction RIB vs FIB
> 
> - **RIB (Routing Table)** : Base de données complète, toutes les routes apprises, dans le plan de contrôle
> - **FIB (Forwarding Table)** : Version optimisée avec uniquement les meilleures routes, dans le plan de données, accessible ultra-rapidement

### Comparaison synthétique

|Aspect|Plan de contrôle|Plan de données|
|---|---|---|
|**Fonction**|Décision ("où envoyer")|Exécution ("envoyer maintenant")|
|**Vitesse**|Lent (ms, secondes)|Ultra-rapide (ns, μs)|
|**Matériel**|CPU général|ASIC spécialisé|
|**Fréquence**|Occasionnel|Continu (chaque paquet)|
|**Charge**|Proportionnelle aux changements|Proportionnelle au trafic|
|**Exemples**|OSPF, BGP, Spanning Tree|Forwarding, ACL, NAT|

### Importance de la séparation

Cette séparation architecturale apporte plusieurs avantages :

1. **Performance** : Le data plane peut utiliser du hardware spécialisé (ASIC) pour atteindre des vitesses térabit
2. **Stabilité** : Un pic de trafic n'affecte pas les protocoles de routage
3. **Sécurité** : Protéger le control plane (rate-limiting, CoPP) sans impacter le forwarding
4. **Évolutivité** : SDN sépare physiquement contrôle centralisé et data distribué

> [!tip] Protection du plan de contrôle Les attaques DoS ciblent souvent le plan de contrôle pour surcharger le CPU. Les bonnes pratiques incluent :
> 
> - **CoPP** (Control Plane Policing) : Limitation du trafic vers le CPU
> - **ACL** sur interfaces de management
> - **Rate-limiting** des protocoles (BGP, OSPF)
> - **Authentication** des voisinages de routage

### Exemple pratique

```bash
# Visualisation sur un routeur Cisco

# Plan de contrôle : Table de routage complète (RIB)
Router# show ip route
Codes: C - connected, S - static, R - RIP, O - OSPF, B - BGP
       D - EIGRP, EX - EIGRP external

O    10.1.1.0/24 [110/20] via 192.168.1.2
O    10.2.1.0/24 [110/30] via 192.168.1.2
B    203.0.113.0/24 [20/0] via 203.0.100.1
C    192.168.1.0/24 is directly connected, GigabitEthernet0/0

# Plan de données : Table de forwarding optimisée (FIB)
Router# show ip cef
Prefix              Next Hop             Interface
0.0.0.0/0           203.0.100.1          GigabitEthernet0/1
10.1.1.0/24         192.168.1.2          GigabitEthernet0/0
10.2.1.0/24         192.168.1.2          GigabitEthernet0/0
192.168.1.0/24      attached             GigabitEthernet0/0
203.0.113.0/24      203.0.100.1          GigabitEthernet0/1
```

> [!example] Scénario complet Quand un paquet arrive destiné à 10.1.1.50 :
> 
> 1. **Plan de données** : Lookup instantané dans la FIB → Next-hop = 192.168.1.2
> 2. **Plan de données** : Réécriture MAC, décrémentation TTL, envoi via Gi0/0
> 3. **Plan de contrôle** : N'est PAS sollicité, continue ses échanges OSPF en arrière-plan
> 
> Résultat : Micro-latence pour le paquet, aucun impact sur le CPU du routeur.

---

## 📖 Récapitulatif

Les fondamentaux du routage IP reposent sur quatre piliers essentiels :

1. **Le routage** permet l'interconnexion de réseaux hétérogènes en déterminant le meilleur chemin pour chaque paquet basé sur l'adresse IP de destination
    
2. **Routage et commutation** opèrent à des niveaux différents : la commutation (L2) utilise les adresses MAC dans un LAN, tandis que le routage (L3) utilise les adresses IP entre réseaux
    
3. **Routeurs et switches L3** se complètent : les routeurs excellent dans les fonctions WAN et sécurité avancée, les switches L3 dans le routage inter-VLAN haute performance
    
4. **Plans de contrôle et de données** séparent l'intelligence (calcul des routes) de l'exécution (forwarding des paquets), permettant performance et stabilité
    

> [!tip] Point clé à retenir Le routage est la fonction qui rend possible Internet et les réseaux d'entreprise modernes. Comprendre la distinction entre ces concepts fondamentaux est essentiel avant d'aborder les protocoles de routage et configurations avancées.

---

_Cours créé pour Obsidian - Partie : Fondamentaux du routage IP_