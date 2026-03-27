

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

## Introduction au NAT

Le **NAT (Network Address Translation)** est un mécanisme de traduction d'adresses IP qui permet de modifier les adresses source et/ou destination des paquets IP lors de leur passage à travers un routeur ou un pare-feu.

> [!info] Définition Le NAT est une technique qui consiste à remapper un espace d'adressage IP vers un autre en modifiant les informations d'adresse réseau dans l'en-tête IP des paquets pendant leur transit.

### 🎯 Objectifs principaux du NAT

1. **Conservation des adresses IPv4** : Permettre à plusieurs machines d'utiliser une seule adresse IP publique
2. **Sécurité** : Masquer la topologie du réseau interne
3. **Flexibilité** : Faciliter les changements de fournisseur d'accès Internet
4. **Interconnexion** : Résoudre les conflits d'adressage entre réseaux

---

## Contexte et problématique

### Épuisement des adresses IPv4

#### 📊 La crise des adresses IPv4

Le protocole IPv4, créé dans les années 1980, utilise des adresses sur **32 bits**, ce qui permet théoriquement environ **4,3 milliards d'adresses uniques**.

```
Nombre total d'adresses IPv4 : 2^32 = 4 294 967 296 adresses
```

> [!warning] Problème d'échelle Avec la croissance exponentielle d'Internet (ordinateurs, smartphones, objets connectés, serveurs), cette limite a été atteinte. L'IANA (Internet Assigned Numbers Authority) a épuisé son stock d'adresses IPv4 en février 2011.

#### 📈 Évolution de la demande

|Année|Événement|Impact|
|---|---|---|
|1981|Création d'IPv4|4,3 milliards d'adresses disponibles|
|2000|~300 millions d'utilisateurs Internet|Premières alertes sur l'épuisement|
|2011|Épuisement IANA|Plus d'allocations centrales possibles|
|2023|~5 milliards d'utilisateurs Internet|Pénurie critique sans NAT|

#### 🔍 Pourquoi l'épuisement est survenu plus tôt que prévu

1. **Allocation inefficace initiale** : Les premiers blocs d'adresses ont été alloués par classes entières (classe A = 16,7 millions d'adresses)
2. **Croissance exponentielle** : Explosion du nombre d'appareils connectés (IoT, mobile)
3. **Gaspillage historique** : Grandes entreprises possédant des blocs entiers peu utilisés

> [!example] Exemple concret Le MIT possède un bloc de classe A complet (18.0.0.0/8), soit 16 777 216 adresses IP, allouées dans les années 1980 quand l'Internet était naissant.

#### 💡 Solutions à l'épuisement

|Solution|Description|Adoption|
|---|---|---|
|**NAT**|Partage d'adresses publiques|✅ Universelle|
|**IPv6**|Nouveau protocole (128 bits)|🔄 En cours|
|**CIDR**|Allocation plus fine|✅ Déployé|
|**Récupération**|Récupération d'adresses inutilisées|⏳ Lente|

---

### Limitations de l'adressage public

#### 🏢 Problématique pour les organisations

Avant le NAT, chaque machine devait posséder une adresse IP publique unique pour communiquer sur Internet, ce qui posait plusieurs problèmes majeurs.

> [!warning] Problèmes sans NAT
> 
> - **Coût élevé** : Acheter/louer des plages d'adresses IP publiques
> - **Gestion complexe** : Administration de centaines voire milliers d'adresses publiques
> - **Mobilité limitée** : Changement de FAI = réadressage complet du réseau
> - **Scalabilité impossible** : Croissance du réseau limitée par les adresses disponibles

#### 💰 Aspect économique

```
Coût typique d'une adresse IPv4 publique (2023) : 
- Prix marché secondaire : 30-50 € par adresse
- Entreprise avec 500 machines : 15 000 - 25 000 €
- Avec NAT : 1 seule adresse IP publique nécessaire
```

#### 🔄 Problème de mobilité et changement de FAI

Sans NAT, si une entreprise change de fournisseur d'accès Internet :

1. **Perte du bloc d'adresses** : Les adresses publiques appartiennent généralement au FAI
2. **Réadressage complet** : Reconfiguration de chaque serveur, routeur, équipement
3. **Mise à jour DNS** : Modification de tous les enregistrements
4. **Interruption de service** : Temps d'indisponibilité pendant la migration

> [!tip] Avantage du NAT Avec le NAT, seule l'adresse IP publique externe change. Le réseau interne reste inchangé, simplifiant considérablement les migrations.

#### 📦 Classes d'adresses et leur inefficacité

Le système de classes d'adresses IPv4 était particulièrement problématique :

|Classe|Plage|Hôtes par réseau|Problème|
|---|---|---|---|
|A|1.0.0.0 à 126.0.0.0|16 777 214|Trop grand pour la plupart des besoins|
|B|128.0.0.0 à 191.255.0.0|65 534|Souvent surdimensionné|
|C|192.0.0.0 à 223.255.255.0|254|Trop petit pour beaucoup d'entreprises|

> [!example] Dilemme typique Une entreprise avec 1 000 machines devait choisir entre :
> 
> - **Classe B** : 65 534 adresses (gaspillage de 64 534 adresses)
> - **4 × Classe C** : Gestion complexe de 4 réseaux séparés

---

### Besoin de sécurité et d'isolation

#### 🔒 Principe de sécurité par obscurité

Le NAT crée une **barrière naturelle** entre le réseau interne et Internet en masquant la structure du réseau privé.

