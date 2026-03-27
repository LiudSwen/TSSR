

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

## 🔧 Vérification de l'état des services

### Pourquoi surveiller les services ?

La surveillance des services est essentielle pour garantir la disponibilité et les performances de votre serveur LAMP. Un service arrêté ou dysfonctionnel peut rendre votre site web inaccessible ou compromettre la sécurité de votre infrastructure.

### Commandes systemctl pour la gestion des services

**systemctl** est l'outil principal pour gérer les services sous systemd (utilisé par la plupart des distributions Linux modernes).

#### Vérifier l'état d'un service

```bash
# Syntaxe générale
systemctl status <nom_du_service>

# Exemples pour les services LAMP
systemctl status apache2      # Apache sur Debian/Ubuntu
systemctl status httpd         # Apache sur RedHat/CentOS
systemctl status mysql         # MySQL/MariaDB
systemctl status mariadb       # MariaDB
systemctl status php8.2-fpm    # PHP-FPM (version 8.2)
```

> [!example] Exemple de sortie
> 
> ```
> ● apache2.service - The Apache HTTP Server
>    Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
>    Active: active (running) since Mon 2024-12-22 10:30:15 CET; 2h 15min ago
>      Docs: https://httpd.apache.org/docs/2.4/
>  Main PID: 1234 (apache2)
>     Tasks: 55 (limit: 4915)
>    Memory: 12.5M
>       CPU: 5.234s
>    CGroup: /system.slice/apache2.service
> ```

#### Interpréter l'état d'un service

|État|Signification|Action requise|
|---|---|---|
|`active (running)`|Service démarré et fonctionnel|✅ Aucune|
|`active (exited)`|Service démarré mais sans processus actif|⚠️ Vérifier si c'est normal|
|`inactive (dead)`|Service arrêté|❌ Démarrer le service|
|`failed`|Service en échec|❌ Investiguer les logs|
|`activating (start)`|Service en cours de démarrage|⏳ Attendre|

#### Vérifier si un service est activé au démarrage

```bash
# Vérifier si le service démarre automatiquement
systemctl is-enabled apache2

# Sorties possibles :
# enabled  - démarre automatiquement
# disabled - ne démarre pas automatiquement
# static   - pas de configuration d'activation
```

#### Lister tous les services

```bash
# Tous les services
systemctl list-units --type=service

# Seulement les services actifs
systemctl list-units --type=service --state=active

# Seulement les services en échec
systemctl list-units --type=service --state=failed

# Avec filtrage pour LAMP
systemctl list-units --type=service | grep -E 'apache|httpd|mysql|mariadb|php'
```

> [!tip] Astuce de productivité Créez un alias dans votre `.bashrc` pour surveiller rapidement vos services LAMP :
> 
> ```bash
> alias lamp-status='systemctl status apache2 mysql php8.2-fpm'
> ```

### Commandes service (anciennes distributions)

Sur les systèmes utilisant encore init.d (anciennes versions) :

```bash
# Vérifier l'état
service apache2 status
service mysql status

# Lister tous les services
service --status-all

# Sortie :
# [ + ]  apache2    (en cours d'exécution)
# [ - ]  mysql      (arrêté)
# [ ? ]  php-fpm    (état inconnu)
```

> [!warning] Compatibilité `service` fonctionne encore sur les systèmes modernes mais utilise systemd en arrière-plan. Privilégiez `systemctl` pour bénéficier de toutes les fonctionnalités.

### Vérifications avancées

#### Temps de fonctionnement (uptime) d'un service

```bash
# Voir depuis combien de temps le service tourne
systemctl show apache2 --property=ActiveEnterTimestamp

# Ou via status avec grep
systemctl status apache2 | grep "Active:"
```

#### Dépendances de services

```bash
# Services dont dépend Apache
systemctl list-dependencies apache2

# Services qui dépendent d'Apache
systemctl list-dependencies apache2 --reverse
```

> [!info] Cas d'usage Utile pour comprendre pourquoi un service ne démarre pas ou pour planifier l'ordre d'arrêt/démarrage lors de la maintenance.

---

## 🔬 Commandes de diagnostic

### netstat - Statistiques réseau

**netstat** affiche les connexions réseau, les tables de routage, les statistiques d'interface et plus encore.

> [!warning] Obsolescence `netstat` est considéré comme obsolète sur les systèmes modernes. Utilisez plutôt `ss` (voir section suivante). Cependant, `netstat` reste présent sur de nombreux systèmes.

#### Installation

```bash
# Debian/Ubuntu
sudo apt install net-tools

# RedHat/CentOS
sudo yum install net-tools
```

#### Syntaxe de base

```bash
netstat [options]
```

#### Options principales

|Option|Description|Exemple d'utilisation|
|---|---|---|
|`-t`|Connexions TCP|Voir les connexions web|
|`-u`|Connexions UDP|Diagnostics DNS|
|`-l`|Sockets en écoute|Ports ouverts|
|`-n`|Affichage numérique|Éviter la résolution DNS|
|`-p`|PID et nom du programme|Identifier l'application|
|`-a`|Toutes les connexions|Vue d'ensemble|
|`-r`|Table de routage|Diagnostics réseau|
|`-s`|Statistiques|Analyse de performance|

