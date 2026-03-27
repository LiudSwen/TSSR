

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

Le **daemon Docker** (dockerd) est le processus serveur qui gère tous les conteneurs, images, réseaux et volumes sur votre système. Sa configuration est essentielle pour optimiser les performances, la sécurité et le comportement de Docker dans votre environnement.

> [!info] Pourquoi configurer le daemon ?
> 
> - Adapter Docker à votre infrastructure (stockage, réseau, logs)
> - Améliorer les performances et la sécurité
> - Centraliser la configuration plutôt que d'utiliser des flags à chaque commande
> - Assurer une configuration cohérente après les redémarrages

---

## Le fichier daemon.json

### 📍 Emplacement et structure

Le fichier `daemon.json` est le principal moyen de configurer Docker de manière persistante.

**Emplacement selon l'OS :**

|Système|Chemin|
|---|---|
|Linux|`/etc/docker/daemon.json`|
|Windows|`C:\ProgramData\docker\config\daemon.json`|
|macOS|`~/.docker/daemon.json`|

> [!warning] Création manuelle Ce fichier n'existe pas par défaut. Vous devez le créer manuellement avec les bonnes permissions.

### 🔧 Configuration de base

```bash
# Créer le répertoire si nécessaire
sudo mkdir -p /etc/docker

# Créer le fichier de configuration
sudo nano /etc/docker/daemon.json
```

Exemple de configuration basique :

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
```

> [!tip] Format JSON strict
> 
> - Utilisez toujours des guillemets doubles `""`
> - Pas de virgule après le dernier élément
> - Validez votre JSON avant de redémarrer Docker

### 📚 Options principales du daemon.json

#### Configuration des logs

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",        // Taille max par fichier
    "max-file": "3",          // Nombre de fichiers conservés
    "compress": "true"        // Compression des anciens logs
  }
}
```

> [!info] Drivers de logs disponibles
> 
> - `json-file` : par défaut, logs en JSON
> - `syslog` : envoi vers syslog
> - `journald` : intégration systemd
> - `gelf` : pour Graylog
> - `fluentd` : pour Fluentd
> - `awslogs` : CloudWatch AWS

#### Configuration du stockage

```json
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "data-root": "/var/lib/docker"
}
```

|Option|Description|
|---|---|
|`storage-driver`|Driver de stockage utilisé (overlay2, aufs, devicemapper)|
|`data-root`|Répertoire racine pour les données Docker|
|`storage-opts`|Options spécifiques au driver|

#### Configuration réseau

```json
{
  "bridge": "docker0",
  "bip": "172.17.0.1/16",
  "default-address-pools": [
    {
      "base": "172.80.0.0/16",
      "size": 24
    }
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "mtu": 1500
}
```

> [!example] Explication des options réseau
> 
> - `bridge` : nom de l'interface bridge par défaut
> - `bip` : CIDR du bridge Docker
> - `default-address-pools` : pool d'adresses pour les réseaux personnalisés
> - `dns` : serveurs DNS pour les conteneurs
> - `mtu` : Maximum Transmission Unit

#### Configuration de sécurité

```json
{
  "icc": false,
  "userns-remap": "default",
  "no-new-privileges": true,
  "selinux-enabled": true,
  "live-restore": true
}
```

|Option|Impact|
|---|---|
|`icc`|Inter-Container Communication (false = plus sécurisé)|
|`userns-remap`|Remapping des utilisateurs pour l'isolation|
|`no-new-privileges`|Empêche l'élévation de privilèges|
|`selinux-enabled`|Active SELinux si disponible|
|`live-restore`|Garde les conteneurs actifs lors du redémarrage du daemon|

#### Configuration des registries

```json
{
  "insecure-registries": ["registry.local:5000"],
  "registry-mirrors": ["https://mirror.example.com"],
  "max-concurrent-downloads": 3,
  "max-concurrent-uploads": 5
}
```

> [!warning] Registries non sécurisés N'utilisez `insecure-registries` qu'en développement local. En production, utilisez toujours HTTPS.

#### Configuration des ressources

```json
{
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  },
  "default-shm-size": "64M",
  "userland-proxy": false
}
```

