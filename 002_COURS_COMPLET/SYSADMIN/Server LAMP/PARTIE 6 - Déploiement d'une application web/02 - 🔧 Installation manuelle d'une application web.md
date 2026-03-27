

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

L'installation manuelle d'une application web consiste à déployer une application sans utiliser de gestionnaire de paquets ou d'outils d'automatisation. Cette méthode vous donne un contrôle total sur le processus et permet de comprendre en profondeur l'architecture d'une application web.

> [!info] Pourquoi installer manuellement ?
> 
> - **Contrôle total** : Vous maîtrisez chaque étape du déploiement
> - **Flexibilité** : Possibilité de personnaliser l'installation selon vos besoins
> - **Apprentissage** : Meilleure compréhension de la structure des applications web
> - **Situations spécifiques** : Applications non disponibles via gestionnaire de paquets

> [!warning] Prérequis
> 
> - Serveur LAMP fonctionnel (Apache, MySQL, PHP)
> - Accès SSH ou terminal sur le serveur
> - Droits d'administration (sudo)
> - Connaissance de la structure du DocumentRoot

---

## 📥 Téléchargement des fichiers

### 🔍 Localisation de l'application

Avant de télécharger, identifiez la source officielle de l'application. Les applications web sont généralement distribuées sous forme d'archives compressées (.zip, .tar.gz, .tar.bz2).

```bash
# Se positionner dans un répertoire temporaire
cd /tmp

# Méthode 1 : Téléchargement avec wget
wget https://exemple.com/application-version.tar.gz

# Méthode 2 : Téléchargement avec curl
curl -O https://exemple.com/application-version.tar.gz

# Méthode 3 : Téléchargement avec curl et nom personnalisé
curl -o mon_app.tar.gz https://exemple.com/application-version.tar.gz
```

> [!tip] Astuce : Vérification de l'intégrité Téléchargez toujours le fichier de checksum (MD5, SHA256) pour vérifier l'intégrité :
> 
> ```bash
> # Télécharger le fichier de checksum
> wget https://exemple.com/application-version.tar.gz.sha256
> 
> # Vérifier l'intégrité
> sha256sum -c application-version.tar.gz.sha256
> ```

### 📦 Types d'archives courants

|Extension|Commande de décompression|Usage typique|
|---|---|---|
|`.tar.gz` ou `.tgz`|`tar -xzf fichier.tar.gz`|Linux/Unix standard|
|`.tar.bz2`|`tar -xjf fichier.tar.bz2`|Meilleure compression|
|`.zip`|`unzip fichier.zip`|Multi-plateforme|
|`.tar.xz`|`tar -xJf fichier.tar.xz`|Compression optimale|

> [!example] Exemple : Téléchargement de WordPress
> 
> ```bash
> # Se placer dans /tmp
> cd /tmp
> 
> # Télécharger la dernière version de WordPress
> wget https://wordpress.org/latest.tar.gz
> 
> # Vérifier la taille du fichier téléchargé
> ls -lh latest.tar.gz
> 
> # Afficher les informations du fichier
> file latest.tar.gz
> ```

### 🔐 Téléchargement sécurisé

```bash
# Forcer HTTPS et vérifier le certificat SSL
wget --secure-protocol=TLSv1_2 https://exemple.com/app.tar.gz

# Suivre les redirections de manière sécurisée
wget --max-redirect=3 https://exemple.com/app.tar.gz

# Télécharger avec authentification si nécessaire
wget --user=utilisateur --password=motdepasse https://exemple.com/app.tar.gz

# Ou mieux : utiliser un fichier de credentials
wget --user=utilisateur --ask-password https://exemple.com/app.tar.gz
```

---

## 📂 Extraction et placement dans DocumentRoot

### 🗂️ Comprendre le DocumentRoot

Le **DocumentRoot** est le répertoire racine où Apache cherche les fichiers à servir. Par défaut :

