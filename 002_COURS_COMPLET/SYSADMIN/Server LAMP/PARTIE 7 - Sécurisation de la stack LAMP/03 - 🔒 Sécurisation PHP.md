

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

## 🎯 Introduction

La sécurisation de PHP est un pilier fondamental dans la protection d'une stack LAMP. PHP, en tant que langage d'exécution côté serveur, peut devenir une porte d'entrée pour des attaquants si sa configuration n'est pas correctement durcie. Cette partie se concentre sur quatre axes essentiels de sécurisation qui permettent de réduire drastiquement la surface d'attaque.

> [!info] Fichier de configuration PHP La configuration PHP est principalement gérée via le fichier `php.ini`, généralement situé dans :
> 
> - `/etc/php/8.x/apache2/php.ini` (pour Apache)
> - `/etc/php/8.x/fpm/php.ini` (pour PHP-FPM)
> - `/etc/php/8.x/cli/php.ini` (pour ligne de commande)

---

## 🚫 Désactivation de fonctions dangereuses

### Pourquoi désactiver certaines fonctions ?

Certaines fonctions PHP permettent d'exécuter des commandes système, de manipuler des processus ou d'accéder à des ressources sensibles. Si un attaquant parvient à injecter du code PHP (via upload de fichier, injection de code, etc.), ces fonctions deviennent des armes redoutables.

> [!warning] Impact de sécurité Les fonctions comme `exec()`, `shell_exec()`, ou `system()` permettent l'exécution de commandes système arbitraires. Un seul fichier compromis peut suffire à prendre le contrôle total du serveur.

### La directive `disable_functions`

La directive `disable_functions` dans `php.ini` permet de désactiver complètement certaines fonctions PHP, les rendant inutilisables même si le code tente de les appeler.

#### Configuration recommandée

```ini
; Liste des fonctions dangereuses à désactiver
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source,phpinfo,proc_nice,proc_terminate,proc_get_status,proc_close,pfsockopen,leak,apache_child_terminate,posix_kill,posix_mkfifo,posix_setpgid,posix_setsid,posix_setuid,ini_alter,dl,symlink,link,chgrp,chmod,chown
```

#### Fonctions critiques à désactiver

|Fonction|Danger|Utilisation légitime rare|
|---|---|---|
|`exec()`|Exécution de commandes shell|Scripts d'administration|
|`shell_exec()`|Exécution de commandes shell|Traitement batch|
|`system()`|Exécution de commandes shell|Scripts système|
|`passthru()`|Exécution avec sortie binaire|Génération d'images|
|`proc_open()`|Contrôle complet de processus|Pipelines complexes|
|`popen()`|Ouverture de processus|Communication inter-processus|
|`eval()`|Exécution de code PHP arbitraire|**Jamais justifié**|
|`phpinfo()`|Révèle la configuration complète|Debugging uniquement|
|`dl()`|Chargement d'extensions dynamiques|Obsolète depuis PHP 5.3|
|`symlink()`|Création de liens symboliques|Peut contourner open_basedir|

> [!example] Test de désactivation
> 
> ```php
> <?php
> // Ce code provoquera une erreur fatale si exec() est désactivé
> exec('whoami', $output);
> // Fatal error: Uncaught Error: Call to undefined function exec()
> ?>
> ```

### Application de la configuration

```bash
# 1. Éditer le fichier php.ini
sudo nano /etc/php/8.2/apache2/php.ini

# 2. Ajouter ou modifier la directive disable_functions
# (Voir configuration ci-dessus)

# 3. Vérifier la syntaxe
php -i | grep disable_functions

# 4. Redémarrer Apache pour appliquer les changements
sudo systemctl restart apache2
```

> [!tip] Astuce de configuration Commentez chaque fonction désactivée pour documenter pourquoi elle a été bloquée. Cela facilite la maintenance future.
> 
> ```ini
> disable_functions = 
>     exec,           ; Exécution commandes shell
>     system,         ; Exécution commandes système
>     passthru        ; Sortie binaire directe
> ```

