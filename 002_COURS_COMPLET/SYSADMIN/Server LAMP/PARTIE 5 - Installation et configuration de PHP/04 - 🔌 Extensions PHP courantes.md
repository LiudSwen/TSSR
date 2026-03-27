

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

## 🎯 Introduction aux extensions PHP

Les extensions PHP sont des modules qui ajoutent des fonctionnalités spécifiques au langage. Par défaut, PHP est installé avec un ensemble d'extensions de base, mais de nombreuses fonctionnalités avancées nécessitent l'installation d'extensions supplémentaires.

> [!info] Pourquoi les extensions sont importantes
> 
> - Elles permettent à PHP d'interagir avec des bases de données, des services web, des formats d'images, etc.
> - Sans les bonnes extensions, votre application ne pourra pas fonctionner correctement
> - Elles sont optimisées en C pour de meilleures performances que du code PHP pur

> [!tip] Convention de nommage Les extensions PHP suivent généralement le format `php-nomextension` pour les packages Debian/Ubuntu, et `php##-nomextension` où ## représente la version de PHP (ex: `php8.2-mysql`).

---

## 🗄️ Extensions pour MySQL/MariaDB

Pour permettre à PHP de communiquer avec MySQL ou MariaDB, vous devez installer au moins une des extensions suivantes.

### mysqli

L'extension **mysqli** (MySQL Improved) est une amélioration de l'ancienne extension mysql (maintenant obsolète). Elle offre une interface procédurale et orientée objet pour interagir avec MySQL/MariaDB.

#### Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install php-mysqli

# Ou pour une version spécifique
sudo apt install php8.2-mysqli

# Redémarrer Apache pour charger l'extension
sudo systemctl restart apache2
```

#### Caractéristiques principales

- Support des requêtes préparées (protection contre les injections SQL)
- Interface procédurale ET orientée objet
- Support des transactions
- Meilleure gestion des erreurs que l'ancienne extension mysql

> [!example] Exemple d'utilisation (orienté objet)
> 
> ```php
> <?php
> // Connexion à la base de données
> $mysqli = new mysqli("localhost", "utilisateur", "motdepasse", "ma_base");
> 
> // Vérification de la connexion
> if ($mysqli->connect_error) {
>     die("Connexion échouée : " . $mysqli->connect_error);
> }
> 
> // Requête préparée (sécurisée)
> $stmt = $mysqli->prepare("SELECT nom, email FROM utilisateurs WHERE id = ?");
> $stmt->bind_param("i", $user_id);
> $user_id = 1;
> $stmt->execute();
> $stmt->bind_result($nom, $email);
> $stmt->fetch();
> 
> echo "Nom: $nom, Email: $email";
> 
> $stmt->close();
> $mysqli->close();
> ?>
> ```

> [!warning] Pièges courants
> 
> - Oublier de fermer les connexions peut épuiser les ressources du serveur
> - Ne pas utiliser les requêtes préparées expose votre application aux injections SQL
> - Confondre les méthodes procédurales et orientées objet dans le même code

---

### pdo_mysql

L'extension **PDO** (PHP Data Objects) avec le driver MySQL offre une interface orientée objet uniforme pour accéder à différents types de bases de données.

#### Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install php-mysql

# Ou pour une version spécifique
sudo apt install php8.2-mysql

# Cette commande installe à la fois PDO et le driver MySQL
# Redémarrer Apache
sudo systemctl restart apache2
```

#### Caractéristiques principales

- Interface uniforme pour différentes bases de données (MySQL, PostgreSQL, SQLite, etc.)
- Support natif des requêtes préparées
- Gestion des erreurs via exceptions
- Plus moderne et flexible que mysqli

