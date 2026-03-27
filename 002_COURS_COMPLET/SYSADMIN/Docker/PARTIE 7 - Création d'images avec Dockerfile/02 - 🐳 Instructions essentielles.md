

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

## Introduction

Les instructions Dockerfile sont les briques fondamentales pour construire vos images Docker. Chaque instruction crée une nouvelle couche dans l'image, ce qui impacte directement la taille et les performances de vos conteneurs. Comprendre ces instructions est essentiel pour créer des images optimisées et maintenables.

> [!info] Principe de fonctionnement Chaque instruction dans un Dockerfile est exécutée séquentiellement et crée une nouvelle couche immutable dans l'image finale. Docker utilise un système de cache pour optimiser les builds successifs.

---

## FROM - L'image de base

### 📖 Définition

`FROM` est **obligatoirement la première instruction** d'un Dockerfile (sauf commentaires ou ARG globaux). Elle définit l'image de base sur laquelle votre image sera construite.

### 🎯 Pourquoi c'est important

- Détermine l'environnement de base (système d'exploitation, outils préinstallés)
- Influence directement la taille finale de l'image
- Définit la compatibilité et la sécurité de base

### 📝 Syntaxe

```dockerfile
# Syntaxe de base
FROM <image>:<tag>

# Avec digest pour garantir l'exactitude
FROM <image>@<digest>

# Avec alias pour les builds multi-étapes
FROM <image>:<tag> AS <nom>
```

### 💡 Exemples pratiques

```dockerfile
# Image Ubuntu officielle version 22.04
FROM ubuntu:22.04

# Image Node.js Alpine (légère)
FROM node:18-alpine

# Image avec digest SHA256 pour reproductibilité
FROM nginx@sha256:a76b1e8b9f9b8e9d8f7e6d5c4b3a2f1e

# Build multi-étapes avec alias
FROM node:18 AS builder
FROM nginx:alpine AS production
```

> [!tip] Choisir la bonne image de base
> 
> - **Alpine Linux** : Ultra-légère (~5 MB), idéale pour la production
> - **Debian/Ubuntu** : Plus complètes, meilleures pour le développement
> - **Distroless** : Sans shell, maximisant la sécurité pour la production
> - Toujours préciser un **tag spécifique** plutôt que `latest` pour la reproductibilité

> [!warning] Pièges courants
> 
> - Ne pas utiliser `latest` en production (version non déterministe)
> - Attention aux images trop volumineuses qui ralentissent les déploiements
> - Vérifier la fréquence de mise à jour de sécurité de l'image de base

### 🔑 Bonnes pratiques

|Pratique|✅ Recommandé|❌ À éviter|
|---|---|---|
|Tag|`FROM node:18.19.0-alpine`|`FROM node:latest`|
|Taille|`FROM alpine:3.19`|`FROM ubuntu:latest` (sans justification)|
|Sécurité|Images officielles vérifiées|Images non maintenues|
|Multi-stage|`FROM node:18 AS builder`|Un seul FROM avec tout|

---

## RUN - Exécuter des commandes

### 📖 Définition

`RUN` exécute des commandes dans le conteneur pendant la phase de **build** et crée une nouvelle couche avec les résultats. C'est l'instruction la plus utilisée pour installer des packages, configurer l'environnement, ou compiler du code.

### 🎯 Pourquoi c'est important

- Permet d'installer les dépendances et outils nécessaires
- Chaque `RUN` crée une couche, impactant la taille de l'image
- Les commandes sont mises en cache par Docker pour accélérer les builds

### 📝 Syntaxe

```dockerfile
# Forme shell (exécutée avec /bin/sh -c)
RUN <commande>

# Forme exec (sans shell intermédiaire)
RUN ["executable", "param1", "param2"]
```

### 💡 Exemples pratiques

```dockerfile
# Installation simple de packages
RUN apt-get update && apt-get install -y curl

# Commandes multiples optimisées (1 seule couche)
RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Forme exec (utile pour éviter l'interprétation du shell)
RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "nginx"]

# Compilation et installation d'une application
RUN npm ci --only=production && \
    npm cache clean --force

# Création d'utilisateur non-root
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup
```

> [!tip] Optimisation des couches Combinez les commandes liées avec `&&` pour créer une seule couche :
> 
> ```dockerfile
> # ❌ Mauvais : 3 couches distinctes
> RUN apt-get update
> RUN apt-get install -y curl
> RUN apt-get clean
> 
> # ✅ Bon : 1 seule couche
> RUN apt-get update && \
>     apt-get install -y curl && \
>     apt-get clean
> ```

