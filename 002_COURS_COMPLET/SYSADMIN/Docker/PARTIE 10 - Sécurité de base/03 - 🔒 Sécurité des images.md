

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

## Introduction à la sécurité des images

Les images Docker constituent le point de départ de tout conteneur. Une image compromise peut exposer l'ensemble de votre infrastructure à des vulnérabilités critiques. La sécurité des images repose sur trois piliers fondamentaux : l'utilisation de sources fiables, la vérification de l'intégrité et l'application des bonnes pratiques de construction.

> [!warning] Pourquoi la sécurité des images est critique
> 
> - Une image malveillante peut contenir des backdoors, des malwares ou des vulnérabilités connues
> - Les images non maintenues accumulent des failles de sécurité au fil du temps
> - Une seule image compromise peut infecter tous les conteneurs qui en dérivent

---

## Utilisation d'images officielles

### Qu'est-ce qu'une image officielle ?

Les images officielles Docker sont des images maintenues par Docker Inc. ou les éditeurs des logiciels concernés. Elles sont hébergées sur Docker Hub avec un badge "Official Image" et suivent des standards stricts de sécurité et de qualité.

### Pourquoi privilégier les images officielles ?

Les images officielles offrent plusieurs garanties de sécurité essentielles. Elles sont régulièrement scannées pour détecter les vulnérabilités, maintenues à jour avec les derniers correctifs de sécurité, et construites selon les meilleures pratiques de l'industrie. De plus, leur provenance est vérifiée et documentée de manière transparente.

### Identifier une image officielle

```bash
# Image officielle (notation courte, sans préfixe)
docker pull nginx

# Image officielle (notation complète)
docker pull docker.io/library/nginx

# Image NON officielle (avec nom d'utilisateur ou organisation)
docker pull moncompte/nginx
docker pull bitnami/nginx
```

> [!info] Structure des noms d'images
> 
> - **Image officielle** : `nginx:latest` ou `library/nginx:latest`
> - **Image utilisateur** : `utilisateur/nginx:latest`
> - **Image organisation** : `organisation/nginx:latest`

### Vérifier la fiabilité d'une image sur Docker Hub

|Critère|Description|Où le trouver|
|---|---|---|
|**Official Image**|Badge officiel Docker|En haut de la page de l'image|
|**Verified Publisher**|Éditeur vérifié par Docker|Badge à côté du nom|
|**Nombre de pulls**|Popularité et confiance communautaire|Statistiques de la page|
|**Dernière mise à jour**|Fraîcheur et maintenance|Section "Last pushed"|
|**Documentation**|Qualité et complétude|Onglet "Overview"|
|**Scan de sécurité**|Vulnérabilités détectées|Onglet "Tags"|

### Bonnes pratiques pour choisir une image

```bash
# ✅ BON : Image officielle avec tag spécifique
docker pull nginx:1.25-alpine

# ✅ BON : Image vérifiée d'un éditeur reconnu
docker pull redis:7.2-alpine

# ⚠️ ACCEPTABLE : Image d'une organisation réputée
docker pull bitnami/postgresql:16

# ❌ MAUVAIS : Image d'utilisateur inconnu
docker pull randomuser123/nginx

# ❌ MAUVAIS : Tag 'latest' (non déterministe)
docker pull nginx:latest
```

