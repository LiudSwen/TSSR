

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

## 📄 Fichier my.cnf / my.ini

### Qu'est-ce que c'est ?

Le fichier de configuration MySQL/MariaDB est le fichier central qui définit le comportement du serveur de base de données. Il contient tous les paramètres qui contrôlent les performances, la sécurité, les connexions réseau et bien d'autres aspects.

> [!info] Différence de nom selon l'OS
> 
> - **Linux/Unix** : `my.cnf`
> - **Windows** : `my.ini`
> 
> Le contenu et la syntaxe sont identiques, seul le nom change.

### 🗂️ Emplacements du fichier

MySQL/MariaDB recherche le fichier de configuration dans plusieurs emplacements, dans cet ordre de priorité :

|Priorité|Emplacement Linux/Unix|Emplacement Windows|Description|
|---|---|---|---|
|1|`/etc/my.cnf`|`C:\Windows\my.ini`|Configuration globale du système|
|2|`/etc/mysql/my.cnf`|`C:\ProgramData\MySQL\MySQL Server X.X\my.ini`|Configuration spécifique MySQL|
|3|`~/.my.cnf`|`%APPDATA%\MySQL\my.ini`|Configuration utilisateur|
|4|Paramètre `--defaults-file`|Paramètre `--defaults-file`|Fichier spécifié au démarrage|

> [!tip] Trouver le fichier actif Pour savoir quel fichier de configuration est actuellement utilisé :
> 
> ```bash
> mysql --help | grep "Default options" -A 1
> # ou
> mysqld --verbose --help | grep "Default options" -A 1
> ```

### 📐 Structure du fichier

Le fichier est organisé en **sections** délimitées par des crochets `[nom_section]`. Chaque section s'applique à un composant spécifique :

```ini
# ========================================
# CONFIGURATION MYSQL/MARIADB
# ========================================

# Section pour le client mysql (ligne de commande)
[client]
port = 3306
socket = /var/run/mysqld/mysqld.sock

# Section pour le serveur mysqld
[mysqld]
user = mysql
pid-file = /var/run/mysqld/mysqld.pid
socket = /var/run/mysqld/mysqld.sock
port = 3306
basedir = /usr
datadir = /var/lib/mysql

# Section pour mysqldump
[mysqldump]
quick
max_allowed_packet = 16M

# Section pour mysql (client)
[mysql]
no-auto-rehash
```

> [!warning] Sections principales à connaître
> 
> - **[client]** : Paramètres pour tous les programmes clients (mysql, mysqldump, etc.)
> - **[mysqld]** : Paramètres du serveur MySQL/MariaDB (LA PLUS IMPORTANTE)
> - **[mysql]** : Paramètres spécifiques au client en ligne de commande
> - **[mysqldump]** : Paramètres pour l'outil de sauvegarde
> - **[mysqld_safe]** : Paramètres pour le wrapper de démarrage sécurisé

### ✍️ Syntaxe des paramètres

```ini
# Commentaire : ligne ignorée

# Syntaxe avec = (recommandée)
parameter_name = value

# Syntaxe sans = (pour les booléens)
skip-networking

# Équivalent avec = 
skip-networking = 1

# Valeurs avec unités
max_connections = 100
innodb_buffer_pool_size = 1G  # G = Gigabytes, M = Megabytes, K = Kilobytes
```

> [!tip] Conventions de nommage MySQL accepte deux formats pour les noms de paramètres :
> 
> - Avec tirets : `max-connections`
> - Avec underscores : `max_connections`
> 
> Les deux sont équivalents, mais l'underscore est plus courant dans les configurations modernes.

### 🔄 Appliquer les modifications

Après avoir modifié `my.cnf` / `my.ini`, il faut redémarrer le serveur :

```bash
# Debian/Ubuntu
sudo systemctl restart mysql

# CentOS/RHEL
sudo systemctl restart mysqld

# Windows (en tant qu'administrateur)
net stop MySQL
net start MySQL
```

> [!warning] Vérifier la syntaxe avant redémarrage Une erreur dans le fichier empêchera le démarrage du serveur !
> 
> ```bash
> # Tester la configuration sans démarrer
> mysqld --validate-config
> 
> # Voir les erreurs détaillées
> sudo journalctl -u mysql -n 50
> ```

### 🎯 Paramètres essentiels de la section [mysqld]

Voici les paramètres de base que vous rencontrerez systématiquement :

```ini
[mysqld]
# Identité et localisation
user = mysql                           # Utilisateur système qui exécute MySQL
datadir = /var/lib/mysql              # Dossier des bases de données
socket = /var/run/mysqld/mysqld.sock  # Socket Unix pour connexions locales
pid-file = /var/run/mysqld/mysqld.pid # Fichier contenant le PID du processus

# Réseau (détaillé dans les sections suivantes)
port = 3306
bind-address = 127.0.0.1

# Encodage (détaillé dans une section suivante)
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Logs (mentionné pour information, pas détaillé ici)
log_error = /var/log/mysql/error.log
```

