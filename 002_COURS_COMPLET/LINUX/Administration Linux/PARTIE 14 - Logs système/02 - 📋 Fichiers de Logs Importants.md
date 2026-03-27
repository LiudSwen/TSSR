

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

## 🎯 Introduction aux fichiers de logs

Les fichiers de logs sont stockés principalement dans `/var/log/` et constituent la mémoire historique de votre système. Chaque fichier a un rôle spécifique et connaître leur emplacement et leur contenu est essentiel pour le diagnostic et la sécurité.

> [!info] Pourquoi ces fichiers sont-ils importants ?
> 
> - **Diagnostic** : Identifier la cause d'un problème système
> - **Sécurité** : Détecter des tentatives d'intrusion ou des comportements suspects
> - **Audit** : Tracer qui a fait quoi et quand
> - **Performance** : Repérer des erreurs récurrentes qui ralentissent le système

---

## 📊 /var/log/syslog et /var/log/messages

### Présentation

Le fichier `syslog` (Debian/Ubuntu) ou `messages` (RHEL/CentOS) est le **journal système général**. Il centralise les messages de la plupart des services et processus système.

> [!tip] Différence selon la distribution
> 
> - **Debian/Ubuntu** : `/var/log/syslog`
> - **RHEL/CentOS/Fedora** : `/var/log/messages`
> 
> Le contenu est similaire, seul le nom change.

### Contenu typique

Ce fichier contient :

- Messages du noyau au démarrage
- Événements des démons système (cron, systemd, etc.)
- Messages réseau et connexions
- Alertes matérielles
- Activités des services non critiques

### Format des entrées

Chaque ligne suit généralement ce format :

```
Date Heure Hostname Service[PID]: Message
```

**Exemple concret** :

```bash
Dec 27 10:23:45 serveur01 systemd[1]: Started Session 42 of user admin.
Dec 27 10:24:12 serveur01 CRON[3521]: (root) CMD (/usr/local/bin/backup.sh)
Dec 27 10:25:03 serveur01 kernel: [12345.678] USB device connected
```

### Consultation efficace

```bash
# Voir les dernières lignes en temps réel
sudo tail -f /var/log/syslog

# Voir les 50 dernières lignes
sudo tail -n 50 /var/log/syslog

# Rechercher des erreurs spécifiques
sudo grep -i "error\|fail\|critical" /var/log/syslog

# Filtrer par service (exemple avec cron)
sudo grep "CRON" /var/log/syslog

# Voir les logs d'aujourd'hui uniquement
sudo grep "$(date '+%b %d')" /var/log/syslog
```

> [!warning] Attention à la taille Ce fichier peut devenir très volumineux. Il est automatiquement rotaté (archivé) par le système, créant des versions compressées comme `syslog.1.gz`, `syslog.2.gz`, etc.

### Cas d'utilisation typiques

|Situation|Commande utile|
|---|---|
|Service qui ne démarre pas|`grep "nom_service" /var/log/syslog`|
|Problème réseau|`grep -i "network\|eth0\|wlan" /var/log/syslog`|
|Erreur au boot|`grep "systemd" /var/log/syslog \| head -100`|
|Activité suspecte|`grep -i "fail\|error" /var/log/syslog`|

---

## 🔐 /var/log/auth.log - Logs d'authentification

### Présentation

Le fichier `auth.log` (ou `secure` sur RHEL) enregistre **toutes les tentatives d'authentification** sur le système. C'est le premier endroit à consulter pour les questions de sécurité.

> [!info] Équivalent selon la distribution
> 
> - **Debian/Ubuntu** : `/var/log/auth.log`
> - **RHEL/CentOS/Fedora** : `/var/log/secure`

### Contenu enregistré

- Connexions SSH (réussies et échouées)
- Utilisation de `sudo`
- Changements d'utilisateur avec `su`
- Authentifications PAM (tous types)
- Verrouillages de compte
- Créations/modifications d'utilisateurs

### Exemples de logs courants

