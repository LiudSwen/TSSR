

## 📚 Table des matières

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

## Introduction

La gestion des règles UFW constitue le cœur de la configuration du pare-feu. Comprendre comment autoriser, refuser ou limiter le trafic réseau est essentiel pour sécuriser efficacement un système Linux. Cette partie détaille les différentes méthodes pour contrôler les flux réseau entrants et sortants.

> [!info] Philosophie UFW UFW adopte une approche par défaut restrictive : tout est bloqué sauf ce qui est explicitement autorisé. Cette philosophie suit le principe de sécurité du "moindre privilège".

---

## Règles de base (allow, deny, reject)

### 🔓 Allow - Autoriser le trafic

La commande `allow` autorise le trafic réseau à passer à travers le pare-feu.

```bash
# Syntaxe générale
sudo ufw allow [options] <port/service>

# Exemples pratiques
sudo ufw allow 22          # Autorise le port 22 (TCP et UDP)
sudo ufw allow 80/tcp      # Autorise uniquement le port 80 en TCP
sudo ufw allow from 192.168.1.100  # Autorise tout trafic depuis cette IP
```

> [!example] Cas d'usage Utilisez `allow` pour :
> 
> - Ouvrir des services essentiels (SSH, HTTP, HTTPS)
> - Autoriser des adresses IP de confiance
> - Permettre l'accès à des applications spécifiques

### 🚫 Deny - Refuser silencieusement

La commande `deny` bloque le trafic sans envoyer de réponse à l'émetteur. Le paquet est simplement "avalé".

```bash
# Syntaxe générale
sudo ufw deny [options] <port/service>

# Exemples pratiques
sudo ufw deny 23           # Bloque Telnet
sudo ufw deny from 10.0.0.50  # Bloque une IP spécifique
sudo ufw deny out 25/tcp   # Bloque les connexions sortantes sur le port 25 (SMTP)
```

> [!warning] Différence avec reject `deny` ne répond rien à l'émetteur, qui devra attendre un timeout. C'est plus discret mais peut ralentir les scans.

### ❌ Reject - Refuser avec notification

La commande `reject` bloque le trafic et envoie un message d'erreur explicite à l'émetteur (ICMP port unreachable).

```bash
# Syntaxe générale
sudo ufw reject [options] <port/service>

# Exemples pratiques
sudo ufw reject 3389       # Rejette RDP avec notification
sudo ufw reject from 172.16.0.0/12  # Rejette une plage IP
sudo ufw reject out to 8.8.8.8  # Rejette les connexions vers cette IP
```

> [!tip] Quand utiliser reject ? Préférez `reject` pour :
> 
> - Les réseaux locaux où la réactivité est importante
> - Le débogage (l'émetteur sait immédiatement que c'est bloqué)
> - Éviter les timeouts inutiles

### 📊 Comparaison : deny vs reject

|Critère|deny|reject|
|---|---|---|
|**Réponse**|Aucune|ICMP error|
|**Discrétion**|Maximum|Moyenne|
|**Rapidité**|Timeout complet|Réponse immédiate|
|**Usage**|Internet public|Réseaux internes|
|**Scans**|Plus long à scanner|Détection rapide|

---

## Ouverture et fermeture de ports

### 🔢 Gestion des ports individuels

```bash
# Ouvrir un port spécifique
sudo ufw allow 8080/tcp              # Port unique en TCP
sudo ufw allow 53                    # Port 53 (TCP et UDP)
sudo ufw allow 1194/udp              # Port unique en UDP

# Fermer un port
sudo ufw deny 445/tcp                # Bloque SMB
sudo ufw delete allow 8080/tcp       # Supprime une règle d'autorisation
```

> [!info] Protocole par défaut Sans spécification, UFW applique la règle aux protocoles TCP **et** UDP. Soyez explicite pour éviter les surprises.

### 📦 Plages de ports

Pour ouvrir plusieurs ports consécutifs, utilisez la notation de plage :

