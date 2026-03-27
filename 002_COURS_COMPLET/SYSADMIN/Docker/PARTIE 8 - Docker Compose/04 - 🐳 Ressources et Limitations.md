# 

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

La gestion des ressources est cruciale dans un environnement conteneurisé pour éviter qu'un conteneur monopolise les ressources système et impacte les autres services. Docker Compose permet de définir des limites et des réservations de ressources pour chaque service.

> [!info] Pourquoi limiter les ressources ?
> 
> - **Prévenir les fuites mémoire** : Un conteneur défectueux ne peut pas consommer toute la RAM
> - **Garantir la qualité de service** : Assurer des ressources minimales pour les services critiques
> - **Optimiser l'utilisation** : Mieux répartir les ressources entre plusieurs conteneurs
> - **Prévisibilité** : Comportement stable et prévisible en production

> [!warning] Comprendre réservation vs limite
> 
> - **Réservation (deploy.resources.reservations)** : Ressources garanties minimum
> - **Limite (deploy.resources.limits)** : Plafond maximum que le conteneur ne peut dépasser

---

## 🖥️ Limitation CPU

### Concepts fondamentaux

Docker utilise le CFS (Completely Fair Scheduler) du noyau Linux pour gérer l'allocation CPU. Les limitations peuvent être exprimées de plusieurs façons.

### Syntaxe et configuration

```yaml
services:
  webapp:
    image: nginx:latest
    deploy:
      resources:
        limits:
          cpus: '2.5'              # Maximum 2.5 cœurs CPU
        reservations:
          cpus: '1.0'              # Minimum 1 cœur garanti
    
  # Alternative avec cpu_count (nombre de cœurs)
  backend:
    image: myapp:latest
    deploy:
      resources:
        limits:
          cpus: '2'                # Équivalent à 2 cœurs complets
```

### Formats de valeur CPU

|Format|Description|Exemple|
|---|---|---|
|Décimal|Fraction de cœur|`'0.5'` = 50% d'un cœur|
|Entier|Nombre de cœurs|`'2'` = 2 cœurs complets|
|Notation|Pourcentage implicite|`'1.5'` = 1 cœur et demi|

### Configuration avancée avec cpu_shares

```yaml
services:
  service_prioritaire:
    image: postgres:15
    deploy:
      resources:
        reservations:
          cpus: '2'
    # cpu_shares définit la priorité relative (valeur par défaut: 1024)
    cpu_shares: 2048              # Priorité double par rapport à la normale
    
  service_secondaire:
    image: redis:7
    deploy:
      resources:
        reservations:
          cpus: '0.5'
    cpu_shares: 512               # Priorité moitié moindre
```

> [!info] Comment fonctionnent les cpu_shares ? Les cpu_shares ne limitent pas le CPU, mais définissent une priorité relative lors de la contention. Si le CPU est disponible, un conteneur peut utiliser plus que sa part.

### Affinité CPU (cpuset)

```yaml
services:
  # Épingler le conteneur à des cœurs CPU spécifiques
  realtime_app:
    image: myapp:latest
    cpuset: "0,1"                 # Utilise uniquement les cœurs 0 et 1
    deploy:
      resources:
        limits:
          cpus: '2'
          
  # Plage de cœurs
  batch_processor:
    image: processor:latest
    cpuset: "2-5"                 # Utilise les cœurs 2, 3, 4, 5
```

### Exemples pratiques

```yaml
version: '3.8'

services:
  # Application web avec CPU modéré
  frontend:
    image: react-app:latest
    deploy:
      resources:
        limits:
          cpus: '1.0'             # Max 1 cœur
        reservations:
          cpus: '0.25'            # Min 25% d'un cœur
    cpu_shares: 1024              # Priorité normale
    
  # Base de données avec forte demande CPU
  database:
    image: postgres:15
    deploy:
      resources:
        limits:
          cpus: '4.0'             # Max 4 cœurs
        reservations:
          cpus: '2.0'             # Min 2 cœurs garantis
    cpu_shares: 2048              # Priorité haute
    cpuset: "0-3"                 # Épinglé aux 4 premiers cœurs
    
  # Worker batch avec basse priorité
  worker:
    image: celery-worker:latest
    deploy:
      resources:
        limits:
          cpus: '2.0'
        reservations:
          cpus: '0.5'
    cpu_shares: 512               # Priorité basse
```