#### Exemples pratiques pour LAMP

```bash
# Voir tous les ports en écoute (TCP)
netstat -tlnp

# Exemple de sortie :
# Proto Recv-Q Send-Q Local Address   Foreign Address   State    PID/Program
# tcp        0      0 0.0.0.0:80      0.0.0.0:*         LISTEN   1234/apache2
# tcp        0      0 0.0.0.0:443     0.0.0.0:*         LISTEN   1234/apache2
# tcp        0      0 127.0.0.1:3306  0.0.0.0:*         LISTEN   5678/mysqld

# Vérifier qu'Apache écoute sur le port 80
netstat -tlnp | grep :80

# Voir toutes les connexions actives vers Apache
netstat -tnp | grep apache2

# Compter le nombre de connexions HTTP actives
netstat -tn | grep :80 | wc -l

# Voir les connexions MySQL
netstat -tnp | grep :3306

# Afficher les statistiques réseau
netstat -s

# Voir les connexions établies (ESTABLISHED)
netstat -tn | grep ESTABLISHED
```

> [!example] Diagnostic de charge Si vous constatez des lenteurs :
> 
> ```bash
> # Compter les connexions par état
> netstat -tn | awk '{print $6}' | sort | uniq -c | sort -rn
> 
> # Résultat exemple :
> #   150 ESTABLISHED
> #    45 TIME_WAIT
> #    12 SYN_RECV
> #     3 CLOSE_WAIT
> ```

#### Interpréter les états de connexion

|État|Signification|Implication|
|---|---|---|
|`LISTEN`|Socket en écoute|Service prêt à accepter des connexions|
|`ESTABLISHED`|Connexion active|Client connecté|
|`TIME_WAIT`|Fermeture en cours|Connexion récemment fermée|
|`CLOSE_WAIT`|Attente de fermeture|Application n'a pas fermé proprement|
|`SYN_RECV`|Réception de demande|Nouvelle connexion en cours|

> [!warning] Attention aux TIME_WAIT Un nombre élevé de connexions en `TIME_WAIT` est normal après un pic de trafic. Cependant, un nombre anormalement élevé peut indiquer un problème de configuration TCP ou une attaque DDoS.

### ss - Socket Statistics

**ss** est le remplaçant moderne de netstat, plus rapide et plus puissant.

#### Avantages de ss

- ⚡ Plus rapide que netstat
- 📊 Plus d'informations disponibles
- 🔧 Filtrage avancé intégré
- 📦 Installé par défaut sur les distributions récentes

#### Syntaxe de base

```bash
ss [options] [filter]
```

#### Options principales

```bash
# Équivalent à netstat -tlnp
ss -tlnp

# Options courantes :
# -t : TCP
# -u : UDP
# -l : En écoute (listening)
# -n : Numérique (pas de résolution DNS)
# -p : Processus
# -a : Toutes les connexions
# -s : Statistiques résumées
# -4 : IPv4 uniquement
# -6 : IPv6 uniquement
```

#### Exemples pratiques pour LAMP

```bash
# Ports en écoute (équivalent netstat -tlnp)
ss -tlnp

# Exemple de sortie :
# State  Recv-Q Send-Q Local Address:Port  Peer Address:Port Process
# LISTEN 0      128    0.0.0.0:80           0.0.0.0:*     users:(("apache2",pid=1234))
# LISTEN 0      80     127.0.0.1:3306       0.0.0.0:*     users:(("mysqld",pid=5678))

# Connexions actives vers le port 80
ss -tn dst :80

# Connexions établies avec Apache
ss -tn state established '( dport = :80 or sport = :80 )'

# Compter les connexions par état
ss -tan | awk '{print $1}' | sort | uniq -c

# Voir toutes les connexions MySQL
ss -tnp | grep :3306

# Statistiques résumées
ss -s
```

> [!tip] Filtrage avancé avec ss `ss` permet des filtres très puissants :
> 
> ```bash
> # Connexions vers le port 80 ou 443
> ss -tn '( dport = :80 or dport = :443 )'
> 
> # Connexions depuis une IP spécifique
> ss -tn src 192.168.1.100
> 
> # Connexions avec plus de 100 octets en attente
> ss -tn state established 'recv-q > 100'
> ```

#### Surveillance en temps réel

```bash
# Rafraîchir toutes les 2 secondes
watch -n 2 'ss -s'

# Surveiller les connexions Apache
watch -n 1 'ss -tn dst :80 | wc -l'

# Surveiller les états de connexion
watch -n 1 'ss -tan | awk "{print \$1}" | sort | uniq -c'
```

### ps - Process Status

**ps** affiche les processus en cours d'exécution sur le système.

#### Syntaxe de base

```bash
ps [options]
```

#### Styles de syntaxe

> [!info] Trois styles disponibles
> 
> - **UNIX** : options précédées d'un tiret (`-`)
> - **BSD** : options sans tiret
> - **GNU** : options longues précédées de deux tirets (`--`)

#### Options essentielles

