

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

## 🎯 Préparation du déploiement

Le déploiement d'une application web nécessite une préparation méthodique pour garantir la sécurité, les performances et la maintenabilité de votre application. Cette phase consiste à préparer l'environnement serveur pour accueillir votre application de manière isolée et sécurisée.

### Pourquoi préparer le déploiement ?

- **Isolation** : Chaque application doit avoir son propre espace (Virtual Host, base de données, utilisateurs)
- **Sécurité** : Limiter les permissions et les accès minimise les risques
- **Maintenabilité** : Une structure claire facilite les mises à jour et le débogage
- **Scalabilité** : Permet d'héberger plusieurs applications sur le même serveur

### Checklist de préparation

Avant de commencer le déploiement, vérifiez les éléments suivants :

> [!info] Liste de vérification
> 
> - [ ] Serveur LAMP fonctionnel (Apache, MySQL, PHP)
> - [ ] Accès root ou sudo au serveur
> - [ ] Nom de domaine configuré (ou sous-domaine)
> - [ ] Fichiers de l'application prêts à être transférés
> - [ ] Connaître les besoins de l'application (version PHP, extensions, etc.)

### Structure recommandée

```
/var/www/
├── html/                    # Site par défaut Apache
├── monsite.com/            # Votre application
│   ├── public/             # Racine web publique (DocumentRoot)
│   │   ├── index.php
│   │   ├── css/
│   │   ├── js/
│   │   └── images/
│   ├── config/             # Fichiers de configuration
│   ├── logs/               # Logs applicatifs
│   └── backups/            # Sauvegardes
└── autresite.com/          # Autre application
```

> [!tip] Bonne pratique Ne mettez jamais tous vos fichiers directement dans le DocumentRoot. Créez une structure avec un dossier `public/` qui sera le seul accessible depuis le web. Les autres dossiers (config, logs, etc.) restent inaccessibles, ce qui améliore la sécurité.

### Plan de déploiement typique

1. **Créer le Virtual Host** : Définir comment Apache servira votre application
2. **Configurer la base de données** : Créer la BDD et l'utilisateur dédié
3. **Transférer les fichiers** : Uploader votre application via SCP, FTP ou Git
4. **Configurer les permissions** : Sécuriser l'accès aux fichiers
5. **Configurer l'application** : Éditer les fichiers de configuration (connexion BDD, etc.)
6. **Activer le site** : Activer le Virtual Host et recharger Apache
7. **Tester** : Vérifier le bon fonctionnement

> [!warning] Attention Faites toujours une sauvegarde de votre configuration Apache actuelle avant d'ajouter un nouveau Virtual Host :
> 
> ```bash
> sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.backup
> ```

---

## 🌐 Création d'un Virtual Host dédié

Un Virtual Host (ou VirtualHost) est une configuration Apache qui permet d'héberger plusieurs sites web sur un même serveur. Chaque Virtual Host définit comment Apache doit répondre aux requêtes pour un nom de domaine spécifique.

### Qu'est-ce qu'un Virtual Host ?

Apache peut écouter sur le même port (80 pour HTTP, 443 pour HTTPS) et servir différents contenus selon le nom de domaine demandé. C'est ce qu'on appelle le **name-based virtual hosting**.

**Exemple :** Sur le même serveur avec la même IP :

- `monsite.com` → `/var/www/monsite.com/public/`
- `blog.monsite.com` → `/var/www/blog/public/`
- `api.monsite.com` → `/var/www/api/public/`

### Création du répertoire de l'application

```bash
# Créer la structure de dossiers
sudo mkdir -p /var/www/monsite.com/public
sudo mkdir -p /var/www/monsite.com/logs
sudo mkdir -p /var/www/monsite.com/config

# Créer un fichier index de test
echo "<?php phpinfo(); ?>" | sudo tee /var/www/monsite.com/public/index.php
```

### Configuration du Virtual Host

```bash
# Créer le fichier de configuration
sudo nano /etc/apache2/sites-available/monsite.com.conf
```

**Configuration basique :**

