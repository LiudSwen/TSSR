

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

## 🌐 Introduction au Tunneling SSH

Le tunneling SSH est une fonctionnalité puissante qui permet de créer des tunnels chiffrés pour faire transiter du trafic réseau à travers une connexion SSH. C'est comme créer un "pont sécurisé" entre différents réseaux ou machines.

> [!info] Pourquoi utiliser le tunneling SSH ?
> 
> - **Sécurité** : Chiffrement du trafic entre deux points
> - **Contournement de pare-feu** : Accès à des services bloqués
> - **Accès distant sécurisé** : Connexion à des services internes depuis l'extérieur
> - **Protection de la vie privée** : Navigation anonyme via proxy

### Les trois types de tunneling

|Type|Direction|Usage principal|
|---|---|---|
|**Local**|Client → Serveur → Service|Accéder à un service distant via le serveur SSH|
|**Distant**|Serveur → Client → Service|Exposer un service local à travers le serveur SSH|
|**Dynamique**|Client ⇄ Serveur ⇄ Multiple|Proxy SOCKS pour navigation web sécurisée|

---

## 🔵 Tunneling Local (Local Port Forwarding)

Le tunneling local permet d'accéder à un service distant en passant par un serveur SSH intermédiaire. Le port local de votre machine est "forwardé" vers un service accessible depuis le serveur SSH.

### 📖 Concept

```
[Votre Machine] → [Serveur SSH] → [Service Cible]
   Port local      Tunnel chiffré    Port distant
```

### 🔧 Syntaxe de base

```bash
ssh -L [bind_address:]port_local:host_destination:port_destination user@serveur_ssh
```

**Décomposition des paramètres** :

- `-L` : Active le tunneling local
- `bind_address` : (Optionnel) Interface d'écoute locale (par défaut : localhost)
- `port_local` : Port sur votre machine qui écoutera les connexions
- `host_destination` : Hôte cible (vu depuis le serveur SSH)
- `port_destination` : Port du service sur l'hôte cible
- `user@serveur_ssh` : Serveur SSH intermédiaire

### 💡 Exemples pratiques

#### Exemple 1 : Accéder à une base de données distante

```bash
# Forwarder le port 3306 (MySQL) d'un serveur distant
ssh -L 3306:db.internal.company.com:3306 user@bastion.company.com

# Maintenant, connectez-vous localement :
mysql -h 127.0.0.1 -P 3306 -u dbuser -p
```

> [!example] Cas d'usage Votre base de données n'est accessible que depuis le réseau interne. Le serveur bastion a accès au réseau interne. Vous créez un tunnel pour y accéder depuis votre poste.

#### Exemple 2 : Accéder à une interface web interne

```bash
# Forwarder un serveur web interne sur le port local 8080
ssh -L 8080:intranet.company.com:80 user@bastion.company.com

# Accédez dans votre navigateur à : http://localhost:8080
```

#### Exemple 3 : Multiple tunnels simultanés

```bash
# Créer plusieurs tunnels en une seule connexion
ssh -L 3306:db.internal:3306 \
    -L 6379:redis.internal:6379 \
    -L 8080:web.internal:80 \
    user@bastion.company.com
```

### 🎯 Options avancées

#### Écouter sur toutes les interfaces

```bash
# Par défaut, seul localhost peut se connecter
ssh -L 8080:remote:80 user@server

# Permettre les connexions depuis d'autres machines du réseau local
ssh -L 0.0.0.0:8080:remote:80 user@server
# ou
ssh -L *:8080:remote:80 user@server
```

> [!warning] Sécurité Exposer un tunnel sur toutes les interfaces (`0.0.0.0` ou `*`) peut être dangereux. Assurez-vous que votre pare-feu local est correctement configuré.

#### Mode background

```bash
# Exécuter le tunnel en arrière-plan
ssh -fNL 8080:remote:80 user@server

# -f : Place SSH en arrière-plan avant l'exécution
# -N : Ne pas exécuter de commande distante (tunnel uniquement)
```

#### Tunnel persistant avec autossh

```bash
# Installation de autossh (si nécessaire)
sudo apt install autossh  # Debian/Ubuntu
sudo yum install autossh  # RedHat/CentOS

# Créer un tunnel qui se reconnecte automatiquement
autossh -M 0 -fNL 8080:remote:80 user@server

# -M 0 : Désactive le port de monitoring (utilise ServerAliveInterval à la place)
```

