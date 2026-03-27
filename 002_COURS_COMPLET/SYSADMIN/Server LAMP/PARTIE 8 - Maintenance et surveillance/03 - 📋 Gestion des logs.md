

## 📚 Table des matières

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

## 🔍 Analyse des logs Apache

### Emplacement des fichiers de logs

Les logs Apache sont généralement stockés dans des emplacements standards selon la distribution :

```bash
# Debian/Ubuntu
/var/log/apache2/access.log
/var/log/apache2/error.log

# Red Hat/CentOS/Fedora
/var/log/httpd/access_log
/var/log/httpd/error_log

# Configuration personnalisée (vhosts)
/var/log/apache2/monsite-access.log
/var/log/apache2/monsite-error.log
```

> [!info] Pourquoi analyser les logs Apache ? Les logs Apache permettent de :
> 
> - Surveiller le trafic et identifier les pics d'activité
> - Détecter les tentatives d'intrusion ou les comportements suspects
> - Diagnostiquer les erreurs 404, 500, etc.
> - Analyser les performances et temps de réponse
> - Comprendre le comportement des utilisateurs

### Types de logs Apache

|Type de log|Fichier|Contenu|Usage|
|---|---|---|---|
|**Access log**|`access.log`|Toutes les requêtes HTTP|Trafic, statistiques, analyse comportementale|
|**Error log**|`error.log`|Erreurs serveur et application|Débogage, surveillance des incidents|
|**SSL log**|`ssl_access.log`|Requêtes HTTPS spécifiques|Sécurité, certificats|
|**Rewrite log**|`rewrite.log`|Règles mod_rewrite|Débogage URL rewriting|

### Formats de logs

#### Format Common Log Format (CLF)

```bash
# Exemple de ligne access.log
192.168.1.100 - - [22/Dec/2025:14:30:45 +0100] "GET /index.php HTTP/1.1" 200 5432
```

**Décomposition :**

- `192.168.1.100` : IP du client
- `-` : identd (généralement inutilisé)
- `-` : utilisateur authentifié
- `[22/Dec/2025:14:30:45 +0100]` : timestamp
- `"GET /index.php HTTP/1.1"` : requête HTTP
- `200` : code de statut HTTP
- `5432` : taille de la réponse en octets

#### Format Combined Log Format

```bash
# Format le plus utilisé (inclut referrer et user-agent)
192.168.1.100 - - [22/Dec/2025:14:30:45 +0100] "GET /index.php HTTP/1.1" 200 5432 "https://google.com" "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
```

#### Personnalisation du format de log

```apache
# Dans le fichier de configuration Apache
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %T" custom

# Variables disponibles :
# %h : IP du client
# %l : identd
# %u : utilisateur authentifié
# %t : timestamp
# %r : première ligne de la requête
# %>s : code de statut final
# %b : taille de la réponse
# %T : temps de traitement en secondes
# %D : temps de traitement en microsecondes
# %{VARIABLE}i : en-tête de requête
# %{VARIABLE}o : en-tête de réponse

# Application du format personnalisé
CustomLog /var/log/apache2/access.log custom
```

### Commandes d'analyse

#### Visualisation en temps réel

```bash
# Suivre les logs en temps réel
tail -f /var/log/apache2/access.log

# Suivre plusieurs fichiers simultanément
tail -f /var/log/apache2/access.log /var/log/apache2/error.log

# Filtrer en temps réel (uniquement erreurs 404)
tail -f /var/log/apache2/access.log | grep " 404 "

# Colorisation pour meilleure lisibilité
tail -f /var/log/apache2/error.log | grep --color=auto -E 'error|warn|critical'
```

#### Analyse des codes de statut HTTP

```bash
# Compter les codes de statut
awk '{print $9}' /var/log/apache2/access.log | sort | uniq -c | sort -rn

# Résultat exemple :
#   45234 200
#    1205 404
#     342 301
#      89 500

# Filtrer uniquement les erreurs (4xx et 5xx)
awk '$9 ~ /^[45]/ {print $9}' /var/log/apache2/access.log | sort | uniq -c | sort -rn

# Voir les URLs générant des erreurs 404
awk '$9 == 404 {print $7}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -20
```

#### Analyse du trafic

```bash
# Top 10 des IPs les plus actives
awk '{print $1}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -10

# Top 10 des pages les plus consultées
awk '{print $7}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -10

# Top 10 des user-agents
awk -F'"' '{print $6}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -10

# Requêtes par heure
awk '{print $4}' /var/log/apache2/access.log | cut -d: -f2 | sort | uniq -c

# Bande passante totale transférée (en octets)
awk '{sum+=$10} END {print sum}' /var/log/apache2/access.log

# Conversion en Mo/Go
awk '{sum+=$10} END {print sum/1024/1024 " Mo"}' /var/log/apache2/access.log
```

#### Détection de menaces et comportements suspects

```bash
# Détecter les scans de vulnérabilités (nombreuses 404 depuis une IP)
awk '$9 == 404 {print $1}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | awk '$1 > 50'

# Détecter les tentatives SQL injection
grep -i "union.*select\|concat.*char\|' or 1=1" /var/log/apache2/access.log

# Détecter les tentatives XSS
grep -i "<script\|javascript:" /var/log/apache2/access.log

# Requêtes anormalement longues (potentiel DoS)
awk '$NF > 10 {print}' /var/log/apache2/access.log  # Temps > 10 secondes
```

#### Analyse des erreurs

