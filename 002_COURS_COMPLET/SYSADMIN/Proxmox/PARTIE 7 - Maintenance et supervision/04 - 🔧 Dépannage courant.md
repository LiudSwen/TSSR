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

## 🎯 Introduction au dépannage

Le dépannage dans Proxmox nécessite une approche méthodique pour identifier rapidement la source des problèmes. Les incidents les plus courants concernent le démarrage des VMs, la connectivité réseau, les erreurs de stockage et l'accès à l'interface web.

> [!info] Philosophie de dépannage Toujours procéder du général au spécifique : vérifier d'abord l'état global du système (ressources, services), puis se concentrer sur l'élément défaillant.

### 🔍 Outils de diagnostic essentiels

|Outil|Commande|Usage|
|---|---|---|
|Logs système|`journalctl -xe`|Erreurs système récentes|
|Logs VM|`qm showcmd <VMID>`|Configuration et commande QEMU|
|État des services|`systemctl status pve*`|Vérifier les services Proxmox|
|Ressources|`pvesh get /nodes/$(hostname)/status`|État CPU/RAM/Stockage|

---

## 🚫 VM qui ne démarre pas

### Symptômes et causes courantes

Une VM qui refuse de démarrer peut avoir plusieurs origines : configuration incorrecte, ressources insuffisantes, problèmes de disque ou de verrouillage.

> [!warning] Vérifications préliminaires Avant toute intervention, vérifiez que le nœud Proxmox dispose de ressources suffisantes (RAM, CPU) et que les services sont actifs.

### Diagnostic étape par étape

#### 1️⃣ Vérifier l'état de la VM

```bash
# Vérifier le statut de la VM
qm status <VMID>

# Afficher la configuration complète
qm config <VMID>

# Vérifier les processus en cours
ps aux | grep <VMID>
```

#### 2️⃣ Examiner les logs

```bash
# Logs de démarrage de la VM
tail -f /var/log/pve/qemu-server/<VMID>.log

# Logs système pour erreurs QEMU
journalctl -u qemu-server@<VMID>.service -xe

# Historique des tâches dans l'interface
# Menu : Datacenter > Tasks
```

> [!example] Exemple de log d'erreur courante
> 
> ```
> kvm: -drive file=/dev/pve/vm-100-disk-0: Could not open backing file: Permission denied
> ```
> 
> Cette erreur indique un problème de permissions ou de verrouillage sur le disque.

### Solutions aux problèmes fréquents

#### 🔒 Problème de verrouillage (Lock)

```bash
# Vérifier si la VM est verrouillée
qm status <VMID>

# Déverrouiller la VM (si le processus est terminé)
qm unlock <VMID>

# Forcer l'arrêt d'une VM bloquée
qm stop <VMID> --skiplock 1
```

> [!warning] Attention au skiplock N'utilisez `--skiplock` que si vous êtes certain qu'aucun processus n'utilise la VM, sinon risque de corruption.

#### 💾 Disque introuvable ou corrompu

```bash
# Lister les disques de la VM
qm config <VMID> | grep -E "scsi|ide|virtio"

# Vérifier l'existence du volume
lvs | grep vm-<VMID>

# Pour stockage local-lvm
lvdisplay /dev/pve/vm-<VMID>-disk-0

# Recréer un disque perdu (backup nécessaire)
qm set <VMID> --scsi0 local-lvm:32
```

#### ⚙️ Configuration BIOS/UEFI incompatible

```bash
# Vérifier le type de BIOS
qm config <VMID> | grep bios

# Changer en UEFI (si nécessaire)
qm set <VMID> --bios ovmf

# Ou revenir en SeaBIOS
qm set <VMID> --bios seabios

# Ajouter un disque EFI pour UEFI
qm set <VMID> --efidisk0 local-lvm:1,format=raw
```

> [!tip] Compatibilité BIOS Windows 11 et les distributions Linux récentes nécessitent généralement UEFI. Les anciennes VMs utilisent SeaBIOS.

#### 🧠 RAM insuffisante sur le nœud

```bash
# Vérifier la RAM disponible
free -h

# Voir l'allocation mémoire des VMs
qm list | awk '{sum+=$4} END {print "Total RAM allouée: " sum/1024 " GB"}'

# Réduire temporairement la RAM de la VM
qm set <VMID> --memory 2048

# Activer le ballooning (ajustement dynamique)
qm set <VMID> --balloon 1024
```

#### 🔌 Périphérique manquant

```bash
# Vérifier les périphériques PCI/USB passthrough
qm config <VMID> | grep -E "hostpci|usb"

# Lister les périphériques PCI disponibles
lspci -nn

# Retirer temporairement un périphérique manquant
qm set <VMID> --delete hostpci0
```

### 🛠️ Démarrage en mode debug

