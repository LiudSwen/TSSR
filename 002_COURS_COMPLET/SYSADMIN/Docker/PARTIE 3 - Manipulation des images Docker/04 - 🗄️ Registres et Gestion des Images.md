

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

## 🎯 Introduction aux Registries

Un **registry Docker** est un système de stockage et de distribution d'images Docker. C'est l'équivalent de GitHub pour le code source, mais pour les images conteneurisées.

> [!info] Pourquoi utiliser un registry ?
> 
> - **Partage** : Distribuer vos images au sein d'une équipe ou publiquement
> - **Versioning** : Gérer différentes versions de vos applications
> - **Centralisation** : Point unique de distribution pour tous vos environnements
> - **CI/CD** : Intégration dans les pipelines d'automatisation

### Types de registries

|Type|Exemples|Usage typique|
|---|---|---|
|**Public**|Docker Hub, Quay.io|Images open-source, partage communautaire|
|**Privé cloud**|Docker Hub (payant), AWS ECR, GCP GCR|Projets d'entreprise, images propriétaires|
|**Auto-hébergé**|Docker Registry, Harbor, Nexus|Contrôle total, sécurité interne|

---

## 🐳 Docker Hub

### Qu'est-ce que Docker Hub ?

**Docker Hub** est le registry public officiel de Docker, comparable à npm pour Node.js ou PyPI pour Python. C'est le registry par défaut utilisé par Docker.

> [!example] URL et structure
> 
> - Site web : https://hub.docker.com
> - Format d'image : `[utilisateur/]nom-image[:tag]`
> - Exemple : `nginx:latest` ou `john/mon-app:v1.0`

### Fonctionnalités principales

#### 🔍 Exploration des images

```bash
# Rechercher une image sur Docker Hub
docker search nginx

# Rechercher avec filtres (étoiles minimales)
docker search --filter stars=100 nginx

# Limiter le nombre de résultats
docker search --limit 5 python
```

> [!tip] Astuces de recherche
> 
> - Les résultats sont triés par popularité
> - Privilégiez les images avec de nombreuses étoiles et téléchargements
> - Consultez toujours la documentation sur le site Docker Hub pour les détails

#### 📊 Informations disponibles

Pour chaque image sur Docker Hub, vous trouverez :

- **Description** : Documentation et cas d'usage
- **Tags** : Versions disponibles
- **Dockerfile** : Source de construction (souvent lié à GitHub)
- **Statistiques** : Nombre de pulls, étoiles
- **Dernière mise à jour** : Date de publication

### Images officielles vs communautaires

#### Images officielles ✅

```bash
# Format : nom-image (sans préfixe utilisateur)
docker pull nginx
docker pull postgres
docker pull node
```

> [!info] Caractéristiques des images officielles
> 
> - Maintenues par Docker Inc. ou les éditeurs officiels
> - Badge "Official Image" sur Docker Hub
> - Documentation complète et à jour
> - Sécurité et mises à jour régulières
> - Bonnes pratiques respectées

#### Images communautaires 👥

```bash
# Format : utilisateur/nom-image
docker pull bitnami/nginx
docker pull linuxserver/plex
```

> [!warning] Vigilance requise
> 
> - Qualité variable selon les mainteneurs
> - Vérifiez la réputation (stars, pulls, dernière mise à jour)
> - Lisez le Dockerfile si disponible
> - Préférez des organisations reconnues (bitnami, linuxserver, etc.)

---

## 🔐 Authentification

### Connexion à Docker Hub

L'authentification est nécessaire pour :

- Pousser des images vers votre compte
- Accéder à des images privées
- Éviter les limitations de rate-limit sur les pulls anonymes

#### Méthode interactive

```bash
# Connexion avec saisie du mot de passe
docker login

# Spécifier un nom d'utilisateur
docker login -u votre-username

# Connexion à un autre registry
docker login registry.gitlab.com
```