- `/var/www/html` sur Debian/Ubuntu
- `/var/www/html` ou `/usr/share/nginx/html` selon la configuration

```bash
# Vérifier le DocumentRoot actuel
grep -r "DocumentRoot" /etc/apache2/sites-enabled/

# Ou consulter la configuration du site par défaut
cat /etc/apache2/sites-available/000-default.conf | grep DocumentRoot
```

### 📦 Extraction de l'archive

```bash
# Méthode 1 : Extraction dans /tmp puis déplacement
cd /tmp
tar -xzf application.tar.gz

# Vérifier le contenu extrait
ls -la application/

# Méthode 2 : Extraction directe dans DocumentRoot (nécessite sudo)
sudo tar -xzf /tmp/application.tar.gz -C /var/www/html/

# Méthode 3 : Extraction avec préservation des permissions
sudo tar -xzpf /tmp/application.tar.gz -C /var/www/html/
```

> [!info] Options de tar expliquées
> 
> - `-x` : Extraire les fichiers
> - `-z` : Décompresser avec gzip
> - `-f` : Spécifier le fichier archive
> - `-C` : Changer de répertoire avant extraction
> - `-p` : Préserver les permissions d'origine
> - `-v` : Mode verbeux (afficher les fichiers extraits)

### 🎯 Placement et organisation

```bash
# Renommer le répertoire extrait pour plus de clarté
cd /var/www/html/
sudo mv application-1.2.3 monapp

# Ou créer un sous-répertoire dédié
sudo mkdir -p /var/www/html/applications
sudo mv application-1.2.3 /var/www/html/applications/monapp

# Vérifier la structure
tree -L 2 /var/www/html/monapp
# ou simplement
ls -la /var/www/html/monapp
```

### 🔒 Configuration des permissions

La gestion des permissions est **cruciale** pour la sécurité et le fonctionnement de l'application.

```bash
# Attribuer la propriété à l'utilisateur Apache
sudo chown -R www-data:www-data /var/www/html/monapp

# Définir les permissions de base (755 pour dossiers, 644 pour fichiers)
sudo find /var/www/html/monapp -type d -exec chmod 755 {} \;
sudo find /var/www/html/monapp -type f -exec chmod 644 {} \;

# Rendre certains répertoires écriture pour l'application (uploads, cache, etc.)
sudo chmod -R 775 /var/www/html/monapp/uploads
sudo chmod -R 775 /var/www/html/monapp/cache
sudo chmod -R 775 /var/www/html/monapp/tmp
```

> [!warning] Permissions sensibles **Ne jamais** mettre 777 sur des fichiers ou dossiers en production :
> 
> - `777` = Lecture, écriture, exécution pour tout le monde (dangereux)
> - `755` = Propriétaire RWX, autres RX (dossiers standards)
> - `644` = Propriétaire RW, autres R (fichiers standards)
> - `775` = Propriétaire et groupe RWX, autres RX (dossiers partagés)

### 📊 Vérification de l'installation

```bash
# Vérifier la structure des fichiers
ls -lah /var/www/html/monapp

# Vérifier les permissions récursives
namei -l /var/www/html/monapp/index.php

# Tester l'accès web (sans navigateur)
curl http://localhost/monapp/
```

> [!example] Exemple complet : Installation de WordPress
> 
> ```bash
> # 1. Téléchargement
> cd /tmp
> wget https://wordpress.org/latest.tar.gz
> 
> # 2. Extraction
> tar -xzf latest.tar.gz
> 
> # 3. Déplacement vers DocumentRoot
> sudo mv wordpress /var/www/html/monblog
> 
> # 4. Configuration des permissions
> sudo chown -R www-data:www-data /var/www/html/monblog
> sudo find /var/www/html/monblog -type d -exec chmod 755 {} \;
> sudo find /var/www/html/monblog -type f -exec chmod 644 {} \;
> sudo chmod -R 775 /var/www/html/monblog/wp-content/uploads
> 
> # 5. Vérification
> ls -la /var/www/html/monblog
> ```

