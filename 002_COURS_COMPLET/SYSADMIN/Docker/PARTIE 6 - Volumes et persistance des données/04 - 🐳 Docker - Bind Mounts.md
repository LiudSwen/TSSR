

## 📑 Table des matières

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

## Introduction aux Bind Mounts

Les **bind mounts** sont une méthode de montage qui permet de lier directement un chemin du système de fichiers de l'hôte à un chemin dans le conteneur. Contrairement aux volumes Docker gérés, les bind mounts dépendent de la structure de répertoires de la machine hôte.

> [!info] Bind Mount vs Volume
> 
> - **Bind mount** : Pointe vers un chemin absolu sur l'hôte (`/home/user/data`)
> - **Volume** : Géré par Docker dans `/var/lib/docker/volumes/`
> 
> Les bind mounts offrent plus de contrôle mais moins de portabilité.

### Caractéristiques principales

|Aspect|Description|
|---|---|
|**Localisation**|N'importe où sur le système hôte|
|**Gestion**|Manuelle par l'utilisateur|
|**Performance**|Excellente (accès direct au système de fichiers)|
|**Portabilité**|Limitée (dépend de la structure hôte)|
|**Sécurité**|Nécessite une attention particulière|

> [!warning] Attention à la sécurité Les bind mounts donnent au conteneur un accès direct au système de fichiers de l'hôte. Un conteneur compromis pourrait potentiellement modifier des fichiers critiques du système.

---

## Montage de répertoires hôte

### Syntaxe de base

Il existe deux syntaxes principales pour créer des bind mounts :

#### 1. Syntaxe `-v` (ancienne, mais toujours utilisée)

```bash
docker run -v /chemin/hote:/chemin/conteneur image
```

#### 2. Syntaxe `--mount` (recommandée, plus explicite)

```bash
docker run --mount type=bind,source=/chemin/hote,target=/chemin/conteneur image
```

> [!tip] Syntaxe recommandée Privilégiez `--mount` pour sa clarté et ses options explicites. La syntaxe `-v` est plus courte mais moins lisible.

### Exemples pratiques

#### Monter un répertoire de code source

```bash
# Développement web - montage du code source
docker run -d \
  --name dev-web \
  --mount type=bind,source=/home/user/projet,target=/usr/share/nginx/html \
  nginx:alpine
```

```bash
# Avec la syntaxe -v (équivalent)
docker run -d \
  --name dev-web \
  -v /home/user/projet:/usr/share/nginx/html \
  nginx:alpine
```

#### Monter plusieurs répertoires

```bash
docker run -d \
  --name app \
  --mount type=bind,source=/home/user/src,target=/app/src \
  --mount type=bind,source=/home/user/config,target=/app/config \
  --mount type=bind,source=/home/user/logs,target=/app/logs \
  mon-application
```

#### Montage en lecture seule

```bash
# Avec --mount
docker run --mount type=bind,source=/home/user/config,target=/app/config,readonly nginx

# Avec -v
docker run -v /home/user/config:/app/config:ro nginx
```

> [!example] Cas d'usage : Configuration en lecture seule Montez vos fichiers de configuration en lecture seule pour empêcher le conteneur de les modifier accidentellement :
> 
> ```bash
> docker run -d \
>   --name mysql-db \
>   --mount type=bind,source=/etc/mysql/custom.cnf,target=/etc/mysql/conf.d/custom.cnf,readonly \
>   mysql:8
> ```

### Options avancées de montage

#### Propagation des montages

La propagation contrôle comment les montages sont partagés entre l'hôte et le conteneur :

```bash
docker run --mount type=bind,source=/data,target=/data,bind-propagation=shared mon-image
```

|Mode|Description|
|---|---|
|`rprivate`|Défaut. Les montages dans le conteneur ne sont pas visibles sur l'hôte|
|`private`|Similaire à rprivate|
|`rshared`|Les montages sont partagés bidirectionnellement|
|`shared`|Les sous-montages sont propagés|
|`rslave`|Le conteneur reçoit les montages de l'hôte uniquement|
|`slave`|Similaire à rslave|

> [!warning] Propagation des montages La modification de la propagation des montages est avancée et rarement nécessaire. Utilisez les valeurs par défaut sauf besoin spécifique.

#### Montage avec chemins relatifs

