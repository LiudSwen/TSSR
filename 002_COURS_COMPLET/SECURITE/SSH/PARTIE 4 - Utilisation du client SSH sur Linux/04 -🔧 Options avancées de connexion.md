

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

## 🚀 Exécution de commandes à distance

### Pourquoi l'utiliser ?

L'exécution de commandes à distance permet d'automatiser des tâches sur des serveurs sans ouvrir de session interactive. C'est particulièrement utile pour :

- Les scripts d'automatisation et déploiements
- La surveillance et collecte d'informations système
- Les tâches de maintenance ponctuelles
- L'intégration dans des pipelines CI/CD

### Syntaxe de base

```bash
# Exécuter une commande simple
ssh user@host 'commande'

# Exemples pratiques
ssh admin@serveur.com 'uptime'
ssh root@192.168.1.100 'df -h'
ssh user@prod 'systemctl status nginx'
```

> [!info] Guillemets et échappement Utilisez des guillemets simples `'...'` pour éviter l'interprétation des variables par le shell local. Pour les guillemets doubles, les variables seront évaluées localement avant l'envoi.

### Commandes multiples

```bash
# Plusieurs commandes avec des points-virgules
ssh user@host 'commande1; commande2; commande3'

# Avec des opérateurs logiques
ssh user@host 'cd /var/log && tail -n 50 syslog'
ssh user@host 'mkdir backup || echo "Dossier déjà existant"'

# Commandes sur plusieurs lignes (plus lisible)
ssh user@host '
    cd /var/www/html
    git pull origin main
    sudo systemctl restart apache2
'
```

> [!warning] Code de retour SSH retourne le code de sortie de la dernière commande exécutée. Pour capturer correctement les erreurs dans les scripts, vérifiez `$?` après chaque appel.

### Redirection et pipes

```bash
# Redirection locale (le fichier est créé sur la machine locale)
ssh user@host 'cat /var/log/syslog' > log_local.txt

# Redirection distante (le fichier est créé sur le serveur)
ssh user@host 'cat /var/log/syslog > /tmp/log_distant.txt'

# Pipe avec commande locale
ssh user@host 'cat /etc/passwd' | grep root

# Pipe avec commande distante
ssh user@host 'cat /etc/passwd | grep root'
```

### Exécution de scripts locaux à distance

```bash
# Envoyer un script et l'exécuter
ssh user@host 'bash -s' < script_local.sh

# Avec des arguments
ssh user@host 'bash -s' < script.sh arg1 arg2

# Avec des variables d'environnement
ssh user@host 'export VAR=value; bash -s' < script.sh
```

> [!example] Exemple de déploiement simple
> 
> ```bash
> # Script de déploiement automatisé
> ssh deploy@prod '
>     cd /var/www/app
>     git pull origin main
>     npm install --production
>     pm2 restart app
>     echo "Déploiement terminé à $(date)"
> ' && echo "✅ Succès" || echo "❌ Échec"
> ```

### Mode pseudo-terminal (-t)

```bash
# Forcer l'allocation d'un pseudo-terminal
ssh -t user@host 'sudo commande'

# Utile pour les commandes nécessitant un TTY
ssh -t user@host 'top'
ssh -t user@host 'vim fichier.txt'

# Double -t pour forcer même si stdin n'est pas un terminal
ssh -tt user@host 'commande_interactive'
```

> [!tip] Quand utiliser -t ? Utilisez `-t` lorsque la commande distante nécessite un terminal interactif (sudo avec mot de passe, éditeurs de texte, top, htop, etc.)

### Commandes sans shell (-N, -f)

```bash
# -N : Ne pas exécuter de commande distante (pour le tunneling)
ssh -N -L 8080:localhost:80 user@host

# -f : Passer en arrière-plan avant l'exécution
ssh -f -N -L 8080:localhost:80 user@host

# Combiné pour un tunnel en arrière-plan
ssh -fN -D 1080 user@proxy-server
```

---

## 🔍 Mode verbeux

### Pourquoi l'utiliser ?

Le mode verbeux est indispensable pour :

- **Diagnostiquer** les problèmes de connexion
- **Comprendre** le processus d'authentification
- **Déboguer** les configurations complexes
- **Auditer** les connexions et négociations cryptographiques

### Niveaux de verbosité

|Option|Niveau|Cas d'usage|
|---|---|---|
|`-v`|Debug niveau 1|Diagnostic basique, voir les étapes principales|
|`-vv`|Debug niveau 2|Informations détaillées sur l'authentification|
|`-vvv`|Debug niveau 3|Toutes les informations, y compris les détails cryptographiques|

