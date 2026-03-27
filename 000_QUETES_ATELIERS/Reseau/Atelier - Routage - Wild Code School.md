---
title: "Atelier : Configurer un réseau IP avec GNS3 - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2935/pages/18614"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Atelier: Configurer un réseau IP avec GNS3

Facile

2h

Auto-validation

Réseau

## Atelier: Configurer un réseau IP avec GNS3

## Introduction

Avec GNS3 (Graphical Network Simulation 3) tu vas apprendre à créer un réseau, et à faire communiquer les élements qui le composent.  
Le but de cet atelier est de te faire configurer des adresses ipv4 statique, explorer la notion de réseau, et de manipuler GNS3.  
Les VPCS (ou ***Virtual PC Simulator***) sont les ***ordinateurs clients*** inclus de base avec GNS3. Avec ceux-ci, tu vas pouvoir configurer des adresses IP, des masques, etc. Tu vas pouvoir également éxecuter des commandes comme **ping**. Tu auras toute la liste des commandes en tapant "**?**" dans une console de VPCS.

## 📚 Pré-requis

Avant de commencer cet atelier, il est préférable d'avoir déjà terminé la quête suivante:

```shell
GNS3 : Graphical Network Simulator-3GNS3 est un logiciel libre pour la simulation de réseaux.1h 30minsVoir la quête - GNS3 : Graphical Network Simulator-3
```

## 🤓 Objectifs:

✅ Pratiquer la configuration d'une interface réseau  
✅ Mettre en place un réseau IPv4 entre 2 machines  
✅ Faire communiquer ces 2 machines entre-elles  
✅ Utiliser les commandes réseau de base (`ip`, `ping`...)

## Sommaire

