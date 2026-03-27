

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

## 🎯 Introduction à Docker Compose

### Qu'est-ce que Docker Compose ?

Docker Compose est un outil qui permet de **définir et gérer des applications multi-conteneurs** à l'aide d'un simple fichier de configuration au format YAML. Au lieu de lancer manuellement plusieurs commandes `docker run` avec de nombreux paramètres, vous décrivez l'ensemble de votre stack applicative dans un fichier `docker-compose.yml`.

> [!info] Définition Docker Compose transforme des commandes Docker complexes en une configuration déclarative simple et réutilisable.

**Principe fondamental :** Vous décrivez **QUOI** vous voulez (services, réseaux, volumes) plutôt que **COMMENT** le faire (succession de commandes).

### Utilité et cas d'usage

#### 🎭 Pourquoi utiliser Docker Compose ?

**1. Simplification de la gestion multi-conteneurs**

Sans Docker Compose, pour lancer une application web avec une base de données :

```bash
# Créer un réseau
docker network create mon-reseau

# Lancer la base de données
docker run -d \
  --name ma-db \
  --network mon-reseau \
  -e POSTGRES_PASSWORD=secret \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:15

# Lancer l'application web
docker run -d \
  --name mon-app \
  --network mon-reseau \
  -p 8080:80 \
  -e DATABASE_URL=postgresql://postgres:secret@ma-db:5432/mydb \
  mon-image-app:latest
```

Avec Docker Compose, tout cela devient :

```bash
docker compose up
```

**2. Configuration centralisée et versionnable**

Toute la configuration est dans un fichier `docker-compose.yml` que vous pouvez :

- Versionner avec Git
- Partager avec votre équipe
- Documenter facilement
- Modifier sans refaire toute la configuration

**3. Reproductibilité des environnements**

> [!tip] Reproductibilité Docker Compose garantit que votre application s'exécute de la même manière sur votre machine de développement, celle de vos collègues, et en production.

#### 📦 Cas d'usage principaux

|Cas d'usage|Description|Exemple typique|
|---|---|---|
|**Développement local**|Environnement de dev complet en une commande|Application + Base de données + Redis + Mailcatcher|
|**Tests d'intégration**|Lancer tous les services nécessaires pour les tests|Application + Services dépendants + Base de test|
|**Démonstrations**|Présenter une application complète facilement|Stack complète prête à l'emploi|
|**Microservices**|Orchestrer plusieurs services interdépendants|API Gateway + Plusieurs microservices + Message queue|
|**Prototypage rapide**|Tester rapidement une architecture|Essayer différentes combinaisons de services|

> [!example] Exemple concret : Stack WordPress Au lieu de configurer manuellement WordPress, MySQL, phpMyAdmin et un reverse proxy, Docker Compose permet de décrire ces 4 services dans un seul fichier et de tout démarrer ensemble.

#### ⚡ Avantages clés

**Gestion du cycle de vie simplifiée**

- `docker compose up` : Démarrer tous les services
- `docker compose down` : Arrêter et supprimer tous les conteneurs
- `docker compose restart` : Redémarrer un ou tous les services
- `docker compose logs` : Voir les logs de tous les services

**Orchestration intelligente**

- Gestion automatique des dépendances entre services
- Création automatique des réseaux isolés
- Gestion des volumes persistants
- Scaling horizontal simple (`docker compose up --scale web=3`)

**Isolation par projet**

- Chaque projet Docker Compose a son propre espace de noms
- Pas de conflits entre projets différents
- Nettoyage facile d'un projet entier

### Docker Compose vs Docker CLI

