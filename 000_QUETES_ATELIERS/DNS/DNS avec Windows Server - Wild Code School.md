---
title: "DNS avec Windows Server - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1444/pages/18628"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
DNS

## DNS avec Windows Server

Découverte du Système des noms de domaine (Domain Name System - DNS) et configuration sur un serveur Windows

Moyen

2h

3 pairs

DNS

## DNS avec Windows Server

## Introduction

Cette quête permet de découvrir comment fonctionne un serveur DNS et d'en faire l'installation et la configuration sur un serveur Windows.

---

#### ⚠️ Avant de commencer cette quête, tu dois avoir terminé les quêtes suivantes:

```shell
Introduction au DNSPrésentation des principaux concepts du système des noms de domaine DNS.30minsVoir la quête - Introduction au DNS
```

![404_DNS_quest](https://storage.googleapis.com/quest_editor_uploads/SwJFdjzghxqDpp2rMhUWwnPaCLCvxwl6.jpg)

## 🤓 Objectifs:

✅ Comprendre le fonctionnement d'un Serveur DNS  
✅ Savoir créer installer et configurer un Serveur DNS sur Windows Server  
✅ Savoir tester le bon fonctionnement d'un Serveur DNS

## Sommaire

- [👉 Rappels](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-rappels)
	- [Notions de base d'un DNS](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#notions-de-base-dun-dns)
		- [Type de serveur DNS](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#type-de-serveur-dns)
		- [Comment DNS répond-il aux requêtes?](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#comment-dns-r%C3%A9pond-il-aux-requ%C3%AAtes-)
- [👉 Configuration d'un serveur DNS](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-configuration-dun-serveur-dns)
- [👉 Installation du rôle DNS](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-installation-du-r%C3%B4le-dns)
- [👉 Fin d'installation](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-fin-dinstallation)
- [👉 Lancement de la console DNS](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-lancement-de-la-console-dns)
- [👉 Création d'une zone directe (Forward Lookup Zones)](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-cr%C3%A9ation-dune-zone-directe-forward-lookup-zones)
- [👉 Création d'une zone indirecte (Reverse Lookup Zones)](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-cr%C3%A9ation-dune-zone-indirecte-reverse-lookup-zones)
- [👉 Création d'un enregistrement A](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-cr%C3%A9ation-dun-enregistrement-a)
- [👉 Création d'un enregistrement CNAME](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-cr%C3%A9ation-dun-enregistrement-cname)
- [👉 Test du service DNS](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-test-du-service-dns)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/1444/pages/18628#-crit%C3%A8res-dacceptation)

## 👉 Rappels

## Notions de base d'un DNS

Tous les ordinateurs sur Internet, depuis votre smartphone ou ordinateur portable jusqu'aux serveurs qui hébergent le contenu des plus grandes boutiques en ligne, communiquent entre eux à l'aide de numéros. Ces numéros sont appelés adresses IP. Lorsque tu ouvres un navigateur et accèdes à un site web, tu n'as pas à mémoriser et à saisir ces adresses. Il te suffit simplement d'entrer un nom de domaine comme *exemple.com* pour arriver au bon endroit.

DNS est un service distribué dans le monde entier qui traduit des noms de domaines, lisibles par l'homme comme [www.exemple.com](http://www.exemple.com/), en adresses IP au format numérique de type 192.0.2.1 que les ordinateurs utilisent pour s'interconnecter. Le système DNS fonctionne comme un annuaire téléphonique en gérant la correspondance entre les noms et les numéros. Les serveurs DNS traduisent des noms de domaines en toutes sortes d'informations, comme par exemple, des adresses IP. Il décide, en quelques sorte, à quel serveur un utilisateur final va se connecter quand il tape un nom de domaine dans son navigateur. Ces demandes sont appelées requêtes.

## Type de serveur DNS

**Serveur faisant autorité**: un serveur DNS faisant autorité contient l'ensemble des informations associées à zone DNS (ensemble de noms de domaines). Ces informations ou enregistrements sont gérés par l'administrateur du serveur, en général à la demande du titulaire d'un nom de domaine faisant partie de sa zone. Ce serveur répond aux requêtes DNS qui lui sont adressée, en général par un résolveur, en communiquant les informations associées (par exemple l'adresse IPv4 associée à ce domaine) ou en renvoyant vers un autre serveur plus adapté s'il n'a pas l'information.

**Résolveur**: en général, les clients n'adressent pas directement leurs requêtes aux serveurs faisant autorité. À la place, ils interrogent un serveur DNS appelé résolveur récursif (ou simplement résolveur). Un résolveur est un peu comme un concierge d'hôtellerie: il ne possède pas d'enregistrement DNS, mais il fait office d'intermédiaire pouvant obtenir les informations de DNS en votre nom. Si une référence de DNS est mise en cache ou stockée temporairement par un DNS récursif, ce dernier répond à la requête DNS en communiquant la source ou l'adresse IP. Dans le cas contraire, il transmet la requête à un ou plusieurs serveurs faisant autorité pour récupérer les informations demandées.

## Comment DNS répond-il aux requêtes?

Le diagramme suivant présente la façon dont les résolveurs et les serveurs faisant autorité collaborent pour indiquer à un utilisateur final à quel serveur il doit se connecter pour consulter un site web ou n'importe quel service sur le réseau.

![image.png](https://storage.googleapis.com/quest_editor_uploads/HHMGS0VHqclysx6obHWeuDxHIKlOkAJM.png)

1. Un utilisateur ouvre un navigateur web, saisit [www.example.com](http://www.example.com/) dans la barre d'adresse et appuie sur Entrée.
2. La demande pour [www.example.com](http://www.example.com/) est acheminée vers un résolveur DNS déclaré dans la configuration réseau de son ordinateur. Ce serveur est généralement géré par le fournisseur d'accès Internet (FAI) de l'utilisateur.
3. Le résolveur DNS du FAI transmet la demande pour [www.example.com](http://www.example.com/) à un serveur de noms racine DNS.
4. Le résolveur DNS du fournisseur d'accès à Internet transmet, à nouveau, la demande pour [www.example.com](http://www.example.com/), mais cette fois-ci, aux serveurs faisant autorité pour le TLD.com. Le serveur de noms de domaines.com répond à la demande avec les adresses des serveurs faisant autorité sur example.com, dans l'exemple: Amazon Route 53.
5. Le résolveur DNS du fournisseur d'accès à Internet choisit un serveur de noms Amazon Route 53 et transmet la demande pour [www.example.com](http://www.example.com/) à ce serveur de noms.
6. Le serveur de noms Amazon Route 53 recherche l'enregistrement [www.example.com](http://www.example.com/) dans la zone hébergée example.com. Il obtient la valeur associée, par exemple l'adresse IP 192.0.2.44, puis il renvoie cette adresse au résolveur DNS.
7. Enfin, le résolveur DNS du fournisseur d'accès à Internet possède l'adresse IP dont l'utilisateur a besoin. Le résolveur renvoie cette valeur au navigateur web. Le résolveur DNS met également en cache (stocke) l'adresse IP de example.com pendant un laps de temps défini, afin qu'il puisse répondre plus rapidement lors du prochain accès à example.com.
8. Le navigateur web envoie une demande HTTP pour [www.example.com](http://www.example.com/) à l'adresse IP figurant dans le résolveur DNS. C'est là que se trouve votre contenu, par exemple, sur un serveur web s'exécutant sur une instance Amazon EC2 ou sur un compartiment Amazon S3 configuré comme un point de terminaison de site web.
9. Le serveur web ou une autre ressource à l'adresse 192.0.2.44 retourne la page web de [www.example.com](http://www.example.com/) vers le navigateur web, et celui-ci affiche la page.
```shell
DNS sur WikipédiaLa page WikipediA sur DNS contient plus d'information que cette quête. Sa lecture attentive permet de répondre aux questions du quizz qui suit.https://fr.wikipedia.org/wiki/Domain_Name_System
```

## 👉 Configuration d'un serveur DNS

La configuration d’un serveur DNS consiste à gérer la correspondance entre les noms de domaine et les adresses IP afin que les machines du réseau puissent résoudre les noms sans utiliser directement les adresses numériques.

En général, on configure:

- Une zone DNS (ex.: `entreprise.local`)
- Une zone de recherche directe (nom → IP)
- Une zone de recherche inversée (IP → nom)
- Des enregistrements DNS comme:
	- A / AAAA: associent un nom à une adresse IPv4/IPv6
		- PTR: résolution inverse
		- CNAME: alias
		- MX: serveur mail
		- NS: serveurs responsables de la zone
- Des serveurs DNS redirecteurs (*DNS forwarders*), utilisés pour les noms externes
- Un cache DNS, conservant temporairement les résolutions

Le serveur DNS permet également de visualiser et gérer les enregistrements actifs dans la zone, ainsi que les requêtes mises en cache.

## 👉 Installation du rôle DNS

Le serveur doit avoir une adresse IP statique.  
Pour la suite on estime que ce serveur a une adresse fixe dans la plage IP des machines clientes, par exemple 172.16.10.0/24.

- Aller dans le **Server Manager**
- Cliquer sur **Manage** -> **Add Roles and Features** pour démarrer l'ajout du rôle DNS
- Cliquer sur **Next**
- Laisser l'option sélectionnée par défaut **Role-Based or feature-based installation** et cliquer sur **Next**
- Garder le serveur sélectionné et cliquer sur **Next**
- Cocher le rôle **DNS Server**
- Une fenêtre contextuelle va apparaître, il faut cliquer sur **Add Features** pour inclure les outils d'administration proposés
- Cliquer sur **Next** 3 fois
- Cliquer sur **Install** et ensuite sur **Close** pour laisser l'installation en arrière-plan

## 👉 Fin d'installation

- Cliquer sur l'icône ronde avec des flèches à l’intérieur qui tournent pour rafraîchir l'affichage
- L'installation du rôle est terminée quand **DNS** apparaît dans la partie gauche

## 👉 Lancement de la console DNS

- Ouvrir la console DNS avec l'une de ces méthodes:
	- Cliquer sur l'icone **DNS** dans le panneau gauche de la console
		- Cliquer avec le bouton droit de la souris sur le serveur sélectionné
				- Cliquer sur **DNS Manager**
		- Cliquer dans **Tools** puis sur **DNS**

## 👉 Création d'une zone directe (Forward Lookup Zones)

- Cliquer avec le bouton droit de la souris sur **Forward Lookup Zones** et cliquer sur sur **New Zone**
- Cliquer sur **Next**
- Choisir l'option par défaut **Primary zone** puis cliquer sur **Next**
- Mettre un nom de zone DNS comme *name.fr*
- Cliquer sur **Next** plusieurs fois puis **Finish** à la fin  
	La zone DNS apparaît sous **Forward Lookup Zones**

## 👉 Création d'une zone indirecte (Reverse Lookup Zones)

- Cliquer avec le bouton droit de la souris sur **Reverse Lookup Zones** et cliquer sur **New Zone**
- Cliquer sur **Next**
- Choisir l'option par défaut **Primary zone** puis cliquer sur **Next**
- Choisir l'option par défaut **IPv4 Reverse Lookup Zone** puis cliquer sur **Next**
- Dans **Network ID** mettre le début de la plage IP correspondant à cette zone
- Cliquer sur **Next** plusieurs fois puis **Finish** à la fin  
	La zone DNS indirecte apparaît sous **Reverse Lookup Zones**

## 👉 Création d'un enregistrement A

Dans la zone DNS créée:

- Clique avec le bouton droit de la souris et sélectionne **New Host (A or AAAA)**
- Mettre un nom DNS et une adresse IP associée
```shell
Remarques concernant les enregistrement DNS :

Le nom DNS n'est pas obligatoirement égal au nom de l'hôte ciblé par l'adresse IP
Plusieurs noms DNS différents peuvent être crées vers une même cible IP, dans ce cas on prendra plutôt des CNAME
```

## 👉 Création d'un enregistrement CNAME

Dans la zone DNS créée:

- Clique avec le bouton droit de la souris et sélectionne **New Alias (CNAME)**
- Mettre un alias de nom vers une adresse IP qui a déjà un enregistrement A

## 👉 Test du service DNS

Après avoir fait les enregistrements DNS, tester le ping entre un client et le serveur.  
Le ping doit répondre au ping avec le nom.

---

## 📝 Quiz

```shell
# 1  - Sur quel port écoute un serveur DNS ?50536768Valider# 2 TCPUDPValider# 3 SBASDASOAValider# 4 TLDTLSTTLValider# 5 Top Level DomainTree Level DomainThe Larger DomainValiderTon score :0 / 5
```

---

## 💪 Challenge

Sur un Windows Server déployé sur une VM.

```shell
Pense à faire un clone de ta machine (Snapshot) pour avoir un backup, au cas où tu ferais une mauvaise configuration qui rendrait ta machine inutilisable.
```
- Mettre en place le service DNS sur le serveur ayant l'adresse IP 172.16.10.5
- Ce serveur fera autorité sur la zone `wilders.lan`
- Mettre en place une zone DNS indirecte
- Mettre en place un enregistrement A et un CNAME pour le serveur DNS
	- Le CNAME pour le serveur peut être par exemple `dns.wilders.lan`

Poste un lien Github qui contiendra des copies d'écran légendés:

- La configuration de la zone directe du serveur
- La configuration de la zone indirecte du serveur
- Un ping depuis le client vers les 2 noms DNS du serveur
- le résultat de la commande `nslookup` depuis le client vers le serveur DNS

## 🧐 Critères d'acceptation

- Il est possible de faire une résolution de nom et une résolution inverse depuis le serveur et depuis une machine du réseau
- Le serveur est bien joignable via 2 noms distincts
- La procédure est claire et permet effectivement lorsqu'elle est appliquée de répondre aux critères du challenge
- Le lien github contient 5 copies d'écran avec une légende pour chacune

Solution postée le **dimanche 14 décembre 2025**

[https://github.com/LiudSwen/dns-quest/blob/main/READMEwindows.md](https://github.com/LiudSwen/dns-quest/blob/main/READMEwindows.md)