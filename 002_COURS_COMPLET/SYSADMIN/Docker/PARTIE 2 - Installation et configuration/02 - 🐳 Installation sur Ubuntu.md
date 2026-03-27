

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

L'installation de Docker sur Ubuntu peut se faire de plusieurs manières, mais la méthode du repository officiel est la plus recommandée car elle offre les mises à jour automatiques et la meilleure stabilité. Cette partie couvre l'installation complète, la configuration du système et la gestion des permissions utilisateurs.

> [!info] Pourquoi utiliser le repository officiel ?
> 
> - **Mises à jour automatiques** : Vous recevez les dernières versions de Docker via `apt update`
> - **Stabilité** : Les packages sont testés et signés par Docker Inc.
> - **Facilité de maintenance** : Intégration native avec le gestionnaire de packages Ubuntu
> - **Support officiel** : Documentation et support alignés avec la version installée

---

## Méthode repository officiel

### Désinstallation des anciennes versions

Avant d'installer Docker, il est crucial de supprimer toute ancienne installation qui pourrait entrer en conflit.

```bash
# Suppression des anciennes versions de Docker
sudo apt-get remove docker docker-engine docker.io containerd runc

# Suppression complète incluant les configurations
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

> [!warning] Conservation des données : La commande ci-dessus ne supprime PAS vos images, conteneurs, volumes ou configurations personnalisées. Ces données restent dans `/var/lib/docker/` et seront automatiquement réutilisées après la nouvelle installation.

### Configuration du repository

#### 1. Mise à jour du système et installation des prérequis

```bash
# Mise à jour de la liste des packages
sudo apt-get update

# Installation des packages nécessaires pour HTTPS
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

**Explication des packages** :

- `ca-certificates` : Certificats pour valider les connexions HTTPS
- `curl` : Outil pour télécharger des fichiers depuis Internet
- `gnupg` : Outil de chiffrement pour vérifier les signatures GPG
- `lsb-release` : Informations sur la version Ubuntu

#### 2. Ajout de la clé GPG officielle de Docker

```bash
# Création du répertoire pour les clés APT
sudo install -m 0755 -d /etc/apt/keyrings

# Téléchargement et installation de la clé GPG Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Définition des permissions appropriées
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

> [!tip] Que fait la clé GPG ? La clé GPG permet à votre système de vérifier l'authenticité des packages Docker téléchargés. C'est une mesure de sécurité qui garantit que les packages proviennent bien de Docker Inc. et n'ont pas été modifiés.

#### 3. Configuration du repository

```bash
# Ajout du repository Docker aux sources APT
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

**Décomposition de la commande** :

- `arch=$(dpkg --print-architecture)` : Détecte automatiquement votre architecture (amd64, arm64, etc.)
- `signed-by=/etc/apt/keyrings/docker.gpg` : Spécifie la clé pour vérifier les signatures
- `$(lsb_release -cs)` : Détecte votre version Ubuntu (focal, jammy, noble, etc.)
- `stable` : Utilise le canal stable (recommandé pour la production)

> [!info] Canaux disponibles Docker propose trois canaux :
> 
> - **stable** : Versions stables, recommandé pour la production
> - **test** : Versions candidates avant la stable
> - **nightly** : Builds quotidiens pour le développement

### Installation de Docker Engine

```bash
# Mise à jour de la liste des packages avec le nouveau repository
sudo apt-get update

# Installation de Docker Engine, CLI, Containerd et plugins
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**Composants installés** :

|Composant|Description|Rôle|
|---|---|---|
|`docker-ce`|Docker Community Edition Engine|Moteur principal de Docker|
|`docker-ce-cli`|Interface en ligne de commande|Commandes `docker` dans le terminal|
|`containerd.io`|Runtime des conteneurs|Gère le cycle de vie des conteneurs|
|`docker-buildx-plugin`|Builder avancé|Construction d'images multi-architectures|
|`docker-compose-plugin`|Compose v2|Gestion d'applications multi-conteneurs|

> [!example] Installation d'une version spécifique Si vous avez besoin d'une version particulière de Docker :
> 
> ```bash
> # Lister les versions disponibles
> apt-cache madison docker-ce
> 
> # Installer une version spécifique (remplacer VERSION_STRING)
> sudo apt-get install docker-ce=5:24.0.0-1~ubuntu.22.04~jammy \
>                      docker-ce-cli=5:24.0.0-1~ubuntu.22.04~jammy \
>                      containerd.io \
>                      docker-buildx-plugin \
>                      docker-compose-plugin
> ```

### Vérification de l'installation

```bash
# Vérification de la version installée
docker --version

# Affichage des informations détaillées
sudo docker version

# Test avec un conteneur Hello World
sudo docker run hello-world
```

**Sortie attendue du test Hello World** :

```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
...
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

