---
title: "Atelier - WSUS - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3077/pages/11705"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Windows

## Atelier - WSUS

Moyen

2h

Auto-validation

Windows

## Atelier - WSUS

## Introduction

Dans cet atelier tu vas installer et configurer un serveur WSUS et faire le lien avec 2 clients.

![logo WSUS](https://storage.googleapis.com/quest_editor_uploads/mRsmMuPy9szPK3rzaCfpP1tSkPNERsoM.jpg)

## 🎯 Objectifs

✅ Installer et configurer un serveur WSUS  
✅ Gérer des GPO de liaison avec des groupes WSUS  
✅ Gérer les mises à jour

## sommaire

- [✔️ Étape 1 - Prérequis](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#%EF%B8%8F-%C3%A9tape-1---pr%C3%A9requis)
- [🔬 Étape 2 - Installation et configuration de WSUS](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#-%C3%A9tape-2---installation-et-configuration-de-wsus)
	- [Création de la partition de stockage des mises à jour](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#cr%C3%A9ation-de-la-partition-de-stockage-des-mises-%C3%A0-jour)
		- [Installation du rôle WSUS](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#installation-du-r%C3%B4le-wsus)
		- [Configuration du service WSUS](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#configuration-du-service-wsus)
- [🔬 Étape 3 - Liaison avec les ordinateurs du domaine](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#-%C3%A9tape-3---liaison-avec-les-ordinateurs-du-domaine)
	- [Configuration sur WSUS](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#configuration-sur-wsus)
		- [GPO pour les clients de la Comptabilité](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#gpo-pour-les-clients-de-la-comptabilit%C3%A9)
		- [GPO pour les clients du service informatique](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#gpo-pour-les-clients-du-service-informatique)
		- [GPO pour les serveurs (non-DC)](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#gpo-pour-les-serveurs-non-dc)
		- [GPO pour les DC](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#gpo-pour-les-dc)
- [🔬 Étape 4 - Gestion des mises à jour](https://odyssey.wildcodeschool.com/quests/3077/pages/11705#-%C3%A9tape-4---gestion-des-mises-%C3%A0-jour)

## ✔️ Étape 1 - Prérequis

Pour cet atelier, tu as besoin:

- Un hyperviseur comme Virtualbox pour pouvoir créer des VM
- 1 VM `WINSERV1` avec Windows Server 2022 installé et mise à jour, avec:
	- Un espace libre et non-configuré (sur une partition ou un disque) d'au moins 20 Go
		- 2 cartes réseaux:
		- Une carte réseau en `Réseau interne` avec l'adresse IP `172.16.10.10/24`
				- Une carte en `NAT` en DHCP
		- Le rôle AD-DS installé et configuré avec un domaine `lab.lan`
- 2 VM `CLIENT1` et `CLIENT2` avec Windows 10 et membres du domaine AD:
	- La VM CLIENT1 fait partie d'une OU nommée `Comptabilite`
		- La VM CLIENT2 fait partie d'une OU nommée `ServiceInformatique`
- Si tu le souhaites, tu peux également mettre 1 VM serveur et 1 VM DC
```shell
Les expérimentations pratiques ont été testées avec les OS Windows Server 2022 et Windows 10. Les VM fonctionnent sur VirtualBox 7, lui-même fonctionnant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites avec d'autres versions de systèmes, et sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## 🔬 Étape 2 - Installation et configuration de WSUS

## Création de la partition de stockage des mises à jour

Créer une partition formaté avec un espace de 20 Go qui se nomme `WSUS`.  
Sur cette partition, créer un dossier `WSUS`

## Installation du rôle WSUS

À partir du **Server Manager**, installe le rôle **Windows Server Update Services**.  
Valide les fonctionnalités supplémentaires qui vont s'ajouter automatiquement.  
Ensuite, sélectionne `WID Connectivity` et `WSUS Service`.  
Indique le dossier que tu as créer pour l'emplacement du stockage des mises à jour.  
Termine l'installation et redémarre le serveur.

## Configuration du service WSUS

Une fois le serveur redémarré, lance la tâche `Post Deployment Configuration for WSUS` dans le Server Manager.  
Ensuite, dans la fenêtre de gauche, vas dans WSUS.  
Avec le bouton droit sélectionne `Windows Server Update Services` cela va lancer automatiquement l'assistant de configuration.

```shell
Tu n'es pas obligé de suivre cet assistant, tu peux le relancer plus tard si necessaire.
```

Si tu a lancé l'assistant:

- Décoche la case `Yes, I would like to join the Microsoft Update Improvement Program`
- Laisse sélectionné la case `Synchronize from Microsoft Update`
- Ne mets pas de proxy
- À la fin, clic sur `Start Connecting`. Cette action peut être longue (entre 10 et 20 min)!
	- Si cela ne fonctionne pas, vérifier la connexion internet
- Après, sélectionne les langues `English` et `French`
- Dans la fenêtre d'après, sélectionne les produits pour lesquels tu souhaites avoir des mises à jour. Ici tu peux choisir parmi les produits **Windows 10** et les serveurs
- Pour les classifications laisse les choix par défaut
- Pour la synchronisation, choisi **4** synchronisations par jour, à partir de **2h**.
- Enfin coche la case `Begin initial synchronization` et clic sur \`Finish

Pour voir l'état de la synchronisation, tu clic sur le nom de ton serveur dans la fenêtre, et tu as l'état de la synchronisation avec le widget **Synchronization Status**.

Va dans `Options`, puis `Automatic Approvals`.  
Dans l'onglet `Update Rules`, cocher `Default Automatic Approval Rule`.

> Cela permet d'approuver automatiquement les mises à jour suivant les règles de la section *Rule Properties* se trouvant en dessous. Par défaut, une mise à jour Critique ou de Sécurité sont Approuvées sur tout les ordinateurs.

- Cliquer sur *Run Rules*
- Cliquer sur `Apply` et `OK`

## 🔬 Étape 3 - Liaison avec les ordinateurs du domaine

## Configuration sur WSUS

Sur le serveur WSUS:

- Va dans `Options`, puis `Computers`.
- Coche l'option `Use Group Policy...` et valide
- Dans l'arborescence des ordinateurs, sous **All Computers**, créer 2 groupes avec `Add Computer Group`:
	- Grp-COMPTABILITE
		- Grp-SERVICE-INFORMATIQUE

## GPO pour les clients de la Comptabilité

- Sur ton AD, créer une GPO **COMPUTER-WSUS-Clients-Comptabilite**
- Va dans *Computer Configuration* --> *Policies* --> *Administrative Templates* --> *Windows Components* --> *Windows update*
- Le paramétrage ci-dessous est commun à toutes les GPO:
	- Va dans `Specify intranet Microsoft update service location`, qui indiquera où est le serveur de mise à jour.
		- Coche `Enabled`
				- Dans les options, pour les 2 premiers champs, mettre l'URL avec le nom du serveur sous sa forme **FQDN**, ajouter le numéro du port 8530
			- Valide la configuration
		- Va dans `Do not connect to any Windows Update Internet locations` qui bloque la connexion aux serveurs de Microsoft
		- Coche `Enabled` et valide la configuration
- Le paramétrage ci-dessous est spécifique à cette GPO:
	- Va dans `Configure Automatic Updates`
		- Coche `Enabled`
				- Dans les options mets:
			- Dans `Configure automatic updating` sélectionne `4- Auto Download and schedule the install`
						- Dans `Scheduled install day` mets `0 - Every day`
						- Dans `Scheduled install time` mets `09:00`
						- Cocher `Every week`
						- Cocher `Install updates for other Microsoft Products`
		- Aller dans `Enable client-side targeting` qui fait la liaison avec les groupes crées dans WSUS
		- Coche `Enabled`
				- Dans les options, mettre le nom du groupe WSUS pour les ordinateurs cible, donc **COMPTABILITE**
				- Valide la configuration
		- Aller dans `Turn off auto-restart for updates during active hours` qui permet d'empêcher les machines de redémarrer après l'installation d'une mise à jour pendant leurs heures d'utilisations
		- Coche `Enabled`
				- Dans les options, mettre (par exemple) `8 AM - 6 PM`

## GPO pour les clients du service informatique

Fais la même chose avec une GPO **COMPUTER-WSUS-Clients-ServiceInformatique** mais en modifiant la cible du groupe WSUS.

## GPO pour les serveurs (non-DC)

Fais cette GPO si tu as une VM serveur.

- Copie la GPO client et renomme là en **COMPUTER-WSUS-Serveurs**
- Ne touche pas à la partie commune et modifie uniquement la partie spécifique à cette GPO:
	- Va dans `Configure Automatic Updates`
		- Dans les options mets:
			- Dans `Configure automatic updating` sélectionne `7- Auto Download, Notify to restart`
						- Dans `Scheduled install day` mets `0 - Every day`
						- Dans `Scheduled install time` mets `09:00`
						- Cocher `Every week`
						- Ne pas cocher `Install updates for other Microsoft Products`
		- Aller dans `Enable client-side targeting` qui fait la liaison avec les groupes crées dans WSUS
		- Coche `Enabled`
				- Dans les options, mettre le nom du groupe WSUS pour les ordinateurs cible, dont ici les serveurs
				- Valide la configuration

## GPO pour les DC

Fais cette GPO si tu as une VM DC.

- Copie la GPO serveur et renomme là en **COMPUTER-WSUS-DC**
- Ne touche pas à la partie commune et modifie uniquement la partie spécifique à cette GPO:
	- Aller dans `Enable client-side targeting` qui fait la liaison avec les groupes crées dans WSUS
		- Coche `Enabled`
				- Dans les options, mettre le nom du groupe WSUS pour les ordinateurs cible, dont ici les contrôleurs de domaine
				- Valide la configuration

Une fois les GPO crées et configurées, lie les aux OU dans lesquelles sont tes machines clientes

Sur chaque client, exécuter la commande avec le compte administrateur local `gpupdate /force`.  
On peut vérifier si les GPO sont appliquée avec la commande `gpresult /R` ou avec la commande PowerShell `Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -Name WUServer, WUStatusServer`

## 🔬 Étape 4 - Gestion des mises à jour

Sur le serveur WSUS, va dans la partie **Updates** et sélectionne **Security Updates**.  
Sélectionne des mises à jour et ouvre le menu d'approbation avec le bouton droit de la souris.  
Tu vas retrouver les groupes que tu as créer sous l'arborescence **All Computers**.  
Tu peux pour chacun des groupes appliquer les différentes mises à jour ou bien les bloquer.

Tu as désormais un serveur WSUS fonctionnel!  
Tu peux tester le lien avec un serveur et/ou un DC si tu ne l'as pas encore fait.

Quête terminée le **jeudi 19 février 2026**