

## 📚 Table des matières

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

La sécurité des conteneurs Docker est cruciale car un conteneur compromis peut potentiellement affecter l'hôte et les autres conteneurs. Cette partie couvre les bonnes pratiques fondamentales pour sécuriser vos déploiements Docker au quotidien.

> [!info] Principe de sécurité La sécurité Docker repose sur le principe de **défense en profondeur** : chaque couche de sécurité réduit la surface d'attaque et limite l'impact potentiel d'une faille.

---

## Ne pas exécuter en root

### Pourquoi c'est important

Par défaut, les processus dans un conteneur Docker s'exécutent en tant qu'utilisateur **root** (UID 0). Si un attaquant compromet le conteneur, il dispose de privilèges élevés qui peuvent faciliter l'évasion du conteneur et l'attaque de l'hôte.

> [!warning] Risque majeur Un processus root dans un conteneur, même avec des restrictions, dispose de capacités dangereuses. Une vulnérabilité kernel ou une mauvaise configuration peut permettre l'évasion du conteneur.

### Créer un utilisateur non-privilégié

#### Dans le Dockerfile

```dockerfile
# Méthode 1 : Créer un utilisateur avec un nom
FROM ubuntu:22.04

# Créer un groupe et un utilisateur
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Créer un répertoire de travail et donner les permissions
WORKDIR /app
COPY . .
RUN chown -R appuser:appuser /app

# Basculer vers l'utilisateur non-privilégié
USER appuser

CMD ["./mon-application"]
```

```dockerfile
# Méthode 2 : Utiliser directement un UID/GID
FROM node:18-alpine

# Alpine utilise addgroup/adduser
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --chown=appuser:appgroup . .

USER appuser

CMD ["node", "server.js"]
```

```dockerfile
# Méthode 3 : Images avec utilisateur intégré
FROM node:18-alpine

# Beaucoup d'images officielles incluent déjà un utilisateur 'node'
WORKDIR /app
COPY --chown=node:node . .

USER node

CMD ["node", "server.js"]
```

#### Au runtime avec docker run

```bash
# Spécifier l'utilisateur lors de l'exécution
docker run --user 1000:1000 mon-image

# Ou avec un nom d'utilisateur (si l'utilisateur existe dans le conteneur)
docker run --user appuser mon-image

# Vérifier l'utilisateur actuel dans le conteneur
docker run mon-image whoami
docker run mon-image id
```

#### Dans Docker Compose

```yaml
version: '3.8'

services:
  app:
    image: mon-image
    user: "1000:1000"  # UID:GID
    # ou
    # user: appuser
```

### Gestion des permissions

> [!tip] Astuce Lorsque vous créez des fichiers sur l'hôte qui doivent être accessibles par le conteneur, assurez-vous que les permissions correspondent à l'UID/GID utilisé dans le conteneur.

```bash
# Sur l'hôte, créer un répertoire avec les bonnes permissions
mkdir data
sudo chown 1000:1000 data

# Monter avec les bonnes permissions
docker run -v ./data:/app/data --user 1000:1000 mon-image
```

### Cas particuliers nécessitant root

Certaines opérations nécessitent temporairement root :

```dockerfile
FROM ubuntu:22.04

# Installation de paquets (nécessite root)
RUN apt-get update && apt-get install -y python3

# Créer l'utilisateur
RUN useradd -r -m appuser

# Configurer les permissions AVANT de changer d'utilisateur
COPY --chown=appuser:appuser . /app
WORKDIR /app

# Basculer vers l'utilisateur non-privilégié pour l'exécution
USER appuser

CMD ["python3", "app.py"]
```

### Vérification et audit

```bash
# Vérifier quel utilisateur exécute un conteneur
docker exec mon-conteneur whoami

# Inspecter la configuration de l'utilisateur
docker inspect mon-conteneur | grep -i user

# Lister les processus avec leurs utilisateurs
docker exec mon-conteneur ps aux
```

> [!warning] Piège courant Ne pas oublier de donner les permissions nécessaires aux fichiers/dossiers AVANT de changer d'utilisateur avec `USER`. Sinon, l'application ne pourra pas lire/écrire ses fichiers.

---

## Images de confiance

