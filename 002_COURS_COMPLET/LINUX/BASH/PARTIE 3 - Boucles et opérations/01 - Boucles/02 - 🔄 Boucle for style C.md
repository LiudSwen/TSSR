

## 📑 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 2 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## Introduction

La boucle `for` style C en Bash permet d'utiliser une syntaxe similaire au langage C pour itérer. Cette syntaxe est particulièrement utile pour les développeurs familiers avec C, C++, Java ou JavaScript, et offre un contrôle précis sur l'initialisation, la condition et l'incrémentation.

> [!info] Pourquoi utiliser le style C ?
> 
> - Syntaxe familière pour les développeurs venant d'autres langages
> - Contrôle granulaire sur les itérations
> - Idéal pour les boucles numériques avec compteur
> - Permet des incrémentations complexes (pas de 2, 3, etc.)

> [!warning] Disponibilité Cette syntaxe nécessite Bash 2.04 ou supérieur. Elle n'est pas disponible dans le shell Bourne classique (`sh`).

---

## Syntaxe de base

La structure générale d'une boucle `for` style C suit cette forme :

```bash
for (( initialisation; condition; incrémentation ))
do
    # Corps de la boucle
    commandes
done
```

Voici un exemple concret :

```bash
#!/bin/bash

for (( i=0; i<5; i++ ))
do
    echo "Itération numéro $i"
done
```

**Sortie :**

```
Itération numéro 0
Itération numéro 1
Itération numéro 2
Itération numéro 3
Itération numéro 4
```

> [!example] Syntaxe compacte Pour une seule commande, on peut écrire sur une ligne :
> 
> ```bash
> for (( i=0; i<5; i++ )); do echo "Valeur: $i"; done
> ```

### Structure des doubles parenthèses `(( ))`

Les doubles parenthèses permettent d'effectuer des opérations arithmétiques. À l'intérieur :

- **Pas besoin du `$`** pour accéder aux variables
- Évaluation arithmétique automatique
- Utilisation d'opérateurs C standard

```bash
# Correct - sans $
for (( i=0; i<10; i++ ))

# Fonctionne aussi, mais redondant
for (( i=0; $i<10; i++ ))
```

---

## Initialisation du compteur

L'initialisation définit la valeur de départ du compteur avant la première itération.

### Syntaxe d'initialisation

```bash
for (( variable=valeur; condition; incrémentation ))
```

### Exemples d'initialisation

```bash
# Démarrer à 0
for (( i=0; i<5; i++ )); do echo $i; done

# Démarrer à 1
for (( count=1; count<=10; count++ )); do echo $count; done

# Démarrer à une valeur négative
for (( n=-5; n<=5; n++ )); do echo $n; done

# Initialiser avec une variable
debut=10
for (( i=debut; i<20; i++ )); do echo $i; done
```

### Initialisations multiples

Bash permet d'initialiser plusieurs variables séparées par des virgules :

```bash
#!/bin/bash

# Deux compteurs simultanés
for (( i=0, j=10; i<5; i++, j-- ))
do
    echo "i=$i, j=$j"
done
```

**Sortie :**

```
i=0, j=10
i=1, j=9
i=2, j=8
i=3, j=7
i=4, j=6
```

> [!tip] Usage pratique Les initialisations multiples sont utiles pour parcourir des structures symétriques ou inverses.

---

## Condition de continuation

La condition détermine si la boucle doit continuer. Elle est évaluée **avant** chaque itération.

### Opérateurs de comparaison

Dans les doubles parenthèses, on utilise les opérateurs arithmétiques standards :

|Opérateur|Signification|
|---|---|
|`<`|Strictement inférieur|
|`<=`|Inférieur ou égal|
|`>`|Strictement supérieur|
|`>=`|Supérieur ou égal|
|`==`|Égal|
|`!=`|Différent|

```bash
# Tant que i est strictement inférieur à 10
for (( i=0; i<10; i++ ))

# Tant que i est inférieur ou égal à 10
for (( i=0; i<=10; i++ ))

# Tant que i est différent de 5
for (( i=0; i!=5; i++ ))

# Tant que i est supérieur à 0
for (( i=10; i>0; i-- ))
```

### Conditions complexes

On peut combiner plusieurs conditions avec les opérateurs logiques :

