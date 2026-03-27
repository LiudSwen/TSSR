

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

## 🎯 Principes du découpage en sous-réseaux

### Qu'est-ce que le subnetting ?

Le **subnetting** (ou sous-réseautage) est la technique qui consiste à diviser un réseau IP en plusieurs sous-réseaux plus petits. Cette division permet une meilleure organisation, une gestion optimisée de l'espace d'adressage, et une sécurité accrue.

> [!info] Pourquoi faire du subnetting ?
> 
> - **Optimisation de l'espace d'adressage** : éviter le gaspillage d'adresses IP
> - **Segmentation du réseau** : isoler différents services ou départements
> - **Performance** : réduire les domaines de broadcast
> - **Sécurité** : limiter la propagation des attaques
> - **Routage efficace** : simplifier les tables de routage

### Rappel sur les classes d'adresses

|Classe|Plage d'adresses|Masque par défaut|Notation CIDR|Usage typique|
|---|---|---|---|---|
|A|0.0.0.0 - 127.255.255.255|255.0.0.0|/8|Très grands réseaux|
|B|128.0.0.0 - 191.255.255.255|255.255.0.0|/16|Réseaux moyens|
|C|192.0.0.0 - 223.255.255.255|255.255.255.0|/24|Petits réseaux|

> [!warning] Adresses réservées Dans chaque sous-réseau, deux adresses sont toujours réservées :
> 
> - **Adresse réseau** (première adresse) : identifie le sous-réseau
> - **Adresse de broadcast** (dernière adresse) : diffusion à tous les hôtes

### Anatomie d'une adresse IP

Une adresse IPv4 est composée de **32 bits** divisés en deux parties :

```
┌─────────────────┬──────────────────┐
│  Network ID     │    Host ID       │
└─────────────────┴──────────────────┘
      ↑                    ↑
  Identifie le      Identifie l'hôte
  sous-réseau       dans le réseau
```

Le **masque de sous-réseau** détermine la frontière entre ces deux parties.

### Le masque de sous-réseau

Le masque peut être exprimé de deux façons :

**1. Notation décimale pointée :**

```
255.255.255.0
```

**2. Notation CIDR (Classless Inter-Domain Routing) :**

```
/24  (signifie 24 bits à 1 dans le masque)
```

> [!example] Conversion masque décimal ↔ CIDR
> 
> ```
> 255.255.255.0    = /24  (24 bits à 1)
> 255.255.255.128  = /25  (25 bits à 1)
> 255.255.255.192  = /26  (26 bits à 1)
> 255.255.255.224  = /27  (27 bits à 1)
> 255.255.255.240  = /28  (28 bits à 1)
> 255.255.255.248  = /29  (29 bits à 1)
> 255.255.255.252  = /30  (30 bits à 1)
> ```

### Formules essentielles

Pour un masque donné avec **n** bits pour les hôtes :

|Élément|Formule|
|---|---|
|Nombre de sous-réseaux possibles|2^(bits empruntés)|
|Nombre d'hôtes par sous-réseau|2^n - 2|
|Incrément entre sous-réseaux|256 - valeur de l'octet significatif|

> [!tip] Astuce pour calculer rapidement Le nombre d'hôtes utilisables suit toujours la séquence :
> 
> - /30 → 2 hôtes (liens point-à-point)
> - /29 → 6 hôtes
> - /28 → 14 hôtes
> - /27 → 30 hôtes
> - /26 → 62 hôtes
> - /25 → 126 hôtes
> - /24 → 254 hôtes

---

## 🔢 Calcul des sous-réseaux (FLSM)

### Qu'est-ce que le FLSM ?

Le **FLSM** (Fixed Length Subnet Mask) est une méthode de subnetting où tous les sous-réseaux créés ont la **même taille** (même masque de sous-réseau).

> [!info] Quand utiliser FLSM ?
> 
> - Lorsque tous les départements/segments ont des besoins similaires en nombre d'hôtes
> - Pour une architecture réseau simple et homogène
> - Facilite la planification et la documentation
> - Simplifie l'administration

### Méthodologie de calcul en 7 étapes

#### Étape 1 : Identifier les besoins

Déterminer :

- Le réseau de base (exemple : 192.168.10.0/24)
- Le nombre de sous-réseaux nécessaires
- Le nombre d'hôtes par sous-réseau

#### Étape 2 : Calculer les bits à emprunter