> [!example] Exemple de session
> 
> ```bash
> $ docker login
> Username: johndoe
> Password: ********
> Login Succeeded
> ```

#### Méthode non-interactive

```bash
# Avec mot de passe en ligne de commande (déconseillé)
docker login -u votre-username -p votre-password

# Avec un fichier de mot de passe (plus sécurisé)
cat ~/mon-password.txt | docker login -u votre-username --password-stdin
```

> [!warning] Sécurité des credentials
> 
> - Ne jamais hardcoder les mots de passe dans des scripts versionnés
> - Utilisez `--password-stdin` pour éviter que le mot de passe apparaisse dans l'historique
> - Les tokens d'accès sont préférables aux mots de passe

### Gestion des tokens d'accès

Les **tokens d'accès** (access tokens) sont plus sécurisés que les mots de passe car ils peuvent être révoqués individuellement.

#### Création d'un token sur Docker Hub

1. Connectez-vous sur https://hub.docker.com
2. Allez dans **Account Settings** → **Security**
3. Cliquez sur **New Access Token**
4. Nommez le token et définissez les permissions
5. Copiez le token (visible une seule fois)

#### Utilisation du token

```bash
# Connexion avec un token
echo "dckr_pat_VOTRE_TOKEN_ICI" | docker login -u votre-username --password-stdin
```

> [!tip] Gestion des tokens
> 
> - Créez des tokens spécifiques pour chaque usage (CI/CD, machine de dev, etc.)
> - Définissez une date d'expiration appropriée
> - Révoquez immédiatement les tokens compromis
> - Permissions : `Read-only` pour les pulls, `Read & Write` pour les push

#### Stockage des credentials

```bash
# Emplacement du fichier de configuration
~/.docker/config.json

# Contenu après connexion (credentials encodées)
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "dXNlcm5hbWU6cGFzc3dvcmQ="
    }
  }
}
```

> [!warning] Sécurité du fichier config.json
> 
> - Les credentials sont encodées en base64 (pas chiffrées !)
> - Sur les systèmes de production, utilisez un credential helper
> - Ne commitez jamais ce fichier dans Git

### Déconnexion

```bash
# Déconnexion du registry par défaut (Docker Hub)
docker logout

# Déconnexion d'un registry spécifique
docker logout registry.gitlab.com

# Vérification
cat ~/.docker/config.json  # Les auths doivent être supprimées
```

---

## 📤 Push : Envoyer des images

### Prérequis et nomenclature

Pour pousser une image vers un registry, elle doit respecter une nomenclature spécifique :

```
[registry-url/][namespace/]repository[:tag]
```

|Élément|Description|Exemple|
|---|---|---|
|**registry-url**|Adresse du registry (optionnel pour Docker Hub)|`registry.gitlab.com`|
|**namespace**|Votre username ou organisation|`johndoe`|
|**repository**|Nom de l'image|`mon-application`|
|**tag**|Version ou variante|`v1.0`, `latest`|

> [!example] Exemples de noms valides
> 
> ```
> johndoe/mon-app:latest          # Docker Hub
> johndoe/mon-app:1.0.3           # Docker Hub avec version
> registry.gitlab.com/team/api:dev # GitLab Registry
> gcr.io/mon-projet/web:prod      # Google Container Registry
> ```

### Taguer une image

Avant de pousser, vous devez taguer votre image avec le nom approprié.

```bash
# Syntaxe générale
docker tag image-source nom-registry/namespace/repository:tag

# Exemples pratiques
docker tag mon-app:latest johndoe/mon-app:latest
docker tag mon-app:latest johndoe/mon-app:1.0.0
docker tag mon-app:latest johndoe/mon-app:stable

# Tag vers un registry privé
docker tag mon-app:latest registry.company.com/team/mon-app:prod
```

