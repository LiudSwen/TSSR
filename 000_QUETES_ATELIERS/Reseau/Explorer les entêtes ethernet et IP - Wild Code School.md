---
title: "Explorer les entêtes ethernet et IP - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2080/pages/6767"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Explorer les entêtes ethernet et IP

Moyen

3 pairs

Réseau

## Explorer les entêtes ethernet et IP

```shell
Introduction
```

Lorsqu'un paquet IP est émis sur un réseau ethernet, on a conceptuellement un paquet IP encapsulé dans une trame ethernet.

Concrètement, ça signifie que les informations qui vont circuler sur le réseau sont:

1 - les champs de l'entête ethernet  
2 - les champs de l'entête IP  
3 - le contenu (payload) du paquet IP.

Les champs des entêtes étant reconnaissable par l'ordre dans lequel ils circulent et par leur taille.

Retrouvons et analysons ces différentes informations.

## 🤓 Objectifs:

- ✅ **Retrouver le contenu de l'entête d'une trame ethernet**
- ✅ **Retrouver le contenu de l’entête d'un paquet IP**
- ✅ **Analyser une en-tête IP**

## 📕 Schéma global d'une trame ethernet 2

![image](https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Ethernet_Type_II_Frame_format.svg/1920px-Ethernet_Type_II_Frame_format.svg.png)

Voici les différents éléments qui compose la trame ethernet 2:

- L'entête (14 octets), lui même composée de:
	- L' **adresse MAC de destination** (6 octets)
		- L' **adresse MAC source** (6 octets)
		- l' **EtherType** (2 octets)
- La **charge utile** (ou payload) qui est le datagramme IP
- Le **CRC checksum** (4 octets) qui vérifie l'intégrité de la trame ethernet

On parle de trame ethernet **2** dans les cas ou le champs Ethertype contient une valeur supérieure à 1536.

## 👉 Datagramme IP ou En-tête IP

