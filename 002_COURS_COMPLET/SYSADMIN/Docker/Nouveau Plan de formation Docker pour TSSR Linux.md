

📘 PARTIE 1 : Introduction et concepts fondamentaux de Docker Fichier Obsidian suggéré : `01-introduction-docker.md`

**Sujets à couvrir :**

1. Qu'est-ce que Docker
    
    - Définition et philosophie
    - Différence conteneur vs machine virtuelle
    - Cas d'usage en entreprise
2. Architecture Docker
    
    - Docker Engine
    - Docker Daemon
    - Docker Client
    - Docker Registry
3. Concepts de base
    
    - Image
    - Conteneur
    - Dockerfile
    - Registry et Docker Hub

---

📘 PARTIE 2 : Installation et configuration Fichier Obsidian suggéré : `02-installation-configuration.md`

**Sujets à couvrir :**

1. Prérequis système
    
    - Versions Ubuntu/Debian compatibles
    - Ressources minimales
    - Architecture processeur
2. Installation sur Ubuntu
    
    - Méthode repository officiel
    - Configuration post-installation
    - Ajout utilisateur au groupe docker
3. Installation sur Debian
    
    - Méthode repository officiel
    - Configuration post-installation
    - Ajout utilisateur au groupe docker
4. Vérification de l'installation
    
    - Commandes de test
    - Hello World Docker
5. Configuration du daemon Docker
    
    - Fichier daemon.json
    - Options de démarrage
    - Gestion du service systemd

---

📘 PARTIE 3 : Manipulation des images Docker Fichier Obsidian suggéré : `03-images-docker.md`

**Sujets à couvrir :**

1. Recherche d'images
    
    - Docker Hub
    - Commande docker search
    - Tags et versions
2. Téléchargement d'images
    
    - docker pull
    - Gestion des tags
    - Images officielles vs communautaires
3. Gestion des images locales
    
    - docker images / docker image ls
    - docker inspect
    - docker rmi
    - docker image prune
4. Registries
    
    - Docker Hub
    - Authentification
    - Push/Pull depuis un registry

---

📘 PARTIE 4 : Gestion des conteneurs Fichier Obsidian suggéré : `04-gestion-conteneurs.md`

**Sujets à couvrir :**

1. Création et démarrage
    
    - docker run
    - Options principales (-d, -it, --name, --rm)
    - Mode interactif vs détaché
2. Gestion du cycle de vie
    
    - docker start/stop/restart
    - docker pause/unpause
    - docker kill
    - docker rm
3. Surveillance des conteneurs
    
    - docker ps / docker container ls
    - docker logs
    - docker stats
    - docker top
    - docker inspect
4. Interaction avec les conteneurs
    
    - docker exec
    - docker attach
    - docker cp

---

📘 PARTIE 5 : Réseau Docker Fichier Obsidian suggéré : `05-reseau-docker.md`

**Sujets à couvrir :**

1. Types de réseaux
    
    - Bridge
    - Host
    - None
    - Overlay (notion de base)
2. Gestion des réseaux
    
    - docker network ls
    - docker network create
    - docker network inspect
    - docker network rm
3. Connexion des conteneurs
    
    - Attacher un conteneur à un réseau
    - Communication inter-conteneurs
    - Résolution DNS
4. Exposition des ports
    
    - Option -p / --publish
    - Mapping de ports
    - Option -P

---

📘 PARTIE 6 : Volumes et persistance des données Fichier Obsidian suggéré : `06-volumes-persistance.md`

**Sujets à couvrir :**

1. Types de stockage
    
    - Volumes
    - Bind mounts
    - tmpfs
2. Gestion des volumes
    
    - docker volume create
    - docker volume ls
    - docker volume inspect
    - docker volume rm
    - docker volume prune
3. Utilisation des volumes
    
    - Option -v / --volume
    - Option --mount
    - Partage de volumes entre conteneurs
4. Bind mounts
    
    - Montage de répertoires hôte
    - Permissions et ownership
    - Cas d'usage

---

📘 PARTIE 7 : Création d'images avec Dockerfile Fichier Obsidian suggéré : `07-dockerfile.md`

**Sujets à couvrir :**

1. Structure d'un Dockerfile
    
    - Syntaxe de base
    - Instructions principales
2. Instructions essentielles
    
    - FROM
    - RUN
    - COPY et ADD
    - WORKDIR
    - ENV
    - EXPOSE
    - CMD et ENTRYPOINT
3. Construction d'images
    
    - docker build
    - Option -t pour le tag
    - Contexte de build
    - Fichier .dockerignore
4. Bonnes pratiques
    
    - Optimisation des layers
    - Ordre des instructions
    - Multi-stage builds (notion de base)
    - Images de base légères

---

📘 PARTIE 8 : Docker Compose Fichier Obsidian suggéré : `08-docker-compose.md`

**Sujets à couvrir :**

1. Introduction à Docker Compose
    
    - Utilité et cas d'usage
    - Installation
2. Fichier docker-compose.yml
    
    - Structure YAML
    - Version du format
    - Services
    - Networks
    - Volumes
3. Commandes Docker Compose
    
    - docker compose up / down
    - docker compose start / stop
    - docker compose ps
    - docker compose logs
    - docker compose exec
4. Configuration des services
    
    - Image ou build
    - Ports
    - Volumes
    - Variables d'environnement
    - Dépendances entre services
    - Restart policy

---

📘 PARTIE 9 : Administration et maintenance Fichier Obsidian suggéré : `09-administration-maintenance.md`

**Sujets à couvrir :**

1. Nettoyage et optimisation
    
    - docker system prune
    - docker image prune
    - docker container prune
    - docker volume prune
    - docker network prune
2. Sauvegarde et restauration
    
    - Export/Import de conteneurs
    - Save/Load d'images
    - Sauvegarde des volumes
3. Logs et debugging
    
    - Configuration des logs drivers
    - Analyse des logs
    - Débogage de conteneurs
4. Ressources et limitations
    
    - Limitation CPU
    - Limitation mémoire
    - Limitation I/O
5. Mises à jour
    
    - Mise à jour de Docker Engine
    - Stratégies de mise à jour des conteneurs

---

📘 PARTIE 10 : Sécurité de base Fichier Obsidian suggéré : `10-securite-base.md`

**Sujets à couvrir :**

1. Bonnes pratiques de sécurité
    
    - Ne pas exécuter en root
    - Images de confiance
    - Scanning de vulnérabilités
    - Mises à jour régulières
2. Isolation et permissions
    
    - User namespaces
    - Capabilities Linux
    - AppArmor/SELinux (notions)
3. Sécurité des images
    
    - Utilisation d'images officielles
    - Vérification des signatures
    - Construction d'images sécurisées
4. Réseau et exposition
    
    - Principe du moindre privilège
    - Exposition minimale des ports
    - Utilisation de reverse proxy
5. Secrets et données sensibles
    
    - Variables d'environnement
    - Docker secrets (notion de base)
    - Bonnes pratiques de gestion