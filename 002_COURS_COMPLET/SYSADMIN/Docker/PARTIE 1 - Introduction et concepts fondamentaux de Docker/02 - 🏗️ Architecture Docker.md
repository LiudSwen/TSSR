

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

## 🎯 Vue d'ensemble de l'architecture

L'architecture Docker repose sur un modèle **client-serveur** qui sépare les responsabilités entre plusieurs composants interconnectés. Cette séparation permet une grande flexibilité et facilite la gestion des conteneurs à distance.

> [!info] Architecture globale Docker utilise une architecture modulaire où chaque composant a un rôle spécifique :
> 
> - **Docker Client** : interface utilisateur pour envoyer des commandes
> - **Docker Daemon** : moteur qui exécute et gère les conteneurs
> - **Docker Registry** : dépôt centralisé pour stocker et distribuer les images

```
┌─────────────────┐
│  Docker Client  │
│    (docker)     │
└────────┬────────┘
         │ Commandes via API REST
         ▼
┌─────────────────┐         ┌──────────────────┐
│  Docker Daemon  │◄────────┤ Docker Registry  │
│   (dockerd)     │ Pull/Push│  (Hub/privé)     │
└────────┬────────┘         └──────────────────┘
         │
         ├─► Conteneurs
         ├─► Images
         ├─► Volumes
         └─► Networks
```

---

## ⚙️ Docker Engine

### Qu'est-ce que Docker Engine ?

Docker Engine est le **cœur de la plateforme Docker**. C'est une application client-serveur qui regroupe tous les composants nécessaires pour créer et exécuter des conteneurs.

> [!info] Composants de Docker Engine Docker Engine comprend trois éléments principaux :
> 
> 1. **Un serveur** (daemon `dockerd`) qui tourne en arrière-plan
> 2. **Une API REST** pour communiquer avec le daemon
> 3. **Un client CLI** (`docker`) pour interagir avec l'API

### Pourquoi cette architecture ?

Cette séparation offre plusieurs avantages :

- **Flexibilité** : le client peut communiquer avec un daemon local ou distant
- **Scalabilité** : plusieurs clients peuvent interagir avec le même daemon
- **Sécurité** : possibilité de sécuriser les communications via TLS
- **Automatisation** : l'API REST permet l'intégration dans des outils et scripts

### Communication entre composants

```bash
# Le client docker envoie une commande
docker run nginx

# 1. Le client traduit la commande en requête API REST
# 2. La requête est envoyée au daemon (local ou distant)
# 3. Le daemon traite la requête et retourne le résultat
```

> [!example] Vérifier l'architecture installée
> 
> ```bash
> # Afficher la version complète de Docker Engine
> docker version
> 
> # Informations système détaillées
> docker info
> 
> # Vérifier l'architecture du système
> docker version --format '{{.Server.Arch}}'
> ```

### Versions de Docker Engine

|Version|Description|Usage recommandé|
|---|---|---|
|**Community (CE)**|Version gratuite et open-source|Développement, petites équipes, production|
|**Enterprise (EE)**|Version payante avec support|Grandes entreprises, besoins de support|

> [!tip] Installation Docker Engine est disponible sur Linux, macOS (via Docker Desktop) et Windows (via Docker Desktop ou WSL2).

---

## 🔧 Docker Daemon (dockerd)

### Rôle du daemon

Le Docker Daemon (`dockerd`) est le **processus serveur** qui s'exécute en arrière-plan sur l'hôte. C'est lui qui fait tout le travail : créer, exécuter, surveiller et détruire les conteneurs.

> [!info] Responsabilités principales
> 
> - Écouter les requêtes de l'API Docker
> - Gérer les objets Docker (images, conteneurs, réseaux, volumes)
> - Communiquer avec d'autres daemons (pour Docker Swarm par exemple)
> - Interagir avec le système d'exploitation hôte

### Fonctionnement du daemon

```bash
# Le daemon est généralement démarré comme service système
sudo systemctl status docker

# Logs du daemon
sudo journalctl -u docker -f

# Vérifier si le daemon est accessible
docker info
```

### Configuration du daemon

Le daemon se configure via le fichier `/etc/docker/daemon.json` (Linux) ou via Docker Desktop (macOS/Windows).

