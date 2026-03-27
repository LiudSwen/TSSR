

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

## 🖥️ Connexion à distance sécurisée

### Qu'est-ce que c'est ?

La connexion à distance sécurisée est l'usage principal de SSH. Elle permet d'accéder à une machine distante via un shell interactif chiffré, remplaçant ainsi des protocoles obsolètes comme Telnet qui transmettaient tout en clair.

### Pourquoi c'est important ?

- **Sécurité** : Toutes les données (identifiants, commandes, résultats) sont chiffrées
- **Administration système** : Gérer des serveurs sans accès physique
- **Travail à distance** : Accéder à des environnements de développement distants
- **Audit** : Traçabilité des connexions et actions

### Syntaxe de base

```bash
# Connexion simple (utilise le nom d'utilisateur local)
ssh hostname

# Connexion avec un utilisateur spécifique
ssh username@hostname

# Connexion avec un port non-standard (défaut: 22)
ssh -p 2222 username@hostname

# Connexion avec une clé privée spécifique
ssh -i ~/.ssh/ma_cle_privee username@hostname

# Connexion en mode verbeux (pour déboguer)
ssh -v username@hostname
# -vv et -vvv pour plus de détails
```

> [!example] Exemples pratiques
> 
> ```bash
> # Se connecter à un serveur web
> ssh admin@webserver.example.com
> 
> # Se connecter à un Raspberry Pi sur le réseau local
> ssh pi@192.168.1.100
> 
> # Se connecter à un serveur cloud avec clé SSH
> ssh -i ~/.ssh/aws_key.pem ubuntu@ec2-54-123-45-67.compute.amazonaws.com
> ```

### Options utiles

|Option|Description|Exemple|
|---|---|---|
|`-p PORT`|Spécifier un port personnalisé|`ssh -p 2222 user@host`|
|`-i KEYFILE`|Utiliser une clé privée spécifique|`ssh -i ~/.ssh/key user@host`|
|`-v/-vv/-vvv`|Mode verbeux (debug)|`ssh -vv user@host`|
|`-o OPTION`|Passer des options SSH|`ssh -o StrictHostKeyChecking=no user@host`|
|`-X`|Activer le forwarding X11|`ssh -X user@host`|
|`-A`|Activer le forwarding d'agent|`ssh -A user@host`|
|`-C`|Activer la compression|`ssh -C user@host`|
|`-4/-6`|Forcer IPv4 ou IPv6|`ssh -4 user@host`|

> [!tip] Astuce : Connexion rapide Créez des alias dans votre fichier `~/.ssh/config` pour éviter de retaper les mêmes options :
> 
> ```bash
> Host monserveur
>     HostName 192.168.1.100
>     User admin
>     Port 2222
>     IdentityFile ~/.ssh/ma_cle
> ```
> 
> Puis simplement : `ssh monserveur`

### Première connexion et empreintes

Lors de la première connexion à un serveur, SSH affiche l'empreinte de la clé du serveur :

```bash
The authenticity of host 'server.com (192.168.1.10)' can't be established.
ED25519 key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

> [!warning] Sécurité : Vérification de l'empreinte **Ne tapez pas "yes" automatiquement !** Vérifiez que l'empreinte correspond à celle fournie par l'administrateur du serveur. Cette étape protège contre les attaques de type "man-in-the-middle".

Une fois acceptée, la clé du serveur est stockée dans `~/.ssh/known_hosts`.

### Pièges courants

> [!warning] Problèmes fréquents
> 
> - **Permission denied** : Vérifiez les permissions de votre clé privée (doivent être 600)
> - **Connection refused** : Le service SSH n'est peut-être pas démarré sur le serveur
> - **Host key verification failed** : La clé du serveur a changé (réinstallation, attaque ?)
> - **Too many authentication failures** : Trop de clés tentées, utilisez `-i` pour spécifier la bonne

### Bonnes pratiques

✅ **À faire :**

- Utiliser l'authentification par clé plutôt que par mot de passe
- Vérifier les empreintes de clés lors de la première connexion
- Utiliser un fichier `~/.ssh/config` pour organiser vos connexions
- Activer la compression (`-C`) pour les connexions lentes

❌ **À éviter :**

- Se connecter en root directement (utilisez sudo après connexion)
- Désactiver `StrictHostKeyChecking` de manière permanente
- Réutiliser la même clé SSH pour tous vos serveurs
- Laisser des sessions SSH ouvertes indéfiniment

---

## 📦 Transfert de fichiers

### Qu'est-ce que c'est ?

SSH offre plusieurs méthodes pour transférer des fichiers de manière sécurisée entre machines. Les deux outils principaux sont **SCP** (Secure Copy) et **SFTP** (SSH File Transfer Protocol).

### Pourquoi c'est important ?

- **Alternative sécurisée** à FTP qui transmet en clair
- **Simplicité** : Utilise la même authentification que SSH
- **Intégration** : Fonctionne dans les scripts et automatisations
- **Fiabilité** : Reprise de transfert possible avec certains outils

---

### 🔹 SCP (Secure Copy)

SCP permet de copier des fichiers comme la commande `cp`, mais entre machines distantes.

#### Syntaxe de base

```bash
# Envoyer un fichier vers un serveur distant
scp fichier_local.txt username@hostname:/chemin/destination/