> [!example] Exemple d'utilisation
> 
> ```php
> <?php
> try {
>     // Connexion avec PDO
>     $pdo = new PDO(
>         "mysql:host=localhost;dbname=ma_base;charset=utf8mb4",
>         "utilisateur",
>         "motdepasse",
>         [
>             PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
>             PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
>         ]
>     );
>     
>     // Requête préparée
>     $stmt = $pdo->prepare("SELECT nom, email FROM utilisateurs WHERE id = :id");
>     $stmt->execute(['id' => 1]);
>     $user = $stmt->fetch();
>     
>     echo "Nom: {$user['nom']}, Email: {$user['email']}";
>     
> } catch (PDOException $e) {
>     die("Erreur de connexion : " . $e->getMessage());
> }
> ?>
> ```

> [!tip] Bonnes pratiques PDO
> 
> - Toujours définir `PDO::ATTR_ERRMODE` à `PDO::ERRMODE_EXCEPTION` pour une meilleure gestion des erreurs
> - Utiliser `charset=utf8mb4` dans le DSN pour un support Unicode complet
> - Les placeholders nommés (`:id`) sont plus lisibles que les `?`

---

### Comparaison mysqli vs PDO

|Critère|mysqli|PDO|
|---|---|---|
|**Bases de données supportées**|MySQL/MariaDB uniquement|MySQL, PostgreSQL, SQLite, Oracle, etc.|
|**Interface**|Procédurale ET orientée objet|Orientée objet uniquement|
|**Requêtes préparées**|✅ Oui|✅ Oui|
|**Gestion d'erreurs**|Retours booléens + mysqli_error()|Exceptions (plus moderne)|
|**Portabilité**|❌ Non portable|✅ Portable entre SGBD|
|**Performance**|Légèrement plus rapide pour MySQL|Très légèrement plus lent|
|**Popularité**|Encore utilisé dans du code legacy|Standard moderne recommandé|

> [!tip] Quelle extension choisir ?
> 
> - **PDO** : recommandé pour les nouveaux projets, surtout si vous pouvez changer de SGBD à l'avenir
> - **mysqli** : acceptable si vous êtes certain de rester sur MySQL/MariaDB et préférez une interface procédurale

---

## 🌐 Extensions web essentielles

### curl

L'extension **cURL** permet à PHP d'effectuer des requêtes HTTP/HTTPS vers des API externes, des services web, ou de télécharger du contenu distant.

#### Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install php-curl

# Ou pour une version spécifique
sudo apt install php8.2-curl

# Redémarrer Apache
sudo systemctl restart apache2
```

#### Cas d'usage courants

- Consommer des API REST (GET, POST, PUT, DELETE)
- Télécharger des fichiers depuis des URLs
- Envoyer des webhooks
- Effectuer des requêtes authentifiées (OAuth, API keys)
- Scraping web (bien que des bibliothèques dédiées soient préférables)

> [!example] Exemple d'utilisation - Requête GET simple
> 
> ```php
> <?php
> // Initialiser cURL
> $ch = curl_init();
> 
> // Configuration
> curl_setopt($ch, CURLOPT_URL, "https://api.example.com/users/1");
> curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); // Retourner le résultat au lieu de l'afficher
> curl_setopt($ch, CURLOPT_TIMEOUT, 10); // Timeout de 10 secondes
> 
> // Exécution
> $response = curl_exec($ch);
> $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
> 
> // Gestion d'erreurs
> if (curl_errno($ch)) {
>     echo "Erreur cURL : " . curl_error($ch);
> } else {
>     echo "Code HTTP : $http_code\n";
>     $data = json_decode($response, true);
>     print_r($data);
> }
> 
> // Fermeture
> curl_close($ch);
> ?>
> ```

> [!example] Exemple - Requête POST avec données JSON
> 
> ```php
> <?php
> $data = [
>     'nom' => 'Dupont',
>     'email' => 'dupont@example.com'
> ];
> 
> $ch = curl_init();
> curl_setopt($ch, CURLOPT_URL, "https://api.example.com/users");
> curl_setopt($ch, CURLOPT_POST, true);
> curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
> curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
> curl_setopt($ch, CURLOPT_HTTPHEADER, [
>     'Content-Type: application/json',
>     'Authorization: Bearer votre_token_ici'
> ]);
> 
> $response = curl_exec($ch);
> curl_close($ch);
> 
> echo $response;
> ?>
> ```

> [!warning] Sécurité avec cURL
> 
> - **Toujours valider les URLs** avant de les passer à cURL
> - Ne désactivez **jamais** la vérification SSL (`CURLOPT_SSL_VERIFYPEER`) en production
> - Définissez des **timeouts appropriés** pour éviter les blocages
> - Attention aux redirections infinies : limitez avec `CURLOPT_MAXREDIRS`

> [!tip] Astuces cURL
> 
> - Utilisez `CURLOPT_VERBOSE` pour déboguer les requêtes complexes
> - `CURLOPT_FOLLOWLOCATION` permet de suivre automatiquement les redirections HTTP
> - Pour des requêtes multiples, réutilisez le même handle cURL avec `curl_reset()`

---

### gd

L'extension **GD** (Graphics Draw) permet de manipuler des images directement en PHP : création, redimensionnement, ajout de texte, filtres, etc.

#### Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install php-gd

# Ou pour une version spécifique
sudo apt install php8.2-gd

# Redémarrer Apache
sudo systemctl restart apache2
```

