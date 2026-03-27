

## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 3 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## 🎯 Introduction au Dockerfile

Un **Dockerfile** est un fichier texte contenant une série d'instructions permettant de construire automatiquement une image Docker. Il définit l'environnement de votre application de manière reproductible et versionnée.

> [!info] Pourquoi utiliser un Dockerfile ?
> 
> - **Reproductibilité** : L'image sera identique à chaque construction
> - **Versioning** : Le Dockerfile peut être versionné avec Git
> - **Documentation** : Il documente l'environnement de l'application
> - **Automatisation** : Construction automatisée dans les pipelines CI/CD

---

## 📝 Syntaxe de base

### Règles fondamentales

```dockerfile
# Ceci est un commentaire
INSTRUCTION arguments
```

> [!warning] Points importants
> 
> - Les instructions sont **insensibles à la casse**, mais la convention est de les écrire en **MAJUSCULES**
> - Chaque instruction crée un nouveau **layer** dans l'image
> - Les commentaires commencent par `#`
> - L'ordre des instructions est crucial pour l'optimisation du cache
> - Le fichier doit s'appeler exactement `Dockerfile` (sans extension)

### Structure type d'un Dockerfile

```dockerfile
# Image de base
FROM image:tag

# Métadonnées
LABEL maintainer="email@example.com"

# Variables de build
ARG BUILD_VERSION=1.0

# Variables d'environnement
ENV APP_HOME=/app

# Répertoire de travail
WORKDIR ${APP_HOME}

# Installation de dépendances
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*

# Copie des fichiers
COPY . .

# Exposition de ports
EXPOSE 8080

# Utilisateur d'exécution
USER appuser

# Commande par défaut
CMD ["./start.sh"]
```

---

## 🔧 Instructions principales

### FROM

Définit l'image de base à partir de laquelle construire votre image.

**Syntaxe :**

```dockerfile
FROM <image>[:<tag>] [AS <name>]
```

**Exemples :**

```dockerfile
# Utiliser une image officielle
FROM python:3.11-slim

# Utiliser une version spécifique (recommandé)
FROM node:18.17.0-alpine

# Multi-stage build avec alias
FROM golang:1.21 AS builder
```

> [!tip] Bonnes pratiques
> 
> - Toujours spécifier un **tag précis** (pas `latest`) pour la reproductibilité
> - Privilégier les images **Alpine** ou **slim** pour réduire la taille
> - Vérifier la source de l'image (images officielles préférées)

> [!warning] Pièges courants
> 
> - Utiliser `latest` rend les builds non reproductibles
> - Les images Alpine utilisent `musl` au lieu de `glibc`, ce qui peut causer des incompatibilités

---

### RUN

Exécute une commande dans un nouveau layer et commit le résultat.

**Syntaxe :**

```dockerfile
# Shell form (exécuté dans /bin/sh -c)
RUN <commande>

# Exec form (exécution directe)
RUN ["executable", "param1", "param2"]
```

**Exemples :**

```dockerfile
# Installation de packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Création d'utilisateur
RUN useradd -m -u 1000 appuser

# Téléchargement de fichiers
RUN curl -fsSL https://example.com/file.tar.gz | tar -xz

# Exec form (évite l'interprétation du shell)
RUN ["/bin/bash", "-c", "echo hello"]
```

> [!tip] Optimisation
> 
> - **Chaîner les commandes** avec `&&` pour réduire le nombre de layers
> - **Nettoyer** les caches (apt, yum, apk) dans la même instruction
> - Mettre les commandes qui changent rarement **en premier** pour optimiser le cache
> - Utiliser `\` pour la lisibilité des longues commandes

```dockerfile
# ❌ Mauvais : crée 3 layers
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# ✅ Bon : crée 1 seul layer
RUN apt-get update \
    && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*
```

---

### COPY et ADD

Copient des fichiers/dossiers depuis le contexte de build vers l'image.

#### COPY

**Syntaxe :**

```dockerfile
COPY [--chown=<user>:<group>] <src>... <dest>
COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
```

**Exemples :**

```dockerfile
# Copier un fichier
COPY requirements.txt /app/

# Copier un dossier
COPY ./src /app/src

# Copier avec changement de propriétaire
COPY --chown=appuser:appuser app.py /app/

# Copier plusieurs fichiers
COPY package*.json ./

# Utiliser des wildcards
COPY *.conf /etc/nginx/
```

#### ADD

**Syntaxe identique à COPY**, mais avec des fonctionnalités supplémentaires :

```dockerfile
# Décompression automatique d'archives locales
ADD archive.tar.gz /app/