> [!tip] Astuce pour les images non officielles Si vous devez utiliser une image non officielle, vérifiez :
> 
> - Le dépôt GitHub source (s'il existe)
> - Le Dockerfile utilisé pour la construction
> - L'historique des commits et la fréquence de maintenance
> - Les avis et issues sur GitHub
> - Le scan de vulnérabilités sur Docker Hub

### Commandes pour explorer les images

```bash
# Lister les images officielles disponibles
docker search nginx --filter is-official=true

# Rechercher avec critères de qualité
docker search nginx --filter stars=1000

# Afficher les détails d'une image locale
docker image inspect nginx:1.25-alpine

# Afficher l'historique des couches d'une image
docker history nginx:1.25-alpine
```

> [!warning] Pièges courants
> 
> - Ne pas confondre "populaire" avec "sécurisé" : une image avec beaucoup de pulls peut contenir des vulnérabilités
> - Éviter les images avec des tags génériques comme `latest`, `stable` ou `production`
> - Méfiance envers les images qui promettent "tout-en-un" : elles violent souvent le principe d'un processus par conteneur

---

## Vérification des signatures

### Qu'est-ce que Docker Content Trust ?

Docker Content Trust (DCT) est un système de signature cryptographique permettant de vérifier l'authenticité et l'intégrité des images Docker. Il repose sur la technologie Notary et utilise des clés publiques/privées pour garantir que l'image provient bien de l'éditeur déclaré et n'a pas été altérée.

### Pourquoi vérifier les signatures ?

La vérification des signatures protège contre plusieurs menaces : les attaques de type "man-in-the-middle" lors du téléchargement, les images compromises sur des registres publics, et le remplacement d'images par des versions malveillantes. Elle garantit également la non-répudiation, prouvant qu'une image spécifique a bien été publiée par son éditeur.

### Activation de Docker Content Trust

```bash
# Activer DCT pour la session courante
export DOCKER_CONTENT_TRUST=1

# Vérifier l'activation
echo $DOCKER_CONTENT_TRUST

# Désactiver DCT
export DOCKER_CONTENT_TRUST=0

# Activer DCT de manière permanente (Linux/Mac)
echo 'export DOCKER_CONTENT_TRUST=1' >> ~/.bashrc
source ~/.bashrc
```

> [!info] Impact de l'activation de DCT Avec DCT activé, Docker refusera de pull ou push des images non signées. Seules les images avec des signatures valides pourront être utilisées.

### Utilisation de DCT pour pull et push

```bash
# Pull avec vérification de signature (DCT activé)
docker pull nginx:1.25-alpine
# Si l'image n'est pas signée, le pull échouera

# Pull en ignorant DCT ponctuellement
DOCKER_CONTENT_TRUST=0 docker pull imagenonssignee:latest

# Push avec signature automatique (nécessite des clés)
docker push monregistre.com/monimage:v1.0
# Docker demandera la passphrase pour signer l'image
```

### Gestion des clés de signature

Docker Content Trust utilise plusieurs types de clés :

```bash
# Générer les clés lors du premier push signé
docker push monregistre.com/monimage:v1.0
# Docker crée automatiquement :
# - Root key (clé racine) : ~/.docker/trust/private/root_keys/
# - Repository key (clé du dépôt) : ~/.docker/trust/private/tuf_keys/

# Lister les clés de confiance
docker trust key generate monnom
# Crée une paire de clés publique/privée

# Importer une clé publique d'un signataire
docker trust signer add --key cert.pem monnom monregistre.com/monimage

# Inspecter les signataires d'une image
docker trust inspect --pretty nginx:1.25-alpine
```

> [!warning] Sécurisation des clés privées **Critiquement important** :
> 
> - Sauvegardez vos clés root et repository dans un endroit sûr (gestionnaire de secrets, HSM)
> - Ne commitez JAMAIS les clés privées dans Git
> - Utilisez des passphrases fortes pour chiffrer les clés
> - La perte de la clé root empêche toute signature future pour vos images

### Vérification manuelle des signatures

```bash
# Afficher les informations de signature d'une image
docker trust inspect nginx:1.25-alpine

# Format lisible avec les signataires
docker trust inspect --pretty nginx:1.25-alpine

# Exemple de sortie :
# Signatures for nginx:1.25-alpine
# SIGNED TAG          DIGEST                                                             SIGNERS
# 1.25-alpine         a3b8c9d7f1e2...                                                    (Repo Admin)
# Administrative keys for nginx:1.25-alpine
# Repository Key: 4f3e2d1c0b9a...
# Root Key:       7a6b5c4d3e2f...
```

### Docker Content Trust dans un workflow CI/CD

```bash
# Dans un pipeline de build
# 1. Builder l'image
docker build -t monregistre.com/app:${VERSION} .

# 2. Activer DCT
export DOCKER_CONTENT_TRUST=1

# 3. Se connecter au registre
echo "${REGISTRY_PASSWORD}" | docker login -u "${REGISTRY_USER}" --password-stdin monregistre.com

# 4. Pousser l'image signée
docker push monregistre.com/app:${VERSION}

# 5. Vérifier la signature
docker trust inspect --pretty monregistre.com/app:${VERSION}
```

> [!tip] Astuce pour les registres privés Pour activer DCT avec des registres privés :
> 
> ```bash
> export DOCKER_CONTENT_TRUST=1
> export DOCKER_CONTENT_TRUST_SERVER=https://monregistre.com:4443
> ```

### Gestion des métadonnées de confiance

```bash
# Révoquer une signature (en cas de compromission)
docker trust revoke monregistre.com/monimage:v1.0

# Supprimer toutes les données de confiance d'un dépôt
docker trust signer remove monnom monregistre.com/monimage

# Effectuer une rotation de la clé repository
docker trust key rotate --key repository monregistre.com/monimage
```

### Alternatives et compléments à DCT

|Solution|Utilisation|Avantage|
|---|---|---|
|**Cosign**|Signature d'images OCI|Standard émergent, intégration Kubernetes|
|**Notary v2**|Évolution de Notary|Support amélioré, plus flexible|
|**Sigstore**|Infrastructure de signature|Open source, gratuit, transparent|
|**In-toto**|Chaîne de custody complète|Traçabilité du build à la prod|

> [!example] Utilisation de Cosign (alternative moderne)
> 
> ```bash
> # Installer Cosign
> go install github.com/sigstore/cosign/cmd/cosign@latest
> 
> # Signer une image
> cosign sign --key cosign.key monregistre.com/app:v1.0
> 
> # Vérifier une signature
> cosign verify --key cosign.pub monregistre.com/app:v1.0
> ```

> [!warning] Limitations de Docker Content Trust
> 
> - Ne protège pas contre les vulnérabilités dans le contenu de l'image
> - Ne remplace pas un scan de sécurité complet
> - Nécessite une gestion rigoureuse des clés
> - Tous les registres ne supportent pas DCT

---

## Construction d'images sécurisées

### Principes fondamentaux d'une image sécurisée

La construction d'images Docker sécurisées repose sur plusieurs principes essentiels. Une image doit contenir le minimum de composants nécessaires pour réduire la surface d'attaque, s'exécuter avec des privilèges minimaux, être construite de manière reproductible et transparente, et être régulièrement mise à jour pour intégrer les correctifs de sécurité.

### Choix de l'image de base

```dockerfile
# ❌ MAUVAIS : Image complète avec beaucoup de surface d'attaque
FROM ubuntu:latest

# ⚠️ MOYEN : Image slim plus légère
FROM python:3.12-slim

# ✅ BON : Image alpine minimaliste
FROM python:3.12-alpine

# ✅ EXCELLENT : Distroless (sans shell, gestionnaire de paquets)
FROM gcr.io/distroless/python3-debian12

# ✅ OPTIMAL : Scratch pour binaires statiques
FROM scratch
```

> [!info] Comparaison des tailles d'images de base
> 
> |Image|Taille approximative|Cas d'usage|
> |---|---|---|
> |`ubuntu:latest`|~70 MB|Développement, débogage|
> |`alpine:latest`|~5 MB|Production, microservices|
> |`distroless`|~20-50 MB|Production sécurisée|
> |`scratch`|0 MB|Binaires Go/Rust compilés statiquement|

### Construction en multi-stage pour réduire la surface d'attaque

```dockerfile
# Stage 1 : Build avec tous les outils nécessaires
FROM node:18-alpine AS builder

WORKDIR /app

# Copier uniquement les fichiers de dépendances d'abord
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le code source
COPY . .

# Builder l'application
RUN npm run build

# Stage 2 : Image finale minimaliste
FROM node:18-alpine

# Créer un utilisateur non-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copier uniquement les artefacts nécessaires depuis le builder
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Changer vers l'utilisateur non-root
USER nodejs

# Exposer le port
EXPOSE 3000

# Commande de démarrage
CMD ["node", "dist/index.js"]
```

> [!tip] Avantages du multi-stage
> 
> - Séparation des outils de build de l'image finale
> - Réduction drastique de la taille de l'image (jusqu'à 90%)
> - Exclusion automatique des secrets et fichiers temporaires de build
> - Amélioration du temps de déploiement

