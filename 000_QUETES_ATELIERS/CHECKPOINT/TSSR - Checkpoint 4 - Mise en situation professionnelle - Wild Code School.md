---
title: "TSSR - Checkpoint 4 - Mise en situation professionnelle - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2816/pages/12386"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Checkpoint TSSR

## TSSR - Checkpoint 4 - Mise en situation professionnelle

Difficile

1h 30mins

1 formateur

Checkpoint TSSR

## TSSR - Checkpoint 4 - Mise en situation professionnelle

## Introduction

Voici venu le moment du dernier checkpoint de ta formation.

Comme les précédents, celui-ci est un point d'étape. Il a pour principal objectif de te permettre de vérifier si tu as bien assimilé les compétences vues jusqu'à présent.

A la différence des précédents, celui-ci peut être considéré comme un *passage de titre blanc*.

Ce checkpoint se fera en 3 parties:

- Une **mise en situation professionnelle** de 1h30
- Un **questionnaire professionnel** de 2h
- Un **entretien technique individuel** d'une durée maximale de 30 min

La mise en situation professionnelle et le questionnaire professionnel n'ont pas de lien et sont indépendant.  
L'entretien technique sera une discussion technique sous la forme d'un échange oral à partir de support ou non.

```shell
Activités et compétences types évaluées dans ce checkpoint :

Exploiter les éléments de l’infrastructure et assurer le support aux utilisateurs

 Assurer le support utilisateur en centre de services
 Exploiter des serveurs Windows et un domaine Active Directory
 Exploiter des serveurs Linux
 Exploiter un réseau IP

Maintenir l’infrastructure et contribuer à son évolution et à sa sécurisation

 Maintenir des serveurs dans une infrastructure virtualisée
 Automatiser des tâches à l’aide de scripts
 Maintenir et sécuriser les accès à Internet et les interconnexions des réseaux
 Mettre en place, assurer et tester les sauvegardes et les restaurations des éléments de l’infrastructure
 Exploiter et maintenir les services de déploiement des postes de travail
```

Cette partie du checkpoint concerne la **mise en situation professionnelle**.