```bash
# Tous les processus (style BSD)
ps aux

# Tous les processus (style UNIX)
ps -ef

# Format personnalisé
ps -eo pid,user,comm,%cpu,%mem,stat,start,time

# Options utiles :
# a : Tous les utilisateurs
# u : Format orienté utilisateur
# x : Inclut les processus sans terminal
# f : Format arbre complet
# -e : Tous les processus
# -f : Format complet
```

#### Exemples pratiques pour LAMP

```bash
# Processus Apache
ps aux | grep apache2

# Processus MySQL
ps aux | grep mysql

# Processus PHP-FPM
ps aux | grep php-fpm

# Compter les processus Apache
ps aux | grep apache2 | wc -l

# Voir l'arborescence des processus Apache
ps auxf | grep apache2

# Processus triés par utilisation CPU
ps aux --sort=-%cpu | head -10

# Processus triés par utilisation mémoire
ps aux --sort=-%mem | head -10

# Voir les threads d'un processus
ps -eLf | grep apache2

# Format personnalisé pour LAMP
ps -eo pid,user,comm,%cpu,%mem,vsz,rss,stat,start,time | grep -E 'apache|mysql|php'
```

> [!example] Analyse de performance
> 
> ```bash
> # Identifier les processus Apache gourmands
> ps aux --sort=-%cpu | grep apache2 | head -5
> 
> # Résultat exemple :
> # USER   PID  %CPU %MEM    VSZ   RSS TTY   STAT START TIME COMMAND
> # www-data 12345 5.2 2.1 245680 87432 ? S  10:30 0:12 /usr/sbin/apache2
> # www-data 12346 3.8 1.9 242156 79124 ? S  10:31 0:08 /usr/sbin/apache2
> ```

#### Colonnes importantes

|Colonne|Description|Importance pour LAMP|
|---|---|---|
|`PID`|Process ID|Identification unique du processus|
|`%CPU`|Utilisation CPU|Performance et détection de boucles|
|`%MEM`|Utilisation mémoire|Détection de fuites mémoire|
|`VSZ`|Mémoire virtuelle (Ko)|Taille totale en mémoire virtuelle|
|`RSS`|Mémoire résidente (Ko)|Mémoire physique réellement utilisée|
|`STAT`|État du processus|Diagnostic de blocage|
|`TIME`|Temps CPU cumulé|Analyse d'utilisation|
|`START`|Heure de démarrage|Durée de vie du processus|

#### États de processus (STAT)

|Code|Signification|Implications|
|---|---|---|
|`R`|Running (en cours)|Processus actif|
|`S`|Sleeping (interruptible)|Normal, en attente|
|`D`|Uninterruptible sleep|Attente I/O (disque/réseau)|
|`Z`|Zombie|Processus terminé non nettoyé|
|`T`|Stopped|Processus arrêté/suspendu|
|`<`|Haute priorité|Processus prioritaire|
|`N`|Basse priorité|Nice positif|
|`s`|Leader de session|Processus principal|
|`+`|Au premier plan|Groupe de processus foreground|

> [!warning] Processus zombies Des processus zombies (`Z`) indiquent que le processus parent ne nettoie pas correctement. Si vous en voyez beaucoup, redémarrez le service concerné.

#### Surveillance continue

```bash
# top : surveillance interactive
top

# Touches utiles dans top :
# P - trier par CPU
# M - trier par mémoire
# k - tuer un processus
# 1 - afficher tous les CPU
# q - quitter

# htop : version améliorée (nécessite installation)
htop

# Surveillance Apache avec top
top -p $(pgrep -d',' apache2)
```

### Comparaison des outils de diagnostic

|Outil|Usage principal|Avantage|Inconvénient|
|---|---|---|---|
|`netstat`|Connexions réseau|Familier, documentation abondante|Obsolète, lent|
|`ss`|Connexions réseau|Rapide, filtrage puissant|Syntaxe moins intuitive|
|`ps`|Processus système|Polyvalent, personnalisable|Statique (snapshot)|
|`top`/`htop`|Surveillance temps réel|Interactif, visuel|Console uniquement|

---

## 💾 Surveillance de l'espace disque

### Pourquoi surveiller l'espace disque ?

Un manque d'espace disque peut avoir des conséquences graves :

- ❌ **Base de données** : Impossibilité d'écrire, corruption de données
- ❌ **Apache** : Impossibilité d'écrire les logs, erreurs 500
- ❌ **PHP** : Sessions perdues, uploads échoués
- ❌ **Système** : Blocage complet si la partition racine est pleine

> [!warning] Seuils critiques
> 
> - **80%** : Commencer à investiguer
> - **90%** : Action requise rapidement
> - **95%** : Critique, risque imminent
> - **100%** : Problèmes garantis

### df - Disk Free

**df** affiche l'espace disque disponible sur les systèmes de fichiers.

#### Syntaxe de base

```bash
df [options] [filesystem]
```

#### Options principales

```bash
# Affichage lisible (human-readable)
df -h

# Exemple de sortie :
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        50G   35G   13G  73% /
# /dev/sda2       200G  150G   40G  79% /var
# tmpfs           7.8G  1.2M  7.8G   1% /tmp

# Afficher le type de système de fichiers
df -T

# Afficher les inodes (nombre de fichiers)
df -i

# Exclure certains types de systèmes de fichiers
df -h -x tmpfs -x devtmpfs

# Afficher un système de fichiers spécifique
df -h /var
```

