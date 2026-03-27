

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

## Introduction

La protection contre les attaques SSH est cruciale car ce service est constamment ciblé par des tentatives d'intrusion automatisées (attaques par force brute, scans de ports, exploitation de vulnérabilités). Une configuration robuste combine plusieurs couches de défense pour réduire la surface d'attaque et bloquer les menaces avant qu'elles n'atteignent le service SSH.

> [!info] Approche en profondeur La sécurité SSH repose sur une stratégie de défense en profondeur : chaque mécanisme ajoute une couche de protection supplémentaire. L'objectif est de rendre toute tentative d'intrusion coûteuse en temps et en ressources pour l'attaquant.

---

## Configuration de fail2ban

### Principe et fonctionnement

Fail2ban est un outil de prévention d'intrusion qui analyse les fichiers de logs du système pour détecter les comportements suspects (tentatives de connexion échouées répétées, scans de ports, etc.) et bannir automatiquement les adresses IP malveillantes en ajoutant des règles au firewall.

**Fonctionnement en 4 étapes :**

1. **Surveillance** : Fail2ban lit en continu les logs définis (ex: `/var/log/auth.log`)
2. **Détection** : Il utilise des expressions régulières pour identifier les échecs d'authentification
3. **Comptage** : Il compte le nombre d'échecs par IP sur une période définie
4. **Action** : Si le seuil est dépassé, il bannit l'IP (via iptables/firewalld) pendant une durée déterminée

> [!warning] Prérequis Fail2ban nécessite que les logs SSH soient correctement configurés. Vérifiez que `SyslogFacility AUTH` et `LogLevel VERBOSE` (ou INFO minimum) sont définis dans `/etc/ssh/sshd_config`.

### Installation

```bash
# Debian/Ubuntu
sudo apt update
sudo apt install fail2ban -y

# RHEL/CentOS/Rocky/Alma
sudo dnf install epel-release -y
sudo dnf install fail2ban fail2ban-firewalld -y

# Arch Linux
sudo pacman -S fail2ban

# Démarrage et activation au boot
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Vérification du statut
sudo systemctl status fail2ban
```

### Configuration de base

Fail2ban utilise deux types de fichiers :

- **jail.conf** : Configuration par défaut (ne jamais modifier directement)
- **jail.local** : Surcharge personnalisée (prioritaire sur jail.conf)

```bash
# Copie du fichier de configuration par défaut
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Édition de la configuration personnalisée
sudo nano /etc/fail2ban/jail.local
```

**Configuration globale dans [DEFAULT] :**

```bash
[DEFAULT]
# Temps de bannissement en secondes (10 minutes ici)
bantime = 600

# Fenêtre temporelle pour compter les échecs (10 minutes)
findtime = 600

# Nombre d'échecs autorisés avant bannissement
maxretry = 5

# Backend de détection (auto, systemd, polling)
backend = auto

# Action par défaut (ban via iptables + email optionnel)
# action_ = ban seulement
# action_mw = ban + email avec whois
# action_mwl = ban + email avec whois + logs
action = %(action_)s

# IPs à ne jamais bannir (localhost, réseau local, IPs de confiance)
ignoreip = 127.0.0.1/8 ::1 192.168.1.0/24
```

> [!tip] Ignoreip Ajoutez toujours vos propres IPs d'administration dans `ignoreip` pour éviter de vous bannir vous-même. Utilisez la notation CIDR pour des plages d'adresses.

### Configuration spécifique SSH

La jail SSH est généralement pré-configurée mais désactivée par défaut. Activation et personnalisation :

```bash
[sshd]
# Activation de la protection SSH
enabled = true

# Port SSH à surveiller (adaptez si vous utilisez un port personnalisé)
port = ssh
# Ou spécifiez explicitement : port = 22,2222

# Protocole (tcp, udp, all)
protocol = tcp

# Filtre à utiliser (définit les regex de détection)
filter = sshd

# Fichier de log à surveiller
logpath = /var/log/auth.log
# Pour RHEL/CentOS : logpath = /var/log/secure

# Backend spécifique (optionnel, override du [DEFAULT])
backend = systemd

# Nombre maximum de tentatives (override du [DEFAULT])
maxretry = 3

# Temps de bannissement spécifique SSH (1 heure)
bantime = 3600

# Fenêtre de détection (10 minutes)
findtime = 600
```

> [!example] Configuration stricte recommandée Pour un serveur exposé sur Internet :
> 
> ```bash
> [sshd]
> enabled = true
> port = ssh
> filter = sshd
> logpath = /var/log/auth.log
> maxretry = 3
> bantime = 86400    # 24 heures
> findtime = 3600    # 1 heure
> ```

### Personnalisation avancée

**Bannissement progressif (récidive) :**

```bash
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
findtime = 600

# Bannissement initial : 1 heure
bantime = 3600

# Bannissement récidive : multiplie le temps de ban à chaque récidive
bantime.increment = true
bantime.factor = 2
bantime.multipliers = 1 2 4 8 16 32 64

# Bannissement maximum : 1 semaine
bantime.maxtime = 604800

# Formule de calcul des récidives
bantime.formula = ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)
```

**Création d'un filtre personnalisé :**

```bash
# Créer un nouveau filtre
sudo nano /etc/fail2ban/filter.d/sshd-aggressive.conf
```

```ini
[Definition]
# Détection plus agressive incluant les connexions interrompues
failregex = ^%(__prefix_line)s(?:error: PAM: )?[aA]uthentication (?:failure|error|failed) for .* from <HOST>( via \S+)?\s*$
            ^%(__prefix_line)s(?:error: PAM: )?User not known to the underlying authentication module for .* from <HOST>\s*$
            ^%(__prefix_line)sFailed \S+ for .*? from <HOST>(?: port \d*)?(?: ssh\d*)?$
            ^%(__prefix_line)sROOT LOGIN REFUSED.* FROM <HOST>$
            ^%(__prefix_line)s[iI](?:llegal|nvalid) user .* from <HOST>$
            ^%(__prefix_line)sUser .+ from <HOST> not allowed because not listed in AllowUsers$
            ^%(__prefix_line)sconnection (?:closed|refused) by <HOST>$
            ^%(__prefix_line)sReceived disconnect from <HOST>:.*:\s*\[preauth\]$

ignoreregex =
```

**Actions personnalisées (notifications) :**

```bash
# Créer une action personnalisée
sudo nano /etc/fail2ban/action.d/telegram-notify.conf
```

```ini
[Definition]
actionstart = 
actionstop = 
actioncheck = 
actionban = curl -s -X POST https://api.telegram.org/bot<TOKEN>/sendMessage -d chat_id=<CHAT_ID> -d text="🚨 Fail2ban: IP <ip> bannie pour <failures> tentatives sur <name>"
actionunban = 
```

### Gestion et surveillance

```bash
# Vérifier le statut global de fail2ban
sudo fail2ban-client status

# Statut d'une jail spécifique (sshd)
sudo fail2ban-client status sshd

# Statistiques détaillées
sudo fail2ban-client status sshd
# Output:
# Status for the jail: sshd
# |- Filter
# |  |- Currently failed: 2
# |  |- Total failed:     157
# |  `- File list:        /var/log/auth.log
# `- Actions
#    |- Currently banned: 3
#    |- Total banned:     45
#    `- Banned IP list:   192.168.1.50 10.0.0.15 203.0.113.42

# Bannir manuellement une IP
sudo fail2ban-client set sshd banip 203.0.113.42

# Débannir une IP
sudo fail2ban-client set sshd unbanip 203.0.113.42

# Recharger la configuration sans redémarrer
sudo fail2ban-client reload

# Recharger une jail spécifique
sudo fail2ban-client reload sshd

# Visualiser les logs de fail2ban
sudo tail -f /var/log/fail2ban.log

