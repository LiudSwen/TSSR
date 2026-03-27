

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

La sécurité réseau dans Docker repose sur un principe fondamental : **exposer uniquement ce qui est strictement nécessaire**. Une mauvaise configuration de l'exposition des ports peut transformer un conteneur isolé en porte d'entrée vers votre infrastructure.

> [!warning] Risques d'une mauvaise exposition
> 
> - Accès non autorisé aux services internes
> - Surface d'attaque augmentée
> - Exposition de services sensibles (bases de données, admin panels)
> - Possibilité d'exploitation de vulnérabilités

---

## Principe du moindre privilège

### 🎯 Concept

Le principe du moindre privilège appliqué au réseau Docker signifie que **chaque conteneur doit avoir accès uniquement aux ressources réseau dont il a strictement besoin**. Ni plus, ni moins.

### Pourquoi c'est crucial

- **Isolation renforcée** : Un conteneur compromis ne peut pas accéder aux autres services
- **Limitation des dégâts** : Réduit l'impact d'une faille de sécurité
- **Contrôle précis** : Vous savez exactement qui communique avec qui
- **Conformité** : Répond aux exigences de sécurité des audits

### 🔧 Mise en pratique

#### Séparation par réseaux

Créez des réseaux Docker dédiés pour chaque groupe de services :

```bash
# Réseau pour le frontend (accessible depuis l'extérieur)
docker network create --driver bridge frontend_network

# Réseau pour le backend (isolé)
docker network create --driver bridge backend_network

# Réseau pour la base de données (hautement isolé)
docker network create --driver bridge database_network --internal
```

> [!info] Réseau internal L'option `--internal` crée un réseau complètement isolé sans accès à Internet ni au host. Idéal pour les bases de données.

#### Connexion sélective des conteneurs

```bash
# Application web (sur frontend uniquement)
docker run -d \
  --name webapp \
  --network frontend_network \
  -p 80:80 \
  nginx:alpine

# API (sur frontend ET backend)
docker run -d \
  --name api \
  --network frontend_network \
  api:latest

# Connecter l'API au réseau backend aussi
docker network connect backend_network api

# Base de données (sur backend uniquement, non exposée)
docker run -d \
  --name database \
  --network backend_network \
  -e POSTGRES_PASSWORD=secret \
  postgres:15
```

#### Avec Docker Compose

```yaml
version: '3.8'

services:
  webapp:
    image: nginx:alpine
    networks:
      - frontend
    ports:
      - "80:80"
  
  api:
    image: api:latest
    networks:
      - frontend
      - backend
    # Pas de ports exposés vers l'extérieur
  
  database:
    image: postgres:15
    networks:
      - backend
    environment:
      POSTGRES_PASSWORD: secret
    # Base de données complètement isolée

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # Pas d'accès externe
```

### 🎨 Tableau de décision

|Service|Réseau Frontend|Réseau Backend|Réseau DB|Ports exposés|
|---|---|---|---|---|
|Reverse Proxy|✅|❌|❌|80, 443|
|Application Web|✅|✅|❌|Aucun|
|API|✅|✅|❌|Aucun|
|Service métier|❌|✅|✅|Aucun|
|Base de données|❌|❌|✅|Aucun|

> [!tip] Astuce de visualisation Utilisez `docker network inspect <network_name>` pour voir quels conteneurs sont connectés à un réseau spécifique.

### ⚠️ Pièges courants

1. **Tout mettre sur le réseau par défaut (`bridge`)**
    
    - ❌ Tous les conteneurs peuvent se parler
    - ✅ Créez des réseaux dédiés
2. **Utiliser `--network host`**
    
    - ❌ Le conteneur partage le réseau du host (dangereux)
    - ✅ Utilisez des réseaux bridge avec exposition sélective
3. **Oublier de déconnecter un conteneur d'un réseau**
    
    ```bash
    # Vérifier les connexions
    docker inspect <container_name> | grep Networks -A 10
    
    # Déconnecter si nécessaire
    docker network disconnect backend_network api
    ```
    

