

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

## 🎯 Introduction au fonctionnement de RIP {#introduction}

RIP utilise un mécanisme de **vecteur de distance** où chaque routeur partage sa vision complète du réseau avec ses voisins directs. Le protocole repose sur des échanges réguliers d'informations et sur plusieurs mécanismes pour éviter les boucles de routage.

> [!info] Principe fondamental Chaque routeur RIP diffuse l'intégralité de sa table de routage à ses voisins toutes les 30 secondes, permettant une convergence progressive du réseau.

---

## 🧮 Algorithme Bellman-Ford {#algorithme-bellman-ford}

### Principe de base

L'algorithme **Bellman-Ford** est au cœur du fonctionnement de RIP. C'est un algorithme de **vecteur de distance** qui calcule le meilleur chemin vers chaque destination.

> [!info] Définition L'algorithme Bellman-Ford permet de trouver le chemin le plus court entre un nœud source et tous les autres nœuds d'un graphe, même en présence de poids négatifs (bien que non applicable en routage).

### Équation de Bellman-Ford

```
D(x,y) = min { c(x,v) + D(v,y) }
```

Où :

- **D(x,y)** = distance (métrique) du routeur X vers la destination Y
- **c(x,v)** = coût de la liaison directe entre X et son voisin V
- **D(v,y)** = distance du voisin V vers la destination Y

### Mécanisme de calcul

1. **Initialisation** : Chaque routeur connaît uniquement ses réseaux directement connectés (métrique = 0 ou 1)
2. **Réception** : Le routeur reçoit les tables de routage de ses voisins
3. **Calcul** : Pour chaque route reçue, il ajoute le coût de sa liaison avec le voisin
4. **Comparaison** : Si cette nouvelle métrique est meilleure, la route est mise à jour
5. **Propagation** : La nouvelle table est diffusée aux voisins

> [!example] Exemple de calcul **Routeur A** reçoit de son voisin **B** :
> 
> - Réseau 192.168.3.0/24, métrique = 2
> 
> **Calcul :**
> 
> - Coût A → B = 1 (liaison directe)
> - Coût total A → 192.168.3.0/24 = 1 + 2 = 3
> 
> Si A n'avait pas de route vers ce réseau ou si sa route actuelle a une métrique > 3, cette nouvelle route est adoptée.

### Caractéristiques importantes

|Aspect|Description|
|---|---|
|**Convergence**|Progressive, peut prendre plusieurs cycles|
|**Complexité**|O(n×m) où n = nombre de nœuds, m = nombre de liaisons|
|**Métrique**|Compte de sauts uniquement (hop count)|
|**Limite**|Maximum 15 sauts (16 = infini/inaccessible)|

> [!warning] Limitation fondamentale RIP utilise uniquement le **nombre de sauts** comme métrique. Un lien à 10 Mbps et un lien à 1 Gbps ont le même coût s'ils représentent un saut !

---

## 📤 Échange de tables de routage complètes {#échange-de-tables}

### Principe d'échange

Contrairement aux protocoles à état de liens (OSPF, IS-IS mentionnés ailleurs), RIP envoie **l'intégralité de sa table de routage** à chaque mise à jour.

