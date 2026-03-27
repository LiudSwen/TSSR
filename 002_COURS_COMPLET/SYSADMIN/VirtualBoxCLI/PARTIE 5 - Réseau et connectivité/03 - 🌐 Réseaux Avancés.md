

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

## 🎯 Introduction aux réseaux avancés

Les réseaux avancés dans VirtualBox permettent de créer des topologies réseau complexes et réalistes pour vos machines virtuelles. Contrairement aux modes réseau simples (NAT, Bridged), ces fonctionnalités offrent un contrôle granulaire sur l'infrastructure réseau.

> [!info] Pourquoi utiliser les réseaux avancés ?
> 
> - **Isolation** : Créer des environnements réseau séparés et sécurisés
> - **Communication inter-VM** : Permettre à plusieurs VMs de communiquer entre elles tout en restant isolées de l'hôte
> - **Simulation** : Reproduire des architectures réseau d'entreprise pour des tests
> - **Flexibilité** : Combiner différents modes réseau sur une même VM

---

## 🔀 NAT Network - Réseaux NAT partagés

### Concept et utilité

Un **NAT Network** est un réseau virtuel privé où plusieurs VMs peuvent communiquer entre elles et accéder à Internet via une passerelle NAT commune. C'est l'équivalent d'un routeur domestique pour vos VMs.

> [!tip] Quand utiliser NAT Network ?
> 
> - Vous avez plusieurs VMs qui doivent communiquer entre elles
> - Vous voulez qu'elles aient accès à Internet
> - Vous voulez les isoler du réseau hôte
> - Vous voulez une configuration simple sans pont réseau

### Différence avec NAT simple

|Caractéristique|NAT simple|NAT Network|
|---|---|---|
|Communication inter-VM|❌ Non|✅ Oui|
|Accès Internet|✅ Oui|✅ Oui|
|Réseau partagé|❌ Chaque VM isolée|✅ Réseau commun|
|Configuration DHCP|✅ Auto|✅ Personnalisable|

### Création d'un NAT Network

```bash
# Créer un nouveau réseau NAT
VBoxManage natnetwork add \
  --netname "MonReseauNAT" \
  --network "10.0.2.0/24" \
  --enable

# Options courantes :
# --netname     : Nom du réseau (obligatoire)
# --network     : Plage d'adresses IP en notation CIDR
# --enable      : Active le réseau immédiatement
# --dhcp on/off : Active/désactive le DHCP (on par défaut)
```

> [!example] Exemple de création avec DHCP désactivé
> 
> ```bash
> VBoxManage natnetwork add \
>   --netname "ReseauLab" \
>   --network "192.168.100.0/24" \
>   --enable \
>   --dhcp off
> ```

### Modification d'un NAT Network

```bash
# Modifier la plage réseau
VBoxManage natnetwork modify \
  --netname "MonReseauNAT" \
  --network "10.0.3.0/24"

# Activer/désactiver le DHCP
VBoxManage natnetwork modify \
  --netname "MonReseauNAT" \
  --dhcp on

# Activer/désactiver l'IPv6
VBoxManage natnetwork modify \
  --netname "MonReseauNAT" \
  --ipv6 on

# Désactiver temporairement le réseau
VBoxManage natnetwork modify \
  --netname "MonReseauNAT" \
  --disable
```

### Port Forwarding sur NAT Network

```bash
# Ajouter une règle de port forwarding
VBoxManage natnetwork modify \
  --netname "MonReseauNAT" \
  --port-forward-4 "ssh:tcp:[]:2222:[10.0.2.5]:22"

# Format de la règle :
# "nom:protocole:[IP_hôte]:port_hôte:[IP_VM]:port_VM"

# Supprimer une règle
VBoxManage natnetwork modify \
  --netname "MonReseauNAT" \
  --port-forward-4 delete ssh
```

> [!warning] Attention aux conflits Les règles de port forwarding sur NAT Network s'appliquent à toutes les VMs du réseau. Assurez-vous que les IPs internes sont correctes.