> [!tip] Astuce de dimensionnement Pour une application en production, commencez par observer l'utilisation CPU réelle avec `docker stats`, puis ajustez les limites avec une marge de 20-30%.

> [!warning] Pièges courants
> 
> - Ne pas confondre `cpus: '2'` avec `cpu_shares: 2` (unités différentes)
> - Les limites CPU trop strictes peuvent causer des timeouts applicatifs
> - Sur un système à 4 cœurs, limiter à `cpus: '5'` n'a aucun effet (plafonné au max système)
> - `cpuset` peut causer des problèmes de portabilité sur des machines avec moins de cœurs

---

## 💾 Limitation Mémoire

### Concepts fondamentaux

Docker permet de limiter la RAM et le swap pour éviter les situations d'out-of-memory (OOM) qui peuvent crasher l'hôte.

### Syntaxe de base

```yaml
services:
  webapp:
    image: nginx:latest
    deploy:
      resources:
        limits:
          memory: 512M            # Maximum 512 Mo de RAM
        reservations:
          memory: 256M            # Minimum 256 Mo garantis
```

### Unités de mesure

|Unité|Description|Exemple|
|---|---|---|
|`b`|Bytes|`1073741824b`|
|`k`|Kilobytes|`524288k`|
|`m`|Megabytes|`512m` ou `512M`|
|`g`|Gigabytes|`2g` ou `2G`|

### Configuration du swap

```yaml
services:
  # Désactiver complètement le swap
  api:
    image: fastapi:latest
    deploy:
      resources:
        limits:
          memory: 1G
    mem_swappiness: 0             # Désactive le swap (0-100)
    
  # Limiter swap et mémoire
  worker:
    image: worker:latest
    deploy:
      resources:
        limits:
          memory: 512M
    mem_swappiness: 10            # Utilisation minimale du swap
    memswap_limit: 1G             # Limite mémoire + swap = 1G (donc 512M de swap)
```

> [!info] Différence memory vs memswap_limit
> 
> - `memory` : Limite de RAM physique
> - `memswap_limit` : Limite de RAM + Swap combinés
> - Si `memswap_limit: 1G` et `memory: 512M`, alors swap max = 512M

### OOM Killer et comportement

```yaml
services:
  # Empêcher le conteneur d'être tué par OOM Killer
  critical_service:
    image: postgres:15
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
    oom_kill_disable: true        # ⚠️ Attention : peut impacter l'hôte
    
  # Ajuster la priorité OOM (défaut: 0)
  cache:
    image: redis:7
    deploy:
      resources:
        limits:
          memory: 512M
    oom_score_adj: 500            # Plus susceptible d'être tué (-1000 à 1000)
```

> [!warning] Attention avec oom_kill_disable Désactiver l'OOM Killer peut mettre en danger tout le système si le conteneur consomme trop de mémoire. À utiliser uniquement pour des services critiques avec une surveillance stricte.

### Réservation de mémoire Kernel

```yaml
services:
  database:
    image: postgres:15
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G
    # Réserver de la mémoire pour les opérations kernel (ex: TCP buffers)
    kernel_memory: 512M           # Limite mémoire kernel
```

### Exemples pratiques