```apache
<VirtualHost *:80>
    # Identité du site
    ServerName monsite.com
    ServerAlias www.monsite.com
    ServerAdmin contact@monsite.com

    # Chemins
    DocumentRoot /var/www/monsite.com/public
    
    # Logs dédiés
    ErrorLog /var/www/monsite.com/logs/error.log
    CustomLog /var/www/monsite.com/logs/access.log combined

    # Configuration du répertoire
    <Directory /var/www/monsite.com/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

> [!example] Explication ligne par ligne
> 
> - `<VirtualHost *:80>` : Écoute sur toutes les interfaces IP sur le port 80
> - `ServerName` : Nom de domaine principal
> - `ServerAlias` : Alias (www, sous-domaines)
> - `ServerAdmin` : Email affiché dans certaines pages d'erreur
> - `DocumentRoot` : Racine des fichiers web accessibles
> - `ErrorLog` / `CustomLog` : Fichiers de logs dédiés à ce site
> - `<Directory>` : Configuration spécifique au répertoire
>     - `Options -Indexes` : Désactive le listing des fichiers
>     - `+FollowSymLinks` : Autorise les liens symboliques
>     - `AllowOverride All` : Permet l'utilisation de .htaccess
>     - `Require all granted` : Autorise l'accès à tous

**Configuration avancée avec PHP et sécurité :**

```apache
<VirtualHost *:80>
    ServerName monsite.com
    ServerAlias www.monsite.com
    ServerAdmin contact@monsite.com
    
    DocumentRoot /var/www/monsite.com/public
    
    # Logs avec rotation
    ErrorLog /var/www/monsite.com/logs/error.log
    CustomLog /var/www/monsite.com/logs/access.log combined
    
    # Configuration PHP
    <FilesMatch \.php$>
        SetHandler application/x-httpd-php
    </FilesMatch>
    
    # Répertoire public
    <Directory /var/www/monsite.com/public>
        Options -Indexes +FollowSymLinks -ExecCGI
        AllowOverride All
        Require all granted
        
        # Interdire l'accès aux fichiers sensibles
        <FilesMatch "^\.">
            Require all denied
        </FilesMatch>
    </Directory>
    
    # Bloquer l'accès aux dossiers sensibles
    <DirectoryMatch "/var/www/monsite.com/(config|logs|backups)">
        Require all denied
    </DirectoryMatch>
    
    # Gestion des erreurs personnalisées
    ErrorDocument 404 /404.html
    ErrorDocument 500 /500.html
    
    # Compression Gzip (si mod_deflate activé)
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript
    </IfModule>
    
    # Headers de sécurité (si mod_headers activé)
    <IfModule mod_headers.c>
        Header set X-Content-Type-Options "nosniff"
        Header set X-Frame-Options "SAMEORIGIN"
        Header set X-XSS-Protection "1; mode=block"
    </IfModule>
</VirtualHost>
```

### Activation et test du Virtual Host

```bash
# Vérifier la syntaxe de la configuration
sudo apache2ctl configtest

# Si OK, activer le site
sudo a2ensite monsite.com.conf

# Recharger Apache pour appliquer les changements
sudo systemctl reload apache2

# Vérifier le statut
sudo systemctl status apache2
```

> [!tip] Astuce : tester sans DNS Si votre domaine n'est pas encore configuré, vous pouvez tester en modifiant le fichier `/etc/hosts` :
> 
> ```bash
> sudo nano /etc/hosts
> # Ajouter : 127.0.0.1    monsite.com
> ```

### Virtual Host pour HTTPS (avec SSL)

```apache
<VirtualHost *:443>
    ServerName monsite.com
    ServerAlias www.monsite.com
    ServerAdmin contact@monsite.com
    
    DocumentRoot /var/www/monsite.com/public
    
    # Activation SSL
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/monsite.com.crt
    SSLCertificateKeyFile /etc/ssl/private/monsite.com.key
    SSLCertificateChainFile /etc/ssl/certs/chain.crt
    
    # Logs
    ErrorLog /var/www/monsite.com/logs/error_ssl.log
    CustomLog /var/www/monsite.com/logs/access_ssl.log combined
    
    <Directory /var/www/monsite.com/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>

# Redirection automatique HTTP vers HTTPS
<VirtualHost *:80>
    ServerName monsite.com
    ServerAlias www.monsite.com
    Redirect permanent / https://monsite.com/
</VirtualHost>
```

### Commandes de gestion des Virtual Hosts

|Commande|Description|
|---|---|
|`sudo a2ensite monsite.com.conf`|Activer un Virtual Host|
|`sudo a2dissite monsite.com.conf`|Désactiver un Virtual Host|
|`sudo apache2ctl -S`|Lister tous les Virtual Hosts configurés|
|`sudo apachectl -t`|Tester la syntaxe de la configuration|
|`sudo systemctl reload apache2`|Recharger Apache sans couper les connexions|
|`sudo systemctl restart apache2`|Redémarrer Apache complètement|

> [!warning] Pièges courants
> 
> - **DocumentRoot incorrect** : Vérifiez que le chemin existe et est accessible
> - **Permissions insuffisantes** : Apache doit pouvoir lire les fichiers (voir section Permissions)
> - **ServerName manquant** : Apache ne saura pas quel VirtualHost utiliser
> - **AllowOverride None** : Les .htaccess seront ignorés (peut causer des erreurs 500)
> - **Oublier de recharger Apache** : Les modifications ne seront pas appliquées

### Déboguer un Virtual Host

```bash
# Vérifier la configuration
sudo apache2ctl -S

