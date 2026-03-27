

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

L'intégration PHP-Apache est l'étape cruciale qui permet à Apache de traiter les fichiers PHP et de générer du contenu dynamique. Cette intégration repose sur le module **mod_php** qui permet à Apache d'interpréter directement le code PHP au sein de ses processus.

> [!info] Pourquoi cette intégration est importante Sans cette intégration, Apache traiterait les fichiers `.php` comme de simples fichiers texte et les renverrait tels quels au navigateur, exposant votre code source au lieu de l'exécuter.

---

## 🔌 Module mod_php (libapache2-mod-php)

### Qu'est-ce que mod_php ?

**mod_php** (ou `libapache2-mod-php`) est un module Apache qui intègre l'interpréteur PHP directement dans les processus Apache. Cela signifie que PHP fonctionne comme une partie intégrante d'Apache plutôt que comme un programme externe.

> [!info] Architecture de mod_php Avec mod_php, chaque processus Apache embarque un interpréteur PHP complet. Cela offre des performances excellentes mais consomme plus de mémoire car chaque processus Apache (même ceux qui servent des fichiers statiques) contient l'interpréteur PHP.

**Avantages de mod_php :**

- ✅ Configuration simple et directe
- ✅ Performances excellentes pour les sites à trafic moyen
- ✅ Pas de configuration supplémentaire complexe
- ✅ Compatible avec `.htaccess` pour les configurations par répertoire

**Inconvénients :**

- ❌ Consommation mémoire élevée (PHP chargé dans chaque processus Apache)
- ❌ Moins flexible que PHP-FPM pour les configurations avancées
- ❌ Problèmes potentiels avec les sites multi-utilisateurs

### Installation du module

L'installation de mod_php se fait via le gestionnaire de paquets de votre distribution :

```bash
# Sur Debian/Ubuntu
sudo apt update
sudo apt install libapache2-mod-php

# Ou avec spécification de version (recommandé)
sudo apt install libapache2-mod-php8.2

# Sur CentOS/RHEL
sudo yum install php

# Sur Fedora
sudo dnf install php
```

> [!tip] Astuce version Il est recommandé de spécifier la version de PHP lors de l'installation (`php8.2`, `php8.1`, etc.) pour éviter les surprises lors des mises à jour du système.

**Installation avec extensions courantes :**

```bash
# Installation complète pour développement web
sudo apt install libapache2-mod-php8.2 \
  php8.2-mysql \
  php8.2-curl \
  php8.2-gd \
  php8.2-mbstring \
  php8.2-xml \
  php8.2-zip \
  php8.2-intl
```

### Vérification de l'installation

Après l'installation, vérifiez que le module est bien installé et activé :

```bash
# Lister les modules Apache activés
apache2ctl -M | grep php

# Ou
apachectl -M | grep php

# Sortie attendue :
# php_module (shared)
```

```bash
# Vérifier la version de PHP
php -v

# Sortie exemple :
# PHP 8.2.7 (cli) (built: Jun  9 2023 19:37:27) (NTS)
```

```bash
# Vérifier les fichiers de configuration chargés
php --ini

# Affiche :
# Configuration File (php.ini) Path: /etc/php/8.2/cli
# Loaded Configuration File: /etc/php/8.2/cli/php.ini
# Scan for additional .ini files in: /etc/php/8.2/cli/conf.d
```

### Activation et désactivation

Apache fournit des outils pour gérer les modules facilement :

```bash
# Activer le module PHP
sudo a2enmod php8.2

# Désactiver le module PHP
sudo a2dismod php8.2

# Redémarrer Apache pour appliquer les changements
sudo systemctl restart apache2
```

> [!warning] Attention aux conflits Si vous avez plusieurs versions de PHP installées, assurez-vous qu'une seule est active dans Apache pour éviter les conflits. Désactivez les autres versions avant d'activer celle souhaitée.

```bash
# Exemple : Basculer de PHP 7.4 à PHP 8.2
sudo a2dismod php7.4
sudo a2enmod php8.2
sudo systemctl restart apache2
```

---

## ⚙️ Configuration du handler PHP

### Comprendre le handler PHP

