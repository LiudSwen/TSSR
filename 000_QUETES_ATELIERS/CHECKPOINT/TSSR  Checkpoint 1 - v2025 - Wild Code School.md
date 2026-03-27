---
title: "TSSR : Checkpoint 1 - v2025 - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3961/pages/18613"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Checkpoint TSSR

## TSSR: Checkpoint 1 - v2025

Moyen

4h

1 formateur

Checkpoint TSSR

## TSSR: Checkpoint 1 - v2025

![image](http://workshop.industrial-architecture.cloud/images/atEonlfPz5Unq02sGCd1Nw.png)  
Un checkpoint, comme son nom l'indique est un point d'étape plus qu'une évaluation. Il te permet de vérifier la compréhension des compétences vues jusqu'à présent.  
Il n'y a pas de surprises! Les notions abordées sont celles vues dans les semaines qui viennent de s'écouler.

C'est un exercice **individuel**, essaye de le faire dans le temps imparti, en condition d'examen, c'est-à-dire sans aucun documents hormis ceux fournis pendant ce checkpoint.  
Comme dans la vraie vie, on ne connait pas tout par cœur, et si tu est bloqué, dans ce cas réfère toi au contenu pédagogique à ta disposition (quêtes, cours, etc.) et à Internet si nécessaire pour continuer.

Malgré cela, si tu ne peux pas le rendre aujourd'hui, ne t'inquiète pas, tu as la possibilité de le rendre lundi matin à 9h, en ajoutant ` Effectué en dehors du timing` dans ton rendu.  
Dans ce cas, il doit être rendu le plus complet possible.

L'essentiel est que tu comprennes et sois capable de mettre en application les notions abordées, si tu n'as pas encore la rapidité, cela viendra en t'exerçant.  
Ton formateur va t'aider dans cette évaluation en examinant le travail que as fourni et en validant la quête le cas échéant.

Bon courage!

```shell
Activités et compétences types évaluées dans ce checkpoint :

Exploiter les éléments de l’infrastructure et assurer le support aux utilisateurs

 Assurer le support utilisateur en centre de services
 Exploiter des serveurs Windows et un domaine Active Directory
✅  Exploiter des serveurs Linux
 Exploiter un réseau IP

Maintenir l’infrastructure et contribuer à son évolution et à sa sécurisation

 Maintenir des serveurs dans une infrastructure virtualisée
✅  Automatiser des tâches à l’aide de scripts
 Maintenir et sécuriser les accès à Internet et les interconnexions des réseaux
 Mettre en place, assurer et tester les sauvegardes et les restaurations des éléments de l’infrastructure
 Exploiter et maintenir les services de déploiement des postes de travail
```

## 🎯 Objectifs

✅ Réaliser les 3 exercices du challenge  
✅ Valider les compétences acquises durant ces dernières semaines de formations

## Sommaire

- [🧰 Prérequis](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#-pr%C3%A9requis)
- [🧭 Mise en contexte](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#-mise-en-contexte)
- [❓ Répondre aux questions des exercices (*How to*)](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#-r%C3%A9pondre-aux-questions-des-exercices-how-to)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#-challenge)
	- [Exercice 1 - Gestion du systèmes (temps estimé: 2h)](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#exercice-1---gestion-du-syst%C3%A8mes-temps-estim%C3%A9--2h)
		- [1.1 Modification du nom de machine](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#11-modification-du-nom-de-machine)
				- [1.2 Création d'utilisateurs](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#12-cr%C3%A9ation-dutilisateurs)
				- [1.3 Gestion de droits](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#13-gestion-de-droits)
				- [1.4 Préparation du disque](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#14-pr%C3%A9paration-du-disque)
				- [1.5 Montage](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#15-montage)
		- [Exercice 2 - Filtrage et traitement de données (temps estimé: 30 min)](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#exercice-2---filtrage-et-traitement-de-donn%C3%A9es-temps-estim%C3%A9--30-min)
		- [2.1 Donne la ligne de commande Bash qui...](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#21-donne-la-ligne-de-commande-bash-qui-)
				- [2.2 Donne les lignes de commandes Bash qui...](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#22-donne-les-lignes-de-commandes-bash-qui-)
		- [Exercice 3 - Script de création d'utilisateurs en bash (temps estimé: 1h30)](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#exercice-3---script-de-cr%C3%A9ation-dutilisateurs-en-bash-temps-estim%C3%A9--1h30)
- [🧐 Critères de validation](https://odyssey.wildcodeschool.com/quests/3961/pages/18613#-crit%C3%A8res-de-validation)

## 🧰 Prérequis

La VM fournie par ton formateur est téléchargée et montée sur Virtualbox.  
Un dossier partagé est configuré sur Virtualbox pour échanger des fichiers si nécessaire.

Télécharge le fichier compressé **checkpoint1.zip** disponible [ici](https://github.com/WildCodeSchool/TSSR_Resources/tree/main/Checkpoint1).  
Le mot de passe pour le décompresser est:  
`pH=R,,a#$W_7~WT$d%f/H`.  
Tu as maintenant à disposition un formulaire de réponses **Checkpoint1\_reponses.docx**.

```shell
Ce formulaire de réponses devra être mis en PDF avant d'être rendu.
```

## 🧭 Mise en contexte

Tu vas effectuer des manipulations d'administration système sur une machine.  
Cette machine est la machine virtuelle (VM) **UBU01** fournie par ton formateur.

```shell
Si tu ne l'as pas déjà fait, effectue un clone de cette VM au cas où tu aurais un problème avec pendant ce checkpoint.
```

Détails sur la VM:

| Type de machine | Nom | Interface | Utilisateurs | Mot de passe |
| --- | --- | --- | --- | --- |
| Client | UBU01 | NAT | Wilder | tSsruBuntu01! |
|  |  |  | prestataire | tSsruBuntu02! |

```shell
Cette VM ne sert que pendant le checkpoint, elle n'est pas rendu à la fin.

Tu peux donc modifier les mots de passe des comptes déjà présent pour aller plus vite.
```

## ❓ Répondre aux questions des exercices (How to)

Il n'y a pas d'ordre pour faire les exercices.  
Les réponses doivent être mises dans le formulaire de réponses.

2 types de questions te sont posées:

- Des questions théoriques ouvertes  
	Pour ces questions, les réponses (jamais plus d'un court paragraphe de quelques lignes) sont à écrire dans la partie prévue pour cela en dessous du numéro de la question dans le formulaire de réponses.
```shell
Réponds correctement aux questions demandées en argumentant.

Seules les réponses complètes, techniques et argumentées seront prises en compte.

⚠️ Aucune copie d'écran ne seront prise en compte.
```
- Des questions pratiques  
	Ces questions nécessitent de faire des actions et/ou d'exécuter des commandes sur une ou des VM du checkpoint.  
	Pour ces questions, les réponses à fournir consistent à mettre une ou plusieurs copies d'écran dans la partie prévue pour cela en dessous du numéro de la question dans le formulaire de réponse.
```shell
Seule tes copies d'écran font foi pour tes réponses. Tu dois montrer clairement ce qui est demandé avec la copie d'écran des fenêtres de la ou des VM, pas de l'écran entier.

L'ordre d'exécution doit être respecté.

⚠️ Aucune explication écrite ne seront prise en compte.
```

## 💪 Challenge

## Exercice 1 - Gestion du systèmes (temps estimé: 2h)

Toutes les réponses doivent être mise dans le formulaire de réponses.

```shell
Toutes les actions doivent être faite en CLI.
```

### 1.1 Modification du nom de machine

Modifie le nom de la VM en `TSSR<Numéro de session TSSR>`.

**À rendre**:

- Copie d'écran du paramétrage
- Copie d'écran du résultat

### 1.2 Création d'utilisateurs

Créer un compte supplémentaire sur le système:

- Un compte utilisateur qui est sous la forme `<Ton prénom>_<Ton nom>`
- Mets le mot de passe que tu souhaites
- Fais en sorte que ce compte puisse faire une élévation de privilèges

**À rendre**:

- Copie d'écran de la création du compte
- Copie d'écran de la gestion des droits
- Copie d'écran du résultat

### 1.3 Gestion de droits

Sur le bureau de l'utilisateur **wilder** il y a 2 dossiers **dossier1** et **dossier2**.  
Ces 2 dossiers (et leurs contenus) ne sont pas accessibles depuis le bureau de l'utilisateur **prestataire**.  
Fais les modifications pour que ce soit le cas.

**À rendre**:

- Copie d'écran de la modification de configuration pour que le compte **prestataire** ai accès à **dossier1**
- Copie d'écran de la modification de configuration pour que le compte **prestataire** ai accès à **dossier2**

### 1.4 Préparation du disque

La VM a 2 disques durs. Tu dois préparer le second disque dur de cette manière:

- 1 partition de 6 Go de type ext4 nommée **DATA**
- 1 partition de 2 Go de type ext4 nommée **PERSO**
- 1 partition avec le reste du disque de type swap nommée **SWAP**
	- C'est cette partition **SWAP** qui sera activée (si un autre swap existe déjà il faut le désactiver)
```shell
La commande fdisk doit être utilisée au lieu de cfdisk.
```

**À rendre**:

- Copie d'écran de la création et du formatage des partitions
- Copie d'écran de la gestion du swap
- 1 ou plusieurs copies d'écran avec:
	- Taille des partitions finales
		- Type de système de fichiers
		- Nom des partitions

### 1.5 Montage

Configure le système pour que:

- La partition **DATA** soit montée automatiquement au démarrage du système dans un dossier `/mnt/data`
- La partition **PERSO** soit montée automatiquement au démarrage du système dans un dossier `/home/wilder/Documents/personnel`
```shell
L'UUID du disque doit être utilisé.

N'oublie pas de vérifier ta configuration à la fin !
```

**À rendre**:

- Des copies d'écran qui permettent de voir clairement les étapes de la configuration pour le montage automatique des 2 partitions
- Une copie d'écran du fichier de configuration principal

## Exercice 2 - Filtrage et traitement de données (temps estimé: 30 min)

Toutes les réponses doivent être mise dans le formulaire de réponses.

Sur la session de l'utilisateur **wilder** tu as le fichier `/home/Documents/apprenants.csv`.  
Ce fichier regroupe les informations d'élèves (fictifs) en fin de formation avancée.  
De gauche à droite, les colonnes sont:

- Prénom
- Nom
- Ville
- Formation initiale
- Formation avancée
- Pourcentage de réussite sur le projet 1
- Pourcentage de réussite sur le projet 2
- Pourcentage de réussite sur le projet 3

### 2.1 Donne la ligne de commande Bash qui...

Q1. Affiche tous les apprenants ayant une formation initiale en **devweb**.

Q2. Affiche uniquement les lignes contenant le prénom **Liam**.

Q3. Affiche le nombre d'apprenants de **Bordeaux** et de **Lyon**, avec une formation initiale en **tssr**, dont les 3 projets ont été réussis à 100%.

Q4. Affiche uniquement les prénoms et les noms, avec les noms triés alphabétiquement

### 2.2 Donne les lignes de commandes Bash qui...

Q5. Pour les apprenants dont:

- Le projet 1 est à 70 ou 80
- Le projet 2 est à 80 ou 90
- Le projet 3 est à 90 ou 100
- Le pourcentage de réussite des projets est obligatoirement croissant  
	La liste ainsi que le nombre d'apprenant concernés sont envoyés dans le fichier **bonneEvolution.txt**.  
	Le fichier contient la liste sous la forme: `<Nom>_<Prénom> <Projet 1> <Projet 2> <Projet 3>`

## Exercice 3 - Script de création d'utilisateurs en bash (temps estimé: 1h30)

Le rendu de cet exercice n'est pas à mettre dans le formulaire de réponses.

**Objectif du script**:

- Création automatique d'utilisateurs
- Les utilisateurs à créer sont entrés en argument du script

**Détail du script**:

- Nom: `addUsers.sh`
- Langage d’exécution: `bash`

**Utilisation du script**:  
On exécute le script en mettant en arguments des noms d'utilisateurs à créer.

Exemple pour créer 3 utilisateurs **user1**, **user2**, **user3**:  
`./addUsers.sh user1 user2 user3`

```shell
On doit pouvoir créer un nombre quelconques d'utilisateurs, soit 2, soit 3, soit 5, ... Et pas uniquement 3 comme dans l'exemple !
```

**Tâches du script**:

- Il doit y avoir une vérification de la présence d'arguments. Sans argument, le script affiche `"Il manque les noms d'utilisateurs en argument - Fin du script"` et il s’arrête.
- Pour chaque utilisateur à créer, il doit y avoir une vérification de l'existence dans le système. S'il existe déjà, un message indiquera `"L'utilisateur <nom_utilisateur> existe déjà"` et le script continue.
- Pour chaque utilisateur crée, il doit y avoir une vérification de cette création. Si la création s'est bien effectuée, un message affiche `"L'utilisateur <nom_utilisateur> a été crée"`. Sinon, un message affiche `"Erreur à la création de l'utilisateur  <nom_utilisateur>"`. Dans tous les cas, le script continue.

**A rendre**:

- Le pseudo-code de l'analyse en format Markdown dans un fichier **addUsers\_pseudoCode.md**
- Le script **addUsers.sh** complet et fonctionnel

## 🧐 Critères de validation

Faire les 3 exercices dans le temps imparti

- Exercice 1: à rendre dans le formulaire de réponses
- Exercice 2: à rendre dans le formulaire de réponses
- Exercice 3: les 2 fichiers sont à rendre à part

Le dépôt Github de réponses doit contenir:

- 1 formulaire de réponses mis en **PDF** soit **Checkpoint1\_reponses.pdf**
- 1 fichier en format markdown **addUsers\_pseudoCode.md**
- 1 fichier script Bash **addUsers.sh**

Solution postée le **vendredi 21 novembre 2025**

[https://github.com/LiudSwen/tssr-1025-checkpoint1-matthias](https://github.com/LiudSwen/tssr-1025-checkpoint1-matthias)