### Gestion sécurisée des utilisateurs

```dockerfile
# ❌ MAUVAIS : Exécution en root (par défaut)
FROM alpine:latest
COPY app /app
CMD ["/app"]

# ✅ BON : Création et utilisation d'un utilisateur dédié
FROM alpine:latest

# Créer un groupe et un utilisateur avec UID/GID spécifiques
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Créer le répertoire de l'app et définir les permissions
RUN mkdir -p /app && \
    chown -R appuser:appgroup /app

WORKDIR /app

# Copier les fichiers avec le bon ownership
COPY --chown=appuser:appgroup app /app

# Basculer vers l'utilisateur non-root
USER appuser

CMD ["/app"]
```

> [!warning] Risques de l'exécution en root
> 
> - Escalade de privilèges si le conteneur est compromis
> - Possibilité d'évasion du conteneur vers l'hôte
> - Violation du principe du moindre privilège
> - Non-conformité avec les standards de sécurité (PCI-DSS, SOC2)

### Gestion des secrets et informations sensibles

```dockerfile
# ❌ MAUVAIS : Secrets en dur dans l'image
FROM alpine:latest
ENV DATABASE_PASSWORD=monsecret123
ENV API_KEY=abc123xyz

# ❌ MAUVAIS : Secrets dans les variables d'ARG
ARG DATABASE_PASSWORD=monsecret123
ENV DATABASE_PASSWORD=${DATABASE_PASSWORD}

# ✅ BON : Utilisation de secrets au runtime
FROM alpine:latest
# Pas de secrets dans l'image
# Les secrets seront injectés via :
# - Variables d'environnement au runtime (docker run -e)
# - Docker secrets (Swarm)
# - Kubernetes secrets
# - Vault ou autre gestionnaire de secrets

# ✅ BON : Utilisation de BuildKit secrets pour le build
# syntax=docker/dockerfile:1
FROM alpine:latest
RUN --mount=type=secret,id=npm_token \
    NPM_TOKEN=$(cat /run/secrets/npm_token) npm install

# Build avec :
# docker build --secret id=npm_token,src=.npmtoken .
```

> [!example] Injection de secrets au runtime
> 
> ```bash
> # Avec docker run
> docker run -e DATABASE_PASSWORD=$(cat secret.txt) monapp
> 
> # Avec Docker Secrets (Swarm)
> echo "monsecret" | docker secret create db_password -
> docker service create --secret db_password monapp
> 
> # Avec docker-compose
> docker-compose run -e DATABASE_PASSWORD monapp
> ```

### Minimisation des couches et optimisation du cache

```dockerfile
# ❌ MAUVAIS : Trop de couches, cache mal utilisé
FROM alpine:latest
RUN apk add --no-cache curl
RUN apk add --no-cache wget
RUN apk add --no-cache git
COPY file1.txt /app/
COPY file2.txt /app/
COPY file3.txt /app/

# ✅ BON : Regroupement des commandes, ordre optimisé
FROM alpine:latest

# Installer tous les paquets en une seule couche
RUN apk add --no-cache \
    curl \
    wget \
    git

# Copier les fichiers qui changent rarement en premier
COPY config.json /app/

# Copier les fichiers qui changent souvent en dernier
COPY --chown=appuser:appgroup . /app/
```

