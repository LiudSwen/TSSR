

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

## Introduction

La sécurité d'Apache repose sur un système de contrôle d'accès granulaire qui permet de définir précisément qui peut accéder à quoi, et comment. Cette partie du cours se concentre sur les quatre piliers fondamentaux de la configuration des permissions : les directives `Directory`, `Options`, `AllowOverride` et `Require`.

> [!info] Pourquoi c'est crucial ? Une mauvaise configuration des permissions peut exposer des fichiers sensibles, permettre l'exécution de scripts malveillants, ou ouvrir des failles de sécurité. Comprendre ces directives est essentiel pour sécuriser votre serveur web.

---

## La directive Directory

### 📖 Concept

La directive `<Directory>` permet de définir des règles de configuration qui s'appliquent à un répertoire spécifique du système de fichiers et à tous ses sous-répertoires (sauf indication contraire).

### ✨ Pourquoi l'utiliser ?

- **Contrôle granulaire** : Appliquer des règles différentes selon les répertoires
- **Sécurité par défaut** : Restreindre l'accès et autoriser seulement ce qui est nécessaire
- **Isolation** : Séparer les configurations entre différents projets ou sites

### 📝 Syntaxe de base

```apache
<Directory "/chemin/absolu/vers/repertoire">
    # Directives de configuration
    Options FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
```

> [!warning] Attention au chemin La directive `<Directory>` utilise des chemins **absolus** du système de fichiers (ex: `/var/www/html`), pas des URLs. Ne confondez pas avec `<Location>` qui travaille sur les URLs.

### 🔍 Syntaxes avancées

#### Wildcard et expressions régulières

```apache
# Avec wildcard (tous les répertoires commençant par "projet")
<Directory "/var/www/projet*">
    Options -Indexes
</Directory>

# Avec expression régulière (nécessite ~)
<DirectoryMatch "^/var/www/.*/private">
    Require all denied
</DirectoryMatch>
```

#### Imbrication et héritage

```apache
# Configuration générale
<Directory "/var/www">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>

# Configuration spécifique (hérite et surcharge)
<Directory "/var/www/html/admin">
    Options -Indexes  # Surcharge la configuration parente
    Require ip 192.168.1.0/24  # Restriction d'accès
</Directory>
```

> [!tip] Astuce - Ordre de traitement Apache traite les directives `<Directory>` du plus général au plus spécifique. Les configurations plus spécifiques écrasent ou complètent les plus générales selon les directives utilisées.

### 📊 Comparaison des directives similaires

|Directive|Cible|Usage|
|---|---|---|
|`<Directory>`|Chemin du système de fichiers|Configuration basée sur l'emplacement physique|
|`<DirectoryMatch>`|Regex sur le chemin|Patterns complexes pour plusieurs répertoires|
|`<Location>`|URL|Configuration basée sur l'URL demandée|
|`<Files>`|Nom de fichier|Configuration pour des fichiers spécifiques|

---

## Options

### 📖 Concept

La directive `Options` contrôle les fonctionnalités disponibles dans un répertoire donné. Elle active ou désactive des comportements spécifiques du serveur.

### ✨ Options principales

#### 1. **Indexes**

```apache
# Active le listage des répertoires
Options +Indexes

# Désactive le listage (recommandé pour la sécurité)
Options -Indexes
```

**Comportement** : Lorsqu'aucun fichier index (index.html, index.php) n'existe, Apache affiche la liste des fichiers du répertoire.

> [!warning] Sécurité L'option `Indexes` peut exposer des fichiers sensibles (backups, configurations). À désactiver en production sauf cas spécifique.

#### 2. **FollowSymLinks**

```apache
# Autorise Apache à suivre les liens symboliques
Options +FollowSymLinks

# Interdit de suivre les liens symboliques
Options -FollowSymLinks
```

**Comportement** : Permet à Apache de suivre les liens symboliques vers des fichiers ou répertoires situés ailleurs sur le système.

> [!info] Alternative sécurisée Utilisez `SymLinksIfOwnerMatch` pour suivre uniquement les liens dont le propriétaire correspond au fichier cible.

