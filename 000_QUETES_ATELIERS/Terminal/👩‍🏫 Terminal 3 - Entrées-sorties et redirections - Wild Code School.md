---
title: "👩‍🏫 Terminal 3 - Entrées-sorties et redirections - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/701/pages/7702"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Terminal

## 👩🏫 Terminal 3 - Entrées-sorties et redirections

3 pairs

Terminal

## 👩🏫 Terminal 3 - Entrées-sorties et redirections

Cette quête présente le concept d'entrées et sorties, d'une manière générale puis plus spécifique à Unix et Linux.

Ces concepts seront mis en pratique, d'abord via des commandes d'affichage. Puis tu verras les mécanismes de redirection de sortie dans le terminal.

Dans cette quête, on évoque Unix, qui a donné naissance à des systèmes tels que Linux et MacOS. Garde à l'esprit que, quand on parle de fonctionnalités ou de commandes Unix, c'est juste pour indiquer que celles-ci existaient dans le système Unix originel, et ne sont pas spécifiques à Linux: elles sont par exemple nativement disponibles sur MacOS.

#### Objectifs

- Comprendre les entrées/sorties
- Commandes d'affichage
- Rediriger la sortie d'une commande
- Entrées

### Entrées/sorties

Les termes d'entrée et de sortie sont courants en informatique, et pas seulement dans le monde Unix/Linux.

Le terme même d'informatique désigne le traitement automatisé de l'information. Un programme informatique:

- prend des données en **entrée**,
- les transforme,
- restitue les données transformées en **sortie**.

Par exemple, le logiciel Auto-Tune prend en entrée des données sonores numérisées, corrige la tonalité de la voix, et donne en sortie le résultat.

Au niveau matériel, on parle de périphériques:

- d' **entrée**: clavier, souris, tablette graphique, scanner, microphone, etc.
- de **sortie**: moniteur, imprimante, enceinte, etc.

Les terminaux matériels tels que le DEC VT100 ci-dessous étaient équipés d'un périphérique d'entrée, le clavier, et d'un périphérique de sortie, l'écran.

