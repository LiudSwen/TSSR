

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

## 🔍 Recherche d'images Docker

La recherche d'images Docker est une étape essentielle avant de déployer des conteneurs. Elle vous permet de trouver des images officielles, communautaires ou d'évaluer leur qualité avant utilisation.

### Docker Hub

> [!info] Qu'est-ce que Docker Hub ? Docker Hub est le registre public officiel de Docker. C'est une plateforme cloud qui permet de stocker, partager et distribuer des images de conteneurs. Il contient des millions d'images publiques et privées.

#### Caractéristiques principales

**🌟 Types d'images disponibles :**

|Type|Description|Indicateur|
|---|---|---|
|**Images officielles**|Maintenues par Docker Inc. et les éditeurs officiels|Badge "Official Image"|
|**Images vérifiées**|Publiées par des éditeurs de confiance vérifiés|Badge "Verified Publisher"|
|**Images communautaires**|Créées et maintenues par la communauté|Aucun badge particulier|

> [!warning] Sécurité et confiance Privilégiez toujours les images officielles ou vérifiées pour des raisons de sécurité. Les images communautaires peuvent contenir des vulnérabilités ou du code malveillant.

#### Navigation sur Docker Hub

**URL principale :** https://hub.docker.com

**Informations disponibles pour chaque image :**

- **Description et documentation** : Usage prévu, configuration
- **Tags disponibles** : Différentes versions et variantes
- **Nombre de téléchargements** : Indicateur de popularité
- **Date de dernière mise à jour** : Maintenance active
- **Dockerfile** : Transparence sur la construction
- **Vulnérabilités connues** : Scan de sécurité automatique

> [!example] Exemple d'images officielles populaires
> 
> - `nginx` : Serveur web et reverse proxy
> - `postgres` : Base de données relationnelle
> - `node` : Runtime JavaScript
> - `python` : Interpréteur Python
> - `redis` : Base de données en mémoire

#### Filtres et recherche avancée

Sur Docker Hub, vous pouvez filtrer par :

- **Type d'image** : Official, Verified, Community
- **Système d'exploitation** : Linux, Windows
- **Architecture** : amd64, arm64, etc.

---

### Commande docker search

> [!info] Pourquoi utiliser `docker search` ? Cette commande permet de rechercher des images directement depuis le terminal, sans ouvrir un navigateur. Pratique pour les scripts et l'automatisation.

#### Syntaxe de base

```bash
docker search [OPTIONS] TERM
```

#### Recherche simple

```bash
# Rechercher une image nginx
docker search nginx

# Résultat typique :
# NAME                     DESCRIPTION                        STARS     OFFICIAL
# nginx                    Official build of Nginx            19000     [OK]
# nginxinc/nginx-unprivileged   Unprivileged NGINX image     500       
# bitnami/nginx            Bitnami nginx Docker Image         200
```

**Colonnes du résultat :**

|Colonne|Description|
|---|---|
|**NAME**|Nom complet de l'image (namespace/nom)|
|**DESCRIPTION**|Description courte de l'image|
|**STARS**|Nombre d'étoiles (popularité)|
|**OFFICIAL**|`[OK]` si image officielle|
|**AUTOMATED**|Si build automatisé (obsolète)|

#### Options principales

```bash
# Limiter le nombre de résultats (par défaut : 25)
docker search --limit 5 python

# Filtrer uniquement les images officielles
docker search --filter "is-official=true" ubuntu

# Filtrer par nombre minimum d'étoiles
docker search --filter "stars=100" postgres

# Format personnalisé de sortie
docker search --format "table {{.Name}}\t{{.StarCount}}\t{{.IsOfficial}}" redis

# Combinaison de filtres
docker search --filter "is-official=true" --filter "stars=1000" nginx
```

> [!tip] Astuce : Format de sortie personnalisé Utilisez `--format` avec les templates Go pour créer des sorties adaptées à vos besoins :
> 
> ```bash
> docker search --format "{{.Name}} (⭐ {{.StarCount}})" alpine
> ```

#### Limitations de docker search

> [!warning] Limitations importantes
> 
> - Affiche maximum 25 résultats par défaut
> - Ne montre pas les tags disponibles
> - Informations limitées comparé à Docker Hub
> - Ne peut pas rechercher dans les registres privés sans configuration

**Alternative pour plus de détails :**

```bash
# Pour voir les tags, utilisez l'API Docker Hub ou le site web
curl -s "https://registry.hub.docker.com/v2/repositories/library/nginx/tags/" | jq '.results[].name'
```

