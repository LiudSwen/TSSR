
---

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

Dans une stack LAMP (Linux, Apache, MySQL/MariaDB, PHP), le système de gestion de base de données (SGBD) est la couche responsable du stockage, de l'organisation et de la récupération des données. MySQL et MariaDB sont les deux SGBD relationnels les plus populaires pour ce rôle.

> [!info] Pourquoi un SGBD dans LAMP ? Le SGBD permet de :
> 
> - Stocker les données de manière structurée et persistante
> - Gérer les relations entre différentes tables de données
> - Assurer l'intégrité et la cohérence des données
> - Permettre des requêtes complexes et performantes
> - Gérer les accès concurrents de plusieurs utilisateurs

---

## 🔀 Choix entre MySQL et MariaDB

### Historique et contexte

**MySQL** a été créé en 1995 et racheté par Oracle en 2010. Suite à ce rachat, la communauté open source a créé **MariaDB** en 2009 comme fork de MySQL pour garantir qu'il reste libre et open source.

### Comparaison détaillée

|Critère|MySQL|MariaDB|
|---|---|---|
|**Propriétaire**|Oracle Corporation|MariaDB Foundation (communauté)|
|**Licence**|GPL (version communautaire) + propriétaire|GPL (entièrement open source)|
|**Compatibilité**|Standard de référence|Compatible avec MySQL (drop-in replacement)|
|**Performance**|Très bonne|Légèrement supérieure sur certains cas|
|**Moteurs de stockage**|InnoDB, MyISAM|InnoDB, Aria, ColumnStore, etc.|
|**Développement**|Contrôlé par Oracle|Communauté active et transparente|
|**Support commercial**|Oracle Support|MariaDB Corporation|

