

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

## 🎯 Introduction

La commande `sort` est un outil fondamental sous Linux qui permet de **trier les lignes d'un fichier ou d'une entrée standard**. Elle est omniprésente dans les scripts shell et les pipelines de traitement de données.

> [!info] Pourquoi utiliser `sort` ?
> 
> - Organiser des données pour les rendre lisibles
> - Préparer des données avant traitement (par exemple avec `uniq`)
> - Analyser des logs en classant par date, taille, ou autre critère
> - Générer des rapports triés

---

## 📝 Syntaxe de base

```bash
sort [OPTIONS] [FICHIER...]
```

> [!example] Utilisation simple
> 
> ```bash
> # Trier le contenu d'un fichier
> sort fichier.txt
> 
> # Trier l'entrée standard (pipeline)
> cat fichier.txt | sort
> 
> # Trier plusieurs fichiers ensemble
> sort fichier1.txt fichier2.txt
> ```

---

## 🔤 Tri alphabétique (par défaut)

Par défaut, `sort` effectue un **tri lexicographique** (ordre alphabétique) en comparant les caractères ligne par ligne.

```bash
# Fichier: noms.txt
# Charlie
# Alice
# Bob

sort noms.txt
# Résultat:
# Alice
# Bob
# Charlie
```

> [!info] Comment fonctionne le tri par défaut ?
> 
> - Comparaison caractère par caractère selon l'ordre ASCII/UTF-8
> - Les majuscules viennent avant les minuscules dans l'ordre ASCII
> - Les espaces et caractères spéciaux sont pris en compte

> [!example] Comportement avec les majuscules/minuscules
> 
> ```bash
> # Fichier: mixed.txt
> # banana
> # Apple
> # cherry
> # Banana
> 
> sort mixed.txt
> # Résultat:
> # Apple
> # Banana
> # banana
> # cherry
> ```

> [!tip] Tri insensible à la casse Utilisez l'option `-f` (ou `--ignore-case`) pour ignorer la différence majuscules/minuscules :
> 
> ```bash
> sort -f mixed.txt
> # Résultat:
> # Apple
> # banana
> # Banana
> # cherry
> ```

---

## 🔢 Option `-n` : Tri numérique

L'option `-n` (ou `--numeric-sort`) permet de trier des nombres selon leur **valeur numérique** plutôt que lexicographiquement.

> [!warning] Piège du tri alphabétique des nombres Sans `-n`, les nombres sont triés comme des chaînes de caractères :
> 
> ```bash
> # Fichier: nombres.txt
> # 100
> # 20
> # 3
> 
> sort nombres.txt
> # Résultat INCORRECT:
> # 100
> # 20
> # 3
> # (car "1" < "2" < "3" en ASCII)
> ```

```bash
# Tri numérique correct
sort -n nombres.txt
# Résultat:
# 3
# 20
# 100
```

> [!example] Cas d'usage pratique
> 
> ```bash
> # Trier un fichier de logs par taille de fichier
> ls -l | tail -n +2 | sort -k5 -n
> 
> # Trier des adresses IP par le dernier octet
> sort -t. -k4 -n adresses_ip.txt
> ```

> [!info] Gestion des nombres décimaux `-n` gère également les nombres décimaux et négatifs :
> 
> ```bash
> # Fichier: decimaux.txt
> # 3.14
> # -5.2
> # 10.01
> # 0.5
> 
> sort -n decimaux.txt
> # Résultat:
> # -5.2
> # 0.5
> # 3.14
> # 10.01
> ```

---

## 🔄 Option `-r` : Tri inverse

L'option `-r` (ou `--reverse`) inverse l'ordre du tri, du plus grand au plus petit.

```bash
# Tri alphabétique inverse
sort -r noms.txt
# Résultat:
# Charlie
# Bob
# Alice

# Tri numérique inverse
sort -nr nombres.txt
# Résultat:
# 100
# 20
# 3
```

> [!example] Cas d'usage pratique
> 
> ```bash
> # Trouver les 10 fichiers les plus volumineux
> du -h * | sort -hr | head -10
> 
> # Trier les processus par utilisation CPU (décroissant)
> ps aux | tail -n +2 | sort -k3 -nr | head -10
> ```

