

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

## 🎯 Présentation d'IPsec

### Qu'est-ce qu'IPsec ?

**IPsec** (Internet Protocol Security) est une suite de protocoles standardisés qui permet de sécuriser les communications IP au niveau de la couche réseau (couche 3 du modèle OSI).

> [!info] Définition IPsec fournit trois services de sécurité principaux :
> 
> - **Confidentialité** : chiffrement des données
> - **Intégrité** : vérification que les données n'ont pas été modifiées
> - **Authentification** : vérification de l'identité des pairs

#### Composants d'IPsec

|Composant|Rôle|Description|
|---|---|---|
|**AH** (Authentication Header)|Intégrité + Authentification|Protège l'intégrité mais ne chiffre pas|
|**ESP** (Encapsulating Security Payload)|Confidentialité + Intégrité|Chiffre et protège les données|
|**IKE** (Internet Key Exchange)|Négociation|Établit et gère les associations de sécurité|
|**SA** (Security Association)|Contexte de sécurité|Ensemble de paramètres de sécurité convenus|

> [!tip] Pratique courante Dans pfSense, on utilise principalement **ESP** car il combine chiffrement et intégrité. AH seul est rarement utilisé aujourd'hui.

### Pourquoi utiliser IPsec ?

IPsec est particulièrement adapté pour :

1. **Connexions site-to-site** : relier deux réseaux distants de manière sécurisée
2. **Interopérabilité** : standard universel supporté par tous les équipements réseau
3. **Performance** : fonctionnement au niveau IP, plus efficace que les VPN applicatifs
4. **Sécurité forte** : chiffrement de bout en bout au niveau réseau

> [!example] Cas d'usage typiques
> 
> - Relier le siège social à une agence distante
> - Connecter un datacenter à un site de production
> - Interconnecter des infrastructures cloud hybrides
> - Sécuriser les communications entre partenaires commerciaux

### Architecture IPsec

IPsec fonctionne en **deux phases** distinctes :

```
┌─────────────────────────────────────────────────────────────┐
│                        PHASE 1 (IKE)                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  • Négociation des algorithmes de sécurité           │   │
│  │  • Authentification mutuelle des pairs               │   │
│  │  • Établissement d'un canal sécurisé (ISAKMP SA)     │   │
│  │  • Échange de clés Diffie-Hellman                    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                        PHASE 2 (IPsec)                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  • Utilise le canal sécurisé de la Phase 1           │   │
│  │  • Négocie les paramètres du tunnel IPsec (ESP)      │   │
│  │  • Définit le trafic à protéger (proxy-id)           │   │
│  │  • Établit l'IPsec SA pour le trafic utilisateur     │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

> [!warning] Distinction importante
> 
> - **Phase 1** = tunnel de gestion (IKE SA) → protège la négociation
> - **Phase 2** = tunnel de données (IPsec SA) → protège le trafic réel

---

## 🌐 Tunnel Site-to-Site

### Concept et cas d'usage

Un tunnel **site-to-site** connecte deux réseaux locaux distants via Internet, créant ainsi un réseau étendu sécurisé.

```
Site A                    Internet                    Site B
┌──────────────┐                              ┌──────────────┐
│ LAN A        │                              │ LAN B        │
│ 10.1.0.0/24  │                              │ 10.2.0.0/24  │
│              │                              │              │
│   ┌──────┐   │                              │   ┌──────┐   │
│   │ PC A │───┼──┐                      ┌────┼───│ PC B │   │
│   └──────┘   │  │                      │    │   └──────┘   │
└──────────────┘  │                      │    └──────────────┘
                  │                      │
            ┌─────▼──────┐        ┌─────▼──────┐
            │  pfSense A │◄───────►│  pfSense B │
            │ WAN: IP A  │  Tunnel │ WAN: IP B  │
            └────────────┘  IPsec  └────────────┘
```

> [!info] Principe Les utilisateurs du LAN A accèdent aux ressources du LAN B de manière **transparente**, comme s'ils étaient sur le même réseau local. Le chiffrement est automatique et invisible pour eux.

#### Avantages du site-to-site

- ✅ Transparent pour les utilisateurs (pas de client VPN à installer)
- ✅ Sécurisation de tous les flux entre les sites
- ✅ Centralisation de la configuration sur les passerelles
- ✅ Possibilité de router tous les protocoles (pas uniquement TCP/UDP)

### Topologies possibles

#### 1. Point-to-Point simple

```
Site A ◄────────────► Site B
```

Configuration la plus simple : deux sites interconnectés.

#### 2. Hub and Spoke (Étoile)

```
        Site B
           │
           │
Site A ◄───┼───► Site Central (Hub)
           │
           │
        Site C
```

Le site central (hub) connecte plusieurs sites distants (spokes). Les spokes ne communiquent pas directement entre eux.

#### 3. Full Mesh (Maillage complet)

```
Site A ◄────────────► Site B
   ▲                     ▲
   │                     │
   │                     │
   └────► Site C ◄───────┘