---

## ⚙️ Configuration de l'application

### 📝 Fichier de configuration principal

La plupart des applications web utilisent un fichier de configuration pour stocker les paramètres critiques : connexion base de données, URLs, clés de sécurité, etc.

#### 🔍 Localisation du fichier

```bash
# Fichiers de configuration courants
config.php
configuration.php
config.inc.php
wp-config.php (WordPress)
config/database.php
.env (applications modernes)
settings.php
```

```bash
# Rechercher les fichiers de configuration
find /var/www/html/monapp -name "*config*" -type f

# Ou rechercher les exemples de configuration
find /var/www/html/monapp -name "*.sample" -o -name "*.example"
```

### 📋 Création du fichier de configuration

De nombreuses applications fournissent un fichier exemple à copier :

```bash
# Copier le fichier exemple
cd /var/www/html/monapp
sudo cp config.sample.php config.php

# Ou créer directement le fichier
sudo nano config.php
```

### 🗄️ Configuration de la base de données

#### Création de la base et de l'utilisateur

```bash
# Se connecter à MySQL
sudo mysql -u root -p

# Ou si configuré sans mot de passe root
sudo mysql
```

```sql
-- Créer la base de données
CREATE DATABASE monapp_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Créer l'utilisateur dédié
CREATE USER 'monapp_user'@'localhost' IDENTIFIED BY 'MotDePasseSecurise123!';

-- Accorder les privilèges
GRANT ALL PRIVILEGES ON monapp_db.* TO 'monapp_user'@'localhost';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Quitter MySQL
EXIT;
```

> [!tip] Bonnes pratiques de sécurité
> 
> - Utilisez un mot de passe fort (minimum 16 caractères, mixte)
> - Créez un utilisateur dédié par application (pas de root)
> - Limitez les privilèges au strict nécessaire
> - Utilisez `'utilisateur'@'localhost'` pour limiter les connexions locales

#### Configuration dans le fichier PHP

```bash
# Éditer le fichier de configuration
sudo nano /var/www/html/monapp/config.php
```

```php
<?php
// Configuration de la base de données
define('DB_HOST', 'localhost');
define('DB_NAME', 'monapp_db');
define('DB_USER', 'monapp_user');
define('DB_PASSWORD', 'MotDePasseSecurise123!');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', 'utf8mb4_unicode_ci');

// Configuration des URLs
define('SITE_URL', 'http://mondomaine.com/monapp');
define('BASE_PATH', '/var/www/html/monapp');

// Paramètres de sécurité
define('SECRET_KEY', 'générer-une-clé-aléatoire-unique');
define('SALT', 'générer-un-salt-aléatoire-unique');

// Environnement (development, production)
define('ENVIRONMENT', 'production');
define('DEBUG', false);
?>
```

### 🔐 Génération de clés de sécurité

De nombreuses applications nécessitent des clés de sécurité uniques :

```bash
# Générer une clé aléatoire sécurisée (64 caractères)
openssl rand -base64 48

# Générer plusieurs clés d'un coup
for i in {1..5}; do openssl rand -base64 48; done

# Ou utiliser pwgen
pwgen -s 64 1
```

> [!example] Exemple : Configuration WordPress
> 
> ```bash
> # Copier le fichier de configuration
> sudo cp /var/www/html/monblog/wp-config-sample.php /var/www/html/monblog/wp-config.php
> 
> # Éditer le fichier
> sudo nano /var/www/html/monblog/wp-config.php
> ```
> 
> ```php
> <?php
> // Base de données
> define( 'DB_NAME', 'wordpress_db' );
> define( 'DB_USER', 'wp_user' );
> define( 'DB_PASSWORD', 'MotDePasseSecurise123!' );
> define( 'DB_HOST', 'localhost' );
> define( 'DB_CHARSET', 'utf8mb4' );
> define( 'DB_COLLATE', '' );
> 
> // Clés de sécurité (obtenir via https://api.wordpress.org/secret-key/1.1/salt/)
> define('AUTH_KEY',         'clé-générée-aléatoirement');
> define('SECURE_AUTH_KEY',  'clé-générée-aléatoirement');
> define('LOGGED_IN_KEY',    'clé-générée-aléatoirement');
> define('NONCE_KEY',        'clé-générée-aléatoirement');
> // ... autres clés
> ?>
> ```