---

## 📊 Option `-k` : Tri par colonne

L'option `-k` (ou `--key`) permet de trier selon une **colonne spécifique** lorsque les lignes contiennent plusieurs champs.

### Syntaxe de `-k`

```bash
sort -k COLONNE[,COLONNE][OPTIONS]
```

- `COLONNE` : numéro de la colonne (commence à 1)
- Options de colonne : `n` (numérique), `r` (inverse), etc.

> [!info] Délimiteur par défaut Par défaut, `sort` utilise les **espaces et tabulations** comme séparateurs de champs.

### Exemples de base

```bash
# Fichier: personnes.txt
# Alice 25 Paris
# Bob 30 Lyon
# Charlie 20 Marseille

# Trier par la 2ème colonne (âge) numériquement
sort -k2 -n personnes.txt
# Résultat:
# Charlie 20 Marseille
# Alice 25 Paris
# Bob 30 Lyon

# Trier par la 3ème colonne (ville) alphabétiquement
sort -k3 personnes.txt
# Résultat:
# Bob 30 Lyon
# Charlie 20 Marseille
# Alice 25 Paris
```

### Tri sur plusieurs colonnes

```bash
# Trier d'abord par ville (col 3), puis par âge (col 2)
sort -k3,3 -k2,2n personnes.txt
```

> [!tip] Spécifier les limites de colonne La syntaxe `-k3,3` signifie "trier uniquement sur la colonne 3", ce qui empêche le tri de déborder sur les colonnes suivantes.

### Options de tri par colonne

```bash
# Tri numérique inverse sur la colonne 2
sort -k2,2nr personnes.txt

# Tri sur colonne 1 (alphabétique), puis colonne 2 (numérique)
sort -k1,1 -k2,2n personnes.txt
```

> [!example] Cas d'usage : trier la sortie de `ls -l`
> 
> ```bash
> # Trier par taille de fichier (colonne 5)
> ls -l | tail -n +2 | sort -k5 -n
> 
> # Trier par date de modification (colonnes 6-8)
> ls -l | tail -n +2 | sort -k6,6M -k7,7n -k8,8
> ```

---

## 🔧 Option `-t` : Définir un délimiteur

L'option `-t` (ou `--field-separator`) permet de spécifier un **délimiteur personnalisé** pour séparer les colonnes.

```bash
sort -t 'DÉLIMITEUR' [OPTIONS]
```

> [!info] Quand utiliser `-t` ?
> 
> - Fichiers CSV (délimité par `,` ou `;`)
> - Fichiers de configuration (délimité par `:` comme `/etc/passwd`)
> - Données structurées avec séparateurs spécifiques

### Exemples avec différents délimiteurs

```bash
# Fichier CSV: donnees.csv
# Alice,25,Paris
# Bob,30,Lyon
# Charlie,20,Marseille

# Trier par la 2ème colonne (âge) avec délimiteur virgule
sort -t',' -k2 -n donnees.csv
# Résultat:
# Charlie,20,Marseille
# Alice,25,Paris
# Bob,30,Lyon

# Fichier /etc/passwd (délimiteur :)
# root:x:0:0:root:/root:/bin/bash
# user1:x:1000:1000:User One:/home/user1:/bin/bash

# Trier par UID (colonne 3)
sort -t':' -k3 -n /etc/passwd
```

> [!example] Traiter des fichiers TSV (Tab-Separated Values)
> 
> ```bash
> # Utiliser littéralement une tabulation comme délimiteur
> sort -t$'\t' -k2 -n fichier.tsv
> ```

> [!warning] Attention aux espaces Quand vous spécifiez un délimiteur avec `-t`, seul **ce caractère exact** est utilisé. Les espaces multiples ne sont plus traités comme un seul séparateur.

---

## 🎯 Option `-u` : Supprimer les doublons

L'option `-u` (ou `--unique`) trie **et supprime les lignes dupliquées**, ne conservant qu'une seule occurrence de chaque ligne identique.

```bash
# Fichier: fruits.txt
# pomme
# banane
# pomme
# orange
# banane
# pomme

sort -u fruits.txt
# Résultat:
# banane
# orange
# pomme
```