|Aspect|Docker CLI|Docker Compose|
|---|---|---|
|**Complexité**|Commandes longues et répétitives|Configuration déclarative simple|
|**Multi-conteneurs**|Gestion manuelle fastidieuse|Gestion automatique et coordonnée|
|**Réseaux**|Création et liaison manuelles|Création automatique d'un réseau dédié|
|**Volumes**|Spécification dans chaque commande|Définition centralisée réutilisable|
|**Variables d'environnement**|`-e` pour chaque variable|Fichier `.env` ou section `environment`|
|**Dépendances**|Ordre de lancement manuel|Gestion automatique avec `depends_on`|
|**Documentation**|Difficile à documenter|Le fichier YAML est auto-documenté|
|**Partage**|Script shell complexe|Simple fichier YAML|

> [!warning] Attention aux idées reçues Docker Compose n'est **PAS** un orchestrateur de production comme Kubernetes. Il est idéal pour le développement et les déploiements simples, mais pour de la production à grande échelle, d'autres outils sont plus appropriés.

---

## 🔧 Installation

### Vérifier la présence de Docker Compose

Docker Compose v2 est maintenant intégré comme plugin Docker. La commande a évolué :

- **Ancienne version** (v1) : `docker-compose` (avec tiret)
- **Nouvelle version** (v2) : `docker compose` (sans tiret, sous-commande de docker)

Pour vérifier si Docker Compose est déjà installé :

```bash
docker compose version
```

Si la commande fonctionne, Docker Compose est déjà installé ! Sinon, suivez les instructions ci-dessous.

> [!info] Docker Compose v2 Depuis Docker Desktop 3.4.0 (2021), Docker Compose v2 est inclus par défaut. Si vous avez installé Docker récemment, vous avez probablement déjà Compose v2.

### Installation sur Linux

#### 🐧 Option 1 : Via Docker Desktop (Recommandé pour débutants)

1. Téléchargez Docker Desktop pour Linux depuis le site officiel Docker
2. Docker Compose v2 est inclus automatiquement

#### 🛠️ Option 2 : Installation manuelle (Plugin Docker)

Si vous utilisez Docker Engine sans Docker Desktop :

```bash
# 1. Créer le répertoire des plugins Docker s'il n'existe pas
mkdir -p ~/.docker/cli-plugins/

# 2. Télécharger le binaire Docker Compose
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

# 3. Rendre le binaire exécutable
chmod +x ~/.docker/cli-plugins/docker-compose

# 4. Vérifier l'installation
docker compose version
```

> [!tip] Architecture ARM Pour les processeurs ARM (comme Raspberry Pi), remplacez `x86_64` par `aarch64` dans l'URL de téléchargement.

#### 🔄 Option 3 : Via le gestionnaire de paquets (selon votre distribution)

**Ubuntu/Debian :**

```bash
sudo apt update
sudo apt install docker-compose-plugin
```

**Fedora :**

```bash
sudo dnf install docker-compose-plugin
```

**Arch Linux :**

```bash
sudo pacman -S docker-compose
```

### Installation sur macOS

#### 🍎 Option 1 : Docker Desktop (Recommandé)