# Récupérer un fichier depuis un serveur distant
scp username@hostname:/chemin/fichier_distant.txt /chemin/local/

# Copier un répertoire entier (récursif)
scp -r dossier_local/ username@hostname:/chemin/destination/

# Copier avec un port SSH non-standard
scp -P 2222 fichier.txt username@hostname:/destination/
```

> [!example] Exemples pratiques
> 
> ```bash
> # Envoyer une sauvegarde sur un serveur
> scp backup.tar.gz admin@backup-server.com:/var/backups/
> 
> # Récupérer les logs d'un serveur
> scp admin@webserver.com:/var/log/nginx/access.log ./logs/
> 
> # Copier un site web complet
> scp -r /var/www/html/ admin@server2.com:/var/www/
> 
> # Copier avec une clé SSH spécifique
> scp -i ~/.ssh/deploy_key deploy.zip ubuntu@prod:/opt/app/
> ```

#### Options importantes

|Option|Description|Exemple|
|---|---|---|
|`-r`|Copie récursive (dossiers)|`scp -r dossier/ user@host:/dest/`|
|`-P PORT`|Port SSH (majuscule !)|`scp -P 2222 file user@host:/dest/`|
|`-p`|Préserve les timestamps|`scp -p file user@host:/dest/`|
|`-C`|Active la compression|`scp -C bigfile user@host:/dest/`|
|`-v`|Mode verbeux|`scp -v file user@host:/dest/`|
|`-l LIMIT`|Limite la bande passante (Kbit/s)|`scp -l 1000 file user@host:/dest/`|
|`-i KEYFILE`|Clé privée spécifique|`scp -i key file user@host:/dest/`|

> [!tip] Astuce : Copie entre deux serveurs distants Vous pouvez copier directement entre deux serveurs sans passer par votre machine :
> 
> ```bash
> scp user1@server1:/fichier.txt user2@server2:/destination/
> ```

> [!warning] Attention au port ! Pour SCP, l'option du port est `-P` (majuscule), contrairement à SSH qui utilise `-p` (minuscule). C'est une source fréquente d'erreurs !

---

### 🔹 SFTP (SSH File Transfer Protocol)

SFTP offre une interface interactive pour gérer les fichiers, similaire à FTP mais sécurisée.

#### Syntaxe de base

```bash
# Se connecter en mode interactif
sftp username@hostname

# Se connecter avec un port spécifique
sftp -P 2222 username@hostname

# Exécuter une commande et quitter
sftp username@hostname <<< "get /remote/file.txt"
```

#### Commandes SFTP interactives

Une fois connecté, vous disposez d'un shell avec ces commandes :

```bash
# Navigation
pwd                    # Affiche le répertoire distant actuel
lpwd                   # Affiche le répertoire local actuel
ls                     # Liste les fichiers distants
lls                    # Liste les fichiers locaux
cd /chemin/distant     # Change de répertoire distant
lcd /chemin/local      # Change de répertoire local

# Transfert de fichiers
get fichier_distant.txt              # Télécharge un fichier
get -r dossier_distant/              # Télécharge un dossier
put fichier_local.txt                # Envoie un fichier
put -r dossier_local/                # Envoie un dossier
mget *.txt                           # Télécharge plusieurs fichiers
mput *.log                           # Envoie plusieurs fichiers

# Gestion de fichiers distants
mkdir nouveau_dossier                # Crée un dossier distant
rmdir dossier_vide                   # Supprime un dossier distant
rm fichier_distant.txt               # Supprime un fichier distant
rename ancien.txt nouveau.txt        # Renomme un fichier distant
chmod 644 fichier.txt                # Change les permissions
chown user:group fichier.txt         # Change le propriétaire

# Gestion de fichiers locaux (avec 'l' devant)
lmkdir nouveau_dossier_local         # Crée un dossier local

# Divers
!commande              # Exécute une commande shell locale
help                   # Affiche l'aide
exit / quit / bye      # Quitte SFTP
```

> [!example] Session SFTP typique
> 
> ```bash
> $ sftp admin@webserver.com
> Connected to webserver.com.
> 
> sftp> pwd
> Remote working directory: /home/admin
> 
> sftp> cd /var/www/html
> sftp> ls -l
> -rw-r--r--    1 www-data www-data     1024 Dec 01 10:00 index.html
> -rw-r--r--    1 www-data www-data     5120 Dec 01 10:00 style.css
> 
> sftp> get index.html
> Fetching /var/www/html/index.html to index.html
> 
> sftp> lcd /tmp
> sftp> put nouveau_fichier.html
> Uploading nouveau_fichier.html to /var/www/html/nouveau_fichier.html
> 
> sftp> exit
> ```

#### Mode batch (non-interactif)

Pour automatiser les transferts SFTP :

```bash
# Utiliser un fichier de commandes
sftp -b commands.txt username@hostname

# Contenu de commands.txt :
# cd /var/www/html
# get *.html
# put nouveau.html
# exit

