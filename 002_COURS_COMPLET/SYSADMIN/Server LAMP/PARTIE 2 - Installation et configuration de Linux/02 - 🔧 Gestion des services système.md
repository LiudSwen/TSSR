

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

## Introduction à la gestion des services

Dans un environnement serveur Linux, la **gestion des services** est cruciale pour assurer le bon fonctionnement de votre infrastructure. Un service (aussi appelé daemon) est un processus qui s'exécute en arrière-plan et fournit des fonctionnalités spécifiques : serveur web (Apache), base de données (MySQL/MariaDB), serveur SSH, etc.

> [!info] Pourquoi c'est important ? Pour un serveur LAMP, vous devez être capable de :
> 
> - Démarrer et arrêter Apache, MySQL/MariaDB
> - Vérifier l'état de santé de ces services
> - Configurer leur démarrage automatique au boot
> - Diagnostiquer les problèmes rapidement

---

## Systemd : principes de base

### Qu'est-ce que systemd ?

**Systemd** est le système d'initialisation (init system) et gestionnaire de services par défaut sur la plupart des distributions Linux modernes (Ubuntu 16.04+, Debian 8+, CentOS 7+, Fedora, Arch Linux, etc.).

Il remplace l'ancien système SysVinit et offre :

- ✅ Démarrage parallélisé des services (boot plus rapide)
- ✅ Gestion unifiée des services, montages, timers, etc.
- ✅ Système de dépendances entre services
- ✅ Journalisation centralisée avec journald
- ✅ Surveillance et redémarrage automatique des services

> [!warning] Attention Systemd est controversé dans la communauté Linux (complexité, mono-application), mais c'est aujourd'hui le standard de facto. Il est essentiel de le maîtriser pour administrer un serveur moderne.

### Architecture de systemd

Systemd fonctionne selon un modèle de **units** (unités). Chaque unit représente une ressource système :

|Type d'unit|Extension|Description|Exemple|
|---|---|---|---|
|Service|`.service`|Service/daemon système|`apache2.service`, `mysql.service`|
|Socket|`.socket`|Socket d'écoute réseau ou IPC|`docker.socket`|
|Target|`.target`|Groupe d'units (point de synchronisation)|`multi-user.target`|
|Mount|`.mount`|Point de montage filesystem|`home.mount`|
|Timer|`.timer`|Planification de tâches (comme cron)|`backup.timer`|
|Device|`.device`|Périphérique matériel|`dev-sda.device`|

> [!info] Pour un serveur LAMP Nous nous concentrerons principalement sur les **services** (`.service`), car c'est ce qui concerne Apache, MySQL/MariaDB et PHP-FPM.

### Les units systemd

Les fichiers de configuration des units sont stockés dans plusieurs emplacements :

```bash
/lib/systemd/system/        # Units fournies par les packages (NE PAS MODIFIER)
/etc/systemd/system/        # Units personnalisées ou overrides (PRIORITAIRE)
/run/systemd/system/        # Units runtime (temporaires)
```

> [!tip] Hiérarchie de priorité `/etc/systemd/system/` > `/run/systemd/system/` > `/lib/systemd/system/`
> 
> Si un même fichier existe dans plusieurs dossiers, celui de `/etc/` sera prioritaire.

**Structure basique d'un fichier `.service` :**

```ini
[Unit]
Description=Mon service personnalisé
After=network.target            # Démarre après le réseau

[Service]
Type=simple                     # Type de processus
ExecStart=/usr/bin/mon-programme
Restart=on-failure              # Redémarre en cas d'échec

[Install]
WantedBy=multi-user.target      # Démarre au boot en mode multi-utilisateur
```

---

## Commandes systemctl essentielles

`systemctl` est l'outil principal pour interagir avec systemd. Voici les commandes indispensables à connaître.

### Gestion de l'état des services

#### 🟢 Démarrer un service

```bash
sudo systemctl start apache2
```

> [!info] Quand l'utiliser ?
> 
> - Après avoir installé un nouveau service
> - Pour relancer un service arrêté manuellement
> - **Attention** : ne démarre PAS automatiquement au prochain boot (voir `enable`)

#### 🔴 Arrêter un service