### Cas particuliers et exceptions

Certaines applications peuvent nécessiter des fonctions spécifiques. Dans ce cas :

1. **Évaluer le risque** : L'application nécessite-t-elle vraiment cette fonction ?
2. **Isoler l'application** : Utiliser un pool PHP-FPM séparé avec sa propre configuration
3. **Limiter l'usage** : Restreindre via des wrappers sécurisés

```ini
; Configuration pour un virtual host spécifique nécessitant exec()
; Dans un fichier php.ini dédié au pool PHP-FPM
disable_functions = passthru,shell_exec,system,proc_open
; exec() reste disponible, mais les autres sont bloquées
```

> [!warning] Pièges courants
> 
> - Ne pas oublier de redémarrer le service après modification
> - Certaines applications Laravel/Symfony peuvent nécessiter `proc_open()` pour des tâches asynchrones
> - Les CMS comme WordPress fonctionnent généralement sans ces fonctions
> - Tester l'application après désactivation pour détecter les dépendances

---

## 🔍 Gestion de l'affichage des erreurs

### Le problème avec `display_errors`

L'affichage des erreurs PHP peut révéler des informations critiques aux attaquants : chemins de fichiers, structure de base de données, versions de bibliothèques, et même fragments de code source.

> [!warning] Fuite d'information
> 
> ```
> Warning: mysqli_connect(): Access denied for user 'admin'@'localhost' 
> (using password: YES) in /var/www/html/config/database.php on line 23
> ```
> 
> Cette erreur révèle : l'utilisateur MySQL, l'emplacement du fichier de configuration, et confirme l'usage de MySQL.

### Configuration pour la production

#### Dans php.ini

```ini
; === CONFIGURATION PRODUCTION ===

; Désactiver l'affichage des erreurs dans le navigateur
display_errors = Off

; Désactiver l'affichage des erreurs de démarrage
display_startup_errors = Off

; Activer la journalisation des erreurs
log_errors = On

; Définir le fichier de log
error_log = /var/log/php/error.log

; Définir le niveau de rapport d'erreurs
; E_ALL & ~E_DEPRECATED & ~E_STRICT : Tout sauf avertissements de dépréciation
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

; Exposer PHP dans les en-têtes HTTP (à désactiver)
expose_php = Off
```

#### Comparaison Développement vs Production

|Directive|Développement|Production|Raison|
|---|---|---|---|
|`display_errors`|On|**Off**|Éviter la fuite d'informations|
|`display_startup_errors`|On|**Off**|Masquer les erreurs de configuration|
|`log_errors`|On|**On**|Toujours journaliser|
|`error_reporting`|E_ALL|E_ALL & ~E_DEPRECATED|Filtrer les avertissements mineurs|
|`expose_php`|On|**Off**|Ne pas révéler la version PHP|

### Configuration du fichier de log

```bash
# 1. Créer le répertoire de logs PHP
sudo mkdir -p /var/log/php

# 2. Définir les permissions appropriées
sudo chown www-data:www-data /var/log/php
sudo chmod 750 /var/log/php

# 3. Créer le fichier de log
sudo touch /var/log/php/error.log
sudo chown www-data:www-data /var/log/php/error.log
sudo chmod 640 /var/log/php/error.log
```

> [!tip] Rotation des logs Configurer logrotate pour éviter que les logs ne consomment tout l'espace disque :
> 
> ```bash
> # /etc/logrotate.d/php-error
> /var/log/php/error.log {
>     daily
>     rotate 14
>     compress
>     delaycompress
>     missingok
>     notifempty
>     create 640 www-data www-data
> }
> ```

### Gestion des erreurs critiques

Pour certaines erreurs critiques que vous souhaitez surveiller, utilisez une page d'erreur personnalisée :

```ini
; Rediriger vers une page d'erreur générique
; (Nécessite configuration Apache/Nginx)
error_page = /error.html
```

