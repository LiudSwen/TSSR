

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

Le test de connexion PHP-MySQL est une étape cruciale pour vérifier que votre serveur LAMP fonctionne correctement. Il permet de s'assurer que PHP peut communiquer avec le serveur MySQL/MariaDB et que les identifiants de connexion sont corrects.

> [!info] Pourquoi tester la connexion ?
> - Valider la configuration du serveur LAMP
> - Vérifier les permissions et identifiants MySQL
> - Détecter les problèmes de connectivité avant le déploiement
> - Confirmer que les extensions PHP MySQL sont actives

---

## 📝 Script de test de connexion

Il existe trois méthodes principales pour se connecter à MySQL depuis PHP : MySQLi (procédurale), MySQLi (orientée objet) et PDO. Chacune a ses avantages.

### Méthode MySQLi (procédurale)

> [!example] Script de test MySQLi procédural

```php
<?php
// test_mysql.php

// Paramètres de connexion
$serveur = "localhost";
$utilisateur = "root";
$motdepasse = "votre_mot_de_passe";
$base = "test";

// Tentative de connexion
$connexion = mysqli_connect($serveur, $utilisateur, $motdepasse, $base);

// Vérification de la connexion
if (!$connexion) {
    die("❌ Échec de la connexion : " . mysqli_connect_error());
}

echo "✅ Connexion réussie à MySQL !<br>";
echo "📊 Version MySQL : " . mysqli_get_server_info($connexion) . "<br>";
echo "🔗 Host info : " . mysqli_get_host_info($connexion) . "<br>";

// Fermeture de la connexion
mysqli_close($connexion);
?>
```

**Caractéristiques :**
- Simple et directe
- Moins de code pour des opérations basiques
- Compatible avec les anciennes versions de PHP
- Limité à MySQL/MariaDB uniquement

### Méthode MySQLi (orientée objet)

> [!example] Script de test MySQLi OOP

```php
<?php
// test_mysql_oop.php

// Paramètres de connexion
$serveur = "localhost";
$utilisateur = "root";
$motdepasse = "votre_mot_de_passe";
$base = "test";

// Création de l'objet de connexion
$connexion = new mysqli($serveur, $utilisateur, $motdepasse, $base);

// Vérification de la connexion
if ($connexion->connect_error) {
    die("❌ Échec de la connexion : " . $connexion->connect_error);
}

echo "✅ Connexion réussie à MySQL !<br>";
echo "📊 Version MySQL : " . $connexion->server_info . "<br>";
echo "🔗 Host info : " . $connexion->host_info . "<br>";
echo "🌍 Charset : " . $connexion->character_set_name() . "<br>";

// Fermeture de la connexion
$connexion->close();
?>
```

**Avantages :**
- Syntaxe plus moderne et lisible
- Facilite la réutilisation du code
- Meilleure organisation pour les projets complexes

### Méthode PDO (recommandée)

> [!tip] PDO est la méthode recommandée
> PDO (PHP Data Objects) offre une abstraction de base de données, permettant de changer facilement de SGBD (MySQL, PostgreSQL, SQLite, etc.) sans réécrire le code.

> [!example] Script de test PDO

```php
<?php
// test_pdo.php

// Paramètres de connexion
$serveur = "localhost";
$base = "test";
$utilisateur = "root";
$motdepasse = "votre_mot_de_passe";
$charset = "utf8mb4";

// Construction du DSN (Data Source Name)
$dsn = "mysql:host=$serveur;dbname=$base;charset=$charset";

// Options de connexion PDO
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION, // Gestion des erreurs par exceptions
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,       // Retour en tableau associatif
    PDO::ATTR_EMULATE_PREPARES   => false,                  // Utilise les vraies requêtes préparées
];

try {
    // Tentative de connexion
    $pdo = new PDO($dsn, $utilisateur, $motdepasse, $options);
    
    echo "✅ Connexion PDO réussie !<br>";
    
    // Récupération de la version MySQL
    $version = $pdo->query('SELECT VERSION()')->fetchColumn();
    echo "📊 Version MySQL : " . $version . "<br>";
    
    // Test d'une requête simple
    $stmt = $pdo->query('SELECT DATABASE()');
    $dbname = $stmt->fetchColumn();
    echo "🗄️ Base de données active : " . $dbname . "<br>";
    
    // Informations sur la connexion
    echo "🌍 Charset : " . $pdo->query('SELECT @@character_set_client')->fetchColumn() . "<br>";
    
} catch (PDOException $e) {
    die("❌ Erreur de connexion PDO : " . $e->getMessage());
}

// PDO se ferme automatiquement, mais on peut forcer :
$pdo = null;
?>
```

