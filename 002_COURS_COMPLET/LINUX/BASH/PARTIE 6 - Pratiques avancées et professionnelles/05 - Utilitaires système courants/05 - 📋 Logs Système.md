

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

## 🎯 Introduction aux logs système

Les logs système sont la mémoire de votre machine Linux. Ils enregistrent tout ce qui se passe : démarrages, erreurs, connexions utilisateurs, activités des services, etc.

> [!info] Pourquoi les logs sont essentiels
> 
> - **Diagnostic** : Identifier la cause d'un problème ou d'un crash
> - **Sécurité** : Détecter des tentatives d'intrusion ou des comportements anormaux
> - **Audit** : Tracer les actions effectuées sur le système
> - **Performance** : Analyser les goulots d'étranglement et optimiser le système

Les logs Linux sont principalement gérés par deux systèmes :

- **Rsyslog** : le système de logging traditionnel (fichiers texte)
- **Systemd-journald** : le système moderne intégré à systemd (binaire)

---

## 📂 L'emplacement des logs : /var/log/

Tous les logs système sont centralisés dans le répertoire `/var/log/`. C'est le point de départ de toute investigation.

### Structure typique de /var/log/

```bash
# Afficher le contenu de /var/log/
ls -lh /var/log/
```

|Fichier/Dossier|Description|
|---|---|
|`/var/log/syslog`|Log général du système (Debian/Ubuntu)|
|`/var/log/messages`|Log général du système (RedHat/CentOS)|
|`/var/log/auth.log`|Authentifications et autorisations|
|`/var/log/kern.log`|Messages du noyau Linux|
|`/var/log/dmesg`|Messages de boot du noyau|
|`/var/log/boot.log`|Informations de démarrage|
|`/var/log/apache2/`|Logs du serveur web Apache|
|`/var/log/nginx/`|Logs du serveur web Nginx|
|`/var/log/mysql/`|Logs de la base de données MySQL|
|`/var/log/apt/`|Logs du gestionnaire de paquets APT|

> [!example] Consulter les logs principaux
> 
> ```bash
> # Log système général (Ubuntu/Debian)
> sudo cat /var/log/syslog
> 
> # Dernières authentifications
> sudo tail /var/log/auth.log
> 
> # Messages du noyau au démarrage
> dmesg | less
> 
> # Lister tous les fichiers de log
> sudo ls -lhR /var/log/ | less
> ```

> [!warning] Permissions et accès root La plupart des fichiers de log nécessitent les droits root pour être consultés. Utilisez `sudo` ou connectez-vous en tant que root.

### Organisation des logs

```bash
# Taille des logs dans /var/log/
sudo du -sh /var/log/*

# Trouver les plus gros fichiers de log
sudo du -ah /var/log/ | sort -rh | head -20

# Surveiller l'espace disque utilisé par les logs
df -h /var/log/
```

---

## 🔄 Syslog et Rsyslog

**Syslog** est le protocole standard de logging sous Linux. **Rsyslog** (Rocket-fast System for Log processing) est son implémentation moderne, plus rapide et plus flexible.

### Fonctionnement de Rsyslog

Rsyslog collecte les messages de log provenant de diverses sources (noyau, applications, services) et les dispatche selon des règles de configuration.

> [!info] Processus Rsyslog
> 
> 1. **Réception** : Rsyslog écoute les messages de log
> 2. **Filtrage** : Application des règles de configuration
> 3. **Action** : Écriture dans des fichiers, redirection, etc.

### Configuration de Rsyslog

Le fichier principal de configuration : `/etc/rsyslog.conf`

```bash
# Afficher la configuration
sudo cat /etc/rsyslog.conf

# Configurations additionnelles dans
ls /etc/rsyslog.d/
```

#### Structure de configuration

```bash
# Format : facility.priority    action
# Exemples de règles dans /etc/rsyslog.conf

# Tous les messages d'authentification
auth,authpriv.*                 /var/log/auth.log

# Messages du noyau
kern.*                          /var/log/kern.log

# Tous les messages (sauf mail)
*.*;mail.none                   /var/log/syslog

# Messages d'urgence à tous les utilisateurs connectés
*.emerg                         :omusrmsg:*
```

> [!tip] Syntaxe des règles Rsyslog `facility.priority destination`
> 
> - **facility** : catégorie du message (auth, kern, mail, daemon, etc.)
> - **priority** : niveau de gravité (debug, info, notice, warning, err, crit, alert, emerg)
> - **destination** : où enregistrer le message (fichier, console, serveur distant)

### Commandes Rsyslog

```bash
# Vérifier le statut de rsyslog
sudo systemctl status rsyslog

# Redémarrer rsyslog après modification de config
sudo systemctl restart rsyslog

# Recharger la configuration sans redémarrer
sudo systemctl reload rsyslog

# Activer rsyslog au démarrage
sudo systemctl enable rsyslog

# Tester la configuration (sur certaines distributions)
sudo rsyslogd -N1
```

