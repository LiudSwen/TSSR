

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

Par défaut, un conteneur Docker peut utiliser **toutes les ressources** disponibles sur l'hôte (CPU, RAM, I/O). Cela peut entraîner des problèmes graves : un conteneur mal configuré peut monopoliser les ressources et impacter les autres conteneurs ou l'hôte lui-même.

La limitation des ressources permet de :

- **Garantir la stabilité** du système en évitant qu'un conteneur consomme toutes les ressources
- **Assurer l'équité** entre conteneurs dans un environnement multi-conteneurs
- **Prévoir les coûts** et dimensionner correctement l'infrastructure
- **Reproduire les conditions de production** en développement

> [!info] Contrôle des ressources Docker utilise les **cgroups** (control groups) du noyau Linux pour limiter et isoler l'utilisation des ressources des conteneurs.

---

## 🔧 Limitation CPU

### Principe de fonctionnement

Docker permet de contrôler l'accès CPU d'un conteneur de plusieurs façons :

- Par **quota** : limiter le temps CPU disponible
- Par **parts** : définir la priorité relative entre conteneurs
- Par **affinité** : assigner des cœurs CPU spécifiques

### Options principales

#### `--cpus` : Limitation simple

Limite le nombre de cœurs CPU utilisables par le conteneur.

```bash
# Limiter à 1.5 cœurs CPU
docker run --cpus="1.5" nginx

# Limiter à 0.5 cœur (50% d'un cœur)
docker run --cpus="0.5" mon-app
```

> [!example] Exemple pratique
> 
> ```bash
> # Application peu gourmande : 0.5 CPU
> docker run -d --name web --cpus="0.5" nginx
> 
> # Base de données : 2 CPU
> docker run -d --name db --cpus="2" postgres
> ```

#### `--cpu-shares` : Priorité relative

Définit les **parts CPU** (poids relatif) par rapport aux autres conteneurs. Valeur par défaut : **1024**.

```bash
# Conteneur prioritaire : 2048 parts (2x plus de priorité)
docker run --cpu-shares=2048 app-prioritaire

# Conteneur normal : 1024 parts (valeur par défaut)
docker run --cpu-shares=1024 app-normale

# Conteneur basse priorité : 512 parts (2x moins de priorité)
docker run --cpu-shares=512 app-background
```

> [!warning] Attention Les `cpu-shares` ne sont appliquées que lorsqu'il y a **contention** (plusieurs conteneurs réclament du CPU). Si un seul conteneur tourne, il peut utiliser 100% du CPU disponible.

#### `--cpuset-cpus` : Affinité CPU

Assigne des cœurs CPU spécifiques au conteneur.

```bash
# Utiliser uniquement les cœurs 0 et 1
docker run --cpuset-cpus="0,1" mon-app

# Utiliser les cœurs 0 à 3
docker run --cpuset-cpus="0-3" mon-app

# Combinaison
docker run --cpuset-cpus="0,2-4" mon-app
```

> [!tip] Astuce Utile pour isoler des applications critiques sur des cœurs dédiés ou optimiser les performances sur des architectures NUMA.

#### Options avancées

```bash
# Période et quota CPU (microseconde)
# Limite : 50% d'un cœur (50000/100000)
docker run --cpu-period=100000 --cpu-quota=50000 mon-app

# Temps CPU en temps réel (nécessite des privilèges)
docker run --cap-add=SYS_NICE --cpu-rt-runtime=950000 --cpu-rt-period=1000000 app-realtime
```

### Syntaxe Docker Compose

```yaml
version: '3.8'

services:
  web:
    image: nginx
    deploy:
      resources:
        limits:
          cpus: '1.5'        # Maximum 1.5 cœurs
        reservations:
          cpus: '0.5'        # Minimum garanti
    cpuset: "0,1"            # Cœurs spécifiques (v2.x)
    cpu_shares: 1024         # Parts CPU

  db:
    image: postgres
    deploy:
      resources:
        limits:
          cpus: '2.0'
```

> [!info] Différence limits vs reservations
> 
> - **limits** : plafond maximum, le conteneur ne peut pas dépasser
> - **reservations** : ressources garanties, réservées pour le conteneur

### Vérification de l'utilisation

```bash
# Voir l'utilisation en temps réel
docker stats

# Statistiques d'un conteneur spécifique
docker stats mon-conteneur

# Format personnalisé
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

---

## 💾 Limitation Mémoire

### Principe de fonctionnement

Sans limitation, un conteneur peut consommer toute la RAM disponible et provoquer un **OOM (Out Of Memory)** qui peut tuer des processus de l'hôte. Docker permet de contrôler :

- La **mémoire RAM** allouée
- Le **swap** disponible
- Le comportement en cas de dépassement

### Options principales

#### `-m` ou `--memory` : Limitation RAM

Définit la quantité maximale de RAM utilisable.

```bash
# Limiter à 512 mégaoctets
docker run -m 512m nginx

