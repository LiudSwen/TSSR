---
title: "Atelier - Installation et configuration Active Directory - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3033/pages/11418"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Active Directory

## Atelier - Installation et configuration Active Directory

Moyen

2h

Auto-validation

Active Directory

## Atelier - Installation et configuration Active Directory

## Introduction

**Active Directory** (ou **AD**) est un élément clé de nombreux environnements informatiques d'entreprise, offrant une plateforme centralisée pour la gestion des identités, des accès et des ressources. En mettant en place Active Directory, tu crées un annuaire sécurisé et extensible qui simplifie l'administration des utilisateurs, des groupes, des ordinateurs et des politiques de sécurité. Dans cet atelier, tu vas explorer les fondamentaux de la conception, de la mise en œuvre et de la gestion d'un environnement Active Directory, en mettant l'accent sur des bonnes pratiques et des solutions adaptées à tes besoins.  
Prépare-toi à plonger dans le cœur de l'infrastructure informatique moderne et à acquérir les compétences nécessaires pour construire et maintenir un AD robuste et sécurisé.

![logo microsoft active directory](https://storage.googleapis.com/quest_editor_uploads/dx5hzG1lrc2YsanVLpKWumup6WuUym9D.png)

## 🎯 Objectifs

✅ Configurer un Active Directory avec des rôles  
✅ Intégrer des ordinateurs à un domaine  
✅ Mettre en place des bonnes pratiques de sécurité  
✅ Effectuer un durcissement de configuration

## sommaire

- [✔️ Étape 1 - Prérequis](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#%EF%B8%8F-%C3%A9tape-1---pr%C3%A9requis)
- [🔬 Étape 2 - Installation et configuration AD](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#-%C3%A9tape-2---installation-et-configuration-ad)
	- [Installation des rôles](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#installation-des-r%C3%B4les)
		- [Configuration en Contrôleur de domaine](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#configuration-en-contr%C3%B4leur-de-domaine)
		- [Création d'une hiérarchie AD](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#cr%C3%A9ation-dune-hi%C3%A9rarchie-ad)
		- [Création de groupes de sécurité](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#cr%C3%A9ation-de-groupes-de-s%C3%A9curit%C3%A9)
		- [Création d'utilisateurs](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#cr%C3%A9ation-dutilisateurs)
- [⚙️ Étape 3 - Intégration de CLIENT1 au domaine](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#%EF%B8%8F-%C3%A9tape-3---int%C3%A9gration-de-client1-au-domaine)
	- [Ajout au domaine](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#ajout-au-domaine)
		- [Différences avec les machine hors-domaine - Partie utilisateurs](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#diff%C3%A9rences-avec-les-machine-hors-domaine---partie-utilisateurs)
		- [Différences avec les machine hors-domaine - Partie ordinateurs](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#diff%C3%A9rences-avec-les-machine-hors-domaine---partie-ordinateurs)
- [⚙️ Étape 4 - Intégration de CLIENT2 au domaine](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#%EF%B8%8F-%C3%A9tape-4---int%C3%A9gration-de-client2-au-domaine)
	- [Ajout au domaine](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#ajout-au-domaine-1)
		- [Suppression du droit d'ajout de machines au domaine](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#suppression-du-droit-dajout-de-machines-au-domaine)
		- [Délégation du droit d'ajout à un domaine pour un compte non-administrateur](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#d%C3%A9l%C3%A9gation-du-droit-dajout-%C3%A0-un-domaine-pour-un-compte-non-administrateur)
		- [Vérification de la configuration de la délégation](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#v%C3%A9rification-de-la-configuration-de-la-d%C3%A9l%C3%A9gation)
		- [Test d'ajout au domaine](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#test-dajout-au-domaine)
- [🏆 Conclusion](https://odyssey.wildcodeschool.com/quests/3033/pages/11418#-conclusion)

## ✔️ Étape 1 - Prérequis

Tu a besoin de 3 VM sous Virtualbox:

- 1 VM serveur Windows Server 2022
- 2 VM client Windows 10

Les VM sont configurés de la manière suivante:

| Fonction de la VM | Serveur | Client |
| --- | --- | --- |
| Nom | WINSERV1 | CLIENT1 / CLIENT2 |
| OS | Windows Server 2022 | Windows 10 |
| OS version | Standard Desktop Experience | Professionnel |
| RAM | 4/8 Go | 2/4 Go |
| Langue à installer | English (US) | French |
| Time and currency / keyboard | French | French |
| Carte réseau VirtualBox | Réseau privé | Réseau privé |
| Adresse IP | 10.10.5.10/24 | 10.10.5.100/24 et 10.10.5.200/24 |
| Passerelle | \- | \- |
| DNS | 10.10.5.10 ou 127.0.0.1 | 10.10.5.10 |
| Utilisateur local | Administrator | Wilder |
| Firewall | Désactivé | Désactivé |

```shell
Pour cet atelier, le serveur est sous OS Windows Server 2022, et les clients sont sous OS Windows 10. Ces machines sont virtualisées sous Virtualbox 7 tournant sur un système hôte Ubuntu 22.04 LTS.

Les expérimentations pratiques peuvent être reproduites avec d'autres versions, sur d'autres distributions Linux, et sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## Installation des rôles

- Ouvre une session avec `Administrator`
- Dans le **Server Manager**, aller dans le menu **Manage** → **Add Roles and Features** → Next (3 fois)
- Ajouter **Active Directory Domain Service** et **DNS Server** (avec features) → Next (4 fois), Install, et Close
- Attendre la fin de la configuration et redémarrer

## Configuration en Contrôleur de domaine

- Clic sur l'icone du drapeau en haut à droite (⚠️) ➔ **Promote this server to a domain controller**
- Sélectionner **Add a new forest**
```shell
Ton serveur va être le premier Contrôleur de domaine de la forêt, donc tu dois créer une forêt.
```
- Configuration:
	- Root domain name: **lab.lan** → Next
		- Entrer un mot de passe pour le DSRM → Next (4 fois)
		- Attendre le **Prerequisite check completed**
		- Clic sur Install et attendre que le serveur redémarre
- Ouvrir une session `Administrator`
- Aller dans **Server manager** → **Tools** → **Active Directory Users and Computers**
- Dans le menu **View**, sélectionne **Advanced Features**
```shell
Le fait d'activer les Advanced Features ajoute des possibilités de paramétrage dans les différentes fenêtres de configuration AD.
```
- Dérouler l'arborescence sous le domaine `lab.lan`
- Créer 3 OU sur la racine du domaine (décocher « Protect container from accidental deletion »):
	- LabUtilisateurs
		- LabOrdinateurs
		- LabSecurite

## Création de groupes de sécurité

Créer 2 groupes dans l’OU LabSecurite:

- Groupe **GrpLabUsers**:
	- Group scope: Global
		- Group type: Security
- Groupe **GrpLabAdmin**:
	- Group scope: Domain Local
		- Group type: Security

## Création d'utilisateurs

Créer 3 comptes utilisateurs dans l'OU LabUtilisateurs:

- User1
- User2
- Wilder

## ⚙️ Étape 3 - Intégration de CLIENT1 au domaine

## Ajout au domaine

Test la communication entre CLIENT1 et le serveur avec un ping. Si cela ne fonctionne pas, vérifier les firewall!

Pour l'intégration au domaine:

- Sur le client, aller dans dans **Système** → **Paramètres avancés du système**
- Onglet **Nom de l'ordinateur** → Modifier → Mettre le nom de domaine dans le champ "Domaine"
- Utiliser le compte administrateur du domaine, soit `lab\administrator` pour intégrer CLIENT1 au domaine lab

> Il peut être nécessaire de mettre le FQDN du domaine, soit **lab.lan**.  
> Donc le compte à utiliser sera `lab.lan\administrator`.

- Redémarrer la machine

Vérifier sur le serveur que la machine est bien dans le domaine:

- Aller dans la console **Active Directory Users and Computers** et vérifier que CLIENT1 est bien dans le conteneur `Computers`.
- Déplace la machine dans l'OU `LabOrdinateurs`
```shell
Bonne pratique :

Ne pas laisser les ordinateurs nouvellement intégrés au domaine dans Computers.

Sais-tu pourquoi ?
```
```shell
Voir la solutionAucune stratégie de sécurité ne s'applique sur les conteneurs natif, comme Computers.

Il est donc fortement conseillé de placer les utilisateurs et les ordinateurs dans des OU.
```

## Différences avec les machine hors-domaine - Partie utilisateurs

Sur les 2 machines clients, sur la session **wilder**, ouvre une console cmd.exe.  
Exécute la commande `gpresult /R`:

Sur CLIENT1, qui est sur le domaine, tu dois avoir un affichage qui ressemble à ça:

```shell
1
Données RSOP pour CLIENT1\wilder sur CLIENT1 : mode journalisation
2
-------------------------------------------------------------------
3

4
Configuration du système d’exploitation : Station de travail membre
5
Version du système d’exploitation...... : 10.0.19045
6
Nom du site............................ : N/A
7
Profil itinérant :             N/A
8
Profil local........................... : C:\Users\wilder
9
Connexion via une liaison lente ? : Non
10

11

12
PARAMÈTRES UTILISATEURS
13
------------------------
14

15
    Heure de la dernière application de la stratégie de groupe : 23/04/2024 à 10:31:57
16
    Stratégie de groupe appliquée depuis :      N/A
17
    Seuil de liaison lente dans la stratégie de groupe :   500 kbps
18
    Nom du domaine :                        CLIENT1
19
    Type de domaine :                        <Ordinateur local>
20

21
    Objets Stratégie de groupe appliqués
22
    -------------------------------------
23
        N/A
24

25
    Les objets stratégie de groupe n’ont pas été appliqués
26
    car ils ont été refusés
27
    -----------------------------------------------------------------------------------
28
        Stratégie de groupe locale
29
          Filtrage :  Non appliqué (vide)
30

31
    L’utilisateur fait partie des groupes de sécurité suivants
32
    ----------------------------------------------------------
33
        Aucun
34
        Tout le monde
35
        Compte local et membre du groupe Administrateurs
36
        Administrateurs
37
        Utilisateurs
38
        INTERACTIF
39
        OUVERTURE DE SESSION DE CONSOLE
40
        Utilisateurs authentifiés
41
        Cette organisation
42
        Compte local
43
        LOCAL
44
        Authentifications NTLM
45
        Niveau obligatoire élevé
```

Et sur CLIENT 2, qui n'est pas sur le domaine, ton affichage dois ressembler à ça:

```shell
1
Données RSOP pour CLIENT2\wilder sur CLIENT2 : mode journalisation
2
-------------------------------------------------------------------
3

4
Configuration du système d’exploitation : Station de travail autonome
5
Version du système d’exploitation...... : 10.0.19045
6
Nom du site............................ : N/A
7
Profil itinérant :             N/A
8
Profil local........................... : C:\Users\wilder
9
Connexion via une liaison lente ? : Non
10

11

12
PARAMÈTRES UTILISATEURS
13
------------------------
14

15
    Heure de la dernière application de la stratégie de groupe : 23/04/2024 à 10:32:05
16
    Stratégie de groupe appliquée depuis :      N/A
17
    Seuil de liaison lente dans la stratégie de groupe :   500 kbps
18
    Nom du domaine :                        DESKTOP-5B4HQH8
19
    Type de domaine :                        Windows NT 4
20

21
    Objets Stratégie de groupe appliqués
22
    -------------------------------------
23
        N/A
24

25
    Les objets stratégie de groupe n’ont pas été appliqués
26
    car ils ont été refusés
27
    -----------------------------------------------------------------------------------
28
        Stratégie de groupe locale
29
          Filtrage :  Non appliqué (vide)
30

31
    L’utilisateur fait partie des groupes de sécurité suivants
32
    ----------------------------------------------------------
33
        Aucun
34
        Tout le monde
35
        Compte local et membre du groupe Administrateurs
36
        Administrateurs
37
        Utilisateurs
38
        INTERACTIF
39
        OUVERTURE DE SESSION DE CONSOLE
40
        Utilisateurs authentifiés
41
        Cette organisation
42
        Compte local
43
        LOCAL
44
        Authentifications NTLM
45
        Niveau obligatoire élevé
```

La seule indication que la machine CLIENT1 est dans un domaine est l'indication `Station de travail membre`.

Il n'y a aucune indication pour l'utilisateur. Pourquoi?

```shell
Voir la solutionTu es connecté avec le compte wilder, qui est un compte local, d'où l'affichage qui ne précise rien sur l'utilisateur.

On le voit avec CLIENT1\wilder sur CLIENT1 (en haut du résultat de la commande gpresult).
```

Ferme la session de CLIENT1 et reconnecte-toi avec le compte du domaine **user1**.  
De nouveau, dans une console cmd.exe, exécute la commande `gpresult /R`.

Cette fois-ci, la partie **PARAMÈTRES UTILISATEURS** change:

```shell
1
Données RSOP pour LAB\user1 sur CLIENT1 : mode journalisation
2
--------------------------------------------------------------
3

4
Configuration du système d’exploitation : Station de travail membre
5
Version du système d’exploitation...... : 10.0.19045
6
Nom du site............................ : N/A
7
Profil itinérant :             N/A
8
Profil local........................... : C:\Users\user1
9
Connexion via une liaison lente ? : Non
10

11

12
PARAMÈTRES UTILISATEURS
13
------------------------
14
    CN=user1,OU=LabUtilisateurs,DC=lab,DC=lan
15
    Heure de la dernière application de la stratégie de groupe : 23/04/2024 à 11:16:41
16
    Stratégie de groupe appliquée depuis :      WINSERV1.lab.lan
17
    Seuil de liaison lente dans la stratégie de groupe :   500 kbps
18
    Nom du domaine :                        LAB
19
    Type de domaine :                        Windows 2008 ou supérieur
```

Différente informations sont apparues ou ont été mises à jour:

- `Données RSOP pour LAB\user1 sur CLIENT1`: **RSOP** (pour *Resultant Set of Policy*) est le résultat des politiques de sécurités appliquées sur les elements d'un domaine AD. On voit bien ici que la session a été ouverte avec un compte du domaine.
- `CN=user1,OU=LabUtilisateurs,DC=lab,DC=lan` qui est le **DistinguishedName** de l'utilisateur **user1**, ou encore sont emplacement dans l'AD:
	- `CN=user1`: CN indique un objet de type *Common Name*, la cible est ici l'utilisateur **user1**
		- `OU=LabUtilisateurs`: OU indique une *Organizational Unit*, qui est l'OU **LabUtilisateurs**
		- `DC=lab,DC=lan`: composantes du nom de domaine complet **lab.lan** (appelé **FQDN** ou *Fully Qualified Domain Name*)
- `Stratégie de groupe appliquée depuis :      WINSERV1.lab.lan`: Le serveur AD sur lequel l'utilisateur a eu son jeton de connexion est la machine **WINSERV1** qui est sur le domaine lab.lan
- `Nom du domaine :                        LAB`: Le nom du domaine

## Différences avec les machine hors-domaine - Partie ordinateurs

Il est possible de visualiser les information de la partie ordinateurs (et donc pas des utilisateurs) à partir des machines, toujours avec la commande `gpresult`, mais à partir de la session **administrateur**.

Sur CLIENT2, qui n'est pas sur le domaine, connecte toi en administrateur local, et exécute la commande `gpresult /R`:

```shell
1
Données RSOP pour CLIENT2\Administrateur sur CLIENT2 : mode journalisation
2
---------------------------------------------------------------------------
3

4
Configuration du système d’exploitation : Station de travail autonome
5
Version du système d’exploitation...... : 10.0.19045
6
Nom du site............................ : N/A
7
Profil itinérant :             N/A
8
Profil local........................... : C:\Users\Administrateur
9
Connexion via une liaison lente ? : Non
10

11

12
Paramètre de l’ordinateur
13
--------------------------
14

15
    Heure de la dernière application de la stratégie de groupe : 23/04/2024 à 10:31:04
16
    Stratégie de groupe appliquée depuis :      N/A
17
    Seuil de liaison lente dans la stratégie de groupe :   500 kbps
18
    Nom du domaine......................... : DESKTOP-5B4HQH8
19
    Type de domaine........................ : Windows NT 4
20

21
    Objets Stratégie de groupe appliqués
22
    -------------------------------------
23
        N/A
24

25
    Les objets stratégie de groupe n’ont pas été appliqués
26
    car ils ont été refusés
27
    -----------------------------------------------------------------------------------
28
        Stratégie de groupe locale
29
          Filtrage :  Non appliqué (vide)
30

31
    L’ordinateur fait partie des groupes de sécurité suivants
32
    ---------------------------------------------------------
33
        Administrateurs
34
        Tout le monde
35
        Utilisateurs authentifiés
36
        Niveau obligatoire système
37

38

39
PARAMÈTRES UTILISATEURS
40
------------------------
41

42
[...]
```

Tout une partie `Paramètre de l’ordinateur` s'affiche désormais.

## ⚙️ Étape 4 - Intégration de CLIENT2 au domaine

## Ajout au domaine

Prends l'un des comptes du domaine que tu as crée, à la place du compte Administrator, pour intégrer la machine CLIENT2 au domaine.  
Est-ce que cela fonctionne?  
Est-ce normal?

```shell
Voir la solutionEt bien oui !

C'est une configuration standard étonnante, mais par défaut, tous les comptes utilisateurs d'un domaine peuvent inclure des machines dans ce même domaine !

Cette limite par défaut est fixée à 10 machine par utilisateur.

Une bonne pratique est de désactiver cette fonctionnalité.
```

Pour la suite de l'atelier, sort la machine du domaine:

- Sur CLIENT2, retourne dans la même fenêtre que celle qui te permet d'ajouter la machine au domaine, et dans le champ **Groupe de travail** met `WORKGROUP`
- Sur le serveur, supprime l'objet AD correspondant à CLIENT2
```shell
Le fait de supprimer l'objet ordinateur correspondant à CLIENT2 sur le serveur supprime également le SID.

Si on réintègre la machine cliente au domaine, elle aura un nouveau SID.

⚠️ À ne pas faire si on veut garder les relations entre ce client et les autres objets AD.
```

## Suppression du droit d'ajout de machines au domaine

- Sur le serveur AD, ouvre la console **Active Directory Users and Computers**
- Va ensuite dans les paramètres du domaine **lab.lan** (bouton droit de la souris et **properties**)
- Va sur l'onglet **Atribute Editor**, cherche l'attribut `ms-DS-MachineAccountQuota`, et met la valeur à 0
- Valide ta modification
```shell
Cette suppression du droit est une bonne pratique.

Cela n'enlève pas le droit d'ajout au domaine pour les comptes administrateurs du serveur.
```

## Délégation du droit d'ajout à un domaine pour un compte non-administrateur

- Dans la console **Active Directory Users and Computers**, clic avec le bouton droit de la souris sur le conteneur **Computers** et sélectionne **Delegate Control**
- Pour **Users or Groups**, ajoute un des comptes du domaine que tu as crée
- Pour **Tasks to Delegate**, sélectionne `Create a custom task to delegate`
- Pour **Active Directory Object Type**, sélectionne `Only the following objects in the folder`, `Computer object`, et `Create selected objects in this folder`
- Pour **Permissions**, sélectionne `General`, `Creation/deletion of specific child objects`, et `Create All Child Objects`
- Valide par Finish

## Vérification de la configuration de la délégation

- Dans la console **Active Directory Users and Computers**, clic avec le bouton droit de la souris sur le conteneur **Computers** et sélectionne **Properties**
- Dans l'onglet **Security** sélectionne l'utilisateur que tu as pris pour la délégation et clic sur **Advanced**
- Dans la nouvelle fenêtre, de nouveau sélectionne ton utilisateur et clic sur **Edit** pour avoir tout le détail de la délégation de droit.

## Test d'ajout au domaine

Essaye d'ajouter CLIENT2 au domaine en te servant d'un compte **qui n'est pas celui que tu as pris pour la délégation de droits**.  
Que se passe-t'il? Quel message as-tu?

Maintenant, fais la même chose, mais avec le compte que tu as pris pour la délégation.  
Est-ce que CLIENT2 est bien intégré au domaine?

## 🏆 Conclusion

Tu peux valider cet atelier si tu as correctement configuré ton AD et si ta délégation de droits fonctionne.

Quête terminée le **mercredi 07 janvier 2026**