

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

Au fil du temps, Docker accumule des ressources inutilisées : conteneurs arrêtés, images sans tags, volumes orphelins et réseaux non utilisés. Ces ressources consomment de l'espace disque et peuvent ralentir votre système. Les commandes de nettoyage (`prune`) permettent de libérer cet espace efficacement.

> [!info] Philosophie du nettoyage Docker Docker adopte une approche conservatrice : il ne supprime jamais automatiquement vos données. C'est à vous de déclencher le nettoyage quand nécessaire. Les commandes `prune` sont conçues pour être sûres et réversibles (sauf pour les données bien sûr).

---

## 🔍 Pourquoi nettoyer régulièrement ?

### Problèmes causés par l'accumulation de ressources

|Problème|Impact|Symptôme|
|---|---|---|
|**Espace disque saturé**|Impossibilité de créer de nouveaux conteneurs/images|Erreurs "no space left on device"|
|**Performance dégradée**|Ralentissement des opérations Docker|Commandes Docker lentes|
|**Confusion**|Difficulté à identifier les ressources actives|Listes longues et désorganisées|
|**Coûts inutiles**|En production, stockage cloud facturé|Factures élevées|

### Quand nettoyer ?

- **Quotidien** : Sur les environnements de développement actifs
- **Hebdomadaire** : Sur les serveurs de test/staging
- **Mensuel** : Sur les environnements de production (avec précaution)
- **Après chaque projet** : Nettoyage complet en développement
- **Avant déploiement** : Assurer un environnement propre

> [!warning] Attention en production En production, le nettoyage doit être planifié et testé. Certaines images "non utilisées" peuvent être nécessaires pour un rollback rapide.

---

## 🗑️ Docker System Prune

### Concept

`docker system prune` est la commande universelle qui nettoie **plusieurs types de ressources** en une seule fois. C'est l'outil le plus puissant et le plus utilisé.

### Syntaxe de base

```bash
# Nettoyage standard (interactif)
docker system prune

# Nettoyage sans confirmation
docker system prune -f

# Nettoyage complet (inclut TOUTES les images non utilisées)
docker system prune -a

# Nettoyage total sans confirmation
docker system prune -a -f

# Nettoyage avec suppression des volumes
docker system prune --volumes

# Combinaison complète (DANGEREUX)
docker system prune -a --volumes -f
```

### Ce qui est supprimé

Par défaut, `docker system prune` supprime :

1. ✅ **Conteneurs arrêtés**
2. ✅ **Réseaux non utilisés** (non attachés à un conteneur)
3. ✅ **Images "dangling"** (sans tag, intermédiaires)
4. ✅ **Cache de build** (couches non utilisées)

> [!example] Exemple de sortie
> 
> ```bash
> $ docker system prune
> WARNING! This will remove:
>   - all stopped containers
>   - all networks not used by at least one container
>   - all dangling images
>   - all dangling build cache
> 
> Are you sure you want to continue? [y/N] y
> 
> Deleted Containers:
> a1b2c3d4e5f6
> f6e5d4c3b2a1
> 
> Deleted Images:
> untagged: my-app@sha256:abc123...
> deleted: sha256:def456...
> 
> Total reclaimed space: 3.5GB
> ```

### Options avancées

```bash
# Filtrer par date (supprimer ce qui a plus de 24h)
docker system prune --filter "until=24h"

# Filtrer par label
docker system prune --filter "label=environment=dev"

# Combiner plusieurs filtres
docker system prune --filter "until=72h" --filter "label!=keep"
```

> [!tip] Astuce : Planification automatique Créez un cron job pour nettoyer automatiquement :
> 
> ```bash
> # Tous les jours à 3h du matin
> 0 3 * * * docker system prune -f --filter "until=48h"
> ```

### Différence avec et sans `-a`

|Option|Images supprimées|Usage typique|
|---|---|---|
|**Sans `-a`**|Seulement les images "dangling" (sans tag)|Sécuritaire, quotidien|
|**Avec `-a`**|Toutes les images non utilisées par un conteneur|Nettoyage profond|

> [!warning] Attention avec `-a` L'option `-a` supprime **toutes** les images qui ne sont pas actuellement utilisées par un conteneur en cours d'exécution. Si vous avez des images que vous comptez réutiliser, elles seront supprimées et devront être re-téléchargées.

---

## 🖼️ Docker Image Prune

### Concept

`docker image prune` nettoie spécifiquement les **images Docker** inutilisées. Plus ciblé que `docker system prune`, il est utile quand vous voulez libérer de l'espace disque sans toucher aux autres ressources.

### Syntaxe