### Envoyer un message de test

```bash
# Envoyer un message de test via logger
logger "Message de test dans syslog"

# Vérifier que le message apparaît
sudo tail /var/log/syslog | grep "Message de test"

# Envoyer avec une facility et priority spécifiques
logger -p user.notice "Test avec priorité notice"
```

> [!example] Créer une règle personnalisée
> 
> ```bash
> # Créer un fichier de configuration pour votre application
> sudo nano /etc/rsyslog.d/50-myapp.conf
> 
> # Contenu du fichier :
> # :programname, isequal, "myapp" /var/log/myapp.log
> # & stop
> 
> # Redémarrer rsyslog
> sudo systemctl restart rsyslog
> 
> # Tester
> logger -t myapp "Test de l'application"
> sudo tail /var/log/myapp.log
> ```

### Logging distant avec Rsyslog

Rsyslog peut envoyer des logs vers un serveur centralisé :

```bash
# Sur le client - ajouter dans /etc/rsyslog.conf
# Envoyer tous les logs vers un serveur distant
# *.* @@serveur-logs.example.com:514    # TCP
# *.* @serveur-logs.example.com:514     # UDP

# Sur le serveur - activer la réception
# Décommenter ces lignes dans /etc/rsyslog.conf :
# module(load="imudp")
# input(type="imudp" port="514")
```

---

## 📖 Journalctl : les logs de systemd

**Journalctl** est l'outil de consultation des logs de **systemd-journald**, le système de logging moderne qui stocke les logs dans un format binaire optimisé.

### Pourquoi journalctl ?

> [!info] Avantages de journald
> 
> - **Indexation** : Recherche rapide et filtrage puissant
> - **Métadonnées** : Chaque entrée contient des informations détaillées (PID, UID, etc.)
> - **Intégration** : Totalement intégré avec systemd
> - **Stockage** : Gestion automatique de l'espace disque

### Commandes de base

```bash
# Afficher tous les logs
journalctl

# Logs depuis le dernier démarrage
journalctl -b

# Logs du démarrage précédent
journalctl -b -1

# Logs en temps réel (équivalent de tail -f)
journalctl -f

# Logs avec pagination inversée (plus récents d'abord)
journalctl -r
```

### Filtrage par temps

```bash
# Logs depuis aujourd'hui
journalctl --since today

# Logs depuis une date spécifique
journalctl --since "2024-12-01"

# Logs depuis une heure précise
journalctl --since "2024-12-13 14:00:00"

# Logs dans un intervalle de temps
journalctl --since "2024-12-13 10:00" --until "2024-12-13 12:00"

# Logs des 2 dernières heures
journalctl --since "2 hours ago"

# Logs de la semaine dernière
journalctl --since "1 week ago"
```

### Filtrage par service

```bash
# Logs d'un service spécifique
journalctl -u nginx.service
journalctl -u ssh.service

# Logs de plusieurs services
journalctl -u nginx.service -u apache2.service

# Logs d'un service en temps réel
journalctl -u nginx.service -f

# Logs d'un service depuis le dernier boot
journalctl -u ssh.service -b
```

### Filtrage par priorité

```bash
# Seulement les erreurs et plus grave
journalctl -p err

# Seulement les warnings et plus grave
journalctl -p warning

# Messages de niveau critique uniquement
journalctl -p crit..alert

# Hiérarchie des priorités :
# 0: emerg   - Système inutilisable
# 1: alert   - Action immédiate requise
# 2: crit    - Conditions critiques
# 3: err     - Erreurs
# 4: warning - Avertissements
# 5: notice  - Normal mais significatif
# 6: info    - Informationnel
# 7: debug   - Messages de débogage
```

### Filtrage par processus

```bash
# Logs d'un PID spécifique
journalctl _PID=1234

# Logs d'un exécutable
journalctl /usr/bin/nginx

# Logs d'un utilisateur spécifique
journalctl _UID=1000

# Logs du noyau uniquement
journalctl -k
```

### Options d'affichage

```bash
# Format JSON pour parsing
journalctl -o json

# Format JSON avec une ligne par entrée
journalctl -o json-pretty

# Format court (syslog-like)
journalctl -o short

# Format détaillé avec toutes les métadonnées
journalctl -o verbose

# Format avec timestamp précis en UTC
journalctl -o short-iso

# N'afficher que les messages (sans métadonnées)
journalctl --no-hostname -o cat
```

### Limiter la sortie

```bash
# Les 100 dernières entrées
journalctl -n 100

# Les 50 dernières lignes d'un service
journalctl -u nginx.service -n 50

# Inverser l'ordre (plus ancien en premier)
journalctl -r -n 20
```

### Recherche dans les logs

```bash
# Recherche de texte (grep intégré)
journalctl | grep "error"

# Recherche sensible à la casse
journalctl | grep -i "failed"

# Recherche dans un service spécifique
journalctl -u ssh.service | grep "Failed password"

# Combiner filtres
journalctl --since today -p err | grep "database"
```