```

Tous les sites sont interconnectés deux à deux. Plus complexe mais offre plus de résilience.

> [!tip] Choix de topologie
> 
> - **Point-to-Point** : deux sites uniquement
> - **Hub and Spoke** : site central + 3+ sites distants, trafic centralisé
> - **Full Mesh** : besoin de communication directe entre tous les sites

---

## ⚙️ Configuration Phase 1

La Phase 1 (IKE) établit le canal sécurisé qui permettra de négocier la Phase 2.

### Paramètres essentiels

Navigation : `VPN > IPsec > Tunnels > Add P1`

#### Configuration de base

|Paramètre|Description|Valeur recommandée|
|---|---|---|
|**Key Exchange version**|Version du protocole IKE|**IKEv2** (plus moderne et sécurisé)|
|**Internet Protocol**|IPv4 ou IPv6|IPv4 (ou Both)|
|**Interface**|Interface WAN locale|WAN (ou interface publique)|
|**Remote Gateway**|Adresse IP publique du pair distant|IP publique du site distant|
|**Description**|Nom du tunnel|Ex: "Tunnel vers Site Agence Paris"|

> [!info] IKEv1 vs IKEv2
> 
> - **IKEv1** : ancien standard, deux modes (Main/Aggressive)
> - **IKEv2** : plus rapide, meilleure gestion de la mobilité, reconnexion automatique
> 
> Utilisez IKEv2 sauf si vous devez vous connecter à un équipement ancien.

#### Authentification

Deux méthodes principales :

**1. Pre-Shared Key (PSK) - Clé partagée**

```
Authentication Method: Mutual PSK
My identifier: My IP address
Peer identifier: Peer IP address
Pre-Shared Key: [votre_clé_secrète_complexe]
```

> [!warning] Sécurité de la PSK
> 
> - Utilisez une clé complexe de **minimum 20 caractères**
> - Mélangez majuscules, minuscules, chiffres et symboles
> - Ne réutilisez jamais la même PSK pour plusieurs tunnels
> - Exemple : `Kx9#mP2$vL5@nQ8!wR4^tY7&`

**2. Certificats RSA**

Plus sécurisé mais plus complexe à mettre en place. Nécessite une PKI (infrastructure à clés publiques).

```
Authentication Method: Mutual RSA
My Certificate: [certificat local]
Peer Certificate Authority: [CA qui a signé le certificat du pair]
```

> [!tip] Choix de la méthode
> 
> - **PSK** : simple, rapide à déployer, adapté aux petites infrastructures
> - **Certificats** : plus sécurisé, gestion centralisée, recommandé pour >5 sites

### Algorithmes de chiffrement

#### Propositions de chiffrement Phase 1

Les propositions définissent les algorithmes acceptables. pfSense négocie automatiquement la meilleure combinaison commune.

**Proposition recommandée (sécurité moderne) :**

```
Encryption Algorithm: AES 256-bit
Hash Algorithm: SHA256
DH Group: 14 (2048 bit)
Lifetime: 28800 secondes (8 heures)
```

**Proposition compatible (pour équipements anciens) :**

```
Encryption Algorithm: AES 128-bit
Hash Algorithm: SHA1
DH Group: 2 (1024 bit)
Lifetime: 28800 secondes
```

> [!info] Comprendre les paramètres
> 
> - **Encryption Algorithm** : chiffre les données (AES = standard actuel)
> - **Hash Algorithm** : assure l'intégrité (SHA256 > SHA1)
> - **DH Group** : complexité de l'échange de clés (plus grand = plus sûr)
> - **Lifetime** : durée de validité des clés avant renouvellement

#### Tableau comparatif des algorithmes

|Algorithme|Sécurité|Performance|Recommandation|
|---|---|---|---|
|AES-256|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|✅ Recommandé|
|AES-128|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|✅ Acceptable|
|3DES|⭐⭐|⭐⭐|❌ Obsolète|
|SHA256|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|✅ Recommandé|
|SHA1|⭐⭐⭐|⭐⭐⭐⭐⭐|⚠️ Déprécié|
|DH Group 14|⭐⭐⭐⭐|⭐⭐⭐⭐|✅ Recommandé|
|DH Group 2|⭐⭐|⭐⭐⭐⭐⭐|❌ Faible|

> [!warning] Pièges courants
> 
> - ❌ Ne mélangez pas algorithmes forts et faibles dans les propositions
> - ❌ N'activez pas DH Group 1 ou 2 (trop faibles)
> - ✅ Assurez-vous que les deux côtés ont au moins une proposition commune

### Modes d'authentification

#### Mode Main vs Aggressive (IKEv1 uniquement)

Si vous utilisez encore IKEv1 :

**Main Mode** (recommandé)

- 6 messages échangés
- Identité des pairs protégée
- Plus sécurisé
- Nécessite une IP fixe des deux côtés

**Aggressive Mode** (à éviter)

- 3 messages échangés
- Identité des pairs exposée
- Moins sécurisé
- Permet IP dynamique côté initiateur

> [!tip] Avec IKEv2 IKEv2 n'a qu'un seul mode qui combine la sécurité du Main Mode et la flexibilité de l'Aggressive Mode. C'est une raison supplémentaire de privilégier IKEv2.

