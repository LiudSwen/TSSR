

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

La sécurisation de MySQL/MariaDB est une étape **cruciale** dans le déploiement d'une stack LAMP. Une base de données mal sécurisée représente une porte d'entrée privilégiée pour les attaquants, pouvant mener à :

- Vol de données sensibles
- Modification ou suppression de données
- Escalade de privilèges sur le serveur
- Utilisation du serveur comme relais d'attaque

> [!info] Principe fondamental La sécurisation repose sur le **principe du moindre privilège** : chaque utilisateur et application ne doit avoir accès qu'aux ressources strictement nécessaires à son fonctionnement.

---

## 👥 Utilisateurs avec privilèges minimaux

### 📘 Pourquoi c'est important

L'utilisation du compte **root** pour les applications est une grave erreur de sécurité. Si un attaquant compromet votre application web, il obtient immédiatement un accès total à toutes les bases de données.

**Les risques** :

- Accès illimité à toutes les bases de données du serveur
- Possibilité de créer/supprimer des utilisateurs
- Exécution de commandes système via certaines fonctions MySQL
- Aucune traçabilité des actions (tout est fait par root)

### 🛠️ Création d'un utilisateur dédié

#### Étape 1 : Connexion en tant que root

```bash
# Connexion à MySQL/MariaDB
sudo mysql -u root -p
```

> [!tip] Sans mot de passe root Si vous venez d'installer MySQL/MariaDB et que l'authentification par socket est activée, utilisez simplement : `sudo mysql`

#### Étape 2 : Création de l'utilisateur

```sql
-- Créer un utilisateur pour une application spécifique
CREATE USER 'mon_app_user'@'localhost' IDENTIFIED BY 'MotDePasseComplexe123!';

-- Vérifier la création
SELECT User, Host FROM mysql.user WHERE User = 'mon_app_user';
```

> [!warning] Choix du mot de passe Utilisez un mot de passe fort :
> 
> - Minimum 16 caractères
> - Mélange de majuscules, minuscules, chiffres et symboles
> - Évitez les mots du dictionnaire
> - Utilisez un gestionnaire de mots de passe

#### Étape 3 : Attribution des privilèges minimaux

```sql
-- Accorder uniquement les privilèges nécessaires sur une base spécifique
GRANT SELECT, INSERT, UPDATE, DELETE ON ma_base_de_donnees.* 
TO 'mon_app_user'@'localhost';

-- Appliquer les changements
FLUSH PRIVILEGES;
```

> [!example] Exemple pour une application WordPress
> 
> ```sql
> -- Créer l'utilisateur WordPress
> CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'Wp$ecure2024Pass!';
> 
> -- Créer la base de données
> CREATE DATABASE wordpress_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
> 
> -- Accorder les privilèges nécessaires
> GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX 
> ON wordpress_db.* TO 'wp_user'@'localhost';
> 
> FLUSH PRIVILEGES;
> ```

### 📊 Tableau des privilèges MySQL

|Privilège|Description|Cas d'usage typique|
|---|---|---|
|`SELECT`|Lecture des données|Toutes applications|
|`INSERT`|Ajout de données|Applications CRUD|
|`UPDATE`|Modification de données|Applications CRUD|
|`DELETE`|Suppression de données|Applications CRUD|
|`CREATE`|Création de tables|Installation/Migration|
|`DROP`|Suppression de tables|Migration (rarement)|
|`ALTER`|Modification de structure|Migration/Mise à jour|
|`INDEX`|Gestion des index|Optimisation|
|`EXECUTE`|Exécution de procédures|Applications avancées|
|`ALL PRIVILEGES`|⚠️ Tous les droits|**ÉVITER**|

### 🔍 Vérification des privilèges

```sql
-- Voir les privilèges d'un utilisateur
SHOW GRANTS FOR 'mon_app_user'@'localhost';

-- Exemple de sortie :
-- GRANT SELECT, INSERT, UPDATE, DELETE ON `ma_base_de_donnees`.* TO `mon_app_user`@`localhost`
```

### 🗑️ Révocation de privilèges

