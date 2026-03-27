

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

L'exposition des ports est un mécanisme fondamental de Docker qui permet de rendre les services s'exécutant dans un conteneur accessibles depuis l'extérieur. Par défaut, les conteneurs Docker sont isolés du réseau de l'hôte, et leurs ports ne sont pas accessibles. L'exposition des ports crée un pont entre le réseau de l'hôte et le réseau interne du conteneur.

> [!info] Pourquoi exposer des ports ?
> 
> - Permettre l'accès aux applications web depuis un navigateur
> - Connecter des clients externes à des bases de données
> - Exposer des APIs REST ou GraphQL
> - Permettre la communication entre conteneurs et l'hôte

---

## Option -p / --publish

L'option `-p` (ou `--publish`) est la méthode la plus courante et la plus précise pour exposer des ports. Elle permet de mapper manuellement un port de l'hôte vers un port du conteneur.

### Syntaxe de base

```bash
docker run -p [IP_HOTE:]PORT_HOTE:PORT_CONTENEUR[/PROTOCOLE] IMAGE
```

### Cas d'usage courants

#### 1. Mapping simple (le plus fréquent)

```bash
# Mapper le port 8080 de l'hôte vers le port 80 du conteneur
docker run -p 8080:80 nginx

# L'application nginx est maintenant accessible sur http://localhost:8080
```

> [!example] Exemple concret
> 
> ```bash
> # Lancer un serveur web sur le port 3000 de l'hôte
> docker run -p 3000:80 nginx
> 
> # Accès : http://localhost:3000
> ```

#### 2. Mapper sur une IP spécifique

```bash
# Exposer uniquement sur l'interface localhost
docker run -p 127.0.0.1:8080:80 nginx

# Exposer sur une IP spécifique (utile pour machines multi-interfaces)
docker run -p 192.168.1.100:8080:80 nginx
```

> [!tip] Astuce sécurité Utiliser `127.0.0.1` limite l'accès au conteneur à la machine hôte uniquement, empêchant les connexions externes.

#### 3. Spécifier le protocole

```bash
# TCP (par défaut, peut être omis)
docker run -p 8080:80/tcp nginx

# UDP (nécessaire pour certains services comme DNS, VPN)
docker run -p 53:53/udp dns-server

# Les deux protocoles simultanément
docker run -p 8080:80/tcp -p 8080:80/udp mon-app
```

#### 4. Expositions multiples

```bash
# Exposer plusieurs ports du même conteneur
docker run -p 80:80 -p 443:443 nginx

# Utile pour HTTP et HTTPS simultanément
docker run \
  -p 8080:80 \
  -p 8443:443 \
  -p 9090:9090 \
  mon-application
```

> [!example] Cas réel - Application web complète
> 
> ```bash
> docker run -d \
>   --name mon-app \
>   -p 3000:3000 \    # Frontend React
>   -p 5000:5000 \    # Backend API
>   -p 5432:5432 \    # PostgreSQL
>   mon-app-fullstack
> ```

---

## Mapping de ports

Le mapping de ports est le processus de création d'une correspondance entre un port de l'hôte et un port du conteneur. Comprendre les différentes stratégies de mapping est essentiel pour une architecture réseau efficace.

### Types de mapping

#### 1. Mapping statique (port fixe)

Le port de l'hôte est explicitement défini.

```bash
# Le port 8080 de l'hôte sera TOUJOURS mappé
docker run -p 8080:80 nginx
```

**Avantages :**

- Prévisibilité : vous savez toujours où accéder au service
- Facilite la documentation et la configuration

**Inconvénients :**

- Conflit si le port est déjà utilisé
- Limite le nombre de conteneurs identiques

#### 2. Mapping dynamique (port aléatoire)

Docker choisit automatiquement un port disponible sur l'hôte.

```bash
# Docker attribue un port aléatoire de l'hôte vers le port 80 du conteneur
docker run -p 80 nginx

# Découvrir le port attribué
docker port <CONTAINER_ID> 80
# Sortie exemple : 0.0.0.0:32768
```

> [!tip] Quand utiliser le mapping dynamique ?
> 
> - Environnements de développement avec de nombreux conteneurs
> - Tests automatisés parallèles
> - Quand seule la communication inter-conteneurs importe

#### 3. Mapping sur toutes les interfaces

