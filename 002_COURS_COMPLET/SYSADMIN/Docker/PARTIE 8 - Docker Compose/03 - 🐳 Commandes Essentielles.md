

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

Les commandes Docker Compose permettent de gérer le cycle de vie complet d'applications multi-conteneurs définies dans un fichier `docker-compose.yml`. Contrairement aux commandes Docker classiques qui opèrent conteneur par conteneur, Docker Compose orchestre plusieurs conteneurs simultanément, ce qui simplifie considérablement la gestion d'applications complexes.

> [!info] Contexte d'utilisation Ces commandes s'appliquent à un projet Docker Compose, c'est-à-dire un répertoire contenant un fichier `docker-compose.yml`. Elles doivent être exécutées depuis ce répertoire ou en spécifiant le chemin avec l'option `-f`.

---

## docker compose up / down

### 🎯 Objectif

Ces deux commandes sont les piliers de Docker Compose : `up` crée et démarre l'ensemble de votre infrastructure, tandis que `down` l'arrête et la supprime proprement.

### docker compose up

**Crée et démarre** tous les services définis dans le fichier `docker-compose.yml`.

#### Syntaxe de base

```bash
docker compose up [OPTIONS] [SERVICE...]
```

#### Options principales

```bash
# Démarrer en mode détaché (arrière-plan)
docker compose up -d

# Forcer la reconstruction des images
docker compose up --build

# Démarrer uniquement certains services
docker compose up service1 service2

# Supprimer les conteneurs orphelins
docker compose up --remove-orphans

# Ne pas démarrer les services dépendants
docker compose up --no-deps service_name

# Attendre que les services soient "healthy" avant de démarrer les dépendants
docker compose up --wait
```

#### Comportement détaillé

Lorsque vous exécutez `docker compose up`, Docker Compose effectue dans l'ordre :

1. **Création du réseau** : Si non existant, crée le réseau par défaut
2. **Création des volumes** : Crée les volumes nommés s'ils n'existent pas
3. **Pull/Build des images** : Télécharge ou construit les images nécessaires
4. **Création des conteneurs** : Crée tous les conteneurs définis
5. **Démarrage orchestré** : Démarre les conteneurs en respectant l'ordre des dépendances

> [!example] Exemple pratique
> 
> ```bash
> # Mode interactif (affiche les logs en direct)
> docker compose up
> 
> # Mode détaché (libère le terminal)
> docker compose up -d
> 
> # Rebuild + démarrage en détaché
> docker compose up -d --build
> 
> # Démarrer uniquement la base de données
> docker compose up -d postgres
> ```

> [!warning] Attention à l'ordre des dépendances Docker Compose démarre les services selon les déclarations `depends_on`, mais cela ne garantit pas que le service soit **prêt** à recevoir des connexions. Utilisez des health checks ou des scripts d'attente pour garantir la disponibilité réelle.

### docker compose down

**Arrête et supprime** les conteneurs, réseaux, et optionnellement volumes et images créés par `up`.

#### Syntaxe de base

```bash
docker compose down [OPTIONS]
```

#### Options principales

```bash
# Supprimer également les volumes nommés
docker compose down -v
# ou
docker compose down --volumes

# Supprimer également les images utilisées
docker compose down --rmi all    # toutes les images
docker compose down --rmi local  # uniquement les images locales

# Supprimer les conteneurs orphelins
docker compose down --remove-orphans

# Délai avant le kill forcé (défaut : 10s)
docker compose down -t 30
```

#### Comportement détaillé

L'exécution de `docker compose down` effectue :

1. **Arrêt des conteneurs** : Envoie SIGTERM puis SIGKILL après le timeout
2. **Suppression des conteneurs** : Supprime tous les conteneurs du projet
3. **Suppression du réseau** : Supprime le réseau par défaut créé
4. **Suppression optionnelle** : Selon les options, supprime volumes/images

