

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

## Introduction à la commande at

La commande **`at`** permet de planifier l'exécution de tâches **ponctuelles** à un moment précis dans le futur. Contrairement aux autres mécanismes de planification qui gèrent des tâches récurrentes, `at` est conçu pour des exécutions uniques.

> [!info] Définition `at` est un planificateur de tâches qui exécute des commandes **une seule fois** à une date et heure spécifiées. Une fois la tâche exécutée, elle disparaît automatiquement de la file d'attente.

---

## Pourquoi utiliser at ?

|Situation|Exemple d'utilisation|
|---|---|
|🔄 Tâche ponctuelle|Redémarrer un service ce soir à minuit|
|📅 Action différée|Envoyer un email dans 2 heures|
|🛠️ Maintenance planifiée|Lancer un script de sauvegarde demain à 3h|
|⏱️ Rappel système|Arrêter un processus dans 30 minutes|
|🧪 Tests temporisés|Exécuter un benchmark dans 5 minutes|

> [!tip] Quand choisir at plutôt que cron ?
> 
> - **at** : tâche unique, planification immédiate, syntaxe naturelle
> - **cron** : tâches récurrentes, planification régulière, plus complexe

---

## Installation et prérequis

### Vérifier la présence de at

```bash
# Vérifier si at est installé
which at

# Vérifier le service atd (daemon)
systemctl status atd
```

### Installation si nécessaire

```bash
# Debian/Ubuntu
sudo apt install at

# RHEL/CentOS/Rocky/Alma
sudo yum install at

# Arch Linux
sudo pacman -S at
```

### Démarrer et activer le service

```bash
# Démarrer le daemon atd
sudo systemctl start atd

# Activer au démarrage
sudo systemctl enable atd

# Vérifier le statut
sudo systemctl status atd
```

> [!warning] Service obligatoire Le daemon **`atd`** doit être actif pour que les tâches `at` s'exécutent. Sans lui, les commandes planifiées ne seront jamais lancées.

---

## Syntaxe et utilisation de at

### Syntaxe de base

```bash
at [OPTIONS] TIME
```

### Formats de temps acceptés

`at` accepte une grande variété de formats temporels, ce qui le rend très flexible :

#### Formats absolus

```bash
# Heure précise (aujourd'hui si futur, sinon demain)
at 14:30
at 2:30pm
at 02:30

# Date et heure complètes
at 14:30 2024-12-25
at 2:30pm Dec 25
at 14:30 tomorrow
at 14:30 next monday
at 14:30 next week
```

#### Formats relatifs

```bash
# Dans X minutes/heures/jours
at now + 30 minutes
at now + 2 hours
at now + 3 days
at now + 1 week

# Combinaisons
at now + 1 hour + 30 minutes
at 14:30 + 2 days
```

#### Mots-clés spéciaux

```bash
at midnight      # Minuit prochain
at noon          # Midi prochain
at teatime       # 16:00 (heure du thé britannique!)
at tomorrow      # Même heure demain
at next week     # Même heure la semaine prochaine
```

> [!example] Exemples pratiques de formats
> 
> ```bash
> # Exécuter ce soir à 23h30
> at 11:30pm
> 
> # Dans exactement 15 minutes
> at now + 15 minutes
> 
> # Demain matin à 7h
> at 7am tomorrow
> 
> # Vendredi prochain à 18h
> at 6pm friday
> 
> # Le 31 décembre à minuit
> at midnight 12/31/2024
> ```

---

### Modes de saisie des commandes

Il existe plusieurs façons de fournir les commandes à exécuter :

#### Mode interactif (par défaut)

```bash
# Lancer at en mode interactif
at 15:00

# Vous entrez alors dans un prompt at>
at> /usr/local/bin/backup.sh
at> echo "Backup terminé" | mail -s "Backup" admin@example.com
at> <Ctrl+D>  # Terminer la saisie

# Message de confirmation
job 42 at Wed Dec 27 15:00:00 2024
```

> [!tip] Terminer la saisie Appuyez sur **Ctrl+D** (EOF) pour valider et quitter le mode interactif. Ne confondez pas avec Ctrl+C qui annulerait la création de la tâche !

