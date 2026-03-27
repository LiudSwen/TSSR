

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

La configuration de base d'Apache définit les paramètres essentiels qui déterminent comment le serveur web répond aux requêtes. Ces directives se trouvent principalement dans le fichier `/etc/apache2/apache2.conf` (Debian/Ubuntu) ou `/etc/httpd/conf/httpd.conf` (RedHat/CentOS).

> [!info] Fichiers de configuration Apache utilise une structure modulaire de configuration :
> 
> - **Fichier principal** : `apache2.conf` ou `httpd.conf`
> - **Sites disponibles** : `/etc/apache2/sites-available/`
> - **Sites activés** : `/etc/apache2/sites-enabled/`
> - **Modules** : `/etc/apache2/mods-available/` et `/etc/apache2/mods-enabled/`

---

## 🌐 Directive ServerName

### Définition et rôle

La directive `ServerName` spécifie le nom de domaine que le serveur utilise pour s'identifier. C'est l'adresse par laquelle le serveur sera accessible sur le réseau.

### Pourquoi c'est important ?

- **Résolution DNS** : Permet au serveur de construire des URLs auto-référencées correctes
- **Virtual Hosts** : Essentiel pour héberger plusieurs sites sur un même serveur
- **Redirections** : Utilisé lors des redirections automatiques
- **Logs** : Facilite l'identification dans les journaux d'accès

> [!warning] Avertissement de démarrage Si `ServerName` n'est pas défini, Apache génère un avertissement au démarrage :
> 
> ```
> AH00558: apache2: Could not reliably determine the server's fully qualified domain name
> ```

### Syntaxe

```apache
ServerName nom_domaine[:port]
```

### Exemples pratiques

```apache
# Configuration simple avec un nom de domaine
ServerName www.example.com

# Configuration avec un port non-standard
ServerName www.example.com:8080

# Configuration avec une adresse IP (déconseillé en production)
ServerName 192.168.1.100

# Configuration pour un environnement de développement local
ServerName localhost
```

### Utilisation dans un Virtual Host

```apache
<VirtualHost *:80>
    ServerName www.monsite.com
    ServerAlias monsite.com
    DocumentRoot /var/www/monsite
</VirtualHost>
```

> [!tip] Bonne pratique Définissez toujours un `ServerName` global dans le fichier de configuration principal, même si vous utilisez des Virtual Hosts. Cela servira de valeur par défaut.

### Pièges courants

|Problème|Cause|Solution|
|---|---|---|
|Redirections incorrectes|ServerName mal configuré|Vérifier la correspondance avec le DNS|
|Site inaccessible|ServerName ne correspond pas à l'URL|Ajouter ServerAlias si nécessaire|
|Certificat SSL invalide|ServerName différent du certificat|Aligner ServerName avec le CN du certificat|

### Vérification

```bash
# Tester la configuration sans redémarrer
sudo apache2ctl configtest

# Vérifier le ServerName actif
apache2ctl -S

# Afficher la configuration complète
apache2ctl -t -D DUMP_VHOSTS
```

---

## 📁 DocumentRoot

### Définition et rôle

`DocumentRoot` spécifie le répertoire racine qui contient les fichiers à servir pour un site web. C'est le point de départ de l'arborescence des fichiers accessibles via HTTP.

### Pourquoi c'est important ?

- **Sécurité** : Limite l'accès aux fichiers du système
- **Organisation** : Structure l'hébergement de plusieurs sites
- **URLs** : Détermine la correspondance entre URL et chemin physique

### Syntaxe

```apache
DocumentRoot "chemin/absolu/vers/le/repertoire"
```

### Exemples pratiques

```apache
# Configuration Debian/Ubuntu standard
DocumentRoot /var/www/html

# Configuration pour un site spécifique
DocumentRoot /var/www/monsite/public

# Configuration pour plusieurs environnements
DocumentRoot /var/www/production/monsite
```

### Configuration complète avec permissions

```apache
DocumentRoot /var/www/monsite

<Directory /var/www/monsite>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
```

> [!info] Correspondance URL ↔ Fichier Exemple avec `DocumentRoot /var/www/html` :
> 
> - `http://monsite.com/` → `/var/www/html/index.html`
> - `http://monsite.com/images/logo.png` → `/var/www/html/images/logo.png`
> - `http://monsite.com/about.html` → `/var/www/html/about.html`

### Bonnes pratiques de sécurité

> [!warning] Permissions et propriétaire
> 
> ```bash
> # Définir le propriétaire correct (généralement www-data)
> sudo chown -R www-data:www-data /var/www/monsite
> 
> # Permissions recommandées
> sudo find /var/www/monsite -type d -exec chmod 755 {} \;
> sudo find /var/www/monsite -type f -exec chmod 644 {} \;
> ```

