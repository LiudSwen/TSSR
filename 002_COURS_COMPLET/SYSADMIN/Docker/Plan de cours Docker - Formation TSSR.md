

📘 PARTIE 1 : Introduction et concepts fondamentaux Fichier Obsidian suggéré : `01-docker-fondamentaux.md`

**Sujets à couvrir :**

1. Présentation de Docker
    
    - Qu'est-ce que la conteneurisation
    - Différence entre virtualisation et conteneurisation
    - Cas d'usage et avantages de Docker
    - Architecture Docker (daemon, client, registries)
2. Installation et configuration
    
    - Prérequis système
    - Installation sur Linux
    - Installation sur Windows (Docker Desktop)
    - Vérification de l'installation
    - Configuration du daemon Docker
3. Concepts de base
    
    - Images vs Conteneurs
    - Docker Hub et registries
    - Namespaces et cgroups
    - Cycle de vie d'un conteneur

---

📘 PARTIE 2 : Manipulation des images Docker Fichier Obsidian suggéré : `02-docker-images.md`

**Sujets à couvrir :**

1. Gestion des images
    
    - Rechercher des images (docker search)
    - Télécharger des images (docker pull)
    - Lister les images locales (docker images)
    - Supprimer des images (docker rmi)
    - Inspecter une image (docker inspect)
    - Tags et versions
2. Création d'images personnalisées
    
    - Structure d'un Dockerfile
    - Instructions principales (FROM, RUN, COPY, ADD, CMD, ENTRYPOINT, WORKDIR, ENV, EXPOSE)
    - Bonnes pratiques de création
    - Construction d'images (docker build)
    - Layers et système de cache
3. Gestion avancée des images
    
    - Sauvegarder et charger des images (save/load)
    - Exporter et importer (export/import)
    - Nettoyer les images inutilisées (prune)

---

📘 PARTIE 3 : Gestion des conteneurs Fichier Obsidian suggéré : `03-docker-conteneurs.md`

**Sujets à couvrir :**

1. Opérations de base sur les conteneurs
    
    - Créer et démarrer un conteneur (docker run)
    - Options principales de docker run (-d, -p, -v, --name, -e, --rm, -it)
    - Lister les conteneurs (docker ps)
    - Arrêter et redémarrer des conteneurs (stop/start/restart)
    - Supprimer des conteneurs (docker rm)
2. Interaction avec les conteneurs
    
    - Exécuter des commandes dans un conteneur (docker exec)
    - Afficher les logs (docker logs)
    - Copier des fichiers (docker cp)
    - Inspecter un conteneur (docker inspect)
    - Statistiques et monitoring (docker stats)
3. Gestion du cycle de vie
    
    - États d'un conteneur
    - Pause et unpause
    - Redémarrage automatique (restart policies)
    - Limiter les ressources (CPU, mémoire)

---

📘 PARTIE 4 : Stockage et réseau Fichier Obsidian suggéré : `04-docker-stockage-reseau.md`

**Sujets à couvrir :**

1. Gestion du stockage
    
    - Volumes Docker (docker volume)
    - Bind mounts
    - Différences et cas d'usage
    - Création et gestion des volumes
    - Partage de données entre conteneurs
    - Sauvegarde et restauration de volumes
2. Réseau Docker
    
    - Types de réseaux (bridge, host, none)
    - Réseau bridge par défaut
    - Créer des réseaux personnalisés (docker network)
    - Connecter des conteneurs entre eux
    - Publication de ports (-p et -P)
    - Résolution DNS entre conteneurs
    - Inspection des réseaux

---

📘 PARTIE 5 : Déploiement avec Docker Compose Fichier Obsidian suggéré : `05-docker-compose.md`

**Sujets à couvrir :**

1. Introduction à Docker Compose
    
    - Qu'est-ce que Docker Compose
    - Installation de Docker Compose
    - Cas d'usage
2. Fichier docker-compose.yml
    
    - Structure du fichier YAML
    - Services
    - Networks
    - Volumes
    - Variables d'environnement
    - Dépendances entre services (depends_on)
3. Commandes Docker Compose
    
    - Démarrer les services (up)
    - Arrêter les services (down)
    - Voir les logs (logs)
    - Lister les services (ps)
    - Reconstruire les images (build)
    - Scaling des services
4. Cas pratiques de déploiement
    
    - Application web + base de données
    - Pile LAMP/LEMP
    - Reverse proxy avec Nginx
    - Monitoring avec conteneurs