```bash
# Démarrer la VM avec affichage des erreurs détaillées
qm start <VMID> --debug

# Afficher la commande QEMU complète utilisée
qm showcmd <VMID>

# Tester manuellement le démarrage (avancé)
# Copier la commande de showcmd et l'exécuter avec modifications
```

> [!tip] Astuces de diagnostic
> 
> - Essayez de démarrer la VM avec un ISO de rescue monté pour vérifier le matériel virtuel
> - Désactivez temporairement les agents (QEMU guest agent) avec `qm set <VMID> --agent 0`
> - Testez avec une configuration minimale (1 CPU, 1 GB RAM, 1 disque)

---

## 🌐 Problèmes de réseau

### Types de problèmes réseau

Les problèmes réseau dans Proxmox peuvent affecter les VMs, les conteneurs ou l'accès au nœud lui-même. Ils sont souvent liés à la configuration des bridges, VLANs ou pare-feu.

### Diagnostic réseau global

#### 🔍 Vérifier l'état des interfaces

```bash
# Lister toutes les interfaces réseau
ip addr show

# État des bridges
brctl show

# Configuration réseau Proxmox
cat /etc/network/interfaces

# Tester la connectivité du nœud
ping -c 4 8.8.8.8
ping -c 4 google.com
```

> [!info] Configuration réseau Proxmox Proxmox utilise des bridges Linux (vmbr0, vmbr1, etc.) pour connecter les VMs au réseau physique. Les VMs se connectent à ces bridges via des interfaces virtuelles (tap).

#### 📊 Vérifier les statistiques réseau

```bash
# Statistiques par interface
ip -s link show vmbr0

# Voir les connexions actives
ss -tunap

# Statistiques détaillées
ifconfig vmbr0

# Vérifier les règles de pare-feu
iptables -L -n -v
```

### Problèmes de connectivité VM

#### 🔌 VM sans accès réseau

```bash
# Vérifier la configuration réseau de la VM
qm config <VMID> | grep net

# Vérifier que le bridge existe
ip link show vmbr0

# Lister les interfaces tap de la VM
ip link | grep tap<VMID>

# Tester depuis le nœud vers la VM
ping <IP_VM>

# Vérifier le trafic sur le bridge
tcpdump -i vmbr0 -n host <IP_VM>
```

> [!example] Configuration réseau typique
> 
> ```bash
> # Dans la config VM (/etc/pve/qemu-server/<VMID>.conf)
> net0: virtio=XX:XX:XX:XX:XX:XX,bridge=vmbr0,firewall=1
> ```

#### 🔧 Solutions aux problèmes VM

**Reconnexion du réseau :**

```bash
# Redémarrer le service réseau de la VM (depuis la VM)
# Debian/Ubuntu
systemctl restart networking
# ou
systemctl restart NetworkManager

# CentOS/RHEL
systemctl restart network

# Reconfigurer l'interface (depuis Proxmox)
qm set <VMID> --net0 virtio,bridge=vmbr0

# Forcer la reconnexion
qm reboot <VMID>
```

**Problème de driver réseau :**

```bash
# Changer le modèle de carte réseau
# virtio (recommandé, nécessite drivers)
qm set <VMID> --net0 virtio=XX:XX:XX:XX:XX:XX,bridge=vmbr0

# e1000 (compatible legacy)
qm set <VMID> --net0 e1000=XX:XX:XX:XX:XX:XX,bridge=vmbr0

# rtl8139 (très compatible mais lent)
qm set <VMID> --net0 rtl8139=XX:XX:XX:XX:XX:XX,bridge=vmbr0
```

> [!tip] Choix du modèle réseau Préférez **virtio** pour les performances, mais utilisez **e1000** pour les OS sans drivers virtio (Windows ancien sans drivers installés).

### Problèmes de bridge et VLAN

#### 🌉 Bridge non fonctionnel

```bash
# Vérifier l'état du bridge
ip link show vmbr0

# Recréer le bridge (attention : perte de connexion temporaire)
ifdown vmbr0
ifup vmbr0

# Ou redémarrer le réseau complet (via console physique!)
systemctl restart networking

# Vérifier les membres du bridge
bridge link show
```

> [!warning] Redémarrage réseau Ne redémarrez JAMAIS le réseau via SSH si le bridge principal gère la connexion SSH. Utilisez la console physique ou iLO/iDRAC.

**Configuration correcte d'un bridge :**

```bash
# /etc/network/interfaces
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
    bridge-ports eno1
    bridge-stp off
    bridge-fd 0
```

#### 🏷️ Problèmes VLAN

```bash
# Vérifier les VLANs configurés
cat /proc/net/vlan/config

# Créer un bridge avec VLAN aware
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    bridge-ports eno1
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    bridge-vids 2-4094

# Configuration VM avec VLAN tag
qm set <VMID> --net0 virtio,bridge=vmbr0,tag=10

# Tester la communication VLAN
tcpdump -i vmbr0 -e -n vlan 10
```

