---
title: "Atelier - Scripts Bash 2 - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3958/pages/18597"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
bash

## Atelier - Scripts Bash 2

Moyen

2h

Auto-validation

bash

## Atelier - Scripts Bash 2

## Objectif du script

Créer un script qui attend une valeur de l'utilisateur.  
Tant que cette valeur n'est pas le mot `exit`, le script redemande une valeur.

## Contraintes

- La valeur `exit` est stockée dans une variable `$bonneValeur`
- Au début du script est affiché:
```shell
Début du jeu
```
- Àchaque fois qu'une valeur fausse est données, le message suivant s'affiche:
```shell
La valeur <valeur> n'est pas la bonne
```
- Le script se termine uniquement lorsque la valeur **exit** est donnée
- La valeur est stockée dans la variable `$valeur`
- Avant de se fermer, le script affiche:
```shell
Bravo tu as trouvé la valeur $bonneValeur !
```

## Aide

- Tu peux utiliser la boucle `while`.
- La commande `read` sert à enregistrer une valeur demandée à l'utilisateur dans une variable.
	- Sous la forme `read -p "<Message>" <Variable>` elle affiche un `<Message>` et enregistre la valeur donnée par l'utilisateur dans la variable `<Variable>`.
```shell
Attention, avec la commande read le nom de la variable n'a pas de $.
```

Quête terminée le **jeudi 13 novembre 2025**