```apache
Options +SymLinksIfOwnerMatch
```

#### 3. **ExecCGI**

```apache
# Autorise l'exécution de scripts CGI
Options +ExecCGI
```

**Comportement** : Permet l'exécution de scripts CGI dans le répertoire.

> [!warning] Attention N'activez cette option que dans les répertoires spécifiquement dédiés aux scripts CGI. Une activation globale est un risque de sécurité majeur.

#### 4. **Includes**

```apache
# Active les Server Side Includes (SSI)
Options +Includes

# Active SSI mais désactive l'exécution de commandes
Options +IncludesNOEXEC
```

**Comportement** : Permet l'utilisation de SSI pour inclure du contenu dynamique dans les pages HTML.

#### 5. **MultiViews**

```apache
# Active la négociation de contenu
Options +MultiViews
```

**Comportement** : Apache tente de servir le meilleur fichier correspondant en fonction de la langue, du type de contenu, etc.

### 📝 Syntaxe complète

```apache
<Directory "/var/www/html">
    # Syntaxe additive (ajoute aux options héritées)
    Options +FollowSymLinks -Indexes
    
    # Syntaxe absolue (remplace toutes les options héritées)
    Options FollowSymLinks
    
    # Désactiver toutes les options
    Options None
    
    # Activer toutes les options (DANGEREUX)
    Options All
</Directory>
```

> [!tip] Préfixe + et -
> 
> - Sans préfixe : remplace complètement les options héritées
> - Avec `+` : ajoute l'option aux options héritées
> - Avec `-` : retire l'option des options héritées

### 🛡️ Configuration sécurisée recommandée

```apache
<Directory "/var/www/html">
    # Configuration sécurisée pour un site web classique
    Options -Indexes +FollowSymLinks -ExecCGI -Includes
    
    # Ou de manière plus restrictive
    Options FollowSymLinks
</Directory>

<Directory "/var/www/html/uploads">
    # Répertoire d'uploads : très restrictif
    Options None
    # On empêche l'exécution de tout script
    php_flag engine off
    RemoveHandler .php .phtml .php3
    RemoveType .php .phtml .php3
</Directory>
```

### 📊 Tableau récapitulatif des Options

|Option|Effet|Risque sécurité|Usage recommandé|
|---|---|---|---|
|`Indexes`|Liste les fichiers|🔴 Élevé|Désactiver en production|
|`FollowSymLinks`|Suit les liens symboliques|🟡 Moyen|Activer avec prudence|
|`SymLinksIfOwnerMatch`|Suit les liens (si même propriétaire)|🟢 Faible|Alternative sécurisée|
|`ExecCGI`|Exécute les scripts CGI|🔴 Élevé|Uniquement répertoires dédiés|
|`Includes`|Active SSI|🟡 Moyen|Éviter si possible|
|`IncludesNOEXEC`|SSI sans exécution|🟢 Faible|Préférer à Includes|
|`MultiViews`|Négociation de contenu|🟢 Faible|Selon besoins|

---

## AllowOverride

### 📖 Concept

La directive `AllowOverride` détermine quelles directives peuvent être placées dans les fichiers `.htaccess` pour surcharger la configuration du serveur. Elle contrôle le niveau de décentralisation de la configuration.

### ✨ Pourquoi c'est important ?

- **Performance** : `.htaccess` ralentit Apache (lu à chaque requête)
- **Sécurité** : Limite ce que les utilisateurs peuvent modifier
- **Contrôle** : Garde la maîtrise de la configuration serveur

### 📝 Valeurs principales

#### 1. **None** (Recommandé pour la performance)

```apache
<Directory "/var/www/html">
    AllowOverride None
</Directory>
```

**Effet** : Désactive complètement l'utilisation de `.htaccess`. Apache ignore ces fichiers.

> [!tip] Meilleure pratique Utilisez `AllowOverride None` et placez toute la configuration dans les fichiers du serveur (VirtualHost ou Directory). C'est plus rapide et plus sûr.

