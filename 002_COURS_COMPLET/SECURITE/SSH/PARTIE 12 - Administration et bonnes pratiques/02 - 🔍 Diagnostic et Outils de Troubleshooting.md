

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

## 🗣️ Mode verbose SSH

### Pourquoi utiliser le mode verbose ?

Le mode verbose permet d'afficher le détail des opérations effectuées lors d'une connexion SSH. C'est l'outil principal pour comprendre **où** et **pourquoi** une connexion échoue.

> [!info] Niveaux de verbosité SSH propose trois niveaux de verbosité croissants :
> 
> - `-v` : Verbosité normale (affiche les étapes principales)
> - `-vv` : Verbosité élevée (détails des négociations)
> - `-vvv` : Verbosité maximale (informations de débogage complètes)

### Syntaxe et utilisation

```bash
# Verbosité niveau 1 (suffisant dans la plupart des cas)
ssh -v utilisateur@serveur.com

# Verbosité niveau 2 (pour problèmes d'authentification)
ssh -vv utilisateur@serveur.com

# Verbosité niveau 3 (débogage approfondi)
ssh -vvv utilisateur@serveur.com

# Combiner avec d'autres options
ssh -vv -p 2222 -i ~/.ssh/ma_cle utilisateur@serveur.com
```

### Interpréter les sorties verbose

> [!example] Exemple de sortie `-v`
> 
> ```
> OpenSSH_8.9p1, OpenSSL 3.0.2
> debug1: Reading configuration data /etc/ssh/ssh_config
> debug1: Connecting to example.com [93.184.216.34] port 22.
> debug1: Connection established.
> debug1: identity file /home/user/.ssh/id_rsa type 0
> debug1: Remote protocol version 2.0, remote software version OpenSSH_8.2
> debug1: Authenticating to example.com:22 as 'user'
> debug1: Offering public key: /home/user/.ssh/id_rsa RSA SHA256:xxxxx
> debug1: Server accepts key: /home/user/.ssh/id_rsa RSA SHA256:xxxxx
> debug1: Authentication succeeded (publickey).
> ```

**Les étapes clés à surveiller :**

|Étape|Ce qu'il faut vérifier|Message typique|
|---|---|---|
|**Résolution DNS**|L'hôte est-il accessible ?|`Connecting to [IP] port 22`|
|**Connexion TCP**|Le port est-il ouvert ?|`Connection established`|
|**Échange de protocole**|Versions compatibles ?|`Remote protocol version 2.0`|
|**Chargement des clés**|Clés trouvées et lisibles ?|`identity file ... type 0`|
|**Authentification**|Clé acceptée ? Mot de passe OK ?|`Authentication succeeded`|

### Scénarios courants et leur diagnostic

> [!warning] Connection timeout
> 
> ```
> debug1: Connecting to serveur.com [10.0.0.1] port 22.
> ssh: connect to host serveur.com port 22: Connection timed out
> ```
> 
> **Signification** : Pas de réponse du serveur (firewall, serveur éteint, mauvaise route réseau)

> [!warning] Connection refused
> 
> ```
> debug1: Connecting to serveur.com [10.0.0.1] port 22.
> ssh: connect to host serveur.com port 22: Connection refused
> ```
> 
> **Signification** : Le serveur répond mais aucun service SSH n'écoute sur ce port

> [!warning] Permission denied
> 
> ```
> debug1: Authentications that can continue: publickey,password
> debug1: Next authentication method: publickey
> debug1: Offering public key: /home/user/.ssh/id_rsa
> debug1: Authentications that can continue: publickey,password
> debug1: No more authentication methods to try.
> Permission denied (publickey,password).
> ```
> 
> **Signification** : Échec de toutes les méthodes d'authentification tentées

> [!tip] Astuce de filtrage Pour isoler uniquement les erreurs :
> 
> ```bash
> ssh -vv user@host 2>&1 | grep -i "error\|fail\|denied\|refused"
> ```

### Pièges courants

- **Trop de verbosité** : `-vvv` génère énormément de lignes, préférez `-v` en première approche
- **Sorties mixtes** : Le verbose va sur stderr, pensez à rediriger si vous sauvegardez : `ssh -v user@host 2> debug.log`
- **Informations sensibles** : Les sorties verboses peuvent contenir des noms de fichiers et chemins, attention lors du partage

---

## 📋 Analyse des logs serveur

### Où trouver les logs SSH côté serveur

