# 

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

## Pourquoi vérifier l'installation ?

La vérification de l'installation Docker est une étape cruciale qui vous permet de :

- **Confirmer que Docker est correctement installé** sur votre système
- **Valider la communication** entre le client Docker et le daemon Docker
- **Tester les permissions** et l'accès aux ressources système
- **Identifier rapidement les problèmes** de configuration avant de commencer à travailler
- **S'assurer que toute la chaîne fonctionne** : téléchargement d'images, création de conteneurs, exécution

> [!info] Client vs Daemon Docker fonctionne selon une architecture client-serveur. Le client Docker (CLI) communique avec le daemon Docker qui fait le travail réel de construction, exécution et distribution des conteneurs.

---

## Commandes de test essentielles

### docker --version

La commande la plus simple pour vérifier que Docker est installé.

```bash
docker --version
```

**Sortie attendue :**

```
Docker version 24.0.7, build afdd53b
```

> [!tip] Quand l'utiliser ? Utilisez cette commande pour une vérification rapide de la présence de Docker et de sa version. Idéal pour les scripts automatisés ou les vérifications rapides.

**Ce qu'elle vérifie :**

- ✅ L'exécutable Docker est présent dans le PATH
- ✅ Le client Docker CLI est fonctionnel
- ❌ Ne vérifie PAS que le daemon Docker est en cours d'exécution

---

### docker version

Une commande plus détaillée qui affiche les informations complètes du client ET du serveur.

```bash
docker version
```

**Sortie attendue :**

```
Client: Docker Engine - Community
 Version:           24.0.7
 API version:       1.43
 Go version:        go1.20.10
 Git commit:        afdd53b
 Built:             Thu Oct 26 09:07:41 2023
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          24.0.7
  API version:      1.43 (minimum version 1.12)
  Go version:       go1.20.10
  Git commit:       311b9ff
  Built:            Thu Oct 26 09:07:41 2023
  OS/Arch:          linux/amd64
  Experimental:     false
```

**Ce qu'elle vérifie :**

- ✅ Le client Docker fonctionne
- ✅ Le daemon Docker est actif et répond
- ✅ La communication client-serveur est établie
- ✅ Les versions du client et du serveur

> [!warning] Erreur "Cannot connect to the Docker daemon" Si vous voyez cette erreur, cela signifie que le daemon Docker n'est pas démarré ou que vous n'avez pas les permissions nécessaires. Vérifiez que le service est actif et que votre utilisateur appartient au groupe `docker`.

**Tableau comparatif des versions :**

|Élément|Client|Serveur|Importance|
|---|---|---|---|
|Version|Version du CLI|Version du daemon|Doit être compatible|
|API version|Version API utilisée|Version API supportée|Compatibilité des commandes|
|OS/Arch|Système client|Système serveur|Peut différer (ex: client Mac, serveur Linux)|

---

### docker info

La commande la plus complète pour obtenir des informations détaillées sur votre installation Docker.

```bash
docker info
```

**Sortie attendue (extrait) :**

```
Client:
 Version:    24.0.7
 Context:    default

Server:
 Containers: 3
  Running: 1
  Paused: 0
  Stopped: 2
 Images: 15
 Server Version: 24.0.7
 Storage Driver: overlay2
  Backing Filesystem: extfs
 Logging Driver: json-file
 Cgroup Driver: systemd
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
 Swarm: inactive
 Runtimes: runc io.containerd.runc.v2
 Default Runtime: runc
 Kernel Version: 5.15.0-91-generic
 Operating System: Ubuntu 22.04.3 LTS
 OSType: linux
 Architecture: x86_64
 CPUs: 8
 Total Memory: 15.54GiB
 Docker Root Dir: /var/lib/docker
```

**Informations clés à vérifier :**

|Information|Signification|Valeur attendue|
|---|---|---|
|**Containers**|Nombre total de conteneurs|Varie selon utilisation|
|**Running**|Conteneurs actifs|0 au début|
|**Images**|Images Docker stockées|0 au début|
|**Storage Driver**|Pilote de stockage utilisé|`overlay2` (recommandé)|
|**Cgroup Driver**|Gestionnaire de groupes de contrôle|`systemd` (Linux moderne)|
|**Docker Root Dir**|Répertoire de données Docker|`/var/lib/docker` (Linux)|

> [!tip] Diagnostic complet Utilisez `docker info` lorsque vous devez diagnostiquer un problème ou vérifier la configuration système complète. C'est votre outil de référence pour comprendre l'état global de votre installation.