#### 2. **All** (À éviter en production)

```apache
<Directory "/var/www/html">
    AllowOverride All
</Directory>
```

**Effet** : Autorise toutes les directives dans `.htaccess`.

> [!warning] Performance et sécurité `AllowOverride All` dégrade significativement les performances et peut créer des failles de sécurité. À utiliser uniquement en développement ou hébergement mutualisé.

#### 3. **Valeurs spécifiques** (Contrôle granulaire)

```apache
<Directory "/var/www/html">
    # Autoriser uniquement certains groupes de directives
    AllowOverride AuthConfig Indexes
</Directory>
```

### 📊 Groupes de directives disponibles

|Groupe|Directives autorisées|Exemple d'usage|
|---|---|---|
|`AuthConfig`|Authentification et autorisation|`Require`, `AuthType`, `AuthName`|
|`FileInfo`|Types de documents|`AddType`, `AddHandler`, `ErrorDocument`|
|`Indexes`|Indexation des répertoires|`DirectoryIndex`, `IndexOptions`|
|`Limit`|Contrôle d'accès basique|`Require`, `Allow`, `Deny`|
|`Options`|Options de répertoire|`Options` (mais pas toutes)|

### 🔍 Exemples pratiques

#### Configuration pour hébergement mutualisé

```apache
<Directory "/var/www/clients">
    # Permet aux clients de gérer l'authentification et les redirections
    AllowOverride AuthConfig FileInfo Limit
    
    # Mais pas les Options dangereuses
    Options -ExecCGI -Includes
</Directory>
```

#### Configuration optimale pour un site unique

```apache
<Directory "/var/www/monsite">
    # Aucun .htaccess autorisé
    AllowOverride None
    
    # Toute la configuration est ici
    Options -Indexes +FollowSymLinks
    Require all granted
    
    # Réécritures directement dans la config
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^(.*)$ index.php [QSA,L]
</Directory>
```

#### Migration de .htaccess vers configuration serveur

**Avant** (avec `.htaccess` dans `/var/www/html/.htaccess`):

```apache
# Dans /etc/apache2/sites-available/monsite.conf
<Directory "/var/www/html">
    AllowOverride All
</Directory>
```

```apache
# Dans /var/www/html/.htaccess
Options -Indexes
RewriteEngine On
RewriteRule ^admin - [F]
```

**Après** (configuration optimisée):

```apache
# Dans /etc/apache2/sites-available/monsite.conf
<Directory "/var/www/html">
    AllowOverride None
    Options -Indexes +FollowSymLinks
    
    RewriteEngine On
    RewriteRule ^admin - [F]
</Directory>
```

> [!tip] Astuce de migration Copiez le contenu de vos `.htaccess` dans les blocs `<Directory>` correspondants, puis définissez `AllowOverride None`. Redémarrez Apache et supprimez les `.htaccess`.

### ⚡ Impact sur les performances

```apache
# LENT - Apache vérifie .htaccess à chaque requête
<Directory "/var/www/html">
    AllowOverride All
</Directory>

# RAPIDE - Apache lit la config une seule fois au démarrage
<Directory "/var/www/html">
    AllowOverride None
    # Configuration directement ici
</Directory>
```

> [!info] Benchmark indicatif Sur un site à trafic moyen, désactiver `.htaccess` peut améliorer les performances de 5 à 15% en réduisant les accès disque.

---

## Require (Allow/Deny)

### 📖 Concept

La directive `Require` (Apache 2.4+) contrôle qui peut accéder aux ressources. Elle remplace l'ancien système `Allow`/`Deny` d'Apache 2.2 et offre une syntaxe plus claire et puissante.

> [!info] Historique Apache 2.2 utilisait `Order`, `Allow`, `Deny`. Apache 2.4+ utilise `Require` avec une logique plus intuitive. Les anciennes directives sont dépréciées.

### ✨ Syntaxe de base

```apache
<Directory "/var/www/html">
    # Autoriser tout le monde
    Require all granted
    
    # Interdire tout le monde
    Require all denied
</Directory>
```

### 🔍 Types de restrictions

