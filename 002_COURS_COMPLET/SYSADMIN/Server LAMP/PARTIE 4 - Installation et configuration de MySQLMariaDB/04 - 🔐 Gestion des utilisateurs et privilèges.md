

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

La gestion des utilisateurs et privilèges dans MySQL/MariaDB est cruciale pour la sécurité de votre serveur LAMP. Elle permet de contrôler finement qui peut accéder à quelles données et effectuer quelles opérations.

> [!info] Pourquoi est-ce important ?
> 
> - **Sécurité** : Limiter les accès uniquement à ce qui est nécessaire (principe du moindre privilège)
> - **Isolation** : Séparer les droits entre applications et utilisateurs
> - **Traçabilité** : Identifier qui fait quoi sur le serveur
> - **Protection** : Éviter qu'une application compromise n'affecte toute la base de données

---

## 👤 Création d'utilisateurs

### Syntaxe de base

```sql
CREATE USER 'nom_utilisateur'@'hôte' IDENTIFIED BY 'mot_de_passe';
```

> [!example] Exemples pratiques
> 
> ```sql
> -- Utilisateur accessible uniquement depuis le serveur local
> CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'MotDePasseSecurise123!';
> 
> -- Utilisateur accessible depuis n'importe où
> CREATE USER 'admin'@'%' IDENTIFIED BY 'SuperMotDePasse456!';
> 
> -- Utilisateur accessible depuis une IP spécifique
> CREATE USER 'backup_user'@'192.168.1.100' IDENTIFIED BY 'BackupPass789!';
> 
> -- Utilisateur accessible depuis un sous-réseau
> CREATE USER 'dev_user'@'192.168.1.%' IDENTIFIED BY 'DevPass000!';
> ```

### Anatomie d'un utilisateur MySQL

Un utilisateur MySQL est composé de **deux parties** :

|Composant|Description|Exemple|
|---|---|---|
|**Nom**|Identifiant de l'utilisateur|`'app_user'`|
|**Hôte**|Origine autorisée de la connexion|`'localhost'`, `'%'`, `'192.168.1.%'`|

> [!warning] Attention `'user'@'localhost'` et `'user'@'%'` sont **deux utilisateurs différents** ! MySQL les traite comme des comptes séparés.

### Vérifier les utilisateurs existants

```sql
-- Lister tous les utilisateurs
SELECT User, Host FROM mysql.user;

-- Voir les détails d'un utilisateur spécifique
SELECT * FROM mysql.user WHERE User = 'app_user'\G
```

> [!tip] Astuce La commande `\G` à la fin affiche les résultats verticalement, ce qui est plus lisible pour les requêtes avec beaucoup de colonnes.

---

## ✅ Attribution de privilèges (GRANT)

### Syntaxe générale

```sql
GRANT privileges ON base.table TO 'utilisateur'@'hôte';
```

### Types de privilèges

#### Privilèges de base de données

|Privilège|Description|Usage typique|
|---|---|---|
|`SELECT`|Lire les données|Application en lecture seule|
|`INSERT`|Insérer des données|Application nécessitant d'ajouter des données|
|`UPDATE`|Modifier des données|Application modifiant des enregistrements|
|`DELETE`|Supprimer des données|Application gérant des suppressions|
|`CREATE`|Créer tables/bases|Scripts d'installation|
|`DROP`|Supprimer tables/bases|Administrateur uniquement|
|`ALTER`|Modifier structure tables|Migrations de schéma|
|`INDEX`|Créer/supprimer index|Optimisation de base|

#### Privilèges administratifs

|Privilège|Description|⚠️ Risque|
|---|---|---|
|`ALL PRIVILEGES`|Tous les droits|Élevé|
|`GRANT OPTION`|Donner ses privilèges à d'autres|Élevé|
|`SUPER`|Opérations administratives|Très élevé|
|`RELOAD`|Recharger les configurations|Moyen|
|`PROCESS`|Voir tous les processus|Moyen|

### Exemples d'attribution

```sql
-- Droits complets sur une base spécifique
GRANT ALL PRIVILEGES ON ma_base.* TO 'app_user'@'localhost';

-- Droits en lecture seule sur toutes les tables d'une base
GRANT SELECT ON ma_base.* TO 'lecteur'@'localhost';

-- Droits SELECT et INSERT sur une table spécifique
GRANT SELECT, INSERT ON ma_base.utilisateurs TO 'app_user'@'localhost';

-- Droits sur toutes les bases (à éviter en production)
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';

-- Droits avec possibilité de les transmettre
GRANT SELECT ON ma_base.* TO 'manager'@'localhost' WITH GRANT OPTION;
```