> [!tip] Ordre optimal des instructions
> 
> 1. FROM (image de base)
> 2. Instructions RUN pour installer les dépendances système (changent rarement)
> 3. COPY/ADD pour les fichiers de configuration (changent occasionnellement)
> 4. COPY/ADD pour les dépendances applicatives (package.json, requirements.txt)
> 5. RUN pour installer les dépendances applicatives
> 6. COPY/ADD pour le code source (change fréquemment)
> 7. Instructions de configuration (USER, WORKDIR, EXPOSE, etc.)
> 8. CMD/ENTRYPOINT

### Nettoyage et suppression des fichiers temporaires

```dockerfile
# ❌ MAUVAIS : Fichiers temporaires restent dans l'image
FROM alpine:latest
RUN apk add --no-cache python3 py3-pip
RUN pip install --no-cache-dir requests
RUN apk add --no-cache git && \
    git clone https://github.com/user/repo.git && \
    cd repo && python setup.py install
# Le cache APK et le dépôt git restent dans l'image !

# ✅ BON : Nettoyage dans la même couche
FROM alpine:latest

RUN apk add --no-cache python3 py3-pip && \
    pip install --no-cache-dir requests && \
    rm -rf /root/.cache

RUN apk add --no-cache --virtual .build-deps git && \
    git clone https://github.com/user/repo.git && \
    cd repo && \
    python setup.py install && \
    cd .. && \
    rm -rf repo && \
    apk del .build-deps

# ✅ EXCELLENT : Utilisation de multi-stage
FROM alpine:latest AS builder
RUN apk add --no-cache git
RUN git clone https://github.com/user/repo.git
WORKDIR /repo
RUN python setup.py bdist_wheel

FROM alpine:latest
RUN apk add --no-cache python3 py3-pip
COPY --from=builder /repo/dist/*.whl /tmp/
RUN pip install --no-cache-dir /tmp/*.whl && rm /tmp/*.whl
```

> [!warning] Erreur courante avec les couches
> 
> ```dockerfile
> # ❌ CECI NE FONCTIONNE PAS
> RUN apt-get update && apt-get install -y curl
> RUN rm -rf /var/lib/apt/lists/*
> # Les fichiers sont dans une couche précédente, la suppression 
> # n'économise PAS d'espace dans l'image finale !
> 
> # ✅ CORRECT
> RUN apt-get update && \
>     apt-get install -y curl && \
>     rm -rf /var/lib/apt/lists/*
> ```

### Hardening du système dans l'image

```dockerfile
FROM alpine:latest

# Mettre à jour tous les paquets pour les derniers correctifs
RUN apk upgrade --no-cache

# Supprimer les paquets inutiles qui augmentent la surface d'attaque
RUN apk del --no-cache \
    apk-tools \
    alpine-keys

# Désactiver l'accès shell (si l'app n'en a pas besoin)
RUN rm -rf /bin/sh /bin/bash 2>/dev/null || true

# Créer un utilisateur et groupe dédiés
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup -s /sbin/nologin

# Définir des permissions restrictives
RUN chmod 700 /app && \
    chown appuser:appgroup /app

# Supprimer les fichiers sensibles par défaut
RUN rm -f /etc/shadow /etc/passwd- /etc/group- 2>/dev/null || true

USER appuser

# Définir un healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
```

### Labels et métadonnées de sécurité

```dockerfile
FROM alpine:latest

# Labels de sécurité et traçabilité
LABEL maintainer="security@company.com" \
      version="1.0.0" \
      description="Application sécurisée" \
      org.opencontainers.image.source="https://github.com/company/repo" \
      org.opencontainers.image.vendor="Company Name" \
      org.opencontainers.image.licenses="MIT" \
      security.scan.date="2024-01-15" \
      security.vulnerabilities="none"

# Documentation des ports exposés (n'ouvre pas réellement les ports)
EXPOSE 3000

# Point de montage pour les volumes
VOLUME ["/data"]

# Configuration du healthcheck
HEALTHCHECK --interval=30s CMD wget --spider http://localhost:3000/health || exit 1
```

### Gestion des dépendances et reproductibilité

```dockerfile
# ✅ BON : Versions fixées pour la reproductibilité
FROM node:18.19.0-alpine3.19

# Installer des versions spécifiques de paquets système
RUN apk add --no-cache \
    curl=8.5.0-r0 \
    ca-certificates=20240226-r0

WORKDIR /app

# Copier les fichiers de lock pour garantir les versions exactes
COPY package.json package-lock.json ./

# Utiliser npm ci (install propre) au lieu de npm install
RUN npm ci --only=production --ignore-scripts

# ❌ MAUVAIS : Versions flottantes
# FROM node:18-alpine
# RUN apk add --no-cache curl
# RUN npm install
```