# Téléchargement depuis une URL
ADD https://example.com/file.txt /app/
```

> [!warning] COPY vs ADD
> 
> - **Privilégier COPY** : plus simple et prévisible
> - **Utiliser ADD uniquement** pour :
>     - Décompresser des archives locales (tar, gzip, bzip2, xz)
>     - Télécharger des fichiers depuis une URL (mais `RUN curl` est souvent préférable)

> [!tip] Bonnes pratiques
> 
> - Copier d'abord les fichiers de **dépendances** (package.json, requirements.txt) avant le code source pour optimiser le cache
> - Utiliser `.dockerignore` pour exclure les fichiers inutiles

```dockerfile
# ✅ Bon ordre pour le cache
COPY package.json package-lock.json ./
RUN npm install
COPY . .

# ❌ Mauvais : invalide le cache à chaque modification de code
COPY . .
RUN npm install
```

---

### WORKDIR

Définit le répertoire de travail pour les instructions suivantes.

**Syntaxe :**

```dockerfile
WORKDIR /chemin/vers/repertoire
```

**Exemples :**

```dockerfile
# Définir le répertoire de travail
WORKDIR /app

# Utiliser des chemins relatifs (relatifs au WORKDIR précédent)
WORKDIR /app
WORKDIR data  # Maintenant dans /app/data

# Utiliser des variables d'environnement
ENV APP_HOME=/application
WORKDIR ${APP_HOME}
```

> [!info] Comportement
> 
> - Crée le répertoire s'il n'existe pas
> - Peut être utilisé plusieurs fois dans un Dockerfile
> - Affecte `RUN`, `CMD`, `ENTRYPOINT`, `COPY`, `ADD`

> [!tip] Bonnes pratiques
> 
> - Préférer `WORKDIR` à `RUN cd /chemin` car cd ne persiste pas entre les layers
> - Utiliser des chemins absolus pour plus de clarté

```dockerfile
# ❌ Mauvais : cd ne persiste pas
RUN cd /app
RUN pwd  # Affiche / et non /app

# ✅ Bon
WORKDIR /app
RUN pwd  # Affiche /app
```

---

### ENV

Définit des variables d'environnement persistantes.

**Syntaxe :**

```dockerfile
ENV <key>=<value> ...
ENV <key> <value>
```

**Exemples :**

```dockerfile
# Définir une variable
ENV NODE_ENV=production

# Définir plusieurs variables
ENV APP_HOME=/app \
    APP_USER=appuser \
    APP_PORT=8080

# Utiliser une variable définie
ENV PATH="${APP_HOME}/bin:${PATH}"
```

> [!info] Comportement
> 
> - Les variables `ENV` sont disponibles :
>     - Pendant le **build** (instructions suivantes)
>     - Dans le **conteneur** en cours d'exécution
> - Peuvent être surchargées avec `docker run -e`

> [!warning] ENV vs ARG
> 
> - `ENV` : variables persistantes dans l'image finale et le conteneur
> - `ARG` : variables disponibles uniquement pendant le build

```dockerfile
# Exemple d'utilisation
ENV DATABASE_URL=postgresql://localhost/db
ENV LOG_LEVEL=info

# Ces variables seront accessibles dans l'application
CMD ["python", "app.py"]
```

---

### ARG

Définit des variables disponibles uniquement pendant le build.

**Syntaxe :**

```dockerfile
ARG <name>[=<default value>]
```

**Exemples :**

```dockerfile
# Définir un argument avec valeur par défaut
ARG PYTHON_VERSION=3.11

# Utiliser l'argument
FROM python:${PYTHON_VERSION}-slim

# Argument sans valeur par défaut
ARG BUILD_DATE

# Convertir ARG en ENV pour le rendre disponible au runtime
ARG APP_VERSION=1.0.0
ENV APP_VERSION=${APP_VERSION}

# Arguments prédéfinis par Docker
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM"
```

**Utilisation lors du build :**

```bash
docker build --build-arg PYTHON_VERSION=3.12 -t myapp .
docker build --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") -t myapp .
```

> [!tip] Bonnes pratiques
> 
> - Définir des valeurs par défaut raisonnables
> - Utiliser `ARG` pour les versions de dépendances
> - Documenter les arguments disponibles dans un README

> [!warning] Portée des ARG
> 
> - `ARG` avant `FROM` : disponible uniquement pour `FROM`
> - `ARG` après `FROM` : disponible pour toutes les instructions suivantes dans ce stage

```dockerfile
# ARG avant FROM (pour choisir l'image de base)
ARG BASE_IMAGE=node:18
FROM ${BASE_IMAGE}

# ARG après FROM (redéfinition nécessaire)
ARG BASE_IMAGE
RUN echo "Using base image: ${BASE_IMAGE}"