### 🔍 Vérification du tunnel

```bash
# Vérifier que le port local écoute
netstat -tuln | grep 8080
# ou
ss -tuln | grep 8080

# Tester la connexion
curl http://localhost:8080

# Voir les connexions SSH actives
ps aux | grep ssh
```

---

## 🔴 Tunneling Distant (Remote Port Forwarding)

Le tunneling distant fait l'inverse du tunneling local : il expose un service de votre machine locale (ou accessible depuis votre machine) sur le serveur SSH distant. Les connexions vers le serveur SSH sont "forwardées" vers votre machine.

### 📖 Concept

```
[Service Local] ← [Votre Machine] ← [Serveur SSH] ← [Clients distants]
                    Tunnel chiffré      Port exposé
```

### 🔧 Syntaxe de base

```bash
ssh -R [bind_address:]port_distant:host_local:port_local user@serveur_ssh
```

**Décomposition des paramètres** :

- `-R` : Active le tunneling distant
- `bind_address` : (Optionnel) Interface d'écoute sur le serveur (par défaut : localhost)
- `port_distant` : Port qui écoutera sur le serveur SSH
- `host_local` : Hôte cible (vu depuis votre machine)
- `port_local` : Port du service local
- `user@serveur_ssh` : Serveur SSH qui exposera le service

### 💡 Exemples pratiques

#### Exemple 1 : Exposer un serveur web local

```bash
# Votre serveur web local sur le port 3000 devient accessible
# sur le serveur distant au port 8080
ssh -R 8080:localhost:3000 user@public-server.com

# Sur le serveur distant, les utilisateurs peuvent accéder à :
# http://localhost:8080 (qui pointe vers votre machine locale)
```

> [!example] Cas d'usage Vous développez une application en local et voulez la montrer à un client sans déployer. Vous créez un tunnel distant pour que le client accède à votre environnement de développement.

#### Exemple 2 : Contourner un NAT/pare-feu

```bash
# Votre machine est derrière un NAT et non accessible depuis Internet
# Exposer votre SSH local via un serveur public
ssh -R 2222:localhost:22 user@vps-public.com

# Depuis n'importe où, connectez-vous à votre machine via le VPS :
ssh -p 2222 user@vps-public.com
```

#### Exemple 3 : Accès à un service de développement

```bash
# Exposer une API locale pendant les tests
ssh -fNR 5000:localhost:5000 user@staging-server.com

# L'équipe de test peut maintenant accéder à votre API :
curl http://localhost:5000/api/endpoint
```

### 🎯 Configuration serveur SSH

Pour que le tunneling distant fonctionne correctement, le serveur SSH doit être configuré.

#### Configuration dans `/etc/ssh/sshd_config`

```bash
# Permettre le tunneling distant
GatewayPorts no    # Par défaut : écoute uniquement sur localhost
# ou
GatewayPorts yes   # Écoute sur toutes les interfaces
# ou
GatewayPorts clientspecified  # Le client décide de l'interface

# Autoriser le forwarding TCP
AllowTcpForwarding yes

# Redémarrer SSH après modification
sudo systemctl restart sshd
```

> [!info] GatewayPorts expliqué
> 
> - `no` : Le port distant n'écoute que sur `127.0.0.1` du serveur
> - `yes` : Le port distant écoute sur `0.0.0.0` (toutes les interfaces)
> - `clientspecified` : Le client peut spécifier l'adresse d'écoute

#### Exemple avec GatewayPorts

```bash
# Avec GatewayPorts clientspecified ou yes
ssh -R 0.0.0.0:8080:localhost:3000 user@server.com
# ou
ssh -R *:8080:localhost:3000 user@server.com

# Le service est maintenant accessible depuis l'extérieur
curl http://server.com:8080
```

### ⚠️ Sécurité du tunneling distant

> [!warning] Risques de sécurité
> 
> - Exposer des services locaux peut créer des vulnérabilités
> - Avec `GatewayPorts yes`, n'importe qui peut accéder au service
> - Utilisez toujours un pare-feu et une authentification forte

```bash
# Bonne pratique : Limiter l'exposition avec iptables sur le serveur
sudo iptables -A INPUT -p tcp --dport 8080 -s TRUSTED_IP -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8080 -j DROP
```