### Comprendre la chaîne d'approvisionnement

Chaque image Docker que vous utilisez peut contenir des vulnérabilités, du code malveillant ou des backdoors. Il est essentiel de contrôler la provenance de vos images.

> [!info] Qu'est-ce qu'une image de confiance ? Une image de confiance provient d'une source vérifiée, est régulièrement mise à jour, auditée, et idéalement signée cryptographiquement.

### Sources d'images recommandées

|Source|Niveau de confiance|Cas d'usage|
|---|---|---|
|**Images officielles Docker**|⭐⭐⭐⭐⭐|Production, base pour vos images|
|**Images vérifiées**|⭐⭐⭐⭐|Éditeurs certifiés par Docker|
|**Vos propres images**|⭐⭐⭐⭐|Contrôle total sur le contenu|
|**Images communautaires populaires**|⭐⭐⭐|Développement, à auditer avant prod|
|**Images inconnues**|⭐|À éviter absolument|

### Utiliser les images officielles

```dockerfile
# ✅ BON : Image officielle
FROM node:18-alpine

# ❌ MAUVAIS : Image non officielle d'origine inconnue
FROM randomuser/node-custom
```

```bash
# Rechercher des images officielles
docker search --filter is-official=true nginx

# Vérifier les badges sur Docker Hub
# - Official Image
# - Verified Publisher
# - Docker Sponsored OSS
```

### Content Trust et signatures d'images

Docker Content Trust utilise des signatures cryptographiques pour vérifier l'intégrité et l'authenticité des images.

```bash
# Activer Docker Content Trust
export DOCKER_CONTENT_TRUST=1

# Désormais, seules les images signées peuvent être pullées
docker pull nginx:latest

# Désactiver temporairement
export DOCKER_CONTENT_TRUST=0
```

```bash
# Signer vos propres images
docker trust sign myregistry.com/myimage:tag

# Inspecter les signatures
docker trust inspect nginx:latest

# Voir les clés de signature
docker trust key load key.pem --name mon-signataire
```

> [!tip] Automatisation Dans un environnement de production, activez `DOCKER_CONTENT_TRUST=1` de façon permanente dans votre environnement pour forcer la vérification des signatures.

### Registres privés et contrôlés

```bash
# Utiliser un registre privé
docker pull registry.entreprise.com/app:1.0

# Configurer l'authentification
docker login registry.entreprise.com

# Pousser vers un registre privé
docker tag mon-app:latest registry.entreprise.com/mon-app:1.0
docker push registry.entreprise.com/mon-app:1.0
```

```yaml
# Docker Compose avec registre privé
version: '3.8'

services:
  app:
    image: registry.entreprise.com/mon-app:1.0
    # ...
```

### Vérification manuelle des images

```bash
# Inspecter une image avant utilisation
docker inspect nginx:latest

# Vérifier les couches
docker history nginx:latest

# Examiner le contenu sans exécuter
docker run --rm -it --entrypoint sh nginx:latest
```

### Politique d'images

> [!example] Exemple de politique d'entreprise
> 
> 1. **Interdire** les images de sources inconnues
> 2. **Privilégier** les images officielles ou vérifiées
> 3. **Exiger** un scan de vulnérabilités avant déploiement
> 4. **Maintenir** un registre privé d'images approuvées
> 5. **Documenter** l'origine de chaque image utilisée

```dockerfile
# Documenter l'origine dans vos Dockerfiles
# Image de base : nginx:1.25-alpine
# Source : https://hub.docker.com/_/nginx
# Dernière vérification : 2025-01-15
# Vulnérabilités connues : 0 (critique)
FROM nginx:1.25-alpine

LABEL maintainer="equipe-securite@entreprise.com"
LABEL source="nginx-officiel"
LABEL scan-date="2025-01-15"
```

### Limitations des tags

> [!warning] Piège des tags mutables Les tags comme `latest`, `stable` peuvent pointer vers différentes versions au fil du temps. Utilisez des tags de version spécifiques en production.

```dockerfile
# ❌ MAUVAIS : Tag mutable
FROM node:latest

# ✅ BON : Version spécifique avec hash
FROM node:18.19.0-alpine@sha256:abc123...

# ✅ ACCEPTABLE : Version spécifique
FROM node:18.19.0-alpine
```