> [!warning] Pièges courants
> 
> - **Cache invalidé** : Modifier une ligne RUN invalide le cache de toutes les instructions suivantes
> - **Fichiers temporaires** : Les fichiers créés puis supprimés dans des RUN différents restent dans les couches
> - **Droits excessifs** : Exécuter tout en root pose des problèmes de sécurité
> - **Ordre des commandes** : Les commandes qui changent rarement doivent être placées en début de Dockerfile

### 🔑 Bonnes pratiques

```dockerfile
# ✅ Installation optimisée avec nettoyage
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        package1 \
        package2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ✅ Ordre alphabétique pour meilleure lisibilité
RUN apt-get update && apt-get install -y \
    curl \
    git \
    nginx \
    vim

# ✅ Utilisation de variables pour la réutilisabilité
RUN VERSION=1.2.3 && \
    curl -O https://example.com/app-${VERSION}.tar.gz && \
    tar -xzf app-${VERSION}.tar.gz && \
    rm app-${VERSION}.tar.gz
```

### 🎨 Astuces avancées

```dockerfile
# Utiliser le BuildKit pour le cache de type mount
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y package

# Exécuter des commandes avec un utilisateur spécifique
RUN chown -R node:node /app
USER node
RUN npm install
```

---

## COPY et ADD - Transférer des fichiers

### 📖 Définition

Ces instructions copient des fichiers et répertoires depuis votre machine (contexte de build) vers le système de fichiers de l'image Docker.

- **COPY** : Simple copie de fichiers
- **ADD** : Copie avec fonctionnalités supplémentaires (extraction d'archives, téléchargement d'URLs)

### 🎯 Pourquoi c'est important

- Transfert du code source et des fichiers de configuration dans l'image
- Impact direct sur la taille de l'image et la sécurité
- Gestion efficace du cache de build

### 📝 Syntaxe

```dockerfile
# COPY - syntaxe simple
COPY <src>... <dest>
COPY ["<src>",... "<dest>"]

# ADD - syntaxe identique mais avec fonctionnalités étendues
ADD <src>... <dest>
ADD ["<src>",... "<dest>"]

# Options disponibles
COPY --chown=<user>:<group> <src> <dest>
COPY --chmod=755 <src> <dest>
```

### 💡 Exemples pratiques

```dockerfile
# Copier un fichier unique
COPY package.json /app/

# Copier plusieurs fichiers
COPY package.json package-lock.json /app/

# Copier tout un répertoire
COPY ./src /app/src

# Copier avec changement de propriétaire
COPY --chown=node:node package*.json /app/

# Copier avec permissions spécifiques
COPY --chmod=755 entrypoint.sh /usr/local/bin/

# Utiliser des wildcards
COPY *.json /app/

# ADD pour extraire une archive locale
ADD app.tar.gz /app/

# ADD pour télécharger depuis une URL (déconseillé)
ADD https://example.com/file.tar.gz /tmp/
```

> [!example] Cas d'usage typique - Application Node.js
> 
> ```dockerfile
> # Copier d'abord les fichiers de dépendances
> COPY package*.json ./
> 
> # Installer les dépendances (couche cachée)
> RUN npm ci
> 
> # Puis copier le code source (change plus souvent)
> COPY . .
> ```

### 🔍 Différences COPY vs ADD

|Fonctionnalité|COPY|ADD|
|---|---|---|
|Copie simple de fichiers|✅|✅|
|Extraction automatique d'archives tar|❌|✅|
|Téléchargement depuis URL|❌|✅|
|Transparence du comportement|✅|❌|
|Recommandation officielle|✅ Préféré|⚠️ Cas spécifiques|

> [!tip] Quand utiliser ADD ?
> 
> - **Extraction d'archives locales** : `ADD app.tar.gz /app/` (décompresse automatiquement)
> - Pour tout le reste, **préférez COPY** pour plus de clarté et de prévisibilité

> [!warning] Pièges courants
> 
> - **Contexte trop large** : Copier `.` copie tout le contexte de build (utiliser `.dockerignore`)
> - **ADD avec URL** : Pas de mise en cache, préférer `RUN curl` ou `RUN wget`
> - **Permissions** : Les fichiers copiés gardent leurs permissions d'origine
> - **Ordre d'instructions** : Copier les fichiers qui changent rarement en premier

### 🔑 Bonnes pratiques

