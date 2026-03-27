

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

## Introduction

La distance administrative est un concept fondamental dans le routage qui permet à un routeur de choisir entre plusieurs sources d'information de routage. Elle représente la **fiabilité** d'une source de routage selon Cisco.

> [!info] Contexte d'utilisation La distance administrative n'intervient que lorsqu'un routeur apprend **la même route** (même réseau de destination) via **plusieurs protocoles de routage différents**. C'est le premier critère de décision avant même de regarder la métrique.

---

## Définition et rôle

### Qu'est-ce que la distance administrative ?

La **distance administrative (AD)** est une valeur numérique entre **0 et 255** qui indique le niveau de confiance accordé à une source d'information de routage.

> [!tip] Principe clé **Plus la valeur est basse, plus la source est considérée comme fiable.**
> 
> - AD = 0 : confiance maximale (interface directement connectée)
> - AD = 255 : source non fiable (route rejetée)

### Rôle dans la décision de routage

Le processus de décision du routeur suit cet ordre :

1. **Longueur du préfixe** (longest prefix match) - route la plus spécifique
2. **Distance administrative** - source la plus fiable
3. **Métrique** - meilleur chemin selon le protocole

> [!example] Exemple concret Un routeur apprend le réseau 10.0.0.0/8 via :
> 
> - OSPF avec une métrique de 10
> - RIP avec une métrique de 2
> 
> Même si RIP a une meilleure métrique, OSPF sera choisi car il a une AD plus faible (110 vs 120).

### Pourquoi la distance administrative est importante ?

- **Détermine quelle route installer dans la table de routage** quand plusieurs sources fournissent la même information
- **Permet la redondance** entre protocoles de routage
- **Facilite les migrations** d'un protocole à un autre
- **Contrôle manuel possible** pour influencer la sélection des routes

---

## Valeurs par défaut des protocoles

Cisco a défini des valeurs standard de distance administrative pour chaque source de routage :

|Source de routage|Distance Administrative|Fiabilité|
|---|---|---|
|**Interface connectée**|0|Maximale|
|**Route statique**|1|Très haute|
|**Route résumée EIGRP**|5|Très haute|
|**eBGP (External BGP)**|20|Haute|
|**EIGRP (interne)**|90|Haute|
|**IGRP**|100|Moyenne-haute|
|**OSPF**|110|Moyenne-haute|
|**IS-IS**|115|Moyenne|
|**RIP**|120|Moyenne|
|**EGP**|140|Moyenne-basse|
|**ODR (On-Demand Routing)**|160|Basse|
|**EIGRP (externe)**|170|Basse|
|**iBGP (Internal BGP)**|200|Très basse|
|**Route inconnue**|255|Non fiable (rejetée)|

> [!info] Routes spéciales
> 
> - **AD 0** : Routes d'interfaces directement connectées - toujours préférées
> - **AD 1** : Routes statiques par défaut - très fiables car configurées manuellement
> - **AD 255** : Route invalide, jamais installée dans la table de routage

### Logique derrière ces valeurs

Les valeurs reflètent une hiérarchie de confiance :

- **Routes directes (0)** : information locale, 100% fiable
- **Configuration manuelle (1-5)** : contrôle administrateur
- **IGP modernes (20-115)** : protocoles internes éprouvés
- **IGP anciens (120-140)** : protocoles moins sophistiqués
- **Routes externes/redistribuées (170-200)** : information de seconde main

> [!warning] Attention Ces valeurs par défaut sont spécifiques à **Cisco IOS**. D'autres constructeurs peuvent utiliser des valeurs différentes.

---

## Modification de la distance administrative

### Pourquoi modifier l'AD ?

- **Influencer la sélection des routes** entre protocoles
- **Créer une route de secours** (floating static route)
- **Résoudre des problèmes de préférence** dans des topologies complexes
- **Tester des migrations** de protocoles

### Syntaxe de modification

#### Pour les routes statiques

```bash
# Route statique avec AD personnalisée
Router(config)# ip route [réseau] [masque] [next-hop | interface] [distance]

# Exemple : route statique de secours avec AD 130
Router(config)# ip route 192.168.10.0 255.255.255.0 10.0.0.2 130
```

> [!example] Floating Static Route
> 
> ```bash
> # Route principale (OSPF, AD 110)
> Router(config)# router ospf 1
> Router(config-router)# network 192.168.10.0 0.0.0.255 area 0
> 
> # Route statique de secours (AD 130 > 110)
> Router(config)# ip route 192.168.10.0 255.255.255.0 10.0.0.2 130
> ```
> 
> La route statique ne sera utilisée que si OSPF tombe.

