# 

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

La maintenance régulière de Proxmox VE est essentielle pour garantir la sécurité, la stabilité et les performances de votre infrastructure de virtualisation. Les mises à jour permettent de corriger les vulnérabilités, d'ajouter de nouvelles fonctionnalités et d'améliorer la compatibilité matérielle.

> [!info] Pourquoi mettre à jour ?
> 
> - **Sécurité** : Correction des failles de sécurité critiques
> - **Stabilité** : Résolution de bugs et amélioration de la fiabilité
> - **Performance** : Optimisations du kernel et des composants
> - **Fonctionnalités** : Accès aux nouvelles capacités de Proxmox

---

## 1. Dépôts APT

Proxmox VE utilise le système de paquets Debian (APT) pour gérer les mises à jour. Comprendre les différents dépôts disponibles est crucial pour choisir la stratégie de mise à jour adaptée à votre environnement.

### Dépôt Enterprise

Le dépôt Enterprise est destiné aux environnements de production avec souscription Proxmox.

> [!info] Caractéristiques
> 
> - **Stabilité maximale** : Paquets testés rigoureusement
> - **Support officiel** : Accès au support Proxmox
> - **Nécessite une souscription** : Clé d'abonnement requise
> - **Recommandé pour la production**

**Configuration par défaut** :

```bash
# Fichier : /etc/apt/sources.list.d/pve-enterprise.list
deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
```

> [!warning] Attention Sans souscription valide, ce dépôt génère des erreurs lors de `apt update`. Il est préférable de le désactiver si vous n'avez pas de souscription.

### Dépôt No-Subscription

Le dépôt No-Subscription est gratuit et adapté aux environnements de test ou non-critiques.

> [!info] Caractéristiques
> 
> - **Gratuit** : Aucune souscription nécessaire
> - **Stable** : Testé mais moins rigoureusement que Enterprise
> - **Mises à jour régulières** : Accès aux correctifs de sécurité
> - **Recommandé pour les labs et homelab**

**Configuration** :

```bash
# Fichier : /etc/apt/sources.list.d/pve-no-subscription.list
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
```

> [!tip] Astuce C'est le dépôt le plus utilisé par la communauté pour des installations non-production.

### Dépôt Test

Le dépôt Test contient les dernières versions en cours de développement.

> [!warning] Utilisation déconseillée en production Ce dépôt est instable et destiné uniquement aux tests et au développement. Les paquets peuvent contenir des bugs critiques.

**Configuration** :

```bash
# Fichier : /etc/apt/sources.list.d/pve-test.list
deb http://download.proxmox.com/debian/pve bookworm pvetest
```

> [!info] Cas d'usage
> 
> - Tester de nouvelles fonctionnalités avant déploiement
> - Environnement de développement isolé
> - Contribuer au projet en remontant des bugs

### Configuration des dépôts

#### Désactivation du dépôt Enterprise

```bash
# Méthode 1 : Renommer le fichier
mv /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak

# Méthode 2 : Commenter la ligne
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
```

#### Activation du dépôt No-Subscription

```bash
# Créer le fichier de configuration
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list

# Mettre à jour la liste des paquets
apt update
```

#### Vérification des dépôts actifs

```bash
# Lister les dépôts configurés
cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list | grep -v "^#" | grep -v "^$"

# Vérifier les dépôts Proxmox spécifiquement
ls -la /etc/apt/sources.list.d/pve-*.list
```

> [!tip] Bonnes pratiques
> 
> - **Production** : Utilisez le dépôt Enterprise avec une souscription valide
> - **Test/Lab** : Utilisez le dépôt No-Subscription
> - **N'activez jamais** plusieurs dépôts Proxmox simultanément (risque de conflits)
> - **Documentez** quel dépôt est utilisé sur chaque nœud

#### Comparaison des dépôts

|Dépôt|Gratuit|Stabilité|Support|Usage recommandé|
|---|---|---|---|---|
|**Enterprise**|❌ Non|⭐⭐⭐⭐⭐|✅ Oui|Production critique|
|**No-Subscription**|✅ Oui|⭐⭐⭐⭐|❌ Communauté|Lab, test, production non-critique|
|**Test**|✅ Oui|⭐⭐|❌ Non|Développement uniquement|

---

## 2. Mise à jour via interface web

L'interface web de Proxmox offre une méthode intuitive pour gérer les mises à jour.

### Accès et vérification

**Navigation dans l'interface** :

1. Connectez-vous à l'interface web : `https://votre-ip:8006`
2. Sélectionnez votre nœud dans l'arborescence
3. Cliquez sur **Updates** dans le menu de gauche

