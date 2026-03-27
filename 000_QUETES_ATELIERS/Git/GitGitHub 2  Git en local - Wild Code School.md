---
title: "Git/GitHub 2 : Git en local - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1309/pages/16963"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Git

## Git/GitHub 2: Git en local

Découvre comment utiliser git en local

3 pairs

Git

## Git/GitHub 2: Git en local

## Introduction

Maintenant que tu connais les bases de ce qu'est git et comment créer un dépôt GitHub, il est temps d'apprendre **comment nous pouvons utiliser git sur notre machine locale.**

![Github](https://storage.googleapis.com/quest_editor_uploads/J4b0TTz5pv2LhAmrkhqSfFjNjQhO0fGB.jpeg)

## 🤓 À la fin de cette quête, tu seras en mesure de:

- ✅ comprendre la **structure d'un dépôt Git local** (*répertoire de travail*, *répertoire intermédiaire*, *dépôt*)
- ✅ Initialiser un **dépôt Git local** sur ton ordinateur
- ✅ Sauvegarder **les modifications de fichiers** dans un dépôt Git local

---

## Anatomie d'un dépôt local Git

**Théorie**

Contrairement à GitHub, qui est un site Web, Git est un logiciel que tu installes sur ton ordinateur.

*Puisque tout se passe sur ton ordinateur, nous parlons de Git local.*

Voici la structure typique d'un dépôt sur ta machine locale selon Git:

![image](https://storage.googleapis.com/quest_editor_uploads/tou4VXpfWeSd2cI4PX2qamKBGMafzrVL.png)  
*Les flèches `add`, `commit` et `checkout` correspondent aux commandes Git que tu verras plus tard, ne t'en préoccupe pas trop pour le moment!*

Cette vidéo t'expliquera plus en détail la structure:

**Entraine toi**

Tu as peut-être déjà remarqué que le flux de travail Git (créer / modifier un fichier, valider pour enregistrer la modification) ressemble beaucoup à ce que tu as fait sur GitHub dans la quête précédente.

Sauf que GitHub propose une interface utilisateur graphique (*GUI* en abrégé), tandis que Git s'exécute en ligne de commande (*CLI* en abréviation anglaise), c'est-à-dire dans ton terminal.

Tu vas donc répéter ce que tu as déjà fait sur GitHub, mais cette fois sur ta machine locale!  
Avant tout, tu vas installer git sur ton système.

```shell
LinuxMacWindowsSur Linux, git pourrait déjà être installé. Vérifie en entrant cette commande dans ton terminal => git --version (Le résultat doit être git version 2.**.*)
Sinon, tu vas devoir l'installer par toi même.

Clique sur ce lien (https://git-scm.com/download/linux)
Dans ton terminal, vérifie ton installation en tapant git --version
Puis dans ton terminal, tu vas renseigner ton nom d'utilisateur et ton email (les mêmes que sur la plateforme github)

Renseigne ton nom d'utilisateur: git config --global user.name "FIRST_NAME LAST_NAME"
Renseigne ton email : git config --global user.email "MY_NAME@example.com"
Ajoute aussi cette configuration (c'est un peu tôt pour t'expliquer en détail mais si tu ne le fais pas git va te poser la question quand tu essaieras de récupérer du code distant) git config --global pull.rebase false
Enfin, termine par cette dernière configuration, qui configure git pour utiliser le nom "main" et non plus "master" comme branche par défaut, ce qui te facilitera la vie quand tu vas utiliser Github (qui lui utilise le nom "main") git config --global init.defaultBranch main
```

## ☝️Résumé

- Git est un système de contrôle de version
- Git t'aide à conserver l'historique de tes fichiers et à travailler en équipe
- Github est une plateforme en ligne qui propose des services tels que **l'hébergement de code** mais c'est aussi un réseau social où tu peux participer à des projets open source, partager et découvrir de nouveaux projets.

---

Pour réaliser le challenge retiens bien ce qui suit:

- Quelle commande te permet de transformer un dossier classique en un projet git local? `git init`
- Quelle est la commande pour placer un fichier dans le répertoire intermédiaire (staging)? `git add`
- Quelle commande utilises tu pour réaliser un commit? `git commit`

## 💪 Challenge

1. Crée un nouveau répertoire nommé `wild-git` et déplace-toi dedans depuis ton terminal
2. Quand tu t'es assuré d'être dans le bon dossier, initialise un nouveau dépôt git pour transformer ton dossier en un projet git local
3. Crée un fichier vide nommé "wild.txt"
4. Ajoute ce fichier à l'index de git (aussi appelé *staging*)
5. Commite ce fichier avec le message suivant "At Wild Code School, we code without shoes."
6. Écrit la commande suivante `git log -p` et colle le résultat en solution du challenge

## 🧐 Critères de validation:

- La solution contient le message suivant: "At Wild Code School, we code without shoes."

Solution postée le **jeudi 23 octobre 2025**

chica@MatthiasC MINGW64 ~/wild-git (main)  
$ git log -p  
commit 9ed37b8a4951a9a372d93071a0d9dc4b33972887 (HEAD -> main)  
Author: MATTHIAS CHICAUD [chicaud.matthias@gmail.com](mailto:chicaud.matthias@gmail.com)  
Date: Thu Oct 23 13:34:11 2025 +0200

```shell
At Wild Code School, we code sithout shoes.
```

diff --git a/wild.txt b/wild.txt  
new file mode 100644  
index 0000000..e69de29