> [!example] Cas d'usage : Application WordPress
> 
> ```sql
> -- Créer l'utilisateur WordPress
> CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_password_2024!';
> 
> -- Donner les droits nécessaires
> GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX 
> ON wordpress_db.* TO 'wp_user'@'localhost';
> 
> -- Appliquer les changements
> FLUSH PRIVILEGES;
> ```

> [!tip] Privilèges minimaux pour une application web Pour la plupart des applications web, ces privilèges suffisent :
> 
> ```sql
> GRANT SELECT, INSERT, UPDATE, DELETE ON ma_base.* TO 'app_user'@'localhost';
> ```

### Vérifier les privilèges d'un utilisateur

```sql
-- Voir les privilèges d'un utilisateur
SHOW GRANTS FOR 'app_user'@'localhost';

-- Voir ses propres privilèges
SHOW GRANTS;
SHOW GRANTS FOR CURRENT_USER;
```

---

## ❌ Retrait de privilèges (REVOKE)

### Syntaxe générale

```sql
REVOKE privilèges ON base.table FROM 'utilisateur'@'hôte';
```

### Exemples de retrait

```sql
-- Retirer un privilège spécifique
REVOKE DELETE ON ma_base.* FROM 'app_user'@'localhost';

-- Retirer plusieurs privilèges
REVOKE INSERT, UPDATE ON ma_base.clients FROM 'app_user'@'localhost';

-- Retirer tous les privilèges
REVOKE ALL PRIVILEGES ON ma_base.* FROM 'app_user'@'localhost';

-- Retirer le droit de donner des privilèges
REVOKE GRANT OPTION ON ma_base.* FROM 'manager'@'localhost';

-- Retirer tous les privilèges sur toutes les bases
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'user'@'localhost';
```

> [!warning] Important `REVOKE` ne supprime pas l'utilisateur, il retire seulement ses privilèges. Pour supprimer complètement un utilisateur :
> 
> ```sql
> DROP USER 'nom_utilisateur'@'hôte';
> ```

### Scénario pratique : Révoquer un accès développeur

```sql
-- Un développeur quitte l'entreprise
-- 1. Voir ce qu'il avait comme accès
SHOW GRANTS FOR 'dev_jean'@'%';

-- 2. Retirer tous ses privilèges
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'dev_jean'@'%';

-- 3. Supprimer le compte
DROP USER 'dev_jean'@'%';

-- 4. Appliquer les changements
FLUSH PRIVILEGES;
```

---

## 🌐 Limitation par hôte

### Comprendre les patterns d'hôtes

La partie hôte détermine **d'où** l'utilisateur peut se connecter. C'est un mécanisme de sécurité essentiel.

|Pattern|Signification|Exemple d'utilisation|
|---|---|---|
|`'localhost'`|Connexions locales uniquement (socket Unix)|Applications sur le même serveur|
|`'127.0.0.1'`|Connexions TCP/IP locales|Applications utilisant TCP explicitement|
|`'%'`|N'importe quelle origine|⚠️ À éviter en production|
|`'192.168.1.50'`|IP spécifique|Serveur applicatif dédié|
|`'192.168.1.%'`|Plage d'IPs (subnet)|Réseau interne d'entreprise|
|`'%.exemple.com'`|Domaine et sous-domaines|Infrastructure avec DNS|

> [!info] Différence localhost vs 127.0.0.1
> 
> - `localhost` : Utilise les sockets Unix (plus rapide, pas de TCP)
> - `127.0.0.1` : Utilise TCP/IP (nécessaire pour certaines applications)
> 
> Sur un serveur LAMP typique, préférez `localhost` pour les performances.

### Exemples de configurations sécurisées

```sql
-- Configuration production : Application web sur le même serveur
CREATE USER 'app_prod'@'localhost' IDENTIFIED BY 'ProdPass2024!';
GRANT SELECT, INSERT, UPDATE, DELETE ON prod_db.* TO 'app_prod'@'localhost';

-- Configuration production : Application sur serveur séparé
CREATE USER 'app_prod'@'192.168.10.50' IDENTIFIED BY 'ProdPass2024!';
GRANT SELECT, INSERT, UPDATE, DELETE ON prod_db.* TO 'app_prod'@'192.168.10.50';

-- Accès administrateur : Seulement depuis le réseau interne
CREATE USER 'dba'@'192.168.1.%' IDENTIFIED BY 'DbaPass2024!';
GRANT ALL PRIVILEGES ON *.* TO 'dba'@'192.168.1.%';

-- Backup automatique : IP fixe du serveur de backup
CREATE USER 'backup'@'192.168.1.100' IDENTIFIED BY 'BackupPass2024!';
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON *.* TO 'backup'@'192.168.1.100';
```