# Ou via stdin
sftp username@hostname <<EOF
cd /var/www/html
get index.html
exit
EOF
```

> [!tip] Astuce : Synchronisation avec SFTP Pour synchroniser des dossiers, utilisez plutôt `rsync` qui peut fonctionner sur SSH et offre des options avancées (delta transfers, exclusions, etc.).

---

### 🔹 Comparaison SCP vs SFTP

|Critère|SCP|SFTP|
|---|---|---|
|**Simplicité**|✅ Très simple pour copies ponctuelles|⚠️ Plus de commandes à connaître|
|**Mode interactif**|❌ Non|✅ Oui, pratique pour explorer|
|**Reprise de transfert**|❌ Non (redémarre à zéro)|✅ Possible avec certains clients|
|**Gestion de fichiers**|❌ Copie uniquement|✅ Création, suppression, renommage|
|**Performance**|✅ Légèrement plus rapide|⚠️ Un peu plus lent|
|**Scripts**|✅ Très facile à scripter|✅ Possible (mode batch)|
|**Standardisation**|⚠️ Moins maintenu|✅ Standard moderne|

> [!info] Quelle méthode choisir ?
> 
> - **SCP** : Pour des copies simples et rapides, scripts automatisés basiques
> - **SFTP** : Pour l'exploration interactive, gestion complexe de fichiers, scripts avancés
> - **rsync sur SSH** : Pour la synchronisation, transferts incrémentaux, et projets volumineux

### Pièges courants

> [!warning] Problèmes fréquents
> 
> - **Confusion -P/-p** : SCP utilise `-P` (majuscule) pour le port, pas `-p`
> - **Oubli du `:` final** : `scp file user@host:/path/` (le `:` est obligatoire)
> - **Permissions insuffisantes** : Vérifiez les droits d'écriture sur la destination
> - **Écrasement silencieux** : SCP/SFTP écrasent les fichiers existants sans confirmation par défaut
> - **Chemins relatifs** : Attention aux chemins relatifs, préférez les chemins absolus pour éviter les confusions

### Bonnes pratiques

✅ **À faire :**

- Utiliser la compression (`-C`) pour les gros fichiers sur connexions lentes
- Préserver les permissions avec `-p` si nécessaire
- Utiliser SFTP pour les opérations interactives nécessitant de la navigation
- Tester avec un petit fichier avant de transférer de gros volumes
- Utiliser rsync pour la synchronisation régulière de données

❌ **À éviter :**

- Transférer des fichiers sensibles sans vérifier les permissions de destination
- Utiliser SCP pour des transferts qui pourraient être interrompus (préférer rsync)
- Oublier de nettoyer les fichiers temporaires après transfert
- Copier récursivement sans vérifier l'espace disque disponible

---

## 🔀 Tunneling et redirection de ports

### Qu'est-ce que c'est ?

Le tunneling SSH (ou port forwarding) permet de créer des "tunnels" chiffrés pour faire passer du trafic réseau à travers une connexion SSH. C'est une fonctionnalité puissante qui transforme SSH en véritable outil de sécurisation réseau.

### Pourquoi c'est important ?

- **Sécuriser des protocoles non-chiffrés** : Encapsuler HTTP, SMTP, bases de données dans SSH
- **Contourner des pare-feu** : Accéder à des services bloqués via un serveur intermédiaire
- **Accès à distance** : Accéder à des services internes depuis l'extérieur
- **Développement** : Tester des webhooks locaux, exposer temporairement des services

### Types de port forwarding

Il existe trois types principaux de redirection de ports :

1. **Local Port Forwarding** : Rediriger un port local vers un port distant
2. **Remote Port Forwarding** : Rediriger un port distant vers un port local
3. **Dynamic Port Forwarding** : Créer un proxy SOCKS

---

### 🔹 Local Port Forwarding

Redirige un port de votre machine locale vers un port sur une machine distante (ou accessible depuis cette machine).

#### Syntaxe

```bash
ssh -L [bind_address:]port_local:host_destination:port_destination username@serveur_ssh
```

#### Schéma conceptuel

```
[Votre machine]                [Serveur SSH]              [Destination]
    localhost:8080  ----SSH---->  serveur.com  ------>  database:3306
```

> [!example] Exemples pratiques
> 
> ```bash
> # Accéder à une base de données MySQL distante via localhost:3306
> ssh -L 3306:localhost:3306 admin@db-server.com
> # Puis connectez-vous à localhost:3306 localement
> 
> # Accéder à un service web interne via localhost:8080
> ssh -L 8080:internal-web:80 admin@gateway-server.com
> # Ouvrez http://localhost:8080 dans votre navigateur
> 
> # Tunnel vers un serveur Redis distant
> ssh -L 6379:redis-server:6379 admin@bastion.com
> 
> # Écouter sur une interface spécifique
> ssh -L 192.168.1.10:8080:internal:80 admin@gateway.com
> # Le tunnel sera accessible depuis 192.168.1.10:8080
> ```

#### Cas d'usage typiques

1. **Accès aux bases de données** : Connecter un client local à une BDD distante
2. **Services web internes** : Accéder à des interfaces d'administration non exposées
3. **Contournement de restrictions** : Accéder à des services via un serveur intermédiaire
4. **Sécurisation** : Chiffrer un protocole non-sécurisé (HTTP, SMTP, etc.)

> [!tip] Astuce : Connexion en arrière-plan Ajoutez `-N` pour ne pas ouvrir de shell (juste le tunnel) et `-f` pour mettre en arrière-plan :
> 
> ```bash
> ssh -f -N -L 8080:internal:80 admin@gateway.com
> ```

---

### 🔹 Remote Port Forwarding

Redirige un port du serveur distant vers un port de votre machine locale. C'est l'inverse du Local Port Forwarding.

#### Syntaxe

```bash
ssh -R [bind_address:]port_distant:host_local:port_local username@serveur_ssh
```

#### Schéma conceptuel

```
[Votre machine]                [Serveur SSH]              [Clients]
    localhost:3000  <----SSH----  serveur.com:8080  <----  Internet