> [!tip] Bonnes pratiques pour les dépendances
> 
> - Toujours fixer les versions (image de base, paquets système, dépendances app)
> - Utiliser les fichiers de lock (package-lock.json, poetry.lock, Gemfile.lock)
> - Scanner régulièrement les vulnérabilités avec `docker scout` ou Trivy
> - Mettre à jour les dépendances de manière contrôlée et testée

### Dockerfile complet sécurisé (exemple Python)

```dockerfile
# syntax=docker/dockerfile:1

# Stage 1 : Builder
FROM python:3.12.1-alpine3.19 AS builder

# Installer les dépendances de build
RUN apk add --no-cache --virtual .build-deps \
    gcc=13.2.1_git20231014-r0 \
    musl-dev=1.2.4_git20230717-r4 \
    postgresql-dev=16.1-r0

WORKDIR /app

# Copier et installer les dépendances Python
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

# Stage 2 : Image finale
FROM python:3.12.1-alpine3.19

# Mettre à jour le système
RUN apk upgrade --no-cache

# Installer uniquement les runtime dependencies
RUN apk add --no-cache \
    libpq=16.1-r0 \
    ca-certificates=20240226-r0

# Créer un utilisateur non-root
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup -s /sbin/nologin

# Créer les répertoires nécessaires
RUN mkdir -p /app /data && \
    chown -R appuser:appgroup /app /data

WORKDIR /app

# Copier les wheels depuis le builder
COPY --from=builder /wheels /wheels

# Installer les dépendances depuis les wheels
RUN pip install --no-cache-dir --no-index --find-links=/wheels /wheels/* && \
    rm -rf /wheels

# Copier le code source avec le bon ownership
COPY --chown=appuser:appgroup . .

# Basculer vers l'utilisateur non-root
USER appuser

# Labels de métadonnées
LABEL maintainer="devops@company.com" \
      version="1.0.0" \
      description="Application Python sécurisée"

# Exposer le port (documentaire)
EXPOSE 8000

# Volume pour les données persistantes
VOLUME ["/data"]

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

# Commande de démarrage
CMD ["python", "app.py"]
```

### Scan de vulnérabilités pendant le build

```bash
# Scanner une image avec Docker Scout (intégré à Docker)
docker scout cves monimage:latest

# Scanner avec Trivy (outil open-source populaire)
trivy image monimage:latest

# Scanner et échouer le build si des vulnérabilités critiques
trivy image --exit-code 1 --severity CRITICAL,HIGH monimage:latest

# Scanner uniquement les vulnérabilités fixables
trivy image --ignore-unfixed monimage:latest

# Générer un rapport HTML
trivy image --format template --template "@html.tpl" -o report.html monimage:latest
```

> [!example] Intégration du scan dans un CI/CD
> 
> ```yaml
> # Exemple GitHub Actions
> - name: Build image
>   run: docker build -t myapp:${{ github.sha }} .
> 
> - name: Scan for vulnerabilities
>   run: |
>     docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
>       aquasec/trivy image --exit-code 1 --severity CRITICAL,HIGH \
>       myapp:${{ github.sha }}
> 
> - name: Push if scan passed
>   run: docker push myapp:${{ github.sha }}
> ```

### Fichiers .dockerignore pour exclure les fichiers sensibles

```dockerignore
# Fichiers de version control
.git
.gitignore
.gitattributes

# Fichiers de configuration et secrets
.env
.env.*
*.key
*.pem
*.crt
secrets/
config/local.*

# Fichiers de build et dépendances
node_modules/
__pycache__/
*.pyc
.pytest_cache/
dist/
build/
target/

# Documentation et fichiers inutiles en production
README.md
docs/
*.md
LICENSE
Makefile

# Fichiers de développement
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Logs et fichiers temporaires
*.log
logs/
tmp/
temp/
```

> [!warning] Erreur critique à éviter **Ne JAMAIS inclure de fichiers secrets dans l'image**, même si vous les supprimez ensuite. Les fichiers restent dans l'historique des couches de l'image et peuvent être extraits. Utilisez toujours `.dockerignore` et des mécanismes d'injection de secrets au runtime.

### Checklist de sécurité pour Dockerfile

- [ ] Image de base officielle ou vérifiée avec version fixée
- [ ] Multi-stage build pour réduire la taille finale
- [ ] Utilisateur non-root créé et utilisé
- [ ] Aucun secret ou credential en dur dans l'image
- [ ] Packages système mis à jour (`apk upgrade`, `apt-get upgrade`)
- [ ] Nettoyage des caches et fichiers temporaires dans la même couche
- [ ] Versions fixes pour toutes les dépendances
- [ ] `.dockerignore` configuré pour exclure les fichiers sensibles
- [ ] HEALTHCHECK défini pour la supervision
- [ ] Labels de métadonnées et traçabilité ajoutés
- [ ] Ports exposés documentés avec EXPOSE
- [ ] Image scannée pour les vulnérabilités
- [ ] Permissions restrictives sur les fichiers et répertoires
- [ ] Suppression des outils et shells inutiles
- [ ] Signature de l'image avec DCT ou Cosign

> [!tip] Automatisation de la checklist Utilisez des outils de lint pour Dockerfile :
> 
> ```bash
> # Hadolint : linter pour Dockerfile
> docker run --rm -i hadolint/hadolint < Dockerfile
> 
> # Dockle : linter de sécurité spécialisé
> docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
>   goodwithtech/dockle monimage:latest
> ```

