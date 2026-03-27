---
title: "Proxmox : Mise en place de VM - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2410/pages/9970"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Virtualisation

## Proxmox: Mise en place de VM

Moyen

1h

Auto-validation

Virtualisation

## Proxmox: Mise en place de VM

## Introduction

Après avoir installé Proxmox et l'avoir configuré, tu vas mettre en place des VM à partir de fichier ISO, de template, et de copie de VM.

Pour aborder cette quête au mieux, tu dois avoir fait les quêtes suivantes:

```shell
Proxmox : Installation1hVoir la quête - Proxmox : InstallationProxmox - Ajout et montage d'un disque dur30minsVoir la quête - Proxmox - Ajout et montage d'un disque durProxmox - Ajout d'un volume LVM1hVoir la quête - Proxmox - Ajout d'un volume LVM
```

## 🤓 Objectifs

✅ Savoir préparer les disques selon les données à stocker  
✅ Charger des fichiers ISO  
✅ Charger des template de VM  
✅ Préparer et configurer des VM avec des méthodes différentes

## sommaire

- [👉 Mise en œuvre](https://odyssey.wildcodeschool.com/quests/2410/pages/9970#-mise-en-%C5%93uvre)
	- [✔️ Pré-requis](https://odyssey.wildcodeschool.com/quests/2410/pages/9970#%EF%B8%8F-pr%C3%A9-requis)
		- [🔧 Modification des contenus des types de données des disques](https://odyssey.wildcodeschool.com/quests/2410/pages/9970#-modification-des-contenus-des-types-de-donn%C3%A9es-des-disques)
		- [👉 1ère méthode de création de VM: à partir d'une ISO](https://odyssey.wildcodeschool.com/quests/2410/pages/9970#-1%C3%A8re-m%C3%A9thode-de-cr%C3%A9ation-de-vm--%C3%A0-partir-dune-iso)
		- [🔧 Démarrage d'une VM](https://odyssey.wildcodeschool.com/quests/2410/pages/9970#-d%C3%A9marrage-dune-vm)
		- [👉 2ème méthode de création de VM: à partir d'une autre VM](https://odyssey.wildcodeschool.com/quests/2410/pages/9970#-2%C3%A8me-m%C3%A9thode-de-cr%C3%A9ation-de-vm--%C3%A0-partir-dune-autre-vm)
		- [👉 3ème méthode de création de VM: à partir d'un template](https://odyssey.wildcodeschool.com/quests/2410/pages/9970#-3%C3%A8me-m%C3%A9thode-de-cr%C3%A9ation-de-vm--%C3%A0-partir-dun-template)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2410/pages/9970#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2410/pages/9970#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2410/pages/9970#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2410/pages/9970#-crit%C3%A8res-dacceptation)

## 👉 Mise en œuvre

## ✔️ Pré-requis

Tu as une machine (physique ou virtuelle) avec Proxmox d'installé.  
Il t'es conseillé d'avoir trois disques durs (physiques ou virtuels) séparés dans l'idéal.  
En effet, il est plutôt recommandé d'avoir un espace dédié pour le système, un autre pour stocker les images, et un dernier pour les VM.

```shell
Cette quête a été réalisée avec un Proxmox installé sur une VM Virtualbox. L'OS hôte est un Ubuntu 22.04 LTS.

Cette VM a 3 disques durs virtuels :

Le premier de 30 Go contient le système
Le second a une taille de 80 Go et servira pour le stockage des fichiers images
Le troisième a une taille de 100 Go et stockera les VM

Chaque disque a une partition ou un volume logique prenant tout l'espace disponible.

Si tu n'as pas tout à fait cette configuration, tu dois adapter la configuration.
```

## 🔧 Modification des contenus des types de données des disques

Démarre ta machine Proxmox et connecte toi en web.

```shell
Pour rappel, on peut se connecter de 2 manières :

En CLI, directement sur la machine ou bien en ssh
Dans un navigateur web, sur l'adresse https://@IP_de_ta_machine:8006/
```

Pour modifier les contenus des espaces de stockage, vas dans `Datacenter` --> `Storage` --> `Edit`.

![Image Alt](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/proxmox-edit-type-de-donnees-des-disques.png?raw=true)

1. Sélectionne `Datacenter`
2. Puis `Storage`
3. Choisi un disque
4. Clique sur `Edit`

![Image Alt](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/proxmox-edit-repertoire-disque.png?raw=true)

Dans la fenêtre qui apparaît, mets:

- `ISO image` et/ou `Container template` si tu veux pouvoir utiliser l'espace de stockage pour les fichiers ISO et/ou pour les templates.
- `Disk image` et/ou `container` pour stocker les VM et/ou les conteneurs LXC.
```shell
Comme déjà vu, il est recommandé de séparer les sources (ici les fichiers ISO) des VM.

Par exemple :

Un espace de stockage de 80 Go qui a ISO image et Container template en Content pour les sources.
Un autre espace de stockage de 100 Go avec Disk image et container pour les VM.
```

## 👉 1ère méthode de création de VM: à partir d'une ISO

![Image Alt](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/proxmox-upload-image-iso.png?raw=true)

1. Sous `Datacenter`, sélectionne `pve`, puis le disque sur lequel tu as choisi de stocker les fichiers ISO.
2. Clique sur `ISO Images`
3. Clique sur `Upload`

![Image Alt](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/proxmox-fenetre-selection-fichier-iso.png?raw=true)

Sélectionne ton fichier ISO stocké et clique sur `Upload` pour le charger sur le serveur.

```shell
Tu peux également utiliser la fonctionnalité Download from URL pour aller chercher directement le fichier à sa source sur un autre serveur ou sur Internet.
```
```shell
Tu peux voir l'historique de toutes tes actions et où en sont certaines tâches dans le menu Tasks en bas de la fenêtre.
```

Pour créer une VM, clique en haut à droite de la fenêtre sur `Create VM`.  
Suis l'assistant de création et modifie les paramètres de la VM comme ceci:

- **General** --> **Name**: `Un nom de machine`
- **OS** --> **ISO Image**: choisi un fichier ISO que tu as uploadé
- **Disks** --> **Storage**: sélectionne le disque sur lequel tu as spécifié le **content** `Disk Image`
```shell
Ici tu peux choisir entre un disque dur Raw ou au format QEMU soit qcow2. Le Raw est un peu plus rapide que le qcow2 car il a très peu de surcharge et aucune métadonnée associée. Mais le format qcow2 a plus de fonctionnalités, comme la compression, le cryptage AES et les sauvegardes incrémentielles.
```
- **Memory** --> **Memory (MiB)**: `1024`

La VM est disponible dans le panneau de gauche, sous `pve`.

## 🔧 Démarrage d'une VM

Démarre ta VM (bouton droit --> Start) et dans le panneau de droit clique sur `Console` pour faire apparaître la fenêtre graphique de ta VM.

```shell
Le bouton Console fait apparaître ta VM dans une fenêtre intégrée à Proxmox.

Si tu fais bouton droit sur ta VM et que tu choisisse Console dans le menu, ta VM va apparaître dans une fenêtre flottante.
```

Installe ta VM.

```shell
Lien vers la doc officielleChapitre concernant la mise en place des VMhttps://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_virtual_machines
```
```shell
Tutoriel complet de la création d'une VM à partir d'une ISOTutoriel extrait d'un blog qui peut t'aider si tu as des difficultés.https://artheodoc.files.wordpress.com/2021/12/exemple_de_creation_d_une_machine_virtuelle_debian_11_sous_proxmox_ve_7_1.pdf
```

## 👉 2ème méthode de création de VM: à partir d'une autre VM

Il faut sélectionner une VM dans la fenêtre de gauche et faire bouton droit --> **Convert to template**.  
Ensuite, il faut **cloner** la VM pour une 2ème VM identique.

```shell
Lien vers la doc officielleChapitre concernant le clonage de VMhttps://pve.proxmox.com/pve-docs/pve-admin-guide.html#qm_copy_and_clone
```
```shell
Tutoriel complet sur le clonage d'une VMTutoriel extrait d'un blog qui peut t'aider si tu as des difficultés.https://artheodoc.files.wordpress.com/2021/12/cloner_une_machine_virtuelle_sous_proxmox_7_1_exemple_avec_une_vm_debian_11.pdf
```

## 👉 3ème méthode de création de VM: à partir d'un template

**Upload d'un template**:

- Sélectionne un disque configuré avec un **Content** `Container template`
- Vas sur **CT Templates** puis **Templates** et une fenêtre va s'ouvrir avec la liste des templates disponible

![Image liste des templates disponibles](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/proxmox-fenetre-liste-templates.png?raw=true)

- Sélectionne un template et télécharge-le.
- Une fois le téléchargement terminé il apparaîtra dans la liste des template téléchargés.

**Création de VM**:

- Clique en haut à droite de la fenêtre sur **Create CT**.
- Créer une VM comme ceci:
	- **General** --> **Hostname**: `Un nom de machine`
		- **General** --> **Password**: `Un mot de passe`
		- **Template** --> **Template**: `Un template téléchargé`
		- **Disks** --> **Disk size (GiB)**: `20`

**Lancement de la VM**:

A la différence d'une installation complète, ici tu as directement une VM pré-configurée.

---

## ☝️ Résumé

Les différents espaces de stockage peuvent être configurés pour avoir des types de données différentes.  
Cette séparation des données est une bonne pratique.  
On peut créer une VM à partir d'un fichier ISO, d'un template, ou à partir d'une autre VM en la clonant.

---

## 📝 Quiz

```shell
# 1  - Il y a 3 possibilités pour avoir une VM sous proxmoxVraiFauxValider# 2 VraiFauxValider# 3 VraiFauxValider# 4 VraiFauxValiderTon score :0 / 4
```

---

## 💪Challenge

Crée des VM avec les 3 méthodes citées ci-dessus.

## 🧐 Critères d'acceptation

Avoir 3 VM fonctionnelles créées à partir des 3 méthodes.

Quête terminée le **vendredi 02 janvier 2026**