> [!example] Exemples d'utilisation
> 
> ```bash
> # Nettoyage standard (garde les volumes et images)
> docker compose down
> 
> # Nettoyage complet avec volumes
> docker compose down -v
> 
> # Nettoyage total (volumes + images)
> docker compose down -v --rmi all
> 
> # Augmenter le délai d'arrêt gracieux
> docker compose down -t 60
> ```

> [!tip] Quand utiliser down vs stop ?
> 
> - Utilisez `down` pour un nettoyage complet en fin de développement ou pour redéployer
> - Utilisez `stop` (voir ci-dessous) si vous voulez juste mettre en pause temporairement tout en conservant les conteneurs

### Tableau comparatif up vs down

|Aspect|`docker compose up`|`docker compose down`|
|---|---|---|
|**Conteneurs**|Crée et démarre|Arrête et supprime|
|**Réseaux**|Crée si nécessaire|Supprime|
|**Volumes**|Crée si nécessaire|Conserve (sauf `-v`)|
|**Images**|Pull/Build si nécessaire|Conserve (sauf `--rmi`)|
|**État des données**|Préservé dans les volumes|Préservé dans les volumes (sauf `-v`)|

---

## docker compose start / stop

### 🎯 Objectif

Ces commandes permettent de **démarrer ou arrêter** des conteneurs **déjà créés** sans les supprimer. Elles sont utiles pour mettre en pause et reprendre votre environnement rapidement.

### docker compose start

**Démarre** des conteneurs existants qui ont été arrêtés.

#### Syntaxe

```bash
docker compose start [SERVICE...]
```

#### Comportement

- Ne crée PAS de nouveaux conteneurs
- Démarre uniquement les conteneurs déjà existants et arrêtés
- Respecte l'ordre des dépendances
- N'affiche pas les logs (contrairement à `up`)

> [!example] Exemples
> 
> ```bash
> # Démarrer tous les services
> docker compose start
> 
> # Démarrer un service spécifique
> docker compose start web
> 
> # Démarrer plusieurs services
> docker compose start web api
> ```

### docker compose stop

**Arrête** les conteneurs en cours d'exécution sans les supprimer.

#### Syntaxe

```bash
docker compose stop [OPTIONS] [SERVICE...]
```

#### Options

```bash
# Définir le timeout avant kill forcé (défaut : 10s)
docker compose stop -t 30

# Arrêter un service spécifique
docker compose stop web
```

#### Comportement

- Envoie SIGTERM aux conteneurs
- Attend le timeout puis envoie SIGKILL si nécessaire
- Conserve les conteneurs (état "exited")
- Conserve les volumes, réseaux, et toute la configuration

> [!example] Exemples pratiques
> 
> ```bash
> # Arrêter tous les services
> docker compose stop
> 
> # Arrêter avec timeout personnalisé
> docker compose stop -t 60
> 
> # Arrêter uniquement la base de données
> docker compose stop postgres
> ```

### Différences clés : start/stop vs up/down

|Commande|Action|Conteneurs après|Réseaux/Volumes|
|---|---|---|---|
|`up`|Crée + démarre|Running|Crée si nécessaire|
|`down`|Arrête + supprime|Supprimés|Supprime réseaux|
|`start`|Démarre existants|Running|Inchangés|
|`stop`|Arrête|Exited (conservés)|Inchangés|

> [!tip] Workflow recommandé
> 
> ```bash
> # Premier lancement du projet
> docker compose up -d
> 
> # Pause pour la nuit ou le weekend
> docker compose stop
> 
> # Reprise le lendemain
> docker compose start
> 
> # Fin de projet ou refonte
> docker compose down -v
> ```

> [!warning] Attention aux modifications du docker-compose.yml Si vous modifiez le fichier `docker-compose.yml` après avoir créé les conteneurs, `start` ne prendra PAS en compte ces changements. Vous devrez utiliser `docker compose up` pour recréer les conteneurs avec la nouvelle configuration.

---

## docker compose ps

### 🎯 Objectif

Affiche l'état des conteneurs gérés par Docker Compose dans le projet courant. C'est l'équivalent de `docker ps` mais filtré pour votre projet Compose.

### Syntaxe

```bash
docker compose ps [OPTIONS] [SERVICE...]
```

