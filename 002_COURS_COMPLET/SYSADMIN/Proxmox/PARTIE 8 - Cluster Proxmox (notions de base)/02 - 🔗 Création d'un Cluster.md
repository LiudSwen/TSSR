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

## 🎯 Introduction

Un **cluster Proxmox** permet de regrouper plusieurs serveurs Proxmox VE en une seule entité logique. Cette configuration offre plusieurs avantages majeurs :

- **Gestion centralisée** : administration de tous les nœuds depuis une seule interface
- **Haute disponibilité (HA)** : basculement automatique des VMs en cas de défaillance
- **Migration en direct** : déplacement des VMs entre nœuds sans interruption
- **Stockage partagé** : accès unifié aux ressources de stockage
- **Répartition de charge** : distribution optimale des machines virtuelles

> [!info] Qu'est-ce qu'un cluster ? Un cluster est un ensemble de serveurs (nœuds) qui travaillent ensemble comme un système unique. Dans Proxmox, le cluster utilise **Corosync** pour la communication entre nœuds et **Proxmox Cluster File System (pmxcfs)** pour partager la configuration.

> [!warning] Prérequis essentiels Avant de créer un cluster, assurez-vous que :
> 
> - Tous les nœuds ont des **noms d'hôte uniques** et valides (FQDN recommandé)
> - Les nœuds peuvent se **joindre mutuellement** via leurs adresses IP
> - Les **horloges sont synchronisées** (NTP configuré)
> - Les **versions de Proxmox** sont identiques ou compatibles
> - Aucun nœud n'appartient déjà à un autre cluster

---

## 🏗️ Création du cluster sur le premier nœud

### Prérequis

Avant de créer le cluster, vérifiez que votre premier nœud est correctement configuré :

```bash
# Vérifier le nom d'hôte (doit être un FQDN)
hostname --fqdn

# Vérifier la résolution DNS/hosts
ping -c 3 nom-du-noeud.domaine.local

# Vérifier la synchronisation temporelle
timedatectl status

# Vérifier qu'aucun cluster n'existe déjà
pvecm status
# Devrait retourner : "no cluster defined"
```

> [!tip] Convention de nommage Utilisez des noms d'hôte significatifs comme `pve-01.lab.local`, `pve-prod-01.entreprise.com`. Évitez les noms génériques comme `proxmox1` ou `server`.

### Commande de création

La création d'un cluster se fait avec la commande `pvecm create` suivie du nom du cluster :

```bash
# Syntaxe de base
pvecm create NOM_DU_CLUSTER

# Exemple
pvecm create mon-cluster-production
```

> [!example] Exemple de création
> 
> ```bash
> root@pve-01:~# pvecm create datacenter-cluster
> Corosync Cluster Engine Authentication key generator.
> Gathering 2048 bits for key from /dev/urandom.
> Writing corosync key to /etc/corosync/authkey.
> Writing corosync config to /etc/pve/corosync.conf
> Restart corosync and cluster filesystem
> ```

**Options avancées** :

```bash
# Spécifier une interface réseau spécifique
pvecm create mon-cluster --link0 192.168.100.10

# Créer avec plusieurs liens (redondance réseau)
pvecm create mon-cluster --link0 192.168.100.10 --link1 10.0.0.10
```

> [!info] Liens réseau multiples Proxmox supporte jusqu'à **8 liens réseau** (link0 à link7) pour la communication cluster. Cela permet d'avoir de la redondance et d'éviter les points de défaillance uniques.

### Vérification après création

Une fois le cluster créé, vérifiez son état :

```bash
# Afficher le statut du cluster
pvecm status

# Lister les nœuds du cluster
pvecm nodes

# Vérifier la configuration Corosync
cat /etc/pve/corosync.conf

# Vérifier les logs en temps réel
journalctl -u corosync -f
```

**Sortie attendue** de `pvecm status` :

