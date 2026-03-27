

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

## 🎯 Introduction à cron

**Cron** est le planificateur de tâches standard sous Linux/Unix qui permet d'exécuter automatiquement des commandes ou scripts à des moments précis ou à intervalles réguliers.

> [!info] Pourquoi utiliser cron avec rsync ? Cron permet d'automatiser vos synchronisations rsync pour :
> 
> - Effectuer des sauvegardes régulières sans intervention manuelle
> - Synchroniser des données pendant les heures creuses
> - Garantir la cohérence et la régularité des backups
> - Libérer l'administrateur des tâches répétitives

### Daemon cron

Le service cron s'exécute en arrière-plan et vérifie toutes les minutes s'il y a des tâches à exécuter.

```bash
# Vérifier l'état du service cron
systemctl status cron      # Debian/Ubuntu
systemctl status crond     # RedHat/CentOS

# Démarrer/activer cron si nécessaire
systemctl start cron
systemctl enable cron
```

---

## 📐 Structure d'une ligne crontab

Une tâche cron (appelée "cron job") est définie sur une ligne avec 6 champs :

```
┌───────────── minute (0 - 59)
│ ┌───────────── heure (0 - 23)
│ │ ┌───────────── jour du mois (1 - 31)
│ │ │ ┌───────────── mois (1 - 12)
│ │ │ │ ┌───────────── jour de la semaine (0 - 7, 0 et 7 = dimanche)
│ │ │ │ │
│ │ │ │ │
* * * * * commande-à-exécuter
```

### Syntaxe des champs temporels

|Symbole|Signification|Exemple|
|---|---|---|
|`*`|Toutes les valeurs|`*` dans le champ heure = toutes les heures|
|`,`|Liste de valeurs|`1,15,30` = aux minutes 1, 15 et 30|
|`-`|Plage de valeurs|`1-5` = du lundi au vendredi|
|`/`|Intervalle|`*/15` = toutes les 15 minutes|
|Nombre|Valeur spécifique|`30` dans minute = à la 30ème minute|

> [!example] Exemples de planifications
> 
> ```bash
> # Tous les jours à 2h30
> 30 2 * * * /chemin/script.sh
> 
> # Toutes les heures
> 0 * * * * /chemin/script.sh
> 
> # Toutes les 15 minutes
> */15 * * * * /chemin/script.sh
> 
> # Du lundi au vendredi à 18h
> 0 18 * * 1-5 /chemin/script.sh
> 
> # Le 1er de chaque mois à minuit
> 0 0 1 * * /chemin/script.sh
> 
> # Les dimanches à 3h
> 0 3 * * 0 /chemin/script.sh
> ```

---

## 🛠️ Création et gestion des tâches cron

### Éditer la crontab de l'utilisateur

Chaque utilisateur possède sa propre crontab :

```bash
# Éditer la crontab de l'utilisateur courant
crontab -e

# Lister les tâches cron de l'utilisateur courant
crontab -l

# Supprimer toute la crontab de l'utilisateur
crontab -r

# Éditer la crontab d'un autre utilisateur (en root)
crontab -u nom_utilisateur -e
```

> [!tip] Premier lancement de crontab -e À la première utilisation, le système vous demandera de choisir un éditeur (nano, vim, etc.). Pour les débutants, **nano** est recommandé.

### Crontab système

Pour les tâches système, vous pouvez également placer des fichiers dans :

```bash
/etc/cron.d/          # Fichiers de crontab système
/etc/cron.hourly/     # Scripts exécutés toutes les heures
/etc/cron.daily/      # Scripts exécutés quotidiennement
/etc/cron.weekly/     # Scripts exécutés hebdomadairement
/etc/cron.monthly/    # Scripts exécutés mensuellement
```

> [!warning] Permissions des scripts Les scripts dans `/etc/cron.*/` doivent être **exécutables** et **ne pas avoir d'extension** :
> 
> ```bash
> chmod +x /etc/cron.daily/backup-rsync
> # Pas de .sh à la fin du nom !
> ```

---

## 🕐 Fréquences courantes pour rsync

Voici des exemples pratiques de planification pour différents besoins de synchronisation :

### Sauvegardes quotidiennes

