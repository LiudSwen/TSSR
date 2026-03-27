

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

## 🗂️ Localisation des logs SSH

### Fichiers de logs principaux

Les logs SSH sont généralement gérés par le démon `syslog` ou `journald` selon la distribution Linux utilisée.

> [!info] Emplacements standards Les logs SSH sont dispersés dans plusieurs fichiers selon leur type et la configuration du système.

#### Sur les systèmes utilisant syslog

```bash
# Logs d'authentification (Debian/Ubuntu)
/var/log/auth.log

# Logs d'authentification (RedHat/CentOS/Fedora)
/var/log/secure

# Logs système généraux
/var/log/syslog    # Debian/Ubuntu
/var/log/messages  # RedHat/CentOS
```

#### Sur les systèmes utilisant systemd/journald

```bash
# Afficher tous les logs SSH
journalctl -u ssh

# Afficher les logs SSHD
journalctl -u sshd

# Selon la distribution
journalctl -u ssh.service
journalctl -u sshd.service
```

### Configuration du niveau de logging

Le niveau de verbosité des logs SSH se configure dans `/etc/ssh/sshd_config` :

```bash
# Niveaux disponibles : QUIET, FATAL, ERROR, INFO, VERBOSE, DEBUG, DEBUG1, DEBUG2, DEBUG3
LogLevel VERBOSE

# Pour un debug approfondi (génère beaucoup de logs)
LogLevel DEBUG3
```

> [!warning] Impact de DEBUG3 Le niveau DEBUG3 génère une quantité massive de logs et peut affecter les performances. À utiliser uniquement pour le dépannage temporaire.

|Niveau|Usage|Volume de logs|
|---|---|---|
|QUIET|Production minimaliste|Très faible|
|INFO|Production standard|Faible|
|VERBOSE|Recommandé pour l'audit|Moyen|
|DEBUG|Dépannage|Élevé|
|DEBUG3|Dépannage intensif|Très élevé|

### Vérifier la configuration actuelle

```bash
# Vérifier le niveau de log configuré
grep LogLevel /etc/ssh/sshd_config

# Vérifier où syslog envoie les logs auth
grep auth /etc/rsyslog.conf
grep auth /etc/rsyslog.d/*.conf
```

---

## 📊 Analyse des logs de connexion

### Structure typique d'une entrée de log SSH

```bash
Dec 20 10:15:42 server sshd[12345]: Accepted publickey for user from 192.168.1.100 port 54321 ssh2: RSA SHA256:abc123...
```

**Décomposition :**

- `Dec 20 10:15:42` : Date et heure
- `server` : Nom d'hôte
- `sshd[12345]` : Processus et PID
- `Accepted publickey` : Type d'événement
- `for user` : Utilisateur concerné
- `from 192.168.1.100 port 54321` : Source de la connexion
- `ssh2: RSA SHA256:...` : Méthode et empreinte de clé

### Commandes d'analyse essentielles

#### Rechercher les connexions réussies

```bash
# Connexions acceptées (syslog)
grep "Accepted" /var/log/auth.log

# Avec journald
journalctl -u ssh | grep "Accepted"

# Filtrer par utilisateur
grep "Accepted.*for username" /var/log/auth.log

# Dernières 20 connexions réussies
grep "Accepted" /var/log/auth.log | tail -20
```

#### Rechercher les tentatives échouées

```bash
# Échecs d'authentification
grep "Failed password" /var/log/auth.log

# Tentatives avec des utilisateurs invalides
grep "Invalid user" /var/log/auth.log

# Connexions refusées
grep "Connection closed" /var/log/auth.log
```

> [!example] Exemple d'analyse d'attaque par force brute
> 
> ```bash
> # Compter les tentatives échouées par IP
> grep "Failed password" /var/log/auth.log | \
>   awk '{print $(NF-3)}' | sort | uniq -c | sort -nr
> 
> # Résultat :
> #  156 192.168.1.200
> #   45 10.0.0.50
> #    3 192.168.1.100
> ```

#### Filtrage par date et heure

