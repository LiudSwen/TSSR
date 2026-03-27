---
title: "Suivi de parc - les enjeux - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2316/pages/12377"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Gestion d'un service informatique

## Suivi de parc - les enjeux

Facile

1h

Quiz

Gestion d'un service informatique

## Suivi de parc - les enjeux

## Introduction

En entreprise, à partir du moment où l'ensemble des matériels et logiciels devient conséquent, il faut commencer à réfléchir à une gestion de parc. Que ce soit pour le stock, pour l'attribution, ou bien encore pour le renouvellement, cette réflexion doit se faire en amont de tout process.  
Par quelques exemples, nous allons essayer de dégager quelques problématiques que tu pourrais rencontrer en entreprise.

![im](https://cdn.pixabay.com/photo/2017/10/04/09/56/office-2815634_960_720.jpg)

## 🤓 Objectifs:

✅ Comprendre les enjeux de la gestion d'un parc informatique

## Sommaire

- [👉 Contexte initial](https://odyssey.wildcodeschool.com/quests/2316/pages/12377#-contexte-initial)
- [👉 Une centralisation](https://odyssey.wildcodeschool.com/quests/2316/pages/12377#-une-centralisation)
- [👉 Exemple 1: Obsolescence des OS](https://odyssey.wildcodeschool.com/quests/2316/pages/12377#-exemple-1--obsolescence-des-os)
- [👉 Exemple 2: Homogénéisation des navigateurs Web](https://odyssey.wildcodeschool.com/quests/2316/pages/12377#-exemple-2--homog%C3%A9n%C3%A9isation-des-navigateurs-web)
- [👉 Exemple 3: Renouvellement matériel](https://odyssey.wildcodeschool.com/quests/2316/pages/12377#-exemple-3--renouvellement-mat%C3%A9riel)
- [👉 État de parc](https://odyssey.wildcodeschool.com/quests/2316/pages/12377#-%C3%A9tat-de-parc)

## 👉 Contexte initial

Imaginons une entreprise, d'environ 2000 salariés, qui est à la fois en France et à l'international.  
Cette société a plusieurs sites (ou filiales) installés un peu partout en France et à l'étranger.

Au delà des aspects de sécurisation systèmes et d'infrastructure réseaux (qui ne seront pas abordé ici), on peut déjà imaginer qu'un certain nombre de matériels et de logiciels vont être utilisés pour l'ensemble des collaborateurs de cette société.

Pour le matériel on trouvera des ordinateurs, des écrans, des téléphones, des matériels réseaux, des périphériques, des imprimantes...

Quant aux logiciels, il va y avoir des OS, des pilotes logiciels, des navigateurs web, des logiciels de sécurité comme pour la gestion du SSO (Sigle Sign On), des logiciels bureautiques, de gestion de plan d'architecture...

Tout cela constitue le **parc informatique**.

Qu'est-ce que le Service Informatique (ou **SI**) va devoir et pouvoir gérer au niveau de ce parc?

## 👉 Une centralisation

Tout d'abord, imaginons que chaque site, dans chaque ville, ou chaque pays achète et gère son matériel. De même, imaginons qu'ils gère également les différents logiciels utilisés. Nous aurions une très grande disparité matérielle et logicielle! D'ailleurs, quelles seraient les conséquences de cette multitudes de versions?

Tout d'abord, des achats par petites quantités, et donc une négociation quasi impossible sur les tarifs.  
Ensuite un problème de compétences humaines. En effet, impossible pour le personnel chargé de la maintenance et de suivi de connaître toutes les références.  
Enfin, un problème d’obsolescences différentes suivant les matériels, et donc une impossibilité de prévoir des renouvellements.

Donc, afin de coordonner tout cela, l'ensemble des achats, des contrats de maintenance, et des compétences à acquérir doit être centralisé au sein d'un même service: le service informatique, ou IT.

Ce dernier aura pour rôle d'avoir un parc le plus homogène possible. Des délégations peuvent être faites sur les sites distants, mais toujours avec l'aval du service IT centralisateur.

## 👉 Exemple 1: Obsolescence des OS

Pour ce premier exemple, prenons l'homogénéisation des OS dans un parc informatique. Mais qu'est-ce donc que cela?  
Cela consiste à tendre vers **une seule type de référence dans un secteur particulier**, à aller vers **l'unicité**.

Imaginons un site de 200 personnes sur lequel il y a 180 ordinateurs. Les versions d'OS sont celles-ci:

- 1 AD (RODC) Windows Server 2012
- 2 Serveur de fichiers Windows Server 2016
- 125 PC portable:
	- 12 PC portables Windows 11
		- 25 PC portables Windows 10
		- 88 PC portables en Windows 7
- 51 PC fixes:
	- 38 PC fixes en Windows 11
		- 9 PC fixes en Windows 10
		- 4 PC fixes en Windows 7
- 1 tablette tactile:
	- 1 tablette tactile en Windows 8

On constate une disparité logicielle au niveau des OS, sur les ordinateurs fixes et portables.  
Qu'est-ce que cela implique?

- Il faut porter une attention particulière à **l'obsolescence des systèmes** (cycle de vie logiciel)
- Il faudra surveiller les vulnérabilités des systèmes non maintenus:
	- Windows Server 2012 a une date de fin de support en 2023
		- Windows 7 en 2020
		- Windows 8 en 2016...
- Il faudra installer les correctifs de sécurité, du moins lorsqu'il sont disponibles, ce qui ne sera plus le cas sur des systèmes anciens
- Il faut programmer une montée de version des OS obsolètes **ou** qui le seront prochainement

> Dans cet exemple, on s'est arrêté aux versions majeures des OS. Mais idéalement, il faudrait voir les versions mineures comme les versions annuelles de Windows 10 (21H2, 21H1...).

## 👉 Exemple 2: Homogénéisation des navigateurs Web

Reprenons le site vu précédemment. On doit mettre en place une solution web qui s'appuie sur une version de navigateur Firefox bien précise. En effet, cette solution web ne fonctionne qu'à partir de Firefox 86.  
Regardons quelles sont les versions de Firefox avec le nombre d’occurrence:

- Firefox 32: 1
- Firefox 43: 1
- Firefox 45: 2
- Firefox 57: 4
- Firefox 61: 10
- Firefox 72: 15
- Firefox 81: 7
- Firefox 84: 10
- Firefox 86: 3
- Firefox 87: 17
- Firefox 91: 1
- Firefox 93: 8
- Firefox 94: 14
- Firefox 95: 15
- Firefox 96: 17
- Firefox 99: 21
- Firefox 100: 34

Dans ce cas on constate que les versions logicielles sont très hétérogènes.

Que peut-on faire?

En premier, mettre à jour les navigateurs qui ont une version ancienne, c'est à dire dans cette exemple presque tout le parc! Au delà de la compatibilité avec la solution logicielle, il en va de la sécurité des matériels. En effet un navigateur web qui n'est pas à jour peut amener son lot de problèmes.

Ensuite mettre en place une solution de suivi de mis-à-jour, complètement automatisée ou bien faite manuellement par le personnel IT, mais dans tous les cas une solution gérée!

Enfin mettre en place un suivi de versions.

## 👉 Exemple 3: Renouvellement matériel

Reprenons une dernière fois ce site distant et cette fois-ci attardons nous sur la partie matérielle.  
Voici ce que cela donne:

- 1 AD (RODC) Windows Server 2012 ==> VM
- 2 Serveur de fichiers Windows Server 2016 ==> VM
- 125 PC portable:
	- 12 PC portables HP G9
		- 25 PC portables HP G8
		- 68 PC portables HP G7
		- 20 PC portables DELL Latitude 3420
- 51 PC fixes:
	- 35 PC fixes DELL Vostro 3710
		- 16 PC fixe Lenovo ThinkCentre M60e
- 1 tablette tactile:
	- 1 tablette Asus ZenPad 10

On constate une disparité matérielle importante. Il y a 4 constructeurs différents, ainsi que 7 références matérielles.  
Qu'est-ce que cela implique?

- Des contrats de maintenance différents, donc probablement des différences de suivi et de réparation des matériels
- La nécessité, pour l'équipe IT, de connaître sur plusieurs références
- Les installations de logiciels, de pilotes sont peut-être différentes suivant les matériels.

Avec cet exemple, il faut se poser la question du futur renouvellement matériel. Quand telle ou telle référence de machine doit être remplacées? Comment programmer à N+1 ou plus l'évolution du nombre de matériel, de références?

## 👉 État de parc

Avec tous ces exemples, on voit donc l'obligation de faire un suivi des différents matériels et logiciels sur un parc informatique.  
Cet état de parc est l'un des éléments du **MCO** (Maintient en Condition Opérationnelle)  
Il existe de nombreuses manières de procéder. L'une d'entre-elles est d'utiliser un logiciel de suivi de parc.  
**Glpi** (Gestionnaire Libre de Parc Informatique) est l'un d'entre-eux.

vendredi 02 janvier 2026

5 questions

vendredi 02 janvier 2026

5 questions