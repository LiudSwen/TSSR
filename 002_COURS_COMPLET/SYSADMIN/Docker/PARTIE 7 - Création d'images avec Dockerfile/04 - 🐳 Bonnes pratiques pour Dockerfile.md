

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

Les bonnes pratiques dans la création de Dockerfiles permettent de construire des images **performantes**, **légères** et **maintenables**. Une mauvaise construction peut entraîner des images volumineuses, des temps de build longs et des problèmes de sécurité. Cette partie couvre les techniques essentielles pour optimiser vos Dockerfiles.

---

## 🔄 Optimisation des layers

### Comprendre le système de layers

Chaque instruction dans un Dockerfile crée un nouveau **layer** (couche). Docker utilise un système de cache pour ces layers, ce qui permet de :

- Accélérer les builds successifs
- Partager des layers entre différentes images
- Réduire l'espace disque utilisé

> [!info] Principe fondamental Une fois qu'un layer est modifié, tous les layers suivants doivent être reconstruits, même s'ils n'ont pas changé. C'est pourquoi l'ordre des instructions est crucial.

### Regrouper les commandes RUN

❌ **Mauvaise pratique** : Chaque RUN crée un layer

```dockerfile
FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get install -y vim
```

✅ **Bonne pratique** : Regrouper les commandes

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*
```

> [!tip] Avantages du regroupement
> 
> - Moins de layers = image plus légère
> - Nettoyage du cache apt dans le même layer
> - Build plus rapide après modification

### Nettoyer dans le même layer

> [!warning] Erreur courante Nettoyer dans un layer séparé ne réduit PAS la taille de l'image finale, car les fichiers existent toujours dans le layer précédent.

❌ **Inefficace** :

```dockerfile
RUN apt-get update && apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*  # Trop tard, le cache existe déjà dans le layer précédent
```

✅ **Efficace** :

```dockerfile
RUN apt-get update && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*  # Nettoyage dans le même layer
```

### Minimiser le nombre de layers

> [!example] Exemple pratique
> 
> **Avant optimisation** : 8 layers, 450 MB
> 
> ```dockerfile
> FROM node:18
> RUN apt-get update
> RUN apt-get install -y python3
> RUN apt-get install -y build-essential
> RUN npm install -g typescript
> RUN npm install -g nodemon
> COPY package.json .
> RUN npm install
> COPY . .
> ```
> 
> **Après optimisation** : 5 layers, 380 MB
> 
> ```dockerfile
> FROM node:18-slim
> 
> RUN apt-get update && apt-get install -y \
>     python3 \
>     build-essential \
>     && rm -rf /var/lib/apt/lists/* \
>     && npm install -g typescript nodemon
> 
> COPY package.json .
> RUN npm install
> COPY . .
> ```

### Utiliser .dockerignore

Le fichier `.dockerignore` fonctionne comme `.gitignore` et permet d'exclure des fichiers du contexte de build.

```bash
# .dockerignore
node_modules
npm-debug.log
.env
.git
.gitignore
README.md
.vscode
*.md
```

> [!tip] Impact sur les performances Un `.dockerignore` bien configuré peut réduire drastiquement le temps de build en excluant des fichiers inutiles du contexte envoyé au démon Docker.

---

## 📊 Ordre des instructions

### Le principe du cache Docker

Docker met en cache chaque layer. Si une instruction change, **tous les layers suivants sont invalidés** et doivent être reconstruits.

> [!info] Règle d'or Placez les instructions qui changent **rarement** en haut du Dockerfile, et celles qui changent **fréquemment** en bas.

### Structure optimale d'un Dockerfile

```dockerfile
# 1. Image de base (change très rarement)
FROM node:18-alpine

# 2. Installation des dépendances système (change rarement)
RUN apk add --no-cache python3 make g++

# 3. Définition du working directory (change rarement)
WORKDIR /app

# 4. Copie des fichiers de dépendances (change occasionnellement)
COPY package.json package-lock.json ./

# 5. Installation des dépendances (change occasionnellement)
RUN npm ci --only=production

# 6. Copie du code source (change fréquemment)
COPY . .

# 7. Configuration runtime (change rarement)
EXPOSE 3000
ENV NODE_ENV=production

# 8. Commande de démarrage (change rarement)
CMD ["node", "server.js"]
```

### Exemples de mauvais ordre

❌ **Mauvais** : Le code est copié avant les dépendances

```dockerfile
FROM node:18
WORKDIR /app

# À chaque modification du code, npm install sera relancé !
COPY . .
RUN npm install

CMD ["node", "server.js"]
```

✅ **Bon** : Les dépendances sont installées avant le code

```dockerfile
FROM node:18
WORKDIR /app

# npm install n'est relancé que si package.json change
COPY package.json package-lock.json ./
RUN npm install

# Le code peut changer sans invalider le cache npm
COPY . .

CMD ["node", "server.js"]
```

### Tableau comparatif des fréquences de changement

|Instruction|Fréquence de changement|Position recommandée|
|---|---|---|
|FROM|Très rare|⬆️ Tout en haut|
|RUN (dépendances système)|Rare|⬆️ Haut|
|WORKDIR|Très rare|⬆️ Haut|
|COPY (package.json)|Occasionnelle|➡️ Milieu|
|RUN (npm install)|Occasionnelle|➡️ Milieu|
|COPY (code source)|Très fréquente|⬇️ Bas|
|ENV, EXPOSE|Rare|⬇️ Bas|
|CMD, ENTRYPOINT|Très rare|⬇️ Tout en bas|

> [!tip] Optimisation pour le développement Pendant le développement, vous modifierez souvent votre code mais rarement vos dépendances. Séparer `COPY package.json` et `COPY . .` permet de tirer parti du cache Docker et d'accélérer considérablement les builds.

---

## 🏗️ Multi-stage builds

### Qu'est-ce qu'un multi-stage build ?

Un **multi-stage build** permet d'utiliser plusieurs instructions `FROM` dans un seul Dockerfile. Chaque `FROM` démarre une nouvelle étape (stage) et peut utiliser une image de base différente.

> [!info] Utilité principale Les multi-stage builds permettent de **séparer la phase de build de la phase d'exécution**, résultant en des images finales beaucoup plus légères.

### Structure de base

```dockerfile
# Stage 1 : Build
FROM node:18 AS builder
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

# Stage 2 : Production
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/server.js"]
```

### Exemple concret avec une application Go

```dockerfile
# === Stage 1 : Compilation ===
FROM golang:1.21 AS builder

WORKDIR /app

# Copie des fichiers de dépendances
COPY go.mod go.sum ./
RUN go mod download

# Copie du code source et compilation
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# === Stage 2 : Image finale ===
FROM alpine:latest

# Installation de certificats SSL si nécessaire
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copie uniquement du binaire compilé depuis le stage builder
COPY --from=builder /app/main .

CMD ["./main"]
```

> [!example] Comparaison de tailles
> 
> - **Sans multi-stage** : golang:1.21 ≈ 900 MB
> - **Avec multi-stage** : alpine + binaire ≈ 15 MB
> 
> **Gain : ~885 MB (98% de réduction !)**

### Avantages des multi-stage builds

|Avantage|Description|
|---|---|
|🪶 **Image légère**|Seuls les fichiers nécessaires à l'exécution sont dans l'image finale|
|🔒 **Sécurité**|Les outils de build ne sont pas présents en production|
|🧹 **Propreté**|Pas besoin de scripts de nettoyage complexes|
|📦 **Séparation des concerns**|Build et runtime sont clairement séparés|

### Multi-stage avec plusieurs targets

Vous pouvez nommer vos stages et les cibler lors du build :

```dockerfile
# Stage de développement
FROM node:18 AS development
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]

# Stage de build
FROM node:18 AS builder
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

# Stage de production
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/server.js"]
```

**Utilisation** :

```bash
# Build pour le développement
docker build --target development -t myapp:dev .

# Build pour la production (par défaut, le dernier stage)
docker build -t myapp:prod .
```

> [!warning] Attention aux chemins Quand vous utilisez `COPY --from=builder`, assurez-vous que le chemin source existe bien dans le stage source. Une erreur courante est de copier depuis un chemin qui n'a pas été créé dans le stage précédent.

---

## 🪶 Images de base légères

### Pourquoi utiliser des images légères ?

Les images de base légères offrent plusieurs avantages :

- ⚡ **Déploiements plus rapides** (moins de données à transférer)
- 💾 **Moins d'espace disque** utilisé
- 🔒 **Surface d'attaque réduite** (moins de packages = moins de vulnérabilités)
- 🚀 **Démarrage plus rapide** des conteneurs

### Comparaison des tailles d'images de base

|Image|Taille approximative|Usage recommandé|
|---|---|---|
|`ubuntu:22.04`|~77 MB|Développement, debugging|
|`debian:12`|~124 MB|Applications complexes|
|`alpine:latest`|~7 MB|Production, microservices|
|`node:18`|~900 MB|Développement Node.js|
|`node:18-slim`|~240 MB|Production Node.js|
|`node:18-alpine`|~175 MB|Production légère Node.js|
|`scratch`|0 MB|Binaires statiques uniquement|

### Alpine Linux : l'image populaire

**Alpine** est une distribution Linux ultra-légère basée sur musl libc et BusyBox.

✅ **Avantages** :

- Extrêmement légère (~7 MB)
- Gestionnaire de paquets simple (`apk`)
- Sécurisée par défaut
- Idéale pour la production

⚠️ **Limitations** :

- Utilise `musl` au lieu de `glibc` (peut causer des incompatibilités)
- Moins de paquets disponibles
- Certaines applications peuvent nécessiter des ajustements

**Exemple avec Alpine** :

```dockerfile
FROM node:18-alpine

# Installation de dépendances système
RUN apk add --no-cache python3 make g++

WORKDIR /app
COPY package.json .
RUN npm ci --only=production
COPY . .

CMD ["node", "server.js"]
```

### Images -slim : le compromis

Les images `-slim` sont des versions allégées des distributions classiques (Debian), sans les paquets non essentiels.

```dockerfile
FROM python:3.11-slim

# Installation d'un paquet si nécessaire
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["python", "app.py"]
```

> [!tip] Quand utiliser -slim vs -alpine ?
> 
> - **Alpine** : Applications simples, microservices, si vous n'avez pas de dépendances système complexes
> - **Slim** : Si vous rencontrez des problèmes de compatibilité avec Alpine, ou si votre application nécessite glibc

### L'image scratch : le minimalisme absolu

`scratch` est une image vide, sans système d'exploitation. Elle ne peut contenir que des binaires **statiques** (compilés avec toutes leurs dépendances).

```dockerfile
# Build stage
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Image finale
FROM scratch
COPY --from=builder /app/main /main
ENTRYPOINT ["/main"]
```

> [!warning] Limitations de scratch
> 
> - Pas de shell (impossible de faire `docker exec` pour debugger)
> - Pas de système de fichiers de base (/etc/passwd, /tmp, etc.)
> - Pas de certificats SSL par défaut
> - Uniquement pour des binaires **totalement statiques**

### Tableau de choix d'image de base

|Langage/Besoin|Image recommandée|Raison|
|---|---|---|
|Node.js (prod)|`node:18-alpine`|Bon compromis légèreté/compatibilité|
|Node.js (build complexe)|`node:18-slim`|Meilleure compatibilité native|
|Python (prod)|`python:3.11-slim`|Alpine pose souvent des problèmes avec les packages Python|
|Go (binaire statique)|`scratch` ou `alpine`|Go compile des binaires statiques|
|Java|`eclipse-temurin:17-jre-alpine`|JRE suffit pour l'exécution|
|Rust (binaire statique)|`scratch`|Rust compile des binaires statiques|
|Application générique|`alpine:latest`|Base universelle légère|

### Optimiser le nettoyage avec Alpine

```dockerfile
FROM alpine:latest

# Installation avec nettoyage automatique
RUN apk add --no-cache \
    nginx \
    curl \
    && rm -rf /var/cache/apk/*

# Alternative : installation temporaire
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    make \
    && # ... compilation ... \
    && apk del .build-deps
```

> [!tip] Astuce : Images distroless Google propose des images "distroless" qui ne contiennent que l'application et ses dépendances runtime, sans gestionnaire de paquets ni shell. Exemple : `gcr.io/distroless/nodejs18-debian11`

---

## 🎯 Récapitulatif des bonnes pratiques

|Pratique|Impact|Priorité|
|---|---|---|
|Regrouper les commandes RUN|Réduit le nombre de layers|🔴 Haute|
|Ordonner les instructions du moins au plus changeant|Optimise le cache Docker|🔴 Haute|
|Utiliser .dockerignore|Accélère les builds|🟡 Moyenne|
|Multi-stage builds|Réduit drastiquement la taille|🔴 Haute|
|Images de base légères (alpine/slim)|Réduit la taille et améliore la sécurité|🟡 Moyenne|
|Nettoyer dans le même layer|Réduit la taille finale|🟡 Moyenne|

> [!info] Mesurer l'impact Utilisez `docker history <image>` pour voir la taille de chaque layer et identifier les optimisations possibles.