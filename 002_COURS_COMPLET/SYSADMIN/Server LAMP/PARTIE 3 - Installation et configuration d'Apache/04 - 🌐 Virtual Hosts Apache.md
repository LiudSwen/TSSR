

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

## 🎯 Principe des hôtes virtuels

### Qu'est-ce qu'un Virtual Host ?

Un **Virtual Host** (hôte virtuel) est une technique permettant d'héberger **plusieurs sites web sur un seul serveur Apache**. Sans les Virtual Hosts, un serveur ne pourrait servir qu'un seul site web.

> [!info] Pourquoi utiliser des Virtual Hosts ?
> 
> - **Économie de ressources** : Un seul serveur peut héberger des dizaines de sites
> - **Flexibilité** : Chaque site peut avoir sa propre configuration
> - **Isolation** : Les sites sont séparés logiquement (logs, répertoires, certificats SSL...)
> - **Environnements multiples** : dev.example.com, staging.example.com, www.example.com sur le même serveur

### Fonctionnement général

Lorsqu'une requête HTTP arrive sur Apache, le serveur doit déterminer **quel Virtual Host doit traiter cette requête**. Apache examine les informations de la requête (en-tête `Host`, adresse IP de destination, port) pour effectuer ce routage.

```
Client → Requête HTTP → Apache → Analyse → Virtual Host correspondant → Réponse
```

### Les types de Virtual Hosts

Apache propose deux approches principales :

|Type|Critère de sélection|Usage typique|
|---|---|---|
|**Par nom**|Nom de domaine (en-tête `Host`)|Hébergement mutualisé, sites multiples sur une IP|
|**Par IP**|Adresse IP de destination|Serveurs dédiés, besoins de certificats SSL distincts (ancien)|

> [!tip] Quelle approche choisir ? **Virtual Host par nom** est la méthode moderne et recommandée dans 99% des cas. Les Virtual Hosts par IP sont devenus rares depuis l'arrivée de SNI (Server Name Indication) pour SSL/TLS.

### Fichiers de configuration

Les Virtual Hosts sont définis dans des fichiers de configuration :

- **Debian/Ubuntu** : `/etc/apache2/sites-available/*.conf`
- **RedHat/CentOS** : `/etc/httpd/conf.d/*.conf`

> [!warning] Configuration principale vs Virtual Hosts Ne confondez pas le fichier de configuration principal (`apache2.conf` ou `httpd.conf`) avec les fichiers de Virtual Hosts. Les Virtual Hosts sont des configurations **spécifiques à chaque site**.

---

## 📛 Virtual Host par nom

### Concept

Le **Name-based Virtual Hosting** utilise le **nom de domaine** présent dans l'en-tête HTTP `Host:` pour distinguer les sites. Plusieurs sites partagent la même adresse IP et le même port.

```
Requête : GET / HTTP/1.1
          Host: www.site1.com
          
→ Apache route vers le Virtual Host configuré pour site1.com
```

> [!info] En-tête Host Depuis HTTP/1.1, les navigateurs envoient automatiquement un en-tête `Host:` avec le nom de domaine demandé. C'est ce qui rend possible le Name-based Virtual Hosting.

### Configuration de base

#### 1. Structure minimale

```apache
<VirtualHost *:80>
    ServerName www.example.com
    ServerAlias example.com
    DocumentRoot /var/www/example
    
    ErrorLog ${APACHE_LOG_DIR}/example-error.log
    CustomLog ${APACHE_LOG_DIR}/example-access.log combined
</VirtualHost>
```

#### 2. Directives essentielles

**`<VirtualHost *:80>`**

- `*` : écoute sur toutes les adresses IP du serveur
- `80` : port HTTP standard
- Alternative : `<VirtualHost 192.168.1.10:80>` pour une IP spécifique

**`ServerName`**

- Nom de domaine principal du site
- **Doit correspondre exactement** au nom demandé par le client
- Exemple : `ServerName www.monsite.fr`

**`ServerAlias`**

- Noms de domaine alternatifs pointant vers le même site
- Accepte plusieurs valeurs séparées par des espaces
- Supporte les wildcards : `ServerAlias *.example.com`

**`DocumentRoot`**

- Chemin absolu vers le répertoire racine du site
- Apache servira les fichiers depuis ce répertoire
- Le répertoire doit exister et être lisible par Apache

**`ErrorLog` et `CustomLog`**

- Logs séparés pour chaque Virtual Host
- Facilite le débogage et l'analyse
- `${APACHE_LOG_DIR}` est une variable pointant vers `/var/log/apache2/` (Debian) ou `/var/log/httpd/` (RedHat)

### Exemple complet

```apache
<VirtualHost *:80>
    # Identification du site
    ServerName blog.example.com
    ServerAlias www.blog.example.com
    ServerAdmin admin@example.com
    
    # Racine du site
    DocumentRoot /var/www/blog
    
    # Permissions du répertoire
    <Directory /var/www/blog>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # Logs dédiés
    ErrorLog ${APACHE_LOG_DIR}/blog-error.log
    CustomLog ${APACHE_LOG_DIR}/blog-access.log combined
    
    # Variables d'environnement (optionnel)
    SetEnv APP_ENV production
</VirtualHost>
```

> [!example] Scénario réel Vous hébergez trois sites sur le même serveur (IP : 203.0.113.10) :
> 
> - `www.boutique.fr` → `/var/www/boutique`
> - `blog.entreprise.com` → `/var/www/blog`
> - `api.service.net` → `/var/www/api`
> 
> Créez trois fichiers dans `/etc/apache2/sites-available/` et activez-les avec `a2ensite`.