# Tester une expression régulière du filtre
sudo fail2ban-regex /var/log/auth.log /etc/fail2ban/filter.d/sshd.conf
```

> [!tip] Surveillance proactive Créez un script de surveillance quotidien :
> 
> ```bash
> #!/bin/bash
> echo "=== Rapport Fail2ban du $(date) ===" | mail -s "Rapport SSH" admin@example.com
> fail2ban-client status sshd | mail -a "From: fail2ban@server" admin@example.com
> ```

---

## Limitation des tentatives de connexion

La configuration SSH native offre plusieurs directives pour limiter les tentatives de connexion et réduire l'exposition aux attaques par force brute.

### MaxAuthTries

Définit le nombre maximum de tentatives d'authentification autorisées par connexion.

```bash
# Dans /etc/ssh/sshd_config
MaxAuthTries 3
```

**Détails du fonctionnement :**

- Compte le nombre de tentatives d'authentification (mot de passe, clé, etc.)
- Si dépassé, la connexion est fermée avec un message "Too many authentication failures"
- S'applique par connexion TCP, pas par IP
- Valeur par défaut : 6

> [!warning] Interaction avec les clés multiples Si un client SSH essaie automatiquement plusieurs clés privées (comportement par défaut), chaque clé compte comme une tentative. Avec `MaxAuthTries 3` et 5 clés dans l'agent SSH, la connexion échouera avant d'essayer le mot de passe.
> 
> **Solution côté client :** Désactiver l'essai automatique de clés avec `IdentitiesOnly yes` dans `~/.ssh/config`.

```bash
# Configuration recommandée
MaxAuthTries 3    # Stricte, pour environnements sensibles
MaxAuthTries 4    # Équilibrée
MaxAuthTries 6    # Par défaut, plus permissive
```

### MaxStartups

Contrôle le nombre de connexions SSH non authentifiées simultanées pour se protéger contre les attaques par déni de service.

```bash
# Dans /etc/ssh/sshd_config
MaxStartups 10:30:60
```

**Syntaxe : `start:rate:full`**

- **start** : Nombre de connexions non authentifiées autorisées sans restriction
- **rate** : Pourcentage de refus aléatoire une fois `start` dépassé
- **full** : Nombre maximum absolu, toutes nouvelles connexions sont refusées

**Exemple avec `10:30:60` :**

1. Connexions 1-10 : Toutes acceptées
2. Connexions 11-60 : Refus aléatoire progressif (30% à la 11ème, augmente jusqu'à 100% à la 60ème)
3. Connexion 61+ : Toutes refusées

> [!info] Calcul du taux de refus Formule : `rate% + ((connexions_actuelles - start) / (full - start)) * (100 - rate)%`
> 
> Avec `10:30:60`, à la 35ème connexion : `30% + ((35-10)/(60-10)) * 70% = 30% + 35% = 65%` de chances d'être refusée

```bash
# Configurations selon le contexte

# Serveur à faible trafic (1-5 utilisateurs)
MaxStartups 3:50:10

# Serveur standard (5-20 utilisateurs)
MaxStartups 10:30:60

# Serveur à fort trafic (20+ utilisateurs, infrastructure)
MaxStartups 20:50:100

# Serveur public exposé (très restrictif contre DDoS)
MaxStartups 5:90:10
```

### LoginGraceTime

Définit le délai maximum accordé à un utilisateur pour s'authentifier après l'établissement de la connexion.

```bash
# Dans /etc/ssh/sshd_config
LoginGraceTime 30
```

**Fonctionnement :**

- Décompte démarre dès l'établissement de la connexion TCP
- Si l'authentification n'est pas complétée dans ce délai, la connexion est fermée
- Libère les ressources et les slots de connexion
- Valeur en secondes (suffixe `m` pour minutes possible)
- Valeur par défaut : 120 secondes (2 minutes)

```bash
# Configurations recommandées

# Très restrictif (data centers, production sensible)
LoginGraceTime 20

# Restrictif standard (recommandé)
LoginGraceTime 30

# Permissif (connexions lentes, environnements de développement)
LoginGraceTime 60

# Par défaut (trop permissif pour la production)
LoginGraceTime 120
```

> [!tip] Optimisation des ressources Un `LoginGraceTime` court (20-30s) combiné à un `MaxStartups` approprié empêche les attaquants de saturer votre serveur en ouvrant de nombreuses connexions qu'ils laissent traîner sans s'authentifier.

### Combinaison optimale

La sécurité SSH repose sur la synergie entre ces trois paramètres :

```bash
# Configuration équilibrée recommandée (production standard)
MaxAuthTries 3
MaxStartups 10:30:60
LoginGraceTime 30

# Configuration stricte (haute sécurité, exposition publique)
MaxAuthTries 2
MaxStartups 5:90:10
LoginGraceTime 20

# Configuration permissive (développement, réseau interne)
MaxAuthTries 4
MaxStartups 20:50:100
LoginGraceTime 60
```

|Paramètre|Protège contre|Impact sur l'utilisateur légitime|
|---|---|---|
|MaxAuthTries|Force brute par connexion|Moyen - doit connaître ses identifiants|
|MaxStartups|DDoS, saturation de connexions|Faible - sauf trafic très élevé|
|LoginGraceTime|Connections zombies, lenteur volontaire|Faible - 30s suffisent largement|

> [!example] Scénario d'attaque bloqué Un attaquant lance 100 connexions simultanées :
> 
> - `MaxStartups 10:30:60` : Seules 60 connexions max sont acceptées, les autres sont refusées immédiatement
> - `LoginGraceTime 30` : Chaque connexion non authentifiée est fermée après 30 secondes
> - `MaxAuthTries 3` : Sur chaque connexion, seulement 3 tentatives de mot de passe
> - Résultat : L'attaquant est fortement ralenti et consomme peu de vos ressources

---

## Timeouts de connexion

Les timeouts de connexion permettent de détecter et fermer automatiquement les sessions inactives, réduisant la surface d'attaque et libérant les ressources.

### ClientAliveInterval et ClientAliveCountMax

Ces deux paramètres travaillent ensemble pour gérer les sessions inactives.

```bash
# Dans /etc/ssh/sshd_config
ClientAliveInterval 300
ClientAliveCountMax 2
```

**ClientAliveInterval** (en secondes) :

- Définit l'intervalle entre chaque message "keepalive" envoyé par le serveur au client
- Si aucune donnée n'est reçue du client pendant cet intervalle, le serveur envoie un message via le canal SSH chiffré
- Valeur par défaut : 0 (désactivé)

**ClientAliveCountMax** :

- Nombre maximum de messages keepalive sans réponse avant de fermer la connexion
- Valeur par défaut : 3

**Calcul du timeout total :**

```
Timeout total = ClientAliveInterval × ClientAliveCountMax
```

Exemple avec la configuration ci-dessus :

```
300 secondes × 2 = 600 secondes = 10 minutes
```

Si le client ne répond pas pendant 10 minutes, la connexion est fermée.

> [!info] Fonctionnement détaillé
> 
> 1. Aucune activité pendant 300s → Serveur envoie keepalive #1
> 2. Pas de réponse, 300s de plus → Serveur envoie keepalive #2
> 3. Pas de réponse, 300s de plus → Connexion fermée (CountMax atteint)

```bash
# Configurations selon les besoins

# Très stricte (serveurs de production sensibles)
ClientAliveInterval 120
ClientAliveCountMax 2
# Timeout total = 4 minutes

# Stricte recommandée (production standard)
ClientAliveInterval 300
ClientAliveCountMax 2
# Timeout total = 10 minutes

# Équilibrée (usage mixte)
ClientAliveInterval 300
ClientAliveCountMax 3
# Timeout total = 15 minutes

# Permissive (développement, sessions longues)
ClientAliveInterval 600
ClientAliveCountMax 5
# Timeout total = 50 minutes

# Désactivé (déconseillé)
ClientAliveInterval 0
ClientAliveCountMax 3
```

### TCPKeepAlive

TCPKeepAlive est un mécanisme de niveau TCP (couche transport) distinct des keepalives SSH.

```bash
# Dans /etc/ssh/sshd_config
TCPKeepAlive no
```

**Différences entre TCPKeepAlive et ClientAlive :**

|Caractéristique|TCPKeepAlive|ClientAlive|
|---|---|---|
|Niveau|TCP (couche 4)|SSH (couche 7)|
|Chiffrement|Non chiffré|Chiffré|
|Spoofable|Oui|Non|
|Contourne firewall|Parfois|Oui|
|Détecte déconnexion|Oui|Oui|
|Recommandé pour SSH|Non|Oui|

**Pourquoi désactiver TCPKeepAlive ?**

1. **Sécurité** : Les paquets TCP keepalive ne sont pas chiffrés et peuvent être forgés (spoofing)
2. **Fiabilité** : Certains firewalls ou NAT peuvent interférer avec les keepalives TCP
3. **Redondance** : ClientAlive fait le même travail de manière plus sécurisée
4. **Compatibilité** : TCPKeepAlive peut causer des déconnexions intempestives avec certains équipements réseau

```bash
# Configuration recommandée
TCPKeepAlive no
ClientAliveInterval 300
ClientAliveCountMax 2
```

> [!warning] Exception rare Dans certains environnements très spécifiques (NAT complexe, load balancers anciens), TCPKeepAlive peut aider à maintenir la table de connexions. Mais dans 99% des cas, mieux vaut s'en passer et utiliser ClientAlive.

### Configuration recommandée

Synthèse d'une configuration optimale pour la plupart des environnements :

```bash
# /etc/ssh/sshd_config - Section Timeouts