> [!warning] Piège courant : Le wildcard '%'
> 
> ```sql
> -- ❌ DANGEREUX : Accessible depuis internet entier
> CREATE USER 'admin'@'%' IDENTIFIED BY 'password';
> 
> -- ✅ SÉCURISÉ : Limité au réseau local
> CREATE USER 'admin'@'192.168.1.%' IDENTIFIED BY 'StrongPassword123!';
> ```

### Ordre de priorité des hôtes

MySQL évalue les règles d'hôtes du **plus spécifique au plus général** :

```sql
-- Ordre de priorité (du plus prioritaire au moins prioritaire) :
1. 'user'@'192.168.1.50'      -- IP exacte
2. 'user'@'192.168.1.%'       -- Plage IP
3. 'user'@'%.exemple.com'     -- Domaine
4. 'user'@'%'                 -- Wildcard
```

> [!example] Exemple de résolution
> 
> ```sql
> -- Si ces deux utilisateurs existent :
> CREATE USER 'app'@'localhost' IDENTIFIED BY 'pass1';
> CREATE USER 'app'@'%' IDENTIFIED BY 'pass2';
> 
> -- Une connexion depuis localhost utilisera 'app'@'localhost'
> -- Une connexion depuis ailleurs utilisera 'app'@'%'
> ```

---

## 🔄 Flush privileges

### Qu'est-ce que FLUSH PRIVILEGES ?

`FLUSH PRIVILEGES` demande à MySQL de **recharger les tables de privilèges** depuis la base `mysql` en mémoire.

```sql
FLUSH PRIVILEGES;
```

### Quand est-ce NÉCESSAIRE ?

|Action|FLUSH requis ?|Raison|
|---|---|---|
|`CREATE USER`|❌ Non|Prend effet immédiatement|
|`DROP USER`|❌ Non|Prend effet immédiatement|
|`GRANT`|❌ Non|Prend effet immédiatement|
|`REVOKE`|❌ Non|Prend effet immédiatement|
|Modification directe de `mysql.user`|✅ **OUI**|Tables modifiées manuellement|
|`INSERT INTO mysql.user`|✅ **OUI**|Contournement des commandes SQL|
|`UPDATE mysql.user`|✅ **OUI**|Modification directe|

> [!info] Clarification importante Contrairement à une idée reçue, `FLUSH PRIVILEGES` n'est **pas nécessaire** après `GRANT`, `REVOKE`, `CREATE USER` ou `DROP USER`. Ces commandes rechargent automatiquement les privilèges.
> 
> Il n'est requis que si vous modifiez **directement** les tables système avec `INSERT`, `UPDATE` ou `DELETE`.

### Quand l'utiliser quand même ?

```sql
-- Par sécurité après plusieurs modifications
CREATE USER 'user1'@'localhost' IDENTIFIED BY 'pass1';
GRANT SELECT ON db1.* TO 'user1'@'localhost';
CREATE USER 'user2'@'localhost' IDENTIFIED BY 'pass2';
GRANT INSERT ON db2.* TO 'user2'@'localhost';
FLUSH PRIVILEGES;  -- Par précaution, pour être certain

-- Après modification directe (à éviter !)
UPDATE mysql.user SET Password=PASSWORD('newpass') WHERE User='root';
FLUSH PRIVILEGES;  -- OBLIGATOIRE ici
```

> [!tip] Bonne pratique Prenez l'habitude d'utiliser `FLUSH PRIVILEGES` après un lot de modifications administratives, même si techniquement ce n'est pas requis. C'est une sécurité supplémentaire qui ne coûte rien.

### Autres types de FLUSH

```sql
-- Recharger tous les caches
FLUSH TABLES;

-- Recharger les logs
FLUSH LOGS;

-- Recharger les tables de privilèges (équivalent à FLUSH PRIVILEGES)
FLUSH USER_RESOURCES;
```

---

## 🛡️ Bonnes pratiques

### Principe du moindre privilège

> [!tip] Règle d'or Donnez **uniquement** les privilèges nécessaires au fonctionnement de l'application, rien de plus.

```sql
-- ❌ MAUVAIS : Trop de privilèges
GRANT ALL PRIVILEGES ON *.* TO 'app_user'@'localhost';

-- ✅ BON : Privilèges minimaux
GRANT SELECT, INSERT, UPDATE, DELETE ON app_db.* TO 'app_user'@'localhost';

-- ✅ ENCORE MIEUX : Privilèges par table si possible
GRANT SELECT, INSERT ON app_db.users TO 'app_user'@'localhost';
GRANT SELECT ON app_db.config TO 'app_user'@'localhost';
```

### Gestion des mots de passe

