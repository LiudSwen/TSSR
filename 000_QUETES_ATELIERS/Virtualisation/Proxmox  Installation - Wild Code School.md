---
title: "Proxmox : Installation - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2409/pages/13713"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Virtualisation

## Proxmox: Installation

Facile

1h

Auto-validation

Virtualisation

## Proxmox: Installation

## Introduction

**Proxmox** est un **hyperviseur de type 1**, c'est-à-dire une plateforme de virtualisation directement installée sur le matériel.  
C'est un logiciel open source (sous licence libre GNU AGPL 3) qui permet de créer et de gérer des machines virtuelles (*virtual machine* ou ***VM***) et des conteneurs avec une GUI en web.

Comme tout hyperviseur, qu'il soit de type 1 ou 2, **Proxmox** a besoin d'une quantité conséquente de mémoire RAM, d'espace de stockage, et de processeurs.  
En effet, un hyperviseur repartit les ressources matérielles de la machine hôte entre plusieurs VM, ce qui requiert d'importantes ressources.  
Néanmoins, dans un lab, comme dans cette quête, la puissance et le nombre de processeur sont des facteurs généralement moins importants.

**Proxmox** en tant qu'hyperviseur de type 1 est normalement installé **directement** sur une machine physique en guise d'OS. C'est la raison pour laquelle on qualifie parfois ce type d'hyperviseur de *bare metal*.

Dans cette quête tu vas installer Proxmox dans une VM Virtualbox.  
Cette installation a ces avantages:

- Cela permet de tester Proxmox sans avoir à consacrer un ordinateur complet pour cela
- On a une plus grande flexibilité car on peut facilement modifier les ressources de la VM
- On peut se familiariser avec le logiciel et l’interface dans un environnement sûr et contrôlé

## 📚 Pré-requis

Avant de commencer cet atelier, il est préférable d'avoir déjà terminé la quête suivante:

```shell
VirtualBox : La gestion des interfaces réseaux30minsVoir la quête - VirtualBox : La gestion des interfaces réseaux
```

## 🤓 Objectifs:

✅ Comprendre le concept et le fonctionnement des hyperviseurs  
✅ Savoir installer et configurer Proxmox

## sommaire

