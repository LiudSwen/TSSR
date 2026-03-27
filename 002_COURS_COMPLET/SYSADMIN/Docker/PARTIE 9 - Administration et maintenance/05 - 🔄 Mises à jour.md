

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

La maintenance des environnements Docker nécessite une stratégie claire de mise à jour, tant pour Docker Engine que pour les conteneurs applicatifs. Une bonne gestion des mises à jour garantit la sécurité, la stabilité et les performances de votre infrastructure.

> [!info] Pourquoi mettre à jour ?
> 
> - **Sécurité** : Correction de vulnérabilités critiques
> - **Performances** : Optimisations et nouvelles fonctionnalités
> - **Compatibilité** : Support des nouvelles versions d'images
> - **Stabilité** : Correction de bugs

---

## Mise à jour de Docker Engine

### Vérifier la version actuelle

Avant toute mise à jour, identifiez votre version actuelle de Docker :

```bash
# Version complète de Docker
docker version

# Version simplifiée
docker --version

# Informations système détaillées
docker info
```

> [!example] Exemple de sortie
> 
> ```
> Client: Docker Engine - Community
>  Version:           24.0.7
>  API version:       1.43
>  Go version:        go1.20.10
> ```

### Mise à jour sur Linux

#### Ubuntu/Debian

```bash
# Mettre à jour la liste des paquets
sudo apt-get update

# Voir les versions disponibles
apt-cache madison docker-ce

# Mettre à jour vers la dernière version
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Ou installer une version spécifique
sudo apt-get install docker-ce=5:24.0.0-1~ubuntu.22.04~jammy
```

> [!warning] Attention aux versions majeures Les mises à jour majeures peuvent introduire des changements incompatibles. Testez toujours dans un environnement de développement avant la production.

#### CentOS/RHEL/Fedora

```bash
# Mettre à jour Docker
sudo yum update docker-ce docker-ce-cli containerd.io

# Ou avec dnf (Fedora)
sudo dnf update docker-ce docker-ce-cli containerd.io

# Redémarrer le service
sudo systemctl restart docker
```

#### Vérification post-installation

```bash
# Vérifier que Docker fonctionne
docker run hello-world

# Vérifier les conteneurs existants
docker ps -a

# Tester une commande simple
docker info
```

### Mise à jour sur Windows et macOS

#### Docker Desktop

Docker Desktop intègre un système de mise à jour automatique :

```bash
# Vérifier manuellement les mises à jour
# Interface graphique : Settings → Software Updates

# En ligne de commande (vérifier la version)
docker version
```

> [!tip] Astuce Windows/macOS Docker Desktop notifie automatiquement les nouvelles versions. La mise à jour nécessite un redémarrage de l'application mais ne supprime pas vos conteneurs ou images.

#### Processus de mise à jour manuelle

1. Télécharger la nouvelle version depuis docker.com
2. Fermer Docker Desktop
3. Installer la nouvelle version
4. Redémarrer Docker Desktop
5. Vérifier que tout fonctionne

### Gestion des versions

#### Épingler une version spécifique

Sur Linux, vous pouvez empêcher les mises à jour automatiques :

```bash
# Ubuntu/Debian - Marquer le paquet comme maintenu
sudo apt-mark hold docker-ce docker-ce-cli containerd.io

# Retirer le marqueur
sudo apt-mark unhold docker-ce docker-ce-cli containerd.io

# CentOS/RHEL - Exclure dans yum.conf
# Ajouter dans /etc/yum.conf :
# exclude=docker-ce docker-ce-cli containerd.io
```

#### Passer à une version antérieure (downgrade)

```bash
# Ubuntu/Debian
sudo apt-get install --allow-downgrades \
  docker-ce=5:23.0.0-1~ubuntu.22.04~jammy \
  docker-ce-cli=5:23.0.0-1~ubuntu.22.04~jammy

# CentOS/RHEL
sudo yum downgrade docker-ce-23.0.0 docker-ce-cli-23.0.0
```

> [!warning] Risques du downgrade Le retour à une version antérieure peut créer des incompatibilités avec les images ou conteneurs créés avec une version plus récente.

---

## Stratégies de mise à jour des conteneurs

