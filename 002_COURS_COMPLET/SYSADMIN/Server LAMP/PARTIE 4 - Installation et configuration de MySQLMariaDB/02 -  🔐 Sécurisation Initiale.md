

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

## 🎯 Introduction à la sécurisation

Après l'installation de MySQL/MariaDB, le serveur de base de données se trouve dans un état par défaut peu sécurisé. Cette configuration initiale est volontairement permissive pour faciliter les premiers tests, mais elle présente plusieurs vulnérabilités critiques qu'il est impératif de corriger avant toute utilisation en production.

> [!warning] Pourquoi sécuriser immédiatement ?
> 
> - **Utilisateurs anonymes** : Permettent des connexions sans authentification
> - **Root sans mot de passe** : L'utilisateur administrateur est accessible sans protection
> - **Accès distant au root** : Augmente la surface d'attaque
> - **Base de données de test** : Accessible publiquement par défaut
> - **Risque d'intrusion** : Un serveur non sécurisé peut être compromis en quelques minutes

### Quand effectuer la sécurisation ?

La sécurisation doit être effectuée **immédiatement après l'installation** de MySQL/MariaDB, avant même de créer vos premières bases de données ou applications. C'est la première étape obligatoire de toute configuration professionnelle.

---

## 🛠️ Le script mysql_secure_installation

### Présentation

`mysql_secure_installation` est un script shell interactif fourni avec MySQL et MariaDB qui automatise les tâches de sécurisation de base. Il vous guide pas à pas à travers les différentes étapes de durcissement de la configuration.

### Lancement du script

```bash
# Lancer le script de sécurisation
sudo mysql_secure_installation
```

> [!info] Pourquoi sudo ? Le script doit être exécuté avec les privilèges administrateur pour pouvoir modifier la configuration de MySQL/MariaDB et accéder aux tables système.

### Processus interactif

Le script pose une série de questions auxquelles vous devez répondre. Voici le déroulement typique :

```bash
# Exemple de session interactive
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MySQL
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MySQL to secure it, we'll need the current
password for the root user. If you've just installed MySQL, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none): [Appuyer sur Entrée]
```

> [!tip] Première exécution Si vous venez d'installer MySQL/MariaDB, le mot de passe root est vide. Appuyez simplement sur Entrée quand on vous demande le mot de passe actuel.

### Différences entre MySQL et MariaDB

Le comportement du script diffère légèrement selon la version :

|Aspect|MySQL 5.7+|MariaDB 10.4+|
|---|---|---|
|**Authentification root**|Plugin `auth_socket` ou `caching_sha2_password`|Plugin `unix_socket` par défaut|
|**Changement de mot de passe**|Peut nécessiter des étapes supplémentaires|Plus direct|
|**Plugin VALIDATE PASSWORD**|Proposé sur MySQL|Non disponible sur MariaDB|

---

## 🔑 Définition du mot de passe root

### Importance du mot de passe root

L'utilisateur `root` MySQL possède **tous les privilèges** sur le serveur de base de données. Sans mot de passe fort, un attaquant peut :

- Accéder à toutes les données
- Modifier ou supprimer des bases de données
- Créer de nouveaux utilisateurs avec privilèges
- Compromettre l'ensemble du système

### Étape dans mysql_secure_installation

```bash
Set root password? [Y/n] Y
New password: [Entrer un mot de passe fort]
Re-enter new password: [Confirmer le mot de passe]
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

> [!warning] Choisir un mot de passe fort Un mot de passe root faible est la porte d'entrée la plus courante pour les attaques. Utilisez :
> 
> - Au minimum 12 caractères
> - Majuscules, minuscules, chiffres et symboles
> - Pas de mots du dictionnaire
> - Pas d'informations personnelles

### Plugin VALIDATE PASSWORD (MySQL uniquement)

Sur MySQL, vous pouvez être invité à installer un plugin de validation de mot de passe :

```bash
VALIDATE PASSWORD PLUGIN can be used to test passwords
and improve security. It checks the strength of password
and allows the users to set only those passwords which are
secure enough. Would you like to setup VALIDATE PASSWORD plugin?

Press y|Y for Yes, any other key for No: Y
```

Le plugin propose trois niveaux de validation :

```bash
There are three levels of password validation policy:

