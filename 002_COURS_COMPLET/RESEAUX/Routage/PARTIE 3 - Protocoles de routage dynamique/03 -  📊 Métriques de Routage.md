

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

## 🎯 Introduction aux métriques

Les **métriques de routage** sont des valeurs numériques utilisées par les protocoles de routage dynamique pour évaluer et comparer différents chemins vers une destination. Lorsqu'un routeur reçoit plusieurs routes vers le même réseau, il utilise la métrique pour déterminer quelle route est la "meilleure".

> [!info] Principe fondamental Plus la métrique est **basse**, meilleure est la route. Le routeur choisit toujours le chemin avec la métrique la plus faible pour installer dans sa table de routage.

### Pourquoi les métriques sont essentielles ?

- **Sélection optimale** : Permettent de choisir automatiquement le meilleur chemin
- **Convergence** : Facilitent la prise de décision rapide lors de changements de topologie
- **Adaptation** : S'ajustent aux conditions du réseau (pannes, congestion, etc.)
- **Différenciation** : Chaque protocole utilise ses propres critères selon ses objectifs

> [!warning] Attention Les métriques ne sont comparables qu'au sein d'un même protocole de routage. Une métrique RIP ne peut pas être directement comparée à une métrique OSPF.

---

## 🔢 Hop Count (Compte de sauts)

### Définition

Le **hop count** (compte de sauts) est la métrique la plus simple : elle compte le nombre de routeurs qu'un paquet doit traverser pour atteindre sa destination. Chaque routeur traversé = 1 saut (hop).

### Protocoles utilisant le hop count

- **RIP (Routing Information Protocol)** : Métrique exclusive
- **EIGRP** : Peut l'utiliser comme composante (rarement seul)

### Fonctionnement

```
Réseau A --[R1]-- Réseau B --[R2]-- Réseau C --[R3]-- Réseau D

Pour aller de Réseau A vers Réseau D :
- Nombre de sauts = 3 (R1, R2, R3)
- Métrique = 3
```

> [!example] Exemple pratique
> 
> ```
> RouterA connecté à Réseau 10.0.0.0/24
>    ↓ (1 saut)
> RouterB
>    ↓ (1 saut)
> RouterC connecté à Réseau 192.168.1.0/24
> 
> Métrique de RouterA vers 192.168.1.0/24 = 2 sauts
> ```

### Avantages

✅ **Simplicité** : Très facile à comprendre et à calculer ✅ **Performance** : Calcul instantané, aucune charge CPU ✅ **Déterministe** : Résultat toujours identique pour un même chemin ✅ **Indépendant du matériel** : Fonctionne sur n'importe quel équipement

### Inconvénients

❌ **Ignore la qualité des liens** : Un lien 10 Mbps = un lien 10 Gbps ❌ **Pas de notion de congestion** : Ne tient pas compte de la charge ❌ **Chemins sous-optimaux** : Peut choisir un chemin lent mais court

> [!warning] Limitation majeure de RIP RIP limite le nombre maximum de sauts à **15**. Une route avec 16 sauts ou plus est considérée comme injoignable. Cela limite RIP aux petits réseaux.

### Exemple comparatif

```
Chemin 1 : RouterA --[1 Gbps]--> RouterB --[1 Gbps]--> Destination
           Métrique = 2 sauts

Chemin 2 : RouterA --[10 Mbps]--> Destination
           Métrique = 1 saut

RIP choisira le Chemin 2 (1 saut) même s'il est 100x plus lent !
```

> [!tip] Astuce Le hop count convient aux réseaux homogènes où tous les liens ont des caractéristiques similaires. Pour des réseaux hétérogènes (mix de débits), privilégiez des métriques plus sophistiquées.

---

## 📡 Bande passante

### Définition

La **bande passante** (bandwidth) représente la capacité maximale de transmission d'un lien réseau, généralement exprimée en bits par seconde (bps, Kbps, Mbps, Gbps). C'est la métrique la plus importante pour les protocoles modernes.

### Protocoles utilisant la bande passante

- **OSPF** : Utilise la bande passante comme métrique principale (coût)
- **EIGRP** : Utilise la bande passante comme composante majeure de sa métrique composite
- **IS-IS** : Utilise un coût basé sur la bande passante

### Calcul du coût OSPF

OSPF ne stocke pas directement la bande passante mais calcule un **coût** inversement proportionnel :

```
Coût OSPF = Bande passante de référence / Bande passante du lien
```

> [!info] Bande passante de référence Par défaut, OSPF utilise une bande passante de référence de **100 Mbps** (100 000 000 bps).
> 
> Cette valeur peut être modifiée avec la commande :
> 
> ```bash
> router ospf 1
>  auto-cost reference-bandwidth 10000  # 10 Gbps en Mbps
> ```

### Exemples de calcul OSPF