```
Cluster information
-------------------
Name:             datacenter-cluster
Config Version:   1
Transport:        knet
Secure auth:      on

Quorum information
------------------
Date:             Wed Dec 24 10:30:00 2025
Quorum provider:  corosync_votequorum
Nodes:            1
Node ID:          0x00000001
Ring ID:          1.5
Quorate:          Yes
```

> [!warning] Quorum avec un seul nœud Avec un seul nœud, le cluster est "quorate" par défaut, mais ce n'est pas une configuration de production. Ajoutez rapidement d'autres nœuds pour bénéficier de la haute disponibilité.

---

## ➕ Ajout de nœuds au cluster

### Génération du lien d'invitation

Pour ajouter un nœud au cluster, vous devez d'abord générer un **lien d'invitation** depuis un nœud déjà membre du cluster :

```bash
# Générer un lien d'invitation (depuis un nœud existant)
pvecm add --help  # Voir les options disponibles

# OU via l'interface Web Proxmox :
# Datacenter → Cluster → Join Information → Copy Information
```

**Via l'interface graphique** (méthode recommandée) :

1. Connectez-vous à l'interface web du nœud déjà dans le cluster
2. Allez dans **Datacenter** → **Cluster**
3. Cliquez sur **Join Information**
4. Cliquez sur **Copy Information** pour copier le lien d'invitation

Le lien ressemble à ceci :

```
{
  "nodelist": [
    {
      "name": "pve-01",
      "nodeid": 1,
      "pve_addr": "192.168.100.10",
      "pve_fp": "AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD",
      "quorum_votes": 1,
      "ring0_addr": "192.168.100.10"
    }
  ],
  "preferred_node": "pve-01",
  "totem": {
    "cluster_name": "datacenter-cluster",
    "config_version": 1,
    "interface": {
      "0": {
        "linknumber": 0
      }
    },
    "ip_version": "ipv4",
    "version": 2
  }
}
```

> [!tip] Validité du lien Le lien d'invitation contient l'empreinte du certificat SSL du cluster. Il est valide tant que le certificat n'a pas changé. Pour des raisons de sécurité, générez un nouveau lien si vous ne l'utilisez pas immédiatement.

### Jonction au cluster

**Depuis le nouveau nœud**, utilisez la commande `pvecm add` pour rejoindre le cluster :

```bash
# Syntaxe de base (en ligne de commande)
pvecm add ADRESSE_IP_NOEUD_EXISTANT

# Exemple
pvecm add 192.168.100.10
```

**Le système vous demandera** :

- Le **mot de passe root** du nœud existant
- Confirmation que le nœud n'a pas de VMs/CTs existants (sinon ils seront supprimés de la configuration locale)

```bash
root@pve-02:~# pvecm add 192.168.100.10
Please enter superuser (root) password for '192.168.100.10': ********
Establishing API connection with host '192.168.100.10'
The authenticity of host '192.168.100.10' can't be established.
X509 SHA256 key fingerprint is AA:BB:CC:...:DD:EE:FF.
Are you sure you want to continue connecting (yes/no)? yes
```

**Avec des options avancées** :

```bash
# Spécifier l'adresse IP que ce nœud utilisera pour la communication cluster
pvecm add 192.168.100.10 --link0 192.168.100.20

# Ajouter avec plusieurs liens réseau
pvecm add 192.168.100.10 --link0 192.168.100.20 --link1 10.0.0.20

# Forcer l'ajout même si des VMs/CTs existent (ATTENTION : perte de configuration)
pvecm add 192.168.100.10 --force
```

> [!warning] Option --force L'option `--force` supprimera la configuration locale de toutes les VMs et conteneurs sur le nœud à ajouter. Utilisez-la uniquement si vous êtes sûr de ne pas avoir de données importantes ou si vous avez sauvegardé.

**Via l'interface graphique** (méthode alternative) :