```bash
sudo systemctl stop apache2
```

> [!warning] Comportement
> 
> - Arrête immédiatement le service
> - Les connexions actives peuvent être brutalement coupées
> - Le service ne redémarrera pas automatiquement (sauf si configuré avec `Restart=always`)

#### 🔄 Redémarrer un service

```bash
sudo systemctl restart apache2
```

> [!info] Cas d'usage
> 
> - Après modification d'un fichier de configuration
> - Pour forcer une réinitialisation complète du service
> - **Inconvénient** : interruption de service (downtime)

#### ♻️ Recharger la configuration (sans interruption)

```bash
sudo systemctl reload apache2
```

> [!tip] Reload vs Restart
> 
> - `reload` : recharge la configuration sans arrêter le service (pas de downtime)
> - `restart` : arrêt complet puis redémarrage (downtime)
> - **Préférez `reload`** quand c'est possible (tous les services ne le supportent pas)

#### 🔁 Reload ou Restart intelligent

```bash
sudo systemctl reload-or-restart apache2
```

> [!tip] Astuce Tente un `reload`, si le service ne le supporte pas, fait un `restart` automatiquement.

### Inspection et diagnostic

#### 📊 Vérifier l'état d'un service

```bash
sudo systemctl status apache2
```

**Exemple de sortie :**

```
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2024-01-15 10:23:45 CET; 2h 15min ago
       Docs: https://httpd.apache.org/docs/2.4/
   Main PID: 1234 (apache2)
      Tasks: 55 (limit: 4915)
     Memory: 45.2M
        CPU: 2.345s
     CGroup: /system.slice/apache2.service
             ├─1234 /usr/sbin/apache2 -k start
             ├─1235 /usr/sbin/apache2 -k start
             └─1236 /usr/sbin/apache2 -k start
```

**Interprétation des informations clés :**

|Champ|Signification|
|---|---|
|`Loaded`|Fichier unit chargé + état d'activation (`enabled`/`disabled`)|
|`Active`|État actuel : `active (running)`, `inactive (dead)`, `failed`|
|`Main PID`|PID du processus principal|
|`Tasks`|Nombre de threads/processus|
|`Memory`|Consommation mémoire|
|`CGroup`|Hiérarchie des processus du service|

> [!tip] Codes couleur
> 
> - 🟢 **Vert** (`active (running)`) : service en cours d'exécution
> - 🔴 **Rouge** (`failed`) : service en erreur
> - ⚪ **Blanc** (`inactive (dead)`) : service arrêté

#### 🔍 Vérifier si un service est actif

```bash
sudo systemctl is-active apache2
# Retourne: active ou inactive
```

```bash
# Utilisation dans un script
if systemctl is-active --quiet apache2; then
    echo "Apache tourne correctement"
else
    echo "Apache est arrêté !"
fi
```

#### ❓ Vérifier si un service a échoué

```bash
sudo systemctl is-failed apache2
# Retourne: active, failed, inactive, unknown
```

#### 📋 Lister tous les services

```bash
# Tous les services
sudo systemctl list-units --type=service

# Services actifs uniquement
sudo systemctl list-units --type=service --state=active

# Services en échec
sudo systemctl list-units --type=service --state=failed
```

> [!tip] Filtrage avec grep
> 
> ```bash
> sudo systemctl list-units --type=service | grep apache
> ```

#### 🔎 Afficher les logs d'un service

```bash
# Logs récents
sudo journalctl -u apache2

# Suivre les logs en temps réel (comme tail -f)
sudo journalctl -u apache2 -f

# Logs depuis le dernier boot
sudo journalctl -u apache2 -b

# Logs des 100 dernières lignes
sudo journalctl -u apache2 -n 100

# Logs avec horodatage précis
sudo journalctl -u apache2 --since "2024-01-15 10:00:00"
sudo journalctl -u apache2 --since "1 hour ago"
sudo journalctl -u apache2 --since today
```

> [!example] Exemple de diagnostic d'erreur
> 
> ```bash
> # Apache ne démarre pas, investigation :
> sudo systemctl status apache2    # Voir l'état général
> sudo journalctl -u apache2 -n 50 # Derniers logs
> sudo apache2ctl configtest       # Tester la configuration Apache
> ```