#### Cas d'usage courants

- Redimensionner des images uploadées par les utilisateurs
- Créer des thumbnails (miniatures)
- Ajouter des watermarks (filigranes)
- Générer des CAPTCHA
- Créer des graphiques simples
- Conversion entre formats (JPEG, PNG, GIF, WebP)

> [!example] Exemple - Redimensionner une image
> 
> ```php
> <?php
> // Image source
> $source = 'photo_originale.jpg';
> $destination = 'photo_miniature.jpg';
> 
> // Dimensions souhaitées
> $largeur_max = 800;
> $hauteur_max = 600;
> 
> // Charger l'image source
> $image_source = imagecreatefromjpeg($source);
> $largeur_source = imagesx($image_source);
> $hauteur_source = imagesy($image_source);
> 
> // Calculer les nouvelles dimensions (en gardant le ratio)
> $ratio = min($largeur_max / $largeur_source, $hauteur_max / $hauteur_source);
> $nouvelle_largeur = (int)($largeur_source * $ratio);
> $nouvelle_hauteur = (int)($hauteur_source * $ratio);
> 
> // Créer la nouvelle image
> $image_destination = imagecreatetruecolor($nouvelle_largeur, $nouvelle_hauteur);
> 
> // Redimensionner
> imagecopyresampled(
>     $image_destination, $image_source,
>     0, 0, 0, 0,
>     $nouvelle_largeur, $nouvelle_hauteur,
>     $largeur_source, $hauteur_source
> );
> 
> // Sauvegarder avec qualité 85
> imagejpeg($image_destination, $destination, 85);
> 
> // Libérer la mémoire
> imagedestroy($image_source);
> imagedestroy($image_destination);
> 
> echo "Image redimensionnée : $destination";
> ?>
> ```

> [!example] Exemple - Ajouter un watermark texte
> 
> ```php
> <?php
> $image = imagecreatefromjpeg('photo.jpg');
> 
> // Couleur du texte (blanc avec opacité)
> $blanc = imagecolorallocatealpha($image, 255, 255, 255, 50);
> 
> // Ajouter le texte
> $texte = "© MonSite.com";
> $font_size = 20;
> imagettftext($image, $font_size, 0, 10, 30, $blanc, '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', $texte);
> 
> // Sauvegarder
> imagejpeg($image, 'photo_watermark.jpg', 90);
> imagedestroy($image);
> ?>
> ```

> [!warning] Limitations de GD
> 
> - **Consommation mémoire** : les grandes images peuvent épuiser la mémoire PHP
> - **Formats limités** : support de base pour JPEG, PNG, GIF, WebP (selon la compilation)
> - Pour des besoins avancés, préférez **ImageMagick** (extension `imagick`)

