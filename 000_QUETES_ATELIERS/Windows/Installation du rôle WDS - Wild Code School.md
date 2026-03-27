---
title: "Installation du rôle WDS - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2337/pages/11636"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Windows

## Installation du rôle WDS

Moyen

1h

Auto-validation

Windows

## Installation du rôle WDS

⚠️ Pour pouvoir aborder correctement cette quête, tu dois avoir terminé la quête suivante:

```shell
DHCP avec Windows ServerInstallation et configuration d'un serveur DHCP avec Windows Server.2hVoir la quête - DHCP avec Windows Server
```

## Introduction

WDS (pour **Windows Deployment Services**) a été introduit avec Windows Server 2008 afin de remplacer le « vieillissant » RIS.  
WDS fournit un système de déploiement automatisé afin de distribuer des images systèmes via le réseau. Grâce à lui on est en mesure de déployer rapidement des OS sur un parc informatique.  
WDS se base sur de nombreux services Windows tels qu'Active Directory et DHCP.

```shell
Il n'est pas obligatoire d'avoir un Active Directory pour pouvoir utiliser WDS.

Souvent, ces 2 rôles sont installés mais WDS peut s'implémenter sans rôle AD DS.
```

Dans cette quête, on va installer WDS sur une machine hors domaine (donc sans AD DS).

---

