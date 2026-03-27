

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

## 🔌 Connexion au serveur MySQL

### Pourquoi se connecter ?

La connexion au serveur MySQL/MariaDB est le point d'entrée obligatoire pour interagir avec vos bases de données. Sans connexion authentifiée, aucune opération n'est possible.

### Syntaxe de connexion de base

```bash
mysql -u nom_utilisateur -p
```

**Décomposition de la commande :**

- `mysql` : commande client pour se connecter au serveur
- `-u nom_utilisateur` : spécifie le nom d'utilisateur (ex: `root`, `admin`, `dev_user`)
- `-p` : demande le mot de passe de manière sécurisée (sera masqué lors de la saisie)

> [!example] Exemple de connexion
> 
> ```bash
> mysql -u root -p
> ```
> 
> Après avoir pressé Entrée, le système vous demandera :
> 
> ```
> Enter password: 
> ```
> 
> Tapez votre mot de passe (invisible) puis validez.

### Options de connexion avancées

```bash
# Connexion avec spécification de l'hôte
mysql -h localhost -u root -p

# Connexion avec spécification du port
mysql -h localhost -P 3306 -u root -p

# Connexion directe à une base de données
mysql -u root -p nom_database

# Connexion avec mot de passe en ligne (NON RECOMMANDÉ)
mysql -u root -pMotDePasse
```