> [!info] Vue d'ensemble L'interface affiche :
> 
> - Liste des paquets disponibles pour mise à jour
> - Type de mise à jour (sécurité, bug fix, nouvelle version)
> - Taille du téléchargement
> - Statut des dépôts configurés

### Processus de mise à jour

#### Étape 1 : Rafraîchir la liste

```
Cliquez sur le bouton "Refresh" pour actualiser la liste des paquets disponibles
```

> [!tip] Automatisation La liste se rafraîchit automatiquement toutes les 24 heures par défaut.

#### Étape 2 : Examiner les mises à jour

**Vérifiez les éléments suivants** :

- Présence de mises à jour du kernel (`pve-kernel-*`)
- Mises à jour des composants critiques (`proxmox-ve`, `pve-manager`)
- Notes de version et changelog

> [!warning] Pièges courants
> 
> - **Kernel updates** : Nécessitent un redémarrage du nœud
> - **Service updates** : Peuvent nécessiter un redémarrage des services (qemu, lxc)
> - Vérifiez toujours les notes de version pour les breaking changes

#### Étape 3 : Lancer la mise à jour

```
Cliquez sur "Upgrade" pour ouvrir la console de mise à jour
```

L'interface ouvre une fenêtre de terminal intégrée qui exécute :

```bash
apt update && apt dist-upgrade
```

> [!example] Exemple de sortie
> 
> ```
> Reading package lists... Done
> Building dependency tree... Done
> Reading state information... Done
> Calculating upgrade... Done
> The following packages will be upgraded:
>   pve-manager proxmox-ve pve-kernel-6.5
> 3 upgraded, 0 newly installed, 0 to remove
> ```

#### Étape 4 : Confirmer et surveiller

- Confirmez l'installation quand demandé (tapez `Y` puis Entrée)
- Surveillez la progression dans la console
- Lisez attentivement les messages d'avertissement

> [!warning] Ne fermez pas la fenêtre Laisser la mise à jour se terminer complètement. Fermer la fenêtre n'arrête pas le processus mais vous perdez la visibilité.

#### Étape 5 : Actions post-mise à jour

**Si le kernel a été mis à jour** :

```bash
# Vérifier la version actuelle
uname -r

# Vérifier les kernels disponibles
pvekernels list

# Planifier un redémarrage
shutdown -r +5 "Redémarrage pour nouveau kernel dans 5 minutes"
```

**Si des services ont été mis à jour** :

```bash
# Vérifier les services à redémarrer
needrestart -l

# Redémarrer les services nécessaires
systemctl restart pvedaemon pveproxy pvestatd
```

> [!tip] Bonnes pratiques interface web
> 
> - **Planifiez** les mises à jour pendant les fenêtres de maintenance
> - **Testez** d'abord sur un nœud non-critique
> - **Sauvegardez** les VMs critiques avant mise à jour majeure
> - **Documentez** chaque mise à jour effectuée

---

## 3. Mise à jour en ligne de commande

La ligne de commande offre plus de contrôle et permet l'automatisation des mises à jour.

### Commandes essentielles

#### Mise à jour standard

```bash
# 1. Mettre à jour la liste des paquets
apt update

# 2. Voir les paquets à mettre à jour
apt list --upgradable

# 3. Effectuer la mise à jour
apt dist-upgrade -y

# Ou en une seule commande
apt update && apt dist-upgrade -y
```

> [!info] Différence apt upgrade vs dist-upgrade
> 
> - `apt upgrade` : Met à jour les paquets sans ajouter/supprimer de dépendances
> - `apt dist-upgrade` : Met à jour intelligemment, peut ajouter/supprimer des paquets si nécessaire
> - **Utilisez toujours `dist-upgrade`** pour Proxmox

#### Vérifications préalables

```bash
# Vérifier l'espace disque disponible
df -h /

# Vérifier les services en cours
systemctl status pvedaemon pveproxy pvestatd

# Vérifier les VMs/Conteneurs en cours d'exécution
qm list
pct list

# Vérifier les dépôts configurés
cat /etc/apt/sources.list.d/pve-*.list | grep -v "^#"
```

> [!warning] Espace disque requis Assurez-vous d'avoir au moins **2 GB d'espace libre** sur la partition root avant toute mise à jour majeure.

#### Mise à jour avec journalisation

```bash
# Créer un répertoire pour les logs
mkdir -p /var/log/proxmox-updates

# Effectuer la mise à jour avec log complet
apt update && apt dist-upgrade -y 2>&1 | tee /var/log/proxmox-updates/update-$(date +%Y%m%d-%H%M%S).log

# Vérifier le code de retour
echo $?
# 0 = succès, autre = erreur
```

