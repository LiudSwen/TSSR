

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

Le répertoire `/var/log` est le système nerveux central de la journalisation Linux. C'est ici que le système et les applications enregistrent tous leurs événements, erreurs, avertissements et informations de diagnostic. Comprendre son organisation est essentiel pour le diagnostic de problèmes et la surveillance système.

> [!info] Pourquoi /var/log ?
> 
> - `/var` signifie "variable" - données qui changent fréquemment
> - Les logs sont des données volatiles qui évoluent constamment
> - Centralisation : un seul endroit pour tous les journaux du système

> [!warning] Permissions importantes La plupart des fichiers dans `/var/log` nécessitent les privilèges root pour être consultés, car ils peuvent contenir des informations sensibles sur le système.

---

## Organisation du répertoire /var/log

### Structure générale

Le répertoire `/var/log` suit une organisation logique qui sépare les logs par fonction, service ou application :

```bash
# Visualiser la structure de /var/log
ls -lah /var/log

# Arborescence des principaux éléments
tree -L 2 /var/log
```

> [!tip] Navigation rapide Utilisez `ls -lt /var/log | head` pour voir les fichiers de logs les plus récemment modifiés, utile pour identifier les services actifs.

### Fichiers de logs principaux

Voici les fichiers de logs les plus importants que vous rencontrerez :

#### **syslog** ou **messages**

Le journal système principal qui enregistre la majorité des événements système.

```bash
# Consulter les dernières lignes
tail -f /var/log/syslog        # Debian/Ubuntu
tail -f /var/log/messages      # Red Hat/CentOS

# Rechercher des erreurs spécifiques
grep -i "error" /var/log/syslog

# Filtrer par date et heure
grep "Dec 27" /var/log/syslog
```

> [!info] Contenu typique
> 
> - Messages du noyau (kernel)
> - Événements système généraux
> - Messages de nombreux services
> - Alertes de sécurité de base

#### **auth.log** ou **secure**

Journalisation de toutes les activités d'authentification et d'autorisation.

```bash
# Voir les tentatives de connexion SSH
tail -f /var/log/auth.log      # Debian/Ubuntu
tail -f /var/log/secure        # Red Hat/CentOS

# Rechercher les tentatives échouées
grep "Failed password" /var/log/auth.log

# Identifier les connexions réussies
grep "Accepted" /var/log/auth.log
```

> [!warning] Sécurité critique Ce fichier est crucial pour détecter les tentatives d'intrusion. Surveillez-le régulièrement pour repérer des patterns suspects (nombreuses tentatives échouées, connexions à des heures inhabituelles).

#### **kern.log**

Messages spécifiques du noyau Linux.

```bash
# Consulter les messages du noyau
tail -f /var/log/kern.log

# Rechercher des problèmes matériels
grep -i "hardware" /var/log/kern.log

# Identifier des erreurs de drivers
grep -i "driver" /var/log/kern.log
```

> [!example] Cas d'usage Indispensable pour diagnostiquer les problèmes matériels, les erreurs de drivers, les panics kernel et les messages de démarrage système.

#### **dmesg**

Buffer du ring kernel contenant les messages de boot et du noyau.

```bash
# Voir le contenu actuel
dmesg

# Surveiller en temps réel
dmesg -w

# Filtrer par niveau (err, warn, info)
dmesg -l err,warn
```

> [!info] Particularité Le fichier `/var/log/dmesg` contient généralement le dernier boot, tandis que la commande `dmesg` affiche le buffer actuel en mémoire.

#### **boot.log**

Journal des processus de démarrage du système.

```bash
# Consulter le dernier démarrage
less /var/log/boot.log

# Rechercher des services qui ont échoué au boot
grep -i "failed" /var/log/boot.log
```

#### **daemon.log**

Messages des services et démons en arrière-plan.

```bash
# Suivre l'activité des démons
tail -f /var/log/daemon.log

# Vérifier un service spécifique
grep "cron" /var/log/daemon.log
```

#### **cron.log** ou logs cron dans syslog

Activité du planificateur de tâches cron.

```bash
# Sur Debian/Ubuntu avec fichier dédié
tail -f /var/log/cron.log

# Sur Red Hat/CentOS (dans messages ou cron)
grep CRON /var/log/messages

# Voir les tâches exécutées
grep "CMD" /var/log/cron.log
```

#### **mail.log** ou **maillog**

Journaux du système de messagerie.

```bash
# Surveiller l'activité mail
tail -f /var/log/mail.log      # Debian
tail -f /var/log/maillog       # Red Hat

# Rechercher des mails envoyés
grep "status=sent" /var/log/mail.log
```

