

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

La gestion des volumes Docker est essentielle pour maintenir la persistance des données de vos conteneurs. Docker fournit un ensemble de commandes dédiées pour créer, lister, inspecter et supprimer les volumes de manière efficace.

> [!info] Pourquoi gérer les volumes ? Les volumes peuvent rapidement s'accumuler et consommer de l'espace disque. Une bonne gestion permet de :
> 
> - Maintenir un environnement propre et organisé
> - Éviter la saturation du disque
> - Faciliter la sauvegarde et la restauration des données
> - Améliorer les performances globales

---

## 📦 docker volume create

### Définition

La commande `docker volume create` permet de créer explicitement un nouveau volume avant de l'utiliser avec un conteneur.

### Pourquoi créer des volumes manuellement ?

- **Contrôle** : Vous choisissez le nom du volume plutôt que d'avoir un nom généré automatiquement
- **Configuration** : Possibilité de spécifier des drivers et options spécifiques
- **Préparation** : Créer les volumes avant le déploiement des conteneurs
- **Organisation** : Meilleure traçabilité et documentation de votre infrastructure

### Syntaxe de base

```bash
docker volume create [OPTIONS] [VOLUME_NAME]
```

### Exemples pratiques

```bash
# Créer un volume avec un nom simple
docker volume create mon_volume

# Créer un volume avec des labels pour l'organisation
docker volume create --label projet=web --label environnement=production db_prod

# Créer un volume avec un driver spécifique
docker volume create --driver local --opt type=none --opt device=/home/user/data --opt o=bind mon_volume_local

# Créer un volume avec des options de montage
docker volume create --opt type=tmpfs --opt device=tmpfs --opt o=size=100m,uid=1000 volume_tmpfs
```

### Options principales

|Option|Description|Exemple|
|---|---|---|
|`--driver` ou `-d`|Spécifie le driver de volume|`--driver local`|
|`--label`|Ajoute des métadonnées au volume|`--label env=prod`|
|`--name`|Nom du volume (peut être omis)|`--name mon_volume`|
|`--opt` ou `-o`|Options spécifiques au driver|`--opt type=nfs`|

> [!example] Cas d'usage réel
> 
> ```bash
> # Créer un volume pour une base de données PostgreSQL
> docker volume create --label app=postgres --label backup=daily postgres_data
> 
> # Utiliser ensuite le volume avec un conteneur
> docker run -d --name postgres_db -v postgres_data:/var/lib/postgresql/data postgres:15
> ```

> [!tip] Astuce de nommage Adoptez une convention de nommage cohérente :
> 
> - `{projet}_{service}_{type}` : `ecommerce_mysql_data`
> - `{env}_{service}_vol` : `prod_redis_vol`
> - Utilisez des labels pour ajouter des métadonnées supplémentaires

> [!warning] Attention Si vous créez un volume sans spécifier de nom, Docker générera un nom aléatoire (hash). Préférez toujours nommer explicitement vos volumes pour faciliter leur gestion.

---

## 📋 docker volume ls

### Définition

La commande `docker volume ls` liste tous les volumes présents sur votre système Docker.

### Pourquoi lister les volumes ?

- **Audit** : Visualiser tous les volumes existants
- **Recherche** : Trouver un volume spécifique
- **Nettoyage** : Identifier les volumes orphelins ou inutilisés
- **Monitoring** : Surveiller l'évolution du nombre de volumes

### Syntaxe de base

```bash
docker volume ls [OPTIONS]
```

### Exemples pratiques

```bash
# Lister tous les volumes
docker volume ls

# Lister uniquement les noms des volumes (format personnalisé)
docker volume ls --format "{{.Name}}"

# Lister avec des informations détaillées
docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"

# Filtrer les volumes par label
docker volume ls --filter "label=environnement=production"

# Filtrer les volumes dangling (non utilisés par un conteneur)
docker volume ls --filter "dangling=true"

# Filtrer par driver
docker volume ls --filter "driver=local"

# Filtrer par nom (expression régulière)
docker volume ls --filter "name=postgres"
```

### Options principales

|Option|Description|Exemple|
|---|---|---|
|`--filter` ou `-f`|Filtre les résultats|`--filter "dangling=true"`|
|`--format`|Format de sortie personnalisé|`--format "{{.Name}}"`|
|`--quiet` ou `-q`|Affiche uniquement les noms|`-q`|

