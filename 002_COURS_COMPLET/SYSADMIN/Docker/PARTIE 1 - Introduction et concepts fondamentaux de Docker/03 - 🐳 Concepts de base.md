

## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 2 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## 🖼️ Image Docker

### Qu'est-ce qu'une image Docker ?

Une **image Docker** est un modèle immuable, en lecture seule, qui contient tout le nécessaire pour exécuter une application : le code, les dépendances, les bibliothèques, les outils système et les fichiers de configuration. C'est comme un "snapshot" complet d'un système de fichiers avec des métadonnées sur la façon de l'exécuter.

> [!info] Analogie Pensez à une image Docker comme un moule à gâteau : c'est un modèle réutilisable qui permet de créer autant de gâteaux (conteneurs) identiques que vous le souhaitez.

### Architecture en couches (Layers)

Les images Docker sont construites selon une architecture en **couches superposées**. Chaque couche représente une instruction du Dockerfile et est immuable une fois créée.

```
┌─────────────────────────────┐
│  Couche App (votre code)    │ ← Couche la plus récente
├─────────────────────────────┤
│  Couche npm install         │
├─────────────────────────────┤
│  Couche Node.js             │
├─────────────────────────────┤
│  Couche OS de base (Ubuntu) │ ← Couche de base
└─────────────────────────────┘
```

> [!tip] Avantage du système de couches
> 
> - **Réutilisation** : Si deux images partagent les mêmes couches de base, elles ne sont stockées qu'une seule fois
> - **Efficacité** : Seules les couches modifiées sont téléchargées ou envoyées
> - **Cache** : Docker met en cache chaque couche pour accélérer les builds

### Commandes essentielles pour les images

#### Lister les images locales

```bash
# Liste toutes les images sur votre machine
docker images

# Affichage avec plus de détails
docker images --all

# Format personnalisé
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

#### Télécharger une image depuis un registry

```bash
# Télécharge la dernière version (tag 'latest' par défaut)
docker pull nginx

# Télécharge une version spécifique
docker pull nginx:1.25

# Télécharge depuis un registry privé
docker pull myregistry.com/myapp:v1.0
```

#### Supprimer une image

```bash
# Supprime une image spécifique
docker rmi nginx:1.25

# Supprime par ID (les 3 premiers caractères suffisent généralement)
docker rmi abc123

# Force la suppression même si des conteneurs l'utilisent
docker rmi -f nginx

# Supprime toutes les images non utilisées
docker image prune -a
```

#### Inspecter une image

```bash
# Affiche les détails complets de l'image en JSON
docker inspect nginx

# Affiche l'historique des couches
docker history nginx

# Voir uniquement certaines informations
docker inspect --format='{{.Architecture}}' nginx
```

#### Créer une image depuis un conteneur (méthode déconseillée)

```bash
# Sauvegarde l'état actuel d'un conteneur en image
docker commit mon-conteneur mon-image:v1

# Avec un message et un auteur
docker commit -m "Ajout de configuration" -a "John Doe" mon-conteneur mon-image:v1
```

> [!warning] Bonne pratique Utilisez toujours un `Dockerfile` pour créer vos images plutôt que `docker commit`. C'est reproductible, versionnable et documenté.

### Tags d'images

Le **tag** est un identifiant qui permet de différencier les versions d'une même image.

```bash
# Syntaxe complète d'une image
[registry]/[namespace]/[repository]:[tag]

# Exemples
docker.io/library/nginx:latest          # Image officielle
docker.io/myusername/myapp:v1.0         # Image personnelle
myregistry.com/team/backend:prod        # Registry privé
```

|Composant|Description|Exemple|
|---|---|---|
|`registry`|Serveur hébergeant les images|`docker.io`, `gcr.io`|
|`namespace`|Utilisateur ou organisation|`library`, `myusername`|
|`repository`|Nom de l'application|`nginx`, `myapp`|
|`tag`|Version ou variante|`latest`, `1.25`, `alpine`|

> [!tip] Convention de nommage des tags
> 
> - `latest` : Dernière version stable (par défaut)
> - `X.Y.Z` : Version sémantique précise (ex: `3.11.4`)
> - `X.Y` : Version majeure.mineure (ex: `3.11`)
> - `alpine` : Variante légère basée sur Alpine Linux
> - `slim` : Variante allégée
> - `dev`, `staging`, `prod` : Environnements

### Tagguer et renommer une image

```bash
# Créer un nouveau tag pour une image existante
docker tag nginx:latest mon-nginx:v1

# Tagguer pour pousser vers un registry
docker tag myapp:latest myregistry.com/myapp:v1.0

# Une image peut avoir plusieurs tags
docker tag myapp:v1.0 myapp:latest
docker tag myapp:v1.0 myapp:stable
```

### Sauvegarder et charger des images

```bash
# Exporter une image vers un fichier tar
docker save -o mon-image.tar nginx:latest

# Exporter plusieurs images
docker save -o mes-images.tar nginx:latest redis:alpine

# Importer une image depuis un fichier tar
docker load -i mon-image.tar

# Importer avec affichage détaillé
docker load --input mon-image.tar
```

> [!example] Cas d'usage Utile pour transférer des images vers des environnements sans accès internet ou pour des backups.

### Pièges courants

> [!warning] Attention aux tags 'latest' Le tag `latest` ne signifie pas toujours "la plus récente version". C'est simplement le tag par défaut. Toujours spécifier une version précise en production.

```bash
# ❌ Risqué en production
docker pull nginx

# ✅ Recommandé en production
docker pull nginx:1.25.3
```

> [!warning] Taille des images Les images peuvent devenir très volumineuses si vous n'êtes pas vigilant. Une image Ubuntu de base fait ~70MB, mais peut facilement dépasser 1GB avec des dépendances mal gérées.

### Astuces avancées

```bash
# Rechercher des images sur Docker Hub
docker search nginx

