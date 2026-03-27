

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

## 🚫 Erreurs 403 Forbidden

### Qu'est-ce qu'une erreur 403 ?

L'erreur **403 Forbidden** indique qu'Apache a reçu la requête mais refuse d'y répondre pour des raisons de permissions. Le serveur comprend la demande mais l'accès est explicitement interdit.

> [!info] Différence avec 401
> 
> - **401 Unauthorized** : Authentification requise mais absente ou invalide
> - **403 Forbidden** : Authentification possible mais accès refusé (permissions insuffisantes)

### Causes principales

#### 1. Permissions de fichiers incorrectes

Les permissions Unix doivent permettre à Apache (utilisateur `www-data` sur Debian/Ubuntu) de lire les fichiers.

```bash
# Vérifier les permissions actuelles
ls -la /var/www/html/

# Structure de permissions recommandée
# Répertoires : 755 (rwxr-xr-x)
# Fichiers : 644 (rw-r--r--)

# Corriger les permissions des répertoires
sudo find /var/www/html/ -type d -exec chmod 755 {} \;

# Corriger les permissions des fichiers
sudo find /var/www/html/ -type f -exec chmod 644 {} \;

# Définir le propriétaire correct
sudo chown -R www-data:www-data /var/www/html/
```

> [!warning] Attention aux permissions trop restrictives Si un répertoire parent a des permissions 700, Apache ne pourra pas y accéder même si le fichier cible a 644.

#### 2. Configuration de Directory dans Apache

Apache utilise des directives `<Directory>` pour contrôler l'accès aux répertoires.

```bash
# Vérifier la configuration du VirtualHost
sudo nano /etc/apache2/sites-available/monsite.conf
```

Configuration problématique :

```apache
<Directory /var/www/html/>
    # Interdit tout accès
    Require all denied
</Directory>
```

Configuration correcte :

```apache
<Directory /var/www/html/>
    Options Indexes FollowSymLinks
    AllowOverride All
    # Autorise tous les accès
    Require all granted
</Directory>
```

> [!example] Options courantes
> 
> - `Indexes` : Affiche la liste des fichiers si pas d'index
> - `FollowSymLinks` : Permet de suivre les liens symboliques
> - `AllowOverride All` : Permet l'utilisation de fichiers .htaccess

#### 3. Problème avec .htaccess

Un fichier `.htaccess` mal configuré peut bloquer l'accès.

```bash
# Vérifier si .htaccess existe
ls -la /var/www/html/.htaccess

# Temporairement renommer pour tester
sudo mv /var/www/html/.htaccess /var/www/html/.htaccess.bak

# Recharger Apache
sudo systemctl reload apache2
```

Exemple de `.htaccess` problématique :

```apache
# Bloque tout
Order deny,allow
Deny from all
```

Exemple de `.htaccess` correct pour restreindre par IP :

```apache
# Autorise seulement certaines IPs
Require ip 192.168.1.0/24
Require ip 10.0.0.5
```

#### 4. SELinux (sur CentOS/RHEL)

SELinux peut bloquer l'accès d'Apache aux fichiers.

```bash
# Vérifier le statut de SELinux
getenforce

# Vérifier le contexte SELinux des fichiers
ls -Z /var/www/html/

# Corriger le contexte SELinux
sudo chcon -R -t httpd_sys_content_t /var/www/html/

# Ou utiliser restorecon
sudo restorecon -Rv /var/www/html/

# Autoriser Apache à se connecter au réseau (si nécessaire)
sudo setsebool -P httpd_can_network_connect 1
```

### Diagnostic systématique

```bash
# 1. Vérifier les permissions
namei -l /var/www/html/index.php

# 2. Vérifier la configuration Apache
sudo apache2ctl -t

# 3. Tester avec un fichier simple
echo "Test" | sudo tee /var/www/html/test.txt
sudo chmod 644 /var/www/html/test.txt

# 4. Consulter les logs
sudo tail -f /var/log/apache2/error.log
```

> [!tip] Astuce de dépannage Créez un fichier `info.php` avec `<?php phpinfo(); ?>` et essayez d'y accéder. Si ça fonctionne, le problème vient de votre application, pas d'Apache.

---

## ⚠️ Erreurs 500 Internal Server Error

### Qu'est-ce qu'une erreur 500 ?

L'erreur **500 Internal Server Error** est une erreur générique indiquant qu'Apache a rencontré un problème inattendu lors du traitement de la requête. C'est l'erreur la plus frustrante car elle ne donne pas de détails visibles à l'utilisateur.

> [!warning] Toujours consulter les logs L'erreur 500 n'affiche volontairement pas les détails pour des raisons de sécurité. Les vraies informations se trouvent dans les logs.

### Causes principales