ARG NODE_ENV=production
RUN npm install --${NODE_ENV}
```

---

### EXPOSE

Documente les ports sur lesquels le conteneur écoute.

**Syntaxe :**

```dockerfile
EXPOSE <port> [<port>/<protocol>...]
```

**Exemples :**

```dockerfile
# Exposer un port TCP (par défaut)
EXPOSE 8080

# Exposer plusieurs ports
EXPOSE 80 443

# Spécifier le protocole
EXPOSE 53/udp
EXPOSE 53/tcp

# Utiliser une variable
ENV APP_PORT=3000
EXPOSE ${APP_PORT}
```

> [!warning] EXPOSE ne publie pas les ports
> 
> - `EXPOSE` est **uniquement documentaire**
> - Pour publier réellement les ports, utiliser `-p` ou `-P` avec `docker run`

```bash
# Publier le port explicitement
docker run -p 8080:8080 myapp

# Publier tous les ports EXPOSE automatiquement
docker run -P myapp
```

> [!tip] Utilité
> 
> - Documentation pour les développeurs
> - Utilisé par `docker run -P` pour publier automatiquement
> - Visible avec `docker inspect`

---

### CMD

Définit la commande par défaut à exécuter au lancement du conteneur.

**Syntaxe :**

```dockerfile
# Exec form (recommandée)
CMD ["executable", "param1", "param2"]

# Shell form
CMD commande param1 param2

# Paramètres par défaut pour ENTRYPOINT
CMD ["param1", "param2"]
```

**Exemples :**

```dockerfile
# Lancer une application Node.js
CMD ["node", "server.js"]

# Lancer un shell (shell form)
CMD npm start

# Avec ENTRYPOINT (voir section ENTRYPOINT)
ENTRYPOINT ["python"]
CMD ["app.py"]  # Argument par défaut

# Script shell
CMD ["/bin/bash", "-c", "echo Hello && sleep 3600"]
```

> [!info] Comportement
> 
> - Une seule instruction `CMD` par Dockerfile (la dernière compte)
> - Peut être **surchargée** en ligne de commande

```bash
# Utiliser la CMD par défaut
docker run myapp

# Surcharger la CMD
docker run myapp python other_script.py
```

> [!warning] Exec form vs Shell form **Exec form** `["executable", "param"]` :
> 
> - ✅ Pas d'interprétation shell (pas de variables `$VAR`, pas de `&&`)
> - ✅ Le processus reçoit directement les signaux (SIGTERM)
> - ✅ PID 1 correct
> 
> **Shell form** `commande param` :
> 
> - ✅ Interprétation shell (variables, pipes, &&)
> - ❌ Le shell devient PID 1, pas l'application
> - ❌ Les signaux ne sont pas correctement propagés

```dockerfile
# ❌ Problème : bash est PID 1, pas node
CMD npm start

# ✅ Solution : exec form
CMD ["npm", "start"]

# ✅ Ou utiliser exec dans le shell
CMD ["sh", "-c", "exec npm start"]
```

---

### ENTRYPOINT

Définit l'exécutable principal du conteneur.

**Syntaxe :**

```dockerfile
# Exec form (recommandée)
ENTRYPOINT ["executable", "param1", "param2"]

# Shell form
ENTRYPOINT commande param1 param2
```

**Exemples :**

```dockerfile
# Conteneur exécutant toujours Python
ENTRYPOINT ["python"]
CMD ["app.py"]  # Argument par défaut

# Script d'initialisation
ENTRYPOINT ["./docker-entrypoint.sh"]

# Application avec arguments
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
```

**Utilisation :**

```bash
# Utilise CMD par défaut : python app.py
docker run myapp

# Surcharge CMD : python script.py
docker run myapp script.py

# Pour surcharger ENTRYPOINT, utiliser --entrypoint
docker run --entrypoint bash myapp
```

> [!info] ENTRYPOINT vs CMD
> 
> |Aspect|CMD|ENTRYPOINT|
> |---|---|---|
> |Objectif|Commande par défaut|Exécutable principal|
> |Surcharge|Facile (`docker run myapp cmd`)|Difficile (`--entrypoint`)|
> |Usage typique|Arguments flexibles|Comportement fixe|
> |Combinaison|Arguments pour ENTRYPOINT|Exécutable pour CMD|

**Pattern classique : ENTRYPOINT + CMD**

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]

# docker run myapp          → python app.py
# docker run myapp test.py  → python test.py
```

```dockerfile
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["start"]

# docker-entrypoint.sh peut faire de l'init puis exec "$@"
# docker run myapp          → ./docker-entrypoint.sh start
# docker run myapp backup   → ./docker-entrypoint.sh backup
```

> [!tip] Script entrypoint type