---

## 🎯 Récapitulatif des bonnes pratiques

### Processus de sécurisation complet

Un processus de sécurisation d'images Docker efficace suit un cycle complet : sélection d'une image de base fiable, construction sécurisée avec Dockerfile optimisé, scan des vulnérabilités, signature de l'image, et surveillance continue après déploiement.

```bash
# 1. Sélection de l'image de base
# Vérifier l'image sur Docker Hub avant utilisation

# 2. Construction avec bonnes pratiques
docker build -t monapp:1.0.0 .

# 3. Scan de vulnérabilités
trivy image --severity HIGH,CRITICAL monapp:1.0.0

# 4. Test de l'image
docker run --rm --read-only --user 1001 monapp:1.0.0 /bin/sh -c "whoami"

# 5. Signature de l'image
export DOCKER_CONTENT_TRUST=1
docker tag monapp:1.0.0 registry.company.com/monapp:1.0.0
docker push registry.company.com/monapp:1.0.0

# 6. Vérification finale
docker trust inspect --pretty registry.company.com/monapp:1.0.0
```

### Matrice de décision pour le choix d'image de base

|Critère|Alpine|Distroless|Ubuntu|Scratch|
|---|---|---|---|---|
|**Taille**|5-20 MB|20-50 MB|70+ MB|0 MB|
|**Sécurité**|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|⭐⭐⭐|⭐⭐⭐⭐⭐|
|**Facilité debug**|⭐⭐⭐⭐|⭐|⭐⭐⭐⭐⭐|⭐|
|**Compatibilité**|⭐⭐⭐|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|⭐⭐|
|**Maintenance**|⭐⭐⭐⭐|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|⭐|
|**Cas d'usage**|Production générale|Production sécurisée|Dev/Test|Binaires statiques|

### Outils essentiels pour la sécurité des images

**Scanners de vulnérabilités :**

```bash
# Trivy (recommandé, open-source)
trivy image monimage:latest

# Docker Scout (intégré à Docker Desktop)
docker scout cves monimage:latest

# Clair (pour registres privés)
clairctl analyze monimage:latest

# Grype (Anchore)
grype monimage:latest
```

**Linters et analyseurs de Dockerfile :**

```bash
# Hadolint (analyse syntaxe et bonnes pratiques)
hadolint Dockerfile

# Dockle (analyse sécurité de l'image)
dockle monimage:latest

# Dive (exploration des couches)
dive monimage:latest
```

**Outils de signature :**

```bash
# Docker Content Trust (natif Docker)
export DOCKER_CONTENT_TRUST=1

# Cosign (Sigstore, moderne)
cosign sign --key cosign.key monimage:latest

# Notary (standalone)
notary adddelegation --publish monimage latest cert.pem --all-paths
```

> [!tip] Configuration d'un pipeline de sécurité complet
> 
> ```bash
> #!/bin/bash
> # Pipeline de sécurisation d'image
> 
> IMAGE_NAME="monapp"
> IMAGE_TAG="1.0.0"
> REGISTRY="registry.company.com"
> 
> echo "🔨 Build de l'image..."
> docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
> 
> echo "🔍 Lint du Dockerfile..."
> hadolint Dockerfile || exit 1
> 
> echo "🔍 Analyse de sécurité avec Dockle..."
> dockle ${IMAGE_NAME}:${IMAGE_TAG} || exit 1
> 
> echo "🛡️ Scan des vulnérabilités avec Trivy..."
> trivy image --exit-code 1 --severity CRITICAL,HIGH ${IMAGE_NAME}:${IMAGE_TAG}
> 
> echo "🔐 Tag et push avec signature..."
> docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
> export DOCKER_CONTENT_TRUST=1
> docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
> 
> echo "✅ Image sécurisée et déployée !"
> docker trust inspect --pretty ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
> ```

### Comparaison des approches de construction

|Approche|Avantages|Inconvénients|Quand l'utiliser|
|---|---|---|---|
|**Image complète (Ubuntu)**|Facilité de debug, tous les outils disponibles|Taille importante, surface d'attaque large|Développement, prototypage|
|**Image slim**|Bon compromis taille/fonctionnalités|Toujours des packages inutiles|Applications avec dépendances complexes|
|**Image alpine**|Très légère, bonne sécurité|Compatibilité musl vs glibc|Production standard, microservices|
|**Image distroless**|Sécurité maximale, pas de shell|Debug difficile, courbe d'apprentissage|Production critique, conformité stricte|
|**Multi-stage**|Meilleur des deux mondes|Dockerfile plus complexe|Toujours recommandé en production|

### Gestion des mises à jour de sécurité

Les images Docker nécessitent une maintenance régulière pour rester sécurisées. Établissez un processus de mise à jour systématique.

```dockerfile
# ✅ Stratégie de mise à jour dans le Dockerfile
FROM alpine:3.19

# Toujours mettre à jour les packages au build
RUN apk upgrade --no-cache && \
    apk add --no-cache \
    curl=8.5.0-r0 \
    ca-certificates=20240226-r0

# Inclure la date de build comme label
LABEL build.date="2024-01-15" \
      security.scan="passed" \
      base.image="alpine:3.19"
```