### Mise à jour manuelle

La méthode la plus simple mais avec interruption de service :

```bash
# 1. Récupérer la nouvelle image
docker pull monapp:latest

# 2. Arrêter le conteneur existant
docker stop monapp-container

# 3. Supprimer le conteneur (les données dans volumes persistent)
docker rm monapp-container

# 4. Recréer avec la nouvelle image
docker run -d \
  --name monapp-container \
  -v monapp-data:/data \
  -p 8080:8080 \
  monapp:latest

# 5. Vérifier que tout fonctionne
docker logs monapp-container
docker ps | grep monapp-container
```

> [!info] Conservation des données Les volumes Docker persistent lors de la suppression d'un conteneur. Seul le conteneur lui-même est recréé avec la nouvelle image.

### Mise à jour avec arrêt minimal

Préparation de la nouvelle version avant l'arrêt de l'ancienne :

```bash
# 1. Télécharger la nouvelle image en arrière-plan
docker pull monapp:v2.0

# 2. Créer le nouveau conteneur sans le démarrer
docker create \
  --name monapp-container-new \
  -v monapp-data:/data \
  -p 8080:8080 \
  monapp:v2.0

# 3. Arrêter l'ancien conteneur
docker stop monapp-container

# 4. Démarrer immédiatement le nouveau
docker start monapp-container-new

# 5. Vérifier et nettoyer l'ancien
docker logs monapp-container-new
docker rm monapp-container
docker rename monapp-container-new monapp-container
```

### Rolling updates

Mise à jour progressive avec plusieurs instances (nécessite un load balancer) :

```bash
# Configuration initiale avec 3 instances
for i in 1 2 3; do
  docker run -d \
    --name monapp-v1-$i \
    --network monapp-net \
    monapp:v1.0
done

# Mise à jour progressive
# 1. Mettre à jour la première instance
docker stop monapp-v1-1
docker rm monapp-v1-1
docker run -d \
  --name monapp-v2-1 \
  --network monapp-net \
  monapp:v2.0

# 2. Surveiller les métriques et logs
docker logs -f monapp-v2-1

# 3. Si OK, continuer avec les autres instances
docker stop monapp-v1-2
docker rm monapp-v1-2
docker run -d \
  --name monapp-v2-2 \
  --network monapp-net \
  monapp:v2.0

# Répéter pour la dernière instance
```

> [!tip] Utilisation de Docker Compose Docker Compose facilite le rolling update avec la commande `docker-compose up -d --scale monapp=3 --no-recreate`

### Blue-Green deployment

Maintien de deux environnements complets, basculement instantané :

```bash
# Environnement Blue (actuel en production)
docker network create blue-network

docker run -d \
  --name app-blue \
  --network blue-network \
  -p 8080:8080 \
  monapp:v1.0

# Préparation de l'environnement Green (nouvelle version)
docker network create green-network

docker run -d \
  --name app-green \
  --network green-network \
  -p 8081:8080 \
  monapp:v2.0

# Tests sur le port 8081
curl http://localhost:8081/health

# Basculement : inverser les ports
docker stop app-blue app-green

docker run -d \
  --name app-green-prod \
  --network green-network \
  -p 8080:8080 \
  monapp:v2.0

docker run -d \
  --name app-blue-standby \
  --network blue-network \
  -p 8081:8080 \
  monapp:v1.0

# Nettoyage après validation
docker rm app-blue app-green
```

> [!info] Avantages Blue-Green
> 
> - **Zéro downtime** : basculement instantané
> - **Rollback facile** : retour immédiat à la version précédente
> - **Tests en conditions réelles** : validation complète avant basculement

#### Avec un reverse proxy (Nginx)

```bash
# Configuration Nginx pour basculement
# /etc/nginx/conf.d/app.conf

upstream backend {
    server app-blue:8080;  # Changer en app-green:8080 pour basculer
}

server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}
```

### Canary deployment

Déploiement progressif avec exposition limitée de la nouvelle version :

