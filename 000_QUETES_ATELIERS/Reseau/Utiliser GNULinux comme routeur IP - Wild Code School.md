---
title: "Utiliser GNU/Linux comme routeur IP - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2350/pages/18688"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Utiliser GNU/Linux comme routeur IP

Découvre comment la pile IP du noyau Linux peut assumer la fonction de routeur

Moyen

2h

3 pairs

Réseau

## Utiliser GNU/Linux comme routeur IP

## Introduction

Dans un réseau IP, un routeur est un nœud permettant d'interconnecter des réseaux logiques distincts.  
Il s'agit d'une passerelle (en anglais: *gateway*), d'un intermédiaire. Ainsi tous les paquets devant aller d'un des réseaux logiques auxquel le routeur est connecté à un autre doivent lui être envoyés. Son rôle particulier consiste alors à transmettre le paquet au lieu de le jeter, comme le ferait un hôte du réseau quand il reçoit un paquet qui ne lui est pas destiné.

S'il existe des équipements matériels dédiés à cet usage, qu'on appelle habituellement routeurs matériels, n'importe quel ordinateur peut en théorie servir de routeur, à condition que son système d'exploitation dispose d'une implémentation du protocole IP (qu'on désigne couramment par pile IP ou *stack* IP) munie de cette fonctionnalité.

C'est le cas du noyau Linux. Donc n'importe quelle machine Linux peut servir de routeur. Cette quête propose d'en faire l'expérience.