### Lister et supprimer des NAT Networks

```bash
# Lister tous les réseaux NAT
VBoxManage natnetwork list

# Afficher les détails d'un réseau spécifique
VBoxManage natnetwork list "MonReseauNAT"

# Supprimer un réseau NAT
VBoxManage natnetwork remove --netname "MonReseauNAT"
```

### Attacher une VM à un NAT Network

```bash
# Configurer l'adaptateur réseau d'une VM
VBoxManage modifyvm "MaVM" \
  --nic1 natnetwork \
  --nat-network1 "MonReseauNAT"

# --nic1 natnetwork  : Définit le type de réseau
# --nat-network1     : Spécifie quel NAT Network utiliser
```

> [!tip] Astuce : Combinaison d'adaptateurs Vous pouvez avoir plusieurs adaptateurs réseau. Par exemple, nic1 en NAT Network pour la communication inter-VM, et nic2 en Host-Only pour l'accès depuis l'hôte.

---

## 🏠 Host-Only Network - Interfaces isolées

### Concept et utilité

Un **Host-Only Network** crée un réseau virtuel privé entre l'hôte et les VMs. Les VMs peuvent communiquer entre elles et avec l'hôte, mais **n'ont pas accès à Internet**.

> [!info] Quand utiliser Host-Only ?
> 
> - Environnement de développement local sécurisé
> - Tests réseau sans accès Internet
> - Communication directe hôte ↔ VMs
> - Isolation totale du réseau externe

### Création d'une interface Host-Only

```bash
# Créer une nouvelle interface host-only
VBoxManage hostonlyif create

# VirtualBox génère automatiquement un nom (ex: vboxnet0, vboxnet1...)
# Exemple de sortie :
# Interface 'vboxnet0' was successfully created
```

### Configuration d'une interface Host-Only

```bash
# Configurer l'adresse IP de l'interface
VBoxManage hostonlyif ipconfig vboxnet0 \
  --ip 192.168.56.1 \
  --netmask 255.255.255.0

# Avec notation CIDR (équivalent)
VBoxManage hostonlyif ipconfig vboxnet0 \
  --ip 192.168.56.1/24

# Configurer IPv6 (optionnel)
VBoxManage hostonlyif ipconfig vboxnet0 \
  --ipv6 fd00::1/64
```

> [!warning] Attention à la cohérence réseau L'adresse IP de l'interface host-only doit être dans la même plage que celle configurée pour le serveur DHCP si vous en utilisez un.

### Lister les interfaces Host-Only

```bash
# Lister toutes les interfaces host-only
VBoxManage list hostonlyifs

# Sortie typique :
# Name:            vboxnet0
# GUID:            786f6276-656e-4074-8000-0a0027000000
# DHCP:            Disabled
# IPAddress:       192.168.56.1
# NetworkMask:     255.255.255.0
# IPV6Address:     
# IPV6NetworkMaskPrefixLength: 0
# Status:          Up
```

### Supprimer une interface Host-Only

```bash
# Supprimer une interface host-only
VBoxManage hostonlyif remove vboxnet0
```

> [!tip] Gestion automatique VirtualBox peut créer automatiquement une interface host-only par défaut (vboxnet0 sur Linux/macOS, VirtualBox Host-Only Network sur Windows) lors de la première utilisation.

### Attacher une VM à un réseau Host-Only

```bash
# Configurer l'adaptateur réseau
VBoxManage modifyvm "MaVM" \
  --nic1 hostonly \
  --hostonlyadapter1 vboxnet0

# --nic1 hostonly        : Type de réseau
# --hostonlyadapter1     : Quelle interface utiliser
```

### Configuration IP manuelle dans la VM

Contrairement au NAT, vous devrez souvent configurer l'IP manuellement dans la VM ou utiliser un serveur DHCP.

