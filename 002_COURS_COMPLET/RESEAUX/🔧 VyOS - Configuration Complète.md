

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

## 🚀 Installation de VyOS

### Téléchargement et préparation

VyOS est disponible en deux versions :

- **VyOS Rolling Release** : gratuite, mises à jour fréquentes
- **VyOS LTS** : support à long terme, nécessite un abonnement

> [!info] Formats disponibles
> 
> - ISO pour installation sur VM ou bare-metal
> - Images cloud (AWS, Azure, GCP, Proxmox, VMware)
> - Images conteneur Docker

### Installation sur VM/Bare-metal

**Étapes d'installation :**

1. **Démarrage sur l'ISO**
    
    - Login par défaut : `vyos` / `vyos`
2. **Lancement de l'installation**
    

```bash
install image
```

3. **Réponses aux questions d'installation**

```bash
# Sélection du disque
Would you like to continue? (Yes/No) [Yes]: Yes
Partition (Auto/Union) [Auto]: Auto
Install the image on? [sda]: sda

# Configuration système
What would you like to name this image? [1.4-rolling]: <nom_version>
Please enter a password for the "vyos" user: <votre_mot_de_passe>
Which drive should GRUB modify the boot partition on? [sda]: sda
```

4. **Redémarrage**

```bash
reboot
```

> [!warning] Retirer l'ISO Pensez à retirer l'ISO du lecteur virtuel avant le redémarrage pour éviter de rebooter sur l'installeur.

### Installation en tant que conteneur

```bash
# Pull de l'image Docker
docker pull vyos/vyos:latest

# Lancement du conteneur
docker run -d --name vyos-router \
  --privileged \
  --network host \
  vyos/vyos:latest
```

---

## 🎛️ Modes de configuration

VyOS utilise un système de modes hiérarchiques inspiré de Juniper JunOS.

### Les trois modes principaux

|Mode|Prompt|Description|Commandes typiques|
|---|---|---|---|
|**Operational**|`vyos@router:~$`|Mode de visualisation et diagnostic|`show`, `ping`, `traceroute`|
|**Configuration**|`vyos@router#`|Mode d'édition de configuration|`set`, `delete`, `edit`|
|**Edit**|`vyos@router# edit <path>`|Contexte de configuration spécifique|Commandes relatives au contexte|

### Navigation entre les modes

```bash
# Passer en mode configuration
configure

# Retourner en mode operational
exit

# Ou utiliser Ctrl+D pour sortir d'un niveau

# Quitter complètement VyOS
exit
# puis
exit
```

### Commandes fondamentales en mode configuration

```bash
# Afficher la configuration active
show

# Afficher la configuration d'une section spécifique
show interfaces

# Comparer la configuration active avec les modifications
compare

# Valider la configuration (vérification syntaxe)
commit

# Sauvegarder la configuration
save

# Annuler les modifications non commitées
discard

# Retourner à la configuration sauvegardée
load
```

> [!tip] Navigation rapide Utilisez la touche **Tab** pour l'autocomplétion et **?** pour afficher les options disponibles à tout moment.

### Syntaxe de configuration

```bash
# DÉFINIR une valeur (SET)
set <chemin> <valeur>

# SUPPRIMER une valeur (DELETE)
delete <chemin>

# ÉDITER un contexte (EDIT)
edit <chemin>

# REVENIR au niveau supérieur (UP)
up

# REVENIR à la racine (TOP)
top
```

> [!example] Exemple de workflow
> 
> ```bash
> configure
> set system host-name vyos-router
> set system domain-name example.com
> commit
> save
> exit
> ```

---

## 🔌 Configuration des interfaces

### Types d'interfaces

VyOS supporte plusieurs types d'interfaces :

- **Ethernet** : `eth0`, `eth1`, etc.
- **VLAN** : `eth0.10`, `eth1.100`, etc.
- **Bond** : agrégation de liens
- **Bridge** : pont réseau
- **Tunnel** : VPN, GRE, VXLAN
- **Loopback** : `lo`
- **Dummy** : interfaces virtuelles

### Configuration d'une interface Ethernet

#### Adresse IP statique

```bash
configure

# Configuration de base
set interfaces ethernet eth0 address '192.168.1.1/24'
set interfaces ethernet eth0 description 'LAN Interface'

# Activer l'interface (par défaut elles sont désactivées)
delete interfaces ethernet eth0 disable

commit
save
```

#### Adresse IP via DHCP

```bash
configure

set interfaces ethernet eth1 address dhcp
set interfaces ethernet eth1 description 'WAN Interface - DHCP'

commit
save
```

#### Multiples adresses IP

```bash
configure

# Ajouter plusieurs adresses sur la même interface
set interfaces ethernet eth0 address '192.168.1.1/24'
set interfaces ethernet eth0 address '192.168.2.1/24'
set interfaces ethernet eth0 address '10.0.0.1/8'

commit
save
```

### Paramètres avancés des interfaces

#### MTU (Maximum Transmission Unit)

```bash
# Modifier le MTU (par défaut 1500)
set interfaces ethernet eth0 mtu '9000'
```

> [!info] Jumbo Frames MTU de 9000 octets pour améliorer les performances sur des réseaux à haut débit (stockage, datacenter).

#### Duplex et vitesse