```dockerfile
#!/bin/bash
set -e

# Initialisation (base de données, configs...)
echo "Initializing..."

# Exécuter la commande passée (CMD ou arguments)
exec "$@"
```

---

### USER

Définit l'utilisateur (et optionnellement le groupe) pour les instructions suivantes et le runtime.

**Syntaxe :**

```dockerfile
USER <user>[:<group>]
USER <UID>[:<GID>]
```

**Exemples :**

```dockerfile
# Créer un utilisateur et l'utiliser
RUN useradd -m -u 1000 appuser
USER appuser

# Utiliser un utilisateur existant
USER node

# Spécifier utilisateur et groupe
USER appuser:appgroup

# Utiliser des UID/GID numériques
USER 1000:1000

# Revenir à root temporairement puis repasser à l'utilisateur
USER root
RUN apt-get install -y some-package
USER appuser
```

> [!warning] Sécurité importante
> 
> - **Ne jamais** exécuter l'application en tant que `root` en production
> - Créer un utilisateur dédié avec des privilèges minimaux
> - Définir `USER` avant `CMD`/`ENTRYPOINT`

```dockerfile
# ❌ Mauvais : l'application tourne en root
FROM python:3.11
COPY . /app
CMD ["python", "app.py"]

# ✅ Bon : utilisateur non-privilégié
FROM python:3.11
RUN useradd -m -u 1000 appuser
WORKDIR /app
COPY --chown=appuser:appuser . .
USER appuser
CMD ["python", "app.py"]
```

> [!tip] Bonnes pratiques
> 
> - Utiliser des UID/GID >= 1000 (conventionnels pour les utilisateurs non-système)
> - Changer le propriétaire des fichiers avec `COPY --chown`
> - Les images officielles (node, python) ont souvent un utilisateur non-root prédéfini

---

### VOLUME

Crée un point de montage pour les volumes externes.

**Syntaxe :**

```dockerfile
VOLUME ["/data"]
VOLUME /data /logs
```

**Exemples :**

```dockerfile
# Volume unique
VOLUME /var/lib/mysql

# Multiples volumes
VOLUME ["/app/data", "/app/logs"]

# Avec variable
ENV DATA_DIR=/data
VOLUME ${DATA_DIR}
```

> [!info] Comportement
> 
> - Crée un point de montage qui sera **persistent** et **partageable**
> - Les données dans ces répertoires ne sont **pas incluses** dans l'image lors du commit
> - Docker créera automatiquement un volume anonyme si non spécifié au `docker run`

```bash
# Docker crée un volume anonyme
docker run myapp

# Spécifier un volume nommé
docker run -v mydata:/var/lib/mysql myapp

# Bind mount (dossier hôte)
docker run -v /host/path:/container/path myapp
```

> [!warning] Limitations
> 
> - Les données ajoutées après `VOLUME` dans le Dockerfile ne seront **pas persistées**
> - Vous ne pouvez pas modifier le contenu d'un volume via Dockerfile après l'avoir déclaré

```dockerfile
# ❌ Mauvais : les données seront perdues
VOLUME /app/data
RUN echo "config" > /app/data/config.txt

# ✅ Bon : préparer les données avant VOLUME
RUN echo "config" > /app/data/config.txt
VOLUME /app/data
```

> [!tip] Quand utiliser VOLUME
> 
> - Bases de données (PostgreSQL, MySQL, MongoDB)
> - Logs d'application
> - Fichiers uploadés par les utilisateurs
> - Tout contenu qui doit survivre au cycle de vie du conteneur

---

### LABEL

Ajoute des métadonnées à l'image sous forme de paires clé-valeur.

**Syntaxe :**

```dockerfile
LABEL <key>=<value> <key>=<value> ...
```

**Exemples :**

```dockerfile
# Labels basiques
LABEL version="1.0"
LABEL description="Mon application Docker"

# Labels multiples (recommandé)
LABEL maintainer="dev@example.com" \
      version="1.0.0" \
      description="Application de démonstration" \
      org.opencontainers.image.authors="John Doe"

# Labels avec espaces (utiliser des guillemets)
LABEL com.example.label-with-value="valeur avec espaces"

# Labels avec variables
ARG VERSION=1.0.0
LABEL version="${VERSION}"
```

> [!info] Conventions de nommage
> 
> - Utiliser la notation **reverse-DNS** : `com.example.key`
> - Standards OCI : `org.opencontainers.image.*`
>     - `org.opencontainers.image.created`
>     - `org.opencontainers.image.authors`
>     - `org.opencontainers.image.url`
>     - `org.opencontainers.image.version`
>     - `org.opencontainers.image.title`
>     - `org.opencontainers.image.description`

**Consulter les labels :**

```bash
docker inspect myapp | jq '.[0].Config.Labels'
```