#### Redirection depuis un fichier

```bash
# Créer un script de commandes
cat > /tmp/taches.sh << 'EOF'
#!/bin/bash
systemctl restart nginx
echo "Nginx redémarré à $(date)" >> /var/log/restart.log
EOF

# Planifier l'exécution du fichier
at midnight < /tmp/taches.sh
```

#### Avec echo et pipe

```bash
# Une seule commande
echo "systemctl restart apache2" | at now + 30 minutes

# Plusieurs commandes (séparées par des retours à la ligne)
echo -e "cd /backup\n./daily-backup.sh\nmail -s 'Backup OK' admin@localhost" | at 2am
```

#### Avec l'option -f (fichier)

```bash
# Exécuter le contenu d'un script
at -f /root/maintenance.sh midnight

# Équivalent à
at midnight < /root/maintenance.sh
```

---

## Gestion des tâches planifiées

### atq - Lister les tâches

La commande **`atq`** (at queue) affiche toutes les tâches en attente.

```bash
# Lister toutes les tâches at en attente
atq

# Sortie exemple :
# 42    Wed Dec 27 15:00:00 2024 a user1
# 43    Thu Dec 28 02:00:00 2024 a user1
# 44    Wed Dec 27 23:30:00 2024 a root
```

#### Format de sortie

```
[ID] [DATE] [HEURE] [ANNÉE] [QUEUE] [UTILISATEUR]
```

|Colonne|Description|
|---|---|
|ID|Numéro unique de la tâche (job number)|
|DATE/HEURE|Moment prévu d'exécution|
|QUEUE|File d'attente (par défaut : `a`)|
|UTILISATEUR|Propriétaire de la tâche|

```bash
# Équivalent alternatif
at -l

# Lister uniquement ses propres tâches (utilisateur courant)
atq
```

> [!info] Files d'attente (queues) Par défaut, `at` utilise la queue `a`. Il est possible d'utiliser d'autres queues (a-z, A-Z) avec l'option `-q`, chacune ayant potentiellement une priorité différente (nice value).

---

### atrm - Supprimer des tâches

La commande **`atrm`** (at remove) permet de supprimer des tâches en attente.

```bash
# Supprimer une tâche par son ID
atrm 42

# Supprimer plusieurs tâches
atrm 42 43 44

# Équivalent alternatif
at -r 42
at -d 42  # d pour delete
```

#### Workflow typique

```bash
# 1. Lister les tâches
atq
# 42    Wed Dec 27 15:00:00 2024 a user1
# 43    Thu Dec 28 02:00:00 2024 a user1

# 2. Supprimer la tâche 42
atrm 42

# 3. Vérifier
atq
# 43    Thu Dec 28 02:00:00 2024 a user1
```

> [!warning] Suppression définitive La suppression d'une tâche avec `atrm` est **immédiate et irréversible**. Aucune confirmation n'est demandée. Vérifiez bien l'ID avant de supprimer !

---

### at -c - Afficher le contenu d'une tâche

L'option **`-c`** affiche le contenu complet d'une tâche planifiée, incluant l'environnement d'exécution.

```bash
# Afficher le contenu de la tâche numéro 42
at -c 42
```

#### Sortie typique

```bash
#!/bin/sh
# atrun uid=1000 gid=1000
# mail user1 0
umask 22

# Beaucoup de variables d'environnement...
SHELL=/bin/bash
HOME=/home/user1
LOGNAME=user1
USER=user1
PATH=/usr/local/bin:/usr/bin:/bin
PWD=/home/user1
...

# La commande réellement planifiée
/usr/local/bin/backup.sh
echo "Backup terminé" | mail -s "Backup" admin@example.com
```

> [!tip] Utilité de at -c Cette commande est précieuse pour :
> 
> - Vérifier les commandes planifiées avant leur exécution
> - Déboguer une tâche qui ne fonctionne pas comme prévu
> - Comprendre l'environnement d'exécution (variables, chemins)
> - Copier une tâche pour la recréer avec modifications