> [!example] Exemples pratiques de debugging
> 
> ```bash
> # Analyser pourquoi un service a échoué
> journalctl -u myservice.service -n 100 --no-pager
> 
> # Voir tous les redémarrages du système
> journalctl --list-boots
> 
> # Logs d'un boot spécifique
> journalctl -b <boot_id>
> 
> # Erreurs système depuis hier
> journalctl --since yesterday -p err
> 
> # Suivre les authentifications SSH en temps réel
> journalctl -u ssh.service -f -p info
> ```

### Gestion de l'espace disque

```bash
# Afficher l'espace utilisé par les logs
journalctl --disk-usage

# Nettoyer les logs plus vieux que 2 semaines
sudo journalctl --vacuum-time=2weeks

# Limiter la taille totale des logs à 500M
sudo journalctl --vacuum-size=500M

# Garder seulement les 5 derniers fichiers
sudo journalctl --vacuum-files=5
```

### Configuration de journald

Fichier de configuration : `/etc/systemd/journald.conf`

```bash
# Éditer la configuration
sudo nano /etc/systemd/journald.conf
```

> [!tip] Options de configuration importantes
> 
> ```ini
> [Journal]
> # Où stocker les logs (persistent, volatile, auto)
> Storage=persistent
> 
> # Compression des logs
> Compress=yes
> 
> # Taille maximale des logs
> SystemMaxUse=500M
> 
> # Durée de rétention
> MaxRetentionSec=1month
> 
> # Redirection vers rsyslog
> ForwardToSyslog=yes
> ```

```bash
# Appliquer les changements
sudo systemctl restart systemd-journald
```

---

## 👁️ Lecture de logs avec tail -f

La commande `tail -f` est l'outil le plus utilisé pour surveiller les logs en temps réel.

### Syntaxe de base

```bash
# Suivre un fichier de log en temps réel
tail -f /var/log/syslog

# Afficher les 50 dernières lignes puis suivre
tail -n 50 -f /var/log/auth.log

# Suivre plusieurs fichiers simultanément
tail -f /var/log/syslog /var/log/auth.log
```

### Options utiles de tail

```bash
# Les N dernières lignes
tail -n 100 /var/log/syslog

# Depuis le byte N
tail -c 1000 /var/log/syslog

# Suivre même si le fichier est recréé (utile avec rotation)
tail -F /var/log/syslog

# Avec le nom du fichier en en-tête (multi-fichiers)
tail -f -v /var/log/syslog /var/log/auth.log
```

> [!info] Différence entre -f et -F
> 
> - **`-f`** : Suit le descripteur de fichier (arrête si le fichier est renommé/supprimé)
> - **`-F`** : Suit le nom du fichier (continue même après rotation)
> 
> Pour les logs qui subissent une rotation, utilisez **`-F`** !

### Combiner tail avec grep

```bash
# Filtrer les lignes contenant "error"
tail -f /var/log/syslog | grep "error"

# Filtrer plusieurs motifs
tail -f /var/log/syslog | grep -E "error|warning|failed"

# Exclure certaines lignes
tail -f /var/log/apache2/access.log | grep -v "robots.txt"

# Coloriser les résultats
tail -f /var/log/syslog | grep --color=auto "error"

# Afficher contexte (3 lignes avant et après)
tail -f /var/log/syslog | grep -C 3 "error"
```

### Surveiller plusieurs logs efficacement

```bash
# Avec multitail (à installer)
sudo apt install multitail
multitail /var/log/syslog /var/log/auth.log /var/log/apache2/error.log

# Avec lnav (Log file navigator - très pratique)
sudo apt install lnav
lnav /var/log/syslog /var/log/auth.log

# Surveiller tous les logs d'un dossier
tail -f /var/log/apache2/*.log
```

> [!tip] Astuces de pro avec tail
> 
> ```bash
> # Surveiller et sauvegarder en même temps (tee)
> tail -f /var/log/syslog | tee ~/surveillance.log
> 
> # Compter les occurrences en temps réel
> tail -f /var/log/apache2/access.log | grep -c "404"
> 
> # Alerter sur un motif spécifique
> tail -f /var/log/auth.log | grep "Failed password" | \
>   while read line; do echo "ALERTE: $line"; done
> 
> # Extraire des champs spécifiques (awk)
> tail -f /var/log/auth.log | awk '{print $1, $2, $3, $11}'
> ```

### Alternative : less +F

```bash
# Ouvrir avec less en mode suivi
less +F /var/log/syslog

# Dans less, basculer entre suivi et navigation :
# Ctrl+C : Arrêter le suivi (mode navigation)
# Shift+F : Reprendre le suivi
# q : Quitter
```

---

## 🔄 Rotation des logs

La rotation des logs empêche les fichiers de log de consommer tout l'espace disque. C'est un processus qui archive, compresse et supprime les anciens logs.

### Logrotate : l'outil de rotation