Avec Apache :

```apache
# Dans .htaccess ou la configuration du VirtualHost
ErrorDocument 500 /error.html
ErrorDocument 503 /error.html
```

> [!example] Page d'erreur générique
> 
> ```html
> <!-- /var/www/html/error.html -->
> <!DOCTYPE html>
> <html>
> <head>
>     <title>Erreur</title>
> </head>
> <body>
>     <h1>Une erreur s'est produite</h1>
>     <p>Veuillez réessayer ultérieurement.</p>
>     <!-- Aucune information technique révélée -->
> </body>
> </html>
> ```

### Vérification de la configuration

```bash
# Vérifier les paramètres actuels
php -i | grep -E "display_errors|log_errors|error_log"

# Tester avec un script PHP
echo "<?php echo 1/0; ?>" | php

# Si display_errors = Off, aucune sortie ne doit apparaître
# L'erreur doit être dans /var/log/php/error.log
```

> [!warning] Pièges courants
> 
> - Oublier de créer le répertoire de logs avec les bonnes permissions
> - Laisser `display_errors = On` dans les fichiers `.htaccess` ou `php.ini` locaux
> - Ne pas configurer la rotation des logs (saturation du disque)
> - Exposer les logs via le serveur web (placer les logs hors de la racine web)

---

## 📁 Limitation d'accès avec open_basedir

### Principe de open_basedir

La directive `open_basedir` restreint les fichiers que PHP peut accéder aux répertoires spécifiés. C'est une forme de chroot pour PHP qui empêche les scripts de lire ou écrire en dehors de zones autorisées.

> [!info] Fonctionnement Lorsque `open_basedir` est défini, toute tentative d'accès à un fichier en dehors des répertoires autorisés provoque une erreur fatale, même si les permissions Unix le permettraient.

### Pourquoi utiliser open_basedir ?

1. **Isoler les applications** : Sur un serveur multi-sites, empêcher un site compromis d'accéder aux fichiers d'un autre
2. **Limiter l'impact d'une intrusion** : Un attaquant ne peut pas lire `/etc/passwd` ou d'autres fichiers système
3. **Prévenir la traversée de répertoires** : Bloquer les attaques par path traversal (`../../../etc/passwd`)

> [!warning] Scénario d'attaque Sans `open_basedir`, un fichier uploadé malveillant pourrait contenir :
> 
> ```php
> <?php
> // Lire le fichier de configuration MySQL
> echo file_get_contents('/etc/mysql/my.cnf');
> // Lister les utilisateurs du système
> echo file_get_contents('/etc/passwd');
> ?>
> ```

### Configuration de base

#### Dans php.ini (global)

```ini
; Limiter l'accès à la racine web et au répertoire temporaire
open_basedir = /var/www/html:/tmp
```

#### Configuration par VirtualHost (recommandé)

```apache
<VirtualHost *:80>
    ServerName site1.example.com
    DocumentRoot /var/www/site1
    
    <Directory /var/www/site1>
        # Restriction pour ce site spécifique
        php_admin_value open_basedir "/var/www/site1:/tmp:/usr/share/php"
    </Directory>
</VirtualHost>

<VirtualHost *:80>
    ServerName site2.example.com
    DocumentRoot /var/www/site2
    
    <Directory /var/www/site2>
        # Restriction différente pour ce site
        php_admin_value open_basedir "/var/www/site2:/tmp:/usr/share/php"
    </Directory>
</VirtualHost>
```

### Répertoires à inclure

|Répertoire|Raison|Exemple|
|---|---|---|
|Racine web|Fichiers de l'application|`/var/www/html`|
|Répertoire temporaire|Sessions, uploads temporaires|`/tmp` ou `/var/tmp`|
|Bibliothèques PHP|Classes PEAR, Composer|`/usr/share/php`|
|Répertoire de sessions|Si personnalisé|`/var/lib/php/sessions`|
|Répertoire d'upload|Stockage fichiers uploadés|`/var/www/uploads`|

