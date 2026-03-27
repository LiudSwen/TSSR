

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

## 🎯 Introduction

**Cron** est le planificateur de tâches standard sur les systèmes Unix/Linux. Il permet d'exécuter automatiquement des commandes ou des scripts à des intervalles précis (quotidien, hebdomadaire, mensuel, ou des horaires personnalisés).

> [!info] Pourquoi utiliser cron ?
> 
> - **Automatisation** : sauvegardes, nettoyage de fichiers, synchronisation
> - **Maintenance** : mises à jour, vérifications système
> - **Surveillance** : collecte de métriques, monitoring
> - **Tâches récurrentes** : rapports, envoi d'emails, traitements batch

Le service `cron` fonctionne en arrière-plan (daemon `crond`) et vérifie chaque minute si des tâches doivent être exécutées.

---

## 📝 Syntaxe de crontab

Chaque ligne dans une crontab suit cette structure :

```bash
# Format général
* * * * * commande_à_exécuter
│ │ │ │ │
│ │ │ │ └─── Jour de la semaine (0-7, 0 et 7 = dimanche)
│ │ │ └───── Mois (1-12)
│ │ └─────── Jour du mois (1-31)
│ └───────── Heure (0-23)
└─────────── Minute (0-59)
```

> [!example] Exemple simple
> 
> ```bash
> # Exécuter un script chaque jour à 2h30 du matin
> 30 2 * * * /home/user/backup.sh
> ```

### Symboles spéciaux

|Symbole|Signification|Exemple|
|---|---|---|
|`*`|Toutes les valeurs|`* * * * *` = chaque minute|
|`,`|Liste de valeurs|`0,30 * * * *` = à 0 et 30 minutes|
|`-`|Plage de valeurs|`0 9-17 * * *` = de 9h à 17h|
|`/`|Incrément/pas|`*/15 * * * *` = toutes les 15 minutes|

---

## 🛠️ Gestion des crontabs

### Commandes essentielles

```bash
# Éditer la crontab de l'utilisateur courant
crontab -e

# Lister les tâches planifiées
crontab -l

# Supprimer toute la crontab
crontab -r

# Éditer la crontab d'un autre utilisateur (root uniquement)
sudo crontab -u username -e

# Lister la crontab d'un autre utilisateur
sudo crontab -u username -l
```

> [!tip] Éditeur par défaut Par défaut, `crontab -e` utilise l'éditeur défini dans `$EDITOR`. Pour changer :
> 
> ```bash
> export EDITOR=nano  # ou vim, vi, etc.
> ```

### Types de crontabs

1. **Crontab utilisateur** : `/var/spool/cron/crontabs/username`
2. **Crontab système** : `/etc/crontab`
3. **Répertoires système** :
    - `/etc/cron.d/` : fichiers crontab supplémentaires
    - `/etc/cron.daily/` : scripts exécutés quotidiennement
    - `/etc/cron.hourly/` : scripts exécutés chaque heure
    - `/etc/cron.weekly/` : scripts exécutés chaque semaine
    - `/etc/cron.monthly/` : scripts exécutés chaque mois

> [!warning] Différence importante La crontab système `/etc/crontab` inclut un champ supplémentaire pour l'utilisateur :
> 
> ```bash
> # Format : minute heure jour mois jour_semaine utilisateur commande
> 30 2 * * * root /usr/local/bin/backup.sh
> ```

---

## 🔍 Format détaillé

### Champs de temps

|Champ|Valeurs|Descriptions spéciales|
|---|---|---|
|Minute|0-59|-|
|Heure|0-23|-|
|Jour du mois|1-31|-|
|Mois|1-12|jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec|
|Jour de la semaine|0-7|0 et 7 = dimanche, 1 = lundi, ... 6 = samedi<br>Ou : sun, mon, tue, wed, thu, fri, sat|

### Chaînes spéciales

Au lieu des 5 champs, vous pouvez utiliser des raccourcis :

```bash
@reboot        # Au démarrage du système
@yearly        # Une fois par an (0 0 1 1 *)
@annually      # Identique à @yearly
@monthly       # Une fois par mois (0 0 1 * *)
@weekly        # Une fois par semaine (0 0 * * 0)
@daily         # Une fois par jour (0 0 * * *)
@midnight      # Identique à @daily
@hourly        # Chaque heure (0 * * * *)
```