> [!example] Exemple de configuration
> 
> ```json
> {
>   "log-driver": "json-file",
>   "log-opts": {
>     "max-size": "10m",
>     "max-file": "3"
>   },
>   "storage-driver": "overlay2",
>   "default-address-pools": [
>     {
>       "base": "172.17.0.0/16",
>       "size": 24
>     }
>   ]
> }
> ```

### Socket Unix vs TCP

Par défaut, le daemon écoute sur un **socket Unix** (`/var/run/docker.sock`) pour des raisons de sécurité.

```bash
# Vérifier le socket
ls -la /var/run/docker.sock

# Le client utilise ce socket par défaut
docker ps
# équivaut à
docker -H unix:///var/run/docker.sock ps
```

> [!warning] Exposition TCP Exposer le daemon sur TCP (port 2375/2376) sans TLS est **dangereux** ! Cela permet à quiconque d'accéder au daemon et donc au système hôte.
> 
> ```bash
> # ⚠️ NE JAMAIS FAIRE EN PRODUCTION
> dockerd -H tcp://0.0.0.0:2375
> ```

### Daemon distant

Vous pouvez configurer le client pour communiquer avec un daemon distant :

```bash
# Se connecter à un daemon distant
docker -H tcp://remote-host:2376 ps

# Définir la variable d'environnement
export DOCKER_HOST=tcp://remote-host:2376
docker ps

# Avec TLS (recommandé)
docker -H tcp://remote-host:2376 \
  --tlsverify \
  --tlscacert=ca.pem \
  --tlscert=cert.pem \
  --tlskey=key.pem \
  ps
```

> [!tip] Docker Context Docker propose un système de "context" pour gérer facilement plusieurs daemons :
> 
> ```bash
> # Créer un contexte
> docker context create remote --docker "host=tcp://remote:2376"
> 
> # Lister les contextes
> docker context ls
> 
> # Utiliser un contexte
> docker context use remote
> ```

### Gestion du daemon

```bash
# Démarrer le daemon (Linux)
sudo systemctl start docker

# Arrêter le daemon
sudo systemctl stop docker

# Redémarrer le daemon
sudo systemctl restart docker

# Activer au démarrage
sudo systemctl enable docker

# Recharger la configuration sans redémarrer
sudo systemctl reload docker
```

> [!warning] Pièges courants
> 
> - **Redémarrage brutal** : `systemctl restart docker` arrête tous les conteneurs !
> - **Permissions** : l'utilisateur doit être dans le groupe `docker` ou utiliser `sudo`
> - **Changement de configuration** : nécessite un redémarrage du daemon pour être pris en compte

---

## 💻 Docker Client (docker)

### Rôle du client

Le Docker Client (`docker`) est l'**interface en ligne de commande** que vous utilisez pour interagir avec Docker. C'est le principal outil pour envoyer des instructions au daemon.

> [!info] Principe de fonctionnement Le client traduit vos commandes en requêtes HTTP vers l'API REST du daemon, puis affiche les résultats de manière lisible.

### Anatomie d'une commande Docker

```bash
docker [OPTIONS] COMMAND [ARG...]
│      │         │       │
│      │         │       └─► Arguments de la commande
│      │         └─────────► Commande à exécuter
│      └───────────────────► Options globales
└──────────────────────────► Programme client
```

> [!example] Exemples de commandes
> 
> ```bash
> # Structure basique
> docker ps
> 
> # Avec options globales
> docker --debug ps
> 
> # Avec sous-commande et arguments
> docker container run nginx
> 
> # Avec options de commande
> docker run -d -p 80:80 --name web nginx
> ```

### Catégories de commandes

Docker organise ses commandes en groupes logiques :

|Groupe|Description|Exemples|
|---|---|---|
|`container`|Gestion des conteneurs|`run`, `stop`, `rm`, `exec`|
|`image`|Gestion des images|`pull`, `push`, `build`, `ls`|
|`network`|Gestion des réseaux|`create`, `connect`, `ls`|
|`volume`|Gestion des volumes|`create`, `rm`, `ls`|
|`system`|Commandes système|`info`, `df`, `prune`|

```bash
# Nouvelle syntaxe (recommandée)
docker container run nginx
docker image ls
docker volume create myvolume

# Ancienne syntaxe (toujours supportée)
docker run nginx
docker images
docker volume create myvolume
```

