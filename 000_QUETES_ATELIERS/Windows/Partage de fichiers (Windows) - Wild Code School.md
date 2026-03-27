---
title: "Partage de fichiers (Windows) - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3084/pages/11751"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Windows

## Partage de fichiers (Windows)

Moyen

3 pairs

Windows

## Partage de fichiers (Windows)

## Introduction

Dans cette quête, tu vas explorer le partage de ressources en environnement Windows, en te concentrant particulièrement sur le protocole SMB (Server Message Block) et la mise en place d'un serveur de fichiers. Cette compétence est cruciale pour tout administrateur systèmes et réseaux travaillant dans un environnement Windows.

![Windows_File_Sharing](https://storage.googleapis.com/quest_editor_uploads/lThujmQmdJBJJmSrPH9j2Z4uoIKHnC4C.png)

## 🤓 Objectifs:

✅ Comprendre l'intérêt de la centralisation des fichiers bureautiques  
✅ Maîtriser le fonctionnement du protocole SMB  
✅ Mettre en place un serveur de fichiers Windows et des lecteurs réseau clients

## Sommaire

- [👉 Contexte: Pourquoi centraliser les fichiers bureautiques?](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#-contexte--pourquoi-centraliser-les-fichiers-bureautiques-)
	- [Avantages de la centralisation](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#avantages-de-la-centralisation)
- [👉 Le protocole SMB: principes et fonctionnement](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#-le-protocole-smb--principes-et-fonctionnement)
	- [Qu'est-ce que SMB?](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#quest-ce-que-smb-)
		- [Versions de SMB](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#versions-de-smb)
		- [Fonctionnement de SMB](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#fonctionnement-de-smb)
		- [Ports utilisés par SMB](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#ports-utilis%C3%A9s-par-smb)
- [👉 Aperçu des droits d'accès: Windows vs Linux](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#-aper%C3%A7u-des-droits-dacc%C3%A8s--windows-vs-linux)
	- [Droits d'accès sous Windows](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#droits-dacc%C3%A8s-sous-windows)
		- [Droits d'accès sous Linux](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#droits-dacc%C3%A8s-sous-linux)
- [👉 Mise en pratique: Configuration d'un serveur de fichiers Windows](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#-mise-en-pratique--configuration-dun-serveur-de-fichiers-windows)
	- [Installation du rôle Serveur de fichiers](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#installation-du-r%C3%B4le-serveur-de-fichiers)
		- [Création d'un partage](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#cr%C3%A9ation-dun-partage)
		- [Configuration avancée avec PowerShell](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#configuration-avanc%C3%A9e-avec-powershell)
- [👉 Configuration des lecteurs réseau sur les clients](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#-configuration-des-lecteurs-r%C3%A9seau-sur-les-clients)
	- [Via l'interface graphique (GUI)](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#via-linterface-graphique-gui)
		- [Via PowerShell](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#via-powershell)
- [📚 Ressources complémentaires](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#-ressources-compl%C3%A9mentaires)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/3084/pages/11751#-crit%C3%A8res-dacceptation)

## 👉 Contexte: Pourquoi centraliser les fichiers bureautiques?

La centralisation des fichiers bureautiques sur un serveur présente de nombreux avantages dans un environnement professionnel:

## Avantages de la centralisation

1. **Collaboration facilitée**
	- Les employés peuvent facilement partager et travailler sur les mêmes documents.
		- Réduction des conflits de versions et des duplications.
2. **Sécurité renforcée**
	- Contrôle d'accès centralisé
		- Mise en place de politiques de sauvegarde plus efficaces
		- Protection contre les ransomwares et autres menaces
3. **Gestion simplifiée**
	- Mises à jour et maintenance centralisées
		- Application uniforme des politiques de rétention et d'archivage
4. **Économie d'espace**
	- Réduction du stockage redondant sur les postes individuels.
		- Optimisation de l'utilisation de l'espace de stockage.
5. **Accès à distance**
	- Possibilité d'accéder aux fichiers depuis n'importe où, favorisant le télétravail.
		- Amélioration de la productivité des employés mobiles.
6. **Conformité**
	- Facilite la mise en conformité avec les réglementations sur la protection des données.
		- Simplifie les audits et le suivi des accès aux données sensibles.

---

## 👉 Le protocole SMB: principes et fonctionnement

## Qu'est-ce que SMB?

SMB (*Server Message Block*) est un protocole de partage de fichiers en réseau développé par Microsoft. Il permet aux ordinateurs de partager des fichiers, des imprimantes et d'autres ressources sur un réseau local.

## Versions de SMB

Les versions de SMB représentent l'évolution du protocole au fil du temps, chacune apportant des améliorations en termes de performances, de sécurité et de fonctionnalités.

1. **SMB 1.0**:
	- Version originale, obsolète et non sécurisée
		- Introduite avec Windows 2000
		- À éviter dans les environnements modernes
2. **SMB 2.0**:
	- Introduit avec Windows Vista et Windows Server 2008
		- Améliore les performances et la résilience
		- Réduit la "verbosité" du protocole sur le réseau
3. **SMB 3.0**:
	- Introduit avec Windows 8 et Windows Server 2012
		- Ajoute le chiffrement et d'autres fonctionnalités de sécurité
		- Améliore les performances dans les environnements virtualisés
4. **SMB 3.1.1**:
	- La dernière version, introduite avec Windows 10 et Windows Server 2016
		- Renforce encore la sécurité avec une négociation de sécurité plus robuste
		- Améliore les performances dans les scénarios de haute latence

## Fonctionnement de SMB

Le protocole SMB suit un processus en plusieurs étapes pour établir une connexion et partager des ressources:

1. **Découverte**:
	- Le client SMB recherche des serveurs SMB sur le réseau.
		- Utilise généralement le protocole NetBIOS ou DNS pour la résolution de noms.
2. **Négociation**:
	- Le client et le serveur négocient la version du protocole à utiliser.
		- Ils s'accordent sur les fonctionnalités supportées mutuellement.
3. **Authentification**:
	- Le client s'authentifie auprès du serveur.
		- Peut utiliser différentes méthodes (Kerberos, NTLM, etc.)
4. **Accès aux ressources**:
	- Une fois authentifié, le client peut accéder aux ressources partagées.
		- Le serveur applique les permissions appropriées.

## Ports utilisés par SMB

La connaissance des ports utilisés par SMB est cruciale pour la configuration des pare-feu et la sécurisation du réseau:

- **Port 445 (TCP)**: Utilisé par les versions récentes de SMB (2.0 et supérieures)
- **Ports 137-139 (TCP/UDP)**: Utilisés par les versions plus anciennes (avec NetBIOS)

---

## 👉 Aperçu des droits d'accès: Windows vs Linux

## Droits d'accès sous Windows

Windows utilise un système de liste de contrôle d'accès (ACL) avec des permissions de base:

1. **Lecture**: Voir le contenu
2. **Écriture**: Modifier ou créer
3. **Exécution**: Exécuter des fichiers ou accéder aux dossiers
4. **Modification**: Combiner lecture, écriture, exécution et suppression
5. **Contrôle total**: Tous les droits, y compris la modification des permissions

Gestion via:

- Interface graphique: Propriétés > Sécurité
- PowerShell: `Get-Acl`, `Set-Acl`
- Commande: `icacls`
```shell
L’idéal est d'utiliser le module PowerShell NTFSSecurity !
```

## Droits d'accès sous Linux

Linux utilise un système plus simple basé sur trois types de permissions:

- **r (read)**: Lecture
- **w (write)**: Écriture
- **x (execute)**: Exécution

Appliqués à trois catégories:

1. Propriétaire (u)
2. Groupe (g)
3. Autres (o)

Représentation:

- Symbolique: rwxr-xr-x
- Numérique: 755

Gestion via commandes:

- `chmod`: Modifier les permissions
- `chown`: Changer le propriétaire
- `chgrp`: Changer le groupe

## 👉 Mise en pratique: Configuration d'un serveur de fichiers Windows

Tu vas maintenant configurer un serveur de fichiers Windows Server 2022 étape par étape.

## Installation du rôle Serveur de fichiers

1. Ouvre le Gestionnaire de serveur
2. Clique sur "Gérer" > "Ajouter des rôles et fonctionnalités"
3. Choisis "Installation basée sur un rôle ou une fonctionnalité"
4. Sélectionne ton serveur
5. Dans la liste des rôles, coche "Services de fichiers et de stockage" > "Serveur de fichiers"
6. Suis l'assistant pour terminer l'installation

## Création d'un partage

1. Dans le Gestionnaire de serveur, va dans "Services de fichiers et de stockage" > "Partages"
2. Clique droit > "Nouveau partage"
3. Choisis "Partage SMB - Rapide"
4. Sélectionne l'emplacement du dossier à partager
5. Nomme ton partage (ex: "Fichiers\_Entreprise")
6. Configure les permissions NTFS et de partage selon tes besoins
7. Termine l'assistant

## Configuration avancée avec PowerShell

L'utilisation de PowerShell permet une configuration plus rapide et automatisable du serveur de fichiers.

Pour créer un partage via PowerShell:

```powershell
1
New-SmbShare -Name "Fichiers_Entreprise" -Path "C:\Partages\Fichiers_Entreprise" -FullAccess "Tout le monde"
```
```shell
Attention si le serveur est en langage US !
```

Pour voir les partages existants:

```powershell
1
Get-SmbShare
```

---

## 👉 Configuration des lecteurs réseau sur les clients

La configuration des lecteurs réseau permet aux utilisateurs d'accéder facilement aux partages depuis leurs postes de travail.

## Via l'interface graphique (GUI)

1. Ouvre l'Explorateur de fichiers
2. Clique droit sur "Ce PC" > "Connecter un lecteur réseau"
3. Choisis une lettre de lecteur
4. Entre le chemin du partage (ex: \\\\nom\_serveur\\Fichiers\_Entreprise)
5. Coche "Se reconnecter à l'ouverture de session" si désiré
6. Clique sur "Terminer"

## Via PowerShell

L'utilisation de PowerShell permet d'automatiser la configuration des lecteurs réseau, ce qui est particulièrement utile dans les grands environnements.

Pour mapper un lecteur réseau:

```powershell
1
New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\nom_serveur\Fichiers_Entreprise" -Persist
```

Pour voir les lecteurs mappés:

```powershell
1
Get-PSDrive -PSProvider FileSystem
```

## 📚 Ressources complémentaires

```shell
Pour approfondir tes connaissances sur le partage de fichiers en environnement Windows et le protocole SMB, voici quelques ressources officielles et utiles :

Documentation officielle Microsoft sur SMB
PowerShell pour la gestion des partages SMB

N'hésite pas à consulter ces ressources pour approfondir ta compréhension et améliorer tes compétences en matière de partage de fichiers sous Windows.
```

---

## 📝 Quiz

```shell
# 1  - Quel est le principal avantage de la centralisation des fichiers bureautiques ?Augmentation de la vitesse des postes clientsFacilitation de la collaboration et de la sécuritéRéduction de la bande passante réseauValider# 2 SMB 3.0SMB 1.0SMB 2.0Valider# 3 44513980Valider# 4 Add-SmbShareNew-SmbShareCreate-SmbShareValider# 5 New-PSDriveConnect-NetworkDriveMap-NetworkDriveValider# 6 Cela réduit l'espace de stockage nécessaireCela simplifie la gestion des droits d'accèsCela augmente la vitesse d'accès aux fichiersValider# 7 Elle n'est compatible qu'avec Windows 10 et versions ultérieuresC'est la première version à supporter le chiffrementElle offre des fonctionnalités de sécurité améliorées par rapport aux versions précédentesValiderTon score :0 / 7
```

---

## 💪Challenge

Sur un Windows Server 2022 avec le rôle ADDS déployé sur une VM:

1. Installe le rôle Serveur de fichiers
2. Crée un dossier "Documents\_Entreprise" à la racine du disque C:
3. Configure un partage nommé "Docs" pour ce dossier
4. Crée trois sous-dossiers: "RH", "Comptabilité" et "Direction"
5. Configure les permissions NTFS et de partage pour que:
	- Le groupe "RH" ait un accès en lecture/écriture au dossier "RH"
		- Le groupe "Comptabilité" ait un accès en lecture/écriture au dossier "Comptabilité"
		- Le groupe "Direction" ait un accès en lecture/écriture à tous les dossiers
		- Tous les utilisateurs du domaine aient un accès en lecture seule au dossier "Documents\_Entreprise"
6. Utilise PowerShell pour lister tous les partages sur le serveur
7. Sur un poste client Windows 10, configure un lecteur réseau pointant vers ce partage via PowerShell
8. Teste l'accès depuis le poste client avec différents comptes utilisateurs
9. Rédige une procédure au format markdown détaillant pas à pas la configuration et les tests effectués, incluant les commandes PowerShell utilisées

## 🧐 Critères d'acceptation

- Ton serveur de fichiers est correctement installé et configuré
- Le partage "Docs" est accessible depuis le réseau
- Les permissions NTFS et de partage sont correctement appliquées selon les spécifications
- Tes commandes PowerShell pour lister les partages et mapper le lecteur réseau fonctionnent correctement
- Les utilisateurs peuvent accéder uniquement aux dossiers et avec les permissions que tu leur as attribuées
- Ta procédure est claire, détaillée et permet de reproduire la configuration

Solution postée le **lundi 12 janvier 2026**

[https://gist.github.com/LiudSwen/fc1d0bbed21a1c9f5d49e77406c4b5f1](https://gist.github.com/LiudSwen/fc1d0bbed21a1c9f5d49e77406c4b5f1)