1. Connectez-vous à l'interface web du **nouveau nœud** (qui va rejoindre)
2. Allez dans **Datacenter** → **Cluster** → **Join Cluster**
3. Collez les **informations d'invitation** copiées précédemment
4. Entrez le **mot de passe root** du cluster
5. Vérifiez l'**empreinte du certificat**
6. Cliquez sur **Join**

### Vérification de l'intégration

Après l'ajout du nœud, vérifiez que tout fonctionne correctement :

```bash
# Sur n'importe quel nœud du cluster
pvecm status

# Lister tous les nœuds
pvecm nodes

# Vérifier les logs d'ajout
journalctl -u corosync -u pve-cluster --since "10 minutes ago"
```

**Sortie attendue** de `pvecm nodes` :

```
Membership information
----------------------
    Nodeid      Votes Name
         1          1 pve-01 (local)
         2          1 pve-02
```

> [!tip] Accès web unifié Une fois le nœud ajouté, vous pouvez accéder à tous les nœuds depuis n'importe quelle interface web du cluster. Le menu de gauche affiche tous les nœuds avec leurs ressources.

**Vérifications supplémentaires** :

```bash
# Vérifier la synchronisation du système de fichiers cluster
pvecm expected 2  # Remplacer 2 par le nombre total de nœuds

# Vérifier la réplication de la configuration
cat /etc/pve/.members

# Tester la communication Corosync
corosync-cfgtool -s

# Vérifier le statut du quorum
pvecm quorum
```

---

## ✅ Vérification de l'état du cluster

### État général du cluster

La commande principale pour vérifier l'état du cluster est `pvecm status` :

```bash
pvecm status
```

**Interprétation des sections** :

|Section|Description|Valeurs normales|
|---|---|---|
|**Cluster information**|Informations générales|Name, Config Version, Transport: knet|
|**Quorum information**|État du quorum|Quorate: Yes, Nodes: nombre total|
|**Membership information**|Liste des nœuds|Tous les nœuds présents et online|

> [!example] Exemple de sortie complète
> 
> ```
> Cluster information
> -------------------
> Name:             datacenter-cluster
> Config Version:   3
> Transport:        knet
> Secure auth:      on
> 
> Quorum information
> ------------------
> Date:             Wed Dec 24 11:00:00 2025
> Quorum provider:  corosync_votequorum
> Nodes:            3
> Node ID:          0x00000001
> Ring ID:          1.8
> Quorate:          Yes
> 
> Votequorum information
> ----------------------
> Expected votes:   3
> Highest expected: 3
> Total votes:      3
> Quorum:           2
> Flags:            Quorate
> 
> Membership information
> ----------------------
> Nodeid      Votes    Name
>     0x00000001  1  pve-01 (local)
>     0x00000002  1  pve-02
>     0x00000003  1  pve-03
> ```

### État du quorum

Le **quorum** est le nombre minimum de nœuds qui doivent être en ligne pour que le cluster fonctionne. Il évite le "split-brain" (division du cluster).

```bash
# Afficher les informations de quorum
pvecm quorum

# Afficher les votes attendus et actuels
corosync-quorumtool -s
```

**Calcul du quorum** :

- Quorum = (nombre de nœuds / 2) + 1
- Avec 3 nœuds : quorum = 2
- Avec 4 nœuds : quorum = 3
- Avec 5 nœuds : quorum = 3

> [!info] Importance du nombre impair de nœuds Il est recommandé d'avoir un **nombre impair de nœuds** (3, 5, 7...) pour éviter les situations où exactement la moitié des nœuds sont en panne et le quorum n'est pas atteint.

**Commandes de diagnostic avancées** :

```bash
# Vérifier le statut de Corosync
systemctl status corosync

# Vérifier les membres Corosync
corosync-cmapctl | grep members

# Afficher la configuration Corosync complète
corosync-cmapctl

# Vérifier les erreurs Corosync
journalctl -u corosync --no-pager | grep -i error
```

### Statut de la réplication

Proxmox utilise **pmxcfs** (Proxmox Cluster File System) pour répliquer la configuration entre tous les nœuds :

