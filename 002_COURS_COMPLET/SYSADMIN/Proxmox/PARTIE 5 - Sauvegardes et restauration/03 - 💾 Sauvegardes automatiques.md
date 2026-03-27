

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

## Introduction

Les sauvegardes automatiques permettent de créer des copies de vos machines virtuelles et conteneurs selon un calendrier prédéfini, sans intervention manuelle. Cette automatisation est essentielle pour garantir la continuité d'activité et minimiser les risques de perte de données.

> [!info] Pourquoi automatiser ?
> 
> - **Fiabilité** : Élimine les oublis humains
> - **Cohérence** : Sauvegardes régulières à intervalles définis
> - **Efficacité** : Exécution pendant les heures creuses
> - **Traçabilité** : Historique complet des sauvegardes

---

## Configuration d'un job de backup

### 🎯 Création d'un job de sauvegarde

Un job de backup définit l'ensemble des paramètres pour automatiser vos sauvegardes : machines concernées, destination, fréquence, rétention, etc.

#### Via l'interface Web

1. Naviguez vers **Datacenter** → **Backup**
2. Cliquez sur **Add** pour créer un nouveau job
3. Configurez les paramètres principaux

> [!example] Interface de création La fenêtre de création présente plusieurs onglets :
> 
> - **General** : Paramètres de base
> - **Retention** : Politique de rétention
> - **Advanced** : Options avancées

#### Via la ligne de commande

```bash
# Créer un job de backup via vzdump
# Cette commande configure les paramètres mais ne l'enregistre pas comme job planifié
vzdump <VMID> --storage <STORAGE> --mode snapshot --compress zstd

# Pour créer un job planifié, éditer directement le fichier de configuration
nano /etc/pve/vzdump.cron
```

### 📋 Paramètres essentiels

#### Storage (Destination)

Définit où les sauvegardes seront stockées.

```bash
# Exemples de destinations possibles
Storage: local           # Stockage local (généralement /var/lib/vz/dump)
Storage: pbs-server      # Proxmox Backup Server
Storage: nfs-backup      # Partage NFS
Storage: cifs-backup     # Partage CIFS/SMB
```

> [!warning] Choix du stockage
> 
> - Ne stockez **jamais** vos backups uniquement sur le même disque que vos VMs
> - Privilégiez un stockage externe, distant ou dédié
> - Vérifiez l'espace disponible avant de configurer le job

#### Mode de sauvegarde

Trois modes disponibles selon vos besoins :

|Mode|Description|Arrêt VM|Cohérence|Performance|
|---|---|---|---|---|
|**Snapshot**|Snapshot du système de fichiers|Non|Excellente|Impact minimal|
|**Suspend**|Suspend la VM pendant la sauvegarde|Oui (temporaire)|Parfaite|Impact moyen|
|**Stop**|Arrêt complet de la VM|Oui|Parfaite|Impact maximal|

```bash
# Configuration du mode dans vzdump
--mode snapshot    # Mode recommandé (par défaut)
--mode suspend     # Pour garantir la cohérence absolue
--mode stop        # Pour les cas critiques uniquement
```

> [!tip] Choix du mode
> 
> - **Snapshot** : Mode par défaut, convient à 95% des cas
> - **Suspend** : Pour les bases de données critiques sans agent QEMU
> - **Stop** : Uniquement si les deux autres modes échouent

#### Compression

La compression réduit la taille des backups et le temps de transfert.

|Algorithme|Ratio|Vitesse|CPU|Recommandation|
|---|---|---|---|---|
|**LZO**|Faible|Très rapide|Faible|Liens lents, CPU limité|
|**GZIP**|Moyen|Moyenne|Moyen|Équilibre général|
|**ZSTD**|Excellent|Rapide|Moyen|**Recommandé** (par défaut)|

```bash
# Configuration de la compression
--compress lzo     # Compression rapide
--compress gzip    # Compression standard
--compress zstd    # Compression moderne (recommandé)
```

> [!tip] Compression ZSTD ZSTD offre le meilleur compromis :
> 
> - Ratio de compression proche de GZIP
> - Vitesse proche de LZO
> - Décompression très rapide

#### Notes et commentaires

```bash
# Ajouter une description au job
--notes-template "{{guestname}} - {{cluster}} - {{timestamp}}"

# Variables disponibles :
# {{guestname}}  - Nom de la VM/CT
# {{vmid}}       - ID numérique
# {{cluster}}    - Nom du cluster
# {{timestamp}}  - Date et heure
# {{hostname}}   - Nom de l'hôte Proxmox
```

### ⚙️ Options avancées

#### Bande passante (Bandwidth Limit)

Limite la bande passante utilisée pour ne pas saturer le réseau.

```bash
# Limiter à 50 MB/s
--bwlimit 50000

# Exemple : backup nocturne sans limite, diurne avec limite
# Job 1 (nuit) : --bwlimit 0 (pas de limite)
# Job 2 (jour) : --bwlimit 25000 (25 MB/s)
```

> [!warning] Unités La limite est exprimée en **KB/s** (kilo-octets par seconde)
> 
> - 10000 = 10 MB/s
> - 50000 = 50 MB/s
> - 0 = pas de limite