**Logrotate** est l'utilitaire standard de rotation des logs sous Linux.

> [!info] Qu'est-ce que logrotate fait ?
> 
> 1. **Rotation** : Renomme le fichier actuel (ex: `syslog` → `syslog.1`)
> 2. **Compression** : Compresse les anciens logs (ex: `syslog.1` → `syslog.1.gz`)
> 3. **Suppression** : Efface les logs trop anciens
> 4. **Recréation** : Crée un nouveau fichier vide pour continuer à logger

### Configuration de logrotate

Fichier principal : `/etc/logrotate.conf` Configurations spécifiques : `/etc/logrotate.d/`

```bash
# Voir la configuration globale
cat /etc/logrotate.conf

# Lister les configurations spécifiques
ls -l /etc/logrotate.d/
```

### Syntaxe d'une configuration

```bash
# Exemple de configuration : /etc/logrotate.d/nginx

/var/log/nginx/*.log {
    daily                    # Rotation quotidienne
    missingok               # Ne pas générer d'erreur si fichier absent
    rotate 14               # Garder 14 archives
    compress                # Comprimer les archives
    delaycompress          # Comprimer à la prochaine rotation
    notifempty             # Ne pas tourner si le fichier est vide
    create 0640 www-data adm  # Créer nouveau fichier avec ces permissions
    sharedscripts          # Exécuter les scripts une seule fois
    postrotate
        # Commande après rotation (recharger nginx)
        if [ -f /var/run/nginx.pid ]; then
            kill -USR1 `cat /var/run/nginx.pid`
        fi
    endscript
}
```

### Directives principales

|Directive|Description|
|---|---|
|`daily` / `weekly` / `monthly`|Fréquence de rotation|
|`rotate N`|Nombre d'archives à conserver|
|`size 100M`|Rotation quand fichier atteint la taille|
|`compress`|Compresser les archives (gzip)|
|`delaycompress`|Ne pas compresser la dernière archive|
|`missingok`|Ne pas errorer si fichier manquant|
|`notifempty`|Ne pas tourner si fichier vide|
|`create MODE USER GROUP`|Permissions du nouveau fichier|
|`copytruncate`|Copier puis vider (pour apps qui gardent le fichier ouvert)|
|`dateext`|Utiliser la date dans le nom (ex: `.20241213`)|
|`maxage N`|Supprimer archives de plus de N jours|

### Scripts pre/post rotation

```bash
# prerotate : avant la rotation
# postrotate : après la rotation
# firstaction : avant toute rotation (si plusieurs fichiers)
# lastaction : après toute rotation

/var/log/myapp/*.log {
    daily
    rotate 7
    compress
    
    prerotate
        echo "Début de la rotation de myapp"
    endscript
    
    postrotate
        # Recharger l'application
        systemctl reload myapp.service
    endscript
}
```

### Tester et forcer la rotation

```bash
# Tester la configuration (mode dry-run)
sudo logrotate -d /etc/logrotate.conf

# Tester une config spécifique
sudo logrotate -d /etc/logrotate.d/nginx

# Forcer la rotation immédiate
sudo logrotate -f /etc/logrotate.conf

# Forcer une config spécifique
sudo logrotate -f /etc/logrotate.d/nginx

# Mode verbeux pour voir ce qui se passe
sudo logrotate -v /etc/logrotate.conf
```

> [!warning] État de logrotate Logrotate garde son état dans `/var/lib/logrotate/status` (ou `/var/lib/logrotate.status`). Ce fichier contient la dernière date de rotation de chaque log.
> 
> ```bash
> # Voir l'état
> cat /var/lib/logrotate/status
> 
> # Réinitialiser pour un fichier (forcer prochaine rotation)
> sudo nano /var/lib/logrotate/status
> # Supprimer la ligne concernée
> ```

### Exemple de configuration personnalisée

```bash
# Créer une config pour vos logs d'application
sudo nano /etc/logrotate.d/myapp

# Contenu :
/var/log/myapp/*.log {
    daily                          # Tous les jours
    rotate 30                      # 30 jours d'historique
    compress                       # Compresser
    delaycompress                 # Pas la dernière
    notifempty                    # Seulement si non vide
    missingok                     # OK si fichier manquant
    create 0644 myuser mygroup    # Nouveau fichier
    dateext                       # Nommer avec la date
    dateformat -%Y%m%d            # Format : -20241213
    
    postrotate
        # Recharger l'application
        systemctl reload myapp.service > /dev/null 2>&1 || true
    endscript
}

# Tester
sudo logrotate -d /etc/logrotate.d/myapp
```

### Automatisation de logrotate

Logrotate est généralement exécuté automatiquement via **cron** ou **systemd timer**.

```bash
# Via cron (ancien système)
cat /etc/cron.daily/logrotate

# Via systemd timer (système moderne)
systemctl status logrotate.timer
systemctl list-timers | grep logrotate

# Voir quand aura lieu la prochaine exécution
systemctl list-timers logrotate.timer

# Forcer une exécution manuelle
sudo systemctl start logrotate.service
```

