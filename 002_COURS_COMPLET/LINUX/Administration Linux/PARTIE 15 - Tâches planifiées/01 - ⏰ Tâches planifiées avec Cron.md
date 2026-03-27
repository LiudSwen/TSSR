

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

## 🎯 Introduction à Cron

**Cron** est le démon (service) standard sous Linux qui permet d'exécuter automatiquement des commandes ou des scripts à des moments précis ou à intervalles réguliers.

> [!info] Pourquoi utiliser Cron ?
> 
> - **Automatisation** : Exécution de tâches répétitives sans intervention manuelle
> - **Maintenance système** : Sauvegardes, rotations de logs, nettoyage de fichiers temporaires
> - **Supervision** : Vérifications périodiques de l'état du système
> - **Traitement batch** : Génération de rapports, synchronisation de données

Le service cron fonctionne en arrière-plan et vérifie chaque minute s'il y a des tâches à exécuter selon les planifications définies dans les **crontabs** (tables de planification).

---

## 📐 Structure de Crontab

### Format de base

Chaque ligne d'un crontab définit une tâche planifiée selon ce format :

```bash
# ┌───────────── minute (0 - 59)
# │ ┌───────────── heure (0 - 23)
# │ │ ┌───────────── jour du mois (1 - 31)
# │ │ │ ┌───────────── mois (1 - 12)
# │ │ │ │ ┌───────────── jour de la semaine (0 - 7) (0 et 7 = dimanche)
# │ │ │ │ │
# * * * * * commande à exécuter
```

> [!example] Exemple simple
> 
> ```bash
> # Exécuter un script tous les jours à 3h30 du matin
> 30 3 * * * /home/user/backup.sh
> ```

### Syntaxe des champs temporels

|Symbole|Signification|Exemple|
|---|---|---|
|`*`|Toutes les valeurs|`* * * * *` = chaque minute|
|`,`|Liste de valeurs|`0,30 * * * *` = à 0 et 30 minutes|
|`-`|Plage de valeurs|`0 9-17 * * *` = de 9h à 17h|
|`/`|Intervalle (step)|`*/15 * * * *` = toutes les 15 minutes|

### Exemples pratiques de planification

```bash
# Toutes les heures à la minute 0
0 * * * * /usr/local/bin/check_status.sh

# Tous les jours à minuit
0 0 * * * /usr/local/bin/daily_cleanup.sh

# Toutes les 15 minutes
*/15 * * * * /usr/local/bin/monitor.sh

# Du lundi au vendredi à 8h30
30 8 * * 1-5 /usr/local/bin/morning_report.sh

# Le 1er de chaque mois à 6h
0 6 1 * * /usr/local/bin/monthly_report.sh

# Tous les dimanches à 2h
0 2 * * 0 /usr/local/bin/weekly_backup.sh

# Toutes les 2 heures entre 9h et 17h
0 9-17/2 * * * /usr/local/bin/check.sh

# Les 1er et 15 du mois à 14h30
30 14 1,15 * * /usr/local/bin/bi_monthly.sh
```