**Avantages de PDO :**
- Portable entre différents SGBD
- Support natif des requêtes préparées
- Gestion des erreurs par exceptions
- Plus sécurisé par défaut

---

## ⚠️ Gestion des erreurs de connexion

### Types d'erreurs courantes

> [!warning] Erreurs fréquentes
> Il est essentiel de comprendre les différentes erreurs pour les résoudre rapidement.

| Code d'erreur | Signification | Solution |
|---------------|---------------|----------|
| 1045 | Access denied | Vérifier utilisateur/mot de passe |
| 2002 | Can't connect to server | MySQL n'est pas démarré |
| 1049 | Unknown database | La base de données n'existe pas |
| 2006 | Server has gone away | Timeout ou connexion perdue |
| 1044 | Access denied for user | Permissions insuffisantes |

> [!example] Script de diagnostic complet

```php
<?php
// diagnostic_mysql.php

$serveur = "localhost";
$utilisateur = "root";
$motdepasse = "votre_mot_de_passe";
$base = "test";

echo "<h2>🔍 Diagnostic de connexion MySQL</h2>";

// 1. Vérifier que l'extension est chargée
echo "<h3>📦 Extensions PHP</h3>";
if (extension_loaded('mysqli')) {
    echo "✅ Extension MySQLi : Chargée<br>";
} else {
    echo "❌ Extension MySQLi : NON chargée<br>";
}

if (extension_loaded('pdo_mysql')) {
    echo "✅ Extension PDO_MySQL : Chargée<br>";
} else {
    echo "❌ Extension PDO_MySQL : NON chargée<br>";
}

// 2. Test de connexion avec gestion détaillée des erreurs
echo "<h3>🔗 Test de connexion</h3>";
$connexion = @mysqli_connect($serveur, $utilisateur, $motdepasse, $base);

if (!$connexion) {
    $erreur_num = mysqli_connect_errno();
    $erreur_msg = mysqli_connect_error();
    
    echo "❌ Échec de connexion<br>";
    echo "Code d'erreur : $erreur_num<br>";
    echo "Message : $erreur_msg<br>";
    
    // Diagnostic selon l'erreur
    switch ($erreur_num) {
        case 1045:
            echo "<br>🔧 Solution : Vérifiez vos identifiants MySQL<br>";
            echo "Commande : mysql -u $utilisateur -p<br>";
            break;
        case 2002:
            echo "<br>🔧 Solution : Démarrez le service MySQL<br>";
            echo "Commande : sudo systemctl start mysql<br>";
            break;
        case 1049:
            echo "<br>🔧 Solution : Créez la base de données<br>";
            echo "Commande SQL : CREATE DATABASE $base;<br>";
            break;
        default:
            echo "<br>🔧 Consultez les logs MySQL pour plus de détails<br>";
    }
} else {
    echo "✅ Connexion réussie !<br>";
    
    // Informations détaillées
    echo "<h3>📊 Informations serveur</h3>";
    echo "Version MySQL : " . mysqli_get_server_info($connexion) . "<br>";
    echo "Host : " . mysqli_get_host_info($connexion) . "<br>";
    echo "Protocole : " . mysqli_get_proto_info($connexion) . "<br>";
    
    // Test des privilèges
    echo "<h3>🔐 Test des privilèges</h3>";
    $result = mysqli_query($connexion, "SHOW GRANTS FOR CURRENT_USER()");
    if ($result) {
        echo "✅ Privilèges de l'utilisateur :<br>";
        while ($row = mysqli_fetch_row($result)) {
            echo "- " . $row[0] . "<br>";
        }
    }
    
    mysqli_close($connexion);
}
?>
```