---

## 🔌 Port d'écoute

### Concept

Le **port d'écoute** est le numéro de port TCP sur lequel le serveur MySQL/MariaDB attend les connexions réseau. C'est comme une porte d'entrée numérotée dans votre serveur.

> [!info] Port par défaut Le port standard de MySQL/MariaDB est **3306**. C'est ce port qui est universellement reconnu pour MySQL.

### Configuration du port

```ini
[mysqld]
port = 3306
```

### 🤔 Pourquoi changer le port ?

|Raison|Explication|Port exemple|
|---|---|---|
|**Sécurité par obscurité**|Rendre les scans automatiques moins efficaces|33306, 13306|
|**Plusieurs instances**|Faire tourner plusieurs serveurs MySQL sur la même machine|3306, 3307, 3308|
|**Conflit de port**|Un autre service utilise déjà le 3306|N'importe quel port libre|
|**Politique d'entreprise**|Standards internes spécifiques|Selon la politique|

> [!warning] Implications du changement de port Si vous changez le port, vous devrez :
> 
> - Modifier toutes les connexions clients
> - Ajuster le pare-feu
> - Mettre à jour les applications qui se connectent à la base

### 🔐 Connexion avec un port personnalisé

Quand le port n'est pas le 3306 par défaut, vous devez le spécifier explicitement :

```bash
# Ligne de commande
mysql -h localhost -P 3307 -u root -p

# Chaîne de connexion PHP
$conn = new mysqli("localhost:3307", "user", "password", "database");

# URL JDBC (Java)
jdbc:mysql://localhost:3307/database
```

> [!tip] Option -P vs -p
> 
> - **-P** (majuscule) : spécifie le **Port**
> - **-p** (minuscule) : demande le **password**
> 
> Ne pas les confondre !

### 🔍 Vérifier le port en écoute

```bash
# Voir tous les ports MySQL en écoute
sudo netstat -tlnp | grep mysql
# ou
sudo ss -tlnp | grep mysql

# Résultat attendu :
# tcp  0  0 127.0.0.1:3306  0.0.0.0:*  LISTEN  1234/mysqld

# Tester la connexion sur un port
telnet localhost 3306
# ou
nc -zv localhost 3306
```

### 🛡️ Sécurité et pare-feu

Si vous exposez MySQL sur le réseau, configurez votre pare-feu :

```bash
# UFW (Ubuntu/Debian)
sudo ufw allow 3306/tcp

# FirewallD (CentOS/RHEL)
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload

# iptables (méthode manuelle)
sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
```

> [!warning] Attention aux ports exposés N'ouvrez le port MySQL sur Internet que si absolument nécessaire ! Préférez des solutions comme :
> 
> - VPN pour l'accès distant
> - Tunnels SSH
> - Proxy inverse avec authentification

---

## 🌐 Bind-address

### Concept fondamental

Le paramètre **bind-address** détermine **sur quelle(s) interface(s) réseau** MySQL écoute les connexions. C'est un paramètre de sécurité crucial qui contrôle qui peut se connecter au serveur.

```ini
[mysqld]
bind-address = 127.0.0.1
```

### 📍 Valeurs possibles et leur signification

|Valeur|Signification|Qui peut se connecter ?|Usage recommandé|
|---|---|---|---|
|`127.0.0.1`|Localhost uniquement (IPv4)|Applications sur le même serveur|**Développement local, serveur web + MySQL sur même machine**|
|`::1`|Localhost uniquement (IPv6)|Applications sur le même serveur (IPv6)|Environnements IPv6 purs|
|`0.0.0.0`|Toutes les interfaces|N'importe qui sur le réseau|Serveur dédié aux bases de données|
|`192.168.1.10`|Interface spécifique|Clients du réseau via cette IP|Isoler MySQL sur un réseau interne|
|Omis ou commenté|Par défaut = `0.0.0.0`|Toutes les connexions acceptées|⚠️ Dangereux en production|

### 🔒 Cas d'usage : 127.0.0.1 (Configuration sécurisée par défaut)

**Quand l'utiliser ?** Architecture LAMP classique où Apache/Nginx et MySQL sont sur le même serveur.

```ini
[mysqld]
bind-address = 127.0.0.1
port = 3306
```

**Avantages :**

- ✅ Sécurité maximale : impossible de se connecter depuis l'extérieur
- ✅ Pas de risque d'exposition accidentelle
- ✅ Performances légèrement meilleures (pas de couche réseau)

**Limitations :**

- ❌ Impossible de connecter depuis un autre serveur
- ❌ Impossible de gérer la base depuis un client distant