```bash
# Exemple de configuration manuelle (dans la VM Linux)
sudo ip addr add 192.168.56.10/24 dev enp0s3
sudo ip link set enp0s3 up

# Pour rendre permanent (Ubuntu/Debian avec Netplan)
# Éditer /etc/netplan/01-netcfg.yaml :
# network:
#   version: 2
#   ethernets:
#     enp0s3:
#       addresses: [192.168.56.10/24]
```

---

## 🔌 Port Forwarding en NAT

### Concept et utilité

Le **Port Forwarding** (redirection de ports) permet de rendre accessible un service tournant dans une VM en NAT depuis l'hôte ou le réseau externe. C'est essentiel car le NAT simple isole complètement la VM.

> [!info] Cas d'usage typiques
> 
> - Accéder à un serveur web dans une VM (port 80/443)
> - SSH vers une VM (port 22)
> - Connexion à une base de données (port 3306, 5432...)
> - Accès à des APIs de développement

### Syntaxe de base

```bash
VBoxManage modifyvm "MaVM" \
  --natpf1 "nom,protocole,ip_hote,port_hote,ip_vm,port_vm"

# Paramètres :
# nom        : Nom de la règle (libre)
# protocole  : tcp ou udp
# ip_hote    : IP de l'interface hôte (vide = toutes)
# port_hote  : Port sur l'hôte
# ip_vm      : IP de la VM (vide = auto)
# port_vm    : Port dans la VM
```

### Exemples pratiques

```bash
# SSH : Rediriger le port 2222 de l'hôte vers le port 22 de la VM
VBoxManage modifyvm "MaVM" \
  --natpf1 "ssh,tcp,,2222,,22"

# HTTP : Rediriger le port 8080 de l'hôte vers le port 80 de la VM
VBoxManage modifyvm "MaVM" \
  --natpf1 "web,tcp,,8080,,80"

# MySQL : Rediriger le port 3307 vers le port 3306
VBoxManage modifyvm "MaVM" \
  --natpf1 "mysql,tcp,,3307,,3306"

# HTTPS avec IP spécifique de l'hôte
VBoxManage modifyvm "MaVM" \
  --natpf1 "https,tcp,127.0.0.1,8443,,443"
```

> [!example] Configuration complète d'un serveur web
> 
> ```bash
> # HTTP
> VBoxManage modifyvm "WebServer" --natpf1 "http,tcp,,8080,,80"
> # HTTPS
> VBoxManage modifyvm "WebServer" --natpf1 "https,tcp,,8443,,443"
> # SSH pour administration
> VBoxManage modifyvm "WebServer" --natpf1 "ssh,tcp,,2222,,22"
> ```

### Gestion dynamique (VM en cours d'exécution)

```bash
# Ajouter une règle sur une VM en cours d'exécution
VBoxManage controlvm "MaVM" \
  natpf1 "ssh,tcp,,2222,,22"

# Supprimer une règle sur une VM en cours d'exécution
VBoxManage controlvm "MaVM" \
  natpf1 delete ssh
```

### Lister les règles de port forwarding

```bash
# Afficher les règles d'une VM
VBoxManage showvminfo "MaVM" | grep "NIC 1 Rule"

# Sortie typique :
# NIC 1 Rule(0):   name = ssh, protocol = tcp, host ip = , host port = 2222, guest ip = , guest port = 22
```

### Supprimer une règle de port forwarding

```bash
# Méthode 1 : Supprimer par nom
VBoxManage modifyvm "MaVM" \
  --natpf1 delete ssh

# Méthode 2 : Sur une VM en cours d'exécution
VBoxManage controlvm "MaVM" \
  natpf1 delete ssh
```

> [!warning] Pièges courants
> 
> - **Ports privilégiés** : Sur l'hôte Linux/macOS, les ports < 1024 nécessitent root
> - **Conflits de ports** : Vérifiez qu'aucun service n'utilise déjà le port hôte
> - **Firewall** : Assurez-vous que le firewall de l'hôte autorise le port
> - **VM éteinte** : Utilisez `modifyvm` pour les VMs éteintes, `controlvm` pour les VMs en cours d'exécution