# Keepalives SSH côté serveur (fermeture auto des sessions inactives)
ClientAliveInterval 300        # Envoie un keepalive toutes les 5 minutes
ClientAliveCountMax 2          # 2 keepalives sans réponse = déconnexion
                               # Timeout total = 10 minutes

# Désactivation des keepalives TCP (moins sécurisés)
TCPKeepAlive no

# Timeout d'authentification (déjà vu précédemment)
LoginGraceTime 30
```

**Configuration côté client (optionnel) :**

Pour éviter d'être déconnecté par le serveur, le client peut envoyer ses propres keepalives :

```bash
# Dans ~/.ssh/config (côté client)
Host *
    ServerAliveInterval 60      # Envoie un keepalive toutes les 60 secondes
    ServerAliveCountMax 3       # 3 keepalives sans réponse = déconnexion
    # Timeout total = 3 minutes
```

> [!tip] Stratégie client-serveur
> 
> - **Serveur** : Timeout long (10-15 min) pour ne pas perturber les utilisateurs actifs
> - **Client** : Timeout court (2-3 min) pour détecter rapidement les coupures réseau
> - Résultat : Le client détecte les problèmes réseau rapidement, le serveur nettoie les sessions vraiment abandonnées

**Test de la configuration :**

```bash
# Test 1 : Vérifier que les paramètres sont actifs
sudo sshd -T | grep -E 'clientalive|tcpkeepalive'

# Test 2 : Connexion et attente d'inactivité
ssh user@server
# Laissez la session inactive pendant ClientAliveInterval × ClientAliveCountMax
# La session doit se fermer automatiquement

# Test 3 : Surveillance des connexions actives
# Pendant qu'une session est ouverte :
sudo ss -tnp | grep sshd
# Surveillez le timer TCP (colonne "timer")
```

---

## Restriction par IP

Restreindre l'accès SSH à des adresses IP spécifiques est une couche de sécurité puissante pour limiter la surface d'attaque. Plusieurs méthodes existent, chacune avec ses avantages.

### Restriction au niveau SSH

La méthode la plus directe consiste à utiliser les directives natives de SSH pour contrôler les accès par IP, utilisateur ou groupe.

#### Match Address

```bash
# Dans /etc/ssh/sshd_config

# Autoriser uniquement certaines IPs pour tous les utilisateurs
# (Place en FIN de fichier)
Match Address 192.168.1.0/24,10.0.0.50
    PasswordAuthentication yes
    
# Tout le reste est refusé (comportement par défaut)
Match Address *
    DenyUsers *
```

**Exemple plus complexe :**

```bash
# Accès admin depuis le réseau local uniquement
Match User admin,root Address 192.168.1.0/24
    PasswordAuthentication no
    PubkeyAuthentication yes
    PermitRootLogin yes

# Accès développeurs depuis VPN uniquement
Match Group developers Address 10.8.0.0/24
    X11Forwarding yes
    AllowTcpForwarding yes

# Accès utilisateurs standards depuis partout (avec restrictions)
Match User * Address *
    PermitRootLogin no
    AllowTcpForwarding no
    X11Forwarding no
```

#### AllowUsers / DenyUsers avec IP

```bash
# Syntaxe : utilisateur@pattern_ip

# N'autoriser root que depuis une IP spécifique
AllowUsers root@192.168.1.10

# Autoriser plusieurs utilisateurs depuis un réseau
AllowUsers admin@192.168.1.* dev@10.0.0.* user@*

# Interdire un utilisateur depuis Internet
DenyUsers baduser@*
DenyUsers *@203.0.113.0/24
```

> [!warning] Ordre de priorité
> 
> 1. DenyUsers / DenyGroups (priorité maximale)
> 2. AllowUsers / AllowGroups
> 3. Match blocks (évalués dans l'ordre d'apparition)
> 
> Si un utilisateur est dans DenyUsers, il ne pourra pas se connecter même s'il est dans AllowUsers.

#### AllowGroups / DenyGroups

```bash
# Créer des groupes système pour organiser les accès
sudo groupadd ssh-local
sudo groupadd ssh-remote
sudo usermod -aG ssh-local admin
sudo usermod -aG ssh-remote developer

# Dans /etc/ssh/sshd_config
AllowGroups ssh-local ssh-remote

# Avec Match pour différencier par IP
Match Group ssh-local Address 192.168.1.0/24
    AllowTcpForwarding yes

Match Group ssh-remote Address !192.168.1.0/24
    AllowTcpForwarding no
    X11Forwarding no
```

### Restriction avec iptables

Iptables permet de filtrer les connexions SSH au niveau du firewall, avant même qu'elles n'atteignent le service SSH.

#### Syntaxe de base

```bash
# Flush des règles existantes pour SSH (attention en production!)
sudo iptables -F
sudo iptables -X

# Politique par défaut (DROP = tout bloquer par défaut)
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Autoriser le loopback (essentiel)
sudo iptables -A INPUT -i lo -j ACCEPT

# Autoriser les connexions établies et reliées
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

#### Autoriser SSH depuis une IP spécifique

```bash
# Autoriser une seule IP
sudo iptables -A INPUT -p tcp --dport 22 -s 192.168.1.50 -j ACCEPT

# Autoriser un réseau complet
sudo iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT

# Autoriser plusieurs IPs/réseaux
sudo iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -s 10.0.0.50 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -s 203.0.113.42 -j ACCEPT

# Bloquer tout le reste (implicite avec politique DROP)
```

#### Protection contre le brute force (sans fail2ban)

```bash
# Limiter les nouvelles connexions SSH à 3 par minute par IP
sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP

# Explication:
# --set : Enregistre l'IP dans la liste "recent"
# --update : Met à jour le compteur
# --seconds 60 : Fenêtre de temps de 60 secondes
# --hitcount 4 : Si 4 connexions ou plus dans les 60s, DROP
```

#### Logging des tentatives SSH

```bash
# Logger les tentatives de connexion SSH refusées
sudo iptables -A INPUT -p tcp --dport 22 -j LOG --log-prefix "SSH-DROP: " --log-level 4

# Puis bloquer
sudo iptables -A INPUT -p tcp --dport 22 -j DROP
```

#### Port Knocking (sécurité par obscurité avancée)

Technique où SSH n'est accessible qu'après avoir "frappé" à des ports spécifiques dans l'ordre.

```bash
# Règle 1 : Frapper au port 7000
sudo iptables -N GATE1
sudo iptables -A INPUT -p tcp --dport 7000 -m recent --name AUTH1 --set -j DROP

# Règle 2 : Frapper au port 8000 (seulement si 7000 a été frappé)
sudo iptables -N GATE2
sudo iptables -A INPUT -p tcp --dport 8000 -m recent --rcheck --name AUTH1 -m recent --name AUTH2 --set -j DROP

# Règle 3 : Frapper au port 9000 (seulement si 8000 a été frappé)
sudo iptables -N GATE3
sudo iptables -A INPUT -p tcp --dport 9000 -m recent --rcheck --name AUTH2 -m recent --name AUTH3 --set -j DROP

# Règle finale : Autoriser SSH seulement si la séquence a été respectée
sudo iptables -A INPUT -p tcp --dport 22 -m recent --rcheck --name AUTH3 -j ACCEPT

# Bloquer SSH si pas de knock
sudo iptables -A INPUT -p tcp --dport 22 -j DROP

# Réinitialisation automatique après 30 secondes
sudo iptables -A INPUT -m recent --name AUTH1 --remove
sudo iptables -A INPUT -m recent --name AUTH2 --remove
sudo iptables -A INPUT -m recent --name AUTH3 --remove
```

**Utilisation côté client :**

```bash
# Frapper dans l'ordre avant de se connecter
nc -z server_ip 7000
nc -z server_ip 8000
nc -z server_ip 9000
ssh user@server_ip
```

> [!warning] Port Knocking Cette technique ajoute de la complexité et n'est pas une vraie sécurité (obscurité ≠ sécurité). Elle peut cependant réduire le bruit des scans automatisés. Préférez les VPN ou l'authentification par clés pour la vraie sécurité.