```bash
# Erreurs les plus fréquentes
grep -i error /var/log/apache2/error.log | cut -d] -f3- | sort | uniq -c | sort -rn | head -20

# Erreurs PHP spécifiques
grep "PHP" /var/log/apache2/error.log | tail -50

# Filtrer par niveau de sévérité
grep "\[error\]" /var/log/apache2/error.log    # Erreurs
grep "\[warn\]" /var/log/apache2/error.log     # Avertissements
grep "\[notice\]" /var/log/apache2/error.log   # Notices
grep "\[crit\]" /var/log/apache2/error.log     # Critiques
```

> [!tip] Astuce : Créer des alias pour les commandes fréquentes
> 
> ```bash
> # Dans ~/.bashrc ou ~/.bash_aliases
> alias apache-watch='tail -f /var/log/apache2/access.log'
> alias apache-errors='tail -f /var/log/apache2/error.log'
> alias apache-top-ips='awk "{print \$1}" /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -20'
> alias apache-404='awk "\$9 == 404 {print \$7}" /var/log/apache2/access.log | sort | uniq -c | sort -rn'
> ```

### Outils d'analyse avancés

#### GoAccess - Analyseur en temps réel

```bash
# Installation
sudo apt install goaccess         # Debian/Ubuntu
sudo yum install goaccess         # CentOS/RHEL

# Analyse interactive en terminal
goaccess /var/log/apache2/access.log --log-format=COMBINED

# Génération d'un rapport HTML
goaccess /var/log/apache2/access.log --log-format=COMBINED -o /var/www/html/report.html

# Analyse en temps réel avec mise à jour automatique
goaccess /var/log/apache2/access.log --log-format=COMBINED -o /var/www/html/report.html --real-time-html

# Analyse de logs compressés
zcat /var/log/apache2/access.log.*.gz | goaccess --log-format=COMBINED

# Configuration personnalisée (créer ~/.goaccessrc)
time-format %H:%M:%S
date-format %d/%b/%Y
log-format COMBINED
```

> [!example] Exemple de rapport GoAccess GoAccess affiche automatiquement :
> 
> - Visites uniques et pages vues
> - Fichiers les plus demandés
> - Pages d'entrée et de sortie
> - Top visiteurs par IP
> - Systèmes d'exploitation et navigateurs
> - Codes de statut HTTP
> - Distribution horaire du trafic

#### AWStats - Statistiques détaillées

```bash
# Installation
sudo apt install awstats          # Debian/Ubuntu

# Configuration de base
sudo cp /etc/awstats/awstats.conf /etc/awstats/awstats.monsite.conf

# Éditer la configuration
sudo nano /etc/awstats/awstats.monsite.conf
```

```perl
# Configuration AWStats
LogFile="/var/log/apache2/access.log"
LogFormat=1                      # Format Combined
SiteDomain="monsite.com"
HostAliases="www.monsite.com localhost"
DirData="/var/lib/awstats"
DirIcons="/awstats-icon"
AllowToUpdateStatsFromBrowser=0  # Sécurité
```

```bash
# Génération des statistiques
sudo /usr/lib/cgi-bin/awstats.pl -config=monsite -update

# Automatisation via cron (tous les jours à 6h00)
echo "0 6 * * * root /usr/lib/cgi-bin/awstats.pl -config=monsite -update > /dev/null" | sudo tee /etc/cron.d/awstats
```

#### Webalizer - Rapports visuels

```bash
# Installation
sudo apt install webalizer

# Configuration
sudo nano /etc/webalizer/webalizer.conf
```

```conf
LogFile     /var/log/apache2/access.log
OutputDir   /var/www/html/webalizer
HostName    monsite.com
Incremental yes
IncrementalName /var/lib/webalizer/webalizer.current
HistoryName     /var/lib/webalizer/webalizer.hist
```

```bash
# Génération du rapport
sudo webalizer

# Automatisation
echo "0 5 * * * root /usr/bin/webalizer > /dev/null 2>&1" | sudo tee /etc/cron.d/webalizer
```

> [!warning] Sécurisation des rapports Les rapports générés contiennent des informations sensibles :
> 
> ```apache
> # Protéger l'accès aux rapports dans Apache
> <Directory /var/www/html/report>
>     AuthType Basic
>     AuthName "Statistiques - Accès restreint"
>     AuthUserFile /etc/apache2/.htpasswd
>     Require valid-user
> </Directory>
> ```
> 
> ```bash
> # Créer le fichier de mots de passe
> sudo htpasswd -c /etc/apache2/.htpasswd admin
> ```

#### Logwatch - Résumés quotidiens par email

```bash
# Installation
sudo apt install logwatch

# Configuration
sudo nano /etc/logwatch/conf/logwatch.conf
```

```conf
# Configuration Logwatch
Output = mail
Format = html
MailTo = admin@monsite.com
MailFrom = logwatch@monsite.com
Detail = Med                   # Low, Med, High
Service = apache
Range = yesterday
```

```bash
# Test manuel
sudo logwatch --detail High --service apache --range today

# Logwatch s'exécute automatiquement via cron quotidiennement
```

> [!tip] Analyse multi-fichiers
> 
> ```bash
> # Analyser tous les logs d'un mois
> zcat /var/log/apache2/access.log.{1..30}.gz /var/log/apache2/access.log | goaccess --log-format=COMBINED
> 
> # Combiner plusieurs vhosts
> cat /var/log/apache2/site1-access.log /var/log/apache2/site2-access.log | goaccess --log-format=COMBINED
> ```