---

## 🟣 Tunneling Dynamique (SOCKS Proxy)

Le tunneling dynamique crée un proxy SOCKS qui route tout le trafic à travers le serveur SSH. Contrairement aux tunnels local et distant qui forwardent un port spécifique, le proxy SOCKS gère dynamiquement plusieurs connexions vers différentes destinations.

### 📖 Concept

```
[Application] → [Proxy SOCKS local] → [Serveur SSH] → [Internet]
                    Port local          Tunnel chiffré
```

### 🔧 Syntaxe de base

```bash
ssh -D [bind_address:]port_local user@serveur_ssh
```

**Décomposition des paramètres** :

- `-D` : Active le tunneling dynamique (proxy SOCKS)
- `bind_address` : (Optionnel) Interface d'écoute (par défaut : localhost)
- `port_local` : Port local pour le proxy SOCKS (généralement 1080)
- `user@serveur_ssh` : Serveur SSH qui agira comme point de sortie

### 💡 Exemples pratiques

#### Exemple 1 : Proxy SOCKS basique

```bash
# Créer un proxy SOCKS sur le port 1080
ssh -D 1080 user@remote-server.com

# Le proxy SOCKS est maintenant actif sur localhost:1080
```

#### Exemple 2 : Mode background

```bash
# Lancer le proxy en arrière-plan
ssh -fND 1080 user@remote-server.com

# Vérifier que le proxy écoute
netstat -tuln | grep 1080
```

#### Exemple 3 : Proxy persistant

```bash
# Avec autossh pour maintenir la connexion
autossh -M 0 -fND 1080 user@remote-server.com

# Configuration dans ~/.ssh/config pour simplifier
cat >> ~/.ssh/config << EOF
Host socks-proxy
    HostName remote-server.com
    User user
    DynamicForward 1080
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF

# Puis simplement :
ssh -fN socks-proxy
```

### 🌐 Configuration des applications

#### Firefox

```
1. Ouvrir Paramètres → Général → Paramètres réseau
2. Configuration manuelle du proxy
3. Hôte SOCKS : localhost
4. Port : 1080
5. SOCKS v5
6. Cocher "DNS proxy avec SOCKS v5"
```

#### Chrome/Chromium (ligne de commande)

```bash
# Linux/Mac
google-chrome --proxy-server="socks5://localhost:1080"

# Windows
chrome.exe --proxy-server="socks5://localhost:1080"
```

#### Configuration système (Linux)

```bash
# Via les variables d'environnement
export ALL_PROXY=socks5://localhost:1080
export all_proxy=socks5://localhost:1080

# Tester avec curl
curl --socks5 localhost:1080 http://ifconfig.me
```

#### Configuration avec proxychains

```bash
# Installation
sudo apt install proxychains4

# Configuration dans /etc/proxychains4.conf
sudo nano /etc/proxychains4.conf

# Ajouter à la fin :
[ProxyList]
socks5 127.0.0.1 1080

# Utilisation
proxychains4 firefox
proxychains4 curl http://ifconfig.me
proxychains4 nmap -sT target.com
```

### 🔍 Vérification du proxy

```bash
# Vérifier votre IP publique sans proxy
curl http://ifconfig.me

# Vérifier votre IP publique avec le proxy SOCKS
curl --socks5 localhost:1080 http://ifconfig.me

# Les deux IPs devraient être différentes
```

### 🎯 Cas d'usage avancés

#### Exemple 1 : Contourner la censure géographique

```bash
# Se connecter à un serveur dans un autre pays
ssh -D 1080 user@server-japan.com

# Configurer votre navigateur pour utiliser le proxy
# Vous apparaissez maintenant comme étant au Japon
```

#### Exemple 2 : Navigation sécurisée sur WiFi public

```bash
# Se connecter à votre serveur personnel
ssh -D 1080 user@home-server.com

# Tout votre trafic passe maintenant par votre connexion maison
# Protection contre les attaques Man-in-the-Middle sur WiFi public
```

#### Exemple 3 : Accès à un réseau d'entreprise

```bash
# Créer un proxy vers le réseau interne via le bastion
ssh -D 1080 user@bastion.company.com

# Configurer les applications pour utiliser le proxy
# Accès transparent aux ressources internes
```

