

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

## 🎯 Introduction

La construction d'images Docker est le processus qui transforme un Dockerfile en une image utilisable. C'est l'étape qui matérialise vos instructions de configuration en un artefact réutilisable et partageable.

> [!info] Pourquoi c'est important La maîtrise du processus de build vous permet de créer des images optimisées, reproductibles et sécurisées. Comprendre les mécanismes sous-jacents vous aide à résoudre les problèmes et à améliorer les performances.

---

## 🔨 La commande docker build

### Syntaxe de base

```bash
docker build [OPTIONS] PATH | URL | -
```

La commande `docker build` lit un Dockerfile et exécute séquentiellement chaque instruction pour créer une nouvelle image.

### Utilisation simple

```bash
# Build depuis le répertoire courant
docker build .

# Build depuis un répertoire spécifique
docker build /chemin/vers/contexte

# Build depuis un fichier Dockerfile nommé différemment
docker build -f MonDockerfile.dev .
```

> [!example] Exemple complet
> 
> ```bash
> # Créer une image depuis le répertoire actuel
> docker build .
> 
> # La sortie affiche chaque étape
> [+] Building 12.3s (10/10) FINISHED
>  => [internal] load build definition from Dockerfile
>  => [internal] load .dockerignore
>  => [1/5] FROM docker.io/library/node:18
>  => [2/5] WORKDIR /app
>  => [3/5] COPY package*.json ./
>  => [4/5] RUN npm install
>  => [5/5] COPY . .
>  => exporting to image
> ```

### Options principales

|Option|Description|Exemple|
|---|---|---|
|`-t, --tag`|Nomme et tag l'image|`docker build -t monapp:1.0 .`|
|`-f, --file`|Spécifie le Dockerfile|`docker build -f Dockerfile.prod .`|
|`--no-cache`|Build sans utiliser le cache|`docker build --no-cache .`|
|`--build-arg`|Passe des variables de build|`docker build --build-arg VERSION=1.0 .`|
|`--target`|Build jusqu'à un stage spécifique|`docker build --target production .`|
|`--platform`|Spécifie la plateforme cible|`docker build --platform linux/amd64 .`|

### Le système de cache

Docker utilise un système de cache intelligent pour accélérer les builds successifs. Chaque instruction crée une couche, et si rien n'a changé, Docker réutilise la couche en cache.

```bash
# Premier build - toutes les étapes sont exécutées
docker build -t monapp .
# => Building 45.2s

# Second build sans changement - instantané
docker build -t monapp .
# => Building 0.3s (cache utilisé)
```

> [!warning] Invalidation du cache Le cache est invalidé dès qu'une instruction change ou qu'un fichier copié est modifié. Toutes les instructions suivantes seront alors ré-exécutées.