**Automatisation des rebuilds de sécurité :**

```bash
# Script de rebuild automatique hebdomadaire
#!/bin/bash

# Rebuild toutes les images
for image in $(cat images-list.txt); do
    echo "Rebuild de ${image}..."
    docker build --no-cache -t ${image} ./builds/${image}
    
    # Scan
    trivy image --exit-code 1 --severity CRITICAL ${image}
    
    if [ $? -eq 0 ]; then
        docker push ${image}
        echo "✅ ${image} mis à jour et déployé"
    else
        echo "❌ ${image} contient des vulnérabilités critiques"
    fi
done
```

> [!warning] Fréquence de mise à jour recommandée
> 
> - **Images de base** : Rebuild hebdomadaire minimum
> - **Applications critiques** : Rebuild dès qu'une CVE critique est publiée
> - **Dépendances** : Mise à jour mensuelle avec tests
> - **Scan continu** : Quotidien sur les images en production

### Patterns de sécurité avancés

**1. Image immuable avec hash de contenu :**

```dockerfile
FROM alpine:3.19@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b

# Utilisation du hash SHA256 exact de l'image
# Garantit l'immuabilité totale de l'image de base
```

**2. Validation des checksums de fichiers téléchargés :**

```dockerfile
FROM alpine:3.19

# Télécharger et vérifier le checksum
RUN wget https://releases.example.com/app-1.0.tar.gz && \
    echo "abc123... app-1.0.tar.gz" | sha256sum -c - && \
    tar xzf app-1.0.tar.gz && \
    rm app-1.0.tar.gz
```

**3. Durcissement du filesystem :**

```dockerfile
FROM alpine:3.19

# Rendre le filesystem read-only sauf exceptions
RUN mkdir -p /app /tmp /var/run && \
    chmod 1777 /tmp && \
    chmod 700 /app /var/run

USER 1001

# Au runtime, utiliser --read-only avec des volumes pour les écritures
# docker run --read-only -v /tmp:/tmp -v /var/run:/var/run monimage
```

**4. Minimisation des capabilities Linux :**

```bash
# Bien que ce soit plutôt du runtime, documenter dans l'image
# les capabilities nécessaires

# Dockerfile avec documentation
LABEL security.capabilities.required="NET_BIND_SERVICE" \
      security.capabilities.dropped="ALL"

# Commande de run recommandée
# docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE monimage
```

### Gestion des images dans un registre privé

```bash
# Configuration d'un registre privé sécurisé
docker run -d \
  -p 5000:5000 \
  --name registry \
  -v /data/registry:/var/lib/registry \
  -e REGISTRY_STORAGE_DELETE_ENABLED=true \
  -e REGISTRY_HTTP_SECRET=secretrandom123 \
  registry:2

# Activation de Docker Content Trust pour le registre
export DOCKER_CONTENT_TRUST=1
export DOCKER_CONTENT_TRUST_SERVER=https://notary.company.com:4443

# Politique de rétention (supprimer les anciennes images)
# Utiliser registry garbage collection
docker exec registry bin/registry garbage-collect /etc/docker/registry/config.yml

# Scanner périodiquement toutes les images du registre
for image in $(curl -s https://registry.company.com/v2/_catalog | jq -r '.repositories[]'); do
    trivy image registry.company.com/${image}:latest
done
```

### Documentation de sécurité de l'image

Toute image de production devrait avoir une documentation de sécurité associée :

````markdown
# Image Security Profile: monapp:1.0.0

## Image Information
- **Base Image**: alpine:3.19@sha256:abc123...
- **Build Date**: 2024-01-15
- **Maintainer**: security@company.com
- **Last Security Scan**: 2024-01-15 (passed)

## Security Features
- ✅ Non-root user (UID 1001)
- ✅ Multi-stage build
- ✅ Read-only filesystem compatible
- ✅ No secrets embedded
- ✅ Signed with DCT
- ✅ Scanned for CVEs (0 high/critical)

## Required Capabilities
- `NET_BIND_SERVICE` (for binding to port 80)

## Required Volumes
- `/data` (read-write, persistent storage)
- `/tmp` (read-write, temporary files)

## Runtime Security Recommendations
```bash
docker run -d \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  -v data-volume:/data:rw \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --user 1001:1001 \
  --security-opt=no-new-privileges \
  monapp:1.0.0
````

## Known Vulnerabilities

None (last scan: 2024-01-15)

## Dependencies

- curl: 8.5.0-r0
- ca-certificates: 20240226-r0
- python3: 3.12.1-r0

````

### Pièges courants à éviter

> [!warning] Top 10 des erreurs de sécurité
> 
> 1. **Utiliser l'image `latest`** : Non-déterministe, impossible à reproduire
> 2. **Exécuter en root** : Violation du principe du moindre privilège
> 3. **Inclure des secrets dans l'image** : Persistent dans l'historique des couches
> 4. **Ne pas scanner les vulnérabilités** : Déploiement de CVEs connues
> 5. **Images trop volumineuses** : Surface d'attaque et temps de déploiement
> 6. **Pas de healthcheck** : Impossible de détecter les conteneurs en échec
> 7. **Versions non fixées des dépendances** : Builds non reproductibles
> 8. **Oublier le .dockerignore** : Inclusion de fichiers sensibles
> 9. **Pas de multi-stage** : Outils de build en production
> 10. **Absence de signature** : Impossible de vérifier l'intégrité

### Vérification finale avant déploiement

Checklist de validation à exécuter avant tout déploiement en production :

```bash
#!/bin/bash
# Validation complète d'une image