> [!tip] Quel choix faire ? **Choisissez MariaDB si :**
> 
> - Vous privilégiez l'open source pur
> - Vous voulez bénéficier des dernières innovations
> - Vous utilisez une distribution Linux récente (c'est souvent le choix par défaut)
> 
> **Choisissez MySQL si :**
> 
> - Vous avez besoin de fonctionnalités Enterprise spécifiques d'Oracle
> - Votre application nécessite une compatibilité stricte avec MySQL
> - Vous avez déjà une infrastructure MySQL existante

### Compatibilité et migration

MariaDB a été conçu comme un "drop-in replacement" de MySQL, ce qui signifie :

- Les commandes SQL sont identiques
- Les outils de gestion (phpMyAdmin, MySQL Workbench) fonctionnent avec les deux
- Les applications PHP/Python/etc. n'ont pas besoin de modification
- La migration de MySQL vers MariaDB est généralement transparente

> [!warning] Attention aux versions MariaDB 10.x n'est PAS compatible avec MySQL 5.x en termes de numérotation. MariaDB 10.2 correspond environ à MySQL 5.7 en termes de fonctionnalités.

---

## 📦 Installation via gestionnaire de paquets

### Sur Debian/Ubuntu

#### Installation de MariaDB

```bash
# Mise à jour de la liste des paquets
sudo apt update

# Installation de MariaDB Server
sudo apt install mariadb-server mariadb-client -y

# Vérification de l'installation
mariadb --version
```

> [!info] Paquets installés
> 
> - `mariadb-server` : Le serveur de base de données
> - `mariadb-client` : Les outils en ligne de commande pour interagir avec le serveur

#### Installation de MySQL

```bash
# Mise à jour de la liste des paquets
sudo apt update

# Installation de MySQL Server
sudo apt install mysql-server mysql-client -y

# Vérification de l'installation
mysql --version
```

> [!example] Résultat attendu
> 
> ```
> mysql  Ver 8.0.35 for Linux on x86_64 (MySQL Community Server - GPL)
> ```
> 
> ou
> 
> ```
> mariadb  Ver 15.1 Distrib 10.11.6-MariaDB, for debian-linux-gnu (x86_64)
> ```

### Sur CentOS/RHEL/Rocky Linux

#### Installation de MariaDB

```bash
# Installation de MariaDB Server
sudo dnf install mariadb-server -y

# Vérification de l'installation
mariadb --version
```

#### Installation de MySQL

Pour MySQL, il faut d'abord ajouter le dépôt officiel :

```bash
# Téléchargement du dépôt MySQL
sudo dnf install https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm -y

# Installation de MySQL Server
sudo dnf install mysql-community-server -y

# Vérification de l'installation
mysql --version
```

### Sur Fedora

```bash
# Installation de MariaDB (recommandé sur Fedora)
sudo dnf install mariadb-server -y

# Vérification de l'installation
mariadb --version
```

> [!tip] Choix du dépôt Les distributions Linux modernes incluent souvent MariaDB par défaut dans leurs dépôts officiels. Pour installer MySQL, vous devrez généralement ajouter le dépôt officiel de MySQL.

### Installation de paquets additionnels utiles

```bash
# Sur Debian/Ubuntu
sudo apt install mycli -y  # Client interactif avec auto-complétion

# Sur CentOS/RHEL/Rocky/Fedora
sudo dnf install mycli -y
```

> [!info] MyCLI `mycli` est un client en ligne de commande moderne pour MySQL/MariaDB avec auto-complétion et coloration syntaxique, rendant l'interaction beaucoup plus agréable.

---

## 🚀 Démarrage et gestion du service

### Gestion du service avec systemd

Les distributions Linux modernes utilisent `systemd` pour gérer les services. Voici les commandes essentielles :

#### Démarrer le service

```bash
# Pour MariaDB
sudo systemctl start mariadb

# Pour MySQL
sudo systemctl start mysqld
```

> [!info] Nom du service
> 
> - MariaDB utilise le nom de service `mariadb`
> - MySQL utilise le nom de service `mysqld` (avec un 'd' à la fin)

#### Arrêter le service

```bash
# Pour MariaDB
sudo systemctl stop mariadb

# Pour MySQL
sudo systemctl stop mysqld
```

#### Redémarrer le service

```bash
# Pour MariaDB
sudo systemctl restart mariadb

# Pour MySQL
sudo systemctl restart mysqld
```

#### Recharger la configuration sans redémarrage

```bash
# Pour MariaDB
sudo systemctl reload mariadb

# Pour MySQL
sudo systemctl reload mysqld
```

> [!tip] Reload vs Restart
> 
> - `reload` : Recharge la configuration sans couper les connexions existantes (plus doux)
> - `restart` : Arrête complètement puis redémarre le service (coupe toutes les connexions)

#### Vérifier le statut du service

```bash
# Pour MariaDB
sudo systemctl status mariadb

# Pour MySQL
sudo systemctl status mysqld
```

> [!example] Sortie attendue
> 
> ```
> ● mariadb.service - MariaDB 10.11.6 database server
>      Loaded: loaded (/lib/systemd/system/mariadb.service; enabled; preset: enabled)
>      Active: active (running) since Mon 2024-12-21 10:30:15 CET; 2h 15min ago
>    Main PID: 1234 (mariadbd)
>      Status: "Taking your SQL requests now..."
>       Tasks: 12 (limit: 4915)
>      Memory: 89.5M
>         CPU: 3.142s
>      CGroup: /system.slice/mariadb.service
>              └─1234 /usr/sbin/mariadbd
> ```

#### Activer le démarrage automatique au boot

```bash
# Pour MariaDB
sudo systemctl enable mariadb

# Pour MySQL
sudo systemctl enable mysqld
```

> [!warning] Démarrage automatique Par défaut, le service n'est pas toujours activé au démarrage. Pensez à l'activer avec `enable` pour qu'il démarre automatiquement au boot du serveur.

#### Désactiver le démarrage automatique

```bash
# Pour MariaDB
sudo systemctl disable mariadb

# Pour MySQL
sudo systemctl disable mysqld
```

### Vérification de l'écoute réseau

```bash
# Vérifier que le service écoute sur le port 3306
sudo netstat -tlnp | grep 3306
# ou avec ss (plus moderne)
sudo ss -tlnp | grep 3306
```

> [!example] Sortie attendue
> 
> ```
> tcp    0    0 127.0.0.1:3306    0.0.0.0:*    LISTEN    1234/mariadbd
> ```

> [!info] Port par défaut MySQL et MariaDB utilisent par défaut le port **3306** pour les connexions TCP/IP.

### Logs du service

#### Visualiser les logs en temps réel

```bash
# Avec journalctl (systemd)
sudo journalctl -u mariadb -f
# ou pour MySQL
sudo journalctl -u mysqld -f
```

#### Consulter les logs récents

```bash
# Les 100 dernières lignes
sudo journalctl -u mariadb -n 100

# Depuis aujourd'hui
sudo journalctl -u mariadb --since today

# Entre deux dates
sudo journalctl -u mariadb --since "2024-12-20" --until "2024-12-21"
```

#### Fichiers de logs traditionnels

```bash
# Logs d'erreur (emplacement par défaut)
sudo tail -f /var/log/mysql/error.log          # Debian/Ubuntu
sudo tail -f /var/log/mariadb/mariadb.log      # Debian/Ubuntu (MariaDB)
sudo tail -f /var/log/mysqld.log               # CentOS/RHEL
```

> [!tip] Astuce de débogage En cas de problème au démarrage, consultez d'abord les logs avec `journalctl` ou dans les fichiers de logs. Les messages d'erreur y sont généralement très explicites.

### Commandes de diagnostic

#### Vérifier que le service répond

```bash
# Test de connexion simple
mysqladmin ping

# Afficher les variables du serveur
mysqladmin variables

# Afficher le statut
mysqladmin status
```

> [!example] Réponse de `mysqladmin ping`
> 
> ```
> mysqld is alive
> ```

#### Vérifier les processus

```bash
# Processus MySQL/MariaDB en cours
ps aux | grep -E 'mysql|mariadb'

# Ressources utilisées
top -p $(pgrep -d',' mysql)
```

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges courants

> [!warning] Problème 1 : Service non démarré après installation **Symptôme :** Impossibilité de se connecter à la base de données
> 
> **Solution :**
> 
> ```bash
> sudo systemctl start mariadb
> sudo systemctl enable mariadb
> ```

> [!warning] Problème 2 : Confusion entre les noms de service **Symptôme :** `systemctl status mysql` ne fonctionne pas
> 
> **Cause :** Le nom du service est `mariadb` ou `mysqld`, pas `mysql`
> 
> **Solution :** Vérifiez avec `systemctl list-units | grep -E 'mysql|mariadb'`

> [!warning] Problème 3 : Firewall bloque l'accès distant **Symptôme :** Connexion locale OK, mais connexion distante refuse
> 
> **Solution :**
> 
> ```bash
> # Ouvrir le port 3306
> sudo firewall-cmd --permanent --add-service=mysql
> sudo firewall-cmd --reload
> 
> # Ou avec UFW (Ubuntu)
> sudo ufw allow 3306/tcp
> ```

> [!warning] Problème 4 : Permissions insuffisantes sur les fichiers **Symptôme :** Le service refuse de démarrer avec des erreurs de permissions
> 
> **Solution :**
> 
> ```bash
> # Vérifier le propriétaire des fichiers de données
> sudo chown -R mysql:mysql /var/lib/mysql
> sudo chmod 750 /var/lib/mysql
> ```

### Bonnes pratiques

> [!tip] Pratique 1 : Toujours activer le démarrage automatique En production, assurez-vous que le service démarre au boot du serveur :
> 
> ```bash
> sudo systemctl enable mariadb
> ```

> [!tip] Pratique 2 : Surveiller les logs régulièrement Mettez en place une surveillance des logs pour détecter les problèmes :
> 
> ```bash
> # Créer un alias pour consulter rapidement les logs
> alias mysql-logs='sudo journalctl -u mariadb -f'
> ```

> [!tip] Pratique 3 : Documenter la version installée Gardez une trace de la version installée dans votre documentation :
> 
> ```bash
> # Sauvegarder les informations de version
> mariadb --version > /opt/infra-docs/mariadb-version.txt
> ```

> [!tip] Pratique 4 : Tester après chaque redémarrage Après un redémarrage du service, testez toujours la connectivité :
> 
> ```bash
> sudo systemctl restart mariadb
> mysqladmin ping && echo "✓ Service OK" || echo "✗ Service KO"
> ```

> [!tip] Pratique 5 : Utiliser systemctl pour gérer le service Évitez les commandes directes comme `/etc/init.d/mysql start`. Utilisez toujours `systemctl` sur les systèmes modernes pour bénéficier de toutes les fonctionnalités de systemd.

### Astuces professionnelles

> [!tip] Astuce 1 : Alias pratiques Ajoutez ces alias dans votre `.bashrc` :
> 
> ```bash
> alias mysql-start='sudo systemctl start mariadb'
> alias mysql-stop='sudo systemctl stop mariadb'
> alias mysql-status='sudo systemctl status mariadb'
> alias mysql-restart='sudo systemctl restart mariadb'
> alias mysql-logs='sudo journalctl -u mariadb -f --lines=100'
> ```

> [!tip] Astuce 2 : Script de vérification rapide Créez un script pour vérifier l'état du service :
> 
> ```bash
> #!/bin/bash
> # check-mysql.sh
> 
> echo "=== État du service MySQL/MariaDB ==="
> sudo systemctl status mariadb --no-pager | grep Active
> 
> echo -e "\n=== Port 3306 ==="
> sudo ss -tlnp | grep 3306
> 
> echo -e "\n=== Test de connexion ==="
> mysqladmin ping 2>/dev/null && echo "✓ Connexion OK" || echo "✗ Connexion échouée"
> ```

> [!tip] Astuce 3 : Monitoring avec watch Surveillez en temps réel l'état du service :
> 
> ```bash
> watch -n 2 'systemctl status mariadb | grep -A 5 "Active:"'
> ```

---

## 🎓 Récapitulatif

Vous avez maintenant les connaissances pour :

✅ Comprendre les différences entre MySQL et MariaDB  
✅ Choisir le SGBD adapté à votre contexte  
✅ Installer MySQL ou MariaDB via le gestionnaire de paquets  
✅ Démarrer, arrêter et gérer le service avec systemd  
✅ Diagnostiquer les problèmes courants  
✅ Appliquer les bonnes pratiques de gestion du service

> [!info] Prochaine étape Une fois le service installé et démarré, vous devrez procéder à la sécurisation initiale et à la configuration du SGBD (ce qui sera abordé dans les parties suivantes du cours LAMP).

---

_Cours généré pour la stack LAMP - Installation et Configuration de MySQL/MariaDB_