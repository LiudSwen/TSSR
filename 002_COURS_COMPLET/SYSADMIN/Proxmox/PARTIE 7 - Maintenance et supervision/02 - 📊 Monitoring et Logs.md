

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

## 🎯 Introduction au monitoring Proxmox

Le monitoring et la gestion des logs sont essentiels pour maintenir un environnement Proxmox sain et performant. Proxmox intègre nativement des outils de surveillance en temps réel qui permettent de détecter rapidement les problèmes, d'analyser les performances et de maintenir une traçabilité complète des opérations.

> [!info] Pourquoi le monitoring est crucial
> 
> - **Détection précoce** : Identifier les problèmes avant qu'ils n'impactent la production
> - **Optimisation** : Analyser l'utilisation des ressources pour améliorer les performances
> - **Planification** : Anticiper les besoins en capacité
> - **Audit** : Tracer toutes les opérations pour la sécurité et la conformité
> - **Dépannage** : Disposer d'informations détaillées pour résoudre rapidement les incidents

---

## 📈 Dashboard de surveillance

Le dashboard de surveillance est l'interface centrale de monitoring dans Proxmox. Il offre une vue d'ensemble en temps réel de l'état de votre infrastructure.

### 🖥️ Accès au Dashboard

Le dashboard principal est accessible dès la connexion à l'interface web Proxmox :

1. **Connexion** : `https://votre-ip:8006`
2. **Vue Datacenter** : Sélectionnez "Datacenter" dans l'arborescence de gauche
3. **Vue Node** : Sélectionnez un nœud spécifique pour des détails précis
4. **Vue VM/CT** : Sélectionnez une VM ou un conteneur pour son monitoring dédié

### 📊 Composants du Dashboard

#### Niveau Datacenter

> [!example] Informations affichées au niveau Datacenter
> 
> - **Résumé du cluster** : Nombre de nœuds, état de santé global
> - **Ressources agrégées** : Total CPU, RAM, stockage disponible
> - **VMs et Conteneurs** : Nombre total et état (running, stopped)
> - **Alertes** : Notifications importantes sur l'infrastructure

#### Niveau Node (Serveur physique)

Le dashboard d'un nœud affiche des informations détaillées sur le serveur physique :

|Section|Description|Utilité|
|---|---|---|
|**Server View**|Nom, version Proxmox, uptime|Identification et disponibilité|
|**CPU(s)**|Utilisation en %, nombre de cœurs|Charge processeur|
|**Memory**|Utilisation RAM en GB/%|Consommation mémoire|
|**Swap**|Utilisation swap|Détection de saturation RAM|
|**Root FS**|Espace disque système|Surveillance partition système|
|**Network**|Trafic entrant/sortant|Activité réseau|
|**Load Average**|Charge système 1/5/15 min|Performance globale|

#### Niveau VM/Conteneur

Chaque machine virtuelle ou conteneur dispose de son propre dashboard :

```
┌─────────────────────────────────────┐
│  VM 100 - web-server (running)      │
├─────────────────────────────────────┤
│  CPU Usage:     15.2% (4 cores)     │
│  Memory Usage:  2.1GB / 4.0GB       │
│  Network In:    1.2 MB/s            │
│  Network Out:   0.8 MB/s            │
│  Disk Read:     245 KB/s            │
│  Disk Write:    128 KB/s            │
└─────────────────────────────────────┘
```

### 🎨 Personnalisation du Dashboard

> [!tip] Configuration de l'affichage
> 
> - **Actualisation automatique** : Les graphiques se rafraîchissent automatiquement (configurable)
> - **Période d'affichage** : Changez la plage temporelle (heure, jour, semaine, mois, année)
> - **Sélection des métriques** : Activez/désactivez certaines métriques selon vos besoins

### 🔔 Indicateurs de santé

Le dashboard utilise un code couleur pour l'état de santé :

|Couleur|Signification|Action recommandée|
|---|---|---|
|🟢 Vert|Fonctionnement normal|Aucune|
|🟡 Jaune|Avertissement, surveillance accrue|Vérifier les détails|
|🔴 Rouge|Problème critique|Intervention immédiate|
|⚫ Gris|Arrêté ou inaccessible|Vérifier l'état|

> [!warning] Seuils d'alerte typiques
> 
> - **CPU > 80%** sur une période prolongée
> - **RAM > 90%** avec swap actif
> - **Disque > 85%** d'utilisation
> - **Load average** supérieur au nombre de cœurs CPU

---

## 📊 Graphiques de ressources

Les graphiques de ressources fournissent une visualisation historique et en temps réel de l'utilisation des ressources système. Ils sont essentiels pour l'analyse de performance et la détection de tendances.

### 📉 Types de graphiques disponibles

#### 1. 💻 CPU (Processeur)

Le graphique CPU affiche l'utilisation du processeur dans le temps.

```bash
# Accès : Node > Summary > CPU Usage
# ou VM > Summary > CPU Usage
```

**Métriques affichées** :

- **Utilisation CPU** : Pourcentage d'utilisation (0-100% par cœur)
- **Mode utilisateur** : Temps CPU pour les processus utilisateur
- **Mode système** : Temps CPU pour le noyau
- **I/O Wait** : Temps d'attente des opérations disque

> [!example] Interprétation du graphique CPU
> 
> - **Pic ponctuel** : Tâche intensive normale (compilation, sauvegarde)
> - **Plateau élevé** : Charge constante, peut nécessiter plus de ressources
> - **Oscillations régulières** : Tâches planifiées (cron, backups)
> - **100% constant** : Saturation, besoin d'ajout de CPU ou optimisation

#### 2. 💾 Memory (Mémoire)

Le graphique mémoire visualise l'utilisation de la RAM et du swap.

**Métriques affichées** :

