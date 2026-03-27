

📘 PARTIE 1 : Introduction et architecture LAMP Fichier Obsidian suggéré : `01-introduction-architecture-lamp.md`

**Sujets à couvrir :**

1. Présentation de la stack LAMP
    
    - Définition et composants
    - Cas d'usage et avantages
    - Alternatives (WAMP, MAMP, LEMP)
2. Architecture et interactions
    
    - Rôle de chaque composant
    - Flux de traitement d'une requête HTTP
    - Schéma d'architecture
3. Prérequis système
    
    - Distributions Linux recommandées
    - Ressources matérielles minimales
    - Configuration réseau de base

---

📘 PARTIE 2 : Installation et configuration de Linux Fichier Obsidian suggéré : `02-linux-preparation-systeme.md`

**Sujets à couvrir :**

1. Préparation du système
    
    - Mise à jour des paquets
    - Configuration du hostname
    - Gestion des utilisateurs et permissions
    - Configuration du pare-feu (firewalld/ufw)
2. Gestion des services système
    
    - Systemd : principes de base
    - Commandes systemctl essentielles
    - Activation au démarrage

---

📘 PARTIE 3 : Installation et configuration d'Apache Fichier Obsidian suggéré : `03-apache-serveur-web.md`

**Sujets à couvrir :**

1. Installation d'Apache
    
    - Installation via gestionnaire de paquets
    - Démarrage et vérification du service
    - Test de la page par défaut
2. Structure et fichiers de configuration
    
    - Arborescence Apache (/etc/apache2 ou /etc/httpd)
    - Fichier principal (apache2.conf / httpd.conf)
    - Fichiers de sites disponibles et activés
    - Répertoires conf.d et mods-available
3. Configuration de base
    
    - Directive ServerName
    - DocumentRoot
    - DirectoryIndex
    - Port d'écoute (Listen)
4. Virtual Hosts
    
    - Principe des hôtes virtuels
    - Virtual Host par nom
    - Virtual Host par IP
    - Configuration multi-sites
5. Permissions et sécurité de base
    
    - Directive Directory
    - Options (Indexes, FollowSymLinks)
    - AllowOverride
    - Require (Allow/Deny)
6. Modules Apache
    
    - Liste des modules courants
    - Activation/désactivation (a2enmod/a2dismod)
    - Module rewrite
    - Module ssl
7. Logs Apache
    
    - Access log et Error log
    - Formats de logs
    - Rotation des logs

---

📘 PARTIE 4 : Installation et configuration de MySQL/MariaDB Fichier Obsidian suggéré : `04-mysql-mariadb-sgbd.md`

**Sujets à couvrir :**

1. Installation de MariaDB/MySQL
    
    - Choix entre MySQL et MariaDB
    - Installation via gestionnaire de paquets
    - Démarrage du service
2. Sécurisation initiale
    
    - Script mysql_secure_installation
    - Définition du mot de passe root
    - Suppression des utilisateurs anonymes
    - Désactivation de l'accès root distant
3. Gestion des bases de données
    
    - Connexion au serveur (mysql -u -p)
    - Création de bases de données
    - Suppression de bases de données
    - Affichage des bases existantes
4. Gestion des utilisateurs et privilèges
    
    - Création d'utilisateurs
    - Attribution de privilèges (GRANT)
    - Retrait de privilèges (REVOKE)
    - Limitation par hôte (localhost, %)
    - Flush privileges
5. Configuration de base
    
    - Fichier my.cnf / my.ini
    - Port d'écoute
    - Bind-address (127.0.0.1 vs 0.0.0.0)
    - Character set et collation
6. Sauvegarde et restauration
    
    - mysqldump : export de bases
    - Importation via mysql
    - Automatisation des sauvegardes

---

📘 PARTIE 5 : Installation et configuration de PHP Fichier Obsidian suggéré : `05-php-langage-scripting.md`

**Sujets à couvrir :**

1. Installation de PHP
    
    - Installation de PHP et modules courants
    - Versions de PHP
    - Vérification de l'installation
2. Intégration PHP-Apache
    
    - Module mod_php (libapache2-mod-php)
    - Configuration du handler PHP
    - Test avec phpinfo()
3. Configuration PHP (php.ini)
    
    - Localisation du fichier php.ini
    - Directives importantes (memory_limit, upload_max_filesize, post_max_size)
    - display_errors et error_reporting
    - date.timezone
    - Redémarrage après modification
4. Extensions PHP courantes
    
    - Extensions pour MySQL/MariaDB (mysqli, pdo_mysql)
    - Extensions web (curl, gd, mbstring)
    - Installation d'extensions supplémentaires
5. Test de connexion PHP-MySQL
    
    - Script de test de connexion
    - Gestion des erreurs de connexion

---

📘 PARTIE 6 : Déploiement d'une application web Fichier Obsidian suggéré : `06-deploiement-application-web.md`

**Sujets à couvrir :**

1. Préparation du déploiement
    
    - Création d'un Virtual Host dédié
    - Création de la base de données et utilisateur
    - Permissions sur les répertoires web
2. Installation manuelle d'une application
    
    - Téléchargement des fichiers
    - Extraction et placement dans DocumentRoot
    - Configuration de l'application (fichier de config)
    - Finalisation de l'installation via navigateur
3. Problèmes courants et dépannage
    
    - Erreurs 403 Forbidden
    - Erreurs 500 Internal Server Error
    - Erreurs de connexion à la base de données
    - Consultation des logs Apache et PHP

---

📘 PARTIE 7 : Sécurisation de la stack LAMP Fichier Obsidian suggéré : `07-securisation-lamp.md`

**Sujets à couvrir :**

1. Sécurisation Apache
    
    - Masquage de la version (ServerTokens, ServerSignature)
    - Désactivation du listing de répertoires
    - Protection des fichiers sensibles (.htaccess, .git)
    - Limitation des méthodes HTTP
2. Sécurisation MySQL/MariaDB
    
    - Utilisateurs avec privilèges minimaux
    - Désactivation de l'accès root distant
    - Changement du port par défaut (optionnel)
3. Sécurisation PHP
    
    - Désactivation de fonctions dangereuses (disable_functions)
    - display_errors en production
    - open_basedir pour limiter l'accès fichiers
    - Mise à jour régulière de PHP
4. Mise en place de HTTPS avec SSL/TLS
    
    - Principe du chiffrement SSL/TLS
    - Certificats Let's Encrypt
    - Installation de Certbot
    - Configuration SSL dans Apache
    - Redirection HTTP vers HTTPS
5. Pare-feu et ports
    
    - Ouverture des ports 80 et 443
    - Fermeture du port 3306 en externe
    - Règles firewalld/ufw

---

📘 PARTIE 8 : Maintenance et surveillance Fichier Obsidian suggéré : `08-maintenance-surveillance-lamp.md`

**Sujets à couvrir :**

1. Mises à jour système
    
    - Mise à jour des paquets Linux
    - Mise à jour des composants LAMP
    - Gestion des versions PHP
2. Surveillance des services
    
    - Vérification de l'état des services
    - Commandes de diagnostic (netstat, ss, ps)
    - Surveillance de l'espace disque
3. Gestion des logs
    
    - Analyse des logs Apache
    - Logs MySQL/MariaDB
    - Rotation automatique des logs
4. Optimisation de base
    
    - Configuration Apache (KeepAlive, MaxClients)
    - Optimisation MySQL (innodb_buffer_pool_size)
    - Cache PHP (OPcache)
5. Sauvegarde régulière
    
    - Sauvegarde des fichiers web
    - Sauvegarde des bases de données
    - Automatisation avec cron