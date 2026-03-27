---
title: "VirtualBox : La gestion des interfaces réseaux - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1977/pages/9983"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Virtualisation

## VirtualBox: La gestion des interfaces réseaux

Facile

30mins

Quiz

Virtualisation

## VirtualBox: La gestion des interfaces réseaux

## Introduction

**VirtualBox** propose plusieurs configurations réseau pour ses machines virtuelles.  
Cette quête vous propose de les découvrir.

![ ](https://storage.googleapis.com/quest_editor_uploads/gOxHoKcWZXn74YVMIKzKIWz1cKlxH4kh.jpg)

---

## 🤓 Objectifs:

✅ Comprendre la différence entre les types de réseau sur VirtualBox

## Sommaire

- [👉 Les modes d'accès réseau](https://odyssey.wildcodeschool.com/quests/1977/pages/9983#-les-modes-dacc%C3%A8s-r%C3%A9seau)
	- [La gestion du réseau par machine](https://odyssey.wildcodeschool.com/quests/1977/pages/9983#la-gestion-du-r%C3%A9seau-par-machine)
		- [Le mode d'accès NAT (Network Address Translation)](https://odyssey.wildcodeschool.com/quests/1977/pages/9983#le-mode-dacc%C3%A8s-nat-network-address-translation)
		- [Le mode d'accès par pont](https://odyssey.wildcodeschool.com/quests/1977/pages/9983#le-mode-dacc%C3%A8s-par-pont)
		- [Le mode Réseau interne](https://odyssey.wildcodeschool.com/quests/1977/pages/9983#le-mode-r%C3%A9seau-interne)
		- [Le mode Réseau privé hôte](https://odyssey.wildcodeschool.com/quests/1977/pages/9983#le-mode-r%C3%A9seau-priv%C3%A9-h%C3%B4te)
		- [Le mode Réseau NAT](https://odyssey.wildcodeschool.com/quests/1977/pages/9983#le-mode-r%C3%A9seau-nat)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/1977/pages/9983#%EF%B8%8F-r%C3%A9sum%C3%A9)

## 👉 Les modes d'accès réseau

Les modes d'accès déterminent la manière dont la machine virtuelle sera raccordée au réseau.  
Les réseaux sont indépendants pour chaque machine, ce qui permet soit de mettre les machines virtuelles sur le même segment de réseau, soit de les isoler les unes des autres.

La suite détaille les principaux mode d'accès réseau de VirtualBox et leur fonctionnement.

## La gestion du réseau par machine

Quand on souhaite paramétrer une machine virtuelle, on se rend dans la section **Paramètres** puis dans l'onglet de gauche, on sélectionne la partie **Réseau** `(1)`

Dans cette partie de la fenêtre on a **les interfaces virtuelles** `(2)`, et pour chacune on a un **modes d'accès réseau** `(3)`. **VirtualBox** permet un maximum de **4** interfaces virtuelles par machine, donc 4 réseaux différents par machine.

![image.png](https://storage.googleapis.com/quest_editor_uploads/s4Mq3pvs5yuc75TpRp5Em7g8FDXSr6xc.png)

## Le mode d'accès NAT (Network Address Translation)

Le mode d'accès NAT permet à votre machine virtuelle d'obtenir une configuration réseau gérée par le logiciel VirtualBox.  
Wikipedia fournit des informations sur le NAT sur [sa page dédiée](https://fr.wikipedia.org/wiki/Network_address_translation), en cas de besoin.

Généralement chaque machine démarrée sur ce mode d'accès réseau possédera la configuration IPv4 `10.0.2.15/24`. La communication avec l'extérieur est possible, mais uniquement pour les connexion initiée depuis la **VM**.

Bien sûr, il est nécessaire de vérifier si la case **câble branché** `(3)` est cochée en dépliant la section **Avancé** `(1)`.

Il est par ailleurs possible de choisir le type de périphérique virtuel souhaité `(2)`, même si dans le cas simple cela n'a pas d'incidence particulière et on peut donc laisser la valeur par défaut.

![image.png](https://storage.googleapis.com/quest_editor_uploads/9izXTFe0xAMcaQDrdPoZGUhrWrp9BUyR.png)

```shell
Network Address Translation (NAT)
Section de la documentation dédiée à la configuration NAThttps://www.virtualbox.org/manual/UserManual.html#network_nat
```

## Le mode d'accès par pont

Ce mode d'accès au réseau permet à la machine virtuelle d'être sur le même segment de réseau que la machine hôte.  
Dans ce mode, il faut choisir avec quelle interface réseau (carte ethernet, wifi...) de la machine hôte le pont doit être créé.

La machine virtuelle peut ainsi communiquer directement avec toutes les hôtes présents sur ce réseau.

Si un serveur DHCP y est présent, la machine virtuelle obtient alors directement une adresse IP.

Admettons que la machine hôte se trouve sur un réseau en `192.168.1.0/24`, avec, par exemple, pour IPv4 `192.168.1.100`, alors la machine virtuelle reçoit aussi une IPv4 en `192.168.1.XXX/24`.

![image.png](https://storage.googleapis.com/quest_editor_uploads/UaoC3sfxDT6AX0hKUXRDJNHT3Z1yBY2v.png)

```shell
Bridged Networking
Section de la documentation dédiée à la configuration réseau par pont.https://www.virtualbox.org/manual/UserManual.html#network_bridged
```

## Le mode Réseau interne

Le réseau interne est très utile pour configurer un service réseau isolé. Par exemple, si tu prépares un serveur DHCP pour un lab, cela évite les conflits avec ta box internet personnelle.

VirtualBox créé alors l'équivalent d'un concentrateur virtuel, non relié à aucun réseau physique de la machine hôte.  
Toutes les machines virtuelles présentes sur le même réseau interne peuvent communiquer entre elles.

```shell
A savoir : VirtualBox peut gérer plusieurs réseaux internes en même temps. On les distingue par leur nom.

Dans l'image ci-dessus le nom intnet est le nom d'un réseau interne, donc si on configure une autre machine virtuelle et qu'on renseigne un nom différent de intnet, elle se trouve sur un segment de réseau différent et ne peut donc pas communiquer avec la première. Pour ajouter un réseau interne, il te suffit de mettre le nouveau nom dans le champs Nom.
```
```shell
Internal Networking
Section de la documentation dédiée à la configuration réseau interne.https://www.virtualbox.org/manual/UserManual.html#network_internal
```

## Le mode Réseau privé hôte

Lors de l'installation de VirtualBox tu as peut-être constaté l'apparition d'un nouveau périphérique réseau sur ton système hôte. Tu peux le retrouver dans les **paramètres réseau et internet** de Windows

![image.png](https://storage.googleapis.com/quest_editor_uploads/fLvx3xSQL9bAjYDrOwiYqHiNptIbsBgC.png)

Si on clic-droit puis **Propriétés**, puis on sélectionne **Protocole Internet Version 4**

![image.png](https://storage.googleapis.com/quest_editor_uploads/6seOTPwwcN4sUbiun6q6padXGEEor4YQ.png)

On remarque alors que cette interface virtuelle attribué à l'hôte est sur le réseau `192.168.56.0/24` avec pour adresse IPv4 `192.168.56.1`

Dans la partie **Nom** en dessous du **mode d'accès réseau**, il est affiché par défaut le nom de cette interface.  
![image.png](https://storage.googleapis.com/quest_editor_uploads/MFFOFCeLJITvPnS2hXTRe94Ih5NIPvg9.png)

Ce mode d'accès est une sorte de réseau interne, mais dans lequel se trouve aussi la machine hôte, via cette nouvelle interface créé par VirtualBox.

Une machine virtuelle raccordée à cette interface peut donc joindre l'hôte sur l'adresse `192.168.56.1`

```shell
Host-Only Networking
Section de la documentation dédiée à la configuration réseau privé hôte.https://www.virtualbox.org/manual/UserManual.html#network_hostonly
```

## Le mode Réseau NAT

Ce mode d'accès réseau est différent du NAT géré nativement par VirtualBox avec son segment de réseau en `10.0.2.15/24`

Il s'agit d'un réseau interne à VirtualBox (similaire au mode réseau interne) mais ce réseau interne est connecté avec l'hôte vite un routeur NAT virtuel.

Il faut au préalable définir un adressage dans les paramètres de VirtualBox.

![image.png](https://storage.googleapis.com/quest_editor_uploads/ZkHL1KsBmqMEeNZJ27igDsD7LDPThyYE.png)

Une fois dans **Paramètres > Réseau**

On retrouve la possibilité de créer une interface virtuelle avec un Nom, un adressage en CIDR, et des options réseaux tel que DHCP, IPv6 ou encore la route par défaut de l'IPv6 et la redirection de ports.

![image.png](https://storage.googleapis.com/quest_editor_uploads/lej3BoBrAGdjHUYsdk5UuuhXyfnZ4iMI.png)  
L'option **supporte le DHCP** permettra à VirtualBox de configurer un DHCP qui se chargera d'adresser vos machines virtuelles sur le segment de réseau défini dans cette partie.

Enfin sur la configuration de la machine virtuelle, en sélectionnant le mode d'accès réseau en: **Réseau NAT**  
On retrouve le réseau **Client01** qui à été créé précédemment.

![image.png](https://storage.googleapis.com/quest_editor_uploads/4wmuvgnb6GgLEloUL7NiwaG6cwlku2T2.png)

```shell
Network Address Translation Service
Section de la documentation dédiée à la configuration réseau interne NAT.https://www.virtualbox.org/manual/UserManual.html#network_nat_service
```

---

## ☝️ Résumé

VirtualBox permet nativement de raccorder vos machines virtuelles à des réseaux isolée, ou sur le même segment de l'hôte. Cela est très utile quand on à besoin de tester des configurations réseaux différentes.

Le schéma suivant résume les différents modes et les possibilités de communication qu'ils offrent.

mardi 11 novembre 2025

3 questions

mardi 11 novembre 2025

3 questions

mardi 11 novembre 2025

3 questions

mardi 11 novembre 2025

3 questions

mardi 11 novembre 2025

3 questions