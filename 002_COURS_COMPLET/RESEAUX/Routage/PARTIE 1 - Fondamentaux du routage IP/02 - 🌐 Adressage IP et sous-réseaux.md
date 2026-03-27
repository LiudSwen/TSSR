

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

## 📊 Classes d'adresses IPv4

### Principe fondamental

L'adressage IPv4 utilise des adresses de **32 bits** représentées en notation décimale pointée (4 octets). Historiquement, les adresses ont été divisées en **classes** pour faciliter la répartition et l'attribution des adresses réseau.

> [!info] Pourquoi les classes ? Dans les années 1980, l'IANA (Internet Assigned Numbers Authority) a créé un système de classes pour organiser l'espace d'adressage IPv4 de manière hiérarchique. Chaque classe était destinée à des types d'organisations différents selon leur taille.

### Les 5 classes d'adresses

|Classe|Premier octet|Plage d'adresses|Masque par défaut|Bits réseau/hôte|Usage|
|---|---|---|---|---|---|
|**A**|1-126|0.0.0.0 - 127.255.255.255|255.0.0.0 (/8)|8/24|Très grands réseaux|
|**B**|128-191|128.0.0.0 - 191.255.255.255|255.255.0.0 (/16)|16/16|Réseaux moyens|
|**C**|192-223|192.0.0.0 - 223.255.255.255|255.255.255.0 (/24)|24/8|Petits réseaux|
|**D**|224-239|224.0.0.0 - 239.255.255.255|N/A|N/A|Multicast|
|**E**|240-255|240.0.0.0 - 255.255.255.255|N/A|N/A|Expérimental|

### Identification des classes

La classe d'une adresse est identifiable par les **premiers bits** de l'adresse :

```
Classe A : 0xxxxxxx.xxxxxxxx.xxxxxxxx.xxxxxxxx
Classe B : 10xxxxxx.xxxxxxxx.xxxxxxxx.xxxxxxxx
Classe C : 110xxxxx.xxxxxxxx.xxxxxxxx.xxxxxxxx
Classe D : 1110xxxx.xxxxxxxx.xxxxxxxx.xxxxxxxx
Classe E : 1111xxxx.xxxxxxxx.xxxxxxxx.xxxxxxxx
```

> [!example] Exemples pratiques
> 
> - **10.50.100.1** → Premier octet = 10 → Classe A
> - **172.16.0.1** → Premier octet = 172 → Classe B
> - **192.168.1.1** → Premier octet = 192 → Classe C
> - **224.0.0.1** → Premier octet = 224 → Classe D (multicast)

### Adresses spéciales et réservées

#### Adresses privées (RFC 1918)

Ces plages ne sont **pas routables sur Internet** et sont utilisées pour les réseaux locaux :

- **Classe A privée** : 10.0.0.0/8 (10.0.0.0 à 10.255.255.255)
- **Classe B privée** : 172.16.0.0/12 (172.16.0.0 à 172.31.255.255)
- **Classe C privée** : 192.168.0.0/16 (192.168.0.0 à 192.168.255.255)

#### Autres adresses réservées

- **127.0.0.0/8** : Loopback (localhost) - 127.0.0.1 est l'adresse de bouclage
- **169.254.0.0/16** : APIPA (Automatic Private IP Addressing) - auto-configuration
- **0.0.0.0/8** : Réseau "ce réseau" (current network)

> [!warning] Limites du système à classes Le système de classes s'est révélé **inefficace** :
> 
> - Gaspillage d'adresses (une classe B = 65 534 hôtes, souvent trop pour une entreprise)
> - Pénurie d'adresses IPv4
> - Flexibilité limitée
> 
> C'est pourquoi le **CIDR** (Classless Inter-Domain Routing) a été introduit en 1993.

---

## 🎯 Masques de sous-réseau (CIDR)

### Principe du masquage

Un **masque de sous-réseau** est une valeur de 32 bits qui sépare une adresse IP en deux parties :

- **Partie réseau** : identifie le réseau
- **Partie hôte** : identifie la machine sur ce réseau

Le masque utilise des **1 consécutifs** pour la partie réseau, suivis de **0 consécutifs** pour la partie hôte.

> [!info] CIDR (Classless Inter-Domain Routing) La notation CIDR utilise le format **adresse/préfixe**, où le préfixe indique le nombre de bits à 1 dans le masque.
> 
> Exemple : **192.168.1.0/24** signifie que les 24 premiers bits sont le réseau.

