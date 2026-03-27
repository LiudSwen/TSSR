---
title: "Atelier : Routage statique avec Packet Tracer - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2874/pages/11941"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Atelier: Routage statique avec Packet Tracer

Cet atelier consiste à mettre en pratique les concepts fondamentaux des réseaux TCP/IP (v4 & v6) à travers l'outil de simulation réseau Packet Tracer.

Difficile

3h

Auto-validation

Réseau

## Atelier: Routage statique avec Packet Tracer

## Introduction

Cet atelier permet de mettre en pratique les concepts de routage statique et d'adressage IPv4/IPv6.  
Il consiste à créer un réseau virtuel, configurer des périphériques réseau, et tester la connectivité entre eux.  
On utilise pour cela **Packet Tracer**, un outil de simulation de réseau très classique de chez [Cisco](https://www.cisco.com/).

![Cisco Packet Tracer](https://networkslearning.com/wp-content/uploads/2020/02/Screenshot-2020-02-15-at-15.54.25.png)

## 🎯 Objectif de l'atelier

✅ Compréhension des types de réseaux (LAN, WAN).  
✅ Connaissance des protocoles de communication (TCP/IP v4 et v6, ICMP).  
✅ Identification des composants réseau (routeurs, commutateurs).  
✅ Configuration de base des périphériques réseau (adresse IP, masque de sous-réseau, passerelle, etc.).  
✅ Mise en réseau de machines via un commutateur.  
✅ Inter-connexion de réseaux entre eux et compréhension du concept de routage (statique)  
✅ Vérifier la connectivité et résoudre les problèmes courants.

## Sommaire

- [📚 Prérequis](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#-pr%C3%A9requis)
- [❓ Qu'est-ce que Packet Tracer?](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#-quest-ce-que-packet-tracer-)
- [⚙️ Installation de Packet Tracer](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#%EF%B8%8F-installation-de-packet-tracer)
- [📖 Documentation de la Topologie](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#-documentation-de-la-topologie)
- [⚙️ Étape 1 - Créer une nouvelle topologie](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#%EF%B8%8F-%C3%A9tape-1---cr%C3%A9er-une-nouvelle-topologie)
- [⚙️ Étape 2 - Configuration des adresses IP](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#%EF%B8%8F-%C3%A9tape-2---configuration-des-adresses-ip)
	- [Adresse IPv4](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#adresse-ipv4)
		- [Adresse IPv6](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#adresse-ipv6)
- [⚙️ Étape 3 - Vérification de la connectivité](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#%EF%B8%8F-%C3%A9tape-3---v%C3%A9rification-de-la-connectivit%C3%A9)
- [⚙️ Étape 4 - Introduction d'un routeur](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#%EF%B8%8F-%C3%A9tape-4---introduction-dun-routeur)
	- [Le plan d'adressage](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#le-plan-dadressage)
		- [Adresse IPv4](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#adresse-ipv4-1)
				- [Adresse IPv6](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#adresse-ipv6-1)
- [⚙️ Étape 5 - Ajout d'un second réseau (site distant)](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#%EF%B8%8F-%C3%A9tape-5---ajout-dun-second-r%C3%A9seau-site-distant)
	- [Le plan d'adressage IP du site 2](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#le-plan-dadressage-ip-du-site-2)
		- [Adresse IPv4](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#adresse-ipv4-2)
				- [Adresse IPv6](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#adresse-ipv6-2)
- [⚙️ Étape 6 - Ajout d'un routeur "Internet"](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#%EF%B8%8F-%C3%A9tape-6---ajout-dun-routeur-internet)
- [⚙️ Étape 7 - Configuration du routeur "Internet"](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#%EF%B8%8F-%C3%A9tape-7---configuration-du-routeur-internet)
	- [Le plan d'adressage IP du routeur Internet](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#le-plan-dadressage-ip-du-routeur-internet)
		- [Adresse IPv4](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#adresse-ipv4-3)
				- [Adresse IPv6](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#adresse-ipv6-3)
				- [CLI](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#cli)
- [⚙️ Étape 8 - Configuration du routage statique](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#%EF%B8%8F-%C3%A9tape-8---configuration-du-routage-statique)
- [⚙️ Étape 9 - Ajout d'un troisième site](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#%EF%B8%8F-%C3%A9tape-9---ajout-dun-troisi%C3%A8me-site)
- [🙌 Partage des Connaissances](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#-partage-des-connaissances)
- [🏄 Aller plus loin](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#-aller-plus-loin)
- [🎉 Conclusion](https://odyssey.wildcodeschool.com/quests/2874/pages/11941#-conclusion)

## 📚 Prérequis

Avant de commencer, tu as besoin d'un ordinateur sous Windows, macOS ou Linux sur lequel est installé Packet Tracer.

## ❓ Qu'est-ce que Packet Tracer?

Packet Tracer est un outil de **simulation** de réseau développé par Cisco, c'est un bon moyen d'explorer et de comprendre les concepts clés des réseaux informatiques.  
Il te permet de créer et de configurer des réseaux virtuels pour tester différents scénarios de réseau.  
C'est un outil largement utilisé dans le domaine de la formation autour du réseau.

## ⚙️ Installation de Packet Tracer

1. Rends-toi sur le site officiel de Cisco NetAcademy à l'adresse [https://www.netacad.com/](https://www.netacad.com/) et inscris-toi pour obtenir un compte gratuit.  
	Tu auras besoin d'un compte Cisco NetAcademy pour accéder à Packet Tracer.
2. Une fois que tu as un compte, connecte-toi à [Cisco NetAcademy](https://www.netacad.com/).
3. Accède à la section " [Ressources > Packet Tracer](https://www.netacad.com/portal/resources/packet-tracer) " pour télécharger la dernière version de Packet Tracer compatible avec ton système d'exploitation.
4. Suis les instructions de l'assistant d'installation pour installer Packet Tracer sur ton ordinateur.

## 📖 Documentation de la Topologie

Tout au long de cet atelier, construit une documentation de la topologie en enregistrant les configurations des routeurs. Note les adresses IP, les masques de sous-réseau et les routes statiques configurées.  
Cela pourra te permettre de reproduire ces concepts dans d'autres situations.

## ⚙️ Étape 1 - Créer une nouvelle topologie

- Créer une nouvelle topologie sur le logiciel packet tracer.
- Dans la barre d'outils en bas à gauche, trouve et ajoute:
	- un commutateur
		- deux ordinateurs

Relie les ensuite au commutateur à l'aide de câbles droits.

![PC0, PC1, Switch0](https://storage.googleapis.com/quest_editor_uploads/GR2XofF5xssnomr47a4TY6Qc7nLjfDZ7.png)

## ⚙️ Étape 2 - Configuration des adresses IP

Accèdes ensuite à la configuration des 2 PC afin de leur configurer sur leur carte réseau (FastEthernet0): une adresse IP et un masque de sous réseau pour l'IPv4 et aussi une IPv6 et un préfixe.

![](https://storage.googleapis.com/quest_editor_uploads/Kh37hpdO13Q239Lj4vVL0Piz4oMbnWqW.png)

Tu peux par exemple utiliser ces paramètres:

## Adresse IPv4

| Machine | Adresse IP | Masque |
| --- | --- | --- |
| PC0 | 192.168.1.10 | 255.255.255.0 |
| PC1 | 192.168.1.11 | 255.255.255.0 |

## Adresse IPv6

| Machine | Adresse IPv6 | Préfixe IPv6 |
| --- | --- | --- |
| PC0 | 2001:db8:cafe:cafe::10/64 | 2001:db8:cafe:cafe::/64 |
| PC1 | 2001:db8:cafe:cafe::11/64 | 2001:db8:cafe:cafe::/64 |

Ce qui devrait te donner:

![](https://storage.googleapis.com/quest_editor_uploads/c5Ej0CJUlAh4CYkGoKPUDeKjQPr3RQB8.png)

## ⚙️ Étape 3 - Vérification de la connectivité

Utilise ensuite l'outil de simulation de Packet Tracer pour tester la connectivité entre les deux ordinateurs.  
Envoie des paquets ICMP (ping) d'un PC à l'autre et vérifie que la connectivité fonctionne.

![](https://storage.googleapis.com/quest_editor_uploads/aupFxlt79b8mKvVC8jxb7Ot5PlNiZrJJ.png)

## ⚙️ Étape 4 - Introduction d'un routeur

Ajoute un routeur `2911` à la topologie et relie-le au switch avec un câble et configure lui ses adresses IPv4 et IPv6.

Configure les postes clients (PC0 et PC1) afin d'utiliser ce routeur comme "passerelle".

## Le plan d'adressage

### Adresse IPv4

| Machine | Adresse IP | Masque | Passerelle |
| --- | --- | --- | --- |
| PC0 | 192.168.1.10 | 255.255.255.0 | 192.168.1.1 |
| PC1 | 192.168.1.11 | 255.255.255.0 | 192.168.1.1 |
| Router1 (LAN) | 192.168.1.1 | 255.255.255.0 |  |
| Router1 (WAN) | 198.51.100.1 | 255.255.255.252 |  |

### Adresse IPv6

| Machine | Adresse IPv6 | Passerelle |
| --- | --- | --- |
| PC0 | 2001:db8:cafe:cafe::10/64 | 2001:db8:cafe:cafe::1 |
| PC1 | 2001:db8:cafe:cafe::11/64 | 2001:db8:cafe:cafe::1 |
| R1 (LAN) | 2001:db8:cafe:cafe::1/64 |  |
| R1 (WAN) | 2001:db8:cafe:feed::1/64 |  |

```shell
Pour configurer une adresse IPv6 sur un routeur dans Packet Tracer, il te faudra passer par la ligne de commande (CLI)
```
```shell
1
Router> en
2
Router# conf t
3
Router (config)# hostname R1
4
R1 (config)# ipv6 unicast-routing
5
R1 (config)# interface gigabitEthernet 0/0
6
R1 (config-if)# description Gateway_LAN
7
R1 (config-if)# ip address 192.168.1.1 255.255.255.0
8
R1 (config-if)# ipv6 enable
9
R1 (config-if)# ipv6 address 2001:db8:cafe:cafe::1/64
10
R1 (config-if)# no shutdown
11
R1 (config-if)# exit
12
R1 (config)# interface gigabitEthernet 0/1
13
R1 (config-if)# description WAN
14
R1 (config-if)# ip address 198.51.100.1 255.255.255.252
15
R1 (config-if)# ipv6 enable
16
R1 (config-if)# ipv6 address 2001:db8:cafe:feed::1/64
17
R1 (config-if)# no shutdown
18
R1 (config-if)# exit
19
R1 (config)# do wr
```

## ⚙️ Étape 5 - Ajout d'un second réseau (site distant)

Ajoutons maintenant un deuxième réseau (ou site "géographique") que l'on nommera `SITE 2`.

Tu peux reprendre sur ce second site:

- 1 routeur 2911
- 1 commutateur 2960
- 2 PC

## Le plan d'adressage IP du site 2

### Adresse IPv4

| Machine | Adresse IP | Masque | Passerelle |
| --- | --- | --- | --- |
| PC2 | 192.168.2.10 | 255.255.255.0 | 192.168.2.1 |
| PC3 | 192.168.2.11 | 255.255.255.0 | 192.168.2.1 |
| R2 (LAN) | 192.168.2.1 | 255.255.255.0 |  |
| R2 (WAN) | 198.51.100.5 | 255.255.255.252 |  |

### Adresse IPv6

| Machine | Adresse IPv6 | Passerelle |
| --- | --- | --- |
| PC2 | 2001:db8:babe:babe::10/64 | 2001:db8:babe:babe::1 |
| PC3 | 2001:db8:babe:babe::11/64 | 2001:db8:babe:babe::1 |
| R2 (LAN) | 2001:db8:babe:babe::1/64 |  |
| R2 (WAN) | 2001:db8:babe:feed::1/64 |  |

Tu devrais désormais avoir une topologie qui ressemble à ceci:

![](https://storage.googleapis.com/quest_editor_uploads/bxvEt4OtJjnabQhqQV6j08x2GScqAuIs.png)

## ⚙️ Étape 6 - Ajout d'un routeur "Internet"

Maintenant, il faut que l'on puisse connecter ces 2 sites ensemble.

On va donc déployer un routeur entre ces 2 sites. Ce routeur se nommera `Internet`.

Déploie un routeur `2911` entre les 2 sites.

Connecte les interfaces WAN de R1 et R2 au routeur Internet à l'aide de **câbles croisés**:

![](https://storage.googleapis.com/quest_editor_uploads/FBnfcBCRozEOrTfR3ZWMg4MmDvgjtm0Z.png)

## ⚙️ Étape 7 - Configuration du routeur "Internet"

configure les adresses IPv4 et IPv6 du routeur Internet en respectant le plan d'adressage et en n'oubliant pas d'activer les interfaces.

## Le plan d'adressage IP du routeur Internet

### Adresse IPv4

| Machine | Adresse IP | Masque |
| --- | --- | --- |
| Internet (G0/0) | 198.51.100.2 | 255.255.255.252 |
| Internet (G0/1) | 198.51.100.6 | 255.255.255.252 |

### Adresse IPv6

| Machine | Adresse IPv6 |
| --- | --- |
| Internet (G0/0) | 2001:db8:cafe:feed::2/64 |
| Internet (G0/1) | 2001:db8:babe:feed::2/64 |

### CLI

```shell
1
Router> en
2
Router# conf t
3
Router(config)# hostname Internet
4
Internet(config)# ipv6 unicast-routing
5
Internet(config)# interface gigabitEthernet 0/0
6
Internet(config-if)# description VERS_SITE1
7
Internet(config-if)# ip address 198.51.100.2 255.255.255.252
8
Internet(config-if)# ipv6 enable 
9
Internet(config-if)# ipv6 address 2001:db8:cafe:feed::2/64
10
Internet(config-if)# no shutdown
11
Internet(config-if)# exit
12
Internet(config)# interface gigabitEthernet 0/1
13
Internet(config-if)# description VERS_SITE2
14
Internet(config-if)# ip address 198.51.100.6 255.255.255.252
15
Internet(config-if)# ipv6 enable 
16
Internet(config-if)# ipv6 address 2001:db8:babe:feed::2/64
17
Internet(config-if)# no shutdown
18
Internet(config-if)# end
19
Internet# write memory
```
```shell
Ton routeur Internet devrait être capable de joindre les interfaces WAN des routeurs R1 et R2 en IPv4 et IPv6.
```
```shell
1
# Interface WAN R1
2
Internet# ping 2001:db8:cafe:feed::1
3
Type escape sequence to abort.
4
Sending 5, 100-byte ICMP Echos to 2001:db8:cafe:feed::1, timeout is 2 seconds:
5
!!!!!
6
Success rate is 100 percent (5/5), round-trip min/avg/max = 0/0/0 ms
7

8
Internet# ping 198.51.100.1
9
Type escape sequence to abort.
10
Sending 5, 100-byte ICMP Echos to 198.51.100.1, timeout is 2 seconds:
11
.!!!!
12
Success rate is 80 percent (4/5), round-trip min/avg/max = 0/0/0 ms
13

14
# Interface WAN R2
15
Internet# ping 2001:db8:babe:feed::1
16
Type escape sequence to abort.
17
Sending 5, 100-byte ICMP Echos to 2001:db8:babe:feed::1, timeout is 2 seconds:
18
!!!!!
19
Success rate is 100 percent (5/5), round-trip min/avg/max = 0/0/0 ms
20

21
Internet# ping 198.51.100.5
22
Type escape sequence to abort.
23
Sending 5, 100-byte ICMP Echos to 198.51.100.5, timeout is 2 seconds:
24
.!!!!
25
Success rate is 80 percent (4/5), round-trip min/avg/max = 0/0/0 ms
```

A ce stade si tu essaie de joindre depuis le **PC0 (site 1)** --> le **PC2 (site2)** via une commande ping, tu devrais constater qu'il y a un problème.

```shell
C:\>ping 192.168.2.10

Pinging 192.168.2.10 with 32 bytes of data:

Reply from 192.168.1.1: Destination host unreachable.
Reply from 192.168.1.1: Destination host unreachable.
Reply from 192.168.1.1: Destination host unreachable.
Reply from 192.168.1.1: Destination host unreachable.

Ping statistics for 192.168.2.10:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),
```
```shell
En effet, le routeur du site 1 ignore totalement comment joindre ce réseau.
Un routeur base ses choix de routage sur les informations contenues dans sa table de routage.
S'il ne dispose pas des informations lui permettant de joindre un réseau distant, il abandonne simplement le paquet.
Les routeurs peuvent apprendre des réseaux distants de 2 manières différentes :

Manuellement : les réseaux distants sont saisis manuellement dans la table de routage à l'aide de routes statiques
Dynamiquement : les routes distantes sont automatiquement acquises via un protocole de routage dynamique
```

Par défaut, un routeur ne connaît que les réseaux qui sont directement connectés à ses interfaces.

Vérifions la table de routage IPv4 de R1:

```shell
1
R1#sh ip route
2
Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
3
       D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area
4
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
5
       E1 - OSPF external type 1, E2 - OSPF external type 2, E - EGP
6
       i - IS-IS, L1 - IS-IS level-1, L2 - IS-IS level-2, ia - IS-IS inter area
7
       * - candidate default, U - per-user static route, o - ODR
8
       P - periodic downloaded static route
9

10
Gateway of last resort is not set
11

12
     192.168.1.0/24 is variably subnetted, 2 subnets, 2 masks
13
C       192.168.1.0/24 is directly connected, GigabitEthernet0/0
14
L       192.168.1.1/32 is directly connected, GigabitEthernet0/0
15
     198.51.100.0/24 is variably subnetted, 2 subnets, 2 masks
16
C       198.51.100.0/30 is directly connected, GigabitEthernet0/1
17
L       198.51.100.1/32 is directly connected, GigabitEthernet0/1
```

Et sa table de routage IPv6:

```shell
1
R1#show ipv6 route
2
IPv6 Routing Table - 5 entries
3
Codes: C - Connected, L - Local, S - Static, R - RIP, B - BGP
4
       U - Per-user Static route, M - MIPv6
5
       I1 - ISIS L1, I2 - ISIS L2, IA - ISIS interarea, IS - ISIS summary
6
       ND - ND Default, NDp - ND Prefix, DCE - Destination, NDr - Redirect
7
       O - OSPF intra, OI - OSPF inter, OE1 - OSPF ext 1, OE2 - OSPF ext 2
8
       ON1 - OSPF NSSA ext 1, ON2 - OSPF NSSA ext 2
9
       D - EIGRP, EX - EIGRP external
10
C   2001:DB8:CAFE:CAFE::/64 [0/0]
11
     via GigabitEthernet0/0, directly connected
12
L   2001:DB8:CAFE:CAFE::1/128 [0/0]
13
     via GigabitEthernet0/0, receive
14
C   2001:DB8:CAFE:FEED::/64 [0/0]
15
     via GigabitEthernet0/1, directly connected
16
L   2001:DB8:CAFE:FEED::1/128 [0/0]
17
     via GigabitEthernet0/1, receive
18
L   FF00::/8 [0/0]
19
     via Null0, receive
```
```shell
Dans les 2 résultats, on voit plusieurs informations très intéressantes :

Les informations sur les réseaux directement connectés à ses interfaces ainsi que le nom de l'interface en question
Tout en haut, l'origine de la route, c'est à dire comment cette route à été apprise :

C: signale un réseau connecté directement
L: identifie l'adresse attribuée à l'interface d'un routeur
S: identifie une route statique créée pour atteindre un réseau donné
O: identifie un réseau découvert de manière dynamique depuis un autre routeur à l'aide du protocole de routage OSPF
Etc...

Dans le résultat de la commande concernant IPv4, la phrase suivante : Gateway of last resort is not set qui indique qu'aucune route par défaut n'est présente. Une route par défaut est utilisée lorsqu'aucune autre route de la table de routage ne correspond à l'adresse IP de destination du paquet. En d'autres termes, si une correspondance plus spécifique n'existe pas, la route par défaut est utilisée comme passerelle de dernier recours.
```

## ⚙️ Étape 8 - Configuration du routage statique

Nous allons configurer le routage statique sur nos routeurs (R1, R2 et Internet) afin de faire communiquer les différents réseaux.

Sur le routeur du site 1 (R1), nous devons renseigner la route pour joindre le réseau local du site 2 et le réseau entre le routeur Internet et R2 (seulement si l'on souhaite joindre l'interface WAN de R2).

Sur le routeur du site 2 (R2), nous devons renseigner la route pour joindre le réseau local du site 1 et le réseau entre le routeur Internet et R1 (seulement si l'on souhaite joindre l'interface WAN de R1).

Sur le routeur Internet, nous devons renseigner comment joindre les réseaux locaux des sites 1 et 2.

```shell
Lorsque tu configures du routage statique standard, il faut spécifier le chemin à emprunter pour atteindre un réseau spécifique.
On peut le faire de plusieurs manière mais la manière la plus utilisée est d'indiquer l'adresse IP du tronçon suivant, c'est à dire l'adresse IP de l'interface du prochain routeur qui permet d'atteindre ce réseau.
```

Commandes à réaliser sur le routeur du site 1:

```shell
R1> enable
R1# configure terminal
R1(config)# ip route 192.168.2.0 255.255.255.0 198.51.100.2
R1(config)# ip route 198.51.100.0 255.255.255.252 198.51.100.2
R1(config)# ipv6 route 2001:db8:babe:babe::0/64 2001:db8:cafe:feed::2
R1(config)# ipv6 route 2001:db8:babe:feed::0/64 2001:db8:cafe:feed::2
R1(config)# do wr
```

Commandes à réaliser sur le routeur du site 2:

```shell
R2> enable
R2# configure terminal
R2(config)# ip route 192.168.1.0 255.255.255.0 198.51.100.6
R2(config)# ip route 198.51.100.0 255.255.255.252 198.51.100.6
R2(config)# ipv6 route 2001:db8:cafe:cafe::0/64 2001:db8:babe:feed::2
R2(config)# ipv6 route 2001:db8:cafe:feed::0/64 2001:db8:babe:feed::2
```

Commandes à réaliser sur le routeur Internet:

```shell
Internet> enable
Internet# configure terminal
Internet(config)# ip route 192.168.1.0 255.255.255.0 198.51.100.1
Internet(config)# ip route 192.168.2.0 255.255.255.0 198.51.100.5
Internet(config)# ipv6 route 2001:db8:cafe:cafe::/64 2001:db8:cafe:feed::1
Internet(config)# ipv6 route 2001:db8:babe:babe::/64 2001:db8:babe:feed::1
```
```shell
Ici le routage de l'IPv4 est réalisé en CLI, mais il est tout à fait possible de réaliser cette opération via l'interface graphique de Packet Tracer dans l'onglet Config > Routing > Static d'un routeur.
⚠️ Ce n'est pas le cas en IPv6
```

Tu peux vérifier les tables de routage des différents routeurs.

```shell
Vérification des tables de routage IPv4 et IPv6 de R1 :
1
R1# sh ip route
2
...
3
Gateway of last resort is not set
4

5
     192.168.1.0/24 is variably subnetted, 2 subnets, 2 masks
6
C       192.168.1.0/24 is directly connected, GigabitEthernet0/0
7
L       192.168.1.1/32 is directly connected, GigabitEthernet0/0
8
S    192.168.2.0/24 [1/0] via 198.51.100.2
9
     198.51.100.0/24 is variably subnetted, 3 subnets, 2 masks
10
C       198.51.100.0/30 is directly connected, GigabitEthernet0/1
11
L       198.51.100.1/32 is directly connected, GigabitEthernet0/1
12
S       198.51.100.4/30 [1/0] via 198.51.100.2
13

14
R1# sh ipv6 route 
15
...
16
S   2001:DB8:BABE:BABE::/64 [1/0]
17
     via 2001:DB8:CAFE:FEED::2
18
S   2001:DB8:BABE:FEED::/64 [1/0]
19
     via 2001:DB8:CAFE:FEED::2
20
C   2001:DB8:CAFE:CAFE::/64 [0/0]
21
     via GigabitEthernet0/0, directly connected
22
L   2001:DB8:CAFE:CAFE::1/128 [0/0]
23
     via GigabitEthernet0/0, receive
24
C   2001:DB8:CAFE:FEED::/64 [0/0]
25
     via GigabitEthernet0/1, directly connected
26
L   2001:DB8:CAFE:FEED::1/128 [0/0]
27
     via GigabitEthernet0/1, receive
28
L   FF00::/8 [0/0]
29
     via Null0, receive
```

Désormais, si tu tentes de joindre depuis le **PC0 (site 1)** --> le **PC2 (site2)** via une commande ping, tu devrais constater que c'est fonctionnel!

```shell
C:\>ping 192.168.2.10

Pinging 192.168.2.10 with 32 bytes of data:

Request timed out.
Reply from 192.168.2.10: bytes=32 time<1ms TTL=125
Reply from 192.168.2.10: bytes=32 time<1ms TTL=125
Reply from 192.168.2.10: bytes=32 time<1ms TTL=125

Ping statistics for 192.168.2.10:
    Packets: Sent = 4, Received = 3, Lost = 1 (25% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms
```

Idem en IPv6

```shell
C:\>ping 2001:db8:babe:babe::10

Pinging 2001:db8:babe:babe::10 with 32 bytes of data:

Reply from 2001:DB8:BABE:BABE::10: bytes=32 time<1ms TTL=125
Reply from 2001:DB8:BABE:BABE::10: bytes=32 time=1ms TTL=125
Reply from 2001:DB8:BABE:BABE::10: bytes=32 time<1ms TTL=125
Reply from 2001:DB8:BABE:BABE::10: bytes=32 time=9ms TTL=125

Ping statistics for 2001:DB8:BABE:BABE::10:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 9ms, Average = 2ms
```

## ⚙️ Étape 9 - Ajout d'un troisième site

Désormais c'est à toi de jouer!

Déploie un 3ème site à l'aide des informations de l'image ci-dessous puis configure les machines et le routeur afin d'assurer une connectivité avec les 2 autres sites.

![](https://storage.googleapis.com/quest_editor_uploads/lm2md8BB06w19AMHxyrErk1kV2gm1NbF.png)

![](https://storage.googleapis.com/quest_editor_uploads/baRsLZUoVKV9FL2M7Wtklwm6cKL06V7h.png)

```shell
Pour l'adressage statique, il te faudra non seulement configurer le nouveau routeur R3, mais aussi revenir sur les autres routeurs afin de leur déclarer ce nouveau site !!
```
```shell
N'hésite pas à prendre des notes, et à préparer ton intervention avant de passer à l'implémentation !
```

## 🙌 Partage des Connaissances

Partage tes résultats et tes expériences avec d'autres étudiants ou collègues pour favoriser l'apprentissage collaboratif.

## 🏄 Aller plus loin

Si tu souhaites rendre dynamique le routage, tu devrais regarder du côté des protocoles de routage **RIP** ou encore **OSPF**.

Si tu souhaite plus généralement approfondir tes connaissances en réseau, tu peux retrouver différents cours et travaux pratiques sur le réseau en libre accès associé à l'outil packet tracer sur [Cisco Netacad](https://www.netacad.com/fr/courses/networking) et sur [SkillsForAll](https://skillsforall.com/course/networking-basics?courseLang=fr-FR)

## 🎉 Conclusion

Félicitations! Tu as réussi à créer un réseau virtuel, configurer des périphériques réseau, et tester la connectivité en utilisant Packet Tracer.

Cet atelier t'a permis de mettre en pratique les concepts de routage statique IPv4 et IPv6.

Continue à explorer et à approfondir tes compétences en réseau pour devenir un expert en la matière.

Quête terminée le **mardi 30 décembre 2025**