#### Options utiles

|Option|Description|Usage|
|---|---|---|
|`-h`|Format lisible (Ko, Mo, Go)|Usage courant|
|`-H`|Format lisible (puissances de 1000)|Standards SI|
|`-T`|Afficher le type de FS|Diagnostic|
|`-i`|Informations sur les inodes|Problèmes avec beaucoup de petits fichiers|
|`-x type`|Exclure un type|Filtrer les FS virtuels|
|`--total`|Ajouter une ligne de total|Vue d'ensemble|

#### Exemples pratiques pour LAMP

```bash
# Vue d'ensemble simple
df -h

# Surveiller les partitions importantes
df -h / /var /home

# Vérifier les inodes (important pour les logs)
df -ih

# Vue complète avec totaux
df -h --total

# Surveiller spécifiquement /var (logs Apache, MySQL)
df -h /var

# Alerter si une partition dépasse 80%
df -h | awk '$5+0 > 80 {print $0}'

# Format personnalisé pour monitoring
df -h --output=source,size,used,avail,pcent,target
```

> [!example] Script de surveillance
> 
> ```bash
> #!/bin/bash
> # Alerter si une partition dépasse 85%
> 
> df -h | awk '$5+0 > 85 {
>   print "⚠️  ALERTE : " $6 " est à " $5 " d'\''utilisation"
>   print "   Espace utilisé : " $3 " / " $2
> }'
> ```

#### Problème d'inodes

```bash
# Vérifier les inodes
df -i

# Si les inodes sont pleins mais pas l'espace :
# Trouver les répertoires avec beaucoup de fichiers
find /var -xdev -type d -exec sh -c 'echo "{} : $(find "{}" -maxdepth 1 | wc -l)"' \; | sort -t: -k2 -rn | head -20

# Cas typique : logs fragmentés ou sessions PHP
ls -1 /var/lib/php/sessions | wc -l
ls -1 /var/log | wc -l
```

> [!tip] Astuce inodes Les inodes peuvent être épuisés avant l'espace disque si vous avez beaucoup de petits fichiers (logs, sessions, cache). C'est un problème courant avec les sessions PHP non nettoyées.

### du - Disk Usage

**du** estime l'utilisation de l'espace disque par fichiers et répertoires.

#### Syntaxe de base

```bash
du [options] [path]
```

#### Options principales

```bash
# Affichage lisible
du -h /var/log

# Résumé d'un répertoire
du -sh /var/log

# Afficher un niveau de profondeur
du -h --max-depth=1 /var

# Trier par taille
du -h /var/log | sort -rh

# Exclure certains fichiers
du -h --exclude='*.gz' /var/log
```

#### Options utiles

|Option|Description|Usage|
|---|---|---|
|`-h`|Format lisible|Usage courant|
|`-s`|Résumé seulement|Taille totale|
|`-c`|Afficher un total|Somme finale|
|`--max-depth=N`|Limiter la profondeur|Éviter trop de détails|
|`-x`|Rester sur une partition|Éviter les montages|
|`--exclude=PATTERN`|Exclure des fichiers|Filtrage|
|`-a`|Tous les fichiers|Inclure les fichiers|

#### Exemples pratiques pour LAMP

```bash
# Trouver les 10 plus gros répertoires dans /var
du -h --max-depth=1 /var | sort -rh | head -10

# Taille des logs Apache
du -sh /var/log/apache2

# Taille des bases MySQL
du -sh /var/lib/mysql

# Détail des bases MySQL
du -h --max-depth=1 /var/lib/mysql | sort -rh

# Trouver les plus gros fichiers de logs
find /var/log -type f -exec du -h {} + | sort -rh | head -20

# Taille des uploads PHP
du -sh /var/www/html/uploads

# Analyser un site web spécifique
du -h --max-depth=2 /var/www/html | sort -rh | head -20

# Voir la croissance des logs en temps réel
watch -n 5 'du -sh /var/log/apache2/*'

# Comparer la taille avant/après compression
du -sh /var/log/apache2/*.log
du -sh /var/log/apache2/*.log.gz
```

> [!example] Trouver les gros consommateurs
> 
> ```bash
> # Top 10 des répertoires dans /var
> du -h --max-depth=1 /var 2>/dev/null | sort -rh | head -10
> 
> # Résultat exemple :
> # 15G     /var/lib
> # 8.2G    /var/log
> # 3.5G    /var/cache
> # 2.1G    /var/www
> ```

#### Analyse approfondie

```bash
# Trouver les fichiers de plus de 100 Mo
find /var -type f -size +100M -exec du -h {} + | sort -rh

# Fichiers modifiés dans les dernières 24h
find /var/log -type f -mtime -1 -exec du -h {} + | sort -rh

# Analyse complète avec statistiques
du -h /var/log/apache2 | awk '{sum+=$1} END {print "Total: " sum}'

# Comparer deux répertoires
diff <(du -h /var/log | sort) <(du -h /var/log.old | sort)
```

### ncdu - NCurses Disk Usage

**ncdu** est une version interactive et visuelle de `du`.

#### Installation