LOW    Length >= 8
MEDIUM Length >= 8, numeric, mixed case, and special characters
STRONG Length >= 8, numeric, mixed case, special characters and dictionary file

Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG: 2
```

> [!tip] Recommandation Choisissez le niveau **STRONG (2)** pour un environnement de production. Cela forcera tous les utilisateurs à utiliser des mots de passe robustes.

### Configuration manuelle du mot de passe

Si vous devez définir le mot de passe manuellement (sans le script) :

```bash
# Se connecter à MySQL en tant que root
sudo mysql

# Dans le shell MySQL
ALTER USER 'root'@'localhost' IDENTIFIED BY 'VotreMotDePasseFort123!';
FLUSH PRIVILEGES;
EXIT;
```

> [!example] Avec MariaDB et authentification unix_socket
> 
> ```sql
> -- Si MariaDB utilise unix_socket, vous devez d'abord changer le plugin
> ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password;
> ALTER USER 'root'@'localhost' IDENTIFIED BY 'VotreMotDePasseFort123!';
> FLUSH PRIVILEGES;
> ```

---

## 👤 Suppression des utilisateurs anonymes

### Qu'est-ce qu'un utilisateur anonyme ?

Par défaut, MySQL/MariaDB crée des utilisateurs sans nom (utilisateurs anonymes) qui permettent à **n'importe qui** de se connecter au serveur sans fournir d'identifiants.

```sql
-- Afficher les utilisateurs anonymes
SELECT User, Host FROM mysql.user WHERE User = '';
```

Résultat typique avant sécurisation :

```
+------+-----------+
| User | Host      |
+------+-----------+
|      | localhost |
|      | hostname  |
+------+-----------+
```

### Risques de sécurité

> [!warning] Dangers des utilisateurs anonymes
> 
> - **Accès non authentifié** : N'importe qui peut se connecter
> - **Accès à la base test** : Les utilisateurs anonymes ont des privilèges sur la base `test`
> - **Exploitation possible** : Peut servir de point d'entrée pour une attaque
> - **Non-traçabilité** : Les actions ne sont pas attribuables à un utilisateur identifié

### Suppression via mysql_secure_installation

```bash
Remove anonymous users? [Y/n] Y
 ... Success!
```

Cette étape exécute en arrière-plan :

```sql
DELETE FROM mysql.user WHERE User='';
FLUSH PRIVILEGES;
```

### Vérification de la suppression

Après suppression, vérifiez qu'il n'y a plus d'utilisateurs anonymes :

```bash
# Se connecter à MySQL
sudo mysql -u root -p

# Vérifier les utilisateurs
SELECT User, Host FROM mysql.user;
```

Vous ne devriez plus voir de lignes avec `User = ''`.

> [!tip] Test de connexion anonyme Essayez de vous connecter sans utilisateur pour confirmer que c'est impossible :
> 
> ```bash
> mysql -u '' -p
> # Devrait échouer avec : ERROR 1045 (28000): Access denied
> ```

---

## 🌐 Désactivation de l'accès root distant

### Principe de l'accès local uniquement

Par défaut, l'utilisateur `root` peut se connecter depuis n'importe quelle machine si le serveur est accessible en réseau. Pour des raisons de sécurité, on limite l'accès root à **localhost uniquement**.

### Différence entre accès local et distant

```sql
-- Afficher les comptes root et leurs hôtes autorisés
SELECT User, Host FROM mysql.user WHERE User = 'root';
```

Résultat avant sécurisation :

```
+------+-----------+
| User | Host      |
+------+-----------+
| root | localhost |
| root | 127.0.0.1 |
| root | ::1       |
| root | %         |  ← Accès depuis n'importe où !
+------+-----------+
```

> [!warning] Le wildcard `%` est dangereux ! L'hôte `%` signifie "n'importe quelle adresse IP". Cela expose votre serveur root à Internet si le port MySQL (3306) est ouvert.

### Désactivation via mysql_secure_installation

```bash
Disallow root login remotely? [Y/n] Y
 ... Success!
```

Cette action supprime toutes les entrées root qui ne sont pas `localhost` :

```sql
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;
```

### Pourquoi c'est crucial ?

|Accès autorisé|Impact sécurité|
|---|---|
|**localhost uniquement**|✅ Attaquant doit d'abord compromettre le serveur|
|**Distant activé**|❌ Attaquant peut tenter une connexion directe depuis Internet|

> [!info] Architecture recommandée
> 
> - **Root** : Accès localhost uniquement pour l'administration système
> - **Utilisateurs applicatifs** : Créés avec des privilèges limités, peuvent avoir accès distant si nécessaire
> - **Bastion/Jump server** : Si administration distante nécessaire, utiliser un serveur intermédiaire sécurisé

### Configuration manuelle

Si vous devez le faire manuellement :

```bash
sudo mysql -u root -p
```

```sql
-- Supprimer les accès root distants
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Ou de manière plus sélective
DROP USER 'root'@'%';
DROP USER 'root'@'hostname';