```bash
# Docker résout automatiquement le chemin absolu
docker run -v $(pwd)/data:/app/data mon-image

# Sur Windows PowerShell
docker run -v ${PWD}/data:/app/data mon-image
```

### Vérification des bind mounts

```bash
# Inspecter les montages d'un conteneur
docker inspect -f '{{ json .Mounts }}' nom-conteneur | jq

# Ou version lisible
docker inspect nom-conteneur | grep -A 20 "Mounts"
```

> [!tip] Astuce de débogage Utilisez `docker inspect` pour vérifier que vos bind mounts sont correctement configurés avant de déboguer l'application elle-même.

---

## Permissions et ownership

Les permissions des fichiers dans les bind mounts peuvent être sources de problèmes. Comprendre le modèle de permissions est essentiel.

### Principe de base : UID/GID

> [!info] Fonctionnement des permissions Docker ne fait **aucune traduction** des UID/GID entre l'hôte et le conteneur. Un fichier appartenant à l'UID 1000 sur l'hôte appartiendra à l'UID 1000 dans le conteneur.

#### Exemple de problème de permissions

```bash
# Sur l'hôte, vous êtes user (UID 1000)
ls -la /home/user/data
# drwxr-xr-x user user data/

# Dans le conteneur, l'application tourne en tant que www-data (UID 33)
docker run -v /home/user/data:/app/data nginx

# Le conteneur ne peut pas écrire dans /app/data !
# Car UID 33 (www-data) n'a pas les permissions d'écriture
```

### Solutions aux problèmes de permissions

#### 1. Ajuster les permissions sur l'hôte

```bash
# Donner les permissions d'écriture à tous
chmod 777 /home/user/data

# Ou plus sécurisé : donner ownership au bon UID
sudo chown -R 33:33 /home/user/data  # UID de www-data dans nginx
```

> [!warning] chmod 777 est dangereux Évitez `chmod 777` en production. Préférez ajuster l'ownership avec le bon UID/GID.

#### 2. Exécuter le conteneur avec l'utilisateur de l'hôte

```bash
# Exécuter avec votre UID/GID
docker run -u $(id -u):$(id -g) \
  -v /home/user/data:/app/data \
  mon-image
```

```bash
# Ou spécifier explicitement
docker run -u 1000:1000 \
  -v /home/user/data:/app/data \
  mon-image
```

#### 3. Créer un utilisateur dans le Dockerfile avec le bon UID

```dockerfile
FROM node:18

# Créer un utilisateur avec l'UID de l'hôte
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g ${GROUP_ID} appuser && \
    useradd -u ${USER_ID} -g appuser -m appuser

USER appuser

WORKDIR /app
```

```bash
# Build avec les bons UID/GID
docker build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) -t mon-image .

# Run sans problème de permissions
docker run -v $(pwd)/data:/app/data mon-image
```

#### 4. Utiliser des volumes intermédiaires

```bash
# Créer un volume géré par Docker
docker volume create app-data

# Copier les données de l'hôte vers le volume
docker run --rm \
  -v /home/user/data:/source:ro \
  -v app-data:/dest \
  alpine cp -a /source/. /dest/

# Utiliser le volume (permissions gérées par Docker)
docker run -v app-data:/app/data mon-image
```

### Cas spécifiques : Docker Desktop

> [!info] Docker Desktop et permissions Sur **macOS** et **Windows**, Docker Desktop utilise une VM. Les bind mounts sont automatiquement configurés avec des permissions permissives pour éviter les problèmes. Sur **Linux**, vous êtes directement sur le système hôte, donc les problèmes de permissions sont plus fréquents.

### Debugging des permissions

```bash
# Vérifier les UID/GID dans le conteneur
docker run --rm mon-image id

# Vérifier qui possède les fichiers dans le conteneur
docker run --rm -v /home/user/data:/data mon-image ls -la /data

# Vérifier quel utilisateur exécute le processus
docker exec nom-conteneur ps aux
```

> [!tip] Astuce de diagnostic Si vous rencontrez des erreurs de permissions :
> 
> 1. Vérifiez l'UID/GID des fichiers sur l'hôte : `ls -ln`
> 2. Vérifiez avec quel utilisateur tourne le conteneur : `docker exec conteneur id`
> 3. Comparez les deux et ajustez en conséquence

### Bonnes pratiques pour les permissions

