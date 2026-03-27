---
title: "Atelier - Communication VPN avec OpenVPN et clé symétrique - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2503/pages/9164"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sécurité réseau

## Atelier - Communication VPN avec OpenVPN et clé symétrique

Moyen

2h

Auto-validation

Sécurité réseau

## Atelier - Communication VPN avec OpenVPN et clé symétrique

## Introduction

Un **VPN** (*Virtual Private Network*) vise à reproduire les conditions d'accès à des ressources qu'offre un réseau privé à des hôtes devant traverser des réseaux publics tels qu'Internet.

L'objectif de cet atelier, est de sécuriser la connexion entre 2 ordinateurs avec le logiciel **OpenVPN** en utilisant une clé de chiffrement unique.

## 🤓 Objectifs:

✅ Installer OpenVPN  
✅ Créer une clé de chiffrement  
✅ Mettre en place un VPN à clé de chiffrement unique

## Sommaire

- [🔧 Prérequis](https://odyssey.wildcodeschool.com/quests/2503/pages/9164#-pr%C3%A9requis)
- [🔬 Configuration initiale des PC](https://odyssey.wildcodeschool.com/quests/2503/pages/9164#-configuration-initiale-des-pc)
- [🏗️ Création d'une clé sécurisé](https://odyssey.wildcodeschool.com/quests/2503/pages/9164#%EF%B8%8F-cr%C3%A9ation-dune-cl%C3%A9-s%C3%A9curis%C3%A9)
- [🔬 Envoi de la clé sur le serveur](https://odyssey.wildcodeschool.com/quests/2503/pages/9164#-envoi-de-la-cl%C3%A9-sur-le-serveur)
- [💬 Test d'une communication non-sécurisée](https://odyssey.wildcodeschool.com/quests/2503/pages/9164#-test-dune-communication-non-s%C3%A9curis%C3%A9e)
- [🔬 Mise en place du VPN](https://odyssey.wildcodeschool.com/quests/2503/pages/9164#-mise-en-place-du-vpn)
- [🔑 Test d'une communication sécurisée](https://odyssey.wildcodeschool.com/quests/2503/pages/9164#-test-dune-communication-s%C3%A9curis%C3%A9e)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2503/pages/9164#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2503/pages/9164#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2503/pages/9164#-crit%C3%A8res-dacceptation)

## 🔧 Prérequis

Tu as besoin de 2 PC ou VM sous Virtualbox.  
Pour chacun:

- Une distribution Linux, comme Ubuntu
- 1 carte réseau en mode `Réseau interne`, avec l'adresse `172.16.10.1` pour PC1 et `172.16.10.2` pour PC2
- 1 carte réseau permettant d'aller sur internet, en mode `NAT` par exemple
- Un compte **wilder1** sur PC1, et **wilder2** sur PC2 (ne pas oublier de donner les droits sudo à chacun de ces utilisateurs avec `usermod -aG sudo <user>`)

> PC1 est le *client* et PC2 est le *serveur*, la connexion sécurisée se fera donc de PC1 vers PC2.

```shell
Les expérimentations pratiques ont été testées sur une distribution Linux Ubuntu 22.04 LTS installée dans une machine virtuelle VirtualBox 7 tournant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites avec d'autres distributions Linux, sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## 🔬 Configuration initiale des PC

Sur PC1 et PC2 faire les actions suivantes.  
MAJ des paquets:

```bash
1
sudo apt update && sudo apt upgrade -y
```

Installation d'OpenVPN:

```bash
1
sudo apt install openvpn
```

Installation de SSH:

```bash
1
sudo apt install openssh-server
```
```shell
Sur PC1 tu peux mettre la version client ou serveur d'openssh.
Différence entre la version client et server d'openssh :

openssh-client : Fournit les outils clients nécessaires pour se connecter à un serveur SSH (le client SSH, scp et d'autres outils).

openssh-server : Utilisé pour mettre en place un serveur SSH. On peut se connecter à ce serveur à distance via SSH à partir d'un ordinateur sur lequel openSSH-client est installé.
```
```shell
N'oublie pas de paramétrer le fichier de configuration ssh sur PC2 pour désactiver l'accès root et n’autoriser que le compte wilder2.

Relance le service ssh après tes modifications.
```

Installation de Wireshark:

```bash
1
sudo apt install wireshark
```

> Lors de l'installation de Wireshark, répondre `oui` à la question `Should non-superusers be able to capture packets ?`. Cela permet que les utilisateurs qui ne sont pas super-utilisateurs puissent capturer des paquets.  
> Ensuite, ajouter l'utilisateur courant au groupe Wireshark: `usermod -a -G wireshark <Utilisateur>`

## 🏗️ Création d'une clé sécurisé

Si les machines sont des VM, il faut désactiver ou supprimer les cartes NAT et ne garder que les cartes réseaux du réseaux interne.  
Dans la suite de cet atelier, tu va créer une clé de chiffrement, qui sera partagée entre le client et le serveur.

```shell
Le procédé utilisé ici est un chiffrement symétrique. La même clé est utilisée pour chiffrer et déchiffrer les données. Cela signifie que le serveur et le client doivent partager la même clé secrète.
```

Sur PC1, se placer dans `/etc/openvpn/client`.  
Générer la clé avec la commande `sudo openvpn --genkey secret <NomDeLaCléStatique>.key`.

Explication:

- `--genkey`: Argument de la ligne de commande d'OpenVPN qui indique une génération de clé
- `secret`: Indique un chiffrement de clé **symétrique**
- `<NomDeLaCléStatique>.key`: Nom de la clé, dans cet atelier le nom est **static-OpenVPN.key**

Tu peux vérifier le contenu de la clé avec la commande `cat`:

```bash
1
wilder1@PC1:/etc/openvpn/client$ sudo cat static-OpenVPN.key 
2
#
3
# 2048 bit OpenVPN static key
4
#
5
-----BEGIN OpenVPN Static key V1-----
6
1b12a19f315cf34d7cc472e5f25f7239
7
c9f1a25ce51f62191f461704d5439b60
8
ba9b1dc44bb9b8ac20543ec92039fe22
9
c8c13da8501379ebb008807c6def738f
10
27ef1d0bb0e2943717c5b6eedf1cd631
11
0195a01b22c470c75ab49039ee94ae0c
12
856e9bfa10aced3500a2229b87874f44
13
afbbc19f6b6600b3d6b51f6d3565894a
14
99845a17ca412bcbd09c0ba4c75ac557
15
d10fbc5700df43d555af30de5d288cff
16
fcdb3e98e02fb82e3ce95ac3208adaea
17
dafcbb1f3bf4bdb8924f7a2d7d4d5cf2
18
e065990766a7ffa396f9d26134e518a0
19
00967cd69b08198a5b2eb23d5ccba38c
20
244e9b6434a2333aec87fdd67a4d0763
21
6497e84cc944a9a251f944f1df4e42fa
22
-----END OpenVPN Static key V1-----
```

## 🔬 Envoi de la clé sur le serveur

On va utiliser la commande `scp` pour envoyer d'une manière sécurisée le fichier `static-OpenVPN.key` de PC1 vers PC2.

```shell
Tu ne peux pas copier directement la clé générée dans le dossier /etc/openVPN sur PC2 car le compte wilder2 n'a pas les droits sur ce dossier.

De plus, on ne peut pas utiliser sudo dans la commande scp.
```
```shell
Les méthodes de copies sécuriséesLa commande scp ainsi que sftp et SSHFS.https://help.ubuntu.com/community/SSH/TransferFiles
```

Méthode:

- Copie de la clé de PC1 vers PC2 avec `sudo scp static-OpenVPN.key wilder2@172.16.10.2:~`
- Connexion en ssh sur PC2: `ssh wilder2@172.16.10.2`
- Une fois la connexion établie en SSH sur PC2, on utilise `sudo` pour copier la clé de `~` vers `/etc/openvpn/server/`.

## 💬 Test d'une communication non-sécurisée

Fais un ping de PC1 vers PC2 et lance Wireshark.  
Vérifie:

- Ton ping est fonctionnel, tu as bien un `echo request` et un `echo reply`
- Le protocole est bien l'ICMP
- La partie `Data` du protocole ICMP est visible en clair

## 🔬 Mise en place du VPN

**Sur PC1**:  
Place toi dans le dossier où tu a mis la clé.  
Exécute la commande `sudo openvpn --dev tun --remote 172.16.10.2 --ifconfig 10.10.5.1 10.10.5.2 --cipher AES-256-CBC --secret static-OpenVPN.key`

Explications:

- `--dev tun`: Spécifie que le VPN doit utiliser un périphérique de réseau virtuel de type **TUN**. On peut aussi utiliser `--dev tap` pour un réseau de type pont (bridge) pour simuler un périphérique Ethernet. **tun** est plus courant pour les VPN de routage.
- `--remote 172.16.10.2`: Adresse IP du serveur VPN (ici PC2)
- `--ifconfig 10.10.5.1 10.10.5.2`: Les adresses IP dans le tunnel VPN, respectivement client (PC1) et serveur (PC2)
```shell
Dans la commande, les adresses sont inversées : en premier l'adresse IP virtualle du serveur (donc PC2), et ensuite l'adresse IP virtuelle du client (donc PC1). Ici les adresses IP virtuelles de PC1 et PC2 sont respectivement 10.10.5.1 et 10.10.5.2.
Les adresses IP choisies pour le tunnel VPN (10.10.5.1 et 10.10.5.2) ne doivent pas être utilisées ailleurs dans le réseau pour éviter tout conflit d'adressage.
```
- `--cipher AES-256-CBC`: Définit l'algorithme de chiffrement utilisé. On peut aussi mettre AES-128-CBC (plus rapide, moins sécurisé) ou AES-256-GCM (plus sécurisé, offre l'intégrité des données).
- `--secret static-OpenVPN.key`: Chemin du fichier contenant la clé secrète statique

**Sur PC2**:  
Place toi dans le dossier où tu as mis la clé.  
Exécute la commande `sudo openvpn --dev tun --ifconfig 10.10.5.2 10.10.5.1 --cipher AES-256-CBC --secret static-OpenVPN.key`

```shell
Ici l'option --remote n'est pas utilisée car elle indique au client VPN sur quel serveur il doit se connecter.
```

La communication sécurisée est établit lorsque sur les 2 machines il y a le message `Initialization Sequence Completed`.

## 🔑 Test d'une communication sécurisée

Fais un ping de PC1 vers PC2 (avec les adresses IP virtuelles) et lance Wireshark.  
Vérifie:

- Ton ping est fonctionnel:
	- Tu as bien une source qui correspond à l'adresse IP **réelle** de PC1, soit 172.16.10.1, et un destinataire avec l'adresse IP 172.16.10.2.
- Le protocole est bien OpenVPN
- Sélectionne la partie `Data` du protocole OpenVPN, et clic avec le bouton droit de la sourie pour avoir le menu. Sélectionne `Suivre` puis `Flux UDP`. Tu dois voir le chiffrement du paquet de données.

## ☝️ Résumé

**Pourquoi Wireshark ne montre pas les adresses IP virtuelles?**

10.10.5.1 (PC1) et 10.10.5.2 (PC2) sont des adresses IP virtuelles utilisées à l'intérieur du tunnel VPN. Elles sont utilisées pour le trafic encapsulé et chiffré qui passe à travers le VPN.  
172.16.10.1 (PC1) et 172.16.10.2 (PC2) sont les adresses IP réelles dans le réseau local 172.16.10.0/24.

Lors du ping de PC1 vers l'adresse IP virtuelle de PC2 (`ping 10.10.5.2`), cette adresse n'est que dans le tunnel VPN.  
Les paquets ICMP générés par le ping sont d'abord encapsulés dans le trafic VPN sur PC1, puis transmis à travers le réseau local entre les adresses IP réelles de PC1 et PC2.  
Lorsque Wireshark capture le trafic (sur PC1), il est sur l'interface réseau locale, donc il n'affiche que les adresses IP réelles sous lesquelles les paquets VPN encapsulés sont transmis.

---

## 💪Challenge

Réalise cet atelier jusqu'à avoir une communication sécurisée entre les 2 PC.

## 🧐 Critères d'acceptation

Valide l'atelier une fois que tu as vérifié que la communication entre les 2 machines est bien chiffrée par le VPN.

Quête terminée le **mercredi 11 février 2026**