```bash
# Syntaxe : port_debut:port_fin/protocole
sudo ufw allow 6000:6010/tcp         # Plage de 11 ports TCP
sudo ufw allow 30000:30100/udp       # Plage pour services dynamiques
sudo ufw deny 137:139/tcp            # Bloque NetBIOS

# Exemple avec application réelle
sudo ufw allow 5900:5910/tcp         # Plage VNC pour plusieurs bureaux
```

> [!warning] Performance Les plages très larges peuvent impacter les performances. Privilégiez des règles spécifiques quand c'est possible.

### 🎯 Règles avec source/destination

Combinez ports et adresses IP pour un contrôle précis :

```bash
# Autoriser un port depuis une IP spécifique
sudo ufw allow from 192.168.1.50 to any port 22

# Autoriser une plage IP sur un port
sudo ufw allow from 10.0.0.0/24 to any port 3306

# Autoriser vers une interface spécifique
sudo ufw allow in on eth0 to any port 80

# Règle complexe : IP source + port destination + interface
sudo ufw allow in on enp0s3 from 172.16.0.0/16 to any port 443 proto tcp
```

> [!example] Scénario pratique Serveur MySQL accessible uniquement depuis le réseau local :
> 
> ```bash
> sudo ufw allow from 192.168.1.0/24 to any port 3306
> sudo ufw deny 3306  # Bloque tout autre accès
> ```

### 🔄 Modification des règles existantes

```bash
# Lister les règles avec numéros
sudo ufw status numbered

# Supprimer une règle par numéro
sudo ufw delete 3

# Supprimer une règle par description
sudo ufw delete allow 8080/tcp

# Remplacer une règle (supprimer puis recréer)
sudo ufw delete allow 22
sudo ufw allow from 192.168.1.0/24 to any port 22
```

---

## Règles par service

UFW reconnaît les services définis dans `/etc/services`, permettant une syntaxe plus lisible.

### 📋 Services courants

```bash
# Services standards
sudo ufw allow ssh          # Port 22 (TCP)
sudo ufw allow http         # Port 80 (TCP)
sudo ufw allow https        # Port 443 (TCP)
sudo ufw allow smtp         # Port 25 (TCP)
sudo ufw allow dns          # Port 53 (TCP et UDP)
sudo ufw allow ntp          # Port 123 (UDP)
sudo ufw allow mysql        # Port 3306 (TCP)
sudo ufw allow postgresql   # Port 5432 (TCP)

# Avec protocole spécifique
sudo ufw allow smtp/tcp
sudo ufw allow dns/udp
```

> [!tip] Lisibilité Préférez les noms de services dans vos configurations : c'est plus maintenable et autodocumenté.

### 🔍 Vérifier les services disponibles

```bash
# Lister les services reconnus par UFW
less /etc/services

# Rechercher un service spécifique
grep "^http" /etc/services
grep "^mysql" /etc/services

# Exemple de sortie
# http    80/tcp    www    # WorldWideWeb HTTP
# https   443/tcp           # http protocol over TLS/SSL
```

### 🎯 Profils d'application

UFW supporte des profils d'application prédéfinis situés dans `/etc/ufw/applications.d/`.

```bash
# Lister les profils disponibles
sudo ufw app list

# Voir les détails d'un profil
sudo ufw app info "Apache Full"
sudo ufw app info OpenSSH

# Utiliser un profil
sudo ufw allow "Apache Full"      # HTTP + HTTPS
sudo ufw allow "Apache Secure"    # HTTPS uniquement
sudo ufw allow OpenSSH            # SSH
sudo ufw allow Nginx              # Nginx (tous les ports configurés)
```

> [!example] Exemple de profil Apache Full
> 
> ```
> [Apache Full]
> title=Web Server (HTTP,HTTPS)
> description=Apache v2 Web Server
> ports=80,443/tcp
> ```

### ✏️ Créer des profils personnalisés

Créez vos propres profils pour des applications complexes :