Pour créer **N** sous-réseaux, il faut emprunter **B** bits tels que : **2^B ≥ N**

> [!example] Exemple
> 
> - Besoin de 8 sous-réseaux → 2^3 = 8 → emprunter 3 bits
> - Besoin de 15 sous-réseaux → 2^4 = 16 → emprunter 4 bits
> - Besoin de 30 sous-réseaux → 2^5 = 32 → emprunter 5 bits

#### Étape 3 : Déterminer le nouveau masque

Si le masque de départ est /24 et qu'on emprunte 3 bits :

```
Nouveau masque = /24 + 3 = /27
ou 255.255.255.224
```

#### Étape 4 : Calculer le nombre d'hôtes par sous-réseau

Avec un /27, il reste **32 - 27 = 5 bits** pour les hôtes :

```
Nombre d'hôtes = 2^5 - 2 = 32 - 2 = 30 hôtes utilisables
```

#### Étape 5 : Calculer l'incrément

L'incrément détermine l'écart entre deux sous-réseaux consécutifs.

Pour /27 (masque 255.255.255.224) :

```
Incrément = 256 - 224 = 32
```

#### Étape 6 : Lister les sous-réseaux

En partant de l'adresse de base, ajouter l'incrément successivement :

```
Sous-réseau 0 : 192.168.10.0/27
Sous-réseau 1 : 192.168.10.32/27
Sous-réseau 2 : 192.168.10.64/27
Sous-réseau 3 : 192.168.10.96/27
Sous-réseau 4 : 192.168.10.128/27
Sous-réseau 5 : 192.168.10.160/27
Sous-réseau 6 : 192.168.10.192/27
Sous-réseau 7 : 192.168.10.224/27
```

#### Étape 7 : Détailler chaque sous-réseau

Pour chaque sous-réseau, identifier :

|Élément|Calcul|Exemple (192.168.10.0/27)|
|---|---|---|
|Adresse réseau|Première adresse|192.168.10.0|
|Première adresse hôte|Réseau + 1|192.168.10.1|
|Dernière adresse hôte|Broadcast - 1|192.168.10.30|
|Adresse de broadcast|Réseau + (incrément - 1)|192.168.10.31|

### Exemple complet : Subnetting d'un réseau /24

**Contexte :** Réseau 172.16.50.0/24 à diviser en 4 sous-réseaux égaux

**1. Bits à emprunter :**

```
2^2 = 4 sous-réseaux → emprunter 2 bits
```

**2. Nouveau masque :**

```
/24 + 2 = /26
255.255.255.192
```

**3. Hôtes par sous-réseau :**

```
32 - 26 = 6 bits pour les hôtes
2^6 - 2 = 64 - 2 = 62 hôtes utilisables
```

**4. Incrément :**

```
256 - 192 = 64
```

**5. Table des sous-réseaux :**

|Sous-réseau|Adresse réseau|Première hôte|Dernière hôte|Broadcast|
|---|---|---|---|---|
|0|172.16.50.0|172.16.50.1|172.16.50.62|172.16.50.63|
|1|172.16.50.64|172.16.50.65|172.16.50.126|172.16.50.127|
|2|172.16.50.128|172.16.50.129|172.16.50.190|172.16.50.191|
|3|172.16.50.192|172.16.50.193|172.16.50.254|172.16.50.255|

> [!tip] Astuce de vérification
> 
> - Le dernier sous-réseau doit se terminer à .255 (broadcast du réseau parent)
> - La somme des hôtes de tous les sous-réseaux doit correspondre à la capacité du réseau parent
> - Broadcast(n) + 1 = Réseau(n+1)

### Tableau de référence rapide

|CIDR|Masque|Incrément|Hôtes utilisables|Nombre de sous-réseaux (depuis /24)|
|---|---|---|---|---|
|/24|255.255.255.0|256|254|1|
|/25|255.255.255.128|128|126|2|
|/26|255.255.255.192|64|62|4|
|/27|255.255.255.224|32|30|8|
|/28|255.255.255.240|16|14|16|
|/29|255.255.255.248|8|6|32|
|/30|255.255.255.252|4|2|64|

> [!warning] Pièges courants en FLSM
> 
> - **Oublier de soustraire 2** pour les adresses réseau et broadcast
> - **Confondre** le nombre de sous-réseaux avec le nombre d'hôtes
> - **Ne pas vérifier** que le dernier sous-réseau ne dépasse pas l'espace disponible
> - **Utiliser FLSM** quand les besoins en hôtes sont très différents (préférer VLSM)