```bash
# Connexion SSH réussie
Dec 27 14:32:10 serveur01 sshd[8234]: Accepted password for admin from 192.168.1.100 port 52341 ssh2

# Connexion SSH échouée
Dec 27 14:35:22 serveur01 sshd[8567]: Failed password for invalid user hacker from 203.0.113.42 port 45123 ssh2

# Utilisation de sudo
Dec 27 14:40:15 serveur01 sudo: admin : TTY=pts/0 ; PWD=/home/admin ; USER=root ; COMMAND=/usr/bin/apt update

# Changement d'utilisateur
Dec 27 14:45:30 serveur01 su[9123]: Successful su for postgres by root
```

### Surveillance de la sécurité

```bash
# Voir toutes les connexions SSH réussies
sudo grep "Accepted" /var/log/auth.log

# Voir toutes les tentatives échouées
sudo grep "Failed password" /var/log/auth.log

# Compter les tentatives échouées par IP
sudo grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr

# Voir toutes les utilisations de sudo par un utilisateur
sudo grep "sudo.*admin" /var/log/auth.log

# Détecter les tentatives de brute force (plus de 5 échecs)
sudo grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | awk '$1 > 5'

# Surveiller en temps réel
sudo tail -f /var/log/auth.log | grep --color=auto "Failed\|Accepted"
```

> [!warning] Sécurité critique Ce fichier doit être surveillé régulièrement. Des tentatives répétées de connexion échouées peuvent indiquer une attaque par force brute.

> [!tip] Astuce d'investigation Combinez `auth.log` avec les adresses IP pour identifier des patterns :
> 
> ```bash
> # Analyser les IPs suspectes
> sudo grep "Failed password" /var/log/auth.log | grep -oP '\d+\.\d+\.\d+\.\d+' | sort | uniq -c | sort -rn | head -10
> ```

### Cas d'utilisation

|Besoin|Commande|
|---|---|
|Qui s'est connecté aujourd'hui ?|`grep "Accepted.*$(date '+%b %d')" /var/log/auth.log`|
|Tentatives échouées récentes|`grep "Failed" /var/log/auth.log \| tail -20`|
|Historique sudo d'un user|`grep "sudo.*username" /var/log/auth.log`|
|Détecter un compte compromis|`grep "username" /var/log/auth.log \| grep "Failed"`|

---

## 🐧 /var/log/kern.log - Logs du noyau

### Présentation

Le fichier `kern.log` contient exclusivement les **messages du noyau Linux** (kernel). Ces logs sont essentiels pour diagnostiquer les problèmes matériels, les pilotes et les erreurs bas niveau.

### Contenu typique

- Détection et initialisation du matériel au démarrage
- Erreurs de pilotes (drivers)
- Problèmes de disque ou mémoire
- Messages de périphériques USB, réseau
- Paniques du noyau (kernel panics)
- Événements de gestion de l'énergie
- Erreurs de segmentation d'applications critiques

### Format des entrées

Les messages du noyau incluent souvent un **timestamp en secondes** entre crochets :

```bash
Dec 27 08:15:23 serveur01 kernel: [    0.000000] Linux version 5.15.0-91-generic
Dec 27 08:15:23 serveur01 kernel: [    0.012345] ACPI: Core revision 20210730
Dec 27 10:42:18 serveur01 kernel: [12345.678901] USB 2-1: new high-speed USB device
```

> [!info] Comprendre le timestamp Le nombre entre crochets `[12345.678901]` représente les secondes écoulées depuis le démarrage du système, avec une précision de la microseconde.

### Consultation pour diagnostic matériel

```bash
# Voir tous les messages du noyau
sudo cat /var/log/kern.log

# Rechercher des erreurs matérielles
sudo grep -i "error\|fail\|warn\|critical" /var/log/kern.log

# Vérifier les problèmes de disque
sudo grep -i "sda\|sdb\|nvme\|ata\|disk" /var/log/kern.log

# Problèmes de mémoire
sudo grep -i "memory\|oom\|out of memory" /var/log/kern.log

# Événements USB
sudo grep -i "usb" /var/log/kern.log

# Voir uniquement le dernier boot (nécessite systemd)
sudo journalctl -k -b 0

# Rechercher les kernel panics (plantages graves)
sudo grep -i "panic\|oops\|bug:" /var/log/kern.log
```