1. Téléchargez Docker Desktop pour Mac depuis [docker.com](https://www.docker.com/products/docker-desktop)
2. Installez l'application
3. Docker Compose v2 est inclus automatiquement

Docker Desktop pour Mac gère automatiquement Docker Engine et Docker Compose.

#### 🍺 Option 2 : Via Homebrew

Si vous préférez Homebrew et utilisez Docker sans Desktop :

```bash
# Installer Docker
brew install docker

# Installer Docker Compose comme plugin
brew install docker-compose
```

> [!warning] Docker Desktop vs Docker Engine Sur macOS, Docker Desktop est fortement recommandé car il configure automatiquement la VM nécessaire pour exécuter Docker (macOS ne peut pas exécuter de conteneurs Linux nativement).

### Installation sur Windows

#### 🪟 Option 1 : Docker Desktop (Recommandé)

1. Téléchargez Docker Desktop pour Windows depuis [docker.com](https://www.docker.com/products/docker-desktop)
2. Installez l'application (nécessite WSL 2)
3. Docker Compose v2 est inclus automatiquement

**Prérequis :**

- Windows 10 version 2004+ ou Windows 11
- WSL 2 activé
- Virtualisation activée dans le BIOS

#### ⚙️ Configuration WSL 2

Si WSL 2 n'est pas encore installé :

```powershell
# Exécuter dans PowerShell en administrateur
wsl --install
```

Redémarrez votre ordinateur après l'installation.

> [!info] WSL 2 Docker Desktop pour Windows utilise WSL 2 (Windows Subsystem for Linux 2) pour exécuter Docker. C'est la méthode la plus performante et recommandée par Docker.

### Vérification de l'installation

Après l'installation, vérifiez que tout fonctionne correctement :

```bash
# Vérifier la version de Docker
docker --version

# Vérifier la version de Docker Compose
docker compose version

# Tester Docker avec un conteneur simple
docker run hello-world
```

**Sortie attendue pour `docker compose version` :**

```
Docker Compose version v2.24.5
```

> [!example] Test complet Pour vérifier que Docker Compose fonctionne vraiment, créez un fichier `docker-compose.yml` simple :
> 
> ```yaml
> services:
>   hello:
>     image: hello-world
> ```
> 
> Puis exécutez :
> 
> ```bash
> docker compose up
> ```
> 
> Vous devriez voir le message de bienvenue de Docker.

#### 🔍 Diagnostic en cas de problème

|Problème|Solution|
|---|---|
|`docker: command not found`|Docker n'est pas installé ou pas dans le PATH|
|`docker compose: command not found`|Compose v2 non installé, essayez `docker-compose` (v1)|
|Permission denied|Ajoutez votre utilisateur au groupe docker : `sudo usermod -aG docker $USER` puis déconnectez/reconnectez-vous|
|Cannot connect to Docker daemon|Docker Engine n'est pas démarré : `sudo systemctl start docker` (Linux)|

> [!warning] Groupe Docker (Linux) Sur Linux, après avoir ajouté votre utilisateur au groupe docker, vous devez vous déconnecter et vous reconnecter (ou redémarrer) pour que les changements prennent effet.

---

## 🎓 Pièges courants et bonnes pratiques

### ⚠️ Pièges à éviter

**1. Confusion entre v1 et v2**

- **v1** : `docker-compose up` (commande séparée)
- **v2** : `docker compose up` (plugin Docker)

> [!tip] Astuce Créez un alias si vous utilisez souvent l'ancienne syntaxe : `alias docker-compose='docker compose'`

**2. Oublier de vérifier les prérequis**

- Docker doit être installé **avant** Docker Compose
- Sur Windows/Mac, Docker Desktop inclut déjà Compose

**3. Droits insuffisants (Linux)**

- L'utilisateur doit appartenir au groupe `docker`
- Redémarrage nécessaire après ajout au groupe

### ✅ Bonnes pratiques

**Installation**

- Privilégiez Docker Desktop pour la facilité d'utilisation
- Sur Linux serveur, utilisez le plugin Docker Compose officiel
- Gardez Docker et Compose à jour régulièrement

**Vérification**

- Testez toujours avec `docker compose version` après installation
- Vérifiez que `docker` et `docker compose` fonctionnent tous les deux

**Documentation**

- Notez la version utilisée dans votre README
- Documentez les prérequis d'installation pour votre équipe

---

## 🔑 Points clés à retenir

- ✅ Docker Compose simplifie la gestion d'applications multi-conteneurs
- ✅ Configuration déclarative dans un fichier YAML
- ✅ Idéal pour le développement, les tests, et les démos
- ✅ Version v2 intégrée comme plugin Docker (`docker compose`)
- ✅ Inclus par défaut dans Docker Desktop
- ✅ Installation simple sur toutes les plateformes
- ✅ Vérification : `docker compose version`

---

_Maintenant que Docker Compose est installé et que vous comprenez son utilité, vous êtes prêt à créer vos premiers fichiers de configuration et à orchestrer vos applications !_