---
title: "Atelier - Utilisation avancée de FreePBX - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3072/pages/11698"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
VoIP

## Atelier - Utilisation avancée de FreePBX

Moyen

1h

Auto-validation

VoIP

## Atelier - Utilisation avancée de FreePBX

## Introduction

FreePBX est une plateforme de communication open-source basée sur Asterisk. Elle offre une interface web intuitive pour gérer la VoIP.  
Dans cet atelier, tu exploreras l'installation, la configuration et la maintenance de FreePBX. Tu va aussi apprendre à créer des pools d'appel pour gérer les flux d'appels et configurer les renvois d'appel pour assurer la continuité des communications.  
L'objectif est de te fournir les compétences nécessaires pour optimiser un système de téléphonie d'entreprise.

![logo freepbx](https://storage.googleapis.com/quest_editor_uploads/CjEbGDI2lnJZC1XB1Hc2vavKRmbQ7LMN.png)

## 🎯 Objectifs

✅ Naviguer dans l'administration de freepbx  
✅ Savoir créer des lignes associées à des utilisateurs  
✅ Savoir faire des renvois d'appels  
✅ Créer un pool d'appels

## sommaire

- [✔️ Étape 1 - Prérequis](https://odyssey.wildcodeschool.com/quests/3072/pages/11698#%EF%B8%8F-%C3%A9tape-1---pr%C3%A9requis)
- [🔬 Étape 2 - Création de lignes](https://odyssey.wildcodeschool.com/quests/3072/pages/11698#-%C3%A9tape-2---cr%C3%A9ation-de-lignes)
- [🔬 Étape 3 - Renvois d'appel](https://odyssey.wildcodeschool.com/quests/3072/pages/11698#-%C3%A9tape-3---renvois-dappel)
- [🔬 Étape 4 - Pool d'appel](https://odyssey.wildcodeschool.com/quests/3072/pages/11698#-%C3%A9tape-4---pool-dappel)

## ✔️ Étape 1 - Prérequis

Pour cet atelier, tu as besoin:

- Un hyperviseur comme Virtualbox pour pouvoir créer des VM
- 1 VM `IPBX` avec FreePBX installé en anglais et mis à jour, avec:
	- 2 cartes réseaux:
		- Une carte réseau en `Réseau interne` avec l'adresse IP `172.16.10.35/24`
				- Une carte en `NAT` en DHCP
		- Les différents modules installés sont à jour
- 3 VM `Client1`, `Client2`, et `Client3` avec:
	- Une carte réseau en `Réseau interne` avec respectivement l'adresse IP `172.16.10.101/24`, `172.16.10.102/24`, et `172.16.10.103/24`
		- Un softphone 3CX installé sur chaque VM
```shell
Les expérimentations pratiques ont été testées avec les OS Windows Server 2022, Windows 10, et FreePBX qui tourne sur une distribution Red Hat. Les VM fonctionnent sur VirtualBox 7, lui-même fonctionnant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites avec d'autres versions de systèmes, et sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## 🔬 Étape 2 - Création de lignes

Sur l'IPBX, créer les lignes suivantes et configure-les sur les machines correspondantes:

| Poste client | Numéro de ligne | Nom | Mot de passe |
| --- | --- | --- | --- |
| Client 1 | 33101 | Stéphanie Morin | 1234 |
| Client 2 | 33102 | Joël Lerobillard | 1234 |
| Client 3 | 33103 | Jean Kyrin | 1234 |

Pour rappel:

- Connecte toi sur FreePBX en web
- Vas dans *Applications -> Extensions* pour créer les comptes SIP

## 🔬 Étape 3 - Renvois d'appel

Tu vas faire un renvois d'appel du poste 33102 vers le poste 33103.  
Sur FreePBX, vas dans *Applications -> FollowMe* et clic sur le crayon à coté du numéro 33102.  
Dans le menu d'édition:

- Dans *Follow-Me List* met le numéro vers lequel renvoyer, soit ici 33103
- *Initial Ring Time* est le temps en secondes avant le transfert d'appel, mets `5`
- *Follow-Me Ring Time* est le temps (ajouté à *Initial Ring Time*) avant que l'appel s’arrête. Mets `10`.
- Met `Yes` pour *Enable Followme*, cela active le transfert d'appel
- Clic sur `Submit` puis `Apply Config`  
	Valide que le transfert d'appel est opérationnel en appelant le poste 33102 à partir du 33101. Normalement, au bout de 5 secondes, l'appel va être transféré sur le poste 33103.

## 🔬 Étape 4 - Pool d'appel

Désactive le transfert d'appel fait précédemment.  
Maintenant, tu vas créer un numéro d'appel **Help-Desk** sur le numéro 33003.  
Les 2 postes 33102 et 33103, inclus dans ce pool d'appel, doivent sonner en même temps.  
Vas dans *Applications -> Ring Groups* et clic sur `Add Ring Group`.  
Dans le menu:

- *Ring-Group Number*: `33003`
- *Group Description*: `Help-Desk`
- *Extension List*: `33102` et `33103` en dessous
- *Ring Strategy*: `ringall`
- *Ring Time*: `15`
- *Destination if no answer*: `Terminate Call - Hangup`
- Clic sur `Submit` puis `Apply Config`  
	Pour vérifier la configuration, à partir du poste 33101, appelle le 33003. Les 2 autres postes doivent sonner en même temps.

Tu as été plus loin dans la configuration de FreePBX!  
Continue à explorer les configuration possible sur ces 2 exemples.

Quête terminée le **dimanche 01 mars 2026**