#### 1. Erreurs dans le fichier .htaccess

Le fichier `.htaccess` est interprété à chaque requête. Une erreur de syntaxe provoque immédiatement une erreur 500.

```bash
# Tester en désactivant .htaccess
sudo mv /var/www/html/.htaccess /var/www/html/.htaccess.disabled

# Si l'erreur disparaît, le problème vient du .htaccess
```

Erreurs courantes dans `.htaccess` :

```apache
# INCORRECT : Directive mal écrite
RedirectWrong /old /new

# CORRECT : Syntaxe valide
Redirect 301 /old /new

# INCORRECT : Module non activé (mod_rewrite)
RewriteEngine On
RewriteRule ^old$ /new [R=301,L]

# Pour activer mod_rewrite
sudo a2enmod rewrite
sudo systemctl restart apache2
```

> [!example] .htaccess courant pour URL rewriting
> 
> ```apache
> <IfModule mod_rewrite.c>
>     RewriteEngine On
>     RewriteBase /
>     
>     # Rediriger tout vers index.php
>     RewriteCond %{REQUEST_FILENAME} !-f
>     RewriteCond %{REQUEST_FILENAME} !-d
>     RewriteRule ^(.*)$ index.php?url=$1 [QSA,L]
> </IfModule>
> ```

#### 2. Erreurs PHP fatales

Les erreurs PHP qui empêchent l'exécution du script génèrent une erreur 500.

```bash
# Activer l'affichage des erreurs PHP (développement uniquement)
sudo nano /etc/php/8.1/apache2/php.ini

# Modifier ces lignes
display_errors = On
error_reporting = E_ALL

# Redémarrer Apache
sudo systemctl restart apache2
```

Types d'erreurs PHP causant des 500 :

```php
// Parse Error : Syntaxe invalide
<?php
echo "Test"  // Manque le point-virgule
?>

// Fatal Error : Fonction inexistante
<?php
appel_fonction_qui_nexiste_pas();
?>

// Fatal Error : Mémoire insuffisante
<?php
// Script consommant trop de mémoire
$huge_array = array_fill(0, 10000000, 'data');
?>

// Fatal Error : Classe non trouvée
<?php
$obj = new ClasseInexistante();
?>
```

> [!tip] Augmenter la mémoire PHP
> 
> ```bash
> sudo nano /etc/php/8.1/apache2/php.ini
> # Modifier
> memory_limit = 256M
> ```

#### 3. Dépassement de limites PHP

```bash
# Paramètres à vérifier dans php.ini
sudo nano /etc/php/8.1/apache2/php.ini
```

```ini
# Temps maximum d'exécution (secondes)
max_execution_time = 30

# Temps maximum pour analyser les données POST
max_input_time = 60

# Taille maximale des données POST
post_max_size = 8M

# Taille maximale d'un fichier uploadé
upload_max_filesize = 2M

# Mémoire allouée à un script
memory_limit = 128M
```

> [!warning] Valeurs cohérentes `post_max_size` doit être supérieur à `upload_max_filesize` car POST contient le fichier plus d'autres données.

#### 4. Permissions d'écriture

PHP peut avoir besoin d'écrire dans certains répertoires (cache, sessions, uploads).

```bash
# Créer et configurer les répertoires nécessaires
sudo mkdir -p /var/www/html/cache /var/www/html/uploads

# Donner les permissions d'écriture à Apache
sudo chown -R www-data:www-data /var/www/html/cache /var/www/html/uploads
sudo chmod -R 775 /var/www/html/cache /var/www/html/uploads
```

#### 5. Modules Apache manquants ou mal configurés

```bash
# Vérifier les modules chargés
apache2ctl -M

# Modules courants nécessaires
sudo a2enmod rewrite    # URL rewriting
sudo a2enmod headers    # Manipulation des en-têtes HTTP
sudo a2enmod ssl        # Support HTTPS
sudo a2enmod proxy      # Proxy inverse
sudo a2enmod proxy_fcgi # PHP-FPM

# Redémarrer après activation
sudo systemctl restart apache2
```

### Diagnostic systématique

```bash
# 1. Vérifier la syntaxe Apache
sudo apache2ctl configtest

# 2. Vérifier les logs en temps réel
sudo tail -f /var/log/apache2/error.log

# 3. Activer le mode verbeux temporairement
sudo nano /etc/apache2/sites-available/monsite.conf
# Ajouter : LogLevel warn rewrite:trace3

# 4. Tester un fichier PHP minimal
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/test.php

# 5. Vérifier les permissions récursivement
sudo find /var/www/html -type f ! -perm 644 -ls
sudo find /var/www/html -type d ! -perm 755 -ls
```

