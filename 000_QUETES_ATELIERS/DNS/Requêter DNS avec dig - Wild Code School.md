---
title: "Requêter DNS avec dig - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2103/pages/18629"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
DNS

## Requêter DNS avec dig

La commande dig permet de faire des requêtes DNS ce qui la place naturellement dans la boite à outil classique d'administration systèmes et réseaux.

Facile

1h

3 pairs

DNS

## Requêter DNS avec dig

## Introduction

La commande **dig** fait partie des outils habituels d'administration systèmes et réseaux. Elle permet de faire toutes sortes de requêtes DNS.

## 🤓 Objectifs:

✅ Découvrir la commande **dig**  
✅ Appréhender son fonctionnement  
✅ Explorer le fonctionnement de DNS

## Sommaire

## 👉 Le DNS

Le DNS est une base de données répartie permettant d'associer des enregistrements appelés *Resource Records* (RR) a des noms de domaine.

```bash
Domain Name System (sur WikipediA)La lecture de la page WikipediA sur le DNS constitue une bonne entrée en matière sur ce sujet.https://fr.wikipedia.org/wiki/Domain_Name_System
```

## 👉 La commande dig

**dig** (*domain information groper*) est un programme Unix en ligne de commande (CLI) pour effectuer des requêtes DNS. C'est un client interactif permettant d'interroger des serveurs DNS.

