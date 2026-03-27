

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

La configuration du pare-feu est **la première ligne de défense** de votre serveur LAMP. Un pare-feu mal configuré peut exposer votre base de données ou bloquer vos utilisateurs légitimes. Cette section couvre la configuration essentielle pour sécuriser votre stack tout en permettant un accès web normal.

> [!info] Pourquoi c'est crucial
> 
> - **Prévention des intrusions** : Bloquer les accès non autorisés
> - **Réduction de la surface d'attaque** : Limiter les points d'entrée
> - **Conformité** : Respecter les standards de sécurité (PCI-DSS, RGPD, etc.)
> - **Protection de MySQL** : Empêcher l'accès direct à la base de données depuis Internet

---

## 🔌 Comprendre les ports réseau

### Qu'est-ce qu'un port ?

Un port est un **point d'entrée logique** pour les connexions réseau. Chaque service écoute sur un port spécifique.

|Port|Service|Protocole|Usage dans LAMP|
|---|---|---|---|
|**80**|HTTP|TCP|Trafic web non chiffré|
|**443**|HTTPS|TCP|Trafic web chiffré (SSL/TLS)|
|**3306**|MySQL/MariaDB|TCP|Accès à la base de données|
|22|SSH|TCP|Administration à distance|

> [!warning] Règle d'or **Fermez tous les ports par défaut, ouvrez uniquement ceux qui sont strictement nécessaires.**

### Ports pour LAMP : stratégie de sécurité

```
┌─────────────────────────────────────┐
│         INTERNET PUBLIC             │
└──────────┬──────────────────────────┘
           │
      ✅ Port 80/443 OUVERTS
      (Accès web nécessaire)
           │
┌──────────▼──────────────────────────┐
│      SERVEUR WEB (Apache)           │
│  - Reçoit requêtes HTTP/HTTPS       │
│  - Sert les pages PHP               │
└──────────┬──────────────────────────┘
           │
   Connexion LOCALE uniquement
   (127.0.0.1 ou socket)
           │
┌──────────▼──────────────────────────┐
│      BASE DE DONNÉES (MySQL)        │
│  ❌ Port 3306 FERMÉ depuis Internet │
│  ✅ Accessible uniquement en local  │
└─────────────────────────────────────┘
```

---

## 🌐 Ouverture des ports 80 et 443

### Pourquoi ouvrir ces ports ?

- **Port 80 (HTTP)** : Permet l'accès web standard et les redirections vers HTTPS
- **Port 443 (HTTPS)** : Trafic web sécurisé chiffré, **obligatoire pour les sites modernes**

> [!tip] Bonne pratique moderne Même si vous ouvrez le port 80, configurez toujours une **redirection automatique vers HTTPS** (port 443) pour sécuriser tout le trafic.

### Vérifier l'état des ports

Avant toute modification, vérifiez quels ports sont actuellement ouverts :

```bash
# Voir les ports en écoute
sudo ss -tlnp | grep -E ':(80|443|3306)'

# Vérifier les services actifs
sudo netstat -tuln | grep -E ':(80|443|3306)'
```

> [!example] Sortie typique
> 
> ```
> tcp   LISTEN   0   128   *:80    *:*    users:(("apache2",pid=1234))
> tcp   LISTEN   0   128   *:443   *:*    users:(("apache2",pid=1234))
> tcp   LISTEN   0   80    127.0.0.1:3306   *:*    users:(("mysqld",pid=5678))
> ```
> 
> ✅ **Bon** : MySQL n'écoute que sur 127.0.0.1 (local)  
> ⚠️ Si vous voyez `0.0.0.0:3306` ou `*:3306`, MySQL est accessible depuis l'extérieur !

---

## 🔒 Fermeture du port 3306 en externe

### Pourquoi fermer ce port ?

> [!warning] Danger critique Laisser le port MySQL ouvert sur Internet est une **faille de sécurité majeure** :
> 
> - Attaques par force brute sur les mots de passe
> - Exploitation de vulnérabilités MySQL
> - Accès direct aux données sensibles
> - Exposition aux scans automatisés de hackers