> [!tip] Bonnes pratiques GD
> 
> - Augmentez `memory_limit` dans php.ini pour traiter de grandes images
> - Toujours appeler `imagedestroy()` pour libérer la mémoire
> - Utilisez `imagecopyresampled()` plutôt que `imagecopyresized()` pour une meilleure qualité
> - Définissez un niveau de qualité JPEG approprié (85-90 est un bon compromis)

---

### mbstring

L'extension **mbstring** (Multi-Byte String) permet de manipuler correctement les chaînes de caractères dans des encodages multi-octets comme UTF-8.

#### Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install php-mbstring

# Ou pour une version spécifique
sudo apt install php8.2-mbstring

# Redémarrer Apache
sudo systemctl restart apache2
```

#### Pourquoi mbstring est indispensable

Les fonctions PHP natives (`strlen()`, `substr()`, `strtoupper()`, etc.) ne fonctionnent correctement qu'avec des caractères ASCII (1 octet). Pour les caractères accentués, les emojis, le chinois, l'arabe, etc., ces fonctions donnent des résultats incorrects.

> [!example] Problème sans mbstring
> 
> ```php
> <?php
> $texte = "Hélène"; // Contient des caractères accentués
> 
> // INCORRECT : compte les octets, pas les caractères
> echo strlen($texte);        // Retourne 7 au lieu de 6
> echo substr($texte, 0, 3);  // Retourne "Hé" cassé
> 
> // CORRECT : avec mbstring
> echo mb_strlen($texte);           // Retourne 6
> echo mb_substr($texte, 0, 3);     // Retourne "Hél"
> echo mb_strtoupper($texte);       // Retourne "HÉLÈNE"
> ?>
> ```

#### Fonctions mbstring essentielles

|Fonction standard|Équivalent mbstring|Usage|
|---|---|---|
|`strlen()`|`mb_strlen()`|Longueur d'une chaîne|
|`substr()`|`mb_substr()`|Extraire une sous-chaîne|
|`strtoupper()`|`mb_strtoupper()`|Convertir en majuscules|
|`strtolower()`|`mb_strtolower()`|Convertir en minuscules|
|`strpos()`|`mb_strpos()`|Trouver la position d'une sous-chaîne|
|`str_split()`|`mb_str_split()`|Diviser en tableau de caractères|

> [!example] Utilisation pratique
> 
> ```php
> <?php
> $phrase = "Les élèves 🎓 apprennent le français";
> 
> // Compter les caractères (y compris emojis)
> echo mb_strlen($phrase);  // 36 caractères
> 
> // Extraire les 10 premiers caractères
> echo mb_substr($phrase, 0, 10);  // "Les élèves"
> 
> // Convertir en majuscules
> echo mb_strtoupper($phrase);  // "LES ÉLÈVES 🎓 APPRENNENT LE FRANÇAIS"
> 
> // Trouver la position d'un mot
> echo mb_strpos($phrase, "français");  // 30
> 
> // Vérifier l'encodage
> echo mb_detect_encoding($phrase);  // UTF-8
> ?>
> ```

> [!tip] Configuration globale Vous pouvez définir l'encodage par défaut dans `php.ini` :
> 
> ```ini
> mbstring.internal_encoding = UTF-8
> mbstring.http_output = UTF-8
> mbstring.encoding_translation = On
> ```

> [!warning] Pièges courants
> 
> - **Oublier mb_** : utiliser `strlen()` au lieu de `mb_strlen()` est l'erreur la plus fréquente
> - **Encodage incohérent** : assurez-vous que vos fichiers PHP, votre base de données et vos headers HTTP sont tous en UTF-8
> - **Performances** : les fonctions mbstring sont légèrement plus lentes, mais le surcoût est négligeable pour la plupart des applications

---

## 📦 Installation d'extensions supplémentaires

### Méthode 1 : Via le gestionnaire de paquets (recommandé)

C'est la méthode la plus simple et la plus sûre pour installer des extensions PHP.

```bash
# Rechercher les extensions disponibles
apt-cache search php8.2-