### Pare-feu bloque le trafic

```bash
# Désactiver temporairement le pare-feu Proxmox
# Sur la VM
qm set <VMID> --net0 virtio,bridge=vmbr0,firewall=0

# Sur le datacenter (interface web)
# Datacenter > Firewall > Options > Firewall: No

# Vérifier les règles iptables
iptables -L -n -v | grep <IP_VM>

# Flush temporaire (attention!)
iptables -F

# Voir les logs du pare-feu
journalctl -f | grep -i firewall
```

> [!warning] Désactivation du pare-feu Désactiver le pare-feu n'est qu'un test de diagnostic. Réactivez-le et ajustez les règles une fois le problème identifié.

### 🧪 Tests de connectivité avancés

```bash
# Test depuis l'hôte vers la VM
arping -I vmbr0 <IP_VM>

# Capture de paquets détaillée
tcpdump -i vmbr0 -vvv -s 0 host <IP_VM>

# Vérifier les tables ARP
ip neigh show

# Tracer le chemin réseau
mtr <IP_VM>
traceroute <IP_VM>

# Tester les ports spécifiques
nc -zv <IP_VM> 22
nc -zv <IP_VM> 80
```

---

## 💾 Problèmes de stockage

### Types d'erreurs de stockage

Les problèmes de stockage peuvent impacter gravement les VMs : impossibilité de démarrer, perte de données, ou performances dégradées. Ils concernent les disques locaux (LVM, Directory), le stockage réseau (NFS, iSCSI, Ceph) ou ZFS.

### Diagnostic du stockage

#### 📊 Vérifier l'état global

```bash
# Voir tous les stockages disponibles
pvesm status

# Espace disque sur le nœud
df -h

# État des LVM
vgs
lvs
pvs

# État des montages
mount | grep -E "pve|storage"

# Vérifier les erreurs disque
dmesg | grep -i error
journalctl -k | grep -i "I/O error"
```

> [!info] Types de stockage Proxmox
> 
> - **local** : répertoire sur le système de fichiers
> - **local-lvm** : volumes logiques LVM (disques VMs)
> - **NFS/CIFS** : stockage réseau
> - **ZFS** : système de fichiers avancé
> - **Ceph** : stockage distribué

#### 🔍 Diagnostiquer un stockage spécifique

```bash
# Informations détaillées sur un stockage
pvesm status -storage local-lvm

# Lister le contenu d'un stockage
pvesm list local-lvm

# Vérifier la disponibilité
pvesm scan lvm

# Pour NFS/CIFS, vérifier les montages
showmount -e <NFS_SERVER>
```

### Stockage LVM (local-lvm)

#### ⚠️ Problème : Volume group plein

```bash
# Vérifier l'espace LVM
vgs
lvs

# Voir l'utilisation détaillée
lvdisplay /dev/pve/data

# Étendre le volume group si possible
# (ajouter un disque physique)
pvcreate /dev/sdb
vgextend pve /dev/sdb

# Étendre le thin pool
lvextend -L +50G /dev/pve/data
```

> [!warning] Thin provisioning Les LVM thin pools permettent l'overprovisioning. Surveillez l'utilisation réelle pour éviter le remplissage complet.

#### 🔧 Disque VM corrompu ou verrouillé

```bash
# Vérifier l'état des volumes
lvs -a | grep vm-<VMID>

# Activer un volume désactivé
lvchange -ay /dev/pve/vm-<VMID>-disk-0

# Vérifier les snapshots (peuvent bloquer)
lvs -a | grep snap

# Supprimer un snapshot bloquant
lvremove /dev/pve/vm-<VMID>-disk-0-snap

# Réparer les métadonnées LVM
vgck pve
vgscan --cache
```

#### 💽 Migration d'un disque

```bash
# Déplacer un disque vers un autre stockage
qm move-disk <VMID> scsi0 local-lvm --delete

# Cloner un disque
qm clone <VMID> <NEW_VMID> --full --storage local-lvm

# Import manuel d'un disque
qm importdisk <VMID> /path/to/disk.qcow2 local-lvm
```

### Stockage Directory (local)

#### 📁 Problème d'espace disque

```bash
# Identifier ce qui consomme l'espace
du -sh /var/lib/vz/*
du -sh /var/lib/vz/template/*

# Nettoyer les anciens templates
ls -lh /var/lib/vz/template/iso/
rm /var/lib/vz/template/iso/old-iso.iso

# Nettoyer les anciens dumps
ls -lh /var/lib/vz/dump/
find /var/lib/vz/dump/ -mtime +30 -delete

# Vérifier les logs volumineux
du -sh /var/log/*
journalctl --vacuum-time=7d
```

#### 🔐 Problèmes de permissions