---

## Scanning de vulnérabilités

### Pourquoi scanner les images

Les images Docker contiennent des systèmes d'exploitation, des bibliothèques et des dépendances qui peuvent avoir des vulnérabilités connues (CVE). Un scan détecte ces failles avant le déploiement.

> [!info] CVE Common Vulnerabilities and Exposures : système de référencement des failles de sécurité publiques. Exemple : CVE-2024-1234

### Outils de scanning

#### Docker Scout (intégré)

Docker Scout est l'outil natif de Docker pour analyser les vulnérabilités.

```bash
# Activer Docker Scout (inclus dans Docker Desktop et CLI récentes)
docker scout quickview nginx:latest

# Analyse détaillée
docker scout cves nginx:latest

# Comparer deux images
docker scout compare --to nginx:1.24 nginx:1.25

# Recommandations de mise à jour
docker scout recommendations nginx:latest
```

```bash
# Analyser une image locale
docker scout cves mon-app:latest

# Format de sortie personnalisé
docker scout cves --format json mon-app:latest > vulnerabilities.json

# Filtrer par sévérité
docker scout cves --only-severity critical,high mon-app:latest
```

#### Trivy (open source)

Trivy est un scanner de vulnérabilités très populaire et complet.

```bash
# Installation
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
# ou avec Docker
docker pull aquasec/trivy

# Scanner une image
trivy image nginx:latest

# Scanner avec sévérité minimale
trivy image --severity HIGH,CRITICAL nginx:latest

# Sortie en JSON
trivy image --format json nginx:latest

# Scanner des fichiers locaux (Dockerfile, requirements.txt, etc.)
trivy fs .

# Scanner une image locale
trivy image mon-app:latest
```

#### Autres outils populaires

```bash
# Snyk
snyk container test nginx:latest

# Clair (serveur)
# Nécessite une installation serveur séparée

# Anchore
anchore-cli image add nginx:latest
anchore-cli image vuln nginx:latest all
```

### Intégration dans le workflow

#### Dans le Dockerfile

```dockerfile
FROM node:18-alpine

# Documenter le dernier scan
LABEL scan.date="2025-01-15"
LABEL scan.tool="trivy"
LABEL scan.critical="0"
LABEL scan.high="2"

WORKDIR /app
COPY . .
RUN npm ci --only=production

USER node
CMD ["node", "server.js"]
```

#### Dans CI/CD (exemple GitHub Actions)

```yaml
# .github/workflows/docker-security.yml
name: Docker Security Scan

on: [push]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build image
        run: docker build -t mon-app:${{ github.sha }} .
      
      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: mon-app:${{ github.sha }}
          severity: 'CRITICAL,HIGH'
          exit-code: '1'  # Échec si vulnérabilités trouvées
      
      - name: Scan with Docker Scout
        run: docker scout cves mon-app:${{ github.sha }}
```

### Interpréter les résultats

Un rapport de scan typique contient :

|Élément|Description|
|---|---|
|**CVE ID**|Identifiant unique de la vulnérabilité|
|**Sévérité**|CRITICAL, HIGH, MEDIUM, LOW|
|**Package affecté**|Nom et version du package vulnérable|
|**Version corrigée**|Version qui résout la vulnérabilité|
|**Description**|Détails de la faille|

```bash
# Exemple de sortie Trivy
nginx:latest (alpine 3.18.0)

Total: 5 (CRITICAL: 1, HIGH: 2, MEDIUM: 2, LOW: 0)

┌────────────────┬────────────────┬──────────┬───────────────────┬──────────────────┐
│    Library     │ Vulnerability  │ Severity │ Installed Version │  Fixed Version   │
├────────────────┼────────────────┼──────────┼───────────────────┼──────────────────┤
│ libssl3        │ CVE-2024-1234  │ CRITICAL │ 3.0.8-r3          │ 3.0.8-r4         │
│ libcrypto3     │ CVE-2024-1234  │ CRITICAL │ 3.0.8-r3          │ 3.0.8-r4         │
│ curl           │ CVE-2024-5678  │ HIGH     │ 8.0.1-r0          │ 8.0.1-r1         │
└────────────────┴────────────────┴──────────┴───────────────────┴──────────────────┘
```