#### Persistance des règles iptables

```bash
# Sauvegarder les règles actuelles
# Debian/Ubuntu
sudo iptables-save > /etc/iptables/rules.v4
sudo apt install iptables-persistent

# RHEL/CentOS
sudo iptables-save > /etc/sysconfig/iptables
sudo systemctl enable iptables

# Restaurer les règles au démarrage
sudo iptables-restore < /etc/iptables/rules.v4
```

#### Exemple complet de règles iptables SSH

```bash
#!/bin/bash
# Script de configuration firewall SSH

# Flush
iptables -F
iptables -X
iptables -Z

# Politiques par défaut
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Loopback
iptables -A INPUT -i lo -j ACCEPT

# Connexions établies
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# SSH depuis réseau local uniquement
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT

# SSH depuis IP publique de confiance avec rate limiting
iptables -A INPUT -p tcp --dport 22 -s 203.0.113.42 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 22 -s 203.0.113.42 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
iptables -A INPUT -p tcp --dport 22 -s 203.0.113.42 -j ACCEPT

# Logger les tentatives SSH rejetées
iptables -A INPUT -p tcp --dport 22 -m limit --limit 5/min -j LOG --log-prefix "SSH-REJECT: " --log-level 4

# Bloquer tout le reste SSH
iptables -A INPUT -p tcp --dport 22 -j DROP

# Sauvegarder
iptables-save > /etc/iptables/rules.v4
```

### Restriction avec firewalld

Firewalld est le gestionnaire de firewall moderne sur RHEL/CentOS/Fedora, offrant une abstraction plus simple qu'iptables avec des zones et des services.

#### Concepts de firewalld

**Zones** : Niveaux de confiance prédéfinis

- `drop` : Tout est bloqué
- `block` : Connexions entrantes bloquées, sortantes autorisées
- `public` : Utilisation par défaut, connexions entrantes sélectives
- `trusted` : Tout est autorisé
- `home` : Réseau domestique de confiance
- `internal` : Réseau interne d'entreprise
- `work` : Réseau de travail

#### Configuration de base

```bash
# Vérifier le statut
sudo systemctl status firewalld
sudo firewall-cmd --state

# Démarrer et activer
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Voir la zone par défaut
sudo firewall-cmd --get-default-zone

# Lister toutes les zones
sudo firewall-cmd --get-zones

# Voir la configuration active
sudo firewall-cmd --list-all
```

#### Restriction SSH par zone

```bash
# Créer une zone personnalisée pour SSH admin
sudo firewall-cmd --permanent --new-zone=ssh-admin
sudo firewall-cmd --reload

# Ajouter le service SSH à cette zone
sudo firewall-cmd --permanent --zone=ssh-admin --add-service=ssh

# Autoriser uniquement les IPs du réseau local
sudo firewall-cmd --permanent --zone=ssh-admin --add-source=192.168.1.0/24

# Appliquer les changements
sudo firewall-cmd --reload

# Vérifier
sudo firewall-cmd --zone=ssh-admin --list-all
```

#### Restriction SSH par IP source

```bash
# Méthode 1 : Rich rules (recommandé pour la granularité)
# Autoriser SSH depuis une IP spécifique
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.50" service name="ssh" accept'

# Autoriser SSH depuis un réseau
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept'

# Bloquer SSH depuis une IP spécifique
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="203.0.113.0/24" service name="ssh" reject'

# Appliquer
sudo firewall-cmd --reload

# Méthode 2 : Source directe dans zone
# Supprimer SSH de la zone public
sudo firewall-cmd --permanent --zone=public --remove-service=ssh

# Créer une zone pour SSH depuis VPN uniquement
sudo firewall-cmd --permanent --new-zone=ssh-vpn
sudo firewall-cmd --permanent --zone=ssh-vpn --add-service=ssh
sudo firewall-cmd --permanent --zone=ssh-vpn --add-source=10.8.0.0/24

# Appliquer
sudo firewall-cmd --reload
```

#### Rate limiting avec firewalld

```bash
# Limiter les connexions SSH à 3 par minute
sudo firewall-cmd --permanent --add-rich-rule='rule service name="ssh" limit value="3/m" accept'

# Limiter par IP source
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="0.0.0.0/0" service name="ssh" limit value="5/m" accept'

# Bloquer après dépassement
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" service name="ssh" limit value="3/m" log prefix="SSH-LIMIT " level="info" accept'

sudo firewall-cmd --reload
```

#### Port personnalisé SSH

```bash
# Si SSH écoute sur un port différent (ex: 2222)
# Méthode 1 : Redéfinir le service SSH
sudo firewall-cmd --permanent --service=ssh --add-port=2222/tcp
sudo firewall-cmd --permanent --service=ssh --remove-port=22/tcp

# Méthode 2 : Ajouter le port directement
sudo firewall-cmd --permanent --add-port=2222/tcp

# Méthode 3 : Rich rule avec port personnalisé
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" port port="2222" protocol="tcp" accept'

sudo firewall-cmd --reload
```

#### Logging des connexions SSH

```bash
# Logger toutes les tentatives SSH
sudo firewall-cmd --permanent --add-rich-rule='rule service name="ssh" log prefix="SSH: " level="info" limit value="3/m" accept'

# Logger uniquement les rejets
sudo firewall-cmd --permanent --add-rich-rule='rule service name="ssh" log prefix="SSH-REJECT: " level="warning" reject'

# Consulter les logs
sudo journalctl -f | grep SSH
# ou
sudo tail -f /var/log/messages | grep SSH
```

#### Configuration complète firewalld pour SSH

```bash
#!/bin/bash
# Script de configuration firewalld pour SSH

# Désactiver SSH sur zone public (Internet)
firewall-cmd --permanent --zone=public --remove-service=ssh

# Zone pour réseau local (accès complet)
firewall-cmd --permanent --new-zone=lan
firewall-cmd --permanent --zone=lan --set-target=ACCEPT
firewall-cmd --permanent --zone=lan --add-source=192.168.1.0/24
firewall-cmd --permanent --zone=lan --add-service=ssh

# Zone pour VPN (accès SSH avec rate limiting)
firewall-cmd --permanent --new-zone=vpn
firewall-cmd --permanent --zone=vpn --add-source=10.8.0.0/24
firewall-cmd --permanent --zone=vpn --add-rich-rule='rule service name="ssh" limit value="5/m" accept'

# Zone pour IPs de confiance (backup, monitoring)
firewall-cmd --permanent --new-zone=trusted-admin
firewall-cmd --permanent --zone=trusted-admin --add-source=203.0.113.42
firewall-cmd --permanent --zone=trusted-admin --add-service=ssh

# Logging des tentatives depuis Internet
firewall-cmd --permanent --zone=public --add-rich-rule='rule service name="ssh" log prefix="SSH-PUBLIC-REJECT: " level="warning" limit value="1/m" reject'

# Appliquer la configuration
firewall-cmd --reload

# Vérifier
firewall-cmd --list-all-zones
```

#### Gestion et dépannage

```bash
# Voir toutes les règles actives
sudo firewall-cmd --list-all-zones

# Voir une zone spécifique
sudo firewall-cmd --zone=public --list-all

# Tester une règle temporairement (sans --permanent)
sudo firewall-cmd --add-rich-rule='rule service name="ssh" accept'
# Si ça fonctionne, l'ajouter de façon permanente
sudo firewall-cmd --permanent --add-rich-rule='rule service name="ssh" accept'
sudo firewall-cmd --reload

# Supprimer une rich rule
sudo firewall-cmd --permanent --remove-rich-rule='rule service name="ssh" accept'

# Réinitialiser firewalld aux paramètres par défaut
sudo firewall-cmd --complete-reload

# Debug : voir les règles iptables générées par firewalld
sudo iptables -L -n -v
sudo iptables -t filter -S
```

### Comparaison des méthodes

|Méthode|Avantages|Inconvénients|Cas d'usage|
|---|---|---|---|
|**SSH natif (Match, Allow/Deny)**|• Simple à configurer<br>• Pas de dépendance externe<br>• Granularité par utilisateur|• Seulement au niveau applicatif<br>• Pas de protection contre DDoS<br>• Logs uniquement SSH|• Restriction par utilisateur<br>• Environnements simples<br>• Déjà derrière un firewall|
|**iptables**|• Contrôle total bas niveau<br>• Très performant<br>• Protection avant le service<br>• Rate limiting efficace|• Syntaxe complexe<br>• Persistance manuelle<br>• Difficile à maintenir|• Serveurs experts<br>• Contrôle fin requis<br>• Performance critique<br>• Systèmes embarqués|
|**firewalld**|• Abstraction simple<br>• Zones de confiance<br>• Gestion dynamique<br>• Intégration systemd|• Disponible surtout sur RHEL<br>• Overhead léger<br>• Moins de contrôle qu'iptables|• Environnements RHEL/CentOS<br>• Administration simplifiée<br>• Gestion par zones<br>• Équipes moins expertes|