---

## 📊 Niveaux de log

Les logs sont classés par niveau de gravité (priority/severity). Comprendre ces niveaux est essentiel pour filtrer et analyser les logs efficacement.

### Hiérarchie des niveaux (syslog/rsyslog)

|Niveau|Nom|Valeur|Description|Utilisation|
|---|---|---|---|---|
|0|`emerg`|Panic|Système inutilisable|Crash système imminent|
|1|`alert`|Alert|Action immédiate requise|Corruption de données, base offline|
|2|`crit`|Critical|Conditions critiques|Défaillance matérielle, FS plein|
|3|`err`|Error|Erreurs|Échec d'opération, erreur logicielle|
|4|`warning`|Warning|Avertissements|Situations anormales non bloquantes|
|5|`notice`|Notice|Normal mais significatif|Événements importants mais normaux|
|6|`info`|Informational|Informations|Événements généraux, statistiques|
|7|`debug`|Debug|Messages de débogage|Détails techniques pour développeurs|

> [!info] Principe d'inclusion Quand vous filtrez sur un niveau, vous obtenez **ce niveau et tous les niveaux plus graves**.
> 
> Exemple : `-p warning` affiche warning, err, crit, alert, et emerg.

### Niveaux dans journalctl

```bash
# Voir toutes les entrées de niveau "err" et supérieur
journalctl -p err

# Voir uniquement les warnings (3 et supérieur)
journalctl -p warning

# Plage de niveaux (de err à crit)
journalctl -p err..crit

# Debug et plus (tout)
journalctl -p debug
```

### Niveaux dans rsyslog

```bash
# Dans /etc/rsyslog.conf, la syntaxe est :
# facility.priority    destination

# Exemples :
*.err                  /var/log/errors.log      # Toutes les erreurs
kern.warning           /var/log/kernel-warn.log # Warnings du noyau
mail.info              /var/log/mail.log        # Infos du serveur mail
*.emerg                :omusrmsg:*              # Urgences à tous
```

### Facilities (catégories de messages)

Les facilities classifient la **source** du message :

|Facility|Description|
|---|---|
|`kern`|Noyau Linux|
|`user`|Processus utilisateur|
|`mail`|Système de mail|
|`daemon`|Démons système|
|`auth`|Authentification/sécurité|
|`syslog`|Syslog lui-même|
|`lpr`|Système d'impression|
|`news`|Système de news|
|`uucp`|Système UUCP|
|`cron`|Tâches cron|
|`authpriv`|Messages d'authentification privés|
|`ftp`|Serveur FTP|
|`local0-local7`|Utilisation locale personnalisée|

### Combiner facility et priority

```bash
# Dans rsyslog.conf
# Syntaxe : facility.priority

# Tous les messages d'authentification de niveau info et +
auth.info              /var/log/auth.log

# Erreurs du noyau uniquement
kern.err               /var/log/kernel-errors.log

# Tout sauf les messages de mail
*.*;mail.none          /var/log/syslog

# Plusieurs facilities
auth,authpriv.notice   /var/log/auth-notice.log

# Tous les messages (= wildcard)
*.*                    /var/log/all.log
```

> [!example] Exemples pratiques de filtrage
> 
> ```bash
> # Voir seulement les erreurs critiques système
> journalctl -p crit -b
> 
> # Erreurs d'authentification aujourd'hui
> journalctl -u ssh.service --since today -p err
> 
> # Messages du noyau de niveau warning
> journalctl -k -p warning
> 
> # Tous les messages debug d'un service
> journalctl -u myapp.service -p debug
> 
> # Dans rsyslog : séparer par niveau
> # *.info;*.!warn    /var/log/info.log    # info mais pas warn+
> # *.warn;*.!err     /var/log/warnings.log
> # *.err             /var/log/errors.log
> ```

### Bonnes pratiques d'utilisation des niveaux

> [!tip] Comment choisir le bon niveau
> 
> - **emerg/alert** : À utiliser **très rarement**, uniquement pour les situations catastrophiques
> - **crit** : Problèmes graves nécessitant une intervention immédiate
> - **err** : Erreurs qui empêchent une fonctionnalité de marcher
> - **warning** : Quelque chose d'anormal mais l'application continue
> - **notice** : Événements normaux mais importants (démarrage, arrêt)
> - **info** : Événements informatifs standards (requêtes, transactions)
> - **debug** : Détails techniques pour le développement (à désactiver en prod)

```bash
# En production, typiquement on log :
# - notice et supérieur pour les services critiques
# - info et supérieur pour les services standards
# - warning et supérieur pour réduire le volume

# En développement/debug :
# - debug pour obtenir tous les détails
```

---

## 🔧 Logger depuis vos scripts

Intégrer le logging dans vos scripts shell est une bonne pratique pour la traçabilité et le debugging.

### La commande logger

`logger` est l'outil en ligne de commande pour envoyer des messages à syslog/journald.