### 🌐 Configuration du Virtual Host (optionnel mais recommandé)

Pour servir l'application sur un domaine spécifique :

```bash
# Créer le fichier de configuration du Virtual Host
sudo nano /etc/apache2/sites-available/monapp.conf
```

```apache
<VirtualHost *:80>
    ServerName monapp.exemple.com
    ServerAlias www.monapp.exemple.com
    
    DocumentRoot /var/www/html/monapp
    
    <Directory /var/www/html/monapp>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/monapp_error.log
    CustomLog ${APACHE_LOG_DIR}/monapp_access.log combined
</VirtualHost>
```

```bash
# Activer le site
sudo a2ensite monapp.conf

# Tester la configuration
sudo apache2ctl configtest

# Recharger Apache
sudo systemctl reload apache2
```

### 🔒 Sécurisation du fichier de configuration

```bash
# Permissions restrictives sur le fichier de configuration
sudo chmod 640 /var/www/html/monapp/config.php
sudo chown www-data:www-data /var/www/html/monapp/config.php

# Vérifier les permissions
ls -l /var/www/html/monapp/config.php
```

> [!warning] Fichiers sensibles Fichiers à protéger **impérativement** :
> 
> - `config.php` et variants : informations de connexion BDD
> - `.env` : variables d'environnement sensibles
> - `composer.json` / `package.json` : informations sur les dépendances
> - Répertoires `.git/` : historique du code (à exclure du web)

---

## 🌐 Finalisation via navigateur

### 🚀 Lancement de l'assistant d'installation

La plupart des applications web modernes proposent un assistant d'installation graphique accessible via navigateur.

#### Accès à l'installateur

1. **Ouvrir le navigateur** et accéder à l'URL de l'application :
    
    ```
    http://votre-serveur/monapp/
    ou
    http://votre-serveur/monapp/install.php
    ou
    http://votre-serveur/monapp/setup.php
    ```
    
2. **URLs d'installation courantes** selon les applications :
    

|Application|URL d'installation|
|---|---|
|WordPress|`/wp-admin/install.php`|
|Joomla|`/installation/index.php`|
|Drupal|`/install.php`|
|PrestaShop|`/install/`|
|phpMyAdmin|`/setup/`|

> [!info] Redirection automatique De nombreuses applications détectent qu'elles ne sont pas configurées et redirigent automatiquement vers l'installateur lors de la première visite.

### 📋 Étapes typiques de l'installation web

#### 1. Vérification des prérequis

L'installateur vérifie que le serveur répond aux exigences :

- Version PHP compatible
- Extensions PHP nécessaires (mysqli, gd, curl, zip, etc.)
- Permissions d'écriture sur certains répertoires
- Configuration PHP (memory_limit, upload_max_filesize, etc.)

```bash
# Si des prérequis manquent, installer les extensions nécessaires
sudo apt update
sudo apt install php-mysql php-gd php-curl php-zip php-mbstring php-xml

# Redémarrer Apache
sudo systemctl restart apache2
```

#### 2. Configuration de la base de données

L'interface vous demande les informations de connexion :

- **Hôte de la base** : `localhost` (dans la plupart des cas)
- **Nom de la base** : `monapp_db`
- **Utilisateur** : `monapp_user`
- **Mot de passe** : le mot de passe défini précédemment
- **Préfixe des tables** : `app_` (pour éviter les conflits)