```bash
# ET logique : &&
for (( i=0; i<10 && i!=5; i++ ))
do
    echo $i
done

# OU logique : ||
for (( i=0; i<5 || i>10; i++ ))
do
    echo $i
done
```

> [!warning] Attention aux boucles infinies Une condition toujours vraie crée une boucle infinie :
> 
> ```bash
> # BOUCLE INFINIE - À ÉVITER
> for (( i=0; i>=0; i++ ))
> do
>     echo $i  # Ne s'arrêtera jamais
> done
> ```

### Condition basée sur une variable externe

```bash
#!/bin/bash

limit=100

for (( i=0; i<limit; i+=10 ))
do
    echo "Progression : $i%"
done
```

---

## Incrémentation

L'incrémentation modifie le compteur **après** chaque itération.

### Types d'incrémentation

```bash
# Incrémentation de 1
for (( i=0; i<10; i++ ))

# Décrémentation de 1
for (( i=10; i>0; i-- ))

# Incrémentation de 2
for (( i=0; i<10; i+=2 ))

# Incrémentation de 5
for (( i=0; i<100; i+=5 ))

# Multiplication par 2
for (( i=1; i<1000; i*=2 ))

# Incrémentation avec variable
pas=3
for (( i=0; i<20; i+=pas ))
```

### Opérateurs d'incrémentation

|Opérateur|Signification|Exemple|
|---|---|---|
|`i++`|Incrémenter de 1|`i = i + 1`|
|`i--`|Décrémenter de 1|`i = i - 1`|
|`i+=n`|Ajouter n|`i = i + n`|
|`i-=n`|Soustraire n|`i = i - n`|
|`i*=n`|Multiplier par n|`i = i * n`|
|`i/=n`|Diviser par n|`i = i / n`|
|`i%=n`|Modulo n|`i = i % n`|

### Exemples pratiques

```bash
# Compter de 2 en 2
for (( i=0; i<=20; i+=2 ))
do
    echo "Nombre pair : $i"
done

# Puissances de 2
for (( i=1; i<=128; i*=2 ))
do
    echo "Puissance de 2 : $i"
done

# Compte à rebours
for (( i=10; i>=0; i-- ))
do
    echo "$i..."
    sleep 1
done
echo "Décollage !"
```

### Incrémentations multiples

```bash
#!/bin/bash

# Plusieurs variables incrémentées
for (( i=0, j=100; i<10; i++, j-=10 ))
do
    echo "i=$i, j=$j, somme=$((i+j))"
done
```

> [!tip] Incrémentation dynamique L'incrémentation peut dépendre de la valeur actuelle :
> 
> ```bash
> for (( i=1; i<100; i+=i ))
> do
>     echo $i  # 1, 2, 4, 8, 16, 32, 64
> done
> ```

---

## Comparaison avec le for classique

Bash propose deux syntaxes de boucle `for` : le style classique et le style C. Voici leurs différences.

### For classique (itération sur liste)

```bash
# Syntaxe
for variable in liste
do
    commandes
done

# Exemples
for fichier in *.txt
do
    echo "Fichier : $fichier"
done

for mot in un deux trois
do
    echo $mot
done

for numero in {1..10}
do
    echo $numero
done
```

### For style C (contrôle numérique)

```bash
# Syntaxe
for (( init; condition; increment ))
do
    commandes
done

# Exemples
for (( i=0; i<10; i++ ))
do
    echo $i
done
```

### Tableau comparatif

|Critère|For classique|For style C|
|---|---|---|
|**Usage principal**|Itérer sur des listes, fichiers, chaînes|Boucles numériques avec compteur|
|**Syntaxe**|`for var in liste`|`for (( init; cond; incr ))`|
|**Contrôle**|Limité (suit la liste)|Précis (init, condition, incr)|
|**Incrémentation**|Automatique (élément suivant)|Personnalisable|
|**Familiarité**|Syntaxe Unix/Shell|Syntaxe C/Java/JavaScript|
|**Expansion**|Oui (*, {}, variables)|Non (arithmétique pure)|
|**Performance**|Rapide pour listes|Rapide pour calculs|

### Quand utiliser chaque syntaxe ?

> [!info] Utiliser le **for classique** pour :
> 
> - Parcourir des fichiers : `for f in *.log`
> - Itérer sur des mots : `for mot in $phrase`
> - Utiliser des expansions : `for i in {1..100}`
> - Traiter des tableaux : `for element in "${array[@]}"`