# Filtrer par nombre d'étoiles (minimum 100)
docker search --filter stars=100 nginx

# Voir l'espace disque utilisé par les images
docker system df

# Nettoyer toutes les images non utilisées et libérer de l'espace
docker system prune -a --volumes
```

---

## 📦 Conteneur

### Qu'est-ce qu'un conteneur Docker ?

Un **conteneur** est une instance exécutable d'une image Docker. C'est un processus isolé qui s'exécute sur votre système d'exploitation hôte, avec son propre système de fichiers, son propre réseau et ses propres ressources.

> [!info] Analogie Si l'image est le moule, le conteneur est le gâteau qui en sort. Vous pouvez créer plusieurs conteneurs identiques à partir de la même image, et chacun vivra sa propre vie indépendamment.

### Conteneur vs Machine Virtuelle

|Aspect|Conteneur|Machine Virtuelle|
|---|---|---|
|**Démarrage**|Quelques secondes|Plusieurs minutes|
|**Taille**|Mo (partage le kernel)|Go (OS complet)|
|**Performance**|Quasi-native|Overhead de virtualisation|
|**Isolation**|Processus isolé|Isolation complète matériel|
|**Portabilité**|Très élevée|Moyenne|
|**Densité**|Centaines par hôte|Dizaines par hôte|

### Cycle de vie d'un conteneur

```
Créé → Démarré → En cours d'exécution → Arrêté → Supprimé
  ↓        ↓              ↓                ↓          ↓
Created  Running        Running          Exited    Removed
```

### Commandes essentielles pour les conteneurs

#### Créer et démarrer un conteneur

```bash
# Démarre un conteneur et se détache immédiatement (-d pour detached)
docker run -d nginx

# Avec un nom personnalisé
docker run -d --name mon-nginx nginx

# Avec mapping de port (port hôte:port conteneur)
docker run -d -p 8080:80 nginx

# Avec variables d'environnement
docker run -d -e "ENV=production" -e "DEBUG=false" nginx

# Avec volume pour persister les données
docker run -d -v /mon/chemin:/usr/share/nginx/html nginx

# Mode interactif avec terminal (-it)
docker run -it ubuntu bash

# Suppression automatique après arrêt (--rm)
docker run --rm -it ubuntu bash
```

> [!tip] Options courantes de docker run
> 
> - `-d` : Détaché (en arrière-plan)
> - `-it` : Interactif avec terminal
> - `-p` : Mapping de ports
> - `-v` : Montage de volumes
> - `-e` : Variables d'environnement
> - `--name` : Nom du conteneur
> - `--rm` : Suppression auto après arrêt
> - `--network` : Réseau à utiliser
> - `--restart` : Politique de redémarrage

#### Lister les conteneurs

```bash
# Liste les conteneurs en cours d'exécution
docker ps

# Liste tous les conteneurs (même arrêtés)
docker ps -a

# Affichage compact (seulement les IDs)
docker ps -q

# Format personnalisé
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Filtrer par statut
docker ps -a --filter status=exited
```

#### Gérer l'état des conteneurs

```bash
# Démarrer un conteneur arrêté
docker start mon-conteneur

# Arrêter un conteneur en cours (SIGTERM puis SIGKILL après 10s)
docker stop mon-conteneur

# Arrêt immédiat (SIGKILL)
docker kill mon-conteneur

# Redémarrer un conteneur
docker restart mon-conteneur

# Mettre en pause (gèle tous les processus)
docker pause mon-conteneur

# Reprendre
docker unpause mon-conteneur
```

#### Interagir avec un conteneur

```bash
# Exécuter une commande dans un conteneur en cours
docker exec mon-conteneur ls /app

# Ouvrir un shell interactif dans un conteneur
docker exec -it mon-conteneur bash

# Ou avec sh si bash n'est pas disponible (Alpine Linux)
docker exec -it mon-conteneur sh

# Exécuter une commande en tant qu'utilisateur spécifique
docker exec -u root mon-conteneur apt update

# Voir les logs d'un conteneur
docker logs mon-conteneur

# Suivre les logs en temps réel (-f pour follow)
docker logs -f mon-conteneur

# Limiter aux 100 dernières lignes
docker logs --tail 100 mon-conteneur

# Avec horodatage
docker logs -t mon-conteneur
```

#### Inspecter un conteneur

```bash
# Détails complets en JSON
docker inspect mon-conteneur

# Informations spécifiques avec Go template
docker inspect --format='{{.NetworkSettings.IPAddress}}' mon-conteneur

# Statistiques en temps réel (CPU, RAM, réseau, I/O)
docker stats mon-conteneur

# Stats pour tous les conteneurs
docker stats

# Processus en cours dans le conteneur
docker top mon-conteneur

# Changements du système de fichiers
docker diff mon-conteneur
```

#### Copier des fichiers

```bash
# Copier depuis l'hôte vers le conteneur
docker cp /mon/fichier.txt mon-conteneur:/app/

# Copier depuis le conteneur vers l'hôte
docker cp mon-conteneur:/app/logs.txt /tmp/

# Copier un dossier complet
docker cp mon-conteneur:/var/log /tmp/logs-backup
```

#### Supprimer des conteneurs

```bash
# Supprimer un conteneur arrêté
docker rm mon-conteneur

# Forcer la suppression même s'il est en cours
docker rm -f mon-conteneur

# Supprimer plusieurs conteneurs
docker rm conteneur1 conteneur2 conteneur3

# Supprimer tous les conteneurs arrêtés
docker container prune

# Supprimer tous les conteneurs (même en cours)
docker rm -f $(docker ps -aq)
```

### États d'un conteneur

Un conteneur peut être dans plusieurs états :

|État|Description|Commande|
|---|---|---|
|`created`|Créé mais pas démarré|`docker create`|
|`running`|En cours d'exécution|`docker start`|
|`paused`|Gelé temporairement|`docker pause`|
|`restarting`|En cours de redémarrage|Automatique|
|`exited`|Arrêté|`docker stop`|
|`dead`|Erreur système|N/A|

### Politique de redémarrage

Les conteneurs peuvent être configurés pour redémarrer automatiquement selon différentes stratégies :

```bash
# Jamais redémarrer (par défaut)
docker run -d --restart no nginx