---

## Variables d'environnement et contexte

Lorsque `at` exécute une tâche, il préserve l'environnement du moment de la planification.

### Ce qui est préservé

```bash
# Ces variables sont capturées au moment de la planification
- SHELL      # Shell utilisé
- HOME       # Répertoire personnel
- USER       # Utilisateur
- LOGNAME    # Nom de login
- PATH       # Chemins d'exécution
- PWD        # Répertoire de travail courant
- LANG       # Locale
- Et beaucoup d'autres...
```

### Implications pratiques

```bash
# Si vous planifiez depuis /home/user1
cd /home/user1
at midnight
at> ./script.sh  # S'exécutera dans /home/user1
at> <Ctrl+D>

# Le PWD est préservé !
```

> [!warning] Attention au PATH Les commandes sont exécutées avec le PATH du moment de la planification. Si vous modifiez votre PATH après avoir créé la tâche, cela n'affectera pas la tâche déjà planifiée.

### Forcer un environnement spécifique

```bash
# Définir explicitement des variables dans la tâche
at midnight
at> export PATH=/usr/local/bin:/usr/bin:/bin
at> cd /var/www
at> ./deploy.sh
at> <Ctrl+D>
```

---

## Contrôle d'accès

### Fichiers de contrôle

L'accès à `at` est contrôlé par deux fichiers :

|Fichier|Localisation|Fonction|
|---|---|---|
|**`/etc/at.allow`**|Prioritaire|Liste des utilisateurs **autorisés**|
|**`/etc/at.deny`**|Secondaire|Liste des utilisateurs **interdits**|

### Logique de contrôle

```bash
# Ordre de priorité :
# 1. Si at.allow existe → seuls les utilisateurs listés sont autorisés
# 2. Sinon, si at.deny existe → tous sauf ceux listés sont autorisés
# 3. Sinon, comportement par défaut (dépend de la distribution)
```

#### Configuration avec at.allow

```bash
# Créer at.allow pour autoriser uniquement certains utilisateurs
sudo nano /etc/at.allow

# Contenu : un utilisateur par ligne
root
user1
admin
backup

# Résultat : seuls ces utilisateurs peuvent utiliser at
```

#### Configuration avec at.deny

```bash
# Interdire des utilisateurs spécifiques
sudo nano /etc/at.deny

# Contenu : un utilisateur par ligne
guest
testuser
temporary

# Résultat : tous les utilisateurs SAUF ceux-ci peuvent utiliser at
```

> [!warning] Sécurité Par défaut sur de nombreux systèmes, **tous les utilisateurs peuvent utiliser at**. Sur un système en production, pensez à restreindre l'accès via `at.allow`.

### Vérifier les permissions

```bash
# Tester en tant qu'utilisateur
at now + 1 minute
at> echo "Test"
at> <Ctrl+D>

# Si refusé :
# You do not have permission to use at.
```

---

## Sorties et notifications

### Gestion des sorties

Par défaut, **toute sortie** (stdout et stderr) d'une commande `at` est envoyée par **email** à l'utilisateur qui a planifié la tâche.

```bash
# Cette commande enverra un mail avec la sortie
echo "df -h" | at now + 1 minute

# L'utilisateur recevra un mail contenant le résultat de df -h
```

### Rediriger les sorties

Pour éviter les emails, redirigez explicitement les sorties :

```bash
# Redirection vers un fichier
at midnight
at> /backup/script.sh > /var/log/backup.log 2>&1
at> <Ctrl+D>

# Suppression complète des sorties
at 2am
at> /maintenance.sh > /dev/null 2>&1
at> <Ctrl+D>
```

### Forcer l'envoi d'emails

```bash
# Envoyer un rapport explicite
at midnight
at> /backup/script.sh > /tmp/backup.log 2>&1
at> mail -s "Backup Report" admin@localhost < /tmp/backup.log
at> <Ctrl+D>
```

> [!tip] Bonnes pratiques de logging
> 
> - Toujours rediriger vers des fichiers pour les tâches importantes
> - Utiliser des noms de logs explicites avec timestamps
> - Configurer la rotation des logs si nécessaire
> - N'utiliser l'email que pour les notifications critiques