```sql
-- Retirer des privilèges spécifiques
REVOKE DELETE ON ma_base_de_donnees.* FROM 'mon_app_user'@'localhost';

-- Retirer tous les privilèges
REVOKE ALL PRIVILEGES ON ma_base_de_donnees.* FROM 'mon_app_user'@'localhost';

FLUSH PRIVILEGES;
```

### ⚠️ Pièges courants

> [!warning] Erreur 1 : Utiliser le même utilisateur pour tout Ne créez pas un seul utilisateur pour toutes vos applications. Chaque application doit avoir son propre utilisateur dédié à sa base de données.

> [!warning] Erreur 2 : Accorder trop de privilèges "au cas où" N'accordez jamais `ALL PRIVILEGES` ou `GRANT OPTION` sauf nécessité absolue. Commencez avec le minimum et ajoutez au besoin.

> [!warning] Erreur 3 : Oublier le FLUSH PRIVILEGES Après modification des privilèges, toujours exécuter `FLUSH PRIVILEGES;` pour que les changements soient pris en compte immédiatement.

### 💡 Astuces avancées

**Utiliser des utilisateurs temporaires pour les migrations** :

```sql
-- Créer un utilisateur pour une migration ponctuelle
CREATE USER 'migration_temp'@'localhost' IDENTIFIED BY 'TempPass123!';
GRANT ALL PRIVILEGES ON ma_base_de_donnees.* TO 'migration_temp'@'localhost';
FLUSH PRIVILEGES;

-- Après la migration, supprimer l'utilisateur
DROP USER 'migration_temp'@'localhost';
```

**Limiter les ressources d'un utilisateur** :

```sql
-- Limiter le nombre de requêtes par heure
ALTER USER 'mon_app_user'@'localhost' 
WITH MAX_QUERIES_PER_HOUR 1000 
MAX_UPDATES_PER_HOUR 500 
MAX_CONNECTIONS_PER_HOUR 100;
```

---

## 🚫 Désactivation de l'accès root distant

### 📘 Pourquoi c'est important

Par défaut, l'utilisateur **root** peut se connecter uniquement depuis `localhost`. Cependant, certaines configurations permettent l'accès distant, ce qui représente un **risque majeur** :

- Exposition du compte le plus puissant aux attaques réseau
- Cible privilégiée des attaques par force brute
- Absence de nécessité réelle dans la plupart des architectures

> [!info] Principe de sécurité L'utilisateur root ne doit **jamais** être accessible depuis le réseau. Toute administration distante doit passer par SSH puis connexion locale.

### 🔍 Vérification de la configuration actuelle

```bash
# Se connecter à MySQL
sudo mysql -u root -p
```

```sql
-- Vérifier les comptes root existants
SELECT User, Host, plugin FROM mysql.user WHERE User = 'root';

-- Résultat souhaité : Host = 'localhost' uniquement
-- +------+-----------+-----------------------+
-- | User | Host      | plugin                |
-- +------+-----------+-----------------------+
-- | root | localhost | auth_socket           |
-- +------+-----------+-----------------------+
```

> [!warning] Configuration dangereuse Si vous voyez `root` avec Host = `%` ou une adresse IP, **votre serveur est vulnérable** !

### 🛡️ Suppression des accès root distants

#### Méthode 1 : Suppression des comptes root distants

```sql
-- Supprimer tous les comptes root qui ne sont pas localhost
DELETE FROM mysql.user WHERE User = 'root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Vérifier que seul localhost reste
SELECT User, Host FROM mysql.user WHERE User = 'root';
```

#### Méthode 2 : Désactivation sélective

```sql
-- Si vous avez besoin de garder le compte mais désactivé
UPDATE mysql.user 
SET authentication_string = '', plugin = '' 
WHERE User = 'root' AND Host != 'localhost';

FLUSH PRIVILEGES;
```

### 🔒 Renforcement de la configuration

#### Configuration dans `/etc/mysql/mariadb.conf.d/50-server.cnf` (ou mysql.conf.d)

```bash
# Éditer le fichier de configuration
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

Vérifier/ajouter cette ligne :

```ini
[mysqld]
# Écouter uniquement sur localhost
bind-address = 127.0.0.1