Un **handler** dans Apache est un mécanisme qui définit comment traiter un type de fichier particulier. Le handler PHP indique à Apache qu'il doit utiliser l'interpréteur PHP pour traiter les fichiers avec certaines extensions.

> [!info] Concept de handler Le handler crée l'association : "Quand Apache rencontre un fichier `.php`, il doit le passer à l'interpréteur PHP plutôt que de le servir tel quel."

### Configuration dans Apache

La configuration du handler PHP se fait généralement automatiquement lors de l'installation de mod_php, mais il est important de comprendre comment elle fonctionne.

**Fichier de configuration principal :**

Le module mod_php ajoute automatiquement sa configuration dans `/etc/apache2/mods-available/php8.2.conf` (le chemin peut varier selon la version) :

```bash
# Visualiser la configuration du module
cat /etc/apache2/mods-available/php8.2.conf
```

**Contenu typique du fichier :**

```apache
<FilesMatch ".+\.ph(ar|p|tml)$">
    SetHandler application/x-httpd-php
</FilesMatch>

<FilesMatch ".+\.phps$">
    SetHandler application/x-httpd-php-source
    # Deny access to raw PHP source by default
    Require all denied
</FilesMatch>

# Deny access to files without filename (e.g. '.php')
<FilesMatch "^\.ph(ar|p|ps|tml)$">
    Require all denied
</FilesMatch>

# Deny access to uploaded PHP files
<Directory /var/www/html/uploads>
    <FilesMatch "\.ph(p[3457]?|tml)$">
        Require all denied
    </FilesMatch>
</Directory>
```

> [!example] Explication ligne par ligne
> 
> - `<FilesMatch ".+\.ph(ar|p|tml)$">` : Correspond aux fichiers `.phar`, `.php`, `.phtml`
> - `SetHandler application/x-httpd-php` : Définit le handler PHP pour ces fichiers
> - `<FilesMatch ".+\.phps$">` : Fichiers `.phps` (source PHP pour affichage)
> - `SetHandler application/x-httpd-php-source` : Affiche le code source avec coloration syntaxique
> - `Require all denied` : Interdit l'accès (sécurité)

### Directives de configuration

Plusieurs directives importantes contrôlent le comportement du handler PHP :

**1. DirectoryIndex**

Définit les fichiers index par défaut quand on accède à un répertoire :

```apache
# Dans /etc/apache2/mods-available/dir.conf ou dans un VirtualHost
DirectoryIndex index.php index.html index.htm
```

> [!tip] Ordre de priorité L'ordre est important ! Apache cherchera `index.php` en premier, puis `index.html`, etc.

**2. AddHandler vs SetHandler**

```apache
# AddHandler : Ajoute un handler (peut coexister avec d'autres)
AddHandler application/x-httpd-php .php .phtml

# SetHandler : Remplace complètement le handler existant
SetHandler application/x-httpd-php
```

> [!warning] Différence critique `SetHandler` s'applique à TOUS les fichiers du contexte, pas seulement ceux avec une extension spécifique. Utilisez-le avec prudence et toujours dans un contexte `<FilesMatch>` ou `<Files>`.

**3. Configuration dans VirtualHost**

Vous pouvez personnaliser le handler PHP par VirtualHost :

```apache
<VirtualHost *:80>
    ServerName monsite.com
    DocumentRoot /var/www/monsite
    
    # Handler PHP personnalisé pour ce site
    <FilesMatch \.php$>
        SetHandler application/x-httpd-php
    </FilesMatch>
    
    # Désactiver PHP dans un sous-répertoire spécifique
    <Directory /var/www/monsite/uploads>
        <FilesMatch \.php$>
            Require all denied
        </FilesMatch>
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/monsite_error.log
    CustomLog ${APACHE_LOG_DIR}/monsite_access.log combined
</VirtualHost>
```

**4. Configuration dans .htaccess**

Si `AllowOverride` est activé, vous pouvez configurer le handler dans `.htaccess` :

```apache
# Dans /var/www/html/.htaccess

# Activer PHP pour des extensions personnalisées
AddHandler application/x-httpd-php .php .php5 .phtml

# Désactiver PHP dans un répertoire
<FilesMatch "\.php$">
    Require all denied
</FilesMatch>

# Ou empêcher l'exécution de PHP
RemoveHandler .php .phtml
```