```bash
# Configuration manuelle (éviter l'auto-négociation)
set interfaces ethernet eth0 duplex 'full'
set interfaces ethernet eth0 speed '1000'

# Valeurs possibles pour speed : 10, 100, 1000, 2500, 5000, 10000, etc.
# Valeurs possibles pour duplex : half, full, auto
```

#### Désactivation d'interface

```bash
# Désactiver administrativement une interface
set interfaces ethernet eth2 disable

# Réactiver (supprimer la directive disable)
delete interfaces ethernet eth2 disable
```

### Vérification et diagnostic

```bash
# Afficher toutes les interfaces
show interfaces

# Afficher une interface spécifique
show interfaces ethernet eth0

# Statistiques détaillées
show interfaces ethernet eth0 statistics

# Afficher seulement l'adresse IP
show interfaces ethernet eth0 brief

# État physique
show interfaces ethernet eth0 physical
```

> [!tip] Raccourci pour voir les IPs
> 
> ```bash
> show interfaces | grep "inet "
> ```

---

## 🏷️ Configuration des VLANs

### Qu'est-ce qu'un VLAN ?

Un VLAN (Virtual Local Area Network) permet de segmenter un réseau physique en plusieurs réseaux logiques isolés au niveau Layer 2.

**Avantages :**

- Séparation du trafic (sécurité)
- Optimisation de la bande passante
- Facilité de gestion
- Réduction des domaines de broadcast

### VLAN Tagging (802.1Q)

VyOS utilise la notation **interface.vlan-id** pour les interfaces VLAN.

> [!warning] VLAN 1 - Bonne pratique de sécurité **Ne jamais utiliser le VLAN 1** ! C'est le VLAN par défaut sur la plupart des équipements réseau et il présente des risques de sécurité :
> 
> - Trafic de management non sécurisé
> - Attaques VLAN hopping facilitées
> - Diffusion de protocoles Layer 2 (CDP, VTP, DTP)
> 
> **Recommandations :**
> 
> - Commencez vos VLANs à partir de **VLAN 10** minimum
> - Réservez un VLAN élevé pour le management (ex: VLAN 99 ou 999)
> - Désactivez le VLAN 1 sur les switches si possible

#### Configuration de base d'un VLAN

```bash
configure

# Créer une interface VLAN 10 sur eth1 (JAMAIS VLAN 1 !)
set interfaces ethernet eth1 vif 10 address '192.168.10.1/24'
set interfaces ethernet eth1 vif 10 description 'VLAN 10 - Serveurs'

# Créer une interface VLAN 20 sur eth1
set interfaces ethernet eth1 vif 20 address '192.168.20.1/24'
set interfaces ethernet eth1 vif 20 description 'VLAN 20 - Utilisateurs'

commit
save
```

> [!info] Notation VIF **VIF** signifie "Virtual Interface". C'est la terminologie VyOS pour les sous-interfaces VLAN.

#### Multiples VLANs sur une interface

```bash
configure

# Configuration trunk avec plusieurs VLANs
set interfaces ethernet eth2 vif 100 address '10.0.100.1/24'
set interfaces ethernet eth2 vif 100 description 'VLAN Production'

set interfaces ethernet eth2 vif 200 address '10.0.200.1/24'
set interfaces ethernet eth2 vif 200 description 'VLAN Development'

set interfaces ethernet eth2 vif 300 address '10.0.300.1/24'
set interfaces ethernet eth2 vif 300 description 'VLAN Guest'

commit
save
```

### QinQ (VLAN Stacking / 802.1ad)

Le QinQ permet d'encapsuler un VLAN dans un autre (double tagging).

```bash
configure

# VLAN externe (S-VLAN) 100, VLAN interne (C-VLAN) 10
set interfaces ethernet eth3 vif-s 100 vif-c 10 address '172.16.10.1/24'
set interfaces ethernet eth3 vif-s 100 vif-c 10 description 'QinQ 100.10'

commit
save
```

> [!warning] Support matériel Le QinQ nécessite que l'équipement réseau upstream supporte le 802.1ad.

### Configuration VLAN avec DHCP

```bash
configure

# VLAN client DHCP
set interfaces ethernet eth1 vif 50 address dhcp
set interfaces ethernet eth1 vif 50 description 'VLAN 50 - DHCP Client'

commit
save
```

### Paramètres avancés VLAN

#### MTU sur VLAN

```bash
# Le MTU du VLAN doit être inférieur ou égal au MTU de l'interface parente
set interfaces ethernet eth1 mtu '1600'
set interfaces ethernet eth1 vif 10 mtu '1500'
```

#### Priorité 802.1p (CoS)

```bash
# Définir la priorité du trafic (0-7)
set interfaces ethernet eth1 vif 10 egress-qos '0:1'
set interfaces ethernet eth1 vif 10 ingress-qos '1:0'
```

### VLAN natif (untagged)

```bash
configure

# Configuration d'une interface trunk avec VLAN natif
# ⚠️ Évitez d'utiliser le VLAN natif sur des trunks si possible
# Si nécessaire, NE JAMAIS utiliser le VLAN 1 comme natif
set interfaces ethernet eth1 address '192.168.100.1/24'
set interfaces ethernet eth1 description 'VLAN natif (non recommandé sur trunk)'

# Les VLANs taggés coexistent sur la même interface
set interfaces ethernet eth1 vif 10 address '192.168.10.1/24'
set interfaces ethernet eth1 vif 20 address '192.168.20.1/24'

commit
save
```

