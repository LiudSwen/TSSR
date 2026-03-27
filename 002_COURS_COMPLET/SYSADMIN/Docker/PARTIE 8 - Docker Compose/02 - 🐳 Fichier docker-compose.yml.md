

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

## 📐 Structure YAML

### Qu'est-ce que YAML ?

YAML (YAML Ain't Markup Language) est un format de sérialisation de données lisible par l'homme. Docker Compose l'utilise pour définir l'infrastructure multi-conteneurs de manière déclarative.

> [!info] Pourquoi YAML ?
> 
> - **Lisibilité** : Syntaxe claire et épurée
> - **Hiérarchie** : L'indentation définit la structure
> - **Pas de symboles complexes** : Moins verbeux que JSON ou XML
> - **Support natif** : Parfait pour les fichiers de configuration

### Règles fondamentales de YAML

#### 1. L'indentation

```yaml
# ✅ CORRECT - Indentation cohérente (2 espaces)
services:
  web:
    image: nginx
    ports:
      - "80:80"

# ❌ INCORRECT - Mélange espaces/tabs
services:
	web:
	  image: nginx
```

> [!warning] Attention à l'indentation !
> 
> - Utilisez **toujours des espaces**, jamais de tabulations
> - Convention Docker Compose : **2 espaces** par niveau
> - L'indentation détermine la hiérarchie (comme en Python)

#### 2. Les types de données

```yaml
# Chaînes de caractères
nom: "mon-app"
nom2: 'mon-app'
nom3: mon-app  # Guillemets optionnels si pas de caractères spéciaux

# Nombres
port: 8080
version: 3.8

# Booléens
restart: true
privileged: false

# Listes (deux syntaxes)
ports:
  - "80:80"
  - "443:443"

# Ou inline
ports: ["80:80", "443:443"]

# Objets/Dictionnaires
environment:
  DB_HOST: postgres
  DB_PORT: 5432

# Multilignes
commande: |
  echo "Ligne 1"
  echo "Ligne 2"
  echo "Ligne 3"
```

#### 3. Les commentaires

```yaml
# Ceci est un commentaire sur une ligne complète

services:
  web:
    image: nginx  # Commentaire en fin de ligne
    # Commentaire pour la section suivante
    ports:
      - "80:80"
```

### Structure typique d'un docker-compose.yml

```yaml
version: '3.8'  # Version du format (optionnel depuis Compose v2)

# Définition des services (conteneurs)
services:
  service1:
    # Configuration du service 1
  service2:
    # Configuration du service 2

# Définition des réseaux personnalisés
networks:
  network1:
    # Configuration du réseau 1

# Définition des volumes nommés
volumes:
  volume1:
    # Configuration du volume 1

# Sections optionnelles
configs:
  # Configurations externes
secrets:
  # Secrets (mots de passe, clés)
```

> [!tip] Ordre des sections Bien que YAML soit flexible, il est conventionnel d'organiser le fichier dans cet ordre :
> 
> 1. `version`
> 2. `services`
> 3. `networks`
> 4. `volumes`
> 5. `configs` et `secrets` (si utilisés)

---

## 🔢 Version du format

### Qu'est-ce que la version ?

La ligne `version` indique le format du fichier docker-compose et les fonctionnalités disponibles.

```yaml
version: '3.8'
```

### Historique des versions

|Version|Date|Principales fonctionnalités|
|---|---|---|
|2.x|2016|Introduction de `depends_on`, `networks`|
|3.0|2017|Support Docker Swarm, `deploy`|
|3.4|2018|`start_period` pour healthcheck|
|3.8|2020|Dernière version 3.x, largement utilisée|

> [!info] Docker Compose v2 et la version Depuis Docker Compose v2 (2021), la ligne `version` est **optionnelle** et même déconseillée. Le parser détecte automatiquement les fonctionnalités utilisées. Cependant, elle reste utile pour :
> 
> - La compatibilité avec les anciennes versions
> - La documentation explicite du format attendu

### Quelle version choisir ?

```yaml
# Recommandation actuelle
version: '3.8'

# Ou omettez la ligne version avec Compose v2+
services:
  web:
    image: nginx
```

> [!tip] Bonne pratique
> 
> - **Projets modernes** : Omettez la ligne `version` (Compose v2)
> - **Compatibilité** : Utilisez `3.8` pour supporter les anciennes versions
> - **Production avec Swarm** : Version 3.x obligatoire pour le déploiement Swarm

---

## 🎯 Services

### Concept des services

Un **service** dans Docker Compose représente un conteneur (ou un groupe de conteneurs identiques). C'est l'élément central de votre architecture.

```yaml
services:
  mon-service:
    # Configuration du service
```

### Options principales d'un service

#### 1. Image

Spécifie l'image Docker à utiliser.

```yaml
services:
  web:
    image: nginx:1.21-alpine  # Image du Docker Hub
  
  custom:
    image: registry.example.com/mon-app:v2  # Registry privé
```

#### 2. Build

Construit une image à partir d'un Dockerfile.

```yaml
services:
  app:
    build: ./app  # Chemin simple
  
  api:
    build:
      context: ./backend  # Dossier contenant le Dockerfile
      dockerfile: Dockerfile.prod  # Nom personnalisé
      args:  # Arguments de build
        NODE_ENV: production
        VERSION: "1.0.0"
      target: production  # Stage spécifique dans un multi-stage build
```

> [!warning] Image vs Build
> 
> - Si `build` et `image` sont tous deux présents, l'image sera construite puis taguée avec le nom spécifié
> - Sans `image`, l'image construite aura un nom généré automatiquement

#### 3. Container_name

Nom personnalisé du conteneur.

```yaml
services:
  web:
    container_name: mon-nginx-web
    image: nginx
```

> [!tip] Quand utiliser container_name ?
> 
> - **Oui** : Pour faciliter le débogage et les logs
> - **Non** : Si vous prévoyez de scaler (plusieurs réplicas) - cela causerait des conflits de noms

#### 4. Ports

Expose des ports du conteneur vers l'hôte.

```yaml
services:
  web:
    image: nginx
    ports:
      - "8080:80"  # HOST:CONTAINER
      - "443:443"
      - "127.0.0.1:3000:3000"  # Bind sur localhost uniquement
      - "8081-8085:8081-8085"  # Plage de ports
```

> [!example] Format des ports
> 
> - `"HOST:CONTAINER"` : Port hôte 8080 → Port conteneur 80
> - `"IP:HOST:CONTAINER"` : Bind sur une IP spécifique
> - `"CONTAINER"` : Port assigné dynamiquement par Docker

#### 5. Environment

Variables d'environnement.

```yaml
services:
  app:
    image: node:16
    environment:
      NODE_ENV: production
      API_KEY: "abc123"
      DEBUG: "true"
  
  # Syntaxe alternative (liste)
  db:
    image: postgres:14
    environment:
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=secret
```

#### 6. Env_file

Charge les variables depuis un fichier.

```yaml
services:
  app:
    image: node:16
    env_file:
      - .env
      - .env.production
```

> [!tip] .env vs environment
> 
> - **env_file** : Pour les secrets et configurations sensibles (à gitignorer)
> - **environment** : Pour les valeurs non sensibles et la documentation

#### 7. Volumes

Monte des volumes ou des dossiers.

```yaml
services:
  web:
    image: nginx
    volumes:
      # Volume nommé
      - html-data:/usr/share/nginx/html
      
      # Bind mount (dossier hôte)
      - ./config/nginx.conf:/etc/nginx/nginx.conf:ro
      
      # Volume anonyme
      - /var/log/nginx
      
      # Syntaxe longue
      - type: bind
        source: ./app
        target: /app
        read_only: true

volumes:
  html-data:  # Déclaration du volume nommé
```

> [!info] Types de volumes
> 
> - **Volume nommé** : Géré par Docker, persistant
> - **Bind mount** : Chemin absolu ou relatif, lié au système hôte
> - **Volume anonyme** : Temporaire, supprimé avec le conteneur
> - **:ro** : Read-only (lecture seule)

#### 8. Networks

Connecte le service à des réseaux.

```yaml
services:
  web:
    image: nginx
    networks:
      - frontend
      - backend
  
  api:
    image: node:16
    networks:
      backend:
        ipv4_address: 172.25.0.100  # IP statique

networks:
  frontend:
  backend:
```

#### 9. Depends_on

Définit les dépendances entre services.

```yaml
services:
  web:
    image: nginx
    depends_on:
      - api
      - cache
  
  api:
    image: node:16
    depends_on:
      db:
        condition: service_healthy  # Attend que db soit healthy
  
  db:
    image: postgres:14
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
```

> [!warning] Depends_on ne garantit pas que le service est "prêt" `depends_on` contrôle seulement l'ordre de démarrage, pas l'état de disponibilité. Utilisez `condition: service_healthy` avec un healthcheck pour une vraie synchronisation.

#### 10. Command

Remplace la commande par défaut du conteneur.

```yaml
services:
  app:
    image: node:16
    command: npm start
  
  worker:
    image: node:16
    command: ["node", "worker.js"]  # Syntaxe tableau
  
  custom:
    image: ubuntu
    command: >
      bash -c "
      echo 'Démarrage...' &&
      sleep 10 &&
      echo 'Prêt!'
      "
```

#### 11. Restart

Politique de redémarrage du conteneur.

```yaml
services:
  web:
    image: nginx
    restart: always  # Toujours redémarrer
  
  worker:
    image: node:16
    restart: unless-stopped  # Sauf si arrêté manuellement
  
  task:
    image: alpine
    restart: on-failure  # Uniquement en cas d'erreur
    restart: on-failure:3  # Maximum 3 tentatives
```

|Valeur|Comportement|
|---|---|
|`no`|Jamais redémarrer (défaut)|
|`always`|Toujours redémarrer|
|`on-failure`|Redémarrer en cas d'erreur|
|`unless-stopped`|Toujours redémarrer sauf si arrêté manuellement|

#### 12. Healthcheck

Vérifie la santé du service.

```yaml
services:
  api:
    image: node:16
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s  # Vérification toutes les 30 secondes
      timeout: 10s  # Timeout après 10 secondes
      retries: 3  # 3 échecs avant d'être "unhealthy"
      start_period: 40s  # Période de grâce au démarrage
```

> [!tip] Bonnes pratiques healthcheck
> 
> - Créez un endpoint `/health` léger dans votre application
> - Utilisez `start_period` pour les applications avec un démarrage lent
> - Testez réellement la disponibilité du service, pas juste le processus

### Exemple complet de service

```yaml
services:
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
      args:
        NODE_ENV: production
    container_name: mon-api
    image: mon-api:latest
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://user:pass@db:5432/mydb
    env_file:
      - .env.secrets
    volumes:
      - ./uploads:/app/uploads
      - api-cache:/app/cache
    networks:
      - backend
    depends_on:
      db:
        condition: service_healthy
    command: npm start
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

---

## 🌐 Networks

### Concept des réseaux

Les **networks** permettent l'isolation et la communication entre conteneurs. Docker Compose crée automatiquement un réseau par défaut, mais vous pouvez en définir de personnalisés.

### Réseau par défaut

```yaml
services:
  web:
    image: nginx
  api:
    image: node:16
```

> [!info] Comportement par défaut Docker Compose crée automatiquement un réseau nommé `{projet}_default`. Tous les services peuvent communiquer entre eux via leur nom de service comme hostname.

```bash
# Dans le conteneur "web", vous pouvez faire :
curl http://api:3000
```

### Définir des réseaux personnalisés

```yaml
services:
  web:
    image: nginx
    networks:
      - frontend
  
  api:
    image: node:16
    networks:
      - frontend
      - backend
  
  db:
    image: postgres:14
    networks:
      - backend

networks:
  frontend:
  backend:
```

> [!example] Isolation réseau Dans cet exemple :
> 
> - `web` et `api` peuvent communiquer (frontend)
> - `api` et `db` peuvent communiquer (backend)
> - `web` et `db` **ne peuvent PAS** communiquer directement

### Options des réseaux

#### 1. Driver

Type de réseau Docker.

```yaml
networks:
  frontend:
    driver: bridge  # Défaut, pour communications locales
  
  backend:
    driver: overlay  # Pour Docker Swarm multi-hôtes
  
  none:
    driver: none  # Pas de réseau
```

|Driver|Usage|
|---|---|
|`bridge`|Réseau local (défaut)|
|`overlay`|Multi-hôtes (Swarm)|
|`host`|Partage le réseau de l'hôte|
|`none`|Pas de réseau|

#### 2. Driver_opts

Options spécifiques au driver.

```yaml
networks:
  custom:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: br-custom
      com.docker.network.bridge.enable_ip_masquerade: "true"
```

#### 3. Ipam (IP Address Management)

Configure les sous-réseaux et les IP.

```yaml
networks:
  backend:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.25.0.0/16
          gateway: 172.25.0.1
          ip_range: 172.25.1.0/24

services:
  db:
    image: postgres:14
    networks:
      backend:
        ipv4_address: 172.25.1.10  # IP statique
```

> [!warning] IP statiques Les IP statiques sont rarement nécessaires. Privilégiez les noms DNS (noms de services) pour la communication inter-conteneurs.

#### 4. Internal

Réseau isolé sans accès externe.

```yaml
networks:
  private:
    internal: true  # Pas d'accès internet
```

#### 5. External

Utilise un réseau existant créé en dehors de Compose.

```yaml
networks:
  shared-network:
    external: true
    name: mon-reseau-existant
```

> [!tip] Quand utiliser external ?
> 
> - Pour partager un réseau entre plusieurs projets docker-compose
> - Pour utiliser un réseau créé manuellement avec `docker network create`

### Exemple d'architecture réseau

```yaml
version: '3.8'

services:
  # Frontend accessible publiquement
  nginx:
    image: nginx
    ports:
      - "80:80"
    networks:
      - frontend

  # API accessible par nginx et pouvant contacter la DB
  api:
    image: node:16
    networks:
      - frontend
      - backend

  # Base de données isolée, accessible uniquement par l'API
  postgres:
    image: postgres:14
    networks:
      - backend
    environment:
      POSTGRES_PASSWORD: secret

  # Cache accessible uniquement par l'API
  redis:
    image: redis:7
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: false  # Peut accéder à internet pour updates
```

---

## 💾 Volumes

### Concept des volumes

Les **volumes** permettent de persister les données et de partager des fichiers entre l'hôte et les conteneurs, ou entre plusieurs conteneurs.

### Types de volumes

#### 1. Volumes nommés (Named volumes)

Gérés par Docker, recommandés pour la production.

```yaml
services:
  db:
    image: postgres:14
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:  # Déclaration obligatoire
```

> [!tip] Avantages des volumes nommés
> 
> - Gérés par Docker (emplacement optimal sur le disque)
> - Indépendants du système de fichiers hôte
> - Faciles à sauvegarder avec `docker volume`
> - Portables entre différents environnements

#### 2. Bind mounts

Montages directs de dossiers/fichiers de l'hôte.

```yaml
services:
  web:
    image: nginx
    volumes:
      - ./html:/usr/share/nginx/html  # Chemin relatif
      - /var/log/nginx:/var/log/nginx  # Chemin absolu
      - ./nginx.conf:/etc/nginx/nginx.conf:ro  # Lecture seule
```

> [!example] Cas d'usage des bind mounts
> 
> - **Développement** : Code source synchronisé en temps réel
> - **Configuration** : Fichiers de config spécifiques à l'environnement
> - **Logs** : Accès direct aux logs depuis l'hôte

#### 3. Volumes anonymes

Créés automatiquement, supprimés avec le conteneur.

```yaml
services:
  app:
    image: node:16
    volumes:
      - /app/node_modules  # Volume anonyme
```

### Options des volumes

#### Déclaration basique

```yaml
volumes:
  mon-volume:  # Volume par défaut (driver local)
```

#### Options avancées

```yaml
volumes:
  data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.1.100,rw
      device: ":/path/to/dir"
  
  cache:
    driver: local
    driver_opts:
      type: tmpfs
      device: tmpfs
      o: size=100m
```

#### External volumes

Utilise un volume créé en dehors de Compose.

```yaml
volumes:
  shared-data:
    external: true
    name: mon-volume-existant
```

### Syntaxe longue des volumes dans les services

```yaml
services:
  app:
    image: node:16
    volumes:
      # Syntaxe longue pour plus de contrôle
      - type: volume
        source: app-data
        target: /app/data
        read_only: false
      
      - type: bind
        source: ./config
        target: /app/config
        read_only: true
      
      - type: tmpfs
        target: /app/tmp
        tmpfs:
          size: 1000000000  # 1GB

volumes:
  app-data:
```

|Type|Description|
|---|---|
|`volume`|Volume nommé Docker|
|`bind`|Bind mount (dossier hôte)|
|`tmpfs`|Système de fichiers temporaire en mémoire|

### Permissions et propriétaires

```yaml
services:
  app:
    image: node:16
    user: "1000:1000"  # UID:GID
    volumes:
      - app-data:/app/data

volumes:
  app-data:
    driver: local
    driver_opts:
      type: none
      o: bind,uid=1000,gid=1000
      device: /data/app
```

> [!warning] Problèmes de permissions courants
> 
> - Les fichiers créés dans des volumes peuvent appartenir à root
> - Solution 1 : Utiliser `user:` dans le service
> - Solution 2 : Configurer le `driver_opts` avec uid/gid
> - Solution 3 : Modifier les permissions dans le Dockerfile

### Exemple complet avec volumes

```yaml
version: '3.8'

services:
  # Application web
  web:
    image: nginx
    volumes:
      # Config en lecture seule
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      # Contenu statique partagé
      - static-content:/usr/share/nginx/html
      # Logs accessibles depuis l'hôte
      - ./logs/nginx:/var/log/nginx
  
  # Application backend
  app:
    build: ./app
    volumes:
      # Code source pour le développement
      - ./app:/app
      # node_modules isolé (évite les conflits)
      - /app/node_modules
      # Uploads persistants
      - uploads:/app/uploads
      # Cache temporaire en mémoire
      - type: tmpfs
        target: /app/cache
  
  # Base de données
  db:
    image: postgres:14
    volumes:
      # Données persistantes
      - db-data:/var/lib/postgresql/data
      # Script d'initialisation
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    environment:
      POSTGRES_PASSWORD: secret

volumes:
  # Volume pour les données statiques partagées
  static-content:
    driver: local
  
  # Volume pour les uploads
  uploads:
    driver: local
  
  # Volume pour la base de données
  db-data:
    driver: local
```

### Gestion des volumes

> [!info] Commandes utiles
> 
> ```bash
> # Lister les volumes
> docker volume ls
> 
> # Inspecter un volume
> docker volume inspect mon-projet_db-data
> 
> # Supprimer les volumes inutilisés
> docker volume prune
> 
> # Sauvegarder un volume
> docker run --rm -v mon-volume:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz /data
> ```

---

## 🎯 Exemple complet d'un docker-compose.yml

Voici un exemple réaliste combinant tous les concepts :

```yaml
version: '3.8'

services:
  # Reverse proxy
  nginx:
    image: nginx:1.21-alpine
    container_name: frontend-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - static-files:/usr/share/nginx/html
    networks:
      - frontend
    depends_on:
      - api
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # API Backend
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
      args:
        NODE_ENV: production
    container_name: backend-api
    image: mon-api:latest
    environment:
      NODE_ENV: production
      PORT: 3000
    env_file:
      - .env.production
    volumes:
      - ./uploads:/app/uploads
      - api-logs:/app/logs
    networks:
      - frontend
      - backend
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Base de données
  db:
    image: postgres:14-alpine
    container_name: postgres-db
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
    networks:
      - backend
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Cache Redis
  redis:
    image: redis:7-alpine
    container_name: redis-cache
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    networks:
      - backend
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3

  # Worker pour tâches asynchrones
  worker:
    build:
      context: ./backend
      dockerfile: Dockerfile
    command: npm run worker
    environment:
      NODE_ENV: production
    env_file:
      - .env.production
    volumes:
      - ./uploads:/app/uploads
    networks:
      - backend
    depends_on:
      - db
      - redis
    restart: unless-stopped

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: false

volumes:
  postgres-data:
    driver: local
  redis-data:
    driver: local
  static-files:
    driver: local
  api-logs:
    driver: local
```

> [!tip] Points clés de cet exemple
> 
> - **Isolation réseau** : Frontend et backend séparés
> - **Santé des services** : Healthchecks pour toutes les dépendances critiques
> - **Persistance** : Volumes nommés pour les données importantes
> - **Configuration** : Variables d'environnement et fichiers .env
> - **Redémarrage** : Politique `unless-stopped` pour la production
> - **Dépendances** : Ordre de démarrage et conditions de santé

---

## 🔍 Pièges courants et solutions

### 1. Indentation YAML incorrecte

```yaml
# ❌ INCORRECT
services:
web:
  image: nginx

# ✅ CORRECT
services:
  web:
    image: nginx
```

### 2. Oublier de déclarer les volumes nommés

```yaml
# ❌ INCORRECT - Le volume n'est pas déclaré
services:
  db:
    volumes:
      - db-data:/var/lib/postgresql/data

# ✅ CORRECT
services:
  db:
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
```

### 3. Chemins relatifs incorrects

```yaml
# ❌ INCORRECT - Chemin depuis la racine
services:
  web:
    volumes:
      - /app/config:/etc/config  # Chemin absolu sur l'hôte

# ✅ CORRECT - Chemin relatif au docker-compose.yml
services:
  web:
    volumes:
      - ./config:/etc/config
```

### 4. Ports en conflit

```yaml
# ❌ INCORRECT - Deux services sur le même port hôte
services:
  web1:
    ports:
      - "80:80"
  web2:
    ports:
      - "80:8080"  # Conflit !

# ✅ CORRECT
services:
  web1:
    ports:
      - "80:80"
  web2:
    ports:
      - "8080:80"
```

### 5. Variables d'environnement non interpolées

```yaml
# ❌ INCORRECT - Guillemets simples empêchent l'interpolation
services:
  db:
    environment:
      - 'POSTGRES_PASSWORD=${DB_PASSWORD}'

# ✅ CORRECT - Guillemets doubles ou pas de guillemets
services:
  db:
    environment:
      - "POSTGRES_PASSWORD=${DB_PASSWORD}"
      - POSTGRES_PASSWORD=${DB_PASSWORD}
```

---

## 💡 Astuces professionnelles

### 1. Variables d'environnement dans docker-compose

Créez un fichier `.env` à côté de `docker-compose.yml` :

```bash
# .env
COMPOSE_PROJECT_NAME=monprojet
DB_PASSWORD=secret123
API_PORT=3000
```

Utilisez-les dans le compose :

```yaml
services:
  api:
    ports:
      - "${API_PORT}:3000"
  db:
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
```

### 2. Fichiers docker-compose multiples

Combinez plusieurs fichiers pour différents environnements :

```bash
# Fichier de base
docker-compose.yml

# Surcharges pour le développement
docker-compose.override.yml

# Surcharges pour la production
docker-compose.prod.yml
```

**docker-compose.yml (base)**

```yaml
services:
  api:
    build: ./backend
    environment:
      NODE_ENV: production
```

**docker-compose.override.yml (dev, chargé automatiquement)**

```yaml
services:
  api:
    volumes:
      - ./backend:/app  # Hot reload en dev
    environment:
      NODE_ENV: development
      DEBUG: "true"
```

**docker-compose.prod.yml (production)**

```yaml
services:
  api:
    image: mon-api:latest  # Image pre-build
    restart: always
    deploy:
      replicas: 3
```

```bash
# Développement (charge automatiquement override)
docker-compose up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

> [!tip] Ordre de priorité Les fichiers sont fusionnés dans l'ordre : le dernier fichier écrase les valeurs précédentes.

### 3. Validation du fichier

```bash
# Valider la syntaxe
docker-compose config

# Voir le résultat final après fusion des fichiers
docker-compose -f docker-compose.yml -f docker-compose.prod.yml config
```

### 4. Extensions YAML pour réutilisation

Utilisez les ancres YAML (`&`) et les références (`*`) pour éviter la duplication :

```yaml
# Définir un template
x-logging: &default-logging
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"

x-healthcheck: &default-healthcheck
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s

services:
  api:
    image: node:16
    logging: *default-logging  # Réutilise la config
    healthcheck:
      <<: *default-healthcheck  # Merge
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  
  worker:
    image: node:16
    logging: *default-logging
    healthcheck:
      <<: *default-healthcheck
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
```

> [!info] Préfixe x- Les clés commençant par `x-` sont ignorées par Docker Compose. C'est pratique pour définir des templates réutilisables.

### 5. Profiles pour des services optionnels

Activez certains services seulement quand nécessaire :

```yaml
services:
  # Services toujours actifs
  api:
    image: node:16
  
  db:
    image: postgres:14
  
  # Services optionnels pour le debug
  pgadmin:
    image: dpage/pgadmin4
    profiles:
      - debug
    ports:
      - "5050:80"
  
  # Services optionnels pour les tests
  test-db:
    image: postgres:14
    profiles:
      - testing
    environment:
      POSTGRES_DB: test_db
```

```bash
# Démarrer sans les services optionnels
docker-compose up

# Démarrer avec le profil debug
docker-compose --profile debug up

# Démarrer avec plusieurs profils
docker-compose --profile debug --profile testing up
```

### 6. Substitution de variables avancée

```yaml
services:
  api:
    image: node:${NODE_VERSION:-16}  # Valeur par défaut si non définie
    ports:
      - "${API_PORT:-3000}:3000"
    environment:
      # Utilise la valeur de DB_HOST ou "localhost" par défaut
      DATABASE_URL: postgresql://user:pass@${DB_HOST:-localhost}:5432/db
```

### 7. Labels pour métadonnées

Ajoutez des métadonnées à vos conteneurs :

```yaml
services:
  api:
    image: node:16
    labels:
      com.example.description: "API Backend"
      com.example.department: "Engineering"
      com.example.maintainer: "team@example.com"
      # Labels pour outils de monitoring
      prometheus.scrape: "true"
      prometheus.port: "9090"
```

### 8. Limites de ressources

```yaml
services:
  api:
    image: node:16
    deploy:
      resources:
        limits:
          cpus: '0.5'  # Maximum 50% d'un CPU
          memory: 512M  # Maximum 512 MB RAM
        reservations:
          cpus: '0.25'  # Minimum garanti
          memory: 256M
```

> [!warning] Deploy vs runtime
> 
> - La section `deploy:` est pour Docker Swarm
> - Pour Compose standalone, utilisez plutôt : `mem_limit`, `mem_reservation`, `cpus`

```yaml
services:
  api:
    image: node:16
    mem_limit: 512m
    mem_reservation: 256m
    cpus: 0.5
```

### 9. Ordre de démarrage avec scripts

Pour garantir qu'un service est vraiment prêt :

```yaml
services:
  api:
    image: node:16
    command: sh -c "
      while ! nc -z db 5432; do
        echo 'Waiting for database...';
        sleep 2;
      done;
      npm start
      "
    depends_on:
      - db
  
  db:
    image: postgres:14
```

Ou utilisez un script `wait-for-it.sh` :

```yaml
services:
  api:
    image: node:16
    volumes:
      - ./wait-for-it.sh:/wait-for-it.sh
    command: >
      sh -c "/wait-for-it.sh db:5432 --timeout=30 --strict -- npm start"
    depends_on:
      - db
```

### 10. Secrets Docker (pour Swarm)

```yaml
services:
  api:
    image: node:16
    secrets:
      - db_password
      - api_key

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    external: true  # Créé via docker secret create
```

> [!info] Secrets en développement Les secrets Docker nécessitent Swarm mode. Pour le développement local, utilisez des fichiers `.env` ou des variables d'environnement.

---

## 📚 Récapitulatif des bonnes pratiques

### Structure du fichier

1. ✅ **Indentation cohérente** : 2 espaces, pas de tabs
2. ✅ **Ordre logique** : version, services, networks, volumes
3. ✅ **Commentaires** : Expliquez les choix non évidents
4. ✅ **Nommage** : Noms explicites pour services, volumes, networks

### Services

1. ✅ **Un service = une responsabilité** : Suivez le principe UNIX
2. ✅ **Healthchecks** : Ajoutez-les pour les services critiques
3. ✅ **Restart policy** : `unless-stopped` ou `always` en production
4. ✅ **Resource limits** : Limitez CPU et mémoire en production
5. ✅ **Container_name** : Uniquement si nécessaire (pas pour scaling)

### Réseaux

1. ✅ **Isolation** : Séparez frontend/backend avec des networks distincts
2. ✅ **Noms DNS** : Utilisez les noms de services, pas d'IP statiques
3. ✅ **Internal networks** : Pour les services qui n'ont pas besoin d'internet

### Volumes

1. ✅ **Volumes nommés** : Pour les données en production
2. ✅ **Bind mounts** : Pour le développement et les configs
3. ✅ **Read-only** : Montez les configs en `:ro`
4. ✅ **Permissions** : Configurez `user:` si nécessaire
5. ✅ **Backup** : Planifiez la sauvegarde des volumes importants

### Sécurité

1. ✅ **Secrets** : Jamais dans le compose, utilisez `.env` (gitignored)
2. ✅ **User** : Évitez root dans les conteneurs
3. ✅ **Read-only rootfs** : Si possible, montez le système en lecture seule
4. ✅ **Capabilities** : Supprimez les capacités inutiles
5. ✅ **Networks** : Isolez les services sensibles

### Organisation

1. ✅ **Multi-fichiers** : Base + override + prod
2. ✅ **Variables** : Utilisez `.env` pour la configuration
3. ✅ **Extensions** : Utilisez les ancres YAML pour éviter la duplication
4. ✅ **Profiles** : Pour les services optionnels
5. ✅ **Documentation** : README expliquant la stack

---

## 🎓 Checklist avant déploiement

Avant de déployer votre `docker-compose.yml` en production :

- [ ] Validation syntaxique : `docker-compose config`
- [ ] Variables sensibles dans `.env` (gitignored)
- [ ] Healthchecks sur tous les services critiques
- [ ] Restart policy configurée (`unless-stopped` ou `always`)
- [ ] Volumes nommés pour les données persistantes
- [ ] Networks configurés avec isolation appropriée
- [ ] Limites de ressources (CPU/mémoire) définies
- [ ] Logs configurés (driver + rotation)
- [ ] Sauvegarde des volumes planifiée
- [ ] Monitoring et alertes en place
- [ ] Documentation à jour (README, commentaires)
- [ ] Tests de redémarrage et récupération

---

## 🏁 Conclusion

Le fichier `docker-compose.yml` est le cœur de votre infrastructure conteneurisée. Une bonne maîtrise de sa structure et de ses options vous permet de :

- 🚀 **Déployer rapidement** des architectures complexes
- 🔒 **Isoler et sécuriser** vos services
- 💾 **Persister les données** de manière fiable
- 🔧 **Gérer facilement** différents environnements
- 📊 **Monitorer et maintenir** vos applications

La syntaxe YAML peut sembler intimidante au début, mais avec la pratique, vous créerez des configurations propres et maintenables. N'oubliez pas : commencez simple, itérez, et ajoutez de la complexité seulement quand nécessaire.

> [!tip] Prochaine étape Maintenant que vous maîtrisez la structure du fichier, vous êtes prêt à explorer les commandes Docker Compose pour gérer vos services au quotidien.