> [!tip] Utilisations courantes
> 
> - Informations de version et build
> - Métadonnées CI/CD (commit SHA, build number)
> - Documentation (maintainer, description)
> - Automation et filtering d'images

```dockerfile
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.authors="team@example.com" \
      org.opencontainers.image.url="https://example.com" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.title="MyApp" \
      org.opencontainers.image.description="Application de démonstration Docker"
```

---

### HEALTHCHECK

Définit comment tester la santé du conteneur.

**Syntaxe :**

```dockerfile
HEALTHCHECK [OPTIONS] CMD command
HEALTHCHECK NONE  # Désactiver les healthchecks hérités
```

**Options disponibles :**

- `--interval=DURATION` (défaut: 30s) : délai entre deux checks
- `--timeout=DURATION` (défaut: 30s) : timeout d'un check
- `--start-period=DURATION` (défaut: 0s) : délai avant le premier check
- `--retries=N` (défaut: 3) : nombre d'échecs consécutifs avant `unhealthy`

**Exemples :**

```dockerfile
# Check HTTP simple
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Check avec wget
HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Check de base de données
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
  CMD pg_isready -U postgres || exit 1

# Check avec script personnalisé
HEALTHCHECK CMD /app/healthcheck.sh

# Désactiver l'healthcheck
HEALTHCHECK NONE
```

> [!info] Codes de retour
> 
> - **0** : success - le conteneur est sain
> - **1** : unhealthy - le conteneur ne fonctionne pas correctement
> - **2** : reserved - ne pas utiliser ce code de sortie

**États du conteneur :**

- `starting` : période de démarrage
- `healthy` : check réussi
- `unhealthy` : plusieurs checks ont échoué

```bash
# Voir le statut health
docker ps
docker inspect --format='{{.State.Health.Status}}' container_name

# Voir l'historique des checks
docker inspect container_name | jq '.[0].State.Health'
```

> [!warning] Attention aux ressources
> 
> - Le healthcheck s'exécute **dans le conteneur**
> - Éviter les checks trop lourds ou fréquents
> - Prévoir suffisamment de `start-period` pour le démarrage de l'application

> [!tip] Bonnes pratiques
> 
> - Toujours définir un healthcheck pour les services en production
> - Tester un endpoint dédié `/health` plutôt que la page d'accueil
> - Adapter `start-period` au temps de démarrage réel de l'application
> - Utiliser des outils légers (curl, wget, scripts shell)

```dockerfile
# ✅ Healthcheck optimisé pour une app Node.js
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1); }).on('error', () => process.exit(1));"
```

---

### ONBUILD

Ajoute une instruction déclenchée lorsque l'image est utilisée comme base d'une autre image.

**Syntaxe :**

```dockerfile
ONBUILD <INSTRUCTION>
```

**Exemples :**

```dockerfile
# Image de base pour applications Node.js
FROM node:18
WORKDIR /app

# Ces instructions s'exécuteront dans les images enfants
ONBUILD COPY package*.json ./
ONBUILD RUN npm install
ONBUILD COPY . .

# Image enfant
FROM mon-image-node-base
# Les ONBUILD s'exécutent automatiquement ici
CMD ["npm", "start"]
```

> [!info] Comportement
> 
> - Les instructions `ONBUILD` sont stockées dans l'image et ne s'exécutent **pas** lors de sa construction
> - Elles s'exécutent lors de la construction d'une image **basée** sur cette image
> - Utile pour créer des images "template"

> [!warning] Limitations
> 
> - Ne peut pas enchaîner : `ONBUILD ONBUILD ...` (interdit)
> - N'affecte pas les instructions `FROM` ou `MAINTAINER`
> - Rarement utilisé, peut rendre le Dockerfile moins lisible
> - Les images officielles évitent généralement `ONBUILD`

> [!tip] Cas d'usage
> 
> - Images de base partagées dans une organisation
> - Standardisation du build pour plusieurs applications similaires
> - Mais préférer souvent la composition explicite pour plus de clarté

---

### SHELL

Change le shell par défaut utilisé pour la forme shell des commandes.

**Syntaxe :**

```dockerfile
SHELL ["executable", "parameters"]
```

**Exemples :**

```dockerfile
# Changer pour bash (par défaut c'est /bin/sh -c)
SHELL ["/bin/bash", "-c"]

# PowerShell sur Windows
SHELL ["powershell", "-command"]

# Bash avec options strictes
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Utilisation
RUN echo "Cette commande utilise le nouveau shell"
```

> [!info] Impact
> 
> - Affecte toutes les instructions en forme shell après `SHELL` :
>     - `RUN commande`
>     - `CMD commande`
>     - `ENTRYPOINT commande`
> - N'affecte pas la forme exec : `RUN ["cmd", "param"]`

