

## 📚 Table des matières

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

## 🔐 Principe du chiffrement SSL/TLS

### Qu'est-ce que SSL/TLS ?

**SSL** (Secure Sockets Layer) et **TLS** (Transport Layer Security) sont des protocoles cryptographiques qui sécurisent les communications sur Internet. TLS est le successeur de SSL, mais on utilise encore souvent le terme "SSL" par habitude.

> [!info] Différence SSL vs TLS
> 
> - **SSL** : Ancienne version (SSL 2.0, SSL 3.0) - **obsolète et non sécurisé**
> - **TLS** : Version moderne (TLS 1.2, TLS 1.3) - **recommandé**
> - On parle souvent de "certificat SSL" mais on utilise en réalité TLS

### Pourquoi utiliser HTTPS ?

|Avantage|Description|
|---|---|
|🔒 **Confidentialité**|Les données sont chiffrées entre le client et le serveur|
|✅ **Intégrité**|Les données ne peuvent pas être modifiées en transit|
|🎯 **Authentification**|Le certificat prouve l'identité du serveur|
|📈 **SEO**|Google favorise les sites HTTPS dans le classement|
|🚀 **HTTP/2**|Nécessite HTTPS pour fonctionner|
|🛡️ **Confiance**|Les navigateurs marquent HTTP comme "non sécurisé"|

### Comment fonctionne le chiffrement TLS ?

Le processus se déroule en plusieurs étapes appelées **TLS Handshake** :

```
Client                                    Serveur
  |                                         |
  |-------- 1. Client Hello --------------->|
  |    (versions TLS supportées, ciphers)   |
  |                                         |
  |<------- 2. Server Hello ----------------|
  |    (version TLS choisie, certificat)    |
  |                                         |
  |-------- 3. Vérification cert ---------->|
  |    (validation du certificat)           |
  |                                         |
  |<------- 4. Échange de clés -------------|
  |    (génération clé de session)          |
  |                                         |
  |======== Communication chiffrée =========|
```

> [!example] Étapes détaillées
> 
> 1. **Client Hello** : Le client propose les versions TLS et algorithmes qu'il supporte
> 2. **Server Hello** : Le serveur choisit la meilleure version TLS et envoie son certificat
> 3. **Vérification** : Le client vérifie que le certificat est valide et signé par une autorité de confiance
> 4. **Échange de clés** : Client et serveur génèrent une clé de session symétrique
> 5. **Communication** : Toutes les données sont chiffrées avec cette clé de session

### Les composants d'un certificat SSL/TLS

Un certificat contient plusieurs informations :

```
Certificat SSL/TLS
├── Domaine(s) concerné(s)
├── Organisation (optionnel)
├── Clé publique
├── Date de validité (début et fin)
├── Algorithme de signature
└── Signature de l'autorité de certification (CA)
```

> [!warning] Durée de validité Les certificats Let's Encrypt sont valides **90 jours**. Cela force le renouvellement régulier et améliore la sécurité, mais nécessite une automatisation.

### Types de certificats