#### 1. **Par adresse IP**

```apache
<Directory "/var/www/html/admin">
    # Autoriser une IP spécifique
    Require ip 192.168.1.100
    
    # Autoriser un réseau
    Require ip 192.168.1.0/24
    
    # Autoriser plusieurs IPs ou réseaux
    Require ip 192.168.1.100 10.0.0.0/8 172.16.0.0/12
</Directory>
```

#### 2. **Par nom d'hôte**

```apache
<Directory "/var/www/html/api">
    # Autoriser un domaine spécifique
    Require host example.com
    
    # Autoriser un sous-domaine et tous ses enfants
    Require host .example.com
    
    # Autoriser plusieurs domaines
    Require host example.com trusted-partner.org
</Directory>
```

> [!warning] Performance La résolution DNS inversée pour `Require host` est coûteuse. Préférez `Require ip` quand c'est possible.

#### 3. **Par utilisateur authentifié**

```apache
<Directory "/var/www/html/private">
    # Nécessite n'importe quel utilisateur authentifié
    Require valid-user
    
    # Nécessite un utilisateur spécifique
    Require user alice bob charlie
    
    # Nécessite un groupe spécifique
    Require group admins developers
</Directory>
```

#### 4. **Par méthode HTTP**

```apache
<Directory "/var/www/html/api">
    # Autoriser seulement GET et POST
    <RequireAll>
        Require method GET POST
    </RequireAll>
</Directory>
```

### 🔗 Logique conditionnelle

#### RequireAll (ET logique)

```apache
<Directory "/var/www/html/admin">
    # L'utilisateur DOIT être authentifié ET venir du réseau local
    <RequireAll>
        Require valid-user
        Require ip 192.168.1.0/24
    </RequireAll>
</Directory>
```

#### RequireAny (OU logique)

```apache
<Directory "/var/www/html/restricted">
    # L'utilisateur doit soit être du réseau local SOIT authentifié
    <RequireAny>
        Require ip 192.168.1.0/24
        Require valid-user
    </RequireAny>
</Directory>
```

#### RequireNone (Négation)

```apache
<Directory "/var/www/html">
    # Accepter tout le monde SAUF certaines IPs
    <RequireAll>
        Require all granted
        <RequireNone>
            Require ip 203.0.113.0/24
        </RequireNone>
    </RequireAll>
</Directory>
```

### 🛡️ Exemples de configurations sécurisées

#### Protection d'un panneau d'administration

```apache
<Directory "/var/www/html/admin">
    # Accès réservé : réseau local + authentification
    <RequireAll>
        Require ip 192.168.1.0/24 10.0.0.0/8
        Require valid-user
    </RequireAll>
    
    Options -Indexes
    AllowOverride None
</Directory>
```

#### API avec liste blanche d'IPs

```apache
<Directory "/var/www/html/api">
    # Seulement les serveurs partenaires
    <RequireAny>
        Require ip 198.51.100.10
        Require ip 203.0.113.25
        Require ip 192.0.2.0/24
    </RequireAny>
    
    # Désactive l'exécution de scripts
    Options None
    AllowOverride None
</Directory>
```

#### Répertoire public avec exceptions

```apache
<Directory "/var/www/html/public">
    # Accessible à tous
    Require all granted
    
    Options -Indexes +FollowSymLinks
</Directory>

<Directory "/var/www/html/public/private">
    # Sauf ce sous-répertoire
    Require all denied
</Directory>
```

#### Protection des fichiers sensibles

```apache
# Protéger tous les fichiers de configuration
<FilesMatch "\.(env|config|ini|conf)$">
    Require all denied
</FilesMatch>

# Protéger les fichiers commençant par un point
<FilesMatch "^\.">
    Require all denied
</FilesMatch>

# Protéger spécifiquement certains fichiers
<Files "composer.json">
    Require all denied
</Files>
```

### 📊 Migration Apache 2.2 → 2.4