---

## 🗄️ Logs MySQL/MariaDB

### Types de logs MySQL/MariaDB

MySQL/MariaDB dispose de plusieurs types de logs pour différents besoins de surveillance et de débogage :

|Type de log|Fichier|Utilité|Impact performance|
|---|---|---|---|
|**Error log**|`error.log`|Erreurs de démarrage, arrêts, problèmes critiques|Minimal|
|**General query log**|`general.log`|Toutes les requêtes SQL|**Très élevé** ⚠️|
|**Slow query log**|`slow-query.log`|Requêtes lentes à optimiser|Faible à modéré|
|**Binary log**|`mysql-bin.*`|Réplication et point-in-time recovery|Modéré|
|**Relay log**|`relay-bin.*`|Réplication (serveurs esclaves)|Modéré|

> [!warning] General Query Log - À éviter en production Le **general query log** enregistre **TOUTES** les requêtes, ce qui :
> 
> - Ralentit considérablement les performances
> - Génère des fichiers énormes rapidement
> - Ne devrait être activé que temporairement pour le débogage
> - Privilégier le **slow query log** pour l'analyse de performance

### Configuration des logs

#### Vérifier la configuration actuelle

```bash
# Se connecter à MySQL
mysql -u root -p

# Vérifier l'état des logs
SHOW VARIABLES LIKE '%log%';

# Vérifier spécifiquement les logs importants
SHOW VARIABLES LIKE 'log_error';
SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'long_query_time';
SHOW VARIABLES LIKE 'general_log';
```

#### Configuration du Error Log

```bash
# Éditer la configuration MySQL
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf    # Debian/Ubuntu
sudo nano /etc/my.cnf                            # CentOS/RHEL
```

```ini
[mysqld]
# Error Log - Toujours activé par défaut
log_error = /var/log/mysql/error.log

# Niveau de verbosité (1 = erreurs, 2 = erreurs + warnings, 3 = tout)
log_error_verbosity = 2
```

```bash
# Redémarrer MySQL pour appliquer
sudo systemctl restart mysql
```

#### Configuration du Slow Query Log

```ini
[mysqld]
# Activer le log des requêtes lentes
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow-query.log

# Définir le seuil de lenteur (en secondes)
long_query_time = 2                    # Requêtes > 2 secondes

# Enregistrer aussi les requêtes n'utilisant pas d'index
log_queries_not_using_indexes = 1

# Limiter le nombre de requêtes sans index loggées par minute
log_throttle_queries_not_using_indexes = 5

# Enregistrer les requêtes administratives lentes (OPTIMIZE, ANALYZE...)
log_slow_admin_statements = 1

# Enregistrer les requêtes esclaves lentes (réplication)
log_slow_slave_statements = 1
```

> [!tip] Ajuster long_query_time selon vos besoins
> 
> - **Sites à fort trafic** : 0.5 à 1 seconde
> - **Applications standard** : 2 à 5 secondes
> - **Débogage intensif** : 0.1 seconde (temporairement)
> - Peut être un nombre décimal : `long_query_time = 0.5`

#### Configuration du General Query Log (débogage uniquement)

```ini
[mysqld]
# ⚠️ N'activer que temporairement !
general_log = 0                        # 0 = désactivé, 1 = activé
general_log_file = /var/log/mysql/general.log
```

```bash
# Activation dynamique sans redémarrage (session temporaire)
mysql -u root -p

SET GLOBAL general_log = 1;

# Faire les tests nécessaires...

# Désactiver immédiatement après
SET GLOBAL general_log = 0;
```

#### Configuration du Binary Log (réplication/backup)

```ini
[mysqld]
# Activer les binary logs
log_bin = /var/log/mysql/mysql-bin
server-id = 1                          # Unique pour chaque serveur

# Durée de conservation (en jours)
expire_logs_days = 7

# Taille maximale avant rotation
max_binlog_size = 100M

# Format (ROW, STATEMENT, MIXED)
binlog_format = MIXED
```

> [!info] Pourquoi activer les binary logs ?
> 
> - **Réplication** : synchroniser plusieurs serveurs MySQL
> - **Point-in-time recovery** : restaurer la base à un moment précis
> - **Audit** : tracer les modifications de données
> - Coût : augmente légèrement l'utilisation disque et la latence

### Analyse des logs de requêtes lentes

#### Visualisation directe

```bash
# Afficher les dernières requêtes lentes
tail -100 /var/log/mysql/slow-query.log

# Suivre en temps réel
tail -f /var/log/mysql/slow-query.log

# Compter le nombre de requêtes lentes
grep "Query_time" /var/log/mysql/slow-query.log | wc -l
```

#### Structure d'une entrée slow query log

```sql
# Time: 2025-12-22T14:35:42.123456Z
# User@Host: webapp[webapp] @ localhost []
# Query_time: 5.234567  Lock_time: 0.000123  Rows_sent: 15000  Rows_examined: 450000
SET timestamp=1703254542;
SELECT users.*, orders.* 
FROM users 
LEFT JOIN orders ON users.id = orders.user_id 
WHERE users.created_at > '2024-01-01';
```

**Décomposition :**

- `Query_time: 5.234567` : temps d'exécution total
- `Lock_time: 0.000123` : temps d'attente de verrou
- `Rows_sent: 15000` : lignes renvoyées au client
- `Rows_examined: 450000` : lignes analysées (ratio important !)