> [!info] Utiliser le **for style C** pour :
> 
> - Boucles avec compteur numérique précis
> - Incrémentations personnalisées (pas de 2, 3, etc.)
> - Conditions arithmétiques complexes
> - Code lisible pour les développeurs C/Java
> - Plusieurs compteurs simultanés

### Exemples de conversion

```bash
# For classique avec {1..10}
for i in {1..10}
do
    echo $i
done

# Équivalent en style C
for (( i=1; i<=10; i++ ))
do
    echo $i
done
```

```bash
# For classique avec seq
for i in $(seq 0 2 20)  # De 0 à 20, pas de 2
do
    echo $i
done

# Équivalent en style C (plus efficace)
for (( i=0; i<=20; i+=2 ))
do
    echo $i
done
```

> [!tip] Performance Le for style C est généralement plus performant pour les boucles numériques car il n'a pas besoin de générer une liste en mémoire.

---

## Pièges courants

### 1. Oublier les doubles parenthèses

```bash
# ❌ INCORRECT - Erreur de syntaxe
for ( i=0; i<10; i++ )

# ✅ CORRECT
for (( i=0; i<10; i++ ))
```

### 2. Utiliser des crochets [ ] au lieu de (( ))

```bash
# ❌ INCORRECT - Syntaxe de test, pas de boucle
for [ i=0; i<10; i++ ]

# ✅ CORRECT
for (( i=0; i<10; i++ ))
```

### 3. Utiliser $ inutilement dans (( ))

```bash
# ⚠️ Fonctionne mais redondant
for (( i=0; $i<10; i++ ))

# ✅ MEILLEUR
for (( i=0; i<10; i++ ))
```

> [!warning] Exception Le `$` est nécessaire **en dehors** des doubles parenthèses :
> 
> ```bash
> for (( i=0; i<10; i++ ))
> do
>     echo $i  # $ nécessaire ici
> done
> ```

### 4. Confondre = et == dans la condition

```bash
# ❌ INCORRECT - Assigne 5 à i au lieu de comparer
for (( i=0; i=5; i++ ))  # Toujours vrai, boucle infinie

# ✅ CORRECT - Compare i à 5
for (( i=0; i==5; i++ ))  # Jamais vrai, n'exécute pas

# ✅ CORRECT - Usage normal
for (( i=0; i<5; i++ ))
```

### 5. Division entière inattendue

```bash
#!/bin/bash

# La division est entière, pas décimale
for (( i=0; i<10; i+=0.5 ))  # ❌ Erreur : décimales non supportées
do
    echo $i
done

# Solution : multiplier par 10
for (( i=0; i<100; i+=5 ))
do
    echo "$(( i/10 )).$(( i%10 ))"  # Affiche 0.0, 0.5, 1.0, etc.
done
```

### 6. Oublier d'incrémenter (boucle infinie)

```bash
# ❌ BOUCLE INFINIE - Pas d'incrémentation
for (( i=0; i<10; ))
do
    echo $i  # Affiche toujours 0
done

# ✅ CORRECT
for (( i=0; i<10; i++ ))
do
    echo $i
done
```

### 7. Portée des variables

```bash
#!/bin/bash

i=999

for (( i=0; i<5; i++ ))
do
    echo "Dans la boucle : $i"
done

echo "Après la boucle : $i"  # Affiche 5, pas 999
```

> [!warning] Attention Contrairement à certains langages, la variable de boucle **n'est pas** locale à la boucle en Bash.

---

## Bonnes pratiques

### 1. Noms de variables explicites

```bash
# ❌ Peu clair
for (( i=0; i<100; i++ ))

# ✅ Plus clair
for (( compteur=0; compteur<100; compteur++ ))
for (( fichier_index=0; fichier_index<total_fichiers; fichier_index++ ))
```

### 2. Extraire les limites dans des variables

```bash
#!/bin/bash

# ❌ Nombre magique
for (( i=0; i<1000; i++ ))
do
    traiter_donnee $i
done

# ✅ Variable nommée
max_iterations=1000
for (( i=0; i<max_iterations; i++ ))
do
    traiter_donnee $i
done
```

### 3. Ajouter des commentaires pour les boucles complexes