### Options principales

```bash
# Afficher tous les conteneurs (y compris arrêtés)
docker compose ps -a

# Afficher uniquement les IDs des conteneurs
docker compose ps -q

# Format de sortie personnalisé
docker compose ps --format json
docker compose ps --format table

# Filtrer les services
docker compose ps --services

# Afficher uniquement certains services
docker compose ps web api
```

### Informations affichées

Par défaut, `docker compose ps` affiche :

- **NAME** : Nom du conteneur
- **IMAGE** : Image utilisée
- **COMMAND** : Commande exécutée
- **SERVICE** : Nom du service dans le docker-compose.yml
- **CREATED** : Date de création
- **STATUS** : État actuel (Up, Exited, Restarting...)
- **PORTS** : Mappings de ports

> [!example] Exemples d'utilisation
> 
> ```bash
> # Vue d'ensemble standard
> docker compose ps
> 
> # Voir tous les conteneurs (actifs et arrêtés)
> docker compose ps -a
> 
> # Obtenir uniquement les IDs (utile pour scripts)
> docker compose ps -q
> 
> # Format JSON pour parsing
> docker compose ps --format json
> 
> # Lister les noms de services disponibles
> docker compose ps --services
> 
> # Vérifier l'état d'un service spécifique
> docker compose ps postgres
> ```

### Interprétation des statuts

|Statut|Signification|Action recommandée|
|---|---|---|
|`Up X seconds/minutes`|Conteneur actif|Aucune|
|`Up X (healthy)`|Conteneur actif avec health check OK|Aucune|
|`Up X (unhealthy)`|Conteneur actif mais health check échoue|Vérifier les logs|
|`Exited (0)`|Conteneur arrêté normalement|Normal si tâche terminée|
|`Exited (1)` ou autre|Conteneur arrêté avec erreur|Vérifier les logs|
|`Restarting`|Conteneur en boucle de redémarrage|Vérifier les logs et la config|

> [!tip] Surveillance rapide Combinez `ps` avec `watch` pour un monitoring en temps réel :
> 
> ```bash
> watch -n 2 docker compose ps
> ```

> [!info] Filtrage par projet Docker Compose identifie automatiquement le projet depuis le nom du répertoire. Tous les conteneurs sont préfixés par ce nom, ce qui permet l'isolation entre projets.

---

## docker compose logs

### 🎯 Objectif

Affiche les logs des conteneurs de votre projet Compose. C'est l'outil principal pour déboguer et surveiller vos services.

### Syntaxe

```bash
docker compose logs [OPTIONS] [SERVICE...]
```

### Options essentielles

```bash
# Suivre les logs en temps réel (comme tail -f)
docker compose logs -f

# Afficher les N dernières lignes
docker compose logs --tail 100

# Afficher les logs depuis un timestamp
docker compose logs --since 2024-01-01T10:00:00
docker compose logs --since 30m  # depuis 30 minutes
docker compose logs --since 2h   # depuis 2 heures

# Afficher les logs jusqu'à un timestamp
docker compose logs --until 2024-01-01T12:00:00

# Afficher les timestamps
docker compose logs -t

# Ne pas afficher les couleurs
docker compose logs --no-color

# Logs d'un service spécifique
docker compose logs web

# Logs de plusieurs services
docker compose logs web api
```

### Comportement détaillé

- Agrège les logs de tous les conteneurs du projet
- Colore par service pour faciliter la lecture
- Préfixe chaque ligne par le nom du service
- Affiche stdout et stderr de chaque conteneur

> [!example] Exemples pratiques
> 
> ```bash
> # Voir tous les logs du projet
> docker compose logs
> 
> # Suivre les logs en temps réel
> docker compose logs -f
> 
> # Les 50 dernières lignes de chaque service
> docker compose logs --tail 50
> 
> # Suivre uniquement les logs du service web
> docker compose logs -f web
> 
> # Logs depuis les 10 dernières minutes avec timestamps
> docker compose logs -t --since 10m
> 
> # Logs d'hier jusqu'à ce matin
> docker compose logs --since "2024-12-24T00:00:00" --until "2024-12-24T09:00:00"
> 
> # Suivre plusieurs services spécifiques
> docker compose logs -f web api postgres
> ```

