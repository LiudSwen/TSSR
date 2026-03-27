

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

## 🎯 Introduction à l'adressage IP

L'adressage IP distingue deux catégories fondamentales d'adresses : **publiques** et **privées**. Cette distinction est au cœur du fonctionnement du NAT et de l'architecture des réseaux modernes.

> [!info] Contexte historique Dans les années 1990, l'épuisement annoncé des adresses IPv4 (environ 4,3 milliards d'adresses disponibles) a nécessité la création de mécanismes de conservation. La RFC 1918, publiée en 1996, a standardisé les plages d'adresses privées non routables sur Internet.

### Principe de base

- **Adresses publiques** : Uniques mondialement, routables sur Internet
- **Adresses privées** : Réutilisables dans différents réseaux, non routables sur Internet
- **NAT** : Le pont entre ces deux mondes

---

## 🏠 Plages d'adresses privées RFC 1918

La RFC 1918 définit trois plages d'adresses IP réservées pour un usage privé, jamais routées sur l'Internet public.

### Les trois classes privées

|Classe|Plage d'adresses|CIDR|Nombre d'adresses|Usage typique|
|---|---|---|---|---|
|**Classe A**|10.0.0.0 - 10.255.255.255|10.0.0.0/8|16 777 216|Grandes entreprises, datacenters|
|**Classe B**|172.16.0.0 - 172.31.255.255|172.16.0.0/12|1 048 576|Entreprises moyennes|
|**Classe C**|192.168.0.0 - 192.168.255.255|192.168.0.0/16|65 536|Réseaux domestiques, PME|

> [!example] Exemples concrets d'utilisation
> 
> - **10.0.0.0/8** : Un grand groupe industriel avec des dizaines de sites
> - **172.16.0.0/12** : Une université avec plusieurs campus
> - **192.168.0.0/16** : Votre box Internet à la maison (généralement 192.168.1.0/24)

### Caractéristiques des adresses privées

```bash
# Vérifier si une adresse est privée
# Exemples d'adresses privées valides :
10.25.50.100
172.20.10.5
192.168.1.254

# Exemples d'adresses HORS RFC 1918 (donc publiques ou invalides) :
172.15.0.1     # Juste avant la plage privée 172.16.0.0
172.32.0.1     # Juste après la plage privée 172.31.255.255
192.167.1.1    # Proche mais pas dans la plage
11.0.0.1       # Pas dans 10.0.0.0/8
```

> [!warning] Routage des adresses privées Les routeurs Internet sont configurés pour **rejeter** automatiquement tout paquet provenant d'une adresse source privée ou destiné à une adresse privée. C'est pourquoi le NAT est indispensable pour connecter un réseau privé à Internet.

### Avantages des adresses privées

1. **Réutilisabilité** : Chaque réseau privé peut utiliser les mêmes plages
2. **Économie d'adresses publiques** : Des milliers d'appareils partagent une seule IP publique
3. **Sécurité par obscurité** : Les machines internes ne sont pas directement accessibles
4. **Flexibilité** : Possibilité de réorganiser le réseau interne sans impact externe

> [!tip] Choix de la plage privée
> 
> - Utilisez **192.168.0.0/16** pour les petits réseaux simples
> - Préférez **10.0.0.0/8** si vous anticipez une croissance importante ou besoin de nombreux sous-réseaux
> - **172.16.0.0/12** est moins utilisée, donc utile pour éviter les conflits en cas de VPN ou fusion de réseaux

---

## 🌍 Adresses publiques routables

Les adresses publiques sont attribuées et gérées par des organismes internationaux pour garantir leur unicité mondiale.

### Hiérarchie d'attribution

```
IANA (Internet Assigned Numbers Authority)
    ↓
RIR (Regional Internet Registries)
    ├─ ARIN (Amérique du Nord)
    ├─ RIPE NCC (Europe, Moyen-Orient)
    ├─ APNIC (Asie-Pacifique)
    ├─ LACNIC (Amérique Latine)
    └─ AFRINIC (Afrique)
        ↓
    LIR/ISP (Fournisseurs d'accès)
        ↓
    Organisations finales
```

### Caractéristiques des adresses publiques

> [!info] Propriétés essentielles
> 
> - **Unicité mondiale** : Une adresse publique ne peut être attribuée qu'à un seul utilisateur à la fois
> - **Routabilité** : Toutes les tables de routage Internet connaissent le chemin vers ces adresses
> - **Traçabilité** : Chaque bloc est enregistré avec son propriétaire
> - **Coût** : Les adresses publiques sont une ressource limitée et payante

### Plages réservées (non utilisables)

Certaines plages d'adresses publiques sont réservées à des usages spéciaux :

|Plage|CIDR|Usage|
|---|---|---|
|0.0.0.0 - 0.255.255.255|0.0.0.0/8|"This network"|
|127.0.0.0 - 127.255.255.255|127.0.0.0/8|Loopback (localhost)|
|169.254.0.0 - 169.254.255.255|169.254.0.0/16|APIPA (auto-configuration)|
|224.0.0.0 - 239.255.255.255|224.0.0.0/4|Multicast|
|240.0.0.0 - 255.255.255.255|240.0.0.0/4|Réservé (usage futur)|