### Filtres disponibles

|Filtre|Description|Exemple|
|---|---|---|
|`dangling`|Volumes non attachés à un conteneur|`dangling=true`|
|`driver`|Filtre par driver|`driver=local`|
|`label`|Filtre par label|`label=env=prod`|
|`name`|Filtre par nom (regex)|`name=^postgres`|

> [!example] Cas d'usage réel
> 
> ```bash
> # Trouver tous les volumes de production
> docker volume ls --filter "label=environnement=production"
> 
> # Lister les volumes non utilisés pour un nettoyage
> docker volume ls --filter "dangling=true" --quiet
> 
> # Afficher un tableau formaté avec toutes les infos importantes
> docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Labels}}"
> ```

> [!tip] Format personnalisé Variables disponibles pour `--format` :
> 
> - `{{.Name}}` : Nom du volume
> - `{{.Driver}}` : Driver utilisé
> - `{{.Labels}}` : Labels associés
> - `{{.Scope}}` : Portée (local/global)
> - `{{.Mountpoint}}` : Point de montage sur l'hôte

> [!warning] Volumes dangling Les volumes "dangling" sont des volumes qui ne sont plus attachés à aucun conteneur. Ils peuvent être supprimés en toute sécurité, mais vérifiez d'abord qu'ils ne contiennent pas de données importantes !

---

## 🔍 docker volume inspect

### Définition

La commande `docker volume inspect` affiche des informations détaillées sur un ou plusieurs volumes.

### Pourquoi inspecter les volumes ?

- **Débogage** : Comprendre pourquoi un volume ne fonctionne pas comme prévu
- **Vérification** : Contrôler la configuration d'un volume
- **Documentation** : Récupérer les métadonnées et labels
- **Localisation** : Trouver l'emplacement physique des données sur l'hôte

### Syntaxe de base

```bash
docker volume inspect [OPTIONS] VOLUME [VOLUME...]
```

### Exemples pratiques

```bash
# Inspecter un volume spécifique
docker volume inspect mon_volume

# Inspecter plusieurs volumes en une seule commande
docker volume inspect postgres_data redis_data mysql_data

# Extraire uniquement le point de montage
docker volume inspect --format '{{.Mountpoint}}' mon_volume

# Extraire les labels
docker volume inspect --format '{{.Labels}}' mon_volume

# Extraire le driver
docker volume inspect --format '{{.Driver}}' mon_volume

# Vérifier la date de création
docker volume inspect --format '{{.CreatedAt}}' mon_volume

# Affichage formaté pour plusieurs informations
docker volume inspect --format 'Nom: {{.Name}} | Driver: {{.Driver}} | Point de montage: {{.Mountpoint}}' mon_volume
```

### Structure de la sortie JSON

```json
[
    {
        "CreatedAt": "2024-01-15T10:30:45Z",
        "Driver": "local",
        "Labels": {
            "environnement": "production",
            "projet": "ecommerce"
        },
        "Mountpoint": "/var/lib/docker/volumes/mon_volume/_data",
        "Name": "mon_volume",
        "Options": {},
        "Scope": "local"
    }
]
```

### Champs principaux

|Champ|Description|
|---|---|
|`CreatedAt`|Date et heure de création du volume|
|`Driver`|Driver utilisé (local, nfs, etc.)|
|`Labels`|Métadonnées sous forme de paires clé-valeur|
|`Mountpoint`|Emplacement physique sur l'hôte|
|`Name`|Nom du volume|
|`Options`|Options spécifiques au driver|
|`Scope`|Portée du volume (local ou global)|

> [!example] Cas d'usage réel
> 
> ```bash
> # Vérifier où sont stockées physiquement les données
> docker volume inspect --format '{{.Mountpoint}}' postgres_data
> # Output: /var/lib/docker/volumes/postgres_data/_data
> 
> # Créer un script de sauvegarde basé sur l'emplacement
> BACKUP_SOURCE=$(docker volume inspect --format '{{.Mountpoint}}' mon_volume)
> tar -czf backup_$(date +%Y%m%d).tar.gz "$BACKUP_SOURCE"
> 
> # Lister tous les volumes d'un projet spécifique
> for vol in $(docker volume ls -q); do
>   project=$(docker volume inspect --format '{{.Labels.projet}}' "$vol" 2>/dev/null)
>   if [ "$project" = "ecommerce" ]; then
>     echo "$vol - $(docker volume inspect --format '{{.Mountpoint}}' "$vol")"
>   fi
> done
> ```

