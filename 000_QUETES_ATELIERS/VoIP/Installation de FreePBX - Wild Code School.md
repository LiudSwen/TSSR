---
title: "Installation de FreePBX - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2790/pages/10087"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
VoIP

## Installation de FreePBX

Facile

1h

Auto-validation

VoIP

## Installation de FreePBX

## Introduction

**FreePBX** est une distribution pour serveur VoIP. Il contient une interface utilisateur graphique (GUI) web qui est utilisée pour configurer et gérer Asterisk. Il rend la gestion d'Asterisk plus facile pour ceux qui ne sont pas familiers avec la ligne de commande ou qui préfèrent une interface visuelle.  
Il fournit une interface pour configurer les fonctionnalités d'Asterisk, comme les extensions, les plans de numérotation, les routes d'appel, etc.  
C'est un outil qui contient et complète Asterisk en fournissant une interface facile à utiliser pour sa configuration et sa gestion.

Cette quête consiste à installer FreePBX.

![logo de freepbx](https://www.asterisk.org/wp-content/uploads/Sangoma_FreePBX_Logo_RGB_vert-pos-e1596552152261.png)

## 🤓 Objectifs:

✅ Installer FreePBX  
✅ Effectuer une configuration de base  
✅ Se connecter en ssh  
✅ Se connecter en web

## Sommaire

- [👉 Mise en œuvre](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#-mise-en-%C5%93uvre)
	- [✔️ Prérequis](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#%EF%B8%8F-pr%C3%A9requis)
		- [🔬 Installation](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#-installation)
		- [⚙️ Configuration sur la VM serveur](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#%EF%B8%8F-configuration-sur-la-vm-serveur)
		- [Modification de la langue du clavier](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#modification-de-la-langue-du-clavier)
				- [Création d'un utilisateur pour l’accès ssh](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#cr%C3%A9ation-dun-utilisateur-pour-lacc%C3%A8s-ssh)
		- [🔑 Connexion en SSH](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#-connexion-en-ssh)
		- [🧭 Connexion en web](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#-connexion-en-web)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2790/pages/10087#-crit%C3%A8res-dacceptation)

## 👉 Mise en œuvre

## ✔️ Prérequis

Tu a besoin de:

- Une VM 1 Go de RAM et 20 Go de disque dur sur laquelle installer FreePBX avec une carte réseau en mode `bridge`.
- L'image ISO de la dernière version que tu trouveras [ici](https://www.freepbx.org/downloads/)
```shell
Les expérimentations pratiques ont été testées sur une distribution FreePBX Distro 16 64 bits (2302-1) contenant FreePBX 16.0.40 installée dans une machine virtuelle VirtualBox 7 tournant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites avec d'autres versions de FreePBX, sur d'autres distributions Linux, et sur d'autres environnement, mais des différences peuvent alors apparaître.
```
```shell
Dans Virtualbox, le type de la VM doit être Linux Red Hat (64-bit) ou Linux Other Linux (64-bit).
```

## 🔬 Installation

Au démarrage de la VM, dans la liste, choisir la version **recommandée**.  
![image de choix de version](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-01.png?raw=true)

Puis sélectionner `Graphical Installation - Output to VGA`.  
![Choix de l'installation graphique](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-02.png?raw=true)

Enfin choisir `FreePBX Standard`  
![Choix de l'installation standard](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-03.png?raw=true)

Pendant l'installation, il faut configurer le mot de passe root (`Root password is not set` s'affiche).  
![Alerte du mot de passe root à changer](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-04.png?raw=true)

Clique sur `ROOT PASSWORD` et entre un mot de passe (robuste, est-il besoin de le préciser?) pour le compte root.

```shell
Le clavier est en anglais donc attention aux lettres des touches du clavier QWERTY !
```

![Alerte du mot de passe root à changer](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-05.png?raw=true)

Indication que le mot de passe root a été changé:  
![Indication que le mot de passe a été changé](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-06.png?raw=true)

L'installation continue et se termine.  
![Fin de l'installation](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-07.png?raw=true)

Éteindre la VM, enlever l'ISO du lecteur et redémarrer la VM.  
![prompt](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-08.png?raw=true)

## ⚙️ Configuration sur la VM serveur

Connecte toi en root.

### Modification de la langue du clavier

La commande `localectl` donne les informations suivantes:

```shell
System Locale: LANG=en_US.UTF-8
    VC Keymap: us
   X11 Layout: us
```

Vérifie avec la commande `localectl list-locales` que tu as bien `fr_FR.utf8` dans la liste qui s'affiche.

Ecrit les lignes de commandes suivantes pour mettre le clavier en français:

```shell
localectl set-locale LANG=fr_FR.utf8
localectl set-keymap fr
localectl set-x11-keymap fr
```

Vérifie avec la commande `localectl`:

```shell
System Locale: LANG=fr_FR.UTF-8
    VC Keymap: fr
   X11 Layout: fr
```

### Création d'un utilisateur pour l’accès ssh

Créer un utilisateur, ici ce sera **wilder**, avec la commande `adduser` et change son mot de passe avec `passwd`.  
Edite le fichier `/etc/ssh/sshd_config` et modifie le fichier pour qu'il contienne les lignes suivantes:

```shell
PermitRootLogin no
AllowUsers wilder
PasswordAuthentication yes
```

Redémarre le service avec `systemctl restart sshd`.

## 🔑 Connexion en SSH

A partir de ta machine cliente, connecte toi en ssh (ici l'adresse IP du serveur FreePBX est 192.168.1.153):

```bash
1
wilder@Ubuntu:~$ ssh sshuser@192.168.1.153
2
sshuser@192.168.1.153's password: 
3
PHP Warning:  include_once(/etc/freepbx.conf): failed to open stream: Permission denied in /var/lib/asterisk/bin/fwconsole on line 12
4
PHP Warning:  include_once(): Failed opening '/etc/freepbx.conf' for inclusion (include_path='.:/usr/share/pear:/usr/share/php') in /var/lib/asterisk/bin/fwconsole on line 12
5
PHP Fatal error:  Uncaught Error: Class 'Symfony\Component\Console\Application' not found in /var/www/html/admin/libraries/FWApplication.class.php:11
6
Stack trace:
7
#0 /var/lib/asterisk/bin/fwconsole(66): include()
8
#1 {main}
9
  thrown in /var/www/html/admin/libraries/FWApplication.class.php on line 11
10
[sshuser@freepbx ~]$
```

Ensuite tu peux passer en root:

```bash
1
[sshuser@freepbx ~]$ su -
2
Mot de passe : 
3
Dernière connexion : mercredi 18 juin 2023 à 17:09:20 UTC sur tty1
4
______                   ______ ______ __   __
5
|  ___|                  | ___ \| ___ \\ \ / /
6
| |_    _ __   ___   ___ | |_/ /| |_/ / \ V / 
7
|  _|  | '__| / _ \ / _ \|  __/ | ___ \ /   \ 
8
| |    | |   |  __/|  __/| |    | |_/ // /^\ \
9
\_|    |_|    \___| \___|\_|    \____/ \/   \/
10
                                              
11
                                              
12
NOTICE! You have 3 notifications! Please log into the UI to see them!
13
Current Network Configuration
14
+-----------+-------------------+---------------------------------------+
15
| Interface | MAC Address       | IP Addresses                          |
16
+-----------+-------------------+---------------------------------------+
17
| eth0      | 08:00:27:7D:BF:B9 | 192.168.1.153                         |
18
|           |                   | 2001:861:3140:3570:a00:27ff:fe7d:bfb9 |
19
|           |                   | fe80::a00:27ff:fe7d:bfb9              |
20
+-----------+-------------------+---------------------------------------+
21

22
Please note most tasks should be handled through the GUI.
23
You can access the GUI by typing one of the above IPs in to your web browser.
24
For support please visit: 
25
    http://www.freepbx.org/support-and-professional-services
26

27
+---------------------------------------------------------------------+
28
| This machine is not activated.  Activating your system ensures that |
29
| your machine is eligible for support and that it has the ability to |
30
| install Commercial Modules.                                         |
31
|                                                                     |
32
| If you already have a Deployment ID for this machine, simply run:   |
33
|                                                                     |
34
|    fwconsole sysadmin activate deploymentid                         |
35
|                                                                     |
36
| to assign that Deployment ID to this system. If this system is new, |
37
| please go to Activation (which is on the System Admin page in the   |
38
| Web UI) and create a new Deployment there.                          |
39
+---------------------------------------------------------------------+
40

41
[root@freepbx ~]#
```
```shell
Afin de sécuriser l'accès au serveur, l'authentification ssh par mot de passe ne doit être que temporaire.

Idéalement, il faut que cette connexion se fasse par partage de clé.

Pour rappel :

Création d'une paire de clés avec ssh-keygen
Copie de la clé publique sur le serveur avec ssh-copy-id

Une fois cela fait, il faut modifier le fichier /etc/ssh/sshd_config pour n'autoriser que l'authentification par clés.
```

## 🧭 Connexion en web

A partir de ton navigateur web, connecte-toi sur l'adresse du serveur et tu arriveras sur l'interface de gestion de FreePBX.  
![page demarrage web](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-09.png?raw=true)

## ☝️ Résumé

FreePBX est un IPBX Asterisk avec une interface graphique.  
La gestion se fait à partir d'un navigateur web.

## 📝 Quiz

```shell
# 1  - FreePBX est un fork d'AsteriskVraiFauxValider# 2 En ligne de commandeVia un navigateur webEn SSHLes 3 autres réponsesValider# 3 VraiFauxValider# 4 VraiFauxValiderTon score :0 / 4
```

## 💪Challenge

Install FreePBX.

## 🧐 Critères d'acceptation

L'installation est fonctionnelle et tu peux te connecter au serveur en SSH et en web.

Quête terminée le **mardi 17 février 2026**