```bash
# Vérifier les permissions
ls -la /var/lib/vz/

# Corriger les permissions
chown -R root:root /var/lib/vz/
chmod 755 /var/lib/vz/

# Pour un répertoire spécifique
chown -R root:root /var/lib/vz/template/iso
chmod 755 /var/lib/vz/template/iso
```

### Stockage NFS

#### 🌐 Montage NFS échoué

```bash
# Tester le montage manuel
mount -t nfs <NFS_SERVER>:/export /mnt/test

# Vérifier la connectivité
ping <NFS_SERVER>
showmount -e <NFS_SERVER>

# Voir les options de montage actuelles
cat /etc/pve/storage.cfg | grep -A5 nfs

# Forcer le remontage
pvesm set <STORAGE_ID> --disable 1
pvesm set <STORAGE_ID> --disable 0

# Vérifier les logs NFS
journalctl -u rpc-statd -xe
dmesg | grep nfs
```

> [!tip] Options NFS recommandées
> 
> ```
> # Dans /etc/pve/storage.cfg
> nfs: backup-nfs
>     export /backup
>     path /mnt/pve/backup-nfs
>     server 192.168.1.50
>     content backup,vztmpl,iso
>     options vers=3,soft,timeo=10
> ```

#### 🔄 NFS en stale/non répondant

```bash
# Forcer l'unmount d'un NFS bloqué
umount -f /mnt/pve/<STORAGE_NAME>

# Ou en lazy unmount
umount -l /mnt/pve/<STORAGE_NAME>

# Nettoyer les montages fantômes
mount | grep nfs
# puis umount chaque entrée orpheline

# Redémarrer les services NFS client
systemctl restart nfs-client.target
systemctl restart rpc-statd
```

### Stockage Ceph (si applicable)

```bash
# Vérifier l'état du cluster Ceph
ceph -s
ceph health detail

# Vérifier les OSDs
ceph osd tree
ceph osd status

# Vérifier les pools
ceph osd pool ls detail

# Réparer les PGs en erreur
ceph pg repair <PG_ID>
```

### ZFS

```bash
# État des pools ZFS
zpool status
zpool list

# Santé des disques
zpool status -x

# Scrub pour vérifier l'intégrité
zpool scrub <POOL_NAME>

# Voir les erreurs
zpool events -v
```

> [!tip] Performances de stockage Utilisez `fio` ou `dd` pour tester les performances I/O :
> 
> ```bash
> # Test d'écriture simple
> dd if=/dev/zero of=/var/lib/vz/testfile bs=1M count=1024 oflag=direct
> 
> # Test de lecture
> dd if=/var/lib/vz/testfile of=/dev/null bs=1M iflag=direct
> ```

---

## 🚪 Accès à l'interface perdu

### Causes possibles

La perte d'accès à l'interface web Proxmox (port 8006) peut provenir d'un problème réseau, d'un service arrêté, de certificats expirés ou d'un pare-feu mal configuré.

### Diagnostic initial

#### 🔌 Vérifier la connectivité réseau

```bash
# Depuis un autre ordinateur
ping <IP_PROXMOX>

# Tester le port 8006
telnet <IP_PROXMOX> 8006
# ou
nc -zv <IP_PROXMOX> 8006

# Test avec curl
curl -k https://<IP_PROXMOX>:8006

# Vérifier depuis le nœud lui-même
curl -k https://localhost:8006
```

> [!info] Port 8006 L'interface web Proxmox utilise le port **8006** en HTTPS. Le port **8007** est utilisé pour la console en noVNC.

#### 🔍 Vérifier les services Proxmox

```bash
# Statut du service principal
systemctl status pveproxy

# Statut de tous les services Proxmox
systemctl status pve*

# Services critiques à vérifier
systemctl status pvedaemon
systemctl status pveproxy
systemctl status pvestatd
systemctl status pve-cluster

# Redémarrer les services si nécessaire
systemctl restart pveproxy
systemctl restart pvedaemon
```

> [!example] Services Proxmox essentiels
> 
> - **pveproxy** : serveur web pour l'interface
> - **pvedaemon** : API backend
> - **pve-cluster** : gestion du cluster
> - **pvestatd** : collecte de statistiques

#### 📋 Examiner les logs

```bash
# Logs du proxy web
journalctl -u pveproxy -xe
tail -f /var/log/pveproxy/access.log

# Logs du daemon
journalctl -u pvedaemon -xe

# Logs système généraux
journalctl -xe | grep -i pve

# Logs Apache (si utilisé)
tail -f /var/log/apache2/error.log
```

### Solutions aux problèmes courants

#### 🔐 Certificats SSL expirés ou invalides