# Installer une ou plusieurs extensions
sudo apt install php8.2-xml php8.2-zip php8.2-intl

# Redémarrer Apache pour charger les nouvelles extensions
sudo systemctl restart apache2
```

#### Extensions couramment utilisées

|Extension|Package|Usage|
|---|---|---|
|**xml**|`php-xml`|Parsing et manipulation XML|
|**zip**|`php-zip`|Création et extraction d'archives ZIP|
|**intl**|`php-intl`|Internationalisation (dates, devises, tri multilingue)|
|**bcmath**|`php-bcmath`|Calculs mathématiques de précision arbitraire|
|**gmp**|`php-gmp`|Arithmétique multi-précision|
|**soap**|`php-soap`|Services web SOAP|
|**ldap**|`php-ldap`|Intégration avec Active Directory/LDAP|
|**redis**|`php-redis`|Client pour le système de cache Redis|
|**memcached**|`php-memcached`|Client pour Memcached|
|**imagick**|`php-imagick`|Manipulation d'images avancée (alternative à GD)|

> [!example] Installation d'extensions pour un projet Laravel/Symfony
> 
> ```bash
> # Extensions recommandées pour les frameworks modernes
> sudo apt install \
>   php8.2-cli \
>   php8.2-common \
>   php8.2-mysql \
>   php8.2-zip \
>   php8.2-gd \
>   php8.2-mbstring \
>   php8.2-curl \
>   php8.2-xml \
>   php8.2-bcmath \
>   php8.2-intl
> 
> sudo systemctl restart apache2
> ```

---

### Méthode 2 : Via PECL (extensions non disponibles dans les dépôts)

**PECL** (PHP Extension Community Library) est le dépôt officiel d'extensions PHP maintenues par la communauté.

#### Installation de PECL

```bash
# Installer PECL et les outils de développement nécessaires
sudo apt update
sudo apt install php-pear php8.2-dev build-essential

# Vérifier l'installation
pecl version
```

#### Installer une extension via PECL

```bash
# Exemple : installer l'extension MongoDB
sudo pecl install mongodb

# Activer l'extension en créant un fichier de configuration
echo "extension=mongodb.so" | sudo tee /etc/php/8.2/mods-available/mongodb.ini

# Activer pour Apache et CLI
sudo phpenmod mongodb

# Redémarrer Apache
sudo systemctl restart apache2
```

> [!example] Extensions populaires via PECL
> 
> ```bash
> # Extension MongoDB
> sudo pecl install mongodb
> 
> # Extension Redis (alternative au package)
> sudo pecl install redis
> 
> # Extension Xdebug (débogueur PHP)
> sudo pecl install xdebug
> 
> # Extension APCu (cache opcode)
> sudo pecl install apcu
> ```

> [!warning] Précautions avec PECL
> 
> - Les extensions PECL nécessitent une recompilation à chaque mise à jour PHP
> - Préférez les packages système (`apt`) quand ils existent
> - Vérifiez la compatibilité avec votre version de PHP
> - Les extensions PECL peuvent avoir des dépendances système supplémentaires

---

### Méthode 3 : Compilation manuelle (avancé)

Pour des cas très spécifiques, vous pouvez compiler une extension depuis les sources.

```bash
# Télécharger les sources de l'extension
wget https://pecl.php.net/get/nom_extension-version.tgz
tar -xzf nom_extension-version.tgz
cd nom_extension-version

# Compiler et installer
phpize
./configure
make
sudo make install

# Activer l'extension
echo "extension=nom_extension.so" | sudo tee /etc/php/8.2/mods-available/nom_extension.ini
sudo phpenmod nom_extension
sudo systemctl restart apache2
```

> [!warning] Compilation manuelle Cette méthode est **déconseillée** sauf si vous savez exactement ce que vous faites. Elle complique les mises à jour et la maintenance du serveur.

---

## 🔍 Vérification des extensions installées

### Méthode 1 : Via phpinfo()

```php
<?php
// Créer un fichier info.php dans /var/www/html/
phpinfo();
?>
```

Accédez ensuite à `http://votre-serveur/info.php` dans votre navigateur. Vous verrez toutes les informations sur PHP, y compris les extensions chargées.