```dockerfile
# ✅ Optimisation du cache : dépendances d'abord
COPY package.json package-lock.json ./
RUN npm ci
COPY . .

# ✅ Copier uniquement ce qui est nécessaire
COPY src/ /app/src/
COPY config/ /app/config/

# ✅ Définir le propriétaire pour la sécurité
COPY --chown=www-data:www-data . /var/www/html

# ❌ À éviter : copie trop large
# COPY . .  (au début du Dockerfile)

# ✅ Utiliser .dockerignore pour exclure des fichiers
# Créer un fichier .dockerignore avec :
# node_modules
# .git
# *.log
# .env
```

### 🎨 Astuces avancées

```dockerfile
# Copier depuis une autre étape de build (multi-stage)
COPY --from=builder /app/dist /usr/share/nginx/html

# Copier depuis une image nommée
COPY --from=nginx:latest /etc/nginx/nginx.conf /etc/nginx/

# Utiliser des patterns complexes
COPY package*.json yarn.lock* pnpm-lock.yaml* ./
```

---

## WORKDIR - Définir le répertoire de travail

### 📖 Définition

`WORKDIR` définit le répertoire de travail pour toutes les instructions suivantes (`RUN`, `CMD`, `ENTRYPOINT`, `COPY`, `ADD`). Si le répertoire n'existe pas, il est créé automatiquement.

### 🎯 Pourquoi c'est important

- Évite les chemins absolus répétitifs
- Améliore la lisibilité du Dockerfile
- Standardise la structure de l'image
- Définit le répertoire par défaut au démarrage du conteneur

### 📝 Syntaxe

```dockerfile
WORKDIR /chemin/vers/répertoire

# Chemins relatifs (s'ajoutent au WORKDIR précédent)
WORKDIR /app
WORKDIR sous-dossier  # Résultat : /app/sous-dossier
```

### 💡 Exemples pratiques

```dockerfile
# Définir un répertoire de travail absolu
WORKDIR /app

# Créer et se placer dans un répertoire
WORKDIR /opt/myapp

# Utilisation avec des chemins relatifs
WORKDIR /app
WORKDIR backend      # On est maintenant dans /app/backend
WORKDIR ../frontend  # On est maintenant dans /app/frontend

# Utilisation avec des variables d'environnement
ENV APP_HOME=/usr/src/app
WORKDIR ${APP_HOME}

# Exemple complet d'une application Node.js
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
CMD ["npm", "start"]
```

> [!example] Avant/Après WORKDIR
> 
> ```dockerfile
> # ❌ Sans WORKDIR - répétitif et verbeux
> FROM node:18-alpine
> COPY package.json /usr/src/app/package.json
> COPY package-lock.json /usr/src/app/package-lock.json
> RUN cd /usr/src/app && npm ci
> COPY . /usr/src/app
> CMD cd /usr/src/app && npm start
> 
> # ✅ Avec WORKDIR - clair et concis
> FROM node:18-alpine
> WORKDIR /usr/src/app
> COPY package*.json ./
> RUN npm ci
> COPY . .
> CMD ["npm", "start"]
> ```

> [!tip] Conventions de nommage
> 
> - `/app` : Convention la plus courante pour les applications
> - `/usr/src/app` : Convention pour les applications sources
> - `/opt/myapp` : Pour les applications système
> - `/home/user/app` : Pour les applications utilisateur non-root

> [!warning] Pièges courants
> 
> - **Chemins relatifs implicites** : Sans WORKDIR, les chemins sont relatifs à `/`
> - **Permissions** : Le répertoire créé appartient à root par défaut
> - **Ne pas confondre** : WORKDIR n'est pas équivalent à `RUN cd` (qui n'a effet que pour cette instruction)

### 🔑 Bonnes pratiques

```dockerfile
# ✅ Définir WORKDIR tôt dans le Dockerfile
FROM python:3.11-slim
WORKDIR /app
# ... reste du Dockerfile

# ✅ Utiliser avec chown pour les utilisateurs non-root
FROM node:18-alpine
RUN mkdir -p /app && chown -R node:node /app
WORKDIR /app
USER node

# ✅ Combiner avec ENV pour la flexibilité
ENV APP_DIR=/usr/src/application
WORKDIR ${APP_DIR}

# ❌ À éviter : ne pas utiliser RUN cd
# RUN cd /app  # N'a aucun effet permanent

# ✅ À la place, utiliser WORKDIR
WORKDIR /app
```

### 🎨 Astuces avancées

```dockerfile
# Build multi-étapes avec différents WORKDIR
FROM node:18 AS builder
WORKDIR /build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY --from=builder /build/dist .

# Utilisation de variables ARG
ARG PROJECT_NAME=myapp
WORKDIR /opt/${PROJECT_NAME}
```

---

## ENV - Variables d'environnement

### 📖 Définition

`ENV` définit des variables d'environnement qui seront disponibles :