- **Memory Used** : RAM actuellement utilisée
- **Memory Available** : RAM disponible
- **Swap Used** : Mémoire swap utilisée (fichier/partition sur disque)
- **Cache/Buffer** : Mémoire utilisée pour le cache système

```
┌─ Graphique Mémoire ─────────────────┐
│                                      │
│  ████████████████░░░░ Used (12GB)    │
│  ░░░░░░░░░░░░░░░░░░░░ Free (4GB)     │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Cache (8GB)    │
│  ▒▒░░░░░░░░░░░░░░░░░░ Swap (0.5GB)   │
│                                      │
└──────────────────────────────────────┘
```

> [!warning] Surveillance du Swap
> 
> - **Swap = 0** : Situation idéale, suffisamment de RAM
> - **Swap faible** : Acceptable, cache système débordant
> - **Swap élevé** : ⚠️ Manque de RAM, performances dégradées
> - **Swap constant** : 🔴 Ajout de RAM urgente nécessaire

#### 3. 🌐 Network (Réseau)

Le graphique réseau affiche le trafic entrant et sortant.

**Métriques affichées** :

- **Traffic In** (RX) : Données reçues en MB/s ou GB/s
- **Traffic Out** (TX) : Données envoyées en MB/s ou GB/s
- **Par interface** : eth0, vmbr0, etc.

```bash
# Analyse d'un pic réseau
# Accès : Node > Summary > Network Traffic
# Comparer avec les graphiques des VMs pour identifier la source
```

> [!tip] Cas d'usage du graphique réseau
> 
> - **Identifier les heures de pointe** : Planifier les maintenances
> - **Détecter les transferts massifs** : Migrations, sauvegardes
> - **Repérer les anomalies** : Attaques DDoS, fuites de données
> - **Vérifier la bande passante** : Dimensionnement réseau

#### 4. 💿 Disk I/O (Entrées/Sorties Disque)

Le graphique Disk I/O mesure les performances de lecture/écriture sur les disques.

**Métriques affichées** :

- **Read** : Débit de lecture (MB/s)
- **Write** : Débit d'écriture (MB/s)
- **IOPS** : Opérations par seconde (disponible selon le stockage)
- **Latence** : Temps de réponse des opérations

|Type de charge|Read|Write|Interprétation|
|---|---|---|---|
|Serveur web|Élevé|Faible|Lecture de contenus statiques|
|Base de données|Moyen|Élevé|Transactions intensives|
|Backup|Très élevé|Faible|Sauvegarde en cours|
|VM inactive|Faible|Faible|Activité normale au repos|

> [!example] Détection de goulots d'étranglement
> 
> ```
> Symptômes d'I/O saturé :
> - I/O Wait élevé dans le graphique CPU (>20%)
> - Latence disque élevée (>50ms)
> - IOPS proche de la limite du stockage
> - VMs avec performances dégradées
> 
> Solutions :
> - Migrer vers du stockage SSD/NVMe
> - Répartir les VMs sur plusieurs datastores
> - Optimiser les applications gourmandes
> - Ajouter du cache (ZFS ARC, Ceph)
> ```

### 📏 Plages temporelles

Proxmox permet d'ajuster la période d'affichage des graphiques :

|Période|Utilité|Granularité|
|---|---|---|
|**Hour**|Surveillance temps réel|1 minute|
|**Day**|Analyse quotidienne|5 minutes|
|**Week**|Tendances hebdomadaires|30 minutes|
|**Month**|Planification capacité|2 heures|
|**Year**|Vue d'ensemble annuelle|1 jour|

```bash
# Navigation dans les graphiques
# - Boutons Hour/Day/Week/Month/Year en haut du graphique
# - Zoom : Cliquer-glisser sur une zone du graphique
# - Reset zoom : Double-clic sur le graphique
```

### 📊 Export et analyse des données

> [!tip] Exploitation avancée des métriques Les données de monitoring Proxmox sont stockées en interne et peuvent être exportées pour analyse :
> 
> ```bash
> # Localisation des données RRD (Round Robin Database)
> /var/lib/rrdcached/db/pve2-*
> 
> # Les données peuvent être intégrées avec :
> - Prometheus + Grafana (visualisation avancée)
> - InfluxDB (stockage long terme)
> - Scripts personnalisés (alerting)
> ```

### 🎯 Bonnes pratiques d'utilisation

> [!tip] Astuces de monitoring
> 
> 1. **Consultez régulièrement** : Vérifiez les graphiques quotidiennement
> 2. **Établissez une baseline** : Connaissez vos métriques "normales"
> 3. **Surveillez les tendances** : Un graphique croissant indique un besoin futur
> 4. **Corrélation** : Comparez les graphiques entre Node, VM et stockage
> 5. **Documentation** : Notez les événements (déploiements, pics) pour contextualiser

---

## 📝 Logs système

Les logs système de Proxmox enregistrent tous les événements importants du système d'exploitation sous-jacent (Debian). Ils sont cruciaux pour le dépannage et la sécurité.

### 📂 Accès aux logs système

```bash
# Via l'interface web
Node > System > Syslog

# Affiche en temps réel les dernières entrées du journal système
# Mise à jour automatique toutes les 3 secondes
```

### 🔍 Structure d'une entrée de log

Chaque ligne de log suit un format standardisé :

```
Dec 24 10:15:32 pve01 systemd[1]: Started Session 123 of user root.
│          │      │       │       └─ Message du log
│          │      │       └─ Processus source (PID)
│          │      └─ Nom d'hôte du serveur
│          └─ Horodatage (timestamp)
└─ Mois, jour, heure:minute:seconde
```

### 📋 Catégories de logs importants

#### 1. 🔐 Logs d'authentification

Messages liés aux connexions et à la sécurité :