```bash
# Vérifier le statut du système de fichiers cluster
pvecm status | grep -A 10 "Cluster information"

# Afficher les membres du cluster dans pmxcfs
cat /etc/pve/.members

# Vérifier la version de la configuration
cat /etc/pve/.version

# Vérifier l'état du service pve-cluster
systemctl status pve-cluster
```

**Fichiers importants du cluster** :

|Fichier|Description|
|---|---|
|`/etc/pve/corosync.conf`|Configuration Corosync (répliqué)|
|`/etc/pve/.members`|Liste des membres du cluster|
|`/etc/pve/.version`|Version de la configuration cluster|
|`/etc/pve/datacenter.cfg`|Configuration du datacenter|
|`/etc/corosync/authkey`|Clé d'authentification (LOCAL, non répliqué)|

> [!tip] Système de fichiers monté `/etc/pve/` est un système de fichiers monté par FUSE (pmxcfs). Tous les fichiers dans ce répertoire sont automatiquement répliqués sur tous les nœuds du cluster en temps réel.

**Vérifier la synchronisation** :

```bash
# Depuis chaque nœud, comparer les versions
# La Config Version doit être identique partout
pvecm status | grep "Config Version"

# Vérifier que tous les nœuds voient le même nombre de membres
cat /etc/pve/.members

# Forcer une mise à jour de la configuration (si nécessaire)
systemctl restart pve-cluster
```

**Commandes de diagnostic réseau** :

```bash
# Tester la connectivité entre nœuds
# Remplacer par les IPs de vos nœuds
ping -c 3 192.168.100.10
ping -c 3 192.168.100.20

# Vérifier les ports Corosync (UDP 5405-5412)
ss -ulnp | grep corosync

# Afficher les statistiques de communication Corosync
corosync-cfgtool -s

# Vérifier la latence entre nœuds
corosync-quorumtool -l
```

---

## ⚠️ Pièges courants et bonnes pratiques

### 🚫 Pièges courants

> [!warning] Noms d'hôte invalides **Problème** : Utiliser des noms d'hôte non-FQDN ou avec des caractères spéciaux.
> 
> **Solution** : Utilisez toujours des FQDN valides (ex: `pve-01.lab.local`) et vérifiez avec `hostname --fqdn`.

> [!warning] Désynchronisation horaire **Problème** : Les horloges des nœuds ne sont pas synchronisées, causant des problèmes de quorum.
> 
> **Solution** : Configurez NTP sur tous les nœuds avant de créer le cluster :
> 
> ```bash
> timedatectl set-ntp true
> systemctl restart systemd-timesyncd
> timedatectl status
> ```

> [!warning] Versions Proxmox incompatibles **Problème** : Ajouter un nœud avec une version Proxmox différente peut causer des problèmes.
> 
> **Solution** : Mettez à jour tous les nœuds à la même version avant de créer/rejoindre le cluster :
> 
> ```bash
> apt update && apt dist-upgrade
> pveversion
> ```

