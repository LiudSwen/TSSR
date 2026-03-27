---
title: "La ToIP avec Asterisk - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2471/pages/11704"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
VoIP

## La ToIP avec Asterisk

Installation et configuration d'Asterisk

Moyen

1h

3 pairs

VoIP

## La ToIP avec Asterisk

## Introduction

**Asterisk** est un autocommutateur téléphonique privé qui peut être utilisé sous 2 licences, la première est la [GPLv2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html) et la seconde est une [licence commerciale](https://www.asterisk.org/products/software/licensing/).  
Il est fourni par la société **Sangoma** et s'installe sur des systèmes GNU/Linux. Sangoma fournit également **FreePBX** qui permet de gérer Asterisk via une interface web.  
Dans cette quête tu vas installer Asterisk à partir d'une source que tu compileras toi-même et tu vas réaliser une première configuration.

![logo-asterisk](https://upload.wikimedia.org/wikipedia/fr/7/7f/Asterisk_logo4.png)

## 📚 Pré-requis

Avant de commencer cette quête, assure-toi d'avoir déjà terminé la quête suivante:

```shell
La Téléphonie sur IP ou ToIPLes notions de base30minsVoir la quête - La Téléphonie sur IP ou ToIP
```

## 🤓 Objectifs:

✅ Compiler et construire une image d'installation personnalisée d'Asterisk  
✅ Installer l'appliance Asterisk  
✅ Configurer Asterisk

## Sommaire

- [📌 L'autocommutateur téléphonique sur IP ou IPBX (rappel)](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#-lautocommutateur-t%C3%A9l%C3%A9phonique-sur-ip-ou-ipbx-rappel)
- [📞 Plus d'info sur Asterisk](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#-plus-dinfo-sur-asterisk)
- [👉 Mise en œuvre de l'installation d'Asterisk](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#-mise-en-%C5%93uvre-de-linstallation-dasterisk)
	- [🔧 Prérequis](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#-pr%C3%A9requis)
		- [🔬 Téléchargement des sources et installation des dépendances](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#-t%C3%A9l%C3%A9chargement-des-sources-et-installation-des-d%C3%A9pendances)
		- [⚙️ Compilation à partir des sources](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#%EF%B8%8F-compilation-%C3%A0-partir-des-sources)
		- [🔬 Installation](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#-installation)
- [👉 Gestion des droits d'accès](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#-gestion-des-droits-dacc%C3%A8s)
- [👉 Les fichiers importants pour l'administration](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#-les-fichiers-importants-pour-ladministration)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2471/pages/11704#-crit%C3%A8res-dacceptation)

## 📌 L'autocommutateur téléphonique sur IP ou IPBX (rappel)

Un autocommutateur téléphonique privé, ou **IPBX** (*Private Branch Exchange*) est un système de téléphonie centralisée d'entreprise qui permet de gérer les appels internes et externes. Concrètement, c'est un équipement qui permet de connecter les différents téléphones d'une entreprise entre-eux et de gérer les appels entrants ou sortants.  
Un IPBX est connecté à un réseau IP sur lequel on va faire de la ToIP (*Telephony over IP*). Il utilise des protocoles réseaux tels que le **SIP** (*Session Initiation Protocol*) pour initialiser la connection des sessions ou le **RTP** ( (*Real-time Transport Protocol*) pour transporter l'information.  
Il permet également de mettre en place des fonctionnalités avancées telles que la messagerie vocale, la conférence téléphonique, la numérotation abrégée, etc.

## 📞 Plus d'info sur Asterisk

**Asterisk** est une plateforme de communication open source, avec 2 licences d'utilisation, dont la licence GPL (*GNU General Public License*). Il permet de créer un système de communication téléphonique complet basé sur de la VoIP et la ToIP.

C'est un logiciel serveur qui fournit des fonctionnalités PBX (*Private Branch Exchange*) comme la numérotation des extensions, les transferts d'appels, la messagerie vocale, le routage des appels, les files d'attente, la musique d'attente, etc. Il supporte également de nombreux protocoles de communication et de codecs audio, ce qui permet une grande flexibilité.

Asterisk utilise des protocoles tels que:

- **SIP** (*Session Initiation Protocol*): protocole de signalisation pour la communication VoIP. SIP est utilisé pour établir, modifier et terminer les sessions de communication VoIP.
- **IAX** (*Inter-Asterisk eXchange*): protocole de signalisation spécifique à Asterisk, utilisé pour établir, modifier et terminer les sessions de communication VoIP. IAX est un protocole qui peut fournir une meilleure qualité audio et une utilisation de bande passante plus efficace que SIP.
- **RTP** (*Real-time Transport Protocol*): protocole de transport utilisé pour la transmission de données audio et vidéo en temps réel. RTP est souvent utilisé avec des protocoles de signalisation tels que SIP et IAX.
- **SRTP** (*Secure Real-time Transport Protocol*): C'est une extension de RTP qui fournit une sécurité pour les flux de média en temps réel en utilisant le chiffrement. Comme RTP, il est souvent utilisé avec SIP et IAX pour sécuriser les communications VoIP.
- **RTCP** (*Real-time Transport Control Protocol*): protocole de contrôle utilisé avec RTP pour fournir des informations de contrôle et de statistiques sur les flux de médias en temps réel.

Asterisk est ainsi un produit très complet, c'est pourquoi il est utilisé dans les entreprises de toutes tailles en tant qu'appliance pour fournir des communications téléphoniques internes et externes, dans les centres d'appels, et les fournisseurs VoIP.

## 👉 Mise en œuvre de l'installation d'Asterisk

## 🔧 Prérequis

Tu as besoin d'une machine physique ou virtuelle avec une distribution `Linux Ubuntu 22.04 LTS`.

```shell
Les expérimentations pratiques ont été testées sur une distribution Linux Ubuntu 22.04 LTS installée dans une machine virtuelle VirtualBox 7 tournant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites avec d'autres distributions Linux, sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## 🔬 Téléchargement des sources et installation des dépendances

```shell
Il est possible d'installer Asterisk par les paquets apt mais dans ce cas, il est peu probable que tu ais la dernière version.

Pour connaître la dernière version contenue dans les paquets, utilise la commande apt policy asterisk.
```

Démarre ton système et fais les mise-à-jour de dépôts (`apt update`).  
Installe les bibliothèques nécessaires pour la compilation d'une installation personnalisée d'Asterisk:

```bash
1
sudo add-apt-repository universe
2
sudo apt -y install git curl wget libnewt-dev libssl-dev libncurses5-dev subversion libsqlite3-dev build-essential libjansson-dev libxml2-dev  uuid-dev
```

Va sur le site officiel d'Asterisk, télécharge la dernière version, et décompresse le fichier pour avoir le dossier d'installation.

```shell
Site officiel d'AsteriskTéléchargement de la dernière versionhttps://www.asterisk.org/
```

Une fois le dossier décompressé, place-toi dedans et télécharge les bibliothèques de codecs en exécutant le script `get_mp3_source.sh` qui est sous `/contrib/scripts`.

Vérifie que toutes les dépendances sont résolues et qu'il n'y a pas d'erreur avec la commande `contrib/scripts/install_prereq install`.

Si tout est bon, tu as cet affichage:

```shell
#############################################
## install completed successfully
#############################################
```

## ⚙️ Compilation à partir des sources

Toujours à la racine du dossier téléchargé, lance la commande `./configure`.

```shell
La commande ./configure va vérifier que toutes les dépendances nécessaires sont bien présentes. Si c'est le cas, un fichier makefile va être crée, sinon, s'il manque des dépendances, il faudra les installer.

Dans cette quête, les dépendances ont été installé au début, donc "normalement", tu n'as pas d'erreurs.
```

Si tout se passe bien, tu as cet affichage:

```shell
.$$$$$$$$$$$$$$$=..      
            .$7$7..          .7$$7:.    
          .$$:.                 ,$7.7   
        .$7.     7$$$$           .$$77  
     ..$$.       $$$$$            .$$$7 
    ..7$   .?.   $$$$$   .?.       7$$$.
   $.$.   .$$$7. $$$$7 .7$$$.      .$$$.
 .777.   .$$$$$$77$$$77$$$$$7.      $$$,
 $$$~      .7$$$$$$$$$$$$$7.       .$$$.
.$$7          .7$$$$$$$7:          ?$$$.
$$$          ?7$$$$$$$$$$I        .$$$7 
$$$       .7$$$$$$$$$$$$$$$$      :$$$. 
$$$       $$$$$$7$$$$$$$$$$$$    .$$$.  
$$$        $$$   7$$$7  .$$$    .$$$.   
$$$$             $$$$7         .$$$.    
7$$$7            7$$$$        7$$$      
 $$$$$                        $$$       
  $$$$7.                       $$  (TM)     
   $$$$$$$.           .7$$$$$$  $$      
     $$$$$$$$$$$$7$$$$$$$$$.$$$$$$      
       $$$$$$$$$$$$$$$$.                

configure: Package configured for: 
configure: OS type  : linux-gnu
configure: Host CPU : x86_64
configure: build-cpu:vendor:os: x86_64 : pc : linux-gnu :
configure: host-cpu:vendor:os: x86_64 : pc : linux-gnu :
```

Pour ouvrir le menu de configuration, exécute la commande `make menuselect`.

```shell
La commande make menuselect va créer une interface graphique en mode texte. Elle te permet de configurer les options de compilation d'Asterisk.

En te déplaçant dans cette interface avec le clavier, tu peux sélectionner les modules et les fonctionnalités à inclure pour l'installation.

N’hésite pas à modifier les options qui te sont proposé pour faire des tests.
```

Voici les fonctionnalités à sélectionner:

- Dans le module **Add-ons**, sélectionne les 4 fonctionnalités:
	- `chan_mobile`
		- `chan_ooh323`
		- `format_mp3`
		- `res_config_mysql`
- Dans le module **Core Sound Packages**, sélectionne les 9 fonctionnalités en français `FR`, puis les mêmes mais en anglais `EN`.
- Dans le module **Music On Hold file Packages**, sélectionne les 4 premières fonctionnalités
- Dans le module **Extras Sound Packages**, sélectionne les 4 même fonctionnalités (que dans **Music On Hold file Packages**), mais en `EN` et `FR`.
```shell
La commande menuselectComment personnaliser l'installation.https://docs.asterisk.org/Getting-Started/Installing-Asterisk/Installing-Asterisk-From-Source/Using-Menuselect-to-Select-Asterisk-Options/
```

Quand tu as terminé, sélectionne `SAVE and EXIT` et lance ensuite la commande `make` dans le terminal.

```shell
Ici make va créer l'image d'installation compilée avec la configuration que tu as choisi.
```
```shell
La commande makeDes infos supplémentaire sur la commande make qui te permet de compiler et de construire une installation.https://www.malekal.com/comment-utiliser-commande-make-exemples/
```

Si tout s'est bien passé, tu devrais avoir cet affichage:

```shell
+--------- Asterisk Build Complete ---------+
 + Asterisk has successfully been built, and +
 + can be installed by running:              +
 +                                           +
 +                make install               +
 +-------------------------------------------+
```

## 🔬 Installation

Comme tu peux le voir à l'écran, lance la commande `sudo make install` pour démarrer l'installation.

Si tout s'est bien déroulé, tu devrais avoir cet affichage:

```shell
+---- Asterisk Installation Complete -------+
 +                                           +
 +    YOU MUST READ THE SECURITY DOCUMENT    +
 +                                           +
 + Asterisk has successfully been installed. +
 + If you would like to install the sample   +
 + configuration files (overwriting any      +
 + existing config files), run:              +
 +                                           +
 + For generic reference documentation:      +
 +    make samples                           +
 +                                           +
 + For a sample basic PBX:                   +
 +    make basic-pbx                         +
 +                                           +
 +                                           +
 +-----------------  or ---------------------+
 +                                           +
 + You can go ahead and install the asterisk +
 + program documentation now or later run:   +
 +                                           +
 +               make progdocs               +
 +                                           +
 + **Note** This requires that you have      +
 + doxygen installed on your local system    +
 +-------------------------------------------+
```

L'installation est terminée, et l'affichage te propose des commandes supplémentaires pour faciliter la mise en oeuvre.

```shell
Les commandes ci-dessous ne sont pas strictement nécessaires pour terminer l'installation à partir d'une source compilée, mais elles peuvent te servir à personnaliser la configuration et avoir des fichiers déjà configurés.

Pour cette quête, il est recommandé de les exécuter.
```
- `sudo make progdocs`: Pour générer la documentation qui sera dans le dossier `doc` directement dans le dossier des sources, celui que tu a décompressé.
- `sudo make samples`: Pour générer les fichiers de configuration par défaut (dans `/etc/asterisk`). Ces fichiers contiennent les paramètres de base pour la configuration des utilisateurs, des extensions, des groupes de sonnerie, des règles de numérotation, etc.
- `sudo make config`: Pour installer les fichiers de configuration dans les répertoires appropriés, en fonction du système. A utiliser après `make samples`.
- `sudo ldconfig`: Pour la mise-à-jour de la bibliothèque des liens dynamiques du système en ajoutant les bibliothèques partagées nécessaires à l'exécution d'Asterisk.
- `sudo make basic-pbx`: Pour compiler et installer le module `basic-pbx` qui est un ensemble de fonctionnalités de base. On y trouve la numérotation des extensions, les transferts d'appels, etc.

Cette dernière commande génère des fichiers de configuration:

```shell
Installing basic-pbx config files...
Installing file configs/basic-pbx/asterisk.conf
Installing file configs/basic-pbx/cdr.conf
Installing file configs/basic-pbx/cdr_custom.conf
Installing file configs/basic-pbx/confbridge.conf
Installing file configs/basic-pbx/extensions.conf
Installing file configs/basic-pbx/indications.conf
Installing file configs/basic-pbx/logger.conf
Installing file configs/basic-pbx/modules.conf
Installing file configs/basic-pbx/musiconhold.conf
Installing file configs/basic-pbx/pjsip.conf
Config file configs/basic-pbx/pjsip_notify.conf is unchanged
Installing file configs/basic-pbx/queues.conf
Installing file configs/basic-pbx/README
Installing file configs/basic-pbx/voicemail.conf
Updating asterisk.conf
```

## 👉 Gestion des droits d'accès

- Créer un groupe `asterisk`.
- Créer un utilisateur avec les paramètres suivants:
	- Nom: `asterisk`
		- Type d'utilisateur: système (avec l'option `-r`)
		- Dossier de travail: `/var/lib/asterisk`
		- Groupe principal: `asterisk`
- Pour permettre à Asterisk d'accéder aux périphériques audio et aux ports de communication, ajoute l'utilisateur `asterisk` aux groupes `audio` et `dialout`.
- Pour tous les fichiers et répertoires de la liste ci-dessous, change le propriétaire et le groupe à `asterisk`, et change les permissions pour que l'utilisateur `asterisk` ait accès en RWE (*Read*, *Write*, *Execute*) tandis que les autres utilisateurs ne peuvent y accéder qu'en RW:
	- `/etc/asterisk`
		- `/var/lib/asterisk`
		- `/var/log/asterisk`
		- `/var/spool/asterisk`
		- `/usr/lib/asterisk`
- Pour les fichiers et répertoires sous `/var/run/asterisk`, change les permissions pour que l'utilisateur `asterisk` ait accès en RWE (*Read*, *Write*, *Execute*) tandis que les autres utilisateurs ne peuvent y accéder qu'en RW.
```bash
Tu es bloqué et tu n'arrive pas à faire les droits demandé ? En dernier recours, tu peux cliquer ci-dessous pour avoir une solution possible.1
# création d'un groupe "asterisk"
2
sudo groupadd asterisk
3
# création d'un utilisateur "asterisk"
4
sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
5
# ajout de l'utilisateur "asterisk" aux groupes "audio" et "dialout"
6
sudo usermod -aG audio,dialout asterisk
7
# change le propriétaire et le groupe
8
sudo chown -R asterisk.asterisk /etc/asterisk
9
sudo chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
10
sudo chown -R asterisk.asterisk /usr/lib/asterisk
11
# change les permissions
12
sudo chmod -R 750 /var/{lib,log,run,spool}/asterisk /usr/lib/asterisk /etc/asterisk
13
Solution
```

## 👉 Les fichiers importants pour l'administration

Parmi les nombreux fichiers de configuration sous `/etc/asterisk/`, quelques-uns sont important:

- `sip.conf`: utilisé pour configurer les connexions SIP avec les fournisseurs de services VoIP et les téléphones SIP.
- `extensions.conf`: pour la configuration du **Dialplan** (définit les extensions, les numéros de téléphone, les fonctionnalités, etc.)
- `users.conf`: contient les utilisateurs et leurs paramètres tels que le nom, le numéro de téléphone, etc.
- `voicemail.conf`: définit les boîtes vocales et leurs paramètres tels que le numéro de téléphone, le mot de passe, le nombre de messages, etc.
- `features.conf`: définit les fonctionnalités supplémentaires comme le renvois d'appels, etc.

---

## ☝️ Résumé

**Asterisk** est un IPBX open source pour gérer de la ToIP.  
Il a de nombreuses fonctionnalités comme les transferts d'appels ou la gestion de la messagerie vocale.  
Le SIP et le RTP sont 2 protocoles utilisés par Asterisk.

---

## 📝 Quiz

```shell
# 1  - Qu'est-ce qu'Asterisk ?Un système de messagerie instantanéeUn système d'exploitationUn navigateur webUn logiciel de téléphonieValider# 2  -  Comment peut-on démarrer le serveur Asterisk ?En exécutant la commande systemctl start asterisk dans la console LinuxAvec l'interface web d'AsteriskEn exécutant la commande start asterisk dans la console LinuxValider# 3  -  Dans quel fichier le Dialplan va se configurer ?extensions.confusers.confsip.confvoicemail.confValider# 4  -  Quels protocoles de signalisation peut utiliser Asterisk pour communiquer avec les équipements de téléphonie ?SIPIAXLes 2ValiderTon score :0 / 4
```

---

## 💪Challenge

Installe Asterisk en suivant cette quête.  
Utilise les informations que tu trouveras dans le [wiki d'Ubuntu](https://doc.ubuntu-fr.org/asterisk#modifier_les_utilisateurs), et dans [la doc officielle](https://wiki.asterisk.org/wiki/display/AST/Home) pour créer l'utilisateur ci-dessous:

- Nom complet: `Stéphane Groot`
- Nom d'utilisateur: `sgroot`
- mot de passe utilisateur:`0000`
- Numéro de téléphone: `88012`
- A une messagerie vocale: `oui`
- Code secret messagerie vocale: `1234`
- Adresse de la messagerie vocale: `88012@ff`
- Envoi et réception d'appel: `oui`
- Service de l'utilisateur: `Finances`
- @IP: `dynamique`
- utilisateurs SIP: `oui`
- codecs: `tous désactivés`
- codecs ulaw: `activés`
- Contexte: `Marketing`
```shell
Dans Asterisk, un contexte est un ensemble de règles de traitement d'appels qui s'appliquent à un groupe spécifique d'appels entrants ou sortants. Chaque contexte contient un ensemble de règles de composition de numéros (Dialplan), qui définissent comment les appels doivent être traités et routés.
```

Envoie le contenu du (ou des) fichier(s) de configuration pour valider cette quête.

## 🧐 Critères d'acceptation

- L'installation d'Asterisk est fonctionnelle.
- Tu as envoyé le contenu du (ou des) fichier(s) de configuration necessaire pour créer l'utilisateur `Stéphane Groot`.

---

Contribuer à améliorer cette quête.Tous les retours sont précieux pour l'amélioration de nos formations.

Le contenu de la quête m'a permis de comprendre les concepts et d'atteindre les objectifs annoncés:

---

Un commentaire pour nous aider à mieux comprendre?