> [!tip] Que vérifie le test hello-world ? Ce test valide que Docker peut :
> 
> 1. Télécharger des images depuis Docker Hub
> 2. Créer un conteneur depuis cette image
> 3. Exécuter le conteneur
> 4. Afficher la sortie du conteneur
> 5. Arrêter et supprimer le conteneur

---

## Configuration post-installation

### Démarrage automatique

Par défaut, Docker est configuré pour démarrer automatiquement au boot du système. Voici comment gérer ce comportement.

```bash
# Vérifier le statut du service Docker
sudo systemctl status docker

# Activer le démarrage automatique (déjà activé par défaut)
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Désactiver le démarrage automatique (si nécessaire)
sudo systemctl disable docker.service
sudo systemctl disable containerd.service

# Démarrer Docker manuellement
sudo systemctl start docker

# Arrêter Docker
sudo systemctl stop docker

# Redémarrer Docker
sudo systemctl restart docker
```

> [!info] Services Docker
> 
> - **docker.service** : Le daemon Docker principal
> - **containerd.service** : Le runtime des conteneurs (dépendance de Docker)
> 
> Les deux services doivent être actifs pour que Docker fonctionne correctement.

### Configuration du daemon Docker

Le daemon Docker peut être configuré via le fichier `/etc/docker/daemon.json`. Ce fichier n'existe pas par défaut et doit être créé.

```bash
# Création du fichier de configuration
sudo nano /etc/docker/daemon.json
```

**Configuration de base recommandée** :

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-address-pools": [
    {
      "base": "172.17.0.0/16",
      "size": 24
    }
  ]
}
```

**Explication des paramètres** :

|Paramètre|Valeur|Description|
|---|---|---|
|`log-driver`|`json-file`|Format de logging par défaut|
|`log-opts.max-size`|`10m`|Taille maximale d'un fichier de log|
|`log-opts.max-file`|`3`|Nombre de fichiers de log à conserver|
|`storage-driver`|`overlay2`|Driver de stockage (recommandé pour Ubuntu)|
|`default-address-pools`|Configuration réseau|Plage d'adresses IP pour les réseaux Docker|

> [!warning] Redémarrage requis Après toute modification du fichier `daemon.json`, vous devez redémarrer Docker :
> 
> ```bash
> sudo systemctl restart docker
> ```

**Configurations avancées utiles** :

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-address-pools": [
    {
      "base": "172.17.0.0/16",
      "size": 24
    }
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "insecure-registries": [],
  "registry-mirrors": [],
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true
}
```

**Paramètres additionnels** :

- `dns` : Serveurs DNS personnalisés pour les conteneurs
- `insecure-registries` : Registries HTTP non sécurisés (déconseillé en production)
- `registry-mirrors` : Miroirs de Docker Hub pour accélérer les téléchargements
- `live-restore` : Les conteneurs continuent de fonctionner lors d'un redémarrage du daemon
- `userland-proxy` : Désactiver le proxy userland (meilleures performances)
- `no-new-privileges` : Sécurité renforcée pour les conteneurs

### Configuration du logging

Docker offre plusieurs drivers de logging. Voici les options principales :

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "compress": "true",
    "labels": "production_status",
    "env": "os,customer"
  }
}
```

**Drivers de logging disponibles** :

|Driver|Usage|Avantages|
|---|---|---|
|`json-file`|Par défaut|Simple, intégré, fonctionne avec `docker logs`|
|`syslog`|Intégration système|Centralisation avec le syslog du système|
|`journald`|Systemd|Intégration native avec journalctl|
|`gelf`|Graylog|Envoi vers des serveurs de logging centralisés|
|`fluentd`|Fluentd|Pipeline de logging flexible|
|`awslogs`|AWS CloudWatch|Intégration cloud AWS|
|`none`|Désactiver|Aucun log (performances maximales)|

> [!tip] Gestion de l'espace disque Sans rotation des logs, les fichiers de logs peuvent rapidement remplir votre disque. La configuration `max-size` et `max-file` est **essentielle** en production :
> 
> - `max-size: 10m` limite chaque fichier à 10 Mo
> - `max-file: 3` conserve 3 fichiers rotationnés
> - Total maximal : 30 Mo par conteneur

### Mise en place d'un proxy (optionnel)

Si vous êtes derrière un proxy d'entreprise, Docker a besoin de configurations spécifiques.

#### Configuration pour le daemon Docker

```bash
# Création du répertoire de configuration systemd pour Docker
sudo mkdir -p /etc/systemd/system/docker.service.d

# Création du fichier de configuration proxy
sudo nano /etc/systemd/system/docker.service.d/http-proxy.conf
```

**Contenu du fichier `http-proxy.conf`** :

```ini
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:8080"
Environment="HTTPS_PROXY=http://proxy.example.com:8080"
Environment="NO_PROXY=localhost,127.0.0.1,docker-registry.example.com,.corp"
```

```bash
# Rechargement de la configuration systemd
sudo systemctl daemon-reload