```bash
# 4 instances v1.0 en production
for i in 1 2 3 4; do
  docker run -d \
    --name app-v1-$i \
    --network app-net \
    --label version=v1.0 \
    monapp:v1.0
done

# Déployer 1 instance v2.0 (20% du trafic)
docker run -d \
  --name app-v2-1 \
  --network app-net \
  --label version=v2.0 \
  monapp:v2.0

# Surveiller les métriques de la v2.0
docker stats app-v2-1
docker logs app-v2-1 --tail 100 -f

# Si OK, augmenter progressivement
# Ajouter une 2e instance v2.0 (40% du trafic)
docker run -d \
  --name app-v2-2 \
  --network app-net \
  --label version=v2.0 \
  monapp:v2.0

# Retirer progressivement les v1.0
docker stop app-v1-1 && docker rm app-v1-1

# Continuer jusqu'à 100% v2.0
```

> [!example] Configuration Traefik pour Canary
> 
> ```yaml
> # docker-compose.yml
> services:
>   app-v1:
>     image: monapp:v1.0
>     labels:
>       - "traefik.http.services.app.loadbalancer.weight=80"
>   
>   app-v2:
>     image: monapp:v2.0
>     labels:
>       - "traefik.http.services.app.loadbalancer.weight=20"
> ```

### Rollback

Retour à la version précédente en cas de problème :

#### Rollback simple

```bash
# Si l'ancien conteneur existe encore
docker stop monapp-v2
docker start monapp-v1

# Ou recréer depuis l'ancienne image
docker stop monapp-v2
docker rm monapp-v2
docker run -d \
  --name monapp-v1 \
  -v monapp-data:/data \
  -p 8080:8080 \
  monapp:v1.0
```

#### Rollback avec sauvegarde

```bash
# Avant la mise à jour, créer une sauvegarde
docker commit monapp-v1 monapp:v1.0-backup

# Ou exporter le conteneur
docker export monapp-v1 > monapp-v1-backup.tar

# En cas de problème, restaurer
docker stop monapp-v2
docker rm monapp-v2
docker run -d \
  --name monapp-v1 \
  -v monapp-data:/data \
  -p 8080:8080 \
  monapp:v1.0-backup
```

> [!warning] Attention aux données Le rollback d'un conteneur ne restaure pas automatiquement les données. Si la v2.0 a modifié la structure de la base de données, un rollback des données peut être nécessaire.

#### Script de rollback automatisé

```bash
#!/bin/bash
# rollback.sh

CONTAINER_NAME="monapp"
OLD_VERSION="v1.0"
BACKUP_TAG="${OLD_VERSION}-backup"

echo "🔄 Début du rollback..."

# Sauvegarder la version actuelle
docker commit ${CONTAINER_NAME} ${CONTAINER_NAME}:failed-version

# Arrêter le conteneur actuel
docker stop ${CONTAINER_NAME}
docker rm ${CONTAINER_NAME}

# Restaurer l'ancienne version
docker run -d \
  --name ${CONTAINER_NAME} \
  -v ${CONTAINER_NAME}-data:/data \
  -p 8080:8080 \
  ${CONTAINER_NAME}:${BACKUP_TAG}

# Vérifier le démarrage
sleep 5
if docker ps | grep -q ${CONTAINER_NAME}; then
    echo "✅ Rollback réussi"
    docker logs ${CONTAINER_NAME} --tail 20
else
    echo "❌ Échec du rollback"
    exit 1
fi
```

---

## Bonnes pratiques

### 🎯 Planification

|Pratique|Description|
|---|---|
|**Calendrier de maintenance**|Définir des fenêtres de maintenance régulières|
|**Tests préalables**|Tester toutes les mises à jour en développement/staging|
|**Communication**|Prévenir les utilisateurs des interruptions planifiées|
|**Documentation**|Documenter toutes les procédures de mise à jour|

### 🔒 Sécurité

```bash
# Toujours vérifier les signatures d'images
docker trust inspect monapp:latest

# Utiliser des tags spécifiques, pas "latest"
# ❌ Mauvais
docker pull monapp:latest

# ✅ Bon
docker pull monapp:v2.0.1

# Scanner les vulnérabilités
docker scout cves monapp:v2.0.1
```

> [!warning] Tag "latest" Ne jamais utiliser `:latest` en production. Ce tag est mobile et peut pointer vers différentes versions, rendant les rollbacks impossibles.

### 📊 Surveillance

