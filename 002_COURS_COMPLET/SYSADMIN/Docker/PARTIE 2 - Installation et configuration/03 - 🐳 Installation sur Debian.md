

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

## Introduction

L'installation de Docker sur Debian peut se faire de plusieurs manières, mais la méthode recommandée est l'utilisation du **repository officiel de Docker**. Cette approche garantit que vous obtenez toujours la version la plus récente et les mises à jour de sécurité directement depuis Docker Inc.

> [!info] Pourquoi le repository officiel ?
> 
> - Accès aux dernières versions stables de Docker
> - Mises à jour de sécurité automatiques via `apt`
> - Support officiel de Docker Inc.
> - Meilleure compatibilité et stabilité

---

## Méthode repository officiel

### Préparation du système

Avant d'installer Docker, il faut préparer le système en supprimant d'éventuelles versions conflictuelles et en installant les prérequis.

#### 🗑️ Suppression des anciennes versions

```bash
# Suppression des anciennes versions de Docker (si présentes)
sudo apt-get remove docker docker-engine docker.io containerd runc
```

> [!warning] Attention aux données existantes Cette commande ne supprime pas les images, conteneurs, volumes et configurations existants situés dans `/var/lib/docker/`. Si vous souhaitez repartir de zéro, supprimez ce répertoire manuellement après désinstallation.

#### 📦 Installation des prérequis

```bash
# Mise à jour de la liste des packages
sudo apt-get update

# Installation des packages nécessaires pour ajouter des repositories HTTPS
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

**Explications des packages** :

- `ca-certificates` : Certificats d'autorité pour la vérification SSL/TLS
- `curl` : Outil pour télécharger des fichiers depuis Internet
- `gnupg` : Outil de gestion des clés GPG pour vérifier l'authenticité des packages
- `lsb-release` : Fournit des informations sur la distribution Linux

---

### Configuration du repository Docker

#### 🔑 Ajout de la clé GPG officielle

La clé GPG permet de vérifier l'authenticité des packages Docker téléchargés.

```bash
# Création du répertoire pour les clés GPG (avec permissions appropriées)
sudo install -m 0755 -d /etc/apt/keyrings

# Téléchargement et installation de la clé GPG officielle de Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Application des bonnes permissions sur la clé
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

> [!tip] Explication de la commande curl
> 
> - `-f` : Échoue silencieusement en cas d'erreur HTTP
> - `-s` : Mode silencieux (pas de barre de progression)
> - `-S` : Affiche les erreurs même en mode silencieux
> - `-L` : Suit les redirections HTTP

#### 📝 Ajout du repository Docker

```bash
# Configuration du repository Docker pour Debian
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

**Décomposition de la commande** :

- `$(dpkg --print-architecture)` : Détecte automatiquement l'architecture (amd64, arm64, etc.)
- `signed-by=/etc/apt/keyrings/docker.gpg` : Spécifie la clé GPG pour vérifier les packages
- `$(lsb_release -cs)` : Récupère le nom de code de la version Debian (bullseye, bookworm, etc.)
- `stable` : Canal de release (stable, test ou nightly)

> [!info] Canaux de release disponibles
> 
> - **stable** : Version stable recommandée pour la production
> - **test** : Versions candidates avant la stable
> - **nightly** : Builds quotidiens pour les tests avancés

---

### Installation des packages Docker

```bash
# Mise à jour de la liste des packages avec le nouveau repository
sudo apt-get update

# Installation de Docker Engine, CLI, containerd et plugins
sudo apt-get install docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
```

**Description des packages installés** :

|Package|Description|
|---|---|
|`docker-ce`|Docker Engine (Community Edition) - Le moteur principal|
|`docker-ce-cli`|Interface en ligne de commande pour interagir avec Docker|
|`containerd.io`|Runtime de conteneurs utilisé par Docker|
|`docker-buildx-plugin`|Plugin pour le build avancé d'images multi-plateformes|
|`docker-compose-plugin`|Plugin pour orchestrer des applications multi-conteneurs|

> [!example] Vérification de l'installation
> 
> ```bash
> # Vérifier la version installée
> docker --version
> # Sortie exemple : Docker version 24.0.7, build afdd53b
> 
> # Vérifier que Docker Compose est disponible
> docker compose version
> # Sortie exemple : Docker Compose version v2.23.0
> ```

---

## Configuration post-installation

### Vérification de l'installation

#### ✅ Test avec l'image hello-world

```bash
# Test de l'installation avec l'image officielle hello-world
sudo docker run hello-world
```

**Ce que fait cette commande** :

1. Docker télécharge l'image `hello-world` depuis Docker Hub (si pas déjà présente)
2. Crée un conteneur à partir de cette image
3. Exécute le conteneur qui affiche un message de confirmation
4. Le conteneur s'arrête automatiquement après l'affichage

> [!info] Sortie attendue Si l'installation est réussie, vous verrez un message commençant par :
> 
> ```
> Hello from Docker!
> This message shows that your installation appears to be working correctly.
> ```

#### 🔍 Vérification des services

```bash
# Vérifier le statut du service Docker
sudo systemctl status docker