### 🔍 Configuration complète exemple

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "compress": "true"
  },
  "storage-driver": "overlay2",
  "data-root": "/var/lib/docker",
  "dns": ["8.8.8.8", "1.1.1.1"],
  "dns-search": ["example.com"],
  "icc": false,
  "live-restore": true,
  "userland-proxy": false,
  "default-address-pools": [
    {
      "base": "172.80.0.0/16",
      "size": 24
    }
  ],
  "insecure-registries": [],
  "registry-mirrors": [],
  "max-concurrent-downloads": 3,
  "max-concurrent-uploads": 5,
  "debug": false,
  "experimental": false
}
```

### ✅ Validation de la configuration

```bash
# Vérifier la syntaxe JSON
cat /etc/docker/daemon.json | python -m json.tool

# Ou avec jq si installé
jq . /etc/docker/daemon.json

# Vérifier les permissions
ls -l /etc/docker/daemon.json
# Devrait être : -rw-r--r-- root root
```

> [!tip] Permissions recommandées
> 
> ```bash
> sudo chmod 644 /etc/docker/daemon.json
> sudo chown root:root /etc/docker/daemon.json
> ```

---

## Options de démarrage

### 🚀 Modes de démarrage

Il existe plusieurs façons de configurer le daemon Docker :

1. **Via daemon.json** (recommandé) : configuration persistante
2. **Via flags de ligne de commande** : configuration temporaire ou spécifique
3. **Via variables d'environnement** : pour certaines options

> [!warning] Conflit de configuration Si une option est définie à la fois dans `daemon.json` ET en ligne de commande, Docker refusera de démarrer. Choisissez une seule méthode par option.

### 📝 Flags de ligne de commande

Les flags sont utiles pour le débogage ou des configurations ponctuelles :

```bash
# Démarrage avec options
dockerd --log-level debug --storage-driver overlay2

# Avec plusieurs options
dockerd \
  --log-level info \
  --storage-driver overlay2 \
  --data-root /mnt/docker \
  --dns 8.8.8.8 \
  --dns 8.8.4.4
```

### 🔑 Flags principaux

|Flag|Description|Exemple|
|---|---|---|
|`--log-level`|Niveau de logs (debug, info, warn, error, fatal)|`--log-level debug`|
|`--storage-driver`|Driver de stockage|`--storage-driver overlay2`|
|`--data-root`|Répertoire des données|`--data-root /mnt/docker`|
|`--host` ou `-H`|Socket d'écoute|`-H tcp://0.0.0.0:2375`|
|`--tls`|Active TLS|`--tls`|
|`--debug` ou `-D`|Mode debug|`-D`|
|`--pidfile`|Fichier PID|`--pidfile /var/run/docker.pid`|

### 🌐 Configuration de l'accès distant

```bash
# DANGEREUX : accès non sécurisé
dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock

# RECOMMANDÉ : avec TLS
dockerd \
  -H tcp://0.0.0.0:2376 \
  --tlsverify \
  --tlscacert=/path/to/ca.pem \
  --tlscert=/path/to/server-cert.pem \
  --tlskey=/path/to/server-key.pem
```

> [!warning] Sécurité critique N'exposez JAMAIS Docker sur TCP sans TLS en production. Un accès non sécurisé = root complet sur le serveur.

### 🔄 Équivalence daemon.json vs flags

**En daemon.json :**

```json
{
  "debug": true,
  "log-level": "info",
  "storage-driver": "overlay2"
}
```

**En ligne de commande :**

```bash
dockerd --debug --log-level info --storage-driver overlay2
```

> [!tip] Bonnes pratiques
> 
> - Utilisez `daemon.json` pour la configuration permanente
> - Utilisez les flags uniquement pour le débogage temporaire
> - Documentez toute configuration non-standard

---

## Gestion du service systemd

### 🎯 Systemd et Docker

Sur les systèmes Linux modernes, Docker est géré comme un service systemd. Cela permet un contrôle fin du daemon et une intégration avec le système.

### 📂 Fichiers systemd importants

```bash
# Fichier de service principal
/lib/systemd/system/docker.service

# Fichier socket (pour activation à la demande)
/lib/systemd/system/docker.socket

# Configuration custom (override)
/etc/systemd/system/docker.service.d/override.conf
```

### 🔍 Commandes de gestion essentielles

#### Statut et informations

```bash
# Vérifier le statut du service
sudo systemctl status docker

# Afficher les logs récents
sudo journalctl -u docker -f

# Logs depuis le dernier boot
sudo journalctl -u docker -b

# Vérifier si Docker est activé au démarrage
sudo systemctl is-enabled docker

# Vérifier si Docker est actif
sudo systemctl is-active docker
```

#### Contrôle du service