> [!warning] Sécurité .htaccess Utiliser `.htaccess` pour la sécurité est pratique mais peut être contourné si un attaquant peut écrire des fichiers. Privilégiez la configuration au niveau du VirtualHost pour les règles de sécurité critiques.

### Gestion des extensions PHP

**Extensions reconnues par défaut :**

|Extension|Description|Usage|
|---|---|---|
|`.php`|Extension standard|Fichiers PHP classiques|
|`.phar`|PHP Archive|Archives PHP exécutables|
|`.phtml`|PHP HTML|Alternative à `.php` (convention)|
|`.phps`|PHP Source|Affichage du code source (désactivé par défaut)|

**Ajouter des extensions personnalisées :**

```apache
# Dans votre VirtualHost ou dans php8.2.conf
<FilesMatch ".+\.(php|php5|inc)$">
    SetHandler application/x-httpd-php
</FilesMatch>
```

> [!warning] Attention aux extensions dangereuses Évitez d'activer PHP pour des extensions comme `.inc` ou `.txt` qui pourraient être téléchargées comme fichiers texte par erreur, exposant votre code source.

**Configuration recommandée pour la sécurité :**

```apache
# Autoriser uniquement .php
<FilesMatch "^.+\.php$">
    SetHandler application/x-httpd-php
</FilesMatch>

# Bloquer tout ce qui ressemble à PHP dans les uploads
<Directory /var/www/html/uploads>
    <FilesMatch "\.(php|php3|php4|php5|php7|phtml|phar)$">
        Require all denied
    </FilesMatch>
</Directory>

# Bloquer les fichiers sans nom (comme .php)
<FilesMatch "^\.php">
    Require all denied
</FilesMatch>
```

---

## 🧪 Test avec phpinfo()

### Création du fichier de test

La fonction `phpinfo()` est l'outil de diagnostic principal pour vérifier que PHP fonctionne correctement avec Apache.

**Créer un fichier de test :**

```bash
# Se placer dans le DocumentRoot d'Apache
cd /var/www/html

# Créer le fichier info.php
sudo nano info.php
```

**Contenu du fichier info.php :**

```php
<?php
// Affiche toutes les informations de configuration PHP
phpinfo();
?>
```

**Version plus détaillée pour diagnostic :**

```php
<?php
// En-tête HTML personnalisé
echo "<!DOCTYPE html>";
echo "<html><head><title>Diagnostic PHP</title></head><body>";
echo "<h1>Configuration PHP</h1>";

// Version PHP
echo "<p><strong>Version PHP :</strong> " . phpversion() . "</p>";

// SAPI (Server API) - devrait afficher "apache2handler" pour mod_php
echo "<p><strong>SAPI :</strong> " . php_sapi_name() . "</p>";

// Informations sur le serveur
echo "<p><strong>Logiciel serveur :</strong> " . $_SERVER['SERVER_SOFTWARE'] . "</p>";

// Séparateur
echo "<hr>";

// Afficher toutes les informations PHP
phpinfo();

echo "</body></html>";
?>
```

**Définir les permissions appropriées :**

```bash
# Rendre le fichier lisible par Apache
sudo chown www-data:www-data /var/www/html/info.php
sudo chmod 644 /var/www/html/info.php
```

**Accéder au fichier via navigateur :**

```
http://localhost/info.php
# ou
http://votre-ip-serveur/info.php
```

> [!tip] Test depuis la ligne de commande Vous pouvez aussi tester avec curl :
> 
> ```bash
> curl http://localhost/info.php
> ```
> 
> Vous devriez voir du HTML, pas du code PHP brut.

### Interprétation des résultats

La page `phpinfo()` affiche des sections importantes :

**1. Section principale (en haut)**