### Gestion avancée des erreurs

> [!example] Classe de connexion avec gestion d'erreurs

```php
<?php
// ConnexionDB.php

class ConnexionDB {
    private $pdo;
    private $config;
    
    public function __construct($config) {
        $this->config = $config;
    }
    
    /**
     * Établit la connexion avec retry automatique
     */
    public function connecter($tentatives = 3) {
        $dsn = sprintf(
            "mysql:host=%s;dbname=%s;charset=%s",
            $this->config['host'],
            $this->config['dbname'],
            $this->config['charset']
        );
        
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
            PDO::ATTR_PERSISTENT         => true, // Connexions persistantes
        ];
        
        $derniere_erreur = null;
        
        // Tentatives multiples de connexion
        for ($i = 0; $i < $tentatives; $i++) {
            try {
                $this->pdo = new PDO(
                    $dsn,
                    $this->config['user'],
                    $this->config['password'],
                    $options
                );
                
                // Connexion réussie
                $this->logInfo("Connexion établie avec succès");
                return true;
                
            } catch (PDOException $e) {
                $derniere_erreur = $e;
                $this->logErreur("Tentative " . ($i + 1) . " échouée : " . $e->getMessage());
                
                // Attendre avant de réessayer (sauf à la dernière tentative)
                if ($i < $tentatives - 1) {
                    sleep(2);
                }
            }
        }
        
        // Toutes les tentatives ont échoué
        $this->gererEchec($derniere_erreur);
        return false;
    }
    
    /**
     * Gère l'échec de connexion selon le type d'erreur
     */
    private function gererEchec(PDOException $e) {
        $code = $e->getCode();
        $message = $e->getMessage();
        
        if (strpos($message, '1045') !== false) {
            // Erreur d'authentification
            throw new Exception("Erreur d'authentification : Identifiants incorrects");
        } elseif (strpos($message, '2002') !== false) {
            // Serveur inaccessible
            throw new Exception("Serveur MySQL inaccessible. Vérifiez que le service est démarré.");
        } elseif (strpos($message, '1049') !== false) {
            // Base de données inexistante
            throw new Exception("La base de données '{$this->config['dbname']}' n'existe pas.");
        } else {
            // Erreur générique
            throw new Exception("Erreur de connexion : " . $message);
        }
    }
    
    /**
     * Test la connexion avec ping
     */
    public function testerConnexion() {
        try {
            if ($this->pdo === null) {
                return false;
            }
            
            // Ping MySQL
            $this->pdo->query('SELECT 1');
            return true;
            
        } catch (PDOException $e) {
            $this->logErreur("Connexion perdue : " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Récupère l'objet PDO
     */
    public function getPDO() {
        if (!$this->testerConnexion()) {
            $this->connecter();
        }
        return $this->pdo;
    }
    
    private function logErreur($message) {
        error_log("[ERREUR DB] " . date('Y-m-d H:i:s') . " - " . $message);
    }
    
    private function logInfo($message) {
        error_log("[INFO DB] " . date('Y-m-d H:i:s') . " - " . $message);
    }
}

// Utilisation
$config = [
    'host'     => 'localhost',
    'dbname'   => 'test',
    'user'     => 'root',
    'password' => 'votre_mot_de_passe',
    'charset'  => 'utf8mb4'
];

try {
    $db = new ConnexionDB($config);
    $db->connecter();
    
    $pdo = $db->getPDO();
    echo "✅ Connexion établie avec succès !";
    
} catch (Exception $e) {
    echo "❌ " . $e->getMessage();
}
?>
```