> [!tip] Optimisation du cache Placez les instructions qui changent rarement (comme l'installation de dépendances) avant celles qui changent souvent (comme la copie du code source).

### Build avec contexte distant

```bash
# Build depuis un repository Git
docker build https://github.com/user/repo.git#branch

# Build depuis une archive tar
docker build http://example.com/context.tar.gz
```

---

## 🏷️ Option -t pour le tag

### Comprendre les tags

Un tag permet d'identifier une image avec un nom lisible plutôt qu'un ID hexadécimal. Le format complet est : `registre/nom:tag`.

```bash
# Syntaxe complète
docker build -t [REGISTRE/]NOM[:TAG] .

# Exemples
docker build -t monapp .                    # Tag par défaut "latest"
docker build -t monapp:1.0 .                # Tag spécifique
docker build -t monapp:1.0.5 .              # Version sémantique
docker build -t myregistry.com/monapp:prod . # Avec registre personnalisé
```

### Bonnes pratiques de nommage

> [!tip] Convention de nommage
> 
> ```bash
> # Utiliser la version sémantique
> docker build -t monapp:1.2.3 .
> 
> # Utiliser des tags environnementaux
> docker build -t monapp:dev .
> docker build -t monapp:staging .
> docker build -t monapp:prod .
> 
> # Utiliser le commit SHA pour la traçabilité
> docker build -t monapp:sha-a3f5c21 .
> docker build -t monapp:v2.1-sha-a3f5c21 .
> ```

### Tags multiples

Vous pouvez assigner plusieurs tags à une même image lors du build :

```bash
# Assigner plusieurs tags simultanément
docker build -t monapp:1.0 -t monapp:1.0.5 -t monapp:latest .

# Utile pour versionner et maintenir un tag stable
docker build \
  -t myregistry.com/monapp:2.3.1 \
  -t myregistry.com/monapp:2.3 \
  -t myregistry.com/monapp:2 \
  -t myregistry.com/monapp:latest \
  .
```

> [!info] Le tag "latest" Si vous omettez le tag, Docker utilise automatiquement `latest`. Attention : `latest` ne signifie pas "la dernière version" mais simplement "le tag par défaut". C'est à vous de le maintenir à jour.

### Tags et registres

```bash
# Pour Docker Hub (registre par défaut)
docker build -t username/monapp:1.0 .

# Pour un registre privé
docker build -t registry.entreprise.com/equipe/monapp:1.0 .

# Pour AWS ECR
docker build -t 123456789012.dkr.ecr.eu-west-1.amazonaws.com/monapp:1.0 .

# Pour Google Container Registry
docker build -t gcr.io/project-id/monapp:1.0 .
```

> [!warning] Attention au push Le tag doit correspondre au registre de destination avant de faire un `docker push`. Utilisez `docker tag` pour renommer si nécessaire.

---

## 📦 Contexte de build

### Qu'est-ce que le contexte ?

Le contexte de build est l'ensemble des fichiers et répertoires que Docker envoie au démon Docker pour construire l'image. C'est le "." à la fin de `docker build .`

```bash
docker build -t monapp .
              ↑         ↑
           options   contexte
```

> [!info] Fonctionnement Lorsque vous lancez `docker build`, Docker :
> 
> 1. Archive tous les fichiers du contexte
> 2. Envoie cette archive au démon Docker
> 3. Utilise ces fichiers pour les instructions COPY et ADD
> 4. Ignore tout ce qui est dans `.dockerignore`

### Impact sur les performances

```bash
# ❌ Mauvais - contexte trop large (tout le disque)
docker build -t monapp /

# ❌ Mauvais - contexte avec beaucoup de fichiers inutiles
docker build -t monapp .
# Sending build context to Docker daemon  2.5GB

# ✅ Bon - contexte limité avec .dockerignore
docker build -t monapp .
# Sending build context to Docker daemon  15.2MB
```

> [!warning] Piège courant Le contexte est envoyé AVANT que le Dockerfile ne soit lu. Même si vous ne copiez qu'un seul fichier, Docker envoie tout le contexte au démon.

### Chemins dans le Dockerfile

Tous les chemins dans les instructions `COPY` et `ADD` sont relatifs à la racine du contexte :

```dockerfile
# Structure de fichiers
# projet/
# ├── Dockerfile
# ├── src/
# │   └── app.js
# └── config/
#     └── settings.json

# Dans le Dockerfile
COPY src/app.js /app/          # ✅ Relatif au contexte
COPY ./src/app.js /app/        # ✅ Identique
COPY /src/app.js /app/         # ❌ Cherche à la racine du système
COPY ../other/file.js /app/    # ❌ Impossible de sortir du contexte
```

### Contextes spéciaux

```bash
# Contexte depuis stdin avec Dockerfile
docker build -t monapp - < Dockerfile

# Contexte depuis stdin avec archive tar
docker build -t monapp - < context.tar.gz

# Contexte vide (pour images sans fichiers à copier)
docker build -t base - <<EOF
FROM alpine:latest
RUN apk add --no-cache curl
EOF
```

### Optimiser le contexte

> [!tip] Stratégies d'optimisation
> 
> ```bash
> # 1. Placer le Dockerfile à la racine du projet minimal
> projet/
> ├── Dockerfile          # ✅ À la racine du contexte nécessaire
> ├── src/
> ├── package.json
> └── node_modules/       # Exclu via .dockerignore
> 
> # 2. Utiliser un sous-répertoire comme contexte
> docker build -t monapp ./backend
> 
> # 3. Séparer les Dockerfiles par environnement
> docker build -f Dockerfile.dev -t monapp:dev ./app
> ```

### Déboguer le contexte

```bash
# Voir la taille du contexte envoyé
docker build .
# Sending build context to Docker daemon  XXX MB

# Lister ce qui est dans le contexte (astuce)
tar -czf - . | tar -tzf - | head -20

# Construire avec plus de verbosité
docker build --progress=plain .
```

---

## 🚫 Fichier .dockerignore

### Principe et utilité

Le fichier `.dockerignore` fonctionne comme `.gitignore` : il exclut des fichiers et répertoires du contexte de build, améliorant les performances et la sécurité.

> [!info] Pourquoi l'utiliser ?
> 
> - **Performance** : Réduire la taille du contexte accélère le build
> - **Sécurité** : Éviter d'inclure des secrets ou données sensibles
> - **Propreté** : Exclure les fichiers temporaires et de développement
> - **Reproductibilité** : Garantir que seuls les fichiers nécessaires sont présents

### Syntaxe de base

```plaintext
# Commentaire
fichier.txt                  # Ignore un fichier spécifique
*.log                        # Ignore tous les fichiers .log
dossier/                     # Ignore un répertoire complet
**/temp                      # Ignore "temp" à n'importe quel niveau
**/*.backup                  # Ignore tous les .backup partout

# Exception (ne pas ignorer)
!important.log               # Inclut malgré *.log ci-dessus
```

### Exemple complet pour un projet Node.js

```plaintext
# .dockerignore

# Dépendances (réinstallées dans le conteneur)
node_modules/
npm-debug.log
yarn-error.log

# Fichiers de développement
.git/
.gitignore
.env
.env.local
.vscode/
.idea/

# Tests et documentation
test/
tests/
**/*.test.js
**/*.spec.js
coverage/
docs/
*.md
!README.md                   # Exception : garder le README

# Fichiers de build et temporaires
dist/
build/
tmp/
*.tmp
.cache/

# Logs
logs/
*.log

# Fichiers système
.DS_Store
Thumbs.db

# CI/CD
.github/
.gitlab-ci.yml
Jenkinsfile

# Docker
Dockerfile*
docker-compose*.yml
.dockerignore
```

### Exemple pour un projet Python

```plaintext
# .dockerignore

# Environnement virtuel
venv/
env/
.venv/

# Bytecode Python
__pycache__/
*.py[cod]
*$py.class
*.so

# Distribution / packaging
dist/
build/
*.egg-info/

# Tests
.pytest_cache/
.coverage
htmlcov/
.tox/

# Jupyter
.ipynb_checkpoints/
*.ipynb

# Fichiers de développement
.env
.env.local
.vscode/
.idea/

# Documentation
docs/
*.md
!README.md
```

### Patterns avancés

```plaintext
# Tout ignorer sauf des exceptions spécifiques
*
!src/
!package.json
!package-lock.json

# Ignorer avec profondeur
*/temp*                      # temp1, tempo, etc. dans répertoires directs
**/logs                      # logs à tous les niveaux
**/*.log                     # Tous les .log partout

# Expressions complexes
[a-z]*.txt                   # Fichiers txt commençant par une minuscule
file?.txt                    # file1.txt, fileA.txt, etc.
```

> [!warning] Pièges courants
> 
> ```plaintext
> # ❌ Ceci ignore TOUT puis essaie d'inclure src/ - Ne marche PAS
> *
> !src/
> 
> # ✅ Solution : spécifier précisément ce qu'on ignore
> node_modules/
> dist/
> tmp/
> # ... et src/ est automatiquement inclus
> ```

### Bonnes pratiques

> [!tip] Conseils d'utilisation
> 
> ```plaintext
> # 1. Commencer par exclure largement
> *
> 
> # 2. Puis inclure ce qui est nécessaire
> !src/
> !package.json
> !package-lock.json
> 
> # 3. Toujours exclure les secrets
> .env
> .env.*
> **/*.key
> **/*.pem
> **/secrets/
> 
> # 4. Exclure les gros fichiers inutiles
> node_modules/
> **/.git/
> **/coverage/
> **/*.log
> 
> # 5. Documenter les choix non évidents
> # Ignorer les fixtures de test (trop volumineuses)
> test/fixtures/
> ```

### Tester votre .dockerignore

```bash
# Vérifier ce qui est effectivement envoyé au daemon
docker build --no-cache .

# Astuce : créer une image temporaire qui liste le contexte
echo "FROM alpine:latest
COPY . /context
RUN ls -laR /context" | docker build -f - .

# Comparer la taille avec et sans .dockerignore
# Sans .dockerignore
rm .dockerignore
docker build .
# Sending build context: 250 MB

# Avec .dockerignore
docker build .
# Sending build context: 15 MB
```

### Cas d'usage spécifiques

```plaintext
# Pour les monorepos
packages/*/node_modules/
packages/*/dist/
!packages/backend/            # Inclure uniquement backend
packages/frontend/
packages/mobile/

# Pour les builds multi-étapes (selon le stage)
# Note : .dockerignore s'applique à tout le build
# Utilisez COPY avec wildcards dans le Dockerfile pour plus de contrôle

# Pour les projets avec assets volumineux
*.mp4
*.mkv
public/videos/
!public/videos/thumbnail.jpg  # Garder seulement la miniature
```

> [!warning] Limitations
> 
> - `.dockerignore` s'applique à TOUT le build, pas par instruction
> - Impossible d'avoir des règles différentes par stage multi-étapes
> - Le fichier doit être à la racine du contexte de build
> - Les patterns sont évalués dans l'ordre (premier match gagne)

---

## 🎯 Synthèse

|Concept|Commande / Fichier|Usage principal|
|---|---|---|
|**Build de base**|`docker build .`|Construire une image depuis un Dockerfile|
|**Nommage**|`docker build -t nom:tag .`|Identifier et versionner les images|
|**Contexte**|Le chemin à la fin de la commande|Définir les fichiers disponibles pour COPY/ADD|
|**Exclusion**|`.dockerignore`|Optimiser et sécuriser le contexte|

> [!tip] Points clés à retenir
> 
> - Le contexte est envoyé en entier au démon Docker avant le build
> - Utilisez toujours `.dockerignore` pour exclure les fichiers inutiles
> - Nommez vos images avec des tags explicites et versionnés
> - Le cache Docker accélère considérablement les builds successifs
> - Placez les instructions qui changent rarement en début de Dockerfile

---

_Ce cours fait partie de la série complète sur Docker et Dockerfile_