> [!example] Exemples avec raccourcis
> 
> ```bash
> @reboot /home/user/startup.sh
> @daily /usr/local/bin/cleanup.sh
> @hourly /usr/local/bin/check_status.sh
> ```

---

## 💡 Exemples de planification

### Exemples simples

```bash
# Toutes les minutes
* * * * * /chemin/script.sh

# Toutes les heures à la 15ème minute
15 * * * * /chemin/script.sh

# Tous les jours à minuit
0 0 * * * /chemin/script.sh

# Tous les jours à 2h30
30 2 * * * /chemin/backup.sh

# Tous les lundis à 9h
0 9 * * 1 /chemin/rapport.sh

# Premier jour de chaque mois à minuit
0 0 1 * * /chemin/monthly.sh
```

### Exemples avancés

```bash
# Toutes les 15 minutes
*/15 * * * * /chemin/monitoring.sh

# Toutes les 2 heures entre 9h et 17h
0 9-17/2 * * * /chemin/check.sh

# Du lundi au vendredi à 8h30
30 8 * * 1-5 /chemin/workday.sh

# Les 1er et 15 de chaque mois à 3h
0 3 1,15 * * /chemin/biweekly.sh

# Tous les dimanches à 23h
0 23 * * 0 /chemin/weekly_backup.sh

# Janvier, avril, juillet, octobre (trimestriel)
0 0 1 1,4,7,10 * /chemin/quarterly.sh

# Tous les jours ouvrés à 18h
0 18 * * 1-5 /chemin/end_of_day.sh

# Chaque minute pendant la première heure de chaque jour
* 0 * * * /chemin/intensive.sh
```

### Combinaisons complexes

```bash
# Toutes les 10 minutes entre 8h et 18h, du lundi au vendredi
*/10 8-18 * * 1-5 /chemin/business_hours.sh

# À 6h, 12h et 18h tous les jours
0 6,12,18 * * * /chemin/three_times.sh

# Toutes les 30 minutes sauf entre minuit et 6h
*/30 6-23 * * * /chemin/daytime.sh

# Le dernier jour de chaque mois (astuce avec février)
0 0 28-31 * * [ $(date -d tomorrow +\%d) -eq 1 ] && /chemin/last_day.sh
```

---

## 🌐 Variables d'environnement dans cron

Les tâches cron s'exécutent dans un environnement minimal. Beaucoup de variables habituelles (`PATH`, `HOME`, `USER`, etc.) peuvent être différentes ou absentes.

### Définir des variables

```bash
# Au début de votre crontab
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
HOME=/home/username
MAILTO=admin@example.com

# Ensuite vos tâches
30 2 * * * /home/username/backup.sh
```

### Variables courantes

|Variable|Description|Valeur par défaut|
|---|---|---|
|`SHELL`|Shell utilisé|`/bin/sh`|
|`PATH`|Chemin de recherche|`/usr/bin:/bin`|
|`HOME`|Répertoire home|`/home/username`|
|`LOGNAME`|Nom de connexion|Username du crontab|
|`MAILTO`|Destinataire des emails|Owner du crontab|
|`LANG`|Localisation|Système|

> [!warning] PATH restreint Le `PATH` dans cron est minimal. Toujours utiliser des chemins absolus :
> 
> ```bash
> # ❌ Mauvais
> 0 2 * * * backup.sh
> 
> # ✅ Bon
> 0 2 * * * /usr/local/bin/backup.sh
> ```

### Redirection de sortie

```bash
# Rediriger stdout et stderr vers un fichier
30 2 * * * /chemin/script.sh >> /var/log/script.log 2>&1

# Supprimer toute sortie
30 2 * * * /chemin/script.sh > /dev/null 2>&1

# Envoyer seulement les erreurs par email
30 2 * * * /chemin/script.sh > /dev/null

# Enregistrer stdout et envoyer stderr par email
30 2 * * * /chemin/script.sh >> /var/log/script.log
```