> [!info] Emplacements standards selon les distributions
> 
> |Distribution|Fichier de log principal|
> |---|---|
> |**Ubuntu/Debian**|`/var/log/auth.log`|
> |**RHEL/CentOS/Fedora**|`/var/log/secure`|
> |**macOS**|`/var/log/system.log`|
> |**Générique**|`/var/log/syslog` (peut contenir SSH)|

### Configuration du niveau de log

Le niveau de détail des logs SSH serveur est défini dans `/etc/ssh/sshd_config` :

```bash
# Niveaux disponibles : QUIET, FATAL, ERROR, INFO, VERBOSE, DEBUG, DEBUG1, DEBUG2, DEBUG3
LogLevel INFO

# Pour un troubleshooting approfondi
LogLevel VERBOSE
# ou
LogLevel DEBUG
```

> [!warning] Attention Après modification de `sshd_config`, il faut redémarrer le service :
> 
> ```bash
> sudo systemctl restart sshd
> ```

### Consulter les logs en temps réel

```bash
# Suivre les logs SSH en temps réel (Ubuntu/Debian)
sudo tail -f /var/log/auth.log

# Sur RHEL/CentOS
sudo tail -f /var/log/secure

# Filtrer uniquement les messages SSH
sudo tail -f /var/log/auth.log | grep sshd

# Avec journalctl (systèmes avec systemd)
sudo journalctl -u ssh -f
# ou
sudo journalctl -u sshd -f
```

### Rechercher des événements spécifiques

```bash
# Toutes les tentatives de connexion échouées
sudo grep "Failed password" /var/log/auth.log

# Tentatives de connexion pour un utilisateur spécifique
sudo grep "user alice" /var/log/auth.log

# Connexions réussies
sudo grep "Accepted" /var/log/auth.log

# Tentatives depuis une IP spécifique
sudo grep "192.168.1.100" /var/log/auth.log

# Événements des dernières 24h avec journalctl
sudo journalctl -u sshd --since "24 hours ago"

# Entre deux dates
sudo journalctl -u sshd --since "2024-01-15 08:00" --until "2024-01-15 18:00"
```

> [!example] Exemples de lignes de log typiques
> 
> ```
> # Connexion réussie par clé publique
> Jan 15 10:23:45 server sshd[12345]: Accepted publickey for alice from 192.168.1.50 port 54321 ssh2: RSA SHA256:xxxxx
> 
> # Échec d'authentification par mot de passe
> Jan 15 10:25:12 server sshd[12346]: Failed password for bob from 192.168.1.51 port 54322 ssh2
> 
> # Utilisateur invalide
> Jan 15 10:27:03 server sshd[12347]: Invalid user charlie from 192.168.1.52 port 54323
> 
> # Déconnexion
> Jan 15 10:35:18 server sshd[12345]: Received disconnect from 192.168.1.50 port 54321:11: disconnected by user
> ```

### Analyser les patterns d'attaque

```bash
# Compter les tentatives échouées par IP
sudo grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn

# Lister les utilisateurs ciblés par des attaques
sudo grep "Invalid user" /var/log/auth.log | awk '{print $8}' | sort | uniq -c | sort -rn

# Statistiques quotidiennes
sudo grep "Failed password" /var/log/auth.log | awk '{print $1" "$2}' | sort | uniq -c
```

> [!tip] Outils d'analyse automatique Pour une analyse plus poussée, considérez des outils comme :
> 
> - `fail2ban` (protection automatique contre les attaques brute-force)
> - `logwatch` (rapports quotidiens par email)
> - `goaccess` (analyse visuelle des logs)

### Pièges courants

- **Rotation des logs** : Les anciens logs sont archivés (`.1`, `.gz`), pensez à les consulter aussi
- **Permissions** : Les logs nécessitent `sudo` pour être consultés
- **Fuseau horaire** : Vérifiez que l'horloge serveur est correcte lors du diagnostic temporel
- **Logs volumineux** : Utilisez `grep`, `awk`, et `tail` plutôt que d'ouvrir les fichiers entiers

---

## 🌐 Test de connectivité réseau

### Vue d'ensemble des outils

Avant de diagnostiquer SSH spécifiquement, il faut vérifier la connectivité réseau de base.

> [!info] Hiérarchie des tests
> 
> 1. **Connectivité IP** → `ping`
> 2. **Résolution DNS** → `nslookup` / `dig`
> 3. **Accessibilité du port** → `telnet` / `nc` / `nmap`
> 4. **Service SSH actif** → Tests de connexion

