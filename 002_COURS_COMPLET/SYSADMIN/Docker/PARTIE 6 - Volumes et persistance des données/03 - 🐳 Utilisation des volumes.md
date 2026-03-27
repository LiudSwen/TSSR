

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

Docker propose deux syntaxes principales pour monter des volumes dans les conteneurs : **`-v/--volume`** (syntaxe historique et concise) et **`--mount`** (syntaxe moderne et explicite). Chacune a ses avantages selon le contexte d'utilisation.

> [!info] Pourquoi deux syntaxes ?
> 
> - **`-v`** : Héritée des premières versions de Docker, courte et pratique pour les cas simples
> - **`--mount`** : Introduite plus tard pour offrir plus de clarté et gérer des configurations complexes
> 
> Les deux syntaxes sont fonctionnellement équivalentes pour la plupart des cas d'usage.

---

## Option -v / --volume

### Syntaxe et utilisation

L'option `-v` (ou `--volume`) utilise une syntaxe courte avec des champs séparés par deux-points (`:`).

**Syntaxe générale :**

```bash
docker run -v [SOURCE:]DESTINATION[:OPTIONS] image
```

**Structure des champs :**

|Champ|Description|Obligatoire|
|---|---|---|
|`SOURCE`|Chemin hôte ou nom du volume|Non (volume anonyme si omis)|
|`DESTINATION`|Chemin dans le conteneur|**Oui**|
|`OPTIONS`|Flags séparés par virgules (ro, rw, z, Z...)|Non|

> [!example] Exemples de base
> 
> ```bash
> # Volume anonyme
> docker run -v /data nginx
> 
> # Volume nommé
> docker run -v mon-volume:/data nginx
> 
> # Bind mount (chemin absolu requis)
> docker run -v /home/user/data:/data nginx
> 
> # Avec options (lecture seule)
> docker run -v mon-volume:/data:ro nginx
> ```

### Les différents types de montage avec -v

#### 1️⃣ Volume anonyme

Créé automatiquement par Docker, géré dans `/var/lib/docker/volumes/`.

```bash
docker run -d --name app -v /app/data nginx

# Docker génère un ID unique
# Visible avec : docker volume ls
```

> [!warning] Limitation des volumes anonymes Les volumes anonymes sont difficiles à identifier et à réutiliser. Privilégiez les volumes nommés pour une meilleure gestion.

#### 2️⃣ Volume nommé

Volume géré par Docker avec un nom explicite.

```bash
# Création implicite lors du run
docker run -d --name app -v app-data:/app/data nginx

# Ou création explicite préalable
docker volume create app-data
docker run -d --name app -v app-data:/app/data nginx
```

> [!tip] Avantages des volumes nommés
> 
> - Facilement identifiables
> - Réutilisables entre conteneurs
> - Sauvegardables et restaurables simplement
> - Meilleure lisibilité des configurations

#### 3️⃣ Bind mount

Montage d'un répertoire ou fichier spécifique de l'hôte.

```bash
# Répertoire
docker run -d -v /home/user/projet:/app nginx

# Fichier unique
docker run -d -v /home/user/config.json:/app/config.json:ro nginx

# Chemin relatif (depuis Docker 17.06+)
docker run -d -v $(pwd)/data:/app/data nginx
```

> [!warning] Chemins absolus requis Avant Docker 17.06, `-v` exigeait des chemins absolus. Avec les versions récentes, les chemins relatifs sont résolus depuis le répertoire courant.

### Options et flags supplémentaires

Les options sont ajoutées après le second deux-points, séparées par des virgules.

|Option|Description|Cas d'usage|
|---|---|---|
|`ro`|Read-only (lecture seule)|Configuration, assets statiques|
|`rw`|Read-write (défaut)|Données applicatives|
|`z`|SELinux : contenu partagé entre conteneurs|Systèmes avec SELinux|
|`Z`|SELinux : contenu privé au conteneur|Données sensibles avec SELinux|
|`consistent`|Cohérence totale (macOS/Windows)|Développement nécessitant synchro immédiate|
|`cached`|Performances prioritaires (macOS/Windows)|Build, compilation|
|`delegated`|Conteneur maître (macOS/Windows)|Logs, sorties temporaires|