### 🔐 Combinaison avec autres tunnels

```bash
# Combiner proxy SOCKS et tunnels locaux
ssh -D 1080 \
    -L 3306:db.internal:3306 \
    -L 6379:redis.internal:6379 \
    user@bastion.company.com

# Vous avez maintenant :
# - Un proxy SOCKS sur le port 1080
# - Un accès direct MySQL sur le port 3306
# - Un accès direct Redis sur le port 6379
```

---

## 🎯 Use Cases Pratiques

### Scénario 1 : Accès à une infrastructure cloud privée

```bash
# Contexte : Vos serveurs sont dans un VPC AWS privé
# Seul le bastion est accessible depuis Internet

# Solution : Tunneling local multiple
ssh -L 3306:rds.internal:3306 \
    -L 5432:postgres.internal:5432 \
    -L 6379:elasticache.internal:6379 \
    -L 9200:elasticsearch.internal:9200 \
    user@bastion.aws.company.com

# Vous pouvez maintenant utiliser vos outils locaux :
mysql -h 127.0.0.1 -P 3306
psql -h 127.0.0.1 -p 5432
redis-cli -h 127.0.0.1 -p 6379
```

### Scénario 2 : Développement collaboratif

```bash
# Contexte : Partager votre environnement de dev avec un collègue distant

# Sur votre machine (tunneling distant)
ssh -R 8080:localhost:3000 user@shared-server.com

# Configuration persistante dans ~/.ssh/config
Host dev-share
    HostName shared-server.com
    User user
    RemoteForward 8080 localhost:3000
    ServerAliveInterval 60
    ExitOnForwardFailure yes

# Lancer avec : ssh -N dev-share
```

### Scénario 3 : Saut multiple (Jump Host)

```bash
# Contexte : Accéder à un service via plusieurs serveurs intermédiaires

# Méthode 1 : Tunnel en cascade
ssh -L 8080:localhost:9090 user@server1 \
    ssh -L 9090:internal-service:80 user@server2

# Méthode 2 : Utilisation de ProxyJump (plus propre)
ssh -J user@server1,user@server2 -L 8080:internal-service:80 user@target

# Méthode 3 : Configuration dans ~/.ssh/config
Host target
    HostName internal-service
    User user
    ProxyJump server1,server2
    LocalForward 8080 localhost:80
```

### Scénario 4 : VPN léger avec SOCKS

```bash
# Contexte : Besoin d'accéder au réseau d'entreprise sans VPN traditionnel

# Créer le tunnel
ssh -D 1080 -C user@vpn-gateway.company.com

# -C : Active la compression (utile sur connexions lentes)

# Configuration système pour router tout le trafic
# Créer un script ~/.local/bin/company-proxy.sh
#!/bin/bash
export ALL_PROXY=socks5://localhost:1080
export NO_PROXY=localhost,127.0.0.1
exec "$@"

# Utilisation :
chmod +x ~/.local/bin/company-proxy.sh
company-proxy.sh firefox
company-proxy.sh git clone internal-repo.company.com/project.git
```

### Scénario 5 : Reverse SSH pour support technique

```bash
# Contexte : Aider un utilisateur dont la machine est derrière un NAT

# Sur la machine de l'utilisateur (tunnel distant)
ssh -R 2222:localhost:22 support@support-server.company.com

# Depuis votre poste de support
ssh support@support-server.company.com
ssh -p 2222 user@localhost

# Vous êtes maintenant connecté à la machine de l'utilisateur
```

### Scénario 6 : Pipeline CI/CD sécurisé

```bash
# Contexte : Jenkins doit accéder à une base de données privée

# Script dans Jenkins
#!/bin/bash
# Créer le tunnel en background
ssh -fNL 5432:db.internal:5432 user@bastion &
SSH_PID=$!

# Attendre que le tunnel soit établi
sleep 2

# Exécuter les tests
PGHOST=localhost PGPORT=5432 ./run-tests.sh

# Nettoyer
kill $SSH_PID
```

### Scénario 7 : Monitoring avec Grafana

