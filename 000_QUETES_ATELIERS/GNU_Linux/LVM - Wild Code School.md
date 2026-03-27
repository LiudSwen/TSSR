---
title: "LVM - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2294/pages/8111"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
GNU/Linux

## LVM

Logical Volume Manager (LVM) est un ensemble d'outil permettant une gestion avancée du stockage sous Linux

Moyen

2h

3 pairs

GNU/Linux

## LVM

## Introduction

Linux permet une gestion avancée du stockage à l'aide de *Logical Volume Manager* ou LVM.

Cette quête consiste à en découvrir et tester les principales fonctionalités

```shell
Les expérimentations pratiques ont été testées sur une Debian 11.3 installée dans une machine virtuelle VirtualBox 6.1 tournant sur un système hôte Ubuntu 22.04 LTS.
```

## 🤓 Objectifs:

✅ Comprendre le fonctionnement de LVM  
✅ Explorer une installation de Debian sur LVM  
✅ Expérimenter avec LVM sur un environnement de test

## Sommaire

- [👉 Les concepts de LVM](https://odyssey.wildcodeschool.com/quests/2294/pages/8111#-les-concepts-de-lvm)
- [👉 Installation d'un système avec LVM](https://odyssey.wildcodeschool.com/quests/2294/pages/8111#-installation-dun-syst%C3%A8me-avec-lvm)
	- [📚 Rappel sur le boot](https://odyssey.wildcodeschool.com/quests/2294/pages/8111#-rappel-sur-le-boot)
		- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/2294/pages/8111#-exercice)
		- [🔍 Les noms des périphériques avec LVM](https://odyssey.wildcodeschool.com/quests/2294/pages/8111#-les-noms-des-p%C3%A9riph%C3%A9riques-avec-lvm)
- [👉 Expérimentations avec LVM](https://odyssey.wildcodeschool.com/quests/2294/pages/8111#-exp%C3%A9rimentations-avec-lvm)
	- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/2294/pages/8111#-exercice-1)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2294/pages/8111#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2294/pages/8111#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2294/pages/8111#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2294/pages/8111#-crit%C3%A8res-dacceptation)

## 👉 Les concepts de LVM

Commençons par une courte vidéo pour découvrir les principaux concepts de LVM.

Comme tu as pu le voir, la gestion du stockage avec LVM s'appuie sur 3 notions principales:

- Les *Physical Volume* ou PV  
	C'est, en quelques sorte, le nom qu'utilise LVM por désigner les supports de stockage physiques. Chaque PV est en général une partition sur un disque dur classique ou un SSD.
- Les *Volume Group* ou VG  
	Comme son nom l'indique, il s'agit d'un groupe de volumes physiques, donc d'un ensemble d'au moins un PV. Chaque VG sert à regrouper l'ensemble de l'espace de tous les PV qu'il contient en une seule réserve dont la taille est environ la somme des tailles des PV.
- Les *Logical Volume* ou LV  
	Avec LVM, ce sont les LV que l'on utilisera à la place des partitions. Ce sont donc les LV que l'on formatera avec un système de fichier tel que ext4.

Continue ta découverte avec la lecture de la ressource suivante:

```shell
An Introduction to LVM Concepts, Terminology, and OperationsCet article de DigitalOcean développe un peu plus les concepts de LVM et déroule un cours exemple d'utilisation.https://www.digitalocean.com/community/tutorials/an-introduction-to-lvm-concepts-terminology-and-operations
```

---

## 👉 Installation d'un système avec LVM

Les programmes *assistants d'installation* de la plupart des distribution GNU/Linux permettent d'installer son système sur LVM.

## 📚 Rappel sur le boot

Une petite parenthèse s'impose pour revenir sur le démarrage (*boot*) d'un système d'exploitation en général et d'un linux en particulier.

Le BIOS ou le UEFI qui équipe les cartes mères ne comprends pas LVM. Aussi le [*bootloader*](https://fr.wikipedia.org/wiki/Chargeur_d%27amor%C3%A7age) et l'éventuelle partition ESP ne peuvent-elles pas être sur un LV.

[GNU Grub](https://fr.wikipedia.org/wiki/GNU_GRUB) qui est le chargeur d'amorçage habituellement utilisé pour démarrer Linux comprend LVM, néanmoins la plupart des installeurs de distribution Linux font néanmoins le choix de déporter la partition `/boot` sur une partition séparée, hors du PV, laissant ainsi au noyau Linux la charge d'initialiser et des monter les LV.

## 🔬 Exercice

Installation d'un système debian avec LVM

Sur une machine de test, par exemple une machine virtuelle, installe un système Debian dont le support d'installation peut être récupérer sur [le site officiel](https://www.debian.org/).

Lors du choix du partitionnement, selectionne:

- Assisté - utiliser tout un disque avec LVM
- Partition /home séparée

On obtient ainsi `/` et `/home` dans 2 volumes logiques différents.

Une fois l'installation terminée, tu peux vérifier que ces 2 systèmes de fichiers sont bien sur LVM à l'aide de diverses commandes, telles que:

- `lsblk` qui affiche la liste des périphériques bloc et leur type donc aussi la liste des LV
- `pvs`, `vgs` et `lvs` qui affichent la liste courte des PV, VG et LV
- `pvdisplay`, `vgdisplay` et `lvdisplay` qui affichent le détail des PV, VG et LV
```shell
Les commandes LVM permettant d'interagir avec le stockage du système, elles nécessitent les droits root pour être exécutées.
```

Exemple

```shell
1
root@debian:~# lsblk 
2
NAME                  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
3
sda                     8:0    0    8G  0 disk 
4
├─sda1                  8:1    0  487M  0 part /boot
5
├─sda2                  8:2    0    1K  0 part 
6
└─sda5                  8:5    0  7,5G  0 part 
7
  ├─debian--vg-root   254:0    0  2,8G  0 lvm  /
8
  ├─debian--vg-swap_1 254:1    0  976M  0 lvm  [SWAP]
9
  └─debian--vg-home   254:2    0  3,8G  0 lvm  /home
10
sr0                    11:0    1 1024M  0 rom  
11
root@debian:~# /sbin/pvs
12
  PV         VG        Fmt  Attr PSize  PFree
13
  /dev/sda5  debian-vg lvm2 a--  <7,52g    0 
14
root@debian:~# /sbin/vgs
15
  VG        #PV #LV #SN Attr   VSize  VFree
16
  debian-vg   1   3   0 wz--n- <7,52g    0 
17
root@debian:~# /sbin/lvs
18
  LV     VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
19
  home   debian-vg -wi-ao----  <3,76g                                                    
20
  root   debian-vg -wi-ao----  <2,81g                                                    
21
  swap_1 debian-vg -wi-ao---- 976,00m                                                    
22
root@debian:~# /sbin/pvdisplay 
23
  --- Physical volume ---
24
  PV Name               /dev/sda5
25
  VG Name               debian-vg
26
  PV Size               7,52 GiB / not usable 2,00 MiB
27
  Allocatable           yes (but full)
28
  PE Size               4,00 MiB
29
  Total PE              1925
30
  Free PE               0
31
  Allocated PE          1925
32
  PV UUID               4BDQRF-inbt-ef0W-1t7R-OC08-kcpv-2lI8En
33
   
34
root@debian:~# /sbin/vgdisplay 
35
  --- Volume group ---
36
  VG Name               debian-vg
37
  System ID             
38
  Format                lvm2
39
  Metadata Areas        1
40
  Metadata Sequence No  4
41
  VG Access             read/write
42
  VG Status             resizable
43
  MAX LV                0
44
  Cur LV                3
45
  Open LV               3
46
  Max PV                0
47
  Cur PV                1
48
  Act PV                1
49
  VG Size               <7,52 GiB
50
  PE Size               4,00 MiB
51
  Total PE              1925
52
  Alloc PE / Size       1925 / <7,52 GiB
53
  Free  PE / Size       0 / 0   
54
  VG UUID               r48g5b-XSgY-ffFO-tXEQ-UtUH-jRTP-HFbrBu
55
   
56
root@debian:~# /sbin/lvdisplay 
57
  --- Logical volume ---
58
  LV Path                /dev/debian-vg/root
59
  LV Name                root
60
  VG Name                debian-vg
61
  LV UUID                PdrQ72-5paR-T1HN-LOUU-OHfr-mg3x-f0Ir28
62
  LV Write Access        read/write
63
  LV Creation host, time debian, 2022-10-10 10:15:54 +0200
64
  LV Status              available
65
  # open                 1
66
  LV Size                <2,81 GiB
67
  Current LE             719
68
  Segments               1
69
  Allocation             inherit
70
  Read ahead sectors     auto
71
  - currently set to     256
72
  Block device           254:0
73
   
74
  --- Logical volume ---
75
  LV Path                /dev/debian-vg/swap_1
76
  LV Name                swap_1
77
  VG Name                debian-vg
78
  LV UUID                0nI8rJ-iaXu-Lddz-l3QH-2IcB-t1Ac-QA3iPb
79
  LV Write Access        read/write
80
  LV Creation host, time debian, 2022-10-10 10:15:54 +0200
81
  LV Status              available
82
  # open                 2
83
  LV Size                976,00 MiB
84
  Current LE             244
85
  Segments               1
86
  Allocation             inherit
87
  Read ahead sectors     auto
88
  - currently set to     256
89
  Block device           254:1
90
   
91
  --- Logical volume ---
92
  LV Path                /dev/debian-vg/home
93
  LV Name                home
94
  VG Name                debian-vg
95
  LV UUID                HUayQA-CmD4-eN9X-Fmhc-ntc3-ySmK-kzuLBT
96
  LV Write Access        read/write
97
  LV Creation host, time debian, 2022-10-10 10:15:54 +0200
98
  LV Status              available
99
  # open                 1
100
  LV Size                <3,76 GiB
101
  Current LE             962
102
  Segments               1
103
  Allocation             inherit
104
  Read ahead sectors     auto
105
  - currently set to     256
106
  Block device           254:2
107
   
108
root@debian:~#
```

Premier constat: il semble y avoir 3 partitions sur le disque

- Une pour /boot
- Une partition de 1k inutilisée
- Une partition servant de PV pour LVM

En fait il s'agit d'un schéma de partitionnement MBR avec une partition primaire pour `/boot` et une partition logique pour le PV `/dev/sda5`, et donc avec une partition étendue pour héberger les partitions logiques.

On peut d'ailleurs s'en assurer avec `fdisk`

```shell
1

2
root@debian:~# /sbin/fdisk -l /dev/sda
3
Disque /dev/sda : 8 GiB, 8589934592 octets, 16777216 secteurs
4
Modèle de disque : VBOX HARDDISK   
5
Unités : secteur de 1 × 512 = 512 octets
6
Taille de secteur (logique / physique) : 512 octets / 512 octets
7
taille d'E/S (minimale / optimale) : 512 octets / 512 octets
8
Type d'étiquette de disque : dos
9
Identifiant de disque : 0xe6c68e40
10

11
Périphérique Amorçage   Début      Fin Secteurs Taille Id Type
12
/dev/sda1    *           2048   999423   997376   487M 83 Linux
13
/dev/sda2             1001470 16775167 15773698   7,5G  5 Étendue
14
/dev/sda5             1001472 16775167 15773696   7,5G 8e LVM Linux
15
root@debian:~# 
16
```

Le `type d'étiquette de disque` indique `dos` qui est le nom d'un partitionnement MBR pour `fdisk`.  
`/dev/sda2 ` est bien indiquée comme une partition étendue. Elle fait d'ailleurs la même taille que `dev/sda5` puisque cette dernière occupe tout l'espace disponible.

C'est l'occasion de vérifier que cette seconde partition `/dev/sda5` porte bien une étiquette `LVM Linux`

Si besoin, la ressource suivante permet de réviser un peu le fonctionnement de MBR.

```shell
Partitions primaires et logiques sur qastack.frCette discussion permet de revoir les notions de partitions primaire, étendue et logique dans le schéma de partitionnement MBRhttps://qastack.fr/superuser/337146/what-are-the-differences-between-primary-and-logical-partition
```

En ce qui concerne LVM, on a un VG `debian-vg` constitué de l'unique PV `/dev/sda5` dont tout l'espace disponible a été alloué aux 3 LV. En effet, le nombre de `Free PE` est 0.

Les 3 LV sont:

- `home`: monté sur `/home`
- `root`: monté sur `/root`
- `swap_1`: qui sert d'espace de swap
```shell
Fonctionnalité intéréssante de LVM : les VG et les LV peuvent être nommés librement.

C'est donc l'occasion de rendre notre gestion du stockage facile à comprendre en choissisant judicieusement les noms utilisés.
Il est courant de préfixer (ou de suffixer) les nom de groupes de volumes avec vg et ceux des volumes logiques avec lv.

Quelques exemples :

fastvg : Le VG avec les disques SSD du systèmes
large-vg : Le VG avec beaucoup d'espace de stockage (et donc probablement moins rapide)
lvlog : Le LV contenant les log (monté sur /var/log par exemple)
db_lv : Le LV hébergeant les fichiers de la base de données
```

Vérifions que ces systèmes de fichiers sont bien monté au démarrage via `/etc/fstab`

```shell
1
root@debian:/dev# cat /etc/fstab 
2
# /etc/fstab: static file system information.
3
#
4
# Use 'blkid' to print the universally unique identifier for a
5
# device; this may be used with UUID= as a more robust way to name devices
6
# that works even if disks are added and removed. See fstab(5).
7
#
8
# systemd generates mount units based on this file, see systemd.mount(5).
9
# Please run 'systemctl daemon-reload' after making changes here.
10
#
11
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
12
/dev/mapper/debian--vg-root /               ext4    errors=remount-ro 0       1
13
# /boot was on /dev/sda1 during installation
14
UUID=4390e93b-48f7-4e0c-8b6e-df33f579bada /boot           ext2    defaults        0       2
15
/dev/mapper/debian--vg-home /home           ext4    defaults        0       2
16
/dev/mapper/debian--vg-swap_1 none            swap    sw              0       0
17
/dev/sr0        /media/cdrom0   udf,iso9660 user,noauto     0       0
18
root@debian:/dev# 
19
```

## 🔍 Les noms des périphériques avec LVM

Tu as sans doute remarqué que les LV sont chacun référencés à l'aide de plusieurs chemins.

`lvdisplay` indique par exemple `/dev/<vgname>/<lvname>` mais dans `/etc/fstab` on croise plutôt `/dev/mapper/<vgname>-<lvname>`.  
Les fichiers représentant réellement les LV dans `/dev` sont en fait des pseudo-fichiers qui s'appellent `dm-<numéro>`

Les autres noms sont des liens symboliques et on peut donc utiliser n'importe lequel de ces noms en privilégiant sans dout ceux qui sont plus lisibles (donc pas les `/dev/dm-<numéro>`)

Vérifions:

```shell
1
root@debian:~# ls -l /dev/dm*
2
brw-rw---- 1 root disk 254, 0 10 oct.  11:15 /dev/dm-0
3
brw-rw---- 1 root disk 254, 1 10 oct.  11:15 /dev/dm-1
4
brw-rw---- 1 root disk 254, 2 10 oct.  11:15 /dev/dm-2
5
root@debian:~# ls -l /dev/mapper/
6
total 0
7
crw------- 1 root root 10, 236 10 oct.  11:15 control
8
lrwxrwxrwx 1 root root       7 10 oct.  11:15 debian--vg-home -> ../dm-2
9
lrwxrwxrwx 1 root root       7 10 oct.  11:15 debian--vg-root -> ../dm-0
10
lrwxrwxrwx 1 root root       7 10 oct.  11:15 debian--vg-swap_1 -> ../dm-1
11
root@debian:~# ls -l /dev/debian-vg/
12
total 0
13
lrwxrwxrwx 1 root root 7 10 oct.  11:15 home -> ../dm-2
14
lrwxrwxrwx 1 root root 7 10 oct.  11:15 root -> ../dm-0
15
lrwxrwxrwx 1 root root 7 10 oct.  11:15 swap_1 -> ../dm-1
16
root@debian:~#
```

## 👉 Expérimentations avec LVM

LVM comprends un ensemble de commandes qui suivent en général le format <cible><operation> avec:

- <cible> = pv, vg ou lv selon ce sur quoi l'on souhaite agir
- <operation> = create, display, scan, change, remove, etc. selon l'action que l'on souhaite faire.

La documentation suivante en décrit la plupart en les regroupant selon des cas d'usage.

```shell
LVM sur Wiki ubuntu-frCette page reprend les concepts de LVM ainsi qu'une liste assez complète d'opérations classiques avec LVM en détaillant les commandes pour y arriver.https://doc.ubuntu-fr.org/lvm
```

## 🔬 Exercice

Voici quelques exemples d'expérimentations pouvant être effectuées:

- Ajouter un nouveau PV au VG.
- Créer un nouveau VG à l'aide d'un (ou de plusieurs) autre(s) PV.
- Ajouter un nouveau LV, le formater avec un système de fichier et le monter au démarrage de la machine.
- Ajouter ou convertir un LV en RAID 1
- Ajouter ou convertir un LV en RAID 0
- Faire un snapshot d'un LV (à condition d'avoir de la place dans le VG) et le monter pour avoir une copie
- Détruire un LV plus nécessaire, comme par exemple un snapshot dont on a plus l'usage.
- ...
```shell
Astuce : Dans le cas d'expérimentations sur une machine virtuelle, faire un snapshot de la VM avant de faire des manipulation permet très facilement et rapidement de revenir à l'état initial.
```

---

## ☝️ Résumé

LVM pour Logical Volume Manager permet sur un système Linux une gestion très flexible du stockage.  
Il s'appuie sur les concepts de volume physique, de groupe de volumes et de volume logique en organisant le stockage par *extends*.

---

## 📝 Quiz

```shell
# 1  - Est-il possible d'augmenter la taille d'un volume logique après sa création ? OuiNonValider# 2 Au niveau du Volume GroupAu niveau du Logical VolumeAu niveau du Physical VolumeValider# 3 VraiFauxValider# 4 vgaddpvmovevgextendpvchangeValiderTon score :0 / 4
```

---

## 💪 Challenge

Le challenge consiste, en partant d'une machine debian telle que celle installée au début de cette quête, à suivre une succession d'étapes visant à effectuer des opérations classiques sur LVM.

À chaque étape, des commandes doivent être saisies pour afficher l'état du système avant les opérations et après les opérations pour pouvoir constater les modifications effectuées.

L'ensemble des commandes et leurs affichages sont à recopier dans la solution de cette quête

1. Ajoute un nouveau disque à la machine et ajoute le au groupe de volume `debian-vg` pour au moins doubler l'espace du groupe de volume
2. Créer un snapshot de LV `home`
3. Monte le snapshot créé sur `/home-snap`
4. Constate que `/home-snap` est bien une copie de `/home`
5. On peut alors travailler sur `/home-snap` et y faire des modifications. En supposant qu'on a maintenant plus besoin de la copie, démonte `/home-snap`
6. Détruit le snapshot

## 🧐 Critères d'acceptation

Les commandes et leurs affichages permettent bien de constater:

1. L'ajout d'un PV à `debian-vg` et au moins le doublement des `Total PE`
2. La création d'un snapshot du LV `home`
3. Il y a bien création d'un dossier `home-snap` et montage du snapshot dans ce dossier
4. L'affichage du contenu de `home-snap` affiche un contenu identique à `/home`
5. L'affichage des systèmes de fichiers actuellement montés n'affiche plus `/home-snap`
6. L'affichage des LV n'affiche plus le snapshot et le LV `home` n'est plus la source d'aucun snapshot

---

Contribuer à améliorer cette quête.Tous les retours sont précieux pour l'amélioration de nos formations.

Le contenu de la quête m'a permis de comprendre les concepts et d'atteindre les objectifs annoncés:

---

Un commentaire pour nous aider à mieux comprendre?