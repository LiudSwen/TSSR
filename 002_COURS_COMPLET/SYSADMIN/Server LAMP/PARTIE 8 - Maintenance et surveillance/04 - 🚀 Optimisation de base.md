
> [!info] Objectif de cette partie Apprendre à optimiser les performances d'un serveur LAMP en configurant Apache, MySQL et PHP pour gérer efficacement la charge et améliorer les temps de réponse.

---

## 📑 Table des matières

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

## ⚙️ Configuration Apache

### KeepAlive

#### 📖 Qu'est-ce que KeepAlive ?

**KeepAlive** permet de maintenir une connexion TCP ouverte entre le client et le serveur pour plusieurs requêtes HTTP consécutives, au lieu de fermer et rouvrir une connexion pour chaque requête.

> [!tip] Pourquoi c'est important Sans KeepAlive, chaque ressource (HTML, CSS, JS, images) nécessite une nouvelle connexion TCP, ce qui entraîne :
> 
> - Overhead de connexion (TCP handshake)
> - Latence supplémentaire
> - Consommation accrue de ressources

#### Configuration de KeepAlive

```bash
# Fichier : /etc/apache2/apache2.conf (Debian/Ubuntu)
# ou /etc/httpd/conf/httpd.conf (CentOS/RHEL)

# Active les connexions persistantes
KeepAlive On

# Nombre maximum de requêtes par connexion KeepAlive
# Augmenter cette valeur pour les sites avec beaucoup de ressources
MaxKeepAliveRequests 100

# Temps d'attente (en secondes) avant de fermer une connexion inactive
# Valeur basse = libère les ressources plus vite
# Valeur haute = meilleure performance pour les clients lents
KeepAliveTimeout 5
```

> [!example] Scénario d'utilisation Une page web avec 1 HTML + 10 CSS/JS + 20 images = 31 ressources
> 
> - **Sans KeepAlive** : 31 connexions TCP différentes
> - **Avec KeepAlive** : 1 seule connexion TCP (si MaxKeepAliveRequests ≥ 31)

#### Recommandations par type de site

|Type de site|KeepAlive|MaxKeepAliveRequests|KeepAliveTimeout|
|---|---|---|---|
|Site statique avec peu d'images|On|50|2-3s|
|Site web moderne (nombreuses ressources)|On|100-200|5s|
|API REST|Off|-|-|
|Site à très fort trafic|On|100|2s|

> [!warning] Attention avec KeepAlive
> 
> - Un **KeepAliveTimeout trop élevé** (ex: 15s) peut bloquer des processus Apache inutilement
> - Sur un serveur avec beaucoup de connexions simultanées, cela peut saturer les workers disponibles
> - Pour les APIs, désactiver KeepAlive est souvent préférable car les requêtes sont uniques

---

### MaxClients et gestion des processus

#### 📖 Les MPM (Multi-Processing Modules)

Apache utilise différents **MPM** pour gérer les requêtes. Les trois principaux sont :

- **Prefork** : Un processus par connexion (stable, compatible PHP en module)
- **Worker** : Threads multiples dans plusieurs processus (plus performant)
- **Event** : Optimisé pour KeepAlive, gère mieux les connexions inactives

> [!info] Vérifier votre MPM actuel
> 
> ```bash
> # Vérifier le MPM en cours d'utilisation
> apache2ctl -V | grep -i mpm
> # ou
> httpd -V | grep -i mpm
> ```

#### Configuration du MPM Prefork

```bash
# Fichier : /etc/apache2/mods-available/mpm_prefork.conf

<IfModule mpm_prefork_module>
    # Nombre de processus enfants au démarrage
    StartServers             5
    
    # Nombre minimum de processus inactifs à maintenir
    MinSpareServers          5
    
    # Nombre maximum de processus inactifs à maintenir
    MaxSpareServers          10
    
    # ANCIEN : MaxClients (Apache 2.2)
    # NOUVEAU : MaxRequestWorkers (Apache 2.4+)
    # Nombre maximum de connexions simultanées
    MaxRequestWorkers        150
    
    # Nombre de requêtes qu'un processus enfant peut traiter avant d'être tué
    # Évite les fuites mémoire sur la durée
    MaxConnectionsPerChild   1000
</IfModule>
```

> [!tip] Calcul de MaxRequestWorkers Formule approximative :
> 
> ```
> MaxRequestWorkers = (RAM disponible pour Apache) / (Taille moyenne d'un processus Apache)
> ```
> 
> Exemple avec 4 Go de RAM :
> 
> - RAM totale : 4096 Mo
> - RAM système : -512 Mo
> - RAM MySQL : -1024 Mo
> - RAM disponible pour Apache : **2560 Mo**
> - Taille processus Apache : ~25 Mo
> - **MaxRequestWorkers = 2560 / 25 ≈ 100**

#### Configuration du MPM Worker

```bash
# Fichier : /etc/apache2/mods-available/mpm_worker.conf

<IfModule mpm_worker_module>
    # Nombre de processus serveur au démarrage
    StartServers             3
    
    # Limites de threads inactifs
    MinSpareThreads          75
    MaxSpareThreads          250
    
    # Nombre de threads par processus enfant
    ThreadsPerChild          25
    
    # Nombre maximum de connexions simultanées
    MaxRequestWorkers        400
    
    # Limite absolue de clients pendant la durée de vie du serveur
    ServerLimit              16
    
    MaxConnectionsPerChild   1000
</IfModule>
```