```bash
# Créer un fichier de profil
sudo nano /etc/ufw/applications.d/mon-app

# Contenu du fichier
[MonApp]
title=Mon Application
description=Service personnalisé
ports=8080,8443/tcp|5000:5010/udp

[MonApp-Admin]
title=Interface Admin Mon Application
description=Accès administrateur
ports=9000/tcp

# Recharger les profils
sudo ufw app update MonApp

# Utiliser le profil
sudo ufw allow "MonApp"
sudo ufw allow from 192.168.1.0/24 app "MonApp-Admin"
```

---

## Limitation des connexions (limit)

La directive `limit` protège contre les attaques par force brute en limitant les tentatives de connexion.

### 🛡️ Principe de fonctionnement

```bash
# Syntaxe de base
sudo ufw limit <port/service>

# Exemples
sudo ufw limit 22/tcp       # Limite SSH
sudo ufw limit ssh          # Équivalent avec nom de service
sudo ufw limit from 0.0.0.0/0 to any port 22  # Limite explicite
```

> [!info] Mécanisme UFW bloque temporairement une IP qui tente plus de **6 connexions en 30 secondes**. Le blocage dure environ 30 secondes après la dernière tentative.

### 🎯 Cas d'usage typiques

```bash
# Protection SSH (cas le plus courant)
sudo ufw limit 22/tcp

# Protection FTP
sudo ufw limit 21/tcp

# Protection services d'authentification
sudo ufw limit 3389/tcp     # RDP
sudo ufw limit 5900/tcp     # VNC

# Avec restriction d'IP source
sudo ufw limit from 0.0.0.0/0 to any port 22 proto tcp
```

> [!warning] Limitation de limit Cette protection est basique et ne remplace pas des outils dédiés comme **fail2ban**. Pour une protection robuste contre le brute-force, combinez UFW avec fail2ban.

### 📊 Comportement détaillé

```bash
# Ce qui se passe en coulisses
# Règle limit crée deux règles iptables :
# 1. Limite le taux de nouvelles connexions
# 2. Log les tentatives excessives

# Visualiser les règles créées
sudo iptables -L -v -n | grep -A 5 "limit:"
```

|Tentatives|Temps|Résultat|
|---|---|---|
|1-6|< 30s|Autorisées|
|7+|< 30s|Bloquées temporairement|
|Après pause|> 30s|Compteur réinitialisé|

### 🔧 Alternatives et compléments

```bash
# Pour une protection plus robuste, installez fail2ban
sudo apt install fail2ban

# Combinaison recommandée
sudo ufw limit 22/tcp           # Protection basique UFW
# + fail2ban configuré          # Protection avancée
```

> [!tip] Stratégie recommandée
> 
> 1. Utilisez `ufw limit` sur SSH en première ligne de défense
> 2. Ajoutez fail2ban pour une protection avancée avec bannissement durable
> 3. Envisagez l'authentification par clés SSH plutôt que par mot de passe
> 4. Changez le port SSH par défaut (port knocking)

---

## Pièges courants et bonnes pratiques

### ⚠️ Pièges fréquents

> [!warning] Se bloquer soi-même
> 
> ```bash
> # DANGER : Ne faites JAMAIS ceci sur une machine distante
> sudo ufw enable              # Sans règle SSH autorisée
> 
> # CORRECT : Toujours autoriser SSH d'abord
> sudo ufw allow 22/tcp
> sudo ufw enable
> ```

> [!warning] Ordre des règles UFW évalue les règles dans l'ordre. La première correspondance s'applique.
> 
> ```bash
> # MAUVAIS ORDRE
> sudo ufw deny from 192.168.1.0/24    # Bloque tout le réseau
> sudo ufw allow from 192.168.1.50     # Ne sera jamais atteint
> 
> # BON ORDRE
> sudo ufw allow from 192.168.1.50     # Exception d'abord
> sudo ufw deny from 192.168.1.0/24    # Règle générale ensuite
> ```

> [!warning] Suppression de règles
> 
> ```bash
> # Vérifiez toujours avant de supprimer
> sudo ufw status numbered
> sudo ufw delete 5            # Attention au bon numéro
> 
> # Préférez la suppression explicite
> sudo ufw delete allow 8080/tcp  # Plus sûr et plus clair
> ```

