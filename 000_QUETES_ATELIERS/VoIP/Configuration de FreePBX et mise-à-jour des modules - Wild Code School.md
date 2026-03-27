---
title: "Configuration de FreePBX et mise-à-jour des modules - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2791/pages/10088"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
VoIP

## Configuration de FreePBX et mise-à-jour des modules

Moyen

1h

Quiz

VoIP

## Configuration de FreePBX et mise-à-jour des modules

## Introduction

Dans cette quête tu vas gérer l'activation et la mise-à-jour du serveur et des modules associés.

![logo de freepbx](https://www.asterisk.org/wp-content/uploads/Sangoma_FreePBX_Logo_RGB_vert-pos-e1596552152261.png)

## 📚 Pré-requis

Avant de commencer cette quête, assure-toi d'avoir déjà terminé la quête suivante:

```shell
Installation de FreePBX1hVoir la quête - Installation de FreePBX
```

## 🤓 Objectifs:

✅ Faire l'activation du serveur  
✅ Effectuer la mise-à-jour des modules et du serveur  
✅ Savoir se repérer dans les menus

## Sommaire

- [👉 Mise en œuvre](https://odyssey.wildcodeschool.com/quests/2791/pages/10088#-mise-en-%C5%93uvre)
	- [✔️ Prérequis](https://odyssey.wildcodeschool.com/quests/2791/pages/10088#%EF%B8%8F-pr%C3%A9requis)
		- [⚙️ Démarrage et première configuration](https://odyssey.wildcodeschool.com/quests/2791/pages/10088#%EF%B8%8F-d%C3%A9marrage-et-premi%C3%A8re-configuration)
		- [💻 Activation du serveur](https://odyssey.wildcodeschool.com/quests/2791/pages/10088#-activation-du-serveur)
		- [🗓️ Update des modules du serveur](https://odyssey.wildcodeschool.com/quests/2791/pages/10088#%EF%B8%8F-update-des-modules-du-serveur)
		- [🗓️ Update complémentaire des modules](https://odyssey.wildcodeschool.com/quests/2791/pages/10088#%EF%B8%8F-update-compl%C3%A9mentaire-des-modules)
		- [🔎 Quelques menus intéressant pour l'administration](https://odyssey.wildcodeschool.com/quests/2791/pages/10088#-quelques-menus-int%C3%A9ressant-pour-ladministration)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2791/pages/10088#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2791/pages/10088#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2791/pages/10088#-crit%C3%A8res-dacceptation)

## 👉 Mise en œuvre

## ✔️ Prérequis

Tu a besoin de:

- Une VM avec FreePBX d'installé et une carte réseau en mode `bridge`.
```shell
Les expérimentations pratiques ont été testées sur une distribution FreePBX Distro 16 64 bits (2302-1) contenant FreePBX 16.0.40 installée dans une machine virtuelle VirtualBox 7 tournant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites avec d'autres versions de FreePBX, sur d'autres distributions Linux, et sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## ⚙️ Démarrage et première configuration

Par l'interface web, connecte-toi en root sur la VM avec le mot de passe associé (à mettre 2 fois).  
Indique également une addresse mail pour les notifications et clique sur Setup System.

Dans la fenêtre, clique sur `FreePBX Administration` et reconnecte-toi en root.  
![icone freepbx administration](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-10.png?raw=true)

Clique sur Skip pour sauter l'activation du serveur et toutes les offres commerciales qui s'affichent.  
![fenêtre pour l'activation](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-11.png?raw=true)

Laisse les langages par défaut et clique sur Submit.  
![fenêtre des langages](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-12.png?raw=true)

A la fenêtre d'activation du firewall, clique sur Abort:  
![fenêtre de l'activation du firewall](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-13.png?raw=true)

A la fenêtre de l'essais de **SIP Station** clique sur Not Now:  
![fenêtre d'essais de sip station](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-14.png?raw=true)

Tu arrive sur le tableau de bord, clique sur Apply Config (en `rouge`)pour valider tout ce que tu viens de faire  
![tableau de bord de freepbx](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-15.png?raw=true)

## 💻 Activation du serveur

Cette activation n'est pas obligatoire, mais elle permet d'avoir accès à l'ensemble des fonctionnalités du serveur.  
Va dans le menu `Admin` puis `System Admin`.  
![menu déroulant administrateur](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-16.png?raw=true)

Un message indique que le système n'est pas activé.  
![message indiquant que le système n'est pas activé](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-17.png?raw=true)

Clique sur `Activation` puis Activate

Dans la fenêtre qui s'affiche, clique sur Activate  
![fenêtre pour l'activation](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-11.png?raw=true)

Entre une adresse email et attend quelques instant.  
![fenêtre du portail](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-18.png?raw=true)

Dans la fenêtre qui s'affiche, renseigne les différentes informations, et:

- Pour `Which best describes you` mets `I use your products and services with my Business(s) and do not want to resell it`
- Pour `Do you agree to receive product and marketing emails from Sangoma ?` coche `No`
- Clique sur Create  
	![fenêtre de renseignements](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-19.png?raw=true)

Dans la fenêtre d'activation, clique sur Activate et attends que l'activation se fasse.  
![fenêtre d'activation](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-20.png?raw=true)

Dans les fenêtres qui s'affichent, clique sur Skip.  
![fenêtre à passer](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-21.png?raw=true)

## 🗓️ Update des modules du serveur

La fenêtre de mise-à-jour des modules va s'afficher automatiquement.  
Clique sur Update Now.  
![fenêtre des modules](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-22.png?raw=true)

Attend la mise-à-jour de tous les modules.  
![fenêtre de mise à jour des modules](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-23.png?raw=true)

Une fois que tout est terminé, clique sur Apply config.

```shell
Il peut y avoir des erreurs sur le serveurs suite à la mise-à-jour des modules et dans ce cas, l'accès au serveur ne se fait pas.

Les modules incriminés sont précisés et il faut les réinstaller et les activer.

Dans ce cas, sur le serveur en CLI, exécute les commandes suivantes :
fwconsole ma install <module>
fwconsole ma enable <module>

Par exemple pour les modules userman, voicemail, et sysadmin :
fwconsole ma install userman
fwconsole ma enable userman
fwconsole ma install voicemail
fwconsole ma enable voicemail
fwconsole ma install sysadmin
fwconsole ma enable sysadmin
```

Va sur le serveur en CLI et exécute la commande `yum update` pour faire la mise-à-jour du serveur.  
Répond `y` lorsque cela sera demandé.

Redémarre le serveur

## 🗓️ Update complémentaire des modules

Connecte-toi en root via la console web, et vas dans le **Dashboard** pour voir s'il te manque des modules.  
Vas dans le menu `Admin` puis `Modules Admin`, et dans l'onglet `Module Update`.

Dans la fenêtre qui s'affiche, dans la colonne `Status`, sélectionne ceux qui sont en `Disabled; Pending Upgrade...` et qui ont une licence **GPL**.  
Sélectionne alors le bouton Upgrade to....  
![Fenêtre de la mise-à-jour des modules](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-28.png?raw=true)

```shell
Les modules commerciaux ne peuvent être achetés que sur un serveur activé.
```

Quand tu as géré tous les modules, clique sur Process.

Dans la fenêtre qui apparaît, clique sur Confirm.  
![Fenêtre de confirmation des mise-à-jour des modules](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-27.png?raw=true)

Quand tout est terminé, clique sur Apply config.

Dans les chapitres précédents, tu as vu les menus suivants:

- `Admin` --> `System Admin` --> `Activation`
- `Admin` --> `Updates` --> `Module Update`

Il y en a beaucoup d'autres!

**Menu System Admin**  
Vas dans `Admin` --> `System Admin` et regarde à droite de la fenêtre, tu as différentes informations sur le serveur.  
![menu déroulant sys admin](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/freePBX-24.png?raw=true)

Regarde plus particulièrement celles-ci:

- **Activation**: Tu peux agir sur cette activation
- **DNS**: Ici tu peux mettre les adresses IP des autres serveurs DNS de ton réseau
- **Network Settings**: Le paramétrage IP (DHCP,...)
- **Hostname**: Le nom de ton serveur
- **Time Zone**: Pour le fuseau horaire

**Menu Administrateurs**  
Vas dans `Admin` --> `Administrators` et tu pourras gérer d'autres comptes administrateurs que root.

**Menu UCP**  
Vas dans `UCP` pour avoir le portail qui permet aux utilisateurs d'avoir un contrôle plus direct sur leurs extensions de téléphonie.

## ☝️ Résumé

Comme tout serveur qui vient d'être installé, FreePBX doit d'abord être mis-à-jour.  
Cela se fait par l'interface web mais également en CLI.  
Les modules de FreePBX avec des licences GPL peuvent être mis-à-jour gratuitement, ceux avec une licence commerciale doivent être acheté auprès de la société Sangoma.  
Des problèmes de modules peuvent apparaître après des mise-à-jour, la résolution se fait en CLI.

## 💪Challenge

Effectue correctement les configurations de mise-à-jour de serveur et des modules et répond correctement au quiz.

## 🧐 Critères d'acceptation

Toutes les réponses au quiz sont correctes.

mardi 17 février 2026

6 questions

mardi 17 février 2026

6 questions

mardi 17 février 2026

6 questions