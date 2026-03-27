---
title: "Installation de Wireshark et analyse de trames ethernet - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2082/pages/10504"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Installation de Wireshark et analyse de trames ethernet

Moyen

3 pairs

Réseau

## Installation de Wireshark et analyse de trames ethernet

## Qu'est-ce que Wireshark?

Wireshark est un logiciel d'écoute et d'analyse de traces réseau libre lancé par Gerald Combs en 1998. Une communauté de spécialistes du réseau et de développeurs de logiciels maintient Wireshark et continue de le mettre à jour pour suivre les évolutions des protocoles réseaux.

Wireshark est absolument sûr à utiliser. Les agences gouvernementales, les entreprises, les organisations à but non lucratif et les établissements d'enseignement utilisent Wireshark à des fins de dépannage et d'enseignement. Il n'y a pas de meilleure façon d'apprendre le réseau que de regarder le trafic sous le microscope Wireshark.

```shell
Wireshark est un puissant renifleur (sniffer) de paquets. Son utilisation est donc à proscrire sans une autorisation explicite du propriétaire du réseau sous la peine de tomber dans l'illégalité.

En pratique : utilise donc wireshark uniquement pour analyser ton propre réseau !
```

## 🤓 Objectifs:

✅ Installer Wireshark  
✅ Faire une première capture de trame  
✅ Savoir reconnaître et trouver les informations concernant Ethernet dans la fenêtre de Wireshark  
✅ Utiliser les filtres d'affichage

## 💻 Installer Wireshark

On peut installer Wireshark sur Windows, MacOS, et Linux.