```bash
# Vérifier les certificats
pvecm cert info

# Vérifier la date d'expiration
openssl x509 -in /etc/pve/local/pve-ssl.pem -noout -enddate
openssl x509 -in /etc/pve/pve-root-ca.pem -noout -enddate

# Régénérer les certificats auto-signés
pvecm updatecerts -f

# Ou recréer le certificat local
rm /etc/pve/local/pve-ssl.key
rm /etc/pve/local/pve-ssl.pem
systemctl restart pveproxy
```

> [!warning] Certificats Après régénération des certificats, vous devrez accepter le nouveau certificat dans votre navigateur.

#### 🧱 Pare-feu bloque le port 8006

```bash
# Vérifier les règles iptables
iptables -L -n | grep 8006

# Vérifier si le port écoute
netstat -tlnp | grep 8006
ss -tlnp | grep 8006

# Autoriser temporairement le port
iptables -I INPUT -p tcp --dport 8006 -j ACCEPT

# Pour UFW
ufw allow 8006/tcp

# Vérifier le pare-feu Proxmox
cat /etc/pve/firewall/cluster.fw
```

#### ⚙️ Configuration pveproxy corrompue

```bash
# Vérifier la configuration
cat /etc/default/pveproxy

# Configuration par défaut attendue
ALLOW_FROM="all"
DENY_FROM=""
POLICY="allow"

# Restaurer la configuration par défaut
cat > /etc/default/pveproxy <<EOF
# Defaults for pveproxy
ALLOW_FROM="all"
DENY_FROM=""
POLICY="allow"
EOF

# Redémarrer
systemctl restart pveproxy
```

#### 🖥️ Problème de résolution DNS

```bash
# Vérifier la résolution du hostname
hostname -f

# Vérifier /etc/hosts
cat /etc/hosts

# Doit contenir une ligne comme :
# 192.168.1.10 pve.domain.com pve

# Corriger si nécessaire
echo "192.168.1.10 $(hostname -f) $(hostname)" >> /etc/hosts

# Redémarrer le cluster
systemctl restart pve-cluster
```

#### 🔄 Cluster status en erreur

```bash
# Vérifier l'état du cluster
pvecm status

# Si corosync a des problèmes
systemctl status corosync
systemctl restart corosync

# Vérifier le quorum
pvecm expected 1

# Recréer la configuration si nécessaire
pvecm updatecerts
systemctl restart pve-cluster
```

### Accès d'urgence

#### 💻 Accès via console série/SSH

```bash
# Se connecter en SSH (si possible)
ssh root@<IP_PROXMOX>

# Ou via console physique (iLO, iDRAC, IPMI)

# Une fois connecté, relancer l'interface
systemctl restart pveproxy pvedaemon

# Vérifier que ça écoute
ss -tlnp | grep 8006
```

#### 🌐 Accès via un tunnel SSH

```bash
# Depuis votre poste de travail
ssh -L 8006:localhost:8006 root@<IP_PROXMOX>

# Puis ouvrir dans le navigateur
https://localhost:8006
```

> [!tip] Astuce tunnel SSH Utile si le pare-feu bloque l'accès externe mais SSH fonctionne. Permet de déboguer l'interface sans exposer le port.

#### 🔧 Réinitialisation complète des services

```bash
# Arrêter tous les services Proxmox
systemctl stop pve*

# Nettoyer les fichiers de lock
rm -f /var/lock/pve*
rm -f /run/lock/pve*

# Redémarrer dans l'ordre
systemctl start pve-cluster
sleep 5
systemctl start pvedaemon
systemctl start pveproxy
systemctl start pvestatd

# Vérifier
systemctl status pve*
```

---

## 🆘 Récupération en mode rescue

### Quand utiliser le mode rescue

Le mode rescue est nécessaire lorsque le système Proxmox est inaccessible ou non-bootable : problème de bootloader, corruption du système de fichiers, perte du mot de passe root, ou erreurs graves dans la configuration.

> [!warning] Mode rescue Le mode rescue nécessite un accès physique (console) ou virtuel (iLO/iDRAC) au serveur. Assurez-vous d'avoir les identifiants nécessaires.

### Boot en mode rescue

#### 💿 Démarrer depuis un ISO Proxmox

```bash
# 1. Insérer le média d'installation Proxmox
# 2. Au boot, sélectionner "Install Proxmox VE (Terminal UI)"
# 3. À l'écran de licence, passer en console : Ctrl+Alt+F2

# Vous êtes maintenant en environnement rescue live
```

#### 🔧 Monter le système existant

```bash
# Identifier les partitions
lsblk
fdisk -l

# Monter la partition root LVM
vgscan
vgchange -ay

# Monter le système
mount /dev/pve/root /mnt

# Monter les autres partitions nécessaires
mount /dev/sda2 /mnt/boot  # Partition boot
mount /dev/sda1 /mnt/boot/efi  # Si UEFI

# Monter les pseudo-filesystems
mount -t proc /proc /mnt/proc
mount --rbind /sys /mnt/sys
mount --rbind /dev /mnt/dev
mount --rbind /run /mnt/run
```

