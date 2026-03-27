---
title: "Atelier - Exploration de la pile protocolaire avec Wireshark - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3960/pages/18612"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Atelier - Exploration de la pile protocolaire avec Wireshark

Facile

1h

Auto-validation

Réseau

## Atelier - Exploration de la pile protocolaire avec Wireshark

Le modèle OSI en 7 couche est un modèle théorique servant à comprendre le fonctionnement des trames ethernet. Avec le logiciel Wireshark, tu vas pouvoir explorer la pile de protocole de cette trame.

## 1\. Prérequis

- Un ordinateur tournant sous Windows (version 10/11 ou Server 2019/2022) ou Ubuntu
- Un accès internet avec un navigateur web
- Le logiciel Wireshark installé
```shell
DISCLAIMER

Les expérimentations pratiques ont été réalisées sur une machine Ubuntu 22.04 LTS, sur un système en français, avec un clavier Français AZERTY.

Elles peuvent être reproduites avec une autre configuration d'ordinateur (autre version d'OS, autre langue, autre hyperviseur, autre système hôte, etc.), mais des différences peuvent alors apparaître et tu devras peut-être adapter les actions à effectuer.
```

## 2\. Capture de paquets

- Lancer Wireshark
- Sélectionner l'interface réseau qui va te servir pour la capture (ici le wifi):