#### Options avancées

**NAT Traversal (NAT-T)**

```
☑ Enable NAT Traversal
NAT Traversal: Auto
```

> [!info] Quand activer NAT-T ? Activez NAT-T si l'un des sites (ou les deux) est derrière un NAT (box internet, routeur). NAT-T encapsule IPsec dans UDP port 4500 pour traverser les équipements NAT.

**Dead Peer Detection (DPD)**

```
☑ Enable DPD
Delay: 10 secondes
Max failures: 5
```

> [!tip] Utilité du DPD DPD détecte rapidement si le pair distant est injoignable et permet une reconnexion automatique. Indispensable pour les liens instables ou avec IP dynamique.

---

## 🔧 Configuration Phase 2

La Phase 2 définit le tunnel IPsec réel qui transportera les données entre les réseaux.

### Paramètres de la Phase 2

Navigation : `VPN > IPsec > Tunnels > Show Phase 2 Entries > Add P2`

#### Configuration de base

|Paramètre|Description|Valeur|
|---|---|---|
|**Mode**|Type d'encapsulation|Tunnel IPv4|
|**Local Network**|Réseau local à protéger|LAN subnet (ou autre)|
|**Remote Network**|Réseau distant accessible|Ex: 10.2.0.0/24|
|**Description**|Identification du tunnel|Ex: "Accès LAN Agence Paris"|

> [!example] Exemple concret Site A (Paris) : LAN 192.168.1.0/24  
> Site B (Lyon) : LAN 10.10.0.0/24
> 
> **Configuration Phase 2 côté Paris :**
> 
> - Local Network: 192.168.1.0/24
> - Remote Network: 10.10.0.0/24
> 
> **Configuration Phase 2 côté Lyon :**
> 
> - Local Network: 10.10.0.0/24
> - Remote Network: 192.168.1.0/24

### Définition du trafic protégé

#### Notion de Proxy-ID

Le **Proxy-ID** (ou Traffic Selector) définit exactement quel trafic sera chiffré et tunnelisé.

```
Proxy-ID = (Local Network) ◄──► (Remote Network)
```

> [!warning] Correspondance obligatoire Les Proxy-ID doivent être **parfaitement symétriques** des deux côtés :
> 
> **Site A :**  
> Local: 192.168.1.0/24 → Remote: 10.10.0.0/24
> 
> **Site B :**  
> Local: 10.10.0.0/24 → Remote: 192.168.1.0/24
> 
> Si les Proxy-ID ne correspondent pas, la Phase 2 échouera.

#### Types de réseaux

Vous pouvez spécifier différents types de réseaux :

|Type|Utilisation|Exemple|
|---|---|---|
|**LAN subnet**|Tout le réseau LAN|192.168.1.0/24|
|**Network**|Sous-réseau personnalisé|10.50.0.0/16|
|**Single host**|Une seule machine|192.168.1.10/32|
|**Address**|Alias d'adresses|Alias "Serveurs_Production"|

> [!tip] Plusieurs réseaux Si vous devez interconnecter plusieurs réseaux entre deux sites, créez **plusieurs entrées Phase 2** sous la même Phase 1, chacune avec son propre Proxy-ID.

#### Protocol et Port

Par défaut, tout le trafic IP est protégé :

```
Protocol: Any
```

Mais vous pouvez restreindre :

```
Protocol: TCP
Local Port: Any
Remote Port: 443 (HTTPS uniquement)
```

> [!info] Usage avancé La restriction par protocole/port est rarement utilisée en site-to-site. Elle peut servir pour des besoins très spécifiques de sécurité ou de segmentation.

### Modes de fonctionnement

#### ESP vs AH

Dans pfSense, seul **ESP** est couramment utilisé :

```
Protocol: ESP
```

**ESP (Encapsulating Security Payload)**

- ✅ Chiffre les données (confidentialité)
- ✅ Vérifie l'intégrité
- ✅ Authentifie les paquets
- Mode par défaut et recommandé

**AH (Authentication Header)**

- ❌ N'offre pas de chiffrement
- ✅ Intégrité et authentification uniquement
- ⚠️ Incompatible avec NAT
- Rarement utilisé aujourd'hui

> [!warning] N'utilisez pas AH AH ne chiffre pas les données et pose des problèmes avec NAT. Utilisez toujours ESP.

#### Algorithmes Phase 2

**Proposition recommandée (sécurité moderne) :**

```
Encryption Algorithms:
  ☑ AES 256-bit (coché)
  ☑ AES 128-bit (coché comme fallback)

Hash Algorithms:
  ☑ SHA256
  ☑ SHA1 (fallback pour compatibilité)

PFS key group: 14 (2048 bit)
Lifetime: 3600 secondes (1 heure)
```

> [!info] Perfect Forward Secrecy (PFS) PFS régénère régulièrement les clés de chiffrement. Même si une clé est compromise, elle ne permet pas de déchiffrer les anciennes communications.
> 
> - **Activé** : sécurité maximale (recommandé)
> - **Désactivé** : légère amélioration des performances