```bash
# Supprimer les images dangling (sans tag)
docker image prune

# Supprimer TOUTES les images non utilisées
docker image prune -a

# Sans confirmation
docker image prune -f

# Avec filtre temporel
docker image prune -a --filter "until=168h"  # 7 jours

# Voir l'espace qui serait libéré (mode dry-run)
docker image prune -a --filter "until=24h" --dry-run
```

### Types d'images concernées

1. **Images "dangling"** (par défaut)
    
    - Images sans tag (`<none>:<none>`)
    - Couches intermédiaires orphelines
    - Résultat de builds successifs
2. **Images non utilisées** (avec `-a`)
    
    - Images avec tag mais sans conteneur associé
    - Anciennes versions d'images
    - Images téléchargées mais jamais exécutées

> [!example] Exemple pratique
> 
> ```bash
> # Lister les images avant nettoyage
> $ docker images
> REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
> nginx         latest    abc123def456   2 weeks ago    142MB
> <none>        <none>    def456abc123   3 weeks ago    200MB
> redis         7.0       789ghi012jkl   1 month ago    117MB
> ubuntu        20.04     mno345pqr678   2 months ago   72.8MB
> 
> # Nettoyer les images dangling
> $ docker image prune -f
> Deleted Images:
> deleted: sha256:def456abc123...
> 
> Total reclaimed space: 200MB
> 
> # Nettoyer toutes les images non utilisées
> $ docker image prune -a -f
> Deleted Images:
> untagged: ubuntu:20.04
> deleted: sha256:mno345pqr678...
> 
> Total reclaimed space: 272.8MB
> ```

### Filtres avancés

```bash
# Supprimer les images de plus de 30 jours
docker image prune -a --filter "until=720h"

# Conserver les images avec un label spécifique
docker image prune -a --filter "label!=keep=true"

# Supprimer uniquement les images d'un certain référentiel
docker images | grep "my-registry" | awk '{print $3}' | xargs docker rmi
```

> [!tip] Astuce : Vérifier avant de supprimer Utilisez `docker images --filter "dangling=true"` pour voir ce qui sera supprimé avant d'exécuter `prune`.

### Pièges courants

> [!warning] Images en cours d'utilisation Si un conteneur (même arrêté) utilise une image, elle ne sera PAS supprimée. Arrêter ne suffit pas, il faut supprimer le conteneur avec `docker rm`.

> [!warning] Multi-stage builds Les images intermédiaires de multi-stage builds sont marquées comme "dangling" mais peuvent être réutilisées par le cache. Les supprimer ralentira les builds futurs.

---

## 📦 Docker Container Prune

### Concept

`docker container prune` supprime tous les **conteneurs arrêtés**. C'est une opération sûre car elle ne touche jamais aux conteneurs en cours d'exécution.

### Syntaxe

```bash
# Supprimer tous les conteneurs arrêtés (avec confirmation)
docker container prune

# Sans confirmation
docker container prune -f

# Avec filtre temporel
docker container prune --filter "until=24h"

# Avec filtre de label
docker container prune --filter "label=temporary"
```

### Ce qui est supprimé

- ✅ Conteneurs avec status `Exited`
- ✅ Conteneurs avec status `Created` (jamais démarrés)
- ❌ Conteneurs en cours d'exécution (`Running`)
- ❌ Conteneurs en pause (`Paused`)

> [!example] Exemple d'utilisation
> 
> ```bash
> # Vérifier les conteneurs arrêtés
> $ docker ps -a --filter "status=exited"
> CONTAINER ID   IMAGE     COMMAND       CREATED        STATUS
> a1b2c3d4e5f6   nginx     "nginx"       2 hours ago    Exited (0)
> f6e5d4c3b2a1   redis     "redis-srv"   1 day ago      Exited (137)
> 
> # Nettoyer
> $ docker container prune -f
> Deleted Containers:
> a1b2c3d4e5f6789...
> f6e5d4c3b2a1234...
> 
> Total reclaimed space: 125MB
> ```

### Filtres utiles

```bash
# Supprimer les conteneurs arrêtés depuis plus de 1 heure
docker container prune --filter "until=1h"

# Supprimer les conteneurs de développement
docker container prune --filter "label=env=dev"

# Combiner plusieurs filtres
docker container prune --filter "until=12h" --filter "label=temporary=true"
```

### Alternative : Suppression sélective

```bash
# Supprimer un conteneur spécifique
docker rm <container_id>

# Supprimer plusieurs conteneurs
docker rm $(docker ps -aq -f status=exited)

# Forcer la suppression (même en cours d'exécution)
docker rm -f <container_id>

# Supprimer et ses volumes associés
docker rm -v <container_id>
```

> [!tip] Astuce : Auto-suppression Utilisez l'option `--rm` lors du lancement pour que le conteneur soit automatiquement supprimé à l'arrêt :
> 
> ```bash
> docker run --rm nginx
> ```