**Ce qu'elle vérifie :**

- ✅ État complet du système Docker
- ✅ Ressources disponibles (CPU, RAM)
- ✅ Configuration du stockage
- ✅ Plugins et drivers actifs
- ✅ Statistiques d'utilisation

---

### docker ps

Liste les conteneurs en cours d'exécution.

```bash
# Conteneurs actifs uniquement
docker ps

# Tous les conteneurs (actifs et arrêtés)
docker ps -a

# Avec colonnes personnalisées
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
```

**Sortie attendue (vide après installation) :**

```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

**Options utiles :**

```bash
# Afficher seulement les IDs
docker ps -q

# Afficher le dernier conteneur créé
docker ps -l

# Filtrer par statut
docker ps -a --filter "status=exited"
```

> [!example] Lecture de la sortie docker ps
> 
> ```
> CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS                NAMES
> a1b2c3d4e5f6   nginx:latest  "nginx -g 'daemon of…"  2 minutes ago    Up 2 minutes    0.0.0.0:80->80/tcp   web-server
> ```
> 
> - **CONTAINER ID** : Identifiant court du conteneur
> - **IMAGE** : Image utilisée pour créer le conteneur
> - **COMMAND** : Commande exécutée dans le conteneur
> - **CREATED** : Date de création
> - **STATUS** : État actuel (Up = actif, Exited = arrêté)
> - **PORTS** : Mapping des ports
> - **NAMES** : Nom du conteneur (auto-généré ou personnalisé)

---

## Hello World Docker

Le test "Hello World" est le test standard pour valider qu'une installation Docker est complètement fonctionnelle.

### Exécution du conteneur Hello World

```bash
docker run hello-world
```

**Sortie attendue :**

```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
c1ec31eb5944: Pull complete
Digest: sha256:1408fec50309afee38f3535383f5b09419e6dc0925bc69891e79d84cc4cdcec6
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

> [!info] Première exécution La première fois que vous exécutez cette commande, Docker va télécharger l'image `hello-world` depuis Docker Hub. Les exécutions suivantes seront instantanées car l'image sera déjà en cache local.

---

### Comprendre ce qui s'est passé

Le processus complet en 4 étapes :

**1. Le client contacte le daemon** 🔄

```
Vous tapez: docker run hello-world
       ↓
Client Docker (CLI)
       ↓
Daemon Docker (serveur)
```

**2. Le daemon télécharge l'image** ⬇️

```
Daemon → Docker Hub (registre d'images)
       ← Image hello-world téléchargée
```

**3. Le daemon crée et exécute le conteneur** 🚀

```
Image hello-world
       ↓
Création d'un conteneur
       ↓
Exécution du programme dans le conteneur
```

**4. La sortie est renvoyée au client** 📤

```
Sortie du conteneur
       ↓
Daemon Docker
       ↓
Client Docker
       ↓
Votre terminal
```

> [!tip] Processus complet validé Si vous voyez le message "Hello from Docker!", cela signifie que TOUTE la chaîne fonctionne : client, daemon, réseau, téléchargement d'images, création de conteneurs, et exécution. Votre installation est complètement opérationnelle !

---

### Vérifier les images téléchargées

Après l'exécution, l'image reste sur votre système :

```bash
docker images
```

**Sortie attendue :**

```
REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
hello-world   latest    9c7a54a9a43c   7 months ago   13.3kB
```

**Informations des colonnes :**

|Colonne|Description|Exemple|
|---|---|---|
|**REPOSITORY**|Nom de l'image|`hello-world`|
|**TAG**|Version/étiquette|`latest`|
|**IMAGE ID**|Identifiant unique|`9c7a54a9a43c`|
|**CREATED**|Date de création|`7 months ago`|
|**SIZE**|Taille de l'image|`13.3kB`|

> [!info] Taille de hello-world L'image `hello-world` ne fait que 13 KB car elle est extrêmement minimaliste. C'est l'une des plus petites images Docker existantes, conçue uniquement pour tester l'installation.

**Commandes utiles pour gérer les images :**

```bash
# Afficher les détails d'une image
docker image inspect hello-world

# Supprimer une image
docker rmi hello-world

# Supprimer les images non utilisées
docker image prune
```

---

### Vérifier l'historique des conteneurs

Le conteneur hello-world s'est exécuté puis arrêté automatiquement :

```bash
docker ps -a
```