|Information|Signification|Valeur attendue|
|---|---|---|
|PHP Version|Version de PHP installée|8.2.x, 8.1.x, etc.|
|System|Système d'exploitation|Linux x.x.x|
|Build Date|Date de compilation|Date récente|
|Server API|Interface serveur utilisée|**Apache 2.0 Handler** (important !)|
|Virtual Directory Support|Support répertoires virtuels|enabled ou disabled|
|Configuration File Path|Chemin php.ini|`/etc/php/8.2/apache2/php.ini`|
|Loaded Configuration File|Fichier ini chargé|Doit correspondre au path ci-dessus|

> [!info] Server API crucial La ligne **Server API** doit indiquer **"Apache 2.0 Handler"** si mod_php est actif. Si vous voyez autre chose (comme "FPM/FastCGI" ou "CGI/FastCGI"), mod_php n'est pas utilisé.

**2. Section Apache Environment**

Cette section affiche les variables d'environnement Apache :

```
DOCUMENT_ROOT: /var/www/html
SERVER_ADMIN: webmaster@localhost
SERVER_NAME: localhost
SERVER_SOFTWARE: Apache/2.4.57 (Debian)
GATEWAY_INTERFACE: CGI/1.1
REQUEST_METHOD: GET
```

> [!example] Vérifications importantes
> 
> - `DOCUMENT_ROOT` : Correspond bien à votre DocumentRoot configuré
> - `SERVER_SOFTWARE` : Affiche la version d'Apache
> - `GATEWAY_INTERFACE` : CGI/1.1 est normal

**3. Section PHP Core**

Contient les directives de configuration PHP :

|Directive|Local Value|Master Value|Description|
|---|---|---|---|
|`display_errors`|Off|Off|Affichage des erreurs|
|`error_reporting`|E_ALL|E_ALL|Niveau de rapport d'erreurs|
|`max_execution_time`|30|30|Temps max d'exécution (secondes)|
|`memory_limit`|128M|128M|Mémoire maximale|
|`upload_max_filesize`|2M|2M|Taille max upload|
|`post_max_size`|8M|8M|Taille max POST|

> [!info] Local vs Master Value
> 
> - **Master Value** : Valeur définie dans `php.ini`
> - **Local Value** : Valeur actuelle (peut être modifiée par `.htaccess` ou `ini_set()`)

**4. Sections des extensions**

Chaque extension PHP chargée a sa propre section :

- **mysqli** : Extension MySQL améliorée
- **curl** : Client HTTP
- **gd** : Manipulation d'images
- **mbstring** : Gestion multi-octets (caractères spéciaux)
- **xml** : Parsing XML
- **json** : Manipulation JSON

### Informations importantes à vérifier

**Checklist de vérification après installation :**

- [ ] **Server API** = "Apache 2.0 Handler"
- [ ] **Loaded Configuration File** pointe vers le bon `php.ini` (`/etc/php/8.2/apache2/php.ini`)
- [ ] Extensions nécessaires chargées (mysqli, curl, gd, etc.)
- [ ] `memory_limit` suffisant (128M minimum, 256M recommandé)
- [ ] `max_execution_time` approprié (30s par défaut)
- [ ] `upload_max_filesize` et `post_max_size` configurés selon besoins
- [ ] `display_errors` = Off en production (On en développement)
- [ ] `error_log` configuré

**Commandes de vérification complémentaires :**

```bash
# Vérifier les modules PHP chargés
php -m

# Vérifier une extension spécifique
php -m | grep mysqli

# Afficher la configuration PHP en ligne de commande
php -i | grep "Configuration File"

# Tester une directive PHP
php -r "echo ini_get('memory_limit');"
```

### Sécurité du fichier phpinfo()

> [!warning] CRITIQUE : Sécurité Le fichier `phpinfo()` révèle des informations sensibles sur votre serveur : versions, chemins, extensions, configuration. Il **NE DOIT JAMAIS** rester accessible en production !

**Informations exposées par phpinfo() :**

- Versions exactes de PHP, Apache, modules
- Chemins système complets
- Variables d'environnement
- Configuration de sécurité
- Extensions installées et leurs versions

**Actions de sécurité obligatoires :**

```bash
# 1. SUPPRIMER le fichier après test
sudo rm /var/www/html/info.php

# 2. Ou le déplacer hors du DocumentRoot
sudo mv /var/www/html/info.php ~/info.php.backup
```

**Si vous devez conserver un fichier de diagnostic :**