---

## 🎨 VLSM (Variable Length Subnet Mask)

### Qu'est-ce que le VLSM ?

Le **VLSM** permet d'utiliser des masques de sous-réseau de **longueurs différentes** au sein d'un même réseau classful. Contrairement au FLSM, on adapte la taille de chaque sous-réseau aux besoins réels.

> [!info] Avantages du VLSM
> 
> - **Optimisation maximale** de l'espace d'adressage
> - **Réduction du gaspillage** d'adresses IP
> - **Flexibilité** pour des besoins hétérogènes
> - **Efficacité** pour les architectures complexes
> - Indispensable pour IPv4 avec la pénurie d'adresses

> [!warning] Prérequis techniques Le VLSM nécessite un protocole de routage qui supporte les informations de masque :
> 
> - RIPv2 ✅
> - EIGRP ✅
> - OSPF ✅
> - IS-IS ✅
> - RIPv1 ❌ (ne supporte pas VLSM)

### Méthodologie VLSM en 5 étapes

#### Étape 1 : Lister et trier les besoins

Identifier tous les sous-réseaux nécessaires et les **trier par ordre décroissant** du nombre d'hôtes requis.

> [!tip] Pourquoi trier par ordre décroissant ? Commencer par les plus gros besoins permet d'éviter la fragmentation et garantit que tous les sous-réseaux pourront être créés.

#### Étape 2 : Choisir le masque adapté pour chaque sous-réseau

Pour chaque besoin, sélectionner le masque qui fournit **juste assez d'hôtes** (la puissance de 2 immédiatement supérieure).

> [!example] Correspondance besoins → masque
> 
> ```
> 500 hôtes  → 2^9 = 512 - 2 = 510  → /23
> 200 hôtes  → 2^8 = 256 - 2 = 254  → /24
> 100 hôtes  → 2^7 = 128 - 2 = 126  → /25
> 50 hôtes   → 2^6 = 64 - 2 = 62   → /26
> 25 hôtes   → 2^5 = 32 - 2 = 30   → /27
> 10 hôtes   → 2^4 = 16 - 2 = 14   → /28
> 2 hôtes    → 2^2 = 4 - 2 = 2     → /30 (liens point-à-point)
> ```

#### Étape 3 : Allouer les adresses séquentiellement

Attribuer les sous-réseaux dans l'ordre, en commençant par l'adresse de base du réseau parent.

#### Étape 4 : Calculer les paramètres de chaque sous-réseau

Pour chaque allocation :

- Adresse réseau
- Plage d'hôtes utilisables
- Adresse de broadcast
- Prochaine adresse disponible

#### Étape 5 : Vérifier la cohérence

S'assurer qu'il n'y a **pas de chevauchement** entre les sous-réseaux et qu'il reste de l'espace disponible si nécessaire.

### Exemple complet de VLSM

**Contexte :** Réseau 192.168.100.0/24 à découper selon ces besoins :

- Département A : 100 hôtes
- Département B : 50 hôtes
- Département C : 25 hôtes
- Département D : 10 hôtes
- Liaison routeur 1 : 2 hôtes
- Liaison routeur 2 : 2 hôtes

**1. Tri par ordre décroissant :**

```
1. Département A : 100 hôtes
2. Département B : 50 hôtes
3. Département C : 25 hôtes
4. Département D : 10 hôtes
5. Liaison routeur 1 : 2 hôtes
6. Liaison routeur 2 : 2 hôtes
```

**2. Sélection des masques :**

|Sous-réseau|Hôtes requis|Hôtes disponibles|Masque|
|---|---|---|---|
|Département A|100|126 (2^7-2)|/25|
|Département B|50|62 (2^6-2)|/26|
|Département C|25|30 (2^5-2)|/27|
|Département D|10|14 (2^4-2)|/28|
|Liaison 1|2|2 (2^2-2)|/30|
|Liaison 2|2|2 (2^2-2)|/30|

**3. Allocation séquentielle :**

**Département A - 192.168.100.0/25**

```
Réseau :          192.168.100.0
Première hôte :   192.168.100.1
Dernière hôte :   192.168.100.126
Broadcast :       192.168.100.127
Prochaine dispo : 192.168.100.128
```