![Plan d'un projet avec 4 réseaux interconnecté par 3 routeurs](https://storage.googleapis.com/quest_editor_uploads/8zSateZDqj6LPhJaqO3RD6CwRKqVtiHA.png)

## 🤓 Objectifs:

✅ Comprendre le routage IP  
✅ Concevoir des tables de routage et faire communiquer des réseaux IP distincts  
✅ Configurer les fonctionnalités de routage d'un système GNU/Linux

## Sommaire

- [👉 Le routage](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#-le-routage)
	- [📑 Communication dans un même réseau (rappel)](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#-communication-dans-un-m%C3%AAme-r%C3%A9seau-rappel)
		- [📚 Sortir du réseau](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#-sortir-du-r%C3%A9seau)
		- [📚 Construire les tables de routage](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#-construire-les-tables-de-routage)
- [👉 Configurer un routeur GNU/Linux](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#-configurer-un-routeur-gnulinux)
	- [📑 La configuration réseau sous GNU/Linux (rappel)](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#-la-configuration-r%C3%A9seau-sous-gnulinux-rappel)
		- [🔬 Exercice - étape 1](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#-exercice---%C3%A9tape-1)
		- [🔬 Exercice - étape 2](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#-exercice---%C3%A9tape-2)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2350/pages/18688#-crit%C3%A8res-dacceptation)

## 👉 Le routage

## 📑 Communication dans un même réseau (rappel)

Lorsque des hôtes sont sur le même réseau physique, par exemple lorsqu'ils sont tous connectés sur le même commutateur Ethernet, et qu'on souhaite leur permettre de communiquer avec le protocole IP, il suffit de leur allouer à chacun une adresse IP distincte et un masque de sous réseau plaçant toutes les adresses dans le même réseau logique.

Par exemple, en admettant qu'il y ait moins de 255 hôtes, on peut opter pour le réseau `203.0.113.0/24` et attribuer aux machines les configurations suivantes:

- `203.0.113.1/24`
- `203.0.113.2/24`
- `203.0.113.3/24`
- etc.
- Jusqu'à `203.0.113.254/24`

Avec IPv6, c'est le même principe, à ceci près que pour rester compatible avec les mécanismes d'auto-adressage sans état (SLAAC), on opte en général pour des réseaux en /64 (donc avec un nombre considérable d'adresses disponibles de l'ordre, de $10^{19}$)

Un exemple avec le réseau `1::/64`:

- `1::1/64`
- `1::2/64`
- `1::3/64`
- etc.
- Jusqu'à `1::ffff:ffff:ffff:fffe/24`
```shell
En IPv6, on pourrait d'ailleurs ne pas avoir à allouer des adresses puisque chaque interface permettant la communication avec la version 6 d'IP dispose par défaut d'une adresse auto allouée dite lien local (link-local) dans le réseau particulier fe80::/64 ne pouvant servir qu'à la communication sur le réseau physique (appelé lien local, dans la terminologie IP)
```

Tant que le réseau physique n'est pas connecté à d'autres réseaux, et notamment pas à Internet, on peut choisir les adresses IP que l'on souhaite tant qu'elles sont uniques localement (en pratique, on ne le fait pas, pour permettre même à un réseau isolé d'être interconnecté plus tard sans avoir à complètement changer le plan d'adressage).  
Mais si le réseau physique est amené à être interconnecté à d'autres réseaux (et notamment Internet) et que l'on ne dispose pas d'adresses IP publiques (allouées par un [RIR](https://fr.wikipedia.org/wiki/Registre_Internet_r%C3%A9gional) ou par un [LIR](https://fr.wikipedia.org/wiki/Local_Internet_registry) qui sont en charge d'en assurer l'unicité sur tout Internet), ou que ses machines doivent ne pas être accessibles depuis Internet, il convient de choisir des adresses à usage privé/local.

Ces adresses sont définies par la [RFC 1918](https://www.rfc-editor.org/rfc/rfc1918.html) pour IPv4. Ce sont les plages:

- `10.0.0.0/8`
- `172.16.0.0/12`
- `192.168.0.0/16`

Pour IPv6, on les appelle les adresses unicast locales uniques (*Unique Local IPv6 Unicast Addresses*) et elles sont définies dans la [RFC 4193](https://www.rfc-editor.org/rfc/rfc4193).  
La plage réservée pour ces adresses est `fc00::/7` mais le $8^{ème}$ bit étant à toujours à 1, elles commencent toutes par `fd`.  
Ces 8 bits de préfixe sont suivi d'un identifiant de site de 40 bits qu'on doit tirer au sort pour en assurer l'unicité.  
Les 16 bits suivant permettent de faire des sous réseaux au besoin et les 64 derniers bits de l'adresse constituent la partie *hôte*.

Plutôt que de sortir tes dés à $2^{40}$ faces, un générateur tel que celui-ci: [Unique Local IPv6 Generator](https://www.unique-local-ipv6.com/), peut-être pratique pour tirer au sort un identifiant de site pour ton réseau (et les sous-réseaux qui le composent dans le cas d'un redécoupage en sous-réseaux local).

## 📚 Sortir du réseau

Le propos du protocole IP - *Internet Protocol* - est de permettre l'interconnexion de réseaux (comme son nom l'indique).  
Il permet donc à des machines sur des réseaux physiques différents (et donc sur des réseaux IP différents) de communiquer ensemble à condition que ces réseaux soient reliés, directement ou indirectement, par des passerelles (des équipements connectés à plusieurs réseaux simultanément) appelées **routeurs**.

La vidéo suivante en rappelle rapidement le principe.

L'interconnexion des réseaux pouvant être quelconque, il peut y avoir plusieurs routeurs sur un même réseau.  
Par ailleurs, un routeur peut donner accès, via d'autres routeurs, à d'autres réseaux que ceux auxquels il est directement connecté. Il peut même exister des boucles, c'est à dire plusieurs chemins pour accéder à une même destination.

Une nœud IP cherchant à communiquer avec un nœud sur un réseau différents du sien est donc face à un problème: à quel **routeur auquel je suis directement connecté** (i.e. sur le même réseau que moi) dois-je envoyer mon paquet pour qu'il puisse atteindre sa destination finale?

Cette information se trouve dans une structure de données présente sur chaque nœud d'un réseau IP qu'on appelle la **table de routage**.

En résumé, cette table est une liste de destinations (donc d'adresses de réseaux). Chaque destination est associée à l'adresse du routeur (obligatoirement présent sur un des réseaux de la machine, donc directement accessible) qui permet, en principe, d'y accéder.

```shell
Un exemple
Dans cette exemple, on utilisera des adresses fictives qu'on écrira @<un texte>. Elles pourraient être remplacées par des adresses IP version 4 ou 6. Le principe du routage et de la table de routage étant identique pour les 2 versions.
Admettons que sur un réseau se trouve 2 routeurs. Le routeur d'adresse @a et celui d'adresse @b.

Le routeur @a permet d’accéder aux réseaux @r1 et @r2.

Le routeur @b permet d'accéder au réseau @r3.

La table de routage des nœuds de ce réseau devraient donc être de la forme
DestinationPasserelle@r1@a@r2@a@r3@b
```

Lorsqu'une machine veut envoyer un paquet à une destination qui n'est pas sur un de ses réseaux, elle parcourt sa table de routage en se posant pour chaque ligne la question:

"Le destinataire du paquet fait-il partie de ce réseau destination?"

Si oui $\Rightarrow$ je dois transmettre le paquet à la passerelle.

```shell
Attention : le paquet IP ne devient pas un paquet à destination de la passerelle. L'adresse de destination précisée dans l'entête IP reste celle du destinataire final.

C'est la trame construite par le routeur pour encapsuler le paquet qui aura pour destinataire l'adresse de la passerelle, au sens du protocole physique sous-jacent (par exemple une adresse MAC pour Ethernet).
```

Pour réduire la taille de la table de routage, il est possible de regrouper plusieurs réseaux accessibles par la même passerelle en construisant une adresse de réseau englobante.

Par exemple, si un routeur donné est la passerelle pour le réseau `2001:0:0:1::/64` et pour le réseau `2001:0:0:3::/64`, il est possible de regrouper ces 2 réseaux dans l'adresse `2001::/62`.

Il reste dans ce cas possible qu'un second routeur soit la passerelle pour le réseau `2001:0:0:2::/64`, en effet, lorsqu'un hôte cherche une correspondance dans la table de routage, il ne cherche pas la première correspondance qu'il trouve, mais la plus précise.

Ainsi, même si une adresse en `2001:0:0:2::` est bien comprise dans la destination `2001::/62`, elle est aussi comprise dans `2001:0:0:2::/64` qui est plus précis, car le masque est plus grand.

Il existe dans les tables de routage une adresse destination particulière appelée `default` qui est une correspondance pour toutes les adresses. C'est toujours la correspondance la moins précise.  
On appelle le routeur associé à l'adresse `default` la **passerelle par défaut**.

La table de routage de nombreux hôtes du réseaux est constituée uniquement d'une passerelle par défaut. C'est le cas de tous les hôtes qui sont connecté à un réseau sur lequel se trouve un seul routeur. Ainsi pour ces machines le routage devient très simple: *"Quand tu ne sais pas, envoie à ta passerelle par défaut"*.

## 📚 Construire les tables de routage

Chaque nœud d'un réseau IP (donc d'une interconnexion de réseaux logiques) doit disposer de sa propre table de routage.

Ces tables de routage peuvent être construites manuellement. C'est tout à fait adapté pour les *petits* réseaux ne comportant que quelques routeurs.

Pour les grands réseaux et/ou ceux étant fréquemment modifiés, on utilise des protocoles de routage tels qu'OSPF qui permettent aux routeurs d'échanger des informations pour calculer automatiquement leurs tables de routage.

Les tables de routage peuvent être configurées à la main sur chaque nœud, mais pour les hôtes d'un réseaux, il est fréquent de les configurer de façon centralisée avec **DHCP** ou via les paquets **ICMPv6** type **Router Advertisement** pour IPv6.

```shell
Le paquet Router Advertisement
Au chapitre 4 de cet article de François Goffinet tu as une explication sur le fonctionnement des paquets RA.https://cisco.goffinet.org/ccna/services-infrastructure/gestion-adresses-ipv6-autoconfiguration-dhcpv6/
```

---

## 👉 Configurer un routeur GNU/Linux

Dans la suite de cette quête, tu vas construire une interconnexion de réseaux IP nécessitant du routage et où les routeurs sont des machines **GNU/Linux** sous **Debian**.

Ton *lab* pour faire cette mise en pratique peut-être un réseau physique avec des machines physiques quelconques si vous disposez d'au moins:

- 4 switches ethernet
- 3 ordinateurs équipés de 2 cartes réseaux (pour l'installation des routeurs linux)
- 4 ordinateurs quelconques pour simuler les clients du réseaux.

Il peut aussi être virtuel avec **GNS3** ou un autre système de virtualisation.

```shell
Créer un lab réseau sans se ruiner
Cet article d'Enix décrit les enjeux et la mise en place d'un lab GNS3.

Tu peux le parcourir rapidement pour voir ce qui s'y dit et comparer avec ce que tu as déjà expérimenté.

Il n'est pas nécessaire de réaliser l'ensemble des manipulations qui y sont décrites, même si il n'est jamais perdu de faire des exercices.https://enix.io/fr/blog/creer-un-lab-reseau-sans-se-ruiner/
```

## 📑 La configuration réseau sous GNU/Linux (rappel)

La configuration du réseau sous GNU/Linux peut être fait dynamiquement à l'aide de la commande `ip`.  
Les modifications sont alors effectives immédiatement. En revanche, elles ne sont pas stockées dans la configuration de la machine et disparaissent alors à chaque redémarrage.

```shell
Introduction à la commande iphttps://fr.linux-console.net/?p=22834
```

La commande `ip` permet donc de gérer les adresses IP des différentes interfaces avec `ip address` mais aussi la table de routage de la machine avec `ip route`

Comme d'habitude, le `man` permet d'avoir toutes les informations sur cette commande, les possibilités qu'elle offre et sa syntaxe.

Il y a d'ailleurs des pages de `man` spécifiques pour la gestion des adresses et des routes:

- `man ip-address`
- `man ip-route`
```shell
Ces modifications dynamiques sont très utiles pour tester des configurations et valider que tout fonctionne bien. Mais lorsqu'on a les configurations définitives des machines, il est préférable qu'elles soient permanentes.
```

La configuration au démarrage de la machine s'effectuent elle, via des fichiers de configuration.  
Ces fichiers peuvent différer selon les distributions. Sous **Debian** et les distributions qui en sont issues (**Ubuntu**, **Mint**, **Kali**, **Tails**...) c'est le fichier `/etc/network/interfaces` (et éventuellement les fichiers présent dans le dossier `/etc/network/interfaces.d`) qui est utilisé.

Là aussi, il est possible de consulter avec profit `man interfaces`, mais tu peux aussi te reporter aux 2 ressources suivantes pour retrouver les informations sur la configuration réseau, et notamment la configuration d'une table de routage statique.

```shell
Network Configuration
Le Debian Wiki dispose d'une page dédiée à la configuration réseau disponible en français.https://wiki.debian.org/fr/NetworkConfiguration
```
```shell
Debian Permanent Static Routes
Décrit la configuration de table de routage statiques sur une Debianhttps://www.mybluelinux.com/debian-permanent-static-routes/
```

## 🔬 Exercice - étape 1

Commence par construire un réseau physique avec 2 machines et fait communiquer ces 2 machines avec IPv4 et IPv6.

Pour pouvoir utiliser des adresses privées pour ces machines, notamment pour IPv6, il te faut un identifiant de site: 40 bits tirés au sort.  
Pour rappel, tu peux utiliser [Unique Local IPv6 Generator](https://www.unique-local-ipv6.com/).

Dans la suite de la quête, on utilise l'identifiant: `d3:9430:138e`, donc le préfixe `fdd3:9430:138e`.  
Mais pour respecter le protocole, tu dois bien avoir **ton propre identifiant aléatoire** pour ta mise en œuvre!

Configure la première machine (10) avec: `10.0.0.10/24` et `fd<ton id de site>::10/64` (pour l'exemple: `fdd3:9430:138e::10/64`) et la deuxième machine (11) avec: `10.0.0.11/24` et `fd<ton id de site>::11/64`

Test, par exemple avec `ping`, qu'il est possible de joindre la première machine à partir de la deuxième et vice-versa.

```shell
Après avoir réussi tes tests, tu peux comparer ta configuration et les commandes exécutées avec cet exemple1

2
# Configuration dynamique de la machine 10
3
$ sudo ip address add 10.0.0.10/24 dev ens4
4
$ ping 10.0.0.11
5
PING 10.0.0.11 (10.0.0.11) 56(84) bytes of data.
6
64 bytes from 10.0.0.11: icmp_seq=1 ttl=64 time=0.700 ms
7
^C
8
$ sudo ip address add fdd3:9430:138e::10/64 dev ens4
9
$ ping fdd3:9430:138e::11
10
PING fdd3:9430:138e::11(fdd3:9430:138e::11) 56 data bytes
11
64 bytes from fdd3:9430:138e::11: icmp_seq=1 ttl=64 time=0.679 ms
12
^C
13

14
# Configuration statique de la machine 10
15
# Fichier /etc/network/interfaces
16
auto ens4
17
# IPv4 configuration
18
iface ens4 inet static
19
  address 10.0.0.10/24
20
# IPv6 configuration
21
iface ens4 inet6 static
22
  address fdd3:9430:138e::10/64
23

24
Voir l'exemple
```

## 🔬 Exercice - étape 2

On ajoute maintenant un routeur (r0) à ce réseau.

Ce routeur dispose de 2 interfaces réseaux.  
La première est sur le même réseau que les machines 10 et 11 avec la configuration suivante:

- `10.0.0.1/24` et `fd<ton id de site>::1/64`

La seconde est sur un second réseau ethernet qui accueillera d'autres routeurs plus tard. Sa configuration est:

- `192.168.0.250/24` et `fd<ton id de site>:192::250/64`

En plus de configurer les interfaces réseaux de cette machine, il faut aussi activer le routage IPv4 et IPv6 au niveau du noyau comme indiqué dans l'article suivant.

```shell
Activer l’IP forwarding sous Linux (IPv4/IPv6)
Comment configurer la pile IP d'un linux en routeurhttps://www.it-connect.fr/activer-lip-forwarding-sous-linux-ipv4ipv6/
```

À ce stade, les 3 interfaces présentent sur le réseau `10.0.0.0/24` / `fd<ton id de site>::/64` peuvent communiquer.  
Valide ta configuration avec `ping` dans tous les sens.

Il reste une interface avec laquelle les machines 10 et 11 ne peuvent pas encore communiquer, c'est `192.168.0.250/24` / `fd<ton id de site>:192::250/64`.  
En effet, elle n'est pas sur le même réseau, il faut indiquer une passerelle.  
Cette passerelle, peut tout à fait être une passerelle par défaut puisqu'il n'y a qu'un routeur sur le réseau `10.0.0.0/24` / `fd<ton id de site>::/64`.

Renseigne cette passerelle par défaut dans la table de routage sur les machines 10 et 11, puis vérifie qu'il est maintenant possible de joindre `192.168.0.250/24` et `fd<ton id de site>:192::250/64` depuis les machines 10 et 11.

```shell
Après avoir réussi tes tests, tu peux comparer ta configuration et les commandes exécutées avec cet exemple1

2
# Configuration dynamique de la table de routage sur la machine 10 ou 11
3
$ sudo ip route add default via 10.0.0.1
4
$ ping 192.168.0.250
5
PING 192.168.0.250 (192.168.0.250) 56(84) bytes of data.
6
64 bytes from 192.168.0.250: icmp_seq=1 ttl=64 time=1.71 msip 
7
^C
8
$ sudo ip route add default via fdd3:9430:138e::1
9
$ ping fdd3:9430:138e:192::250
10
PING fdd3:9430:138e:192::250(fdd3:9430:138e:192::250) 56 data bytes
11
64 bytes from fdd3:9430:138e:192::250: icmp_seq=1 ttl=64 time=0.618 ms
12
^C
13

14
# Configuration statique de la machine 10
15
# Fichier /etc/network/interfaces
16
auto ens4
17
iface ens4 inet static
18
    address 10.0.0.10
19
    netmask 255.255.255.0
20
    gateway 10.0.0.1
21

22
iface ens4 inet6 static
23
    address fdd3:9430:138e::10
24
    netmask 64
25
    gateway fdd3:9430:138e::1
26

27
Voir l'exemple
```

---

## ☝️ Résumé

Les tables de routage permettent d'indiquer par quel·s routeur·s passer pour sortir du réseau.

Le noyau Linux peut se comporter comme un routeur, il est donc possible de monter une infrastructure réseau complète en se basant uniquement sur des machines classiques sous GNU/Linux.

---

## 📝 Quiz

```shell
# 1  - Seuls les routeurs ont besoin d'une table de routageVraiFauxValider# 2 Le routeur destinataire de tous les paquetsLe routeur destinataire des paquets qui n'ont pas d'autres correspondances dans la table de routageLa passerelle qui existe quand aucune configuration n'est faiteValider# 3 Seulement avec certaines distributions spécialiséesSeulement avec certains matériels spécialisésDans tous les casValiderTon score :0 / 3
```

---

## 💪 Challenge

À la suite de l'étape 2:

Ajoute 2 autres routeurs (r1 et r2) sur le réseau `192.168.0.0/24` / `fd<ton id de site>:192::/64`.

Ces 2 routeurs ont eux aussi 2 interfaces réseaux.

La configuration de r1 est:

- Interface 1: `192.168.0.251/24` et `fd<ton id de site>:192::251/64`
- Interface 2: `10.0.1.1/24` et `fd<ton id de site>:1::1/64`

et celle de r2 est:

- Interface 1: `192.168.0.252/24` et `fd<ton id de site>:192::252/64`
- Interface 2: `10.0.2.1/24` et `fd<ton id de site>:2::1/64`

Ajoute aussi une machine (12) sur le réseau `10.0.1.0/24` / `fd<ton id de site>:1::/64` avec les configurations:

- `10.0.1.12/24` et `fd<ton id de site>:1::12/64`

et une machine (13) sur le réseau `10.0.2.0/24` / `fd<ton id de site>:2::/64` avec les configurations:

- `10.0.2.13/24` et `fd<ton id de site>:2::13/64`.
```shell
Un indice pour t'aiderLes tables de routage des routeurs ne peuvent pas être constituées uniquement d'une passerelle par défaut puisqu'il y a 2 routeurs en plus d'eux-même sur leur réseau.
Il faut donc indiquer pour r0 que l'accès à 10.0.1.0/24/fd<ton id de site>:1::/64 s'effectue via r1 et que l'accès à  10.0.2.0/24/fd<ton id de site>:2::/64 s'effectue via r2 et ainsi de suite pour les autres routeurs.Voir
```

Configure toutes les machines pour que la communication soit possible depuis n'importe laquelle vers toutes les autres puis poste les commandes permettant la configuration dynamique de chacune et les fichiers de configuration de toutes les machines.

## 🧐 Critères d'acceptation

Les commandes données et les fichiers de configuration proposés permettent chacun de faire communiquer l'ensemble des machines suivantes:

- machine 10
- machine 11
- machine 12
- machine 13
- routeur r0
- routeur r1
- routeur r2

L'identifiant de site utilisé pour le réseau IPv6 est bien aléatoire.

---

Contribuer à améliorer cette quête.Tous les retours sont précieux pour l'amélioration de nos formations.

Le contenu de la quête m'a permis de comprendre les concepts et d'atteindre les objectifs annoncés:

---

Un commentaire pour nous aider à mieux comprendre?