```bash
# Sauvegarde quotidienne à 2h du matin (heure creuse)
0 2 * * * /usr/local/bin/backup-home.sh >> /var/log/rsync-backup.log 2>&1

# Sauvegarde tous les soirs à 23h
0 23 * * * /root/scripts/rsync-daily.sh

# Sauvegarde en semaine à 1h du matin
0 1 * * 1-5 /opt/backups/rsync-workdays.sh
```

### Sauvegardes fréquentes

```bash
# Toutes les 6 heures
0 */6 * * * /usr/local/bin/sync-data.sh

# Toutes les heures en journée (8h-18h)
0 8-18 * * * /home/user/scripts/hourly-sync.sh

# Toutes les 30 minutes
*/30 * * * * /opt/sync/frequent-sync.sh
```

### Sauvegardes hebdomadaires

```bash
# Tous les dimanches à 3h (backup complet)
0 3 * * 0 /root/scripts/weekly-full-backup.sh

# Tous les vendredis soir à 22h
0 22 * * 5 /usr/local/bin/friday-backup.sh
```

### Sauvegardes mensuelles

```bash
# Le 1er de chaque mois à minuit
0 0 1 * * /root/scripts/monthly-archive.sh

# Le dernier jour du mois à 23h30 (approximatif avec jour 28)
30 23 28-31 * * [ "$(date +\%d -d tomorrow)" = "01" ] && /root/scripts/end-of-month.sh
```

> [!example] Stratégie de sauvegarde 3-2-1 Exemple de planification complète :
> 
> ```bash
> # Incrémental quotidien à 2h
> 0 2 * * * /opt/backup/rsync-incremental.sh
> 
> # Complet hebdomadaire dimanche à 3h
> 0 3 * * 0 /opt/backup/rsync-full.sh
> 
> # Archive mensuelle le 1er à minuit
> 0 0 1 * * /opt/backup/rsync-monthly-archive.sh
> ```

---

## 📤 Redirection des sorties

Par défaut, cron envoie la sortie des commandes par email à l'utilisateur. Il est crucial de bien gérer ces sorties.

### Redirections de base

```bash
# Rediriger stdout vers un fichier log
0 2 * * * /script.sh >> /var/log/backup.log

# Rediriger stderr vers un fichier log
0 2 * * * /script.sh 2>> /var/log/backup-errors.log

# Rediriger stdout ET stderr vers le même fichier
0 2 * * * /script.sh >> /var/log/backup.log 2>&1

# Tout ignorer (silence complet - déconseillé)
0 2 * * * /script.sh > /dev/null 2>&1
```

> [!info] Comprendre les descripteurs
> 
> - `1` ou `stdout` : sortie standard (résultats normaux)
> - `2` ou `stderr` : sortie d'erreur (messages d'erreur)
> - `2>&1` : redirige stderr vers stdout

### Gestion des emails cron

```bash
# Définir l'adresse email pour les notifications (en tête de crontab)
MAILTO=admin@example.com

# Désactiver les emails
MAILTO=""

# Exemple complet
MAILTO=backup-admin@company.com
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

0 2 * * * /opt/backup/rsync-daily.sh >> /var/log/rsync.log 2>&1
```

### Rotation des logs

Pour éviter que les fichiers de logs ne deviennent trop volumineux :

```bash
# Script avec horodatage dans le nom du log
0 2 * * * /script.sh >> /var/log/backup-$(date +\%Y\%m\%d).log 2>&1

# Avec logrotate (configuration séparée recommandée)
0 2 * * * /script.sh >> /var/log/backup.log 2>&1
```

Fichier `/etc/logrotate.d/rsync-backup` :

```
/var/log/rsync-backup.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
```

> [!tip] Logs structurés Ajoutez des timestamps dans vos scripts pour faciliter le débogage :
> 
> ```bash
> echo "[$(date '+%Y-%m-%d %H:%M:%S')] Début de la sauvegarde" >> /var/log/backup.log
> rsync -avz /source /dest >> /var/log/backup.log 2>&1
> echo "[$(date '+%Y-%m-%d %H:%M:%S')] Fin de la sauvegarde" >> /var/log/backup.log
> ```

---

## 🔧 Environnement et chemins dans cron