### Test avec ping

```bash
# Test de connectivité basique
ping -c 4 serveur.com

# Avec IP directe (pour exclure les problèmes DNS)
ping -c 4 93.184.216.34

# Définir un timeout
ping -c 4 -W 2 serveur.com

# Ping continu (Ctrl+C pour arrêter)
ping serveur.com
```

> [!warning] Limites de ping
> 
> - Certains serveurs/firewalls bloquent ICMP (ping)
> - Un ping qui échoue ne signifie pas forcément que le serveur est inaccessible
> - Un ping qui réussit ne garantit pas que SSH est accessible

**Interprétation des résultats :**

|Résultat|Signification|Action|
|---|---|---|
|`64 bytes from...`|Serveur accessible|Continuer les tests|
|`Request timeout`|Pas de réponse ICMP|Tester avec telnet/nc|
|`Unknown host`|Problème DNS|Vérifier résolution DNS|
|`Network is unreachable`|Problème routage local|Vérifier config réseau|

### Test de résolution DNS

```bash
# Vérifier la résolution DNS
nslookup serveur.com

# Plus d'informations avec dig
dig serveur.com

# Résolution inverse (IP vers nom)
dig -x 93.184.216.34

# Utiliser un serveur DNS spécifique
dig @8.8.8.8 serveur.com
```

> [!tip] Contourner un problème DNS Si la résolution DNS échoue mais que vous connaissez l'IP, utilisez-la directement :
> 
> ```bash
> ssh utilisateur@93.184.216.34
> ```

### Test de connectivité TCP avec telnet

```bash
# Tester si le port 22 est ouvert et accessible
telnet serveur.com 22

# Avec une IP
telnet 93.184.216.34 22

# Port non-standard
telnet serveur.com 2222
```

**Interprétation :**

```bash
# ✅ Port accessible
$ telnet serveur.com 22
Trying 93.184.216.34...
Connected to serveur.com.
Escape character is '^]'.
SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5

# ❌ Port fermé/filtré
$ telnet serveur.com 22
Trying 93.184.216.34...
telnet: Unable to connect to remote host: Connection refused

# ❌ Timeout (firewall ou serveur inaccessible)
$ telnet serveur.com 22
Trying 93.184.216.34...
telnet: Unable to connect to remote host: Connection timed out
```

> [!info] Sortir de telnet Pour quitter une session telnet : `Ctrl + ]` puis taper `quit`

### Test avec netcat (nc)

`netcat` est plus polyvalent et moderne que telnet :

```bash
# Test simple de port
nc -zv serveur.com 22

# Avec timeout de 5 secondes
nc -zv -w 5 serveur.com 22

# Tester une plage de ports
nc -zv serveur.com 20-25

# Mode verbeux pour plus de détails
nc -zvv serveur.com 22
```

**Options utiles :**

|Option|Signification|
|---|---|
|`-z`|Mode scan (pas de transfert de données)|
|`-v`|Verbeux|
|`-w N`|Timeout de N secondes|
|`-u`|Utiliser UDP au lieu de TCP|
|`-n`|Ne pas résoudre DNS (utiliser IP directement)|

> [!example] Exemple de diagnostic complet
> 
> ```bash
> # 1. Test ping
> ping -c 2 serveur.com
> 
> # 2. Vérification DNS
> nslookup serveur.com
> 
> # 3. Test du port SSH
> nc -zv -w 3 serveur.com 22
> 
> # 4. Si échec, tester ports standards
> nc -zv -w 3 serveur.com 21 22 23 80 443
> ```

### Test avec nmap (scan de ports avancé)

```bash
# Scanner le port SSH spécifiquement
nmap -p 22 serveur.com

# Détection de version
nmap -sV -p 22 serveur.com

# Scan rapide des ports communs
nmap --top-ports 20 serveur.com

# Scan complet mais plus lent
nmap -p- serveur.com
```

> [!warning] Considérations légales Le scan de ports avec nmap peut être considéré comme intrusif. N'utilisez nmap que sur :
> 
> - Vos propres serveurs
> - Des serveurs pour lesquels vous avez une autorisation explicite

### Pièges courants

- **Firewalls silencieux** : Certains firewalls ne répondent pas (ni refus, ni acceptation), causant des timeouts
- **Port non-standard** : SSH peut être sur un autre port que 22, vérifiez la configuration
- **IPv4 vs IPv6** : Certains serveurs sont uniquement accessibles en IPv4 ou IPv6
- **VPN/Proxy** : Votre connexion peut passer par un intermédiaire qui bloque certains ports