|Type|Validation|Usage|Prix|
|---|---|---|---|
|**DV** (Domain Validation)|Propriété du domaine|Sites web classiques|Gratuit (Let's Encrypt)|
|**OV** (Organization Validation)|Identité de l'organisation|Sites professionnels|Payant|
|**EV** (Extended Validation)|Validation approfondie|Banques, e-commerce|Cher|

> [!tip] Quel certificat choisir ? Pour la majorité des sites web, un certificat **DV de Let's Encrypt est largement suffisant** et gratuit. Les certificats OV/EV n'apportent plus de bénéfices visuels dans les navigateurs modernes.

---

## 🌐 Certificats Let's Encrypt

### Présentation de Let's Encrypt

**Let's Encrypt** est une autorité de certification (CA) gratuite, automatisée et ouverte, créée en 2016 par l'Internet Security Research Group (ISRG).

> [!info] Philosophie de Let's Encrypt
> 
> - **Gratuit** : Aucun coût pour obtenir un certificat
> - **Automatisé** : Délivrance et renouvellement automatiques
> - **Ouvert** : Protocole ACME standard et open source
> - **Transparent** : Tous les certificats émis sont publics
> - **Sécurisé** : Bonnes pratiques de sécurité appliquées

### Le protocole ACME

**ACME** (Automatic Certificate Management Environment) est le protocole utilisé par Let's Encrypt pour automatiser l'émission et le renouvellement des certificats.

Processus de validation du domaine :

```
1. Demande de certificat
   ├── Votre serveur → Serveur Let's Encrypt
   └── "Je veux un certificat pour example.com"

2. Challenge (défi)
   ├── Let's Encrypt → Votre serveur
   └── "Prouve que tu contrôles ce domaine"

3. Réponse au challenge
   ├── Votre serveur place un fichier/enregistrement
   └── Let's Encrypt vérifie la présence

4. Émission du certificat
   ├── Validation réussie ✓
   └── Certificat délivré
```

### Méthodes de validation (challenges)

Let's Encrypt propose plusieurs méthodes pour prouver que vous contrôlez le domaine :

|Méthode|Description|Cas d'usage|
|---|---|---|
|**HTTP-01**|Fichier placé sur le serveur web|Serveur web accessible publiquement|
|**DNS-01**|Enregistrement TXT dans le DNS|Certificats wildcard, serveurs internes|
|**TLS-ALPN-01**|Validation via TLS|Ports 80/443 utilisés, environnements complexes|

> [!example] Challenge HTTP-01 en détail
> 
> ```bash
> # Let's Encrypt demande de placer un fichier ici :
> http://example.com/.well-known/acme-challenge/TOKEN
> 
> # Le fichier contient une clé de validation
> # Let's Encrypt fait une requête HTTP pour le vérifier
> # Si le fichier est présent et correct → validation réussie
> ```

> [!tip] Quelle méthode choisir ?
> 
> - **HTTP-01** : Méthode par défaut, simple et rapide pour la plupart des cas
> - **DNS-01** : Nécessaire pour les certificats wildcard (*.example.com) ou si le port 80 n'est pas accessible
> - **TLS-ALPN-01** : Rarement utilisé, pour des cas très spécifiques

### Limites de Let's Encrypt

> [!warning] Quotas à connaître
> 
> - **50 certificats par domaine enregistré** par semaine
> - **5 certificats identiques** (mêmes domaines) par semaine
> - **300 comptes** par IP et par 3 heures
> - **10 domaines** en échec de validation par compte et par heure
> 
> Ces limites sont généralement largement suffisantes pour un usage normal.

### Certificats wildcard

Let's Encrypt permet de créer des certificats **wildcard** qui couvrent tous les sous-domaines :

```
*.example.com → valide pour :
- blog.example.com
- shop.example.com
- api.example.com
- etc.

Mais PAS pour :
- example.com (domaine racine)
- sub.blog.example.com (sous-sous-domaine)
```

> [!info] Wildcard et validation DNS Les certificats wildcard nécessitent **obligatoirement** la validation **DNS-01**, car il n'est pas possible de placer un fichier sur tous les sous-domaines possibles.

---

## 🛠️ Installation de Certbot

### Qu'est-ce que Certbot ?

**Certbot** est le client ACME officiel recommandé par Let's Encrypt. C'est un outil en ligne de commande qui automatise l'obtention et le renouvellement des certificats.

> [!info] Alternatives à Certbot Il existe d'autres clients ACME (acme.sh, dehydrated, etc.) mais Certbot reste le plus populaire et le mieux supporté pour Apache et Nginx.

### Installation sur Debian/Ubuntu

```bash
# Mise à jour des paquets
sudo apt update

# Installation de Certbot et du plugin Apache
sudo apt install certbot python3-certbot-apache -y

# Vérification de l'installation
certbot --version
```

> [!example] Sortie attendue
> 
> ```
> certbot 2.x.x
> ```

### Installation sur CentOS/RHEL/Rocky Linux

```bash
# Installation d'EPEL (Extra Packages for Enterprise Linux)
sudo dnf install epel-release -y

# Installation de Certbot
sudo dnf install certbot python3-certbot-apache -y

# Vérification
certbot --version
```

### Plugins Certbot disponibles

Certbot utilise des **plugins** pour s'intégrer avec différents serveurs web :

|Plugin|Description|Installation|
|---|---|---|
|`apache`|Configuration automatique d'Apache|`python3-certbot-apache`|
|`nginx`|Configuration automatique de Nginx|`python3-certbot-nginx`|
|`standalone`|Serveur web temporaire|Inclus par défaut|
|`webroot`|Utilise un répertoire existant|Inclus par défaut|
|`dns-*`|Validation DNS (plusieurs fournisseurs)|Plugins spécifiques|

### Préparation avant l'installation d'un certificat

> [!warning] Vérifications préalables Avant de demander un certificat, assurez-vous que :
> 
> 1. ✅ Votre domaine pointe vers votre serveur (enregistrement DNS A ou AAAA)
> 2. ✅ Apache est installé et fonctionne
> 3. ✅ Le VirtualHost pour votre domaine est configuré
> 4. ✅ Le port 80 est ouvert et accessible depuis Internet
> 5. ✅ Le ServerName est correct dans la configuration Apache

```bash
# Vérifier que le domaine pointe vers le serveur
dig +short example.com
# Doit retourner l'IP publique de votre serveur

# Vérifier qu'Apache écoute sur le port 80
sudo netstat -tlnp | grep :80

# Vérifier que le VirtualHost répond
curl -I http://example.com
```

> [!tip] Test de connectivité Vous pouvez utiliser des outils en ligne comme :
> 
> - https://letsdebug.net/ → Diagnostique les problèmes potentiels
> - https://www.whatsmydns.net/ → Vérifie la propagation DNS

---

## 🎯 Configuration SSL dans Apache

### Obtention du premier certificat

#### Méthode automatique (recommandée)

La méthode la plus simple utilise le plugin Apache qui configure tout automatiquement :

```bash
# Obtenir et installer le certificat automatiquement
sudo certbot --apache -d example.com -d www.example.com

# Avec une adresse email pour les notifications
sudo certbot --apache -d example.com -d www.example.com --email admin@example.com --agree-tos
```

> [!example] Options expliquées
> 
> - `--apache` : Utilise le plugin Apache pour la configuration automatique
> - `-d example.com` : Spécifie le(s) domaine(s) pour le certificat
> - `--email` : Adresse pour les notifications de renouvellement
> - `--agree-tos` : Accepte automatiquement les conditions d'utilisation
> - `--non-interactive` : Mode non interactif (pour scripts)

Certbot vous posera quelques questions :

```
1. Entrez votre email : admin@example.com
2. Acceptez-vous les conditions : (Y)es
3. Voulez-vous partager votre email avec EFF : (Y)es/(N)o
4. Rediriger HTTP vers HTTPS : 1: No redirect / 2: Redirect (recommandé)
```

> [!tip] Mode non interactif Pour automatiser complètement :
> 
> ```bash
> sudo certbot --apache -d example.com -d www.example.com \
>   --email admin@example.com \
>   --agree-tos \
>   --no-eff-email \
>   --redirect \
>   --non-interactive
> ```

#### Méthode webroot (manuelle)

Si vous préférez configurer Apache manuellement :

```bash
# Obtenir le certificat sans modification d'Apache
sudo certbot certonly --webroot -w /var/www/html -d example.com -d www.example.com
```

> [!info] Quand utiliser webroot ?
> 
> - Vous voulez contrôler manuellement la configuration Apache
> - Vous avez une configuration Apache complexe
> - Vous gérez plusieurs sites avec des configurations différentes

### Fichiers du certificat

Après l'obtention, Certbot place les certificats dans `/etc/letsencrypt/` :

```
/etc/letsencrypt/
├── live/
│   └── example.com/
│       ├── fullchain.pem    → Certificat + chaîne intermédiaire
│       ├── privkey.pem      → Clé privée
│       ├── cert.pem         → Certificat seul
│       └── chain.pem        → Chaîne intermédiaire
├── archive/
│   └── example.com/
│       ├── fullchain1.pem
│       ├── privkey1.pem
│       └── ...
└── renewal/
    └── example.com.conf
```

> [!warning] Permissions des fichiers
> 
> - Les certificats dans `live/` sont des **liens symboliques** vers `archive/`
> - La clé privée (`privkey.pem`) a les permissions **600** (lecture seule pour root)
> - **Ne modifiez jamais** directement les fichiers dans ces répertoires

### Configuration manuelle du VirtualHost HTTPS

Si vous utilisez la méthode webroot, configurez Apache manuellement :

```bash
# Activer le module SSL
sudo a2enmod ssl

# Créer/éditer le VirtualHost HTTPS
sudo nano /etc/apache2/sites-available/example.com-ssl.conf
```

```apache
<VirtualHost *:443>
    # Informations de base
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/example.com/public_html
    
    # Logs
    ErrorLog ${APACHE_LOG_DIR}/example.com-error.log
    CustomLog ${APACHE_LOG_DIR}/example.com-access.log combined
    
    # Configuration SSL/TLS
    SSLEngine on
    
    # Chemins des certificats
    SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
    
    # Protocoles SSL/TLS autorisés (désactive les anciennes versions)
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
    
    # Suites cryptographiques sécurisées
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off
    
    # Options de performance
    SSLSessionTickets off
    
    # Configuration HSTS (optionnel mais recommandé)
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    
    # Répertoire du site
    <Directory /var/www/example.com/public_html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

> [!info] Directives SSL expliquées
> 
> - **SSLEngine on** : Active SSL/TLS pour ce VirtualHost
> - **SSLCertificateFile** : Chemin vers le certificat complet (avec chaîne)
> - **SSLCertificateKeyFile** : Chemin vers la clé privée
> - **SSLProtocol** : N'autorise que TLS 1.2 et 1.3 (sécurisé)
> - **SSLCipherSuite** : Liste des algorithmes de chiffrement acceptés
> - **SSLHonorCipherOrder** : Laisse le client choisir le meilleur cipher

```bash
# Activer le site HTTPS
sudo a2ensite example.com-ssl.conf

# Vérifier la configuration
sudo apache2ctl configtest

# Recharger Apache
sudo systemctl reload apache2
```

### Configuration SSL optimale

Pour une sécurité et des performances maximales, ajoutez ces directives dans `/etc/apache2/mods-available/ssl.conf` :

```apache
# Configuration globale SSL/TLS
<IfModule mod_ssl.c>
    # Désactiver la compression SSL (vulnérabilité CRIME)
    SSLCompression off
    
    # Session cache pour améliorer les performances
    SSLSessionCache shmcb:/var/cache/apache2/ssl_scache(512000)
    SSLSessionCacheTimeout 300
    
    # Utiliser le stapling OCSP
    SSLUseStapling on
    SSLStaplingCache shmcb:/var/cache/apache2/ssl_stapling(128000)
    SSLStaplingResponderTimeout 5
    SSLStaplingReturnResponderErrors off
    
    # Modern configuration (Mozilla)
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off
</IfModule>
```

> [!tip] OCSP Stapling L'OCSP Stapling améliore les performances en permettant au serveur de fournir le statut de révocation du certificat, évitant au client de contacter l'autorité de certification.

### Activer les en-têtes de sécurité

```bash
# Activer le module headers
sudo a2enmod headers
```

Ajoutez dans votre VirtualHost HTTPS :

```apache
# En-têtes de sécurité recommandés
<IfModule mod_headers.c>
    # Force HTTPS pour 1 an (HSTS)
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    
    # Empêche le chargement dans une iframe (clickjacking)
    Header always set X-Frame-Options "SAMEORIGIN"
    
    # Active la protection XSS du navigateur
    Header always set X-XSS-Protection "1; mode=block"
    
    # Empêche le sniffing MIME
    Header always set X-Content-Type-Options "nosniff"
    
    # Politique de référent
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    
    # Content Security Policy (à adapter selon vos besoins)
    Header always set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"
</IfModule>
```

> [!warning] Content-Security-Policy La directive CSP doit être adaptée à votre site. Une politique trop stricte peut casser des fonctionnalités. Testez progressivement.

### Tester la configuration SSL

```bash
# Vérifier que le port 443 est ouvert
sudo netstat -tlnp | grep :443

# Tester la connexion SSL
openssl s_client -connect example.com:443 -servername example.com

# Vérifier le certificat
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -dates -subject
```

> [!tip] Outils de test en ligne
> 
> - **SSL Labs** : https://www.ssllabs.com/ssltest/ → Test complet de la configuration SSL (vise un score A+)
> - **Security Headers** : https://securityheaders.com/ → Vérifie les en-têtes de sécurité
> - **Mozilla Observatory** : https://observatory.mozilla.org/ → Audit de sécurité complet

### Vérification de la note SSL Labs

Une bonne configuration devrait obtenir un **score A+** sur SSL Labs :

|Critère|Configuration recommandée|
|---|---|
|**Protocoles**|TLS 1.2 et TLS 1.3 uniquement|
|**Ciphers**|Forward Secrecy (ECDHE, DHE)|
|**HSTS**|Activé avec max-age ≥ 6 mois|
|**Certificat**|Valide, non révoqué, chaîne complète|
|**OCSP Stapling**|Activé|

---

## 🔄 Redirection HTTP vers HTTPS

### Pourquoi rediriger HTTP vers HTTPS ?

Une fois HTTPS configuré, il faut **forcer** tous les visiteurs à utiliser la version sécurisée :

> [!warning] Sans redirection
> 
> - Les utilisateurs peuvent encore accéder au site en HTTP
> - Les moteurs de recherche indexent les deux versions (duplicate content)
> - Les liens HTTP restent non sécurisés
> - Les données peuvent encore être interceptées

### Méthode 1 : Redirection automatique par Certbot

Si vous avez utilisé `certbot --apache`, Certbot a probablement déjà configuré la redirection :

```apache
# Généré automatiquement par Certbot
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    
    # Redirection permanente vers HTTPS
    RewriteEngine on
    RewriteCond %{SERVER_NAME} =example.com [OR]
    RewriteCond %{SERVER_NAME} =www.example.com
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
```

### Méthode 2 : Redirection manuelle avec mod_rewrite

Si vous configurez manuellement, éditez votre VirtualHost HTTP :

```bash
sudo nano /etc/apache2/sites-available/example.com.conf
```

```apache
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/example.com/public_html
    
    # Logs
    ErrorLog ${APACHE_LOG_DIR}/example.com-error.log
    CustomLog ${APACHE_LOG_DIR}/example.com-access.log combined
    
    # Activer le module rewrite
    <IfModule mod_rewrite.c>
        RewriteEngine On
        
        # Rediriger tout le trafic HTTP vers HTTPS
        RewriteCond %{HTTPS} off
        RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
    </IfModule>
</VirtualHost>
```

> [!info] Explication de la règle
> 
> - **RewriteCond %{HTTPS} off** : Si la connexion n'est pas en HTTPS
> - **RewriteRule ^(.*)$** : Capture toute l'URL
> - **https://%{HTTP_HOST}%{REQUEST_URI}** : Redirige vers la même URL en HTTPS
> - **[L,R=301]** : Last rule, Redirection permanente (301)

```bash
# Activer mod_rewrite
sudo a2enmod rewrite

# Recharger Apache
sudo systemctl reload apache2
```

### Méthode 3 : Redirection simple avec Redirect

Alternative plus simple mais moins flexible :

```apache
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    
    # Redirection permanente simple
    Redirect permanent / https://example.com/
</VirtualHost>
```

> [!warning] Limitation du Redirect simple Cette méthode redirige toujours vers le domaine principal. Si vous avez plusieurs alias (www, blog, etc.), préférez mod_rewrite qui conserve le domaine utilisé.

### Tester la redirection

```bash
# Test avec curl (doit afficher une redirection 301)
curl -I http://example.com

# Résultat attendu :
# HTTP/1.1 301 Moved Permanently
# Location: https://example.com/

# Test de plusieurs URLs
curl -I http://example.com/page
curl -I http://www.example.com
curl -I http://example.com/dossier/fichier.html
```

> [!tip] Vérification complète
> 
> - ✅ http://example.com → https://example.com
> - ✅ http://www.example.com → https://www.example.com
> - ✅ Les chemins sont préservés : http://example.com/test → https://example.com/test
> - ✅ Code HTTP 301 (permanent) et non 302 (temporaire)

### Redirection avancée : www vers non-www (ou inversement)

Vous pouvez aussi normaliser les URLs avec ou sans www :

#### Rediriger www vers non-www

```apache
<VirtualHost *:443>
    ServerName www.example.com
    
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
    
    # Redirection www → non-www
    RewriteEngine On
    RewriteCond %{HTTP_HOST} ^www\.(.*)$ [NC]
    RewriteRule ^(.*)$ https://%1$1 [R=301,L]
</VirtualHost>
```

#### Rediriger non-www vers www

```apache
<VirtualHost *:443>
    ServerName example.com
    
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
    
    # Redirection non-www → www
    RewriteEngine On
    RewriteCond %{HTTP_HOST} !^www\. [NC]
    RewriteRule ^(.*)$ https://www.%{HTTP_HOST}$1 [R=301,L]
</VirtualHost>
```

> [!tip] Quelle version choisir ?
> 
> - **Sans www** : Plus court, moderne (example.com)
> - **Avec www** : Traditionnel, permet certaines configurations DNS avancées
> 
> L'important est de **choisir une version et s'y tenir** pour éviter le duplicate content SEO.

### Renouvellement automatique des certificats

Let's Encrypt nécessite un renouvellement tous les 90 jours, mais Certbot l'automatise :

```bash
# Vérifier que le renouvellement automatique est configuré
sudo systemctl status certbot.timer

# Test de renouvellement (dry-run, ne renouvelle pas vraiment)
sudo certbot renew --dry-run

# Voir les certificats installés
sudo certbot certificates
```

> [!info] Comment fonctionne le renouvellement Certbot crée automatiquement un **timer systemd** qui vérifie deux fois par jour si des certificats doivent être renouvelés :
> 
> ```bash
> /etc/systemd/system/certbot.timer
> /etc/systemd/system/certbot.service
> ```

```bash
# Forcer le renouvellement manuel (si nécessaire)
sudo certbot renew

# Renouveler un certificat spécifique
sudo certbot renew --cert-name example.com
```

> [!warning] Hook de renouvellement Après le renouvellement, Apache doit être rechargé pour utiliser le nouveau certificat. Certbot le fait automatiquement, mais vous pouvez vérifier :
> 
> ```bash
> # Voir les hooks configurés
> cat /etc/letsencrypt/renewal/example.com.conf
> 
> # Devrait contenir :
> # post_hook = systemctl reload apache2
> ```

### Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> **1. Boucle de redirection infinie**
> 
> ```apache
> # ❌ MAUVAIS : redirige HTTPS vers HTTPS indéfiniment
> RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
> 
> # ✅ BON : vérifie d'abord si on est déjà en HTTPS
> RewriteCond %{HTTPS} off
> RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
> ```
> 
> **2. Certificat pour le mauvais domaine**
> 
> ```apache
> # ❌ MAUVAIS : ServerName ne correspond pas au certificat
> ServerName blog.example.com
> SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
> 
> # ✅ BON : le certificat doit couvrir le domaine
> # Soit obtenir un certificat pour blog.example.com
> # Soit utiliser un certificat wildcard *.example.com
> ```
> 
> **3. Mixed content (contenu mixte)**
> 
> ```html
> <!-- ❌ MAUVAIS : page HTTPS charge des ressources HTTP -->
> <img src="http://example.com/image.jpg">
> <script src="http://cdn.example.com/script.js"></script>
> 
> <!-- ✅ BON : utiliser HTTPS ou des URLs relatives -->
> <img src="https://example.com/image.jpg">
> <script src="//cdn.example.com/script.js"></script>
> <img src="/images/image.jpg">
> ```
> 
> **4. Oublier de renouveler les certificats**
> 
> ```bash
> # Vérifier que le timer est actif
> sudo systemctl status certbot.timer
> 
> # Si inactif, l'activer :
> sudo systemctl enable certbot.timer
> sudo systemctl start certbot.timer
> ```
> 
> **5. Port 80 fermé**
> 
> ```bash
> # Let's Encrypt a besoin du port 80 pour la validation HTTP-01
> # Même si vous voulez utiliser uniquement HTTPS (443)
> 
> # Vérifier que le port 80 est ouvert
> sudo ufw allow 80/tcp
> sudo ufw allow 443/tcp
> ```

### Bonnes pratiques de sécurité SSL/TLS

|Pratique|Pourquoi|Comment|
|---|---|---|
|🔒 **TLS 1.2+ uniquement**|Les anciennes versions ont des vulnérabilités|`SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1`|
|🔑 **Forward Secrecy**|Protection même si la clé privée est compromise|Utiliser ECDHE/DHE dans SSLCipherSuite|
|📋 **HSTS activé**|Force HTTPS, même si l'utilisateur tape HTTP|`Header set Strict-Transport-Security "max-age=31536000"`|
|⚡ **OCSP Stapling**|Améliore les performances de validation|`SSLUseStapling on`|
|🔄 **Renouvellement automatique**|Évite l'expiration des certificats|Timer Certbot actif|
|🛡️ **En-têtes de sécurité**|Protection contre XSS, clickjacking, etc.|Module headers avec directives appropriées|
|📊 **Monitoring**|Détection rapide des problèmes|Surveillance des logs et alertes d'expiration|

### Surveillance et maintenance

#### Créer une alerte d'expiration

Créez un script de vérification :

```bash
sudo nano /usr/local/bin/check-ssl-expiry.sh
```

```bash
#!/bin/bash
# Script de vérification de l'expiration des certificats

DOMAIN="example.com"
DAYS_WARNING=14  # Alerte si expire dans moins de 14 jours
EMAIL="admin@example.com"

# Récupérer la date d'expiration
EXPIRY_DATE=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
CURRENT_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))

