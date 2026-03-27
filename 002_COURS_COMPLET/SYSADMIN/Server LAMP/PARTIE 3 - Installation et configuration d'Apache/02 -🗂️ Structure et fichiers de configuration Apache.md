

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

## 🎯 Vue d'ensemble

La configuration d'Apache suit une architecture modulaire et hiérarchique qui permet une grande flexibilité. Comprendre cette structure est essentiel pour administrer efficacement un serveur web.

> [!info] Différences selon les distributions
> 
> - **Debian/Ubuntu** : `/etc/apache2` avec une structure modulaire
> - **Red Hat/CentOS** : `/etc/httpd` avec une structure plus monolithique
> 
> Ce cours se concentre principalement sur la structure Debian/Ubuntu, plus répandue et considérée comme plus organisée.

---

## 📁 Arborescence Apache

### Structure complète sous Debian/Ubuntu

```bash
/etc/apache2/
├── apache2.conf           # Fichier de configuration principal
├── envvars               # Variables d'environnement
├── magic                 # Reconnaissance des types MIME
├── ports.conf            # Configuration des ports d'écoute
│
├── mods-available/       # Modules disponibles
├── mods-enabled/         # Modules activés (liens symboliques)
│
├── conf-available/       # Configurations additionnelles disponibles
├── conf-enabled/         # Configurations additionnelles activées
│
├── sites-available/      # Sites virtuels disponibles
├── sites-enabled/        # Sites virtuels activés (liens symboliques)
│
└── conf.d/              # Configurations legacy (anciennes versions)
```

### Structure sous Red Hat/CentOS

```bash
/etc/httpd/
├── conf/
│   ├── httpd.conf        # Fichier principal (tout en un)
│   └── magic
│
├── conf.d/               # Configurations modulaires
│   ├── autoindex.conf
│   ├── userdir.conf
│   └── welcome.conf
│
└── conf.modules.d/       # Chargement des modules
    ├── 00-base.conf
    ├── 00-mpm.conf
    └── 00-ssl.conf
```

> [!tip] Philosophie de l'arborescence La structure Debian/Ubuntu sépare clairement :
> 
> - Ce qui est **disponible** (available) : configurations présentes mais non actives
> - Ce qui est **activé** (enabled) : configurations actuellement utilisées
> 
> Cela permet d'activer/désactiver facilement des fonctionnalités sans supprimer les fichiers.

### Répertoires importants

|Répertoire|Utilité|Commandes associées|
|---|---|---|
|`/var/www/html`|Racine web par défaut|Document root|
|`/var/log/apache2`|Logs du serveur|`access.log`, `error.log`|
|`/usr/lib/apache2/modules`|Binaires des modules|`.so` files|
|`/usr/share/apache2`|Fichiers de support|Pages d'erreur par défaut|

---

## ⚙️ Fichier principal de configuration

### apache2.conf (Debian/Ubuntu)

Le fichier `/etc/apache2/apache2.conf` est le point d'entrée de toute la configuration.

#### Structure du fichier

```apache
# Section 1 : Configuration globale du serveur
ServerRoot "/etc/apache2"
Mutex file:${APACHE_LOCK_DIR} default
PidFile ${APACHE_PID_FILE}
Timeout 300
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5

# Section 2 : Modules de Multi-Processing (MPM)
# Ces directives définissent comment Apache gère les processus
<IfModule mpm_prefork_module>
    StartServers             5
    MinSpareServers          5
    MaxSpareServers         10
    MaxRequestWorkers      150
    MaxConnectionsPerChild   0
</IfModule>

# Section 3 : Sécurité par défaut - Restrictions globales
<Directory />
    Options FollowSymLinks
    AllowOverride None
    Require all denied
</Directory>

# Section 4 : Autorisation pour /var/www
<Directory /var/www/>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>

# Section 5 : Configuration des fichiers .htaccess
AccessFileName .htaccess
<FilesMatch "^\.ht">
    Require all denied
</FilesMatch>

# Section 6 : Logging
LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %O" common

# Section 7 : Inclusion d'autres fichiers de configuration
IncludeOptional mods-enabled/*.load
IncludeOptional mods-enabled/*.conf
Include ports.conf
IncludeOptional conf-enabled/*.conf
IncludeOptional sites-enabled/*.conf
```