```bash
# Accessible depuis n'importe quelle IP de l'hôte
docker run -p 8080:80 nginx

# Équivalent à
docker run -p 0.0.0.0:8080:80 nginx
```

#### 4. Mapping uniquement en local

```bash
# Accessible uniquement via localhost
docker run -p 127.0.0.1:8080:80 nginx

# Empêche tout accès externe, même depuis le réseau local
```

### Tableau comparatif des stratégies

|Stratégie|Syntaxe|Cas d'usage|Sécurité|
|---|---|---|---|
|Port fixe|`-p 8080:80`|Production, services publics|Moyenne|
|Port dynamique|`-p 80`|Développement, tests|Moyenne|
|IP spécifique|`-p 127.0.0.1:8080:80`|Services internes|Élevée|
|Multi-protocole|`-p 53:53/udp -p 53:53/tcp`|DNS, VPN|Moyenne|

### Visualisation du port forwarding

```
┌─────────────────────────────────────────────────┐
│              Machine Hôte                        │
│                                                  │
│  Navigateur                                      │
│      │                                           │
│      │ http://localhost:8080                     │
│      ▼                                           │
│  ┌─────────────────────────────┐                │
│  │   Port 8080 (hôte)          │                │
│  └──────────┬──────────────────┘                │
│             │ Port Forwarding                    │
│             │ -p 8080:80                         │
│             ▼                                    │
│  ┌─────────────────────────────────────────┐    │
│  │        Conteneur Docker                 │    │
│  │  ┌─────────────────────────┐            │    │
│  │  │   Port 80 (conteneur)   │            │    │
│  │  │         nginx           │            │    │
│  │  └─────────────────────────┘            │    │
│  └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

---

## Option -P

L'option `-P` (ou `--publish-all`) expose automatiquement **tous les ports** déclarés avec l'instruction `EXPOSE` dans le Dockerfile du conteneur.

### Syntaxe

```bash
docker run -P IMAGE
```

### Fonctionnement

```bash
# Le Dockerfile de l'image contient :
# EXPOSE 80
# EXPOSE 443

# Lancer avec -P
docker run -d -P nginx

# Docker attribue automatiquement des ports aléatoires
# Port 80 → 0.0.0.0:32768
# Port 443 → 0.0.0.0:32769
```

### Découvrir les ports attribués

```bash
# Méthode 1 : docker port
docker port <CONTAINER_ID>
# Sortie :
# 80/tcp -> 0.0.0.0:32768
# 443/tcp -> 0.0.0.0:32769

# Méthode 2 : docker ps
docker ps
# La colonne PORTS montre les mappings

# Méthode 3 : docker inspect
docker inspect <CONTAINER_ID> | grep -A 10 "Ports"
```

### Différence entre -p et -P

|Critère|`-p` (publish)|`-P` (publish-all)|
|---|---|---|
|Contrôle|Manuel, précis|Automatique|
|Ports exposés|Ceux que vous spécifiez|Tous les ports EXPOSE du Dockerfile|
|Port hôte|Défini par vous|Attribué par Docker (aléatoire)|
|Cas d'usage|Production, configuration précise|Développement rapide, tests|

> [!example] Comparaison pratique
> 
> ```bash
> # Avec -p : vous contrôlez tout
> docker run -p 8080:80 -p 8443:443 nginx
> # Accès : http://localhost:8080 et https://localhost:8443
> 
> # Avec -P : Docker décide
> docker run -P nginx
> # Accès : http://localhost:32768 et https://localhost:32769
> # (les ports peuvent changer à chaque lancement)
> ```

### Limiter -P à une interface spécifique

Il n'est pas possible de combiner `-P` avec une IP spécifique directement, mais vous pouvez utiliser `--network` pour plus de contrôle.

```bash
# -P expose sur toutes les interfaces (0.0.0.0)
docker run -P nginx

# Pour plus de contrôle, utilisez -p avec les ports individuels
docker run -p 127.0.0.1::80 nginx  # Port dynamique sur localhost uniquement
```

---

## Pièges courants

### 1. Port déjà utilisé

```bash
# Erreur courante
docker run -p 8080:80 nginx
# Error: Bind for 0.0.0.0:8080 failed: port is already allocated

# Solutions :
# a) Identifier le processus utilisant le port
sudo lsof -i :8080
# ou
sudo netstat -tuln | grep 8080

# b) Choisir un autre port
docker run -p 8081:80 nginx