```bash
# Avec journald - dernières 24h
journalctl -u ssh --since "24 hours ago"

# Depuis une date précise
journalctl -u ssh --since "2025-12-19 14:00:00"

# Période spécifique
journalctl -u ssh --since "2025-12-19" --until "2025-12-20"

# Avec grep classique (format des logs peut varier)
grep "Dec 20" /var/log/auth.log
```

### Patterns de logs importants à surveiller

#### Événements de sécurité critiques

```bash
# Modifications de privilèges
grep "sudo" /var/log/auth.log

# Changements de configuration SSH
grep "Received SIGHUP" /var/log/auth.log

# Déconnexions anormales
grep "Connection reset" /var/log/auth.log
grep "Timeout" /var/log/auth.log

# Tentatives de connexion root
grep "Failed password for root" /var/log/auth.log
```

> [!warning] Alertes critiques Les patterns suivants nécessitent une investigation immédiate :
> 
> - Multiples échecs suivis d'une connexion réussie (potentielle compromission)
> - Connexions depuis des IP inhabituelles
> - Tentatives sur le compte root
> - Pics d'activité anormaux

#### Créer des scripts d'analyse personnalisés

```bash
#!/bin/bash
# Script : ssh-audit.sh
# Analyse rapide des logs SSH

LOG_FILE="/var/log/auth.log"
TIMEFRAME="today"

echo "=== Rapport SSH - $(date) ==="
echo ""

echo "📊 Statistiques globales :"
echo "Connexions réussies : $(grep "Accepted" $LOG_FILE | wc -l)"
echo "Échecs d'authentification : $(grep "Failed password" $LOG_FILE | wc -l)"
echo ""

echo "👥 Top 5 utilisateurs connectés :"
grep "Accepted" $LOG_FILE | awk '{for(i=1;i<=NF;i++) if($i=="for") print $(i+1)}' | \
  sort | uniq -c | sort -rn | head -5
echo ""

echo "🌍 Top 5 IPs sources :"
grep "Accepted" $LOG_FILE | awk '{print $(NF-3)}' | \
  sort | uniq -c | sort -rn | head -5
echo ""

echo "⚠️ IPs avec échecs multiples (>10) :"
grep "Failed password" $LOG_FILE | awk '{print $(NF-3)}' | \
  sort | uniq -c | sort -rn | awk '$1 > 10 {print $0}'
```

> [!tip] Automatisation Planifiez ce script avec cron pour recevoir des rapports quotidiens :
> 
> ```bash
> # Ajout à crontab
> 0 8 * * * /usr/local/bin/ssh-audit.sh | mail -s "Rapport SSH quotidien" admin@example.com
> ```

---

## 🔎 Monitoring des accès

### Surveillance en temps réel

#### Avec tail

```bash
# Suivre les logs en temps réel (syslog)
tail -f /var/log/auth.log | grep sshd

# Avec coloration syntaxique
tail -f /var/log/auth.log | grep --color=auto -E "Accepted|Failed"

# Avec journald
journalctl -u ssh -f
```

#### Avec watch

```bash
# Afficher les dernières connexions toutes les 2 secondes
watch -n 2 'tail -20 /var/log/auth.log | grep Accepted'

# Compter les événements en temps réel
watch -n 5 'echo "Connexions: $(grep Accepted /var/log/auth.log | wc -l) | Échecs: $(grep Failed /var/log/auth.log | wc -l)"'
```

### Mise en place d'alertes

#### Avec rsyslog (forwarding vers un serveur centralisé)

```bash
# Configuration dans /etc/rsyslog.d/50-ssh.conf
# Envoyer tous les logs SSH vers un serveur distant
if $programname == 'sshd' then @192.168.1.10:514
& stop

# Format avec TCP (plus fiable)
if $programname == 'sshd' then @@192.168.1.10:514
& stop
```

#### Script de surveillance simple

```bash
#!/bin/bash
# Script : ssh-monitor.sh
# Surveillance continue avec alertes

ALERT_EMAIL="admin@example.com"
THRESHOLD=5  # Nombre d'échecs avant alerte
CHECK_INTERVAL=60  # Secondes

while true; do
    # Compter les échecs dans la dernière minute
    FAILURES=$(grep "Failed password" /var/log/auth.log | \
               grep "$(date '+%b %d %H:%M' --date='1 minute ago')" | wc -l)
    
    if [ $FAILURES -gt $THRESHOLD ]; then
        echo "ALERTE: $FAILURES tentatives échouées détectées" | \
          mail -s "Alerte SSH - Tentatives suspectes" $ALERT_EMAIL
    fi
    
    sleep $CHECK_INTERVAL
done
```

