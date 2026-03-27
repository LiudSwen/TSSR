

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

## 🎯 Introduction aux Systemd Timers

Les **systemd timers** sont l'alternative moderne à cron pour planifier l'exécution de tâches sous Linux. Ils font partie intégrante de systemd, le système d'initialisation et de gestion des services utilisé par la plupart des distributions Linux actuelles.

> [!info] Contexte historique Bien que cron reste largement utilisé et parfaitement fonctionnel, systemd timers offrent une approche plus intégrée et puissante pour la planification de tâches. Les deux systèmes peuvent coexister sur un même système.

---

## 🔍 Pourquoi utiliser Systemd Timers ?

### Avantages par rapport à cron

|Critère|Systemd Timers|Cron|
|---|---|---|
|**Logs centralisés**|Intégration avec journalctl|Logs dispersés (syslog, mail)|
|**Gestion des dépendances**|Support natif (After, Requires)|Aucun|
|**Granularité temporelle**|Précision à la microseconde|Minute minimum|
|**Rattrapage des tâches**|Persistent=true disponible|Non supporté|
|**Gestion des ressources**|Limitation CPU/mémoire intégrée|Nécessite des outils externes|
|**Monitoring**|systemctl status intégré|Nécessite des scripts|

> [!tip] Quand utiliser systemd timers ?
> 
> - Tâches système critiques nécessitant un monitoring précis
> - Besoin de gérer des dépendances entre services
> - Exigence de logs centralisés et structurés
> - Planification complexe avec conditions multiples
> - Environnements nécessitant une gestion fine des ressources

---

## 🏗️ Architecture des Timers

Un timer systemd nécessite **deux fichiers** distincts :

```
/etc/systemd/system/
├── mon-script.service    # Définit QUOI exécuter
└── mon-script.timer      # Définit QUAND exécuter
```

> [!warning] Convention de nommage Le fichier `.timer` et le fichier `.service` doivent avoir **le même nom de base** (ex: `backup.timer` et `backup.service`). Si vous souhaitez un nom différent, utilisez la directive `Unit=` dans le timer.

### Le fichier .service

C'est une unit systemd classique qui décrit la tâche à exécuter.

### Le fichier .timer

C'est une unit spéciale qui définit quand et comment déclencher le service associé.

---

## 🛠️ Création d'un timer simple

### Exemple pratique : Nettoyage automatique de logs

#### Étape 1 : Créer le script à exécuter

```bash
# Créer le script
sudo nano /usr/local/bin/clean-logs.sh
```

```bash
#!/bin/bash
# Script de nettoyage des logs anciens

LOG_DIR="/var/log/myapp"
DAYS=30

find "$LOG_DIR" -name "*.log" -type f -mtime +$DAYS -delete
echo "Logs supprimés : $(date)" >> /var/log/clean-logs.log
```

```bash
# Rendre le script exécutable
sudo chmod +x /usr/local/bin/clean-logs.sh
```

#### Étape 2 : Créer le fichier service

```bash
sudo nano /etc/systemd/system/clean-logs.service
```

```ini
[Unit]
Description=Nettoyage des anciens logs applicatifs
Documentation=man:systemd.service(5)

[Service]
Type=oneshot
ExecStart=/usr/local/bin/clean-logs.sh
User=root
StandardOutput=journal
StandardError=journal

# Sécurité : limiter les ressources
CPUQuota=20%
MemoryMax=100M
```

> [!info] Type=oneshot Ce type indique que le service s'exécute une fois puis se termine. C'est le type approprié pour les tâches planifiées.

#### Étape 3 : Créer le fichier timer

```bash
sudo nano /etc/systemd/system/clean-logs.timer
```

```ini
[Unit]
Description=Timer pour le nettoyage quotidien des logs
Documentation=man:systemd.timer(5)

[Timer]
# Exécution quotidienne à 3h du matin
OnCalendar=daily
# Alternative : OnCalendar=*-*-* 03:00:00

# Ajouter un délai aléatoire de 0 à 15 minutes
RandomizedDelaySec=15min

# Si le système était éteint, rattraper l'exécution manquée
Persistent=true

[Install]
WantedBy=timers.target
```