Tu pourras trouver tous les détails dans la [RFC791](https://datatracker.ietf.org/doc/html/rfc791) à partir de la page 10.

![image](https://www.brimbelle.org/mattieu/projects/reseaulution/1280/Cours_Theorique_III_fichiers/image002.gif)

Il est composé de:

- **La version** (4 bits)
	- 00 – Réservé
		- 01 – Non assigné
		- 02 – Non assigné
		- 03 – Non assigné
		- 04 – IP V4
		- 05 – ST Datagram Mode
		- 06 – IP V6
		- 07 – Non assigné
		- 08 – Non assigné
		- 09 – Non assigné
		- 10 – Non assigné
		- 11 – Non assigné
		- 12 – Non assigné
		- 13 – Non assigné
		- 14 – Non assigné
		- 15 – Réservé
- **L'IHL** (Internet Header Lenght) ou **HLEN** (Header Length) --> longueur d'en-tête (4 bits)  
	Représente la longueur en mots de 32 bits de l’entête IP. Par défaut, il est égal à 5 (20 octets). Cependant, avec les options de l’entête IP, il peut être compris entre 6 et 15.  
	Le fait que le codage soit sur 4 bits, la taille maximum de l’entête IP est donc de 15\*32bits/8 = 60 octets
- **Le service** (8 bits), décomposé de la sorte:
	- La priorité (3 bits)
		- Le délai (1 bit)
		- Le débit (1 bit)
		- La fiabilité (1 bit)
		- Le coût (1 bit)
		- le MBZ (Must Be Zero) codé sur 1 bit avec une valeur 0  
		Plus de détails sur le champs service dans la [RFC791](https://datatracker.ietf.org/doc/html/rfc791) à la page 11
- **La longueur total** (16 bits soit 2 octets)
- **L'identification** (16 bits soit 2 octets)
- **Les flags** (3 bits)
- **Les Offsets** (13 bits)
- **Le TTL** (Time to Live) ou durée de vie (8 bits ou 1 octet)
- **Le protocole** (8 bits):  
	Désigne le protocole porté par le paquet, au dessus de la couche IP.  
	Exemples de valeurs:
	- 1 --> protocole ICMP
		- 6 --> TCP  
		Tu les trouveras tous dans la [RFC1700](https://www.frameip.com/rfc-1700-assigned-numbers/) à partir de la page 7.
- **Le checksum** (16 bits ou 2 octets) qui vérifie l'intégrité du paquet IP
- **L'adresse IP source** (32 bits soit 4 octets)
- **L'adresse IP destination** (32 bits soit 4 octets)
- **Options**: champs de longueur variable de 0 à 40 octets
- **Le padding** ou bourrage: champs de longueur variable de 0 à 7 bits  
	Le champ Bourrage n’existe que pour assurer à l’en-tête IP une taille totale multiple de  
	4 octets. Le bourrage se fait par des octets à 0.

## 👉 Correspondance avec les analyseurs de trames réseaux

Lorsqu'on analyse ce qui circule sur le réseau, on peut utiliser ces information pour décortiquer les trames.

Examinons une représentation hexadécimale d'une trame ethernet.  
Dans cette représentation, la trame est découpée en plusieurs lignes, chaque ligne étant numérotée (c'est la première colonne -4 chiffres suivi de:).  
Le reste de la ligne est la valeur traduite en hexadécimale qui a circulée sur le réseau.  
La dernière colonne visible dans les exemples ci dessous est une traduction en ASCII qui n'est pas toujours pertinente, notamment lorsque les informations qui circulent sont au format binaire et non texte, comme c'est le cas pour les entête ethernet et IP.

## Exemple de trame ethernet:

```shell
0000: 00 A0 24 BD 75 DB 08 00 02 05 2D FE 08 00 45 00 ..$.u.....-...E.
0010: 00 60 3C EF 00 00 1C 06 A4 FE 80 00 64 01 D0 80 .\`<.........d...
0020: 08 29 00 17 04 2B 47 A8 BA 20 01 A3 96 14 50 18 .)...+G.. ....P.
0030: 20 00 72 D3 00 00 FF FB 01 FF FD 01 0D 0A 0D 0A .r.............
0040: 55 4E 49 58 28 72 29 20 53 79 73 74 65 6D 20 56 UNIX(r) System V
0050: 20 52 65 6C 65 61 73 65 20 34 2E 30 20 28 63 65 Release 4.0 (ce
0060: 76 73 61 30 30 29 0D 0A 0D 00 0D 0A 0D 00 9F 59 vsa00).........Y
0070: 6E FC n.
```

Dans cette trame, on va retrouver les éléments vu plus haut.

- **Le MAC Header**:  
	0000: `00 A0 24 BD 75 DB 08 00 02 05 2D FE 08 00` 45 00..$.u.....-...E.  
	0010: 00 60 3C EF 00 00 1C 06 A4 FE 80 00 64 01 D0 80.\`<.........d...  
	0020: 08 29 00 17 04 2B 47 A8 BA 20 01 A3 96 14 50 18.)...+G......P.  
	0030: 20 00 72 D3 00 00 FF FB 01 FF FD 01 0D 0A 0D 0A.r.............  
	0040: 55 4E 49 58 28 72 29 20 53 79 73 74 65 6D 20 56 UNIX(r) System V  
	0050: 20 52 65 6C 65 61 73 65 20 34 2E 30 20 28 63 65 Release 4.0 (ce  
	0060: 76 73 61 30 30 29 0D 0A 0D 00 0D 0A 0D 00 9F 59 vsa00).........Y  
	0070: 6E FC n.
	- L'adresse de destination: `00 A0 24 BD 75 DB`
		- L'adresse source: `08 00 02 05 2D FE`
		- L'EtherType: `08 00`
- **L'en-tête IP**:

0000: 00 A0 24 BD 75 DB 08 00 02 05 2D FE 08 00 `45 00`..$.u.....-...E.  
0010: `00 60 3C EF 00 00 1C 06 A4 FE 80 00 64 01 D0 80`.\`<.........d...  
0020: `08 29` 00 17 04 2B 47 A8 BA 20 01 A3 96 14 50 18.)...+G......P.  
0030: 20 00 72 D3 00 00 FF FB 01 FF FD 01 0D 0A 0D 0A.r.............  
0040: 55 4E 49 58 28 72 29 20 53 79 73 74 65 6D 20 56 UNIX(r) System V  
0050: 20 52 65 6C 65 61 73 65 20 34 2E 30 20 28 63 65 Release 4.0 (ce  
0060: 76 73 61 30 30 29 0D 0A 0D 00 0D 0A 0D 00 9F 59 vsa00).........Y  
0070: 6E FC n.

Avec les différents éléments:

- La version: `4`
- L'IHL: `5`
- Le service: `00`
- La longueur total: `0060` (équivaut à 96 octets)
- L'identification: `3C EF`
- Les flags: `00`
- Les Offsets: `00`
- Le TTL: `1C`
- Le protocole: `06` ==> protocole TCP (on peut le vérifier [ici](https://www.frameip.com/rfc-1700-assigned-numbers/))
- Le checksum: `A4 FE`
- L'adresse IP source: `80 00 64 01` soit 128.0.100.1
- L'adresse IP destination: `D0 80 08 29` soit 208.128.8.41
- Option: ici il n'y en a pas
- Le padding: ici il n'y en a pas
- Le reste constitue les données et le FCS (`9F 59 6E FC`)

## 💪 Challenge

Analyse la trame ethernet ci-dessous et retrouve les différents éléments demandés.

```shell
0000: 00 12 17 41 c2 c7 00 1a 73 24 44 89 08 00 45 00 ..A.... s$D...E.
0010: 01 bb da c2 40 00 3c 06 fc 9d d5 e4 00 2a 3e 93 ....@.<......*>.
0020: 51 3b 00 50 04 85 87 c7 14 d5 00 12 b0 cb 50 19 Q;.P..........P.
0030: 19 20 95 45 00 00 3e 20 0a 3c 74 64 20 77 69 64 . .E..> .<td wid
0040: 74 86 3d 22 33 30 25 22 20 20 68 65 69 67 68 74 th="30%" height
```

Tu dois retrouver:

- L'adresse MAC source
- L'adresse MAC destination
- L'EtherType
- Le contenu de l'en-tête IP, soit:
	- La version du protocole
		- L'IHL
		- Le service
		- La longueur totale du datagramme IP (en décimal, pas en hexadécimal)
		- L'identifiant affecté au datagramme
		- Les flags
		- Les offsets
		- La valeur du champ TTL
		- Le contenu du champ protocole. En déduire le protocole encapsulé dans le  
		paquet IP.
		- Le checksum
		- L'adresse IP source (en format décimal)
		- L'adresse IP de destination (en format décimal)

Publie le résultat de tes recherches au format Markdown dans l'éditeur intégré sous la forme:

- Ce qui est demandé à gauche (15 infos)
- Ce que tu as trouvé à droite

## 🧐 Critères d'acceptation

Le texte posté:

- Est dans une syntaxe Markdown correcte
- Doit contenir toutes les réponses

Solution postée le **lundi 17 novembre 2025**

| Questions | Réponses |
| --- | --- |
| L'adresse MAC source: | 00 1a 73 24 44 89 |
| L'adresse MAC destination: | 00 12 17 41 c2 c7 |
| L'EtherType: | 08 00 |
| La version du protocole: | 4 |
| L'IHL: | 5 |
| Le service: | 00 |
| La longueur totale du datagramme IP: | 443 (0x01bb) |
| L'identifiant affecté au datagramme: | da c2 |
| Les flags: | 40 |
| Les offsets: | 00 |
| La valeur du champ TTL: | 3c |
| Le contenu du champ protocole. | 06 - TCP |
| Le checksum: | fc 9d |
| L'adresse IP source (en format décimal): | 213.228.0.42 (d5 e4 00 2a) |
| L'adresse IP de destination (en format décimal): | 62.147.81.59 (3e 93 51 3b) |