> [!tip] Aide en ligne de commande
> 
> ```bash
> # Aide générale
> docker --help
> 
> # Aide sur une commande
> docker run --help
> 
> # Aide sur un groupe de commandes
> docker container --help
> ```

### Options globales importantes

```bash
# Afficher les requêtes API envoyées
docker --debug ps

# Spécifier le daemon cible
docker -H tcp://remote:2376 ps

# Changer le niveau de log
docker --log-level debug ps

# Format de sortie personnalisé
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### Communication client-daemon

```bash
# Le client envoie une requête HTTP
docker ps

# Ce qui se passe en coulisses :
# GET /v1.43/containers/json HTTP/1.1
# Host: unix:///var/run/docker.sock
```

> [!example] Voir les requêtes API
> 
> ```bash
> # Activer le mode debug pour voir les requêtes
> docker --debug run hello-world
> 
> # Utiliser curl pour interroger l'API directement
> curl --unix-socket /var/run/docker.sock \
>   http://localhost/v1.43/containers/json
> ```

### Alternatives au client CLI

Bien que `docker` soit l'outil principal, il existe d'autres moyens d'interagir avec le daemon :

- **API REST** : via curl, scripts Python, etc.
- **SDK officiels** : Go, Python, Java, Node.js
- **Interfaces graphiques** : Portainer, Docker Desktop
- **Outils tiers** : docker-compose, kubernetes

> [!warning] Compatibilité client-daemon Le client et le daemon doivent avoir des versions compatibles. Docker assure une compatibilité API sur plusieurs versions, mais des écarts trop importants peuvent causer des problèmes.
> 
> ```bash
> # Vérifier la compatibilité
> docker version
> 
> # Résultat :
> # Client: Docker Engine - Community
> #  Version:           24.0.7
> #  API version:       1.43
> # 
> # Server: Docker Engine - Community
> #  Version:          24.0.7
> #  API version:      1.43 (minimum version 1.12)
> ```

---

## 📦 Docker Registry

### Qu'est-ce qu'un registry ?

Un Docker Registry est un **système de stockage et de distribution** pour les images Docker. C'est l'équivalent de GitHub pour le code, mais pour les images de conteneurs.

> [!info] Rôle du registry
> 
> - **Stocker** les images Docker de manière centralisée
> - **Distribuer** les images aux différents environnements
> - **Versionner** les images via les tags
> - **Sécuriser** l'accès aux images (registries privés)

### Types de registry

|Type|Description|Usage|
|---|---|---|
|**Docker Hub**|Registry public officiel de Docker|Images publiques, sharing communautaire|
|**Registry privé**|Auto-hébergé ou cloud privé|Entreprise, images confidentielles|
|**Cloud providers**|AWS ECR, Google GCR, Azure ACR|Intégration cloud, CI/CD|

### Docker Hub

Docker Hub est le registry **public par défaut**. Il contient des millions d'images officielles et communautaires.

```bash
# Rechercher une image sur Docker Hub
docker search nginx

# Télécharger une image depuis Docker Hub
docker pull nginx

# Par défaut, cela télécharge depuis Docker Hub
docker pull nginx
# équivaut à
docker pull docker.io/library/nginx:latest
```

> [!example] Structure d'une référence d'image
> 
> ```
> [registry/][namespace/]repository[:tag|@digest]
> │           │           │          │
> │           │           │          └─► Version (tag ou digest)
> │           │           └────────────► Nom de l'image
> │           └────────────────────────► Utilisateur ou organisation
> └────────────────────────────────────► Serveur registry
> 
> Exemples :
> nginx                    → docker.io/library/nginx:latest
> nginx:1.25               → docker.io/library/nginx:1.25
> myuser/myapp             → docker.io/myuser/myapp:latest
> gcr.io/project/image     → Google Container Registry
> ```

### Authentification

```bash
# Se connecter à Docker Hub
docker login

# Se connecter à un registry privé
docker login registry.example.com

# Se déconnecter
docker logout

# Spécifier les identifiants
docker login -u username -p password
```

> [!warning] Sécurité des credentials Ne jamais stocker les mots de passe en clair dans les scripts ! Utilisez :
> 
> - Variables d'environnement
> - Credential helpers
> - Secrets management (Vault, AWS Secrets Manager)

### Push et Pull

```bash
# Télécharger une image (pull)
docker pull nginx:1.25
docker pull ubuntu:22.04