**Recommandations par contexte :**

```bash
# Serveur d'entreprise avec équipes IT
→ firewalld (zones, rich rules) + fail2ban

# Serveur personnel / VPS
→ iptables basique + fail2ban

# Serveur haute sécurité / gouvernemental
→ iptables avancé + fail2ban + SSH Match + VPN obligatoire

# Développement / Lab
→ SSH natif (AllowUsers/Groups) + firewalld basique

# Infrastructure cloud (AWS, Azure, GCP)
→ Security Groups du cloud + SSH Match + fail2ban en interne
```

> [!tip] Défense en profondeur La meilleure approche combine plusieurs couches :
> 
> 1. **Firewall** (iptables/firewalld) : Filtrage IP, rate limiting
> 2. **fail2ban** : Bannissement automatique des attaquants
> 3. **SSH natif** : Match rules, AllowUsers, timeouts
> 4. **Authentification forte** : Clés SSH, 2FA (mentionné mais pas développé ici)
> 
> Aucune méthode seule n'est suffisante.

---

## Pièges courants

### 1. Se bannir soi-même

**Problème :** Configurer des règles de firewall ou fail2ban trop strictes sans exception pour sa propre IP.

```bash
# ❌ DANGER : Peut vous bloquer instantanément
sudo iptables -A INPUT -p tcp --dport 22 -s 192.168.1.100 -j ACCEPT
sudo iptables -P INPUT DROP
# Si vous n'êtes pas sur 192.168.1.100, vous êtes bloqué !

# ✅ CORRECT : Toujours ajouter son IP dans ignoreip de fail2ban
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1 VOTRE_IP_ACTUELLE

# ✅ CORRECT : Tester avant de rendre permanent
sudo iptables -A INPUT -p tcp --dport 22 -s VOTRE_IP -j ACCEPT
# Tester la connexion depuis un autre terminal
# Si OK, sauvegarder avec iptables-save
```

**Solution de secours :**

- Avoir toujours un accès console physique ou KVM/IPMI
- Configurer un script de réinitialisation automatique après X minutes
- Utiliser `at` pour planifier un flush des règles

```bash
# Script de sécurité : annule les modifications après 5 minutes si non confirmé
sudo bash -c 'echo "iptables -F; iptables -P INPUT ACCEPT" | at now + 5 minutes'
# Faire vos modifications
# Si tout fonctionne :
sudo atrm $(atq | tail -1 | cut -f1)
```

### 2. Oublier de recharger SSH après modification

**Problème :** Modifier `/etc/ssh/sshd_config` sans redémarrer le service.

```bash
# ❌ Les modifications ne sont pas appliquées
sudo nano /etc/ssh/sshd_config
# ... modifications ...
# Sortir sans recharger

# ✅ TOUJOURS tester et recharger
# Test de syntaxe avant de recharger
sudo sshd -t
# Si OK :
sudo systemctl reload sshd
# ou
sudo systemctl restart sshd
```

> [!warning] Reload vs Restart
> 
> - `reload` : Relit la configuration sans couper les connexions existantes (préférable)
> - `restart` : Redémarre complètement, coupe les connexions actives
> 
> Utilisez `reload` sauf si vous avez modifié des paramètres critiques nécessitant un restart.

### 3. Conflits entre fail2ban et iptables/firewalld

**Problème :** Fail2ban utilise iptables en arrière-plan. Si vous gérez aussi iptables manuellement, risque de conflits.

```bash
# ❌ Règles en conflit
# Vous : bloquez tout SSH sauf une IP
sudo iptables -A INPUT -p tcp --dport 22 -s 192.168.1.50 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j DROP

# Fail2ban : essaie d'insérer des règles de ban
# → Les règles de fail2ban peuvent être ignorées ou mal placées

# ✅ CORRECT : Utiliser une chaîne dédiée pour fail2ban
# fail2ban insère ses règles dans sa propre chaîne (f2b-sshd)
# Vos règles doivent laisser passer vers cette chaîne

sudo iptables -N SSH-RULES
sudo iptables -A INPUT -p tcp --dport 22 -j SSH-RULES
sudo iptables -A SSH-RULES -j f2b-sshd  # Chaîne fail2ban en premier
sudo iptables -A SSH-RULES -s 192.168.1.0/24 -j ACCEPT
sudo iptables -A SSH-RULES -j DROP
```

**Avec firewalld :**

```bash
# Fail2ban s'intègre automatiquement avec firewalld si configuré
# Dans /etc/fail2ban/jail.local
[DEFAULT]
banaction = firewallcmd-ipset
# ou
banaction = firewallcmd-rich-rules
```

### 4. Rate limiting trop agressif (faux positifs)

**Problème :** Des utilisateurs légitimes se font bannir à cause de paramètres trop stricts.

```bash
# ❌ Trop strict pour un environnement avec plusieurs admins
MaxAuthTries 2        # Seulement 2 essais
LoginGraceTime 15     # 15 secondes pour taper le mot de passe
maxretry = 2          # Ban après 2 échecs (fail2ban)
findtime = 3600       # Sur 1 heure

# Scénario : Un admin avec 3 clés SSH dans son agent
# → Chaque clé = 1 tentative
# → MaxAuthTries dépassé avant même d'essayer le mot de passe !

# ✅ Équilibré pour la plupart des cas
MaxAuthTries 4
LoginGraceTime 30
maxretry = 5
findtime = 600        # 10 minutes
```

**Diagnostic :**

```bash
# Voir les bannissements récents de fail2ban
sudo fail2ban-client status sshd
sudo tail -f /var/log/fail2ban.log

# Identifier les faux positifs
sudo grep "Failed password" /var/log/auth.log | grep LEGITIMATE_USER_IP

# Débannir temporairement
sudo fail2ban-client set sshd unbanip 192.168.1.50
```

### 5. Ne pas logger ou surveiller

**Problème :** Configuration sans monitoring = impossible de détecter les attaques ou diagnostiquer les problèmes.

```bash
# ❌ Aucune visibilité
# Pas de logs fail2ban consultés
# Pas de surveillance des auth.log
# Pas d'alertes

# ✅ Surveillance active

# Logs SSH en temps réel
sudo tail -f /var/log/auth.log | grep sshd

# Statistiques fail2ban quotidiennes
sudo fail2ban-client status sshd > /var/log/fail2ban-daily.log

# Script d'alerte par email si plus de 10 bans/jour
#!/bin/bash
BANS=$(fail2ban-client status sshd | grep "Total banned" | awk '{print $4}')
if [ "$BANS" -gt 10 ]; then
    echo "Alerte : $BANS IPs bannies aujourd'hui" | mail -s "Fail2ban Alert" admin@example.com
fi

# Cron quotidien
echo "0 23 * * * /usr/local/bin/fail2ban-alert.sh" | sudo crontab -
```

### 6. Configuration de fail2ban non persistante

**Problème :** Modifications dans `jail.conf` au lieu de `jail.local`, écrasées lors d'une mise à jour.

```bash
# ❌ Sera perdu lors d'une mise à jour
sudo nano /etc/fail2ban/jail.conf
# Modifications...

# ✅ Persistant entre les mises à jour
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
# Modifications...

# jail.local a toujours priorité sur jail.conf
```

### 7. Tester les règles sur le mauvais port

**Problème :** SSH écoute sur un port personnalisé mais les règles ciblent le port 22.

```bash
# SSH configuré sur port 2222
# Dans /etc/ssh/sshd_config
Port 2222

# ❌ Fail2ban surveille le mauvais port
[sshd]
port = ssh  # = port 22 par défaut

# ❌ Firewall bloque le bon port
sudo firewall-cmd --add-service=ssh  # Autorise port 22, pas 2222

# ✅ Cohérence sur tous les niveaux
# fail2ban
[sshd]
port = 2222

# firewalld
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --permanent --remove-service=ssh

# iptables
sudo iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
```

---

## Bonnes pratiques de sécurisation

### 1. Approche par couches (Defense in Depth)