- [✔️ Prérequis](https://odyssey.wildcodeschool.com/quests/2935/pages/18614#%EF%B8%8F-pr%C3%A9requis)
- [👉 Création d'un réseau simple avec 2 VPCS](https://odyssey.wildcodeschool.com/quests/2935/pages/18614#-cr%C3%A9ation-dun-r%C3%A9seau-simple-avec-2-vpcs)
	- [⚙️ Configuration du réseau](https://odyssey.wildcodeschool.com/quests/2935/pages/18614#%EF%B8%8F-configuration-du-r%C3%A9seau)
		- [💬 Test de connectivité réseau](https://odyssey.wildcodeschool.com/quests/2935/pages/18614#-test-de-connectivit%C3%A9-r%C3%A9seau)
		- [💾 Sauvegarde de la configuration](https://odyssey.wildcodeschool.com/quests/2935/pages/18614#-sauvegarde-de-la-configuration)
		- [🔬 Ajout d'un switch au réseau](https://odyssey.wildcodeschool.com/quests/2935/pages/18614#-ajout-dun-switch-au-r%C3%A9seau)
		- [🔍 Utilisation de Wireshark pour analyser le réseau](https://odyssey.wildcodeschool.com/quests/2935/pages/18614#-utilisation-de-wireshark-pour-analyser-le-r%C3%A9seau)
- [👉 Création d'un réseau avec 2 machines Alpine Linux](https://odyssey.wildcodeschool.com/quests/2935/pages/18614#-cr%C3%A9ation-dun-r%C3%A9seau-avec-2-machines-alpine-linux)
	- [⚙️ Configuration du réseau](https://odyssey.wildcodeschool.com/quests/2935/pages/18614#%EF%B8%8F-configuration-du-r%C3%A9seau-1)
		- [💬 Test du réseau](https://odyssey.wildcodeschool.com/quests/2935/pages/18614#-test-du-r%C3%A9seau)
- [💪 Conclusion](https://odyssey.wildcodeschool.com/quests/2935/pages/18614#-conclusion)

## ✔️ Prérequis

Logiciels installés sur ta machine hôte:

- GNS3, avec un template Alpine Linux d'installé
- Wireshark

> Cet atelier a été réalisé et testé sous **Ubuntu 22.04**. GNS3 est indépendant de l'OS sur lequel il est installé. Malgré cela, si tu utilise une autre version ou un autre OS, il y aura peut-être des ajustements à faire.

```shell
Les expérimentations pratiques ont été réalisées et testées sous Ubuntu 22.04.

GNS3 est indépendant de l'OS sur lequel il est installé. Malgré cela, si tu utilise une autre version ou un autre OS, des différences peuvent alors apparaître et il y aura peut-être des ajustements à faire.
```

## 👉 Création d'un réseau simple avec 2 VPCS

## ⚙️ Configuration du réseau

Voici le schéma du réseau que tu vas réaliser:

![schéma GNS3 de 2 VPCS reliés entre-eux](https://storage.googleapis.com/assets_upload_prod/AAbYqbgdkoZJONQ2jUI4vzA89s17Dzuy.png)

Voici le plan d'adressage:

| Matériel | Adresse IP | Masque de sous-réseau |
| --- | --- | --- |
| PC1 | 10.1.1.1 | 255.255.255.0 |
| PC2 | 10.1.1.2 | 255.255.255.0 |

Manipulations pratiques:

- Mettre 2 VPCS dans la fenêtre projet de GNS3
- Les renommer PC1 et PC2
- Les relier par un câble
- Allumer les VPCS
- Ouvrir les consoles de chaque VPCS

La configuration réseau se fera sous la forme:

- `ip adresseIP masqueIP passerelleIP`  
	OU
- `ip adresseIP/CIDR passerelleIP`

Soit pour **PC1**:

```shell
1
PC1> ip 10.1.1.1 255.255.255.0 10.1.1.254
```

Ou bien:

```shell
1
PC1> ip 10.1.1.1/24 10.1.1.254
```

> ℹ️ Dans cet atelier, tu n'es pas obligé de configurer une passerelle

Pour connaitre la configuration:

```shell
1
PC1> show ip
```

Une fois PC1 configuré, fais les mêmes actions de configuration réseau pour **PC2**.

## 💬 Test de connectivité réseau

On doit pouvoir faire un ping entre PC1 et PC2.

Sur PC1:

```shell
1
PC1> ping 10.1.1.2
2
84 bytes from 10.1.1.2 icmp_seq=1 ttl=64 time=0.098 ms
3
84 bytes from 10.1.1.2 icmp_seq=2 ttl=64 time=0.209 ms
4
84 bytes from 10.1.1.2 icmp_seq=3 ttl=64 time=0.197 ms
5
84 bytes from 10.1.1.2 icmp_seq=3 ttl=64 time=0.197 ms
6
PC1>
```

Faire la même chose sur PC2 en faisant un ping vers PC1.

```shell
Dans le cadre de cette configuration IP, le ping de PC2 vers PC1 doit être fonctionnel.

Néanmoins, dans des cas de configuration précis, cette réciprocité n'est pas automatique.
```

## 💾 Sauvegarde de la configuration

Pour sauvegarder la configuration sur PC1:

```shell
1
PC1> save
2
Saving startup configuration to startup.vpc
3
.  done
4
PC1>
```

Faire la même chose sur PC2.

> ℹ️ Tu peux aussi enregistrer la configuration à partir du menu ***edit config*** de chaque matériel.

```shell
Tu viens de faire communiquer tes 2 machines !
```

## 🔬 Ajout d'un switch au réseau

Voici le schéma du réseau que tu vas réaliser:

![schéma GNS3 de 2 VPCS reliés entre-eux par un switch](https://storage.googleapis.com/assets_upload_prod/B4N2KfbK2KsZ8OPeLcgB3kLc5Yzoq4VE.png)

- Ajouter un switch de type **Ethernet Switch** sur le plan.
- Supprimer le câble qui relie les 2 PC et relier chaque PC à l'un des ports du switch.
- Sans changer la configuration des 2 VPCs, vérifier que le ping fonctionne toujours.

## 🔍 Utilisation de Wireshark pour analyser le réseau

**Analyse réseau 1**

- En cliquant sur l'un des câbles qui relient les VPCs au switch, cliquer sur `Start capture`
- Wireshark va s'ouvrir et la capture va commencer (sniff réseau).
- Lance un **ping** de **PC1** vers **PC2** et de **PC2** vers **PC1**.
- Examine ce qui se passe sur les machines (dans leur console) et sur le réseau avec Wireshark.

**Analyse réseau 2**

- Maintenant configurer un des VPCS sur un réseau IP différent
- Reproduire l’expérience du ping. Que constate-tu?

**Analyse réseau 3**

- Maintenant configurer un VPCS pour qu'il soit sur le même réseau que le second, mais le second pour qu'il ne soit pas sur le même réseau  
	Par exemple:  
	Le premier en 10.0.0.200/24 et le second en 10.0.0.1/25
- Reproduire l'expérience du ping
- Que constate-tu et pourquoi as-tu ce résultats?

Si tu ne l'as pas fait, créer des configurations statiques (pour qu'elle reste à chaque démarrage) en mettant toutes les machines sur le même réseau.

> Cela se fait en allant dans `Edit Config` dans le menu (bouton droit souris) des VPCs).

## 👉 Création d'un réseau avec 2 machines Alpine Linux

Récupère le projet ci-dessous et ouvre-le dans GNS3.

```shell
https://github.com/WildCodeSchool/TSSR_Resources/raw/main/Ressources_ateliers/BasicNetwork.gns3project
```

Une fois le projet ouvert, tu dois voir deux machines Linux (Alpine) connectées à un switch.

```shell
Si tu as une erreur à l'ouvertur du projet, installe le template pour une machine Alpine
```

## ⚙️ Configuration du réseau

Une fois le projet ouvert, démarre les machines.  
Tous les points d'interconnexion entre les machines et le switch doivent être verts.

Tu peux ensuite ouvrir un terminal pour chaque machine en effectuant un clic droit dessus et en sélectionnant **Console** ou **Custom Console**.

Une fois connecté à une machine, tu peux vérifier l'état de l'interface réseau avec la commande `ip a`:

```bash
1
alpine:~# ip a
2
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
3
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
4
    inet 127.0.0.1/8 scope host lo
5
       valid_lft forever preferred_lft forever
6
    inet6 ::1/128 scope host 
7
       valid_lft forever preferred_lft forever
8
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
9
    link/ether 0c:ac:14:5b:00:00 brd ff:ff:ff:ff:ff:ff
10
    inet6 fe80::eac:14ff:fe5b:0/64 scope link 
11
       valid_lft forever preferred_lft forever
```

Comme tu peux le voir, l'interface réseau `eth0` n'a pas d'adresse IPv4, car elle n'est pas encore configurée.

Tu peux paramétrer une adresse IP avec la commande `ip` par exemple `ip 192.168.1.1 255.255.255.0`, mais cette configuration ne persistera pas après le redémarrage de la machine, n'hésite pas à faire le test.

Tu peux voir la configuration de l'interface réseau dans le fichier `/etc/network/interfaces`:

```bash
1
alpine:~# cat /etc/network/interfaces
2
auto lo
3
iface lo inet loopback
4

5
auto eth0
6
iface eth0 inet manual
7
# DHCP
8
#iface eth0 inet dhcp
9
# Static
10
#iface eth0 inet static
11
#    address IP_ADDRESS/MASK
12
#    gateway GW_IP_ADDRESS
13
#    dns-nameserver DNS_IP_ADDRESS
```

Comme tu peux le voir, l'interface réseau `eth0` est configurée en manuel.

L'interface n'est pas en DHCP et aucune adresse IP n'est configurée en statique (le caractère `#` permet de commenter une ligne).

Tu vas configurer l'interface réseau en IPv4 statique avec l'adresse `192.168.1.20` et un masque `24` (ou `255.255.255.0`).

```shell
Rappel : le masque permet de définir la taille du réseau. Un masque 24 permet d'avoir 256 adresses IP dans le réseau, dont 254 utilisables pour les machines (1 est réservée pour le réseau et 1 pour le broadcast).
```

Tu peux donc configurer l'interface réseau en IPv4 statique en modifiant le fichier `/etc/network/interfaces`. Sur cette machine, seul l'éditeur `vi` est installé, tu peux donc l'utiliser pour modifier le fichier.

```shell
On peut configurer la passerelle et le serveur DNS sur ce même fichier. Toutefois, nous ne le ferons pas pour le moment, car nous n'en avons pas besoin.
```
```shell
Si tu as besoin de comprendre un peu mieux comment fonctionne vi, tu peux consulter ce lien.https://www.redhat.com/sysadmin/introduction-vi-editor
```
```shell
Pour rappel, tu peux utiliser la touche i pour passer en mode édition, puis la touche ESC pour revenir en mode commande.

Enfin, tu peux utiliser la commande :wq pour enregistrer et quitter le fichier.
```
```bash
1
alpine:~# vi /etc/network/interfaces
```

Une fois le fichier ouvert, tu peux modifier la configuration de l'interface réseau comme ceci:

```bash
1
auto lo
2
iface lo inet loopback
3

4
auto eth0
5
iface eth0 inet static
6
address 192.168.1.20/24
7
gateway 192.168.1.1
```

Tu vas ensuite configurer le serveur DNS en modifiant le fichier `/etc/resolv.conf`:

```bash
1
alpine:~# vi /etc/resolv.conf
2
nameserver 1.1.1.1
3
nameserver 8.8.8.8
```

Tu peux ensuite redémarrer l'interface réseau pour prendre en compte les modifications:

```bash
1
alpine:~# ifdown eth0 && ifup eth0
```
```shell
Ces commandes permettent de désactiver (ifdown) puis d'activer (ifup) l'interface réseau eth0, ce qui permet de prendre en compte les modifications apportées au fichier /etc/network/interfaces.
```

Tu peux ensuite vérifier que l'interface réseau est bien configurée avec la commande `ip a`:

```bash
1
alpine:~# ip a
2
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
3
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
4
    inet 127.0.0.1/8 scope host lo
5
       valid_lft forever preferred_lft forever
6
    inet6 ::1/128 scope host 
7
       valid_lft forever preferred_lft forever
8
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
9
    link/ether 0c:ac:14:5b:00:00 brd ff:ff:ff:ff:ff:ff
10
    inet 192.168.1.20/24 scope global eth0
11
       valid_lft forever preferred_lft forever
12
    inet6 fe80::eac:14ff:fe5b:0/64 scope link 
13
       valid_lft forever preferred_lft forever
```

Tu peux maintenant reproduire la même configuration sur la deuxième machine.

```shell
Attention : Les adresses IP doivent être différentes pour chaque machine mais dans le même sous-réseau (ex: 192.168.1.20 et 192.168.1.21) !
```

## 💬 Test du réseau

Nous allons maintenant pouvoir tester le réseau en effectuant un ping entre les deux machines.

Pour cela, tu peux utiliser la commande `ping`, par exemple depuis la première machine:

```bash
1
alpine:~# ping 192.168.1.21
2
alpine:~# ping 192.168.1.21
3
PING 192.168.1.21 (192.168.1.21): 56 data bytes
4
64 bytes from 192.168.1.21: seq=0 ttl=64 time=1.432 ms
5
64 bytes from 192.168.1.21: seq=1 ttl=64 time=1.754 ms
6
64 bytes from 192.168.1.21: seq=2 ttl=64 time=1.614 ms
7
64 bytes from 192.168.1.21: seq=3 ttl=64 time=1.568 ms
```

Cette commande permet d'envoyer des paquets ICMP (Internet Control Message Protocol) à une adresse IP. Si la machine cible répond, alors le ping est réussi.

```shell
Sour Linux, la commande continue d'envoyer des paquets tant que tu ne l'arrêtes pas avec la combinaison de touches CTRL + C.
```

---

## 💪 Conclusion

Valide l'atelier si tu es en mesure d'effectuer des pings entre les deux VPCs et les deux machines Alpine Linux.

Quête terminée le **vendredi 21 novembre 2025**