> [!info] Plusieurs tags pour une même image Une image peut avoir plusieurs tags simultanément :
> 
> ```bash
> docker tag mon-app:latest johndoe/mon-app:latest
> docker tag mon-app:latest johndoe/mon-app:1.2.0
> docker tag mon-app:latest johndoe/mon-app:stable
> ```
> 
> Ces trois tags pointent vers la même image (même IMAGE ID).

### Pousser vers un registry

```bash
# Push simple vers Docker Hub
docker push johndoe/mon-app:latest

# Push avec tag spécifique
docker push johndoe/mon-app:1.0.0

# Push vers un registry privé
docker push registry.company.com/team/mon-app:prod

# Push de tous les tags d'un repository
docker push --all-tags johndoe/mon-app
```

> [!example] Workflow complet de push
> 
> ```bash
> # 1. Construire l'image
> docker build -t mon-app:latest .
> 
> # 2. Tester localement
> docker run --rm mon-app:latest
> 
> # 3. Se connecter au registry
> docker login
> 
> # 4. Taguer pour le registry
> docker tag mon-app:latest johndoe/mon-app:1.0.0
> docker tag mon-app:latest johndoe/mon-app:latest
> 
> # 5. Pousser les tags
> docker push johndoe/mon-app:1.0.0
> docker push johndoe/mon-app:latest
> ```

#### Comprendre le processus de push

Lors d'un push, Docker :

1. **Analyse les layers** : Identifie les couches déjà présentes sur le registry
2. **Upload incrémental** : Ne pousse que les nouvelles couches
3. **Vérifie l'intégrité** : Calcule les checksums pour garantir l'intégrité

```bash
# Exemple de sortie pendant un push
$ docker push johndoe/mon-app:latest
The push refers to repository [docker.io/johndoe/mon-app]
5f70bf18a086: Pushed 
d191d1e5d3d1: Layer already exists
1f6b6c7dc482: Layer already exists
c8dd97366670: Layer already exists
latest: digest: sha256:8f3b... size: 1234
```

> [!tip] Optimisation des push
> 
> - Les layers partagées entre images ne sont uploadées qu'une fois
> - Utilisez un `.dockerignore` pour réduire la taille des contextes
> - Les push incrémentaux sont rapides si seules quelques couches changent

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> **Erreur : "denied: requested access to the resource is denied"**
> 
> - Vous n'êtes pas connecté : `docker login`
> - Le namespace ne correspond pas à votre username
> - Permissions insuffisantes sur un registry privé
> 
> **Erreur : "name invalid: repository name must be lowercase"**
> 
> - Les noms d'images doivent être en minuscules
> - Utilisez des tirets `-` plutôt que des underscores `_`
> 
> **Oubli du tag**
> 
> ```bash
> # ❌ Mauvais : crée johndoe/mon-app:latest seulement
> docker tag mon-app johndoe/mon-app
> 
> # ✅ Bon : spécifie explicitement le tag
> docker tag mon-app johndoe/mon-app:1.0.0
> ```

---

## 📥 Pull : Récupérer des images

### Syntaxe et comportement

```bash
# Syntaxe générale
docker pull [registry/]image[:tag]

# Pull depuis Docker Hub (registry par défaut)
docker pull nginx
docker pull nginx:alpine

# Pull depuis un registry spécifique
docker pull registry.gitlab.com/group/project/image:tag
docker pull gcr.io/google-containers/nginx:latest
```

> [!info] Comportement par défaut
> 
> - Si aucun registry n'est spécifié, Docker utilise Docker Hub
> - Si aucun tag n'est spécifié, Docker utilise `:latest`
> - Le pull télécharge toutes les couches (layers) de l'image

#### Process de téléchargement

```bash
$ docker pull nginx:alpine
alpine: Pulling from library/nginx
31e352740f53: Pull complete 
fd3b854c37a6: Pull complete 
8fd7c77d4f0c: Pull complete 
Digest: sha256:2c8f...
Status: Downloaded newer image for nginx:alpine
docker.io/library/nginx:alpine
```

