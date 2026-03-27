## Sommaire - Guide d'installation GLPI sur Debian

1. [Préparation du système](#1-préparation-du-système)
2. [Installation de MariaDB](#2-installation-de-mariadb)
3. [Installation d'Apache et PHP](#3-installation-dapache-et-php)
4. [Téléchargement et installation de GLPI](#4-téléchargement-et-installation-de-glpi)
5. [Configuration d'Apache pour GLPI](#5-configuration-dapache-pour-glpi)
6. [Installation via l'interface web](#6-installation-via-linterface-web)
7. [Ressources complémentaires](#6-ressources-complémentaires)

---

### 1. Préparation du système

#### 1.1 Connexion en root
```bash
su -
```
*Ou utilisez `sudo` si votre utilisateur est dans le groupe sudoers*

#### 1.2 Mise à jour du système
```bash
apt update && apt upgrade -y
```

#### 1.3 Installation des outils de base
```bash
apt install -y curl wget vim ca-certificates lsb-release
```

#### 1.4 Configuration du nom d'hôte
```bash
hostnamectl set-hostname DOM-GLPI-01
```

---

### 2. Installation de MariaDB

#### 2.1 Installation du serveur MariaDB
```bash
apt install mariadb-server mariadb-client -y
```

#### 2.2 Démarrage et activation de MariaDB
```bash
systemctl start mariadb
systemctl enable mariadb
systemctl status mariadb
```

#### 2.3 Sécurisation de MariaDB
```bash
mariadb_secure_installation
```

**Réponses recommandées :**
- **Enter root user password or leave blank** : **APPUYEZ SUR ENTRÉE** (pas de mot de passe défini par défaut)
- Switch to unix_socket authentication? **N**
- Change the root password? **Y** (choisissez un mot de passe fort)
- Remove anonymous users? **Y**
- Disallow root login remotely? **Y**
- Remove test database? **Y**
- Reload privilege tables? **Y**

#### 2.4 Création de la base de données GLPI
```bash
mysql -u root -p
```

Dans le prompt MySQL, exécutez les commandes suivantes :
```sql
CREATE DATABASE glpidb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'glpiuser'@'localhost' IDENTIFIED BY 'Azerty1*';
GRANT ALL PRIVILEGES ON glpidb.* TO 'glpiuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

### 3. Installation d'Apache et PHP

#### 3.1 Installation d'Apache
```bash
apt install apache2 -y
```

#### 3.2 Activation et démarrage d'Apache
```bash
systemctl start apache2
systemctl enable apache2
systemctl status apache2
```

#### 3.3 Installation de PHP 8.4+ et modules requis
```bash
apt install -y php php-cli php-common php-mysql php-gd php-xml php-mbstring \
php-curl php-intl php-zip php-bz2 php-ldap php-apcu php-bcmath \
php-xmlrpc php-cas libapache2-mod-php
```

- #####  Installation du module IMAP (optionnel - pour collecte d'emails)
```bash
apt install -y php8.4-imap
```

#### 3.4 Vérification de la version PHP
```bash
php -v
```

#### 3.5 Configuration de PHP pour GLPI
Éditez le fichier php.ini :
```bash
nano /etc/php/8.4/apache2/php.ini
```

Modifiez les paramètres suivants (utilisez `ctrl + w` pour rechercher dans nano) :
Par exemple : `ctrl + w` > memory_limit > `Entrée`
```ini
memory_limit = 256M
upload_max_filesize = 100M
post_max_size = 100M
max_execution_time = 300
max_input_time = 300
session.cookie_httponly = On
date.timezone = Europe/Paris
```

#### 3.6 Redémarrage d'Apache
```bash
systemctl restart apache2
```

---

### 4. Téléchargement et installation de GLPI

#### 4.1 Téléchargement de la dernière version de GLPI
Allez sur https://github.com/glpi-project/glpi/releases pour connaître la dernière version.

```bash
cd /tmp
wget https://github.com/glpi-project/glpi/releases/download/11.0.5/glpi-11.0.5.tgz
```

- **Remplacez `11.0.5` par la version actuelle**

#### 4.2 Extraction dans le répertoire web
```bash
tar -xzf glpi-11.0.5.tgz
mv glpi /var/www/html/
```

#### 4.3 Attribution des permissions
```bash
chown -R www-data:www-data /var/www/html/glpi
chmod -R 755 /var/www/html/glpi
```

---

### 5. Configuration d'Apache pour GLPI

#### 5.1 Création du VirtualHost
```bash
nano /etc/apache2/sites-available/glpi.conf
```

Ajoutez le contenu suivant :
```apache
<VirtualHost *:80>
    ServerName DOM-GLPI-01
    DocumentRoot /var/www/html/glpi/public

    <Directory /var/www/html/glpi/public>
        Require all granted
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>

    <Directory /var/www/html/glpi>
        Options -Indexes
    </Directory>

    ErrorLog /var/log/apache2/glpi-error.log
    CustomLog /var/log/apache2/glpi-access.log combined
</VirtualHost>
```

#### 5.2 Activation du module rewrite et du site
```bash
a2enmod rewrite
a2dissite 000-default.conf
a2ensite glpi.conf
```

#### 5.3 Redémarrage d'Apache
```bash
systemctl restart apache2
```

#### 5.4 Test de la configuration Apache
```bash
apache2ctl configtest
```
- *Doit afficher "Syntax OK"*

---

### 6. Installation via l'interface web

#### 6.1 Accès à l'interface d'installation
Ouvrez votre navigateur web et accédez à :
```
http://ADRESSE_IP_DU_SERVEUR_GLPI/  (172.16.13.1)
```

#### 6.2 Étapes de l'assistant d'installation

#### Écran 1 : Choix de la langue
- Sélectionner **Français**
- Cliquer sur **OK**

![img](Ressources/glpi_img/01_glpi_installation_web/02_glpi_installation_web.png)

#### Écran 2 : Licence
- Cliquer sur **Continuer**

![img](Ressources/glpi_img/01_glpi_installation_web/03_glpi_installation_web.png)

#### Écran 3 : Choix du type d'installation
- Sélectionner **Installer**

![img](Ressources/glpi_img/01_glpi_installation_web/04_glpi_installation_web.png)

#### Écran 4 : Vérification de la compatibilité
- Vérifier que tous les prérequis sont ok
- Si certains éléments sont en orange ou rouge, corrigez-les avant de continuer
- Cliquer sur **Continuer**

![img](Ressources/glpi_img/01_glpi_installation_web/05_glpi_installation_web.png)

#### Écran 5 : Configuration de la base de données
Renseignez les informations suivantes :
- **Serveur SQL** : `localhost`
- **Utilisateur SQL** : `glpiuser`
- **Mot de passe SQL** : `Azerty1*` (Le mot de passe définit à l'étape 2.4)
- Cliquer sur **Continuer**

![img](Ressources/glpi_img/01_glpi_installation_web/06_glpi_installation_web.png)

#### Écran 6 : Sélection de la base de données
- Sélectionner **glpidb**
- Cliquer sur **Continuer**

![img](Ressources/glpi_img/01_glpi_installation_web/07_glpi_installation_web.png)

#### Écran 7 : Initialisation de la base

- Attendre la fin du processus
- Cliquer sur **Continuer**

![img](Ressources/glpi_img/01_glpi_installation_web/08_glpi_installation_web.png)

#### Écran 8 : Récolte des données

- Décocher **Envoyer statistiques d'usage**
- Cliquer sur **Continuer**

![img](Ressources/glpi_img/01_glpi_installation_web/09_glpi_installation_web.png)

#### Écran 9 : Dernière étape installation

- Décocher **Envoyer statistiques d'usage**
- Cliquer sur **Continuer**

![img](Ressources/glpi_img/01_glpi_installation_web/10_glpi_installation_web.png)

#### Écran 10 : Fin de l'installation
- L'installation est terminée !

![img](Ressources/glpi_img/01_glpi_installation_web/11_glpi_installation_web.png)

#### 11 : Première connexion 

- Entrer les identifiants
- Noter les informations de connexion par défaut :
  - **Compte super-administrateur** : `glpi` / `glpi`
  - **Compte administrateur** : `tech` / `tech`
  - **Compte normal** : `normal` / `normal`
  - **Compte post-only** : `post-only` / `postonly`
- Sélectionner **Base interne GLPI**
- Cliquer sur **Se connecter**

![img](Ressources/glpi_img/01_glpi_installation_web/12_glpi_installation_web.png)

#### 12 : Interface WEB

- Cliquer sur **Désactiver les données de démonstration**  

![img](Ressources/glpi_img/01_glpi_installation_web/13_glpi_installation_web.png)

---

### 7. Ressources complémentaires

- **Documentation officielle** : https://glpi-install.readthedocs.io/
- **Forum communautaire** : https://forum.glpi-project.org/
- **GitHub GLPI** : https://github.com/glpi-project/glpi
- **Plugins GLPI** : https://plugins.glpi-project.org/