> [!tip] Isoler le problème Créez un sous-répertoire avec une configuration minimale pour tester chaque élément séparément.

---

## 🔌 Erreurs de connexion à la base de données

### Types d'erreurs de connexion

Les erreurs de connexion à MySQL/MariaDB se manifestent de différentes manières selon le langage et le contexte.

> [!info] Pourquoi ces erreurs sont critiques Sans base de données, la plupart des applications web modernes (WordPress, Drupal, etc.) ne peuvent pas fonctionner du tout.

### Erreurs courantes

#### 1. "Access denied for user"

**Message complet :**

```
Access denied for user 'username'@'localhost' (using password: YES)
```

**Causes :**

- Mot de passe incorrect
- Utilisateur inexistant
- Permissions insuffisantes

**Solutions :**

```bash
# Se connecter à MySQL en root
sudo mysql -u root -p

# Vérifier que l'utilisateur existe
SELECT User, Host FROM mysql.user WHERE User = 'nom_utilisateur';

# Recréer l'utilisateur avec le bon mot de passe
DROP USER IF EXISTS 'nom_utilisateur'@'localhost';
CREATE USER 'nom_utilisateur'@'localhost' IDENTIFIED BY 'mot_de_passe_fort';

# Donner les permissions sur la base
GRANT ALL PRIVILEGES ON nom_base.* TO 'nom_utilisateur'@'localhost';
FLUSH PRIVILEGES;

# Vérifier les permissions
SHOW GRANTS FOR 'nom_utilisateur'@'localhost';
```

> [!warning] Host dans les permissions Un utilisateur `'user'@'localhost'` est différent de `'user'@'%'`. Le premier ne peut se connecter que localement, le second depuis n'importe où.

#### 2. "Can't connect to MySQL server"

**Message complet :**

```
Can't connect to MySQL server on 'localhost' (111)
```

**Causes :**

- Service MySQL arrêté
- Socket MySQL introuvable
- Firewall bloquant la connexion

**Solutions :**

```bash
# Vérifier le statut du service
sudo systemctl status mysql

# Démarrer si arrêté
sudo systemctl start mysql

# Vérifier que MySQL écoute
sudo netstat -tlnp | grep mysql
# Ou avec ss
sudo ss -tlnp | grep mysql

# Résultat attendu : mysql écoute sur 3306 ou socket
# tcp  0  0 127.0.0.1:3306  0.0.0.0:*  LISTEN  1234/mysqld

# Vérifier le socket
ls -l /var/run/mysqld/mysqld.sock

# Si le socket n'existe pas, redémarrer MySQL
sudo systemctl restart mysql
```

#### 3. "Unknown database"

**Message :**

```
Unknown database 'nom_de_la_base'
```

**Causes :**

- Base de données non créée
- Nom mal orthographié (sensible à la casse)

**Solutions :**

```bash
# Se connecter à MySQL
sudo mysql -u root -p

# Lister les bases existantes
SHOW DATABASES;

# Créer la base si elle n'existe pas
CREATE DATABASE nom_base CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Vérifier la création
SHOW DATABASES LIKE 'nom_base';
```

> [!tip] Encodage recommandé Utilisez toujours `utf8mb4` et `utf8mb4_unicode_ci` pour un support complet d'Unicode, y compris les emojis.

#### 4. "Too many connections"

**Message :**

```
Too many connections
```

**Causes :**

- Limite de connexions simultanées atteinte
- Application qui ne ferme pas les connexions
- Pic de trafic

**Solutions :**

```bash
# Se connecter à MySQL (si possible)
sudo mysql -u root -p

# Vérifier les connexions actuelles
SHOW PROCESSLIST;

# Voir la limite actuelle
SHOW VARIABLES LIKE 'max_connections';

# Augmenter temporairement (perdu au redémarrage)
SET GLOBAL max_connections = 200;

# Modification permanente
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

# Ajouter ou modifier
[mysqld]
max_connections = 200

# Redémarrer MySQL
sudo systemctl restart mysql
```

> [!warning] Pool de connexions Augmenter `max_connections` n'est pas toujours la solution. Il faut aussi optimiser l'application pour utiliser un pool de connexions et fermer les connexions inutilisées.

### Configuration de connexion PHP

Fichier de configuration typique (`config.php`) :

```php
<?php
// Configuration de la base de données
define('DB_HOST', 'localhost');      // ou 127.0.0.1
define('DB_NAME', 'nom_base');
define('DB_USER', 'nom_utilisateur');
define('DB_PASS', 'mot_de_passe');
define('DB_CHARSET', 'utf8mb4');

// Connexion avec PDO (recommandé)
try {
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];
    $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
} catch (PDOException $e) {
    // En production, ne pas afficher les détails
    error_log("Erreur de connexion : " . $e->getMessage());
    die("Erreur de connexion à la base de données");
}

// Connexion avec MySQLi (alternative)
$mysqli = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
if ($mysqli->connect_error) {
    error_log("Erreur MySQLi : " . $mysqli->connect_error);
    die("Erreur de connexion à la base de données");
}
$mysqli->set_charset(DB_CHARSET);
?>
```

