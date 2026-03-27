---
title: "NFtables - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2246/pages/7939"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sécurité réseau

## NFtables

Découverte de Netfilter, le pare-feu intégré à Linux et de son outil de configuration NFtables

Moyen

3h

Quiz

Sécurité réseau

## NFtables

## Introduction

Le noyau **Linux** est, depuis la version 2.4, équipé d'un système de filtrage de paquets réseaux appelé **Netfilter** permettant de déployer un pare-feu (*firewall*) sur n'importe quelle distribution GNU/Linux.

![image](https://www.netfilter.org/images/netfilter-logo3.png)

## 🤓 Objectifs:

✅ Découvrir Netfilter et ses fonctionnalités  
✅ Comprendre les notions de tables, de chaînes et de règles  
✅ Explorer l'écriture de règles de filtrage et NAT avec NFtables

## Sommaire

- [👉 Netfilter](https://odyssey.wildcodeschool.com/quests/2246/pages/7939#-netfilter)
	- [Les fonctionnalités de Netfilter](https://odyssey.wildcodeschool.com/quests/2246/pages/7939#les-fonctionnalit%C3%A9s-de-netfilter)
- [👉 NFtables](https://odyssey.wildcodeschool.com/quests/2246/pages/7939#-nftables)
	- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/2246/pages/7939#-exercice)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2246/pages/7939#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2246/pages/7939#-quiz)
	- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2246/pages/7939#-crit%C3%A8res-dacceptation)

## 👉 Netfilter

**Netfilter** est souvent qualifié de *framework* permettant la mise en place d'un pare-feu dans le noyau Linux en ceci qu'il s'agit en fait d'un ensemble de **points d'accroche** (*hooks*) permettant l'interception et la manipulation des paquets réseaux à différents moments de leur traitement par la pile réseau Linux.

```
Une page WikipediA pour en apprendre un peu plus sur la notion de hook en informatiquehttps://fr.wikipedia.org/wiki/Hook_(informatique)
```

Contrairement à un firewall plus classique, **Netfilter** ne comporte donc pas d'interface de commande en lui-même.

Pas d' **interface graphique** ni de **CLI**!

Il doit donc être paramétré à l'aide d'autres outils. De multiples programmes permettent d'interagir avec **Netfilter**.

Le plus classique d'entre eux, **iptables**, est la CLI développée par l'équipe du projet Netfilter depuis ses débuts en 2001 (date de sortie du noyau 2.4).

Aujourd'hui considéré comme vieillissant, **iptables** est en cours de remplaçement par son successeur **NFtables** disponible depuis la version 3.13 de Linux de 2014.

## Les fonctionnalités de Netfilter

Commence par parcourir la ressource suivante pour découvrir (ou retrouver) quelques notions générales sur les pare-feux et notamment sur les différentes catégories couramment utilisées pour les différencier.

```
Page WikipediA sur les pare-feuxhttps://fr.wikipedia.org/wiki/Pare-feu_(informatique)
```

**Netfilter** offre pour IPv4 et IPv6:

- du filtrage de paquets *stateless*
- du filtrage de paquets *statefull*
- des fonctionnalités de traduction d'adresses (NAT) et de ports (NAPT)
- des extensions via des composants supplémentaires notamment le suivi de connexion avec conntrack

**Netfilter** permet ainsi de déployer des pare-feux sur les serveurs et les postes clients sous GNU/Linux pour filtrer le trafic entrant et sortant de ces machines.  
Mais associé aux fonctionnalités de routage du noyau Linux, il peut tout à fait servir de pare-feu réseau et filtrer le trafic entrant et sortant de réseaux entiers.

À noter que Netfilter a été certifié CSPN par l'ANSSI (pour la version 2.6.27, comme préciser sur [cette note](https://www.ssi.gouv.fr/actualite/certification-au-titre-de-la-cspn-du-logiciel-netfilter/))

---

## 👉 NFtables

**NFtables** est un outil en ligne de commande permettant la configuration de Netfilter.

Il nécessite de bien comprendre les différents *hooks* offerts par Netfilter ainsi que les notions de table, de chaîne et de règle.

Le cours qui suit permet d'aborder ces notions pas à pas en s'appuyant sur des exemples pratiques.

```
Filtrage réseau et pare-feu avec Netfilter et NFtablesUn cours en 5 modules permettant d'appréhender par étapes Netfilter via NFtables.https://www.it-connect.fr/cours/filtrage-reseau-et-pare-feu-avec-netfilter-et-nftables/
```

## 🔬 Exercice

Suis ce cours jusqu'au bout en réalisant les exemples sur un environnement de test, pouvant être mis en place virtuellement, par exemple avec GNS3.

---

## ☝️ Résumé

Netfilter est le firewall disponible nativement sur Linux et il peut être configurer avec NFtables soit en mode interactif, soit à l'aide de fichiers de configuration.

Les règles qui sont appliquées aux paquets sont regroupées dans des chaînes, qui spécifient à quel *hook* elles s'appliquent, elles-même regroupées dans des tables précisant le type de paquets réseaux concernés.

---

## 📝 Quiz

La validation de cette quête consiste en un quizz de 3 questions à choix multiples. Il peut n'y avoir aucune, une ou plusieurs bonnes réponses à chaque question.

## 🧐 Critères d'acceptation

Répondre correctement aux 3 questions.