#### **user.log**

Messages générés par les applications en espace utilisateur.

```bash
# Consulter l'activité utilisateur
tail -f /var/log/user.log
```

#### **Xorg.0.log**

Journal du serveur d'affichage X11.

```bash
# Diagnostiquer les problèmes graphiques
less /var/log/Xorg.0.log

# Rechercher des erreurs
grep "(EE)" /var/log/Xorg.0.log

# Voir les avertissements
grep "(WW)" /var/log/Xorg.0.log
```

> [!example] Utilisation typique Essentiel pour résoudre les problèmes de résolution d'écran, de drivers graphiques ou de configuration multi-écrans.

### Sous-répertoires importants

#### **/var/log/apache2/** ou **/var/log/httpd/**

Logs du serveur web Apache.

```bash
# Structure typique
/var/log/apache2/
├── access.log          # Toutes les requêtes HTTP
├── error.log           # Erreurs du serveur
├── other_vhosts_access.log  # Virtual hosts
└── ssl_access.log      # Accès HTTPS

# Analyser le trafic web
tail -f /var/log/apache2/access.log

# Surveiller les erreurs
tail -f /var/log/apache2/error.log
```

> [!tip] Format des access logs Format typique : `IP - - [date] "méthode URL protocole" code taille "referer" "user-agent"`

#### **/var/log/nginx/**

Logs du serveur web Nginx.

```bash
# Structure
/var/log/nginx/
├── access.log
└── error.log

# Analyser les requêtes
tail -f /var/log/nginx/access.log
```

#### **/var/log/mysql/** ou **/var/log/mariadb/**

Logs de la base de données MySQL/MariaDB.

```bash
# Fichiers principaux
/var/log/mysql/
├── error.log           # Erreurs du serveur
├── mysql.log           # Requêtes générales (si activé)
└── mysql-slow.log      # Requêtes lentes (si activé)

# Identifier les requêtes problématiques
tail -f /var/log/mysql/mysql-slow.log
```

#### **/var/log/postgresql/**

Logs du serveur PostgreSQL.

```bash
# Consulter les logs
tail -f /var/log/postgresql/postgresql-15-main.log
```

#### **/var/log/apt/**

Historique des opérations de gestion de paquets (Debian/Ubuntu).

```bash
# Structure
/var/log/apt/
├── history.log         # Historique des commandes
├── term.log            # Sortie complète des commandes
└── eipp.log.xz         # Détails techniques compressés

# Voir les dernières installations
grep "install" /var/log/apt/history.log

# Identifier les mises à jour récentes
tail -20 /var/log/apt/history.log
```

> [!example] Cas d'usage Utile pour comprendre quand un paquet a été installé, mis à jour ou supprimé, notamment lors de régressions après une mise à jour système.

#### **/var/log/dnf/** ou **/var/log/yum.log**

Logs de gestion de paquets Red Hat/Fedora.

```bash
# Sur systèmes récents avec dnf
less /var/log/dnf.log

# Sur anciens systèmes avec yum
less /var/log/yum.log
```

#### **/var/log/journal/**

Répertoire de stockage pour systemd-journald (logs binaires).

```bash
# Ne pas lire directement, utiliser journalctl
journalctl

# Les fichiers ici sont au format binaire
ls -lh /var/log/journal/
```

> [!warning] Format binaire Ces fichiers ne peuvent pas être lus avec `cat`, `less` ou `grep`. Utilisez toujours `journalctl` pour les consulter.

#### **/var/log/samba/**

Logs du serveur de partage de fichiers Samba.

```bash
# Structure
/var/log/samba/
├── log.nmbd            # Service de noms NetBIOS
├── log.smbd            # Service de partage SMB
└── cores/              # Core dumps éventuels
```

#### **/var/log/cups/**

Logs du système d'impression CUPS.

```bash
# Fichiers principaux
/var/log/cups/
├── access_log          # Accès aux services d'impression
├── error_log           # Erreurs d'impression
└── page_log            # Pages imprimées
```

---

## Différences selon les distributions

Bien que la structure de base de `/var/log` soit similaire, chaque distribution Linux a ses spécificités. Comprendre ces différences est crucial lors du passage d'une distribution à une autre.

### Debian/Ubuntu

Distribution orientée stabilité avec une convention de nommage historique.

#### Fichiers principaux