---

## ⚙️ Vérification des services et ports

### Vérifier l'état du service SSH

> [!info] Systèmes avec systemd (Ubuntu 16+, Debian 8+, CentOS 7+, etc.)

```bash
# Statut du service
sudo systemctl status ssh
# ou sur certaines distributions
sudo systemctl status sshd

# Vérifier si le service est actif
sudo systemctl is-active sshd

# Vérifier si le service démarre au boot
sudo systemctl is-enabled sshd

# Voir les dernières lignes de log
sudo systemctl status sshd -l
```

**Interprétation du statut :**

```bash
# ✅ Service actif et fonctionnel
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2024-01-15 10:00:00 UTC; 2h 30min ago
   Main PID: 1234 (sshd)

# ❌ Service arrêté
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: inactive (dead)

# ⚠️ Service en échec
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: failed (Result: exit-code)
```

> [!info] Systèmes avec init/SysV (anciennes distributions)

```bash
# Statut du service
sudo service ssh status
# ou
sudo /etc/init.d/ssh status

# Démarrer/arrêter le service
sudo service ssh start
sudo service ssh stop
sudo service ssh restart
```

### Gestion du service SSH

```bash
# Démarrer le service
sudo systemctl start sshd

# Arrêter le service
sudo systemctl stop sshd

# Redémarrer (après modification de config)
sudo systemctl restart sshd

# Recharger la config sans couper les connexions actives
sudo systemctl reload sshd

# Activer au démarrage
sudo systemctl enable sshd

# Désactiver au démarrage
sudo systemctl disable sshd
```

> [!warning] Restart vs Reload
> 
> - `restart` : Coupe toutes les connexions actives
> - `reload` : Préserve les connexions actives, mais certaines options nécessitent un restart

### Vérifier les ports en écoute

```bash
# Lister tous les ports en écoute
sudo ss -tuln

# Filtrer uniquement SSH (port 22)
sudo ss -tuln | grep :22

# Avec netstat (ancien mais toujours utilisé)
sudo netstat -tuln | grep :22

# Afficher le processus associé
sudo ss -tulnp | grep ssh
sudo netstat -tulnp | grep ssh

# Lister avec lsof
sudo lsof -i :22
```

**Options expliquées :**

|Option|Signification|
|---|---|
|`-t`|TCP|
|`-u`|UDP|
|`-l`|Listening (en écoute)|
|`-n`|Numérique (ne pas résoudre les noms)|
|`-p`|Afficher le processus|

> [!example] Sortie typique
> 
> ```bash
> $ sudo ss -tulnp | grep ssh
> tcp   LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=1234,fd=3))
> tcp   LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=1234,fd=4))
> ```
> 
> **Interprétation** : SSH écoute sur le port 22, en IPv4 (0.0.0.0) et IPv6 (::), processus sshd avec PID 1234

### Vérifier sur quel(s) port(s) SSH écoute

```bash
# Consulter la configuration
grep "^Port" /etc/ssh/sshd_config

# Si aucun résultat, le port par défaut (22) est utilisé
grep "^#Port" /etc/ssh/sshd_config

# Vérifier toutes les directives Listen
grep -E "^(Port|ListenAddress)" /etc/ssh/sshd_config
```

> [!tip] Configuration multi-ports
> 
> ```bash
> # Dans /etc/ssh/sshd_config, SSH peut écouter sur plusieurs ports :
> Port 22
> Port 2222
> 
> # Ou sur des interfaces spécifiques :
> ListenAddress 0.0.0.0:22
> ListenAddress 192.168.1.10:2222
> ```

### Tester la configuration SSH avant de redémarrer

```bash
# Vérifier la syntaxe de sshd_config
sudo sshd -t

# Mode verbeux pour plus de détails
sudo sshd -T

# Tester une configuration spécifique
sudo sshd -t -f /etc/ssh/sshd_config.test
```

> [!warning] Validation avant restart **Toujours** tester la configuration avec `sshd -t` avant de redémarrer le service, sinon vous risquez de vous enfermer dehors !

### Diagnostiquer pourquoi SSH ne démarre pas

```bash
# Voir les erreurs complètes
sudo systemctl status sshd -l

# Consulter les logs récents
sudo journalctl -u sshd -n 50

# Logs en temps réel
sudo journalctl -u sshd -f

# Démarrer en mode debug (temporaire)
sudo /usr/sbin/sshd -d -p 2223
```

