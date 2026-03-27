---
title: "Git/GitHub 5 : Merge & Conflits - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1312/pages/7727"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Git

## Git/GitHub 5: Merge & Conflits

Découvre comment merger et gérer des conflits

3 pairs

Git

## Git/GitHub 5: Merge & Conflits

## Introduction

Si tu n'as jamais entendu parler de conflits dans **git**, ne t'inquiète pas, tu auras à les gérer assez souvent en travaillant sur certains projets d'équipe.

Les conflits sont généralement inévitables lorsque tu travailles en équipe.

Dans cette quête, nous allons aborder ce que sont les conflits et comment nous pouvons les gérer.

![Fusion - illustration](https://storage.googleapis.com/quest_editor_uploads/9wG0fW5xmUvPxl83tOBoawbNUTDoym4B.jpeg)

## 🤓 À la fin de cette quête, tu seras en mesure de:

- ✅ Résoudre les conflits liés à la fusion
- ✅ Comprendre comment réaliser une fusion

---

## ⏬ Git pull, une commande qui te veut du bien

**Définition**

Lorsque plusieurs personnes collaborent à un même projet, elles **modifient constamment les fichiers**.

Imagine que tu travailles sur un fichier texte; pendant ce temps, un de tes collègues modifie des lignes sur le même fichier.

Dans un monde sans Git, pour harmoniser votre travail, tu dois récupérer une copie de ses fichiers et comparer les différences avec ta version, puis copier les lignes de code correspondantes de la nouvelle présentation du texte et les coller dans ton fichier.

C'est une opération longue et risquée, car tu ne seras peut-être pas en mesure de repérer tous les changements effectués par ton collègue. Et dans un cas réel, tu peux être amené à modifier beaucoup de lignes sur un grand nombre de fichiers, et qu'il y ait non pas un, mais plusieurs autres collègues travaillant simultanément dessus. Cela devient un casse tête très rapidement.

Heureusement, **Git peut faire ce travail pour toi!**  
C'est ce qu'on appelle une **fusion** (merging). Elle est réalisée par la commande "git pull" (il y a d'autres façons de le faire, mais c'est suffisant pour l'instant), qui te permet de **mettre à jour tes fichiers locaux avec les fichiers distants** (par exemple, sur le repo GitHub).

Dans la plupart des cas, cette *fusion* est **automatique**: Git localise de lui-même les différences entre tes fichiers locaux et leurs homologues distants et les intègre dans tes fichiers locaux.

Pour voir les effets d'un "git pull", utilise [cet outil](https://onlywei.github.io/explain-git-with-d3/#pull) (ne fais pas attention au texte explicatif, il dépasse la portée de cette quête).

## Conflits de fusion

Observe un exemple de conflit et sa résolution dans cette vidéo.

---

## 💪 Challenge

1. Crée un nouveau dépôt sur GitHub, en cochant "Initialize this repository with a README".
2. Toujours dans GitHub, écris quelques lignes de texte dans le fichier README.md.
3. Clone le repo.
4. Sur GitHub, écris "REMOTE" sur la première ligne du README.md et fais un commit pour ce changement.
5. Localement (sur ton ordinateur), dans ton éditeur de code préféré, modifie également la première ligne du README.md (écris "LOCAL") et commit la modification.
6. Dans ton Terminal, fais un "git pull" et Un joli petit conflit apparaîtra!
7. Réouvre ton éditeur, résous le conflit dans le README.md (choisis de garder "LOCAL") et fais un commit pour ce changement.
8. Fais une nouvelle tentative, Git te dira que tu es déjà à jour. Le conflit est réglé!
9. Envoie tes modifications au repo distant en faisant un git push origin main.
10. Dans GitHub, ouvre le README.md et assure-toi que "LOCAL" est maintenant sur la première ligne. Bien joué!
11. Copie le contenu de ton terminal du premier git pull (étape 6 de ces instructions) jusqu'à la fin et colle-le en solution.

## 🧐 Critères de validation

- Le contenu du Terminal est bien posté en solution.
- La première utilisation de git pull provoque un conflit.
- La deuxième utilisation de git pull indique "déjà à jour" (le conflit a été résolu).

Solution postée le **mardi 04 novembre 2025**

```
1
PS C:\Users\chica\wild-git\Merge-Conflit> git pull
2
Enter passphrase for key '/c/Users/chica/.ssh/id_rsa':
3
remote: Enumerating objects: 5, done.
4
remote: Counting objects: 100% (5/5), done.
5
remote: Compressing objects: 100% (2/2), done.
6
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
7
Unpacking objects: 100% (3/3), 977 bytes | 139.00 KiB/s, done.
8
From github.com:LiudSwen/Merge-Conflit
9
   a955e73..1cdbf52  main       -> origin/main
10
Auto-merging README.md
11
CONFLICT (content): Merge conflict in README.md
12
Automatic merge failed; fix conflicts and then commit the result.
13

14
PS C:\Users\chica\wild-git\Merge-Conflit> git commit -m "Conflit ok"
15
U       README.md
16
error: Committing is not possible because you have unmerged files.
17
hint: Fix them up in the work tree, and then use 'git add/rm <file>'
18
hint: as appropriate to mark resolution and make a commit.
19
fatal: Exiting because of an unresolved conflict.
20

21
PS C:\Users\chica\wild-git\Merge-Conflit> git status
22
On branch main
23
Your branch and 'origin/main' have diverged,
24
and have 1 and 1 different commits each, respectively.
25
  (use "git pull" if you want to integrate the remote branch with yours)
26

27
You have unmerged paths.
28
  (fix conflicts and run "git commit")
29
  (use "git merge --abort" to abort the merge)
30

31
Unmerged paths:
32
  (use "git add <file>..." to mark resolution)
33
        both modified:   README.md
34

35
no changes added to commit (use "git add" and/or "git commit -a")
36

37
PS C:\Users\chica\wild-git\Merge-Conflit> git add .
38

39
PS C:\Users\chica\wild-git\Merge-Conflit> git status
40
On branch main
41
Your branch and 'origin/main' have diverged,
42
and have 1 and 1 different commits each, respectively.
43
  (use "git pull" if you want to integrate the remote branch with yours)
44

45
All conflicts fixed but you are still merging.
46
  (use "git commit" to conclude merge)
47

48
Changes to be committed:
49
        modified:   README.md
50

51
PS C:\Users\chica\wild-git\Merge-Conflit> git commit -m "Conflit ok"
52
[main c3f4fc6] Conflit ok
53

54
PS C:\Users\chica\wild-git\Merge-Conflit> git pull
55
Enter passphrase for key '/c/Users/chica/.ssh/id_rsa':
56
Already up to date.
57

58
PS C:\Users\chica\wild-git\Merge-Conflit> git push
59
Enter passphrase for key '/c/Users/chica/.ssh/id_rsa':
60
Enumerating objects: 10, done.
61
Counting objects: 100% (10/10), done.
62
Delta compression using up to 12 threads
63
Compressing objects: 100% (4/4), done.
64
Writing objects: 100% (6/6), 660 bytes | 660.00 KiB/s, done.
65
Total 6 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
66
To github.com:LiudSwen/Merge-Conflit.git
67
   1cdbf52..c3f4fc6  main -> main
```