> [!warning] Sécurité du mot de passe **Ne jamais utiliser** `-pMotDePasse` (mot de passe collé à l'option) en production :
> 
> - Le mot de passe apparaît dans l'historique des commandes
> - Il est visible dans la liste des processus (`ps aux`)
> - Risque de compromission élevé
> 
> Utilisez toujours `-p` seul pour une saisie sécurisée.

### Paramètres de connexion courants

|Option|Description|Exemple|
|---|---|---|
|`-h` ou `--host`|Adresse du serveur MySQL|`-h 192.168.1.100`|
|`-P` ou `--port`|Port du serveur (défaut: 3306)|`-P 3307`|
|`-u` ou `--user`|Nom d'utilisateur|`-u admin`|
|`-p` ou `--password`|Demande le mot de passe|`-p`|
|`-D` ou `--database`|Base de données à utiliser|`-D ma_base`|

### Vérification de la connexion réussie

Une fois connecté, vous verrez l'invite MySQL :

```
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 42
Server version: 10.5.12-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
```

> [!tip] Astuce de productivité Pour se déconnecter proprement :
> 
> ```sql
> EXIT;
> -- ou simplement
> \q
> -- ou encore
> quit
> ```

### Pièges courants

1. **Erreur d'authentification** : Vérifiez nom d'utilisateur et mot de passe
    
    ```
    ERROR 1045 (28000): Access denied for user 'root'@'localhost'
    ```
    
2. **Serveur non démarré** : Démarrez MySQL/MariaDB avant connexion
    
    ```
    ERROR 2002 (HY000): Can't connect to local MySQL server through socket
    ```
    
3. **Port incorrect** : Vérifiez que vous utilisez le bon port (3306 par défaut)
    

---

## 🔨 Création de bases de données

### Pourquoi créer une base de données ?

Chaque projet, application ou service doit avoir sa propre base de données isolée pour :

- Organiser logiquement les données
- Gérer les permissions indépendamment
- Faciliter les sauvegardes et restaurations
- Éviter les conflits de nommage

### Syntaxe de création basique

```sql
CREATE DATABASE nom_database;
```

> [!example] Création simple
> 
> ```sql
> CREATE DATABASE mon_site_web;
> ```
> 
> Réponse du serveur :
> 
> ```
> Query OK, 1 row affected (0.01 sec)
> ```

### Création avec options complètes

```sql
CREATE DATABASE nom_database
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
```

**Explication des options :**

- `CHARACTER SET utf8mb4` : jeu de caractères complet supportant les emojis et caractères spéciaux
- `COLLATE utf8mb4_unicode_ci` : règles de comparaison insensibles à la casse

> [!info] Pourquoi utf8mb4 ?
> 
> - `utf8` en MySQL ne supporte que 3 octets (incomplet)
> - `utf8mb4` supporte 4 octets (UTF-8 complet)
> - Essentiel pour les emojis, certains caractères asiatiques, etc.
> - **Toujours privilégier utf8mb4** pour les nouvelles bases

### Création conditionnelle

```sql
CREATE DATABASE IF NOT EXISTS nom_database;
```

Cette syntaxe évite une erreur si la base existe déjà :

- **Sans `IF NOT EXISTS`** : erreur si la base existe
- **Avec `IF NOT EXISTS`** : aucune erreur, la base existante est conservée

> [!example] Utilisation dans les scripts
> 
> ```sql
> -- Idéal pour les scripts d'installation automatisés
> CREATE DATABASE IF NOT EXISTS e_commerce
>     CHARACTER SET utf8mb4
>     COLLATE utf8mb4_unicode_ci;
> ```

### Bonnes pratiques de nommage

|✅ Recommandé|❌ À éviter|Raison|
|---|---|---|
|`mon_site_web`|`Mon Site Web`|Éviter les espaces|
|`ecommerce_prod`|`e-commerce`|Éviter les tirets|
|`app_v2`|`2ndApp`|Ne pas commencer par un chiffre|
|`blog_utilisateurs`|`tès_àccénts`|Éviter les accents|

> [!tip] Convention de nommage
> 
> - **Minuscules uniquement** : évite les problèmes de casse entre systèmes
> - **Underscores** pour séparer les mots : `ma_base_donnees`
> - **Noms descriptifs** : `blog_entreprise` plutôt que `db1`
> - **Préfixes** pour l'environnement : `prod_ecommerce`, `dev_ecommerce`

### Vérification de la création

Après création, sélectionnez la base pour l'utiliser :

```sql
USE nom_database;
```

Réponse :

```
Database changed
```

### Pièges courants

1. **Base déjà existante** sans `IF NOT EXISTS`
    
    ```
    ERROR 1007 (HY000): Can't create database 'test'; database exists
    ```
    
2. **Caractères interdits** dans le nom
    
    ```
    ERROR 1064 (42000): You have an error in your SQL syntax
    ```
    
3. **Oubli du point-virgule** : la commande n'est pas exécutée
    
    ```sql
    CREATE DATABASE test
    -- Attente de la suite...
    ```
    

---

## 🗑️ Suppression de bases de données

### Pourquoi supprimer une base ?

La suppression est nécessaire pour :

- Nettoyer les environnements de test
- Supprimer des projets abandonnés
- Libérer de l'espace disque
- Réinitialiser une application

> [!warning] Opération irréversible **ATTENTION** : La suppression d'une base de données est **définitive** et **immédiate**.
> 
> - Toutes les tables sont supprimées
> - Toutes les données sont perdues
> - Aucun "undo" n'est possible
> - **Faites TOUJOURS une sauvegarde avant**

### Syntaxe de suppression basique

```sql
DROP DATABASE nom_database;
```

> [!example] Suppression simple
> 
> ```sql
> DROP DATABASE ancienne_base;
> ```
> 
> Réponse :
> 
> ```
> Query OK, 0 rows affected (0.05 sec)
> ```

### Suppression conditionnelle

```sql
DROP DATABASE IF EXISTS nom_database;
```

**Différence importante :**

- **Sans `IF EXISTS`** : erreur si la base n'existe pas
- **Avec `IF EXISTS`** : aucune erreur, opération silencieuse

> [!example] Utilisation dans les scripts
> 
> ```sql
> -- Nettoyer avant de recréer (pattern courant)
> DROP DATABASE IF EXISTS test_app;
> CREATE DATABASE test_app
>     CHARACTER SET utf8mb4
>     COLLATE utf8mb4_unicode_ci;
> ```

### Workflow de suppression sécurisé

```sql
-- 1. Vérifier que la base existe
SHOW DATABASES LIKE 'ma_base';

-- 2. Sauvegarder si nécessaire (depuis le terminal)
-- mysqldump -u root -p ma_base > backup_ma_base.sql

-- 3. Vérifier qu'aucune application ne l'utilise

-- 4. Supprimer
DROP DATABASE IF EXISTS ma_base;

-- 5. Vérifier la suppression
SHOW DATABASES;
```

> [!tip] Protection supplémentaire Avant de supprimer une base critique, vous pouvez temporairement renommer :
> 
> ```sql
> -- Renommer au lieu de supprimer directement
> RENAME DATABASE old_name TO old_name_archive;
> -- (Note: RENAME DATABASE n'existe plus depuis MySQL 5.1.23)
> -- Alternative: créer nouvelle base et migrer, puis supprimer
> ```

### Commande de sauvegarde avant suppression

```bash
# Depuis le terminal (pas dans MySQL)
# Sauvegarde complète
mysqldump -u root -p nom_database > backup_$(date +%Y%m%d).sql

# Sauvegarde compressée
mysqldump -u root -p nom_database | gzip > backup_$(date +%Y%m%d).sql.gz
```

### Droits nécessaires

Pour supprimer une base, l'utilisateur doit avoir le privilège `DROP` :

```sql
-- Vérifier les privilèges
SHOW GRANTS FOR CURRENT_USER;
```

### Pièges courants

1. **Base inexistante** sans `IF EXISTS`
    
    ```
    ERROR 1008 (HY000): Can't drop database 'test'; database doesn't exist
    ```
    
2. **Base actuellement utilisée**
    
    ```sql
    -- Erreur si vous êtes connecté à la base
    USE ma_base;
    DROP DATABASE ma_base;  -- Peut causer des problèmes
    
    -- Solution : se déconnecter de la base d'abord
    USE mysql;
    DROP DATABASE ma_base;
    ```
    
3. **Permissions insuffisantes**
    
    ```
    ERROR 1044 (42000): Access denied for user 'user'@'localhost' to database 'test'
    ```
    

> [!warning] Bases système à ne JAMAIS supprimer Ne supprimez **JAMAIS** ces bases critiques :
> 
> - `mysql` : contient les utilisateurs, privilèges et paramètres système
> - `information_schema` : métadonnées sur toutes les bases
> - `performance_schema` : données de performance
> - `sys` : vues simplifiées pour l'administration
> 
> Leur suppression **casserait complètement** votre serveur MySQL/MariaDB.

---

## 👁️ Affichage des bases existantes

### Pourquoi lister les bases ?

L'affichage des bases permet de :

- Vérifier l'existence d'une base avant création/suppression
- Explorer la structure du serveur
- Auditer les bases présentes
- Documenter l'infrastructure

### Commande principale

```sql
SHOW DATABASES;
```

> [!example] Résultat typique
> 
> ```sql
> SHOW DATABASES;
> ```
> 
> ```
> +--------------------+
> | Database           |
> +--------------------+
> | information_schema |
> | mysql              |
> | performance_schema |
> | sys                |
> | mon_site_web       |
> | e_commerce         |
> +--------------------+
> 6 rows in set (0.00 sec)
> ```

### Filtrage avec LIKE

```sql
-- Recherche par motif
SHOW DATABASES LIKE 'pattern';
```

**Wildcards disponibles :**

- `%` : remplace zéro, un ou plusieurs caractères
- `_` : remplace exactement un caractère

> [!example] Exemples de filtrage
> 
> ```sql
> -- Toutes les bases commençant par "test"
> SHOW DATABASES LIKE 'test%';
> 
> -- Toutes les bases contenant "prod"
> SHOW DATABASES LIKE '%prod%';
> 
> -- Bases avec exactement 4 caractères
> SHOW DATABASES LIKE '____';
> 
> -- Bases finissant par "_db"
> SHOW DATABASES LIKE '%_db';
> ```

### Affichage avec WHERE

Pour des critères plus complexes, utilisez `information_schema` :

```sql
SELECT SCHEMA_NAME 
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME LIKE 'prod_%';
```

> [!info] information_schema `information_schema` est une base de données virtuelle contenant les métadonnées :
> 
> - `SCHEMATA` : liste des bases de données
> - `TABLES` : liste des tables
> - `COLUMNS` : liste des colonnes
> - Très utile pour des requêtes complexes d'administration

### Affichage détaillé

```sql
-- Voir la base actuellement sélectionnée
SELECT DATABASE();

-- Statistiques sur les bases
SELECT 
    SCHEMA_NAME as 'Base de données',
    DEFAULT_CHARACTER_SET_NAME as 'Charset',
    DEFAULT_COLLATION_NAME as 'Collation'
FROM information_schema.SCHEMATA;
```

> [!example] Résultat détaillé
> 
> ```
> +--------------------+---------+--------------------+
> | Base de données    | Charset | Collation          |
> +--------------------+---------+--------------------+
> | information_schema | utf8    | utf8_general_ci    |
> | mon_site_web       | utf8mb4 | utf8mb4_unicode_ci |
> | mysql              | utf8mb4 | utf8mb4_0900_ai_ci |
> +--------------------+---------+--------------------+
> ```

### Compter les bases

```sql
-- Nombre total de bases
SELECT COUNT(*) as 'Nombre de bases' 
FROM information_schema.SCHEMATA;

-- Nombre de bases utilisateur (hors système)
SELECT COUNT(*) as 'Bases utilisateur'
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys');
```

### Taille des bases de données

```sql
SELECT 
    table_schema AS 'Base de données',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Taille (MB)'
FROM information_schema.TABLES
GROUP BY table_schema
ORDER BY SUM(data_length + index_length) DESC;
```

> [!tip] Monitoring de l'espace Cette requête est particulièrement utile pour :
> 
> - Identifier les bases volumineuses
> - Planifier les sauvegardes
> - Surveiller la croissance
> - Optimiser l'espace disque

### Affichage avec permissions

Les bases affichées dépendent des droits de l'utilisateur :

```sql
-- Un utilisateur voit uniquement les bases auxquelles il a accès
SHOW DATABASES;

-- L'administrateur (root) voit toutes les bases
```

> [!warning] Visibilité limitée Un utilisateur sans privilèges globaux ne verra que :
> 
> - Les bases où il a au moins un privilège
> - `information_schema` (toujours visible)
> 
> Il ne verra pas les autres bases, même si elles existent.

### Commandes alternatives

```sql
-- Équivalent alternatif (moins courant)
SHOW SCHEMAS;

-- Via mysqlshow (depuis le terminal)
mysqlshow -u root -p

-- Avec filtre depuis le terminal
mysqlshow -u root -p "test%"
```

### Bonnes pratiques d'exploration

```sql
-- 1. Lister toutes les bases
SHOW DATABASES;

-- 2. Sélectionner une base
USE nom_database;

-- 3. Vérifier la base active
SELECT DATABASE();

-- 4. Lister les tables de cette base
SHOW TABLES;

-- 5. Analyser la structure d'une table
DESCRIBE nom_table;
```

> [!tip] Astuce pour les scripts Vous pouvez utiliser `SHOW DATABASES` dans des scripts bash :
> 
> ```bash
> #!/bin/bash
> # Lister toutes les bases et les sauvegarder
> mysql -u root -p -e "SHOW DATABASES;" | tail -n +2 | while read db; do
>     if [ "$db" != "information_schema" ] && [ "$db" != "performance_schema" ]; then
>         mysqldump -u root -p "$db" > "${db}_backup.sql"
>     fi
> done
> ```

---

## 📊 Récapitulatif des commandes essentielles

|Opération|Commande|Usage|
|---|---|---|
|**Connexion**|`mysql -u root -p`|Se connecter au serveur|
|**Lister**|`SHOW DATABASES;`|Voir toutes les bases|
|**Filtrer**|`SHOW DATABASES LIKE 'test%';`|Rechercher des bases|
|**Créer**|`CREATE DATABASE nom;`|Créer une nouvelle base|
|**Créer (sûr)**|`CREATE DATABASE IF NOT EXISTS nom;`|Création conditionnelle|
|**Utiliser**|`USE nom;`|Sélectionner une base|
|**Supprimer**|`DROP DATABASE nom;`|Supprimer une base|
|**Supprimer (sûr)**|`DROP DATABASE IF EXISTS nom;`|Suppression conditionnelle|
|**Base active**|`SELECT DATABASE();`|Voir la base courante|
|**Déconnexion**|`EXIT;` ou `\q`|Quitter MySQL|

---

## 🎯 Points clés à retenir

> [!tip] Synthèse des bonnes pratiques
> 
> **Connexion :**
> 
> - Utilisez toujours `-p` seul pour la sécurité
> - Vérifiez le serveur et le port si erreur de connexion
> 
> **Création :**
> 
> - Privilégiez `utf8mb4` et `utf8mb4_unicode_ci`
> - Utilisez `IF NOT EXISTS` dans les scripts
> - Respectez les conventions de nommage
> 
> **Suppression :**
> 
> - **TOUJOURS** sauvegarder avant
> - Utilisez `IF EXISTS` pour éviter les erreurs
> - Ne supprimez jamais les bases système
> 
> **Exploration :**
> 
> - `SHOW DATABASES` pour lister
> - `LIKE` pour filtrer
> - `information_schema` pour les requêtes avancées