### Notation décimale vs CIDR

|Notation CIDR|Masque décimal|Bits réseau|Bits hôte|Nombre d'hôtes|
|---|---|---|---|---|
|/8|255.0.0.0|8|24|16 777 214|
|/16|255.255.0.0|16|16|65 534|
|/24|255.255.255.0|24|8|254|
|/25|255.255.255.128|25|7|126|
|/26|255.255.255.192|26|6|62|
|/27|255.255.255.224|27|5|30|
|/28|255.255.255.240|28|4|14|
|/29|255.255.255.248|29|3|6|
|/30|255.255.255.252|30|2|2|
|/31|255.255.255.254|31|1|2*|
|/32|255.255.255.255|32|0|1 (hôte unique)|

> [!tip] Astuce pour le /30 Un réseau **/30** est parfait pour les **liaisons point-à-point** entre deux routeurs (2 hôtes utilisables + 1 réseau + 1 broadcast = 4 adresses totales).

> [!example] Notation /31 pour liens point-à-point Le **/31** (RFC 3021) permet d'utiliser 2 adresses sans gaspiller d'adresse réseau ni broadcast, optimisé pour les liens point-à-point.

### Conversion masque décimal ↔ CIDR

#### Méthode binaire

Pour convertir un masque décimal en CIDR, il faut compter les bits à 1 :

```
Exemple : 255.255.255.224

Étape 1 : Convertir en binaire
255 = 11111111
255 = 11111111
255 = 11111111
224 = 11100000

Étape 2 : Compter les 1
11111111.11111111.11111111.11100000 = 27 bits à 1

Résultat : /27
```

#### Tableau de conversion rapide (dernier octet)

|Valeur|Binaire|Bits|CIDR|
|---|---|---|---|
|0|00000000|+0|/24|
|128|10000000|+1|/25|
|192|11000000|+2|/26|
|224|11100000|+3|/27|
|240|11110000|+4|/28|
|248|11111000|+5|/29|
|252|11111100|+6|/30|
|254|11111110|+7|/31|
|255|11111111|+8|/32|

### Opération ET logique (AND)

Le masque est appliqué à l'adresse IP via une opération **ET bit à bit** pour obtenir l'adresse réseau :

```
Exemple : 192.168.1.130/26

Adresse IP    : 192.168.1.130  = 11000000.10101000.00000001.10000010
Masque /26    : 255.255.255.192 = 11111111.11111111.11111111.11000000
                                  ─────────────────────────────────────
Réseau (AND)  : 192.168.1.128   = 11000000.10101000.00000001.10000000
```

> [!tip] Méthode rapide pour les calculs Pour un masque /26 (255.255.255.192) :
> 
> - Le dernier octet a une valeur de masque de 192
> - Les réseaux sont espacés de : 256 - 192 = **64**
> - Les réseaux possibles sont : 0, 64, 128, 192
> - 130 est entre 128 et 192, donc le réseau est **192.168.1.128/26**

### Sous-réseaux (Subnetting)

Le **subnetting** consiste à diviser un réseau en plusieurs sous-réseaux plus petits pour :

- Optimiser l'utilisation des adresses
- Améliorer la sécurité (segmentation)
- Réduire les domaines de broadcast

#### Formule de calcul

```
Nombre de sous-réseaux = 2^n  (où n = nombre de bits empruntés)
Nombre d'hôtes par sous-réseau = 2^h - 2  (où h = bits hôtes restants)
```

> [!example] Exemple de subnetting **Réseau initial** : 192.168.1.0/24 (254 hôtes)
> 
> **Objectif** : Créer 4 sous-réseaux
> 
> **Solution** :
> 
> - Bits nécessaires : 2^2 = 4 sous-réseaux → emprunter 2 bits
> - Nouveau masque : /24 + 2 = **/26**
> - Hôtes par sous-réseau : 2^6 - 2 = 62 hôtes
> 
> **Sous-réseaux créés** :
> 
> 1. 192.168.1.0/26 (0-63)
> 2. 192.168.1.64/26 (64-127)
> 3. 192.168.1.128/26 (128-191)
> 4. 192.168.1.192/26 (192-255)

### VLSM (Variable Length Subnet Mask)

Le **VLSM** permet d'utiliser des masques de longueurs différentes au sein d'un même réseau majeur, optimisant ainsi l'utilisation des adresses.

> [!info] Avantages du VLSM
> 
> - Flexibilité dans l'allocation des adresses
> - Réduction du gaspillage d'adresses
> - Adaptation aux besoins réels de chaque sous-réseau

