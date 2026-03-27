

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

## 🔍 Qu'est-ce que le NAT

### Définition

Le **NAT (Network Address Translation)** est un mécanisme de traduction d'adresses IP qui permet de modifier les informations d'adressage réseau dans les en-têtes des paquets IP lorsqu'ils traversent un routeur ou un pare-feu.

> [!info] Principe fondamental Le NAT transforme les adresses IP privées (non routables sur Internet) en adresses IP publiques (routables) et inversement, permettant ainsi à plusieurs machines d'un réseau local de partager une ou plusieurs adresses IP publiques.

### Contexte historique et nécessité

Le NAT a été développé principalement pour répondre à **l'épuisement des adresses IPv4** :

|Problématique|Solution apportée par NAT|
|---|---|
|Pénurie d'adresses IPv4 publiques|Permet à plusieurs hôtes de partager une seule IP publique|
|Coût des adresses publiques|Réduit le nombre d'adresses publiques nécessaires|
|Sécurité du réseau interne|Masque la topologie interne du réseau|
|Flexibilité de l'adressage|Permet de réorganiser le réseau interne sans impact externe|

> [!example] Exemple concret Une entreprise avec 200 employés peut utiliser une seule adresse IP publique (ex: 203.0.113.5) pour tous ses postes, qui utilisent en interne des adresses privées (ex: 192.168.1.1 à 192.168.1.200).

### Principe de fonctionnement de base

Le NAT fonctionne en maintenant une **table de traduction** qui associe :

- Les adresses IP sources/destinations
- Les ports sources/destinations
- Les états des connexions

**Flux sortant (Inside → Outside)** :

1. Un paquet part du réseau interne avec une IP privée source
2. Le routeur NAT remplace l'IP privée par son IP publique
3. Le routeur enregistre cette correspondance dans sa table
4. Le paquet est envoyé vers Internet avec l'IP publique

**Flux entrant (Outside → Inside)** :

1. Une réponse arrive avec l'IP publique comme destination
2. Le routeur consulte sa table de traduction
3. Il remplace l'IP publique par l'IP privée correspondante
4. Le paquet est transmis à la machine interne

> [!warning] Point d'attention Le NAT modifie les paquets en transit, ce qui peut avoir des implications sur certains protocoles (notamment ceux qui incluent des informations d'adressage dans les données de la couche application).

---

## 🏗️ Rôle dans l'architecture réseau

### Position stratégique

Le NAT se positionne comme un **point de passage obligatoire** entre le réseau interne (privé) et le réseau externe (Internet) :

```
[Réseau Interne]  ←→  [Routeur NAT]  ←→  [Internet]
  (Privé)              (Traduction)        (Public)
192.168.x.x          203.0.113.5          Monde entier
```

### Fonctions principales

#### 1. **Conservation des adresses IPv4**

> [!tip] Avantage économique Une organisation peut fonctionner avec un nombre minimal d'adresses publiques, réduisant ainsi les coûts et la complexité administrative.

Le NAT permet d'utiliser les plages d'adresses privées définies par la RFC 1918 :

- **10.0.0.0/8** (10.0.0.0 à 10.255.255.255) - Classe A
- **172.16.0.0/12** (172.16.0.0 à 172.31.255.255) - Classe B
- **192.168.0.0/16** (192.168.0.0 à 192.168.255.255) - Classe C

Ces adresses peuvent être réutilisées dans n'importe quel réseau privé sans conflit.

#### 2. **Sécurité par obscurcissement**

Le NAT offre une **première couche de sécurité** :

|Aspect sécurité|Explication|
|---|---|
|Masquage de la topologie|Les adresses internes ne sont pas visibles depuis l'extérieur|
|Filtrage implicite|Seules les connexions initiées depuis l'intérieur sont autorisées par défaut|
|Isolation du réseau|Difficulté pour un attaquant externe d'atteindre directement une machine interne|