> [!tip] Extraction d'informations avec jq Pour un traitement plus avancé, utilisez `jq` :
> 
> ```bash
> # Installer jq si nécessaire: sudo apt install jq
> 
> # Extraire toutes les informations de manière structurée
> docker volume inspect mon_volume | jq '.[0]'
> 
> # Extraire uniquement les labels
> docker volume inspect mon_volume | jq '.[0].Labels'
> 
> # Vérifier si un volume a un label spécifique
> docker volume inspect mon_volume | jq '.[0].Labels.environnement'
> ```

> [!warning] Accès au Mountpoint Le `Mountpoint` est un chemin système qui nécessite généralement des privilèges root pour y accéder. Sur certains systèmes (Docker Desktop), ce chemin peut être à l'intérieur d'une VM et non directement accessible.

---

## 🗑️ docker volume rm

### Définition

La commande `docker volume rm` supprime un ou plusieurs volumes Docker.

### Pourquoi supprimer des volumes ?

- **Nettoyage** : Libérer de l'espace disque
- **Maintenance** : Supprimer des volumes obsolètes ou corrompus
- **Réinitialisation** : Repartir de zéro pour certains services
- **Gestion des coûts** : Réduire l'utilisation de stockage dans le cloud

### Syntaxe de base

```bash
docker volume rm [OPTIONS] VOLUME [VOLUME...]
```

### Exemples pratiques

```bash
# Supprimer un volume unique
docker volume rm mon_volume

# Supprimer plusieurs volumes en une commande
docker volume rm postgres_data redis_data mysql_data

# Supprimer avec confirmation forcée (sans prompt)
docker volume rm --force mon_volume

# Supprimer tous les volumes dangling
docker volume rm $(docker volume ls -q --filter "dangling=true")

# Supprimer tous les volumes d'un projet spécifique (avec prudence !)
docker volume rm $(docker volume ls -q --filter "label=projet=test")
```

### Options principales

|Option|Description|
|---|---|
|`--force` ou `-f`|Force la suppression sans confirmation|

> [!example] Cas d'usage réel
> 
> ```bash
> # Workflow de nettoyage sécurisé
> # 1. Lister les volumes non utilisés
> docker volume ls --filter "dangling=true"
> 
> # 2. Vérifier ce qu'ils contiennent (si accessible)
> docker volume inspect volume_suspect
> 
> # 3. Supprimer après vérification
> docker volume rm volume_suspect
> 
> # Suppression conditionnelle avec vérification
> for vol in $(docker volume ls -q); do
>   # Vérifier si le volume est utilisé
>   if ! docker ps -a --filter volume="$vol" --format '{{.Names}}' | grep -q .; then
>     echo "Volume $vol non utilisé, suppression..."
>     docker volume rm "$vol"
>   fi
> done
> ```

> [!warning] Attention - Perte de données irréversible **La suppression d'un volume est définitive et irréversible !**
> 
> - Toutes les données contenues dans le volume seront perdues
> - Aucun moyen de récupération natif dans Docker
> - Vérifiez TOUJOURS qu'aucun conteneur n'utilise le volume
> - Effectuez une sauvegarde si les données sont importantes

> [!tip] Vérification avant suppression
> 
> ```bash
> # Vérifier si un volume est utilisé par un conteneur
> docker ps -a --filter volume=mon_volume --format '{{.Names}}'
> 
> # Si la commande ne retourne rien, le volume n'est pas utilisé
> # Sinon, elle affichera les noms des conteneurs utilisant ce volume
> ```

### Erreurs courantes

```bash
# Erreur : Volume en cours d'utilisation
$ docker volume rm postgres_data
Error response from daemon: remove postgres_data: volume is in use - [abc123def456]

# Solution : Arrêter et supprimer d'abord le conteneur
docker stop abc123def456
docker rm abc123def456
docker volume rm postgres_data

# Ou forcer la suppression du conteneur avec le volume
docker rm -f -v abc123def456
docker volume rm postgres_data
```

