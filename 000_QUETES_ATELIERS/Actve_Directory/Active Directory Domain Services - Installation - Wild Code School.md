---
title: "Active Directory Domain Services - Installation - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1944/pages/18638"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Active Directory

## Active Directory Domain Services - Installation

Facile

1h

3 pairs

Active Directory

## Active Directory Domain Services - Installation

## Introduction

Dans cette quête tu va en apprendre plus sur l'Active Directory. En particulier sur les protocoles réseaux associés, ainsi que sur le rôle des DC.

## 📚 Prérequis

Avant de commencer, il est préférable d'avoir déjà terminé les quêtes suivantes:

```shell
Active Directory Domain Services - Introduction1hVoir la quête - Active Directory Domain Services - IntroductionDNS avec Windows ServerDécouverte du Système des noms de domaine (Domain Name System - DNS) et configuration sur un serveur Windows2hVoir la quête - DNS avec Windows Server
```

---

![logo AD](https://storage.googleapis.com/assets_upload_prod/BiLIVytsyVQwtaW1DtFrRfUIMFuQSY9X.png)

## 🎯 Objectifs

✅ Savoir installer un Active Directory  
✅ Joindre une machine à un domaine

## sommaire

- [📌 Rappels](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#-rappels)
	- [Définition et Explication de l'AD DS](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#d%C3%A9finition-et-explication-de-lad-ds)
		- [Les avantages des services de domaine avec AD DS](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#les-avantages-des-services-de-domaine-avec-ad-ds)
		- [Les termes à connaître](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#les-termes-%C3%A0-conna%C3%AEtre)
		- [Quels sont les services fournis par AD DS?](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#quels-sont-les-services-fournis-par-ad-ds-)
- [🌐 Principaux protocoles réseaux](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#-principaux-protocoles-r%C3%A9seaux)
- [🔐 Rôle des DC](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#-r%C3%B4le-des-dc)
- [🔬 Installation du rôle AD DS](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#-installation-du-r%C3%B4le-ad-ds)
- [⚙️ Configuration post-installation](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#%EF%B8%8F-configuration-post-installation)
- [⚙️ Joindre le domaine](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#%EF%B8%8F-joindre-le-domaine)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [📒 Documentation](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#-documentation)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/1944/pages/18638#-crit%C3%A8res-dacceptation)

## 📌 Rappels

## Définition et Explication de l'AD DS

Le rôle serveur AD DS (Active Directory Domain Services) contient les fonctions essentielles d’Active Directory pour gérer les utilisateurs et les ordinateurs et pour permettre aux administrateurs système d’organiser les données en hiérarchies logiques.  
Il fournit également des certificats de sécurité, l’authentification unique (SSO), LDAP, et la gestion des droits.

## Les avantages des services de domaine avec AD DS

Pour l’administration de base de ses utilisateurs et ordinateurs réseau, l’utilisation d’AD DS présente plusieurs avantages.

- Tu peux personnaliser la façon dont tes données sont organisées de façon à répondre aux besoins de ton entreprise
- Si cela s’avère nécessaire, tu peux gérer AD DS à partir de n’importe quel ordinateur du réseau
- AD DS fournit une fonction intégrée de réplication et de redondance: si un contrôleur de domaine tombe en panne, un autre contrôleur de domaine prend la charge à son compte
- Tout accès aux ressources réseau passe par AD DS, ce qui assure une gestion centralisée des droits d’accès au réseau

## Les termes à connaître

Pour comprendre AD DS, il faut définir quelques termes clés.

- **Schéma**: l’ensemble de règles utilisateur configurées qui régissent les objets et attributs dans AD DS
- **Catalogue Global**: le conteneur de tous les objets AD DS. Si tu as besoin de trouver le nom d’un utilisateur, ce nom est stocké dans le catalogue global
- **Mécanisme de requêtes et d'index**: ce système permet aux utilisateurs de se trouver les uns et les autres dans AD.  
	*Par exemple, lorsque tu commences à saisir un nom dans ton client de messagerie, ce dernier te propose les correspondances possibles.*
- **Services de réplication**: le service de réplication garantit que tous les contrôleurs de domaine du réseau partagent le même catalogue global et le même schéma.
- **Sites**: les sites sont des représentations de la topologie réseau; AD DS sait ainsi quels sont les objets qui vont ensemble, ce qui lui permet d’optimiser la réplication et l’indexation.
- **Lightweight Directory Access Protocol** (LDAP): protocole qui permet à AD de communiquer avec d’autres services d’annuaire sur d’autres plates-formes.

## Quels sont les services fournis par AD DS?

Les services fournis par AD DS suivants constituent les fonctionnalités de base d’un système de gestion centralisée des utilisateurs.

- **Services de domaines**: Stocke les données et gère les communications entre les utilisateurs et le contrôleur de domaine. Il s’agit de la principale fonctionnalité d’AD DS.
- **Services de certificat**: Permet à ton contrôleur de domaine de servir des certificats et des signatures numériques, ainsi qu’un chiffrement à clé publique.
- **Lightweight Directory Services**: Prend en charge LDAP pour des services de domaine multiplateformes, par exemple l’ensemble des ordinateurs Linux présents sur ton réseau.
- **Services de fédération d'annuaire**: Dans la même session, fournit une authentification SSO pour plusieurs applications. Ainsi, les utilisateurs ne sont pas obligés de ressaisir les mêmes identifiants.
- **Gestion des droits**: Contrôle les politiques en matière de droits à l’information et d’accès aux données. Par exemple, la gestion des droits détermine si tu peux accéder à un dossier ou envoyer un e-mail.

---

## 🌐 Principaux protocoles réseaux

L'AD ne fonctionne pas seul, il s'appuie sur des protocoles réseaux standards:

- **DNS**: Indispensable pour permettre la résolution des noms et la localisation des services AD (comme les DC).
- **LDAP** (*Lightweight Directory Access Protocol*): Le protocole standard pour interroger et modifier l'annuaire. AD DS est une implémentation d'un annuaire LDAP.
- **Kerberos**: Protocole d'authentification par défaut qui sécurise les échanges via des tickets et une authentification mutuelle.
- **SNTP**: Assure la synchronisation du temps, ce qui est critique pour le bon fonctionnement de Kerberos et de la réplication.

## 🔐 Rôle des DC

Les DC répondent aux demandes d'authentification et stockent les données AD DS.  
Ils hébergent également les services suivants, complémentaires à AD DS:

- **KDC** (Kerberos Key Distribution Center): Il vérifie et chiffre les tickets Kerberos utilisés par AD DS pour l'authentification.
- **NetLogon**: C'est le service de communication des informations d'authentification
- **Windows Time** (W32Time): Ce service assure la synchronisation des horloges des ordinateurs du domaine AD. Kerberos impose que les horloges de tous les ordinateurs soient synchronisées.
- **IsmServ** (*Intersite Messaging*): Il permet aux DC de communiquer les uns avec les autres pour la réplication et le routage inter-sites.

De plus:

- AD DS doit avoir au moins 1 DC.
- AD DS gère les relations de confiance entre plusieurs domaines ou **Relation d'approbation**, ce qui te permet d’accorder les droits d’accès des utilisateurs d’un domaine à d’autres domaines de sa forêt.
```shell
LDAP sur WikipédiaSi tu veux en savoir plus sur le protocole LDAP.https://fr.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol
```

## 🔬 Installation du rôle AD DS

Le serveur doit avoir une adresse IP statique.  
Le rôle DNS n'est pas installé.  
Pour la suite on estime que ce serveur a une adresse fixe dans la plage IP des machines clientes, par exemple 172.16.10.0/24.

- Aller dans le **Server Manager**
- Cliquer sur **Manage** -> **Add Roles and Features** pour démarrer l'ajout du rôle Active Directory Domain Sevices
- Cliquer sur **Next**
- Laisser l'option sélectionnée par défaut **Role-Based or feature-based installation** et cliquer sur **Next**
- Garder le serveur sélectionné et cliquer sur **Next**
- Cocher les rôles **Active Directory Domain Services** et **DNS Server**
- Une fenêtre contextuelle va apparaître pour chaque rôle coché, il faut cliquer sur **Add Features** pour inclure les outils d'administration proposés
- Cliquer sur **Next** 4 fois
- Cliquer sur **Install** et ensuite sur **Close** pour laisser l'installation en arrière-plan

## ⚙️ Configuration post-installation

- Cliquer sur l'icône ronde avec des flèches à l’intérieur qui tournent pour rafraîchir l'affichage
- Attendre l'icone de notification (triangle jaune)
- Une fois que l'icone apparaît, cliquer dessus et cliquer sur **Promote this server to a domain controller**
- Une fenêtre va apparaître
- Sélectionner **Add a new forest** et dans **Root domain name** mettre le nom du domaine, par exemple `wilders.lan`
- Cliquer sur **Next**
- Laisser les options par défaut et mettre (2 fois) le mot de passe pour le **DSRM**
- Cliquer sur **Next** 5 fois (laisser toutes les options par défaut)
- Cliquer sur **Install**
- Une fois que l'installation est terminé, le serveur redémarre

## ⚙️ Joindre le domaine

Sur le client, aller dans les propriétés systèmes.

- Aller dans l'onglet **Nom de l'ordinateur**
- Cliquer sur **Modifier**
- Dans **Domaine** mettre le nom du domaine et valider  
	![fenêtre windows 11 des propriété systèmes](https://storage.googleapis.com/assets_upload_prod/FblC70tK9HiyEvKDivqbBLdqmCytMPYI.png)
- Un compte sera demandé, il faut mettre le compte `Administrator` du serveur avec le mot de passe associé
- Ensuite l'ordinateur devra être redémarré
```shell
Si un message d'erreur apparaît, vérifier le DNS
```

Après s'être reconnecté, on peut vérifier que le client est bien sur le domaine avec les commandes suivantes:

En cmd.exe:

```shell
1
systeminfo | findstr /i "domaine"
```

En Powershell:

```powershell
1
(Get-CimInstance Win32_ComputerSystem).Domain
```

On peut aussi le vérifier sur le serveur, dans la console **Active Directory Users and Computers**. Dans ce cas, vérifier si l'objet client est dans le conteneur **Computers**.

---

## ☝️ Résumé

Active Directory repose sur des protocoles réseaux essentiels: **DNS** pour localiser les services, **LDAP** pour interroger l'annuaire, **Kerberos** pour l'authentification sécurisée et **SNTP** pour la synchronisation du temps.  
Les **contrôleurs de domaine (DC)** stockent les données AD DS et assurent l'authentification via des services clés comme KDC, NetLogon, Windows Time et la réplication inter-sites.  
L'installation d'AD DS se fait via le **Server Manager**. Après l'installation, le serveur doit être **promu contrôleur de domaine** en créant une nouvelle forêt.  
Enfin, les clients rejoignent le domaine en configurant le **nom de domaine** (avec un DNS correct).

---

## 📒 Documentation

```shell
Créer un domaine Active Directory sur Windows Server
Ce tuto aborde les différentes étapes pour mettre en place graphiquement un contrôleur de domaine sur un serveur Windowshttps://www.windows8facile.fr/ws2016-creer-domaine-active-directory-dns-dhcp/
```
```shell
Installer et configurer Active Directory avec PowerShell
La mise en place d'un contrôleur de domaine est aussi possible directement avec PowerShell comme expliqué dans cet articlehttps://remiflandrois.fr/2019/01/28/install-config-ad-powershell/
```

---

## 💪Challenge

Sur un Windows Server déployé sur une VM.

```shell
Pense à faire un clone de ta machine (Snapshot) pour avoir un backup, au cas où tu ferais une mauvaise configuration qui rendrait ta machine inutilisable.
```
- Mettre en place le service Active Directory Domain Services sur le serveur ayant l'adresse IP 172.16.10.5
- Créer un domaine `wilders.lan`
- Joindre un client au domaine

Poste un lien Github qui contiendra des copies d'écran légendés:

- La fenêtre du Server Manager où on voit clairement que le rôle AD DS est installé
- La fenêtre de la console Active Directory Users and Computers dans laquelle on voit que le client est dans le conteneur Computers

## 🧐 Critères d'acceptation

- Le lien github contient 2 copies d'écran avec une légende pour chacune

Solution postée le **lundi 29 décembre 2025**

[https://github.com/LiudSwen/AD-DS-Quest/blob/main/AD-DS-Installation.md](https://github.com/LiudSwen/AD-DS-Quest/blob/main/AD-DS-Installation.md)