```bash
# Message simple
logger "Mon message de log"

# Avec une facility et priority
logger -p user.notice "Opération terminée avec succès"

# Avec un tag (identifiant)
logger -t monscript "Démarrage du traitement"

# Message d'erreur
logger -p user.err -t monscript "Erreur lors du traitement"

# Combinaisons
logger -p daemon.warning -t backup_script "Espace disque faible : 90% utilisé"
```

### Options de logger

```bash
# -p : priority (facility.level)
logger -p local0.info "Message custom"

# -t : tag (nom du programme)
logger -t myapp "Message avec tag"

# -i : inclure le PID
logger -i -t myapp "Message avec PID"

# -s : afficher aussi sur stderr
logger -s -t myapp "Message aussi en console"

# --id : spécifier un PID custom
logger --id=$ -t myapp "Message avec mon PID"

# -f : lire depuis un fichier
logger -t myapp -f /tmp/messages.txt

# Via stdin
echo "Message depuis stdin" | logger -t myapp

# Socket personnalisé (pour journald)
logger --journald << EOF
MESSAGE=Mon message
PRIORITY=3
CUSTOM_FIELD=valeur
EOF
```

### Intégration dans un script shell

```bash
#!/bin/bash

# Script avec logging intégré

SCRIPT_NAME="backup_script"

# Fonction de logging
log_info() {
    logger -p user.info -t "$SCRIPT_NAME" "$1"
    echo "[INFO] $1"
}

log_error() {
    logger -p user.err -t "$SCRIPT_NAME" "$1"
    echo "[ERROR] $1" >&2
}

log_warning() {
    logger -p user.warning -t "$SCRIPT_NAME" "$1"
    echo "[WARNING] $1"
}

# Début du script
log_info "Démarrage de la sauvegarde"

# Simulation d'opérations
if [ -d "/data/backup" ]; then
    log_info "Répertoire de backup trouvé"
    
    # Calcul espace disque
    DISK_USAGE=$(df /data/backup | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$DISK_USAGE" -gt 90 ]; then
        log_warning "Espace disque critique : ${DISK_USAGE}% utilisé"
    else
        log_info "Espace disque OK : ${DISK_USAGE}% utilisé"
    fi
    
    # Opération de backup (simulée)
    if tar -czf "/data/backup/backup_$(date +%Y%m%d).tar.gz" /home/user/ 2>/dev/null; then
        log_info "Sauvegarde terminée avec succès"
    else
        log_error "Échec de la sauvegarde"
        exit 1
    fi
else
    log_error "Répertoire de backup introuvable : /data/backup"
    exit 1
fi

log_info "Script terminé"
```

### Vérifier les logs du script

```bash
# Voir tous les messages du script
journalctl -t backup_script

# Voir les erreurs uniquement
journalctl -t backup_script -p err

# Suivre en temps réel
journalctl -t backup_script -f

# Logs du jour
journalctl -t backup_script --since today
```

### Logging avancé avec des champs personnalisés

Pour **journald**, vous pouvez ajouter des champs personnalisés :

```bash
#!/bin/bash

# Envoyer un message avec des métadonnées custom
systemd-cat -t myapp -p info <<EOF
MESSAGE=Opération réussie
OPERATION_ID=12345
USER_ID=1000
DURATION=2.5
STATUS=success
EOF

# Vérifier avec journalctl
journalctl -t myapp -o json-pretty | grep OPERATION_ID
```

### Logger les erreurs et sorties standard

```bash
#!/bin/bash

# Rediriger stdout et stderr vers logger
exec 1> >(logger -t monscript -p user.info)
exec 2> >(logger -t monscript -p user.err)

echo "Ceci ira dans les logs en tant qu'info"
echo "Ceci est une erreur" >&2

# Toute la sortie du script est maintenant loggée
ls -l /root  # L'erreur de permission sera loggée
```

### Fonction de logging complète

```bash
#!/bin/bash

# Fonction de logging professionnelle

SCRIPT_NAME=$(basename "$0")
LOG_FACILITY="local0"

# Codes couleur pour terminal
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Envoi à syslog
    logger -p "${LOG_FACILITY}.${level}" -t "$SCRIPT_NAME" "$message"
    
    # Affichage console avec couleur
    case $level in
        err|error)
            echo -e "${RED}[ERROR]${NC} [$timestamp] $message" >&2
            ;;
        warning|warn)
            echo -e "${YELLOW}[WARN]${NC} [$timestamp] $message"
            ;;
        info)
            echo -e "${GREEN}[INFO]${NC} [$timestamp] $message"
            ;;
        debug)
            echo -e "${BLUE}[DEBUG]${NC} [$timestamp] $message"
            ;;
        *)
            echo "[$timestamp] $message"
            ;;
    esac
}

# Raccourcis
log_debug() { log debug "$@"; }
log_info() { log info "$@"; }
log_warn() { log warning "$@"; }
log_error() { log err "$@"; }

# Utilisation
log_info "Script démarré"
log_debug "Mode debug activé"
log_warn "Attention : configuration par défaut utilisée"
log_error "Impossible de se connecter à la base de données"
```