> [!tip] Suppression en masse intelligente
> 
> ```bash
> # Créer une fonction pour supprimer les volumes de manière sécurisée
> safe_volume_rm() {
>   local volume_name=$1
>   local containers=$(docker ps -aq --filter volume="$volume_name")
>   
>   if [ -z "$containers" ]; then
>     echo "Suppression du volume $volume_name..."
>     docker volume rm "$volume_name"
>   else
>     echo "ATTENTION: Volume $volume_name utilisé par des conteneurs"
>     docker ps -a --filter volume="$volume_name" --format 'table {{.Names}}\t{{.Status}}'
>   fi
> }
> 
> # Utilisation
> safe_volume_rm mon_volume
> ```

---

## 🧹 docker volume prune

### Définition

La commande `docker volume prune` supprime tous les volumes non utilisés (dangling) en une seule opération.

### Pourquoi utiliser prune ?

- **Efficacité** : Nettoyer rapidement tous les volumes orphelins
- **Automatisation** : Intégrer facilement dans des scripts de maintenance
- **Espace disque** : Récupérer de l'espace sans identifier manuellement chaque volume
- **Simplicité** : Une seule commande au lieu de supprimer volume par volume

### Syntaxe de base

```bash
docker volume prune [OPTIONS]
```

### Exemples pratiques

```bash
# Nettoyer tous les volumes non utilisés (avec confirmation)
docker volume prune

# Nettoyer sans demander de confirmation
docker volume prune --force

# Nettoyer uniquement les volumes correspondant à un filtre
docker volume prune --filter "label=environnement=test"

# Nettoyer les volumes de plus de 24h non utilisés
docker volume prune --filter "until=24h"

# Nettoyer avec affichage de l'espace récupéré
docker volume prune -f --verbose
```

### Options principales

|Option|Description|Exemple|
|---|---|---|
|`--all` ou `-a`|Supprime TOUS les volumes (utilisés ou non) ⚠️|`--all`|
|`--filter`|Filtre les volumes à supprimer|`--filter "label!=keep"`|
|`--force` ou `-f`|Supprime sans confirmation|`-f`|

### Filtres disponibles

|Filtre|Description|Exemple|
|---|---|---|
|`label`|Filtre par label|`label=environnement=dev`|
|`label!`|Exclut un label|`label!=important`|
|`until`|Volumes créés avant une durée|`until=24h`, `until=2023-01-01`|

> [!example] Cas d'usage réel
> 
> ```bash
> # Nettoyage de maintenance hebdomadaire
> # Supprimer les volumes de test de plus d'une semaine
> docker volume prune --filter "label=environnement=test" --filter "until=168h" -f
> 
> # Nettoyage avant déploiement
> # Supprimer tous les volumes dangling avant un nouveau build
> docker volume prune -f
> 
> # Script de nettoyage automatisé (cron job)
> #!/bin/bash
> # Sauvegarde de l'espace avant nettoyage
> AVANT=$(df -h / | tail -1 | awk '{print $4}')
> 
> # Nettoyage des volumes
> docker volume prune -f
> 
> # Espace après nettoyage
> APRES=$(df -h / | tail -1 | awk '{print $4}')
> 
> echo "Espace libéré : $AVANT -> $APRES"
> 
> # Ajouter au crontab : 0 3 * * 0 /path/to/script.sh
> ```

> [!warning] Danger avec --all **L'option `--all` supprime TOUS les volumes, même ceux utilisés par des conteneurs arrêtés !**
> 
> ```bash
> # ⚠️ DANGEREUX - Supprime TOUS les volumes
> docker volume prune --all -f
> 
> # Même les volumes de conteneurs arrêtés mais non supprimés seront perdus
> # N'utilisez cette option que si vous êtes absolument certain de ce que vous faites
> ```

### Comprendre "dangling" vs "unused"

```bash
# Volume "dangling" (par défaut avec prune)
# - Créé mais jamais attaché à un conteneur, OU
# - Conteneur supprimé, volume orphelin

# Volume "unused" (avec --all)
# - N'est pas monté dans un conteneur EN COURS D'EXÉCUTION
# - Peut être attaché à un conteneur arrêté
```

> [!tip] Prévention des suppressions accidentelles
> 
> ```bash
> # Protéger des volumes importants avec un label
> docker volume create --label keep=true postgres_prod_data
> 
> # Nettoyer en excluant les volumes protégés
> docker volume prune --filter "label!=keep"
> 
> # Alternative : créer un alias sécurisé
> alias docker-clean='docker volume prune --filter "label!=important" -f'
> ```

