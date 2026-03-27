

> [!info] Contexte PHP (Hypertext Preprocessor) est le langage de script côté serveur qui constitue le "P" dans LAMP. Il permet de générer dynamiquement du contenu web en interagissant avec la base de données et en traitant les requêtes utilisateurs.

---

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

## 🔧 Installation de PHP

### Installation de base

L'installation de PHP sur un système Linux se fait via le gestionnaire de paquets de la distribution.

#### Sur Ubuntu/Debian

```bash
# Mise à jour des paquets
sudo apt update

# Installation de PHP et du module Apache
sudo apt install php libapache2-mod-php
```

> [!info] Module Apache `libapache2-mod-php` est le module qui permet à Apache de traiter les fichiers PHP. Sans ce module, Apache servirait les fichiers PHP comme du texte brut.

#### Sur CentOS/RHEL

```bash
# Installation de PHP et du module Apache
sudo yum install php php-common

# Ou avec DNF (versions récentes)
sudo dnf install php php-common
```

---

### Installation des modules PHP courants

PHP seul est limité. Les modules (ou extensions) ajoutent des fonctionnalités essentielles pour le développement web.

#### Modules essentiels pour LAMP

```bash
# Ubuntu/Debian
sudo apt install php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip

# CentOS/RHEL
sudo yum install php-mysqlnd php-cli php-curl php-gd php-mbstring php-xml php-zip
```

#### Tableau des modules courants

|Module|Description|Usage typique|
|---|---|---|
|`php-mysql` / `php-mysqlnd`|Connexion MySQL/MariaDB|Obligatoire pour communiquer avec la base de données|
|`php-cli`|Interface en ligne de commande|Scripts PHP hors web, Composer, artisan|
|`php-curl`|Client HTTP|Appels API, téléchargements|
|`php-gd`|Manipulation d'images|Redimensionnement, thumbnails, watermarks|
|`php-mbstring`|Gestion multi-bytes|Support UTF-8, caractères internationaux|
|`php-xml`|Traitement XML|Parsing XML, SOAP, RSS|
|`php-zip`|Compression/décompression|Archives, imports/exports|
|`php-json`|Encodage/décodage JSON|APIs REST (généralement inclus par défaut)|
|`php-intl`|Internationalisation|Formatage dates, nombres selon locales|
|`php-bcmath`|Calculs en précision arbitraire|Calculs financiers, cryptographie|

> [!example] Exemple d'installation ciblée Pour une application WordPress :
> 
> ```bash
> sudo apt install php php-mysql php-curl php-gd php-mbstring php-xml php-zip php-imagick
> ```

---

### Activation et redémarrage d'Apache

Après l'installation de PHP, il faut redémarrer Apache pour charger le module.

```bash
# Ubuntu/Debian
sudo systemctl restart apache2

# CentOS/RHEL
sudo systemctl restart httpd
```

> [!warning] Redémarrage obligatoire Sans redémarrage, Apache ne reconnaîtra pas PHP et continuera à servir les fichiers `.php` comme du texte brut.

---

## 📌 Versions de PHP

### Comprendre les versions de PHP

PHP suit un cycle de versionnement sémantique : `MAJEUR.MINEUR.CORRECTIF`

- **Majeur** : Changements incompatibles, nouvelles fonctionnalités majeures
- **Mineur** : Nouvelles fonctionnalités compatibles
- **Correctif** : Corrections de bugs

> [!info] Cycle de vie Chaque version de PHP a un cycle de support :
> 
> - **Active support** : 2 ans (nouvelles fonctionnalités et corrections)
> - **Security support** : 1 an supplémentaire (corrections de sécurité uniquement)
> - Après 3 ans total : **End of Life (EOL)** - plus aucun support

### Vérifier la version disponible

```bash
# Version par défaut dans les dépôts
apt-cache policy php

# Ou
yum info php
```

### Versions actuelles (fin 2024)

|Version|Statut|Notes|
|---|---|---|
|PHP 8.3|Active support|Version recommandée, dernières fonctionnalités|
|PHP 8.2|Active support|Stable et moderne|
|PHP 8.1|Security support|Support jusqu'à fin 2024|
|PHP 8.0|EOL|Ne plus utiliser|
|PHP 7.4|EOL|Migration urgente nécessaire|

> [!warning] Attention aux versions EOL Utiliser une version EOL expose votre serveur à des failles de sécurité non corrigées. Planifiez toujours les migrations avant la fin du support.

---

### Installer une version spécifique de PHP

Par défaut, les dépôts officiels proposent souvent des versions anciennes. Pour obtenir des versions récentes :

#### Sur Ubuntu/Debian avec le dépôt Ondřej Surý