> [!example] Scénario typique Un site WordPress hébergé sur un VPS :
> 
> - Apache et MySQL sur le même serveur
> - WordPress se connecte via localhost
> - Aucun accès externe à MySQL nécessaire → `bind-address = 127.0.0.1` est parfait !

### 🌍 Cas d'usage : 0.0.0.0 (Accès réseau complet)

**Quand l'utiliser ?** Serveur de base de données dédié, ou accès distant nécessaire.

```ini
[mysqld]
bind-address = 0.0.0.0
port = 3306
```

**Avantages :**

- ✅ Connexions depuis n'importe quelle machine
- ✅ Architecture multi-serveurs possible
- ✅ Outils d'administration distants (MySQL Workbench, phpMyAdmin distant)

**Risques et protections obligatoires :**

> [!warning] ATTENTION : Configuration dangereuse sans précautions ! Avec `0.0.0.0`, votre MySQL est exposé. Vous DEVEZ :
> 
> 1. Configurer un pare-feu stricte
> 2. Utiliser des mots de passe robustes
> 3. Limiter les utilisateurs aux IPs autorisées
> 4. Désactiver le compte root distant

**Protection par pare-feu :**

```bash
# N'autoriser que certaines IPs
sudo ufw allow from 192.168.1.0/24 to any port 3306
sudo ufw deny 3306

# Ou avec iptables
sudo iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 3306 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 3306 -j DROP
```

**Protection au niveau MySQL :**

```sql
-- Créer un utilisateur limité à une IP spécifique
CREATE USER 'app_user'@'192.168.1.50' IDENTIFIED BY 'mot_de_passe_fort';
GRANT ALL PRIVILEGES ON app_db.* TO 'app_user'@'192.168.1.50';

-- Interdire root à distance (autoriser uniquement localhost)
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;
```

### 🎯 Cas d'usage : IP spécifique (Isolation réseau)

**Quand l'utiliser ?** Serveur avec plusieurs interfaces réseau, où vous voulez isoler MySQL.

```ini
[mysqld]
bind-address = 10.0.1.100  # Interface réseau privé
port = 3306
```

**Scénario typique :** Un serveur avec 2 cartes réseau :

- `eth0` (192.168.1.10) : réseau public
- `eth1` (10.0.1.100) : réseau privé backend

En configurant `bind-address = 10.0.1.100`, MySQL n'est accessible que depuis le réseau privé.

### 🔄 Passer de 127.0.0.1 à 0.0.0.0

**Procédure complète :**

```bash
# 1. Modifier la configuration
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

# Changer :
# bind-address = 127.0.0.1
# En :
bind-address = 0.0.0.0

# 2. Redémarrer MySQL
sudo systemctl restart mysql

# 3. Vérifier l'écoute réseau
sudo netstat -tlnp | grep 3306
# Avant : tcp  0  0 127.0.0.1:3306  ...
# Après : tcp  0  0 0.0.0.0:3306    ...

# 4. Configurer le pare-feu
sudo ufw allow from 192.168.1.0/24 to any port 3306

# 5. Créer des utilisateurs réseau
mysql -u root -p
```

```sql
-- Créer un utilisateur accessible depuis le réseau
CREATE USER 'remote_user'@'%' IDENTIFIED BY 'password_securise';
GRANT SELECT, INSERT, UPDATE, DELETE ON app_db.* TO 'remote_user'@'%';
FLUSH PRIVILEGES;
```

### 🧪 Tester la connexion distante

```bash
# Depuis une machine distante, tester la connexion
mysql -h 192.168.1.10 -P 3306 -u remote_user -p

# Si erreur "Can't connect" :
# - Vérifier bind-address
# - Vérifier le pare-feu
# - Vérifier les privilèges utilisateur
```

> [!tip] Diagnostic des problèmes de connexion
> 
> ```bash
> # 1. MySQL écoute-t-il sur le bon port/IP ?
> sudo ss -tlnp | grep 3306
> 
> # 2. Le pare-feu bloque-t-il ?
> sudo ufw status
> telnet <ip_serveur> 3306
> 
> # 3. L'utilisateur a-t-il les droits ?
> SELECT User, Host FROM mysql.user;
> ```

### 📊 Comparaison récapitulative

|Critère|127.0.0.1|0.0.0.0|IP spécifique|
|---|---|---|---|
|**Sécurité**|⭐⭐⭐⭐⭐|⭐⭐ (avec pare-feu)|⭐⭐⭐⭐|
|**Complexité**|Très simple|Nécessite sécurisation|Moyenne|
|**Accès distant**|❌ Non|✅ Oui|✅ Oui (réseau ciblé)|
|**Performance locale**|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|⭐⭐⭐⭐|
|**Architecture**|Monolithique|Distribuée|Distribuée contrôlée|