```bash
# Connexions réussies
Dec 24 10:15:30 pve01 sshd[12345]: Accepted publickey for root from 192.168.1.10

# Tentatives échouées
Dec 24 10:16:45 pve01 sshd[12346]: Failed password for invalid user admin from 203.0.113.5

# Connexions web interface
Dec 24 10:17:00 pve01 pveproxy[1234]: authentication successful (user: admin@pam)
```

> [!warning] Surveillance de sécurité Surveillez particulièrement :
> 
> - Tentatives de connexion échouées répétées
> - Connexions depuis des IPs inhabituelles
> - Élévation de privilèges (sudo)
> - Modifications de comptes utilisateurs

#### 2. ⚙️ Logs système (Kernel et services)

Messages du noyau Linux et des services système :

```bash
# Démarrage de services
Dec 24 10:00:01 pve01 systemd[1]: Started Proxmox VE replication runner.

# Erreurs matérielles
Dec 24 10:05:23 pve01 kernel: [12345.678] ata1: SATA link down

# Modifications réseau
Dec 24 10:10:15 pve01 kernel: [12346.789] vmbr0: port 1(eth0) entered forwarding state
```

#### 3. 🖥️ Logs Proxmox spécifiques

Événements liés à la gestion des VMs et conteneurs :

```bash
# Démarrage VM
Dec 24 10:20:00 pve01 pvedaemon[1234]: <root@pam> successful auth for user 'root@pam'
Dec 24 10:20:01 pve01 qm[12345]: VM 100 started

# Migration
Dec 24 10:25:00 pve01 pve-ha-lrm[1234]: starting migration of VM 100 to pve02

# Snapshot
Dec 24 10:30:00 pve01 vzdump[12346]: creating vzdump archive '/var/lib/vz/dump/vzdump-qemu-100...'
```

#### 4. 💾 Logs stockage

Événements liés aux systèmes de fichiers et au stockage :

```bash
# ZFS
Dec 24 10:35:00 pve01 zed[1234]: eid=45 class=statechange pool='rpool'

# LVM
Dec 24 10:40:00 pve01 lvm[1234]: Volume group "pve" successfully extended

# Erreurs disque
Dec 24 10:45:00 pve01 kernel: [12350.123] sd 0:0:0:0: [sda] Sense Key: Medium Error
```

### 🔧 Commandes en ligne de commande

Pour une analyse plus poussée, connectez-vous en SSH au nœud :

```bash
# Afficher les logs en temps réel
tail -f /var/log/syslog

# Afficher les dernières 100 lignes
tail -n 100 /var/log/syslog

# Rechercher un terme spécifique
grep "error" /var/log/syslog

# Rechercher avec contexte (5 lignes avant/après)
grep -C 5 "failed" /var/log/syslog

# Afficher seulement les logs d'aujourd'hui
journalctl --since today

# Afficher les logs d'un service spécifique
journalctl -u pveproxy

# Afficher les logs avec priorité error ou plus grave
journalctl -p err
```

### 📊 Niveaux de sévérité des logs

Les logs utilisent des niveaux de priorité standardisés (syslog) :

|Niveau|Nom|Description|Exemple|
|---|---|---|---|
|0|Emergency|Système inutilisable|Kernel panic|
|1|Alert|Action immédiate requise|Corruption filesystem|
|2|Critical|Condition critique|Panne matérielle|
|3|Error|Erreur|Service qui ne démarre pas|
|4|Warning|Avertissement|Disque presque plein|
|5|Notice|Notice normale|Redémarrage service|
|6|Info|Informatif|Connexion utilisateur|
|7|Debug|Debug|Informations détaillées|

### 🎯 Analyse pratique des logs

> [!example] Scénario : Recherche de la cause d'un crash VM
> 
> ```bash
> # 1. Identifier l'heure du crash dans l'interface web
> 
> # 2. Consulter les logs autour de cette période
> grep "VM 100" /var/log/syslog | grep -i "error\|fail\|crash"
> 
> # 3. Vérifier les logs kernel pour erreurs matérielles
> journalctl -k --since "2025-01-15 10:00:00" --until "2025-01-15 10:30:00"
> 
> # 4. Consulter les logs spécifiques QEMU
> journalctl -u qemu-server@100 --since "2025-01-15 10:00:00"
> 
> # 5. Vérifier l'état du stockage
> dmesg | grep -i "error\|fail" | grep sd
> ```

### 🔄 Rotation et conservation des logs

Proxmox utilise `logrotate` pour gérer automatiquement les logs :

```bash
# Configuration de la rotation
/etc/logrotate.d/rsyslog

# Paramètres par défaut :
# - Rotation hebdomadaire
# - Conservation de 4 semaines
# - Compression des anciens logs
# - Logs archivés : /var/log/syslog.1.gz, syslog.2.gz, etc.
```

> [!tip] Gestion de l'espace disque
> 
> ```bash
> # Vérifier l'espace utilisé par les logs
> du -sh /var/log/
> 
> # Voir les plus gros fichiers de logs
> du -h /var/log/* | sort -h | tail -n 10
> 
> # Forcer une rotation manuelle si nécessaire
> logrotate -f /etc/logrotate.conf
> ```

---

## 📋 Journal des tâches

Le journal des tâches (Task Log) enregistre toutes les opérations administratives effectuées dans Proxmox. C'est un outil d'audit essentiel qui trace chaque action avec son résultat.

### 📍 Accès au journal des tâches

```bash
# Via l'interface web
# Méthode 1 : Vue globale
Datacenter > Tasks

# Méthode 2 : Par nœud
Node > Tasks

# Méthode 3 : Par VM/Conteneur
VM/CT > Tasks (uniquement les tâches de cette VM)
```

### 🔍 Structure du journal des tâches

Le journal des tâches se présente sous forme de tableau avec les colonnes suivantes :