### Activation et gestion (Debian/Ubuntu)

```bash
# Créer le fichier de configuration
sudo nano /etc/apache2/sites-available/monsite.conf

# Activer le Virtual Host
sudo a2ensite monsite.conf

# Désactiver un Virtual Host
sudo a2dissite monsite.conf

# Tester la configuration
sudo apache2ctl configtest

# Recharger Apache
sudo systemctl reload apache2
```

> [!warning] Toujours tester avant de recharger Utilisez `apache2ctl configtest` ou `apachectl configtest` pour vérifier la syntaxe. Une erreur de configuration peut empêcher Apache de démarrer !

### Virtual Host par défaut

Apache a besoin d'un **Virtual Host par défaut** pour traiter les requêtes qui ne correspondent à aucun `ServerName` ou `ServerAlias`.

```apache
<VirtualHost *:80>
    ServerName _default_
    DocumentRoot /var/www/html
    
    # Page d'erreur ou redirection
    Redirect 404 /
</VirtualHost>
```

> [!tip] Premier Virtual Host = Défaut Le **premier Virtual Host** dans l'ordre de chargement (ordre alphabétique sur Debian) devient le défaut. Sur Debian/Ubuntu, c'est généralement `000-default.conf`.

### Wildcards et ServerAlias

```apache
<VirtualHost *:80>
    ServerName example.com
    
    # Accepte tous les sous-domaines
    ServerAlias *.example.com
    
    # Accepte plusieurs domaines distincts
    ServerAlias exemple.fr www.exemple.fr
    
    DocumentRoot /var/www/example
</VirtualHost>
```

> [!warning] Sécurité avec les wildcards Avec `ServerAlias *`, vous acceptez **n'importe quel sous-domaine**. Assurez-vous que votre application gère correctement les sous-domaines inconnus pour éviter des failles de sécurité.

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> **1. DocumentRoot inexistant**
> 
> ```
> AH00112: Warning: DocumentRoot [/var/www/site] does not exist
> ```
> 
> → Créez le répertoire : `sudo mkdir -p /var/www/site`
> 
> **2. Permissions insuffisantes**
> 
> ```
> AH01630: client denied by server configuration
> ```
> 
> → Vérifiez les permissions et la directive `Require all granted`
> 
> **3. ServerName manquant** Sans `ServerName`, Apache ne peut pas router correctement les requêtes.
> 
> **4. Oubli du rechargement** Les modifications ne sont actives qu'après `systemctl reload apache2`

### Bonnes pratiques

✅ **Nommage des fichiers** : Utilisez des noms descriptifs (`blog.example.com.conf`)

✅ **Un fichier par site** : Ne mélangez pas plusieurs Virtual Hosts dans un seul fichier

✅ **Logs séparés** : Chaque Virtual Host doit avoir ses propres logs

✅ **Documentation** : Ajoutez des commentaires dans vos fichiers de configuration

✅ **Versioning** : Conservez vos configurations dans un système de contrôle de version (Git)

---

## 🔢 Virtual Host par IP

### Concept

Le **IP-based Virtual Hosting** utilise l'**adresse IP de destination** pour distinguer les sites. Chaque site a sa propre adresse IP dédiée.

```
Client → www.site1.com (203.0.113.10) → Virtual Host 1
Client → www.site2.com (203.0.113.11) → Virtual Host 2
```

> [!info] Utilisation moderne limitée Avec l'épuisement des adresses IPv4 et l'arrivée de SNI (Server Name Indication) pour SSL/TLS, les Virtual Hosts par IP sont devenus **rares**. Ils sont surtout utilisés dans des contextes legacy ou des contraintes spécifiques.

### Configuration de base

#### Prérequis : Plusieurs adresses IP

Votre serveur doit avoir plusieurs adresses IP configurées :

```bash
# Voir les adresses IP
ip addr show

# Ajouter une IP temporaire (exemple)
sudo ip addr add 192.168.1.11/24 dev eth0

# Configuration permanente : éditer /etc/network/interfaces (Debian)
# ou /etc/sysconfig/network-scripts/ifcfg-eth0 (RedHat)
```

#### Syntaxe du Virtual Host

```apache
<VirtualHost 192.168.1.10:80>
    ServerName www.site1.com
    DocumentRoot /var/www/site1
    
    ErrorLog ${APACHE_LOG_DIR}/site1-error.log
    CustomLog ${APACHE_LOG_DIR}/site1-access.log combined
</VirtualHost>

<VirtualHost 192.168.1.11:80>
    ServerName www.site2.com
    DocumentRoot /var/www/site2
    
    ErrorLog ${APACHE_LOG_DIR}/site2-error.log
    CustomLog ${APACHE_LOG_DIR}/site2-access.log combined
</VirtualHost>
```

> [!warning] Différence clé Au lieu de `<VirtualHost *:80>`, on spécifie l'**IP exacte** : `<VirtualHost 192.168.1.10:80>`

### Exemple avec ports différents

Vous pouvez combiner IP et port pour une granularité maximale :

```apache
# Site HTTP standard
<VirtualHost 192.168.1.10:80>
    ServerName www.public.com
    DocumentRoot /var/www/public
</VirtualHost>

# Site HTTPS avec IP dédiée
<VirtualHost 192.168.1.10:443>
    ServerName www.public.com
    DocumentRoot /var/www/public
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/public.crt
    SSLCertificateKeyFile /etc/ssl/private/public.key
</VirtualHost>

# Application interne sur port custom
<VirtualHost 192.168.1.11:8080>
    ServerName admin.internal.com
    DocumentRoot /var/www/admin
    
    <Directory /var/www/admin>
        Require ip 192.168.1.0/24
    </Directory>
</VirtualHost>
```

