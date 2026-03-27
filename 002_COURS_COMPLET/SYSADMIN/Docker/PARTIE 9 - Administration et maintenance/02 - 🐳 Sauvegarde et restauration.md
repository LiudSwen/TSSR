

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

La sauvegarde et la restauration sont des opérations critiques dans la gestion de conteneurs Docker. Elles permettent de :

- **Migrer** des conteneurs et images entre environnements
- **Créer des points de restauration** avant des modifications importantes
- **Partager** des configurations avec d'autres développeurs
- **Archiver** des versions spécifiques pour audit ou conformité
- **Récupérer** rapidement après une panne ou corruption

> [!info] Différence clé Docker propose plusieurs mécanismes selon ce que vous souhaitez sauvegarder :
> 
> - **Conteneurs** : état d'exécution complet avec filesystem
> - **Images** : template réutilisable sans état
> - **Volumes** : données persistantes indépendantes

---

## 📦 Export/Import de conteneurs

### Qu'est-ce que l'export/import ?

L'**export** crée une archive tar du système de fichiers d'un conteneur (état actuel). L'**import** reconstruit une image à partir de cette archive.

> [!warning] Limitation importante `docker export` capture UNIQUEMENT le filesystem du conteneur. Sont perdus :
> 
> - L'historique des layers
> - Les métadonnées (labels, variables d'environnement)
> - Les ports exposés
> - Les volumes montés
> - La commande par défaut

### 🔧 Export d'un conteneur

```bash
# Export d'un conteneur en cours d'exécution ou arrêté
docker export mon_conteneur > mon_conteneur.tar

# Avec compression gzip (recommandé pour économiser l'espace)
docker export mon_conteneur | gzip > mon_conteneur.tar.gz

# Export avec nom explicite incluant la date
docker export mon_conteneur > backup_app_$(date +%Y%m%d).tar
```

> [!example] Cas d'usage typique Vous avez configuré manuellement un conteneur Nginx avec des fichiers de configuration spécifiques. Vous voulez capturer cet état pour le déployer ailleurs.

### 📥 Import d'un conteneur

```bash
# Import basique : crée une nouvelle image
docker import mon_conteneur.tar mon_image:v1

# Import avec fichier compressé
docker import mon_conteneur.tar.gz mon_image:v1

# Import depuis stdin avec message de commit
cat mon_conteneur.tar | docker import - mon_image:v1 -m "État après configuration"

# Import avec commande par défaut (car perdue à l'export)
docker import mon_conteneur.tar mon_image:v1 -c 'CMD ["/usr/sbin/nginx", "-g", "daemon off;"]'
```

> [!tip] Astuce : restaurer les métadonnées Après l'import, utilisez `docker run` avec tous les paramètres nécessaires :
> 
> ```bash
> docker run -d \
>   --name nouveau_conteneur \
>   -p 80:80 \
>   -e ENV_VAR=valeur \
>   -v mon_volume:/data \
>   mon_image:v1 \
>   /bin/sh -c "commande"
> ```

### 🔄 Workflow export/import complet

```bash
# 1. Identifier le conteneur à exporter
docker ps -a

# 2. Arrêter le conteneur pour cohérence (optionnel mais recommandé)
docker stop mon_conteneur

# 3. Exporter
docker export mon_conteneur | gzip > backup_$(date +%Y%m%d_%H%M%S).tar.gz

# 4. Transférer vers autre machine (exemple)
scp backup_20250101_143000.tar.gz user@serveur:/tmp/

# 5. Sur la machine cible : importer
docker import backup_20250101_143000.tar.gz mon_app:restauree

# 6. Recréer le conteneur avec configuration complète
docker run -d \
  --name mon_app_restored \
  -p 8080:80 \
  -v /data/app:/var/www/html \
  mon_app:restauree \
  apache2-foreground
```

---

## 💿 Save/Load d'images

### Qu'est-ce que save/load ?

`docker save` sauvegarde une ou plusieurs images Docker **avec tous leurs layers et métadonnées**. `docker load` les restaure à l'identique.

> [!info] Différence avec export/import **Save/Load** préserve :
> 
> - ✅ Tous les layers de l'image
> - ✅ L'historique complet
> - ✅ Les tags
> - ✅ Les métadonnées (CMD, ENTRYPOINT, ENV, EXPOSE...)
> 
> C'est la méthode préférée pour sauvegarder des images.

### 💾 Save : sauvegarder des images

```bash
# Sauvegarder une seule image
docker save nginx:latest > nginx_latest.tar

# Avec compression (fortement recommandé)
docker save nginx:latest | gzip > nginx_latest.tar.gz

# Sauvegarder plusieurs images dans une seule archive
docker save nginx:latest nginx:alpine mysql:8.0 | gzip > mes_images.tar.gz

# Sauvegarder toutes les versions d'une image
docker save -o postgres_all.tar postgres:13 postgres:14 postgres:15

# Utiliser l'option -o (output) au lieu de redirection
docker save -o backup_app.tar mon_app:v1.0 mon_app:v1.1
```

> [!tip] Compression Les images Docker peuvent être très volumineuses. La compression gzip réduit généralement la taille de 50-70% :
> 
> ```bash
> # Sans compression : ~500 MB
> docker save nginx:latest > nginx.tar
> 
> # Avec compression : ~180 MB
> docker save nginx:latest | gzip > nginx.tar.gz
> ```

### 📂 Load : restaurer des images

```bash
# Charger une image depuis une archive
docker load < nginx_latest.tar

# Avec fichier compressé
docker load < nginx_latest.tar.gz

# Utiliser l'option -i (input)
docker load -i backup_app.tar

# Charger et afficher les détails
docker load --input mes_images.tar.gz

# Vérifier les images chargées
docker images
```

> [!example] Scénario de migration
> 
> ```bash
> # Machine source : sauvegarder votre stack complète
> docker save \
>   mon_app:v2.1 \
>   postgres:15 \
>   redis:7-alpine \
>   | gzip > stack_complete.tar.gz
> 
> # Transférer
> rsync -avz stack_complete.tar.gz serveur-prod:/tmp/
> 
> # Machine cible : restaurer
> docker load < /tmp/stack_complete.tar.gz
> 
> # Vérifier
> docker images | grep -E "mon_app|postgres|redis"
> ```

### 📊 Comparaison save vs export

|Critère|docker save|docker export|
|---|---|---|
|**Cible**|Images|Conteneurs|
|**Préserve layers**|✅ Oui|❌ Non (flatten)|
|**Préserve métadonnées**|✅ Oui|❌ Non|
|**Préserve historique**|✅ Oui|❌ Non|
|**Taille**|Plus grande|Plus petite|
|**Usage recommandé**|Sauvegarde d'images|Snapshot filesystem|
|**Restauration**|docker load|docker import|

---

## 💾 Sauvegarde des volumes

### Pourquoi sauvegarder les volumes ?

Les volumes Docker contiennent les **données persistantes** de vos applications (bases de données, fichiers uploadés, configurations...). Contrairement aux conteneurs et images, ils survivent aux suppressions et doivent être sauvegardés séparément.

> [!warning] Risque de perte de données Supprimer un conteneur ne supprime PAS automatiquement ses volumes, mais supprimer un volume détruit définitivement les données. Une sauvegarde régulière est essentielle.

### 🔍 Identifier les volumes à sauvegarder

```bash
# Lister tous les volumes
docker volume ls

# Inspecter un volume spécifique
docker volume inspect mon_volume

# Trouver où est stocké un volume sur l'hôte
docker volume inspect mon_volume --format '{{ .Mountpoint }}'

# Lister les volumes utilisés par un conteneur
docker inspect mon_conteneur --format '{{ json .Mounts }}' | jq
```

### 💾 Méthode 1 : Sauvegarde avec tar depuis un conteneur temporaire

C'est la méthode **officielle et recommandée** par Docker.

```bash
# Créer une archive du volume
docker run --rm \
  -v mon_volume:/data \
  -v $(pwd):/backup \
  alpine \
  tar czf /backup/mon_volume_backup.tar.gz -C /data .

# Explication :
# --rm                    : supprime le conteneur après exécution
# -v mon_volume:/data     : monte le volume à sauvegarder
# -v $(pwd):/backup       : monte le répertoire courant pour stocker l'archive
# alpine                  : image légère avec tar préinstallé
# tar czf                 : crée archive compressée
# -C /data .              : sauvegarde tout le contenu de /data
```

> [!example] Sauvegarde d'une base de données PostgreSQL
> 
> ```bash
> # Volume de données PostgreSQL
> docker run --rm \
>   -v postgres_data:/data \
>   -v /backups:/backup \
>   alpine \
>   tar czf /backup/postgres_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .
> ```

### 📥 Méthode 1 : Restauration depuis archive tar

```bash
# Créer un nouveau volume (si nécessaire)
docker volume create mon_volume_restored

# Restaurer les données
docker run --rm \
  -v mon_volume_restored:/data \
  -v $(pwd):/backup \
  alpine \
  sh -c "cd /data && tar xzf /backup/mon_volume_backup.tar.gz"

# Ou en une ligne plus concise
docker run --rm \
  -v mon_volume_restored:/data \
  -v $(pwd):/backup \
  alpine \
  tar xzf /backup/mon_volume_backup.tar.gz -C /data
```

### 💾 Méthode 2 : Copie directe avec rsync (volumes sur l'hôte)

Si vous avez accès au système de fichiers de l'hôte :

```bash
# Trouver l'emplacement du volume
VOLUME_PATH=$(docker volume inspect mon_volume --format '{{ .Mountpoint }}')

# Sauvegarder avec rsync
sudo rsync -avz "$VOLUME_PATH/" /backup/volumes/mon_volume/

# Restaurer
sudo rsync -avz /backup/volumes/mon_volume/ "$VOLUME_PATH/"
```

> [!warning] Permissions root Les volumes Docker appartiennent généralement à root. Utilisez `sudo` pour accéder aux mountpoints.

### 💾 Méthode 3 : Dump de base de données (méthode spécialisée)

Pour les bases de données, utilisez leurs outils natifs :

```bash
# PostgreSQL : dump SQL
docker exec mon_postgres pg_dumpall -U postgres > backup_db.sql

# Restauration PostgreSQL
cat backup_db.sql | docker exec -i mon_postgres psql -U postgres

# MySQL : dump SQL
docker exec mon_mysql mysqldump -u root -p'password' --all-databases > backup_mysql.sql

# Restauration MySQL
cat backup_mysql.sql | docker exec -i mon_mysql mysql -u root -p'password'

# MongoDB : dump binaire
docker exec mon_mongo mongodump --out /dump
docker cp mon_mongo:/dump ./backup_mongo

# Restauration MongoDB
docker cp ./backup_mongo mon_mongo:/dump
docker exec mon_mongo mongorestore /dump
```

> [!tip] Combiner les approches Pour une sauvegarde complète d'une application avec BDD :
> 
> 1. **Dump SQL** : pour import facile et lisibilité
> 2. **Sauvegarde du volume** : pour récupération rapide bit-à-bit
> 3. Conserver les deux types de backup

### 🔄 Script de sauvegarde automatisé

```bash
#!/bin/bash
# backup_volumes.sh

BACKUP_DIR="/backups/docker"
DATE=$(date +%Y%m%d_%H%M%S)

# Créer le répertoire de backup
mkdir -p "$BACKUP_DIR"

# Liste des volumes à sauvegarder
VOLUMES=("app_data" "postgres_data" "redis_data")

for volume in "${VOLUMES[@]}"; do
    echo "Sauvegarde de $volume..."
    
    docker run --rm \
        -v "$volume:/data:ro" \
        -v "$BACKUP_DIR:/backup" \
        alpine \
        tar czf "/backup/${volume}_${DATE}.tar.gz" -C /data .
    
    echo "✓ $volume sauvegardé"
done

# Nettoyer les backups de plus de 30 jours
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete

echo "Sauvegarde terminée : $BACKUP_DIR"
```

> [!tip] Automatisation avec cron
> 
> ```bash
> # Ajouter au crontab (crontab -e)
> # Sauvegarde quotidienne à 2h du matin
> 0 2 * * * /usr/local/bin/backup_volumes.sh >> /var/log/docker_backup.log 2>&1
> ```

### 📊 Tableau récapitulatif des méthodes de sauvegarde

|Méthode|Avantages|Inconvénients|Usage recommandé|
|---|---|---|---|
|**tar depuis conteneur**|✅ Portable<br>✅ Compression<br>✅ Pas besoin d'accès root|⚠️ Plus lent|Migration, archivage|
|**rsync direct**|✅ Très rapide<br>✅ Incrémental|❌ Besoin accès root<br>❌ Dépend de l'hôte|Backup local régulier|
|**Dump BDD**|✅ Portable<br>✅ Lisible<br>✅ Import sélectif|⚠️ Taille importante<br>⚠️ Plus lent|Bases de données|
|**Snapshot volume**|✅ Instantané<br>✅ COW efficient|❌ Dépend du driver|Environnements cloud|

---

## ⚠️ Pièges courants

### Export/Import

> [!warning] Perte de configuration
> 
> ```bash
> # ❌ Export puis import : perte des ports, variables, volumes
> docker export mon_app > app.tar
> docker import app.tar app:new
> docker run app:new  # Échec : pas de CMD définie
> 
> # ✅ Réimporter avec configuration complète
> docker import app.tar app:new -c 'CMD ["npm", "start"]'
> docker run -p 3000:3000 -e NODE_ENV=production app:new
> ```

### Save/Load

> [!warning] Tags manquants
> 
> ```bash
> # ❌ Sauvegarder sans tag : perd le tag
> docker save abc123def > image.tar
> 
> # ✅ Toujours utiliser nom:tag
> docker save mon_app:v1.0 > image.tar
> ```

> [!warning] Images multiples
> 
> ```bash
> # ❌ Plusieurs save séparés (inefficace)
> docker save nginx > nginx.tar
> docker save redis > redis.tar
> 
> # ✅ Un seul save pour partager les layers communs
> docker save nginx redis > stack.tar
> ```

### Sauvegarde de volumes

> [!warning] Conteneur en cours d'exécution
> 
> ```bash
> # ⚠️ Risque : sauvegarde pendant écritures (incohérence)
> docker run --rm -v db_data:/data -v $(pwd):/backup alpine tar czf /backup/db.tar.gz -C /data .
> 
> # ✅ Arrêter le conteneur d'abord
> docker stop mon_app
> docker run --rm -v db_data:/data -v $(pwd):/backup alpine tar czf /backup/db.tar.gz -C /data .
> docker start mon_app
> ```

> [!warning] Permissions lors de la restauration
> 
> ```bash
> # ❌ Restauration avec mauvaises permissions
> docker run --rm -v new_volume:/data -v $(pwd):/backup alpine tar xzf /backup/db.tar.gz -C /data
> # Les fichiers peuvent appartenir au mauvais utilisateur
> 
> # ✅ Vérifier et corriger les permissions
> docker run --rm -v new_volume:/data alpine chown -R 999:999 /data  # UID postgres par exemple
> ```

---

## ✅ Bonnes pratiques

### 🎯 Stratégie de sauvegarde

> [!tip] Règle 3-2-1 Appliquez la règle de backup 3-2-1 :
> 
> - **3** copies de vos données (originale + 2 backups)
> - **2** types de support différents (local + cloud)
> - **1** copie hors site (protection contre sinistre)

```bash
# Exemple de stratégie complète
# 1. Backup local journalier
0 2 * * * /scripts/backup_docker_local.sh

# 2. Sync vers NAS chaque nuit
0 3 * * * rsync -avz /backups/docker/ nas:/docker_backups/

# 3. Upload cloud hebdomadaire
0 4 * * 0 /scripts/upload_to_s3.sh
```

### 🏷️ Nommage cohérent

```bash
# ✅ Convention de nommage claire
BACKUP_NAME="${SERVICE}_${ENVIRONMENT}_${VERSION}_$(date +%Y%m%d_%H%M%S)"

# Exemples :
# postgres_production_15.2_20250125_020000.tar.gz
# nginx_staging_1.25_20250125_020000.tar.gz
# app_data_production_v2.1_20250125_020000.tar.gz
```

### 🔒 Sécurité des backups

> [!warning] Chiffrement des données sensibles
> 
> ```bash
> # Sauvegarder et chiffrer
> docker run --rm \
>   -v db_data:/data \
>   -v $(pwd):/backup \
>   alpine \
>   tar czf - -C /data . | \
>   openssl enc -aes-256-cbc -salt -out /backup/db_encrypted.tar.gz.enc -pass pass:motdepasse
> 
> # Déchiffrer et restaurer
> openssl enc -d -aes-256-cbc -in db_encrypted.tar.gz.enc -pass pass:motdepasse | \
>   docker run --rm -i \
>     -v db_data_restored:/data \
>     alpine \
>     tar xzf - -C /data
> ```

### 📝 Documentation des backups

Créez un fichier `BACKUP_MANIFEST.md` pour chaque backup :

````markdown
# Backup Manifest

**Date**: 2025-01-25 02:00:00
**Environnement**: Production
**Version**: v2.1.0

## Contenu
- `app_v2.1.tar.gz` : Image de l'application
- `postgres_data.tar.gz` : Volume base de données
- `uploads.tar.gz` : Volume fichiers utilisateurs
- `config_backup.tar.gz` : Configurations Nginx

## Commandes de restauration
```bash
docker load < app_v2.1.tar.gz
docker volume create postgres_data
docker run --rm -v postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres_data.tar.gz -C /data
````

## Checksums

```
md5sum *.tar.gz > checksums.md5
```

````

### 🔄 Tests de restauration

> [!tip] Testez vos backups !
> Un backup non testé est un backup potentiellement inutile.
> 
> ```bash
> # Script de test de restauration mensuel
> #!/bin/bash
> # test_restore.sh
> 
> BACKUP_FILE="/backups/latest/db_data.tar.gz"
> TEST_VOLUME="db_data_test_$(date +%s)"
> 
> echo "Test de restauration..."
> 
> # Créer volume de test
> docker volume create "$TEST_VOLUME"
> 
> # Restaurer
> docker run --rm \
>   -v "$TEST_VOLUME:/data" \
>   -v /backups/latest:/backup \
>   alpine \
>   tar xzf /backup/db_data.tar.gz -C /data
> 
> # Vérifier l'intégrité
> docker run --rm \
>   -v "$TEST_VOLUME:/data" \
>   postgres:15 \
>   pg_dump -U postgres --schema-only > /tmp/schema_test.sql
> 
> # Comparer avec schéma attendu
> diff /tmp/schema_test.sql /backups/schema_reference.sql
> 
> if [ $? -eq 0 ]; then
>     echo "✓ Test de restauration réussi"
> else
>     echo "✗ Échec du test de restauration"
>     exit 1
> fi
> 
> # Nettoyer
> docker volume rm "$TEST_VOLUME"
> ```

### 📊 Monitoring et alertes

```bash
# Script avec notification en cas d'échec
#!/bin/bash

BACKUP_DIR="/backups"
LOG_FILE="/var/log/docker_backup.log"

backup_volume() {
    local volume=$1
    echo "[$(date)] Début backup $volume" >> "$LOG_FILE"
    
    docker run --rm \
        -v "$volume:/data:ro" \
        -v "$BACKUP_DIR:/backup" \
        alpine \
        tar czf "/backup/${volume}_$(date +%Y%m%d).tar.gz" -C /data .
    
    if [ $? -eq 0 ]; then
        echo "[$(date)] ✓ $volume backup OK" >> "$LOG_FILE"
        return 0
    else
        echo "[$(date)] ✗ $volume backup FAILED" >> "$LOG_FILE"
        # Envoyer alerte (email, Slack, etc.)
        curl -X POST https://hooks.slack.com/services/XXX \
            -d "{\"text\":\"❌ Backup Docker échoué: $volume\"}"
        return 1
    fi
}

# Boucle sur tous les volumes
for volume in $(docker volume ls -q); do
    backup_volume "$volume"
done
````

### 💡 Astuces avancées

> [!tip] Compression adaptative
> 
> ```bash
> # Utiliser pigz (gzip parallèle) pour les gros volumes
> docker run --rm \
>   -v big_volume:/data \
>   -v $(pwd):/backup \
>   alpine \
>   sh -c "apk add pigz && tar -I pigz -cf /backup/big_volume.tar.gz -C /data ."
> 
> # Gain de temps : 3-4x plus rapide sur machines multi-cœurs
> ```

> [!tip] Backup incrémental
> 
> ```bash
> # Premier backup complet
> docker run --rm \
>   -v data:/data \
>   -v $(pwd):/backup \
>   alpine \
>   tar czf /backup/full_20250125.tar.gz -C /data .
> 
> # Backups incrémentaux (seulement les changements)
> docker run --rm \
>   -v data:/data \
>   -v $(pwd):/backup \
>   alpine \
>   tar czf /backup/incr_20250126.tar.gz \
>     --listed-incremental=/backup/snapshot.snar \
>     -C /data .
> ```

---

## 🎓 Résumé

|Action|Commande clé|Usage|
|---|---|---|
|**Exporter conteneur**|`docker export conteneur > fichier.tar`|Snapshot filesystem|
|**Importer conteneur**|`docker import fichier.tar image:tag`|Créer image depuis snapshot|
|**Sauvegarder image**|`docker save image:tag > fichier.tar`|Archiver image complète|
|**Charger image**|`docker load < fichier.tar`|Restaurer image|
|**Backup volume**|`docker run --rm -v vol:/data -v $(pwd):/backup alpine tar czf ...`|Sauvegarder données|
|**Restaurer volume**|`docker run --rm -v vol:/data -v $(pwd):/backup alpine tar xzf ...`|Restaurer données|

> [!info] Points essentiels à retenir
> 
> - **Export/Import** : pour filesystem de conteneurs (perd métadonnées)
> - **Save/Load** : pour images complètes (préserve tout)
> - **Backup volumes** : essentiel pour données persistantes
> - Toujours **tester vos restaurations**
> - Adopter une **stratégie 3-2-1**
> - **Chiffrer** les données sensibles
> - **Automatiser** avec des scripts et cron

---