> [!tip] Syntaxe multi-répertoires Séparez les répertoires avec `:` (Linux) ou `;` (Windows)
> 
> ```ini
> open_basedir = "/var/www/site1:/tmp:/usr/share/php:/var/www/uploads"
> ```

### Configuration avancée avec PHP-FPM

Pour PHP-FPM, la configuration se fait dans les pools :

```ini
; /etc/php/8.2/fpm/pool.d/site1.conf
[site1]
user = site1
group = site1
listen = /run/php/php8.2-fpm-site1.sock

; Restriction open_basedir pour ce pool
php_admin_value[open_basedir] = /var/www/site1:/tmp:/usr/share/php
```

### Cas d'usage complexes

#### Application avec plusieurs points d'entrée

```ini
; WordPress avec uploads et cache séparés
open_basedir = "/var/www/wordpress:/tmp:/var/www/uploads:/var/www/cache:/usr/share/php"
```

#### Serveur de développement

```ini
; Environnement de dev (plus permissif)
open_basedir = "/var/www:/home/dev:/tmp:/usr/share/php"
```

#### Aucune restriction (à éviter en production)

```ini
; Désactiver open_basedir (dangereux)
open_basedir = none
; OU laisser vide
open_basedir =
```

### Vérification et débogage

```bash
# Vérifier la configuration actuelle
php -i | grep open_basedir

# Tester avec un script PHP
cat > test_basedir.php << 'EOF'
<?php
// Devrait fonctionner
echo file_get_contents('/var/www/html/index.php');

// Devrait échouer
echo file_get_contents('/etc/passwd');
?>
EOF

php test_basedir.php
```

> [!example] Message d'erreur attendu
> 
> ```
> Warning: file_get_contents(): open_basedir restriction in effect. 
> File(/etc/passwd) is not within the allowed path(s): 
> (/var/www/html:/tmp) in test_basedir.php on line 5
> ```

### Impact sur les performances

`open_basedir` a un léger impact sur les performances car PHP doit vérifier chaque accès fichier. Cependant, le coût est négligeable comparé au gain de sécurité.

|Configuration|Overhead|Recommandation|
|---|---|---|
|Pas d'open_basedir|0%|❌ Éviter en production|
|1-3 répertoires|< 1%|✅ Recommandé|
|5+ répertoires|1-2%|⚠️ Acceptable si nécessaire|

> [!warning] Pièges courants
> 
> - Oublier `/tmp` : les sessions PHP échouent
> - Oublier `/usr/share/php` : les bibliothèques PEAR/Composer échouent
> - Chemins non canoniques : utiliser des chemins absolus, pas de liens symboliques
> - Configuration par `.htaccess` : `open_basedir` ne peut être défini que dans `php.ini`, VirtualHost, ou pool FPM (pas en `.htaccess`)
> - Permissions insuffisantes : même avec `open_basedir` correct, l'utilisateur PHP doit avoir les permissions Unix appropriées

### Contournements à surveiller

Même avec `open_basedir`, certaines vulnérabilités peuvent permettre des contournements :

1. **Liens symboliques** : Si un attaquant peut créer un symlink dans un répertoire autorisé pointant vers un répertoire interdit
2. **Fonctions non couvertes** : Certaines fonctions obscures peuvent ne pas respecter `open_basedir` (bugs PHP)
3. **Extensions natives** : Des extensions mal codées peuvent contourner la restriction

> [!tip] Défense en profondeur Combinez `open_basedir` avec :
> 
> - Permissions Unix strictes
> - SELinux ou AppArmor
> - Désactivation de fonctions dangereuses
> - Principe du moindre privilège

---

## 🔄 Mise à jour régulière de PHP

### Pourquoi mettre à jour PHP ?

Les vulnérabilités de sécurité dans PHP sont régulièrement découvertes et corrigées. Une version obsolète expose le serveur à des exploits connus et documentés publiquement.