```bash
# Démarrer Docker
sudo systemctl start docker

# Arrêter Docker
sudo systemctl stop docker

# Redémarrer Docker
sudo systemctl restart docker

# Recharger la configuration (sans arrêter)
sudo systemctl reload docker

# Activer au démarrage
sudo systemctl enable docker

# Désactiver au démarrage
sudo systemctl disable docker
```

> [!info] Différence reload vs restart
> 
> - `reload` : recharge la configuration sans couper les connexions (si supporté)
> - `restart` : arrêt complet puis redémarrage, toutes les connexions sont coupées

### ⚙️ Configuration du fichier service

**Contenu par défaut de docker.service :**

```ini
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target docker.socket firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
```

> [!info] Sections importantes
> 
> - `[Unit]` : dépendances et ordre de démarrage
> - `[Service]` : configuration du processus
> - `[Install]` : comportement à l'installation

### 🛠️ Personnaliser la configuration

**Méthode recommandée : créer un fichier override**

```bash
# Créer un répertoire pour les overrides
sudo mkdir -p /etc/systemd/system/docker.service.d

# Créer un fichier de configuration custom
sudo nano /etc/systemd/system/docker.service.d/override.conf
```

**Exemple d'override pour ajouter des options :**

```ini
[Service]
# Vider la directive ExecStart existante
ExecStart=
# Définir la nouvelle commande avec options
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock
```

**Exemple pour configurer un proxy :**

```ini
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:8080"
Environment="HTTPS_PROXY=https://proxy.example.com:8080"
Environment="NO_PROXY=localhost,127.0.0.1,::1"
```

**Exemple pour limiter les ressources :**

```ini
[Service]
CPUQuota=200%
MemoryLimit=4G
```

> [!warning] Attention aux modifications Modifier directement `/lib/systemd/system/docker.service` n'est pas recommandé car le fichier sera écrasé lors des mises à jour. Utilisez toujours les overrides.

### 🔄 Appliquer les modifications

Après toute modification de la configuration systemd :

```bash
# 1. Recharger les fichiers de configuration systemd
sudo systemctl daemon-reload

# 2. Redémarrer Docker
sudo systemctl restart docker

# 3. Vérifier le statut
sudo systemctl status docker
```

### 📊 Diagnostics et débogage

#### Vérifier la configuration chargée

```bash
# Afficher la configuration complète du service
sudo systemctl show docker

# Afficher uniquement certaines propriétés
sudo systemctl show docker -p ExecStart -p Environment

# Afficher les overrides actifs
sudo systemctl cat docker
```

#### Analyser les logs

```bash
# Logs en temps réel
sudo journalctl -u docker -f

# Logs avec priorité (erreurs seulement)
sudo journalctl -u docker -p err

# Logs depuis une date
sudo journalctl -u docker --since "2024-01-01"

# Logs depuis X minutes
sudo journalctl -u docker --since "10 minutes ago"

# Format détaillé avec toutes les métadonnées
sudo journalctl -u docker -o verbose

# Exporter les logs
sudo journalctl -u docker > docker-logs.txt
```

> [!tip] Options journalctl utiles
> 
> - `-f` : follow (temps réel)
> - `-n 100` : afficher les 100 dernières lignes
> - `-r` : ordre inverse (plus récent en premier)
> - `--no-pager` : sortie brute sans pagination

#### Problèmes de démarrage

```bash
# Vérifier les erreurs de démarrage
sudo systemctl status docker -l

# Analyser les échecs
sudo systemctl list-units --failed

# Réinitialiser les compteurs d'échec
sudo systemctl reset-failed docker

# Tester le démarrage en mode debug
sudo dockerd --debug
```

### 🔐 Configuration de sécurité systemd

**Renforcement de la sécurité :**

```ini
[Service]
# Isolation du système de fichiers
ProtectSystem=full
ProtectHome=true
ReadOnlyPaths=/
ReadWritePaths=/var/lib/docker

# Isolation réseau et IPC
PrivateNetwork=false
PrivateIPC=true

# Restrictions d'accès
NoNewPrivileges=true
RestrictRealtime=true
RestrictSUIDSGID=true

# Limites de ressources
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
```

> [!warning] Impact des restrictions Certaines restrictions peuvent empêcher Docker de fonctionner correctement. Testez toujours après modification.

### 📈 Gestion des ressources via systemd

**Limiter CPU et mémoire du daemon :**

```ini
[Service]
# Limiter à 50% CPU max
CPUQuota=50%

# Limiter la mémoire à 2GB
MemoryLimit=2G
MemoryHigh=1.5G

# Limiter l'I/O
IOWeight=500
```

**Vérifier l'utilisation :**

