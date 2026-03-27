

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

La sécurisation d'Apache est une étape cruciale dans le durcissement d'un serveur LAMP. Par défaut, Apache expose des informations qui peuvent être utilisées par des attaquants pour identifier des vulnérabilités connues. Cette partie du cours couvre les configurations essentielles pour réduire la surface d'attaque de votre serveur web.

> [!info] Principe de sécurité La règle fondamentale est de **minimiser l'exposition d'informations** sur votre système. Moins un attaquant en sait sur votre configuration, plus il lui sera difficile de cibler des exploits spécifiques.

---

## 🕵️ Masquage de la version Apache {#masquage-version}

### Pourquoi masquer la version ?

Par défaut, Apache divulgue des informations détaillées sur sa version et les modules installés dans :

- Les en-têtes HTTP de réponse
- Les pages d'erreur (404, 403, 500, etc.)

**Exemple d'en-tête par défaut :**

```
Server: Apache/2.4.41 (Ubuntu) OpenSSL/1.1.1f PHP/7.4.3
```

Ces informations permettent à un attaquant de :

- Identifier la version exacte d'Apache
- Connaître le système d'exploitation
- Lister les modules actifs
- Chercher des exploits ciblés dans des bases de données comme CVE

### Les directives de configuration

Apache propose deux directives complémentaires pour contrôler l'affichage des informations :

#### 1. **ServerTokens**

Contrôle les informations envoyées dans l'en-tête HTTP `Server`.

|Valeur|Information affichée|Exemple|
|---|---|---|
|`Prod`|Apache seulement|`Server: Apache`|
|`Major`|Version majeure|`Server: Apache/2`|
|`Minor`|Version mineure|`Server: Apache/2.4`|
|`Min`|Version minimale|`Server: Apache/2.4.41`|
|`OS`|+ Système d'exploitation|`Server: Apache/2.4.41 (Ubuntu)`|
|`Full`|Toutes les infos (défaut)|`Server: Apache/2.4.41 (Ubuntu) OpenSSL/1.1.1f`|

#### 2. **ServerSignature**

Contrôle l'affichage du pied de page dans les pages d'erreur générées par Apache.

|Valeur|Description|
|---|---|
|`On`|Affiche la version complète (défaut)|
|`Off`|N'affiche rien|
|`EMail`|Affiche version + email du ServerAdmin|

### Configuration recommandée

> [!example] Configuration sécurisée

**Fichier à modifier :** `/etc/apache2/conf-available/security.conf` (Debian/Ubuntu) ou `/etc/httpd/conf/httpd.conf` (RedHat/CentOS)

```apache
# Masquer au maximum les informations du serveur
ServerTokens Prod
ServerSignature Off
```

**Application des modifications :**

```bash
# Vérifier la syntaxe
sudo apache2ctl configtest

# Recharger Apache
sudo systemctl reload apache2
```

### Vérification

Testez avec `curl` pour voir l'en-tête `Server` :

```bash
# Avant la modification
curl -I http://votre-serveur.com
# Server: Apache/2.4.41 (Ubuntu) OpenSSL/1.1.1f PHP/7.4.3

# Après la modification
curl -I http://votre-serveur.com
# Server: Apache
```

> [!tip] Astuce avancée Vous pouvez même personnaliser complètement l'en-tête `Server` en recompilant Apache avec l'option `--with-server-header` ou en utilisant le module `mod_security` pour le modifier dynamiquement.

> [!warning] Attention Le masquage des informations n'est **pas une mesure de sécurité en soi**, mais une couche supplémentaire qui complique la reconnaissance du système. Il faut toujours maintenir Apache à jour !

---

## 📂 Désactivation du listing de répertoires {#listing-repertoires}

### Le problème du listing automatique

Lorsqu'un répertoire ne contient pas de fichier index (index.html, index.php), Apache affiche par défaut la liste complète des fichiers et sous-répertoires. C'est la directive `Options Indexes` qui active ce comportement.

**Risques :**

