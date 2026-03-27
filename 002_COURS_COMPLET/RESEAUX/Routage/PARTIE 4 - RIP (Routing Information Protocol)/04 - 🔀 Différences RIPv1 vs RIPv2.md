

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

RIP (Routing Information Protocol) existe en deux versions principales. **RIPv2** a été développé pour corriger les limitations de **RIPv1** et apporter des fonctionnalités modernes nécessaires aux réseaux actuels. Cette évolution est définie dans la RFC 2453.

> [!info] Pourquoi deux versions ? RIPv1 était adapté aux réseaux simples des années 1980 avec des adresses par classe (classful). Avec l'explosion d'Internet et l'épuisement des adresses IPv4, RIPv2 a introduit le support du VLSM et du CIDR pour une utilisation plus efficace de l'espace d'adressage.

---

## 🎯 Support du VLSM

### Qu'est-ce que le VLSM ?

Le **VLSM** (Variable Length Subnet Mask) permet d'utiliser des masques de sous-réseau de longueurs différentes au sein d'un même réseau, optimisant ainsi l'utilisation des adresses IP.

### RIPv1 : Classful (sans VLSM)

RIPv1 est un protocole **classful**, ce qui signifie :

- ❌ **N'envoie PAS** le masque de sous-réseau dans les mises à jour
- ❌ Suppose que tous les réseaux utilisent leur masque par défaut (classe A, B ou C)
- ❌ Ne supporte pas le VLSM ni le CIDR
- ❌ Effectue une summarisation automatique aux limites des classes

> [!warning] Limitation majeure Avec RIPv1, si vous utilisez 192.168.1.0/24 et 192.168.1.128/25 dans le même réseau, RIPv1 ne pourra pas les différencier. Il supposera que tout 192.168.1.x utilise un masque /24.

**Exemple de problème avec RIPv1 :**

```
Réseau réel :
- LAN A : 192.168.10.0/24 (254 hôtes)
- LAN B : 192.168.10.128/26 (62 hôtes)  ← VLSM

Ce que RIPv1 voit :
- 192.168.10.0/24 uniquement (il ignore le /26)
- Conflit et perte de routes
```

### RIPv2 : Classless (avec VLSM)

RIPv2 est un protocole **classless**, ce qui signifie :

- ✅ **Envoie** le masque de sous-réseau avec chaque route
- ✅ Supporte le VLSM et le CIDR
- ✅ Peut désactiver la summarisation automatique
- ✅ Permet une utilisation optimale de l'espace d'adressage

**Configuration RIPv2 avec VLSM :**

```bash
Router(config)# router rip
Router(config-router)# version 2
Router(config-router)# no auto-summary  # Désactive la summarisation classful
Router(config-router)# network 192.168.10.0
```

> [!tip] Bonne pratique Toujours utiliser `no auto-summary` avec RIPv2 pour profiter pleinement du VLSM. La summarisation automatique est un vestige de RIPv1 et peut causer des problèmes de routage.

**Exemple fonctionnel avec RIPv2 :**

```
Configuration :
- LAN A : 192.168.10.0/24 (254 hôtes)
- LAN B : 192.168.10.128/26 (62 hôtes)
- LAN C : 192.168.10.192/27 (30 hôtes)

RIPv2 annonce correctement :
- 192.168.10.0 avec masque 255.255.255.0
- 192.168.10.128 avec masque 255.255.255.192
- 192.168.10.192 avec masque 255.255.255.224
```

### Vérification du support VLSM

```bash
# Vérifier les routes reçues avec leur masque
Router# show ip route rip

# Voir les mises à jour envoyées/reçues
Router# debug ip rip
```

> [!example] Cas d'usage typique Une entreprise avec un réseau 10.0.0.0/8 qui veut subdiviser :
> 
> - Siège social : 10.1.0.0/16 (65 534 hôtes)
> - Agences : 10.2.1.0/24, 10.2.2.0/24, etc. (254 hôtes chacune)
> - Liens WAN : 10.100.1.0/30, 10.100.1.4/30, etc. (2 hôtes par lien)
> 
> RIPv1 ne peut pas gérer cette topologie. RIPv2 le fait sans problème.

---

## 📡 Multicasting vs Broadcasting

### RIPv1 : Broadcasting

RIPv1 utilise le **broadcast** pour envoyer ses mises à jour :

- 📢 Adresse de destination : **255.255.255.255**
- ❌ Tous les appareils du réseau local reçoivent les paquets
- ❌ Gaspillage de bande passante et de ressources CPU
- ❌ Même les non-routeurs traitent les paquets (pour ensuite les ignorer)

**Impact sur le réseau :**

