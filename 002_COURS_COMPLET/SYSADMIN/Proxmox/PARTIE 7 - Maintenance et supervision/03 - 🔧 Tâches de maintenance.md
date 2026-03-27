

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

## Introduction

La maintenance régulière de Proxmox VE est essentielle pour garantir la stabilité, les performances et la sécurité de votre infrastructure de virtualisation. Ces tâches préventives permettent d'éviter les problèmes avant qu'ils ne surviennent et d'assurer une disponibilité optimale de vos VM et conteneurs.

> [!info] Pourquoi la maintenance est cruciale
> 
> - **Prévention des pannes** : Détection précoce des problèmes potentiels
> - **Optimisation des ressources** : Libération d'espace disque inutilisé
> - **Stabilité du système** : Maintien d'un environnement propre et fonctionnel
> - **Conformité** : Respect des bonnes pratiques d'administration système

---

## Nettoyage des anciens kernels

### 🎯 Pourquoi nettoyer les anciens kernels ?

Proxmox conserve automatiquement les anciennes versions du kernel lors des mises à jour. Bien que cette pratique soit sécuritaire (elle permet de revenir à un kernel stable en cas de problème), l'accumulation de kernels peut :

- Saturer la partition `/boot` (généralement limitée à 512 Mo)
- Empêcher l'installation de nouvelles mises à jour
- Ralentir le démarrage du système (plus d'entrées GRUB)

> [!warning] Attention Ne supprimez JAMAIS le kernel actuellement en cours d'utilisation ! Vérifiez toujours avec `uname -r` avant toute suppression.

### 📊 Monitoring automatisé des services

#### Script de vérification complète

```bash
#!/bin/bash
# Script de monitoring complet des services Proxmox

LOG_FILE="/var/log/pve-service-check.log"
EMAIL="admin@domain.com"
HOSTNAME=$(hostname)

echo "=== Service Check - $(date) ===" | tee -a $LOG_FILE

# Liste des services critiques à vérifier
SERVICES=("pvedaemon" "pveproxy" "pvestatd" "pve-cluster" "corosync" "pve-firewall")

FAILED_SERVICES=""

for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "✓ $service : OK" | tee -a $LOG_FILE
    else
        echo "✗ $service : FAILED" | tee -a $LOG_FILE
        FAILED_SERVICES="$FAILED_SERVICES $service"
        
        # Tentative de redémarrage automatique
        echo "Tentative de redémarrage de $service..." | tee -a $LOG_FILE
        systemctl restart "$service"
        sleep 5
        
        if systemctl is-active --quiet "$service"; then
            echo "✓ $service redémarré avec succès" | tee -a $LOG_FILE
        else
            echo "✗ Échec du redémarrage de $service" | tee -a $LOG_FILE
        fi
    fi
done

# Envoyer une alerte si des services ont échoué
if [ -n "$FAILED_SERVICES" ]; then
    echo "ALERTE : Services en échec sur $HOSTNAME : $FAILED_SERVICES" | \
    mail -s "Services Proxmox en échec sur $HOSTNAME" $EMAIL
fi

# Vérifier l'accès à l'interface web
if ! curl -k -s https://localhost:8006/api2/json > /dev/null; then
    echo "✗ Interface web inaccessible !" | tee -a $LOG_FILE
    echo "Interface web Proxmox inaccessible sur $HOSTNAME" | \
    mail -s "Interface Proxmox inaccessible" $EMAIL
else
    echo "✓ Interface web : OK" | tee -a $LOG_FILE
fi

echo "====================================" | tee -a $LOG_FILE
```

#### Configuration d'un cron pour le monitoring

```bash
# Éditer la crontab
crontab -e

# Ajouter une vérification toutes les 5 minutes
*/5 * * * * /usr/local/bin/pve-service-check.sh

# Ou une vérification toutes les heures
0 * * * * /usr/local/bin/pve-service-check.sh

# Rendre le script exécutable
chmod +x /usr/local/bin/pve-service-check.sh
```

### 🌐 Vérification des services réseau

```bash
# Vérifier tous les ports écoutés par Proxmox
ss -tlnp | grep -E 'pve|corosync|qemu'

# Ports standards Proxmox :
# 8006  : Interface web (HTTPS)
# 3128  : SPICE Proxy
# 5900+ : Console VNC des VM
# 5405  : Corosync (multicast)
# 85    : pveproxy (API)

# Tester la connectivité cluster (si applicable)
ping -c 3 <IP_AUTRE_NOEUD>

# Vérifier la latence réseau entre nœuds
fping -c 10 -p 100 <IP_NOEUD1> <IP_NOEUD2>

# Vérifier le multicast (pour corosync)
omping -c 5 <IP_NOEUD1> <IP_NOEUD2>
```

### 🔐 Vérification des certificats SSL

```bash
# Vérifier la validité du certificat de l'interface web
openssl s_client -connect localhost:8006 -showcerts 2>/dev/null | \
openssl x509 -noout -dates

# Afficher les détails du certificat
openssl x509 -in /etc/pve/local/pveproxy-ssl.pem -noout -text

# Vérifier l'expiration du certificat
openssl x509 -in /etc/pve/local/pveproxy-ssl.pem -noout -enddate

# Renouveler le certificat SSL si nécessaire
pvecm updatecerts
```

### 📈 Surveillance des performances des services

```bash
# Vérifier l'utilisation CPU et mémoire des services Proxmox
ps aux | grep -E 'pve|corosync|qemu' | awk '{print $2, $3, $4, $11}'

# Utiliser top pour surveiller en temps réel
top -p $(pgrep -d',' pvedaemon)

# Surveiller les ressources avec systemd-cgtop
systemd-cgtop

# Afficher les statistiques de charge système
uptime
cat /proc/loadavg

# Vérifier les temps de réponse de l'API
time curl -k https://localhost:8006/api2/json
```

### 🔍 Analyse des logs

```bash
# Consulter les logs système généraux
journalctl -xe

# Logs des dernières 24h pour un service spécifique
journalctl -u pvedaemon --since "24 hours ago"

# Suivre les logs en temps réel
journalctl -u pveproxy -f

# Rechercher des erreurs dans les logs
journalctl -p err -b

# Logs spécifiques aux VM
tail -f /var/log/qemu-server/*.log

# Logs des conteneurs
journalctl -u lxc@*

# Exporter les logs pour analyse
journalctl -u pvedaemon --since "2025-12-20" > /tmp/pvedaemon.log
```

> [!tip] Centralisation des logs Pour une infrastructure multi-nœuds, configurez un serveur syslog centralisé :
> 
> ```bash
> # Installer rsyslog si nécessaire
> apt install rsyslog
> 
> # Configurer l'envoi vers un serveur distant
> echo "*.* @@syslog-server:514" >> /etc/rsyslog.conf
> systemctl restart rsyslog
> ```

### 🛠️ Commandes de dépannage avancées

```bash
# Réinitialiser complètement les services Proxmox (en dernier recours)
systemctl stop pve*
systemctl stop corosync
sleep 5
systemctl start corosync
systemctl start pve-cluster
systemctl start pvedaemon pveproxy pvestatd pve-firewall

# Vérifier l'intégrité de la base de configuration cluster
pvecm expected 1  # Forcer le quorum si nécessaire (DANGER en production !)
systemctl restart pve-cluster

# Recréer le pmxcfs en cas de corruption
systemctl stop pve-cluster
rm -rf /var/lib/pve-cluster/backup/*
systemctl start pve-cluster

# Vérifier la cohérence de la configuration
pvesh get /cluster/status
pvesh get /nodes/$(hostname)/status
```

### 📊 Dashboard de monitoring (exemple)

```bash
#!/bin/bash
# Dashboard simple de monitoring des services

clear
echo "╔════════════════════════════════════════════════════════╗"
echo "║        PROXMOX SERVICE MONITORING DASHBOARD           ║"
echo "║              $(date '+%Y-%m-%d %H:%M:%S')                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo

# Services
echo "📊 SERVICES STATUS:"
for service in pvedaemon pveproxy pvestatd pve-cluster corosync; do
    if systemctl is-active --quiet "$service"; then
        echo "  ✓ $service"
    else
        echo "  ✗ $service (FAILED)"
    fi
done
echo

# Load Average
echo "⚡ SYSTEM LOAD:"
uptime | awk -F'load average:' '{print "  " $2}'
echo

# Memory
echo "💾 MEMORY:"
free -h | awk 'NR==2{printf "  Used: %s / %s (%.0f%%)\n", $3, $2, $3*100/$2}'
echo

# Disk Usage
echo "💿 DISK USAGE:"
df -h | awk 'NR==1 || /\/$|\/var/' | tail -n +2 | \
while read line; do
    echo "  $line"
done
echo

# VM Status
echo "🖥️  RUNNING VMs:"
qm list | awk 'NR>1 && $3=="running" {print "  VM", $1, "-", $2}'
echo

# CT Status
echo "📦 RUNNING CTs:"
pct list | awk 'NR>1 && $2=="running" {print "  CT", $1, "-", $3}'
```

> [!example] Utilisation du dashboard
> 
> ```bash
> # Rendre le script exécutable
> chmod +x /usr/local/bin/pve-dashboard.sh
> 
> # Lancer le dashboard
> /usr/local/bin/pve-dashboard.sh
> 
> # Ou avec rafraîchissement automatique
> watch -n 5 /usr/local/bin/pve-dashboard.sh
> ```

### ⚠️ Pièges courants

|Problème|Symptôme|Solution|
|---|---|---|
|Service actif mais non fonctionnel|`systemctl status` OK mais service inaccessible|Vérifier les logs avec `journalctl`, tester les ports avec `ss -tlnp`|
|Redémarrage en boucle|Service démarre puis s'arrête immédiatement|Analyser avec `journalctl -xe`, vérifier les dépendances|
|Cluster non quorate|Impossible d'accéder à la configuration|Vérifier corosync, forcer le quorum si nécessaire (attention !)|
|Interface web lente|Temps de réponse élevé|Vérifier la charge CPU/RAM, redémarrer pveproxy, analyser les logs|
|Perte de configuration|Fichiers dans /etc/pve vides|pmxcfs non monté, redémarrer pve-cluster|

### 🎯 Checklist de maintenance des services

**Quotidiennement :**

- [ ] Vérifier l'état des services critiques (`systemctl status pve*`)
- [ ] Consulter les logs pour détecter des erreurs (`journalctl -p err`)
- [ ] Vérifier l'accès à l'interface web

**Hebdomadairement :**

- [ ] Analyser les performances des services
- [ ] Vérifier les certificats SSL (expiration)
- [ ] Tester la communication cluster (si applicable)
- [ ] Nettoyer les anciens logs

**Mensuellement :**

- [ ] Audit complet des services avec script de monitoring
- [ ] Vérification de la configuration des services
- [ ] Test de reprise après panne (sur environnement de test)
- [ ] Documentation des incidents et résolutions

> [!tip] Bonnes pratiques
> 
> - Configurez des alertes automatiques pour les services critiques
> - Maintenez un journal de bord des interventions
> - Testez régulièrement les procédures de récupération
> - Documentez toute modification de configuration
> - Utilisez un système de monitoring externe (Zabbix, Prometheus, etc.)

---

## 🎓 Résumé des tâches de maintenance essentielles

### 🔄 Cycle de maintenance recommandé

|Fréquence|Tâches|Temps estimé|
|---|---|---|
|**Quotidien**|Vérification services, logs, espace disque|10-15 min|
|**Hebdomadaire**|Nettoyage logs, vérification backups, analyse stockage|30-45 min|
|**Mensuel**|Nettoyage kernels, audit complet, tests de restauration|1-2h|
|**Trimestriel**|Revue architecture, optimisation, documentation|2-4h|

### 🔑 Points clés à retenir

1. **Nettoyage des kernels** : Conservez toujours au minimum le kernel actuel + le précédent
2. **Stockage** : Surveillez particulièrement les attributs SMART et lancez des scrubs ZFS réguliers
3. **Espace disque** : Maintenez toujours au moins 20% d'espace libre sur les partitions critiques
4. **Services** : Un service défaillant peut avoir un impact en cascade, intervenez rapidement

### 🚨 Signaux d'alerte à surveiller

- 🔴 **Critique** : Service pve-cluster en erreur, /boot à 95%, thin pool à 95%
- 🟠 **Important** : Espace disque > 85%, services redémarrant régulièrement, erreurs SMART
- 🟡 **Attention** : Backups anciens non nettoyés, snapshots nombreux, logs volumineux

> [!info] Automatisation recommandée Pour une maintenance optimale, automatisez au maximum :
> 
> - Scripts de vérification quotidienne avec alertes email
> - Nettoyage automatique des logs (logrotate)
> - Monitoring des services avec redémarrage automatique si nécessaire
> - Rapports hebdomadaires d'état du système

La maintenance préventive est la clé d'une infrastructure Proxmox stable et performante. En suivant ces recommandations, vous éviterez la majorité des problèmes avant qu'ils ne deviennent critiques.Vérification de l'espace disponible sur /boot

```bash
# Vérifier l'espace disque utilisé sur /boot
df -h /boot

# Afficher la taille des fichiers dans /boot
du -sh /boot/*

# Lister tous les kernels installés
dpkg --list | grep -E 'linux-image|pve-kernel'
```

### 🔍 Identifier le kernel actuel et les anciens kernels

```bash
# Afficher le kernel en cours d'utilisation
uname -r

# Lister tous les kernels PVE installés avec leur version
dpkg -l | grep pve-kernel | grep -v $(uname -r)

# Exemple de sortie :
# ii  pve-kernel-6.2.16-3-pve    6.2.16-3    amd64
# ii  pve-kernel-6.5.11-7-pve    6.5.11-7    amd64
# (Le kernel actuel n'apparaît pas car filtré)
```

### 🗑️ Suppression des anciens kernels

#### Méthode 1 : Suppression manuelle sélective

```bash
# Supprimer un kernel spécifique (remplacer X.X.XX-X par la version)
apt remove pve-kernel-X.X.XX-X-pve

# Exemple concret
apt remove pve-kernel-6.2.16-3-pve

# Supprimer également les headers associés
apt remove pve-headers-X.X.XX-X-pve
```

#### Méthode 2 : Suppression automatique des anciens kernels

```bash
# Utiliser pvekclean pour nettoyer automatiquement
# (conserve le kernel actuel + le précédent par sécurité)
pvekclean

# Pour une suppression plus agressive (ne garde que le kernel actuel)
apt autoremove --purge
```

#### Méthode 3 : Script de nettoyage intelligent

```bash
#!/bin/bash
# Script de nettoyage des anciens kernels Proxmox

# Récupérer le kernel actuel
CURRENT_KERNEL=$(uname -r)

echo "Kernel actuel : $CURRENT_KERNEL"
echo "Kernels installés :"

# Lister tous les kernels sauf l'actuel
dpkg -l | grep pve-kernel | awk '{print $2}' | grep -v "$CURRENT_KERNEL"

# Demander confirmation
read -p "Voulez-vous supprimer les anciens kernels ? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Supprimer tous les anciens kernels
    apt remove --purge $(dpkg -l | grep pve-kernel | awk '{print $2}' | grep -v "$CURRENT_KERNEL")
    apt autoremove --purge
    update-grub
    echo "Nettoyage terminé !"
fi
```

### 🔄 Mise à jour de GRUB

```bash
# Après suppression, mettre à jour le menu de démarrage
update-grub

# Vérifier les entrées GRUB
grep menuentry /boot/grub/grub.cfg
```

> [!tip] Astuce Configurez une tâche cron pour vérifier automatiquement l'espace disque sur `/boot` et recevoir une alerte si l'utilisation dépasse 80%.

### ⚠️ Pièges courants

|Problème|Cause|Solution|
|---|---|---|
|Impossible de supprimer un kernel|Le kernel est protégé ou en cours d'utilisation|Redémarrer sur un autre kernel via GRUB|
|/boot plein, impossible de mettre à jour|Trop de kernels accumulés|Supprimer manuellement les fichiers dans `/boot` puis nettoyer avec `apt`|
|Erreur lors de `update-grub`|Configuration GRUB corrompue|Vérifier `/etc/default/grub` et régénérer avec `grub-mkconfig`|

---

## Vérification du stockage

### 🎯 Pourquoi vérifier le stockage ?

Le stockage est le cœur de Proxmox. Une défaillance ou une dégradation du stockage peut entraîner :

- Perte de données de VM/CT
- Corruption de systèmes de fichiers
- Arrêt brutal de machines virtuelles
- Impossibilité de créer de nouvelles VM

### 📊 Vérification de l'état général du stockage

```bash
# Lister tous les storages configurés dans Proxmox
pvesm status

# Exemple de sortie :
# Name             Type     Status           Total            Used       Available        %
# local            dir      active      49506304        10485760        36463488    21.19%
# local-lvm        lvmthin  active     209715200        52428800       157286400    25.00%

# Afficher les détails d'un storage spécifique
pvesm list local

# Vérifier l'espace disque de tous les points de montage
df -h

# Afficher l'utilisation avec inodes (important pour les systèmes avec beaucoup de petits fichiers)
df -i
```

### 🔍 Vérification des systèmes de fichiers

#### Pour ext4

```bash
# Vérifier l'état d'un système de fichiers ext4 (nécessite démontage)
# ATTENTION : Ne pas exécuter sur un FS monté !
umount /dev/sdX1
fsck.ext4 -f -v /dev/sdX1

# Vérifier sans réparer (lecture seule, peut être fait monté)
fsck.ext4 -n /dev/sdX1

# Afficher les informations du système de fichiers
tune2fs -l /dev/sdX1 | grep -i "last checked\|mount count\|maximum mount"
```

#### Pour ZFS

```bash
# Vérifier l'état général du pool ZFS
zpool status

# Exemple de sortie saine :
#   pool: rpool
#  state: ONLINE
#   scan: scrub repaired 0B in 0h0m with 0 errors

# Lancer un scrub (vérification d'intégrité)
zpool scrub rpool

# Vérifier la progression du scrub
zpool status -v

# Afficher les statistiques d'I/O
zpool iostat -v rpool 5

# Vérifier la santé des datasets
zfs list -o name,used,avail,refer,mountpoint
```

#### Pour LVM

```bash
# Afficher tous les volumes physiques
pvdisplay

# Vérifier l'état des volumes logiques
lvdisplay

# Afficher les groupes de volumes
vgdisplay

# Vérifier l'intégrité d'un thin pool (utilisé par local-lvm)
lvs -a -o+seg_monitor

# Afficher l'utilisation détaillée du thin pool
lvs -o+lv_metadata_size,metadata_percent,data_percent
```

### 💾 Vérification SMART des disques

```bash
# Installer smartmontools si nécessaire
apt install smartmontools

# Vérifier la santé globale d'un disque
smartctl -H /dev/sda

# Exemple de sortie saine :
# SMART overall-health self-assessment test result: PASSED

# Afficher toutes les informations SMART
smartctl -a /dev/sda

# Vérifier les attributs critiques
smartctl -A /dev/sda | grep -E "Reallocated|Current_Pending|Offline_Uncorrectable|Temperature"

# Lancer un test court (environ 2 minutes)
smartctl -t short /dev/sda

# Vérifier les résultats du test
smartctl -l selftest /dev/sda

# Lister tous les disques disponibles
smartctl --scan
```

> [!warning] Signaux d'alerte SMART Surveillez particulièrement ces attributs :
> 
> - **Reallocated_Sector_Ct** : Secteurs réalloués (devrait être 0)
> - **Current_Pending_Sector** : Secteurs en attente de réallocation
> - **Offline_Uncorrectable** : Secteurs incorrigeables
> - **Temperature_Celsius** : Température (ne devrait pas dépasser 55-60°C en charge)

### 🔧 Vérification de l'intégrité des backups

```bash
# Lister tous les backups disponibles
vzdump list

# Vérifier l'intégrité d'une archive de backup
vzdump --verify /var/lib/vz/dump/vzdump-qemu-100-*.vma.zst

# Pour les backups sur PBS (Proxmox Backup Server)
proxmox-backup-client verify vzdump/vm/100/
```

### 📈 Surveillance de la performance du stockage

```bash
# Tester la vitesse de lecture/écriture d'un disque
dd if=/dev/zero of=/tmp/testfile bs=1G count=1 oflag=direct
dd if=/tmp/testfile of=/dev/null bs=1G count=1 iflag=direct

# Utiliser fio pour des tests plus avancés
apt install fio
fio --name=random-write --ioengine=libaio --rw=randwrite --bs=4k --numjobs=1 --size=1g --iodepth=1 --runtime=60 --time_based

# Surveiller les I/O en temps réel
iostat -x 2
# ou
iotop -o
```

> [!tip] Automatisation de la surveillance
> 
> ```bash
> # Script de surveillance quotidienne du stockage
> #!/bin/bash
> LOG="/var/log/storage-check.log"
> 
> echo "=== Storage Check - $(date) ===" >> $LOG
> pvesm status >> $LOG
> zpool status >> $LOG
> 
> # Vérifier les disques SMART
> for disk in /dev/sd[a-z]; do
>   if [ -e "$disk" ]; then
>     echo "Checking $disk..." >> $LOG
>     smartctl -H $disk >> $LOG 2>&1
>   fi
> done
> ```

### ⚠️ Pièges courants

|Problème|Symptôme|Solution|
|---|---|---|
|Storage apparaît "inactive"|Erreur dans `pvesm status`|Vérifier les points de montage et permissions|
|Thin pool plein à 100%|Impossible de créer des snapshots|Étendre le thin pool ou supprimer des snapshots|
|ZFS scrub échoue|Erreurs de checksum détectées|Vérifier la santé des disques avec SMART, remplacer si nécessaire|
|Inodes épuisés|`df -h` montre de l'espace mais création impossible|Nettoyer les petits fichiers ou augmenter le nombre d'inodes|

---

## Gestion de l'espace disque

### 🎯 Pourquoi gérer l'espace disque ?

Un manque d'espace disque peut provoquer :

- Arrêt des VM/CT (impossibilité d'écrire)
- Impossibilité de créer des backups
- Échec des mises à jour système
- Corruption de bases de données

> [!info] Seuils recommandés
> 
> - **Alerte** : 80% d'utilisation
> - **Critique** : 90% d'utilisation
> - **Action immédiate** : 95% d'utilisation

### 📊 Analyse de l'utilisation de l'espace

```bash
# Vue d'ensemble de tous les systèmes de fichiers
df -h

# Afficher l'utilisation avec des barres visuelles
df -h | awk 'NR==1 || /\/$|\/boot|\/var/ {print $0}'

# Trouver les répertoires les plus volumineux dans /var
du -sh /var/* | sort -hr | head -10

# Analyser récursivement un répertoire
du -h --max-depth=2 /var/lib/vz | sort -hr | head -20

# Utiliser ncdu pour une analyse interactive (plus pratique)
apt install ncdu
ncdu /var/lib/vz
```

### 🗑️ Nettoyage des fichiers temporaires et logs

```bash
# Nettoyer le cache APT
apt clean
apt autoclean

# Supprimer les paquets orphelins
apt autoremove --purge

# Nettoyer les logs anciens (garder 7 jours)
journalctl --vacuum-time=7d

# Limiter la taille totale des logs à 500M
journalctl --vacuum-size=500M

# Vérifier la taille des logs
du -sh /var/log/journal/

# Nettoyer les anciens logs rotatés
find /var/log -type f -name "*.gz" -mtime +30 -delete
find /var/log -type f -name "*.old" -mtime +30 -delete

# Nettoyer le répertoire tmp
find /tmp -type f -atime +7 -delete
```

### 📦 Gestion des backups

```bash
# Lister tous les backups avec leur taille
ls -lh /var/lib/vz/dump/

# Trouver les backups de plus de 30 jours
find /var/lib/vz/dump/ -name "*.vma*" -mtime +30

# Supprimer les anciens backups (ATTENTION : vérifier avant !)
find /var/lib/vz/dump/ -name "*.vma*" -mtime +30 -exec rm {} \;

# Configurer la rétention automatique dans Proxmox
# Via l'interface web : Datacenter > Backup > Edit
# Ou en CLI :
vzdump --mode snapshot --storage local --maxfiles 3 --all 1

# Vérifier l'espace utilisé par les backups
du -sh /var/lib/vz/dump/
```

> [!tip] Politique de rétention recommandée
> 
> - **Backups quotidiens** : Conserver 7 jours
> - **Backups hebdomadaires** : Conserver 4 semaines
> - **Backups mensuels** : Conserver 6-12 mois

### 💿 Nettoyage des images ISO et templates

```bash
# Lister les ISOs disponibles
ls -lh /var/lib/vz/template/iso/

# Supprimer une ISO inutilisée
rm /var/lib/vz/template/iso/ubuntu-22.04.iso

# Via l'interface CLI Proxmox
pvesm list local --content iso

# Nettoyer les templates de conteneurs anciens
ls -lh /var/lib/vz/template/cache/
rm /var/lib/vz/template/cache/ubuntu-22.04-standard_*.tar.zst
```

### 📸 Gestion des snapshots

Les snapshots peuvent rapidement consommer beaucoup d'espace, surtout s'ils sont oubliés.

```bash
# Lister tous les snapshots de toutes les VM
qm listsnapshot <vmid>

# Exemple pour la VM 100
qm listsnapshot 100

# Supprimer un snapshot spécifique
qm delsnapshot <vmid> <snapshot_name>

# Pour les conteneurs LXC
pct listsnapshot <ctid>
pct delsnapshot <ctid> <snapshot_name>

# Script pour lister tous les snapshots du serveur
#!/bin/bash
echo "=== VM Snapshots ==="
for vm in $(qm list | awk 'NR>1 {print $1}'); do
  echo "VM $vm:"
  qm listsnapshot $vm
done

echo "=== CT Snapshots ==="
for ct in $(pct list | awk 'NR>1 {print $1}'); do
  echo "CT $ct:"
  pct listsnapshot $ct
done
```

#### Pour ZFS

```bash
# Lister tous les snapshots ZFS
zfs list -t snapshot

# Afficher l'espace utilisé par les snapshots
zfs list -o space -t snapshot

# Supprimer un snapshot ZFS
zfs destroy rpool/data@snapshot_name

# Supprimer tous les snapshots anciens (exemple : plus de 7 jours)
zfs list -H -o name -t snapshot | grep "$(date -d '7 days ago' +%Y-%m-%d)" | xargs -n 1 zfs destroy
```

#### Pour LVM

```bash
# Lister les snapshots LVM
lvs --noheadings -o lv_name,origin,snap_percent | grep -v "^  $"

# Supprimer un snapshot LVM
lvremove /dev/vg/snapshot_name

# Attention : Les snapshots LVM qui se remplissent à 100% deviennent invalides !
```

### 🔍 Identifier les gros fichiers et répertoires

```bash
# Trouver les 20 plus gros fichiers du système
find / -type f -exec du -h {} + 2>/dev/null | sort -rh | head -20

# Fichiers de plus de 1GB
find /var -type f -size +1G -exec ls -lh {} \;

# Répertoires les plus volumineux
du -h / 2>/dev/null | grep '^[0-9\.]*G' | sort -rn

# Analyse spécifique de /var/lib/vz (VM et CT)
du -sh /var/lib/vz/images/*
du -sh /var/lib/vz/private/*
```

### 🎛️ Extension de l'espace disque

#### Étendre une partition LVM

```bash
# Vérifier l'espace disponible dans le VG
vgdisplay

# Étendre un LV (exemple : ajouter 50GB)
lvextend -L +50G /dev/pve/data

# Ou utiliser tout l'espace libre
lvextend -l +100%FREE /dev/pve/data

# Redimensionner le système de fichiers
resize2fs /dev/pve/root
# ou pour XFS
xfs_growfs /dev/pve/root
```

#### Étendre un pool ZFS

```bash
# Ajouter un disque au pool
zpool add rpool /dev/sdX

# Remplacer un disque (pour augmenter la taille)
zpool replace rpool /dev/sdX /dev/sdY

# Le pool s'étend automatiquement après remplacement de tous les disques
```

### 📋 Script de monitoring automatique

```bash
#!/bin/bash
# Script de surveillance de l'espace disque avec alertes

THRESHOLD=80
EMAIL="admin@domain.com"
HOSTNAME=$(hostname)

# Vérifier chaque partition
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output; do
  usage=$(echo $output | awk '{ print $1}' | cut -d'%' -f1)
  partition=$(echo $output | awk '{ print $2 }')
  
  if [ $usage -ge $THRESHOLD ]; then
    echo "ALERTE : Partition $partition sur $HOSTNAME est à ${usage}% !" | \
    mail -s "Espace disque critique sur $HOSTNAME" $EMAIL
  fi
done

# Vérifier les thin pools LVM
lvs --noheadings -o lv_name,data_percent,metadata_percent | while read lv data meta; do
  data_int=$(echo $data | cut -d'.' -f1)
  if [ "$data_int" -ge "$THRESHOLD" ]; then
    echo "ALERTE : Thin pool $lv est à ${data}% de capacité !" | \
    mail -s "Thin pool critique sur $HOSTNAME" $EMAIL
  fi
done
```

> [!tip] Bonnes pratiques
> 
> - Configurez des alertes automatiques à 80% et 90%
> - Planifiez des revues mensuelles de l'espace disque
> - Documentez où sont stockées les données volumineuses
> - Établissez une politique de rétention claire pour les backups
> - Utilisez un stockage externe pour les archives long terme

### ⚠️ Pièges courants

|Problème|Cause|Solution|
|---|---|---|
|Snapshot LVM à 100%|Trop de modifications sur le volume source|Merger ou supprimer immédiatement le snapshot|
|`/boot` plein mais `df` montre de l'espace|Anciens kernels non supprimés|Nettoyer manuellement `/boot` puis `apt autoremove`|
|Impossible de supprimer des fichiers|Fichiers ouverts par des processus|Identifier avec `lsof` et arrêter le processus|
|ZFS dataset plein mais pas de fichiers|Snapshots consommant l'espace|Lister et supprimer les snapshots avec `zfs list -t snapshot`|

---

## Vérification de l'état des services

### 🎯 Pourquoi vérifier les services ?

Les services Proxmox assurent le fonctionnement de :

- L'interface web (pveproxy)
- Le clustering (corosync, pve-cluster)
- La gestion des VM (qemu, kvm)
- La gestion des conteneurs (pve-container)
- Le stockage (zfs, ceph si utilisé)

Un service défaillant peut paralyser tout ou partie de votre infrastructure.

### 📊 Vue d'ensemble des services critiques

Les services essentiels de Proxmox :

|Service|Rôle|Impact si arrêté|
|---|---|---|
|`pve-cluster`|Gestion du cluster et configuration partagée|Perte d'accès à la configuration|
|`pvedaemon`|API Proxmox|Interface web inaccessible|
|`pveproxy`|Serveur web (interface)|Impossible de se connecter à l'interface|
|`pvestatd`|Collecte de statistiques|Pas de graphiques de monitoring|
|`pve-firewall`|Pare-feu Proxmox|Règles de firewall non appliquées|
|`corosync`|Communication cluster|Perte de quorum en cluster|
|`qemu-server`|Gestion des VM KVM|Impossible de démarrer/arrêter des VM|
|`lxc`|Gestion des conteneurs|Impossible de gérer les CT|

### 🔍 Vérification de l'état des services

```bash
# Vérifier l'état de tous les services Proxmox
systemctl status pve*

# Vérifier un service spécifique
systemctl status pvedaemon

# Vérifier si un service est actif (retourne 0 si actif)
systemctl is-active pveproxy

# Vérifier si un service est enabled au démarrage
systemctl is-enabled pvedaemon

# Lister tous les services en cours d'exécution
systemctl list-units --type=service --state=running | grep pve

# Afficher les services en échec
systemctl list-units --type=service --state=failed
```

### 🔄 Gestion des services

```bash
# Démarrer un service
systemctl start pvedaemon

# Arrêter un service
systemctl stop pvedaemon

# Redémarrer un service
systemctl restart pvedaemon

# Recharger la configuration sans redémarrer
systemctl reload pvedaemon

# Activer un service au démarrage
systemctl enable pvedaemon

# Désactiver un service au démarrage
systemctl disable pvedaemon

# Redémarrer tous les services Proxmox
systemctl restart pve*
```

> [!warning] Ordre de redémarrage en cluster En environnement cluster, respectez cet ordre :
> 
> 1. `pve-cluster`
> 2. `corosync`
> 3. Autres services PVE

### 📋 Vérifications spécifiques par service

#### Service web (pveproxy)

```bash
# Vérifier l'état du service web
systemctl status pveproxy

# Tester l'accès à l'API
curl -k https://localhost:8006/api2/json

# Vérifier les ports écoutés
ss -tlnp | grep pveproxy

# Exemple de sortie saine :
# LISTEN 0 128 *:8006 *:* users:(("pveproxy",pid=1234))

# Vérifier les logs en cas de problème
journalctl -u pveproxy -n 50

# Tester l'accès depuis l'extérieur
curl -k https://IP_PROXMOX:8006
```

#### Service cluster (pve-cluster)

```bash
# Vérifier l'état du cluster
pvecm status

# Vérifier la synchronisation du pmxcfs (filesystem cluster)
systemctl status pve-cluster

# Vérifier le montage du filesystem cluster
df -h /etc/pve

# Afficher le contenu de la base de configuration cluster
cat /etc/pve/corosync.conf

# Vérifier les logs du cluster
journalctl -u pve-cluster -f
```

#### Service Corosync (clustering)

```bash
# Vérifier l'état de corosync
systemctl status corosync

# Vérifier le quorum (en mode cluster)
corosync-quorumtool

# Exemple de sortie saine :
# Quorum information
# ------------------
# Date:             Wed Dec 24 10:00:00 2025
# Quorum provider:  corosync_votequorum
# Nodes:            3
# Expected votes:   3
# Highest expected: 3
# Total votes:      3
# Quorum:           2  
# Flags:            Quorate

# Vérifier la communication entre les nœuds
corosync-cmapctl | grep members

# Tester la connectivité réseau du cluster
pvecm nodes
```

#### Service QEMU/KVM (machines virtuelles)

```bash
# Vérifier que KVM est bien chargé
lsmod | grep kvm

# Exemple de sortie :
# kvm_intel        331776  0
# kvm              1089536  1 kvm_intel

# Vérifier les VM en cours d'exécution
qm list

# Vérifier l'état d'une VM spécifique
qm status 100

# Vérifier les processus QEMU
ps aux | grep qemu

# Vérifier les performances des VM
qm monitor 100
# Puis taper : info status
```

#### Service LXC (conteneurs)

```bash
# Vérifier l'état du service LXC
systemctl status lxc

# Lister tous les conteneurs
pct list

# Vérifier l'état d'un conteneur spécifique
pct status 100

# Vérifier les cgroups (contrôle des ressources)
cat /sys/fs/cgroup/pve/lxc/*/tasks
```

### 🔧 Diagnostic et résolution de problèmes

#### Service ne démarre pas

```bash
# Vérifier les logs détaillés
journalctl -xe -u pvedaemon

# Vérifier la configuration du service
systemctl cat pvedaemon

# Tester le service en mode debug
/usr/bin/pvedaemon start --debug

# Vérifier les dépendances du service
systemctl list-dependencies pvedaemon
```

#### Service se coupe régulièrement

```bash
# Surveiller le service en temps réel
watch -n 1 systemctl is-active pvedaemon

# Vérifier les crash dumps
coredumpctl list

# Analyser les ressources système lors du crash
# (configurer auparavant avec 'apt install sysstat')
sar -u -f /var/log/sysstat/sa*

# Vérifier la mémoire disponible
free -h
vmstat 1 5
```

#### Interface web inaccessible

```bash
# Séquence de diagnostic complète
echo "1. Vérification du service pveproxy..."
systemctl status pveproxy

echo "2. Vérification du port 8006..."
ss -tlnp | grep 8006

echo "3. Test de l'API locale..."
curl -k https://localhost:8006/api2/json

echo "4. Vérification du pare-feu..."
iptables -L -n | grep 8006

echo "5. Logs du service..."
journalctl -u pveproxy -n 20

# Redémarrage complet des services web si nécessaire
systemctl restart pvedaemon pveproxy pvestatd
```

### 📊