```yaml
version: '3.8'

services:
  # Application Node.js avec V8 heap
  nodejs_app:
    image: node:18
    environment:
      NODE_OPTIONS: "--max-old-space-size=768"  # 768 MB pour V8
    deploy:
      resources:
        limits:
          memory: 1G              # Marge pour l'OS et autres processus
        reservations:
          memory: 512M
    mem_swappiness: 0
    
  # Cache Redis
  redis:
    image: redis:7
    command: redis-server --maxmemory 450mb --maxmemory-policy allkeys-lru
    deploy:
      resources:
        limits:
          memory: 512M            # Légèrement supérieur au maxmemory
        reservations:
          memory: 256M
    mem_swappiness: 0             # Critique pour les performances
    
  # Base de données PostgreSQL
  postgres:
    image: postgres:15
    environment:
      POSTGRES_SHARED_BUFFERS: 1GB
      POSTGRES_EFFECTIVE_CACHE_SIZE: 3GB
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G
    mem_swappiness: 10            # Swap minimal
    memswap_limit: 4G             # Pas de swap additionnel
    
  # Worker Celery avec tâches gourmandes
  celery_worker:
    image: celery:latest
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 512M
    oom_score_adj: 100            # Peut être tué en priorité si nécessaire
```

> [!tip] Dimensionnement mémoire **Règle du 80/20** : Si votre application utilise typiquement 400M, définissez la limite à 500-600M (marge de 25-50%). Pour les pics occasionnels, surveillez avec `docker stats`.

> [!example] Calcul de memswap_limit
> 
> ```yaml
> deploy:
>   resources:
>     limits:
>       memory: 1G
> memswap_limit: 1.5G
> # Résultat : 1G RAM + 500M Swap max
> ```
> 
> Si `memswap_limit` n'est pas défini, par défaut Docker autorise swap = 2 × memory.

### Surveillance et debugging

```bash
# Voir l'utilisation mémoire en temps réel
docker stats --no-stream

# Vérifier les événements OOM
docker inspect <container_id> | grep OOMKilled

# Logs kernel pour OOM
dmesg | grep -i "out of memory"
```

> [!warning] Pièges courants
> 
> - Ne pas aligner `memory` avec la configuration interne de l'app (ex: JVM `-Xmx`, Node `--max-old-space-size`)
> - Oublier que `memswap_limit` inclut la RAM (pas seulement le swap additionnel)
> - Définir des limites trop strictes qui causent des OOM fréquents
> - Utiliser `oom_kill_disable: true` sans monitoring adéquat

---

## 💿 Limitation I/O

### Concepts fondamentaux

Les limitations I/O contrôlent la bande passante de lecture/écriture sur les disques pour éviter qu'un conteneur sature les E/S et impacte les autres services.

### Limitation de débit (throughput)

```yaml
services:
  # Limiter la vitesse de lecture/écriture en bytes par seconde
  database:
    image: postgres:15
    deploy:
      resources:
        limits:
          # Note: blkio n'est pas dans deploy.resources mais à la racine
    blkio_config:
      # Limite de lecture
      device_read_bps:
        - path: /dev/sda           # Périphérique block
          rate: '50mb'             # 50 MB/s maximum
      # Limite d'écriture
      device_write_bps:
        - path: /dev/sda
          rate: '25mb'             # 25 MB/s maximum
```

### Limitation par opérations (IOPS)

```yaml
services:
  # Limiter le nombre d'opérations I/O par seconde
  mongodb:
    image: mongo:7
    blkio_config:
      # IOPS en lecture
      device_read_iops:
        - path: /dev/sda
          rate: 1000               # Max 1000 opérations lecture/sec
      # IOPS en écriture
      device_write_iops:
        - path: /dev/sda
          rate: 500                # Max 500 opérations écriture/sec
```

### Poids I/O (priorité relative)

```yaml
services:
  # Priorité haute pour la base de données
  postgres:
    image: postgres:15
    blkio_config:
      weight: 800                  # Poids entre 10-1000 (défaut: 500)
      
  # Priorité basse pour le service de backup
  backup:
    image: backup:latest
    blkio_config:
      weight: 100                  # Priorité basse
```