# Désactiver le networking complètement (optionnel, très restrictif)
# skip-networking
```

> [!tip] bind-address vs skip-networking
> 
> - `bind-address = 127.0.0.1` : MySQL n'écoute que sur localhost, mais accepte les connexions locales via TCP
> - `skip-networking` : Désactive complètement le réseau, seules les connexions via socket Unix sont possibles (plus restrictif)

```bash
# Redémarrer MySQL pour appliquer les changements
sudo systemctl restart mysql
# ou pour MariaDB
sudo systemctl restart mariadb
```

### ✅ Validation de la configuration

```bash
# Vérifier que MySQL n'écoute que sur localhost
sudo netstat -tlnp | grep mysql
# ou avec ss
sudo ss -tlnp | grep mysql

# Résultat attendu :
# tcp  0  0  127.0.0.1:3306  0.0.0.0:*  LISTEN  1234/mysqld
```

> [!example] Test de connexion distante (doit échouer) Depuis une autre machine :
> 
> ```bash
> mysql -h IP_DU_SERVEUR -u root -p
> # Résultat attendu : ERROR 2003 (HY000): Can't connect to MySQL server
> ```

### 🔐 Authentification par socket Unix

MariaDB/MySQL moderne utilise le plugin `auth_socket` pour root :

```sql
-- Vérifier le plugin d'authentification de root
SELECT User, Host, plugin FROM mysql.user WHERE User = 'root';

-- Si nécessaire, activer auth_socket pour root
ALTER USER 'root'@'localhost' IDENTIFIED VIA unix_socket;
FLUSH PRIVILEGES;
```

> [!info] Avantage du auth_socket Avec `auth_socket`, seul l'utilisateur système `root` peut se connecter à MySQL en tant que root, sans même utiliser de mot de passe. Cela élimine le risque d'attaque par force brute sur le mot de passe.

### 💡 Astuces

**Pour l'administration distante sécurisée** :

```bash
# Utiliser un tunnel SSH au lieu d'ouvrir MySQL au réseau
ssh -L 3307:localhost:3306 user@serveur-distant

# Puis se connecter localement sur le port tunnelisé
mysql -h 127.0.0.1 -P 3307 -u root -p
```

**Créer un utilisateur admin dédié (si absolument nécessaire)** :

```sql
-- Créer un utilisateur pour l'administration distante (mieux que root)
CREATE USER 'admin_backup'@'IP_SPECIFIQUE' IDENTIFIED BY 'MotDePasseTresComplexe!';
GRANT ALL PRIVILEGES ON *.* TO 'admin_backup'@'IP_SPECIFIQUE' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

---

## 🔄 Changement du port par défaut

### 📘 Pourquoi changer le port

Le port **3306** est le port par défaut de MySQL/MariaDB. Changer ce port apporte un niveau de sécurité supplémentaire par **obscurcissement** :

**Avantages** :

- Réduit les scans automatisés ciblant le port 3306
- Complique les attaques opportunistes
- Ajoute une couche de défense en profondeur

**Limites** :

- Ce n'est **pas** une solution de sécurité à elle seule
- N'empêche pas un attaquant déterminé
- Peut compliquer la maintenance

> [!warning] Sécurité par l'obscurité Le changement de port est une mesure **complémentaire**, pas principale. Il ne remplace JAMAIS une vraie sécurisation (mots de passe forts, privilèges minimaux, firewall, etc.).

### 🛠️ Modification du port

#### Étape 1 : Choisir un nouveau port

```bash
# Vérifier les ports disponibles
sudo netstat -tlnp | grep LISTEN
# ou
sudo ss -tlnp | grep LISTEN

# Choisir un port entre 1024 et 65535 non utilisé
# Exemple : 33060, 13306, 3307
```

> [!tip] Choix du port
> 
> - Évitez les ports bien connus (< 1024)
> - Préférez un port entre 10000 et 65535
> - Documentez votre choix pour la maintenance future
> - Évitez les ports déjà utilisés par d'autres services

#### Étape 2 : Modifier la configuration MySQL

```bash
# Éditer le fichier de configuration principal
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
# ou pour MySQL
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Modifier/ajouter la directive `port` :

```ini
[mysqld]
# Port par défaut
# port = 3306

# Nouveau port personnalisé
port = 13306

# S'assurer que bind-address est correctement défini
bind-address = 127.0.0.1
```

#### Étape 3 : Redémarrer le service

```bash
# Tester la configuration avant de redémarrer
sudo mysqld --help --verbose | grep port