**Sortie attendue :**

```
CONTAINER ID   IMAGE         COMMAND    CREATED          STATUS                      PORTS     NAMES
a1b2c3d4e5f6   hello-world   "/hello"   2 minutes ago    Exited (0) 2 minutes ago              optimistic_curie
```

**Analyse de la sortie :**

- **STATUS** : `Exited (0)` signifie que le conteneur s'est terminé avec succès
    - Code `0` = succès
    - Code différent de `0` = erreur
- **COMMAND** : `/hello` est le programme exécuté dans le conteneur
- **NAMES** : Docker génère un nom aléatoire si vous n'en spécifiez pas

> [!example] Cycle de vie du conteneur hello-world
> 
> ```
> Création → Démarrage → Exécution (affichage du message) → Arrêt automatique
>    ↓           ↓              ↓                                 ↓
> docker run   Image chargée   Programme /hello exécuté    Conteneur avec status Exited
> ```

**Commandes pour gérer les conteneurs arrêtés :**

```bash
# Redémarrer un conteneur arrêté (par ID ou nom)
docker start a1b2c3d4e5f6

# Supprimer un conteneur spécifique
docker rm a1b2c3d4e5f6

# Supprimer tous les conteneurs arrêtés
docker container prune

# Supprimer automatiquement après exécution
docker run --rm hello-world
```

> [!tip] Option --rm L'option `--rm` supprime automatiquement le conteneur après son arrêt. C'est très utile pour les tests et pour éviter d'accumuler des conteneurs arrêtés.

---

## Tests de fonctionnement avancés

Une fois le test Hello World réussi, vous pouvez effectuer des tests supplémentaires :

### Test avec un conteneur interactif

```bash
# Lancer un conteneur Ubuntu interactif
docker run -it ubuntu bash
```

**Ce que cela teste :**

- ✅ Téléchargement d'une image plus volumineuse
- ✅ Mode interactif (terminal)
- ✅ Allocation d'un pseudo-TTY

Une fois dans le conteneur :

```bash
# Vous êtes maintenant dans Ubuntu !
root@a1b2c3d4e5f6:/# ls
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

# Vérifier la version
root@a1b2c3d4e5f6:/# cat /etc/os-release

# Quitter le conteneur
root@a1b2c3d4e5f6:/# exit
```

---

### Test avec un serveur web

```bash
# Lancer un serveur nginx
docker run -d -p 8080:80 --name test-nginx nginx
```

**Options expliquées :**

- `-d` : Mode détaché (arrière-plan)
- `-p 8080:80` : Mapper le port 80 du conteneur vers le port 8080 de l'hôte
- `--name test-nginx` : Donner un nom personnalisé au conteneur
- `nginx` : Nom de l'image à utiliser

**Vérification :**

```bash
# Vérifier que le conteneur tourne
docker ps

# Tester avec curl
curl http://localhost:8080
```

**Sortie attendue :** Vous devriez voir le HTML de la page d'accueil Nginx.

**Nettoyage :**

```bash
# Arrêter le conteneur
docker stop test-nginx

# Supprimer le conteneur
docker rm test-nginx
```

> [!tip] Test réseau complet Ce test valide non seulement que Docker fonctionne, mais aussi que le mapping de ports et la configuration réseau sont corrects.

---

### Test avec construction d'image

Créez un fichier `Dockerfile` simple :

```bash
# Créer un répertoire de test
mkdir docker-test && cd docker-test

# Créer un Dockerfile
cat > Dockerfile << 'EOF'
FROM alpine:latest
CMD echo "Build et exécution réussis !"
EOF

# Construire l'image
docker build -t test-build .

# Exécuter l'image
docker run --rm test-build
```

**Ce que cela teste :**

- ✅ Capacité à construire des images
- ✅ Lecture de Dockerfile
- ✅ Système de layers
- ✅ Mise en cache des builds

---

## Pièges courants lors de la vérification

### 1. Erreur "permission denied"

```bash
docker: Got permission denied while trying to connect to the Docker daemon socket
```

**Cause :** Votre utilisateur n'a pas les permissions pour accéder au socket Docker.

**Solution :**

```bash
# Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER

# Se déconnecter et se reconnecter (ou redémarrer)
# Ou activer le nouveau groupe immédiatement
newgrp docker

# Vérifier
docker run hello-world
```

> [!warning] Sécurité Ajouter un utilisateur au groupe `docker` lui donne des privilèges équivalents à root. N'ajoutez que des utilisateurs de confiance.