#### Lifetime (durée de vie)

```
Lifetime: 3600 secondes (1 heure)
```

Plus le lifetime est court :

- ✅ Plus sécurisé (renouvellement fréquent des clés)
- ❌ Plus de charge CPU (renégociations fréquentes)

Valeurs courantes :

- **3600s** (1h) : sécurité élevée
- **28800s** (8h) : bon compromis
- **86400s** (24h) : charge CPU minimale

> [!tip] Recommandation Pour un tunnel stable, 3600 à 28800 secondes est un bon compromis. Pour des liens instables, augmentez à 28800s pour éviter les renégociations trop fréquentes.

#### Options avancées

**Automatically ping host**

```
Automatically ping host: [IP d'une machine du réseau distant]
```

> [!tip] Keep-alive automatique Cette option génère du trafic régulier vers le réseau distant, maintenant le tunnel actif même sans activité utilisateur. Très utile pour :
> 
> - Éviter la fermeture du tunnel par inactivité
> - Détecter rapidement les pannes
> - Maintenir les états NAT

---

## 🔍 Dépannage des tunnels IPsec

### États du tunnel

Navigation : `Status > IPsec > Overview`

#### États possibles

|État|Icône|Signification|Action|
|---|---|---|---|
|**Connected**|🟢|Tunnel établi et opérationnel|Aucune|
|**Connecting**|🟡|Négociation en cours|Attendre ou vérifier logs|
|**Disconnected**|🔴|Tunnel inactif|Vérifier configuration|

#### Détails des phases

**Phase 1 Status**

```
✅ ESTABLISHED - La Phase 1 est active
```

**Phase 2 Status**

```
✅ INSTALLED - La Phase 2 est active et route le trafic
```

> [!warning] Phase 1 OK mais Phase 2 KO Si la Phase 1 est établie mais pas la Phase 2, le problème vient généralement de :
> 
> - Proxy-ID non correspondants
> - Algorithmes Phase 2 incompatibles
> - Règles de firewall bloquant le trafic

### Outils de diagnostic

#### 1. Status IPsec

`Status > IPsec > Overview`

Affiche l'état en temps réel :

- Connexions actives
- Statistiques de trafic
- Propositions négociées
- Durée de vie restante

> [!tip] Actions disponibles
> 
> - **Connect** : force l'établissement du tunnel
> - **Disconnect** : ferme le tunnel
> - **Show SPD** : affiche les Security Policy Database entries
> - **Show SAD** : affiche les Security Association Database entries

#### 2. Logs IPsec

`Status > System Logs > IPsec`

Les logs montrent la négociation en détail :

**Messages importants :**

```
✅ "IKE_SA rekeyed successfully" 
   → Renouvellement normal des clés

✅ "CHILD_SA established"
   → Phase 2 établie avec succès

⚠️ "no matching proposal found"
   → Algorithmes incompatibles

❌ "authentication failed"
   → Problème PSK ou certificat

❌ "peer not responding"
   → Problème réseau ou firewall
```

> [!example] Lecture d'un log typique
> 
> ```
> charon: 09[IKE] initiating IKE_SA
> charon: 09[IKE] sending IKE_SA_INIT request
> charon: 09[NET] received packet
> charon: 09[IKE] IKE_SA established
> charon: 10[CFG] configured proposal: AES-256/HMAC_SHA2_256/PRF_HMAC_SHA2_256/MODP_2048
> charon: 10[IKE] CHILD_SA established
> ```
> 
> → Négociation réussie avec AES-256 et SHA256

#### 3. Ping depuis pfSense

`Diagnostics > Ping`

```
Host: [IP d'une machine du réseau distant]
Source Address: [IP d'une machine du réseau local]
```

> [!info] Test de bout en bout Pinger depuis pfSense permet de vérifier :
> 
> - ✅ Le tunnel est établi
> - ✅ Le routage fonctionne
> - ✅ Les règles firewall autorisent ICMP
> 
> Si le ping fonctionne depuis pfSense mais pas depuis un PC du LAN, le problème vient du réseau local.

#### 4. Packet Capture

`Diagnostics > Packet Capture`

Capture le trafic pour analyse approfondie :

```
Interface: WAN
Address Family: IPv4
Protocol: UDP
Port: 500 (IKE)
```

Puis analyser avec Wireshark pour voir les échanges IKE.

> [!tip] Ports à capturer
> 
> - **UDP 500** : IKE (Phase 1)
> - **UDP 4500** : NAT-T (IPsec avec NAT)
> - **Protocol 50** : ESP (trafic chiffré Phase 2)

### Problèmes courants

#### 🔴 Phase 1 ne s'établit pas

**Symptômes :**

- Logs : "peer not responding"
- État : Disconnected

**Causes possibles :**

1. **Problème réseau**
    
    - Vérifiez que le WAN est fonctionnel
    - Ping l'IP publique du pair distant
    - Vérifiez qu'aucun firewall intermédiaire ne bloque UDP 500
2. **PSK incorrecte**
    
    - Vérifiez que les PSK sont **strictement identiques** des deux côtés
    - Attention aux espaces invisibles en début/fin