Ne comptez jamais sur une seule mesure de sécurité. Empilez les protections :

```bash
# Couche 1 : Réseau (avant d'atteindre le serveur)
- VPN obligatoire pour l'administration
- Segmentation réseau (VLAN admin séparé)
- Security Groups cloud (AWS, Azure, GCP)

# Couche 2 : Firewall système
- iptables/firewalld : restriction IP, rate limiting
- fail2ban : bannissement automatique

# Couche 3 : Service SSH
- Port non standard
- Authentification par clés uniquement
- Désactivation root login
- Match rules pour restriction fine

# Couche 4 : Système
- SELinux/AppArmor activé
- Mises à jour automatiques de sécurité
- Audit régulier (auditd, aide)

# Couche 5 : Surveillance
- Monitoring centralisé (SIEM)
- Alertes en temps réel
- Logs externalisés (syslog distant)
```

### 2. Principe du moindre privilège

```bash
# ✅ Créer des comptes dédiés (pas de root direct)
# Utilisateur admin avec sudo
sudo adduser admin
sudo usermod -aG sudo admin  # Debian/Ubuntu
sudo usermod -aG wheel admin # RHEL/CentOS

# Désactiver root SSH
PermitRootLogin no

# Accès SSH par groupe
AllowGroups ssh-users ssh-admins

# Sudo sans mot de passe pour des commandes spécifiques uniquement
# /etc/sudoers.d/admin
admin ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx, /usr/bin/tail -f /var/log/nginx/*
```

### 3. Automatisation et infrastructure as code

```bash
# Ansible playbook pour configuration SSH sécurisée
---
- name: Sécurisation SSH
  hosts: all
  become: yes
  tasks:
    - name: Configuration SSH
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
      loop:
        - { regexp: '^PermitRootLogin', line: 'PermitRootLogin no' }
        - { regexp: '^PasswordAuthentication', line: 'PasswordAuthentication no' }
        - { regexp: '^MaxAuthTries', line: 'MaxAuthTries 3' }
        - { regexp: '^ClientAliveInterval', line: 'ClientAliveInterval 300' }
      notify: reload ssh

    - name: Installation fail2ban
      apt:
        name: fail2ban
        state: present

    - name: Configuration fail2ban
      template:
        src: jail.local.j2
        dest: /etc/fail2ban/jail.local
      notify: restart fail2ban

  handlers:
    - name: reload ssh
      systemd:
        name: sshd
        state: reloaded

    - name: restart fail2ban
      systemd:
        name: fail2ban
        state: restarted
```

### 4. Documentation et changement management

```bash
# Maintenir une documentation à jour
# /root/security-doc/ssh-config.md

## Configuration SSH Actuelle
- Port: 2222
- Authentification: Clés ED25519 uniquement
- IPs autorisées: 192.168.1.0/24, 10.8.0.0/24 (VPN)
- Fail2ban: 3 tentatives, ban 24h
- Dernière modification: 2024-12-10 par admin

## Procédure de débannissement d'urgence
1. Connexion console/KVM
2. `sudo fail2ban-client set sshd unbanip <IP>`
3. Vérifier logs: `sudo grep <IP> /var/log/fail2ban.log`

## Contacts urgence
- Admin système: +33 X XX XX XX XX
- Astreinte sécurité: security@entreprise.com
```

### 5. Tests réguliers et audits

```bash
# Script de test mensuel automatisé
#!/bin/bash
# /usr/local/bin/ssh-security-audit.sh

echo "=== Audit Sécurité SSH $(date) ===" > /var/log/ssh-audit.log

# Test 1 : Vérifier que root ne peut pas se connecter
echo "[TEST] Root login disabled" >> /var/log/ssh-audit.log
sshd -T | grep -i "permitrootlogin no" >> /var/log/ssh-audit.log || echo "FAIL: Root login enabled!" >> /var/log/ssh-audit.log

# Test 2 : Vérifier fail2ban actif
echo "[TEST] Fail2ban status" >> /var/log/ssh-audit.log
systemctl is-active fail2ban >> /var/log/ssh-audit.log

# Test 3 : Nombre de tentatives échouées cette semaine
echo "[TEST] Failed attempts last 7 days" >> /var/log/ssh-audit.log
grep "Failed password" /var/log/auth.log | wc -l >> /var/log/ssh-audit.log

# Test 4 : IPs actuellement bannies
echo "[TEST] Currently banned IPs" >> /var/log/ssh-audit.log
fail2ban-client status sshd >> /var/log/ssh-audit.log

# Envoi du rapport
mail -s "SSH Security Audit" admin@example.com < /var/log/ssh-audit.log

# Cron : 1er jour du mois à 6h
# 0 6 1 * * /usr/local/bin/ssh-security-audit.sh
```

### 6. Plan de reprise en cas de lockout

```bash
# Scénario : Vous vous êtes bloqué hors du serveur

# Solution 1 : Accès console (IPMI/KVM/Console cloud)
# → Connexion directe sur la machine
# → Modifier /etc/ssh/sshd_config ou débannir IP

# Solution 2 : Resetroot (si console disponible)
# Reboot en mode single-user, modifier config

# Solution 3 : Script de réinitialisation automatique
# Sur le serveur, planifier une tâche qui flush les règles après X temps
# À exécuter AVANT de tester des modifications critiques

#!/bin/bash
# /usr/local/bin/firewall-safety-reset.sh
sleep 300  # 5 minutes
iptables -F
iptables -P INPUT ACCEPT
systemctl stop fail2ban
echo "FIREWALL RESET - CONFIG NON CONFIRMEE" | wall

# Lancer avant vos modifs
sudo /usr/local/bin/firewall-safety-reset.sh &
# Si tout fonctionne, tuer le process
sudo pkill -f firewall-safety-reset
```

### 7. Checklist de configuration sécurisée

```bash
# ✅ Checklist de validation

## Configuration SSH (/etc/ssh/sshd_config)
[ ] Port non standard (ex: 2222)
[ ] PermitRootLogin no
[ ] PasswordAuthentication no
[ ] PubkeyAuthentication yes
[ ] MaxAuthTries 3-4
[ ] MaxStartups 10:30:60
[ ] LoginGraceTime 30
[ ] ClientAliveInterval 300
[ ] ClientAliveCountMax 2
[ ] TCPKeepAlive no
[ ] AllowUsers ou AllowGroups défini
[ ] Match rules pour restrictions IP

## Firewall
[ ] Service SSH restreint par IP
[ ] Rate limiting activé
[ ] Logs des tentatives activés
[ ] Règles persistantes (iptables-save ou firewalld)

## Fail2ban
[ ] Service actif et enabled
[ ] Jail sshd activée
[ ] maxretry <= 5
[ ] bantime >= 3600 (1h)
[ ] ignoreip contient vos IPs admin
[ ] Logs consultés régulièrement

## Authentification
[ ] Clés SSH déployées pour tous les admins
[ ] Passphrase sur les clés privées
[ ] Clés autorisées dans ~/.ssh/authorized_keys (permissions 600)
[ ] Aucun compte avec mot de passe faible

## Monitoring
[ ] Logs centralisés (rsyslog distant)
[ ] Alertes configurées (email/SMS)
[ ] Dashboard de surveillance (Grafana/ELK)
[ ] Tests d'intrusion planifiés

## Documentation
[ ] Procédures de débannissement documentées
[ ] Contacts urgence à jour
[ ] Changelog des modifications
[ ] Plan de recovery testé
```

---

## 🎯 Résumé des configurations recommandées

### Configuration SSH de base (sécurité standard)

```bash
# /etc/ssh/sshd_config - Configuration équilibrée pour production

# === AUTHENTIFICATION ===
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# === LIMITATIONS CONNEXIONS ===
MaxAuthTries 3
MaxStartups 10:30:60
LoginGraceTime 30

# === TIMEOUTS ===
ClientAliveInterval 300
ClientAliveCountMax 2
TCPKeepAlive no

# === RESTRICTIONS UTILISATEURS ===
AllowGroups ssh-users ssh-admins

# === LOGS ===
SyslogFacility AUTH
LogLevel VERBOSE

# === DIVERS ===
X11Forwarding no
AllowTcpForwarding no
PrintLastLog yes
```

### Configuration fail2ban (protection standard)

```bash
# /etc/fail2ban/jail.local

[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
ignoreip = 127.0.0.1/8 ::1 192.168.1.0/24 VOTRE_IP_ADMIN
action = %(action_)s

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 86400
findtime = 3600
```

