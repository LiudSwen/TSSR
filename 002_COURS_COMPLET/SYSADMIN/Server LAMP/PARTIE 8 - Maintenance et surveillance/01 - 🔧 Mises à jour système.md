

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

## 🔄 Mises à jour système

La maintenance régulière d'un serveur LAMP est essentielle pour garantir la sécurité, la stabilité et les performances. Les mises à jour corrigent les vulnérabilités, apportent des améliorations et assurent la compatibilité avec les nouvelles technologies.

> [!warning] Importance critique Un serveur non maintenu est une porte ouverte aux attaques. Les vulnérabilités découvertes sont rapidement exploitées par les attaquants. Une mise à jour régulière n'est pas optionnelle, c'est une nécessité.

---

## 📦 Mise à jour des paquets Linux

### Pourquoi mettre à jour les paquets ?

Les mises à jour système corrigent :

- **Failles de sécurité** : CVE (Common Vulnerabilities and Exposures) découvertes
- **Bugs** : Corrections de dysfonctionnements
- **Performance** : Optimisations du kernel et des bibliothèques
- **Compatibilité** : Support de nouveaux standards

### Commandes essentielles selon la distribution

#### Sur Debian/Ubuntu (APT)

```bash
# Mettre à jour la liste des paquets disponibles
sudo apt update

# Voir les paquets qui peuvent être mis à jour
apt list --upgradable

# Mettre à jour tous les paquets installés
sudo apt upgrade

# Mise à jour complète (peut supprimer/installer des paquets)
sudo apt full-upgrade

# Nettoyer les paquets obsolètes
sudo apt autoremove
sudo apt autoclean
```

> [!info] Différence upgrade vs full-upgrade
> 
> - `apt upgrade` : Met à jour les paquets sans supprimer ni installer de nouveaux paquets
> - `apt full-upgrade` : Peut installer ou supprimer des paquets pour résoudre les dépendances (anciennement `dist-upgrade`)

#### Sur RedHat/CentOS/AlmaLinux (YUM/DNF)

```bash
# Vérifier les mises à jour disponibles
sudo yum check-update
# ou avec DNF (plus récent)
sudo dnf check-update

# Mettre à jour tous les paquets
sudo yum update
# ou
sudo dnf update

# Mettre à jour un paquet spécifique
sudo yum update nom_paquet
sudo dnf update nom_paquet

# Nettoyer le cache
sudo yum clean all
sudo dnf clean all
```

### Stratégies de mise à jour

|Approche|Quand l'utiliser|Commande|
|---|---|---|
|**Mises à jour de sécurité uniquement**|Environnement de production critique|`apt upgrade -s` puis sélection manuelle|
|**Mises à jour automatiques**|Serveurs de développement|Configuration d'`unattended-upgrades`|
|**Mises à jour manuelles planifiées**|Production standard|Fenêtres de maintenance régulières|
|**Mises à jour progressives**|Parcs de serveurs|Mise à jour par vagues avec tests|

### Mise en place des mises à jour automatiques de sécurité

#### Sur Debian/Ubuntu

```bash
# Installer le paquet de mises à jour automatiques
sudo apt install unattended-upgrades

# Activer les mises à jour automatiques
sudo dpkg-reconfigure -plow unattended-upgrades

# Configuration avancée
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

Exemple de configuration `/etc/apt/apt.conf.d/50unattended-upgrades` :

```bash
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    // "${distro_id}:${distro_codename}-updates";
};

# Redémarrer automatiquement si nécessaire
Unattended-Upgrade::Automatic-Reboot "true";

# Heure de redémarrage automatique (2h du matin)
Unattended-Upgrade::Automatic-Reboot-Time "02:00";

# Email de notification
Unattended-Upgrade::Mail "admin@example.com";

# Ne pas mettre à jour ces paquets automatiquement
Unattended-Upgrade::Package-Blacklist {
    "apache2";
    "mysql-server";
    "php";
};
```

> [!tip] Bonne pratique N'activez les redémarrages automatiques que si vous avez un système de monitoring qui vous alertera en cas de problème. Pour les serveurs critiques, privilégiez les redémarrages manuels pendant les fenêtres de maintenance.

### Vérification avant mise à jour

```bash
# Simuler une mise à jour (dry-run)
sudo apt upgrade -s
sudo yum update --assumeno