```bash
#!/bin/bash

# Parcours des fichiers par blocs de 10
debut=0
fin=100
pas=10

for (( i=debut; i<fin; i+=pas ))
do
    # Traitement d'un bloc de fichiers
    echo "Traitement des fichiers $i à $((i+pas-1))"
done
```

### 4. Vérifier les entrées utilisateur

```bash
#!/bin/bash

read -p "Nombre d'itérations : " nb_iterations

# Validation
if ! [[ "$nb_iterations" =~ ^[0-9]+$ ]]; then
    echo "Erreur : nombre entier requis"
    exit 1
fi

for (( i=0; i<nb_iterations; i++ ))
do
    echo "Itération $i"
done
```

### 5. Utiliser des fonctions pour les boucles complexes

```bash
#!/bin/bash

traiter_batch() {
    local debut=$1
    local fin=$2
    
    for (( i=debut; i<fin; i++ ))
    do
        echo "Traitement de l'élément $i"
        # Logique complexe ici
    done
}

# Appel propre
traiter_batch 0 100
traiter_batch 100 200
```

---

## Astuces avancées

### 1. Boucles imbriquées

```bash
#!/bin/bash

# Table de multiplication
for (( i=1; i<=10; i++ ))
do
    for (( j=1; j<=10; j++ ))
    do
        resultat=$((i * j))
        printf "%4d" $resultat
    done
    echo ""  # Nouvelle ligne
done
```

### 2. Break et continue

```bash
#!/bin/bash

# Break : sortir de la boucle
for (( i=0; i<100; i++ ))
do
    if (( i == 50 )); then
        echo "Arrêt à 50"
        break
    fi
    echo $i
done

# Continue : passer à l'itération suivante
for (( i=0; i<20; i++ ))
do
    if (( i % 2 == 0 )); then
        continue  # Saute les nombres pairs
    fi
    echo "Impair : $i"
done
```

### 3. Boucle sans corps

```bash
#!/bin/bash

# Calculer la somme de 1 à 100 sans corps
somme=0
for (( i=1, somme=0; i<=100; somme+=i, i++ )); do :; done
echo "Somme : $somme"

# Ou plus lisible avec un corps minimal
somme=0
for (( i=1; i<=100; i++ ))
do
    ((somme += i))
done
echo "Somme : $somme"
```

### 4. Accès aux arguments du script

```bash
#!/bin/bash

# Parcourir tous les arguments numériquement
for (( i=1; i<=$#; i++ ))
do
    echo "Argument $i : ${!i}"
done
```

### 5. Barre de progression

```bash
#!/bin/bash

total=50

for (( i=0; i<=total; i++ ))
do
    # Calcul du pourcentage
    pourcent=$((i * 100 / total))
    
    # Affichage de la barre
    printf "\rProgression : [%-50s] %d%%" \
           "$(printf '#%.0s' $(seq 1 $i))" \
           "$pourcent"
    
    sleep 0.1
done

echo -e "\n✅ Terminé !"
```

### 6. Traitement en parallèle (concept avancé)

```bash
#!/bin/bash

# Lancer plusieurs processus en arrière-plan
max_jobs=5

for (( i=0; i<20; i++ ))
do
    # Attendre si trop de processus actifs
    while (( $(jobs -r | wc -l) >= max_jobs ))
    do
        sleep 0.1
    done
    
    # Lancer le traitement en arrière-plan
    {
        echo "Traitement de $i"
        sleep 1
    } &
done

# Attendre tous les processus
wait
echo "Tous les traitements terminés"
```

### 7. Boucle infinie avec condition de sortie

```bash
#!/bin/bash

# Boucle infinie avec mécanisme d'arrêt
tentatives=0
max_tentatives=5

for (( ;; ))  # Boucle infinie
do
    ((tentatives++))
    
    if commande_peut_echouer; then
        echo "Succès !"
        break
    fi
    
    if (( tentatives >= max_tentatives )); then
        echo "Échec après $max_tentatives tentatives"
        exit 1
    fi
    
    echo "Tentative $tentatives échouée, nouvelle tentative..."
    sleep 2
done
```

---

> [!tip] 💡 Résumé La boucle `for` style C offre un contrôle précis sur les itérations numériques. Privilégiez-la pour les compteurs et les calculs arithmétiques, et utilisez le for classique pour parcourir des listes ou fichiers. Maîtriser les deux syntaxes vous rendra plus efficace en scripting Bash.