> [!example] Test de connexion standalone
> 
> ```bash
> # Créer un fichier de test
> sudo nano /var/www/html/test_db.php
> ```
> 
> ```php
> <?php
> $host = 'localhost';
> $db = 'nom_base';
> $user = 'nom_utilisateur';
> $pass = 'mot_de_passe';
> 
> try {
>     $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
>     echo "Connexion réussie !";
> } catch (PDOException $e) {
>     echo "Erreur : " . $e->getMessage();
> }
> ?>
> ```

### Diagnostic systématique

|Étape|Commande|Ce qu'on vérifie|
|---|---|---|
|1. Service|`sudo systemctl status mysql`|MySQL est démarré|
|2. Écoute|`sudo ss -tlnp \| grep mysql`|MySQL écoute sur le port|
|3. Connexion CLI|`mysql -u user -p`|Identifiants valides|
|4. Base existe|`SHOW DATABASES;`|La base est créée|
|5. Permissions|`SHOW GRANTS FOR 'user'@'localhost';`|Droits suffisants|

```bash
# Script de diagnostic complet
#!/bin/bash

echo "=== Diagnostic MySQL ==="

echo "1. Statut du service :"
systemctl is-active mysql

echo -e "\n2. MySQL écoute-t-il ?"
ss -tlnp | grep mysql

echo -e "\n3. Test de connexion locale :"
mysql -u root -p -e "SELECT 'Connexion OK' AS Status;"

echo -e "\n4. Lister les bases :"
mysql -u root -p -e "SHOW DATABASES;"

echo -e "\n5. Connexions actives :"
mysql -u root -p -e "SHOW PROCESSLIST;"
```

> [!tip] Fichier .my.cnf pour automatiser Créez `/home/votre_user/.my.cnf` pour éviter de taper le mot de passe :
> 
> ```ini
> [client]
> user=root
> password=votre_mot_de_passe
> ```
> 
> **Attention :** Protégez ce fichier avec `chmod 600 ~/.my.cnf`

---

## 📋 Consultation des logs Apache et PHP

### Pourquoi les logs sont essentiels

Les logs sont votre meilleure source d'information pour diagnostiquer les problèmes. Ils enregistrent tout ce qui se passe dans Apache et PHP avec différents niveaux de détail.

> [!info] Philosophie des logs Les logs ne mentent jamais. Si vous avez un problème, la réponse est presque toujours dans les logs.

### Logs Apache

#### Emplacement des logs

|Distribution|Access Log|Error Log|
|---|---|---|
|Ubuntu/Debian|`/var/log/apache2/access.log`|`/var/log/apache2/error.log`|
|CentOS/RHEL|`/var/log/httpd/access_log`|`/var/log/httpd/error_log`|

```bash
# Vérifier l'emplacement configuré
sudo apache2ctl -S | grep ErrorLog
sudo apache2ctl -S | grep CustomLog
```

#### Access Log

Le **access log** enregistre toutes les requêtes HTTP reçues par le serveur.

**Format typique (Combined Log Format) :**

```
192.168.1.100 - - [22/Dec/2025:10:30:45 +0100] "GET /index.php HTTP/1.1" 200 5432 "https://google.com" "Mozilla/5.0..."
```

**Décomposition :**

1. `192.168.1.100` : IP du client
2. `-` : Identité du client (rarement utilisé)
3. `-` : Utilisateur authentifié
4. `[22/Dec/2025:10:30:45 +0100]` : Date et heure
5. `"GET /index.php HTTP/1.1"` : Requête HTTP
6. `200` : Code de statut HTTP
7. `5432` : Taille de la réponse en octets
8. `"https://google.com"` : Referer (page précédente)
9. `"Mozilla/5.0..."` : User-Agent (navigateur)

**Commandes utiles :**

```bash
# Consulter les dernières lignes
sudo tail -f /var/log/apache2/access.log

# Voir les 50 dernières requêtes
sudo tail -n 50 /var/log/apache2/access.log

# Filtrer par code d'erreur (404, 500, etc.)
sudo grep " 404 " /var/log/apache2/access.log

# Compter les requêtes par code de statut
sudo awk '{print $9}' /var/log/apache2/access.log | sort | uniq -c | sort -rn

# Top 10 des IPs qui font le plus de requêtes
sudo awk '{print $1}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -10

# Top 10 des pages les plus demandées
sudo awk '{print $7}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -10
```