---

## 🔤 Character set et collation

### Concepts essentiels

Le **character set** (jeu de caractères) définit **quels caractères peuvent être stockés** dans la base de données, tandis que la **collation** définit **comment ces caractères sont comparés et triés**.

> [!info] Analogie simple
> 
> - **Character set** : l'alphabet que vous utilisez (latin, cyrillique, japonais...)
> - **Collation** : les règles de tri de cet alphabet (A avant B, accents ignorés ou pas, casse...)

### 🌍 Character sets principaux

|Character Set|Nom complet|Description|Usage|Taille max/char|
|---|---|---|---|---|
|`latin1`|ISO 8859-1|Europe occidentale basique|⚠️ Obsolète, à éviter|1 octet|
|`utf8`|UTF-8 (3 octets)|Unicode partiel, sans emojis|⚠️ Piège ! Utiliser utf8mb4|1-3 octets|
|`utf8mb4`|UTF-8 (4 octets)|Unicode complet avec emojis|✅ **Recommandé pour tout**|1-4 octets|
|`utf16`|UTF-16|Unicode sur 2/4 octets|Rare, cas spécifiques|2-4 octets|
|`ascii`|ASCII|Caractères anglais uniquement|Scripts, identifiants|1 octet|

> [!warning] Piège fréquent : utf8 vs utf8mb4 En MySQL, `utf8` est en réalité **UTF-8 sur 3 octets**, ce qui exclut :
> 
> - Les emojis (😀, 🎉, ❤️)
> - Certains caractères asiatiques rares
> - Les symboles mathématiques avancés
> 
> **Utilisez TOUJOURS `utf8mb4`** pour un support Unicode complet !

### 📏 Collations courantes

Les collations définissent les règles de comparaison et de tri. Format : `charset_language_variant`

#### Pour utf8mb4 (les plus utilisées)

|Collation|Description|Sensible à la casse|Sensible aux accents|Performance|Usage|
|---|---|---|---|---|---|
|`utf8mb4_general_ci`|Général, rapide|❌ Non (CI)|❌ Non|⭐⭐⭐⭐⭐|Ancienne référence|
|`utf8mb4_unicode_ci`|Unicode standard|❌ Non (CI)|❌ Non|⭐⭐⭐⭐|**Recommandé général**|
|`utf8mb4_unicode_520_ci`|Unicode 5.2.0|❌ Non (CI)|❌ Non|⭐⭐⭐|Tri multilingue avancé|
|`utf8mb4_bin`|Binaire (octet par octet)|✅ Oui|✅ Oui|⭐⭐⭐⭐⭐|Comparaisons exactes|
|`utf8mb4_0900_ai_ci`|MySQL 8.0+, moderne|❌ Non (CI)|❌ Non (AI)|⭐⭐⭐⭐|**MySQL 8.0+ recommandé**|

**Légende des suffixes :**

- `ci` = Case Insensitive (insensible à la casse : 'A' = 'a')
- `cs` = Case Sensitive (sensible à la casse : 'A' ≠ 'a')
- `ai` = Accent Insensitive (insensible aux accents : 'e' = 'é')
- `as` = Accent Sensitive (sensible aux accents : 'e' ≠ 'é')
- `bin` = Binary (comparaison binaire stricte)

### ⚙️ Configuration au niveau serveur

Ces paramètres dans `my.cnf` définissent les valeurs par défaut pour toutes les nouvelles bases :

```ini
[mysqld]
# Configuration recommandée moderne
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# MySQL 8.0+ (encore mieux)
character-set-server = utf8mb4
collation-server = utf8mb4_0900_ai_ci
```

> [!tip] Impact de cette configuration Quand vous créez une nouvelle base de données sans spécifier le charset, elle utilisera automatiquement `utf8mb4` avec la collation définie.

### 🗃️ Hiérarchie des niveaux de configuration

MySQL applique les character sets et collations selon une hiérarchie :

```
1. SERVEUR (my.cnf)
   └─ character-set-server, collation-server
      │
      ↓
2. BASE DE DONNÉES
   └─ CREATE DATABASE ... CHARACTER SET ... COLLATE ...
      │
      ↓
3. TABLE
   └─ CREATE TABLE ... CHARACTER SET ... COLLATE ...
      │
      ↓
4. COLONNE
   └─ colonne VARCHAR(100) CHARACTER SET ... COLLATE ...
```

**Règle d'héritage :** Chaque niveau hérite du niveau supérieur s'il n'est pas explicitement défini.

### 💾 Exemples de configuration à différents niveaux

#### Niveau Base de données

```sql
-- Créer une base avec utf8mb4
CREATE DATABASE mon_app 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Modifier une base existante
ALTER DATABASE mon_app 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Vérifier la configuration
SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME 
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME = 'mon_app';
```