> [!warning] Sécurité VLAN natif
> 
> - Le VLAN natif permet le trafic non-tagué sur un trunk
> - **Bonne pratique** : Utiliser un VLAN natif différent du VLAN 1
> - **Meilleure pratique** : Utiliser un VLAN natif inutilisé (ex: VLAN 999)
> - **Pratique optimale** : Ne pas utiliser de VLAN natif et taguer tout le trafic

### Vérification des VLANs

```bash
# Afficher toutes les interfaces VLAN
show interfaces

# Afficher un VLAN spécifique
show interfaces ethernet eth1 vif 10

# Vérifier les tags VLAN actifs
show interfaces ethernet eth1 vif

# Statistiques d'une interface VLAN
show interfaces ethernet eth1 vif 10 statistics
```

> [!example] Scénario typique : Réseau d'entreprise
> 
> ```bash
> configure
> 
> # VLAN 10 - Management (JAMAIS VLAN 1 !)
> set interfaces ethernet eth0 vif 10 address '10.0.10.1/24'
> set interfaces ethernet eth0 vif 10 description 'Management'
> 
> # VLAN 20 - Serveurs
> set interfaces ethernet eth0 vif 20 address '10.0.20.1/24'
> set interfaces ethernet eth0 vif 20 description 'Servers'
> 
> # VLAN 30 - Bureaux
> set interfaces ethernet eth0 vif 30 address '10.0.30.1/24'
> set interfaces ethernet eth0 vif 30 description 'Office Users'
> 
> # VLAN 40 - Invités
> set interfaces ethernet eth0 vif 40 address '10.0.40.1/24'
> set interfaces ethernet eth0 vif 40 description 'Guest WiFi'
> 
> commit
> save
> ```

> [!tip] Schéma de numérotation VLAN recommandé
> 
> - **VLAN 10-19** : Management et infrastructure
> - **VLAN 20-29** : Serveurs et services
> - **VLAN 30-39** : Utilisateurs et postes de travail
> - **VLAN 40-49** : Invités et IoT
> - **VLAN 50-99** : Réserve / services spéciaux
> - **VLAN 100+** : Production / applications
> - **VLAN 999** : VLAN natif inutilisé (si nécessaire)

---

## 🛣️ Routage IP (IP Route)

### Concepts de base du routage

Le routage détermine le chemin que prennent les paquets IP pour atteindre leur destination. VyOS supporte :

- **Routage statique** : routes configurées manuellement
- **Routage dynamique** : protocoles comme OSPF, BGP, RIP

> [!info] Focus sur le routage statique Cette section se concentre sur le routage statique. Les protocoles dynamiques sont des sujets avancés traités dans d'autres parties.

### Table de routage

La table de routage contient :

- **Réseau de destination** : où le paquet doit aller
- **Masque** : taille du réseau
- **Passerelle (Gateway)** : prochain saut
- **Interface** : interface de sortie
- **Métrique** : coût de la route

### Route par défaut (Default Gateway)

La route par défaut (0.0.0.0/0) est utilisée quand aucune route spécifique ne correspond.

```bash
configure

# Route par défaut via une passerelle
set protocols static route 0.0.0.0/0 next-hop 192.168.1.254

# Route par défaut via une interface
set protocols static route 0.0.0.0/0 next-hop 192.168.1.254 interface eth0

commit
save
```

> [!warning] Une seule route par défaut Avoir plusieurs routes par défaut avec la même métrique peut causer des comportements imprévisibles. Utilisez des métriques différentes pour le load-balancing ou le failover.

### Routes statiques

#### Route simple

```bash
configure

# Route vers le réseau 10.20.0.0/24 via la passerelle 192.168.1.10
set protocols static route 10.20.0.0/24 next-hop 192.168.1.10

commit
save
```

#### Route avec interface spécifique

```bash
configure

# Route via une interface particulière
set protocols static route 172.16.0.0/16 next-hop 10.0.0.1 interface eth1

commit
save
```

> [!tip] Quand spécifier l'interface ? C'est utile quand plusieurs interfaces peuvent atteindre la même passerelle (réseaux multihome).

#### Route avec métrique

```bash
configure

# Route primaire (métrique basse = prioritaire)
set protocols static route 192.168.50.0/24 next-hop 10.0.0.1 distance 10

# Route de backup (métrique haute)
set protocols static route 192.168.50.0/24 next-hop 10.0.0.2 distance 20

commit
save
```

> [!info] Distance administrative Plus la valeur est **basse**, plus la route est **prioritaire**. Par défaut = 1 pour les routes statiques.

### Routes multiples (ECMP - Equal Cost Multi-Path)

ECMP permet de répartir le trafic sur plusieurs chemins de coût égal.

```bash
configure

# Deux routes avec la même métrique = load balancing
set protocols static route 10.100.0.0/24 next-hop 192.168.1.1
set protocols static route 10.100.0.0/24 next-hop 192.168.1.2

commit
save
```

> [!tip] Load balancing VyOS répartit le trafic par flux (hash des IPs source/destination), pas paquet par paquet.

### Routes host (/32)

```bash
configure

# Route spécifique vers un seul hôte
set protocols static route 8.8.8.8/32 next-hop 192.168.1.254

commit
save
```

