

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

## 🎯 Introduction à LAMP

**LAMP** est un acronyme désignant une stack technologique open-source très populaire pour le développement web. Elle tire son nom des initiales de ses quatre composants principaux :

- **L** : Linux (système d'exploitation)
- **A** : Apache (serveur web)
- **M** : MySQL/MariaDB (système de gestion de base de données)
- **P** : PHP (langage de programmation côté serveur)

> [!info] Pourquoi LAMP ? LAMP est devenu un standard de l'industrie pour plusieurs raisons :
> 
> - **Gratuité** : Tous les composants sont open-source
> - **Stabilité** : Technologies éprouvées depuis plus de 20 ans
> - **Communauté** : Large base d'utilisateurs et documentation abondante
> - **Flexibilité** : Peut être adapté à divers types de projets web

### Variantes de LAMP

Bien que classique, LAMP a donné naissance à plusieurs variantes :

|Acronyme|Différence|Usage|
|---|---|---|
|**WAMP**|Windows au lieu de Linux|Développement sous Windows|
|**MAMP**|macOS au lieu de Linux|Développement sous macOS|
|**LEMP**|Nginx au lieu d'Apache|Performance accrue pour sites à fort trafic|
|**LAMP** (moderne)|PostgreSQL au lieu de MySQL|Applications nécessitant des fonctionnalités SQL avancées|

> [!tip] Astuce Le principe reste le même : un système d'exploitation, un serveur web, une base de données et un langage de script. La logique d'architecture s'applique à toutes ces variantes.

---

## 🏗️ Architecture et interactions

### Rôle de chaque composant

Chaque composant de la stack LAMP joue un rôle spécifique et essentiel dans le traitement des requêtes web.

#### 🐧 Linux - Le système d'exploitation

**Rôle** : Fournir l'environnement d'exécution pour tous les autres composants.

Linux est la fondation sur laquelle repose toute la stack. Il gère :

- Les ressources système (CPU, mémoire, disque)
- Les permissions et la sécurité
- Les processus et services
- Le réseau et les communications

> [!info] Pourquoi Linux ?
> 
> - **Stabilité** : Peut fonctionner des mois sans redémarrage
> - **Sécurité** : Modèle de permissions robuste
> - **Performance** : Optimisé pour les serveurs
> - **Coût** : Pas de licence à payer

**Distributions populaires pour LAMP** :

- Ubuntu Server (recommandé pour débutants)
- Debian (très stable)
- CentOS/Rocky Linux (orienté entreprise)
- Red Hat Enterprise Linux (support commercial)

#### 🌐 Apache - Le serveur web

**Rôle** : Recevoir les requêtes HTTP des clients et renvoyer les réponses appropriées.

Apache HTTP Server est le point d'entrée de toute communication web. Il :

- Écoute sur les ports 80 (HTTP) et 443 (HTTPS)
- Analyse les requêtes HTTP entrantes
- Gère les fichiers statiques (HTML, CSS, JS, images)
- Transmet les requêtes dynamiques à PHP
- Retourne les réponses au client

> [!example] Exemple concret Quand vous tapez `www.monsite.com/index.php` dans votre navigateur :
> 
> 1. La requête arrive sur le port 80 du serveur
> 2. Apache reçoit la requête
> 3. Apache identifie qu'il s'agit d'un fichier `.php`
> 4. Il transmet le fichier à PHP pour traitement

**Fonctionnalités clés d'Apache** :

- **Virtual Hosts** : Héberger plusieurs sites sur un même serveur
- **Modules** : Étendre les fonctionnalités (SSL, réécriture d'URL, authentification)
- **.htaccess** : Configuration au niveau du répertoire
- **Logs** : Traçabilité des accès et erreurs

#### 🐬 MySQL/MariaDB - Le système de gestion de base de données

**Rôle** : Stocker, organiser et gérer les données persistantes de l'application.

MySQL (ou sa variante MariaDB) est responsable de :

- Stocker les données structurées (utilisateurs, articles, produits, etc.)
- Exécuter des requêtes SQL pour lire/écrire des données
- Garantir l'intégrité et la cohérence des données
- Gérer les accès concurrents

> [!info] MySQL vs MariaDB MariaDB est un fork de MySQL créé par les développeurs originaux de MySQL. Elle offre :
> 
> - Meilleure compatibilité avec les standards SQL
> - Plus de moteurs de stockage
> - Performances légèrement améliorées
> - 100% compatible avec MySQL dans la plupart des cas

**Types de données stockées** :

- Comptes utilisateurs et authentification
- Contenu dynamique (articles de blog, produits e-commerce)
- Configurations et paramètres
- Logs et statistiques
- Relations entre entités

#### 🐘 PHP - Le langage de programmation

**Rôle** : Générer dynamiquement le contenu HTML en fonction de la logique métier et des données.

PHP est le cerveau de l'application. Il :

- Interprète le code PHP des fichiers `.php`
- Exécute la logique métier (calculs, validations, traitements)
- Se connecte à MySQL pour récupérer/modifier des données
- Génère le HTML final à renvoyer au client
- Gère les sessions utilisateur

> [!example] Exemple de traitement PHP
> 
> ```php
> <?php
> // Connexion à la base de données
> $conn = new mysqli("localhost", "user", "password", "database");
> 
> // Récupération des articles
> $result = $conn->query("SELECT * FROM articles ORDER BY date DESC LIMIT 10");
> 
> // Génération du HTML
> while($row = $result->fetch_assoc()) {
>     echo "<article>";
>     echo "<h2>" . htmlspecialchars($row['titre']) . "</h2>";
>     echo "<p>" . htmlspecialchars($row['contenu']) . "</p>";
>     echo "</article>";
> }
> ?>
> ```

**Capacités de PHP** :

- Manipulation de chaînes et tableaux
- Traitement de formulaires
- Gestion de fichiers (upload, lecture, écriture)
- Envoi d'emails
- Génération de PDF, images
- API REST et services web

---

### Flux de traitement d'une requête HTTP

Comprendre le cheminement d'une requête HTTP à travers la stack LAMP est essentiel pour déboguer et optimiser les applications.

#### 📋 Étapes détaillées du traitement

##### 1️⃣ **Le client émet une requête HTTP**

Un utilisateur saisit une URL ou clique sur un lien dans son navigateur.

```
GET /profil.php?id=42 HTTP/1.1
Host: www.monsite.com
User-Agent: Mozilla/5.0
Accept: text/html
Cookie: session_id=abc123xyz
```

> [!info] Composants de la requête
> 
> - **Méthode** : GET, POST, PUT, DELETE, etc.
> - **URL** : Le chemin de la ressource demandée
> - **En-têtes** : Métadonnées (cookies, langue, type de contenu)
> - **Corps** : Données (pour POST/PUT)

##### 2️⃣ **Linux reçoit la requête réseau**

Le système d'exploitation Linux :

- Reçoit les paquets TCP/IP sur l'interface réseau
- Vérifie les règles firewall (iptables/firewalld)
- Route les paquets vers le processus Apache écoutant sur le port 80/443

```bash
# Linux gère le routage réseau
netstat -tulpn | grep :80
# tcp   0   0.0.0.0:80   0.0.0.0:*   LISTEN   1234/apache2
```

##### 3️⃣ **Apache traite la requête**

Apache analyse la requête et détermine l'action à entreprendre :

**a) Identification du Virtual Host**

Apache vérifie quel site correspond au nom de domaine demandé.

```apache
# Configuration Apache
<VirtualHost *:80>
    ServerName www.monsite.com
    DocumentRoot /var/www/monsite
    
    <Directory /var/www/monsite>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

**b) Vérification du fichier demandé**

Apache localise le fichier dans le système de fichiers :

- `/var/www/monsite/profil.php` existe-t-il ?
- Les permissions sont-elles correctes ?
- Y a-t-il des règles `.htaccess` à appliquer ?

**c) Détermination du type de fichier**

```apache
# Si fichier statique (.html, .css, .jpg) → Apache le renvoie directement
# Si fichier dynamique (.php) → Apache passe la main à PHP
```

> [!warning] Attention aux permissions Les fichiers doivent être lisibles par l'utilisateur Apache (généralement `www-data` ou `apache`).
> 
> ```bash
> # Vérifier les permissions
> ls -la /var/www/monsite/profil.php
> # -rw-r--r-- 1 www-data www-data 2048 Dec 15 10:30 profil.php
> ```

##### 4️⃣ **PHP exécute le script**

Apache transmet le fichier PHP à l'interpréteur PHP (via mod_php ou PHP-FPM).

**Étapes d'exécution PHP** :

**a) Parsing et compilation**

```php
<?php
// PHP analyse le code et le compile en opcodes
// (instructions machine compréhensibles)
```

**b) Exécution du code**

```php
<?php
// Récupération des paramètres GET
$user_id = $_GET['id'] ?? 0;

// Validation des données
if (!is_numeric($user_id)) {
    die("ID invalide");
}

// Connexion à MySQL (étape suivante)
```

##### 5️⃣ **PHP interroge MySQL**

PHP établit une connexion avec le serveur MySQL et exécute des requêtes.

```php
<?php
// Connexion à la base de données
$conn = new mysqli("localhost", "web_user", "password", "monsite_db");

if ($conn->connect_error) {
    die("Connexion échouée: " . $conn->connect_error);
}

// Préparation de la requête (protection contre SQL injection)
$stmt = $conn->prepare("SELECT nom, email, bio FROM users WHERE id = ?");
$stmt->bind_param("i", $user_id);

// Exécution
$stmt->execute();
$result = $stmt->get_result();

// Récupération des données
if ($row = $result->fetch_assoc()) {
    $nom = $row['nom'];
    $email = $row['email'];
    $bio = $row['bio'];
} else {
    die("Utilisateur non trouvé");
}

$stmt->close();
$conn->close();
?>
```

> [!tip] Performance MySQL
> 
> - Utilisez des index sur les colonnes fréquemment recherchées
> - Limitez le nombre de requêtes (évitez les boucles)
> - Utilisez des requêtes préparées pour la sécurité et la performance

##### 6️⃣ **MySQL retourne les données**

Le serveur MySQL :

- Parse la requête SQL
- Vérifie les permissions de l'utilisateur
- Exécute la requête (utilise les index si disponibles)
- Retourne un jeu de résultats à PHP

```
Résultat MySQL → PHP :
{
    "nom": "Jean Dupont",
    "email": "jean@example.com",
    "bio": "Développeur web passionné"
}
```

##### 7️⃣ **PHP génère le HTML**

PHP construit la page HTML finale avec les données récupérées.

```php
<?php
// Génération du HTML
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Profil de <?= htmlspecialchars($nom) ?></title>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
    <div class="profil">
        <h1><?= htmlspecialchars($nom) ?></h1>
        <p class="email"><?= htmlspecialchars($email) ?></p>
        <div class="bio">
            <?= nl2br(htmlspecialchars($bio)) ?>
        </div>
    </div>
</body>
</html>
```

> [!warning] Sécurité XSS Toujours utiliser `htmlspecialchars()` pour afficher des données utilisateur afin de prévenir les attaques XSS (Cross-Site Scripting).

##### 8️⃣ **PHP renvoie le résultat à Apache**

PHP termine l'exécution et retourne le HTML généré à Apache.

```
PHP → Apache :
- Code de statut HTTP : 200 OK
- En-têtes : Content-Type: text/html; charset=UTF-8
- Corps : Le HTML généré (environ 2 Ko dans cet exemple)
```

##### 9️⃣ **Apache transmet la réponse au client**

Apache construit la réponse HTTP complète et l'envoie au navigateur.

```
HTTP/1.1 200 OK
Date: Sun, 21 Dec 2025 14:30:00 GMT
Server: Apache/2.4.41
Content-Type: text/html; charset=UTF-8
Content-Length: 2048
Set-Cookie: session_id=abc123xyz; Path=/; HttpOnly

<!DOCTYPE html>
<html lang="fr">
...
</html>
```

##### 🔟 **Le navigateur affiche la page**

Le navigateur :

- Reçoit la réponse HTTP
- Parse le HTML
- Télécharge les ressources additionnelles (CSS, JS, images)
- Rend la page à l'écran

> [!info] Ressources additionnelles Le navigateur fera des requêtes séparées pour chaque ressource :
> 
> - `GET /css/style.css` → Apache renvoie directement (fichier statique)
> - `GET /images/avatar.jpg` → Apache renvoie directement
> - `GET /js/script.js` → Apache renvoie directement

#### ⏱️ Temps de traitement typique

|Étape|Temps moyen|Optimisations possibles|
|---|---|---|
|Réseau client → serveur|20-100 ms|CDN, serveur géographiquement proche|
|Apache parsing|1-5 ms|Optimisation de la configuration|
|PHP exécution|50-200 ms|Opcache, code optimisé|
|MySQL requête|10-100 ms|Index, requêtes optimisées|
|Génération HTML|10-50 ms|Templates mis en cache|
|Réseau serveur → client|20-100 ms|Compression GZIP|
|**TOTAL**|**111-555 ms**|Caching, optimisations diverses|

> [!tip] Optimisation
> 
> - Activez le cache PHP (Opcache)
> - Utilisez un cache applicatif (Redis, Memcached)
> - Optimisez les requêtes SQL et ajoutez des index
> - Compressez les ressources (GZIP)
> - Utilisez un CDN pour les ressources statiques

---

### Schéma d'architecture

#### 🎨 Vue d'ensemble de la stack LAMP

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT (Navigateur)                   │
│                    https://www.monsite.com                   │
└────────────────────────────┬────────────────────────────────┘
                             │
                             │ Requête HTTP
                             │ GET /profil.php?id=42
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                         INTERNET                             │
└────────────────────────────┬────────────────────────────────┘
                             │
                             │ Port 80/443
                             ▼
╔═════════════════════════════════════════════════════════════╗
║                    SERVEUR LINUX                             ║
║                                                              ║
║  ┌────────────────────────────────────────────────────┐    ║
║  │              APACHE HTTP SERVER                     │    ║
║  │                                                      │    ║
║  │  • Réception de la requête HTTP                     │    ║
║  │  • Analyse de l'URL et des en-têtes                 │    ║
║  │  • Gestion des Virtual Hosts                        │    ║
║  │  • Lecture du fichier .htaccess                     │    ║
║  │                                                      │    ║
║  │  ┌──────────────────────────────────────┐          │    ║
║  │  │   Fichier statique ?                 │          │    ║
║  │  │   (.html, .css, .jpg)                │          │    ║
║  │  └──────────┬───────────────────────────┘          │    ║
║  │             │                                        │    ║
║  │      OUI ───┴──► Renvoi direct                      │    ║
║  │             │                                        │    ║
║  │      NON    │                                        │    ║
║  │             ▼                                        │    ║
║  │  ┌──────────────────────────────────────┐          │    ║
║  │  │   Fichier PHP ?                      │          │    ║
║  │  │   (.php)                             │          │    ║
║  │  └──────────┬───────────────────────────┘          │    ║
║  └─────────────┼──────────────────────────────────────┘    ║
║                │                                             ║
║                │ Transmission via mod_php ou PHP-FPM        ║
║                ▼                                             ║
║  ┌──────────────────────────────────────────────────────┐  ║
║  │              INTERPRÉTEUR PHP                         │  ║
║  │                                                        │  ║
║  │  • Parsing du code PHP                                │  ║
║  │  • Compilation en opcodes                             │  ║
║  │  • Exécution de la logique métier                     │  ║
║  │  • Gestion des sessions                               │  ║
║  │                                                        │  ║
║  │  Besoin de données ? ────┐                            │  ║
║  │                           │                            │  ║
║  │                           ▼                            │  ║
║  │  ┌────────────────────────────────────┐               │  ║
║  │  │  Connexion MySQL                   │               │  ║
║  │  │  $conn = new mysqli(...)           │               │  ║
║  │  └────────────┬───────────────────────┘               │  ║
║  └───────────────┼────────────────────────────────────────┘  ║
║                  │                                            ║
║                  │ Requête SQL via socket                     ║
║                  │ SELECT * FROM users WHERE id=42            ║
║                  ▼                                            ║
║  ┌──────────────────────────────────────────────────────┐   ║
║  │           SERVEUR MySQL/MariaDB                       │   ║
║  │                                                        │   ║
║  │  • Authentification de l'utilisateur                  │   ║
║  │  • Parsing de la requête SQL                          │   ║
║  │  • Vérification des permissions                       │   ║
║  │  • Exécution sur les tables                           │   ║
║  │  • Utilisation des index                              │   ║
║  │                                                        │   ║
║  │  ┌──────────────────────────────────┐                │   ║
║  │  │   BASE DE DONNÉES : monsite_db   │                │   ║
║  │  │                                   │                │   ║
║  │  │   ┌─────────────────────────┐    │                │   ║
║  │  │   │  Table: users           │    │                │   ║
║  │  │   │  ├─ id (PK)             │    │                │   ║
║  │  │   │  ├─ nom                 │    │                │   ║
║  │  │   │  ├─ email               │    │                │   ║
║  │  │   │  └─ bio                 │    │                │   ║
║  │  │   └─────────────────────────┘    │                │   ║
║  │  └──────────────────────────────────┘                │   ║
║  │                                                        │   ║
║  │  Résultat : { nom, email, bio }                       │   ║
║  └───────────────────────┬────────────────────────────────┘  ║
║                          │                                    ║
║                          │ Données renvoyées                  ║
║                          ▼                                    ║
║  ┌──────────────────────────────────────────────────────┐   ║
║  │              INTERPRÉTEUR PHP                         │   ║
║  │                                                        │   ║
║  │  • Réception des données MySQL                        │   ║
║  │  • Traitement et validation                           │   ║
║  │  • Génération du HTML final                           │   ║
║  │  • htmlspecialchars() pour la sécurité                │   ║
║  │                                                        │   ║
║  │  HTML généré ────────────────┐                        │   ║
║  └──────────────────────────────┼────────────────────────┘   ║
║                                 │                             ║
║                                 │                             ║
║                                 ▼                             ║
║  ┌──────────────────────────────────────────────────────┐   ║
║  │              APACHE HTTP SERVER                       │   ║
║  │                                                        │   ║
║  │  • Construction de la réponse HTTP                    │   ║
║  │  • Ajout des en-têtes (Content-Type, etc.)           │   ║
║  │  • Compression GZIP (si activée)                      │   ║
║  │  • Logs d'accès                                       │   ║
║  └──────────────────────────┬─────────────────────────────┘  ║
╚════════════════════════════┼══════════════════════════════════╝
                             │
                             │ Réponse HTTP 200 OK
                             │ + HTML complet
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT (Navigateur)                   │
│                                                              │
│  • Réception du HTML                                        │
│  • Parsing et rendu                                         │
│  • Requêtes additionnelles pour CSS/JS/images              │
│  • Affichage de la page                                     │
└─────────────────────────────────────────────────────────────┘
```

#### 🔄 Communication entre les composants

```
APACHE  ←──────────────────────→  PHP
        mod_php (module intégré)
        ou
        FastCGI / PHP-FPM (processus séparé)


PHP     ←──────────────────────→  MySQL
        Connexion TCP socket
        (généralement localhost:3306)
        via extensions :
        - mysqli
        - PDO
```

> [!info] Modes de communication Apache-PHP
> 
> **mod_php** :
> 
> - PHP intégré directement dans Apache
> - Plus simple à configurer
> - Consomme plus de mémoire
> - Un processus Apache = un interpréteur PHP
> 
> **PHP-FPM** :
> 
> - PHP dans des processus séparés
> - Meilleure gestion de la mémoire
> - Performance supérieure sous charge
> - Configuration plus complexe
> - Recommandé pour production

#### 📂 Organisation des fichiers typique

```
/var/www/monsite/              # Racine du site
│
├── index.php                   # Page d'accueil
├── profil.php                  # Page de profil
├── login.php                   # Authentification
│
├── css/                        # Fichiers CSS (statiques)
│   └── style.css
│
├── js/                         # JavaScript (statique)
│   └── script.js
│
├── images/                     # Images (statiques)
│   └── logo.png
│
├── includes/                   # Fichiers PHP inclus
│   ├── config.php             # Configuration DB
│   ├── functions.php          # Fonctions utilitaires
│   └── header.php             # En-tête commun
│
└── .htaccess                  # Configuration Apache

/etc/apache2/                  # Configuration Apache
│
├── apache2.conf               # Configuration principale
├── sites-available/
│   └── monsite.conf           # VirtualHost
└── sites-enabled/
    └── monsite.conf → ../sites-available/monsite.conf

/var/log/apache2/              # Logs Apache
│
├── access.log                 # Logs d'accès
└── error.log                  # Logs d'erreurs
```

---

## 🎯 Pièges courants et bonnes pratiques

### ⚠️ Pièges à éviter

> [!warning] Erreur n°1 : Ne pas protéger contre les injections SQL
> 
> ```php
> // ❌ MAUVAIS - Vulnérable aux injections SQL
> $id = $_GET['id'];
> $query = "SELECT * FROM users WHERE id = $id";
> 
> // ✅ BON - Requête préparée
> $stmt = $conn->prepare("SELECT * FROM users WHERE id = ?");
> $stmt->bind_param("i", $id);
> ```

> [!warning] Erreur n°2 : Oublier htmlspecialchars()
> 
> ```php
> // ❌ MAUVAIS - Vulnérable aux XSS
> echo "<h1>" . $username . "</h1>";
> 
> // ✅ BON - Protection XSS
> echo "<h1>" . htmlspecialchars($username, ENT_QUOTES, 'UTF-8') . "</h1>";
> ```

> [!warning] Erreur n°3 : Laisser les erreurs PHP visibles en production
> 
> ```php
> // ❌ MAUVAIS - Affiche les erreurs sensibles
> error_reporting(E_ALL);
> ini_set('display_errors', 1);
> 
> // ✅ BON - Logs les erreurs sans les afficher
> error_reporting(E_ALL);
> ini_set('display_errors', 0);
> ini_set('log_errors', 1);
> ini_set('error_log', '/var/log/php/errors.log');
> ```

> [!warning] Erreur n°4 : Ne pas fermer les connexions MySQL
> 
> ```php
> // ❌ MAUVAIS - Fuite de connexions
> $conn = new mysqli($host, $user, $pass, $db);
> // ... utilisation ...
> // Pas de fermeture
> 
> // ✅ BON - Fermeture explicite
> $conn = new mysqli($host, $user, $pass, $db);
> // ... utilisation ...
> $conn->close();
> ```

### ✅ Bonnes pratiques

> [!tip] Bonne pratique n°1 : Séparer la configuration
> 
> ```php
> // config.php - Hors du DocumentRoot si possible
> <?php
> define('DB_HOST', 'localhost');
> define('DB_USER', 'web_user');
> define('DB_PASS', 'mot_de_passe_fort');
> define('DB_NAME', 'monsite_db');
> 
> // Ne jamais commiter ce fichier dans Git
> // Ajouter config.php au .gitignore
> ```

> [!tip] Bonne pratique n°2 : Utiliser des en-têtes de sécurité
> 
> ```apache
> # .htaccess ou configuration Apache
> Header set X-Content-Type-Options "nosniff"
> Header set X-Frame-Options "SAMEORIGIN"
> Header set X-XSS-Protection "1; mode=block"
> Header set Referrer-Policy "strict-origin-when-cross-origin"
> ```

> [!tip] Bonne pratique n°3 : Activer Opcache
> 
> ```ini
> ; php.ini
> opcache.enable=1
> opcache.memory_consumption=128
> opcache.interned_strings_buffer=8
> opcache.max_accelerated_files=10000
> opcache.validate_timestamps=0  ; En production
> ```

> [!tip] Bonne pratique n°4 : Structurer les logs
> 
> ```bash
> # Structure de logs recommandée
> /var/log/
> ├── apache2/
> │   ├── access.log          # Accès HTTP
> │   └── error.log           # Erreurs Apache
> ├── mysql/
> │   ├── error.log           # Erreurs MySQL
> │   └── slow-query.log      # Requêtes lentes
> └── php/
>     ├── errors.log          # Erreurs PHP
>     └── application.log     # Logs applicatifs
> ```

> [!tip] Bonne pratique n°5 : Implémenter le principe de moindre privilège
> 
> ```sql
> -- Créer un utilisateur MySQL avec droits limités
> CREATE USER 'web_user'@'localhost' IDENTIFIED BY 'mot_de_passe_fort';
> 
> -- Donner uniquement les permissions nécessaires
> GRANT SELECT, INSERT, UPDATE, DELETE ON monsite_db.* TO 'web_user'@'localhost';
> 
> -- Ne JAMAIS utiliser root pour les connexions web
> FLUSH PRIVILEGES;
> ```

> [!tip] Bonne pratique n°6 : Optimiser les performances
> 
> ```apache
> # Activer la compression GZIP
> <IfModule mod_deflate.c>
>     AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript
> </IfModule>
> 
> # Activer le cache navigateur
> <IfModule mod_expires.c>
>     ExpiresActive On
>     ExpiresByType image/jpg "access plus 1 year"
>     ExpiresByType image/jpeg "access plus 1 year"
>     ExpiresByType image/png "access plus 1 year"
>     ExpiresByType text/css "access plus 1 month"
>     ExpiresByType application/javascript "access plus 1 month"
> </IfModule>
> ```

---

## 💡 Astuces avancées

### 🚀 Astuce n°1 : Déboguer les problèmes de connexion

Quand une requête ne fonctionne pas, vérifiez dans l'ordre :

```bash
# 1. Apache est-il démarré ?
sudo systemctl status apache2
# ou
sudo service apache2 status

# 2. Apache écoute-t-il sur le bon port ?
sudo netstat -tulpn | grep :80

# 3. Les logs Apache montrent-ils des erreurs ?
sudo tail -f /var/log/apache2/error.log

# 4. PHP fonctionne-t-il ?
php -v
php -m  # Liste des modules

# 5. MySQL est-il accessible ?
mysql -u web_user -p -h localhost monsite_db

# 6. Les permissions sont-elles correctes ?
ls -la /var/www/monsite/
# Les fichiers doivent appartenir à www-data:www-data
```

### 🔍 Astuce n°2 : Tracer une requête complète

Créez un fichier de test pour vérifier toute la chaîne :

```php
<?php
// test.php - Diagnostic complet LAMP
header('Content-Type: text/plain; charset=utf-8');

echo "=== TEST STACK LAMP ===\n\n";

// 1. Test PHP
echo "✓ PHP version : " . PHP_VERSION . "\n";
echo "✓ PHP SAPI : " . php_sapi_name() . "\n\n";

// 2. Test modules PHP
echo "Modules PHP chargés :\n";
$modules = ['mysqli', 'pdo_mysql', 'mbstring', 'json'];
foreach ($modules as $module) {
    echo ($extension_loaded($module) ? "✓" : "✗") . " $module\n";
}
echo "\n";

// 3. Test connexion MySQL
echo "Test connexion MySQL :\n";
$conn = @new mysqli('localhost', 'web_user', 'password', 'monsite_db');

if ($conn->connect_error) {
    echo "✗ Connexion échouée : " . $conn->connect_error . "\n";
} else {
    echo "✓ Connexion réussie\n";
    echo "✓ Serveur MySQL : " . $conn->server_info . "\n";
    
    // 4. Test requête simple
    $result = $conn->query("SELECT 1 + 1 AS resultat");
    if ($result) {
        $row = $result->fetch_assoc();
        echo "✓ Requête test : 1 + 1 = " . $row['resultat'] . "\n";
    }
    
    $conn->close();
}

echo "\n";

// 5. Test permissions fichiers
echo "Permissions fichiers :\n";
$file = __FILE__;
$perms = fileperms($file);
echo "✓ Ce fichier : " . substr(sprintf('%o', $perms), -4) . "\n";

echo "\n=== FIN DU TEST ===\n";
?>
```

### ⚡ Astuce n°3 : Surveiller les performances

```bash
# Surveiller les processus Apache
watch -n 1 'ps aux | grep apache2 | wc -l'

# Surveiller les connexions MySQL
watch -n 1 'mysql -u root -p -e "SHOW PROCESSLIST"'

# Surveiller l'utilisation mémoire
free -h

# Analyser les requêtes lentes MySQL
mysqldumpslow /var/log/mysql/slow-query.log | head -20
```

### 🎨 Astuce n°4 : Utiliser des templates pour séparer logique et présentation

```php
<?php
// profil.php - Contrôleur
require_once 'includes/config.php';

// Logique métier
$user_id = $_GET['id'] ?? 0;
$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

$stmt = $conn->prepare("SELECT nom, email, bio FROM users WHERE id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

$stmt->close();
$conn->close();

// Inclusion du template
require_once 'templates/profil_view.php';
?>
```

```php
<?php
// templates/profil_view.php - Vue
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Profil de <?= htmlspecialchars($user['nom']) ?></title>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
    <?php include 'templates/header.php'; ?>
    
    <main class="profil">
        <h1><?= htmlspecialchars($user['nom']) ?></h1>
        <p class="email"><?= htmlspecialchars($user['email']) ?></p>
        <div class="bio">
            <?= nl2br(htmlspecialchars($user['bio'])) ?>
        </div>
    </main>
    
    <?php include 'templates/footer.php'; ?>
</body>
</html>
```

### 🛡️ Astuce n°5 : Sécuriser l'accès aux fichiers sensibles

```apache
# .htaccess - Protéger les fichiers de configuration
<FilesMatch "^(config\.php|\.env|\.git)">
    Require all denied
</FilesMatch>

# Désactiver le listing de répertoires
Options -Indexes

# Protéger un répertoire par mot de passe
<Directory /var/www/monsite/admin>
    AuthType Basic
    AuthName "Zone d'administration"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Directory>
```

```bash
# Créer un fichier .htpasswd
sudo htpasswd -c /etc/apache2/.htpasswd admin_user
```

### 📊 Astuce n°6 : Monitoring en temps réel

Créez un script de monitoring simple :

```php
<?php
// status.php - Page de statut (à protéger!)
header('Content-Type: application/json');

$status = [
    'timestamp' => date('Y-m-d H:i:s'),
    'services' => []
];

// Check Apache
$status['services']['apache'] = [
    'status' => function_exists('apache_get_version') ? 'running' : 'unknown',
    'version' => function_exists('apache_get_version') ? apache_get_version() : 'N/A'
];

// Check PHP
$status['services']['php'] = [
    'status' => 'running',
    'version' => PHP_VERSION,
    'memory_usage' => memory_get_usage(true) . ' bytes',
    'memory_limit' => ini_get('memory_limit')
];

// Check MySQL
try {
    $conn = new mysqli('localhost', 'web_user', 'password', 'monsite_db');
    $status['services']['mysql'] = [
        'status' => 'running',
        'version' => $conn->server_info,
        'connections' => $conn->query("SHOW STATUS LIKE 'Threads_connected'")->fetch_row()[1]
    ];
    $conn->close();
} catch (Exception $e) {
    $status['services']['mysql'] = [
        'status' => 'error',
        'message' => $e->getMessage()
    ];
}

echo json_encode($status, JSON_PRETTY_PRINT);
?>
```

---

## 🔧 Tableau récapitulatif des interactions

|Composant|Rôle principal|Communique avec|Type de communication|Port par défaut|
|---|---|---|---|---|
|**Linux**|OS hôte, gestion des ressources|Tous les composants|-|-|
|**Apache**|Serveur web, réception/envoi HTTP|Client, PHP|HTTP, FastCGI/mod_php|80, 443|
|**PHP**|Traitement logique, génération HTML|Apache, MySQL|FastCGI, Socket TCP|-|
|**MySQL**|Stockage et gestion des données|PHP|Socket TCP|3306|
|**Client**|Navigateur web|Apache|HTTP/HTTPS|-|

---

## 🎓 Points clés à retenir

> [!info] Synthèse de l'architecture LAMP
> 
> 1. **Flux unidirectionnel** : Client → Apache → PHP → MySQL → PHP → Apache → Client
>     
> 2. **Séparation des responsabilités** :
>     
>     - Apache : communication HTTP
>     - PHP : logique applicative
>     - MySQL : persistance des données
> 3. **Points de performance critiques** :
>     
>     - Temps de réponse MySQL (index, optimisation)
>     - Temps d'exécution PHP (opcache, code optimisé)
>     - Latence réseau (compression, CDN)
> 4. **Sécurité multicouche** :
>     
>     - Firewall Linux (iptables)
>     - Configuration Apache (permissions, .htaccess)
>     - Validation PHP (injection, XSS)
>     - Permissions MySQL (utilisateurs limités)
> 5. **Scalabilité** :
>     
>     - Apache : augmenter les workers/threads
>     - PHP : PHP-FPM avec pool de processus
>     - MySQL : réplication master-slave, caching

---

## 📈 Évolution et alternatives

### Évolutions modernes de LAMP

|Composant|Alternatives modernes|Avantages|
|---|---|---|
|**Apache**|Nginx|Plus rapide pour contenu statique, moins de mémoire|
|**MySQL**|MariaDB, PostgreSQL|Plus de fonctionnalités, meilleures performances|
|**PHP**|Python (Django), Node.js|Asynchrone, temps réel|
|**Monolithe**|Microservices|Scalabilité, déploiement indépendant|

### Stack moderne typique

```
Client
  ↓
Nginx (reverse proxy)
  ↓
├─→ Node.js (API REST)
├─→ PHP-FPM (legacy)
└─→ Python (microservices)
  ↓
├─→ PostgreSQL (données relationnelles)
├─→ Redis (cache)
└─→ Elasticsearch (recherche)
```

> [!info] Pourquoi LAMP reste pertinent Malgré l'émergence de nouvelles technologies, LAMP reste une excellente stack pour :
> 
> - Projets de taille petite à moyenne
> - Prototypes et MVP rapides
> - Sites vitrines et blogs
> - Applications métier internes
> - Apprentissage des concepts web fondamentaux
> 
> La simplicité de LAMP et sa documentation abondante en font un choix solide pour débuter.

---

**🎯 Conclusion**

L'architecture LAMP est un système élégant où chaque composant joue un rôle précis. Comprendre le flux complet d'une requête HTTP - du client au serveur, en passant par Apache, PHP et MySQL - est essentiel pour développer, déboguer et optimiser efficacement des applications web.

La force de LAMP réside dans sa simplicité conceptuelle : chaque couche a une responsabilité claire, les interactions sont bien définies, et l'ensemble forme un écosystème cohérent et éprouvé depuis plus de deux décennies.