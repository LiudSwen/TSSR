---
title: "Système binaire et hexadécimal - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2041/pages/11638"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Système binaire et hexadécimal

Facile

3 pairs

Réseau

## Système binaire et hexadécimal

```
Introduction
```

Notre système de numération usuel est le système décimal. C'est un système de numération comprenant 10 chiffres de 0 à 9, soit 10 symboles différents pour compter.  
En informatique, 2 autres systèmes de numération sont couramment utilisés:

- Le système binaire
- Le système hexadécimal

![image](https://culture-informatique.net/wp-content/uploads/2017/08/ID-100280536.jpg)

## 🤓 Objectifs:

✅ Découvrir les systèmes de numération binaire et hexadécimal  
✅ Savoir compter en binaire  
✅ Savoir compter en hexadécimal  
✅ Savoir convertir des nombres d'une base à une autre

## Sommaire

- [📖 Systèmes de numération](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#-syst%C3%A8mes-de-num%C3%A9ration)
- [📖 Le système binaire (base 2)](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#-le-syst%C3%A8me-binaire-base-2)
	- [Intérêt de la conversion binaire](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#int%C3%A9r%C3%AAt-de-la-conversion-binaire)
		- [Compter en binaire](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#compter-en-binaire)
		- [Conversion décimale vers binaire (méthode 1):](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#conversion-d%C3%A9cimale-vers-binaire-m%C3%A9thode-1-)
		- [Conversion décimale vers binaire (méthode 2):](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#conversion-d%C3%A9cimale-vers-binaire-m%C3%A9thode-2-)
		- [Conversion binaire vers décimale](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#conversion-binaire-vers-d%C3%A9cimale)
		- [Calculer une somme en binaire](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#calculer-une-somme-en-binaire)
- [📖 Le système hexadécimal (base 16)](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#-le-syst%C3%A8me-hexad%C3%A9cimal-base-16)
	- [Intérêt de la conversion en hexadécimal](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#int%C3%A9r%C3%AAt-de-la-conversion-en-hexad%C3%A9cimal)
		- [Compter en hexadécimal](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#compter-en-hexad%C3%A9cimal)
		- [Conversion binaire vers hexadécimal](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#conversion-binaire-vers-hexad%C3%A9cimal)
		- [1\. Méthode d'écriture du binaire](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#1-m%C3%A9thode-d%C3%A9criture-du-binaire)
				- [2\. Conversion des groupes de nombres binaires](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#2-conversion-des-groupes-de-nombres-binaires)
		- [Conversion hexadécimal vers binaire](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#conversion-hexad%C3%A9cimal-vers-binaire)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2041/pages/11638#-crit%C3%A8res-dacceptation)

## 📖 Systèmes de numération

Un système de numération est un moyen de représenter des nombres. Il est généralement défini par une base, qui est le nombre de chiffres distincts utilisés dans ce système. Les systèmes de numération les plus couramment utilisés dans l'informatique sont le **système décimal** (base 10), le **système binaire** (base 2) et le **système hexadécimal** (base 16).

## 📖 Le système binaire (base 2)

Le système binaire n'utilise que deux chiffres, 0 et 1.  
Chaque position dans un nombre binaire représente une puissance de 2.  
En informatique, c'est le bit, l'unité élémentaire qui prend les valeurs 0 ou 1 qui utilise ce système.

## Intérêt de la conversion binaire

Cette conversion est fondamentale car les ordinateurs eux-mêmes opèrent en binaire. Toutes les données, que ce soit du texte, des images, de l'audio ou des instructions de programme, sont stockées et manipulées sous forme binaire.

Quelques exemples pour lesquels cette conversion entre en jeu:

- Les adresses IP
- Le chiffrement
- Le codage des caractères

## Compter en binaire

Pour commencer: une explication en vidéo plutôt ludique!

À titre d'exemple: un tableau contenant tous les nombres qu'on peut représenter en binaire avec au plus 4 chiffres et leur équivalent en décimal:

| Décimal | Binaire | Explications |
| --- | --- | --- |
| 0 | 0000 | Logique! |
| 1 | 0001 | Simple! |
| 2 | 0010 | Le premier rang (chiffre le plus à droite) est au maximum autorisé (un 1), on passe au rang suivant. On met le second à 1 et on remet le premier à 0 |
| 3 | 0011 | On re-remplit le rang 1 |
| 4 | 0100 | Les rangs 1 et 2 sont plein, on passe au rang 3 et on remet les précédents à 0 |
| 5 | 0101 |  |
| 6 | 0110 |  |
| 7 | 0111 |  |
| 8 | 1000 | On entame le quatrième rang |
| 9 | 1001 | On recommence au premier |
| 10 | 1010 | ... |
| 11 | 1011 |  |
| 12 | 1100 |  |
| 13 | 1101 |  |
| 14 | 1110 |  |
| 15 | 1111 |  |

## Conversion décimale vers binaire (méthode 1):

Pour convertir un nombre décimal en binaire, une méthode consiste à diviser le nombre par 2 et à noter le reste, puis à continuer à diviser jusqu'à ce que le quotient soit 0.

Exemple avec le nombre 35:

- 35 divisé par 2 donne 17 et il reste 1
- 17 divisé par 2 donne 8 et il reste 1
- 8 divisé par 2 donne 4 et il reste 0
- 4 divisé par 2 donne 2 et il reste 0
- 2 divisé par 2 donne 1 et il reste 0
- 1 divisé par 2 donne 0 et il reste 1

Si tu lis les "restes" de bas en haut, tu as **100011** en binaire.  
Donc, 35 en décimale (base 10) donne 100011 en binaire (base 2).

## Conversion décimale vers binaire (méthode 2):

Une autre méthode consiste à utiliser ce tableau:

| Puissance de 2 | $2^7$ | $2^6$ | $2^5$ | $2^4$ | $2^3$ | $2^2$ | $2^1$ | $2^0$ |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Valeur | 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |

Il faut décomposer le nombre en puissance de 2:

35 = 32 + 2 + 1  
35 = **0** x 128 + **0** x 64 + **1** x 32 + **0** x 16 + **0** x 4 + **1** x 2 + **1** x 1

En lisant les chiffres **0** et **1** de la gauche vers la droite, on a **0010011**.

```
Dans la méthode 1 on a trouvé que 35 en décimal est équivalent à 100011 en binaire.

Dans la méthode 2 on a trouvé que c'est équivalent à 0010011.

Dans le deuxième cas, les deux 0 devant 10011 ne comptent pas.
```

## Conversion binaire vers décimale

La méthode la plus simple est d'utiliser le tableau des puissances de 2 vu sur le chapitre précédent.  
Il suffit de multiplier chaque chiffre du nombre binaire par la valeur de la puissance de 2 à laquelle il correspond.

Exemple pour le nombre binaire 10011010, si on le place dans le tableau des puissances de 2:

| Puissance de 2 | $2^7$ | $2^6$ | $2^5$ | $2^4$ | $2^3$ | $2^2$ | $2^1$ | $2^0$ |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Valeur | 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |
| Nombre en binaire | 1 | 0 | 0 | 1 | 1 | 0 | 1 | 0 |
| Calcul | 1 x 128 | 0 x 64 | 0 x 32 | 1 x 16 | 1 x 8 | 0 x 4 | 1 x 2 | 0 x 1 |

Donc le résultat de la conversion sera:

1 x 128 + 0 x 64 + 0 x 32 + 1 x 16 + 1 x 8 + 0 x 4 + 1 x 2 + 0 x 1 = 128 + 16 + 8 + 2 = **154**

## Calculer une somme en binaire

Exemple avec le calcul de 39 + 1  
![image](https://culture-informatique.net/wp-content/uploads/2012/10/calcul-binaire.png)

## 📖 Le système hexadécimal (base 16)

Le système hexadécimal utilise seize chiffres distincts:

- Tout d'abord les chiffres de 0 à 9
- Puis les lettres de A à F (pour représenter les valeurs de 10 à 15)

Chaque position dans un nombre hexadécimal représente une puissance de 16.

> Norme d'écriture:  
> Le nombre hexadécimal 3CF peut s'écrire des façons suivantes:
> 
> - $3CF_{(hexa)}$
> - 0x3CF  
> 	Ces notation sont très utile sur des nombres tendancieux comme 101 par exemple.  
> 	Comment savoir si 101 est en base 10 (décimal), en base 2 (binaire), ou bien en base 16 (hexadécimal)?  
> 	Si on estime que 101 est en base 16, on a:  
> 	$101_{(hexa)}$ = $257_{(decimal)}$ = $1 0000 0001_{(binaire)}$ ==> 0x101

## Intérêt de la conversion en hexadécimal

En informatique il est assez utile de savoir convertir les valeurs de différentes bases en d'autres bases.  
Les plus courantes sont binaires en hexadécimales et vice-versa.

Par exemple, dans le cas d'une adresse IPV6, il est plus "simple" de retenir **2001:861:3140:3571:8f53:ac8a:8939:76aa** que **0010000000000001:0000100001100001:0011000101000000:0011010101110001:1000111101010011:1010110010001010:1000100100111001:0111011010101010**

## Compter en hexadécimal

- Une petite vidéo pour commencer:
- Les premiers chiffres:

| Décimal | Hexadécimal |
| --- | --- |
| 0 | 0 |
| 1 | 1 |
| 2 | 2 |
| 3 | 3 |
| 4 | 4 |
| 5 | 5 |
| 6 | 6 |
| 7 | 7 |
| 8 | 8 |
| 9 | 9 |
| 10 | A |
| 11 | B |
| 12 | C |
| 13 | D |
| 14 | E |
| 15 | F |
| 16 | 10 |
| 17 | 11 |
| 18 | 12 |
| 19 | 13 |
| 20 | 14 |

## Conversion binaire vers hexadécimal

### 1\. Méthode d'écriture du binaire

Cette première étape est simple, il suffit de toujours prendre des regroupements de 4 bits.

Exemple 1:  
$1_{(binaire)}$ = 0001  
$101_{(binaire)}$ = 0101  
Lorsque tu as moins de 4 bits, tu rajoutes des zéros devant pour atteindre le nombre de 4 bits demandé.

Exemple 2:  
$10011011_{(binaire)}$ = 1001 1011  
$111001_{(binaire)}$ = 0011 1001  
Lorsque tu as plus de 4 bits, tu mets des espaces pour séparer tous les paquets de 4 bits (n'oublie pas de rajouter des zéros s'il le faut).

Exemple 3:  
$1110101110011011_{(binaire)}$ = 1110 1011 1001 1011  
Comme pour l'exemple 2, il faut mettre des espaces pour faciliter la lecture et le calcul à venir.

### 2\. Conversion des groupes de nombres binaires

Un tableau de conversion utile:

| Décimal | Hexadécimal | Binaire |
| --- | --- | --- |
| 0 | 0 | 0000 |
| 1 | 1 | 0001 |
| 2 | 2 | 0010 |
| 3 | 3 | 0011 |
| 4 | 4 | 0100 |
| 5 | 5 | 0101 |
| 6 | 6 | 0110 |
| 7 | 7 | 0111 |
| 8 | 8 | 1000 |
| 9 | 9 | 1001 |
| 10 | A | 1010 |
| 11 | B | 1011 |
| 12 | C | 1100 |
| 13 | D | 1101 |
| 14 | E | 1110 |
| 15 | F | 1111 |

Il faut prendre chaque regroupement de 4 bits et faire la correspondance entre le binaire et l'hexadécimal.

Exemple 1:  
$0001_{(binaire)}$ = $1_{(hexa)}$  
$0110_{(binaire)}$ = $6_{(hexa)}$  
$1011_{(binaire)}$ = $B_{(hexa)}$  
Dans chacun des exemples ci dessus, il suffit juste de consulter le tableau de conversion.

Exemple 2:  
$10_{(binaire)}$ = $0010_{(binaire)}$ = $2_{(hexa)}$  
$110_{(binaire)}$ = $0110_{(binaire)}$ = $6_{(hexa)}$  
Il ne faut pas que tu oublie de rajouter des 0 lorsqu'il y a moins de 4 bits.

Exemple 3:  
$1011 1001 0011_{(binaire)}$ = $B93_{(hexa)}$  
Explication:  
$1011_{(binaire)}$ = $B_{(hexa)}$  
$1001_{(binaire)}$ = $9_{(hexa)}$  
$0011_{(binaire)}$ = $3_{(hexa)}$  
Il faut bien faire la conversion de chaque petit regroupement pour réussir son coup.

## Conversion hexadécimal vers binaire

**C'est exactement la même chose mais dans l'autre sens!**

---

## 💪 Challenge

Répondre correctement aux questions ci-dessous:

1. Que vaut $5B1_{(hexa)}$ en base 2?
2. Que vaut 0xA en décimal?
3. En hexadécimal, quelles sont les valeurs maximales et minimales que l'on peut représenter sur 1 octets?
4. Donner la représentation binaire et hexadécimale de l'adresse IP 192.168.1.80

## 🧐 Critères d'acceptation

- Répondre correctement aux 4 questions sous forme de fichier markdown

Solution postée le **mardi 11 novembre 2025**

**Que vaut 5B1 en base 2?**  
0101 1011 0001

**Que vaut 0xA en décimal?**  
10

**En hexadécimal, quelles sont les valeurs maximales et minimales que l'on peut représenter sur 1 octets?**  
Maximales: 0xFF | Minimales: 0x00

**Donner la représentation binaire et hexadécimale de l'adresse IP 192.168.1.80**  
Binaire: 11000000.10101000.00000001.01010000  
Hexadécimal: C0.A8.01.50