> [!info] Structure typique Proxmox
> 
> - `/dev/sda1` : partition EFI (si UEFI)
> - `/dev/sda2` : partition boot
> - `/dev/sda3` : LVM contenant root, swap, data

#### 🖥️ Chroot dans le système

```bash
# Entrer dans le système monté
chroot /mnt /bin/bash

# Vous êtes maintenant dans votre système Proxmox
# comme si vous aviez booté normalement
```

### Réparations courantes en mode rescue

#### 🔑 Réinitialisation du mot de passe root

```bash
# Une fois en chroot
passwd root

# Entrer le nouveau mot de passe deux fois
# Sauvegarder et quitter
exit
```

> [!tip] Mot de passe PAM Ce mot de passe s'applique uniquement à l'authentification PAM (Linux). Les comptes Proxmox VE (pve) dans l'interface ont leurs propres mots de passe.

#### 🥾 Réparer le bootloader GRUB

```bash
# Après chroot, réinstaller GRUB
update-grub

# Pour système BIOS
grub-install /dev/sda

# Pour système UEFI
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=proxmox

# Vérifier la configuration
cat /boot/grub/grub.cfg | grep menuentry
```

#### 💾 Réparer le système de fichiers

```bash
# AVANT le chroot, démonter les partitions
umount /mnt/boot/efi
umount /mnt/boot
umount /mnt

# Vérifier et réparer ext4
e2fsck -f -y /dev/sda2

# Pour XFS
xfs_repair /dev/sda2

# Pour le root LVM
e2fsck -f -y /dev/pve/root

# Remonter ensuite
mount /dev/pve/root /mnt
mount /dev/sda2 /mnt/boot
```

> [!warning] fsck sur système monté Ne jamais lancer fsck sur un système de fichiers monté ! Cela peut causer une corruption irréversible.

#### ⚙️ Réparer la configuration réseau

```bash
# En chroot, éditer la configuration
nano /etc/network/interfaces

# Configuration minimale fonctionnelle
auto lo
iface lo inet loopback

auto eno1
iface eno1 inet manual

auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
    bridge-ports eno1
    bridge-stp off
    bridge-fd 0

# Redémarrer le réseau (après reboot)
```

#### 🗄️ Réparer la base de données Proxmox

```bash
# En chroot, vérifier la cohérence
sqlite3 /var/lib/pve-cluster/config.db "PRAGMA integrity_check;"

# Sauvegarder avant réparation
cp -a /var/lib/pve-cluster /var/lib/pve-cluster.backup

# Recréer le cluster local
rm -rf /var/lib/pve-cluster/config.db*
pmxcfs -l

# Régénérer la configuration
pvecm updatecerts -f
```

#### 📦 Réparer les paquets cassés

```bash
# En chroot, configurer le réseau DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Mettre à jour les sources
apt update

# Réparer les paquets
apt --fix-broken install
dpkg --configure -a

# Réinstaller Proxmox si nécessaire
apt install --reinstall proxmox-ve
```

### Récupération des données VM

#### 💾 Sauvegarder les disques VM en rescue

```bash
# Lister les volumes LVM
lvs | grep vm-

# Copier un disque VM vers un autre support
dd if=/dev/pve/vm-100-disk-0 of=/mnt/backup/vm-100-disk-0.img bs=4M status=progress

# Ou avec compression
dd if=/dev/pve/vm-100-disk-0 bs=4M | gzip > /mnt/backup/vm-100-disk-0.img.gz

# Monter directement un disque VM (si partition visible)
kpartx -av /dev/pve/vm-100-disk-0
mount /dev/mapper/pve-vm--100--disk--0p1 /mnt/vm-recovery
```

> [!tip] Récupération sélective Si vous n'avez besoin que de certains fichiers, montez le disque VM et copiez uniquement ce qui est nécessaire pour gagner du temps.

#### 🔄 Restaurer un disque VM

```bash
# Restaurer depuis une image
dd if=/mnt/backup/vm-100-disk-0.img of=/dev/pve/vm-100-disk-0 bs=4M status=progress

# Ou depuis une compression
gunzip -c /mnt/backup/vm-100-disk-0.img.gz | dd of=/dev/pve/vm-100-disk-0 bs=4M

# Réactiver le volume
lvchange -ay /dev/pve/vm-100-disk-0
```

### Reconstruction complète du système

#### 🔨 Réinstallation sur place

```bash
# Si le système est trop corrompu, réinstaller Proxmox
# ATTENTION : sauvegardez /etc/pve/ avant !

# En rescue, sauvegarder la configuration
mkdir -p /mnt/backup
cp -a /mnt/etc/pve /mnt/backup/pve-config
cp -a /mnt/etc/network/interfaces /mnt/backup/

# Réinstaller Proxmox VE depuis l'ISO
# Après installation, restaurer la configuration
cp -a /backup/pve-config/* /etc/pve/
cp /backup/interfaces /etc/network/interfaces
```