```
Réseau avec 100 appareils dont 3 routeurs :
- RIPv1 envoie à 255.255.255.255
- Les 100 appareils reçoivent et traitent le paquet
- 97 appareils jettent le paquet après traitement initial
- Inefficace et perturbateur
```

> [!warning] Problème de sécurité Le broadcast RIPv1 peut être intercepté par n'importe quel appareil sur le réseau, rendant la topologie visible à tous. De plus, impossible d'authentifier les sources.

### RIPv2 : Multicasting

RIPv2 utilise le **multicast** pour ses mises à jour :

- 📡 Adresse de destination : **224.0.0.9**
- ✅ Seuls les routeurs ayant rejoint le groupe multicast reçoivent
- ✅ Les autres appareils ignorent complètement les paquets
- ✅ Économie de ressources réseau et CPU
- ✅ Plus efficace et moins intrusif

**Fonctionnement du multicast :**

```
Réseau avec 100 appareils dont 3 routeurs RIPv2 :
- RIPv2 envoie à 224.0.0.9 (groupe multicast)
- Seuls les 3 routeurs traitent les paquets
- Les 97 autres appareils ignorent au niveau carte réseau
- Efficace et transparent pour les hôtes
```

> [!info] Adresse multicast réservée L'adresse **224.0.0.9** est officiellement réservée par l'IANA pour RIPv2. C'est une adresse du range 224.0.0.0/24 réservé aux protocoles de routage.

### Configuration et vérification

```bash
# RIPv2 utilise automatiquement le multicast 224.0.0.9
Router(config)# router rip
Router(config-router)# version 2

# Vérifier les interfaces multicast
Router# show ip igmp groups
# Vous devriez voir 224.0.0.9 sur les interfaces RIP

# Capturer les paquets RIP
Router# debug ip rip
# Output montrera les envois vers 224.0.0.9
```

### Comparaison de performance

|Critère|RIPv1 (Broadcast)|RIPv2 (Multicast)|
|---|---|---|
|Adresse destination|255.255.255.255|224.0.0.9|
|Appareils impactés|Tous sur le LAN|Seulement routeurs RIP|
|Charge CPU hôtes|Élevée|Minimale|
|Bande passante|Gaspillée|Optimisée|
|Sécurité|Faible|Meilleure (+ auth)|

> [!tip] Impact sur les gros réseaux Sur un réseau avec des centaines de postes clients, la différence entre broadcast et multicast est significative. Les broadcasts RIPv1 toutes les 30 secondes peuvent causer des micro-latences sur les postes, particulièrement visibles dans les applications temps réel (VoIP, visio).

---

## 🔐 Authentication

### RIPv1 : Aucune authentification

RIPv1 ne supporte **aucune forme d'authentification** :

- ❌ N'importe qui peut injecter de fausses routes
- ❌ Vulnérable aux attaques man-in-the-middle
- ❌ Impossible de vérifier la source des mises à jour
- ❌ Risque de détournement de trafic

> [!warning] Risque de sécurité critique Un attaquant sur le réseau peut facilement annoncer une route par défaut (0.0.0.0/0) avec une métrique faible et détourner tout le trafic vers son propre routeur pour intercepter les données.

**Exemple d'attaque sur RIPv1 :**

```
Attaquant connecté au LAN :
1. Envoie un paquet RIP avec route 0.0.0.0/0 metric 1
2. Les routeurs légitimes acceptent cette route
3. Tout le trafic Internet est redirigé vers l'attaquant
4. L'attaquant peut intercepter, modifier ou bloquer le trafic
```

### RIPv2 : Support de l'authentification

RIPv2 intègre un mécanisme d'authentification pour sécuriser les échanges :

- ✅ Vérifie l'identité de l'émetteur des mises à jour
- ✅ Empêche l'injection de fausses routes
- ✅ Deux modes disponibles : **plain text** et **MD5**
- ✅ Protection contre les attaques basiques

#### Authentification Plain Text

Le mode **plain text** (texte clair) est le plus simple mais le moins sécurisé :

- 🔓 Mot de passe envoyé en clair
- ❌ Vulnérable au sniffing réseau
- ⚠️ Mieux que rien, mais à éviter en production

**Configuration Plain Text :**

```bash
# Créer une key chain
Router(config)# key chain RIP_KEY
Router(config-keychain)# key 1
Router(config-keychain-key)# key-string MonMotDePasse123

# Appliquer sur l'interface
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip rip authentication mode text
Router(config-if)# ip rip authentication key-chain RIP_KEY
```

> [!warning] Plain text visible Avec Wireshark ou `debug ip rip`, n'importe qui sur le réseau peut voir le mot de passe. Cette méthode n'est acceptable QUE sur des réseaux totalement isolés et sécurisés physiquement.