![dessin de 2 personnes devant leur ordinateurs avec pleins d'autres ordinateurs reliés entre-eux](https://www.simplilearn.com/ice9/free_resources_article_thumb/Types_of_Networks_1.png)

## 📝 Objectifs

✅ Faire toutes les interventions demandées  
✅ Mettre les réponses correctes dans le formulaire réponse  
✅ Valider les compétences acquises durant la formation

## Sommaire

- [🔍 Contexte de ce checkpoint](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#-contexte-de-ce-checkpoint)
- [📖 Comment répondre aux questions (*How to*)](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#-comment-r%C3%A9pondre-aux-questions-how-to)
- [🔧 Equipements à disposition](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#-equipements-%C3%A0-disposition)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#-challenge)
	- [1\. Adaptation de script](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#1-adaptation-de-script)
		- [Intervention 1](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#intervention-1)
				- [Intervention 2](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#intervention-2)
		- [2\. Active Directory](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#2-active-directory)
		- [Intervention 1](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#intervention-1-1)
				- [Intervention 2](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#intervention-2-1)
				- [Intervention 3](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#intervention-3)
		- [3\. Serveur Linux](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#3-serveur-linux)
		- [Intervention 1](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#intervention-1-2)
				- [Intervention 2](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#intervention-2-2)
		- [4\. Téléphonie](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#4-t%C3%A9l%C3%A9phonie)
		- [Intervention 1](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#intervention-1-3)
				- [Intervention 2](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#intervention-2-3)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2816/pages/12386#-crit%C3%A8res-dacceptation)

## 🔍 Contexte de ce checkpoint

```shell
A ton passage de titre, la mise en situation professionnelle dure 1h30. A la fin du temps imparti, le jury te demandera de cesser toute production et tu devras rendre tes réponses.

Afin de te mettre en condition d'examen :

Ne consulte pas les cours et autres contenus qui sont sur le drive de ta formation
Le formulaire de réponse devra être rendu à la fin du temps imparti
```
```shell
L'utilisation d'internet est possible pendant cette partie du checkpoint 4.
```

Les réponses à ce checkpoint sont à fournir dans le document **FichierReponseMiseEnSituationProfessionnelle** à télécharger [ici](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/TSSRCheckpoint4/).  
Le mot de passe de l'archive zip qui contient le fichier réponse est **AUbwR9bUmanTpDZo1TRc9**.

Les réponses aux questions sont uniquement constituées de copies d'écran, tel que cela est demandé.

```shell
Ton formateur ne regardera pas le contenu des VM, elles ne sont là que pour tester tes réponses et les valider.

Seul le remplissage correct du fichier de réponses avec des copies d'écran validera ton travail.
```

## 🔧 Equipements à disposition

Dans ce checkpoint, tu interviens sur une infrastructure réseau constituée de différentes VM.

Pour les utiliser:

- Télécharge les fichiers OVA correspondant à partir de ce lien: [TéléchargementVM](https://drive.google.com/drive/folders/1Mm3BfKpSfJDcEm2g3koPBA3zYHQ-ubY1?usp=drive_link)
- Importe les machines virtuelles dans Virtualbox
- Démarre-les lorsqu'elles sont necessaire

Listes des VM:

| Nom | OS | Fonction | Paramètres IP | Utilisateurs |
| --- | --- | --- | --- | --- |
| SRVWIN01 | Windows Server 2022 | AD-DS, DNS, DHCP | 172.16.10.10/24 | administrator |
| SRVLX01 | Linux Debian 11 | Glpi, serveur web | 172.16.10.15/24 | root, wilder |
| SRVLX02 | Linux Red Hat 7 | IPBX | 172.16.10.5/24 | root |
| CLIENT01 | Windows 10 | \- | DHCP | administrateur, wilder |

```shell
Indications supplémentaires sur les VM :

Tous les mots de passe des comptes utilisateurs du tableau ci-dessus sont P@ssw0rdTssR
Tous les outils et logiciels necessaires sont installés sur les machines
Les différentes mise en veille des machines Windows sont désactivées
```
```shell
N'hésite pas à cloner une VM, ou à faire un snapshot si tu n'est pas sûr de tes manipulations.
```

---

## 💪 Challenge

## 1\. Adaptation de script

Machine concernée: **CLIENT01**

### Intervention 1

Sur la machine **CLIENT01**, tu trouveras le script PowerShell `C:\Scripts\GetIpConfiguration.ps1`.  
Dans ce script, remplace les commentaires `# XXX` par un commentaire qui explique ce que fait la ligne ou le paragraphe situé en dessous.

Question 1:  
Insère la ou les copies d'écran du script avec tes commentaires.

### Intervention 2

Fais 2 copies de ce script (nommées `GetIpConfiguration_1.ps1` et `GetIpConfiguration_2.ps1`) et modifie les pour avoir en sortie écran:

- L'alias d'interface
- L'adresse IP v4
- Le masque de sous-réseaux
- Le statut du DHCP

En complément, tu dois exporter les informations trouvées dans un fichier de sortie. Ce fichier se nomme `export1.csv` pour le premier script, et `export2.csv` pour le second. Ils sont placés au même endroit que les scripts, et les informations sont séparées par des ";" (point-virgule).

L'affichage de sortie du script `GetIpConfiguration_1.ps1` doit être **exactement** comme ci-dessous (avec les attributs dans l'ordre):

```powershell
1
InterfaceAlias      IPAddress       PrefixLength      Dhcp
2
--------------      ---------       ------------      ----
3
Ethernet            172.16.10.60    24                Enabled
```

L'affichage de sortie du script `GetIpConfiguration_2.ps1` doit être **exactement** comme ci-dessous (avec le contenu de chaque ligne dans l'ordre):

```powershell
1
Type d'interface : Ethernet
2
Adresse IP :          172.16.10.60/24
3
Statut du DHCP :   Enabled
```

Voilà ce que peut être le contenu du fichier `export1.csv`:

```powershell
1
Ethernet;172.16.10.60;24;Enabled
```

De même, voilà ce que peut être le contenu du fichier `export2.csv`:

```powershell
1
Ethernet;172.16.10.60/24;Enabled
```

Question 2:  
Insérer les copies d'écran du script GetIpConfiguration\_1.ps1, de l'affichage de sortie, et du contenu du fichier export1.csv.

Question 3:  
Insérer les copies d'écran du script GetIpConfiguration\_2.ps1, de l'affichage de sortie, et du contenu du fichier export2.csv.

## 2\. Active Directory

Machines concernées: **SRVWIN01** et **CLIENT01**

### Intervention 1

Modifie la configuration du service DHCP sur le serveur pour que le client ai l'adresse IP dynamique 172.16.10.100.

Question 4:  
Insérer les copies d'écran de la configuration DHCP sur le serveur, ainsi que le résultat de la commande "ipconfig/all" sur le client.

### Intervention 2

On souhaite mettre un fond d'écran sur les machines clientes suivant le service dans lequel se trouve les utilisateurs.  
En te basant sur les GPO existantes, créer une GPO `USER-Interface-Wallpaper-Gestion` pour les personnes ayant un compte dans l'OU **Gestion**.

Cette GPO:

- Affiche l'image **C:\\Content\\Gestion.jpg** en fond d'écran
- A une application sécurisée par des groupes de filtrage (contenant les utilisateurs de l'OU Gestion)

Question 5:  
Insérer les copies d'écran de la configuration de la GPO (contenu et partie filtrage), ainsi que le résultat sur le client.

### Intervention 3

Faire en sorte que le serveur IPBX soit accessible par le nom **ipbx.lab.lan**.

Question 6:  
Insérer la ou les copies d'écran de la configuration sur serveur, ainsi que le résultat de la commande "ping" sur le client.

## 3\. Serveur Linux

Machines concernées: **SRVLX01** et **CLIENT01**

```shell
Tu peux te servir du serveur SRVWIN01 pour délivrer un paramétrage IP à la machine cliente CLIENT01.

Si tu souhaite t'en passer, n'oublie pas de paramétrer la machine CLIENT01 en IP fixe.
```

### Intervention 1

Afin d'améliorer la sécurité de l'accès SSH au serveur, fais les modifications suivantes:

- Interdire l'accès avec le compte **root**
- Interdire l'accès par mot de passe
- Autoriser l'accès par clé de chiffrement
- Modifier le port TCP de ce service pour qu'il soit accessible sur le numéro 22504

Question 7:  
Insérer la ou les copies d'écran de la configuration sur le serveur, ainsi que l'application dans une connexion SSH depuis le client vers le serveur.

### Intervention 2

Sur le home directory de root tu as:

- Un fichier **LisezMoi** qui contient des informations sur les serveurs/applications installés
- Un fichier **En-Travaux.tar.gz** qui contient une image et l'index d'un site temporaire

Ce site temporaire doit s'afficher à la place du site intranet.

Question 8:  
Insérer la copie d'écran de l'application sur le client lors de la visite du site web.

## 4\. Téléphonie

Machines concernées: **SRVLX02**, **SRVWIN01**, et **CLIENT01**

Pour les interventions, 2 softphones vont être utilisés, un sur chacun des PC Windows (client et serveur).

### Intervention 1

Créer le compte de l'utilisateur **Miguel Hernandez** avec le numéro 80104 sur l'IPBX.

Question 9:  
Insérer la ou les copies d'écran de la configuration du compte sur l'IPBX, ainsi que le résultat sur le client.

### Intervention 2

Mettre en service les 2 softphones avec les lignes de Miguel Hernandez et d'Emma Chen.

Question 10:  
Insérer la ou les copies d'écran attestant une communication réussie entre les 2 utilisateurs.

## 🧐 Critères d'acceptation

Les réponses aux questions doivent être fournie sous forme de copies d'écran, comme demandé dans le formulaire réponse.  
Le fichier doit être mis en pdf et uploadé.

Solution postée le **mercredi 11 mars 2026**

[Télécharger le fichier](https://storage.googleapis.com/odyssey_production_solutions/solutions/002d8b8cd3edb11a35f3dbf1410fa5a5?GoogleAccessId=odyssey-app%40odyssey-react-267410.iam.gserviceaccount.com&Expires=1774255202&Signature=Pc3MkTffdF7OjPX0SO1NdeP0hDuxwTbfOaij8x%2FZ5wFSTL1xVlT1iIZtWX9fCG1PW%2FZhFp58jdbbHgxJCZhmPyRcdwVdo4Z6UM9yutjNBH7xz95FYElFC33uI9OMiJ7%2FKLnajjSKli9ZPYB8sW3W09KCcryb760alRYgZOsc4r4bXoLJlDpp6Z0EI5LVVUVChuiDPh7o7BA6NN62d3XaxmmFd4mWjd2SGxhiendQs0bbk40DeGV7Gbo8QCDOiPYo1RhC98uTlT9Hb5ykxpFYDPtaZD976awqa%2FuBvMxMMDg%2Fb%2FUpvdXGoLc%2FKu7SWUHaiWFo4i6PGheypSTlsj0Phw%3D%3D)

⚠️ La Wild Code School n'est pas responsable des liens / fichiers partagés par les Wilders.