# Vérifier l'espace disque disponible
df -h

# Vérifier la mémoire disponible
free -h

# Lister les services critiques en cours
systemctl list-units --type=service --state=running | grep -E 'apache|mysql|php'
```

> [!warning] Pièges courants
> 
> - **Manque d'espace disque** : Les mises à jour échouent silencieusement si `/var` est plein
> - **Kernel en cours vs installé** : Après une mise à jour du kernel, un redémarrage est nécessaire
> - **Paquets retenus (held)** : Certains paquets peuvent être marqués comme "hold" et ne seront pas mis à jour

### Gestion des paquets retenus

```bash
# Voir les paquets retenus
apt-mark showhold
dpkg --get-selections | grep hold

# Retenir un paquet (empêcher sa mise à jour)
sudo apt-mark hold nom_paquet

# Libérer un paquet retenu
sudo apt-mark unhold nom_paquet

# Exemple : retenir Apache pendant une maintenance
sudo apt-mark hold apache2
```

---

## 🏗️ Mise à jour des composants LAMP

### Stratégie de mise à jour des composants

La mise à jour des composants LAMP nécessite une approche prudente car ils sont au cœur de vos applications web.

> [!info] Ordre de mise à jour recommandé
> 
> 1. **Linux** (système de base)
> 2. **MySQL/MariaDB** (base de données)
> 3. **Apache** (serveur web)
> 4. **PHP** (langage)

Cet ordre minimise les risques de conflits de dépendances.

### Mise à jour d'Apache

```bash
# Vérifier la version actuelle
apache2 -v
httpd -v  # Sur RedHat/CentOS

# Voir les mises à jour disponibles
apt list --upgradable | grep apache2
yum list updates | grep httpd

# Sauvegarder la configuration
sudo cp -r /etc/apache2 /etc/apache2.backup.$(date +%Y%m%d)
sudo cp -r /etc/httpd /etc/httpd.backup.$(date +%Y%m%d)  # RedHat

# Mettre à jour Apache
sudo apt update && sudo apt upgrade apache2
sudo yum update httpd

# Vérifier la configuration après mise à jour
sudo apache2ctl configtest
sudo apachectl configtest

# Redémarrer Apache
sudo systemctl restart apache2
sudo systemctl restart httpd
```

> [!tip] Astuce : Rechargement gracieux Utilisez `reload` plutôt que `restart` pour éviter de couper les connexions en cours :
> 
> ```bash
> sudo systemctl reload apache2
> ```

### Mise à jour de MySQL/MariaDB

```bash
# Vérifier la version actuelle
mysql --version
mysqld --version

# Sauvegarder TOUTES les bases de données AVANT la mise à jour
sudo mysqldump --all-databases --single-transaction --quick --lock-tables=false \
  > /backup/all-databases-$(date +%Y%m%d-%H%M%S).sql

# OU sauvegarder avec compression
sudo mysqldump --all-databases --single-transaction --quick --lock-tables=false \
  | gzip > /backup/all-databases-$(date +%Y%m%d-%H%M%S).sql.gz

# Mettre à jour MySQL/MariaDB
sudo apt update && sudo apt upgrade mysql-server
sudo yum update mysql-server

# Exécuter le script de mise à niveau (IMPORTANT)
sudo mysql_upgrade -u root -p

# Redémarrer le service
sudo systemctl restart mysql
sudo systemctl restart mariadb
```

> [!warning] Attention aux versions majeures Les mises à jour de versions majeures (ex: MySQL 5.7 → 8.0 ou MariaDB 10.4 → 10.11) nécessitent une préparation spéciale :
> 
> - Lire les notes de version
> - Tester sur un environnement de développement
> - Vérifier la compatibilité des applications
> - Planifier un rollback si nécessaire

### Vérification post-mise à jour MySQL

```bash
# Vérifier que MySQL fonctionne
sudo systemctl status mysql

# Se connecter et vérifier
mysql -u root -p -e "SELECT VERSION();"

# Vérifier les bases de données
mysql -u root -p -e "SHOW DATABASES;"

# Vérifier les logs pour des erreurs
sudo tail -f /var/log/mysql/error.log
```

### Mise à jour PHP

La mise à jour de PHP est traitée en détail dans la section suivante sur la gestion des versions PHP, car elle implique souvent des changements de version majeure.

### Checklist de mise à jour LAMP

```bash
#!/bin/bash
# Script de vérification post-mise à jour