![fenêtre de sélection de l'interface réseau dans wireshark](https://storage.googleapis.com/assets_upload_prod/gzQ73PVH9yn6WoL7JUF9DGcisUfqcoeJ.png)

- Tu peux filtrer les interfaces si nécessaire pour avoir un meilleur affichage
- Il doit rester l'interface avec laquelle tu vas capturer, sinon tu peux la sélectionner en double-cliquant dessus

![fenêtre de sélection de l'interface dans wireshark une fois que l'affichage a été filtré](https://storage.googleapis.com/assets_upload_prod/hIr8xOM8LSNtmC0DbQVGf6ifpPhlaGLD.png)

- Lancer la capture en cliquant sur l'icone bleue de Wireshark (en haut à gauche) ou en double-cliquant sur l'interface réseau choisie

## 3\. Fenêtre d'analyse

- La fenêtre d'affichage de Wireshark va s'ouvrir et la capture va commencer.
- Attend quelques secondes et ensuite clic sur le carré rouge pour arrêter la capture.
- Voici comment se compose cette fenêtre:

![fenêtre de wireshark avec une capture en cours](https://storage.googleapis.com/assets_upload_prod/l5hl6X6r5KQOaErqbv9Lgn7U5pHgxREo.png)

- **La zone de filtre d'affichage**: On peut taper un filtre qui va permettre de voir seulement les trames qui nous intéressent. Par exemple ici le filtre est `(http && (ip.dst == 46.30.212.249 || ip.src == 46.30.212.249))`. Il laisse voir uniquement les trames dont le protocole est `HTTP` et ( on utilise `&&`) dont l'adresse IP source ou (on utilise `||`) destination est `46.30.212.249`.
- **La liste des trames**: Ici nous avons 2 trames, la trame `6648` est sélectionnée (en bleu clair) on peut à ce niveau voir quelques renseignements comme l' **IP source** (`192.168.8.22`), l' **IP destination** (`46.30.212.249`) et le protocole `HTTP`. Cette trame sélectionnée est détaillée dans les cadres 3 et 4.
- **La trame décodée**: Cette zone donne le détail de la trame classé en fonction des **couches du modèle OSI**. Nous allons voir ça en détail un peu plus bas.
- **La trame en hexadécimal et ASCII**: Dans cette dernière zone, nous pouvons voir l'ensemble des octets de la trame représentés de deux manières: a. En hexadécimal sur la gauche b. En ASCII sur la droite Il s'agit bien de deux fois la même chose. Si l'on clique sur une partie, la partie correspondante se met en surbrillance dans la partie d'à coté.
```shell
Comme tu peux le constater, même sans activité de ta part, Wireshark va enregistrer toute l'activité réseau de l'ordinateur. C'est l'inconvéniant de Wireshark : il va tout capturer ! Donc il est vital d'utiliser les filtres.
```

## 4\. Capture de paquets avec filtre de capture

- Reviens sur la fenêtre de démarrage en allant sur **Fichier --> close**
- Tu vas refaire une capture, mais cette fois-ci avec un filtre de capture sur le site `www.wildcodeschool.com`

![filtre de choix d'un host](https://storage.googleapis.com/assets_upload_prod/giN06EP5vbhaQQX7BNBu2dhkZQdPo6FU.png)

- Relance la capture

**Pourquoi rien n’apparaît dans la fenêtre?**

- Vas sur internet sur le site de la [Wild Code School](https://www.wildcodeschool.com/) et navigue un peu sur le site
- La fenêtre de capture de Wireshark va se remplir!
- Quitte le site en fermant le navigateur et arrête la capture

Il existe de nombreux filtres de capture, voici quelques exemples que tu peux essayer:

- `port 80`: filtre sur le port 80 en UDP ou en TCP
- `tcp port http`: filtre sur le port 80 en TCP
- `not arp and not port 53`: filtre en excluant le protocole ARP et le port 53 qui est le port par défaut du DNS

Tu trouveras d'autres exemple sur le [wiki de Wireshark](https://wiki.wireshark.org/CaptureFilters) et sur le site de [Wireshark](https://www.wireshark.org/docs/wsug_html_chunked/ChCapCaptureFilterSection.html). Essayes-en plusieurs et regarde le résultat dans la fenêtre de capture.

## 5\. Capture du protocole ICMP avec filtre de capture

Un **ping** est le test le plus courant pour surveiller la disponibilité d’un hôte distant. L’utilitaire envoie des demandes (**ICMP Echo-Request**) sur le protocole ICMP à l’hôte spécifié et enregistre les réponses reçues (**ICMP Echo-Reply**).

- Reviens sur la fenêtre de démarrage
- A l'aide des informations que tu trouveras [ici](https://wiki.wireshark.org/Internet_Control_Message_Protocol) fait une capture en IPv4 tout en faisant un ping vers le site **[www.wildcodeschool.com](http://www.wildcodeschool.com/)**
- Tu dois avoir beaucoup de paquets dans la fenêtre de capture!
- Regardons en détails cela avec 2 paquets extrait de cette capture:

![fenêtre du détail de 2 paquets dans wireshark](https://storage.googleapis.com/assets_upload_prod/fHhdL7WGXCDuD76ZujIE9zXU7eK2keeR.png)

- Voilà les informations (à adapter avec ta propre capture) que nous avons sur ces 2 paquets:

|  | 1er paquet | 2ème paquet |
| --- | --- | --- |
| Numéro (depuis le début de la capture) | 5 | 6 |
| Horodatage (depuis le début de la capture) | 2,003137228 secondes | 2,014963032 secondes |
| Source (@IP ou hostname) | ordinateur Ubuntu | 172.67.146.155 |
| Destination (@IP ou hostname) | 172.67.146.155 | ordinateur Ubuntu |
| Protocole | ICMP | ICMP |
| Longueur | 98 octets | 98 octets |
| Commentaire | \- | \- |
| Addresse MAC (destination / source) | 34:53:d2:0b:8c:ac / cc:15:31:db:1f:23 | cc:15:31:db:1f:23 / 34:53:d2:0b:8c:ac |
| Information | Echo (ping) request = **demande** | Echo (ping) reply = **réponse** |

En examinant les résultats, Quel paquet est la requête et quel paquet est la réponse?

- Reviens sur la fenêtre de démarrage et cette fois ci, fait une capture avec de l'IPv6. Pour cela tu dois adapter ta **commande ping** et ton **filtre de capture**
- Analyse le résultat et regarde s'il y a des différences dans la fenêtre de **liste des trames**

## 6\. Analyse de la capture ICMP

- Procède à la capture d'un ping IPv4 avec le filtre de capture adapté
- Une fois que tu as quelques paquets, arrête la capture
- Sélectionne l'un des paquets en **Echo (ping) request** (tu trouveras ça dans la colonne *Info*)
- Va voir maintenant les informations dans la fenêtre du milieu

![fenêtre montrant la colonne info](https://storage.googleapis.com/assets_upload_prod/O7fHeFi7msBK0r9WrhcE2jCXmsYNtVJL.png)

- Les informations que tu as concernent les différents protocoles encapsulés les uns dans les autres:
	- "Frame 7:..." ==> Niveau 1
		- "Ethernet II,..." ==> Niveau 2, c'est **la trame ethernet**
		- "Internet Protocol Version 4,..." ==> Niveau 3, c'est le paquet IP
		- "Internet Control Message Protocol" ==> Niveau 4, c'est le protocole **ICMP**
- Tu as ainsi les différents protocoles impliqué dans un ping et **l'ordre d'encapsulation**
- Chaque partie peut être déployée (cliquer sur le +), à l'intérieur, Wireshark a décodé le moindre octet de la trame

![détail sur le contenu d'un paquet](https://storage.googleapis.com/assets_upload_prod/nULyDYLSV7v3w5DFrXBfl4pf5VcwW3bx.png)

## 7\. Analyse d'une capture sans filtre (de capture)

- Procède à une autre capture, mais cette fois-ci sans filtre de capture
- Ouvre le site wildcodeschool.com dans ton navigateur, navigue un peu sur le site, vas chercher des informations, et arrête la capture
- Examine les requêtes et réponses et trouve l'ensemble des protocoles impliqués dans une communication web et l'ordre d'encapsulation. Tu peux t'aider de ce schéma pour t'aider:

![modele osi et tcp avec des protocoles](https://storage.googleapis.com/assets_upload_prod/QzCzeI2EM3VjKOiNekypXVh9mP4w9tHo.png)

- Utilise le filtre d'affichage adéquat pour avoir le **protocole TLS**. Que constate-tu au niveau de la trame?

Voici quelques exemples de filtre d'affichage:

| Filtre d'affichage | Rôle |
| --- | --- |
| http | Uniquement les trames dont le protocole est HTTP |
| bootp | Uniquement les trames dont le protocole est DHCP ou BOOTP |
| dns | Uniquement les trames dont le protocole est dns |
| icmp | Uniquement les trames dont le protocole est icmp |
| ip.addr==@IP | Uniquement les trames pour l'adresse @IP |
| ip.src==@IP | Uniquement les trames dont l'IP source @IP |
| ip.dst==@IP | Uniquement les trames dont l'IP destination est @IP |
| eth.addr==@MAC | Uniquement les trames dont l'adresse MAC est @MAC |
| tcp.port==80 | Uniquement les trames TCP dont le port source ou destination est 80 |
| (ip.src==@IP) && (tcp.port==80) | Uniquement les trames TCP dont l'IP source est @IP ET dont le port source ou destination est 80 |
| (ip.src==@IP) \|\| (tcp.port==80) | Uniquement les trames TCP dont l'IP source est @IP OU dont le port source ou destination est 80 |
| ip.dst==224.0.0.0/4 | Uniquement les trames MULTICAST |
| ip.dst==224.0.0.0/4 &&!ssdp | Uniquement les trames MULTICAST ET pas (NOT) les trames SSDP |

Continue à t’entraîner avec Wireshark en utilisant les filtres de capture et d'affichage.

Bravo à toi pour être arrivé au bout de cet atelier!

Quête terminée le **mardi 18 novembre 2025**