```bash
# Surveiller l'utilisation des ressources après une mise à jour
docker stats --no-stream

# Vérifier les logs en continu
docker logs -f --tail 100 monapp

# Monitorer la santé des conteneurs
docker inspect --format='{{.State.Health.Status}}' monapp

# Surveiller les événements Docker
docker events --filter 'type=container' --filter 'event=start'
```

### 💾 Sauvegarde

```bash
# Sauvegarder les volumes avant mise à jour
docker run --rm \
  -v monapp-data:/source:ro \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/monapp-data-$(date +%Y%m%d).tar.gz -C /source .

# Sauvegarder les configurations
docker inspect monapp > monapp-config-backup.json

# Exporter l'image actuelle
docker save monapp:v1.0 | gzip > monapp-v1.0.tar.gz
```

> [!tip] Automatisation des sauvegardes Créez des scripts cron pour automatiser les sauvegardes avant chaque mise à jour planifiée.

### 🔄 Automatisation

```bash
# Script de mise à jour automatisée
#!/bin/bash
# update-container.sh

IMAGE_NAME=$1
CONTAINER_NAME=$2
BACKUP_ENABLED=${3:-true}

# Récupérer la nouvelle image
docker pull ${IMAGE_NAME}

# Sauvegarder si demandé
if [ "$BACKUP_ENABLED" = true ]; then
    docker commit ${CONTAINER_NAME} ${IMAGE_NAME}-backup
fi

# Mettre à jour
docker stop ${CONTAINER_NAME}
docker rm ${CONTAINER_NAME}
docker run -d --name ${CONTAINER_NAME} ${IMAGE_NAME}

# Vérifier
sleep 3
if docker ps | grep -q ${CONTAINER_NAME}; then
    echo "✅ Mise à jour réussie"
else
    echo "❌ Échec - Rollback en cours"
    docker run -d --name ${CONTAINER_NAME} ${IMAGE_NAME}-backup
fi
```

### 📋 Checklist de mise à jour

> [!example] Checklist complète **Avant la mise à jour :**
> 
> - [ ] Sauvegarder les volumes de données
> - [ ] Exporter la configuration actuelle
> - [ ] Tester la nouvelle version en staging
> - [ ] Vérifier les notes de version (breaking changes)
> - [ ] Préparer un plan de rollback
> - [ ] Informer les parties prenantes
> 
> **Pendant la mise à jour :**
> 
> - [ ] Télécharger la nouvelle image
> - [ ] Vérifier l'intégrité de l'image
> - [ ] Créer le nouveau conteneur
> - [ ] Migrer les données si nécessaire
> - [ ] Appliquer la nouvelle configuration
> 
> **Après la mise à jour :**
> 
> - [ ] Vérifier les logs de démarrage
> - [ ] Tester les fonctionnalités critiques
> - [ ] Surveiller les métriques pendant 24-48h
> - [ ] Valider avec les utilisateurs
> - [ ] Nettoyer les anciennes images/conteneurs
> - [ ] Documenter les changements

### 🚀 Optimisation

```bash
# Nettoyer les anciennes images après mise à jour
docker image prune -a --filter "until=24h"

# Voir l'espace récupérable
docker system df

# Nettoyage complet (attention !)
docker system prune -a --volumes

# Garder seulement les N dernières versions
docker images | grep monapp | tail -n +4 | awk '{print $3}' | xargs docker rmi
```

> [!warning] Prudence avec le nettoyage Le nettoyage automatique peut supprimer des images nécessaires au rollback. Gardez toujours au moins 2-3 versions précédentes.

### 📈 Gestion des versions multiples

```bash
# Stratégie de nommage des tags
monapp:v1.2.3          # Version exacte
monapp:v1.2            # Version mineure
monapp:v1              # Version majeure
monapp:stable          # Dernière version stable
monapp:sha256-abc123   # Build spécifique

# Garder plusieurs versions en parallèle
docker pull monapp:v1.2.3
docker pull monapp:v1.2.4
docker tag monapp:v1.2.4 monapp:stable

# Vérifier les versions disponibles
docker images monapp --format "table {{.Tag}}\t{{.CreatedAt}}\t{{.Size}}"
```