---
title: "Le protocole DHCP - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2270/pages/18625"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Le protocole DHCP

Facile

1h

Quiz

Réseau

## Le protocole DHCP

## Introduction

Le protocole **DHCP** (**D** ynamic **H** ost **C** onfiguration **P** rotocol) est un protocole client/serveur qui fournit automatiquement aux hôtes d'un réseau physique, une configuration IP: C'est à dire une adresse IP mais aussi, un masque de sous-réseau, une passerelle par défaut, ou bien encore des adresses de résolveurs DNS.  
Les RFC [2131](https://www.rfc-editor.org/rfc/rfc2131) et [2132](https://www.rfc-editor.org/rfc/rfc2132) définissent DHCP comme norme IETF (**I** nternet **E** ngineering **T** ask **F** orce), compatible avec le protocole BOOTP (*Bootstrap Protocol* - RFC [951](https://www.rfc-editor.org/rfc/rfc951)), un protocole avec lequel DHCP partage de nombreux détails d’implémentation. DHCP sert de remplaçant à RARP (RFC [903](https://www.rfc-editor.org/rfc/rfc903)) qui permet aussi l'auto-configuration d'hôtes du réseau, mais statiquement.

En résumé DHCP permet aux hôtes d’obtenir les informations de configuration IP requises à partir d’un serveur DHCP.

Plus de détails sur les différences entre BootP et DHCP [ici](https://waytolearnx.com/2018/07/difference-entre-bootp-et-dhcp.html).

---

#### ⚠️Avant de commencer cette quête, tu dois avoir terminé les quêtes suivantes:

```shell
À la découverte de l'adresse IP30minsVoir la quête - À la découverte de l'adresse IPDécoupage de réseaux IP2hVoir la quête - Découpage de réseaux IP
```

![image](https://upload.wikimedia.org/wikipedia/commons/4/47/Dhcp-discover.png)

## 🤓 Objectifs:

✅ Comprendre les enjeux de l'adressage IP  
✅ Connaître le fonctionnement général du protocole DHCP

## Sommaire

- [👉 Le problème de l'adressage manuel](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#-le-probl%C3%A8me-de-ladressage-manuel)
	- [Ajout d'un nouvel hôte au réseau](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#ajout-dun-nouvel-h%C3%B4te-au-r%C3%A9seau)
		- [Plage réseau pleine](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#plage-r%C3%A9seau-pleine)
- [👉 Le fonctionnement général de DHCP](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#-le-fonctionnement-g%C3%A9n%C3%A9ral-de-dhcp)
	- [Découverte et communication avec le serveur](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#d%C3%A9couverte-et-communication-avec-le-serveur)
		- [La gestion de la plage IP par le serveur](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#la-gestion-de-la-plage-ip-par-le-serveur)
		- [🔬 Calcul du nombre d'adresses disponible sur une plage](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#-calcul-du-nombre-dadresses-disponible-sur-une-plage)
		- [Le cas de serveurs DHCP multiples](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#le-cas-de-serveurs-dhcp-multiples)
		- [Gestion de la dynamique du réseau](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#gestion-de-la-dynamique-du-r%C3%A9seau)
		- [🔬 Calcul du nombre d'adresses disponible sur une plage avec exception d'adresses](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#-calcul-du-nombre-dadresses-disponible-sur-une-plage-avec-exception-dadresses)
- [👉 Pour aller plus loin](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#-pour-aller-plus-loin)
	- [Agent relais DHCP](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#agent-relais-dhcp)
		- [Tolérance de pannes](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#tol%C3%A9rance-de-pannes)
- [👉 La configuration cliente](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#-la-configuration-cliente)
	- [🖥️ Configuration DHCP cliente sous Windows](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#%EF%B8%8F-configuration-dhcp-cliente-sous-windows)
		- [🖥️ Configuration DHCP cliente sous GNU/Linux](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#%EF%B8%8F-configuration-dhcp-cliente-sous-gnulinux)
- [👉 Le cas IPv6](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#-le-cas-ipv6)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [💻 Le serveur DHCP](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#-le-serveur-dhcp)
		- [📏 Étendue DHCP](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#-%C3%A9tendue-dhcp)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#-challenge)
	- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2270/pages/18625#-crit%C3%A8res-dacceptation)

## 👉 Le problème de l'adressage manuel

Regardons ensemble les enjeux de la configuration réseau d'une machine:

- Elle doit disposer d'une adresse unique. Il ne doit pas y avoir d'adresses en doublon sur un même réseau
- Elle doit disposer d'une configuration réseau compatible avec les autres machines, c'est à dire considérer que le réseau dont elle fait partie englobe l'ensemble des autres machines. Sinon elle ne pourrait pas leur envoyer de paquets directement.
- Elle doit disposer d'une adresse IP appartenant au réseau des autres machines, c'est à dire que *toutes* les autres machines considèrent que la nouvelle machine est dans leur réseau. Sinon ces machines ne pourraient pas envoyer de paquet directement au nouvel hôte du réseau.
- Elle doit disposer des informations complémentaires nécessaires (routage, résolution de nom, etc...)

## Ajout d'un nouvel hôte au réseau

Prenons pour exemple un réseau local tel que celui qui est probablement chez toi, constitué par une box internet fournie par ton Fournisseur d'Accès Internet (FAI)

Supposons une configuration réseau classique.  
L'ensemble des équipements du réseau communiquent en utilisant le réseau logique 192.168.0.0/24

L'adresse du réseau: 192.168.0.0 n'est donc pas utilisable par un hôte, ainsi que l'adresse 192.168.0.255 qui est réservée pour la diffusion (*broadcast*) sur ce réseau.

La box dispose de l'adresse 192.168.0.254

On souhaite ajouter un nouveau matériel (un ordinateur portable par exemple) au réseau:

🤔 **1er problème**: il doit être sur le même réseau que les autres équipements

On opte pour une configuration en 192.168.0.x/24

🤔 **2ème problème**: il lui faut une adresse différente de tous les autres équipements de ce réseau.

Le réseau contient, en plus de la box, un ordinateur fixe en 192.168.0.1.

On pourrait donc opter pour 192.168.0.2 mais il faut aussi tenir compte de tous les équipements qui se connectent sur ce réseau, même épisodiquement, et qui pourraient ne pas être actuellement allumé.

Le réseau contient aussi:

- une tablette en 192.168.0.2
- une console de jeu en 192.168.0.10
- deux smartphones en 192.168.0.100 et 192.168.0.101
- une imprimante réseau en 192.168.0.250

On peut donc choisir, par exemple, 192.168.0.3/24 pour l'ordinateur portable.

Un autre court exemple en vidéo:

🤔 **Plus généralement**: comment connaître la liste exhaustive de l'ensemble des équipements qui se connectent à un moment ou à un autre sur ce réseau et de leur configurations réseau?

**Une solution**: avoir un document avec la liste équipements et de leurs adresses 📝.

🤔 **Nouveau problème:** Il ne faut **jamais** oublier de mettre à jour cette la liste à chaque déploiement de nouvelles machines, à chaque suppression définitive de machines et plus généralement à chaque modification des éléments du réseaux.

## Plage réseau pleine

Supposons un nouveau cas de figure: Nous sommes arriver à la fin de la plage qu'on avait prévue.  
Par exemple: il y a 254 adresses réservées dans la liste pour notre /24

**Remarque:** Peut-être a-t-on oublié d'enlever des configurations quand on a enlevé des machines?

Dans le cas où il n'y a effectivement plus d'adresses disponibles dans la plage, il faut une plage réseau plus grande. Il faut donc changer, à la main, la configuration des 254 machines pour pouvoir en ajouter une nouvelle 😭!

**Conclusion:** Un mécanisme d'adressage automatique permettant une gestion centralisée de ces problèmes est indispensable dès que le réseau contient plus de quelques hôtes.

## 👉 Le fonctionnement général de DHCP

L'idée générale est de centraliser la configuration de l'ensemble des machines sur un seul serveur.

**Inconvénient:** Le problème du boot!  
Comment une machine qui n'a pas de configuration réseau (IP) peut communiquer avec le serveur?

## Découverte et communication avec le serveur

Un serveur DHCP distribue des adresses IP aux hôtes du réseau physique qui le demande en répondant aux requêtes du protocole DHCP.  
Il dispose en ce qui le concerne d'une configuration IP statique.  
Dans un réseau, on peut donc n'avoir qu'une seule machine avec adresse IP fixe: **le serveur DHCP**.

Le mécanisme de base de la communication reprend **BOOTP**. Il circule ainsi dans des datagrammes **UDP**.  
Le port **UDP 67** est réservé pour les messages à destination d'un **serveur** DHCP et le port **UDP 68** pour les messages à destination d'un **client** DHCP.

Quand une machine configurée pour utiliser DHCP est démarrée, elle n'a aucune information sur sa configuration réseau, et surtout, l'utilisateur ne doit rien faire de particulier pour trouver une adresse IP.  
La technique utilisée est le **broadcast**:  
Le client DHCP ne connaît pas l'adresse du serveur DHCP et ne connaît même pas l'adresse du réseau IP sur lequel il se trouve.  
Pour trouver et dialoguer avec un serveur DHCP, le client émet un datagramme UDP à destination du port **67** et provenant du port **68**.  
Le protocole DHCP nécessite la communication de certaines informations dont notamment l'adresse MAC de la machine cliente (pour tous les réseaux physiques utilisant des adresses MAC, comme c'est le cas pour Ethernet ou Wifi).  
Ces informations sont donc incluses dans le datagramme avec le type de requête: **DHCPDISCOVER** dans ce cas.

Ce datagramme est encapsulé dans un paquet IP de diffusion sur le réseau local.  
L'adresse IPv4 de destination est l'adresse diffusion sur un réseau inconnu: **255.255.255.255**  
Le client ne connaissant pas encore son adresse, il ne peut pas choisir d'adresse IPv4 source non plus. Il utilise alors l'adresse indéfinie: **0.0.0.0**

Lorsqu'un serveur DHCP reçoit ce genre de requête, il peut y répondre en proposant une adresse IP selon lui disponible, ainsi que l'ensemble des autres information de configuration.  
Cette proposition, de type **DHCPOFFER**, circule elle aussi dans un datagramme UDP, depuis le port 67 vers le port 68, cette fois.  
Le paquet IP qui transport ce datagramme aura, assez logiquement, l'adresse IP du serveur comme adresse source. Le client saura alors a qui s'adresser pour la suite.  
Et bien que le client ne le sache pas encore, le serveur utilise déjà l'adresse qu'il lui propose comme adresse IP de destination.  
Pour que le paquet arrive au bon destinataire, il est envoyé dans une trame ayant pour adresse MAC de destination celle qui était inclu dans le **DHCPDISCOVER**.  
La réponse n'est ainsi pas un *broadcast*.

```shell
On pourrait croire qu'un seul paquet peut suffire à la bonne marche du protocole. En fait, il existe plusieurs types de paquets DHCP susceptibles d'être émis soit par le client pour le ou les serveurs, soit par le serveur vers un client :
NomDescriptionDHCPDISCOVER  (1)Pour localiser les serveurs DHCP disponibles et demander une première configurationDHCPOFFER (2)Réponse du serveur à un message DHCPDISCOVER, qui contient une proposition de paramètrage DHCPREQUEST (3)Requête du client vers le serveur pour réserver une adresse proposée ou pour prolonger son bailDHCPDECLINE (4)Le client annonce au serveur que l'adresse est déjà utiliséeDHCPACK (5)Réponse du serveur pour accepter une demande (REQUEST) qui contient des paramètres et l'adresse IP du clientDHCPNAK (6)Réponse du serveur pour signaler au client que son bail est échu ou si le client annonce une mauvaise configuration réseauDHCPRELEASE (7)Le client libère son adresse IPDHCPINFORM (8)Le client demande des paramètres locaux, il a déjà son adresse IP

la valeur entre parenthèse est utilisée pour identifier ces requêtes dans les messages DHCP

Voilà ce que cela donne schématiquement, dans un cas ou il y aurait 2 serveurs DHCP sur le même réseau :
```

## La gestion de la plage IP par le serveur

Un serveur DHCP doit être configuré en lui indiquant un ensemble d'adresses IP (une plage) qu'il peut distribuer.  
Une plage d'adresses est en général définie par une adresse de début et une adresse de fin.

Attention, **certaines adresses IP ne doivent pas être attribuées**:

- L'adresse IP de *broadcast* (la dernière du réseau)
- L'adresse IP du réseau (la première du réseau)

### 🔬 Calcul du nombre d'adresses disponible sur une plage

Prenons la plage IP de `172.16.1.10` à `172.16.3.240`. On suppose que cette plage ne contient pas d'adresse réservée telle que l'adresse du réseau ou celle de *broadcast*  
Quel sera le nombre d'adresses IP disponibles?

```shell
Un problème pour trouver la solution ? Essayes encore un peu et si vraiment tu n'y arrive pas tu pourrasIl faut faire le calcul par plage de réseaux :

Les 2 premiers octets des adresses, soit 172et 16 ne changent pas.
Ce n'est qu'à partir du 3ème octet que cela change, on passe de 1 à 3.

Voici une méthode de calcul :
de 172.16.1.10 à 172.16.1.255, on aura 246 adresses disponibles (de 10 à 255)
de 172.16.2.0 à 172.16.2.255, on aura 256 adresses disponibles (de 0 à 255)
de 172.16.3.0 à 172.16.3.240, on aura 241 adresses disponibles (de 0 à 240)

Pour cet exemple, on aura donc en tout 743 adresses IP disponibles.
Clicker ici pour avoir la solution
```

Pour répondre à un **DHCPDISCOVER** le serveur choisi une adresse disponible dans cette plage.  
Cette proposition d'adresse est envoyée par un message de type **DHCPOFFER** du serveur vers le client.  
À ce stade le serveur peut déjà réservé, temporairement, l'adresse proposée.

## Le cas de serveurs DHCP multiples

Le protocole DHCP prévoit le cas ou plusieurs serveurs DHCP sont sur le même réseau physique (on parle aussi de domaine de *broadcast* pour désigner l'ensemble de machine joignable par diffusion).

Le second échange de message (après le **DHCPDISCOVER** puis **DHCPOFFER**) est donc prévu pour éviter de réserver plus d'adresses que nécessaire.

Dans le cas ou le client reçoit plusieurs propositions (**DHCPOFFER**), il choisit l'une d'entre elle (en général, la première)

- Le client envoie alors un **DHCPREQUEST** en *broadcast* contenant l'identifiant du serveur ayant fait la proposition choisie. Ce message indique au serveur ayant fait la proposition que le client l'accepte, et aux autres serveurs que le client décline implicitement leurs propositions.
- Le serveur DHCP dont la proposition est acceptée répond par un **DHCPACK** pour confirmer la réservation du client. C'est à ce moment qu'il peut réserver *définitivement* dans sa plage, l'adresse du client. Le message **DHCPACK** contient à nouveau l'ensemble des paramètres de configuration du serveur qui doivent être les mêmes que dans le **DHCPOFFER**.

## Gestion de la dynamique du réseau

Un réseau informatique n'est pas figé, c'est un système qui vit, change, et évolue:

- De nouveaux hôtes se connectent au réseau
- D'autres le quitte (pannes, fin de vie,...)
- Des ordinateurs nomades (portables, smartphone...) vont faire de bref séjour sur ce réseau.

Ainsi les adresses IP ne sont pas données ***ad vitam eternam***.  
Pour des raisons d’optimisation des ressources réseau, les adresses IP sont délivrées pour une durée limitée. C’est ce qu’on appelle un **bail** (**lease** en anglais).

La réservation d'une adresse via DHCP est donc temporaire. Au moment de l'attribution, le serveur indique au client la durée du bail.  
Une fois cette durée écoulée, l'adresse peut être réutilisée par le serveur et n'est plus censée être utilisée par le client.

Un client DHCP peut toutefois demander à renouveler son bail pour conserver son adresse plus longtemps. C'est le fonctionnement classique. L'hôte va alors uniquement envoyer un **DHCPREQUEST** en *broadcast*, avant la fin du bail, pour demander un renouvellement. Le serveur qui dispose de la configuration du client dans sa plage accepte à nouveau par un **DHCPACK** qui renouvelle le bail.

Ce mécanisme de baux DHCP permet la gestion de la dynamique du réseau, les adresses utilisées par des machines ne faisant pas de renouvellement sont ainsi réutilisées.

Le paramétrage d'une durée de bail est un élément important de la prise en compte de la dynamique d'un réseau:

- D'une durée trop longue, des adresses vont rester réservées inutilement, augmentant le risque d'être à court d'adresses. Ou nécessitant, pour ne pas tomber à court, des plages plus grandes.
- D'une durée trop courte, le réseau va être encombré de message de configuration DHCP pour rien.

Une bonne durée est estimée en cohérence avec la dynamique du réseau. L'ordre d'idée étant le temps que reste un hôte sur le réseau en général.

Le bail sera par exemple court, de l'ordre de quelques dizaines de minutes sur un hot spot wifi ou l'essentiel des hôtes ne font que passer. Il sera beaucoup plus long, souvent de l'ordre de quelques jours, sur un réseau ou la plupart des ordinateurs sont fixes.

Un serveur DHCP peut fournir une adresse IP fixe à un client bien particulier en associant, dans sa configuration, une adresse IP à une adresse MAC. Ceci ne doit être utilisé que de manière modérée sous peine de perdre l'aspect dynamique, mais cela peut se révéler utile pour fournir l’adresse IP à des serveurs, par exemple pour un serveur TFTP servant pour le boot à distance des machines.

**Réservation d'adresses:**  
On peut avoir besoin sur une plage IP d'un certains nombres d'adresses réservées, qui ne doivent pas être distribuées aux clients:

- Des adresses IP déjà données à des machines (postes clients, serveurs, imprimantes,...) en adresses IP fixe.
- Des plages d'adresses pour des fonctions particulières, comme une plage d'adresses réservées pour les serveurs.

### 🔬 Calcul du nombre d'adresses disponible sur une plage avec exception d'adresses

Reprenons l'exemple de la réservation d'adresses vue plus haut, soit une plage IP de `172.16.1.10` à `172.16.3.240`.  
On va réserver (donc ne plus rendre disponible) pour chaque plage (avec `x` ayant pour valeur 1, 2, ou 3):

- De `172.16.x.0` à `172.16.x.10`
- De `172.16.x.240` à `172.16.x.255`  
	Quel sera alors le nombre d'adresses disponibles?
```shell
Un problème pour trouver la solution ? Essayes encore un peu et si vraiment tu n'y arrive pas tu pourrasIl faut faire le calcul par plage de réseaux :

Voici une méthode de calcul :

la plage 172.16.1.10 à 172.16.1.255 est réduite à 172.16.1.11 jusqu'à 172.16.1.239 soit 229 adresses disponibles.
la plage 172.16.2.0 à 172.16.2.255 est réduite à 172.16.2.11 jusqu'à 172.16.2.239 soit 229 adresses disponibles.
la plage 172.16.3.0 à 172.16.3.240 est réduite à 172.16.3.11 jusqu'à 172.16.2.239 soit 229 adresses disponibles.

Pour cet exemple, on aura donc en tout 687 adresses IP disponibles.Clicker ici pour avoir la solution
```

## 👉 Pour aller plus loin

D'autres fonctionnalités existent pour augmenter l'efficacité de ce système.

## Agent relais DHCP

L’hôte contenant l’agent relais DHCP est lui aussi configuré avec une adresse IP statique, au même titre que le serveur DHCP lui-même. Lors de sa configuration, on indique l’adresse d’un serveur DHCP auquel il transmet les découvertes DHCP lui parvenant sur le port UDP/67 (également activé en écoute pour les agents de relais). Cet agent diffuse alors sur son segment réseau (qui est également celui du client), les réponses qu’il reçoit du serveur DHCP.  
C'est une solution pour permettre à un client DHCP de sortir de son domaine de *broadcast* et ainsi de diffuser ses demandes sur un réseau composé de routeurs.

![Relais DHCP](https://storage.googleapis.com/assets_upload_prod/zNvxKriTxQ7wHe6ZwsmBWnxG2oMTMFTZ.jpg)

## Tolérance de pannes

Un système est tolérant aux pannes s'il peut continuer à fonctionner malgré la défaillance de certains composants.  
Le protocole DHCP permet une implémentation très facile de la tolérance aux pannes et de **l'équilibrage de charge**. Si vous connectez 2 serveurs DHCP au même sous-réseau IP et si ces 2 serveurs sont configurés pour prendre en charge les adresses IP de ce sous-réseau, le protocole gère tous les conflits pouvant intervenir entre les deux serveurs.

## 👉 La configuration cliente

## 🖥️ Configuration DHCP cliente sous Windows

Sur un PC Windows on tape la commande `ipconfig /all` dans une fenêtre de commande:

```shell
C:\>ipconfig /all

Configuration IP de Windows

   Nom de l’hôte . . . . . . . . . . : PCLab
   Suffixe DNS principal . . . . . . :
   Type de noeud. . . . . . . . . .  : Hybride
   Routage IP activé . . . . . . . . : Non
   Proxy WINS activé . . . . . . . . : Non
   Liste de recherche du suffixe DNS.: lan

Carte Ethernet Ethernet0 :

   Suffixe DNS propre à la connexion. . . : lan
   Description. . . . . . . . . . . . . . : Intel(R) 82574L Gigabit Network Connection
   Adresse physique . . . . . . . . . . . : 00-0F-29-A2-B2-FA
   DHCP activé. . . . . . . . . . . . . . : Oui
   Configuration automatique activée. . . : Oui
   Adresse IPv6. . . . . . . . . . . . . .: 2001:861:3140:3570:ce4:da39:4239:dd45(préféré)
   Adresse IPv6 temporaire . . . . . . . .: 2001:861:3140:3570:d9b3:69d5:80f8:bf4d(préféré)
   Adresse IPv6 de liaison locale. . . . .: fe80::ce4:da39:4239:dd45%2(préféré)
   Adresse IPv4. . . . . . . . . . . . . .: 192.168.1.12(préféré)
   Masque de sous-réseau. . . . . . . . . : 255.255.255.0
   Bail obtenu. . . . . . . . . . . . . . : mercredi 7 septembre 2022 16:29:05
   Bail expirant. . . . . . . . . . . . . : jeudi 8 septembre 2022 16:29:05
   Passerelle par défaut. . . . . . . . . : fe80::3653:d2ff:fe0b:8cac%2
                                       192.168.1.254
   Serveur DHCP . . . . . . . . . . . . . : 192.168.1.254
   IAID DHCPv6 . . . . . . . . . . . : 100666409
   DUID de client DHCPv6. . . . . . . . : 00-01-00-01-2A-54-B4-88-00-0C-29-B2-D9-DE
   Serveurs DNS. . .  . . . . . . . . . . : 2001:861:3140:3570:3653:d2ff:fe0b:8cac
                                       192.168.1.254
                                       2001:861:3140:3570:3653:d2ff:fe0b:8cac
   NetBIOS sur Tcpip. . . . . . . . . . . : Activé
   Liste de recherche de suffixes DNS propres à la connexion :
                                       lan
```

Tu dois avoir `DHCP activé. . . . . . . . . . . . . . : Oui`

En PowerShell, avec une session administrateur, on l'active de cette manière:

```powershell
1
$IPType = "IPv4"
2
$adapter = Get-NetAdapter | ? {$_.Status -eq "up"}
3
$interface = $adapter | Get-NetIPInterface -AddressFamily $IPType
4
If ($interface.Dhcp -eq "Disabled") {
5
 # Suppression de passerelle existante
6
 If (($interface | Get-NetIPConfiguration).Ipv4DefaultGateway) {
7
 $interface | Remove-NetRoute -Confirm:$false
8
 }
9
 # Activation du DHCP
10
 $interface | Set-NetIPInterface -DHCP Enabled
11
 # Configuration des serveurs DNS automatiquement
12
 $interface | Set-DnsClientServerAddress -ResetServerAddresses
13
}
```

## 🖥️ Configuration DHCP cliente sous GNU/Linux

Dans un terminal Linux Ubuntu:

```shell
wilder@UbuntuLab-[~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: wlp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether cc:15:31:db:1f:23 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.105/24 brd 192.168.1.255 scope global dynamic noprefixroute wlp4s0
       valid_lft 85231sec preferred_lft 85231sec
    inet6 fe80::c4a8:81c0:2081:ad0c/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

Tu dois avoir `inet xxx.xxx.xxx.xxx/xx brd xxx.xxx.xxx.xxx scope global dynamic` avec un `dynamic` pour valider le fait qu'une adresse IP est en DHCP.

Tu pourras trouver [ici](https://itnixpro.com/how-to-configure-dhcp-client-on-ubuntu-22-04/) une méthode complète pour configurer un Linux Ubuntu 22.04 en client DHCP

## 👉 Le cas IPv6

IPv6 disposant d'un mécanisme d'auto-configuration dit SLAAC (***S** tate **L** ess **A** ddress **A** uto- **C** onfiguration*), DHCP n'est plus indispensable...

Néanmoins, dans certains cas, il peut conserver un intérêt, aussi une adaptation du protocole DHCP existe pour IPv6: DHCPv6 (Dynamic Host Configuration Protocol version 6). Elle est définie notamment dans la RFC [8415](https://datatracker.ietf.org/doc/html/rfc8415)

---

## ☝️ Résumé

## 💻 Le serveur DHCP

Il permet de distribuer des paramètres IP au clients.  
Ces paramètres sont fournis pour une certaine durée (durée de **bail**).  
On peut aussi effectuer une réservation d'adresse en indiquant au serveur l'adresse MAC d'une machine cliente.

## 📏 Étendue DHCP

Une étendue est une plage d'adresse IP, par exemple de l'adresse IP 192.168.1.0 à l'adresse 192.168.1.240.

---

## 💪 Challenge

Réponds au quizz.

## 🧐 Critères d'acceptation

Tu dois répondre correctement à 5 questions sur 5.

lundi 08 décembre 2025

5 questions

lundi 08 décembre 2025

5 questions

lundi 08 décembre 2025

5 questions