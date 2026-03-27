---
title: "Atelier : Gestion avancée de LVM - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3054/pages/11596"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
GNU/Linux

## Atelier: Gestion avancée de LVM

Moyen

1h

Auto-validation

GNU/Linux

## Atelier: Gestion avancée de LVM

## Introduction

Cet atelier va t'initier à la gestion avancée des partitions sous Linux en utilisant LVM (*Logical Volume Manager*). En suivant les différentes étapes, tu vas pouvoir créer, gérer, et manipuler les différents éléments de LVM.

![image avec plusieurs disques à gauche une flche de la gauche vers la droite et un gros disque à droite](https://storage.googleapis.com/quest_editor_uploads/YD8e5f75ddR5nZqkl0231muhqQjoZHm6.png)

## 🤓 Objectifs:

✅ Manipuler des PV, VG, et LV  
✅ Effectuer des actions avancées sur LVM

## sommaire

- [✔️ Étape 1 - Prérequis](https://odyssey.wildcodeschool.com/quests/3054/pages/11596#%EF%B8%8F-%C3%A9tape-1---pr%C3%A9requis)
- [🔬 Étape 2 - Initialisation et création des LV](https://odyssey.wildcodeschool.com/quests/3054/pages/11596#-%C3%A9tape-2---initialisation-et-cr%C3%A9ation-des-lv)
- [🔬 Étape 3 - Formatage et montage de FS](https://odyssey.wildcodeschool.com/quests/3054/pages/11596#-%C3%A9tape-3---formatage-et-montage-de-fs)
- [🔬 Étape 4 - Étendre le LV](https://odyssey.wildcodeschool.com/quests/3054/pages/11596#-%C3%A9tape-4---%C3%A9tendre-le-lv)
- [🔬 Étape 5 - Ajout d'un disque au PV existant](https://odyssey.wildcodeschool.com/quests/3054/pages/11596#-%C3%A9tape-5---ajout-dun-disque-au-pv-existant)
- [🔬 Étape 6 - Création d'un snapshot](https://odyssey.wildcodeschool.com/quests/3054/pages/11596#-%C3%A9tape-6---cr%C3%A9ation-dun-snapshot)
- [🔬 Étape 7 - Redimensionnement d'un LV](https://odyssey.wildcodeschool.com/quests/3054/pages/11596#-%C3%A9tape-7---redimensionnement-dun-lv)

## ✔️ Étape 1 - Prérequis

Pour cet atelier, tu as besoin:

- Un hyperviseur comme VirtualBox pour pouvoir créer des VM
- 1 VM avec debian 12 installé et mise-à-jour, avec en plus du disque système:
	- Un disque de 10 Go
		- Un disque de 20 Go
		- Un disque de 25 Go
- Pendant l'installation de Debian: Lorsque tu arrives à l'étape de partitionnement du disque dur, choisis l'option "Manuel".  
	Crée les partitions suivantes:
	- Système de 8 Go pour /,
		- Swap, d'une taille supérieure ou égale à la quantité de RAM disponible sur la VM,
		- /home utilise le reste de l'espace disque principal.

Points de montage: Associe la partition que tu as créée au point de montage /home.

```shell
Les expérimentations pratiques ont été testées avec Debian 12. Cette VM fonctionne sur VirtualBox 7, lui-même fonctionnant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites avec d'autres versions de systèmes, et sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## 🔬 Étape 2 - Initialisation et création des LV

```shell
En général, lvm est installé déjà sur le système. On peut le vérifier avec les commandes lvm version ou apt list --installed lvm2.
Si ce n'est pas le cas, installe le :
1
sudo apt install lvm2
```

Utilisation de 2 disques de 10 et 20 Go.

- Identifier les 2 disques non-système avec `fdisk -l`, normalement **/dev/sdb** et **/dev/sdc**.
- Initialiser les disques pour l'utilisation de LVM avec la commande `pvcreate` sur chacun des 2 disques.
- Créer un groupe de volume **vg\_datas** avec la commande `vgcreate` avec les 2 disques
- Vérifier avec `vgdisplay` que la création s'est bien passée (tu dois avoir un **VG Size** de la taille totale des 2 disques)
- Créer un volume logique **lv\_datas** de 25 Go avec la commande `lvcreate`:
```bash
1
lvcreate -L 25G -n lv_datas vg_datas
```
```shell
L'option '-L' Spécifie la taille du volume logique. Dans cet exemple, le volume logique aura une taille de 25 gigaoctets.
L'option -n Définit le nom du volume logique. Ici, le nom sera "lv_datas". Il est important de choisir un nom descriptif pour identifier facilement le volume logique.
vg_datas indique le groupe de volumes (VG) auquel le volume logique sera ajouté. Un groupe de volumes est un ensemble de volumes physiques (PV) regroupés pour faciliter la gestion du stockage. Dans ce cas, le volume logique lv_datas sera créé dans le groupe de volumes vg_datas.
```
- Vérifier avec `lvdisplay` que tout est bien crée (tu dois avoir un **LV Size** de la taille que tu as choisi).
- Essaye maintenant de créer un volume logique de 35Go? observe le résultat.

## 🔬 Étape 3 - Formatage et montage de FS

Avant de pouvoir utiliser un volume logique, il faut le formater avec un système de fichiers. Nous allons utiliser ext4:

```bash
1
mkfs.ext4 /dev/vg_datas/lv_datas
```
- Création d'un point de montage avec montage du LV: Pour accéder aux données d'un volume logique, il faut le monter sur un répertoire. Nous allons créer le répertoire /mnt/datas et y monter le volume logique lv\_datas.
```bash
1
mkdir /mnt/datas
2
mount /dev/vg_data/lv_data /mnt/datas
```
- Pour le montage automatique au démarrage, ajouter au fichier **/etc/fstab** la ligne `/dev/vg_datas/lv_datas /mnt/datas ext4 defaults 0 2`

## 🔬 Étape 4 - Étendre le LV

- Pour vérifier la place restante sur le VG, exécuter `vgs`
- Pour etendre le LV avec la place restante:
```bash
1
lvextend -l +100%FREE /dev/vg_datas/lv_datas
```
- Ensuite il faut étendre le FS:
```bash
1
resize2fs /dev/vg_datas/lv_datas
```
- Vérifier avec `lvs` que l'opération a réussi

## 🔬 Étape 5 - Ajout d'un disque au PV existant

Utilisation du disque de 25 Go.

- Initialiser le nouveau disque:
```bash
1
# On estime que le nouveau disque est /dev/sdd
2
pvcreate /dev/sdd
```
- Ajouter ce nouveau disque au PV existant:
```bash
1
vgextend vg_datas /dev/sdd
```
- Vérifier avec `vgs` que l'information de **VFree** correspond à la taille du disque ajouté
- Créer un nouveau LV **lv\_datas2** de 15 Go:
```bash
1
lvcreate  -L 15G -n lv_datas2 vg_datas
```
- Formater ce LV:
```bash
1
mkfs.ext4 /dev/vg_datas/lv_datas2
```
- Effectuer le montage:
```bash
1
mkdir /mnt/datas2
2
mount /dev/vg_datas/lv_datas2 /mnt/datas2
```
- Ajouter dans le fichier **/etc/fstab** la ligne `/dev/vg_datas/lv_datas2 /mnt/datas2 ext4 defaults 0 2`

## 🔬 Étape 6 - Création d'un snapshot

Avant de commencer: créé un fichier dans le dossier /mnt/datas2:

```bash
1
echo "Contenu avant création du snapshot !" > /mnt/datas2/test_file.txt
```

Exécute maintenant les commandes suivantes pour faire un snapshot et monter ce snapshot dans `/mnt/datas_snap`:

```bash
1
lvcreate --size 5G --snapshot --name lv_datas_snap /dev/vg_datas/lv_datas2
2
mkdir /mnt/datas_snap
3
mount /dev/vg_datas/lv_datas_snap /mnt/datas_snap/
```

Vérifie le contenu du snapshot:

```bash
1
ls /mnt/datas2
2
ls /mnt/datas_snap
```

> Si c'est bien un snapshot, le contenu de **datas\_snap** est identique à celui de **lv\_datas2**

Créé un fichier dans le répertoire /mnt/datas2:

```bash
1
echo "Après création du snapshot" > /mnt/datas2/test_file1.txt
```

Vérifie si ce fichier apparaît également dans le snapshot ou s'il est bien maintenant indépendant du sa source.

Pour supprimer le snapshot:

```bash
1
umount /mnt/datas_snap
2
lvremove /dev/vg_datas/lv_datas_snap
```

## 🔬 Étape 7 - Redimensionnement d'un LV

```shell
Avant de redimensionner le système de fichiers, il est fortement recommandé d'en vérifier l'intégrité avec e2fsck.
```
- Tout d'abord, il faut le démonter avec `umount /mnt/datas`
- Pour le redimensionner à 15 Go:
```bash
1
lvresize -L 15G /dev/vg_datas/lv_datas
```
```shell
Un message d'alerte te prévient que tes données ainsi que ton FS peuvent être détruite !

C'est normal car tu vas réduire la taille.

LVM ne gère pas les données, donc même si le LV est vide, comme ici, tu as le message d'alerte.
```
- Ne pas oublier de redimensionner le FS:
```bash
1
resize2fs /dev/vg_datas/lv_datas
```

Pourquoi cela ne marche pas?  
Comme indiqué à l'écran, essaye d'exécuter la commande `e2fsck -f /dev/vg_datas/lv_datas`.  
Est-ce que cela marche?

Tu as ce message, et les erreurs associées car la taille du FS dépasse actuellement la taille physique du LV.  
Tu as ce dysfonctionnement car tu as réduit la taille du LV sans réduire d'abord la taille du FS! Cette manipulation amène une corruption dans la structure du FS.

- Pour pouvoir faire cela correctement, il faut tout d'abord revenir à la taille initiale du LV:
```bash
1
lvresize -L 29.99G /dev/vg_datas/lv_datas
```
- Puis tu peux réparer le FS:
```bash
1
e2fsck -f /dev/vg_datas/lv_datas
```
- Cela va te permettre de réduire le FS:
```bash
1
resize2fs /dev/vg_datas/lv_datas 15G
```
- Uniquement là tu peux réduire la taille du LV:
```bash
1
lvresize -L 15G /dev/vg_datas/lv_datas
```
- Tu peux vérifier que l'opération a réussi avec la commande:
```bash
1
e2fsck -f /dev/vg_datas/lv_datas
```

Valide l'atelier si tu as réussi à gérer LVM comme demandé.

Quête terminée le **mercredi 11 février 2026**