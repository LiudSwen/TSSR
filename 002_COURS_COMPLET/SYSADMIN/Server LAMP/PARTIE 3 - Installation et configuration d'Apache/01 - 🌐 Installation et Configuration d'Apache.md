

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

## 🎯 Introduction à Apache

**Apache HTTP Server** (communément appelé Apache) est le serveur web le plus populaire au monde. C'est un composant essentiel de la stack LAMP (Linux, Apache, MySQL, PHP).

> [!info] Qu'est-ce qu'Apache ? Apache est un logiciel serveur web open-source qui traite les requêtes HTTP et sert des pages web aux clients (navigateurs). Il peut servir du contenu statique (HTML, CSS, images) et dynamique (via PHP, Python, etc.).

**Pourquoi utiliser Apache ?**

- ✅ **Stabilité éprouvée** : Utilisé depuis 1995, extrêmement fiable
- ✅ **Flexibilité** : Système de modules extensible
- ✅ **Documentation riche** : Énorme communauté et ressources
- ✅ **Compatible** : Fonctionne avec la majorité des systèmes d'exploitation
- ✅ **Fichiers .htaccess** : Configuration au niveau des répertoires

---

## 📦 Installation d'Apache

### Installation via gestionnaire de paquets

L'installation d'Apache varie légèrement selon votre distribution Linux. Voici les commandes pour les distributions les plus courantes.

#### Sur Debian/Ubuntu

```bash
# Mise à jour de la liste des paquets
sudo apt update

# Installation d'Apache2
sudo apt install apache2 -y
```

> [!tip] Pourquoi "apache2" ? Sur les systèmes Debian/Ubuntu, le paquet s'appelle `apache2` car il s'agit de la version 2.x du serveur Apache HTTP.

#### Sur CentOS/RHEL/Fedora

```bash
# Sur CentOS/RHEL 7
sudo yum install httpd -y

# Sur CentOS/RHEL 8+ et Fedora
sudo dnf install httpd -y
```

> [!warning] Différence de nom Sur les distributions Red Hat, Apache s'appelle `httpd` (HTTP Daemon) au lieu d'`apache2`. C'est le même logiciel, seul le nom du paquet diffère.

#### Vérification de l'installation

```bash
# Vérifier la version installée
apache2 -v    # Sur Debian/Ubuntu
httpd -v      # Sur CentOS/RHEL/Fedora

# Afficher les modules compilés
apache2 -l    # Sur Debian/Ubuntu
httpd -l      # Sur CentOS/RHEL/Fedora
```

**Exemple de sortie :**

```bash
Server version: Apache/2.4.52 (Ubuntu)
Server built:   2024-01-09T19:36:14
```

> [!example] Que signifie cette sortie ?
> 
> - **Server version** : La version exacte d'Apache installée
> - **Server built** : La date de compilation du binaire
> - Ces informations sont utiles pour vérifier la compatibilité et les correctifs de sécurité

---

### Démarrage et vérification du service

Apache fonctionne comme un service système géré par `systemd` sur les distributions Linux modernes.

#### Commandes de base du service

```bash
# Démarrer Apache
sudo systemctl start apache2    # Debian/Ubuntu
sudo systemctl start httpd      # CentOS/RHEL

# Arrêter Apache
sudo systemctl stop apache2
sudo systemctl stop httpd

# Redémarrer Apache (arrêt puis démarrage)
sudo systemctl restart apache2
sudo systemctl restart httpd

# Recharger la configuration (sans couper les connexions)
sudo systemctl reload apache2
sudo systemctl reload httpd

# Vérifier le statut du service
sudo systemctl status apache2
sudo systemctl status httpd
```

> [!info] Restart vs Reload
> 
> - **restart** : Arrête complètement le service puis le redémarre. Les connexions actives sont coupées.
> - **reload** : Recharge la configuration sans interrompre le service. Les connexions actives continuent. **Privilégiez reload** quand vous modifiez la configuration.

#### Activer le démarrage automatique

Pour qu'Apache démarre automatiquement au boot du système :

```bash
# Activer le démarrage automatique
sudo systemctl enable apache2    # Debian/Ubuntu
sudo systemctl enable httpd      # CentOS/RHEL

# Désactiver le démarrage automatique
sudo systemctl disable apache2
sudo systemctl disable httpd

# Vérifier si le démarrage auto est activé
sudo systemctl is-enabled apache2
sudo systemctl is-enabled httpd
```

> [!tip] Bonne pratique Sur un serveur de production, **activez toujours** le démarrage automatique pour qu'Apache redémarre après un reboot du système.

#### Vérifier que le service fonctionne