|Colonne|Description|Exemple|
|---|---|---|
|**Status**|État de la tâche|✅ OK, ❌ Error, ⏳ Running|
|**Start Time**|Date et heure de début|2025-01-15 10:30:45|
|**Duration**|Durée d'exécution|00:02:35|
|**Type**|Type d'opération|vzdump, qmstart, vzmigrate|
|**ID**|Identifiant VM/CT|100, 101, etc.|
|**User**|Utilisateur ayant lancé la tâche|root@pam|
|**Node**|Nœud concerné|pve01|

### 📂 Types de tâches enregistrées

#### 1. 🚀 Opérations VM/Conteneur

```
┌─ Tâches courantes ──────────────────────┐
│                                          │
│  qmstart     - Démarrage VM              │
│  qmstop      - Arrêt VM                  │
│  qmshutdown  - Arrêt propre VM           │
│  qmreboot    - Redémarrage VM            │
│  qmreset     - Reset VM                  │
│  qmcreate    - Création VM               │
│  qmdestroy   - Suppression VM            │
│                                          │
│  vzstart     - Démarrage conteneur       │
│  vzstop      - Arrêt conteneur           │
│  vzcreate    - Création conteneur        │
│  vzdestroy   - Suppression conteneur     │
│                                          │
└──────────────────────────────────────────┘
```

#### 2. 💾 Opérations de sauvegarde et snapshot

```bash
# Sauvegarde (vzdump)
TASK: vzdump 100
Duration: 00:05:23
Status: OK
INFO: Starting Backup of VM 100
INFO: Backup finished at 2025-01-15 10:35:45

# Snapshot
TASK: qmsnapshot 100 --snapname backup-20250115
Status: OK

# Restauration
TASK: qmrestore 100 --archive /var/lib/vz/dump/vzdump-qemu-100...
Duration: 00:08:12
Status: OK
```

#### 3. 🔄 Opérations de migration

```bash
# Migration
TASK: qmigrate 100 --target pve02
Status: OK
INFO: Starting migration of VM 100 to node 'pve02'
INFO: Starting migration tunnel
INFO: Migration finished successfully (duration 00:02:15)

# Migration avec stockage
TASK: qmigrate 100 --target pve02 --targetstorage local-lvm
```

#### 4. ⚙️ Opérations de configuration

```bash
# Modification configuration VM
TASK: qmset 100
Status: OK
INFO: Update VM 100: -cores 4 -memory 8192

# Redimensionnement disque
TASK: qmresize 100 --disk scsi0 --size +20G
Status: OK
```

#### 5. 🗂️ Opérations de stockage

```bash
# Création volume
TASK: pvesm alloc local-lvm 100 vm-100-disk-1 10G

# Suppression volume
TASK: pvesm free local-lvm:vm-100-disk-1

# Template creation
TASK: qmtemplate 100
Status: OK
```

### 📊 Analyse détaillée d'une tâche

Cliquer sur une tâche dans le journal ouvre une fenêtre détaillée :

```
┌─ Task Details ──────────────────────────────────────┐
│                                                      │
│  UPID: UPID:pve01:00001234:00ABCDEF:5F8B1234:       │
│        vzdump:100:root@pam:                          │
│                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                      │
│  INFO: Starting Backup of VM 100 (qemu)              │
│  INFO: Backup started at 2025-01-15 10:30:00         │
│  INFO: status = running                              │
│  INFO: Backup mode: snapshot                         │
│  INFO: Creating Snapshot                             │
│  INFO: Snapshot created                              │
│  INFO: Creating archive '/var/lib/vz/dump/...'       │
│  INFO: Transferred 15.2 GB in 312 seconds            │
│  INFO: Average speed: 49.8 MB/s                      │
│  INFO: Archive size: 8.3 GB (compression: 45%)       │
│  INFO: Backup finished at 2025-01-15 10:35:23        │
│  INFO: TASK OK                                       │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### 🎛️ Filtrage et recherche

Le journal des tâches offre plusieurs options de filtrage :

```bash
# Filtres disponibles dans l'interface web
┌─ Filtres ──────────────────────────┐
│                                    │
│  Since: [Dernière heure ▼]         │
│  Until: [Maintenant     ▼]         │
│  Type:  [Tous les types ▼]         │
│  Status: [Tous          ▼]         │
│  VMID:  [100]                      │
│                                    │
│  [Appliquer] [Réinitialiser]       │
│                                    │
└────────────────────────────────────┘
```

> [!example] Cas d'usage des filtres
> 
> ```
> Rechercher toutes les sauvegardes échouées du mois :
> - Since: Il y a 1 mois
> - Type: vzdump
> - Status: Error
> 
> Vérifier les migrations de la VM 100 :
> - VMID: 100
> - Type: qmigrate
> 
> Audit des actions d'un utilisateur :
> - User: tech@pam
> - Since: Date de début de son contrat
> ```

### 🔧 Accès via ligne de commande

```bash
# Afficher toutes les tâches actives
pvesh get /cluster/tasks

# Afficher les tâches d'une VM spécifique
pvesh get /nodes/{node}/qemu/{vmid}/status/current

# Afficher les tâches avec filtre
pvesh get /cluster/tasks --typefilter vzdump