---

## Pièges courants

### 1. Service atd non démarré

```bash
# Symptôme : les tâches sont créées mais ne s'exécutent jamais
atq  # Affiche des tâches
# Mais rien ne se passe !

# Solution :
sudo systemctl start atd
sudo systemctl enable atd
```

### 2. Chemins relatifs

```bash
# ❌ Piège : chemin relatif
at midnight
at> ./script.sh  # Pourrait ne pas fonctionner
at> <Ctrl+D>

# ✅ Solution : chemin absolu
at midnight
at> /home/user/scripts/script.sh
at> <Ctrl+D>
```

### 3. Variables non définies

```bash
# ❌ Piège : variable shell non exportée
MY_VAR="valeur"
echo "echo $MY_VAR" | at now + 1 minute
# La variable sera vide à l'exécution !

# ✅ Solution : définir dans la commande
echo 'MY_VAR="valeur"; echo $MY_VAR' | at now + 1 minute
```

### 4. Permissions insuffisantes

```bash
# ❌ Piège : script sans droits d'exécution
at midnight
at> /root/script.sh  # Erreur si non exécutable
at> <Ctrl+D>

# ✅ Solution : vérifier les permissions
chmod +x /root/script.sh
# Ou appeler explicitement le shell
at midnight
at> /bin/bash /root/script.sh
at> <Ctrl+D>
```

### 5. Dates dans le passé

```bash
# ❌ at refuse les dates passées
at 10:00
# Si il est déjà 14:00, at planifiera pour 10:00 DEMAIN

# Vérifiez toujours avec atq après création !
atq
```

### 6. Environnement différent

```bash
# ❌ Piège : compter sur l'environnement interactif
at midnight
at> my_custom_command  # Commande dans PATH personnel
at> <Ctrl+D>

# ✅ Solution : utiliser des chemins absolus
at midnight
at> /usr/local/bin/my_custom_command
at> <Ctrl+D>
```

---

## Bonnes pratiques

### 1. Toujours utiliser des chemins absolus

```bash
# ✅ Bon
at midnight
at> /usr/bin/python3 /opt/scripts/backup.py
at> <Ctrl+D>

# ❌ À éviter
at midnight
at> python3 backup.py
at> <Ctrl+D>
```

### 2. Loguer toutes les exécutions

```bash
# Créer une fonction de logging
at midnight << 'EOF'
#!/bin/bash
LOG="/var/log/myapp/scheduled-$(date +%Y%m%d-%H%M%S).log"
{
    echo "=== Début : $(date) ==="
    /opt/myapp/task.sh
    echo "=== Fin : $(date) - Exit code: $? ==="
} > "$LOG" 2>&1
EOF
```

### 3. Vérifier immédiatement après création

```bash
# Planifier une tâche
at 23:30
at> /backup/run.sh
at> <Ctrl+D>

# Vérifier IMMÉDIATEMENT
atq
at -c [ID_de_la_tache]  # Inspecter le contenu
```

### 4. Documenter les tâches planifiées

```bash
# Ajouter des commentaires explicites
at midnight
at> # Sauvegarde quotidienne de la base de données
at> # Planifié par: admin
at> # Date: 2024-12-27
at> /usr/local/bin/db-backup.sh
at> <Ctrl+D>
```

### 5. Gérer les erreurs

```bash
# Script avec gestion d'erreurs
at 2am << 'EOF'
#!/bin/bash
set -e  # Arrêter en cas d'erreur

if ! /backup/script.sh > /var/log/backup.log 2>&1; then
    echo "ERREUR: Échec du backup" | mail -s "Backup FAILED" admin@localhost
    exit 1
fi

echo "Backup réussi" | mail -s "Backup OK" admin@localhost
EOF
```

### 6. Nettoyer les anciennes tâches

```bash
# Vérifier régulièrement les tâches en attente
atq

# Supprimer les tâches obsolètes
atrm [IDs_obsoletes]
```