> [!warning] Ne pas confondre Le NAT n'est **PAS un pare-feu** ! Il offre une certaine protection mais ne remplace pas une vraie politique de sécurité avec un firewall dédié.

#### 3. **Flexibilité de l'adressage interne**

Le NAT permet de :

- Changer d'opérateur Internet sans modifier l'adressage interne
- Réorganiser le réseau interne sans impact externe
- Fusionner des réseaux avec des plans d'adressage qui se chevauchent

> [!example] Cas d'usage : Fusion d'entreprises Deux entreprises fusionnent, chacune utilise le réseau 192.168.1.0/24. Grâce au NAT, elles peuvent continuer temporairement avec leurs adresses existantes pendant la transition.

#### 4. **Interconnexion de réseaux**

Le NAT facilite la connexion entre :

- Réseaux privés et Internet public
- Réseaux avec des schémas d'adressage incompatibles
- Environnements nécessitant une séparation logique

### Impact sur les flux réseau

Le NAT modifie le comportement naturel du routage IP :

**Sans NAT** :

```
Client 192.168.1.10 → Serveur web 203.0.113.50
Le serveur voit : source = 192.168.1.10
```

**Avec NAT** :

```
Client 192.168.1.10 → [NAT] → Serveur web 203.0.113.50
Le serveur voit : source = 198.51.100.5 (IP publique du NAT)
```

> [!info] Conséquence importante Le serveur distant ne connaît jamais l'adresse réelle du client, seulement l'adresse du routeur NAT. Cela a des implications pour les logs, la géolocalisation, et certains mécanismes d'authentification.

### Limitations architecturales

Bien que très utile, le NAT introduit certaines contraintes :

- **Complexité pour les connexions entrantes** : Nécessite une configuration spécifique (port forwarding, etc.)
- **Problèmes avec certains protocoles** : FTP, SIP, IPsec peuvent nécessiter des mécanismes d'assistance (ALG - Application Layer Gateway)
- **Perte de la connectivité end-to-end** : Le principe fondamental d'Internet (chaque machine a une adresse unique) est rompu
- **Impact sur les performances** : Overhead de traitement pour chaque paquet

---

## 📊 Position dans le modèle OSI

### Couche de fonctionnement

Le NAT opère principalement à la **couche 3 (Réseau)** du modèle OSI, mais peut également intervenir à la **couche 4 (Transport)** selon le type de NAT utilisé.

```
┌─────────────────────────────┐
│ 7. Application              │
├─────────────────────────────┤
│ 6. Présentation             │
├─────────────────────────────┤
│ 5. Session                  │
├─────────────────────────────┤
│ 4. Transport                │ ← NAT/PAT agit ici (ports)
├─────────────────────────────┤
│ 3. Réseau                   │ ← NAT agit ici (adresses IP)
├─────────────────────────────┤
│ 2. Liaison de données       │
├─────────────────────────────┤
│ 1. Physique                 │
└─────────────────────────────┘
```

### Manipulation de la couche 3 (Réseau)

Le NAT modifie les champs de l'**en-tête IP** :

|Champ modifié|Action|
|---|---|
|Adresse IP source|Remplacée par l'IP publique (flux sortant)|
|Adresse IP destination|Remplacée par l'IP privée (flux entrant)|
|Checksum IP|Recalculé après modification des adresses|

> [!info] Structure de l'en-tête IPv4 L'en-tête IPv4 contient les adresses source et destination sur 32 bits chacune. Le NAT doit modifier ces champs puis recalculer le checksum pour maintenir l'intégrité du paquet.

### Manipulation de la couche 4 (Transport)

Pour le **PAT (Port Address Translation)**, le NAT modifie également l'**en-tête TCP/UDP** :

|Champ modifié|Action|
|---|---|
|Port source|Remplacé par un port dynamique choisi par le NAT|
|Port destination|Remplacé lors du port forwarding|
|Checksum TCP/UDP|Recalculé car les checksums TCP/UDP incluent une pseudo-en-tête avec les adresses IP|

