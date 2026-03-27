
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

## 🗄️ Vérification de l'espace disque disponible {#espace-disque}

### Pourquoi surveiller l'espace disque ?

Un système de fichiers plein peut causer des problèmes critiques : impossibilité d'écrire des logs, échecs de mise à jour, corruption de données, plantage d'applications. La surveillance proactive permet d'éviter ces situations.

### La commande `df` - Disk Free

`df` affiche l'utilisation de l'espace disque pour tous les systèmes de fichiers montés.

```bash
# Affichage basique
df

# Format lisible par l'humain (recommandé)
df -h

# Afficher aussi les inodes
df -i

# Cibler un système de fichiers spécifique
df -h /var

# Exclure certains types de systèmes de fichiers
df -h -x tmpfs -x devtmpfs
```

> [!example] Exemple de sortie
> 
> ```
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/sda1        50G   35G   13G  74% /
> /dev/sda2       100G   80G   15G  85% /home
> /dev/sdb1       200G  150G   40G  79% /data
> ```

> [!info] Comprendre les colonnes
> 
> - **Filesystem** : Nom du périphérique ou partition
> - **Size** : Capacité totale
> - **Used** : Espace utilisé
> - **Avail** : Espace disponible
> - **Use%** : Pourcentage d'utilisation
> - **Mounted on** : Point de montage

### La commande `du` - Disk Usage

`du` permet d'analyser l'utilisation de l'espace par répertoire ou fichier.

```bash
# Taille d'un répertoire
du -sh /var/log

# Liste des sous-répertoires avec leurs tailles
du -h --max-depth=1 /var

# Trier par taille (nécessite un pipe vers sort)
du -h --max-depth=1 /var | sort -hr

# Trouver les 10 plus gros répertoires
du -h /home | sort -hr | head -10

# Afficher seulement le total
du -sh /home/*

# Exclure certains patterns
du -sh --exclude="*.log" /var
```

> [!tip] Astuce pour identifier rapidement les gros consommateurs
> 
> ```bash
> # Script one-liner très utile
> du -h --max-depth=1 / 2>/dev/null | sort -hr | head -20
> ```
> 
> Ceci affiche les 20 plus gros répertoires à la racine en ignorant les erreurs de permission.

### Surveillance automatisée de l'espace disque

```bash
# Vérifier si un système de fichiers dépasse 80%
df -h | awk '$5 > 80 {print $0}'

# Script de surveillance simple
#!/bin/bash
THRESHOLD=80
df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print $5 " " $6}' | while read output;
do
  usage=$(echo $output | awk '{print $1}' | sed 's/%//g')
  partition=$(echo $output | awk '{print $2}')
  if [ $usage -ge $THRESHOLD ]; then
    echo "ALERTE: Le point de montage $partition est à ${usage}%"
  fi
done
```

### Libérer de l'espace disque

```bash
# Nettoyer le cache APT (Debian/Ubuntu)
sudo apt clean
sudo apt autoclean

# Nettoyer le cache YUM/DNF (RedHat/CentOS)
sudo dnf clean all

# Supprimer les anciens kernels (Ubuntu)
sudo apt autoremove --purge

# Vider les logs systèmes anciens
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=500M

# Trouver et supprimer les fichiers temporaires anciens
find /tmp -type f -atime +7 -delete
```

> [!warning] Attention aux suppressions Ne jamais supprimer de fichiers système sans être certain de leur inutilité. Privilégiez les outils de nettoyage automatiques fournis par votre distribution.

---

## ⚙️ Vérification des services critiques {#services-critiques}

### Gestion des services avec `systemd`

La plupart des distributions Linux modernes utilisent `systemd` comme système d'initialisation et gestionnaire de services.

### Vérifier l'état d'un service

```bash
# Vérifier l'état d'un service
systemctl status nginx

# État condensé (running, failed, inactive...)
systemctl is-active nginx

# Vérifier si un service est activé au démarrage
systemctl is-enabled nginx

# Vérifier si un service a échoué
systemctl is-failed nginx
```