---

## Astuces avancées

### 1. Utiliser des queues avec priorités

```bash
# Queue 'a' (nice 0, priorité normale, par défaut)
at -q a midnight
at> /backup/normal.sh
at> <Ctrl+D>

# Queue 'b' (nice 2, priorité plus basse)
at -q b midnight
at> /backup/low-priority.sh
at> <Ctrl+D>

# Queue inversement prioritaire avec 'A' (nice -2, haute priorité)
sudo at -q A midnight
at> /critical/task.sh
at> <Ctrl+D>
```

### 2. Planifier une tâche conditionnelle

```bash
# Exécuter seulement si une condition est vraie
at 3am << 'EOF'
#!/bin/bash
if [ -f /tmp/trigger.flag ]; then
    /opt/scripts/conditional-task.sh
    rm /tmp/trigger.flag
fi
EOF
```

### 3. Chaîner des tâches at

```bash
# Créer une tâche qui planifie la suivante
at now + 5 minutes << 'EOF'
#!/bin/bash
echo "Première tâche exécutée"
# Planifier la tâche suivante
echo "/next/task.sh" | at now + 10 minutes
EOF
```

### 4. Utiliser batch pour charge système basse

```bash
# batch est une variante de at qui attend que la charge soit basse
# (généralement < 1.5 de load average)
batch
at> /heavy/computation.sh
at> <Ctrl+D>

# Équivalent à : at -q b -m now
```

### 5. Copier/migrer une tâche

```bash
# Sauvegarder le contenu d'une tâche
at -c 42 > /tmp/task-42.sh

# Modifier si nécessaire
nano /tmp/task-42.sh

# Replanifier
at midnight < /tmp/task-42.sh
```

### 6. Planifier avec des calculs de date complexes

```bash
# Utiliser date pour calculer des dates complexes
NEXT_MONDAY=$(date -d "next monday" +"%Y-%m-%d")
at 09:00 $NEXT_MONDAY
at> /reports/weekly-report.sh
at> <Ctrl+D>

# Dernier jour du mois prochain à minuit
LAST_DAY=$(date -d "$(date -d '+1 month' +%Y-%m-01) -1 day" +"%Y-%m-%d")
at midnight $LAST_DAY
at> /billing/monthly-billing.sh
at> <Ctrl+D>
```

### 7. Monitoring et alertes

```bash
# Script de monitoring des tâches at
cat > /usr/local/bin/at-monitor.sh << 'EOF'
#!/bin/bash
COUNT=$(atq | wc -l)
if [ $COUNT -gt 10 ]; then
    echo "ATTENTION: $COUNT tâches at en attente" | \
        mail -s "AT Queue Alert" admin@localhost
fi
EOF

chmod +x /usr/local/bin/at-monitor.sh
```

### 8. Combiner at avec d'autres outils

```bash
# Planifier un snapshot avec LVM
at 2am << 'EOF'
#!/bin/bash
lvcreate -L 10G -s -n backup-snap /dev/vg0/data
mount /dev/vg0/backup-snap /mnt/snapshot
rsync -a /mnt/snapshot/ /backup/daily/
umount /mnt/snapshot
lvremove -f /dev/vg0/backup-snap
EOF

# Planifier un déploiement
at 23:00 Friday << 'EOF'
#!/bin/bash
cd /var/www/app
git pull origin main
systemctl restart myapp
curl -X POST https://monitoring.example.com/deploy/notify
EOF
```

---

> [!tip] Résumé des commandes essentielles
> 
> - **`at TIME`** : planifier une tâche ponctuelle
> - **`atq`** ou **`at -l`** : lister les tâches en attente
> - **`atrm ID`** ou **`at -r ID`** : supprimer une tâche
> - **`at -c ID`** : afficher le contenu d'une tâche
> - **`systemctl status atd`** : vérifier le service
> - **`batch`** : planifier avec charge système basse

---

_Ce cours couvre l'essentiel de la commande `at` pour la planification de tâches ponctuelles sous Linux. Pour approfondir davantage, consultez `man at`, `man atd` et `man batch`._