> [!tip] Astuce pour tester vos expressions Utilisez des outils en ligne comme [crontab.guru](https://crontab.guru/) ou [crontab-generator.org](https://crontab-generator.org/) pour valider et comprendre vos expressions cron.

### Variables d'environnement dans crontab

Vous pouvez définir des variables d'environnement en début de crontab :

```bash
# Définir le shell à utiliser
SHELL=/bin/bash

# Définir le PATH
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Rediriger les sorties par email
MAILTO=admin@example.com

# Ou désactiver l'envoi d'emails
MAILTO=""

# Ensuite vos tâches planifiées
30 2 * * * /home/user/backup.sh
```

> [!warning] Attention au PATH Cron utilise un PATH minimal par défaut. Spécifiez toujours les chemins absolus pour vos commandes ou définissez explicitement la variable PATH.

### Chaînes spéciales (@)

Cron supporte des raccourcis pratiques :

|Chaîne|Équivalent|Description|
|---|---|---|
|`@reboot`|-|Au démarrage du système|
|`@yearly` ou `@annually`|`0 0 1 1 *`|Une fois par an (1er janvier à minuit)|
|`@monthly`|`0 0 1 * *`|Une fois par mois (1er du mois à minuit)|
|`@weekly`|`0 0 * * 0`|Une fois par semaine (dimanche à minuit)|
|`@daily` ou `@midnight`|`0 0 * * *`|Une fois par jour (à minuit)|
|`@hourly`|`0 * * * *`|Une fois par heure|

```bash
# Exemples d'utilisation
@reboot /usr/local/bin/startup_script.sh
@daily /usr/local/bin/daily_backup.sh
@hourly /usr/local/bin/check_services.sh
```

---

## 👤 Gestion des crontabs utilisateurs

Chaque utilisateur peut avoir son propre crontab personnel pour planifier des tâches. Ces crontabs sont stockés dans `/var/spool/cron/crontabs/` (le chemin peut varier selon la distribution).

### Commandes principales

#### `crontab -e` : Éditer le crontab

```bash
# Éditer le crontab de l'utilisateur courant
crontab -e

# Éditer le crontab d'un autre utilisateur (en tant que root)
sudo crontab -e -u username
```

> [!info] Éditeur par défaut La commande utilise l'éditeur défini dans la variable `VISUAL` ou `EDITOR`. Pour changer l'éditeur :
> 
> ```bash
> export EDITOR=nano
> crontab -e
> ```

Au premier lancement, le système peut vous demander de choisir un éditeur :

```bash
Select an editor:
  1. /bin/nano        <---- easiest
  2. /usr/bin/vim.basic
  3. /usr/bin/vim.tiny
  4. /bin/ed
```

#### `crontab -l` : Lister le crontab

```bash
# Afficher le crontab de l'utilisateur courant
crontab -l

# Afficher le crontab d'un autre utilisateur (root requis)
sudo crontab -l -u username
```

> [!example] Sortie typique
> 
> ```bash
> $ crontab -l
> # Backup quotidien
> 0 2 * * * /home/user/scripts/backup.sh
> 
> # Nettoyage hebdomadaire
> 0 3 * * 0 /home/user/scripts/cleanup.sh
> ```

#### `crontab -r` : Supprimer le crontab

```bash
# Supprimer TOUT le crontab de l'utilisateur courant
crontab -r

# Supprimer le crontab d'un autre utilisateur (root requis)
sudo crontab -r -u username
```

> [!warning] Attention ! `crontab -r` supprime **TOUTES** les tâches planifiées de l'utilisateur sans confirmation. Pour supprimer une seule tâche, utilisez `crontab -e` et supprimez la ligne concernée.

#### Sauvegarde et restauration

```bash
# Sauvegarder le crontab dans un fichier
crontab -l > mon_crontab_backup.txt

# Restaurer un crontab depuis un fichier
crontab mon_crontab_backup.txt

# Ou via redirection
crontab < mon_crontab_backup.txt
```

> [!tip] Bonne pratique Sauvegardez toujours votre crontab avant de faire des modifications importantes :
> 
> ```bash
> crontab -l > ~/crontab_backup_$(date +%Y%m%d).txt
> crontab -e
> ```

### Contrôle d'accès aux crontabs

Les administrateurs peuvent contrôler qui peut utiliser cron via deux fichiers :

```bash
# /etc/cron.allow : liste des utilisateurs autorisés (prioritaire)
# Si ce fichier existe, SEULS les utilisateurs listés peuvent utiliser cron

# /etc/cron.deny : liste des utilisateurs interdits
# Si cron.allow n'existe pas, tous sauf ceux listés ici peuvent utiliser cron
```

> [!example] Exemple de configuration
> 
> ```bash
> # Autoriser uniquement certains utilisateurs
> echo "alice" | sudo tee /etc/cron.allow
> echo "bob" | sudo tee -a /etc/cron.allow
> 
> # Ou interdire des utilisateurs spécifiques
> echo "mallory" | sudo tee /etc/cron.deny
> ```

Par défaut, si aucun de ces fichiers n'existe, tous les utilisateurs peuvent utiliser cron (sauf si la politique de sécurité du système l'interdit).