> [!warning] Risques d'une version obsolète
> 
> - Vulnérabilités zero-day devenues publiques
> - Exploits automatisés ciblant les versions anciennes
> - Non-conformité avec les standards de sécurité (PCI-DSS, ISO 27001)
> - Incompatibilité avec les frameworks modernes

### Cycle de vie des versions PHP

PHP suit un cycle de publication prévisible :

|Phase|Durée|Description|
|---|---|---|
|**Active Support**|2 ans|Corrections de bugs et de sécurité|
|**Security Support**|1 an|Corrections de sécurité uniquement|
|**End of Life (EOL)**|Après 3 ans|⚠️ Aucun support, vulnérable|

#### Versions PHP et leur statut (2024-2025)

|Version|Active jusqu'à|Security jusqu'à|Statut|
|---|---|---|---|
|PHP 8.3|23 Nov 2025|23 Nov 2026|✅ Recommandé|
|PHP 8.2|08 Déc 2024|08 Déc 2025|✅ Supporté|
|PHP 8.1|25 Nov 2023|25 Nov 2024|⚠️ Security only|
|PHP 8.0|26 Nov 2022|26 Nov 2023|❌ EOL|
|PHP 7.4|28 Nov 2021|28 Nov 2022|❌ EOL|
|PHP 7.3 et antérieures|-|-|❌ EOL critique|

> [!info] Source officielle Consultez toujours https://www.php.net/supported-versions.php pour les dates exactes

### Stratégie de mise à jour

#### 1. Surveillance des annonces de sécurité

```bash
# S'abonner aux annonces de sécurité PHP
# Via la mailing list officielle ou RSS
# https://www.php.net/mailing-lists.php
```

Surveiller également :