> [!tip] Astuce avancée Cette méthode permet de conserver un historique détaillé de toutes vos mises à jour pour audit ou dépannage.

#### Gestion des kernels

```bash
# Lister les kernels installés
dpkg --list | grep pve-kernel

# Afficher le kernel actif
uname -r

# Voir les kernels disponibles au boot
pvekernels list

# Supprimer un ancien kernel (libère de l'espace)
apt remove pve-kernel-6.2.16-15-pve
apt autoremove

# Définir le kernel par défaut
proxmox-boot-tool kernel pin 6.5.13-3-pve
```

> [!warning] Ne supprimez jamais le kernel actif ! Vérifiez toujours avec `uname -r` avant de supprimer un kernel.

#### Mises à jour de sécurité uniquement

```bash
# Installer unattended-upgrades
apt install unattended-upgrades

# Configurer pour les mises à jour de sécurité
cat > /etc/apt/apt.conf.d/50unattended-upgrades <<EOF
Unattended-Upgrade::Origins-Pattern {
    "origin=Debian,codename=\${distro_codename},label=Debian-Security";
    "origin=Proxmox";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::Mail "admin@example.com";
EOF

# Test en mode dry-run
unattended-upgrades --dry-run --debug
```

### Automatisation

#### Script de mise à jour automatique

```bash
#!/bin/bash
# /usr/local/bin/proxmox-auto-update.sh

# Configuration
LOG_DIR="/var/log/proxmox-updates"
LOG_FILE="$LOG_DIR/auto-update-$(date +%Y%m%d-%H%M%S).log"
EMAIL="admin@example.com"

# Créer le répertoire de logs
mkdir -p "$LOG_DIR"

# Fonction de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Début de la mise à jour
log "=== Début de la mise à jour automatique ==="

# Vérifier l'espace disque
SPACE=$(df / | awk 'NR==2 {print $4}')
if [ "$SPACE" -lt 2097152 ]; then
    log "ERREUR: Espace disque insuffisant ($SPACE KB disponible)"
    exit 1
fi

# Mettre à jour la liste des paquets
log "Mise à jour de la liste des paquets..."
apt update >> "$LOG_FILE" 2>&1

# Vérifier les paquets à mettre à jour
UPDATES=$(apt list --upgradable 2>/dev/null | grep -v "Listing" | wc -l)
log "Nombre de paquets à mettre à jour: $UPDATES"

if [ "$UPDATES" -eq 0 ]; then
    log "Système à jour, aucune action nécessaire"
    exit 0
fi

# Effectuer la mise à jour
log "Installation des mises à jour..."
DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y >> "$LOG_FILE" 2>&1

# Vérifier si un redémarrage est nécessaire
if [ -f /var/run/reboot-required ]; then
    log "ATTENTION: Redémarrage requis"
    # Envoyer une notification
    echo "Un redémarrage est nécessaire sur $(hostname)" | mail -s "Proxmox Update - Redémarrage requis" "$EMAIL"
fi

# Nettoyer les paquets obsolètes
log "Nettoyage des paquets obsolètes..."
apt autoremove -y >> "$LOG_FILE" 2>&1
apt autoclean >> "$LOG_FILE" 2>&1

log "=== Mise à jour terminée avec succès ==="

# Envoyer le rapport par email
mail -s "Proxmox Update Report - $(hostname)" "$EMAIL" < "$LOG_FILE"
```

**Rendre le script exécutable** :

```bash
chmod +x /usr/local/bin/proxmox-auto-update.sh
```

#### Planification avec Cron

```bash
# Éditer la crontab
crontab -e

# Mise à jour hebdomadaire le dimanche à 3h du matin
0 3 * * 0 /usr/local/bin/proxmox-auto-update.sh

# Mise à jour quotidienne des paquets de sécurité uniquement à 2h
0 2 * * * apt update && unattended-upgrades
```

> [!tip] Stratégies de planification
> 
> - **Production critique** : Mise à jour manuelle uniquement
> - **Production standard** : Hebdomadaire en maintenance window
> - **Test/Lab** : Quotidienne ou hebdomadaire automatique

#### Notifications par email