# Tagger une image pour un registry
docker tag myapp:latest registry.example.com/myapp:1.0

# Pousser une image (push)
docker push registry.example.com/myapp:1.0

# Pull depuis un registry privé
docker pull registry.example.com/private/image:v2
```

### Registry privé auto-hébergé

Docker fournit une image officielle pour héberger votre propre registry :

```bash
# Démarrer un registry local
docker run -d \
  -p 5000:5000 \
  --name registry \
  -v registry-data:/var/lib/registry \
  registry:2

# Tagger une image pour ce registry
docker tag myapp:latest localhost:5000/myapp:1.0

# Pousser vers le registry local
docker push localhost:5000/myapp:1.0

# Pull depuis le registry local
docker pull localhost:5000/myapp:1.0
```

> [!tip] Configuration du registry Pour un registry de production, configurez :
> 
> - **HTTPS/TLS** : sécurisation des communications
> - **Authentification** : contrôle d'accès
> - **Storage backend** : S3, Azure Blob, etc.
> - **Garbage collection** : nettoyage des images inutilisées

### Registries cloud

Les principaux fournisseurs cloud proposent leurs propres registries managés :

```bash
# AWS ECR
aws ecr get-login-password | docker login --username AWS \
  --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0

# Google GCR
gcloud auth configure-docker
docker push gcr.io/my-project/myapp:1.0

# Azure ACR
az acr login --name myregistry
docker push myregistry.azurecr.io/myapp:1.0
```

### Gestion des images dans un registry

```bash
# Lister les tags d'une image sur Docker Hub
# (nécessite l'API ou interface web)

# Supprimer une image du registry local
curl -X DELETE http://localhost:5000/v2/myapp/manifests/sha256:...

# Nettoyer les anciennes versions (garbage collection)
docker exec registry bin/registry garbage-collect \
  /etc/docker/registry/config.yml
```

> [!warning] Pièges courants
> 
> - **Quota de pull** : Docker Hub limite le nombre de pulls anonymes (100/6h)
> - **Taille des layers** : les grosses images ralentissent les déploiements
> - **Tags mutables** : `latest` peut changer sans préavis, préférez des versions fixes
> - **Registries HTTP** : par défaut, Docker n'accepte que HTTPS (sauf localhost)

### Insecure registry

Pour utiliser un registry HTTP en développement :

```json
// /etc/docker/daemon.json
{
  "insecure-registries": ["registry.local:5000"]
}
```

```bash
# Redémarrer le daemon après modification
sudo systemctl restart docker
```

> [!warning] Sécurité Ne jamais utiliser `insecure-registries` en production ! Configurez toujours TLS pour les registries accessibles publiquement.

---

## 🔄 Interaction entre les composants

### Flux complet : du pull au run

Voici ce qui se passe quand vous exécutez `docker run nginx` :

```
1. Client Docker (CLI)
   └─► Envoie la commande au daemon via API REST

2. Docker Daemon
   ├─► Vérifie si l'image existe localement
   ├─► Si non : contacte Docker Registry (Hub)
   │   └─► Pull de l'image nginx
   ├─► Crée un conteneur à partir de l'image
   └─► Démarre le conteneur

3. Docker Registry
   └─► Envoie les layers de l'image au daemon

4. Résultat
   └─► Conteneur nginx en cours d'exécution
```

> [!example] Observer le flux
> 
> ```bash
> # Supprimer l'image localement
> docker rmi nginx
> 
> # Observer le pull puis le run
> docker run --name web -d nginx
> 
> # Sortie :
> # Unable to find image 'nginx:latest' locally
> # latest: Pulling from library/nginx
> # a2abf6c4d29d: Pull complete
> # ...
> # Status: Downloaded newer image for nginx:latest
> # c3f279d17e0a12345...
> ```

### Communication sécurisée

```bash
# Configuration TLS pour daemon distant
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=/path/to/certs
export DOCKER_HOST=tcp://remote:2376

docker ps  # Communication chiffrée TLS
```

> [!tip] Bonnes pratiques
> 
> - Toujours utiliser TLS pour les communications distantes
> - Limiter l'accès au socket Docker (`/var/run/docker.sock`)
> - Utiliser des registries privés pour les images sensibles
> - Activer l'authentification sur les registries