### Bonnes pratiques

> [!tip] Recommandations
> 
> - **Nommage clair** : Utilisez des noms descriptifs pour vos règles (ssh-vm1, web-prod...)
> - **Ports non-standards** : Utilisez des ports > 1024 sur l'hôte pour éviter les problèmes de permissions
> - **Documentation** : Gardez une liste des ports utilisés pour éviter les conflits
> - **Sécurité** : N'exposez que les ports nécessaires, utilisez `127.0.0.1` pour limiter l'accès à l'hôte local

---

## 🖥️ DHCP Server - Serveur DHCP intégré

### Concept et utilité

VirtualBox intègre un **serveur DHCP** qui peut attribuer automatiquement des adresses IP aux VMs sur un réseau NAT Network ou Host-Only. Cela évite la configuration manuelle des IPs dans chaque VM.

> [!info] Pourquoi utiliser le DHCP intégré ?
> 
> - **Automatisation** : Plus besoin de configurer manuellement les IPs
> - **Flexibilité** : Attribution dynamique ou réservations statiques
> - **Simplicité** : Géré directement par VirtualBox
> - **Cohérence** : Évite les conflits d'adresses IP

### DHCP pour NAT Network

Par défaut, un NAT Network a le DHCP activé. Vous pouvez le personnaliser :

```bash
# Créer un NAT Network avec DHCP activé (par défaut)
VBoxManage natnetwork add \
  --netname "MonReseauNAT" \
  --network "10.0.2.0/24" \
  --enable \
  --dhcp on

# Désactiver le DHCP sur un NAT Network existant
VBoxManage natnetwork modify \
  --netname "MonReseauNAT" \
  --dhcp off
```

### DHCP pour Host-Only Network

Le serveur DHCP pour Host-Only doit être configuré explicitement :

```bash
# Ajouter un serveur DHCP à une interface host-only
VBoxManage dhcpserver add \
  --interface vboxnet0 \
  --server-ip 192.168.56.100 \
  --netmask 255.255.255.0 \
  --lower-ip 192.168.56.101 \
  --upper-ip 192.168.56.254 \
  --enable

# Paramètres :
# --interface  : Interface host-only concernée
# --server-ip  : IP du serveur DHCP lui-même
# --netmask    : Masque de sous-réseau
# --lower-ip   : Début de la plage d'attribution
# --upper-ip   : Fin de la plage d'attribution
# --enable     : Active le serveur immédiatement
```

> [!example] Configuration typique
> 
> ```bash
> # Interface host-only : 192.168.56.1
> # Serveur DHCP : 192.168.56.100
> # Plage clients : 192.168.56.101 - 192.168.56.200
> 
> VBoxManage dhcpserver add \
>   --interface vboxnet0 \
>   --server-ip 192.168.56.100 \
>   --netmask 255.255.255.0 \
>   --lower-ip 192.168.56.101 \
>   --upper-ip 192.168.56.200 \
>   --enable
> ```

### Modification d'un serveur DHCP

```bash
# Modifier la plage d'attribution
VBoxManage dhcpserver modify \
  --interface vboxnet0 \
  --lower-ip 192.168.56.50 \
  --upper-ip 192.168.56.150

# Changer l'IP du serveur DHCP
VBoxManage dhcpserver modify \
  --interface vboxnet0 \
  --server-ip 192.168.56.254

# Activer/désactiver
VBoxManage dhcpserver modify \
  --interface vboxnet0 \
  --enable

VBoxManage dhcpserver modify \
  --interface vboxnet0 \
  --disable
```

### Options DHCP avancées

```bash
# Configurer la passerelle par défaut (gateway)
VBoxManage dhcpserver modify \
  --interface vboxnet0 \
  --options 3:192.168.56.1

# Configurer les serveurs DNS
VBoxManage dhcpserver modify \
  --interface vboxnet0 \
  --options 6:8.8.8.8,8.8.4.4

# Configurer le temps de bail (lease time) en secondes
VBoxManage dhcpserver modify \
  --interface vboxnet0 \
  --options 51:3600

# Codes d'options DHCP courantes :
# 3  : Routeur/Gateway
# 6  : Serveurs DNS
# 15 : Nom de domaine
# 51 : Lease time
```