Chaque ligne représente :

- Une **layer** (couche) de l'image
- Téléchargement parallélisé pour plus de rapidité
- Vérification d'intégrité via les checksums

### Spécifier des versions

#### Tags sémantiques

```bash
# Version majeure
docker pull node:20

# Version majeure.mineure
docker pull node:20.10

# Version complète (majeure.mineure.patch)
docker pull node:20.10.0

# Variantes
docker pull node:20-alpine
docker pull node:20-slim
docker pull node:20-bullseye
```

> [!tip] Stratégie de versioning
> 
> - **Production** : Tag complet `nginx:1.25.3` (reproductibilité)
> - **Développement** : Tag majeur `nginx:1` (mises à jour automatiques)
> - **Testing** : Tag spécifique ou digest SHA256
> 
> Évitez `:latest` en production car il change sans prévenir !

#### Tags spéciaux

|Tag|Signification|Recommandation|
|---|---|---|
|`latest`|Dernière version buildée|⚠️ Éviter en production|
|`stable`|Version stable (si fourni)|✅ Bon pour démarrer|
|`alpine`|Variante légère basée sur Alpine Linux|✅ Recommandé pour la taille|
|`slim`|Version minimale sans extras|✅ Bon compromis|
|`edge`, `nightly`|Versions de développement|❌ Jamais en production|

#### Pull par digest SHA256

Le digest est un hash unique identifiant précisément une image, indépendamment des tags.

```bash
# Pull par digest (immuable)
docker pull nginx@sha256:2c8f5e...

# Obtenir le digest d'une image locale
docker inspect --format='{{.RepoDigests}}' nginx:alpine

# Exemple de sortie
[nginx@sha256:2c8f5e0c5e84b...]
```

> [!info] Pourquoi utiliser les digests ?
> 
> - **Immuabilité** : Le digest ne change jamais, contrairement aux tags
> - **Sécurité** : Garantit l'exacte version testée et approuvée
> - **Audit** : Traçabilité complète dans les déploiements
> - **CI/CD** : Assure la reproductibilité entre les environnements

### Images depuis d'autres registries

#### Registries cloud populaires

```bash
# Amazon ECR (Elastic Container Registry)
docker pull 123456789.dkr.ecr.us-east-1.amazonaws.com/mon-app:latest

# Google Container Registry
docker pull gcr.io/mon-projet/mon-app:v1.0

# Azure Container Registry
docker pull monregistry.azurecr.io/mon-app:latest

# GitLab Container Registry
docker pull registry.gitlab.com/groupe/projet/app:main

# GitHub Container Registry
docker pull ghcr.io/utilisateur/mon-app:latest

# Quay.io (Red Hat)
docker pull quay.io/organization/image:tag
```

#### Authentification pour registries privés

```bash
# AWS ECR (nécessite AWS CLI)
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  123456789.dkr.ecr.us-east-1.amazonaws.com

# Google GCR
gcloud auth configure-docker

# Azure ACR
az acr login --name monregistry

# GitLab / GitHub (token personnel)
docker login registry.gitlab.com -u username -p glpat-xxxxx
docker login ghcr.io -u username -p ghp_xxxxx
```

### Options avancées de pull

```bash
# Pull sans affichage verbeux
docker pull -q nginx:alpine

# Pull toutes les architectures (multi-platform)
docker pull --platform linux/amd64 nginx:alpine
docker pull --platform linux/arm64 nginx:alpine

# Pull avec limitation réseau (si configuré dans le daemon)
# Utile pour ne pas saturer la bande passante
docker pull --disable-content-trust=false nginx
```