> [!example] Exemple de diagnostic Si un disque montre des signes de défaillance, vous verrez des messages comme :
> 
> ```
> kernel: [45678.123] ata1.00: exception Emask 0x0 SAct 0x0 SErr 0x0 action 0x6 frozen
> kernel: [45678.124] ata1.00: failed command: READ DMA
> kernel: [45678.125] ata1.00: status: { DRDY ERR }
> kernel: [45678.126] ata1.00: error: { UNC }
> ```
> 
> Ces messages indiquent des secteurs défectueux (UNC = Uncorrectable Error).

### Cas d'utilisation critiques

|Problème|Investigation|
|---|---|
|Système lent ou freeze|Chercher "hung task", "blocked", "soft lockup"|
|Disque qui déconne|Chercher "ata", "SCSI error", "I/O error"|
|Carte réseau instable|Chercher le nom de l'interface (eth0, ens33)|
|Problème de driver|Chercher le nom du module ou "firmware"|
|Out of Memory|Chercher "OOM killer", "Out of memory"|

> [!warning] Erreurs critiques Les messages contenant "Oops", "panic", "BUG", ou "segfault" indiquent des problèmes graves qui peuvent nécessiter un redémarrage ou une mise à jour du noyau.

### Piège courant

> [!warning] Ne pas confondre avec syslog Bien que certains messages du noyau apparaissent aussi dans `syslog`, `kern.log` est **plus complet** pour tout ce qui concerne le noyau. Utilisez toujours `kern.log` pour les diagnostics matériels approfondis.

---

## 📦 /var/log/apt/ - Logs de gestion de paquets

### Présentation

Le répertoire `/var/log/apt/` (sur Debian/Ubuntu) contient l'**historique complet** de toutes les opérations de gestion de paquets. C'est indispensable pour tracer les installations, mises à jour et suppressions.

> [!info] Équivalent sur d'autres distributions
> 
> - **RHEL/CentOS** : `/var/log/yum.log` ou `/var/log/dnf.log`
> - **Arch Linux** : `/var/log/pacman.log`
> 
> Nous nous concentrons ici sur Debian/Ubuntu avec APT.

### Structure du répertoire

```bash
/var/log/apt/
├── history.log        # Historique détaillé des commandes
├── history.log.1.gz   # Archives rotées
├── term.log           # Sortie terminal complète
├── term.log.1.gz      # Archives rotées
└── eipp.log.xz        # Logs de résolution de dépendances (avancé)
```

### /var/log/apt/history.log

Ce fichier enregistre **quoi, quand, et par qui** chaque opération a été effectuée.

**Format des entrées** :

```bash
Start-Date: 2024-12-27  14:23:45
Commandline: apt install nginx
Requested-By: admin (1000)
Install: nginx:amd64 (1.18.0-6ubuntu14)
End-Date: 2024-12-27  14:24:12

Start-Date: 2024-12-27  15:10:33
Commandline: apt upgrade
Requested-By: root (0)
Upgrade: systemd:amd64 (249.11-0ubuntu3.11, 249.11-0ubuntu3.12)
End-Date: 2024-12-27  15:12:08
```

### /var/log/apt/term.log

Ce fichier contient la **sortie terminal complète**, incluant les messages d'erreur, les confirmations, et toutes les interactions.

```bash
Log started: 2024-12-27  14:23:45
(Reading database ... 234567 files and directories currently installed.)
Preparing to unpack .../nginx_1.18.0-6ubuntu14_amd64.deb ...
Unpacking nginx (1.18.0-6ubuntu14) ...
Setting up nginx (1.18.0-6ubuntu14) ...
Processing triggers for systemd (249.11-0ubuntu3.11) ...
Log ended: 2024-12-27  14:24:12
```

### Consultation et analyse