### Blackhole routes

Les blackhole routes suppriment silencieusement le trafic (utile pour bloquer des destinations).

```bash
configure

# Tout trafic vers ce réseau est abandonné
set protocols static route 192.168.99.0/24 blackhole

commit
save
```

> [!warning] Usage prudent Les blackhole routes peuvent causer des problèmes difficiles à diagnostiquer si configurées par erreur.

### Routes avec description

```bash
configure

# Ajouter une description pour documentation
set protocols static route 10.50.0.0/24 next-hop 192.168.1.20
set protocols static route 10.50.0.0/24 description 'Route vers site distant Paris'

commit
save
```

### Configuration avancée

#### Route avec DHCP option

```bash
configure

# Ne pas utiliser la route par défaut fournie par DHCP
set interfaces ethernet eth1 address dhcp
set interfaces ethernet eth1 dhcp-options no-default-route

# Définir manuellement la route par défaut
set protocols static route 0.0.0.0/0 next-hop 203.0.113.1

commit
save
```

#### Policy-based routing

```bash
configure

# Marquer le trafic source 192.168.10.0/24 pour utiliser une table de routage alternative
set policy route PBR rule 10 source address 192.168.10.0/24
set policy route PBR rule 10 set table 100

# Définir la route dans la table 100
set protocols static table 100 route 0.0.0.0/0 next-hop 10.0.0.100

# Appliquer la policy sur l'interface
set interfaces ethernet eth2 policy route PBR

commit
save
```

### Vérification des routes

```bash
# Afficher la table de routage complète
show ip route

# Afficher seulement les routes statiques
show ip route static

# Afficher seulement la route par défaut
show ip route 0.0.0.0/0

# Vérifier le chemin vers une destination
show ip route 10.20.30.40

# Tracer la route
traceroute 10.20.30.40

# Test de connectivité
ping 10.20.30.40
```

> [!example] Lecture d'une table de routage
> 
> ```
> S>*  0.0.0.0/0 [1/0] via 192.168.1.254, eth0
> ```
> 
> - **S** : route statique
> - **>** : route sélectionnée (active)
> - ***** : route dans le FIB (Forwarding Information Base)
> - **[1/0]** : [distance administrative / métrique]

### Suppression de routes

```bash
configure

# Supprimer une route spécifique
delete protocols static route 10.20.0.0/24

# Supprimer toutes les routes statiques (ATTENTION!)
delete protocols static route

commit
save
```

> [!warning] Suppression massive La suppression de `protocols static route` supprime **toutes** les routes statiques, y compris la route par défaut !

### Scénarios courants

#### Scénario 1 : Routeur d'accès Internet simple

```bash
configure

# Interface WAN
set interfaces ethernet eth0 address dhcp
set interfaces ethernet eth0 description 'WAN - Internet'

# Interface LAN
set interfaces ethernet eth1 address '192.168.1.1/24'
set interfaces ethernet eth1 description 'LAN'

# Route par défaut via DHCP (automatique)
# Pas besoin de configurer manuellement si DHCP fournit la gateway

commit
save
```

#### Scénario 2 : Multi-site avec routes statiques

```bash
configure

# Interface LAN local
set interfaces ethernet eth0 address '10.0.1.1/24'
set interfaces ethernet eth0 description 'LAN Site A'

# Interface WAN vers routeur distant
set interfaces ethernet eth1 address '203.0.113.10/30'
set interfaces ethernet eth1 description 'WAN to Site B'

# Route vers le LAN du site distant
set protocols static route 10.0.2.0/24 next-hop 203.0.113.9
set protocols static route 10.0.2.0/24 description 'LAN Site B'

# Route par défaut vers Internet
set protocols static route 0.0.0.0/0 next-hop 203.0.113.1

commit
save
```

#### Scénario 3 : Redondance avec failover

```bash
configure

# Route primaire (fibre optique) - métrique basse
set protocols static route 0.0.0.0/0 next-hop 192.168.1.254 distance 10
set protocols static route 0.0.0.0/0 next-hop 192.168.1.254 description 'Internet Primaire - Fibre'

# Route backup (4G/LTE) - métrique haute
set protocols static route 0.0.0.0/0 next-hop 192.168.2.254 distance 20
set protocols static route 0.0.0.0/0 next-hop 192.168.2.254 description 'Internet Backup - 4G'

commit
save
```

---

## 💾 Sauvegarde et gestion de la configuration

### Comprendre les configurations VyOS

VyOS maintient deux types de configuration :

- **Running config** : configuration active en mémoire
- **Saved config** : configuration sauvegardée sur disque

> [!warning] Perte de configuration Les modifications commitées mais non sauvegardées sont **perdues** au redémarrage !

### Workflow de configuration

```bash
# 1. Entrer en mode configuration
configure

# 2. Faire des modifications
set system host-name vyos-router

# 3. Vérifier les changements
compare

# 4. Valider (activer les changements)
commit

# 5. Sauvegarder sur disque
save

# 6. Sortir du mode configuration
exit
```

### Commandes de sauvegarde

#### Sauvegarde standard

```bash
# Sauvegarder la configuration running
save

# Sauvegarder avec un nom spécifique
save /config/backup-2026-01-26.config
```

#### Vérification de la configuration sauvegardée

