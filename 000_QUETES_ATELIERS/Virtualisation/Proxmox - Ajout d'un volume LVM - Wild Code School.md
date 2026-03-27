---
title: "Proxmox - Ajout d'un volume LVM - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2781/pages/10009"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Virtualisation

## Proxmox - Ajout d'un volume LVM

Moyen

1h

Auto-validation

Virtualisation

## Proxmox - Ajout d'un volume LVM

## Introduction

Dans cette quête, tu vas gérer l'ajout d'un disque dur et le configurer avec la méthode LVM.  
On part du principe que tu as déjà une installation de Proxmox existante.

## 📚 Pré-requis

Avant de commencer cette quête, il est préférable d'avoir déjà terminé la quête suivante:

```shell
Proxmox : Installation1hVoir la quête - Proxmox : Installation
```

## 🤓 Objectifs:

✅ Configurer proxmox  
✅ Gérer l'ajout de disque dur par une méthode LVM

## sommaire

- [📚 Information sur les espaces de stockage](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#-information-sur-les-espaces-de-stockage)
	- [📌 Configuration des espaces de stockages du datacenter](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#-configuration-des-espaces-de-stockages-du-datacenter)
		- [📌 Configuration des serveurs du datacenter](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#-configuration-des-serveurs-du-datacenter)
- [👉 Mise en œuvre](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#-mise-en-%C5%93uvre)
	- [✔️ Prérequis](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#%EF%B8%8F-pr%C3%A9requis)
		- [📌 Connexion à Proxmox (rappel)](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#-connexion-%C3%A0-proxmox-rappel)
		- [🔧 Ajout du disque dur](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#-ajout-du-disque-dur)
		- [🔬 Création du volume logique](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#-cr%C3%A9ation-du-volume-logique)
		- [🔬 Configuration dans proxmox](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#-configuration-dans-proxmox)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2781/pages/10009#-crit%C3%A8res-dacceptation)

## 📚 Information sur les espaces de stockage

## 📌 Configuration des espaces de stockages du datacenter

Pour chaque espace de stockage, Il faut indiquer ce qu'ils peuvent contenir.  
Il faut aller dans **Datacenter** --> **Storage** --> **Add** puis aller dans **Content** (on double-clique) pour avoir le détail du contenu (colonne 1 du tableau ci-dessous).  
Lorsque l'on va directement sur le storage, l'affichage des types de données change (colonne 2) selon ce que l'on a sélectionné au niveau du Datacenter.

![](https://odyssey.wildcodeschool.com/quests/2781/pages/image.png)

| Dénomination à partir du Datacenter | Dénomination sur le storage | Type de données stockées |
| --- | --- | --- |
| Disk image | VM Disks | Image de disque dur au format qcow2 de type KVM-Qemu (*Kernel-based Virtual Machine*) |
| ISO image | ISO Images | Image ISO |
| Container template | CT Templates | Template de conteneur au format LXC (*Linux Container*) |
| VZDump backup file | Backups | Fichier de sauvegarde complète de machine VZDump |
| Container | CT Volumes | Autorisé pour stocker des conteneurs de données |
| Snippets | Snippets | Extrait de code |

En shell, on peut retrouver ces infos en allant voir le contenu du fichier `/etc/pve/storage.cfg`.

## 📌 Configuration des serveurs du datacenter

En cliquant sur le premier serveur de VM (`pve` par défaut), on voit plusieurs fonctionnalités à droite.  
Parmi celles-ci on peut trouver:

| Noeud PVE | Rôles |
| --- | --- |
| Summary | Permet de voir les statistiques d'utilisation du serveur (CPU, RAM...). |
| Shell | Permet d'ouvrir un terminal sur le serveur (pas besoin de putty ou un autre connecteur ssh). |
| System | Permet de changer les paramètres réseau, DNS, logs de syslog... |
| Updates | Pour faire les mises à jour serveur. |
| Disks | Permet de voir l'état des disques durs |
| Syslog | Journalisation |

## 👉 Mise en œuvre

## ✔️ Prérequis

Pour cette quête, il est nécessaire de disposer d'une VM Virtualbox sur laquelle Proxmox est installé.  
Voici la configuration:

- RAM: au minimum `4 Go`, dans l'idéal au moins `8 Go`
- Nombre de processeurs: au minimum `1`
- Nombre de cœurs par processeurs: `1`
- Stockage: `1 controleur SATA` et `un disque dur (de type VMDK) de 30 Go (pour le système)`
- L'activation des `VT-x/AMD-v` est faite (virtualisation imbriquée)
- Carte réseau: 1 seule en `bridge`
```shell
Bien que n'importe quel mode convienne pour la carte réseau de la VM, il est conseillé de la mettre en mode bridge, ce qui te permettra d'interagir dirrectement avec elle à partir de ta machine.

Si tu la mets en mode private network, tu dois avoir une deuxième machine dans le même réseau que proxmox, qui servira de client.
```

## 📌 Connexion à Proxmox (rappel)

Tu peux te connecter de 2 manières:

- En CLI directement sur la machine
- En GUI dans un navigateur web en se connectant à l'adresse `https://@IP_de_ta_machine:8006/`

## 🔧 Ajout du disque dur

Dans Virtualbox, sur le contrôleur SATA existant, crée 1 disque dur de type `vmdk` de 100 Go.

```shell
Les disques durs des VM sont dynamiques, l'espace réel occupé par ces derniers est de quelques dizaines de Mo.

Attention néanmoins à ne pas remplir cet espace disque si tu n'a pas assez de place sur ta machine hôte.
```

Démarre la VM, et connecte toi en GUI avec le compte root.  
Le disque dur ajouté est visible dans `pve` --> `disks`: `/dev/sdc`.

## 🔬 Création du volume logique

En shell, exécute la commande `fdisk -l /dev/sdc` pour voir les informations sur le disque:

```bash
1
root@pve:~# fdisk -l /dev/sdc
2
Disk /dev/sdc: 100 GiB, 107374182400 bytes, 209715200 sectors
3
Disk model: VBOX HARDDISK   
4
Units: sectors of 1 * 512 = 512 bytes
5
Sector size (logical/physical): 512 bytes / 512 bytes
6
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

Création du volume physique avec `pvcreate /dev/sdc`:

```bash
1
root@pve:~# pvcreate /dev/sdc
2
  Physical volume "/dev/sdc" successfully created.
```

Vérification de la création du volume avec `pvdisplay /dev/sdc`:

```bash
1
root@pve:~# pvdisplay /dev/sdc
2
  "/dev/sdc" is a new physical volume of "100.00 GiB"
3
  --- NEW Physical volume ---
4
  PV Name               /dev/sdc
5
  VG Name               
6
  PV Size               100.00 GiB
7
  Allocatable           NO
8
  PE Size               0   
9
  Total PE              0
10
  Free PE               0
11
  Allocated PE          0
12
  PV UUID               F00x6D-Ziyu-ACMB-hbYA-n2CR-oF3q-J7sCgf
```

Création du volume group `vg1` avec la commande `vgcreate vg1 /dev/sdc`:

```bash
1
root@pve:~# vgcreate vg1 /dev/sdc
2
  Volume group "vg1" successfully created
```

Création du volume logique `vl-dd2` avec la commande `lvcreate -n vl-dd2 -L 90G vg1`:

```bash
1
root@pve:~# lvcreate -n vl-dd2 -L 90G vg1
2
  Logical volume "vl-dd2" created.
```

Formatage en ext4 du volume logique avec la commande `mkfs.ext4`:

```bash
1
root@pve:~# mkfs.ext4 /dev/vg1/vl-dd2
2
mke2fs 1.46.5 (30-Dec-2021)
3
Creating filesystem with 23592960 4k blocks and 5898240 inodes
4
Filesystem UUID: 68572cc2-0249-41e3-a50c-0353f879fb3b
5
Superblock backups stored on blocks: 
6
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
7
        4096000, 7962624, 11239424, 20480000
8

9
Allocating group tables: done                            
10
Writing inode tables: done                            
11
Creating journal (131072 blocks): done
12
Writing superblocks and filesystem accounting information: done
```

Conversion du volume logique au format **thin-pool** avec la commande `lvconvert --type thin-pool vg1/vl-dd2`

```bash
1
root@pve:~# lvconvert --type thin-pool vg1/vl-dd2
2
  Thin pool volume with chunk size 64.00 KiB can address at most 15.81 TiB of data.
3
  WARNING: Converting vg1/vl-dd2 to thin pool's data volume with metadata wiping.
4
  THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)
5
Do you really want to convert vg1/vl-dd2? [y/n]: y
6
  Converted vg1/vl-dd2 to thin pool.
```
```shell
Quelques avantages de la conversion en thin-pool :

Allocation de stockage à la demande
Snapshots plus rapide
Clonage rapide

Vous pouvez consulter la référence vers la documentation Proxmox
```
```shell
Le disque dur de 100 Go est maintenant partitionné et formaté en ext4.
```

## 🔬 Configuration dans proxmox

Tu peux voir le volume group et le logical volume dans `pve` --> `disk`.

Pour ajouter le volume logique, vas dans `Datacenter` puis `Storage`:

- Clic sur `Add` et sélectionne `LVM-Thin`
- Dans l'onglet `General`, mets les informations suivantes:
	- ID: `lvm2`
		- Volume group: `vg1`
		- Thin Pool: `vl-dd2`
		- Enable: `à cocher`
```shell
C'est le paramètre Content qui définit le contenu de la partition (fichiers ISO, disque dur de VM, etc.)
```
```shell
Tu as monté un disque dur complètement fonctionnel et utilisable pour gérer les VM.

Il est visible sous pve et sous Datacenter --> Storage.
```

---

## ☝️ Résumé

On peut monter un disque sur proxmox, mais il faut d'abord le monter sur le système.  
On peut tout faire à partir de l'interface web, même exécuter des lignes de commandes.  
Pour voir les disques et les partitions d'une machine, il faut aller dans `pve` (ici la machine) puis `Disk`.  
Les disques durs montés sont visible dans `Datacenter` --> `Storage` ou directement sur la machine, ici `pve`.  
L'utilisation de LVM et entre-autre des volumes logiques ̀thin pool\` est une bonne méthode d'optimisation de la gestion des disques.

---

## 📝 Quiz

```shell
# 1  - On est obligé d'utiliser les thin pool dans la méthode LVM sur ProxmoxVraiFauxValider# 2 VraiFauxValiderTon score :0 / 2
```

---

## 💪Challenge

Installe et configure un disque dur avec la méthode de création LVM.  
Test les différents contenu (image ISO, etc.) que tu peux mettre sur cet espace de stockage.

## 🧐 Critères d'acceptation

Ton disque est complètement opérationnel et visible dans Proxmox.

Quête terminée le **vendredi 02 janvier 2026**