# Redémarrage de Docker
sudo systemctl restart docker

# Vérification que les variables sont bien prises en compte
sudo systemctl show --property=Environment docker
```

#### Configuration pour les builds Docker

Le daemon proxy ne s'applique pas automatiquement aux builds. Vous devez les configurer séparément dans `~/.docker/config.json` :

```json
{
  "proxies": {
    "default": {
      "httpProxy": "http://proxy.example.com:8080",
      "httpsProxy": "http://proxy.example.com:8080",
      "noProxy": "localhost,127.0.0.1,.example.com"
    }
  }
}
```

> [!info] Différence daemon vs build proxy
> 
> - **Daemon proxy** (`/etc/systemd/system/docker.service.d/`) : Utilisé par Docker pour pull/push des images
> - **Build proxy** (`~/.docker/config.json`) : Utilisé pendant `docker build` pour les téléchargements dans l'image

---

## Ajout utilisateur au groupe docker

### Pourquoi ajouter un utilisateur au groupe

Par défaut, la commande `docker` nécessite des privilèges `root`. Sans ajout au groupe docker, vous devez utiliser `sudo` pour chaque commande :

```bash
# Sans appartenance au groupe (nécessite sudo)
sudo docker ps
sudo docker run nginx
sudo docker build -t myapp .
```

L'ajout au groupe docker permet d'exécuter les commandes sans `sudo` :

```bash
# Avec appartenance au groupe (pas de sudo)
docker ps
docker run nginx
docker build -t myapp .
```

> [!info] Comment ça fonctionne ? Le daemon Docker écoute sur un socket Unix (`/var/run/docker.sock`) qui appartient au groupe `docker`. Seuls les membres de ce groupe peuvent communiquer avec le daemon sans privilèges root.

### Procédure d'ajout

```bash
# Création du groupe docker (normalement déjà créé lors de l'installation)
sudo groupadd docker

# Ajout de votre utilisateur au groupe docker
sudo usermod -aG docker $USER

# Ajout d'un utilisateur spécifique
sudo usermod -aG docker nom_utilisateur

# Vérification de l'appartenance au groupe
groups $USER
```

**Activation des changements** :

```bash
# Méthode 1 : Nouvelle session de groupe (sans déconnexion)
newgrp docker

# Méthode 2 : Déconnexion/reconnexion complète (recommandé)
# Déconnectez-vous puis reconnectez-vous

# Méthode 3 : Redémarrage du système (le plus propre)
sudo reboot
```

> [!warning] Les changements de groupe nécessitent une nouvelle session L'ajout à un groupe n'est effectif qu'après :
> 
> 1. Une nouvelle connexion SSH
> 2. Une déconnexion/reconnexion de votre session graphique
> 3. L'utilisation de `newgrp docker`
> 4. Un redémarrage complet
> 
> La commande `groups` dans le terminal actuel continuera d'afficher l'ancienne liste jusqu'à l'ouverture d'une nouvelle session.

**Vérification que ça fonctionne** :

```bash
# Test sans sudo
docker run hello-world

# Si ça fonctionne, vous verrez :
# "Hello from Docker!"
# Sans message d'erreur de permission

# Vérification des permissions du socket
ls -l /var/run/docker.sock
# Devrait afficher : srw-rw---- 1 root docker ...
```

### Implications de sécurité

> [!warning] Sécurité : Équivalent à l'accès root Ajouter un utilisateur au groupe `docker` lui donne effectivement des **privilèges root** sur le système. Voici pourquoi :

**Un utilisateur du groupe docker peut** :

```bash
# Monter n'importe quel répertoire du système
docker run -v /:/host -it ubuntu chroot /host

# Lire n'importe quel fichier
docker run -v /etc/shadow:/shadow ubuntu cat /shadow

# Modifier des fichiers système
docker run -v /etc:/etc ubuntu bash -c "echo 'malicious' >> /etc/hosts"