### Réservations IP (adresses statiques)

```bash
# Réserver une IP pour une adresse MAC spécifique
VBoxManage dhcpserver modify \
  --interface vboxnet0 \
  --fixed-address 192.168.56.50 \
  --mac-address 08:00:27:12:34:56

# Supprimer une réservation
VBoxManage dhcpserver modify \
  --interface vboxnet0 \
  --del-fixed-address 192.168.56.50
```

> [!tip] Trouver l'adresse MAC d'une VM
> 
> ```bash
> VBoxManage showvminfo "MaVM" | grep "NIC 1"
> # Recherchez la ligne "MAC: ..."
> ```

### Lister les serveurs DHCP

```bash
# Lister tous les serveurs DHCP configurés
VBoxManage list dhcpservers

# Sortie typique :
# NetworkName:    HostInterfaceNetworking-vboxnet0
# Dhcpd IP:       192.168.56.100
# LowerIPAddress: 192.168.56.101
# UpperIPAddress: 192.168.56.254
# NetworkMask:    255.255.255.0
# Enabled:        Yes
# Global Configuration:
#     minLeaseTime:     default
#     defaultLeaseTime: default
#     maxLeaseTime:     default
```

### Supprimer un serveur DHCP

```bash
# Supprimer un serveur DHCP
VBoxManage dhcpserver remove --interface vboxnet0

# Ou pour un NAT Network
VBoxManage dhcpserver remove --netname "MonReseauNAT"
```

> [!warning] Désactivation vs Suppression
> 
> - **Disable** : Le serveur DHCP reste configuré mais n'attribue plus d'IPs
> - **Remove** : Supprime complètement la configuration du serveur DHCP

### Dépannage DHCP

> [!tip] Vérifications en cas de problème
> 
> ```bash
> # 1. Vérifier que le serveur DHCP est activé
> VBoxManage list dhcpservers | grep -A 10 vboxnet0
> 
> # 2. Vérifier la configuration de l'adaptateur réseau de la VM
> VBoxManage showvminfo "MaVM" | grep "NIC 1"
> 
> # 3. Dans la VM, vérifier la réception DHCP (Linux)
> sudo dhclient -v enp0s3
> # ou
> sudo dhcpcd enp0s3
> 
> # 4. Vérifier l'IP attribuée
> ip addr show enp0s3
> ```

---

## 📊 Comparaison des modes réseau

### Tableau récapitulatif

|Fonctionnalité|NAT simple|NAT Network|Host-Only|Bridged|
|---|---|---|---|---|
|Accès Internet|✅ Oui|✅ Oui|❌ Non|✅ Oui|
|Communication inter-VM|❌ Non|✅ Oui|✅ Oui|✅ Oui|
|Visible depuis l'hôte|⚠️ Port Forward|⚠️ Port Forward|✅ Oui|✅ Oui|
|Visible depuis réseau externe|❌ Non|❌ Non|❌ Non|✅ Oui|
|Configuration IP|🔄 DHCP auto|🔄 DHCP custom|⚙️ Manuelle/DHCP|🔄 Réseau externe|
|Isolation|✅ Haute|⚙️ Moyenne|✅ Haute|❌ Aucune|

### Guide de choix

> [!tip] Quel mode choisir ?
> 
> **NAT simple** :
> 
> - VM unique qui a juste besoin d'Internet
> - Isolation maximale
> - Accès aux services via port forwarding
> 
> **NAT Network** :
> 
> - Plusieurs VMs qui doivent communiquer
> - Accès Internet nécessaire
> - Simulation d'un réseau d'entreprise isolé
> 
> **Host-Only** :
> 
> - Développement local sécurisé
> - Accès direct hôte ↔ VMs
> - Aucun besoin d'Internet dans les VMs
> - Tests réseau en environnement isolé
> 
> **Bridged** (non couvert en détail ici) :
> 
> - VM doit être visible comme une machine physique sur le réseau
> - Besoin d'une IP du réseau local
> - Accès direct depuis d'autres machines du réseau