> [!tip] Bash strict mode

```dockerfile
# Activer les meilleures pratiques bash
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# -e : exit si une commande échoue
# -u : exit si variable non définie
# -o pipefail : fail si une commande dans un pipe échoue

RUN apt-get update && apt-get install -y curl
```

> [!warning] Compatibilité
> 
> - Sur Alpine Linux, `/bin/bash` peut ne pas être disponible (utilise `/bin/sh`)
> - Sur Windows, ajuster pour `cmd` ou `powershell`

---

### STOPSIGNAL

Définit le signal système envoyé au conteneur pour l'arrêter.

**Syntaxe :**

```dockerfile
STOPSIGNAL signal
```

**Exemples :**

```dockerfile
# Signal par défaut (SIGTERM)
STOPSIGNAL SIGTERM

# Utiliser SIGQUIT
STOPSIGNAL SIGQUIT

# Ou en numérique
STOPSIGNAL 9  # SIGKILL (déconseillé)
```

> [!info] Signaux communs
> 
> - **SIGTERM (15)** : Arrêt gracieux (défaut)
> - **SIGINT (2)** : Interruption (Ctrl+C)
> - **SIGQUIT (3)** : Arrêt avec core dump
> - **SIGKILL (9)** : Arrêt forcé immédiat (à éviter)

**Fonctionnement :**

```bash
# docker stop envoie STOPSIGNAL au conteneur
docker stop mycontainer

# Attend jusqu'à 10s (défaut) puis envoie SIGKILL
docker stop --time=30 mycontainer
```

> [!tip] Quand modifier STOPSIGNAL
> 
> - Applications nécessitant un signal spécifique pour un arrêt propre
> - Certaines bases de données ou serveurs web
> - Par défaut, `SIGTERM` convient à la plupart des applications

> [!warning] À éviter
> 
> - Ne pas utiliser `SIGKILL` comme STOPSIGNAL
> - Permet d'avoir un arrêt gracieux (fermeture des connexions, sauvegarde de l'état)

```dockerfile
# Application Node.js qui gère SIGTERM
FROM node:18-alpine
COPY . /app
WORKDIR /app
STOPSIGNAL SIGTERM
CMD ["node", "server.js"]
```

---

## 🔄 Ordre d'exécution et layers

### Concept de layers

Chaque instruction dans un Dockerfile crée un **layer** (couche) dans l'image finale. Les layers sont :

- **Immuables** : une fois créés, ils ne changent pas
- **Cachés** : Docker réutilise les layers non modifiés
- **Empilés** : l'image finale est la somme de tous les layers

```dockerfile
FROM ubuntu:22.04          # Layer 1
RUN apt-get update         # Layer 2
RUN apt-get install -y git # Layer 3
COPY . /app                # Layer 4
```

> [!info] Cache Docker Docker utilise un système de cache intelligent :
> 
> - Si une instruction n'a pas changé, Docker réutilise le layer du cache
> - Si une instruction change, tous les layers suivants sont reconstruits
> - Le cache se base sur le contenu (checksum) des instructions et fichiers

### Optimisation de l'ordre

**Principe clé** : Placer les instructions qui changent rarement **en premier** et celles qui changent souvent **à la fin**.

```dockerfile
# ✅ Bon ordre (optimisé pour le cache)
FROM python:3.11-slim

# 1. Installation de dépendances système (change rarement)
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 2. Copie des fichiers de dépendances (change moyennement)
WORKDIR /app
COPY requirements.txt .

# 3. Installation des dépendances Python (change moyennement)
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copie du code source (change souvent)
COPY . .

# 5. Commande d'exécution
CMD ["python", "app.py"]
```

```dockerfile
# ❌ Mauvais ordre (pas de cache efficace)
FROM python:3.11-slim

# Copier tout d'abord invalide le cache à chaque modification
COPY . /app
WORKDIR /app

# Ces layers seront reconstruits à chaque fois
RUN apt-get update && apt-get install -y gcc
RUN pip install -r requirements.txt

CMD ["python", "app.py"]
```

### Impact sur la taille de l'image

> [!warning] Les layers s'accumulent Chaque instruction `RUN`, `COPY`, `ADD` ajoute de la taille à l'image, même si vous supprimez des fichiers dans un layer suivant.

```dockerfile
# ❌ Mauvais : 3 layers, fichiers temporaires conservés
RUN apt-get update                           # Layer 1 : +50MB
RUN apt-get install -y wget                  # Layer 2 : +100MB
RUN rm -rf /var/lib/apt/lists/*              # Layer 3 : +0MB (mais layers précédents gardent les fichiers)

# ✅ Bon : 1 layer, nettoyage dans la même instruction
RUN apt-get update \
    && apt-get install -y wget \
    && rm -rf /var/lib/apt/lists/*          # Layer 1 : +100MB seulement
```