#### Pour EIGRP

```bash
# Modifier l'AD pour toutes les routes EIGRP
Router(config)# router eigrp [AS-number]
Router(config-router)# distance eigrp [AD-interne] [AD-externe]

# Exemple
Router(config)# router eigrp 100
Router(config-router)# distance eigrp 95 175
```

> [!info] EIGRP a deux valeurs
> 
> - **AD interne** (défaut 90) : routes apprises dans le même système autonome
> - **AD externe** (défaut 170) : routes redistribuées d'autres protocoles

#### Pour OSPF

```bash
# Modifier l'AD pour toutes les routes OSPF
Router(config)# router ospf [process-id]
Router(config-router)# distance [AD-value]

# Exemple
Router(config)# router ospf 1
Router(config-router)# distance 115
```

#### Pour RIP

```bash
# Modifier l'AD pour toutes les routes RIP
Router(config)# router rip
Router(config-router)# distance [AD-value]

# Exemple
Router(config)# router rip
Router(config-router)# distance 125
```

#### Modification sélective avec listes d'accès

```bash
# Modifier l'AD uniquement pour certaines routes
Router(config-router)# distance [AD] [source-IP] [wildcard] [ACL]

# Exemple : AD 95 pour routes de 10.1.1.0/24 via OSPF
Router(config)# access-list 1 permit 10.1.1.0 0.0.0.255
Router(config)# router ospf 1
Router(config-router)# distance 95 0.0.0.0 255.255.255.255 1
```

> [!tip] Astuce Utilisez la modification sélective pour un contrôle granulaire sans affecter toutes les routes du protocole.

### Vérification

```bash
# Voir la distance administrative des routes
Router# show ip route

# Détails d'une route spécifique
Router# show ip route 192.168.10.0

# Voir la configuration du protocole
Router# show ip protocols
```

> [!example] Lecture de la table de routage
> 
> ```
> O    192.168.10.0/24 [110/20] via 10.0.0.2
> S    192.168.20.0/24 [130/0] via 10.0.0.3
> ```
> 
> - **[110/20]** : AD = 110 (OSPF), métrique = 20
> - **[130/0]** : AD = 130 (statique modifiée), métrique = 0

---

## Ordre de préférence

### Processus de sélection complet

Lorsqu'un routeur reçoit des informations sur plusieurs routes vers la même destination :

```
┌─────────────────────────────────────┐
│  1. Longueur du préfixe             │
│     (Longest prefix match)          │
│     → Route la plus spécifique      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  2. Distance Administrative         │
│     → Source la plus fiable         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  3. Métrique                        │
│     → Meilleur chemin selon         │
│       le protocole                  │
└─────────────────────────────────────┘
```

> [!info] Étapes détaillées
> 
> 1. **Longest prefix match** : 10.1.1.0/24 est préféré à 10.0.0.0/8 pour atteindre 10.1.1.50
> 2. **Si même longueur** : comparer les distances administratives
> 3. **Si même AD** : comparer les métriques du protocole
> 4. **Si tout est identique** : load balancing (si supporté)

### Scénarios d'application

#### Scénario 1 : Préfixes différents

```
Routes disponibles :
- 10.0.0.0/8 via OSPF
- 10.1.0.0/16 via RIP
- 10.1.1.0/24 via statique

Pour atteindre 10.1.1.50 → Route statique 10.1.1.0/24
(Plus spécifique, peu importe l'AD)
```

#### Scénario 2 : Même préfixe, AD différentes

```
Routes vers 192.168.1.0/24 :
- OSPF : AD 110, métrique 20
- RIP : AD 120, métrique 2
- EIGRP : AD 90, métrique 256000

Résultat → EIGRP choisi (AD la plus basse)
```

#### Scénario 3 : Même préfixe, même AD

```
Routes vers 172.16.0.0/16 via OSPF :
- Via routeur A : AD 110, métrique 20
- Via routeur B : AD 110, métrique 30

Résultat → Via routeur A (meilleure métrique)
```

### Ordre de préférence global

Voici l'ordre complet de préférence (du plus au moins préféré) :

1. **Connected** (AD 0)
2. **Static** (AD 1)
3. **EIGRP summary** (AD 5)
4. **eBGP** (AD 20)
5. **EIGRP internal** (AD 90)
6. **IGRP** (AD 100)
7. **OSPF** (AD 110)
8. **IS-IS** (AD 115)
9. **RIP** (AD 120)
10. **EIGRP external** (AD 170)
11. **iBGP** (AD 200)

