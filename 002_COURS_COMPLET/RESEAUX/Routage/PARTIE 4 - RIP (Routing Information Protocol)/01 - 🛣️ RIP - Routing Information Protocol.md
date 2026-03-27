

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

## 🎯 Introduction

RIP (Routing Information Protocol) est l'un des protocoles de routage dynamique les plus anciens et les plus simples. Il appartient à la famille des **protocoles à vecteur de distance** (distance vector) et utilise l'algorithme de Bellman-Ford pour déterminer les meilleures routes.

> [!info] Protocole à vecteur de distance Dans un protocole à vecteur de distance, chaque routeur partage sa table de routage complète avec ses voisins directs. Les routeurs ne connaissent pas la topologie complète du réseau, seulement la direction (vecteur) et la distance (métrique) pour atteindre chaque destination.

**Pourquoi utiliser RIP ?**

- Configuration simple et rapide
- Faible consommation de ressources
- Idéal pour les petits réseaux (< 15 routeurs)
- Apprentissage et tests en environnement de formation

**Quand ne PAS utiliser RIP ?**

- Réseaux de grande taille
- Environnements nécessitant une convergence rapide
- Réseaux complexes avec beaucoup de chemins redondants

---

## 📜 Historique et évolutions

### RIPv1 (1988 - RFC 1058)

La première version de RIP, définie dans la RFC 1058, présentait plusieurs limitations importantes :

|Caractéristique|Description|
|---|---|
|**Classful**|Ne supporte que les classes d'adresses (A, B, C) sans VLSM|
|**Pas de masque**|N'envoie pas le masque de sous-réseau dans les mises à jour|
|**Broadcast**|Utilise l'adresse de broadcast (255.255.255.255)|
|**Pas d'authentification**|Aucune sécurité sur les échanges de routes|
|**Métrique**|Compte de sauts uniquement (hop count)|

> [!warning] Limitation majeure de RIPv1 L'absence de masque de sous-réseau dans les mises à jour rend RIPv1 incompatible avec le VLSM (Variable Length Subnet Mask) et le CIDR, ce qui limite considérablement son utilisation dans les réseaux modernes.

### RIPv2 (1994 - RFC 2453)

RIPv2 apporte des améliorations significatives tout en maintenant la compatibilité avec RIPv1 :

|Amélioration|Avantage|
|---|---|
|**Classless**|Support du VLSM et du CIDR|
|**Masque inclus**|Envoie le masque de sous-réseau avec chaque route|
|**Multicast**|Utilise l'adresse 224.0.0.9 (moins de trafic)|
|**Authentification**|Support de l'authentification MD5 et texte clair|
|**Next-hop**|Peut spécifier un next-hop différent du routeur source|
|**Tags de route**|Permet de marquer les routes externes|

> [!tip] Version recommandée RIPv2 doit toujours être préféré à RIPv1 dans les déploiements modernes. La configuration est similaire et les avantages sont considérables.

### RIPng (2997 - RFC 2080)

RIPng (RIP next generation) est l'adaptation de RIP pour IPv6. Il conserve les mêmes principes que RIPv2 mais utilise l'adresse multicast IPv6 `FF02::9`.

---

## ⚙️ Caractéristiques principales

### Protocole à vecteur de distance

RIP fonctionne selon le principe suivant :

1. Chaque routeur connaît directement ses réseaux connectés
2. Il partage sa table de routage complète avec ses voisins
3. Les voisins ajoutent ces routes avec une métrique incrémentée
4. Le processus se répète jusqu'à la convergence du réseau

```
Routeur A ──────── Routeur B ──────── Routeur C
  |                  |                  |
Réseau 1          Réseau 2          Réseau 3

Routeur A annonce : "Réseau 1 à 0 saut"
Routeur B reçoit et annonce : "Réseau 1 à 1 saut"
Routeur C reçoit et enregistre : "Réseau 1 à 2 sauts via B"
```

### Métrique simple

La métrique RIP est basée uniquement sur le **nombre de sauts (hop count)** :

- Chaque routeur traversé = 1 saut
- Réseau directement connecté = 0 saut
- Pas de prise en compte de la bande passante ou de la latence

> [!example] Calcul de métrique
> 
> ```
> Réseau source ── R1 ── R2 ── R3 ── Réseau destination
>                   ↓     ↓     ↓
>                 1 hop  2 hops 3 hops
> ```
> 
> Le réseau de destination est à 3 sauts depuis la source.

### Mises à jour périodiques