#### Étape 4 : Activer et démarrer le timer

```bash
# Recharger la configuration systemd
sudo systemctl daemon-reload

# Activer le timer (démarrage automatique au boot)
sudo systemctl enable clean-logs.timer

# Démarrer le timer immédiatement
sudo systemctl start clean-logs.timer

# Vérifier le statut
sudo systemctl status clean-logs.timer
```

> [!example] Sortie attendue
> 
> ```
> ● clean-logs.timer - Timer pour le nettoyage quotidien des logs
>      Loaded: loaded (/etc/systemd/system/clean-logs.timer; enabled)
>      Active: active (waiting) since Mon 2024-12-27 10:30:00 CET
>    Trigger: Tue 2024-12-28 03:00:00 CET
> ```

---

## 📅 Types de timers

Systemd propose deux catégories principales de timers :

### 1. Timers monotoniques (relatifs)

Basés sur le temps écoulé depuis un événement système.

```ini
[Timer]
# 15 minutes après le démarrage du système
OnBootSec=15min

# 5 minutes après l'activation du timer
OnStartupSec=5min

# 10 secondes après la dernière activation du service
OnUnitActiveSec=10s

# 1 heure après que le service soit devenu inactif
OnUnitInactiveSec=1h
```

> [!tip] Cas d'usage
> 
> - `OnBootSec` : tâches d'initialisation système
> - `OnUnitActiveSec` : monitoring périodique régulier
> - `OnUnitInactiveSec` : tâches à répéter après un délai fixe

### 2. Timers réels (calendrier)

Basés sur la date et l'heure absolues (comme cron).

```ini
[Timer]
# Syntaxe complète : DayOfWeek Year-Month-Day Hour:Minute:Second

# Chaque jour à 6h30
OnCalendar=*-*-* 06:30:00

# Raccourci équivalent
OnCalendar=06:30

# Tous les lundis à 9h
OnCalendar=Mon *-*-* 09:00:00

# Premier jour de chaque mois à minuit
OnCalendar=*-*-01 00:00:00

# Toutes les 15 minutes
OnCalendar=*:0/15

# Plusieurs horaires possibles
OnCalendar=Mon,Wed,Fri 08:00
OnCalendar=Tue,Thu 14:00
```

### Syntaxe OnCalendar détaillée

```
DayOfWeek Year-Month-Day Hour:Minute:Second
```

**Composants :**

- `DayOfWeek` : Mon, Tue, Wed, Thu, Fri, Sat, Sun (optionnel)
- `Year` : année complète ou `*` pour chaque année
- `Month` : 01-12 ou `*`
- `Day` : 01-31 ou `*`
- `Hour` : 00-23 ou `*`
- `Minute` : 00-59 ou `*`
- `Second` : 00-59 ou `*`

**Raccourcis pratiques :**

```ini
OnCalendar=minutely    # Chaque minute
OnCalendar=hourly      # Chaque heure
OnCalendar=daily       # Chaque jour à minuit
OnCalendar=weekly      # Chaque lundi à minuit
OnCalendar=monthly     # Premier jour du mois à minuit
OnCalendar=yearly      # Premier janvier à minuit
```

> [!tip] Tester une expression OnCalendar
> 
> ```bash
> systemd-analyze calendar "Mon,Fri *-*-* 12:00:00"
> systemd-analyze calendar "weekly"
> systemd-analyze calendar "*:0/15"
> ```

---

## 🎮 Gestion des timers avec systemctl

### Commandes essentielles

```bash
# Lister TOUS les timers (actifs et inactifs)
systemctl list-timers --all

# Lister uniquement les timers actifs
systemctl list-timers

# Affichage détaillé avec unités
systemctl list-timers --all --no-pager

# Statut d'un timer spécifique
systemctl status clean-logs.timer

# Démarrer un timer
systemctl start clean-logs.timer

# Arrêter un timer
systemctl stop clean-logs.timer

# Activer au démarrage
systemctl enable clean-logs.timer

# Désactiver au démarrage
systemctl disable clean-logs.timer

# Redémarrer un timer
systemctl restart clean-logs.timer
```