> [!warning] Ratio Rows_examined / Rows_sent Un ratio élevé indique une requête inefficace :
> 
> - Ratio < 10 : bon
> - Ratio 10-100 : acceptable
> - Ratio > 100 : **à optimiser impérativement**
> 
> Exemple ci-dessus : 450000/15000 = 30 (à surveiller)

#### Outil mysqldumpslow - Analyse automatique

```bash
# Installer si nécessaire (généralement inclus)
which mysqldumpslow

# Afficher les 10 requêtes les plus lentes
mysqldumpslow -t 10 /var/log/mysql/slow-query.log

# Trier par temps total d'exécution (plutôt que temps moyen)
mysqldumpslow -s t -t 10 /var/log/mysql/slow-query.log

# Trier par nombre de verrous
mysqldumpslow -s l -t 10 /var/log/mysql/slow-query.log

# Trier par nombre d'appels
mysqldumpslow -s c -t 10 /var/log/mysql/slow-query.log

# Afficher seulement les requêtes > 10 secondes
mysqldumpslow -t 10 -s t /var/log/mysql/slow-query.log | grep "Query_time.*[1-9][0-9]"
```

**Options principales :**

- `-s` : méthode de tri (t=time, c=count, l=lock, r=rows)
- `-t N` : afficher les N premières requêtes
- `-a` : ne pas abstraire les nombres et chaînes
- `-g PATTERN` : filtrer par motif regex

> [!example] Exemple de sortie mysqldumpslow
> 
> ```bash
> Count: 245  Time=4.56s (1117s)  Lock=0.00s (0s)  Rows=1250.3 (306324), webapp[webapp]@localhost
>   SELECT * FROM orders WHERE user_id=N AND status='S'
> 
> Count: 89   Time=12.34s (1098s)  Lock=0.02s (1s)  Rows=450.0 (40050), webapp[webapp]@localhost
>   SELECT users.*, COUNT(orders.id) FROM users LEFT JOIN orders ON users.id=orders.user_id GROUP BY users.id
> ```
> 
> - **Count** : nombre d'exécutions
> - **Time** : temps moyen (temps total)
> - **Rows** : lignes moyennes (lignes totales)

#### Outil pt-query-digest (Percona Toolkit)

```bash
# Installation
sudo apt install percona-toolkit

# Analyse détaillée avec statistiques
pt-query-digest /var/log/mysql/slow-query.log

# Sauvegarder le rapport dans un fichier
pt-query-digest /var/log/mysql/slow-query.log > analyse-requetes.txt

# Analyser uniquement les requêtes SELECT
pt-query-digest --filter '$event->{arg} =~ m/^SELECT/i' /var/log/mysql/slow-query.log

# Créer un rapport HTML
pt-query-digest --output=html /var/log/mysql/slow-query.log > rapport.html

# Analyser en temps réel
pt-query-digest --processlist h=localhost,u=root,p=password --run-time=60
```

> [!tip] pt-query-digest vs mysqldumpslow **pt-query-digest** est plus puissant :
> 
> - Statistiques détaillées (médianes, 95e percentile)
> - Détection de variabilité des performances
> - Analyse des plans d'exécution
> - Export vers bases de données ou HTML
> - Conseils d'optimisation
> 
> Privilégier **pt-query-digest** pour l'analyse approfondie.

#### Identifier les optimisations nécessaires

```bash
# Requêtes avec le plus grand nombre de lignes examinées
mysqldumpslow -s r -t 20 /var/log/mysql/slow-query.log

# Requêtes les plus fréquentes
mysqldumpslow -s c -t 20 /var/log/mysql/slow-query.log

# Combiner avec grep pour filtrer
mysqldumpslow -s t /var/log/mysql/slow-query.log | grep "SELECT.*JOIN"
```

```sql
-- Une fois les requêtes identifiées, analyser avec EXPLAIN
EXPLAIN SELECT users.*, orders.* 
FROM users 
LEFT JOIN orders ON users.id = orders.user_id 
WHERE users.created_at > '2024-01-01';

-- Vérifier les index manquants
SHOW INDEX FROM users;
SHOW INDEX FROM orders;

-- Créer les index nécessaires
CREATE INDEX idx_created_at ON users(created_at);
CREATE INDEX idx_user_id ON orders(user_id);
```

> [!tip] Workflow d'optimisation
> 
> 1. Identifier les requêtes lentes avec `mysqldumpslow` ou `pt-query-digest`
> 2. Analyser avec `EXPLAIN` pour comprendre le plan d'exécution
> 3. Ajouter les index manquants
> 4. Réécrire les requêtes inefficaces
> 5. Vérifier l'amélioration dans les logs

### Logs d'erreurs MySQL

#### Analyse des erreurs courantes

```bash
# Afficher les erreurs récentes
tail -100 /var/log/mysql/error.log

# Rechercher des types d'erreurs spécifiques
grep -i "error" /var/log/mysql/error.log
grep -i "warning" /var/log/mysql/error.log
grep -i "crash" /var/log/mysql/error.log
grep -i "deadlock" /var/log/mysql/error.log

# Compter les occurrences d'erreurs
grep -i "error" /var/log/mysql/error.log | cut -d']' -f2 | sort | uniq -c | sort -rn

# Erreurs de connexion
grep "Access denied" /var/log/mysql/error.log
grep "Too many connections" /var/log/mysql/error.log

# Problèmes de tables
grep "Table.*crashed" /var/log/mysql/error.log
grep "Table.*marked as crashed" /var/log/mysql/error.log
```