> [!info] Email automatique Si `MAILTO` est défini et qu'une commande produit une sortie, cron envoie automatiquement un email avec cette sortie.

### Charger l'environnement complet

```bash
# Sourcer le profil utilisateur avant d'exécuter
30 2 * * * . $HOME/.profile; /chemin/script.sh

# Ou depuis le script lui-même
#!/bin/bash
source /home/username/.bashrc
# ... reste du script
```

---

## 📊 Logs de cron

### Emplacement des logs

```bash
# Sur la plupart des systèmes
/var/log/cron
/var/log/cron.log

# Sur Debian/Ubuntu
/var/log/syslog    # cron logs mélangés avec autres logs système

# Vérifier les logs récents
tail -f /var/log/cron

# Filtrer les logs cron sur Ubuntu
grep CRON /var/log/syslog
```

### Consulter les logs

```bash
# Voir toutes les exécutions cron
grep CRON /var/log/syslog

# Voir les exécutions d'un utilisateur spécifique
grep "CRON.*username" /var/log/syslog

# Voir les exécutions des dernières 24h
journalctl -u cron --since "24 hours ago"

# Suivre les logs en temps réel
journalctl -u cron -f

# Logs avec plus de détails (systemd)
journalctl -u cron.service --no-pager
```

> [!tip] Activer plus de logs Sur certains systèmes, vous pouvez augmenter la verbosité de cron :
> 
> ```bash
> # Dans /etc/default/cron (Debian/Ubuntu)
> EXTRA_OPTS="-L 2"
> 
> # Puis redémarrer
> sudo systemctl restart cron
> ```

### Débogage des tâches cron

```bash
# Créer un fichier de log personnalisé dans votre script
#!/bin/bash
LOG_FILE="/var/log/mon_script.log"
echo "$(date): Début du script" >> "$LOG_FILE"
# ... votre code ...
echo "$(date): Fin du script" >> "$LOG_FILE"

# Ou directement dans la crontab
30 2 * * * /chemin/script.sh >> /tmp/debug_cron.log 2>&1
```

> [!warning] Permissions des logs Assurez-vous que l'utilisateur cron a les permissions d'écriture sur les fichiers de log.

---

## 🔄 Alternatives à cron

### 1. `at` - Tâches ponctuelles

Contrairement à cron (tâches récurrentes), `at` planifie des tâches uniques.

```bash
# Installer at (si nécessaire)
sudo apt install at    # Debian/Ubuntu
sudo yum install at    # RedHat/CentOS

# Démarrer le service
sudo systemctl start atd
sudo systemctl enable atd

# Planifier une tâche
echo "/chemin/script.sh" | at 14:30
echo "/chemin/script.sh" | at now + 2 hours
echo "/chemin/script.sh" | at midnight
echo "/chemin/script.sh" | at 2pm tomorrow

# Mode interactif
at 15:00
> /usr/local/bin/backup.sh
> /usr/local/bin/cleanup.sh
> <Ctrl+D>

# Lister les tâches en attente
atq

# Supprimer une tâche
atrm 3    # 3 étant le numéro de job

# Voir le contenu d'une tâche
at -c 3
```

> [!info] Quand utiliser `at` ?
> 
> - Tâche à exécuter une seule fois
> - Planification rapide sans éditer la crontab
> - Tests avant d'ajouter à cron

### 2. `systemd timers` - Planification moderne

Les **systemd timers** sont l'alternative moderne à cron sur les systèmes utilisant systemd.

#### Avantages sur cron

- Meilleure intégration avec systemd
- Logs centralisés avec `journalctl`
- Gestion des dépendances entre services
- Possibilité de définir des conditions d'exécution
- Meilleure gestion des tâches manquées

#### Création d'un timer

```bash
# 1. Créer un service unit (/etc/systemd/system/mon-backup.service)
[Unit]
Description=Backup quotidien

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
User=username
```

```bash
# 2. Créer un timer unit (/etc/systemd/system/mon-backup.timer)
[Unit]
Description=Timer pour backup quotidien

[Timer]
OnCalendar=daily
OnCalendar=02:30
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
# 3. Activer et démarrer le timer
sudo systemctl daemon-reload
sudo systemctl enable mon-backup.timer
sudo systemctl start mon-backup.timer

# Vérifier le status
systemctl status mon-backup.timer
systemctl list-timers --all
```