- **Mises à jour complètes** : Envoi de la table de routage entière
- **Fréquence** : Toutes les 30 secondes par défaut
- **Mode** : RIPv1 utilise broadcast, RIPv2 utilise multicast

> [!warning] Charge réseau Les mises à jour périodiques complètes génèrent du trafic réseau constant, même si la topologie ne change pas. C'est l'une des raisons pour lesquelles RIP n'est pas adapté aux grands réseaux.

### Distance administrative

La distance administrative (AD) de RIP est **120**, ce qui la place relativement bas dans l'ordre de préférence :

|Protocole|AD|Priorité|
|---|---|---|
|Route connectée|0|Très haute|
|Route statique|1|Très haute|
|EIGRP|90|Haute|
|OSPF|110|Haute|
|**RIP**|**120**|**Moyenne**|
|Route externe|170+|Basse|

> [!info] Impact de l'AD Si RIP et OSPF apprennent la même route, c'est OSPF qui sera préféré car son AD (110) est inférieur à celui de RIP (120).

---

## 🚧 Métrique et limitation des sauts

### Le problème des 15 sauts

RIP impose une **limite stricte de 15 sauts** pour considérer une route comme valide.

**Conséquences :**

- Route avec 16 sauts ou plus = inaccessible (métrique infinie)
- Diamètre maximum du réseau = 15 routeurs
- Protection contre les boucles de routage infinies

> [!warning] Limitation critique Cette limite de 15 sauts fait de RIP un protocole inadapté pour les réseaux moyens à grands. Au-delà de 15 routeurs entre deux points, la communication est impossible avec RIP.

### Exemple de limitation

```
Internet
   |
  R1 ─ R2 ─ R3 ─ ... ─ R14 ─ R15 ─ R16 ─ Réseau distant
   ↓    ↓    ↓          ↓     ↓     ↓
  1    2    3         14    15    16 (INACCESSIBLE)
```

Le réseau derrière R16 sera marqué comme inaccessible par R1.

### Pourquoi cette limite ?

1. **Prévention des boucles** : Limite les comptes à l'infini en cas de boucle
2. **Convergence** : Accélère la détection de routes invalides
3. **Simplicité** : Facilite le débogage et la compréhension

> [!tip] Astuce de conception Si votre réseau approche la limite des 15 sauts, c'est un signal fort qu'il faut migrer vers un protocole plus moderne comme OSPF ou EIGRP.

---

## ⏱️ Temporisateurs RIP

RIP utilise quatre temporisateurs principaux pour gérer le cycle de vie des routes. La compréhension de ces temporisateurs est essentielle pour le dépannage et l'optimisation.

### 1. Update Timer (30 secondes)

**Fonction** : Intervalle entre les mises à jour périodiques

```
T=0s    T=30s   T=60s   T=90s
 |       |       |       |
 └─MAJ───└─MAJ───└─MAJ───└─MAJ...
```

- **Valeur par défaut** : 30 secondes
- **Comportement** : Chaque routeur envoie sa table complète
- **Variabilité** : Un décalage aléatoire de 0-5 secondes peut être ajouté

> [!info] Synchronisation Le décalage aléatoire évite que tous les routeurs envoient leurs mises à jour exactement au même moment, ce qui pourrait causer des congestions.

### 2. Invalid Timer (180 secondes)

**Fonction** : Temps avant qu'une route soit considérée comme invalide

- **Valeur par défaut** : 180 secondes (6 × Update Timer)
- **Déclenchement** : Commence quand une route n'est plus mise à jour
- **Action** : La route passe en état "possibly down"
- **Métrique** : Passe à 16 (infinie)

**Scénario :**

```
T=0     : Route apprise, métrique = 3
T=30    : Mise à jour reçue, timer réinitialisé
T=60    : Mise à jour reçue, timer réinitialisé
T=90    : PAS de mise à jour
T=120   : PAS de mise à jour
T=150   : PAS de mise à jour
T=180   : INVALID ! Métrique → 16
```

> [!warning] Route invalide vs route supprimée Une route invalide reste dans la table de routage mais avec une métrique de 16. Elle n'est pas encore supprimée et peut propager l'information "route inaccessible" aux voisins.

### 3. Holddown Timer (180 secondes)

**Fonction** : Période de stabilisation après invalidation d'une route

- **Valeur par défaut** : 180 secondes
- **Déclenchement** : Commence quand une route devient invalide
- **But** : Éviter les informations contradictoires pendant la convergence
- **Comportement** : Ignore les mises à jour moins bonnes pendant cette période

**Mécanisme de protection :**

