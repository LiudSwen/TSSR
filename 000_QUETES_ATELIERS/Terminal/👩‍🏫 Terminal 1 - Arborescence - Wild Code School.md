---
title: "👩‍🏫 Terminal 1 - Arborescence - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1315/pages/10181"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Terminal

## 👩🏫 Terminal 1 - Arborescence

Découvre comment explorer l'arborscence de ton système de fichiers

Facile

45mins

3 pairs

Terminal

## 👩🏫 Terminal 1 - Arborescence

## Introduction

Le développeur doit souvent utiliser le terminal pour travailler sur son ordinateur afin d'effectuer diverses opérations.  
Le terminal peut sembler effrayant à première vue.  
Mais tu verras, c'est un outil vraiment facile à utiliser et il peut t'aider à effectuer certaines opérations de base plus rapidement.

Dans cette quête, tu vas découvrir le **terminal**, ainsi que quelques **commandes de base pour explorer l'arborescence des répertoires**.

![image](https://storage.googleapis.com/quest_editor_uploads/PHYfp98TW0FrXy9M92aRlkFPDEcIinRF.jpg)

## 🤓 A la fin de cette quête, tu vas:

- ✅ Comprendre comment afficher le contenu d'un répertoire
- ✅ Savoir te repérer dans l'arborescence
- ✅ Comprendre comment naviguer dans l'arborescence
- ✅ Connaître ce que sont les arguments ou les paramètres d'une commande
- ✅ Comprendre la signification de `.`, `..` et `~`

---

## 👩💻 💻 Utilisateurs Mac et Windows

Le terminal que tu vas découvrir, dans cette quête et les suivantes, est un héritage du **système d'exploitation Unix**... Dont Linux est un descendant.

###### Et si tu n'utilises pas Linux, mais MacOS ou Windows?

#### MacOS

Bonne nouvelle: **MacOS descend également d'Unix**, et il est livré avec un **terminal** (recherche Spotlight via cmd+space, puis "terminal").  
La principale **différence avec Linux** est que ton **répertoire personnel** sera quelque chose comme `/Users/myname` au lieu de `/home/myname`.

D'autres différences plus subtiles concernent les options acceptées par certaines commandes, mais cela ne devrait pas t'affecter lors de ces quêtes "terminal".

#### Windows

Windows est un descendant de **MS-DOS**, qui s'est lui-même inspiré d'Unix.  
Il fournit un **terminal**, offrant des *équivalents* aux commandes Unix, mais avec des noms différents!

Il est donc nécessaire d'installer un **autre terminal**, afin de bénéficier d'un environnement proche des systèmes Unix.  
Tu devras installer **Git Bash**, en suivant les instructions fournies dans ce [Gist](https://gist.github.com/bhubr/00c6e39e72231cf091a17772d73e6fb3).  
Veinard, en faisant cela, tu auras déjà Git installé!

Une fois le processus d'installation terminé, Tu pourras suivre ces quêtes sans problème, la principale différence étant que **ton répertoire d'origine sera quelque chose comme** `/c/Users/MyName` au lieu de `/home/wilder`.

---

## 🖥️ Le terminal

![image](https://storage.googleapis.com/quest_editor_uploads/ZhqXKK3F9DqQhQ9nvr2ZRR3IxgvsUtOm.jpeg)

**A quoi ça sert?**

Le terminal te permet d' **exécuter des commandes en les tapant sur le clavier**.  
Quel intérêt à une époque où nos ordinateurs ont des interfaces graphiques conviviales et nos smartphones des écrans tactiles?

Eh bien, même si ce n'est pas immédiatement évident pour toi, le terminal offre **de nombreuses possibilités**. Par exemple, il y a des commandes pour:

- **Manipuler** (copier, déplacer, renommer, supprimer) des fichiers et des répertoires
- **Extraire** des informations spécifiques à partir de fichiers texte volumineux plus rapidement qu'avec un éditeur de texte.
- **Rechercher** efficacement des fichiers dans une arborescence de fichiers, selon différents critères (nom, date de modification, etc.)
- **Installer** un logiciel
- et d' **autres choses** (la liste complète serait longue!)

Avec un peu de pratique, certaines opérations se font **beaucoup plus rapidement** dans le terminal que via l'interface utilisateur graphique (GUI)!

**Un peu d'histoire**

Le mot terminal désignait à l'origine un **"ordinateur" rudimentaire**, équipé d'un simple clavier, et relié par un réseau à un serveur central.  
Ci-dessous, un des précurseurs, le Dec VT100.

![image](https://storage.googleapis.com/quest_editor_uploads/CFXjbkRplmWbzw4DTmAFSv59rY5MTpps.jpg)

L'utilisateur se connecte au serveur et peut alors entrer des commandes à l'aide du clavier.

Bien que la souris ait été inventée en même temps que les terminaux, les ordinateurs n'en étaient pas équipés et, de plus, les écrans étaient très limités et ne pouvaient afficher que du texte, en vert sur un fond noir (penses-y, la prochaine fois que tu regarderas The Matrix!)

![image](https://storage.googleapis.com/quest_editor_uploads/e93UpyJ7G170wCaO3fdWXDjjx8bz5K9K.jpg)

```shell
Terminal sur WikipédiaHistorique et différents types de terminauxhttps://en.wikipedia.org/wiki/Computer_terminal
```

## 📂 L'arborescence des répertoires sous Linux

Sur tous les systèmes d'exploitation, les fichiers et les répertoires sont organisés en **"arborescence"**, c'est-à-dire une **structure hiérarchique**.

Le terme "arborescence" n'est pas une coïncidence, car une arborescence de fichiers ressemble à un bon vieil arbre: la **"racine"** de l'arborescence serait le **tronc**, les **répertoires**, ses **branches**, et les **fichiers**, ses **feuilles**.

Il existe certaines disparités entre les systèmes: par exemple, sous Windows, chaque lecteur physique (partition de disque dur, lecteur optique de DVD ou Blu Ray, clé USB) se voit attribuer une lettre (C: pour le disque dur de démarrage, D: pour le lecteur optique, par exemple).

Ce n'est pas le cas sous les systèmes Unix, dont Linux et OS X font partie. Sous ces systèmes, tous les disques apparaissent sous la même arborescence.

> Utilisateurs de Windows: **Git Bash** émule en fait cette arborescence unifiée. Votre disque **C:** apparaîtra sous la forme `/c` sous Git Bash.

Voyons maintenant **à quoi ressemble cette arborescence** sous Linux.

L'image ci-dessous n'en montre qu'une très petite partie car pour la montrer en entier, tu auras probablement besoin d'un écran de 450 pouces!

![image](https://storage.googleapis.com/quest_editor_uploads/tbkGL5q5ZJvwVpRDrEyF46GgNr6p4Ht4.png)

```shell
L'arborescence des répertoires sous LinuxRessource détaillant la fonction des répertoires situés à la racine de l'arbre (pas besoin de tous les connaître par coeur !)https://help.ubuntu.com/community/LinuxFilesystemTreeOverview
```

## 👀 Explorer l'arborescence avec le terminal

Nous entrons dans le vif du sujet!  
Commence par regarder cette [vidéo](https://www.youtube.com/watch?v=AO0jzD1hpXc), qui montre comment utiliser le terminal, et quelques commandes de base.

Conseil général, ne suis pas passivement la vidéo: **tape toi-même les commandes dans le terminal**!

Ce qui suit est un complément, largement redondant avec la vidéo, mais avec des exemples supplémentaires.

Suis la vidéo, **garde le terminal ouvert et n'efface rien (pas de "clear")** après avoir essayé les différentes commandes.  
Cela te servira pour le **challenge**.

**Lancer le terminal**

Le **terminal** est l'une des nombreuses applications fournies par défaut avec Linux.  
Pour clarifier: parler du terminal n'est pas correct, il serait plus exact de parler de **l'émulateur de terminal**.

Pour lancer le terminal, tu devras d'abord le trouver!  
Tu pourras le trouver en haut à gauche de l'écran sous Ubuntu.

- Clique sur "Activités",
- Tape "ter", pour trouver l'application du terminal.
- Une fois le terminal lancé, si tu souhaites ajouter une nouvelle icône, fais un clic droit sur son icône dans la barre latérale gauche, puis clique sur "Ajouter aux favoris", afin qu'elle apparaisse toujours dans la barre des favoris!

**L'invite de commande ou "prompt"**

L'émulateur de terminal affiche une fenêtre avec un fond sombre.

![image](https://storage.googleapis.com/quest_editor_uploads/1oO8cqOnmdUSST2mEbbOfCDNGLXzsZm7.png)

Dans cette fenêtre, un curseur clignotant est affiché, précédé de **l'invite de commande** ou **prompt** en anglais. L'invite de commande peut être décomposée comme suit:

- La première partie, **en vert**, `username@Computer-Name` indique **qui** nous sommes et **sur quelle machine nous travaillons**. Ici, nous travaillons localement, mais nous pourrions très bien nous connecter à distance à une autre machine Linux, auquel cas cette partie changerait.
- La deuxième partie **en bleu**, séparée de la première par une flèche, indique **où tu te trouves** dans l'arborescence... Nous reviendrons sur la signification de `~` plus tard.
- Le dernier caractère, `$`... **finissant l'invite**.

Après l'invite se trouve le curseur, et maintenant c'est à toi de jouer!  
Tu vas te faire la main sur quelques commandes. **Un conseil: essaye les au fur et à mesure**!

**Lister le contenu d'un répertoire avec `ls`**

La commande `ls` te permet d'afficher le contenu d'un répertoire.  
Quelques exemples, en supposant que tu viens de lancer le terminal:

- `ls` affiche les fichiers et répertoires contenus dans le répertoire courant, celui dans lequel tu es actuellement.
- `ls .` fait la même chose! Le symbole `.` signifie "le répertoire actuel".
- `ls -a` affiche le contenu du répertoire, mais en incluant les fichiers cachés. Ceux-ci sont précédés du caractère `.` pour les différencier des fichiers "normaux". Attention, ici, le `.` est annexé au nom du fichier, il n'a pas la même signification que le symbole `.` pris isolément.
- `ls Images` et `ls ./Images` affiche le contenu du dossier Images.
- `ls /home/wilder` est une autre façon d'afficher le contenu de ton répertoire personnel, qui se trouve être le répertoire par défaut au lancement du terminal.
- `ls /home` te permet d'afficher la liste des répertoires associés à chaque utilisateur du système.
- `ls ..` te donnera le même résultat! Le `..` signifie le *répertoire parent*. Celui qui se trouve juste au-dessus dans l'arborescence. `/home` est au-dessus de `/home/wilder`.
- `ls /bin` affiche le contenu d'un répertoire contenant les commandes de base du système (par exemple, la commande `ls` elle-même!).
- `ls -l /bin` fait la même chose, mais donne plus de détails, comme par exemple qui possède les fichiers, quand ils ont été modifiés pour la dernière fois, et ainsi de suite.

Je voudrais profiter de cette occasion pour introduire ici la notion de *paramètres* ou d' *arguments* d'une commande: c'est simplement tout ce qui vient après la commande elle-même.

- Pour prendre le dernier exemple, `-l` et `/bin` sont les arguments donnés à `ls`.
- Les arguments commençant par `-` ou `--` comme `-a`, `-l` ou `--help` sont appelés flags; ils modifient le comportement de la commande.

Autre chose, qui peut sembler "évidente": le caractère slash (`/`) permet d' **enchaîner les noms des répertoires et de leurs sous-répertoires**.  
C'est le **séparateur de répertoires**.

**Afficher le répertoire courant avec `pwd`**

La commande `pwd` te permet d' **afficher le répertoire courant**, également appelé "répertoire de travail". D'où le nom de la commande, abréviation de **print working directory**.

Lorsque tu viens de lancer le terminal, `pwd` devrait t'afficher `/home/wilder`.

**Changer de répertoire avec `cd`**

L'ordre `cd` signifie **changer de répertoire** et te permet donc de changer ton répertoire de travail.

Quelques exemples, à essayer dans l'ordre:

- `cd Images`: se déplacer sous le dossier Images (vérifier avec `pwd`).
- `cd ..`: remonter dans le répertoire parent/home/wilder.
- `cd /opt`: aller sous un répertoire en précisant son *chemin absolu*. L'emplacement de l'arborescence, c'est-à-dire sa position par rapport à la racine de l'arborescence.
- `cd ../home/wilder`: d'abord, retourne à la racine (via `..`) et de là, retourne au fichier `/home/wilder`.
- `cd /usr/bin`: aller dans un autre répertoire, celui-ci étant un autre répertoire contenant des commandes (vérifier avec `ls`).
- `cd` sans paramètres: retour au répertoire personnel de l'utilisateur courant.
- `cd ~` Même chose.
- `cd ~/Music`: va sous ton dossier Music (quel que soit le dossier dans lequel tu étais avant).

**Signification de `~`**

Le caractère `~` (appelé *tilde*) représente le **répertoire personnel de l'utilisateur actuel**.  
C'est un moyen rapide d'accéder à l'adresse `/home/username` (remplacer le `username` par celui de l'utilisateur actuel).

C'est très pratique, surtout si tu es dans un répertoire complètement différent et que tu veux consulter un élément de ton dossier personnel.  
Par exemple, où que nous soyons, `ls ~/Downloads` te permet de lister le contenu de ton dossier *Downloads*.

📚 Ressources

```shell
Linux - Commandes de baseCette ressource couvre beaucoup plus de commandements que cette quête, mais peut servir de référence pour celle-ci et les suivantes.https://files.fosswire.com/2007/08/fwunixref.pdf
```

---

## 💪 Challenge

Tu as gardé ton terminal ouvert comme demandé, n'est-ce pas?

1. Dans le menu *Édition* en haut de la fenêtre du terminal, clique sur "Tout sélectionner".
2. Dans le même menu, clique sur "Copier".
3. Colle le tout pour poster ta solution.

## 🧐 Critères d'acceptation

- Avoir utilisé les commandes `ls`, `pwd` et `cd`. Les exemples suivants sont donnés dans l'étape "Explorer l'arborescence avec le terminal".

Solution postée le **lundi 20 octobre 2025**

```shell
1
chica@MatthiasC MINGW64 /
2
$ ls images
3
ls: cannot access 'images': No such file or directory
4

5
chica@MatthiasC MINGW64 /
6
$ pwd
7
/
8

9
chica@MatthiasC MINGW64 /
10
$ pwd
11
/
12

13
chica@MatthiasC MINGW64 /
14
$ cd
15

16
chica@MatthiasC MINGW64 ~
17
$ pwd
18
/c/Users/chica
19

20
chica@MatthiasC MINGW64 ~
21
$ cd ..
22

23
chica@MatthiasC MINGW64 /c/Users
24
$ pwd
25
/c/Users
26

27
chica@MatthiasC MINGW64 /c/Users
28
$ ls
29
'All Users'@   Default/  'Default User'@   Public/   chica/   desktop.ini
30

31
chica@MatthiasC MINGW64 /c/Users
32
$ ls -a
33
 ./   'All Users'@  'Default User'@   chica/
34
 ../   Default/      Public/          desktop.ini
35

36
chica@MatthiasC MINGW64 /c/Users
37
$ cd /c/users/Chica
38

39
chica@MatthiasC MINGW64 /c/users/Chica
40
$ pwd
41
/c/users/Chica
42

43
chica@MatthiasC MINGW64 /c/users/Chica
44
$ cd /d
45

46
chica@MatthiasC MINGW64 /d
47
$ pwd
48
/d
49

50
chica@MatthiasC MINGW64 /d
51
$ cd/e
52
bash: cd/e: No such file or directory
53

54
chica@MatthiasC MINGW64 /d
55
$ cd /e
56

57
chica@MatthiasC MINGW64 /e
58
$ pwd
59
/e
60

61
chica@MatthiasC MINGW64 /e
62
$ ls
63
'$RECYCLE.BIN'/   Docs/  'System Volume Information'/   VM/
64
 Backups/         ISO/    Utilitaires/
65

66
chica@MatthiasC MINGW64 /e
67
$ cd ../e/ISO
68

69
chica@MatthiasC MINGW64 /e/ISO
70
$ pwd
71
/e/ISO
72

73
chica@MatthiasC MINGW64 /e/ISO
74
$ ls
75
SERVER_EVAL_x64FRE_en-us-001.iso  debian-13.1.0-amd64-DVD-1-003.iso
76
Win10_22H2_French_x64v1-004.iso   ubuntu-24.04.3-desktop-amd64-002.iso
77
Win11_24H2_French_x64-005.iso
78

79
chica@MatthiasC MINGW64 /e/ISO
80
$
```