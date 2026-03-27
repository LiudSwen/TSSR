

## 📋 Table des matières

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

La commande `uniq` est un outil essentiel pour **détecter et gérer les lignes en double** dans un fichier ou un flux de données. Son rôle principal est de **supprimer les lignes consécutives identiques**.

> [!info] Pourquoi utiliser `uniq` ?
> 
> - Nettoyer des fichiers de logs en supprimant les répétitions
> - Compter les occurrences d'événements dans des données
> - Identifier les valeurs uniques ou dupliquées dans un dataset
> - Analyser des fichiers de configuration ou de résultats

> [!warning] Point crucial à retenir `uniq` ne compare que les **lignes consécutives**. Pour traiter toutes les lignes d'un fichier, il faut d'abord le **trier** avec `sort`.

---

## Fonctionnement de base

### Syntaxe générale

```bash
uniq [OPTIONS] [FICHIER_ENTREE] [FICHIER_SORTIE]
```

### Comportement par défaut

Sans option, `uniq` supprime les **doublons consécutifs** :

```bash
# Fichier exemple : donnees.txt
apple
apple
banana
apple
orange
orange

# Commande
uniq donnees.txt

# Résultat
apple
banana
apple
orange
```

> [!example] Observation importante La ligne "apple" apparaît deux fois dans le résultat car les occurrences ne sont pas consécutives. La première série d'apple est suivie de banana, puis apple réapparaît.

### Combinaison avec `sort`

Pour obtenir des lignes réellement uniques dans tout le fichier :

```bash
# Trier puis supprimer les doublons
sort donnees.txt | uniq

# Résultat
apple
banana
orange
```

---

## Options principales

### Option `-c` : Compter les occurrences

Préfixe chaque ligne unique par son **nombre d'occurrences** :

```bash
sort donnees.txt | uniq -c

# Résultat
      3 apple
      1 banana
      2 orange
```

> [!tip] Astuce d'analyse Combine avec `sort -n` pour trier par fréquence :
> 
> ```bash
> sort donnees.txt | uniq -c | sort -nr
> # Affiche les lignes les plus fréquentes en premier
> ```

**Cas d'usage typiques** :

- Analyser les codes d'erreur les plus fréquents dans des logs
- Identifier les IP les plus actives dans un fichier d'accès
- Compter les mots les plus utilisés dans un texte

```bash
# Exemple : Top 10 des commandes les plus utilisées
history | awk '{print $2}' | sort | uniq -c | sort -nr | head -10
```

---

### Option `-d` : Afficher uniquement les doublons

Ne garde que les lignes qui apparaissent **au moins deux fois** :

```bash
sort donnees.txt | uniq -d

# Résultat
apple
orange
```

> [!info] Comportement
> 
> - Chaque ligne dupliquée est affichée **une seule fois**
> - Les lignes uniques (banana) sont ignorées

**Cas d'usage typiques** :

- Détecter des entrées dupliquées dans une base de données
- Identifier des fichiers avec des noms en double
- Trouver des utilisateurs avec plusieurs comptes

```bash
# Exemple : Trouver les lignes en double dans un fichier de configuration
sort config.conf | uniq -d

# Exemple : Détecter les emails en double
cut -d',' -f2 users.csv | sort | uniq -d
```

---

### Option `-u` : Afficher uniquement les lignes uniques

Ne garde que les lignes qui apparaissent **exactement une fois** :

```bash
sort donnees.txt | uniq -u

# Résultat
banana
```

> [!example] Différence avec le comportement par défaut
> 
> - `uniq` (sans option) : supprime les répétitions consécutives mais garde une occurrence
> - `uniq -u` : ne garde que les lignes qui n'ont AUCUN doublon

**Cas d'usage typiques** :

- Extraire les valeurs uniques d'un dataset
- Identifier les entrées qui n'ont pas de duplicata
- Filtrer les données pour ne garder que les éléments isolés

```bash
# Exemple : Trouver les utilisateurs qui n'ont qu'une seule session
cut -f1 sessions.log | sort | uniq -u

# Exemple : Identifier les fichiers sans sauvegarde
ls current/ backup/ | sort | uniq -u
```

---

### Tableau récapitulatif des options

|Option|Description|Résultat pour "A A B C C C"|
|---|---|---|
|(aucune)|Supprime doublons consécutifs|A B C|
|`-c`|Compte les occurrences|2 A<br>1 B<br>3 C|
|`-d`|Garde seulement les doublons|A C|
|`-u`|Garde seulement les uniques|B|

---

## Cas d'usage pratiques

### 1. Analyse de logs

```bash
# Compter les types d'erreurs dans un log Apache
grep "error" /var/log/apache2/error.log | \
  awk '{print $9}' | \
  sort | uniq -c | sort -nr

# Résultat exemple
    847 404
    152 500
     23 403
```