# Envoyer une alerte si nécessaire
if [ $DAYS_LEFT -lt $DAYS_WARNING ]; then
    echo "ALERTE : Le certificat SSL pour $DOMAIN expire dans $DAYS_LEFT jours !" | \
    mail -s "Certificat SSL bientôt expiré" $EMAIL
fi
```

```bash
# Rendre le script exécutable
sudo chmod +x /usr/local/bin/check-ssl-expiry.sh

# Ajouter au cron (vérification quotidienne)
sudo crontab -e

# Ajouter cette ligne :
0 8 * * * /usr/local/bin/check-ssl-expiry.sh
```

#### Logs à surveiller

```bash
# Logs de renouvellement Certbot
sudo cat /var/log/letsencrypt/letsencrypt.log

# Erreurs SSL Apache
sudo tail -f /var/log/apache2/error.log | grep -i ssl

# Vérifier l'utilisation du certificat
sudo journalctl -u apache2 | grep -i ssl
```

> [!tip] Monitoring avec des outils externes
> 
> - **UptimeRobot** : Surveillance gratuite de la disponibilité HTTPS
> - **SSL Labs Monitoring** : Alertes sur les changements de configuration SSL
> - **Certwatch** : Notifications d'expiration de certificats

### Commandes utiles de diagnostic

```bash
# Afficher tous les certificats Let's Encrypt
sudo certbot certificates