> [!warning] Content Trust et signatures Docker Content Trust (DCT) permet de vérifier les signatures des images :
> 
> ```bash
> # Activer DCT
> export DOCKER_CONTENT_TRUST=1
> 
> # Les pulls non signés seront rejetés
> docker pull johndoe/unsigned-app
> # Error: remote trust data does not exist
> ```
> 
> Utile pour la sécurité, mais toutes les images ne sont pas signées.

### Gestion du cache et mise à jour

```bash
# Vérifier si une image a besoin d'être mise à jour
docker pull nginx:alpine
# Si "Image is up to date" = pas de changement

# Forcer le re-téléchargement (ignore le cache)
docker image rm nginx:alpine
docker pull nginx:alpine

# Pull d'une image même si elle existe localement
# (Docker compare les digests automatiquement)
docker pull nginx:latest  # Vérifie toujours les mises à jour
```

> [!tip] Automatiser les mises à jour Pour maintenir vos images à jour :
> 
> ```bash
> # Script de mise à jour de toutes les images locales
> docker images --format "{{.Repository}}:{{.Tag}}" | \
>   grep -v "<none>" | \
>   xargs -L1 docker pull
> ```

---

## ✅ Bonnes pratiques

### 🏷️ Convention de nommage

```bash
# ✅ Bon : Clair et sémantique
mon-app:1.2.3
mon-app:1.2.3-alpine
mon-api:v2.0.0-rc1
frontend:2024-01-15

# ❌ Mauvais : Peu informatif
mon-app:final
mon-app:new
mon-app:test123
```

> [!tip] Schéma de tags recommandé Combinez plusieurs informations :
> 
> ```bash
> # Format : version-variant-environnement
> docker tag app:latest company/app:1.2.3-alpine-prod
> docker tag app:latest company/app:1.2-alpine
> docker tag app:latest company/app:1-alpine
> docker tag app:latest company/app:latest
> ```

### 🔄 Workflow de publication

```bash
# 1. Build avec cache
docker build -t mon-app:latest .

# 2. Tests locaux
docker run --rm mon-app:latest npm test

# 3. Tag semantic versioning
VERSION="1.2.3"
docker tag mon-app:latest username/mon-app:${VERSION}
docker tag mon-app:latest username/mon-app:1.2
docker tag mon-app:latest username/mon-app:1
docker tag mon-app:latest username/mon-app:latest

# 4. Push de toutes les versions
docker push username/mon-app:${VERSION}
docker push username/mon-app:1.2
docker push username/mon-app:1
docker push username/mon-app:latest
```

### 🔒 Sécurité

> [!warning] Checklist de sécurité
> 
> **Avant de pousser une image :**
> 
> - [ ] Pas de secrets hardcodés (mots de passe, clés API)
> - [ ] Scan de vulnérabilités effectué
> - [ ] Image basée sur une base officielle et à jour
> - [ ] Utilisateur non-root configuré dans le Dockerfile
> - [ ] Documentation des dépendances sensibles
> 
> **Gestion des accès :**
> 
> - [ ] Tokens d'accès plutôt que mots de passe
> - [ ] Permissions minimales sur les registries privés
> - [ ] Rotation régulière des credentials
> - [ ] Images privées pour le code propriétaire

```bash
# Scanner une image avant push (avec Trivy par exemple)
trivy image mon-app:latest

# Vérifier l'historique d'une image
docker history mon-app:latest --no-trunc

# Inspecter le contenu
docker inspect mon-app:latest
```

### 📦 Optimisation de la taille

```bash
# Préférer les variantes slim/alpine
docker pull node:20-alpine       # ~180 MB
# vs
docker pull node:20              # ~1 GB

# Multi-stage builds pour réduire la taille finale
# (construction séparée de l'image finale)
```

> [!tip] Réduction de la taille des images
> 
> - Utilisez `.dockerignore` pour exclure les fichiers inutiles
> - Combinez les commandes RUN pour réduire les layers
> - Nettoyez les caches dans la même layer
> - Préférez les images Alpine quand c'est compatible
> - Utilisez des multi-stage builds pour séparer build et runtime