|Apache 2.2 (ancien)|Apache 2.4 (nouveau)|
|---|---|
|`Order allow,deny`<br>`Allow from all`|`Require all granted`|
|`Order deny,allow`<br>`Deny from all`|`Require all denied`|
|`Order deny,allow`<br>`Allow from 192.168.1`|`Require ip 192.168.1`|
|`Allow from .example.com`|`Require host .example.com`|

**Exemple complet de migration :**

```apache
# Apache 2.2 (ANCIEN - ne fonctionne plus correctement)
<Directory "/var/www/html/admin">
    Order deny,allow
    Deny from all
    Allow from 192.168.1.0/24
</Directory>

# Apache 2.4 (NOUVEAU)
<Directory "/var/www/html/admin">
    Require ip 192.168.1.0/24
</Directory>
```

### 🔐 Combinaison avec l'authentification

```apache
<Directory "/var/www/html/secure">
    # Configurer l'authentification HTTP Basic
    AuthType Basic
    AuthName "Zone réservée"
    AuthUserFile /etc/apache2/.htpasswd
    
    # Autoriser les utilisateurs authentifiés OU le réseau local
    <RequireAny>
        Require valid-user
        Require ip 192.168.1.0/24
    </RequireAny>
</Directory>
```

> [!tip] Créer un fichier de mots de passe
> 
> ```bash
> # Créer un utilisateur
> htpasswd -c /etc/apache2/.htpasswd alice
> 
> # Ajouter d'autres utilisateurs (sans -c)
> htpasswd /etc/apache2/.htpasswd bob
> ```

---

## Pièges courants

### 🚨 Piège 1 : Chemin relatif dans Directory

```apache
# ❌ INCORRECT - Ne fonctionnera pas
<Directory "html">
    Options -Indexes
</Directory>

# ✅ CORRECT - Chemin absolu
<Directory "/var/www/html">
    Options -Indexes
</Directory>
```

> [!warning] Toujours des chemins absolus La directive `<Directory>` nécessite toujours un chemin absolu du système de fichiers.

### 🚨 Piège 2 : Ordre des directives

```apache
# ❌ INCORRECT - L'ordre compte !
<Directory "/var/www/html/admin">
    Require all granted
</Directory>

<Directory "/var/www/html">
    Require all denied
</Directory>

# ✅ CORRECT - Du général au spécifique
<Directory "/var/www/html">
    Require all denied
</Directory>

<Directory "/var/www/html/admin">
    Require all granted
</Directory>
```

> [!tip] Règle d'or Apache traite les directives du répertoire parent vers l'enfant. Placez les configurations générales avant les spécifiques.

### 🚨 Piège 3 : Options avec et sans préfixe

```apache
# Configuration parente
<Directory "/var/www">
    Options Indexes FollowSymLinks MultiViews
</Directory>

# ❌ ERREUR - Écrase TOUTES les options héritées
<Directory "/var/www/html">
    Options -Indexes
    # Résultat : AUCUNE option n'est active !
</Directory>

# ✅ CORRECT - Modification incrémentale
<Directory "/var/www/html">
    Options +FollowSymLinks -Indexes
    # Résultat : FollowSymLinks et MultiViews actifs, Indexes désactivé
</Directory>
```

### 🚨 Piège 4 : AllowOverride et performance

```apache
# ❌ MAUVAISE PRATIQUE - Impact performance
<Directory "/var/www/html">
    AllowOverride All
</Directory>

# ✅ BONNE PRATIQUE - Configuration centralisée
<Directory "/var/www/html">
    AllowOverride None
    
    Options -Indexes +FollowSymLinks
    RewriteEngine On
    RewriteRule ^(.*)$ index.php [QSA,L]
</Directory>
```

> [!info] Impact Avec `AllowOverride All`, Apache vérifie l'existence de `.htaccess` dans chaque répertoire de la hiérarchie pour **chaque requête**.

### 🚨 Piège 5 : Require mal compris