# Tester le renouvellement sans réellement renouveler
sudo certbot renew --dry-run

# Voir la configuration d'un certificat
sudo cat /etc/letsencrypt/renewal/example.com.conf

# Vérifier la validité d'un certificat
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -dates

# Afficher le contenu complet d'un certificat
openssl x509 -in /etc/letsencrypt/live/example.com/cert.pem -text -noout

# Vérifier la correspondance clé privée / certificat
openssl x509 -noout -modulus -in /etc/letsencrypt/live/example.com/cert.pem | openssl md5
openssl rsa -noout -modulus -in /etc/letsencrypt/live/example.com/privkey.pem | openssl md5
# Les deux hashes MD5 doivent être identiques

# Tester la connexion TLS 1.3
openssl s_client -connect example.com:443 -tls1_3

# Lister les ciphers supportés
nmap --script ssl-enum-ciphers -p 443 example.com
```

### Astuces avancées

> [!tip] 💡 Astuces pratiques
> 
> **1. Obtenir un certificat pour plusieurs domaines différents**
> 
> ```bash
> sudo certbot --apache \
>   -d example.com -d www.example.com \
>   -d blog.example.com -d shop.example.com
> ```
> 
> **2. Certificat wildcard avec validation DNS**
> 
> ```bash
> sudo certbot certonly --manual --preferred-challenges dns \
>   -d example.com -d *.example.com
> # Vous devrez ajouter un enregistrement TXT dans votre DNS
> ```
> 
> **3. Forcer le renouvellement avant expiration**
> 
> ```bash
> sudo certbot renew --force-renewal --cert-name example.com
> ```
> 
> **4. Révoquer un certificat compromis**
> 
> ```bash
> sudo certbot revoke --cert-path /etc/letsencrypt/live/example.com/cert.pem
> ```
> 
> **5. Supprimer un certificat inutilisé**
> 
> ```bash
> sudo certbot delete --cert-name example.com
> ```
> 
> **6. Changer l'email de notification**
> 
> ```bash
> sudo certbot update_account --email newemail@example.com
> ```
> 
> **7. Configuration HTTP/2 avec HTTPS**
> 
> ```bash
> # Activer HTTP/2 (nécessite Apache 2.4.17+)
> sudo a2enmod http2
> ```
> 
> ```apache
> # Dans le VirtualHost HTTPS
> Protocols h2 http/1.1
> ```
> 
> **8. Rediriger tous les sous-domaines vers HTTPS**
> 
> ```apache
> <VirtualHost *:80>
>     ServerName example.com
>     ServerAlias *.example.com
>     
>     RewriteEngine On
>     RewriteCond %{HTTPS} off
>     RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
> </VirtualHost>
> ```

### Récapitulatif des étapes

Pour mettre en place HTTPS sur votre serveur LAMP :

```
1️⃣ Préparation
   ├── Vérifier DNS → domaine pointe vers serveur
   ├── Apache fonctionnel avec VirtualHost configuré
   └── Port 80 ouvert