### Intégration dans un workflow CI/CD

```bash
# Script de nettoyage pour CI/CD
#!/bin/bash

# Nettoyer avant les tests
echo "🧹 Nettoyage des volumes de test..."
docker volume prune --filter "label=ci=true" -f

# Exécuter les tests
./run-tests.sh

# Nettoyer après les tests
echo "🧹 Nettoyage post-tests..."
docker volume prune --filter "label=ci=true" -f

# Statistiques
echo "📊 Volumes restants:"
docker volume ls
```

> [!example] Monitoring de l'espace disque
> 
> ```bash
> # Script de surveillance avec alerte
> #!/bin/bash
> 
> # Seuil d'utilisation (80%)
> SEUIL=80
> 
> # Vérifier l'utilisation du disque
> UTILISATION=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
> 
> if [ "$UTILISATION" -gt "$SEUIL" ]; then
>   echo "⚠️  Disque à ${UTILISATION}% - Nettoyage des volumes..."
>   
>   # Afficher ce qui sera supprimé
>   docker volume ls --filter "dangling=true"
>   
>   # Nettoyer
>   docker volume prune -f
>   
>   # Vérifier l'amélioration
>   APRES=$(df / | tail -1 | awk '{print $5}')
>   echo "✅ Utilisation après nettoyage: $APRES"
> else
>   echo "✅ Espace disque OK (${UTILISATION}%)"
> fi
> ```

---

## ✅ Bonnes pratiques

### 🏷️ Nommage et organisation

```bash
# Convention de nommage claire
docker volume create projet_service_environnement_data
# Exemples:
# - ecommerce_postgres_prod_data
# - blog_redis_dev_cache
# - api_mysql_staging_db

# Utiliser des labels pour l'organisation
docker volume create \
  --label projet=ecommerce \
  --label service=postgres \
  --label environnement=production \
  --label backup=daily \
  --label owner=team-backend \
  ecommerce_postgres_prod_data
```

### 🔍 Audit régulier

```bash
# Script d'audit hebdomadaire
#!/bin/bash

echo "=== AUDIT DES VOLUMES DOCKER ==="
echo ""

# Volumes totaux
TOTAL=$(docker volume ls -q | wc -l)
echo "📦 Volumes totaux: $TOTAL"

# Volumes dangling
DANGLING=$(docker volume ls -qf "dangling=true" | wc -l)
echo "🔴 Volumes dangling: $DANGLING"

# Espace utilisé par les volumes
ESPACE=$(du -sh /var/lib/docker/volumes 2>/dev/null | awk '{print $1}')
echo "💾 Espace total utilisé: $ESPACE"

# Volumes par environnement
echo ""
echo "📊 Répartition par environnement:"
for env in production staging development test; do
  COUNT=$(docker volume ls -q --filter "label=environnement=$env" | wc -l)
  echo "  - $env: $COUNT volumes"
done
```

### 🛡️ Protection des données critiques

```bash
# Toujours labelliser les volumes critiques
docker volume create \
  --label critical=true \
  --label backup=required \
  --label retention=permanent \
  production_database

# Script de sauvegarde automatique
#!/bin/bash
for vol in $(docker volume ls -q --filter "label=backup=required"); do
  MOUNTPOINT=$(docker volume inspect --format '{{.Mountpoint}}' "$vol")
  BACKUP_FILE="backup_${vol}_$(date +%Y%m%d_%H%M%S).tar.gz"
  
  echo "💾 Sauvegarde de $vol..."
  tar -czf "/backups/$BACKUP_FILE" -C "$MOUNTPOINT" .
done
```

### 🔄 Automatisation du nettoyage

```bash
# Créer un service systemd pour le nettoyage automatique
# /etc/systemd/system/docker-volume-cleanup.service

[Unit]
Description=Docker Volume Cleanup
After=docker.service

[Service]
Type=oneshot
ExecStart=/usr/bin/docker volume prune --filter "label!=critical" -f

[Install]
WantedBy=multi-user.target

# /etc/systemd/system/docker-volume-cleanup.timer

[Unit]
Description=Docker Volume Cleanup Timer

[Timer]
OnCalendar=Sun *-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target

# Activer le timer
# sudo systemctl enable docker-volume-cleanup.timer
# sudo systemctl start docker-volume-cleanup.timer
```