### Configuration de fail2ban (aperçu)

> [!info] Fail2ban Fail2ban est un outil dédié qui analyse les logs et bannit automatiquement les IPs suspectes. Voici un aperçu de sa configuration pour SSH.

```bash
# Installation
apt install fail2ban  # Debian/Ubuntu
yum install fail2ban  # RedHat/CentOS

# Configuration SSH dans /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log  # ou /var/log/secure
maxretry = 3                  # Nombre de tentatives avant ban
bantime = 3600                # Durée du ban en secondes
findtime = 600                # Fenêtre de temps pour compter les tentatives
```

### Tableaux de bord avec logwatch

```bash
# Installation
apt install logwatch  # Debian/Ubuntu
yum install logwatch  # RedHat/CentOS

# Génération d'un rapport manuel
logwatch --service sshd --detail High --range today

# Configuration pour envoi automatique quotidien
# Éditer /etc/logwatch/conf/logwatch.conf
MailTo = admin@example.com
Detail = High
Service = sshd
Range = yesterday
```

> [!tip] Outils graphiques Pour une visualisation avancée, considérez des solutions comme :
> 
> - **GoAccess** : Analyse en temps réel dans le terminal ou HTML
> - **ELK Stack** (Elasticsearch, Logstash, Kibana) : Solution professionnelle
> - **Grafana + Loki** : Alternative moderne et performante

---

## 🛠️ Outils d'audit

### lastlog - Dernière connexion par utilisateur

La commande `lastlog` affiche la dernière connexion de chaque utilisateur du système.

```bash
# Afficher toutes les dernières connexions
lastlog

# Sortie typique :
# Username    Port     From             Latest
# root        pts/0    192.168.1.100    Fri Dec 20 10:15:42 +0000 2025
# user1       pts/1    192.168.1.101    Thu Dec 19 14:32:11 +0000 2025
# user2                                 **Never logged in**
```

#### Options utiles

```bash
# Afficher seulement les utilisateurs jamais connectés
lastlog | grep "Never"

# Afficher un utilisateur spécifique
lastlog -u username

# Afficher par UID
lastlog -u 1000

# Avant une certaine date (jours)
lastlog -b 7  # Plus de 7 jours

# Depuis une certaine date
lastlog -t 30  # Moins de 30 jours
```

> [!tip] Détection de comptes dormants
> 
> ```bash
> # Identifier les comptes qui ne se sont jamais connectés
> lastlog | awk '/Never/ {print $1}' | grep -v Username
> 
> # Comptes inactifs depuis plus de 90 jours
> lastlog -b 90
> ```

### last - Historique des connexions

La commande `last` lit le fichier `/var/log/wtmp` pour afficher l'historique complet des connexions.

```bash
# Afficher toutes les connexions
last

# Sortie typique :
# user1    pts/0    192.168.1.100    Fri Dec 20 10:15   still logged in
# user2    pts/1    192.168.1.101    Thu Dec 19 14:32 - 16:45  (02:13)
# reboot   system boot  5.15.0-generic   Thu Dec 19 08:00   still running
```

#### Options avancées

```bash
# Filtrer par utilisateur
last username

# Filtrer par terminal
last -t pts/0

# Afficher les 10 dernières connexions
last -n 10

# Afficher depuis une date
last -s "2025-12-19"

# Afficher jusqu'à une date
last -t "2025-12-20"

# Période spécifique
last -s "2025-12-19 14:00" -t "2025-12-20 10:00"

# Afficher les redémarrages seulement
last reboot

# Afficher avec l'IP complète (pas de résolution DNS)
last -i

# Afficher les noms d'hôte complets
last -w
```

> [!example] Analyse de session utilisateur
> 
> ```bash
> # Temps total de connexion d'un utilisateur
> last username | grep -v "still logged in" | \
>   awk '{print $NF}' | grep "(" | \
>   sed 's/[()]//g'
> 
> # Connexions d'aujourd'hui uniquement
> last -s today
> 
> # Détecter les connexions simultanées d'un même utilisateur
> last username | grep "still logged in"
> ```

