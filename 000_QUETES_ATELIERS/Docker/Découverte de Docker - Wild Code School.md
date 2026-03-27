---
title: "Découverte de Docker - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2416/pages/18081"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Docker

## Découverte de Docker

Expérimenter la récupération d'images et le lancement de conteneurs

Facile

1h 30mins

3 pairs

Docker

## Découverte de Docker

## Introduction

**Docker** est un outil permettant la gestion d'applications sous la forme de **conteneurs**.

Cette quête propose de découvrir les notions d' **image** et de **conteneur** et ainsi de commencer à utiliser **Docker** pour déployer des applications.

![The Docker blue banner representing a whale carrying containers on its back](https://www.docker.com/wp-content/uploads/2022/03/horizontal-logo-monochromatic-white.png)

## 🤓 Objectifs:

✅ Découvrir les concepts fondamentaux de Docker  
✅ Récupérer des images  
✅ Exécuter des conteneurs

## Sommaire

- [👉 Installer Docker](https://odyssey.wildcodeschool.com/quests/2416/pages/18081#-installer-docker)
- [👉 Gérer les images](https://odyssey.wildcodeschool.com/quests/2416/pages/18081#-g%C3%A9rer-les-images)
- [👉 Lancer un conteneur](https://odyssey.wildcodeschool.com/quests/2416/pages/18081#-lancer-un-conteneur)
	- [🔬 Lancement d'un conteneur interactif](https://odyssey.wildcodeschool.com/quests/2416/pages/18081#-lancement-dun-conteneur-interactif)
		- [🔬 Lancement d'un conteneur serveur](https://odyssey.wildcodeschool.com/quests/2416/pages/18081#-lancement-dun-conteneur-serveur)
- [👉 Poursuivre son exploration](https://odyssey.wildcodeschool.com/quests/2416/pages/18081#-poursuivre-son-exploration)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2416/pages/18081#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2416/pages/18081#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2416/pages/18081#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2416/pages/18081#-crit%C3%A8res-dacceptation)

## 👉 Installer Docker

**Docker** est constitué d'un serveur `dockerd` et d'une interface utilisateur qui peut-être en ligne de commande: la commande `docker`, ou graphique: **Docker Desktop**.  
L'installation classique de Docker consiste à installer le serveur et au moins un client sur la même machine.

```shell
En pratique, Docker Desktop est bien plus qu'une interface graphique pour interagir avec Docker. En effet, comme Docker repose fortement sur des fonctionnalités spécifiques du noyau Linux (les namespaces et les cgroups notamment), une couche de virtualisation supplémentaire est nécessaire, sur un système non Linux, pour disposer d'un noyau Linux et ainsi de Docker. Une installation de Docker Desktop consiste donc aussi à installer une machine virtuelle Linux pour héberger le dockerd.
```

Première étape pour commencer à pratiquer avec Docker: l'installation.

```shell
LinuxWindows & MacMême si Docker Desktop est maintenant aussi disponible sous Linux, l'installation habituelle consiste à installer Docker Engine qui installe le serveur et le client CLI directement sur l'OS.

https://docs.docker.com/engine/

Documentation officielle de Docker Engine

👉 Suis la partie de la documentation dédiée à l'installation sur ta distribution GNU/Linux.
```

La façon la plus simple de vérifier si ton installation est fonctionnelle est sans doute d'afficher la version de docker.

```shell
1
wilder@host:~$ docker --version
2
Docker version 20.10.23, build 7155243
```
```shell
Qu'est-ce que Docker - IBM France
Cet article permet d'appréhender ce qu'est Docker et à quoi il sert.https://www.ibm.com/fr-fr/cloud/learn/docker
```

---

## 👉 Gérer les images

Une application distribuée via Docker est appelée une **image**.

```shell
Une image peut-être vue comme un paquet contenant un programme et toutes les dépendances nécessaires à son exécution.

C'est parce qu'une image est ainsi auto-suffisante, et ne dépend au final que de la présence du Docker Engine, et de rien d'autre, pour être exécutée, que Docker peut-être considéré comme un moyen fiable et simple de déployer des applications sur n'importe quel environnement.
```

Il est évidemment possible de construire ses propres **images**, mais pour l'instant, il est plus simple de récupérer une **image** existante.

Les **images** peuvent être publiées dans des dépôts.

Durant l'installation de **Docker**, tu as peut-être été amené à créer un compte sur [Docker Hub](https://hub.docker.com/).  
Ce site, géré par la société [Docker Inc.](https://www.docker.com/company/) qui est aussi l'éditeur de **Docker**, héberge un grand nombre de dépôts.  
Tu peux d'ailleurs l'utiliser pour publier tes propres images dans ton propre dépôt public ou privé.

Par défaut, Docker récupère les images sur **Docker Hub**.

La commande pour récupérer une image est `docker image pull` (ou `docker pull` en version courte) suivi du nom d'une image, éventuellement suivi d'un identifiant de version séparé par `:`.  
Lorsque la version n'est pas précisée, Docker récupère la dernière version: `latest`.

Tu as peut-être déjà récupéré l'image `hello-world` lors de l'installation. Tu peux le vérifier en affichant les images disponibles sur ta machine avec `docker image ls` (ou `docker images` en raccourci).

Exemple:

```shell
1
wilder@host:~$ docker image ls
2
REPOSITORY                                         TAG         IMAGE ID       CREATED         SIZE
3
docker/getting-started                             latest      3e4394f6b72f   6 weeks ago     47MB
4
debian                                             latest      c4905f2a4f97   9 months ago    124MB
5
hello-world                                        latest      feb5d9fea6a5   16 months ago   13.3kB
```

Si ce n'est pas fait, récupère cette image:

```shell
1
wilder@host:~$ docker image pull hello-world
2
Using default tag: latest
3
latest: Pulling from library/hello-world
4
2db29710123e: Pull complete 
5
Digest: sha256:aa0cc8055b82dc2509bed2e19b275c8f463506616377219d9642221ab53cf9fe
6
Status: Downloaded newer image for hello-world:latest
7
docker.io/library/hello-world:latest
```

Il ne serait d'ailleurs pas très grave d'essayer de récupérer une image déjà présente localement. **Docker** vérifie avant et indique que la récupération n'est pas nécessaire si l'image dans la version demandée est déjà présente.

```shell
1
wilder@host:~$ docker image pull hello-world:latest
2
latest: Pulling from library/hello-world
3
Digest: sha256:aa0cc8055b82dc2509bed2e19b275c8f463506616377219d9642221ab53cf9fe
4
Status: Image is up to date for hello-world:latest
5
docker.io/library/hello-world:latest
```

Il est possible de supprimer des images locales avec la commande `docker image rm` (ou `docker rmi` en raccourci).

## 👉 Lancer un conteneur

L'exécution d'une image consiste pour **Docker** à créer un conteneur.

```shell
Un conteneur est une forme d'isolation de processus sur un système qui se traduit par le fait que ce processus, et donc tout ses fils, sont isolés du reste du système qu'il voit donc différemment des autres processus.
Par exemple :

Les processus du conteneur ne voit pas l'ensemble du système de fichier, mais seulement ce qui est disponible dans l'image.
Le conteneur a en général un autre nom d'hôte (hostname) que le système hôte
Les identifiants de processus sont différents dans le conteneur qui ne voit ainsi que les processus fils du processus racine du conteneur (qui sera le pid 1)
etc.
```

Pour exécuter une image, et donc créer un conteneur, on utilise la commande `docker run` suivi du nom de l'image (et éventuellement de la version) qu'on veut exécuter.

Test en exécutant l'image `hello-world`. Tu devrais obtenir quelque chose de similaire à ce qui suit:

```shell
1
wilder@host:~$ docker run hello-world
2

3
Hello from Docker!
4
This message shows that your installation appears to be working correctly.
5

6
To generate this message, Docker took the following steps:
7
 1. The Docker client contacted the Docker daemon.
8
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
9
    (amd64)
10
 3. The Docker daemon created a new container from that image which runs the
11
    executable that produces the output you are currently reading.
12
 4. The Docker daemon streamed that output to the Docker client, which sent it
13
    to your terminal.
14

15
To try something more ambitious, you can run an Ubuntu container with:
16
 $ docker run -it ubuntu bash
17

18
Share images, automate workflows, and more with a free Docker ID:
19
 https://hub.docker.com/
20

21
For more examples and ideas, visit:
22
 https://docs.docker.com/get-started/
```
```shell
Docker tente en général de rattraper les oublis.

Aussi, si on tente d'exécuter une image qui n'est pas disponible, il va la télécharger automatiquement.

C'est ce qu'indique le texte affiche par ce hello-world qui suppose qu'on a directement entré docker run hello-world juste après l'installation de Docker. Ce que tu as peut-être fait en suivant la doc 😉.
```

De très nombreuses options sont disponibles pour `docker run` et permettent de définir la façon dont **Docker** doit exécuter le conteneur.

Quelques exemples:

- `-d`: permet d'executer le conteneur en tâche de fond.
- `-e`: permet de passer au conteneur des variables d'environnement.
- `-h`: permet de choisir le nom d'hôte du conteneur.
- `-i`: exécution interactive. Les entrées clavier sont transmise au conteneur.
- `-m`: limite la quantité de mémoire vive accessible par le conteneur.
- `-p`: créé un transfert de port entre un port de l'hôte et un port du conteneur.
- `-t`: associe une console (pseudo-tty) au conteneur.
- `-v`: associer le conteneur à un volume.
- *etc.*

## 🔬 Lancement d'un conteneur interactif

Décortiquons l'exemple suggéré par `hello-world` d'exécuter `docker run -it ubuntu bash`

Il s'agit d'exécuter l'image `ubuntu`. Même plus précisément `ubuntu:latest` puisqu'aucune version n'est précisée. Cette image est comme son nom l'indique un système ubuntu minimal.  
Il est d'ailleurs possible d'en savoir plus en allant voir son [descriptif sur Docker Hub](https://hub.docker.com/_/ubuntu).  
Les options `-it` permettent d'interagir directement avec le conteneur via le terminal.  
Le `bash` final indique quelle commande/programme on souhaite exécuter dans le conteneur. Ce paramètre est optionnel car chaque image contient la commande à exécuter par défaut quand ce n'est pas précisé.

Lance la commande, tu devrais obtenir un résultat similaire à ceci:

```shell
1
wilder@host:~$ docker run -it ubuntu bash
2
Unable to find image 'ubuntu:latest' locally
3
latest: Pulling from library/ubuntu
4
677076032cca: Pull complete 
5
Digest: sha256:9a0bdde4188b896a372804be2384015e90e3f84906b750c1a53539b585fbbe7f
6
Status: Downloaded newer image for ubuntu:latest
7
root@7037ef56444a:/#
```

Il s'agit d'un shell, ce qui est logique puisqu'on a exécuté `bash`.  
Mais l'utilisateur est maintenant `root`. Par défaut, les processus sont exécutés par le compte root dans le conteneur.  
On note que le nom d'hôte à changé. Il est très probablement différent sur ta machine, il s'agit de l'identifiant du conteneur que Docker à générer automatiquement lorsqu'il l'a lancé.

On peut d'ailleurs le vérifier en ouvrant un autre terminal et en utilisant la commande `docker container ps` (ou `docker ps` en version courte) qui affiche l'ensemble des conteneurs actifs:

```shell
1
wilder@host:~$ docker container ps
2
CONTAINER ID   IMAGE     COMMAND   CREATED         STATUS         PORTS     NAMES
3
7037ef56444a   ubuntu    "bash"    5 minutes ago   Up 5 minutes             brave_galileo
```
```shell
Attention à bien exécuter docker ps dans un autre terminal car dans le conteneur, tu n'as accès qu'à ce qui se trouve dans l'image qui ne contient, bien sûr, pas Docker.
```

Tu peux d'ailleurs constater l'isolation du conteneur en affichant tous les processus à l'aide de la commande `ps -ef` et constater que l'exécution dans le conteneur produit un résultat bien différent d'une exécution sur le système hôte.

Dans le conteneur, tu obtiens quelque chose de similaire à ceci:

```shell
1
root@7037ef56444a:/# ps -ef
2
UID          PID    PPID  C STIME TTY          TIME CMD
3
root           1       0  0 15:13 pts/0    00:00:00 bash
4
root          12       1  0 15:21 pts/0    00:00:00 ps -ef
```

On constate bien qu'il n'y a que notre `bash`, et les commandes qu'il a exécutées (processus fils), qui s'exécute dans le **conteneur** et que `bash` est d'ailleurs le processus de `pid` 1.

De la même façon, le système de fichier vu par le conteneur est différent de celui de l'hôte. Par exemple le `/home` du conteneur est vide.

Taper `exit` dans le conteneur termine `bash` et passe le conteneur dans l'état `exited`.  
Il n'apparaît d'ailleurs plus dans la liste des **conteneurs** affichée par `docker ps` sauf si on y ajoute l'option `-a`.

La commande `docker system prune` permet un *nettoyage* de certaines ressources docker plus utilisées, notamment les **conteneurs** terminés.

## 🔬 Lancement d'un conteneur serveur

Tentons maintenant d'exécuter un **conteneur** serveur.

Pour l'exemple, on suppose de déploiement d'un serveur web: le classique [httpd](https://httpd.apache.org/), le serveur web de la fondation [Apache](https://apache.org/).

Une image docker officielle de ce serveur est disponible sur Docker Hub: [Image Docker de httpd](https://hub.docker.com/_/httpd).

Lance directement le **conteneur** avec la commande `docker run -dp 8000:80 httpd`.  
L'option `d` pour l'executer en tâche de fond, et l'option `p 8000:80` pour indiquer de mettre en port 8000 de l'hôte en écoute et de transferer les paquets qui y arrivent sur le port 80 du conteneur.

```shell
1
wilder@host:~$ docker run -dp 8000:80 httpd
2
Unable to find image 'httpd:latest' locally
3
latest: Pulling from library/httpd
4
01b5b2efb836: Pull complete 
5
831122b282b9: Pull complete 
6
1a6abe5420b4: Pull complete 
7
36fa1415f90a: Pull complete 
8
0127b4d49ca0: Pull complete 
9
Digest: sha256:e63470b5cf761fe43810b49a1cc3117746d7d6bff36d80e2b0a5ad1c6f0325d5
10
Status: Downloaded newer image for httpd:latest
11
c3ea8a097e236934cd265981ff7f080264044d2a28654455b36e901a013f9f07
12
wilder@host:~$
```
```shell
La commande a déclenché automatiquement le téléchargement de l'image.

On note même qu'il y a eu des téléchargements.

C'est lié à un mécanisme de gestion des images par couches.

En effet, les images Docker sont constituées d'une succession de couches, chaque couche étant mutualisée entre toutes les images qui la partage.
Par exemple :

L'image httpd:2.4 qu'on vient de récupérer (latest au moment de la rédaction de cette quête) est construite à partir d'une autre image : debian:bullseye-slim. Sur un système où cette image est déjà présente, elle n'est pas téléchargée à nouveau. Elle est juste indiquée comme étant la première couche de l'image httpd:2.4.
```

**Docker** rend immédiatement la main, puisqu'on a lancé le conteneur en tâche de fond, mais il est actuellement en cours.

Il apparaît d'ailleurs dans `docker ps`

```shell
1
wilder@host:~$ docker ps
2
CONTAINER ID   IMAGE     COMMAND              CREATED          STATUS          PORTS                                   NAMES
3
c3ea8a097e23   httpd     "httpd-foreground"   14 minutes ago   Up 14 minutes   0.0.0.0:8000->80/tcp, :::8000->80/tcp   inspiring_brahmagupta
```

On peut aussi vérifier que le port 8000 est bien ouvert sur le système hôte.

```shell
1
wilder@host:~$ ss -tl
2
State                    Recv-Q                   Send-Q                                     Local Address:Port                                       Peer Address:Port                  Process                   
3
LISTEN                   0                        4096                                             0.0.0.0:8000                                            0.0.0.0:*                                               
4
LISTEN                   0                        4096                                                [::]:8000                                               [::]:*
```

Et surtout plus intéréssant, on peut maintenant se connecter sur le serveur web en insérant `http://localhost:8000` dans la barre d'adresse.

![Screenshot of a web browser showing "It works"](https://storage.googleapis.com/quest_editor_uploads/Hgl21ZP1at3kjLcJepQc9XUHzLuhEKEl.png)

Docker offre la possibilité d’accéder aux journaux du conteneur à l'aide de `docker container logs` (ou `docker logs` en plus court) suivi de l'identifiant du conteneur. Lesquels font, dans ce cas, apparaître les requêtes HTTP reçues.

```shell
1
wilder@host:~$ docker container logs c3ea8a097e23
2
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message
3
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message
4
[Tue Feb 07 13:41:34.517240 2023] [mpm_event:notice] [pid 1:tid 140370447027520] AH00489: Apache/2.4.55 (Unix) configured -- resuming normal operations
5
[Tue Feb 07 13:41:34.517295 2023] [core:notice] [pid 1:tid 140370447027520] AH00094: Command line: 'httpd -D FOREGROUND'
6
172.17.0.1 - - [07/Feb/2023:13:51:28 +0000] "GET / HTTP/1.1" 304 -
7
172.17.0.1 - - [07/Feb/2023:13:52:21 +0000] "GET / HTTP/1.1" 200 45
```

La commande `docker stop` suivi de l'identifiant du conteneur permet d’arrêter le conteneur, et donc de couper le serveur web.

## 👉 Poursuivre son exploration

```shell
Docker 101 tutorialUn tutoriel proposé par Docker, assez orienté pour les dev, mais qui peut te permettre d'en apprendre un peu plus sur Docker.https://www.docker.com/101-tutorial/
```

Le tutoriel précédent contient notamment cette longue vidéo qui permet de bien comprendre ce qu'est en conteneur en explorant, par l'exemple, les mécanismes qui permettent sa mise en place.

```shell
CLI cheat sheetCe petit aide-mémoire permet de retrouver un ensemble courant de commande docker.https://docs.docker.com/get-started/docker_cheatsheet.pdf
```

---

## ☝️ Résumé

Docker permet de récupérer des images d'applications et de les exécuter dans des conteneurs logiciels.

---

## 📝 Quiz

```shell
# 1  - Docker Hubpropose des images dockerest un conteneurest un site webValider# 2 est une application client-serveurfourni une interface graphiquecontient le serveur dockerdfourni une CLIpeut-être installé sur tous les systèmesValider# 3 affiche la liste des processus en coursaffiche la liste des images disponiblesaffiche la liste des conteneurs en cours d'exécutionest une commande qui n'existe pasValider# 4 est un alias de docker list imagesest un alias de docker image lsaffiche les images disponibles sur Docker Hubaffiche les images disponibles localementValiderTon score :0 / 4
```

---

## 💪 Challenge

Exécute l'image docker [php](https://hub.docker.com/_/php) puis lance là dans un conteneur **interactif**.  
Dans l'interpréteur php alors disponible, exécute la fonction

```php
1
php > phpinfo(INFO_GENERAL);
```

Copie le résultat de cette commande comme solution.

Tu peux sortir de l'interpréteur php (et du conteneur) en tapant `exit`.

```shell
BONUS :

Profite que tu as maintenant un interpréteur php à ta disposition pour apprendre les rudiments de ce langage 😛
```

## 🧐 Critères d'acceptation

L'affichage obtenu contient une trentaine de ligne qui commencent par **PHP Version =>**...

Solution postée le **mercredi 31 décembre 2025**

```shell
PHP Version => 8.5.1

System => Linux 944031b4c6e0 6.6.87.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Thu Jun  5 18:30:46 UTC 2025 x86_64
Build Date => Dec 29 2025 23:24:17
Build System => Linux - Docker
Build Provider => https://github.com/docker-library/php
Configure Command =>  './configure'  '--build=x86_64-linux-gnu' '--with-config-file-path=/usr/local/etc/php' '--with-config-file-scan-dir=/usr/local/etc/php/conf.d' '--enable-option-checking=fatal' '--with-mhash' '--with-pic' '--enable-mbstring' '--enable-mysqlnd' '--with-password-argon2' '--with-sodium=shared' '--with-pdo-sqlite=/usr' '--with-sqlite3=/usr' '--with-curl' '--with-iconv' '--with-openssl' '--with-readline' '--with-zlib' '--enable-phpdbg' '--enable-phpdbg-readline' '--with-pear' '--with-libdir=lib/x86_64-linux-gnu' '--enable-embed' 'build_alias=x86_64-linux-gnu' 'PHP_UNAME=Linux - Docker' 'PHP_BUILD_PROVIDER=https://github.com/docker-library/php'
Server API => Command Line Interface
Virtual Directory Support => disabled
Configuration File (php.ini) Path => /usr/local/etc/php
Loaded Configuration File => (none)
Scan this dir for additional .ini files => /usr/local/etc/php/conf.d
Additional .ini files parsed => /usr/local/etc/php/conf.d/docker-php-ext-sodium.ini

PHP API => 20250925
PHP Extension => 20250925
Zend Extension => 420250925
Zend Extension Build => API420250925,NTS
PHP Extension Build => API20250925,NTS
PHP Integer Size => 64 bits
Debug Build => no
Thread Safety => disabled
Zend Signal Handling => enabled
Zend Memory Manager => enabled
Zend Multibyte Support => provided by mbstring
Zend Max Execution Timers => disabled
IPv6 Support => enabled
DTrace Support => disabled

Registered PHP Streams => https, ftps, compress.zlib, php, file, glob, data, http, ftp, phar
Registered Stream Socket Transports => tcp, udp, unix, udg, ssl, tls, tlsv1.0, tlsv1.1, tlsv1.2, tlsv1.3
Registered Stream Filters => zlib.*, convert.iconv.*, string.rot13, string.toupper, string.tolower, convert.*, consumed, dechunk

This program makes use of the Zend Scripting Language Engine:
Zend Engine v4.5.1, Copyright (c) Zend Technologies
    with Zend OPcache v8.5.1, Copyright (c), by Zend Technologies
```