```

> [!example] Exemples pratiques
> 
> ```bash
> # Exposer votre serveur web local (port 3000) sur le port 8080 du serveur
> ssh -R 8080:localhost:3000 admin@public-server.com
> # Les visiteurs de public-server.com:8080 accèdent à votre localhost:3000
> 
> # Permettre l'accès à votre base de données locale depuis le serveur distant
> ssh -R 5432:localhost:5432 admin@dev-server.com
> 
> # Exposition temporaire pour des tests de webhook
> ssh -R 9000:localhost:8000 admin@test-server.com
> # Configurez le webhook vers test-server.com:9000
> ```

#### Cas d'usage typiques

1. **Démonstration** : Montrer une application locale à un client sans déployer
2. **Webhooks** : Tester des webhooks sur votre environnement de développement local
3. **Support technique** : Donner temporairement accès à votre machine locale
4. **Reverse tunneling** : Contourner un NAT pour accéder à une machine locale depuis l'extérieur

> [!warning] Sécurité : GatewayPorts Par défaut, le tunnel n'est accessible que depuis localhost sur le serveur SSH. Pour l'exposer publiquement, le serveur doit avoir `GatewayPorts yes` dans sa configuration SSH.

> [!tip] Astuce : Alternative moderne Pour exposer temporairement un service local, considérez des services dédiés comme ngrok, localtunnel, ou serveo qui sont plus simples et sécurisés pour ce cas d'usage.

---

### 🔹 Dynamic Port Forwarding (SOCKS Proxy)

Crée un proxy SOCKS local qui route tout le trafic via le serveur SSH. C'est un tunnel dynamique qui s'adapte automatiquement.

#### Syntaxe

```bash
ssh -D [bind_address:]port_local username@serveur_ssh
```

#### Schéma conceptuel

```
[Applications locales]     [Serveur SSH]        [Internet]
      ↓                         ↓                   ↓
  localhost:1080  --SSH-->  serveur.com  ---->  Anywhere
    (SOCKS proxy)
```

> [!example] Exemples pratiques
> 
> ```bash
> # Créer un proxy SOCKS sur le port 1080
> ssh -D 1080 admin@proxy-server.com
> 
> # Créer un proxy et rester en arrière-plan
> ssh -f -N -D 1080 admin@proxy-server.com
> 
> # Créer un proxy sur une interface spécifique
> ssh -D 127.0.0.1:1080 admin@proxy-server.com
> ```

#### Configuration des applications

Une fois le proxy créé, configurez vos applications pour l'utiliser :

**Firefox :**

1. Paramètres → Général → Paramètres réseau → Paramètres de connexion
2. Sélectionnez "Configuration manuelle du proxy"
3. Hôte SOCKS : `localhost`, Port : `1080`, SOCKS v5
4. Cochez "DNS distant lors de l'utilisation de SOCKS v5"

**Chrome/Chromium (ligne de commande) :**

```bash
google-chrome --proxy-server="socks5://localhost:1080"
```

**Curl :**

```bash
curl --socks5 localhost:1080 https://api.example.com
```

**Configuration système (Linux) :**

```bash
# Via variables d'environnement
export ALL_PROXY=socks5://localhost:1080
export all_proxy=socks5://localhost:1080

# Puis utilisez vos applications normalement
wget https://example.com
curl https://api.example.com
```

> [!info] SOCKS4 vs SOCKS5 SOCKS5 est préférable car il supporte :
> 
> - L'authentification
> - La résolution DNS distante (vos requêtes DNS passent par le tunnel)
> - UDP en plus de TCP

#### Cas d'usage typiques

1. **Contournement de censure** : Accéder à Internet via un serveur situé ailleurs
2. **Confidentialité** : Masquer votre adresse IP réelle
3. **Accès à un réseau interne** : Naviguer comme si vous étiez sur le réseau distant
4. **Tests géographiques** : Tester comment votre site apparaît depuis un autre pays
5. **Sécurité sur WiFi public** : Chiffrer tout votre trafic

> [!warning] Limitations
> 
> - Tous les programmes ne supportent pas les proxies SOCKS
> - Les requêtes DNS peuvent fuir si mal configuré (utilisez SOCKS5 avec DNS distant)
> - Moins performant qu'un VPN complet pour un usage intensif

---

### 🔹 Combinaison et options avancées

Vous pouvez combiner plusieurs tunnels dans une même connexion SSH :

```bash
# Plusieurs tunnels locaux
ssh -L 8080:web:80 -L 3306:db:3306 -L 6379:redis:6379 admin@bastion.com

# Tunnel local + remote simultanés
ssh -L 8080:internal:80 -R 9000:localhost:3000 admin@server.com