### ✅ Bonnes pratiques essentielles

> [!tip] Documentation des règles Ajoutez des commentaires dans vos scripts de configuration :
> 
> ```bash
> #!/bin/bash
> # Configuration UFW - Serveur Web Production
> # Dernière mise à jour : 2025-01-15
> 
> # SSH - Accès admin uniquement depuis VPN
> sudo ufw allow from 10.8.0.0/24 to any port 22
> 
> # Web - Public
> sudo ufw allow 80/tcp   # HTTP
> sudo ufw allow 443/tcp  # HTTPS
> 
> # Base de données - Réseau interne uniquement
> sudo ufw allow from 172.16.0.0/16 to any port 3306
> ```

> [!tip] Principe du moindre privilège
> 
> ```bash
> # TROP PERMISSIF
> sudo ufw allow 3306/tcp
> 
> # MIEUX : Restreindre à la source nécessaire
> sudo ufw allow from 192.168.1.100 to any port 3306
> 
> # OPTIMAL : Avec interface spécifique
> sudo ufw allow in on eth1 from 192.168.1.100 to any port 3306
> ```

> [!tip] Gestion par environnement Utilisez des scripts versionnés pour chaque environnement :
> 
> ```bash
> # ufw-dev.sh
> sudo ufw allow from 192.168.1.0/24  # Réseau dev complet
> 
> # ufw-prod.sh
> sudo ufw allow from 10.0.1.50       # Uniquement serveur app
> sudo ufw limit 22/tcp                # Protection renforcée
> ```

### 🔍 Vérification et audit

```bash
# Vérifier la configuration actuelle
sudo ufw status verbose
sudo ufw status numbered

# Vérifier les règles iptables sous-jacentes
sudo iptables -L -n -v
sudo ip6tables -L -n -v

# Tester une connexion
nc -zv <ip> <port>           # Depuis une autre machine
telnet <ip> <port>           # Alternative

# Logger pour audit
sudo ufw logging on          # Active les logs
sudo tail -f /var/log/ufw.log  # Surveille en temps réel
```

### 🎯 Astuces avancées

> [!tip] Sauvegarde de configuration
> 
> ```bash
> # Exporter les règles
> sudo ufw status numbered > ufw-backup-$(date +%F).txt
> 
> # Script de restauration
> sudo cp /etc/ufw/user.rules /etc/ufw/user.rules.backup
> sudo cp /etc/ufw/user6.rules /etc/ufw/user6.rules.backup
> ```

> [!tip] Règles temporaires pour test
> 
> ```bash
> # Ajouter une règle temporaire
> sudo ufw allow from 203.0.113.50
> 
> # Tester
> # ... validation ...
> 
> # Retirer si non satisfaisant
> sudo ufw delete allow from 203.0.113.50
> ```

> [!tip] Gestion d'interfaces multiples
> 
> ```bash
> # Interface publique (Internet)
> sudo ufw deny in on eth0
> sudo ufw allow in on eth0 to any port 80
> sudo ufw allow in on eth0 to any port 443
> 
> # Interface privée (LAN)
> sudo ufw allow in on eth1
> ```

### 📝 Checklist de sécurité

Avant de mettre en production :

- [ ] SSH protégé (limit ou restriction IP)
- [ ] Uniquement les ports nécessaires ouverts
- [ ] Services internes accessibles uniquement du LAN
- [ ] Logs activés et surveillés
- [ ] Documentation des règles à jour
- [ ] Tests de connexion effectués
- [ ] Sauvegarde de la configuration
- [ ] Plan de rollback préparé

---

> [!success] Points clés à retenir
> 
> - `allow`, `deny`, et `reject` contrôlent le trafic différemment
> - Utilisez les noms de services pour plus de clarté
> - `limit` protège contre le brute-force basique
> - L'ordre des règles est crucial
> - Toujours tester avant de déployer en production
> - Privilégiez les restrictions par IP source quand possible