---
title: "Proxmox - Ajout et montage d'un disque dur - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2768/pages/9953"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Virtualisation

## Proxmox - Ajout et montage d'un disque dur

Facile

30mins

Auto-validation

Virtualisation

## Proxmox - Ajout et montage d'un disque dur

## Introduction

Dans cette quête, tu vas gérer l'ajout d'un disques durs.  
Tu vas monter le disque dans un répertoire et le configurer ensuite dans Proxmox.  
On part du principe que tu as déjà une installation de Proxmox existante.

## 📚 Pré-requis

Avant de commencer cette quête, il est préférable d'avoir déjà terminé la quête suivante:

```shell
Proxmox : Installation1hVoir la quête - Proxmox : Installation
```

## 🤓 Objectifs:

✅ Configurer proxmox  
✅ Gérer l'ajout de disques durs par une méthode de montage classique

## sommaire

- [📚 Information sur les espaces de stockage](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#-information-sur-les-espaces-de-stockage)
	- [📌 Configuration des espaces de stockages du datacenter](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#-configuration-des-espaces-de-stockages-du-datacenter)
		- [📌 Configuration des serveurs du datacenter](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#-configuration-des-serveurs-du-datacenter)
- [👉 Mise en œuvre](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#-mise-en-%C5%93uvre)
	- [✔️ Prérequis](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#%EF%B8%8F-pr%C3%A9requis)
		- [📌 Connexion à Proxmox (rappel)](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#-connexion-%C3%A0-proxmox-rappel)
		- [🔧 Ajout d'un disque dur](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#-ajout-dun-disque-dur)
		- [🔬 Formatage et montage](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#-formatage-et-montage)
		- [🔬 Configuration dans proxmox](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#-configuration-dans-proxmox)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2768/pages/9953#-crit%C3%A8res-dacceptation)

## 📚 Information sur les espaces de stockage

## 📌 Configuration des espaces de stockages du datacenter

Pour chaque espace de stockage, Il faut indiquer ce qu'ils peuvent contenir.  
Il faut aller dans **Datacenter** --> **Storage** --> **Add** puis aller dans **Content** (on double-clique) pour avoir le détail du contenu (colonne 1 du tableau ci-dessous).  
Lorsque l'on va directement sur le storage, l'affichage des types de données change (colonne 2) selon ce que l'on a sélectionné au niveau du Datacenter.

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

## 🔧 Ajout d'un disque dur

Dans Virtualbox, sur le contrôleur SATA existant, crée 1 disque dur de type `vmdk` de 80.

```shell
Les disques durs des VM sont dynamiques, l'espace réel occupé par ces derniers est de quelques dizaines de Mo.

Attention néanmoins à ne pas remplir cet espace disque si tu n'a pas assez de place sur ta machine hôte.
```

Démarre la VM, et connecte toi en GUI avec le compte root.  
Le disque dur ajouté est visible dans `pve` --> `disks`: `/dev/sdb`.

## 🔬 Formatage et montage

En shell, exécute la commande `fdisk -l /dev/sdb` pour voir les informations sur le disque:

```bash
1
root@pve:~# fdisk -l /dev/sdb
2
Disk /dev/sdb: 80 GiB, 85899345920 bytes, 167772160 sectors
3
Disk model: VBOX HARDDISK   
4
Units: sectors of 1 * 512 = 512 bytes
5
Sector size (logical/physical): 512 bytes / 512 bytes
6
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

Partitionne le disque:

```bash
1
root@pve:~# fdisk /dev/sdb
```

Choisis `n` (ajout de partition) puis `p` (primary) et prend les valeurs par défaut qui consistent à utiliser créer une partition primaire en prenant l'intégralité du disque.  
Sauvegarde et quitte l'utilitaire.

Tu as maintenant une partition **/dev/sdb1**.

Formate cette partition en **ext4** et monte la automatiquement dans un dossier **/srv/dd1**.

```bash
Tu n'y arrives pas ?1
# Formate en ext4 :
2
mkfs.ext4 /dev/sdb1
3

4
# Création d'un répertoire de montage :
5
mkdir /media/dd1
6

7
# Ajouter la ligne "/dev/sdb1 /media/dd1 ext4 defaults 0 0" dans le fichier /etc/fstab pour que le montage se fasse à chaque démarrage.
8
echo "/dev/sdb1 /media/dd1 ext4 defaults 0 0" >> /etc/fstab
9

10
# Montage de la partition :
11
mount /media/dd1/
12
Click ici pour avoir la solution
```
```shell
Le disque dur de 80 Go est maintenant partitionné et formaté en ext4.
```

## 🔬 Configuration dans proxmox

Maintenant, il faut intégrer ce disque dur à l'hyperviseur.  
Pour ajouter ce 2ème disque dur, suis les instructions suivantes:

- A partir de `Datacenter` va dans `Storage`
- Clic sur `Add` et sélectionne `Directory`
- Dans l'onglet `General`, mets les informations suivantes:
	- ID: `dd1`
		- Directory: `/media/dd1`
		- Content: `Disk Image`
		- Enable: `à cocher`
- Dans l'onglet `Backup Retention`, mets `Keep Last` à `1`
```shell
C'est le parametre Content qui définit le contenu de la partition (fichiers ISO, disque dur de VM, etc.)
```
```shell
Tu as monté un disque dur complètement fonctionnel et utilisable pour gérer les VM.

Il est visible sous pve.
```

---

## ☝️ Résumé

On peut monter un disque sur proxmox, mais il faut d'abord le monter sur le système.  
On peut tout faire à partir de l'interface web, même exécuter des lignes de commandes.  
Pour voir les disques et les partitions d'une machine, il faut aller dans `pve` (ici la machine) puis `Disk`.  
Les disques durs montés sont visible dans `Datacenter` --> `Storage` ou directement sur la machine, ici `pve`.

---

## 📝 Quiz

```shell
# 1  - Les disque dur peuvent être configuré entièrement à partir de l'interface webVraiFauxValider# 2 VraiFauxValider# 3 VraiFauxValiderTon score :0 / 3
```

---

## 💪Challenge

Installe et configure un disque dur avec la méthode de montage classique utilisée dans cette quête.  
Test les différents contenu (image ISO, etc.) que tu peux mettre sur cet espace de stockage.

## 🧐 Critères d'acceptation

Ton disque est complètement opérationnel et visible dans Proxmox.

Quête terminée le **vendredi 02 janvier 2026**