#### Syntaxe OnCalendar

```bash
# Exemples de planification
OnCalendar=hourly              # Chaque heure
OnCalendar=daily               # Chaque jour à minuit
OnCalendar=weekly              # Chaque lundi à minuit
OnCalendar=monthly             # Le 1er de chaque mois à minuit

# Formats personnalisés
OnCalendar=Mon,Fri *-*-* 09:00:00    # Lundi et vendredi à 9h
OnCalendar=*-*-* 02:30:00            # Chaque jour à 2h30
OnCalendar=*-*-01 00:00:00           # Le 1er de chaque mois
OnCalendar=Mon *-*-* 00:00:00        # Chaque lundi
```

> [!tip] Tester une expression OnCalendar
> 
> ```bash
> systemd-analyze calendar "Mon,Fri *-*-* 09:00:00"
> ```

#### Comparaison cron vs systemd timers

|Critère|Cron|Systemd Timers|
|---|---|---|
|Syntaxe|Simple, concise|Plus verbeuse|
|Logs|Dispersés|Centralisés (`journalctl`)|
|Dépendances|Non|Oui|
|Tâches manquées|Ignorées|Peut rattraper (`Persistent=true`)|
|Environnement|Minimal|Complet systemd|
|Courbe d'apprentissage|Faible|Moyenne|

### 3. Autres alternatives

```bash
# anacron - Pour machines non allumées 24/7
# Exécute les tâches manquées au prochain démarrage
sudo apt install anacron

# fcron - Hybride cron/anacron
# Plus flexible que cron standard

# Outils de gestion de configuration
# - Ansible (module cron)
# - Puppet, Chef, Salt
```

---

## ⚠️ Pièges courants

### 1. Pourcentage (`%`)

```bash
# ❌ Le % est interprété comme newline
30 2 * * * /usr/bin/date +%Y-%m-%d

# ✅ Échapper le %
30 2 * * * /usr/bin/date +\%Y-\%m-\%d

# ✅ Ou appeler depuis un script
30 2 * * * /usr/local/bin/date-formatted.sh
```

### 2. PATH limité

```bash
# ❌ Commande introuvable
30 2 * * * python script.py

# ✅ Chemin absolu
30 2 * * * /usr/bin/python3 /home/user/script.py

# ✅ Ou définir PATH
PATH=/usr/local/bin:/usr/bin:/bin
30 2 * * * python3 /home/user/script.py
```

### 3. Répertoire de travail

```bash
# ❌ Fichier introuvable (cron démarre dans HOME)
30 2 * * * ./script.sh

# ✅ cd dans le bon répertoire
30 2 * * * cd /home/user/project && ./script.sh

# ✅ Ou chemin absolu
30 2 * * * /home/user/project/script.sh
```

### 4. Variables d'environnement

```bash
# ❌ $USER, $HOME, etc. peuvent être différents
30 2 * * * echo $USER > /tmp/user.txt

# ✅ Redéfinir ou utiliser des valeurs fixes
HOME=/home/username
30 2 * * * echo $USER > /tmp/user.txt
```

### 5. Sortie non gérée

```bash
# ❌ Génère des emails à chaque exécution
30 2 * * * /chemin/script-verbeux.sh

# ✅ Rediriger la sortie
30 2 * * * /chemin/script.sh > /dev/null 2>&1

# ✅ Ou logger
30 2 * * * /chemin/script.sh >> /var/log/script.log 2>&1
```

### 6. Permissions et propriété

```bash
# ❌ Script non exécutable
-rw-r--r-- 1 user user script.sh

# ✅ Rendre exécutable
chmod +x script.sh

# Vérifier que l'utilisateur cron a accès au fichier
```

### 7. Tâches qui se chevauchent

```bash
# Si une tâche prend plus de temps que l'intervalle
*/5 * * * * /chemin/long-script.sh    # Peut se lancer plusieurs fois

# ✅ Solution : ajouter un lock
*/5 * * * * flock -n /tmp/script.lock /chemin/long-script.sh
```