# Vérifier que Docker démarre au boot
sudo systemctl is-enabled docker
```

---

### Configuration du service Docker

#### 🚀 Activation au démarrage

Par défaut, Docker devrait être configuré pour démarrer automatiquement. Pour le vérifier et le configurer :

```bash
# Activer le démarrage automatique de Docker
sudo systemctl enable docker

# Activer également containerd
sudo systemctl enable containerd

# Démarrer Docker immédiatement (si pas déjà démarré)
sudo systemctl start docker
```

#### 🔄 Commandes de gestion du service

```bash
# Démarrer Docker
sudo systemctl start docker

# Arrêter Docker
sudo systemctl stop docker

# Redémarrer Docker
sudo systemctl restart docker

# Recharger la configuration sans redémarrer
sudo systemctl reload docker

# Afficher les logs du service
sudo journalctl -u docker.service -f
```

> [!warning] Arrêt de Docker Arrêter le service Docker arrêtera tous les conteneurs en cours d'exécution. Assurez-vous de sauvegarder les données importantes avant un arrêt.

---

### Configuration du daemon Docker

Le daemon Docker peut être configuré via le fichier `/etc/docker/daemon.json`. Cette configuration permet de modifier le comportement global de Docker.

#### 📄 Création du fichier de configuration

```bash
# Créer le répertoire de configuration si nécessaire
sudo mkdir -p /etc/docker

# Créer/éditer le fichier de configuration
sudo nano /etc/docker/daemon.json
```

#### ⚙️ Exemple de configuration de base

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

**Explications des paramètres** :

|Paramètre|Description|
|---|---|
|`log-driver`|Driver de logging utilisé (json-file, syslog, journald, etc.)|
|`log-opts.max-size`|Taille maximale d'un fichier de log avant rotation|
|`log-opts.max-file`|Nombre de fichiers de log à conserver|
|`storage-driver`|Driver de stockage pour les images et conteneurs|
|`default-address-pools`|Pools d'adresses IP par défaut pour les réseaux Docker|

> [!tip] Bonnes pratiques de configuration
> 
> - Toujours limiter la taille des logs pour éviter de remplir le disque
> - Utiliser `overlay2` comme storage driver (meilleur performances)
> - Documenter chaque paramètre modifié pour faciliter la maintenance

#### 🔄 Application de la configuration

```bash
# Valider la syntaxe JSON (optionnel mais recommandé)
cat /etc/docker/daemon.json | jq .

# Redémarrer Docker pour appliquer les changements
sudo systemctl restart docker

# Vérifier que Docker a bien redémarré
sudo systemctl status docker
```

> [!warning] Validation de la configuration Une erreur de syntaxe dans `daemon.json` empêchera Docker de démarrer. Toujours valider le JSON avant de redémarrer le service.

---

## Ajout utilisateur au groupe docker

### Pourquoi ajouter un utilisateur au groupe

Par défaut, Docker nécessite des privilèges root pour fonctionner car il interagit avec le daemon Docker via un socket Unix (`/var/run/docker.sock`) qui appartient à root et au groupe `docker`.

**Sans ajout au groupe** :

```bash
# Nécessite sudo à chaque commande
sudo docker ps
sudo docker run nginx
sudo docker images
```

**Avec ajout au groupe** :

```bash
# Pas besoin de sudo
docker ps
docker run nginx
docker images
```

> [!info] Avantages de l'ajout au groupe
> 
> - Simplicité d'utilisation au quotidien
> - Pas besoin de taper `sudo` à chaque commande
> - Meilleure expérience développeur
> - Facilite l'intégration avec les outils de développement

---

### Procédure d'ajout

#### 👤 Ajout d'un utilisateur au groupe docker

```bash
# Ajouter l'utilisateur courant au groupe docker
sudo usermod -aG docker $USER