- Exposition de fichiers sensibles (backups, configs, logs)
- Révélation de la structure du site
- Accès à des fichiers oubliés ou temporaires
- Divulgation d'informations sur l'organisation du code

### Désactivation globale

> [!example] Configuration recommandée

**Fichier :** `/etc/apache2/apache2.conf` ou `/etc/httpd/conf/httpd.conf`

```apache
# Configuration pour le répertoire racine
<Directory /var/www/>
    # Désactiver le listing de répertoires
    Options -Indexes
    
    # Autoriser les .htaccess (optionnel selon vos besoins)
    AllowOverride All
    
    # Contrôle d'accès Apache 2.4+
    Require all granted
</Directory>
```

**Explication des options :**

- `Options -Indexes` : Le signe `-` désactive l'option Indexes
- `Options +FollowSymLinks` : Permet de suivre les liens symboliques (souvent nécessaire)
- `Options None` : Désactive toutes les options

### Désactivation pour un Virtual Host spécifique

```apache
<VirtualHost *:80>
    ServerName example.com
    DocumentRoot /var/www/example
    
    <Directory /var/www/example>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
```

### Désactivation via .htaccess

Si vous ne pouvez pas modifier la configuration principale :

```apache
# Fichier: /var/www/html/.htaccess
Options -Indexes
```

> [!warning] Piège courant Si vous utilisez plusieurs directives `Options`, attention à la combinaison :
> 
> ```apache
> # ❌ MAUVAIS : La dernière directive écrase la première
> Options -Indexes
> Options +FollowSymLinks
> 
> # ✅ BON : Combiner sur une seule ligne
> Options -Indexes +FollowSymLinks
> ```

### Personnalisation de la page d'erreur

Au lieu d'afficher une liste ou une erreur 403, redirigez vers une page personnalisée :

```apache
# Redirection des erreurs 403 (accès refusé)
ErrorDocument 403 /erreur403.html

<Directory /var/www/html/uploads>
    Options -Indexes
    ErrorDocument 403 "Accès interdit à ce répertoire"
</Directory>
```

### Test de la configuration

```bash
# Créer un répertoire de test sans fichier index
sudo mkdir /var/www/html/test
sudo touch /var/www/html/test/fichier1.txt
sudo touch /var/www/html/test/fichier2.txt

# Recharger Apache
sudo systemctl reload apache2

# Tester dans le navigateur
# http://votre-serveur.com/test/
# Devrait afficher une erreur 403 au lieu de lister les fichiers
```

> [!tip] Bonne pratique Même avec `Options -Indexes`, créez toujours des fichiers `index.html` vides dans les répertoires sensibles comme `/uploads` ou `/backups` pour une défense en profondeur.

---

## 🛡️ Protection des fichiers sensibles {#fichiers-sensibles}

### Fichiers à protéger absolument

Certains fichiers ne doivent **jamais** être accessibles via le web :

|Type de fichier|Exemples|Risque|
|---|---|---|
|Configuration|`.htaccess`, `.htpasswd`, `config.php`|Mots de passe, clés API|
|Contrôle de version|`.git/`, `.svn/`, `.hg/`|Code source complet|
|Environnement|`.env`, `.env.local`|Credentials de base de données|
|Backups|`*.sql`, `*.bak`, `*.old`, `*~`|Données sensibles|
|Logs|`error.log`, `access.log`|Informations système|
|Documentation|`README.md`, `INSTALL.txt`|Détails techniques|

### Protection des fichiers .htaccess et .htpasswd

> [!example] Configuration de base

**Fichier :** `/etc/apache2/apache2.conf`

```apache
# Bloquer l'accès aux fichiers .ht*
<FilesMatch "^\.ht">
    Require all denied
</FilesMatch>
```

**Version alternative plus explicite :**

```apache
# Protection des fichiers de configuration Apache
<Files ".htaccess">
    Require all denied
</Files>

<Files ".htpasswd">
    Require all denied
</Files>
```

### Protection des répertoires Git et SVN