```bash
# ✅ BON : Spécifier l'utilisateur explicitement
docker run -u $(id -u):$(id -g) \
  -v $(pwd):/app \
  --workdir /app \
  node:18 npm install

# ❌ MAUVAIS : Laisser le conteneur créer des fichiers en root
docker run -v $(pwd):/app node:18 npm install
# Résultat : node_modules appartient à root sur l'hôte !
```

---

## Cas d'usage

Les bind mounts excellent dans certains scénarios spécifiques où les volumes gérés ne sont pas adaptés.

### 1. Développement local

Le cas d'usage le plus courant : synchronisation du code source en temps réel.

#### Développement web (hot-reload)

```bash
# React/Vue/Angular avec hot-reload
docker run -d \
  --name frontend-dev \
  -p 3000:3000 \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/public:/app/public \
  -v /app/node_modules \  # Volume anonyme pour node_modules
  react-app npm start
```

> [!tip] Volume anonyme pour node_modules Le montage `-v /app/node_modules` crée un volume anonyme qui masque le répertoire node_modules de l'hôte. Cela évite les conflits entre les dépendances natives de l'hôte et du conteneur.

#### Développement backend avec rechargement automatique

```bash
# Python Flask avec auto-reload
docker run -d \
  --name api-dev \
  -p 5000:5000 \
  -v $(pwd):/app \
  -e FLASK_ENV=development \
  python:3.11 flask run --host=0.0.0.0
```

```bash
# Node.js avec nodemon
docker run -d \
  --name node-dev \
  -p 3000:3000 \
  -v $(pwd):/app \
  -w /app \
  node:18 npx nodemon server.js
```

#### Docker Compose pour le développement

```yaml
version: '3.8'

services:
  app:
    build: .
    volumes:
      - ./src:/app/src          # Code source
      - ./config:/app/config    # Configuration
      - /app/node_modules       # Volume anonyme
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    command: npm run dev
```

### 2. Configuration externe

Injecter des fichiers de configuration sans rebuilder l'image.

#### Configuration d'application

```bash
# Nginx avec configuration personnalisée
docker run -d \
  --name web \
  -p 80:80 \
  -v /etc/nginx/custom.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/html:/usr/share/nginx/html:ro \
  nginx:alpine
```

#### Configuration de base de données

```bash
# MySQL avec fichier de configuration personnalisé
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  -v /opt/mysql/config/my.cnf:/etc/mysql/conf.d/custom.cnf:ro \
  -v mysql-data:/var/lib/mysql \
  mysql:8
```

> [!example] Configuration multi-environnement
> 
> ```bash
> # Développement
> docker run -v ./config/dev.yml:/app/config.yml app
> 
> # Production
> docker run -v /etc/app/prod.yml:/app/config.yml app
> ```

### 3. Partage de fichiers entre conteneurs

Plusieurs conteneurs peuvent accéder au même bind mount pour partager des données.

```bash
# Conteneur 1 : génère des rapports
docker run -d \
  --name generateur \
  -v /srv/reports:/output \
  generateur-rapports

# Conteneur 2 : serveur web pour consulter les rapports
docker run -d \
  --name viewer \
  -p 8080:80 \
  -v /srv/reports:/usr/share/nginx/html:ro \
  nginx:alpine
```

#### Avec Docker Compose

```yaml
version: '3.8'

services:
  producer:
    image: producer-app
    volumes:
      - shared-data:/data
      
  consumer:
    image: consumer-app
    volumes:
      - shared-data:/input:ro
      
  viewer:
    image: nginx:alpine
    volumes:
      - shared-data:/usr/share/nginx/html:ro
    ports:
      - "8080:80"

volumes:
  shared-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /srv/shared
```

### 4. Logs et monitoring

Accéder aux logs depuis l'hôte pour analyse et archivage.

```bash
# Application qui écrit des logs
docker run -d \
  --name app \
  -v /var/log/app:/app/logs \
  mon-application

# Les logs sont accessibles directement sur l'hôte
tail -f /var/log/app/application.log
```

#### Intégration avec des outils de log

```bash
# Filebeat peut lire les logs directement
docker run -d \
  --name filebeat \
  -v /var/log/app:/logs:ro \
  -v ./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro \
  elastic/filebeat:8.0.0
```

### 5. Backup et restauration

Simplifier les backups en ayant un accès direct aux fichiers.