### Configuration MySQL pour liaison locale uniquement

Avant même de configurer le pare-feu, **configurez MySQL pour n'écouter qu'en local** :

```bash
# Éditer la configuration MySQL
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# OU pour MariaDB/CentOS
sudo nano /etc/my.cnf.d/mariadb-server.cnf
```

Cherchez et modifiez la ligne `bind-address` :

```ini
[mysqld]
# ✅ BON : Écoute uniquement sur localhost
bind-address = 127.0.0.1

# ❌ MAUVAIS : Écoute sur toutes les interfaces
# bind-address = 0.0.0.0
```

> [!tip] Alternative moderne Pour MariaDB 10.3+ et MySQL 8.0+, vous pouvez aussi utiliser :
> 
> ```ini
> bind-address = localhost
> ```

Redémarrez MySQL pour appliquer :

```bash
# Ubuntu/Debian
sudo systemctl restart mysql

# CentOS/RHEL
sudo systemctl restart mariadb
```

Vérifiez la configuration :

```bash
sudo ss -tlnp | grep 3306
```

Vous devriez voir `127.0.0.1:3306` et **jamais** `0.0.0.0:3306`.

### Règles pare-feu pour MySQL

Même avec la liaison locale, **ajoutez une règle pare-feu de sécurité supplémentaire** (défense en profondeur) :

```bash
# UFW (Ubuntu/Debian)
sudo ufw deny 3306/tcp

# Firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --remove-service=mysql
sudo firewall-cmd --reload
```

> [!info] Exception : Serveur de base de données distant Si vous avez une architecture séparée (serveur web ≠ serveur BDD), vous devrez autoriser **uniquement l'IP du serveur web** :
> 
> ```bash
> # UFW : Autoriser uniquement depuis le serveur web (IP 192.168.1.100)
> sudo ufw allow from 192.168.1.100 to any port 3306 proto tcp
> 
> # Firewalld : Zone riche pour IP spécifique
> sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.100" port port="3306" protocol="tcp" accept'
> ```

---

## 🛡️ Gestion avec UFW (Ubuntu/Debian)

### Introduction à UFW

**UFW (Uncomplicated Firewall)** est l'interface simplifiée d'iptables utilisée par défaut sur Ubuntu et Debian.

> [!info] Avantages d'UFW
> 
> - Syntaxe simple et intuitive
> - Profils d'application prédéfinis
> - Activation/désactivation facile
> - Logs clairs et lisibles

### Installation et activation

```bash
# Installation (si non présent)
sudo apt update
sudo apt install ufw

# Vérifier le statut
sudo ufw status verbose
```

> [!warning] Piège SSH **Avant d'activer UFW**, autorisez SSH sinon vous serez déconnecté et bloqué !
> 
> ```bash
> sudo ufw allow 22/tcp
> # OU avec le profil
> sudo ufw allow OpenSSH
> ```

### Configuration complète pour LAMP

```bash
# 1. Réinitialiser UFW (optionnel, si vous repartez de zéro)
sudo ufw --force reset

# 2. Définir les politiques par défaut (tout bloquer sauf sortant)
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 3. Autoriser SSH (CRITIQUE - faites-le d'abord !)
sudo ufw allow 22/tcp
# OU si vous utilisez un port SSH personnalisé (ex: 2222)
# sudo ufw allow 2222/tcp

# 4. Autoriser HTTP et HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# OU utiliser les profils Apache
sudo ufw allow 'Apache Full'  # Autorise 80 et 443

# 5. BLOQUER explicitement MySQL (optionnel mais recommandé)
sudo ufw deny 3306/tcp

# 6. Activer UFW
sudo ufw enable

# 7. Vérifier la configuration
sudo ufw status numbered
```

> [!example] Sortie typique de `ufw status numbered`
> 
> ```
> Status: active
> 
>      To                         Action      From
>      --                         ------      ----
> [ 1] 22/tcp                     ALLOW IN    Anywhere
> [ 2] 80/tcp                     ALLOW IN    Anywhere
> [ 3] 443/tcp                    ALLOW IN    Anywhere
> [ 4] 3306/tcp                   DENY IN     Anywhere
> ```