> [!tip] Analyser avec GoAccess
> 
> ```bash
> sudo apt install goaccess
> sudo goaccess /var/log/apache2/access.log --log-format=COMBINED
> ```
> 
> Outil interactif en temps réel pour analyser les logs visuellement.

#### Error Log

Le **error log** enregistre les erreurs et avertissements d'Apache et des applications.

**Format typique :**

```
[Mon Dec 22 10:30:45.123456 2025] [php:error] [pid 12345] [client 192.168.1.100:54321] PHP Fatal error: Call to undefined function...
```

**Niveaux de log Apache :**

|Niveau|Description|Utilisation|
|---|---|---|
|`emerg`|Système inutilisable|Crash critique|
|`alert`|Action immédiate requise|Problème grave|
|`crit`|Conditions critiques|Erreur matérielle|
|`error`|Erreurs|Erreurs applicatives|
|`warn`|Avertissements|Configurations douteuses|
|`notice`|Normal mais significatif|Événements importants|
|`info`|Informations|Démarrage, arrêt|
|`debug`|Messages de débogage|Développement|

**Configuration du niveau de log :**

```bash
sudo nano /etc/apache2/apache2.conf
```

```apache
# Par défaut : warn (n'affiche que warn et au-dessus)
LogLevel warn

# Pour plus de détails (développement)
LogLevel info

# Pour déboguer mod_rewrite spécifiquement
LogLevel warn rewrite:trace3

# Pour déboguer SSL
LogLevel warn ssl:trace4
```

**Commandes utiles :**

```bash
# Suivre les erreurs en temps réel
sudo tail -f /var/log/apache2/error.log

# Filtrer par niveau d'erreur
sudo grep "\[error\]" /var/log/apache2/error.log

# Filtrer par type (PHP, mod_rewrite, etc.)
sudo grep "\[php:" /var/log/apache2/error.log

# Erreurs des 5 dernières minutes
sudo find /var/log/apache2/ -mmin -5 -exec grep "error" {} \;

# Compter les erreurs PHP par type
sudo grep "PHP" /var/log/apache2/error.log | awk -F: '{print $NF}' | sort | uniq -c | sort -rn
```

> [!warning] Rotation des logs Les logs peuvent devenir très volumineux. Apache utilise `logrotate` pour les archiver automatiquement.
> 
> ```bash
> # Configuration de logrotate pour Apache
> cat /etc/logrotate.d/apache2
> ```

### Logs PHP

PHP enregistre ses propres logs séparément des logs Apache.

#### Emplacement du log PHP

```bash
# Trouver l'emplacement configuré
php -i | grep error_log

# Emplacements courants
# Ubuntu/Debian : /var/log/php8.1-fpm.log (si PHP-FPM)
# Log dans Apache : intégré dans error.log d'Apache
```

#### Configuration des logs PHP

```bash
sudo nano /etc/php/8.1/apache2/php.ini
```

```ini
; Activer le logging des erreurs
log_errors = On

; Fichier de log (si vide, va dans le log Apache)
error_log = /var/log/php_errors.log

; Types d'erreurs à logger
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

; Affichage des erreurs (Off en production !)
display_errors = Off
display_startup_errors = Off

; Logger les erreurs répétées
ignore_repeated_errors = Off
```

> [!warning] Sécurité en production **Toujours** mettre `display_errors = Off` en production pour éviter de révéler des informations sensibles aux utilisateurs.

#### Types d'erreurs PHP

|Type|Constante|Description|Gravité|
|---|---|---|---|
|Parse Error|`E_PARSE`|Erreur de syntaxe|Fatale|
|Fatal Error|`E_ERROR`|Erreur fatale|Fatale|
|Warning|`E_WARNING`|Avertissement d'exécution|Non fatale|
|Notice|`E_NOTICE`|Notice d'exécution|Non fatale|
|Deprecated|`E_DEPRECATED`|Fonctionnalité obsolète|Non fatale|

**Commandes utiles :**

```bash
# Suivre le log PHP
sudo tail -f /var/log/php_errors.log

# Rechercher les erreurs fatales
sudo grep "Fatal error" /var/log/apache2/error.log

# Rechercher les warnings PHP
sudo grep "Warning" /var/log/apache2/error.log

# Statistiques sur les types d'erreurs
sudo grep "PHP" /var/log/apache2/error.log | sed 's/.*PHP \(.*\):.*/\1/' | sort | uniq -c | sort -rn
```

#### Logging personnalisé dans le code PHP