### Techniques de filtrage avancées

> [!tip] Combinaisons utiles
> 
> ```bash
> # Suivre avec limite de lignes initiales
> docker compose logs -f --tail 20
> 
> # Logs depuis le dernier démarrage
> docker compose logs --since $(docker compose ps -q web | xargs docker inspect -f '{{.State.StartedAt}}')
> 
> # Exporter les logs vers un fichier
> docker compose logs > app_logs.txt
> 
> # Filtrer les logs avec grep
> docker compose logs | grep ERROR
> docker compose logs -f | grep -i "error\|warning"
> ```

### Gestion des logs par service

```bash
# Logs d'un service avec filtrage
docker compose logs web | grep "HTTP"

# Comparer les logs de deux services
docker compose logs web > web.log &
docker compose logs api > api.log &

# Suivre plusieurs services dans des terminaux séparés
# Terminal 1
docker compose logs -f web
# Terminal 2
docker compose logs -f api
```

> [!warning] Volume des logs Les logs peuvent devenir volumineux. Utilisez `--tail` et `--since` pour limiter la sortie, surtout en production. Considérez la mise en place d'une rotation des logs ou d'une solution de logging centralisée pour les environnements de production.

> [!info] Drivers de logging Docker Compose utilise le driver de logging configuré dans Docker (par défaut : `json-file`). Vous pouvez configurer d'autres drivers (syslog, journald, etc.) dans votre docker-compose.yml pour rediriger les logs vers des systèmes externes.

---

## docker compose exec

### 🎯 Objectif

Exécute une commande dans un conteneur **en cours d'exécution**. C'est l'équivalent de `docker exec` mais avec la reconnaissance automatique du projet Compose.

### Syntaxe

```bash
docker compose exec [OPTIONS] SERVICE COMMAND [ARGS...]
```

### Options principales

```bash
# Exécution en mode détaché (arrière-plan)
docker compose exec -d service_name command

# Spécifier l'utilisateur
docker compose exec -u user service_name command
docker compose exec -u root service_name command

# Désactiver l'allocation de TTY
docker compose exec -T service_name command

# Définir des variables d'environnement
docker compose exec -e VAR=value service_name command

# Spécifier le répertoire de travail
docker compose exec -w /app/subdir service_name command

# Spécifier l'index du conteneur (si scale > 1)
docker compose exec --index 2 service_name command

# Mode privilégié
docker compose exec --privileged service_name command
```

### Cas d'usage courants

#### 1. Shell interactif

```bash
# Ouvrir un bash dans le conteneur
docker compose exec web bash

# Ouvrir un sh (Alpine Linux)
docker compose exec web sh

# Avec un utilisateur spécifique
docker compose exec -u postgres postgres bash
```

#### 2. Commandes de base de données

```bash
# Se connecter à PostgreSQL
docker compose exec postgres psql -U username -d database

# Se connecter à MySQL
docker compose exec mysql mysql -u root -p

# Se connecter à MongoDB
docker compose exec mongo mongosh

# Dump d'une base de données
docker compose exec postgres pg_dump -U user dbname > backup.sql
```

#### 3. Inspection et debugging

```bash
# Vérifier les variables d'environnement
docker compose exec web env

# Explorer le système de fichiers
docker compose exec web ls -la /var/www

# Vérifier les processus
docker compose exec web ps aux

# Tester la connectivité réseau
docker compose exec web ping api
docker compose exec web curl http://api:3000/health
```

#### 4. Maintenance applicative

```bash
# Migrations de base de données
docker compose exec web php artisan migrate
docker compose exec web python manage.py migrate

# Clear de cache
docker compose exec web php artisan cache:clear
docker compose exec web npm run clear-cache

# Installation de dépendances
docker compose exec web npm install
docker compose exec web composer install
```

#### 5. Scripts et automatisation