- CVE Database (https://cve.mitre.org)
- PHP Security Advisories (https://www.php.net/security)
- Ubuntu Security Notices (pour les paquets système)

#### 2. Vérification de la version actuelle

```bash
# Version PHP CLI
php -v

# Version PHP pour Apache
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
# Accéder à http://votre-serveur/info.php
# PUIS SUPPRIMER LE FICHIER !
rm /var/www/html/info.php

# Version via la ligne de commande (plus sûr)
php -r "echo PHP_VERSION;"
```

#### 3. Mise à jour sur Ubuntu/Debian

```bash
# Mettre à jour la liste des paquets
sudo apt update

# Vérifier les mises à jour disponibles pour PHP
apt list --upgradable | grep php

# Mettre à jour PHP (version mineure/patch)
sudo apt upgrade php8.2

# OU mettre à jour tout le système
sudo apt upgrade

# Redémarrer Apache pour appliquer
sudo systemctl restart apache2
```

#### 4. Migration vers une version majeure

Pour passer à une nouvelle version majeure (ex: PHP 8.1 → 8.2) :

```bash
# 1. Ajouter le repository ondrej/php (si nécessaire)
sudo add-apt-repository ppa:ondrej/php
sudo apt update

# 2. Installer la nouvelle version
sudo apt install php8.3 php8.3-common php8.3-mysql php8.3-xml php8.3-curl php8.3-gd php8.3-mbstring php8.3-zip

# 3. Installer les modules Apache
sudo apt install libapache2-mod-php8.3

# 4. Désactiver l'ancienne version et activer la nouvelle
sudo a2dismod php8.2
sudo a2enmod php8.3

# 5. Redémarrer Apache
sudo systemctl restart apache2

# 6. Vérifier la version active
php -v

# 7. Tester l'application

# 8. Désinstaller l'ancienne version (optionnel)
sudo apt remove php8.2
```

> [!warning] Tests avant migration majeure Avant une migration majeure :
> 
> 1. Lire les notes de migration (https://www.php.net/migration83)
> 2. Tester sur un environnement de développement/staging
> 3. Vérifier la compatibilité des dépendances Composer
> 4. Planifier une fenêtre de maintenance
> 5. Préparer un plan de rollback

### Processus de mise à jour recommandé

#### Environnement de production

1. **Planification**
    
    - Lire les changelogs et breaking changes
    - Identifier les dépendances affectées
    - Prévoir une fenêtre de maintenance
2. **Test en staging**
    
    ```bash
    # Cloner l'environnement de production
    # Appliquer la mise à jour
    # Exécuter la suite de tests
    # Vérifier les logs d'erreurs
    ```
    
3. **Sauvegarde**
    
    ```bash
    # Sauvegarder la base de données
    sudo mysqldump --all-databases > backup_$(date +%Y%m%d).sql
    
    # Sauvegarder les fichiers
    sudo tar -czf /backup/www_$(date +%Y%m%d).tar.gz /var/www
    
    # Sauvegarder la configuration
    sudo cp /etc/php/8.2/apache2/php.ini /backup/php.ini.backup
    ```
    
4. **Mise à jour**
    
    ```bash
    # Appliquer la mise à jour
    sudo apt update && sudo apt upgrade php8.2
    
    # Redémarrer les services
    sudo systemctl restart apache2
    ```
    
5. **Vérification**
    
    ```bash
    # Vérifier la version
    php -v
    
    # Vérifier les logs
    sudo tail -f /var/log/apache2/error.log
    sudo tail -f /var/log/php/error.log
    
    # Tester l'application
    curl -I https://votre-site.com
    ```
    
6. **Monitoring post-mise à jour**
    
    - Surveiller les métriques (CPU, mémoire, temps de réponse)
    - Vérifier les logs d'erreur pendant 24-48h
    - Recueillir les retours utilisateurs

### Automatisation des mises à jour

#### Configuration unattended-upgrades (Ubuntu)

```bash
# Installer le paquet
sudo apt install unattended-upgrades

# Configurer pour PHP
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

```conf
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "LP-PPA-ondrej-php:${distro_codename}";  // Pour mises à jour PHP
};

// Redémarrage automatique si nécessaire
Unattended-Upgrade::Automatic-Reboot "false";  // À activer avec prudence

// Email de notification
Unattended-Upgrade::Mail "admin@example.com";
```

> [!warning] Prudence avec les mises à jour automatiques Pour les serveurs de production critiques :
> 
> - Activer uniquement les mises à jour de sécurité
> - Désactiver le redémarrage automatique
> - Tester manuellement les mises à jour majeures
> - Privilégier les fenêtres de maintenance planifiées

### Compatibilité et breaking changes

#### PHP 7.4 → 8.0

Changements majeurs :

- Paramètres nommés
- Union types
- JIT compiler
- Promotion de propriétés de constructeur
- Gestion d'erreurs stricte

#### PHP 8.0 → 8.1

Nouveautés :

- Enums
- Readonly properties
- Fibers
- Never return type
- New in initializers

#### PHP 8.1 → 8.2

Nouveautés :

- Readonly classes
- Null, false, true types
- Traits constants
- Deprecation de dynamic properties

#### PHP 8.2 → 8.3

Nouveautés :

- Typed class constants
- json_validate()
- Randomizer additions
- Dynamic class constant fetch

> [!tip] Gestion de la compatibilité Utilisez des outils comme PHPCompatibility pour détecter les incompatibilités :
> 
> ```bash
> composer require --dev phpcompatibility/php-compatibility
> vendor/bin/phpcs --standard=PHPCompatibility --runtime-set testVersion 8.3 /var/www/html
> ```

### Checklist de mise à jour

- [ ] Vérifier la version actuelle de PHP
- [ ] Consulter les notes de migration de la version cible
- [ ] Sauvegarder base de données et fichiers
- [ ] Tester en environnement de staging
- [ ] Vérifier la compatibilité des dépendances (Composer)
- [ ] Planifier une fenêtre de maintenance
- [ ] Informer les utilisateurs de la maintenance
- [ ] Appliquer la mise à jour
- [ ] Vérifier la version installée
- [ ] Tester l'application
- [ ] Surveiller les logs pendant 24-48h
- [ ] Documenter les problèmes rencontrés

> [!warning] Pièges courants
> 
> - Mettre à jour sans tester sur un environnement de staging
> - Ne pas lire les breaking changes
> - Oublier de mettre à jour les extensions PHP (mysql, gd, curl, etc.)
> - Ne pas vérifier les dépendances Composer
> - Appliquer des mises à jour majeures en heures pleines
> - Ne pas avoir de plan de rollback

### Rollback en cas de problème

Si la mise à jour cause des problèmes critiques :

```bash
# Restaurer l'ancienne version PHP (si toujours disponible)
sudo a2dismod php8.3
sudo a2enmod php8.2
sudo systemctl restart apache2

# Restaurer la sauvegarde de configuration
sudo cp /backup/php.ini.backup /etc/php/8.2/apache2/php.ini

# Restaurer les fichiers si nécessaire
sudo tar -xzf /backup/www_20241222.tar.gz -C /

# Restaurer la base de données si nécessaire
mysql -u root -p < /backup/backup_20241222.sql
```

---

## 🎯 Synthèse de la sécurisation PHP

La sécurisation de PHP dans une stack LAMP repose sur quatre piliers complémentaires :

|Mesure|Impact Sécurité|Complexité|Priorité|
|---|---|---|---|
|**Désactivation de fonctions**|🔴 Élevé|🟢 Faible|⭐⭐⭐ Critique|
|**Masquage des erreurs**|🟠 Moyen|🟢 Faible|⭐⭐⭐ Critique|
|**open_basedir**|🟠 Moyen|🟡 Moyenne|⭐⭐ Important|
|**Mises à jour**|🔴 Élevé|🟡 Moyenne|⭐⭐⭐ Critique|

### Configuration minimale de production

```ini
; /etc/php/8.3/apache2/php.ini - Configuration sécurisée minimale

; Désactivation de fonctions dangereuses
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source

; Masquage des erreurs
display_errors = Off
display_startup_errors = Off
log_errors = On
error_log = /var/log/php/error.log
expose_php = Off

; Limitation d'accès fichiers
open_basedir = /var/www/html:/tmp:/usr/share/php

; Autres paramètres de sécurité
file_uploads = On
upload_max_filesize = 10M
max_file_uploads = 5
allow_url_fopen = On
allow_url_include = Off
```

> [!tip] Application immédiate Pour appliquer cette configuration :
> 
> ```bash
> sudo nano /etc/php/8.3/apache2/php.ini
> # Copier la configuration ci-dessus
> sudo systemctl restart apache2
> # Vérifier
> php -i | grep -E "disable_functions|display_errors|open_basedir"
> ```

### Approche défense en profondeur

La sécurité PHP ne doit jamais reposer sur une seule mesure. Combinez ces quatre axes avec :

1. **Permissions système strictes**
    
    ```bash
    # Fichiers : lecture seule pour www-data
    sudo find /var/www/html -type f -exec chmod 644 {} \;
    # Répertoires : exécution pour parcourir
    sudo find /var/www/html -type d -exec chmod 755 {} \;
    # Propriétaire : utilisateur différent de www-data
    sudo chown -R deploy:www-data /var/www/html
    ```
    
2. **Pare-feu applicatif (WAF)**
    
    - ModSecurity pour Apache
    - Filtrage des patterns d'attaque connus
    - Protection contre les injections
3. **Surveillance et monitoring**
    
    - Alertes sur les erreurs critiques
    - Surveillance des tentatives d'accès suspects
    - Analyse régulière des logs
4. **Validation des entrées utilisateur**
    
    - Toujours dans le code PHP lui-même
    - Ne jamais faire confiance aux données externes
    - Utiliser des requêtes préparées pour SQL

> [!warning] Rappel important La configuration PHP sécurisée est une **base**, pas une solution complète. Elle doit être combinée avec :
> 
> - Code applicatif sécurisé
> - Architecture système durcie
> - Processus de mise à jour rigoureux
> - Monitoring et réponse aux incidents

### Vérification finale de la sécurisation

Script de vérification rapide :

```bash
#!/bin/bash
# check-php-security.sh - Vérification de la configuration PHP

echo "=== Vérification de la sécurisation PHP ==="
echo ""

# Version PHP
echo "1. Version PHP :"
php -v | head -n 1

# Fonctions désactivées
echo ""
echo "2. Fonctions dangereuses désactivées :"
php -i | grep disable_functions | cut -d'>' -f2

# Affichage des erreurs
echo ""
echo "3. Affichage des erreurs (doit être Off) :"
php -i | grep "display_errors" | head -n 1

# Log des erreurs
echo ""
echo "4. Journalisation des erreurs (doit être On) :"
php -i | grep "log_errors" | head -n 1

# open_basedir
echo ""
echo "5. Restriction open_basedir :"
php -i | grep "open_basedir"

# expose_php
echo ""
echo "6. Exposition de PHP (doit être Off) :"
php -i | grep "expose_php"

echo ""
echo "=== Fin de la vérification ==="
```

```bash
# Rendre le script exécutable
chmod +x check-php-security.sh

# Exécuter
./check-php-security.sh
```

### Maintenance continue

La sécurisation PHP n'est pas une action ponctuelle mais un processus continu :

**Mensuel :**

- Vérifier les mises à jour de sécurité disponibles
- Analyser les logs d'erreurs pour détecter des tentatives d'attaque
- Revoir la liste des fonctions désactivées en fonction de l'évolution de l'application

**Trimestriel :**

- Auditer la configuration complète de PHP
- Tester la restauration des sauvegardes
- Revoir les permissions fichiers

**Annuel :**

- Planifier la migration vers une version majeure si nécessaire
- Audit de sécurité complet de la stack LAMP
- Formation de l'équipe sur les nouvelles menaces

> [!info] Documentation et traçabilité Documentez toutes les modifications de configuration :
> 
> - Date de modification
> - Raison du changement
> - Tests effectués
> - Personne responsable
> 
> Conservez l'historique dans un système de gestion de configuration (Git, documentation interne, etc.)

---

## 📚 Points clés à retenir

### Désactivation de fonctions dangereuses

- ✅ Bloquer `exec()`, `system()`, `shell_exec()`, `proc_open()` en priorité
- ✅ Adapter la liste selon les besoins réels de l'application
- ✅ Tester après désactivation pour détecter les dépendances

### Gestion des erreurs

- ✅ `display_errors = Off` en production (toujours)
- ✅ `log_errors = On` avec un fichier de log dédié
- ✅ Configurer la rotation des logs
- ✅ `expose_php = Off` pour masquer la version

### open_basedir

- ✅ Restreindre aux répertoires strictement nécessaires
- ✅ Inclure `/tmp` pour les sessions
- ✅ Configuration par VirtualHost pour l'isolation multi-sites
- ✅ Combiner avec les permissions Unix

### Mises à jour

- ✅ Suivre le cycle de support PHP officiel
- ✅ Tester en staging avant la production
- ✅ Sauvegarder avant chaque mise à jour
- ✅ Planifier les migrations majeures avec soin
- ✅ Surveiller les annonces de sécurité

### Approche globale

- ✅ Défense en profondeur : combiner plusieurs mesures
- ✅ Maintenance continue : la sécurité est un processus
- ✅ Documentation : tracer toutes les modifications
- ✅ Monitoring : détecter rapidement les anomalies

---

_Ce document couvre la sécurisation PHP dans le cadre d'une stack LAMP. Pour une sécurité optimale, ces mesures doivent être combinées avec la sécurisation d'Apache, MySQL, du système d'exploitation et des applications déployées._