### Exemple : Script de monitoring avec logging

```bash
#!/bin/bash

SCRIPT_NAME="system_monitor"

log_info() {
    logger -p local0.info -t "$SCRIPT_NAME" "$1"
}

log_warning() {
    logger -p local0.warning -t "$SCRIPT_NAME" "$1"
}

log_error() {
    logger -p local0.err -t "$SCRIPT_NAME" "$1"
}

# Vérifier CPU
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    log_warning "CPU usage élevé : ${CPU_USAGE}%"
fi

# Vérifier RAM
RAM_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')
if (( $(echo "$RAM_USAGE > 85" | bc -l) )); then
    log_warning "RAM usage élevé : ${RAM_USAGE}%"
fi

# Vérifier disque
while IFS= read -r line; do
    MOUNT=$(echo $line | awk '{print $6}')
    USAGE=$(echo $line | awk '{print $5}' | sed 's/%//')
    
    if [ "$USAGE" -gt 90 ]; then
        log_error "Disque presque plein sur $MOUNT : ${USAGE}%"
    elif [ "$USAGE" -gt 75 ]; then
        log_warning "Disque usage élevé sur $MOUNT : ${USAGE}%"
    fi
done < <(df -h | grep -vE '^Filesystem|tmpfs|cdrom')

log_info "Vérification système terminée"
```

### Créer un fichier de log dédié pour votre script

Si vous préférez un fichier de log séparé plutôt que syslog :

```bash
#!/bin/bash

LOG_FILE="/var/log/myapp.log"

# Créer le fichier s'il n'existe pas
sudo touch "$LOG_FILE"
sudo chmod 644 "$LOG_FILE"

# Fonction de logging dans fichier
log_to_file() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Écrire dans le fichier
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Aussi envoyer à syslog
    logger -p user.$level -t myapp "$message"
}

# Utilisation
log_to_file info "Application démarrée"
log_to_file error "Connexion base de données échouée"
log_to_file warning "Fichier de configuration manquant"
```

Et ajouter la rotation pour ce fichier :

```bash
# Créer /etc/logrotate.d/myapp
sudo nano /etc/logrotate.d/myapp

# Contenu :
/var/log/myapp.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 644 root root
}
```

> [!tip] Bonnes pratiques de logging dans les scripts
> 
> 1. **Toujours logger les événements importants** : démarrages, arrêts, erreurs
> 2. **Utiliser des tags cohérents** : même nom pour tous les logs d'un script
> 3. **Choisir le bon niveau** : ne pas tout logger en "error"
> 4. **Ajouter du contexte** : inclure des variables, IDs, timestamps
> 5. **Logger avant ET après** les opérations critiques
> 6. **Ne pas logger de données sensibles** : mots de passe, tokens, etc.
> 7. **Tester le logging** : vérifier que vos messages apparaissent bien

### Debugging : activer/désactiver le debug

```bash
#!/bin/bash

# Variable de contrôle du debug
DEBUG=${DEBUG:-0}  # Par défaut désactivé

debug() {
    if [ "$DEBUG" = "1" ]; then
        logger -p user.debug -t "$SCRIPT_NAME" "$1"
        echo "[DEBUG] $1"
    fi
}

log_info() {
    logger -p user.info -t "$SCRIPT_NAME" "$1"
    echo "[INFO] $1"
}

# Utilisation
debug "Début de la fonction process_data()"
log_info "Traitement des données"
debug "Variables: VAR1=$VAR1, VAR2=$VAR2"

# Lancer avec debug :
# DEBUG=1 ./monscript.sh

# Lancer sans debug :
# ./monscript.sh
```

---

## 🎯 Résumé et bonnes pratiques

### Récapitulatif des outils

|Besoin|Outil|Commande|
|---|---|---|
|Consulter logs système|Journalctl|`journalctl`|
|Suivre un log en temps réel|tail|`tail -f /var/log/syslog`|
|Chercher dans les logs|grep|`journalctl \| grep "error"`|
|Logger depuis un script|logger|`logger "Mon message"`|
|Configurer le logging|rsyslog|`/etc/rsyslog.conf`|
|Gérer la rotation|logrotate|`/etc/logrotate.d/`|
|Voir les logs d'un service|journalctl|`journalctl -u nginx.service`|

### Checklist des bonnes pratiques