```bash
# Statistiques du service
sudo systemctl status docker

# Utilisation détaillée via cgroups
sudo systemd-cgtop -m

# Informations sur les ressources
cat /sys/fs/cgroup/system.slice/docker.service/memory.current
```

### 🔄 Redémarrage automatique

Configuration du comportement de redémarrage :

```ini
[Service]
# Redémarrer toujours
Restart=always

# Délai entre redémarrages
RestartSec=5

# Limiter les redémarrages (3 tentatives en 60s)
StartLimitBurst=3
StartLimitInterval=60s
```

|Valeur de Restart|Comportement|
|---|---|
|`no`|Jamais redémarrer|
|`always`|Toujours redémarrer|
|`on-success`|Seulement si sortie normale|
|`on-failure`|Seulement si erreur|
|`on-abnormal`|Seulement si sortie anormale|

### 🎛️ Variables d'environnement

Définir des variables pour Docker via systemd :

```ini
[Service]
Environment="DOCKER_OPTS=--log-level=debug"
Environment="HTTP_PROXY=http://proxy:8080"
EnvironmentFile=/etc/default/docker
```

**Fichier /etc/default/docker :**

```bash
# Options Docker
DOCKER_OPTS="--log-level=info"

# Configuration proxy
HTTP_PROXY="http://proxy.example.com:8080"
HTTPS_PROXY="https://proxy.example.com:8080"
NO_PROXY="localhost,127.0.0.1"
```

### 🔍 Commandes avancées

```bash
# Afficher l'arborescence des processus Docker
sudo systemctl status docker --no-pager -l

# Vérifier les dépendances
sudo systemctl list-dependencies docker

# Masquer le service (empêcher tout démarrage)
sudo systemctl mask docker

# Démasquer
sudo systemctl unmask docker

# Recharger sans redémarrer (si disponible)
sudo systemctl reload-or-restart docker
```

---

## 🎯 Pièges courants et solutions

### ❌ Conflit daemon.json vs flags

**Problème :**

```bash
# Erreur au démarrage
unable to configure the Docker daemon with file /etc/docker/daemon.json: 
the following directives are specified both as a flag and in the configuration file: 
log-level
```

**Solution :** Choisir une seule source de configuration par option.

### ❌ JSON invalide

**Problème :** Docker refuse de démarrer après modification de daemon.json

**Solution :**

```bash
# Valider le JSON
python -m json.tool /etc/docker/daemon.json

# Vérifier les logs
sudo journalctl -u docker -n 50
```

### ❌ Permissions incorrectes

**Problème :** Le daemon.json n'est pas lu

**Solution :**

```bash
sudo chmod 644 /etc/docker/daemon.json
sudo chown root:root /etc/docker/daemon.json
```

### ❌ Modifications non prises en compte

**Problème :** Les changements ne s'appliquent pas

**Solution :**

```bash
# Toujours recharger systemd ET redémarrer Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# Vérifier la config chargée
docker info | grep -i "log\|storage"
```

---

## 📌 Bonnes pratiques

> [!tip] Configuration recommandée
> 
> 1. **Utilisez daemon.json** pour toute configuration persistante
> 2. **Créez des backups** avant modification
> 3. **Validez le JSON** avant de redémarrer
> 4. **Testez en dev** avant production
> 5. **Documentez** vos choix de configuration

> [!tip] Gestion du service
> 
> 6. **Activez Docker au démarrage** sauf besoin spécifique
> 7. **Utilisez les overrides systemd** plutôt que de modifier le service principal
> 8. **Surveillez les logs** régulièrement avec journalctl
> 9. **Limitez les ressources** si Docker partage le serveur
> 10. **Configurez le restart automatique** pour la production

> [!tip] Sécurité
> 
> 11. **N'exposez jamais** Docker sur TCP sans TLS
> 12. **Limitez ICC** (Inter-Container Communication) si possible
> 13. **Activez userns-remap** pour l'isolation
> 14. **Configurez live-restore** pour minimiser l'impact des redémarrages
> 15. **Auditez** régulièrement votre configuration

---

## 🔧 Commandes de référence rapide

```bash
# Configuration
sudo nano /etc/docker/daemon.json
sudo systemctl daemon-reload

# Gestion du service
sudo systemctl status docker
sudo systemctl restart docker
sudo systemctl enable docker

# Diagnostics
sudo journalctl -u docker -f
docker info
docker version

# Validation
python -m json.tool /etc/docker/daemon.json
sudo systemctl cat docker
```

---

## 🎯 Pièges courants et solutions