### Profils d'application UFW

UFW propose des profils prédéfinis pour les applications courantes :

```bash
# Lister les profils disponibles
sudo ufw app list

# Voir les détails d'un profil
sudo ufw app info 'Apache Full'
```

Profils Apache courants :

- **Apache** : Port 80 uniquement
- **Apache Secure** : Port 443 uniquement
- **Apache Full** : Ports 80 et 443

```bash
# Utilisation recommandée
sudo ufw allow 'Apache Full'
```

### Commandes UFW utiles

```bash
# Voir le statut détaillé
sudo ufw status verbose

# Désactiver temporairement
sudo ufw disable

# Réactiver
sudo ufw enable

# Supprimer une règle par numéro
sudo ufw delete 4  # Supprime la règle n°4

# Supprimer une règle par spécification
sudo ufw delete allow 80/tcp

# Réinitialiser toutes les règles
sudo ufw reset

# Voir les logs
sudo tail -f /var/log/ufw.log
```

### Configuration avancée UFW

#### Limiter les tentatives de connexion (protection brute force)

```bash
# Limite les connexions SSH (max 6 tentatives en 30 secondes)
sudo ufw limit 22/tcp
```

#### Autoriser une IP spécifique

```bash
# Autoriser tout le trafic depuis une IP
sudo ufw allow from 203.0.113.100

# Autoriser une IP sur un port spécifique
sudo ufw allow from 203.0.113.100 to any port 3306
```

#### Autoriser un sous-réseau

```bash
# Autoriser un réseau local (ex: pour un VPN)
sudo ufw allow from 10.0.0.0/8 to any port 3306
```

> [!tip] Astuce pour le debug Activez les logs UFW pour surveiller les tentatives bloquées :
> 
> ```bash
> sudo ufw logging on
> sudo ufw logging medium  # Niveau de détail : low, medium, high, full
> ```

---

## 🔥 Gestion avec Firewalld (CentOS/RHEL/Fedora)

### Introduction à Firewalld

**Firewalld** est le pare-feu dynamique par défaut sur CentOS, RHEL et Fedora. Il utilise le concept de **zones** pour gérer les règles.

> [!info] Concepts clés de Firewalld
> 
> - **Zones** : Ensembles de règles (public, trusted, internal, etc.)
> - **Services** : Profils prédéfinis (http, https, mysql, ssh)
> - **Permanent vs Runtime** : Modifications temporaires ou persistantes

### Installation et activation

```bash
# Installation (normalement déjà présent)
sudo dnf install firewalld  # Fedora/RHEL 8+
# OU
sudo yum install firewalld  # CentOS 7

# Démarrer et activer au boot
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Vérifier le statut
sudo firewall-cmd --state
```

### Comprendre les zones Firewalld

```bash
# Lister toutes les zones
sudo firewall-cmd --get-zones

# Voir la zone par défaut
sudo firewall-cmd --get-default-zone

# Voir la configuration d'une zone
sudo firewall-cmd --zone=public --list-all
```

Zones courantes :

- **public** : Zone par défaut, accès restreint (recommandée pour serveurs web)
- **trusted** : Tout le trafic autorisé (dangereuse pour Internet)
- **internal** : Pour réseaux internes de confiance
- **dmz** : Pour serveurs exposés avec accès limité

> [!tip] Bonne pratique Utilisez la zone **public** pour votre serveur LAMP accessible depuis Internet.

### Configuration complète pour LAMP

```bash
# 1. Vérifier la zone active
sudo firewall-cmd --get-active-zones

# 2. Autoriser HTTP et HTTPS (permanent)
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https

# 3. Autoriser SSH (si pas déjà fait)
sudo firewall-cmd --permanent --zone=public --add-service=ssh

# 4. SUPPRIMER le service MySQL s'il est ouvert
sudo firewall-cmd --permanent --zone=public --remove-service=mysql

# 5. Bloquer explicitement le port 3306
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port port="3306" protocol="tcp" reject'

# 6. Recharger pour appliquer les modifications
sudo firewall-cmd --reload

# 7. Vérifier la configuration
sudo firewall-cmd --zone=public --list-all
```