---

## 🗂️ Fichiers système de configuration

### `/etc/crontab` : Le crontab système principal

Ce fichier définit des tâches planifiées **à l'échelle du système**. Contrairement aux crontabs utilisateurs, il inclut un champ supplémentaire pour spécifier **quel utilisateur** exécute la commande.

```bash
# Voir le contenu du crontab système
cat /etc/crontab
```

#### Structure du fichier

```bash
# /etc/crontab: system-wide crontab
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user  command
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
```

> [!info] Format avec utilisateur
> 
> ```bash
> # ┌─── minute (0 - 59)
> # │ ┌─── heure (0 - 23)
> # │ │ ┌─── jour du mois (1 - 31)
> # │ │ │ ┌─── mois (1 - 12)
> # │ │ │ │ ┌─── jour de la semaine (0 - 7)
> # │ │ │ │ │ ┌─── utilisateur
> # │ │ │ │ │ │
> # * * * * * user commande
> ```

> [!example] Exemples d'utilisation
> 
> ```bash
> # Exécuter en tant que root tous les jours à 4h
> 0 4 * * * root /usr/local/bin/system_maintenance.sh
> 
> # Exécuter en tant qu'utilisateur www-data toutes les heures
> 0 * * * * www-data /var/www/scripts/cache_cleanup.sh
> 
> # Exécuter en tant que backup_user tous les dimanches
> 0 2 * * 0 backup_user /home/backup_user/weekly_backup.sh
> ```

> [!warning] Ne pas utiliser `crontab -e` pour /etc/crontab Le fichier `/etc/crontab` doit être édité **directement** avec un éditeur (nano, vim) en tant que root :
> 
> ```bash
> sudo nano /etc/crontab
> ```
> 
> N'utilisez PAS `crontab -e` qui gère les crontabs utilisateurs.

### `/etc/cron.d/` : Répertoire de fichiers crontab modulaires

Ce répertoire permet de placer des fichiers de configuration cron **indépendants**, ce qui facilite la gestion par paquets ou applications.

```bash
# Lister les fichiers dans /etc/cron.d/
ls -l /etc/cron.d/
```

#### Caractéristiques