```bash
# Afficher la configuration sauvegardée
show configuration files

# Comparer running config avec saved config
compare saved
```

### Restauration de configuration

```bash
configure

# Charger la configuration sauvegardée
load

# Charger une configuration spécifique
load /config/backup-2026-01-26.config

# Fusionner avec la configuration actuelle
merge /config/partial-config.config

commit
save
```

> [!tip] Différence load vs merge
> 
> - **load** : remplace totalement la configuration
> - **merge** : ajoute/fusionne avec la configuration existante

### Rollback de configuration

VyOS conserve un historique des commits pour permettre le rollback.

```bash
configure

# Voir l'historique des commits
show system commit

# Rollback au commit précédent
rollback 1

# Rollback à un commit spécifique (exemple : 5 commits en arrière)
rollback 5

commit
save
```

> [!info] Limite de l'historique Par défaut, VyOS conserve les 100 derniers commits.

### Export et backup externe

#### Export en format texte

```bash
# Afficher la configuration complète
show configuration

# Exporter vers un fichier
show configuration > /tmp/vyos-config.txt

# Copier via SCP vers un serveur distant
scp /tmp/vyos-config.txt user@backup-server:/backups/
```

#### Export en format JSON

```bash
# Configuration au format JSON (utile pour automation)
show configuration json

# Sauvegarder en JSON
show configuration json > /tmp/vyos-config.json
```

### Configuration automatisée

#### Boot config

```bash
# Spécifier un fichier de configuration au boot
set system config-management commit-archive location 'scp://user@server/path'
```

#### Script de sauvegarde automatique

```bash
# Créer un script de backup quotidien (à placer dans /config/scripts)
#!/bin/bash
DATE=$(date +%Y%m%d)
/opt/vyatta/bin/vyatta-op-cmd-wrapper show configuration > /config/backup-$DATE.config
scp /config/backup-$DATE.config user@backup-server:/vyos-backups/
```

### Réinitialisation

#### Reset partiel

```bash
configure

# Supprimer une section de configuration
delete interfaces ethernet eth2

commit
save
```

#### Reset complet (factory reset)

```bash
# ATTENTION : Ceci efface TOUTE la configuration !
configure
load /opt/vyatta/etc/config.boot.default
commit
save
exit

# Redémarrer
reboot
```

> [!warning] Reset complet Le reset complet ramène VyOS à sa configuration d'usine. Utilisez avec **extrême prudence** !

### Bonnes pratiques

> [!tip] Checklist de sauvegarde
> 
> - ✅ Toujours faire `compare` avant `commit`
> - ✅ Toujours faire `save` après `commit`
> - ✅ Documenter les changements avec `commit comment "description"`
> - ✅ Faire des backups réguliers hors du routeur
> - ✅ Tester les restaurations périodiquement
> - ✅ Versionner les configurations importantes

#### Commit avec commentaire

```bash
configure

set system host-name new-vyos-router

commit comment "Changement de hostname pour conformité DNS"

save
```

#### Commit avec confirmation automatique

```bash
configure

# Demander confirmation après 5 minutes
commit-confirm 5

# Si tout fonctionne bien, confirmer
confirm

# Sinon, la configuration rollback automatiquement après 5 minutes
```

> [!tip] Sécurité lors de changements critiques Le `commit-confirm` est **essentiel** lors de modifications réseau à distance pour éviter de se bloquer l'accès.

---

## 🖥️ Configuration spécifique Proxmox

### Préparation de la VM VyOS sur Proxmox

#### Création de la VM

```bash
# Dans l'interface Proxmox ou via CLI
qm create 100 --name vyos-router --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
```

**Paramètres recommandés :**

- **RAM** : 2 GB minimum (4 GB pour usage intensif)
- **CPU** : 2 cores minimum
- **Disque** : 10 GB minimum
- **Type réseau** : VirtIO (meilleures performances)

> [!tip] Performance réseau Utilisez toujours **VirtIO** pour les interfaces réseau sur Proxmox, c'est le driver le plus performant.

#### Ajout d'interfaces réseau multiples

```bash
# Ajouter des interfaces pour un routeur multi-réseaux
qm set 100 --net1 virtio,bridge=vmbr1
qm set 100 --net2 virtio,bridge=vmbr2
qm set 100 --net3 virtio,bridge=vmbr3
```

**Correspondance des interfaces :**

|Proxmox|VyOS|Usage typique|
|---|---|---|
|net0 → vmbr0|eth0|WAN / Internet|
|net1 → vmbr1|eth1|LAN / VLAN Trunk|
|net2 → vmbr2|eth2|DMZ|
|net3 → vmbr3|eth3|Management|

### Identification des interfaces dans VyOS

```bash
# Lister toutes les interfaces détectées
show interfaces

# Vérifier les adresses MAC (pour correspondre avec Proxmox)
show interfaces ethernet detail

# Voir l'état physique
ip link show
```

> [!info] Ordre des interfaces L'ordre des interfaces dans VyOS (eth0, eth1, etc.) correspond généralement à l'ordre d'ajout dans Proxmox (net0, net1, etc.), mais vérifiez toujours les adresses MAC pour être sûr.

### Configuration réseau typique sur Proxmox

#### Scénario 1 : Routeur simple avec VLAN