-- Recharger les privilèges
FLUSH PRIVILEGES;
```

### Cas particulier : Besoin d'administration distante

> [!tip] Bonne pratique pour l'administration distante Si vous devez vraiment administrer MySQL à distance :
> 
> 1. **Ne jamais utiliser root** : Créez un utilisateur administratif dédié
> 
> ```sql
> CREATE USER 'admin'@'192.168.1.100' IDENTIFIED BY 'MotDePasseTresFort!';
> GRANT ALL PRIVILEGES ON *.* TO 'admin'@'192.168.1.100' WITH GRANT OPTION;
> ```
> 
> 2. **Utiliser SSH tunneling** : Créez un tunnel SSH pour sécuriser la connexion
> 
> ```bash
> ssh -L 3306:localhost:3306 user@serveur-mysql
> ```
> 
> 3. **Configurer un pare-feu** : Limitez l'accès au port 3306 avec iptables/ufw
> 
> ```bash
> sudo ufw allow from 192.168.1.100 to any port 3306
> ```

---

## ✅ Vérification de la configuration

### Autres étapes du script

Le script `mysql_secure_installation` pose également d'autres questions :

#### Suppression de la base de données test

```bash
Remove test database and access to it? [Y/n] Y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!
```

> [!info] La base `test` La base de données `test` est accessible par défaut aux utilisateurs anonymes. Elle n'a aucune utilité en production et doit être supprimée.

#### Rechargement des tables de privilèges

```bash
Reload privilege tables now? [Y/n] Y
 ... Success!
```

Cette étape applique immédiatement tous les changements effectués.

### Vérification complète post-sécurisation

Après avoir exécuté le script, effectuez ces vérifications :

```bash
# 1. Vérifier que root nécessite un mot de passe
mysql -u root
# Devrait échouer : ERROR 1045 (28000): Access denied

# 2. Connexion réussie avec mot de passe
mysql -u root -p
# Entrer le mot de passe défini
```

```sql
-- 3. Vérifier qu'il n'y a plus d'utilisateurs anonymes
SELECT User, Host FROM mysql.user WHERE User = '';
-- Devrait retourner 0 ligne

-- 4. Vérifier que root est limité à localhost
SELECT User, Host FROM mysql.user WHERE User = 'root';
-- Devrait montrer uniquement localhost, 127.0.0.1, ::1

-- 5. Vérifier que la base test n'existe plus
SHOW DATABASES;
-- Ne devrait pas afficher 'test'

-- 6. Afficher tous les utilisateurs restants
SELECT User, Host, plugin, authentication_string 
FROM mysql.user 
ORDER BY User, Host;
```

> [!example] Sortie attendue pour un serveur sécurisé
> 
> ```
> +-------------+-----------+-----------------------+-------------------+
> | User        | Host      | plugin                | authentication... |
> +-------------+-----------+-----------------------+-------------------+
> | mariadb.sys | localhost | mysql_native_password |                   |
> | mysql       | localhost | mysql_native_password | invalid           |
> | root        | localhost | mysql_native_password | *8C7D3EF...       |
> +-------------+-----------+-----------------------+-------------------+
> ```

---

## ⚠️ Pièges courants

### 1. Oublier de définir un mot de passe root

**Symptôme** : Vous pouvez toujours vous connecter avec `sudo mysql` sans mot de passe.

**Explication** : Sur MariaDB récent, le plugin `unix_socket` permet l'authentification via le compte système.

```sql
-- Vérifier le plugin d'authentification
SELECT User, Host, plugin FROM mysql.user WHERE User = 'root';
```

**Solution** : Si vous voulez forcer l'authentification par mot de passe :

```sql
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('VotreMotDePasse');
FLUSH PRIVILEGES;
```

### 2. Bloquer son propre accès root

**Symptôme** : Après sécurisation, impossible de se connecter, même avec le bon mot de passe.

**Causes possibles** :

- Mot de passe mal saisi lors de la définition
- Plugin d'authentification incorrect
- Suppression accidentelle du compte root

**Solution de récupération** :

```bash
# 1. Arrêter MySQL
sudo systemctl stop mysql