Les répertoires de contrôle de version contiennent tout l'historique du code source !

```apache
# Bloquer tous les répertoires cachés (commençant par .)
<DirectoryMatch "^\.|\/\.">
    Require all denied
</DirectoryMatch>

# Alternative : bloquer spécifiquement .git et .svn
<DirectoryMatch "^\.git|^\.svn">
    Require all denied
</DirectoryMatch>
```

### Protection des fichiers de configuration et environnement

```apache
# Bloquer les fichiers de configuration courants
<FilesMatch "\.(env|ini|log|conf|config|bak|sql|old|save|swp)$">
    Require all denied
</FilesMatch>

# Protection spécifique pour les fichiers d'environnement
<Files ".env">
    Require all denied
</Files>

<Files "config.php">
    Require all denied
</Files>
```

### Protection des backups et fichiers temporaires

```apache
# Bloquer les extensions de backup communes
<FilesMatch "\.(bak|backup|old|orig|save|swo|swp|tmp|temp)$">
    Require all denied
</FilesMatch>

# Bloquer les fichiers se terminant par ~
<FilesMatch "~$">
    Require all denied
</FilesMatch>

# Bloquer les dumps SQL
<FilesMatch "\.sql$">
    Require all denied
</FilesMatch>
```

### Protection des fichiers README et documentation

```apache
# Bloquer les fichiers de documentation
<FilesMatch "^(README|INSTALL|LICENSE|CHANGELOG|CONTRIBUTING)">
    Require all denied
</FilesMatch>
```

### Configuration complète recommandée

> [!example] Configuration de production

Créez un fichier dédié pour centraliser ces règles :

**Fichier :** `/etc/apache2/conf-available/file-protection.conf`

```apache
# =====================================
# Protection des fichiers sensibles
# =====================================

# 1. Fichiers de configuration Apache
<FilesMatch "^\.ht">
    Require all denied
</FilesMatch>

# 2. Répertoires de contrôle de version
<DirectoryMatch "/\.(git|svn|hg|bzr)">
    Require all denied
</DirectoryMatch>

# 3. Fichiers d'environnement et configuration
<FilesMatch "\.(env|ini|conf|config)$">
    Require all denied
</FilesMatch>

# 4. Backups et fichiers temporaires
<FilesMatch "\.(bak|backup|old|orig|save|swo|swp|tmp|~)$">
    Require all denied
</FilesMatch>

# 5. Dumps de base de données
<FilesMatch "\.(sql|sqlite|db)$">
    Require all denied
</FilesMatch>

# 6. Fichiers de logs
<FilesMatch "\.(log)$">
    Require all denied
</FilesMatch>

# 7. Documentation technique
<FilesMatch "^(README|INSTALL|LICENSE|CHANGELOG|CONTRIBUTING|TODO)">
    Require all denied
</FilesMatch>

# 8. Fichiers cachés en général
<FilesMatch "^\.">
    Require all denied
</FilesMatch>
```

**Activation de la configuration :**

```bash
# Activer le fichier de configuration
sudo a2enconf file-protection

# Tester la syntaxe
sudo apache2ctl configtest

# Recharger Apache
sudo systemctl reload apache2
```

### Protection via .htaccess (niveau répertoire)

Si vous ne pouvez pas modifier la configuration globale :

```apache
# Fichier: /var/www/html/.htaccess

# Bloquer .git
RedirectMatch 404 /\.git

# Bloquer fichiers sensibles
<FilesMatch "\.(env|bak|sql|log)$">
    Require all denied
</FilesMatch>
```

> [!warning] Attention aux performances Les directives `<FilesMatch>` utilisent des expressions régulières et sont évaluées pour chaque requête. Sur des sites à très fort trafic, préférez des règles plus spécifiques plutôt que des regex complexes.

