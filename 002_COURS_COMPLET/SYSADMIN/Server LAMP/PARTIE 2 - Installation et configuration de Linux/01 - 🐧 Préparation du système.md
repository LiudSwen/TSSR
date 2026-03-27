

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

## 🔧 Préparation du système

### Qu'est-ce que la préparation du système ?

La préparation du système consiste à mettre en place un environnement Linux stable, sécurisé et optimisé avant d'installer les composants du serveur LAMP (Linux, Apache, MySQL, PHP). Cette étape garantit que votre serveur dispose d'une base solide et évite les problèmes futurs.

### Pourquoi est-ce important ?

> [!info] Importance de la préparation
> 
> - **Sécurité** : Un système mal configuré est vulnérable aux attaques
> - **Stabilité** : Évite les conflits de paquets et les dysfonctionnements
> - **Performance** : Un système optimisé dès le départ fonctionne mieux
> - **Maintenance** : Facilite les mises à jour et la gestion future

### Vérification de la distribution Linux

Avant toute manipulation, identifiez votre distribution :

```bash
# Afficher la distribution et la version
cat /etc/os-release

# Version courte
lsb_release -a

# Informations sur le noyau
uname -a
```

> [!example] Résultat typique
> 
> ```
> NAME="Ubuntu"
> VERSION="22.04.3 LTS (Jammy Jellyfish)"
> ID=ubuntu
> ID_LIKE=debian
> ```

### Vérification de l'espace disque

```bash
# Afficher l'espace disque disponible
df -h

# Afficher l'utilisation des répertoires principaux
du -sh /var /home /tmp

# Vérifier les inodes (important pour les petits fichiers)
df -i
```

> [!warning] Espace disque minimum recommandé
> 
> - **Système** : 20 GB minimum
> - **/var** : 10 GB minimum (logs, base de données)
> - **/home** : Selon vos besoins utilisateurs

---

## 📦 Mise à jour des paquets

### Comprendre le système de paquets

Linux utilise des gestionnaires de paquets pour installer, mettre à jour et supprimer des logiciels. Les deux principaux sont :

|Distribution|Gestionnaire|Commandes|
|---|---|---|
|Debian/Ubuntu|APT|`apt`, `apt-get`, `dpkg`|
|RedHat/CentOS/Rocky|YUM/DNF|`yum`, `dnf`, `rpm`|

### Mise à jour sous Debian/Ubuntu

```bash
# 1. Mettre à jour la liste des paquets disponibles
sudo apt update

# 2. Afficher les paquets qui peuvent être mis à jour
apt list --upgradable

# 3. Mettre à jour tous les paquets installés
sudo apt upgrade -y

# 4. Mise à jour complète (inclut les suppressions si nécessaire)
sudo apt full-upgrade -y

# 5. Nettoyer les paquets inutiles
sudo apt autoremove -y
sudo apt autoclean
```

> [!tip] Différence entre upgrade et full-upgrade
> 
> - `apt upgrade` : Met à jour sans supprimer de paquets
> - `apt full-upgrade` : Peut supprimer des paquets obsolètes pour résoudre les dépendances

### Mise à jour sous RedHat/CentOS/Rocky

```bash
# 1. Mettre à jour la liste des paquets (DNF/YUM)
sudo dnf check-update
# ou pour YUM
sudo yum check-update

# 2. Mettre à jour tous les paquets
sudo dnf update -y
# ou
sudo yum update -y

# 3. Nettoyer le cache
sudo dnf clean all
# ou
sudo yum clean all
```

### Automatisation des mises à jour

> [!warning] Mises à jour automatiques : avantages et risques **Avantages** : Sécurité maintenue, gain de temps **Risques** : Possibles incompatibilités, redémarrages non planifiés

**Installation du système de mise à jour automatique (Ubuntu) :**

```bash
# Installer unattended-upgrades
sudo apt install unattended-upgrades -y

# Configurer les mises à jour automatiques
sudo dpkg-reconfigure -plow unattended-upgrades

# Éditer la configuration
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

**Configuration recommandée :**

```bash
# Activer uniquement les mises à jour de sécurité
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};

# Redémarrage automatique si nécessaire (à 2h du matin)
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";

# Notifications par email
Unattended-Upgrade::Mail "admin@example.com";
```

### Gestion des redémarrages

```bash
# Vérifier si un redémarrage est nécessaire
[ -f /var/run/reboot-required ] && echo "Redémarrage nécessaire" || echo "Pas de redémarrage"