> [!info] Comment fonctionne le weight ? Similaire aux cpu_shares, le weight définit une priorité relative. Avec postgres (800) et backup (100), postgres obtient 8× plus de bande passante I/O lors de contention.

### Poids par périphérique

```yaml
services:
  database:
    image: postgres:15
    blkio_config:
      weight: 500                  # Poids global
      weight_device:
        - path: /dev/sda           # SSD rapide
          weight: 900              # Priorité haute sur ce device
        - path: /dev/sdb           # HDD lent
          weight: 300              # Priorité basse
```

### Exemples pratiques

```yaml
version: '3.8'

services:
  # Base de données principale avec I/O prioritaires
  postgres_primary:
    image: postgres:15
    volumes:
      - postgres_data:/var/lib/postgresql/data
    blkio_config:
      weight: 800                  # Priorité haute
      device_write_bps:
        - path: /dev/sda
          rate: '100mb'            # Écriture max 100 MB/s
      device_read_bps:
        - path: /dev/sda
          rate: '200mb'            # Lecture max 200 MB/s
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 4G
  
  # Service de logs avec I/O limité
  logging_service:
    image: fluentd:latest
    volumes:
      - logs:/var/log
    blkio_config:
      weight: 300                  # Priorité basse
      device_write_bps:
        - path: /dev/sda
          rate: '10mb'             # Max 10 MB/s en écriture
      device_write_iops:
        - path: /dev/sda
          rate: 100                # Max 100 IOPS écriture
  
  # Worker de traitement batch
  batch_worker:
    image: worker:latest
    blkio_config:
      weight: 500                  # Priorité normale
      device_read_iops:
        - path: /dev/sda
          rate: 2000               # Max 2000 IOPS lecture
      device_write_iops:
        - path: /dev/sda
          rate: 1000               # Max 1000 IOPS écriture
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
  
  # Service de backup avec throttling strict
  backup:
    image: backup:latest
    volumes:
      - postgres_data:/backup/postgres:ro
      - backup_target:/backup/target
    blkio_config:
      weight: 100                  # Priorité très basse
      device_read_bps:
        - path: /dev/sda           # Lecture données
          rate: '20mb'
      device_write_bps:
        - path: /dev/sdb           # Écriture backup
          rate: '30mb'
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M

volumes:
  postgres_data:
  logs:
  backup_target:
```

### Identifier les périphériques block

```bash
# Lister les périphériques block
lsblk

# Exemple de sortie:
# NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
# sda      8:0    0   500G  0 disk
# ├─sda1   8:1    0   499G  0 part /
# └─sda2   8:2    0     1G  0 part [SWAP]
# sdb      8:16   0     1T  0 disk /data

# Voir les périphériques montés
df -h

# Obtenir le chemin device d'un volume Docker
docker volume inspect <volume_name> | grep Mountpoint
```

### Configuration combinée avec cgroups v2

```yaml
services:
  # Configuration moderne avec cgroups v2
  service:
    image: myapp:latest
    blkio_config:
      weight: 600
      device_read_bps:
        - path: /dev/sda
          rate: '50mb'
    # Activer cgroups v2 pour des contrôles plus fins
    cgroup_parent: custom_cgroup
```

> [!warning] Support des limitations I/O Les limitations I/O dépendent du backend de stockage et de la version de cgroups :
> 
> - **Cgroups v1** : Support complet avec blkio controller
> - **Cgroups v2** : Support via io controller (syntaxe différente)
> - **Overlay2** : Support limité, fonctionne mieux avec device mapper
> - **Windows** : Support limité des limitations I/O

### Unités de mesure

|Unité|Description|Exemple|
|---|---|---|
|`b`|Bytes/seconde|`10485760b` = 10 MB/s|
|`k`, `kb`|Kilobytes/seconde|`10240kb` = 10 MB/s|
|`m`, `mb`|Megabytes/seconde|`10mb` = 10 MB/s|
|`g`, `gb`|Gigabytes/seconde|`1gb` = 1 GB/s|

