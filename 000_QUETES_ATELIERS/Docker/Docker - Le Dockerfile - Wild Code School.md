---
title: "Docker - Le Dockerfile - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3021/pages/11394"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Docker

## Docker - Le Dockerfile

Moyen

3 pairs

Docker

## Docker - Le Dockerfile

## Introduction

Dans cette quête, tu vas explorer un des fondements de Docker: La construction d'images.  
Jusqu'à présent lorsque tu as utilisé Docker, tu t'es servi d'images préexistantes. Cette quête va te permettre de personnaliser ces images pour créer tes propres images à l'aide d'un fichier Dockerfile.

![Image Dockerfile https://www.data-transitionnumerique.com/](https://www.data-transitionnumerique.com/wp-content/uploads/2022/04/dockerfile-scaled.jpg)

## 🤓 Objectifs:

✅ Apprendre à créer, gérer et utiliser des images Docker à l'aide de Dockerfile.  
✅ Explorer les bonnes pratiques pour la construction des Dockerfiles.

## Sommaire

- [👉 Rappel sur les images et les layers](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#-rappel-sur-les-images-et-les-layers)
- [👉 Créer une image Docker](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#-cr%C3%A9er-une-image-docker)
- [👉 Le Dockerfile](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#-le-dockerfile)
	- [Qu'est-ce qu'un Dockerfile](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#quest-ce-quun-dockerfile)
		- [Structure d'un Dockerfile](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#structure-dun-dockerfile)
		- [Principales instructions Dockerfile](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#principales-instructions-dockerfile)
		- [Exemple de Dockerfile](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#exemple-de-dockerfile)
		- [Construire une image d'après le Dockerfile](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#construire-une-image-dapr%C3%A8s-le-dockerfile)
		- [Publier des images vers un registre](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#publier-des-images-vers-un-registre)
		- [Avantages de l'utilisation d'un Dockerfile](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#avantages-de-lutilisation-dun-dockerfile)
- [👉 Ton premier Dockerfile](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#-ton-premier-dockerfile)
- [👉 Quelques bonnes pratiques](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#-quelques-bonnes-pratiques)
- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/3021/pages/11394#-crit%C3%A8res-dacceptation)

## 👉 Rappel sur les images et les layers

Les images sont les éléments fondamentaux de l'écosystème Docker, servant de blocs de construction pour les conteneurs. Elles encapsulent l'ensemble des dépendances nécessaires à l'exécution d'une application, fournissant ainsi un environnement isolé et reproductible.

```shell
Si on compare une image Docker à une une boite qui contient tout ce dont ton application a besoin pour fonctionner, le Dockerfile est comme le plan détaillé nécessaire pour construire ta propre boite.

Chaque ligne de ce plan représente une instruction spécifique, allant de la sélection de la boîte de base à l'ajout des dernières touches personnalisées.
```

**Quelques commandes utiles:**

```shell
Images du Docker HubTélécharger un imageLister les images localesSupprimer une image du cache  localLister les images disponibles sur le Docker Hub : docker search <mot-clé>
1
wilder@docker1:~$ docker search ubuntu
2
NAME                             DESCRIPTION                                     STARS     OFFICIAL
3
ubuntu                           Ubuntu is a Debian-based Linux operating sys…   16978     [OK]
4
ubuntu-debootstrap               DEPRECATED; use "ubuntu" instead                52        [OK]
5
open-liberty                     Open Liberty multi-architecture images based…   64        [OK]
6
neurodebian                      NeuroDebian provides neuroscience research s…   107       [OK]
7
websphere-liberty                WebSphere Liberty multi-architecture images …   298       [OK]
8
ubuntu-upstart                   DEPRECATED, as is Upstart (find other proces…   115       [OK]
9
ubuntu/nginx                     Nginx, a high-performance reverse proxy & we…   112
10
ubuntu/squid                     Squid is a caching proxy for the Web. Long-t…   88
11
...
Tu verras une liste de résultats de recherche affichant le nom de l'image, une brève description, le nombre de stars (notations) et le nombre de pulls (téléchargements).
Tu peux aussi te rendre directement sur le Docker Hub avec ton navigateur et parcourir une vaste gamme d'images Docker.
```

## 👉 Créer une image Docker

L'une des pratiques les plus fondamentales et puissantes avec Docker est la capacité de créer tes propres images personnalisées.

Lorsque tu envisages de créer ta propre image Docker, tu as deux options principales:

- Transformer un conteneur existant en une image Docker
- Rédiger un fichier `Dockerfile` pour définir les étapes de construction de votre image.
```shell
Bien que la méthode basée sur le build d'une image à partir d'un conteneur soit simple et rapide, elle présente un gros inconvénient : elle ne fournit pas de trace claire des étapes de construction de l'image.

C'est pourquoi il est recommandé d'utiliser plutôt un fichier Dockerfile.
```

---

## 👉 Le Dockerfile

## Qu'est-ce qu'un Dockerfile

Un Dockerfile est un fichier texte simple qui contient une série d'instructions permettant de décrire les étapes nécessaires à la construction d'une image Docker. Il agit comme un script de construction pour générer automatiquement une image Docker complète et prête à être utilisée.

Tu pourrais partir de zéro pour construire une image ([from scratch](https://docs.docker.com/get-started/11_what_next/#creating-a-container-from-scratch)), mais généralement, tu te base sur une image déjà existante.

## Structure d'un Dockerfile

Un `Dockerfile` est composé d'un ensemble d'instructions, chaque instruction étant une étape distincte dans le processus de construction de l'image.  
Il est important de noter que chaque instruction est écrite en lettre majuscule, suivie de l'argument en minuscule.

Voici un exemple de structure typique d'un Dockerfile

```bash
1
# Syntaxe de commentaire : tout ce qui suit un '#' est ignoré  
2
# Étape 1 : Sélection de l'image de base 
3
FROM ubuntu:latest  
4
# Étape 2 : Mise à jour des packages et installation des dépendances 
5
RUN apt-get update && apt-get install -y package1 package2 package3  
6
# Étape 3 : Copie des fichiers de l'hôte dans l'image 
7
COPY /chemin/local /chemin/destination  
8
# Étape 4 : Exécution de commandes lors du lancement du conteneur 
9
CMD ["commande", "argument1", "argument2"]\`
```

## Principales instructions Dockerfile

- `FROM`: Spécifie l'image de base à utiliser pour construire l'image. Cette instruction est obligatoire et doit figurer en haut du Dockerfile.
- `RUN`: Exécute des commandes dans l'image en cours de construction. Ces commandes peuvent être des mises à jour du système, des installations de logiciels, etc.
- `COPY`: Copie des fichiers depuis l'hôte dans l'image. Utile pour inclure des fichiers de configuration, des scripts, etc.
- `CMD`: Définit la commande par défaut à exécuter lors du lancement du conteneur à partir de l'image. Il ne peut y avoir qu'une seule instruction CMD dans un Dockerfile, bien que tu puisses spécifier plusieurs arguments.

D'autres instructions comme `EXPOSE`, `WORKDIR`, `ENV`, `ENTRYPOINT`, etc., permettent de définir des ports à exposer, le répertoire de travail par défaut, des variables d'environnement, le programme de base avec lequel sera lancé la commande, etc.

```shell
Tu peux t'aider de la documentation officielle de Docker pour connaître les différentes directives utilisables dans un Dockerfile, d'ailleurs il est vivement recommandé de la parcourir ;)https://docs.docker.com/reference/dockerfile/
```

## Exemple de Dockerfile

Voici un exemple de Dockerfile pour créer une image Docker d'une base de données PostgreSQL:

```bash
1
# Utiliser l'image officielle PostgreSQL en tant qu'image de base 
2
FROM postgres:latest  
3
# Définir les variables d'environnement pour le nom de l'utilisateur PostgreSQL et le mot de passe 
4
ENV POSTGRES_USER myuser 
5
ENV POSTGRES_PASSWORD mypassword  
6
# Créer une base de données par défaut lors du démarrage du conteneur 
7
ENV POSTGRES_DB mydatabase  
8
# Exposer le port par défaut de PostgreSQL 
9
EXPOSE 5432
```

Dans cet exemple:

- On utilise l'image officielle de PostgreSQL comme image de base, avec la dernière version disponible.
- Nous définissons les variables d'environnement `POSTGRES_USER`, `POSTGRES_PASSWORD` et `POSTGRES_DB` pour spécifier le nom d'utilisateur, le mot de passe et le nom de la base de données à créer par défaut lors du démarrage du conteneur.
- Nous exposons le port par défaut de PostgreSQL, qui est 5432.
```shell
Ce Dockerfile serait utilisé pour construire une image Docker de PostgreSQL avec les configurations spécifiées. Tu peux ensuite utiliser cette image pour exécuter des conteneurs PostgreSQL avec les paramètres prédéfinis.
```

## Construire une image d'après le Dockerfile

Pour construire une image Docker à partir d'un Dockerfile, utilise la commande `docker build`.

Voici comment cela fonctionne

```shell
Step 1Assure toi que tu es dans le répertoire contenant ton Dockerfile.Étape suivante
Step 2
Step 3
```

Par exemple, pour le Dockerfile suivant:

```bash
1
wilder@docker1:~/mon_projet_docker$ cat Dockerfile
2
FROM ubuntu:latest
3
RUN apt update && apt install python3 -y
```

Voici la sortie que tu peux voir lors de la construction de l'image:

```bash
1
wilder@docker1:~/mon_projet_docker$ docker build -t mon_ubuntu_perso:V1.0 .
2
[+] Building 25.6s (6/6) FINISHED                                                                docker:default
3
 => [internal] load build definition from Dockerfile                                                       0.0s
4
 => => transferring dockerfile: 97B                                                                        0.0s
5
 => [internal] load metadata for docker.io/library/ubuntu:latest                                           0.0s
6
 => [internal] load .dockerignore                                                                          0.0s
7
 => => transferring context: 2B                                                                            0.0s
8
 => CACHED [1/2] FROM docker.io/library/ubuntu:latest                                                      0.0s
9
 => [2/2] RUN apt update && apt install python3 -y                                                        24.4s
10
 => exporting to image                                                                                     1.1s
11
 => => exporting layers                                                                                    1.1s
12
 => => writing image sha256:74a2de4928f861a5d8d83bb059343ce23bc117d983da3eab6ccd2cd34fe2e2a9               0.0s
13
 => => naming to docker.io/library/mon_ubuntu_perso:V1.0                                                   0.0s
```
```shell
Dans cet exemple, Docker construit une image à partir d'une image Ubuntu, met à jour le cache apt, installe Python3, et termine la construction de l'image avec succès.
```

Une fois que ton image est construite, tu peux la voir répertoriée en utilisant la commande `docker images`.

```bash
1
wilder@docker1:~/mon_projet_docker$ docker images
2
REPOSITORY            TAG       IMAGE ID       CREATED         SIZE
3
mon_ubuntu_perso      V1.0      74a2de4928f8   6 seconds ago   158MB
4
ubuntu                latest    ca2b0f26964c   5 weeks ago     77.9MB
```
```shell
As-tu remarqué la différence de taille entre l'image de base ubuntu et ton image mon_ubuntu_perso ?
Comment se fait-il que la différence soit si grande alors que nous avons seulement installé python3 ? (pour information, normalement la taille est de 23.5 MB pour python3 et ses dépendances)
Réponse : la première commande effectuée est apt update ,  les 56.6 MB supplémentaires représentent donc la mise à jour du cache apt.
On peut donc en conclure que l'image de base ubuntu n'embarque pas ce cache, ce qui est une bonne pratique de construction d'images !!!
```

## Publier des images vers un registre

Pour partager tes images Docker avec d'autres utilisateurs ou pour les utiliser sur d'autres systèmes, tu peux les publier vers un registre Docker.

```shell
Tu trouveras, en cliquant sur ce lien, un tuto pour publier une image sur Docker Hub.https://www.it-connect.fr/comment-publier-une-image-dockerfile-sur-le-referentiel-docker-hub/
```

## Avantages de l'utilisation d'un Dockerfile

- **Reproductibilité:** En utilisant un Dockerfile, tu peux garantir que chaque membre de ton équipe utilise la même configuration pour construire l'image, assurant ainsi la reproductibilité du processus.
- **Transparence:** Le Dockerfile agit comme une documentation vivante du processus de construction de l'image, offrant une transparence totale sur les étapes impliquées.
- **Flexibilité:** Tu peux facilement personnaliser le processus de construction en ajoutant, supprimant ou modifiant des instructions dans le Dockerfile pour répondre aux besoins spécifiques de ton application.

---

## 👉 Ton premier Dockerfile

Maintenant que nous avons couvert les bases, je te propose de créer ta première image Docker d'un serveur web Nginx. Cette image aura une page d'accueil personnalisée qui sera servie depuis l'hôte Docker.

On pourrait obtenir un conteneur fonctionnel qui répond à notre besoin en utilisant plusieurs commandes ad-hoc, en ayant pris soin préalablement de créer notre fichier à destination du serveur web nginx.

Les commandes pourraient ressembler à ceci:

```bash
1
# Vérification du contenu du fichier index.html de l'hôte :
2
wilder@docker1:~$ cat index.html
3
<h1>Bienvenue sur mon serveur Nginx !</h1>
4

5
# Création du conteneur :
6
wilder@docker1:~$ docker run -d -p 80:80 --name mon-nginx nginx:latest
7
ed78fb64ca1dec6ae66ffb26a8e66221d71f52f0ca3b259cea0e93a1c447e926
8

9
# Copie du fichier index.html de l'hôte vers le conteneur :
10
wilder@docker1:~$ docker cp index.html mon-nginx:/usr/share/nginx/html/index.html
```

Notre conteneur est bien fonctionnel et joignable sur le `port 80` de l'hôte:

```bash
1
wilder@docker1:~$ docker ps
2
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                               NAMES
3
ed78fb64ca1d   nginx:latest   "/docker-entrypoint.…"   9 seconds ago   Up 8 seconds   0.0.0.0:80->80/tcp, :::80->80/tcp   mon-nginx
4

5
wilder@docker1:~$ curl 127.0.0.1:80
6
<h1>Bienvenue sur mon serveur Nginx !</h1>
```

Ces commandes ad-hoc permettent d'arriver à un résultat similaire à ce que l'on souhaite faire, sauf que l'on dispose d'un conteneur, et non pas d'une image.

Nous allons réaliser une image qui réponde à notre besoin.

On peut découper les commandes `ad-hoc` précédentes en différentes instructions:

- L'image de base utilisée: `nginx:latest`
- La copie du fichier `index.html` de l'hôte vers le conteneur
- L'exposition du `port 80` du conteneur sur le `port 80` de l'hôte Docker

Avant de commencer à écrire ton Dockerfile, tu dois organiser ton projet et créer un dossier dédié pour ton application Docker.

```bash
1
wilder@docker1:~$ mkdir mon_projet_docker
2
wilder@docker1:~$ cd mon_projet_docker
3
wilder@docker1:~/mon_projet_docker$ touch Dockerfile
```

Tu devras aussi créer le fichier `index.html` à l'intérieur de ton dossier de projet.

```bash
1
wilder@docker1:~/mon_projet_docker$ cat index.html
2
<h1>Bienvenue sur mon serveur Nginx cree a partir de mon image !!!!</h1>
```

La structure de ton dossier ressemblera à ceci:

```bash
1
wilder@docker1:~$ tree
2
.
3
├── mon_projet_docker
4
    └── Dockerfile
5
    └── index.html
```

Tu es maintenant prêt à commencer à rédiger les instructions de ton Dockerfile pour définir le processus de construction de ton image Docker.

Tu peux ouvrir le fichier Dockerfile dans ton éditeur de texte et commencer à écrire tes instructions Docker.

```bash
1
wilder@docker1:~/mon_projet_docker$ nano Dockerfile
```
```bash
Step 1 - FROMUtilisation de l'image officielle Nginx
1
FROM nginx:latestÉtape suivante
Step 2 - COPY
Step 3
```

Notre fichier Dockerfile:

```bash
1
# Utilisation de l'image officielle Nginx
2
FROM nginx:latest
3

4
# Copie du fichier index.html local vers le répertoire de configuration Nginx dans l'image
5
COPY index.html /usr/share/nginx/html
6

7
# Exposer le port 80 pour le trafic web
8
EXPOSE 80
```

Il ne nous reste plus qu'a créer notre image:

```bash
1
# Build de notre image :
2
wilder@docker1:~/mon_projet_docker$ docker build -t mon-nginx:v1.0 .
3
[+] Building 0.1s (7/7) FINISHED                                                                                                                docker:default
4
 => [internal] load build definition from Dockerfile                                                                                                      0.0s
5
 => => transferring dockerfile: 282B                                                                                                                      0.0s
6
 => [internal] load metadata for docker.io/library/nginx:latest                                                                                           0.0s
7
 => [internal] load .dockerignore                                                                                                                         0.0s
8
 => => transferring context: 2B                                                                                                                           0.0s
9
 => [internal] load build context                                                                                                                         0.0s
10
 => => transferring context: 495B                                                                                                                         0.0s
11
 => [1/2] FROM docker.io/library/nginx:latest                                                                                                             0.0s
12
 => [2/2] COPY index.html /usr/share/nginx/html                                                                                                           0.0s
13
 => exporting to image                                                                                                                                    0.0s
14
 => => exporting layers                                                                                                                                   0.0s
15
 => => writing image sha256:b160a8d1a401f7fbaff10daa3dc06ea44a0945ce0372ead5b8432bde24523e44                                                              0.0s
16
 => => naming to docker.io/library/mon-nginx:v1.0                                                                                                         0.0s
17

18
# Vérification de notre image :
19
wilder@docker1:~/mon_projet_docker$ docker images
20
REPOSITORY            TAG       IMAGE ID       CREATED         SIZE
21
mon-nginx             v1.0      b160a8d1a401   6 minutes ago   187MB
```
```shell
Fais bien attention à renseigner le contexte lors du build de l'image, ici représenté par un . à la fin de la commande build .
```

Nous allons créér un conteneur à partir de notre image et vérifier la page d'accueil du serveur nginx:

```bash
1
wilder@docker1:~/mon_projet_docker$ docker run -d --name my-nginx  -p 80:80 mon-nginx:v1.0
2
17ed6a61677f56f97bbf1391657e99cb6f64fb3a255966b5dc88268835cbb851
3

4
wilder@docker1:~/mon_projet_docker$ docker ps
5
CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS         PORTS                               NAMES
6
17ed6a61677f   mon-nginx:v1.0   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   0.0.0.0:80->80/tcp, :::80->80/tcp   my-nginx
7

8
wilder@docker1:~/mon_projet_docker$ curl 127.0.0.1:80
9
<h1>Bienvenue sur mon serveur Nginx créé à partir de mon image !!!!</h1>
```

**Parfait, tout fonctionne comme prévu** 👍

---

## 👉 Quelques bonnes pratiques

Avant de clôturer cette quête, voici quelques bonnes pratiques à garder à l'esprit lors de la création d'images Docker et de la rédaction de tes Dockerfile:

1. **Minimiser la taille de l'image:** Essaye de réduire autant que possible la taille de tes images Docker. Utilise des images de base légères comme Alpine Linux et évite d'inclure des éléments inutiles dans ton conteneur.
2. **Utiliser des images de base appropriées:** Choisis des images de base adaptées à ton application. Par exemple, si tu développes une application Node.js, utilise une image Node.js officielle comme base.
3. **Diviser les commandes RUN:** Lorsque tu utilises la commande RUN dans ton Dockerfile, regroupe les commandes similaires en une seule instruction pour réduire le nombre de couches dans l'image finale.

Par exemple, au lieu d'écrire plusieurs commandes RUN séparées pour installer des packages et nettoyer les caches dans un Dockerfile, tu peux les combiner en une seule commande RUN. Cela permet d'éviter la création de couches supplémentaires dans l'image Docker pour chaque commande individuelle, ce qui contribue à réduire la taille de l'image finale.

Exemple:

```bash
1
# Mauvaise pratique : commandes RUN séparées
2
RUN apt-get update 
3
RUN apt-get install -y package1 package2 
4
RUN apt-get clean  
5

6
# Bonne pratique : commandes RUN combinées 
7
RUN apt-get update && apt-get install -y package1 package2 && apt-get clean
```
1. **Éviter les secrets dans le Dockerfile:** Ne stocke pas de secrets sensibles tels que les mots de passe ou les clés d'API directement dans ton Dockerfile!!! Utilise plutôt des variables d'environnement ou des volumes secrets pour fournir ces informations de manière sécurisée.
2. **Nettoyer les dépendances inutiles:** Assure toi de supprimer les dépendances inutiles et les fichiers temporaires après l'installation des packages et la construction de ton application dans le Dockerfile. Cela permet de réduire la taille de l'image finale.
```bash
1
# Supprimer les caches de package :
2
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
3
# Supprimer les fichiers temporaires :
4
RUN rm -rf /tmp/*
5
# Supprimer les logs :
6
RUN rm -rf /var/log/*
7
# Supprimer les caches de langage
8
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* \ /var/cache/apt/archives/* /tmp/* /var/tmp/*
```
1. **Utiliser.dockerignore:** Crée un fichier.dockerignore pour exclure les fichiers et répertoires non pertinents lors de la construction de l'image. Cela permet d'accélérer le processus de construction et de réduire la taille de l'image.  
	Le fichier `.dockerignore` est utilisé pour spécifier les fichiers et répertoires à exclure lors de la construction de l'image Docker. Il fonctionne de manière similaire à un fichier `.gitignore` dans un projet Git, mais au lieu de spécifier les fichiers à ignorer lors de la création d'un dépôt Git, il spécifie les fichiers à ignorer lors de la construction de l'image Docker.

Voici un exemple simple de contenu d'un fichier `.dockerignore`:

```bash
1
# Ignorer les fichiers et répertoires spécifiques
2
*secret*  
3
.git 
4
*.log  
5
# Ignorer tous les fichiers d'un type spécifique 
6
*.tmp  
7
# Ignorer tous les fichiers dans un répertoire spécifique 
8
logs/
```
1. **Configurer correctement les variables d'environnement:** Utilise des variables d'environnement pour configurer dynamiquement ton application. Cela rend ton image plus flexible et portable entre différents environnements et facilite le déploiement et la configuration de ton application pour les nouveaux utilisateurs ou les membres de l'équipe.

---

## 📝 Quiz

```shell
# 1  - Quelle commande Docker permet de lister les images téléchargées localement ?docker listdocker imagesdocker searchdocker pullValider# 2 docker remove <image>docker delete <image>docker rmi <image>docker erase <image>Valider# 3 Un format de fichier pour stocker des images DockerUn fichier de configuration pour construire une image DockerUn fichier de documentation pour les projets DockerUn fichier de sauvegarde pour les conteneurs DockerValider# 4 Il permet de lancer des conteneurs DockerIl permet de lister les images disponibles sur le Docker HubIl permet de créer des images Docker personnalisées en décrivant les étapes de constructionIl permet de rechercher des images sur le Docker HubValider# 5 RUNCOPYCMDEXPOSEValider# 6 RUNCOPYCMDEXPOSEValider# 7 docker startdocker rundocker createdocker buildValider# 8 Avec l'option -versionAvec l'option -tagAvec l'option -vAvec l'option -tValider# 9 Parce que cela garantit une trace claire des étapes de construction de l'imageParce que cela rend le processus de construction plus rapideParce que cela garantit que les images seront toujours à jourParce que cela rend les images plus légèresValider# 10 Utiliser des machines virtuelles au lieu de conteneursRegrouper plusieurs applications dans une seule imageUtiliser des images de base légères comme Alpine LinuxValiderTon score :0 / 10
```

---

## 💪 Challenge

Dans ce challenge, tu devras mettre en application certains concepts abordés dans cette quête.

**Objectif:**  
Créer une image Docker contenant un script qui affiche "Hello Wilder from container \[nom du container\]" lorsqu'un conteneur basé sur cette image est lancé.

```shell
🎯 Tu publieras ton image sur le DockerHub et fournira un lien vers cette image comme solution au challenge.
```

**Instructions:**

1. Crée un script sur ton hôte Docker nommé `hello_wilder.sh` qui affiche "Hello Wilder from container \[nom du container\]". Assure toi que ce script est exécutable et que \[nom du container\] se rapporte à une variable capable de récupérer le nom du conteneur.
2. Crée un Dockerfile et alimente-le pour répondre à la demande:
	- Image de base
		- Copie du script
		- Commande par défaut qui lance le script `hello_wilder.sh`
3. Construit ton image personnalisée.
4. Teste ton image en instanciant un conteneur basé sur ton image.
5. Optimise ton image: explore les différents moyens qui permettent de réduire ton image sans compromettre sa fonctionnalité.
6. Poste ton image sur le [Docker Hub](https://hub.docker.com/)

**Conseils:**

Explore la documentation Docker pour en savoir plus sur les meilleures pratiques en matière de création d'images Docker optimisées.  
N'hésite pas à expérimenter et à rechercher des solutions en ligne si tu rencontres des difficultés.

## 🧐 Critères d'acceptation

- L'image Docker est construite avec succès et répond à la demande
- La taille de l'image est minimisée autant que possible

Solution postée le **mercredi 31 décembre 2025**

[https://hub.docker.com/r/liudswen/hello-world/tags](https://hub.docker.com/r/liudswen/hello-world/tags)