> [!warning] Attention au piège Une route RIP avec une métrique de 1 sera **toujours** moins préférée qu'une route OSPF avec une métrique de 10000, car l'AD est évaluée **avant** la métrique.

---

## Pièges courants

### 1. Confusion AD vs Métrique

> [!warning] Erreur fréquente Penser que la métrique influence le choix entre protocoles différents.
> 
> **Réalité** : La métrique n'est comparée que si l'AD est identique.

```bash
# Erreur de raisonnement
"RIP a une métrique de 2, OSPF de 50, donc RIP sera choisi"
❌ FAUX : OSPF (AD 110) sera choisi avant RIP (AD 120)
```

### 2. Floating static route mal configurée

> [!warning] Piège classique
> 
> ```bash
> # Route principale OSPF (AD 110)
> # Route statique de secours - ERREUR !
> Router(config)# ip route 10.0.0.0 255.0.0.0 192.168.1.1
> ```
> 
> La route statique (AD 1) prendra **toujours** le dessus sur OSPF !
> 
> **Correction** :
> 
> ```bash
> Router(config)# ip route 10.0.0.0 255.0.0.0 192.168.1.1 150
> ```

### 3. Oublier l'impact sur toutes les routes

> [!warning] Impact global
> 
> ```bash
> Router(config-router)# distance 90
> ```
> 
> Cette commande affecte **TOUTES** les routes du protocole, pas seulement une route spécifique.

### 4. Ne pas documenter les modifications

> [!tip] Bonne pratique
> 
> ```bash
> # Toujours commenter les modifications d'AD
> Router(config)# ip route 10.0.0.0 255.0.0.0 192.168.1.1 150
> ! Route de secours si OSPF (AD 110) tombe
> ```

### 5. Conflit entre redistribution et AD

Lors de la redistribution entre protocoles, l'AD peut créer des boucles de routage si mal configurée.

> [!warning] Scénario dangereux Routeur A : OSPF → RIP (redistribution) Routeur B : RIP → OSPF (redistribution)
> 
> Sans filtrage approprié, les routes peuvent osciller entre protocoles.

### 6. AD 255 par accident

> [!warning] Route invisible Une AD de 255 rend la route **complètement invisible** dans la table de routage.
> 
> ```bash
> Router(config)# ip route 10.0.0.0 255.0.0.0 192.168.1.1 255
> # Cette route ne sera JAMAIS utilisée
> ```

---

## Bonnes pratiques

### ✅ Planification

- **Documentez** toutes les modifications d'AD dans votre documentation réseau
- **Testez** en laboratoire avant de déployer en production
- **Utilisez des valeurs cohérentes** dans toute l'infrastructure

### ✅ Floating static routes

```bash
# Structure recommandée
# Route principale : protocole dynamique (ex: OSPF, AD 110)
# Route de secours : statique avec AD > 110

Router(config)# ip route 0.0.0.0 0.0.0.0 192.168.1.1 130
! Route par défaut de secours si OSPF échoue
```

### ✅ Modification sélective

Préférez les modifications ciblées aux changements globaux :

```bash
# ✅ Bon : modification sélective
Router(config)# access-list 10 permit 172.16.0.0 0.0.255.255
Router(config-router)# distance 95 0.0.0.0 255.255.255.255 10

# ⚠️ Moins bon : modification globale
Router(config-router)# distance 95
```

### ✅ Vérification systématique

```bash
# Toujours vérifier après modification
Router# show ip route
Router# show ip protocols
Router# show run | section router
```

> [!tip] Astuce de dépannage Si une route n'apparaît pas comme prévu :
> 
> 1. Vérifiez le préfixe (longest match)
> 2. Vérifiez l'AD avec `show ip route`
> 3. Vérifiez la configuration avec `show ip protocols`
> 4. Vérifiez la connectivité de base

---

## Résumé des commandes essentielles

```bash
# Afficher les routes avec leur AD
show ip route
show ip protocols

# Route statique avec AD personnalisée
ip route [réseau] [masque] [next-hop] [distance]

# Modifier AD EIGRP
router eigrp [AS]
  distance eigrp [interne] [externe]

# Modifier AD OSPF
router ospf [process-id]
  distance [valeur]

# Modifier AD RIP
router rip
  distance [valeur]

# Modification sélective
distance [AD] [source] [wildcard] [ACL]
```

---

> [!info] Rappel important La distance administrative est un **concept Cisco** qui résout l'ambiguïté lorsque plusieurs protocoles de routage annoncent la même destination. C'est un critère de **confiance administrative**, pas de performance réseau.