### Priorisation des vulnérabilités

> [!tip] Ordre de priorité
> 
> 1. **CRITICAL** : Corriger immédiatement, ne pas déployer
> 2. **HIGH** : Corriger avant production ou sous 7 jours
> 3. **MEDIUM** : Planifier une correction sous 30 jours
> 4. **LOW** : Corriger lors de la prochaine mise à jour majeure

### Remédiation des vulnérabilités

```dockerfile
# Avant (avec vulnérabilités)
FROM node:18.12.0-alpine

# Après (version corrigée)
FROM node:18.19.0-alpine

# Mettre à jour les packages système
RUN apk update && apk upgrade

# Mettre à jour les dépendances applicatives
COPY package*.json ./
RUN npm audit fix
RUN npm ci --only=production
```

> [!warning] Faux positifs Certaines vulnérabilités détectées peuvent ne pas s'appliquer à votre cas d'usage. Documentez les exceptions acceptées et revoyez-les régulièrement.

### Automatisation du scanning

```bash
# Script de scan automatique
#!/bin/bash
IMAGE=$1
THRESHOLD="HIGH"

echo "Scanning $IMAGE..."
trivy image --severity CRITICAL,HIGH --exit-code 1 $IMAGE

if [ $? -eq 0 ]; then
    echo "✅ No critical vulnerabilities found"
    exit 0
else
    echo "❌ Critical vulnerabilities detected"
    exit 1
fi
```

---

## Mises à jour régulières

### Pourquoi mettre à jour

Les images Docker deviennent obsolètes rapidement : de nouvelles vulnérabilités sont découvertes, des correctifs sont publiés, et les dépendances évoluent. Sans mises à jour, votre surface d'attaque augmente.

> [!warning] Dette de sécurité Chaque jour sans mise à jour augmente le risque. Les attaquants exploitent activement les CVE publiques dans les heures suivant leur divulgation.

### Stratégie de mise à jour

#### Images de base

```dockerfile
# Spécifier une version, mais mettre à jour régulièrement
FROM node:18.19-alpine  # ← Vérifier mensuellement

# Rebuild l'image régulièrement pour obtenir les derniers patchs
RUN apk update && apk upgrade
```

```bash
# Vérifier les mises à jour disponibles
docker pull node:18-alpine
docker scout compare mon-app:latest node:18-alpine

# Rebuilder avec la dernière version
docker build --no-cache -t mon-app:latest .
```

#### Dépendances système

```dockerfile
FROM ubuntu:22.04

# Mettre à jour au moment du build
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Pour Alpine
FROM alpine:3.19
RUN apk update && \
    apk upgrade && \
    rm -rf /var/cache/apk/*
```

> [!tip] Minimiser les couches Combinez `update` et `upgrade` dans une seule instruction RUN pour réduire la taille de l'image et garantir la cohérence.

#### Dépendances applicatives

```dockerfile
# Node.js
FROM node:18-alpine
COPY package*.json ./
RUN npm audit fix && \
    npm ci --only=production

# Python
FROM python:3.11-slim
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt --no-cache-dir

# Go (gestion via go.mod)
FROM golang:1.21-alpine
COPY go.mod go.sum ./
RUN go mod download && \
    go mod verify
```

### Calendrier de mise à jour

|Fréquence|Contexte|Actions|
|---|---|---|
|**Immédiat**|Vulnérabilité CRITICAL divulguée|Patch et redéploiement d'urgence|
|**Hebdomadaire**|Images de production actives|Scan automatique, alerte si HIGH+|
|**Mensuel**|Maintenance planifiée|Mise à jour des images de base et dépendances|
|**Trimestriel**|Revue de sécurité|Audit complet, migration vers nouvelles versions majeures|

### Automatisation des mises à jour

#### Dependabot (GitHub)

```yaml
# .github/dependabot.yml
version: 2
updates:
  # Mettre à jour les dépendances Docker
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10

  # Mettre à jour les dépendances npm
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
```

#### Renovate Bot

