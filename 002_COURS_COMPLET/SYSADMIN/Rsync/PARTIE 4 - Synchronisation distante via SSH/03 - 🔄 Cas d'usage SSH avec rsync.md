

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

## 💾 Sauvegarde sur serveur de backup

### Contexte et utilité

La sauvegarde régulière de données critiques vers un serveur distant dédié est une pratique essentielle pour la continuité d'activité. rsync excelle dans ce scénario grâce à sa capacité à effectuer des sauvegardes incrémentales rapides et efficaces.

> [!info] Pourquoi utiliser rsync pour les sauvegardes ?
> - **Transferts incrémentaux** : seules les modifications sont envoyées
> - **Préservation des métadonnées** : permissions, dates, propriétaires
> - **Reprise après interruption** : reprend où il s'était arrêté
> - **Vérification d'intégrité** : checksums pour garantir l'exactitude

### Sauvegarde complète d'un serveur web

```bash
# Sauvegarde de l'ensemble des données d'un serveur web
rsync -avz --delete \
  /var/www/ \
  backup@backup-srv.example.com:/backups/web-server/www/

# Avec exclusions des fichiers temporaires et caches
rsync -avz --delete \
  --exclude='cache/' \
  --exclude='tmp/' \
  --exclude='*.log' \
  /var/www/ \
  backup@backup-srv.example.com:/backups/web-server/www/
```

> [!tip] Astuce : Organisation des sauvegardes
> Créez une structure de répertoires datée sur le serveur de backup :
> ```bash
> rsync -avz /var/www/ \
>   backup@backup-srv:/backups/web-$(date +%Y-%m-%d)/
> ```

### Sauvegarde des bases de données

```bash
# Export MySQL puis transfert
mysqldump -u root -p --all-databases > /tmp/db-backup.sql
rsync -avz --progress \
  /tmp/db-backup.sql \
  backup@backup-srv:/backups/databases/db-$(date +%Y-%m-%d).sql

# Nettoyage local après transfert réussi
if [ $? -eq 0 ]; then
  rm /tmp/db-backup.sql
fi
```

### Sauvegarde des configurations système

```bash
# Sauvegarde des configurations critiques
rsync -avz --delete \
  --include='/etc/***' \
  --include='/root/.ssh/***' \
  --include='/home/*/.ssh/***' \
  --exclude='*' \
  / \
  backup@backup-srv:/backups/system-configs/$(hostname)/
```

> [!warning] Attention aux données sensibles
> Les fichiers de configuration peuvent contenir des mots de passe ou clés privées. Assurez-vous que le serveur de backup est correctement sécurisé et que les permissions sont restrictives.

### Sauvegarde avec rotation

```bash
# Script de sauvegarde avec conservation des 7 dernières versions
#!/bin/bash

BACKUP_HOST="backup@backup-srv.example.com"
BACKUP_DIR="/backups/web-server"
DATE=$(date +%Y-%m-%d)

# Création d'une nouvelle sauvegarde en lien avec la précédente
rsync -avz --delete \
  --link-dest=${BACKUP_DIR}/latest \
  /var/www/ \
  ${BACKUP_HOST}:${BACKUP_DIR}/${DATE}/

# Mise à jour du lien symbolique "latest"
ssh ${BACKUP_HOST} "ln -snf ${BACKUP_DIR}/${DATE} ${BACKUP_DIR}/latest"

# Suppression des sauvegardes de plus de 7 jours
ssh ${BACKUP_HOST} "find ${BACKUP_DIR} -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;"
```

> [!example] Principe du --link-dest
> Cette option crée des liens physiques vers les fichiers inchangés de la sauvegarde précédente, économisant ainsi énormément d'espace tout en conservant des sauvegardes complètes apparentes.

---

## 🔄 Synchronisation entre serveurs

### Maintien de la cohérence entre environnements

La synchronisation bidirectionnelle ou unidirectionnelle entre serveurs permet de maintenir des environnements cohérents (production, staging, développement) ou de distribuer du contenu.

### Synchronisation d'un serveur de production vers staging

```bash
# Copie du contenu de production vers staging
# Exécuté depuis le serveur de staging
rsync -avz --delete \
  prod@prod-srv.example.com:/var/www/production/ \
  /var/www/staging/

# Ou exécuté depuis le serveur de production (push)
rsync -avz --delete \
  /var/www/production/ \
  staging@staging-srv.example.com:/var/www/staging/
```