> [!warning] Sécurité **Supprimez immédiatement le fichier info.php après utilisation** ! Il expose des informations sensibles sur votre configuration serveur.

---

### Méthode 2 : En ligne de commande

```bash
# Lister toutes les extensions chargées
php -m

# Vérifier si une extension spécifique est installée
php -m | grep mysqli
php -m | grep curl

# Voir la configuration complète
php -i

# Voir uniquement les extensions Zend
php -m | grep -A 100 "Zend Modules"
```

> [!example] Sortie typique de `php -m`
> 
> ```
> [PHP Modules]
> calendar
> Core
> ctype
> curl
> date
> dom
> exif
> fileinfo
> filter
> ftp
> gd
> gettext
> hash
> iconv
> json
> libxml
> mbstring
> mysqli
> mysqlnd
> openssl
> pcre
> PDO
> pdo_mysql
> Phar
> ...
> ```

---

### Méthode 3 : Vérifier dans un script PHP

```php
<?php
// Vérifier si une extension est chargée
if (extension_loaded('mysqli')) {
    echo "Extension mysqli : ✅ Installée\n";
} else {
    echo "Extension mysqli : ❌ Non installée\n";
}

// Vérifier plusieurs extensions
$extensions = ['curl', 'gd', 'mbstring', 'pdo_mysql'];
foreach ($extensions as $ext) {
    $status = extension_loaded($ext) ? '✅' : '❌';
    echo "$status $ext\n";
}

// Lister toutes les extensions chargées
print_r(get_loaded_extensions());
?>
```

---

### Méthode 4 : Vérifier les fichiers de configuration

```bash
# Voir les extensions activées pour Apache
ls /etc/php/8.2/apache2/conf.d/

# Voir les extensions disponibles
ls /etc/php/8.2/mods-available/

# Voir quelle configuration charge quelles extensions
php --ini
```

> [!tip] Activer/Désactiver des extensions
> 
> ```bash
> # Activer une extension
> sudo phpenmod nom_extension
> 
> # Désactiver une extension
> sudo phpdismod nom_extension
> 
> # Redémarrer Apache après modification
> sudo systemctl restart apache2
> ```

---

## 🎯 Récapitulatif

> [!info] Points clés à retenir
> 
> **Extensions pour bases de données** :
> 
> - `mysqli` : interface MySQL/MariaDB (procédurale ou OOP)
> - `pdo_mysql` : interface unifiée et portable (recommandé)
> 
> **Extensions web** :
> 
> - `curl` : requêtes HTTP/HTTPS, consommation d'APIs
> - `gd` : manipulation d'images (redimensionnement, watermarks)
> - `mbstring` : gestion correcte des caractères UTF-8
> 
> **Installation** :
> 
> - Privilégiez `apt install php-extension` (plus simple et maintenu)
> - Utilisez PECL uniquement pour les extensions non disponibles
> - Toujours redémarrer Apache après installation : `sudo systemctl restart apache2`
> 
> **Vérification** :
> 
> - `php -m` : lister les extensions en CLI
> - `phpinfo()` : voir toutes les infos (à supprimer après usage !)
> - `extension_loaded()` : tester programmatiquement

> [!tip] Checklist pour un nouveau serveur LAMP
> 
> ```bash
> # Extensions minimales recommandées
> sudo apt install \
>   php-mysql \
>   php-curl \
>   php-gd \
>   php-mbstring \
>   php-xml \
>   php-zip
> 
> sudo systemctl restart apache2
> php -m | grep -E "(curl|gd|mbstring|mysqli|pdo_mysql)"
> ```

---

**✅ Vous maîtrisez maintenant les extensions PHP essentielles pour un serveur LAMP fonctionnel !**