- [📚 Définitions](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#-d%C3%A9finitions)
- [👉 Mise en œuvre](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#-mise-en-%C5%93uvre)
	- [✔️ Prérequis](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#%EF%B8%8F-pr%C3%A9requis)
		- [⚙️ Préparation de la VM](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#%EF%B8%8F-pr%C3%A9paration-de-la-vm)
		- [🔬 Installation](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#-installation)
		- [🔑 Connexion à Proxmox](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#-connexion-%C3%A0-proxmox)
		- [🔧 Mis-à-jour des dépôts](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#-mis-%C3%A0-jour-des-d%C3%A9p%C3%B4ts)
		- [🧭 Navigation dans l'interface](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#-navigation-dans-linterface)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2409/pages/13713#-crit%C3%A8res-dacceptation)

## 📚 Définitions

Les 2 ressources ci-dessous, permettent de définir ce que sont les hyperviseurs.

```shell
Un hyperviseur, qu'est-ce que c'est ?
Tu peux trouver sur cet article de Red Hat une introduction à la virtualisation et à ses différents concepts.https://www.redhat.com/fr/topics/virtualization/what-is-a-hypervisor
```

Même si Proxmox est un hyperviseur de type 1, et donc qu'il est prévu pour être installé directement sur un serveur physique, on peut aussi l'installer sur une machine virtuelle, notamment pour un lab. Quand un hyperviseur est installé dans une VM (et donc sur un autre hyperviseur), on parle de virtualisation imbriquée ou *nested virtualization*.

```shell
Quel est l'interet d'installer Proxmox sur une VM ?

Si tu n'as pas de machines physiques disponible alors tu n'as pas le choix
Cela peut permettre de tester Proxmox avant de l'installer réellement
```

## 👉 Mise en œuvre

## ✔️ Prérequis

```shell
Pré-requis officielsLes pré-requis techniques et recommandations indiquées sur le site officiel.https://www.proxmox.com/en/proxmox-ve/requirements
```

Pour cette quête il te faut:

- Une machine physique (hôte) avec au moins 8 Go de RAM et 100 Go de disponible sur le disque dur
- Le logiciel Virtualbox d'installé.
```shell
Source d'installation de VirtualboxLa page officielle des sources.https://www.virtualbox.org/wiki/Downloads
```
- Le fichier ISO d'installation de Proxmox.
```shell
Source d'installation de proxmoxLa page officielle des sources.

Pour cette quête tu as besoin de Proxmox Virtual Environment. Le fichier d'installation est sous la forme proxmox-ve_x.x.iso.https://www.proxmox.com/en/downloads
```

## ⚙️ Préparation de la VM

La VM doit être préparée comme ceci:

- Type: `Linux`
- Version: `Debian <dernière version> 64 bits`
- RAM: au minimum `4 Go`, dans l'idéal au moins `8 Go`
- Nombre de processeurs: au minimum `1`
- Nombre de cœurs par processeurs: `1`
- Stockage: `1 controleur SATA` et `un disque dur (de type VMDK) de 30 Go (pour le système)`
```shell
Créer d'abord une VM vide et ensuite ajoute le disque dur sur le contrôleur SATA.
```
- Carte réseau: 1 seule en `bridge`
```shell
Bien que n'importe quel mode convienne pour la carte réseau de la VM, il est conseillé de la mettre en mode bridge, ce qui te permettra d'interagir dirrectement avec elle à partir de ta machine.

Si tu la mets en mode private network, tu dois avoir une deuxième machine dans le même réseau que proxmox, qui servira de client.
```
- Activer la virtualisation imbriquée: dans la partie `Système`, onglet `Processeur`, cocher la case `Activer VT-x/AMD-v`.  
	Si ce n'est pas possible (case grisée):
	- Pour Windows, aller dans `cd "C:\Program Files\Oracle\VirtualBox\"` et exécuter la commande `.\VBoxManage.exe modifyvm "Nom_de_ta_VM" --nested-hw-virt on`
		- Pour Linux, exécuter la commande `vboxmanage modifyvm "Nom_de_ta_VM" --nested-hw-virt on`

## 🔬 Installation

Démarre ta machine avec l'ISO que tu as téléchargé et suis les instructions d'installation à l'écran.  
Tu as ci-dessous un lien vers la documentation officielle.

```shell
Documentation d'installationLa page des guides officiels d'installation.https://www.proxmox.com/en/downloads/category/documentation-pve
```

Une vidéo pour l'installation de Proxmox sur Virtualbox:

Une vidéo pour l'installation de Proxmox en mode **bare metal**:

## 🔑 Connexion à Proxmox

Tu peux te connecter de 2 manières:

- En CLI directement sur la machine
- En GUI dans un navigateur web en se connectant à l'adresse `https://@IP_de_ta_machine:8006/`
```shell
L'adresse IP de la machine apparaît dans une bannière au démarrage de la machine en CLI.
```

La connection de base se fait avec le compte `root`.  
On peut tout à fait créer d'autres comptes, liés à la base de données interne de comptes et de groupes, ou bien à un annuaire LDAP, comme l'Active Directory.

## 🔧 Mis-à-jour des dépôts

Connecte-toi en web sur la machine proxmox avec le compte **root**.

```shell
Si tu as mis la carte réseau de la VM en mode bridge ou host only tu peux utiliser directement le navigateur web de ta machine.

Si tu as mis la carte en private network, tu dois utiliser une machine cliente pour te connecter en web.
```
```shell
Un message d'erreur indique que le serveur n'est pas enregistré.
Proxmox Server Solutions GmbH, l'entreprise allemande qui édite proxmox a choisi un modèle économique consistant, entre autres, à proposer sous licence libre, et gratuitement, le logiciel ProxmoxVE et à demander des souscriptions aux utilisateurs afin d'avoir les dernières mises à jour.
Ainsi le dépôt Proxmox VE Enterprise Repository n'est accessible qu'aux clients à jour de leur souscriptions.
Il existe néanmoins un autre dépot : le Proxmox VE No-Subscription Repository qui, lui, est accessible gratuitement et permet de maintenir à jour son installation.
Proxmox Server Solutions GmbH recommande le dépôt entreprise pour plus de stabilité en promettant de n'y publier que des mises à jours plus exhaustivement testées que sur le dépôt No-Subscription.
```

Met à jour le `/etc/apt/sources.list` (ou le dossier `/etc/apt/sources.list.d`) pour utiliser le dépôt ne nécessitant pas de souscription en suivant la documentation suivante:

```shell
Package repositoriesPartie de la documentation officielle décrivant les différents dépôts apt permettant la mise à jour de Proxmoxhttps://pve.proxmox.com/pve-docs/pve-admin-guide.html#sysadmin_package_repositories
```
```shell
Tu accède au shell de la machine directement à partir de l'interface graphique sans repasser par la VM en CLI :

Sélectionne ta machine dans le panneau de gauche, si tu n'as pas changé le nom c'est pve
Dans la colonne de droite, clic sur >_Shell
```

Tu peux voir le statut des dépôts dans `pve --> Updates --> Repository`.  
Désactive le dépôt `pve-enterprise` en le selectionnant et en cliquant sur `Disable`.  
Remonte sur `Updates` et clique sur `Refresh` pour charger les nouveaux paquets, qui vont apparaitre dans la fenêtre.  
Ensuite, clic sur `Upgrade` pour mettre à jour Proxmox.

## 🧭 Navigation dans l'interface

En cliquant sur **Datacenter** à gauche, tu peux dérouler l'interface dans la fenêtre de droite.

> Un datacenter peut contenir plusieurs serveurs Proxmox

En naviguant dans les menus, tu peux voir plusieurs fonctionnalités, dont:

| Datacenter | Rôles |
| --- | --- |
| Summary | Permet de voir le statut et l'état général des clusters. |
| Options | Permet de changer certains réglages (claviers, proxy logiciel, adresse mail expéditeur) |
| Storage | Permet d'ajouter des espaces de stockage (répertoire locaux, partage NTFS, ISCSI,...) et d'indiquer quel type de données ils contiendront (images ISO, VM, sauvegardes...). |
| Backup | Permet de programmer des sauvegardes de machines. |
| Permissions | Permet de gérer des comptes utilisateurs, des groupes,... |

Regarde les différentes fenêtres pour t'approprier l'interface.

---

## ☝️ Résumé

Proxmox est un logiciel libre et c'est un hyperviseur de type 1.  
On peut l'installer sur une machine physique (bare metal) ou une machine virtuelle.  
On peut gérer les VM en CLI, via une interface graphique disponible à partir d'un navigateur web ou même à partir de script à l'aide d'une API.  
La mise-à-jour des paquets peut se faire à partir d'un dépôt gratuit qu'il suffit de configurer.

---

## 📝 Quiz

```shell
# 1  - Proxmox est un hyperviseur de type 2VraiFauxValider# 2 VraiFauxValider# 3 VraiFauxValider# 4 VraiFauxValider# 5 8080008006443Valider# 6 VraiFauxValider# 7 VraiFauxValiderTon score :0 / 7
```

---

## 💪Challenge

Installe Proxmox selon les pré-requis demandés sur une VM Virtualbox.

## 🧐 Critères d'acceptation

Ton installation est fonctionnelle.

Quête terminée le **vendredi 02 janvier 2026**