echo "=== Vérification des services LAMP ==="

# Apache
if systemctl is-active --quiet apache2; then
    echo "✓ Apache est actif"
    apache2 -v
else
    echo "✗ Apache n'est pas actif !"
fi

# MySQL/MariaDB
if systemctl is-active --quiet mysql; then
    echo "✓ MySQL est actif"
    mysql --version
else
    echo "✗ MySQL n'est pas actif !"
fi

# PHP
if command -v php &> /dev/null; then
    echo "✓ PHP est installé"
    php -v
else
    echo "✗ PHP n'est pas trouvé !"
fi

# Test de connexion
echo "=== Test de la stack LAMP ==="
echo "<?php phpinfo(); ?>" | php | grep "PHP Version"
```

> [!example] Exemple de procédure de mise à jour en production
> 
> 1. **J-7** : Notification de la fenêtre de maintenance
> 2. **J-1** : Sauvegarde complète du système
> 3. **Jour J - 2h** : Début de la maintenance
> 4. **2h15** : Mise à jour système et composants
> 5. **2h45** : Tests fonctionnels
> 6. **3h** : Monitoring renforcé
> 7. **J+1** : Bilan post-maintenance

---

## 🔀 Gestion des versions PHP

La gestion des versions PHP est cruciale car différentes applications peuvent nécessiter différentes versions. PHP évolue rapidement et les anciennes versions deviennent rapidement obsolètes et non supportées.

### Cycle de vie des versions PHP

|Version PHP|Sortie|Support actif jusqu'à|Support sécurité jusqu'à|Statut|
|---|---|---|---|---|
|PHP 7.4|Nov 2019|Nov 2021|Nov 2022|❌ Obsolète|
|PHP 8.0|Nov 2020|Nov 2022|Nov 2023|❌ Obsolète|
|PHP 8.1|Nov 2021|Nov 2023|Nov 2025|⚠️ Sécurité seule|
|PHP 8.2|Dec 2022|Dec 2024|Dec 2026|✅ Support actif|
|PHP 8.3|Nov 2023|Nov 2025|Nov 2027|✅ Support actif|

> [!warning] Versions obsolètes Une version PHP qui n'est plus supportée ne reçoit plus de correctifs de sécurité. Utiliser une version obsolète expose votre serveur à des vulnérabilités connues et non corrigées.

### Installation de multiples versions PHP

#### Sur Ubuntu/Debian avec le dépôt Ondřej Surý

```bash
# Ajouter le dépôt PPA (le plus utilisé pour PHP)
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update

# Installer plusieurs versions PHP
sudo apt install php8.1 php8.1-fpm php8.1-mysql php8.1-cli
sudo apt install php8.2 php8.2-fpm php8.2-mysql php8.2-cli
sudo apt install php8.3 php8.3-fpm php8.3-mysql php8.3-cli

# Installer les extensions courantes pour chaque version
sudo apt install php8.3-{curl,gd,mbstring,xml,zip,intl,bcmath}
```

> [!info] FPM vs Module Apache
> 
> - **PHP-FPM** (FastCGI Process Manager) : Recommandé, meilleure performance, isolation par version
> - **Module Apache** (libapache2-mod-php) : Plus simple mais une seule version active à la fois

#### Sur RedHat/CentOS avec Remi

```bash
# Installer le dépôt EPEL et Remi
sudo yum install epel-release
sudo yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm

# Lister les versions PHP disponibles
sudo yum module list php

# Installer PHP 8.2
sudo yum module enable php:remi-8.2
sudo yum install php php-fpm php-mysqlnd php-cli

# Pour installer une autre version en parallèle
sudo yum install php83 php83-php-fpm php83-php-mysqlnd
```

### Basculer entre les versions PHP (CLI)

```bash
# Voir les versions installées
ls /usr/bin/php*

# Voir la version PHP CLI par défaut
php -v

# Utiliser update-alternatives pour changer la version par défaut
sudo update-alternatives --config php

# Ou définir manuellement
sudo update-alternatives --set php /usr/bin/php8.3

# Utiliser une version spécifique ponctuellement
/usr/bin/php8.2 script.php
```

### Configuration Apache avec plusieurs versions PHP

#### Méthode 1 : VirtualHost avec PHP-FPM

```apache
# /etc/apache2/sites-available/site-php82.conf

