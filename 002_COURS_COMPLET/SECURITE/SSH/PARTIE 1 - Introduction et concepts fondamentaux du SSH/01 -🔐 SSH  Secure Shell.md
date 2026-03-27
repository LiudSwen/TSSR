

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

## 🎯 Définition et historique

### Qu'est-ce que SSH ?

**SSH (Secure Shell)** est un protocole réseau cryptographique permettant d'établir une communication sécurisée entre deux machines sur un réseau non sécurisé. Il permet principalement :

- **L'accès distant à un shell** (ligne de commande) sur une machine distante
- **L'exécution de commandes** sur un serveur distant
- **Le transfert de fichiers** de manière sécurisée
- **Le tunneling** de protocoles réseau (redirection de ports)
- **L'authentification forte** par clés cryptographiques

> [!info] Principe fondamental SSH remplace les anciens protocoles d'administration à distance (Telnet, rlogin, rsh) en chiffrant l'intégralité des échanges, protégeant ainsi contre l'écoute réseau (sniffing), l'interception et les attaques de type "man-in-the-middle".

### 📜 Historique

|Année|Événement|
|---|---|
|**1995**|Tatu Ylönen (Université de technologie d'Helsinki) crée SSH-1 après qu'une attaque par sniffing de mots de passe ait compromis son réseau universitaire|
|**1995**|Sortie de la première version publique (SSH-1.0)|
|**1996**|Tatu Ylönen fonde SSH Communications Security pour commercialiser SSH|
|**1996**|SSH-1.5 corrige des failles de sécurité de SSH-1.0|
|**1999**|Lancement du projet OpenSSH par l'équipe OpenBSD, qui deviendra l'implémentation de référence|
|**2006**|SSH-2 devient un standard IETF (RFC 4251 à 4254)|
|**Aujourd'hui**|SSH est le standard de facto pour l'administration système à distance|

> [!tip] OpenSSH OpenSSH est aujourd'hui l'implémentation SSH la plus utilisée au monde. Elle est open source, gratuite, et intégrée par défaut dans la plupart des systèmes Unix/Linux, macOS, et depuis Windows 10.

### 🔑 Cas d'usage principaux

**1. Administration système à distance**

```bash
# Connexion à un serveur distant
ssh admin@serveur.exemple.com
```

**2. Transfert de fichiers sécurisé**

```bash
# Avec SCP (Secure Copy)
scp fichier.txt user@serveur:/chemin/destination/

# Avec SFTP (SSH File Transfer Protocol)
sftp user@serveur
```

**3. Exécution de commandes distantes**

```bash
# Exécuter une commande sans ouvrir de session interactive
ssh user@serveur "df -h"
```

**4. Tunneling et redirection de ports**

```bash
# Créer un tunnel sécurisé pour accéder à un service distant
ssh -L 8080:localhost:80 user@serveur
```

---

## 🔄 Différences avec Telnet et rlogin

### Vue d'ensemble comparative

|Caractéristique|SSH|Telnet|rlogin|
|---|---|---|---|
|**Chiffrement**|✅ Complet|❌ Aucun|❌ Aucun|
|**Authentification**|Fort (clés/mot de passe)|Faible (mot de passe)|Très faible (.rhosts)|
|**Port par défaut**|22|23|513|
|**Intégrité des données**|✅ Garantie|❌ Non garantie|❌ Non garantie|
|**Transfert de fichiers**|✅ Intégré (SCP/SFTP)|❌ Non|❌ Non|
|**Redirection de ports**|✅ Oui|❌ Non|❌ Non|
|**Utilisation moderne**|✅ Standard actuel|⚠️ Obsolète|⚠️ Obsolète|

### 🚫 Telnet : Le protocole non sécurisé

**Telnet** (Telecommunication Network) est un protocole de communication datant de 1969.

> [!warning] Danger critique Telnet transmet **TOUT en clair** : mots de passe, commandes, données. Un attaquant écoutant le réseau peut capturer l'intégralité de la session avec des outils comme Wireshark.

**Exemple de vulnérabilité Telnet :**

```bash
# Connexion Telnet (DANGEREUX)
telnet serveur.exemple.com

# Un attaquant sur le réseau peut capturer :
# - Le nom d'utilisateur : "admin"
# - Le mot de passe : "MonMotDePasse123"
# - Toutes les commandes exécutées
```

**Pourquoi Telnet est dangereux :**

- Aucun chiffrement des données
- Mots de passe transmis en texte brut
- Vulnérable aux attaques man-in-the-middle
- Pas d'authentification mutuelle serveur/client
- Pas de vérification de l'intégrité des données

> [!info] Cas d'usage légitimes de Telnet Telnet reste utilisé uniquement pour :
> 
> - Tester la connectivité TCP vers un port spécifique
> - Administrer des équipements réseau anciens sur des réseaux isolés
> - Déboguer des protocoles textuels (HTTP, SMTP) à des fins pédagogiques

### 🔓 rlogin et les r-commands : Sécurité basée sur la confiance

**rlogin** (remote login) fait partie de la suite "r-commands" (rsh, rcp, rexec) développée pour BSD Unix.

**Principe de fonctionnement :**

- Authentification basée sur des fichiers `.rhosts` et `/etc/hosts.equiv`
- Confiance accordée à certaines machines du réseau
- Connexion sans mot de passe depuis les machines "de confiance"

```bash
# Exemple de fichier .rhosts (DANGEREUX)
serveur1.exemple.com utilisateur1
serveur2.exemple.com utilisateur2
```

> [!warning] Failles de sécurité majeures
> 
> - **IP spoofing** : Un attaquant peut usurper l'adresse IP d'une machine de confiance
> - **Aucun chiffrement** : Comme Telnet, tout transite en clair
> - **Confiance aveugle** : Le système fait confiance à l'adresse IP, facilement falsifiable
> - **Fichiers .rhosts** : Souvent mal configurés, permettant des accès non autorisés

**Les r-commands incluent :**

```bash
# rlogin : connexion distante
rlogin serveur.exemple.com

# rsh : exécution de commandes distantes
rsh serveur.exemple.com ls -la

# rcp : copie de fichiers
rcp fichier.txt serveur.exemple.com:/tmp/
```

### ✅ SSH : La solution moderne et sécurisée

**Ce que SSH apporte par rapport à Telnet et rlogin :**

**1. Chiffrement complet**

```bash
# Toutes les données sont chiffrées end-to-end
ssh user@serveur
# Le mot de passe, les commandes, les résultats : TOUT est chiffré
```

**2. Authentification forte**

- Par mot de passe (chiffré lors de la transmission)
- Par clés cryptographiques (RSA, Ed25519, ECDSA)
- Authentification mutuelle (le client vérifie l'identité du serveur)

**3. Intégrité des données**

- Détection des modifications de données en transit
- Protection contre les attaques man-in-the-middle
- Codes d'authentification de message (MAC)

**4. Fonctionnalités avancées**

- Compression des données
- Multiplexage de connexions
- Agent d'authentification
- Transfert X11 sécurisé
- Tunneling de ports

> [!tip] Migration de Telnet/rlogin vers SSH La transition est simple :
> 
> ```bash
> # Ancienne méthode (DANGEREUSE)
> telnet serveur.com
> rlogin serveur.com
> 
> # Nouvelle méthode (SÉCURISÉE)
> ssh user@serveur.com
> ```

### 🔍 Comparaison technique des protocoles

**Architecture de sécurité :**

```
┌─────────────────────────────────────────────────────────┐
│                      TELNET / RLOGIN                     │
├─────────────────────────────────────────────────────────┤
│  Client ◄────────[Texte en clair]────────► Serveur     │
│                                                          │
│  👁️ Attaquant peut lire TOUT le trafic                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                          SSH                             │
├─────────────────────────────────────────────────────────┤
│  Client ◄──[Tunnel chiffré AES/ChaCha20]──► Serveur    │
│                                                          │
│  🔒 Chiffrement • Authentification • Intégrité          │
│  👁️ Attaquant ne voit que des données chiffrées         │
└─────────────────────────────────────────────────────────┘
```

---

## 🔢 Versions du protocole (SSH-1 vs SSH-2)

### SSH-1 : La première génération (1995-2006)

**SSH-1** était une avancée majeure lors de sa sortie, mais présente aujourd'hui des failles de sécurité connues.

> [!warning] SSH-1 est obsolète et dangereux SSH-1 ne doit **JAMAIS** être utilisé en production. Il est désactivé par défaut dans toutes les implémentations modernes.

**Caractéristiques de SSH-1 :**

- Chiffrement : DES, 3DES, Blowfish, IDEA
- Authentification : RSA uniquement
- Vérification d'intégrité : CRC-32 (faible)

**Vulnérabilités majeures de SSH-1 :**

|Vulnérabilité|Description|Impact|
|---|---|---|
|**Insertion de données**|Faille dans le CRC-32 permettant de modifier les paquets|Compromission de l'intégrité|
|**Fuite de clés**|Mauvaise gestion de la mémoire et des clés temporaires|Récupération potentielle des clés|
|**Attaque MITM**|Faiblesse dans l'échange de clés initial|Interception possible de session|
|**Algorithmes faibles**|DES considéré cassé, CRC-32 insuffisant|Déchiffrement possible|

```bash
# Forcer SSH-1 (NE JAMAIS FAIRE)
ssh -1 user@serveur  # Option dépréciée et bloquée par défaut
```

### SSH-2 : La version moderne (1996-présent)

**SSH-2** est une réécriture complète du protocole, incompatible avec SSH-1, corrigeant toutes ses failles.

> [!info] SSH-2 est le standard actuel Toutes les connexions SSH modernes utilisent exclusivement SSH-2. C'est le protocole standardisé par l'IETF (RFC 4251-4254).

**Améliorations majeures de SSH-2 :**

**1. Sécurité renforcée**

```bash
# Algorithmes cryptographiques modernes
- Chiffrement : AES, ChaCha20, 3DES
- Échange de clés : Diffie-Hellman, ECDH, Curve25519
- Authentification : RSA, DSA, ECDSA, Ed25519
- Intégrité : HMAC-SHA1, HMAC-SHA2-256, HMAC-SHA2-512
```

**2. Protocole en couches** SSH-2 est organisé en trois protocoles distincts :

```
┌─────────────────────────────────────────────┐
│     SSH-USERAUTH (Authentification)         │
│           RFC 4252                           │
├─────────────────────────────────────────────┤
│     SSH-CONNECTION (Canaux multiples)       │
│           RFC 4254                           │
├─────────────────────────────────────────────┤
│     SSH-TRANS (Couche transport)            │
│     RFC 4253 - Chiffrement de base          │
├─────────────────────────────────────────────┤
│              TCP (Port 22)                  │
└─────────────────────────────────────────────┘
```

**3. Fonctionnalités avancées**

- **Canaux multiples** : Plusieurs sessions simultanées dans une connexion
- **Transfert de ports** : Local et distant (tunneling)
- **Subsystèmes** : SFTP intégré nativement
- **Renégociation de clés** : Changement périodique automatique des clés
- **Compression** : Réduction de la bande passante

### 📊 Comparaison détaillée SSH-1 vs SSH-2

|Aspect|SSH-1|SSH-2|
|---|---|---|
|**Architecture**|Monolithique|Modulaire (3 couches)|
|**Vérification d'intégrité**|CRC-32 (cassé)|HMAC-SHA2 (robuste)|
|**Échange de clés**|RSA simple|Diffie-Hellman, ECDH|
|**Types de clés**|RSA uniquement|RSA, DSA, ECDSA, Ed25519|
|**Canaux multiples**|❌ Non|✅ Oui|
|**SFTP natif**|❌ Non|✅ Oui|
|**Renégociation**|❌ Non|✅ Automatique|
|**Sécurité**|⚠️ Vulnérable|✅ Robuste|
|**Standard IETF**|❌ Non|✅ Oui (RFC 4251-4254)|

### 🔐 Sécurité en pratique

**Vérifier la version SSH utilisée :**

```bash
# Afficher la version du client SSH
ssh -V
# Exemple de sortie : OpenSSH_9.0p1, OpenSSL 3.0.2

# Vérifier les protocoles supportés par un serveur
ssh -v user@serveur 2>&1 | grep "protocol"
```

**Configuration serveur (désactiver SSH-1) :**

```bash
# Dans /etc/ssh/sshd_config
Protocol 2  # Force l'utilisation exclusive de SSH-2
```

> [!tip] Bonnes pratiques
> 
> - **Toujours** utiliser SSH-2 (c'est le défaut depuis 2001+)
> - Vérifier que `Protocol 2` est défini dans la configuration serveur
> - Désactiver explicitement SSH-1 si votre système le supporte encore
> - Mettre à jour régulièrement OpenSSH pour bénéficier des derniers correctifs

### 🚀 Évolution continue

SSH-2 continue d'évoluer avec de nouveaux algorithmes :

**Algorithmes modernes recommandés :**

```bash
# Algorithmes d'échange de clés
- curve25519-sha256 (le plus rapide et sûr)
- diffie-hellman-group-exchange-sha256

# Algorithmes de chiffrement
- chacha20-poly1305@openssh.com (très performant)
- aes256-gcm@openssh.com
- aes128-gcm@openssh.com

# Algorithmes de signature
- ssh-ed25519 (recommandé, le plus moderne)
- ecdsa-sha2-nistp256
- rsa-sha2-512
```

**Configuration moderne optimale :**

```bash
# Dans ~/.ssh/config ou /etc/ssh/ssh_config
Host *
    # Utiliser les algorithmes les plus sécurisés
    KexAlgorithms curve25519-sha256,diffie-hellman-group-exchange-sha256
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
    HostKeyAlgorithms ssh-ed25519,ecdsa-sha2-nistp256,rsa-sha2-512
```

---

## 🌐 Port par défaut et protocole TCP

### Port 22 : Le standard SSH

SSH utilise par défaut le **port TCP 22** pour toutes ses communications.

> [!info] Pourquoi le port 22 ? Le port 22 a été officiellement assigné à SSH par l'IANA (Internet Assigned Numbers Authority) en 1995. C'est un port dans la plage des "Well Known Ports" (0-1023), réservés aux services système.

**Structure de connexion SSH :**

```
Client SSH                              Serveur SSH
(Port source aléatoire)                 (Port 22)
         │                                   │
         │     ───── TCP SYN ────────►       │
         │     ◄──── TCP SYN-ACK ─────       │
         │     ───── TCP ACK ────────►       │
         │                                   │
         │  ┌─────────────────────────────┐  │
         │  │  Établissement connexion TCP │  │
         │  └─────────────────────────────┘  │
         │                                   │
         │  ───── Handshake SSH ──────►      │
         │  ◄──── Version SSH ─────────      │
         │  ───── Échange de clés ─────►     │
         │  ◄──── Clé serveur ──────────     │
         │                                   │
         │  [Tunnel chiffré établi]          │
         │  ═════════════════════════════    │
```

### 🔌 TCP : Le protocole de transport

**Pourquoi SSH utilise TCP et non UDP ?**

|Caractéristique|TCP (utilisé par SSH)|UDP (non utilisé)|
|---|---|---|
|**Connexion**|Orienté connexion|Sans connexion|
|**Fiabilité**|Garantie de livraison|Pas de garantie|
|**Ordre**|Ordre des paquets préservé|Pas d'ordre|
|**Contrôle d'erreur**|Retransmission automatique|Pas de retransmission|
|**Contrôle de flux**|Oui (flow control)|Non|
|**Usage SSH**|✅ Idéal|❌ Inadapté|

> [!info] Pourquoi TCP est essentiel pour SSH SSH nécessite une connexion fiable car :
> 
> - Les commandes doivent arriver dans l'ordre exact
> - La perte de paquets corromprait le flux chiffré
> - L'authentification et l'établissement du tunnel nécessitent un échange en plusieurs étapes
> - Le chiffrement par bloc dépend de l'intégrité de la séquence

**Connexion SSH détaillée :**

```bash
# Établissement d'une connexion SSH
ssh user@serveur.exemple.com

# Ce qui se passe en coulisses :
# 1. Résolution DNS : serveur.exemple.com → 192.168.1.10
# 2. Connexion TCP vers 192.168.1.10:22
# 3. Three-way handshake TCP (SYN, SYN-ACK, ACK)
# 4. Échange de versions SSH
# 5. Échange de clés (Key Exchange)
# 6. Authentification utilisateur
# 7. Établissement du canal chiffré
# 8. Session interactive prête
```

### 🔄 Changer le port SSH

**Pourquoi changer le port par défaut ?**

> [!tip] Sécurité par l'obscurité (complément) Changer le port SSH du 22 vers un autre port réduit le bruit des scans automatisés et des attaques de bots, mais ce n'est **PAS** une mesure de sécurité suffisante en soi. C'est un complément à des pratiques robustes.

**Avantages :**

- ✅ Réduction drastique des tentatives de connexion automatisées
- ✅ Moins de logs pollués par des scans de bots
- ✅ Protection supplémentaire contre les attaques de masse

**Inconvénients :**

- ⚠️ Donne un faux sentiment de sécurité
- ⚠️ Nécessite de se souvenir du port ou de le documenter
- ⚠️ Peut compliquer la configuration dans certains environnements

**Configuration côté serveur :**

```bash
# Éditer /etc/ssh/sshd_config
sudo nano /etc/ssh/sshd_config

# Modifier la ligne Port
Port 2222  # ou n'importe quel port > 1024 disponible

# Redémarrer le service SSH
sudo systemctl restart sshd

# Vérifier que le nouveau port est en écoute
sudo ss -tlnp | grep sshd
# LISTEN    0    128    0.0.0.0:2222    0.0.0.0:*    users:(("sshd",pid=1234,fd=3))
```

**Configuration pare-feu :**

```bash
# Avec ufw (Ubuntu/Debian)
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp  # Après avoir vérifié que le nouveau port fonctionne

# Avec firewalld (RHEL/CentOS)
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --permanent --remove-service=ssh
sudo firewall-cmd --reload

# Avec iptables
sudo iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
sudo iptables -D INPUT -p tcp --dport 22 -j ACCEPT
```

**Connexion sur un port personnalisé :**

```bash
# Option -p pour spécifier le port
ssh -p 2222 user@serveur.exemple.com

# Configuration permanente dans ~/.ssh/config
Host monserveur
    HostName serveur.exemple.com
    User user
    Port 2222

# Puis connexion simplifiée
ssh monserveur
```

### 📡 Analyse réseau d'une connexion SSH

**Visualiser les connexions SSH actives :**

```bash
# Voir les connexions SSH établies
sudo ss -tnp | grep ':22'
# tcp   ESTAB  0  0  192.168.1.10:22  192.168.1.100:54321  users:(("sshd",pid=5678))

# Avec netstat (ancien outil)
sudo netstat -tnp | grep ':22'

# Statistiques détaillées
sudo ss -s | grep -i tcp
```

**Capture de trafic SSH (analyse) :**

```bash
# Capturer le trafic SSH avec tcpdump
sudo tcpdump -i eth0 port 22 -w ssh_capture.pcap

# Observer en temps réel (sans enregistrement)
sudo tcpdump -i eth0 port 22 -v

# Analyser une capture
wireshark ssh_capture.pcap
```

> [!info] Ce que vous verrez dans Wireshark
> 
> - Les paquets TCP (SYN, ACK, PSH, FIN)
> - L'échange de versions SSH en clair (SSH-2.0-OpenSSH_X.X)
> - Ensuite, uniquement des données chiffrées incompréhensibles
> - Les métadonnées : IP source/dest, ports, taille des paquets

### 🛡️ Sécurisation du port SSH

**Bonnes pratiques :**

**1. Limitation par pare-feu**

```bash
# N'autoriser SSH que depuis des IP spécifiques
sudo ufw allow from 192.168.1.0/24 to any port 22

# Ou avec iptables
sudo iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j DROP
```

**2. Fail2ban contre les attaques par force brute**

```bash
# Installation (Debian/Ubuntu)
sudo apt install fail2ban

# Configuration SSH dans /etc/fail2ban/jail.local
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600

# Redémarrer Fail2ban
sudo systemctl restart fail2ban

# Vérifier les IP bannies
sudo fail2ban-client status sshd
```

**3. Détecter les scans de ports**

```bash
# Avec portsentry (détection de scan)
sudo apt install portsentry

# Surveiller les logs d'authentification
sudo tail -f /var/log/auth.log | grep sshd
```

### 🌍 SSH dans différents contextes réseau

**1. Réseau local (LAN)**

```bash
# Connexion directe sur le réseau local
ssh user@192.168.1.50
# Pas de NAT, connexion directe au port 22
```

**2. Internet (accès distant)**

```bash
# Connexion via Internet nécessite souvent une configuration NAT
ssh user@ip-publique.exemple.com

# Sur le routeur, redirection de port (NAT/PAT)
# Port externe 22 → Port interne 192.168.1.50:22
```

**3. Derrière un proxy**

```bash
# Utiliser un proxy HTTP/HTTPS pour SSH
ssh -o ProxyCommand='nc -X connect -x proxy.exemple.com:8080 %h %p' user@serveur

# Configuration permanente dans ~/.ssh/config
Host serveur-via-proxy
    HostName serveur.exemple.com
    ProxyCommand nc -X connect -x proxy.exemple.com:8080 %h %p
```

**4. VPN et SSH**

```bash
# Se connecter au VPN puis SSH
sudo openvpn --config client.ovpn
# Puis connexion SSH sur le réseau VPN
ssh user@10.8.0.1
```

### 🔍 Diagnostic de connectivité SSH

**Tester l'accessibilité du port SSH :**

```bash
# Avec netcat (nc)
nc -zv serveur.exemple.com 22
# Connection to serveur.exemple.com 22 port [tcp/ssh] succeeded!

# Avec telnet
telnet serveur.exemple.com 22
# Connected to serveur.exemple.com.
# SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.1

# Avec nmap (scan de port)
nmap -p 22 serveur.exemple.com
# 22/tcp open  ssh

# Test de connectivité SSH avec timeout
timeout 5 ssh -v user@serveur.exemple.com 2>&1 | head -20
```

**Diagnostiquer les problèmes de connexion :**

```bash
# Mode verbeux (debug)
ssh -v user@serveur.exemple.com
# -vv ou -vvv pour encore plus de détails

# Vérifier les routes réseau
traceroute serveur.exemple.com

# Tester depuis le serveur lui-même
sudo ss -tlnp | grep :22
# Vérifie que sshd écoute bien sur le port 22
```

> [!warning] Problèmes courants
> 
> - **Connection refused** : Le service SSH n'est pas démarré ou le port est bloqué
> - **Connection timeout** : Pare-feu bloque le trafic ou mauvaise route réseau
> - **Permission denied** : Problème d'authentification (mot de passe ou clé)
> - **Host key verification failed** : Clé d'hôte changée (possible MITM)

---

## 🎓 Points clés à retenir

> [!tip] Résumé essentiel
> 
> 1. **SSH** est le standard de sécurité pour l'administration à distance, remplaçant Telnet/rlogin obsolètes
> 2. **SSH-2** est la seule version à utiliser (sécurité, fonctionnalités, standardisation)
> 3. Le **port 22/TCP** est le port par défaut, modifiable pour réduire les scans automatisés
> 4. Le protocole **TCP** garantit fiabilité et ordre, essentiels pour SSH
> 5. **Toujours privilégier la sécurité** : clés d'authentification, mise à jour régulière, pare-feu configuré

---

_Cours réalisé pour Obsidian - Partie 1/X sur SSH_