**Département B - 192.168.100.128/26**

```
Réseau :          192.168.100.128
Première hôte :   192.168.100.129
Dernière hôte :   192.168.100.190
Broadcast :       192.168.100.191
Prochaine dispo : 192.168.100.192
```

**Département C - 192.168.100.192/27**

```
Réseau :          192.168.100.192
Première hôte :   192.168.100.193
Dernière hôte :   192.168.100.222
Broadcast :       192.168.100.223
Prochaine dispo : 192.168.100.224
```

**Département D - 192.168.100.224/28**

```
Réseau :          192.168.100.224
Première hôte :   192.168.100.225
Dernière hôte :   192.168.100.238
Broadcast :       192.168.100.239
Prochaine dispo : 192.168.100.240
```

**Liaison Routeur 1 - 192.168.100.240/30**

```
Réseau :          192.168.100.240
Première hôte :   192.168.100.241
Dernière hôte :   192.168.100.242
Broadcast :       192.168.100.243
Prochaine dispo : 192.168.100.244
```

**Liaison Routeur 2 - 192.168.100.244/30**

```
Réseau :          192.168.100.244
Première hôte :   192.168.100.245
Dernière hôte :   192.168.100.246
Broadcast :       192.168.100.247
Prochaine dispo : 192.168.100.248
```

**4. Bilan de l'allocation :**

```
Espace utilisé :   248 adresses (sur 256)
Espace restant :   192.168.100.248 - 192.168.100.255 (8 adresses)
Efficacité :       96.9%
```

### Visualisation hiérarchique du VLSM

```
192.168.100.0/24 (256 adresses)
│
├─ 192.168.100.0/25 ────────── Département A (128 adresses)
│
├─ 192.168.100.128/26 ───────── Département B (64 adresses)
│
├─ 192.168.100.192/27 ───────── Département C (32 adresses)
│
├─ 192.168.100.224/28 ───────── Département D (16 adresses)
│
├─ 192.168.100.240/30 ───────── Liaison 1 (4 adresses)
│
├─ 192.168.100.244/30 ───────── Liaison 2 (4 adresses)
│
└─ 192.168.100.248/29 ───────── Espace libre (8 adresses)
```

> [!tip] Bonnes pratiques VLSM
> 
> - **Toujours trier** les besoins du plus grand au plus petit
> - **Prévoir une marge** de croissance (10-20% supplémentaire)
> - **Documenter** immédiatement chaque allocation
> - **Réserver** des blocs pour usage futur
> - Utiliser des **outils de calcul** pour les réseaux complexes

> [!warning] Pièges courants en VLSM
> 
> - **Ne pas trier** les besoins → risque de fragmentation
> - **Oublier les liens point-à-point** (/30 pour les liaisons routeur-routeur)
> - **Sous-estimer** les besoins futurs
> - **Chevauchement** d'adresses par erreur de calcul
> - **Gaspillage** en allouant des masques trop larges

### Différence FLSM vs VLSM

|Critère|FLSM|VLSM|
|---|---|---|
|Taille des sous-réseaux|Identique pour tous|Variable selon les besoins|
|Complexité|Simple|Plus complexe|
|Efficacité d'adressage|Moyenne à faible|Très élevée|
|Usage|Réseaux homogènes|Réseaux hétérogènes|
|Protocoles requis|Tous|RIPv2, EIGRP, OSPF, IS-IS|
|Gaspillage d'adresses|Élevé|Minimal|

---

## 📊 Agrégation de routes (Supernetting)

### Qu'est-ce que le supernetting ?

Le **supernetting** (ou agrégation de routes) est l'opération **inverse du subnetting**. Il consiste à combiner plusieurs réseaux contigus en un seul réseau plus large avec un masque plus court.

> [!info] Objectifs du supernetting
> 
> - **Réduire la taille** des tables de routage
> - **Optimiser** les performances des routeurs
> - **Simplifier** la gestion du routage
> - **Améliorer** la scalabilité du réseau
> - Technique fondamentale pour le **routage CIDR**

### Principe du supernetting

Au lieu d'avoir plusieurs entrées dans la table de routage :

```
192.168.0.0/24
192.168.1.0/24
192.168.2.0/24
192.168.3.0/24
```

On crée une seule entrée agrégée :

```
192.168.0.0/22  (englobe les 4 réseaux)
```