### 📝 Documentation et traçabilité

```bash
# Documenter les volumes avec des labels détaillés
docker volume create \
  --label description="Base de données principale de l'application e-commerce" \
  --label created-by="DevOps Team" \
  --label created-date="2024-01-15" \
  --label contact="devops@exemple.com" \
  --label documentation="https://wiki.exemple.com/volumes/ecommerce-db" \
  ecommerce_main_db

# Générer un rapport de documentation
#!/bin/bash
echo "# Documentation des volumes Docker" > volumes_report.md
echo "" >> volumes_report.md

for vol in $(docker volume ls -q); do
  echo "## $vol" >> volumes_report.md
  docker volume inspect "$vol" --format \
    '- **Driver**: {{.Driver}}
- **Créé le**: {{.CreatedAt}}
- **Labels**: {{.Labels}}
- **Mountpoint**: {{.Mountpoint}}' >> volumes_report.md
  echo "" >> volumes_report.md
done
```

### 🎯 Stratégie de rétention

```bash
# Définir des politiques de rétention avec des labels
# Permanent
docker volume create --label retention=permanent prod_data

# 90 jours
docker volume create --label retention=90days --label expires=$(date -d '+90 days' +%Y-%m-%d) staging_data

# 7 jours
docker volume create --label retention=7days --label expires=$(date -d '+7 days' +%Y-%m-%d) test_data

# Script de nettoyage basé sur la rétention
#!/bin/bash
TODAY=$(date +%Y-%m-%d)

for vol in $(docker volume ls -q); do
  EXPIRES=$(docker volume inspect --format '{{.Labels.expires}}' "$vol" 2>/dev/null)
  
  if [ ! -z "$EXPIRES" ] && [[ "$EXPIRES" < "$TODAY" ]]; then
    echo "🗑️  Volume $vol expiré (date: $EXPIRES)"
    docker volume rm "$vol"
  fi
done
```

### 🔐 Sécurité

```bash
# Restreindre l'accès aux montpoints (sur l'hôte)
MOUNTPOINT=$(docker volume inspect --format '{{.Mountpoint}}' secure_volume)
sudo chmod 700 "$MOUNTPOINT"
sudo chown root:root "$MOUNTPOINT"

# Créer des volumes chiffrés (nécessite des plugins spécifiques)
docker volume create \
  --driver local \
  --opt type=tmpfs \
  --opt device=tmpfs \
  --opt o=size=100m,encryption=aes256 \
  secure_temp_volume
```

### 📊 Monitoring de l'utilisation

```bash
# Script de monitoring de la taille des volumes
#!/bin/bash

echo "=== TAILLE DES VOLUMES ==="
printf "%-40s %15s\n" "VOLUME" "TAILLE"
echo "-------------------------------------------------------"

for vol in $(docker volume ls -q); do
  MOUNTPOINT=$(docker volume inspect --format '{{.Mountpoint}}' "$vol" 2>/dev/null)
  if [ -d "$MOUNTPOINT" ]; then
    SIZE=$(sudo du -sh "$MOUNTPOINT" 2>/dev/null | awk '{print $1}')
    printf "%-40s %15s\n" "$vol" "$SIZE"
  fi
done | sort -k2 -h -r

echo "-------------------------------------------------------"
TOTAL=$(sudo du -sh /var/lib/docker/volumes 2>/dev/null | awk '{print $1}')
echo "TOTAL: $TOTAL"
```

> [!tip] Checklist de maintenance mensuelle
> 
> - [ ] Auditer tous les volumes avec `docker volume ls`
> - [ ] Identifier les volumes dangling
> - [ ] Vérifier l'espace disque utilisé
> - [ ] Sauvegarder les volumes critiques
> - [ ] Nettoyer les volumes obsolètes
> - [ ] Vérifier les labels et la documentation
> - [ ] Tester la restauration d'une sauvegarde
> - [ ] Mettre à jour la documentation

---

> [!info] Résumé des commandes essentielles
> 
> ```bash
> # Création
> docker volume create mon_volume
> 
> # Listage
> docker volume ls
> docker volume ls --filter "dangling=true"
> 
> # Inspection
> docker volume inspect mon_volume
> 
> # Suppression
> docker volume rm mon_volume
> docker volume prune -f
> 
> # Nettoyage intelligent
> docker volume prune --filter "label!=critical" -f
> ```