```bash
# Installer mailutils
apt install mailutils

# Configurer postfix (relais SMTP)
dpkg-reconfigure postfix

# Tester l'envoi
echo "Test de notification Proxmox" | mail -s "Test" admin@example.com

# Script de notification de mises à jour disponibles
cat > /usr/local/bin/check-updates.sh <<'EOF'
#!/bin/bash
apt update > /dev/null 2>&1
UPDATES=$(apt list --upgradable 2>/dev/null | grep -v "Listing" | wc -l)

if [ "$UPDATES" -gt 0 ]; then
    apt list --upgradable 2>/dev/null | mail -s "[$UPDATES] Mises à jour disponibles sur $(hostname)" admin@example.com
fi
EOF

chmod +x /usr/local/bin/check-updates.sh

# Planifier la vérification quotidienne
echo "0 8 * * * /usr/local/bin/check-updates.sh" | crontab -
```

> [!example] Exemple de configuration complète
> 
> ```bash
> # Vérification quotidienne à 8h
> 0 8 * * * /usr/local/bin/check-updates.sh
> 
> # Mise à jour auto des paquets de sécurité à 2h
> 0 2 * * * unattended-upgrades
> 
> # Mise à jour complète hebdomadaire (dimanche 3h)
> 0 3 * * 0 /usr/local/bin/proxmox-auto-update.sh
> ```

---

## 4. Mise à niveau de version majeure

La migration entre versions majeures de Proxmox (ex: 7.x vers 8.x) nécessite une préparation minutieuse.

### Préparation

#### Vérifications préalables

```bash
# Vérifier la version actuelle
pveversion

# Vérifier l'état du cluster (si applicable)
pvecm status

# Vérifier les versions des VMs/Conteneurs
qm list
pct list

# Vérifier les dépôts configurés
cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list

# Vérifier l'espace disque
df -h

# Vérifier les services critiques
systemctl status pvedaemon pveproxy corosync
```

> [!warning] Prérequis critiques
> 
> - Système entièrement à jour sur la version actuelle
> - Sauvegardes complètes de toutes les VMs critiques
> - Sauvegardes de la configuration Proxmox
> - Au moins 5 GB d'espace libre sur `/`
> - Fenêtre de maintenance planifiée

#### Sauvegardes essentielles

```bash
# Créer un répertoire de sauvegarde
mkdir -p /root/proxmox-backup-$(date +%Y%m%d)
cd /root/proxmox-backup-$(date +%Y%m%d)

# Sauvegarder la configuration réseau
cp -r /etc/network /root/proxmox-backup-$(date +%Y%m%d)/network

# Sauvegarder la configuration Proxmox
cp -r /etc/pve /root/proxmox-backup-$(date +%Y%m%d)/pve

# Sauvegarder les configurations APT
cp -r /etc/apt /root/proxmox-backup-$(date +%Y%m%d)/apt

# Sauvegarder la liste des paquets installés
dpkg --get-selections > /root/proxmox-backup-$(date +%Y%m%d)/packages.list

# Sauvegarder la configuration du cluster (si applicable)
pvecm status > /root/proxmox-backup-$(date +%Y%m%d)/cluster-status.txt

# Créer une archive
tar czf /root/proxmox-backup-$(date +%Y%m%d).tar.gz /root/proxmox-backup-$(date +%Y%m%d)
```

> [!tip] Sauvegarde supplémentaire Copiez l'archive sur un serveur distant ou un support externe pour plus de sécurité.

#### Utilisation du Proxmox Cluster Upgrade Tool

Proxmox fournit un outil de vérification avant migration :

```bash
# Mettre à jour le système actuel
apt update && apt dist-upgrade

# Installer l'outil de vérification
apt install proxmox-upgrade-check

# Lancer la vérification
pve7to8 --full

# Examiner attentivement le rapport
```

> [!info] Le rapport indique
> 
> - ✅ Checks réussis
> - ⚠️ Avertissements à considérer
> - ❌ Problèmes bloquants à résoudre

**Résoudre les problèmes identifiés** avant de continuer.

### Processus de migration

#### Étape 1 : Mettre à jour vers la dernière version mineure

```bash
# S'assurer d'être sur la dernière version de la branche actuelle
apt update && apt dist-upgrade -y

# Redémarrer si nécessaire
reboot

# Vérifier la version après redémarrage
pveversion
```

#### Étape 2 : Modifier les dépôts APT

**Exemple de migration de Proxmox 7 vers 8** :

```bash
# Sauvegarder les dépôts actuels
cp -r /etc/apt/sources.list.d /root/apt-sources-backup

# Mise à jour du dépôt Debian (bullseye -> bookworm)
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list

# Mise à jour du dépôt Proxmox
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/pve-*.list

# Si vous utilisez Ceph, mettre à jour également
sed -i 's/quincy/reef/g' /etc/apt/sources.list.d/ceph.list

# Vérifier les modifications
cat /etc/apt/sources.list
cat /etc/apt/sources.list.d/*.list
```

