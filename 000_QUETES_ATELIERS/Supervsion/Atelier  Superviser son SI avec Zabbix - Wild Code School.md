---
title: "Atelier : Superviser son SI avec Zabbix - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3573/pages/14981"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Supervision

## Atelier: Superviser son SI avec Zabbix

Facile

02mins

Auto-validation

Supervision

## Atelier: Superviser son SI avec Zabbix

## Introduction

Zabbix est une solution open-source de supervision qui va te permettre de surveiller les performances et la disponibilité des éléments de ton SI (serveurs, réseaux, VMs, services, clients).

Dans cet atelier, tu vas apprendre à installer, configurer et utiliser Zabbix pour superviser des services critiques.

![Logo Zabbix](https://upload.wikimedia.org/wikipedia/commons/b/bf/Zabbix_logo.png)

## 🎯 Objectifs

✅ Installer et configurer un serveur Zabbix.  
✅ Ajouter et superviser des hôtes.  
✅ Créer des alertes personnalisés.  
✅ Configurer des notifications.

## Sommaire

- [🔧 Prérequis](https://odyssey.wildcodeschool.com/quests/3573/pages/14981#-pr%C3%A9requis)
- [🔬 Étape 1 - Installation du serveur Zabbix](https://odyssey.wildcodeschool.com/quests/3573/pages/14981#-%C3%A9tape-1---installation-du-serveur-zabbix)
- [🔬 Étape 2 - Configuration de Zabbix](https://odyssey.wildcodeschool.com/quests/3573/pages/14981#-%C3%A9tape-2---configuration-de-zabbix)
- [🔬 Étape 3 - Configuration de Zabbix depuis la WUI](https://odyssey.wildcodeschool.com/quests/3573/pages/14981#-%C3%A9tape-3---configuration-de-zabbix-depuis-la-wui)
- [🔬 Étape 4 - Installation et configuration de l'Agent Zabbix](https://odyssey.wildcodeschool.com/quests/3573/pages/14981#-%C3%A9tape-4---installation-et-configuration-de-lagent-zabbix)
- [🔬 Étape 5 - Ajout d'un hôte et création d'un groupe](https://odyssey.wildcodeschool.com/quests/3573/pages/14981#-%C3%A9tape-5---ajout-dun-h%C3%B4te-et-cr%C3%A9ation-dun-groupe)
- [🔬 Étape 6 - Configuration des alertes et des notifications](https://odyssey.wildcodeschool.com/quests/3573/pages/14981#-%C3%A9tape-6---configuration-des-alertes-et-des-notifications)
- [📝 Résumé](https://odyssey.wildcodeschool.com/quests/3573/pages/14981#-r%C3%A9sum%C3%A9)
- [🏆 Challenge](https://odyssey.wildcodeschool.com/quests/3573/pages/14981#-challenge)
- [🔍 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/3573/pages/14981#-crit%C3%A8res-dacceptation)

## 🔧 Prérequis

Pour cet atelier, tu as besoin des éléments suivant:

- Un serveur avec une distribution Linux (Debian, Ubuntu, CentOS, etc).
- Un serveur web (Apache ou Nginx).
- Un SGBD ou DBMS (MariaDB/MySQL ou PostgreSQL).
- Un Windows 11 où installer l'agent Zabbix.
```bash
Ce lab a été testé sur Debian 12.8 avec Zabbix 7.2, mariadb et NGINX pour le serveur. Pour la partie cliente ce lab a été testé avec Windows 10 Pro et Windows 11 Pro.

Les étapes peuvent varier selon l'OS utilisé.

Afin de pouvoir installer la solution Zabbix, assure toi que le serveur puisse avoir accès à internet.
```
```bash
Comme tu l'auras compris il existe plusieurs systèmes et méthodes qui permettent d'installer et configurer Zabbix. Retrouve toutes ces infos ici :

https://www.zabbix.com/fr/download

Zabbix offre une grande flexibilité d'installation et de configuration en fonction des besoins et de l'infrastructure, C'est un peu comme une sandwicherie où tu choisirais ton menu et où ils te donneraient la recette pour le faire.
```

## 🔬 Étape 1 - Installation du serveur Zabbix

1. Installation du dépôt de Zabbix dans le système:
```bash
1
wget https://repo.zabbix.com/zabbix/7.2/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.2+debian12_all.deb
2
dpkg -i zabbix-release_latest_7.2+debian12_all.deb
```
1. Mise à jour de la liste des paquets et upgrade éventuel:
```bash
1
apt update && apt upgrade -y
```
1. Installation de Zabbix server, du frontend, et de l'agent:
```bash
1
apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
```

## 🔬 Étape 2 - Configuration de Zabbix

1. Installation du SGBD:
```bash
1
apt install mariadb-server
```
1. Vérification du SGBD:
```bash
1
systemctl status mysql
```
```bash
A l'étape suivante, personnalise le nom de la base de données, l'utilisateur de la base de données et le mdp de cet utilisateur.
```
1. Création et configuration de la base de données:
```bash
1
mysql -uroot -p
2
password
3
mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;
4
mysql> create user zabbix@localhost identified by 'password';
5
mysql> grant all privileges on zabbix.* to zabbix@localhost;
6
mysql> set global log_bin_trust_function_creators = 1;
7
mysql> quit;
```
```bash
A l'étape suivante tu seras invité à entrer le mdp de l'utilisateur de la BD précédemment créée.
```
1. Importation du schéma et des données:
```bash
1
zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
```
1. Désactivation de la possibilité de modifier la configuration de la BD par des acteurs malveillants:
```bash
1
mysql -uroot -p
2
password
3
mysql> set global log_bin_trust_function_creators = 0;
4
mysql> quit;
```
```bash
A l'étape suivante tu marqueras une pause pour commencer une réflexion sur le stockage des mdp :D
```
```bash
Voir la solutionAttention :  Ne jamais stocker les mots de passe en clair dans les fichiers de configuration ! C'est une pratique extrêmement risquée qui expose les systèmes à des attaques.
Utilisez plutôt l'une des méthodes suivantes pour stocker les mots de passe de manière sécurisée :

Coffres-forts de mots de passe : Utilisez un gestionnaire de mots de passe pour stocker et gérer les mots de passe de manière sécurisée. Zabbix peut s'intégrer avec certains gestionnaires de mots de passe.

Chiffrement : Chiffrez le mot de passe avant de le stocker dans le fichier de configuration. Assurez-vous d'utiliser un algorithme de chiffrement fort et de stocker la clé de chiffrement de manière sécurisée.

Pour aller plus loin sur la sécurisation des mots de passe dans Zabbix, consultez la documentation officielle :

https://www.zabbix.com/documentation/7.2/en/manual/appendix/install/db_encrypt
```
1. Edition du fichier de configuration de la BD du serveur Zabbix dans `/etc/zabbix/zabbix_server.conf`:
```bash
1
DBPassword=password
```
1. Configuration de PHP pour accéder au frontend dans `/etc/zabbix/nginx.conf`:
```bash
1
listen 8080;
2
server_name <ici tu rentreras l'adresse IPv4 de ta machine>;
```
1. Démarrage du server et des processus de l'agent:
```bash
1
systemctl restart zabbix-server zabbix-agent nginx php8.2-fpm
2
systemctl enable zabbix-server zabbix-agent nginx php8.2-fpm
```

## 🔬 Étape 3 - Configuration de Zabbix depuis la WUI

```bash
Ici assure toi que le client se trouve bien sur le même réseau que le serveur.
```
1. Depuis un client tape l'adresse de ton serveur dans un navigateur en ajoutant le port d'écoute:  
	`X.X.X.X:8080`
2. A partir des boutons `Next step`, à toi de configurer ton serveur. Quelques indications... Tu devras renseigner entre autres:
- Le mdp de ta base de donnée
- Le nom de ton serveur Zabbix
- le fuseau horaire du serveur (UTC+1 si t'es à Paris et UTC+3 si t'es en Arménie au hasard hein)

## 🔬 Étape 4 - Installation et configuration de l'Agent Zabbix

1. Télécharge l'agent Zabbix depuis le client Windows à l'adresse suivante: [https://www.zabbix.com/download\_agents](https://www.zabbix.com/download_agents)
2. Lance l'installation de l'agent sur ton client Windows.
3. Durant l'installation, précise l'adresse IP de ton serveur Zabbix dans le champ `Zabbix server IP/DNS:`

## 🔬 Étape 5 - Ajout d'un hôte et création d'un groupe

1. Pour ta 1ère connexion sur la WUI tu utiliseras les identifiants par défaut:
- Utilisateur: Admin
- Mot de passe: zabbix
1. Création de groupes d'hôtes:
- Dans le menu `Data collection/Host groups`:
	- Crée un groupe d'hôtes sous Windows en cliquant sur le bouton `Create host group`.
		- Appelle ce groupe `Windows hosts`.
1. Ajout des hôtes:
- Dans le menu `Data collection/Hosts`:
	- Ajoute ton client Windows en cliquant sur le bouton `Create host`.
		- Ajoute le dans le groupe créé précédemment.
		- Ajoute l'interface `Agent`.
		- Renseigne l'adresse IP de ton client.

## 🔬 Étape 6 - Configuration des alertes et des notifications

```bash
Nous allons appliquer un modèle d'alertes préétabli parmi ceux que Zabbix propose.
```
1. Application du template pour la supervision des hôtes Windows:
- Dans le menu `Data collection/Hosts`:
	- Clique sur le client.
		- Dans le champ `Templates`, clique sur le bouton `Select`.
		- Dans le champ `Template group`, clique sur le bouton `Select`.
		- Choisis `Template`.
		- Coche dans la liste le modèle `Windows by Zabbix agent` puis clique sur `Select`.
		- Clique sur le bouton `Update`.
```bash
A cette étape déjà, tu devrais constater la remontée d'indicateurs dans le menu Monitoring/Hosts, puis en cliquant sur ton client.
```
1. Tu vas configurer la partie notification en suivant les étapes de cette vidéo:
```shell
Concernant la vidéo : https://www.youtube.com/watch?v=9DT7kR8fa0o

Il te faudra surement activer l'authentification à 2 facteurs dans ton web client de messagerie pour permettre à Zabbix d'envoyer des notifications au moyen de ton adresse mail.
Tu n'as pas besoin d'activer "IMAP access" à priori comme expliquer dans la vidéo.
Quand tu seras à l'étape Alerts/Media types inutile de créer un nouveau type de media en cliquant sur Create media type. Il te suffit d'activer le "Media type" Email déjà existant et de le configurer comme expliquer.
```
1. Création d'une alerte spécifique lié à l'utilisation de notre RAM:
- Dans le menu `Data collection/Hosts`:
	- Clique sur `Items` qui se trouve sur la ligne de ton client.
		- Dans le champ `Name` écris "memory utilization" puis tape entrée.
		- Clique sur `Memory utilization` puis sur le bouton `Clone`.
		- Donne un nom et une key à ton item pour le test (ex: Alerte RAM et AlerteRAM).
		- Clique sur `Add`.
1. Configuration du déclencheur de l'alerte précédemment créée.
- Dans le menu `Data collection/Hosts`:
	- Clique sur `Triggers` qui se trouve sur la ligne de ton client.
		- Clique sur le bouton `Create trigger` et donne lui un nom (ex: WindowsAlerteRam).
		- Clique sur `Disaster` et sur `Add` du champ `Expression`.
		- Sélectionne dans la liste ton item `Alerte RAM`.
		- Dans `Result` sélectionne `>=` puis la valeur qui va te permettre de déclencher l'alerte.
		- Clique sur `Insert` puis `Add` en bas de la fenêtre.
1. Ouvre quelques applications sur ton client pour solliciter la RAM au niveau que tu as défini pour l'alerte et réceptionne ton mail. Quand l'utilisation de ta RAM va redescendre tu vas recevoir dans la foulée un mail de Zabbix t'indiquant que le problème est résolu.

## 📝 Résumé

Comme tu peux le constater Zabbix est un outil puissant qui te permet de calibrer au millimètre et en temps réel la supervision de ton SI. Tu vas pouvoir monitorer la disponibilité et les performances de tes serveurs, tes réseaux, tes VMs, tes services, tes clients dans une interface intuitive et modulable à souhait.

## 🏆 Challenge

Toi aussi configure une alerte et une notification qui t'en avise.

## 🔍 Critères d'acceptation

Si tu reçois le mail, c'est gagné!

Quête terminée le **mercredi 04 février 2026**