<VirtualHost *:80>
    ServerName site1.example.com
    DocumentRoot /var/www/site1
    
    # Utiliser PHP 8.2 via FPM
    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php8.2-fpm.sock|fcgi://localhost"
    </FilesMatch>
    
    <Directory /var/www/site1>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/site1-error.log
    CustomLog ${APACHE_LOG_DIR}/site1-access.log combined
</VirtualHost>
```

```apache
# /etc/apache2/sites-available/site-php83.conf

<VirtualHost *:80>
    ServerName site2.example.com
    DocumentRoot /var/www/site2
    
    # Utiliser PHP 8.3 via FPM
    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php8.3-fpm.sock|fcgi://localhost"
    </FilesMatch>
    
    <Directory /var/www/site2>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/site2-error.log
    CustomLog ${APACHE_LOG_DIR}/site2-access.log combined
</VirtualHost>
```

```bash
# Activer les modules nécessaires
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php8.2-fpm
sudo a2enconf php8.3-fpm

# Activer les sites
sudo a2ensite site-php82
sudo a2ensite site-php83

# Redémarrer Apache
sudo systemctl reload apache2
```

#### Méthode 2 : Répertoires avec versions différentes

```apache
<VirtualHost *:80>
    ServerName multiversion.example.com
    DocumentRoot /var/www/multiversion
    
    # PHP 8.3 par défaut
    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php8.3-fpm.sock|fcgi://localhost"
    </FilesMatch>
    
    # PHP 8.2 pour un répertoire spécifique
    <Directory /var/www/multiversion/legacy-app>
        <FilesMatch \.php$>
            SetHandler "proxy:unix:/run/php/php8.2-fpm.sock|fcgi://localhost"
        </FilesMatch>
    </Directory>
</VirtualHost>
```

### Gestion des pools PHP-FPM

Chaque version PHP-FPM peut avoir plusieurs pools avec des configurations différentes.

```bash
# Configuration d'un pool personnalisé
sudo nano /etc/php/8.3/fpm/pool.d/site1.conf
```

```ini
[site1]
; Utilisateur et groupe
user = www-data
group = www-data

; Socket Unix (recommandé pour les performances locales)
listen = /run/php/php8.3-fpm-site1.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

; Gestionnaire de processus
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500

; Limites de ressources
php_admin_value[memory_limit] = 256M
php_admin_value[upload_max_filesize] = 50M
php_admin_value[post_max_size] = 50M
php_admin_value[max_execution_time] = 60

; Logs spécifiques
php_admin_value[error_log] = /var/log/php-fpm/site1-error.log
php_admin_flag[log_errors] = on

; Variables d'environnement
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
```

```bash
# Vérifier la configuration
sudo php-fpm8.3 -t

# Redémarrer PHP-FPM
sudo systemctl restart php8.3-fpm

# Voir le statut de tous les pools
sudo systemctl status php*-fpm
```

> [!tip] Optimisation des pools
> 
> - **Sites à fort trafic** : `pm = dynamic` avec des valeurs élevées
> - **Sites légers** : `pm = ondemand` pour économiser la RAM
> - **Sites critiques** : `pm = static` pour des performances prévisibles

### Migration vers une nouvelle version PHP

```bash
# 1. Installer la nouvelle version
sudo apt install php8.3 php8.3-fpm php8.3-mysql php8.3-{curl,gd,mbstring,xml,zip}

# 2. Copier la configuration de l'ancienne version
sudo cp /etc/php/8.2/fpm/php.ini /etc/php/8.3/fpm/php.ini

