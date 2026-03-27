---
title: "Installation d'un serveur Glpi - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2129/pages/10836"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Gestion d'un service informatique

## Installation d'un serveur Glpi

Moyen

3h

Auto-validation

Gestion d'un service informatique

## Installation d'un serveur Glpi

Il te seras utile de faire ces quêtes avant de commencer celle-ci.

```shell
VirtualBox : La gestion des interfaces réseaux30minsVoir la quête - VirtualBox : La gestion des interfaces réseauxDHCP avec Linux Debian2hVoir la quête - DHCP avec Linux Debian
```

## Introduction

Glpi est un logiciel d’inventaire et de ticketingOpen Source, que l'on peut installer indifféremment sur Linux ou Windows.  
Compte tenu du coût de licence d'exploitation d'un système Windows, il est assez courant de l'installer sur un Linux. Néanmoins, cela peut être un choix d’entreprise ou un choix personnel contraint du fait d’une absence de compétences sur les environnements Linux.  
Dans cette quête, nous allons installer un Glpi 10.0.2 sur une distribution Ubuntu.

Pour cette quête tu auras besoin:

- D'un hyperviseur, comme Virtualbox
	- Réfère toi aux quêtes sur VirtalBox pour télécharger, installer et configurer ta VM
- D'une fichier image ISO d'ubuntu server
	- Cette quête a été réalisée avec **Ubuntu Server 22.04**.
- D'un accès à internet pour les mise-à-jour et téléchargements nécessaires.
- D'une deuxième VM déjà prête en Windows ou Linux pour la fin de cette installation.