Il fait partie de la suite logiciel du serveur [bind](https://www.isc.org/bind/).  
Sous GNU/Linux, il est en général disponible dans le package **dnsutils**.

On peut vérifier qu'il est correctement installé en l'appelant par son nom dans un terminal. Sans argument, il affiche la liste des serveurs de nom de la racine.

```bash
1
wilder@host:~$ dig
2

3
; <<>> DiG 9.18.1-1ubuntu1.1-Ubuntu <<>>
4
;; global options: +cmd
5
;; Got answer:
6
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 58750
7
;; flags: qr rd ra; QUERY: 1, ANSWER: 13, AUTHORITY: 0, ADDITIONAL: 1
8

9
;; OPT PSEUDOSECTION:
10
; EDNS: version: 0, flags:; udp: 65494
11
;; QUESTION SECTION:
12
;.                IN    NS
13

14
;; ANSWER SECTION:
15
.            7188    IN    NS    a.root-servers.net.
16
.            7188    IN    NS    g.root-servers.net.
17
.            7188    IN    NS    m.root-servers.net.
18
.            7188    IN    NS    f.root-servers.net.
19
.            7188    IN    NS    b.root-servers.net.
20
.            7188    IN    NS    c.root-servers.net.
21
.            7188    IN    NS    i.root-servers.net.
22
.            7188    IN    NS    l.root-servers.net.
23
.            7188    IN    NS    e.root-servers.net.
24
.            7188    IN    NS    j.root-servers.net.
25
.            7188    IN    NS    k.root-servers.net.
26
.            7188    IN    NS    h.root-servers.net.
27
.            7188    IN    NS    d.root-servers.net.
28

29
;; Query time: 0 msec
30
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
31
;; WHEN: Fri Jun 10 14:24:23 CEST 2022
32
;; MSG SIZE  rcvd: 239
```

La requête par défaut récupère le champs **A** associé au domaine indiqué.  
Par exemple pour récupérer les adresses IP version 4 associées au domaine **wildcodeschool.com**:

```bash
1
wilder@host:~$ dig wildcodeschool.com
2

3
; <<>> DiG 9.18.1-1ubuntu1.1-Ubuntu <<>> wildcodeschool.com
4
;; global options: +cmd
5
;; Got answer:
6
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54080
7
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
8

9
;; OPT PSEUDOSECTION:
10
; EDNS: version: 0, flags:; udp: 65494
11
;; QUESTION SECTION:
12
;wildcodeschool.com.        IN    A
13

14
;; ANSWER SECTION:
15
wildcodeschool.com.    300    IN    A    172.67.146.155
16
wildcodeschool.com.    300    IN    A    104.21.79.167
17

18
;; Query time: 11 msec
19
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
20
;; WHEN: Fri Jun 10 14:40:29 CEST 2022
21
;; MSG SIZE  rcvd: 79
22
```

Mais si on souhaite plutôt récupérer les adresses IP version 6, il faut indiquer qu'on veut récupérer le champs **AAAA**

```bash
1
wilder@host:~$ dig AAAA wildcodeschool.com
2

3
; <<>> DiG 9.18.1-1ubuntu1.1-Ubuntu <<>> AAAA wildcodeschool.com
4
;; global options: +cmd
5
;; Got answer:
6
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 34263
7
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
8

9
;; OPT PSEUDOSECTION:
10
; EDNS: version: 0, flags:; udp: 65494
11
;; QUESTION SECTION:
12
;wildcodeschool.com.        IN    AAAA
13

14
;; ANSWER SECTION:
15
wildcodeschool.com.    300    IN    AAAA    2606:4700:3034::6815:4fa7
16
wildcodeschool.com.    300    IN    AAAA    2606:4700:3032::ac43:929b
17

18
;; Query time: 11 msec
19
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
20
;; WHEN: Fri Jun 10 14:42:54 CEST 2022
21
;; MSG SIZE  rcvd: 103
22
```

La vidéo suivante explore un peu plus la syntaxe et les différents cas d'utilisation de **dig**

```bash
How to Use the dig Command on Linux
Cet article sur howtogeek.com décrit dans le détail les différents éléments de sortie de dig et montre plusieurs des options disponibles de cette commandehttps://www.howtogeek.com/663056/how-to-use-the-dig-command-on-linux/
```

Et bien sûr, pour un maximum de détail et d'information: `man dig`

---

## ☝️ Résumé

La commande **dig** permet, à l'aide d'un terminal, de récupérer n'importe quelle information de DNS. Elle permet donc, notamment:

- de récupérer les adresses IPv4 associées à un nom de domaine
- de récupérer les adresses IPv6 associées à un nom de domaine
- et beaucoup d'autres choses...

---

## 📝 Quiz

```bash
# 1  - A est un Resource Record de DNSVraiFauxValider# 2 est un client DNSdispose d'une interface graphiquepermet uniquement de récupérer les adresses IPest un outil permettant de déboguer DNSValider# 3 contient des adresses IPv6est un label de qualité pour les andouillettesest complémentaire de Aest une version améliorée du champs AValider# 4 digbindAnginxValiderTon score :0 / 4
```

---

## 💪 Challenge

Utilise la commande **dig** pour récupérer les informations suivantes:

- les adresses IP version 4 du site web de la **Wild Code School**! [www.wildcodeschool.com](http://www.wildcodeschool.com/)
- les adresses IP version 6 d' **odyssey** et en déduire l'hébergeur de ton fournisseur de quête préféré
- (Bonus) les noms des serveurs de noms faisant autorité sur le domaine wildcodeschool.com et le serveur primaire.
- (Bonus) Refaire les requêtes précédentes en précisant l'utilisation du serveur récursif **quad9** (9.9.9.9 ou 2620:fe::9)

Poste les commandes tapées et leurs résultats dans un lien Github.

## 🧐 Critères d'acceptation

- Toutes les adresses IPv4 de [www.wildcodeschool.com](http://www.wildcodeschool.com/) ont été trouvées
- Toutes les adresses IPv6 d'odyssey.wildcodeschool.com ont été trouvées
- Les commandes utilisées sont correctes.

Solution postée le **dimanche 14 décembre 2025**

[https://gist.github.com/LiudSwen/db222a3557187844ab39dd511c8f2e91](https://gist.github.com/LiudSwen/db222a3557187844ab39dd511c8f2e91)