# Toujours redémarrer (même après reboot de l'hôte)
docker run -d --restart always nginx

# Redémarrer sauf si arrêté manuellement
docker run -d --restart unless-stopped nginx

# Redémarrer uniquement en cas d'erreur (max 5 tentatives)
docker run -d --restart on-failure:5 nginx
```

> [!tip] Recommandation pour la production Utilisez `unless-stopped` pour vos services en production. Cela permet de redémarrer automatiquement après un crash, mais respecte les arrêts manuels.

### Limiter les ressources

```bash
# Limiter la mémoire (256MB)
docker run -d -m 256m nginx

# Limiter le CPU (50% d'un core)
docker run -d --cpus="0.5" nginx

# Priorité CPU (valeur relative, par défaut 1024)
docker run -d --cpu-shares=512 nginx

# Combinaison de limites
docker run -d -m 512m --cpus="1.0" --name app nginx
```

> [!warning] Monitoring des ressources Surveillez toujours la consommation avec `docker stats` pour éviter que des conteneurs monopolisent les ressources de l'hôte.

### Réseau des conteneurs

```bash
# Lister les réseaux disponibles
docker network ls

# Créer un réseau personnalisé
docker network create mon-reseau

# Connecter un conteneur à un réseau
docker run -d --network mon-reseau --name app1 nginx

# Inspecter un réseau
docker network inspect mon-reseau

# Connecter un conteneur existant
docker network connect mon-reseau mon-conteneur

# Déconnecter
docker network disconnect mon-reseau mon-conteneur
```

### Pièges courants

> [!warning] Données perdues à l'arrêt Par défaut, toutes les modifications dans un conteneur sont perdues quand il est supprimé. Utilisez des **volumes** pour persister les données importantes.

```bash
# ❌ Données perdues
docker run -d --name db mysql

# ✅ Données persistées
docker run -d --name db -v mysql-data:/var/lib/mysql mysql
```

> [!warning] Port déjà utilisé Si vous obtenez une erreur "port is already allocated", c'est qu'un autre service utilise déjà ce port sur votre hôte.

```bash
# Vérifier quel processus utilise le port 8080
netstat -tulpn | grep 8080   # Linux
lsof -i :8080                # macOS

# Utiliser un autre port hôte
docker run -d -p 8081:80 nginx
```

> [!warning] Conteneur qui se termine immédiatement Un conteneur s'arrête dès que son processus principal se termine. Assurez-vous que l'application reste en premier plan.

```bash
# ❌ Se termine immédiatement
docker run ubuntu echo "Hello"

# ✅ Reste actif
docker run -d nginx  # nginx tourne en premier plan dans le conteneur
```

### Astuces avancées

```bash
# Attacher votre terminal à un conteneur en cours
docker attach mon-conteneur

# Envoyer un signal spécifique
docker kill --signal=SIGHUP mon-conteneur

# Exporter le système de fichiers d'un conteneur
docker export mon-conteneur > backup.tar

# Créer un conteneur sans le démarrer
docker create --name mon-conteneur nginx

# Renommer un conteneur
docker rename ancien-nom nouveau-nom

# Afficher les événements Docker en temps réel
docker events

# Mettre à jour la configuration d'un conteneur en cours
docker update --memory 512m --cpus 2 mon-conteneur
```

---

## 📝 Dockerfile

### Qu'est-ce qu'un Dockerfile ?

Un **Dockerfile** est un fichier texte contenant une série d'instructions qui définissent comment construire une image Docker. C'est le blueprint de votre image, permettant une construction automatisée, reproductible et versionnée.

> [!info] Pourquoi utiliser un Dockerfile ?
> 
> - **Reproductibilité** : Même image à chaque build
> - **Versionning** : Historique complet dans Git
> - **Documentation** : Le Dockerfile explique comment l'image est construite
> - **Automatisation** : Intégration dans des pipelines CI/CD

### Structure d'un Dockerfile

```dockerfile
# Commentaire : Image de base
FROM node:18-alpine

# Métadonnées
LABEL maintainer="dev@example.com"
LABEL version="1.0"

# Variables d'environnement
ENV NODE_ENV=production
ENV PORT=3000

# Répertoire de travail
WORKDIR /app

# Copie des fichiers
COPY package*.json ./

# Exécution de commandes
RUN npm ci --only=production

# Copie du code source
COPY . .

# Exposition de port (documentation)
EXPOSE 3000

# Utilisateur non-root pour la sécurité
USER node

# Commande par défaut
CMD ["node", "server.js"]
```

### Instructions principales du Dockerfile

#### FROM - Image de base

Définit l'image de départ pour votre build. C'est toujours la première instruction (sauf pour les arguments ARG globaux).

```dockerfile
# Image officielle depuis Docker Hub
FROM ubuntu:22.04

# Image avec tag spécifique
FROM node:18.17.0-alpine

# Image depuis un registry privé
FROM myregistry.com/baseimage:latest

# Multi-stage build (plusieurs FROM dans un même Dockerfile)
FROM node:18 AS builder
# ... instructions de build ...
FROM node:18-alpine AS production
# ... copie depuis l'étape builder ...
```

> [!tip] Choisir la bonne image de base
> 
> - Préférez les images **officielles** et **vérifiées**
> - Utilisez les variantes **alpine** pour la légèreté (5-10x plus petites)
> - Spécifiez toujours une **version précise** en production
> - Vérifiez les vulnérabilités avec `docker scan`

#### WORKDIR - Répertoire de travail

Définit le répertoire de travail pour toutes les instructions suivantes (RUN, CMD, COPY, etc.).

```dockerfile
# Change le répertoire courant
WORKDIR /app

