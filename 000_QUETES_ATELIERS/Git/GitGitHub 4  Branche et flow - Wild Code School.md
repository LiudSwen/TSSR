---
title: "Git/GitHub 4 : Branche et flow - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1313/pages/11582"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Git

## Git/GitHub 4: Branche et flow

Découvrez comment travailler avec Git et Github.

3 pairs

Git

## Git/GitHub 4: Branche et flow

## Introduction

Maintenant que tu connais les bases de GitHub et Git, assemble les pièces du puzzle en découvrant le flow pour les utiliser de manière optimale!

![image](https://storage.googleapis.com/quest_editor_uploads/TKruZpmIMxO7LOiG7RTcYcx4tvDDMTWq.jpeg)

## 🤓 À la fin de cette quête, tu pourras:

- ✅ **Créer une branche et la fusionner** avec la branche *main* via l'interface graphique GitHub
- ✅ Créer une branche via **Git CLI**
- ✅ Suivre le flow **GitHub** en utilisant Git

---

## Pourquoi suivre un flow?

Un **flow** (parfois aussi appelé *workflow*) est une **série d'étapes** que les membres de l'équipe doivent suivre pour **compléter une tâche.**  
Dans notre cas, la **tâche consiste à apporter des modifications** **au code** d'un projet web.

S'entendre sur les étapes à suivre permet à plusieurs personnes de **s'organiser**. En effet, une telle approche:

• **Minimise** le risque de **conflits** (une notion que tu as déjà vue), car elle empêche plusieurs développeurs de travailler sur le même code en même temps (cela se fait grâce à l'utilisation de *branches* que nous découvrirons plus tard);

• Facilite le **contrôle** du code produit par chaque développeur, ce qui assure la **qualité du projet** (ceci est fait par l'utilisation de *pull requests* que nous verrons plus tard également).

Dans cette quête, nous découvrirons progressivement le **flow GitHub** qui te servira dans tes futurs projets.

Pour ce faire, tu découvriras d'abord le **flow à suivre sur GitHub**, uniquement via son **interface graphique**.

Ensuite, tu verras comment effectuer certaines des mêmes opérations (création de branches) via Git, sur des **lignes de commande sur ta machine**.

Enfin, tu suivras à nouveau le flow de GitHub, mais cette fois en utilisant **ce que tu as appris sur Git**.

## flow GitHub: introduction

GitHub fonctionne grâce à un système de **branches**.  
Pour avoir une première idée de ce dont il s'agit, lis l'introduction et la partie "Branching Out" de la ressource suivante. Elle date de 2018, et parle de la branche `master`, mais le principe général reste le même.

```shell
Travailler avec les branches de Git et GitHubhttps://thenewstack.io/dont-mess-with-the-master-working-with-branches-in-git-and-github/
```

  
Découvre ensuite comment les branches sont utilisées dans le flow GitHub en suivant [ce tutoriel](https://guides.github.com/activities/hello-world/).  

```shell
Des guides : Bonjour le mondehttps://guides.github.com/activities/hello-world/
```

  
Félicitations, tu viens de suivre le flow de GitHub pour la première fois!  
  
Lorsque tu as terminé, dans le repo GitHub que tu as créé en suivant le tutoriel, clique sur le bouton `Insights` puis sur `Network` pour accéder à un **historique visuel de ton projet.**  
  
Comme sur l'exemple ci-dessous, tu pourras voir la branche que tu as créée à partir de ta branche `main`, le commit que tu as fait sur cette branche et ensuite la fusion avec la branche `main`.  
  
Le `network graph` est un moyen simple de **visualiser les branches** créée dans ton repo GitHub - il devrait t'être utile pendant ta vie de développeur!  

## Git: la création de branches locales

  
Tu viens d'apprendre à utiliser l'interface graphique de GitHub.  
  
Cette nouvelle branche te permet de **modifier un fichier** directement dans ton navigateur, **puis de le fusionner** avec ton code de base pour le partager avec le reste de ton équipe.  
  
Mais comme tu le sais déjà, **modifier du code en utilisant uniquement l'interface GitHub**, c'est-à-dire faire tout dans ton navigateur, **n'est pas très pratique**: il est plus pratique de **travailler localement** (= **sur ton ordinateur**), dans un éditeur de texte, pour enregistrer tes modifications en utilisant Git (rappelle-toi tes amis `git add` et `git commit`), et seulement ensuite de **les pousser vers ton repo GitHub.**  
  
Cela tombe bien: il est justement possible de **créer une branche locale** pour effectuer des commits sur celle-ci, puis de pousser cette branche vers un repo GitHub (l'interface graphique de GitHub prend alors le relais selon le flow que tu connais déjà à l'étape de *pull request*).  
  
Mais tout d'abord, apprends à **créer une branche via Git** en regardant [cette vidéo](https://www.youtube.com/watch?v=sgzkY5vFKQQ) (de 0 à 5 minutes 30).  

Consolide tes connaissances en visualisant l'ouverture d'une nouvelle branche [ici](https://onlywei.github.io/explain-git-with-d3/#branch).  
Dans le simulateur de terminal (la petite fenêtre noire à gauche de l'écran), tape les commandes suivantes et observe ce qui se passe.

```shell
git branch new-branch
git checkout new-branch
git commit
git commit
git checkout main
git commit
git commit
git checkout new-branch
git commit
```

  
N'hésite pas à **jouer avec les lignes de commande** pour voir le résultat produit sous forme d'image.  
  
*Comme tu le sais déjà, pour pousser les modifications que tu as effectuées sur ton ordinateur vers la branche `main` de ton dépôt GitHub, tu dois utiliser la commande `git push origin main`. Quelle commande penses-tu sera utilisée pour effectuer la même action, mais sur une autre branche (nommée, par exemple, `new-branch`)?*  
  
*La commande à utiliser sera `git push origin new-branch` ce qui signifie que nous remplaçons `main` par le nom de la branche que tu veux pousser sur le distant (= sur GitHub). Tu as toujours voulu savoir à quoi référait `origin`? Clique [ici](https://stackoverflow.com/a/9529518) pour une lecture de 30 secondes.*  

## GitHub et Git: le flow final

  
Maintenant que tu sais comment créer une branche localement sur ta machine, il est temps de suivre le flow GitHub que tu as déjà vu, mais cette fois en mélangeant Git et GitHub.  
  
Pour ce faire, consulte [cette vidéo](https://www.youtube.com/watch?v=MnUd31TvBoU).  

## ☝️ Résumé

- Suivre un flow minimise les risques de conflits.
- GitHub fonctionne via un système de **branches**.
- Les branches te permettent de travailler sur une version séparée que tu modifiras
- Nous pouvons créer des branches via l'interface graphique ou via la CLI.

---

## 💪 Challenge

Pratiquons ça!

1. Crée un nouveau dépôt nommé `website-flow` sur GitHub en cochant «Initialize this repository with a README».
2. Clone le dépôt sur ta machine.
3. Localement (= via Git), crée une nouvelle branche appelée `cheese` et place-toi dessus.
4. Dans ton éditeur de texte préféré, modifie le fichier readme (par exemple, en écrivant une liste de tes fromages à pizza préférés).
5. En t'assurant que tu es bien sur la branche `cheese`, valide tes modifications et transféres-les dans ton dépôt GitHub.
6. Sur GitHub, fusionne la branche `cheese` avec la branche `main` via une pull request, puis supprime la branche `cheese`.
7. En solution de ce challenge, partage le lien de ton repo GitHub avec `/commits` à la fin

> Ce lien te mènera à l'historique de tous les crimes commis sur ton repo.

## 🧐 Critères de validation:

- Le lien fourni est un lien vers un dépôt GitHub.
- Dans l'historique des commits, le commit le plus récent est similaire à la demande de fusion pull #1 de user/cheese où l'utilisation est le nom d'utilisateur de l'étudiant qui a posté sa solution (= la branche cheese a bien été fusionnée dans `main`).
- Dans l'onglet branche, seule la branche `main` est présente (= la branche cheese a été supprimée).

Solution postée le **mardi 04 novembre 2025**

[https://github.com/LiudSwen/website-flow/commits/](https://github.com/LiudSwen/website-flow/commits/)