# Limiter à 2 gigaoctets
docker run -m 2g mon-app

# Différentes unités : b, k, m, g
docker run -m 1024m mon-app  # = 1g
```

> [!warning] OOM Killer Si un conteneur dépasse sa limite mémoire, le **OOM killer** du noyau Linux peut tuer le processus principal du conteneur, provoquant son arrêt.

#### `--memory-swap` : Contrôle du swap

Définit la quantité totale de mémoire + swap utilisable.

```bash
# 512m RAM + 512m swap (total 1g)
docker run -m 512m --memory-swap=1g mon-app

# Désactiver complètement le swap
docker run -m 512m --memory-swap=512m mon-app

# Swap illimité (valeur par défaut si non spécifié)
docker run -m 512m --memory-swap=-1 mon-app
```

> [!info] Calcul du swap Le swap disponible = `--memory-swap` - `--memory`
> 
> Exemple : `--memory=512m --memory-swap=1g` → 512m de RAM + 512m de swap

#### `--memory-reservation` : Soft limit

Définit une limite "douce" (soft limit) : le conteneur peut dépasser cette limite si l'hôte a de la mémoire disponible.

```bash
# Réservation de 256m, mais peut utiliser plus si disponible
docker run -m 512m --memory-reservation=256m mon-app
```

#### `--oom-kill-disable` : Désactiver l'OOM killer

Empêche le système de tuer le conteneur en cas de dépassement mémoire.

```bash
# Désactiver l'OOM killer (dangereux !)
docker run -m 512m --oom-kill-disable mon-app
```

> [!warning] Danger N'utilisez `--oom-kill-disable` que si vous avez aussi défini une limite mémoire stricte avec `-m`, sinon le conteneur peut bloquer tout le système.

#### `--oom-score-adj` : Priorité OOM

Ajuste la priorité du conteneur pour l'OOM killer (-1000 à 1000). Plus la valeur est élevée, plus le processus sera tué en priorité.

```bash
# Priorité basse : sera tué en dernier
docker run --oom-score-adj=-500 app-critique

# Priorité haute : sera tué en premier
docker run --oom-score-adj=500 app-temporaire
```

### Syntaxe Docker Compose

```yaml
version: '3.8'

services:
  web:
    image: nginx
    deploy:
      resources:
        limits:
          memory: 512M        # Maximum 512 Mo
        reservations:
          memory: 256M        # Minimum garanti
    mem_swappiness: 0         # Tendance à utiliser le swap (0-100)
    
  db:
    image: postgres
    deploy:
      resources:
        limits:
          memory: 2G
    memswap_limit: 2G         # Désactive le swap
    oom_kill_disable: false   # Autoriser l'OOM killer
    oom_score_adj: -100       # Priorité basse pour l'OOM
```

### Vérification de l'utilisation

```bash
# Voir l'utilisation mémoire en temps réel
docker stats

# Détails mémoire d'un conteneur
docker inspect mon-conteneur | grep -i memory

# Événements OOM
docker events --filter event=oom

# Logs du système pour OOM
dmesg | grep -i "out of memory"
```

---

## 💿 Limitation I/O

### Principe de fonctionnement

Sans limitation, un conteneur peut saturer les I/O disque et ralentir tout le système. Docker permet de contrôler :

- Le **débit** de lecture/écriture (throughput)
- Le **nombre d'opérations** par seconde (IOPS)
- L'accès à des **périphériques** spécifiques

### Options principales

#### Limitation du débit (throughput)

```bash
# Limiter la lecture à 10 Mo/s
docker run --device-read-bps /dev/sda:10mb mon-app

# Limiter l'écriture à 5 Mo/s
docker run --device-write-bps /dev/sda:5mb mon-app

# Combiner les deux
docker run \
  --device-read-bps /dev/sda:10mb \
  --device-write-bps /dev/sda:5mb \
  mon-app
```

> [!info] Unités disponibles
> 
> - `kb` : kilooctets par seconde
> - `mb` : mégaoctets par seconde
> - `gb` : gigaoctets par seconde

#### Limitation des IOPS

```bash
# Limiter à 1000 opérations de lecture par seconde
docker run --device-read-iops /dev/sda:1000 mon-app

# Limiter à 500 opérations d'écriture par seconde
docker run --device-write-iops /dev/sda:500 mon-app

# Combiner
docker run \
  --device-read-iops /dev/sda:1000 \
  --device-write-iops /dev/sda:500 \
  mon-app
```

#### Poids I/O (blkio-weight)

Définit la priorité relative d'accès aux I/O (10-1000, défaut : 500).

```bash
# Priorité haute pour la base de données
docker run --blkio-weight 800 postgres

# Priorité normale
docker run --blkio-weight 500 mon-app