Cron s'exécute avec un **environnement minimal**, ce qui diffère d'une session shell interactive.

### Variables d'environnement limitées

```bash
# Variables disponibles par défaut dans cron
HOME=/home/utilisateur
LOGNAME=utilisateur
PATH=/usr/bin:/bin
SHELL=/bin/sh
```

> [!warning] Problème fréquent : commande introuvable Les commandes qui fonctionnent en ligne de commande peuvent échouer dans cron si elles ne sont pas dans le PATH minimal.

### Définir des variables dans crontab

```bash
# En tête de la crontab
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=admin@example.com
HOME=/root

# Tâches cron
0 2 * * * /opt/backup/rsync-daily.sh
```

### Utiliser des chemins absolus

```bash
# ❌ MAUVAIS - peut ne pas fonctionner
0 2 * * * rsync -avz /data /backup

# ✅ BON - chemin absolu
0 2 * * * /usr/bin/rsync -avz /data /backup

# ✅ ENCORE MIEUX - script avec tous les chemins absolus
0 2 * * * /usr/local/bin/backup-script.sh
```

> [!tip] Trouver le chemin absolu d'une commande
> 
> ```bash
> which rsync
> # Résultat : /usr/bin/rsync
> 
> which ssh-agent
> # Utiliser ce chemin dans votre crontab
> ```

### Sourcer l'environnement

Si votre script nécessite des variables d'environnement spécifiques :

```bash
# Dans la crontab
0 2 * * * . /home/user/.profile && /home/user/scripts/backup.sh

# Ou dans le script lui-même
#!/bin/bash
source /home/user/.bashrc
# ... reste du script
```

---

## ✅ Bonnes pratiques

### 1. Toujours tester avant de planifier

```bash
# Tester le script manuellement
/usr/local/bin/backup-script.sh

# Tester avec l'environnement cron simulé
env -i HOME=$HOME /usr/local/bin/backup-script.sh

# Planifier pour s'exécuter dans quelques minutes pour test
# (ajouter temporairement dans crontab -e)
25 14 * * * /usr/local/bin/backup-script.sh >> /var/log/test.log 2>&1
# Puis vérifier le log après exécution
```

### 2. Utiliser le verrouillage pour éviter les exécutions multiples

Si une synchronisation prend plus de temps que l'intervalle de cron :

```bash
#!/bin/bash
LOCKFILE=/var/lock/rsync-backup.lock

# Vérifier si le script est déjà en cours
if [ -f "$LOCKFILE" ]; then
    echo "Une sauvegarde est déjà en cours" >&2
    exit 1
fi

# Créer le fichier de verrouillage
touch "$LOCKFILE"

# Nettoyer le fichier de verrouillage à la fin
trap "rm -f $LOCKFILE" EXIT

# Exécuter rsync
rsync -avz /source /destination
```

Ou avec `flock` (plus robuste) :

```bash
# Dans crontab
0 2 * * * flock -n /var/lock/rsync.lock /usr/local/bin/backup-script.sh
```

### 3. Documenter vos tâches cron

```bash
# Mauvais - aucun commentaire
0 2 * * * /opt/backup.sh

# Bon - avec commentaire explicatif
# Sauvegarde quotidienne des homes vers NAS - Ticket #1234
# Responsable: admin@company.com
0 2 * * * /opt/scripts/backup-homes.sh >> /var/log/backup-homes.log 2>&1
```

### 4. Centraliser les scripts

```bash
# Structure recommandée
/opt/scripts/           # Scripts de production
/opt/scripts/backup/    # Scripts de sauvegarde rsync
/var/log/scripts/       # Logs des scripts
/etc/rsync/             # Fichiers de configuration rsync
```

### 5. Gérer les codes de retour

```bash
#!/bin/bash
rsync -avz /source /dest >> /var/log/backup.log 2>&1

if [ $? -eq 0 ]; then
    echo "[$(date)] Sauvegarde réussie" >> /var/log/backup.log
else
    echo "[$(date)] ERREUR lors de la sauvegarde" >> /var/log/backup.log
    # Optionnel : envoyer une alerte
    mail -s "Erreur backup" admin@company.com < /var/log/backup.log
fi
```

### 6. Utiliser des timeouts