---

### 2. Daemon Docker non démarré

```bash
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Solutions selon l'OS :**

```bash
# Linux (systemd)
sudo systemctl start docker
sudo systemctl enable docker  # Démarrage automatique

# Linux (service)
sudo service docker start

# Vérifier le statut
sudo systemctl status docker
```

---

### 3. Conflit de port

```bash
docker: Error response from daemon: driver failed programming external connectivity:
Bind for 0.0.0.0:8080 failed: port is already allocated.
```

**Solution :**

```bash
# Vérifier quel processus utilise le port
sudo lsof -i :8080
# ou
sudo netstat -tulpn | grep 8080

# Utiliser un port différent
docker run -p 8081:80 nginx
```

---

### 4. Erreur de téléchargement d'image

```bash
Error response from daemon: Get "https://registry-1.docker.io/v2/": dial tcp: lookup registry-1.docker.io: no such host
```

**Causes possibles :**

- ❌ Problème de connexion internet
- ❌ Proxy non configuré
- ❌ DNS non fonctionnel
- ❌ Pare-feu bloquant Docker

**Solutions :**

```bash
# Tester la connectivité
ping registry-1.docker.io

# Vérifier les DNS
cat /etc/resolv.conf

# Configurer un proxy si nécessaire (dans /etc/docker/daemon.json)
{
  "proxies": {
    "http-proxy": "http://proxy.example.com:8080",
    "https-proxy": "http://proxy.example.com:8080"
  }
}

# Redémarrer Docker
sudo systemctl restart docker
```

---

### 5. Espace disque insuffisant

```bash
no space left on device
```

**Vérification :**

```bash
# Vérifier l'espace disque
df -h

# Vérifier l'utilisation de Docker
docker system df
```

**Nettoyage :**

```bash
# Supprimer les conteneurs arrêtés
docker container prune

# Supprimer les images inutilisées
docker image prune

# Nettoyage complet (attention, supprime tout ce qui n'est pas utilisé)
docker system prune -a
```

---

## Bonnes pratiques

### ✅ À faire

1. **Tester systématiquement après installation**
    
    ```bash
    docker --version && docker version && docker info && docker run hello-world
    ```
    
2. **Vérifier les versions régulièrement**
    
    - Assurez-vous que votre Docker est à jour
    - Vérifiez la compatibilité client/serveur
3. **Utiliser --rm pour les tests**
    
    ```bash
    docker run --rm hello-world
    ```
    
    Évite l'accumulation de conteneurs de test
    
4. **Documenter votre configuration**
    
    - Notez la version de Docker installée
    - Gardez trace des problèmes rencontrés et leurs solutions
5. **Configurer le démarrage automatique**
    
    ```bash
    sudo systemctl enable docker
    ```
    

---

### ❌ À éviter

1. **Ne pas vérifier l'installation avant de travailler**
    
    - Vous risquez de perdre du temps sur des problèmes de base
2. **Ignorer les avertissements de `docker info`**
    
    - Les warnings peuvent indiquer des problèmes futurs
3. **Exécuter Docker en root systématiquement**
    
    - Configurez correctement les permissions utilisateur
4. **Laisser accumuler les conteneurs et images de test**
    
    ```bash
    # Vérifier régulièrement
    docker ps -a
    docker images
    ```
    
5. **Ne pas tester le réseau et les ports**
    
    - Validez que le mapping de ports fonctionne

---

### 🎯 Checklist de vérification complète

Après installation, assurez-vous que tous ces tests passent :

```bash
# ✅ Test 1 : Version du client
docker --version

# ✅ Test 2 : Communication client-serveur
docker version

# ✅ Test 3 : Informations système
docker info

# ✅ Test 4 : Hello World
docker run --rm hello-world

# ✅ Test 5 : Conteneur interactif
docker run --rm -it alpine echo "Test réussi"

# ✅ Test 6 : Mapping de port
docker run --rm -d -p 8888:80 --name test-web nginx
curl http://localhost:8888
docker stop test-web

# ✅ Test 7 : Vérification des permissions
docker ps
docker images
```

> [!tip] Script de vérification automatique Créez un script `check-docker.sh` avec ces commandes pour tester rapidement votre installation à tout moment.

---

**🎉 Félicitations !** Si tous ces tests passent, votre installation Docker est complètement fonctionnelle et vous êtes prêt à travailler avec des conteneurs.