---

### Tags et versions

> [!info] Qu'est-ce qu'un tag Docker ? Un tag est un label associé à une image Docker qui permet d'identifier une version ou variante spécifique. C'est comme un numéro de version pour les images.

#### Syntaxe des tags

```bash
# Format complet d'une référence d'image
[REGISTRY/]NAMESPACE/IMAGE_NAME[:TAG]

# Exemples
docker.io/library/nginx:latest           # Image officielle, tag latest
docker.io/user/myapp:v1.2.3              # Image utilisateur avec version
ghcr.io/company/service:production       # GitHub Container Registry
```

> [!tip] Tag par défaut Si vous omettez le tag, Docker utilise automatiquement `:latest`
> 
> ```bash
> docker pull nginx        # équivaut à nginx:latest
> ```

#### Types de tags courants

**1. Tags de version sémantique**

```bash
# Version complète
nginx:1.25.3

# Version majeure et mineure
nginx:1.25

# Version majeure uniquement
nginx:1

# Latest (dernière version stable)
nginx:latest
```

> [!warning] Attention avec `latest` Le tag `latest` ne signifie pas toujours "la dernière version". C'est simplement le tag par défaut. Une image peut être mise à jour sans que `latest` soit modifié.

**2. Tags de variantes**

```bash
# Variantes de système d'exploitation
python:3.12-slim          # Version minimale
python:3.12-alpine        # Basée sur Alpine Linux (très légère)
python:3.12-bookworm      # Basée sur Debian Bookworm
python:3.12-bullseye      # Basée sur Debian Bullseye

# Variantes fonctionnelles
node:20-alpine            # Node.js sur Alpine
node:20-slim              # Version réduite
postgres:16-alpine        # PostgreSQL sur Alpine
```

**Comparaison des tailles :**

|Variante|Taille typique|Usage recommandé|
|---|---|---|
|**Standard**|500MB - 1GB|Développement, tous les outils|
|**Slim**|100MB - 300MB|Production, outils essentiels|
|**Alpine**|10MB - 100MB|Production optimisée, contraintes de taille|

> [!example] Exemple : Images Python
> 
> ```bash
> # Image complète avec tous les outils
> python:3.12              # ~1GB
> 
> # Version slim (sans outils de compilation)
> python:3.12-slim         # ~150MB
> 
> # Version Alpine (ultra-légère)
> python:3.12-alpine       # ~50MB
> ```

#### Bonnes pratiques pour les tags

> [!tip] Règles d'or pour les tags
> 
> 1. **Ne jamais utiliser `latest` en production** : Privilégiez des versions spécifiques
> 2. **Utiliser des versions complètes** : `nginx:1.25.3` plutôt que `nginx:1`
> 3. **Documenter les variantes** : Expliquez pourquoi vous utilisez `alpine` ou `slim`
> 4. **Tester les mises à jour** : Avant de changer de version en production

```bash
# ❌ Mauvaise pratique : Tag implicite
FROM nginx

# ❌ Mauvaise pratique : Tag latest explicite
FROM nginx:latest

# ✅ Bonne pratique : Version spécifique
FROM nginx:1.25.3-alpine

# ✅ Très bonne pratique : Version + hash (immutable)
FROM nginx:1.25.3-alpine@sha256:abc123...
```

#### Consulter les tags disponibles

**Méthode 1 : Via Docker Hub**

- Visitez la page de l'image sur hub.docker.com
- Onglet "Tags" pour voir toutes les versions

**Méthode 2 : Via l'API Docker Hub**

```bash
# Lister les tags d'une image officielle
curl -s "https://registry.hub.docker.com/v2/repositories/library/nginx/tags/" | jq -r '.results[].name'

# Avec pagination pour voir plus de résultats
curl -s "https://registry.hub.docker.com/v2/repositories/library/nginx/tags/?page_size=100" | jq -r '.results[].name'
```

**Méthode 3 : Outils tiers**

```bash
# Avec l'outil regctl (registration client)
regctl tag ls nginx

# Avec skopeo
skopeo list-tags docker://nginx
```

#### Stratégies de tagging pour vos images

> [!example] Stratégies de versioning **Pour vos propres images, utilisez plusieurs tags :**
> 
> ```bash
> # Tag avec version complète (immutable)
> myapp:1.2.3
> 
> # Tag avec version majeure.mineure (rolling)
> myapp:1.2
> 
> # Tag avec version majeure (rolling)
> myapp:1
> 
> # Tag d'environnement
> myapp:production
> myapp:staging
> myapp:dev
> 
> # Tag de commit Git
> myapp:sha-abc1234
> ```