#### Erreurs critiques à surveiller

|Erreur|Signification|Action|
|---|---|---|
|`Too many connections`|Limite de connexions atteinte|Augmenter `max_connections`|
|`Out of memory`|Mémoire insuffisante|Optimiser `innodb_buffer_pool_size`|
|`Table 'X' is marked as crashed`|Table corrompue|Exécuter `REPAIR TABLE`|
|`Deadlock found`|Conflit de verrous|Optimiser les transactions|
|`Disk is full`|Espace disque saturé|Nettoyer les logs/données|
|`Access denied for user`|Problème d'authentification|Vérifier les privilèges|

#### Surveillance automatique des erreurs

```bash
# Script de surveillance à exécuter régulièrement
cat > /usr/local/bin/mysql-error-monitor.sh << 'EOF'
#!/bin/bash

LOG_FILE="/var/log/mysql/error.log"
ALERT_EMAIL="admin@monsite.com"
TEMP_FILE="/tmp/mysql-errors-$(date +%Y%m%d).tmp"

# Erreurs critiques à surveiller
PATTERNS=(
    "crashed"
    "Too many connections"
    "Out of memory"
    "Deadlock"
    "Disk.*full"
)

# Chercher les nouvelles erreurs depuis la dernière exécution
if [ -f "$TEMP_FILE" ]; then
    LAST_SIZE=$(cat "$TEMP_FILE")
else
    LAST_SIZE=0
fi

CURRENT_SIZE=$(wc -c < "$LOG_FILE")
echo "$CURRENT_SIZE" > "$TEMP_FILE"

if [ "$CURRENT_SIZE" -gt "$LAST_SIZE" ]; then
    NEW_LINES=$(tail -c +$((LAST_SIZE + 1)) "$LOG_FILE")
    
    for PATTERN in "${PATTERNS[@]}"; do
        MATCHES=$(echo "$NEW_LINES" | grep -i "$PATTERN")
        if [ -n "$MATCHES" ]; then
            echo "$MATCHES" | mail -s "MySQL Alert: $PATTERN detected" "$ALERT_EMAIL"
        fi
    done
fi
EOF

chmod +x /usr/local/bin/mysql-error-monitor.sh

# Exécution toutes les 15 minutes via cron
echo "*/15 * * * * /usr/local/bin/mysql-error-monitor.sh" | sudo crontab -
```

> [!info] Intégration avec les outils de monitoring Pour une surveillance professionnelle, intégrer MySQL avec :
> 
> - **Prometheus + Grafana** : métriques en temps réel
> - **Nagios/Icinga** : alertes configurables
> - **Zabbix** : monitoring complet
> - **MySQL Enterprise Monitor** : solution commerciale officielle

---

## 🔄 Rotation automatique des logs

### Principe de la rotation

La rotation des logs consiste à :

1. **Archiver** les logs actuels en les renommant
2. **Compresser** les anciens logs pour économiser l'espace
3. **Créer** de nouveaux fichiers de logs vides
4. **Supprimer** les logs trop anciens selon la rétention définie

> [!info] Pourquoi faire la rotation des logs ?
> 
> - **Éviter la saturation disque** : les logs peuvent croître de plusieurs Go par jour
> - **Faciliter l'analyse** : travailler sur des fichiers de taille raisonnable
> - **Respecter les contraintes légales** : durée de conservation des données
> - **Optimiser les performances** : fichiers plus petits = accès plus rapide
> - **Archivage organisé** : retrouver facilement les logs d'une période donnée

### Configuration de logrotate

**logrotate** est l'outil standard sous Linux pour gérer la rotation automatique des logs.

#### Emplacement des fichiers de configuration

```bash
# Configuration principale
/etc/logrotate.conf

# Configurations spécifiques par application
/etc/logrotate.d/apache2
/etc/logrotate.d/mysql-server

# Fichier d'état (dernière rotation)
/var/lib/logrotate/status
```

#### Structure d'une configuration logrotate

```bash
# Syntaxe générale
/chemin/vers/fichier.log {
    # Fréquence de rotation
    daily|weekly|monthly
    
    # Nombre de fichiers à conserver
    rotate 7
    
    # Compression
    compress
    delaycompress
    
    # Gestion des fichiers manquants
    missingok
    notifempty
    
    # Permissions du nouveau fichier
    create 0640 www-data adm
    
    # Actions personnalisées
    postrotate
        # commandes à exécuter après rotation
    endscript
}
```

#### Options principales de logrotate

|Option|Description|Exemple|
|---|---|---|
|`daily`|Rotation quotidienne|-|
|`weekly`|Rotation hebdomadaire (lundi)|-|
|`monthly`|Rotation mensuelle (1er du mois)|-|
|`rotate N`|Conserver N anciennes versions|`rotate 14`|
|`size NM`|Rotation si taille > N Mo|`size 100M`|
|`maxsize NM`|Rotation même avant échéance si taille dépassée|`maxsize 500M`|
|`compress`|Compresser les anciens logs (gzip)|-|
|`delaycompress`|Compresser seulement au cycle suivant|-|
|`nocompress`|Ne pas compresser|-|
|`missingok`|Ne pas générer d'erreur si log absent|-|
|`notifempty`|Ne pas effectuer rotation si fichier vide|-|
|`create MODE USER GROUP`|Créer nouveau fichier avec permissions|`create 0640 www-data adm`|
|`copytruncate`|Copier puis vider le fichier (évite redémarrage)|-|
|`dateext`|Ajouter date dans nom fichier|`access.log-20251222`|
|`dateformat`|Format de la date|`dateformat -%Y%m%d-%s`|
|`sharedscripts`|Exécuter scripts une seule fois pour tous les fichiers|-|