# Obtenir un shell root
docker run -v /:/mnt -it ubuntu chroot /mnt bash
```

**Bonnes pratiques de sécurité** :

1. **Principe du moindre privilège** : N'ajoutez au groupe docker que les utilisateurs qui en ont vraiment besoin
    
2. **Utilisateurs de confiance uniquement** : Traitez l'accès docker comme un accès sudo/root
    
3. **Environnements de production** :
    
    ```bash
    # Utilisez plutôt sudo avec des règles précises dans /etc/sudoers.d/
    username ALL=(ALL) NOPASSWD: /usr/bin/docker ps, /usr/bin/docker logs
    ```
    
4. **Audit des accès** :
    
    ```bash
    # Lister les membres du groupe docker
    getent group docker
    
    # Surveiller les accès au socket Docker
    sudo ausearch -f /var/run/docker.sock
    ```
    
5. **Alternatives pour la production** :
    
    - Utilisez des solutions rootless Docker (Docker en mode utilisateur non-privilégié)
    - Implémentez Docker avec AppArmor ou SELinux
    - Utilisez des orchestrateurs comme Kubernetes avec RBAC

> [!tip] Docker Rootless Pour une sécurité maximale, envisagez Docker en mode rootless qui n'a pas besoin d'accès root. Cette configuration sera abordée dans une partie ultérieure du cours.

**Comparaison des approches** :

|Méthode|Facilité|Sécurité|Usage recommandé|
|---|---|---|---|
|Groupe docker|⭐⭐⭐ Facile|⚠️ Faible|Développement local|
|Sudo à chaque fois|⭐⭐ Moyen|⭐⭐⭐ Élevée|Serveurs partagés|
|Sudo avec règles|⭐ Complexe|⭐⭐⭐ Élevée|Production|
|Docker Rootless|⭐ Complexe|⭐⭐⭐ Maximale|Production sécurisée|

---

## Pièges courants et résolutions

### Erreur : "permission denied" après ajout au groupe

**Symptôme** :

```bash
docker ps
# Got permission denied while trying to connect to the Docker daemon socket
```

**Cause** : Les changements de groupe ne sont pas actifs dans la session actuelle.

**Solution** :

```bash
# Option 1 : Nouvelle session de groupe
newgrp docker

# Option 2 : Se déconnecter et se reconnecter

# Option 3 : Vérifier que l'utilisateur est bien dans le groupe
groups
# Doit afficher : ... docker ...
```

### Erreur : Conflit entre anciennes et nouvelles installations

**Symptôme** :

```bash
sudo apt-get install docker-ce
# Package docker-ce has no installation candidate
```

**Cause** : Problème avec les sources APT ou cache corrompu.

**Solution** :

```bash
# Nettoyer le cache APT
sudo apt-get clean
sudo apt-get autoclean

# Mettre à jour les sources
sudo apt-get update

# Réinstaller si nécessaire
sudo apt-get install --reinstall docker-ce docker-ce-cli containerd.io
```

### Erreur : Le daemon ne démarre pas après configuration

**Symptôme** :

```bash
sudo systemctl status docker
# Active: failed (Result: exit-code)
```

**Cause** : Erreur de syntaxe dans `/etc/docker/daemon.json`.

**Solution** :

```bash
# Vérifier les logs du daemon
sudo journalctl -xeu docker.service

# Valider la syntaxe JSON
cat /etc/docker/daemon.json | python3 -m json.tool

# Ou avec jq
cat /etc/docker/daemon.json | jq .

# Corriger les erreurs et redémarrer
sudo systemctl restart docker
```

> [!tip] Validation JSON Avant de redémarrer Docker après modification de `daemon.json`, validez toujours la syntaxe JSON. Une simple virgule manquante empêchera Docker de démarrer.

### Erreur : Espace disque insuffisant

**Symptôme** :

```bash
docker build -t myapp .
# no space left on device
```

**Cause** : Accumulation d'images, conteneurs et volumes inutilisés.

**Solution** :

```bash
# Voir l'utilisation disque
docker system df

# Nettoyer les ressources inutilisées
docker system prune -a

# Nettoyer spécifiquement
docker image prune -a    # Images
docker container prune   # Conteneurs arrêtés
docker volume prune      # Volumes non utilisés
```

### Erreur : Problème de résolution DNS dans les conteneurs

**Symptôme** :

```bash
docker run ubuntu apt-get update
# Temporary failure resolving 'archive.ubuntu.com'
```

**Cause** : Problème de configuration DNS.

**Solution** :

```bash
# Ajouter des DNS dans /etc/docker/daemon.json
sudo nano /etc/docker/daemon.json
```

```json
{
  "dns": ["8.8.8.8", "8.8.4.4", "1.1.1.1"]
}
```

```bash
# Redémarrer Docker
sudo systemctl restart docker
```

### Port 80/443 déjà utilisé

**Symptôme** :

```bash
docker run -p 80:80 nginx
# Error: Bind for 0.0.0.0:80 failed: port is already allocated
```

**Cause** : Apache, Nginx ou un autre service utilise déjà le port.

**Solution** :

```bash
# Identifier le processus utilisant le port
sudo lsof -i :80
sudo netstat -tulpn | grep :80

# Arrêter le service conflictuel
sudo systemctl stop apache2
# ou
sudo systemctl stop nginx

# Ou utiliser un autre port
docker run -p 8080:80 nginx
```

---

> [!info] Configuration terminée Votre installation Docker sur Ubuntu est maintenant complète et configurée. Vous pouvez désormais utiliser Docker en tant qu'utilisateur standard et le daemon est optimisé pour une utilisation quotidienne.