IMAGE=$1

echo "🔍 Vérification de l'image ${IMAGE}..."

# 1. Vérifier que l'image existe
docker image inspect ${IMAGE} > /dev/null 2>&1 || {
    echo "❌ Image introuvable"
    exit 1
}

# 2. Vérifier qu'elle n'utilise pas root
ROOT_USER=$(docker image inspect ${IMAGE} --format='{{.Config.User}}')
if [ -z "$ROOT_USER" ] || [ "$ROOT_USER" = "0" ] || [ "$ROOT_USER" = "root" ]; then
    echo "❌ Image s'exécute en root"
    exit 1
fi
echo "✅ Image utilise l'utilisateur ${ROOT_USER}"

# 3. Scanner les vulnérabilités
echo "🛡️ Scan de sécurité..."
trivy image --severity HIGH,CRITICAL --exit-code 1 ${IMAGE} || {
    echo "❌ Vulnérabilités détectées"
    exit 1
}
echo "✅ Aucune vulnérabilité critique"

# 4. Vérifier la signature (si DCT activé)
if [ "$DOCKER_CONTENT_TRUST" = "1" ]; then
    docker trust inspect ${IMAGE} > /dev/null 2>&1 || {
        echo "❌ Image non signée"
        exit 1
    }
    echo "✅ Image correctement signée"
fi

# 5. Vérifier la taille
SIZE=$(docker image inspect ${IMAGE} --format='{{.Size}}')
SIZE_MB=$((SIZE / 1024 / 1024))
if [ $SIZE_MB -gt 500 ]; then
    echo "⚠️  Avertissement : Image volumineuse (${SIZE_MB}MB)"
fi

# 6. Tester le healthcheck
docker run --rm -d --name test-${RANDOM} ${IMAGE}
sleep 5
HEALTH=$(docker inspect test-${RANDOM} --format='{{.State.Health.Status}}')
docker stop test-${RANDOM} > /dev/null 2>&1
if [ "$HEALTH" != "healthy" ] && [ "$HEALTH" != "" ]; then
    echo "⚠️  Healthcheck non sain : ${HEALTH}"
fi

echo "✅ Validation complète réussie !"
echo "Image prête pour le déploiement en production"
````

### Métriques de sécurité à surveiller

Établissez des KPIs pour mesurer la qualité de sécurité de vos images :

|Métrique|Objectif|Critique|
|---|---|---|
|**Images avec CVE critiques**|0|< 5%|
|**Images signées**|100%|> 95%|
|**Images avec utilisateur root**|0|< 10%|
|**Âge moyen des images**|< 7 jours|< 30 jours|
|**Taille moyenne des images**|< 100MB|< 500MB|
|**Images scannées dans les 24h**|100%|> 90%|
|**Temps de correction CVE**|< 24h|< 7 jours|

> [!tip] Tableau de bord de sécurité Créez un dashboard automatisé qui affiche ces métriques en temps réel. Utilisez des outils comme Prometheus + Grafana pour visualiser l'état de sécurité de votre registre d'images.

---

## 📚 Synthèse finale

La sécurité des images Docker repose sur trois piliers indissociables : l'utilisation d'images de base fiables et vérifiées, la vérification systématique des signatures pour garantir l'intégrité, et l'application rigoureuse des bonnes pratiques de construction pour minimiser la surface d'attaque.

### Les points essentiels à retenir

**Pour les images officielles :**

- Privilégiez toujours les images officielles ou celles d'éditeurs vérifiés
- Fixez les versions exactes avec des tags spécifiques (jamais `latest`)
- Vérifiez les scans de vulnérabilités sur Docker Hub avant utilisation
- Utilisez les hashs SHA256 pour une immuabilité totale

**Pour la vérification des signatures :**

- Activez Docker Content Trust en production
- Gérez vos clés de signature de manière sécurisée
- Automatisez la signature dans vos pipelines CI/CD
- Vérifiez les signatures avant chaque déploiement

**Pour la construction sécurisée :**

- Utilisez le multi-stage build systématiquement
- Créez et utilisez un utilisateur non-root
- Ne stockez jamais de secrets dans l'image
- Scannez les vulnérabilités à chaque build
- Maintenez vos images à jour régulièrement

> [!tip] Règle d'or de la sécurité des images **Une image sécurisée est une image :**
> 
> - **Minimale** (seulement ce qui est nécessaire)
> - **Vérifiable** (signée et scannée)
> - **Maintenue** (régulièrement mise à jour)
> - **Documentée** (traçabilité complète)

La sécurité des images n'est pas un état final mais un processus continu. Intégrez ces pratiques dès le début de vos projets et automatisez-les au maximum pour garantir une sécurité durable et efficace.