```bash
# Voir l'historique complet
sudo cat /var/log/apt/history.log

# Voir les 20 dernières opérations
sudo tail -n 100 /var/log/apt/history.log

# Trouver quand un paquet a été installé
sudo grep -A 3 "Install:.*nginx" /var/log/apt/history.log

# Voir toutes les mises à jour du mois
sudo grep "$(date '+%Y-%m')" /var/log/apt/history.log

# Lister tous les paquets installés avec apt (pas les dépendances auto)
sudo grep "^Commandline: apt install" /var/log/apt/history.log

# Voir qui a effectué des opérations (utile en multi-admin)
sudo grep "Requested-By" /var/log/apt/history.log

# Trouver les suppressions de paquets
sudo grep "Remove:" /var/log/apt/history.log

# Analyser les erreurs lors d'installations
sudo grep -i "error\|failed" /var/log/apt/term.log
```

> [!tip] Audit et rollback Ces logs sont précieux pour :
> 
> - Comprendre **pourquoi** un système a changé de comportement
> - Identifier **qui** a installé ou supprimé un paquet
> - Retrouver la **version exacte** d'un paquet avant une mise à jour

### Cas d'utilisation pratiques

|Besoin|Commande|
|---|---|
|Quand nginx a-t-il été installé ?|`grep -B 1 "nginx" /var/log/apt/history.log`|
|Qui a fait l'upgrade hier ?|`grep "$(date -d yesterday '+%Y-%m-%d')" /var/log/apt/history.log`|
|Toutes les installations ce mois|`grep "Install:" /var/log/apt/history.log \| grep "$(date '+%Y-%m')"`|
|Erreurs lors de la dernière opération|`tail -100 /var/log/apt/term.log \| grep -i error`|

### Consulter les archives

Les logs sont automatiquement archivés et compressés. Pour les consulter :

```bash
# Lire un fichier compressé
zcat /var/log/apt/history.log.1.gz

# Rechercher dans tous les logs (actuels et archivés)
zgrep "nginx" /var/log/apt/history.log*

# Voir l'historique complet sur plusieurs mois
zcat /var/log/apt/history.log.*.gz | grep "Install:"
```

> [!example] Exemple d'investigation après un problème Un service ne fonctionne plus depuis hier. Pour identifier si une mise à jour est en cause :
> 
> ```bash
> # 1. Vérifier les upgrades d'hier
> sudo grep "$(date -d yesterday '+%Y-%m-%d')" /var/log/apt/history.log
> 
> # 2. Voir si le paquet du service a été touché
> sudo grep -A 5 "Upgrade:.*mon-service" /var/log/apt/history.log
> 
> # 3. Consulter les erreurs potentielles
> sudo grep -A 10 "$(date -d yesterday '+%Y-%m-%d')" /var/log/apt/term.log | grep -i error
> ```

---

## ✅ Bonnes pratiques de consultation

### Outils recommandés

```bash
# less : navigation confortable dans les gros fichiers
sudo less /var/log/syslog
# Touches utiles : espace (page suivante), b (page précédente), / (recherche), q (quitter)

# tail -f : surveillance en temps réel (indispensable)
sudo tail -f /var/log/auth.log

# grep avec contexte : voir les lignes avant/après un match
sudo grep -C 3 "error" /var/log/syslog  # 3 lignes avant et après
sudo grep -B 5 "failed" /var/log/auth.log  # 5 lignes avant
sudo grep -A 2 "warning" /var/log/kern.log  # 2 lignes après

# Recherches insensibles à la casse
sudo grep -i "ERROR" /var/log/syslog  # trouve error, Error, ERROR, etc.

# Compter les occurrences
sudo grep -c "Failed password" /var/log/auth.log

# Exclure des résultats
sudo grep "error" /var/log/syslog | grep -v "ignore_this"
```

### Combinaisons puissantes

