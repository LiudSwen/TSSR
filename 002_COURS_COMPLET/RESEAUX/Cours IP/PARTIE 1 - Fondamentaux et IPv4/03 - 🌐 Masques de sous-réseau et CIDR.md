

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

## 🎯 Masque de sous-réseau par défaut

### Qu'est-ce qu'un masque de sous-réseau ?

Le masque de sous-réseau (subnet mask) est un nombre de 32 bits qui permet de distinguer dans une adresse IP :

- La **partie réseau** (network portion) : identifie le réseau
- La **partie hôte** (host portion) : identifie la machine sur ce réseau

> [!info] Principe fondamental Le masque utilise une suite de bits à 1 suivie d'une suite de bits à 0. Les bits à 1 correspondent à la partie réseau, les bits à 0 à la partie hôte.

### Les masques par défaut selon les classes

Les classes d'adresses IP ont des masques de sous-réseau par défaut :

|Classe|Plage d'adresses|Masque par défaut|Notation binaire|CIDR|
|---|---|---|---|---|
|**Classe A**|1.0.0.0 - 126.255.255.255|255.0.0.0|11111111.00000000.00000000.00000000|/8|
|**Classe B**|128.0.0.0 - 191.255.255.255|255.255.0.0|11111111.11111111.00000000.00000000|/16|
|**Classe C**|192.0.0.0 - 223.255.255.255|255.255.255.0|11111111.11111111.11111111.00000000|/24|

> [!example] Exemple concret Pour l'adresse IP **172.16.50.10** (Classe B) :
> 
> - Masque par défaut : **255.255.0.0**
> - Partie réseau : **172.16**.0.0
> - Partie hôte : 0.0.**50.10**

### Comment fonctionne le masque ?

Le masque agit comme un filtre lors d'une opération **ET logique (AND)** bit à bit avec l'adresse IP :

```
Adresse IP :    192.168.1.100     11000000.10101000.00000001.01100100
Masque :        255.255.255.0     11111111.11111111.11111111.00000000
                                   ========================================
Résultat (AND): 192.168.1.0       11000000.10101000.00000001.00000000
```

> [!tip] Astuce pour comprendre Là où le masque a un **1**, l'adresse IP est **conservée** (partie réseau)  
> Là où le masque a un **0**, l'adresse IP est **mise à zéro** (partie hôte)

### Pourquoi utiliser des masques ?

1. **Segmentation du réseau** : diviser un grand réseau en sous-réseaux plus petits
2. **Sécurité** : isoler des segments de réseau
3. **Performance** : réduire le broadcast domain
4. **Organisation logique** : regrouper des machines par fonction ou localisation

> [!warning] Attention Le masque par défaut n'est qu'une convention. En pratique, vous pouvez utiliser n'importe quel masque selon vos besoins (on parle alors de **subnetting**).

---

## 📐 Notation CIDR

### Qu'est-ce que CIDR ?

**CIDR** (Classless Inter-Domain Routing) est une notation compacte pour représenter une adresse IP et son masque de sous-réseau.

> [!info] Syntaxe CIDR **Adresse_IP/Nombre_de_bits_à_1**
> 
> Exemple : `192.168.1.0/24`

Le nombre après le slash (/) indique **combien de bits sont à 1** dans le masque de sous-réseau (en partant de la gauche).

### Table de correspondance CIDR

|CIDR|Masque décimal|Notation binaire|Bits réseau|Bits hôte|
|---|---|---|---|---|
|/8|255.0.0.0|11111111.00000000.00000000.00000000|8|24|
|/16|255.255.0.0|11111111.11111111.00000000.00000000|16|16|
|/24|255.255.255.0|11111111.11111111.11111111.00000000|24|8|
|/25|255.255.255.128|11111111.11111111.11111111.10000000|25|7|
|/26|255.255.255.192|11111111.11111111.11111111.11000000|26|6|
|/27|255.255.255.224|11111111.11111111.11111111.11100000|27|5|
|/28|255.255.255.240|11111111.11111111.11111111.11110000|28|4|
|/29|255.255.255.248|11111111.11111111.11111111.11111000|29|3|
|/30|255.255.255.252|11111111.11111111.11111111.11111100|30|2|
|/31|255.255.255.254|11111111.11111111.11111111.11111110|31|1|
|/32|255.255.255.255|11111111.11111111.11111111.11111111|32|0|

