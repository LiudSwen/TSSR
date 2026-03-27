---
title: "Atelier - Git-Github - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3956/pages/18536"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Git

## Atelier - Git-Github

Facile

1h

Auto-validation

Git

## Atelier - Git-Github

En équipe de 2, suivez les instructions, chaque personne choisissant son rôle!  
Colonne de gauche: Tic.  
Colonne de droite: Tac.  
Dans cet atelier, vous apprendrez comment collaborer à l’aide de Git et GitHub, comment gérer les conflits de fichiers et comment versionner votre code.

## Étape 1

|  | Tic | Tac |
| --- | --- | --- |
| Tâche 1 | Crée un nouveau répertoire vide nommé **wild-project** sur votre poste de travail | Regarde ce que fait Tic et sois attentif. |
| Tâche 2 | Crée un nouveau repository public vide sur GitHub appelé **wild-project** sur votre profil (Pas de génération de README.md!!) | Regarde ce que fait Tic et sois attentif. |
| Tâche 3 | Dans le nouveau dossier **wild-project** situé localement sur ton ordinateur, suis les commandes répertoriées sur GitHub dans **…or create a new repository on the command line**. Assure-toi d’avoir coché l’option SSH, pas HTTPS. | Explique à Tic ce qu’il fait à chaque étape. |

On parle de ces commandes:

![copie écran github pour la création d'un dépôt](https://storage.googleapis.com/assets_upload_prod/PbBXBAc1stJ7hCJWfnjMnFkYwfEd4tSS.png)

|  | Tic | Tac |
| --- | --- | --- |
| Tâche 4 | Donne le lien vers le repo à Tac et comprenez ensemble comment le cloner sur son ordinateur. | Clone le repo nouvellement créé de Tic en renommant le répertoire cible local “wild-tac” avec la commande "git clone url\_of\_the\_new\_repository wild-tac" |

## Étape 2

Tout le monde ouvre le répertoire du projet dans l'éditeur de code (par exemple).

Puis pendant que Tac regarde, Tic Modifie le fichier **README.md** en tapant:

```bash
1
# wild-project
2
Comment installer ce projet ?
3
Tout ce que nous avons à faire pour l'instant, c'est de le cloner.
```

Ensuite:

|  | Tic | Tac |
| --- | --- | --- |
| Tâche 5 | Crée le fichier **another\_file.html** dans le répertoire du projet. Ajoute un commentaire à l’intérieur du fichier: **<!-- tapez votre commentaire ici -->** | Crée le fichier **not\_same\_file.html** dans le dossier du projet. Ouvre le fichier et ajoute également un commentaire à l’intérieur, peu importe qu’il soit identique ou différent. |
| Tâche 6 | Regarde ce que fait Tac, essaye de comprendre ce qui se passe à chaque étape et quel est le résultat. | Crée le fichier **secret\_file.html** contenant: **Ne doit pas être partagé sur GitHub car c'est le mot de passe que j'utilise pour gmail, Facebook, mon ordinateur portable, et si je le pouvais, je l'utiliserais pour le code PIN de mon téléphone** Exécute la commande "git status". Ignore le fichier **secret\_file.html** en créant un fichier **.gitignore** ([clique ici](https://git-scm.com/docs/gitignore) pour plus d’informations) et en ajoutant les instructions nécessaires. |
| Tâche 7 | Exécute la commande "git status" | Exécute "git status" et le fichier **.gitignore** devrait apparaître. |

## Étape 3

Tout le monde fait les manipulations suivantes:

```shell
git add .
git status
git commit -m "Change me"
```

Remplacez **Change me** par un message explicite expliquant ce que vous avez fait. Il n’y a pas de limites, et vous pouvez appuyer sur Entrée tant que vous n’avez pas fermé les guillemets.

Ensuite:

|  | Tic | Tac |
| --- | --- | --- |
| Tâche 8 | Commence par pousser: "git push" | Pareil pour toi, mais après après Tic: "git push" |
| Tâche 9 | Tout s’est bien passé pour toi. | Tu as un message d’erreur: que dit le message? |
| Tâche 10 | Puisque tu es propriétaire du dépôt, tu dois autoriser Tac à travailler dessus… Accède à “Settings” > “Collaborators and team” et ajoute Tac en tant que collaborateur. | Tu dois accepter l’invitation que tu as dû recevoir dans ta boîte mail. Essaye ensuite à nouveau de transférer ton commit vers le repo en ligne avec "git push" |
| Tâche 11 | En tant que “Ranger du risque”, aide Tac. | Tu as un autre message d’erreur! Que dit le message? Trouve la solution sans chercher sur Internet, simplement en lisant le message dans la console. Si tu es vraiment bloqué, appelle ton formateur ou ta formatrice pour obtenir de l’aide! Une fois le problème résolu, tu peux enfin pousser avec "git push" |

## Étape 4

Tout le monde vérifie la mise à jour sur GitHub.  
Le fichier `secret_file.html` est-il là?

Ensuite:

|  | Tic | Tac |
| --- | --- | --- |
| Tâche 12 | Fais un **git pull** pour obtenir les dernières modifications apportées par Tac. Crée ensuite une nouvelle branche à partir de la branche actuelle avec "git branch tic\_branch" puis "git switch tic\_branch" ou directement: "git switch -c tic\_branch" | Suis les mêmes instructions que Tic et créez une nouvelle branche "tac\_branch". |
| Tâche 13 | Crée un fichier **same\_file.html** et saisis un commentaire "<!-- tapez votre commentaire ici -->" | Crée un fichier **same\_file.html** et tape également un commentaire à l’intérieur, mais pas le même que Tic! |

## Étape 5

Tout le monde exécute les commandes suivantes:

```bash
1
git add .
2
git status
3
git commit -m "Change me"
```

Ensuite:

|  | Tic | Tac |
| --- | --- | --- |
| Tâche 14 | Publie ta branche sur GitHub en utilisant "git push origin tic\_branch" | Publie ta branche sur GitHub en utilisant: "git push origin tac\_branch" |
| Tâche 15 | Crée une pull request sur GitHub depuis ta branche **tic\_branch** vers **main** (sois prudent avec la direction). Vérifie si “able to merge” s’affiche. Ajoute une description: “Explain what you modified and how to test it”. | Regarde ce que fait Tic et fais de même avec ta branche (**tac\_branch** vers **main**) |
| Tâche 16 | Regarde ce que fait Tac et aide-le si nécessaire. | Va sur GitHub et accéde à ta pull request. Vérifie si tout semble bon, puis clique sur le bouton “Merge pull request”. 🥳 Bon travail! Tu viens de réussir la fusion de ta première branche! Maintenant, tu peux voir ton travail sur la branche principale. |
| Tâche 17 | Suis les mêmes étapes que Tac pour valider ta pull request et pouvoir fusionner ta branche. Fichtre! Il y a un conflit! tu peux voir le message: “This branch has conflicts that must be resolved”. | Regarde ce que fait Tic. |

Regardez cette vidéo ensemble pour pouvoir déboguer:

```bash
Resoudre les conflits de fusionComment débugguer.https://www.youtube.com/watch?v=JtIX3HJKwfo&t=2s
```

|  | Tic | Tac |
| --- | --- | --- |
| Tâche 18 | Au lieu de résoudre les conflits sur GitHub comme indiqué dans la vidéo, fais-le localement dans ton éditeur de code. Sur GitHub, clique sur “command line instructions” comme indiqué dans l’image suivante et suis les instructions. ![lien vers les instructions en ligne de commande](https://wildcodeschool.github.io/workshop-git/images/printConflicts.png) N’oublie pas de faire un "git status" entre chaque étape et d’en discuter avec Tac. | Regarde ce que fait Tic et aide-le si besoin (une deuxième personne ne sera pas toujours là pour résoudre les conflits avec vous, alors profitez-en!) |
| Tâche 19 | Maintenant qu’il n’y a plus de conflits, reviens à la pull request sur GitHub, vérifie si tout va bien et clique sur le bouton "Merge pull request". | Regarde ce que fait Tic et aide si nécessaire. |

Bravo à tout le monde, vous avez réussi à résoudre avec succès un conflit de fusion dans une pull request, félicitations! 🥳

Quête terminée le **jeudi 30 octobre 2025**