### Configuration firewalld (RHEL/CentOS)

```bash
# Supprimer SSH de la zone publique
firewall-cmd --permanent --zone=public --remove-service=ssh

# Créer zone pour réseau local
firewall-cmd --permanent --new-zone=lan-admin
firewall-cmd --permanent --zone=lan-admin --add-source=192.168.1.0/24
firewall-cmd --permanent --zone=lan-admin --add-service=ssh

# Créer zone VPN avec rate limiting
firewall-cmd --permanent --new-zone=vpn-access
firewall-cmd --permanent --zone=vpn-access --add-source=10.8.0.0/24
firewall-cmd --permanent --zone=vpn-access --add-rich-rule='rule service name="ssh" limit value="5/m" accept'

# Appliquer
firewall-cmd --reload
```

### Configuration iptables (Debian/Ubuntu)

```bash
#!/bin/bash
# /etc/iptables/rules.sh - Configuration SSH sécurisée

# Flush
iptables -F
iptables -X

# Politiques par défaut
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Loopback
iptables -A INPUT -i lo -j ACCEPT

# Connexions établies
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# SSH depuis réseau local (sans limitation)
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT

# SSH depuis Internet avec rate limiting
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Sauvegarder
iptables-save > /etc/iptables/rules.v4
```

---

## 📊 Tableaux de référence rapide

### Paramètres SSH par niveau de sécurité

|Paramètre|Permissif (Dev)|Standard (Prod)|Strict (Haute sécu)|
|---|---|---|---|
|**MaxAuthTries**|6|3|2|
|**MaxStartups**|20:50:100|10:30:60|5:90:10|
|**LoginGraceTime**|60s|30s|20s|
|**ClientAliveInterval**|600s|300s|120s|
|**ClientAliveCountMax**|5|2|2|
|**PasswordAuthentication**|yes|no|no|
|**PermitRootLogin**|yes|no|no|

### Paramètres fail2ban par exposition

|Paramètre|Interne|Public standard|Très exposé|
|---|---|---|---|
|**maxretry**|10|5|3|
|**bantime**|600s (10min)|3600s (1h)|86400s (24h)|
|**findtime**|600s|600s|3600s|
|**bantime.increment**|false|true|true|
|**bantime.maxtime**|-|604800s (7j)|2592000s (30j)|

### Comparaison des méthodes de restriction IP

|Critère|SSH natif|iptables|firewalld|Fail2ban|
|---|---|---|---|---|
|**Niveau**|Application|Noyau|Noyau|Application+Noyau|
|**Performance**|⭐⭐⭐|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|⭐⭐⭐|
|**Simplicité**|⭐⭐⭐⭐⭐|⭐⭐|⭐⭐⭐⭐|⭐⭐⭐⭐|
|**Dynamique**|❌|❌|⚠️|✅|
|**Granularité**|Utilisateur/Groupe|IP/Port|IP/Zone|IP (auto)|
|**Protection DDoS**|❌|✅|✅|⚠️|

---

## 🔍 Commandes de diagnostic essentielles

### Vérification de la configuration SSH

```bash
# Test de syntaxe sans redémarrage
sudo sshd -t

# Afficher la configuration effective (avec les valeurs par défaut)
sudo sshd -T

# Afficher uniquement certains paramètres
sudo sshd -T | grep -E 'maxauthtries|clientalive|permit'

# Vérifier le port d'écoute
sudo ss -tlnp | grep sshd
# ou
sudo netstat -tlnp | grep sshd

# Voir les sessions SSH actives
who
w

# Voir les dernières connexions
last -a | head -20
lastlog

# Historique des authentifications
sudo grep "Accepted\|Failed" /var/log/auth.log | tail -50
```

### Surveillance fail2ban

```bash
# Statut global
sudo fail2ban-client status

# Statut détaillé jail SSH
sudo fail2ban-client status sshd

# IPs actuellement bannies
sudo fail2ban-client get sshd banip

# Débannir une IP
sudo fail2ban-client set sshd unbanip 203.0.113.42

# Bannir manuellement une IP
sudo fail2ban-client set sshd banip 203.0.113.42

# Logs en temps réel
sudo tail -f /var/log/fail2ban.log

# Statistiques du jour
sudo grep "Ban" /var/log/fail2ban.log | grep "$(date +%Y-%m-%d)"

# Top 10 des IPs bannies
sudo grep "Ban" /var/log/fail2ban.log | awk '{print $NF}' | sort | uniq -c | sort -rn | head -10
```

### Analyse des tentatives d'attaque

```bash
# Tentatives échouées SSH du jour
sudo grep "$(date +"%b %e")" /var/log/auth.log | grep "Failed password"

# Top 10 des IPs attaquantes
sudo grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -10

# Utilisateurs les plus ciblés
sudo grep "Failed password" /var/log/auth.log | awk '{print $(NF-5)}' | sort | uniq -c | sort -rn | head -10

# Tentatives par heure (dernier jour)
sudo grep "Failed password" /var/log/auth.log | grep "$(date +"%b %e")" | cut -d: -f1 | uniq -c

# Détection de scans de ports
sudo grep "Did not receive identification string" /var/log/auth.log | tail -20

# Tentatives root
sudo grep "Failed password for root" /var/log/auth.log | wc -l
```

### Vérification firewall

```bash
# iptables
sudo iptables -L -n -v --line-numbers
sudo iptables -L INPUT -n -v | grep "dpt:22"
sudo iptables -S | grep 22

# firewalld
sudo firewall-cmd --list-all
sudo firewall-cmd --list-all-zones
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --list-rich-rules

# Connexions actives SSH
sudo ss -tn | grep :22
sudo netstat -tn | grep :22

# Logs firewall (iptables)
sudo grep "SSH-" /var/log/kern.log | tail -20

# Logs firewall (firewalld)
sudo journalctl -u firewalld -f
```

---

## ⚙️ Scripts d'automatisation utiles

### Script de rapport quotidien SSH

```bash
#!/bin/bash
# /usr/local/bin/ssh-daily-report.sh
# À planifier en cron : 0 23 * * * /usr/local/bin/ssh-daily-report.sh

REPORT_FILE="/var/log/ssh-daily-$(date +%Y%m%d).log"
EMAIL="admin@example.com"

{
    echo "==================================="
    echo "Rapport SSH - $(date)"
    echo "==================================="
    echo ""
    
    echo "--- Tentatives échouées ---"
    grep "Failed password" /var/log/auth.log | grep "$(date +"%b %e")" | wc -l
    echo ""
    
    echo "--- Top 5 IPs attaquantes ---"
    grep "Failed password" /var/log/auth.log | grep "$(date +"%b %e")" | \
    awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -5
    echo ""
    
    echo "--- Fail2ban : IPs bannies aujourd'hui ---"
    grep "Ban" /var/log/fail2ban.log | grep "$(date +%Y-%m-%d)" | wc -l
    echo ""
    
    echo "--- Connexions réussies ---"
    grep "Accepted" /var/log/auth.log | grep "$(date +"%b %e")" | tail -10
    echo ""
    
    echo "--- Sessions actives actuellement ---"
    w
    
} > "$REPORT_FILE"

# Envoi par email
mail -s "Rapport SSH Quotidien - $(hostname)" "$EMAIL" < "$REPORT_FILE"

# Nettoyage des rapports > 30 jours
find /var/log -name "ssh-daily-*.log" -mtime +30 -delete
```

### Script de surveillance en temps réel

```bash
#!/bin/bash
# /usr/local/bin/ssh-live-monitor.sh
# Surveillance en temps réel avec alertes

ALERT_EMAIL="security@example.com"
THRESHOLD=10  # Alerte si > 10 tentatives/minute

while true; do
    # Compter les tentatives de la dernière minute
    ATTEMPTS=$(grep "Failed password" /var/log/auth.log | \
               grep "$(date "+%b %e %H:%M")" | wc -l)
    
    if [ "$ATTEMPTS" -gt "$THRESHOLD" ]; then
        echo "ALERTE: $ATTEMPTS tentatives SSH détectées en 1 minute" | \
        mail -s "ALERTE SSH - $(hostname)" "$ALERT_EMAIL"
        
        # Logger l'alerte
        logger -p auth.alert -t ssh-monitor \
        "ATTACK DETECTED: $ATTEMPTS failed attempts in last minute"
    fi
    
    # Affichage console
    clear
    echo "=== SSH Monitor - $(date) ==="
    echo "Tentatives dernière minute: $ATTEMPTS"
    echo ""
    echo "Sessions actives:"
    w -h | wc -l
    echo ""
    echo "Fail2ban status:"
    fail2ban-client status sshd | grep "Currently banned"
    
    sleep 60
done
```