```php
<?php
// Logger dans le fichier error_log d'Apache/PHP
error_log("Message de debug personnalisé");

// Logger avec contexte
error_log("Erreur lors de la connexion utilisateur : " . $username);

// Logger des variables
error_log("Valeur de \$data : " . print_r($data, true));

// Logger vers un fichier spécifique
error_log("Message important", 3, "/var/log/mon_app.log");

// En développement, afficher et logger
ini_set('display_errors', 1);
ini_set('log_errors', 1);
error_reporting(E_ALL);
?>
```

> [!tip] Fonction de debug personnalisée
> 
> ```php
> function debug_log($message, $data = null) {
>     $log = date('Y-m-d H:i:s') . " - " . $message;
>     if ($data !== null) {
>         $log .= " - Data: " . print_r($data, true);
>     }
>     error_log($log);
> }
> 
> // Utilisation
> debug_log("Utilisateur connecté", ['user_id' => 123, 'ip' => $_SERVER['REMOTE_ADDR']]);
> ```

### Configuration avancée des logs

#### Logs par VirtualHost

Chaque site peut avoir ses propres logs :

```apache
<VirtualHost *:80>
    ServerName monsite.com
    DocumentRoot /var/www/monsite
    
    # Logs spécifiques à ce site
    ErrorLog ${APACHE_LOG_DIR}/monsite_error.log
    CustomLog ${APACHE_LOG_DIR}/monsite_access.log combined
    
    # Niveau de log personnalisé
    LogLevel warn
</VirtualHost>
```

#### Format de log personnalisé

```apache
# Définir un format personnalisé
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D" custom

# %h : IP client
# %l : identité
# %u : utilisateur authentifié
# %t : timestamp
# %r : requête
# %s : statut
# %b : taille
# %D : temps de réponse en microsecondes

# Utiliser ce format
CustomLog ${APACHE_LOG_DIR}/access.log custom
```

> [!example] Surveiller les temps de réponse
> 
> ```bash
> # Afficher les requêtes les plus lentes
> sudo awk '{print $NF/1000000 " secondes - " $7}' /var/log/apache2/access.log | sort -rn | head -20
> ```

### Outils de surveillance

#### Surveiller en temps réel avec multitail

```bash
# Installer multitail
sudo apt install multitail

# Surveiller plusieurs logs simultanément
sudo multitail /var/log/apache2/error.log /var/log/apache2/access.log

# Avec coloration syntaxique
sudo multitail -cS apache /var/log/apache2/error.log -cS apache_access /var/log/apache2/access.log
```

#### Analyser avec lnav (Log File Navigator)

```bash
# Installer lnav
sudo apt install lnav

# Ouvrir tous les logs Apache
sudo lnav /var/log/apache2/*.log

# Navigation interactive avec recherche et filtrage
```

> [!tip] Raccourcis lnav
> 
> - `/` : Rechercher
> - `n` / `N` : Résultat suivant/précédent
> - `f` : Filtrer
> - `q` : Quitter

#### Monitoring avec systemd journal

```bash
# Voir les logs du service Apache
sudo journalctl -u apache2

# Suivre en temps réel
sudo journalctl -u apache2 -f

# Logs depuis le dernier démarrage
sudo journalctl -u apache2 -b

# Logs des 2 dernières heures
sudo journalctl -u apache2 --since "2 hours ago"

# Logs avec priorité error et plus grave
sudo journalctl -u apache2 -p err
```

### Script de diagnostic automatique

Créer un script pour diagnostiquer rapidement les problèmes :