> [!example] Sortie typique de `--list-all`
> 
> ```
> public (active)
>   target: default
>   interfaces: eth0
>   services: dhcpv6-client http https ssh
>   ports: 
>   protocols: 
>   rich rules: 
>     rule family="ipv4" port port="3306" protocol="tcp" reject
> ```

### Services Firewalld prédéfinis

```bash
# Lister tous les services disponibles
sudo firewall-cmd --get-services

# Voir les détails d'un service
sudo firewall-cmd --info-service=http
```

Services importants pour LAMP :

- **http** : Port 80
- **https** : Port 443
- **mysql** : Port 3306 (à NE PAS autoriser depuis Internet)
- **ssh** : Port 22

### Commandes Firewalld utiles

```bash
# Voir toutes les règles actives
sudo firewall-cmd --list-all

# Recharger sans perdre les connexions actives
sudo firewall-cmd --reload

# Recharger complètement (coupe les connexions)
sudo firewall-cmd --complete-reload

# Voir les règles permanentes
sudo firewall-cmd --permanent --list-all

# Supprimer un service
sudo firewall-cmd --permanent --remove-service=http
sudo firewall-cmd --reload
```

### Configuration avancée Firewalld

#### Autoriser des ports personnalisés

```bash
# Ajouter un port spécifique
sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
sudo firewall-cmd --reload

# Ajouter une plage de ports
sudo firewall-cmd --permanent --zone=public --add-port=8000-8100/tcp
```

#### Rich Rules (règles avancées)

Les **rich rules** permettent un contrôle granulaire :

```bash
# Autoriser une IP spécifique sur MySQL
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.100" port port="3306" protocol="tcp" accept'

# Autoriser un sous-réseau
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.0.0.0/8" port port="3306" protocol="tcp" accept'

# Bloquer une IP malveillante
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="203.0.113.50" reject'

# Limiter le taux de connexion (protection brute force)
sudo firewall-cmd --permanent --add-rich-rule='rule service name="ssh" limit value="5/m" accept'
```

#### Mode panic (urgence)

En cas d'attaque, bloquez tout le trafic instantanément :

```bash
# Activer le mode panic (coupe TOUT, même SSH !)
sudo firewall-cmd --panic-on

# Désactiver le mode panic
sudo firewall-cmd --panic-off

# Vérifier si le mode panic est actif
sudo firewall-cmd --query-panic
```

> [!warning] Attention au mode panic Le mode panic **coupe toutes les connexions**, y compris SSH. Utilisez-le uniquement si vous avez un accès console direct ou IPMI.

#### Logging des paquets bloqués

```bash
# Activer les logs pour les paquets rejetés
sudo firewall-cmd --set-log-denied=all
sudo firewall-cmd --reload

# Voir les logs
sudo journalctl -u firewalld -f
# OU
sudo tail -f /var/log/messages | grep -i firewall
```

Options de log : `off`, `all`, `unicast`, `broadcast`, `multicast`

---

## ✅ Bonnes pratiques

### Principe du moindre privilège

> [!tip] Règle d'or **Tout est interdit par défaut, on n'autorise que le strict nécessaire.**

```bash
# UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Firewalld
# La zone 'public' fait déjà cela par défaut
```

### Défense en profondeur (layered security)

Ne comptez pas uniquement sur le pare-feu :

1. **Pare-feu réseau** : Bloquer les ports (couche réseau)
2. **Configuration MySQL** : `bind-address = 127.0.0.1` (couche application)
3. **Authentification forte** : Mots de passe robustes, clés SSH (couche accès)
4. **Monitoring** : Surveillance des tentatives d'intrusion (couche détection)

### Tester la configuration

Après avoir configuré le pare-feu, **testez depuis l'extérieur** :

```bash
# Depuis une autre machine ou un service en ligne (shodan.io, nmap)
nmap -p 80,443,3306 votre-ip-publique
```