### Logging des erreurs

> [!tip] Importance du logging
> Ne jamais afficher les erreurs de connexion directement en production. Utilisez un système de logging.

> [!example] Configuration du logging

```php
<?php
// config_logging.php

// Configuration des erreurs PHP
ini_set('display_errors', 0);           // Ne pas afficher les erreurs
ini_set('log_errors', 1);               // Logger les erreurs
ini_set('error_log', '/var/log/php/errors.log'); // Fichier de log

/**
 * Fonction de logging personnalisée
 */
function loggerConnexion($niveau, $message, $contexte = []) {
    $log_file = '/var/log/lamp/db_connexion.log';
    
    $timestamp = date('Y-m-d H:i:s');
    $contexte_str = !empty($contexte) ? json_encode($contexte) : '';
    
    $ligne = sprintf(
        "[%s] [%s] %s %s\n",
        $timestamp,
        strtoupper($niveau),
        $message,
        $contexte_str
    );
    
    // Créer le répertoire si nécessaire
    $dir = dirname($log_file);
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
    
    file_put_contents($log_file, $ligne, FILE_APPEND);
}

/**
 * Test de connexion avec logging
 */
function testerConnexionAvecLog() {
    $config = [
        'host'     => 'localhost',
        'dbname'   => 'test',
        'user'     => 'root',
        'password' => 'votre_mot_de_passe'
    ];
    
    try {
        $dsn = "mysql:host={$config['host']};dbname={$config['dbname']}";
        $pdo = new PDO($dsn, $config['user'], $config['password'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
        ]);
        
        loggerConnexion('info', 'Connexion réussie', [
            'host' => $config['host'],
            'database' => $config['dbname']
        ]);
        
        return $pdo;
        
    } catch (PDOException $e) {
        loggerConnexion('error', 'Échec de connexion', [
            'code' => $e->getCode(),
            'message' => $e->getMessage(),
            'host' => $config['host']
        ]);
        
        // En production, ne jamais afficher l'erreur réelle
        die("Une erreur est survenue. Contactez l'administrateur.");
    }
}
?>
```

---

## 🔒 Bonnes pratiques de sécurité

> [!warning] Sécurité des identifiants
> Ne jamais hardcoder les identifiants dans le code !

### Utilisation d'un fichier de configuration

```php
<?php
// config.php (à placer HORS du document root)

return [
    'database' => [
        'host'     => getenv('DB_HOST') ?: 'localhost',
        'name'     => getenv('DB_NAME') ?: 'test',
        'user'     => getenv('DB_USER') ?: 'root',
        'password' => getenv('DB_PASSWORD') ?: '',
        'charset'  => 'utf8mb4',
        'options'  => [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]
    ]
];
?>
```

### Fichier .env pour les credentials

```bash
# .env (à ne JAMAIS versionner dans Git)
DB_HOST=localhost
DB_NAME=ma_base
DB_USER=mon_utilisateur
DB_PASSWORD=mon_mot_de_passe_securise
```

### Utilisation sécurisée

```php
<?php
// connexion_securisee.php

// Charger les variables d'environnement
if (file_exists(__DIR__ . '/.env')) {
    $lines = file(__DIR__ . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '#') === 0) continue;
        list($key, $value) = explode('=', $line, 2);
        putenv(trim($key) . '=' . trim($value));
    }
}

// Charger la configuration
$config = require __DIR__ . '/../config/config.php';

try {
    $dsn = sprintf(
        "mysql:host=%s;dbname=%s;charset=%s",
        $config['database']['host'],
        $config['database']['name'],
        $config['database']['charset']
    );
    
    $pdo = new PDO(
        $dsn,
        $config['database']['user'],
        $config['database']['password'],
        $config['database']['options']
    );
    
    echo "✅ Connexion sécurisée établie";
    
} catch (PDOException $e) {
    error_log("Erreur DB : " . $e->getMessage());
    die("Erreur de connexion à la base de données");
}
?>
```