|Fichier|Description|
|---|---|
|`/var/log/syslog`|Journal système principal|
|`/var/log/auth.log`|Authentifications et autorisations|
|`/var/log/kern.log`|Messages du noyau uniquement|
|`/var/log/daemon.log`|Services et démons|
|`/var/log/user.log`|Messages des applications utilisateurs|
|`/var/log/mail.log`|Serveur de messagerie|
|`/var/log/cron.log`|Tâches planifiées|
|`/var/log/dpkg.log`|Historique des opérations dpkg|
|`/var/log/apt/`|Répertoire pour apt (history.log, term.log)|

#### Particularités

```bash
# Debian/Ubuntu sépare les logs par fonction
ls /var/log/*.log

# La configuration rsyslog est modulaire
ls /etc/rsyslog.d/

# Voir les règles de dispatch des logs
cat /etc/rsyslog.conf
grep "^[^#]" /etc/rsyslog.d/50-default.conf
```

> [!info] Philosophie Debian Séparation claire des logs par type de service, facilitant la lecture et la maintenance. Chaque type de message a son propre fichier dédié.

### Red Hat/CentOS/Fedora

Distribution orientée entreprise avec une approche plus centralisée.

#### Fichiers principaux

|Fichier|Description|
|---|---|
|`/var/log/messages`|Journal système principal (équivalent syslog)|
|`/var/log/secure`|Authentifications et autorisations (équivalent auth.log)|
|`/var/log/maillog`|Serveur de messagerie|
|`/var/log/cron`|Tâches planifiées|
|`/var/log/boot.log`|Messages de démarrage|
|`/var/log/yum.log` ou `/var/log/dnf.log`|Gestionnaire de paquets|
|`/var/log/audit/audit.log`|SELinux et audits de sécurité|

#### Particularités

```bash
# Red Hat centralise plus dans messages
tail -f /var/log/messages

# SELinux a son propre système d'audit
tail -f /var/log/audit/audit.log

# Gestion de paquets historisée
less /var/log/dnf.log
```

> [!warning] SELinux Red Hat/CentOS inclut par défaut SELinux avec des logs d'audit détaillés dans `/var/log/audit/`. C'est une différence majeure avec Debian qui n'active pas SELinux par défaut.

> [!example] Messages centralisés Sur Red Hat, beaucoup de logs qui seraient séparés sur Debian (daemon, user, cron) se retrouvent dans `/var/log/messages`, rendant la recherche plus complexe mais la surveillance plus centralisée.

### Arch Linux

Distribution minimaliste orientée simplicité et modernité.

#### Particularités

Arch Linux adopte une approche résolument moderne :

```bash
# Arch utilise principalement systemd-journald
journalctl

# Moins de fichiers texte traditionnels dans /var/log
ls /var/log/

# Certains logs traditionnels peuvent être absents par défaut
# car tout passe par journald
```

> [!info] Philosophie Arch Arch privilégie `systemd-journald` et le journal binaire. Les logs texte traditionnels dans `/var/log` sont minimaux sauf si explicitement configurés ou générés par des applications tierces.

**Configuration pour logs persistants :**

```bash
# Activer le stockage persistant du journal
sudo mkdir -p /var/log/journal
sudo systemctl restart systemd-journald

# Vérifier
journalctl --disk-usage
```

### Tableau comparatif

|Fonction|Debian/Ubuntu|Red Hat/CentOS|Arch Linux|
|---|---|---|---|
|**Système principal**|`/var/log/syslog`|`/var/log/messages`|journald (journal binaire)|
|**Authentification**|`/var/log/auth.log`|`/var/log/secure`|journald|
|**Messagerie**|`/var/log/mail.log`|`/var/log/maillog`|Selon config MTA|
|**Cron**|`/var/log/cron.log`|`/var/log/cron`|journald|
|**Noyau**|`/var/log/kern.log`|Dans `/var/log/messages`|journald + dmesg|
|**Paquets**|`/var/log/apt/`, `/var/log/dpkg.log`|`/var/log/yum.log`, `/var/log/dnf.log`|`/var/log/pacman.log`|
|**Audit sécurité**|Optionnel (auditd)|`/var/log/audit/audit.log` (SELinux)|Optionnel|
|**Daemon**|`/var/log/daemon.log`|Dans `/var/log/messages`|journald|
|**Système de logs**|rsyslog (texte)|rsyslog (texte)|systemd-journald (binaire)|

> [!tip] Commandes universelles Quel que soit votre distribution, ces commandes fonctionnent partout :
> 
> - `dmesg` pour les messages du noyau
> - `journalctl` pour les logs systemd
> - `last` pour l'historique des connexions
> - `lastb` pour les tentatives de connexion échouées