- Chaque fichier suit le **même format** que `/etc/crontab` (avec le champ utilisateur)
- Les fichiers doivent avoir des **permissions strictes** : pas d'exécution, appartenant à root
- Les noms de fichiers ne doivent **pas contenir de point** (sauf avant l'extension)

> [!example] Exemple de fichier `/etc/cron.d/custom-backup`
> 
> ```bash
> # Fichier : /etc/cron.d/custom-backup
> # Backup personnalisé de l'application
> 
> SHELL=/bin/bash
> PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
> MAILTO=admin@example.com
> 
> # Backup quotidien à 3h du matin
> 0 3 * * * backup_user /opt/myapp/scripts/backup.sh >> /var/log/myapp/backup.log 2>&1
> 
> # Vérification des logs toutes les heures
> 0 * * * * root /opt/myapp/scripts/check_logs.sh
> ```

> [!tip] Avantages de /etc/cron.d/
> 
> - **Modularité** : chaque application/service peut avoir son propre fichier
> - **Gestion de paquets** : les paquets peuvent installer/supprimer leurs propres crons facilement
> - **Organisation** : séparation claire des différentes tâches planifiées
> - **Versioning** : plus facile à gérer avec des outils de configuration (Ansible, Puppet)

#### Créer un fichier dans /etc/cron.d/

```bash
# Créer un nouveau fichier cron
sudo nano /etc/cron.d/mon-application

# Définir les permissions appropriées
sudo chmod 644 /etc/cron.d/mon-application
sudo chown root:root /etc/cron.d/mon-application
```

> [!warning] Conventions de nommage
> 
> - Évitez les points dans les noms de fichiers (sauf `.dpkg-dist`, `.dpkg-old`, etc.)
> - Utilisez des tirets ou underscores : `my-app` ou `my_app`
> - Les fichiers avec des noms invalides seront **ignorés silencieusement** par cron

### Comparaison : /etc/crontab vs /etc/cron.d/ vs crontab utilisateur

|Critère|`/etc/crontab`|`/etc/cron.d/`|`crontab -e`|
|---|---|---|---|
|Édition|Éditeur direct (nano, vim)|Éditeur direct|`crontab -e`|
|Champ utilisateur|✅ Requis|✅ Requis|❌ Non (utilisateur courant)|
|Privilèges requis|Root|Root|Utilisateur concerné|
|Usage typique|Configuration système centrale|Tâches modulaires par application|Tâches personnelles utilisateur|
|Gestion de paquets|Déconseillé|✅ Recommandé|Non applicable|
|Permissions|644|644|Gérées automatiquement|

---

## 📁 Répertoires de planification simplifiée

Pour faciliter la gestion des tâches récurrentes courantes, la plupart des distributions Linux fournissent des répertoires prédéfinis où il suffit de placer des scripts pour qu'ils soient exécutés automatiquement.

### Les quatre répertoires standards

```bash
/etc/cron.hourly/   # Scripts exécutés toutes les heures
/etc/cron.daily/    # Scripts exécutés tous les jours
/etc/cron.weekly/   # Scripts exécutés toutes les semaines
/etc/cron.monthly/  # Scripts exécutés tous les mois
```

> [!info] Principe de fonctionnement
> 
> - Ces répertoires sont parcourus par la commande `run-parts` appelée depuis `/etc/crontab` ou par `anacron`
> - **Tout script exécutable** placé dans ces répertoires sera automatiquement lancé
> - Les scripts sont exécutés en tant que **root**
> - L'ordre d'exécution est **alphabétique**

### Utilisation pratique

#### Ajouter un script dans un répertoire

```bash
# 1. Créer votre script
sudo nano /etc/cron.daily/mon-backup

# 2. Rendre le script exécutable (OBLIGATOIRE)
sudo chmod +x /etc/cron.daily/mon-backup

# 3. Vérifier les permissions
ls -l /etc/cron.daily/mon-backup
# Sortie attendue : -rwxr-xr-x 1 root root ...
```

> [!example] Exemple de script `/etc/cron.daily/cleanup-tmp`
> 
> ```bash
> #!/bin/bash
> # Nettoyage des fichiers temporaires de plus de 7 jours
> 
> find /tmp -type f -mtime +7 -delete
> find /var/tmp -type f -mtime +7 -delete
> 
> echo "Nettoyage effectué le $(date)" >> /var/log/cleanup.log
> ```

#### Horaires d'exécution

Les horaires exacts dépendent de la configuration dans `/etc/crontab` :

```bash
# Exemple typique dans /etc/crontab
17 * * * * root cd / && run-parts --report /etc/cron.hourly
25 6 * * * root test -x /usr/sbin/anacron || run-parts --report /etc/cron.daily
47 6 * * 7 root test -x /usr/sbin/anacron || run-parts --report /etc/cron.weekly
52 6 1 * * root test -x /usr/sbin/anacron || run-parts --report /etc/cron.monthly
```

|Répertoire|Horaire par défaut|Jour|
|---|---|---|
|`cron.hourly`|À 17 minutes après chaque heure|Tous les jours|
|`cron.daily`|À 6h25|Tous les jours|
|`cron.weekly`|À 6h47|Dimanches|
|`cron.monthly`|À 6h52|Le 1er du mois|

> [!warning] Anacron peut modifier ces horaires Sur de nombreux systèmes, **anacron** gère l'exécution des répertoires daily/weekly/monthly. Anacron garantit que les tâches soient exécutées même si le système était éteint au moment prévu.

### Tester manuellement l'exécution

```bash
# Exécuter manuellement tous les scripts d'un répertoire
sudo run-parts /etc/cron.daily

# Exécuter en mode test (affiche ce qui serait lancé sans l'exécuter)
sudo run-parts --test /etc/cron.daily

# Voir les détails de ce qui se passe
sudo run-parts --report /etc/cron.daily

# Exécuter un script spécifique
sudo /etc/cron.daily/mon-script
```

### Conventions de nommage des scripts

> [!tip] Bonnes pratiques pour nommer vos scripts
> 
> - Utilisez des noms **sans extension** ou avec des extensions reconnues (`.sh`)
> - Préfixez avec des chiffres pour contrôler l'ordre : `10-backup`, `20-cleanup`, `30-report`
> - Évitez les points dans le nom (sauf avant extension)
> - Utilisez des tirets ou underscores, pas d'espaces

```bash
# ✅ Bons noms
/etc/cron.daily/backup
/etc/cron.daily/backup.sh
/etc/cron.daily/10-backup
/etc/cron.daily/database_backup

# ❌ Noms problématiques
/etc/cron.daily/backup.txt    # Extension non reconnue
/etc/cron.daily/backup.bak    # Sera ignoré
/etc/cron.daily/.backup       # Fichier caché, ignoré
/etc/cron.daily/back up       # Espaces problématiques
```

> [!info] Fichiers ignorés par run-parts `run-parts` ignore automatiquement certains fichiers :
> 
> - Fichiers cachés (commençant par `.`)
> - Fichiers se terminant par `~`, `,`, `.bak`, `.dpkg-old`, etc.
> - Fichiers non exécutables
> - Fichiers contenant des points (selon configuration)

### Désactiver temporairement un script

```bash
# Méthode 1 : Retirer les droits d'exécution
sudo chmod -x /etc/cron.daily/mon-script

# Méthode 2 : Renommer avec une extension ignorée
sudo mv /etc/cron.daily/mon-script /etc/cron.daily/mon-script.disabled

# Méthode 3 : Déplacer hors du répertoire
sudo mv /etc/cron.daily/mon-script /root/scripts-disabled/
```

### Logs et débogage

```bash
# Vérifier les logs d'exécution de cron
sudo grep CRON /var/log/syslog

# Ou sur les systèmes avec systemd
sudo journalctl -u cron

# Voir les dernières exécutions
sudo grep "run-parts" /var/log/syslog
```

> [!example] Sortie typique des logs
> 
> ```bash
> Dec 27 06:25:01 server CRON[12345]: (root) CMD (test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily ))
> Dec 27 06:25:01 server anacron[12346]: Anacron 2.3 started on 2025-12-27
> Dec 27 06:25:01 server anacron[12346]: Normal exit (0 jobs run)
> ```

---

## ⚠️ Pièges courants et bonnes pratiques

### Environnement d'exécution limité

> [!warning] Problème n°1 : PATH minimal Cron utilise un PATH très limité. Les commandes peuvent ne pas être trouvées.
> 
> ```bash
> # ❌ Peut échouer
> */5 * * * * backup.sh
> 
> # ✅ Toujours utiliser des chemins absolus
> */5 * * * * /usr/local/bin/backup.sh
> 
> # ✅ Ou définir le PATH en début de crontab
> PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
> */5 * * * * backup.sh
> ```

> [!warning] Problème n°2 : Variables d'environnement absentes Variables comme `HOME`, `USER`, `DISPLAY` peuvent ne pas être définies ou différentes.
> 
> ```bash
> # ✅ Définir explicitement les variables nécessaires
> HOME=/home/user
> DISPLAY=:0
> 
> 0 9 * * * /usr/local/bin/mon-script.sh
> ```

### Gestion des sorties et erreurs

> [!tip] Toujours rediriger les sorties Par défaut, cron envoie les sorties par email (si `MAILTO` est défini). Cela peut générer beaucoup de spam.
> 
> ```bash
> # ❌ Sortie envoyée par email
> 0 2 * * * /usr/local/bin/backup.sh
> 
> # ✅ Rediriger vers un fichier log
> 0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
> 
> # ✅ Supprimer complètement les sorties (attention, vous perdez les infos)
> 0 2 * * * /usr/local/bin/backup.sh > /dev/null 2>&1
> 
> # ✅ Logger seulement les erreurs
> 0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>> /var/log/backup-errors.log
> ```

### Permissions et sécurité

> [!warning] Attention aux permissions des scripts
> 
> ```bash
> # ✅ Scripts dans /etc/cron.d/ et /etc/crontab
> sudo chmod 644 /etc/cron.d/mon-fichier
> sudo chown root:root /etc/cron.d/mon-fichier
> 
> # ✅ Scripts dans /etc/cron.daily/ etc.
> sudo chmod 755 /etc/cron.daily/mon-script
> sudo chown root:root /etc/cron.daily/mon-script
> ```

> [!tip] Ne jamais rendre les scripts world-writable
> 
> ```bash
> # ❌ DANGER : n'importe qui peut modifier le script
> sudo chmod 777 /etc/cron.daily/mon-script
> 
> # ✅ Permissions sécurisées
> sudo chmod 755 /etc/cron.daily/mon-script
> ```

### Shell et interpréteur

> [!tip] Toujours spécifier le shebang dans vos scripts
> 
> ```bash
> #!/bin/bash
> # ou
> #!/usr/bin/env bash
> # ou pour Python
> #!/usr/bin/env python3
> ```

> [!info] Définir le SHELL dans le crontab si nécessaire
> 
> ```bash
> SHELL=/bin/bash
> 
> 0 2 * * * /usr/local/bin/mon-script.sh
> ```

### Logs et débogage

> [!tip] Techniques de débogage
> 
> ```bash
> # 1. Activer les logs détaillés dans vos scripts
> #!/bin/bash
> set -x  # Mode debug bash
> exec 2>> /var/log/mon-script-debug.log
> 
> # 2. Logger début et fin d'exécution
> echo "$(date): Début du script" >> /var/log/mon-script.log
> # ... votre code ...
> echo "$(date): Fin du script" >> /var/log/mon-script.log
> 
> # 3. Vérifier les logs système
> sudo grep CRON /var/log/syslog | tail -20
> sudo journalctl -u cron -n 50
> ```

> [!example] Template de script robuste
> 
> ```bash
> #!/bin/bash
> 
> # Configuration
> LOGFILE="/var/log/mon-script.log"
> LOCKFILE="/var/run/mon-script.lock"
> 
> # Fonction de log
> log() {
>     echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
> }
> 
> # Vérifier si le script ne tourne pas déjà
> if [ -f "$LOCKFILE" ]; then
>     log "ERREUR: Le script est déjà en cours d'exécution"
>     exit 1
> fi
> 
> # Créer le fichier de lock
> touch "$LOCKFILE"
> 
> # Nettoyer à la sortie
> trap "rm -f $LOCKFILE" EXIT
> 
> # Votre code ici
> log "Début du traitement"
> 
> # Votre logique métier...
> 
> log "Fin du traitement"
> exit 0
> ```

### Gestion du temps et fuseaux horaires

> [!info] Cron utilise l'heure locale du système
> 
> ```bash
> # Vérifier le fuseau horaire
> timedatectl
> 
> # Ou
> cat /etc/timezone
> ```

> [!tip] Pour exécuter en UTC
> 
> ```bash
> # Définir TZ dans le crontab
> TZ=UTC
> 0 2 * * * /usr/local/bin/backup.sh
> ```

### Fréquence d'exécution : éviter les chevauchements

> [!warning] Éviter qu'une tâche se lance avant la fin de la précédente Utilisez un fichier de lock ou des outils comme `flock` :
> 
> ```bash
> # Avec flock (empêche l'exécution simultanée)
> */5 * * * * flock -n /var/lock/mon-script.lock /usr/local/bin/mon-script.sh
> 
> # Ou dans le script lui-même
> #!/bin/bash
> LOCKFILE=/var/lock/mon-script.lock
> 
> exec 200>"$LOCKFILE"
> flock -n 200 || exit 1
> 
> # Votre code ici...
> ```

### Test avant mise en production

> [!tip] Toujours tester vos tâches planifiées
> 
> ```bash
> # 1. Tester le script manuellement
> sudo /usr/local/bin/mon-script.sh
> 
> # 2. Tester avec l'environnement cron
> sudo -u www-data env -i
> ```