> [!example] Interprétation de la sortie de `systemctl status`
> 
> ```
> ● nginx.service - A high performance web server
>      Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
>      Active: active (running) since Mon 2024-01-15 10:23:45 UTC; 2 days ago
>    Main PID: 1234 (nginx)
>       Tasks: 5 (limit: 4915)
>      Memory: 12.3M
>         CPU: 2min 34.567s
>      CGroup: /system.slice/nginx.service
>              ├─1234 nginx: master process
>              └─1235 nginx: worker process
> ```
> 
> Points clés :
> 
> - **Loaded** : Le service est chargé et activé au démarrage
> - **Active** : État actuel (running = en cours d'exécution)
> - **Main PID** : Identifiant du processus principal
> - **Tasks/Memory/CPU** : Statistiques de ressources

### Lister et surveiller les services

```bash
# Lister tous les services
systemctl list-units --type=service

# Lister seulement les services actifs
systemctl list-units --type=service --state=running

# Lister les services en échec
systemctl list-units --type=service --state=failed

# Lister tous les services (actifs et inactifs)
systemctl list-unit-files --type=service

# Voir les dépendances d'un service
systemctl list-dependencies nginx
```

### Script de vérification des services critiques

```bash
#!/bin/bash
# Liste des services critiques à surveiller
CRITICAL_SERVICES=("nginx" "mysql" "ssh" "cron")

echo "=== Vérification des services critiques ==="
for service in "${CRITICAL_SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "✓ $service : Running"
    else
        echo "✗ $service : STOPPED ou FAILED"
        # Afficher les dernières lignes de log
        echo "  Derniers logs :"
        journalctl -u "$service" -n 5 --no-pager
    fi
done
```

### Analyser les échecs de services

```bash
# Voir pourquoi un service a échoué
systemctl status nginx --no-pager -l

# Voir les logs du service
journalctl -u nginx

# Logs depuis le dernier démarrage
journalctl -u nginx -b

# Suivre les logs en temps réel
journalctl -u nginx -f

# Logs avec priorité erreur ou supérieure
journalctl -u nginx -p err
```

> [!tip] Commandes de dépannage rapide
> 
> ```bash
> # Voir tous les services en échec avec leurs logs
> systemctl --failed
> 
> # Réinitialiser l'état "failed" après correction
> systemctl reset-failed
> 
> # Recharger la configuration systemd après modification
> systemctl daemon-reload
> ```

### Gestion avancée des services

```bash
# Activer un service au démarrage
sudo systemctl enable nginx

# Démarrer un service
sudo systemctl start nginx

# Redémarrer un service
sudo systemctl restart nginx

# Recharger la configuration sans redémarrage complet
sudo systemctl reload nginx

# Arrêter un service
sudo systemctl stop nginx

# Désactiver un service au démarrage
sudo systemctl disable nginx

# Masquer un service (empêcher tout démarrage)
sudo systemctl mask nginx

# Démasquer un service
sudo systemctl unmask nginx
```

> [!warning] Différence entre disable et mask
> 
> - **disable** : Le service ne démarre pas automatiquement mais peut être démarré manuellement
> - **mask** : Le service ne peut absolument pas être démarré, même manuellement (crée un lien symbolique vers /dev/null)

---

## 📜 Analyse des logs d'erreurs {#logs-erreurs}

### Architecture des logs sous Linux

Les logs système sont généralement stockés dans `/var/log/`. Les distributions modernes utilisent `journald` (partie de systemd) en complément ou remplacement des fichiers de logs traditionnels.

### Fichiers de logs importants

|Fichier de log|Description|
|---|---|
|`/var/log/syslog`|Log système général (Debian/Ubuntu)|
|`/var/log/messages`|Log système général (RedHat/CentOS)|
|`/var/log/auth.log`|Authentifications et sudo (Debian/Ubuntu)|
|`/var/log/secure`|Authentifications et sudo (RedHat/CentOS)|
|`/var/log/kern.log`|Messages du kernel|
|`/var/log/dmesg`|Messages de démarrage du kernel|
|`/var/log/boot.log`|Logs de démarrage système|
|`/var/log/apache2/`|Logs Apache (si installé)|
|`/var/log/nginx/`|Logs Nginx (si installé)|

### La commande `journalctl`

`journalctl` est l'outil principal pour consulter les logs de `systemd`.

```bash
# Afficher tous les logs
journalctl

# Logs depuis le dernier démarrage
journalctl -b

# Logs du démarrage précédent
journalctl -b -1

# Logs depuis une date
journalctl --since "2024-01-15 10:00:00"
journalctl --since "1 hour ago"
journalctl --since "yesterday"

# Logs jusqu'à une date
journalctl --until "2024-01-15 12:00:00"

# Combiner since et until
journalctl --since "09:00" --until "12:00"

# Suivre les logs en temps réel
journalctl -f

# Logs d'un service spécifique
journalctl -u nginx

# Logs avec priorité spécifique
journalctl -p err      # Erreurs uniquement
journalctl -p warning  # Warnings et supérieur

# Afficher les logs inversés (plus récents en premier)
journalctl -r

# Limiter le nombre de lignes
journalctl -n 50

# Format de sortie
journalctl -o json           # Format JSON
journalctl -o json-pretty    # JSON indenté
journalctl -o verbose        # Maximum de détails
```

> [!info] Niveaux de priorité des logs De la plus haute à la plus basse :
> 
> - **emerg** (0) : Système inutilisable
> - **alert** (1) : Action immédiate requise
> - **crit** (2) : Conditions critiques
> - **err** (3) : Erreurs
> - **warning** (4) : Avertissements
> - **notice** (5) : Normal mais significatif
> - **info** (6) : Informatif
> - **debug** (7) : Messages de débogage

### Filtrer et rechercher dans les logs

```bash
# Rechercher un pattern
journalctl | grep "error"

# Logs d'un processus spécifique par PID
journalctl _PID=1234

# Logs d'un exécutable spécifique
journalctl /usr/bin/nginx

# Logs générés par un utilisateur
journalctl _UID=1000

# Combiner plusieurs filtres
journalctl -u nginx -p err --since "1 hour ago"

# Logs du kernel uniquement
journalctl -k
journalctl --dmesg
```

### Analyser les fichiers de logs traditionnels

```bash
# Voir les dernières lignes d'un log
tail /var/log/syslog

# Suivre un log en temps réel
tail -f /var/log/syslog

# Voir les premières lignes
head /var/log/syslog

# Rechercher dans les logs
grep "error" /var/log/syslog

# Recherche insensible à la casse
grep -i "failed" /var/log/syslog

# Rechercher dans tous les logs
grep -r "out of memory" /var/log/

# Compter les occurrences
grep -c "error" /var/log/syslog

# Afficher le contexte (lignes avant/après)
grep -A 5 -B 5 "error" /var/log/syslog
```

### Analyse avancée avec `awk` et `sed`

```bash
# Extraire seulement les erreurs SSH
grep "sshd" /var/log/auth.log | grep "Failed"

# Compter les tentatives de connexion échouées par IP
grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr

# Extraire les messages d'une plage horaire
awk '/Jan 15 10:00/,/Jan 15 12:00/' /var/log/syslog

# Afficher seulement certaines colonnes
awk '{print $1, $2, $3, $NF}' /var/log/syslog
```

> [!example] Script d'analyse quotidienne des erreurs
> 
> ```bash
> #!/bin/bash
> echo "=== Rapport d'erreurs des dernières 24h ==="
> echo ""
> 
> echo "Erreurs critiques :"
> journalctl -p crit --since "24 hours ago" --no-pager | wc -l
> 
> echo ""
> echo "Erreurs par service :"
> journalctl -p err --since "24 hours ago" --no-pager | \
>   grep -oP '(?<=\[)[^\]]+' | sort | uniq -c | sort -rn | head -10
> 
> echo ""
> echo "Services en échec :"
> systemctl --failed --no-pager
> ```

### Gestion de la taille des logs

```bash
# Voir l'espace disque utilisé par journald
journalctl --disk-usage

# Nettoyer les logs plus anciens que X jours
sudo journalctl --vacuum-time=30d

# Limiter la taille totale des logs
sudo journalctl --vacuum-size=1G

# Rotation manuelle des logs
sudo logrotate -f /etc/logrotate.conf

# Vérifier la configuration de logrotate
cat /etc/logrotate.conf
ls -la /etc/logrotate.d/
```

> [!warning] Configuration de la rétention des logs Modifiez `/etc/systemd/journald.conf` pour configurer la rétention permanente :
> 
> ```ini
> [Journal]
> SystemMaxUse=1G
> SystemMaxFileSize=100M
> MaxRetentionSec=30day
> ```
> 
> N'oubliez pas de redémarrer journald après modification : `sudo systemctl restart systemd-journald`

---

## 📊 Surveillance de la charge système {#charge-systeme}

### Comprendre la charge système

La charge système représente le nombre de processus en attente d'exécution ou en cours d'exécution. Elle permet d'évaluer si le système est surchargé.

### La commande `uptime`

```bash
uptime
```

> [!example] Sortie typique
> 
> ```
> 14:23:15 up 5 days, 3:42, 2 users, load average: 0.52, 0.58, 0.61
> ```
> 
> - **14:23:15** : Heure actuelle
> - **up 5 days, 3:42** : Temps depuis le dernier démarrage
> - **2 users** : Nombre d'utilisateurs connectés
> - **load average: 0.52, 0.58, 0.61** : Charge moyenne sur 1, 5 et 15 minutes

> [!info] Interpréter la charge moyenne
> 
> - Sur un système à 4 cœurs, une charge de 4.0 signifie 100% d'utilisation
> - Une charge de 2.0 sur 4 cœurs = 50% d'utilisation
> - Une charge > nombre de cœurs = système surchargé
> - Vérifier le nombre de cœurs : `nproc` ou `grep -c ^processor /proc/cpuinfo`

### La commande `top`

`top` affiche en temps réel les processus et l'utilisation des ressources.

```bash
# Lancer top
top

# Trier par utilisation CPU (par défaut)
# Appuyer sur 'P' dans top

# Trier par utilisation mémoire
# Appuyer sur 'M' dans top

# Trier par temps CPU
# Appuyer sur 'T' dans top

# Filtrer par utilisateur
# Appuyer sur 'u' puis entrer le nom d'utilisateur

# Tuer un processus depuis top
# Appuyer sur 'k' puis entrer le PID

# Afficher les threads
# Appuyer sur 'H'

# Mode batch (pour redirection)
top -b -n 1

# Actualiser toutes les 2 secondes
top -d 2
```

> [!example] Comprendre l'en-tête de top
> 
> ```
> top - 14:23:15 up 5 days,  3:42,  2 users,  load average: 0.52, 0.58, 0.61
> Tasks: 243 total,   1 running, 242 sleeping,   0 stopped,   0 zombie
> %Cpu(s):  3.2 us,  1.1 sy,  0.0 ni, 95.5 id,  0.1 wa,  0.0 hi,  0.1 si,  0.0 st
> MiB Mem :   7842.2 total,   1234.5 free,   3456.7 used,   3151.0 buff/cache
> MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   3987.4 avail Mem
> ```
> 
> Métriques CPU importantes :
> 
> - **us** (user) : Temps CPU en espace utilisateur
> - **sy** (system) : Temps CPU en espace kernel
> - **id** (idle) : Temps CPU inactif
> - **wa** (wait) : Temps d'attente I/O (si élevé = problème disque/réseau)

### La commande `htop`

`htop` est une version améliorée et plus conviviale de `top`.

```bash
# Installer htop
sudo apt install htop    # Debian/Ubuntu
sudo dnf install htop    # RedHat/CentOS

# Lancer htop
htop
```

> [!tip] Raccourcis clavier utiles dans htop
> 
> - **F2** : Configuration
> - **F3** : Recherche
> - **F4** : Filtrer
> - **F5** : Vue arborescente
> - **F6** : Trier
> - **F9** : Tuer un processus
> - **F10** : Quitter
> - **Space** : Marquer un processus
> - **U** : Afficher uniquement les processus d'un utilisateur

### Surveillance de la mémoire

```bash
# Affichage simple
free

# Format lisible
free -h

# Actualisation continue toutes les 2 secondes
free -h -s 2

# Afficher en Mo
free -m

# Afficher en Go
free -g
```

> [!example] Comprendre la sortie de `free -h`
> 
> ```
>                total        used        free      shared  buff/cache   available
> Mem:           7.7Gi       3.4Gi       1.2Gi       234Mi       3.1Gi       3.9Gi
> Swap:          2.0Gi          0B       2.0Gi
> ```
> 
> Points importants :
> 
> - **used** : Mémoire réellement utilisée par les applications
> - **free** : Mémoire totalement inutilisée (souvent faible, c'est normal)
> - **buff/cache** : Mémoire utilisée pour le cache (peut être libérée si nécessaire)
> - **available** : Mémoire réellement disponible pour les nouvelles applications (métrique la plus importante)

### Surveillance de l'I/O disque

```bash
# Installer iostat (fait partie de sysstat)
sudo apt install sysstat

# Statistiques I/O basiques
iostat

# Affichage étendu
iostat -x

# Actualisation toutes les 2 secondes
iostat -x 2

# Statistiques par partition
iostat -p sda

# Statistiques en Mo/s
iostat -m

# Format lisible avec timestamps
iostat -t -x 2
```

> [!info] Métriques I/O importantes
> 
> - **%util** : Pourcentage de temps où le périphérique était occupé (> 80% = goulot d'étranglement)
> - **await** : Temps d'attente moyen des requêtes (en ms)
> - **r/s** et **w/s** : Opérations de lecture/écriture par seconde
> - **rkB/s** et **wkB/s** : Kilo-octets lus/écrits par seconde

### Surveillance réseau avec `iftop`

```bash
# Installer iftop
sudo apt install iftop

# Lancer iftop
sudo iftop

# Spécifier une interface
sudo iftop -i eth0

# Afficher les ports
sudo iftop -P

# Ne pas résoudre les noms d'hôtes
sudo iftop -n
```

### Surveillance en temps réel avec `vmstat`

```bash
# Affichage basique
vmstat

# Actualisation toutes les 2 secondes, 5 fois
vmstat 2 5

# Afficher les statistiques disque
vmstat -d

# Afficher les statistiques mémoire détaillées
vmstat -s

# Format avec timestamp
vmstat -t 2
```

> [!example] Interpréter vmstat
> 
> ```
> procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
>  1  0      0 1234567 123456 3151000  0    0     5    10  100  200  3  1 96  0  0
> ```
> 
> Colonnes critiques :
> 
> - **r** : Processus en attente d'exécution (si > nb de CPU = surcharge)
> - **b** : Processus en attente I/O (sleep non-interruptible)
> - **si/so** : Swap in/out (si > 0 régulièrement = manque de RAM)
> - **wa** : Temps CPU d'attente I/O (si élevé = problème disque)

### Script de surveillance globale

```bash
#!/bin/bash
echo "=== Surveillance système $(date) ==="
echo ""

echo "Charge système :"
uptime

echo ""
echo "Mémoire :"
free -h | grep -E "Mem|Swap"

echo ""
echo "Espace disque (> 80%) :"
df -h | awk '$5 > 80 {print $0}'

echo ""
echo "Top 5 processus CPU :"
ps aux --sort=-%cpu | head -6

echo ""
echo "Top 5 processus mémoire :"
ps aux --sort=-%mem | head -6

echo ""
echo "Services en échec :"
systemctl --failed --no-legend | wc -l

echo ""
echo "Dernières erreurs (5 lignes) :"
journalctl -p err --since "1 hour ago" -n 5 --no-pager
```

> [!tip] Automatiser la surveillance Ajoutez ce script dans une tâche cron pour recevoir des rapports réguliers :
> 
> ```bash
> # Éditer le crontab
> crontab -e
> 
> # Ajouter une ligne pour exécuter toutes les heures
> 0 * * * * /chemin/vers/script.sh >> /var/log/surveillance.log 2>&1
> ```

### Outils de surveillance avancés

```bash
# glances - Outil de surveillance tout-en-un
sudo apt install glances
glances

# nmon - Outil de performance IBM
sudo apt install nmon
nmon

# dstat - Statistiques système polyvalentes
sudo apt install dstat
dstat -cdngy 2

# iotop - Surveillance I/O par processus
sudo apt install iotop
sudo iotop
```

> [!warning] Impact de la surveillance Les outils de surveillance consomment eux-mêmes des ressources. Sur un système en production, privilégiez des intervalles d'actualisation raisonnables (≥ 2 secondes) et évitez de lancer trop d'outils simultanément.

---

## 🎯 Bonnes pratiques de vérification système

### Routine de vérification quotidienne

1. **Vérifier la charge système** : `uptime` ou `top` pour une vue rapide
2. **Contrôler l'espace disque** : `df -h` pour s'assurer qu'aucune partition n'est pleine
3. **Examiner les services critiques** : `systemctl --failed` pour détecter les échecs
4. **Parcourir les logs récents** : `journalctl -p err --since today` pour identifier les erreurs

### Routine de vérification hebdomadaire

1. **Analyser les logs d'authentification** : Détecter les tentatives d'intrusion
2. **Vérifier l'utilisation des ressources** : Identifier les tendances (augmentation progressive de la mémoire, etc.)
3. **Contrôler l'intégrité des sauvegardes** : S'assurer que les services de sauvegarde fonctionnent
4. **Examiner les mises à jour disponibles** : Planifier les maintenances nécessaires

### Mise en place d'alertes

```bash
# Exemple de script d'alerte simple
#!/bin/bash
ALERT_EMAIL="admin@example.com"
THRESHOLD_DISK=85
THRESHOLD_LOAD=$(nproc)

# Vérifier l'espace disque
df -h | awk -v threshold=$THRESHOLD_DISK \
  '$5 > threshold {print "ALERTE: "$6" est à "$5}' | \
  while read line; do
    echo "$line" | mail -s "Alerte espace disque" $ALERT_EMAIL
  done

# Vérifier la charge
LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
if (( $(echo "$LOAD > $THRESHOLD_LOAD" | bc -l) )); then
  echo "Charge système élevée: $LOAD" | mail -s "Alerte charge système" $ALERT_EMAIL
fi
```

> [!tip] Solutions de monitoring professionnelles Pour une surveillance avancée en production, considérez des solutions comme :
> 
> - **Prometheus + Grafana** : Monitoring et visualisation
> - **Nagios / Icinga** : Supervision d'infrastructure
> - **Zabbix** : Monitoring complet et alerting
> - **Netdata** : Monitoring temps réel avec interface web

### Pièges courants à éviter

1. **Négliger l'utilisation des inodes** : Un système de fichiers peut être "plein" même avec de l'espace disponible si tous les inodes sont utilisés (`df -i`)
2. **Confondre mémoire utilisée et disponible** : Regarder la colonne "available" plutôt que "free" dans `free -h`
3. **Ignorer les logs d'avertissement** : Les warnings précèdent souvent les erreurs critiques
4. **Ne pas surveiller le swap** : Un usage intensif du swap indique un manque de RAM
5. **Oublier de nettoyer les logs** : Les logs peuvent rapidement saturer le disque

---

## 🔑 Points clés à retenir

- L'espace disque doit être surveillé avec `df` et `du`, avec attention particulière aux partitions système (`/`, `/var`, `/tmp`)
- Les services critiques doivent être vérifiés régulièrement avec `systemctl` et leurs logs examinés via `journalctl`
- Les logs d'erreurs contiennent des informations précieuses pour le dépannage et doivent être consultés régulièrement
- La charge système s'évalue avec `uptime`, `top`, et `htop`, en gardant en tête le nombre de cœurs CPU disponibles
- Une surveillance proactive permet d'éviter les incidents en production

---

_Cours créé pour la formation Administration Linux - Mises à jour et maintenance système_