```bash
# Exécuter un script
docker compose exec web ./scripts/setup.sh

# En mode non-interactif (pour scripts)
docker compose exec -T web bash -c "echo 'test' > /tmp/file.txt"

# Avec plusieurs commandes
docker compose exec web bash -c "cd /app && npm test && npm run build"
```

> [!example] Exemples pratiques avancés
> 
> ```bash
> # Créer un utilisateur dans PostgreSQL
> docker compose exec postgres psql -U postgres -c "CREATE USER newuser WITH PASSWORD 'password';"
> 
> # Vérifier les logs d'une application Node.js
> docker compose exec api node -e "console.log(process.env)"
> 
> # Déboguer avec root (installer des outils)
> docker compose exec -u root web apt-get update
> docker compose exec -u root web apt-get install -y vim
> 
> # Exécuter des tests
> docker compose exec web pytest tests/
> docker compose exec web npm test
> 
> # Copier le contenu d'un conteneur (alternative)
> docker compose exec web cat /app/config.json > local_config.json
> ```

### Différences avec docker compose run

|Aspect|`exec`|`run`|
|---|---|---|
|**Conteneur**|Utilise un conteneur existant|Crée un nouveau conteneur|
|**État requis**|Conteneur doit être "Up"|Conteneur peut être arrêté|
|**Réseau**|Réseau du conteneur existant|Nouveau conteneur avec réseau|
|**Volumes**|Volumes du conteneur existant|Monte les volumes définis|
|**Ports**|Utilise les ports mappés|N'expose pas de ports par défaut|
|**Nettoyage**|Aucun|Conteneur reste (sauf `--rm`)|

> [!tip] Quand utiliser exec vs run ?
> 
> - Utilisez `exec` pour interagir avec un service en cours d'exécution (debugging, maintenance)
> - Utilisez `run` pour exécuter des commandes ponctuelles ou des tâches isolées

> [!warning] Service doit être actif `docker compose exec` ne fonctionne que sur des conteneurs en cours d'exécution. Si le service est arrêté, vous obtiendrez une erreur. Vérifiez d'abord avec `docker compose ps`.

### Bonnes pratiques

> [!tip] Astuces exec
> 
> ```bash
> # Toujours vérifier l'état avant exec
> docker compose ps web && docker compose exec web bash
> 
> # Alias pratiques dans votre .bashrc ou .zshrc
> alias dcexec='docker compose exec'
> alias dcbash='docker compose exec web bash'
> 
> # Pour les services avec plusieurs instances
> docker compose exec --index 1 web bash  # première instance
> docker compose exec --index 2 web bash  # deuxième instance
> 
> # Rediriger la sortie vers un fichier
> docker compose exec web cat /var/log/app.log > local_app.log
> ```

---

## 🎓 Récapitulatif des commandes

|Commande|Objectif|Usage principal|État du conteneur|
|---|---|---|---|
|`up`|Crée et démarre|Premier lancement, redéploiement|Créé et démarré|
|`down`|Arrête et supprime|Nettoyage, fin de projet|Supprimé|
|`start`|Démarre existants|Reprise après pause|Running|
|`stop`|Arrête|Pause temporaire|Exited|
|`ps`|Affiche l'état|Surveillance, vérification|Inchangé|
|`logs`|Affiche les logs|Debugging, monitoring|Inchangé|
|`exec`|Exécute commande|Interaction, maintenance|Running requis|

> [!tip] Workflow de développement type
> 
> ```bash
> # Jour 1 : Premier lancement
> docker compose up -d --build
> docker compose ps  # Vérifier l'état
> docker compose logs -f  # Surveiller les logs
> 
> # Interaction quotidienne
> docker compose exec web bash  # Accéder au conteneur
> docker compose logs -f web  # Suivre les logs
> 
> # Fin de journée
> docker compose stop  # Pause
> 
> # Jour 2 : Reprise
> docker compose start
> docker compose ps  # Vérifier l'état
> 
> # Modification du docker-compose.yml
> docker compose up -d  # Recrée les conteneurs modifiés
> 
> # Fin de projet
> docker compose down -v  # Nettoyage complet
> ```