# Redémarrer MySQL/MariaDB
sudo systemctl restart mysql
# ou
sudo systemctl restart mariadb

# Vérifier le statut
sudo systemctl status mysql
```

#### Étape 4 : Vérifier le changement

```bash
# Vérifier que MySQL écoute sur le nouveau port
sudo netstat -tlnp | grep mysql
# ou
sudo ss -tlnp | grep mysql

# Résultat attendu :
# tcp  0  0  127.0.0.1:13306  0.0.0.0:*  LISTEN  5678/mysqld
```

### 🔌 Connexion au nouveau port

#### Depuis la ligne de commande

```bash
# Spécifier le port avec l'option -P (majuscule)
mysql -u root -p -P 13306
# ou
mysql -u root -p --port=13306

# Avec un hôte spécifique
mysql -h localhost -P 13306 -u root -p
```

#### Configuration du client MySQL

Créer/modifier `~/.my.cnf` pour éviter de spécifier le port à chaque fois :

```bash
nano ~/.my.cnf
```

```ini
[client]
port = 13306
user = mon_user
# password = "mon_pass"  # Éviter de mettre le mot de passe ici
```

```bash
# Protéger le fichier
chmod 600 ~/.my.cnf
```

### 🔧 Mise à jour des applications

> [!warning] Impact sur les applications Après le changement de port, **toutes vos applications** doivent être mises à jour avec le nouveau port.

#### Configuration PHP (exemple)

```php
// Fichier de configuration de l'application (config.php)
$db_host = 'localhost';
$db_port = 13306;  // Nouveau port
$db_name = 'ma_base';
$db_user = 'mon_user';
$db_pass = 'mon_pass';

// Connexion PDO
$dsn = "mysql:host=$db_host;port=$db_port;dbname=$db_name;charset=utf8mb4";
$pdo = new PDO($dsn, $db_user, $db_pass);
```

#### Configuration WordPress

```php
// Modifier wp-config.php
define('DB_HOST', 'localhost:13306');
```

#### Configuration général des applications

La plupart des applications acceptent la notation `host:port` :

- `localhost:13306`
- `127.0.0.1:13306`

### 🔥 Configuration du pare-feu

Si vous avez un pare-feu actif (UFW, iptables), pensez à mettre à jour les règles :

```bash
# Avec UFW
# Supprimer l'ancienne règle (si elle existe)
sudo ufw delete allow 3306/tcp

# Ajouter la nouvelle règle (uniquement si accès distant nécessaire)
sudo ufw allow 13306/tcp

# Vérifier les règles
sudo ufw status numbered
```

> [!tip] Pare-feu et localhost Si MySQL écoute uniquement sur `127.0.0.1`, les règles de pare-feu n'ont aucun impact car le trafic localhost ne passe pas par le pare-feu.

### 🔍 Dépannage

**Problème : Impossible de se connecter après changement**

```bash
# 1. Vérifier que MySQL écoute sur le bon port
sudo ss -tlnp | grep mysql

# 2. Vérifier les logs d'erreurs
sudo tail -f /var/log/mysql/error.log

# 3. Tester la connexion avec le nouveau port
mysql -h 127.0.0.1 -P 13306 -u root -p

# 4. Vérifier la configuration
sudo mysqld --help --verbose | grep -A 1 "Default options"
```

**Problème : Le service ne démarre pas**

```bash
# Vérifier la syntaxe de la configuration
sudo mysqld --help --verbose

# Vérifier que le port n'est pas déjà utilisé
sudo netstat -tlnp | grep 13306

# Consulter les logs système
sudo journalctl -xe -u mysql
```

### 💡 Astuces avancées

**Utiliser plusieurs ports (configuration multi-instance)** :

Si vous exécutez plusieurs instances MySQL :

```ini
[mysqld1]
port = 3306
socket = /var/run/mysqld/mysqld1.sock
datadir = /var/lib/mysql1