> [!warning] Sécurité des mots de passe
> 
> - **Longueur minimale** : 16 caractères
> - **Complexité** : Majuscules, minuscules, chiffres, caractères spéciaux
> - **Unicité** : Un mot de passe différent par utilisateur
> - **Rotation** : Changer régulièrement les mots de passe critiques

```sql
-- Créer avec un mot de passe fort
CREATE USER 'app'@'localhost' IDENTIFIED BY 'Xk9$mP2#vL8@qR5!nT7';

-- Changer un mot de passe
ALTER USER 'app'@'localhost' IDENTIFIED BY 'NouveauMotDePasse2024!';

-- Forcer l'expiration du mot de passe (optionnel)
ALTER USER 'app'@'localhost' PASSWORD EXPIRE;
```

### Séparation des utilisateurs par application

```sql
-- Application WordPress
CREATE USER 'wp_blog'@'localhost' IDENTIFIED BY 'WpPass2024!';
GRANT SELECT, INSERT, UPDATE, DELETE ON wordpress.* TO 'wp_blog'@'localhost';

-- Application de gestion
CREATE USER 'gestion_app'@'localhost' IDENTIFIED BY 'GestionPass2024!';
GRANT SELECT, INSERT, UPDATE, DELETE ON gestion.* TO 'gestion_app'@'localhost';

-- Utilisateur de backup
CREATE USER 'backup_user'@'localhost' IDENTIFIED BY 'BackupPass2024!';
GRANT SELECT, LOCK TABLES, SHOW VIEW ON *.* TO 'backup_user'@'localhost';
```

### Limitation réseau stricte

```sql
-- ❌ DANGEREUX : Accès depuis partout
CREATE USER 'admin'@'%' IDENTIFIED BY 'password';

-- ✅ SÉCURISÉ : Accès limité
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'StrongPassword123!';

-- ✅ ACCEPTABLE : Réseau interne uniquement
CREATE USER 'admin'@'192.168.1.%' IDENTIFIED BY 'StrongPassword123!';
```

### Audit régulier

```sql
-- Lister tous les utilisateurs et leurs origines
SELECT User, Host FROM mysql.user ORDER BY User, Host;

-- Voir les utilisateurs avec accès depuis partout (potentiellement dangereux)
SELECT User, Host FROM mysql.user WHERE Host = '%';

-- Voir les comptes sans mot de passe (très dangereux !)
SELECT User, Host FROM mysql.user WHERE authentication_string = '';

-- Voir les utilisateurs avec privilège SUPER
SELECT User, Host, Super_priv FROM mysql.user WHERE Super_priv = 'Y';
```

### Script de création d'utilisateur sécurisé

```sql
-- Template complet pour créer un utilisateur d'application
-- 1. Créer l'utilisateur avec un mot de passe fort
CREATE USER 'nom_app'@'localhost' IDENTIFIED BY 'MotDePasseComplexe2024!';

-- 2. Donner uniquement les privilèges nécessaires
GRANT SELECT, INSERT, UPDATE, DELETE ON base_app.* TO 'nom_app'@'localhost';

-- 3. Vérifier les privilèges accordés
SHOW GRANTS FOR 'nom_app'@'localhost';

-- 4. Appliquer les changements (par précaution)
FLUSH PRIVILEGES;

-- 5. Tester la connexion (depuis le terminal)
-- mysql -u nom_app -p base_app
```

### Checklist de sécurité

> [!warning] Points de vérification essentiels
> 
> - [ ] Aucun utilisateur avec `'%'` en production
> - [ ] Pas de compte sans mot de passe
> - [ ] L'utilisateur `root` accessible uniquement depuis `localhost`
> - [ ] Pas de privilège `ALL PRIVILEGES` sauf pour root
> - [ ] Suppression des utilisateurs anonymes
> - [ ] Mots de passe conformes à la politique de sécurité
> - [ ] Un utilisateur par application
> - [ ] Privilèges limités au strict nécessaire

```sql
-- Vérification rapide de sécurité
-- Supprimer les utilisateurs anonymes
DELETE FROM mysql.user WHERE User = '';

-- Supprimer les bases de test
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db = 'test' OR Db = 'test\\_%';

-- Appliquer
FLUSH PRIVILEGES;
```

---

> [!tip] Mémo rapide
> 
> ```sql
> -- Créer
> CREATE USER 'user'@'host' IDENTIFIED BY 'pass';
> 
> -- Donner des droits
> GRANT privileges ON db.table TO 'user'@'host';
> 
> -- Retirer des droits
> REVOKE privileges ON db.table FROM 'user'@'host';
> 
> -- Voir les droits
> SHOW GRANTS FOR 'user'@'host';
> 
> -- Supprimer
> DROP USER 'user'@'host';
> 
> -- Appliquer (si modification directe)
> FLUSH PRIVILEGES;
> ```