# Dynamic + Local
ssh -D 1080 -L 5432:db:5432 admin@gateway.com
```

#### Options utiles

|Option|Description|
|---|---|
|`-N`|Ne pas exécuter de commande distante (juste le tunnel)|
|`-f`|Mettre la connexion en arrière-plan|
|`-g`|Permettre aux hôtes distants de se connecter aux ports locaux|
|`-C`|Activer la compression (utile pour les tunnels)|
|`-v`|Mode verbeux (debug des tunnels)|

> [!example] Tunnel permanent en arrière-plan
> 
> ```bash
> # Créer un tunnel qui persiste en arrière-plan
> ssh -f -N -C -D 1080 admin@proxy.com
> 
> # Vérifier que le tunnel est actif
> ps aux | grep ssh
> 
> # Trouver et tuer le tunnel
> pkill -f "ssh -f -N -C -D 1080"
> ```

### Configuration persistante

Pour automatiser vos tunnels, utilisez `~/.ssh/config` :

```bash
Host mytunnel
    HostName server.com
    User admin
    LocalForward 8080 internal-web:80
    LocalForward 3306 database:3306
    DynamicForward 1080
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Puis simplement : `ssh -N mytunnel`

> [!tip] Astuce : Autossh pour la résilience Pour des tunnels qui doivent rester actifs en permanence, utilisez `autossh` qui redémarre automatiquement la connexion en cas de déconnexion :
> 
> ```bash
> autossh -M 0 -f -N -D 1080 admin@proxy.com
> ```

### Pièges courants

> [!warning] Problèmes fréquents
> 
> - **Port déjà utilisé** : "bind: Address already in use" → Un autre processus utilise ce port
> - **Permissions insuffisantes** : "Permission denied" → Ports < 1024 nécessitent root
> - **Tunnel inactif** : Certains serveurs SSH ont des timeouts → Utilisez `ServerAliveInterval`
> - **GatewayPorts refusé** : Le serveur refuse les Remote Forward publics → Configuration serveur nécessaire
> - **Fuite DNS** : Avec SOCKS, vérifiez que les DNS passent bien par le tunnel

### Bonnes pratiques

✅ **À faire :**

- Utiliser `-N` pour des tunnels purs (sans shell)
- Activer la compression (`-C`) pour de meilleures performances
- Configurer `ServerAliveInterval` pour éviter les déconnexions
- Documenter vos tunnels dans `~/.ssh/config`
- Utiliser autossh pour des tunnels critiques en production

❌ **À éviter :**

- Exposer des services sensibles sans authentification supplémentaire
- Laisser des tunnels ouverts indéfiniment sans surveillance
- Utiliser des ports privilégiés (<1024) sans raison
- Oublier de fermer les tunnels après usage
- Créer des boucles de tunnels (tunnel A→B puis B→A)

---

## ⚡ Exécution de commandes à distance

### Qu'est-ce que c'est ?

SSH permet d'exécuter des commandes sur une machine distante sans ouvrir de session interactive. C'est essentiel pour l'automatisation, les scripts et l'administration système à grande échelle.

### Pourquoi c'est important ?

- **Automatisation** : Intégrer des opérations distantes dans des scripts
- **Administration** : Gérer plusieurs serveurs simultanément
- **Déploiement** : Automatiser le déploiement d'applications
- **Monitoring** : Collecter des informations système régulièrement
- **CI/CD** : Intégrer dans des pipelines de déploiement

---

### 🔹 Commande simple à distance

#### Syntaxe de base

```bash
ssh username@hostname 'commande'
ssh username@hostname "commande avec $variables"
```

> [!example] Exemples pratiques
> 
> ```bash
> # Vérifier l'uptime d'un serveur
> ssh admin@webserver.com 'uptime'
> 
> # Obtenir l'utilisation disque
> ssh admin@dbserver.com 'df -h'
> 
> # Redémarrer un service
> ssh admin@appserver.com 'sudo systemctl restart nginx'
> 
> # Vérifier les processus
> ssh admin@server.com 'ps aux | grep apache'
> 
> # Créer un fichier distant
> ssh admin@server.com 'echo "Hello" > /tmp/test.txt'
> ```

#### Guillemets simples vs doubles

```bash
# Guillemets simples : Les variables sont évaluées sur la machine DISTANTE
ssh user@server 'echo $HOSTNAME'
# Affiche le hostname du serveur distant

# Guillemets doubles : Les variables sont évaluées LOCALEMENT
ssh user@server "echo $HOSTNAME"
# Affiche votre hostname local

# Échapper pour évaluer à distance avec guillemets doubles
LOCAL_VAR="test"
ssh user@server "echo $LOCAL_VAR et \$HOSTNAME"
# Affiche "test et hostname-distant"
```

> [!tip] Astuce : Quelle syntaxe choisir ?
> 
> - Guillemets simples (`'...'`) : Pour des commandes simples sans variables locales
> - Guillemets doubles (`"..."`) : Quand vous devez passer des variables locales
> - Here-doc : Pour des scripts multi-lignes complexes

---

### 🔹 Commandes multiples

#### Chaînage de commandes

```bash
# Commandes séquentielles (ET logique)
ssh user@server 'cd /var/www && ls -la && pwd'

# Commandes indépendantes (point-virgule)
ssh user@server 'date; uptime; whoami'

# Commandes conditionnelles (OU logique)
ssh user@server 'systemctl is-active nginx || echo "Nginx is down!"'

# Pipeline de commandes
ssh user@server 'cat /var/log/nginx/access.log | grep "404" | wc -l'
```