### Comprendre la sortie de list-timers

```bash
systemctl list-timers
```

```
NEXT                         LEFT          LAST                         PASSED       UNIT                   ACTIVATES
Tue 2024-12-28 03:00:00 CET  16h left      Mon 2024-12-27 03:00:00 CET  7h ago       clean-logs.timer       clean-logs.service
Tue 2024-12-28 00:00:00 CET  13h left      Mon 2024-12-27 00:00:00 CET  10h ago      logrotate.timer        logrotate.service
```

**Colonnes :**

- `NEXT` : Prochaine exécution planifiée (date/heure absolue)
- `LEFT` : Temps restant avant la prochaine exécution
- `LAST` : Dernière exécution
- `PASSED` : Temps écoulé depuis la dernière exécution
- `UNIT` : Nom du timer
- `ACTIVATES` : Service activé par ce timer

> [!tip] Filtrage et tri
> 
> ```bash
> # Afficher uniquement les timers contenant "backup"
> systemctl list-timers | grep backup
> 
> # Trier par prochaine exécution
> systemctl list-timers --no-pager | sort
> ```

### Exécution manuelle d'un service

```bash
# Exécuter le service immédiatement (sans attendre le timer)
sudo systemctl start clean-logs.service

# Vérifier les logs de la dernière exécution
sudo journalctl -u clean-logs.service -n 50
```

> [!warning] Ne pas confondre
> 
> - `systemctl start clean-logs.timer` → active le mécanisme de planification
> - `systemctl start clean-logs.service` → exécute la tâche immédiatement

---

## ⚙️ Options avancées

### Persistent : rattrapage des tâches manquées

```ini
[Timer]
OnCalendar=daily
Persistent=true
```

> [!info] Comportement de Persistent Quand `Persistent=true`, si le système était éteint au moment de l'exécution planifiée, la tâche sera exécutée **au prochain démarrage**. Sans cette option, l'exécution est simplement sautée.

### RandomizedDelaySec : éviter les pics de charge

```ini
[Timer]
OnCalendar=hourly
RandomizedDelaySec=5min
```

Ajoute un délai aléatoire entre 0 et la valeur spécifiée. Utile pour :

- Répartir la charge sur plusieurs serveurs
- Éviter les contentions de ressources
- Limiter les pics réseau simultanés

### AccuracySec : ajuster la précision

```ini
[Timer]
OnCalendar=*:0/5
AccuracySec=1s
```

Par défaut, systemd groupe les timers dans une fenêtre de 1 minute pour économiser l'énergie. `AccuracySec` permet d'ajuster cette précision :

- `1us` : précision maximale (microseconde)
- `1s` : précision à la seconde
- `1min` : précision à la minute (défaut pour la plupart des timers)

> [!warning] Impact sur les performances Une précision élevée augmente la consommation CPU et empêche certaines optimisations d'économie d'énergie. À utiliser uniquement si nécessaire.

### WakeSystem : réveil depuis la suspension

```ini
[Timer]
OnCalendar=daily
WakeSystem=true
```

Permet au timer de réveiller le système depuis un état de suspension pour exécuter la tâche.

> [!warning] Privilèges requis Cette fonctionnalité nécessite des privilèges spécifiques et peut ne pas fonctionner sur tous les systèmes.

### Unit : associer un service différent

```ini
[Timer]
OnCalendar=hourly
Unit=autre-service.service
```

Par défaut, `backup.timer` active `backup.service`. Utilisez `Unit=` pour changer ce comportement.

---

## 🚨 Pièges courants et bonnes pratiques

### ❌ Piège 1 : Oublier daemon-reload

```bash
# Après toute modification de fichiers .timer ou .service
sudo systemctl daemon-reload
```

> [!warning] Symptôme Les modifications ne sont pas prises en compte, l'ancien comportement persiste.