> [!warning] copytruncate vs create
> 
> - **create** (recommandé) : renomme le fichier, en crée un nouveau → nécessite souvent un signal au service
> - **copytruncate** : copie et vide le fichier → évite le redémarrage mais risque de perte de logs pendant la copie
> - Pour Apache et MySQL, privilégier **create** avec script de rechargement

### Rotation des logs Apache

#### Configuration par défaut

```bash
# Vérifier la configuration actuelle
cat /etc/logrotate.d/apache2
```

```bash
/var/log/apache2/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    postrotate
        if invoke-rc.d apache2 status > /dev/null 2>&1; then \
            invoke-rc.d apache2 reload > /dev/null 2>&1; \
        fi
    endscript
}
```

> [!info] Explication de la configuration Apache
> 
> - `daily` : rotation chaque jour
> - `rotate 14` : garde 14 jours d'historique
> - `compress` : compresse les anciens logs
> - `delaycompress` : ne compresse pas le log d'hier (permet analyse immédiate)
> - `postrotate` : recharge Apache après rotation pour qu'il utilise le nouveau fichier

#### Configuration personnalisée pour sites à fort trafic

```bash
# Éditer ou créer une configuration spécifique
sudo nano /etc/logrotate.d/apache2-custom
```

```bash
# Site à très fort trafic - rotation par taille
/var/log/apache2/site-haute-charge-access.log {
    size 500M              # Rotation dès 500 Mo
    rotate 30              # Garder 30 fichiers
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    dateext
    dateformat -%Y%m%d-%s
    postrotate
        /usr/sbin/apache2ctl graceful > /dev/null 2>&1
    endscript
}

# Logs d'erreur - rotation hebdomadaire
/var/log/apache2/*-error.log {
    weekly
    rotate 8               # 8 semaines = 2 mois
    compress
    delaycompress
    notifempty
    missingok
    create 0640 www-data adm
    sharedscripts
    postrotate
        /usr/sbin/apache2ctl graceful > /dev/null 2>&1
    endscript
}

# Logs de développement - rotation quotidienne courte rétention
/var/log/apache2/dev-*.log {
    daily
    rotate 3               # Garder seulement 3 jours
    compress
    notifempty
    missingok
    create 0640 www-data adm
    postrotate
        /usr/sbin/apache2ctl graceful > /dev/null 2>&1
    endscript
}
```

> [!tip] apache2ctl graceful vs reload
> 
> - **graceful** : termine les requêtes en cours avant de recharger → pas d'interruption
> - **reload** : recharge immédiatement → plus rapide mais peut interrompre requêtes
> - **restart** : redémarrage complet → à éviter pour la rotation
> 
> Privilégier `graceful` pour la rotation de logs.

#### Configuration pour logs séparés par vhost

```bash
# Rotation distincte pour chaque site
sudo nano /etc/logrotate.d/apache2-vhosts
```

```bash
# Site principal - rétention longue
/var/log/apache2/monsite.com-access.log
/var/log/apache2/monsite.com-error.log {
    daily
    rotate 90              # 3 mois
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    dateext
    sharedscripts
    postrotate
        /usr/sbin/apache2ctl graceful > /dev/null 2>&1
    endscript
}

# Sites secondaires - rétention courte
/var/log/apache2/blog.monsite.com-*.log
/var/log/apache2/dev.monsite.com-*.log {
    weekly
    rotate 4               # 4 semaines
    compress
    notifempty
    create 0640 www-data adm
    sharedscripts
    postrotate
        /usr/sbin/apache2ctl graceful > /dev/null 2>&1
    endscript
}
```

### Rotation des logs MySQL

#### Configuration par défaut

```bash
# Vérifier la configuration MySQL
cat /etc/logrotate.d/mysql-server
```

```bash
/var/log/mysql/mysql.log
/var/log/mysql/error.log {
    daily
    rotate 7
    missingok
    create 0640 mysql adm
    compress
    postrotate
        test -x /usr/bin/mysqladmin || exit 0
        if /usr/bin/mysqladmin ping > /dev/null 2>&1; then
            /usr/bin/mysqladmin flush-logs
        fi
    endscript
}
```

> [!info] mysqladmin flush-logs La commande `mysqladmin flush-logs` indique à MySQL de :
> 
> - Fermer les fichiers de logs actuels
> - Créer de nouveaux fichiers de logs
> - Commencer à écrire dans les nouveaux fichiers
> 
> C'est préférable à un redémarrage complet du serveur.

#### Configuration optimisée pour production

```bash
sudo nano /etc/logrotate.d/mysql-custom
```