Pour éviter qu'un rsync bloqué ne consume des ressources indéfiniment :

```bash
# Dans crontab avec timeout
0 2 * * * timeout 2h /usr/local/bin/backup-script.sh

# Ou dans le script
#!/bin/bash
timeout 7200 rsync -avz /source /dest
```

---

## ⚠️ Pièges courants

### Piège #1 : Caractères spéciaux non échappés

```bash
# ❌ Problème avec %
0 2 * * * echo $(date +%Y%m%d)  # Le % sera mal interprété

# ✅ Solution : échapper avec \
0 2 * * * echo $(date +\%Y\%m\%d)

# ✅ Alternative : utiliser un script
0 2 * * * /usr/local/bin/backup-with-date.sh
```

### Piège #2 : Permissions insuffisantes

```bash
# Le script doit être exécutable
chmod +x /opt/scripts/backup.sh

# L'utilisateur cron doit avoir accès aux fichiers
# Si besoin, utiliser sudo dans crontab (avec configuration sudoers)
0 2 * * * sudo /opt/scripts/backup-root.sh
```

### Piège #3 : Oublier les redirections

```bash
# ❌ Sans redirection, cron essaie d'envoyer un email à chaque exécution
0 2 * * * /backup.sh

# ✅ Rediriger vers un log
0 2 * * * /backup.sh >> /var/log/backup.log 2>&1
```

### Piège #4 : Mauvaise interprétation des jours

```bash
# ⚠️ ATTENTION : Ceci s'exécute si c'est le 1er OU un lundi
0 2 1 * 1 /script.sh

# Les champs jour du mois et jour de la semaine sont en OU, pas en ET
# Pour "le 1er lundi du mois", il faut un script plus complexe
```

### Piège #5 : Cron ne se recharge pas automatiquement

```bash
# ❌ Après modification de /etc/crontab
# Cron ne détecte pas toujours le changement

# ✅ Recharger cron après modification
systemctl reload cron
```

> [!warning] Crontab utilisateur vs crontab système
> 
> - `crontab -e` : se recharge automatiquement après sauvegarde
> - `/etc/crontab` et `/etc/cron.d/*` : nécessitent parfois un reload de cron

### Piège #6 : Timezone et changement d'heure

```bash
# Définir la timezone dans la crontab si nécessaire
TZ=Europe/Paris
0 2 * * * /backup.sh

# Attention aux changements d'heure : une tâche à 2h30 peut être sautée ou exécutée deux fois
# lors du passage à l'heure d'été/hiver
```

---

## 🎯 Exemple complet : Planification d'une stratégie de sauvegarde

Fichier `/etc/cron.d/rsync-backups` :

```bash
# Cron jobs pour sauvegardes rsync
# Responsable: admin@company.com
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=backup-admin@company.com

# Sauvegarde incrémentale toutes les 6 heures
0 */6 * * * root /opt/scripts/backup/rsync-incremental.sh >> /var/log/backup/incremental.log 2>&1

# Sauvegarde complète quotidienne à 2h
0 2 * * * root flock -n /var/lock/rsync-daily.lock /opt/scripts/backup/rsync-daily.sh >> /var/log/backup/daily.log 2>&1

# Sauvegarde hebdomadaire dimanche à 3h
0 3 * * 0 root /opt/scripts/backup/rsync-weekly.sh >> /var/log/backup/weekly.log 2>&1

# Nettoyage mensuel des anciennes sauvegardes (1er du mois à 4h)
0 4 1 * * root /opt/scripts/backup/cleanup-old-backups.sh >> /var/log/backup/cleanup.log 2>&1

# Vérification de l'intégrité des backups (tous les lundis à 5h)
0 5 * * 1 root /opt/scripts/backup/verify-backups.sh >> /var/log/backup/verify.log 2>&1
```

---

> [!tip] Astuce finale Pour déboguer une tâche cron qui ne fonctionne pas :
> 
> 1. Vérifiez les logs système : `grep CRON /var/log/syslog`
> 2. Vérifiez que le service cron est actif : `systemctl status cron`
> 3. Testez votre script manuellement avec l'environnement minimal
> 4. Ajoutez un maximum de logs dans votre script
> 5. Vérifiez les permissions et les chemins absolus