> [!tip] Défense en profondeur La meilleure protection est de **ne jamais placer ces fichiers dans le DocumentRoot**. Stockez les fichiers sensibles en dehors du répertoire web :
> 
> ```
> /var/www/example.com/
> ├── public/          # DocumentRoot (accessible web)
> │   └── index.php
> ├── config/          # Hors DocumentRoot
> │   └── database.php
> └── .env             # Hors DocumentRoot
> ```

### Test de la configuration

```bash
# Créer des fichiers de test
sudo touch /var/www/html/.git/config
sudo touch /var/www/html/.env
sudo touch /var/www/html/backup.sql

# Tester l'accès (devrait retourner 403)
curl -I http://votre-serveur.com/.git/config
curl -I http://votre-serveur.com/.env
curl -I http://votre-serveur.com/backup.sql
```

---

## 🚦 Limitation des méthodes HTTP {#methodes-http}

### Comprendre les méthodes HTTP

HTTP définit plusieurs méthodes (verbes) pour interagir avec un serveur :

|Méthode|Usage|Risque si non contrôlée|
|---|---|---|
|`GET`|Récupérer une ressource|✅ Nécessaire (lecture)|
|`POST`|Envoyer des données|✅ Nécessaire (formulaires)|
|`HEAD`|Obtenir les en-têtes|⚠️ Peut révéler des infos|
|`OPTIONS`|Lister les méthodes autorisées|⚠️ Reconnaissance|
|`PUT`|Uploader/remplacer un fichier|❌ Upload non autorisé|
|`DELETE`|Supprimer une ressource|❌ Suppression non autorisée|
|`TRACE`|Echo de la requête|❌ XST (Cross-Site Tracing)|
|`CONNECT`|Établir un tunnel|❌ Proxy non autorisé|
|`PATCH`|Modification partielle|⚠️ Selon l'application|

### Pourquoi limiter les méthodes ?

**Risques liés aux méthodes non restreintes :**

1. **PUT / DELETE** : Permettent de modifier ou supprimer des fichiers sur le serveur
2. **TRACE** : Vulnérabilité XST (Cross-Site Tracing) permettant de voler des cookies HttpOnly
3. **OPTIONS** : Révèle les méthodes autorisées (reconnaissance)
4. **CONNECT** : Peut transformer votre serveur en proxy

> [!info] Principe du moindre privilège N'autorisez que les méthodes HTTP strictement nécessaires au fonctionnement de votre application. Par défaut, GET et POST suffisent pour 95% des sites web classiques.

### Configuration globale : Autoriser uniquement GET et POST

> [!example] Configuration recommandée pour un site classique

**Fichier :** `/etc/apache2/apache2.conf` ou dans votre VirtualHost

```apache
# Limiter aux méthodes essentielles
<Directory /var/www/>
    <LimitExcept GET POST HEAD>
        Require all denied
    </LimitExcept>
</Directory>
```

**Explication :**

- `<LimitExcept GET POST HEAD>` : Définit les méthodes autorisées
- `Require all denied` : Refuse toutes les autres méthodes
- `HEAD` est souvent inclus car utilisé pour vérifier l'existence d'une ressource

### Désactivation complète de méthodes dangereuses

Pour une sécurité maximale, bloquez explicitement les méthodes sensibles :

```apache
# Bloquer les méthodes dangereuses
<Directory /var/www/>
    # Méthode 1 : Utiliser LimitExcept (recommandé)
    <LimitExcept GET POST HEAD>
        Require all denied
    </LimitExcept>
</Directory>

# OU

# Méthode 2 : Bloquer explicitement (plus verbeux)
<Directory /var/www/>
    <Limit PUT DELETE TRACE CONNECT OPTIONS PATCH>
        Require all denied
    </Limit>
</Directory>
```

### Désactivation spécifique de TRACE (XST)

La méthode TRACE peut être exploitée pour voler des cookies HttpOnly via une attaque XST.

```apache
# Désactiver globalement la méthode TRACE
TraceEnable Off
```

> [!warning] TraceEnable Cette directive doit être placée au niveau global (hors des balises `<Directory>`) ou dans un VirtualHost.

**Placement correct :**