```bash
#!/bin/bash
# diagnostic_lamp.sh - Script de diagnostic LAMP

echo "=========================================="
echo "   DIAGNOSTIC SERVEUR LAMP"
echo "=========================================="

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction de test
test_service() {
    if systemctl is-active --quiet $1; then
        echo -e "${GREEN}✓${NC} $1 est actif"
        return 0
    else
        echo -e "${RED}✗${NC} $1 est inactif"
        return 1
    fi
}

echo -e "\n=== SERVICES ==="
test_service apache2
test_service mysql

echo -e "\n=== CONFIGURATION APACHE ==="
if sudo apache2ctl configtest 2>&1 | grep -q "Syntax OK"; then
    echo -e "${GREEN}✓${NC} Configuration Apache valide"
else
    echo -e "${RED}✗${NC} Erreur de configuration Apache"
    sudo apache2ctl configtest
fi

echo -e "\n=== PORTS EN ÉCOUTE ==="
if sudo ss -tlnp | grep -q ":80"; then
    echo -e "${GREEN}✓${NC} Apache écoute sur le port 80"
else
    echo -e "${RED}✗${NC} Apache n'écoute pas sur le port 80"
fi

if sudo ss -tlnp | grep -q ":3306"; then
    echo -e "${GREEN}✓${NC} MySQL écoute sur le port 3306"
else
    echo -e "${RED}✗${NC} MySQL n'écoute pas sur le port 3306"
fi

echo -e "\n=== MODULES APACHE ==="
for module in rewrite ssl headers; do
    if apache2ctl -M 2>/dev/null | grep -q "${module}_module"; then
        echo -e "${GREEN}✓${NC} Module $module activé"
    else
        echo -e "${YELLOW}!${NC} Module $module non activé"
    fi
done

echo -e "\n=== PHP ==="
php_version=$(php -v | head -n 1)
echo "Version : $php_version"

echo -e "\n=== ESPACE DISQUE ==="
df -h / | tail -1 | awk '{
    if ($5+0 > 90) 
        printf "\033[0;31m✗\033[0m Disque plein à %s\n", $5
    else if ($5+0 > 70) 
        printf "\033[1;33m!\033[0m Disque à %s\n", $5
    else 
        printf "\033[0;32m✓\033[0m Disque à %s\n", $5
}'

echo -e "\n=== DERNIÈRES ERREURS APACHE ==="
echo "5 dernières erreurs :"
sudo tail -5 /var/log/apache2/error.log 2>/dev/null || echo "Aucun log trouvé"

echo -e "\n=== DERNIÈRES ERREURS PHP ==="
sudo grep "PHP" /var/log/apache2/error.log | tail -5 2>/dev/null || echo "Aucune erreur PHP récente"

echo -e "\n=== CONNEXIONS MYSQL ==="
mysql_connections=$(sudo mysql -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null | tail -1 | awk '{print $2}')
if [ ! -z "$mysql_connections" ]; then
    echo "Connexions actives : $mysql_connections"
else
    echo -e "${RED}✗${NC} Impossible de se connecter à MySQL"
fi

echo -e "\n=========================================="
echo "   FIN DU DIAGNOSTIC"
echo "=========================================="
```

**Utilisation :**

```bash
# Rendre le script exécutable
chmod +x diagnostic_lamp.sh

# Exécuter
sudo ./diagnostic_lamp.sh
```

### Bonnes pratiques de gestion des logs

#### 1. Rotation automatique

Vérifier la configuration logrotate :

```bash
# Configuration par défaut d'Apache
cat /etc/logrotate.d/apache2
```

Configuration typique :

```
/var/log/apache2/*.log {
    daily                    # Rotation quotidienne
    missingok               # Pas d'erreur si log manquant
    rotate 14               # Garder 14 jours d'archives
    compress                # Compresser les archives
    delaycompress          # Compresser après la 2e rotation
    notifempty             # Ne pas tourner si vide
    create 640 root adm    # Permissions des nouveaux fichiers
    sharedscripts          # Exécuter les scripts une fois
    postrotate
        if /etc/init.d/apache2 status > /dev/null ; then \
            /etc/init.d/apache2 reload > /dev/null; \
        fi;
    endscript
}
```

#### 2. Surveillance proactive

```bash
# Créer un script de surveillance
sudo nano /usr/local/bin/check_apache_errors.sh
```

```bash
#!/bin/bash
# Alerter si trop d'erreurs

ERROR_THRESHOLD=50
LOG_FILE="/var/log/apache2/error.log"
ALERT_EMAIL="admin@example.com"

# Compter les erreurs des 5 dernières minutes
ERROR_COUNT=$(find $LOG_FILE -mmin -5 -exec grep -c "error" {} \; 2>/dev/null)

if [ "$ERROR_COUNT" -gt "$ERROR_THRESHOLD" ]; then
    echo "ALERTE : $ERROR_COUNT erreurs détectées dans les 5 dernières minutes" | \
    mail -s "Alerte Apache - Trop d'erreurs" $ALERT_EMAIL
fi
```

```bash
# Ajouter au crontab (toutes les 5 minutes)
sudo crontab -e
*/5 * * * * /usr/local/bin/check_apache_errors.sh
```

#### 3. Centralisation des logs

Pour gérer plusieurs serveurs :

```bash
# Installer rsyslog (généralement déjà installé)
sudo apt install rsyslog

# Configurer l'envoi vers un serveur centralisé
sudo nano /etc/rsyslog.d/apache.conf
```

```
# Envoyer les logs Apache vers serveur distant
$ModLoad imfile
$InputFileName /var/log/apache2/error.log
$InputFileTag apache-error:
$InputFileStateFile stat-apache-error
$InputFileSeverity error
$InputFileFacility local3
$InputRunFileMonitor

# Destination : serveur syslog distant
local3.* @@log-server.example.com:514
```

> [!info] Alternatives modernes
> 
> - **ELK Stack** (Elasticsearch, Logstash, Kibana) : Solution complète d'analyse
> - **Graylog** : Plateforme de gestion de logs open source
> - **Loki** : Solution de logs de Grafana