```bash
# Base de données avec bind mount pour les dumps
docker run -d \
  --name postgres \
  -v /backup/postgres:/backup \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:15

# Script de backup sur l'hôte
docker exec postgres pg_dump -U postgres mydb > /backup/postgres/dump_$(date +%Y%m%d).sql
```

### 6. Développement de Dockerfile

Tester rapidement des modifications sans rebuilder.

```bash
# Monter un script de démarrage pour le tester
docker run -it \
  --name test \
  -v $(pwd)/entrypoint.sh:/docker-entrypoint.sh \
  alpine sh
```

### 7. Accès à des sockets système

Communiquer avec des services via des sockets Unix.

```bash
# Accès au Docker daemon depuis un conteneur
docker run -d \
  --name portainer \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  portainer/portainer-ce

# Monitoring système
docker run -d \
  --name cadvisor \
  -v /:/rootfs:ro \
  -v /var/run:/var/run:ro \
  -v /sys:/sys:ro \
  -v /var/lib/docker/:/var/lib/docker:ro \
  google/cadvisor:latest
```

> [!warning] Sécurité avec docker.sock Monter `/var/run/docker.sock` donne au conteneur un contrôle total sur Docker. N'utilisez cela qu'avec des images de confiance.

### 8. Partage de code source entre projets

```bash
# Bibliothèque partagée entre plusieurs projets
docker run -d \
  --name projet1 \
  -v /home/dev/shared-lib:/app/lib:ro \
  -v $(pwd)/projet1:/app/src \
  projet1-image

docker run -d \
  --name projet2 \
  -v /home/dev/shared-lib:/app/lib:ro \
  -v $(pwd)/projet2:/app/src \
  projet2-image
```

### Tableau récapitulatif des cas d'usage

|Cas d'usage|Avantage|Exemple|
|---|---|---|
|**Développement**|Hot-reload, pas de rebuild|Code source en temps réel|
|**Configuration**|Modification sans rebuild|Fichiers de config externes|
|**Logs**|Accès direct depuis l'hôte|Monitoring et archivage|
|**Backup**|Simplification des sauvegardes|Dumps de BDD|
|**Partage de données**|Communication inter-conteneurs|Pipeline de traitement|
|**Testing**|Itération rapide|Test de scripts|
|**Sockets système**|Intégration système|Docker-in-Docker|

### Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> **1. Bind mount d'un répertoire inexistant**
> 
> ```bash
> # ❌ Si /opt/data n'existe pas, Docker crée un répertoire vide appartenant à root
> docker run -v /opt/data:/data app
> ```
> 
> **2. Conflits de permissions en production**
> 
> ```bash
> # ❌ Dangereux en production
> docker run -v /etc/passwd:/etc/passwd app
> ```
> 
> **3. Oublier :ro pour les montages en lecture seule**
> 
> ```bash
> # ✅ Toujours en lecture seule si pas besoin d'écrire
> docker run -v /config:/config:ro app
> ```
> 
> **4. Montage de node_modules ou vendor**
> 
> ```bash
> # ❌ Provoque des problèmes de compatibilité
> docker run -v $(pwd):/app node-app
> 
> # ✅ Exclure avec un volume anonyme
> docker run -v $(pwd):/app -v /app/node_modules node-app
> ```

### Quand NE PAS utiliser les bind mounts

Les bind mounts ne conviennent pas à tous les scénarios :

- ❌ **Données en production** → Préférez les volumes Docker
- ❌ **Portabilité multi-plateforme** → Les chemins diffèrent entre OS
- ❌ **Performance I/O intensive** → Les volumes sont optimisés
- ❌ **Isolation stricte** → Les bind mounts violent l'isolation
- ❌ **Données sensibles** → Risque d'exposition

> [!tip] Règle générale
> 
> - **Développement** : Bind mounts pour le code et la configuration
> - **Production** : Volumes Docker pour les données persistantes
> - **Configuration** : Bind mounts en lecture seule acceptables

---

## 🎯 Points clés à retenir

1. **Les bind mounts lient directement l'hôte au conteneur** - pas de gestion par Docker
2. **Utilisez `--mount` plutôt que `-v`** pour plus de clarté et d'options
3. **Les permissions sont une source majeure de problèmes** - comprenez UID/GID
4. **Parfaits pour le développement** - hot-reload et itération rapide
5. **Montez en lecture seule quand possible** - sécurité et prévention d'accidents
6. **Évitez en production** - préférez les volumes Docker pour les données critiques