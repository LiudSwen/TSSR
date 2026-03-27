

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

Le téléchargement d'images est l'opération fondamentale qui permet de récupérer des images depuis un registre Docker (généralement Docker Hub) vers votre machine locale. C'est la première étape avant de pouvoir créer et exécuter des conteneurs.

> [!info] Pourquoi télécharger des images ?
> 
> - Récupérer des environnements préconfigurés (bases de données, serveurs web, etc.)
> - Obtenir des images de base pour créer vos propres images
> - Assurer la disponibilité locale d'une image avant de l'utiliser
> - Contrôler les versions spécifiques des logiciels utilisés

---

## La commande docker pull

### Syntaxe de base

```bash
docker pull [OPTIONS] NOM[:TAG|@DIGEST]
```

### Structure complète d'une référence d'image

```bash
[REGISTRE/][NAMESPACE/]REPOSITORY[:TAG|@DIGEST]
```

**Décomposition** :

- **REGISTRE** : L'URL du registre (par défaut : `docker.io` pour Docker Hub)
- **NAMESPACE** : L'organisation ou l'utilisateur propriétaire (par défaut : `library` pour les images officielles)
- **REPOSITORY** : Le nom de l'image
- **TAG** : La version ou variante (par défaut : `latest`)
- **DIGEST** : Identifiant unique et immuable de l'image (SHA256)

### Exemples d'utilisation

```bash
# Téléchargement simple (utilise le tag 'latest' par défaut)
docker pull nginx

# Équivalent complet (ce que Docker fait réellement)
docker pull docker.io/library/nginx:latest

# Télécharger une version spécifique
docker pull nginx:1.25.3

# Télécharger depuis un registre alternatif
docker pull gcr.io/google-containers/nginx:latest

# Télécharger avec un digest (garantit l'image exacte)
docker pull nginx@sha256:4c0fdaa8b6341bfdeca5f18f7837462c80cff90527ee35ef185571e1c327beac
```

### Options principales

```bash
# Télécharger toutes les variantes (tous les tags) d'une image
docker pull --all-tags nginx

# Mode silencieux (quiet)
docker pull -q nginx

# Spécifier la plateforme (utile pour Apple Silicon / ARM)
docker pull --platform linux/amd64 nginx
docker pull --platform linux/arm64 nginx
```

> [!example] Exemple pratique : téléchargement multi-plateforme
> 
> ```bash
> # Sur un Mac M1/M2, télécharger l'image AMD64 pour compatibilité
> docker pull --platform linux/amd64 mysql:8.0
> 
> # Vérifier la plateforme de l'image téléchargée
> docker image inspect mysql:8.0 | grep Architecture
> ```

### Processus de téléchargement

Lorsque vous exécutez `docker pull`, Docker :