#### Niveau Table

```sql
-- Créer une table avec charset explicite
CREATE TABLE utilisateurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100),
    email VARCHAR(255)
) ENGINE=InnoDB 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Modifier une table existante
ALTER TABLE utilisateurs 
CONVERT TO CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
```

#### Niveau Colonne (cas particuliers)

```sql
-- Colonne avec collation spécifique (sensible à la casse)
CREATE TABLE produits (
    id INT PRIMARY KEY,
    code_produit VARCHAR(50) 
        CHARACTER SET utf8mb4 
        COLLATE utf8mb4_bin,  -- Comparaison exacte !
    nom VARCHAR(200)
        CHARACTER SET utf8mb4 
        COLLATE utf8mb4_unicode_ci
);
```

> [!example] Cas d'usage des collations par colonne
> 
> - **Mots de passe hashés** : `utf8mb4_bin` (comparaison stricte)
> - **Codes produits** : `utf8mb4_bin` (AB123 ≠ ab123)
> - **Noms de personnes** : `utf8mb4_unicode_ci` (Müller = Muller)
> - **Emails** : `utf8mb4_general_ci` ou `utf8mb4_bin` selon besoin

### 🔍 Vérifier la configuration actuelle

```sql
-- Configuration du serveur
SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';

-- Résultat typique :
-- character_set_server    | utf8mb4
-- character_set_database  | utf8mb4
-- collation_server        | utf8mb4_unicode_ci
-- collation_database      | utf8mb4_unicode_ci

-- Character sets disponibles
SHOW CHARACTER SET;

-- Collations disponibles pour utf8mb4
SHOW COLLATION WHERE Charset = 'utf8mb4';

-- Configuration d'une base spécifique
SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME 
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME = 'nom_base';

-- Configuration d'une table spécifique
SHOW TABLE STATUS FROM nom_base LIKE 'nom_table';

-- Configuration des colonnes d'une table
SHOW FULL COLUMNS FROM nom_table;
```

### 🔄 Migration depuis latin1 ou utf8 vers utf8mb4

> [!warning] Attention : Sauvegarde obligatoire ! Toujours faire une sauvegarde complète avant une migration de charset :
> 
> ```bash
> mysqldump -u root -p --default-character-set=utf8mb4 \
>   --databases nom_base > backup_avant_migration.sql
> ```

**Procédure complète de migration :**

```sql
-- 1. Modifier la configuration par défaut de la base
ALTER DATABASE nom_base 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 2. Convertir chaque table
-- ATTENTION : Cette opération peut être longue sur de grosses tables !
ALTER TABLE table1 
CONVERT TO CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

ALTER TABLE table2 
CONVERT TO CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 3. Vérifier la conversion
SELECT TABLE_NAME, TABLE_COLLATION 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'nom_base';
```

**Script pour migrer toutes les tables automatiquement :**

```bash
#!/bin/bash
# migration_utf8mb4.sh

DB_NAME="nom_base"
DB_USER="root"
DB_PASS="password"

# Générer les commandes ALTER pour toutes les tables
mysql -u$DB_USER -p$DB_PASS -D$DB_NAME -e "SHOW TABLES" | \
tail -n +2 | \
while read TABLE; do
    echo "ALTER TABLE \`$TABLE\` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
done | mysql -u$DB_USER -p$DB_PASS -D$DB_NAME
```

### 🎯 Impact des collations sur les requêtes

```sql
-- Base de test
CREATE TABLE test_collation (
    id INT PRIMARY KEY AUTO_INCREMENT,
    texte_ci VARCHAR(50) COLLATE utf8mb4_unicode_ci,
    texte_bin VARCHAR(50) COLLATE utf8mb4_bin
);

INSERT INTO test_collation (texte_ci, texte_bin) VALUES 
('Café', 'Café'),
('café', 'café'),
('Cafe', 'Cafe');

-- Comparaison avec utf8mb4_unicode_ci (insensible à la casse et accents)
SELECT * FROM test_collation WHERE texte_ci = 'cafe';
-- Résultat : 3 lignes (Café, café, Cafe)

-- Comparaison avec utf8mb4_bin (sensible à tout)
SELECT * FROM test_collation WHERE texte_bin = 'cafe';
-- Résultat : 0 ligne (aucune correspondance exacte)

SELECT * FROM test_collation WHERE texte_bin = 'Café';
-- Résultat : 1 ligne (correspondance exacte uniquement)

-- Tri avec utf8mb4_unicode_ci
SELECT texte_ci FROM test_collation ORDER BY texte_ci;
-- Résultat : Cafe, Café, café (les 3 sont considérés "égaux" en tri)

-- Tri avec utf8mb4_bin
SELECT texte_bin FROM test_collation ORDER BY texte_bin;
-- Résultat : Cafe, Café, café (ordre ASCII strict)
```