|Type de lien|Bande passante|Coût par défaut|Formule|
|---|---|---|---|
|Série 64 Kbps|64 Kbps|1562|100000/64|
|T1 (1.544 Mbps)|1.544 Mbps|64|100000/1544|
|Ethernet|10 Mbps|10|100000/10|
|Fast Ethernet|100 Mbps|1|100000/100|
|Gigabit Ethernet|1 Gbps|1|100000/1000 = 0.1 → arrondi à 1|
|10 Gigabit Ethernet|10 Gbps|1|100000/10000 = 0.01 → arrondi à 1|

> [!warning] Problème des liens rapides Avec la référence par défaut de 100 Mbps, tous les liens ≥ 100 Mbps ont un coût de **1**. OSPF ne peut pas différencier un Fast Ethernet d'un 10 Gigabit Ethernet !
> 
> **Solution** : Augmenter la bande passante de référence à 10 Gbps ou plus.

### Configuration de la bande passante

```bash
# Voir la bande passante configurée
Router# show interface gigabitEthernet 0/0
  MTU 1500 bytes, BW 1000000 Kbit/sec, ...

# Modifier la bande passante (affecte les calculs de métrique)
Router(config)# interface gigabitEthernet 0/0
Router(config-if)# bandwidth 100000  # en Kbps (100 Mbps)

# Forcer un coût OSPF spécifique (ignore la bande passante)
Router(config-if)# ip ospf cost 50
```

> [!tip] Bonne pratique
> 
> - Ajustez la bande passante de référence pour correspondre aux liens les plus rapides de votre réseau
> - Configurez manuellement le coût OSPF sur les liens critiques pour un contrôle précis
> - Utilisez la même référence sur TOUS les routeurs OSPF du domaine

### Avantages

✅ **Reflète la capacité réelle** : Favorise les liens à haut débit ✅ **Pertinent pour la QoS** : Aligné avec les besoins de performance ✅ **Flexible** : Peut être ajusté manuellement si nécessaire ✅ **Standard moderne** : Utilisé par la plupart des protocoles actuels

### Inconvénients

❌ **Statique** : Ne reflète pas la charge actuelle du lien ❌ **Configuration manuelle** : Peut nécessiter des ajustements ❌ **Problème d'échelle** : Nécessite des ajustements pour les liens très rapides (>100G)

> [!example] Scénario pratique
> 
> ```
> Réseau avec 3 chemins vers la destination :
> 
> Chemin A : [1 Gbps] → [1 Gbps] → Destination
>            Coût = 1 + 1 = 2
> 
> Chemin B : [100 Mbps] → [100 Mbps] → [100 Mbps] → Destination
>            Coût = 1 + 1 + 1 = 3
> 
> Chemin C : [10 Gbps] → Destination
>            Coût = 1
> 
> OSPF choisira le Chemin C (coût le plus faible)
> ```

---

## ⏱️ Délai

### Définition

Le **délai** (delay ou latency) mesure le temps nécessaire pour qu'un paquet traverse un lien réseau. Il est exprimé en microsecondes (µs) ou millisecondes (ms) et représente la latence de transmission.

### Protocoles utilisant le délai

- **EIGRP** : Utilise le délai comme composante de sa métrique composite
- **IGRP** (obsolète) : Utilisait le délai comme métrique principale

### Types de délai

1. **Délai de propagation** : Temps physique de traversée du média (vitesse de la lumière dans la fibre, cuivre, etc.)
2. **Délai de transmission** : Temps pour placer tous les bits sur le lien
3. **Délai de traitement** : Temps de traitement par le routeur
4. **Délai de file d'attente** : Temps d'attente dans les buffers

> [!info] Délai dans EIGRP EIGRP utilise un **délai cumulatif** : la somme des délais de tous les liens du chemin. Le délai est exprimé en unités de 10 microsecondes.

### Valeurs de délai par défaut (EIGRP)

|Type de lien|Bande passante|Délai (µs)|Délai EIGRP|
|---|---|---|---|
|Série lente|< 1 Mbps|20 000|2000|
|Série T1|1.544 Mbps|20 000|2000|
|Ethernet|10 Mbps|1 000|100|
|Fast Ethernet|100 Mbps|100|10|
|Gigabit Ethernet|1 Gbps|10|1|

### Configuration du délai

```bash
# Voir le délai configuré
Router# show interface gigabitEthernet 0/0
  MTU 1500 bytes, BW 1000000 Kbit/sec, DLY 10 usec, ...

# Modifier le délai (affecte EIGRP)
Router(config)# interface gigabitEthernet 0/0
Router(config-if)# delay 20  # en dizaines de microsecondes (200 µs)

# Vérifier l'impact sur EIGRP
Router# show ip eigrp topology 192.168.1.0/24
  (feasible distance/advertised distance)
  via 10.0.0.2 (256256/256000), GigabitEthernet0/0
```

> [!warning] Différence avec la latence réelle Le délai configuré sur une interface est une valeur **administrative** utilisée pour les calculs de métrique. Il ne reflète pas nécessairement la latence réelle mesurée (ping).

### Avantages