### Structure de répertoires recommandée

```
/var/www/
├── site1/
│   ├── public/          # DocumentRoot pour site1
│   ├── logs/
│   └── private/         # Fichiers non accessibles par le web
├── site2/
│   ├── public/          # DocumentRoot pour site2
│   ├── logs/
│   └── private/
```

### Pièges courants

|Problème|Cause|Solution|
|---|---|---|
|Error 403 Forbidden|Permissions incorrectes|Vérifier chmod/chown et directive Directory|
|Error 404 Not Found|DocumentRoot incorrect|Vérifier le chemin absolu|
|Fichiers non affichés|Pas de DirectoryIndex|Ajouter un fichier index ou configurer DirectoryIndex|

### Vérification et débogage

```bash
# Vérifier le DocumentRoot actif
apache2ctl -S | grep DocumentRoot

# Tester l'accès aux fichiers
sudo -u www-data test -r /var/www/monsite/index.html && echo "Accessible"

# Lister les permissions
ls -la /var/www/monsite/
```

> [!tip] Développement vs Production En développement, vous pouvez pointer DocumentRoot vers votre répertoire home, mais en production, utilisez toujours `/var/www/` pour une meilleure organisation et sécurité.

---

## 📄 DirectoryIndex

### Définition et rôle

`DirectoryIndex` définit la liste des fichiers qu'Apache recherchera et servira automatiquement lorsqu'un répertoire est demandé (sans spécifier de fichier dans l'URL).

### Pourquoi c'est important ?

- **Expérience utilisateur** : Permet d'accéder à `http://site.com/` au lieu de `http://site.com/index.html`
- **Flexibilité** : Supporte plusieurs technologies (PHP, HTML, etc.)
- **Sécurité** : Évite l'affichage du contenu du répertoire

### Syntaxe

```apache
DirectoryIndex fichier1 [fichier2] [fichier3] ...
```

### Configuration par défaut

```apache
DirectoryIndex index.html index.htm index.php
```

> [!info] Ordre de priorité Apache cherche les fichiers dans l'ordre spécifié. Le premier fichier trouvé est servi.

### Exemples pratiques

```apache
# Configuration pour un site PHP
DirectoryIndex index.php index.html index.htm

# Configuration pour un site avec plusieurs technologies
DirectoryIndex index.php index.py index.html default.html

# Configuration pour une application Node.js avec page de maintenance
DirectoryIndex maintenance.html index.html

# Configuration uniquement PHP (forcer l'utilisation de PHP)
DirectoryIndex index.php
```

### Scénarios d'utilisation

#### Site multilingue

```apache
<Directory /var/www/monsite>
    # Cherche d'abord la version localisée
    DirectoryIndex index-fr.html index-en.html index.html
</Directory>
```

#### Site avec page d'accueil dynamique

```apache
DirectoryIndex home.php index.php index.html
```

#### Application avec plusieurs points d'entrée

```apache
# Dans un sous-répertoire admin
<Directory /var/www/monsite/admin>
    DirectoryIndex dashboard.php admin.php index.php
</Directory>

# Dans le répertoire principal
<Directory /var/www/monsite>
    DirectoryIndex index.php welcome.php index.html
</Directory>
```

### Comportement sans DirectoryIndex

Si aucun fichier de la liste n'existe :

1. **Avec `Options Indexes`** : Apache affiche le contenu du répertoire (listing)
2. **Sans `Options Indexes`** : Apache renvoie une erreur 403 Forbidden

```apache
<Directory /var/www/monsite>
    Options -Indexes  # Désactive le listing (recommandé)
    DirectoryIndex index.php index.html
</Directory>
```

> [!warning] Sécurité : Désactivez les listings de répertoires
> 
> ```apache
> Options -Indexes
> ```
> 
> Cela empêche les visiteurs de voir la structure de vos fichiers si aucun fichier index n'existe.

### Test avec différentes extensions

```apache
# Support de multiples technologies
DirectoryIndex index.php index.phtml index.html index.htm default.html default.htm home.html home.htm
```

### Pièges courants

|Problème|Cause|Solution|
|---|---|---|
|Affichage du listing de répertoire|Aucun fichier index trouvé|Ajouter le fichier ou modifier DirectoryIndex|
|Mauvais fichier servi|Ordre incorrect dans DirectoryIndex|Réorganiser la liste par priorité|
|Error 403|Options -Indexes + aucun index|Ajouter un fichier index approprié|

### Vérification

```bash
# Tester quel fichier sera servi
ls -la /var/www/monsite/ | grep -E 'index\.|default\.'

# Vérifier la configuration active
apache2ctl -M | grep dir  # Vérifie que mod_dir est activé

# Test avec curl
curl -I http://localhost/
```

> [!tip] Bonne pratique Listez toujours plusieurs alternatives dans DirectoryIndex pour gérer différents scénarios :
> 
> ```apache
> DirectoryIndex index.php index.html index.htm default.html
> ```

### Configuration avancée : Redirection personnalisée

Si vous voulez un comportement personnalisé quand aucun index n'existe :

```apache
<Directory /var/www/monsite>
    DirectoryIndex index.php index.html
    Options -Indexes
    
    # Si aucun index n'existe, rediriger vers une page personnalisée
    ErrorDocument 403 /error/no-index.html
</Directory>
```

---

## 🔌 Port d'écoute (Listen)

### Définition et rôle

La directive `Listen` indique à Apache sur quels ports et interfaces réseau il doit écouter les connexions entrantes.

### Pourquoi c'est important ?

- **Accessibilité** : Détermine comment les clients peuvent se connecter
- **Sécurité** : Permet de limiter l'écoute à certaines interfaces
- **Multi-applications** : Permet d'héberger plusieurs services sur différents ports

### Syntaxe

```apache
Listen [adresse_ip:]port [protocol]
```

### Configuration par défaut

```apache
Listen 80
```

### Exemples pratiques

#### Configuration standard HTTP/HTTPS

```apache
# HTTP standard
Listen 80

# HTTPS (nécessite mod_ssl)
Listen 443
```

#### Écoute sur une interface spécifique

```apache
# Écouter uniquement sur localhost
Listen 127.0.0.1:80

# Écouter sur une IP spécifique
Listen 192.168.1.100:80

# Écouter sur toutes les interfaces (comportement par défaut)
Listen 0.0.0.0:80
```

#### Écoute sur plusieurs ports

```apache
Listen 80
Listen 8080
Listen 443
Listen 8443
```

> [!info] Distinction IPv4/IPv6
> 
> ```apache
> # IPv4 uniquement
> Listen 0.0.0.0:80
> 
> # IPv6 uniquement
> Listen [::]:80
> 
> # Les deux (comportement par défaut avec Listen 80)
> Listen 80
> ```

### Configurations avancées

#### Environnement de développement

```apache
# Port non-standard pour éviter les conflits
Listen 8080
Listen 8443
```

#### Séparation publique/privée

```apache
# Interface publique
Listen 203.0.113.10:80
Listen 203.0.113.10:443

# Interface privée/admin
Listen 10.0.0.5:9090
```

#### Multi-domaines avec ports différents

```apache
Listen 80
Listen 8080

<VirtualHost *:80>
    ServerName site1.com
    DocumentRoot /var/www/site1
</VirtualHost>

<VirtualHost *:8080>
    ServerName site2.com
    DocumentRoot /var/www/site2
</VirtualHost>
```

### Ports standards et leurs usages

|Port|Usage|Protocole|
|---|---|---|
|80|HTTP standard|HTTP|
|443|HTTPS standard|HTTPS/SSL/TLS|
|8080|HTTP alternatif (dev, proxy)|HTTP|
|8443|HTTPS alternatif|HTTPS/SSL/TLS|
|8000-8999|Développement/test|HTTP/HTTPS|

> [!warning] Ports privilégiés (< 1024) Les ports inférieurs à 1024 nécessitent les privilèges root pour être ouverts. Apache démarre en root puis change d'utilisateur (www-data), mais garde l'accès aux ports privilégiés.

### Sécurité et bonnes pratiques

#### Limiter l'écoute aux interfaces nécessaires

```apache
# Moins sécurisé : écoute sur toutes les interfaces
Listen 80

# Plus sécurisé : écoute uniquement sur l'interface publique
Listen 203.0.113.10:80
```

#### Utiliser HTTPS par défaut

```apache
# Configuration moderne recommandée
Listen 80
Listen 443

# Redirection HTTP → HTTPS dans le VirtualHost
<VirtualHost *:80>
    ServerName example.com
    Redirect permanent / https://example.com/
</VirtualHost>

<VirtualHost *:443>
    ServerName example.com
    # Configuration SSL...
</VirtualHost>
```

### Pièges courants

|Problème|Cause|Solution|
|---|---|---|
|Port already in use|Autre service utilise le port|Identifier avec `netstat` ou `ss`, changer de port|
|Permission denied|Port < 1024 sans privilèges|Lancer Apache avec sudo ou utiliser port > 1024|
|Site inaccessible|Firewall bloque le port|Ouvrir le port : `ufw allow 80/tcp`|
|Timeout de connexion|Listen sur mauvaise interface|Vérifier l'IP avec `ip addr`|

### Vérification et débogage

```bash
# Vérifier les ports en écoute
sudo netstat -tlnp | grep apache
# ou
sudo ss -tlnp | grep apache

# Vérifier la configuration Apache
apache2ctl -S

# Tester si le port est accessible
telnet localhost 80
# ou
curl -I http://localhost:80

# Vérifier qu'aucun autre service n'utilise le port
sudo lsof -i :80

# Vérifier les règles de firewall
sudo ufw status
# ou
sudo iptables -L
```

### Configuration avec firewall

```bash
# UFW (Ubuntu/Debian)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp

# Firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# IPTables
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

> [!tip] Astuce de production En production, n'exposez que les ports nécessaires :
> 
> - Port 80 et 443 pour le trafic web public
> - Ports alternatifs (8080, etc.) uniquement sur interfaces privées
> - Utilisez toujours un firewall pour filtrer les accès

### Test de connectivité

```bash
# Depuis le serveur local
curl http://localhost:80
curl https://localhost:443 -k

# Depuis une machine distante
curl http://192.168.1.100:80
curl https://example.com:443

# Test avec nmap
nmap -p 80,443,8080 192.168.1.100
```

### Changement de port après installation

```apache
# 1. Modifier la directive Listen
Listen 8080

# 2. Modifier les VirtualHosts concernés
<VirtualHost *:8080>
    ServerName example.com
    DocumentRoot /var/www/html
</VirtualHost>

# 3. Tester et redémarrer
sudo apache2ctl configtest
sudo systemctl restart apache2

# 4. Vérifier
curl http://localhost:8080
```

---

## 🔄 Application des modifications

Après avoir modifié la configuration, il est nécessaire de recharger ou redémarrer Apache :

```bash
# Tester la configuration (TOUJOURS faire avant de redémarrer)
sudo apache2ctl configtest
# ou
sudo apachectl configtest

# Recharger la configuration (sans couper les connexions actives)
sudo systemctl reload apache2

# Redémarrer Apache (coupe les connexions actives)
sudo systemctl restart apache2

# Vérifier le statut
sudo systemctl status apache2
```

> [!tip] Test avant application Utilisez toujours `apache2ctl configtest` ou `apache2ctl -t` avant de redémarrer pour éviter de casser le service en cas d'erreur de syntaxe.

---

## 📊 Exemple de configuration complète

```apache
# Configuration globale dans /etc/apache2/apache2.conf ou sites-available/000-default.conf

# Définition du nom de serveur
ServerName www.monsite.com

# Ports d'écoute
Listen 80

# Configuration du site principal
<VirtualHost *:80>
    ServerName www.monsite.com
    ServerAlias monsite.com
    
    # Répertoire racine
    DocumentRoot /var/www/monsite/public
    
    # Fichiers index
    DirectoryIndex index.php index.html index.htm
    
    # Permissions du répertoire
    <Directory /var/www/monsite/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # Logs
    ErrorLog ${APACHE_LOG_DIR}/monsite_error.log
    CustomLog ${APACHE_LOG_DIR}/monsite_access.log combined
</VirtualHost>
```

> [!example] Configuration HTTPS complète
> 
> ```apache
> # Configuration HTTP avec redirection
> <VirtualHost *:80>
>     ServerName www.monsite.com
>     Redirect permanent / https://www.monsite.com/
> </VirtualHost>
> 
> # Configuration HTTPS
> <VirtualHost *:443>
>     ServerName www.monsite.com
>     ServerAlias monsite.com
>     
>     DocumentRoot /var/www/monsite/public
>     DirectoryIndex index.php index.html
>     
>     <Directory /var/www/monsite/public>
>         Options -Indexes +FollowSymLinks
>         AllowOverride All
>         Require all granted
>     </Directory>
>     
>     # Configuration SSL (nécessite mod_ssl)
>     SSLEngine on
>     SSLCertificateFile /etc/ssl/certs/monsite.crt
>     SSLCertificateKeyFile /etc/ssl/private/monsite.key
>     
>     ErrorLog ${APACHE_LOG_DIR}/monsite_ssl_error.log
>     CustomLog ${APACHE_LOG_DIR}/monsite_ssl_access.log combined
> </VirtualHost>
> ```

---

## 🎯 Récapitulatif des directives

|Directive|Rôle|Syntaxe|Exemple|
|---|---|---|---|
|**ServerName**|Identité du serveur|`ServerName domaine[:port]`|`ServerName www.site.com`|
|**DocumentRoot**|Racine des fichiers web|`DocumentRoot "chemin"`|`DocumentRoot /var/www/html`|
|**DirectoryIndex**|Fichiers index par défaut|`DirectoryIndex fichier1 fichier2`|`DirectoryIndex index.php index.html`|
|**Listen**|Port et interface d'écoute|`Listen [IP:]port`|`Listen 80` ou `Listen 192.168.1.10:80`|