---

## Exposition minimale des ports

### 🎯 Concept

N'exposez **que les ports strictement nécessaires** et uniquement sur les interfaces réseau appropriées. Chaque port exposé est une porte potentielle pour les attaquants.

### Syntaxe d'exposition des ports

#### Format de base

```bash
-p [ip:]host_port:container_port[/protocol]
```

|Partie|Description|Exemple|
|---|---|---|
|`ip` (optionnel)|Interface sur laquelle écouter|`127.0.0.1`, `0.0.0.0`|
|`host_port`|Port sur la machine hôte|`8080`|
|`container_port`|Port dans le conteneur|`80`|
|`protocol` (optionnel)|TCP ou UDP|`tcp`, `udp`|

### 🔧 Bonnes pratiques d'exposition

#### 1. Exposition locale uniquement

Pour les services de développement ou d'administration :

```bash
# ❌ MAUVAIS : Accessible depuis n'importe quelle IP
docker run -d -p 5432:5432 postgres:15

# ✅ BON : Accessible uniquement depuis localhost
docker run -d -p 127.0.0.1:5432:5432 postgres:15
```

> [!warning] Attention Sans spécifier l'IP, Docker expose sur `0.0.0.0`, ce qui signifie **toutes les interfaces**, y compris celles accessibles depuis Internet !

#### 2. Ports non-standards

Utilisez des ports non-standards pour réduire les scans automatiques :

```bash
# Au lieu du port 22 standard pour SSH
docker run -d -p 127.0.0.1:2222:22 ssh-server

# Au lieu du port 3306 pour MySQL
docker run -d -p 127.0.0.1:33306:3306 mysql:8
```

#### 3. Exposition conditionnelle selon l'environnement

```yaml
# docker-compose.yml
version: '3.8'

services:
  database:
    image: postgres:15
    ports:
      # Exposé seulement en développement
      - "${DB_EXPOSE:-127.0.0.1:5432}:5432"
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}

  # Production : DB_EXPOSE non défini = pas d'exposition
  # Dev : DB_EXPOSE=127.0.0.1:5432 dans .env
```

#### 4. Aucune exposition pour les services internes

```yaml
version: '3.8'

services:
  frontend:
    image: nginx:alpine
    ports:
      - "80:80"  # Seul service exposé
    networks:
      - frontend
  
  api:
    image: api:latest
    # PAS de section ports
    # Communication interne uniquement via le réseau Docker
    networks:
      - frontend
      - backend
  
  redis:
    image: redis:alpine
    # PAS de section ports
    networks:
      - backend
```

### 📊 Comparaison des méthodes d'exposition

|Méthode|Syntaxe|Accessible depuis|Cas d'usage|
|---|---|---|---|
|Toutes interfaces|`-p 8080:80`|Internet + LAN + localhost|Services publics (avec pare-feu)|
|Localhost|`-p 127.0.0.1:8080:80`|Localhost uniquement|Dev, admin, bases de données|
|IP spécifique|`-p 192.168.1.10:8080:80`|Interface spécifique|Réseau privé uniquement|
|Pas d'exposition|(aucun `-p`)|Réseau Docker uniquement|Services internes|

### 🔍 Vérification de l'exposition

```bash
# Lister tous les ports exposés
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Vérifier les ports ouverts sur le système
sudo netstat -tulpn | grep docker

# Ou avec ss (plus moderne)
sudo ss -tulpn | grep docker

# Tester l'accessibilité depuis l'extérieur
nmap -p 1-65535 votre-ip-publique
```

> [!tip] Astuce de sécurité Configurez un pare-feu (iptables, ufw, firewalld) même si vous limitez l'exposition des ports Docker. C'est une double protection.

### ⚠️ Pièges courants