```apache
# Dans /etc/apache2/conf-available/security.conf
ServerTokens Prod
ServerSignature Off
TraceEnable Off
```

### Configuration pour une API REST

Si vous développez une API REST, vous aurez besoin de méthodes supplémentaires :

```apache
<Directory /var/www/api/>
    # API REST : autoriser les méthodes CRUD complètes
    <LimitExcept GET POST PUT DELETE PATCH OPTIONS>
        Require all denied
    </LimitExcept>
    
    # Autoriser OPTIONS pour CORS
    # (nécessaire pour les requêtes cross-origin)
</Directory>
```

### Configuration par Virtual Host

Différents sites peuvent avoir des besoins différents :

```apache
# Site web classique (blog, vitrine)
<VirtualHost *:80>
    ServerName www.example.com
    DocumentRoot /var/www/example
    
    <Directory /var/www/example>
        <LimitExcept GET POST HEAD>
            Require all denied
        </LimitExcept>
    </Directory>
</VirtualHost>

# API REST
<VirtualHost *:80>
    ServerName api.example.com
    DocumentRoot /var/www/api
    
    <Directory /var/www/api>
        <LimitExcept GET POST PUT DELETE PATCH OPTIONS>
            Require all denied
        </LimitExcept>
    </Directory>
</VirtualHost>
```

### Protection avancée avec mod_rewrite

Une approche alternative utilise mod_rewrite pour rejeter les méthodes non autorisées :

```apache
# Activer mod_rewrite
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Bloquer toutes les méthodes sauf GET, POST, HEAD
    RewriteCond %{REQUEST_METHOD} !^(GET|POST|HEAD)$
    RewriteRule .* - [F,L]
</IfModule>
```

**Avantage :** Plus flexible, permet des règles conditionnelles complexes  
**Inconvénient :** Moins performant que `<LimitExcept>` natif

### Configuration complète recommandée

> [!example] Configuration de production

**Fichier :** `/etc/apache2/conf-available/http-methods.conf`

```apache
# =====================================
# Limitation des méthodes HTTP
# =====================================

# Désactiver TRACE globalement (protection XST)
TraceEnable Off

# Limitation par défaut pour tous les répertoires web
<Directory /var/www/>
    # Autoriser uniquement les méthodes essentielles
    <LimitExcept GET POST HEAD>
        Require all denied
    </LimitExcept>
</Directory>

# Configuration spécifique pour les uploads
<Directory /var/www/html/uploads/>
    # Pas d'exécution de scripts
    Options -ExecCGI
    AddHandler cgi-script .php .pl .py .jsp .asp .sh .cgi
    
    # Seulement lecture
    <LimitExcept GET HEAD>
        Require all denied
    </LimitExcept>
</Directory>
```

**Activation :**

```bash
sudo a2enconf http-methods
sudo apache2ctl configtest
sudo systemctl reload apache2
```

### Test de la configuration

Utilisez `curl` pour tester les différentes méthodes :

```bash
# Test GET (devrait fonctionner)
curl -X GET http://votre-serveur.com/

# Test POST (devrait fonctionner)
curl -X POST http://votre-serveur.com/

# Test PUT (devrait retourner 405 ou 403)
curl -X PUT http://votre-serveur.com/test.txt -d "contenu"

# Test DELETE (devrait retourner 405 ou 403)
curl -X DELETE http://votre-serveur.com/test.txt

# Test TRACE (devrait retourner 405)
curl -X TRACE http://votre-serveur.com/

# Test OPTIONS (selon config)
curl -X OPTIONS http://votre-serveur.com/
```

### Test automatisé avec script

```bash
#!/bin/bash
# test-http-methods.sh

URL="http://votre-serveur.com"
METHODS=("GET" "POST" "PUT" "DELETE" "TRACE" "OPTIONS" "CONNECT" "PATCH")

echo "Test des méthodes HTTP sur $URL"
echo "================================"

for METHOD in "${METHODS[@]}"; do
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X $METHOD $URL)
    echo "$METHOD : $RESPONSE"
done
```