### 🔄 Gestion des tags

```bash
# Stratégie de versioning cohérente
production:
  - mon-app:1.2.3 (version exacte)
  - mon-app:1.2 (dernière patch)
  - mon-app:1 (dernière minor)
  - mon-app:stable

développement:
  - mon-app:dev
  - mon-app:feature-xyz
  - mon-app:commit-abc123

staging:
  - mon-app:staging
  - mon-app:rc-1.2.3
```

> [!info] Tag `latest` : à utiliser avec précaution
> 
> - `:latest` ne signifie pas "la plus récente version"
> - C'est juste le tag par défaut si non spécifié
> - Peut pointer vers n'importe quelle version
> - ⚠️ En production, toujours spécifier un tag explicite

### 📊 Monitoring et maintenance

```bash
# Lister les images avec taille
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Nettoyer les images inutilisées
docker image prune -a

# Voir l'espace disque utilisé
docker system df

# Analyser les layers d'une image
docker history mon-app:latest

# Inspecter les métadonnées
docker inspect mon-app:latest | jq '.[0].Config.Labels'
```

### 🚀 Automatisation CI/CD

Exemple de workflow automatisé :

```bash
#!/bin/bash
# Script de publication automatique

# Variables
APP_NAME="mon-app"
VERSION=$(git describe --tags --always)
REGISTRY="username"

# Build
docker build -t ${APP_NAME}:${VERSION} .

# Test
docker run --rm ${APP_NAME}:${VERSION} npm test

# Tag
docker tag ${APP_NAME}:${VERSION} ${REGISTRY}/${APP_NAME}:${VERSION}
docker tag ${APP_NAME}:${VERSION} ${REGISTRY}/${APP_NAME}:latest

# Push
docker login
docker push ${REGISTRY}/${APP_NAME}:${VERSION}
docker push ${REGISTRY}/${APP_NAME}:latest

echo "✅ Image publiée : ${REGISTRY}/${APP_NAME}:${VERSION}"
```

### 📝 Documentation

> [!example] Checklist de documentation pour une image
> 
> Dans le README de votre repository Docker Hub :
> 
> - **Description** : À quoi sert l'image
> - **Tags disponibles** : Versions et variantes
> - **Variables d'environnement** : Configuration nécessaire
> - **Volumes** : Points de montage recommandés
> - **Ports** : Ports exposés
> - **Exemples d'utilisation** : Commandes `docker run` complètes
> - **Dépendances** : Services requis (base de données, etc.)
> - **Changelog** : Historique des versions

---

## 🎯 Résumé des commandes essentielles

```bash
# Authentification
docker login                                    # Se connecter à Docker Hub
docker logout                                   # Se déconnecter

# Pull (télécharger)
docker pull nginx                               # Image depuis Docker Hub
docker pull nginx:1.25.3                        # Version spécifique
docker pull registry.gitlab.com/group/app       # Registry privé

# Tag (renommer)
docker tag source destination:tag               # Créer un tag
docker tag app:latest user/app:1.0.0           # Tag pour push

# Push (envoyer)
docker push user/app:1.0.0                     # Pousser une image
docker push --all-tags user/app                # Pousser tous les tags

# Recherche et inspection
docker search nginx                             # Rechercher sur Hub
docker inspect app:latest                       # Détails d'une image
docker history app:latest                       # Voir les layers
```

---

**🎓 Points clés à retenir**

1. **Docker Hub** est le registry public par défaut, mais d'autres existent
2. **Authentification** nécessaire pour push et images privées (utilisez des tokens)
3. **Nomenclature** : `[registry/]namespace/repository:tag`
4. **Versioning** : Utilisez des tags sémantiques explicites en production
5. **Sécurité** : Scannez les images, utilisez des bases officielles, pas de secrets
6. **Optimisation** : Variantes Alpine, multi-stage builds, .dockerignore