### Exemple complet optimisé

```dockerfile
FROM node:18-alpine AS builder

# Layer 1 : métadonnées (change rarement)
LABEL maintainer="dev@example.com"
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Layer 2 : dépendances système (change très rarement)
RUN apk add --no-cache \
    python3 \
    make \
    g++

# Layer 3 : répertoire de travail
WORKDIR /app

# Layer 4 : fichiers de dépendances (change moyennement)
COPY package.json package-lock.json ./

# Layer 5 : installation dépendances (change moyennement)
RUN npm ci --only=production

# Layer 6 : code source (change souvent)
COPY . .

# Layer 7 : build (si nécessaire)
RUN npm run build

# Image finale
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package.json .

USER node
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

---

## ✨ Bonnes pratiques générales

### 1. Minimiser le nombre de layers

```dockerfile
# ❌ Mauvais : trop de layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get install -y vim

# ✅ Bon : instructions groupées
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*
```

### 2. Utiliser .dockerignore

Créer un fichier `.dockerignore` pour exclure les fichiers inutiles du contexte de build :

```dockerignore
# Fichiers de version
.git
.gitignore
.dockerignore

# Dépendances
node_modules
__pycache__
*.pyc
venv

# Logs et données temporaires
*.log
tmp/
*.tmp

# Documentation
README.md
docs/

# Fichiers de développement
.env.local
docker-compose.yml
Dockerfile
```

> [!tip] Impact
> 
> - Accélère le build (moins de fichiers à transférer)
> - Réduit la taille de l'image
> - Évite d'inclure des secrets par accident

### 3. Multi-stage builds

Utiliser plusieurs stages `FROM` pour réduire la taille de l'image finale :

```dockerfile
# Stage 1 : Build
FROM golang:1.21 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o app

# Stage 2 : Production (image finale minimaliste)
FROM alpine:3.18
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/app /usr/local/bin/app
USER nobody
ENTRYPOINT ["app"]
```

### 4. Sécurité

```dockerfile
# ✅ Bonnes pratiques de sécurité

# 1. Utiliser des images officielles avec tags précis
FROM python:3.11.6-slim

# 2. Mettre à jour les packages (mais nettoyer après)
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. Créer un utilisateur non-root
RUN useradd -m -u 1000 appuser \
    && chown -R appuser:appuser /app

# 4. Ne pas exposer de secrets
# ❌ Mauvais : ARG PASSWORD=secret123
# ✅ Bon : utiliser des secrets Docker ou variables d'environnement au runtime

WORKDIR /app
COPY --chown=appuser:appuser . .

# 5. Exécuter en tant qu'utilisateur non-root
USER appuser

# 6. Scanner l'image avec des outils de sécurité
# docker scan myimage
```

### 5. Lisibilité et maintenance

```dockerfile
# ✅ Dockerfile bien structuré et commenté

# Image de base
FROM node:18-alpine AS base
LABEL maintainer="team@example.com" \
      version="1.0.0"

# Stage de build
FROM base AS builder
WORKDIR /app

# Installation des dépendances de build
RUN apk add --no-cache \
    python3 \
    make \
    g++

# Copie et installation des dépendances
COPY package*.json ./
RUN npm ci

# Copie du code et build
COPY . .
RUN npm run build

# Image de production
FROM base AS production
WORKDIR /app

# Copie uniquement des artefacts nécessaires
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package.json .

# Configuration finale
ENV NODE_ENV=production
USER node
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD node healthcheck.js

CMD ["node", "dist/server.js"]
```

### 6. Variables et arguments

```dockerfile
# ✅ Utiliser des variables pour la flexibilité

# Arguments de build
ARG NODE_VERSION=18
ARG APP_VERSION=1.0.0

# Image avec version paramétrable
FROM node:${NODE_VERSION}-alpine

# Convertir en variable d'environnement si nécessaire
ENV APP_VERSION=${APP_VERSION}

# Utiliser dans les labels
LABEL version="${APP_VERSION}"

# Variables d'environnement avec valeurs par défaut
ENV PORT=3000 \
    NODE_ENV=production \
    LOG_LEVEL=info
```

### 7. Optimisation de la taille

```dockerfile
# ✅ Techniques pour réduire la taille

# 1. Utiliser des images Alpine
FROM node:18-alpine  # ~170MB au lieu de ~900MB avec node:18

# 2. Multi-stage builds
FROM node:18 AS builder
# ... build ...
FROM node:18-alpine AS production
COPY --from=builder /app/dist ./dist

# 3. Nettoyer les caches
RUN apt-get update && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*  # Nettoyer apt cache