### Script de backup de configuration

```bash
#!/bin/bash
# /usr/local/bin/backup-ssh-config.sh
# Backup automatique de la config SSH + firewall + fail2ban

BACKUP_DIR="/root/ssh-config-backups"
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup SSH
tar -czf "$BACKUP_DIR/sshd-config-$DATE.tar.gz" \
    /etc/ssh/sshd_config \
    /etc/ssh/ssh_config \
    /etc/ssh/moduli 2>/dev/null

# Backup fail2ban
tar -czf "$BACKUP_DIR/fail2ban-config-$DATE.tar.gz" \
    /etc/fail2ban/ 2>/dev/null

# Backup firewall
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --list-all-zones > "$BACKUP_DIR/firewalld-$DATE.txt"
else
    iptables-save > "$BACKUP_DIR/iptables-$DATE.rules"
fi

# Conserver uniquement les 30 derniers jours
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.txt" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.rules" -mtime +30 -delete

echo "Backup créé: $BACKUP_DIR/*-$DATE.*"
```

### Script de test de sécurité SSH

```bash
#!/bin/bash
# /usr/local/bin/ssh-security-test.sh
# Test automatique de la configuration SSH

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Test de Sécurité SSH ==="
echo ""

# Test 1: Root login désactivé
echo -n "Root login disabled: "
if sshd -T | grep -q "permitrootlogin no"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
fi

# Test 2: Authentification par mot de passe désactivée
echo -n "Password auth disabled: "
if sshd -T | grep -q "passwordauthentication no"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${YELLOW}⚠ WARNING${NC}"
fi

# Test 3: MaxAuthTries <= 4
echo -n "MaxAuthTries secure: "
MAX_TRIES=$(sshd -T | grep "^maxauthtries" | awk '{print $2}')
if [ "$MAX_TRIES" -le 4 ]; then
    echo -e "${GREEN}✓ PASS (${MAX_TRIES})${NC}"
else
    echo -e "${YELLOW}⚠ WARNING (${MAX_TRIES})${NC}"
fi

# Test 4: ClientAliveInterval configuré
echo -n "Session timeout configured: "
ALIVE=$(sshd -T | grep "^clientaliveinterval" | awk '{print $2}')
if [ "$ALIVE" -gt 0 ]; then
    echo -e "${GREEN}✓ PASS (${ALIVE}s)${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
fi

# Test 5: Fail2ban actif
echo -n "Fail2ban running: "
if systemctl is-active fail2ban &> /dev/null; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
fi

# Test 6: Firewall actif
echo -n "Firewall active: "
if systemctl is-active firewalld &> /dev/null || systemctl is-active iptables &> /dev/null; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
fi

# Test 7: Port non standard (optionnel)
echo -n "Non-standard port: "
PORT=$(sshd -T | grep "^port" | awk '{print $2}')
if [ "$PORT" != "22" ]; then
    echo -e "${GREEN}✓ INFO (${PORT})${NC}"
else
    echo -e "${YELLOW}⚠ INFO (22 - consider changing)${NC}"
fi

echo ""
echo "=== Test terminé ==="
```

---

## 🎓 Astuces avancées

### 1. Notifications Telegram pour fail2ban

```bash
# /etc/fail2ban/action.d/telegram.conf
[Definition]
actionstart = 
actionstop = 
actioncheck = 
actionban = curl -s -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/sendMessage" \
            -d "chat_id=<YOUR_CHAT_ID>" \
            -d "text=🚨 *Fail2ban Alert*%0A%0AJail: *<name>*%0AIP: *<ip>*%0AFailures: *<failures>*%0ABan time: *<bantime>s*" \
            -d "parse_mode=Markdown"
actionunban = curl -s -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/sendMessage" \
              -d "chat_id=<YOUR_CHAT_ID>" \
              -d "text=✅ IP *<ip>* unbanned from *<name>*" \
              -d "parse_mode=Markdown"

[Init]
init = 'Telegram notifications'

# Utilisation dans jail.local
[sshd]
enabled = true
action = telegram[name=sshd]
```

### 2. Whitelist dynamique basée sur GeoIP

```bash
# Autoriser uniquement certains pays
# Installation
sudo apt install geoip-bin geoip-database

# Script de filtrage
#!/bin/bash
# Autoriser uniquement FR, BE, CH
ALLOWED_COUNTRIES="FR BE CH"

# Analyser les IPs bannies
for IP in $(fail2ban-client get sshd banip); do
    COUNTRY=$(geoiplookup $IP | awk -F': ' '{print $2}' | cut -d',' -f1)
    if [[ "$ALLOWED_COUNTRIES" =~ "$COUNTRY" ]]; then
        fail2ban-client set sshd unbanip $IP
        echo "Unbanned $IP (from $COUNTRY)"
    fi
done
```

### 3. Honeypot SSH sur port 22

```bash
# Garder le vrai SSH sur port 2222
# Port 22 en mode honeypot pour logger les attaquants

# Installation cowrie (honeypot SSH)
sudo apt install python3-pip
sudo pip3 install cowrie

# Configuration
# SSH réel sur 2222
Port 2222

# Cowrie écoute sur 22 et log toutes les tentatives
# Permet d'étudier les techniques des attaquants
```

### 4. Rotation automatique des clés SSH

```bash
#!/bin/bash
# Script de rotation mensuelle des clés autorisées

# Générer nouvelle paire
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_new -C "$(date +%Y%m)"

# Déployer sur serveurs
for SERVER in server1 server2 server3; do
    ssh-copy-id -i ~/.ssh/id_ed25519_new.pub user@$SERVER
done

# Après validation, supprimer l'ancienne
rm ~/.ssh/id_ed25519.old*
mv ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.old
mv ~/.ssh/id_ed25519_new ~/.ssh/id_ed25519
```

### 5. Analyse forensique post-attaque

```bash
#!/bin/bash
# Analyse détaillée après détection d'intrusion

IP=$1  # IP suspecte

echo "=== Analyse forensique pour $IP ==="

# Toutes les tentatives de cette IP
echo "--- Tentatives d'authentification ---"
grep "$IP" /var/log/auth.log | grep -E "Failed|Accepted"

# Utilisateurs testés
echo "--- Utilisateurs ciblés ---"
grep "$IP" /var/log/auth.log | grep "Failed password" | \
awk '{for(i=1;i<=NF;i++) if ($i=="for") print $(i+1)}' | sort | uniq -c

# Timing des attaques
echo "--- Timeline ---"
grep "$IP" /var/log/auth.log | awk '{print $1, $2, $3}'

# Whois
echo "--- WHOIS ---"
whois "$IP" | grep -E "OrgName|Country|NetRange"

# Vérifier si dans base de réputation
echo "--- Réputation (AbuseIPDB) ---"
curl -s "https://api.abuseipdb.com/api/v2/check?ipAddress=$IP" \
    -H "Key: YOUR_API_KEY" | jq '.data.abuseConfidenceScore'
```

---

## 📝 Checklist de mise en production

```bash
# Avant de déployer en production, vérifier:

☐ Backup de la configuration actuelle créé
☐ Accès console/KVM disponible en cas de lockout
☐ Clés SSH déployées et testées pour tous les admins
☐ Script de réinitialisation automatique configuré (safety net)
☐ Fail2ban testé en mode debug
☐ Règles firewall testées depuis IP légitime
☐ Règles firewall testées depuis IP externe (lockout?)
☐ Documentation à jour (qui contacter, comment débannir)
☐ Monitoring et alertes configurés
☐ Tests de connexion depuis tous les emplacements légitimes
☐ Plan B défini si problème (restore, accès alternatif)
☐ Équipe prévenue des changements
☐ Fenêtre de maintenance planifiée
☐ Rollback procedure documentée

# Test final avant activation
sudo sshd -t  # Syntaxe SSH OK?
sudo fail2ban-client start  # Fail2ban démarre?
# Connexion test depuis IP autorisée
# Connexion test depuis IP non autorisée (doit échouer)
```

---

> [!tip] 💡 Le plus important La sécurité SSH n'est pas un état mais un processus continu. Surveillez régulièrement vos logs, mettez à jour vos règles selon les menaces émergentes, et testez régulièrement vos défenses. Un système non surveillé est un système vulnérable, même parfaitement configuré.