> [!example] Exemple VLSM **Réseau** : 172.16.0.0/16
> 
> **Besoins** :
> 
> - Service A : 500 hôtes → /23 (510 hôtes)
> - Service B : 100 hôtes → /25 (126 hôtes)
> - Service C : 50 hôtes → /26 (62 hôtes)
> - Liaison routeur-routeur : 2 hôtes → /30 (2 hôtes)
> 
> **Allocation** :
> 
> - Service A : 172.16.0.0/23
> - Service B : 172.16.2.0/25
> - Service C : 172.16.2.128/26
> - Liaison : 172.16.2.192/30

---

## 🧮 Calcul de réseau, broadcast, plage d'hôtes

### Les éléments d'un sous-réseau

Chaque sous-réseau contient 4 éléments clés :

1. **Adresse réseau** : Première adresse (tous les bits hôtes à 0)
2. **Première adresse hôte** : Adresse réseau + 1
3. **Dernière adresse hôte** : Adresse broadcast - 1
4. **Adresse de broadcast** : Dernière adresse (tous les bits hôtes à 1)

### Méthode de calcul systématique

#### Étape 1 : Identifier le masque et calculer le bloc

```
Formule du bloc = 256 - valeur_octet_masque

Exemple : /26 → 255.255.255.192
Bloc = 256 - 192 = 64
```

#### Étape 2 : Trouver l'adresse réseau

L'adresse réseau est le multiple du bloc immédiatement inférieur ou égal à l'adresse donnée.

```
Exemple : 192.168.10.150/26
Bloc = 64
Multiples de 64 : 0, 64, 128, 192, 256...
150 est entre 128 et 192
→ Adresse réseau = 192.168.10.128
```

#### Étape 3 : Calculer le broadcast

```
Broadcast = Prochain_réseau - 1

Exemple : 192.168.10.150/26
Adresse réseau = 192.168.10.128
Prochain réseau = 192.168.10.192
→ Broadcast = 192.168.10.191
```

#### Étape 4 : Déterminer la plage d'hôtes

```
Première hôte = Adresse_réseau + 1
Dernière hôte = Adresse_broadcast - 1

Exemple : 192.168.10.150/26
→ Plage : 192.168.10.129 à 192.168.10.190
```

> [!example] Exemple complet **Adresse donnée** : 10.50.120.75/21
> 
> **Étape 1** : Masque /21 = 255.255.248.0
> 
> - Octet concerné : le 3ème (120)
> - Bloc = 256 - 248 = **8**
> 
> **Étape 2** : Trouver le réseau
> 
> - Multiples de 8 : 0, 8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88, 96, 104, 112, **120**, 128...
> - **Réseau** : 10.50.120.0
> 
> **Étape 3** : Calculer le broadcast
> 
> - Prochain réseau : 10.50.128.0
> - **Broadcast** : 10.50.127.255
> 
> **Étape 4** : Plage d'hôtes
> 
> - **Première hôte** : 10.50.120.1
> - **Dernière hôte** : 10.50.127.254
> - **Nombre d'hôtes** : 2^11 - 2 = 2046 hôtes

### Tableaux de référence rapide

#### Masques courants et leurs caractéristiques

|CIDR|Masque|Bloc|Réseaux|Hôtes par réseau|Usage typique|
|---|---|---|---|---|---|
|/30|255.255.255.252|4|64|2|Liaisons point-à-point|
|/29|255.255.255.248|8|32|6|Très petits réseaux|
|/28|255.255.255.240|16|16|14|Petits départements|
|/27|255.255.255.224|32|8|30|Équipes de travail|
|/26|255.255.255.192|64|4|62|Bureaux moyens|
|/25|255.255.255.128|128|2|126|Grands bureaux|
|/24|255.255.255.0|256|1|254|Réseau local standard|

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> **1. Oublier les adresses réservées**
> 
> - L'adresse réseau et le broadcast ne sont **PAS utilisables** pour des hôtes
> - Toujours soustraire 2 au nombre total d'adresses
> 
> **2. Confusion entre masque et inverse**
> 
> - Masque : bits à 1 pour le réseau
> - Wildcard (inverse) : bits à 0 pour le réseau (utilisé dans les ACL)
> 
> **3. Mauvais octet de calcul**
> 
> - Avec /21, le calcul se fait sur le 3ème octet
> - Avec /14, le calcul se fait sur le 2ème octet
> - Identifier le bon octet selon le masque !

