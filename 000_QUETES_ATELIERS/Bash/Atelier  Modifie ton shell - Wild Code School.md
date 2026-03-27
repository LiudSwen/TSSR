---
title: "Atelier : Modifie ton shell - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2852/pages/13779"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
bash

## Atelier: Modifie ton shell

Facile

2h

Auto-validation

bash

## Atelier: Modifie ton shell

## Introduction

Avant les interfaces graphiques des OS, les utilisateurs se servaient de la ligne de commande pour pouvoir interagir avec les ordinateurs.  
Ces lignes de commandes sont exécutées par un interpréteur de lignes de commandes ou **shell**.  
Tu vas découvrir ici que cette connaissance est toujours utile de nos jours!

![image de la mascotte linux Tux](https://storage.googleapis.com/quest_editor_uploads/ejrFdp0UMTPlE3U3cNxGZWUGZE3QdZlm.jpg)

## 🤓 Objectifs:

✅ Exécuter des commandes dans le terminal  
✅ Changer de terminal  
✅ Modifier le terminal

## Sommaire

- [📖 Quelques définitions](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#-quelques-d%C3%A9finitions)
- [💻 Le terminal Linux](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#-le-terminal-linux)
- [💻 Lancement de lignes de commandes shell](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#-lancement-de-lignes-de-commandes-shell)
- [👉 Modification du terminal](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#-modification-du-terminal)
	- [✔️ Prérequis](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#%EF%B8%8F-pr%C3%A9requis)
		- [🔬 Changement de terminal](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#-changement-de-terminal)
- [⚙️ Customiser une commande de terminal avec eza](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#%EF%B8%8F-customiser-une-commande-de-terminal-avec-eza)
	- [Installation d'eza](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#installation-deza)
		- [Installation des polices d'icônes](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#installation-des-polices-dic%C3%B4nes)
		- [Configuration des alias](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#configuration-des-alias)
- [⚙️ Modifier le prompt](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#%EF%B8%8F-modifier-le-prompt)
	- [Modification du fichier.bashrc](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#modification-du-fichier-bashrc)
- [Conclusion](https://odyssey.wildcodeschool.com/quests/2852/pages/13779#conclusion)

## 📖 Quelques définitions

| OS | Terminal | Console | Shell | Ligne de commande |
| --- | --- | --- | --- | --- |
|  | Un terminal (parfois appelé **TTY** dans le contexte Unix) est un environnement d'entrée et de sortie. Il émule une **console** dans une interface graphique. | Une console est un dispositif d'entrée/sortie physique, souvent le terminal primaire directement connecté à une machine. | Le shell est un interpréteur de **lignes de commandes**. Il fournit des commandes pour interagir avec l'OS | Ce sont des instructions textuelles écrites dans un **terminal**. Elles sont interprétées par un **shell**. |
| Windows | Terminal Windows, PowerShell | ConHost (processus hôte de la console) | **PowerShell**, cmd | Syntaxe DOS, Syntaxe PowerShell |
| Linux | **Gnome-terminal**, Xterm, MobaXterm, Konsole,... | Terminaux virtuels (comme `/dev/tty1`, `/dev/tty2`,...) | **Bourne shell** (sh), KornShell (ksh), C shell (csh), tcsh,**bash**, Z shell (zsh),... | Commandes shell Linux |

## 💻 Le terminal Linux

Il y a plusieurs méthodes pour lancer le terminal par défaut.  
En voici une:

- Démarre Ubuntu
- Dans la fenêtre des applications, tape l'un des mots suivants pour trouver le terminal: ***Terminal***, ***Command***, ***Prompt***, ou ***Shell***.
- Lance le terminal
- La fenêtre du terminal va s'ouvrir et tu vas pouvoir exécuter des commandes

## 💻 Lancement de lignes de commandes shell

Dans ce terminal, tu peux lancer - entre autres - les types de commandes suivantes:

- Gestion du système de fichiers: `cd`, `ls`, ou `pwd`
- Manipulation de fichiers: `cp`, `rm`, ou `mkdir`
- Contenu de fichiers: `cat`, `more`, ou `less`
- Compression de données: `tar`, `gzip`
- Recherche: `grep`, `find`
- Gestion des droits: `chmod`, `chown`
- Montage: `mount`, `umount`

Écris ces différentes commandes dans le terminal avant de les exécuter, et regarde le résultat.  
Tu peux t'aider de la commande **man** pour voir le détail de chaque commande et également du site [ExplainShell](https://explainshell.com/).

> **⚠️ Attention**:  
> Certaines commandes comme `chmod` et `rm` peuvent être dangereuses si elles sont exécutées sans connaissance.  
> Utilise une VM si tu n'es pas sûr.

## 👉 Modification du terminal

### ✔️ Prérequis

Tu as besoin du matériel suivant:

- Une VM ou un hôte sous Linux

> **ℹ️ Info**:  
> Les expérimentations pratiques ont été testées avec un OS Linux Ubuntu 22.04 LTS installé dans une machine virtuelle VirtualBox 7.0 tournant sur un système hôte Ubuntu 22.04 LTS.  
> Elles peuvent être reproduites avec d'autres distributions Linux, sur d'autres environnements, mais des différences peuvent alors apparaître.

> **⚠️ Attention**:  
> Si tu ne maîtrises pas ton OS, les modifications effectuées ici peuvent amener des dysfonctionnements sur ton ordinateur.  
> Pour plus de sécurité, utilise une machine virtuelle.

### 🔬 Changement de terminal

Une autre méthode pour ouvrir le terminal par défaut consiste à appuyer sur les touches Ctrl + Alt + T.  
Essaye pour voir!

Installons **Tilix** qui est un autre terminal.

> **ℹ️ Info**:  
> Sur les systèmes unix, on peut installer plusieurs interfaces, ainsi que plusieurs terminaux.

Écris les lignes de commandes suivantes dans un terminal:

```bash
1
sudo apt update && sudo apt upgrade -y
2
sudo apt install tilix -y
```

Lance-le en tapant `tilix` dans un terminal.  
Ferme-le et essaye de le relancer avec Ctrl + Alt + T. Que se passe-t-il?

Tilix n'est pas le terminal par défaut, donc c'est **gnome-terminal** qui se lance.  
Tu pourras lancer le terminal **Tilix** en cherchant **"tilix"** dans le menu des applications.

## ⚙️ Customiser une commande de terminal avec eza

Nous allons utiliser **eza**, une alternative moderne à `ls`.

### Installation d'eza

```bash
1
# Ajouter le dépôt et installer eza
2
sudo mkdir -p /etc/apt/keyrings
3
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.amd64.repo | sudo tee /etc/apt/keyrings/gierens.asc
4
sudo chmod 644 /etc/apt/keyrings/gierens.asc
5
sudo sh -c 'echo "deb [signed-by=/etc/apt/keyrings/gierens.asc] http://deb.gierens.de stable main" > /etc/apt/sources.list.d/eza.list'
6
sudo apt update
7
sudo apt install -y eza
```

### Installation des polices d'icônes

```bash
1
sudo apt install fonts-font-awesome -y
```

### Configuration des alias

Éditez le fichier `.bashrc`:

```bash
1
# Commentez les anciens alias ls
2
# alias ll='ls -alF'
3
# alias la='ls -A'
4
# alias l='ls -CF'
5

6
# Ajoutez les nouveaux alias eza
7
alias l='eza --icons --color=always --group-directories-first'
8
alias ll='eza -alF --icons --color=always --group-directories-first'
9
alias la='eza -a --icons --color=always --group-directories-first'
10
alias l.='eza -a | egrep "^\."'
11
alias lt='eza --tree --icons --color=always'
```

Rechargez la configuration avec:

```bash
1
source ~/.bashrc
```

## ⚙️ Modifier le prompt

Le prompt standard d'un terminal est sous la forme:

```bash
1
user@host:path$
```

Explication:

- `user`: le nom d'utilisateur actuel
- `@`: Caractère séparateur
- `host`: le nom d'hôte de la machine
- `:`: Caractère séparateur
- `path`: le chemin du répertoire actuel
- `$`: indicateur de fin de prompt

### Modification du fichier.bashrc

1. Faites une copie de sauvegarde:
```bash
1
cp ~/.bashrc ~/.bashrcSave
```
1. Modifiez la ligne PS1:
```bash
1
# Commentez la ligne originale
2
# PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
3

4
# Ajoutez votre nouvelle ligne de prompt (exemple avec un emoji)
5
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\](\[\033[01;34m\]\u💀️\h\[\033[01;32m\])-[\[\033[01;37m\]\w\[\033[01;32m\]]\[\033[01;34m\]\$ '
```

> **🔗 Ressources utiles**:
> 
> - [Codes couleurs du prompt](https://grawok.wordpress.com/2011/08/03/terminal-changer-la-couleur-du-prompt/)
> - [Bibliothèque d'émojis](https://emojipedia.org/)

## Conclusion

En suivant cet atelier, tu as pu découvrir comment personnaliser et améliorer ton expérience de terminal Linux, en utilisant des outils modernes comme `eza` et en personnalisant ton prompt.

**Amusez-vous bien avec votre nouveau terminal!** 🚀🐧

Quête terminée le **lundi 27 octobre 2025**