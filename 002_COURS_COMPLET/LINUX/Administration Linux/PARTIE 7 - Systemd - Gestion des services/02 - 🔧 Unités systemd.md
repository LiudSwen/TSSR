

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

## 🎯 Introduction aux unités systemd {#introduction}

Les **unités** (units) sont les briques fondamentales de systemd. Chaque unité représente une ressource que systemd peut gérer : un service, un point de montage, un socket, un minuteur, etc.

> [!info] Concept clé Une unité systemd est définie par un fichier de configuration qui décrit la ressource et comment systemd doit la gérer. Ces fichiers utilisent une syntaxe INI simple et lisible.

### Pourquoi c'est important ?

- **Uniformisation** : Tous les éléments du système utilisent le même format de configuration
- **Dépendances** : Les unités peuvent dépendre les unes des autres de manière explicite
- **Parallélisation** : systemd peut démarrer plusieurs unités en parallèle selon leurs dépendances
- **Gestion centralisée** : Un seul outil (`systemctl`) pour tout gérer

---

## 🗂️ Types d'unités {#types-dunités}

Systemd supporte plusieurs types d'unités, chacun avec un rôle spécifique. Voici les principaux :

### Types principaux

|Type|Extension|Description|Cas d'usage typique|
|---|---|---|---|
|**service**|`.service`|Gère les processus et démons|Apache, SSH, applications|
|**socket**|`.socket`|Gère les sockets (IPC, réseau)|Activation à la demande|
|**timer**|`.timer`|Planification de tâches|Alternative à cron|
|**mount**|`.mount`|Points de montage de systèmes de fichiers|Montage automatique|
|**target**|`.target`|Groupe d'unités, points de synchronisation|multi-user.target, graphical.target|

### Autres types d'unités

|Type|Extension|Description|
|---|---|---|
|**device**|`.device`|Périphériques matériels|
|**automount**|`.automount`|Montage automatique à la demande|
|**swap**|`.swap`|Partitions ou fichiers swap|
|**path**|`.path`|Surveillance de fichiers/répertoires|
|**slice**|`.slice`|Groupes de ressources (cgroups)|
|**scope**|`.scope`|Groupes de processus externes|

> [!tip] Astuce Pour voir tous les types d'unités chargées sur votre système :
> 
> ```bash
> systemctl list-units --all --type=service
> systemctl list-units --all --type=timer
> ```

### Détail : Service

Le type le plus courant. Gère le cycle de vie d'un processus (démarrage, arrêt, redémarrage).

```bash
# Exemples de services
nginx.service        # Serveur web
sshd.service        # Serveur SSH
postgresql.service  # Base de données
```

### Détail : Socket

Permet l'**activation à la demande** : systemd écoute sur un socket et démarre le service associé uniquement quand une connexion arrive.

```bash
# Exemple : socket SSH
sshd.socket  # Écoute sur le port 22
sshd.service # Démarre quand connexion reçue
```

> [!info] Avantage Économise des ressources en ne démarrant les services que lorsqu'ils sont réellement nécessaires.

### Détail : Timer

Alternative moderne à cron, intégrée à systemd avec des fonctionnalités avancées.

```bash
# Exemple : sauvegarde quotidienne
backup.timer   # Définit le planning
backup.service # Service exécuté par le timer
```

### Détail : Mount

Représente un point de montage défini dans `/etc/fstab` ou créé dynamiquement.

```bash
# Exemple
home.mount       # Point de montage /home
mnt-data.mount   # Point de montage /mnt/data
```

> [!warning] Convention de nommage Le nom du fichier `.mount` doit correspondre au chemin de montage avec les `/` remplacés par des `-`. Exemple : `/mnt/data` → `mnt-data.mount`

### Détail : Target

Un target est un **groupe logique d'unités** qui sert de point de synchronisation. C'est l'équivalent des runlevels de SysVinit.

```bash
# Targets principaux
multi-user.target  # Système multi-utilisateurs (mode texte)
graphical.target   # Interface graphique
rescue.target      # Mode de secours
emergency.target   # Mode d'urgence
```

---

## 📂 Localisation des fichiers unit {#localisation-des-fichiers-unit}

Les fichiers d'unités sont stockés dans plusieurs répertoires, avec une **hiérarchie de priorité**.