> [!example] Exemples d'utilisation
> 
> - `10.0.0.0/8` : grand réseau d'entreprise (16 777 214 hôtes)
> - `172.16.0.0/16` : réseau de campus (65 534 hôtes)
> - `192.168.1.0/24` : réseau local typique (254 hôtes)
> - `192.168.1.0/30` : liaison point-à-point (2 hôtes)
> - `192.168.1.10/32` : une seule adresse IP spécifique

### Avantages de la notation CIDR

1. **Concision** : `192.168.1.0/24` au lieu de `192.168.1.0 masque 255.255.255.0`
2. **Flexibilité** : permet des masques de n'importe quelle longueur (pas limité aux classes)
3. **Agrégation de routes** : simplifie les tables de routage
4. **Standard universel** : utilisé dans toute la configuration réseau moderne

> [!tip] Conversion rapide Pour convertir CIDR en masque décimal, retiens ces valeurs pour le dernier octet :
> 
> - /25 = 128
> - /26 = 192
> - /27 = 224
> - /28 = 240
> - /29 = 248
> - /30 = 252

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> - **Ne pas confondre** `/24` (masque) avec `.24` (partie de l'adresse)
> - `/32` désigne **une seule adresse**, pas un réseau
> - Plus le nombre CIDR est **grand**, moins il y a d'hôtes disponibles
> - Un réseau en `/8` est **plus grand** qu'un réseau en `/24`

---

## 🔢 Calcul du nombre d'hôtes disponibles

### Formule de base

Le nombre d'hôtes disponibles dans un réseau dépend du nombre de bits réservés à la partie hôte :

> [!info] Formule **Nombre d'hôtes = 2^n - 2**
> 
> Où **n** = nombre de bits à 0 dans le masque (bits hôte)

On retire **2** car :

1. L'**adresse réseau** (tous les bits hôte à 0) : identifie le réseau lui-même
2. L'**adresse de broadcast** (tous les bits hôte à 1) : pour communiquer avec tous les hôtes

> [!example] Exemple avec /24 Réseau : `192.168.1.0/24`
> 
> - Masque : 255.255.255.0
> - Bits réseau : 24
> - Bits hôte : 32 - 24 = **8 bits**
> - Calcul : 2^8 - 2 = 256 - 2 = **254 hôtes**

### Table de calcul rapide

|CIDR|Bits hôte|Calcul|Hôtes disponibles|Usage typique|
|---|---|---|---|---|
|/8|24|2^24 - 2|16 777 214|Très grand réseau d'entreprise|
|/16|16|2^16 - 2|65 534|Réseau de campus|
|/17|15|2^15 - 2|32 766|Grande subdivision|
|/18|14|2^14 - 2|16 382||
|/19|13|2^13 - 2|8 190||
|/20|12|2^12 - 2|4 094||
|/21|11|2^11 - 2|2 046||
|/22|10|2^10 - 2|1 022||
|/23|9|2^9 - 2|510||
|/24|8|2^8 - 2|254|Réseau local standard|
|/25|7|2^7 - 2|126|Petit département|
|/26|6|2^6 - 2|62|Salle de réunion|
|/27|5|2^5 - 2|30|Petit bureau|
|/28|4|2^4 - 2|14|Très petit segment|
|/29|3|2^3 - 2|6|Groupe de serveurs|
|/30|2|2^2 - 2|2|Liaison point-à-point|
|/31|1|2^1 - 2|0*|Liaison point-à-point spéciale (RFC 3021)|
|/32|0|2^0 - 2|0|Adresse unique (hôte)|

> [!info] Cas particulier du /31 Le **/31** est un cas spécial défini par la RFC 3021 pour les liaisons point-à-point où on n'a pas besoin d'adresse réseau ni broadcast. Les 2 adresses sont utilisables pour les équipements.

### Méthode de calcul rapide

Pour calculer mentalement :

1. **Trouver les bits hôte** : 32 - CIDR
2. **Calculer 2^n** :
    - 2^8 = 256
    - 2^7 = 128
    - 2^6 = 64
    - 2^5 = 32
    - 2^4 = 16
    - 2^3 = 8
    - 2^2 = 4
3. **Soustraire 2**

> [!tip] Astuce de mémorisation Retiens ces valeurs clés :
> 
> - **/24** = 254 hôtes (réseau typique)
> - **/25** = 126 hôtes (moitié d'un /24)
> - **/26** = 62 hôtes (quart d'un /24)
> - **/30** = 2 hôtes (liaison entre 2 routeurs)

### Exemples pratiques

> [!example] Exemple 1 : Réseau d'entreprise Une entreprise a le réseau `10.50.0.0/16`
> 
> - Bits hôte : 32 - 16 = 16
> - Hôtes : 2^16 - 2 = 65 534 hôtes
> - Suffisant pour une grande organisation

> [!example] Exemple 2 : Bureau à distance Un bureau distant a `192.168.10.128/26`
> 
> - Bits hôte : 32 - 26 = 6
> - Hôtes : 2^6 - 2 = 62 hôtes
> - Adapté pour ~50 employés

> [!example] Exemple 3 : Liaison routeur-routeur Connexion entre deux routeurs : `10.1.1.0/30`
> 
> - Bits hôte : 32 - 30 = 2
> - Hôtes : 2^2 - 2 = 2 hôtes
> - Parfait pour relier 2 équipements

### Choix du bon masque

Pour choisir le masque adapté :

1. **Estimer le nombre d'hôtes** nécessaires (avec marge de croissance ~30%)
2. **Trouver le n** tel que 2^n - 2 ≥ nombre d'hôtes
3. **Calculer le CIDR** : 32 - n

> [!warning] Pièges courants
> 
> - **Oublier le -2** dans le calcul (adresse réseau et broadcast)
> - **Ne pas prévoir de croissance** : toujours ajouter une marge
> - **Gaspiller des adresses** : un /24 (254 hôtes) pour 10 machines est inefficace
> - **Confusion** : un /24 a **plus** d'hôtes qu'un /25

---

## 🎯 Calcul de l'adresse réseau et broadcast

### Concepts fondamentaux

Dans chaque réseau, il existe trois types d'adresses importantes :

1. **Adresse réseau** : identifie le réseau (tous les bits hôte à 0)
2. **Adresses utilisables** : pour les machines du réseau
3. **Adresse de broadcast** : pour diffuser à tous (tous les bits hôte à 1)

> [!info] Structure d'un réseau
> 
> ```
> Réseau: 192.168.1.0/24
> 
> 192.168.1.0       ← Adresse réseau (réservée)
> 192.168.1.1       ← Première adresse utilisable
> 192.168.1.2       
> ...
> 192.168.1.253
> 192.168.1.254     ← Dernière adresse utilisable
> 192.168.1.255     ← Adresse de broadcast (réservée)
> ```

### Méthode 1 : Calcul avec la notation CIDR simple (/8, /16, /24)

Pour les masques "classiques" qui tombent sur les octets :

> [!example] /24 (255.255.255.0) IP quelconque : `192.168.1.50/24`
> 
> - **Adresse réseau** : remplacer le dernier octet par 0 → `192.168.1.0`
> - **Première IP utilisable** : adresse réseau + 1 → `192.168.1.1`
> - **Dernière IP utilisable** : adresse broadcast - 1 → `192.168.1.254`
> - **Adresse broadcast** : remplacer le dernier octet par 255 → `192.168.1.255`

> [!example] /16 (255.255.0.0) IP quelconque : `172.16.50.100/16`
> 
> - **Adresse réseau** : `172.16.0.0`
> - **Première IP utilisable** : `172.16.0.1`
> - **Dernière IP utilisable** : `172.16.255.254`
> - **Adresse broadcast** : `172.16.255.255`

> [!example] /8 (255.0.0.0) IP quelconque : `10.50.100.25/8`
> 
> - **Adresse réseau** : `10.0.0.0`
> - **Première IP utilisable** : `10.0.0.1`
> - **Dernière IP utilisable** : `10.255.255.254`
> - **Adresse broadcast** : `10.255.255.255`

### Méthode 2 : Calcul avec masques complexes

Pour les masques qui "coupent" un octet (ex: /25, /26, /27...), il faut calculer par blocs.

#### Étape 1 : Trouver la taille du bloc

La taille du bloc = 256 - valeur du dernier octet du masque

|CIDR|Masque|Dernier octet|Taille du bloc|
|---|---|---|---|
|/25|255.255.255.128|128|256 - 128 = 128|
|/26|255.255.255.192|192|256 - 192 = 64|
|/27|255.255.255.224|224|256 - 224 = 32|
|/28|255.255.255.240|240|256 - 240 = 16|
|/29|255.255.255.248|248|256 - 248 = 8|
|/30|255.255.255.252|252|256 - 252 = 4|

#### Étape 2 : Trouver l'adresse réseau

L'adresse réseau est un **multiple de la taille du bloc**.

> [!example] Exemple avec /26 IP donnée : `192.168.1.75/26`
> 
> - Masque : 255.255.255.192
> - Taille du bloc : 256 - 192 = 64
> - Multiples de 64 : 0, 64, 128, 192
> - 75 est entre 64 et 128
> - **Adresse réseau** : `192.168.1.64`
> - **Adresse broadcast** : 192.168.1.(64 + 64 - 1) = `192.168.1.127`
> - **Première IP utilisable** : `192.168.1.65`
> - **Dernière IP utilisable** : `192.168.1.126`

> [!example] Exemple avec /27 IP donnée : `10.20.30.156/27`
> 
> - Masque : 255.255.255.224
> - Taille du bloc : 256 - 224 = 32
> - Multiples de 32 : 0, 32, 64, 96, 128, 160, 192, 224
> - 156 est entre 128 et 160
> - **Adresse réseau** : `10.20.30.128`
> - **Adresse broadcast** : 10.20.30.(128 + 32 - 1) = `10.20.30.159`
> - **Première IP utilisable** : `10.20.30.129`
> - **Dernière IP utilisable** : `10.20.30.158`

> [!example] Exemple avec /30 IP donnée : `172.16.10.17/30`
> 
> - Masque : 255.255.255.252
> - Taille du bloc : 256 - 252 = 4
> - Multiples de 4 : 0, 4, 8, 12, 16, 20, 24...
> - 17 est entre 16 et 20
> - **Adresse réseau** : `172.16.10.16`
> - **Adresse broadcast** : 172.16.10.(16 + 4 - 1) = `172.16.10.19`
> - **Première IP utilisable** : `172.16.10.17`
> - **Dernière IP utilisable** : `172.16.10.18`

### Méthode 3 : Calcul binaire (méthode universelle)

Pour n'importe quel masque, la méthode binaire fonctionne toujours :

#### Pour l'adresse réseau :

1. Convertir l'IP et le masque en binaire
2. Faire un **ET logique** (AND) bit à bit
3. Reconvertir en décimal

> [!example] Exemple IP : `192.168.1.75/26`
> 
> ```
> IP:      192  .  168  .    1  .   75
> Binaire: 11000000.10101000.00000001.01001011
> 
> Masque:  255  .  255  .  255  .  192
> Binaire: 11111111.11111111.11111111.11000000
> 
> AND:     11000000.10101000.00000001.01000000
> Réseau:  192  .  168  .    1  .   64
> ```

#### Pour l'adresse de broadcast :

1. Partir de l'adresse réseau
2. Mettre tous les bits hôte à **1**
3. Reconvertir en décimal

> [!example] Suite de l'exemple
> 
> ```
> Réseau:    11000000.10101000.00000001.01000000
>                                       ↑↑↑↑↑↑
>                                    bits hôte
> 
> Broadcast: 11000000.10101000.00000001.01111111
> Décimal:   192  .  168  .    1  .  127
> ```

### Tableau récapitulatif pour /24 subdivisé

|Sous-réseau|CIDR|Adresse réseau|Broadcast|Plage utilisable|Nb hôtes|
|---|---|---|---|---|---|
|1|/25|192.168.1.0|192.168.1.127|.1 à .126|126|
|2|/25|192.168.1.128|192.168.1.255|.129 à .254|126|
|||||||
|1|/26|192.168.1.0|192.168.1.63|.1 à .62|62|
|2|/26|192.168.1.64|192.168.1.127|.65 à .126|62|
|3|/26|192.168.1.128|192.168.1.191|.129 à .190|62|
|4|/26|192.168.1.192|192.168.1.255|.193 à .254|62|

### Méthode rapide de vérification

Pour vérifier si deux adresses IP sont dans le même réseau :

1. Appliquer le masque (AND) aux deux adresses
2. Si le résultat est identique → même réseau
3. Sinon → réseaux différents

> [!example] Vérification IP1 : `192.168.1.75/26` et IP2 : `192.168.1.90/26`
> 
> - IP1 AND masque = 192.168.1.64
> - IP2 AND masque = 192.168.1.64
> - **Même réseau** ✓
> 
> IP3 : `192.168.1.150/26`
> 
> - IP3 AND masque = 192.168.1.128
> - **Réseau différent** ✗

### Astuces pratiques

> [!tip] Astuces de calcul rapide
> 
> 1. **Pour /30** : les réseaux sont de 4 en 4 (0, 4, 8, 12, 16...)
> 2. **Pour /29** : les réseaux sont de 8 en 8 (0, 8, 16, 24...)
> 3. **Pour /27** : les réseaux sont de 32 en 32 (0, 32, 64, 96...)
> 4. **Pour /26** : les réseaux sont de 64 en 64 (0, 64, 128, 192)
> 5. **Pour /25** : deux réseaux seulement (0 et 128)

> [!warning] Erreurs courantes
> 
> - **Utiliser l'adresse réseau** pour un hôte (ex: configurer 192.168.1.0 sur une machine)
> - **Utiliser l'adresse broadcast** pour un hôte (ex: 192.168.1.255)
> - **Oublier** que la première IP utilisable = réseau + 1
> - **Oublier** que la dernière IP utilisable = broadcast - 1
> - **Confondre** la taille du réseau et la plage d'adresses utilisables

---

## 🎓 Synthèse générale

### Points clés à retenir

1. **Le masque de sous-réseau** sépare une adresse IP en partie réseau et partie hôte
2. **La notation CIDR** (/X) indique le nombre de bits à 1 dans le masque
3. **Le nombre d'hôtes** = 2^(bits hôte) - 2
4. **L'adresse réseau** a tous les bits hôte à 0
5. **L'adresse broadcast** a tous les bits hôte à 1
6. **Les adresses utilisables** sont entre l'adresse réseau et le broadcast (exclus)

### Règles d'or

> [!tip] Mémorisez ces règles
> 
> - Plus le CIDR est **grand** (/30), moins il y a d'hôtes
> - Plus le CIDR est **petit** (/8), plus il y a d'hôtes
> - Un réseau en **/24 = 254 hôtes** (à retenir absolument)
> - Un réseau en **/30 = 2 hôtes** (liaisons point-à-point)
> - Toujours soustraire **2** du total pour obtenir les hôtes utilisables

### Méthode de travail recommandée

1. **Identifier le CIDR** de l'adresse
2. **Calculer les bits hôte** : 32 - CIDR
3. **Trouver la taille du bloc** : 256 - valeur du dernier octet du masque
4. **Déterminer l'adresse réseau** : multiple de la taille du bloc
5. **Calculer le broadcast** : réseau + taille du bloc - 1
6. **Déduire la plage utilisable** : réseau+1 à broadcast-1

---

_Cours créé pour une utilisation avec Obsidian - Partie 3 : Masques de sous-réseau et CIDR_