Pour **MacOS et Windows**, tu peux aller voir [ici](https://www.wireshark.org/#download) pour trouver les sources d'installation. Tu n'auras plus qu'à installer le logiciel.  
Si vraiment tu n'y arrive pas, [ici](https://networkproguide.com/install-wireshark-on-windows-10/) tu auras une explication pour l'installer sur Windows, et [ici pour MacOS](https://www.geeksforgeeks.org/how-to-install-wireshark-on-macos/).

Pour **GNU/Linux**, [la doc officielle](https://www.wireshark.org/docs/wsug_html_chunked/ChBuildInstallUnixInstallBins.html) recommande une méthode d'installation par paquets.

```shell
Wireshark nécessite des droits particuliers pour pouvoir capturer le trafic réseau.

Pour pouvoir le lancer sans être root, sur Debian et les systèmes dérivés (ubuntu, mint, kali, etc...) on peut suivre les recommandations du readme spécifique
```

## 👉 1er lancement

![image](https://image.jimcdn.com/app/cms/image/transf/dimension=910x10000:format=jpg/path/s5ab5d7650401adc0/image/ibbd0089d22888bc5/version/1617725349/image.jpg)  
Au lancement de Wireshark, tu peux voir une fenêtre qui montre une liste de toutes les interfaces réseau que tu peux surveiller. Tu as également un champs de filtre de capture, pour ne capturer que ce que tu souhaites.

## 🕸️ Capturer des paquets

![image](https://www.rabbitmq.com/img/wireshark-main-window.png)  
Cliquer sur l'icone en forme d'aileron bleu en haut à gauche pour démarrer la capture. L'icône devient alors grise et la fenêtre principale se remplie de données en temps réel!  
Cliquer sur l'icône en forme de carré rouge pour arrêter la capture.

## 🔬 Analyser la capture

## Les vues de Wireshark:

- La vue du haut, la **liste des paquets**, contient la liste des paquets capturés
- La vue du milieu, le **détail des paquets**, montre toutes les informations du paquet sélectionné.
- La vue du bas, les **octets de paquets**, montre les données brutes du paquet sélectionné, **en hexadécimal**.

![image](https://www.wireshark.org/docs/wsug_html/wsug_graphics/ws-main.png)

Ces vues peuvent être affichées ou masquées via le menu **View**.

## 🗒️ La liste des paquets

Elle contient des lignes qui avancent dans le temps, chaque ligne représentant un paquet capturé, ainsi que les colonnes suivantes:

- **No.**: Il s'agit de l'ordre de numérotation du paquet qui a été capturé. La parenthèse indique que ce paquet fait partie d'une conversation.
- **Time**: Cette colonne t'indique combien de temps après le début de la capture ce paquet a été capturé. Tu peux modifier cette valeur dans le menu Paramètres si tu souhaites afficher quelque chose de différent.
- **Source**: Il s'agit de l'adresse du système qui a envoyé le paquet.
- **Destination**: il s'agit de l'adresse de destination de ce paquet.
- **Protocole**: il s'agit du type de paquet, par exemple, TCP, DNS, DHCPv6 ou ARP.
- **Length**: Cette colonne t'indique la longueur du paquet en octets.
- **Info**: cette colonne te donne plus d'informations sur le contenu du paquet et varie selon le type de paquet dont il s'agit.

## 🔎 Détails des paquets:

![image](https://www.wireshark.org/docs/wsug_html_chunked/wsug_graphics/ws-details-pane.png)

Ce volet affiche les protocoles et les entêtes de protocole du paquet sélectionné dans la fenêtre « Liste de paquets ».  
Ces protocoles sont affichés du plus bas niveau en haut (protocole physique) en haut de la vue au plus haut niveau (applicatif) en bas de la vue.  
Les lignes de résumé du protocole (étiquettes de sous-arborescence) et les champs du paquet sont affichés dans une arborescence qui peut être développée et réduite.

## 🕶️ Filtres de capture et d'affichage

![fenêtre affichage wireshark qui montre le filtre tcp](https://storage.googleapis.com/quest_editor_uploads/UlwIQaEOZJrw0Rwe4LW4koS5va3sMnou.png)

#### Les filtres de capture (comme tcp port 80)

Ils ne doivent pas être confondus avec les filtres d'affichage.  
Ils sont beaucoup plus limités et sont utilisés pour réduire la taille d'une capture de paquets bruts.  
Les filtres de capture sont définis avant de démarrer une capture de paquet et ne peuvent pas être modifiés pendant la capture.  
Quelques filtres de captures:

- **host IP-address**: ce filtre limite la capture au traffic de et vers l'adresse IP
- **net 192.168.0.0/24**: ce filtre capture tout le traffic sur le sous-réseau
- **dst host IP-address**: capture les paquets envoyés vers l'hôte spécifique
- **port 53**: capture le traffic seulement sur le port 53
- **port not 53 and not arp**: capture tout le traffic sauf le port 53 (DNS) et le traffic ARP

#### Les filtres d'affichage (comme tcp.port == 80)

Ils sont utilisés pour masquer certains paquets de la liste des paquets et peuvent être modifié à la volée.  
Quelques filtres d'affichage:

- **ip.src==IP-address and ip.dst==IP-address**: Ce filtre montre les paquets d'un ordinateur (ip.src) à un autre (ip.dst). Tu peux également utiliser ip.addr pour afficher les paquets vers et depuis cette adresse IP
- **tcp.port eq 25**: Ce filtre te montrera tout le trafic sur le port 25 (SMTP)
- **icmp**: Ce filtre te montrera uniquement le trafic ICMP dans la capture, il s'agit très probablement de pings.
- **ip.addr!= IP\_address**: Ce filtre te montre tout le trafic sauf le trafic vers ou depuis l'ordinateur spécifié

> *Dans la fenêtre principale, on peut trouver le filtre de capture juste au-dessus de la liste des interfaces et dans la boîte de dialogue des interfaces. Le filtre d'affichage peut être changé au-dessus de la liste de paquets*

---

## 💪 Challenge

- Télécharger le fichier [MyFirstCapture.pcapng](https://github.com/WildCodeSchool/TSSR_Resources/raw/main/pcap/MyFirstCapture.pcapng) et l'ouvrir avec Wireshark
- Répondre aux questions ci-dessous au format markdown

## Les questions:

1. Quels protocoles ont été utilisés dans la trace réseau capturée? Indique comment tu as eu cette information (quelle fenêtre, éventuellement quelle ligne ou quelle colonne).
2. Quelles sont les adresses IP et les adresses MAC des interfaces ayant échangé des informations?
3. Quel filtre d'affichage permet de ne plus afficher les paquets ARP?
4. Quelles informations sont disponibles dans la colonne **info** de **la liste des paquets** pour la ligne 3?
5. Le paquet N°8 est-il une question ou une réponse? et quel est le paquet correspondant (la question, si c'est une réponse ou la réponse, si c'est une question?

## 🧐 Critères d'acceptation

- Une réponse correcte est fourni à chacune des 5 questions
- La syntaxe markdown est respectée

Solution postée le **jeudi 13 novembre 2025**

**Analyse de la capture réseau**

**1\. Protocoles utilisés dans la capture**  
Les protocoles présents dans la trace réseau sont **ARP** et **ICMP**.  
Je les ai identifiés dans la **fenêtre supérieure**, dans la colonne **Protocol**, où chaque paquet affiche le protocole associé.

---

**2\. Adresses IP et adresses MAC échangées**

Adresses IP:

- 10.1.1.1
- 10.1.1.2

Elles apparaissent dans la **fenêtre supérieure**, colonnes **Source** et **Destination**, sur les paquets ICMP.

Adresses MAC:

- 00:50:79:66:68:00
- 00:50:79:66:68:01

Je les ai trouvées dans la **fenêtre du milieu**, section **Ethernet II**, dans les lignes **Source** et **Destination** des paquets ARP.

---

**3\. Filtre permettant de masquer les paquets ARP**  
Le filtre d’affichage à entrer dans la barre de filtre pour masquer les paquets ARP est:  
not arp

---

**4\. Informations de la colonne Info pour le paquet n°3**  
Echo (ping) request id=0xb78e, seq=1/256, ttl=64 (reply in 4)

---

**5\. Nature du paquet n°8 et paquet correspondant**  
Le paquet n°8 est une **réponse ICMP Echo Reply**.  
Il correspond à la **requête ICMP Echo** du paquet n°7.