![image](https://storage.googleapis.com/quest_editor_uploads/22loGs3OrW5h7owaOh4hfZ4HUUHaFChP.jpg)

## 🤓 Objectifs:

✅ Savoir à quoi sert WDS  
✅ Savoir installer WDS en PowerShell et en graphique  
✅ Savoir configurer et démarrer le service WDS en PowerShell et en graphique

## Sommaire

- [👉 Définition de WDS (*Windows Deployment Services*)](https://odyssey.wildcodeschool.com/quests/2337/pages/11636#-d%C3%A9finition-de-wds-windows-deployment-services)
- [👉 Mise en œuvre](https://odyssey.wildcodeschool.com/quests/2337/pages/11636#-mise-en-%C5%93uvre)
	- [🔧 Prérequis](https://odyssey.wildcodeschool.com/quests/2337/pages/11636#-pr%C3%A9requis)
		- [🔬 Installation du rôle WDS](https://odyssey.wildcodeschool.com/quests/2337/pages/11636#-installation-du-r%C3%B4le-wds)
		- [🔬 Configuration du WDS](https://odyssey.wildcodeschool.com/quests/2337/pages/11636#-configuration-du-wds)
		- [🔬 Lancement du service WDS](https://odyssey.wildcodeschool.com/quests/2337/pages/11636#-lancement-du-service-wds)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2337/pages/11636#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2337/pages/11636#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2337/pages/11636#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2337/pages/11636#-crit%C3%A8res-dacceptation)

## 👉 Définition de WDS (Windows Deployment Services)

WDS est le système de déploiement apparu avec Windows Server 2008.  
Il est le remplaçant du fameux RIS (Remote Install Services).

Ses principales nouveautés sont:

- Présence d’une interface graphique
- Déploiement en masse via la création de sessions multicast (comme Ghost Cast Server)
- Déploiement automatisé via l’utilisation d’un fichier « unattented.xml »
- Support natif des versions Windows *client* depuis Vista et *serveur* à partir de Server 2008
- Support de l’EFI
- Possibilité de le coupler avec SCCM et MDT
- Disparation du périphérique d’amorçage (disquette ou CD) au profit du démarrage réseau

## 👉 Mise en œuvre

## 🔧 Prérequis

Tu as besoin d'une VM Microsoft Windows Server (en version au moins 2008):

- Adresse IP fixe du serveur: `192.168.10.2/24`
- Nom du serveur: `srv-wds`

Ce serveur est installé avec le rôle DHCP dans la configuration suivante:

- Début de plage d'adresses: `192.168.10.10`
- Fin de plage d'adresses: `192.168.10.100`
- Masque: `/24`

Ce serveur dispose de 2 disques configurés comme ceci:

- Disque **système**: 30 Go
- Disque **WDS**:
	- Taille de volume: `30 Go`
		- Partition de type: `GPT`
		- File system: `NTFS`
		- Nom: `WDS`

## 🔬 Installation du rôle WDS

```powershell
En PowerShellEn GraphiqueExécuter la commande suivante dans une console PowerShell :
1
Install-WindowsFeature wds-deployment -includemanagementtools
```

L'installation est terminée lorsque le rôle **WDS** apparaît dans le **Server Manager**.  
La console **Windows Deployment Services** est disponible dans le menu **Tools**, à partir du rôle WDS, ou encore en tapant `WdsMgmt.msc` dans une fenêtre de commande.  
Si on la lance, voilà à quoi elle ressemble:  
![Console WDS](https://neptunet.fr/wp-content/uploads/2020/10/wds-12.png)  
On voit bien ici qu'il n'y a rien de configuré:  
![image WDS](https://neptunet.fr/wp-content/uploads/2020/10/wds-13.png)

## 🔬 Configuration du WDS

```powershell
En PowerShellEn GraphiqueExécuter la commande suivante dans une console PowerShell pour configurer le service :
1
# /Server:(Nom du serveur WDS)
2
# /remInst:(emplacement des données WDS pour les déploiements)
3
# /Standalone : A utiliser si le serveur n'est pas sur un domaine
4
wdsutil /Initialize-Server /Server:srv-wds /remInst:D:\WdsData /Standalone 
Exécuter la commande suivante dans une console PowerShell pour configurer la gestion des clients :
1
# /Server:(Nom du serveur WDS)
2
# /AnswerClients:(All | Known | None) ==> le comportement pour les requêtes des clients
3
# All   ==> Réponse à tous les clients
4
# Known ==> Réponse uniquement aux clients connu
5
# None  ==> Pas de réponse aux clients
6
wdsutil /Set-Server /Server:srv-wds /AnswerClients:All 
La commande suivante va permettre de vérifier la configuration :
1
# /Server:(Nom du serveur WDS)
2
wdsutil /Get-Server /Server:srv-wds /Show:Config
```
```shell
A ce stade, le serveur a bien été configuré mais le service n’a pas encore démarré. On peut le voir grâce à la présence d’une icône noire sur le nom du serveur.
```

## 🔬 Lancement du service WDS

```powershell
En PowerShellEn GraphiquePour démarrer le service, exécuter la commande suivante dans une console PowerShell :
1
Start-Service -Name WDSServer
```
```shell
On peut voir une icone verte sur le nom du serveur, indiquant que le service est lancé.
```

Dans la console WDS, sous le nom du serveur, on peut voir les dossiers suivants:

- **Install images**: contient les images des systèmes d’exploitation à déployer
- **Boot images**: contient les images WinPE permettant d’amorcer le système depuis le réseau
- **Pending devices**: liste des clients en attente de validation (si on a coché la case de validation des clients à l'étape **PXE Server Initial Settings**)
- **Prestage Devices**: liste des clients connus qui peuvent être sélectionné
- **Multicast transmissions**: permet de créer des sessions multicast afin de déployer un grand  
	nombre de clients simultanément
- **Drivers**: permet d’ajouter des pilotes afin de les incorporer dans les images à déployer

De même, à l'emplacement choisi pour les données de déploiement, donc ici le second disque dur, tu trouveras une nouvelle arborescence de dossiers.  
C'est dans ces dossier que tu mettras les images de déploiement, les images de démarrage, les pilotes logiciels,...

A ce stade, tu as un serveur WDS fonctionnel avec le service lancé.

---

## ☝️ Résumé

WDS (Windows Deployment Services) est un système de déploiement pour les systèmes Windows.  
On peut le coupler avec SCCM, MDT, le tout sur un domaine AD DS, mais il peut également s’exécuter en autonome.  
LE seul pré-requis obligatoire est un service DHCP fonctionnel.  
L'installation peut se faire en PowerShell ou en graphique.  
Une fois installé, on a accès à une console de gestion dédiée et une arborescence de dossiers est également créée.

---

## 📝 Quiz

```shell
# 1  - WDS ne fonctionne que sur un domaine AD DSVraiFauxValider# 2 VraiFauxValider# 3 Wds.mscMgmtWDS.mscWDSMgmt.mscValider# 4 VraiFauxValider# 5 VraiFauxValider# 6 VraiFauxValiderTon score :0 / 6
```

---

## 💪Challenge

Créée 2 VM.  
Sur la première, installe WDS en PowerShell, et sur la deuxième fais-le en mode graphique.  
Faire ces 2 installations va pouvoir te permettre de maîtriser le sujet et pouvoir comparer les 2 méthodes.

## 🧐 Critères d'acceptation

Installe le rôle WDS de 2 manières.

Quête terminée le **jeudi 05 février 2026**