> [!example] Exemples avec options
> 
> ```bash
> # Volume en lecture seule
> docker run -v app-config:/etc/app:ro nginx
> 
> # Bind mount avec SELinux (systèmes RedHat/CentOS)
> docker run -v /host/data:/container/data:z nginx
> 
> # Performance optimisée sur macOS
> docker run -v $(pwd):/app:cached node npm install
> 
> # Combinaison d'options
> docker run -v logs:/var/log:rw,z nginx
> ```

> [!tip] Options de cohérence (macOS/Windows) Sur Docker Desktop, les options `consistent`, `cached`, et `delegated` améliorent les performances des bind mounts :
> 
> - **consistent** : Synchronisation immédiate (lent mais précis)
> - **cached** : L'hôte écrit, le conteneur lit avec délai (développement)
> - **delegated** : Le conteneur écrit, l'hôte lit avec délai (logs, builds)

---

## Option --mount

### Syntaxe et structure

L'option `--mount` utilise une syntaxe clé-valeur plus explicite et lisible.

**Syntaxe générale :**

```bash
docker run --mount key1=value1,key2=value2,... image
```

**Clés principales :**

|Clé|Description|Valeurs possibles|
|---|---|---|
|`type`|Type de montage|`volume`, `bind`, `tmpfs`|
|`source` ou `src`|Source (nom volume ou chemin hôte)|Nom ou chemin|
|`destination`, `dst` ou `target`|Chemin dans le conteneur|Chemin absolu|
|`readonly` ou `ro`|Lecture seule|Pas de valeur (flag)|
|`volume-driver`|Driver de volume personnalisé|Nom du driver|
|`volume-opt`|Options du driver|key=value|

> [!example] Exemples équivalents -v vs --mount
> 
> ```bash
> # Volume nommé
> docker run -v mon-volume:/data nginx
> docker run --mount type=volume,source=mon-volume,target=/data nginx
> 
> # Bind mount
> docker run -v /host/path:/container/path nginx
> docker run --mount type=bind,source=/host/path,target=/container/path nginx
> 
> # Lecture seule
> docker run -v mon-volume:/data:ro nginx
> docker run --mount type=volume,source=mon-volume,target=/data,readonly nginx
> ```

### Comparaison --mount vs -v

|Aspect|`-v / --volume`|`--mount`|
|---|---|---|
|**Syntaxe**|Concise (`src:dst:opts`)|Explicite (`key=value`)|
|**Lisibilité**|Moins claire pour débutants|Très claire|
|**Création auto**|Crée répertoires manquants|Erreur si source inexistante (bind)|
|**Volumes nommés**|✅ Supporté|✅ Supporté|
|**Bind mounts**|✅ Supporté|✅ Supporté|
|**tmpfs**|❌ Nécessite `--tmpfs`|✅ Avec `type=tmpfs`|
|**Options driver**|❌ Limité|✅ `volume-opt`|
|**Docker Compose**|Format court|Format long (recommandé)|

> [!tip] Quand utiliser --mount ? Préférez `--mount` dans ces situations :
> 
> - Scripts de production nécessitant clarté
> - Configurations complexes avec options driver
> - Besoin de validation stricte (erreur si bind source inexistante)
> - Documentation destinée à des débutants

### Cas d'usage avancés

#### Volume avec driver personnalisé

```bash
# Utilisation d'un driver NFS
docker run --mount \
  type=volume,\
  source=nfs-data,\
  target=/data,\
  volume-driver=local,\
  volume-opt=type=nfs,\
  volume-opt=o=addr=192.168.1.100,\
  volume-opt=device=:/share/data \
  nginx
```

#### tmpfs mount (système de fichiers temporaire en RAM)

```bash
# Données temporaires en mémoire (non persistantes)
docker run --mount type=tmpfs,target=/tmp,tmpfs-size=100m nginx
```

> [!info] Utilité de tmpfs Les montages `tmpfs` stockent les données en RAM plutôt que sur disque :
> 
> - ⚡ Performances maximales
> - 🔒 Données effacées à l'arrêt du conteneur
> - 💾 Idéal pour caches, sessions, données temporaires

#### Bind mount avec propagation

```bash
# Propagation des sous-montages de l'hôte vers le conteneur
docker run --mount \
  type=bind,\
  source=/host/path,\
  target=/container/path,\
  bind-propagation=rslave \
  nginx
```

**Modes de propagation :**

- `rprivate` (défaut) : Pas de propagation
- `shared` : Bidirectionnelle
- `slave` : Hôte → Conteneur uniquement
- `rslave` : Récursif slave
- `private` : Isolation totale