### ❌ Conflit daemon.json vs flags

**Problème :**

```bash
# Erreur au démarrage
unable to configure the Docker daemon with file /etc/docker/daemon.json: 
the following directives are specified both as a flag and in the configuration file: 
log-level
```

**Solution :** Choisir une seule source de configuration par option. Soit vous configurez dans `daemon.json`, soit via les flags systemd, mais pas les deux.

```bash
# Vérifier les flags dans le service systemd
sudo systemctl cat docker | grep ExecStart

# Supprimer les flags redondants ou les options de daemon.json
```

---

### ❌ JSON invalide

**Problème :** Docker refuse de démarrer après modification de daemon.json

**Erreurs courantes :**

- Virgule en trop à la fin
- Guillemets simples au lieu de doubles
- Commentaires dans le JSON (non supportés)

**Solution :**

```bash
# Valider le JSON avant de redémarrer
python -m json.tool /etc/docker/daemon.json

# Ou avec jq
jq . /etc/docker/daemon.json

# Si erreur, vérifier les logs
sudo journalctl -u docker -n 50 --no-pager
```

**Backup avant modification :**

```bash
sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup
```

---

### ❌ Permissions incorrectes

**Problème :** Le daemon.json n'est pas lu ou Docker refuse de démarrer

**Solution :**

```bash
# Vérifier les permissions actuelles
ls -l /etc/docker/daemon.json

# Corriger les permissions (lecture pour tous, écriture pour root)
sudo chmod 644 /etc/docker/daemon.json
sudo chown root:root /etc/docker/daemon.json
```

---

### ❌ Modifications non prises en compte

**Problème :** Les changements dans daemon.json ne s'appliquent pas

**Solution complète :**

```bash
# 1. Valider le JSON
python -m json.tool /etc/docker/daemon.json

# 2. Recharger systemd (si vous avez modifié les overrides)
sudo systemctl daemon-reload

# 3. Redémarrer Docker
sudo systemctl restart docker

# 4. Vérifier que la config est appliquée
docker info | grep -i "storage driver"
docker info | grep -i "logging driver"

# 5. Vérifier les logs en cas de problème
sudo journalctl -u docker -n 100 --no-pager
```

---

### ❌ Docker ne démarre plus après modification

**Problème :** Le service échoue au démarrage

**Diagnostic et résolution :**

```bash
# 1. Vérifier le statut et l'erreur
sudo systemctl status docker -l

# 2. Voir les logs détaillés
sudo journalctl -u docker -n 100 --no-pager

# 3. Restaurer la config précédente
sudo mv /etc/docker/daemon.json.backup /etc/docker/daemon.json

# 4. Redémarrer
sudo systemctl restart docker

# 5. Si ça ne marche toujours pas, vider le fichier
sudo rm /etc/docker/daemon.json
sudo systemctl restart docker
```

---

### ❌ Conflit de driver de stockage

**Problème :** Erreur lors du changement de `storage-driver`

```
Error starting daemon: error initializing graphdriver: 
driver not supported
```

**Solution :**

```bash
# 1. Vérifier les drivers supportés
docker info | grep "Storage Driver"

# 2. Si vous devez changer de driver, sauvegarder vos données
docker save $(docker images -q) -o all-images.tar

# 3. Arrêter Docker et nettoyer
sudo systemctl stop docker
sudo rm -rf /var/lib/docker/*

# 4. Configurer le nouveau driver
sudo nano /etc/docker/daemon.json
# Ajouter: "storage-driver": "overlay2"

# 5. Redémarrer
sudo systemctl start docker

# 6. Restaurer les images si nécessaire
docker load -i all-images.tar
```

> [!warning] Changement de storage-driver Changer le driver de stockage efface toutes les images, conteneurs et volumes ! Sauvegardez tout d'abord.

---

### ❌ Problèmes de DNS dans les conteneurs

**Problème :** Les conteneurs ne peuvent pas résoudre les noms de domaine

**Solution :**

```bash
# Ajouter des DNS dans daemon.json
sudo nano /etc/docker/daemon.json
```

```json
{
  "dns": ["8.8.8.8", "8.8.4.4", "1.1.1.1"],
  "dns-search": ["example.com"]
}
```

```bash
# Redémarrer Docker
sudo systemctl restart docker

# Tester dans un conteneur
docker run --rm alpine ping -c 2 google.com
```

---

### ❌ Logs qui saturent le disque

**Problème :** Les logs Docker remplissent l'espace disque

**Solution immédiate :**

