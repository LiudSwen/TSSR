---
title: "Atelier : File system - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2860/pages/11217"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
GNU/Linux

## Atelier: File system

Facile

2h

Auto-validation

GNU/Linux

## Atelier: File system

## Introduction

Dans cet atelier, tu vas apprendre à monter (et démonter) manuellement (ou automatiquement) les partitions d'un système.  
Tu vas également modifier le système de fichiers de ces partitions en utilisant les systèmes de fichiers ext4, et xfs ou btrfs.

## 🤓 Objectifs:

✅ Savoir créer des partitions sur un disque dur  
✅ Formater une partition avec un système de fichier  
✅ Monter et démonter une partition  
✅ Utiliser le fichier /etc/fstab pour gérer le montage automatique des partitions

## Sommaire

- [✔️ Prérequis](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#%EF%B8%8F-pr%C3%A9requis)
- [👉 Mise en œuvre](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#-mise-en-%C5%93uvre)
	- [🔬 Vérification](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#-v%C3%A9rification)
		- [🔬 Préparation](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#-pr%C3%A9paration)
		- [🔬 Préparation du disque /dev/sdb](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#-pr%C3%A9paration-du-disque-devsdb)
		- [Création de 2 partitions](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#cr%C3%A9ation-de-2-partitions)
				- [Formatage de la partition 1](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#formatage-de-la-partition-1)
				- [Formatage de la partition 2](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#formatage-de-la-partition-2)
				- [Effacer le MBR (optionnel)](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#effacer-le-mbr-optionnel)
		- [🔬 Préparation du disque /dev/sdc](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#-pr%C3%A9paration-du-disque-devsdc)
		- [Création d'une partition de type swap](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#cr%C3%A9ation-dune-partition-de-type-swap)
				- [Formatage de la partition SWAP](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#formatage-de-la-partition-swap)
		- [Montage des partitions du disque /dev/sdb](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#montage-des-partitions-du-disque-devsdb)
		- [Montage automatique au démarrage](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#montage-automatique-au-d%C3%A9marrage)
		- [Montage sans privilèges (user)](https://odyssey.wildcodeschool.com/quests/2860/pages/11217#montage-sans-privil%C3%A8ges-user)

## ✔️ Prérequis

Tu as besoin du matériel suivant:

- Une VM ou un hôte sous Linux avec 2 disques durs:
	- 1 disque sur lequel tu as installé l'OS
		- 1 disque de 30 Go
		- 1 disque de 8 Go
```shell
Les expérimentations pratiques ont été testées avec un OS Linux Ubuntu 22.04 LTS installé dans une machine virtuelle VirtualBox 7.0 tournant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites avec d'autres distributions Linux, sur d'autres environnement, mais des différences peuvent alors apparaître.
```
```shell
Attention :

Si tu ne maitrise pas ton OS, les modifications effectuées ici peuvent amener des dysfonctionnements sur ton ordinateur.

Pour plus de sécurité utilise une machine virtuelle.
```

## 👉 Mise en œuvre

## 🔬 Vérification

En tapant la commande `sudo fdisk -l` dans un terminal tu dois avoir la liste des disques et des partitions de ton système.  
Le disque de 30 Go devrait être associé au fichier **/dev/sdb**. Ce fichier représente le périphérique. De même, le disque de 8 Go devrait être associé à **/dev/sdc**.  
Si les disques ne sont pas sur ces fichiers, pour la suite de l’atelier tu devras modifier le code pour l'adapter à ton File System si ce n'est pas le cas.

De même avec cette commande tu vois le disque initial sur lequel est installé le système /dev/sda avec ses partitions /dev/sda1, /dev/sda2, …

Les 2 autres disques ne contiennent aucune table de partition valide, puisqu'ils n'ont pas été formatés. Ils n'ont pas d’étiquette de disque ni de partitions.

Avec `ls -l` sur les fichiers de disque (soient /dev/sda, /dev/sdb, et /dev/sdc) tu peux voir au niveau des droits d'accès une première lettre " **b** ". elle indique que c'est un périphérique en mode bloc.

```bash
1
wilder@Host:~$ ls -l /dev/sda
2
brw-rw---- 1 root disk 8, 0 mars   1 16:28 /dev/sda
```

## 🔬 Préparation

Installer les paquets pour l'utilisation du file system **XFS**:

```bash
1
wilder@Host:~$ sudo apt install xfsprogs
```

## 🔬 Préparation du disque /dev/sdb

Surtout ne te trompe pas de disque, ne formate pas **/dev/sda** qui contient ton système et tes fichiers, sinon tu as gagné un billet gratuit pour refaire entièrement ta machine (VM ou physique)!

### Création de 2 partitions

Lance l’utilitaire `cfdisk`

```bash
1
wilder@Host:~$ sudo cfdisk /dev/sdb
```

Au tout début, il faut choisir le type des tables de partition, puisque le disque est vierge:

- Gpt: le nouveau système pour les bios UEFI
- **Dos** (c'est ce qu'il faut choisir)
- Sgi et sun: pour les systèmes Unix professionnels sur gros ordinateur

Créer les partitions:

Le menu de cfdisk est en bas de la fenêtre: l'un des items est en surbrillance par exemple `[Nouvelle]`.  
Tu changes de menu à l'aide du curseur gauche-droite et tu le sélectionne à l'aide de la touche entrée.  
Le curseur haut-bas sert à changer de partition active.

- Créer la table des partitions: mettre sur `[Nouvelle]` puis appuyer sur entrée
- Créer deux partitions primaires dedans:
	- La première de 25 Go de type Linux (83)
		- La seconde avec la place restante, de type Linux (83)
		- Ne mettre aucune des deux en « Amorçable » (« bootable »). Mémorisez les noms de ces partitions: **/dev/sdb1** et **/dev/sdb2** si c'est bien ce disque.
- Enregistrer les changements de partitions avec le menu `[Ecrire]` tapez « oui », puis `[Quitter]`.

### Formatage de la partition 1

Tu la formate en **XFS** (n'oublie pas l'option **`-L`** pour spécifier le label du volume):

```bash
1
wilder@Host:~$ sudo mkfs.xfs -L HOME /dev/sdb1
```

Si tu veux reformater un volume déjà formaté, rajoute l'option `-f` pour forcer l'action.

### Formatage de la partition 2

Tu la formate en **ext4**. C'est le format le plus fréquent sur Linux.

```bash
1
wilder@Host:~$ sudo mkfs.ext4 -L DATA /dev/sdb2
```

### Effacer le MBR (optionnel)

Pour effacer le MBR d’un coup et recommencer les manipulations précédentes, écrit la ligne suivante:

```bash
1
wilder@Host:~$  sudo dd if=/dev/zero ibs=512 count=1 of=/dev/sdb
```

Pour partitionner plus simplement, tu peux utiliser l’utilitaire `gparted` (ne fonctionne pas sur une VM).  
Voici la ligne de commande à utiliser:

```bash
1
wilder@Host:~$ sudo gparted /dev/sdb
```

L'effacement du MBR supprime la table des partitions, donc intrinsèquement les partitions elles-même.

## 🔬 Préparation du disque /dev/sdc

Sur ce disque on va créer une seule et unique partition qui servira de SWAP.

### Création d'une partition de type swap

Utilise la commande suivante pour créer la partition:

```bash
1
wilder@Host:~$ sudo fdisk /dev/sdc
```

Prépare la partition pour qu'elle soit de type **SWAP**:

- `n` pour une nouvelle partition
- `p` pour une partition primaire
- `1` pour le numéro de partition
- Appuyer sur la touche Entrée pour les numéro de début et fin de premier secteur
- `t` pour définir le type de partition
- `82` pour le type de partition swap
- `w` pour ecrire la table de partitions et quitter

### Formatage de la partition SWAP

Exécute la commande suivante:

```bash
1
wilder@Host:~$ sudo mkswap /dev/sdc1
```

L'activation du swap se fait avec la commande:

```bash
1
wilder@Host:~$ sudo swapon /dev/sdc1
```

## Montage des partitions du disque /dev/sdb

Créer 2 dossiers **/mnt/home** et **/mnt/data**:

```bash
1
wilder@Host:~$ sudo mkdir /mnt/home
2
wilder@Host:~$ sudo mkdir /mnt/data
```

Monte les partitions crées et formatées dans les dossiers que tu viens de créer:

```bash
1
wilder@Host:~$ sudo mount -t xfs /dev/sdb1 /mnt/home
2
wilder@Host:~$ sudo mount -t ext4 /dev/sdb2 /mnt/data
```

Vérifie que les dossier **/mnt/home** et **/mnt/data** sont vide (avec `ls`).  
C'est normal, la partition vient d'être formatée.

Utilise la commande `df -h` ou la commande `pydf` pour lister les volumes montés et afficher la place libre. Tu vois que la partition **/dev/sdb1** n'est pas vraiment vide, un petit espace est  
occupés par le file system alors qu'elle est vide... ce sont des informations de gestion qui occupe cet espace (***les métadonnées***).

Copie les fichiers et dossier de ton home (donc **/home**) dans **/mnt/home**:

```bash
1
wilder@Host:~$ sudo cp -arT /home /mnt/home
```

Explication de `-arT`:

- `-r`: fait une copie récursive
- `-T`: indique de copier de dossier à dossier (sinon il faudrait mettre **/home/\***)
- `-a`: permet de copier aussi tous les attributs des fichiers: dates, protection...

Le site **explainshell** peut t'en apprendre plus. [Clic ici](https://explainshell.com/explain?cmd=cp+-arT) pour en savoir plus.

Rajoute des fichiers sur les 2 partitions montées afin de pouvoir vérifier la réalité du montage.

Tu peux utiliser la commande `touch` pour cela.

Tu peux démonter les partitions avec la commande `umount`.

```shell
Utilisation de la commande umount.https://debian-facile.org/doc:systeme:umount
```
```shell
Il ne faut pas être dans le dossier à démonter lorsque l'on utilise umount.
```

Vérifie que les fichiers ne sont plus présent dans les dossiers sous /mnt.  
Le point de montage reste, mais il est vide.

## Montage automatique au démarrage

Édite le fichier **/etc/fstab**, il faut y rajouter les lignes suivantes.

```bash
1
# montage de home sur la partition xfs
2
/dev/sdb1 /home xfs defaults 0 2
3
# montage de data sur la partition ext4
4
/dev/sdb2 /mnt/data ext4 defaults 0 2
5
# montage de la partition de swap
6
/dev/sdc1  none  swap  sw  0  0
```

Ne pas oublier de commenter avec **#** la ligne déjà présente pour le swap.

Ensuite, utilise la commande `mount -a` pour vérifier l'état du fichier **fstab**.  
Après, redémarre la VM.

Maintenant, **/home** est maintenant associé au volume **sdb1**: les fichiers que tu as crée tout à l'heure se retrouve dans le home.  
Les commandes `mount` et `df` montrent également comment sont faits les montages:

```bash
1
wilder@Host:~$ mount | grep sdb
2
wilder@Host:~$ df -h
3
wilder@Host:~$ pydf
```

Avec **df -h** on voit que **/dev/sdb2** est monté sur **/mnt/data**  
Vérifie que tu as à nouveau les fichiers crée tout à l'heure sur **/mnt/data**.

Pour finir, tu peux démonter **/dev/sdb1** ou **/home** afin de récupérer l'environnement normal.  
Si tu as un message disant que le **device est busy**, c'est que tu es dedans ou qu'un logiciel utilise ce dossier.  
Si tu es bloqué, exécute la commande suivante:

```bash
1
wilder@Host:~$ sudo umount -l /home
```

Pour vraiment finir, il faut commenter ce que tu as rajouté dans **/etc/fstab**, sinon au prochain démarrage, ce sera le volume **XFS** qui sera de nouveau monté sur **/home**.  
Donc, mets un **#** devant la ligne **/dev/sdb1**.

## Montage sans privilèges (user)

On va modifier les options de montage de **/dev/sdb2** sur **/mnt/data**. D'abord, il faut la démonter:

```bash
1
wilder@Host:~$ sudo umount -l /dev/sdb2
```

Essaye pour commencer de monter **/dev/sdb2** en tant que simple utilisateur, sans mettre de `sudo` devant la commande, en voici 3 à tester successivement:

```bash
1
wilder@Host:~$ mount /dev/sdb2 /mnt/data
2
wilder@Host:~$ mount /dev/sdb2
3
wilder@Host:~$ mount /mnt/data
```

Normalement, il doit chaque fois y avoir une erreur: **« can't find in /etc/fstab »** ou **« only root can do that »**.  
On va maintenant modifier la ligne concernée dans **/etc/fstab** qui permet à un utilisateur sans privilège de monter la 2e partition.

```bash
1
# montage de data sur la partition ext4 : possible pour un utilisateur
2
/dev/sdb2 /mnt/data ext4 noauto,rw,user,exec 0 0
```

Refais les tentatives de montage et cette fois-ci l'une des deux dernières, par le device, ou par le point de montage, doit réussir. C'est grâce au mot clé **user** dans les options de montage.

Démonte les volumes puis enlève ou commente les lignes dans **/etc/fstab** afin de ne plus rien monter au démarrage.

Quête terminée le **mardi 28 octobre 2025**