1. **Oublier que 0.0.0.0 expose sur Internet**
    
    ```bash
    # ❌ Si votre serveur a une IP publique, ceci est dangereux !
    docker run -p 3306:3306 mysql
    
    # ✅ Toujours spécifier localhost pour les services sensibles
    docker run -p 127.0.0.1:3306:3306 mysql
    ```
    
2. **Exposer les ports de monitoring/metrics publiquement**
    
    ```bash
    # ❌ Metrics exposées publiquement
    docker run -p 9090:9090 prometheus
    
    # ✅ Metrics accessibles uniquement localement
    docker run -p 127.0.0.1:9090:9090 prometheus
    ```
    
3. **Ne pas documenter les ports exposés**
    
    ```yaml
    # ✅ Documentez chaque port exposé
    services:
      app:
        ports:
          - "80:8080"     # HTTP public
          - "127.0.0.1:9229:9229"  # Node.js debugger (dev only)
    ```
    

---

## Utilisation de reverse proxy

### 🎯 Concept

Un reverse proxy agit comme **point d'entrée unique** pour tous vos services Docker. Au lieu d'exposer chaque conteneur directement, vous exposez uniquement le reverse proxy qui route les requêtes vers les bons conteneurs.

### Pourquoi utiliser un reverse proxy

|Avantage|Explication|
|---|---|
|**🔒 Sécurité**|Un seul point d'exposition à sécuriser|
|**🔐 SSL/TLS centralisé**|Gestion des certificats à un seul endroit|
|**🌐 Routage par domaine**|`api.example.com` → API, `app.example.com` → Frontend|
|**⚖️ Load balancing**|Distribution de charge entre plusieurs instances|
|**🛡️ Protection**|Rate limiting, filtrage, WAF|
|**📊 Logging centralisé**|Tous les accès logs au même endroit|

### 🔧 Architecture recommandée

```
Internet
   ↓
[Reverse Proxy] ← Seul conteneur exposé sur 80/443
   ↓
[Réseau Docker interne]
   ├── Conteneur App 1 (non exposé)
   ├── Conteneur App 2 (non exposé)
   └── Conteneur API (non exposé)
```

### Solutions populaires

#### 1. Nginx (manuel mais flexible)

**Structure de base :**