> [!warning] Erreurs de connexion courantes Si la connexion échoue :
> 
> ```bash
> # Vérifier que MySQL est actif
> sudo systemctl status mysql
> 
> # Tester la connexion depuis la ligne de commande
> mysql -u monapp_user -p monapp_db
> 
> # Vérifier les privilèges de l'utilisateur
> sudo mysql -u root -p
> ```
> 
> ```sql
> SHOW GRANTS FOR 'monapp_user'@'localhost';
> ```

#### 3. Configuration du site

Informations générales demandées :

- **Titre du site** : Nom de votre application/site
- **Description** : Brève description
- **URL du site** : `http://mondomaine.com/monapp`
- **Email de contact** : adresse email administrative

#### 4. Création du compte administrateur

Paramètres du premier utilisateur :

- **Nom d'utilisateur** : `admin` (éviter pour la sécurité)
- **Mot de passe** : Générer un mot de passe fort
- **Email** : Adresse email valide

> [!tip] Sécurité du compte admin
> 
> - N'utilisez JAMAIS "admin" comme nom d'utilisateur
> - Utilisez un nom d'utilisateur unique et imprévisible
> - Mot de passe minimum 16 caractères avec majuscules, minuscules, chiffres, symboles
> - Activez l'authentification à deux facteurs (2FA) si disponible

#### 5. Importation des données initiales

Certaines applications proposent :

- Import de données d'exemple (démo)
- Configuration de thèmes par défaut
- Installation de plugins/modules essentiels

> [!info] Recommandation Ne pas installer les données de démonstration en production, uniquement pour tester l'application.

#### 6. Finalisation

L'installateur :

1. Crée les tables de la base de données
2. Insère les données de configuration
3. Génère les fichiers nécessaires
4. Configure les paramètres de sécurité de base

### 🔒 Actions post-installation

#### Suppression des fichiers d'installation

**CRITIQUE** pour la sécurité :

```bash
# Supprimer ou renommer le répertoire d'installation
sudo rm -rf /var/www/html/monapp/install
sudo rm -rf /var/www/html/monapp/installation

# Ou renommer pour le désactiver
sudo mv /var/www/html/monapp/install /var/www/html/monapp/install.old
sudo mv /var/www/html/monapp/install.php /var/www/html/monapp/install.php.old
```

> [!warning] Sécurité critique Les fichiers d'installation peuvent permettre à un attaquant de **réinitialiser complètement** votre application. Leur suppression est **obligatoire** après installation.

#### Vérification des permissions finales

```bash
# Vérifier les permissions des fichiers sensibles
ls -l /var/www/html/monapp/config.php
ls -ld /var/www/html/monapp/uploads

# Restreindre l'accès au fichier de configuration
sudo chmod 640 /var/www/html/monapp/config.php
```

#### Configuration du fichier .htaccess

Si l'application utilise Apache avec mod_rewrite :

```bash
# Vérifier que mod_rewrite est activé
sudo a2enmod rewrite
sudo systemctl restart apache2

# Créer ou éditer le .htaccess
sudo nano /var/www/html/monapp/.htaccess
```

```apache
# Exemple de .htaccess basique
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /monapp/
    
    # Rediriger vers index.php si le fichier n'existe pas
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php?/$1 [L]
</IfModule>

# Désactiver l'affichage du contenu des répertoires
Options -Indexes

# Protéger les fichiers sensibles
<FilesMatch "^(config\.php|\.env|composer\.json)$">
    Require all denied
</FilesMatch>
```

### ✅ Test final de l'application

```bash
# Test de la page d'accueil
curl -I http://localhost/monapp/

# Test avec authentification si nécessaire
curl -u admin:password http://localhost/monapp/admin/

# Vérifier les logs Apache pour erreurs
sudo tail -f /var/log/apache2/error.log

# Vérifier les logs de l'application
sudo tail -f /var/www/html/monapp/logs/error.log
```