### Utilisation pratique

```bash
# Niveau 1 : Debug basique
ssh -v user@host

# Niveau 2 : Plus de détails
ssh -vv user@host

# Niveau 3 : Maximum d'informations
ssh -vvv user@host
```

### Ce que vous verrez avec -v

```bash
ssh -v user@host
```

**Informations affichées :**

- Version d'OpenSSH
- Lecture des fichiers de configuration
- Résolution DNS de l'hôte
- Établissement de la connexion TCP
- Échange des versions du protocole SSH
- Algorithmes de chiffrement négociés
- Méthodes d'authentification tentées
- Établissement du canal sécurisé

> [!example] Sortie typique avec -v
> 
> ```
> OpenSSH_8.9p1, OpenSSL 3.0.2
> debug1: Reading configuration data /home/user/.ssh/config
> debug1: Reading configuration data /etc/ssh/ssh_config
> debug1: Connecting to serveur.com [192.168.1.100] port 22.
> debug1: Connection established.
> debug1: Remote protocol version 2.0, remote software version OpenSSH_8.2
> debug1: Authenticating to serveur.com:22 as 'user'
> debug1: Authentications that can continue: publickey,password
> debug1: Next authentication method: publickey
> debug1: Offering public key: /home/user/.ssh/id_rsa RSA SHA256:...
> debug1: Server accepts key: /home/user/.ssh/id_rsa RSA SHA256:...
> debug1: Authentication succeeded (publickey).
> ```

### Cas d'usage spécifiques

#### Problème d'authentification par clé

```bash
# Vérifier quelle clé est utilisée
ssh -v user@host 2>&1 | grep "Offering public key"

# Voir pourquoi une clé est rejetée
ssh -vv user@host 2>&1 | grep -A5 "Offering public key"
```

#### Problème de configuration

```bash
# Vérifier les fichiers de config lus
ssh -v user@host 2>&1 | grep "Reading configuration"

# Voir les paramètres appliqués
ssh -vvv user@host 2>&1 | grep "debug3: .*applying"
```

#### Problème de connexion réseau

```bash
# Voir la résolution DNS et la connexion
ssh -v user@host 2>&1 | grep -E "(Connecting|Connection established|connect to host)"
```

> [!tip] Redirection et filtrage Redirigez la sortie debug avec `2>&1` et utilisez `grep` pour filtrer les informations pertinentes. Le mode verbeux écrit sur stderr (descripteur 2).

### Analyse des algorithmes cryptographiques

```bash
# Voir les algorithmes proposés et acceptés
ssh -vv user@host 2>&1 | grep -E "(kex|cipher|MAC)"
```

**Exemple de sortie :**

```
debug2: KEX algorithms: curve25519-sha256,ecdh-sha2-nistp256
debug2: host key algorithms: rsa-sha2-512,rsa-sha2-256
debug2: ciphers ctos: chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
debug2: MACs ctos: hmac-sha2-256,hmac-sha2-512
```

> [!warning] Informations sensibles Le mode `-vvv` peut afficher des informations sensibles dans les logs. N'utilisez jamais ce niveau en production et nettoyez les logs après diagnostic.

---

## 📦 Compression des données

### Pourquoi l'utiliser ?

La compression SSH réduit la quantité de données transférées sur le réseau :

- **Améliore** les performances sur connexions lentes (3G, satellite)
- **Réduit** la bande passante consommée
- **Accélère** le transfert de fichiers texte et logs
- **Peut ralentir** sur connexions rapides (overhead CPU)

### Activation de la compression

```bash
# Activer la compression avec -C
ssh -C user@host

# Combiné avec d'autres options
ssh -C user@host 'tar czf - /var/log' > logs.tar.gz

# Compression avec transfert de fichiers
scp -C fichier.txt user@host:/destination/
```

### Configuration permanente

```bash
# Dans ~/.ssh/config
Host serveur-lent
    HostName serveur.com
    User admin
    Compression yes
    CompressionLevel 6  # Niveau 1-9 (6 par défaut)
```

### Niveaux de compression

|Niveau|Vitesse|Taux de compression|Usage|
|---|---|---|---|
|1|Très rapide|Faible|Connexions moyennement lentes|
|6 (défaut)|Équilibré|Moyen|Usage général|
|9|Lent|Élevé|Connexions très lentes, CPU puissant|