# Planifier un redémarrage
sudo shutdown -r +60 "Redémarrage dans 60 minutes pour maintenance"

# Annuler un redémarrage planifié
sudo shutdown -c
```

> [!tip] Astuce : Vérification régulière Ajoutez cette commande à votre routine :
> 
> ```bash
> sudo apt update && apt list --upgradable
> ```

---

## 🏷️ Configuration du hostname

### Qu'est-ce que le hostname ?

Le hostname est l'identifiant unique de votre machine sur le réseau. Il est crucial pour :

- Identifier le serveur dans les logs
- Faciliter l'administration de plusieurs serveurs
- Configurer correctement les services réseau

### Structure d'un hostname

> [!info] Convention de nommage **Format recommandé** : `role-environment-number.domain.tld`
> 
> Exemples :
> 
> - `web-prod-01.example.com`
> - `db-dev-02.internal.local`
> - `lamp-staging.mysite.org`

### Afficher le hostname actuel

```bash
# Méthode 1 : commande hostname
hostname

# Méthode 2 : hostname complet (FQDN)
hostname -f

# Méthode 3 : via hostnamectl (systemd)
hostnamectl

# Méthode 4 : lire le fichier de configuration
cat /etc/hostname
```

### Modifier le hostname temporairement

```bash
# Change le hostname jusqu'au prochain redémarrage
sudo hostname nouveau-nom

# Vérification
hostname
```

> [!warning] Modification temporaire Cette méthode ne persiste pas après un redémarrage. Utilisez-la uniquement pour des tests.

### Modifier le hostname de manière permanente

**Méthode 1 : avec hostnamectl (recommandé pour systemd)**

```bash
# Définir le hostname
sudo hostnamectl set-hostname lamp-server-01

# Définir le hostname "joli" (optionnel)
sudo hostnamectl set-hostname "LAMP Production Server" --pretty

# Vérifier les changements
hostnamectl status
```

**Méthode 2 : modification manuelle des fichiers**

```bash
# 1. Éditer /etc/hostname
sudo nano /etc/hostname
# Remplacer tout le contenu par le nouveau nom :
# lamp-server-01

# 2. Éditer /etc/hosts
sudo nano /etc/hosts
# Ajouter/modifier la ligne :
# 127.0.1.1    lamp-server-01.example.com    lamp-server-01

# 3. Redémarrer le service (ou redémarrer la machine)
sudo systemctl restart systemd-hostnamed
```

### Configuration complète du fichier /etc/hosts

```bash
# /etc/hosts - Configuration type pour un serveur LAMP
127.0.0.1       localhost
127.0.1.1       lamp-server-01.example.com lamp-server-01

# IPv6
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

# Autres serveurs du réseau (optionnel)
192.168.1.100   lamp-server-01.example.com lamp-server-01
192.168.1.101   db-server-01.example.com db-server-01
```

> [!tip] Bonnes pratiques pour /etc/hosts
> 
> - Toujours inclure le FQDN (Fully Qualified Domain Name) avant l'alias court
> - Utiliser 127.0.1.1 pour le hostname local (pas 127.0.0.1)
> - Documenter les entrées avec des commentaires

### Vérification de la configuration DNS

```bash
# Tester la résolution du hostname
ping -c 3 $(hostname)

# Vérifier la résolution DNS inverse
nslookup $(hostname -I | awk '{print $1}')

# Vérifier le FQDN
hostname -f

# Test complet de résolution
getent hosts $(hostname)
```

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> **1. Hostname non résolu localement**
> 
> ```bash
> # Symptôme : sudo donne un avertissement
> sudo: unable to resolve host lamp-server-01
> 
> # Solution : vérifier /etc/hosts
> grep $(hostname) /etc/hosts
> ```
> 
> **2. Caractères invalides dans le hostname**
> 
> - Utilisez uniquement : lettres, chiffres, tirets (-)
> - Pas d'underscores (_), d'espaces ou de caractères spéciaux
> - Longueur maximum : 63 caractères
> 
> **3. Confusion entre hostname et FQDN**
> 
> - Hostname : `lamp-server-01`
> - FQDN : `lamp-server-01.example.com`

---

## 👥 Gestion des utilisateurs et permissions

### Principe de moindre privilège

> [!info] Sécurité par les permissions Le principe fondamental : chaque utilisateur et processus doit avoir uniquement les permissions nécessaires à sa fonction, pas plus.

### Comprendre les types d'utilisateurs

|Type|Description|UID|Exemple|
|---|---|---|---|
|**root**|Super-utilisateur, tous les droits|0|root|
|**Système**|Utilisateurs pour les services|1-999|www-data, mysql|
|**Utilisateurs normaux**|Utilisateurs humains|1000+|admin, dev|

### Gestion des utilisateurs

**Créer un utilisateur**

```bash
# Créer un utilisateur avec répertoire home
sudo adduser nom_utilisateur