```bash
# Debian/Ubuntu
sudo apt install ncdu

# RedHat/CentOS
sudo yum install ncdu
```

#### Utilisation

```bash
# Analyser un répertoire
ncdu /var

# Navigation dans ncdu :
# ↑↓    - naviguer
# Enter - entrer dans un répertoire
# d     - supprimer un fichier/répertoire
# g     - afficher en pourcentage
# n     - trier par nom
# s     - trier par taille
# q     - quitter
```

> [!tip] Avantage de ncdu `ncdu` permet une navigation interactive et peut supprimer des fichiers directement. Parfait pour nettoyer rapidement les gros fichiers.

### Automatisation de la surveillance

#### Script de surveillance quotidien

```bash
#!/bin/bash
# Surveillance espace disque pour serveur LAMP

THRESHOLD=85
EMAIL="admin@example.com"

# Vérifier chaque partition
df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print $5 " " $6}' | while read output;
do
  usage=$(echo $output | awk '{print $1}' | sed 's/%//g')
  partition=$(echo $output | awk '{print $2}')
  
  if [ $usage -ge $THRESHOLD ]; then
    echo "⚠️  ALERTE : $partition est à ${usage}% d'utilisation" | mail -s "Alerte espace disque" $EMAIL
  fi
done

# Vérifier les gros fichiers de logs
find /var/log -type f -size +500M -exec ls -lh {} \; | mail -s "Gros fichiers de logs" $EMAIL

# Rapport quotidien
{
  echo "=== Rapport espace disque $(date) ==="
  echo ""
  df -h
  echo ""
  echo "=== Top 10 répertoires /var ==="
  du -h --max-depth=1 /var | sort -rh | head -10
} | mail -s "Rapport quotidien espace disque" $EMAIL
```

#### Surveillance avec monitoring système

```bash
# Installer monitoring (exemple avec Monit)
sudo apt install monit

# Configuration Monit pour l'espace disque
# /etc/monit/conf.d/filesystem.conf
check filesystem rootfs with path /
  if space usage > 85% then alert
  if space usage > 90% for 5 cycles then exec "/usr/local/bin/cleanup.sh"

check filesystem varfs with path /var
  if space usage > 85% then alert
```

### Nettoyage et libération d'espace

#### Logs Apache

```bash
# Compresser les anciens logs
find /var/log/apache2 -name "*.log" -type f -mtime +7 -exec gzip {} \;

# Supprimer les logs compressés de plus de 30 jours
find /var/log/apache2 -name "*.gz" -type f -mtime +30 -delete

# Rotation manuelle si logrotate n'est pas configuré
logrotate -f /etc/logrotate.d/apache2
```

#### Logs MySQL

```bash
# Vérifier les binary logs
ls -lh /var/lib/mysql/mysql-bin.*

# Purger les binary logs de plus de 3 jours
mysql -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 3 DAY);"

# Vérifier l'espace libéré
du -sh /var/lib/mysql
```

#### Cache et fichiers temporaires

```bash
# Nettoyer le cache apt
sudo apt clean

# Supprimer les paquets orphelins
sudo apt autoremove

# Nettoyer les fichiers temporaires PHP (sessions)
find /var/lib/php/sessions -type f -mtime +1 -delete

# Nettoyer les fichiers temporaires système
sudo find /tmp -type f -atime +7 -delete
```

> [!warning] Précaution Avant de supprimer des fichiers, **vérifiez toujours** qu'ils ne sont pas nécessaires. Faites des sauvegardes des fichiers de logs importants avant nettoyage.

### Bonnes pratiques

1. **Surveillance proactive**
    
    - Monitorer quotidiennement avec `df -h`
    - Configurer des alertes à 85% d'utilisation
    - Surveiller aussi les inodes (`df -i`)
2. **Rotation des logs**
    
    - Configurer logrotate correctement
    - Compresser les anciens logs
    - Définir une politique de rétention claire
3. **Partitionnement intelligent**
    
    - Séparer `/var` sur une partition dédiée
    - Isoler `/var/log` si possible
    - Prévoir de l'espace pour la croissance
4. **Nettoyage régulier**
    
    - Automatiser le nettoyage avec cron
    - Purger régulièrement les binary logs MySQL
    - Nettoyer les sessions PHP expirées
5. **Documentation**
    
    - Noter la croissance mensuelle
    - Identifier les tendances
    - Planifier l'extension de stockage à l'avance

---

## 🎯 Pièges courants et solutions

### Piège 1 : Négliger les inodes

**Problème** : L'espace disque est disponible mais impossible de créer de nouveaux fichiers.

```bash
# Vérifier les inodes
df -i

# Nettoyer si saturé
find /var/lib/php/sessions -type f -delete
```

### Piège 2 : Processus zombies ignorés

**Problème** : Accumulation de processus zombies qui consomment des ressources.

```bash
# Identifier les zombies
ps aux | grep 'Z'

# Solution : redémarrer le service parent
systemctl restart apache2
```

### Piège 3 : Ignorer les connexions TIME_WAIT

**Problème** : Trop de connexions en `TIME_WAIT` peuvent épuiser les ports disponibles.