```bash
configure

# eth0 : WAN vers Internet (via vmbr0 sur Proxmox)
set interfaces ethernet eth0 address dhcp
set interfaces ethernet eth0 description 'WAN - Internet via Proxmox'

# eth1 : Trunk VLAN vers infrastructure (via vmbr1 sur Proxmox)
set interfaces ethernet eth1 description 'VLAN Trunk'

# VLAN 10 : Serveurs
set interfaces ethernet eth1 vif 10 address '10.0.10.1/24'
set interfaces ethernet eth1 vif 10 description 'VLAN 10 - Serveurs Proxmox'

# VLAN 20 : VMs de production
set interfaces ethernet eth1 vif 20 address '10.0.20.1/24'
set interfaces ethernet eth1 vif 20 description 'VLAN 20 - Production VMs'

# VLAN 30 : VMs de dev/test
set interfaces ethernet eth1 vif 30 address '10.0.30.1/24'
set interfaces ethernet eth1 vif 30 description 'VLAN 30 - Dev/Test VMs'

# VLAN 99 : Management (JAMAIS VLAN 1 pour la sécurité !)
set interfaces ethernet eth1 vif 99 address '10.0.99.1/24'
set interfaces ethernet eth1 vif 99 description 'VLAN 99 - Management'

commit
save
```

#### Scénario 2 : Routeur avec DMZ

```bash
configure

# eth0 : WAN
set interfaces ethernet eth0 address dhcp
set interfaces ethernet eth0 description 'WAN - Internet'

# eth1 : LAN interne
set interfaces ethernet eth1 address '192.168.1.1/24'
set interfaces ethernet eth1 description 'LAN Interne'

# eth2 : DMZ pour services exposés
set interfaces ethernet eth2 address '10.10.10.1/24'
set interfaces ethernet eth2 description 'DMZ - Services publics'

# eth3 : Management dédié
set interfaces ethernet eth3 address '192.168.99.1/24'
set interfaces ethernet eth3 description 'Management Network'

commit
save
```

### Configuration de bridges Proxmox pour VLANs

> [!info] Configuration côté Proxmox Pour que les VLANs fonctionnent correctement, configurez les bridges Proxmox en mode "VLAN aware".

```bash
# Dans Proxmox (fichier /etc/network/interfaces)

# Bridge VLAN-aware
auto vmbr1
iface vmbr1 inet manual
    bridge-ports none
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    bridge-vids 2-4094
```

### Accès à la console VyOS depuis Proxmox

```bash
# Via l'interface web Proxmox : VM > Console

# Via CLI sur le host Proxmox
qm terminal 100

# Via VNC (si activé)
qm vncproxy 100
```

### Optimisations pour Proxmox

#### Désactiver les services inutiles

```bash
configure

# Si pas besoin d'IPv6
set system ipv6 disable

commit
save
```

#### Optimiser les performances réseau

```bash
configure

# Activer les offloads matériels (si supporté par VirtIO)
set interfaces ethernet eth0 offload gso
set interfaces ethernet eth0 offload gro
set interfaces ethernet eth0 offload tso
set interfaces ethernet eth0 offload sg

commit
save
```

> [!warning] Offload et VLANs Les offloads matériels peuvent parfois causer des problèmes avec les VLANs. Si vous rencontrez des soucis de performance ou de connectivité, essayez de les désactiver.

#### Ajuster les queues réseau

```bash
configure

# Augmenter les tailles de queue pour le throughput
set interfaces ethernet eth0 ring-buffer rx 4096
set interfaces ethernet eth0 ring-buffer tx 4096

commit
save
```

### Snapshot et backup dans Proxmox

> [!tip] Avant modifications importantes Créez toujours un snapshot de la VM VyOS avant des changements critiques !

```bash
# Dans Proxmox CLI
qm snapshot 100 vyos-before-routing-changes

# Restaurer si nécessaire
qm rollback 100 vyos-before-routing-changes
```

### Accès SSH pour gestion à distance

```bash
configure

# Activer SSH
set service ssh port 22
set service ssh listen-address 192.168.99.1

# Autoriser seulement depuis le réseau management
set service ssh access-control allow from 192.168.99.0/24

# Désactiver l'authentification par mot de passe (optionnel, si clés SSH)
set service ssh disable-password-authentication

commit
save
```

### Configuration après installation sur Proxmox

#### Checklist post-installation

```bash
# 1. Vérifier les interfaces détectées
show interfaces

# 2. Configurer le hostname
configure
set system host-name vyos-router
set system domain-name lab.local
commit
save

# 3. Configurer le fuseau horaire
configure
set system time-zone Europe/Paris
commit
save

# 4. Configurer NTP
configure
set system ntp server 0.fr.pool.ntp.org
set system ntp server 1.fr.pool.ntp.org
commit
save

# 5. Tester la connectivité
ping 8.8.8.8
ping google.com
```

### Dépannage spécifique Proxmox

#### Interface non détectée

```bash
# Vérifier dans VyOS
show interfaces
ip link show

# Redémarrer la VM depuis Proxmox
qm stop 100
qm start 100
```

#### Problème de performances réseau

```bash
# Vérifier le type de driver réseau dans Proxmox
qm config 100 | grep net

# Doit afficher "virtio" et non "e1000" ou "rtl8139"
# Si ce n'est pas le cas, changer :
qm set 100 --net0 virtio,bridge=vmbr0
```

#### VLANs qui ne fonctionnent pas