✅ **Pertinent pour les applications temps réel** : VoIP, vidéo, gaming ✅ **Différencie les technologies** : Fibre vs satellite vs liaison terrestre ✅ **Complémentaire** : Combine bien avec la bande passante (utilisé par EIGRP) ✅ **Prévisible** : Relativement stable dans le temps

### Inconvénients

❌ **Configuration manuelle** : Les valeurs par défaut ne sont pas toujours précises ❌ **Ne reflète pas la gigue** : Variations de latence non prises en compte ❌ **Statique** : Ne s'adapte pas à la congestion ❌ **Complexe à mesurer** : La latence réelle varie selon les conditions

> [!example] Comparaison de chemins
> 
> ```
> Chemin 1 : Fibre terrestre
>   Interface 1 : Délai = 10 µs
>   Interface 2 : Délai = 10 µs
>   Délai total = 20 µs
> 
> Chemin 2 : Liaison satellite
>   Interface 1 : Délai = 250 000 µs (250 ms)
>   Délai total = 250 000 µs
> 
> EIGRP préférera le Chemin 1 (délai plus faible)
> même si le satellite a plus de bande passante
> ```

> [!tip] Optimisation du délai
> 
> - Pour les applications sensibles à la latence, ajustez manuellement le délai pour refléter la réalité
> - Utilisez des mesures réelles (ping, traceroute) pour calibrer vos valeurs
> - Considérez le délai dans votre conception réseau : évitez les sauts multiples pour les flux temps réel

---

## 🛡️ Fiabilité

### Définition

La **fiabilité** (reliability) mesure la stabilité et le taux d'erreur d'un lien réseau. Elle représente la probabilité qu'un paquet soit transmis avec succès sans erreur ni perte.

### Protocoles utilisant la fiabilité

- **EIGRP** : Peut l'utiliser comme composante de sa métrique (désactivé par défaut)
- **IGRP** (obsolète) : Utilisait la fiabilité dans ses calculs

### Calcul de la fiabilité

La fiabilité est exprimée sous forme d'une fraction où :

- **255/255** = 100% fiable (meilleur)
- **1/255** = très peu fiable (pire)

```
Fiabilité = (Paquets transmis avec succès / Total paquets envoyés) × 255
```

### Facteurs affectant la fiabilité

- **Erreurs CRC** : Paquets corrompus détectés par le checksum
- **Pertes de paquets** : Collisions, congestion, défaillances
- **Interférences** : Particulièrement sur les liens sans fil
- **Qualité du média** : Câbles défectueux, connecteurs oxydés
- **Saturation** : Buffers pleins causant des drops

### Visualisation de la fiabilité

```bash
# Voir la fiabilité d'une interface
Router# show interface gigabitEthernet 0/0
  MTU 1500 bytes, BW 1000000 Kbit/sec, DLY 10 usec,
     reliability 255/255, txload 1/255, rxload 1/255

# Statistiques d'erreurs
Router# show interface gigabitEthernet 0/0
  0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored
  0 output errors, 0 collisions, 0 interface resets
```

> [!info] Calcul automatique La fiabilité est calculée automatiquement par le routeur en fonction des statistiques d'erreurs observées sur une période de 5 minutes. Elle se met à jour dynamiquement.

### Impact sur EIGRP

Par défaut, EIGRP **n'utilise pas** la fiabilité dans son calcul de métrique. Pour l'activer :

```bash
Router(config)# router eigrp 100
Router(config-router)# metric weights 0 1 0 1 0 0
# Format: K1(BP) K2(Load) K3(Delay) K4(Reliability) K5(MTU)
```

> [!warning] Utilisation déconseillée L'utilisation de la fiabilité dans les métriques est généralement **déconseillée** car :
> 
> - Elle peut causer de l'instabilité (flapping de routes)
> - Les valeurs changent fréquemment
> - Elle peut déclencher des reconvergences inutiles

### Avantages

✅ **Détecte les liens problématiques** : Identifie les interfaces à problèmes ✅ **Dynamique** : S'adapte aux conditions réelles du réseau ✅ **Monitoring** : Bon indicateur pour la supervision ✅ **Prédictif** : Peut anticiper les défaillances

### Inconvénients

❌ **Instabilité** : Variations fréquentes perturbent le routage ❌ **Réactif** : Détecte les problèmes après coup, pas en prévention ❌ **Complexe** : Difficile à interpréter sans contexte ❌ **Overhead** : Calculs supplémentaires et convergences

> [!example] Scénario de fiabilité
> 
> ```
> Interface GigabitEthernet0/0 :
> - 1 000 000 paquets envoyés
> - 950 000 paquets reçus sans erreur
> - 50 000 paquets avec erreurs CRC
> 
> Fiabilité = (950 000 / 1 000 000) × 255 = 242/255
> 
> Cette interface commence à montrer des signes de dégradation
> et pourrait nécessiter un diagnostic matériel.
> ```