3. **IP Remote Gateway erronée**
    
    - Vérifiez l'IP publique réelle du pair
    - Si IP dynamique, utilisez un DynDNS
4. **Algorithmes incompatibles**
    
    - Logs : "no matching proposal found"
    - Ajoutez des propositions communes (AES-128 + SHA1 comme fallback)

> [!warning] Firewall WAN Assurez-vous que les règles firewall WAN autorisent :
> 
> - UDP port 500 (IKE)
> - UDP port 4500 (NAT-T si applicable)
> - Protocol ESP (IP protocol 50)

#### 🟡 Phase 1 OK mais Phase 2 KO

**Symptômes :**

- Phase 1 : ESTABLISHED
- Phase 2 : jamais INSTALLED
- Logs : "no matching CHILD_SA config"

**Causes possibles :**

1. **Proxy-ID non correspondants**
    
    Vérifiez la symétrie :
    
    ```
    Site A → Site B
    Local: 192.168.1.0/24  →  Remote: 10.10.0.0/24
    
    Site B → Site A  
    Local: 10.10.0.0/24  →  Remote: 192.168.1.0/24
    ```
    
2. **Algorithmes Phase 2 incompatibles**
    
    Ajoutez AES-128 en plus d'AES-256
    
3. **PFS non correspondant**
    
    Vérifiez que le DH Group est identique (ou désactivé) des deux côtés
    

> [!tip] Astuce diagnostic Activez le mode "Show Advanced" dans les logs IPsec pour voir les Proxy-ID négociés et identifier la différence.

#### 🟢 Tunnel établi mais pas de trafic

**Symptômes :**

- Phase 1 et 2 : OK
- Impossible de pinger à travers le tunnel

**Causes possibles :**

1. **Règles firewall IPsec**
    
    Vérifiez : `Firewall > Rules > IPsec`
    
    Ajoutez une règle :
    
    ```
    Action: Pass
    Protocol: Any
    Source: any
    Destination: any
    Description: Allow all IPsec traffic
    ```
    
2. **Pas de route sur les machines**
    
    Les PCs doivent avoir pfSense comme passerelle par défaut, ou une route spécifique vers le réseau distant :
    
    ```bash
    # Sur Windows
    route add 10.10.0.0 MASK 255.255.255.0 192.168.1.1
    
    # Sur Linux
    ip route add 10.10.0.0/24 via 192.168.1.1
    ```
    
3. **NAT Outbound sur le trafic VPN**
    
    Vérifiez : `Firewall > NAT > Outbound`
    
    Le trafic vers le réseau distant ne doit **PAS** être NATé :
    
    ```
    Mode: Hybrid ou Manual
    
    Ajouter une règle de NON-NAT :
    Interface: WAN
    Source: 192.168.1.0/24
    Destination: 10.10.0.0/24 (réseau distant)
    ☑ No NAT
    ```
    
4. **Asymmetric routing**
    
    Vérifiez que le trafic retour passe bien par le tunnel et non par une autre route.
    

> [!warning] Piège classique : NAT Le trafic destiné au tunnel IPsec ne doit **JAMAIS** être NATé, sinon les Proxy-ID ne correspondront plus et le trafic ne sera pas encapsulé dans le tunnel.

#### ⚡ Tunnel instable (déconnexions fréquentes)

**Causes possibles :**

1. **DPD trop agressif**
    
    Augmentez les valeurs :
    
    ```
    DPD Delay: 30 secondes
    Max failures: 10
    ```
    
2. **Lifetime trop court**
    
    Des renégociations trop fréquentes peuvent causer des micro-coupures :
    
    ```
    Phase 1 Lifetime: 28800s (8h) minimum
    Phase 2 Lifetime: 3600s (1h) ou plus
    ```
    
3. **Lien Internet instable**
    
    Activez le "Automatically ping host" pour maintenir le tunnel :
    
    ```
    Phase 2 > Automatically ping host: [IP stable du réseau distant]
    ```
    
4. **MTU et fragmentation**
    
    Problème classique avec IPsec : le chiffrement ajoute des en-têtes, ce qui peut causer de la fragmentation.
    
    Solution : ajuster le MSS Clamping
    
    `Firewall > Rules > IPsec`
    
    Dans les options avancées de la règle Pass :
    
    ```
    Advanced Options > Max MSS: 1300
    ```
    

> [!info] Calcul du MTU
> 
> - MTU standard Ethernet : 1500 bytes
> - En-têtes IP : 20 bytes
> - En-têtes ESP : ~50-60 bytes
> - En-têtes UDP (si NAT-T) : 8 bytes
> 
> MTU effectif avec IPsec : ~1400 bytes MSS recommandé : 1300-1360 bytes

#### 📊 Performance dégradée

**Symptômes :**

- Tunnel fonctionnel mais débit faible
- Latence élevée

**Causes et solutions :**

1. **CPU surchargé par le chiffrement**
    
    Vérifiez : `Status > System > System Information`
    
    Si CPU > 80% lors du trafic VPN :
    
    - Passez à AES-128 au lieu d'AES-256 (plus léger)
    - Envisagez du matériel avec accélération AES-NI
    - Vérifiez que AES-NI est activé : `System > Advanced > Miscellaneous`