### 🚨 Problèmes courants et solutions

#### Problème 1 : Emojis coupés ou ????

**Symptôme :** Les emojis s'affichent comme "????" ou provoquent des erreurs.

**Cause :** Utilisation de `utf8` (3 octets) au lieu de `utf8mb4` (4 octets).

**Solution :**

```sql
-- Convertir la table
ALTER TABLE messages 
CONVERT TO CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Et dans my.cnf
[mysqld]
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
```

#### Problème 2 : Recherche insensible aux accents ne fonctionne pas

**Symptôme :** Rechercher "cafe" ne trouve pas "café".

**Cause :** Collation `utf8mb4_bin` (sensible) au lieu de `utf8mb4_unicode_ci` (insensible).

**Solution :**

```sql
-- Modifier la collation de la colonne
ALTER TABLE produits 
MODIFY nom VARCHAR(200) 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Ou forcer la collation dans la requête
SELECT * FROM produits 
WHERE nom COLLATE utf8mb4_unicode_ci = 'cafe';
```

#### Problème 3 : Erreur "Illegal mix of collations"

**Symptôme :**

```
ERROR 1267 (HY000): Illegal mix of collations 
(utf8mb4_unicode_ci,IMPLICIT) and (utf8mb4_general_ci,IMPLICIT)
```

**Cause :** Comparaison entre colonnes ayant des collations différentes.

**Solution :**

```sql
-- Option 1 : Unifier les collations des colonnes
ALTER TABLE table1 
MODIFY colonne1 VARCHAR(100) 
COLLATE utf8mb4_unicode_ci;

-- Option 2 : Forcer une collation dans la requête
SELECT * FROM table1 t1
JOIN table2 t2 
ON t1.colonne1 COLLATE utf8mb4_unicode_ci = t2.colonne2;
```

#### Problème 4 : Données corrompues après migration

**Symptôme :** Caractères étranges (Ã©, Ã , etc.) après conversion.

**Cause :** Double encodage ou mauvaise conversion.

**Solution :**

```sql
-- Si les données étaient déjà en UTF-8 mais stockées en latin1
-- Il faut d'abord les "réparer"
ALTER TABLE ma_table 
MODIFY colonne BLOB;  -- Conversion en binaire d'abord

ALTER TABLE ma_table 
MODIFY colonne VARCHAR(255) 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;  -- Puis en utf8mb4
```

> [!tip] Tester avant de migrer
> 
> ```sql
> -- Créer une table de test
> CREATE TABLE test_migration LIKE table_originale;
> INSERT INTO test_migration SELECT * FROM table_originale LIMIT 100;
> 
> -- Tester la conversion
> ALTER TABLE test_migration 
> CONVERT TO CHARACTER SET utf8mb4 
> COLLATE utf8mb4_unicode_ci;
> 
> -- Vérifier les données
> SELECT * FROM test_migration WHERE colonne LIKE '%é%';
> ```

### 📱 Configuration pour les connexions client

Les clients doivent aussi utiliser le bon charset pour communiquer avec le serveur :

```ini
# Dans my.cnf, section [client]
[client]
default-character-set = utf8mb4

# Dans my.cnf, section [mysql]
[mysql]
default-character-set = utf8mb4
```

**En PHP (PDO) :**

```php
// Méthode 1 : Dans le DSN
$pdo = new PDO(
    'mysql:host=localhost;dbname=ma_base;charset=utf8mb4',
    'user',
    'password'
);

// Méthode 2 : Après connexion
$pdo = new PDO('mysql:host=localhost;dbname=ma_base', 'user', 'password');
$pdo->exec("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");
```

**En Python (mysql-connector) :**

```python
import mysql.connector

conn = mysql.connector.connect(
    host='localhost',
    database='ma_base',
    user='user',
    password='password',
    charset='utf8mb4',
    collation='utf8mb4_unicode_ci'
)
```

**En ligne de commande :**

```bash
# Spécifier le charset à la connexion
mysql --default-character-set=utf8mb4 -u root -p

# Ou après connexion
mysql> SET NAMES utf8mb4;
mysql> SET CHARACTER SET utf8mb4;
```

### 🔬 Variables système liées aux character sets

```sql
-- Voir toutes les variables de charset
SHOW VARIABLES LIKE 'character_set%';

-- Variables importantes :
-- character_set_client     : Charset des requêtes envoyées par le client
-- character_set_connection : Charset pour la communication
-- character_set_results    : Charset des résultats renvoyés au client
-- character_set_database   : Charset par défaut de la base actuelle
-- character_set_server     : Charset par défaut du serveur
-- character_set_system     : Charset du système (toujours utf8)

-- Modifier temporairement (session)
SET NAMES utf8mb4;
-- Équivalent à :
SET character_set_client = utf8mb4;
SET character_set_results = utf8mb4;
SET character_set_connection = utf8mb4;
```