```bash
# 1. Vérifier que le bridge Proxmox est VLAN-aware
cat /etc/network/interfaces | grep -A5 vmbr1

# 2. Vérifier les VLAN tags dans VyOS
show interfaces ethernet eth1 vif

# 3. S'assurer de ne pas utiliser le VLAN 1 (problèmes courants)
show interfaces | grep "vif 1"

# 4. Tester la connectivité VLAN par VLAN
ping -I eth1.10 10.0.10.2
```

> [!tip] Dépannage VLAN 1 Si vous avez hérité d'une config avec VLAN 1 et que ça ne fonctionne pas :
> 
> ```bash
> configure
> # Migrer vers VLAN 10 (ou autre)
> delete interfaces ethernet eth1 vif 1
> set interfaces ethernet eth1 vif 10 address '10.0.10.1/24'
> commit
> save
> ```

---

## 🎯 Pièges courants et solutions

### Oublier de sauvegarder

**Problème :** Modifications commitées mais perdues au reboot.

**Solution :**

```bash
# Toujours terminer par save
commit
save
```

### Interface désactivée par défaut

**Problème :** Interface configurée mais pas de connectivité.

**Solution :**

```bash
# Supprimer le flag disable
delete interfaces ethernet eth0 disable
commit
```

### MTU VLAN supérieur à l'interface parent

**Problème :** Fragmentation ou perte de paquets.

**Solution :**

```bash
# MTU parent >= MTU VLAN + overhead (4 bytes pour 802.1Q)
set interfaces ethernet eth0 mtu 1504
set interfaces ethernet eth0 vif 10 mtu 1500
```

### Utilisation du VLAN 1

**Problème :** Risque de sécurité, attaques VLAN hopping, problèmes de compatibilité.

**Solution :**

```bash
# Ne JAMAIS utiliser VLAN 1 - migrer immédiatement
configure

# Si vous avez VLAN 1, le supprimer et recréer
delete interfaces ethernet eth0 vif 1

# Utiliser VLAN 10 minimum
set interfaces ethernet eth0 vif 10 address '10.0.10.1/24'
set interfaces ethernet eth0 vif 10 description 'Management (ex-VLAN 1)'

commit
save
```

> [!warning] Pourquoi éviter VLAN 1
> 
> - **Sécurité** : VLAN par défaut = cible privilégiée des attaques
> - **Protocoles Layer 2** : CDP, VTP, DTP transitent en VLAN 1 par défaut
> - **VLAN hopping** : Double tagging attack exploite le VLAN 1
> - **Isolation** : Difficulté à isoler complètement le trafic management

### Routes conflictuelles

**Problème :** Plusieurs routes vers la même destination avec métriques identiques.

**Solution :**

```bash
# Utiliser des métriques différentes ou ECMP intentionnel
set protocols static route 10.0.0.0/24 next-hop 192.168.1.1 distance 10
set protocols static route 10.0.0.0/24 next-hop 192.168.1.2 distance 20
```

### VyOS lent sur Proxmox

**Problème :** Interface web lente, commandes qui traînent.

**Solution :**

```bash
# 1. Augmenter la RAM de la VM (2GB → 4GB)
# 2. Ajouter des CPU cores
# 3. Vérifier que VirtIO est utilisé
# 4. Activer l'entropy generator
configure
set system option random-device /dev/urandom
commit
save
```

### Configuration non commitée

**Problème :** Modifications visibles dans `show` mais pas actives.

**Solution :**

```bash
# Vérifier et commiter
compare
commit
```

### Modification de paramètres existants

#### Changer une adresse IP

```bash
configure

# MÉTHODE 1 : Supprimer puis recréer
delete interfaces ethernet eth0 address '192.168.1.1/24'
set interfaces ethernet eth0 address '192.168.2.1/24'

# MÉTHODE 2 : Simplement ajouter (multihome)
set interfaces ethernet eth0 address '192.168.2.1/24'
# Les deux IPs coexisteront

commit
save
```

#### Changer une passerelle par défaut

```bash
configure

# Supprimer l'ancienne route
delete protocols static route 0.0.0.0/0 next-hop 192.168.1.254

# Ajouter la nouvelle
set protocols static route 0.0.0.0/0 next-hop 192.168.1.1

commit
save
```

#### Modifier un VLAN ID

```bash
configure

# Impossible de modifier directement, il faut supprimer et recréer
delete interfaces ethernet eth1 vif 10
set interfaces ethernet eth1 vif 20 address '10.0.20.1/24'
set interfaces ethernet eth1 vif 20 description 'Nouveau VLAN 20'

commit
save
```

> [!warning] Attention aux services actifs La suppression d'une interface coupera toutes les connexions actives sur cette interface !

#### Changer un MTU

```bash
configure

# Modification directe possible
set interfaces ethernet eth0 mtu 9000

commit
save
```

### Suppression d'éléments de configuration

#### Supprimer une interface complète

```bash
configure

# Supprimer toute la config d'une interface
delete interfaces ethernet eth2

commit
save
```

#### Supprimer un VLAN spécifique

```bash
configure

# Supprimer un VLAN
delete interfaces ethernet eth1 vif 30

commit
save
```

#### Supprimer une route