# Créer un utilisateur sans interaction (pour scripts)
sudo useradd -m -s /bin/bash nom_utilisateur

# Créer un utilisateur système (pour un service)
sudo useradd -r -s /bin/false nom_service
```

> [!example] Différence adduser vs useradd
> 
> - `adduser` : Commande interactive, crée automatiquement le home, demande le mot de passe
> - `useradd` : Commande bas niveau, nécessite plus d'options manuelles

**Options importantes pour useradd**

```bash
# Créer un utilisateur complet
sudo useradd -m \                    # Créer le répertoire home
            -s /bin/bash \          # Shell par défaut
            -G sudo,www-data \      # Groupes supplémentaires
            -c "Administrateur LAMP" \  # Commentaire
            nom_utilisateur

# Définir le mot de passe
sudo passwd nom_utilisateur
```

**Modifier un utilisateur existant**

```bash
# Changer le shell
sudo usermod -s /bin/bash nom_utilisateur

# Ajouter à un groupe supplémentaire
sudo usermod -aG sudo nom_utilisateur

# Renommer un utilisateur
sudo usermod -l nouveau_nom ancien_nom

# Verrouiller un compte (désactiver temporairement)
sudo usermod -L nom_utilisateur

# Déverrouiller un compte
sudo usermod -U nom_utilisateur
```

**Supprimer un utilisateur**

```bash
# Supprimer l'utilisateur mais garder son répertoire home
sudo userdel nom_utilisateur

# Supprimer l'utilisateur ET son répertoire home
sudo deluser --remove-home nom_utilisateur
```

### Gestion des groupes

**Créer et gérer des groupes**

```bash
# Créer un groupe
sudo groupadd nom_groupe

# Ajouter un utilisateur à un groupe
sudo usermod -aG nom_groupe nom_utilisateur
# ou
sudo adduser nom_utilisateur nom_groupe

# Retirer un utilisateur d'un groupe
sudo gpasswd -d nom_utilisateur nom_groupe

# Lister les groupes d'un utilisateur
groups nom_utilisateur
id nom_utilisateur

# Lister tous les membres d'un groupe
getent group nom_groupe
```

> [!warning] Option -aG vs -G
> 
> - `usermod -aG groupe user` : **Ajoute** le groupe (append)
> - `usermod -G groupe user` : **Remplace** tous les groupes par celui-ci Toujours utiliser `-aG` pour ajouter !

**Groupes importants pour un serveur LAMP**

```bash
# Groupe sudo : administration système
sudo usermod -aG sudo nom_utilisateur

# Groupe www-data : gestion des fichiers web
sudo usermod -aG www-data nom_utilisateur

# Groupe mysql : gestion de la base de données (rarement utilisé)
# sudo usermod -aG mysql nom_utilisateur
```

### Configuration de sudo

**Qu'est-ce que sudo ?**

`sudo` (Super User DO) permet d'exécuter des commandes avec les privilèges root sans se connecter en tant que root.

**Éditer la configuration sudo**

```bash
# TOUJOURS utiliser visudo (vérifie la syntaxe avant de sauvegarder)
sudo visudo
```

> [!warning] Ne jamais éditer /etc/sudoers directement Utilisez toujours `visudo` pour éviter de bloquer votre accès sudo en cas d'erreur de syntaxe.

**Exemples de configuration sudo**

```bash
# Fichier : /etc/sudoers

# Permettre à un utilisateur d'utiliser sudo avec mot de passe
nom_utilisateur ALL=(ALL:ALL) ALL

# Permettre à un utilisateur d'utiliser sudo SANS mot de passe (ATTENTION : risque)
nom_utilisateur ALL=(ALL) NOPASSWD:ALL

# Permettre uniquement certaines commandes
nom_utilisateur ALL=(ALL) /usr/sbin/systemctl restart apache2, /usr/sbin/systemctl reload apache2

