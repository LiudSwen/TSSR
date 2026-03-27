---
title: "Découpage de réseaux IP - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2277/pages/10608"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Découpage de réseaux IP

Moyen

2h

3 pairs

Réseau

## Découpage de réseaux IP

```shell
Introduction
```

Les réseaux sont très souvent constitués de sous-réseaux. Chaque sous-réseaux ne peut communiquer avec les autres qu'en passant par des intermédiaires qu'on appelle des routeurs.

## 🤓Objectifs:

✅ Connaître les différents types de découpe de réseaux IP  
✅ Savoir déterminer un CIDR, une adresse de réseaux, et une adresse de diffusion

## Sommaire

- [👉 Pourquoi faire des sous-réseaux?](https://odyssey.wildcodeschool.com/quests/2277/pages/10608#-pourquoi-faire-des-sous-r%C3%A9seaux-)
- [👉 Calcul du nombre d'hôtes disponibles](https://odyssey.wildcodeschool.com/quests/2277/pages/10608#-calcul-du-nombre-dh%C3%B4tes-disponibles)
	- [🔬 Exercice de calcul du nombre d’hôtes](https://odyssey.wildcodeschool.com/quests/2277/pages/10608#-exercice-de-calcul-du-nombre-dh%C3%B4tes)
- [👉 Le découpage symétrique](https://odyssey.wildcodeschool.com/quests/2277/pages/10608#-le-d%C3%A9coupage-sym%C3%A9trique)
- [👉 Le découpage asymétrique](https://odyssey.wildcodeschool.com/quests/2277/pages/10608#-le-d%C3%A9coupage-asym%C3%A9trique)
	- [Pour aller plus loin](https://odyssey.wildcodeschool.com/quests/2277/pages/10608#pour-aller-plus-loin)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2277/pages/10608#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2277/pages/10608#-crit%C3%A8res-dacceptation)

## 👉 Pourquoi faire des sous-réseaux?

Les raisons derrière ce type de découpage remontent aux premières spécifications d'IP - où il n'y avait que quelques sites fonctionnant sur des numéros de réseau de classe A, ce qui permettait des millions d'hôtes connectés.

```shell
Pour rappel, les adresses de classe A vont de 10.0.0.0 à 10.255.255.255 .

On n'utilise plus les classes de nos jours, mais la notation CIDR.
```

**Problème**: c'est évidemment un trafic énorme et des problèmes d'administration si tous les ordinateurs IP d'un important site doivent être connectés sur le même réseau: essayer de gérer un tel monstre serait un cauchemar et le réseau s'écroulerait (de manière quasi-certaine) sous la charge de son propre trafic (saturé).

**La solution**: arrive le découpage en sous-réseaux!  
L'adresse de réseau de classe A peut être découpée pour permettre sa distribution à plusieurs (voire beaucoup de) réseaux séparés. La gestion de chaque réseau séparé peut facilement être déléguée de la même façon.  
Cela permet d'établir des réseaux petits et gérables avec des technologies de réseaux différentes (comme Ethernet, WiFi, ATM...) qui peuvent être interconnectés.  
Cette interconnexion de réseaux divers et variés est une des base de la création d'Internet.

En plus d'une facilité de gestion, voici quelques raisons supplémentaire pour vous convaincre de découper vos réseaux:

- La topographie d'un site peut créer des restrictions (longueur de câble) sur les possibilités de connexion de l'infrastructure physique, nécessitant des réseaux multiples. Le découpage en sous-réseaux permet de le faire dans un environnement IP en n'utilisant qu'un seul numéro de réseau IP.
- Des nécessités de sécurité peuvent très bien imposer que les différentes classes d'utilisateurs ne partagent pas le même réseau - puisque le trafic d'un réseau peut toujours être intercepté par un utilisateur compétent. Le découpage en sous-réseaux donne un moyen d'empêcher que le département marketing espionne le trafic sur le réseau de R & D (ou que les étudiants espionnent le réseau de l'administration)!

On va trouver des réseaux à découpages **symétrique** et **asymétrique**.

## 👉 Calcul du nombre d'hôtes disponibles

Cela revient à calculer combien d’adresses sont disponibles pour adresser des machines sur le réseau. Ces machines ont alors toutes le même masque de sous-réseau (et donc le même suffixe CIDR).  
Prenons l'exemple de l'IPv4 privée `192.168.10.0/24`.  
Le masque en `/24` signifie que les 24 premiers bits sont à 1. Il y a 8 bits dans 1 octet. Comme 3x8=24, les 3 premiers octets sont à 1, et donc ils ne seront pas pris en compte.  
Pour cette adresse, l'identifiant de réseau est `192.168.10` et l'identifiant d'hôte est sur le dernier octet.  
Les valeurs de ce dernier octet vont de 0 à 255, or:

- Je dois garder la première adresse, ici `192.168.10.0` car c'est **l'adresse de réseau**.
- Je dois garder la dernière adresse, ici `192.168.10.255` car c'est **l'adresse de diffusion** (ou adresse de *broadcast*).  
	Les adresses disponibles iront donc de `192.168.10.1` à `192.168.10.254`, soit 254 adresses disponibles.
```shell
L'adresse du réseau est la tout première adressable sur la plage d'adresse IPv4

L'adresse de diffusion (Broadcast) est la toute dernière adressable.

Ces deux adresses ne peuvent être attribuée à un équipement.
```

## 🔬 Exercice de calcul du nombre d’hôtes

Si on prend le réseau 172.16.0.0/16, quels est:

1. Le nombre d'adresses en tout sur ce réseau.
2. Le nombre d'adresses disponible pour des équipements, ainsi que la plage d'adresses associée.
```shell
Si vraiment tu n'arrive pas à trouver la solution tu peux
Le /16 indique un masque 255.255.0.0 où les 2 premiers octets sont à 1. Donc seul les 2 derniers octets sont utilisés.

Le 3ème octet a des valeurs de 0 à 255. De même pour le 4ème octet.

On aura donc 256 x 256 = 65536 adresses en tout pour ce réseau.
On va enlever la première adresse IP (adresse de réseau), qui est 172.16.0.0 et la dernière adresse (adresse de broadcast), qui est 172.16.255.255.

Donc au aura 65536 - 2 = 65534 adresses disponibles pour des équipements, pour des adresses allant de 172.16.0.1 à 172.16.255.254.
Cliquer ici
```

## 👉 Le découpage symétrique

On prend le contexte suivant: une école d'informatique a 4 départements pédagogique et on doit avoir un réseau informatique pour chacun.  
Voilà les 4 départements:

1. Développement Web
2. Data et IA
3. Infra et cybersécurité
4. Design produit

On reprend le réseau vu plus haut, `192.168.10.0/24`. On le découpe en `4` sous-réseaux de taille identique.  
Chacun de ces sous-réseaux doivent accueillir au moins `25` équipements adressables

On cherche dans le tableau des puissances de `2` ci-dessous le nombre supérieur à 25 et la puissance de 2 associée:

| 2^0 | 2^1 | 2^2 | 2^3 | 2^4 | 2^5 | 2^6 | 2^7 | 2^8 | 2^9 | 2^10 | 2^11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512 | 1024 | 2048 |

Le nombre supérieur à 25 est ici 32, donc la puissance de 2 associée est `2` puissance `5`.  
Cela donne le nombre d'adresses IP disponible au total, soit `32`.

```shell
Attention ! Ne pas oublier de soustraire obligatoirement 2 adresses qui sont essentielles pour le bon fonctionnement d'un réseau : l'adresse du réseau (la première de la plage) et l'adresse de diffusion ou broadcast en anglais (la dernière de la plage).
```

Le nombre d’adresses disponibles, c'est-à-dire celles que l'on peut attribuer, se calcule comme suit: `2^(nombre de bits hôte) – 2`  
Ici le `nombre de bits hôte` est égal à 5.

Donc `2` puissance `5`, soit `32`, moins les `2` adresses (réseau et diffusion), donne un total de `30`.  
On a donc `30` adresses IP disponibles sur chaque sous-réseaux.

Le **CIDR** se calcul par `32 - nombre de bits hôte`, soit ici 32 - 5, donc 27.  
Le CIDR est donc `/27`.

```shell
On calcul le CIDR en prenant le chiffre de la puissance, soit ici pour 2 puissance 5, le CIDR sera de 32 - 5 soit 27.
```

Pour le réseau `192.168.10.0/24` on peut faire les 4 sous-réseaux suivants:

**Sous-réseau 1: Développement Web**  
Adresse de réseau: `192.168.10.0/27`  
Début de plage IP disponible: `192.168.10.1`  
Fin de plage IP disponible: `192.168.10.30`  
Adresse de broadcast: `192.168.0.31`

**Sous-réseau 2: Data et IA**  
Adresse de réseau: `192.168.10.32/27`  
Début de plage IP disponible: `192.168.10.33`  
Fin de plage IP disponible: `192.168.10.62`  
Adresse de broadcast: `192.168.10.63`

**Sous-réseau 3: Infra et cybersécurité**  
Adresse de réseau: `192.168.10.64/27`  
Début de plage IP disponible: `192.168.10.65`  
Fin de plage IP disponible: `192.168.10.94`  
Adresse de broadcast: `192.168.10.95`

**Sous-réseau 4: Design produit**  
Adresse de réseau: `192.168.10.96/27`  
Début de plage IP disponible: `192.168.10.97`  
Fin de plage IP disponible: `192.168.10.126`  
Adresse de broadcast: `192.168.10.127`

Si on synthétise tout ça dans un tableau, ça donne cela:

|  | Adresse réseau | Adresse de broadcast | Adresse de début de plage | Adresse de fin de plage |
| --- | --- | --- | --- | --- |
| Développement Web | 192.168.10.0/27 | 192.168.10.31 | 192.168.10.1 | 192.168.10.30 |
| Data et IA | 192.168.10.32/27 | 192.168.10.63 | 192.168.10.33 | 192.168.10.62 |
| Infra et cybersécurité | 192.168.10.64/27 | 192.168.10.95 | 192.168.10.65 | 192.168.10.94 |
| Design produit | 192.168.10.96/27 | 192.168.10.127 | 192.168.10.97 | 192.168.10.126 |

> Essaye de refaire cet exemple en comprenant la méthode

## 👉 Le découpage asymétrique

Dans le découpage asymétrique, chaque sous-réseaux possède une taille différente.  
La méthode de calcul est la même mais pour chaque sous-réseaux.

Une méthode consiste à commencer par le sous-réseaux qui va contenir le plus d'équipements. Cela permet de minimiser le gaspillage d'adresses IP.  
Par exemple si j'ai un segment de réseau avec 28 adresses IP et deux autres qui en ont 80 et 16, on va traiter le réseau avec 80 adresses IP, puis celui avec 28, et enfin celui avec 16 adresses IP.

Si on reprend l'école d'informatique vu ci-dessous, composées de 4 départements **Développement Web**, **Data et IA**, **Infra et cybersécurité**, et **Design produit**, cette fois-ci, le nombre d'équipements réseaux est différents dans chaque sous-réseaux:

- Développement Web (20 équipements)
- Data et IA (34 équipements)
- Infra et cybersécurité (15 équipements)
- Design produit (6 équipements)

On va cette fois-ci essayer d'affiner le nombre d'équipement au plus juste.  
En prenant la méthode de calcul avec le tableau des puissance de 2, on va chercher le résultat pour chaque sous-réseaux.

```shell
Pour rappel, Le nombre d’adresses disponibles à l’adressage se calcule comme suit : 2^(nbre bits hôte) – 2
2^02^12^22^32^42^52^62^72^82^92^102^11124816326412825651210242048
```

On cherche en premier le nombre d'hôte pour chaque département de la liste ci-dessus:

- Développement Web (20 équipements) --> 2^5 - 2 = 32 - 2 = 30
- Data et IA (34 équipements) --> 2^6 - 2 = 64 - 2 = 62
- Infra et cybersécurité (15 équipements) --> 2^5-2 = 32 - 2 = 30
- Design produit (6 équipements) --> 2^3 - 2 = 8 - 2 = 6

Les sous-réseaux seront dans cette ordre:

- Data et IA (62 hôtes)
- Développement Web (30 hôtes)
- Infra et cybersécurité (30 hôtes)
- Design produit (6 hôtes)
```shell
Pour les réseaux Développement Web et Infra et cybersécurité on peut les mettre dans n'importe quel ordre car ils peuvent contenir le même nombre d'hôtes.
```

Pour le réseau `192.168.10.0/24`, on a donc les 4 sous-réseaux suivants:

**Sous-réseau 1: Data et IA**  
Adresse de réseau: `192.168.10.0/26`  
Début de plage IP disponible: `192.168.10.1`  
Fin de plage IP disponible: `192.168.10.62`  
Adresse de broadcast: `192.168.10.63`

**Sous-réseau 2: Développement Web**  
Adresse de réseau: `192.168.10.64/27`  
Début de plage IP disponible: `192.168.10.65`  
Fin de plage IP disponible: `192.168.10.94`  
Adresse de broadcast: `192.168.10.95`

**Sous-réseau 3: Infra et cybersécurité**  
Adresse de réseau: `192.168.10.96/27`  
Début de plage IP disponible: `192.168.10.97`  
Fin de plage IP disponible: `192.168.10.126`  
Adresse de broadcast: `192.168.10.127`

**Sous-réseau 4: Design produit**  
Adresse de réseau: `192.168.10.128/29`  
Début de plage IP disponible: `192.168.10.129`  
Fin de plage IP disponible: `192.168.10.134`  
Adresse de broadcast: `192.168.10.135`

Donc cela donne:

|  | Adresse réseau | Adresse de broadcast | Adresse de début de plage | Adresse de fin de plage |
| --- | --- | --- | --- | --- |
| Data et IA | 192.168.10.0/26 | 192.168.10.63 | 192.168.10.1 | 192.168.10.62 |
| Développement Web | 192.168.10.64/27 | 192.168.10.95 | 192.168.10.65 | 192.168.10.94 |
| Infra et cybersécurité | 192.168.10.96/27 | 192.168.10.127 | 192.168.10.97 | 192.168.10.126 |
| Design produit | 192.168.10.128/29 | 192.168.10.135 | 192.168.10.129 | 192.168.10.134 |

---

## Pour aller plus loin

```shell
Les réseaux TCP/IP et l'adressage IPv4https://fr.wikibooks.org/wiki/R%C3%A9seaux_TCP/IP/Adressage_IP_v4
```

---

## 💪 Challenge

Une société fictive a 4 pôles informatiques. Le réseau est en **172.16.1.0/24**.  
Découper ce réseau de 2 manières, **symétrique** et **asymétrique**, pour que chaque pôle ci-dessous puissent avoir assez d'adresse pour chaque équipement.

Le Pôle informatique (6 bureaux, environ **50 équipements** au total)  
Le Pôle développement (6 bureaux, environ **12 équipements** au total)  
Le Pôle Administratif (4 bureaux, environ **20 équipements** au total)  
Le Pôle Technicien (4 bureaux, environ **15 équipements** au total)

- Effectuer le découpage réseau pour une entreprise en donnant la formule utilisée pour chaque réseau découpé ainsi que le CIDR qui lui correspond pour permettre d'adresser ses équipements.
- Calculer pour chaque réseau, l'adresse réseau et l'adresse de diffusion (Broadcast)
- Présenter ce découpage dans un fichier texte en markdown, à la suite, ou sous forme de tableau, et poster le dans la solution, par exemple en le publiant dans un [gist](https://gist.github.com/).

## 🧐 Critères d'acceptation

- Les différentes plages d'adresses sont valides
- Il y a assez de place dans chaque plage pour accueillir le nombre d'équipements prévus
- La méthode de calcul est expliquée clairement
- Les adresses de réseau et de diffusion sont correctes
- Il y a le résultats pour un découpage symétrique et pour un découpage asymétrique.

Solution postée le **jeudi 13 novembre 2025**

[https://gist.github.com/LiudSwen/e45f7ef5b07f22df8ee850f3c983fde4](https://gist.github.com/LiudSwen/e45f7ef5b07f22df8ee850f3c983fde4)