2. **Algorithmes faibles mais gourmands**
    
    Évitez 3DES, SHA512 qui sont lents. Privilégiez :
    
    ```
    AES-128 ou AES-256 (avec AES-NI)
    SHA256
    DH Group 14
    ```
    
3. **Multiples renégociations**
    
    Augmentez les Lifetime pour réduire les renégociations
    
4. **QoS et prioritisation**
    
    Si vous avez du trafic mixte (VoIP + données) dans le tunnel, configurez des priorités :
    
    `Firewall > Traffic Shaper`
    

> [!tip] Vérifier les performances Utilisez `iperf3` entre deux machines à travers le tunnel pour mesurer le débit réel :
> 
> ```bash
> # Sur le serveur (site distant)
> iperf3 -s
> 
> # Sur le client (site local)
> iperf3 -c [IP_serveur_distant] -t 30
> ```

#### 🔐 Erreur d'authentification

**Symptômes :**

- Logs : "authentication failed"
- Phase 1 ne s'établit jamais

**Solutions :**

1. **Avec PSK**
    
    - Vérifiez que la PSK est **exactement identique** (sensible à la casse)
    - Réinitialisez la PSK des deux côtés simultanément
    - Évitez les caractères spéciaux exotiques (restez sur A-Z, 0-9, @#$%^&*)
2. **Avec certificats**
    
    - Vérifiez que les certificats ne sont pas expirés
    - Vérifiez que la CA est bien importée des deux côtés
    - Vérifiez que le CN (Common Name) du certificat correspond à l'identifier
3. **Identifiers mal configurés**
    
    Phase 1 :
    
    ```
    My identifier: My IP address (ou Distinguished name si certificat)
    Peer identifier: Peer IP address (ou Distinguished name si certificat)
    ```
    
    Ces valeurs doivent correspondre aux configurations inverses du pair.
    

---

## 📚 Bonnes pratiques

### Sécurité

> [!tip] Recommandations de sécurité
> 
> **Phase 1 :**
> 
> - ✅ Utilisez IKEv2 (pas IKEv1)
> - ✅ PSK de minimum 20 caractères complexes
> - ✅ AES-256 + SHA256 + DH Group 14 minimum
> - ✅ Activez DPD pour détecter les pannes
> 
> **Phase 2 :**
> 
> - ✅ ESP uniquement (pas AH)
> - ✅ PFS activé (DH Group 14)
> - ✅ Lifetime raisonnable (1-8 heures)
> - ✅ Proxy-ID précis (pas de 0.0.0.0/0 en production)
> 
> **Firewall :**
> 
> - ✅ Règles spécifiques sur l'interface IPsec
> - ✅ Logging activé pour audit
> - ✅ Pas de règle "any/any" sauf en phase de test

### Documentation

Pour chaque tunnel, documentez :

```markdown
## Tunnel IPsec - Site Agence Paris

**Informations générales :**
- Remote Gateway: 203.0.113.50
- PSK: [stockée dans gestionnaire de mots de passe]
- Date de création: 2025-01-10
- Contact distant: Jean Dupont (j.dupont@example.com)

**Réseaux interconnectés :**
- Local: 192.168.1.0/24 (LAN Paris)
- Remote: 10.10.0.0/24 (LAN Agence)

**Configuration Phase 1 :**
- Version: IKEv2
- Encryption: AES-256
- Hash: SHA256
- DH Group: 14

**Configuration Phase 2 :**
- Encryption: AES-256
- Hash: SHA256
- PFS Group: 14
- Lifetime: 3600s
```

> [!tip] Gestion centralisée Utilisez un tableau récapitulatif pour tous vos tunnels :
> 
> |Site|IP WAN|Réseaux locaux|Réseaux distants|État|Dernière vérif|
> |---|---|---|---|---|---|
> |Paris|203.0.113.50|192.168.1.0/24|10.10.0.0/24|🟢|2025-01-10|
> |Lyon|198.51.100.75|10.10.0.0/24|192.168.1.0/24|🟢|2025-01-10|

### Monitoring

**Vérifications régulières :**

1. **Status des tunnels** (quotidien)
    
    - Tous les tunnels sont connectés
    - Pas d'erreurs dans les logs
2. **Performance** (hebdomadaire)
    
    - Débit satisfaisant
    - Latence normale
    - CPU < 70% lors du trafic VPN
3. **Sécurité** (mensuel)
    
    - Logs d'authentification (tentatives suspectes ?)
    - Rotation des PSK si nécessaire
    - Vérification des certificats (expiration)
    - Mise à jour pfSense

> [!example] Script de monitoring simple Créez un alias contenant les IPs à pinger de l'autre côté de chaque tunnel, puis configurez le "Automatically ping host" sur chaque Phase 2. Surveillez les alertes de connectivité.

### Sauvegarde

**Configuration à sauvegarder régulièrement :**

`Diagnostics > Backup & Restore`

```
☑ IPsec configuration
☑ Firewall rules
☑ NAT configuration
☑ Certificates (si applicable)
```

> [!warning] Sécurité des sauvegardes Les sauvegardes contiennent les PSK en clair ! Stockez-les de manière sécurisée :
> 
> - Chiffrement du fichier de backup
> - Stockage hors-ligne ou dans un vault sécurisé
> - Accès restreint

### Évolutivité

**Planification de la croissance :**

1. **Ajout de nouveaux sites**
    
    - Documentez les plages IP utilisées
    - Évitez les chevauchements de réseaux
    - Planifiez la topologie (Hub & Spoke vs Full Mesh)
2. **Changement d'IP publique**
    
    - Si possible, utilisez DynDNS pour les sites à IP dynamique
    - Configurez des notifications d'alerte
    - Prévoyez une procédure de mise à jour coordonnée
3. **Migration vers IKEv2**
    
    - Si vous utilisez encore IKEv1, planifiez la migration
    - Testez d'abord sur un tunnel non-critique
    - Migrez site par site

---

## 🎯 Pièges à éviter

### ❌ Erreurs de configuration courantes

1. **Proxy-ID asymétriques**
    
    ```
    ❌ Site A: Local 192.168.1.0/24 → Remote 10.0.0.0/8
    ❌ Site B: Local 10.10.0.0/24 → Remote 192.168.0.0/16
    
    ✅ Site A: Local 192.168.1.0/24 → Remote 10.10.0.0/24
    ✅ Site B: Local 10.10.0.0/24 → Remote 192.168.1.0/24
    ```
    
2. **NAT sur le trafic VPN**
    
    ```
    ❌ Outbound NAT actif pour destination = réseau distant
    ✅ Règle spécifique "No NAT" pour le trafic VPN
    ```
    
3. **Pas de règle firewall IPsec**
    
    ```
    ❌ Aucune règle sur l'interface IPsec
    ✅ Au minimum : Action Pass, Protocol Any, Source any, Dest any
    ```
    
4. **PSK faible**
    
    ```
    ❌ "password123" ou "azerty"
    ✅ "Kx9#mP2$vL5@nQ8!wR4^tY7&zXcVbN1@"
    ```
    
5. **Oublier les routes statiques**
    
    Si vos réseaux locaux ne sont pas directement connectés à pfSense :
    
    ```
    ❌ pfSense ne sait pas router vers 192.168.10.0/24
    ✅ Ajouter route statique : 192.168.10.0/24 via gateway interne
    ```
    

### ⚠️ Pièges de déploiement

1. **Test en production sans plan B**
    
    ✅ Testez toujours sur un tunnel non-critique d'abord ✅ Ayez un accès physique ou out-of-band au site distant ✅ Planifiez une fenêtre de maintenance
    
2. **Modifications simultanées des deux côtés**
    
    ✅ Modifiez un côté, vérifiez, puis l'autre ✅ Documentez qui fait quoi et quand
    
3. **Upgrade pfSense sans vérification**
    
    ✅ Vérifiez les release notes (changements IPsec ?) ✅ Testez sur un environnement de lab si possible ✅ Sauvegardez avant upgrade
    

### 🔍 Checklist de dépannage

Suivez cette checklist dans l'ordre :

```
□ 1. Le WAN est-il fonctionnel ?
   → Ping l'IP publique du pair distant

□ 2. Les ports IPsec sont-ils ouverts ?
   → WAN Rules : UDP 500, UDP 4500, Protocol ESP

□ 3. La Phase 1 s'établit-elle ?
   → Status > IPsec : Phase 1 ESTABLISHED ?

□ 4. Les algorithmes sont-ils compatibles ?
   → Logs IPsec : "no matching proposal" ?

□ 5. L'authentification fonctionne-t-elle ?
   → PSK identique ? Certificats valides ?

□ 6. La Phase 2 s'établit-elle ?
   → Status > IPsec : Phase 2 INSTALLED ?

□ 7. Les Proxy-ID correspondent-ils ?
   → Vérifier Local/Remote des deux côtés

□ 8. Le trafic est-il autorisé par le firewall ?
   → Firewall > Rules > IPsec : règle Pass ?

□ 9. Le NAT est-il désactivé pour le VPN ?
   → Firewall > NAT > Outbound : règle "No NAT" ?

□ 10. Les routes sont-elles correctes ?
   → Diagnostics > Routes : réseau distant présent ?

□ 11. Le trafic passe-t-il réellement dans le tunnel ?
   → Status > IPsec : compteurs de trafic augmentent ?

□ 12. Les machines finales ont-elles la bonne gateway ?
   → PCs : gateway = IP de pfSense ?
```

---

## 💡 Astuces avancées

### Tunnel de secours (Failover)

Créez un tunnel IPsec redondant sur une seconde connexion WAN :

```
Tunnel principal : WAN1 (Fibre)
Tunnel de backup : WAN2 (4G/5G)
```

Configuration :

- Deux Phase 1 distinctes (une par WAN)
- Mêmes Proxy-ID sur les deux Phase 2
- Gateway Group avec priorités
- Monitoring pour basculement automatique

### IPsec + OSPF ou BGP

Pour des infrastructures complexes, combinez IPsec avec un protocole de routage dynamique :

```
IPsec : assure le chiffrement
OSPF/BGP : gère le routage dynamique
```

> [!info] Cas d'usage Infrastructure avec multiples chemins redondants, où les routes doivent s'adapter automatiquement aux pannes.

### Debugging avancé

**Mode debug strongSwan :**

Console SSH sur pfSense :

```bash
# Activer le debug
ipsec stroke loglevel ike 3
ipsec stroke loglevel net 3

# Voir les logs en temps réel
clog -f /var/log/ipsec.log

# Désactiver après dépannage
ipsec stroke loglevel ike 1
ipsec stroke loglevel net 1
```

**Afficher les SA actives :**

```bash
# Security Associations
ipsec statusall

# SPD (Security Policy Database)
setkey -DP

# SAD (Security Association Database)
setkey -D
```

### Performance : AES-NI

Vérifiez que l'accélération matérielle AES-NI est active :

```bash
# Via SSH
sysctl dev.aesni

# Si présent et chargé :
dev.aesni.0.%desc: AES-CBC,AES-XTS,AES-GCM,AES-ICM
```

Activation : `System > Advanced > Miscellaneous`

```
☑ AES-NI CPU-based Acceleration
```

> [!tip] Gain de performance Avec AES-NI, le chiffrement AES peut être **5 à 10 fois plus rapide** sans surcharge CPU significative.

---

## 📖 Récapitulatif

### Étapes de configuration complète

**1. Phase 1 (IKE)**

- Version : IKEv2
- Interface : WAN
- Remote Gateway : IP publique du pair
- Authentication : Mutual PSK (ou certificats)
- Encryption : AES-256 + SHA256 + DH Group 14
- NAT Traversal : Auto
- DPD : Activé (10s / 5 failures)

**2. Phase 2 (IPsec)**

- Mode : Tunnel IPv4
- Local Network : votre LAN
- Remote Network : LAN distant
- Protocol : ESP
- Encryption : AES-256 + SHA256
- PFS : Group 14
- Lifetime : 3600s

**3. Firewall**

- WAN Rules : UDP 500, UDP 4500, ESP
- IPsec Rules : Pass any/any (ou spécifique)
- NAT Outbound : No NAT pour trafic VPN

**4. Vérification**

- Status > IPsec : Phase 1 & 2 connectées
- Diagnostics > Ping : test depuis pfSense
- Test depuis PC du LAN
- Vérification des compteurs de trafic

### Commandes utiles

```bash
# Redémarrer IPsec
/etc/rc.d/ipsec restart

# Status des tunnels
ipsec statusall

# Initier un tunnel
ipsec up [nom_connexion]

# Fermer un tunnel
ipsec down [nom_connexion]

# Logs en temps réel
clog -f /var/log/ipsec.log

# Tester la connectivité
ping -S [IP_source_locale] [IP_destination_distante]
```

### Tableau de référence rapide

|Besoin|Configuration|Valeur recommandée|
|---|---|---|
|Sécurité maximale|Phase 1 Encryption|AES-256 + SHA256 + DH 14|
|Compatibilité anciens équipements|Phase 1 Encryption|AES-128 + SHA1 + DH 2|
|Performance optimale|Activer AES-NI|System > Advanced|
|Tunnel stable|Lifetime|28800s (8h)|
|Détection rapide de panne|DPD|10s delay / 5 failures|
|Éviter fragmentation|MSS Clamping|1300 bytes|
|Site à IP dynamique|NAT-T + DPD|Auto + Activé|
|Plusieurs réseaux|Multiple Phase 2|Une P2 par paire réseau|

---

## ✅ Points clés à retenir

> [!important] L'essentiel sur IPsec
> 
> **Architecture :**
> 
> - Phase 1 = tunnel de gestion (IKE)
> - Phase 2 = tunnel de données (ESP)
> - Les deux doivent être établies pour que le trafic passe
> 
> **Configuration :**
> 
> - IKEv2 est préférable à IKEv1
> - Les Proxy-ID doivent être symétriques
> - ESP est le protocole standard (pas AH)
> - AES-256 + SHA256 + DH Group 14 = sécurité moderne
> 
> **Firewall :**
> 
> - WAN : ouvrir UDP 500, 4500 et ESP
> - IPsec : règles Pass pour autoriser le trafic
> - NAT : NO NAT pour le trafic VPN
> 
> **Dépannage :**
> 
> - Logs IPsec sont votre meilleur ami
> - Vérifiez toujours Phase 1 puis Phase 2
> - Status > IPsec montre l'état en temps réel
> - Les Proxy-ID sont la cause n°1 d'échec Phase 2
> 
> **Sécurité :**
> 
> - PSK minimum 20 caractères complexes
> - Rotation régulière des clés (ou certificats)
> - Monitoring des connexions
> - Sauvegardes chiffrées de la config

---

_Cours rédigé pour pfSense - Services réseau essentiels - IPsec VPN_