```bash
# Vérifier la taille des logs
du -sh /var/lib/docker/containers/*/*-json.log

# Nettoyer manuellement (ARRÊTER les conteneurs d'abord)
truncate -s 0 /var/lib/docker/containers/*/*-json.log
```

**Solution permanente dans daemon.json :**

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "compress": "true"
  }
}
```

> [!tip] Nettoyage automatique Avec cette config, chaque conteneur garde au max 30 MB de logs (10m × 3 fichiers)

---

### ❌ Service systemd qui ne redémarre pas automatiquement

**Problème :** Docker ne redémarre pas après un crash

**Solution :**

```bash
# Créer un override
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo nano /etc/systemd/system/docker.service.d/restart.conf
```

```ini
[Service]
Restart=always
RestartSec=5
StartLimitBurst=5
StartLimitInterval=60s
```

```bash
# Appliquer
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

### ❌ Conteneurs qui s'arrêtent lors du redémarrage du daemon

**Problème :** Tous les conteneurs s'arrêtent quand on redémarre Docker

**Solution : Activer live-restore**

```json
{
  "live-restore": true
}
```

```bash
sudo systemctl restart docker
# Les conteneurs continuent de tourner pendant le redémarrage
```

> [!info] Limitation de live-restore Ne fonctionne pas lors d'une mise à jour majeure de Docker ou de changements dans la config réseau

---

## 📌 Bonnes pratiques

### 🎯 Configuration

> [!tip] Gestion du fichier daemon.json
> 
> - **Créez toujours un backup** avant modification
> - **Validez le JSON** avec `python -m json.tool` ou `jq`
> - **Testez en dev** avant d'appliquer en production
> - **Documentez vos choix** dans un commentaire séparé (JSON ne supporte pas les commentaires)
> - **Versionnez** le fichier dans votre système de configuration (Ansible, Git, etc.)

**Exemple de documentation externe :**

```bash
# /etc/docker/daemon.json.doc
# Configuration Docker - Production Web Server
# Dernière modification: 2024-12-25
# Responsable: DevOps Team
#
# Choix techniques:
# - overlay2: meilleure performance pour notre use case
# - logs limités à 10MB: éviter saturation disque
# - live-restore: minimiser downtime lors maintenance
```

---

### 🔐 Sécurité

> [!tip] Durcissement de la configuration
> 
> 1. **N'exposez JAMAIS Docker sur TCP sans TLS**
>     
>     ```json
>     {
>       "hosts": ["unix:///var/run/docker.sock"],
>       "tls": true,
>       "tlsverify": true,
>       "tlscacert": "/path/to/ca.pem",
>       "tlscert": "/path/to/cert.pem",
>       "tlskey": "/path/to/key.pem"
>     }
>     ```
>     
> 2. **Désactivez ICC si non nécessaire**
>     
>     ```json
>     { "icc": false }
>     ```
>     
> 3. **Activez userns-remap**
>     
>     ```json
>     { "userns-remap": "default" }
>     ```
>     
> 4. **Limitez les registries non sécurisés**
>     
>     ```json
>     { "insecure-registries": [] }
>     ```
>     
> 5. **Activez l'audit logging**
>     
>     ```json
>     {
>       "log-driver": "json-file",
>       "log-opts": {
>         "max-size": "10m",
>         "max-file": "5",
>         "labels": "production"
>       }
>     }
>     ```
>     

---

### ⚙️ Performance

> [!tip] Optimisation des ressources
> 
> **Pour les environnements avec beaucoup de conteneurs :**
> 
> ```json
> {
>   "userland-proxy": false,
>   "max-concurrent-downloads": 6,
>   "max-concurrent-uploads": 10,
>   "default-shm-size": "128M"
> }
> ```
> 
> **Pour les environnements avec stockage limité :**
> 
> ```json
> {
>   "storage-driver": "overlay2",
>   "storage-opts": [
>     "overlay2.override_kernel_check=true"
>   ],
>   "log-opts": {
>     "max-size": "5m",
>     "max-file": "2"
>   }
> }
> ```
> 
> **Pour les environnements réseau complexes :**
> 
> ```json
> {
>   "mtu": 1450,
>   "default-address-pools": [
>     {
>       "base": "172.80.0.0/16",
>       "size": 24
>     }
>   ]
> }
> ```

---

### 🔄 Gestion du service systemd