- Pendant le build (pour les instructions suivantes)
- Au runtime (dans les conteneurs lancés depuis l'image)

### 🎯 Pourquoi c'est important

- Configuration flexible sans reconstruire l'image
- Partage de valeurs entre instructions du Dockerfile
- Standardisation de la configuration applicative
- Pattern 12-factor app pour la portabilité

### 📝 Syntaxe

```dockerfile
# Syntaxe simple (une variable)
ENV CLÉ=valeur

# Syntaxe ancienne (encore supportée)
ENV CLÉ valeur

# Définir plusieurs variables
ENV CLÉ1=valeur1 \
    CLÉ2=valeur2 \
    CLÉ3=valeur3
```

### 💡 Exemples pratiques

```dockerfile
# Variable simple
ENV NODE_ENV=production

# Plusieurs variables en une instruction
ENV APP_HOME=/app \
    APP_USER=appuser \
    APP_PORT=3000

# Utiliser des variables dans d'autres instructions
ENV APP_DIR=/usr/src/app
WORKDIR ${APP_DIR}
COPY . ${APP_DIR}

# Variables pour la configuration applicative
ENV DATABASE_HOST=localhost \
    DATABASE_PORT=5432 \
    LOG_LEVEL=info

# Variable de chemin PATH
ENV PATH="/app/bin:${PATH}"

# Exemple complet Node.js
FROM node:18-alpine
ENV NODE_ENV=production \
    PORT=3000 \
    LOG_LEVEL=info
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE ${PORT}
CMD ["node", "server.js"]
```

> [!example] Utilisation dans l'application
> 
> ```javascript
> // Dans votre application Node.js
> const port = process.env.PORT || 3000;
> const logLevel = process.env.LOG_LEVEL || 'info';
> const nodeEnv = process.env.NODE_ENV || 'development';
> 
> console.log(`Starting server on port ${port}`);
> ```

> [!tip] Surcharger les variables au runtime
> 
> ```bash
> # Les variables ENV peuvent être surchargées au lancement
> docker run -e NODE_ENV=development -e PORT=8080 myimage
> 
> # Ou via un fichier .env
> docker run --env-file .env myimage
> ```

> [!warning] Pièges courants
> 
> - **Secrets** : Ne jamais mettre de secrets (mots de passe, tokens) dans ENV (ils sont visibles dans l'image)
> - **Persistance** : ENV persiste au runtime, contrairement à ARG qui n'existe qu'au build
> - **Surcharge** : Les variables définies au runtime écrasent celles du Dockerfile
> - **Guillemets** : `ENV KEY="value"` inclut les guillemets dans la valeur

### 🔍 Différences ENV vs ARG

|Caractéristique|ENV|ARG|
|---|---|---|
|Disponible au build|✅|✅|
|Disponible au runtime|✅|❌|
|Visible dans `docker inspect`|✅|❌|
|Modifiable au `docker run`|✅|❌|
|Modifiable au `docker build`|❌|✅|
|Usage recommandé|Configuration runtime|Paramètres de build|

### 🔑 Bonnes pratiques

```dockerfile
# ✅ Grouper les variables liées
ENV DATABASE_HOST=db \
    DATABASE_PORT=5432 \
    DATABASE_NAME=myapp

# ✅ Valeurs par défaut raisonnables
ENV NODE_ENV=production \
    LOG_LEVEL=info \
    PORT=3000

# ✅ Documentation des variables attendues
ENV API_KEY="" \
    SECRET_TOKEN=""
# Note: Ces valeurs vides seront surchargées au runtime

# ❌ À éviter : secrets en dur
# ENV DATABASE_PASSWORD=supersecret123  # DANGER !

# ✅ Utiliser des secrets au runtime
# docker run -e DATABASE_PASSWORD="$DB_PASS" myimage

# ✅ Combiner ENV et ARG pour la flexibilité
ARG NODE_VERSION=18
FROM node:${NODE_VERSION}-alpine
ENV NODE_ENV=production
```

### 🎨 Astuces avancées

```dockerfile
# Utiliser ARG pour rendre ENV configurable au build
ARG APP_ENV=production
ENV NODE_ENV=${APP_ENV}

# Construire avec : docker build --build-arg APP_ENV=development .

# Variables conditionnelles (nécessite un script)
ENV ENABLE_FEATURE=${ENABLE_FEATURE:-false}

# Concaténation de chemins
ENV APP_HOME=/app
ENV BIN_PATH=${APP_HOME}/bin
ENV PATH="${BIN_PATH}:${PATH}"

# Variables pour la locale
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1
```

### 🔐 Gestion sécurisée des variables sensibles

```dockerfile
# ✅ Ne jamais faire ça dans le Dockerfile
# ENV API_SECRET=secret123

# ✅ À la place, documenter et fournir une valeur vide
ENV API_SECRET=""

# Au runtime, utiliser :
# - docker run -e API_SECRET="$(cat secret.txt)" myimage
# - Docker secrets (mode swarm)
# - Kubernetes secrets
# - Variables d'environnement du système CI/CD
```

---

## EXPOSE - Documenter les ports

### 📖 Définition

`EXPOSE` documente les ports sur lesquels le conteneur écoute au runtime. C'est une instruction **purement informative** qui ne publie pas réellement les ports.

### 🎯 Pourquoi c'est important

- Documentation pour les utilisateurs de l'image
- Métadonnées exploitées par certains orchestrateurs
- Facilite la commande `docker run -P` (publication automatique)
- Convention standardisée pour la communication inter-conteneurs

### 📝 Syntaxe

```dockerfile
# Port simple
EXPOSE <port>

# Avec protocole (par défaut: TCP)
EXPOSE <port>/tcp
EXPOSE <port>/udp

# Plusieurs ports
EXPOSE <port1> <port2> <port3>
```

### 💡 Exemples pratiques

```dockerfile
# Exposer un port HTTP standard
EXPOSE 80

# Exposer un port HTTPS
EXPOSE 443

# Exposer avec protocole explicite
EXPOSE 53/udp
EXPOSE 53/tcp

# Exposer plusieurs ports
EXPOSE 80 443

# Application Node.js standard
FROM node:18-alpine
WORKDIR /app
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]

# Application avec plusieurs services
EXPOSE 8080/tcp
EXPOSE 8081/tcp
EXPOSE 9090/tcp

# Utilisation avec une variable ENV
ENV PORT=3000
EXPOSE ${PORT}
```

> [!example] Publication réelle des ports
> 
> ```bash
> # EXPOSE ne publie PAS le port automatiquement
> docker run myimage  # Port 80 non accessible depuis l'hôte
> 
> # Pour publier le port, utiliser -p (manuel)
> docker run -p 8080:80 myimage  # Hôte:8080 -> Conteneur:80
> 
> # Ou -P (automatique, utilise les ports EXPOSE)
> docker run -P myimage  # Docker choisit un port aléatoire sur l'hôte
> ```

> [!info] EXPOSE vs -p
> 
> - `EXPOSE` dans le Dockerfile = **documentation**
> - `-p` lors du `docker run` = **publication réelle** du port
> - `-P` lors du `docker run` = publie tous les ports `EXPOSE` avec des ports aléatoires sur l'hôte

> [!tip] Conventions de ports
> 
> - **80** : HTTP
> - **443** : HTTPS
> - **3000** : Node.js/React (développement)
> - **8080** : Applications Java/Tomcat
> - **5432** : PostgreSQL
> - **3306** : MySQL
> - **6379** : Redis
> - **27017** : MongoDB

> [!warning] Pièges courants
> 
> - **EXPOSE ne publie pas** : Il faut utiliser `-p` au `docker run`
> - **Sécurité** : Exposer un port ne le rend pas accessible depuis l'extérieur sans publication explicite
> - **Cohérence** : Le port EXPOSE devrait correspondre au port réellement utilisé par l'application
> - **Multiplicité** : Exposer trop de ports peut indiquer un problème d'architecture

### 🔑 Bonnes pratiques

```dockerfile
# ✅ Documenter tous les ports utilisés
FROM nginx:alpine
EXPOSE 80
EXPOSE 443

# ✅ Utiliser des variables pour la flexibilité
ARG APP_PORT=3000
ENV PORT=${APP_PORT}
EXPOSE ${PORT}

# ✅ Commenter les ports non standards
# Port pour l'API
EXPOSE 8080
# Port pour les métriques Prometheus
EXPOSE 9090

# ❌ À éviter : exposer des ports non utilisés
# EXPOSE 80  # Si l'app n'écoute pas réellement sur le port 80

# ✅ Cohérence avec l'application
FROM node:18-alpine
ENV PORT=3000
EXPOSE ${PORT}
CMD ["node", "server.js"]
# server.js doit écouter sur process.env.PORT
```

### 🎨 Astuces avancées

```dockerfile
# Build avec port configurable
ARG HTTP_PORT=8080
ARG HTTPS_PORT=8443
EXPOSE ${HTTP_PORT}
EXPOSE ${HTTPS_PORT}

# Build avec : docker build --build-arg HTTP_PORT=9090 .

# Microservices avec plusieurs ports
# Port API
EXPOSE 8080
# Port Admin
EXPOSE 8081
# Port Metrics
EXPOSE 9090
# Port Health
EXPOSE 9091

# Documentation complète
LABEL description="API REST avec métriques Prometheus"
LABEL ports.api="8080/tcp" \
      ports.metrics="9090/tcp" \
      ports.health="9091/tcp"
EXPOSE 8080 9090 9091
```

### 📊 Utilisation avec Docker Compose

```yaml
# docker-compose.yml
services:
  app:
    build: .
    ports:
      # EXPOSE 3000 dans le Dockerfile est documenté ici
      - "8080:3000"  # Hôte:8080 -> Conteneur:3000
    
  nginx:
    image: nginx
    ports:
      # Publication automatique des ports EXPOSE
      - "80:80"
      - "443:443"
```

---

## CMD et ENTRYPOINT - Commande au démarrage

### 📖 Définition

Ces instructions définissent **la commande exécutée au démarrage du conteneur** :

- **CMD** : Commande par défaut, facilement remplaçable
- **ENTRYPOINT** : Point d'entrée fixe du conteneur, arguments modifiables

### 🎯 Pourquoi c'est important

- Définit le comportement du conteneur au démarrage
- Différencie les images d'outils des images de services
- Permet de créer des conteneurs réutilisables et flexibles
- Combinaison CMD+ENTRYPOINT offre une grande souplesse

### 📝 Syntaxe

```dockerfile
# Forme exec (recommandée) - pas d'interprétation shell
CMD ["executable", "param1", "param2"]
ENTRYPOINT ["executable", "param1", "param2"]

# Forme shell - exécutée avec /bin/sh -c
CMD commande param1 param2
ENTRYPOINT commande param1 param2

# CMD comme paramètres par défaut pour ENTRYPOINT
ENTRYPOINT ["executable"]
CMD ["param1", "param2"]
```

### 💡 Exemples pratiques - CMD

```dockerfile
# Application web Node.js
FROM node:18-alpine
WORKDIR /app
COPY . .
CMD ["node", "server.js"]

# Script Python
FROM python:3.11-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]

# Forme shell (déconseillée)
CMD npm start

# Serveur avec configuration
CMD ["nginx", "-g", "daemon off;"]

# Commande avec variables d'environnement (forme shell nécessaire)
CMD npm start --port $PORT
```

### 💡 Exemples pratiques - ENTRYPOINT

```dockerfile
# Image comme outil CLI
FROM alpine:3.19
RUN apk add --no-cache curl
ENTRYPOINT ["curl"]
CMD ["--help"]
# Usage: docker run myimage https://example.com

# Script d'initialisation
FROM postgres:15
COPY init.sh /docker-entrypoint-initdb.d/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]

# Application avec script wrapper
FROM python:3.11-slim
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["python", "app.py"]
```

### 💡 Exemples pratiques - Combinaison CMD + ENTRYPOINT

```dockerfile
# Pattern le plus flexible
FROM alpine:3.19
RUN apk add --no-cache curl
ENTRYPOINT ["curl"]
CMD ["--help"]

# Usage:
# docker run myimage                    # Affiche --help
# docker run myimage https://google.com # Curl vers google.com
# docker run myimage -I https://api.com # Curl avec option -I

# Application avec paramètres flexibles
FROM node:18-alpine
WORKDIR /app
COPY . .
ENTRYPOINT ["node"]
CMD ["server.js"]
# Usage:
# docker run myimage              # Exécute: node server.js
# docker run myimage app.js       # Exécute: node app.js
# docker run myimage --version    # Exécute: node --version
```

### 🔍 Différences CMD vs ENTRYPOINT

|Caractéristique|CMD|ENTRYPOINT|
|---|---|---|
|Facilement remplaçable|✅ Oui|❌ Non (sauf --entrypoint)|
|Idéal pour|Paramètres par défaut|Exécutable principal|
|Peut être combiné|✅ Avec ENTRYPOINT|✅ Avec CMD|
|Usage typique|Services/applications|Outils/wrappers|
|Nombre par Dockerfile|1 seul actif|1 seul actif|

> [!example] Comportement lors de l'exécution
> 
> ```dockerfile
> # Scénario 1 : Seulement CMD
> CMD ["echo", "Hello"]
> ```
> 
> ```bash
> docker run myimage              # Affiche: Hello
> docker run myimage echo Bye     # Affiche: Bye (CMD remplacé)
> ```
> 
> ```dockerfile
> # Scénario 2 : Seulement ENTRYPOINT
> ENTRYPOINT ["echo", "Hello"]
> ```
> 
> ```bash
> docker run myimage              # Affiche: Hello
> docker run myimage World        # Affiche: Hello World (argument ajouté)
> ```
> 
> ```dockerfile
> # Scénario 3 : ENTRYPOINT + CMD
> ENTRYPOINT ["echo"]
> CMD ["Hello"]
> ```
> 
> ```bash
> docker run myimage              # Affiche: Hello
> docker run myimage World        # Affiche: World (CMD remplacé)
> ```

> [!tip] Quand utiliser quoi ?
> 
> **Utilisez CMD seul quand :**
> 
> - Vous créez une image d'application standard
> - La commande peut être complètement remplacée
> - Exemple : serveur web, API, application
> 
> **Utilisez ENTRYPOINT seul quand :**
> 
> - Vous créez une image outil/utilitaire
> - Le point d'entrée doit être fixe
> - Exemple : curl, grep, compilateur
> 
> **Utilisez ENTRYPOINT + CMD quand :**
> 
> - Vous voulez un exécutable fixe avec des paramètres par défaut modifiables
> - Maximum de flexibilité
> - Exemple : script d'initialisation avec options

> [!warning] Pièges courants
> 
> - **Forme shell vs exec** : La forme shell empêche la réception de signaux (SIGTERM) correctement
> - **Plusieurs CMD/ENTRYPOINT** : Seul le dernier est pris en compte
> - **Confusion arguments** : Avec ENTRYPOINT, les arguments docker run s'ajoutent, avec CMD ils remplacent
> - **PID 1** : En forme shell, le processus n'est pas PID 1, ce qui peut causer des problèmes d'arrêt

### 🔑 Bonnes pratiques

```dockerfile
# ✅ Forme exec recommandée (gestion correcte des signaux)
CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT ["python", "app.py"]

# ❌ Forme shell (le processus n'est pas PID 1)
CMD npm start

# ✅ Si vous devez utiliser des variables shell, utilisez sh -c
CMD ["sh", "-c", "npm start --port $PORT"]

# ✅ Application avec entrypoint script
FROM node:18-alpine
WORKDIR /app
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
COPY . .
ENTRYPOINT ["entrypoint.sh"]
CMD ["npm", "start"]

# ✅ Pattern pour images outils
FROM alpine:3.19
RUN apk add --no-cache jq
ENTRYPOINT ["jq"]
CMD ["--help"]

# ✅ Service avec configuration flexible
FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
```

### 🎨 Astuces avancées

```dockerfile
# Script entrypoint.sh pour initialisation
#!/bin/sh
set -e

# Initialisation (migrations, configuration, etc.)
echo "Initializing application..."
python manage.py migrate

# Passer la main à la commande fournie (exec remplace le shell par la commande)
exec "$@"
```

```dockerfile
# Dockerfile utilisant le script
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# Usage:
# docker run myimage                                  # Lance runserver
# docker run myimage python manage.py shell          # Lance shell Django
# docker run myimage python manage.py test           # Lance les tests
```

### 📊 Matrice de décision CMD vs ENTRYPOINT

|Cas d'usage|Recommandation|Exemple|
|---|---|---|
|API/Service web|`CMD` seul|`CMD ["node", "server.js"]`|
|Outil CLI|`ENTRYPOINT` seul|`ENTRYPOINT ["curl"]`|
|App avec script init|`ENTRYPOINT` + `CMD`|`ENTRYPOINT ["init.sh"]`<br>`CMD ["app"]`|
|Service configurable|`ENTRYPOINT` + `CMD`|`ENTRYPOINT ["python"]`<br>`CMD ["app.py"]`|
|Image de base|Aucun (à définir par l'utilisateur)|-|

### 🔧 Exemples complets par type d'application

#### Application Node.js

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
ENV NODE_ENV=production \
    PORT=3000
EXPOSE ${PORT}
# CMD seul : application standard
CMD ["node", "server.js"]
```

#### Outil CLI (curl wrapper)

```dockerfile
FROM alpine:3.19
RUN apk add --no-cache curl ca-certificates
# ENTRYPOINT + CMD : outil avec options par défaut
ENTRYPOINT ["curl", "-s"]
CMD ["--help"]
```

#### Application avec initialisation

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
# ENTRYPOINT + CMD : init script + commande par défaut
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:8000"]
```

#### Base de données avec initialisation

```dockerfile
FROM postgres:15-alpine
COPY init-scripts/ /docker-entrypoint-initdb.d/
# ENTRYPOINT : script d'init PostgreSQL
# CMD : commande PostgreSQL
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
```

### 🎯 Résumé et règles d'or

> [!tip] Règles de décision rapide
> 
> 1. **Voulez-vous que l'utilisateur puisse remplacer facilement la commande ?**
>     - Oui → `CMD` seul
>     - Non → `ENTRYPOINT`
> 2. **Votre image est-elle un outil ou un service ?**
>     - Outil → `ENTRYPOINT` (+ `CMD` pour options par défaut)
>     - Service → `CMD` seul
> 3. **Avez-vous besoin d'un script d'initialisation ?**
>     - Oui → `ENTRYPOINT` pour le script + `CMD` pour la commande
> 4. **Forme shell ou exec ?**
>     - **Toujours préférer la forme exec** sauf si vous avez absolument besoin d'un shell

> [!warning] Erreurs fréquentes à éviter
> 
> ```dockerfile
> # ❌ Forme shell qui empêche l'arrêt propre
> CMD npm start
> 
> # ✅ Forme exec qui permet les signaux
> CMD ["npm", "start"]
> 
> # ❌ Oublier exec dans un script entrypoint
> #!/bin/sh
> python app.py  # Le shell reste PID 1
> 
> # ✅ Utiliser exec pour remplacer le shell
> #!/bin/sh
> exec python app.py  # python devient PID 1
> ```

---

## 🎓 Récapitulatif des instructions essentielles

|Instruction|Rôle|Nombre par Dockerfile|Impact sur le cache|
|---|---|---|---|
|`FROM`|Image de base|1+ (multi-stage)|Invalide tout si changé|
|`RUN`|Exécuter des commandes|Plusieurs|Chaque RUN = nouvelle couche|
|`COPY`|Copier des fichiers|Plusieurs|Invalidé si fichiers changent|
|`ADD`|Copier + extraire/télécharger|Plusieurs|Invalidé si fichiers changent|
|`WORKDIR`|Définir répertoire de travail|Plusieurs|Faible impact|
|`ENV`|Variables d'environnement|Plusieurs|Faible impact|
|`EXPOSE`|Documenter les ports|Plusieurs|Aucun impact|
|`CMD`|Commande par défaut|1 seul actif|Aucun impact|
|`ENTRYPOINT`|Point d'entrée fixe|1 seul actif|Aucun impact|

### 🏆 Checklist finale pour un Dockerfile optimal

- [ ] **FROM** : Image de base légère et avec tag spécifique
- [ ] **RUN** : Commandes combinées pour minimiser les couches
- [ ] **COPY** : Fichiers de dépendances copiés avant le code source
- [ ] **WORKDIR** : Répertoire de travail défini clairement
- [ ] **ENV** : Variables d'environnement documentées, sans secrets
- [ ] **EXPOSE** : Ports documentés correspondant à l'application
- [ ] **CMD/ENTRYPOINT** : Forme exec utilisée, choix approprié au cas d'usage
- [ ] **Ordre optimisé** : Instructions qui changent rarement en premier
- [ ] **.dockerignore** : Fichiers inutiles exclus du contexte
- [ ] **Sécurité** : Utilisateur non-root, pas de secrets dans l'image

---

## 💡 Exemple complet d'un Dockerfile bien structuré

```dockerfile
# ========================================
# Stage 1: Builder
# ========================================
FROM node:18-alpine AS builder

# Métadonnées
LABEL maintainer="dev@example.com"
LABEL description="Application Node.js avec build multi-étapes"

# Variables de build
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Répertoire de travail
WORKDIR /app

# Copie des dépendances (cache optimisé)
COPY package*.json ./

# Installation des dépendances
RUN npm ci --only=production && \
    npm cache clean --force

# Copie du code source
COPY . .

# Build de l'application
RUN npm run build

# ========================================
# Stage 2: Production
# ========================================
FROM node:18-alpine

# Utilisateur non-root
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

# Variables d'environnement
ENV NODE_ENV=production \
    PORT=3000 \
    LOG_LEVEL=info

# Répertoire de travail
WORKDIR /app

# Copie depuis le builder
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup package*.json ./

# Changement d'utilisateur
USER appuser

# Port exposé
EXPOSE ${PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node healthcheck.js || exit 1

# Commande de démarrage
CMD ["node", "dist/server.js"]
```

Ce Dockerfile illustre toutes les bonnes pratiques :

- ✅ Build multi-étages pour réduire la taille
- ✅ Optimisation du cache avec l'ordre des instructions
- ✅ Utilisateur non-root pour la sécurité
- ✅ Variables d'environnement configurables
- ✅ Documentation complète avec LABEL et commentaires
- ✅ Health check pour la production
- ✅ Forme exec pour CMD

---

**Fin du cours sur les instructions essentielles du Dockerfile** 🎉