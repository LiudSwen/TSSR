---
title: "Atelier : Routage et NAT - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3066/pages/18174"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Atelier: Routage et NAT

Moyen

Auto-validation

Réseau

## Atelier: Routage et NAT

## Introduction

Dans cet atelier consacré au **Routage et NAT (Network Address Translation)** avec Cisco Packet Tracer!

![Image d'un Schéma réseau Cisco packet tracer](https://storage.googleapis.com/assets_upload_prod/vLmfZIMRN6qG6VbTFKiyKlwLtQaH2s0s.jpg)

```shell
En tant que technicien(ne) réseau dans une grande école composée de trois bâtiments, tu es responsable, avec ton équipe, de la conception, de la configuration et de la gestion de l'infrastructure réseau de l'établissement.
Récemment, l'école a acquis trois commutateurs et deux routeurs Cisco pour améliorer son réseau. C'est pourquoi tu as choisi de simuler cette mise à jour sur Cisco Packet Tracer.
On t'a spécifiquement demandé de configurer chaque bâtiment dans un sous-réseau distinct, d'établir le routage entre ces sous-réseaux et de mettre en place l'accès à Internet.
Cette simulation te permettra de prévoir efficacement l'intégration des nouveaux équipements, d'anticiper les besoins en configuration et de faciliter une transition en douceur
```
```shell
Au cours de cet atelier, tu vas construire deux réseaux en parallèle : un réseau IPv4 et un réseau IPv6 avec des adresses GUA (Global Unicast Addresses). .
```

## 🤓 Objectifs:

✅ Comprendre les principes fondamentaux du routage et du NAT.  
✅ Apprendre à configurer des périphériques réseau virtuels dans Cisco Packet Tracer.  
✅ Mettre en place des routes pour permettre la communication entre différents réseaux.  
✅ Configuration du NAT pour masquer les adresses IP internes lors de l'accès à Internet.

## Sommaire

- [✔️ Prérequis](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#%EF%B8%8F-pr%C3%A9requis)
- [👉 Premiers pas avec Cisco Packet Tracer](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-premiers-pas-avec-cisco-packet-tracer)
	- [❓ Qu'est-ce que Cisco Packet Tracer?](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-quest-ce-que-cisco-packet-tracer-)
		- [🔍 Aperçu de l'interface de Cisco Packet Tracer](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-aper%C3%A7u-de-linterface-de-cisco-packet-tracer)
		- [🛠️ Création d'un premier réseau](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#%EF%B8%8F--cr%C3%A9ation-dun-premier-r%C3%A9seau)
		- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-exercice)
- [👉 Routage](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-routage)
	- [🔗 Ajout et connexion des périphériques](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-ajout-et-connexion-des-p%C3%A9riph%C3%A9riques)
		- [🛠️ Configuration du routeur](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#%EF%B8%8F-configuration-du-routeur)
		- [🧪 Test de connectivité](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-test-de-connectivit%C3%A9)
		- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-exercice-1)
- [👉 NAT (Network Address Translation)](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-nat-network-address-translation)
	- [🌐 Simuler Internet](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-simuler-internet)
		- [🌐 Le NAT PAT](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-le-nat-pat)
		- [🛠️ Configuration du NAT](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#%EF%B8%8F-configuration-du-nat)
		- [🧪 Test et vérification du NAT](https://odyssey.wildcodeschool.com/quests/3066/pages/18174#-test-et-v%C3%A9rification-du-nat)

## ✔️ Prérequis

Pour tirer le meilleur parti de cet atelier, assure-toi d'avoir:

- Cisco Packet Tracer installé sur ton ordinateur. Tu peux le télécharger depuis le site officiel de Cisco si ce n'est pas déjà fait.
- Des connaissances de base sur les réseaux informatiques, y compris les adresses IP, les sous-réseaux et le fonctionnement des routeurs.
- Une compréhension élémentaire de l'interface de Cisco Packet Tracer, bien que nous explorerons ensemble les fonctionnalités nécessaires.
- Un compte sur le site de Cisco NetAcad.
```shell
Si tu n'en as pas encore, crée un compte et connecte-toi. Ensuite, accède au lien suivant pour télécharger des ressources utiles : https://www.netacad.com/portal/resources/packet-tracer.
```

## 👉 Premiers pas avec Cisco Packet Tracer

## ❓ Qu'est-ce que Cisco Packet Tracer?

![Image d'un Schéma réseau Cisco packet tracer](https://storage.googleapis.com/assets_upload_prod/cj4u1Zf6Ndi0hmui0KXJIqSxsz9qHxXY.jpg)  
**Cisco Packet Tracer** est un logiciel de simulation réseau développé par Cisco Systems. Il est largement utilisé dans le domaine de l'éducation, en particulier pour l'apprentissage et la pratique des concepts de réseaux informatiques. Conçu pour être intuitif et puissant, Cisco Packet Tracer permet de créer des réseaux complexes en simulant le comportement des équipements réseau.

## 🔍 Aperçu de l'interface de Cisco Packet Tracer

Lorsque tu ouvres Cisco Packet Tracer, tu es accueilli par un espace de travail principal. Voici les éléments clés que tu trouveras dans cette interface:

1. **Espace de travail**: C'est dans le grand espace blanc que tu vas créer ton réseau, configurer les équipements et observer des simulations
2. **Barre d'outils principale**: Cette barre propose des icônes raccourcies pour les commandes de menu les plus utilisées telles que (*Nouveau fichier, Enregistrer, Zoom, Copier, Coller, ect...*).

![icônes de la barre d'outils principale](https://storage.googleapis.com/assets_upload_prod/ddANwG1Xub3phZDPbin8cLPRx4bNEaaf.png)

1. **Barre d'outils communs**: Cette barre te donne accès aux outils couramment utilisés dans l'espace de travail:  
	*Sélection, Inspecter, Supprimer, Redimensionner la forme, Placer une note, Palette de dessin, Ajouter un PDU simple et Ajouter un PDU complexe.*

![icônes de la barre d'outils communs](https://storage.googleapis.com/assets_upload_prod/p8zZ45uhZmMcBJUcGYxgPJhPhCueSCIc.png)

1. **Barre temps réel/simulation**: Cette barre te permet de basculer entre le mode temps réel et le mode simulation grâce aux onglets de cette barre. Elle offre également des boutons pour Réinitialiser les appareils et Accélérer le temps, ainsi que les boutons de contrôle de lecture et le bouton de bascule de la liste des événements en mode simulation.

  
5\. **Boîte des composants réseau**: C'est ici que tu choisis les appareils et les connexions à placer dans l'espace de travail. Elle comprend la boîte de sélection de type d'appareil et la boîte de sélection spécifique à l'appareil. Il y a un champ de recherche qui te permet de trouver rapidement un appareil spécifique en entrant son nom lorsque tu survoles l'icône de l'appareil dans la boîte spécifique à l'appareil.

![Boîte des composants réseau](https://storage.googleapis.com/assets_upload_prod/SfnM0ADmYwCP0gBBBN8BoHSioI20NDZd.png)

## 🛠️ Création d'un premier réseau

Dans cette section, tu vas créer ton premier sous-réseau *(Bâtiment 1)* dans Cisco Packet Tracer en ajoutant des PC sur la zone de travail, les connectant via un commutateur à l'aide de câbles et en configurant les adresses IP.

1. **Ajout de PC sur la zone de travail:**
	- Dans le coin inferieur gauche de Cisco Packet Tracer, explore la catégorie **End Devices** (Périphériques finaux).
		- Recherche et sélectionne l'icône représentant un **PC**, puis fais-la glisser sur la zone de travail.
2. **Ajout d'un commutateur:**
	- Dans la catégorie **Network Devices** (Périphériques réseaux), localise l'icône représentant un commutateur (switch).
		- Fais glisser cet icône sur la zone de travail à proximité du PC que tu as ajouté.
3. **Connexion du PC au commutateur:**
	- Dans la catégorie **Connections**, sélectionne l'icône en forme d'éclair pour les câbles.
		- Clique sur un port du commutateur, puis sur un port d'un PC pour établir une connexion.  
		![démo1](https://storage.googleapis.com/assets_upload_prod/NxGDVrqKhCXb709ldNI3oFn13jgDwpX7.gif)
```shell
Le câble en forme d'éclair permet de choisir et de brancher le câble  automatiquement.
Le câble en forme de ligne complète représente les câbles droits.
Le câble en forme de ligne pointillée représente les câbles croisés.
Le câble jaune représente les câbles en fibre optique.
```
1. **Configuration des adresses IP sur le PC:**
	- Clique sur le `PC0` pour ouvrir sa fenêtre de configuration.
		- Sélectionne l'onglet **Desktop** (Bureau), puis **IP Configuration** (Configuration IP).
		- Configure l'adresse IPv4 du `PC0`:
		- Adresse IP: `192.168.1.10`
				- Masque de sous-réseau: `255.255.255.0`
				- Cela sera le premier hôte de notre sous-réseau `192.168.1.0/24`
		- Configure l'adresse IPv6 du `PC0`:
		- Adresse IPv6: `2001:db8:f3c1:1::10`
				- Préfixe de sous-réseau: `/64`
				- Cela sera le premier hôte de notre sous-réseau IPv6 `2001:db8:f3c1:1::/64`

### 🔬 Exercice

Maintenant que tu as configuré le premier PC avec l'adresse IPv4 `192.168.1.10` et l'adresse IPv6 `2001:db8:1::10`, ajoute deux autres PCs au commutateur et configure leurs adresses IP pour qu'ils soient dans le même sous-réseau.

1. **Ajout de nouveaux PCs:**
	- Ajoute deux nouveaux PCs à côté du premier sur la zone de travail.
2. **Configuration des adresses IP:**
	- `PC1`
		- IPv4: Configure l'adresse IP `192.168.1.11` et le masque de sous-réseau `255.255.255.0`.
				- IPv6: Configure l'adresse IP `2001:db8:f3c1:1::11` et le préfixe de sous-réseau `64`.
		- `PC2`
		- IPv4: Configure l'adresse IP `192.168.1.12` et le masque de sous-réseau `255.255.255.0`.
				- IPv6: Configure l'adresse IP `2001:db8:f3c1:1::12` et le préfixe de sous-réseau `64`.
3. **Tests de connectivité:**
	- Ouvre une fenêtre de terminal sur chaque PC (dans l'onglet **Desktop**, clique sur **Command Prompt**).
		- Effectue des tests de ping pour IPv4.
		- Effectue des tests de ping pour IPv6.
		- Assure-toi que tous les pings sont réussis pour vérifier que les PC peuvent se communiquer correctement dans le même réseau pour les adresses IPv4 et IPv6.
4. **Marquage des adresses IP:**
	- Dans la barre d'outils située en haut de Cisco Packet Tracer, clique sur l'icône en forme de **bloc-note** pour créer des notes sur ton schéma.
		- Marque les adresses IPv4 et IPv6 de chaque nœud pour une référence rapide.
		- Utilise l'outil de dessin en forme de **rectangle** pour illustrer le sous-réseau `192.168.1.0` et `2001:db8:f3c1::/64` en choisissant une couleur de ton choix.
```shell
Voir la solutionTon réseau devrait maintenant ressembler à ceci, même si certaines interfaces peuvent être connectées différemment !

Tu peux personnaliser les informations affichées sur les périphériques, y compris les étiquettes des interfaces. Cela te permet de savoir facilement à quelle interface est connecté chaque câble. Pour ce faire, accède aux paramètres de Packet Tracer via Preferences > Interfaces > Always Show Port Labels.
```

## 👉 Routage

Dans cette partie de l'atelier, tu vas créer un nouveau sous-réseau `192.168.2.0/24 -  2001:db8:f3c1:2::/64` *(Bâtiment 2)* et le connecter au réseau existant via un routeur **Cisco 2911**.

## 🔗 Ajout et connexion des périphériques

1. Dans la catégorie `Network Devices > Routers`, sélectionne le routeur `2911` et fais-le glisser sur la zone de travail.
2. Utilise un câble pour connecter l'interface `GigabitEthernet0/0` du routeur à l'un des ports libres du commutateur `Switch0` du sous-réseau `192.168.1.0/24`.
3. Ajoute deux PCs `PC3` et `PC4` et connecte-les à un nouveau commutateur **2960** `Switch1`.
4. Connecte ce nouveau commutateur `Switch1` à l'interface `GigabitEthernet0/1` du routeur.

## 🛠️ Configuration du routeur

1. **Renommer le routeur:**
	- Clique sur le routeur `Router0` et va sur l'onglet **CLI** pour le configurer en ligne de commande.
		- Une fois devant la console du router appuie sur Entrée et le prompt `Router>` s'affichera.
		- Pour commencer, assure-toi d'être en **mode configuration** sur le routeur. Pour cela utilise la commande `enable` pour activer le routeur et `configure terminal` pour accéder au mode de configuration et change le nom du routeur en `R0`.
```shell
Router> enable
   Router# configure terminal
   Router(config)# hostname R0
   R0(config)#
```
1. **Configuration des l'interfaces du routeur:**

Attribue la première adresse de chaque sous-réseau comme adresse IP de passerelle:

- `Interface GigaEthernet 0/0`:
	- IPv4: `192.168.1.1`
		- IPv6: `2001:db8:f3c1:1::1`
- `Interface GigaEthernet 0/1`:
	- IPv4: `192.168.2.1`
		- IPv6: `2001:db8:f3c1:2::1`

Utilise les commandes suivantes pour configurer les deux interfaces et activer le routage IPv6:

```shell
R0> enable
R0# configure terminal
R0(config)# interface GigabitEthernet0/0
R0(config-if)# ip address 192.168.1.1 255.255.255.0
R0(config-if)# ipv6 address 2001:db8:f3c1:1::1/64
R0(config-if)# no shutdown
R0(config-if)# exit
R0(config)# interface GigabitEthernet0/1
R0(config-if)# ip address 192.168.2.1 255.255.255.0
R0(config-if)# ipv6 address 2001:db8:f3c1:2::1/64
R0(config-if)# no shutdown
R0(config-if)# exit
R0(config)# ipv6 unicast-routing
```
```shell
interface GigabitEthernet0/* : Accède au mode de configuration de l'interface.
ip address : Définit l'adresse IPv4 et son masque de sous-réseau pour l'interface.
ipv6 address : Définit l'adresse IPv6 et son préfixe pour l'interface.
no shutdown : Active l'interface.
exit : Quitte le mode de configuration de l'interface pour retourner au mode de configuration terminal.
ipv6 unicast-routing : Active le routage de IPv6.
```

Assure-toi d'exécuter la commande `do show ip route` pour voir la table de routage.

1. **Sauvegarde de la configuration:**

Pour que la configuration du routeur soit persistante après un redémarrage, pense à la sauvegarder avec la commande: `copy running-config startup-config` ou `write memory`.

```shell
R0> enable
   R0# copy running-config startup-config
   Destination filename [startup-config]? 
   Building configuration...
   [OK]
```

## 🧪 Test de connectivité

1. **Configuration réseau des PCs**
	- `PC3`
		- IPv4: Configure l'adresse IP `192.168.2.10` et le masque de sous-réseau `255.255.255.0`.
				- IPv6: Configure l'adresse IP `2001:db8:f3c1:2::10` et le préfixe de sous-réseau `64`.
		- `PC4`
		- IPv4: Configure l'adresse IP `192.168.2.11` et le masque de sous-réseau `255.255.255.0`.
				- IPv6: Configure l'adresse IP `2001:db8:f3c1:2::11` et le préfixe de sous-réseau `64`.
2. **Définir les passerelles:**

Rends-toi sur chaque PC des deux sous-réseaux pour définir la passerelle en utilisant les adresses IP que tu as attribuées aux interfaces du routeur `R0`.

- Sélectionne l'onglet **Desktop** (Bureau) > **IP Configuration** (Configuration IP) > **Default Gateway**.
	- `PC0 ` -> `192.168.1.1`
		- `PC1 ` -> `192.168.1.1`
		- `PC2 ` -> `192.168.1.1`
		- `PC3 ` -> `192.168.2.1`
		- `PC4 ` -> `192.168.2.1`
1. **Test de ping:**

À partir de `PC2`, ouvre un terminal et utilise la commande `ping` pour vérifier la connectivité avec `PC4` en utilisant à la fois **IPv4** et **IPv6**.

```shell
Voir la solutionTon réseau devrait maintenant ressembler à ceci. Les étiquettes ajoutées sont là pour clarifier le schéma, mais tu n'es pas obligé.e de les inclure toutes dans ta simulation.
```

### 🔬 Exercice

1. **Crée un nouveau réseau** `192.168.3.0/24 - 2001:db8:f3c1:3::/64`:

Ajoute un PC `PC5` et configure son adresse IP:  
\- IPv4: `192.168.3.10/24`  
\- IPv6: `2001:db8:f3c1:3::10`

Connecte-le à un nouveau commutateur `Switch2`.

1. **Crée un nouveau routeur **2911** et renomme-le en** `R1`:

Utilise l'interface `GigabitEthernet0/1` de `R1` comme passerelle pour ce nouveau réseau et configure l'adresse IP:  
\- IPv4: `192.168.3.1/24`  
\- IPv6: `2001:db8:f3c1:3::1`

Connecte l'interface `GigabitEthernet0/1` au nouveau commutateur `Switch2`.

1. **Connecte les routeurs** `R0` et `R1`

Utilise un câble croisé *(ligne en pointillé)* pour connecter l'interface `GigabitEthernet0/2` de `R0` à l'interface `GigabitEthernet0/0` de `R1`.

1. **Configure les routeurs** `R0` et `R1`

**IPv4**: Crée un nouveau sous-réseau `192.168.4.0/30` pour établir une connexion *point-à-point(deux nœuds seulement)* entre les routeurs `R0` et `R1`.

```shell
Le CIDR /30 offre précisément deux adresses IP utilisables, ce qui en fait un choix optimal pour une liaison point-à-point entre deux routeurs.
```
- Configure l'interface `GigabitEthernet0/2` de `R0` avec l'adresse IP `192.168.4.1`.
- Configure l'interface `GigabitEthernet0/0` de `R1` avec l'adresse IP `192.168.4.2`.

**IPv6**: Étant donné qu'il s'agit d'une connexion *point-à-point*, tu vas configurer les adresses IPv6 en ***lien local***. Cette configuration est efficace car elle permet aux interfaces de communiquer directement en utilisant des adresses IPv6 automatiquement configurées `fe80::/10`, sans besoin de configuration manuelle des adresses globales.

- Configuration du routeur `R0`:
```shell
R0> enable
R0# configure terminal
R0(config)# interface GigabitEthernet0/2
R0(config-if)# ip address 192.168.4.1 255.255.255.252
R0(config-if)# ipv6 enable
R0(config-if)# no shutdown
R0(config-if)# exit
```
- Configuration du routeur `R1`:
```shell
R1> enable
R1# configure terminal
R1(config)# interface GigabitEthernet0/0
R1(config-if)# ip address 192.168.4.2 255.255.255.252
R1(config-if)# ipv6 enable
R1(config)# ipv6 unicast-routing
R1(config-if)# no shutdown
R1(config-if)# exit
```
```shell
interface GigabitEthernet0/* : Accède au mode de configuration de l'interface.
ip address : Définit l'adresse IPv4 et son masque de sous-réseau pour l'interface.
ipv6 enable : Active l'IPv6 sur l'interface en génère une adresse link-local.
no shutdown : Active l'interface.
exit : Quitte le mode de configuration de l'interface pour retourner au mode de configuration terminal.
ipv6 unicast-routing : Active le routage de IPv6.
```

Les adresses de lien local IPv6 `FE80::/10` sont générées automatiquement en utilisant la méthode **EUI-64** à partir de l'adresse MAC de l'interface réseau. N'oublie pas de noter ces adresses IPv6 de lien local, car tu en auras besoin plus tard pour configurer les routes IPv6.

Pour les visualiser, utilise la commande `do show ipv6 interface brief`.

Voici les adresses générées par les deux interfaces de mes deux routeurs:

- `R0 / GigabitEthernet0/2`: `FE80::260:70FF:FECD:3703`
- `R1 / GigabitEthernet0/0`: `FE80::20C:85FF:FE83:1D01`
1. **Déclare les routes statiques sur les deux routeurs selon la table de routage ci-dessous:**
- Table de routage `R0`

**IPv4**

| Réseau | Masque | Passerelle | Interface | Type |
| --- | --- | --- | --- | --- |
| 192.168.1.0 | 255.255.255.0 | Directement | GigabitEthernet0/0 | C |
| 192.168.2.0 | 255.255.255.0 | Directement | GigabitEthernet0/1 | C |
| 192.168.4.0 | 255.255.255.252 | Directement | GigabitEthernet0/2 | C |
| 192.168.3.0 | 255.255.255.0 | 192.168.4.2 | GigabitEthernet0/2 | S |

**IPV6**

| Réseau | Préfixe | Passerelle | Interface | Type |
| --- | --- | --- | --- | --- |
| 2001:db8:f3c1:1::/64 | /64 | Directement | GigabitEthernet0/0 | C |
| 2001:db8:f3c1:2::/64 | /64 | Directement | GigabitEthernet0/1 | C |
| fe80::/64 | /64 | Directement | GigabitEthernet0/2 | C |
| 2001:db8:f3c1:3::/64 | /64 | fe80::20c:85ff:fe83:1d01 | GigabitEthernet0/2 | S |

- Table de routage `R1`

**IPv4**

| Réseau | Masque | Passerelle | Interface | Type |
| --- | --- | --- | --- | --- |
| 192.168.3.0 | 255.255.255.0 | Directement | GigabitEthernet0/1 | C |
| 192.168.4.0 | 255.255.255.252 | Directement | GigabitEthernet0/0 | C |
| 192.168.1.0 | 255.255.255.0 | 192.168.4.1 | GigabitEthernet0/0 | S |
| 192.168.2.0 | 255.255.255.0 | 192.168.4.1 | GigabitEthernet0/0 | S |

**IPv6**

| Réseau | Préfixe | Passerelle | Interface | Type |
| --- | --- | --- | --- | --- |
| 2001:db8:f3c1:3::/64 | /64 | Directement | GigabitEthernet0/1 | C |
| fe80::/64 | /64 | Directement | GigabitEthernet0/0 | C |
| 2001:db8:f3c1:1::/64 | /64 | fe80::260:70ff:fecd:3703 | GigabitEthernet0/0 | S |
| 2001:db8:f3c1:2::/64 | /64 | fe80::260:70ff:fecd:3703 | GigabitEthernet0/0 | S |

```shell
Pour déclarer les routes statiques sur les routeurs Cisco, utilise la commande ip route. Assure-toi d'être en mode configuration Router(config)#.

Exemple v4 : pour déclarer la route statique IPv4 vers le réseau 10.0.0.0/8 via la passerelle 9.0.0.254

Router(config)# ip route 10.0.0.0 255.0.0.0 9.0.0.254

Exemple v6 : pour déclarer la route statique IPv6 vers le réseau fd03:5fe:b:a3f::/64 via la passerelle FE80::1, spécifie également l'interface de sortie

Router(config)# ipv6 route fd03:5fe:b:a3f::/64 GigabitEthernet0/0 FE80::1
```
```shell
Voir la solutionR0
R0> enable
R0# configure terminal
R0(config)# ip route 192.168.3.0 255.255.255.0 192.168.4.2
R0(config)# ipv6 route 2001:db8:f3c1:3::/64 GigabitEthernet0/2 FE80::20C:85FF:FE83:1D01

R1
R1> enable
R1# configure terminal
R1(config)# ip route 192.168.1.0 255.255.255.0 192.168.4.1
R1(config)# ip route 192.168.2.0 255.255.255.0 192.168.4.1
R1(config)# ipv6 route 2001:db8:f3c1:1::/64 GigabitEthernet0/0 FE80::260:70FF:FECD:3703
R1(config)# ipv6 route 2001:db8:f3c1:2::/64 GigabitEthernet0/0 FE80::260:70FF:FECD:3703

Adapte les commandes avec tes propres adresses de lien local FE80::. Pour voir les adresses configurées, utilise la commande suivante :
Router# show ipv6 interface brief
```
1. **Test de ping:**

À partir de `PC2`, ouvre un terminal et utilise la commande `ping` pour vérifier la connectivité avec `PC5` en utilisant à la fois **IPv4** et **IPv6**.

```shell
Voir la solutionFélicitations ! Tu devrais maintenant avoir un réseau qui ressemble à cela, avec un routage fonctionnel entre les 4 sous-réseaux !
```

## 👉 NAT (Network Address Translation)

## 🌐 Simuler Internet

Dans cette partie, tu vas simuler une connexion à Internet et configurer la route par défaut sur les deux routeurs de notre réseau. Pour ce faire, tu vas ajouter un routeur 2911 supplémentaire pour simuler une adresse IP publique sur Internet avec laquelle nous allons tenter de communiquer.

À la fin de cette partie, ton schéma devrait ressembler à ceci:

![Schéma complet](https://storage.googleapis.com/assets_upload_prod/OLpM8HN8Ot7axBe8QlDqlK5qORp1PkcP.png)

**Ajout et configuration des routeurs:**

1. Ajoute un nouveau routeur `2911`, renomme le `R2` et Connect son interface `Gigbitethernet0/0` à l'interface `Gigbitethernet0/2` du `R1`.
2. Assigne les adresses IP publiques v6 et v4 aux interfaces des routeurs `R1` et `R0`
- `R2` Interface `GigaEthernet 0/0`:
	- IPv4: `80.65.24.2` `255.255.255.252`
		- IPv6: `2001:db8:1000::1 /48`
- `R1` Interface `GigaEthernet 0/2`:
	- IPv4: `80.65.24.1` `255.255.255.252`
		- IPv6: `2001:db8:1000:: /48`
1. Ajoute la route par défaut sur les deux routeurs `R0` et `R1`.
```shell
Rappel: La route par défaut 0.0.0.0 0.0.0.0 ::/0 est la route que le routeur utilise lorsqu'il ne connaît pas la destination d'un paquet. Elle est utilisée pour acheminer les paquets vers un routeur ou une passerelle de niveau supérieur (souvent connecté à Internet), permettant ainsi au trafic de quitter le réseau local.
```
```shell
Voir la solutionR0
R0> enable
R0# configure terminal
R0(config)# ip route 0.0.0.0 0.0.0.0 192.168.4.2
R0(config)# ipv6 route ::/0 GigabitEthernet0/2 FE80::20C:85FF:FE83:1D01

R1
R1> enable
R1# configure terminal
R1(config)# ip route 0.0.0.0 0.0.0.0 80.65.24.2
R1(config)# ipv6 route ::/0 GigabitEthernet0/2 2001:db8:1000::1 /48
```
1. Une fois les routes configurées sur les routeurs selon les tables de routage, essaye de faire un ping vers l'adresse ip d'internet `80.65.24.2` depuis le `PC3` en utilisant **IPv4** et **IPv6**.. Qu'est-ce que tu observes?
```shell
Voir la solutionLe ping IPv6 fonctionne, mais le ping IPv4 échoue. Pourquoi ?

Grâce aux adresses GUA (Global Unicast Address) de l'IPv6, nos clients possèdent chacun une adresse IP publique, ce qui les rend joignables depuis l'extérieur.

Pour comprendre pourquoi le ping IPv4 échoue, tu dois passer en mode simulation :

Passe en mode Simulation en cliquant sur le bouton situé en bas à droite de l'écran.
Clique sur Edit Filters et sélectionne uniquement le protocole ICMP.

Relance le ping le routeur R2 avec la commande ping 80.65.24.2, puis appuie sur le bouton Play.
Observe l'enveloppe apparaître sur le PC3 et suis le trajet du paquet à travers les différentes étapes.

En mode simulation, tu peux cliquer sur l'enveloppe pour voir les en-têtes des différentes couches TCP/IP.
Le paquet atteint sa destination, le routeur R2, mais la réponse ICMP echo-reply ne revient pas. C'est parce qu'Internet, représenté par R2, ne sait pas comment atteindre notre sous-réseau privé 192.168.2.0/24 pour renvoyer la réponse à 192.168.2.10.
Le chapitre suivant sur le NAT expliquera comment résoudre ce problème en utilisant une adresse IP publique comme IP source dans nos paquets pour que Internet puisse nous répondre via cette adresse.
```

## 🌐 Le NAT PAT

Le **NAT PAT** est une forme de NAT qui permet de traduire plusieurs adresses IP privées en une seule adresse IP publique en utilisant différents ports TCP ou UDP. Cela permet de prendre en charge simultanément de nombreuses connexions réseau à partir d'une seule adresse IP publique.

## 🛠️ Configuration du NAT

Pour configurer le NAT PAT sur `R1` et permettre aux périphériques du réseau privé `192.168.2.0/24` d'accéder à Internet via une seule adresse IP publique `80.65.24.1`, voici les commandes à taper:

```shell
R1> enable
R1# configure terminal
R1(config)# interface GigabitEthernet0/0
R1(config-if)# ip nat inside
R1(config-if)# exit
R1(config)# interface GigabitEthernet0/2
R1(config-if)# ip nat outside
R1(config-if)# exit
R1(config)# ip nat inside source list 1 interface GigabitEthernet0/2 overload
R1(config)# access-list 1 permit 192.168.2.0 0.0.0.255
R1(config)# do show ip nat translations
```
```shell
ip nat inside : Définit l'interface comme interne pour le NAT.
ip nat outside : Définit l'interface comme externe pour le NAT.
ip nat inside source list 1 interface GigabitEthernet0/2 overload : Configure le NAT Overload pour traduire les adresses IP internes en utilisant l'interface externe, (Overload est le terme qui désigne le PAT chez Cisco)
access-list 1 permit 192.168.2.0 0.0.0.255 : Crée une liste d'accès autorisant le sous-réseau 192.168.2.0/24. Le wildcard mask 0.0.0.255 signifie que les 24 premiers bits de l'adresse doivent correspondre exactement à 192.168.2 et que les 8 derniers bits (la partie hôte) peuvent varier de 0 à 255.
do show ip nat translations : Affiche les traductions NAT actives.
```

Avec cette configuration, les PCs du sous-réseau `192.168.2.0/24` pourront accéder à Internet en utilisant l'adresse IP publique `80.65.24.1` attribuée à l'interface `GigabitEthernet0/2` de `R1`.

## 🧪 Test et vérification du NAT

En mode simulation, envoie à nouveau un ping depuis ton PC `192.168.2.10` et intercepte le paquet lorsqu'il atteint le `R1`.

Clique sur le paquet intercepté, puis dans l'onglet **Inbound PDU Details** *(pré-routage)*, tu verras que l'adresse IP source du paquet est `192.168.2.10`.

En revanche, dans l'onglet **Outbound PDU Details** \_(post-routage), l'adresse IP source est celle attribuée à l'interface **WAN** `GigabitEthernet0/2` du `R1`.

Cela indique que le **NAT** a correctement traduit l'adresse privée en adresse publique, permettant ainsi à ton PC d'être joignable depuis l'extérieur.

![Capture du pré et post-routage](https://storage.googleapis.com/assets_upload_prod/MLGl7cHHnxFYmp1J82bziEMA0MI1Slsp.png)

```shell
Si tu es arrivé.e jusqu'ici avec le NAT fonctionnel, bravo ! Tu viens de mettre en place ton premier réseau avec NAT sur Cisco Packet Tracer.
```

Quête terminée le **mardi 30 décembre 2025**