### ❌ Piège 2 : Activer le service au lieu du timer

```bash
# ❌ INCORRECT
sudo systemctl enable clean-logs.service

# ✅ CORRECT
sudo systemctl enable clean-logs.timer
```

> [!warning] Conséquence Le service ne sera jamais déclenché automatiquement car le timer n'est pas actif.

### ❌ Piège 3 : Permissions insuffisantes

```ini
# Si le script nécessite des droits root
[Service]
User=root

# Sinon, utiliser un utilisateur dédié
[Service]
User=backup
Group=backup
```

### ❌ Piège 4 : Chemins relatifs dans les scripts

```bash
# ❌ INCORRECT dans un script
cd ../logs
./cleanup.sh

# ✅ CORRECT
cd /var/log/myapp || exit 1
/usr/local/bin/cleanup.sh
```

> [!tip] Toujours utiliser des chemins absolus Systemd n'exécute pas les services depuis un répertoire de travail prévisible.

### ✅ Bonne pratique 1 : Logging structuré

```ini
[Service]
ExecStart=/usr/local/bin/mon-script.sh
StandardOutput=journal
StandardError=journal
SyslogIdentifier=mon-script
```

Permet de filtrer facilement les logs :

```bash
journalctl -t mon-script -f
```

### ✅ Bonne pratique 2 : Gestion des erreurs

```ini
[Service]
Type=oneshot
ExecStart=/usr/local/bin/script.sh
Restart=on-failure
RestartSec=5min
```

### ✅ Bonne pratique 3 : Limitation des ressources

```ini
[Service]
CPUQuota=50%
MemoryMax=500M
TasksMax=10
IOWeight=100
```

### ✅ Bonne pratique 4 : Documentation

```ini
[Unit]
Description=Nettoyage quotidien des logs applicatifs
Documentation=man:systemd.timer(5)
Documentation=https://wiki.monentreprise.com/ops/timers
```

### ✅ Bonne pratique 5 : Monitoring

```bash
# Créer un script de vérification
cat > /usr/local/bin/check-timers.sh << 'EOF'
#!/bin/bash
FAILED=$(systemctl list-timers --failed --no-legend | wc -l)
if [ "$FAILED" -gt 0 ]; then
    echo "⚠️ $FAILED timer(s) en échec"
    systemctl list-timers --failed
    exit 1
fi
echo "✅ Tous les timers fonctionnent"
EOF

chmod +x /usr/local/bin/check-timers.sh
```

### ✅ Bonne pratique 6 : Isolation de sécurité

```ini
[Service]
# Isolation du système de fichiers
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/log/myapp

# Restrictions réseau
PrivateNetwork=true

# Restrictions des capacités
NoNewPrivileges=true
CapabilityBoundingSet=
```

---

## 📊 Comparaison Timer vs Service classique

|Aspect|Timer + Service|Service seul|
|---|---|---|
|**Démarrage**|Selon planification|Manuel ou au boot|
|**Répétition**|Automatique|Nécessite Restart=|
|**Flexibilité horaire**|Très élevée|Limitée|
|**Monitoring**|list-timers dédié|list-units générique|
|**Cas d'usage**|Tâches planifiées|Services permanents|

---

## 🔧 Astuces avancées

### Visualiser le calendrier d'un timer

```bash
# Voir les 10 prochaines exécutions
systemd-analyze calendar "Mon-Fri 09:00" --iterations=10
```

### Déboguer un timer qui ne se déclenche pas

```bash
# 1. Vérifier que le timer est actif
systemctl is-active clean-logs.timer

# 2. Vérifier la prochaine exécution
systemctl list-timers clean-logs.timer

# 3. Vérifier les logs du timer
journalctl -u clean-logs.timer -n 50

# 4. Vérifier les logs du service
journalctl -u clean-logs.service -n 50

# 5. Tester le service manuellement
systemctl start clean-logs.service
```

### Créer un timer utilisateur (sans root)