```
1. Route vers 10.0.0.0/8 invalide (métrique 16)
2. Holddown timer démarre (180s)
3. Mise à jour reçue : "10.0.0.0/8 via R2, métrique 5"
   → Acceptée (meilleure que 16)
4. Mise à jour reçue : "10.0.0.0/8 via R3, métrique 8"
   → Rejetée pendant holddown (pire que route actuelle)
```

> [!tip] Prévention des boucles Le holddown timer empêche qu'une route oscillante ne cause des boucles de routage. Il force le réseau à se stabiliser avant d'accepter de nouvelles informations potentiellement erronées.

### 4. Flush Timer (240 secondes)

**Fonction** : Temps avant suppression définitive de la route

- **Valeur par défaut** : 240 secondes (4 × Update Timer)
- **Déclenchement** : Commence en même temps que l'Invalid Timer
- **Action finale** : Supprime la route de la table de routage
- **Relation** : Flush = Invalid + 60 secondes (typiquement)

**Chronologie complète :**

```
T=0     : Route active, reçoit des mises à jour
T=0-180 : Invalid Timer en cours
T=180   : Route → invalide (métrique 16), Holddown démarre
T=0-240 : Flush Timer en cours
T=240   : Route SUPPRIMÉE de la table
```

### Tableau récapitulatif des temporisateurs

|Temporisateur|Défaut|Fonction|Début|
|---|---|---|---|
|**Update**|30s|Envoi des mises à jour|Permanent|
|**Invalid**|180s|Invalidation de route|Dernière MAJ|
|**Holddown**|180s|Stabilisation réseau|Invalidation|
|**Flush**|240s|Suppression de route|Dernière MAJ|

> [!example] Exemple complet Un routeur apprend une route à t=0.
> 
> - **t=0-30-60-90** : Mises à jour régulières reçues, tout va bien
> - **t=120** : Plus de mise à jour (problème réseau)
> - **t=180** : Invalid Timer expire → route invalide (métrique 16)
> - **t=180-360** : Holddown actif, ignore les mauvaises nouvelles
> - **t=240** : Flush Timer expire → route supprimée
> 
> La route reste donc 60 secondes en état invalide avant suppression.

### Relation entre les temporisateurs

```
Dernière MAJ
     |
     v
  [UPDATE]───────────────────────────────> Mises à jour
     |                                      toutes les 30s
     |
     +──────[INVALID TIMER]──────────────> 180s
     |            |
     |            v (T=180s)
     |      Route invalide
     |      Métrique → 16
     |      [HOLDDOWN]────────────────────> 180s
     |
     +──────[FLUSH TIMER]────────────────> 240s
                  |
                  v (T=240s)
            Route supprimée
```

> [!warning] Convergence lente Avec ces temporisateurs, RIP peut prendre jusqu'à 240 secondes pour complètement réagir à une panne. C'est beaucoup trop lent pour les applications critiques. Des protocoles comme OSPF convergent en quelques secondes.

---

## 🔄 Fonctionnement détaillé

### Processus d'apprentissage des routes

1. **Initialisation**
    
    - Le routeur apprend ses réseaux directement connectés (métrique 0)
    - Il envoie immédiatement une mise à jour à ses voisins
2. **Réception de mises à jour**
    
    ```
    Mise à jour reçue de R2 :
    - Réseau : 192.168.10.0/24
    - Métrique : 2
    
    Traitement :
    - Métrique finale = 2 + 1 = 3
    - Interface = celle qui a reçu la MAJ
    - Next-hop = R2
    ```
    
3. **Comparaison et mise à jour**
    
    - Route inexistante → ajout immédiat
    - Route existante avec meilleure métrique → remplacement
    - Route existante avec métrique égale → load balancing possible
    - Route existante avec pire métrique → ignorée

### Mécanismes de prévention des boucles

RIP utilise plusieurs techniques pour éviter les boucles de routage :

#### Split Horizon

**Principe** : Ne jamais renvoyer une route par l'interface où elle a été apprise

```
R1 ─────── R2 ─────── R3
 |          |          |
N1         N2         N3

R2 apprend N1 via R1 (interface E0)
→ R2n'annonce PAS N1 à R1 sur E0
→ R2 annonce N1 à R3 sur E1
```

> [!tip] Efficacité Split Horizon empêche les boucles à 2 routeurs dans 90% des cas. C'est la première ligne de défense contre les boucles.

#### Split Horizon with Poison Reverse

**Principe** : Annoncer les routes avec métrique infinie (16) sur l'interface d'où elles viennent

```
R2 apprend N1 via R1 (interface E0)
→ R2 annonce N1 à R1 sur E0 avec métrique 16
→ R1 sait que passer par R2 pour N1 est une mauvaise idée
```