> [!example] Exemple : Finalisation WordPress
> 
> 1. Accéder à `http://votre-serveur/monblog/wp-admin/install.php`
> 2. Choisir la langue
> 3. Remplir les informations :
>     - Titre : "Mon Blog"
>     - Utilisateur : "admin_unique_123"
>     - Mot de passe fort généré
>     - Email : votre@email.com
> 4. Cliquer sur "Installer WordPress"
> 5. Se connecter au tableau de bord
> 6. **Important** : Supprimer le fichier install.php est géré automatiquement par WordPress

---

## ⚠️ Pièges courants et bonnes pratiques

### 🚫 Erreurs fréquentes

#### 1. Permissions incorrectes

```bash
# ❌ MAUVAIS : Permissions trop permissives
sudo chmod -R 777 /var/www/html/monapp  # DANGEREUX !

# ✅ BON : Permissions appropriées
sudo chown -R www-data:www-data /var/www/html/monapp
sudo find /var/www/html/monapp -type d -exec chmod 755 {} \;
sudo find /var/www/html/monapp -type f -exec chmod 644 {} \;
```

> [!warning] Pourquoi 777 est dangereux ?
> 
> - N'importe quel utilisateur peut modifier les fichiers
> - Scripts malveillants peuvent être injectés
> - Fichiers de configuration exposés à la modification
> - Violation des standards de sécurité

#### 2. Configuration de base de données

```bash
# ❌ MAUVAIS : Utiliser le compte root
DB_USER='root'
DB_PASSWORD='password'

# ✅ BON : Utilisateur dédié avec privilèges limités
DB_USER='monapp_user'
DB_PASSWORD='MotDePasseComplexe123!@#'
```

#### 3. Fichiers d'installation non supprimés

```bash
# ❌ MAUVAIS : Laisser les fichiers d'installation
# Fichiers exposés : install.php, setup.php, /installation/

# ✅ BON : Supprimer immédiatement après installation
sudo rm -rf /var/www/html/monapp/install
sudo rm /var/www/html/monapp/install.php
```

#### 4. DocumentRoot incorrect

```bash
# ❌ MAUVAIS : Pointer vers un sous-répertoire contenant des fichiers sensibles
DocumentRoot /var/www/html/monapp

# ✅ BON : Pointer vers le répertoire public si l'application a une structure MVC
DocumentRoot /var/www/html/monapp/public
```

#### 5. Oublier de redémarrer les services

```bash
# ❌ MAUVAIS : Modifier la configuration sans redémarrer
sudo nano /etc/apache2/sites-available/monapp.conf
# ... puis quitter sans recharger

# ✅ BON : Toujours tester et recharger
sudo apache2ctl configtest
sudo systemctl reload apache2
```

### ✅ Checklist de bonnes pratiques

#### Avant l'installation

- [ ] Vérifier la source officielle de l'application
- [ ] Lire la documentation d'installation
- [ ] Vérifier les prérequis système (PHP, extensions, etc.)
- [ ] Sauvegarder le serveur si des données existent
- [ ] Préparer les informations de base de données

#### Pendant l'installation

- [ ] Vérifier l'intégrité de l'archive téléchargée (checksum)
- [ ] Créer une base de données et un utilisateur dédiés
- [ ] Utiliser des mots de passe forts (16+ caractères)
- [ ] Configurer les permissions correctement (755/644)
- [ ] Ne pas exposer de fichiers sensibles (.git, .env, config.php)
- [ ] Tester la configuration Apache avant de recharger

#### Après l'installation

- [ ] Supprimer les fichiers d'installation
- [ ] Vérifier les permissions finales
- [ ] Tester l'accès à l'application
- [ ] Consulter les logs pour détecter les erreurs
- [ ] Mettre en place une sauvegarde
- [ ] Documenter la configuration pour référence future
- [ ] Configurer les mises à jour automatiques si disponibles
- [ ] Activer HTTPS (certificat SSL)

### 🛡️ Sécurisation supplémentaire