```bash
# Contexte : Accéder à plusieurs interfaces de monitoring internes

# Créer plusieurs tunnels
ssh -L 3000:grafana.internal:3000 \
    -L 9090:prometheus.internal:9090 \
    -L 9093:alertmanager.internal:9093 \
    -L 5601:kibana.internal:5601 \
    user@monitoring-gateway.company.com

# Accès dans le navigateur :
# - http://localhost:3000 → Grafana
# - http://localhost:9090 → Prometheus
# - http://localhost:9093 → Alertmanager
# - http://localhost:5601 → Kibana
```

### Scénario 8 : Debugging de production

```bash
# Contexte : Accéder temporairement à un service en production

# Tunnel temporaire avec timeout automatique
timeout 3600 ssh -L 9229:app-server:9229 user@prod-bastion
# Le tunnel se fermera automatiquement après 1 heure

# Se connecter au debugger Node.js distant
chrome://inspect dans Chrome
# Configurer : localhost:9229
```

---

## ⚠️ Pièges Courants et Bonnes Pratiques

### Pièges courants

#### 1. Port déjà utilisé

```bash
# Erreur typique
ssh -L 8080:remote:80 user@server
# Error: bind: Address already in use

# Solution : Vérifier et libérer le port
netstat -tuln | grep 8080
kill <PID_du_processus>

# Ou utiliser un autre port
ssh -L 8081:remote:80 user@server
```

#### 2. GatewayPorts non configuré

```bash
# Le tunnel distant ne fonctionne pas depuis l'extérieur
ssh -R 8080:localhost:3000 user@server

# Solution : Vérifier la configuration du serveur
# Sur le serveur : /etc/ssh/sshd_config
GatewayPorts clientspecified
```

#### 3. Tunnel qui se ferme inopinément

```bash
# Le tunnel SSH se déconnecte après inactivité

# Solution : Configuration dans ~/.ssh/config
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes

# Ou sur la ligne de commande
ssh -o ServerAliveInterval=60 -L 8080:remote:80 user@server
```

#### 4. Oubli du mode -N

```bash
# Mauvaise pratique : le tunnel ouvre aussi un shell
ssh -L 8080:remote:80 user@server

# Bonne pratique : tunnel uniquement
ssh -fNL 8080:remote:80 user@server
```

#### 5. Confusion localhost vs 0.0.0.0

```bash
# Le tunnel n'est pas accessible depuis d'autres machines

# Local uniquement (par défaut)
ssh -L 8080:remote:80 user@server

# Accessible sur le réseau local (attention à la sécurité)
ssh -L 0.0.0.0:8080:remote:80 user@server
```

### 🎯 Bonnes pratiques

#### 1. Utiliser ~/.ssh/config

```bash
# Au lieu de commandes longues, créer des profils
cat >> ~/.ssh/config << 'EOF'
Host db-tunnel
    HostName bastion.company.com
    User devops
    LocalForward 3306 db.internal:3306
    LocalForward 6379 redis.internal:6379
    ServerAliveInterval 60
    ExitOnForwardFailure yes

Host socks-proxy
    HostName proxy-server.com
    User user
    DynamicForward 1080
    Compression yes
    ServerAliveInterval 60

Host reverse-tunnel
    HostName public-server.com
    User user
    RemoteForward 8080 localhost:3000
    ServerAliveInterval 60
    ExitOnForwardFailure yes
EOF

# Utilisation simplifiée
ssh -fN db-tunnel
ssh -fN socks-proxy
ssh -fN reverse-tunnel
```

#### 2. Gestion des tunnels actifs

```bash
# Script pour lister les tunnels actifs
cat > ~/.local/bin/ssh-tunnels << 'EOF'
#!/bin/bash
echo "=== Tunnels SSH actifs ==="
ps aux | grep "ssh -" | grep -v grep | while read line; do
    echo "$line"
done

echo -e "\n=== Ports en écoute ==="
netstat -tuln | grep -E ":(1080|3306|5432|6379|8080)" || echo "Aucun tunnel détecté"
EOF

chmod +x ~/.local/bin/ssh-tunnels
```

#### 3. Sécurisation des tunnels

```bash
# Toujours utiliser l'authentification par clé
ssh-keygen -t ed25519 -C "tunneling-key"

# Limiter les permissions dans authorized_keys sur le serveur
# Ajouter devant la clé publique :
no-pty,no-X11-forwarding,permitopen="localhost:3306" ssh-ed25519 AAAA...

# Cela autorise uniquement le tunnel vers localhost:3306
```

