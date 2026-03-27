

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

La sauvegarde des bases de données est une opération **critique** pour la pérennité des données. Une stratégie de sauvegarde bien pensée permet de :

- 🛡️ Protéger contre la perte de données (erreur humaine, panne matérielle)
- 🔄 Faciliter la migration vers un autre serveur
- 🧪 Créer des environnements de test avec des données réelles
- ⏮️ Revenir à un état antérieur en cas de problème

> [!warning] Importance capitale Sans sauvegarde régulière et testée, vous risquez une **perte totale et irréversible** de vos données. Une sauvegarde non testée est aussi dangereuse que pas de sauvegarde du tout.

---

## mysqldump - Export de bases

### Principe et fonctionnement

`mysqldump` est l'outil officiel fourni avec MySQL/MariaDB pour exporter des bases de données. Il génère un fichier texte contenant des instructions SQL permettant de recréer la structure et les données.

**Comment ça fonctionne :**

1. Se connecte au serveur MySQL
2. Lit les données table par table
3. Génère des instructions `CREATE TABLE` et `INSERT INTO`
4. Écrit le tout dans un fichier ou sur la sortie standard

> [!info] Format du dump Le fichier généré est du SQL pur, ce qui le rend :
> 
> - Lisible et éditable manuellement
> - Compatible entre différentes versions de MySQL/MariaDB
> - Facile à versionner avec Git
> - Mais potentiellement volumineux pour de grandes bases

### Syntaxe de base

```bash
# Syntaxe générale
mysqldump [options] nom_base > fichier_dump.sql

# Exemple simple
mysqldump -u root -p ma_base > sauvegarde.sql
```

**Décomposition de la commande :**

- `mysqldump` : l'outil d'export
- `-u root` : utilisateur MySQL
- `-p` : demande le mot de passe de façon interactive
- `ma_base` : nom de la base à sauvegarder
- `> sauvegarde.sql` : redirection vers un fichier