> [!tip] Bonnes pratiques générales
> 
> **Consultation des logs :**
> 
> - ✅ Utilisez `journalctl` pour les systèmes modernes (systemd)
> - ✅ Filtrez par service, date, niveau de priorité pour gagner du temps
> - ✅ Utilisez `tail -F` (pas `-f`) pour suivre les logs avec rotation
> - ✅ Combinez grep avec des options de contexte (`-A`, `-B`, `-C`)
> 
> **Gestion de l'espace disque :**
> 
> - ✅ Configurez logrotate pour tous vos fichiers de logs personnalisés
> - ✅ Définissez des limites de taille et de durée appropriées
> - ✅ Surveillez régulièrement l'espace dans `/var/log/`
> - ✅ Utilisez la compression pour économiser de l'espace
> 
> **Logging applicatif :**
> 
> - ✅ Utilisez des tags cohérents et uniques pour vos applications
> - ✅ Choisissez le bon niveau de log (ne pas abuser de "error")
> - ✅ Ajoutez du contexte : IDs, variables, timestamps
> - ✅ Ne loggez JAMAIS de données sensibles (mots de passe, tokens)
> - ✅ Testez que vos logs apparaissent correctement
> 
> **Sécurité et audit :**
> 
> - ✅ Surveillez `/var/log/auth.log` pour les tentatives de connexion
> - ✅ Centralisez les logs critiques sur un serveur distant
> - ✅ Protégez l'accès aux fichiers de logs (permissions appropriées)
> - ✅ Archivez les logs importants pour conformité/audit

### Commandes essentielles à retenir

```bash
# Les 10 commandes les plus utiles au quotidien

# 1. Voir les logs en temps réel
journalctl -f

# 2. Logs d'un service spécifique
journalctl -u nginx.service

# 3. Erreurs système depuis aujourd'hui
journalctl --since today -p err

# 4. Suivre un fichier de log
tail -F /var/log/syslog

# 5. Chercher dans les logs
journalctl | grep "error"

# 6. Logger depuis la ligne de commande
logger -t myapp "Message de test"

# 7. Espace utilisé par les logs
journalctl --disk-usage

# 8. Nettoyer les vieux logs
sudo journalctl --vacuum-time=2weeks

# 9. Tester la rotation des logs
sudo logrotate -d /etc/logrotate.conf

# 10. Logs d'authentification
sudo tail -f /var/log/auth.log
```

> [!warning] Pièges à éviter
> 
> - ❌ Ne jamais supprimer `/var/log/` ou ses contenus à la main
> - ❌ Ne pas modifier les logs existants (intégrité)
> - ❌ Ne pas désactiver logrotate sans surveillance de l'espace
> - ❌ Ne pas logger des boucles infinies (saturation des logs)
> - ❌ Ne pas utiliser `tail -f` sur des logs avec rotation (utiliser `-F`)
> - ❌ Ne pas oublier de recharger rsyslog après modification de config
> - ❌ Ne pas ignorer les erreurs dans auth.log (sécurité)

---

## 📚 Cas d'usage pratiques

### Scénario 1 : Diagnostiquer un service qui crash

```bash
# 1. Voir les logs récents du service
journalctl -u myservice.service -n 100

# 2. Voir les erreurs uniquement
journalctl -u myservice.service -p err --since today

# 3. Suivre en temps réel pendant un redémarrage
journalctl -u myservice.service -f

# 4. Vérifier le dernier crash
journalctl -u myservice.service --since "10 minutes ago"
```

### Scénario 2 : Analyser une intrusion

```bash
# 1. Tentatives de connexion SSH échouées
sudo grep "Failed password" /var/log/auth.log

# 2. Connexions réussies récentes
sudo grep "Accepted password" /var/log/auth.log

# 3. Avec journalctl
journalctl -u ssh.service | grep "Failed password"

# 4. Voir les IPs qui tentent de se connecter
sudo grep "Failed password" /var/log/auth.log | \
  awk '{print $(NF-3)}' | sort | uniq -c | sort -rn
```

### Scénario 3 : Suivre une application web

```bash
# Suivre access.log et error.log simultanément
tail -f /var/log/nginx/access.log /var/log/nginx/error.log

# Filtrer les erreurs 500
tail -f /var/log/nginx/access.log | grep " 500 "

# Compter les requêtes par seconde
tail -f /var/log/nginx/access.log | \
  awk '{print strftime("%H:%M:%S")}' | uniq -c
```

### Scénario 4 : Debug d'un script batch

```bash
# 1. Script avec logging complet
#!/bin/bash
SCRIPT="batch_processor"
logger -t $SCRIPT "Démarrage du traitement"

for file in /data/*.txt; do
    logger -t $SCRIPT "Traitement de $file"
    
    if process_file "$file"; then
        logger -p user.info -t $SCRIPT "✓ $file traité avec succès"
    else
        logger -p user.err -t $SCRIPT "✗ Échec sur $file"
    fi
done

logger -t $SCRIPT "Traitement terminé"

# 2. Suivre l'exécution
journalctl -t batch_processor -f

# 3. Voir seulement les échecs
journalctl -t batch_processor -p err
```

---

🎉 **Félicitations !** Vous maîtrisez maintenant les logs système Linux. Vous savez où les trouver, comment les consulter, les filtrer, les gérer, et même logger depuis vos propres scripts. Les logs n'ont plus de secrets pour vous !