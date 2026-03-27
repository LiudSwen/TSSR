

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

## Introduction aux modules

Les modules Apache sont des composants qui étendent les fonctionnalités du serveur web. Apache suit une architecture modulaire qui permet d'activer uniquement les fonctionnalités nécessaires, optimisant ainsi les performances et la sécurité.

> [!info] Pourquoi utiliser des modules ?
> 
> - **Performance** : Charger uniquement ce dont vous avez besoin
> - **Sécurité** : Réduire la surface d'attaque en désactivant les modules inutilisés
> - **Flexibilité** : Ajouter des fonctionnalités selon les besoins du projet
> - **Maintenance** : Faciliter les mises à jour et la gestion du serveur

### Architecture modulaire

Apache peut charger des modules de deux façons :

- **Statique** : Compilés directement dans le binaire Apache (rare aujourd'hui)
- **Dynamique** : Chargés au démarrage via des fichiers `.so` (standard)

---

## Liste des modules courants

Voici les modules Apache les plus utilisés, classés par catégorie :

### Modules de base

|Module|Description|Usage typique|
|---|---|---|
|`mod_dir`|Gestion des répertoires et fichiers index|Affichage automatique de index.html|
|`mod_mime`|Association des extensions aux types MIME|Gestion des types de fichiers|
|`mod_log_config`|Configuration flexible des logs|Personnalisation des fichiers de log|
|`mod_alias`|Création d'alias et de redirections|Mappage d'URLs vers des chemins système|
|`mod_autoindex`|Génération automatique d'index de répertoires|Listing de fichiers|

### Modules de performance

|Module|Description|Usage typique|
|---|---|---|
|`mod_deflate`|Compression des contenus|Réduction de la bande passante|
|`mod_expires`|Contrôle des en-têtes d'expiration|Optimisation du cache navigateur|
|`mod_headers`|Manipulation des en-têtes HTTP|Ajout/modification d'en-têtes|
|`mod_cache`|Système de cache|Amélioration des performances|

### Modules de sécurité

|Module|Description|Usage typique|
|---|---|---|
|`mod_ssl`|Support HTTPS/TLS|Sécurisation des connexions|
|`mod_security`|Pare-feu applicatif web (WAF)|Protection contre les attaques|
|`mod_auth_basic`|Authentification HTTP basique|Protection par mot de passe|
|`mod_authz_host`|Contrôle d'accès par IP|Restriction d'accès|

### Modules de réécriture et proxy

|Module|Description|Usage typique|
|---|---|---|
|`mod_rewrite`|Réécriture d'URLs|URLs propres, redirections avancées|
|`mod_proxy`|Fonctionnalités de proxy|Reverse proxy, load balancing|
|`mod_proxy_http`|Proxy HTTP|Proxyfication de requêtes HTTP|
|`mod_proxy_fcgi`|Proxy FastCGI|Communication avec PHP-FPM|

### Modules pour langages dynamiques

|Module|Description|Usage typique|
|---|---|---|
|`mod_php`|Interpréteur PHP intégré|Exécution de PHP (déprécié)|
|`mod_wsgi`|Support Python WSGI|Applications Python|
|`mod_perl`|Interpréteur Perl intégré|Applications Perl|

> [!warning] Attention L'utilisation de `mod_php` est déconseillée aujourd'hui. Préférez PHP-FPM avec `mod_proxy_fcgi` pour de meilleures performances et une meilleure isolation.

---

## Activation et désactivation des modules

### Commandes a2enmod et a2dismod

Sur les systèmes Debian/Ubuntu, Apache fournit des utilitaires pour gérer facilement les modules :

```bash
# Activer un module
sudo a2enmod nom_du_module

# Désactiver un module
sudo a2dismod nom_du_module

# Redémarrer Apache pour appliquer les changements
sudo systemctl restart apache2
```

> [!example] Exemple pratique
> 
> ```bash
> # Activer le module de réécriture d'URL
> sudo a2enmod rewrite
> 
> # Activer le module SSL
> sudo a2enmod ssl
> 
> # Activer plusieurs modules en une fois
> sudo a2enmod rewrite ssl headers
> 
> # Redémarrer Apache
> sudo systemctl restart apache2
> ```

### Vérifier les modules actifs

```bash
# Lister tous les modules chargés
apache2ctl -M

# Ou avec apachectl
apachectl -M

# Rechercher un module spécifique
apache2ctl -M | grep rewrite
```

> [!tip] Astuce Utilisez `apache2ctl -t` avant de redémarrer pour vérifier la syntaxe de votre configuration et éviter les erreurs.

### Fonctionnement interne

Les commandes `a2enmod` et `a2dismod` créent ou suppriment des liens symboliques :

```bash
# Structure des répertoires
/etc/apache2/
├── mods-available/    # Tous les modules disponibles
│   ├── rewrite.load   # Fichier de chargement
│   └── rewrite.conf   # Configuration (optionnel)
└── mods-enabled/      # Modules activés (symlinks)
    └── rewrite.load -> ../mods-available/rewrite.load
```

> [!info] Comprendre les fichiers .load et .conf
> 
> - **`.load`** : Contient la directive `LoadModule` qui charge le module
> - **`.conf`** : Contient la configuration spécifique du module (optionnel)

### Activation manuelle (méthode alternative)

Sur d'autres distributions (RedHat/CentOS), l'activation se fait via le fichier de configuration :

```bash
# Éditer le fichier de configuration principal
sudo nano /etc/httpd/conf/httpd.conf

# Décommenter ou ajouter la ligne LoadModule
LoadModule rewrite_module modules/mod_rewrite.so

# Redémarrer Apache
sudo systemctl restart httpd
```

---

## Module rewrite

Le module `mod_rewrite` est l'un des modules les plus puissants d'Apache. Il permet de réécrire dynamiquement les URLs en fonction de règles personnalisées.

### Activation du module

```bash
# Activer mod_rewrite
sudo a2enmod rewrite

# Redémarrer Apache
sudo systemctl restart apache2
```

### Configuration de base

Pour utiliser `mod_rewrite`, il faut autoriser l'utilisation de fichiers `.htaccess` :

```apache
<Directory /var/www/html>
    # Autoriser les directives de réécriture dans .htaccess
    AllowOverride All
    
    # Ou plus spécifiquement
    AllowOverride FileInfo
</Directory>
```

> [!warning] Sécurité `AllowOverride All` donne beaucoup de permissions. En production, utilisez `AllowOverride FileInfo` pour limiter aux directives de réécriture uniquement.

### Syntaxe des règles de réécriture

```apache
RewriteEngine On                      # Activer le moteur de réécriture
RewriteRule Pattern Substitution [Flags]
```

**Composants d'une règle :**

- **Pattern** : Expression régulière pour matcher l'URL
- **Substitution** : Nouvelle URL ou chemin
- **Flags** : Options modifiant le comportement de la règle

### Flags courants

|Flag|Description|Exemple d'usage|
|---|---|---|
|`[L]`|Last - Arrête le traitement|Dernière règle à appliquer|
|`[R=301]`|Redirect permanent|Redirection permanente|
|`[R=302]`|Redirect temporaire|Redirection temporaire|
|`[NC]`|No Case - Insensible à la casse|Ignorer majuscules/minuscules|
|`[QSA]`|Query String Append|Préserver les paramètres GET|
|`[L,QSA]`|Combinaison de flags|Plusieurs flags séparés par virgules|

> [!example] Exemples pratiques de réécriture

#### Exemple 1 : URLs propres (suppression de .php)

```apache
RewriteEngine On

# Rediriger /page.php vers /page
RewriteCond %{THE_REQUEST} ^GET\ /(.*)\.php\ HTTP
RewriteRule (.*)\.php$ /$1 [R=301,L]

# Réécrire /page vers /page.php en interne
RewriteCond %{REQUEST_FILENAME}.php -f
RewriteRule ^(.*)$ $1.php [L]
```

#### Exemple 2 : Forcer HTTPS

```apache
RewriteEngine On

# Vérifier si la connexion n'est pas en HTTPS
RewriteCond %{HTTPS} !=on
# Rediriger vers HTTPS
RewriteRule ^(.*)$ https://%{HTTP_HOST}/$1 [R=301,L]
```

#### Exemple 3 : Rediriger www vers non-www

```apache
RewriteEngine On

# Si le domaine commence par www
RewriteCond %{HTTP_HOST} ^www\.(.+)$ [NC]
# Rediriger vers la version sans www
RewriteRule ^(.*)$ https://%1/$1 [R=301,L]
```

#### Exemple 4 : URLs SEO-friendly

```apache
RewriteEngine On

# Transformer /article/123/titre-de-article
# En /article.php?id=123
RewriteRule ^article/([0-9]+)/[a-z0-9-]+$ /article.php?id=$1 [L,QSA]
```

### RewriteCond : Conditions de réécriture

Les `RewriteCond` permettent d'ajouter des conditions aux règles :

```apache
RewriteCond TestString Pattern [Flags]
```

**Variables serveur courantes :**

|Variable|Description|
|---|---|
|`%{HTTP_HOST}`|Nom de domaine de la requête|
|`%{REQUEST_URI}`|URI de la requête|
|`%{HTTPS}`|État de la connexion HTTPS|
|`%{REQUEST_FILENAME}`|Chemin complet du fichier|
|`%{QUERY_STRING}`|Paramètres GET de l'URL|
|`%{HTTP_REFERER}`|Page de provenance|
|`%{REMOTE_ADDR}`|Adresse IP du client|

> [!example] Conditions multiples

```apache
RewriteEngine On

# Plusieurs conditions (ET logique par défaut)
RewriteCond %{HTTP_HOST} ^example\.com$ [NC]
RewriteCond %{REQUEST_URI} !^/admin/
RewriteRule ^(.*)$ https://www.example.com/$1 [R=301,L]

# Conditions avec OU logique
RewriteCond %{HTTP_HOST} ^example\.com$ [NC,OR]
RewriteCond %{HTTP_HOST} ^autre-domaine\.com$ [NC]
RewriteRule ^(.*)$ https://www.example.com/$1 [R=301,L]
```

### Debugging des règles de réécriture

```bash
# Activer le log de réécriture
sudo nano /etc/apache2/sites-available/000-default.conf
```

```apache
<VirtualHost *:80>
    # Activer le log de debug pour mod_rewrite
    LogLevel alert rewrite:trace6
    
    # Fichier de log personnalisé
    ErrorLog ${APACHE_LOG_DIR}/rewrite.log
</VirtualHost>
```

> [!tip] Niveaux de trace
> 
> - `trace1` : Informations minimales
> - `trace3` : Informations détaillées (recommandé)
> - `trace6` : Toutes les informations (très verbeux)

### Pièges courants

> [!warning] Erreurs fréquentes

1. **Boucles infinies**

```apache
# ❌ Mauvais - Crée une boucle infinie
RewriteRule ^(.*)$ /index.php/$1 [L]

# ✅ Correct - Vérifie que ce n'est pas déjà index.php
RewriteCond %{REQUEST_URI} !^/index\.php
RewriteRule ^(.*)$ /index.php/$1 [L]
```

2. **Oublier le flag [L]**

```apache
# ❌ Les règles suivantes seront aussi exécutées
RewriteRule ^old-page$ /new-page

# ✅ Arrête le traitement après cette règle
RewriteRule ^old-page$ /new-page [L]
```

3. **Problèmes de chemin relatif/absolu**

```apache
# ❌ Chemin relatif - peut causer des problèmes
RewriteRule ^page$ page.php [L]

# ✅ Chemin absolu - toujours préférable
RewriteRule ^page$ /page.php [L]
```

### Bonnes pratiques

✅ **Toujours activer explicitement le moteur**

```apache
RewriteEngine On
```

✅ **Utiliser RewriteBase pour les installations en sous-dossier**

```apache
RewriteEngine On
RewriteBase /mon-site/
```

✅ **Exclure les fichiers statiques**

```apache
# Ne pas réécrire si le fichier existe
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ /index.php/$1 [L]
```

✅ **Grouper les règles similaires**

```apache
# Toutes les redirections permanentes ensemble
RewriteRule ^old-page-1$ /new-page-1 [R=301,L]
RewriteRule ^old-page-2$ /new-page-2 [R=301,L]
```

---

## Module ssl

Le module `mod_ssl` permet à Apache de gérer les connexions HTTPS sécurisées via le protocole SSL/TLS.

### Activation du module

```bash
# Activer mod_ssl
sudo a2enmod ssl

# Redémarrer Apache
sudo systemctl restart apache2
```

### Concepts SSL/TLS

> [!info] SSL vs TLS
> 
> - **SSL** (Secure Sockets Layer) : Protocole obsolète, vulnérable
> - **TLS** (Transport Layer Security) : Évolution sécurisée de SSL
> - Aujourd'hui, on parle de SSL par habitude, mais on utilise TLS

**Composants nécessaires pour HTTPS :**

1. **Certificat SSL** : Fichier `.crt` ou `.pem` contenant la clé publique
2. **Clé privée** : Fichier `.key` contenant la clé privée
3. **Chaîne de certificats** : Certificats intermédiaires (optionnel mais recommandé)

### Configuration d'un VirtualHost SSL

```apache
<VirtualHost *:443>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/html
    
    # Activer SSL pour ce VirtualHost
    SSLEngine on
    
    # Chemin vers le certificat SSL
    SSLCertificateFile /etc/ssl/certs/example.com.crt
    
    # Chemin vers la clé privée
    SSLCertificateKeyFile /etc/ssl/private/example.com.key
    
    # Chemin vers la chaîne de certificats (optionnel)
    SSLCertificateChainFile /etc/ssl/certs/chain.pem
    
    # Logs spécifiques
    ErrorLog ${APACHE_LOG_DIR}/example-ssl-error.log
    CustomLog ${APACHE_LOG_DIR}/example-ssl-access.log combined
</VirtualHost>
```

> [!warning] Port d'écoute N'oubliez pas de faire écouter Apache sur le port 443 :
> 
> ```apache
> Listen 443
> ```

### Configuration SSL sécurisée moderne

```apache
# Configuration globale SSL (dans apache2.conf ou ssl.conf)

# Désactiver SSLv2 et SSLv3 (vulnérables)
SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1

# Utiliser uniquement TLS 1.2 et 1.3
SSLProtocol TLSv1.2 TLSv1.3

# Suites de chiffrement recommandées (Mozilla Modern)
SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305

# Préférer les suites de chiffrement du serveur
SSLHonorCipherOrder on

# Optimisations de performance
SSLSessionCache shmcb:/var/cache/apache2/ssl_scache(512000)
SSLSessionCacheTimeout 300

# OCSP Stapling (vérification du certificat)
SSLUseStapling on
SSLStaplingCache shmcb:/var/cache/apache2/stapling_cache(128000)

# En-têtes de sécurité HSTS
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
```

> [!tip] Niveaux de configuration SSL (Mozilla)
> 
> - **Modern** : Sécurité maximale, compatibilité réduite (TLS 1.3 uniquement)
> - **Intermediate** : Bon équilibre sécurité/compatibilité (recommandé)
> - **Old** : Compatibilité maximale, sécurité réduite (non recommandé)

### Génération d'un certificat auto-signé (développement)

```bash
# Créer un certificat auto-signé valide 365 jours
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt

# Répondre aux questions :
# Country Name: FR
# State: Nouvelle-Aquitaine
# City: Bordeaux
# Organization: Mon Entreprise
# Common Name: example.com (IMPORTANT: votre nom de domaine)
```

> [!warning] Certificats auto-signés Les certificats auto-signés ne sont PAS reconnus par les navigateurs et déclenchent des avertissements. À utiliser **uniquement en développement local**.

### Let's Encrypt (certificats gratuits en production)

Let's Encrypt est l'autorité de certification recommandée pour obtenir des certificats SSL gratuits :

```bash
# Installer Certbot
sudo apt install certbot python3-certbot-apache

# Obtenir un certificat automatiquement
sudo certbot --apache -d example.com -d www.example.com

# Certbot configure automatiquement Apache et crée le VirtualHost SSL
```

> [!info] Renouvellement automatique
> 
> ```bash
> # Tester le renouvellement
> sudo certbot renew --dry-run
> 
> # Les certificats Let's Encrypt se renouvellent automatiquement
> # via une tâche cron créée par Certbot
> ```

### Redirection HTTP vers HTTPS

```apache
# VirtualHost HTTP (port 80)
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    
    # Rediriger tout le trafic vers HTTPS
    Redirect permanent / https://example.com/
    
    # Alternative avec mod_rewrite
    # RewriteEngine On
    # RewriteCond %{HTTPS} off
    # RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</VirtualHost>

# VirtualHost HTTPS (port 443)
<VirtualHost *:443>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/html
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/example.com.crt
    SSLCertificateKeyFile /etc/ssl/private/example.com.key
    
    # Configuration du site...
</VirtualHost>
```

### Test et vérification SSL

```bash
# Vérifier la syntaxe de la configuration SSL
sudo apache2ctl -t

# Tester la connexion SSL avec OpenSSL
openssl s_client -connect example.com:443 -servername example.com

# Vérifier les protocoles supportés
nmap --script ssl-enum-ciphers -p 443 example.com

# Tester en ligne (recommandé)
# https://www.ssllabs.com/ssltest/
```

### Résolution des problèmes courants

> [!warning] Erreurs fréquentes

**1. Certificat non reconnu**

```
SSL certificate problem: self signed certificate
```

- Cause : Certificat auto-signé ou chaîne incomplète
- Solution : Utiliser Let's Encrypt ou ajouter `SSLCertificateChainFile`

**2. Mixed Content Warning**

```
Mixed Content: The page was loaded over HTTPS but requested an insecure resource
```

- Cause : Ressources (CSS, JS, images) chargées en HTTP
- Solution : Forcer HTTPS pour toutes les ressources

**3. Permission denied sur les fichiers de certificat**

```
Permission denied: mod_ssl: Can't read private key
```

```bash
# Vérifier les permissions
sudo chmod 600 /etc/ssl/private/example.com.key
sudo chown root:root /etc/ssl/private/example.com.key
```

### En-têtes de sécurité HTTP

```apache
<VirtualHost *:443>
    # ... configuration SSL ...
    
    # HSTS - Forcer HTTPS pendant 1 an
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    
    # Protection contre le clickjacking
    Header always set X-Frame-Options "SAMEORIGIN"
    
    # Protection XSS
    Header always set X-XSS-Protection "1; mode=block"
    
    # Bloquer le MIME type sniffing
    Header always set X-Content-Type-Options "nosniff"
    
    # Content Security Policy
    Header always set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"
</VirtualHost>
```

> [!tip] Module headers requis Ces en-têtes nécessitent le module `mod_headers` :
> 
> ```bash
> sudo a2enmod headers
> sudo systemctl restart apache2
> ```

### Bonnes pratiques SSL

✅ **Utiliser TLS 1.2 minimum**

```apache
SSLProtocol TLSv1.2 TLSv1.3
```

✅ **Désactiver les suites de chiffrement faibles**

```apache
SSLCipherSuite HIGH:!aNULL:!MD5:!3DES
```

✅ **Mettre à jour régulièrement les certificats**

```bash
# Vérifier la date d'expiration
openssl x509 -in /etc/ssl/certs/example.com.crt -noout -dates
```

✅ **Activer OCSP Stapling**

```apache
SSLUseStapling on
SSLStaplingCache shmcb:/var/cache/apache2/stapling_cache(128000)
```

✅ **Séparer les clés privées**

```bash
# Permissions strictes sur les clés privées
sudo chmod 600 /etc/ssl/private/*.key
sudo chown root:root /etc/ssl/private/*.key
```

### Performance et optimisation

```apache
# Cache des sessions SSL
SSLSessionCache shmcb:/var/cache/apache2/ssl_scache(512000)
SSLSessionCacheTimeout 300

# Compression SSL (à désactiver si CRIME est une préoccupation)
SSLCompression off

# Limitation du nombre de renégociations
SSLInsecureRenegotiation off
```

---

## 🎯 Points clés à retenir

1. **Architecture modulaire** : Activez uniquement les modules nécessaires
2. **Gestion des modules** : Utilisez `a2enmod`/`a2dismod` sur Debian/Ubuntu
3. **mod_rewrite** : Maîtrisez les règles de réécriture pour des URLs propres
4. **mod_ssl** : Configurez HTTPS avec TLS 1.2+ et des certificats valides
5. **Sécurité** : Désactivez les protocoles obsolètes et utilisez des en-têtes de sécurité

> [!tip] Commandes essentielles à retenir
> 
> ```bash
> # Gestion des modules
> sudo a2enmod rewrite ssl headers
> sudo a2dismod autoindex
> 
> # Vérification
> apache2ctl -M
> apache2ctl -t
> 
> # Redémarrage
> sudo systemctl restart apache2
> ```