### 🎓 Bonnes pratiques récapitulatives

> [!tip] Règles d'or pour les character sets et collations
> 
> 1. **TOUJOURS utiliser utf8mb4**, jamais `utf8` ou `latin1`
> 2. **Configuration serveur** : Définir `utf8mb4_unicode_ci` dans `my.cnf`
> 3. **Bases de données** : Créer systématiquement avec `CHARACTER SET utf8mb4`
> 4. **Tables existantes** : Planifier une migration progressive vers `utf8mb4`
> 5. **Clients** : Configurer `SET NAMES utf8mb4` ou équivalent
> 6. **Collations** :
>     - Général : `utf8mb4_unicode_ci` ou `utf8mb4_0900_ai_ci` (MySQL 8.0+)
>     - Données sensibles (codes, passwords) : `utf8mb4_bin`
>     - Jamais de `utf8mb4_general_ci` (obsolète et moins précis)
> 7. **Tests** : Toujours tester avec des caractères spéciaux (é, ñ, 中, 😀)
> 8. **Backups** : Spécifier `--default-character-set=utf8mb4` dans mysqldump

### 📊 Tableau décisionnel : Quelle collation choisir ?

|Besoin|Collation recommandée|Raison|
|---|---|---|
|Site web multilingue|`utf8mb4_unicode_ci`|Support correct de toutes les langues|
|Application moderne (MySQL 8.0+)|`utf8mb4_0900_ai_ci`|Meilleure conformité Unicode|
|Codes produits, identifiants|`utf8mb4_bin`|Comparaison stricte (AB123 ≠ ab123)|
|Mots de passe hashés|`utf8mb4_bin`|Comparaison binaire exacte|
|Adresses email|`utf8mb4_general_ci`|Performance, casse insensible|
|Noms de personnes|`utf8mb4_unicode_ci`|Gestion correcte des accents|
|Données JSON|`utf8mb4_bin`|Préservation exacte du format|
|Maximum de performance|`utf8mb4_general_ci`|Plus rapide (mais moins précis)|

### 🧪 Script de validation de la configuration

```sql
-- Script complet de validation de la configuration charset/collation
-- À exécuter pour auditer votre configuration

-- 1. Configuration du serveur
SELECT 
    'Configuration Serveur' AS Section,
    @@character_set_server AS charset_serveur,
    @@collation_server AS collation_serveur;

-- 2. Liste des bases avec leur charset
SELECT 
    'Bases de données' AS Section,
    SCHEMA_NAME AS base,
    DEFAULT_CHARACTER_SET_NAME AS charset,
    DEFAULT_COLLATION_NAME AS collation
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys');

-- 3. Tables qui ne sont PAS en utf8mb4
SELECT 
    'Tables non-UTF8MB4' AS Section,
    TABLE_SCHEMA AS base,
    TABLE_NAME AS table_name,
    TABLE_COLLATION AS collation
FROM information_schema.TABLES
WHERE TABLE_SCHEMA NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
  AND TABLE_COLLATION NOT LIKE 'utf8mb4%'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- 4. Colonnes qui ne sont PAS en utf8mb4
SELECT 
    'Colonnes non-UTF8MB4' AS Section,
    TABLE_SCHEMA AS base,
    TABLE_NAME AS table_name,
    COLUMN_NAME AS colonne,
    CHARACTER_SET_NAME AS charset,
    COLLATION_NAME AS collation
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
  AND CHARACTER_SET_NAME IS NOT NULL
  AND CHARACTER_SET_NAME != 'utf8mb4'
ORDER BY TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME;
```

---

## 🎯 Synthèse de la configuration de base

### Configuration recommandée dans my.cnf

```ini
# ========================================
# CONFIGURATION DE BASE MYSQL/MARIADB
# my.cnf (Linux) / my.ini (Windows)
# ========================================

[mysqld]
# === IDENTITÉ ET LOCALISATION ===
user = mysql
datadir = /var/lib/mysql
socket = /var/run/mysqld/mysqld.sock
pid-file = /var/run/mysqld/mysqld.pid

# === RÉSEAU ===
# Port d'écoute standard
port = 3306

# Sécurité : écoute uniquement en local
# Pour accès réseau : utiliser 0.0.0.0 avec pare-feu
bind-address = 127.0.0.1

# === ENCODAGE (UTF-8 COMPLET) ===
# Character set par défaut (avec support emojis)
character-set-server = utf8mb4

# Collation par défaut
# utf8mb4_unicode_ci : recommandé pour MySQL 5.7 et inférieur
# utf8mb4_0900_ai_ci : recommandé pour MySQL 8.0+
collation-server = utf8mb4_unicode_ci

# === LOGS (pour information) ===
log_error = /var/log/mysql/error.log

[client]
# Charset par défaut pour les clients
default-character-set = utf8mb4
port = 3306
socket = /var/run/mysqld/mysqld.sock

[mysql]
# Charset pour le client mysql en ligne de commande
default-character-set = utf8mb4
```