### Rechargement de configuration

#### 🔄 Recharger les fichiers units

Lorsque vous modifiez un fichier `.service` ou ajoutez une nouvelle unit, systemd doit recharger sa configuration :

```bash
sudo systemctl daemon-reload
```

> [!warning] Important **Toujours** exécuter `daemon-reload` après :
> 
> - Modification d'un fichier `.service` existant
> - Création d'une nouvelle unit dans `/etc/systemd/system/`
> - Suppression d'une unit
> 
> Sans cela, systemd continuera d'utiliser l'ancienne configuration en cache.

**Exemple de workflow :**

```bash
# 1. Modifier le fichier service
sudo nano /etc/systemd/system/mon-service.service

# 2. Recharger systemd
sudo systemctl daemon-reload

# 3. Redémarrer le service pour appliquer les changements
sudo systemctl restart mon-service
```

---

## Activation au démarrage

Un service peut être **actif** (en cours d'exécution) sans être **activé** (démarrage automatique au boot). Ce sont deux notions distinctes.

### Enable et disable

#### ✅ Activer le démarrage automatique

```bash
sudo systemctl enable apache2
```

**Effet :**

- Crée un lien symbolique dans `/etc/systemd/system/`
- Le service démarrera automatiquement au prochain boot
- **N'affecte PAS** l'état actuel (n'a pas besoin de `start`)

> [!info] Scénario typique Après installation d'Apache :
> 
> ```bash
> sudo apt install apache2
> sudo systemctl enable apache2   # Activation au boot
> sudo systemctl start apache2    # Démarrage immédiat
> ```
> 
> Ou en une seule commande :
> 
> ```bash
> sudo systemctl enable --now apache2  # Enable + Start
> ```

#### ❌ Désactiver le démarrage automatique

```bash
sudo systemctl disable apache2
```

**Effet :**

- Supprime le lien symbolique de démarrage
- Le service ne démarrera plus automatiquement au boot
- **N'arrête PAS** le service s'il tourne (utilisez `stop` pour cela)

> [!tip] Disable + Stop en une commande
> 
> ```bash
> sudo systemctl disable --now apache2  # Disable + Stop
> ```

### Masquage de services

Le **masquage** (mask) est une protection renforcée contre le démarrage d'un service.

#### 🚫 Masquer un service

```bash
sudo systemctl mask apache2
```

**Effet :**

- Crée un lien symbolique vers `/dev/null`
- **Empêche totalement** le démarrage du service (même manuel avec `start`)
- Utile pour bloquer définitivement un service indésirable

> [!example] Cas d'usage : empêcher Apache de démarrer
> 
> ```bash
> sudo systemctl mask apache2
> sudo systemctl start apache2
> # Erreur: Failed to start apache2.service: Unit apache2.service is masked.
> ```

#### 🔓 Démasquer un service

```bash
sudo systemctl unmask apache2
```

> [!warning] Mask vs Disable
> 
> - `disable` : empêche le démarrage automatique au boot, mais `start` manuel reste possible
> - `mask` : empêche **tout** démarrage, même manuel
> - **Mask est plus radical** et doit être utilisé avec précaution

### Vérification du statut d'activation

#### 🔍 Vérifier si un service est activé au boot

```bash
sudo systemctl is-enabled apache2
# Retourne: enabled, disabled, masked, static
```

**Valeurs possibles :**

|État|Signification|
|---|---|
|`enabled`|Démarre automatiquement au boot|
|`disabled`|Ne démarre pas au boot (démarrage manuel possible)|
|`masked`|Complètement bloqué (aucun démarrage possible)|
|`static`|Ne peut pas être activé (démarré par dépendance uniquement)|
|`generated`|Unit générée automatiquement par systemd|

#### 📋 Lister les services activés au boot

```bash
# Services activés dans le target actuel
sudo systemctl list-unit-files --type=service --state=enabled

# Tous les services avec leur état d'activation
sudo systemctl list-unit-files --type=service
```

**Exemple de sortie :**

```
UNIT FILE                 STATE           VENDOR PRESET
apache2.service           enabled         enabled
mysql.service             enabled         enabled
ssh.service               enabled         enabled
nginx.service             disabled        disabled
```

---

## Bonnes pratiques

### 🎯 Synthèse des commandes essentielles

```bash
# Gestion de l'état
sudo systemctl start <service>          # Démarrer
sudo systemctl stop <service>           # Arrêter
sudo systemctl restart <service>        # Redémarrer
sudo systemctl reload <service>         # Recharger config

# Activation au boot
sudo systemctl enable <service>         # Activer au boot
sudo systemctl disable <service>        # Désactiver au boot
sudo systemctl enable --now <service>   # Activer + Démarrer

# Diagnostic
sudo systemctl status <service>         # État détaillé
sudo systemctl is-active <service>      # Actif ?
sudo systemctl is-enabled <service>     # Activé au boot ?
sudo journalctl -u <service> -f         # Logs en direct

# Maintenance
sudo systemctl daemon-reload            # Après modif .service
```

### ✅ Workflow recommandé pour un serveur LAMP

**Installation initiale :**

```bash
# Apache
sudo apt install apache2
sudo systemctl enable --now apache2
sudo systemctl status apache2

# MySQL/MariaDB
sudo apt install mariadb-server
sudo systemctl enable --now mariadb
sudo systemctl status mariadb

# PHP (PHP-FPM si utilisé)
sudo apt install php-fpm
sudo systemctl enable --now php8.2-fpm
sudo systemctl status php8.2-fpm
```

**Après modification de configuration :**

```bash
# Apache (tester la config avant)
sudo apache2ctl configtest
sudo systemctl reload apache2    # Pas de downtime

# MySQL (redémarrage nécessaire)
sudo systemctl restart mariadb

# PHP-FPM
sudo systemctl reload php8.2-fpm
```

### ⚠️ Pièges courants à éviter

> [!warning] Erreur #1 : Oublier daemon-reload Après modification d'un fichier `.service`, pensez à :
> 
> ```bash
> sudo systemctl daemon-reload
> ```

> [!warning] Erreur #2 : Confondre enable et start
> 
> - `enable` : démarrage automatique au boot (futur)
> - `start` : démarrage immédiat (maintenant)
> - Il faut souvent les deux !

> [!warning] Erreur #3 : Restart au lieu de Reload Préférez `reload` quand c'est possible (pas de coupure) :
> 
> ```bash
> # Bien
> sudo systemctl reload apache2
> 
> # Moins bien (interruption de service)
> sudo systemctl restart apache2
> ```

> [!warning] Erreur #4 : Ne pas vérifier l'état après une action Toujours vérifier que tout fonctionne :
> 
> ```bash
> sudo systemctl start apache2
> sudo systemctl status apache2  # Vérification
> ```

### 💡 Astuces avancées

**Alias systemctl :**

```bash
# Ajouter dans ~/.bashrc
alias sc='sudo systemctl'
alias scs='sudo systemctl status'
alias scr='sudo systemctl restart'
alias sce='sudo systemctl enable --now'
alias jc='sudo journalctl -u'
```

**Surveillance des services critiques :**

```bash
# Script simple de monitoring
#!/bin/bash
SERVICES=("apache2" "mariadb" "php8.2-fpm")

for service in "${SERVICES[@]}"; do
    if ! systemctl is-active --quiet "$service"; then
        echo "⚠️  $service est arrêté !"
        # Envoyer alerte, redémarrer, etc.
    fi
done
```

**Démarrage conditionnel :**

Créer un service qui ne démarre que si un autre est actif :

```ini
[Unit]
Description=Mon service
After=mariadb.service
Requires=mariadb.service    # Ne démarre que si mariadb tourne

[Service]
ExecStart=/usr/bin/mon-app

[Install]
WantedBy=multi-user.target
```

---

> [!tip] 🎓 Points clés à retenir
> 
> 1. **Systemd** est le gestionnaire de services standard sur Linux moderne
> 2. **`systemctl`** est l'outil principal pour gérer les services
> 3. Distinction **enable** (boot) vs **start** (immédiat)
> 4. Toujours vérifier avec `status` et les logs `journalctl`
> 5. Privilégier `reload` à `restart` quand c'est possible