# Ou spécifier explicitement le nom d'utilisateur
sudo usermod -aG docker nom_utilisateur
```

**Explications des options** :

- `-a` : Append (ajoute sans retirer les autres groupes)
- `-G` : Spécifie le groupe supplémentaire à ajouter
- `$USER` : Variable d'environnement contenant le nom de l'utilisateur courant

#### 🔄 Activation des changements

Les changements de groupe ne prennent effet qu'après une nouvelle session :

```bash
# Option 1 : Se déconnecter et se reconnecter
exit

# Option 2 : Démarrer un nouveau shell avec le nouveau groupe
newgrp docker

# Option 3 : Redémarrer la session SSH (si connexion distante)
```

> [!tip] Vérification de l'appartenance au groupe
> 
> ```bash
> # Vérifier les groupes de l'utilisateur courant
> groups
> 
> # Vérifier qu'on peut exécuter Docker sans sudo
> docker run hello-world
> ```

#### ✅ Test de fonctionnement

```bash
# Cette commande doit fonctionner sans sudo
docker ps

# Tester avec une image simple
docker run --rm hello-world

# Vérifier les informations système
docker info
```

---

### Implications de sécurité

> [!warning] Considérations de sécurité importantes

L'ajout d'un utilisateur au groupe `docker` lui donne effectivement des **privilèges équivalents à root** sur le système hôte. Voici pourquoi :

#### 🚨 Risques potentiels

1. **Montage de volumes arbitraires** :

```bash
# Un utilisateur du groupe docker peut monter n'importe quel répertoire
docker run -v /:/host -it ubuntu bash
# Accès root à tout le système de fichiers de l'hôte
```

2. **Exécution de conteneurs privilégiés** :

```bash
# Désactivation complète des restrictions de sécurité
docker run --privileged -it ubuntu bash
```

3. **Modification des fichiers système** :

```bash
# Montage de /etc pour modifier des fichiers sensibles
docker run -v /etc:/etc_host -it ubuntu bash
```

#### 🛡️ Bonnes pratiques de sécurité

|Pratique|Description|
|---|---|
|**Utilisateurs de confiance uniquement**|N'ajoutez au groupe docker que les utilisateurs qui ont réellement besoin d'accéder à Docker|
|**Audit régulier**|Vérifiez régulièrement qui appartient au groupe docker|
|**Alternatives**|Envisagez Docker rootless pour les environnements multi-utilisateurs|
|**Surveillance**|Monitorez les activités Docker des utilisateurs non-admin|

#### 📋 Vérification des membres du groupe

```bash
# Lister tous les utilisateurs du groupe docker
getent group docker

# Vérifier les permissions du socket Docker
ls -l /var/run/docker.sock
```

> [!tip] Alternative : Docker Rootless Pour les environnements nécessitant une sécurité renforcée, Docker peut être installé et exécuté en mode "rootless", où le daemon Docker fonctionne sans privilèges root. Cette configuration sera abordée dans une partie ultérieure du cours.

#### 🔐 Recommandations finales

- **Environnement de développement** : Ajouter l'utilisateur au groupe docker est généralement acceptable
- **Serveur de production** : Éviter d'ajouter des utilisateurs non-admin au groupe docker
- **Serveurs partagés** : Privilégier des solutions comme Docker rootless ou des outils d'orchestration avec contrôle d'accès
- **Containers sensibles** : Utiliser des politiques de sécurité additionnelles (AppArmor, SELinux)

---

## 🎯 Récapitulatif

Vous avez maintenant une installation Docker complète et fonctionnelle sur Debian avec :

✅ Installation via le repository officiel Docker ✅ Configuration du daemon Docker pour une utilisation optimale ✅ Service Docker activé et démarrant automatiquement ✅ Utilisateur ajouté au groupe docker pour une utilisation simplifiée ✅ Compréhension des implications de sécurité

Votre environnement Docker est prêt pour la création et la gestion de conteneurs.