# 2. Démarrer en mode sans vérification des privilèges
sudo mysqld_safe --skip-grant-tables &

# 3. Se connecter sans mot de passe
mysql -u root

# 4. Réinitialiser le mot de passe
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'NouveauMotDePasse';
EXIT;

# 5. Redémarrer normalement
sudo killall mysqld
sudo systemctl start mysql
```

> [!warning] Mode --skip-grant-tables Ce mode désactive complètement la sécurité. Ne l'utilisez que pour la récupération d'urgence et assurez-vous que le serveur n'est pas accessible depuis le réseau.

### 3. Confusion entre utilisateur système et utilisateur MySQL

**Erreur courante** :

```bash
# Ceci utilise l'authentification système (unix_socket)
sudo mysql

# Ceci utilise l'authentification MySQL (mot de passe)
mysql -u root -p
```

> [!info] Comprendre la différence
> 
> - `sudo mysql` : S'authentifie via le compte système root (plugin unix_socket)
> - `mysql -u root -p` : S'authentifie via le mot de passe MySQL
> 
> Les deux peuvent coexister mais correspondent à des méthodes d'authentification différentes.

### 4. Oublier FLUSH PRIVILEGES

Après toute modification manuelle des tables de privilèges, il est **impératif** d'exécuter :

```sql
FLUSH PRIVILEGES;
```

Sans cette commande, les changements ne sont pas appliqués immédiatement et MySQL continue d'utiliser l'ancienne configuration en cache.

### 5. Port 3306 exposé publiquement

**Vérification** :

```bash
# Vérifier sur quelle interface MySQL écoute
sudo netstat -tlnp | grep 3306

# Ou avec ss
sudo ss -tlnp | grep 3306
```

**Sortie sécurisée** (écoute uniquement sur localhost) :

```
tcp  0  0  127.0.0.1:3306  0.0.0.0:*  LISTEN  1234/mysqld
```

**Sortie non sécurisée** (écoute sur toutes les interfaces) :

```
tcp  0  0  0.0.0.0:3306  0.0.0.0:*  LISTEN  1234/mysqld
```

**Configuration** : Le fichier `/etc/mysql/mariadb.conf.d/50-server.cnf` (MariaDB) ou `/etc/mysql/mysql.conf.d/mysqld.cnf` (MySQL) doit contenir :

```ini
[mysqld]
bind-address = 127.0.0.1
```

> [!tip] Sécurité réseau Même avec l'accès root désactivé à distance, il est préférable de ne pas exposer le port 3306 sur Internet. Utilisez :
> 
> - `bind-address = 127.0.0.1` pour un accès local uniquement
> - Un pare-feu (ufw, iptables) pour filtrer les connexions
> - Un VPN ou SSH tunnel pour l'administration distante

### 6. Ne pas documenter le mot de passe root

Après avoir défini un mot de passe fort, **documentez-le de manière sécurisée** :

- Gestionnaire de mots de passe (KeePass, Bitwarden)
- Coffre-fort d'entreprise
- Documentation chiffrée

**Ne jamais** :

- Stocker le mot de passe en clair dans un fichier
- L'envoyer par email
- Le partager via un chat non chiffré
- L'écrire sur un post-it

---

## 🎓 Bonnes pratiques récapitulatives

> [!tip] Checklist de sécurisation MySQL/MariaDB
> 
> - ✅ Exécuter `mysql_secure_installation` immédiatement après l'installation
> - ✅ Définir un mot de passe root fort (12+ caractères, complexe)
> - ✅ Supprimer tous les utilisateurs anonymes
> - ✅ Désactiver l'accès root distant
> - ✅ Supprimer la base de données `test`
> - ✅ Configurer `bind-address = 127.0.0.1` pour un accès local uniquement
> - ✅ Documenter le mot de passe root de manière sécurisée
> - ✅ Tester la configuration après sécurisation
> - ✅ Configurer un pare-feu (ufw/iptables)
> - ✅ Planifier des sauvegardes régulières

La sécurisation initiale est une étape **non négociable** dans la mise en place d'un serveur MySQL/MariaDB. Un serveur non sécurisé peut être compromis en quelques minutes et entraîner des pertes de données catastrophiques. Prenez le temps de bien configurer la sécurité dès le départ.