---

## Partage de volumes entre conteneurs

### Volumes partagés nommés

Plusieurs conteneurs peuvent monter le même volume nommé simultanément.

> [!example] Scénario classique : App + Base de données
> 
> ```bash
> # 1. Créer le volume
> docker volume create shared-data
> 
> # 2. Conteneur base de données
> docker run -d \
>   --name postgres \
>   -v shared-data:/var/lib/postgresql/data \
>   postgres:15
> 
> # 3. Conteneur application
> docker run -d \
>   --name app \
>   -v shared-data:/app/data \
>   myapp:latest
> 
> # Les deux conteneurs accèdent aux mêmes données
> ```

> [!warning] Gestion de la concurrence Lors du partage de volumes entre conteneurs :
> 
> - Assurez-vous que les applications gèrent correctement les accès concurrents
> - Utilisez des verrous fichiers ou mécanismes de synchronisation si nécessaire
> - Pour les bases de données, évitez d'avoir plusieurs instances écrivant simultanément

### Option --volumes-from

Cette option permet de monter **tous** les volumes d'un conteneur existant dans un nouveau conteneur.

**Syntaxe :**

```bash
docker run --volumes-from CONTENEUR_SOURCE image
```

> [!example] Conteneur de données (Data Container Pattern)
> 
> ```bash
> # 1. Créer un conteneur avec des volumes (peut être arrêté)
> docker create -v /data --name datastore busybox
> 
> # 2. Utiliser ses volumes dans d'autres conteneurs
> docker run -d --volumes-from datastore --name app1 nginx
> docker run -d --volumes-from datastore --name app2 nginx
> 
> # app1 et app2 partagent les mêmes volumes que datastore
> ```

**Options supplémentaires :**

```bash
# Monter en lecture seule
docker run --volumes-from datastore:ro nginx

# Monter en lecture-écriture (défaut)
docker run --volumes-from datastore:rw nginx
```

> [!tip] Cas d'usage de --volumes-from
> 
> - **Conteneurs de backup** : Monter les volumes pour sauvegarder
> - **Migration de données** : Transférer données entre conteneurs
> - **Debugging** : Inspecter les volumes d'un conteneur en production
> - **Partage de configuration** : Distribuer fichiers de config communs

> [!warning] Limitations de --volumes-from
> 
> - Moins flexible que le montage direct de volumes nommés
> - Crée une dépendance implicite entre conteneurs
> - Difficile à suivre dans des architectures complexes
> 
> **Recommandation moderne** : Préférez les volumes nommés explicites pour plus de clarté.

### Patterns de communication

#### Pattern 1 : Partage de logs

```bash
# Volume de logs partagé
docker volume create app-logs

# Application qui génère des logs
docker run -d \
  --name webapp \
  -v app-logs:/var/log/app \
  myapp

# Collecteur de logs (Fluentd, Logstash...)
docker run -d \
  --name log-collector \
  -v app-logs:/logs:ro \
  fluentd
```

#### Pattern 2 : Configuration centralisée

```bash
# Volume de configuration
docker volume create app-config

# Conteneur qui initialise la config
docker run --rm \
  -v app-config:/config \
  busybox sh -c "echo 'key=value' > /config/app.conf"

# Applications qui consomment la config (lecture seule)
docker run -d -v app-config:/etc/app:ro --name app1 myapp
docker run -d -v app-config:/etc/app:ro --name app2 myapp
```

#### Pattern 3 : Processing pipeline

```bash
# Volume de données partagé
docker volume create pipeline-data

# Étape 1 : Ingestion
docker run --rm \
  -v pipeline-data:/data \
  --name ingester \
  myingester

# Étape 2 : Traitement
docker run --rm \
  -v pipeline-data:/data \
  --name processor \
  myprocessor

# Étape 3 : Export
docker run --rm \
  -v pipeline-data:/data:ro \
  --name exporter \
  myexporter
```

> [!tip] Coordination entre conteneurs Lors de pipelines ou workflows :
> 
> - Utilisez des signaux ou fichiers marqueurs pour synchroniser les étapes
> - Implémentez des mécanismes de retry en cas de conflit
> - Loggez les opérations sur volumes partagés pour faciliter le debugging

#### Pattern 4 : Conteneur Sidecar