#### Authentification MD5 (Recommandée)

Le mode **MD5** utilise un hash cryptographique :

- 🔒 Mot de passe jamais envoyé sur le réseau
- ✅ Hash MD5 du message + clé secrète
- ✅ Protection contre le sniffing et le replay
- ✅ Standard pour RIPv2 en production

**Configuration MD5 :**

```bash
# Créer une key chain avec plusieurs clés pour rotation
Router(config)# key chain RIP_MD5
Router(config-keychain)# key 1
Router(config-keychain-key)# key-string ClefSecrete456
Router(config-keychain-key)# accept-lifetime 00:00:00 Jan 1 2024 infinite
Router(config-keychain-key)# send-lifetime 00:00:00 Jan 1 2024 23:59:59 Dec 31 2024

# Clé de secours pour l'année suivante
Router(config-keychain)# key 2
Router(config-keychain-key)# key-string NouvelleClef789
Router(config-keychain-key)# accept-lifetime 00:00:00 Dec 1 2024 infinite
Router(config-keychain-key)# send-lifetime 00:00:00 Jan 1 2025 infinite

# Appliquer sur l'interface
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip rip authentication mode md5
Router(config-if)# ip rip authentication key-chain RIP_MD5
```

> [!tip] Rotation des clés Utilisez plusieurs clés avec des périodes de validité pour permettre une rotation sans interruption. La clé 1 expire fin 2024, mais la clé 2 est acceptée dès décembre 2024, permettant une transition en douceur.

#### Vérification de l'authentification

```bash
# Vérifier le statut d'authentification
Router# show ip rip database

# Voir les détails des interfaces RIP
Router# show ip protocols

# Déboguer les problèmes d'authentification
Router# debug ip rip
# Vous verrez des messages d'erreur si l'auth échoue

# Vérifier les key chains configurées
Router# show key chain
```

### Comparaison des méthodes d'authentification

|Méthode|Sécurité|Performance|Cas d'usage|
|---|---|---|---|
|Aucune (RIPv1)|❌ Nulle|⚡ Maximale|Labo/Test uniquement|
|Plain Text|🔓 Faible|⚡ Excellente|Réseau isolé physiquement|
|MD5 (RIPv2)|🔒 Bonne|✅ Bonne|**Production recommandée**|

> [!example] Scénario d'entreprise Une entreprise avec 3 sites interconnectés par VPN MPLS :
> 
> - Sans auth : Risque qu'un site compromis injecte des routes malveillantes
> - Avec MD5 : Seuls les routeurs légitimes avec la bonne clé peuvent échanger des routes
> - Même si un attaquant capture le trafic, il ne peut pas déchiffrer ni rejouer les paquets

### Pièges courants avec l'authentification

> [!warning] Erreurs fréquentes
> 
> 1. **Key chain mal synchronisée** : Les deux routeurs doivent avoir la même clé active
> 2. **Horloge désynchronisée** : Les `accept-lifetime` et `send-lifetime` dépendent de l'horloge système
> 3. **Majuscules/minuscules** : Les clés sont sensibles à la casse
> 4. **Interface oubliée** : L'auth doit être activée sur TOUTES les interfaces RIP

**Exemple de diagnostic :**

```bash
# Si les routes disparaissent après avoir activé l'auth
Router# debug ip rip
# Vous verrez : "RIPv2 authentication failed"

# Vérifier l'horloge
Router# show clock

# Vérifier les key chains sur les deux routeurs
Router# show key chain

# Comparer les configurations
Router# show running-config | section key chain
Router# show running-config | section interface
```

---

## 📊 Tableau comparatif général

|Caractéristique|RIPv1|RIPv2|
|---|---|---|
|**RFC**|RFC 1058 (1988)|RFC 2453 (1998)|
|**Classe**|Classful|Classless|
|**Masque de sous-réseau**|❌ Non envoyé|✅ Envoyé avec chaque route|
|**VLSM / CIDR**|❌ Non supporté|✅ Supporté|
|**Mode de diffusion**|Broadcast (255.255.255.255)|Multicast (224.0.0.9)|
|**Authentification**|❌ Aucune|✅ Text et MD5|
|**Summarisation auto**|✅ Toujours active|⚙️ Configurable (no auto-summary)|
|**Route tagging**|❌ Non|✅ Oui (pour filtrage)|
|**Métrique maximale**|15 hops|15 hops|
|**Compatibilité**|❌ Ne fonctionne pas avec RIPv2|✅ Peut recevoir RIPv1|
|**Sécurité**|🔓 Très faible|🔒 Moyenne (avec MD5)|
|**Usage moderne**|⛔ Obsolète|⚠️ Réseaux simples uniquement|