### Hiérarchie des répertoires

```bash
/etc/systemd/system/          # Priorité 1 : Configuration locale (admin)
/run/systemd/system/          # Priorité 2 : Configuration volatile (runtime)
/usr/lib/systemd/system/      # Priorité 3 : Configuration système (packages)
/lib/systemd/system/          # Priorité 3 : Lien symbolique vers /usr/lib
```

> [!info] Ordre de priorité systemd recherche les unités dans cet ordre et utilise la **première trouvée**. Cela permet de surcharger facilement les unités système.

### Description détaillée

#### `/etc/systemd/system/`

- **Usage** : Configuration de l'administrateur
- **Contenu** : Unités personnalisées, surcharges, liens symboliques
- **Priorité** : Maximale - écrase tout le reste
- **Persistance** : Survit aux mises à jour

```bash
# Créer ou modifier une unité personnalisée
sudo vim /etc/systemd/system/mon-service.service

# Surcharger une unité existante
sudo systemctl edit nginx.service
```

#### `/run/systemd/system/`

- **Usage** : Unités temporaires créées au runtime
- **Contenu** : Unités générées dynamiquement par systemd
- **Priorité** : Moyenne
- **Persistance** : **Effacé au redémarrage**

> [!warning] Attention Ne jamais placer d'unités importantes ici, car elles seront perdues au redémarrage.

#### `/usr/lib/systemd/system/` ou `/lib/systemd/system/`

- **Usage** : Unités fournies par les packages
- **Contenu** : Configuration par défaut des services installés
- **Priorité** : Faible
- **Persistance** : Peut être écrasé lors des mises à jour

```bash
# Voir l'unité par défaut d'un service
cat /lib/systemd/system/nginx.service
```

> [!tip] Bonne pratique **Ne jamais modifier directement** les fichiers dans `/lib/systemd/system/`. Utilisez plutôt les mécanismes de surcharge dans `/etc/systemd/system/`.

### Mécanisme de surcharge (override)

Pour personnaliser une unité sans modifier l'original :

```bash
# Méthode 1 : Utiliser systemctl edit (recommandé)
sudo systemctl edit nginx.service
# Crée /etc/systemd/system/nginx.service.d/override.conf

# Méthode 2 : Copier et modifier
sudo cp /lib/systemd/system/nginx.service /etc/systemd/system/
sudo vim /etc/systemd/system/nginx.service
```

> [!tip] Avantage de la méthode 1 Avec `systemctl edit`, seules vos modifications sont stockées. Les mises à jour du package peuvent mettre à jour l'unité d'origine sans affecter vos personnalisations.

### Répertoires de surcharge

```bash
# Structure des répertoires .d/
/etc/systemd/system/nginx.service.d/
    └── override.conf      # Vos modifications
    └── custom.conf        # Autres personnalisations
```

Ces fichiers sont **fusionnés** avec l'unité d'origine.

---

## 📖 Lecture d'un fichier unit {#lecture-dun-fichier-unit}

### Afficher le contenu d'une unité

```bash
# Voir l'unité active (avec surcharges appliquées)
systemctl cat nginx.service

# Voir uniquement l'unité d'origine
cat /lib/systemd/system/nginx.service

# Voir la configuration complète fusionnée
systemctl show nginx.service
```

### Structure générale

Tous les fichiers unit suivent le format **INI** avec des sections entre crochets :

```ini
[Section]
Directive1=valeur
Directive2=valeur

[AutreSection]
Directive3=valeur
```

### Sections communes à tous les types d'unités

#### Section `[Unit]`

Contient les **métadonnées** et les **dépendances** de l'unité.

```ini
[Unit]
Description=Description courte du service
Documentation=man:nginx(8) https://nginx.org/en/docs/
After=network.target
Requires=network.target
Wants=postgresql.service
Conflicts=apache2.service
```

**Directives principales :**

|Directive|Description|Exemple|
|---|---|---|
|`Description`|Description lisible|`Description=Serveur web Nginx`|
|`Documentation`|Liens vers la doc|`Documentation=man:nginx(8)`|
|`After`|Démarre après ces unités|`After=network.target`|
|`Before`|Démarre avant ces unités|`Before=multi-user.target`|
|`Requires`|Dépendance stricte|`Requires=postgresql.service`|
|`Wants`|Dépendance souple|`Wants=redis.service`|
|`Conflicts`|Incompatible avec|`Conflicts=apache2.service`|