### Patterns d'erreurs et résolutions

|Pattern dans les logs|Cause probable|Action|
|---|---|---|
|`Permission denied`|Permissions fichiers|Vérifier `chmod/chown`|
|`No such file or directory`|Chemin incorrect|Vérifier DocumentRoot et chemins|
|`Cannot allocate memory`|Mémoire insuffisante|Augmenter RAM ou optimiser|
|`Timeout`|Script trop long|Augmenter `max_execution_time`|
|`Connection refused`|Service arrêté|Redémarrer le service|
|`Too many open files`|Limite de descripteurs|Augmenter `ulimit`|
|`Segmentation fault`|Bug module/PHP|Identifier et désactiver le module|
|`SSL handshake failed`|Certificat invalide|Vérifier certificat SSL|

### Checklist de dépannage complète

Quand un problème survient, suivez cette checklist :

```
□ 1. REPRODUIRE LE PROBLÈME
   - Tester avec plusieurs navigateurs
   - Tester en navigation privée
   - Noter le message d'erreur exact

□ 2. CONSULTER LES LOGS
   - Error log Apache
   - Access log Apache
   - Log PHP
   - Log système (journalctl)

□ 3. VÉRIFIER LES SERVICES
   - Apache est actif : systemctl status apache2
   - MySQL est actif : systemctl status mysql
   - PHP-FPM est actif (si utilisé)

□ 4. TESTER LA CONFIGURATION
   - Syntaxe Apache : apache2ctl configtest
   - Syntaxe PHP : php -l fichier.php

□ 5. VÉRIFIER LES PERMISSIONS
   - Propriétaire : www-data
   - Fichiers : 644
   - Répertoires : 755

□ 6. TESTER LA CONNECTIVITÉ
   - Port 80/443 ouvert : ss -tlnp | grep apache
   - Firewall : sudo ufw status
   - Connexion MySQL : mysql -u user -p

□ 7. ISOLER LE PROBLÈME
   - Désactiver .htaccess
   - Tester avec fichier minimal
   - Désactiver modules un par un

□ 8. RECHERCHER EN LIGNE
   - Message d'erreur exact
   - Vérifier sur StackOverflow
   - Documentation officielle
```

> [!tip] Principe de résolution Procédez toujours par élimination : testez une hypothèse à la fois, et ne changez qu'une chose à la fois. Documentez ce que vous testez.

### Ressources utiles pour le dépannage

```bash
# Commandes de diagnostic rapide à retenir
sudo apache2ctl configtest           # Test config Apache
sudo apache2ctl -M                   # Liste des modules
sudo apache2ctl -S                   # VirtualHosts configurés
php -i                               # Infos PHP (comme phpinfo())
mysql -u root -p -e "SHOW VARIABLES" # Variables MySQL
netstat -tlnp | grep -E ':(80|443|3306)' # Ports ouverts

# Logs essentiels
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/apache2/access.log
sudo journalctl -u apache2 -f
sudo journalctl -u mysql -f
```

---

## 🎯 Récapitulatif

### Points clés à retenir

1. **Erreurs 403** : Toujours vérifier dans cet ordre → Permissions fichiers → Configuration Directory → .htaccess → SELinux
    
2. **Erreurs 500** : Le problème est dans les logs → Tester .htaccess → Vérifier erreurs PHP → Contrôler les modules Apache
    
3. **Base de données** : Suivre la checklist → Service MySQL actif → Utilisateur/mot de passe valides → Base existe → Permissions accordées
    
4. **Logs** : Votre meilleure ressource → Access log pour les requêtes → Error log pour les problèmes → Logs PHP pour les erreurs applicatives
    
5. **Méthodologie** : Procéder systématiquement → Reproduire le problème → Consulter les logs → Isoler la cause → Tester la solution → Documenter
    

> [!warning] Erreurs courantes des débutants
> 
> - Ne pas consulter les logs avant de chercher
> - Changer plusieurs choses à la fois
> - Oublier de recharger Apache après modifications
> - Laisser `display_errors = On` en production
> - Ne pas vérifier la syntaxe avant de redémarrer

### Méthode universelle de dépannage

```
1. OBSERVER : Quel est le symptôme exact ?
2. REPRODUIRE : Le problème est-il constant ?
3. LOGS : Que disent les fichiers de log ?
4. ISOLER : Quel composant est responsable ?
5. HYPOTHÈSE : Quelle pourrait être la cause ?
6. TESTER : La solution fonctionne-t-elle ?
7. DOCUMENTER : Noter la résolution pour plus tard
```

> [!tip] Dernier conseil Gardez un journal de bord de vos pannes et solutions. La plupart des problèmes se répètent, et avoir une base de connaissances personnelle vous fera gagner un temps précieux.