> [!example] Cas pratiques
> 
> ```bash
> # Sauvegarder et vérifier
> ssh admin@server 'tar -czf backup.tar.gz /data && ls -lh backup.tar.gz'
> 
> # Vérifier un service et redémarrer si nécessaire
> ssh admin@server 'systemctl is-active apache2 || sudo systemctl start apache2'
> 
> # Analyser des logs
> ssh admin@server 'cat /var/log/syslog | grep ERROR | tail -20'
> 
> # Nettoyer et vérifier l'espace libéré
> ssh admin@server 'du -sh /tmp && rm -rf /tmp/cache/* && du -sh /tmp'
> ```

---

### 🔹 Scripts multi-lignes avec Here-Document

Pour des scripts complexes, utilisez la syntaxe here-document :

```bash
ssh user@server << 'EOF'
#!/bin/bash
# Script multi-lignes exécuté à distance

echo "=== Rapport système ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo ""

echo "=== CPU ==="
top -bn1 | head -5

echo "=== Mémoire ==="
free -h

echo "=== Disque ==="
df -h | grep -v tmpfs

echo "=== Dernières connexions ==="
last -5
EOF
```

> [!info] EOF entre guillemets simples `<< 'EOF'` avec guillemets simples empêche l'expansion des variables localement. Sans guillemets, les variables `$VAR` seraient évaluées avant l'envoi.

> [!example] Script de déploiement complet
> 
> ```bash
> ssh deploy@production << 'DEPLOY'
> set -e  # Arrêter en cas d'erreur
> 
> echo "🚀 Début du déploiement..."
> 
> # Backup de l'ancienne version
> cd /var/www/app
> tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz current/
> 
> # Mise à jour du code
> git fetch origin
> git checkout main
> git pull origin main
> 
> # Installation des dépendances
> npm install --production
> 
> # Build de l'application
> npm run build
> 
> # Redémarrage du service
> sudo systemctl restart app-service
> 
> # Vérification
> sleep 3
> if systemctl is-active --quiet app-service; then
>     echo "✅ Déploiement réussi !"
> else
>     echo "❌ Échec du déploiement !"
>     exit 1
> fi
> DEPLOY
> ```

---

### 🔹 Redirection et capture de sortie

#### Capturer la sortie localement

```bash
# Capturer la sortie dans une variable
UPTIME=$(ssh user@server 'uptime')
echo "Serveur uptime: $UPTIME"

# Capturer dans un fichier
ssh user@server 'cat /var/log/nginx/access.log' > local_copy.log

# Capturer stdout et stderr séparément
ssh user@server 'commande' > output.txt 2> errors.txt

# Traiter la sortie avec un pipe local
ssh user@server 'cat /etc/passwd' | grep root | cut -d: -f1
```

> [!example] Exemples de capture
> 
> ```bash
> # Collecter des métriques de plusieurs serveurs
> for server in web1 web2 web3; do
>     echo "=== $server ===" >> metrics.txt
>     ssh admin@$server 'free -m | grep Mem' >> metrics.txt
> done
> 
> # Vérifier si un fichier existe et capturer le résultat
> if ssh user@server 'test -f /etc/important.conf'; then
>     echo "Fichier trouvé"
> else
>     echo "Fichier manquant"
> fi
> 
> # Compter les processus distants
> PROCESS_COUNT=$(ssh user@server 'ps aux | wc -l')
> echo "Nombre de processus: $PROCESS_COUNT"
> ```

#### Redirection côté distant

```bash
# Rediriger la sortie vers un fichier distant
ssh user@server 'ls -la > /tmp/listing.txt'

# Append à un fichier distant
ssh user@server 'date >> /var/log/custom.log'

# Envoyer des données locales vers un fichier distant
cat local_file.txt | ssh user@server 'cat > /remote/file.txt'

# Compresser localement et décompresser à distance
tar czf - local_dir/ | ssh user@server 'tar xzf - -C /remote/path/'
```

---

### 🔹 Exécution en arrière-plan

#### Lancer des commandes longues

```bash
# Avec nohup (survit à la déconnexion SSH)
ssh user@server 'nohup ./long_script.sh > output.log 2>&1 &'

# Avec screen (permet de se rattacher plus tard)
ssh user@server 'screen -dmS mysession ./long_script.sh'

# Vérifier les sessions screen
ssh user@server 'screen -ls'

# Se reconnecter à une session screen
ssh user@server -t 'screen -r mysession'

# Avec tmux (alternative moderne à screen)
ssh user@server 'tmux new-session -d -s mysession "./long_script.sh"'
```

> [!info] Option -t pour les sessions interactives L'option `-t` force l'allocation d'un pseudo-terminal, nécessaire pour screen/tmux :
> 
> ```bash
> ssh -t user@server 'screen -r mysession'
> ```

> [!example] Cas pratique : Lancement de tâches longues
> 
> ```bash
> # Démarrer un backup en arrière-plan
> ssh admin@backup 'nohup /opt/backup.sh > /var/log/backup.log 2>&1 &'
> 
> # Lancer une migration de base de données dans screen
> ssh dba@dbserver 'screen -dmS migration /scripts/migrate.sh'
> 
> # Vérifier la progression plus tard
> ssh dba@dbserver -t 'screen -r migration'
> 
> # Démarrer un serveur de développement distant
> ssh dev@devserver 'tmux new -d -s devserver "cd /app && npm start"'
> ```

---

### 🔹 Boucles et serveurs multiples

#### Exécuter sur plusieurs serveurs