> [!info] Requires vs Wants
> 
> - **Requires** : Si la dépendance échoue, cette unité échoue aussi (dépendance forte)
> - **Wants** : Si la dépendance échoue, cette unité continue quand même (dépendance faible)

#### Section `[Install]`

Définit le comportement lors de l'**activation** avec `systemctl enable`.

```ini
[Install]
WantedBy=multi-user.target
RequiredBy=graphical.target
Also=nginx-debug.service
Alias=webserver.service
```

**Directives principales :**

|Directive|Description|Action lors de `enable`|
|---|---|---|
|`WantedBy`|Cible qui veut cette unité|Crée un lien dans `.wants/`|
|`RequiredBy`|Cible qui requiert cette unité|Crée un lien dans `.requires/`|
|`Also`|Active également ces unités|Active les unités listées|
|`Alias`|Nom alternatif|Crée un lien symbolique|

> [!example] Exemple pratique
> 
> ```ini
> [Install]
> WantedBy=multi-user.target
> ```
> 
> Cette directive crée le lien :
> 
> ```bash
> /etc/systemd/system/multi-user.target.wants/nginx.service
>   → /lib/systemd/system/nginx.service
> ```

### Commandes utiles pour l'analyse

```bash
# Afficher toutes les propriétés d'une unité
systemctl show nginx.service

# Voir les dépendances
systemctl list-dependencies nginx.service

# Voir quelles unités dépendent de celle-ci
systemctl list-dependencies --reverse nginx.service

# Vérifier la syntaxe d'une unité
systemd-analyze verify /etc/systemd/system/mon-service.service

# Voir le graphe de démarrage
systemd-analyze plot > boot.svg
```

> [!tip] Astuce de débogage La commande `systemd-analyze verify` est très utile pour détecter les erreurs de syntaxe avant de recharger systemd.

---

## ⚙️ Structure d'un fichier .service {#structure-dun-fichier-service}

Un fichier `.service` est le type d'unité le plus utilisé. Il décrit comment démarrer, arrêter et gérer un service.

### Exemple complet et commenté

```ini
[Unit]
# Description courte affichée par systemctl status
Description=Serveur web Nginx haute performance
# Liens vers la documentation
Documentation=man:nginx(8) https://nginx.org/en/docs/

# Démarre après le réseau et le système de fichiers
After=network.target nss-lookup.target
# Souhaite que le réseau soit disponible (dépendance faible)
Wants=network-online.target

# Ne peut pas coexister avec Apache
Conflicts=apache2.service


[Service]
# Type de service (voir détails ci-dessous)
Type=forking

# Fichier PID pour le processus principal
PIDFile=/run/nginx.pid

# Commandes de gestion du service
ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/bin/kill -QUIT $MAINPID

# Politique de redémarrage
Restart=on-failure
RestartSec=5s

# Limites de ressources
TimeoutStartSec=60s
TimeoutStopSec=30s
PrivateTmp=yes

# Utilisateur et groupe d'exécution
User=www-data
Group=www-data


[Install]
# Active ce service quand multi-user.target est atteint
WantedBy=multi-user.target
```

### Section `[Service]` détaillée

C'est la section spécifique aux fichiers `.service` qui définit comment le service s'exécute.

#### Directive `Type=`

Définit comment systemd doit considérer le service démarré.

|Type|Description|Cas d'usage|
|---|---|---|
|`simple`|Processus principal reste en avant-plan|**Défaut**, applications modernes|
|`forking`|Processus se met en arrière-plan (fork)|Démons traditionnels (nginx, Apache)|
|`oneshot`|Exécution unique puis se termine|Scripts de configuration, montage|
|`dbus`|Attend l'acquisition d'un nom D-Bus|Services utilisant D-Bus|
|`notify`|Utilise `sd_notify()` pour signaler le démarrage|Applications systemd-aware|
|`idle`|Attend que les autres services démarrent|Services non urgents|