1. **Contacte le registre** et vérifie l'existence de l'image
2. **Récupère le manifeste** (métadonnées de l'image)
3. **Télécharge les couches** (layers) en parallèle
4. **Vérifie l'intégrité** avec les checksums
5. **Stocke les couches** dans le cache local

```bash
docker pull ubuntu:22.04
# Sortie typique :
# 22.04: Pulling from library/ubuntu
# 445a6a12be2b: Pull complete      ← Layer 1
# Digest: sha256:340d9b015b194dc...
# Status: Downloaded newer image for ubuntu:22.04
# docker.io/library/ubuntu:22.04
```

> [!tip] Optimisation du téléchargement Docker télécharge uniquement les couches qui ne sont pas déjà présentes localement. Si vous téléchargez `nginx:1.25.3` puis `nginx:1.25.4`, seules les couches différentes seront téléchargées, ce qui accélère considérablement le processus.

---

## Gestion des tags

### Qu'est-ce qu'un tag ?

Un tag est un **alias lisible** qui pointe vers une image spécifique identifiée par son digest. Les tags permettent de référencer des versions ou des variantes d'images de manière compréhensible.

> [!warning] Les tags sont mutables ! Contrairement aux digests, un tag peut être réassigné à une image différente. Le tag `latest` d'aujourd'hui n'est pas forcément le même que celui de demain.

### Tags courants et leur signification

|Tag|Signification|Exemple|
|---|---|---|
|`latest`|Dernière version stable (par défaut)|`nginx:latest`|
|Version sémantique|Version spécifique (major.minor.patch)|`node:18.19.0`|
|Version courte|Dernière version d'une branche|`node:18`, `python:3.11`|
|Variantes OS|Distribution Linux utilisée|`python:3.11-slim`, `node:18-alpine`|
|Architecture|Plateforme matérielle|`nginx:alpine-arm64`|
|Développement|Versions de développement|`postgres:14-beta`, `redis:7.0-rc`|

### Exemples de stratégies de tags

```bash
# Stratégie 1 : Utiliser 'latest' (déconseillé en production)
docker pull redis:latest
# ❌ Problème : L'image peut changer à tout moment

# Stratégie 2 : Version majeure (accepte les mises à jour mineures)
docker pull postgres:15
# ⚠️ Risque modéré : Les mises à jour 15.x peuvent introduire des changements

# Stratégie 3 : Version complète (recommandé)
docker pull postgres:15.5-alpine
# ✅ Reproductible : Vous obtenez toujours la même version

# Stratégie 4 : Digest (maximum de sécurité)
docker pull postgres@sha256:abc123...
# ✅ Immuable : Garantie absolue de l'image exacte
```

### Lister les tags disponibles

Docker ne fournit pas de commande native pour lister les tags. Vous devez consulter le registre :

```bash
# Sur Docker Hub (via navigateur web)
https://hub.docker.com/r/library/nginx/tags

# Ou via l'API Docker Hub
curl -s "https://hub.docker.com/v2/repositories/library/nginx/tags/" | jq '.results[].name'

# Avec un outil tiers (skopeo)
skopeo list-tags docker://docker.io/nginx
```

### Variantes courantes d'images

```bash
# Image standard (Debian généralement)
docker pull python:3.11

# Image Alpine (très légère, ~5-10 MB)
docker pull python:3.11-alpine
# ✅ Avantages : Petite taille, sécurisée
# ❌ Inconvénients : Peut manquer certains outils, compilation parfois nécessaire

# Image Slim (Debian allégée)
docker pull python:3.11-slim
# ✅ Compromis entre taille et compatibilité

# Image complète avec outils de build
docker pull node:18-bullseye
# Pour compilation de modules natifs

# Image avec version Windows Server
docker pull mcr.microsoft.com/windows/servercore:ltsc2022
```

> [!tip] Choisir la bonne variante
> 
> - **Développement** : Image standard (meilleure compatibilité)
> - **Production** : Image slim ou alpine (optimisation taille/sécurité)
> - **CI/CD** : Image avec outils de build si compilation nécessaire
> - **Débutants** : Image standard ou slim (éviter alpine au début)

---

## Images officielles vs communautaires

### Images officielles

Les images officielles sont maintenues par Docker Inc. ou par les éditeurs des logiciels concernés, et sont publiées dans le namespace `library`.

**Caractéristiques** :

- ✅ Badge "Docker Official Image" sur Docker Hub
- ✅ Revues de sécurité régulières
- ✅ Documentation complète
- ✅ Mises à jour fréquentes
- ✅ Meilleures pratiques Docker appliquées
- ✅ Référencement simplifié (pas besoin du namespace)

```bash
# Images officielles (namespace 'library' implicite)
docker pull nginx
docker pull postgres
docker pull redis
docker pull python

# Équivaut à :
docker pull library/nginx
docker pull library/postgres
```

**Exemples d'images officielles populaires** :

|Image|Description|Usage typique|
|---|---|---|
|`nginx`|Serveur web et reverse proxy|Servir des sites web, load balancing|
|`postgres`|Base de données relationnelle|Applications nécessitant SQL|
|`redis`|Cache et base clé-valeur|Sessions, cache, files d'attente|
|`node`|Runtime JavaScript|Applications Node.js|
|`python`|Interpréteur Python|Scripts, API, ML/Data Science|
|`mysql`|Base de données relationnelle|Applications web PHP/Java|
|`mongo`|Base de données NoSQL|Applications avec données JSON|
|`ubuntu`|Distribution Linux|Image de base pour builds custom|

### Images vérifiées (Verified Publisher)

Images publiées par des éditeurs de logiciels reconnus et vérifiés par Docker.

**Caractéristiques** :

- ✅ Badge "Verified Publisher" bleu sur Docker Hub
- ✅ Provenance authentifiée
- ✅ Support potentiel de l'éditeur
- ⚠️ Nécessite le namespace complet

```bash
# Images vérifiées d'éditeurs
docker pull bitnami/nginx
docker pull gitlab/gitlab-ce
docker pull hashicorp/terraform
```

### Images communautaires

Images publiées par des utilisateurs individuels ou des organisations.

**Caractéristiques** :

- ⚠️ Aucune vérification par Docker
- ⚠️ Qualité et sécurité variables
- ⚠️ Maintenance non garantie
- ⚠️ Documentation parfois absente
- ✅ Souvent spécialisées ou innovantes

```bash
# Images communautaires (nécessitent toujours le namespace)
docker pull username/custom-app
docker pull mycompany/internal-tool
```

### Comment identifier le type d'image

```bash
# Sur Docker Hub, recherchez les badges :
# 🔵 "Docker Official Image" = Image officielle
# ✓ "Verified Publisher" = Éditeur vérifié
# (aucun badge) = Image communautaire

# Dans le nom de l'image :
nginx              # Officielle (pas de namespace)
library/nginx      # Officielle (namespace explicite)
bitnami/nginx      # Vérifiée ou communautaire (avec namespace)
username/myapp     # Communautaire
```

### Registres alternatifs

Docker Hub n'est pas le seul registre disponible :

```bash
# Google Container Registry (GCR)
docker pull gcr.io/google-containers/nginx

# Amazon Elastic Container Registry (ECR)
docker pull 123456789.dkr.ecr.eu-west-1.amazonaws.com/myapp

# GitHub Container Registry (GHCR)
docker pull ghcr.io/organization/repository

# Red Hat Quay
docker pull quay.io/prometheus/prometheus

# Microsoft Container Registry
docker pull mcr.microsoft.com/dotnet/aspnet

# Registre privé d'entreprise
docker pull registry.mycompany.com/internal/app
```

> [!info] Authentification sur les registres Pour accéder à des registres privés ou à certains registres publics, vous devez vous authentifier :
> 
> ```bash
> # Docker Hub
> docker login
> 
> # Autre registre
> docker login registry.mycompany.com
> 
> # Avec credentials explicites (CI/CD)
> echo $PASSWORD | docker login -u $USERNAME --password-stdin
> ```

### Critères de sélection d'une image

> [!tip] Comment choisir une image ?
> 
> **Priorisez dans cet ordre** :
> 
> 1. **Images officielles** (quand disponibles)
>     - Sécurité maximale
>     - Mises à jour garanties
>     - Documentation complète
> 2. **Images d'éditeurs vérifiés**
>     - Pour les logiciels commerciaux
>     - Support officiel potentiel
>     - Optimisations spécifiques
> 3. **Images communautaires populaires**
>     - Vérifiez le nombre de téléchargements (>1M = bon signe)
>     - Consultez le Dockerfile sur GitHub
>     - Vérifiez la date de dernière mise à jour (<3 mois)
>     - Lisez les commentaires et issues
> 4. **Créez votre propre image**
>     - Si aucune image ne répond à vos besoins
>     - Pour un contrôle total
>     - Basez-vous sur une image officielle

**Checklist de sécurité** :

```bash
# 1. Vérifier la provenance
docker image inspect nginx:latest | grep -A 10 "Labels"

# 2. Consulter l'historique des couches
docker history nginx:latest

# 3. Analyser les vulnérabilités (avec Docker Scout)
docker scout cves nginx:latest

# 4. Vérifier la signature (si disponible)
docker trust inspect nginx:latest
```

---

## Pièges courants

### 1. Le piège du tag 'latest'

```bash
# ❌ Mauvaise pratique
docker pull redis:latest
```

**Problèmes** :

- `latest` ne signifie pas "la plus récente" mais "le tag par défaut"
- Peut pointer vers une version obsolète si le mainteneur ne le met pas à jour
- Non reproductible : `latest` aujourd'hui ≠ `latest` demain
- Casse les déploiements en production

```bash
# ✅ Bonne pratique
docker pull redis:7.2.3-alpine
```

### 2. Confusion entre tag et digest

```bash
# Tag (mutable, peut changer)
docker pull nginx:1.25

# Digest (immuable, ne change jamais)
docker pull nginx@sha256:4c0fdaa8b6341bfdeca5f18f7837462c80cff90527ee35ef185571e1c327beac
```

> [!warning] Un même tag peut pointer vers différents digests
> 
> ```bash
> # Aujourd'hui
> docker pull python:3.11
> # digest: sha256:abc123...
> 
> # Dans 1 mois (après une mise à jour de sécurité)
> docker pull python:3.11
> # digest: sha256:def456...  ← Différent !
> ```

### 3. Plateformes incompatibles

```bash
# Sur Mac M1/M2 (ARM64), télécharger une image AMD64
docker pull mysql:8.0

# ⚠️ Fonctionne mais avec émulation (lent)
# L'image AMD64 est exécutée via Rosetta/QEMU

# ✅ Solution : spécifier la plateforme
docker pull --platform linux/arm64 mysql:8.0
```

### 4. Oublier le namespace pour les images communautaires

```bash
# ❌ Erreur fréquente
docker pull myapp
# Error: pull access denied for myapp, repository does not exist

# ✅ Correct
docker pull username/myapp
```

### 5. Espace disque insuffisant

```bash
# Les images s'accumulent rapidement
docker pull ubuntu:22.04    # ~30 MB
docker pull postgres:15     # ~150 MB
docker pull node:18         # ~400 MB

# Vérifier l'espace utilisé
docker system df

# Nettoyer les images inutilisées
docker image prune -a
```

### 6. Problèmes de rate limiting

Docker Hub limite les téléchargements anonymes (100 pulls / 6h par IP).

```bash
# ❌ Sans authentification : limite atteinte rapidement
docker pull nginx

# ✅ Avec authentification : limite plus élevée (200/6h gratuit, illimité payant)
docker login
docker pull nginx
```

> [!tip] Contourner les rate limits
> 
> - Créez un compte Docker Hub gratuit (200 pulls/6h)
> - Utilisez un registre alternatif (GCR, ECR)
> - Configurez un cache registry local pour votre équipe
> - Passez à un abonnement payant Docker Hub si nécessaire

### 7. Télécharger toutes les variantes par erreur

```bash
# ❌ Télécharge TOUS les tags (peut représenter plusieurs GB)
docker pull --all-tags nginx

# ✅ Téléchargez seulement ce dont vous avez besoin
docker pull nginx:1.25-alpine
```

### 8. Ignorer les avertissements de sécurité

```bash
# Après un pull, Docker peut afficher des warnings
docker pull node:14
# Warning: node:14 has known vulnerabilities

# ✅ Toujours utiliser des versions maintenues
docker pull node:20-alpine  # Version LTS récente
```

---

## Bonnes pratiques récapitulatives

> [!tip] Checklist pour le téléchargement d'images
> 
> ✅ **Toujours** spécifier un tag de version précis en production  
> ✅ **Privilégier** les images officielles quand elles existent  
> ✅ **Utiliser** des variantes allégées (`alpine`, `slim`) en production  
> ✅ **Vérifier** la date de dernière mise à jour de l'image  
> ✅ **Documenter** les versions utilisées dans votre projet  
> ✅ **Tester** les nouvelles versions avant de les déployer  
> ✅ **S'authentifier** sur Docker Hub pour éviter les rate limits  
> ✅ **Scanner** les images pour détecter les vulnérabilités  
> ✅ **Nettoyer** régulièrement les images inutilisées
> 
> ❌ **Éviter** d'utiliser `:latest` en production  
> ❌ **Ne pas** faire confiance aveuglément aux images communautaires  
> ❌ **Ne pas** télécharger `--all-tags` sans raison valable  
> ❌ **Ne pas** ignorer les avertissements de plateforme

**Commandes de vérification post-téléchargement** :

```bash
# Lister les images téléchargées
docker images

# Inspecter une image
docker image inspect nginx:1.25-alpine

# Voir l'historique des couches
docker history nginx:1.25-alpine

# Analyser les vulnérabilités
docker scout cves nginx:1.25-alpine

# Afficher la taille réelle
docker system df -v | grep nginx
```