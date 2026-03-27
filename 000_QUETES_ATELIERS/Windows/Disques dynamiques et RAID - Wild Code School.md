---
title: "Disques dynamiques et RAID - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2291/pages/8097"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Windows

## Disques dynamiques et RAID

Exploration des mécanismes de RAID logiciel sous Windows

Facile

3h

Auto-validation

Windows

## Disques dynamiques et RAID

## Introduction

Cette quête explore les mécanismes RAID disponibles sur les systèmes Windows.

```shell
Les expérimentations pratiques ont été testées sur un Windows Server 2022 installé dans une machine virtuelle VirtualBox 6.1 tournant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites avec d'autres versions de Windows, Server ou non, sur d'autres environnement, mais des différences peuvent alors apparaître.
```

![Windows Server 2022 background](https://storage.googleapis.com/quest_editor_uploads/A4jpm2Mz4O1D8pgKRFmVkhxFoB5DE0JP.png)

## 🤓 Objectifs:

✅ Comprendre les différents niveaux de RAID classiques  
✅ Savoir déployer du RAID logiciel sous Windows grâce aux disques dynamiques  
✅ Expérimenter et tester

## Sommaire

- [👉 Une courte introduction aux RAID](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#-une-courte-introduction-aux-raid)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#-quiz)
- [👉 Les disques dynamiques sous Windows](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#-les-disques-dynamiques-sous-windows)
	- [Environnement de test](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#environnement-de-test)
		- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#-exercice)
		- [Création d'un RAID 1](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#cr%C3%A9ation-dun-raid-1)
				- [Dépôt d'un fichier de test](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#d%C3%A9p%C3%B4t-dun-fichier-de-test)
				- [Simulation d'une panne](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#simulation-dune-panne)
				- [Vérification de la tolérance aux pannes](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#v%C3%A9rification-de-la-tol%C3%A9rance-aux-pannes)
				- [Reconstruction du RAID](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#reconstruction-du-raid)
		- [🔬 Exercices complémentaires](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#-exercices-compl%C3%A9mentaires)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2291/pages/8097#%EF%B8%8F-r%C3%A9sum%C3%A9)

## 👉 Une courte introduction aux RAID

RAID consiste en un ensemble de techniques de virtualisation du stockage permettant d'en améliorer les performances et/ou de tolérer des pannes de disques.

```shell
Le RAID sur WikipediAPour en apprendre un peu plus sur le RAID, tu peux consulter cette page WikipediAhttps://fr.wikipedia.org/wiki/RAID_(informatique)
```

La vidéo suivante constitue une bonne illustration des différents types de RAID.

## 📝 Quiz

Vérifie que tu as bien compris en répondant à ces quelques questions. Plusieurs bonnes réponses sont possibles pour chaque question.

```shell
# 1  - Le RAID 0 permet :Un gain de performanceDe la tolérance de panneD'avoir autant d'espace de stockage que la somme des disques utilisésValider# 2 Un gain de performanceDe la tolérance de panneD'avoir autant d'espace de stockage que la somme des disques utilisésValider# 3 Un gain de performanceDe la tolérance de panneD'avoir autant d'espace de stockage que la somme des disques utilisésValider# 4 RAID 0RAID 1RAID 5ValiderTon score :0 / 4
```

---

## 👉 Les disques dynamiques sous Windows

Windows propose une implémentation de RAID logicielle à l'aide de **disques dynamiques**.

Il offre la possibilité de faire du RAID 0 (*striping*), du RAID 1 (*mirroring*) et du RAID 5.

Le démarrage du système sur un disque dynamique n'est pas possible. Le disque système, celui sur lequel Windows est installé, ne peut donc pas être un disque dynamique.

```shell
Les disques dynamiques sont disponibles à partir de Windows 2000.

Tous les niveaux de RAID peuvent ne pas être disponibles sur toutes les versions de Windows.
```

La gestion des disques dynamiques est possible à partir de l'élément **Gestion des disques** de l'outil **Gestion de l'ordinateur**

![Caputre d'écran de l'outil de gestion de disques Windows](https://storage.googleapis.com/quest_editor_uploads/sqCnmcof8vrSuET5OvtNKltwZRwtAYCH.png)

Les disques non encore utilisés peuvent être convertis en disques dynamiques et utilisés pour créer:

- Un nouveau volume agrégé par bandes (un RAID 0)
- Un nouveau volume en miroir (un RAID 1)
- Un nouveau volume RAID-5

Ces actions sont accessibles soit via le menu contextuel (clic droit) d'un disque disponible

![Menu contextuel d'un disque sous Windows](https://storage.googleapis.com/quest_editor_uploads/T9o0ZeFhLJn5GoKEja2AtFhR1IznjqCZ.png)

Soit via l'option **Toutes les tâches** du menu général **Action** à condition qu'un disque disponible soit sélectionné.

![Menu action de la Gestion d'ordinateur Windows](https://storage.googleapis.com/quest_editor_uploads/Wochj6EJ6tv1NIbFJYCUO8FQFEXVYqYx.png)

## Environnement de test

Pour pouvoir expérimenter sereinement, il est préférable de travailler sur une machine dédiée au test.

Il est ainsi possible de la redémarrer, reconfigurer voir casser sans impact sur les utilisateurs.

Une stratégie courante est de s'appuyer sur des machines virtuelles.

L'expérimentation qui suit nécessite un minimum de 4 disques:

- Un disque *système* pour l'installation de Windows, donc suffisamment grand pour accueillir le système et avoir un peu d'espace de travail (de l'ordre de quelques dizaines de Gio)
- 3 disques qui serviront de disques dynamiques. Ces disques peuvent être assez petits puisqu'ils ne stockeront pas réellement de données.

Ces disques peuvent être des disques virtuels.

## 🔬 Exercice

### Création d'un RAID 1

Commence par créer un volume RAID 1 avec 2 disques.

### Dépôt d'un fichier de test

Sur le volume ainsi créé, ajoute un fichier quelconque (par exemple un fichier texte contenant le message "Je suis un fichier stocké sur un RAID 1")

Ce fichier devrait donc rester accessible si l'un des 2 disques est défaillant.

### Simulation d'une panne

Test cette possibilité en retirant un des 2 disques.

> Sur **VirtualBox** cette manipulation peut-être faite via l'interface graphique (Option **Stockage** dans la **Configuration** de la VM), à condition d'éteindre la machine. En effet, l'interface graphique permet de choisir la configuration au démarrage de la VM.
> 
> Il est aussi possible de supprimer un disque en ligne (c'est à dire sans éteindre la VM) avec la ligne de commande **VirtualBox**.
> 
> La commande `VBoxManage showvminfo` permet d'obtenir toutes les informations concernant une VM.  
> Les informations concernant le *Storage Controller* utilisé ainsi que le port et l'identifiant `UUID` de chaque disque virtuel sont nécessaires pour la commande suivante.

```bash
1
wilder@ubuntu:~$ VBoxManage showvminfo "Windows Server 2022"
2
Name:                        Windows Server 2022
3
Groups:                      /
4
Guest OS:                    Other Windows (64-bit)
5

6
[...]
7

8
Storage Controller Name (0):            IDE
9
Storage Controller Type (0):            PIIX4
10
Storage Controller Instance Number (0): 0
11
Storage Controller Max Port Count (0):  2
12
Storage Controller Port Count (0):      2
13
Storage Controller Bootable (0):        on
14
Storage Controller Name (1):            AHCI
15
Storage Controller Type (1):            IntelAhci
16
Storage Controller Instance Number (1): 0
17
Storage Controller Max Port Count (1):  30
18
Storage Controller Port Count (1):      4
19
Storage Controller Bootable (1):        on
20
IDE (0, 0): /home/wilder/VirtualBox VMs/Windows Server 2022/Snapshots/{dfd21cc4-b6ca-4feb-b920-0722f782de3c}.vdi (UUID: dfd21cc4-b6ca-4feb-b920-0722f782de3c) (non-rotational (SSD))
21
IDE (1, 0): Empty
22
AHCI (0, 0): /home/wilder/VirtualBox VMs/Windows Server 2022/Snapshots/{6c93dd86-6e51-4153-8797-ffc365faefca}.vdi (UUID: 6c93dd86-6e51-4153-8797-ffc365faefca) (hot-pluggable) (non-rotational (SSD))
23
AHCI (1, 0): /home/wilder/VirtualBox VMs/Windows Server 2022/Snapshots/{b7dc4a1c-4a38-4b36-b089-d203f158f002}.vdi (UUID: b7dc4a1c-4a38-4b36-b089-d203f158f002) (hot-pluggable) (non-rotational (SSD))
24
AHCI (2, 0): /home/wilder/VirtualBox VMs/Windows Server 2022/Snapshots/{a64481d8-acef-4eb8-b7ca-61e046f2284b}.vdi (UUID: a64481d8-acef-4eb8-b7ca-61e046f2284b) (hot-pluggable) (non-rotational (SSD))
25

26
[...]
27

28
wilder@ubuntu:~$ 
29
```

> On voit ainsi que cette VM, nommée `Windows Server 2022`, dispose de 2 contrôleurs de disques
> 
> - Un contrôleur `0` nommé `IDE`
> - Un contrôleur `1` nommé `AHCI`
> 
> Le contrôleur `AHCI` a 4 ports et sur les 3 premiers, on trouve un disque:
> 
> - Un disque d'UUID `6c93dd86-6e51-4153-8797-ffc365faefca` sur le port `0`
> - Un disque d'UUID `b7dc4a1c-4a38-4b36-b089-d203f158f002` sur le port `1`
> - Un disque d'UUID `a64481d8-acef-4eb8-b7ca-61e046f2284b` sur le port `2`
> 
> Chaque port du contrôleur n'est connecté qu'à 1 disque, mais il pourrait y en avoir plusieurs sur certains contrôleurs, ce qui explique le second 0 dans `AHCI (X, 0)`.
> 
> Muni de ces informations, il est possible de connecter ou déconnecter des disques avec la commande `VBoxManage storageattach`
> 
> Par exemple, pour déconnecter le premier des 3 disques précédents, sur le port 0 donc, on indique à VirtualBox qu'on souhaite le remplacer par un medium: `none` avec la commande suivante:

```shell
1

2
wilder@ubuntu:~$ VBoxManage storageattach "Windows Server 2022" --storagectl AHCI --port 0 --medium none
3
```

> Pour reconnecter le disque, on utilise la même commande, toujours en précisant la VM, le contrôleur disque et le port, mais en précisant en plus le type `hdd` et le **UUID** du disque en medium.

```shell
1

2
wilder@ubuntu:~$ VBoxManage storageattach "Windows Server 2022" --storagectl AHCI --port 0 --type hdd --medium 6c93dd86-6e51-4153-8797-ffc365faefca
3
```
```shell
La documentation VirtualBoxPlus de détail sur l'utilisation de VirtualBox en ligne de commande sur la doc officielle.https://www.virtualbox.org/manual/ch08.html#vboxmanage-storageattach
```

### Vérification de la tolérance aux pannes

Une fois le disque retiré, vérifie que ton fichier est toujours présent, que tu peux y accéder et même le modifier ou ajouter d'autres fichiers.

Windows nous indique néanmoins dans la gestion de disques que la situation n'est pas normale en notant **Échec de la redondance** sur le disque restant et en indiquant l'autre disque comme manquant.

En effet, la perte du second disque entraînerait cette fois-ci la perte des données.

### Reconstruction du RAID

Reconnecte le disque retiré ou ajoute un nouveau disque de remplacement et remet le RAID en état dans l'interface de gestion de disques.

À noter que:

- Pour remplacer le disque manquant par un nouveau disque, il est nécessaire de **Supprimer le disque miroir...** puis d' **Ajouter un disque miroir...** en choisisant le nouveau disque.
- La reconnexion du disque retiré fait apparaître un disque **Étranger**. Windows détecte que le disque contient un volume RAID, mais ne le rend pas disponible immédiatement. Il est nécessaire de l'importer pour le rendre disponible sur ce système, comme ce serait nécessaire pour un disque qui proviendrait d'une autre machine. On a alors 2 copies indépendantes.
- Un moment de reconstruction est nécessaire à la recopie des informations sur l'autre disque. Ce temps peut être très long dans le cas d'un disque concernant beaucoup de données. Windows nous indique dans la gestion de disques: **Resynchronisation en cours**.

## 🔬 Exercices complémentaires

Procède maintenant au même genre de tests avec un RAID 5 et un RAID 0.

---

## ☝️ Résumé

Tu sais maintenant configurer des volumes RAID sur un système Windows.

Si tu as bien compris le fonctionnement et testé plusieurs cas de figure, tu peux maintenant valider cette quête.

Quête terminée le **lundi 19 janvier 2026**