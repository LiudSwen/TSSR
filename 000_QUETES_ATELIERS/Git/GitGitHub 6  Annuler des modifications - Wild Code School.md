---
title: "Git/GitHub 6 : Annuler des modifications - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1311/pages/8744"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Git

## Git/GitHub 6: Annuler des modifications

Découvre comment revenir sur tes erreurs avec git

3 pairs

Git

## Git/GitHub 6: Annuler des modifications

## Introduction

Parfois, il peut arriver que pour une raison quelconque, tu fasses une erreur en utilisant Git, c'est tout à fait normal, se tromper fait partie du comportement humain.

La bonne nouvelle est qu'avec git, tu peux toujours trouver un moyen de corriger certaines de tes erreurs, et c'est aussi l'un des meilleurs atouts de Git.

![Revert](https://storage.googleapis.com/quest_editor_uploads/mNJoOUcatgJZNHWh37B06kUe1gRpmNMQ.jpeg)

## 🤓 À la fin de cette quête, tu seras en mesure de:

- ✅ **Revert** tes erreurs

---

## 🙊 Oh mon Git

**Philosophie**

Au début, travailler avec git peut sembler un peu difficile, mais **ne t'inquiète pas**, **plus tu l'utiliseras, plus tu le maîtriseras.**

De plus, profites d'être étudiant pour **faire des erreurs.** C'est **l'une des meilleures façons d'apprendre**!

Mais, la bonne nouvelle est que Git a tout un tas de **fonctionnalités rassurantes** qui te permettent de **revenir en arrière et de corriger tes erreurs**.

Cette vidéo t'expliquera **comment annuler avec git!**

## 🕰️ Git checkout: la machine à remonter le temps

L'un des intérêts majeurs de Git est qu'il te permet de garder une **trace** des différentes versions de ton projet. Et même plus qu'une trace: tu peux à tout moment **revenir à une version précédente**.

Cela peut être utile si tu travailles pendant un certain temps et que ton client arrive et te dit qu'il préférait la version que tu lui avais montrée deux semaines auparavant.

## ↩️ Git revert: un commit en poursuit un autre

Que faire si tu ne souhaites pas revenir complètement à une version antérieure de ton projet, mais simplement «annuler» l'un de tes commits?

Là encore, Git a une solution: la commande `git revert` qui permet de créer un commit "anti-commit" et est expliquée dans la [vidéo](https://www.youtube.com/watch?v=RIYrfkZjWmA) (cette fois de la minute 4:57 à 7:00).

Dans la ressource précédente, `git revert` est utilisé avec l'empreinte (hash) correspondant au commit à annuler.  
Tu peux également utiliser `git revert HEAD` qui te permet d'annuler un commit que tu viens de faire, comme indiqué [ici](https://githowto.com/undoing_committed_changes).

Entraîne-toi à utiliser `git revert <hash>` et `git revert HEAD` [ici](https://onlywei.github.io/explain-git-with-d3/#revert).

**Que penses-tu que HEAD représente?**

## ⏮️ Git commit --amend: La solution aux oops de dernière minute

**Malheur de l'attachement**

Tu as probablement déjà vécu ce moment gênant lorsque, après avoir cliqué sur le bouton «Envoyer», tu te rends compte que tu as oublié la pièce jointe promise dans ton e-mail.

Tu peux rencontrer un revers similaire dans Git: par exemple, valider et réaliser une seconde plus tard que tu as oublié d'ajouter un fichier critique.

Pour rattraper ton retard, applique la technique décrite [ici](https://githowto.com/amending_commits).

```shell
Git comment modifier les commitshttps://githowto.com/amending_commits
```

## ⚠️ Git reset: ATTENTION

La documentation officielle le dit: "À tout moment, tu peux annuler quelque chose. Sois prudent, car tu ne pourras pas toujours annuler certaines de ces annulations".

La commande `git reset <hash>` te permets de définir un commit et d'effacer tout l'historique des modifications effectuées après le commit.  
Lorsqu'il est utilisé de cette manière, il efface uniquement l'historique, tandis que les fichiers sur ton ordinateur restent intacts. Pratique...

**Mais méfie-toi de `git reset <hash> --hard`!** Cela provoque la suppression des fichiers sur ton ordinateur.

**Un aide-mémoire pour la route**

Faire des erreurs avec Git arrive à tout le monde, à tel point que ce site a été créé: [https://ohshitgit.com](https://ohshitgit.com/). Les erreurs de manipulation les plus courantes sont enregistrées ici, ainsi que les solutions. Ajoute-le à tes favoris, car tu en auras probablement besoin un jour!

```shell
Oh shit, Git!?!Un aide mémoire pour de nombreux problèmes githttps://ohshitgit.com/
```

## ☝️Résumé

- **Git** peut être difficile à gérer au début mais **ne t'inquiéte pas** avec git **tu peux toujours remonter le temps**
- Tu peux consulter le site Web [Oh shit git?!](https://ohshitgit.com/) pour trouver comment annuler une erreur

---

## 💪 Challenge

Faisons quelques erreurs!

1. Crée un dépôt Git local nommé "oops".
2. Dans ce dossier, crée un fichier `wilders.txt`
3. Fais un commit pour ajouter ton nom;
4. Fais un second commit pour ajouter le nom de ton formateur
5. Fais un troisième commit pour ajouter la localisation de ton campus
6. Affiche l'historique des commits en utilisant la commande `git log --oneline`.
7. Annule les modifications du troisième commit en utilisant la commande git de ton choix. *Attention: cela ne doit pas être destructeur pour les fichiers de ton ordinateur.*
8. Affiche à nouveau l'historique de validation en utilisant la commande `git log --oneline` un nouvel élément doit signaler l'annulation des modifications liées au troisième commit.
9. Copie le contenu de ton terminal depuis le premier `git log --oneline` (étape 6 de ces instructions) jusqu'à la fin et colle-le pour poster ta solution.

## 🧐 Critères de validation:

- Lorsque l'on compare les deux réponses Git relatives à git log --oneline, on constate que les modifications relatives au troisième commit ont été annulées.
- L'annulation des modifications du troisième commit est non destructive pour les fichiers sur l'ordinateur (voir la dernière étape de cette quête).

Solution postée le **samedi 08 novembre 2025**

```bash
1
// bash
2

3
# ==============================
4
# Premier git log --oneline 
5
# ==============================
6
PS C:\Users\chica\wild-git\oops> git log --oneline
7
3cfb696 (HEAD -> main) Ajout de la localisation de mon campus
8
b5f7f7e Ajout de mon formateur
9
696fdf5 Ajout de mon nom
10
6c49009 Création du wilders.txt - Version 1
11

12
# ==============================
13
# Annulation du dernier git commit
14
# ==============================
15
PS C:\Users\chica\wild-git\oops> git revert --no-edit HEAD
16
[main b90c795] Revert "Ajout de la localisation de mon campus"
17
 Date: Sat Nov 8 09:16:40 2025 +0100
18
 1 file changed, 0 insertions(+), 0 deletions(-)
19

20
# ==============================
21
# Second git log --oneline 
22
# ==============================
23
PS C:\Users\chica\wild-git\oops> git log --oneline
24
b90c795 (HEAD -> main) Revert "Ajout de la localisation de mon campus"
25
3cfb696 Ajout de la localisation de mon campus
26
b5f7f7e Ajout de mon formateur
27
696fdf5 Ajout de mon nom
28
6c49009 Création du wilders.txt - Version 1
```