# 3. Adapter les pools si nécessaire
sudo cp -r /etc/php/8.2/fpm/pool.d/* /etc/php/8.3/fpm/pool.d/

# 4. Tester la configuration
sudo php-fpm8.3 -t

# 5. Démarrer le nouveau service
sudo systemctl start php8.3-fpm
sudo systemctl enable php8.3-fpm

# 6. Modifier la configuration Apache (VirtualHost)
# Remplacer php8.2-fpm.sock par php8.3-fpm.sock

# 7. Recharger Apache
sudo systemctl reload apache2

# 8. Tester l'application
# Créer un fichier phpinfo.php pour vérifier
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/test.php

# 9. Une fois validé, arrêter l'ancienne version
sudo systemctl stop php8.2-fpm
sudo systemctl disable php8.2-fpm

# 10. Optionnel : désinstaller l'ancienne version
sudo apt remove php8.2*
```

> [!warning] Points d'attention lors de la migration
> 
> - **Extensions obsolètes** : Certaines extensions peuvent ne plus être disponibles
> - **Fonctions dépréciées** : Consulter les logs PHP pour identifier les avertissements
> - **Performances** : Tester la charge avant de migrer en production
> - **Composer** : Mettre à jour les dépendances pour assurer la compatibilité

### Vérification des versions actives

```bash
# Version PHP CLI
php -v

# Versions PHP-FPM en cours d'exécution
systemctl list-units --type=service | grep php-fpm

# Vérifier quelle version répond sur un VirtualHost
curl -I http://site1.example.com/phpinfo.php | grep X-Powered-By

# Ou créer un script de test
cat << 'EOF' | sudo tee /var/www/html/version.php
<?php
header('Content-Type: text/plain');
echo "PHP Version: " . PHP_VERSION . "\n";
echo "Server API: " . php_sapi_name() . "\n";
echo "Loaded extensions:\n";
print_r(get_loaded_extensions());
EOF
```

### Compatibilité et tests

```bash
# Vérifier la syntaxe PHP d'un fichier avec une version spécifique
php8.3 -l fichier.php

# Lister les fonctions dépréciées dans un projet
grep -r "ereg\|mysql_\|split" /var/www/monsite/

# Utiliser PHP CodeSniffer pour détecter les problèmes
composer global require "squizlabs/php_codesniffer=*"
phpcs --standard=PHPCompatibility --runtime-set testVersion 8.3 /var/www/monsite/
```

> [!tip] Astuce : Environnement de test Avant de migrer en production, créez un environnement de staging avec la nouvelle version PHP :
> 
> ```bash
> # Sous-domaine de test
> sudo cp /etc/apache2/sites-available/site.conf \
>          /etc/apache2/sites-available/test-site.conf
> 
> # Modifier pour utiliser test.example.com et PHP 8.3
> sudo nano /etc/apache2/sites-available/test-site.conf
> sudo a2ensite test-site
> sudo systemctl reload apache2
> ```

### Désinstallation propre d'une version PHP

```bash
# Lister tous les paquets PHP d'une version
dpkg -l | grep php8.2

# Désinstaller une version spécifique et ses extensions
sudo apt purge php8.2*

# Nettoyer les dépendances orphelines
sudo apt autoremove

# Supprimer les fichiers de configuration restants
sudo rm -rf /etc/php/8.2/

# Nettoyer les logs
sudo rm -rf /var/log/php8.2-fpm.log
```

---

## 🎯 Récapitulatif des bonnes pratiques

### Mises à jour système

✅ **À faire :**

- Planifier des fenêtres de maintenance régulières
- Toujours sauvegarder avant une mise à jour majeure
- Tester en environnement de développement d'abord
- Utiliser les mises à jour automatiques pour les correctifs de sécurité
- Surveiller les logs après les mises à jour

❌ **À éviter :**

- Mettre à jour en production sans test préalable
- Négliger les mises à jour de sécurité
- Oublier de redémarrer après une mise à jour du kernel
- Mettre à jour sans vérifier l'espace disque

### Composants LAMP

✅ **À faire :**

- Suivre l'ordre : Linux → MySQL → Apache → PHP
- Faire des sauvegardes complètes de la base de données
- Vérifier la configuration après chaque mise à jour
- Utiliser `reload` plutôt que `restart` quand possible
- Documenter les versions utilisées

❌ **À éviter :**

- Sauter les versions majeures sans préparation
- Mettre à jour MySQL sans exécuter `mysql_upgrade`
- Ignorer les incompatibilités de versions
- Oublier de tester les applications après mise à jour

### Gestion PHP

✅ **À faire :**

- Utiliser PHP-FPM pour gérer plusieurs versions
- Maintenir au moins 2 versions PHP supportées
- Planifier les migrations de version PHP
- Tester la compatibilité avant migration
- Configurer des pools séparés par application

❌ **À éviter :**

- Utiliser des versions PHP obsolètes
- Changer de version PHP sans tester
- Négliger la configuration des pools PHP-FPM
- Mélanger les versions dans le même VirtualHost sans raison