> [!tip] Choix de la direction
> - **Pull** (depuis staging) : le serveur de staging contrôle quand synchroniser
> - **Push** (depuis production) : synchronisation déclenchée côté production
> Préférez le pull pour plus de sécurité (pas d'accès SSH depuis production)

### Synchronisation de contenu statique entre serveurs web

```bash
# Distribution de contenu vers plusieurs serveurs web frontaux
for server in web1 web2 web3; do
  rsync -avz --delete \
    /var/www/static/ \
    www-data@${server}.example.com:/var/www/static/
done
```

### Synchronisation sélective avec exclusions

```bash
# Synchronisation en excluant les fichiers de développement
rsync -avz --delete \
  --exclude='.git/' \
  --exclude='node_modules/' \
  --exclude='*.log' \
  --exclude='config.dev.php' \
  dev@dev-srv:/var/www/app/ \
  /var/www/app/
```

### Synchronisation bidirectionnelle (avec précautions)

> [!warning] Attention : synchronisation bidirectionnelle
> rsync n'est pas conçu pour la synchronisation bidirectionnelle automatique. Pour ce cas d'usage, considérez des outils spécialisés comme `unison` ou `syncthing`.

```bash
# Approche manuelle en deux étapes (à utiliser avec prudence)
# Étape 1 : Serveur A → Serveur B
rsync -avzu \
  /data/shared/ \
  serverB:/data/shared/

# Étape 2 : Serveur B → Serveur A
rsync -avzu \
  serverB:/data/shared/ \
  /data/shared/
```

> [!info] Option -u (--update)
> L'option `-u` ne transfère que les fichiers plus récents que ceux existants, évitant ainsi d'écraser des modifications plus récentes. Cependant, cela ne résout pas les conflits de modifications simultanées.

### Synchronisation de fichiers de logs centralisés

```bash
# Collecte des logs depuis plusieurs serveurs vers un serveur central
# Script exécuté sur le serveur de logs central

SERVERS="web1 web2 web3 app1 app2"
LOG_DIR="/var/log/centralized"

for server in $SERVERS; do
  mkdir -p ${LOG_DIR}/${server}
  rsync -avz \
    --include='*.log' \
    --include='*/' \
    --exclude='*' \
    root@${server}:/var/log/ \
    ${LOG_DIR}/${server}/
done
```

---

## 🚀 Déploiement de fichiers

### Déploiement d'applications web

Le déploiement via rsync permet de pousser rapidement du code ou des ressources vers des serveurs de production tout en minimisant les temps d'arrêt.

### Déploiement basique d'une application

```bash
# Déploiement depuis un dépôt local vers production
rsync -avz --delete \
  --exclude='.git/' \
  --exclude='node_modules/' \
  --exclude='.env' \
  /local/app/ \
  deploy@prod-srv.example.com:/var/www/app/
```

> [!tip] Bonnes pratiques de déploiement
> - Toujours utiliser `--dry-run` avant le déploiement réel
> - Exclure les fichiers de configuration locaux
> - Conserver les données uploadées par les utilisateurs
> - Faire une sauvegarde avant déploiement

### Déploiement avec vérification préalable

```bash
#!/bin/bash

APP_DIR="/local/app"
REMOTE="deploy@prod-srv.example.com:/var/www/app/"

echo "=== Simulation du déploiement ==="
rsync -avzn --delete \
  --exclude='.git/' \
  --exclude='node_modules/' \
  ${APP_DIR}/ ${REMOTE}

read -p "Confirmer le déploiement ? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "=== Déploiement en cours ==="
  rsync -avz --delete \
    --exclude='.git/' \
    --exclude='node_modules/' \
    ${APP_DIR}/ ${REMOTE}
  echo "=== Déploiement terminé ==="
else
  echo "Déploiement annulé"
fi
```

### Déploiement avec sauvegarde automatique

```bash
#!/bin/bash

REMOTE_HOST="deploy@prod-srv.example.com"
REMOTE_PATH="/var/www/app"
BACKUP_PATH="/var/www/backups/app-$(date +%Y%m%d-%H%M%S)"

# Création d'une sauvegarde avant déploiement
ssh ${REMOTE_HOST} "cp -a ${REMOTE_PATH} ${BACKUP_PATH}"

# Déploiement
rsync -avz --delete \
  --exclude='.git/' \
  /local/app/ \
  ${REMOTE_HOST}:${REMOTE_PATH}/

# Vérification du code de retour
if [ $? -eq 0 ]; then
  echo "Déploiement réussi. Backup disponible : ${BACKUP_PATH}"
else
  echo "Erreur lors du déploiement. Restauration de la sauvegarde..."
  ssh ${REMOTE_HOST} "rm -rf ${REMOTE_PATH} && mv ${BACKUP_PATH} ${REMOTE_PATH}"
fi
```

### Déploiement de ressources statiques

```bash
# Déploiement optimisé pour les assets statiques (images, CSS, JS)
rsync -avz \
  --include='*.css' \
  --include='*.js' \
  --include='*.jpg' \
  --include='*.png' \
  --include='*.svg' \
  --include='*.woff*' \
  --exclude='*' \
  /local/app/public/assets/ \
  cdn@cdn-srv.example.com:/var/www/cdn/assets/
```

### Déploiement multi-serveurs

```bash
#!/bin/bash

SERVERS="web1.example.com web2.example.com web3.example.com"
APP_DIR="/local/app"
REMOTE_PATH="/var/www/app"

for server in $SERVERS; do
  echo "=== Déploiement vers $server ==="
  rsync -avz --delete \
    --exclude='.git/' \
    --exclude='node_modules/' \
    --exclude='.env' \
    ${APP_DIR}/ \
    deploy@${server}:${REMOTE_PATH}/
  
  if [ $? -eq 0 ]; then
    echo "✓ Déploiement réussi sur $server"
  else
    echo "✗ Échec du déploiement sur $server"
  fi
done
```

> [!example] Déploiement progressif
> Pour minimiser les risques, déployez d'abord sur un serveur, testez, puis déployez sur les autres :
> ```bash
> # Déploiement sur canary
> rsync -avz app/ deploy@canary:/var/www/app/
> 
> # Tests manuels ou automatisés...
> 
> # Déploiement sur le reste de la flotte
> for server in web{1..10}; do
>   rsync -avz app/ deploy@${server}:/var/www/app/
> done
> ```

### Déploiement avec préservation de fichiers spécifiques

```bash
# Déploiement en préservant les uploads et configurations
rsync -avz --delete \
  --exclude='.git/' \
  --exclude='uploads/' \
  --exclude='config.local.php' \
  --exclude='storage/logs/' \
  /local/app/ \
  deploy@prod-srv.example.com:/var/www/app/
```

> [!info] Fichiers à toujours exclure
> Typiquement, excluez :
> - Fichiers de configuration d'environnement (`.env`, `config.local.*`)
> - Uploads utilisateurs (`uploads/`, `media/`)
> - Logs (`*.log`, `logs/`)
> - Caches (`cache/`, `tmp/`)
> - Dépendances (`node_modules/`, `vendor/`)

### Déploiement avec rechargement de service

```bash
#!/bin/bash

REMOTE_HOST="deploy@prod-srv.example.com"
APP_PATH="/var/www/app"

# Déploiement
rsync -avz --delete \
  --exclude='.git/' \
  /local/app/ \
  ${REMOTE_HOST}:${APP_PATH}/

# Rechargement du service applicatif après déploiement réussi
if [ $? -eq 0 ]; then
  ssh ${REMOTE_HOST} "sudo systemctl reload php-fpm"
  echo "Déploiement terminé et service rechargé"
fi
```

---

## 📊 Tableau récapitulatif des cas d'usage

| Cas d'usage | Direction | Options clés | Fréquence typique |
|-------------|-----------|--------------|-------------------|
| Sauvegarde serveur | Push vers backup | `-avz --delete` | Quotidienne/Horaire |
| Sync prod → staging | Pull depuis staging | `-avz --delete` | À la demande |
| Distribution contenu | Push vers multiples | `-avz --delete` | Continue/Horaire |
| Déploiement code | Push vers production | `-avz --delete --exclude` | À chaque release |
| Collecte logs | Pull vers central | `-avz --include` | Horaire |

> [!tip] Automatisation recommandée
> Tous ces cas d'usage gagnent à être automatisés via cron ou des outils de CI/CD, combinés avec des scripts de vérification et de notification en cas d'échec.