```bash
# Ajout du dépôt PPA
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update

# Installation d'une version spécifique
sudo apt install php8.3 php8.3-mysql php8.3-cli php8.3-curl php8.3-gd

# Ou PHP 8.2
sudo apt install php8.2 php8.2-mysql php8.2-cli php8.2-curl php8.2-gd
```

#### Sur CentOS/RHEL avec Remi

```bash
# Installation du dépôt EPEL et Remi
sudo yum install epel-release
sudo yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm

# Activation du module PHP 8.3
sudo dnf module reset php
sudo dnf module enable php:remi-8.3
sudo dnf install php php-mysqlnd php-cli php-curl php-gd
```

> [!tip] Astuce : Cohabitation de versions Il est possible d'installer plusieurs versions de PHP simultanément et de choisir laquelle utiliser avec Apache ou en ligne de commande. Cela nécessite l'utilisation de PHP-FPM (sujet d'une autre partie).

---

### Gérer plusieurs versions installées

```bash
# Lister les versions de PHP installées
dpkg -l | grep php | grep -E 'php[0-9]\.[0-9]'

# Changer la version par défaut en CLI
sudo update-alternatives --config php

# Désactiver une version dans Apache
sudo a2dismod php8.2

# Activer une autre version
sudo a2enmod php8.3
sudo systemctl restart apache2
```

---

## ✅ Vérification de l'installation

### Vérification en ligne de commande

#### Version de PHP

```bash
# Afficher la version installée
php -v
```

**Sortie attendue :**

```
PHP 8.3.1 (cli) (built: Dec 20 2023 12:45:23) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.3.1, Copyright (c) Zend Technologies
    with Zend OPcache v8.3.1, Copyright (c), by Zend Technologies
```

> [!info] Informations importantes
> 
> - **Version** : 8.3.1
> - **(cli)** : Interface en ligne de commande
> - **(NTS)** : Non Thread Safe (normal pour Linux)
> - **Zend OPcache** : Cache de bytecode activé (bon pour les performances)

---

#### Modules installés

```bash
# Lister tous les modules PHP chargés
php -m

# Vérifier un module spécifique
php -m | grep mysql
php -m | grep curl
```

**Exemple de sortie :**

```
[PHP Modules]
calendar
Core
ctype
curl
date
dom
...
mysql
mysqli
pdo
pdo_mysql
...
```

---

#### Configuration PHP

```bash
# Afficher toute la configuration
php -i

# Afficher uniquement la configuration (plus lisible)
php -i | grep -E 'Configuration File|memory_limit|upload_max_filesize'

# Trouver le fichier php.ini utilisé
php --ini
```

**Sortie de `php --ini` :**

```
Configuration File (php.ini) Path: /etc/php/8.3/cli
Loaded Configuration File:         /etc/php/8.3/cli/php.ini
Scan for additional .ini files in: /etc/php/8.3/cli/conf.d
Additional .ini files parsed:      /etc/php/8.3/cli/conf.d/10-mysqlnd.ini,
                                   /etc/php/8.3/cli/conf.d/10-opcache.ini,
                                   ...
```

> [!warning] CLI vs Apache La configuration PHP en ligne de commande (`/etc/php/8.3/cli/php.ini`) est différente de celle utilisée par Apache (`/etc/php/8.3/apache2/php.ini`). Les modifications doivent être faites dans le bon fichier selon le contexte.

---

### Vérification via le navigateur web

#### Créer un fichier de test PHP

```bash
# Créer le fichier info.php dans le répertoire web
sudo nano /var/www/html/info.php
```

**Contenu du fichier :**

```php
<?php
phpinfo();
?>
```

#### Accéder au fichier via le navigateur

Ouvrez votre navigateur et accédez à :

```
http://votre-serveur/info.php
# ou
http://localhost/info.php
```

> [!example] Que voir sur la page phpinfo() La page affiche :
> 
> - Version de PHP et Zend Engine
> - Configuration complète (php.ini)
> - Modules chargés avec leurs options
> - Variables d'environnement
> - Headers HTTP

---

#### Interpréter les informations importantes

**Éléments à vérifier :**

1. **Version de PHP** : En haut de la page, vérifiez que c'est la version attendue
    
2. **Server API** : Doit indiquer `Apache 2.0 Handler` (ou FPM/FastCGI selon configuration)
    
3. **Loaded Configuration File** : Chemin du fichier php.ini utilisé par Apache
    
    ```
    /etc/php/8.3/apache2/php.ini
    ```
    
4. **Modules actifs** : Descendez pour vérifier la présence de :
    
    - `mysql` ou `mysqli` : Connexion MySQL
    - `PDO` : Interface base de données
    - `curl` : Requêtes HTTP
    - `gd` : Manipulation d'images
5. **Paramètres critiques** :
    
    - `memory_limit` : Mémoire allouée (min 128M)
    - `upload_max_filesize` : Taille max uploads (par défaut 2M)
    - `post_max_size` : Taille max POST (doit être > upload_max_filesize)
    - `max_execution_time` : Temps max exécution script (30s par défaut)

> [!tip] Recherche rapide Utilisez `Ctrl+F` dans le navigateur pour rechercher rapidement un paramètre ou module spécifique dans la page phpinfo().

---

#### Supprimer le fichier de test

> [!warning] Sécurité Le fichier `info.php` expose des informations sensibles sur votre configuration serveur. **Supprimez-le immédiatement** après vérification.

```bash
sudo rm /var/www/html/info.php
```

---

### Test fonctionnel simple

Créer un script de test plus sûr que phpinfo() :

```bash
sudo nano /var/www/html/test.php
```

**Contenu :**

```php
<?php
// Test basique
echo "<h1>PHP fonctionne !</h1>";
echo "<p>Version PHP : " . phpinfo(INFO_GENERAL) . "</p>";

// Test MySQL
if (extension_loaded('mysqli')) {
    echo "<p>✓ Module MySQL chargé</p>";
} else {
    echo "<p>✗ Module MySQL absent</p>";
}

// Test écriture
$test_file = '/tmp/php_test_' . time() . '.txt';
if (file_put_contents($test_file, 'test')) {
    echo "<p>✓ Écriture fichier OK</p>";
    unlink($test_file);
} else {
    echo "<p>✗ Problème d'écriture</p>";
}
?>
```

Accédez à `http://votre-serveur/test.php` pour vérifier le bon fonctionnement.

---

### Vérification des logs

En cas de problème, consultez les logs :

```bash
# Logs Apache
sudo tail -f /var/log/apache2/error.log  # Debian/Ubuntu
sudo tail -f /var/log/httpd/error_log    # CentOS/RHEL

# Logs PHP (si configurés)
sudo tail -f /var/log/php/error.log
```

> [!tip] Astuce de débogage Si PHP ne s'exécute pas :
> 
> 1. Vérifiez que le module Apache est chargé : `apache2ctl -M | grep php`
> 2. Vérifiez les permissions du fichier PHP : `ls -l /var/www/html/test.php`
> 3. Vérifiez la configuration Apache pour les fichiers PHP
> 4. Consultez les logs d'erreur

---

## 🎯 Pièges courants

> [!warning] Erreur : Page affiche le code PHP **Symptôme** : Le navigateur affiche `<?php echo "test"; ?>` au lieu d'exécuter le code.
> 
> **Causes possibles** :
> 
> - Module PHP non activé dans Apache
> - Apache n'a pas été redémarré après installation
> - Configuration Apache ne traite pas les `.php`
> 
> **Solution** :
> 
> ```bash
> sudo a2enmod php8.3  # Remplacer par votre version
> sudo systemctl restart apache2
> ```

> [!warning] Erreur : Module MySQL absent **Symptôme** : `Fatal error: Call to undefined function mysqli_connect()`
> 
> **Solution** :
> 
> ```bash
> sudo apt install php-mysql
> sudo systemctl restart apache2
> ```

> [!warning] Versions PHP multiples Si plusieurs versions sont installées, assurez-vous que la bonne est activée dans Apache :
> 
> ```bash
> sudo a2dismod php7.4
> sudo a2enmod php8.3
> sudo systemctl restart apache2
> ```

---

## 💡 Bonnes pratiques

### Maintenance et mises à jour

```bash
# Mettre à jour régulièrement PHP et ses modules
sudo apt update
sudo apt upgrade php php-*

# Vérifier les mises à jour de sécurité
sudo apt list --upgradable | grep php
```

### Documentation de votre installation

Gardez une trace de votre configuration :

```bash
# Sauvegarder la liste des modules installés
php -m > ~/php-modules-$(date +%F).txt

# Sauvegarder la configuration
php -i > ~/php-config-$(date +%F).txt
```

### Sécurité de base

- Ne laissez **jamais** `info.php` en production
- Installez uniquement les modules nécessaires
- Tenez PHP à jour (patches de sécurité)
- Surveillez les annonces de fin de support

---

## 🎓 Résumé

À ce stade, vous devez avoir :

✅ PHP installé avec les modules essentiels  
✅ Une compréhension des versions et leur cycle de vie  
✅ La capacité de vérifier votre installation (CLI et web)  
✅ Un environnement PHP fonctionnel prêt pour le développement

Le serveur LAMP dispose maintenant de sa couche de traitement PHP. L'étape suivante consistera à configurer PHP en profondeur pour optimiser les performances et la sécurité (sujet d'une prochaine partie).