# Priorité basse pour les backups
docker run --blkio-weight 200 backup-job
```

> [!warning] Limitation Le `blkio-weight` fonctionne uniquement avec certains **schedulers I/O** du noyau Linux (CFQ). Avec les schedulers modernes (mq-deadline, none), cette option peut ne pas avoir d'effet.

#### Poids I/O par périphérique

```bash
# Poids différents selon le disque
docker run --blkio-weight-device /dev/sda:800 --blkio-weight-device /dev/sdb:200 mon-app
```

### Syntaxe Docker Compose

```yaml
version: '3.8'

services:
  db:
    image: postgres
    deploy:
      resources:
        limits:
          # Pas de support natif pour I/O dans deploy
          # Utiliser device_* à la racine du service
    device_read_bps:
      - path: /dev/sda
        rate: '10mb'
    device_write_bps:
      - path: /dev/sda
        rate: '5mb'
    device_read_iops:
      - path: /dev/sda
        rate: 1000
    device_write_iops:
      - path: /dev/sda
        rate: 500
    blkio_config:
      weight: 800
      weight_device:
        - path: /dev/sda
          weight: 800
```

### Vérification de l'utilisation

```bash
# Statistiques I/O en temps réel
docker stats --format "table {{.Name}}\t{{.BlockIO}}"

# Détails I/O d'un conteneur
docker inspect mon-conteneur | grep -i blkio

# I/O au niveau système (iotop nécessaire)
sudo iotop -o

# Statistiques par périphérique
iostat -x 1
```

> [!tip] Astuce avancée Pour un contrôle I/O plus fin, utilisez les **volumes** avec des options de montage spécifiques ou configurez des **quotas filesystem** sur l'hôte.

---

## ⚠️ Pièges courants

### 1. Oublier de limiter les ressources en production

```bash
# ❌ Mauvais : aucune limite
docker run -d nginx

# ✅ Bon : limites appropriées
docker run -d --cpus="1" -m 512m nginx
```

> [!warning] Impact Un conteneur sans limite peut monopoliser toutes les ressources et faire tomber l'hôte entier.

### 2. Limites trop restrictives

```bash
# ❌ Trop restrictif pour une base de données
docker run -d --cpus="0.1" -m 128m postgres

# ✅ Dimensionnement approprié
docker run -d --cpus="2" -m 4g postgres
```

> [!tip] Conseil Utilisez `docker stats` en environnement de test pour observer la consommation réelle avant de fixer les limites définitives.

### 3. Confondre --memory-swap et swap disponible

```bash
# ❌ Erreur : 1g de swap (pas 500m)
docker run -m 512m --memory-swap=1g mon-app

# ✅ Correct : 512m RAM + 500m swap
docker run -m 512m --memory-swap=1012m mon-app
```

### 4. Désactiver l'OOM killer sans limite mémoire

```bash
# ❌ Dangereux : peut bloquer tout le système
docker run --oom-kill-disable mon-app

# ✅ Sécurisé : limite mémoire + OOM désactivé
docker run -m 1g --oom-kill-disable mon-app
```

### 5. Ignorer les reservations en orchestration

```yaml
# ❌ Seulement des limits : pas de garantie
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G

# ✅ Limits ET reservations : ressources garanties
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 256M
```

### 6. Négliger le monitoring

```bash
# ✅ Toujours surveiller l'utilisation
docker stats --no-stream > stats.log

# ✅ Configurer des alertes
docker events --filter event=oom --format '{{.Time}} {{.Status}}' &
```

### 7. Limitations I/O inefficaces sur les SSD modernes

> [!info] À savoir Les limitations I/O traditionnelles (`blkio-weight`) fonctionnent mal avec les schedulers I/O modernes (BFQ, mq-deadline) utilisés par les SSD NVMe. Privilégiez les limitations de débit (`device-read-bps`, `device-write-bps`).

---

## 🎯 Bonnes pratiques

### Définir des limites par défaut

```bash
# Dans /etc/docker/daemon.json
{
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
```

### Utiliser des profils de ressources

```yaml
# Profil "small" pour les microservices
x-resources-small: &small-resources
  deploy:
    resources:
      limits:
        cpus: '0.5'
        memory: 512M
      reservations:
        cpus: '0.25'
        memory: 256M

services:
  api:
    <<: *small-resources
    image: mon-api
```

### Tester progressivement

1. **Développement** : pas de limites (observation)
2. **Staging** : limites larges + monitoring
3. **Production** : limites ajustées selon les métriques observées

### Documenter les besoins

```yaml
services:
  db:
    image: postgres:15
    # Ressources basées sur :
    # - 1000 requêtes/sec en pic
    # - Dataset de 50 Go
    # - Tests de charge du 15/12/2024
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
```

> [!tip] Astuce finale Les limitations de ressources sont essentielles pour la stabilité, mais elles ne remplacent pas une architecture bien conçue. Optimisez d'abord votre application avant de simplement augmenter les ressources allouées.

---