```bash
configure

# Supprimer une route spécifique
delete protocols static route 10.50.0.0/24

# Supprimer seulement un next-hop d'une route (si plusieurs)
delete protocols static route 10.50.0.0/24 next-hop 192.168.1.10

commit
save
```

#### Supprimer toutes les routes statiques

```bash
configure

# ATTENTION : Ceci supprime TOUTES les routes y compris la route par défaut !
delete protocols static route

commit
save
```

> [!warning] Impact de la suppression Avant de supprimer des routes, assurez-vous de ne pas vous couper l'accès SSH/Console !

#### Nettoyer une configuration avant reconfiguration

```bash
configure

# Supprimer toute la config réseau d'une interface
delete interfaces ethernet eth3 address
delete interfaces ethernet eth3 description
delete interfaces ethernet eth3 vif

# L'interface existe toujours mais sans config
commit
save
```

### Réinitialisation sélective

#### Reset d'une interface à zéro

```bash
configure

# Supprimer complètement l'interface
delete interfaces ethernet eth2

# Reconfigurer depuis le début
set interfaces ethernet eth2 address '10.0.2.1/24'
set interfaces ethernet eth2 description 'Interface réinitialisée'

commit
save
```

#### Reset du routage complet

```bash
configure

# Supprimer tous les protocoles de routage
delete protocols

# Reconfigurer seulement ce qui est nécessaire
set protocols static route 0.0.0.0/0 next-hop 192.168.1.254

commit
save
```

---

## 📋 Commandes de modification rapide

### Visualiser avant de supprimer

```bash
configure

# Voir ce qui sera supprimé
show interfaces ethernet eth2

# Puis supprimer
delete interfaces ethernet eth2
```

### Modifier avec confirmation

```bash
configure

# Faire les modifications
delete protocols static route 0.0.0.0/0
set protocols static route 0.0.0.0/0 next-hop 192.168.1.1

# Vérifier avant de valider
compare

# Commit avec rollback automatique si problème
commit-confirm 2

# Tester la connectivité
exit
ping 8.8.8.8

# Si OK, confirmer
configure
confirm

# Sinon, attendre 2 minutes et ça rollback automatiquement
```

### Copier/modifier une config existante

```bash
configure

# Copier la config d'eth0 vers eth1
copy interfaces ethernet eth0 to interfaces ethernet eth1

# Modifier seulement l'IP
set interfaces ethernet eth1 address '10.0.1.1/24'

commit
save
```

---

## 🔄 Scénarios de modification courants

### Changer le schéma d'adressage IP

```bash
configure

# Ancien : 192.168.1.0/24
# Nouveau : 10.0.1.0/24

# Supprimer l'ancienne IP
delete interfaces ethernet eth1 address '192.168.1.1/24'

# Ajouter la nouvelle
set interfaces ethernet eth1 address '10.0.1.1/24'

# Mettre à jour les routes qui dépendent de cette interface
delete protocols static route 192.168.10.0/24 next-hop 192.168.1.254
set protocols static route 10.0.10.0/24 next-hop 10.0.1.254

commit
save
```

### Migrer d'un VLAN simple à un trunk VLAN

```bash
configure

# Configuration initiale : interface simple
# eth1 : 192.168.1.1/24

# Supprimer l'IP de l'interface physique
delete interfaces ethernet eth1 address

# Créer les VLANs
set interfaces ethernet eth1 vif 10 address '10.0.10.1/24'
set interfaces ethernet eth1 vif 10 description 'VLAN 10 - Serveurs'
set interfaces ethernet eth1 vif 20 address '10.0.20.1/24'
set interfaces ethernet eth1 vif 20 description 'VLAN 20 - Clients'

# Mettre à jour la description de l'interface physique
set interfaces ethernet eth1 description 'VLAN Trunk'

commit
save
```

### Passer de DHCP à IP statique

```bash
configure

# Supprimer DHCP
delete interfaces ethernet eth0 address dhcp
delete interfaces ethernet eth0 dhcp-options

# Configurer IP statique
set interfaces ethernet eth0 address '192.168.1.100/24'

# Ajouter route par défaut (que DHCP fournissait automatiquement)
set protocols static route 0.0.0.0/0 next-hop 192.168.1.1

# Ajouter DNS (que DHCP fournissait automatiquement)
set system name-server 8.8.8.8
set system name-server 8.8.4.4

commit
save
```

---

## ✨ Astuces de productivité

### Autocomplétion

```bash
# Utiliser Tab pour compléter
set inter[TAB]  # → set interfaces
set interfaces e[TAB]  # → set interfaces ethernet
```

### Aide contextuelle

```bash
# Utiliser ? pour voir les options
set interfaces ?
set interfaces ethernet eth0 ?
```

### Copier des configurations

```bash
configure

# Copier une configuration d'interface
copy interfaces ethernet eth0 to interfaces ethernet eth3

commit
```

### Templates de configuration

```bash
# Créer un template réutilisable
configure

edit interfaces ethernet eth0
set address 192.168.1.1/24
set description 'Template LAN'
top

# Copier pour d'autres interfaces
copy interfaces ethernet eth0 to interfaces ethernet eth2
set interfaces ethernet eth2 address 192.168.2.1/24
```

### Recherche dans la configuration

```bash
# Chercher une valeur dans la config
show configuration | grep "192.168"

# Chercher dans les commands
show configuration commands | grep vif
```

---

**🎓 Fin du cours VyOS - Configuration**