![](https://storage.googleapis.com/images-innoveduc/linux_terminal/DEC_VT100_terminal.jpg)

### Commandes d'affichage

> On va voir beaucoup de commandes dans cette quête. Si tu te souviens du nom d'une commande, mais pas de comment l'utiliser, tu peux utiliser les "pages de manuel": tape `man commande` pour obtenir de l'aide sur `commande` (par exemple `man ls`). Pour quitter, utilise la touche **q**.

Les commandes que tu as vues dans la première quête Linux, telles que `ls`, produisent un affichage sur ce qu'on appelle la "sortie standard", en d'autres termes, l'écran du terminal.

Il existe plusieurs commandes dédiées à l'affichage du contenu d'un fichier texte sur la sortie standard.

![](https://storage.googleapis.com/images-innoveduc/linux_terminal/cat-command-meme.jpg)

`cat` permet entre autres d'afficher le contenu d'un fichier de texte, dans son intégralité. Afin de pouvoir l'essayer, récupère un fichier d'exemple (une petite liste de commandes Unix) en lançant la commande ci-dessous. Au préalable, sous Linux tu peux avoir besoin de lancer `sudo apt-get install -y curl`, sous Windows tu dois avoir [installé Git Bash](https://gist.github.com/bhubr/00c6e39e72231cf091a17772d73e6fb3).

```shell
curl -o Unix_commands.md https://gist.githubusercontent.com/phaneendra/3804036/raw/f124b9f7703114d6be22f55e775cd2d015a45a91/UnixCommands.md
```

Pour afficher le contenu de ce fichier, lance la commande suivante:

```shell
1
cat Unix_commands.md
2
```

Ce fichier est d'une taille "raisonnable". Mais lorsqu'on a affaire à des fichiers volumineux, `cat` s'avère peu pratique, car on est obligé de faire défiler l'affichage pour remonter vers le début du fichier.

- `more` permet d'afficher le contenu d'un fichier, page par page: touche *espace* pour avancer d'une page, touche *b* (back) pour reculer d'une page, *q* (quit) pour quitter.
- `less` est un peu plus intuitif et permet d'avancer/reculer grâce aux touches bas/haut. Pour quitter `less`, il faut utiliser la touche *q*, comme pour `more`.
- `head` et `tail` permettent d'afficher respectivement les 10 premières ou dernières lignes d'un fichier. Parmi les arguments qu'elles reconnaissent:
- `-n` suivi d'un nombre permet de spécifier le nombre de lignes qu'on veut voir
- `-f` les fait passer en mode "follow": si le fichier est modifié, les modifications s'affichent en direct à l'écran (dans ce cas, utilise *Ctrl C* pour quitter).
```shell
Cheat sheets Linux et UbuntuDes aide-mémoires en une page, l'un couvrant Linux en général, et l'autre plus spécifiquement Ubuntu. Les utilisateurs de Git Bash (Windows) et MacOS peuvent utiliser la version Linux.https://threenine.co.uk/linux-terminal-command-cheat-sheets/
```

### Rediriger la sortie d'une commande

Certaines commandes Unix font leur travail silencieusement, comme `cp` ou `mv`, qui ne produisent pas d'affichage quand elles réussissent.

Les autres affichent leurs résultats sur la "sortie standard", l'écran. Mais on peut vouloir récupérer les informations produites par une commande, par exemple pour les sauvegarder dans un fichier.

Unix fournit pour cela des mécanismes de *redirection des entrées-sorties*.

#### Rediriger vers un fichier

Essaie cette commande, dont la 1ère partie devrait t'être familière (`ls` = lister le contenu d'un répertoire, `~` = répertoire personnel):

```shell
1
ls ~ > home-contents.txt
2
```

Tu le constates, cette commande n'affiche... rien!

C'est dû à l'utilisation du symbole `>`: au lieu d'être affiché sur la sortie standard, le résultat de `ls ~` a été écrit dans le fichier `home-contents.txt`, qui est créé par la même occasion - ou écrasé, c’est-à-dire remplacé, s’il existait. Tu viens d'effectuer une *redirection de sortie*.

> Le symbole `>` permet de rediriger la sortie d'une commande vers une autre sortie que la sortie standard. La variante `>>` permet aussi de rediriger la sortie vers un fichier, mais en *ajoutant* du contenu au fichier s’il existe, plutôt que de l’écraser.

Petit exercice: vérifie la présence du fichier `home-contents.txt` avec `ls`, puis affiche-le, et enfin supprime-le.

#### Rendre une commande silencieuse

> **Attention**, la commande suivante ne fonctionnera pas sous Windows, même avec Git Bash!

Il peut arriver qu'on ait besoin d'exécuter une commande, sans que celle-ci produise d'affichage. On peut alors rediriger sa sortie vers le "périphérique nul", un pseudo-périphérique qui ne garde pas les données qui y sont écrites. Exemple:

```shell
1
ls / > /dev/null
2
```

#### Sortie d'erreur

Essaie de rediriger la sortie d'un `cat` sur un fichier inexistant vers un fichier, par exemple:

```shell
cat /foo > /tmp/foo.txt
```

Contre toute attente, tu écopes de l'affichage suivant:

```shell
cat: /foo: No such file or directory
```

Wait... la sortie écran aurait dû être écrite dans `/tmp/foo.txt`, non? Si tu examines ce fichier, tu verras qu'il est vide.

Explication: bien que les terminaux (physiques ou virtuels) n'aient qu'un écran où afficher leurs résultats, ils disposent en réalité de deux canaux de sortie: la "sortie standard", utilisée pour le fonctionnement normal des programmes, et l'"erreur standard" ou sortie d'erreur, utilisée pour reporter des erreurs. Ces sorties sont nommées et numérotées: le numéro 1 correspond à la sortie standard (*stdout*), le numéro 2 à la sortie d'erreur (*stderr*).

L'exemple de `cat` qu'on vient de prendre provoque un affichage sur la sortie d'erreur, et c'est la seule sortie standard qui a été redirigée vers un fichier.

Pour rediriger la sortie d'erreur, il faut faire précéder le symbole `>` du numéro attribué à la sortie d'erreur, soit 2. Exemple:

```shell
cat /foo 2> /tmp/foo-err.txt
```

Cette fois, le message d'erreur ne s'affiche plus à l'écran, mais tu peux le retrouver en affichant `/tmp/foo-err.txt`.

Il est parfois pratique de rediriger la sortie d'erreur vers le périphérique nul (**ne fonctionne pas sous Windows**):

```shell
cat /foo 2> /dev/null
```

### Entrées

Nombre de commandes Unix sont faites pour traiter des données fournies en entrée. Tu vas voir ici plusieurs exemples: `cat`, `wc`, `sort`, `grep`.

#### Saisir avec

Comme tu l’as déjà vu, `cat` permet d'afficher du contenu sur la sortie standard. Ce contenu peut tout aussi bien provenir d'un fichier que de l'"entrée standard", c'est-à-dire du clavier. Il n'y a qu'une entrée, l'entrée standard *stdin*, portant le numéro 0.

Tape `cat` sans argument et valide.

Le terminal semble se bloquer: faute de lui avoir fourni un fichier d'entrée, `cat` est en attente de saisie. Écris quelques mots, valide avec entrée, et répète cette opération. Tu peux constater que chaque ligne saisie est affichée une deuxième fois après validation. Explication: la commande `cat` renvoie sur la sortie ce qu'elle reçoit en entrée. **Pour signifier la fin de la saisie**, et retrouver le contrôle de ton terminal, effectue la combinaison de touches *Ctrl+D* (le même principe s'appliquera aux commandes suivantes).

Petit exercice: lance `cat > languages.txt`, saisis quelques langages de programmation (PHP, Java, JavaScript, Python, *etc.*), chacun sur une ligne, et enfin interromps la saisie. Tu constateras que les lignes que tu saisis ne sont plus répétées: c'est normal, tu as redirigé la sortie de `cat`. Tu peux d'ailleurs afficher le fichier ainsi créé, toujours avec `cat`! Garde ce fichier pour tester la commande suivante...

#### Compter avec

Si dans la vie courante, WC peut-être assimilé à une "sortie standard", dans le monde Unix, `wc` permet de compter les lignes, mots et/ou caractères d'une chaîne d'entrée. Tu peux l'appliquer à un fichier: `wc languages.txt` affichera respectivement le nombre de lignes, de mots et de caractères contenus dans le fichier.

Lance ensuite `wc` sans option ni nom de fichier: comme pour `cat`, le terminal semble se bloquer, ce qui signifie une attente de saisie. Saisis quelques mots, n'hésite pas à passer à la ligne, puis termine la saisie avec Ctrl+D: `wc` affiche le compte de ce que tu lui as entré.

#### Trier avec

Tu peux appliquer `sort` sur un fichier: `sort languages.txt` t'affichera la liste des langages saisie précédemment, triée par ordre alphabétique.

Teste `sort` sans argument, puis saisis par exemple un prénom par ligne, sans ordre particulier, puis interromps la saisie pour obtenir la liste triée.

#### Filtrer avec

`grep` permet de filtrer une entrée, pour ne garder que les lignes contenant un certain "motif": par exemple une chaîne de caractères.

Lance `grep Java` puis saisis à nouveau des langages, chacun sur une ligne: `Java`, `JavaScript`, `PHP`, `Python`. Interromps la saisie (toujours avec *Ctrl D*).

Toutes les lignes saisies contenant `Java` sont dupliquées à l'écran: `grep` renvoie sur la sortie les lignes contenant la chaîne qu'on lui a donnée. Les autres lignes sont éliminées. `grep` effectue donc un filtrage de l'entrée et donne le résultat sur la sortie standard.

`grep`, comme les commandes précédentes, peut travailler sur un fichier.

#### Rediriger une entrée

Certaines commandes telles que `cat` ou `sort` peuvent directement agir sur un fichier donné en argument.

On peut également rediriger l'entrée standard pour leur fournir l'entrée sur laquelle travailler: c'est le symétrique de la redirection de sortie. La redirection de sortie permet d'indiquer que la sortie redirigée n'est pas l'écran mais, par exemple, un fichier; la redirection d'entrée permet d'indiquer que l'entrée standard n'est pas le clavier mais, par exemple, un fichier.

Pour rediriger l'entrée standard, en prenant le contenu de `languages.txt` comme entrée pour `wc`:

```shell
wc < languages.txt
```

Il y a peu de différences avec `wc languages.txt`, mais il est important d'au moins mentionner cet aspect avant de passer à la suite...

### Les "tubes" Unix

Tout ce que tu viens de voir amène à l'un des aspects qui rendent le shell aussi puissant: la possibilité de combiner plusieurs commandes Unix, grâce au mécanisme de "tubes" (*pipes* en anglais).

L'idée, c'est qu'il est possible de **rediriger la sortie** d'une commande, afin de **l'utiliser comme entrée** d'une autre commande. On peut utiliser ce mécanisme à la chaîne, de sorte qu'on peut effectuer des traitements complexes sur des données en une seule ligne de commande.

![](https://storage.googleapis.com/images-innoveduc/linux_terminal/unix_pipes.svg)

Si on prend cette illustration, *IN* est une donnée d'entrée (par exemple un fichier contenant des lignes de texte), *FILTER* est une commande Unix comme `grep`, `sort`, `wc`, etc.

Le "pipe" ou tube est matérialisé par la barre verticale `|` (qu'on appelle, de fait, *pipe*).

Des exemples devraient t'aider à comprendre.

#### Filtrer et compter les prénoms

Télécharge ce fichier issu d'une [plate-forme open data](https://www.data.gouv.fr/fr/datasets/liste-de-prenoms/), via l'une de ces deux commandes:

`wget https://www.data.gouv.fr/s/resources/liste-de-prenoms/20141127-154433/Prenoms.csv`

Ou

`curl https://www.data.gouv.fr/s/resources/liste-de-prenoms/20141127-154433/Prenoms.csv -o Prenoms.csv`

Tu peux en obtenir un aperçu grâce à `head` qu'on a vu précédemment (ici on utilise `-n` pour spécifier un nombre de lignes):

```shell
1
head Prenoms.csv
2
```

On obtient:

```shell
aaliyah;f;english (modern);0
    aapeli;m;finnish;0
    aapo;m;finnish;0
    aaren;m,f;english;0
    aarne;m;finnish;0
```

Les fichiers CSV sont souvent générés à partir de tableurs ou de bases de données. C'est un format pratique pour partager des informations, les importer, les exporter... Chaque ligne correspond à une ligne de tableur, et les champs sont séparés par des virgules ou points-virgules (d'où le nom CSV, *Comma-Separated Values*). Ici le 2ème champ est le genre, et il est suivi de la langue.

Si on souhaite *compter* le nombre de prénoms féminins *et* français, voici ce qu'on écrira:

```shell
1
grep "f;french" < Prenoms.csv | wc -l
2
```
- On indique à `grep` de prendre `Prenoms.csv` comme entrée, et de ne garder que les lignes contenant `f:french`.
- Le caractère pipe `|` redirige la sortie de `grep` comme entrée pour `wc`.

#### Concaténer, trier, et écrire le résultat dans un fichier

On souhaite, à partir du fichier `Prenoms.csv`, trouver tous les prénoms correspondant aux pays scandinaves (Suède, Norvège, Danemark), et les trier en ordre alphabétique.

On peut commencer par trier le fichier à plusieurs reprises avec `grep`, et rediriger le résultat vers des fichiers distincts:

```shell
1
grep swedish Prenoms.csv > Swedish.csv
2
grep danish Prenoms.csv > Danish.csv
3
grep norwegian Prenoms.csv > Norwegian.csv
4
```

Ensuite, on peut concaténer le résultat et le trier, en une seule ligne:

```shell
1
    cat Swedish.csv Danish.csv Norwegian.csv | sort -u
2
```

Essaie de voir ce qui se passe avec la même ligne si on ne fournit pas l'option `-u` (dont tu peux trouver la signification avec `man sort`).

Tu peux également rediriger le résultat de la commande vers un fichier `Scandinavian.csv`.

```shell
An Introduction to Linux I/O Redirectionhttps://www.digitalocean.com/community/tutorials/an-introduction-to-linux-i-o-redirection
```

## Challenge

### Compter les alumnis

Télécharge le fichier [wilders.csv](https://gist.githubusercontent.com/bhubr/bc3a21a0202109beeb31c4a677e0461b/raw/d8805eb82e8aabffab3b0163596c734f376617d0/wilders.csv), qui contient une liste *fictive* d'anciens élèves, au format CSV.

Il va s'agir d'effectuer des manipulations sur cette liste.

- Créer un fichier `php_france_2019.csv` contenant uniquement le *nombre* de wilders ayant fait du **PHP**, sur un campus en **France**, en **2019**.
- Créer un fichier `javascript_biarritz_toulouse.csv` contenant uniquement les wilders ayant fait du **JavaScript**, sur les campus de **Toulouse et Biarritz**. *Indice:* tu peux avoir besoin de créer des fichiers "intermédiaires", et de les concaténer.
- Combiner les commandes `history` et `tail` (en ajustant le nombre de lignes) pour produire un fichier `history.txt`, contenant les commandes que tu as saisies pour arriver aux résultats précédents.

### Critères de validation

- Avoir les trois fichiers demandés sur un Gist

Solution postée le **mercredi 22 octobre 2025**

[https://gist.github.com/LiudSwen/3338f8aee61a98efc280434d5de284be](https://gist.github.com/LiudSwen/3338f8aee61a98efc280434d5de284be)