> [!tip] Sécurité du mot de passe Évitez `-p[motdepasse]` directement dans la commande (visible dans l'historique). Préférez `-p` seul pour saisie interactive, ou utilisez un fichier de configuration `~/.my.cnf`.

### Options importantes

#### Options de contenu

```bash
# Sauvegarder UNIQUEMENT la structure (pas de données)
mysqldump -u root -p --no-data ma_base > structure.sql

# Sauvegarder UNIQUEMENT les données (pas de structure)
mysqldump -u root -p --no-create-info ma_base > donnees.sql

# Inclure les routines (procédures stockées, fonctions)
mysqldump -u root -p --routines --triggers ma_base > complet.sql
```

#### Options de performance

```bash
# Dump rapide avec verrouillage minimal (pour InnoDB)
mysqldump -u root -p --single-transaction --quick ma_base > dump.sql

# Explication :
# --single-transaction : cohérence des données sans verrouiller les tables
# --quick : lit ligne par ligne (économise la RAM)
```

> [!info] Différence moteurs de stockage
> 
> - **InnoDB** : utilisez `--single-transaction` (pas de verrouillage)
> - **MyISAM** : utilisez `--lock-tables` (verrouillage nécessaire)

#### Options de compatibilité

```bash
# Dump compatible avec d'autres SGBD
mysqldump -u root -p --compatible=postgresql ma_base > dump.sql

# Ajouter DROP TABLE avant CREATE TABLE
mysqldump -u root -p --add-drop-table ma_base > dump.sql

# Désactiver les commentaires et commandes spécifiques MySQL
mysqldump -u root -p --skip-comments --skip-extended-insert ma_base > dump.sql
```

### Cas d'usage courants

#### 1️⃣ Sauvegarder une seule base

```bash
mysqldump -u root -p --single-transaction --routines --triggers \
  ma_base > ma_base_$(date +%Y%m%d).sql
```

#### 2️⃣ Sauvegarder toutes les bases

```bash
# Toutes les bases utilisateur + système
mysqldump -u root -p --all-databases --single-transaction \
  > toutes_bases_$(date +%Y%m%d).sql

# Seulement certaines bases
mysqldump -u root -p --databases base1 base2 base3 \
  > plusieurs_bases.sql
```

> [!warning] Bases système `--all-databases` inclut mysql, information_schema, performance_schema. Soyez prudent lors de la restauration pour ne pas écraser la configuration système.

#### 3️⃣ Sauvegarder une ou plusieurs tables spécifiques

```bash
# Une table
mysqldump -u root -p ma_base ma_table > ma_table.sql

# Plusieurs tables
mysqldump -u root -p ma_base table1 table2 table3 > tables.sql
```

#### 4️⃣ Sauvegarder avec compression

```bash
# Compression gzip (réduit la taille de 70-90%)
mysqldump -u root -p --single-transaction ma_base | gzip > ma_base.sql.gz

# Compression bzip2 (meilleure compression, plus lent)
mysqldump -u root -p --single-transaction ma_base | bzip2 > ma_base.sql.bz2
```

#### 5️⃣ Sauvegarder vers un serveur distant

```bash
# Via SSH
mysqldump -u root -p ma_base | ssh user@serveur-distant "cat > /backup/ma_base.sql"

# Compressé via SSH
mysqldump -u root -p ma_base | gzip | \
  ssh user@serveur-distant "cat > /backup/ma_base.sql.gz"
```

#### 6️⃣ Dump avec condition WHERE

```bash
# Sauvegarder uniquement certaines lignes
mysqldump -u root -p ma_base ma_table \
  --where="date_creation >= '2024-01-01'" > table_filtre.sql
```

### Tableau récapitulatif des options principales

|Option|Usage|Cas d'utilisation|
|---|---|---|
|`--single-transaction`|Cohérence InnoDB sans verrouillage|Production avec InnoDB|
|`--lock-tables`|Verrouille les tables|MyISAM ou cohérence stricte|
|`--quick`|Lecture ligne par ligne|Grandes bases, RAM limitée|
|`--routines`|Inclut procédures/fonctions|Base avec logique métier|
|`--triggers`|Inclut les déclencheurs|Intégrité référentielle complexe|
|`--no-data`|Structure seule|Documentation, migration structure|
|`--no-create-info`|Données seules|Mise à jour données uniquement|
|`--add-drop-table`|DROP avant CREATE|Réinstallation propre|
|`--databases`|Plusieurs bases|Backup sélectif|
|`--all-databases`|Toutes les bases|Backup complet serveur|

> [!tip] Astuce pour grandes bases Pour des bases de plusieurs Go, combinez : `--single-transaction --quick --extended-insert=FALSE` pour un meilleur contrôle et débogage.

---

## Importation via mysql

### Restauration complète

L'importation utilise le client `mysql` standard pour exécuter les instructions SQL contenues dans le dump.

#### Syntaxe de base

```bash
# Restauration simple
mysql -u root -p nom_base < fichier_dump.sql

# Si le dump contient CREATE DATABASE
mysql -u root -p < fichier_dump.sql

# Avec affichage de la progression
pv fichier_dump.sql | mysql -u root -p nom_base
# (nécessite le paquet 'pv' : apt install pv)
```

#### Restauration d'un dump compressé

```bash
# Depuis gzip
gunzip < ma_base.sql.gz | mysql -u root -p nom_base
# ou
zcat ma_base.sql.gz | mysql -u root -p nom_base

# Depuis bzip2
bunzip2 < ma_base.sql.bz2 | mysql -u root -p nom_base
# ou
bzcat ma_base.sql.bz2 | mysql -u root -p nom_base
```

### Restauration sélective

#### Restaurer uniquement certaines tables

```bash
# Extraire une table d'un dump complet
sed -n '/CREATE TABLE `ma_table`/,/UNLOCK TABLES;/p' dump_complet.sql > ma_table.sql

# Puis restaurer
mysql -u root -p nom_base < ma_table.sql
```

#### Restaurer avec vérification préalable

```bash
# Créer d'abord la base si elle n'existe pas
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS ma_base CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Puis restaurer
mysql -u root -p ma_base < sauvegarde.sql
```

### Gestion des erreurs

#### Mode strict vs permissif

```bash
# Mode par défaut (s'arrête à la première erreur)
mysql -u root -p nom_base < dump.sql

# Forcer la continuation malgré les erreurs
mysql -u root -p --force nom_base < dump.sql

# Afficher les warnings
mysql -u root -p --show-warnings nom_base < dump.sql
```

> [!warning] Attention avec --force L'option `--force` continue malgré les erreurs, ce qui peut aboutir à une base incomplète ou incohérente. À n'utiliser que si vous comprenez les erreurs et savez qu'elles sont non critiques.

#### Logger les erreurs

```bash
# Rediriger les erreurs vers un fichier
mysql -u root -p nom_base < dump.sql 2> erreurs_import.log

# Tout logger (output + erreurs)
mysql -u root -p nom_base < dump.sql &> import_complet.log
```

#### Surveillance de l'importation

```bash
# Avec pv pour voir la progression
pv dump.sql | mysql -u root -p nom_base

# Script avec horodatage
echo "Début restauration: $(date)" > import.log
mysql -u root -p nom_base < dump.sql 2>&1 | tee -a import.log
echo "Fin restauration: $(date)" >> import.log
```

### Cas particuliers de restauration

#### Restauration sur une base existante

```bash
# ATTENTION : cela va ÉCRASER les données existantes !

# Option 1 : Supprimer et recréer
mysql -u root -p -e "DROP DATABASE IF EXISTS ma_base; CREATE DATABASE ma_base;"
mysql -u root -p ma_base < dump.sql

# Option 2 : Fusionner (risqué)
mysql -u root -p ma_base < dump.sql
# Les données existantes non présentes dans le dump restent
```

> [!warning] Risque de perte de données Toujours faire une sauvegarde avant de restaurer sur une base existante contenant des données importantes.

#### Restauration entre serveurs de versions différentes

```bash
# Vérifier la compatibilité
mysql --version

# Pour version MySQL ancienne -> récente : généralement OK
mysql -u root -p ma_base < dump_ancien.sql

# Pour version récente -> ancienne : créer un dump compatible
mysqldump --compatible=mysql40 -u root -p ma_base > dump_compatible.sql
```

---

## Automatisation des sauvegardes

### Scripts de sauvegarde

#### Script de base

```bash
#!/bin/bash
# script: backup_mysql.sh

# Configuration
DB_USER="root"
DB_PASS="mot_de_passe"  # ⚠️ À sécuriser !
DB_NAME="ma_base"
BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${DATE}.sql.gz"

# Créer le répertoire si inexistant
mkdir -p "$BACKUP_DIR"

# Sauvegarde
mysqldump -u "$DB_USER" -p"$DB_PASS" \
  --single-transaction --routines --triggers \
  "$DB_NAME" | gzip > "$BACKUP_FILE"

# Vérifier le succès
if [ $? -eq 0 ]; then
    echo "Sauvegarde réussie : $BACKUP_FILE"
    exit 0
else
    echo "Erreur lors de la sauvegarde"
    exit 1
fi
```

> [!warning] Sécurité du mot de passe Ne jamais mettre le mot de passe en clair dans un script ! Utilisez plutôt un fichier `.my.cnf` ou des variables d'environnement sécurisées.

#### Script sécurisé avec fichier de configuration

```bash
#!/bin/bash
# script: backup_mysql_secure.sh

# Fichier de configuration MySQL (~/.my.cnf)
# [client]
# user=root
# password=votre_mot_de_passe

DB_NAME="ma_base"
BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${DATE}.sql.gz"
LOG_FILE="/var/log/mysql_backup.log"

# Fonction de log
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Créer le répertoire
mkdir -p "$BACKUP_DIR"

# Sauvegarde
log "Début sauvegarde de $DB_NAME"
mysqldump --defaults-extra-file=~/.my.cnf \
  --single-transaction --routines --triggers \
  "$DB_NAME" | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log "Sauvegarde réussie : $BACKUP_FILE ($SIZE)"
else
    log "ERREUR lors de la sauvegarde"
    exit 1
fi
```

**Fichier ~/.my.cnf** :

```ini
[client]
user=root
password=votre_mot_de_passe

[mysqldump]
single-transaction
routines
triggers
```

```bash
# Sécuriser le fichier
chmod 600 ~/.my.cnf
```

#### Script avancé multi-bases

```bash
#!/bin/bash
# script: backup_all_databases.sh

BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/mysql_backup.log"
RETENTION_DAYS=7

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

mkdir -p "$BACKUP_DIR"

# Liste des bases à sauvegarder (exclut les bases système)
DATABASES=$(mysql --defaults-extra-file=~/.my.cnf -e "SHOW DATABASES;" | \
  grep -Ev "Database|information_schema|performance_schema|mysql|sys")

log "=== Début sauvegarde de toutes les bases ==="

for DB in $DATABASES; do
    BACKUP_FILE="$BACKUP_DIR/${DB}_${DATE}.sql.gz"
    log "Sauvegarde de $DB..."
    
    mysqldump --defaults-extra-file=~/.my.cnf \
      --single-transaction --routines --triggers \
      "$DB" | gzip > "$BACKUP_FILE"
    
    if [ $? -eq 0 ]; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        log "✓ $DB sauvegardée ($SIZE)"
    else
        log "✗ Erreur pour $DB"
    fi
done

# Nettoyage des anciennes sauvegardes
log "Nettoyage des sauvegardes > $RETENTION_DAYS jours"
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

log "=== Sauvegarde terminée ==="
```

### Planification avec cron

#### Éditer la crontab

```bash
# Éditer la crontab de l'utilisateur
crontab -e

# Éditer la crontab root (pour accès complet MySQL)
sudo crontab -e
```

#### Exemples de planification

```bash
# Tous les jours à 2h du matin
0 2 * * * /usr/local/bin/backup_mysql.sh

# Toutes les 6 heures
0 */6 * * * /usr/local/bin/backup_mysql.sh

# Du lundi au vendredi à 23h
0 23 * * 1-5 /usr/local/bin/backup_mysql.sh

# Tous les dimanches à 3h (sauvegarde hebdo complète)
0 3 * * 0 /usr/local/bin/backup_all_databases.sh

# Toutes les heures en semaine (9h-18h)
0 9-18 * * 1-5 /usr/local/bin/backup_mysql.sh
```

#### Format cron expliqué

```
* * * * * commande
│ │ │ │ │
│ │ │ │ └─ Jour de la semaine (0-7, 0 et 7 = dimanche)
│ │ │ └─── Mois (1-12)
│ │ └───── Jour du mois (1-31)
│ └─────── Heure (0-23)
└───────── Minute (0-59)
```

> [!tip] Tester votre cron Utilisez [crontab.guru](https://crontab.guru/) pour valider et comprendre vos expressions cron.

#### Cron avec notifications

```bash
#!/bin/bash
# script: backup_with_notification.sh

BACKUP_SCRIPT="/usr/local/bin/backup_mysql.sh"
ADMIN_EMAIL="admin@example.com"

# Exécuter le backup
"$BACKUP_SCRIPT" > /tmp/backup_output.txt 2>&1

# Vérifier le résultat
if [ $? -eq 0 ]; then
    SUBJECT="✓ Sauvegarde MySQL réussie"
else
    SUBJECT="✗ ERREUR Sauvegarde MySQL"
fi

# Envoyer email (nécessite mailutils ou sendmail)
mail -s "$SUBJECT" "$ADMIN_EMAIL" < /tmp/backup_output.txt
```

**Crontab :**

```bash
0 2 * * * /usr/local/bin/backup_with_notification.sh
```

### Rotation et archivage

#### Stratégie 3-2-1

> [!info] Règle 3-2-1 de sauvegarde
> 
> - **3** copies de vos données
> - Sur **2** supports différents
> - Dont **1** hors site (offsite)

#### Script de rotation simple (rétention par âge)

```bash
#!/bin/bash
# Déjà intégré dans le script précédent

BACKUP_DIR="/var/backups/mysql"
RETENTION_DAYS=7

# Supprimer les sauvegardes de plus de 7 jours
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
```

#### Script de rotation avancé (GFS - Grand-père, Père, Fils)

```bash
#!/bin/bash
# script: backup_rotation_gfs.sh

BACKUP_DIR="/var/backups/mysql"
DAILY_DIR="$BACKUP_DIR/daily"
WEEKLY_DIR="$BACKUP_DIR/weekly"
MONTHLY_DIR="$BACKUP_DIR/monthly"

DB_NAME="ma_base"
DATE=$(date +%Y%m%d)
DAY_OF_WEEK=$(date +%u)  # 1=lundi, 7=dimanche
DAY_OF_MONTH=$(date +%d)

# Créer les répertoires
mkdir -p "$DAILY_DIR" "$WEEKLY_DIR" "$MONTHLY_DIR"

# Sauvegarde quotidienne
DAILY_BACKUP="$DAILY_DIR/${DB_NAME}_${DATE}.sql.gz"
mysqldump --defaults-extra-file=~/.my.cnf \
  --single-transaction --routines --triggers \
  "$DB_NAME" | gzip > "$DAILY_BACKUP"

# Si dimanche : copier vers weekly
if [ "$DAY_OF_WEEK" -eq 7 ]; then
    cp "$DAILY_BACKUP" "$WEEKLY_DIR/${DB_NAME}_week_${DATE}.sql.gz"
fi

# Si 1er du mois : copier vers monthly
if [ "$DAY_OF_MONTH" -eq 01 ]; then
    cp "$DAILY_BACKUP" "$MONTHLY_DIR/${DB_NAME}_month_${DATE}.sql.gz"
fi

# Nettoyage
find "$DAILY_DIR" -name "*.sql.gz" -mtime +7 -delete     # 7 jours
find "$WEEKLY_DIR" -name "*.sql.gz" -mtime +28 -delete   # 4 semaines
find "$MONTHLY_DIR" -name "*.sql.gz" -mtime +365 -delete # 12 mois
```

#### Sauvegarde vers stockage distant

```bash
#!/bin/bash
# script: backup_to_remote.sh

BACKUP_FILE="/var/backups/mysql/ma_base_$(date +%Y%m%d).sql.gz"
REMOTE_USER="backup"
REMOTE_HOST="backup-server.example.com"
REMOTE_DIR="/backups/mysql"

# Sauvegarde locale
mysqldump --defaults-extra-file=~/.my.cnf \
  --single-transaction --routines --triggers \
  ma_base | gzip > "$BACKUP_FILE"

# Transfert via rsync (avec reprise possible)
rsync -avz --progress "$BACKUP_FILE" \
  "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"

# Ou via SCP (plus simple)
# scp "$BACKUP_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"

# Vérification sur le serveur distant
ssh "$REMOTE_USER@$REMOTE_HOST" "ls -lh $REMOTE_DIR/$(basename $BACKUP_FILE)"
```

#### Sauvegarde cloud (exemple avec AWS S3)

```bash
#!/bin/bash
# script: backup_to_s3.sh
# Nécessite: apt install awscli

BACKUP_FILE="/tmp/ma_base_$(date +%Y%m%d).sql.gz"
S3_BUCKET="s3://mon-bucket-backup/mysql"

# Sauvegarde
mysqldump --defaults-extra-file=~/.my.cnf \
  --single-transaction --routines --triggers \
  ma_base | gzip > "$BACKUP_FILE"

# Upload vers S3
aws s3 cp "$BACKUP_FILE" "$S3_BUCKET/" \
  --storage-class STANDARD_IA  # Intelligent-Tiering pour réduire les coûts

# Supprimer le fichier local temporaire
rm "$BACKUP_FILE"

# Politique de rétention S3 (à configurer via la console AWS)
# - Transition vers Glacier après 30 jours
# - Suppression après 1 an
```

---

## Bonnes pratiques

### ✅ Sécurité

1. **Protéger les credentials**
    
    ```bash
    # Fichier ~/.my.cnf
    chmod 600 ~/.my.cnf
    chown mysql:mysql ~/.my.cnf
    ```
    
2. **Chiffrer les sauvegardes sensibles**
    
    ```bash
    # Avec GPG
    mysqldump -u root -p ma_base | gzip | \
      gpg --encrypt --recipient admin@example.com > ma_base.sql.gz.gpg
    
    # Déchiffrer
    gpg --decrypt ma_base.sql.gz.gpg | gunzip | mysql -u root -p ma_base
    ```
    
3. **Limiter les accès aux fichiers de backup**
    
    ```bash
    chmod 700 /var/backups/mysql
    chmod 600 /var/backups/mysql/*.sql.gz
    ```
    

### ✅ Fiabilité

1. **Tester régulièrement les restaurations**
    
    ```bash
    # Script de test mensuel
    # Restaurer sur une base de test et vérifier l'intégrité
    ```
    
2. **Vérifier l'intégrité après sauvegarde**
    
    ```bash
    # Tester que le fichier n'est pas corrompu
    gunzip -t backup.sql.gz
    
    # Vérifier qu'il contient des données
    [ $(gunzip -c backup.sql.gz | wc -l) -gt 100 ] && echo "OK" || echo "KO"
    ```
    
3. **Logger et monitorer**
    
    ```bash
    # Envoyer les logs vers un système centralisé
    # Alerter si une sauvegarde échoue
    ```
    

### ✅ Performance

1. **Horaires adaptés**
    
    - Planifier aux heures creuses (nuit, weekend)
    - Éviter les pics d'activité
2. **Options optimisées**
    
    ```bash
    # Pour InnoDB
    --single-transaction --quick --skip-lock-tables
    
    # Augmenter la taille du buffer
    --max_allowed_packet=512M
    ```
    
3. **Compression adaptée**
    
    |Méthode|Compression|Vitesse|CPU|Usage|
    |---|---|---|---|---|
    |gzip|Bonne (~80%)|Rapide|Modéré|Production|
    |bzip2|Meilleure (~85%)|Lent|Élevé|Archivage|
    |xz|Excellente (~90%)|Très lent|Très élevé|Archivage long terme|
    |Aucune|0%|Instantané|Aucun|Disque rapide, tests|
    

### ✅ Organisation

1. **Nommage cohérent**
    
    ```bash
    # Format recommandé
    nombase_YYYYMMDD_HHMMSS.sql.gz
    
    # Exemples
    wordpress_20241221_020000.sql.gz
    prestashop_20241221_030000.sql.gz
    ```
    
2. **Structure de répertoires**
    
    ```
    /var/backups/mysql/
    ├── daily/
    ├── weekly/
    ├── monthly/
    └── logs/
    ```
    
3. **Documentation**
    
    - Procédure de restauration écrite et testée
    - Liste des bases critiques
    - RTO/RPO définis (Recovery Time/Point Objective)

### ✅ Stratégie complète

> [!tip] Stratégie de sauvegarde recommandée
> 
> 1. **Sauvegarde quotidienne** automatique (2h du matin)
> 2. **Rétention** : 7 jours local + 30 jours distant
> 3. **Test de restauration** mensuel documenté
> 4. **Monitoring** avec alertes en cas d'échec
> 5. **Sauvegarde hors site** (cloud ou serveur distant)
> 6. **Chiffrement** pour les données sensibles

### ⚠️ Pièges courants à éviter

|Piège|Conséquence|Solution|
|---|---|---|
|Ne jamais tester les restaurations|Découvrir que le backup est corrompu en cas de besoin|Test mensuel obligatoire|
|Mot de passe en clair dans les scripts|Fuite de sécurité|Utiliser ~/.my.cnf avec chmod 600|
|Backup sur le même disque que les données|Perte simultanée en cas de crash|Backup sur disque/serveur séparé|
|Pas de monitoring|Ne pas savoir qu'un backup a échoué|Logs + alertes email/Slack|
|Oublier les procédures stockées|Perte de logique métier|--routines --triggers|
|Garder tous les backups infiniment|Saturation disque|Politique de rotation claire|
|Dumps énormes non compressés|Espace et bande passante gaspillés|Toujours compresser (gzip minimum)|

---

## 🎯 Points clés à retenir

1. **mysqldump** est l'outil standard pour exporter des bases MySQL/MariaDB en SQL
2. Utilisez **--single-transaction** pour InnoDB (pas de verrouillage)
3. Toujours **compresser** les dumps (gzip) pour économiser l'espace
4. **Automatisez** avec cron + scripts bash robustes
5. Appliquez une **rotation** (daily/weekly/monthly) pour gérer l'espace disque
6. **Testez régulièrement** vos restaurations (backup non testé = pas de backup)
7. Gardez au moins **une copie hors site** (cloud, serveur distant)
8. **Chiffrez** les données sensibles avec GPG
9. **Sécurisez** les fichiers de backup (chmod 600) et credentials
10. **Documentez** vos procédures de restauration et testez-les

---

## 📊 Tableau comparatif des méthodes de sauvegarde

|Critère|mysqldump|Copie physique|Réplication|
|---|---|---|---|
|**Facilité**|⭐⭐⭐⭐⭐ Très simple|⭐⭐ Complexe|⭐⭐⭐ Moyen|
|**Portabilité**|⭐⭐⭐⭐⭐ SQL universel|⭐⭐ Dépend version|⭐⭐⭐ Entre versions proches|
|**Taille**|⭐⭐⭐ Compressible|⭐⭐ Fichiers bruts|⭐⭐⭐⭐ Temps réel|
|**Performance**|⭐⭐⭐ Bon (peut ralentir)|⭐⭐⭐⭐⭐ Très rapide|⭐⭐⭐⭐ Continu|
|**Restauration partielle**|⭐⭐⭐⭐⭐ Table par table|⭐ Tout ou rien|⭐⭐ Limité|
|**Cohérence**|⭐⭐⭐⭐ Excellente|⭐⭐⭐⭐ Bonne|⭐⭐⭐⭐⭐ Parfaite|
|**Usage recommandé**|Backup quotidien standard|Grandes bases, migration|Haute disponibilité|

> [!info] Quand utiliser quoi ?
> 
> - **mysqldump** : Usage quotidien, petites/moyennes bases, flexibilité maximale
> - **Copie physique** (non couverte ici) : Très grandes bases, migration serveur
> - **Réplication** (non couverte ici) : Haute disponibilité, pas vraiment du backup

---

## 🔧 Exemple de configuration complète

### Structure des fichiers

```
/etc/mysql/
  └── backup.cnf         # Configuration MySQL pour backup

/usr/local/bin/
  ├── mysql-backup.sh    # Script principal
  └── mysql-restore.sh   # Script de restauration

/var/backups/mysql/
  ├── daily/             # Sauvegardes quotidiennes (7 jours)
  ├── weekly/            # Sauvegardes hebdomadaires (4 semaines)
  ├── monthly/           # Sauvegardes mensuelles (12 mois)
  └── logs/              # Logs des opérations

/var/log/
  └── mysql-backup.log   # Log centralisé
```

### Fichier de configuration /etc/mysql/backup.cnf

```ini
[client]
user=backup_user
password=SecurePassword123!

[mysqldump]
single-transaction
routines
triggers
events
quick
compress
max_allowed_packet=512M
```

```bash
# Sécuriser le fichier
chmod 600 /etc/mysql/backup.cnf
chown root:root /etc/mysql/backup.cnf
```

### Script complet de production /usr/local/bin/mysql-backup.sh

```bash
#!/bin/bash
#
# Script de sauvegarde MySQL/MariaDB complet
# Auteur: Admin
# Version: 2.0
#

set -euo pipefail  # Arrêt en cas d'erreur

# ============================================================================
# CONFIGURATION
# ============================================================================

MYSQL_CNF="/etc/mysql/backup.cnf"
BACKUP_ROOT="/var/backups/mysql"
LOG_FILE="/var/log/mysql-backup.log"
RETENTION_DAILY=7
RETENTION_WEEKLY=28
RETENTION_MONTHLY=365

# Email de notification (vide = pas d'email)
ADMIN_EMAIL="admin@example.com"

# ============================================================================
# FONCTIONS
# ============================================================================

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

send_notification() {
    local subject="$1"
    local body="$2"
    
    if [ -n "$ADMIN_EMAIL" ] && command -v mail &> /dev/null; then
        echo "$body" | mail -s "$subject" "$ADMIN_EMAIL"
    fi
}

get_database_size() {
    local db="$1"
    mysql --defaults-extra-file="$MYSQL_CNF" -sNe "
        SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2)
        FROM information_schema.tables
        WHERE table_schema='$db'
    " 2>/dev/null || echo "0"
}

# ============================================================================
# VÉRIFICATIONS PRÉLIMINAIRES
# ============================================================================

# Vérifier que mysql et mysqldump sont disponibles
if ! command -v mysql &> /dev/null || ! command -v mysqldump &> /dev/null; then
    log "ERROR" "MySQL client ou mysqldump non trouvé"
    exit 1
fi

# Vérifier le fichier de configuration
if [ ! -f "$MYSQL_CNF" ]; then
    log "ERROR" "Fichier de configuration $MYSQL_CNF introuvable"
    exit 1
fi

# Tester la connexion MySQL
if ! mysql --defaults-extra-file="$MYSQL_CNF" -e "SELECT 1" &> /dev/null; then
    log "ERROR" "Impossible de se connecter à MySQL"
    send_notification "❌ ERREUR Backup MySQL" "Connexion MySQL impossible"
    exit 1
fi

# ============================================================================
# PRÉPARATION
# ============================================================================

DATE=$(date +%Y%m%d_%H%M%S)
DATE_DAILY=$(date +%Y%m%d)
DATE_WEEKLY=$(date +%Y_W%U)
DATE_MONTHLY=$(date +%Y%m)
DAY_OF_WEEK=$(date +%u)
DAY_OF_MONTH=$(date +%d)

DAILY_DIR="$BACKUP_ROOT/daily"
WEEKLY_DIR="$BACKUP_ROOT/weekly"
MONTHLY_DIR="$BACKUP_ROOT/monthly"
LOG_DIR="$BACKUP_ROOT/logs"

# Créer les répertoires
mkdir -p "$DAILY_DIR" "$WEEKLY_DIR" "$MONTHLY_DIR" "$LOG_DIR"

log "INFO" "=========================================="
log "INFO" "Démarrage de la sauvegarde MySQL"
log "INFO" "=========================================="

# ============================================================================
# RÉCUPÉRATION DES BASES DE DONNÉES
# ============================================================================

log "INFO" "Récupération de la liste des bases de données..."

DATABASES=$(mysql --defaults-extra-file="$MYSQL_CNF" -sNe "SHOW DATABASES" | \
    grep -Ev "^(information_schema|performance_schema|mysql|sys)$")

if [ -z "$DATABASES" ]; then
    log "ERROR" "Aucune base de données à sauvegarder"
    exit 1
fi

TOTAL_DBS=$(echo "$DATABASES" | wc -l)
log "INFO" "Nombre de bases à sauvegarder: $TOTAL_DBS"

# ============================================================================
# SAUVEGARDE DES BASES
# ============================================================================

SUCCESS_COUNT=0
ERROR_COUNT=0
TOTAL_SIZE=0

for DB in $DATABASES; do
    log "INFO" "Traitement de la base: $DB"
    
    # Taille de la base
    DB_SIZE=$(get_database_size "$DB")
    log "INFO" "  Taille: ${DB_SIZE}MB"
    
    # Fichier de sauvegarde quotidienne
    BACKUP_FILE="$DAILY_DIR/${DB}_${DATE_DAILY}.sql.gz"
    
    # Exécuter mysqldump
    START_TIME=$(date +%s)
    
    if mysqldump --defaults-extra-file="$MYSQL_CNF" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --quick \
        "$DB" 2>"$LOG_DIR/${DB}_${DATE}.err" | gzip > "$BACKUP_FILE"; then
        
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        
        log "INFO" "  ✓ Succès en ${DURATION}s - Taille: $BACKUP_SIZE"
        
        # Vérifier l'intégrité du fichier compressé
        if gunzip -t "$BACKUP_FILE" 2>/dev/null; then
            log "INFO" "  ✓ Intégrité vérifiée"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            TOTAL_SIZE=$((TOTAL_SIZE + $(stat -f%z "$BACKUP_FILE" 2>/dev/null || stat -c%s "$BACKUP_FILE")))
        else
            log "ERROR" "  ✗ Fichier corrompu!"
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
        
        # Copie hebdomadaire (dimanche)
        if [ "$DAY_OF_WEEK" -eq 7 ]; then
            cp "$BACKUP_FILE" "$WEEKLY_DIR/${DB}_${DATE_WEEKLY}.sql.gz"
            log "INFO" "  → Copie hebdomadaire créée"
        fi
        
        # Copie mensuelle (1er du mois)
        if [ "$DAY_OF_MONTH" = "01" ]; then
            cp "$BACKUP_FILE" "$MONTHLY_DIR/${DB}_${DATE_MONTHLY}.sql.gz"
            log "INFO" "  → Copie mensuelle créée"
        fi
        
    else
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        log "ERROR" "  ✗ Échec après ${DURATION}s"
        cat "$LOG_DIR/${DB}_${DATE}.err" >> "$LOG_FILE"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
done

# ============================================================================
# NETTOYAGE DES ANCIENNES SAUVEGARDES
# ============================================================================

log "INFO" "Nettoyage des anciennes sauvegardes..."

# Quotidiennes > 7 jours
REMOVED_DAILY=$(find "$DAILY_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAILY -delete -print | wc -l)
log "INFO" "  Quotidiennes supprimées: $REMOVED_DAILY"

# Hebdomadaires > 28 jours
REMOVED_WEEKLY=$(find "$WEEKLY_DIR" -name "*.sql.gz" -mtime +$RETENTION_WEEKLY -delete -print | wc -l)
log "INFO" "  Hebdomadaires supprimées: $REMOVED_WEEKLY"

# Mensuelles > 365 jours
REMOVED_MONTHLY=$(find "$MONTHLY_DIR" -name "*.sql.gz" -mtime +$RETENTION_MONTHLY -delete -print | wc -l)
log "INFO" "  Mensuelles supprimées: $REMOVED_MONTHLY"

# Logs > 30 jours
find "$LOG_DIR" -name "*.err" -mtime +30 -delete

# ============================================================================
# RAPPORT FINAL
# ============================================================================

TOTAL_SIZE_MB=$((TOTAL_SIZE / 1024 / 1024))

log "INFO" "=========================================="
log "INFO" "Sauvegarde terminée"
log "INFO" "=========================================="
log "INFO" "Bases sauvegardées: $SUCCESS_COUNT/$TOTAL_DBS"
log "INFO" "Erreurs: $ERROR_COUNT"
log "INFO" "Taille totale: ${TOTAL_SIZE_MB}MB"
log "INFO" "Espace disque disponible:"
df -h "$BACKUP_ROOT" | tail -1 | awk '{print "  "$4" disponible sur "$6}' | tee -a "$LOG_FILE"

# Notification par email
if [ $ERROR_COUNT -eq 0 ]; then
    SUBJECT="✓ Sauvegarde MySQL réussie"
    BODY="Sauvegarde terminée avec succès
    
Résumé:
- Bases sauvegardées: $SUCCESS_COUNT/$TOTAL_DBS
- Taille totale: ${TOTAL_SIZE_MB}MB
- Durée: $(date -d @$(($(date +%s) - START_TIME)) -u +%H:%M:%S)
- Localisation: $BACKUP_ROOT"
else
    SUBJECT="⚠️ Sauvegarde MySQL avec erreurs"
    BODY="La sauvegarde a rencontré des erreurs
    
Résumé:
- Bases réussies: $SUCCESS_COUNT/$TOTAL_DBS
- Erreurs: $ERROR_COUNT
- Consultez le log: $LOG_FILE"
fi

send_notification "$SUBJECT" "$BODY"

# Code de sortie
if [ $ERROR_COUNT -eq 0 ]; then
    exit 0
else
    exit 1
fi
```

### Script de restauration /usr/local/bin/mysql-restore.sh

```bash
#!/bin/bash
#
# Script de restauration MySQL/MariaDB
# Usage: ./mysql-restore.sh <fichier_backup.sql.gz> [nom_base]
#

set -euo pipefail

MYSQL_CNF="/etc/mysql/backup.cnf"
LOG_FILE="/var/log/mysql-restore.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" | tee -a "$LOG_FILE"
}

# Vérifier les arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <fichier_backup.sql.gz> [nom_base]"
    echo "Exemple: $0 /var/backups/mysql/daily/wordpress_20241221.sql.gz"
    echo "         $0 /var/backups/mysql/daily/wordpress_20241221.sql.gz wordpress_restored"
    exit 1
fi

BACKUP_FILE="$1"
DB_NAME="${2:-}"

# Vérifications
if [ ! -f "$BACKUP_FILE" ]; then
    log "ERROR: Fichier $BACKUP_FILE introuvable"
    exit 1
fi

if [ ! -f "$MYSQL_CNF" ]; then
    log "ERROR: Fichier de configuration $MYSQL_CNF introuvable"
    exit 1
fi

log "=========================================="
log "Restauration MySQL"
log "=========================================="
log "Fichier: $BACKUP_FILE"

# Vérifier l'intégrité du fichier
log "Vérification de l'intégrité du fichier..."
if ! gunzip -t "$BACKUP_FILE" 2>/dev/null; then
    log "ERROR: Le fichier est corrompu!"
    exit 1
fi
log "✓ Intégrité OK"

# Déterminer le nom de la base
if [ -z "$DB_NAME" ]; then
    # Extraire du nom de fichier
    DB_NAME=$(basename "$BACKUP_FILE" | sed 's/_[0-9]*.sql.gz$//')
    log "Base de données cible: $DB_NAME (déduit du nom de fichier)"
else
    log "Base de données cible: $DB_NAME (spécifié)"
fi

# Confirmation
log ""
log "⚠️  ATTENTION ⚠️"
log "Cette opération va ÉCRASER toutes les données de la base '$DB_NAME'"
log ""
read -p "Confirmez-vous la restauration? (oui/non): " CONFIRM

if [ "$CONFIRM" != "oui" ]; then
    log "Restauration annulée par l'utilisateur"
    exit 0
fi

# Créer une sauvegarde de sécurité si la base existe
if mysql --defaults-extra-file="$MYSQL_CNF" -e "USE $DB_NAME" 2>/dev/null; then
    SAFETY_BACKUP="/tmp/${DB_NAME}_before_restore_$(date +%Y%m%d_%H%M%S).sql.gz"
    log "Création d'une sauvegarde de sécurité..."
    mysqldump --defaults-extra-file="$MYSQL_CNF" \
        --single-transaction --routines --triggers \
        "$DB_NAME" | gzip > "$SAFETY_BACKUP"
    log "✓ Sauvegarde de sécurité: $SAFETY_BACKUP"
fi

# Restauration
log "Démarrage de la restauration..."
START_TIME=$(date +%s)

if gunzip < "$BACKUP_FILE" | mysql --defaults-extra-file="$MYSQL_CNF" "$DB_NAME" 2>"$LOG_FILE.err"; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    log "=========================================="
    log "✓ Restauration réussie en ${DURATION}s"
    log "=========================================="
    
    # Statistiques
    TABLE_COUNT=$(mysql --defaults-extra-file="$MYSQL_CNF" -sNe \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME'")
    log "Tables restaurées: $TABLE_COUNT"
    
    exit 0
else
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    log "=========================================="
    log "✗ Échec de la restauration après ${DURATION}s"
    log "=========================================="
    log "Consultez les erreurs dans: $LOG_FILE.err"
    
    if [ -f "$SAFETY_BACKUP" ]; then
        log ""
        log "Une sauvegarde de sécurité est disponible:"
        log "  $SAFETY_BACKUP"
    fi
    
    exit 1
fi
```

### Rendre les scripts exécutables

```bash
chmod +x /usr/local/bin/mysql-backup.sh
chmod +x /usr/local/bin/mysql-restore.sh
```

### Configuration cron

```bash
# Éditer la crontab root
sudo crontab -e
```

```cron
# Sauvegarde MySQL quotidienne à 2h du matin
0 2 * * * /usr/local/bin/mysql-backup.sh

# Vérification hebdomadaire de l'espace disque (dimanche 1h)
0 1 * * 0 df -h /var/backups/mysql | mail -s "Espace disque backups MySQL" admin@example.com
```

---

## 🚀 Utilisation pratique

### Effectuer une sauvegarde manuelle

```bash
# Sauvegarde complète
sudo /usr/local/bin/mysql-backup.sh

# Voir les logs en temps réel
tail -f /var/log/mysql-backup.log
```

### Restaurer une base de données

```bash
# Lister les sauvegardes disponibles
ls -lh /var/backups/mysql/daily/

# Restaurer une base
sudo /usr/local/bin/mysql-restore.sh \
  /var/backups/mysql/daily/wordpress_20241221.sql.gz

# Restaurer vers une nouvelle base (pour tester)
sudo /usr/local/bin/mysql-restore.sh \
  /var/backups/mysql/daily/wordpress_20241221.sql.gz wordpress_test
```

### Vérifier l'état des sauvegardes

```bash
# Voir les dernières sauvegardes
find /var/backups/mysql -name "*.sql.gz" -mtime -7 -ls

# Espace utilisé par les sauvegardes
du -sh /var/backups/mysql/*

# Dernières lignes du log
tail -20 /var/log/mysql-backup.log
```

---

## 🎓 Conclusion

La sauvegarde et la restauration de bases de données MySQL/MariaDB sont des compétences **essentielles** pour tout administrateur système. Ce cours vous a présenté :

✅ **mysqldump** : l'outil standard flexible et portable  
✅ **Automatisation** : scripts robustes avec gestion d'erreurs  
✅ **Planification** : cron pour des sauvegardes régulières  
✅ **Rotation** : stratégie GFS (quotidien/hebdo/mensuel)  
✅ **Sécurité** : chiffrement, permissions, credentials sécurisés  
✅ **Bonnes pratiques** : tests réguliers, monitoring, documentation

> [!tip] Recommandation finale La meilleure sauvegarde est celle que vous **testez régulièrement**. Planifiez un exercice de restauration mensuel pour valider votre stratégie. Un jour, vous serez content de l'avoir fait ! 💾🔥