```bash
# Vérifier le nombre de TIME_WAIT
ss -tan | grep TIME_WAIT | wc -l

# Ajuster les paramètres kernel si nécessaire
echo "net.ipv4.tcp_fin_timeout = 30" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Piège 4 : Services qui redémarrent en boucle

**Problème** : Un service crashe et redémarre constamment sans être détecté.

```bash
# Vérifier l'historique des redémarrages
journalctl -u apache2 --since "1 hour ago" | grep -i restart

# Voir les échecs récents
systemctl list-units --failed

# Analyser les logs
journalctl -u apache2 -n 100 --no-pager
```

### Piège 5 : Ne pas surveiller la croissance des logs

**Problème** : Les logs remplissent le disque progressivement.

```bash
# Surveiller la croissance en temps réel
watch -n 60 'du -sh /var/log/apache2'

# Automatiser avec cron
0 0 * * * find /var/log/apache2 -name "*.log" -mtime +7 -exec gzip {} \;
```

### Piège 6 : Oublier les bases de données temporaires

**Problème** : Les tables temporaires MySQL consomment de l'espace.

```bash
# Vérifier les tables temporaires
du -sh /var/lib/mysql/tmp

# Nettoyer si nécessaire
mysql -e "SHOW GLOBAL STATUS LIKE 'Created_tmp%';"
```

### Piège 7 : Confusion entre VSZ et RSS

**Problème** : Interpréter incorrectement l'utilisation mémoire.

```bash
# VSZ = mémoire virtuelle (peut être partagée)
# RSS = mémoire physique réellement utilisée

# Voir la mémoire réelle d'Apache
ps aux | grep apache2 | awk '{sum+=$6} END {print sum/1024 " MB"}'
```

---

## 💡 Astuces professionnelles

### 1. Créer un dashboard de surveillance rapide

```bash
#!/bin/bash
# dashboard-lamp.sh - Vue d'ensemble LAMP

clear
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║            🖥️  DASHBOARD SERVEUR LAMP                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Services
echo "📊 ÉTAT DES SERVICES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
systemctl is-active apache2 >/dev/null 2>&1 && echo "✅ Apache  : ACTIF" || echo "❌ Apache  : ARRÊTÉ"
systemctl is-active mysql >/dev/null 2>&1 && echo "✅ MySQL   : ACTIF" || echo "❌ MySQL   : ARRÊTÉ"
systemctl is-active php8.2-fpm >/dev/null 2>&1 && echo "✅ PHP-FPM : ACTIF" || echo "❌ PHP-FPM : ARRÊTÉ"
echo ""

# Connexions
echo "🌐 CONNEXIONS RÉSEAU"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Port 80  : $(ss -tn dst :80 | wc -l) connexions"
echo "Port 443 : $(ss -tn dst :443 | wc -l) connexions"
echo "Port 3306: $(ss -tn dst :3306 | wc -l) connexions"
echo ""

# Processus
echo "⚙️  PROCESSUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Apache : $(pgrep -c apache2) processus"
echo "MySQL  : $(pgrep -c mysqld) processus"
echo "PHP    : $(pgrep -c php-fpm) processus"
echo ""

# Espace disque
echo "💾 ESPACE DISQUE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
df -h / /var | tail -n +2 | awk '{printf "%-15s : %5s utilisé sur %5s (%s)\n", $6, $3, $2, $5}'
echo ""

# Top processus CPU
echo "🔥 TOP 3 PROCESSUS CPU"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ps aux --sort=-%cpu | head -4 | tail -3 | awk '{printf "%5s %5s %s\n", $3, $4, $11}'
echo ""

# Top processus Mémoire
echo "🧠 TOP 3 PROCESSUS MÉMOIRE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ps aux --sort=-%mem | head -4 | tail -3 | awk '{printf "%5s %5s %s\n", $3, $4, $11}'
echo ""

echo "Dernière mise à jour : $(date '+%Y-%m-%d %H:%M:%S')"
```

Utilisez-le avec `watch` pour un rafraîchissement automatique :

```bash
chmod +x dashboard-lamp.sh
watch -n 5 -c ./dashboard-lamp.sh
```

### 2. Alertes instantanées avec systemd

Configurez des alertes automatiques lorsqu'un service échoue :

```bash
# Créer un script d'alerte
sudo nano /usr/local/bin/alert-service.sh
```

```bash
#!/bin/bash
SERVICE=$1
STATUS=$(systemctl is-active $SERVICE)

if [ "$STATUS" != "active" ]; then
    echo "⚠️ ALERTE: $SERVICE est $STATUS" | mail -s "Service Down: $SERVICE" admin@example.com
    # Ou utiliser un webhook Slack/Discord
    # curl -X POST -H 'Content-type: application/json' --data '{"text":"Service Down: '$SERVICE'"}' YOUR_WEBHOOK_URL
fi
```

```bash
# Rendre exécutable
sudo chmod +x /usr/local/bin/alert-service.sh

# Configurer systemd pour appeler ce script
sudo systemctl edit apache2.service
```

Ajoutez dans l'override :

```ini
[Service]
ExecStopPost=/usr/local/bin/alert-service.sh apache2
```

### 3. Logs centralisés et rotation optimisée

```bash
# Configuration logrotate optimisée pour LAMP
# /etc/logrotate.d/lamp-optimized