```bash
# Error log - rotation quotidienne
/var/log/mysql/error.log {
    daily
    rotate 30              # 30 jours
    missingok
    notifempty
    compress
    delaycompress
    create 0640 mysql adm
    postrotate
        test -x /usr/bin/mysqladmin || exit 0
        /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf flush-logs 2>/dev/null
    endscript
}

# Slow query log - rotation hebdomadaire
/var/log/mysql/slow-query.log {
    weekly
    rotate 12              # 12 semaines = 3 mois
    missingok
    notifempty
    compress
    create 0640 mysql adm
    postrotate
        test -x /usr/bin/mysqladmin || exit 0
        /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf flush-logs 2>/dev/null
    endscript
}

# General query log - rotation par taille (si activé temporairement)
/var/log/mysql/general.log {
    size 100M              # Rotation rapide car croissance rapide
    rotate 3               # Garder peu de temps
    missingok
    notifempty
    compress
    create 0640 mysql adm
    postrotate
        test -x /usr/bin/mysqladmin || exit 0
        /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf flush-logs 2>/dev/null
    endscript
}
```

#### Rotation des binary logs MySQL

```bash
# Les binary logs nécessitent une approche différente
sudo nano /etc/logrotate.d/mysql-binlog
```

```bash
# Binary logs - gérés par MySQL lui-même
# Ne PAS utiliser logrotate standard pour les binlogs !
# À la place, configurer dans /etc/mysql/mysql.conf.d/mysqld.cnf :
#
# expire_logs_days = 7
# max_binlog_size = 100M
#
# Ou via SQL pour purge manuel :
# PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);
```

> [!warning] Ne jamais utiliser logrotate pour les binary logs Les **binary logs** sont critiques pour :
> 
> - La réplication entre serveurs
> - Le point-in-time recovery
> 
> Ils doivent être gérés **uniquement par MySQL** via :
> 
> - `expire_logs_days` dans la configuration
> - `PURGE BINARY LOGS` en SQL
> - Jamais avec logrotate (risque de corruption)

#### Script personnalisé pour archivage avant rotation

```bash
# Script d'archivage avant rotation
sudo nano /usr/local/bin/mysql-log-archive.sh
```

```bash
#!/bin/bash
# Archiver les logs MySQL avant rotation

ARCHIVE_DIR="/backup/mysql-logs"
LOG_DIR="/var/log/mysql"
DATE=$(date +%Y%m%d)

# Créer le répertoire d'archive
mkdir -p "$ARCHIVE_DIR/$DATE"

# Copier les logs actuels avant rotation
cp "$LOG_DIR/slow-query.log" "$ARCHIVE_DIR/$DATE/" 2>/dev/null
cp "$LOG_DIR/error.log" "$ARCHIVE_DIR/$DATE/" 2>/dev/null

# Compresser l'archive
cd "$ARCHIVE_DIR"
tar -czf "mysql-logs-$DATE.tar.gz" "$DATE/"
rm -rf "$DATE"

# Supprimer les archives > 90 jours
find "$ARCHIVE_DIR" -name "mysql-logs-*.tar.gz" -mtime +90 -delete

echo "Archive MySQL logs: $ARCHIVE_DIR/mysql-logs-$DATE.tar.gz"
```

```bash
chmod +x /usr/local/bin/mysql-log-archive.sh
```

```bash
# Appeler le script dans la rotation
sudo nano /etc/logrotate.d/mysql-custom
```

```bash
/var/log/mysql/slow-query.log {
    weekly
    rotate 12
    prerotate
        /usr/local/bin/mysql-log-archive.sh
    endscript
    postrotate
        /usr/bin/mysqladmin flush-logs
    endscript
}
```

### Vérification et tests

#### Tester la configuration logrotate

```bash
# Vérifier la syntaxe de la configuration
sudo logrotate -d /etc/logrotate.conf

# Tester une configuration spécifique sans l'exécuter
sudo logrotate -d /etc/logrotate.d/apache2

# Tester avec verbose pour voir les détails
sudo logrotate -dv /etc/logrotate.d/mysql-server

# Forcer la rotation manuellement (mode debug)
sudo logrotate -d -f /etc/logrotate.d/apache2

# Forcer la rotation réellement
sudo logrotate -f /etc/logrotate.d/apache2
```

> [!tip] Options de test logrotate
> 
> - `-d` (--debug) : mode test, n'effectue pas les rotations
> - `-v` (--verbose) : affiche les détails des opérations
> - `-f` (--force) : force la rotation même si les conditions ne sont pas remplies
> - `-s` (--state) : spécifier un fichier d'état alternatif

#### Vérifier l'état des rotations

```bash
# Voir quand la dernière rotation a eu lieu
sudo cat /var/lib/logrotate/status

# Rechercher un fichier spécifique
sudo cat /var/lib/logrotate/status | grep apache

# Exemple de sortie :
# "/var/log/apache2/access.log" 2025-12-22-6:25:1
# "/var/log/apache2/error.log" 2025-12-22-6:25:1
```

#### Vérifier les logs après rotation

```bash
# Lister les logs Apache avec dates
ls -lh /var/log/apache2/

# Résultat attendu :
# -rw-r----- 1 www-data adm  0 Dec 22 06:25 access.log
# -rw-r----- 1 www-data adm  5.2M Dec 21 23:59 access.log.1
# -rw-r----- 1 www-data adm  2.1M Dec 20 23:59 access.log.2.gz
# -rw-r----- 1 www-data adm  3.4M Dec 19 23:59 access.log.3.gz

# Vérifier les permissions
stat /var/log/apache2/access.log

# Vérifier qu'Apache écrit bien dans le nouveau fichier
sudo lsof | grep /var/log/apache2/access.log
```

#### Surveillance de l'espace disque