#### Mode Pigz (Parallel GZIP)

Active la compression parallèle pour GZIP.

```bash
# Activer pigz (utilise tous les cœurs disponibles)
--pigz 0

# Limiter le nombre de threads
--pigz 4  # Utilise 4 threads
```

> [!info] Quand utiliser Pigz ? Utile uniquement si vous utilisez la compression GZIP et avez :
> 
> - Un processeur multi-cœurs (4+)
> - Des grosses VMs (>100 GB)
> - Du temps CPU disponible

#### Exclusion de disques

Exclut certains disques de la sauvegarde.

```bash
# Exclure scsi1 et scsi2
--exclude-path /dev/sdb,/dev/sdc

# Via l'interface : cocher "Exclude unused disks"
# Exclut automatiquement les disques non montés
```

> [!example] Cas d'usage
> 
> - Disques de données temporaires
> - Caches ou fichiers de swap
> - Disques de logs volumineux
> - ISO montés temporairement

---

## Planification (Schedule)

### ⏰ Syntaxe Cron

Proxmox utilise la syntaxe **Cron** standard pour planifier les sauvegardes.

```
┌─────── Minute (0-59)
│ ┌───── Heure (0-23)
│ │ ┌─── Jour du mois (1-31)
│ │ │ ┌─ Mois (1-12)
│ │ │ │ ┌ Jour de la semaine (0-7, 0 et 7 = dimanche)
│ │ │ │ │
* * * * *
```

### 📅 Exemples de planification

#### Sauvegardes quotidiennes

```bash
# Tous les jours à 2h30 du matin
30 2 * * *

# Tous les jours à minuit
0 0 * * *

# Tous les jours à 23h45
45 23 * * *
```

#### Sauvegardes hebdomadaires

```bash
# Tous les dimanches à 3h00
0 3 * * 0

# Tous les lundis à 1h00
0 1 * * 1

# Tous les vendredis à 22h00
0 22 * * 5
```

#### Sauvegardes mensuelles

```bash
# Le 1er de chaque mois à 4h00
0 4 1 * *

# Le dernier jour du mois à 23h00 (nécessite un script)
0 23 28-31 * * [ $(date -d tomorrow +\%d) -eq 1 ] && /usr/bin/vzdump

# Le 15 de chaque mois à 2h00
0 2 15 * *
```

#### Planifications complexes

```bash
# Toutes les 6 heures
0 */6 * * *

# Du lundi au vendredi à 23h00
0 23 * * 1-5

# Les 1er et 15 de chaque mois
0 2 1,15 * *

# Toutes les 4 heures entre 8h et 20h
0 8-20/4 * * *
```