/var/log/apache2/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 640 root adm
    sharedscripts
    postrotate
        if systemctl is-active apache2 > /dev/null; then
            systemctl reload apache2 > /dev/null
        fi
    endscript
    # Alerter si les logs dépassent 1GB avant rotation
    size 1G
    prerotate
        SIZE=$(du -m /var/log/apache2/access.log | cut -f1)
        if [ $SIZE -gt 1000 ]; then
            echo "⚠️ Log Apache > 1GB avant rotation" | logger -t logrotate
        fi
    endscript
}

/var/log/mysql/*.log {
    daily
    rotate 7
    missingok
    compress
    delaycompress
    notifempty
    create 640 mysql adm
    sharedscripts
    postrotate
        if test -x /usr/bin/mysqladmin && /usr/bin/mysqladmin ping &>/dev/null; then
            /usr/bin/mysqladmin flush-logs
        fi
    endscript
}
```

### 4. Monitoring avec des outils systèmes

```bash
# Installer glances - monitoring avancé
sudo apt install glances

# Lancer glances
glances

# Mode serveur pour monitoring distant
glances -w

# Connecter depuis un autre terminal
glances -c @IP_SERVER
```

### 5. Automatiser les vérifications avec cron

```bash
# Éditer crontab
crontab -e
```

Ajoutez ces tâches :

```bash
# Vérifier l'état des services toutes les 5 minutes
*/5 * * * * systemctl is-active apache2 mysql php8.2-fpm || /usr/local/bin/alert-service.sh

# Rapport d'espace disque quotidien à 8h
0 8 * * * df -h | mail -s "Rapport espace disque $(date +\%F)" admin@example.com

# Nettoyer les logs compressés de plus de 30 jours tous les dimanches
0 2 * * 0 find /var/log/apache2 -name "*.gz" -mtime +30 -delete

# Vérifier les processus zombies toutes les heures
0 * * * * [ $(ps aux | grep -c 'Z') -gt 5 ] && echo "Zombies détectés" | mail -s "Alerte Zombies" admin@example.com

# Statistiques de connexions toutes les heures
0 * * * * ss -s > /var/log/connection-stats-$(date +\%Y\%m\%d-\%H00).log
```

### 6. Créer des alias pratiques

Ajoutez dans `~/.bashrc` ou `~/.bash_aliases` :

```bash
# Surveillance LAMP
alias lamp-status='systemctl status apache2 mysql php8.2-fpm'
alias lamp-restart='sudo systemctl restart apache2 mysql php8.2-fpm'
alias lamp-logs='sudo tail -f /var/log/apache2/error.log /var/log/mysql/error.log'

# Connexions réseau
alias conn80='ss -tn dst :80'
alias conn443='ss -tn dst :443'
alias conn-count='ss -tan | awk "{print \$1}" | sort | uniq -c | sort -rn'

# Espace disque
alias disk-usage='df -h | grep -vE "tmpfs|udev"'
alias big-files='du -ah /var | sort -rh | head -20'
alias log-size='du -sh /var/log/*'

# Processus
alias apache-procs='ps aux | grep apache2'
alias mysql-procs='ps aux | grep mysql'
alias top-cpu='ps aux --sort=-%cpu | head -10'
alias top-mem='ps aux --sort=-%mem | head -10'

# Nettoyage rapide
alias clean-logs='sudo find /var/log -name "*.log" -mtime +7 -exec gzip {} \;'
alias clean-tmp='sudo find /tmp -type f -atime +7 -delete'
```

Rechargez le fichier :

```bash
source ~/.bashrc
```

### 7. Script de diagnostic complet

```bash
#!/bin/bash
# lamp-diagnostic.sh - Diagnostic complet du serveur LAMP

OUTPUT="/tmp/lamp-diagnostic-$(date +%Y%m%d-%H%M%S).txt"