### Configuration de Listen

Pour écouter sur plusieurs IP, configurez la directive `Listen` :

```apache
# /etc/apache2/ports.conf (Debian) ou httpd.conf (RedHat)

Listen 192.168.1.10:80
Listen 192.168.1.11:80
Listen 192.168.1.10:443

# Ou écouter sur toutes les IP
Listen 80
Listen 443
```

> [!tip] Listen vs VirtualHost
> 
> - **Listen** : définit sur quelles IP/ports Apache écoute
> - **VirtualHost** : définit comment traiter les requêtes sur ces IP/ports

### Cas d'usage des Virtual Hosts par IP

|Scénario|Raison|
|---|---|
|**SSL/TLS ancien**|Avant SNI, chaque certificat nécessitait une IP dédiée|
|**Isolation réseau**|Sites sur des segments réseau différents|
|**Contraintes firewall**|Règles de pare-feu basées sur l'IP|
|**Clients legacy**|Anciens clients ne supportant pas SNI|
|**Séparation facturation**|Hébergement avec IPs dédiées facturées séparément|

> [!info] SSL/TLS et SNI Historiquement, HTTPS nécessitait une IP par certificat. Depuis SNI (2003, largement supporté depuis 2010), ce n'est plus nécessaire. Les Virtual Hosts par nom fonctionnent parfaitement avec HTTPS moderne.

### Avantages et inconvénients

**✅ Avantages**