> [!info] Tables complètes Chaque message RIP contient toutes les routes connues par le routeur (jusqu'à 25 routes par paquet UDP en RIPv2).

### Structure des échanges

**Format d'une entrée RIP :**

```
┌─────────────────────────────────────┐
│  Adresse réseau destination         │
├─────────────────────────────────────┤
│  Masque de sous-réseau (RIPv2)      │
├─────────────────────────────────────┤
│  Prochain saut (Next Hop)           │
├─────────────────────────────────────┤
│  Métrique (1 à 16)                  │
└─────────────────────────────────────┘
```

### Types de messages RIP

|Type|Description|Utilisation|
|---|---|---|
|**Request**|Demande de routes|Au démarrage d'un routeur|
|**Response**|Réponse contenant les routes|Mises à jour périodiques ou réponse à un Request|

> [!example] Exemple de table échangée
> 
> ```
> Réseau              Métrique    Prochain saut
> 10.0.1.0/24         1           -
> 10.0.2.0/24         2           192.168.1.2
> 10.0.3.0/24         3           192.168.1.2
> 172.16.0.0/16       1           -
> 192.168.5.0/24      4           192.168.1.3
> ```

### Mécanisme de diffusion

**RIPv1 :**

- Utilise le **broadcast** (255.255.255.255)
- Port UDP **520**
- Pas d'authentification

**RIPv2 :**

- Utilise le **multicast** (224.0.0.9)
- Port UDP **520**
- Support de l'authentification (MD5)
- Supporte VLSM et CIDR

> [!tip] Optimisation réseau RIPv2 utilise le multicast plutôt que le broadcast, réduisant la charge sur les équipements qui ne participent pas à RIP.

### Avantages et inconvénients

**✅ Avantages :**

- Simplicité de mise en œuvre
- Chaque routeur a une vue complète depuis ses voisins
- Facile à déboguer

**❌ Inconvénients :**

- **Bande passante** : Échange de tables complètes même si rien n'a changé
- **Scalabilité limitée** : Inefficace sur de grands réseaux
- **Convergence lente** : Nécessite plusieurs cycles

---

## ⏰ Mises à jour périodiques {#mises-à-jour-périodiques}

### Timers RIP

RIP utilise plusieurs **timers** pour gérer les mises à jour et la stabilité du réseau.

|Timer|Valeur par défaut|Fonction|
|---|---|---|
|**Update Timer**|30 secondes|Fréquence d'envoi des mises à jour complètes|
|**Invalid Timer**|180 secondes|Temps avant de marquer une route comme invalide|
|**Hold-down Timer**|180 secondes|Temps d'attente avant d'accepter une nouvelle route|
|**Flush Timer**|240 secondes|Temps avant de supprimer une route de la table|

### Cycle de mise à jour

```
Temps 0s    : Routeur A envoie sa table complète
Temps 30s   : Routeur A envoie à nouveau sa table complète
Temps 60s   : Routeur A envoie à nouveau sa table complète
...         : Cycle continu toutes les 30 secondes
```

> [!info] Pourquoi 30 secondes ? Ce délai est un compromis entre :
> 
> - **Réactivité** : Détection relativement rapide des changements
> - **Charge réseau** : Éviter une surcharge due à des mises à jour trop fréquentes

### Mécanisme de validation des routes

**1. Route active (normale) :**

- Le routeur reçoit des mises à jour régulières
- La route est utilisable et propagée

**2. Route invalide (après 180s sans mise à jour) :**

- La métrique passe à **16** (inaccessible)
- La route est marquée comme "possibly down"
- Elle reste dans la table mais n'est pas utilisée

**3. Route supprimée (après 240s) :**

- La route est définitivement retirée de la table
- Elle n'est plus propagée

> [!example] Chronologie d'une panne
> 
> ```
> T = 0s     : Liaison normale, métrique = 2
> T = 30s    : Mise à jour reçue, timer remis à zéro
> T = 60s    : Mise à jour reçue, timer remis à zéro
> T = 90s    : PANNE - Plus de mise à jour
> T = 180s   : Invalid timer expire → métrique = 16
> T = 240s   : Flush timer expire → route supprimée
> ```

### Triggered Updates (mises à jour déclenchées)

En plus des mises à jour périodiques, RIP peut envoyer des **mises à jour immédiates** en cas de :

- Changement de métrique d'une route
- Nouvelle route découverte
- Route devenue inaccessible

> [!tip] Optimisation Les triggered updates accélèrent la convergence en ne pas attendre le prochain cycle de 30 secondes.

> [!warning] Problème de synchronisation Si tous les routeurs envoient leurs mises à jour exactement toutes les 30 secondes au même moment, cela peut créer des **pics de trafic**. C'est pourquoi RIP ajoute un délai aléatoire (jitter) de ±5 secondes.

---

## 🛡️ Mécanismes anti-boucles {#mécanismes-anti-boucles}

Les algorithmes à vecteur de distance comme RIP sont sujets aux **boucles de routage**. Plusieurs mécanismes sont implémentés pour les prévenir.

### 1. Split Horizon

**Principe :** Ne jamais renvoyer une route par l'interface où elle a été apprise.

> [!info] Règle fondamentale Si le routeur A a appris une route vers 10.0.1.0/24 via le routeur B, alors A ne réannoncera JAMAIS cette route à B.

**Sans Split Horizon :**

```
Routeur A → Routeur B : "Je connais 10.0.1.0/24, métrique 2"
Routeur B → Routeur A : "Je connais 10.0.1.0/24, métrique 3"
                        (Boucle potentielle !)
```

**Avec Split Horizon :**

```
Routeur A → Routeur B : "Je connais 10.0.1.0/24, métrique 2"
Routeur B → Routeur A : (ne réannonce PAS cette route)
```

> [!example] Illustration
> 
> ```
> [Réseau 10.0.1.0/24] ←→ [Routeur A] ←→ [Routeur B] ←→ [Routeur C]
> 
> A annonce à B : 10.0.1.0/24 métrique 1
> B annonce à C : 10.0.1.0/24 métrique 2
> B N'annonce PAS à A cette route (split horizon)
> C N'annonce PAS à B cette route (split horizon)
> ```

### 2. Split Horizon avec Poison Reverse

**Principe :** Renvoyer la route apprise mais avec une métrique **infinie (16)**.

C'est une variante plus agressive du Split Horizon.

**Fonctionnement :**

```
Routeur B → Routeur A : "10.0.1.0/24 métrique 16 (inaccessible)"
```

> [!info] Avantage Le Poison Reverse informe explicitement le voisin que cette route ne doit pas être utilisée en retour, accélérant la convergence.

**Comparaison :**

|Méthode|Route renvoyée ?|Métrique|
|---|---|---|
|**Split Horizon**|❌ Non|-|
|**Poison Reverse**|✅ Oui|16 (infini)|

### 3. Route Poisoning

**Principe :** Quand une route devient inaccessible, annoncer immédiatement cette route avec une métrique de **16**.

> [!warning] Propagation rapide de l'information Au lieu d'attendre que les timers expirent, le routeur qui détecte la panne diffuse immédiatement la métrique infinie à tous ses voisins.

**Processus :**

1. **Détection de panne :** Le routeur A perd la connexion à 10.0.1.0/24
2. **Empoisonnement :** A met la métrique à 16 dans sa table
3. **Triggered update :** A envoie immédiatement une mise à jour avec métrique 16
4. **Propagation :** Les voisins reçoivent et propagent cette information

> [!example] Scénario
> 
> ```
> T = 0s    : Liaison A → 10.0.1.0/24 tombe
> T = 0.5s  : A détecte la panne
> T = 1s    : A envoie "10.0.1.0/24 métrique 16" à B et C
> T = 2s    : B et C marquent la route comme inaccessible
> T = 3s    : B et C propagent "métrique 16" à leurs voisins
> ```

### 4. Hold-down Timer

**Principe :** Après avoir reçu une information indiquant qu'une route est down, ignorer toute mise à jour concernant cette route pendant un certain temps (180 secondes par défaut).

> [!info] Objectif Éviter que des informations contradictoires ou obsolètes ne provoquent des oscillations dans la table de routage.

**Fonctionnement :**

1. Le routeur reçoit une route avec métrique 16 (empoisonnée)
2. Il active le **hold-down timer** pour cette route
3. Pendant 180 secondes :
    - Il ignore les mises à jour avec une métrique **pire** que l'ancienne
    - Il accepte les mises à jour avec une métrique **meilleure** que l'ancienne
4. Après expiration, il accepte toutes les mises à jour

**États pendant hold-down :**

|Nouvelle métrique|Action|
|---|---|
|Meilleure que l'ancienne|✅ Acceptée immédiatement|
|Égale ou pire|❌ Ignorée pendant hold-down|
|Après 180s|✅ Toutes mises à jour acceptées|

> [!warning] Compromis Le hold-down timer améliore la stabilité mais **ralentit la convergence** en cas de changements légitimes. C'est un compromis entre stabilité et réactivité.

> [!example] Scénario complet
> 
> ```
> T = 0s    : Route vers 10.0.1.0/24, métrique 3
> T = 10s   : Réception "métrique 16" → Hold-down activé
> T = 30s   : Réception "métrique 5" → Ignorée (pire que 3)
> T = 60s   : Réception "métrique 2" → Acceptée (meilleure que 3)
> ```

### 5. Maximum Hop Count (Métrique infinie)

**Principe :** Limiter la métrique maximale à **15 sauts**. Une métrique de **16** signifie que la destination est inaccessible.

> [!info] Limitation des boucles Même si une boucle se forme, les paquets ne peuvent pas circuler indéfiniment car la métrique augmente à chaque saut et atteint rapidement 16.

**Pourquoi 15 ?**

- Compromis entre **scalabilité** et **convergence rapide**
- Avec 15 sauts max, un comptage jusqu'à l'infini reste gérable
- Adapté aux petits et moyens réseaux (limite de RIP)

### Synthèse des mécanismes

```
┌─────────────────────────────────────────────────────────────┐
│                    Détection de panne                        │
│                           ↓                                  │
│              ┌────────────────────────┐                      │
│              │   Route Poisoning      │                      │
│              │   (métrique → 16)      │                      │
│              └───────────┬────────────┘                      │
│                          ↓                                   │
│              ┌────────────────────────┐                      │
│              │  Triggered Update      │                      │
│              │  (envoi immédiat)      │                      │
│              └───────────┬────────────┘                      │
│                          ↓                                   │
│    ┌─────────────────────────────────────────┐              │
│    │          Réception par voisins          │              │
│    └────────────┬────────────────────────────┘              │
│                 ↓                                            │
│    ┌─────────────────────────────────────────┐              │
│    │       Hold-down Timer activé            │              │
│    │       (180s d'attente)                  │              │
│    └────────────┬────────────────────────────┘              │
│                 ↓                                            │
│    ┌─────────────────────────────────────────┐              │
│    │  Split Horizon / Poison Reverse         │              │
│    │  (pas de réannonce sur même interface)  │              │
│    └────────────┬────────────────────────────┘              │
│                 ↓                                            │
│    ┌─────────────────────────────────────────┐              │
│    │      Max Hop Count = 16 = infini        │              │
│    │      (limite les boucles infinies)      │              │
│    └─────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

> [!tip] Astuce mémorisation **PSHRM** : Poison, Split, Hold-down, Route poisoning, Max hop count Tous ces mécanismes travaillent ensemble pour assurer la stabilité du routage RIP.

---

## 🎯 Résumé des concepts clés

|Concept|Point essentiel|
|---|---|
|**Bellman-Ford**|Algorithme de vecteur de distance, calcul itératif du meilleur chemin|
|**Tables complètes**|Échange de l'intégralité de la table toutes les 30s|
|**Timers**|Update (30s), Invalid (180s), Hold-down (180s), Flush (240s)|
|**Split Horizon**|Ne pas réannoncer une route sur l'interface source|
|**Poison Reverse**|Réannoncer avec métrique 16 sur l'interface source|
|**Route Poisoning**|Annoncer métrique 16 immédiatement en cas de panne|
|**Hold-down**|Ignorer temporairement les mises à jour après un empoisonnement|
|**Max Hop**|Limite à 15 sauts, 16 = inaccessible|

> [!warning] Limitations globales de RIP
> 
> - Convergence lente (plusieurs minutes)
> - Utilisation de bande passante importante
> - Scalabilité limitée (max 15 sauts)
> - Métrique simpliste (hop count uniquement)

---