#### Multi-architecture et tags

> [!info] Images multi-architecture Les images modernes supportent plusieurs architectures processeur (amd64, arm64, etc.). Un même tag peut pointer vers différentes variantes selon votre plateforme.

```bash
# Docker sélectionne automatiquement la bonne architecture
docker pull nginx:1.25.3

# Forcer une architecture spécifique
docker pull --platform linux/amd64 nginx:1.25.3
docker pull --platform linux/arm64 nginx:1.25.3

# Voir les architectures disponibles
docker manifest inspect nginx:1.25.3 | jq '.manifests[].platform'
```

> [!tip] Astuce : Manifests Les manifests permettent à un seul tag de pointer vers plusieurs variantes d'images (différentes architectures ou OS). Docker choisit automatiquement la bonne version selon votre système.

---

## 🎯 Pièges courants

> [!warning] Erreurs fréquentes à éviter

**1. Utiliser `latest` en production**

```bash
# ❌ Risque : L'image peut changer sans prévenir
docker run nginx:latest

# ✅ Solution : Utiliser une version fixe
docker run nginx:1.25.3-alpine
```

**2. Ignorer les différences entre variantes**

```bash
# ❌ Alpine utilise musl au lieu de glibc
# Certaines applications peuvent ne pas fonctionner
FROM python:3.12-alpine

# ✅ Tester d'abord, ou utiliser slim si problème
FROM python:3.12-slim
```

**3. Ne pas vérifier la date de dernière mise à jour**

- Une image non maintenue peut contenir des vulnérabilités
- Vérifiez toujours sur Docker Hub la dernière mise à jour

**4. Faire confiance aux images communautaires sans vérification**

```bash
# ❌ Image inconnue sans audit
docker pull unknownuser/suspicious-app

# ✅ Privilégier les images officielles
docker pull nginx
```

---

## 💡 Astuces pratiques

### Recherche efficace

```bash
# Combiner plusieurs critères
docker search --filter "is-official=true" --filter "stars=1000" --limit 10 python

# Rechercher et trier par popularité
docker search redis --format "table {{.Name}}\t{{.StarCount}}" | sort -k2 -rn
```

### Vérification rapide d'une image

```bash
# Voir les détails d'un tag spécifique
docker pull nginx:1.25.3
docker image inspect nginx:1.25.3

# Voir l'historique de construction
docker history nginx:1.25.3

# Vérifier la taille
docker images nginx:1.25.3
```

### Alias utiles

```bash
# Ajouter à votre ~/.bashrc ou ~/.zshrc

# Recherche rapide avec détails
alias ds='docker search --format "table {{.Name}}\t{{.StarCount}}\t{{.IsOfficial}}"'

# Lister les tags via API
dstags() {
    curl -s "https://registry.hub.docker.com/v2/repositories/library/$1/tags/" | jq -r '.results[].name'
}

# Usage : dstags nginx
```

### Automatisation de la sélection d'image

```bash
# Script pour choisir la meilleure variante
#!/bin/bash
IMAGE=$1
VERSION=$2

# Vérifier si Alpine fonctionne pour votre cas
if docker run --rm ${IMAGE}:${VERSION}-alpine sh -c "exit 0" 2>/dev/null; then
    echo "Using Alpine variant"
    TAG="${VERSION}-alpine"
else
    echo "Using Slim variant"
    TAG="${VERSION}-slim"
fi

docker pull ${IMAGE}:${TAG}
```

---

## 📊 Récapitulatif

|Méthode|Avantages|Inconvénients|
|---|---|---|
|**Docker Hub (web)**|Interface riche, documentation complète|Nécessite un navigateur|
|**docker search**|Rapide, scriptable, disponible partout|Informations limitées, pas de tags|
|**API Docker Hub**|Programmable, accès aux tags|Nécessite des outils (curl, jq)|

**Points clés à retenir :**

- ✅ Privilégiez les images officielles et vérifiées
- ✅ Utilisez toujours des tags de version spécifiques en production
- ✅ Choisissez la variante adaptée à votre besoin (standard/slim/alpine)
- ✅ Vérifiez la date de dernière mise à jour et le nombre d'étoiles
- ✅ Testez les images avant de les déployer en production