> [!tip] Utilisation pratique
> 
> - Utilisez la fiabilité comme **métrique de monitoring**, pas de routage
> - Surveillez les interfaces avec une fiabilité < 240/255
> - Configurez des alertes SNMP pour les chutes de fiabilité
> - Gardez la fiabilité désactivée dans les calculs de métrique EIGRP

---

## 📊 Charge

### Définition

La **charge** (load) mesure l'utilisation actuelle d'un lien réseau par rapport à sa capacité maximale. Elle indique le niveau de congestion d'une interface et est exprimée sous forme de fraction.

### Protocoles utilisant la charge

- **EIGRP** : Peut l'utiliser comme composante de sa métrique (désactivé par défaut)
- **IGRP** (obsolète) : Utilisait la charge dans ses calculs

### Représentation de la charge

La charge est exprimée sur une échelle de **1/255 à 255/255** :

- **1/255** = Lien totalement inutilisé (0,4% d'utilisation)
- **128/255** = Lien utilisé à 50%
- **255/255** = Lien saturé à 100%

```
Charge = (Trafic actuel / Capacité maximale) × 255
```

### Monitoring de la charge

```bash
# Voir la charge d'une interface
Router# show interface gigabitEthernet 0/0
  MTU 1500 bytes, BW 1000000 Kbit/sec, DLY 10 usec,
     reliability 255/255, txload 84/255, rxload 45/255
  
  txload = Charge en transmission (sortie) = 33%
  rxload = Charge en réception (entrée) = 18%
```

> [!info] Calcul dynamique La charge est calculée en temps réel sur une **période glissante de 5 minutes**. C'est une moyenne exponentielle pondérée qui privilégie les valeurs récentes.

### Impact sur EIGRP

Par défaut, EIGRP **n'utilise pas** la charge dans sa métrique. Pour l'activer :

```bash
Router(config)# router eigrp 100
Router(config-router)# metric weights 0 1 1 1 0 0
# K2=1 active la prise en compte de la charge
```

### Exemple de calcul

```
Interface GigabitEthernet (1 Gbps de capacité) :

Trafic moyen sur 5 minutes : 350 Mbps

Charge = (350 / 1000) × 255 = 89/255 ≈ 35%

Le routeur affichera : txload 89/255
```

### Seuils de charge typiques

|Charge|Pourcentage|État|Action recommandée|
|---|---|---|---|
|< 50/255|< 20%|Optimal|Aucune|
|50-127/255|20-50%|Normal|Surveillance|
|128-191/255|50-75%|Élevé|Planifier upgrade|
|192-229/255|75-90%|Critique|Upgrade urgent|
|> 230/255|> 90%|Saturé|Intervention immédiate|

> [!warning] Risques de la charge dynamique Utiliser la charge dans les métriques de routage peut causer :
> 
> - **Route flapping** : Changements fréquents de route
> - **Oscillations** : Routes qui basculent en permanence
> - **Instabilité** : Convergence difficile
> - **Effet domino** : Migration de trafic créant une surcharge ailleurs

### Avantages

✅ **Détection de congestion** : Identifie les goulots d'étranglement ✅ **Temps réel** : Reflète l'état actuel du réseau ✅ **Load balancing potentiel** : Pourrait répartir la charge (théoriquement) ✅ **Diagnostic** : Aide à identifier les liens surchargés

### Inconvénients

❌ **Instabilité majeure** : Cause des problèmes de convergence ❌ **Effet rebond** : Le trafic migre vers un autre lien qui se sature à son tour ❌ **Pas de prédiction** : Ne prévoit pas les pointes futures ❌ **Calcul coûteux** : Overhead CPU pour recalculs fréquents

> [!example] Scénario problématique
> 
> ```
> Chemin A : 70% utilisé → Métrique augmente
> Chemin B : 30% utilisé → Métrique plus basse
> 
> Routeur bascule le trafic vers Chemin B
> ↓
> Chemin B : 80% utilisé → Métrique augmente
> Chemin A : 20% utilisé → Métrique plus basse
> 
> Routeur rebascule vers Chemin A
> ↓
> Boucle infinie d'oscillations !
> ```

> [!tip] Recommandations
> 
> - **N'activez JAMAIS la charge dans les métriques** pour le routage
> - Utilisez la charge uniquement pour le **monitoring et l'alerte**
> - Préférez le load balancing statique (ECMP) si disponible
> - Configurez des seuils d'alerte (ex: txload > 200/255)
> - Planifiez des upgrades de capacité basés sur les tendances

### Commandes de monitoring

```bash
# Surveiller la charge en continu
Router# show interface | include load

# Historique de la charge avec SNMP
Router(config)# snmp-server enable traps cpu threshold

# Statistiques détaillées
Router# show interfaces stats
```

---

## 🧮 Coût composite

### Définition

Un **coût composite** (composite metric) combine plusieurs métriques simples en une seule valeur pour obtenir une évaluation plus complète de la qualité d'un chemin. C'est l'approche la plus sophistiquée du routage dynamique.

### Protocoles utilisant un coût composite

- **EIGRP** : Métrique composite principale
- **IGRP** (obsolète) : Précurseur d'EIGRP avec métrique similaire

### Formule de la métrique EIGRP

EIGRP utilise une formule complexe qui combine plusieurs facteurs :

```
Métrique EIGRP = 256 × [(K1 × BP) + (K2 × BP)/(256 - Load) + (K3 × Delay) + (K4 × K5)/(Reliability + K5)]

Où :
- BP = Bande passante (valeur calculée)
- Load = Charge (0-255)
- Delay = Délai cumulé
- Reliability = Fiabilité (0-255)
- K1, K2, K3, K4, K5 = Constantes configurables
```

> [!info] Valeurs par défaut des K Par défaut, EIGRP utilise :
> 
> - **K1 = 1** (Bande passante : activée)
> - **K2 = 0** (Charge : désactivée)
> - **K3 = 1** (Délai : activée)
> - **K4 = 0** (Fiabilité : désactivée)
> - **K5 = 0** (MTU : non utilisé)

### Formule simplifiée (par défaut)

Avec les K par défaut, la formule devient :

```
Métrique EIGRP = 256 × [(Bande passante) + (Délai)]

Où :
- Bande passante = 10^7 / BP_min (BP_min en Kbps)
- Délai = Somme des délais / 10 (en unités de 10 µs)
```

### Exemple de calcul détaillé

```
Topologie :
RouterA --(FastEthernet)--> RouterB --(GigabitEthernet)--> RouterC

Interface FastEthernet :
- Bande passante : 100 000 Kbps
- Délai : 100 µs (10 unités)

Interface GigabitEthernet :
- Bande passante : 1 000 000 Kbps
- Délai : 10 µs (1 unité)

Calcul :
1. BP_min = min(100000, 1000000) = 100 000 Kbps
   Composante BP = 10^7 / 100000 = 100

2. Délai total = 10 + 1 = 11 unités
   Composante Delay = 11

3. Métrique = 256 × (100 + 11) = 256 × 111 = 28 416
```

### Configuration des K-values

```bash
# Voir les K-values actuelles
Router# show ip protocols
Routing Protocol is "eigrp 100"
  EIGRP metric weight K1=1, K2=0, K3=1, K4=0, K5=0

# Modifier les K-values (à éviter !)
Router(config)# router eigrp 100
Router(config-router)# metric weights 0 1 0 1 0 0
# Format: tos K1 K2 K3 K4 K5
# tos = toujours 0 (non utilisé)

# Vérifier la métrique d'une route
Router# show ip eigrp topology 192.168.1.0/24
  P 192.168.1.0/24, 1 successors, FD is 28416
        via 10.0.0.2 (28416/28160), GigabitEthernet0/0
```

> [!warning] Compatibilité des K-values **CRITIQUE** : Tous les routeurs EIGRP dans un AS (Autonomous System) **doivent avoir les mêmes K-values**. Si les K-values diffèrent, les routeurs ne formeront pas de voisinage EIGRP !
> 
> Erreur typique :
> 
> ```
> %DUAL-5-NBRCHANGE: EIGRP-IPv4 100: Neighbor 10.0.0.2 (GigabitEthernet0/0)
> is down: K-value mismatch
> ```

### Variantes de métrique EIGRP

#### Métrique Wide (EIGRP Named Mode)

Les réseaux modernes ont des liens > 1 Gbps. La métrique classique EIGRP sature. EIGRP Named Mode introduit une métrique étendue :

```
Métrique Wide = 65536 × [(K1 × BP) + (K3 × Delay)]

- Multiplicateur : 65536 au lieu de 256
- Permet de gérer des liens jusqu'à 4.2 Tbps
- Rétrocompatible via conversion automatique
```

```bash
# Configuration EIGRP Named Mode
Router(config)# router eigrp CORE
Router(config-router)# address-family ipv4 unicast autonomous-system 100
Router(config-router-af)# network 10.0.0.0
Router(config-router-af)# topology base
Router(config-router-af-topology)# metric weights 0 1 0 1 0 0 0
# 7 paramètres au lieu de 6 en mode classique
```

### Composantes en détail

|Composante|Poids par défaut|Usage typique|Recommandation|
|---|---|---|---|
|Bande passante (K1)|1|Toujours actif|✅ Garder actif|
|Charge (K2)|0|Désactivé|❌ Ne jamais activer|
|Délai (K3)|1|Toujours actif|✅ Garder actif|
|Fiabilité (K4)|0|Désactivé|⚠️ Activer avec prudence|
|MTU (K5)|0|Non utilisé|❌ Ne jamais activer|

### Avantages du coût composite

✅ **Vision holistique** : Prend en compte plusieurs aspects du réseau ✅ **Flexibilité** : Peut être ajusté selon les besoins spécifiques ✅ **Précision** : Évaluation plus réaliste qu'une métrique simple ✅ **Adaptation** : Peut intégrer des critères dynamiques (si activés) ✅ **Échelle** : Métrique Wide permet de gérer les réseaux très rapides

### Inconvénients du coût composite

❌ **Complexité** : Difficile à comprendre et à debugger ❌ **Configuration** : Nécessite une expertise pour optimiser ❌ **Compatibilité** : K-values doivent être identiques partout ❌ **Overhead** : Calculs plus lourds que les métriques simples ❌ **Instabilité potentielle** : Si métriques dynamiques activées

> [!example] Comparaison de chemins avec EIGRP
> 
> ```
> Réseau source : 10.0.0.0/24
> Destination : 192.168.50.0/24
> 
> Chemin 1 : 
>   - Interface 1 : FastEthernet (100 Mbps, 100 µs)
>   - Interface 2 : FastEthernet (100 Mbps, 100 µs)
>   BP_min = 100 000 Kbps → BP = 100
>   Delay = 10 + 10 = 20
>   Métrique = 256 × (100 + 20) = 30 720
> 
> Chemin 2 :
>   - Interface 1 : GigabitEthernet (1 Gbps, 10 µs)
>   BP_min = 1 000 000 Kbps → BP = 10
>   Delay = 1
>   Métrique = 256 × (10 + 1) = 2 816
> 
> EIGRP choisira le Chemin 2 (métrique plus faible)
> Même avec 1 seul saut mais un lien rapide !
> ```

### Tuning de la métrique EIGRP

```bash
# Scénario : Forcer un chemin spécifique

# Option 1 : Modifier la bande passante (recommandé)
Router(config)# interface serial 0/0
Router(config-if)# bandwidth 256  # Réduit artificiellement à 256 Kbps
# Augmente la métrique pour rendre ce chemin moins attractif

# Option 2 : Modifier le délai (recommandé)
Router(config-if)# delay 500  # Augmente à 5000 µs
# Augmente la métrique sans affecter d'autres protocoles

# Option 3 : Modifier les K-values (déconseillé)
Router(config)# router eigrp 100
Router(config-router)# metric weights 0 2 0 1 0 0
# Double l'importance de la bande passante
# ATTENTION : À faire sur TOUS les routeurs EIGRP !
```

> [!tip] Bonnes pratiques pour le coût composite
> 
> - Gardez les **K-values par défaut** (K1=1, K3=1, autres=0) sauf besoin très spécifique
> - N'activez **JAMAIS K2** (charge) en production → instabilité garantie
> - Utilisez la modification de **delay** pour influencer le routage (pas la bande passante)
> - Documentez toute modification de K-values dans votre documentation réseau
> - Utilisez EIGRP Named Mode pour les réseaux modernes (> 1 Gbps)
> - Vérifiez la cohérence des K-values avec `show ip protocols`

### Troubleshooting de la métrique composite

```bash
# Vérifier la métrique d'une route spécifique
Router# show ip eigrp topology 192.168.1.0/24
EIGRP-IPv4 Topology Entry for AS(100)/ID(1.1.1.1) for 192.168.1.0/24
  State is Passive, Query origin flag is 1, 1 Successor(s), FD is 3072
  Descriptor Blocks:
  10.0.0.2 (GigabitEthernet0/0), from 10.0.0.2, Send flag is 0x0
      Composite metric is (3072/2816), route is Internal
      Vector metric:
        Minimum bandwidth is 1000000 Kbit
        Total delay is 20000000 picoseconds
        Reliability is 255/255
        Load is 1/255
        Minimum MTU is 1500
        Hop count is 1
        Originating router is 2.2.2.2

# Débugger les calculs de métrique
Router# debug eigrp packets
Router# debug eigrp fsm

# Voir toutes les routes EIGRP avec métriques
Router# show ip route eigrp
D    192.168.1.0/24 [90/3072] via 10.0.0.2, 00:05:32, GigabitEthernet0/0
     [AD/Métrique]

# Comparer plusieurs chemins
Router# show ip eigrp topology all-links
```

> [!warning] Erreurs courantes **Erreur 1** : Modifier la bande passante sans comprendre l'impact
> 
> ```bash
> # ❌ MAUVAIS : Réduit artificiellement la BP pour tous les protocoles
> interface gigabitEthernet 0/0
>  bandwidth 100000
> 
> # ✅ BON : Utiliser le délai pour influencer EIGRP uniquement
> interface gigabitEthernet 0/0
>  delay 50
> ```
> 
> **Erreur 2** : K-values différentes entre routeurs
> 
> ```
> RouterA : K1=1, K2=0, K3=1, K4=0, K5=0
> RouterB : K1=1, K2=1, K3=1, K4=0, K5=0
> 
> Résultat : Pas de voisinage EIGRP formé !
> ```

### Impact sur la convergence

Le coût composite affecte la vitesse de convergence :

```
Métrique simple (RIP - hop count) :
- Calcul instantané
- Convergence rapide
- Mais choix potentiellement sous-optimal

Métrique composite (EIGRP) :
- Calcul plus complexe (quelques millisecondes)
- Convergence légèrement plus lente
- Mais choix de route optimal

Trade-off : Précision vs Rapidité
```

---

## 📋 Comparaison des métriques

### Tableau comparatif général

|Métrique|Protocoles|Complexité|Statique/Dynamique|Pertinence moderne|Usage recommandé|
|---|---|---|---|---|---|
|**Hop count**|RIP|⭐ Très simple|Statique|⚠️ Limité|Petits réseaux homogènes|
|**Bande passante**|OSPF, IS-IS|⭐⭐ Simple|Statique|✅ Excellent|Tous types de réseaux|
|**Délai**|EIGRP (composante)|⭐⭐ Moyen|Statique|✅ Bon|Réseaux temps réel|
|**Fiabilité**|EIGRP (optionnel)|⭐⭐⭐ Complexe|Dynamique|❌ Déconseillé|Monitoring uniquement|
|**Charge**|EIGRP (optionnel)|⭐⭐⭐ Complexe|Dynamique|❌ Déconseillé|Monitoring uniquement|
|**Coût composite**|EIGRP|⭐⭐⭐⭐ Très complexe|Configurable|✅ Excellent|Réseaux enterprise|

### Comparaison par cas d'usage

#### 🏢 Réseau d'entreprise moderne

**Recommandation : OSPF (bande passante) ou EIGRP (composite)**

```
Critères prioritaires :
✅ Différenciation des débits (Fast Ethernet vs 10G)
✅ Stabilité et prévisibilité
✅ Scalabilité
✅ Support des technologies modernes

Métrique idéale : Bande passante (OSPF) ou Composite (EIGRP)
Configuration : Augmenter la référence OSPF à 10 Gbps minimum
```

#### 🌐 Réseau avec liens satellites/WAN

**Recommandation : EIGRP avec délai optimisé**

```
Critères prioritaires :
✅ Prise en compte de la latence
✅ Éviter les chemins satellites quand alternative terrestre existe
✅ Différenciation fibre vs satellite

Métrique idéale : Composite EIGRP (BP + Délai)
Configuration : Ajuster manuellement le délai sur les liens satellites
```

#### 🏠 Petit réseau domestique/SOHO

**Recommandation : RIP ou routage statique**

```
Critères prioritaires :
✅ Simplicité de configuration
✅ Faible overhead
✅ Pas de besoins avancés

Métrique idéale : Hop count (RIP) ou pas de métrique (statique)
Configuration : Configuration par défaut suffisante
```

#### 🎮 Réseau gaming/temps réel

**Recommandation : EIGRP avec focus sur le délai**

```
Critères prioritaires :
✅ Minimiser la latence
✅ Stabilité des routes
✅ Éviter les chemins longs

Métrique idéale : Composite EIGRP avec K3 (délai) augmenté
Configuration : metric weights 0 1 0 2 0 0
```

### Matrice de décision

```
Question 1 : Protocole déjà en place ?
├─ OUI → Utiliser la métrique native du protocole
└─ NON → Passer à Question 2

Question 2 : Taille du réseau ?
├─ < 10 routeurs → RIP (hop count) acceptable
├─ 10-100 routeurs → OSPF (bande passante) recommandé
└─ > 100 routeurs → OSPF ou EIGRP selon architecture

Question 3 : Hétérogénéité des liens ?
├─ Liens homogènes → Hop count ou BP suffisant
└─ Liens variés → Métrique composite (EIGRP)

Question 4 : Exigences latence ?
├─ Critique (VoIP, gaming) → EIGRP avec délai
└─ Standard → OSPF suffit

Question 5 : Environnement Cisco pur ?
├─ OUI → EIGRP (propriétaire mais puissant)
└─ NON → OSPF (standard ouvert)
```

### Impact sur les performances

|Métrique|Temps de calcul|Overhead CPU|Mémoire utilisée|Convergence|
|---|---|---|---|---|
|Hop count|< 1 ms|Minimal|Très faible|Rapide (30-60s)|
|Bande passante|< 5 ms|Faible|Faible|Moyenne (5-10s)|
|Composite (2 facteurs)|< 10 ms|Moyen|Moyenne|Rapide (1-5s)|
|Composite (4+ facteurs)|< 50 ms|Élevé|Élevée|Variable|

> [!tip] Règle d'or **"Keep it simple"** : Utilisez la métrique la plus simple qui répond à vos besoins. Une métrique complexe n'est pas toujours meilleure si vos besoins sont basiques.

### Scénarios de migration

#### Migration RIP → OSPF

```bash
# Étape 1 : Activer OSPF en parallèle (distance administrative supérieure)
Router(config)# router ospf 1
Router(config-router)# distance 125  # Temporairement > 120 (RIP)
Router(config-router)# network 10.0.0.0 0.255.255.255 area 0

# Étape 2 : Vérifier que les routes OSPF sont apprises
Router# show ip route ospf

# Étape 3 : Restaurer la distance OSPF normale (110)
Router(config)# router ospf 1
Router(config-router)# distance 110

# Étape 4 : Routes OSPF prennent le dessus (110 < 120)
# OSPF devient actif, RIP en backup

# Étape 5 : Désactiver RIP après validation
Router(config)# no router rip
```

#### Migration métrique classique → Wide (EIGRP)

```bash
# Étape 1 : Activer EIGRP Named Mode sur un routeur pilote
Router(config)# router eigrp CORE
Router(config-router)# address-family ipv4 unicast autonomous-system 100

# Étape 2 : Conversion automatique entre classique et wide
# Les deux modes coexistent pendant la migration

# Étape 3 : Migrer progressivement tous les routeurs
# Pas de perte de service

# Étape 4 : Vérifier les métriques
Router# show eigrp address-family ipv4 topology
```

### Recommandations finales

> [!tip] Meilleures pratiques globales
> 
> **Pour la production** :
> 
> - ✅ Utilisez la **bande passante** (OSPF) pour 90% des cas
> - ✅ Gardez les **configurations par défaut** tant que possible
> - ✅ Documentez toute modification de métrique
> - ✅ Testez les changements en lab avant production
> - ✅ Surveillez les métriques comme indicateurs de santé
> 
> **À éviter** :
> 
> - ❌ N'activez jamais la **charge** dans les calculs de routage
> - ❌ N'utilisez pas la **fiabilité** comme métrique de routage
> - ❌ Ne modifiez pas les **K-values** sans raison solide
> - ❌ N'utilisez pas RIP pour les réseaux > 15 routeurs
> - ❌ Ne changez pas de protocole sans plan de migration

### Outils de vérification

```bash
# Comparer les métriques de tous les protocoles
Router# show ip route | include via
  D    192.168.1.0/24 [90/3072] via 10.0.0.2
  O    192.168.2.0/24 [110/20] via 10.0.0.3
  R    192.168.3.0/24 [120/2] via 10.0.0.4

# Analyser les décisions de routage
Router# show ip route 192.168.1.0
Routing entry for 192.168.1.0/24
  Known via "eigrp 100", distance 90, metric 3072
  
# Debugging des calculs
Router# debug ip routing
Router# debug eigrp fsm
Router# debug ip ospf spf

# Monitoring des changements
Router# show ip route summary
Router# show ip protocols
```

---

## 🎯 Synthèse et points clés

### Les 3 métriques essentielles à maîtriser

1. **Hop count** (RIP)
    
    - La plus simple : compte les routeurs
    - Limitée mais facile à comprendre
    - Utile pour petits réseaux homogènes
2. **Bande passante** (OSPF)
    
    - La plus utilisée en production
    - Reflète la capacité des liens
    - Standard de facto pour les réseaux modernes
3. **Coût composite** (EIGRP)
    
    - La plus sophistiquée : combine BP + délai
    - Offre le meilleur compromis performance/flexibilité
    - Idéale pour les environnements complexes

### Règles d'or à retenir

> [!warning] Règles critiques
> 
> 1. **Plus la métrique est BASSE, meilleur est le chemin**
> 2. Les métriques ne sont **comparables qu'au sein d'un même protocole**
> 3. La **distance administrative** départage les protocoles, pas les métriques
> 4. Les métriques **dynamiques** (charge, fiabilité) causent de l'instabilité
> 5. Toujours **tester** les changements de métrique en environnement de lab

### Aide-mémoire visuel

```
📊 MÉTRIQUES DE ROUTAGE - GUIDE RAPIDE

Simple ←─────────────────────────────────────→ Complexe
Hop     Bande passante     Délai     Composite

Statique ←───────────────────────────────────→ Dynamique
BP/Délai              Fiabilité/Charge

Recommandé ←─────────────────────────────────→ Déconseillé
BP/Composite          Fiabilité/Charge

Production ←─────────────────────────────────→ Lab/Test
OSPF/EIGRP            RIP/métriques dynamiques
```

### Checklist de configuration

- [ ] Protocole de routage choisi selon la taille du réseau
- [ ] Métriques par défaut comprises et documentées
- [ ] Bande passante de référence ajustée si nécessaire (OSPF)
- [ ] K-values identiques sur tous les routeurs (EIGRP)
- [ ] Métriques dynamiques désactivées (charge, fiabilité)
- [ ] Tests de convergence effectués
- [ ] Monitoring des métriques configuré
- [ ] Documentation à jour avec les modifications
- [ ] Plan de rollback préparé

> [!success] Vous maîtrisez maintenant
> 
> - ✅ Les 6 types de métriques de routage
> - ✅ Leurs avantages et limitations
> - ✅ Comment les configurer et les ajuster
> - ✅ Quand utiliser chaque métrique
> - ✅ Les pièges à éviter
> - ✅ Les bonnes pratiques de production
> 
> Vous êtes prêt à concevoir et optimiser le routage dynamique de vos réseaux ! 🚀

---

_Cours préparé pour Obsidian - Partie : Protocoles de routage dynamique - Section : Métriques de routage_