```bash
# Boucle simple
for server in web1 web2 web3; do
    echo "=== $server ==="
    ssh admin@$server 'hostname && uptime'
done

# Avec un fichier de liste de serveurs
while read server; do
    ssh admin@$server 'df -h | grep "/$"'
done < servers.txt

# Parallélisation avec background jobs
for server in web{1..10}; do
    ssh admin@$server 'systemctl status nginx' &
done
wait  # Attendre que tous les jobs se terminent

# Parallélisation avec GNU Parallel
parallel "ssh admin@{} 'uptime'" ::: web1 web2 web3 db1 db2
```

> [!example] Scripts d'administration multi-serveurs
> 
> ```bash
> # Déployer une mise à jour sur tous les serveurs web
> SERVERS="web1 web2 web3"
> for server in $SERVERS; do
>     echo "📦 Déploiement sur $server..."
>     ssh deploy@$server << 'EOF'
>         cd /var/www/app
>         git pull origin main
>         npm install
>         pm2 reload all
> EOF
>     if [ $? -eq 0 ]; then
>         echo "✅ $server: OK"
>     else
>         echo "❌ $server: ÉCHEC"
>     fi
> done
> 
> # Collecter des logs de tous les serveurs
> for server in app{1..5}; do
>     ssh admin@$server 'tail -100 /var/log/app.log' \
>         > "logs/${server}_$(date +%Y%m%d).log"
> done
> 
> # Vérifier la version d'un package sur tous les serveurs
> for server in $(cat production_servers.txt); do
>     VERSION=$(ssh admin@$server 'dpkg -l | grep nginx | awk "{print \$3}"')
>     echo "$server: nginx $VERSION"
> done
> ```

---

### 🔹 Passage de fichiers et stdin/stdout

#### Envoyer des données via stdin

```bash
# Envoyer le contenu d'un fichier comme input
cat local_file.txt | ssh user@server 'cat > remote_file.txt'

# Exécuter un script local à distance
cat local_script.sh | ssh user@server 'bash -s'

# Avec arguments
cat script.sh | ssh user@server 'bash -s -- arg1 arg2'

# Envoyer une archive et l'extraire directement
tar czf - directory/ | ssh user@server 'tar xzf - -C /destination/'

# Copier une base de données directement
mysqldump database | ssh user@server 'mysql database'
```

> [!example] Cas pratiques avancés
> 
> ```bash
> # Backup d'une base de données MySQL distant vers local
> ssh user@dbserver 'mysqldump -u root -p"password" mydb' > local_backup.sql
> 
> # Copier une base de données d'un serveur à un autre
> ssh user@source 'mysqldump mydb' | ssh user@dest 'mysql mydb'
> 
> # Synchroniser des données avec compression à la volée
> ssh user@source 'tar czf - /data' | ssh user@dest 'tar xzf - -C /backup'
> 
> # Exécuter un script local avec paramètres distants
> cat deploy.sh | ssh user@server "bash -s -- $(hostname) $VERSION"
> ```

---

### 🔹 Variables d'environnement

#### Définir des variables pour la commande distante

```bash
# Variable simple
ssh user@server 'export VAR=value; echo $VAR'

# Variables multiples
ssh user@server 'export DB_HOST=localhost DB_PORT=5432; ./script.sh'

# Via la configuration SSH (SendEnv/AcceptEnv)
# Localement dans ~/.ssh/config:
# SendEnv MY_VAR

export MY_VAR="valeur"
ssh user@server 'echo $MY_VAR'
```

> [!warning] Limitations des variables d'environnement Par défaut, SSH ne transmet pas vos variables d'environnement locales. Pour activer cela :
> 
> - Client : Ajouter `SendEnv PATTERN` dans `~/.ssh/config`
> - Serveur : Ajouter `AcceptEnv PATTERN` dans `/etc/ssh/sshd_config`
> 
> Les patterns acceptés : `LC_*`, `LANG`, etc.

> [!example] Configuration pour passer des variables
> 
> ```bash
> # Dans ~/.ssh/config
> Host production
>     HostName prod.example.com
>     User deploy
>     SendEnv DEPLOY_ENV DEPLOY_VERSION
> 
> # Utilisation
> export DEPLOY_ENV="production"
> export DEPLOY_VERSION="v2.1.0"
> ssh production 'echo "Deploying $DEPLOY_VERSION to $DEPLOY_ENV"'
> ```

---

### 🔹 Gestion des erreurs

#### Codes de retour

```bash
# Vérifier le code de retour
ssh user@server 'command'
if [ $? -eq 0 ]; then
    echo "Succès"
else
    echo "Échec"
fi

# En une ligne
ssh user@server 'command' && echo "OK" || echo "Erreur"

# Stopper un script en cas d'erreur (dans un here-doc)
ssh user@server << 'EOF'
set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

command1
command2
command3
EOF
```

> [!example] Script robuste avec gestion d'erreurs
> 
> ```bash
> #!/bin/bash
> 
> SERVERS="web1 web2 web3"
> FAILED_SERVERS=""
> 
> for server in $SERVERS; do
>     echo "🔄 Traitement de $server..."
>     
>     if ssh admin@$server << 'EOF'
> set -e
> sudo systemctl reload nginx
> sudo systemctl is-active nginx
> EOF
>     then
>         echo "✅ $server: OK"
>     else
>         echo "❌ $server: ÉCHEC"
>         FAILED_SERVERS="$FAILED_SERVERS $server"
>     fi
> done
> 
> if [ -n "$FAILED_SERVERS" ]; then
>     echo ""
>     echo "⚠️  Serveurs en échec:$FAILED_SERVERS"
>     exit 1
> else
>     echo ""
>     echo "🎉 Tous les serveurs traités avec succès"
> fi
> ```