```bash
# Créer un fichier avec un nom non-devinable
sudo nano /var/www/html/diagnostic-$(date +%s).php
```

```php
<?php
// Protection par mot de passe
$password = 'votre_mot_de_passe_fort_ici';

if (!isset($_GET['pass']) || $_GET['pass'] !== $password) {
    http_response_code(403);
    die('Accès refusé');
}

phpinfo();
?>
```

**Accès sécurisé :**

```
http://localhost/diagnostic-1234567890.php?pass=votre_mot_de_passe_fort_ici
```

**Protection via .htaccess :**

```apache
# Dans /var/www/html/.htaccess
<Files "info.php">
    # Autoriser uniquement l'IP locale
    Require ip 127.0.0.1
    Require ip ::1
    
    # Ou autoriser une IP spécifique
    Require ip 192.168.1.100
</Files>
```

**Protection via VirtualHost :**

```apache
<VirtualHost *:80>
    ServerName monsite.com
    DocumentRoot /var/www/html
    
    # Bloquer info.php complètement
    <Files "info.php">
        Require all denied
    </Files>
    
    # Ou autoriser seulement certaines IPs
    <Files "info.php">
        Require ip 192.168.1.0/24
    </Files>
</VirtualHost>
```

> [!tip] Alternative sécurisée Utilisez plutôt la ligne de commande pour les diagnostics :
> 
> ```bash
> php -i  # Équivalent de phpinfo() en ligne de commande
> php -i | grep -i "module"  # Filtrer les résultats
> ```

---

## ⚠️ Pièges courants

### 1. Code PHP affiché au lieu d'être exécuté

**Symptôme :** Le navigateur affiche le code PHP brut au lieu du résultat.

```php
<?php echo "Hello World"; ?>
```

s'affiche tel quel au lieu d'afficher "Hello World".

**Causes possibles :**

```bash
# Vérifier que mod_php est activé
apache2ctl -M | grep php
# Si vide, le module n'est pas activé

# Activer le module
sudo a2enmod php8.2
sudo systemctl restart apache2
```

```bash
# Vérifier la configuration du handler
grep -r "SetHandler.*php" /etc/apache2/
# Doit retourner la configuration du handler
```

**Autre cause :** Extension de fichier incorrecte (`.ph` au lieu de `.php`)

### 2. Erreur 403 Forbidden sur fichiers PHP

**Symptôme :** Accès refusé aux fichiers `.php`

**Causes :**

```bash
# 1. Permissions fichier incorrectes
ls -l /var/www/html/index.php
# Doit être : -rw-r--r-- www-data www-data

# Corriger :
sudo chown www-data:www-data /var/www/html/index.php
sudo chmod 644 /var/www/html/index.php
```

```apache
# 2. Configuration Apache trop restrictive
# Vérifier dans votre VirtualHost ou .htaccess
<Directory /var/www/html>
    Require all granted  # Doit autoriser l'accès
</Directory>
```

### 3. Erreur 500 Internal Server Error

**Symptôme :** Erreur serveur 500 lors de l'accès à un fichier PHP

**Diagnostic :**

```bash
# Consulter les logs Apache
sudo tail -f /var/log/apache2/error.log

# Logs possibles :
# - "PHP Parse error" : Erreur de syntaxe PHP
# - "Premature end of script headers" : Script PHP crashe
# - "ModSecurity" : Règles de sécurité bloquent la requête
```

**Solutions :**

```bash
# 1. Vérifier la syntaxe PHP
php -l /var/www/html/fichier.php

# 2. Activer l'affichage des erreurs PHP (développement uniquement)
sudo nano /etc/php/8.2/apache2/php.ini
# Modifier :
display_errors = On
error_reporting = E_ALL

# Redémarrer Apache
sudo systemctl restart apache2
```

### 4. Plusieurs versions de PHP en conflit

**Symptôme :** PHP ne fonctionne pas ou version incorrecte utilisée

```bash
# Lister toutes les versions installées
dpkg -l | grep php | grep -E "^ii"

# Lister les modules PHP activés dans Apache
ls -l /etc/apache2/mods-enabled/ | grep php

# Désactiver toutes les versions sauf celle voulue
sudo a2dismod php7.4
sudo a2dismod php8.1
sudo a2enmod php8.2
sudo systemctl restart apache2
```