[mysqld2]
port = 3307
socket = /var/run/mysqld/mysqld2.sock
datadir = /var/lib/mysql2
```

**Documentation du changement** :

Créez un fichier de documentation pour votre équipe :

```bash
# Créer un fichier README
sudo nano /root/mysql-config-notes.txt
```

```text
Configuration MySQL personnalisée
==================================
Port modifié : 13306 (au lieu de 3306)
Date du changement : 2024-12-22
Raison : Sécurité renforcée

Applications impactées :
- WordPress : wp-config.php modifié
- API custom : config/database.php modifié
- Scripts de backup : backup.sh ligne 15 modifiée

Connexion :
mysql -u user -p -P 13306
```

---

## 📋 Récapitulatif des bonnes pratiques

> [!tip] Checklist de sécurisation MySQL/MariaDB

### ✅ Utilisateurs et privilèges

- [ ] Créer des utilisateurs dédiés par application
- [ ] Accorder uniquement les privilèges nécessaires (SELECT, INSERT, UPDATE, DELETE)
- [ ] Ne jamais utiliser root pour les applications
- [ ] Ne jamais accorder `ALL PRIVILEGES` sauf exception justifiée
- [ ] Utiliser des mots de passe forts (16+ caractères)
- [ ] Exécuter `FLUSH PRIVILEGES` après chaque modification
- [ ] Documenter les utilisateurs et leurs permissions

### 🚫 Accès root

- [ ] Vérifier qu'aucun compte root distant n'existe
- [ ] Supprimer tout compte root avec Host != 'localhost'
- [ ] Configurer `bind-address = 127.0.0.1`
- [ ] Activer `auth_socket` pour root
- [ ] Tester qu'aucune connexion distante root n'est possible
- [ ] Utiliser SSH + tunnel pour administration distante

### 🔄 Port personnalisé (optionnel)

- [ ] Choisir un port non standard (ex: 13306)
- [ ] Modifier le fichier de configuration
- [ ] Mettre à jour toutes les applications
- [ ] Documenter le changement
- [ ] Tester les connexions après modification
- [ ] Mettre à jour le pare-feu si nécessaire

### 🔒 Sécurité générale

```bash
# Script de vérification rapide
sudo mysql -u root -p -e "
SELECT CONCAT('Users: ', COUNT(*)) FROM mysql.user;
SELECT User, Host FROM mysql.user WHERE User = 'root';
SHOW VARIABLES LIKE 'bind_address';
SHOW VARIABLES LIKE 'port';
"
```

### 📊 Résumé visuel

|Mesure|Niveau|Effort|Impact|
|---|---|---|---|
|Utilisateurs dédiés|⚠️ **Critique**|🟢 Faible|🔴 Élevé|
|Privilèges minimaux|⚠️ **Critique**|🟢 Faible|🔴 Élevé|
|Pas de root distant|⚠️ **Critique**|🟢 Faible|🔴 Élevé|
|bind-address localhost|⚠️ **Critique**|🟢 Faible|🔴 Élevé|
|Changement de port|ℹ️ Optionnel|🟡 Moyen|🟡 Moyen|

> [!info] Défense en profondeur La sécurité repose sur la **combinaison** de plusieurs mesures. Aucune solution unique ne suffit, mais leur accumulation rend les attaques exponentiellement plus difficiles.

---

**🎓 Points clés à retenir** :

1. **Principe du moindre privilège** : Chaque utilisateur n'a accès qu'à ce dont il a besoin
2. **Root = Administration uniquement** : Jamais pour les applications
3. **Localhost uniquement** : Pas d'accès réseau pour les comptes critiques
4. **Obscurité ≠ Sécurité** : Le changement de port aide mais ne remplace pas une vraie sécurisation
5. **Documentation** : Toujours documenter vos changements de configuration

**Commande de validation finale** :

```bash
# Test complet de la configuration
sudo mysql -u root -p << EOF
-- Vérifier les utilisateurs
SELECT User, Host, plugin FROM mysql.user ORDER BY User, Host;

-- Vérifier la configuration réseau
SHOW VARIABLES LIKE 'bind_address';
SHOW VARIABLES LIKE 'port';
SHOW VARIABLES LIKE 'skip_networking';

-- Vérifier les privilèges d'un utilisateur applicatif
SHOW GRANTS FOR 'mon_app_user'@'localhost';
EOF
```

---

_Cours créé pour la sécurisation de la stack LAMP - Section MySQL/MariaDB_