---

## Astuces pratiques multi-distributions

### Identifier votre distribution

```bash
# Méthode universelle
cat /etc/os-release

# Selon le système
lsb_release -a          # Debian/Ubuntu
cat /etc/redhat-release # Red Hat/CentOS
uname -r                # Version du noyau (toutes distributions)
```

### Commandes de consultation universelles

```bash
# Voir les dernières lignes d'un log (toutes distributions)
tail -n 50 /var/log/syslog  # ou messages selon distro

# Suivre en temps réel
tail -f /var/log/auth.log

# Rechercher dans tous les logs
grep -r "error" /var/log/ 2>/dev/null

# Voir les logs d'un service (systemd, universel)
journalctl -u nom-du-service.service

# Combinaison puissante : journalctl + grep
journalctl -u ssh.service | grep "Failed"
```

### Rotation des logs

Toutes les distributions utilisent `logrotate` pour gérer la rotation automatique :

```bash
# Configuration principale
cat /etc/logrotate.conf

# Configurations spécifiques
ls /etc/logrotate.d/

# Tester la rotation manuellement
sudo logrotate -d /etc/logrotate.conf  # dry-run
sudo logrotate -f /etc/logrotate.conf  # force
```

> [!warning] Gestion de l'espace disque Sans rotation, les logs peuvent remplir `/var` et causer des problèmes système. Vérifiez régulièrement :
> 
> ```bash
> df -h /var
> du -sh /var/log/*
> ```

---

## Bonnes pratiques

### Surveillance régulière

```bash
# Script simple de surveillance quotidienne
#!/bin/bash
echo "=== Erreurs récentes ==="
grep -i "error\|failed\|critical" /var/log/syslog | tail -20

echo "=== Tentatives de connexion échouées ==="
grep "Failed password" /var/log/auth.log | tail -10

echo "=== Utilisation disque /var ==="
df -h /var
```

### Protection et archivage

```bash
# Sauvegarder les logs importants
sudo tar -czf logs-backup-$(date +%Y%m%d).tar.gz /var/log/

# Copier sur un serveur distant
scp logs-backup-*.tar.gz user@backup-server:/backups/logs/
```

> [!tip] Centralisation des logs Pour une infrastructure avec plusieurs serveurs, envisagez une solution de centralisation comme rsyslog en mode serveur, syslog-ng, ou des outils modernes comme Loki, Elasticsearch, ou Graylog.

### Nettoyage sécurisé

```bash
# NE JAMAIS supprimer directement les fichiers de logs actifs
# Utilisez plutôt la troncature pour vider sans supprimer

# Vider un log (conserve le fichier)
sudo truncate -s 0 /var/log/ancien.log

# Ou avec redirection
sudo sh -c "> /var/log/ancien.log"

# Forcer une rotation anticipée
sudo logrotate -f /etc/logrotate.d/rsyslog
```

> [!warning] Pièges courants
> 
> - Ne jamais faire `rm /var/log/syslog` sur un fichier actif : le processus continue d'écrire dans un fichier supprimé, gaspillant de l'espace
> - Toujours utiliser `truncate` ou la rotation de logs pour les fichiers actifs
> - Vérifier les permissions après manipulation (`ls -l /var/log/`)

---

## Pièges courants

> [!warning] Erreurs fréquentes
> 
> **1. Confondre les noms selon les distributions**
> 
> - Chercher `syslog` sur Red Hat (c'est `messages`)
> - Chercher `secure` sur Debian (c'est `auth.log`)
> 
> **2. Oublier les permissions**
> 
> ```bash
> # Erreur : Permission denied
> cat /var/log/auth.log
> # Solution : utiliser sudo
> sudo cat /var/log/auth.log
> ```
> 
> **3. Lire les logs binaires avec des outils texte**
> 
> ```bash
> # ❌ Ne fonctionne pas
> cat /var/log/journal/xxx/system.journal
> # ✅ Correct
> journalctl
> ```
> 
> **4. Ignorer la rotation des logs**
> 
> - Les fichiers `.1`, `.2.gz` contiennent l'historique
> - Pour chercher sur plusieurs jours : `zgrep "pattern" /var/log/syslog*`
> 
> **5. Saturation de /var**
> 
> - Surveiller régulièrement : `df -h /var`
> - Configurer correctement logrotate
> - Utiliser `journalctl --vacuum-size=500M` pour systemd-journald

---

_Cours généré pour l'administration système Linux - Section Logs système_