> [!example] Erreurs courantes au démarrage
> 
> ```
> # ❌ Erreur de permissions sur les clés
> Permissions 0644 for '/etc/ssh/ssh_host_rsa_key' are too open.
> → Solution : chmod 600 /etc/ssh/ssh_host_rsa_key
> 
> # ❌ Port déjà utilisé
> error: Bind to port 22 on 0.0.0.0 failed: Address already in use.
> → Solution : Vérifier quel processus utilise le port avec : sudo lsof -i :22
> 
> # ❌ Erreur de syntaxe dans la config
> /etc/ssh/sshd_config line 42: Bad configuration option: InvalidOption
> → Solution : Corriger ou commenter la ligne problématique
> 
> # ❌ Clé hôte manquante
> Could not load host key: /etc/ssh/ssh_host_ed25519_key
> → Solution : Régénérer les clés : sudo ssh-keygen -A
> ```

### Vérifier les connexions SSH actives

```bash
# Lister les connexions SSH établies
sudo ss -o state established '( dport = :22 or sport = :22 )'

# Avec netstat
sudo netstat -tnpa | grep 'ESTABLISHED.*sshd'

# Voir les utilisateurs connectés en SSH
w
# ou
who
```

> [!example] Sortie de la commande `w`
> 
> ```
> $ w
>  14:23:45 up 5 days,  3:42,  2 users,  load average: 0.15, 0.10, 0.08
> USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
> alice    pts/0    192.168.1.50     10:23    0.00s  0.12s  0.01s w
> bob      pts/1    192.168.1.51     14:10    5:00   0.08s  0.08s -bash
> ```

### Vérifier les règles de firewall

```bash
# UFW (Ubuntu/Debian)
sudo ufw status verbose
sudo ufw status numbered

# Firewalld (RHEL/CentOS/Fedora)
sudo firewall-cmd --list-all
sudo firewall-cmd --list-ports

# iptables (direct)
sudo iptables -L -n -v
sudo iptables -L INPUT -n -v | grep 22

# Vérifier si SSH est autorisé
sudo ufw app list
sudo ufw status | grep -i ssh
```

> [!tip] Autoriser SSH dans le firewall
> 
> ```bash
> # UFW
> sudo ufw allow ssh
> # ou port spécifique
> sudo ufw allow 2222/tcp
> 
> # Firewalld
> sudo firewall-cmd --permanent --add-service=ssh
> sudo firewall-cmd --reload
> 
> # iptables
> sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
> ```

### Pièges courants

- **Service nommé différemment** : `ssh` vs `sshd` selon la distribution
- **Plusieurs instances** : Parfois SSH tourne sur plusieurs ports avec plusieurs processus
- **Changement de port** : Après modification du port, pensez à mettre à jour le firewall
- **SELinux/AppArmor** : Ces systèmes de sécurité peuvent bloquer SSH, vérifiez leurs logs
- **Modifications perdues** : Certaines modifs nécessitent un `restart`, d'autres un `reload`

---

## 🎯 Méthodologie de diagnostic complète

> [!tip] Approche systématique Lors d'un problème SSH, suivez cette séquence :
> 
> 1. **Client** : `ssh -vv user@host` (observer où ça bloque)
> 2. **Réseau** : `ping`, `nc -zv host 22` (connectivité basique)
> 3. **Serveur** : `sudo systemctl status sshd` (service actif ?)
> 4. **Ports** : `sudo ss -tuln | grep :22` (écoute sur le bon port ?)
> 5. **Logs serveur** : `sudo journalctl -u sshd -n 50` (erreurs ?)
> 6. **Firewall** : `sudo ufw status` ou `sudo firewall-cmd --list-all`
> 
> Cette méthodologie permet d'isoler rapidement la source du problème.

---

## 📝 Récapitulatif des commandes essentielles

|Objectif|Commande|
|---|---|
|**Connexion verbose**|`ssh -v user@host`|
|**Logs serveur temps réel**|`sudo tail -f /var/log/auth.log`|
|**Test de port**|`nc -zv host 22`|
|**Statut du service**|`sudo systemctl status sshd`|
|**Ports en écoute**|`sudo ss -tuln \| grep :22`|
|**Valider config SSH**|`sudo sshd -t`|
|**Connexions actives**|`w` ou `who`|
|**Redémarrer SSH**|`sudo systemctl restart sshd`|