# Crée le répertoire s'il n'existe pas
WORKDIR /usr/src/app

# Chemins relatifs possibles
WORKDIR /app
WORKDIR backend    # Devient /app/backend
```

> [!warning] Ne pas utiliser cd N'utilisez jamais `RUN cd /app` car l'effet ne persiste pas entre les instructions. Utilisez toujours `WORKDIR`.

```dockerfile
# ❌ Mauvaise pratique
RUN cd /app
RUN npm install  # Exécuté à la racine !

# ✅ Bonne pratique
WORKDIR /app
RUN npm install
```

#### COPY et ADD - Copier des fichiers

Copient des fichiers depuis l'hôte vers l'image.

```dockerfile
# Copie simple
COPY package.json /app/

# Copie multiple
COPY package.json package-lock.json /app/

# Copie avec wildcard
COPY *.json /app/

# Copie d'un dossier complet
COPY src/ /app/src/

# Copie avec renommage
COPY config.dev.json /app/config.json

# Préserver la structure
COPY . .

# Avec --chown (change le propriétaire)
COPY --chown=node:node . /app
```

**ADD** est similaire à COPY mais avec des fonctionnalités supplémentaires :

```dockerfile
# Décompresse automatiquement les archives tar
ADD archive.tar.gz /app/

# Télécharge depuis une URL (déconseillé)
ADD https://example.com/file.txt /app/

# Pour tout le reste, utilisez COPY
COPY package.json /app/
```

> [!warning] Préférez COPY à ADD Utilisez `COPY` sauf si vous avez spécifiquement besoin de la décompression automatique. `ADD` peut avoir des comportements inattendus avec les URLs.

#### RUN - Exécuter des commandes

Exécute des commandes pendant le build et crée une nouvelle couche.

```dockerfile
# Forme shell (exécuté dans /bin/sh -c)
RUN apt-get update && apt-get install -y python3

# Forme exec (pas d'interprétation shell)
RUN ["apt-get", "install", "-y", "python3"]