### lastb - Tentatives échouées

La commande `lastb` affiche les tentatives de connexion échouées (lit `/var/log/btmp`).

```bash
# Nécessite les privilèges root
sudo lastb

# Sortie typique :
# username ssh:notty    192.168.1.200    Fri Dec 20 10:20 - 10:20  (00:00)
# root     ssh:notty    10.0.0.50        Fri Dec 20 09:45 - 09:45  (00:00)
```

#### Analyse des échecs

```bash
# Compter les échecs par utilisateur
sudo lastb | awk '{print $1}' | sort | uniq -c | sort -rn

# Compter les échecs par IP
sudo lastb | awk '{print $3}' | sort | uniq -c | sort -rn

# Échecs sur les dernières 24h
sudo lastb -s "-24hours"

# Afficher les 20 derniers échecs
sudo lastb -n 20

# Afficher avec IP complète
sudo lastb -i
```

> [!warning] Sécurité du fichier btmp Le fichier `/var/log/btmp` peut devenir très volumineux en cas d'attaques. Pensez à le nettoyer régulièrement :
> 
> ```bash
> # Sauvegarder puis vider
> sudo cp /var/log/btmp /var/log/btmp.backup
> sudo > /var/log/btmp
> 
> # Ou avec rotation automatique dans /etc/logrotate.d/btmp
> ```

### who - Utilisateurs actuellement connectés

La commande `who` affiche les utilisateurs actuellement connectés au système.

```bash
# Affichage standard
who

# Sortie typique :
# user1    pts/0        2025-12-20 10:15 (192.168.1.100)
# user2    pts/1        2025-12-20 09:30 (192.168.1.101)

# Avec informations détaillées
who -a

# Afficher les processus actifs de chaque utilisateur
who -u

# Afficher l'heure du dernier boot
who -b

# Compter le nombre d'utilisateurs connectés
who | wc -l

# Format court (noms uniquement)
who -q
```

#### w - Version étendue de who

```bash
# Afficher l'activité des utilisateurs
w

# Sortie typique :
#  10:15:42 up 5 days,  2:30,  2 users,  load average: 0.08, 0.03, 0.01
# USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
# user1    pts/0    192.168.1.100    10:15    0.00s  0.04s  0.00s w
# user2    pts/1    192.168.1.101    09:30    45:23  0.01s  0.01s -bash

# Sans l'en-tête
w -h

# Format court
w -s

# Pour un utilisateur spécifique
w username
```

### whowatch - Surveillance interactive

```bash
# Installation
apt install whowatch  # Debian/Ubuntu
yum install whowatch  # RedHat/CentOS

# Lancement (nécessite root)
sudo whowatch

# Interface interactive :
# - Flèches pour naviguer
# - Enter pour voir les processus d'un utilisateur
# - F9 pour envoyer un signal à un processus
# - 't' pour l'arborescence des processus
# - 'q' pour quitter
```

### Combinaison d'outils pour audit complet

```bash
#!/bin/bash
# Script : ssh-full-audit.sh
# Audit complet des connexions SSH

echo "═══════════════════════════════════════════════════════"
echo "          AUDIT COMPLET SSH - $(date)"
echo "═══════════════════════════════════════════════════════"
echo ""

echo "👥 UTILISATEURS ACTUELLEMENT CONNECTÉS :"
who
echo ""

echo "📊 DERNIÈRE CONNEXION PAR UTILISATEUR :"
lastlog | head -20
echo ""

echo "📜 HISTORIQUE DES 10 DERNIÈRES CONNEXIONS :"
last -n 10
echo ""

echo "⚠️ DERNIÈRES TENTATIVES ÉCHOUÉES :"
sudo lastb -n 10
echo ""

echo "🔍 STATISTIQUES D'ÉCHECS PAR IP :"
sudo lastb | awk '{print $3}' | sort | uniq -c | sort -rn | head -10
echo ""

echo "🌍 CONNEXIONS ACTIVES PAR IP :"
who | awk '{print $5}' | sed 's/[()]//g' | sort | uniq -c
echo ""

echo "📈 COMPTES JAMAIS UTILISÉS :"
lastlog | grep "Never" | wc -l
echo ""

echo "═══════════════════════════════════════════════════════"
```