### Combinaisons courantes

```bash
# Développement web : NAT + Host-Only
VBoxManage modifyvm "DevVM" --nic1 nat --natpf1 "ssh,tcp,,2222,,22"
VBoxManage modifyvm "DevVM" --nic2 hostonly --hostonlyadapter2 vboxnet0

# Cluster de VMs : NAT Network
VBoxManage modifyvm "Node1" --nic1 natnetwork --nat-network1 "ClusterNet"
VBoxManage modifyvm "Node2" --nic1 natnetwork --nat-network1 "ClusterNet"
VBoxManage modifyvm "Node3" --nic1 natnetwork --nat-network1 "ClusterNet"

# Lab sécurisé avec accès admin : Host-Only + NAT
VBoxManage modifyvm "LabVM" --nic1 hostonly --hostonlyadapter1 vboxnet0
VBoxManage modifyvm "LabVM" --nic2 nat
```

> [!info] Bonnes pratiques générales
> 
> - **Nommage cohérent** : Utilisez des noms descriptifs pour vos réseaux (prod-net, dev-net, lab-net...)
> - **Documentation** : Gardez un schéma de votre topologie réseau
> - **Sécurité** : Appliquez le principe du moindre privilège (accès minimum nécessaire)
> - **Flexibilité** : N'hésitez pas à combiner plusieurs adaptateurs réseau sur une même VM
> - **Tests** : Testez toujours votre configuration avec `ping`, `ssh`, etc.

---

## 🎓 Résumé des commandes essentielles

```bash
# ===== NAT NETWORK =====
# Créer
VBoxManage natnetwork add --netname "Net" --network "10.0.2.0/24" --enable
# Modifier
VBoxManage natnetwork modify --netname "Net" --dhcp on
# Lister
VBoxManage natnetwork list
# Supprimer
VBoxManage natnetwork remove --netname "Net"

# ===== HOST-ONLY =====
# Créer interface
VBoxManage hostonlyif create
# Configurer IP
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1/24
# Lister
VBoxManage list hostonlyifs
# Supprimer
VBoxManage hostonlyif remove vboxnet0

# ===== PORT FORWARDING =====
# Ajouter règle (VM éteinte)
VBoxManage modifyvm "VM" --natpf1 "ssh,tcp,,2222,,22"
# Ajouter règle (VM en cours)
VBoxManage controlvm "VM" natpf1 "ssh,tcp,,2222,,22"
# Supprimer règle
VBoxManage modifyvm "VM" --natpf1 delete ssh

# ===== DHCP SERVER =====
# Ajouter serveur DHCP
VBoxManage dhcpserver add --interface vboxnet0 \
  --server-ip 192.168.56.100 --netmask 255.255.255.0 \
  --lower-ip 192.168.56.101 --upper-ip 192.168.56.254 --enable
# Modifier
VBoxManage dhcpserver modify --interface vboxnet0 --lower-ip 192.168.56.50
# Lister
VBoxManage list dhcpservers
# Supprimer
VBoxManage dhcpserver remove --interface vboxnet0

# ===== ATTACHER VM À RÉSEAU =====
# NAT Network
VBoxManage modifyvm "VM" --nic1 natnetwork --nat-network1 "MonReseauNAT"
# Host-Only
VBoxManage modifyvm "VM" --nic1 hostonly --hostonlyadapter1 vboxnet0
```

---

**📌 Note finale** : Les réseaux avancés de VirtualBox offrent une flexibilité remarquable pour créer des environnements de test, développement ou formation. Maîtriser ces concepts vous permettra de simuler des architectures réseau complexes et de mieux comprendre les fondamentaux du réseau.