```yaml
# docker-compose.yml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    networks:
      - frontend
    depends_on:
      - webapp
      - api

  webapp:
    image: webapp:latest
    # Aucun port exposé à l'extérieur
    networks:
      - frontend

  api:
    image: api:latest
    # Aucun port exposé à l'extérieur
    networks:
      - frontend
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

**Configuration Nginx :**

```nginx
# nginx.conf
http {
    # Configuration de base
    upstream webapp_backend {
        server webapp:3000;  # Nom du service Docker
    }
    
    upstream api_backend {
        server api:8080;
    }

    # Redirection HTTP → HTTPS
    server {
        listen 80;
        server_name example.com www.example.com;
        return 301 https://$server_name$request_uri;
    }

    # Application web
    server {
        listen 443 ssl http2;
        server_name example.com www.example.com;
        
        ssl_certificate /etc/nginx/certs/fullchain.pem;
        ssl_certificate_key /etc/nginx/certs/privkey.pem;
        
        # Sécurité SSL
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
        
        location / {
            proxy_pass http://webapp_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # API
    server {
        listen 443 ssl http2;
        server_name api.example.com;
        
        ssl_certificate /etc/nginx/certs/fullchain.pem;
        ssl_certificate_key /etc/nginx/certs/privkey.pem;
        
        location / {
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            
            # Rate limiting
            limit_req zone=api burst=20 nodelay;
        }
    }
    
    # Zone de rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
}
```

> [!tip] Headers importants
> 
> - `X-Real-IP` : IP réelle du client
> - `X-Forwarded-For` : Chaîne des proxies traversés
> - `X-Forwarded-Proto` : Protocole original (http/https)

#### 2. Traefik (automatique et moderne)

Traefik découvre automatiquement vos conteneurs via des labels Docker.

```yaml
# docker-compose.yml
version: '3.8'

services:
  traefik:
    image: traefik:v2.11
    command:
      - "--api.insecure=false"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.email=admin@example.com"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik-certs:/letsencrypt
    networks:
      - frontend

  webapp:
    image: webapp:latest
    labels:
      # Activer Traefik pour ce service
      - "traefik.enable=true"
      # Définir le domaine
      - "traefik.http.routers.webapp.rule=Host(`example.com`)"
      # Utiliser HTTPS
      - "traefik.http.routers.webapp.entrypoints=websecure"
      # Certificat Let's Encrypt automatique
      - "traefik.http.routers.webapp.tls.certresolver=letsencrypt"
      # Port du conteneur (si différent de 80)
      - "traefik.http.services.webapp.loadbalancer.server.port=3000"
    networks:
      - frontend

  api:
    image: api:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`api.example.com`)"
      - "traefik.http.routers.api.entrypoints=websecure"
      - "traefik.http.routers.api.tls.certresolver=letsencrypt"
      # Middleware de rate limiting
      - "traefik.http.middlewares.api-ratelimit.ratelimit.average=100"
      - "traefik.http.middlewares.api-ratelimit.ratelimit.burst=50"
      - "traefik.http.routers.api.middlewares=api-ratelimit"
      - "traefik.http.services.api.loadbalancer.server.port=8080"
    networks:
      - frontend
      - backend

volumes:
  traefik-certs:

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

> [!info] Avantages de Traefik
> 
> - **Auto-découverte** : Détecte automatiquement les nouveaux conteneurs
> - **Let's Encrypt intégré** : Certificats SSL/TLS automatiques et gratuits
> - **Dashboard** : Interface web de monitoring
> - **Configuration par labels** : Pas de fichier de config à modifier

#### 3. Caddy (le plus simple)

Caddy gère automatiquement HTTPS avec Let's Encrypt, sans configuration.

```yaml
# docker-compose.yml
version: '3.8'

services:
  caddy:
    image: caddy:2-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy-data:/data
      - caddy-config:/config
    networks:
      - frontend

  webapp:
    image: webapp:latest
    networks:
      - frontend

  api:
    image: api:latest
    networks:
      - frontend

volumes:
  caddy-data:
  caddy-config:

networks:
  frontend:
    driver: bridge
```

**Caddyfile (configuration) :**

```caddyfile
# HTTPS automatique pour example.com
example.com {
    # Reverse proxy vers le conteneur webapp
    reverse_proxy webapp:3000
    
    # Headers de sécurité
    header {
        Strict-Transport-Security "max-age=31536000;"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
    }
}

# API avec rate limiting
api.example.com {
    reverse_proxy api:8080
    
    # Rate limiting : 100 requêtes par minute
    rate_limit {
        zone api_zone {
            key {remote_host}
            events 100
            window 1m
        }
    }
}
```

> [!tip] Pourquoi choisir Caddy ?
> 
> - Configuration ultra-simple
> - HTTPS automatique sans configuration
> - Syntaxe très lisible
> - Parfait pour débuter ou pour des projets simples

### 🎨 Comparaison des solutions

|Critère|Nginx|Traefik|Caddy|
|---|---|---|---|
|**Complexité**|⭐⭐⭐|⭐⭐|⭐|
|**Flexibilité**|⭐⭐⭐|⭐⭐⭐|⭐⭐|
|**Auto-configuration**|❌|✅|✅|
|**Let's Encrypt auto**|❌ (certbot requis)|✅|✅|
|**Performance**|⭐⭐⭐|⭐⭐|⭐⭐|
|**Dashboard**|❌ (tiers requis)|✅|❌|
|**Load balancing**|✅|✅|✅|
|**Cas d'usage**|Production complexe|Orchestration Docker|Projets simples/moyens|

### 🔐 Sécurité avancée avec reverse proxy

#### Headers de sécurité à ajouter

```nginx
# Nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'" always;
```

```yaml
# Traefik (labels)
- "traefik.http.middlewares.security-headers.headers.stsSeconds=31536000"
- "traefik.http.middlewares.security-headers.headers.framedeny=true"
- "traefik.http.middlewares.security-headers.headers.contentTypeNosniff=true"
- "traefik.http.middlewares.security-headers.headers.browserXssFilter=true"
- "traefik.http.routers.webapp.middlewares=security-headers"
```

#### Rate limiting et protection DDoS

```nginx
# Nginx - dans le bloc http
limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
limit_conn_zone $binary_remote_addr zone=addr:10m;

server {
    # Limiter le nombre de requêtes par seconde
    limit_req zone=general burst=20 nodelay;
    # Limiter le nombre de connexions simultanées
    limit_conn addr 10;
}
```

```yaml
# Traefik
- "traefik.http.middlewares.rate-limit.ratelimit.average=100"
- "traefik.http.middlewares.rate-limit.ratelimit.period=1m"
- "traefik.http.middlewares.rate-limit.ratelimit.burst=50"
```

### ⚠️ Pièges courants

1. **Oublier les headers X-Forwarded**
    
    ```nginx
    # ❌ L'application backend voit l'IP du proxy, pas du client
    proxy_pass http://backend;
    
    # ✅ L'application reçoit les bonnes informations
    proxy_pass http://backend;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    ```
    
2. **Exposer à la fois le proxy ET les conteneurs**
    
    ```yaml
    # ❌ MAUVAIS : Les deux sont exposés !
    services:
      nginx:
        ports: ["80:80"]
      webapp:
        ports: ["3000:3000"]  # À SUPPRIMER !
    
    # ✅ BON : Seul le proxy est exposé
    services:
      nginx:
        ports: ["80:80"]
      webapp:
        # Pas de section ports
    ```
    
3. **Ne pas sécuriser le dashboard Traefik**
    
    ```yaml
    # ❌ Dashboard accessible publiquement
    command:
      - "--api.insecure=true"
    
    # ✅ Dashboard protégé par authentification
    command:
      - "--api.dashboard=true"
      - "--api.insecure=false"
    labels:
      - "traefik.http.routers.dashboard.rule=Host(`traefik.example.com`)"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.middlewares=auth"
      - "traefik.http.middlewares.auth.basicauth.users=admin:$$apr1$$..."
    ```
    

### 🎯 Checklist de mise en production

- [ ] Seul le reverse proxy expose des ports (80, 443)
- [ ] Tous les services backend sont sur un réseau interne
- [ ] HTTPS activé avec certificats valides
- [ ] Headers de sécurité configurés
- [ ] Rate limiting en place
- [ ] Logs centralisés et surveillés
- [ ] Timeouts configurés correctement
- [ ] Redirection HTTP → HTTPS active
- [ ] Pas d'exposition de dashboard admin non protégé

---

## 🎓 Résumé des bonnes pratiques

> [!tip] Points clés à retenir
> 
> 1. **Réseaux isolés** : Séparez vos services par fonction (frontend, backend, database)
> 2. **Exposition minimale** : N'exposez que ce qui doit l'être, et sur localhost quand possible
> 3. **Reverse proxy obligatoire** : Un seul point d'entrée, SSL/TLS centralisé, sécurité renforcée
> 4. **Surveillance** : Auditez régulièrement vos ports exposés avec `docker ps` et `netstat`
> 5. **Defence en profondeur** : Combine réseau Docker + firewall + reverse proxy + rate limiting

> [!warning] Erreurs à éviter absolument
> 
> - ❌ Exposer des bases de données sur `0.0.0.0`
> - ❌ Utiliser `--network host` en production
> - ❌ Exposer des dashboards d'administration sans authentification
> - ❌ Oublier de configurer les headers de sécurité
> - ❌ Ne pas utiliser HTTPS (même en interne)