# Détails d'une tâche spécifique (via son UPID)
pvesh get /nodes/{node}/tasks/{upid}/log
```

### 📈 Statistiques et rapports

> [!tip] Analyse des tâches
> 
> ```bash
> # Compter les tâches par type
> grep "TASK OK" /var/log/pve/tasks/* | cut -d: -f3 | sort | uniq -c
> 
> # Identifier les tâches longues (>10 minutes)
> # Via l'interface, trier par "Duration" décroissante
> 
> # Taux de réussite des sauvegardes
> # Comparer nombre de OK vs ERROR pour type=vzdump
> ```

### ⚠️ Gestion des erreurs

Lorsqu'une tâche échoue, le journal fournit des informations détaillées :

```bash
TASK ERROR: vzdump 100
Duration: 00:01:05
Status: ERROR

INFO: Starting Backup of VM 100
INFO: status = running
ERROR: Backup of VM 100 failed - unable to create snapshot
ERROR: Cannot create snapshot: device or resource busy
TASK ERROR
```

> [!warning] Actions en cas d'erreur
> 
> 1. **Lire le message d'erreur complet** : Cliquez sur la tâche pour voir tous les détails
> 2. **Identifier la cause** : Snapshot impossible, manque d'espace, timeout réseau, etc.
> 3. **Consulter le syslog** : Vérifier s'il y a des erreurs système correlées
> 4. **Relancer la tâche** : Après correction du problème
> 5. **Documenter** : Noter la cause et la solution pour référence future

### 🗑️ Nettoyage et archivage

```bash
# Localisation des logs de tâches
/var/log/pve/tasks/

# Structure :
# /var/log/pve/tasks/[INDEX]/[UPID]
# INDEX = 2 premiers caractères de l'UPID

# Les tâches sont automatiquement archivées après 30 jours
# Configuration dans /etc/pve/datacenter.cfg
```

> [!tip] Bonnes pratiques
> 
> - Consultez régulièrement le journal pour détecter les problèmes récurrents
> - Utilisez les filtres pour créer des "vues" par type d'opération
> - Documentez les tâches inhabituelles ou les erreurs pour référence
> - Exportez les logs importants pour audit ou conformité
> - Surveillez particulièrement les tâches nocturnes automatiques (backups)

---

## 🔍 Syslog

Syslog est le système de journalisation centralisé de Proxmox. Il collecte, stocke et permet l'analyse de tous les messages système, formant la base du monitoring et du dépannage de l'infrastructure.

### 📖 Qu'est-ce que Syslog ?

Syslog est un protocole et un système standard de journalisation utilisé par Linux et Unix. Dans Proxmox, il centralise les messages de :

- **Kernel Linux** : Messages du noyau, pilotes matériels
- **Services système** : systemd, réseau, stockage
- **Applications Proxmox** : pvedaemon, pveproxy, pvestatd
- **VMs et Conteneurs** : Événements de gestion
- **Sécurité** : Authentifications, accès, modifications

> [!info] Architecture Syslog dans Proxmox
> 
> ```
> ┌─────────────────────────────────────────┐
> │  Sources de logs                        │
> ├─────────────────────────────────────────┤
> │  Kernel → systemd-journald → rsyslog    │
> │  Services → systemd → rsyslog           │
> │  Applications → rsyslog                 │
> └─────────────┬───────────────────────────┘
>               ↓
> ┌─────────────────────────────────────────┐
> │  rsyslog (daemon de journalisation)     │
> │  - Filtrage par priorité                │
> │  - Routage vers fichiers                │
> │  - Envoi vers serveur distant (optionnel)│
> └─────────────┬───────────────────────────┘
>               ↓
> ┌─────────────────────────────────────────┐
> │  Fichiers de logs                       │
> │  /var/log/syslog                        │
> │  /var/log/auth.log                      │
> │  /var/log/daemon.log                    │
> │  /var/log/kern.log                      │
> └─────────────────────────────────────────┘
> ```

### 📂 Fichiers de logs principaux

Proxmox utilise plusieurs fichiers de logs spécialisés :

|Fichier|Contenu|Utilisation|
|---|---|---|
|`/var/log/syslog`|**Tous les messages** système|Vue globale, première consultation|
|`/var/log/auth.log`|**Authentification** et sécurité|Connexions SSH, sudo, login|
|`/var/log/daemon.log`|**Services** et démons|Proxmox, QEMU, LXC|
|`/var/log/kern.log`|**Kernel** Linux|Matériel, drivers, erreurs bas niveau|
|`/var/log/mail.log`|**Emails** système|Notifications, alertes|
|`/var/log/pve/`|**Logs Proxmox** spécifiques|Tasks, cluster, API|

### 🔧 Accès et consultation Syslog

#### Via l'interface web

```bash
# Navigation
Node > System > Syslog

# Fonctionnalités :
# - Affichage en temps réel (auto-refresh)
# - Filtrage par niveau de sévérité
# - Recherche par mot-clé
# - Export du contenu
```

#### Via ligne de commande

```bash
# Afficher les logs en temps réel
tail -f /var/log/syslog

# Afficher les 50 dernières lignes
tail -n 50 /var/log/syslog

# Afficher les logs d'authentification
tail -f /var/log/auth.log

# Rechercher un terme spécifique
grep "error" /var/log/syslog

# Rechercher avec numéro de ligne
grep -n "VM 100" /var/log/syslog

# Rechercher en ignorant la casse
grep -i "warning" /var/log/syslog

# Compter les occurrences
grep -c "failed" /var/log/auth.log

# Recherche multi-fichiers
grep "pvedaemon" /var/log/*.log
```

### 🎯 Utilisation de journalctl

`journalctl` est l'outil moderne de consultation des logs systemd, plus puissant que les fichiers texte classiques :

```bash
# Afficher tous les logs
journalctl

# Logs en temps réel (comme tail -f)
journalctl -f

# Logs depuis le dernier démarrage
journalctl -b

# Logs d'un service spécifique
journalctl -u pvedaemon
journalctl -u pveproxy
journalctl -u qemu-server@100  # Logs VM 100

# Logs par période
journalctl --since "2025-01-15 10:00:00"
journalctl --since "1 hour ago"
journalctl --since today
journalctl --since yesterday --until today

# Logs par priorité (niveau de sévérité)
journalctl -p err              # Erreurs uniquement
journalctl -p warning          # Warnings et plus grave
journalctl -p info             # Info et plus grave

# Logs du kernel uniquement
journalctl -k
journalctl -k -p err           # Erreurs kernel

# Logs avec contexte (lignes avant/après)
journalctl -u pvedaemon -n 100

# Format de sortie
journalctl -o json             # Format JSON
journalctl -o json-pretty      # JSON formaté
journalctl -o verbose          # Tous les champs

# Combiner plusieurs critères
journalctl -u pvedaemon --since "10 minutes ago" -p warning
```

> [!tip] Raccourcis journalctl utiles
> 
> ```bash
> # Navigation dans journalctl
> Espace       - Page suivante
> b            - Page précédente
> g            - Début du journal
> G            - Fin du journal
> /motif       - Rechercher
> n            - Occurrence suivante
> q            - Quitter
> 
> # Export pour analyse
> journalctl --since today > /tmp/logs-today.txt
> journalctl -u pvedaemon --since "1 week ago" -o json > /tmp/pvedaemon.json
> ```

### 🔎 Analyse pratique avec Syslog

#### Scénario 1 : Déboguer une VM qui ne démarre pas

```bash
# 1. Identifier les logs récents de la VM 100
journalctl -u qemu-server@100 --since "10 minutes ago"

# 2. Vérifier les erreurs Proxmox
grep "VM 100" /var/log/syslog | grep -i error

# 3. Vérifier les erreurs QEMU
journalctl -u qemu-server@100 -p err

# 4. Vérifier l'état du stockage
journalctl -k | grep -i "sd\|scsi\|disk" | grep -i error
```

#### Scénario 2 : Audit de sécurité

```bash
# Tentatives de connexion échouées
grep "Failed password" /var/log/auth.log

# Compter les échecs par IP
grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr

# Connexions SSH réussies
grep "Accepted" /var/log/auth.log

# Utilisations de sudo
grep "sudo" /var/log/auth.log

# Modifications de comptes
journalctl | grep -E "user|group" | grep -i "add\|modify\|delete"
```

#### Scénario 3 : Performance et ressources

```bash
# Messages de saturation mémoire (OOM - Out Of Memory)
journalctl -k | grep -i "out of memory\|oom"

# Erreurs disque
journalctl -k | grep -i "error\|fail" | grep -i "sd\|disk"

# Problèmes réseau
journalctl -k | grep -i "network\|eth\|vmbr" | grep -i error

# Messages de température/ventilation
journalctl -k | grep -i "temp\|thermal\|fan"
```

### ⚙️ Configuration Syslog (rsyslog)

La configuration de rsyslog se trouve dans `/etc/rsyslog.conf` et `/etc/rsyslog.d/` :

```bash
# Fichier principal
/etc/rsyslog.conf

# Fichiers de configuration additionnels
/etc/rsyslog.d/50-default.conf
/etc/rsyslog.d/pve.conf         # Configuration Proxmox

# Visualiser la configuration
cat /etc/rsyslog.d/50-default.conf
```

#### Structure d'une règle rsyslog

```bash
# Format : facility.priority    action
# Exemple :
*.info;mail.none;authpriv.none;cron.none    /var/log/syslog
│  │    │                                    └─ Destination
│  │    └─ Exclusions
│  └─ Niveau de priorité
└─ Facility (source)
```

### 📊 Facilities et Priorités Syslog

#### Facilities (sources de messages)

|Facility|Code|Description|
|---|---|---|
|`kern`|0|Messages du kernel|
|`user`|1|Messages niveau utilisateur|
|`mail`|2|Système de mail|
|`daemon`|3|Démons système|
|`auth`|4|Sécurité/autorisation|
|`syslog`|5|Messages syslogd|
|`lpr`|6|Sous-système d'impression|
|`news`|7|Sous-système news|
|`cron`|15|Tâches planifiées|
|`local0-7`|16-23|Usage local personnalisé|

#### Priorités (niveaux de sévérité)

|Priorité|Code|Signification|Quand utiliser|
|---|---|---|---|
|`emerg`|0|Urgence - système inutilisable|Kernel panic|
|`alert`|1|Alerte - action immédiate|Base de données corrompue|
|`crit`|2|Critique|Disque dur défaillant|
|`err`|3|Erreur|Service qui crash|
|`warning`|4|Avertissement|Disque à 85%|
|`notice`|5|Notice normale|Configuration modifiée|
|`info`|6|Information|Démarrage service|
|`debug`|7|Debug|Informations de développement|

### 📤 Centralisation des logs (Syslog distant)

Pour un cluster Proxmox ou une infrastructure importante, il est recommandé de centraliser les logs sur un serveur dédié.

#### Configuration d'un serveur de logs distant

```bash
# Sur le serveur de logs (récepteur)
# Éditer /etc/rsyslog.conf

# Activer la réception UDP (port 514)
module(load="imudp")
input(type="imudp" port="514")

# Activer la réception TCP (port 514) - plus fiable
module(load="imtcp")
input(type="imtcp" port="514")

# Redémarrer rsyslog
systemctl restart rsyslog
```

#### Configuration des clients Proxmox (émetteurs)

```bash
# Sur chaque nœud Proxmox
# Créer /etc/rsyslog.d/remote.conf

# Envoi vers serveur distant via UDP
*.* @192.168.1.100:514

# Envoi via TCP (recommandé, plus fiable)
*.* @@192.168.1.100:514

# Envoi uniquement des erreurs et plus grave
*.err @@192.168.1.100:514

# Redémarrer rsyslog
systemctl restart rsyslog
```

> [!warning] Sécurité de la centralisation Pour un environnement de production, utilisez TLS pour chiffrer les logs en transit :
> 
> ```bash
> # Configuration TLS dans rsyslog
> # Nécessite des certificats SSL/TLS
> # Voir documentation rsyslog-tls
> ```

### 🗄️ Gestion et rotation des logs

#### Logrotate - Rotation automatique

Proxmox utilise `logrotate` pour gérer la taille et la rétention des logs :

```bash
# Configuration principale
/etc/logrotate.conf

# Configurations spécifiques
/etc/logrotate.d/rsyslog
/etc/logrotate.d/pve

# Exemple de configuration
cat /etc/logrotate.d/rsyslog
```

Configuration typique :

```bash
/var/log/syslog
{
    rotate 7           # Conserver 7 fichiers
    daily              # Rotation quotidienne
    missingok          # Pas d'erreur si fichier manquant
    notifempty         # Ne pas rotate si vide
    delaycompress      # Compresser à la prochaine rotation
    compress           # Compresser les anciens logs
    postrotate         # Commande après rotation
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
```

#### Commandes logrotate utiles

```bash
# Forcer une rotation manuelle
logrotate -f /etc/logrotate.conf

# Tester la configuration (mode debug, sans rotation)
logrotate -d /etc/logrotate.conf

# Forcer rotation d'un fichier spécifique
logrotate -f /etc/logrotate.d/rsyslog

# Vérifier l'état de la dernière rotation
cat /var/lib/logrotate/status
```

#### Vérifier l'espace disque des logs

```bash
# Taille totale de /var/log
du -sh /var/log/

# Détail par fichier (top 10)
du -h /var/log/* | sort -hr | head -10

# Surveiller en temps réel la croissance
watch -n 5 'du -sh /var/log/*'

# Identifier les gros fichiers
find /var/log -type f -size +100M -exec ls -lh {} \;
```

> [!tip] Gestion de l'espace disque
> 
> ```bash
> # Si /var/log sature, actions d'urgence :
> 
> # 1. Identifier le coupable
> du -h /var/log/* | sort -hr
> 
> # 2. Archiver manuellement si nécessaire
> tar -czf /backup/logs-$(date +%Y%m%d).tar.gz /var/log/*.log
> 
> # 3. Vider un log sans arrêter le service
> > /var/log/syslog                    # ATTENTION : perte de données
> truncate -s 0 /var/log/syslog        # Alternative
> 
> # 4. Forcer la rotation
> logrotate -f /etc/logrotate.conf
> 
> # 5. Ajuster la configuration logrotate si récurrent
> # Réduire le nombre de rotations conservées
> # Augmenter la fréquence de rotation
> ```

### 🚨 Alertes et surveillance proactive

#### Surveillance avec systemd

```bash
# Vérifier les services en erreur
systemctl --failed

# Surveiller les logs avec alerte
journalctl -f -p err

# Créer un alias pour surveillance
alias watch-errors='journalctl -f -p err --no-pager'
```

#### Scripts de surveillance personnalisés

```bash
# Script de surveillance basique
#!/bin/bash
# /usr/local/bin/check-logs.sh

# Vérifier les erreurs dans la dernière heure
ERRORS=$(journalctl --since "1 hour ago" -p err | wc -l)

if [ $ERRORS -gt 10 ]; then
    echo "ALERTE : $ERRORS erreurs détectées dans la dernière heure"
    # Envoyer email ou notification
    mail -s "Alerte Proxmox" admin@example.com <<< "Trop d'erreurs"
fi
```

#### Utilisation de fail2ban pour la sécurité

```bash
# Installation
apt update
apt install fail2ban

# Configuration Proxmox
cat > /etc/fail2ban/jail.local <<EOF
[proxmox]
enabled = true
port = https,http,8006
filter = proxmox
logpath = /var/log/daemon.log
maxretry = 3
bantime = 3600
EOF

# Créer le filtre
cat > /etc/fail2ban/filter.d/proxmox.conf <<EOF
[Definition]
failregex = pvedaemon\[.*authentication failure.*rhost=<HOST>
ignoreregex =
EOF

# Redémarrer fail2ban
systemctl restart fail2ban

# Vérifier les bannissements
fail2ban-client status proxmox
```

### 📚 Bonnes pratiques Syslog

> [!tip] Recommandations essentielles **1. Consultation régulière**
> 
> - Consultez les logs quotidiennement, même sans problème apparent
> - Apprenez à reconnaître les patterns normaux de votre système
> 
> **2. Recherche efficace**
> 
> - Utilisez `journalctl` pour les recherches complexes
> - Combinez `grep`, `awk`, `sort`, `uniq` pour l'analyse
> - Créez des alias pour vos recherches fréquentes
> 
> **3. Conservation appropriée**
> 
> - Logs système : 1-2 semaines localement
> - Logs de sécurité : 3-6 mois (réglementaire)
> - Logs archivés : selon politique d'entreprise
> 
> **4. Centralisation**
> 
> - Serveur de logs dédié pour les clusters
> - Sauvegarde régulière des logs importants
> - Chiffrement des logs sensibles
> 
> **5. Automatisation**
> 
> - Scripts de surveillance automatique
> - Alertes sur événements critiques
> - Rapports périodiques
> 
> **6. Documentation**
> 
> - Notez les événements inhabituels et leur résolution
> - Créez une base de connaissances des erreurs courantes
> - Documentez votre configuration rsyslog/logrotate

### 🎓 Commandes essentielles à retenir

```bash
# Les 10 commandes les plus utiles pour Syslog

# 1. Vue temps réel tous logs
tail -f /var/log/syslog

# 2. Logs temps réel avec journalctl
journalctl -f

# 3. Erreurs récentes
journalctl -p err --since "1 hour ago"

# 4. Logs d'un service
journalctl -u pvedaemon

# 5. Recherche avec contexte
grep -C 5 "error" /var/log/syslog

# 6. Erreurs kernel
journalctl -k -p err

# 7. Logs d'authentification
tail -f /var/log/auth.log

# 8. Espace disque logs
du -sh /var/log/*

# 9. Rotation manuelle
logrotate -f /etc/logrotate.conf

# 10. Export pour analyse
journalctl --since today > ~/logs-analyse.txt
```

---

## 🎯 Synthèse et vue d'ensemble

### 🔄 Intégration des outils de monitoring

Le monitoring Proxmox repose sur une combinaison d'outils complémentaires :

```
┌─────────────────────────────────────────────┐
│         MONITORING PROXMOX                  │
├─────────────────────────────────────────────┤
│                                             │
│  📈 Dashboard    →  Vue temps réel          │
│                     Alertes visuelles       │
│                                             │
│  📊 Graphiques   →  Analyse historique      │
│                     Tendances               │
│                                             │
│  📝 Logs Système →  Événements système      │
│                     Erreurs matérielles     │
│                                             │
│  📋 Tasks        →  Audit opérations        │
│                     Historique actions      │
│                                             │
│  🔍 Syslog       →  Dépannage approfondi    │
│                     Analyse technique       │
│                                             │
└─────────────────────────────────────────────┘
```

### 📊 Méthodologie de surveillance quotidienne

> [!example] Routine de monitoring recommandée **Matin (5 minutes)**
> 
> 1. Dashboard → Vérifier état global (nœuds, VMs, alertes)
> 2. Graphiques → Analyser la nuit (CPU, RAM, réseau)
> 3. Tasks → Vérifier succès des backups nocturnes
> 
> **Hebdomadaire (15 minutes)**
> 
> 4. Syslog → Rechercher erreurs récurrentes
> 5. Graphiques → Analyser tendances sur 7 jours
> 6. Tasks → Auditer toutes les opérations de la semaine
> 7. Espace disque → Vérifier logs et stockage
> 
> **Mensuel (30 minutes)**
> 
> 8. Analyse complète des performances
> 9. Planification capacité (croissance ressources)
> 10. Archivage logs importants
> 11. Revue de la configuration monitoring

### 🔧 Dépannage : approche méthodique

Lorsqu'un problème survient, suivez cette approche structurée :

```
1. IDENTIFIER
   ↓
   Dashboard → Quel composant ? (Node, VM, Stockage)
   
2. CONTEXTUALISER
   ↓
   Graphiques → Quand ? (pic ressources, changement)
   
3. DÉTAILLER
   ↓
   Tasks → Quelle opération ? (backup, migration, etc.)
   
4. ANALYSER
   ↓
   Syslog → Pourquoi ? (erreur technique précise)
   
5. RÉSOUDRE
   ↓
   Action corrective + Documentation
```

### 💡 Astuces finales

> [!tip] Optimisations et raccourcis **Interface Web**
> 
> - Ctrl+F5 : Rafraîchir le dashboard
> - Favoris navigateur : Créez des liens directs vers vos vues fréquentes
> - Multi-onglets : Dashboard + Syslog + Tasks simultanément
> 
> **Ligne de commande**
> 
> ```bash
> # Créer des alias dans ~/.bashrc
> alias pve-errors='journalctl -p err --since "1 hour ago"'
> alias pve-tasks='pvesh get /cluster/tasks | less'
> alias pve-watch='watch -n 2 "pvesh get /nodes/$(hostname)/status"'
> alias pve-vms='qm list'
> 
> # Script de monitoring personnalisé
> # /usr/local/bin/pve-status.sh
> #!/bin/bash
> echo "=== Proxmox Status ==="
> pvesh get /nodes/$(hostname)/status
> echo "
> ```

=== Recent Errors ==="

> journalctl -p err --since "1 hour ago" --no-pager | tail -10 echo " === Failed Tasks ===" pvesh get /cluster/tasks --errors 1 --limit 5
> 
> ```
> 
> **Surveillance avancée**
> - Intégration Prometheus/Grafana pour dashboards personnalisés
> - Exporteur Proxmox pour métriques détaillées
> - Alerting avec Alertmanager
> - Scripts de monitoring automatique (cron)
> ```

---

## ✅ Points clés à retenir

> [!info] Résumé des concepts essentiels
> 
> **📈 Dashboard**
> 
> - Interface centrale de surveillance en temps réel
> - Vue par niveau : Datacenter → Node → VM/CT
> - Code couleur pour identifier rapidement les problèmes
> 
> **📊 Graphiques de ressources**
> 
> - Visualisation historique : CPU, RAM, réseau, disque
> - Analyse des tendances et détection des anomalies
> - Plages temporelles : heure, jour, semaine, mois, année
> 
> **📝 Logs système**
> 
> - Événements système et matériels
> - Accès via interface web ou commande (journalctl)
> - Filtrage par priorité et période
> 
> **📋 Journal des tâches**
> 
> - Audit complet de toutes les opérations administratives
> - Traçabilité : qui, quoi, quand, résultat
> - Essentiel pour dépannage et conformité
> 
> **🔍 Syslog**
> 
> - Journalisation centralisée de tous les messages
> - Outil de dépannage technique approfondi
> - Configuration via rsyslog, rotation via logrotate

### 🚀 Prochaines compétences

Le monitoring et les logs vous ont permis de maîtriser la surveillance de votre infrastructure Proxmox. Vous êtes maintenant capable de :

✅ Interpréter l'état de santé de votre système  
✅ Analyser les performances et détecter les goulots d'étranglement  
✅ Tracer toutes les opérations effectuées  
✅ Dépanner efficacement les problèmes  
✅ Anticiper les besoins en capacité

Ces compétences sont essentielles pour maintenir un environnement Proxmox stable, performant et sécurisé.