# Commandes multiples pour réduire les couches
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        git \
    && rm -rf /var/lib/apt/lists/*

# Avec continuation de ligne
RUN npm install \
    && npm run build \
    && npm cache clean --force
```

> [!tip] Optimisation des couches RUN Combinez les commandes liées avec `&&` pour créer moins de couches et réduire la taille de l'image.

```dockerfile
# ❌ Crée 3 couches (moins efficace)
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# ✅ Crée 1 couche (plus efficace)
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*
```

#### ENV - Variables d'environnement

Définit des variables d'environnement disponibles au build et au runtime.

```dockerfile
# Syntaxe simple
ENV NODE_ENV production

# Syntaxe multiple
ENV NODE_ENV=production \
    PORT=3000 \
    LOG_LEVEL=info

# Utilisation dans d'autres instructions
ENV APP_DIR=/app
WORKDIR ${APP_DIR}
COPY . ${APP_DIR}
```

> [!info] ENV vs ARG
> 
> - `ENV` : Disponible au build ET au runtime
> - `ARG` : Disponible UNIQUEMENT au build

#### ARG - Arguments de build

Définit des variables utilisables uniquement pendant le build, pouvant être passées avec `--build-arg`.

```dockerfile
# Déclaration avec valeur par défaut
ARG NODE_VERSION=18
ARG BUILD_DATE

# Utilisation
FROM node:${NODE_VERSION}-alpine

# Disponible uniquement au build
RUN echo "Built on ${BUILD_DATE}"
```

```bash
# Passage d'arguments lors du build
docker build --build-arg NODE_VERSION=20 --build-arg BUILD_DATE=$(date) .
```

> [!tip] Ordre ARG/FROM Les ARG avant FROM sont globaux et peuvent être utilisés dans FROM. Les ARG après FROM sont spécifiques à cette stage.

```dockerfile
# ARG global
ARG BASE_IMAGE=node:18

# Utilisable dans FROM
FROM ${BASE_IMAGE}

# ARG spécifique à cette image
ARG APP_VERSION=1.0
```

#### EXPOSE - Documentation de ports

Documente quels ports l'application écoute. C'est informatif, pas une vraie ouverture de port.

```dockerfile
# Port unique
EXPOSE 3000

# Multiples ports
EXPOSE 3000 8080

# Avec protocole
EXPOSE 3000/tcp
EXPOSE 53/udp
```

> [!warning] EXPOSE ne publie pas les ports `EXPOSE` est uniquement de la documentation. Pour publier réellement les ports, utilisez `-p` lors du `docker run`.

```bash
# Malgré EXPOSE 3000 dans le Dockerfile
docker run -d -p 8080:3000 mon-app  # Nécessaire pour accès externe
```

#### USER - Utilisateur d'exécution

Définit l'utilisateur (et groupe) pour les instructions RUN, CMD et ENTRYPOINT suivantes.

```dockerfile
# Basculer vers un utilisateur non-root
USER node

# Avec groupe
USER node:node

# Avec UID:GID
USER 1000:1000

# Créer un utilisateur au préalable
RUN useradd -m -u 1000 appuser
USER appuser
```

> [!tip] Sécurité : toujours utiliser USER Pour des raisons de sécurité, évitez d'exécuter votre application en tant que root. Basculez vers un utilisateur non-privilégié.

```dockerfile
# ❌ Risque de sécurité
FROM node:18
COPY . /app
CMD ["node", "server.js"]  # S'exécute en root !

# ✅ Sécurisé
FROM node:18
COPY --chown=node:node . /app
USER node
CMD ["node", "server.js"]  # S'exécute en tant que 'node'
```

#### CMD - Commande par défaut

Définit la commande par défaut exécutée au démarrage du conteneur. Peut être surchargée par `docker run`.

```dockerfile
# Forme exec (recommandée)
CMD ["node", "server.js"]

# Forme shell (lance un shell)
CMD node server.js

# Avec des paramètres
CMD ["npm", "start"]

# Valeur par défaut pour ENTRYPOINT
CMD ["--help"]
```

> [!info] Un seul CMD S'il y a plusieurs CMD dans un Dockerfile, seul le dernier est pris en compte.

#### ENTRYPOINT - Point d'entrée

Définit l'exécutable principal du conteneur. Ne peut pas être surchargé facilement (sauf avec `--entrypoint`).

```dockerfile
# Forme exec
ENTRYPOINT ["python", "app.py"]

# Combiné avec CMD pour des arguments par défaut
ENTRYPOINT ["python", "app.py"]
CMD ["--port", "8000"]
```

```bash
# Avec l'exemple ci-dessus
docker run mon-app                    # Lance : python app.py --port 8000
docker run mon-app --port 9000        # Lance : python app.py --port 9000
```

> [!info] ENTRYPOINT vs CMD
> 
> - `ENTRYPOINT` : Commande principale, difficile à surcharger
> - `CMD` : Arguments par défaut, faciles à surcharger
> - **Combinaison** : ENTRYPOINT + CMD = commande flexible

```dockerfile
# Pattern recommandé pour une CLI
ENTRYPOINT ["myapp"]
CMD ["--help"]

# docker run mon-app           → myapp --help
# docker run mon-app version   → myapp version
```

#### VOLUME - Points de montage

Déclare des points de montage pour la persistance des données.

```dockerfile
# Volume unique
VOLUME /data

# Volumes multiples
VOLUME ["/var/log", "/var/db"]

# Avec chemin absolu
VOLUME /app/uploads
```

> [!warning] VOLUME crée des volumes anonymes `VOLUME` dans le Dockerfile crée un volume anonyme par défaut. Préférez déclarer les volumes explicitement au runtime avec `-v`.

```bash
# Volume nommé (recommandé)
docker run -v mes-donnees:/data mon-app

# Volume anonyme (créé automatiquement par VOLUME)
docker run mon-app
```

#### LABEL - Métadonnées

Ajoute des métadonnées à l'image sous forme de paires clé-valeur.

```dockerfile
# Labels simples
LABEL version="1.0"
LABEL description="Application de démonstration"

# Multiple labels
LABEL maintainer="dev@example.com" \
      version="1.0.0" \
      release-date="2025-01-01"

# Labels avec namespaces (convention)
LABEL com.example.version="1.0"
LABEL com.example.git-commit="abc123"
```

```bash
# Inspecter les labels
docker inspect --format='{{json .Config.Labels}}' mon-image
```

### Dockerfile complet - Exemple Node.js

```dockerfile
# === Stage 1: Build ===
FROM node:18-alpine AS builder

# Métadonnées
LABEL maintainer="dev@company.com"
LABEL description="Backend API Node.js"

# Variables de build
ARG NODE_ENV=production

# Installation des dépendances de build
WORKDIR /build
COPY package*.json ./
RUN npm ci

# Copie et build du code
COPY . .
RUN npm run build

# === Stage 2: Production ===
FROM node:18-alpine

# Variables d'environnement
ENV NODE_ENV=production \
    PORT=3000

# Création d'un utilisateur non-root
RUN addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser

# Répertoire de travail
WORKDIR /app

# Copie des dépendances depuis le stage builder
COPY --from=builder --chown=appuser:appgroup /build/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /build/dist ./dist
COPY --from=builder --chown=appuser:appgroup /build/package*.json ./

# Basculer vers l'utilisateur non-root
USER appuser

# Port exposé (documentation)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node healthcheck.js || exit 1

# Commande de démarrage
CMD ["node", "dist/server.js"]
```

### Construire une image depuis un Dockerfile

```bash
# Build basique (cherche ./Dockerfile)
docker build -t mon-app:latest .

# Spécifier un Dockerfile différent
docker build -f Dockerfile.prod -t mon-app:prod .

# Avec des arguments de build
docker build --build-arg NODE_VERSION=20 -t mon-app .

# Sans utiliser le cache
docker build --no-cache -t mon-app .

# Build multi-plateforme
docker build --platform linux/amd64,linux/arm64 -t mon-app .

# Avec une target spécifique (multi-stage)
docker build --target builder -t mon-app:builder .

# Afficher les étapes de build
docker build --progress=plain -t mon-app .
```

### .dockerignore - Exclure des fichiers

Le fichier `.dockerignore` fonctionne comme `.gitignore` et permet d'exclure des fichiers du contexte de build.

```plaintext
# .dockerignore

# Dépendances
node_modules/
npm-debug.log

# Fichiers de développement
.git/
.gitignore
.env.local
*.md
README.md

# Tests
test/
*.test.js
coverage/

# Build artifacts
dist/
build/

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Fichiers temporaires
tmp/
temp/
*.tmp
```

> [!tip] Pourquoi utiliser .dockerignore ?
> 
> - **Vitesse** : Réduit la taille du contexte envoyé au daemon Docker
> - **Sécurité** : Évite d'inclure des secrets ou fichiers sensibles
> - **Taille** : Empêche l'inclusion de fichiers inutiles dans l'image finale

### Multi-stage builds - Optimisation avancée

Les builds multi-stages permettent de créer des images légères en séparant l'environnement de build de l'environnement d'exécution.

```dockerfile
# === Stage 1: Dépendances ===
FROM node:18 AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# === Stage 2: Build ===
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm run test

# === Stage 3: Production ===
FROM node:18-alpine
WORKDIR /app

# Copie seulement ce qui est nécessaire
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY package*.json ./

USER node
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

> [!example] Avantages du multi-stage
> 
> - **Taille réduite** : L'image finale ne contient que le nécessaire à l'exécution
> - **Sécurité** : Pas d'outils de build dans l'image finale
> - **Organisation** : Séparation claire des responsabilités

```dockerfile
# Exemple pour une app Go
FROM golang:1.21 AS builder
WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 go build -o app .

FROM alpine:3.19
COPY --from=builder /build/app /usr/local/bin/
CMD ["app"]
```

### BuildKit et optimisations avancées

BuildKit est le nouveau moteur de build Docker avec des fonctionnalités avancées.

```dockerfile
# syntax=docker/dockerfile:1.4

# Cache de montage pour npm (accélère les builds)
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

# Secrets de build (ne sont pas inclus dans l'image)
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc \
    npm install --registry=https://private-registry.com

# Montage de bind (fichier temporaire)
RUN --mount=type=bind,source=package.json,target=/tmp/package.json \
    cat /tmp/package.json
```

```bash
# Activer BuildKit
export DOCKER_BUILDKIT=1
docker build -t mon-app .

# Ou directement dans la commande
DOCKER_BUILDKIT=1 docker build -t mon-app .

# Avec un secret
docker build --secret id=npmrc,src=$HOME/.npmrc -t mon-app .
```

### Bonnes pratiques du Dockerfile

> [!tip] Ordre des instructions Placez les instructions qui changent rarement en premier pour maximiser l'utilisation du cache.

```dockerfile
# ✅ Bon ordre (maximise le cache)
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./          # Change rarement
RUN npm ci                     # Change rarement
COPY . .                       # Change souvent
RUN npm run build             # Dépend du code source

# ❌ Mauvais ordre
FROM node:18-alpine
WORKDIR /app
COPY . .                      # Change souvent, invalide tout le cache
COPY package*.json ./
RUN npm ci
```

> [!tip] Une responsabilité par conteneur Un conteneur = un processus principal. Séparez vos services (app, database, cache) dans différents conteneurs.

```dockerfile
# ❌ Anti-pattern : plusieurs services
FROM ubuntu
RUN apt-get update && apt-get install -y nginx postgresql redis
CMD service postgresql start && service redis start && nginx

# ✅ Pattern correct : un service par conteneur
FROM nginx:alpine
COPY nginx.conf /etc/nginx/
CMD ["nginx", "-g", "daemon off;"]
```

> [!tip] Minimiser le nombre de couches Combinez les commandes RUN connexes pour réduire le nombre de couches.

```dockerfile
# ❌ Trop de couches
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get clean

# ✅ Optimisé
RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

> [!tip] Utiliser des images de base légères Préférez les variantes Alpine quand c'est possible.

|Image|Taille|Usage|
|---|---|---|
|`ubuntu:22.04`|~77 MB|Développement, debugging|
|`debian:12-slim`|~74 MB|Bon compromis|
|`alpine:3.19`|~7 MB|Production, léger|
|`scratch`|0 MB|Binaires statiques uniquement|

### Pièges courants

> [!warning] Cache Docker trompeur Docker ne détecte pas les changements dans les fichiers externes ou les ressources téléchargées.

```dockerfile
# ❌ Problème : Docker cache le RUN même si le fichier change
ADD http://example.com/config.json /app/
RUN process-config /app/config.json

# ✅ Solution : Forcer la mise à jour
ARG CACHE_BUST=1
ADD http://example.com/config.json /app/
RUN process-config /app/config.json
```

```bash
# Forcer le rebuild
docker build --build-arg CACHE_BUST=$(date +%s) -t mon-app .
```

> [!warning] Variables d'environnement dans CMD La forme shell de CMD permet l'expansion de variables, mais pas la forme exec.

```dockerfile
ENV PORT=3000

# ❌ Ne fonctionne pas (forme exec)
CMD ["node", "server.js", "--port", "$PORT"]  # $PORT littéral

# ✅ Fonctionne (forme shell)
CMD node server.js --port $PORT

# ✅ Ou avec une autre approche
CMD ["sh", "-c", "node server.js --port $PORT"]
```

> [!warning] Fichiers sensibles dans l'image Ne copiez jamais de secrets directement dans l'image.

```dockerfile
# ❌ DANGEREUX : Le secret reste dans l'historique de l'image
COPY .env /app/.env

# ✅ Passer les secrets au runtime
# docker run -e DATABASE_PASSWORD=secret mon-app

# ✅ Ou utiliser Docker secrets (Swarm/Kubernetes)
# docker secret create db_password password.txt
```

### Astuces avancées

```bash
# Voir le contenu d'une image sans la lancer
docker run --rm -it --entrypoint sh mon-app

# Inspecter les couches d'une image
docker history mon-app

# Avec les commandes complètes
docker history --no-trunc mon-app

# Analyser la taille de chaque couche
docker history --format "table {{.Size}}\t{{.CreatedBy}}" mon-app

# Lint votre Dockerfile (nécessite hadolint)
docker run --rm -i hadolint/hadolint < Dockerfile

# Scanner les vulnérabilités
docker scan mon-app

# Builder avec un contexte distant
docker build https://github.com/user/repo.git#branch:docker/

# Extraire des fichiers d'une image
docker create --name extract mon-app
docker cp extract:/app/config.json ./
docker rm extract
```

---

## 🌐 Registry et Docker Hub

### Qu'est-ce qu'un Registry Docker ?

Un **registry Docker** est un système de stockage et de distribution d'images Docker. C'est un serveur qui héberge des repositories d'images et permet de les pousser (push) et télécharger (pull).

> [!info] Analogie Un registry Docker est comme GitHub pour le code : c'est un endroit centralisé où vous stockez, versionnez et partagez vos images Docker.

### Types de registries

|Type|Exemples|Usage|
|---|---|---|
|**Public**|Docker Hub, Quay.io|Images open-source, communauté|
|**Privé cloud**|AWS ECR, Google GCR, Azure ACR|Production cloud|
|**Auto-hébergé**|Docker Registry, Harbor, GitLab Registry|On-premise, contrôle total|

### Docker Hub - Le registry officiel

**Docker Hub** est le registry public par défaut de Docker, hébergeant des millions d'images.

#### Structure d'un nom d'image sur Docker Hub

```
[registry]/[namespace]/[repository]:[tag]

docker.io/library/nginx:latest
    ↓       ↓      ↓       ↓
registry  namespace repo   tag

# Équivalences
nginx                           # Raccourci
library/nginx                   # Namespace officiel
docker.io/library/nginx        # Complet
docker.io/library/nginx:latest # Avec tag
```

|Composant|Description|Par défaut|
|---|---|---|
|`registry`|Serveur d'hébergement|`docker.io`|
|`namespace`|Organisation/utilisateur|`library` (officiel)|
|`repository`|Nom de l'image|Obligatoire|
|`tag`|Version/variante|`latest`|

#### Images officielles vs communautaires

```bash
# Images officielles (namespace 'library')
docker pull nginx              # = docker.io/library/nginx
docker pull ubuntu             # = docker.io/library/ubuntu
docker pull postgres           # = docker.io/library/postgres

# Images communautaires (avec namespace utilisateur)
docker pull bitnami/nginx      # Par Bitnami
docker pull myusername/myapp   # Votre image personnelle
```

> [!info] Images officielles Les images sous `library/` sont maintenues par Docker Inc. et la communauté. Elles sont vérifiées et régulièrement mises à jour.

### Commandes Registry essentielles

#### Authentification

```bash
# Se connecter à Docker Hub
docker login

# Avec credentials explicites
docker login -u mon-username -p mon-password

# Se connecter à un registry privé
docker login myregistry.com

# Avec un token/password depuis un fichier
cat ~/mon-token.txt | docker login -u mon-username --password-stdin

# Se déconnecter
docker logout

# Logout d'un registry spécifique
docker logout myregistry.com
```

> [!warning] Sécurité Évitez de passer le mot de passe en paramètre `-p` (visible dans l'historique). Utilisez `--password-stdin` ou laissez Docker demander le mot de passe interactivement.

#### Pousser une image (Push)

```bash
# Taguer l'image avec votre namespace
docker tag mon-app:latest mon-username/mon-app:latest
docker tag mon-app:latest mon-username/mon-app:v1.0.0

# Pousser vers Docker Hub
docker push mon-username/mon-app:latest
docker push mon-username/mon-app:v1.0.0

# Pousser toutes les versions d'un repository
docker push --all-tags mon-username/mon-app

# Pousser vers un registry privé
docker tag mon-app myregistry.com/project/mon-app:v1
docker push myregistry.com/project/mon-app:v1
```

#### Télécharger une image (Pull)

```bash
# Depuis Docker Hub (namespace officiel)
docker pull nginx
docker pull nginx:1.25

# Depuis Docker Hub (utilisateur)
docker pull mon-username/mon-app:latest

# Depuis un registry privé
docker pull myregistry.com/project/backend:prod

# Toutes les variantes d'un repository
docker pull --all-tags nginx

# Avec plateforme spécifique
docker pull --platform linux/amd64 nginx
```

#### Rechercher des images

```bash
# Rechercher sur Docker Hub
docker search nginx

# Limiter aux images officielles
docker search --filter is-official=true nginx

# Minimum d'étoiles
docker search --filter stars=100 nginx

# Limiter le nombre de résultats
docker search --limit 10 python
```

### Registry privé - Auto-hébergé

Vous pouvez héberger votre propre registry Docker pour un contrôle total.

#### Démarrer un registry local

```bash
# Lancer un registry simple
docker run -d -p 5000:5000 --name registry registry:2

# Avec persistance des données
docker run -d \
  -p 5000:5000 \
  --name registry \
  -v /mnt/registry:/var/lib/registry \
  registry:2

# Avec authentification basique
docker run -d \
  -p 5000:5000 \
  --name registry \
  -v /mnt/registry:/var/lib/registry \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -v /auth:/auth \
  registry:2
```

#### Utiliser le registry local

```bash
# Taguer pour le registry local
docker tag mon-app:latest localhost:5000/mon-app:v1

# Pousser vers le registry local
docker push localhost:5000/mon-app:v1

# Pull depuis le registry local
docker pull localhost:5000/mon-app:v1

# Lister les images du registry
curl -X GET http://localhost:5000/v2/_catalog

# Lister les tags d'une image
curl -X GET http://localhost:5000/v2/mon-app/tags/list
```

### Registries cloud - Exemples

#### Amazon ECR (Elastic Container Registry)

```bash
# Authentification
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin \
  123456789.dkr.ecr.eu-west-1.amazonaws.com

# Taguer et pousser
docker tag mon-app:latest 123456789.dkr.ecr.eu-west-1.amazonaws.com/mon-app:v1
docker push 123456789.dkr.ecr.eu-west-1.amazonaws.com/mon-app:v1
```

#### Google Container Registry (GCR)

```bash
# Authentification
gcloud auth configure-docker

# Taguer et pousser
docker tag mon-app:latest gcr.io/mon-projet/mon-app:v1
docker push gcr.io/mon-projet/mon-app:v1
```

#### Azure Container Registry (ACR)

```bash
# Authentification
az acr login --name myregistry

# Taguer et pousser
docker tag mon-app:latest myregistry.azurecr.io/mon-app:v1
docker push myregistry.azurecr.io/mon-app:v1
```

### Gestion des tags - Stratégies

> [!tip] Stratégies de tagging recommandées Ne vous fiez pas uniquement à `latest` en production. Utilisez des versions sémantiques.

```bash
# Tagging sémantique
docker tag mon-app:latest mon-username/mon-app:1.2.3   # Version précise
docker tag mon-app:latest mon-username/mon-app:1.2     # Version mineure
docker tag mon-app:latest mon-username/mon-app:1       # Version majeure
docker tag mon-app:latest mon-username/mon-app:latest  # Dernière stable

# Tagging par environnement
docker tag mon-app:latest mon-username/mon-app:dev
docker tag mon-app:latest mon-username/mon-app:staging
docker tag mon-app:latest mon-username/mon-app:prod

# Tagging par commit Git
docker tag mon-app:latest mon-username/mon-app:sha-abc1234

# Tagging par date
docker tag mon-app:latest mon-username/mon-app:2025-01-15
```

### Supprimer des images d'un registry

```bash
# Sur Docker Hub (via l'API)
# Nécessite un token d'accès
curl -X DELETE \
  -H "Authorization: Bearer $TOKEN" \
  https://hub.docker.com/v2/repositories/mon-username/mon-app/tags/v1/

# Sur un registry privé (v2 API)
curl -X DELETE \
  http://localhost:5000/v2/mon-app/manifests/sha256:abc...

# Garbage collection sur un registry privé
docker exec registry bin/registry garbage-collect \
  /etc/docker/registry/config.yml
```

> [!warning] Suppression irréversible La suppression d'un tag d'un registry est définitive. Assurez-vous d'avoir des backups si nécessaire.

### Sécurité et bonnes pratiques

> [!tip] Scanner les vulnérabilités Analysez toujours vos images avant de les déployer en production.

```bash
# Scanner une image locale
docker scan mon-app:latest

# Scanner avec Trivy (outil populaire)
trivy image mon-app:latest

# Scanner avec Snyk
snyk container test mon-app:latest

# Scanner depuis Docker Hub (intégré)
# Activé automatiquement pour les repos
```

> [!tip] Signature d'images avec Docker Content Trust Signez vos images pour garantir leur intégrité et leur provenance.

```bash
# Activer Docker Content Trust
export DOCKER_CONTENT_TRUST=1

# Pousser une image signée
docker push mon-username/mon-app:v1
# → Demande de créer des clés de signature

# Pull vérifiera automatiquement la signature
docker pull mon-username/mon-app:v1
```

> [!warning] Images publiques Soyez prudent avec ce que vous publiez publiquement. Ne pas inclure :
> 
> - Secrets ou mots de passe
> - Clés API
> - Propriété intellectuelle sensible
> - Informations personnelles

### Limites et quotas

#### Docker Hub (compte gratuit)

|Limite|Valeur|
|---|---|
|Pull rate limit|200 pulls / 6h (anonyme), 200 pulls / 6h (authentifié)|
|Repositories privés|1|
|Repositories publics|Illimité|
|Taille par image|Illimité|
|Rétention|Images non utilisées supprimées après 6 mois (compte gratuit)|

> [!tip] Éviter le rate limit
> 
> - Authentifiez-vous toujours : `docker login`
> - Utilisez un registry mirror ou cache
> - Passez à Docker Hub Pro/Team pour des limites plus élevées

### Mirror et Cache Registry

Pour accélérer les pulls et économiser la bande passante, configurez un registry mirror.

```bash
# Configurer un mirror dans /etc/docker/daemon.json
{
  "registry-mirrors": ["https://mirror.gcr.io"]
}

# Redémarrer Docker
sudo systemctl restart docker

# Vérifier la configuration
docker info | grep -A 5 "Registry Mirrors"
```

### Pièges courants

> [!warning] Tag 'latest' trompeur `latest` ne veut pas dire "la plus récente". C'est juste le tag par défaut si aucun n'est spécifié.

```bash
# Ces deux commandes font la même chose
docker pull nginx
docker pull nginx:latest

# Mais 'latest' peut être très ancien si personne ne l'a mis à jour !
```

> [!warning] Registry non sécurisé Par défaut, Docker refuse les connexions non-HTTPS aux registries.

```bash
# Si vous devez utiliser HTTP (développement uniquement !)
# Ajoutez dans /etc/docker/daemon.json
{
  "insecure-registries": ["myregistry.local:5000"]
}

# Redémarrer Docker
sudo systemctl restart docker
```

> [!warning] Espace disque sur le registry Les registries auto-hébergés peuvent rapidement remplir le disque.

```bash
# Activer le garbage collection automatique
# Dans la config du registry
storage:
  delete:
    enabled: true

# Lancer le garbage collection manuellement
docker exec registry bin/registry garbage-collect \
  /etc/docker/registry/config.yml --delete-untagged=true
```

### Astuces avancées

```bash
# Copier une image d'un registry à un autre sans la télécharger
# Utiliser skopeo
skopeo copy \
  docker://docker.io/library/nginx:latest \
  docker://myregistry.com/nginx:latest

# Inspecter une image distante sans la télécharger
skopeo inspect docker://nginx:latest

# Exporter toutes les images locales vers un registry
for image in $(docker images --format "{{.Repository}}:{{.Tag}}"); do
  docker tag $image myregistry.com/$image
  docker push myregistry.com/$image
done

# Lister les repositories d'un registry
curl -s http://localhost:5000/v2/_catalog | jq .

# Obtenir le digest (hash) d'une image
docker inspect --format='{{index .RepoDigests 0}}' nginx:latest

# Pull par digest (garantit l'image exacte)
docker pull nginx@sha256:abc123def456...
```

---

## 🎯 Résumé des concepts de base

|Concept|Description|Commande clé|
|---|---|---|
|**Image**|Modèle immuable en couches|`docker images`, `docker pull`|
|**Conteneur**|Instance exécutable d'une image|`docker run`, `docker ps`|
|**Dockerfile**|Instructions pour construire une image|`docker build`|
|**Registry**|Stockage et distribution d'images|`docker push`, `docker pull`|

> [!info] Points clés à retenir
> 
> - Une **image** est un template, un **conteneur** est une instance de ce template
> - Le **Dockerfile** définit comment construire une image de manière reproductible
> - Les **registries** permettent de partager et versionner vos images
> - Les images sont construites en **couches** pour l'efficacité
> - Toujours utiliser des **versions précises** en production
> - Les **conteneurs sont éphémères**, utilisez des **volumes** pour la persistance

---

_Cours créé pour Obsidian - Docker Concepts de Base_