#### 4. Monitoring et logs

```bash
# Activer le logging SSH détaillé
ssh -vv -L 8080:remote:80 user@server

# Logger les connexions du tunnel
ssh -L 8080:remote:80 user@server 2>&1 | tee ~/tunnel.log

# Surveiller l'utilisation d'un tunnel
watch -n 1 'netstat -an | grep :8080'
```

#### 5. Automatisation avec systemd

```bash
# Créer un service systemd pour un tunnel persistant
sudo nano /etc/systemd/system/ssh-tunnel-db.service

[Unit]
Description=SSH Tunnel to Database
After=network.target

[Service]
User=myuser
ExecStart=/usr/bin/ssh -N -L 3306:db.internal:3306 user@bastion
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

# Activer et démarrer
sudo systemctl enable ssh-tunnel-db
sudo systemctl start ssh-tunnel-db
sudo systemctl status ssh-tunnel-db
```

#### 6. Timeout et nettoyage

```bash
# Tunnel temporaire avec auto-destruction
(ssh -fNL 8080:remote:80 user@server & echo $! > /tmp/tunnel.pid) && \
(sleep 3600; kill $(cat /tmp/tunnel.pid); rm /tmp/tunnel.pid) &

# Ou utiliser timeout
timeout 3600 ssh -NL 8080:remote:80 user@server
```

#### 7. Vérification avant utilisation

```bash
# Script de pré-vérification
cat > ~/.local/bin/check-tunnel << 'EOF'
#!/bin/bash
PORT=$1
HOST=$2

# Vérifier que le port local est libre
if netstat -tuln | grep -q ":$PORT "; then
    echo "Erreur : Port $PORT déjà utilisé"
    exit 1
fi

# Vérifier la connectivité SSH
if ! ssh -o ConnectTimeout=5 -q $HOST exit; then
    echo "Erreur : Impossible de se connecter à $HOST"
    exit 1
fi

echo "Vérifications OK"
EOF

chmod +x ~/.local/bin/check-tunnel

# Utilisation
check-tunnel 8080 user@server && ssh -fNL 8080:remote:80 user@server
```

### 💡 Astuces avancées

#### Tunnel avec saut multiple en une ligne

```bash
# Accéder à un service via plusieurs sauts
ssh -L 8080:final-target:80 -J jump1,jump2,jump3 user@target
```

#### Tunnel bidirectionnel

```bash
# Créer un tunnel local ET distant simultanément
ssh -L 8080:remote:80 -R 9090:localhost:3000 user@server
```

#### Compression pour connexions lentes

```bash
# Activer la compression pour améliorer les performances
ssh -C -D 1080 user@server
```

#### ControlMaster pour réutiliser les connexions

```bash
# Configuration dans ~/.ssh/config
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m

# Créer le dossier
mkdir -p ~/.ssh/sockets

# Première connexion : établit le master
ssh user@server

# Connexions suivantes : réutilisent le master (très rapide)
ssh -L 8080:remote:80 user@server  # Instantané !
```

#### Tunnel avec notification

```bash
# Recevoir une notification quand le tunnel est prêt
ssh -fNL 8080:remote:80 user@server && notify-send "Tunnel SSH" "Le tunnel est actif sur le port 8080"
```

---

> [!tip] Résumé des commandes essentielles
> 
> ```bash
> # Tunneling local
> ssh -L port_local:host_distant:port_distant user@server
> 
> # Tunneling distant
> ssh -R port_distant:host_local:port_local user@server
> 
> # Tunneling dynamique (SOCKS)
> ssh -D port_local user@server
> 
> # Mode background
> ssh -fN [options] user@server
> 
> # Multiples tunnels
> ssh -L 3306:db:3306 -L 6379:redis:6379 -D 1080 user@server
> ```

> [!info] Points clés à retenir
> 
> - Les tunnels SSH chiffrent tout le trafic qui les traverse
> - Le tunneling local permet d'accéder à des services distants
> - Le tunneling distant permet d'exposer des services locaux
> - Le proxy SOCKS est idéal pour router tout le trafic d'une application
> - Toujours sécuriser les tunnels et limiter leur exposition
> - Utiliser `~/.ssh/config` pour simplifier la gestion des tunnels
> - Surveiller les tunnels actifs et nettoyer les connexions inutilisées