> [!warning] Double recalcul Lorsque le NAT modifie les adresses IP, il doit recalculer :
> 
> 1. Le checksum IP (couche 3)
> 2. Le checksum TCP/UDP (couche 4, car il inclut les adresses IP dans son calcul)

### Implications techniques

#### Traçabilité des paquets

Le NAT crée une **rupture dans la traçabilité end-to-end** :

```
Avant NAT : Client → Routeur 1 → Routeur 2 → Serveur
            IP source reste identique sur tout le chemin

Avec NAT :  Client → NAT → Routeur 1 → Routeur 2 → Serveur
            IP source change au niveau du NAT
```

#### État de connexion (Stateful)

Le NAT doit maintenir un **état pour chaque connexion** :

> [!example] Table de traduction NAT
> 
> ```
> IP Interne:Port  →  IP Publique:Port  →  IP Destination:Port
> 192.168.1.10:5000 → 203.0.113.5:60001 → 93.184.216.34:80
> 192.168.1.11:5000 → 203.0.113.5:60002 → 93.184.216.34:80
> 192.168.1.10:5001 → 203.0.113.5:60003 → 151.101.1.69:443
> ```

Cette table permet au NAT de savoir où router les paquets de retour.

#### Timeouts et gestion des sessions

Le NAT doit gérer des **timeouts** pour nettoyer sa table :

|Protocole|Timeout typique|Raison|
|---|---|---|
|TCP établi|2 heures|Connexions longues possibles|
|TCP SYN|2 minutes|Phase d'établissement courte|
|UDP|30-60 secondes|Protocole sans état|
|ICMP|30 secondes|Messages ponctuels|

> [!tip] Optimisation Ces timeouts peuvent être ajustés selon les besoins, mais des valeurs trop courtes risquent de couper des connexions légitimes, tandis que des valeurs trop longues peuvent saturer la table de traduction.

### Incompatibilités protocolaires

Certains protocoles de couches supérieures posent problème avec le NAT :

#### Protocoles intégrant des adresses IP dans les données

- **FTP** : Les commandes PORT et PASV contiennent des adresses IP dans les données de la couche application
- **SIP (VoIP)** : Les messages SDP contiennent des informations d'adressage
- **H.323** : Protocole de visioconférence incluant des adresses dans la signalisation

> [!info] Solution : ALG (Application Layer Gateway) Des mécanismes spéciaux appelés ALG sont nécessaires pour que le NAT inspecte et modifie également les données de la couche application, pas seulement les en-têtes IP/TCP/UDP.

#### Protocoles d'authentification

- **IPsec** : Utilise des checksums cryptographiques qui détectent toute modification des paquets
- **Kerberos** : Peut inclure des adresses IP dans ses tickets

### Interaction avec d'autres couches

Le NAT peut nécessiter une coordination avec :

|Couche|Interaction|
|---|---|
|Couche 2|Le NAT utilise ARP pour résoudre les adresses MAC sur ses interfaces|
|Couche 4|Modification des ports et recalcul des checksums TCP/UDP|
|Couche 5-7|ALG pour certains protocoles applicatifs|

> [!warning] Piège courant Le NAT n'est pas "transparent" pour tous les protocoles. Les applications qui assument une connectivité end-to-end directe peuvent dysfonctionner derrière un NAT sans configuration appropriée.

---

## 🎯 Points clés à retenir

> [!tip] Synthèse des fondamentaux
> 
> - Le **NAT traduit les adresses IP** privées en publiques pour permettre l'accès à Internet
> - Il résout le problème de **pénurie d'adresses IPv4** en permettant le partage d'IPs publiques
> - Il opère aux **couches 3 et 4** du modèle OSI (adresses IP et ports)
> - Il offre une **sécurité basique** mais ne remplace pas un pare-feu
> - Il maintient une **table d'état** pour router correctement les paquets de retour
> - Certains protocoles nécessitent des **mécanismes spéciaux (ALG)** pour fonctionner avec le NAT

---

_📅 Dernière mise à jour : Décembre 2025_