> [!example] Calcul Worker
> 
> - **ThreadsPerChild = 25**
> - **MaxRequestWorkers = 400**
> - Nombre de processus nécessaires = 400 / 25 = **16 processus**
> - **ServerLimit doit être ≥ 16**

#### Configuration du MPM Event (recommandé)

```bash
# Fichier : /etc/apache2/mods-available/mpm_event.conf

<IfModule mpm_event_module>
    StartServers             3
    MinSpareThreads          75
    MaxSpareThreads          250
    ThreadsPerChild          25
    MaxRequestWorkers        400
    ServerLimit              16
    
    # Spécifique à Event : nombre de connexions KeepAlive par processus
    AsyncRequestWorkerFactor 2
</IfModule>
```

> [!tip] Pourquoi Event est meilleur Event gère les connexions KeepAlive inactives dans un thread dédié, libérant ainsi les workers pour traiter de nouvelles requêtes. C'est idéal pour les sites modernes avec KeepAlive activé.

#### Commandes de gestion

```bash
# Recharger la configuration Apache
sudo systemctl reload apache2

# Vérifier la syntaxe avant de recharger
sudo apache2ctl configtest

# Surveiller les processus Apache en temps réel
sudo watch -n 1 'ps aux | grep apache2 | wc -l'

# Voir les connexions actives
sudo netstat -an | grep :80 | wc -l

# Activer un MPM différent (Debian/Ubuntu)
sudo a2dismod mpm_prefork
sudo a2enmod mpm_event
sudo systemctl restart apache2
```

> [!warning] Attention lors du changement de MPM
> 
> - **Prefork** est nécessaire si vous utilisez `mod_php` (PHP en module Apache)
> - **Worker/Event** nécessitent PHP-FPM (PHP en FastCGI)
> - Toujours tester la nouvelle configuration avant de redémarrer en production

---

## 🗄️ Optimisation MySQL

### innodb_buffer_pool_size

#### 📖 Qu'est-ce que le Buffer Pool ?

Le **buffer pool** est la zone de mémoire où InnoDB met en cache les données et les index. C'est **LE paramètre le plus important** pour les performances MySQL.

> [!info] Principe de fonctionnement
> 
> - Stocke en RAM les pages de données fréquemment accédées
> - Évite les lectures disque coûteuses
> - Améliore drastiquement les performances des requêtes SELECT
> - Accélère aussi les opérations INSERT/UPDATE en mettant en cache les index

#### Configuration de base

```bash
# Fichier : /etc/mysql/mysql.conf.d/mysqld.cnf (Debian/Ubuntu)
# ou /etc/my.cnf (CentOS/RHEL)

[mysqld]
# Taille du buffer pool InnoDB
# Règle générale : 70-80% de la RAM sur un serveur dédié MySQL
innodb_buffer_pool_size = 2G

# Nombre d'instances de buffer pool (améliore la concurrence)
# Recommandé : 1 instance par Go (minimum 1, maximum 64)
# Exemple : 2G de buffer = 2 instances
innodb_buffer_pool_instances = 2
```

> [!tip] Dimensionnement selon la RAM disponible
> 
> |RAM serveur|RAM pour MySQL|innodb_buffer_pool_size|Instances|
> |---|---|---|---|
> |1 Go|512 Mo|256M|1|
> |2 Go|1.5 Go|1G|1|
> |4 Go|3 Go|2G|2|
> |8 Go|6 Go|5G|5|
> |16 Go|12 Go|10G|10|
> |32 Go|24 Go|20G|20|

#### Vérifier l'utilisation actuelle

```bash
# Connectez-vous à MySQL
mysql -u root -p

# Vérifier la taille configurée
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';

# Voir l'utilisation du buffer pool
SHOW ENGINE INNODB STATUS\G

# Statistiques détaillées
SELECT 
    (PagesData * PageSize) / POWER(1024, 3) AS DataGB,
    (PagesFree * PageSize) / POWER(1024, 3) AS FreeGB,
    (PagesData * PageSize) / (innodb_buffer_pool_size) * 100 AS PercentUsed
FROM (
    SELECT variable_value AS PageSize FROM information_schema.global_status 
    WHERE variable_name = 'Innodb_page_size'
) AS ps,
(
    SELECT variable_value AS PagesData FROM information_schema.global_status 
    WHERE variable_name = 'Innodb_buffer_pool_pages_data'
) AS pd,
(
    SELECT variable_value AS PagesFree FROM information_schema.global_status 
    WHERE variable_name = 'Innodb_buffer_pool_pages_free'
) AS pf,
(
    SELECT @@innodb_buffer_pool_size AS innodb_buffer_pool_size
) AS bp;
```

> [!example] Interpréter les résultats Si votre buffer pool est utilisé à **95%+**, c'est un bon signe d'utilisation optimale. Si c'est en dessous de 60%, vous pouvez peut-être réduire la taille pour libérer de la RAM.

#### Modifier la taille sans redémarrage (MySQL 5.7.5+)