# Permettre à un groupe
%admin ALL=(ALL:ALL) ALL
```

**Créer des règles sudo personnalisées**

```bash
# Créer un fichier dans /etc/sudoers.d/ (recommandé)
sudo visudo -f /etc/sudoers.d/lamp-admin

# Contenu du fichier :
# Groupe lamp-admin peut gérer les services web
%lamp-admin ALL=(ALL) NOPASSWD: /usr/sbin/systemctl * apache2, \
                                /usr/sbin/systemctl * mysql, \
                                /usr/bin/tail /var/log/apache2/*
```

> [!tip] Organisation des règles sudo Utilisez des fichiers séparés dans `/etc/sudoers.d/` pour chaque ensemble de règles. C'est plus propre et plus maintenable.

### Comprendre les permissions Linux

**Les trois types de permissions**

|Permission|Fichier|Répertoire|Valeur octale|
|---|---|---|---|
|**r** (read)|Lire le contenu|Lister les fichiers|4|
|**w** (write)|Modifier le contenu|Créer/supprimer des fichiers|2|
|**x** (execute)|Exécuter le fichier|Accéder au répertoire|1|

**Les trois catégories d'utilisateurs**

```bash
# Format : rwxrwxrwx
#          ↓  ↓  ↓
#          │  │  └─ Others (autres)
#          │  └──── Group (groupe)
#          └─────── User (propriétaire)
```

**Afficher les permissions**

```bash
# Lister avec permissions détaillées
ls -l fichier.txt
# -rw-r--r-- 1 user group 1024 Dec 20 10:30 fichier.txt

# Format détaillé avec ACL
ls -la /var/www/html/

# Afficher uniquement les permissions
stat -c '%A %n' fichier.txt
```

### Modifier les permissions

**Avec chmod (mode symbolique)**

```bash
# Ajouter une permission
chmod u+x script.sh        # User : ajouter exécution
chmod g+w fichier.txt      # Group : ajouter écriture
chmod o-r fichier.txt      # Others : retirer lecture

# Modifier plusieurs permissions
chmod ug+rw fichier.txt    # User et Group : ajouter lecture/écriture
chmod a+r fichier.txt      # All : ajouter lecture pour tous

# Définir exactement les permissions
chmod u=rwx,g=rx,o=r fichier.txt
```

**Avec chmod (mode octal)**

```bash
# Calcul : r=4, w=2, x=1
# Exemples courants :

# 755 : rwxr-xr-x (propriétaire: tout, autres: lecture/exécution)
chmod 755 script.sh

# 644 : rw-r--r-- (propriétaire: lecture/écriture, autres: lecture seule)
chmod 644 fichier.txt

# 600 : rw------- (propriétaire: lecture/écriture, autres: rien)
chmod 600 secret.key

# 775 : rwxrwxr-x (propriétaire et groupe: tout, autres: lecture/exécution)
chmod 775 /var/www/html

# 750 : rwxr-x--- (propriétaire: tout, groupe: lecture/exécution, autres: rien)
chmod 750 /var/www/html
```

> [!example] Permissions recommandées pour un serveur web
> 
> ```bash
> # Répertoires web
> sudo chmod 755 /var/www/html
> 
> # Fichiers HTML/PHP
> sudo chmod 644 /var/www/html/*.html
> sudo chmod 644 /var/www/html/*.php
> 
> # Répertoires d'upload
> sudo chmod 775 /var/www/html/uploads
> 
> # Fichiers de configuration sensibles
> sudo chmod 600 /etc/mysql/my.cnf
> ```

### Modifier le propriétaire et le groupe

```bash
# Changer le propriétaire
sudo chown nouvel_user fichier.txt

# Changer le propriétaire et le groupe
sudo chown nouvel_user:nouveau_groupe fichier.txt

# Récursif (tout un répertoire)
sudo chown -R www-data:www-data /var/www/html

# Changer uniquement le groupe
sudo chgrp nouveau_groupe fichier.txt
```

### Permissions spéciales

**SUID (Set User ID) - bit 4000**

```bash
# Exécute le fichier avec les droits du propriétaire
chmod u+s /usr/bin/programme
chmod 4755 /usr/bin/programme

# Exemple : passwd utilise SUID pour modifier /etc/shadow
ls -l /usr/bin/passwd
# -rwsr-xr-x (notez le 's' à la place du 'x')
```

**SGID (Set Group ID) - bit 2000**

```bash
# Sur un fichier : exécute avec les droits du groupe
chmod g+s fichier

# Sur un répertoire : les nouveaux fichiers héritent du groupe
chmod g+s /var/www/html/shared
chmod 2775 /var/www/html/shared
```

**Sticky Bit - bit 1000**

```bash
# Seul le propriétaire peut supprimer ses fichiers (utile pour /tmp)
chmod +t /var/www/html/uploads
chmod 1777 /var/www/html/uploads

# Exemple : /tmp utilise le sticky bit
ls -ld /tmp
# drwxrwxrwt (notez le 't' à la fin)
```

### Configuration type pour un serveur LAMP

```bash
# 1. Créer un utilisateur dédié au développement web
sudo adduser webdev
sudo usermod -aG sudo,www-data webdev

# 2. Configurer les permissions du répertoire web
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# 3. Permettre au groupe www-data d'écrire dans certains dossiers
sudo chmod -R 775 /var/www/html/uploads
sudo chmod -R 775 /var/www/html/cache

# 4. Sécuriser les fichiers de configuration
sudo chmod 600 /var/www/html/config.php
sudo chown www-data:www-data /var/www/html/config.php

# 5. Appliquer SGID sur le répertoire web
sudo chmod g+s /var/www/html
```

### Vérification et audit des permissions

```bash
# Trouver les fichiers avec permissions trop larges
find /var/www/html -type f -perm -o+w

# Trouver les fichiers SUID/SGID (potentiellement dangereux)
find / -type f \( -perm -4000 -o -perm -2000 \) -ls 2>/dev/null

# Trouver les fichiers appartenant à un utilisateur
find /var/www -user www-data

# Trouver les fichiers sans propriétaire
find /var/www -nouser -o -nogroup
```

> [!tip] Astuce : Script de vérification rapide
> 
> ```bash
> # Créer un script pour vérifier les permissions web
> cat > check-web-perms.sh << 'EOF'
> #!/bin/bash
> echo "=== Vérification des permissions web ==="
> echo "Propriétaire de /var/www/html :"
> ls -ld /var/www/html
> echo -e "\nFichiers avec write pour others :"
> find /var/www/html -type f -perm -o+w
> echo -e "\nFichiers exécutables :"
> find /var/www/html -type f -perm -u+x
> EOF
> chmod +x check-web-perms.sh
> ```

---

## 🔥 Configuration du pare-feu

### Pourquoi un pare-feu ?

> [!info] Rôle du pare-feu Un pare-feu (firewall) contrôle le trafic réseau entrant et sortant, permettant uniquement les connexions autorisées. C'est la première ligne de défense contre les attaques réseau.

### Choisir entre firewalld et ufw

|Critère|firewalld|ufw|
|---|---|---|
|**Distributions**|RedHat, CentOS, Rocky, Fedora|Ubuntu, Debian|
|**Backend**|nftables/iptables|iptables|
|**Interface**|firewall-cmd, GUI|ufw (ligne de commande)|
|**Complexité**|Plus avancé (zones)|Plus simple|
|**Performance**|Rechargement dynamique|Nécessite redémarrage|

---

## 🛡️ UFW (Uncomplicated Firewall) - Ubuntu/Debian

### Installation et activation

```bash
# Installer ufw (généralement préinstallé sur Ubuntu)
sudo apt install ufw -y

# Vérifier le statut
sudo ufw status

# Vérifier la version
sudo ufw version
```

**Activation du pare-feu**

```bash
# IMPORTANT : Autoriser SSH AVANT d'activer le pare-feu
sudo ufw allow ssh
# ou spécifier le port
sudo ufw allow 22/tcp

# Activer le pare-feu
sudo ufw enable

# Vérifier le statut détaillé
sudo ufw status verbose
```

> [!warning] Risque de blocage SSH **TOUJOURS** autoriser SSH avant d'activer UFW, sinon vous perdrez l'accès à votre serveur distant !
> 
> ```bash
> sudo ufw allow 22/tcp
> sudo ufw enable
> ```

### Configuration par défaut

```bash
# Définir les politiques par défaut
sudo ufw default deny incoming   # Bloquer tout le trafic entrant
sudo ufw default allow outgoing  # Autoriser tout le trafic sortant

# Vérifier les politiques
sudo ufw status verbose
```

### Autoriser les services pour LAMP

```bash
# SSH (port 22)
sudo ufw allow ssh
# ou
sudo ufw allow 22/tcp

# HTTP (port 80)
sudo ufw allow http
# ou
sudo ufw allow 80/tcp

# HTTPS (port 443)
sudo ufw allow https
# ou
sudo ufw allow 443/tcp

# MySQL (port 3306) - UNIQUEMENT si accès distant nécessaire
sudo ufw allow 3306/tcp
```

> [!warning] Sécurité MySQL N'autorisez MySQL (3306) que si absolument nécessaire. Par défaut, MySQL ne devrait être accessible qu'en local.

### Règles avancées avec UFW

**Autoriser depuis une IP spécifique**

```bash
# Autoriser SSH uniquement depuis une IP
sudo ufw allow from 192.168.1.100 to any port 22 proto tcp

# Autoriser MySQL uniquement depuis un réseau privé
sudo ufw allow from 192.168.1.0/24 to any port 3306 proto tcp

# Autoriser tout le trafic depuis une IP de confiance
sudo ufw allow from 192.168.1.50
```

**Autoriser sur une interface réseau spécifique**

```bash
# Lister les interfaces réseau
ip addr show

# Autoriser sur une interface spécifique
sudo ufw allow in on eth0 to any port 80 proto tcp
sudo ufw allow in on eth1 to any port 3306 proto tcp
```

**Limiter les connexions (protection anti-brute force)**

```bash
# Limiter SSH : max 6 connexions en 30 secondes par IP
sudo ufw limit ssh
# ou
sudo ufw limit 22/tcp

# Afficher les règles avec numéros
sudo ufw status numbered
```

> [!tip] Protection SSH La règle `ufw limit ssh` protège contre les attaques par force brute en limitant les tentatives de connexion.

### Bloquer des connexions

```bash
# Bloquer une IP spécifique
sudo ufw deny from 192.168.1.100

# Bloquer un port
sudo ufw deny 23/tcp

# Bloquer un réseau
sudo ufw deny from 10.0.0.0/8
```

### Gérer les règles UFW

**Afficher les règles**

```bash
# Statut simple
sudo ufw status

# Statut détaillé
sudo ufw status verbose

# Afficher avec numéros (pour suppression)
sudo ufw status numbered

# Afficher les règles brutes (iptables)
sudo ufw show raw
```

**Supprimer des règles**

```bash
# Méthode 1 : Par numéro
sudo ufw status numbered
sudo ufw delete 3

# Méthode 2 : Par commande exacte
sudo ufw delete allow 80/tcp

# Méthode 3 : Par description
sudo ufw delete allow from 192.168.1.100
```

**Réinitialiser le pare-feu**

```bash
# Désactiver UFW
sudo ufw disable

# Supprimer toutes les règles
sudo ufw reset

# Reconfigurer depuis zéro
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable
```

### Logs et débogage UFW

```bash
# Activer les logs
sudo ufw logging on

# Niveau de logs (off, low, medium, high, full)
sudo ufw logging medium

# Voir les logs en temps réel
sudo tail -f /var/log/ufw.log

# Filtrer les connexions bloquées
sudo grep "UFW BLOCK" /var/log/ufw.log

# Statistiques
sudo ufw status verbose
```

### Configuration avancée de UFW

**Fichiers de configuration**

```bash
# Configuration principale
sudo nano /etc/ufw/ufw.conf

# Règles utilisateur
ls /etc/ufw/user.rules
ls /etc/ufw/user6.rules

# Règles système
ls /etc/ufw/before.rules
ls /etc/ufw/after.rules
```

**Créer des applications prédéfinies**

```bash
# Créer un profil d'application
sudo nano /etc/ufw/applications.d/lamp

# Contenu du fichier :
[LAMP Full]
title=LAMP Stack
description=Linux Apache MySQL PHP
ports=80,443/tcp

# Recharger les profils
sudo ufw app update LAMP

# Utiliser le profil
sudo ufw allow "LAMP Full"

# Lister les applications disponibles
sudo ufw app list
```

---

## 🔥 Firewalld - RedHat/CentOS/Rocky

### Installation et activation

```bash
# Installer firewalld
sudo dnf install firewalld -y
# ou pour CentOS 7
sudo yum install firewalld -y

# Démarrer et activer au démarrage
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Vérifier le statut
sudo firewall-cmd --state
sudo systemctl status firewalld
```

### Concept de zones dans firewalld

> [!info] Zones firewalld Firewalld utilise des **zones** pour définir le niveau de confiance des connexions réseau. Chaque interface réseau est assignée à une zone.

**