#### 🗂️ Migration des VMs vers un nouveau nœud

```bash
# En rescue, exporter les configurations
mkdir /mnt/backup/vm-configs
cp /mnt/etc/pve/qemu-server/*.conf /mnt/backup/vm-configs/

# Copier les disques (si possible via réseau)
# Sur le nouveau nœud :
scp root@old-node:/backup/vm-configs/* /etc/pve/qemu-server/
# Puis importer les disques
```

### Sortie du mode rescue

#### ✅ Vérifications avant reboot

```bash
# En chroot, vérifier les services
systemctl list-units --failed

# Vérifier GRUB
ls /boot/grub/
cat /boot/grub/grub.cfg | head -20

# Vérifier fstab
cat /etc/fstab

# Tester la configuration réseau
cat /etc/network/interfaces

# Sortir du chroot
exit
```

#### 🔄 Démonter et redémarrer

```bash
# Démonter proprement
umount /mnt/boot/efi
umount /mnt/boot
umount -l /mnt/dev
umount -l /mnt/proc
umount -l /mnt/sys
umount -l /mnt/run
umount /mnt

# Désactiver le volume group
vgchange -an pve

# Retirer le média d'installation et redémarrer
reboot
```

> [!tip] Post-reboot Après le redémarrage, connectez-vous et vérifiez :
> 
> - Les services Proxmox : `systemctl status pve*`
> - L'interface web : `https://<IP>:8006`
> - Les VMs : `qm list`
> - Le stockage : `pvesm status`

### Scénarios de rescue spécifiques

#### 🔒 Cluster non accessible (split-brain)

```bash
# En rescue/chroot
# Forcer le nœud en mode standalone
pvecm expected 1

# Ou réinitialiser complètement le cluster
systemctl stop pve-cluster corosync
pmxcfs -l
rm /etc/pve/corosync.conf
rm /etc/corosync/*
systemctl start pve-cluster
```

#### 💥 Kernel panic au boot

```bash
# Booter en rescue
# Chroot dans le système
chroot /mnt /bin/bash

# Lister les kernels disponibles
ls /boot/

# Réinstaller le kernel
apt install --reinstall pve-kernel-6.8

# Reconstruire initramfs
update-initramfs -u -k all

# Mettre à jour GRUB
update-grub
```

#### 🧩 LVM metadata corrompu

```bash
# Sauvegarder les métadonnées
vgcfgbackup

# Restaurer depuis un backup automatique
vgcfgrestore pve

# Ou forcer la récupération
vgck --updatemetadata pve

# Réactiver
vgchange -ay pve
```

> [!warning] Dernière limite Si les métadonnées LVM et les sauvegardes sont corrompues, la récupération des données peut nécessiter des outils spécialisés comme `testdisk` ou `ddrescue`.

---

## 📊 Tableau récapitulatif des commandes de dépannage

|Problème|Commande principale|Action|
|---|---|---|
|VM ne démarre pas|`qm start <VMID>`|Lancer et observer les erreurs|
|VM verrouillée|`qm unlock <VMID>`|Déverrouiller la VM|
|Logs VM|`tail -f /var/log/pve/qemu-server/<VMID>.log`|Voir les erreurs en temps réel|
|Réseau VM absent|`qm config <VMID> \| grep net`|Vérifier la configuration réseau|
|Bridge down|`ifup vmbr0`|Réactiver le bridge|
|Service Proxmox arrêté|`systemctl restart pveproxy`|Redémarrer l'interface web|
|Certificat expiré|`pvecm updatecerts -f`|Régénérer les certificats|
|Stockage plein|`pvesm status`|Vérifier l'espace|
|LVM volume inactif|`lvchange -ay /dev/pve/vm-X-disk-0`|Activer le volume|
|NFS non monté|`pvesm set <ID> --disable 0`|Réactiver le stockage|
|Mot de passe perdu|`passwd root` (en rescue)|Changer le mot de passe|
|GRUB cassé|`grub-install /dev/sda` (en rescue)|Réinstaller GRUB|
|Filesystem corrompu|`e2fsck -f -y /dev/sda2` (en rescue)|Réparer le système de fichiers|

---

## 🎯 Bonnes pratiques de dépannage

### Méthodologie systématique

1. **Identifier** : Quel est le symptôme exact ? Depuis quand ?
2. **Isoler** : Le problème touche-t-il une VM, un nœud, ou le cluster entier ?
3. **Vérifier les logs** : Toujours consulter les journaux avant d'agir
4. **Tester** : Procéder par élimination, une hypothèse à la fois
5. **Documenter** : Noter les actions effectuées et les résultats

### Protection préventive