### Conditions pour agréger des routes

Pour pouvoir agréger plusieurs réseaux, il faut que :

1. **Les réseaux soient contigus** (se suivent dans l'ordre)
2. **Le nombre de réseaux soit une puissance de 2** (2, 4, 8, 16, 32...)
3. **Le premier réseau commence à une frontière valide** pour le nouveau masque

> [!warning] Alignement des adresses L'adresse du premier réseau doit être divisible par la taille totale du bloc agrégé.
> 
> Exemple : Pour agréger 4 réseaux /24, le premier doit commencer à une adresse divisible par 4.

### Méthodologie d'agrégation en 4 étapes

#### Étape 1 : Vérifier la contiguïté

Lister les réseaux à agréger et s'assurer qu'ils se suivent sans interruption.

#### Étape 2 : Calculer le nouveau masque

```
Nouveau masque = Masque original - log₂(nombre de réseaux)
```

> [!example] Calcul du masque agrégé
> 
> ```
> 2 réseaux /24  → /24 - 1 = /23
> 4 réseaux /24  → /24 - 2 = /22
> 8 réseaux /24  → /24 - 3 = /21
> 16 réseaux /24 → /24 - 4 = /20
> ```

#### Étape 3 : Déterminer l'adresse réseau agrégée

L'adresse réseau agrégée est celle du **premier réseau** de la séquence.

#### Étape 4 : Vérifier la validité

S'assurer que tous les réseaux individuels sont bien **inclus** dans la plage de l'agrégat.

### Exemple 1 : Agrégation simple

**Réseaux à agréger :**

```
10.1.0.0/24
10.1.1.0/24
10.1.2.0/24
10.1.3.0/24
```

**1. Vérification :** 4 réseaux /24 contigus ✅

**2. Calcul du masque :**

```
/24 - log₂(4) = /24 - 2 = /22
```

**3. Route agrégée :**

```
10.1.0.0/22
```

**4. Vérification de la couverture :**

```
10.1.0.0/22 couvre de 10.1.0.0 à 10.1.3.255 ✅
```

**Résultat :**

- **Avant :** 4 entrées dans la table de routage
- **Après :** 1 seule entrée
- **Réduction :** 75%

### Exemple 2 : Agrégation complexe

**Réseaux à agréger :**

```
172.16.16.0/24
172.16.17.0/24
172.16.18.0/24
172.16.19.0/24
172.16.20.0/24
172.16.21.0/24
172.16.22.0/24
172.16.23.0/24
```

**1. Vérification :** 8 réseaux /24 contigus ✅

**2. Calcul du masque :**

```
/24 - log₂(8) = /24 - 3 = /21
```

**3. Route agrégée :**

```
172.16.16.0/21
```

**4. Détails de l'agrégat :**

```
Adresse réseau : 172.16.16.0
Masque :         255.255.248.0
Plage couverte : 172.16.16.0 - 172.16.23.255
Taille :         2048 adresses (8 × 256)
```

### Conversion binaire pour l'agrégation

Comprendre l'agrégation en binaire aide à visualiser le processus :

**Exemple : Agrégation de 4 réseaux /24**

```
192.168.0.0    11000000.10101000.00000000.00000000
192.168.1.0    11000000.10101000.00000001.00000000
192.168.2.0    11000000.10101000.00000010.00000000
192.168.3.0    11000000.10101000.00000011.00000000
               ────────────────────────────────────
Partie commune 11000000.10101000.000000            ← 22 bits

Masque /22 :   11111111.11111111.11111100.00000000
Résultat :     192.168.0.0/22
```

Les **22 premiers bits** sont identiques → on peut agréger avec un masque /22.

### Tableau de référence pour l'agrégation

|Réseaux à agréger|Bits à supprimer|Nouveau masque|Exemple|
|---|---|---|---|
|2 × /24|1|/23|192.168.0.0/23|
|4 × /24|2|/22|192.168.0.0/22|
|8 × /24|3|/21|192.168.0.0/21|
|16 × /24|4|/20|192.168.0.0/20|
|2 × /23|1|/22|10.0.0.0/22|
|4 × /22|2|/20|10.0.0.0/20|
|8 × /21|3|/18|10.0.0.0/18|

### Vérification d'une agrégation valide

Pour vérifier si une agrégation est correcte, utiliser cette checklist :

> [!tip] Checklist de validation
> 
> - [ ] Les réseaux sont-ils **contigus** ?
> - [ ] Le nombre de réseaux est-il une **puissance de 2** ?
> - [ ] Le premier réseau commence-t-il à une **adresse alignée** ?
> - [ ] Tous les réseaux individuels sont-ils **inclus** dans l'agrégat ?
> - [ ] Aucun réseau **externe** n'est-il inclus par erreur ?

### Cas particulier : Agrégation non alignée

**Problème :** Que faire si les réseaux ne commencent pas à une adresse alignée ?

**Exemple :** Agréger ces réseaux

```
10.50.10.0/24
10.50.11.0/24
10.50.12.0/24
10.50.13.0/24
```

**Analyse :**

- 4 réseaux /24 contigus
- Masque cible : /22
- **Problème :** 10.50.10.0 n'est pas divisible par 4

**Solution :**

En binaire, le troisième octet :

```
10 = 00001010
11 = 00001011
12 = 00001100
13 = 00001101
```

On ne peut pas créer un /22 propre car le début n'est pas aligné sur une frontière /22.

**Alternatives :**

1. **Agréger par paires** :
    
    - 10.50.10.0/23 (englobe .10 et .11)
    - 10.50.12.0/23 (englobe .12 et .13)
    - Résultat : 2 entrées au lieu de 4
2. **Utiliser un masque plus court** (moins efficace) :
    
    - 10.50.8.0/21 engloberait tout mais inclurait aussi .8, .9, .14, .15

> [!warning] Importance de l'alignement L'agrégation fonctionne uniquement si l'adresse de départ est alignée sur la frontière du nouveau masque. C'est pourquoi la planification initiale du réseau est cruciale.

### Application pratique : Annonce de routes

Le supernetting est utilisé dans plusieurs contextes :

**1. BGP (Border Gateway Protocol)**

```
Au lieu d'annoncer :
  203.0.113.0/24
  203.0.114.0/24
  203.0.115.0/24
  203.0.116.0/24

On annonce :
  203.0.113.0/22
```

**2. Routage interne**

```
Routeur de cœur reçoit :
  10.1.0.0/22   (agrégat du datacenter A)
  10.2.0.0/22   (agrégat du datacenter B)

Au lieu de dizaines de routes /24 individuelles
```

**3. Tables de routage Internet**

```
Avant CIDR (années 1990) : ~100,000 entrées
Après CIDR avec agrégation : réduction massive
Aujourd'hui : ~950,000 entrées (mais sans agrégation, ce serait des millions)
```

### Exemple réel : FAI et agrégation

**Contexte :** Un FAI possède ces blocs contigus :

```
198.51.100.0/24  → Client A
198.51.101.0/24  → Client B
198.51.102.0/24  → Client C
198.51.103.0/24  → Client D
198.51.104.0/24  → Client E
198.51.105.0/24  → Client F
198.51.106.0/24  → Client G
198.51.107.0/24  → Client H
```

**Agrégation hiérarchique :**

```
Niveau 1 - Agrégation complète :
198.51.100.0/21  (annoncé sur Internet)
│
├─ Niveau 2 - Par région :
│  ├─ 198.51.100.0/22  (Région Nord)
│  │  ├─ 198.51.100.0/23
│  │  │  ├─ 198.51.100.0/24  (Client A)
│  │  │  └─ 198.51.101.0/24  (Client B)
│  │  └─ 198.51.102.0/23
│  │     ├─ 198.51.102.0/24  (Client C)
│  │     └─ 198.51.103.0/24  (Client D)
│  │
│  └─ 198.51.104.0/22  (Région Sud)
│     ├─ 198.51.104.0/23
│     │  ├─ 198.51.104.0/24  (Client E)
│     │  └─ 198.51.105.0/24  (Client F)
│     └─ 198.51.106.0/23
│        ├─ 198.51.106.0/24  (Client G)
│        └─ 198.51.107.0/24  (Client H)
```

**Avantages :**

- Internet global : 1 route (/21)
- Routeurs régionaux : 2 routes (/22)
- Routeurs d'accès : 4 routes (/23)
- Clients individuels : 8 routes (/24)

### Calcul rapide d'agrégation

**Méthode des puissances de 2 :**

|Nombre de /24|Bits à retirer|Nouveau masque|Bloc d'adresses|
|---|---|---|---|
|2|1|/23|512 adresses|
|4|2|/22|1,024 adresses|
|8|3|/21|2,048 adresses|
|16|4|/20|4,096 adresses|
|32|5|/19|8,192 adresses|
|64|6|/18|16,384 adresses|
|128|7|/17|32,768 adresses|
|256|8|/16|65,536 adresses|

### Supernetting et routage sans classe (CIDR)

Le **CIDR** (Classless Inter-Domain Routing) a été introduit en 1993 pour :

1. **Ralentir l'épuisement** des adresses IPv4
2. **Réduire** la taille des tables de routage BGP
3. **Permettre** une allocation plus flexible des adresses

> [!info] CIDR vs Classes **Avant CIDR (classes) :**
> 
> - Organisation demande 2000 adresses
> - Reçoit une classe B complète (/16 = 65,536 adresses)
> - Gaspillage : 63,536 adresses
> 
> **Avec CIDR :**
> 
> - Organisation demande 2000 adresses
> - Reçoit un /21 (2,048 adresses)
> - Gaspillage : seulement 48 adresses

### Outils de calcul d'agrégation

**Méthode manuelle rapide :**

```
Pour trouver le masque agrégé de N réseaux /X :

1. N doit être une puissance de 2
2. Bits à retirer = log₂(N)
3. Nouveau masque = X - bits à retirer

Exemple : 16 réseaux /24
  log₂(16) = 4
  /24 - 4 = /20
```

**Vérification de l'adresse de début :**

```
Pour un /22 (qui couvre 4 × /24) :
  L'adresse doit être divisible par 4

Exemples valides :
  192.168.0.0/22  ✅ (0 divisible par 4)
  192.168.4.0/22  ✅ (4 divisible par 4)
  192.168.8.0/22  ✅ (8 divisible par 4)

Exemples invalides :
  192.168.1.0/22  ❌ (1 non divisible par 4)
  192.168.3.0/22  ❌ (3 non divisible par 4)
  192.168.10.0/22 ❌ (10 non divisible par 4)
```

### Limites et considérations du supernetting

> [!warning] Attention aux agrégations excessives **Problème du "black hole"** : Si vous agrégez trop et qu'un sous-réseau devient inaccessible, tout le trafic vers l'agrégat peut être affecté.
> 
> **Exemple :**
> 
> - Vous annoncez 10.0.0.0/16 (agrégat)
> - Le réseau 10.0.50.0/24 tombe en panne
> - Si un routeur distant connaît uniquement l'agrégat, il continuera d'envoyer le trafic vers vous
> - Le trafic pour 10.0.50.0/24 sera perdu

**Solutions :**

1. **Route plus spécifique** : annoncer aussi les routes critiques individuellement
2. **Monitoring** : détecter les pannes rapidement
3. **Redondance** : avoir des chemins alternatifs

### Bonnes pratiques d'agrégation

> [!tip] Règles d'or
> 
> 1. **Planifier l'adressage** dès le départ pour faciliter l'agrégation future
> 2. **Documenter** toutes les agrégations effectuées
> 3. **Aligner** les blocs d'adresses sur des frontières de puissances de 2
> 4. **Ne pas sur-agréger** : garder des routes spécifiques pour le contrôle fin
> 5. **Tester** l'impact avant de déployer en production
> 6. **Monitorer** les performances après agrégation

### Comparaison : Avant/Après agrégation

**Scénario : Entreprise multi-sites**

|Aspect|Sans agrégation|Avec agrégation|
|---|---|---|
|**Routes annoncées**|50 réseaux /24|1 réseau /18|
|**Taille table routage**|50 entrées|1 entrée|
|**Mémoire routeur**|~15 KB|~300 bytes|
|**Temps convergence**|Plus lent|Plus rapide|
|**Stabilité**|Moins stable|Plus stable|
|**Complexité config**|Haute|Basse|

**Économies réalisées :**

- **Mémoire :** 98% de réduction
- **Processeur :** moins de calculs de routage
- **Bande passante :** moins d'updates de routage
- **Maintenance :** configuration simplifiée

### Exercice de validation des connaissances

**Situation :** Vous avez ces réseaux :

```
172.20.32.0/24
172.20.33.0/24
172.20.34.0/24
172.20.35.0/24
172.20.36.0/24
172.20.37.0/24
172.20.38.0/24
172.20.39.0/24
```

**Questions à se poser :**

1. Sont-ils contigus ? → ✅ Oui (32 à 39)
2. Combien y en a-t-il ? → 8 réseaux
3. Est-ce une puissance de 2 ? → ✅ Oui (2³ = 8)
4. Masque actuel ? → /24
5. Bits à retirer ? → log₂(8) = 3
6. Nouveau masque ? → /24 - 3 = /21
7. Premier réseau ? → 172.20.32.0
8. Alignement ? → 32 divisible par 8 ? → ✅ Oui (32 = 4×8)

**Route agrégée finale :**

```
172.20.32.0/21
```

**Vérification :**

```
172.20.32.0/21 couvre de 172.20.32.0 à 172.20.39.255 ✅
Tous les réseaux sont inclus ✅
Aucun réseau externe n'est inclus ✅
```

---

## 🎓 Résumé des concepts clés

### Subnetting (FLSM)

- Diviser un réseau en **sous-réseaux de taille égale**
- Utile pour des besoins **homogènes**
- Formule : **2^n - 2** hôtes utilisables
- Simple mais peut gaspiller des adresses

### VLSM

- Diviser un réseau en **sous-réseaux de tailles variables**
- Optimise l'utilisation des adresses
- Nécessite un **tri décroissant** des besoins
- Requiert des protocoles de routage modernes

### Supernetting

- **Combiner** plusieurs réseaux en un seul
- Réduit la taille des tables de routage
- Nécessite des réseaux **contigus et alignés**
- Fondamental pour la scalabilité Internet

> [!tip] Principe général
> 
> - **Subnetting** : on rallonge le masque (on découpe)
> - **Supernetting** : on raccourcit le masque (on agrège)
> - **VLSM** : on utilise plusieurs longueurs de masque (on optimise)

### Tableau récapitulatif des opérations

|Opération|Direction masque|Objectif|Exemple|
|---|---|---|---|
|**Subnetting**|⬆️ Allonger (+bits)|Créer plusieurs petits réseaux|/24 → /26|
|**Supernetting**|⬇️ Raccourcir (-bits)|Créer un grand réseau|/24 → /22|
|**VLSM**|⬆️⬇️ Variable|Optimiser l'espace|/24 → /25, /27, /30|

### Formules essentielles à retenir

```
┌─────────────────────────────────────────────────────────┐
│  Nombre de sous-réseaux = 2^(bits empruntés)            │
│  Nombre d'hôtes = 2^(bits restants) - 2                 │
│  Incrément = 256 - (valeur octet masque)                │
│  Nouveau masque agrégé = Masque - log₂(nb réseaux)      │
└─────────────────────────────────────────────────────────┘
```

### Masques à connaître par cœur

|CIDR|Masque décimal|Hôtes|Usage typique|
|---|---|---|---|
|/30|255.255.255.252|2|Liens point-à-point|
|/29|255.255.255.248|6|Très petits LANs|
|/28|255.255.255.240|14|Petits groupes|
|/27|255.255.255.224|30|Départements|
|/26|255.255.255.192|62|Moyens groupes|
|/25|255.255.255.128|126|Grands groupes|
|/24|255.255.255.0|254|LAN standard|

---

## ✅ Points de vigilance finaux

> [!warning] Erreurs fréquentes à éviter
> 
> **En Subnetting :**
> 
> - Oublier de soustraire 2 pour les adresses réseau/broadcast
> - Confondre nombre de sous-réseaux et nombre d'hôtes
> - Ne pas vérifier que tous les sous-réseaux tiennent dans l'espace disponible
> 
> **En VLSM :**
> 
> - Ne pas trier les besoins par ordre décroissant
> - Oublier les liaisons point-à-point (/30)
> - Créer des chevauchements d'adresses
> - Sous-estimer les besoins de croissance
> 
> **En Supernetting :**
> 
> - Agréger des réseaux non contigus
> - Ignorer l'alignement des adresses
> - Sur-agréger et perdre la granularité
> - Ne pas documenter les agrégations

> [!tip] Astuces de mémorisation
> 
> - **Masque /30** : "Thirty = Two" (30 → 2 hôtes)
> - **Puissances de 2** : 2, 4, 8, 16, 32, 64, 128, 256
> - **Incrément** : toujours une puissance de 2
> - **Premier réseau** : toujours divisible par le nombre de réseaux agrégés

---

**📝 Fin du cours Subnetting IPv4**