---

## ⚡ Pièges courants

> [!warning] Erreurs fréquentes à éviter

### 1. Ne pas vérifier l'existence de la connexion

```php
// ❌ MAUVAIS
$result = mysqli_query($connexion, "SELECT * FROM users");
// Si $connexion est null, erreur fatale

// ✅ BON
if ($connexion && mysqli_ping($connexion)) {
    $result = mysqli_query($connexion, "SELECT * FROM users");
} else {
    die("Connexion invalide");
}
```

### 2. Afficher les erreurs en production

```php
// ❌ MAUVAIS (expose des infos sensibles)
die("Erreur : " . mysqli_connect_error());

// ✅ BON
error_log("Erreur DB : " . mysqli_connect_error());
die("Une erreur est survenue");
```

### 3. Oublier le charset

```php
// ❌ MAUVAIS (problèmes d'encodage)
$pdo = new PDO("mysql:host=localhost;dbname=test", $user, $pass);

// ✅ BON
$pdo = new PDO("mysql:host=localhost;dbname=test;charset=utf8mb4", $user, $pass);
```

### 4. Connexions non fermées

```php
// ❌ MAUVAIS (fuite de ressources)
function getUsers() {
    $pdo = new PDO(...);
    return $pdo->query("SELECT * FROM users")->fetchAll();
    // PDO reste ouvert
}

// ✅ BON
function getUsers() {
    $pdo = new PDO(...);
    $result = $pdo->query("SELECT * FROM users")->fetchAll();
    $pdo = null; // Fermeture explicite
    return $result;
}
```

### 5. Ne pas utiliser de timeout

```php
// ✅ BON : Définir un timeout de connexion
$options = [
    PDO::ATTR_TIMEOUT => 5, // 5 secondes max
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
];

$pdo = new PDO($dsn, $user, $pass, $options);
```

### 6. Tester uniquement une fois

> [!tip] Astuce
> Créez un script de monitoring qui teste régulièrement la connexion, surtout en production.

```php
<?php
// monitoring_db.php

function verifierConnexionDB() {
    $config = require __DIR__ . '/config.php';
    
    try {
        $start = microtime(true);
        
        $pdo = new PDO(
            "mysql:host={$config['host']};dbname={$config['dbname']}",
            $config['user'],
            $config['password'],
            [PDO::ATTR_TIMEOUT => 3]
        );
        
        $pdo->query('SELECT 1');
        $temps = round((microtime(true) - $start) * 1000, 2);
        
        return [
            'status' => 'OK',
            'temps_ms' => $temps,
            'timestamp' => date('Y-m-d H:i:s')
        ];
        
    } catch (Exception $e) {
        return [
            'status' => 'ERREUR',
            'message' => $e->getMessage(),
            'timestamp' => date('Y-m-d H:i:s')
        ];
    }
}

// Exécuter la vérification
$resultat = verifierConnexionDB();
echo json_encode($resultat, JSON_PRETTY_PRINT);
?>
```

---

> [!tip] Astuces finales
> - Testez toujours vos connexions dans différents environnements (dev, staging, prod)
> - Utilisez des utilisateurs MySQL différents selon les environnements
> - Limitez les privilèges de l'utilisateur MySQL au strict minimum
> - Activez les connexions SSL pour les bases de données distantes
> - Surveillez les performances de connexion avec un monitoring

> [!info] Commandes MySQL utiles pour le dépannage
> ```bash
> # Vérifier le statut de MySQL
> sudo systemctl status mysql
> 
> # Tester la connexion MySQL
> mysql -u root -p
> 
> # Voir les utilisateurs MySQL
> SELECT User, Host FROM mysql.user;
> 
> # Créer un utilisateur de test
> CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'password';
> GRANT ALL PRIVILEGES ON test.* TO 'testuser'@'localhost';
> FLUSH PRIVILEGES;
> ```