> [!tip] Générateur Cron Utilisez des outils en ligne comme [crontab.guru](https://crontab.guru/) pour valider votre syntaxe cron.

### 🔄 Stratégies de planification recommandées

#### Stratégie 3-2-1

Une approche professionnelle combine plusieurs jobs :

```bash
# Job 1 : Sauvegarde quotidienne (rétention 7 jours)
Schedule: 0 2 * * *
Retention: 7

# Job 2 : Sauvegarde hebdomadaire (rétention 4 semaines)
Schedule: 0 3 * * 0
Retention: 4

# Job 3 : Sauvegarde mensuelle (rétention 12 mois)
Schedule: 0 4 1 * *
Retention: 12
```

> [!info] Règle 3-2-1
> 
> - **3** copies de vos données
> - **2** types de supports différents
> - **1** copie hors site

#### Selon la criticité

|Type de VM|Fréquence|Heure|Rétention|
|---|---|---|---|
|**Production critique**|Toutes les 4h|0,4,8,12,16,20|48h|
|**Production standard**|Quotidienne|02:00|7 jours|
|**Développement**|Hebdomadaire|Dimanche 03:00|4 semaines|
|**Test/Staging**|Hebdomadaire|Samedi 22:00|2 semaines|
|**Archive**|Mensuelle|1er du mois 04:00|12 mois|

### 🕐 Configuration de la planification

#### Via l'interface Web

1. Dans l'onglet **General** du job
2. Section **Schedule**
3. Saisir l'expression cron ou utiliser les options rapides
4. Cocher **Enable** pour activer la planification

#### Via fichier de configuration

```bash
# Éditer le fichier de configuration Cron
nano /etc/pve/vzdump.cron

# Format : <schedule> <command>
# Exemple :
30 2 * * * root vzdump --all --mode snapshot --storage backup-nfs --compress zstd --mailnotification always
```

> [!warning] Redémarrage requis Après modification manuelle de `/etc/pve/vzdump.cron`, redémarrez le service :
> 
> ```bash
> systemctl restart cron
> ```

### ⏸️ Désactiver temporairement

```bash
# Via l'interface : décocher "Enable" dans le job

# Via CLI : commenter la ligne dans le cron
nano /etc/pve/vzdump.cron
# 30 2 * * * root vzdump ...  (ajouter # au début)
```

---

## Sélection des machines

### 🎯 Méthodes de sélection

Proxmox offre plusieurs façons de sélectionner les VMs/CTs à sauvegarder.

#### Sélection manuelle (par ID)

Spécifie explicitement les VMs/CTs par leur ID.

```bash
# Un seul ID
--vmid 100

# Plusieurs IDs (séparés par des virgules)
--vmid 100,101,105,200

# Via l'interface : cocher les VMs dans la liste
```

> [!tip] Quand utiliser ?
> 
> - Nombre limité de machines
> - Machines spécifiques avec besoins particuliers
> - Contrôle précis sur ce qui est sauvegardé

#### Sélection par pool

Les pools permettent de grouper logiquement des VMs/CTs.

```bash
# Sauvegarder toutes les VMs d'un pool
--pool production

# Via l'interface : sélectionner le pool dans le menu déroulant
```

**Créer un pool :**

1. **Datacenter** → **Permissions** → **Pools** → **Create**
2. Nommer le pool (ex: `production`, `dev`, `web-servers`)
3. Ajouter des VMs/CTs au pool depuis leurs propriétés

> [!example] Organisation par pools
> 
> ```
> production         → VMs critiques
> ├── web-frontend   → Serveurs web
> ├── databases      → Bases de données
> └── applications   → Apps métier
> 
> development        → Environnement de dev
> test               → Environnement de test
> staging            → Pré-production
> ```

#### Sélection globale (--all)

Sauvegarde **toutes** les VMs et CTs du nœud.

```bash
# Sauvegarder toutes les machines
--all

# Via l'interface : cocher "Select all"
```

> [!warning] Attention
> 
> - Sauvegarde **tout**, même les machines de test
> - Peut saturer l'espace de stockage
> - Temps de backup potentiellement très long
> - À réserver aux petites infrastructures homogènes

#### Combinaison de critères

```bash
# Sauvegarder un pool ET des VMs spécifiques
--pool production --vmid 999,1000

# Cela n'est pas possible via une seule commande vzdump
# Solution : créer deux jobs distincts
```

### 🏷️ Organisation recommandée

#### Par fonction métier

```
pool:web           → 101, 102, 103 (serveurs web)
pool:database      → 201, 202 (bases de données)
pool:application   → 301, 302, 303 (apps métier)
pool:monitoring    → 401 (supervision)
```

**Jobs associés :**

- `web` : quotidien, rétention 7j
- `database` : toutes les 4h, rétention 48h
- `application` : quotidien, rétention 14j
- `monitoring` : hebdomadaire, rétention 4 semaines

#### Par environnement

```
pool:prod          → Machines de production
pool:preprod       → Pré-production
pool:dev           → Développement
pool:test          → Tests
```

**Jobs associés :**

- `prod` : quotidien 2h, rétention 30j + mensuel
- `preprod` : quotidien 3h, rétention 7j
- `dev` : hebdomadaire, rétention 2 semaines
- `test` : manuel uniquement

#### Par criticité

```
pool:tier1         → Critique (RTO < 1h)
pool:tier2         → Important (RTO < 4h)
pool:tier3         → Standard (RTO < 24h)
```

**Jobs associés :**

- `tier1` : toutes les 2h, rétention 7j
- `tier2` : toutes les 6h, rétention 3j
- `tier3` : quotidien, rétention 7j

### 🔍 Filtrage avancé

#### Exclure des machines spécifiques

```bash
# Sauvegarder tout sauf certaines VMs
# Pas de flag --exclude natif, solutions :

# Solution 1 : Utiliser des pools (recommandé)
# Créer un pool sans les VMs à exclure

# Solution 2 : Scripts personnalisés
#!/bin/bash
ALL_VMS=$(qm list | awk 'NR>1 {print $1}')
EXCLUDE="999 1000"
for VM in $ALL_VMS; do
    if [[ ! " $EXCLUDE " =~ " $VM " ]]; then
        vzdump $VM --storage backup-nfs
    fi
done
```

#### Sauvegarder selon l'état

```bash
# Uniquement les VMs en cours d'exécution
#!/bin/bash
for VM in $(qm list | awk '$3=="running" {print $1}'); do
    vzdump $VM --storage backup-nfs
done

# Uniquement les VMs arrêtées
for VM in $(qm list | awk '$3=="stopped" {print $1}'); do
    vzdump $VM --mode stop --storage backup-nfs
done
```

### 📊 Ordre d'exécution

Les sauvegardes sont exécutées **séquentiellement** dans l'ordre :

1. Par numéro de VMID croissant
2. Une VM/CT à la fois (pas de parallélisation native)

```bash
# Si vous sauvegardez : 105, 100, 103
# Ordre d'exécution : 100 → 103 → 105

# Pour forcer un ordre spécifique :
# Créer plusieurs jobs avec des horaires décalés
Job1: 02:00 → VMID 201 (base de données)
Job2: 02:30 → VMID 101,102 (frontends)
```

> [!tip] Optimisation Pour les grosses infrastructures, envisagez :
> 
> - Plusieurs jobs en parallèle sur différents nœuds
> - Répartition des backups sur plusieurs horaires
> - Utilisation de Proxmox Backup Server (parallélisation native)

---

## Notifications

### 📧 Configuration des notifications email

Les notifications permettent d'être informé du succès ou de l'échec des sauvegardes.

#### Configuration du serveur mail

```bash
# Configurer le serveur SMTP sur le nœud Proxmox
nano /etc/postfix/main.cf

# Exemple avec un serveur SMTP externe
relayhost = smtp.example.com:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous

# Créer le fichier de credentials
nano /etc/postfix/sasl_passwd
# Contenu :
smtp.example.com:587 user@example.com:password

# Hasher et protéger le fichier
postmap /etc/postfix/sasl_passwd
chmod 600 /etc/postfix/sasl_passwd

# Redémarrer Postfix
systemctl restart postfix

# Tester l'envoi
echo "Test backup notification" | mail -s "Test Proxmox" admin@example.com
```

#### Options de notification

Trois niveaux de notification disponibles :

|Option|Description|Quand utiliser|
|---|---|---|
|**Always**|Email pour chaque backup (succès + échec)|Environnement critique, audits|
|**Failure**|Email uniquement en cas d'échec|**Recommandé** pour la production|
|**Never**|Aucune notification|Tests, environnements non critiques|

```bash
# Configuration dans vzdump
--mailnotification always   # Toujours notifier
--mailnotification failure  # Uniquement les échecs (recommandé)
--mailnotification never    # Jamais

# Définir le destinataire
--mailto admin@example.com,backup@example.com  # Plusieurs destinataires
```

> [!tip] Recommandation Utilisez `failure` en production :
> 
> - Évite le spam de mails quotidiens
> - Alerte immédiatement en cas de problème
> - Permet une réaction rapide

#### Via l'interface Web

1. Dans le job de backup, section **Notification**
2. **Send email to** : adresse(s) email
3. **Notify** : sélectionner le mode (Always/Failure/Never)

### 📝 Contenu des notifications

#### Email de succès

```
Subject: vzdump backup status (pve01) : OK

VZDUMP backup summary:

Hostname: pve01
Backup job started at: 2025-01-15 02:00:01
Backup job finished at: 2025-01-15 02:15:32
Total duration: 15 minutes 31 seconds

VM/CT details:
  100: backup-vm-100-2025_01_15-02_00_01.vma.zst (15.2 GB, 00:08:45)
  101: backup-vm-101-2025_01_15-02_08_46.vma.zst (8.7 GB, 00:06:46)

Total backup size: 23.9 GB
Status: OK
```

#### Email d'échec

```
Subject: vzdump backup status (pve01) : ERROR

VZDUMP backup summary:

ERROR: Backup of VM 100 failed
Error message: command 'zstd' failed with exit code 1

VM/CT details:
  100: FAILED - Insufficient space on storage 'backup-nfs'
  101: backup-vm-101-2025_01_15-02_08_46.vma.zst (8.7 GB, 00:06:46) - OK

Status: ERROR - 1 of 2 backups failed
```

> [!warning] Surveillance obligatoire Les notifications par email ne remplacent pas un système de monitoring :
> 
> - Les emails peuvent être perdus/filtrés
> - Vérifiez régulièrement les logs manuellement
> - Mettez en place une surveillance active (Zabbix, Nagios, etc.)

### 🔔 Notifications avancées

#### Webhooks et intégrations

Pour des notifications vers Slack, Teams, Discord, etc., utilisez un script post-hook :

```bash
#!/bin/bash
# /usr/local/bin/backup-notify.sh

# Variables passées par vzdump
VMID=$1
STATUS=$2  # 0=success, 1=failure

# Webhook Slack
WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

if [ $STATUS -eq 0 ]; then
    MESSAGE="✅ Backup VM $VMID réussi"
    COLOR="good"
else
    MESSAGE="❌ Backup VM $VMID échoué"
    COLOR="danger"
fi

curl -X POST $WEBHOOK_URL \
    -H 'Content-Type: application/json' \
    -d "{
        \"attachments\": [{
            \"color\": \"$COLOR\",
            \"text\": \"$MESSAGE\",
            \"fields\": [{
                \"title\": \"Hôte\",
                \"value\": \"$(hostname)\",
                \"short\": true
            }]
        }]
    }"
```

**Configuration du hook :**

```bash
# Rendre le script exécutable
chmod +x /usr/local/bin/backup-notify.sh

# Ajouter au job vzdump
--script /usr/local/bin/backup-notify.sh
```

#### Logs détaillés

Les logs des backups sont conservés dans :

```bash
# Logs de sauvegarde
/var/log/vzdump/

# Voir le dernier backup
tail -f /var/log/vzdump/vzdump.log

# Voir les backups d'un job spécifique
grep "Backup job" /var/log/vzdump/vzdump.log

# Filtrer les erreurs
grep "ERROR" /var/log/vzdump/vzdump.log
```

> [!tip] Rotation des logs Les logs sont automatiquement tournés par logrotate. Configuration dans `/etc/logrotate.d/pve`

#### Monitoring via API

```bash
# Vérifier l'état des derniers backups via API
pvesh get /cluster/backup --output-format=json

# Script de vérification
#!/bin/bash
LAST_BACKUP=$(pvesh get /cluster/backup --output-format=json | jq -r '.[0].starttime')
CURRENT_TIME=$(date +%s)
DIFF=$((CURRENT_TIME - LAST_BACKUP))

# Alerte si dernier backup > 48h
if [ $DIFF -gt 172800 ]; then
    echo "WARNING: Last backup is older than 48 hours"
    # Envoyer une alerte
fi
```

### 📊 Tableau de bord de surveillance

Créez un script de rapport quotidien :

```bash
#!/bin/bash
# /usr/local/bin/backup-report.sh

echo "=== Rapport de sauvegarde Proxmox ===="
echo "Date: $(date)"
echo ""

echo "Jobs configurés:"
pvesh get /cluster/backup --output-format=json | jq -r '.[] | "- \(.id): \(.schedule)"'

echo ""
echo "Dernières sauvegardes (24h):"
grep "Backup job" /var/log/vzdump/vzdump.log | tail -n 10

echo ""
echo "Erreurs récentes:"
grep "ERROR" /var/log/vzdump/vzdump.log | tail -n 5

# Envoyer par email
# | mail -s "Rapport backup Proxmox" admin@example.com
```

---

## Bonnes pratiques

### ✅ Règles d'or

> [!tip] Les 10 commandements du backup
> 
> 1. **Tester régulièrement** les restaurations (mensuel minimum)
> 2. **Séparer physiquement** les backups des données sources
> 3. **Automatiser** au maximum (planification + vérification)
> 4. **Monitorer** : un backup sans surveillance est un backup potentiellement défaillant
> 5. **Documenter** la stratégie et les procédures de restauration
> 6. **Chiffrer** les backups contenant des données sensibles
> 7. **Versionner** : garder plusieurs points de restauration
> 8. **Optimiser** les fenêtres de backup selon l'activité
> 9. **Alerter** en cas d'échec (notifications multiples)
> 10. **Auditer** régulièrement l'espace et la validité des backups

### 🎯 Stratégie de rétention

#### Principe Grandfather-Father-Son (GFS)

```
Quotidien (Son)      → 7 jours   → Backup à 02:00
Hebdomadaire (Father) → 4 semaines → Dimanche à 03:00
Mensuel (Grandfather) → 12 mois    → 1er du mois à 04:00
```

**Configuration multi-jobs :**

```bash
# Job 1 : Quotidien
--storage backup-daily
--maxfiles 7
Schedule: 0 2 * * *

# Job 2 : Hebdomadaire
--storage backup-weekly
--maxfiles 4
Schedule: 0 3 * * 0

# Job 3 : Mensuel
--storage backup-monthly
--maxfiles 12
Schedule: 0 4 1 * *
```

#### Selon le type de données

|Type de données|Fréquence|Rétention|Justification|
|---|---|---|---|
|**Base de données**|4h|7 jours|Données changeantes, RPO faible|
|**Fichiers utilisateurs**|Quotidien|30 jours|Récupération fichiers supprimés|
|**Configuration système**|Hebdomadaire|3 mois|Changements peu fréquents|
|**Archives**|Mensuel|5 ans|Compliance légale|

### ⚡ Optimisation des performances

#### Fenêtres de backup

```bash
# Identifier les heures creuses
# Analyser la charge CPU/IO sur 24h
sar -u 1 86400 > cpu-load.txt

# Planifier les backups pendant les creux
# Exemple : 02:00-06:00 pour les serveurs d'entreprise
```

#### Parallélisation

```bash
# Répartir les VMs sur plusieurs jobs
# Job 1 : VMs 100-199 à 02:00
# Job 2 : VMs 200-299 à 02:00 (sur un autre storage)
# Job 3 : VMs 300-399 à 02:00 (sur un autre storage)

# Attention : vérifier la charge réseau et disque
```

#### Bandwidth shaping

```bash
# Limiter pendant les heures ouvrées
Job_Jour:
  Schedule: 0 9-17 * * 1-5
  bwlimit: 10000  # 10 MB/s

# Illimité la nuit
Job_Nuit:
  Schedule: 0 0-6,18-23 * * *
  bwlimit: 0  # Pas de limite
```

### 🔒 Sécurité

#### Protection des backups

```bash
# Droits restrictifs sur le stockage
chmod 700 /mnt/backup
chown root:root /mnt/backup

# Pour stockage NFS, options de sécurité
# Dans /etc/fstab :
backup-server:/backups /mnt/backup nfs defaults,nosuid,nodev,noexec 0 0
```

#### Chiffrement

```bash
# Proxmox ne chiffre pas nativement les backups VMA
# Solutions :

# 1. Chiffrement du stockage (LUKS)
cryptsetup luksFormat /dev/sdX
cryptsetup open /dev/sdX backup-encrypted

# 2. Chiffrement post-backup
#!/bin/bash
BACKUP_FILE="/mnt/backup/vzdump-qemu-100-*.vma.zst"
gpg --encrypt --recipient admin@example.com $BACKUP_FILE
rm $BACKUP_FILE  # Supprimer la version non chiffrée
```

> [!warning] Performance vs Sécurité Le chiffrement augmente :
> 
> - La charge CPU (+20-40%)
> - Le temps de backup (+15-30%)
> - La complexité de restauration

#### Immutabilité des backups

Pour protéger contre les ransomwares et suppressions accidentelles :

```bash
# Option 1 : Stockage en lecture seule après backup
# Monter le NFS en RW pour backup, puis remounter en RO
mount -o remount,ro /mnt/backup

# Option 2 : Proxmox Backup Server avec namespaces protégés
# PBS offre des snapshots protégés natifs

# Option 3 : Utiliser des snapshots ZFS
zfs snapshot tank/backups@$(date +%Y%m%d-%H%M%S)
```

### 📋 Vérification et validation

#### Tests de restauration réguliers

```bash
# Script de test de restauration mensuel
#!/bin/bash
# /usr/local/bin/test-restore.sh

TEST_VM_ID=9999
BACKUP_FILE=$(ls -t /mnt/backup/vzdump-qemu-100-*.vma.zst | head -1)

echo "Test de restauration : $BACKUP_FILE"

# Restaurer sur un VMID de test
qmrestore $BACKUP_FILE $TEST_VM_ID --storage local-lvm

# Démarrer la VM
qm start $TEST_VM_ID

# Attendre le boot
sleep 60

# Vérifier que la VM répond
qm status $TEST_VM_ID

# Nettoyer
qm stop $TEST_VM_ID
qm destroy $TEST_VM_ID

echo "Test de restauration terminé avec succès"
```

> [!tip] Calendrier de tests
> 
> - **Hebdomadaire** : Vérifier que les backups sont créés
> - **Mensuel** : Test de restauration complet d'une VM non critique
> - **Trimestriel** : Test de restauration d'une VM critique
> - **Annuel** : Simulation de disaster recovery complet

#### Vérification de l'intégrité

```bash
# Vérifier l'intégrité d'un backup
zstd -t /mnt/backup/vzdump-qemu-100-*.vma.zst

# Script de vérification automatique
#!/bin/bash
for BACKUP in /mnt/backup/*.zst; do
    echo "Vérification: $BACKUP"
    if zstd -t "$BACKUP" 2>/dev/null; then
        echo "✓ OK"
    else
        echo "✗ CORROMPU !"
        # Envoyer une alerte
        echo "Backup corrompu: $BACKUP" | mail -s "ALERT Backup" admin@example.com
    fi
done
```

#### Monitoring de l'espace disque

```bash
# Vérifier l'espace avant backup
#!/bin/bash
STORAGE_PATH="/mnt/backup"
THRESHOLD=90  # Alerte si > 90% utilisé

USAGE=$(df -h $STORAGE_PATH | awk 'NR==2 {print $5}' | sed 's/%//')

if [ $USAGE -gt $THRESHOLD ]; then
    echo "ALERTE: Espace disque backup à ${USAGE}%"
    # Envoyer notification
    echo "Espace disque critique sur $STORAGE_PATH" | mail -s "ALERT Storage" admin@example.com
fi
```

### 🔧 Dépannage courant

#### Backup qui échoue - Espace insuffisant

```bash
# Symptôme
ERROR: Backup of VM 100 failed - Cannot write to storage

# Vérification
df -h /mnt/backup

# Solutions
# 1. Nettoyer les vieux backups
find /mnt/backup -name "*.vma.zst" -mtime +30 -delete

# 2. Ajuster la rétention
--maxfiles 5  # Au lieu de 7

# 3. Augmenter l'espace de stockage
```

#### Backup trop lent

```bash
# Symptôme
Backup prend plusieurs heures

# Diagnostics
# 1. Vérifier la charge IO
iostat -x 5

# 2. Vérifier le réseau (si NFS/CIFS)
iftop -i eth0

# Solutions
# 1. Réduire la compression
--compress lzo  # Au lieu de zstd

# 2. Désactiver pigz si actif
# Supprimer --pigz

# 3. Limiter le nombre de VMs simultanées
# Créer plusieurs jobs espacés dans le temps

# 4. Vérifier la fragmentation du disque source
fstrim -v /
```

#### Snapshot qui reste bloqué

```bash
# Symptôme
ERROR: unable to create snapshot - snapshot already exists

# Vérification
qm listsnapshot 100

# Solution
# Supprimer le snapshot bloqué
qm delsnapshot 100 vzdump
```

#### Notifications non reçues

```bash
# Vérifier la configuration Postfix
systemctl status postfix

# Tester l'envoi manuel
echo "Test" | mail -s "Test" admin@example.com

# Vérifier les logs
tail -f /var/log/mail.log

# Configuration du relay SMTP
nano /etc/postfix/main.cf
postfix reload
```

### 📈 Métriques de surveillance

#### Indicateurs clés (KPIs)

|Métrique|Objectif|Alerte si|
|---|---|---|
|**Taux de succès**|100%|< 95%|
|**Durée du backup**|< 2h|> 4h|
|**Taille moyenne**|Stable|Variation > 30%|
|**Espace disponible**|> 20%|< 10%|
|**Âge du dernier backup**|< 24h|> 48h|
|**Taux de compression**|50-70%|< 30% ou > 80%|

#### Dashboard de monitoring

```bash
#!/bin/bash
# /usr/local/bin/backup-dashboard.sh
# Génère un rapport de métriques

echo "=== Dashboard Backups Proxmox ==="
echo "Date: $(date)"
echo ""

# Nombre total de backups
TOTAL_BACKUPS=$(ls /mnt/backup/*.vma.zst 2>/dev/null | wc -l)
echo "Backups totaux: $TOTAL_BACKUPS"

# Espace utilisé
SPACE_USED=$(du -sh /mnt/backup | awk '{print $1}')
SPACE_AVAIL=$(df -h /mnt/backup | awk 'NR==2 {print $4}')
echo "Espace utilisé: $SPACE_USED / Disponible: $SPACE_AVAIL"

# Dernière sauvegarde
LAST_BACKUP=$(ls -t /mnt/backup/*.vma.zst 2>/dev/null | head -1)
LAST_DATE=$(stat -c %y "$LAST_BACKUP" | cut -d' ' -f1)
echo "Dernier backup: $LAST_DATE"

# Taux de succès (dernières 24h)
SUCCESS=$(grep "Backup job.*OK" /var/log/vzdump/vzdump.log | grep "$(date +%Y-%m-%d)" | wc -l)
FAILED=$(grep "Backup job.*ERROR" /var/log/vzdump/vzdump.log | grep "$(date +%Y-%m-%d)" | wc -l)
echo "Succès: $SUCCESS / Échecs: $FAILED"

# Backups par VM
echo ""
echo "Backups par VM:"
for VM in $(qm list | awk 'NR>1 {print $1}'); do
    COUNT=$(ls /mnt/backup/vzdump-qemu-$VM-*.vma.zst 2>/dev/null | wc -l)
    echo "  VM $VM: $COUNT backups"
done
```

### 🎓 Scénarios avancés

#### Backup incrémental avec PBS

Pour les grandes infrastructures, Proxmox Backup Server offre des backups incrémentiels :

```bash
# Configuration PBS comme storage
pvesm add pbs pbs-server --server backup.example.com --datastore prod-backups

# Job de backup vers PBS
vzdump 100 --storage pbs-server --mode snapshot

# PBS gère automatiquement:
# - Déduplication
# - Incrémentation
# - Compression
# - Vérification d'intégrité
```

#### Backup avant maintenance

```bash
#!/bin/bash
# /usr/local/bin/pre-maintenance-backup.sh
# Backup de sécurité avant maintenance

VM_ID=$1
if [ -z "$VM_ID" ]; then
    echo "Usage: $0 <VMID>"
    exit 1
fi

echo "Backup de sécurité de la VM $VM_ID avant maintenance..."

# Créer un backup avec note spécifique
vzdump $VM_ID \
    --storage backup-nfs \
    --mode snapshot \
    --compress zstd \
    --notes-template "PRE-MAINTENANCE-{{timestamp}}"

# Vérifier le succès
if [ $? -eq 0 ]; then
    echo "✓ Backup réussi. Vous pouvez procéder à la maintenance."
else
    echo "✗ Échec du backup. ARRÊTEZ la maintenance !"
    exit 1
fi
```

#### Réplication combinée avec backup

```bash
# Stratégie haute disponibilité:
# 1. Réplication en temps réel vers autre nœud (HA)
# 2. Backup quotidien vers stockage externe (DR)

# Configuration réplication
pvesm add zfspool remote-zfs --server node2 --pool rpool/data

# Job backup quotidien vers NFS
Schedule: 0 2 * * *
Storage: backup-nfs

# Les deux systèmes coexistent pour protection maximale
```

#### Archivage long terme

```bash
#!/bin/bash
# /usr/local/bin/archive-backup.sh
# Déplacer les backups anciens vers archive froide

SOURCE="/mnt/backup"
ARCHIVE="/mnt/cold-archive"
AGE_DAYS=90  # Archiver après 90 jours

find $SOURCE -name "*.vma.zst" -mtime +$AGE_DAYS -exec mv {} $ARCHIVE/ \;

# Puis copier vers stockage externe (tape, cloud, etc.)
# rclone sync $ARCHIVE remote:backups-archive
```

### 💡 Astuces professionnelles

#### Template de naming intelligent

```bash
# Format recommandé pour les notes
--notes-template "{{guestname}}_{{vmid}}_{{cluster}}_{{timestamp}}_ENV:PROD_APP:WEB"

# Exemple de résultat:
# webserver01_100_cluster-prod_2025-01-15-02:00:01_ENV:PROD_APP:WEB.vma.zst

# Permet de filtrer facilement:
ls *ENV:PROD* | # Tous les backups de prod
ls *APP:DB*     # Tous les backups de bases de données
```

#### Hook de pré-backup

```bash
#!/bin/bash
# /usr/local/bin/pre-backup-hook.sh
# Exécuté AVANT chaque backup

VMID=$1
PHASE=$2  # pre-stop, pre-backup, etc.

if [ "$PHASE" == "pre-backup" ]; then
    # Nettoyer les logs dans la VM
    qm guest exec $VMID -- find /var/log -name "*.log" -mtime +7 -delete
    
    # Flush les caches
    qm guest exec $VMID -- sync
    
    echo "VM $VMID prête pour backup"
fi
```

#### Backup conditionnel

```bash
#!/bin/bash
# Backup uniquement si des changements significatifs

VM_ID=100
LAST_BACKUP_SIZE=$(ls -l /mnt/backup/vzdump-qemu-$VM_ID-*.vma.zst | tail -1 | awk '{print $5}')
CURRENT_DISK_SIZE=$(qm config $VM_ID | grep "scsi0:" | awk '{print $3}')

# Calculer le delta (simplifié)
DELTA=$((CURRENT_DISK_SIZE - LAST_BACKUP_SIZE))
PERCENT=$((DELTA * 100 / LAST_BACKUP_SIZE))

if [ $PERCENT -gt 5 ]; then
    echo "Changements détectés ($PERCENT%), backup lancé"
    vzdump $VM_ID --storage backup-nfs
else
    echo "Peu de changements ($PERCENT%), backup ignoré"
fi
```

#### Rapport de capacité

```bash
#!/bin/bash
# /usr/local/bin/capacity-planning.sh
# Prédiction de l'espace nécessaire

STORAGE="/mnt/backup"
DAILY_GROWTH=$(find $STORAGE -name "*.vma.zst" -mtime -1 -exec du -c {} + | tail -1 | awk '{print $1}')
WEEKLY_GROWTH=$((DAILY_GROWTH * 7))
MONTHLY_GROWTH=$((DAILY_GROWTH * 30))

SPACE_AVAIL=$(df $STORAGE | awk 'NR==2 {print $4}')

echo "=== Planification capacité ==="
echo "Croissance quotidienne: $(numfmt --to=iec $DAILY_GROWTH)"
echo "Croissance hebdomadaire: $(numfmt --to=iec $WEEKLY_GROWTH)"
echo "Croissance mensuelle: $(numfmt --to=iec $MONTHLY_GROWTH)"
echo "Espace disponible: $(numfmt --to=iec $SPACE_AVAIL)"

DAYS_LEFT=$((SPACE_AVAIL / DAILY_GROWTH))
echo ""
echo "⚠️  Espace suffisant pour: $DAYS_LEFT jours"

if [ $DAYS_LEFT -lt 30 ]; then
    echo "🔴 ACTION REQUISE: Augmenter l'espace de stockage !"
fi
```

---

## 🎯 Checklist de mise en production

Avant de mettre en production votre stratégie de backup :

- [ ] **Configuration testée**
    
    - [ ] Job de backup créé et activé
    - [ ] Planification cohérente avec les besoins
    - [ ] Rétention adaptée à la criticité
    - [ ] Compression configurée (ZSTD recommandé)
- [ ] **Stockage validé**
    
    - [ ] Espace suffisant calculé (x3 minimum)
    - [ ] Stockage séparé physiquement
    - [ ] Permissions correctes configurées
    - [ ] Montage automatique au boot
- [ ] **Notifications actives**
    
    - [ ] Serveur mail configuré et testé
    - [ ] Destinataires corrects
    - [ ] Mode "Failure" activé minimum
    - [ ] Webhooks configurés (si applicable)
- [ ] **Tests effectués**
    
    - [ ] Backup manuel réussi
    - [ ] Restauration testée avec succès
    - [ ] Notifications reçues
    - [ ] Intégrité des fichiers vérifiée
- [ ] **Monitoring en place**
    
    - [ ] Alertes espace disque configurées
    - [ ] Dashboard de suivi créé
    - [ ] Logs surveillés
    - [ ] Métriques KPI définies
- [ ] **Documentation**
    
    - [ ] Procédure de restauration documentée
    - [ ] Contacts d'urgence définis
    - [ ] Stratégie de rétention formalisée
    - [ ] Planning de tests réguliers établi
- [ ] **Sécurité**
    
    - [ ] Accès restreints configurés
    - [ ] Chiffrement évalué (si nécessaire)
    - [ ] Protection anti-ransomware activée
    - [ ] Audit de sécurité effectué

---

## 📚 Récapitulatif

Les sauvegardes automatiques dans Proxmox constituent la colonne vertébrale de votre stratégie de protection des données. Une configuration bien pensée doit inclure :

1. **Jobs multiples** adaptés à chaque niveau de criticité
2. **Planification intelligente** respectant les fenêtres de maintenance
3. **Sélection précise** via pools ou IDs pour un contrôle optimal
4. **Notifications proactives** pour détecter rapidement les problèmes
5. **Tests réguliers** pour garantir la restaurabilité

> [!warning] Rappel crucial Un backup non testé est un backup qui n'existe pas. Planifiez des tests de restauration réguliers et documentez vos procédures.

La mise en place d'une stratégie de backup robuste demande du temps initial, mais c'est un investissement qui peut sauver votre infrastructure en cas de sinistre. Privilégiez toujours la simplicité, la fiabilité et la surveillance continue.

---

_Fin de la partie : Sauvegardes automatiques_