```bash
# Désactiver l'affichage des erreurs PHP en production
sudo nano /etc/php/8.1/apache2/php.ini
```

```ini
display_errors = Off
log_errors = On
error_log = /var/log/php/error.log
```

```bash
# Créer le répertoire de logs PHP
sudo mkdir -p /var/log/php
sudo chown www-data:www-data /var/log/php

# Protéger le fichier .htaccess contre la modification
sudo chown root:www-data /var/www/html/monapp/.htaccess
sudo chmod 644 /var/www/html/monapp/.htaccess
```

### 📊 Surveillance post-installation

```bash
# Surveiller les logs d'accès
sudo tail -f /var/log/apache2/access.log

# Surveiller les logs d'erreur
sudo tail -f /var/log/apache2/error.log

# Surveiller les logs de l'application
sudo tail -f /var/www/html/monapp/logs/app.log

# Vérifier l'utilisation du disque
df -h

# Vérifier les processus Apache/MySQL
ps aux | grep apache
ps aux | grep mysql
```

### 🔄 Maintenance régulière

```bash
# Sauvegarder la base de données
mysqldump -u monapp_user -p monapp_db > backup_$(date +%Y%m%d).sql

# Sauvegarder les fichiers de l'application
sudo tar -czf /backups/monapp_$(date +%Y%m%d).tar.gz /var/www/html/monapp

# Nettoyer les logs anciens
sudo find /var/log/apache2 -name "*.log" -mtime +30 -delete

# Vérifier les mises à jour de sécurité
sudo apt update
sudo apt list --upgradable
```

> [!tip] Automatisation Utilisez `cron` pour automatiser les sauvegardes :
> 
> ```bash
> # Éditer le crontab
> sudo crontab -e
> 
> # Ajouter une sauvegarde quotidienne à 2h du matin
> 0 2 * * * mysqldump -u monapp_user -pMotDePasse monapp_db > /backups/db_$(date +\%Y\%m\%d).sql
> ```

---

## 🎯 Résumé des commandes essentielles

```bash
# Téléchargement
wget https://exemple.com/app.tar.gz

# Extraction
tar -xzf app.tar.gz

# Déplacement
sudo mv app /var/www/html/monapp

# Permissions
sudo chown -R www-data:www-data /var/www/html/monapp
sudo find /var/www/html/monapp -type d -exec chmod 755 {} \;
sudo find /var/www/html/monapp -type f -exec chmod 644 {} \;

# Configuration base de données
sudo mysql -u root -p
# CREATE DATABASE monapp_db;
# CREATE USER 'monapp_user'@'localhost' IDENTIFIED BY 'password';
# GRANT ALL PRIVILEGES ON monapp_db.* TO 'monapp_user'@'localhost';
# FLUSH PRIVILEGES;
# EXIT;

# Copier et éditer le fichier de configuration
sudo cp config.sample.php config.php
sudo nano config.php

# Sécuriser le fichier de configuration
sudo chmod 640 config.php

# Finalisation via navigateur
# http://votre-serveur/monapp/install.php

# Suppression des fichiers d'installation (CRITIQUE)
sudo rm -rf /var/www/html/monapp/install
sudo rm /var/www/html/monapp/install.php

# Vérification
curl -I http://localhost/monapp/
sudo tail -f /var/log/apache2/error.log
```

---

## 📚 Points clés à retenir

### 🎯 Ordre des opérations

1. **Téléchargement** → Toujours vérifier la source officielle et l'intégrité
2. **Extraction** → Utiliser le bon répertoire temporaire (/tmp)
3. **Déplacement** → Placer dans DocumentRoot avec structure claire
4. **Permissions** → Configuration immédiate après déplacement
5. **Base de données** → Créer avant la configuration de l'application
6. **Configuration** → Fichiers sensibles avec permissions restrictives
7. **Installation web** → Suivre l'assistant pas à pas
8. **Sécurisation** → Suppression des fichiers d'installation obligatoire
9. **Tests** → Vérifier le fonctionnement complet
10. **Documentation** → Noter la configuration pour maintenance future