> [!info] Sécurité par le NAT Le NAT n'est **pas** un mécanisme de sécurité en soi, mais il apporte une couche de protection supplémentaire par effet de bord :
> 
> - Les machines internes ne sont pas directement accessibles depuis Internet
> - La topologie du réseau interne reste invisible de l'extérieur
> - Les connexions sont généralement initiées depuis l'intérieur uniquement

#### 🛡️ Isolation du réseau interne

```
Internet (Hostile)
       ↓
   [Routeur NAT]  ← Point de contrôle unique
       ↓
 Réseau privé
 (192.168.1.0/24)
       ↓
 Machines internes invisibles depuis l'extérieur
```

**Avantages de l'isolation :**

1. **Invisibilité** : Les machines internes n'ont pas d'adresse publique directe
2. **Filtrage implicite** : Seules les connexions initiées depuis l'intérieur sont autorisées par défaut
3. **Point de contrôle centralisé** : Toutes les communications passent par le routeur NAT
4. **Réduction de la surface d'attaque** : Moins de points d'entrée potentiels

> [!warning] Ne pas confondre Le NAT n'est **PAS** un pare-feu :
> 
> - Il ne filtre pas activement le trafic malveillant
> - Il ne protège pas contre les attaques applicatives
> - Il ne remplace pas des mécanismes de sécurité dédiés
> 
> Le NAT apporte une **sécurité par défaut** en rendant les machines internes non directement joignables.

#### 🎭 Masquage de la topologie réseau

Le NAT empêche les attaquants de :

- **Scanner le réseau interne** : Les adresses privées ne sont pas routables sur Internet
- **Identifier le nombre de machines** : Toutes les connexions proviennent de la même IP publique
- **Cartographier l'infrastructure** : La structure interne reste opaque
- **Cibler des machines spécifiques** : Pas d'accès direct aux équipements internes

#### 🔐 Adresses privées (RFC 1918)

Pour permettre au NAT de fonctionner, des plages d'adresses IP ont été réservées à un usage **strictement privé** et ne sont jamais routées sur Internet :

|Plage d'adresses|Masque CIDR|Nombre d'adresses|Usage typique|
|---|---|---|---|
|10.0.0.0 - 10.255.255.255|10.0.0.0/8|16 777 216|Grandes entreprises, datacenters|
|172.16.0.0 - 172.31.255.255|172.16.0.0/12|1 048 576|Moyennes entreprises|
|192.168.0.0 - 192.168.255.255|192.168.0.0/16|65 536|Petites entreprises, particuliers|

> [!tip] Utilisation des adresses privées Ces adresses peuvent être réutilisées librement par n'importe quelle organisation sans coordination. Deux entreprises peuvent toutes deux utiliser 192.168.1.0/24 sans conflit, car ces réseaux restent isolés par le NAT.

#### 🚫 Protection contre les scans de ports

Sans NAT (exposition directe) :

```bash
# Attaquant depuis Internet
nmap -p- 203.0.113.10-20
# → Peut scanner directement 10 machines exposées
# → Découvre les services ouverts sur chaque machine
# → Identifie les vulnérabilités potentielles
```

Avec NAT :

```bash
# Attaquant depuis Internet
nmap -p- 203.0.113.10
# → Ne voit qu'UNE seule machine (le routeur NAT)
# → Ne peut pas atteindre les machines internes
# → Doit d'abord compromettre le routeur pour progresser
```

> [!example] Scénario réel Une entreprise avec 200 machines :
> 
> **Sans NAT** :
> 
> - 200 adresses IP publiques exposées
> - 200 cibles potentielles pour un attaquant
> - Chaque machine doit être individuellement sécurisée
> 
> **Avec NAT** :
> 
> - 1 adresse IP publique exposée (le routeur)
> - Les machines internes restent inaccessibles par défaut
> - Concentration des efforts de sécurité sur le point d'entrée

#### ⚖️ Équilibre sécurité vs accessibilité

Le NAT crée un défi pour les services devant être accessibles depuis Internet :

```
Problème : Comment permettre l'accès à un serveur web interne 
           tout en conservant la protection du NAT ?

Solution : Redirection de ports (Port Forwarding)
           → Sujet détaillé dans une partie ultérieure
```

> [!warning] Limitations de sécurité Le NAT ne protège pas contre :
> 
> - Les attaques provenant de l'intérieur du réseau
> - Les malwares téléchargés par les utilisateurs
> - Les connexions sortantes malveillantes
> - Les vulnérabilités applicatives (XSS, SQL injection, etc.)
> - Les attaques de type phishing ou ingénierie sociale

---

## 🎯 Synthèse des fondamentaux

Le NAT est devenu une technologie **incontournable** pour plusieurs raisons convergentes :

1. **Technique** : Pénurie d'adresses IPv4 rendant impossible l'attribution d'IPs publiques à tous les appareils
2. **Économique** : Coût prohibitif de l'acquisition et gestion de blocs d'adresses publiques
3. **Sécurité** : Isolation naturelle du réseau interne et réduction de la surface d'attaque
4. **Opérationnelle** : Simplification des migrations et changements d'infrastructure

> [!tip] En résumé Le NAT transforme la contrainte de l'épuisement des adresses IPv4 en une opportunité d'améliorer la sécurité et la flexibilité des réseaux, tout en permettant la croissance continue d'Internet.

Ces fondamentaux expliquent **pourquoi** le NAT existe. Les parties suivantes détailleront **comment** il fonctionne et **comment** l'implémenter efficacement.