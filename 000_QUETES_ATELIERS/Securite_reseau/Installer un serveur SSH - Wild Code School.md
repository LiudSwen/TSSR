---
title: "Installer un serveur SSH - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2367/pages/10080"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sécurité réseau

## Installer un serveur SSH

Installation du serveur OpenSSH pour permettre l'ouverture d'un terminal à distance en utilisant le protocole sécurisé SSH

Facile

30mins

3 pairs

Sécurité réseau

## Installer un serveur SSH

## Introduction

[OpenSSH](https://www.openssh.com/) est l'implémentation la plus couramment utilisée du protocole SSH.

Développé dans le cadre du Projet [OpenBSD](https://www.openbsd.org/), **OpenSSH** propose un serveur et un client SSH en ligne de commande en [logiciel libre](https://www.fsf.org/fr/quest-ce-que-le-logiciel-libre).

Cette quête aborde l'installation et la configuration de base d'un serveur **OpenSSH**.

![Logo OpenSSH](https://img.linuxfr.org/img/687474703a2f2f7777772e6f70656e7373682e636f6d2f696d616765732f6f70656e7373682e676966/openssh.gif)

## 🤓 Objectifs:

✅ Savoir installer le serveur OpenSSH  
✅ Comprendre les principales options de configuration

## Sommaire

- [👉 SSH et OpenSSH](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#-ssh-et-openssh)
- [🔬 Installation](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#-installation)
- [🔬 Configuration](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#-configuration)
	- [Port d'écoute](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#port-d%C3%A9coute)
		- [Versions du protocole IP](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#versions-du-protocole-ip)
		- [Choix des interfaces d'écoute](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#choix-des-interfaces-d%C3%A9coute)
		- [Interdire ou autoriser des utilisateurs](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#interdire-ou-autoriser-des-utilisateurs)
		- [Authentification par mots de passe](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#authentification-par-mots-de-passe)
		- [Authentification par clés cryptographiques](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#authentification-par-cl%C3%A9s-cryptographiques)
		- [Authentification multi-facteurs](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#authentification-multi-facteurs)
- [Poursuivre la découverte](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#poursuivre-la-d%C3%A9couverte)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2367/pages/10080#-crit%C3%A8res-dacceptation)

## 👉 SSH et OpenSSH

**SSH** pour *Secure SHell* est un protocole réseau applicatif créé en 1995 par [Tatu Ylonen](https://ylonen.org/).

La version 2, sortie en 2006 est la seule recommandée actuellement.

**SSH** est défini comme standard IETF, principalement dans les RFC [4251](https://www.rfc-editor.org/rfc/rfc4251), [4252](https://www.rfc-editor.org/rfc/rfc4252), [4253](https://www.rfc-editor.org/rfc/rfc4253) et [4254](https://www.rfc-editor.org/rfc/rfc4254).

C'est un protocole Client Serveur qui communique via **TCP** et le port standard est **22**.

**SSH** permet, comme son nom l'indique, l'ouverture d'un terminal à distance, mais pas uniquement, il permet aussi:

- Le transfert de fichiers (on parle alors de **sftp**)
- La création de différentes formes de tunnels qui lui permettent d'encapsuler d'autres protocoles. Par exemple, le *X11 forwarding* qui permet l'ouverture de sessions graphiques à distance sur un serveur type Unix.
```shell
Secure Shell sur WikiepdiA
Plus d'information sur le protocole SSH sur la page WikipediA.https://fr.wikipedia.org/wiki/Secure_Shell
```

Il existe plusieurs implémentations du protocole, mais [OpenSSH](https://www.openssh.com/) est certainement la plus couramment utilisée.

Elle propose un client ssh en ligne de commande: `ssh` et un serveur: `sshd` mais aussi plusieurs autres commandes connexes telles que, entre autres:

- `ssh-keygen`: pour la génération de clés cryptographiques pour les différents cryptosystèmes pris en charge par ssh.
- `sftp`: un client CLI pour le transfert de fichiers interactifs similaire, dans sa syntaxe, à `ftp`.
- `ssh-copy-id`: outil pour copier ses clés publiques sur un serveur en utilisant une connexion ssh.

## 🔬 Installation

**OpenSSH** est disponible sur les systèmes type Unix et depuis quelques années sous Windows.

Pour commencer à appréhender ce service essentiel, installe le serveur sur l'environnement de ton choix.  
Ce serveur peut évidemment être une machine virtuelle dédiée à cet usage, pour éviter de bousculer ton environnement de travail habituel.  
Mieux encore, installe un serveur OpenSSH sur un serveur GNU/Linux **et** sur un serveur Windows en suivant les instructions ci dessous.

```shell
LinuxWindowsOpenSSH est en général présent dans les dépôts des principales distributions GNU/Linux.
L'installation passe donc par l'outil d'installation de paquets habituel de la distribution.
Sous les systèmes dérivés de Debian (Ubuntu, Mint, Kali...), on utilise apt.
On peut ainsi installer le serveur OpenSSH avec la commande : apt install openssh-server.

Il est aussi possible d'installer le serveur et le client en même temps avec apt install ssh.
Page SSH sur le Wiki Debian
Introduction à l'utilisation de ssh sous Debianhttps://wiki.debian.org/fr/SSH
```

Une fois l'installation effectuée, il est possible de se connecter au serveur avec un client ssh local ou distant.

Par exemple avec le client OpenSSH en ligne de commande:

```shell
wilder@hostname:~$ ssh <username>@<ssh-hostname>
```

avec:

- **<username>**: le nom du compte avec lequel on souhaite se connecter sur le serveur.
- **<ssh-hostname>**: le nom d'hôte ou l'adresse IP du serveur.

Le **<username>** peut être omis, dans ce cas `ssh` utilise le nom d'utilisateur local (*wilder* dans notre cas).

Des clients à interface graphique existent, notamment sous Windows. Le plus courant d'entre eux est sans doute [PuTTY](https://putty.org/)

---

## 🔬 Configuration

La configuration du serveur OpenSSH se trouve dans un (des) fichier(s) texte(s) de configuration dont l'emplacement diffère en fonction du système d'exploitation.

```shell
LinuxWindowsLe principal fichier de configuration du serveur OpenSSH est (en général) /etc/ssh/sshd_config.

Il peut être complété d'un répertoire /etc/ssh/sshd_config.d dans lequel il est possible d'ajouter des fichiers de configurations supplémentaires, à condition que leur nom, au choix, se termine par .conf.
Ce mécanisme de dossier de configuration en .d est assez classique sous GNU/Linux.

Il permet de conserver le fichier de configuration d'origine et par exemple de pouvoir le remplacer, le cas échéant, lors des mises à jour sans que cela remplace la configuration spécifique à cette machine.
On peut d'ailleurs constater ce mécanisme en examinant le fichier /etc/ssh/sshd_config pour voir que sa première directive est ainsi :
Include /etc/ssh/sshd_config.d/*.conf\`

Ces fichiers sont parcouru par le serveur OpenSSH au démarrage. Ainsi chaque modification de configuration nécessite un redémarrage du serveur pour être prise en compte.
Sur un sytème avec systemd (cas classique), ce redémarrage s'effectue avec la commande systemctl reload-or-restart sshd.service
```

Ces fichiers sont constitués d'options de configuration, une par ligne, ainsi que de commentaires qui en facilitent la lecture. Les commentaires sont les lignes qui commencent par `#`.  
Ces lignes commençant par `#` ne sont donc pas prises en compte dans la configuration.  
Chaque option de configuration prend la forme suivante:

```shell
1
<Directive> <valeur>
```
```shell
Astuce
Avant de redémarrer sshd pour prendre en compte des changements dans la configuration, il peut être utile de s'assurer que les fichiers de configuration ne comportent pas d'erreurs qui pourraient empêcher le redémarrage du service.
C'est l'objectif de l'option -t qui permet d'affiche les erreurs dans les fichiers de configuration.

Ainsi une exécution de sshd -t qui n'affiche rien permet de s'assurer qu'il n'y a pas d'erreur de syntaxe dans une nouvelle configuration.
```

Détaillons maintenant quelques unes de ces options:

## Port d'écoute

Le serveur OpenSSH peut être en écoute sur un port TCP au choix.

```shell
1
# Choix du port TCP sur lequel le serveur écoute - 22 par défaut
2
Port 22
```
```shell
Les attaques de bots

Sur un serveur OpenSSH en écoute sur Internet, il est assez courant de ne pas utiliser le port standard (22).

En effet, de nombreux programmes malveillants (bots) tentent continuellement des tentatives de connexion avec des couples identifiant/mots de passe courants dans l'espoir de récupérer un accès valide au serveur. En changeant de port d'écoute, on évite la plupart de ces tentatives ce qui permet d'alleger les journaux de connexion.
```
```shell
Que sont les bots ? Définition et explication
Dans cet article, l'éditeur d'antivirus Kaspersky propose une définition de bot en tentant notamment une catégorisation des bots malveillants.https://www.kaspersky.fr/resource-center/definitions/what-are-bots
```
```shell
Credential stuffing (attaque informatique)
Ce court article de la CNIL explique le scénario d'attaque type Credential Stuffing (bourrage d'identifiants).https://www.cnil.fr/fr/definition/credential-stuffing-attaque-informatique
```

## Versions du protocole IP

OpenSSH fonctionne avec IP version 4 et 6.

```shell
1
# Choix de la version d'IP - Par défaut IP v4 et v6 : any
2
AddressFamily any
3
# IPv4 seulement
4
# AddressFamily inet
5
# IPv6 seulement
6
# AddressFamily inet6
```

## Choix des interfaces d'écoute

OpenSSH permet de spécifier les adresses IP (et donc les interfaces réseaux) d'écoute.

Lorsqu'on souhaite écouter sur toutes les interfaces, on utilise les adresses IP indéfinies (qui ne sont composées que de 0 de zéros) soit:

- en IPv4: `0.0.0.0`
- en IPv6: `::`
```shell
1
# Écoute sur toutes les interfaces IPv4
2
ListenAddress 0.0.0.0
3
# Écoute sur toutes les interfaces IPv6
4
ListenAddress ::
```

Cette option de configuration est utile, par exemple pour des serveurs qui sont connectés à un réseau d’administration spécifique et donc pour lesquels l'accès SSH est ainsi restreint à ce réseau uniquement.

## Interdire ou autoriser des utilisateurs

OpenSSH s'appuie sur les utilisateurs du système d'exploitation.  
Par défaut, l'ensemble des utilisateurs du système peut se connecter au serveur mais il est possible de choisir précisément ceux qui peuvent se connecter et ceux qui ne le peuvent pas.

2 stratégies différentes existent pour atteindre cet objectif:

- **Une liste d'interdiction**: permet de préciser les utilisateurs qui **n** 'ont **pas** le droit de se connecter, les autres étant donc **implicitement autorisés**.
- **Une liste d'autorisation**: permet de préciser les utilisateurs qui ont le droit de se connecter, les autres étant donc **implicitement interdits**.

Pour préciser la liste d'utilisateurs n'ayant pas le droit de se connecter:

```shell
1
# Liste d'utilisateurs ne pouvant pas se connecter
2
DenyUsers wilder3 wilder4
```

Pour préciser la liste d'utilisateurs autorisés à se connecter:

```shell
1
# Liste d'utilisateurs pouvant se connecter
2
AllowUsers wilder1 wilder2
```

Dans le cas ou les 2 listes sont utilisées simultanément OpenSSH applique d'abord **DenyUsers** puis **AllowUsers**.

```shell
L'utilisateur root est géré spécifiquement par l'option PermitRootLogin
```

## Authentification par mots de passe

OpenSSH permet aux utilisateurs du système autorisés de se connecter à distance en précisant leur identifiant et leur mot de passe.

Cette authentification par mot de passe peut-être désactivée.

```shell
1
# Authentification par mots de passe - valeur par défaut yes
2
PasswordAuthentication no
```
```shell
Attention !

Soit sûr qu'une autre stratégie d'authentification te permet de te connecter avant de changer cette option, sans quoi tu ne pourra plus te connecter au serveur du tout.
```

## Authentification par clés cryptographiques

En plus des mots de passe, SSH permet une authentification à l'aide d'une paire de clés cryptographiques asymétriques.

```shell
1
# Authentification par clés - valeur par défaut yes
2
PubkeyAuthentication yes
```

Cette authentification suppose qu'une paire de clé asymétrique d'authentification existe sur le client (rsa, ecdsa ou ed25519) et que la clé publique à été copiée sur le serveur.

La génération de clé peut-être effectuée avec `ssh-keygen`

La copie peut se faire via ssh avec `ssh-copy-id` (sauf sur les serveurs OpenSSH sous Windows)

```shell
Key-based authentication in OpenSSH for Windows
Plus d'informations sur sur l'authentification par clés avec OpenSSH sous Windows.https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement
```

## Authentification multi-facteurs

SSH peut imposer l'utilisation de plusieurs moyens d'authentification successifs.

Par exemple, pour imposer une authentification par clé suivi de la fourniture du mot de passe, on peut utiliser la configuration suivante:

```shell
1
# Authentification par clés puis par mot de passe
2
AuthenticationMethods publickey,password
```

## Poursuivre la découverte

```shell
LinuxWindowsComprendre et maîtriser SSH
Le cours ssh sur it-connect.frhttps://www.it-connect.fr/cours/comprendre-et-maitriser-ssh/
```

---

## ☝️ Résumé

OpenSSH est l'implémentation de référence du protocole SSH.

La partie serveur peut-être installée sous GNU/Linux mais aussi sous Windows et dispose de nombreuses options de configuration qui permettent notamment d'en améliorer encore la sécurité.

---

## 📝 Quiz

```shell
# 1  - OpenSSH est un protocole IETFest originaire du projet OpenBSDest un serveur uniquement. Pour s'y connecter il faut un client tel que PuTTY.est une implémentation du protocole SSHValider# 2 qui est transporté soit par TCP soit par UDPcréé originellement par Tatu YlonenDe couche applicative (7 au sens OSI)originaire de chez MicrosoftValider# 3 transfert de fichiersutilisation anonyme d'un serveurla création de tunnel sécuriséouverture d'un shell à distanceValider# 4 via des fichiers textes de configurationavec un programme spécifiqueà l'aide de clés dans la base de registreValiderTon score :0 / 4
```

---

## 💪 Challenge

Fourni un fichier de configuration valide pour un serveur OpenSSH permettant la configuration suivante:

- Le serveur écoute sur le port TCP 222 en IPv6 uniquement
- Seul l'utilisateur ayant le nom de login `wilder` peut se connecter
- La connexion par mot de passe est impossible. Une clé est nécessaire.

## 🧐 Critères d'acceptation

La configuration proposée est valide (elle ne renvoi pas d'erreur à l'appel de `sshd -tf <chemin du fichier>`) et elle permet bien d'atteindre les objectifs imposés.

Solution postée le **samedi 08 novembre 2025**

```shell
# ===== OpenSSH server config - Challenge =====
# Écoute en IPv6 uniquement
AddressFamily inet6

# Port TCP 222 uniquement
Port 222
# Lier sur toutes les interfaces IPv6
ListenAddress ::

# Seul l'utilisateur 'wilder' peut se connecter
AllowUsers wilder

# Authentification : clé obligatoire, aucun mot de passe
PubkeyAuthentication yes
PasswordAuthentication no
```