> [!example] Exemples par type
> 
> ```ini
> # simple : processus reste en premier plan
> Type=simple
> ExecStart=/usr/bin/mon-app --foreground
> 
> # forking : processus daemon classique
> Type=forking
> ExecStart=/usr/sbin/nginx
> PIDFile=/run/nginx.pid
> 
> # oneshot : script d'initialisation
> Type=oneshot
> ExecStart=/usr/local/bin/init-database.sh
> RemainAfterExit=yes
> ```

#### Commandes d'exécution

```ini
# Commande avant le démarrage (test de config, etc.)
ExecStartPre=/usr/sbin/nginx -t

# Commande de démarrage principale
ExecStart=/usr/sbin/nginx -g 'daemon on;'

# Commandes après le démarrage
ExecStartPost=/usr/local/bin/notify-started.sh

# Commande de rechargement (SIGHUP généralement)
ExecReload=/bin/kill -HUP $MAINPID

# Commande d'arrêt
ExecStop=/bin/kill -QUIT $MAINPID

# Commandes après l'arrêt (nettoyage)
ExecStopPost=/usr/local/bin/cleanup.sh
```

> [!warning] Piège courant
> 
> - `ExecStart` n'accepte **qu'une seule commande** (sauf pour `Type=oneshot`)
> - Pour exécuter plusieurs commandes, utilisez un script shell ou `ExecStartPre`/`ExecStartPost`

#### Variables d'environnement disponibles

Dans les commandes `Exec*`, vous pouvez utiliser ces variables :

|Variable|Description|Exemple|
|---|---|---|
|`$MAINPID`|PID du processus principal|`/bin/kill -HUP $MAINPID`|
|`$SERVICE_RESULT`|Résultat du service|`success`, `timeout`, `exit-code`|
|`%n`|Nom complet de l'unité|`nginx.service`|
|`%N`|Nom sans le suffixe|`nginx`|
|`%p`|Préfixe (avant @)|Pour template units|
|`%i`|Instance (après @)|Pour template units|

#### Politique de redémarrage

```ini
# Quand redémarrer le service
Restart=always           # Toujours redémarrer
Restart=on-failure       # Uniquement en cas d'échec (recommandé)
Restart=on-abnormal      # Si tué par signal ou timeout
Restart=on-abort         # Si tué par signal non intercepté
Restart=no               # Jamais (défaut)

# Délai avant redémarrage
RestartSec=5s            # Attendre 5 secondes

# Empêcher les redémarrages en boucle
StartLimitBurst=5        # Max 5 tentatives
StartLimitIntervalSec=10 # Dans une fenêtre de 10 secondes
```

> [!tip] Bonne pratique Utilisez `Restart=on-failure` pour la plupart des services de production. Cela redémarre le service en cas de crash mais pas lors d'un arrêt normal.

#### Timeouts et limites

```ini
# Temps maximum pour le démarrage
TimeoutStartSec=60s      # 60 secondes (défaut: 90s)

# Temps maximum pour l'arrêt gracieux
TimeoutStopSec=30s       # 30 secondes (défaut: 90s)

# Temps pour ExecStartPre et ExecStartPost
TimeoutStartSec=0        # Pas de timeout (attention!)

# Intervalle d'activité (watchdog)
WatchdogSec=30s          # Le service doit signaler toutes les 30s
```

#### Sécurité et isolation

```ini
# Utilisateur et groupe
User=www-data
Group=www-data

# Répertoire temporaire isolé
PrivateTmp=yes           # /tmp et /var/tmp privés

# Isolation du système de fichiers
ProtectSystem=strict     # Système en lecture seule
ProtectHome=yes          # /home inaccessible
ReadWritePaths=/var/www  # Exception: écriture autorisée ici

# Restrictions de capacités
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
NoNewPrivileges=yes      # Empêche l'escalade de privilèges

# Restrictions système
PrivateDevices=yes       # Masque /dev
ProtectKernelTunables=yes
ProtectControlGroups=yes
RestrictRealtime=yes
```

> [!warning] Sécurité importante Ces directives de sécurité sont essentielles pour limiter l'impact d'une compromission du service. Activez-en autant que possible sans casser le fonctionnement.

#### Gestion des ressources