### 🔒 Sécurité avant tout

|Élément|Mauvaise pratique|Bonne pratique|
|---|---|---|
|**Permissions fichiers**|777|644|
|**Permissions dossiers**|777|755|
|**Utilisateur BDD**|root|Utilisateur dédié|
|**Mot de passe**|admin123|Complexe 16+ caractères|
|**Fichiers install**|Laisser en place|Supprimer immédiatement|
|**Config PHP**|display_errors = On|display_errors = Off (prod)|
|**DocumentRoot**|Racine app|Dossier public/ si MVC|

### 🎓 Compétences acquises

Après avoir suivi ce cours, vous êtes capable de :

- ✅ Télécharger et vérifier l'intégrité d'une application web
- ✅ Extraire et organiser les fichiers dans l'arborescence du serveur
- ✅ Configurer les permissions Linux de manière sécurisée
- ✅ Créer et configurer une base de données MySQL dédiée
- ✅ Éditer les fichiers de configuration d'applications PHP
- ✅ Finaliser l'installation via l'interface web
- ✅ Sécuriser l'installation post-déploiement
- ✅ Diagnostiquer et résoudre les problèmes courants
- ✅ Mettre en place une maintenance de base

### 💡 Astuces professionnelles

> [!tip] Organisation des projets Créez une structure claire pour gérer plusieurs applications :
> 
> ```
> /var/www/
> ├── html/
> │   ├── app1/
> │   ├── app2/
> │   └── app3/
> ├── backups/
> │   ├── app1/
> │   ├── app2/
> │   └── app3/
> └── logs/
>     ├── app1/
>     ├── app2/
>     └── app3/
> ```

> [!tip] Script d'installation automatisé Une fois maîtrisé, créez un script bash pour automatiser :
> 
> ```bash
> #!/bin/bash
> # install_webapp.sh
> APP_NAME=$1
> APP_URL=$2
> 
> echo "Installation de $APP_NAME..."
> cd /tmp
> wget $APP_URL
> tar -xzf *.tar.gz
> sudo mv ${APP_NAME}* /var/www/html/$APP_NAME
> sudo chown -R www-data:www-data /var/www/html/$APP_NAME
> # ... suite du script
> ```

> [!tip] Documentation de configuration Conservez un fichier README.md dans chaque application :
> 
> ```markdown
> # Application: MonApp
> - Date installation: 2024-12-22
> - Version: 2.5.1
> - Base de données: monapp_db
> - Utilisateur BDD: monapp_user
> - DocumentRoot: /var/www/html/monapp
> - Virtual Host: monapp.exemple.com
> - Notes spéciales: [ajoutez vos notes]
> ```

### 🔍 Commandes de diagnostic rapide

```bash
# Vérifier qu'Apache fonctionne
sudo systemctl status apache2

# Vérifier qu'MySQL fonctionne
sudo systemctl status mysql

# Tester la syntaxe Apache
sudo apache2ctl configtest

# Voir les dernières erreurs
sudo tail -20 /var/log/apache2/error.log

# Tester la connexion PHP-MySQL
php -r "new mysqli('localhost', 'user', 'pass', 'db') or die('Erreur');"

# Vérifier les modules Apache actifs
apache2ctl -M | grep rewrite

# Voir les sites activés
ls -la /etc/apache2/sites-enabled/

# Vérifier l'espace disque
df -h /var/www/html

# Voir les processus Apache
ps aux | grep apache2 | wc -l
```

---

**📌 Note finale :** L'installation manuelle d'applications web est une compétence fondamentale en administration système. Elle vous donne une compréhension approfondie de l'architecture des applications web et vous prépare à résoudre efficacement les problèmes en production. Prenez le temps de bien maîtriser chaque étape avant de passer à des méthodes d'installation automatisées.