> [!tip] Dimensionnement I/O Commencez par mesurer les I/O réelles avec `docker stats` et `iostat`. Pour une base de données, réservez 20-30% de bande passante supplémentaire pour les pics d'activité.

### Surveillance des I/O

```bash
# Voir les stats I/O en temps réel
docker stats --format "table {{.Container}}\t{{.BlockIO}}"

# Stats détaillées d'un conteneur
docker inspect <container_id> | grep -A 20 BlkioStats

# Utiliser iostat pour le système
iostat -x 1 10

# Voir les I/O par processus dans un conteneur
docker exec <container_id> iotop -o
```

> [!example] Calcul de throughput nécessaire Si votre base de données fait 1000 écritures/sec de 4KB en moyenne :
> 
> - Throughput = 1000 × 4KB = 4 MB/s minimum
> - Avec marge 50% : `device_write_bps: 6mb`
> - IOPS : `device_write_iops: 1500` (avec marge)

> [!warning] Pièges courants
> 
> - Les limitations I/O ne fonctionnent que sur les périphériques block physiques, pas sur les volumes tmpfs ou en mémoire
> - Le path doit pointer vers le device (`/dev/sda`), pas vers le point de montage (`/data`)
> - Sur des SSD NVMe, les chemins peuvent être `/dev/nvme0n1` au lieu de `/dev/sda`
> - Les limitations s'appliquent au conteneur, mais tous les processus du conteneur partagent cette limite
> - Certains drivers de stockage Docker (overlay2) contournent les limitations blkio

---

## 🎯 Bonnes Pratiques Générales

### Configuration équilibrée pour un stack complet

```yaml
version: '3.8'

services:
  # Load Balancer - ressources minimales
  nginx:
    image: nginx:alpine
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
        reservations:
          cpus: '0.25'
          memory: 64M
    blkio_config:
      weight: 300
  
  # Application web - ressources modérées
  webapp:
    image: webapp:latest
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1.5'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
    cpu_shares: 1024
    mem_swappiness: 10
    blkio_config:
      weight: 500
  
  # Base de données - ressources importantes
  postgres:
    image: postgres:15
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 4G
        reservations:
          cpus: '2'
          memory: 2G
    cpu_shares: 2048
    cpuset: "0-3"
    mem_swappiness: 0
    blkio_config:
      weight: 900
      device_write_bps:
        - path: /dev/sda
          rate: '100mb'
      device_read_bps:
        - path: /dev/sda
          rate: '200mb'
  
  # Cache - ressources moyennes avec éviction
  redis:
    image: redis:7
    command: redis-server --maxmemory 900mb --maxmemory-policy allkeys-lru
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '1'
          memory: 512M
    mem_swappiness: 0
    blkio_config:
      weight: 700
  
  # Worker background - priorité basse
  worker:
    image: celery:latest
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 256M
    cpu_shares: 512
    oom_score_adj: 200
    blkio_config:
      weight: 200
```

### Checklist de configuration

> [!tip] Checklist des ressources **CPU**
> 
> - ✅ Définir limits et reservations selon l'usage observé
> - ✅ Utiliser cpu_shares pour les priorités relatives
> - ✅ Réserver cpuset pour les services temps réel si nécessaire
> - ✅ Prévoir 20-30% de marge sur les limites
> 
> **Mémoire**
> 
> - ✅ Aligner memory limits avec la config applicative (JVM heap, Node max-old-space-size)
> - ✅ Désactiver swap (mem_swappiness: 0) pour les bases de données et caches
> - ✅ Configurer OOM score selon la criticité du service
> - ✅ Éviter oom_kill_disable sauf pour services critiques surveillés
> 
> **I/O**
> 
> - ✅ Identifier les périphériques block corrects avec lsblk
> - ✅ Utiliser weight pour la priorité relative entre services
> - ✅ Limiter throughput pour les services de backup/batch
> - ✅ Tester sur l'environnement cible (support cgroups, driver de stockage)