### 5. Configuration .htaccess ignorée

**Symptôme :** Les directives dans `.htaccess` ne fonctionnent pas

**Cause :** `AllowOverride` n'est pas activé

```apache
# Dans /etc/apache2/sites-available/000-default.conf
<Directory /var/www/html>
    Options Indexes FollowSymLinks
    AllowOverride All  # Doit être "All" et non "None"
    Require all granted
</Directory>
```

```bash
# Redémarrer Apache
sudo systemctl restart apache2
```

### 6. Téléchargement du fichier PHP au lieu de l'exécuter

**Symptôme :** Le navigateur télécharge le fichier `.php` au lieu de l'afficher

**Cause :** Handler PHP incorrect ou Content-Type forcé

```apache
# Vérifier qu'il n'y a pas de directive qui force le téléchargement
# Dans VirtualHost ou .htaccess, NE PAS avoir :
<FilesMatch "\.php$">
    ForceType application/octet-stream  # INCORRECT !
</FilesMatch>

# Doit être :
<FilesMatch "\.php$">
    SetHandler application/x-httpd-php  # CORRECT
</FilesMatch>
```

---

## ✅ Bonnes pratiques

### 1. Gestion des versions PHP

```bash
# Installer plusieurs versions si nécessaire
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.2 php8.1 php7.4

# Utiliser update-alternatives pour gérer la version CLI
sudo update-alternatives --config php

# Mais pour Apache, toujours n'activer qu'UN SEUL module
sudo a2dismod php7.4 php8.1
sudo a2enmod php8.2
```

### 2. Séparation des configurations PHP

PHP utilise des fichiers `php.ini` différents selon le contexte :

```bash
# PHP CLI (ligne de commande)
/etc/php/8.2/cli/php.ini

# PHP Apache
/etc/php/8.2/apache2/php.ini

# PHP FPM (si utilisé)
/etc/php/8.2/fpm/php.ini
```

> [!tip] Configuration différenciée Configurez différemment selon le contexte :
> 
> - **CLI** : `memory_limit = -1` (illimité), `max_execution_time = 0`
> - **Apache** : `memory_limit = 256M`, `max_execution_time = 60`

### 3. Optimisation des performances

```apache
# Dans votre VirtualHost - désactiver les fonctionnalités inutiles
<Directory /var/www/html>
    # Désactiver .htaccess si non nécessaire (gain de performance)
    AllowOverride None
    
    # Désactiver le suivi des liens symboliques
    Options -FollowSymLinks
</Directory>
```

```ini
# Dans /etc/php/8.2/apache2/php.ini
; Désactiver les fonctions dangereuses
disable_functions = exec,passthru,shell_exec,system,proc_open,popen

; Optimiser l'OPcache
opcache.enable=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.revalidate_freq=60
```

### 4. Sécurité renforcée

```apache
# Protection des répertoires sensibles
<Directory /var/www/html/includes>
    <FilesMatch "\.php$">
        Require all denied
    </FilesMatch>
</Directory>

<Directory /var/www/html/uploads>
    # Empêcher l'exécution de tout code
    php_flag engine off
    <FilesMatch "\.(php|phtml|php3|php4|php5|phps)$">
        Require all denied
    </FilesMatch>
</Directory>
```

```ini
# Dans php.ini
; Désactiver l'exposition de la version PHP
expose_php = Off

; Restreindre les fichiers accessibles
open_basedir = /var/www/html:/tmp

; Désactiver les URLs distantes
allow_url_fopen = Off
allow_url_include = Off
```

### 5. Monitoring et logs

```apache
# Configuration des logs par VirtualHost
<VirtualHost *:80>
    ServerName monsite.com
    
    # Logs PHP dédiés
    php_value error_log /var/log/apache2/monsite_php_error.log
    
    ErrorLog ${APACHE_LOG_DIR}/monsite_error.log
    CustomLog ${APACHE_LOG_DIR}/monsite_access.log combined
</VirtualHost>
```

