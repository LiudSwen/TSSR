---
title: "TSSR - Checkpoint 3 - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2934/pages/18685"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Checkpoint TSSR

## TSSR - Checkpoint 3

Moyen

4h

1 formateur

Checkpoint TSSR

## TSSR - Checkpoint 3

![Illustration sur laquelle est écrit Checkpoint avec un picto figurant une épingle classiquement utilisé pour marqué des points d'étape sur des cartes](http://workshop.industrial-architecture.cloud/images/atEonlfPz5Unq02sGCd1Nw.png)

Voici venu le moment du checkpoint!

Comme les précédents, celui-ci est un point d'étape. Il a pour principal objectif de te permettre de vérifier si tu as bien assimilé les compétences vues jusqu'à présent.

Il n'y a pas de surprises, il s'agit de mettre en application les notions abordées dans les semaines qui viennent de s'écouler. Tu peux bien sûr te référer aux quêtes, cours et ateliers que tu as déjà effectuées et à la documentation.  
Néanmoins, c'est un exercice individuel qu'il te faut réaliser seul·e.

Tu devrais être en mesure de le finir dans le temps imparti. Plus tu as des automatismes, plus tu iras vite.  
Néanmoins, il ne s'agit pas d'un examen et si tu n'as pas fini au bout de la durée impartie, ne t'inquiète pas, tu peux poursuivre ces exercices dans les jours qui viennent.  
La rapidité d'exécution n'étant pas la compétence essentielle nécessaire à ce checkpoint, tu es **fortement invité** à le retravailler par la suite afin de réussir à valider les compétences.  
L'essentiel est que tu comprennes et sois capable de mettre en application les notions abordées, si tu n'as pas encore la rapidité, cela viendra en t'exerçant.

Ton formateur va t'aider dans cette évaluation en examinant le travail que tu as fourni et en validant la quête le cas échéant.  
Si tu n'as pas tout fini dans les délais, tu ajouteras simplement un commentaire `# Effectué en dehors du timing`, pour l'indiquer à ton formateur. Ça lui permettra de bien comprendre les forces et faiblesses de chacun, et de s'adapter.

```shell
Activités et compétences types évaluées dans ce checkpoint :

Exploiter les éléments de l’infrastructure et assurer le support aux utilisateurs

 Assurer le support utilisateur en centre de services
 Exploiter des serveurs Windows et un domaine Active Directory
✅ Exploiter des serveurs Linux
✅ Exploiter un réseau IP

Maintenir l’infrastructure et contribuer à son évolution et à sa sécurisation

✅ Maintenir des serveurs dans une infrastructure virtualisée
 Automatiser des tâches à l’aide de scripts
✅ Maintenir et sécuriser les accès à Internet et les interconnexions des réseaux
 Mettre en place, assurer et tester les sauvegardes et les restaurations des éléments de l’infrastructure
 Exploiter et maintenir les services de déploiement des postes de travail
```

## 📝 Objectifs

✅ Réaliser les 2 exercices du challenge  
✅ Valider les compétences acquises durant ces dernières semaines de formations

## Sommaire

- [🤓 Contexte de ce checkpoint](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#-contexte-de-ce-checkpoint)
- [📖 Répondre aux questions (*How to*)](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#-r%C3%A9pondre-aux-questions-how-to)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#-challenge)
	- [Exercice 1: Manipulations pratiques sur VM Windows (temps estimé: 1h30)](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#exercice-1--manipulations-pratiques-sur-vm-windows-temps-estim%C3%A9--1h30)
		- [Partie 1: Gestion des utilisateurs](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#partie-1--gestion-des-utilisateurs)
				- [Partie 2: Restriction utilisateurs](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#partie-2--restriction-utilisateurs)
				- [Partie 3: Lecteurs réseaux](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#partie-3--lecteurs-r%C3%A9seaux)
		- [Exercice 2: Manipulations pratiques sur VM Linux (temps estimé: 2h30)](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#exercice-2--manipulations-pratiques-sur-vm-linux-temps-estim%C3%A9--2h30)
		- [Partie 1: Gestion des utilisateurs](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#partie-1--gestion-des-utilisateurs-1)
				- [Partie 2: Configuration de SSH](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#partie-2--configuration-de-ssh)
				- [Partie 3: Analyse du stockage](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#partie-3--analyse-du-stockage)
				- [Partie 4: Sauvegardes](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#partie-4--sauvegardes)
				- [Partie 5: Filtrage et analyse réseau](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#partie-5--filtrage-et-analyse-r%C3%A9seau)
				- [Partie 6: Analyse de logs](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#partie-6---analyse-de-logs)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2934/pages/18685#-crit%C3%A8res-dacceptation)

## 🤓 Contexte de ce checkpoint

Dans ce checkpoint, tu interviens sur 2 machines virtuelles VirtualBox:

- Une VM Windows Server nommée **SRVWIN01**
- Une VM GNU/Linux nommée **SRVLX01**

La VM Windows a une interface réseau configurées en mode `Réseau interne`.  
La VM GNU/Linux a une interface réseau configurée en mode `Bridge` et utilise DHCP en IPv4 et l'auto-configuration IPv6 standard. Il est possible d'y accéder via ssh.

Détails sur les VM:

| Type de machine | Nom | Utilisateur | Mot de passe |
| --- | --- | --- | --- |
| Windows Server | SRVWIN01 | Administrator | %Adm!n@2k=T0p |
| GNU/Linux | SRVLX01 | wilder | wcs4ever |
|  |  | root | MXtTvqGXmZDf |

Ton formateur vas te fournir le fichier de réponses **Checkpoint3\_formulaireReponses.docx**.

---

## 📖 Répondre aux questions (How to)

Les réponses doivent être mise dans le fichier **Checkpoint2\_reponses.docx**.

2 types de questions te sont posées:

- **Des questions théoriques ouvertes**  
	Pour ces questions, les réponses (jamais plus d'un court paragraphe de quelques lignes) sont à écrire dans la partie prévue pour cela en dessous du numéro de la question dans le fichier de réponses.
```shell
Réponds correctement aux questions demandées. Seules les réponses complètes, techniques et argumentées seront prises en compte.
```
- **Des questions pratiques**  
	Ces questions demande de lancer des commandes et d'effectuer des actions sur les VM du checkpoint.  
	Pour ces questions, les réponses à fournir consistent à mettre une ou plusieurs copies d'écran dans la partie prévue pour cela en dessous du numéro de la question dans le fichier réponse.
```shell
Seule tes copies d'écran font foi pour tes réponses. Tu dois montrer clairement ce qui est demandé avec la copie d'écran des fenêtres, pas de l'écran entier. L'ordre d'exécution doit être respecté.

Si tu mets des explications écrites elles ne seront pas prise en compte.
```

---

## 💪 Challenge

## Exercice 1: Manipulations pratiques sur VM Windows (temps estimé: 1h30)

Pour cet exercice tu as besoin de la VM **SRVWIN01**.

### Partie 1: Gestion des utilisateurs

L'utilisateur **Kelly Rhameur** a quitté l'entreprise.  
Elle est remplacée par **Lionel Lemarchand**

**Q.1.1.1** Créer l'utilisateur **Lionel Lemarchand** avec les même attribut de société que **Kelly Rhameur**.

**Q.1.1.2** Créer une OU **DeactivatedUsers** et déplace le compte désactivé de **Kelly Rhameur** dedans.

**Q.1.1.3** Modifier le groupe de l'OU dans laquelle était **Kelly Rhameur** en conséquence.

**Q.1.1.4** Créer le dossier Individuel du nouvel utilisateur et archive celui de **Kelly Rhameur** en le suffixant par **\-ARCHIVE**.

### Partie 2: Restriction utilisateurs

**Q.1.2.1** Faire en sorte que l'utilisateur **Gabriel Ghul** ne puisse se connecter que du lundi au vendredi, de 7h à 17h.

**Q.1.2.2** De même, bloquer sa connexion au seul ordinateur **CLIENT01**.

**Q.1.2.3** Mettre en place une stratégie de mot de passe pour durcir les comptes des utilisateurs de l'OU **LabUsers**.

### Partie 3: Lecteurs réseaux

**Q.1.3.1** Créer une GPO **Drive-Mount** qui monte les lecteurs **E:** et **F:** sur les clients.

## Exercice 2: Manipulations pratiques sur VM Linux (temps estimé: 2h30)

Pour cet exercice tu as besoin de la VM **SRVLX01**.

### Partie 1: Gestion des utilisateurs

**Q.2.1.1** Sur le serveur, créer un compte pour ton usage personnel.

**Q.2.1.2** Quelles préconisations proposes-tu concernant ce compte?

### Partie 2: Configuration de SSH

Un serveur SSH est lancé sur le port par défaut.  
Il est possible de s'y connecter avec n'importe quel compte, y compris le compte root.

**Q.2.2.1** Désactiver complètement l'accès à distance de l'utilisateur root.

**Q.2.2.2** Autoriser l'accès à distance à ton compte personnel uniquement.

**Q.2.2.3** Mettre en place une authentification par clé valide et désactiver l'authentification par mot de passe

### Partie 3: Analyse du stockage

**Q.2.3.1** Quels sont les systèmes de fichiers actuellement montés?

**Q.2.3.2** Quel type de système de stockage ils utilisent?

**Q.2.3.3** Ajouter un nouveau disque de 8,00 Gio au serveur et réparer le volume RAID

**Q.2.3.4** Ajouter un nouveau volume logique LVM de 2 Gio qui servira à héberger des sauvegardes. Ce volume doit être monté automatiquement à chaque démarrage dans l'emplacement par défaut: `/var/lib/bareos/storage`.

**Q.2.3.5** Combien d'espace disponible reste-t-il dans le groupe de volume?

### Partie 4: Sauvegardes

Le logiciel bareos est installé sur le serveur.  
Les composants `bareos-dir`, `bareos-sd` et `bareos-fd` sont installés avec une configuration par défaut.

**Q.2.4.1** Expliquer succinctement les rôles respectifs des 3 composants bareos installés sur la VM.

### Partie 5: Filtrage et analyse réseau

**Q.2.5.1** Quelles sont actuellement les règles appliquées sur Netfilter?

**Q.2.5.2** Quels types de communications sont autorisées?

**Q.2.5.3** Quels types sont interdit?

**Q.2.5.4** Sur nftables, ajouter les règles nécessaires pour autoriser bareos à communiquer avec les clients bareos potentiellement présents sur l'ensemble des machines du réseau local sur lequel se trouve le serveur.

```shell
Rappel : Bareos utilise les ports TCP 9101 à 9103 pour la communication entre ses différents composants.
```

### Partie 6: Analyse de logs

**Q.2.6.1** Lister les 10 derniers échecs de connexion ayant eu lieu sur le serveur en indiquant pour chacun:

- La date et l'heure de la tentative
- L'adresse IP de la machine ayant fait la tentative

## 🧐 Critères d'acceptation

Toutes tes réponses écrites, ainsi que tes copies d'écran sont mise dans le fichier de réponses.  
Ce fichier est mis en PDF dans un dépôt Github dont le lien sera donné en solution à ce checkpoint.

```shell
Seront considéré comme faux :

Toutes les questions non répondues
Toutes les réponses fausses ou hors-sujet
Toutes les réponses n'ayant pas de justification
Des commandes ou des captures d'écran sans rapport avec la question
Des commandes ou des captures d'écran manquantes
```

Solution postée le **vendredi 13 février 2026**

[https://github.com/LiudSwen/Checkpoint3](https://github.com/LiudSwen/Checkpoint3)