> [!info] Différence avec Split Horizon Au lieu de ne rien dire, on dit explicitement "cette route est inaccessible par moi". C'est plus verbeux mais plus sûr.

#### Route Poisoning

**Principe** : Quand une route tombe, l'annoncer immédiatement avec métrique 16

```
N1 tombe sur R1
→ R1 annonce immédiatement : N1 = métrique 16
→ Tous les voisins invalident leur route vers N1
→ Convergence plus rapide
```

#### Triggered Updates

**Principe** : Ne pas attendre les 30 secondes en cas de changement

```
Changement détecté (route down, nouvelle route, métrique changée)
→ Mise à jour IMMÉDIATE envoyée
→ Accélère la convergence
```

> [!warning] Limitations Même avec triggered updates, RIP reste lent à converger comparé à OSPF ou EIGRP en raison des temporisateurs Invalid et Holddown.

---

## ⚠️ Pièges courants

### 1. Confusion entre RIPv1 et RIPv2

**Problème** : Oublier de spécifier la version peut causer des incompatibilités

```bash
# ❌ MAUVAIS : Version par défaut (peut être v1)
router rip
 network 192.168.1.0

# ✅ BON : Toujours spécifier v2
router rip
 version 2
 network 192.168.1.0
```

### 2. Résumé automatique non désactivé

**Problème** : RIPv2 active l'auto-summary par défaut, causant des problèmes avec VLSM

```bash
# Réseau : 192.168.1.0/24 et 192.168.2.0/24
# RIP va résumer en 192.168.0.0/16 → PERTE D'INFORMATION

# ✅ Solution : Désactiver auto-summary
router rip
 version 2
 no auto-summary
 network 192.168.1.0
 network 192.168.2.0
```

> [!warning] Symptôme typique Si vous avez des sous-réseaux non contigus ou du VLSM et que le routage ne fonctionne pas, vérifiez `auto-summary` en premier.

### 3. Oubli de l'authentification

**Problème** : Laisser RIP sans authentification permet des injections de routes malveillantes

```bash
# ✅ Toujours configurer l'authentification
key chain RIP_KEYS
 key 1
  key-string SecureP@ss123

interface GigabitEthernet0/0
 ip rip authentication mode md5
 ip rip authentication key-chain RIP_KEYS
```

### 4. Passive Interface oubliée

**Problème** : RIP annonce sur des interfaces vers des utilisateurs finaux

```bash
# ❌ RIP annonce sur toutes les interfaces où "network" est configuré
router rip
 network 192.168.1.0

# ✅ Rendre passives les interfaces utilisateurs
router rip
 network 192.168.1.0
 passive-interface GigabitEthernet0/1  # Vers les utilisateurs
 passive-interface default              # Ou toutes par défaut
 no passive-interface GigabitEthernet0/0  # Sauf vers routeurs
```

### 5. Mauvaise compréhension de la commande "network"

**Problème** : La commande `network` active RIP, elle n'annonce pas le réseau

```bash
# La commande "network" fait DEUX choses :
# 1. Active RIP sur les interfaces dans ce réseau classful
# 2. Annonce les réseaux de ces interfaces

router rip
 network 10.0.0.0  # Active RIP sur TOUTES les interfaces 10.x.x.x
```

> [!info] Réseau classful RIP utilise toujours les limites de classes pour `network`, même en v2 :
> 
> - 10.1.1.0 → converti en 10.0.0.0 (classe A)
> - 172.16.5.0 → converti en 172.16.0.0 (classe B)
> - 192.168.1.0 → reste 192.168.1.0 (classe C)

### 6. Ignore les temporisateurs

**Problème** : Ne pas comprendre que RIP est LENT par conception

```bash
# RIP peut prendre jusqu'à 240 secondes pour converger
# Si vous avez besoin de convergence rapide, utilisez OSPF ou EIGRP

# ❌ Mauvais choix pour :
# - Applications temps réel
# - VoIP sans QoS robuste
# - Liens redondants critiques

# ✅ Bon choix pour :
# - Labs et apprentissage
# - Très petits réseaux stables
# - Compatibilité avec vieux équipements
```

### 7. Oubli du "no ip split-horizon" sur Frame Relay/NBMA

**Problème** : Sur les réseaux NBMA (hub-and-spoke), split-horizon bloque les mises à jour

```bash
# Sur hub Frame Relay avec plusieurs spokes
interface Serial0/0
 no ip split-horizon  # OBLIGATOIRE pour NBMA hub
```

---

## ✅ Bonnes pratiques