> [!info] Différence avec `uniq`
> 
> - `sort -u` : trie ET supprime les doublons en une seule commande
> - `uniq` : supprime uniquement les doublons **consécutifs** (nécessite un tri préalable)
> 
> ```bash
> # Ces deux commandes sont équivalentes
> sort fichier.txt | uniq
> sort -u fichier.txt
> ```

> [!tip] Performance `sort -u` est généralement **plus rapide** que `sort | uniq` car il effectue les deux opérations simultanément.

### Supprimer les doublons sur une colonne spécifique

```bash
# Fichier: personnes.txt
# Alice 25 Paris
# Bob 30 Lyon
# Alice 28 Marseille
# Charlie 20 Paris

# Garder les lignes uniques basées sur la 1ère colonne (prénom)
sort -t' ' -k1,1 -u personnes.txt
# Résultat:
# Alice 25 Paris
# Bob 30 Lyon
# Charlie 20 Paris
```

---

## 🔗 Combinaison d'options

Les options de `sort` peuvent être combinées pour des tris complexes.

### Exemples de combinaisons courantes

```bash
# Tri numérique inverse + suppression des doublons
sort -nur nombres.txt

# Tri par colonne 2 (numérique) puis colonne 1 (alphabétique)
sort -k2,2n -k1,1 fichier.txt

# Tri sur CSV : colonne 3 (numérique inverse) sans doublons
sort -t',' -k3,3nr -u donnees.csv

# Tri par taille de fichier (décroissant) en format lisible
du -h * | sort -hr
```

> [!example] Cas d'usage complexe : analyser des logs
> 
> ```bash
> # Fichier log.txt format: [DATE] [NIVEAU] [MESSAGE]
> # 2024-01-15 ERROR Connection failed
> # 2024-01-14 INFO User login
> # 2024-01-15 ERROR Database timeout
> # 2024-01-14 WARN Low memory
> 
> # Trier par niveau (colonne 2) puis par date (colonne 1)
> sort -k2,2 -k1,1 log.txt
> 
> # Compter les erreurs uniques
> grep ERROR log.txt | sort -k3- -u | wc -l
> ```

### Tableau récapitulatif des options

|Option|Description|Exemple|
|---|---|---|
|(défaut)|Tri alphabétique|`sort fichier.txt`|
|`-n`|Tri numérique|`sort -n nombres.txt`|
|`-r`|Tri inverse|`sort -r fichier.txt`|
|`-k`|Tri par colonne|`sort -k2 fichier.txt`|
|`-t`|Délimiteur personnalisé|`sort -t',' fichier.csv`|
|`-u`|Supprimer doublons|`sort -u fichier.txt`|
|`-f`|Ignorer la casse|`sort -f fichier.txt`|
|`-h`|Tri "human-readable" (tailles)|`sort -h tailles.txt`|
|`-M`|Tri par mois|`sort -M mois.txt`|
|`-V`|Tri de versions|`sort -V versions.txt`|

---

## ⚠️ Pièges courants

> [!warning] Piège 1 : Oublier `-n` pour les nombres
> 
> ```bash
> # INCORRECT - tri alphabétique
> sort nombres.txt
> # 1, 10, 100, 2, 20, 3...
> 
> # CORRECT - tri numérique
> sort -n nombres.txt
> # 1, 2, 3, 10, 20, 100...
> ```

> [!warning] Piège 2 : Délimiteur par défaut vs personnalisé
> 
> ```bash
> # Si votre fichier utilise des virgules, spécifiez -t
> sort -k2 -n data.csv  # INCORRECT (cherche des espaces)
> sort -t',' -k2 -n data.csv  # CORRECT
> ```

> [!warning] Piège 3 : Stabilité du tri `sort` n'est pas stable par défaut : deux lignes identiques pour la clé de tri peuvent être réordonnées. Utilisez `-s` (stable sort) pour préserver l'ordre original :
> 
> ```bash
> sort -s -k2 fichier.txt
> ```