---

### 🔹 Options utiles pour l'exécution de commandes

|Option|Description|Exemple|
|---|---|---|
|`-n`|Redirige stdin depuis /dev/null|`ssh -n user@server cmd`|
|`-t`|Force l'allocation d'un PTY|`ssh -t user@server 'top'`|
|`-T`|Désactive l'allocation de PTY|`ssh -T user@server cmd`|
|`-q`|Mode silencieux (pas d'avertissements)|`ssh -q user@server cmd`|
|`-o`|Options SSH spécifiques|`ssh -o ConnectTimeout=5 user@server`|
|`-f`|Mise en arrière-plan|`ssh -f user@server 'sleep 10'`|
|`-N`|Pas de commande (tunnels uniquement)|`ssh -N -L 8080:localhost:80`|

> [!tip] Combiner les options
> 
> ```bash
> # Commande silencieuse sans PTY avec timeout
> ssh -qT -o ConnectTimeout=5 user@server 'uptime'
> 
> # Commande en arrière-plan pour lancer un process long
> ssh -f user@server 'nohup ./long_task.sh &'
> 
> # Forcer un PTY pour les commandes interactives
> ssh -t user@server 'sudo su - appuser'
> ```

---

### Pièges courants

> [!warning] Problèmes fréquents
> 
> - **Guillemets et échappement** : Attention aux niveaux d'échappement (`'`, `"`, `\`)
> - **Variables locales vs distantes** : `$VAR` évalué localement avec `"..."`, à distance avec `'...'`
> - **Stdin déjà utilisé** : Utiliser `-n` dans les boucles pour éviter que SSH consomme stdin
> - **Pseudo-terminal requis** : Certaines commandes (sudo, top) nécessitent `-t`
> - **Timeout par défaut** : Pas de timeout automatique, utiliser `-o ConnectTimeout`
> - **Chemins relatifs** : Les chemins sont relatifs au home directory distant, pas au répertoire courant

### Bonnes pratiques

✅ **À faire :**

- Utiliser `set -e` dans les scripts pour arrêter en cas d'erreur
- Tester d'abord les commandes manuellement avant de les scripter
- Utiliser des timeouts (`-o ConnectTimeout`) pour éviter les blocages
- Logger les résultats des exécutions dans des scripts de production
- Utiliser des outils comme Ansible pour l'administration à grande échelle
- Préférer SSH config pour les options répétitives

❌ **À éviter :**

- Mettre des mots de passe dans les scripts (utilisez les clés SSH)
- Ignorer les codes de retour des commandes
- Exécuter des commandes destructives sans confirmation
- Utiliser `ssh` dans des boucles sans `-n` (risque de stdin consumé)
- Oublier d'échapper correctement les caractères spéciaux
- Lancer des opérations longues sans mécanisme de reprise (nohup, screen, tmux)

---

## 🎯 Synthèse des cas d'usage

|Cas d'usage|Outil/Méthode|Commande exemple|
|---|---|---|
|**Session interactive**|ssh|`ssh user@host`|
|**Copie simple de fichiers**|scp|`scp file.txt user@host:/path/`|
|**Gestion de fichiers**|sftp|`sftp user@host`|
|**Accès service distant local**|Local Forward|`ssh -L 8080:internal:80 user@host`|
|**Exposer service local**|Remote Forward|`ssh -R 8080:localhost:3000 user@host`|
|**Proxy complet**|Dynamic Forward|`ssh -D 1080 user@host`|
|**Commande unique**|ssh + commande|`ssh user@host 'uptime'`|
|**Script distant**|here-doc|`ssh user@host << 'EOF' ... EOF`|
|**Administration multi-serveurs**|boucle + ssh|`for s in ...; do ssh user@$s cmd; done`|
|**Transfert de données**|pipe + ssh|`tar czf - dir/ \| ssh user@host 'tar xzf -'`|

---

## 💡 Conseils finaux

> [!tip] Optimisation et automatisation
> 
> - **Utilisez `~/.ssh/config`** pour centraliser vos configurations
> - **ControlMaster** pour réutiliser les connexions SSH et accélérer les commandes multiples
> - **Ansible** pour orchestrer des opérations complexes sur plusieurs serveurs
> - **tmux/screen** pour les sessions longues qui doivent survivre aux déconnexions
> - **rsync over SSH** pour la synchronisation efficace de fichiers

> [!info] Sécurité avant tout
> 
> - Toujours vérifier les empreintes lors de la première connexion
> - Utiliser l'authentification par clé plutôt que par mot de passe
> - Limiter les privilèges : ne pas se connecter en root directement
> - Auditer régulièrement les accès SSH via les logs
> - Désactiver le forwarding si non nécessaire pour limiter les risques

SSH est un couteau suisse de l'administration système et du développement. Maîtriser ces différents cas d'usage vous permettra de travailler efficacement, en sécurité, et d'automatiser de nombreuses tâches quotidiennes. 🚀