```bash
# Surveiller les logs en temps réel
tail -f /var/log/apache2/error.log /var/log/apache2/monsite_php_error.log

# Rechercher les erreurs PHP
grep "PHP" /var/log/apache2/error.log | tail -20
```

### 6. Tests automatisés

```bash
# Script de test de la configuration PHP-Apache
#!/bin/bash

echo "=== Test de configuration PHP-Apache ==="

# 1. Vérifier mod_php
echo -n "Module mod_php activé : "
if apache2ctl -M 2>/dev/null | grep -q php; then
    echo "✓ OUI"
else
    echo "✗ NON - ERREUR"
fi

# 2. Vérifier la version PHP
echo "Version PHP : $(php -r 'echo phpversion();')"

# 3. Vérifier le fichier php.ini
echo "Fichier php.ini : $(php -r 'echo php_ini_loaded_file();')"

# 4. Tester une requête PHP
echo -n "Test requête PHP : "
if curl -s http://localhost/ | grep -q "PHP"; then
    echo "✓ Fonctionne"
else
    echo "⚠ À vérifier"
fi

# 5. Vérifier les extensions critiques
echo "Extensions PHP chargées :"
php -m | grep -E "(mysqli|curl|gd|mbstring)" | sed 's/^/  - /'

echo "=== Test terminé ==="
```

**Rendre le script exécutable et l'utiliser :**

```bash
# Sauvegarder le script
sudo nano /usr/local/bin/test-php-apache.sh

# Rendre exécutable
sudo chmod +x /usr/local/bin/test-php-apache.sh

# Exécuter
sudo /usr/local/bin/test-php-apache.sh
```

### 7. Documentation de configuration

Documentez toujours vos configurations personnalisées :

```apache
# Dans votre VirtualHost
<VirtualHost *:80>
    ServerName monsite.com
    DocumentRoot /var/www/monsite
    
    # Configuration PHP personnalisée
    # Date: 2024-01-15
    # Raison: Augmentation limite mémoire pour traitement images
    php_value memory_limit 512M
    php_value upload_max_filesize 20M
    php_value post_max_size 25M
    
    # Logs personnalisés
    ErrorLog ${APACHE_LOG_DIR}/monsite_error.log
    CustomLog ${APACHE_LOG_DIR}/monsite_access.log combined
</VirtualHost>
```

### 8. Maintenance régulière

**Checklist de maintenance :**

```bash
# 1. Vérifier les mises à jour PHP disponibles
apt list --upgradable | grep php

# 2. Mettre à jour PHP et ses extensions
sudo apt update
sudo apt upgrade php8.2*

# 3. Redémarrer Apache après mise à jour
sudo systemctl restart apache2

# 4. Vérifier les logs d'erreurs
sudo tail -50 /var/log/apache2/error.log | grep -i php

# 5. Tester les fonctionnalités critiques
curl -I http://localhost/  # Vérifier le header
```

**Automatiser avec un cron job :**

```bash
# Créer un script de surveillance
sudo nano /usr/local/bin/check-php-health.sh
```

```bash
#!/bin/bash
# Script de surveillance PHP-Apache

LOG="/var/log/php-health-check.log"

echo "=== Check $(date) ===" >> $LOG

# Vérifier que mod_php est actif
if ! apache2ctl -M 2>/dev/null | grep -q php; then
    echo "ALERTE: mod_php n'est pas actif !" >> $LOG
    systemctl restart apache2
fi

# Vérifier les erreurs PHP récentes
ERRORS=$(grep -c "PHP Fatal error" /var/log/apache2/error.log)
if [ $ERRORS -gt 10 ]; then
    echo "ALERTE: $ERRORS erreurs PHP détectées" >> $LOG
fi

echo "Check terminé" >> $LOG
```

```bash
# Ajouter au crontab (toutes les heures)
sudo crontab -e
# Ajouter :
0 * * * * /usr/local/bin/check-php-health.sh
```

### 9. Environnements multiples

Pour gérer différents environnements (dev, staging, production) :