### Monitoring et ajustement

```yaml
services:
  # Service avec monitoring intégré
  monitored_app:
    image: myapp:latest
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
    # Labels pour monitoring (Prometheus, etc.)
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=9090"
    # Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

> [!tip] Stratégie d'optimisation progressive
> 
> 1. **Démarrer large** : Limites généreuses en développement
> 2. **Mesurer** : Utiliser `docker stats` pendant plusieurs jours en staging
> 3. **Analyser** : Identifier les pics et moyennes d'utilisation
> 4. **Ajuster** : Réduire progressivement avec marge de sécurité
> 5. **Tester** : Stress tests avec les nouvelles limites
> 6. **Monitorer** : Alertes sur utilisation > 80% des limites

### Anti-patterns à éviter

> [!warning] Erreurs fréquentes ❌ **Limites identiques pour tous les services**
> 
> ```yaml
> # Mauvais : même config pour tous
> x-resources: &resources
>   deploy:
>     resources:
>       limits:
>         cpus: '2'
>         memory: 2G
> ```
> 
> ✅ Adapter selon le profil de chaque service
> 
> ❌ **Limites trop strictes**
> 
> ```yaml
> # Mauvais : app Java avec heap 1G mais limite 1G
> webapp:
>   environment:
>     JAVA_OPTS: "-Xmx1024m"
>   deploy:
>     resources:
>       limits:
>         memory: 1G  # Pas de marge pour l'OS, métadata...
> ```
> 
> ✅ Prévoir 20-30% de marge : memory: 1.3G
> 
> ❌ **Oublier les reservations**
> 
> ```yaml
> # Mauvais : seulement des limites
> postgres:
>   deploy:
>     resources:
>       limits:
>         cpus: '4'
>         memory: 4G
>   # Pas de reservations = peut être starved
> ```
> 
> ✅ Définir reservations pour garantir les ressources minimales
> 
> ❌ **Mauvais path device I/O**
> 
> ```yaml
> # Mauvais : path vers montage au lieu de device
> blkio_config:
>   device_write_bps:
>     - path: /var/lib/docker  # ❌ Point de montage
>       rate: '50mb'
> ```
> 
> ✅ Utiliser le device block : path: /dev/sda

### Template de référence

```yaml
version: '3.8'

# Extension pour ressources réutilisables
x-resource-tiny: &resource-tiny
  deploy:
    resources:
      limits:
        cpus: '0.5'
        memory: 256M
      reservations:
        cpus: '0.25'
        memory: 128M

x-resource-small: &resource-small
  deploy:
    resources:
      limits:
        cpus: '1'
        memory: 512M
      reservations:
        cpus: '0.5'
        memory: 256M

x-resource-medium: &resource-medium
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
      reservations:
        cpus: '1'
        memory: 1G

x-resource-large: &resource-large
  deploy:
    resources:
      limits:
        cpus: '4'
        memory: 4G
      reservations:
        cpus: '2'
        memory: 2G

services:
  # Utilisation des templates
  nginx:
    image: nginx:alpine
    <<: *resource-tiny
    
  webapp:
    image: webapp:latest
    <<: *resource-medium
    
  database:
    image: postgres:15
    <<: *resource-large
    mem_swappiness: 0
    blkio_config:
      weight: 900
```

---

> [!info] Résumé La gestion des ressources Docker Compose repose sur trois piliers :
> 
> - **CPU** : Contrôle via `cpus`, `cpu_shares`, et `cpuset` pour répartir la puissance de calcul
> - **Mémoire** : Limites via `memory`, gestion du swap, et protection OOM pour la stabilité
> - **I/O** : Throttling via `blkio_config` pour éviter la saturation des disques
> 
> L'objectif est d'assurer des performances prévisibles, éviter les contentions, et garantir la qualité de service de votre infrastructure conteneurisée.