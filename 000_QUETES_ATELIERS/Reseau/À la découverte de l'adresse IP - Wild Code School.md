---
title: "À la découverte de l'adresse IP - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2274/pages/11264"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## À la découverte de l'adresse IP

Facile

30mins

Quiz

Réseau

## À la découverte de l'adresse IP

```shell
Introduction
```

Dans cette quête nous allons apprendre de quoi est fait une adresse IPv4 (**Internet Protocol Version 4**), comment ce système IP fonctionne et pourquoi cela a été mis en place.  
Allons voir ça!

![Datacenter](https://storage.googleapis.com/quest_editor_uploads/AiWy7U9iSlvhA5szIu51JjEKhCFbO0p7.jpg)

## 🤓Objectifs:

✅ Connaître les différents éléments qui sont reliés à l'adresse IPv4  
✅ Connaître les différents types d'adresses IPv4  
✅ Savoir reconnaître les adresses IPv4 publiques et privées

## 👀 Contenu de la quête:

- Qu'est-ce qu'une adresse IP?
- De quoi est constitué une adresse IPv4?
- Les classes d'adresses IPv4

---

## 👉 Qu'est-ce qu'une adresse IP?

C’est bien connu: pour qu’un courrier arrive dans la boîte aux lettres du bon destinataire, il faut préciser l’adresse exacte incluant le pays, la ville, le code postal, le numéro et la rue. De cette façon, les employés de la poste savent où le courrier doit être acheminé. Il en va de même sur les réseaux informatiques: tout appareil faisant partie d’un réseau nécessite un « numéro » unique afin de pouvoir communiquer avec les autres appareils et recevoir des **paquets de données** de leur part.  
Cette identification de tous les hôtes connectés à un réseau est obligatoire pour que tous les **paquets** arrivent à destination.  
Le format de cette adresse IP est toutefois bien différent de celui apposé sur nos courriers.  
En IPv4, elle est constituée de 4 nombres allant de 0 à 255 espacés par un point.  
En voici un exemple: `192.168.1.10`

## 👉 De quoi est constitué une adresse IPv4?

### L'adresse IPv4

Elle est composée de deux parties:

1. Une partie réseau, commune à toutes les adresses d'un même réseau, qui permet d’identifier l’adresse du réseau
2. Une partie hôte qui permet d’identifier la machine sur le réseau

Exemple pour l'adresse IPv4 `192.168.1.23`:

1. Partie réseau: `192.168.1`
2. Partie hôte: `.23`

Une adresse IP est codée sur 4 octets soit 32 bits car 1 octet = 8 bits. C'est une séquence binaire mais pour rendre sa lecture plus facile aux êtres humains, on la convertit en notation dite *décimale pointée*.

Exemple: `11000000101010000000000100010111` est nettement moins facile à lire et retenir que son équivalent décimal `192.168.1.23`

### Le masque de sous-réseau

Dans la configuration d'une machine, une adresse IP est toujours accompagnée d’un masque de sous-réseau. Le masque de sous-réseau permet d’identifier, pour cette adresse IP, quelle est la partie **réseau** et quelle est la partie **machine**. Dans un masque de sous-réseau, les bits de la partie réseau sont tous à 1 et les autres à 0.

Exemple: Soit le couple IP / masque de sous-réseau suivant: `192.168.5.122 / 255.255.255.224`

Si on converti ces 2 adresses en binaires, nous aurons ceci:

- L'adresse IP en binaire:`11000000.10101000.00000101.01111010`
- Le masque en binaire: `11111111 11111111 11111111 11100000`

Il y a 27 bits à 1 dans le masque de sous-réseau.  
En faisant un `ET` logique (plus d'information [ici](https://fr.wikipedia.org/wiki/Fonction_ET) sur le ET logique)  
Nous en déduisons que dans notre IP de `192.168.5.122`:

1. La partie réseau occupe les 27 premiers bits
2. La partie hôte occupe les 5 derniers bits.

La coupure se fait donc à l’intérieur du dernier octet de l’adresse IP. Eh oui, c’est possible!

### Les masques en notation CIDR (Classless Inter-Domain Routing)

Pour simplifier l’écriture des masques de sous réseau, on écrit simplement le nombre de bits à 1 précédé d’un /.

Pour l’exemple précédent, le couple IP masque de sous-réseau s’écrira donc: `192.168.5.122/27` car 27 bits du masque de sous-réseau sont à 1

/8 signifie donc que les 8 premiers bits du masque sont à 1  
/16 signifie donc que les 16 premiers bits du masque sont à 1  
/20 signifie donc que les 20 premiers bits du masque sont à 1 etc...

### La plage d’adresse

Une plage d’adresses est l’ensemble des adresses IP définies par l’association d’une IP et d’un masque, de la plus petite à la plus grande.  
La 1ère adresse d’une plage (la plus petite donc) est **l’adresse réseau**. La dernière adresse d’une plage (la plus grande donc) est **l’adresse de diffusion** ou **adresse de broadcast**.

---

## 👉 Les classes d'adresses IPv4

Une astuce pour reconnaitre les classes d’adresses IP lorsqu’elles sont écrites en décimal est de regarder le premier octet d’une adresse.

- S’il est compris entre 1 et 126, c’est alors une adresse de classe A
- S’il est compris entre 128 et 191, c’est une classe B
- Et entre 192 et 223, c’est une classe C.

![image.png](https://storage.googleapis.com/quest_editor_uploads/jsQQIxSnwtB9L4rud7eaOW2tC5Hw99L6.png)

Deux autres classes existent mais sont très peu utilisées:

Classe D: Les adresses de classe D sont utilisées pour les communications multicast. Le premier octet d'une adresse IP de classe D est compris entre `224` et `239.`

Classe E: Les adresses de classe E sont réservées par IANA à un usage non déterminé. Les adresses de classe E commencent toujours par `240.0.0.0` et se terminent en `255.255.255.255.`

**Remarque importante**:  
Le rangement des adresses IP en classe A, B, C,... est historique. De nos jours, cette classification n'a plus lieu d'être. Tu peux encore la trouver dans des réseaux très anciens, mais **la notification CIDR** doit être celle à utiliser.

### Les plages d’adresses privées

Il existe certaines plages d'adresse dédiées à des utilisations dans des réseaux privés (et donc inutilisables sur Internet). Il est recommandé de les utiliser pour l’adressage de réseaux privés en entreprise ou à la maison.  
Elles sont appelées plages d’adresses IP privées.

La plage 10.0.0.0/8 de `10.0.0.0` à `10.255.255.255`  
La plage 172.16.0.0/12 de `172.16.0.0` à `172.31.255.255`  
La plage 192.168.0.0/16 de `192.168.0.0` à `192.168.255.255`

ATTENTION, elles sont non routables par les routeurs de l’Internet (qui ne routent que les adresses IP publiques). Elles ne sont visibles que des hôtes de votre réseau.

### Les adresses IP publiques

Contrairement aux adresses IP privées, les adresses IP publiques ne sont généralement pas utilisées pour un usage local et réservées aux machines destinées à communiquer sur Internet.  
Les routeurs (par exemple la box que votre fournisseur d'accès à internet vous met à disposition) disposent d’une adresse IP publique côté Internet, ce qui la rend visible sur Internet (elle répondra au ping généralement) ainsi qu'une adresse IP privée telle que `192.168.1.1` ou `192.168.1.254`  
Une adresse IP publique est unique dans le monde, ce qui n’est pas le cas des adresses privées qui doivent être unique dans un même réseau local  
Les adresses IP publiques sont toutes les adresses n'appartenant pas à une plage réservée pour un usage particulier.

---

## 💪 Challenge

Répondre au quizz de validation.

## 🧐 Critères d'acceptation

Avoir toutes les réponses correctes.

---

mardi 11 novembre 2025

4 questions

mardi 11 novembre 2025

4 questions