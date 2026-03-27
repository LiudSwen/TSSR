---
title: "La Téléphonie sur IP ou ToIP - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2464/pages/10056"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
VoIP

## La Téléphonie sur IP ou ToIP

Les notions de base

Facile

30mins

Quiz

VoIP

## La Téléphonie sur IP ou ToIP

## Introduction

La ToIP (pour *Telephony Over IP* ou téléphonie sur IP) est une technologie qui gère une infrastructure réseau permettant le transport de communications téléphoniques sur des réseaux IP. Cette technologie est de plus en plus utilisée en entreprise, car elle permet de réduire les coûts de communication tout en offrant de nouvelles fonctionnalités.

Les avantages de la ToIP sont nombreux: coûts réduits, meilleure qualité de communication, gestion centralisée des communications, fonctionnalités avancées (messagerie vocale, conférence téléphonique, etc.). L'utilisation se fait sur des appareils fixe ou mobile, filaire ou non.

Dans cette quête, tu vas découvrir les fondamentaux de cette technologie, comment elle fonctionne, ses avantages et comment elle est utilisée en entreprise.

![logo-ToIP](https://mb.cision.com/Public/12797/2969438/bec50c6af5a6f842_800x800ar.png)

## 🤓 Objectifs:

✅ Découvrir les fondamentaux de la ToIP et son fonctionnement  
✅ Connaitre les différents élements matériel qui entre en jeu  
✅ Comprendre l'infrastructure ToIP

## Sommaire

- [👉 Une histoire de central téléphonique](https://odyssey.wildcodeschool.com/quests/2464/pages/10056#-une-histoire-de-central-t%C3%A9l%C3%A9phonique)
- [👉 Le matériel spécifique pour la VoIP](https://odyssey.wildcodeschool.com/quests/2464/pages/10056#-le-mat%C3%A9riel-sp%C3%A9cifique-pour-la-voip)
- [👉 Différence entre la VoIP et la ToIP](https://odyssey.wildcodeschool.com/quests/2464/pages/10056#-diff%C3%A9rence-entre-la-voip-et-la-toip)
	- [La VoIP](https://odyssey.wildcodeschool.com/quests/2464/pages/10056#la-voip)
		- [La ToIP](https://odyssey.wildcodeschool.com/quests/2464/pages/10056#la-toip)
- [👉 Les protocoles](https://odyssey.wildcodeschool.com/quests/2464/pages/10056#-les-protocoles)
- [👉 Et l'infrastructure réseau dans tout ça?](https://odyssey.wildcodeschool.com/quests/2464/pages/10056#-et-linfrastructure-r%C3%A9seau-dans-tout-%C3%A7a-)
- [👉 Les évolutions](https://odyssey.wildcodeschool.com/quests/2464/pages/10056#-les-%C3%A9volutions)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2464/pages/10056#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2464/pages/10056#-crit%C3%A8res-dacceptation)

## 👉 Une histoire de central téléphonique

En France, la téléphonie classique, dite **RTC** (pour **Réseau Téléphonique Commuté**) s'est développée durant le 20ème siècle, et a commencée à se démocratiser dans les années 80.  
Pour pouvoir relier les appelants et les appelés, il faut un **central téléphonique**. Jusqu'en 1975, c'étaient les **demoiselles du téléphone** qui se chargeaient de cela. Elles faisaient transiter manuellement les communications d'une place à une autre.

![image-demoiselles-telephone](https://images.ladepeche.fr/api/v1/images/view/5c1bbbd63e4546549a59a8bc/original/image.jpg)

```
Le central téléphonique
Une définition plus étoffée.https://www.central-telephonique-guide.be/quest-ce-quun-central-telephonique/
```
```
Le réseau RTC
La page Wikipédia sur le RTChttps://fr.wikipedia.org/wiki/R%C3%A9seau_t%C3%A9l%C3%A9phonique_commut%C3%A9
```

A partir de 1975, les premiers **commutateurs automatiques** ou **autocom**, également appelé **PABX** (pour *Private Automatic Branch EXchange*) sont apparus. Ces appareils jouent le rôle de central téléphonique.

![image-PABX](https://i.pinimg.com/originals/f4/be/e5/f4bee59aebb888c9d25777a9134e1285.jpg)

Au début des années 90, la technologie **RNIS** (pour Réseau numérique à intégration de services) a commencé a être commercialisée. Cette technologie permet de numériser le signal analogique de la voix dans les transmissions téléphoniques.  
Le RNIS s'utilise sur des PABX.

```
Le RNIS
La page wikipédia dédiéehttps://fr.wikipedia.org/wiki/R%C3%A9seau_num%C3%A9rique_%C3%A0_int%C3%A9gration_de_services
```

Presque en même temps, un nouveau type d'autocom, l' **IPBX** (*Internet Protocol Private Branch Exchange*) est apparu. Cet appareil permet d'utiliser des réseaux informatiques sur protocole IP pour faire transiter les communications téléphoniques. Les téléphones deviennent des **terminaux IP**, c'est-à-dire des appareils qui, connectés sur un réseau IP, peuvent servir de téléphone.

![image-ipbx](https://www.ipconnect.fr/wp-content/uploads/2015/05/yeastar-serieS.png.webp)

```
PABX et IPBXLa page Wikipédia sur l'autocommutateur téléphonique privéhttps://fr.wikipedia.org/wiki/Autocommutateur_t%C3%A9l%C3%A9phonique_priv%C3%A9
```

## 👉 Le matériel spécifique pour la VoIP

L'ensemble des matériels compatibles seront connectés à un réseau IP, donc pour le matériel filaire, le câblage se fera uniquement avec des câbles RJ45.  
On trouvera d'abord les **terminaux IP**, qui sont les appareils utilisés par les utilisateurs:

- Les téléphones IP fixe ou de type desk
- Les smartphones VoIP
- Les ordinateurs
- ...
```
La VoIP a amené le concept de softphone : un logiciel qui permet à un utilisateur de passer et de recevoir des appels téléphoniques à partir de son ordinateur, de sa tablette ou de son smartphone en utilisant une connexion Internet.

Sans être un matériel au sens propre, les softphones doivent être pris en compte dans infrastructure ToIP.
```

> Il est possible de relier des téléphones non-IP à un réseau IP avec des **adaptateurs ATA**

On trouvera également les autocommutateurs PABX et IPBX.  
Enfin, les passerelle VoIP, qui jouent le rôle de pont entre réseaux IP et non-IP.

## 👉 Différence entre la VoIP et la ToIP

Souvent on emploie ces 2 termes en pensant que c'est la même chose.

## La VoIP

C'est la technologie utilisée, ce qui permet de pouvoir passer des appels vocaux par internet.  
Les signaux audio analogiques sont convertis en paquets de données numériques. Cette conversion se fait à l'aide de **codec** (pour **Cod** eur/ **Dec** odeur).  
Ces paquets IP sont ensuite transmis sur Internet.  
Plusieurs protocoles réseaux sont implémentés.  
Ainsi on peut dire que **VoIP = technologie utilisée (protocoles)**.

```
Les codecs
La page Wikipédia sur la définition d'un codechttps://fr.wikipedia.org/wiki/Codec
```

## La ToIP

C'est une infrastructure réseau qui va s'appuyer sur la VoIP pour gérer la téléphonie d'entreprise, ainsi que les services associés sur un réseau IP.  
On va utiliser les technologie de la VoIP pour pouvoir sortir du réseau interne d'entreprise les appels téléphoniques.  
Donc, **ToIP = une infrastructure**.

## 👉 Les protocoles

De nombreux protocoles sont utilisés pour la mise en place de la VoIP ou de la ToIP.  
En voici quelques-un:

- Le **SIP** (*Session Initiation Protocol*) est un protocole de signalisation basé sur l'IP.  
	Il est utilisé pour établir, modifier et terminer des sessions de communication en temps réel telles que les appels vocaux et vidéo, les conférences, les messageries instantanées, etc.  
	Il gère les sessions de communication entre les différentes parties impliquées.  
	Dans son fonctionnement, il utilise des requêtes et des réponses pour établir et terminer des sessions de communication.  
	Il fonctionne avec d'autres protocoles, comme le **SDP** (*Session Description Protocol*) qui est un autre protocole de signalisation, et qui décrit les caractéristiques d'une session en cours.
- Le **RTP** (*Real-time Transport Protocol*) est un protocole de transport.  
	Il est utilisé pour transmettre des données audio et vidéo en temps réel sur des réseaux IP. Il fonctionne avec le protocole **SIP**.  
	RTP utilise le protocole **UDP** (*User Datagram Protocol*) pour envoyer des paquets de données audio et vidéo entre les différents appareils participant à la session de communication. Dans le message RTP on trouve le temps d'échantillonnage, le numéro de séquence et la synchronisation des médias pour permettre une reconstruction précise du flux de données audio ou vidéo à l'arrivée.

![schéma-protocoles-voip](https://d33wubrfki0l68.cloudfront.net/6cc14709cd073b25be67330cdeb908f8638fc6a7/31426/assets/images/protocole-sip/lucidchart/9ca7f7c3-f1e7-4e86-92e7-c194871df934.png)

Sur le schéma généraliste ci-dessous, on peut voir les différents éléments de l'infrastructure ToIP:

- Les terminaux IP représentés par le téléphone et l'ordinateur
- L’autocommutateur, représenté par l' **IP PBX**
- La passerelle VoIP
- Le réseau téléphonique RTC, représenté par le nuage **PSTN** (*Public Switched Telephone Network*)

![schema-reseau-ToIP](https://d33wubrfki0l68.cloudfront.net/2fb300b48f9fee61f67a744c1e6576f5eb1b12b6/decc1/assets/images/protocole-sip/lucidchart/fb60f8c4-32e1-4174-8b80-a6d140d65300.png)

La vidéo ci-dessous va t'expliquer en 2 min comment une infrastructure de téléphonie analogique évolue en voix sur IP.

## 👉 Les évolutions

Le **Trunk SIP** remplace progressivement le RNIS et la technologie **Centrex** (central téléphonique dans le cloud) se développe.

Une petite vidéo pour comprendre rapidement ce qu'est le trunk SIP:

De même, voici une vidéo pour comprendre ce qu'est le centrex en moins de 3 min:

---

## 💪Challenge

Répond correctement aux questions du quiz.

## 🧐 Critères d'acceptation

Tu dois avoir toutes les bonnes réponses pour valider cette quête.

samedi 14 février 2026

6 questions

samedi 14 février 2026

6 questions