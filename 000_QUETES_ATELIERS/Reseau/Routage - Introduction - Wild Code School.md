---
title: "Routage - Introduction - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3964/pages/18631"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Routage - Introduction

Moyen

1h

Auto-validation

Réseau

## Routage - Introduction

## Sommaire

- [🔎 Concept de routage](https://odyssey.wildcodeschool.com/quests/3964/pages/18631#-concept-de-routage)
- [🌏 Routage statique et dynamique](https://odyssey.wildcodeschool.com/quests/3964/pages/18631#-routage-statique-et-dynamique)
	- [Cas d'utilisation des types de routage](https://odyssey.wildcodeschool.com/quests/3964/pages/18631#cas-dutilisation-des-types-de-routage)
		- [Routage statique ou dynamique? Les 2 chef!](https://odyssey.wildcodeschool.com/quests/3964/pages/18631#routage-statique-ou-dynamique--les-2-chef-)
		- [Le choix des routes](https://odyssey.wildcodeschool.com/quests/3964/pages/18631#le-choix-des-routes)
- [📑 La table de routage](https://odyssey.wildcodeschool.com/quests/3964/pages/18631#-la-table-de-routage)
- [🔩 Le routage statique](https://odyssey.wildcodeschool.com/quests/3964/pages/18631#-le-routage-statique)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/3964/pages/18631#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/3964/pages/18631#-quiz)

## 🔎 Concept de routage

## Principes généraux

Le routage est un processus essentiel des réseaux informatiques qui permet de **transférer des paquets de données entre différents réseaux**.  
Ce processus repose sur l’utilisation de **routeurs**, qui analysent les adresses IP de destination des paquets pour décider de leur itinéraire à travers un réseau ou une interconnexion de réseaux.

Les routeurs s’appuient sur des **tables de routage** pour prendre leurs décisions de routage. Cette table de routage contient des informations sur les chemins disponibles vers différents réseaux.

Lorsqu’un paquet arrive sur une interface de routeur, celui-ci:

1. Examine l’adresse IP de destination dans l’en-tête du paquet.
2. Recherche dans la table de routage une entrée correspondant à cette adresse ou à une plage d’adresses (préfixe IP).
3. Transmet le paquet vers le prochain routeur.

Et ainsi de suite... Chaque routeur sur le chemin réalise la même action, jusqu'à ce que le paquet arrive à destination ou qu'il soit abandonné. C'est le même processus qui est à l'oeuvre qu'il s'agisse de réseaux IPv4 ou IPv6 ou alors de réseaux privé ou public. Le processus de routage de paquet est universel dans les réseaux basés sur TCP/IP!

## Questions/réponses

***Si un paquet n'atteint jamais sa destination, le paquet circulera indéfiniment dans les réseaux?***

Si un paquet ne parvient jamais à atteindre sa destination, il ne restera pas indéfiniment sur le réseau grâce au champ [**TTL (Time To Live)**](https://fr.wikipedia.org/wiki/Time_to_Live) dans l’en-tête IP.  
Ce champ est initialisé avec une valeur par l’expéditeur (par exemple, 64 ou 128) et est décrémenté de 1 chaque fois que le paquet traverse un nœud, comme un routeur.  
Si le TTL atteint 0 avant que le paquet n'atteigne sa destination, il est automatiquement supprimé. De plus, le routeur qui effectue cette suppression renvoie un message ICMP "Time Exceeded" à l'expéditeur, l'informant que le paquet n’a pas pu aboutir. Ce mécanisme protège le réseau contre les paquets errants, notamment en cas de boucles de routage ou d’adresses inaccessibles.

***Comment le routeur apprend-il ces réseaux? Comment un routeur remplit-il sa table de routage?***

Cela dépend des réseaux.

- **Réseaux directement connectés**: Les réseaux directement connectés sont les réseaux accessibles via les interfaces actives d’un routeur, sans passer par un autre appareil intermédiaire. Lorsqu’une interface du routeur est configurée avec une **adresse IP** et un **masque de sous-réseau** (ou longueur de préfixe dans le cas d'IPv6), et que l’interface est **active** (statut `up/up`), **ce réseau est automatiquement ajouté à la table de routage**.
- **Réseaux distants**: Les réseaux distants désignent les réseaux qui ne sont pas directement accessibles via une interface locale du routeur. Pour atteindre ces réseaux, un routeur doit s’appuyer sur des informations supplémentaires pour acheminer correctement les paquets. Ces informations peuvent être obtenues de deux façons principales:
	- **Manuellement**, en utilisant des **routes statiques**. C'est toi, en tant qu'administrateur, qui entres les informations directement dans la table de routage.
		- **Dynamiquement**, grâce à un **protocole de routage dynamique**, où les routes sont apprises automatiquement sans que tu aies besoin d'intervenir.

***Mais du coup, les routeurs disposent-ils des informations pour joindre tous les réseaux de la planète?***

Non, ce n'est pas le cas! Les routeurs ne stockent pas les informations sur tous les réseaux existants dans le monde. Ils se contentent de conserver des routes pertinentes pour les réseaux qu'ils doivent atteindre, directement ou via d'autres routeurs. Par exemple, sur un réseau local ou une infrastructure d'entreprise, un routeur n'aura dans sa table de routage que les informations nécessaires à la connectivité interne et aux connexions externes requises.

***Que se passe-t-il s'il reçoit un paquet destiné à un réseau qu’il ne connaît pas?***

C'est très simple, il abandonne le paquet!

Pour éviter cela, il est essentiel de configurer une instruction clé: **la route par défaut**. Cette route spéciale indique au routeur où envoyer les paquets pour lesquels il ne trouve aucune correspondance dans sa table de routage.  
Cette route par défaut peut être configurée manuellement (statique) ou apprise dynamiquement via des protocoles de routage.

---

## 🌏 Routage statique et dynamique

## Cas d'utilisation des types de routage

Le **routage statique** est idéal pour les petits réseaux où la sécurité et la prévisibilité sont primordiales. Il consomme peu de bande passante et ne nécessite pas de calculs dynamiques, mais il demande une configuration manuelle et une maintenance régulière, ce qui peut devenir contraignant dans des réseaux plus vastes. En termes de sécurité, les routes statiques ne sont pas annoncées sur le réseau, ce qui les rend moins vulnérables aux attaques externes.

Le **routage dynamique**, quant à lui, s'adapte automatiquement aux changements de réseau, ce qui le rend parfait pour les réseaux complexes et évolutifs. Il offre plus de flexibilité, mais utilise plus de ressources et peut présenter des risques de sécurité. Les informations de routage étant échangées entre les routeurs, elles peuvent être interceptées ou manipulées par des attaquants si elles ne sont pas protégées.

## Routage statique ou dynamique? Les 2 chef!

Il est important de comprendre que le routage statique et le routage dynamique ne s'excluent pas mutuellement.  
La plupart des réseaux modernes utilisent une combinaison de protocoles de routage dynamique et de routes statiques.  
Cela peut donner lieu à un routeur disposant de plusieurs chemins vers un réseau de destination via des routes statiques et des routes apprises dynamiquement.

C'est justement cette combinaison de routage statique et dynamique qui fait toute la force d'Internet.  
Internet n'est pas un seul réseau, mais un immense maillage de milliers de réseaux interconnectés à travers le monde.  
Les routeurs travaillent ensemble pour échanger des informations et trouver le meilleur chemin possible pour acheminer les données, même si des parties du réseau tombent en panne ou deviennent inaccessibles.

## Le choix des routes

Jusqu'à présent, nous avons appris qu'il est possible de configurer un routeur avec plusieurs protocoles de routage et des routes statiques. Dans ce cas là, la table de routage peut disposer de plusieurs sources de route pour le même réseau de destination.

***Alors comment le routeur choisit-il sur quelle route envoyer le paquet?***

Les routeurs vont utiliser pour cela ce que l'on appelle la **distance administrative (AD)**.

La distance administrative représente le degré de fiabilité de la route. Plus elle est faible, plus la source de la route est fiable.  
Par exemple, par défaut, les routeurs CISCO disposent de valeurs administratives selon l'origine de la route: connectée directement, statique, apprise dynamiquement avec le protocole de routage EIGRP, apprise dynamiquement avec le protocole OSPF...

Le tableau ci-dessous est un exemple des valeurs de distance administratives implémentées dans les routeurs CISCO:

| Origine de la route | Distance administrative |
| --- | --- |
| Connectée directement | O |
| Statique | 1 |
| EIGRP interne | 90 |
| OSPF | 110 |
| RIP | 120 |

De ce fait, si le routeur doit choisir entre une route statique et une route OSPF, la route statique est prioritaire. De même, une route connectée directement est prioritaire sur une route statique.

---

## 📑 La table de routage

Sur un routeur Cisco IOS, la commande `show ip route` peut être utilisée pour afficher la table de routage IPv4 d'un routeur. On utilisera la commande `show ipv6 route` pour afficher la table de routage IPv6:

```shell
1
R1 # show ip route 
2
Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP D -      EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area N1 - OSPF NSSA        external type 1, N2 - OSPF NSSA external type 2 E1 - OSPF external type          1, E2 - OSPF external type 2, E - EGP i - IS-IS, L1 - IS-IS level-1, L2 -        IS-IS level-2, ia - IS-IS inter area * 
3
  - candidate default, U - per-user         static route, o - ODR P - 
4
  - periodic downloaded static route 
5
Gateway of last resort is not set 
6
  10.0.0.0/8 is variably subnetted, 2 subnets, 2 masks 
7
D   10.1.1.0/24 [90/2170112] via 209.165.200.226, 00:00:05, Serial0/0/0 
8
D   10.1.2.0/24 [90/2170112] via 209.165.200.226, 00:00:05, Serial0/0/0            192.168.10.0/24 is variably subnetted, 2 subnets, 3 masks 
9
C   192.168.10.0/24 is directly connected, GigabitEthernet0/0 
10
L   192.168.10.1/32 is directly connected, GigabitEthernet0/0 
11
  192.168.11.0/24 is variably subnetted, 2 subnets, 3 masks 
12
C   192.168.11.0/24 is directly connected, GigabitEthernet0/1 
13
L   192.168.11.1/32 is directly connected, GigabitEthernet0/1 
14
  209.165.200.0/24 is variably subnetted, 2 subnets, 3 masks 
15
C   209.165.200.224/30 is directly connected, Serial0/0/0 
16
L   209.165.200.225/32 is directly connected, Serial0/0/0
```
```shell
La source des entrées de la table de routage est identifiée par un code. Ce code définit comment la route a été découverte.

On retrouve ces codes en début de ligne et la signification de ces codes sont indiqués en début de sortie.
Voici quelques exemples de codes courants :

L : identifie l'adresse attribuée à l'interface d'un routeur. Ceci permet au routeur de déterminer efficacement s'il reçoit un paquet destiné à l'interface et non à être transféré.
C : signale un réseau connecté directement.
S : identifie une route statique créée pour atteindre un réseau donné.
D : identifie un réseau découvert de manière dynamique depuis un autre routeur à l'aide du protocole EIGRP.
O : identifie un réseau découvert de manière dynamique depuis un autre routeur à l'aide du protocole de routage OSPF.
```

Un routeur fournit des informations supplémentaires concernant la route, notamment la façon dont elle a été détectée, depuis combien de temps elle se trouve dans la table et quelle interface spécifique permet d'atteindre une destination prédéfinie.

```shell
En tant qu'administrateur réseau, il est important de savoir interpréter le contenu d'une table de routage IPv4 et IPv6.
```

Basons-nous sur cette figure, issues de la sortie de la commande `show ip route`:

`D   10.1.1.0/24 [90/2170112] via 209.165.200.226, 00:00:05, Serial0/0/0`

L'entrée identifie les informations suivantes:

- `D` = Origine de la route: indique comment la route a été apprise.
- `10.1.1.0/24` = Réseau de destination: identifie l'adresse du réseau distant.
- `90` = Distance administrative: indique la fiabilité de l'origine de la route.
- `2170112` = Métrique: indique la valeur attribuée pour atteindre le réseau distant. Les valeurs inférieures indiquent les routes préférées.
- `209.165.200.226` = Tronçon suivant: indique l'adresse IPv4 du prochain routeur vers lequel transférer le paquet.
- `00:00:05` = Horodatage de route: indique la durée écoulée depuis que la route a été découverte.
- `Serial0/0/0` = Interface de sortie: identifie l'interface de sortie à utiliser pour transférer un paquet vers la destination finale.

Un routeur nouvellement déployé, sans aucune interface configurée, dispose d'une table de routage vide, comme indiqué dans la capture:

![](https://storage.googleapis.com/assets_upload_prod/OdGI8REZFTANPZLLlth32YkRwW0m7DED.png)

Avant que l'état de l'interface soit considéré comme up/up et ajouté à la table de routage IPv4, l'interface doit:

- être associée à une adresse IPv4 ou IPv6 valide
- être activée à l'aide de la commande no shutdown
- recevoir un signal porteur d'un autre périphérique (routeur, commutateur, hôte, etc.).

Une fois l'interface active, son réseau est ajouté à la table de routage en tant que réseau connecté directement.

```shell
Une interface active, correctement configurée et connectée directement crée en réalité deux entrées de table de routage.
Exemple :
1
R1 # show ip route
2

3
  192.168.10.0/24 is variably subnetted, 2 subnets, 3 masks 
4
C   192.168.10.0/24 is directly connected, GigabitEthernet0/0 
5
L   192.168.10.1/32 is directly connected, GigabitEthernet0/0 
Les interfaces connectées directement ont deux codes d'origine de la route :

C : identifie un réseau connecté directement
L : identifie l'adresse IPv4 attribuée à l'interface du routeur sur ce réseau
```

---

## 🔩 Le routage statique

Par défaut, les routeurs ont dans leur table de routage les réseau directement connectés.  
Ils ne connaissent pas les réseaux qui se trouvent derrière un autre routeur.

```shell
Dans cette infrastructure :

R1 n’a pas connaissance du réseau WAN 38.125.212.14/24
R2 n’a pas connaissance des réseaux A et B
```
```shell
Le routage statique consiste à configurer manuellement les tables de routages des routeurs en leur déclarant comment accéder à ces réseaux, et par quel moyen.
```

## Spécification du chemin

Avant de détailler les différents types de routage statique, il faut savoir que l’on peut spécifier le chemin à emprunter pour atteindre un réseau spécifique de 3 manières.

- **En indiquant l’adresse IP du tronçon suivant**: Par exemple, pour R2 si je veux créer une route statique pour atteindre les réseaux A ou B, j’indiquerais l’adresse IP de l’interface du prochain routeur qui permet d’atteindre ces réseaux.  
	Ici, se sera l’interface `G0/1` de `R1`.  
	Cette méthode est généralement utilisée lors de la connexion à un support de diffusion, par exemple Internet. **Cette méthode est à privilégier**.

Les commandes sont les suivantes:

```shell
1
R2 (config) # ip route 192.168.0.0 255.255.255.0 192.168.2.2 
2
R2 (config) # ip route 192.168.1.0 255.255.255.0 192.168.2.2
```
- La 2ème méthode est la méthode dite **route statique directement connecté**. Au lieu de spécifier l’adresse IP du tronçon suivant, nous spécifions le nom de l’interface de sortie sur le routeur lui-même. Ici, l’interface sur le routeur `R2` qui permet d’atteindre les réseaux `A` et `B` est `GigabitEthernet 0/0`. Ces routes sont généralement utilisées pour la connexion dans une configuration point à point.

Les commandes sont les suivantes:

```shell
1
R2 (config) # ip route 192.168.0.0 255.255.255.0 G0/0 
2
R2 (config) # ip route 192.168.1.0 255.255.255.0 G0/0
```
- La troisième méthode compile les deux précédentes. Il s’agit de **spécifier l’interface de sortie + l’adresse IP du tronçon suivant**. On appelle cette méthode le **routage statique entièrement spécifié, ou entièrement indiqué**. Cette méthode était utilisée dans les anciens système d’exploitation IOS.
```shell
1
R2 (config) # ip route 192.168.0.0 255.255.255.0 G0/0 192.168.2.2 
2
R2 (config) # ip route 192.168.1.0 255.255.255.0 G0/0 192.168.2.2
```

## Les types de routes statiques

## Route statique standard

Elles sont utiles pour la connexion d'un réseau distant spécifique

```shell
L'image montre que R2 peut être configuré avec une route statique pour atteindre les réseau A et B.
```
```shell
Configuration de 2 routes statiques standard :
1
R2 (config) # ip route 192.168.0.0 255.255.255.0 192.168.2.2 
2
R2 (config) # ip route 192.168.1.0 255.255.255.0 192.168.2.2
```

## Route statique par défaut

Une route par défaut est une route statique qui correspond à tous les paquets.

Au lieu de stocker toutes les routes vers tous les réseaux dans la table de routage, un routeur peut stocker une route par défaut unique pour représenter n'importe quel réseau ne figurant pas dans la table de routage.

```shell
Une route par défaut est utilisée lorsqu'aucune autre route de la table de routage ne correspond à l'adresse IP de destination du paquet.
En d'autres termes, si une correspondance plus spécifique n'existe pas, la route par défaut est utilisée comme passerelle de dernier recours.
Les routes statiques par défaut sont communément utilisées lors de la connexion :

D'un routeur de périphérie au réseau d'un fournisseur de services
D'un routeur d'extrémité (un routeur avec un seul routeur voisin en amont)
```
```shell
Configuration d'une route statique par défaut :
1
R1 (config) # ip route 0.0.0.0 0.0.0.0 192.168.2.1
```

## Route statique récapitulative

La route statique récapitulative, également connue sous le nom d'agrégation de routes, permet de réduire le volume de la table de routage et d’optimiser le processus de recherche.

```shell
Une route statique récapitulative réduit le volume de la table de routage et permet de l’optimiser.

Normalement, R2 doit avoir dans sa table de routage une route statique pour le réseau A (192.168.0.0/24) et 1 autre pour le réseau B (192.168.1.0/24).
En faisant une agrégation de routes, nous pouvons créer une seule entrée dans la table de routage : 192.168.0.0/23 ou 192.168.0.0 255.255.254.0
```
```shell
Configuration d'une route statique récapitulative :
1
R2 (config) # ip route 192.168.0.0 255.255.254.0 192.168.2.2
```
```shell
L’importance de créer une infrastructure logique et bien organisée au niveau de l'adressage IP prend tout son sens !!!
```

## Route statique flottante

Les routes statiques flottantes sont des routes statiques qui ont une distance administrative supérieure à la distance administrative d'une autre route statique ou de routes dynamiques.

Elles sont très utiles comme routes de secours pour une liaison principale.

Par défaut, les routes statiques ont une distance administrative égale à `1`, ce qui les rend préférables aux routes acquises à partir des protocoles de routage dynamique.

La distance administrative d'une route statique peut être augmentée pour rendre la route moins souhaitable que celle d'une autre route statique ou d'une route apprise via un protocole de routage dynamique.  
De cette manière, la route statique "flotte" et n'est pas utilisée lorsque la route dont la distance administrative est meilleure est active.

Toutefois, si la route préférée est perdue, la route statique flottante peut relayer, et le trafic peut être envoyé par cette autre route.

```shell
Une route statique flottante est une route de secours, dans l’éventualité ou un chemin serait rompu et qu’un autre chemin est possible.
Elle se configure en indiquant une distance administrative supérieure aux routes déjà présentes dans la table de routage.
Les routes statiques IPv4 sont configurées à l'aide de la commande de configuration globale ip route et en spécifiant une distance administrative.

Si aucune distance administrative n'est configurée, la valeur par défaut (1) est utilisée.
Dans notre topologie, la route préférée pour R1 est celle qui va vers R2. La connexion vers R3 doit être utilisée comme route de secours uniquement.
R1 est configuré avec une route statique par défaut pointant vers R2. Étant donné qu'aucune distance administrative n'est configurée, la valeur par défaut (1) est utilisée pour cette route statique.
R1 est également configuré avec une route statique flottante par défaut pointant vers R3 avec une distance administrative de 5. Cette valeur est supérieure à la valeur par défaut 1.
Les routes flottantes ne sont pas présentent dans la table de routage, à moins que la route préférée échoue.
```
```shell
Configuration d'une route statique flottante :
1
R1 (config) # ip route 0.0.0.0 0.0.0.0 192.168.2.1 
2
R1 (config) # ip route 0.0.0.0 0.0.0.0 192.168.3.2 5
```
```shell
Une considération importante en ce qui concerne les routes statiques flottantes est qu'elles sont affectées par le temps de convergence.

Une route qui interrompt et rétablit constamment une connexion peut entraîner une activation inutile de l'interface de secours.
```

---

## ☝️ Résumé

Les routes statiques permettent de configurer manuellement les chemins pour acheminer des paquets vers des réseaux spécifiques. Voici un résumé des principaux types de routes statiques et leur utilisation:

**1\. Route statique standard**

- Utilisée pour atteindre un réseau distant spécifique.
- Exige une configuration manuelle avec l’adresse du réseau cible, le masque de sous-réseau et le prochain saut ou l’interface de sortie.

**2\. Route statique par défaut**

- Correspond à tous les paquets pour lesquels aucune route spécifique n'est définie.
- Souvent utilisée pour connecter un routeur périphérique au réseau d’un fournisseur de services ou pour les passerelles de dernier recours.
- Exemples d’utilisation:
	- Routeur d’extrémité avec un seul voisin en amont.

**3\. Route statique récapitulative**

- Combine plusieurs routes en une seule pour réduire la taille de la table de routage et optimiser les recherches.
- Exemple: au lieu de créer deux routes distinctes pour `192.168.0.0/24` et `192.168.1.0/24`, une seule route récapitulative `192.168.0.0/23` peut être utilisée.

**4\. Route statique flottante**

- Sert de route de secours pour une liaison principale.
- Configurée avec une distance administrative supérieure à celle des autres routes (valeur par défaut pour les routes statiques: 1).
- Active uniquement si la route principale échoue, assurant ainsi la continuité du trafic.

**Points clés:**

- Les routes statiques offrent un contrôle précis et des solutions adaptées à des besoins spécifiques.
- Une bonne configuration des routes statiques peut améliorer la sécurité, la performance et la résilience des infrastructures réseau.
- La distance administrative permet de définir la priorité entre différentes routes statiques et dynamiques.

---

## 📝 Quiz

```shell
# 1  -  Quel est le rôle principal d'un routeur dans un réseau informatique ?Il stocke les fichiers partagés dans un réseau.Il attribue des adresses IP aux équipements connectés.Il analyse les paquets de données pour décider de leur itinéraire vers leur destination.Il chiffre les données pour garantir leur confidentialité.Valider# 2  -  Que contient une table de routage utilisée par un routeur ?Les noms des utilisateurs connectés au réseau.Les données chiffrées des utilisateurs.Les journaux des paquets transmis.Les informations sur les chemins vers différents réseaux.Valider# 3  -  Que fait un routeur lorsqu'il ne trouve pas d'entrée correspondante dans sa table de routage pour une adresse IP de destination ?Il attribue une nouvelle adresse IP au paquet.Il stocke le paquet dans un buffer pour analyse ultérieure.Il redirige automatiquement le paquet vers un serveur DNS.Il abandonne le paquet.Valider# 4  -  À quoi sert le champ TTL (Time To Live) dans l'en-tête IP d'un paquet ?À calculer le temps nécessaire pour qu'un paquet atteigne sa destination.À limiter le temps qu'un paquet peut rester sur le réseau en réduisant sa valeur à chaque saut.À définir la priorité d’un paquet sur le réseau.À sécuriser les paquets contre les interceptions malveillantes.Valider# 5  -  Que se passe-t-il si le TTL d'un paquet atteint 0 avant qu'il n'arrive à destination ?Le TTL est automatiquement réinitialisé pour permettre au paquet de continuer.Le paquet est supprimé, et un message ICMP "Time Exceeded" est envoyé à l’expéditeur.Le paquet est mis en pause et réinitialisé pour poursuivre son chemin.Le paquet est renvoyé à l’expéditeur.Valider# 6  -  Qu'est-ce qu'une route par défaut dans un routeur ?Une route configurée pour indiquer où envoyer les paquets dont la destination n'est pas connue par le routeur.Une route qui stocke les informations sur tous les réseaux connus dans le monde.Une route dynamique toujours apprise par des protocoles de routage.Une route utilisée uniquement dans les réseaux locaux pour limiter la congestion.Valider# 7  -  Quelle est une caractéristique clé du routage statique ?Il consomme plus de ressources réseau pour échanger des informations.Il utilise des calculs dynamiques pour trouver les meilleurs chemins.Il s'adapte automatiquement aux changements dans le réseau.Il nécessite une configuration manuelle et offre une prévisibilité élevée.Valider# 8  -  Pourquoi le routage dynamique peut-il présenter un risque de sécurité ?Parce qu'il n'utilise pas de routes statiques comme alternative.Parce qu'il ne peut pas gérer des réseaux complexes.Parce qu'il rend les routeurs moins fiables.Parce que les informations de routage échangées entre routeurs peuvent être interceptées ou manipulées si elles ne sont pas protégées.Valider# 9  -  Comment un routeur choisit-il la route à utiliser lorsqu’il a plusieurs chemins pour une même destination ?Il donne toujours la priorité au routage dynamique.Il sélectionne toujours le chemin le plus court en termes de distance géographique.Il choisit au hasard parmi les routes disponibles.Il se base sur la valeur de la distance administrative (AD), en choisissant la source avec la valeur la plus faible.Valider# 10  -  Quelle commande permet d’afficher la table de routage IPv6 sur un routeur Cisco IOS ?show ip routeshow route ipv6show ip routesshow ipv6 routeValider# 11  -  Dans la sortie suivante : \`D 10.1.1.0/24 [90/2170112] via 209.165.200.226, 00:00:05, Serial0/0/0\`  Que représente le champ \`[90/2170112]\` ?L'horodatage de la route et le réseau de destination.L'origine de la route et l'interface de sortie.La distance administrative et la métrique de la route.La distance administrative et l'adresse du tronçon suivant.Valider# 12  -  Dans une table de routage, que signifie une entrée marquée \`C\` ?Une route configurée manuellement par l’administrateur réseau.Une route apprise dynamiquement par un protocole de routage.Une route connectée directement à une interface du routeur.Une route par défaut utilisée pour tous les réseaux inconnus.Valider# 13  -  Une interface active et correctement configurée ajoute combien d’entrées dans la table de routage ?Deux entrées : une pour le réseau connecté directement et une pour l'adresse IP attribuée à l'interface du routeurDeux entrées : une pour le réseau connecté directement et une pour la route par défaut.Une seule entrée, pour le réseau connecté directement.Deux entrées : une pour le réseau connecté directement et une pour la plage d’hôtes.Deux entrées : une pour le réseau connecté directement et une pour l'adresse du tronçon suivant.Valider# 14  -  Quelle est la fonction principale d'une route statique par défaut ?Agir comme une route de secours.Réduire le volume de la table de routage.Correspondre à tous les paquets lorsque aucune route spécifique ne correspond.Fournir une route préférée pour les réseaux directement connectés.Valider# 15  -  Dans quel cas une route statique récapitulative est-elle utilisée ?Lorsqu'un routeur a besoin d'une route de secours.Lorsqu'une route doit avoir une distance administrative supérieure.Lorsqu'un routeur est connecté à un fournisseur de services.Lorsqu'il est nécessaire d'optimiser et de réduire le volume de la table de routage.Valider# 16  -  Quelle commande permet de configurer une route statique flottante ?ip route 192.168.0.0 255.255.255.0 G0/0ip route 192.168.0.0 255.255.255.0 G0/0 10ip route 192.168.0.0 255.255.255.0 G0/0 defaultip route 192.168.0.0 255.255.255.0 G0/0 192.168.2.2Valider# 17  -  Par défaut, quelle est la valeur de la distance administrative d'une route statique ?51010Valider# 18  -  Quelle différence existe entre une route statique standard et une route statique flottante ?Une route statique flottante est une route de secours qui n'est activée que si la route préférée échoue.Une route statique standard correspond à tous les paquets comme une route par défaut.Une route statique standard est configurée avec une distance administrative supérieure.Une route statique flottante est utilisée uniquement pour réduire la table de routage.ValiderTon score :0 / 18
```

Valide cette quête lorsque tu as compris les principes du routage.

Quête terminée le **lundi 08 décembre 2025**