> [!info] Algorithme utilisé SSH utilise la bibliothèque zlib, le même algorithme que gzip, pour la compression des données.

### Quand utiliser la compression ?

#### ✅ Situations favorables

```bash
# Transfert de logs texte non compressés
ssh -C user@host 'cat /var/log/syslog' > syslog_local.txt

# Connexions lentes (modem, satellite, 3G)
ssh -C -o CompressionLevel=9 user@serveur-distant

# Scripts générant beaucoup de texte
ssh -C user@host 'find / -type f -name "*.log"'
```

#### ❌ Situations défavorables

```bash
# ❌ Fichiers déjà compressés (overhead inutile)
scp -C archive.tar.gz user@host:/tmp/  # Inutile
scp -C video.mp4 user@host:/media/     # Contre-productif

# ❌ Connexions LAN rapides (overhead CPU > gain bande passante)
ssh -C user@192.168.1.100  # Probablement plus lent

# ❌ Serveurs avec CPU limité
ssh -C user@raspberry-pi  # Peut ralentir le système
```

> [!tip] Test de performance Testez avec et sans compression pour votre cas d'usage :
> 
> ```bash
> time ssh user@host 'cat gros_fichier.log' > /dev/null
> time ssh -C user@host 'cat gros_fichier.log' > /dev/null
> ```

### Impact sur les performances

|Type de données|Gain typique|Recommandation|
|---|---|---|
|Logs texte|60-80%|✅ Compression fortement recommandée|
|Code source|50-70%|✅ Recommandée|
|JSON/XML|70-85%|✅ Très efficace|
|Images JPEG/PNG|0-5%|❌ Éviter|
|Vidéos|0-2%|❌ Éviter|
|Archives .gz/.zip|0-3%|❌ Éviter|
|Binaires compilés|10-30%|⚠️ Selon contexte|

> [!warning] Overhead CPU La compression consomme du CPU côté client ET serveur. Sur des machines peu puissantes ou très sollicitées, cela peut dégrader les performances même avec une connexion lente.

---

## ⏱️ Keepalive et timeouts

### Pourquoi c'est important ?

Les connexions SSH peuvent être interrompues par :

- **Firewalls** qui coupent les connexions inactives
- **NAT** qui expire les mappings de ports
- **Proxies** qui timeout les connexions idle
- **Problèmes réseau** transitoires

Les mécanismes keepalive et timeout permettent de :

- Maintenir les connexions longues durées actives
- Détecter rapidement les connexions mortes
- Éviter les sessions zombies
- Reconnecter automatiquement

### ServerAliveInterval (Client → Serveur)

Envoie des paquets keepalive du **client vers le serveur** pour maintenir la connexion active.

```bash
# Envoyer un keepalive toutes les 60 secondes
ssh -o ServerAliveInterval=60 user@host

# Combiné avec ServerAliveCountMax
ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=3 user@host
```

**Fonctionnement :**

- Le client envoie un paquet toutes les X secondes
- Si aucune réponse après `ServerAliveCountMax` tentatives → déconnexion
- Détecte les serveurs qui ne répondent plus