```bash
# Méthode 1 : Vérifier le statut du service
sudo systemctl status apache2

# Méthode 2 : Vérifier les processus en cours
ps aux | grep apache2    # Debian/Ubuntu
ps aux | grep httpd      # CentOS/RHEL

# Méthode 3 : Vérifier les ports en écoute
sudo netstat -tulpn | grep :80
# OU avec ss (plus moderne)
sudo ss -tulpn | grep :80
```

**Exemple de sortie avec `systemctl status` :**

```bash
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2024-12-21 10:30:15 UTC; 5min ago
       Docs: https://httpd.apache.org/docs/2.4/
   Main PID: 1234 (apache2)
      Tasks: 55 (limit: 4915)
     Memory: 12.5M
```

> [!example] Interpréter la sortie
> 
> - **Loaded** : Le service est chargé et configuré
> - **enabled** : Le démarrage automatique est activé
> - **Active: active (running)** : Le service fonctionne correctement
> - **Main PID** : Le numéro du processus principal
> - Si vous voyez `failed` ou `inactive`, le service ne fonctionne pas

#### Vérifier les ports

Apache écoute par défaut sur le port 80 (HTTP) et 443 (HTTPS si SSL est configuré) :

```bash
# Lister les ports en écoute
sudo ss -tulpn | grep apache
sudo ss -tulpn | grep httpd

# Exemple de sortie attendue
# tcp   LISTEN 0  511  *:80   *:*   users:(("apache2",pid=1234))
```

> [!warning] Port déjà utilisé Si vous obtenez une erreur au démarrage d'Apache, vérifiez qu'aucun autre service n'utilise déjà le port 80 :
> 
> ```bash
> sudo lsof -i :80
> ```
> 
> D'autres services comme Nginx ou un serveur de développement peuvent bloquer ce port.

---

### Test de la page par défaut

Une fois Apache démarré, il sert automatiquement une page par défaut pour confirmer que l'installation fonctionne.

#### Tester depuis le serveur lui-même

```bash
# Tester avec curl
curl http://localhost

# Tester avec wget
wget http://localhost -O -

# Tester avec lynx (navigateur en ligne de commande)
lynx http://localhost
```

> [!example] Sortie attendue Vous devriez voir du code HTML contenant des balises comme `<html>`, `<title>It works!</title>` ou `Apache2 Ubuntu Default Page`.

#### Tester depuis un navigateur

1. **Obtenir l'adresse IP du serveur** :

```bash
# Afficher l'IP publique
ip addr show

# OU utiliser hostname
hostname -I

# OU sur les systèmes avec ifconfig
ifconfig
```

2. **Accéder à la page** :
    - Ouvrez votre navigateur
    - Accédez à : `http://ADRESSE_IP_DU_SERVEUR`
    - Exemple : `http://192.168.1.100`

> [!info] Page par défaut La page affichée dépend de votre distribution :
> 
> - **Debian/Ubuntu** : "Apache2 Ubuntu Default Page" avec des informations sur la configuration
> - **CentOS/RHEL** : Page de test Red Hat avec le logo d'Apache
> 
> Cette page confirme qu'Apache fonctionne correctement et sert des fichiers.

#### Emplacement de la page par défaut

```bash
# Sur Debian/Ubuntu
/var/www/html/index.html

# Sur CentOS/RHEL
/var/www/html/index.html

# Afficher le contenu
cat /var/www/html/index.html
```

> [!tip] Personnaliser la page Vous pouvez modifier ou remplacer ce fichier `index.html` pour créer votre propre page d'accueil :
> 
> ```bash
> sudo nano /var/www/html/index.html
> ```

#### Structure des répertoires Apache

|Répertoire|Description|Distribution|
|---|---|---|
|`/var/www/html/`|Racine web par défaut (Document Root)|Toutes|
|`/etc/apache2/`|Fichiers de configuration|Debian/Ubuntu|
|`/etc/httpd/`|Fichiers de configuration|CentOS/RHEL|
|`/var/log/apache2/`|Fichiers de logs|Debian/Ubuntu|
|`/var/log/httpd/`|Fichiers de logs|CentOS/RHEL|

> [!example] Document Root Le **Document Root** est le répertoire racine où Apache cherche les fichiers à servir. Par défaut, c'est `/var/www/html/`. Tous les fichiers placés ici sont accessibles via le navigateur.

#### Dépannage courant

**Problème : La page ne s'affiche pas**

```bash
# 1. Vérifier qu'Apache est démarré
sudo systemctl status apache2

# 2. Vérifier les logs d'erreur
sudo tail -f /var/log/apache2/error.log    # Debian/Ubuntu
sudo tail -f /var/log/httpd/error_log      # CentOS/RHEL

# 3. Vérifier le pare-feu
sudo ufw status                             # Ubuntu
sudo firewall-cmd --list-all               # CentOS/RHEL

# 4. Autoriser HTTP dans le pare-feu
sudo ufw allow 'Apache'                     # Ubuntu
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload                  # CentOS/RHEL
```