> [!warning] Vérifiez manuellement N'utilisez pas `sed` aveuglément. Éditez et vérifiez chaque fichier manuellement si vous n'êtes pas sûr.

#### Étape 3 : Effectuer la mise à niveau

```bash
# Mettre à jour la liste des paquets
apt update

# Vérifier qu'il n'y a pas d'erreurs de dépôts
apt update 2>&1 | grep -i error

# Effectuer la mise à niveau du système
apt dist-upgrade

# Répondre aux questions de configuration
# Lisez attentivement chaque prompt
```

> [!warning] Points d'attention durant l'installation
> 
> - Gardez les versions de configuration locales si vous avez des customisations
> - Acceptez les nouvelles versions par défaut si vous n'avez rien modifié
> - Ne pas interrompre le processus (peut prendre 30-60 minutes)

#### Étape 4 : Redémarrer le nœud

```bash
# Redémarrage après mise à niveau majeure
reboot
```

### Vérifications post-migration

#### Vérifications système

```bash
# Vérifier la nouvelle version de Proxmox
pveversion -v

# Vérifier la version du kernel
uname -r

# Vérifier les services
systemctl status pvedaemon pveproxy pvestatd

# Vérifier les logs pour erreurs
journalctl -xe | grep -i error
journalctl -u pvedaemon -f
```

#### Vérifications cluster

```bash
# Vérifier l'état du cluster
pvecm status

# Vérifier la version de tous les nœuds
pvecm nodes

# Vérifier le quorum
pvecm expected 1  # ajuster selon le nombre de nœuds
```

> [!info] Migration cluster Dans un cluster, migrez un nœud à la fois et attendez que tout soit stable avant de passer au suivant.

#### Vérifications VMs et conteneurs

```bash
# Lister toutes les VMs
qm list

# Vérifier les VMs en cours d'exécution
qm status <VMID>

# Lister tous les conteneurs
pct list

# Vérifier les conteneurs en cours d'exécution
pct status <CTID>

# Tester la connexion à une VM/conteneur critique
qm start <VMID>
pct start <CTID>
```

#### Vérifications réseau et stockage

```bash
# Vérifier la configuration réseau
ip addr show
ip route show

# Vérifier les bridges
brctl show

# Vérifier le stockage
pvesm status

# Vérifier les disques
lsblk
zpool status  # si ZFS
lvs  # si LVM
```

#### Nettoyage post-migration

```bash
# Supprimer les anciens kernels
apt autoremove

# Nettoyer le cache APT
apt autoclean

# Vérifier l'espace disque libéré
df -h
```

> [!tip] Bonnes pratiques de migration majeure
> 
> - **Testez d'abord** sur un nœud de test ou en lab
> - **Migrez pendant** une fenêtre de maintenance
> - **Documentez** chaque étape et les problèmes rencontrés
> - **Conservez** les sauvegardes pendant au moins 30 jours
> - Dans un cluster : **un nœud à la fois**, avec validation complète entre chaque
> - **Préparez un plan de rollback** si nécessaire

#### Rollback en cas de problème

Si la migration échoue gravement :

```bash
# Restaurer les dépôts sauvegardés
rm -rf /etc/apt/sources.list.d/*
cp -r /root/apt-sources-backup/* /etc/apt/sources.list.d/

# Restaurer le sources.list principal
cp /root/proxmox-backup-YYYYMMDD/apt/sources.list /etc/apt/

# Downgrade (complexe, souvent plus simple de réinstaller)
# Ou restaurer depuis snapshot/backup si disponible
```

> [!warning] Le rollback est complexe Un downgrade complet est rarement possible. C'est pourquoi les sauvegardes et tests préalables sont critiques.

---

## 🎯 Résumé des points clés

|Aspect|Recommandation|
|---|---|
|**Dépôt**|Enterprise pour prod avec support, No-Subscription pour le reste|
|**Fréquence**|Hebdomadaire pour mises à jour de sécurité, mensuelle pour autres|
|**Méthode**|Interface web pour simplicité, CLI pour contrôle et automatisation|
|**Tests**|Toujours tester sur environnement non-critique d'abord|
|**Sauvegardes**|Avant toute mise à jour majeure ou upgrade de version|
|**Documentation**|Journaliser toutes les opérations de maintenance|

> [!tip] Philosophie de maintenance La maintenance proactive de Proxmox est un investissement dans la stabilité et la sécurité de votre infrastructure. Une stratégie de mise à jour claire et documentée évite les surprises et facilite la résolution de problèmes.

---

_Cours rédigé pour Obsidian - Proxmox VE_