### Espace récupéré

L'espace libéré par `container prune` provient de :

1. **Couche inscriptible** (writable layer) du conteneur
2. **Logs** du conteneur (si non externalisés)
3. **Métadonnées** Docker

> [!info] Note sur l'espace Les conteneurs occupent généralement peu d'espace (quelques MB à quelques centaines de MB). La vraie économie d'espace vient du nettoyage d'images et de volumes.

---

## 💾 Docker Volume Prune

### Concept

`docker volume prune` supprime les **volumes non utilisés** (orphelins). C'est la commande la plus dangereuse car elle peut entraîner une **perte de données permanente**.

### Syntaxe

```bash
# Supprimer les volumes non utilisés (avec confirmation)
docker volume prune

# Sans confirmation (DANGEREUX)
docker volume prune -f

# Avec filtre de label
docker volume prune --filter "label=temporary"

# Voir l'espace qui serait libéré
docker volume prune --filter "label=env=dev" --dry-run
```

### Ce qui est supprimé

Un volume est considéré comme "non utilisé" s'il n'est **attaché à aucun conteneur** (en cours d'exécution OU arrêté).

- ✅ Volumes anonymes sans conteneur
- ✅ Volumes nommés sans conteneur associé
- ❌ Volumes attachés à un conteneur (même arrêté)
- ❌ Volumes en cours d'utilisation

> [!warning] ⚠️ DANGER : Perte de données Les données supprimées dans un volume sont **IRRÉVERSIBLES**. Toujours vérifier le contenu avant de supprimer.

> [!example] Exemple pratique
> 
> ```bash
> # Lister tous les volumes
> $ docker volume ls
> DRIVER    VOLUME NAME
> local     postgres_data
> local     redis_cache
> local     a1b2c3d4e5f6...
> 
> # Identifier les volumes orphelins
> $ docker volume ls -qf dangling=true
> a1b2c3d4e5f6...
> 
> # Inspecter avant de supprimer
> $ docker volume inspect a1b2c3d4e5f6
> 
> # Nettoyer les volumes orphelins
> $ docker volume prune -f
> Deleted Volumes:
> a1b2c3d4e5f6...
> 
> Total reclaimed space: 2.3GB
> ```

### Cas d'usage des volumes

|Type de volume|Quand le supprimer ?|Risque|
|---|---|---|
|**Volumes anonymes**|Après suppression du conteneur|Faible (données temporaires)|
|**Volumes nommés pour cache**|Régulièrement|Faible (régénérable)|
|**Volumes de données métier**|JAMAIS automatiquement|ÉLEVÉ (perte de données)|
|**Volumes de développement**|Fin de projet|Moyen (recréable)|

### Prévenir la perte de données

```bash
# 1. Lister les volumes et leur utilisation
docker volume ls

# 2. Voir quel conteneur utilise un volume
docker ps -a --filter volume=<volume_name>

# 3. Inspecter le volume
docker volume inspect <volume_name>

# 4. Sauvegarder un volume avant suppression
docker run --rm -v <volume_name>:/data -v $(pwd):/backup \
  alpine tar czf /backup/volume-backup.tar.gz /data

# 5. Utiliser des labels pour protéger
docker volume create --label keep=true my_important_data
```

> [!tip] Astuce : Volumes temporaires Pour les volumes que vous savez temporaires, créez-les avec un label :
> 
> ```bash
> docker volume create --label temporary=true cache_volume
> docker volume prune --filter "label=temporary"
> ```

### Alternative : Suppression manuelle

```bash
# Supprimer un volume spécifique
docker volume rm <volume_name>

# Supprimer plusieurs volumes
docker volume rm volume1 volume2 volume3

# Supprimer tous les volumes non utilisés (filtre manuel)
docker volume rm $(docker volume ls -qf dangling=true)
```

> [!warning] Volumes et conteneurs arrêtés Un volume attaché à un conteneur **arrêté** n'est PAS considéré comme orphelin. Vous devez d'abord supprimer le conteneur avec `docker rm` pour libérer le volume.

---

## 🌐 Docker Network Prune

### Concept

`docker network prune` supprime les **réseaux non utilisés**. Un réseau est considéré comme non utilisé s'il n'est connecté à aucun conteneur.

### Syntaxe

```bash
# Supprimer les réseaux non utilisés (avec confirmation)
docker network prune

# Sans confirmation
docker network prune -f

# Avec filtre de label
docker network prune --filter "label=project=old-app"
```

### Réseaux protégés

Certains réseaux ne peuvent JAMAIS être supprimés :

- ❌ `bridge` (réseau par défaut)
- ❌ `host` (réseau host)
- ❌ `none` (pas de réseau)

> [!info] Réseaux système Ces trois réseaux sont créés par Docker au démarrage et sont essentiels au fonctionnement du système.

### Ce qui est supprimé

- ✅ Réseaux personnalisés sans conteneur connecté
- ✅ Réseaux créés manuellement (`docker network create`)
- ✅ Réseaux créés par Docker Compose (si aucun service actif)
- ❌ Réseaux avec au moins un conteneur connecté

> [!example] Exemple d'utilisation
> 
> ```bash
> # Lister tous les réseaux
> $ docker network ls
> NETWORK ID     NAME              DRIVER    SCOPE
> abc123def456   bridge            bridge    local
> def456abc789   host              host      local
> 789ghi012jkl   none              null      local
> jkl012mno345   my_custom_net     bridge    local
> mno345pqr678   old_project_net   bridge    local
> 
> # Identifier les réseaux non utilisés
> $ docker network ls --filter "dangling=true"
> 
> # Nettoyer
> $ docker network prune -f
> Deleted Networks:
> old_project_net
> 
> # Vérification
> $ docker network ls
> NETWORK ID     NAME              DRIVER    SCOPE
> abc123def456   bridge            bridge    local
> def456abc789   host              host      local
> 789ghi012jkl   none              null      local
> jkl012mno345   my_custom_net     bridge    local
> ```

### Cas particulier : Docker Compose

Quand vous utilisez Docker Compose, les réseaux sont automatiquement créés :

```bash
# Docker Compose crée un réseau par défaut
docker-compose up -d  # Crée "myproject_default"

# Arrêter les conteneurs ne supprime PAS le réseau
docker-compose down

# Pour supprimer aussi les réseaux
docker-compose down --volumes --remove-orphans

# Ou nettoyer manuellement
docker network prune -f
```

> [!tip] Astuce : Nommer vos réseaux Créez des réseaux avec des noms explicites et des labels pour faciliter la maintenance :
> 
> ```bash
> docker network create \
>   --label environment=dev \
>   --label project=my-app \
>   my-app-network
> ```

### Vérification avant suppression

```bash
# Voir quels conteneurs utilisent un réseau
docker network inspect <network_name>

# Résultat montre les conteneurs connectés
"Containers": {
    "abc123...": {
        "Name": "web-server",
        "IPv4Address": "172.18.0.2/16"
    }
}

# Si vide, le réseau peut être supprimé en toute sécurité
"Containers": {}
```

### Impact de la suppression

La suppression d'un réseau est **sans risque** car :

1. Les réseaux peuvent être recréés facilement
2. Pas de perte de données
3. Les conteneurs en cours d'exécution gardent leur réseau

> [!warning] Attention aux services interconnectés Si vous supprimez un réseau alors que des conteneurs arrêtés en dépendent, ils ne pourront pas communiquer au redémarrage. Recréez le réseau ou reconnectez les conteneurs.

---

## 📊 Stratégies de nettoyage

### Nettoyage par environnement

#### 🧪 Développement local

Nettoyage agressif pour libérer de l'espace rapidement :

```bash
# Nettoyage quotidien automatique
docker system prune -af --volumes --filter "until=24h"

# OU nettoyage manuel complet
docker stop $(docker ps -aq)
docker system prune -af --volumes
```

**Rationale** : En développement, tout peut être reconstruit facilement. L'espace disque est précieux.

#### 🧪 Environnement de test/CI

Nettoyage après chaque job ou quotidiennement :

```bash
# Script de nettoyage post-test
docker container prune -f
docker image prune -af --filter "until=72h"
docker volume prune -f --filter "label=ci=true"
```

**Rationale** : Les environnements CI/CD accumulent rapidement des artefacts. Nettoyage fréquent pour performances optimales.

#### 🚀 Production

Nettoyage conservateur et planifié :

```bash
# Nettoyage mensuel avec précautions
docker image prune -f --filter "until=720h"  # 30 jours
docker container prune -f --filter "until=168h"  # 7 jours
# PAS de volume prune en production
# PAS de -a sur image prune (garde les images de rollback)
```

**Rationale** : En production, la stabilité prime. Garder les images récentes pour les rollbacks rapides.

### Nettoyage par fréquence

|Fréquence|Commande|Environnement|
|---|---|---|
|**Quotidien**|`docker container prune -f`|Dev, Test|
|**Hebdomadaire**|`docker image prune -f`|Dev, Test, Staging|
|**Mensuel**|`docker system prune -af --filter "until=720h"`|Dev|
|**Mensuel**|`docker system prune -f --filter "until=720h"`|Production|
|**Jamais automatique**|`docker volume prune`|Production|

### Scripts de maintenance

#### Script de nettoyage intelligent

```bash
#!/bin/bash
# docker-cleanup.sh

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Nettoyage Docker ===${NC}"

# 1. Afficher l'espace disque avant
echo -e "\n${YELLOW}Espace disque avant :${NC}"
df -h | grep -E "Filesystem|/var/lib/docker"
docker system df

# 2. Nettoyer les conteneurs arrêtés
echo -e "\n${YELLOW}Nettoyage des conteneurs arrêtés...${NC}"
docker container prune -f --filter "until=24h"

# 3. Nettoyer les images dangling
echo -e "\n${YELLOW}Nettoyage des images dangling...${NC}"
docker image prune -f

# 4. Nettoyer les réseaux
echo -e "\n${YELLOW}Nettoyage des réseaux...${NC}"
docker network prune -f

# 5. Nettoyer le cache de build
echo -e "\n${YELLOW}Nettoyage du cache de build...${NC}"
docker builder prune -f --filter "until=72h"

# 6. Afficher l'espace disque après
echo -e "\n${GREEN}Espace disque après :${NC}"
df -h | grep -E "Filesystem|/var/lib/docker"
docker system df

echo -e "\n${GREEN}=== Nettoyage terminé ===${NC}"
```

#### Script avec confirmation pour production

```bash
#!/bin/bash
# docker-cleanup-prod.sh

echo "AVERTISSEMENT : Nettoyage en environnement de production"
echo "Les images de moins de 30 jours seront conservées"
read -p "Continuer ? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Annulé"
    exit 1
fi

# Nettoyage conservateur
docker container prune -f --filter "until=168h"
docker image prune -f --filter "until=720h"
docker network prune -f

echo "Nettoyage terminé. Vérifiez docker system df"
docker system df
```

### Monitoring de l'espace disque

```bash
# Voir l'utilisation détaillée
docker system df -v

# Résultat détaillé :
# Images space usage:
# REPOSITORY   TAG      IMAGE ID      CREATED      SIZE      SHARED SIZE   UNIQUE SIZE
# 
# Containers space usage:
# CONTAINER ID   IMAGE    COMMAND   SIZE
# 
# Local Volumes space usage:
# VOLUME NAME                    LINKS     SIZE
# 
# Build cache usage:
# ID            PARENT ID          TYPE        SIZE
```

> [!tip] Astuce : Alertes d'espace disque Créez un script de monitoring pour être alerté quand l'espace disque est bas :
> 
> ```bash
> #!/bin/bash
> THRESHOLD=80
> USAGE=$(df -h /var/lib/docker | tail -1 | awk '{print $5}' | sed 's/%//')
> 
> if [ $USAGE -gt $THRESHOLD ]; then
>     echo "ALERTE : Espace disque Docker à ${USAGE}%"
>     docker system df
> fi
> ```

---

## ✅ Bonnes pratiques

### 1. Toujours vérifier avant de nettoyer en production

```bash
# Utilisez --dry-run ou vérifiez manuellement
docker image ls
docker container ls -a
docker volume ls
docker network ls

# Puis décidez ce qui peut être supprimé
```

### 2. Utilisez des labels pour organiser vos ressources

```bash
# Créer des ressources avec des labels
docker run -d --label env=dev --label temporary=true nginx
docker volume create --label backup=required postgres_data
docker network create --label project=myapp myapp_network

# Nettoyer sélectivement
docker container prune --filter "label=temporary=true"
docker volume prune --filter "label=env=dev"
```

### 3. Automatisez le nettoyage en développement

```bash
# Ajoutez à votre crontab (crontab -e)
# Nettoyage tous les jours à 2h du matin
0 2 * * * docker system prune -f --filter "until=48h" >> /var/log/docker-cleanup.log 2>&1
```

### 4. Séparez les données critiques des données temporaires

```bash
# Volume critique (base de données)
docker volume create --label critical=true postgres_production

# Volume temporaire (cache)
docker volume create --label temporary=true redis_cache

# Ne nettoyez JAMAIS automatiquement les volumes critiques
docker volume prune --filter "label=temporary=true"
```

### 5. Sauvegardez avant de nettoyer des volumes

```bash
# Sauvegarder un volume
docker run --rm \
  -v postgres_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/postgres_backup_$(date +%Y%m%d).tar.gz /data

# Restaurer un volume
docker run --rm \
  -v postgres_data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/postgres_backup_20241225.tar.gz -C /
```

### 6. Utilisez des images multi-stage pour réduire la taille

```dockerfile
# Build stage
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage (plus petite)
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/index.js"]
```

**Avantage** : Moins d'images intermédiaires = moins de nettoyage nécessaire.

### 7. Nettoyez le cache de build régulièrement

```bash
# Le cache de build peut devenir très volumineux
docker builder prune -af

# Ou avec filtre temporel
docker builder prune -f --filter "until=168h"
```

### 8. Utilisez `.dockerignore` pour réduire le contexte de build

```
# .dockerignore
node_modules
npm-debug.log
.git
.env
*.md
tests/
```

**Avantage** : Moins de données = builds plus rapides et moins de déchets.

### 9. Privilégiez `--rm` pour les conteneurs temporaires

```bash
# Le conteneur sera automatiquement supprimé à l'arrêt
docker run --rm -it ubuntu bash

# Parfait pour :
# - Tests rapides
# - Scripts one-shot
# - Commandes ponctuelles
```

### 10. Surveillez régulièrement l'espace disque

```bash
# Commande à exécuter régulièrement
watch -n 60 'docker system df'

# Ou créez un alias
alias docker-space='docker system df && echo "\n=== Détail ===" && docker system df -v'
```

### Checklist de nettoyage

> [!tip] Checklist mensuelle
> 
> - [ ] Vérifier `docker system df`
> - [ ] Lister les conteneurs arrêtés depuis longtemps
> - [ ] Identifier les images non utilisées depuis 30+ jours
> - [ ] Vérifier les volumes orphelins
> - [ ] Sauvegarder les données critiques
> - [ ] Exécuter les commandes de nettoyage appropriées
> - [ ] Vérifier l'espace libéré
> - [ ] Documenter les ressources conservées et pourquoi

### Éviter les pièges courants

> [!warning] Erreurs à éviter
> 
> 1. **Ne jamais exécuter `docker system prune -a --volumes -f` en production sans réflexion**
> 2. **Ne pas nettoyer les volumes sans sauvegarde préalable**
> 3. **Ne pas oublier que les conteneurs arrêtés protègent leurs volumes**
> 4. **Ne pas supprimer les images nécessaires aux rollbacks**
> 5. **Ne pas nettoyer pendant les heures de pointe**
> 6. **Ne pas oublier de vérifier les dépendances entre ressources**

### Tableau récapitulatif des commandes

|Commande|Cible|Sécurité|Usage recommandé|
|---|---|---|---|
|`docker system prune`|Conteneurs + Images dangling + Réseaux + Cache|⚠️ Moyen|Quotidien (dev)|
|`docker system prune -a`|+ Toutes images non utilisées|⚠️ Moyen|Hebdomadaire (dev)|
|`docker system prune --volumes`|+ Volumes orphelins|🔴 DANGEREUX|Jamais en auto|
|`docker image prune`|Images dangling|✅ Sûr|Quotidien|
|`docker image prune -a`|Toutes images non utilisées|⚠️ Moyen|Hebdomadaire|
|`docker container prune`|Conteneurs arrêtés|✅ Sûr|Quotidien|
|`docker volume prune`|Volumes orphelins|🔴 DANGEREUX|Manuel uniquement|
|`docker network prune`|Réseaux non utilisés|✅ Sûr|Hebdomadaire|

### Estimation de l'espace récupérable

|Type de ressource|Espace typique|Fréquence d'accumulation|
|---|---|---|
|**Images dangling**|500MB - 5GB|Quotidienne (dev actif)|
|**Conteneurs arrêtés**|10MB - 500MB|Quotidienne|
|**Images non utilisées**|1GB - 20GB|Hebdomadaire|
|**Volumes orphelins**|100MB - 100GB|Variable|
|**Réseaux**|<1MB|Négligeable|
|**Cache de build**|1GB - 50GB|Quotidienne (builds fréquents)|

---

## 📈 Optimisation continue

### Mesurer l'impact du nettoyage

```bash
# Avant le nettoyage
echo "=== AVANT ===" > cleanup-report.txt
docker system df >> cleanup-report.txt
df -h /var/lib/docker >> cleanup-report.txt

# Effectuer le nettoyage
docker system prune -af --filter "until=168h"

# Après le nettoyage
echo "\n=== APRÈS ===" >> cleanup-report.txt
docker system df >> cleanup-report.txt
df -h /var/lib/docker >> cleanup-report.txt

# Afficher le rapport
cat cleanup-report.txt
```

### Analyser les tendances

```bash
# Script pour logger l'utilisation quotidienne
#!/bin/bash
# log-docker-usage.sh

DATE=$(date +%Y-%m-%d)
LOG_FILE="/var/log/docker-usage.log"

echo "[$DATE]" >> $LOG_FILE
docker system df >> $LOG_FILE
echo "---" >> $LOG_FILE

# Analyser avec :
# grep "Images space usage" /var/log/docker-usage.log
```

### Optimiser les images

> [!tip] Réduire la taille des images
> 
> ```dockerfile
> # ❌ Mauvais : image volumineuse
> FROM ubuntu:latest
> RUN apt-get update && apt-get install -y python3 python3-pip
> COPY . /app
> RUN pip3 install -r requirements.txt
> 
> # ✅ Bon : image optimisée
> FROM python:3.11-alpine
> WORKDIR /app
> COPY requirements.txt .
> RUN pip install --no-cache-dir -r requirements.txt
> COPY . .
> ```

### Politique de rétention

Définissez une politique claire pour votre équipe :

```yaml
# docker-cleanup-policy.yml
development:
  containers:
    stopped_older_than: 24h
  images:
    unused_older_than: 7d
  volumes:
    manual_review: true
  frequency: daily

staging:
  containers:
    stopped_older_than: 48h
  images:
    unused_older_than: 14d
  volumes:
    manual_review: true
  frequency: weekly

production:
  containers:
    stopped_older_than: 7d
  images:
    unused_older_than: 30d
    keep_last_n_versions: 3
  volumes:
    never_auto_delete: true
  frequency: monthly
  requires_approval: true
```

---

## 🎯 Cas pratiques

### Cas 1 : Espace disque critique (>90%)

```bash
# 1. Évaluer la situation
docker system df
df -h /var/lib/docker

# 2. Action immédiate : libérer de l'espace rapidement
docker container prune -f
docker image prune -af

# 3. Si insuffisant : nettoyer le cache de build
docker builder prune -af

# 4. En dernier recours (après vérification) : volumes
docker volume ls -qf dangling=true
# Inspecter chaque volume avant de supprimer
docker volume prune -f

# 5. Vérifier le résultat
docker system df
```

### Cas 2 : Projet terminé, nettoyage complet

```bash
# 1. Arrêter tous les conteneurs du projet
docker-compose -f mon-projet/docker-compose.yml down

# 2. Supprimer les conteneurs
docker ps -a --filter "label=com.docker.compose.project=mon-projet" -q | xargs docker rm

# 3. Supprimer les images du projet
docker images --filter "label=project=mon-projet" -q | xargs docker rmi

# 4. Supprimer les volumes du projet (APRÈS SAUVEGARDE)
docker volume ls --filter "label=project=mon-projet" -q | xargs docker volume rm

# 5. Supprimer les réseaux
docker network prune -f --filter "label=project=mon-projet"
```

### Cas 3 : CI/CD - Nettoyage post-pipeline

```bash
#!/bin/bash
# cleanup-after-ci.sh
# À exécuter après chaque job CI/CD

# Variables
BUILD_ID=${CI_BUILD_ID:-"unknown"}
MAX_AGE="6h"

# Nettoyer les conteneurs de ce build
docker container prune -f --filter "label=build_id=$BUILD_ID"

# Nettoyer les images de test
docker image prune -af --filter "until=$MAX_AGE" --filter "label=ci=true"

# Nettoyer les volumes temporaires
docker volume prune -f --filter "label=temporary=true"

# Rapport
echo "Nettoyage CI terminé pour build $BUILD_ID"
docker system df
```

### Cas 4 : Migration vers un nouveau serveur

```bash
# Avant la migration : identifier ce qui doit être conservé

# 1. Lister les conteneurs en production
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"

# 2. Identifier les volumes critiques
docker volume ls --format "{{.Name}}" | while read vol; do
  echo "Volume: $vol"
  docker ps -a --filter volume=$vol --format "  Utilisé par: {{.Names}}"
done

# 3. Exporter les images nécessaires
docker images --format "{{.Repository}}:{{.Tag}}" > images-list.txt

# 4. Sauvegarder les volumes
for vol in $(docker volume ls -q); do
  docker run --rm -v $vol:/data -v $(pwd)/backups:/backup \
    alpine tar czf /backup/$vol.tar.gz /data
done

# 5. Sur le nouveau serveur : nettoyer avant import
docker system prune -af --volumes
```

---

## 🔧 Dépannage

### Problème : "No space left on device"

```bash
# 1. Localiser le problème
df -h
du -sh /var/lib/docker/*

# 2. Action d'urgence
docker system prune -af --volumes

# 3. Redémarrer le démon Docker si nécessaire
sudo systemctl restart docker

# 4. Vérifier les logs Docker
sudo journalctl -u docker --since "1 hour ago"
```

### Problème : Commande prune très lente

```bash
# Cause possible : trop de ressources à analyser

# Solution 1 : Nettoyer par étapes
docker container prune -f
sleep 5
docker image prune -f
sleep 5
docker volume prune -f
sleep 5
docker network prune -f

# Solution 2 : Augmenter le timeout
DOCKER_CLIENT_TIMEOUT=300 docker system prune -af
```

### Problème : Images qui reviennent constamment

```bash
# Cause : Processus automatique qui recrée des images

# Identifier le coupable
docker events --filter "type=image" --filter "event=pull"

# Solutions possibles :
# - Désactiver le pull automatique
# - Utiliser une politique de cache
# - Fixer les versions d'images dans docker-compose.yml
```

### Problème : Volumes supprimés par erreur

```bash
# Prévention : toujours sauvegarder avant de supprimer

# Si c'est trop tard :
# 1. Arrêter IMMÉDIATEMENT toute activité Docker
sudo systemctl stop docker

# 2. Vérifier si des outils de récupération sont possibles
# (dépend du système de fichiers)

# 3. Restaurer depuis la dernière sauvegarde
docker volume create recovered_volume
docker run --rm -v recovered_volume:/data -v $(pwd)/backups:/backup \
  alpine tar xzf /backup/volume_backup.tar.gz -C /

# Leçon : TOUJOURS sauvegarder les volumes critiques
```

---

## 📝 Résumé des points clés

1. **Nettoyage régulier** : Essentiel pour maintenir un environnement Docker sain
2. **docker system prune** : Commande principale, à adapter selon l'environnement
3. **Volumes = DANGER** : Ne jamais nettoyer automatiquement sans sauvegarde
4. **Labels** : Organisent et facilitent le nettoyage sélectif
5. **Filtres temporels** : Permettent un nettoyage progressif et sûr
6. **Automatisation** : Cron jobs pour le nettoyage régulier (dev/test)
7. **Monitoring** : `docker system df` pour surveiller l'utilisation
8. **Environnements** : Stratégies différentes selon dev/staging/prod
9. **Prévention** : Mieux vaut optimiser que nettoyer (images alpine, multi-stage)
10. **Documentation** : Politique de rétention claire pour l'équipe

> [!success] Bonne pratique globale **"Nettoyer souvent, peu à la fois, plutôt que rarement et massivement"**
> 
> Un nettoyage régulier avec des filtres conservateurs (`until=48h`) est plus sûr qu'un nettoyage agressif occasionnel.

---

## 🚀 Pour aller plus loin

### Commandes avancées

```bash
# Voir l'historique d'une image (comprendre sa taille)
docker history <image_name>

# Trouver les plus grosses images
docker images --format "{{.Size}}\t{{.Repository}}:{{.Tag}}" | sort -hr | head -10

# Analyser une image avec dive
dive <image_name>

# Nettoyer les builders BuildKit
docker buildx prune

# Voir les événements Docker en temps réel
docker events --filter "type=container" --filter "type=image"
```

### Outils externes utiles

- **ctop** : Monitoring en temps réel des conteneurs
- **dive** : Analyser la taille des images layer par layer
- **docker-slim** : Réduire la taille des images automatiquement
- **lazydocker** : Interface TUI pour gérer Docker

### Scripts de maintenance avancés

```bash
#!/bin/bash
# docker-health-check.sh
# Script complet de santé Docker

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Seuils d'alerte
DISK_THRESHOLD=80
CONTAINER_THRESHOLD=50

echo -e "${GREEN}=== Health Check Docker ===${NC}\n"

# 1. Vérifier l'espace disque
DISK_USAGE=$(df -h /var/lib/docker | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt $DISK_THRESHOLD ]; then
    echo -e "${RED}⚠️  ALERTE: Espace disque à ${DISK_USAGE}%${NC}"
else
    echo -e "${GREEN}✅ Espace disque: ${DISK_USAGE}%${NC}"
fi

# 2. Compter les conteneurs arrêtés
STOPPED=$(docker ps -aq -f status=exited | wc -l)
if [ $STOPPED -gt $CONTAINER_THRESHOLD ]; then
    echo -e "${YELLOW}⚠️  $STOPPED conteneurs arrêtés (seuil: $CONTAINER_THRESHOLD)${NC}"
else
    echo -e "${GREEN}✅ $STOPPED conteneurs arrêtés${NC}"
fi

# 3. Images dangling
DANGLING=$(docker images -qf dangling=true | wc -l)
echo -e "${YELLOW}📦 $DANGLING images dangling${NC}"

# 4. Volumes orphelins
ORPHAN_VOL=$(docker volume ls -qf dangling=true | wc -l)
if [ $ORPHAN_VOL -gt 0 ]; then
    echo -e "${YELLOW}💾 $ORPHAN_VOL volumes orphelins${NC}"
fi

# 5. Détails de l'utilisation
echo -e "\n${YELLOW}Utilisation détaillée:${NC}"
docker system df

# 6. Recommandations
echo -e "\n${GREEN}=== Recommandations ===${NC}"
if [ $DISK_USAGE -gt $DISK_THRESHOLD ]; then
    echo "- Exécuter: docker system prune -af"
fi
if [ $STOPPED -gt 10 ]; then
    echo "- Exécuter: docker container prune -f"
fi
if [ $DANGLING -gt 5 ]; then
    echo "- Exécuter: docker image prune -f"
fi
```

---

_Fin du cours - Docker : Nettoyage et Optimisation_ 🎉