> [!example] Configuration typique
> 
> ```bash
> # Dans ~/.ssh/config
> Host *
>     ServerAliveInterval 60
>     ServerAliveCountMax 3
> ```
> 
> Cela signifie : envoyer un keepalive toutes les 60 secondes, et se déconnecter si 3 paquets consécutifs restent sans réponse (timeout après 180 secondes d'inactivité).

### ConnectTimeout

Définit le **délai maximum** pour établir la connexion initiale.

```bash
# Timeout de 10 secondes pour la connexion
ssh -o ConnectTimeout=10 user@host

# Utile pour tester rapidement des serveurs
ssh -o ConnectTimeout=5 user@host && echo "✅ Serveur accessible"
```

**Cas d'usage :**

- Scripts de monitoring (éviter les blocages)
- Tests de disponibilité rapides
- Failover automatique

> [!tip] Valeur par défaut Sans `ConnectTimeout`, SSH peut attendre très longtemps (jusqu'au timeout TCP du système, souvent 2-3 minutes).

### ConnectionAttempts

Nombre de **tentatives de connexion** avant d'abandonner.

```bash
# Tenter 3 fois de se connecter
ssh -o ConnectionAttempts=3 user@host

# Combiné avec ConnectTimeout
ssh -o ConnectTimeout=5 -o ConnectionAttempts=3 user@host
```

### Configuration complète pour connexions instables

```bash
# En ligne de commande
ssh \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=2 \
  -o ConnectTimeout=10 \
  -o ConnectionAttempts=3 \
  user@serveur-instable
```

```bash
# Dans ~/.ssh/config (recommandé)
Host serveur-instable
    HostName serveur.example.com
    User admin
    
    # Keepalive client → serveur
    ServerAliveInterval 30
    ServerAliveCountMax 2
    
    # Timeouts de connexion
    ConnectTimeout 10
    ConnectionAttempts 3
    
    # Optionnel : compression pour connexion lente
    Compression yes
```

### TCPKeepAlive vs ServerAlive

|Paramètre|Niveau|Direction|Traversée NAT/FW|Recommandation|
|---|---|---|---|---|
|`TCPKeepAlive`|TCP|Bidirectionnel|❌ Non|⚠️ Moins fiable|
|`ServerAliveInterval`|SSH|Client → Serveur|✅ Oui|✅ Recommandé|

```bash
# TCPKeepAlive (déconseillé pour les keepalives)
ssh -o TCPKeepAlive=yes user@host

# ServerAliveInterval (recommandé)
ssh -o ServerAliveInterval=60 user@host
```

> [!warning] TCPKeepAlive `TCPKeepAlive` fonctionne au niveau TCP et peut être bloqué par les firewalls/NAT. `ServerAliveInterval` fonctionne au niveau SSH (dans le tunnel chiffré) et traverse mieux les équipements réseau.

### Exemples de configurations selon les scénarios

#### Connexion derrière NAT/Firewall strict

```bash
Host serveur-via-nat
    HostName serveur.com
    User admin
    
    # Keepalive agressif pour éviter l'expiration NAT
    ServerAliveInterval 15
    ServerAliveCountMax 3
```

#### Session longue durée (compilation, backup)

```bash
Host serveur-build
    HostName build.example.com
    User jenkins
    
    # Keepalive relâché (économiser la bande passante)
    ServerAliveInterval 120
    ServerAliveCountMax 5
```

#### Scripts de monitoring/automation

```bash
Host serveurs-prod-*
    # Timeout court pour ne pas bloquer
    ConnectTimeout 5
    ConnectionAttempts 2
    
    # Pas de keepalive (connexions courtes)
    ServerAliveInterval 0
```

#### Connexion via réseau mobile instable

```bash
Host mobile-server
    HostName remote.example.com
    User user
    
    # Keepalive fréquent
    ServerAliveInterval 20
    ServerAliveCountMax 4
    
    # Plusieurs tentatives
    ConnectTimeout 15
    ConnectionAttempts 5
    
    # Compression pour économiser la bande passante
    Compression yes
```

> [!tip] Éviter les déconnexions inopinées Pour les sessions interactives longues (serveurs de développement, bastion), configurez :
> 
> ```bash
> ServerAliveInterval 60
> ServerAliveCountMax 3
> ```
> 
> Cela maintient la connexion active sans surcharger le réseau.

### Vérification des paramètres actifs

```bash
# Afficher la configuration SSH complète pour un hôte
ssh -G user@host | grep -E "(serveralive|connecttimeout|connectionattempts)"

# Tester avec mode verbeux
ssh -v user@host 2>&1 | grep -E "(timeout|keepalive)"
```

> [!info] Priorité des paramètres L'ordre de priorité est :
> 
> 1. Options en ligne de commande (`-o`)
> 2. Fichier `~/.ssh/config` (utilisateur)
> 3. Fichier `/etc/ssh/ssh_config` (système)
> 
> Les paramètres spécifiés en ligne de commande écrasent toujours ceux des fichiers de configuration.

---

## 🎯 Résumé des options avancées

|Option/Paramètre|Fonction|Usage typique|
|---|---|---|
|`'commande'`|Exécution distante|Automatisation, scripts|
|`-t`|Forcer pseudo-terminal|sudo, vim, top|
|`-v`, `-vv`, `-vvv`|Mode debug|Diagnostic problèmes|
|`-C`|Compression|Connexions lentes, logs|
|`ServerAliveInterval`|Keepalive client|Maintien connexion|
|`ConnectTimeout`|Timeout connexion|Scripts, monitoring|
|`ConnectionAttempts`|Tentatives|Réseau instable|

> [!tip] Bonne pratique Centralisez vos configurations dans `~/.ssh/config` plutôt que d'utiliser systématiquement les options en ligne de commande. C'est plus maintenable et moins sujet aux erreurs.

---

**🎓 Vous maîtrisez maintenant les options avancées de connexion SSH !**