```json
// renovate.json
{
  "extends": ["config:base"],
  "dockerfile": {
    "enabled": true
  },
  "schedule": ["before 5am on monday"],
  "automerge": true,
  "automergeType": "pr",
  "vulnerabilityAlerts": {
    "enabled": true,
    "schedule": ["at any time"]
  }
}
```

#### Script personnalisé

```bash
#!/bin/bash
# update-images.sh - Script de mise à jour automatique

IMAGES=(
  "mon-app:latest"
  "mon-api:latest"
  "mon-worker:latest"
)

for IMAGE in "${IMAGES[@]}"; do
  echo "Updating $IMAGE..."
  
  # Pull la dernière version de l'image de base
  docker pull $IMAGE
  
  # Rebuild
  docker build --no-cache -t $IMAGE .
  
  # Scan
  trivy image --severity HIGH,CRITICAL $IMAGE
  
  if [ $? -eq 0 ]; then
    echo "✅ $IMAGE updated and secure"
    docker push $IMAGE
  else
    echo "❌ $IMAGE has vulnerabilities, fix before pushing"
  fi
done
```

### Gestion des versions

```dockerfile
# Utiliser des tags précis avec un système de versioning
FROM node:18.19.0-alpine3.19

# Documenter la version dans les labels
LABEL version="1.2.3"
LABEL base-image="node:18.19.0-alpine3.19"
LABEL build-date="2025-01-15"
LABEL maintainer="dev@entreprise.com"
```

```bash
# Versionner vos images
docker build -t mon-app:1.2.3 .
docker tag mon-app:1.2.3 mon-app:latest
docker push mon-app:1.2.3
docker push mon-app:latest
```

### Tests de régression après mise à jour

> [!warning] Ne jamais déployer sans tester Une mise à jour peut introduire des incompatibilités ou régressions. Testez toujours dans un environnement de staging.

```bash
# Pipeline de mise à jour sécurisé
# 1. Build avec nouvelle version
docker build -t mon-app:test .

# 2. Scan de sécurité
trivy image --severity CRITICAL,HIGH mon-app:test

# 3. Tests automatisés
docker run --rm mon-app:test npm test

# 4. Déploiement en staging
docker-compose -f docker-compose.staging.yml up -d

# 5. Tests de smoke
./run-smoke-tests.sh staging

# 6. Si OK, tag et push en production
docker tag mon-app:test mon-app:1.2.4
docker push mon-app:1.2.4
```

### Surveillance continue

```bash
# Monitorer les nouvelles vulnérabilités sur images en production
docker scout watch mon-app:latest

# Vérifier quotidiennement
docker scout cves --only-severity critical,high mon-app:production

# Alertes par email/Slack
docker scout cves mon-app:production | grep CRITICAL && \
  curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"🚨 Critical vulnerability detected in mon-app"}' \
  $SLACK_WEBHOOK_URL
```

### Documentation des mises à jour

```markdown
# Changelog - mon-app

## [1.2.4] - 2025-01-15
### Security
- Updated Node.js base image from 18.12.0 to 18.19.0
- Fixed CVE-2024-1234 (CRITICAL) in OpenSSL
- Updated npm dependencies (5 HIGH vulnerabilities)

### Changed
- Rebuilt with `--no-cache` to ensure latest patches

## [1.2.3] - 2025-01-01
### Security
- Updated Alpine Linux from 3.18 to 3.19
- Fixed CVE-2024-5678 in curl
```

> [!tip] Astuce de planification Configurez des rappels calendrier pour les revues de sécurité mensuelles. C'est plus efficace que de réagir aux alertes en urgence.

---

## 🎯 Récapitulatif

Les bonnes pratiques de sécurité Docker essentielles :

1. **Ne jamais exécuter en root** : Créer un utilisateur dédié dans vos Dockerfiles
2. **Utiliser des images de confiance** : Privilégier les images officielles et signées
3. **Scanner régulièrement** : Intégrer les scans de vulnérabilités dans votre CI/CD
4. **Mettre à jour fréquemment** : Établir un calendrier de maintenance et automatiser

> [!info] Principe fondamental La sécurité est un processus continu, pas une configuration unique. Restez vigilant et adaptez vos pratiques aux nouvelles menaces.