> [!tip] Administration quotidienne
> 
> **Commandes essentielles à connaître :**
> 
> ```bash
> # Vérification rapide
> sudo systemctl status docker
> 
> # Logs en temps réel
> sudo journalctl -u docker -f
> 
> # Redémarrage propre
> sudo systemctl daemon-reload
> sudo systemctl restart docker
> 
> # Vérification post-redémarrage
> docker ps
> docker info
> ```
> 
> **Monitoring continu :**
> 
> ```bash
> # Créer un script de monitoring
> cat > /usr/local/bin/docker-health-check.sh << 'EOF'
> #!/bin/bash
> if ! systemctl is-active --quiet docker; then
>   echo "Docker is down! Attempting restart..."
>   systemctl restart docker
>   # Envoyer une alerte (mail, slack, etc.)
> fi
> EOF
> 
> chmod +x /usr/local/bin/docker-health-check.sh
> 
> # Ajouter dans crontab
> */5 * * * * /usr/local/bin/docker-health-check.sh
> ```

---

### 📊 Maintenance

> [!tip] Routine de maintenance
> 
> **Hebdomadaire :**
> 
> ```bash
> # Vérifier l'espace disque
> df -h /var/lib/docker
> 
> # Vérifier les logs
> sudo journalctl -u docker --since "7 days ago" | grep -i error
> 
> # Nettoyer les ressources inutilisées
> docker system prune -a --volumes -f
> ```
> 
> **Mensuel :**
> 
> ```bash
> # Backup de la configuration
> sudo cp /etc/docker/daemon.json /backup/daemon.json.$(date +%Y%m%d)
> sudo cp -r /etc/systemd/system/docker.service.d /backup/
> 
> # Vérifier les mises à jour Docker
> apt-cache policy docker-ce
> 
> # Analyser les performances
> docker info
> docker stats --no-stream
> ```
> 
> **Avant chaque modification critique :**
> 
> ```bash
> # Backup complet
> docker save $(docker images -q) -o /backup/images-$(date +%Y%m%d).tar
> docker ps -a --format "{{.Names}}" | xargs -I {} docker export {} -o /backup/{}.tar
> 
> # Documenter le changement
> echo "$(date): Modification de daemon.json - raison: xxx" >> /var/log/docker-changes.log
> ```

---

## 🔧 Commandes de référence rapide

### Configuration du daemon

```bash
# Éditer la configuration
sudo nano /etc/docker/daemon.json

# Valider le JSON
python -m json.tool /etc/docker/daemon.json

# Backup avant modification
sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup

# Appliquer les changements
sudo systemctl daemon-reload
sudo systemctl restart docker

# Vérifier la configuration chargée
docker info
```

---

### Gestion du service systemd

```bash
# Statut et informations
sudo systemctl status docker
sudo systemctl is-enabled docker
sudo systemctl is-active docker

# Contrôle du service
sudo systemctl start docker
sudo systemctl stop docker
sudo systemctl restart docker
sudo systemctl enable docker
sudo systemctl disable docker

# Logs et diagnostics
sudo journalctl -u docker -f
sudo journalctl -u docker --since "1 hour ago"
sudo journalctl -u docker -p err
```

---

### Configuration avancée systemd

```bash
# Créer un override
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo nano /etc/systemd/system/docker.service.d/override.conf

# Voir la configuration complète
sudo systemctl cat docker

# Voir uniquement les overrides
ls -la /etc/systemd/system/docker.service.d/

# Supprimer les overrides
sudo rm -rf /etc/systemd/system/docker.service.d/
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

### Diagnostics

```bash
# Vérifier la configuration chargée
docker info | grep -i "storage\|log"

# Analyser les erreurs
sudo journalctl -u docker -p err --no-pager

# Tester le daemon en mode debug
sudo dockerd --debug

# Vérifier les permissions
ls -la /etc/docker/daemon.json
ls -la /var/run/docker.sock

# Analyser les ressources
sudo systemd-cgtop -m
sudo systemctl show docker -p CPUQuota -p MemoryLimit
```

---

## 💡 Astuces pro

### 🎨 Template de configuration pour différents environnements

**Développement :**

```json
{
  "debug": true,
  "log-level": "debug",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "5"
  },
  "storage-driver": "overlay2",
  "insecure-registries": ["registry.local:5000"]
}
```

**Production :**

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "compress": "true"
  },
  "storage-driver": "overlay2",
  "icc": false,
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true,
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
```

---

### 🔍 Script de validation automatique