# Voir les logs d'erreur en temps réel
sudo tail -f /var/www/monsite.com/logs/error.log

# Vérifier les permissions
ls -la /var/www/monsite.com/public/

# Tester la résolution DNS
nslookup monsite.com

# Tester la connectivité
curl -I http://monsite.com
```

---

## 🗄️ Création de la base de données et utilisateur

La plupart des applications web nécessitent une base de données pour stocker les données. Pour des raisons de sécurité, chaque application doit avoir sa propre base de données avec un utilisateur dédié possédant uniquement les permissions nécessaires.

### Pourquoi un utilisateur dédié ?

> [!info] Principe du moindre privilège Chaque application doit avoir son propre utilisateur MySQL avec accès uniquement à sa base de données. Cela limite les dégâts en cas de compromission de l'application.

**Mauvaise pratique :** Utiliser le compte `root` dans l'application **Bonne pratique :** Créer un utilisateur avec accès limité à une seule base de données

### Connexion à MySQL

```bash
# Connexion en tant que root
sudo mysql -u root -p

# Ou si configuré sans mot de passe root
sudo mysql
```

### Création de la base de données

```sql
-- Créer une base de données avec encodage UTF-8
CREATE DATABASE monsite_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Vérifier la création
SHOW DATABASES;
```

> [!example] Explications
> 
> - `CHARACTER SET utf8mb4` : Support complet des caractères Unicode (y compris les emojis)
> - `COLLATE utf8mb4_unicode_ci` : Règles de tri et comparaison insensibles à la casse (ci = case insensitive)

### Création de l'utilisateur et attribution des permissions

```sql
-- Créer un utilisateur avec accès local uniquement
CREATE USER 'monsite_user'@'localhost' IDENTIFIED BY 'MotDePasseSecurise123!';

-- Accorder tous les privilèges sur la base de données spécifique
GRANT ALL PRIVILEGES ON monsite_db.* TO 'monsite_user'@'localhost';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Vérifier les permissions
SHOW GRANTS FOR 'monsite_user'@'localhost';
```

> [!tip] Génération de mot de passe sécurisé
> 
> ```bash
> # Générer un mot de passe aléatoire fort
> openssl rand -base64 32
> ```

### Permissions granulaires (approche sécurisée)

Pour certaines applications en production, vous pouvez limiter davantage les permissions :

```sql
-- Créer l'utilisateur
CREATE USER 'monsite_user'@'localhost' IDENTIFIED BY 'MotDePasseSecurise123!';

-- Permissions limitées (lecture et écriture, mais pas de modification de structure)
GRANT SELECT, INSERT, UPDATE, DELETE ON monsite_db.* TO 'monsite_user'@'localhost';

-- Appliquer
FLUSH PRIVILEGES;
```

|Permission|Description|Cas d'usage|
|---|---|---|
|`ALL PRIVILEGES`|Tous les droits sur la base|Développement, admin complet|
|`SELECT`|Lecture des données|Application en lecture seule|
|`INSERT`|Ajout de données|Application qui crée du contenu|
|`UPDATE`|Modification de données|Application avec édition|
|`DELETE`|Suppression de données|Application avec suppression|
|`CREATE`|Création de tables|Migration de schéma|
|`DROP`|Suppression de tables|Réinstallation, migration|
|`ALTER`|Modification de structure|Mise à jour de schéma|

### Utilisateur avec accès distant (si nécessaire)

> [!warning] Sécurité N'autorisez l'accès distant que si absolument nécessaire et uniquement depuis des IPs de confiance.

```sql
-- Utilisateur accessible depuis une IP spécifique
CREATE USER 'monsite_user'@'192.168.1.100' IDENTIFIED BY 'MotDePasseSecurise123!';
GRANT ALL PRIVILEGES ON monsite_db.* TO 'monsite_user'@'192.168.1.100';

-- Utilisateur accessible depuis n'importe où (DANGEREUX)
CREATE USER 'monsite_user'@'%' IDENTIFIED BY 'MotDePasseSecurise123!';
GRANT ALL PRIVILEGES ON monsite_db.* TO 'monsite_user'@'%';

FLUSH PRIVILEGES;
```

Vous devrez également modifier la configuration MySQL :

```bash
# Éditer la configuration MySQL
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

# Chercher et modifier :
# bind-address = 127.0.0.1
# Remplacer par :
bind-address = 0.0.0.0

# Redémarrer MySQL
sudo systemctl restart mysql
```

### Test de connexion

```bash
# Tester la connexion avec le nouvel utilisateur
mysql -u monsite_user -p monsite_db