RUN npm ci --only=production \
    && npm cache clean --force  # Nettoyer npm cache

# 4. Utiliser --no-install-recommends (Debian/Ubuntu)
RUN apt-get install -y --no-install-recommends curl

# 5. Installer uniquement les dépendances de production
RUN pip install --no-cache-dir -r requirements.txt
```

### 8. Reproductibilité

```dockerfile
# ✅ Assurer la reproductibilité des builds

# 1. Tags précis (jamais 'latest')
FROM python:3.11.6-slim  # ✅ version précise
# FROM python:3.11       # ⚠️ peut changer
# FROM python:latest     # ❌ non reproductible

# 2. Fixer les versions des dépendances
COPY requirements.txt .  # Avec versions pinnées : requests==2.31.0
RUN pip install -r requirements.txt

# 3. Utiliser des checksums si possible
ARG PACKAGE_SHA256=abc123...
RUN curl -fsSL https://example.com/package.tar.gz -o package.tar.gz \
    && echo "${PACKAGE_SHA256}  package.tar.gz" | sha256sum -c - \
    && tar -xzf package.tar.gz

# 4. Documenter les versions dans les labels
ARG BUILD_DATE
ARG GIT_SHA
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${GIT_SHA}"
```

### 9. Documentation intégrée

```dockerfile
# ✅ Documenter le Dockerfile

# ==============================================================================
# Image Docker pour MyApp
# ==============================================================================
# Cette image contient une application Node.js avec les dépendances suivantes :
# - Node.js 18 (Alpine)
# - PostgreSQL client
# - Redis client
#
# Variables d'environnement requises :
# - DATABASE_URL : URL de connexion PostgreSQL
# - REDIS_URL : URL de connexion Redis
#
# Ports exposés :
# - 3000 : API HTTP
#
# Build : docker build -t myapp:1.0.0 .
# Run : docker run -p 3000:3000 -e DATABASE_URL=... myapp:1.0.0
# ==============================================================================

FROM node:18-alpine

# Métadonnées
LABEL maintainer="dev@example.com" \
      description="Application MyApp avec Node.js et PostgreSQL"

# Configuration
ENV NODE_ENV=production \
    PORT=3000

# Installation et configuration
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .

# Sécurité : utilisateur non-root
USER node

# Port et healthcheck
EXPOSE 3000
HEALTHCHECK CMD node healthcheck.js

# Lancement
CMD ["node", "server.js"]
```

### 10. Tests et validation

```bash
# Construire l'image
docker build -t myapp:test .

# Vérifier la taille
docker images myapp:test

# Scanner les vulnérabilités
docker scout cves myapp:test
# ou
trivy image myapp:test

# Tester l'image
docker run --rm myapp:test --version

# Inspecter les layers
docker history myapp:test

# Analyser l'efficacité
dive myapp:test
```

---

## 🎯 Récapitulatif

### Ordre recommandé des instructions

```dockerfile
# 1. Image de base
FROM image:tag

# 2. Métadonnées
LABEL key="value"
ARG BUILD_ARG

# 3. Variables d'environnement
ENV VAR=value

# 4. Dépendances système (change rarement)
RUN apt-get update && apt-get install -y ...

# 5. Répertoire de travail
WORKDIR /app

# 6. Fichiers de dépendances (change moyennement)
COPY package.json requirements.txt .

# 7. Installation des dépendances
RUN npm install / pip install

# 8. Code source (change souvent)
COPY . .

# 9. Build si nécessaire
RUN npm run build

# 10. Configuration utilisateur
USER appuser

# 11. Exposition de ports
EXPOSE 8080

# 12. Volumes
VOLUME /data

# 13. Healthcheck
HEALTHCHECK CMD curl -f http://localhost:8080/health

# 14. Point d'entrée et commande
ENTRYPOINT ["executable"]
CMD ["param"]
```

### Checklist finale

> [!tip] Avant de pusher votre Dockerfile
> 
> - ✅ Image de base avec tag précis (pas `latest`)
> - ✅ Instructions groupées pour réduire les layers
> - ✅ Cache APT/YUM/APK nettoyé dans chaque RUN
> - ✅ .dockerignore configuré
> - ✅ Utilisateur non-root défini
> - ✅ Ports documentés avec EXPOSE
> - ✅ HEALTHCHECK défini pour les services
> - ✅ Variables sensibles gérées au runtime (pas hardcodées)
> - ✅ Multi-stage builds pour les applications compilées
> - ✅ Labels et métadonnées ajoutées
> - ✅ Commentaires pour les sections complexes
> - ✅ Image testée et scannée pour les vulnérabilités

---

**🎓 Fin du cours sur la structure d'un Dockerfile**