```bash
#!/bin/bash
# validate-docker-config.sh

CONFIG="/etc/docker/daemon.json"

echo "🔍 Validation de la configuration Docker..."

# Vérifier que le fichier existe
if [ ! -f "$CONFIG" ]; then
    echo "❌ Fichier $CONFIG non trouvé"
    exit 1
fi

# Vérifier les permissions
PERMS=$(stat -c %a "$CONFIG")
if [ "$PERMS" != "644" ]; then
    echo "⚠️  Permissions incorrectes: $PERMS (attendu: 644)"
fi

# Valider le JSON
if python -m json.tool "$CONFIG" > /dev/null 2>&1; then
    echo "✅ JSON valide"
else
    echo "❌ JSON invalide"
    python -m json.tool "$CONFIG"
    exit 1
fi

# Créer un backup
BACKUP="${CONFIG}.backup-$(date +%Y%m%d-%H%M%S)"
cp "$CONFIG" "$BACKUP"
echo "📦 Backup créé: $BACKUP"

# Tester le redémarrage (dry-run)
echo "🧪 Test de la configuration..."
sudo dockerd --validate --config-file="$CONFIG" 2>&1

echo "✨ Validation terminée"
```

---

### 🚀 Migration rapide vers une nouvelle configuration

```bash
#!/bin/bash
# migrate-docker-config.sh

OLD_CONFIG="/etc/docker/daemon.json"
NEW_CONFIG="/tmp/daemon.json.new"

echo "📋 Migration de la configuration Docker"

# Backup
sudo cp "$OLD_CONFIG" "${OLD_CONFIG}.pre-migration-$(date +%Y%m%d)"

# Appliquer la nouvelle config
sudo cp "$NEW_CONFIG" "$OLD_CONFIG"

# Valider
if python -m json.tool "$OLD_CONFIG" > /dev/null 2>&1; then
    echo "✅ Nouvelle configuration valide"
    
    # Redémarrer
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    
    # Vérifier
    if sudo systemctl is-active --quiet docker; then
        echo "✅ Docker redémarré avec succès"
        docker info | grep -i "storage\|log"
    else
        echo "❌ Échec du redémarrage, restauration..."
        sudo cp "${OLD_CONFIG}.pre-migration-$(date +%Y%m%d)" "$OLD_CONFIG"
        sudo systemctl restart docker
    fi
else
    echo "❌ Configuration invalide, annulation"
    exit 1
fi
```

---

### 🎯 Configuration multi-environnement avec symlinks

```bash
# Structure de configuration
/etc/docker/
├── daemon.json -> daemon.json.prod
├── daemon.json.dev
├── daemon.json.staging
└── daemon.json.prod

# Changer d'environnement
sudo ln -sf /etc/docker/daemon.json.dev /etc/docker/daemon.json
sudo systemctl restart docker
```

---

### 📊 Dashboard de monitoring simple

```bash
#!/bin/bash
# docker-dashboard.sh

clear
echo "🐳 Docker Dashboard"
echo "=================="
echo ""

echo "📌 Service Status:"
systemctl status docker --no-pager | head -n 3
echo ""

echo "💾 Disk Usage:"
df -h /var/lib/docker | tail -n 1
echo ""

echo "📦 Resources:"
docker system df
echo ""

echo "🔄 Running Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
echo ""

echo "📝 Recent Logs (last 5 lines):"
journalctl -u docker -n 5 --no-pager
```

---

## 🎓 Récapitulatif

### Ce que vous devez retenir

1. **daemon.json** est la méthode recommandée pour configurer Docker de manière persistante
2. **Systemd** gère le cycle de vie du service Docker sur Linux moderne
3. **Toujours valider** le JSON avant de redémarrer le daemon
4. **Ne mélangez pas** les flags de ligne de commande et daemon.json pour la même option
5. **Utilisez les overrides** systemd plutôt que de modifier le fichier service principal
6. **Activez live-restore** en production pour minimiser l'impact des redémarrages
7. **Limitez les logs** pour éviter de saturer le disque
8. **Sécurisez toujours** l'accès distant avec TLS

---

### Checklist de configuration sécurisée

- [ ] daemon.json existe avec permissions 644
- [ ] JSON validé et syntaxiquement correct
- [ ] Logs limités en taille (max-size + max-file)
- [ ] Storage driver approprié (overlay2 recommandé)
- [ ] live-restore activé
- [ ] icc désactivé si isolation requise
- [ ] Pas d'insecure-registries en production
- [ ] Service activé au démarrage (systemctl enable)
- [ ] Restart automatique configuré
- [ ] Monitoring et alertes en place

---

**🎉 Vous maîtrisez maintenant la configuration du daemon Docker et sa gestion via systemd !**