### Outils complémentaires

#### pam_tally2 / faillock - Compteur d'échecs PAM

```bash
# Afficher les échecs pour tous les utilisateurs (anciennes versions)
pam_tally2

# Version moderne (systemd)
faillock

# Afficher pour un utilisateur spécifique
faillock --user username

# Réinitialiser le compteur
faillock --user username --reset
```

#### auditd - Audit système avancé

```bash
# Installation
apt install auditd  # Debian/Ubuntu

# Ajouter une règle pour surveiller SSH
auditctl -w /etc/ssh/sshd_config -p wa -k sshd_config

# Rechercher les événements SSH
ausearch -k sshd_config

# Générer un rapport
aureport --auth
```

> [!tip] Bonnes pratiques d'audit
> 
> - **Conservez les logs** pendant au moins 90 jours (conformité)
> - **Centralisez** les logs sur un serveur dédié
> - **Automatisez** les analyses avec des scripts cron
> - **Corrélez** les événements de plusieurs sources
> - **Archivez** régulièrement les logs anciens compressés
> - **Surveillez** l'espace disque utilisé par les logs

---

## 🎯 Pièges courants

> [!warning] Erreurs fréquentes
> 
> **Logs qui disparaissent :**
> 
> - Vérifier la rotation des logs (`/etc/logrotate.d/rsyslog`)
> - Surveiller l'espace disque avec `df -h /var/log`
> 
> **Mauvaise interprétation des logs :**
> 
> - Les connexions "still logged in" dans `last` ne signifient pas forcément une session active
> - Les échecs multiples peuvent être légitimes (utilisateur a oublié son mot de passe)
> 
> **Oubli de nettoyage :**
> 
> - `/var/log/btmp` peut devenir gigantesque sans rotation
> - Les fichiers wtmp/btmp ne sont pas toujours inclus dans logrotate par défaut

---

## 💡 Astuces avancées

### Créer des alias pour l'audit rapide

```bash
# Ajouter au ~/.bashrc
alias ssh-fails='sudo grep "Failed password" /var/log/auth.log | tail -20'
alias ssh-success='grep "Accepted" /var/log/auth.log | tail -20'
alias ssh-active='w -h | grep pts'
alias ssh-ips='who | awk "{print \$5}" | sed "s/[()]//g" | sort | uniq'
```

### Monitoring avec awk avancé

```bash
# Analyser les heures de pointe de connexion
grep "Accepted" /var/log/auth.log | \
  awk '{print $3}' | cut -d: -f1 | sort | uniq -c | sort -rn

# Durée moyenne des sessions
last | grep -v "still logged in" | \
  awk '/pts/ {print $NF}' | grep "(" | \
  sed 's/[()]//g' | awk -F: '{print ($1*60)+$2}' | \
  awk '{sum+=$1; count++} END {print "Moyenne:", sum/count, "minutes"}'
```

### Exporter les logs pour analyse externe

```bash
# Exporter en CSV pour Excel/LibreOffice
grep "Accepted" /var/log/auth.log | \
  awk '{print $1" "$2" "$3","$9","$11}' > ssh_connexions.csv

# Format JSON pour ingestion dans ELK
grep "Accepted" /var/log/auth.log | \
  awk '{print "{\"date\":\""$1" "$2" "$3"\",\"user\":\""$9"\",\"ip\":\""$11"\"}"}' \
  > ssh_connexions.json
```

---

**📌 Points clés à retenir :**

- Les logs SSH sont essentiels pour la sécurité et se trouvent dans `/var/log/auth.log` ou via `journalctl`
- Utilisez `LogLevel VERBOSE` pour un bon équilibre entre détail et performance
- Les outils `last`, `lastb`, `who` et `lastlog` offrent des vues complémentaires sur l'activité SSH
- Automatisez l'analyse avec des scripts et mettez en place des alertes pour les événements critiques
- Conservez et archivez vos logs pour respecter les politiques de sécurité et de conformité
- Surveillez particulièrement : les échecs multiples, les IPs inhabituelles et les tentatives sur root