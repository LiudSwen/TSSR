---
title: "👩‍🏫 Terminal 2 - Fichiers et dossiers - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1316/pages/10344"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Terminal

## 👩🏫 Terminal 2 - Fichiers et dossiers

Découvre comment manipuler les fichiers et les dossiers avec le terminal

Facile

45mins

3 pairs

Terminal

## 👩🏫 Terminal 2 - Fichiers et dossiers

## Introduction

Le terminal est souvent utilisé pour **manipuler des répertoires et des fichiers**.  
Avec ton terminal, tu peux **créer et supprimer des répertoires**, créer des **fichiers**, **copier** et **déplacer** des fichiers.  
Dans cette quête, tu vas **apprendre à utiliser toutes ces commandes** dans ton terminal.

![image](https://storage.googleapis.com/quest_editor_uploads/PaizwzicAwTlqLbCJ3a4Zj7SdnZbS9SQ.jpeg)

## 🤓 A la fin de cette quête, tu sauras:

- ✅ Comment **créer** **répertoires** et fichiers avec ton interface en ligne de commande (CLI en)
- ✅ Comment **copier** et **déplacer** des fichiers et répertoires avec ton CLI

## Créer des répertoires

> `mkdir` → **m** a **k** e **dir** ectory

Depuis la racine de ton dossier personnel (`cd` pour y retourner), entre:

```bash
1
mkdir quests
2
mkdir -p quests/shell/vegetables quests/shell/fruits
3
mkdir quests/shell/remove-me quests/shell/delete-me
4
ls quests/shell
```

Remarques:

- Tu peux créer un seul répertoire comme sur la première ligne, ou plusieurs à la fois comme sur la deuxième ligne.
- La commande de la deuxième ligne échouerait sans le flag `-p` parce que le répertoire `quests/shell` n'existe pas; `-p` indique à `mkdir` de créer les répertoires intermédiaires si ceux-ci n'existent pas.

## Supprimer des répertoires

> `rmdir` → **r** e **m** ove **dir** ectory

Nous allons supprimer deux des répertoires que nous venons de créer:

```bash
1
rmdir quests/shell/remove-me quests/shell/delete-me
```

Attention, ici, `rmdir` ne fonctionne que sur des répertoires vides!

## Créer des fichiers

> `touch`

Cet exemple montre que tu peux créer un ou plusieurs fichiers, de la même manière que tu peux créer plusieurs répertoires avec `mkdir`.

```bash
1
cd ~/quests/shell
2
touch apple
3
touch apricot
4
touch carrot parsnip cauliflower courgette
5
ls
```

Créer des fichiers vides peut être utile de temps en temps, même si cela ne semble pas évident à première vue!

`touch` a un second effet: il **modifie le timestamp du fichier**. Un timestamp (horodatage) est une information précise de **date/heure**.  
Le système de fichiers mémorise, entre autres, les horodatages de la dernière modification et du dernier accès au fichier.  
A proprement parler, il ne s'agit pas d'un "historique", car seule la dernière date/heure est stockée. Par exemple:

```bash
1
ls -l ~/.bashrc
2
touch ~/.bashrc
3
ls -l ~/.bashrc
```

Le second `ls -l` indique que le dernier horodatage de modification a été fixé à la date du jour.

## Copier des fichiers

> `cp` → **c** o *p* y

La commande `cp` est utilisée avec deux paramètres, à savoir la ou les *source(s)* et la *destination* (ou *cible*). Il peut y avoir plusieurs sources, mais il n'y a qu'une seule destination.

#### Exemple 1: Copier un fichier

Nous créons ici deux copies du fichier `apple`, qui est la *source* dans les deux cas, la *destination* étant à chaque fois un nouveau fichier: `banana` or `orange`, chacun étant une copie exacte de `apple`.

```bash
1
cp apple banana
2
cp apple fruits/orange
3
ls ; ls fruits
```

Remarques:

- Tu peux spécifier n'importe quel chemin pour la cible, comme indiqué dans le deuxième `cp`
- `;` te permet de lancer plusieurs commandes en une seule ligne.

#### Exemple 2: Copier plusieurs fichiers dans un repertoire

Ici, nous créons une copie de chacun des fruits dans le répertoire `fruits`:

```bash
1
cp ap* banana fruits/
2
ls fruits
```

Remarques:

- Lorsque l'ordre `cp` reçoit plus de deux arguments, il s'attend à ce que le dernier, la destination, soit un **répertoire**.
- Le `/` ajouté aux `fruits` est **optionnel** (même sans lui, `cp` déterminera si la cible est un fichier ou un répertoire).
- Le concept des caractères *wildcard*: des caractères spéciaux permettent de spécifier simplement des ensembles de fichiers. Le caractère `*` seul signifie **"tous les fichiers "**; `ap*` signifie "tous les fichiers commençant par `ap` " (donc "apple" et "apricot" correspondent).

#### Exemple 3: faire une copie récursive

Tu rencontreras le terme **récursivité** si tu suis une formation de développeur.  
Il s'agit de **répéter** la même opération un certain nombre de fois.  
Appliqué à la copie, cela se traduit par **copier un répertoire** et *son contenu entier*.

Exemple avec le repertoire `/fruits`:

```bash
1
cp -R fruits copy-of-fruits
```

Concrètement, `cp` copie d'abord le répertoire donné comme argument source (ici `fruits`). **Grâce à l'argument `-R`**, si le répertoire source contient des fichiers, ceux-ci sont copiés. S'il contient des répertoires, il les copie aussi, puis "descend" dans chacun de ces répertoires, et copie leur contenu, et ainsi de suite.

Cela fonctionne également avec des répertoires sources multiples, et dans ce cas tu devras donner un répertoire existant comme argument de destination. Ici, nous allons copier `fruits` et `copy-of-fruits` dans le dossier `/tmp` qui contient les fichiers temporaires du système. Comme son contenu est effacé chaque fois que la machine est redémarrée, il peut être "pollué" sans crainte!

```bash
1
cp -R fruits copy-of-fruits /tmp/
```

Tu remarqueras que le flag `-R` est obligatoire pour copier un répertoire, même si il est vide.

## Supprimer des fichiers et des repertoires

> `rm` → **r** e **m** ove

**Attention!** Contrairement au bouton "Mettre dans la corbeille" de Windows ou de MacOS, la suppression via `rm` est **immédiate et définitive**.  
⬇️(**Une fois n'est pas coutume, ne reproduis PAS les commandes ci-dessous sur ta machine 🙏🙏**) ![sudo rm -rf /](https://i.redd.it/bziqsyznxtu31.jpg)

#### Exemple 1: Supprimer les doublons

Après les exemples de `cp`, tu te retrouves avec des doublons, que tu peux voir en lançant `find` - qui affiche le **contenu de l'arborescence** du répertoire courant.

Sachant que nous avons copié les fruits dans le répertoire `fruits`, nous allons supprimer les originaux, en utilisant `rm`:

```bash
1
rm ap* banana
```

Là encore, il est possible de passer plusieurs fichiers en paramètre, et d'utiliser une *wildcard* pour entrer moins de caractères.

#### Exemple 2: supprimer récursivement un répertoire

La commande `rmdir` ne permettant pas d' **effacer un répertoire non-vide**, on peut utiliser `rm` avec l'option `-r` (récursif) pour y parvenir:

```bash
1
rm -r copy-of-fruits
```

> Comme le `rm` est **immédiat et définitif**, tu dois **faire attention** lorsque tu l'utilises avec le `-r` et/ou avec la wildcard `*`.  
> Il est en effet trop facile de se tromper et d'effacer par inadvertance tout un répertoire et son contenu.

## Déplacer et/ou renommer

> `mv` → **m** o **v** e

`mv` est utilisé avec deux ou plusieurs arguments, tout comme `cp` - le dernier étant la destination, et le(s) précédent(s) la (ou les) source(s).

- Déplacer: `mv ca* parsnip courgette vegetables/`
- Renommer: `mv fruits/orange fruits/grapefruit`
- Déplacer et renommer: `mv vegetables/courgette fruits/kiwi`

---

## 📚 Ressources

```shell
Learning the shell - lesson 5Une ressource qui couvre les mêmes commandes que cette quête, et donne d'autres exemples de l'utilisation des wildcards.http://linuxcommand.org/lc3_lts0050.php
```

---

## 💪 Challenge

Tu vas devoir télécharger un fichier planets.zip, que tu récupereras via le terminal.

Tu auras besoin de deux outils en ligne de commande: curl et unzip, qui te permettent respectivement de télécharger un fichier, et de décompresser une archive.zip.

Pour les installer, tu vas également utiliser le terminal! Voici les commandes à exécuter, en fonction de ton système d'exploitation:

### Installer curl et unzip

##### Linux

```bash
1
sudo apt-get install -y curl unzip
```

(sudo avant une commande t'accorde temporairement des privilèges administratifs, qui sont nécessaires pour installer un logiciel).

##### MacOS

```bash
1
brew install curl unzip
```

(curl est censé être livré avec MacOS, donc `brew install unzip` devrait suffire).

##### Windows

Rien à faire, puisque curl et unzip sont installés par défaut avec Git Bash!

---

### Télécharger le fichier:

Navigue maintenant dans le répertoire `~/quests/shell` et lance ces deux commandes, pour télécharger l'archive planets.zip et la décompresser:

```bash
1
curl --ssl-no-revoke -L -o planets.zip "https://github.com/WildCodeSchool/quests-resources/blob/master/terminal/planets.zip?raw=true"
2
unzip planets.zip
```

---

## Challenge

Cette archive contient des images de planètes réelles et fictives. Une fois que tu as extrait ses fichiers, utilise l'explorateur de fichiers de ton système pour visualiser les images qu'elle contient.

Mais le but n'est pas (encore) de devenir un touriste de l'espace!  
Tu vas utiliser une partie des commandes que tu viens d'apprendre dans cette quête, pour classer les planètes. Tu vas devoir:

1. **📂 Créer trois répertoires sous planets:**
	- real
		- fictional
		- inhabited
2. **📂 Créer trois autres répertoires dans le répertoire planets/real:**
	- terrestrial
		- gas-giants
		- dwarf-planets
3. ↪️ **Déplacer chacune des neuf planètes** **réelles** à l'endroit correct parmi les trois sous-dossiers de planets/real,
4. ↪️ **Déplacer les trois planètes fictives** sous "planets/fictional",
5. ⏩ **Copier les quatre planètes habitées** (qu'elles soient habitées par des humains ou des robots) dans planets/inhabited (remarque: attention en anglais, *inhabited* signifie habité, *uninhabited* signifie inhabité)
6. ❌ Enfin, puisque Pluton n'est plus vraiment considérée comme une planète, tu vas enfin l' **effacer, ainsi que son répertoire parent**.

Si tu es un peu perdu, tu peux demander aux camarades branchés science(-fiction) de t'aider, sinon tu peux trouver des indices [ici](https://www.le-systeme-solaire.net/planetes.html) et [ici](https://star-name-registry.com/blog/item/top-15-fictional-planets-in-science-fiction).

Le résultat de tes efforts comprendra:

- **Une copie de la sortie de la commande `find` (ou pour les utilisateurs de mac OS la sortie de la commande `ls -R` )**
- **Une copie de l'historique des commandes qui t'a conduit à ce point: utilise la commande `history` et colle uniquement les lignes relatives au challenge**
- **Après avoir validé ton résultat, tu peux nettoyer le répertoire `~/quests/shell`.**

## 🧐 Critères de réussite

- Avoir bien organisé les planètes!
- N'avoir utilisé que le terminal:)

Solution postée le **jeudi 23 octobre 2025**

```shell
1
# Solution Final avec les planètes valides
2

3
## Find
4

5
'''
6
mat@mat-Ubu:~$ find ~/planets/
7
/home/mat/planets/
8
/home/mat/planets/real
9
/home/mat/planets/real/gas-giants
10
/home/mat/planets/real/gas-giants/neptune.jpeg
11
/home/mat/planets/real/gas-giants/jupiter.jpeg
12
/home/mat/planets/real/gas-giants/uranus.jpeg
13
/home/mat/planets/real/gas-giants/saturn.jpeg
14
/home/mat/planets/real/terrestrial
15
/home/mat/planets/real/terrestrial/venus.jpeg
16
/home/mat/planets/real/terrestrial/earth.jpeg
17
/home/mat/planets/real/terrestrial/mars.jpeg
18
/home/mat/planets/real/terrestrial/mercury.jpeg
19
/home/mat/planets/fictionnal
20
/home/mat/planets/fictionnal/cybertron.jpeg
21
/home/mat/planets/fictionnal/arrakis.jpeg
22
/home/mat/planets/fictionnal/coruscant.jpeg
23
/home/mat/planets/inhabited
24
/home/mat/planets/inhabited/cybertron.jpeg
25
/home/mat/planets/inhabited/earth.jpeg
26
/home/mat/planets/inhabited/arrakis.jpeg
27
/home/mat/planets/inhabited/coruscant.jpeg
28
'''
29

30
## History
31

32
'''
33
   9  curl --ssl-no-revoke -L -o planets.zip "https://github.com/WildCodeSchool/quests-resources/blob/master/terminal/planets.zip?raw=true"
34
   10  unzip planets.zip
35
   11  pwd
36
   12  cd /home/mat/planets
37
   13  mkdir real fictionnal inhabited
38
   20  mkdir ~/planets/real/terrestrial/
39
   21  mkdir ~/planets/real/gas-giants dwarf-plantes
40
   22  mv dwarf-planets > real
41
   23  rm -r dwarf-plantes/
42
   24  mkdir ~/planets/real/dwarf-planets
43
   27  mv arrakis.jpeg coruscant.jpeg cybertron.jpeg fictionnal/
44
   28  mv mercury.jpeg venus.jpeg earth.jpeg mars.jpeg real/terrestrial/
45
   29  mv jupiter.jpeg saturn.jpeg uranus.jpeg neptune.jpeg real/gas-giants/
46
   30  mv pluto.jpeg real/dwarf-planets/
47
   31  cd real
48
   32  rm -r dwarf-planets/
49
   33  cd ..
50
   34  find
51
   35  cd ..
52
   36  find ~/planets
53
   37  cd fictionnal
54
   38  cd ~/planets/fictionnal/
55
   39  cp arrakis.jpeg coruscant.jpeg cybertron.jpeg ~/planets/inhabited/
56
   40  cd ~/planets/real/terrestrial/
57
   41  cp earth.jpeg ~/planets/inhabited/
58
   42  cd ~
59
   43  find ~/planets/
60
'''
```