# c) Arrêter le conteneur utilisant le port
docker stop <CONTAINER_ID>
```

> [!warning] Attention Windows Sur Windows, certains ports (notamment 80, 443) peuvent être réservés par le système ou IIS.

### 2. Oublier le protocole UDP

```bash
# ❌ Incorrect pour un serveur DNS
docker run -p 53:53 dns-server
# Seul TCP est mappé !

# ✅ Correct
docker run -p 53:53/udp dns-server

# ✅ Encore mieux (TCP et UDP)
docker run -p 53:53/tcp -p 53:53/udp dns-server
```

### 3. Confusion entre port hôte et port conteneur

```bash
# ❌ Erreur : inversion des ports
docker run -p 80:8080 nginx
# nginx écoute sur le port 80 dans le conteneur, pas 8080 !

# ✅ Correct
docker run -p 8080:80 nginx
# Hôte:Conteneur
```

> [!tip] Mémo Rappelez-vous toujours : `-p HÔTE:CONTENEUR`

### 4. Firewall bloquant les ports

```bash
# Le conteneur fonctionne mais n'est pas accessible depuis l'extérieur

# Vérifier le firewall (Linux)
sudo ufw status
sudo ufw allow 8080/tcp

# Vérifier le firewall (Windows)
# PowerShell en admin
New-NetFirewallRule -DisplayName "Docker Port 8080" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

### 5. Utiliser -P en production

> [!warning] Éviter -P en production L'option `-P` attribue des ports aléatoires qui peuvent changer à chaque redémarrage. Cela rend impossible la configuration de load balancers, reverse proxies, ou DNS.

---

## Bonnes pratiques

### 1. Utiliser des ports non-privilégiés en développement

```bash
# ✅ Bon : évite les conflits et les problèmes de permissions
docker run -p 8080:80 nginx

# ❌ À éviter : nécessite des droits root et peut causer des conflits
docker run -p 80:80 nginx
```

### 2. Exposer uniquement sur localhost en développement

```bash
# ✅ Sécurisé : accessible uniquement en local
docker run -p 127.0.0.1:8080:80 nginx

# ❌ Moins sécurisé : accessible depuis le réseau
docker run -p 8080:80 nginx
```

### 3. Documenter les mappings de ports

```bash
# Créer un docker-compose.yml pour la documentation
version: '3.8'
services:
  web:
    image: nginx
    ports:
      - "8080:80"   # Frontend HTTP
      - "8443:443"  # Frontend HTTPS
  
  api:
    image: mon-api
    ports:
      - "5000:5000" # API REST
```

### 4. Utiliser des variables d'environnement pour les ports

```bash
# Rendre les ports configurables
export WEB_PORT=8080
docker run -p ${WEB_PORT}:80 nginx

# Ou avec docker-compose
# docker-compose.yml
services:
  web:
    ports:
      - "${WEB_PORT:-8080}:80"  # Port par défaut : 8080
```

### 5. Vérifier les ports avant le lancement

```bash
# Script de vérification
check_port() {
  if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Port $1 déjà utilisé"
    return 1
  else
    echo "✅ Port $1 disponible"
    return 0
  fi
}

check_port 8080 && docker run -p 8080:80 nginx
```

### 6. Nommer les conteneurs pour faciliter la gestion

```bash
# ✅ Avec nom : facile à gérer
docker run -d --name mon-nginx -p 8080:80 nginx
docker port mon-nginx

# ❌ Sans nom : difficile à retrouver
docker run -d -p 8080:80 nginx
docker port <ID_COMPLIQUÉ>
```

### 7. Utiliser des ranges de ports cohérents

```bash
# Organisation par projet
# Projet A : 8000-8099
docker run -p 8080:80 projet-a-web
docker run -p 8081:3000 projet-a-api

# Projet B : 8100-8199
docker run -p 8180:80 projet-b-web
docker run -p 8181:3000 projet-b-api
```

---

> [!tip] Astuce finale Utilisez `docker ps --format "table {{.Names}}\t{{.Ports}}"` pour une vue claire de tous vos mappings de ports actifs.

```bash
# Affichage personnalisé
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}"

# Sortie exemple :
# NAMES          IMAGE    PORTS
# mon-nginx      nginx    0.0.0.0:8080->80/tcp
# mon-postgres   postgres 0.0.0.0:5432->5432/tcp
```