# Une fois connecté, tester l'accès
SHOW TABLES;
SELECT DATABASE();
```

### Import d'un fichier SQL

```bash
# Importer un dump SQL
mysql -u monsite_user -p monsite_db < /chemin/vers/dump.sql

# Ou depuis MySQL
mysql -u monsite_user -p monsite_db
SOURCE /chemin/vers/dump.sql;
```

### Commandes de gestion courantes

```sql
-- Lister tous les utilisateurs
SELECT User, Host FROM mysql.user;

-- Voir les permissions d'un utilisateur
SHOW GRANTS FOR 'monsite_user'@'localhost';

-- Modifier le mot de passe d'un utilisateur
ALTER USER 'monsite_user'@'localhost' IDENTIFIED BY 'NouveauMotDePasse456!';

-- Révoquer des permissions
REVOKE DELETE ON monsite_db.* FROM 'monsite_user'@'localhost';

-- Supprimer un utilisateur
DROP USER 'monsite_user'@'localhost';

-- Supprimer une base de données (ATTENTION !)
DROP DATABASE monsite_db;
```

### Configuration de l'application

Une fois la base créée, configurez votre application pour s'y connecter :

**Exemple pour PHP (fichier config.php) :**

```php
<?php
// Configuration de la base de données
define('DB_HOST', 'localhost');
define('DB_NAME', 'monsite_db');
define('DB_USER', 'monsite_user');
define('DB_PASS', 'MotDePasseSecurise123!');
define('DB_CHARSET', 'utf8mb4');

// Connexion PDO
try {
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET,
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
} catch(PDOException $e) {
    die("Erreur de connexion : " . $e->getMessage());
}
?>
```

> [!warning] Sécurité du fichier de configuration Le fichier contenant les identifiants de base de données ne doit JAMAIS être accessible depuis le web :
> 
> - Placez-le en dehors du DocumentRoot, ou
> - Protégez-le avec un `.htaccess`, ou
> - Bloquez-le dans la configuration du Virtual Host
> 
> ```apache
> <Files "config.php">
>     Require all denied
> </Files>
> ```

### Bonnes pratiques

> [!tip] Recommandations
> 
> - **Nom de BDD et utilisateur** : Utilisez un préfixe ou suffixe cohérent (`app_db`, `app_user`)
> - **Mot de passe fort** : Minimum 16 caractères, mélange de majuscules, minuscules, chiffres et symboles
> - **Backups réguliers** : Automatisez les sauvegardes avec `mysqldump`
> - **Environnement séparé** : Base de développement ≠ base de production
> - **Variables d'environnement** : Stockez les credentials dans des variables d'env plutôt qu'en dur dans le code

### Sauvegarde de la base de données

```bash
# Sauvegarde complète
mysqldump -u monsite_user -p monsite_db > /var/www/monsite.com/backups/monsite_db_$(date +%Y%m%d).sql

# Sauvegarde avec compression
mysqldump -u monsite_user -p monsite_db | gzip > /var/www/monsite.com/backups/monsite_db_$(date +%Y%m%d).sql.gz

# Restauration
mysql -u monsite_user -p monsite_db < /var/www/monsite.com/backups/monsite_db_20241222.sql

# Restauration depuis un fichier compressé
gunzip < /var/www/monsite.com/backups/monsite_db_20241222.sql.gz | mysql -u monsite_user -p monsite_db
```

---

## 🔐 Permissions sur les répertoires web

Les permissions Linux sont cruciales pour la sécurité et le bon fonctionnement de votre application web. Un mauvais paramétrage peut soit bloquer le fonctionnement, soit créer des failles de sécurité majeures.

### Comprendre les permissions Linux

Chaque fichier et dossier possède :

- **Un propriétaire** (user)
- **Un groupe** (group)
- **Des permissions** pour le propriétaire, le groupe et les autres

```bash
# Visualiser les permissions
ls -la /var/www/monsite.com/