> [!tip] Astuces de calcul mental
> 
> **Méthode des puissances de 2** :
> 
> - /30 = 2^2 = 4 adresses
> - /29 = 2^3 = 8 adresses
> - /28 = 2^4 = 16 adresses
> - /27 = 2^5 = 32 adresses
> - /26 = 2^6 = 64 adresses
> - /25 = 2^7 = 128 adresses
> - /24 = 2^8 = 256 adresses
> 
> **Règle rapide pour /24 à /32** : Le dernier octet seul détermine tout. Apprenez les multiples de : 4, 8, 16, 32, 64, 128.

---

## 🔗 Supernetting et agrégation

### Principe du Supernetting

Le **supernetting** (ou agrégation de routes) est l'opération inverse du subnetting : il consiste à **regrouper plusieurs réseaux contigus** en un seul réseau plus grand avec un masque plus court.

> [!info] Objectifs du supernetting
> 
> - **Réduire la taille des tables de routage** (moins d'entrées)
> - **Améliorer les performances** des routeurs
> - **Simplifier la gestion** des routes
> - **Optimiser la propagation** des routes dans les protocoles de routage

### Conditions pour agréger

Pour pouvoir agréger plusieurs réseaux, il faut que :

1. Les réseaux soient **contigus** (consécutifs dans l'espace d'adressage)
2. Les réseaux aient la **même longueur de masque** (même taille)
3. Le nombre de réseaux soit une **puissance de 2** (2, 4, 8, 16...)
4. Le premier réseau commence sur une **limite correcte** (multiple du nouveau bloc)

### Méthode d'agrégation

#### Étape 1 : Vérifier la contiguïté

```
Exemple : Peut-on agréger ces réseaux ?
- 192.168.0.0/24
- 192.168.1.0/24
- 192.168.2.0/24
- 192.168.3.0/24

Réponse : OUI (réseaux consécutifs, même taille, 4 = 2^2)
```

#### Étape 2 : Trouver le nouveau masque

```
Formule : nouveau_masque = ancien_masque - nombre_de_bits_empruntés

Nombre de réseaux = 2^n
→ n bits à "emprunter" au masque réseau

Exemple : 4 réseaux /24
4 = 2^2 → 2 bits
Nouveau masque = 24 - 2 = /22
```

#### Étape 3 : Calculer le réseau agrégé

Le réseau agrégé est le premier réseau de la séquence avec le nouveau masque.

```
Exemple : Agrégation de 192.168.0.0/24 à 192.168.3.0/24
→ Réseau agrégé : 192.168.0.0/22
```

> [!example] Exemple complet d'agrégation **Réseaux à agréger** :
> 
> - 172.16.0.0/24
> - 172.16.1.0/24
> - 172.16.2.0/24
> - 172.16.3.0/24
> - 172.16.4.0/24
> - 172.16.5.0/24
> - 172.16.6.0/24
> - 172.16.7.0/24
> 
> **Solution** :
> 
> 1. Nombre de réseaux = 8 = 2^3
> 2. Bits à emprunter = 3
> 3. Nouveau masque = 24 - 3 = **/21**
> 4. **Réseau agrégé** : 172.16.0.0/21
> 
> **Vérification** :
> 
> - 172.16.0.0/21 couvre 2048 adresses (256 × 8)
> - De 172.16.0.0 à 172.16.7.255 ✓

### Vérification par conversion binaire

Pour s'assurer que l'agrégation est correcte, convertir en binaire les adresses concernées :

```
Exemple : Agréger 10.1.0.0/24, 10.1.1.0/24, 10.1.2.0/24, 10.1.3.0/24

10.1.0.0 = 00001010.00000001.00000000.00000000
10.1.1.0 = 00001010.00000001.00000001.00000000
10.1.2.0 = 00001010.00000001.00000010.00000000
10.1.3.0 = 00001010.00000001.00000011.00000000
                                       ^^
                                       Ces 2 bits varient

Les 22 premiers bits sont identiques
→ Agrégation possible en /22
→ Résultat : 10.1.0.0/22
```

### Agrégation hiérarchique

Dans les grands réseaux, l'agrégation peut se faire de manière **hiérarchique** à plusieurs niveaux.

> [!example] Agrégation à plusieurs niveaux **Niveau 1 - Sites locaux** :
> 
> - Site A : 10.1.0.0/24, 10.1.1.0/24, 10.1.2.0/24, 10.1.3.0/24 → Agrégé en : **10.1.0.0/22**
>     
> - Site B : 10.1.4.0/24, 10.1.5.0/24, 10.1.6.0/24, 10.1.7.0/24 → Agrégé en : **10.1.4.0/22**
>     
> 
> **Niveau 2 - Région** :
> 
> - 10.1.0.0/22 + 10.1.4.0/22 → Agrégé en : **10.1.0.0/21**

### Limites et pièges du supernetting

> [!warning] Attention aux trous ! Si vous agrégez 192.168.0.0/24 et 192.168.2.0/24 (en sautant .1.0), l'agrégat 192.168.0.0/23 **inclura 192.168.1.0/24** qui n'existe peut-être pas dans votre réseau.
> 
> Cela peut créer des **routes noires** (black holes) où le trafic est routé vers des réseaux inexistants.

> [!warning] Perte de spécificité Une route agrégée est **moins spécifique** qu'une route individuelle. En cas de conflit, la route la plus spécifique (masque le plus long) est préférée.
> 
> Exemple :
> 
> - Route agrégée : 10.0.0.0/8
> - Route spécifique : 10.1.1.0/24
> 
> Le trafic vers 10.1.1.0/24 suivra la route spécifique, pas l'agrégat.

### Applications pratiques

#### Dans les protocoles de routage

Les protocoles de routage modernes (BGP, OSPF, EIGRP) supportent l'agrégation automatique ou manuelle :

```bash
# Exemple de configuration Cisco pour l'agrégation
router bgp 65000
  address-family ipv4
    aggregate-address 192.168.0.0 255.255.252.0 summary-only
```

#### Agrégation pour l'Internet

Les FAI (Fournisseurs d'Accès Internet) utilisent massivement l'agrégation pour :

- Réduire la taille de la table de routage Internet (actuellement ~900k entrées)
- Annoncer un seul préfixe pour tous leurs clients

> [!tip] Bonnes pratiques d'agrégation
> 
> **1. Planifier la hiérarchie d'adressage**
> 
> - Attribuer les réseaux de manière contiguë dès le départ
> - Prévoir les futures agrégations
> 
> **2. Documenter les agrégations**
> 
> - Maintenir un plan d'adressage clair
> - Indiquer quels réseaux sont agrégés où
> 
> **3. Surveiller les routes**
> 
> - Vérifier que l'agrégation n'introduit pas de boucles
> - Valider que tous les sous-réseaux restent joignables
> 
> **4. Utiliser l'agrégation avec modération**
> 
> - Ne pas sur-agréger au détriment de la précision du routage
> - Conserver des routes spécifiques si nécessaire pour le contrôle

### Calcul rapide d'agrégation

> [!tip] Méthode rapide Pour agréger rapidement :
> 
> 1. Compter le nombre de réseaux : N
> 2. Trouver la puissance de 2 : N = 2^n
> 3. Soustraire n du masque d'origine
> 4. Vérifier que le premier réseau est aligné sur le nouveau bloc
> 
> **Exemple mental** :
> 
> - 8 réseaux /24 → 8 = 2^3 → /24 - 3 = /21
> - 16 réseaux /27 → 16 = 2^4 → /27 - 4 = /23
> - 4 réseaux /22 → 4 = 2^2 → /22 - 2 = /20

---

## 📚 Résumé des concepts clés

> [!info] Points essentiels à retenir
> 
> **Classes d'adresses** :
> 
> - Système historique (A, B, C, D, E)
> - Remplacé par CIDR pour plus de flexibilité
> - Adresses privées (RFC 1918) : 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
> 
> **CIDR et masques** :
> 
> - Notation /préfixe pour indiquer la longueur du masque
> - Opération ET logique pour trouver le réseau
> - VLSM permet des masques de longueurs variables
> 
> **Calculs de sous-réseaux** :
> 
> - Méthode du bloc : 256 - valeur_masque
> - Toujours retirer 2 adresses (réseau + broadcast)
> - Identifier le bon octet selon le masque
> 
> **Supernetting** :
> 
> - Agrégation de réseaux contigus
> - Réduit la taille des tables de routage
> - Nécessite une planification rigoureuse

---

_Ce document constitue une référence complète sur l'adressage IP et les sous-réseaux. Pour approfondir, référez-vous aux RFC 791 (IP), RFC 1918 (Private Address Space), RFC 4632 (CIDR), et RFC 1812 (Router Requirements)._