### Checklist de vérification post-configuration

> [!example] Vérifications à effectuer après modification de my.cnf
> 
> ```bash
> # 1. Vérifier la syntaxe du fichier
> mysqld --validate-config
> 
> # 2. Redémarrer MySQL
> sudo systemctl restart mysql
> 
> # 3. Vérifier que MySQL a démarré
> sudo systemctl status mysql
> 
> # 4. Se connecter et vérifier les paramètres
> mysql -u root -p
> ```
> 
> ```sql
> -- Dans MySQL :
> -- Vérifier le port et bind-address
> SHOW VARIABLES LIKE 'port';
> SHOW VARIABLES LIKE 'bind_address';
> 
> -- Vérifier les charsets
> SHOW VARIABLES LIKE 'character_set_server';
> SHOW VARIABLES LIKE 'collation_server';
> 
> -- Tester avec un emoji
> SELECT '👍 Configuration OK!' AS test_emoji;
> ```
> 
> ```bash
> # 5. Vérifier l'écoute réseau (en dehors de MySQL)
> sudo ss -tlnp | grep 3306
> # Attendu : 127.0.0.1:3306 si bind-address = 127.0.0.1
> #           0.0.0.0:3306 si bind-address = 0.0.0.0
> 
> # 6. Tester la connexion
> mysql -h 127.0.0.1 -P 3306 -u root -p
> ```

### 🔑 Points clés à retenir

|Paramètre|Valeur production|Valeur développement|Impact|
|---|---|---|---|
|**port**|`3306` (standard)|`3306` ou personnalisé|Connexion réseau|
|**bind-address**|`127.0.0.1` (si mono-serveur) ou `0.0.0.0` (si distribué)|`127.0.0.1`|Sécurité critique|
|**character-set-server**|`utf8mb4`|`utf8mb4`|Support Unicode complet|
|**collation-server**|`utf8mb4_unicode_ci` ou `utf8mb4_0900_ai_ci`|`utf8mb4_unicode_ci`|Tri et comparaisons|

> [!warning] Erreurs fatales à éviter
> 
> ❌ **Ne JAMAIS faire :**
> 
> - Utiliser `utf8` au lieu de `utf8mb4` (emojis cassés)
> - Laisser `bind-address = 0.0.0.0` sans pare-feu (faille de sécurité)
> - Oublier de redémarrer MySQL après modification de `my.cnf`
> - Modifier la configuration en production sans test préalable
> - Changer le charset d'une base en production sans backup
> 
> ✅ **Toujours faire :**
> 
> - Backup avant toute modification de configuration
> - Tester les modifications sur un environnement de dev
> - Documenter chaque changement dans `my.cnf` avec des commentaires
> - Valider la syntaxe avec `mysqld --validate-config`
> - Vérifier les logs après redémarrage

---

## 📝 Résumé exécutif

### Ce que vous devez maîtriser

1. **Fichier my.cnf / my.ini**
    
    - Localisation selon l'OS
    - Structure en sections `[mysqld]`, `[client]`, `[mysql]`
    - Syntaxe des paramètres
    - Redémarrage obligatoire après modification
2. **Port d'écoute**
    
    - Port standard : 3306
    - Changement pour sécurité ou multi-instances
    - Configuration pare-feu nécessaire si exposition réseau
3. **Bind-address**
    
    - `127.0.0.1` : local uniquement (SÉCURISÉ)
    - `0.0.0.0` : réseau complet (NÉCESSITE SÉCURISATION)
    - IP spécifique : isolation réseau
    - Impact majeur sur la sécurité
4. **Character set et collation**
    
    - **Obligatoire** : `utf8mb4` (pas `utf8` !)
    - Collation : `utf8mb4_unicode_ci` (général) ou `utf8mb4_bin` (strict)
    - Configuration à tous les niveaux : serveur → base → table → colonne
    - Migration délicate, nécessite backups

### Configuration minimale sécurisée

```ini
[mysqld]
port = 3306
bind-address = 127.0.0.1
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[client]
default-character-set = utf8mb4
```

**Cette configuration est un excellent point de départ** pour un serveur LAMP standard où Apache/Nginx et MySQL sont sur la même machine. Elle privilégie la sécurité (bind-address local) et la compatibilité Unicode complète (utf8mb4).

---

_Cours rédigé pour une architecture serveur LAMP - Configuration de base MySQL/MariaDB_