### 1. Configuration minimale recommandée

```bash
# Configuration RIPv2 moderne et sécurisée
router rip
 version 2                    # Toujours v2
 no auto-summary              # VLSM/CIDR
 network 10.0.0.0             # Réseaux à inclure
 network 192.168.1.0
 passive-interface default    # Sécurité par défaut
 no passive-interface Gi0/0   # Activer uniquement où nécessaire
```

### 2. Sécurisation systématique

```bash
# Authentification MD5
key chain RIP_AUTH
 key 1
  key-string MySecureKey123
  
interface GigabitEthernet0/0
 ip rip authentication mode md5
 ip rip authentication key-chain RIP_AUTH

# Filtrage avec ACL
access-list 10 permit 10.0.0.0 0.255.255.255
router rip
 distribute-list 10 in  # Accepte uniquement réseaux 10.x
```

### 3. Limitation de l'impact sur le réseau

```bash
# Réduire le trafic RIP
router rip
 passive-interface default           # Désactive partout
 no passive-interface Gi0/0          # Active seulement nécessaire
 timers basic 15 90 90 120          # Temporisateurs plus agressifs (optionnel)
```

> [!warning] Modification des timers Changer les temporisateurs RIP peut accélérer la convergence MAIS tous les routeurs du domaine RIP doivent avoir les MÊMES valeurs, sinon comportement imprévisible.

### 4. Documentation et clarté

```bash
# Utiliser des descriptions
interface GigabitEthernet0/0
 description ** Vers Routeur Core - RIP actif **
 
interface GigabitEthernet0/1
 description ** Vers LAN Utilisateurs - RIP passif **
```

### 5. Validation et monitoring

```bash
# Commandes essentielles de vérification
show ip protocols              # Configuration RIP active
show ip rip database          # Base de données RIP complète
show ip route rip             # Routes apprises par RIP uniquement
debug ip rip                  # Débogage des mises à jour (ATTENTION : verbeux)
debug ip rip events           # Événements RIP uniquement
```

### 6. Migration vers OSPF

Si votre réseau grandit, préparez la migration :

```bash
# Phase 1 : RIP et OSPF coexistent
router rip
 version 2
 network 10.0.0.0
 
router ospf 1
 network 192.168.0.0 0.0.255.255 area 0

# Phase 2 : Redistribution temporaire
router ospf 1
 redistribute rip subnets
 
router rip
 redistribute ospf 1 metric 5

# Phase 3 : Migration complète vers OSPF
no router rip  # Suppression finale de RIP
```

> [!tip] Conseil de migration Migrez progressivement, zone par zone. Ne supprimez RIP que quand OSPF est complètement stabilisé sur tout le réseau.

### 7. Utilisation appropriée

**✅ Utilisez RIP quand :**

- Réseau < 10 routeurs
- Apprentissage et labs
- Compatibilité avec équipements anciens obligatoire
- Simplicité absolument requise

**❌ N'utilisez PAS RIP quand :**

- Réseau > 15 routeurs
- Convergence rapide nécessaire
- Réseau avec redondance complexe
- Bande passante limitée (liens WAN lents)

---

## 📊 Comparaison rapide RIPv1 vs RIPv2

|Critère|RIPv1|RIPv2|
|---|---|---|
|Type|Classful|Classless|
|Masque dans MAJ|❌ Non|✅ Oui|
|VLSM/CIDR|❌ Non|✅ Oui|
|Transport|Broadcast|Multicast (224.0.0.9)|
|Authentification|❌ Non|✅ Oui (MD5/texte)|
|Tags de route|❌ Non|✅ Oui|
|Compatibilité|Ancienne|Moderne|

> [!tip] Recommandation finale **Utilisez toujours RIPv2**. RIPv1 ne devrait plus être utilisé dans aucun réseau moderne, sauf contrainte absolue d'interopérabilité avec des équipements très anciens.

---

## 🎓 Points clés à retenir

1. **RIP = Simple mais limité** : 15 sauts maximum, convergence lente
2. **Toujours utiliser RIPv2** : Support VLSM, multicast, authentification
3. **Temporisateurs critiques** : 30s update, 180s invalid, 240s flush
4. **Désactiver auto-summary** : Essentiel pour VLSM
5. **Passive-interface** : Sécurité et réduction du trafic
6. **Authentification MD5** : Protection contre injection de routes
7. **Split Horizon** : Prévention des boucles (sauf NBMA)
8. **Métrique = sauts uniquement** : Pas de bande passante prise en compte

---

_Cours créé pour Obsidian - Réseau et routage dynamique_