> [!warning] Pare-feu bloquant les ports cluster **Problème** : Le pare-feu bloque les ports nécessaires à la communication cluster.
> 
> **Solution** : Assurez-vous que ces ports sont ouverts entre les nœuds :
> 
> - **UDP 5405-5412** : Communication Corosync
> - **TCP 22** : SSH (pour l'ajout de nœuds)
> - **TCP 8006** : Interface web Proxmox
> - **TCP 3128** : Proxy SPICE (optionnel)

> [!warning] Ajout forcé avec données existantes **Problème** : Utiliser `--force` lors de l'ajout d'un nœud avec des VMs/CTs existants.
> 
> **Solution** : Sauvegardez toujours les VMs avant d'ajouter un nœud avec `--force`, ou migrez-les proprement.

### ✅ Bonnes pratiques

> [!tip] Planification du cluster
> 
> - **Minimum 3 nœuds** pour avoir un vrai quorum et haute disponibilité
> - **Nombre impair** de nœuds (3, 5, 7) pour éviter les split-brain
> - **Réseau dédié** pour la communication cluster (VLAN séparé recommandé)
> - **Liens redondants** (link0 et link1) pour la résilience réseau

> [!tip] Réseau cluster
> 
> - Utilisez un **réseau dédié à faible latence** (< 2ms) pour Corosync
> - Configurez des **liens multiples** sur des réseaux différents
> - Évitez de router la communication cluster sur internet
> - Privilégiez des connexions **10GbE ou plus** pour le stockage partagé

> [!tip] Documentation
> 
> - **Documentez** les adresses IP, noms d'hôte et rôles de chaque nœud
> - Gardez une **copie de la configuration** (`/etc/pve/corosync.conf`)
> - Notez les **empreintes des certificats** SSL du cluster
> - Maintenez un **journal des modifications** du cluster

> [!tip] Sauvegarde avant changements Avant tout changement majeur du cluster :
> 
> ```bash
> # Sauvegarder la configuration Corosync
> cp /etc/pve/corosync.conf /root/corosync.conf.backup
> 
> # Sauvegarder la clé d'authentification
> cp /etc/corosync/authkey /root/authkey.backup
> 
> # Exporter la liste des VMs/CTs
> pvesh get /cluster/resources --type vm > /root/vm_list.txt
> ```

> [!tip] Surveillance continue Mettez en place une surveillance pour :
> 
> - **État du quorum** (alerte si non-quorate)
> - **Nombre de nœuds online** (alerte si nœud manquant)
> - **Latence réseau** entre nœuds (alerte si > 5ms)
> - **Erreurs Corosync** dans les logs
> 
> Exemple de script de surveillance :
> 
> ```bash
> #!/bin/bash
> # Script de vérification du cluster (à exécuter en cron)
> 
> if ! pvecm status | grep -q "Quorate.*Yes"; then
>     echo "ALERTE: Cluster non-quorate!" | mail -s "Cluster Alert" admin@example.com
> fi
> 
> NODE_COUNT=$(pvecm nodes | grep -c "^[[:space:]]*[0-9]")
> if [ "$NODE_COUNT" -lt 3 ]; then
>     echo "ALERTE: Seulement $NODE_COUNT nœuds actifs!" | mail -s "Cluster Alert" admin@example.com
> fi
> ```

> [!tip] Tests réguliers Effectuez des tests réguliers pour valider la haute disponibilité :
> 
> - **Simulation de panne** : arrêter un nœud et vérifier le basculement
> - **Migration à chaud** : migrer des VMs entre nœuds
> - **Test de quorum** : vérifier le comportement avec N-1 nœuds
> - **Restauration** : tester la procédure de récupération d'un nœud

---

## 🎓 Résumé des commandes essentielles

```bash
# === CRÉATION DU CLUSTER ===
pvecm create nom-cluster                    # Créer un cluster
pvecm create nom-cluster --link0 IP         # Créer avec IP spécifique

# === AJOUT DE NŒUDS ===
pvecm add IP_NOEUD_EXISTANT                 # Rejoindre un cluster
pvecm add IP --link0 IP_LOCAL               # Rejoindre avec IP spécifique

# === VÉRIFICATION ===
pvecm status                                # État complet du cluster
pvecm nodes                                 # Liste des nœuds
pvecm quorum                                # Informations de quorum
corosync-quorumtool -s                      # Statut quorum détaillé
cat /etc/pve/corosync.conf                  # Configuration Corosync

# === DIAGNOSTIC ===
systemctl status corosync                   # Service Corosync
systemctl status pve-cluster                # Service cluster Proxmox
journalctl -u corosync -f                   # Logs Corosync en direct
pvecm expected N                            # Définir votes attendus
```

---

**Navigation** : 🏠 [[Proxmox - Sommaire]] | ⬅️ [[Proxmox - Introduction aux Clusters]] | ➡️ [[Proxmox - Gestion du Cluster]]