- Isolation réseau complète
- Compatible avec les très vieux clients (pré-HTTP/1.1)
- Simplicité du routage (pas de dépendance à l'en-tête Host)

**❌ Inconvénients**

- Consommation d'adresses IP (problème avec IPv4)
- Coût supplémentaire (IPs dédiées)
- Configuration réseau plus complexe
- Moins flexible que le Name-based

### Pièges courants

> [!warning] Erreurs à éviter
> 
> **1. IP non configurée sur l'interface réseau**
> 
> ```
> (99)Cannot assign requested address: AH00072: make_sock: could not bind to address 192.168.1.10:80
> ```
> 
> → L'IP doit exister sur une interface réseau du serveur
> 
> **2. Conflit avec Name-based** Si vous mélangez `<VirtualHost *:80>` et `<VirtualHost 192.168.1.10:80>`, le comportement peut être imprévisible.
> 
> **3. Oubli de Listen** Sans `Listen 192.168.1.10:80`, Apache n'écoutera pas sur cette IP.

### Bonnes pratiques

✅ **Documentez les IP** : Maintenez un inventaire clair de vos adresses IP

✅ **Configuration réseau persistante** : Assurez-vous que les IP survivent aux redémarrages

✅ **Préférez Name-based** : Utilisez IP-based uniquement si vraiment nécessaire

✅ **Testez la connectivité** : Vérifiez que chaque IP est accessible (`ping`, `telnet`)

---

## 🏗️ Configuration multi-sites

### Architecture d'hébergement multiple

Une configuration multi-sites permet d'héberger **plusieurs sites web complètement indépendants** sur un même serveur Apache. Chaque site a ses propres :

- Nom de domaine
- Répertoire racine
- Configuration spécifique
- Logs dédiés
- Certificats SSL (optionnel)

> [!info] Scénarios typiques
> 
> - Agence web hébergeant les sites de plusieurs clients
> - Entreprise avec plusieurs marques/produits
> - Environnements multiples (dev, staging, production)
> - Sites multilingues ou multi-régionaux

### Structure de répertoires recommandée

```
/var/www/
├── site1.com/
│   ├── public_html/       # DocumentRoot
│   ├── logs/              # Logs (optionnel)
│   └── ssl/               # Certificats SSL (optionnel)
├── site2.com/
│   ├── public_html/
│   ├── logs/
│   └── ssl/
└── site3.com/
    ├── public_html/
    ├── logs/
    └── ssl/
```

> [!tip] Organisation alternative Vous pouvez aussi séparer par fonction :
> 
> ```
> /var/www/html/site1/
> /var/www/html/site2/
> /var/log/apache2/site1-*
> /var/log/apache2/site2-*
> ```

### Configuration complète multi-sites

#### 1. Site principal (site1.com)

```apache
# /etc/apache2/sites-available/site1.com.conf

<VirtualHost *:80>
    ServerName site1.com
    ServerAlias www.site1.com
    ServerAdmin admin@site1.com
    
    DocumentRoot /var/www/site1.com/public_html
    
    <Directory /var/www/site1.com/public_html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # Logs dédiés
    ErrorLog /var/www/site1.com/logs/error.log
    CustomLog /var/www/site1.com/logs/access.log combined
    
    # Sécurité de base
    <FilesMatch "\.(?i:php)$">
        Require all granted
    </FilesMatch>
</VirtualHost>
```

#### 2. Site secondaire (site2.com)

```apache
# /etc/apache2/sites-available/site2.com.conf

<VirtualHost *:80>
    ServerName site2.com
    ServerAlias www.site2.com *.site2.com
    ServerAdmin webmaster@site2.com
    
    DocumentRoot /var/www/site2.com/public_html
    
    <Directory /var/www/site2.com/public_html>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>
    
    # Logs avec rotation
    ErrorLog /var/www/site2.com/logs/error.log
    CustomLog /var/www/site2.com/logs/access.log combined
    
    # Configuration PHP spécifique (optionnel)
    php_admin_value upload_max_filesize 50M
    php_admin_value post_max_size 50M
</VirtualHost>
```

#### 3. Application web (app.example.com)

```apache
# /etc/apache2/sites-available/app.example.com.conf

<VirtualHost *:80>
    ServerName app.example.com
    ServerAdmin support@example.com
    
    DocumentRoot /var/www/app.example.com/public_html
    
    <Directory /var/www/app.example.com/public_html>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
        
        # Réécriture pour application SPA
        RewriteEngine On
        RewriteBase /
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.html [L]
    </Directory>
    
    # Headers de sécurité
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    
    ErrorLog ${APACHE_LOG_DIR}/app-error.log
    CustomLog ${APACHE_LOG_DIR}/app-access.log combined
</VirtualHost>
```

### Configuration HTTPS multi-sites

#### Redirection HTTP → HTTPS

```apache
# site1.com HTTP → HTTPS
<VirtualHost *:80>
    ServerName site1.com
    ServerAlias www.site1.com
    
    # Redirection permanente vers HTTPS
    Redirect permanent / https://site1.com/
</VirtualHost>

# site1.com HTTPS
<VirtualHost *:443>
    ServerName site1.com
    ServerAlias www.site1.com
    ServerAdmin admin@site1.com
    
    DocumentRoot /var/www/site1.com/public_html
    
    <Directory /var/www/site1.com/public_html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # Configuration SSL
    SSLEngine on
    SSLCertificateFile /var/www/site1.com/ssl/cert.pem
    SSLCertificateKeyFile /var/www/site1.com/ssl/key.pem
    SSLCertificateChainFile /var/www/site1.com/ssl/chain.pem
    
    # Sécurité SSL moderne
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
    SSLHonorCipherOrder off
    
    ErrorLog /var/www/site1.com/logs/ssl-error.log
    CustomLog /var/www/site1.com/logs/ssl-access.log combined
</VirtualHost>
```

> [!tip] Let's Encrypt pour tous les sites Utilisez Certbot pour obtenir des certificats gratuits :
> 
> ```bash
> sudo certbot --apache -d site1.com -d www.site1.com
> sudo certbot --apache -d site2.com -d www.site2.com
> ```

### Configuration avec sous-domaines

```apache
# Sous-domaine API
<VirtualHost *:80>
    ServerName api.example.com
    DocumentRoot /var/www/api.example.com/public_html
    
    <Directory /var/www/api.example.com/public_html>
        Options -Indexes
        AllowOverride None
        Require all granted
        
        # Headers CORS pour API
        Header always set Access-Control-Allow-Origin "*"
        Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/api-error.log
    CustomLog ${APACHE_LOG_DIR}/api-access.log combined
</VirtualHost>

# Sous-domaine Blog
<VirtualHost *:80>
    ServerName blog.example.com
    DocumentRoot /var/www/blog.example.com/public_html
    
    <Directory /var/www/blog.example.com/public_html>
        Options +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/blog-error.log
    CustomLog ${APACHE_LOG_DIR}/blog-access.log combined
</VirtualHost>

# Sous-domaine statique (CDN)
<VirtualHost *:80>
    ServerName static.example.com
    DocumentRoot /var/www/static.example.com/public_html
    
    <Directory /var/www/static.example.com/public_html>
        Options -Indexes
        AllowOverride None
        Require all granted
        
        # Cache agressif pour assets statiques
        ExpiresActive On
        ExpiresDefault "access plus 1 year"
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/static-error.log
    CustomLog ${APACHE_LOG_DIR}/static-access.log combined
</VirtualHost>
```

### Environnements multiples (dev/staging/prod)

```apache
# Production
<VirtualHost *:80>
    ServerName www.example.com
    DocumentRoot /var/www/production/public_html
    
    <Directory /var/www/production/public_html>
        Options -Indexes
        AllowOverride All
        Require all granted
    </Directory>
    
    SetEnv APP_ENV production
    SetEnv APP_DEBUG false
    
    ErrorLog ${APACHE_LOG_DIR}/prod-error.log
    CustomLog ${APACHE_LOG_DIR}/prod-access.log combined
</VirtualHost>

# Staging (pré-production)
<VirtualHost *:80>
    ServerName staging.example.com
    DocumentRoot /var/www/staging/public_html
    
    <Directory /var/www/staging/public_html>
        Options +Indexes
        AllowOverride All
        # Accès restreint
        Require ip 192.168.1.0/24 203.0.113.0/24
    </Directory>
    
    SetEnv APP_ENV staging
    SetEnv APP_DEBUG true
    
    ErrorLog ${APACHE_LOG_DIR}/staging-error.log
    CustomLog ${APACHE_LOG_DIR}/staging-access.log combined
</VirtualHost>

# Développement
<VirtualHost *:80>
    ServerName dev.example.com
    DocumentRoot /var/www/development/public_html
    
    <Directory /var/www/development/public_html>
        Options +Indexes +FollowSymLinks
        AllowOverride All
        # Accès interne uniquement
        Require ip 192.168.1.0/24
    </Directory>
    
    SetEnv APP_ENV development
    SetEnv APP_DEBUG true
    
    ErrorLog ${APACHE_LOG_DIR}/dev-error.log
    CustomLog ${APACHE_LOG_DIR}/dev-access.log combined
</VirtualHost>
```

### Script de déploiement automatisé

```bash
#!/bin/bash
# create-vhost.sh - Script de création de Virtual Host

DOMAIN=$1
EMAIL=$2

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Usage: $0 domain.com admin@domain.com"
    exit 1
fi

# Créer la structure de répertoires
sudo mkdir -p /var/www/$DOMAIN/{public_html,logs,ssl}
sudo chown -R www-data:www-data /var/www/$DOMAIN

# Créer le fichier de configuration
sudo tee /etc/apache2/sites-available/$DOMAIN.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    ServerAdmin $EMAIL
    
    DocumentRoot /var/www/$DOMAIN/public_html
    
    <Directory /var/www/$DOMAIN/public_html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog /var/www/$DOMAIN/logs/error.log
    CustomLog /var/www/$DOMAIN/logs/access.log combined
</VirtualHost>
EOF

# Créer une page d'index par défaut
sudo tee /var/www/$DOMAIN/public_html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>$DOMAIN</title>
</head>
<body>
    <h1>Site en construction</h1>
    <p>$DOMAIN est en cours de configuration.</p>
</body>
</html>
EOF

# Activer le site
sudo a2ensite $DOMAIN.conf

# Tester la configuration
sudo apache2ctl configtest

# Recharger Apache
sudo systemctl reload apache2

echo "✅ Virtual Host $DOMAIN créé avec succès !"
echo "📁 DocumentRoot: /var/www/$DOMAIN/public_html"
echo "📋 Configuration: /etc/apache2/sites-available/$DOMAIN.conf"
```

Usage :

```bash
chmod +x create-vhost.sh
sudo ./create-vhost.sh monsite.com admin@monsite.com
```

### Gestion des logs multi-sites

#### Configuration avancée des logs

```apache
<VirtualHost *:80>
    ServerName example.com
    DocumentRoot /var/www/example/public_html
    
    # Format de log personnalisé avec vhost
    LogFormat "%V:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
    
    # Logs avec rotation automatique par date
    ErrorLog "|/usr/bin/rotatelogs /var/www/example/logs/error-%Y%m%d.log 86400"
    CustomLog "|/usr/bin/rotatelogs /var/www/example/logs/access-%Y%m%d.log 86400" vhost_combined
    
    # Log conditionnel (ignorer les images)
    SetEnvIf Request_URI "\.(gif|jpg|png|css|js)$" dontlog
    CustomLog /var/www/example/logs/app.log combined env=!dontlog
</VirtualHost>
```

#### Analyse centralisée

```bash
# Analyser tous les logs d'accès
sudo grep -h "404" /var/www/*/logs/access.log | sort | uniq -c | sort -nr

# Surveiller en temps réel tous les sites
sudo tail -f /var/www/*/logs/access.log

# Erreurs des dernières 24h tous sites confondus
sudo find /var/www/*/logs/ -name "error.log" -mtime -1 -exec grep -H "error" {} \;
```

### Optimisations multi-sites

#### Utilisation des includes

```apache
# /etc/apache2/conf-available/security-headers.conf
Header always set X-Content-Type-Options "nosniff"
Header always set X-Frame-Options "SAMEORIGIN"
Header always set X-XSS-Protection "1; mode=block"
Header always set Referrer-Policy "strict-origin-when-cross-origin"

# Dans chaque Virtual Host
<VirtualHost *:80>
    ServerName site1.com
    DocumentRoot /var/www/site1/public_html
    
    # Inclure la configuration commune
    Include conf-available/security-headers.conf
</VirtualHost>
```

#### Macros pour Virtual Hosts répétitifs

```apache
# Activer le module macro
# sudo a2enmod macro

# Définir une macro pour sites standards
<Macro VHost $domain $admin>
    <VirtualHost *:80>
        ServerName $domain
        ServerAlias www.$domain
        ServerAdmin $admin
        
        DocumentRoot /var/www/$domain/public_html
        
        <Directory /var/www/$domain/public_html>
            Options -Indexes +FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
        
        ErrorLog /var/www/$domain/logs/error.log
        CustomLog /var/www/$domain/logs/access.log combined
    </VirtualHost>
</Macro>

# Utiliser la macro
Use VHost site1.com admin@site1.com
Use VHost site2.com admin@site2.com
Use VHost site3.com admin@site3.com

# Annuler la macro après usage
UndefMacro VHost
```

> [!tip] Avantage des macros Les macros permettent de **réduire la duplication** et de **standardiser** les configurations. Parfait pour gérer des dizaines de sites similaires.

#### Mise en cache partagée

```apache
# Configuration globale du cache (à placer dans apache2.conf ou httpd.conf)
# sudo a2enmod cache
# sudo a2enmod cache_disk

<IfModule mod_cache_disk.c>
    CacheRoot /var/cache/apache2/mod_cache_disk
    CacheEnable disk "/"
    CacheDirLevels 2
    CacheDirLength 1
    CacheMaxFileSize 1000000
</IfModule>

# Dans chaque Virtual Host
<VirtualHost *:80>
    ServerName site1.com
    DocumentRoot /var/www/site1/public_html
    
    # Cache spécifique pour ce site
    CacheEnable disk /
    CacheHeader on
    CacheDefaultExpire 3600
    
    # Ne pas mettre en cache certaines URLs
    CacheDisable /admin
    CacheDisable /api
</VirtualHost>
```

### Isolation et sécurité multi-sites

#### Séparation des utilisateurs système

```bash
# Créer un utilisateur par site pour isolation maximale
sudo useradd -r -s /bin/false site1_user
sudo useradd -r -s /bin/false site2_user

# Attribuer les permissions
sudo chown -R site1_user:site1_user /var/www/site1
sudo chown -R site2_user:site2_user /var/www/site2

# Configuration Apache avec MPM-ITK (alternative à MPM prefork/worker)
# sudo a2enmod mpm_itk
```

```apache
<VirtualHost *:80>
    ServerName site1.com
    DocumentRoot /var/www/site1/public_html
    
    # Exécuter Apache sous l'utilisateur du site
    AssignUserId site1_user site1_user
    
    <Directory /var/www/site1/public_html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

> [!warning] MPM-ITK vs autres MPM **MPM-ITK** offre une excellente isolation mais peut consommer plus de ressources. Évaluez vos besoins de sécurité vs performance.

#### Restrictions d'accès par site

```apache
# Site avec authentification
<VirtualHost *:80>
    ServerName admin.example.com
    DocumentRoot /var/www/admin/public_html
    
    <Directory /var/www/admin/public_html>
        Options -Indexes
        AllowOverride None
        
        # Authentification HTTP Basic
        AuthType Basic
        AuthName "Zone d'administration"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
        
        # ET restriction IP
        Require ip 192.168.1.0/24
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/admin-error.log
    CustomLog ${APACHE_LOG_DIR}/admin-access.log combined
</VirtualHost>

# Site avec géoblocage (nécessite mod_geoip)
<VirtualHost *:80>
    ServerName restricted.example.com
    DocumentRoot /var/www/restricted/public_html
    
    <Directory /var/www/restricted/public_html>
        # Autoriser uniquement France et Belgique
        GeoIPEnable On
        SetEnvIf GEOIP_COUNTRY_CODE FR AllowCountry
        SetEnvIf GEOIP_COUNTRY_CODE BE AllowCountry
        
        Require env AllowCountry
    </Directory>
</VirtualHost>
```

#### Limitation de ressources par site

```apache
<VirtualHost *:80>
    ServerName heavysite.com
    DocumentRoot /var/www/heavysite/public_html
    
    # Limiter les connexions simultanées (nécessite mod_qos)
    QS_SrvMaxConnPerIP 10
    
    # Limiter la bande passante (nécessite mod_bw)
    BandwidthModule On
    ForceBandWidthModule On
    Bandwidth all 102400
    MinBandwidth all -1
    
    # Timeout spécifique
    TimeOut 60
    
    <Directory /var/www/heavysite/public_html>
        Options -Indexes
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
```

### Surveillance et monitoring multi-sites

#### Page de statut par Virtual Host

```apache
# Virtual Host principal
<VirtualHost *:80>
    ServerName site1.com
    DocumentRoot /var/www/site1/public_html
    
    # Activer le statut Apache pour ce site
    <Location /server-status>
        SetHandler server-status
        Require ip 127.0.0.1 192.168.1.0/24
    </Location>
    
    # Informations détaillées
    ExtendedStatus On
</VirtualHost>
```

#### Script de surveillance

```bash
#!/bin/bash
# monitor-vhosts.sh - Surveillance des Virtual Hosts

SITES=(
    "site1.com"
    "site2.com"
    "api.example.com"
)

echo "🔍 Surveillance des Virtual Hosts - $(date)"
echo "================================================"

for site in "${SITES[@]}"; do
    # Test HTTP
    status=$(curl -s -o /dev/null -w "%{http_code}" "http://$site")
    
    if [ "$status" -eq 200 ]; then
        echo "✅ $site - OK ($status)"
    else
        echo "❌ $site - ERREUR ($status)"
        
        # Envoyer une alerte
        echo "Alerte: $site retourne $status" | mail -s "Alerte Apache" admin@example.com
    fi
    
    # Vérifier les erreurs récentes dans les logs
    errors=$(sudo grep -c "error" "/var/www/$site/logs/error.log" 2>/dev/null || echo 0)
    echo "   📊 Erreurs dans les logs: $errors"
done

echo "================================================"
```

#### Intégration avec des outils de monitoring

```apache
# Endpoint de healthcheck
<VirtualHost *:80>
    ServerName site1.com
    DocumentRoot /var/www/site1/public_html
    
    # Endpoint pour Nagios, Prometheus, etc.
    <Location /health>
        SetHandler server-status
        Require ip 10.0.0.0/8
        ProxyPass !
    </Location>
    
    # Métriques personnalisées
    <Location /metrics>
        SetHandler application/json
        Require ip 10.0.0.0/8
        
        # Script CGI retournant des métriques
        Options +ExecCGI
        AddHandler cgi-script .py
    </Location>
</VirtualHost>
```

### Gestion des erreurs multi-sites

#### Pages d'erreur personnalisées

```apache
<VirtualHost *:80>
    ServerName site1.com
    DocumentRoot /var/www/site1/public_html
    
    # Pages d'erreur personnalisées
    ErrorDocument 400 /errors/400.html
    ErrorDocument 401 /errors/401.html
    ErrorDocument 403 /errors/403.html
    ErrorDocument 404 /errors/404.html
    ErrorDocument 500 /errors/500.html
    ErrorDocument 503 /errors/503.html
    
    # Ou redirection vers un script dynamique
    ErrorDocument 404 /error-handler.php
    
    <Directory /var/www/site1/public_html>
        Options -Indexes
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

#### Gestion centralisée des erreurs

```apache
# Fichier: /etc/apache2/conf-available/error-pages.conf

# Pages d'erreur partagées
Alias /errors /usr/share/apache2/error-pages

<Directory /usr/share/apache2/error-pages>
    Options -Indexes
    AllowOverride None
    Require all granted
</Directory>

# Dans chaque Virtual Host
<VirtualHost *:80>
    ServerName site1.com
    DocumentRoot /var/www/site1/public_html
    
    # Utiliser les pages d'erreur partagées
    Include conf-available/error-pages.conf
    ErrorDocument 404 /errors/404.html
    ErrorDocument 500 /errors/500.html
</VirtualHost>
```

### Débogage et dépannage

#### Vérification de la configuration

```bash
# Tester la syntaxe globale
sudo apache2ctl configtest
# ou
sudo apachectl configtest

# Afficher tous les Virtual Hosts chargés
sudo apache2ctl -S
# ou
sudo apachectl -S

# Sortie exemple:
# VirtualHost configuration:
# *:80                   site1.com (/etc/apache2/sites-enabled/site1.com.conf:1)
# *:80                   site2.com (/etc/apache2/sites-enabled/site2.com.conf:1)
# *:443                  site1.com (/etc/apache2/sites-enabled/site1.com-ssl.conf:1)

# Vérifier les modules chargés
apache2ctl -M | grep -i rewrite
apache2ctl -M | grep -i ssl
```

#### Logs de débogage

```apache
<VirtualHost *:80>
    ServerName debug.example.com
    DocumentRoot /var/www/debug/public_html
    
    # Niveau de log très verbeux (TEMPORAIRE pour debug)
    LogLevel trace8
    
    # Log détaillé du module rewrite
    LogLevel rewrite:trace6
    
    ErrorLog ${APACHE_LOG_DIR}/debug-error.log
    CustomLog ${APACHE_LOG_DIR}/debug-access.log combined
</VirtualHost>
```

> [!warning] LogLevel en production N'utilisez **JAMAIS** `LogLevel trace` en production ! Cela génère des logs énormes et ralentit Apache. Utilisez `warn` ou `error` en production.

#### Tests de résolution DNS

```bash
# Vérifier la résolution DNS
dig site1.com +short
nslookup site1.com

# Tester avec curl
curl -I http://site1.com

# Tester avec un Host header spécifique
curl -H "Host: site1.com" http://192.168.1.10/

# Simuler différents clients
curl -H "User-Agent: Mozilla/5.0" http://site1.com
curl -H "User-Agent: Googlebot" http://site1.com
```

#### Diagnostic de Virtual Host

```bash
# Voir quel Virtual Host répond
curl -v http://site1.com 2>&1 | grep "< Server"

# Tester SSL/TLS
openssl s_client -connect site1.com:443 -servername site1.com

# Vérifier les certificats
echo | openssl s_client -connect site1.com:443 -servername site1.com 2>/dev/null | openssl x509 -noout -dates

# Analyser les performances
ab -n 1000 -c 10 http://site1.com/
```

### Pièges courants multi-sites

> [!warning] Erreurs fréquentes
> 
> **1. Mauvais ordre de chargement** Le premier Virtual Host devient le défaut. Nommez vos fichiers avec des préfixes numériques :
> 
> ```
> 000-default.conf
> 010-site1.com.conf
> 020-site2.com.conf
> ```
> 
> **2. DocumentRoot identiques** Ne pointez jamais deux Virtual Hosts vers le même DocumentRoot sauf si vous savez ce que vous faites.
> 
> **3. Permissions incorrectes**
> 
> ```bash
> # Vérifiez toujours
> sudo ls -la /var/www/site1/
> sudo namei -l /var/www/site1/public_html/index.html
> ```
> 
> **4. Oubli du rechargement après modifications**
> 
> ```bash
> sudo systemctl reload apache2  # Recharge la config
> sudo systemctl restart apache2 # Redémarre Apache
> ```
> 
> **5. Conflits de ports** Si plusieurs Virtual Hosts utilisent le même IP:Port, seul le premier ServerName compte. Les autres doivent être en ServerAlias.
> 
> **6. Logs qui explosent** Sans rotation, les logs peuvent saturer le disque. Utilisez `logrotate` :
> 
> ```bash
> sudo nano /etc/logrotate.d/apache2
> ```

### Bonnes pratiques multi-sites

✅ **Nommage cohérent** : Utilisez toujours le FQDN comme nom de fichier (`site1.com.conf`)

✅ **Un fichier par site** : Facilite la maintenance et le déploiement

✅ **Documentation** : Ajoutez des commentaires dans chaque configuration

```apache
# Site: Boutique en ligne
# Responsable: Jean Dupont <jean@example.com>
# Créé: 2024-01-15
# Dernière modif: 2024-03-20 - Ajout HTTPS
<VirtualHost *:80>
    ServerName boutique.example.com
    # ...
</VirtualHost>
```

✅ **Versionning** : Utilisez Git pour vos configurations

```bash
cd /etc/apache2/sites-available
sudo git init
sudo git add *.conf
sudo git commit -m "Configuration initiale"
```

✅ **Tests automatisés** : Créez un script de validation

```bash
#!/bin/bash
# test-vhosts.sh

SITES=("site1.com" "site2.com" "api.example.com")

for site in "${SITES[@]}"; do
    # Test HTTP
    if curl -f -s "http://$site" > /dev/null; then
        echo "✅ $site OK"
    else
        echo "❌ $site FAIL"
        exit 1
    fi
done

echo "✅ Tous les sites fonctionnent"
```

✅ **Sauvegarde** : Automatisez les backups

```bash
#!/bin/bash
# backup-vhosts.sh

BACKUP_DIR="/backup/apache-configs"
DATE=$(date +%Y%m%d)

mkdir -p $BACKUP_DIR

# Sauvegarder les configurations
tar -czf $BACKUP_DIR/vhosts-$DATE.tar.gz \
    /etc/apache2/sites-available/ \
    /etc/apache2/sites-enabled/

# Garder seulement les 30 derniers jours
find $BACKUP_DIR -name "vhosts-*.tar.gz" -mtime +30 -delete

echo "✅ Sauvegarde créée: vhosts-$DATE.tar.gz"
```

✅ **Monitoring** : Surveillez les métriques importantes

```apache
# Activer mod_status globalement
<IfModule mod_status.c>
    ExtendedStatus On
    
    <Location /server-status>
        SetHandler server-status
        Require ip 127.0.0.1
    </Location>
</IfModule>
```

✅ **Sécurité** : Appliquez le principe du moindre privilège

```apache
<VirtualHost *:80>
    ServerName secure.example.com
    DocumentRoot /var/www/secure/public_html
    
    <Directory /var/www/secure/public_html>
        # Désactiver les options dangereuses
        Options -Indexes -ExecCGI -FollowSymLinks
        
        # Limiter les overrides
        AllowOverride FileInfo Indexes
        
        # Permissions strictes
        Require all granted
        
        # Bloquer les fichiers sensibles
        <FilesMatch "\.(env|config|ini|log)$">
            Require all denied
        </FilesMatch>
    </Directory>
    
    # Headers de sécurité
    Header always set X-Frame-Options "DENY"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "no-referrer-when-downgrade"
    Header always set Content-Security-Policy "default-src 'self'"
</VirtualHost>
```

✅ **Performance** : Optimisez chaque site selon ses besoins

```apache
<VirtualHost *:80>
    ServerName fast.example.com
    DocumentRoot /var/www/fast/public_html
    
    # Compression
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript
    </IfModule>
    
    # Expiration des ressources statiques
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresByType image/jpg "access plus 1 year"
        ExpiresByType image/jpeg "access plus 1 year"
        ExpiresByType image/gif "access plus 1 year"
        ExpiresByType image/png "access plus 1 year"
        ExpiresByType text/css "access plus 1 month"
        ExpiresByType application/javascript "access plus 1 month"
    </IfModule>
    
    # Keep-Alive pour les connexions
    KeepAlive On
    MaxKeepAliveRequests 100
    KeepAliveTimeout 5
</VirtualHost>
```

---

## 🎯 Récapitulatif

### Points clés à retenir

🔹 **Virtual Hosts** permettent d'héberger **plusieurs sites sur un seul serveur Apache**

🔹 **Name-based Virtual Hosting** (par nom de domaine) est la méthode **moderne et recommandée**

🔹 **IP-based Virtual Hosting** (par adresse IP) est utilisé dans des cas **spécifiques et rares**

🔹 **Configuration multi-sites** nécessite une organisation rigoureuse (répertoires, logs, sécurité)

🔹 **Chaque Virtual Host** peut avoir sa propre configuration indépendante

🔹 **L'ordre de chargement** des Virtual Hosts détermine lequel sera utilisé par défaut

🔹 **Toujours tester** la configuration avec `apache2ctl configtest` avant de recharger

🔹 **Les logs séparés** facilitent le débogage et l'analyse de chaque site

### Commandes essentielles

```bash
# Créer un Virtual Host
sudo nano /etc/apache2/sites-available/monsite.conf

# Activer un Virtual Host
sudo a2ensite monsite.conf

# Désactiver un Virtual Host
sudo a2dissite monsite.conf

# Lister tous les Virtual Hosts
sudo apache2ctl -S

# Tester la configuration
sudo apache2ctl configtest

# Recharger Apache
sudo systemctl reload apache2

# Redémarrer Apache
sudo systemctl restart apache2

# Voir les logs en temps réel
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/www/monsite/logs/access.log
```

### Checklist de création d'un Virtual Host

- [ ] Créer la structure de répertoires (`mkdir -p /var/www/site/public_html`)
- [ ] Définir les permissions correctes (`chown -R www-data:www-data`)
- [ ] Créer le fichier de configuration dans `sites-available/`
- [ ] Définir `ServerName` et éventuellement `ServerAlias`
- [ ] Spécifier le `DocumentRoot`
- [ ] Configurer les permissions du répertoire (`<Directory>`)
- [ ] Définir les logs (`ErrorLog` et `CustomLog`)
- [ ] Tester la syntaxe (`apache2ctl configtest`)
- [ ] Activer le site (`a2ensite`)
- [ ] Recharger Apache (`systemctl reload apache2`)
- [ ] Vérifier la résolution DNS
- [ ] Tester l'accès au site (`curl -I http://monsite.com`)
- [ ] Consulter les logs en cas de problème

### Ressources de débogage

|Problème|Solution|
|---|---|
|**404 Not Found**|Vérifier DocumentRoot, permissions, fichiers présents|
|**403 Forbidden**|Vérifier `Require all granted`, permissions du système de fichiers|
|**Virtual Host pas trouvé**|Vérifier ServerName, DNS, `apache2ctl -S`|
|**Site par défaut affiché**|Vérifier l'ordre de chargement, ServerName correct|
|**Erreur SSL**|Vérifier les certificats, chemins, module SSL activé|
|**Logs vides**|Vérifier les chemins, permissions d'écriture|
|**Modifications non prises en compte**|Recharger Apache, vérifier le bon fichier modifié|

---

_Ce cours couvre l'installation et la configuration des Virtual Hosts Apache. Pour approfondir d'autres aspects de LAMP (PHP, MySQL, sécurité SSL), consultez les parties suivantes du cours._