2️⃣ Installation
   ├── Installer Certbot : apt install certbot python3-certbot-apache
   └── Vérifier l'installation : certbot --version

3️⃣ Obtention du certificat
   ├── Automatique : certbot --apache -d example.com
   └── Manuel : certbot certonly --webroot -w /var/www/html -d example.com

4️⃣ Configuration SSL
   ├── Activer mod_ssl : a2enmod ssl
   ├── Configurer VirtualHost HTTPS (port 443)
   ├── Définir SSLCertificateFile et SSLCertificateKeyFile
   └── Optimiser : SSLProtocol, SSLCipherSuite, HSTS

5️⃣ Redirection HTTP → HTTPS
   ├── Activer mod_rewrite : a2enmod rewrite
   ├── Ajouter règles de redirection dans VirtualHost HTTP
   └── Tester les redirections

6️⃣ Vérification et tests
   ├── SSL Labs : https://www.ssllabs.com/ssltest/
   ├── Tester certificat : openssl s_client
   └── Vérifier renouvellement auto : certbot renew --dry-run

7️⃣ Maintenance
   ├── Surveiller expiration des certificats
   ├── Vérifier logs de renouvellement
   └── Maintenir la configuration à jour
```

> [!info] Points clés à retenir
> 
> - ✅ HTTPS est **gratuit** avec Let's Encrypt
> - ✅ Certbot **automatise** complètement le processus
> - ✅ Les certificats expirent tous les **90 jours** mais se renouvellent automatiquement
> - ✅ Toujours **rediriger HTTP vers HTTPS** pour la sécurité
> - ✅ Utiliser uniquement **TLS 1.2+** et des ciphers modernes
> - ✅ Activer **HSTS** pour forcer HTTPS côté navigateur
> - ✅ Tester régulièrement avec **SSL Labs** pour maintenir un score A+

---

## 🎓 Concepts avancés à connaître

### Différence entre certificat et clé privée

```
Certificat (Public)                    Clé Privée (Secrète)
├── Contient la clé publique          ├── Jamais partagée
├── Signé par une CA                  ├── Stockée sur le serveur
├── Prouve l'identité du domaine      ├── Utilisée pour déchiffrer
└── Peut être partagé librement       └── Permissions 600 (root only)
```

### Chaîne de certification

Un certificat SSL fait partie d'une **chaîne de confiance** :

```
Root CA (Autorité racine)
    └── Intermediate CA (Autorité intermédiaire)
        └── Server Certificate (Votre certificat)
```

> [!info] Pourquoi fullchain.pem ? Le fichier `fullchain.pem` contient votre certificat + le certificat intermédiaire. C'est nécessaire pour que les navigateurs puissent remonter la chaîne jusqu'à une autorité racine de confiance.

### SNI (Server Name Indication)

**SNI** permet d'héberger plusieurs certificats SSL sur la même IP :

```apache
# Plusieurs domaines, même IP, certificats différents
<VirtualHost *:443>
    ServerName example.com
    SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
</VirtualHost>

<VirtualHost *:443>
    ServerName autre-site.com
    SSLCertificateFile /etc/letsencrypt/live/autre-site.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/autre-site.com/privkey.pem
</VirtualHost>
```

> [!warning] Navigateurs très anciens SNI n'est pas supporté par les très vieux navigateurs (IE6 sur Windows XP, Android 2.x). Ces navigateurs ne peuvent pas accéder à des sites avec SNI. En 2025, cela représente moins de 0.1% des utilisateurs.

---

**🎯 Vous savez maintenant sécuriser votre stack LAMP avec HTTPS !**