```bash
# Créer les répertoires
mkdir -p ~/.config/systemd/user/

# Créer les fichiers .service et .timer dans ce dossier
nano ~/.config/systemd/user/ma-tache.service
nano ~/.config/systemd/user/ma-tache.timer

# Recharger la configuration utilisateur
systemctl --user daemon-reload

# Activer et démarrer
systemctl --user enable --now ma-tache.timer

# Lister les timers utilisateur
systemctl --user list-timers
```

> [!info] Linger pour persistance Par défaut, les services utilisateur s'arrêtent à la déconnexion. Pour les maintenir actifs :
> 
> ```bash
> sudo loginctl enable-linger $USER
> ```

### Template de timer réutilisable

```bash
# Créer /etc/systemd/system/backup@.service
[Unit]
Description=Backup de %i

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh %i
```

```bash
# Créer /etc/systemd/system/backup@.timer
[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
# Utilisation
systemctl enable backup@database.timer
systemctl enable backup@files.timer
```

---

## 📝 Exemple complet : Système de backup

### Script de backup

```bash
sudo nano /usr/local/bin/backup-system.sh
```

```bash
#!/bin/bash
set -euo pipefail

BACKUP_DIR="/var/backups/system"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/backup-system.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Début du backup système"

# Créer le répertoire de destination
mkdir -p "$BACKUP_DIR"

# Backup de la configuration système
tar -czf "$BACKUP_DIR/etc_$DATE.tar.gz" /etc/ 2>/dev/null || true

# Backup de la liste des paquets installés
dpkg --get-selections > "$BACKUP_DIR/packages_$DATE.list"

# Nettoyage des backups de plus de 30 jours
find "$BACKUP_DIR" -type f -mtime +30 -delete

log "Backup système terminé avec succès"
```

```bash
sudo chmod +x /usr/local/bin/backup-system.sh
```

### Fichier service

```bash
sudo nano /etc/systemd/system/backup-system.service
```

```ini
[Unit]
Description=Backup quotidien du système
Documentation=file:///usr/local/bin/backup-system.sh
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup-system.sh
User=root
Group=root

# Logs
StandardOutput=journal
StandardError=journal
SyslogIdentifier=backup-system

# Sécurité et limitations
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=/var/backups /var/log
CPUQuota=30%
MemoryMax=1G
IOWeight=50

# Gestion d'erreur
Restart=on-failure
RestartSec=10min
```

### Fichier timer

```bash
sudo nano /etc/systemd/system/backup-system.timer
```

```ini
[Unit]
Description=Timer pour le backup quotidien du système
Documentation=file:///usr/local/bin/backup-system.sh

[Timer]
# Exécution chaque jour à 2h du matin
OnCalendar=*-*-* 02:00:00

# Délai aléatoire pour éviter les pics
RandomizedDelaySec=30min

# Rattraper si le système était éteint
Persistent=true

# Précision d'une minute suffisante
AccuracySec=1min

[Install]
WantedBy=timers.target
```

### Activation

```bash
sudo systemctl daemon-reload
sudo systemctl enable backup-system.timer
sudo systemctl start backup-system.timer

# Vérification
systemctl status backup-system.timer
systemctl list-timers backup-system.timer
```

---

## 🎓 Récapitulatif

Les systemd timers offrent une alternative moderne et puissante à cron pour la planification de tâches :

**Points clés à retenir :**

- Un timer nécessite toujours un fichier `.timer` et un fichier `.service`
- Deux types principaux : monotoniques (relatifs) et calendrier (absolus)
- Commande principale : `systemctl list-timers` pour surveiller
- Options importantes : `Persistent`, `RandomizedDelaySec`, `AccuracySec`
- Toujours utiliser `systemctl daemon-reload` après modification
- Activer le `.timer`, pas le `.service`
- Logs centralisés via `journalctl`

**Workflow type :**

1. Créer le script à exécuter
2. Créer le fichier `.service`
3. Créer le fichier `.timer`
4. `daemon-reload`, `enable`, `start`
5. Vérifier avec `list-timers` et `status`