```bash
# Sauvegarder régulièrement la configuration
mkdir -p /root/backups
tar czf /root/backups/pve-config-$(date +%Y%m%d).tar.gz /etc/pve/

# Sauvegarder la configuration réseau
cp /etc/network/interfaces /root/backups/interfaces.backup

# Activer la rotation des logs
journalctl --vacuum-time=30d

# Surveiller l'espace disque
df -h | mail -s "Proxmox disk space" admin@example.com
```

> [!tip] Sauvegarde de configuration automatique Créez un script cron pour sauvegarder automatiquement `/etc/pve/` et `/etc/network/interfaces` quotidiennement.

### Outils indispensables à connaître

|Outil|Usage|Exemple|
|---|---|---|
|`journalctl`|Logs système|`journalctl -u pveproxy -xe`|
|`systemctl`|Gestion services|`systemctl status pvedaemon`|
|`qm`|Gestion VMs|`qm list`, `qm config 100`|
|`pvesm`|Gestion stockage|`pvesm status`, `pvesm list local-lvm`|
|`tcpdump`|Capture réseau|`tcpdump -i vmbr0 host 192.168.1.100`|
|`lvs/vgs/pvs`|Gestion LVM|`lvs`, `vgdisplay`|
|`ip`|Configuration réseau|`ip addr`, `ip route`|

---

## 🚨 Erreurs critiques et solutions d'urgence

### "Cluster not ready - no quorum?"

```bash
# Solution temporaire : forcer le quorum
pvecm expected 1

# Solution permanente : réparer le cluster
systemctl restart corosync pve-cluster
pvecm status
```

### "Unable to activate storage"

```bash
# Pour LVM
vgchange -ay pve
lvchange -ay /dev/pve/data

# Pour NFS
systemctl restart rpc-statd
pvesm set <STORAGE_ID> --disable 0
```

### "TASK ERROR: can't lock file"

```bash
# Identifier le processus verrouillant
lsof | grep <VMID>

# Tuer le processus bloquant (avec prudence)
kill -9 <PID>

# Déverrouiller
qm unlock <VMID>
```

### "500 Internal Server Error"

```bash
# Redémarrer les services
systemctl restart pvedaemon pveproxy

# Vérifier les certificats
pvecm updatecerts -f

# Vérifier les permissions
chown -R www-data:www-data /var/log/pveproxy
```

> [!warning] Dernier recours Si aucune solution ne fonctionne, envisagez un reboot du nœud. Assurez-vous que les VMs critiques ont été migrées ou sont en haute disponibilité.

---

## 🔍 Checklist de diagnostic rapide

Lorsque vous rencontrez un problème, parcourez cette checklist :

- [ ] Les services Proxmox sont-ils actifs ? `systemctl status pve*`
- [ ] Y a-t-il des erreurs dans les logs ? `journalctl -xe`
- [ ] Le réseau fonctionne-t-il ? `ping 8.8.8.8`
- [ ] L'espace disque est-il suffisant ? `df -h`
- [ ] Le stockage est-il accessible ? `pvesm status`
- [ ] Les VMs sont-elles dans l'état attendu ? `qm list`
- [ ] Y a-t-il des processus zombies ou bloqués ? `top`, `htop`
- [ ] Les certificats sont-ils valides ? `pvecm cert info`
- [ ] Le cluster a-t-il le quorum ? `pvecm status`
- [ ] La configuration réseau est-elle correcte ? `ip addr`, `brctl show`

---

## 🎓 Points clés à retenir

> [!tip] Les 5 commandements du dépannage Proxmox
> 
> 1. **Toujours consulter les logs en premier** - `journalctl` est votre meilleur ami
> 2. **Ne jamais redémarrer le réseau via SSH** - Utilisez la console physique
> 3. **Sauvegarder avant de modifier** - Un `cp` rapide peut sauver votre journée
> 4. **Tester en environnement isolé** - Évitez d'expérimenter en production
> 5. **Documenter vos actions** - Vous (et vos collègues) vous remercierez plus tard

### Ressources système à surveiller

- **RAM** : Les VMs surcommitées peuvent causer des OOM (Out Of Memory)
- **CPU** : Un CPU saturé ralentit toutes les VMs du nœud
- **I/O disque** : Les goulots d'étranglement impactent sévèrement les performances
- **Réseau** : Les erreurs de paquets indiquent des problèmes matériels ou de configuration

### Quand demander de l'aide

Si après avoir suivi ce guide :

- Le problème persiste après plusieurs tentatives
- Vous risquez de perdre des données critiques
- Le problème affecte un cluster en production
- Vous n'êtes pas certain des conséquences d'une action

N'hésitez pas à consulter :

- Les forums Proxmox : https://forum.proxmox.com
- La documentation officielle
- Un administrateur senior ou un consultant spécialisé

---

**Fin du cours sur le dépannage Proxmox** 🎉