![glpi](https://www.linuxtricks.fr/upload/logo-glpi.png)

## 🤓 Objectifs:

✅ Installer une distribution Ubuntu server  
✅ Installer une base de données et créer un compte avec des droits élevés  
✅ Mettre en place l'appliance Glpi et la configurer  
✅ Sécuriser les accès

## 👀 Contenu de la quête:

- [👉 Préparation de la VM](https://odyssey.wildcodeschool.com/quests/2129/pages/10836#-pr%C3%A9paration-de-la-vm)
- [👉 Installation d'Ubuntu Server](https://odyssey.wildcodeschool.com/quests/2129/pages/10836#-installation-dubuntu-server)
- [👉 Configuration](https://odyssey.wildcodeschool.com/quests/2129/pages/10836#-configuration)
	- - [Installation des pré-requis](https://odyssey.wildcodeschool.com/quests/2129/pages/10836#installation-des-pr%C3%A9-requis)
				- [Configuration de MariaDB](https://odyssey.wildcodeschool.com/quests/2129/pages/10836#configuration-de-mariadb)
				- [Récupération des sources Glpi](https://odyssey.wildcodeschool.com/quests/2129/pages/10836#r%C3%A9cup%C3%A9ration-des-sources-glpi)
				- [Configuration du site](https://odyssey.wildcodeschool.com/quests/2129/pages/10836#configuration-du-site)
				- [Configuration de PHP](https://odyssey.wildcodeschool.com/quests/2129/pages/10836#configuration-de-php)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2129/pages/10836#challenge)
- [👉 Installation de Glpi](https://odyssey.wildcodeschool.com/quests/2129/pages/10836#-installation-de-glpi)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2129/pages/10836#-crit%C3%A8res-dacceptation)

## 👉 Préparation de la VM

- Tu peux aller [ici](https://ubuntu.com/download/server) pour télécharger une image ISO d'Ubuntu Server
- Avec l'hyperviseur de ton choix (comme Virtualbox), prépare une VM selon les caractéristiques suivantes:
	- Au minimum 2 Go de RAM
		- Au minimum 20 Go de disque dur
		- Mets ta carte réseau en mode "bridge", de cette manière ta VM pourras communiquer avec l'ensemble de ton réseau et de ta box internet
		- Insère l'image ISO d'Ubuntu Server

## 👉 Installation d'Ubuntu Server

Dans les menus, le déplacement se fait avec les flèches du clavier et la touche tabulation, et la sélection avec la touche espace ou entrée.  
Démarre ta VM et suis les instructions suivantes:

- A l'option de **GNU GRUB** choisir `Try or Install`
- Choisir la langue `Français`
- A la fenêtre **Mise à jour du programme d'installation**, choisir `Continuer sans mettre à jour`
- A la **configuration clavier**, choisir `French` pour les 2 choix
- Au choix du **type d'installation**, choisir `Ubuntu Server` (pas ***minimized***)
- A la **connection réseau**, attendre que la configuration réseau se fasse (adresse IP, masque) et cliquer sur `Terminer`
- A la **configuration du proxy**, ne rien mettre et cliquer sur `Terminer`
- A la **configuration du miroir d'archives**, laisser par défaut et cliquer sur `Terminer`
- A la **configuration de stockage**, choisir `Utiliser un disque entier` et cliquer 2 fois sur `Terminé`
- Au message de **confirmation de l'action**, choisir `Continuer`
- A la **configuration du profil**:
	- Mettre un nom
		- Mettre `glpi-server` comme nom de machine
		- Mettre `wilder` comme nom d'utilisateur
		- Choisir un mot de passe (l'écrire 2 fois) et cliquer sur `Terminé`
```shell
Attention car pour le mot de passe, ton clavier sera en QWERTY !
```
- A la **configuration SSH**, ne pas cocher la case et cliquer sur `Terminé`
- Dans la **fenêtre des options**, ne rien cocher et aller sur `Terminé`

L'installation va alors commencer.

- Attendre quelques minutes que tout s'installe
- Une fois l'installation terminée, choisir `Redémarrer maintenant`, enlever l'ISO de la VM, et appuyer sur la touche `Entrée`
- Se connecter avec le compte `wilder` et le mot de passe associé (en clavier AZERTY cette fois-ci)
- Vérifier que la configuration réseau est correcte avec la commande `ip a`.

> Si la configuration est correcte, fais un snapshot de ta VM à partir de l'hyperviseur.

```shell
Difference entre Ubuntu Desktop et Ubuntu Server (Eng)https://linuxhint.com/ubuntu-desktop-ubuntu-server-difference/
```

## 👉 Configuration

### Installation des pré-requis

Faisons une mise-à-jour:

```shell
1
sudo apt-get update && sudo apt-get upgrade
```

Installation d'Apache:

```shell
1
sudo apt-get install apache2 -y
```

Activation d'Apache au démarrage de la machine:

```shell
sudo systemctl enable apache2
```

Installation de la base de donnée. Ici nous installons **MariaDB**:

```shell
1
sudo apt-get install mariadb-server -y
```

Installation des modules annexes:

```shell
1
sudo apt-get install php8.1 libapache2-mod-php -y
2

3
sudo apt-get install php-{ldap,imap,apcu,xmlrpc,curl,common,gd,json,mbstring,mysql,xml,intl,zip,bz2}
```

### Configuration de MariaDB

```shell
Qu'est-ce que MariaDB ?https://fr.wikipedia.org/wiki/MariaDB
```

La commande ci-dessous va lancer le processus d'initialisation de la base de données:

```shell
1
sudo mysql_secure_installation
```

Répondre `Y` à toutes les questions qui seront posées pendant l'initialisation.

Suite à la question `Change the root password?` il faudra entrer le mot de passe de la base de données.

```shell
Attention : retiens bien ce mot de passe car il te sera demandé plus tard dans l'installation
```

Connection à la base de données:

```shell
1
mysql -u root -p
```
```shell
Suite à cette commande, tu vas devoir rentrer le mot de passe root.

Si tu es sur Ubuntu, il n'y en a pas de configuré, dans ce cas, ne rentre rien et valide avec la touche entrée.
```

On va configurer ceci:

- Un nom de base de données: `glpidb`
- un compte avec des droits d'accès élevé: `glpi` (il faudra choisir un mot de passe)

Cela va se faire avec les commandes ci-dessous:

```shell
1
CREATE DATABASE glpidb CHARACTER SET utf8 COLLATE utf8_bin;
2
grant all privileges on glpidb.* to glpi@localhost identified by 'motDePasse';
3
flush privileges;
4
quit
```

### Récupération des sources Glpi

On récupère la source:

```shell
1
wget https://github.com/glpi-project/glpi/releases/download/10.0.10/glpi-10.0.10.tgz
```

On va mettre le contenu téléchargé dans un autre emplacement:

```shell
Nom de domaine glpiSi on veut lier ce serveur Glpi à un domaine, il faut mettre le nom du domaine dans les commandes ci-dessous.

Sinon, on peut créer un nouveau domaine.
```
```shell
sudo mkdir /var/www/glpi.monNomDeDomaine
sudo tar -xzvf glpi-10.0.10.tgz
sudo cp -R glpi/* /var/www/glpi.monNomDeDomaine/
```

On va modifier les droits:

```shell
sudo chown -R www-data:www-data /var/www/glpi.monNomDeDomaine/
sudo chmod -R 775 /var/www/glpi.monNomDeDomaine/
```

### Configuration du site

```shell
sudo  nano /etc/apache2/sites-available/000-default.conf
```

on va modifier le "documentroot" du site:  
DocumentRoot /var/www/glpi

### Configuration de PHP

On va tout d'abord éditer le fichier `php.ini` qui est sous `/etc/php/8.2/apache2/`  
Ensuite on va modifier les paramètres suivants:

- memory\_limit = `64M`
- file\_uploads = `on`
- max\_execution\_time = `600`
- session.auto\_start = `0`
- session.use\_trans\_sid = `0`

Fermer le fichier et redémarrer la machine.

---

## 💪Challenge

L'installation de Glpi va commencer à partir de maintenant.  
Si tu ne l'a pas fait régulièrement, fais un snapshot de ta machine.

## 👉 Installation de Glpi

On va faire l'installation à partir d'un navigateur web, donc à partir d'une autre machine.  
Il va falloir configurer la carte réseau de ta VM, mettre une adresse IP fixe, et que tu ais une autre VM dans le même réseau que celle-ci.

- **Configuration réseau de la VM Glpi**:  
	Tout d'abord, arrête ta VM.  
	Dans ton hyperviseur va modifier la carte réseau pour qu'elle ne soit plus en bridge mais en `réseau interne`.  
	Redémarre ta VM.
- **Mettre une adresse IP fixe**:  
	Choisi une adresse IP avec le masque associé et mets-là dans la configuration de ta machine.
- **Démarre ton autre VM (client Windows ou Linux)**  
	Ping ta VM Ubuntu server pour vérifier que la configuration réseau est bonne.

Si tout est correct,ouvre un navigateur web et entre l'adresse `http://adresse IP du serveur glpi/glpi`  
Dans les fenêtres graphique de configuration:

- Mettre `Français` en langue
- Accepter la licence GPL en cochant la case `J'ai lu et accepté...`
- Cliquer sur `installer`
- Si tout est ok sur la fenêtre cliquer sur `continuer`
- Configuration de la base de données MariaDB:
	- serveur SQL: `127.0.0.1`
		- utilisateur: `glpi`
		- Mot de passe: `Mot de passe défini pendant la configuration de la base de données pour le compte glpi`

## 🧐 Critères d'acceptation

Tu dois avoir un serveur Glpi fonctionnel que tu peux atteindre en web avec une autre machine.

Quête terminée le **mardi 06 janvier 2026**