```bash
# Logs d'aujourd'hui uniquement (format francophone)
sudo grep "$(date '+%d %b')" /var/log/syslog

# Logs entre deux heures précises
sudo awk '/10:00:00/,/11:00:00/' /var/log/syslog

# Top 10 des IPs ayant échoué à se connecter
sudo grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -10

# Surveiller plusieurs fichiers simultanément
sudo tail -f /var/log/syslog /var/log/auth.log

# Extraire et analyser avec awk
sudo awk '/error/ {print $1, $2, $3, $NF}' /var/log/syslog
```

> [!tip] Coloriser la sortie pour plus de lisibilité
> 
> ```bash
> # Avec grep (auto-coloration)
> sudo tail -f /var/log/syslog | grep --color=auto "error\|warn\|fail"
> 
> # Avec ccze (à installer : apt install ccze)
> sudo tail -f /var/log/syslog | ccze -A
> ```

### Automatisation de la surveillance

```bash
# Script simple de monitoring (à placer dans un cron)
#!/bin/bash
# Alerte si plus de 10 tentatives de connexion échouées dans la dernière heure

FAILED=$(sudo grep "Failed password" /var/log/auth.log | grep "$(date '+%b %d %H')" | wc -l)

if [ $FAILED -gt 10 ]; then
    echo "ALERTE : $FAILED tentatives de connexion échouées dans la dernière heure !" | mail -s "Alerte Sécurité" admin@example.com
fi
```

### Rotation et archivage

> [!info] Rotation automatique Les logs sont automatiquement gérés par `logrotate` qui :
> 
> - Archive les vieux logs (`.log.1`, `.log.2.gz`, etc.)
> - Compresse les archives pour économiser l'espace
> - Supprime les archives trop anciennes selon la configuration
> 
> Configuration dans : `/etc/logrotate.d/` et `/etc/logrotate.conf`

```bash
# Voir la taille des logs
sudo du -sh /var/log/*

# Vérifier l'espace disque utilisé
df -h /var/log

# Forcer une rotation manuelle (pour tests)
sudo logrotate -f /etc/logrotate.conf
```

### Pièges à éviter

> [!warning] Erreurs courantes
> 
> - **Oublier sudo** : La plupart des logs nécessitent des permissions root
> - **Ne pas surveiller en temps réel** : `tail -f` est votre meilleur ami pour le debugging
> - **Ignorer les logs archivés** : Un problème peut avoir commencé il y a plusieurs jours
> - **Chercher dans le mauvais fichier** : Vérifiez que vous consultez bien le log approprié au problème
> - **Ne pas combiner les sources** : Croisez syslog, auth.log et kern.log pour une vue complète

### Checklist de diagnostic

Lorsque vous enquêtez sur un problème, suivez cet ordre :

1. **Identifier le type de problème** (service, sécurité, matériel, paquet)
2. **Choisir le bon fichier de log** selon la table ci-dessous
3. **Chercher autour de l'heure du problème** (`grep "Dec 27 14:"`)
4. **Élargir la recherche** si nécessaire (archives, autres logs)
5. **Corréler les événements** entre différents fichiers

|Type de problème|Fichier prioritaire|Fichiers secondaires|
|---|---|---|
|Service qui plante|`syslog`|`kern.log` (si crash), logs spécifiques du service|
|Connexion refusée|`auth.log`|`syslog` (pour SSH)|
|Disque défaillant|`kern.log`|`syslog`|
|Paquet cassé|`apt/history.log` et `term.log`|`syslog`|
|Freeze système|`kern.log`|`syslog`|

---

## 🎓 Résumé des fichiers clés

|Fichier|Contenu|Usage principal|
|---|---|---|
|**syslog/messages**|Logs système généraux|Diagnostic de services, événements système|
|**auth.log/secure**|Authentifications|Sécurité, connexions, sudo|
|**kern.log**|Messages du noyau|Problèmes matériels, drivers|
|**apt/**|Gestion de paquets|Historique des installations/mises à jour|

> [!tip] Mémo rapide
> 
> - **Problème de service** → `syslog`
> - **Sécurité/Connexions** → `auth.log`
> - **Matériel/Kernel** → `kern.log`
> - **Paquets** → `apt/history.log`