> [!example] Résultat attendu
> 
> ```
> PORT     STATE    SERVICE
> 80/tcp   open     http
> 443/tcp  open     https
> 3306/tcp filtered mysql    # Ou 'closed' - les deux sont bons
> ```
> 
> ✅ **Parfait** : MySQL n'est pas accessible  
> ❌ **Problème** : Si 3306 montre `open`, votre BDD est exposée !

### Automatiser et documenter

```bash
# Créer un script de configuration
sudo nano /root/configure-firewall.sh
```

```bash
#!/bin/bash
# Configuration pare-feu LAMP - À exécuter après installation

echo "Configuration du pare-feu pour stack LAMP..."

if command -v ufw &> /dev/null; then
    echo "Détection UFW..."
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw deny 3306/tcp
    ufw --force enable
    ufw status verbose
elif command -v firewall-cmd &> /dev/null; then
    echo "Détection Firewalld..."
    firewall-cmd --permanent --zone=public --add-service=ssh
    firewall-cmd --permanent --zone=public --add-service=http
    firewall-cmd --permanent --zone=public --add-service=https
    firewall-cmd --permanent --zone=public --remove-service=mysql
    firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port port="3306" protocol="tcp" reject'
    firewall-cmd --reload
    firewall-cmd --list-all
else
    echo "Aucun pare-feu détecté (UFW ou Firewalld)"
    exit 1
fi

echo "Configuration terminée !"
```

```bash
# Rendre le script exécutable
sudo chmod +x /root/configure-firewall.sh

# Exécuter
sudo /root/configure-firewall.sh
```

### Surveillance et maintenance

```bash
# UFW : Surveiller les tentatives bloquées
sudo tail -f /var/log/ufw.log

# Firewalld : Surveiller les rejets
sudo journalctl -u firewalld -f --since "10 minutes ago"

# Analyser les IPs suspectes
sudo grep -i "BLOCK" /var/log/ufw.log | awk '{print $12}' | sort | uniq -c | sort -rn | head -10
```

> [!tip] Automatiser la surveillance Configurez **Fail2Ban** pour bannir automatiquement les IPs malveillantes après plusieurs tentatives échouées (mentionné ici, détaillé dans d'autres sections du cours).

### Checklist de sécurité pare-feu

Avant de mettre en production, vérifiez :

- [ ] Ports 80 et 443 ouverts et fonctionnels
- [ ] Port 3306 fermé depuis Internet (test nmap externe)
- [ ] MySQL configuré avec `bind-address = 127.0.0.1`
- [ ] SSH accessible (si vous gérez le serveur à distance)
- [ ] Politiques par défaut configurées (deny incoming, allow outgoing)
- [ ] Logs pare-feu activés
- [ ] Documentation créée (quelles règles, pourquoi)
- [ ] Script de configuration sauvegardé
- [ ] Connexion de secours testée (console, IPMI, KVM)

---

## 🎓 Récapitulatif

|Élément|Configuration|Commande clé|
|---|---|---|
|**HTTP**|✅ Ouvert|`ufw allow 80/tcp` / `firewall-cmd --add-service=http`|
|**HTTPS**|✅ Ouvert|`ufw allow 443/tcp` / `firewall-cmd --add-service=https`|
|**MySQL**|❌ Fermé|`ufw deny 3306/tcp` / `firewall-cmd --remove-service=mysql`|
|**MySQL bind**|127.0.0.1|`bind-address = 127.0.0.1` dans my.cnf|
|**SSH**|✅ Ouvert|`ufw allow 22/tcp` / `firewall-cmd --add-service=ssh`|

> [!success] Objectif atteint Votre serveur LAMP est maintenant protégé au niveau réseau :
> 
> - Les utilisateurs peuvent accéder à vos sites web (80/443)
> - Votre base de données est inaccessible depuis Internet (3306)
> - Vous pouvez administrer le serveur à distance (22)
> - Le principe du moindre privilège est appliqué

---

_Cours créé pour Obsidian - Stack LAMP - Sécurisation réseau_ 🔒