---

## ✅ Bonnes pratiques

### 1. Toujours utiliser des chemins absolus

```bash
# Commandes
30 2 * * * /usr/bin/rsync ...

# Scripts
30 2 * * * /home/user/scripts/backup.sh

# Fichiers de sortie
30 2 * * * /chemin/script.sh >> /var/log/mon_script.log 2>&1
```

### 2. Commenter vos entrées crontab

```bash
# Backup quotidien de la base de données à 2h30
30 2 * * * /usr/local/bin/db-backup.sh

# Nettoyage des fichiers temporaires tous les lundis
0 3 * * 1 /usr/local/bin/cleanup-temp.sh

# Génération de rapports hebdomadaires (dimanche 23h)
0 23 * * 0 /usr/local/bin/weekly-report.sh
```

### 3. Tester avant de planifier

```bash
# Tester manuellement le script
/chemin/vers/script.sh

# Vérifier la syntaxe crontab
crontab -l | crontab -

# Utiliser at pour un test ponctuel
echo "/chemin/script.sh" | at now + 1 minute
```

### 4. Gérer les logs proprement

```bash
# Logger avec horodatage
30 2 * * * echo "$(date): Début backup" >> /var/log/backup.log; /chemin/backup.sh >> /var/log/backup.log 2>&1

# Rotation des logs (combiner avec logrotate)
# /etc/logrotate.d/mon-script
/var/log/mon-script.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
}
```

### 5. Utiliser un wrapper script

```bash
# /usr/local/bin/cron-wrapper.sh
#!/bin/bash
SCRIPT=$1
LOG_FILE="/var/log/cron/$(basename $SCRIPT .sh).log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Début" >> "$LOG_FILE"
$SCRIPT >> "$LOG_FILE" 2>&1
EXIT_CODE=$?
echo "$(date '+%Y-%m-%d %H:%M:%S') - Fin (code: $EXIT_CODE)" >> "$LOG_FILE"
exit $EXIT_CODE

# Dans crontab
30 2 * * * /usr/local/bin/cron-wrapper.sh /home/user/backup.sh
```

### 6. Définir MAILTO approprié

```bash
# En haut de la crontab
MAILTO=admin@example.com    # Recevoir les erreurs
# ou
MAILTO=""                   # Désactiver les emails

30 2 * * * /chemin/script.sh
```

### 7. Utiliser flock pour éviter les chevauchements

```bash
# Empêcher plusieurs instances simultanées
*/5 * * * * flock -n /tmp/mon-script.lock -c '/chemin/mon-script.sh'

# Ou dans le script lui-même
#!/bin/bash
exec 200>/tmp/mon-script.lock
flock -n 200 || exit 1
# ... reste du script
```

### 8. Documenter l'environnement nécessaire

```bash
# En-tête de la crontab avec contexte
# Crontab pour l'utilisateur backup
# Nécessite : rsync, mysql-client
# Logs : /var/log/backup/
# Contact : admin@example.com

SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=admin@example.com

30 2 * * * /usr/local/bin/backup.sh
```

### 9. Utiliser des outils de validation

```bash
# Valider la syntaxe avant d'installer
crontab -l > /tmp/crontab.bak
nano /tmp/crontab.bak
crontab /tmp/crontab.bak
crontab -l    # Vérifier

# Ou utiliser des outils en ligne
# crontab.guru - validateur de syntaxe cron
```

### 10. Monitoring et alertes

```bash
# Créer un fichier témoin à chaque exécution
30 2 * * * /chemin/backup.sh && touch /tmp/backup_success

# Script de surveillance (cron séparé)
0 8 * * * [ -f /tmp/backup_success ] && rm /tmp/backup_success || echo "Backup failed!" | mail -s "Alert" admin@example.com
```

---

> [!tip] Astuce finale Gardez une copie de votre crontab sous contrôle de version :
> 
> ```bash
> crontab -l > ~/crontab-backup-$(date +%Y%m%d).txt
> # ou
> crontab -l > ~/.config/crontab.conf
> git add ~/.config/crontab.conf && git commit -m "Update crontab"
> ```