```apache
# ❌ INCORRECT - Ceci autorise SOIT les IPs SOIT tous
<Directory "/var/www/html/admin">
    Require ip 192.168.1.0/24
    Require all granted  # <- Annule la restriction !
</Directory>

# ✅ CORRECT - Utiliser RequireAll si plusieurs conditions
<Directory "/var/www/html/admin">
    <RequireAll>
        Require ip 192.168.1.0/24
        Require valid-user
    </RequireAll>
</Directory>
```

### 🚨 Piège 6 : Oublier les fichiers cachés

```apache
# ❌ INCOMPLET - Les .git, .env sont accessibles !
<Directory "/var/www/html">
    Options -Indexes
    Require all granted
</Directory>

# ✅ COMPLET - Protection des fichiers sensibles
<Directory "/var/www/html">
    Options -Indexes
    Require all granted
</Directory>

# Bloquer les fichiers cachés
<DirectoryMatch "^/var/www/html/\.">
    Require all denied
</DirectoryMatch>

# Ou avec Files
<FilesMatch "^\.">
    Require all denied
</FilesMatch>
```

### 🚨 Piège 7 : Répertoires d'upload non protégés

```apache
# ❌ DANGEREUX - Des scripts PHP peuvent être uploadés et exécutés !
<Directory "/var/www/html/uploads">
    Options -Indexes
    Require all granted
</Directory>

# ✅ SÉCURISÉ - Empêche l'exécution de scripts
<Directory "/var/www/html/uploads">
    Options None
    Require all granted
    
    # Désactive PHP
    php_flag engine off
    
    # Retire les handlers dangereux
    RemoveHandler .php .phtml .php3 .php4 .php5 .phps
    RemoveType .php .phtml .php3 .php4 .php5 .phps
    
    # Ou définir le type comme texte brut
    <FilesMatch "\.php$">
        SetHandler none
        ForceType text/plain
    </FilesMatch>
</Directory>
```

### 🚨 Piège 8 : Confusion Directory vs Location

```apache
# ❌ MAUVAISE COMPRÉHENSION
<Directory "/admin">  # Cherche le dossier /admin à la racine du système !
    Require all denied
</Directory>

# ✅ CORRECT selon le besoin
# Pour un chemin physique :
<Directory "/var/www/html/admin">
    Require all denied
</Directory>

# Pour une URL :
<Location "/admin">
    Require all denied
</Location>
```

> [!info] Différence clé
> 
> - `<Directory>` = Chemin physique du système de fichiers
> - `<Location>` = Chemin de l'URL (après traitement par mod_rewrite)

---

## 🎯 Checklist de sécurité

Avant de mettre un site en production, vérifiez :

- [ ] `Options -Indexes` activé partout sauf si nécessaire
- [ ] `AllowOverride None` pour optimiser les performances
- [ ] `Require` correctement configuré pour chaque répertoire
- [ ] Fichiers sensibles protégés (.git, .env, .config, etc.)
- [ ] Répertoires d'upload sécurisés (pas d'exécution PHP)
- [ ] Panneau d'administration restreint par IP et/ou authentification
- [ ] `FollowSymLinks` utilisé plutôt que `SymLinksIfOwnerMatch` si propriétés OK
- [ ] Options dangereuses désactivées (`ExecCGI`, `Includes`)
- [ ] Configuration testée avec `apachectl configtest`
- [ ] Logs d'erreurs surveillés après mise en production

---

## 📚 Résumé des bonnes pratiques

|Principe|Recommandation|
|---|---|
|**Philosophie**|Interdire par défaut, autoriser explicitement|
|**Options**|Désactiver tout sauf le strict nécessaire|
|**AllowOverride**|`None` en production pour les performances|
|**Require**|Utiliser la syntaxe Apache 2.4+|
|**Fichiers sensibles**|Toujours protéger .git, .env, .config, etc.|
|**Uploads**|Désactiver l'exécution de scripts|
|**Admin**|Restreindre par IP + authentification|
|**Performance**|Configuration dans VirtualHost, pas .htaccess|

---

**🎓 Vous maîtrisez maintenant les fondamentaux de la sécurité Apache !** Ces quatre directives (`Directory`, `Options`, `AllowOverride`, `Require`) constituent la base de toute configuration Apache sécurisée.