```bash
# Vérifier l'espace disque utilisé par les logs
du -sh /var/log/apache2
du -sh /var/log/mysql

# Détail par fichier
du -h /var/log/apache2/* | sort -rh | head -10

# Vérifier l'espace disque total disponible
df -h /var/log

# Créer un script de surveillance
cat > /usr/local/bin/check-log-space.sh << 'EOF'
#!/bin/bash
THRESHOLD=80
USAGE=$(df /var/log | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "ALERTE: Espace disque /var/log à ${USAGE}% (seuil: ${THRESHOLD}%)"
    du -sh /var/log/*/* | sort -rh | head -20
    exit 1
fi
EOF

chmod +x /usr/local/bin/check-log-space.sh

# Exécution quotidienne
echo "0 8 * * * /usr/local/bin/check-log-space.sh" | sudo crontab -
```

#### Tester le postrotate

```bash
# Tester que Apache recharge bien après rotation
sudo logrotate -f /etc/logrotate.d/apache2

# Vérifier dans les logs système
sudo journalctl -u apache2 -n 20

# Vérifier que MySQL flush bien les logs
sudo logrotate -f /etc/logrotate.d/mysql-server

# Vérifier la connexion MySQL
sudo mysqladmin ping
sudo mysqladmin status
```

#### Automatisation des vérifications

```bash
# Script de vérification post-rotation
cat > /usr/local/bin/verify-logrotate.sh << 'EOF'
#!/bin/bash

echo "=== Vérification rotation des logs ==="
echo ""

# Vérifier Apache
echo "Logs Apache:"
ls -lh /var/log/apache2/*.log | tail -5
echo ""

# Vérifier MySQL
echo "Logs MySQL:"
ls -lh /var/log/mysql/*.log | tail -5
echo ""

# Vérifier les services
echo "Statut Apache:"
systemctl is-active apache2
echo ""

echo "Statut MySQL:"
systemctl is-active mysql
echo ""

# Vérifier espace disque
echo "Espace disque /var/log:"
df -h /var/log | tail -1
echo ""

# Vérifier anciennes rotations
echo "Nombre de fichiers .gz (archives):"
find /var/log -name "*.gz" | wc -l
echo ""

# Dernière rotation logrotate
echo "Dernière exécution logrotate:"
grep "$(date +%Y-%m-%d)" /var/lib/logrotate/status | head -5

EOF

chmod +x /usr/local/bin/verify-logrotate.sh

# Exécuter après chaque rotation (le matin)
echo "30 6 * * * /usr/local/bin/verify-logrotate.sh | mail -s 'Rapport rotation logs' admin@monsite.com" | sudo crontab -
```

> [!tip] Planification de logrotate logrotate s'exécute automatiquement via :
> 
> - **Debian/Ubuntu** : `/etc/cron.daily/logrotate` (vers 6h25)
> - **CentOS/RHEL** : `/etc/cron.daily/logrotate`
> 
> Pour changer l'heure d'exécution :
> 
> ```bash
> # Déplacer vers cron.hourly pour exécution horaire
> sudo mv /etc/cron.daily/logrotate /etc/cron.hourly/
> 
> # Ou créer un cron spécifique
> echo "0 3 * * * /usr/sbin/logrotate /etc/logrotate.conf" | sudo crontab -
> ```

> [!warning] Pièges courants de logrotate
> 
> 1. **Permissions incorrectes** : vérifier que `create` spécifie les bons user/group
> 2. **Service ne recharge pas** : tester le script `postrotate` manuellement
> 3. **Compression échoue** : vérifier que gzip est installé
> 4. **Fichier toujours en cours d'utilisation** : utiliser `copytruncate` si nécessaire
> 5. **Rotation trop fréquente** : ajuster `size` ou la fréquence selon le trafic
> 6. **Logs perdus pendant rotation** : utiliser `delaycompress` pour garder le dernier non compressé

---

## 📝 Résumé des bonnes pratiques

### Analyse des logs Apache

✅ Utiliser GoAccess ou AWStats pour des rapports automatiques  
✅ Surveiller les codes 404 et 500 régulièrement  
✅ Détecter les comportements suspects (scans, injections)  
✅ Analyser les performances avec les temps de réponse  
✅ Protéger l'accès aux rapports de statistiques

### Logs MySQL/MariaDB

✅ Toujours activer le slow query log en production  
✅ Ajuster `long_query_time` selon vos besoins (0.5-2s)  
✅ Utiliser pt-query-digest pour l'analyse approfondie  
✅ Ne jamais activer general_log en production (sauf debug temporaire)  
✅ Surveiller les erreurs critiques (deadlock, crash, connexions)  
✅ Gérer les binary logs via MySQL, pas logrotate

### Rotation automatique

✅ Configurer logrotate pour éviter la saturation disque  
✅ Adapter la fréquence de rotation au volume de trafic  
✅ Utiliser `compress` pour économiser l'espace  
✅ Toujours tester avec `-d` avant de déployer  
✅ Mettre en place une surveillance de l'espace disque  
✅ Vérifier que les services rechargent correctement après rotation  
✅ Conserver les logs selon vos obligations légales et métier

> [!success] Checklist quotidienne de surveillance
> 
> - [ ] Vérifier l'espace disque de /var/log
> - [ ] Consulter les erreurs critiques Apache et MySQL
> - [ ] Analyser les requêtes lentes MySQL (top 10)
> - [ ] Vérifier les tentatives d'intrusion dans access.log
> - [ ] Contrôler que la rotation s'est bien effectuée
> - [ ] Surveiller les codes d'erreur HTTP inhabituels