> [!warning] Piège 4 : Espaces multiples Avec le délimiteur par défaut, les espaces multiples sont traités comme un seul. Avec `-t' '`, chaque espace compte :
> 
> ```bash
> # Ligne: "Alice  25" (2 espaces)
> sort -k2      # Fonctionne (espaces = 1 séparateur)
> sort -t' ' -k2  # Problème (k2 pourrait être vide)
> ```

> [!warning] Piège 5 : Tri sur toute la ligne après la colonne
> 
> ```bash
> # Si vous ne spécifiez que -k2, le tri continue sur les colonnes suivantes
> sort -k2 fichier.txt  # Trie sur col 2, puis 3, puis 4...
> 
> # Pour trier UNIQUEMENT sur col 2
> sort -k2,2 fichier.txt
> ```

---

## 💡 Astuces avancées

> [!tip] Astuce 1 : Tri human-readable avec `-h` Pour trier des tailles de fichiers lisibles (K, M, G) :
> 
> ```bash
> du -h * | sort -h
> # 4.0K fichier1
> # 128K fichier2
> # 2.5M fichier3
> # 1.2G fichier4
> ```

> [!tip] Astuce 2 : Tri par mois avec `-M`
> 
> ```bash
> # Fichier: dates.txt
> # Jan
> # Mar
> # Feb
> 
> sort -M dates.txt
> # Résultat:
> # Jan
> # Feb
> # Mar
> ```

> [!tip] Astuce 3 : Tri de numéros de version avec `-V`
> 
> ```bash
> # Fichier: versions.txt
> # v1.10
> # v1.2
> # v1.9
> 
> sort -V versions.txt
> # Résultat:
> # v1.2
> # v1.9
> # v1.10
> ```

> [!tip] Astuce 4 : Vérifier si un fichier est trié
> 
> ```bash
> # Retourne 0 si trié, 1 sinon
> sort -c fichier.txt
> 
> # Version silencieuse
> sort -C fichier.txt
> ```

> [!tip] Astuce 5 : Tri en parallèle pour gros fichiers
> 
> ```bash
> # Utiliser plusieurs cœurs pour accélérer le tri
> sort --parallel=4 gros_fichier.txt
> 
> # Ou automatiquement selon les cœurs disponibles
> sort --parallel=$(nproc) gros_fichier.txt
> ```

> [!tip] Astuce 6 : Limiter l'utilisation mémoire
> 
> ```bash
> # Limiter le buffer mémoire (utile pour très gros fichiers)
> sort -S 1G gros_fichier.txt
> 
> # Utiliser un répertoire temporaire spécifique
> sort -T /chemin/vers/tmp gros_fichier.txt
> ```

> [!tip] Astuce 7 : Tri aléatoire avec `-R`
> 
> ```bash
> # Mélanger les lignes aléatoirement
> sort -R fichier.txt
> 
> # Utile pour échantillonner des données
> sort -R data.txt | head -100 > echantillon.txt
> ```

> [!tip] Astuce 8 : Combiner avec d'autres commandes
> 
> ```bash
> # Top 10 des commandes les plus utilisées
> history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10
> 
> # Trouver les IPs les plus fréquentes dans un log
> awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
> 
> # Comparer deux fichiers triés
> sort fichier1.txt > f1_sorted
> sort fichier2.txt > f2_sorted
> comm f1_sorted f2_sorted
> ```

---

## 📌 Bonnes pratiques

1. **Toujours utiliser `-n` pour les nombres** : Le tri alphabétique sur des nombres donne des résultats incorrects
2. **Spécifier le délimiteur avec `-t`** pour les fichiers structurés (CSV, TSV, etc.)
3. **Utiliser `-k` avec précision** : Spécifiez `-k2,2` plutôt que `-k2` pour éviter le tri sur les colonnes suivantes
4. **Combiner `-u` avec `sort`** plutôt que d'utiliser `uniq` séparément pour de meilleures performances
5. **Tester sur un échantillon** : Avec de gros fichiers, testez d'abord votre commande sur quelques lignes avec `head`
6. **Préserver l'ordre original** : Utilisez `-s` pour un tri stable quand c'est important

---

_Fin du cours sur la commande `sort` - Maîtrisez le tri de données sous Linux ! 🚀_