> [!info] Compatibilité RIPv1 ↔ RIPv2 Par défaut, un routeur RIPv2 peut recevoir à la fois RIPv1 et RIPv2, mais envoie uniquement RIPv2. Ceci permet une migration progressive dans un réseau mixte.

---

## 🔄 Migration de RIPv1 vers RIPv2

### Stratégie de migration

Pour migrer un réseau de RIPv1 vers RIPv2 sans interruption :

**Étape 1 : Préparation**

```bash
# Sur chaque routeur, vérifier la configuration actuelle
Router# show ip protocols
Router# show ip route rip

# Documenter la topologie et les routes existantes
```

**Étape 2 : Configuration RIPv2 en mode compatible**

```bash
# Activer RIPv2 mais accepter aussi RIPv1 temporairement
Router(config)# router rip
Router(config-router)# version 2
Router(config-router)# no auto-summary

# À ce stade : envoie RIPv2, accepte RIPv1 et RIPv2
```

**Étape 3 : Migration progressive**

Migrer routeur par routeur, en commençant par les routeurs de cœur :

```bash
# Sur chaque routeur
Router(config)# router rip
Router(config-router)# version 2
Router(config-router)# no auto-summary

# Vérifier que les routes sont toujours échangées
Router# show ip route rip
Router# show ip protocols
```

**Étape 4 : Désactivation stricte de RIPv1**

Une fois tous les routeurs en RIPv2 :

```bash
# Sur toutes les interfaces, forcer RIPv2 uniquement
Router(config)# interface range GigabitEthernet0/0-1
Router(config-if-range)# ip rip send version 2
Router(config-if-range)# ip rip receive version 2
```

**Étape 5 : Ajout de l'authentification MD5**

```bash
# Déployer les key chains progressivement
Router(config)# key chain RIP_PROD
Router(config-keychain)# key 1
Router(config-keychain-key)# key-string P@ssw0rd$ecure2024

# Activer sur toutes les interfaces RIP
Router(config)# interface range GigabitEthernet0/0-1
Router(config-if-range)# ip rip authentication mode md5
Router(config-if-range)# ip rip authentication key-chain RIP_PROD
```

> [!tip] Astuce de production Planifiez la migration durant une fenêtre de maintenance. Même si RIPv2 accepte RIPv1 par défaut, des problèmes de VLSM ou de summarisation peuvent survenir. Ayez un plan de rollback prêt.

### Vérifications post-migration

```bash
# Confirmer que tous les routeurs utilisent RIPv2
Router# show ip protocols | include Routing Protocol
# Devrait montrer : Routing Protocol is "rip" version 2

# Vérifier que toutes les routes incluent les masques
Router# show ip route rip
# Les routes doivent afficher le masque complet (ex: /27)

# Confirmer l'utilisation du multicast
Router# debug ip rip
# Les updates doivent être envoyés à 224.0.0.9

# Tester l'authentification
# Essayer de connecter un routeur sans auth → doit échouer
```

### Checklist de migration

- [ ] Documentation de la topologie existante
- [ ] Sauvegarde des configurations (`copy running-config tftp`)
- [ ] Fenêtre de maintenance planifiée
- [ ] Activation de RIPv2 sur tous les routeurs
- [ ] Désactivation de `auto-summary`
- [ ] Vérification de la connectivité entre tous les sites
- [ ] Configuration des key chains identiques
- [ ] Activation de l'authentification MD5
- [ ] Tests de connectivité complets
- [ ] Monitoring pendant 24-48h post-migration

> [!warning] Ne jamais mélanger en production Même si techniquement possible, ne laissez JAMAIS un réseau en mode mixte RIPv1/RIPv2 en production. C'est une configuration transitoire uniquement. Les différences de comportement (VLSM, summarisation) peuvent créer des routes incohérentes et des trous noirs de routage.

---

## 🎯 Points clés à retenir

1. **VLSM** : RIPv2 envoie les masques, RIPv1 non → RIPv2 seul supporte VLSM
2. **Multicast** : RIPv2 utilise 224.0.0.9, RIPv1 broadcast 255.255.255.255 → RIPv2 plus efficace
3. **Authentification** : RIPv2 supporte MD5, RIPv1 rien → RIPv2 beaucoup plus sécurisé
4. **Commande essentielle** : `no auto-summary` pour exploiter pleinement RIPv2
5. **Migration** : Peut se faire progressivement grâce à la compatibilité RIPv2→RIPv1

> [!tip] Recommandation finale Dans tout nouveau déploiement, utilisez **RIPv2 avec MD5** et `no auto-summary`. RIPv1 ne devrait plus être utilisé que dans des environnements de laboratoire ou des systèmes legacy qui ne peuvent être mis à jour.