### 2. Nettoyage de données

```bash
# Supprimer les emails en double d'une liste
sort emails.txt | uniq > emails_clean.txt

# Identifier les doublons avant suppression
sort emails.txt | uniq -d > doublons.txt
```

### 3. Surveillance système

```bash
# Trouver les processus qui consomment le plus de ressources
ps aux | awk '{print $11}' | sort | uniq -c | sort -nr | head -20

# Identifier les utilisateurs connectés (sans répétitions)
who | awk '{print $1}' | sort | uniq
```

### 4. Analyse de fichiers texte

```bash
# Compter les mots uniques dans un fichier
tr '[:upper:]' '[:lower:]' < texte.txt | \
  tr -cs '[:alpha:]' '\n' | \
  sort | uniq -c | sort -nr | head -50
```

---

## Pièges courants

### ❌ Piège 1 : Oublier de trier

```bash
# INCORRECT - ne fonctionne que sur les doublons consécutifs
uniq fichier.txt

# CORRECT - trie d'abord pour regrouper les lignes identiques
sort fichier.txt | uniq
```

> [!warning] Attention Sans `sort`, `uniq` peut manquer des doublons non consécutifs et donner des résultats incomplets.

### ❌ Piège 2 : Espaces et casse

```bash
# Fichier avec variations de casse et espaces
Apple
apple
 apple

# Sans traitement, chaque ligne est considérée différente
sort fichier.txt | uniq
# Résultat : 3 lignes différentes

# CORRECT - normaliser d'abord
tr '[:upper:]' '[:lower:]' < fichier.txt | \
  sed 's/^[[:space:]]*//' | \
  sort | uniq
```

### ❌ Piège 3 : Confusion entre `-d` et `-u`

```bash
# Données : A A B C C
sort data.txt | uniq -d  # Résultat : A C (les doublons)
sort data.txt | uniq -u  # Résultat : B (les uniques)

# Pour voir TOUTES les lignes avec leur statut
sort data.txt | uniq -c
```

### ❌ Piège 4 : Ordre de sortie avec `-c`

```bash
# Le comptage ne trie PAS automatiquement par fréquence
uniq -c fichier.txt  # Ordre : tel quel

# Pour trier par fréquence décroissante
uniq -c fichier.txt | sort -nr

# Pour trier par fréquence croissante
uniq -c fichier.txt | sort -n
```

---

## Astuces avancées

### 🎯 Astuce 1 : Ignorer des champs spécifiques

```bash
# Ignorer le premier champ (option -f)
# Utile pour des fichiers avec timestamp ou ID
uniq -f 1 fichier.txt

# Ignorer les N premiers caractères (option -s)
uniq -s 5 fichier.txt
```

### 🎯 Astuce 2 : Comparer seulement une partie des lignes

```bash
# Comparer seulement les N premiers caractères (option -w)
# Exemple : regrouper par préfixe
uniq -w 3 fichier.txt  # Compare seulement 3 premiers caractères
```

### 🎯 Astuce 3 : Analyse statistique rapide

```bash
# Distribution statistique des données
sort data.txt | uniq -c | awk '
{
    count[$1]++
    total++
}
END {
    for (n in count) {
        printf "%d lignes apparaissent %d fois (%.1f%%)\n", 
               count[n], n, count[n]/total*100
    }
}'
```

### 🎯 Astuce 4 : Comparaison de fichiers

```bash
# Trouver les lignes présentes uniquement dans fichier1
sort fichier1.txt fichier2.txt fichier2.txt | uniq -u

# Trouver les lignes communes aux deux fichiers
sort fichier1.txt fichier2.txt | uniq -d
```

### 🎯 Astuce 5 : Pipeline complexe pour logs

```bash
# Analyse complète d'un log : erreurs, comptage, et contexte
grep -i "error" application.log | \
  awk '{print $5, $6, $7}' | \
  sort | uniq -c | sort -nr | \
  awk '$1 > 10 {print $0}'  # Seulement erreurs > 10 occurrences
```

### 🎯 Astuce 6 : Cas insensible avec GNU `uniq`

```bash
# Sur systèmes avec GNU coreutils
# Option -i pour ignorer la casse
sort -f fichier.txt | uniq -i

# Alternative portable
tr '[:upper:]' '[:lower:]' < fichier.txt | sort | uniq
```

---

> [!tip] Mémo rapide
> 
> - **Toujours trier avant `uniq`** pour des résultats complets
> - `-c` pour compter, `-d` pour doublons, `-u` pour uniques
> - Combiner avec `sort -nr` pour un classement par fréquence
> - Attention aux espaces et à la casse qui créent des différences