```apache
# Site de développement
<VirtualHost *:80>
    ServerName dev.monsite.local
    DocumentRoot /var/www/dev
    
    # Configuration PHP pour développement
    php_flag display_errors On
    php_value error_reporting 32767  # E_ALL
    php_value memory_limit 512M
    php_flag html_errors On
    
    SetEnv APPLICATION_ENV development
</VirtualHost>

# Site de production
<VirtualHost *:80>
    ServerName monsite.com
    DocumentRoot /var/www/prod
    
    # Configuration PHP pour production
    php_flag display_errors Off
    php_value error_reporting 22527  # E_ALL & ~E_DEPRECATED & ~E_STRICT
    php_value memory_limit 256M
    php_flag log_errors On
    php_value error_log /var/log/apache2/prod_php_errors.log
    
    SetEnv APPLICATION_ENV production
</VirtualHost>
```

**Dans votre code PHP, détectez l'environnement :**

```php
<?php
$env = getenv('APPLICATION_ENV') ?: 'production';

if ($env === 'development') {
    ini_set('display_errors', 1);
    error_reporting(E_ALL);
} else {
    ini_set('display_errors', 0);
    error_reporting(E_ALL & ~E_DEPRECATED & ~E_STRICT);
}
?>
```

### 10. Sauvegarde des configurations

```bash
# Script de sauvegarde des configurations PHP-Apache
#!/bin/bash

BACKUP_DIR="/backup/php-apache-configs"
DATE=$(date +%Y%m%d_%H%M%S)

# Créer le répertoire de sauvegarde
mkdir -p $BACKUP_DIR

# Sauvegarder les configurations Apache
tar -czf $BACKUP_DIR/apache-configs-$DATE.tar.gz \
    /etc/apache2/sites-available/ \
    /etc/apache2/sites-enabled/ \
    /etc/apache2/mods-available/ \
    /etc/apache2/mods-enabled/ \
    /etc/apache2/apache2.conf

# Sauvegarder les configurations PHP
tar -czf $BACKUP_DIR/php-configs-$DATE.tar.gz \
    /etc/php/

# Garder uniquement les 7 dernières sauvegardes
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Sauvegarde terminée : $BACKUP_DIR"
```

> [!tip] Astuce finale Créez toujours un fichier `test.php` simple dans votre DocumentRoot pour vérifier rapidement que PHP fonctionne après chaque modification :
> 
> ```php
> <?php echo "PHP fonctionne - Version: " . phpversion(); ?>
> ```

---

## 🎓 Récapitulatif

Vous avez maintenant une compréhension complète de l'intégration PHP-Apache :

**Points clés à retenir :**

1. **mod_php** intègre l'interpréteur PHP directement dans Apache via `libapache2-mod-php`
2. Le **handler PHP** (`application/x-httpd-php`) indique à Apache comment traiter les fichiers `.php`
3. La configuration se fait via :
    - `/etc/apache2/mods-available/php8.2.conf` (configuration du module)
    - VirtualHosts (configuration par site)
    - `.htaccess` (si AllowOverride est activé)
4. **phpinfo()** est l'outil de diagnostic principal, mais doit être supprimé en production
5. Server API doit indiquer **"Apache 2.0 Handler"** pour confirmer que mod_php est actif
6. La sécurité nécessite de bloquer PHP dans les répertoires d'upload et de protéger les fichiers sensibles
7. Les configurations PHP diffèrent selon le contexte (CLI vs Apache)
8. Une seule version de PHP doit être active dans Apache à la fois

**Commandes essentielles :**

```bash
# Gestion du module
sudo a2enmod php8.2          # Activer
sudo a2dismod php8.2         # Désactiver
apache2ctl -M | grep php     # Vérifier

# Diagnostic
php -v                       # Version PHP
php -m                       # Extensions chargées
php --ini                    # Fichiers de configuration
php -i                       # phpinfo() en ligne de commande

# Tests
curl -I http://localhost/    # Vérifier les headers
sudo tail -f /var/log/apache2/error.log  # Surveiller les erreurs
```

**Architecture de mod_php :**

```
Requête HTTP → Apache → mod_php (interpréteur PHP embarqué) → Exécution PHP → Réponse HTML
```

Avec ces connaissances, vous êtes capable de configurer, optimiser et dépanner l'intégration PHP-Apache de manière professionnelle ! 🚀