```bash
# Exemple : obtenir votre adresse IP publique
curl ifconfig.me
curl icanhazip.com

# Résultat typique : 203.0.113.42
# Cette adresse est unique et routable sur Internet
```

> [!warning] Épuisement IPv4 Les adresses IPv4 publiques sont épuisées depuis 2011 au niveau de l'IANA. Les RIR distribuent les adresses restantes avec parcimonie. C'est pourquoi :
> 
> - Les FAI utilisent massivement le NAT (CGNAT - Carrier-Grade NAT)
> - Le passage à IPv6 est encouragé
> - Le marché secondaire d'adresses IPv4 existe (revente de blocs)

### Types d'attribution

**Attribution statique** :

- Adresse fixe assignée en permanence
- Nécessaire pour les serveurs publics
- Plus coûteuse

**Attribution dynamique** :

- Adresse change à chaque connexion (ou périodiquement)
- Usage typique : clients résidentiels
- Optimise l'utilisation des adresses disponibles

```bash
# Vérifier la stabilité de votre IP publique
# Tester à plusieurs moments :
date && curl -s ifconfig.me

# Si l'IP change, vous avez une attribution dynamique
```

---

## 📦 Notion d'espace d'adressage

L'espace d'adressage représente l'ensemble des adresses IP disponibles et leur organisation logique.

### Définition et portée

> [!info] Espace d'adressage L'espace d'adressage IPv4 est théoriquement constitué de 2³² = 4 294 967 296 adresses uniques (de 0.0.0.0 à 255.255.255.255). Cependant, cet espace est fragmenté entre différents usages.

### Répartition de l'espace IPv4

```
Espace IPv4 total : 4 294 967 296 adresses (100%)
├─ Adresses publiques routables : ~3 700 000 000 (86%)
├─ Adresses privées RFC 1918 : ~17 900 000 (0,4%)
│   ├─ 10.0.0.0/8 : 16 777 216
│   ├─ 172.16.0.0/12 : 1 048 576
│   └─ 192.168.0.0/16 : 65 536
└─ Adresses réservées/spéciales : ~577 000 000 (13,6%)
    ├─ Loopback : 16 777 216
    ├─ Multicast : 268 435 456
    ├─ APIPA : 65 536
    └─ Autres réservations
```

### Espaces d'adressage dans une architecture NAT

Dans un réseau utilisant le NAT, deux espaces d'adressage coexistent :

**Espace privé (inside)** :

- Adresses non routables sur Internet
- Grande capacité (choix de la plage)
- Gestion locale libre

**Espace public (outside)** :

- Adresses routables mondialement
- Ressource limitée et coûteuse
- Une ou plusieurs adresses partagées

```
┌─────────────────────────────────────────────────────────────┐
│                    ESPACE PRIVÉ (INSIDE)                    │
│                     192.168.1.0/24                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │   PC 1   │  │   PC 2   │  │ Serveur  │  │   PC N   │     │
│  │.1.10     │  │.1.20     │  │.1.100    │  │.1.254    │     │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘     │
│                            │                                │
│                            ▼                                │
│                   ┌─────────────────┐                       │
│                   │  Routeur NAT    │                       │
│                   │  Inside: .1.1   │                       │
│                   └─────────────────┘                       │
└─────────────────────────────│───────────────────────────────┘
                              │ Translation
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   ESPACE PUBLIC (OUTSIDE)                   │
│                                                             │
│                   ┌─────────────────┐                       │
│                   │  Routeur NAT    │                       │
│                   │Outside: 203.0   │                       │
│                   │       .113.42   │                       │
│                   └─────────────────┘                       │
│                            │                                │
│                            ▼                                │
│                       INTERNET                              │
└─────────────────────────────────────────────────────────────┘
```

> [!example] Exemple concret de cohabitation Une entreprise avec 500 postes de travail :
> 
> - **Espace privé** : 10.50.0.0/16 (65 536 adresses disponibles)
> - **Espace public** : 203.0.113.0/29 (seulement 6 adresses utilisables)
> 
> Le NAT permet aux 500 postes de partager ces 6 adresses publiques.

### Gestion de l'espace d'adressage

**Planification de l'espace privé** :

```bash
# Exemple de découpage pour une entreprise moyenne
# Réseau principal : 10.0.0.0/8

# Segmentation par usage :
10.10.0.0/16    # Utilisateurs (65k adresses)
10.20.0.0/16    # Serveurs
10.30.0.0/16    # Invités/WiFi
10.40.0.0/16    # VoIP
10.50.0.0/16    # IoT/Imprimantes
```