> [!warning] Pare-feu Le pare-feu est une cause fréquente de blocage. Assurez-vous que le port 80 est ouvert. Sur un cloud (AWS, Azure, GCP), vérifiez également les règles du groupe de sécurité.

**Problème : Erreur de permission**

```bash
# Vérifier les permissions du répertoire web
ls -la /var/www/html/

# Les permissions doivent être :
# drwxr-xr-x pour les répertoires (755)
# -rw-r--r-- pour les fichiers (644)

# Corriger si nécessaire
sudo chown -R www-data:www-data /var/www/html/    # Debian/Ubuntu
sudo chown -R apache:apache /var/www/html/        # CentOS/RHEL

sudo chmod -R 755 /var/www/html/
```

> [!tip] Utilisateur Apache Apache s'exécute sous un utilisateur spécifique :
> 
> - **www-data** sur Debian/Ubuntu
> - **apache** sur CentOS/RHEL
> 
> Les fichiers web doivent être lisibles par cet utilisateur.

---

## ✅ Vérification finale

Pour confirmer que tout fonctionne correctement :

```bash
# 1. Apache est démarré et activé
sudo systemctl is-active apache2
sudo systemctl is-enabled apache2

# 2. Le port 80 est en écoute
sudo ss -tulpn | grep :80

# 3. La page par défaut est accessible
curl -I http://localhost
# Devrait retourner : HTTP/1.1 200 OK

# 4. Aucune erreur dans les logs
sudo tail -20 /var/log/apache2/error.log
```

> [!tip] Commande de diagnostic complète Cette commande affiche un résumé de l'état d'Apache :
> 
> ```bash
> sudo apache2ctl -S    # Debian/Ubuntu
> sudo httpd -S         # CentOS/RHEL
> ```
> 
> Elle affiche les virtual hosts configurés et vérifie la syntaxe.

---

## 🎓 Pièges courants et bonnes pratiques

### ⚠️ Pièges courants

1. **Oublier de redémarrer après modification**
    
    - Après toute modification de configuration, pensez à recharger : `sudo systemctl reload apache2`
2. **Confusion entre restart et reload**
    
    - Utilisez `reload` pour éviter de couper les connexions actives
3. **Pare-feu non configuré**
    
    - N'oubliez pas d'ouvrir le port 80 (et 443 pour HTTPS)
4. **Permissions incorrectes**
    
    - Les fichiers doivent appartenir à l'utilisateur Apache et avoir les bonnes permissions
5. **SELinux sur CentOS/RHEL**
    
    - SELinux peut bloquer Apache. Vérifiez avec : `sudo getenforce`

### ✨ Bonnes pratiques

1. **Toujours activer le démarrage automatique**
    
    ```bash
    sudo systemctl enable apache2
    ```
    
2. **Surveiller les logs régulièrement**
    
    ```bash
    sudo tail -f /var/log/apache2/access.log
    sudo tail -f /var/log/apache2/error.log
    ```
    
3. **Tester la configuration avant de recharger**
    
    ```bash
    sudo apache2ctl configtest    # Debian/Ubuntu
    sudo httpd -t                 # CentOS/RHEL
    ```
    
4. **Créer un backup de la configuration**
    
    ```bash
    sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.backup
    ```
    
5. **Documenter vos modifications**
    
    - Ajoutez des commentaires dans les fichiers de configuration
    - Gardez un journal des changements

---

## 🔧 Astuces pratiques

### Commandes rapides

```bash
# Alias utile à ajouter dans ~/.bashrc
alias apache-restart='sudo systemctl restart apache2'
alias apache-reload='sudo systemctl reload apache2'
alias apache-status='sudo systemctl status apache2'
alias apache-logs='sudo tail -f /var/log/apache2/error.log'

# Recharger le .bashrc
source ~/.bashrc
```

### Vérification de la syntaxe

Avant de recharger Apache, vérifiez toujours la syntaxe :

```bash
# Test de configuration
sudo apache2ctl configtest

# Si OK, vous verrez :
# Syntax OK

# Sinon, le message d'erreur indiquera le fichier et la ligne problématiques
```

> [!warning] Ne jamais recharger sans tester Un fichier de configuration invalide peut empêcher Apache de démarrer. Testez toujours avec `configtest` avant de recharger.

### Commande tout-en-un pour l'installation

```bash
# Script d'installation complet (Debian/Ubuntu)
sudo apt update && \
sudo apt install apache2 -y && \
sudo systemctl start apache2 && \
sudo systemctl enable apache2 && \
sudo systemctl status apache2
```

---

**🎉 Félicitations !** Vous avez installé et configuré Apache avec succès. Votre serveur web est maintenant opérationnel et prêt à servir des pages.