```bash
# Volume partagé entre conteneur principal et sidecar
docker volume create app-shared

# Conteneur principal
docker run -d \
  --name main-app \
  -v app-shared:/app/data \
  myapp

# Sidecar pour monitoring/backup
docker run -d \
  --name sidecar \
  --volumes-from main-app:ro \
  monitoring-agent
```

---

## Bonnes pratiques

### ✅ Recommandations générales

1. **Privilégier les volumes nommés pour la persistance**
    
    ```bash
    # ✅ Bon
    docker run -v postgres-data:/var/lib/postgresql/data postgres
    
    # ❌ À éviter (volume anonyme)
    docker run -v /var/lib/postgresql/data postgres
    ```
    
2. **Utiliser bind mounts pour le développement uniquement**
    
    ```bash
    # ✅ OK en développement
    docker run -v $(pwd)/src:/app/src:cached node
    
    # ❌ À éviter en production (couplage avec l'hôte)
    docker run -v /srv/myapp:/app nginx
    ```
    
3. **Monter en lecture seule quand possible**
    
    ```bash
    # Configuration qui ne doit jamais être modifiée
    docker run -v app-config:/etc/app:ro nginx
    ```
    
4. **Préférer --mount pour les scripts de production**
    
    ```bash
    # Plus lisible et moins sujet aux erreurs
    docker run --mount type=volume,source=data,target=/data nginx
    ```
    
5. **Documenter les volumes dans les Dockerfiles**
    
    ```dockerfile
    # Déclare les points de montage attendus
    VOLUME ["/data", "/config"]
    ```
    

### ⚠️ Pièges courants

#### Piège 1 : Chemins relatifs avec -v

```bash
# ❌ Peut créer un volume nommé "data" au lieu d'un bind mount
docker run -v data:/app nginx

# ✅ Utiliser un chemin absolu ou $(pwd)
docker run -v $(pwd)/data:/app nginx
```

#### Piège 2 : Permissions filesystem

```bash
# Le conteneur peut ne pas avoir les permissions nécessaires
# ✅ Vérifier l'UID/GID du processus dans le conteneur
docker run --user 1000:1000 -v /host/data:/data nginx

# Ou ajuster les permissions côté hôte
sudo chown -R 1000:1000 /host/data
```

#### Piège 3 : Volume masquant des données existantes

```bash
# Si l'image contient déjà /app/data, le volume le remplace
docker run -v empty-volume:/app/data myapp

# ✅ Docker copie le contenu initial de l'image dans le volume
# (uniquement si le volume est vide et nommé)
```

#### Piège 4 : Suppression accidentelle de volumes

```bash
# ❌ Supprime le conteneur ET ses volumes anonymes
docker rm -v container

# ✅ Utiliser des volumes nommés pour éviter les pertes
docker volume create important-data
docker run -v important-data:/data nginx
```

### 🎯 Astuces avancées

#### Astuce 1 : Inspecter les montages d'un conteneur

```bash
# Afficher tous les volumes montés
docker inspect -f '{{ json .Mounts }}' container | jq

# Trouver le chemin hôte d'un volume
docker volume inspect volume-name -f '{{ .Mountpoint }}'
```

#### Astuce 2 : Backup rapide d'un volume

```bash
# Créer une archive du volume
docker run --rm \
  -v mon-volume:/data \
  -v $(pwd):/backup \
  busybox tar czf /backup/backup.tar.gz -C /data .
```

#### Astuce 3 : Partage de socket Docker

```bash
# Permettre à un conteneur de contrôler Docker
docker run -v /var/run/docker.sock:/var/run/docker.sock docker

# ⚠️ Attention : accès root équivalent sur l'hôte !
```

#### Astuce 4 : Variables d'environnement pour les chemins

```bash
# Rendre les montages configurables
DATA_DIR=/srv/mydata
docker run -v ${DATA_DIR}:/data nginx
```

#### Astuce 5 : Montage de multiples volumes

```bash
# Plusieurs volumes dans une seule commande
docker run \
  -v app-data:/app/data \
  -v app-config:/app/config:ro \
  -v app-logs:/app/logs \
  -v $(pwd)/src:/app/src:cached \
  myapp
```

---

> [!info] Rappel Cette partie couvre **l'utilisation** des volumes. La création, la gestion du cycle de vie et les opérations de maintenance des volumes sont abordées dans d'autres parties du cours.