> [!tip] Bonnes pratiques de planification
> 
> - **Anticipez la croissance** : Prévoyez 2-3x vos besoins actuels
> - **Documentez** : Maintenez un plan d'adressage à jour (IPAM)
> - **Standardisez** : Utilisez la même logique de sous-réseau sur tous les sites
> - **Évitez 192.168.1.0/24** : Trop commun, risque de conflits VPN

### Fragmentation et agrégation

**Problème de fragmentation** : L'espace public est fragmenté en millions de petits blocs, rendant les tables de routage Internet gigantesques.

**Solution par agrégation** : Les routes sont regroupées autant que possible pour réduire la taille des tables.

```bash
# Au lieu de router individuellement :
203.0.113.0/30
203.0.113.4/30
203.0.113.8/30
203.0.113.12/30

# On agrège en une seule route :
203.0.113.0/28

# Gain : 4 entrées → 1 entrée dans la table de routage
```

---

## ⚖️ Comparaison et cohabitation

### Tableau récapitulatif

|Critère|Adresses privées|Adresses publiques|
|---|---|---|
|**Routabilité**|Non routable sur Internet|Routable mondialement|
|**Unicité**|Réutilisable dans chaque réseau|Unique mondialement|
|**Coût**|Gratuit|Payant (location ou achat)|
|**Quantité**|Illimitée localement|Limitée et épuisée|
|**Gestion**|Libre par l'administrateur local|Contrôlée par RIR/ISP|
|**Sécurité**|Invisible depuis Internet|Exposée et visible|
|**Traçabilité**|Locale uniquement|Traçable jusqu'au propriétaire|

### Interaction via NAT

Le NAT agit comme un **traducteur bidirectionnel** entre ces deux espaces :

```
FLUX SORTANT (Inside → Outside)
─────────────────────────────────
Client privé 192.168.1.10:5000
        ↓
    [NAT Translation]
        ↓
IP publique 203.0.113.42:3000
        ↓
    Serveur distant


FLUX ENTRANT (Outside → Inside)
─────────────────────────────────
Serveur distant
        ↓
IP publique 203.0.113.42:80
        ↓
    [NAT Translation]
        ↓
Serveur web 192.168.1.100:80
```

> [!warning] Pièges courants
> 
> **Conflit d'adressage privé** : Si vous connectez deux réseaux privés utilisant la même plage (ex: deux sites en 192.168.1.0/24), vous aurez des conflits. Solution : renumeroter l'un des réseaux avant connexion.
> 
> **CGNAT et applications P2P** : Si votre FAI utilise du NAT sur son réseau (CGNAT), vous êtes "derrière deux NAT". Cela complique l'hébergement de services ou les applications peer-to-peer.

### Scénarios d'utilisation conjointe

**Scénario 1 : Réseau domestique simple**

```
Internet (IP publique dynamique)
    ↓
Box FAI avec NAT
    ↓
Réseau local 192.168.1.0/24
    ├─ Ordinateurs
    ├─ Smartphones
    └─ Objets connectés
```

**Scénario 2 : Entreprise multi-sites**

```
Internet (Bloc public 203.0.113.0/29)
    ↓
Routeur central avec NAT
    ↓
    ├─ Site A : 10.1.0.0/16 (privé)
    ├─ Site B : 10.2.0.0/16 (privé)
    └─ Site C : 10.3.0.0/16 (privé)
```

**Scénario 3 : DMZ avec services publics**

```
Internet
    ↓
Firewall/NAT
    ├─ DMZ : 203.0.113.32/28 (public)
    │       └─ Serveurs web accessibles
    └─ LAN : 10.0.0.0/8 (privé)
            └─ Postes de travail protégés
```

> [!tip] Astuce pour identifier l'espace Vous pouvez rapidement identifier si une adresse est privée ou publique :
> 
> - **Commence par 10.** → Privé
> - **172.16.** à **172.31.** → Privé
> - **192.168.** → Privé
> - **Tout le reste** (sauf plages spéciales) → Public ou réservé

### Transition et coexistence IPv4/IPv6

> [!info] L'avenir de l'adressage IPv6 dispose d'un espace d'adressage de 2¹²⁸ adresses (340 undécillions), éliminant le besoin de NAT. Cependant, IPv4 et IPv6 coexisteront pendant des décennies :
> 
> - **Dual-stack** : Utilisation simultanée d'IPv4 et IPv6
> - **NAT64** : Translation entre IPv6 et IPv4
> - Les concepts d'adressage privé/public restent pertinents pour comprendre les réseaux actuels

---

## 🎓 Points clés à retenir

1. **RFC 1918** définit trois plages privées : 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
2. Les **adresses privées** sont réutilisables et non routables sur Internet
3. Les **adresses publiques** sont uniques, routables, mais épuisées
4. L'**espace d'adressage** IPv4 est fragmenté entre usages publics, privés et réservés
5. Le **NAT** est le mécanisme permettant la cohabitation de ces deux espaces
6. La planification de l'adressage privé doit anticiper la croissance et éviter les plages communes

---

_Ce cours fait partie de la série sur le NAT - Fondamentaux_