**Résultat attendu :**

```
GET : 200
POST : 200 ou 405 (selon présence de formulaire)
PUT : 405 ou 403
DELETE : 405 ou 403
TRACE : 405
OPTIONS : 405 ou 200 (si API REST)
CONNECT : 405
PATCH : 405 ou 403
```

> [!tip] Codes de réponse HTTP
> 
> - **200** : Méthode autorisée et réussie
> - **405 Method Not Allowed** : Méthode non autorisée (bon signe !)
> - **403 Forbidden** : Accès interdit (également acceptable)
> - **501 Not Implemented** : Méthode non implémentée

> [!warning] Piège avec les applications PHP Certaines applications PHP modernes (frameworks) gèrent elles-mêmes les méthodes HTTP via le routing. Dans ce cas :
> 
> - Apache peut autoriser toutes les méthodes
> - L'application PHP filtre ensuite ce qui est vraiment autorisé
> 
> Néanmoins, il est recommandé de limiter au niveau Apache comme première ligne de défense.

### Cas particulier : WebDAV

Si vous utilisez WebDAV (partage de fichiers), vous devrez autoriser des méthodes supplémentaires :

```apache
<Directory /var/www/webdav/>
    # WebDAV nécessite ces méthodes
    <LimitExcept GET POST HEAD PUT DELETE PROPFIND PROPPATCH MKCOL COPY MOVE LOCK UNLOCK OPTIONS>
        Require all denied
    </LimitExcept>
    
    # Authentification obligatoire pour WebDAV
    AuthType Basic
    AuthName "WebDAV Restricted"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Directory>
```

---

## 📊 Récapitulatif des configurations

> [!tip] Checklist de sécurisation Apache

### Fichier principal : `/etc/apache2/conf-available/security.conf`

```apache
# Masquage des informations
ServerTokens Prod
ServerSignature Off

# Désactivation de TRACE
TraceEnable Off

# Désactivation du listing de répertoires (peut être dans apache2.conf)
<Directory /var/www/>
    Options -Indexes +FollowSymLinks
    AllowOverride None
    Require all granted
    
    # Limitation des méthodes HTTP
    <LimitExcept GET POST HEAD>
        Require all denied
    </LimitExcept>
</Directory>

# Protection des fichiers sensibles
<FilesMatch "^\.ht">
    Require all denied
</FilesMatch>

<DirectoryMatch "/\.(git|svn)">
    Require all denied
</DirectoryMatch>

<FilesMatch "\.(env|bak|sql|log|ini|conf)$">
    Require all denied
</FilesMatch>
```

### Activation et vérification

```bash
# Activer la configuration de sécurité
sudo a2enconf security

# Vérifier la syntaxe
sudo apache2ctl configtest

# Recharger Apache
sudo systemctl reload apache2

# Vérifier les en-têtes
curl -I http://votre-serveur.com
```

> [!info] Défense en profondeur Ces configurations constituent la **première couche** de sécurité. Elles doivent être complétées par :
> 
> - Mises à jour régulières d'Apache et des modules
> - Configuration HTTPS avec TLS moderne
> - Pare-feu applicatif (ModSecurity)
> - Surveillance des logs
> - Principe du moindre privilège pour les permissions fichiers

---

## 🎓 Points clés à retenir

1. **Masquage de version** : `ServerTokens Prod` + `ServerSignature Off` réduisent l'exposition d'informations
2. **Listing de répertoires** : `Options -Indexes` empêche l'énumération des fichiers
3. **Fichiers sensibles** : Bloquez `.git/`, `.env`, backups et fichiers de configuration
4. **Méthodes HTTP** : N'autorisez que `GET POST HEAD` pour un site classique, désactivez `TRACE`
5. **Tests** : Vérifiez chaque configuration avec `curl` et les outils de test

> [!warning] Maintenance continue La sécurité n'est pas un état figé mais un processus continu. Auditez régulièrement votre configuration Apache et surveillez les nouvelles vulnérabilités.