```ini
# Limites mémoire
MemoryLimit=512M         # Maximum 512 Mo
MemoryHigh=400M          # Throttling à 400 Mo

# Limites CPU
CPUQuota=50%             # Maximum 50% d'un cœur
CPUWeight=100            # Priorité CPU (100-10000)

# Limites de processus
TasksMax=100             # Maximum 100 processus/threads

# Limites d'I/O
IOWeight=100             # Priorité I/O (10-1000)
```

#### Gestion des logs

```ini
# Redirection de sortie standard
StandardOutput=journal   # Vers journald (défaut)
StandardOutput=null      # Ignorer
StandardOutput=file:/var/log/app.log  # Vers fichier

# Redirection erreur standard
StandardError=journal
StandardError=inherit    # Même destination que stdout

# Niveau de log dans syslog
SyslogIdentifier=mon-app
SyslogLevel=info
```

### Exemple minimaliste

Pour un service simple, vous pouvez vous contenter de :

```ini
[Unit]
Description=Mon application

[Service]
ExecStart=/usr/local/bin/mon-app

[Install]
WantedBy=multi-user.target
```

> [!info] Valeurs par défaut systemd appliquera automatiquement :
> 
> - `Type=simple`
> - `Restart=no`
> - Timeouts standards de 90 secondes

### Exemple avancé avec Type=notify

Pour une application moderne qui signale son démarrage :

```ini
[Unit]
Description=Application moderne avec notification
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
NotifyAccess=main

ExecStart=/usr/bin/mon-app
Restart=on-failure
RestartSec=10s

# Sécurité renforcée
User=appuser
Group=appuser
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
NoNewPrivileges=yes

# Le service doit envoyer un signal toutes les 30s
WatchdogSec=30s

# Ressources
MemoryLimit=1G
CPUQuota=200%

[Install]
WantedBy=multi-user.target
```

### Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> **1. Mauvais type de service**
> 
> ```ini
> # ❌ Mauvais : nginx fork mais Type=simple
> Type=simple
> ExecStart=/usr/sbin/nginx
> 
> # ✅ Correct
> Type=forking
> PIDFile=/run/nginx.pid
> ExecStart=/usr/sbin/nginx
> ```
> 
> **2. Oublier de recharger systemd**
> 
> ```bash
> # Après modification d'un fichier unit
> sudo systemctl daemon-reload  # OBLIGATOIRE!
> sudo systemctl restart service
> ```
> 
> **3. Chemins relatifs**
> 
> ```ini
> # ❌ Mauvais
> ExecStart=./mon-script.sh
> 
> # ✅ Correct : toujours des chemins absolus
> ExecStart=/usr/local/bin/mon-script.sh
> ```
> 
> **4. Commandes shell complexes**
> 
> ```ini
> # ❌ Mauvais : pipe et redirections ne fonctionnent pas
> ExecStart=/bin/cat /var/log/app.log | grep ERROR
> 
> # ✅ Correct : utiliser un script ou /bin/bash -c
> ExecStart=/bin/bash -c '/bin/cat /var/log/app.log | grep ERROR'
> ```

### Validation et test

```bash
# 1. Vérifier la syntaxe
systemd-analyze verify /etc/systemd/system/mon-service.service

# 2. Recharger systemd
sudo systemctl daemon-reload

# 3. Activer le service
sudo systemctl enable mon-service.service

# 4. Démarrer le service
sudo systemctl start mon-service.service

# 5. Vérifier le statut
systemctl status mon-service.service

# 6. Voir les logs
journalctl -u mon-service.service -f
```

> [!tip] Debug En cas de problème, utilisez :
> 
> ```bash
> # Logs détaillés
> journalctl -xe -u mon-service.service
> 
> # Voir pourquoi un service a échoué
> systemctl status mon-service.service
> 
> # Voir toutes les propriétés
> systemctl show mon-service.service
> ```

---

## 🎓 Récapitulatif

Les unités systemd sont les composants fondamentaux qui permettent de gérer l'ensemble du système :

- **Types variés** : service, socket, timer, mount, target pour couvrir tous les besoins
- **Hiérarchie claire** : `/etc/systemd/system/` surcharge `/lib/systemd/system/`
- **Format simple** : Fichiers INI avec sections `[Unit]`, `[Service]`, `[Install]`
- **Flexibilité** : Nombreuses directives pour configurer précisément chaque aspect

La maîtrise de la structure des fichiers `.service` est essentielle pour administrer efficacement un système Linux moderne.