```sql
-- Vérifier la taille actuelle (en octets)
SELECT @@innodb_buffer_pool_size / 1024 / 1024 / 1024 AS 'Size in GB';

-- Modifier dynamiquement (multiple de innodb_buffer_pool_chunk_size)
SET GLOBAL innodb_buffer_pool_size = 3221225472;  -- 3 Go en octets

-- Vérifier le changement
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
```

> [!warning] Contraintes du redimensionnement dynamique
> 
> - La nouvelle taille doit être un **multiple de** `innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances`
> - Valeur par défaut du chunk : 128 Mo
> - Exemple : avec 2 instances, changez par incréments de 256 Mo (128 * 2)

---

### Autres paramètres InnoDB essentiels

#### innodb_log_file_size

```bash
[mysqld]
# Taille des fichiers de logs de transactions
# Plus grand = moins de flush sur disque, meilleures performances en écriture
# Mais temps de récupération plus long après un crash
innodb_log_file_size = 512M

# Nombre de fichiers de logs (généralement 2)
innodb_log_files_in_group = 2
```

> [!tip] Dimensionnement
> 
> - **Petit site** (peu d'écritures) : 128M
> - **Site moyen** : 256-512M
> - **Gros site** (beaucoup d'écritures) : 1G ou plus

#### innodb_flush_log_at_trx_commit

```bash
[mysqld]
# Contrôle la fréquence de flush des logs sur disque
# 0 = flush toutes les secondes (plus rapide, risque de perte de données)
# 1 = flush à chaque transaction (ACID complet, plus lent)
# 2 = flush toutes les secondes vers l'OS (compromis)
innodb_flush_log_at_trx_commit = 1
```

> [!warning] Compromis performance vs sécurité
> 
> - **Valeur 1** : ACID complet, recommandé pour les données critiques
> - **Valeur 2** : Bon compromis, perte max d'1 seconde de données en cas de crash
> - **Valeur 0** : Maximum de performance, mais risque de corruption de la base

#### innodb_flush_method

```bash
[mysqld]
# Méthode d'écriture sur disque (Linux)
# O_DIRECT évite la mise en cache du système d'exploitation (double cache)
innodb_flush_method = O_DIRECT
```

> [!info] Quand utiliser O_DIRECT
> 
> - **Recommandé** sur les serveurs dédiés MySQL
> - Évite que les données soient mises en cache deux fois (buffer pool + cache OS)
> - Libère de la RAM pour le buffer pool

#### Configuration complète optimisée

```bash
[mysqld]
# === Moteur InnoDB ===
innodb_buffer_pool_size = 2G
innodb_buffer_pool_instances = 2
innodb_log_file_size = 512M
innodb_log_files_in_group = 2
innodb_flush_log_at_trx_commit = 1
innodb_flush_method = O_DIRECT

# Taille du cache pour les fichiers ouverts
innodb_open_files = 400

# Threads d'écriture (I/O)
innodb_write_io_threads = 4
innodb_read_io_threads = 4

# === Connexions ===
max_connections = 150

# === Cache des requêtes (déprécié MySQL 8.0+) ===
# query_cache_type = 1
# query_cache_size = 32M

# === Tables temporaires ===
tmp_table_size = 64M
max_heap_table_size = 64M

# === Logs lents ===
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow-query.log
long_query_time = 2
```

#### Appliquer les modifications

```bash
# Éditer le fichier de configuration
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

# Vérifier la syntaxe (pas d'outil natif, mais on peut tester au démarrage)
sudo mysqld --verbose --help | grep -A 1 "Default options"

# Redémarrer MySQL
sudo systemctl restart mysql

# Vérifier que MySQL a démarré correctement
sudo systemctl status mysql

# Se connecter et vérifier les paramètres
mysql -u root -p -e "SHOW VARIABLES LIKE 'innodb%';"
```

> [!warning] Modifier innodb_log_file_size nécessite une procédure spéciale
> 
> 1. Arrêter MySQL proprement : `sudo systemctl stop mysql`
> 2. Supprimer les anciens logs : `sudo rm /var/lib/mysql/ib_logfile*`
> 3. Modifier la configuration
> 4. Redémarrer MySQL : `sudo systemctl start mysql`

---

## 🚀 Cache PHP (OPcache)

### 📖 Qu'est-ce qu'OPcache ?

**OPcache** est un système de cache intégré à PHP (depuis 5.5) qui stocke le bytecode compilé des scripts PHP en mémoire, évitant ainsi de recompiler les fichiers à chaque requête.

> [!info] Gain de performance
> 
> - **Sans OPcache** : PHP lit, parse, compile puis exécute le script à chaque requête
> - **Avec OPcache** : PHP exécute directement le bytecode mis en cache
> - Amélioration typique : **30% à 300%** selon l'application

---

### Activation et configuration

#### Vérifier si OPcache est installé

```bash
# Vérifier si l'extension est chargée
php -v

# Vérifier la configuration OPcache
php -i | grep opcache

# Voir la configuration dans un fichier
php --ini | grep opcache
```

#### Installation si nécessaire

```bash
# Debian/Ubuntu
sudo apt update
sudo apt install php-opcache

# CentOS/RHEL
sudo yum install php-opcache

# Redémarrer PHP-FPM ou Apache
sudo systemctl restart php8.1-fpm
# ou
sudo systemctl restart apache2
```

#### Configuration optimale

```bash
# Fichier : /etc/php/8.1/apache2/conf.d/10-opcache.ini
# ou /etc/php/8.1/fpm/conf.d/10-opcache.ini

[opcache]
# Activer OPcache
opcache.enable=1

# Activer pour les scripts CLI (ligne de commande)
opcache.enable_cli=0

# Mémoire allouée au cache (en Mo)
# Augmenter pour les grosses applications
opcache.memory_consumption=128

# Mémoire pour les chaînes interned (noms de classes, fonctions...)
opcache.interned_strings_buffer=8

# Nombre maximum de fichiers pouvant être mis en cache
# Augmenter pour les gros projets (Symfony, WordPress multisite...)
opcache.max_accelerated_files=10000

# Fréquence de vérification des mises à jour (en secondes)
# 0 = vérifier à chaque requête (développement)
# 60+ = vérifier toutes les N secondes (production)
opcache.revalidate_freq=2

# Valider les timestamps (vérifier si les fichiers ont changé)
# 1 = oui (développement)
# 0 = non (production, meilleure performance)
opcache.validate_timestamps=1

# Activer le fast shutdown (libération rapide de la mémoire)
opcache.fast_shutdown=1

# Niveau d'optimisation (0-5)
opcache.optimization_level=0x7FFFBFFF

# Sauvegarder les commentaires (nécessaire pour certains frameworks)
opcache.save_comments=1

# Charger les fichiers en cache dès le démarrage
opcache.load_comments=1
```

> [!tip] Configuration selon l'environnement
> 
> **Développement** :
> 
> ```ini
> opcache.revalidate_freq=0
> opcache.validate_timestamps=1
> ```
> 
> Vérifie les changements à chaque requête.
> 
> **Production** :
> 
> ```ini
> opcache.revalidate_freq=60
> opcache.validate_timestamps=0
> ```
> 
> Ne vérifie pas les changements, maximum de performance.

#### Dimensionnement de la mémoire

|Type d'application|memory_consumption|max_accelerated_files|
|---|---|---|
|Petit site (< 100 fichiers)|64M|4000|
|WordPress / Laravel simple|128M|10000|
|Gros CMS / Framework|256M|20000|
|Application enterprise|512M+|50000+|

> [!example] Calculer max_accelerated_files
> 
> ```bash
> # Compter les fichiers PHP dans votre projet
> find /var/www/html -name "*.php" | wc -l
> 
> # Multiplier par ~2 pour avoir de la marge
> # Exemple : 3500 fichiers × 2 = 7000
> # → Configurer max_accelerated_files = 10000
> ```

---

### Surveillance du cache

#### Vérifier le statut d'OPcache

```bash
# Créer un script PHP pour voir le statut
sudo nano /var/www/html/opcache-status.php
```

```php
<?php
// Afficher les informations OPcache
phpinfo();

// Ou utiliser opcache_get_status() pour plus de détails
echo "<pre>";
print_r(opcache_get_status());
echo "</pre>";
?>
```

> [!warning] Sécurité **Supprimez ce fichier après utilisation** ou protégez-le par authentification HTTP. Il contient des informations sensibles sur votre configuration.

#### Utiliser un outil de monitoring

```bash
# Cloner OPcache GUI (outil de monitoring web)
cd /var/www/html
sudo git clone https://github.com/amnuts/opcache-gui.git
sudo chown -R www-data:www-data opcache-gui

# Accéder via : http://votre-serveur/opcache-gui
```

#### Analyser les statistiques OPcache

```php
<?php
$status = opcache_get_status();

// Taux d'utilisation de la mémoire
$memory_used = $status['memory_usage']['used_memory'];
$memory_total = $memory_used + $status['memory_usage']['free_memory'];
$memory_percent = ($memory_used / $memory_total) * 100;

echo "Utilisation mémoire : " . round($memory_percent, 2) . "%\n";

// Hit ratio (taux de succès du cache)
$hits = $status['opcache_statistics']['hits'];
$misses = $status['opcache_statistics']['misses'];
$hit_rate = ($hits / ($hits + $misses)) * 100;

echo "Hit rate : " . round($hit_rate, 2) . "%\n";

// Fichiers en cache
$cached_scripts = $status['opcache_statistics']['num_cached_scripts'];
$max_scripts = $status['opcache_statistics']['max_cached_keys'];

echo "Scripts en cache : $cached_scripts / $max_scripts\n";
?>
```

> [!tip] Indicateurs de bonne santé
> 
> - **Hit rate** : > 95% (si < 90%, augmenter opcache.memory_consumption)
> - **Utilisation mémoire** : 60-80% (si > 90%, augmenter la taille)
> - **Scripts en cache** : < 80% du max (si saturé, augmenter max_accelerated_files)

#### Vider le cache manuellement

```bash
# Méthode 1 : Redémarrer PHP-FPM
sudo systemctl restart php8.1-fpm

# Méthode 2 : Redémarrer Apache (si mod_php)
sudo systemctl restart apache2

# Méthode 3 : Via un script PHP
# Créer /var/www/html/opcache-reset.php
```

```php
<?php
// Protéger par un token secret
if ($_GET['token'] === 'votre_token_secret_ici') {
    opcache_reset();
    echo "OPcache vidé avec succès !";
} else {
    echo "Accès refusé";
}
?>
```

```bash
# Appeler le script pour vider le cache
curl "http://localhost/opcache-reset.php?token=votre_token_secret_ici"

# Supprimer le script après utilisation
sudo rm /var/www/html/opcache-reset.php
```

> [!warning] Attention en production Vider OPcache en production entraîne une **charge CPU élevée** temporaire, car tous les scripts doivent être recompilés. Faites-le pendant les heures creuses si possible.

#### Configurer l'invalidation automatique

```bash
# Ajouter dans la configuration PHP
[opcache]
# Nombre de secondes entre chaque vérification des fichiers
opcache.revalidate_freq=60

# En production, désactiver la validation pour maximum de performance
# Invalider manuellement après chaque déploiement
opcache.validate_timestamps=0
```

> [!example] Automatiser l'invalidation lors du déploiement
> 
> ```bash
> #!/bin/bash
> # Script de déploiement
> 
> # Déployer le code
> git pull origin main
> 
> # Vider OPcache automatiquement
> curl -s "http://localhost/opcache-reset.php?token=votre_token_secret" > /dev/null
> 
> # Ou redémarrer PHP-FPM
> sudo systemctl reload php8.1-fpm
> 
> echo "Déploiement terminé, OPcache vidé"
> ```

---

## ⚠️ Pièges courants

### Apache

> [!warning] KeepAlive mal configuré **Problème** : KeepAliveTimeout trop élevé (15-30s) bloque les workers Apache
> 
> **Symptôme** : Le serveur devient lent même avec peu de trafic, car tous les workers sont occupés à attendre
> 
> **Solution** : Réduire à 2-5 secondes selon le profil du site

> [!warning] MaxRequestWorkers trop élevé **Problème** : Configurer 300 workers sur un serveur avec 2 Go de RAM
> 
> **Symptôme** : Swap intensif, serveur qui freeze
> 
> **Solution** : Calculer précisément selon la RAM disponible (voir formule ci-dessus)

> [!warning] Oublier de recharger Apache **Problème** : Modifier la configuration mais ne pas recharger
> 
> **Solution** : Toujours faire `sudo systemctl reload apache2` après une modification

---

### MySQL

> [!warning] innodb_buffer_pool_size trop grand **Problème** : Allouer 3.5 Go sur un serveur avec 4 Go de RAM totale
> 
> **Symptôme** : OOM Killer tue MySQL, système instable
> 
> **Solution** : Laisser au moins 25% de RAM pour l'OS et autres services

> [!warning] Modifier innodb_log_file_size sans précaution **Problème** : Changer la taille dans la config et redémarrer directement
> 
> **Symptôme** : MySQL refuse de démarrer avec une erreur de corruption
> 
> **Solution** : Toujours supprimer les anciens fichiers `ib_logfile*` avant

> [!warning] innodb_flush_log_at_trx_commit=0 en production **Problème** : Privilégier la performance au détriment de la durabilité
> 
> **Symptôme** : Perte ou corruption de données après un crash
> 
> **Solution** : Utiliser la valeur 1 pour les données critiques, 2 en compromis acceptable

---

### OPcache

> [!warning] opcache.validate_timestamps=0 en développement **Problème** : Désactiver la validation en environnement de dev
> 
> **Symptôme** : Les modifications de code ne sont pas prises en compte
> 
> **Solution** : Toujours laisser à 1 en développement, 0 uniquement en production

> [!warning] opcache.memory_consumption trop faible **Problème** : Allouer 64M pour une grosse application Symfony
> 
> **Symptôme** : Cache plein, évictions constantes, performances dégradées
> 
> **Solution** : Surveiller l'utilisation et augmenter si > 90%

> [!warning] Oublier de vider le cache après un déploiement **Problème** : Déployer du nouveau code mais continuer à exécuter l'ancien bytecode
> 
> **Symptôme** : Bugs inexplicables, code "qui ne change pas"
> 
> **Solution** : Automatiser `opcache_reset()` ou redémarrer PHP-FPM après chaque déploiement

> [!warning] max_accelerated_files trop faible **Problème** : 4000 fichiers configurés pour une application avec 8000 fichiers PHP
> 
> **Symptôme** : Hash collision, performance médiocre
> 
> **Solution** : Compter les fichiers PHP du projet et multiplier par 2

---

## 🎯 Checklist de vérification

```bash
# === APACHE ===
# Vérifier la configuration KeepAlive
grep -E "KeepAlive|MaxKeepAliveRequests|KeepAliveTimeout" /etc/apache2/apache2.conf

# Vérifier le MPM et ses paramètres
apache2ctl -M | grep mpm
cat /etc/apache2/mods-enabled/mpm_*.conf

# Tester la configuration
apache2ctl configtest

# === MYSQL ===
# Vérifier les paramètres InnoDB
mysql -u root -p -e "SHOW VARIABLES LIKE 'innodb_buffer_pool%';"
mysql -u root -p -e "SHOW VARIABLES LIKE 'innodb_log%';"
mysql -u root -p -e "SHOW VARIABLES LIKE 'innodb_flush%';"

# Vérifier l'utilisation du buffer pool
mysql -u root -p -e "SHOW ENGINE INNODB STATUS\G" | grep -A 10 "BUFFER POOL"

# Statistiques de performance
mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%';"

# === PHP OPCACHE ===
# Vérifier si OPcache est actif
php -i | grep opcache.enable

# Voir la configuration complète
php -i | grep opcache

# Vérifier l'utilisation mémoire et hit rate
php -r "print_r(opcache_get_status());"

# === MONITORING GÉNÉRAL ===
# Surveiller la mémoire disponible
free -h

# Voir les processus Apache actifs
ps aux | grep apache2 | wc -l

# Vérifier les connexions MySQL
mysql -u root -p -e "SHOW PROCESSLIST;"

# Surveiller les logs d'erreurs
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/mysql/error.log
```

---

## 📊 Métriques de performance à surveiller

### Apache

```bash
# Installer Apache mod_status pour le monitoring
sudo a2enmod status

# Configurer mod_status
sudo nano /etc/apache2/mods-enabled/status.conf
```

```apache
<IfModule mod_status.c>
    <Location /server-status>
        SetHandler server-status
        # Restreindre l'accès à localhost uniquement
        Require ip 127.0.0.1
    </Location>
    
    # Activer les statistiques étendues
    ExtendedStatus On
</IfModule>
```

```bash
# Redémarrer Apache
sudo systemctl reload apache2

# Consulter les statistiques
curl http://localhost/server-status

# Version détaillée
curl http://localhost/server-status?auto
```

> [!info] Métriques importantes d'Apache
> 
> - **Total accesses** : Nombre total de requêtes
> - **BusyWorkers** : Nombre de workers actifs (doit être < MaxRequestWorkers)
> - **IdleWorkers** : Workers en attente (si = 0, augmenter MaxRequestWorkers)
> - **Requests per second** : Débit du serveur
> - **Bytes per request** : Taille moyenne des réponses

---

### MySQL

```sql
-- Connexion MySQL
mysql -u root -p

-- Voir le ratio de hit du buffer pool
SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_read%';

-- Calculer le hit ratio
-- Formule : (Innodb_buffer_pool_read_requests - Innodb_buffer_pool_reads) / Innodb_buffer_pool_read_requests * 100
-- Un bon ratio est > 99%

-- Voir les requêtes lentes
SELECT * FROM mysql.slow_log ORDER BY query_time DESC LIMIT 10;

-- Statistiques des tables
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC
LIMIT 20;

-- Voir les connexions actives
SHOW PROCESSLIST;

-- Variables de performance importantes
SHOW GLOBAL STATUS LIKE 'Threads_connected';
SHOW GLOBAL STATUS LIKE 'Threads_running';
SHOW GLOBAL STATUS LIKE 'Queries';
SHOW GLOBAL STATUS LIKE 'Slow_queries';
```

> [!tip] Utiliser mysqltuner
> 
> ```bash
> # Installer mysqltuner (script Perl d'analyse)
> sudo apt install mysqltuner
> # ou
> wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl
> chmod +x mysqltuner.pl
> 
> # Exécuter l'analyse
> sudo mysqltuner
> # ou
> ./mysqltuner.pl
> 
> # Il va analyser votre configuration et donner des recommandations
> ```

---

### OPcache

```php
<?php
// Script de monitoring complet d'OPcache
$status = opcache_get_status(false);
$config = opcache_get_configuration();

echo "=== CONFIGURATION OPCACHE ===\n";
echo "Mémoire allouée : " . ($config['directives']['opcache.memory_consumption'] / 1024 / 1024) . " Mo\n";
echo "Max fichiers : " . $config['directives']['opcache.max_accelerated_files'] . "\n";
echo "Validation timestamps : " . ($config['directives']['opcache.validate_timestamps'] ? 'Oui' : 'Non') . "\n";

echo "\n=== UTILISATION MÉMOIRE ===\n";
$memory = $status['memory_usage'];
$used = $memory['used_memory'] / 1024 / 1024;
$free = $memory['free_memory'] / 1024 / 1024;
$wasted = $memory['wasted_memory'] / 1024 / 1024;
$total = $used + $free + $wasted;

echo "Utilisée : " . round($used, 2) . " Mo (" . round(($used / $total) * 100, 2) . "%)\n";
echo "Libre : " . round($free, 2) . " Mo (" . round(($free / $total) * 100, 2) . "%)\n";
echo "Gaspillée : " . round($wasted, 2) . " Mo (" . round(($wasted / $total) * 100, 2) . "%)\n";

echo "\n=== STATISTIQUES ===\n";
$stats = $status['opcache_statistics'];
$hits = $stats['hits'];
$misses = $stats['misses'];
$total_requests = $hits + $misses;
$hit_rate = ($total_requests > 0) ? ($hits / $total_requests) * 100 : 0;

echo "Hits : " . number_format($hits) . "\n";
echo "Misses : " . number_format($misses) . "\n";
echo "Hit rate : " . round($hit_rate, 2) . "%\n";
echo "Scripts en cache : " . $stats['num_cached_scripts'] . " / " . $stats['max_cached_keys'] . "\n";

echo "\n=== ALERTES ===\n";
if ($hit_rate < 90) {
    echo "⚠️  Hit rate trop faible (< 90%) → Augmenter opcache.memory_consumption\n";
}
if (($used / $total) > 0.9) {
    echo "⚠️  Mémoire presque saturée (> 90%) → Augmenter opcache.memory_consumption\n";
}
if ($stats['num_cached_scripts'] / $stats['max_cached_keys'] > 0.8) {
    echo "⚠️  Nombre de scripts proche du maximum → Augmenter opcache.max_accelerated_files\n";
}
if ($stats['oom_restarts'] > 0) {
    echo "⚠️  " . $stats['oom_restarts'] . " redémarrages suite à manque de mémoire\n";
}
if ($stats['hash_restarts'] > 0) {
    echo "⚠️  " . $stats['hash_restarts'] . " redémarrages suite à collision de hash\n";
}

if ($hit_rate >= 95 && ($used / $total) < 0.85) {
    echo "✅ OPcache fonctionne de manière optimale !\n";
}
?>
```

---

## 🔧 Bonnes pratiques de configuration

### 1. Toujours tester avant de déployer

```bash
# Créer une copie de sauvegarde de la configuration
sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.backup
sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.backup
sudo cp /etc/php/8.1/fpm/conf.d/10-opcache.ini /etc/php/8.1/fpm/conf.d/10-opcache.ini.backup

# Tester la syntaxe avant de redémarrer
sudo apache2ctl configtest
sudo mysqld --verbose --help > /dev/null
php -i > /dev/null

# Vérifier les logs après un redémarrage
sudo systemctl restart apache2 && sudo tail -f /var/log/apache2/error.log
```

> [!tip] Testez sur un environnement de staging Avant d'appliquer des changements en production, testez toujours sur un serveur de staging identique pour éviter les mauvaises surprises.

---

### 2. Documenter vos modifications

```bash
# Ajouter des commentaires dans les fichiers de config
# Fichier : /etc/apache2/apache2.conf

# [2024-12-22] Augmentation MaxRequestWorkers de 150 à 200
# Raison : Trafic augmenté de 40% ce mois-ci
# Observé : Load average stable, pas de swap
MaxRequestWorkers 200
```

> [!info] Tenir un journal des modifications Créez un fichier `/root/server-changes.log` pour tracer toutes les modifications importantes :
> 
> ```
> 2024-12-22 10:30 - Augmentation innodb_buffer_pool_size de 2G à 3G
> 2024-12-22 10:35 - Activation OPcache avec 128M de RAM
> 2024-12-22 11:00 - Passage MPM prefork → event
> ```

---

### 3. Monitorer l'impact des changements

```bash
# Avant la modification, noter les métriques
echo "=== AVANT MODIFICATION ===" >> /root/performance.log
date >> /root/performance.log
apache2ctl fullstatus >> /root/performance.log
mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'Queries';" >> /root/performance.log

# Appliquer la modification

# Après la modification (attendre 1h), comparer
echo "=== APRÈS MODIFICATION ===" >> /root/performance.log
date >> /root/performance.log
apache2ctl fullstatus >> /root/performance.log
mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'Queries';" >> /root/performance.log
```

> [!example] Outils de monitoring recommandés
> 
> - **htop** : Surveillance CPU/RAM en temps réel
> - **iotop** : Surveillance des I/O disque
> - **mytop** : Surveillance MySQL en temps réel
> - **Apache mod_status** : Statistiques Apache
> - **Netdata** : Dashboard complet de monitoring
> 
> ```bash
> sudo apt install htop iotop mytop
> ```

---

### 4. Adapter selon la charge

> [!info] Réévaluer régulièrement Les besoins évoluent avec le temps. Réévaluez vos paramètres :
> 
> - **Mensuellement** : Vérifier les tendances d'utilisation
> - **Après une montée de trafic** : Ajuster les limites si nécessaire
> - **Après un incident** : Analyser et corriger
> - **Lors de mises à jour** : Vérifier la compatibilité des optimisations

---

### 5. Garder des marges de sécurité

```bash
# Exemple de calcul avec marge
# Serveur avec 8 Go de RAM

# RAM disponible : 8192 Mo
# - Système : -512 Mo
# - MySQL : -5120 Mo (buffer pool 5G)
# - PHP-FPM : -1024 Mo (estimé)
# - Marge sécurité : -512 Mo
# = Reste pour Apache : 1024 Mo

# Avec 25 Mo par processus Apache :
# MaxRequestWorkers = 1024 / 25 = 40
```

> [!warning] Ne jamais saturer la RAM Laisser toujours 10-15% de RAM libre pour :
> 
> - Les pics de trafic
> - Les processus système
> - Les caches système
> - Éviter le swap

---

## 🎓 Astuces d'optimisation avancées

### Combiner KeepAlive et compression

```apache
# Activer la compression gzip
<IfModule mod_deflate.c>
    # Compresser les types de fichiers texte
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css
    AddOutputFilterByType DEFLATE application/javascript application/json
    
    # Ne pas compresser les images déjà compressées
    SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png|webp)$ no-gzip
</IfModule>

# Avec KeepAlive, les fichiers compressés sont servis plus rapidement
KeepAlive On
MaxKeepAliveRequests 100
```

> [!tip] Gain de performance combiné Compression + KeepAlive = Moins de bande passante + Moins de connexions = Serveur plus rapide et économe

---

### Précharger les tables MySQL les plus utilisées

```sql
-- Identifier les tables les plus sollicitées
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS 'Size (MB)',
    TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA NOT IN ('information_schema', 'mysql', 'performance_schema')
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC
LIMIT 10;

-- Précharger manuellement une table dans le buffer pool
-- (utile après un redémarrage MySQL)
SELECT COUNT(*) FROM votre_table;
```

---

### Utiliser PHP-FPM avec Apache Event

```bash
# Désactiver mod_php et utiliser PHP-FPM
sudo a2dismod php8.1
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php8.1-fpm

# Activer MPM Event
sudo a2dismod mpm_prefork
sudo a2enmod mpm_event

# Configurer PHP-FPM pour optimiser les performances
sudo nano /etc/php/8.1/fpm/pool.d/www.conf
```

```ini
[www]
; Mode de communication (socket Unix = plus rapide que TCP)
listen = /run/php/php8.1-fpm.sock

; Gestion dynamique des processus
pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.max_requests = 500

; Limites de temps
request_terminate_timeout = 30s
```

> [!info] Pourquoi cette combinaison est meilleure
> 
> - **MPM Event** gère mieux les connexions KeepAlive
> - **PHP-FPM** sépare PHP d'Apache (meilleure isolation)
> - **Socket Unix** est plus rapide que TCP pour la communication locale
> - Possibilité de redémarrer PHP sans redémarrer Apache

---

### Activer le slow query log MySQL

```sql
-- Activer le log des requêtes lentes
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2; -- 2 secondes
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow-query.log';

-- Analyser les requêtes lentes avec pt-query-digest
sudo apt install percona-toolkit
pt-query-digest /var/log/mysql/slow-query.log
```

> [!tip] Optimiser les requêtes identifiées Une fois les requêtes lentes identifiées :
> 
> 1. Ajouter des index sur les colonnes utilisées dans WHERE/JOIN
> 2. Réécrire les requêtes complexes
> 3. Utiliser EXPLAIN pour comprendre le plan d'exécution
> 4. Monitorer l'amélioration après optimisation

---

## 🏁 Résumé des paramètres clés

### Apache

|Paramètre|Valeur recommandée|Impact|
|---|---|---|
|KeepAlive|On|✅ Réduit la latence|
|KeepAliveTimeout|2-5s|⚡ Libère les workers|
|MaxKeepAliveRequests|100|📊 Équilibre perf/ressources|
|MaxRequestWorkers|RAM/25Mo|🎯 Évite la saturation|

### MySQL

|Paramètre|Valeur recommandée|Impact|
|---|---|---|
|innodb_buffer_pool_size|70-80% RAM|🚀 Performance maximale|
|innodb_buffer_pool_instances|1 par Go|⚡ Meilleure concurrence|
|innodb_log_file_size|512M-1G|💾 Réduit les I/O|
|innodb_flush_log_at_trx_commit|1 (prod)|🔒 Sécurité données|

### OPcache

|Paramètre|Valeur recommandée|Impact|
|---|---|---|
|opcache.memory_consumption|128-256M|🧠 Cache bytecode|
|opcache.max_accelerated_files|10000-20000|📁 Capacité cache|
|opcache.validate_timestamps|0 (prod)|⚡ Maximum perf|
|opcache.revalidate_freq|60+ (prod)|🔄 Réduction checks|

---

## ✅ Checklist finale d'optimisation

```bash
# === VÉRIFICATIONS APACHE ===
[ ] KeepAlive activé avec timeout approprié
[ ] MaxRequestWorkers calculé selon RAM disponible
[ ] MPM adapté (Event recommandé avec PHP-FPM)
[ ] Compression gzip activée
[ ] mod_status activé pour monitoring

# === VÉRIFICATIONS MYSQL ===
[ ] innodb_buffer_pool_size = 70-80% RAM disponible
[ ] innodb_buffer_pool_instances configuré
[ ] innodb_log_file_size adapté au volume d'écritures
[ ] innodb_flush_method = O_DIRECT
[ ] Slow query log activé

# === VÉRIFICATIONS OPCACHE ===
[ ] OPcache activé et fonctionnel
[ ] Mémoire suffisante (vérifier utilisation < 85%)
[ ] Hit rate > 95%
[ ] max_accelerated_files > nombre de fichiers PHP
[ ] validate_timestamps = 0 en production

# === MONITORING ===
[ ] Logs d'erreurs surveillés
[ ] Métriques de performance suivies
[ ] Alertes configurées si disponible
[ ] Sauvegardes de configuration effectuées

# === DOCUMENTATION ===
[ ] Modifications documentées
[ ] Journal des changements à jour
[ ] Procédures de rollback préparées
```

---

**🎉 Félicitations !** Vous maîtrisez maintenant les optimisations de base d'un serveur LAMP. Ces configurations constituent une base solide pour des performances optimales.