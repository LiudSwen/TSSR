---
title: "Mariadb installation serveur et client - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2846/pages/10314"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Base de données

## Mariadb installation serveur et client

Installer un serveur de base de données MariaDB, le sécuriser au minimum et premier pas à l'utilisation du client.

Facile

1h

3 pairs

Base de données

## Mariadb installation serveur et client

## Introduction

MariaDB est un système de gestion de bases de données relationnelles (SGBDR) né d'un [fork](https://fr.wikipedia.org/wiki/Fork_\(d%C3%A9veloppement_logiciel\)) de MySQL.

![Logo de MariaDB représentant une otarie](https://1.bp.blogspot.com/-sWFwjDmfjEo/XqcbUTQkCRI/AAAAAAAA784/3aIrGt2N980-rXgbQ5Nis7zGjFPiARsCQCK4BGAsYHg/w1200-h630-p-k-no-nu/MariaDB_Logo.d8a208f0a889a8f0f0551b8391a065ea79c54f3a.png)

---

## ⚙️ Pré-requis

Avant de commencer cette quête, il est préférable de savoir déjà:

- Utiliser un terminal
- Installer des paquets sur une distribution linux basée sur Debian
- Avoir une VM ou conteneur Debian/Ubuntu sans interface graphique et sans serveur SQL

---

## 🎯 Objectifs:

✅ Comprendre ce qu'est un serveur de base de données  
✅ Installer un serveur de base de données en local  
✅ Sécuriser au strict minimum un serveur de base de données  
✅ Se connecter à un serveur de base de données avec un terminal  
✅ Créer un utilisateur avec des privilèges

## Sommaire

- [📖 Définition](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-d%C3%A9finition)
- [📖 MariaDB c'est quoi?](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-mariadb-cest-quoi-)
- [📖 MariaDB c'est qui?](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-mariadb-cest-qui-)
- [📖 Comparaison avec MySQL](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-comparaison-avec-mysql)
- [📖 Quand utiliser MariaDB?](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-quand-utiliser-mariadb-)
- [🐚 Installation de MariaDB](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-installation-de-mariadb)
- [🐚 Se connecter au serveur](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-se-connecter-au-serveur)
- [🐚 Requêter le serveur](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-requ%C3%AAter-le-serveur)
- [🐚 Lister les utilisateurs](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-lister-les-utilisateurs)
- [🐚 Lister les bases de données](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-lister-les-bases-de-donn%C3%A9es)
- [🐚 Créer un utilisateur](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-cr%C3%A9er-un-utilisateur)
- [🐚 Créer une nouvelle base de données](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-cr%C3%A9er-une-nouvelle-base-de-donn%C3%A9es)
- [🐚 Gérer les droits](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-g%C3%A9rer-les-droits)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2846/pages/10314#-crit%C3%A8res-dacceptation)

## 📖 Définition

Une base de données permet de stocker des informations utiles pour ton application. Tu vas apprendre lors de cette quête comment manipuler ces données, mais pour le moment, tu dois installer un logiciel de base de données sur ta machine, c'est ce qu'on appelle un SGBDR (Système de Gestion de Base de Données Relationnelle).

On va manipuler le SGBDR qui se nomme **MariaDB**.

## 📖 MariaDB c'est quoi?

MariaDB est un système d'administration de bases de données relationnelles open source et gratuit. Il a été conçu par les développeurs à l'origine de MySQL suite aux inquiétudes concernant la commercialisation de MySQL après son acquisition par Oracle en 2009.

Ce SGBDR offre les mêmes fonctionnalités que MySQL et peut être utilisé pour remplacer ce dernier directement. Conçu pour la vitesse, la fiabilité et la facilité d'utilisation, ce système peut être utilisé pour les tâches de traitement des petites et grandes entreprises.

## 📖 MariaDB c'est qui?

Le nom de MariaDB vient de l'une des filles du co-fondateur, Michael "Monty" Winenius. MySQL, désormais une marque déposée par Oracle, porte le nom de sa fille My. Pour suivre la tradition, MariaDB porte le nom de sa fille cadette, Maria. Initialement, MariaDB était le nom d'un moteur de stockage, rebaptisé Aria.

## 📖 Comparaison avec MySQL

La principale différence entre MariaDB et MySQL est que MariaDB est complètement open-source et est globalement plus rapide que MySQL grâce à un plus grand nombre de moteurs de stockage et un pool de connexion plus important.

Cependant, MySQL supporte le masquage des données et les colonnes dynamiques, ce qui n'est pas le cas de MariaDB.

## 📖 Quand utiliser MariaDB?

MariaDB convient bien aux applications transactionnelles d'entreprise qui nécessitent la prise en charge de requêtes fréquentes, des temps de réponse rapides et le traitement de petites quantités de données. Son moteur de stockage InnoDB prend en charge les transactions conformes à [ACID](https://fr.wikipedia.org/wiki/Propri%C3%A9t%C3%A9s_ACID) en s'assurant, notamment,maria que chaque transaction est traitée comme une seule unité.

## 🐚 Installation de MariaDB

```sh
Cette quête aborde l'installation de MariaDB sur une système d'exploitation basé sur Debian (avec le gestionnaire de paquet APT).
Pour l'installation sur d'autres environnement, tu peux te réferer à la documentation officielle : MariaDB Binary Packages
N'hésites pas à en discuter avec ton formateur pour trouver d'autres ressources adéquates.
```
```sh
A noter que l'installation du paquet suivant installe également un client permettant de manipuler le serveur.
```
```sh
Debian/UbuntuPour installer MariaDB, ouvre un terminal et tape :
1
$ sudo apt update
2
$ sudo apt install mariadb-server
Si jamais tu veux vérifier la version avant installation, tu peux faire ce qui suit :
1
$ sudo apt show mariadb-server
Voilà tu viens de d'installer le serveur MariaDB, c'est  fini... ou pas, car en fait, c'est la configuration "fine" qui sera un peu plus complexe.
Optimization and Tuning - MariaDB Knowledge Base🐧 Si jamais tu t'ennuie pendant cette quête, je t'invites à te connecter sur la base de connaissance de MariaDB et notamment sur la partie "optimisation et réglage" qui te permet de voir plus loin qu'une simple installation.https://mariadb.com/kb/en/optimization-and-tuning/
🐚 Sécurisation de MariaDB
Un peu de sécurité ne fait jamais de mal, ou même si ce n'est pas vraiment de la sécurité à proprement parler, il existe un script fourni avec le paquet que tu viens d'installer et qui permet de revoir quelques éléments de l'installation par défaut.
Pour lancer ce script, voici la commande à lancer :
1
$ sudo mariadb-secure-installation
Tu vas être amené à répondre à une série de questions interactives conçues pour renforcer à minima la sécurité de ton serveur MariaDB.
Voici des explications plus précises :
Conseil pour tout ce que tu feras en quête : si tu ne sais pas ce que tu fais autant rechercher des explications avant de faire n'importe quoi ! Car c'est bien connu : c'est en faisant n'importe quoi.. que l'on fait n'importe quoi !
1
Setting a root password: 
Tu as la possibilité de définir un mot de passe pour le compte root, offrant ainsi une couche de protection supplémentaire. Je te recommande chaudement de le faire car par défaut le compte root n'a pas de mot de passe :).
1
Removing anonymous users:
Le script te propose de supprimer tous les comptes utilisateurs anonymes, garantissant que seuls les utilisateurs authentifiés peuvent accéder aux bases de données.
1
Disallowing remote root login:
Tu seras invité à désactiver la connexion root à distance, empêchant ainsi tout accès non autorisé potentiel à partir de sources externes.
1
Removing the test database:
Supprimer la base de données de "test", créée par défaut, qui est généralement accessible aux utilisateurs anonymes. Cette action élimine toutes les vulnérabilités de sécurité potentielles associées à la base de données de "test".
1
Reloading privilege tables:
Une fois les mesures de sécurité nécessaires mises en œuvre, le script te propose de recharger les tables de privilèges pour appliquer efficacement les modifications. Si tu ne le fais pas, alors certains éléments de configuration ne prendront effet qu'après avoir lancé la commande "FLUSH PRIVILEGES" en te connectant directement au serveur. Un redémarrage du serveur MariaDB ne rechargera pas automatiquement les privilèges.
```

Si l'envie te prend de vérifier que ton serveur MariaDB est fonctionnel, tu peux en vérifier l'état comme suit:

```bash
1
$ sudo systemctl status mariadb
```

Tu devrais voir s'afficher quelque chose de similaire à ce qui suit:

```sh
1
● mariadb.service - MariaDB 10.5.21 database server
2
     Loaded: loaded (/lib/systemd/system/mariadb.service; enabled; vendor preset: enabled)
3
     Active: active (running) since Thu 2023-10-12 14:37:08 CEST; 18min ago
4
       Docs: man:mariadbd(8)
5
             https://mariadb.com/kb/en/library/systemd/
6
   Main PID: 455 (mariadbd)
7
     Status: "Taking your SQL requests now..."
8
      Tasks: 9 (limit: 1115)
9
     Memory: 114.4M
10
        CPU: 523ms
11
     CGroup: /system.slice/mariadb.service
12
             └─455 /usr/sbin/mariadbd
13
```

L'affichage de `systemctl status` se termine par quelques lignes de log à la suite de l'état affiché ci-dessus.

Si tu as autre chose que "Active" sur la 3ème ligne, alors il y a un problème. Tu peux donc soit essayer de trouver par toi même la raison soit demander de l'aide à ton formateur.

## 🐚 Se connecter au serveur

Comme indiqué un peu plus haut, en installant la partie "serveur", tu as un client qui s'est automatiquement ajouté. Ce dernier te permet, depuis ton terminal, de te connecteur au serveur avec soit un compte `root` (différent de celui de ton système) sans mot de passe OU si tu as lancé les commandes pour sécuriser ton serveur, avec le mot de passe défini.

Pour t'y connecter, il suffit de lancer la commande suivante:

```bash
1
$ mariadb -u root -p
```
```sh
Le paramètre "-p" force la demande d'un mot de passe de connexion. Une fois la commande lancée, tu peux saisir le mot de passe et ensuite appuyer sur la touche "entrée".
```

Tu devrais voir ceci (avec un numéro de version plus ou moins différent):

```sh
1
wilder@debian:~$ mariadb -u root -p
2
Welcome to the MariaDB monitor.  Commands end with ; or \g.
3
Your MariaDB connection id is 41
4
Server version: 10.5.21-MariaDB-0+deb11u1 Debian 11
5

6
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.
7

8
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
9

10
MariaDB [(none)]>
```

Première chose à noter: le prompt à changé.  
En effet, tu n'es plus ici en train d'envoyer des commandes à ton shell, mais à la base de données.

Il convient donc d'adapter ton langage 😄.

C'est le langage [SQL](https://fr.wikipedia.org/wiki/Structured_Query_Language) (*Structured Query Language*) qui est utilisé pour interagir avec une base de données.

```sh
Tu vois ici que tu peux obtenir de l'aide en écrivant "\h" (puis touche entrée) et il est indiqué que tes commandes SQL doivent être terminées par ";" ou "\g".
```
```sh
Plus d'info sur le langage SQL sur le site SQL.shhttps://sql.sh/
```

## 🐚 Requêter le serveur

Entre une première requête pour tester:

```sql
1
MariaDB [(none)]> SHOW AUTHORS;
2
+--------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------+
3
| Name                           | Location                              | Comment                                                                                                                                 |
4
+--------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------+
5
| Michael (Monty) Widenius       | Tusby, Finland                        | Lead developer and main author                                                                                                          |
6
| Sergei Golubchik               | Kerpen, Germany                       | Architect, Full-text search, precision math, plugin framework, merges etc                                                               |
7
| Igor Babaev                    | Bellevue, USA                         | Optimizer, keycache, core work                                                                                                          |
8
...
9
| Peter Zaitsev                  | Tacoma, WA, USA                       | SHA1(), AES_ENCRYPT(), AES_DECRYPT(), bug fixing                                                                                        |
10
| Mark Mark Callaghan            | Texas, USA                            | Statistics patches                                                                                                                      |
11
+--------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------+
12
105 rows in set (0,000 sec)
13

14
MariaDB [(none)]>
```

Cette requête SQL `SHOW AUTHORS` permet d'afficher la liste des contributeurs à mariadb. Comme toute requête SQL elle se termine par un `;` (ou un `\G` pour avoir un affichage en liste).  
Elle affiche donc la liste des 105 contributeurs actuels et une fois le résultat affiché, tu récupères le prompt pour entrer une nouvelle requête.

La commande `mariadb` permet par défaut d'intergir en mode interactif avec la base.  
Pour sortir de ce **prompt mariadb** et retourner au shell, il faut entrer la commade `exit`. Ce `exit` n'est pas du SQL, le `;` est donc inutile.

Il est aussi possible d'utiliser la commande `mariadb` plutôt en mode script pour lui faire exécuter des requêtes SQL sans quitter le shell.

On peut par exemple le faire avec l'option `-e` qu'on fait suivre de la requête SQL qu'on souhaite exécuter.

```sh
1
wilder@debian:~$ mariadb -u root -p -e "SHOW AUTHORS;"
2
Enter password: 
3
+--------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------+
4
| Name                           | Location                              | Comment                                                                                                                                 |
5
+--------------------------------+---------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------+
6
| Michael (Monty) Widenius       | Tusby, Finland                        | Lead developer and main author                                                                                                          |
7
...
8
wilder@debian:~$
9
```

Il devient alors possible d'interagir avec les résultats au moyen des commandes habituelles du shell. Par exemple pour découvrir la liste des contributeurs Français.

```sh
1
romain@debian:~$ mariadb -u root -p -e "SHOW AUTHORS;"|grep France
2
Enter password: 
3
Olivier Bertrand    Paris, France    CONNECT storage engine
4
Guilhem Bichot    Bordeaux, France    Replication (since 4.0)
5
romain@debian:~$ 
6
```

Il est aussi envisageable d'utiliser les mécanismes de redirections et de *pipe* du shell pour obtenir des résultats similaires.

Par exemple avec `|`:

```sh
1
wilder@debian:~$ echo "SHOW AUTHORS" | mariadb -u root -p
```

Ou via l'utilisation d'un fichier contenant la requete (ou bien sûr les requêtes).

```sh
1
wilder@debian:~$ cat show-authors.sql 
2
SHOW AUTHORS;
3
wilder@debian:~$ mariadb -u root -p < show-authors.sql
```
```sh
Redirections et gestion du flux avec Bash
Un article pour revoir les notions d'entrée et de sortie standard ainsi que les mécanismes de redirectionhttps://www.pierre-giraud.com/shell-bash/redirection-gestion-flux/
```

## 🐚 Lister les utilisateurs

MariaDB est un SGBDR identique à MySQL et il intègre donc des "fonctions" intégrées à ce dernier comme par exemple celle qui te permet de retrouver l'utilisateur courant ou bien encore la liste des utilisateurs existants.

Voyons comment faire pour connaître l'utilisateur courant. Tout d'abord, connectes toi à ton serveur de base de données puis une fois connecté lances la commande suivante:

```sql
1
SELECT current_user();
```

Comme tu es connecté en *root*, tu devrais voir ceci:

```sql
1
MariaDB [(none)]> SELECT current_user();
2
+----------------+
3
| current_user() |
4
+----------------+
5
| root@localhost |
6
+----------------+
7
1 row in set (0,000 sec)
8
```

Maintenant on va lister l'ensemble des comptes utilisateurs:

```sql
1
MariaDB [(none)]> SELECT user, host FROM mysql.user;
2
+-------------+-----------+
3
| User        | Host      |
4
+-------------+-----------+
5
| mariadb.sys | localhost |
6
| mysql       | localhost |
7
| root        | localhost |
8
+-------------+-----------+
9
3 rows in set (0,001 sec)
10
```

Sur un système fraîchement installé, on y trouve le compte `root` ainsi que 2 comptes administratifs `mariadb.sys` et `mysql` qui sont 2 comptes qu'utilise le serveur pour sa gestion interne.

## 🐚 Lister les bases de données

Le serveur MariaDB est livré par défaut avec quatre base de données nécessaires pour son bon fonctionnement. Je te propose de les lister avec la commande suivante:

```bash
1
SHOW databases;
```

Et tu devrais voir ceci:

```sql
1
MariaDB [(none)]> SHOW DATABASES;
2
+--------------------+
3
| Database           |
4
+--------------------+
5
| information_schema |
6
| mysql              |
7
| performance_schema |
8
+--------------------+
9
3 rows in set (0,001 sec)
```
- `information_schema`: base de données système qui fournit des métadonnées sur d'autres bases de données, tables, colonnes, index, utilisateurs, privilèges, etc. Tu peux exécuter des requêtes SQL sur la base de données `information_schema` pour obtenir des informations sur sa structure. Elle est particulièrement utile pour la gestion et la documentation de la structure de la base de données.
- `mysql`: base de données qui contient des tables système et des données liées à la gestion des utilisateurs, des privilèges et de la sécurité dans le système de gestion de base de données. C'est là que se trouvent des tables telles que `mysql.user`, `mysql.db`, `mysql.tables_priv`, `mysql.columns_priv`, etc. Elle est essentielle pour la gestion des utilisateurs et des privilèges.
- `performance_schema`: base de données utilisée pour la collecte de statistiques de performance et de métadonnées sur les opérations en cours dans le système de gestion de base de données. Elle est principalement utilisée pour le profilage des performances et le dépannage.
- `sys`: extension optionnelle qui n'est pas incluse par défaut dans toutes les installations de MariaDB/MySQL. Elle contient des vues et des procédures stockées qui facilitent la surveillance et la gestion des performances de la base de données. Elle fournit des informations sous une forme plus conviviale que `performance_schema` pour analyser les performances du système de gestion de base de données.

## 🐚 Créer un utilisateur

On a vu que, par défaut, nous n'avons qu'un compte `root` et il est évident que ce compte ne doit servir que pour les tâches d'administration de la base. Nous allons donc voir ici comment créer un compte utilisateur sans privilège.

```sh
Pourquoi aucun privilège ? Parce que pour le moment nous n'avons aucune base de données hormis celles propres au bon fonctionnement du serveur et on ne souhaite pas que notre nouvel utilisateur y accède.
```

Pour cela, voici les commandes à lancer depuis le serveur MariaDB:

```sql
1
CREATE USER 'nom_utilisateur'@'localhost' IDENTIFIED BY 'password';
```

Penses à remplacer `nom_utilisateur` par un identifiant pertinent. Même s'il est envisageable d'avoir des comptes pour des utilisateurs *humain*, la plupart du temps, les comptes utilisateurs d'une base de données correspondent à des applications. On a donc fréquemment des identifiants utilisateurs tels que *wordpress* ou *prestashop*.

`localhost` spécifie que cet utilisateur ne peut se connecter que depuis le serveur MariaDB `local`. Si tu souhaites lui autoriser la connexion depuis n'importe quelle adresse IP, alors mets `%` à la place de `localhost`.

Choisi un mot de passe robuste et différent pour chaque nouvel utilisateur créé. Une bonne pratique consiste à utiliser un générateur aléatoire.

Tu peux maintenant relancer la requête affichant l'ensemble des utilisateurs pour voir le résultat.

## 🐚 Créer une nouvelle base de données

Les 4 bases de données, nécessaires au bon fonctionnement de MariaDB, ne doivent pas être utilisées pour stocker des données applicatives.

L'approche habituelle consiste à créer une nouvelle base de données sur un serveur MariaDB existant ou sur un nouveau pour chaque nouvelle application.

La création d'une nouvelle base de fait à l'aide de la requête SQL suivante:

```sql
1
CREATE DATABASE nom_db;
```

Il est courant de nommer la base avec le même nom que l'application qui en dépend. Il est ainsi très facile de savoir ce qui correspond à quoi.

## 🐚 Gérer les droits

On a maintenant un utilisateur et une base de donnée, mais... encore faut-il que cet utilisateur dispose des droits d'accès nécessaire à interagir avec cette base.

MariaDB, grâce au langage SQL, permet une gestion très fine des droits d'accès.

Pour faire très simple et donner accès à l'ensemble des opérations sur l'ensemble des éléments d'une *database* à un utilisateur, on utilise la requête suivante:

```sql
1
GRANT ALL PRIVILEGES ON nom_db.* TO 'nom_utilisateur'@'localhost';
```
```sh
Pour explorer plus en détail ce qu'il est possible de faire avec la requête GRANT, tu peux consulter la section correspondante de la doc officielle.https://mariadb.com/kb/en/grant/
```

## ☝️ Résumé

MariaDB est un SGBDR très similaire à MySQL dont il est issu.

Il s'installe à l'aide d' `apt` sur les systèmes debian et dérivés.

L'administration de la base se fait à l'aide de requête SQL

---

## 📝 Quiz

```sh
# 1  - Sur un serveur mariaDB fraîchement installé on trouve4 bases existantes nécessaires à la gestion du systèmeUne base de donnée exempleAucune base, le serveur est tout neufValider# 2 SHOW DATABASESsudo mariadb -lSELECT ALL FROM DATABASESDB LISTValider# 3 CREATE USERNEW USERsudo mariadb -nValider# 4 ACCESSGRANTAUTHORIZATIONValiderTon score :0 / 4
```

---

## 💪 Challenge

Développe un script bash permettant de mettre en place la base de donnée nécessaire à un projet.

Ce script peut être appelé avec un paramètre qui est le nom du projet ou sans paramètre. Dans ce second cas, il demandera alors à l'utilisateur qui lance le script d'entrer un noms de projet.

Ex:

```sh
1
wilder@debian:~$ sudo create-db.sh MyProject
```

L'objectif de ce script est:

- Installer mariaDB sur la machine si nécessaire
- Créer une nouvelle *database* portant le nom du projet
- Créer un nouvel utilisateur portant aussi le nom du projet. Cet utilisateur se voit affecter un mot de passe aléatoire de 16 caractères.
- Accorder tous les droits sur cette nouvelle *database* à ce nouvel utilisateur
- Afficher les informations récapitulatives en indiquant notamment le mot de passe qu'il faudra utiliser pour se connecter à la base avec le nouvel utilisateur.

Si tu ne trouves pas de moyen de générer un mot de passe aléatoire, tu peux le découvrir via les astuces suivantes:

```sh
Voir la solutionEn utilisant openssl, s'il est installé sur la machine :
1
wilder@debian:~$ openssl rand -base64 16
En utilisant le pseudo fichier générateur d'aléatoire /dev/urandom et la commande tr
1
wilder@debian:~$ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16
```

Une fois le script testé et terminé, publie le dans un dépôt github et poste son adresse en solution.

## 🧐 Critères d'acceptation

- Après l'exécution du script il est possible de se connecter à la base avec l'utilisateur à l'aide d'une commande telle que:
```sh
1
wilder@debian:~$ mariadb -u <project_name> -D <project_name> -p
```
- La base et le compte ont bien été créés.

---

Contribuer à améliorer cette quête.Tous les retours sont précieux pour l'amélioration de nos formations.

Le contenu de la quête m'a permis de comprendre les concepts et d'atteindre les objectifs annoncés:

---

Un commentaire pour nous aider à mieux comprendre?