# Exemple de sortie :
# drwxr-xr-x  5 www-data www-data 4096 Dec 22 10:30 public
# -rw-r--r--  1 www-data www-data 2048 Dec 22 10:25 index.php
```

**Décodage :** `drwxr-xr-x`

- `d` : type (d=directory, -=file, l=link)
- `rwx` : permissions du propriétaire (read, write, execute)
- `r-x` : permissions du groupe (read, execute)
- `r-x` : permissions des autres (read, execute)

|Notation|Octale|Signification|
|---|---|---|
|`---`|0|Aucune permission|
|`r--`|4|Lecture seule|
|`r-x`|5|Lecture + exécution|
|`rw-`|6|Lecture + écriture|
|`rwx`|7|Lecture + écriture + exécution|

### Le rôle de www-data

`www-data` est l'utilisateur sous lequel Apache s'exécute par défaut sur Debian/Ubuntu. Votre application PHP tourne avec les permissions de cet utilisateur.

> [!info] Principe de base
> 
> - Apache (www-data) doit pouvoir **lire** tous les fichiers de l'application
> - Apache doit pouvoir **écrire** uniquement dans les dossiers où l'application crée/modifie des fichiers (uploads, cache, logs, sessions)
> - Vous (votre utilisateur) devez pouvoir modifier les fichiers pour les mises à jour

### Configuration des permissions recommandée

```bash
# Définir www-data comme propriétaire
sudo chown -R www-data:www-data /var/www/monsite.com

# Permissions des dossiers : 755 (rwxr-xr-x)
# Le propriétaire peut tout faire, les autres peuvent lire et exécuter
sudo find /var/www/monsite.com -type d -exec chmod 755 {} \;

