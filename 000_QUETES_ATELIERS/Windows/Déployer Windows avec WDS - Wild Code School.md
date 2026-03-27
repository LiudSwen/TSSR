---
title: "Déployer Windows avec WDS - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2338/pages/10932"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Windows

## Déployer Windows avec WDS

Moyen

1h

Auto-validation

Windows

## Déployer Windows avec WDS

## Introduction

WDS permet de déployer des images Windows. Ces images peuvent être brutes, équivalentes à un nouveau PC que l'on viendrait d'allumer, ou bien complètement customisées.  
Cette quête consiste à déployer une image standard d'un Windows en utilisant l'infrastructure WDS.  
Bien que courante, il n'est pas obligatoire d'avoir une infrastructure AD pour déployer une image Windows.  
Cette quête consiste donc à le faire sans AD.

## 🤓 Objectifs:

✅ Préparer le déploiement d'une image Windows  
✅ Gérer un déploiement d'image par WDS

## Sommaire

- [👉 Un element indispensable: le master](https://odyssey.wildcodeschool.com/quests/2338/pages/10932#-un-element-indispensable--le-master)
- [👉 Mise en œuvre](https://odyssey.wildcodeschool.com/quests/2338/pages/10932#-mise-en-%C5%93uvre)
	- [🔧 Prérequis](https://odyssey.wildcodeschool.com/quests/2338/pages/10932#-pr%C3%A9requis)
		- [🔬 Image de démarrage](https://odyssey.wildcodeschool.com/quests/2338/pages/10932#-image-de-d%C3%A9marrage)
		- [🔬 Image d'installation](https://odyssey.wildcodeschool.com/quests/2338/pages/10932#-image-dinstallation)
		- [🔬 Lancement du déploiement](https://odyssey.wildcodeschool.com/quests/2338/pages/10932#-lancement-du-d%C3%A9ploiement)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2338/pages/10932#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2338/pages/10932#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2338/pages/10932#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2338/pages/10932#-crit%C3%A8res-dacceptation)

## 👉 Un element indispensable: le master

L’image d’un OS générique est en quelques sortes l’image d’une installation personnalisée d’un système Windows qui peut être installée sur des postes de travail différents de celui où l’image a été créé.  
C'est ce qu'on appelle un **master**.

Pour le préparer, on prend une machine, on y installe le système d'exploitation voulu, les pilotes, les logiciels, le fond d'écran... En bref, on le paramètre comme on le souhaite. Cet ordinateur est donc le modèle qui sert à beaucoup d’autres.

Cet OS modèle peut donc être copié sur d’autres ordinateurs. La généricisation d’une image permet de rendre chaque machine unique en effaçant quelques informatiques spécifiques dont le **SID** (***Security Identifier*** ou Identifiant de sécurité).  
Ce processus s'appelle un **sysprep**.

```shell
SysprepPour aller plus loin sur le site de Microsofthttps://learn.microsoft.com/fr-fr/Windows-Hardware/manufacture/Desktop/Sysprep-process-Overview?view=windows-11
```
```shell
En savoir plus sur les SIDPour aller plus loin sur le site de Microsofthttps://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/manage/understand-security-identifiers
```
```shell
Un master n'est pas qu'un fichier. Il peut aussi regrouper tous les processus mis en place pour automatiser une installation comme un fichier de réponses, des scripts, des tâches automatisées, etc.

En vulgarisant on identifie souvent un master à un fichier mais ce n'est donc pas que cela.
```
```shell
Qu'est-ce qu'un fichier de réponse ?Pour aller plus loin sur le site de Microsofthttps://learn.microsoft.com/fr-fr/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs?view=windows-11
```

## 👉 Mise en œuvre

## 🔧 Prérequis

Pour pouvoir faire cette quête tu as besoin de:

- 1 serveur `Windows Server` avec le rôle WDS installé, configuré, et démarré.
- 1 service DHCP (qui peut être sur le même serveur)
	- La plage IP va de `172.16.1.50` à `172.16.1.240` avec un masque en `/24`
- Une image iso Windows Server
- Un ordinateur client avec une configuration réseau DHCP
```shell
AttentionPour cette quête le rôle AD DS ne doit pas être installé et les machines ne doivent pas faire partie d'un domaine.
```

Les 2 machines sont sur le même réseau interne et ont une adresse IP privée.

```shell
Dans ton hyperviseur, tes 2 VM sont dans un réseau privé. C'est-à-dire qu'elles communiquent entre-elles, mais pas avec l'exterieur. Donc il n'y a pas de communication avec la machine hôte et il n'y a pas d'accès internet.

Si tu utilise VirtualBox, tu dois mettre les cartes réseaux de tes VM en Réseau interne.
```
```shell
Dans le cas d'une machine cliente n'étant pas sur le même réseau que le serveur WDS ou ne pouvant pas l'atteindre, on peut booter à partir d'un média amovible.

Dans ce cas, ce support nomade peut regrouper uniquement l'image de boot et l'image d'installation est téléchargée, ou bien il peut contenir les 2.
```

**Images à déployer**:  
On ne vas pas préparer une image à déployer de a à z, mais utiliser une image déjà prête.  
Pour cela, il faut:

- Une **image de démarrage**
- Une **image d'installation**

## 🔬 Image de démarrage

Elle sert à lancer l'installateur de Windows (ou ***booter***), qui permet par la suite d’installer le système d’exploitation lui-même.  
Ici, on prend l'image qui se trouve sur une image ISO de Windows (équivalent d'un CD/DVD).  
Oui cette image existe déjà nativement sur tous les supports d'installation Windows!

- Dans une VM, met l'ISO d'une image Windows dans le lecteur DVD. Par exemple l'ISO de Windows Server 2022.
- Tu vois l'image de démarrage **boot.wim** dans `D:\sources` avec D étant la lettre du lecteur DVD de ta VM.  
	C'est ce fichier image de démarrage **boot.wim** que l'on intégre dans la console WDS à l'aide de la procédure suivante, soit en PowerShell, soit via l'interface graphique.
```powershell
PowerShellGraphiqueExécute la commande PowerShell suivante dans une console PowerShell :
1
# D etant la lettre du DVD
2
Import-WdsBootImage -Path D:\sources\boot.wim -NewImageName "Boot image lab x64" -SkipVerify
```

En sélectionnant le dossier `Boot Images` tu vois dans la fenêtre de droite l'image que tu a ajouté.  
Si rien n’apparaît dans la fenêtre de droite, clique sur le bouton `Refresh` dans le menu de la console.

## 🔬 Image d'installation

C'est ce que l'on déploie sur les postes. C'est l’image d'un système d’exploitation qui a été personnalisé (ou pas). Comme pour l'image de démarrage, c'est un fichier de type **wim**.  
Ici, on va utiliser une image d'installation qui se trouve elle aussi sur une image ISO de Windows.

Tu peux trouver l'image d'installation **install.wim** dans `D:\source`, **D** étant la lettre du lecteur DVD de ta VM.

```powershell
PowerShellGraphiqueLa commande PowerShell suivante donne la liste des OS contenu dans une image d'installation :
1
# D: Lettre du lecteur DVD, à modifier si nécessaire
2
Get-WindowsImage -ImagePath "D:\sources\install.wim" | Select Imagename
Une fois l'image choisie, on peut la sélectionner :
1
# Création du groupe d'image d'installation
2
New-WdsInstallImageGroup -Name "desktops"
3
# Sélection de l'image
4
$ImageName = 'Windows 10 Pro'
5
Import-WdsInstallImage -ImageGroup "desktops" -Path "D:\Sources\Install.wim" -ImageName $ImageName
```

En sélectionnant le dossier `Install Images` tu vois dans la fenêtre de droite le groupe d'images que tu as crée.  
En cliquant sur celui-ci, tu peux voir l'image d'installation.  
Si rien n’apparaît dans la fenêtre de droite, clique sur le bouton `Refresh` dans le menu de la console.

## 🔬 Lancement du déploiement

Démarrer la VM cliente et modifier l'ordre de boot pour qu'elle démarre sur le réseau.

- Le déploiement se fait sous forme graphique.
- Un compte pour se connecter au serveur est demandé sous la forme `domaine\utilisateur`.  
	Pour `le nom du domaine`, utilise le nom de ton serveur WDS.  
	Pour `le compte d'utilisateur`, utilise le compte d'administration que tu as utilisé pour configurer le serveur WDS.
```shell
Dans ce cas précis on utilise le compte Administrator du serveur, mais on peut utiliser un autre compte, à partir du moment où il est autorisé à déployer avec WDS.

De même, si un domaine était en place, on utiliserai son nom au lieu du nom du serveur WDS.
```
- Ensuite suit les indications à l'écran pour déployer le système sur ta VM.

Le système s'installe alors par le réseau.  
Comme l'image n'est pas configurée, des opérations manuelles supplémentaires sont nécessaires

```shell
Tu as déployé une image d'OS par le réseau !
```

---

## ☝️ Résumé

Un master est l'image d'un OS paramétrée et customisée que l'on peut installer à distance sur des machines.  
On a besoin d'une image de démarrage et d'une image d'installation.  
Le serveur WDS et la machine client doivent être dans le même domaine de broadcast.

---

## 📝 Quiz

```shell
# 1  - Un sysprep permet :D'effacer le contenu d'un disque durD'effacer certains paramètres d'un OS dont le SIDValider# 2 Un fichier ISO d'un OSUne image de démarrageL'image d'une installation personnalisée d'un OSValider# 3 Uniquement un fichierL'ensemble des processus qui amène à une image d'installation pouvant être déployéValider# 4 En ligne de commandesEn mode graphiqueValider# 5 VraiFauxValider# 6 VraiFauxValider# 7 Un compte administrateurUn compte du serveur WDSUn compte autorisé à lancer un déploiementValider# 8 VraiFauxValider# 9 VraiFauxValiderTon score :0 / 9
```

---

## 💪Challenge

Créée 2 VM. L'une sera le serveur WDS et l'autre le client.  
Effectue cette installation avec les 2 méthodes.

## 🧐 Critères d'acceptation

- Installe le rôle WDS de 2 manières.
- Déploie un client par le service WDS.

Quête terminée le **jeudi 05 février 2026**