---
title: "Bash - Introduction - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2983/pages/17882"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
bash

## Bash - Introduction

Facile

1h

3 pairs

bash

## Bash - Introduction

## Introduction

**Bash** (pour Bourne-Again shell) est l'interpreteur en ligne de commande le plus courant sur les systèmes GNU/Linux. C'est le shell par défaut sur la plupart des distributions.

Il a été créé en 1989 par [Brian Fox](https://en.wikipedia.org/wiki/Brian_Fox_\(computer_programmer\)) et tire son nom du Bourne shell (écrit par [Steve Bourne](https://fr.wikipedia.org/wiki/Stephen_Bourne)) qui a été le shell par défaut de la version 7 d'Unix en 1977.  
Il est aujourd'hui développé et maintenu par le [projet GNU](https://www.gnu.org/).

![Logo bash avec l'inscription : The bourne-again shell](https://linuxhandbook.com/content/images/2020/06/bash-shell-logo.jpg)

---

## 🤓 Objectifs:

✅ Apprendre à créer un script bash  
✅ Comprendre comment exécuter un script  
✅ Découvrir les variables  
✅ Savoir faire varier le comportement d'un script avec des arguments

---

## Sommaire

- [📖 Glossaire](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#-glossaire)
- [📚 Définition](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#-d%C3%A9finition)
- [📄 Structure d'un script Bash](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#-structure-dun-script-bash)
- [⚙️ Appel d'un script](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#%EF%B8%8F-appel-dun-script)
	- [🔬 Un peu de pratique](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#-un-peu-de-pratique)
- [💲 Les variables](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#-les-variables)
	- [💲 Un peu de pratique](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#-un-peu-de-pratique-1)
- [🎛️ Paramètres et arguments](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#%EF%B8%8F-param%C3%A8tres-et-arguments)
- [#️⃣ Commentaires](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#%EF%B8%8F%E2%83%A3-commentaires)
- [🌱 Variables d'environnement](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#-variables-denvironnement)
- [🛠️ Exemples de construction de scripts "utiles"](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#%EF%B8%8F-exemples-de-construction-de-scripts-utiles)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2983/pages/17882#-crit%C3%A8res-dacceptation)

## 📖 Glossaire

- **shell**: Programme qui agit comme une interface utilisateur en ligne de commande (CLI, Command Line Interface) pour permettre à l'utilisateur de communiquer avec le système d'exploitation. Outre le bash, on peut nommer `sh`, `zsh`, `ksh`,...

---

## 📚 Définition

S'il y a une chose à retenir pour commencer, c'est que "Bash" est à la fois un **interpréteur de commandes** et un **langage de programmation**.

- Un **interpréteur de commandes** parce qu'il permet d'interagir avec le système d'exploitation via des commandes en lien étroit avec le système de fichiers, les divers composants de la machine, le réseau,...
- Un **langage de programmation** puisqu'il est possible de créer des fichiers contenant des instructions qui seront jouées selon un ordre logique, permettant de les regrouper en unités logiques: on parle alors de **scripts**.

C'est entre autres cette dualité qui en fait un outil extrêmement polyvalent: on peut **avec la même syntaxe** exécuter des commandes système et écrire des scripts complexes qui permettront d'automatiser des taches redondantes.

## 📄 Structure d'un script Bash

Nous allons ici nous intéresser à la possibilité d'écrire des scripts: comment écrire des instructions qui font le travail "à notre place". Avant même de voir les instructions que l'on peut mettre dans un script bash, penchons nous sur sa composition: un script Bash est un *fichier texte*. N'importe quel éditeur de texte te permettra de consulter un fichier Bash et d'en lire le contenu. Comme tout fichier il est sujet aux contraintes du système de fichiers, il est notamment rattaché à un propriétaire et un groupe. Attention: si pour lire le contenu d'un script il te faudra le droit *read* sur le fichier, pour exécuter le programme contenu il te faudra le droit *execute* (J'adore quand les choses sont nommées correctement, pas toi?). Il est courant que le nom d'un script bash se termine par ".sh" mais comme ailleurs dans un système Linux ce n'est pas une contrainte technique ni une obligation.

Ensuite, quelle est la structure de base à mettre dans un script? C'est (relativement) simple: il faut définir le *shebang* du script. Non non, ce n'est pas un gros mot! C'est le nom donné à la première instruction de ton script, qui définit quel interpréteur doit être utilisé lorsque cet interpréteur n'est pas précisé dans la commande d'appel.  
Pour l'anecdote, le nom est en fait la contraction des deux premiers caractères en anglais: `#!` (*sharp* et *bang*). Ainsi, un script bash classique commencera souvent par cette ligne: `#! /bin/bash`. Ce n'est pas invariable néanmoins, on peut imaginer trouver un de ces shebangs en tête de fichier (liste non exhaustive):

- `#!/bin/bash`
- `#!/usr/bin/env bash`
- `#!/bin/sh -x`
- `#!/usr/bin/perl`
- `#!/usr/bin/tcl`
- `#!/bin/sed -f`
- `#!/usr/awk -f`
- `#!/usr/bin/python -O`

Si tu as pris le temps de réellement lire la liste, quelque chose doit te paraître un peu étrange: Python? Perl? En effet, le shebang n'est pas exclusif à Bash: il sert à définir l'interpréteur, et fonctionne avec plusieurs langages, voire avec des commandes qu'on n'aurait pas qualifiées d'interpréteurs à proprement parler (sed, awk,...).

```shell
Bash Shebang
Tu peux en apprendre un peu plus sur les shebang en lisant cet article.https://linuxize.com/post/bash-shebang/
```

## ⚙️ Appel d'un script

Lorsque tu es dans ton terminal, tu peux appeler un script via la commande `bash chemin/vers/ton/script.sh`. Cela appelle bash pour lui demander d'exécuter ton fichier script. Il exécute son contenu ligne après ligne.

Tu peux aussi taper `./script.sh` (sans le mot clé `bash`) ou n'importe quel chemin qui permet d'acceder directement à ton script: le système lit le script en vue de l'exécuter, et en lisant le shebang il sait quel interpréteur utiliser. Tu dois avoir le droit d'exécution sur le fichier pour que cette technique fonctionne.

## 🔬 Un peu de pratique

Tu vas maintenant créer ton premier script et, pour perpétuer une tradition de développeurs, ce premier script se concentrera sur le fait d'afficher la chaine "Hello world!". Commence par ouvrir un terminal et créer un fichier `hello.sh`, édite le et ajoute le shebang que nous avons vu plus haut. Dans la suite du fichier nous allons utiliser la commande `echo 'Hello world'`. Elle va nous permettre d'afficher (dans le terminal) le texte "Hello world". Retourne dans ton invite de commande, et tape `bash ./hello.sh`: tu devrais voir apparaitre le texte juste en dessous et récupérer la main dans ton shell. Tu viens de réaliser ton premier script, félicitations!

Même si ce script n'est pas bien utile en soi, il va te permettre de faire quelques tests pour valider tout ce que tu as vu jusqu'ici:

- modifie les droits dessus (`chmod -x hello.sh`) et réessaie de l'exécuter de différentes façons (Rétablis ensuite les droits avec l'option `+x`).
```shell
Si tu connaîs un peu git, c'est sans doute le bon moment pour valider (commit) et éventuellement publier (push) ton premier script !
```

## 💲 Les variables

Notre script marche bien mais a un comportement trop basique, on aimerait qu'il soit capable de saluer l'utilisateur directement. On veut introduire un comportement **variable** à notre script: le comportement global est le même, on veut juste changer un détail d'implémentation (le nom à afficher).  
Créons donc une variable dans notre script. Edite `hello.sh` et modifie le comme suit:

```bash
1
#!/bin/bash
2
name="Wilder"
3
echo "Hello $name !"
```

En le réexécutant, joie! On a bien pu altérer le comportement de notre script. Mais qu'est ce qui s'est passé ici?

Une variable est un "nom de code" qui va contenir une information pour nous, ce qui va nous permettre de manipuler dans notre script ce nom de code plutôt que la valeur. La variable `school` peut contenir la valeur "Wild Code School" ou "Lycée Louis Pasteur" par exemple: tu n'as probablement pas envie de réécrire ton script à chaque fois que tu changes d'établissement!). Le nom d'une variable est un "simple" pointeur vers l'emplacement mémoire où sont conservées les données qu'elle contient.

Quelques points intéressants à propos des variables **en bash** (chaque langage à ses propres règles sur ces sujets):

- On affecte ("met une valeur dans") une variable grâce au signe `=`: en écrivant `my_school="WildCodeSchool"`, la valeur "Wild Code School" a été mémorisée sous le nom `my_school`
- On lit le contenu une variable en utilisant son nom précédé d'un `$`: `echo $my_school` affichera "Wild Code School" (si c'est écrit à la suite de l'exemple précédent)

## 💲 Un peu de pratique

C'est bien beau tout ça, mais si ce n'est pas terrible que mon nom soit "en dur" dans mon script (si je veux modifier le comportement, je dois éditer son contenu). Ce serait beaucoup plus sympa que le script *demande* à l'utilisateur comment il s'appelle avant de le saluer. Ca tombe bien, puisqu'une instruction Bash permet de faire exactement ça: `read`!  
En tapant l'instruction `read myName`, le script laissera la possibilité à l'utilisateur de saisir la valeur de son choix (et appuyer sur Entrée) et stockera ladite valeur dans `myName`. NB: cela va sans dire mais-va-mieux-en-le-disant: vous pouvez choisir ce que vous voulez comme nom de variable, `myName` n'est ici qu'un exemple;-)

A ton tour: modifie le script `hello.sh` pour qu'il utilise l'instruction `read` et salue ensuite l'utilisateur. Ci-dessous tu trouveras différentes solutions: en effet, un même problème peut être résolu de plein de manières différentes, et ce sera de plus en plus vrai à mesure que tu apprendras les possibilités de bash (et des langages de programmation en général)

```bash
Voir la solution1
#!/bin/bash
2

3
echo "Merci de spécifier votre nom : "
4
read name
5
echo "Hello $name !"
```
```shell
Voir la solution
Si tu as lu la documentation ou fait des recherches sur read, tu as peut-être découvert une option de la commande. Comme son nom l'indique, une option va modifier le comportement de ton script. Ici, l'option -p ("prompt", qu'on pourrait traduire ici par "intitulé") suivie d'un texte te permet de donner directement l'introduction fournie à ton utilisateur :

1
#!/bin/bash
2

3
read -p "Merci de spécifier votre nom : " name
4
echo "Hello $name !"
```
```shell
Voir la solution
En poussant un peu, on pourrait arriver au même résultat en une seule ligne en utilisant l'opérateur && ("et"), qui permet de jouer la seconde partie de la ligne si et seulement si la première s'est bien déroulée. Mais nous verrons cela plus tard, cet exemple est juste là pour attiser ta curiosité :

1
#!/bin/bash
2

3
read -p "Merci de spécifier votre nom : " name && echo "Hello $name !"
```

## 🎛️ Paramètres et arguments

C'est un bien joli script que tu as fait, mais l'utilisateur a tout de même deux actions à faire pour se faire saluer (lancer le script, **puis** indiquer son nom). L'idéal en termes d'utilisabilité (et d'automatisation) serait de permettre de faire les deux actions en une seule ligne: entrent en scène les **paramètres** et les **arguments**

- Les **paramètres** sont des variables prédéfinies qu'un script peut utiliser pour récupérer des valeurs fournis lors de l'appel à ce script.
- Les **arguments** permettent à l'utilisateur de donner une information importante au fonctionnement de ton script. Ce sont les valeurs des paramètres pour une execution donnée du script. Elles sont sépares du nom du script par un (ou des) espaces.

Un petit exemple?  
Tu pourrais imaginer appeler le script précédent ainsi: `./hello.sh Wilder`.  
Dans ce cas, `Wilder` est un argument du script avec l'idée suivante: on donne notre nom au script afin qu'il sache quoi afficher (on aurait aussi pu appeler `./hello.sh Brian`, la seule différence aurait résidé dans le nom affiché)

Très bien, on a donc transféré des arguments à notre script, mais comment les récupérer et les utiliser? Quand tu exécutes un script bash, le nom du script lui-même est accessible dans une variable `$0`, et les arguments potentiels sont disponibles dans des variables nommées de `$1` à `$9`: les paramètres du script.

On obtient donc le script suivant:

```bash
1
#!/bin/bash
2

3
echo "Hello $1 !"
```

Si tu appelles la commande `bash hello.sh Wilder`, tu verras apparaître le message "Hello Wilder!".

```shell
Le standard POSIX qui assure la compatibilité des systèmes dits unix établit des conventions sur la syntaxe des commandes et distingue les arguments obligatoires d'un script (ou d'un programme) de ceux qui sont facultatifs : les options.
Dans cette convention, les options sont reconnaissables parce qu'elles commencent par le caractère -.
GNU ajoute le principe d'options au format long qui débutent quand à elles par --.
Plus d'information en suivant ce lien : https://www.gnu.org/software/libc/manual/html_node/Argument-Syntax.html
```

Simple et efficace! Bien sûr, c'est plutôt simple à appliquer sur un script ne comprenant qu'une ou deux lignes de code, mais si tes scripts sont plus complexes (et ils le deviendront bientôt!) il serait intéressant de pouvoir expliquer à un éventuel utilisateur (ou prochain développeur) ce qu'il doit savoir sans lire et analyser intégralement le code... Ce qui nous amène aux commentaires!

Comme vu auparavant, tout texte écrit dans le fichier est analysé et exécuté par ton interpréteur de commande. Comment y insérer de la documentation, un avertissement ou toute autre info utile à une autre humain? Ce besoin est omniprésent parmi les langages de programmation et ils possèdent presque tous la possibilité d'ajouter des **commentaires**: du texte que l'interpréteur saura qu'il doit ignorer.  
En Bash, toute ligne (sauf la première avec le shebang) commençant par un symbole dièse `#` sera purement et simplement ignorée par Bash. Un exemple?

```bash
1
#!/bin/bash
2

3
# Script arguments:
4
# $1 should represent the name of the user to be greeted
5
# The argument is mandatory but the script doesn't check it for now
6
echo "Hello $1 !"
```

Ce script fait *exactement* la même chose que le précédent; mais à la lecture, on a une meilleure idée de l'utilité de `$1`.

## 🌱 Variables d'environnement

... Oui, on va *encore* modifier ce script "hello.sh" (promis, c'est la dernière fois!).

Au final, c'est un peu étrange de devoir donner ton nom à un script pour qu'il te salue, il pourrait le "déduire" de ton invite de commande (Ex: `wilder@wildcodeschool` signifie que tu t'appelles "wilder). Bash a accès à toute une liste de *variables* particulières qui décrivent ton *environnement* de travail: les **variables d'environnement**.

Ton OS en définit certaines par défaut et elles sont accessibles depuis n'importe quel script, programme ou commande. Leurs noms sont sensibles à la casse et sont souvent écrites en "MAJUSCULES" par convention. Tu peux toutes les consulter via la commande `printenv`, ou `printenv PATH` si tu souhaites connaitre le contenu de la variable d'environnement PATH (pour information, c'est elle qui définit les dossiers dans lesquels l'interpréteur cherchera les commandes que tu invoques). Tu peux accéder à la valeur d'une telle variable exactement comme tu le ferais avec une variable classique, via `$PATH` par exemple, et ceci depuis ton terminal ou un script. Dernière version de notre `hello.sh`:

```bash
1
#!/bin/bash
2

3
echo "Hello $USERNAME !"
```

Lance le script et tu devrais voir le message "Hello Matthias!" (si ton nom d'utilisateur est ton prénom, bien sûr). Pas de valeur "en dur" (c'est ainsi qu'on appelle les valeurs affichées sans le secours de variables, et ce n'est pas une bonne pratique!) ni besoin de prompt supplémentaire, d'argument ou autre: l'interpréteur connait déjà la valeur à afficher. Et le meilleur est que tu peux partager ton script avec quelqu'un et c'est **son** nom qui s'affichera, un peu comme s'il s'adressait systématiquement à la bonne personne, il remplit maintenant sa fonction correctement (en plus de t'avoir accompagné dans la découverte de nouvelles notions, bien sûr).

D'ailleurs profitons en pour explorer cette variable d'environnement `PATH`.  
Il est dit plus haut qu'elle contient l'ensemble des chemins dans lequel ton interpréteur de commande (bash en l’occurrence dans le cas qui nous intéresse) cherche une commande lorsqu'elle est appelée avec son nom seulement (c'est à dire, sans le chemin nécessaire pour y accéder).

Commence par jeter un coup d'oeil à sa valeur:

```bash
1
wilder@host:~$ echo $PATH
2
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
3
wilder@host:~$
```

Tu devrais obtenir un résultat proche. En tout cas, il s'agit d'une liste de chemins séparé par `:`.

Testons ce comportement en ajoutant le répertoire dans lequel se trouve notre script à cette liste.  
Dans l'exemple qui suit, on suppose que ce répertoire est: `/home/wilder/bash-scripts`.

```bash
1
wilder@host:~$ PATH=$PATH:/home/wilder/bash-scripts/
2
wilder@host:~$ echo $PATH
3
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/wilder/bash-scripts/
4
romain@atlas:~$ hello.sh
5
Hello wilder
```

Tu constates qu'il est maintenant possible d'appeler ton script uniquement avec son nom comme les commandes classiques telles que `ls` ou `cp`.

```shell
Attention, ce changement de la valeur de PATH n'est effectif que dans le shell courant (celui dans lequel tu as taper l'exemple.

Si tu ouvres un autre shell, les variables d'environnement y seront telles qu'elles sont à leur état initial et donc sans la modification que tu viens de faire.

Chaque instance du shell dispose de son propre environnement.
Si tu souhaites que cette modification du PATH soit effective dans chacun de tes shells il est possible d'ajouter la modification de la variable dans le fichier ~.bashrc en utilisant commande export qui permet aux variables d'environnement d'être disponible dans les sous-shell.
Tu peux par exemple ajouter les lignes suivantes à la fin du fichier ~/.bashrc :
# Add the ~/scripts directory to PATH for an easy access to my scripts
export PATH="$HOME/scripts:$PATH"

Tu en profites pour noter que la variable d'environnement $HOME contient le chemin de ton répertoire personnel.
Ainsi, si tu ranges tous tes scripts ce dossier, que tu ajoutes ce dossier à ton $PATH, et que par ailleurs tu omets le .sh dans les noms de tes scripts, tes scripts deviennent comme des commandes classiques de ton shell auxquelles tu peux accéder où que tu sois dans l'arborescence en tapant simplement leur nom. Pratique, non ?
```

Et si on passait à la vitesse supérieure?

## 🛠️ Exemples de construction de scripts "utiles"

Un adage de développeurs dit en substance: "Le développement est l'art de passer une semaine à gagner une seconde". Outre le paradoxe humoristique apparent, l'idée est de gagner cette "seconde" un nombre de fois suffisant pour que l'automatisation devienne "rentable" en termes de temps (un script à lancer) et de fiabilité (pas de risque d'erreur de saisie ou d'inattention).  
Il y a quelque chose qu'il faut bien comprendre: toute commande que tu tapes dans ton terminal pourrait être une instruction dans un script. Du simple `ls` aux commandes bash les plus complexes, **tout** est automatisable.

On va ici construire un script à partir de besoins, pour que tu voies un peu mieux le processus qui amène de l'idée à l'outil automatisé final.

```shell
Besoin : "Chaque matin je lance les mêmes programmes :

Firefox
Virtualbox
Keepass (mon gestionnaire de mots de passe)
etc.

C'est redondant et j'oublie une fois sur deux de lancer KeePass, c'est agaçant". Moins de clics, plus de CLI !
```

Lorsque tu cliques sur l'icône de Firefox sur Ubuntu (ou double-cliques sur Windows, le fonctionnement est le même), tu appelles un programme... Que tu pourrais tout aussi bien appeler via ton terminal!

Ouvre un terminal sur une session graphique et tape firefox (ou le nom de ton navigateur préféré). Hop, ton navigateur s'ouvre et affiche une belle fenêtre graphique comme il le fait habituellement.

Écrit donc le script pour te permettre de lancer tous tes programmes du matin en une seule action.

```bash
Voir la solution1
#!/bin/bash
2

3
# Script to start all everydays tools at once
4
firefox
5
keepassxc
6
virtualbox
```

Maintenant, tu peux même cliquer sur ton script via ton interface graphique pour lancer tout d'un coup 😉

---

## ☝️ Résumé

Les scripts bash sont des fichiers textes qui permettent d’exécuter une séquence de commande en une seule opération. Il peuvent comporter des commentaires et des variables qui permettent de nommer des valeurs pouvant ainsi être utilisée plusieurs fois.

Des variables prédéfinies permettent de récupérer les arguments de la ligne de commande et ainsi avoir un comportement différents à chaque appel.

D'autres variables d'environnement permettent d’accéder à des informations du système directement depuis le script.

---

## 📝 Quiz

```shell
# 1  - Bash est le shell historique disponible depuis la première version d'Unix.FauxVraiValider# 2 =$exportechoValider# 3 $=printreadValider# 4 getread=$Valider# 5 $SCRIPT_NAME$0$1Cette variable n'existe pasValiderTon score :0 / 5
```

---

## 💪 Challenge

```shell
Besoin : "Je veux regrouper tous mes projets de scripts dans un même répertoire.

Dans ce répertoire chaque projet est rangé dans un dossier qui porte le nom du projet.

Dans ce dossier il y a au moins 2 fichiers :

le script qui s'appelle comme le projet avec un .sh à la fin
un fichier README.md pour documenter le projet.

Pour éviter d'avoir à le faire à chaque fois, on veut donc lancer une unique commande qui créera des fichiers préremplis dans un dossier préétabli.
```

Exemple:

Supposons que le dossier dans lequel on range les projets soit le dossier `~/Projets` et qu'on veuille créer le projet `SuperScript`. Voici la commande qu'on veut pouvoir taper et ce qu'on veut obtenir:

```bash
1
wilder@host:~$ create-project.sh SuperScript
2
Création du dossier /home/wilder/Projets/SuperScript
3
Initialisation du fichier /home/wilder/Projets/SuperScript/README.md
4
Initialisation du fichier /home/wilder/Projets/SuperScript/SuperScript.sh
5
Projet SuperScript initialisé
6
wilder@host:~$ ls -lh Projets/SuperScript/
7
total 8K
8
-rw-rw-r-- 1 wilder wilder   21 mars   1 16:55 README.md
9
-rwxrwxr-x 1 wilder wilder   12 mars   1 16:55 SuperScript.sh
10
wilder@host:~$ cat Projets/SuperScript/SuperScript.sh 
11
#!/bin/bash
12
wilder@host:~$ cat Projets/SuperScript/README.md 
13
# Projet SuperScript
14
wilder@host:~$ 
15
```

Créé le script permettant de réaliser cette opération et copie ce script dans la solution de cette quête.

## 🧐 Critères d'acceptation

Le script doit respecter les contraintes suivantes:

- Le dossier dans lequel les projets sont rangé doit être dans une variable en début de script pour pouvoir être modifier facilement.
- Le script doit comporter les commentaires nécessaires à suivre les différentes étapes.
- L'affichage du script doit être conforme à l'exemple au dessus.
- 1 dossier et 2 fichiers doivent être crées avec les noms adéquats.
- Le script doit déjà comporter le shebang et disposer des droits d'exécution
- Le README.md doit commencer par un titre en markdown comportant le nom du projet.

Solution postée le **dimanche 02 novembre 2025**

```shell
1
#! /bin/bash
2

3
# Variable
4
NomDossier="Projets"
5
Projet="$1"
6
BASE_DIR="$HOME/$NomDossier"
7

8
# Script :
9

10
# Création dossiers, créations fichiers
11
mkdir -p $NomDossier/$Projet 
12
touch $BASE_DIR/$Projet/$Projet.sh README.md 
13

14
# Ecrit le contenu des fichiers
15
echo "#!/bin/bash" > $BASE_DIR/$Projet/$Projet.sh
16
echo "# Projet $1" > $BASE_DIR/$Projet/README.md
17

18
# Donne les droits d'execution
19
chmod +x $BASE_DIR/$Projet/$Projet.sh
20

21
# Affichage à l'écran de ce que le script vient de faire
22
echo "Création du dossier $BASE_DIR/$Projet"
23
echo "Initialisation du fichier $BASE_DIR/$Projet/README.md"
24
echo "Initialisation du fichier $BASE_DIR/$Projet/$Projet.sh"
25
echo "Projet $1 initialisé"
```