# Permissions des fichiers : 644 (rw-r--r--)
# Le propriétaire peut lire/écrire, les autres peuvent lire
sudo find /var/www/monsite.com -type f -exec chmod 644 {} \;
```

> [!example] Pourquoi ces permissions ?
> 
> - **755 pour les dossiers** : Permet à Apache de lister et accéder aux fichiers
> - **644 pour les fichiers** : Apache peut lire, mais seul le propriétaire peut modifier
> - Cette configuration empêche l'exécution de fichiers uploadés par des utilisateurs malveillants

### Dossiers nécessitant des permissions d'écriture

Certains dossiers doivent être modifiables par Apache :

```bash
# Dossier d'uploads (où les utilisateurs uploadent des fichiers)
sudo chmod 775 /var/www/monsite.com/public/uploads
sudo chmod 664 /var/www/monsite.com/public/uploads/*

# Dossier de cache (où l'application stocke les fichiers temporaires)
sudo chmod 775 /var/www/monsite.com/cache

# Dossier de logs applicatifs
sudo chmod 775 /var/www/monsite.com/logs

# Dossier de sessions PHP (si personnalisé)
sudo chmod 770 /var/www/monsite.com/sessions
```

> [!warning] Sécurité des uploads Ne donnez JAMAIS 777 à un dossier accessible depuis le web ! Un attaquant pourrait uploader et exécuter un script malveillant.

### Permettre à votre utilisateur de modifier les fichiers

Si vous êtes l'administrateur et devez pouvoir modifier les fichiers, ajoutez-vous au groupe www-data :

```bash
# Ajouter votre utilisateur au groupe www-data
sudo usermod -a -G www-data $USER

# Vous devez vous déconnecter/reconnecter pour que ça prenne effet
# Ou exécuter :
newgrp www-data

# Vérifier l'appartenance aux groupes
groups
```

Puis configurez les permissions pour que le groupe puisse écrire :

```bash
# Propriétaire : www-data, Groupe : www-data
sudo chown -R www-data:www-data /var/www/monsite.com

# Dossiers : 775 (rwxrwxr-x) - propriétaire ET groupe peuvent écrire
sudo find /var/www/monsite.com -type d -exec chmod 775 {} \;

# Fichiers : 664 (rw-rw-r--) - propriétaire ET groupe peuvent écrire
sudo find /var/www/monsite.com -type f -exec chmod 664 {} \;
```

### Protection des fichiers sensibles

```bash
# Fichier de configuration (lecture seule pour le groupe/autres)
sudo chmod 640 /var/www/monsite.com/config/database.php
sudo chown www-data:www-data /var/www/monsite.com/config/database.php

# Logs (écriture pour www-data, lecture pour vous)
sudo chmod 660 /var/www/monsite.com/logs/*.log

# Scripts d'administration (exécution uniquement par le propriétaire)
sudo chmod 700 /var/www/monsite.com/scripts/admin.sh
```

### Interdire l'exécution dans les dossiers d'upload

Pour empêcher l'exécution de scripts uploadés, configurez Apache :

**Dans le Virtual Host ou .htaccess du dossier uploads :**

```apache
<Directory /var/www/monsite.com/public/uploads>
    # Interdire l'exécution de scripts
    php_flag engine off
    
    # Interdire l'accès aux fichiers .php
    <FilesMatch "\.php$">
        Require all denied
    </FilesMatch>
    
    # Types MIME autorisés uniquement
    <FilesMatch "\.(jpg|jpeg|png|gif|pdf|doc|docx)$">
        Require all granted
    </FilesMatch>
</Directory>
```

Ou en .htaccess dans `/var/www/monsite.com/public/uploads/.htaccess` :

```apache
# Désactiver PHP
php_flag engine off

# Bloquer l'accès aux .php
<FilesMatch "\.php$">
    Require all denied
</FilesMatch>
```

### Permissions SELinux (si activé)

Sur les systèmes avec SELinux (CentOS, RHEL, Fedora), vous devez aussi configurer le contexte de sécurité :

```bash
# Vérifier si SELinux est actif
getenforce

# Configurer le contexte pour Apache
sudo semanage fcontext -a -t httpd_sys_content_t "/var/www/monsite.com(/.*)?"
sudo restorecon -R /var/www/monsite.com

# Pour les dossiers d'écriture
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/monsite.com/uploads(/.*)?"
sudo restorecon -R /var/www/monsite.com/uploads
```

### Commandes utiles

```bash
# Voir les permissions détaillées
ls -la /var/www/monsite.com/

# Voir le propriétaire et groupe
stat /var/www/monsite.com/public/index.php

# Changer le propriétaire
sudo chown utilisateur:groupe fichier

# Changer les permissions
sudo chmod 755 dossier
sudo chmod 644 fichier

# Appliquer récursivement
sudo chown -R www-data:www-data /var/www/monsite.com
sudo chmod -R 755 /var/www/monsite.com

# Modifier uniquement les dossiers
find /var/www/monsite.com -type d -exec chmod 755 {} \;

# Modifier uniquement les fichiers
find /var/www/monsite.com -type f -exec chmod 644 {} \;
```

### Tableau récapitulatif des permissions

|Élément|Propriétaire|Groupe|Permissions|Commande|
|---|---|---|---|---|
|Dossiers web|www-data|www-data|755|`chmod 755 dossier/`|
|Fichiers web|www-data|www-data|644|`chmod 644 fichier.php`|
|Uploads/cache|www-data|www-data|775 (dossier)|`chmod 775 uploads/`|
|Config sensible|www-data|www-data|640|`chmod 640 config.php`|
|Logs|www-data|www-data|660|`chmod 660 app.log`|
|Scripts admin|root|root|700|`chmod 700 script.sh`|

### Scénarios de permissions courants

#### Scénario 1 : Application en lecture seule

L'application ne modifie jamais de fichiers sur le serveur (pas d'uploads, cache en mémoire) :

```bash
sudo chown -R www-data:www-data /var/www/monsite.com
sudo find /var/www/monsite.com -type d -exec chmod 755 {} \;
sudo find /var/www/monsite.com -type f -exec chmod 644 {} \;
```

#### Scénario 2 : Application avec uploads et cache

L'application permet les uploads et utilise un cache fichier :

```bash
# Permissions générales
sudo chown -R www-data:www-data /var/www/monsite.com
sudo find /var/www/monsite.com -type d -exec chmod 755 {} \;
sudo find /var/www/monsite.com -type f -exec chmod 644 {} \;

# Permissions d'écriture pour dossiers spécifiques
sudo chmod 775 /var/www/monsite.com/public/uploads
sudo chmod 775 /var/www/monsite.com/cache
sudo chmod 775 /var/www/monsite.com/logs
```

#### Scénario 3 : Développement avec accès utilisateur

Vous devez pouvoir modifier les fichiers facilement pendant le développement :

```bash
# Vous ajouter au groupe www-data
sudo usermod -a -G www-data $USER
newgrp www-data

# Permissions de groupe en écriture
sudo chown -R www-data:www-data /var/www/monsite.com
sudo find /var/www/monsite.com -type d -exec chmod 775 {} \;
sudo find /var/www/monsite.com -type f -exec chmod 664 {} \;

# Dossiers nécessitant l'écriture par Apache
sudo chmod 775 /var/www/monsite.com/public/uploads
sudo chmod 775 /var/www/monsite.com/cache
```

#### Scénario 4 : Déploiement via Git

Vous déployez l'application avec Git et devez gérer les permissions :

```bash
# Après un git pull, réappliquer les permissions
cd /var/www/monsite.com

# Fichiers appartiennent à www-data
sudo chown -R www-data:www-data .

# Votre utilisateur peut modifier
sudo usermod -a -G www-data $USER

# Permissions standards
sudo find . -type d -exec chmod 775 {} \;
sudo find . -type f -exec chmod 664 {} \;

# Dossiers d'écriture
sudo chmod 775 public/uploads cache logs
```

> [!tip] Automatisation avec script Créez un script de déploiement pour automatiser ces tâches :
> 
> ```bash
> #!/bin/bash
> # deploy-permissions.sh
> 
> SITE_PATH="/var/www/monsite.com"
> WEB_USER="www-data"
> WEB_GROUP="www-data"
> 
> echo "Application des permissions..."
> 
> # Propriétaire
> sudo chown -R $WEB_USER:$WEB_GROUP $SITE_PATH
> 
> # Permissions de base
> sudo find $SITE_PATH -type d -exec chmod 755 {} \;
> sudo find $SITE_PATH -type f -exec chmod 644 {} \;
> 
> # Dossiers d'écriture
> sudo chmod 775 $SITE_PATH/public/uploads
> sudo chmod 775 $SITE_PATH/cache
> sudo chmod 775 $SITE_PATH/logs
> 
> # Fichiers sensibles
> sudo chmod 640 $SITE_PATH/config/*.php
> 
> echo "Permissions appliquées avec succès !"
> ```

### Pièges courants et solutions

> [!warning] Erreur : 403 Forbidden

**Symptômes :** Apache refuse l'accès aux fichiers

**Causes possibles :**

1. Permissions trop restrictives sur les dossiers
2. Propriétaire incorrect
3. Configuration Apache (Require all denied)

**Solutions :**

```bash
# Vérifier les permissions
ls -la /var/www/monsite.com/public/

# Corriger le propriétaire
sudo chown -R www-data:www-data /var/www/monsite.com

# Corriger les permissions des dossiers
sudo find /var/www/monsite.com -type d -exec chmod 755 {} \;

# Vérifier la configuration Apache
sudo apache2ctl -t
```

> [!warning] Erreur : Unable to write to file

**Symptômes :** L'application ne peut pas écrire dans un dossier

**Causes possibles :**

1. Permissions d'écriture manquantes pour www-data
2. Dossier n'existe pas
3. SELinux bloque l'écriture

**Solutions :**

```bash
# Créer le dossier si nécessaire
sudo mkdir -p /var/www/monsite.com/cache

# Permissions d'écriture
sudo chown www-data:www-data /var/www/monsite.com/cache
sudo chmod 775 /var/www/monsite.com/cache

# Vérifier SELinux (si applicable)
getenforce
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/monsite.com/cache(/.*)?"
sudo restorecon -R /var/www/monsite.com/cache
```

> [!warning] Erreur : Permission denied lors du déploiement

**Symptômes :** Impossible de modifier les fichiers en SSH/FTP

**Causes possibles :**

1. Votre utilisateur n'est pas dans le groupe www-data
2. Permissions du groupe insuffisantes

**Solutions :**

```bash
# Ajouter votre utilisateur au groupe
sudo usermod -a -G www-data $USER

# Vous déconnecter/reconnecter ou :
newgrp www-data

# Permissions de groupe en écriture
sudo find /var/www/monsite.com -type d -exec chmod 775 {} \;
sudo find /var/www/monsite.com -type f -exec chmod 664 {} \;
```

### Vérification et audit des permissions

```bash
# Vérifier les permissions d'un site complet
sudo find /var/www/monsite.com -type f ! -perm 644 -ls
sudo find /var/www/monsite.com -type d ! -perm 755 -ls

# Trouver les fichiers appartenant à un utilisateur spécifique
sudo find /var/www/monsite.com ! -user www-data -ls

# Trouver les fichiers avec permissions 777 (dangereux)
sudo find /var/www/monsite.com -type f -perm 777 -ls
sudo find /var/www/monsite.com -type d -perm 777 -ls

# Audit de sécurité complet
sudo find /var/www/monsite.com \( -perm -002 -o -perm -020 \) -ls
```

### Bonnes pratiques de sécurité

> [!tip] Recommandations essentielles
> 
> 1. **Jamais 777** : N'utilisez jamais chmod 777, même "temporairement"
> 2. **Principe du moindre privilège** : Donnez uniquement les permissions nécessaires
> 3. **Séparer lecture/écriture** : Seuls les dossiers qui en ont besoin doivent être modifiables
> 4. **Protéger les fichiers sensibles** : Config, credentials doivent être 640 ou moins
> 5. **Désactiver l'exécution** : Pas de PHP dans les dossiers d'uploads
> 6. **Audits réguliers** : Vérifiez périodiquement les permissions
> 7. **Documenter les exceptions** : Si vous devez donner des permissions spéciales, documentez pourquoi
> 8. **Automatiser** : Utilisez des scripts de déploiement pour garantir la cohérence

### Commande de réinitialisation rapide

Si vous devez repartir de zéro avec des permissions saines :

```bash
#!/bin/bash
# reset-permissions.sh - Réinitialise les permissions à des valeurs sûres

SITE_PATH="/var/www/monsite.com"

echo "⚠️  Réinitialisation des permissions pour $SITE_PATH"

# Propriétaire
sudo chown -R www-data:www-data $SITE_PATH

# Permissions de base
echo "📁 Application des permissions de base..."
sudo find $SITE_PATH -type d -exec chmod 755 {} \;
sudo find $SITE_PATH -type f -exec chmod 644 {} \;

# Dossiers d'écriture
echo "✍️  Configuration des dossiers d'écriture..."
for dir in uploads cache logs sessions tmp; do
    if [ -d "$SITE_PATH/$dir" ]; then
        sudo chmod 775 $SITE_PATH/$dir
        echo "   ✓ $dir"
    fi
done

# Protection des fichiers sensibles
echo "🔒 Protection des fichiers sensibles..."
if [ -d "$SITE_PATH/config" ]; then
    sudo find $SITE_PATH/config -type f -name "*.php" -exec chmod 640 {} \;
    echo "   ✓ config/"
fi

echo "✅ Permissions réinitialisées avec succès !"
```

---

## 🎓 Synthèse du déploiement

### Checklist complète de déploiement

> [!example] Liste de vérification finale
> 
> **Préparation**
> 
> - [ ] Serveur LAMP fonctionnel
> - [ ] Nom de domaine configuré
> - [ ] Fichiers de l'application prêts
> 
> **Virtual Host**
> 
> - [ ] Dossiers créés (`/var/www/monsite.com/public`, `/logs`, `/config`)
> - [ ] Configuration Virtual Host créée (`/etc/apache2/sites-available/monsite.com.conf`)
> - [ ] ServerName et ServerAlias définis
> - [ ] DocumentRoot correctement pointé
> - [ ] Logs configurés
> - [ ] Options de sécurité activées (pas d'Indexes, .htaccess autorisé)
> - [ ] Site activé (`a2ensite monsite.com.conf`)
> - [ ] Apache rechargé (`systemctl reload apache2`)
> - [ ] Test de syntaxe OK (`apache2ctl configtest`)
> 
> **Base de données**
> 
> - [ ] Base de données créée avec UTF-8
> - [ ] Utilisateur MySQL créé avec mot de passe fort
> - [ ] Permissions accordées (GRANT)
> - [ ] Privilèges appliqués (FLUSH PRIVILEGES)
> - [ ] Connexion testée
> - [ ] Fichier de configuration de l'app mis à jour
> 
> **Permissions**
> 
> - [ ] Propriétaire : www-data:www-data
> - [ ] Dossiers : 755
> - [ ] Fichiers : 644
> - [ ] Dossiers d'écriture : 775 (uploads, cache, logs)
> - [ ] Fichiers sensibles : 640 (config)
> - [ ] Exécution désactivée dans uploads
> - [ ] Permissions testées
> 
> **Tests finaux**
> 
> - [ ] Site accessible depuis le navigateur
> - [ ] Connexion base de données fonctionnelle
> - [ ] Upload de fichier fonctionne (si applicable)
> - [ ] Logs générés correctement
> - [ ] Erreurs 404/500 personnalisées (si configurées)
> - [ ] HTTPS configuré (si applicable)

### Commandes de diagnostic rapide

```bash
# Vérifier que tout fonctionne
echo "=== APACHE ==="
sudo systemctl status apache2
sudo apache2ctl -S

echo "=== VIRTUAL HOST ==="
ls -la /var/www/monsite.com/

echo "=== PERMISSIONS ==="
ls -la /var/www/monsite.com/public/

echo "=== MYSQL ==="
sudo systemctl status mysql
mysql -u monsite_user -p -e "SELECT DATABASE();" monsite_db

echo "=== LOGS ==="
sudo tail -n 20 /var/www/monsite.com/logs/error.log
sudo tail -n 20 /var/log/apache2/error.log
```

### Architecture finale

```
📦 /var/www/monsite.com/
├── 📂 public/                    (755, DocumentRoot)
│   ├── 📄 index.php             (644)
│   ├── 📂 css/                  (755)
│   ├── 📂 js/                   (755)
│   ├── 📂 images/               (755)
│   └── 📂 uploads/              (775, écriture Apache)
├── 📂 config/                    (755)
│   └── 📄 database.php          (640, sensible)
├── 📂 cache/                     (775, écriture Apache)
├── 📂 logs/                      (775, écriture Apache)
│   ├── 📄 error.log             (660)
│   └── 📄 access.log            (660)
└── 📂 backups/                   (755)

🔧 Apache Virtual Host:
   /etc/apache2/sites-available/monsite.com.conf

🗄️ MySQL:
   Base: monsite_db
   User: monsite_user@localhost
```

Ce cours couvre tous les aspects essentiels du déploiement d'une application web sur un serveur LAMP, avec un focus particulier sur la sécurité et les bonnes pratiques. Chaque section fournit des explications détaillées, des exemples pratiques, et des solutions aux problèmes courants.