> [!example] Directives clés expliquées
> 
> **ServerRoot** : Répertoire racine d'Apache, tous les chemins relatifs partent de là
> 
> **Timeout** : Temps maximum (en secondes) pour une requête. Augmenter pour des uploads lourds
> 
> **KeepAlive** : Maintient la connexion TCP ouverte pour plusieurs requêtes (améliore les performances)
> 
> **MaxKeepAliveRequests** : Nombre max de requêtes par connexion persistante (100 par défaut)

#### Directives de sécurité critiques

```apache
# Désactive la signature du serveur (masque la version Apache)
ServerTokens Prod
ServerSignature Off

# Bloque l'accès aux fichiers sensibles
<FilesMatch "^\.ht">
    Require all denied
</FilesMatch>

# Désactive le listing des répertoires (sauf si explicitement activé)
<Directory /var/www/>
    Options -Indexes
</Directory>
```

> [!warning] Sécurité par défaut La directive `<Directory />` avec `Require all denied` est cruciale : elle bloque l'accès à TOUT le système de fichiers par défaut. Vous devez ensuite autoriser explicitement les répertoires que vous voulez exposer.

### httpd.conf (Red Hat/CentOS)

Le fichier `/etc/httpd/conf/httpd.conf` regroupe toute la configuration dans un seul fichier plus monolithique.

```apache
# Configuration globale
ServerRoot "/etc/httpd"
Listen 80

# Inclusion des modules
Include conf.modules.d/*.conf

# Utilisateur/Groupe Apache
User apache
Group apache

# Configuration du serveur principal
ServerAdmin root@localhost
DocumentRoot "/var/www/html"

# Directives de répertoire
<Directory "/var/www/html">
    AllowOverride None
    Require all granted
</Directory>

# Inclusion de configurations additionnelles
IncludeOptional conf.d/*.conf
```

### Le fichier ports.conf

Contrôle sur quels ports Apache écoute :

```apache
# ports.conf
Listen 80

<IfModule ssl_module>
    Listen 443
</IfModule>

<IfModule mod_gnutls.c>
    Listen 443
</IfModule>
```

> [!tip] Multiple ports Vous pouvez faire écouter Apache sur plusieurs ports :
> 
> ```apache
> Listen 80
> Listen 8080
> Listen 443
> ```

### Le fichier envvars

Définit les variables d'environnement utilisées par Apache :

```bash
# /etc/apache2/envvars
export APACHE_RUN_USER=www-data
export APACHE_RUN_GROUP=www-data
export APACHE_PID_FILE=/var/run/apache2/apache2.pid
export APACHE_RUN_DIR=/var/run/apache2
export APACHE_LOCK_DIR=/var/lock/apache2
export APACHE_LOG_DIR=/var/log/apache2
```

---

## 🌐 Fichiers de sites

### Concept des sites disponibles et activés

Apache utilise un système à deux niveaux pour gérer les sites web :