{
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║       DIAGNOSTIC COMPLET SERVEUR LAMP - $(date)      ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "========== INFORMATIONS SYSTÈME =========="
    uname -a
    echo ""
    uptime
    echo ""
    
    echo "========== ÉTAT DES SERVICES =========="
    systemctl status apache2 --no-pager
    echo ""
    systemctl status mysql --no-pager
    echo ""
    systemctl status php8.2-fpm --no-pager
    echo ""
    
    echo "========== CONNEXIONS RÉSEAU =========="
    echo "Ports en écoute :"
    ss -tlnp
    echo ""
    echo "Connexions actives HTTP :"
    ss -tn dst :80
    echo ""
    echo "Connexions actives HTTPS :"
    ss -tn dst :443
    echo ""
    echo "Statistiques réseau :"
    ss -s
    echo ""
    
    echo "========== PROCESSUS =========="
    echo "Top 10 CPU :"
    ps aux --sort=-%cpu | head -11
    echo ""
    echo "Top 10 Mémoire :"
    ps aux --sort=-%mem | head -11
    echo ""
    echo "Processus zombies :"
    ps aux | grep 'Z'
    echo ""
    
    echo "========== ESPACE DISQUE =========="
    df -h
    echo ""
    df -i
    echo ""
    echo "Gros répertoires dans /var :"
    du -h --max-depth=1 /var 2>/dev/null | sort -rh | head -10
    echo ""
    echo "Taille des logs :"
    du -sh /var/log/*
    echo ""
    
    echo "========== LOGS RÉCENTS =========="
    echo "Dernières erreurs Apache :"
    tail -20 /var/log/apache2/error.log
    echo ""
    echo "Dernières erreurs MySQL :"
    tail -20 /var/log/mysql/error.log 2>/dev/null
    echo ""
    
    echo "========== CONFIGURATION =========="
    echo "Version Apache :"
    apache2 -v
    echo ""
    echo "Version MySQL :"
    mysql --version
    echo ""
    echo "Version PHP :"
    php -v
    echo ""
    
    echo "========== FIN DU DIAGNOSTIC =========="
    
} | tee "$OUTPUT"

echo ""
echo "✅ Diagnostic enregistré dans : $OUTPUT"
echo "📧 Envoi du rapport par email..."
cat "$OUTPUT" | mail -s "Diagnostic LAMP $(hostname) - $(date +%Y-%m-%d)" admin@example.com
```

### 8. Monitoring proactif avec des seuils

```bash
#!/bin/bash
# lamp-monitor.sh - Monitoring avec alertes

# Seuils
CPU_THRESHOLD=80
MEM_THRESHOLD=85
DISK_THRESHOLD=85
CONN_THRESHOLD=500

# Vérifier CPU
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    echo "⚠️ CPU à ${CPU_USAGE}% (seuil: ${CPU_THRESHOLD}%)" | logger -t lamp-monitor
fi

# Vérifier mémoire
MEM_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}' | cut -d'.' -f1)
if [ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]; then
    echo "⚠️ Mémoire à ${MEM_USAGE}% (seuil: ${MEM_THRESHOLD}%)" | logger -t lamp-monitor
fi

# Vérifier disque
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "⚠️ Disque à ${DISK_USAGE}% (seuil: ${DISK_THRESHOLD}%)" | logger -t lamp-monitor
fi

# Vérifier connexions
CONN_COUNT=$(ss -tn dst :80 | wc -l)
if [ "$CONN_COUNT" -gt "$CONN_THRESHOLD" ]; then
    echo "⚠️ ${CONN_COUNT} connexions HTTP (seuil: ${CONN_THRESHOLD})" | logger -t lamp-monitor
fi

# Vérifier services
for SERVICE in apache2 mysql php8.2-fpm; do
    if ! systemctl is-active --quiet $SERVICE; then
        echo "❌ Service $SERVICE est arrêté !" | logger -t lamp-monitor -p user.crit
        systemctl restart $SERVICE
    fi
done
```

Ajoutez dans cron pour exécution toutes les 5 minutes :

```bash
*/5 * * * * /usr/local/bin/lamp-monitor.sh
```

---

## 📝 Récapitulatif des commandes essentielles

|Objectif|Commande|Usage|
|---|---|---|
|État service|`systemctl status <service>`|Vérification rapide|
|Ports en écoute|`ss -tlnp`|Voir les services réseau|
|Connexions actives|`ss -tn dst :80`|Trafic HTTP en temps réel|
|Processus actifs|`ps aux`|Vue d'ensemble système|
|Espace disque|`df -h`|Capacité disponible|
|Usage répertoire|`du -sh <path>`|Taille d'un dossier|
|Top CPU|`ps aux --sort=-%cpu \| head`|Gourmands CPU|
|Top Mémoire|`ps aux --sort=-%mem \| head`|Gourmands mémoire|
|Logs temps réel|`tail -f /var/log/apache2/error.log`|Suivi des erreurs|
|Surveillance interactive|`htop` ou `top`|Monitoring complet|

---

## ✅ Checklist de surveillance quotidienne

**Matin (5 minutes)** :

- [ ] Vérifier l'état des services : `systemctl status apache2 mysql php8.2-fpm`
- [ ] Consulter l'espace disque : `df -h`
- [ ] Vérifier les logs d'erreurs : `tail -50 /var/log/apache2/error.log`
- [ ] Observer la charge système : `uptime`

**Mi-journée (2 minutes)** :

- [ ] Nombre de connexions actives : `ss -s`
- [ ] Processus les plus gourmands : `top -bn1 | head -20`

**Soir (5 minutes)** :

- [ ] Comparer l'espace disque du matin
- [ ] Vérifier les processus zombies : `ps aux | grep Z`
- [ ] Analyser les pics de trafic dans les logs
- [ ] Planifier les nettoyages si nécessaire

**Hebdomadaire** :

- [ ] Rotation manuelle des logs si nécessaire
- [ ] Nettoyage des fichiers temporaires
- [ ] Analyse des tendances de croissance
- [ ] Mise à jour de la documentation

---

**🎓 Fin de la partie : Surveillance des services**

> [!success] Ce que vous maîtrisez maintenant
> 
> - ✅ Vérifier l'état et la santé des services LAMP
> - ✅ Utiliser les outils de diagnostic réseau (netstat, ss, ps)
> - ✅ Surveiller l'espace disque et identifier les problèmes
> - ✅ Automatiser la surveillance avec des scripts
> - ✅ Interpréter les métriques et agir en conséquence