1. **sites-available/** : Tous les fichiers de configuration de sites (actifs ou non)
2. **sites-enabled/** : Liens symboliques vers les sites actuellement actifs

> [!info] Pourquoi cette séparation ? Cela permet de :
> 
> - Désactiver temporairement un site sans perdre sa configuration
> - Activer/désactiver rapidement des sites selon les besoins
> - Versionner toutes les configurations même désactivées
> - Tester des configurations avant de les activer

### Structure d'un fichier de site

#### Site par défaut (000-default.conf)

```apache
# /etc/apache2/sites-available/000-default.conf

<VirtualHost *:80>
    # Contact administrateur
    ServerAdmin webmaster@localhost
    
    # Racine des documents web
    DocumentRoot /var/www/html
    
    # Logs spécifiques à ce site
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

> [!example] Fichier de site complet
> 
> ```apache
> <VirtualHost *:80>
>     # Identification du site
>     ServerName example.com
>     ServerAlias www.example.com
>     ServerAdmin admin@example.com
>     
>     # Chemin racine du site
>     DocumentRoot /var/www/example.com/public_html
>     
>     # Configuration du répertoire
>     <Directory /var/www/example.com/public_html>
>         Options -Indexes +FollowSymLinks
>         AllowOverride All
>         Require all granted
>     </Directory>
>     
>     # Logs dédiés
>     ErrorLog ${APACHE_LOG_DIR}/example.com-error.log
>     CustomLog ${APACHE_LOG_DIR}/example.com-access.log combined
>     
>     # Optionnel : Redirection HTTPS
>     # RewriteEngine On
>     # RewriteCond %{HTTPS} off
>     # RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
> </VirtualHost>
> ```

### Commandes de gestion des sites

```bash
# Activer un site
sudo a2ensite example.com.conf

# Désactiver un site
sudo a2dissite example.com.conf

# Recharger la configuration
sudo systemctl reload apache2

# Vérifier la configuration avant de recharger
sudo apache2ctl configtest
```

> [!warning] Toujours tester avant de recharger Utilisez `apache2ctl configtest` ou `apachectl -t` avant de recharger Apache. Une erreur de syntaxe peut empêcher le démarrage du serveur !

### Anatomie d'un VirtualHost

```apache
<VirtualHost *:80>
    # --- IDENTIFICATION ---
    ServerName monsite.com           # Domaine principal
    ServerAlias www.monsite.com      # Domaines alternatifs
    ServerAdmin admin@monsite.com    # Contact technique
    
    # --- CHEMINS ---
    DocumentRoot /var/www/monsite    # Racine web
    
    # --- SÉCURITÉ ET PERMISSIONS ---
    <Directory /var/www/monsite>
        Options -Indexes +FollowSymLinks    # Désactive listing, active symlinks
        AllowOverride All                   # Autorise .htaccess
        Require all granted                 # Accès public
    </Directory>
    
    # --- LOGS ---
    ErrorLog ${APACHE_LOG_DIR}/monsite-error.log
    CustomLog ${APACHE_LOG_DIR}/monsite-access.log combined
    
    # --- CONFIGURATION ADDITIONNELLE ---
    # Redirection, réécriture d'URL, headers, etc.
</VirtualHost>
```

#### Directives importantes dans VirtualHost

|Directive|Fonction|Exemple|
|---|---|---|
|`ServerName`|Nom de domaine principal|`ServerName example.com`|
|`ServerAlias`|Noms de domaine alternatifs|`ServerAlias www.example.com`|
|`DocumentRoot`|Racine du site web|`DocumentRoot /var/www/site`|
|`ErrorLog`|Fichier de log des erreurs|`ErrorLog /var/log/error.log`|
|`CustomLog`|Fichier de log des accès|`CustomLog /var/log/access.log`|

### Priorité des VirtualHosts

Apache traite les VirtualHosts dans l'ordre alphabétique. Le premier VirtualHost est le **default** utilisé si aucun ServerName ne correspond.

```bash
# Préfixer avec des numéros pour contrôler l'ordre
000-default.conf          # Site par défaut
100-example.com.conf      # Site principal
200-test.example.com.conf # Site de test
```

> [!tip] Convention de nommage Utilisez des préfixes numériques pour contrôler l'ordre de chargement et des noms explicites pour identifier facilement vos sites.

---

## 🧩 Répertoires conf.d et mods-available

### Le répertoire mods-available/

Contient les configurations des modules Apache. Chaque module a généralement deux fichiers :

- **`.load`** : Charge la bibliothèque du module
- **`.conf`** : Configure le module

#### Exemple : Module rewrite

```apache
# /etc/apache2/mods-available/rewrite.load
LoadModule rewrite_module /usr/lib/apache2/modules/mod_rewrite.so
```

```apache
# /etc/apache2/mods-available/rewrite.conf
<IfModule mod_rewrite.c>
    # Configuration spécifique au module
    RewriteEngine Off
</IfModule>
```

### Gestion des modules

```bash
# Lister les modules disponibles
ls /etc/apache2/mods-available/

# Lister les modules activés
ls /etc/apache2/mods-enabled/
# ou
apache2ctl -M

# Activer un module
sudo a2enmod rewrite

# Désactiver un module
sudo a2dismod rewrite

# Recharger Apache après modification
sudo systemctl reload apache2
```

> [!example] Modules couramment utilisés
> 
> ```bash
> sudo a2enmod rewrite    # Réécriture d'URL
> sudo a2enmod ssl        # Support HTTPS
> sudo a2enmod headers    # Manipulation des en-têtes HTTP
> sudo a2enmod proxy      # Fonctions proxy
> sudo a2enmod proxy_http # Proxy HTTP
> ```

### Le répertoire conf-available/

Contient des configurations additionnelles modulaires qui ne sont pas des VirtualHosts ni des modules.

#### Exemples de configurations

```apache
# /etc/apache2/conf-available/security.conf
# Configuration de sécurité globale

ServerTokens Prod
ServerSignature Off
TraceEnable Off

<Directory />
    AllowOverride None
    Require all denied
</Directory>
```

```apache
# /etc/apache2/conf-available/charset.conf
# Configuration des encodages

AddDefaultCharset UTF-8
```

### Gestion des configurations

```bash
# Activer une configuration
sudo a2enconf security

# Désactiver une configuration
sudo a2disconf security

# Recharger Apache
sudo systemctl reload apache2
```

### Le répertoire conf.d/ (legacy)

> [!info] Répertoire legacy Sur les anciennes versions d'Apache et sur Red Hat/CentOS, `conf.d/` est le répertoire standard pour les configurations additionnelles. Tous les fichiers `.conf` dans ce répertoire sont automatiquement chargés.

Sous Debian/Ubuntu moderne, ce répertoire existe pour compatibilité mais `conf-available/conf-enabled/` est préféré.

```bash
# Structure Red Hat/CentOS
/etc/httpd/conf.d/
├── autoindex.conf    # Configuration de l'index automatique
├── userdir.conf      # Répertoires utilisateurs
├── welcome.conf      # Page d'accueil par défaut
└── ssl.conf          # Configuration SSL/TLS
```

---

## ✅ Bonnes pratiques

### Organisation des fichiers

```bash
# Nommage cohérent des fichiers de sites
[priorité]-[domaine].conf
000-default.conf
100-example.com.conf
100-example.com-ssl.conf
```

### Gestion de la configuration

> [!tip] Versionner vos configurations
> 
> ```bash
> # Initialiser un dépôt git dans /etc/apache2
> cd /etc/apache2
> sudo git init
> sudo git add .
> sudo git commit -m "Configuration initiale"
> 
> # Après chaque modification importante
> sudo git add sites-available/monsite.conf
> sudo git commit -m "Ajout configuration monsite.com"
> ```

### Sauvegarde avant modification

```bash
# Toujours sauvegarder avant de modifier
sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.backup
sudo cp -r /etc/apache2/sites-available /etc/apache2/sites-available.backup

# Ou avec date
sudo cp apache2.conf apache2.conf.$(date +%Y%m%d)
```

### Validation systématique

```bash
# Workflow de modification
# 1. Éditer le fichier
sudo nano /etc/apache2/sites-available/monsite.conf

# 2. Vérifier la syntaxe
sudo apache2ctl configtest

# 3. Si OK, activer et recharger
sudo a2ensite monsite.conf
sudo systemctl reload apache2

# 4. Vérifier les logs
sudo tail -f /var/log/apache2/error.log
```

> [!warning] Erreurs courantes
> 
> - Oublier le point-virgule ou l'accolade fermante
> - Chemins de fichiers incorrects (typos dans DocumentRoot)
> - Conflits de ports entre VirtualHosts
> - Permissions inadéquates sur les répertoires web
> - Modules requis non activés (ex: rewrite pour les URL réécrites)

### Sécurisation de base

```apache
# Dans chaque VirtualHost
<Directory /var/www/monsite>
    # Désactiver le listing des répertoires
    Options -Indexes +FollowSymLinks
    
    # Permettre .htaccess si nécessaire
    AllowOverride All
    
    # Accès public
    Require all granted
</Directory>

# Bloquer les fichiers sensibles
<FilesMatch "^\.(htaccess|htpasswd|git|env)">
    Require all denied
</FilesMatch>
```

### Performance

```apache
# Activer la compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript
</IfModule>

# Cache des fichiers statiques
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
</IfModule>
```

### Documentation de vos configurations

```apache
# Toujours commenter vos fichiers de configuration
<VirtualHost *:80>
    # Site : exemple.com
    # Responsable : admin@exemple.com
    # Créé le : 2025-01-15
    # Dernière modification : 2025-01-20
    
    ServerName exemple.com
    DocumentRoot /var/www/exemple
    
    # Redirection HTTPS activée le 2025-01-20
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
</VirtualHost>
```

---

## 🎯 Points clés à retenir

> [!tip] Mémo rapide
> 
> **Structure Debian/Ubuntu** : Séparation available/enabled pour sites, modules et configurations
> 
> **Fichier principal** : `apache2.conf` inclut tous les autres fichiers via `Include`
> 
> **VirtualHosts** : Un fichier par site dans `sites-available/`, activation via `a2ensite`
> 
> **Modules** : Fichiers `.load` + `.conf` dans `mods-available/`, activation via `a2enmod`
> 
> **Validation** : Toujours utiliser `apache2ctl configtest` avant de recharger
> 
> **Sécurité** : Principe du moindre privilège, bloquer par défaut, autoriser explicitement