

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

**sed** (Stream EDitor) est un éditeur de texte en flux qui permet de transformer du texte de manière automatique et efficace. Contrairement aux éditeurs classiques, sed traite le texte ligne par ligne sans interaction utilisateur.

> [!info] Pourquoi utiliser sed ?
> 
> - **Performance** : Traite de gros fichiers sans les charger entièrement en mémoire
> - **Automatisation** : Idéal pour les scripts et le traitement par lots
> - **Puissance** : Combinaison avec les expressions régulières
> - **Portabilité** : Disponible sur tous les systèmes Unix/Linux

### Cas d'usage typiques

- Rechercher et remplacer du texte dans des fichiers
- Supprimer des lignes spécifiques
- Extraire des portions de texte
- Transformer des logs ou des données structurées
- Automatiser des modifications répétitives

---

## 📝 Syntaxe de base

```bash
sed 'commande' fichier
```

**Structure :**

- `sed` : la commande
- `'commande'` : l'opération à effectuer (entre quotes simples)
- `fichier` : le fichier à traiter (optionnel, peut lire depuis stdin)

> [!example] Exemples simples
> 
> ```bash
> # Afficher un fichier (comme cat)
> sed '' fichier.txt
> 
> # Utiliser sed avec un pipe
> cat fichier.txt | sed 's/ancien/nouveau/'
> 
> # Traiter plusieurs fichiers
> sed 's/foo/bar/' file1.txt file2.txt
> ```

**Flux de traitement :**

1. sed lit une ligne du fichier
2. Applique la commande à cette ligne
3. Affiche le résultat (par défaut)
4. Passe à la ligne suivante

---

## 🔄 Substitution avec s

La commande `s` (substitute) est la plus utilisée dans sed. Elle permet de rechercher et remplacer du texte.

### Syntaxe de base

```bash
sed 's/pattern/replacement/' fichier
```

|Élément|Description|
|---|---|
|`s`|Commande de substitution|
|`/`|Délimiteur (peut être changé)|
|`pattern`|Texte ou regex à rechercher|
|`replacement`|Texte de remplacement|

> [!example] Exemples pratiques
> 
> ```bash
> # Remplacer la première occurrence de "chat" par "chien"
> sed 's/chat/chien/' animaux.txt
> 
> # Utiliser un délimiteur alternatif (utile pour les chemins)
> sed 's|/home/user|/home/admin|' config.txt
> sed 's#http://old#https://new#' urls.txt
> 
> # Remplacer avec du texte vide (suppression)
> sed 's/mot_a_supprimer//' fichier.txt
> ```

### Caractères spéciaux dans le remplacement

|Caractère|Signification|
|---|---|
|`&`|Texte correspondant au pattern|
|`\1`, `\2`, ...|Groupes de capture|
|`\n`|Nouvelle ligne|
|`\t`|Tabulation|

> [!example] Utilisation de & et des groupes
> 
> ```bash
> # Entourer chaque mot "ERROR" de crochets
> sed 's/ERROR/[&]/' logs.txt
> # Résultat : ERROR devient [ERROR]
> 
> # Inverser deux mots
> sed 's/\(premier\) \(second\)/\2 \1/' texte.txt
> # Résultat : "premier second" devient "second premier"
> 
> # Mettre en majuscules avec \U (GNU sed)
> echo "hello" | sed 's/.*/\U&/'
> # Résultat : HELLO
> ```

---

## 🚩 Les flags de substitution

Les flags modifient le comportement de la commande `s` et sont placés après le dernier délimiteur.

### Flag g (global)

**Par défaut, sed ne remplace que la première occurrence par ligne.**

```bash
# Sans g : remplace seulement la première occurrence
echo "foo foo foo" | sed 's/foo/bar/'
# Résultat : bar foo foo

# Avec g : remplace toutes les occurrences
echo "foo foo foo" | sed 's/foo/bar/g'
# Résultat : bar bar bar
```

> [!warning] Attention Le flag `g` ne fonctionne que sur une seule ligne à la fois. Pour traiter tout le fichier, sed le fait automatiquement ligne par ligne.

### Flag i (insensible à la casse)

```bash
# Recherche insensible à la casse
sed 's/error/ERREUR/i' logs.txt
# Remplace error, Error, ERROR, ErRoR, etc.

# Combiner i et g
sed 's/error/ERREUR/gi' logs.txt
# Remplace toutes les occurrences, quelle que soit la casse
```

### Flag numérique (remplacer la Nième occurrence)

```bash
# Remplacer seulement la 2ème occurrence
echo "foo foo foo foo" | sed 's/foo/bar/2'
# Résultat : foo bar foo foo

# Remplacer à partir de la 2ème occurrence
echo "foo foo foo foo" | sed 's/foo/bar/2g'
# Résultat : foo bar bar bar
```

### Flag p (print)

```bash
# Affiche les lignes modifiées (utilisé avec -n)
sed -n 's/pattern/replacement/p' fichier
# Affiche uniquement les lignes où un remplacement a eu lieu
```

### Tableau récapitulatif des flags

|Flag|Description|Exemple|
|---|---|---|
|`g`|Remplace toutes les occurrences|`s/a/b/g`|
|`i`|Ignore la casse|`s/error/ERREUR/i`|
|`1-9`|Remplace la Nième occurrence|`s/foo/bar/2`|
|`p`|Affiche les lignes modifiées|`s/pattern/replacement/p`|
|`w fichier`|Écrit les lignes modifiées dans un fichier|`s/pattern/replacement/w output.txt`|

> [!tip] Combinaison de flags
> 
> ```bash
> # Combiner plusieurs flags
> sed 's/error/ERREUR/gip' logs.txt
> # g : toutes les occurrences
> # i : insensible à la casse
> # p : affiche les lignes modifiées
> ```

---

## 🗑️ Suppression de lignes avec d

La commande `d` (delete) supprime des lignes entières du flux de sortie.

### Syntaxe de base

```bash
# Supprimer toutes les lignes
sed 'd' fichier  # Ne rien afficher !

# Supprimer une ligne spécifique
sed '3d' fichier  # Supprime la ligne 3

# Supprimer plusieurs lignes
sed '2d; 5d; 8d' fichier  # Supprime les lignes 2, 5 et 8
```

### Suppression par pattern

```bash
# Supprimer les lignes contenant un pattern
sed '/pattern/d' fichier

# Supprimer les lignes vides
sed '/^$/d' fichier

# Supprimer les lignes commençant par #
sed '/^#/d' config.txt
```

> [!example] Exemples pratiques
> 
> ```bash
> # Supprimer les commentaires d'un fichier de configuration
> sed '/^#/d; /^$/d' config.conf
> 
> # Supprimer les lignes contenant "DEBUG"
> sed '/DEBUG/d' logs.txt
> 
> # Supprimer les lignes ne contenant PAS "ERROR" (avec !)
> sed '/ERROR/!d' logs.txt
> # Équivalent à grep "ERROR" logs.txt
> ```

### Suppression par plage

```bash
# Supprimer les lignes 5 à 10
sed '5,10d' fichier

# Supprimer depuis la ligne 20 jusqu'à la fin
sed '20,$d' fichier

# Supprimer depuis le début jusqu'à la ligne 5
sed '1,5d' fichier
```

> [!warning] Point d'attention La commande `d` supprime la ligne du flux de sortie, mais ne modifie pas le fichier source (sauf si vous utilisez `-i`).

---

## ➕ Insertion et ajout (i et a)

Les commandes `i` (insert) et `a` (append) permettent d'ajouter du texte avant ou après une ligne.

### Commande i (insert - insérer avant)

```bash
# Syntaxe
sed 'adresse i\texte' fichier

# Insérer avant la ligne 3
sed '3i\Nouvelle ligne' fichier

# Insérer avant chaque ligne contenant "pattern"
sed '/pattern/i\Texte avant' fichier
```

### Commande a (append - ajouter après)

```bash
# Syntaxe
sed 'adresse a\texte' fichier

# Ajouter après la ligne 3
sed '3a\Nouvelle ligne' fichier

# Ajouter après chaque ligne contenant "pattern"
sed '/pattern/a\Texte après' fichier
```

> [!example] Exemples pratiques
> 
> ```bash
> # Ajouter un en-tête au début du fichier
> sed '1i\# Fichier de configuration\n# Généré automatiquement' config.txt
> 
> # Ajouter une ligne après chaque occurrence de "TODO"
> sed '/TODO/a\Action requise: à compléter' notes.txt
> 
> # Insérer une ligne vide avant chaque section
> sed '/^\[.*\]$/i\\' config.ini
> ```

### Syntaxe multi-lignes

```bash
# Méthode 1 : Utiliser \n
sed '5i\Ligne 1\nLigne 2\nLigne 3' fichier

# Méthode 2 : Antislash en fin de ligne (GNU sed)
sed '5i\
Ligne 1\
Ligne 2\
Ligne 3' fichier
```

> [!tip] Astuce Pour insérer du contenu au début ou à la fin d'un fichier :
> 
> ```bash
> # Au début
> sed '1i\Header text' fichier
> 
> # À la fin
> sed '$a\Footer text' fichier
> ```

---

## 🔄 Remplacement de lignes avec c

La commande `c` (change) remplace une ligne entière par un nouveau texte.

### Syntaxe de base

```bash
sed 'adresse c\nouveau texte' fichier
```

> [!example] Exemples d'utilisation
> 
> ```bash
> # Remplacer la ligne 3
> sed '3c\Texte de remplacement complet' fichier
> 
> # Remplacer les lignes contenant "ERROR"
> sed '/ERROR/c\[ERREUR TRAITÉE]' logs.txt
> 
> # Remplacer une plage de lignes
> sed '5,10c\Ces lignes ont été remplacées' fichier
> ```

### Différence avec la substitution (s)

|Commande|Action|Exemple|
|---|---|---|
|`s/pattern/replacement/`|Remplace le pattern dans la ligne|`foo bar baz` → `new bar baz`|
|`c\texte`|Remplace la ligne entière|`foo bar baz` → `texte`|

> [!example] Comparaison
> 
> ```bash
> # Fichier test.txt contient : "Hello World"
> 
> # Avec s : remplace seulement "Hello"
> sed 's/Hello/Bonjour/' test.txt
> # Résultat : Bonjour World
> 
> # Avec c : remplace toute la ligne
> sed 'c\Bonjour le monde' test.txt
> # Résultat : Bonjour le monde
> ```

### Utilisation avancée

```bash
# Remplacer plusieurs lignes par du contenu multi-lignes
sed '5,10c\
Première ligne de remplacement\
Deuxième ligne de remplacement\
Troisième ligne de remplacement' fichier

# Remplacer conditionnellement
sed '/^#.*deprecated/c\# Cette fonction est obsolète' code.py
```

> [!warning] Attention avec les plages Quand vous utilisez `c` avec une plage (ex: `5,10c\texte`), sed remplace **toute la plage** par **une seule ligne** de texte, pas ligne par ligne.
> 
> ```bash
> # Remplace les lignes 5 à 10 par UNE SEULE ligne
> sed '5,10c\Remplacement unique' fichier
> ```

---

## 👁️ Affichage sélectif avec p

La commande `p` (print) affiche les lignes. Combinée avec l'option `-n`, elle permet un affichage sélectif.

### Option -n (mode silencieux)

**Par défaut, sed affiche toutes les lignes.** L'option `-n` désactive cet affichage automatique.

```bash
# Sans -n : affiche toutes les lignes + les lignes où s trouve un match
sed 's/pattern/replacement/p' fichier  # Duplication !

# Avec -n : affiche uniquement les lignes où s trouve un match
sed -n 's/pattern/replacement/p' fichier
```

### Afficher des lignes spécifiques

```bash
# Afficher la ligne 5
sed -n '5p' fichier

# Afficher les lignes 5 à 10
sed -n '5,10p' fichier

# Afficher la dernière ligne
sed -n '$p' fichier

# Afficher les lignes paires
sed -n '2~2p' fichier

# Afficher les lignes impaires
sed -n '1~2p' fichier
```

> [!example] Équivalent de head et tail
> 
> ```bash
> # Équivalent de head -n 10
> sed -n '1,10p' fichier
> 
> # Équivalent de tail (afficher les 10 dernières lignes, nécessite de connaître le nombre total)
> # Méthode indirecte
> sed -n '$-9,$p' fichier  # Ne fonctionne pas toujours
> 
> # Afficher à partir de la ligne 20
> sed -n '20,$p' fichier
> ```

### Affichage par pattern

```bash
# Afficher les lignes contenant "ERROR"
sed -n '/ERROR/p' fichier
# Équivalent à : grep "ERROR" fichier

# Afficher les lignes ne contenant PAS "ERROR"
sed -n '/ERROR/!p' fichier
# Équivalent à : grep -v "ERROR" fichier

# Afficher les lignes entre deux patterns
sed -n '/START/,/END/p' fichier
```

> [!tip] Combinaison avec la substitution
> 
> ```bash
> # Afficher uniquement les lignes où un remplacement a eu lieu
> sed -n 's/foo/bar/p' fichier
> 
> # Compter le nombre de remplacements effectués
> sed -n 's/foo/bar/p' fichier | wc -l
> ```

### Utilisation avancée

```bash
# Afficher toutes les lignes sauf une plage
sed -n '5,10!p' fichier

# Afficher et modifier en même temps
sed -n 's/ERROR/[ERROR]/p' logs.txt

# Dupliquer certaines lignes
sed -n 'p;/important/p' fichier
# Affiche toutes les lignes, et les lignes contenant "important" en double
```

---

## 📏 Plages de lignes

Les plages (ranges) permettent d'appliquer des commandes à plusieurs lignes consécutives.

### Syntaxe des plages

```bash
# Format général
sed 'début,fin commande' fichier
```

### Plages numériques

```bash
# Lignes 5 à 10
sed '5,10d' fichier          # Supprime les lignes 5 à 10
sed '5,10s/foo/bar/' fichier # Remplace dans les lignes 5 à 10

# Du début jusqu'à la ligne 20
sed '1,20d' fichier

# De la ligne 30 jusqu'à la fin
sed '30,$d' fichier

# Une seule ligne (cas particulier)
sed '5s/foo/bar/' fichier    # Uniquement la ligne 5
```

> [!example] Exemples pratiques
> 
> ```bash
> # Supprimer les 10 premières lignes (en-tête)
> sed '1,10d' data.csv
> 
> # Remplacer uniquement dans les 5 premières lignes
> sed '1,5s/old/new/g' config.txt
> 
> # Afficher les lignes 100 à 200
> sed -n '100,200p' fichier.log
> ```

### Plages par pattern

```bash
# Entre deux patterns
sed '/START/,/END/d' fichier
# Supprime depuis la ligne contenant START jusqu'à END (inclus)

# Depuis un pattern jusqu'à la fin
sed '/ERROR/,$d' logs.txt
# Supprime depuis la première ligne contenant ERROR jusqu'à la fin

# Depuis le début jusqu'à un pattern
sed '1,/HEADER/d' fichier
```

> [!example] Cas d'usage avec patterns
> 
> ```bash
> # Extraire une section d'un fichier de configuration
> sed -n '/\[section1\]/,/\[section2\]/p' config.ini
> 
> # Commenter une section de code
> sed '/BEGIN_SECTION/,/END_SECTION/s/^/# /' script.sh
> 
> # Supprimer un bloc de commentaires
> sed '/\/\*/,/\*\//d' code.c
> ```

### Plages avec incrément

```bash
# Toutes les 2 lignes à partir de la ligne 1
sed -n '1~2p' fichier  # Lignes 1, 3, 5, 7...

# Toutes les 3 lignes à partir de la ligne 2
sed -n '2~3p' fichier  # Lignes 2, 5, 8, 11...

# Supprimer une ligne sur trois
sed '0~3d' fichier
```

### Plages avec adresse relative

```bash
# Pattern + N lignes après
sed '/ERROR/,+3d' logs.txt
# Supprime la ligne contenant ERROR plus les 3 lignes suivantes

# Ligne N + M lignes après
sed '10,+5d' fichier
# Supprime les lignes 10 à 15
```

> [!warning] Comportement des plages avec patterns Si le pattern de fin n'est jamais trouvé, sed traite jusqu'à la fin du fichier :
> 
> ```bash
> sed '/START/,/END/d' fichier
> # Si "END" n'existe pas, supprime de START jusqu'à la fin
> ```

### Négation de plages

```bash
# Appliquer une commande SAUF dans une plage
sed '5,10!d' fichier
# Supprime tout SAUF les lignes 5 à 10 (équivalent de garder 5 à 10)

sed '/START/,/END/!s/foo/bar/' fichier
# Remplace foo par bar SAUF entre START et END
```

---

## 💾 Modification in-place avec -i

L'option `-i` permet de modifier directement le fichier source au lieu d'afficher le résultat sur stdout.

### Syntaxe de base

```bash
# Modification directe (attention, irréversible !)
sed -i 's/ancien/nouveau/g' fichier.txt

# Avec une extension pour créer un backup
sed -i.bak 's/ancien/nouveau/g' fichier.txt
# Crée fichier.txt.bak (original) et modifie fichier.txt
```

> [!warning] ⚠️ ATTENTION : Pas de retour en arrière Sans backup, la modification est **définitive**. Il est impossible de récupérer le contenu original.

### Différences selon les systèmes

|Système|Syntaxe backup|Comportement|
|---|---|---|
|**GNU sed** (Linux)|`-i.bak` ou `-i .bak`|Les deux fonctionnent|
|**BSD sed** (macOS)|`-i .bak`|**Espace obligatoire**|

```bash
# GNU sed (Linux)
sed -i.bak 's/foo/bar/g' fichier       # OK
sed -i .bak 's/foo/bar/g' fichier      # OK

# BSD sed (macOS)
sed -i .bak 's/foo/bar/g' fichier      # OK
sed -i.bak 's/foo/bar/g' fichier       # ERREUR
```

> [!tip] Astuce portable Pour un script qui fonctionne sur Linux ET macOS :
> 
> ```bash
> # Toujours utiliser un espace après -i
> sed -i.bak 's/foo/bar/g' fichier
> ```

### Exemples d'utilisation

```bash
# Remplacer dans plusieurs fichiers
sed -i 's/http:/https:/g' *.html

# Supprimer les lignes vides d'un fichier
sed -i '/^$/d' document.txt

# Nettoyer les espaces en fin de ligne
sed -i 's/[[:space:]]*$//' code.py

# Ajouter un en-tête à un fichier
sed -i '1i\#!/bin/bash' script.sh
```

> [!example] Modification avec backup
> 
> ```bash
> # Créer un backup avant modification
> sed -i.original 's/DEBUG/INFO/g' app.log
> 
> # Résultat :
> # - app.log          : version modifiée
> # - app.log.original : version originale
> 
> # Si erreur, restaurer l'original :
> mv app.log.original app.log
> ```

### Utilisation sécurisée

```bash
# 1. Toujours tester SANS -i d'abord
sed 's/pattern/replacement/g' fichier | less

# 2. Si OK, utiliser -i avec backup
sed -i.bak 's/pattern/replacement/g' fichier

# 3. Vérifier le résultat
diff fichier.bak fichier

# 4. Si satisfait, supprimer le backup
rm fichier.bak
```

> [!warning] Cas problématiques
> 
> ```bash
> # ❌ NE PAS FAIRE : modification sans backup sur des fichiers critiques
> sed -i 's/root/admin/' /etc/passwd
> 
> # ✅ FAIRE : toujours créer un backup des fichiers système
> sed -i.backup 's/pattern/replacement/' /etc/config
> ```

### Option -i sans argument (pas de backup)

```bash
# Modifier sans créer de backup
sed -i '' 's/foo/bar/' fichier.txt  # BSD sed (macOS)
sed -i 's/foo/bar/' fichier.txt     # GNU sed (Linux)
```

> [!tip] Bonne pratique En production, **toujours créer un backup** :
> 
> ```bash
> # Ajouter la date au backup
> sed -i.$(date +%Y%m%d) 's/old/new/g' important.conf
> # Crée : important.conf.20241211
> ```

---

## 🔍 Utilisation avec les regex

sed supporte les expressions régulières, ce qui le rend extrêmement puissant pour le traitement de texte.

### Métacaractères de base

|Symbole|Signification|Exemple|
|---|---|---|
|`.`|N'importe quel caractère|`s/a.c/ABC/` → "abc", "a1c", "a c"|
|`*`|0 ou plusieurs du caractère précédent|`s/ab*c/X/` → "ac", "abc", "abbc"|
|`^`|Début de ligne|`s/^#/\/\//`|
|`$`|Fin de ligne|`s/;$/,/`|
|`[]`|Classe de caractères|`s/[aeiou]/X/`|
|`[^]`|Classe négative|`s/[^0-9]//g`|
|`\`|Échappement|`s/\./,/` → remplace le point littéral|

### Classes de caractères POSIX

```bash
# Syntaxe : [[:classe:]]
```

|Classe|Équivalent|Description|
|---|---|---|
|`[[:alpha:]]`|`[a-zA-Z]`|Lettres|
|`[[:digit:]]`|`[0-9]`|Chiffres|
|`[[:alnum:]]`|`[a-zA-Z0-9]`|Lettres et chiffres|
|`[[:space:]]`|`[ \t\n\r]`|Espaces blancs|
|`[[:upper:]]`|`[A-Z]`|Majuscules|
|`[[:lower:]]`|`[a-z]`|Minuscules|
|`[[:punct:]]`||Ponctuation|

> [!example] Exemples avec classes POSIX
> 
> ```bash
> # Supprimer tous les chiffres
> sed 's/[[:digit:]]//g' fichier
> 
> # Remplacer les espaces par des underscores
> sed 's/[[:space:]]/_/g' fichier
> 
> # Garder uniquement les lettres et chiffres
> sed 's/[^[:alnum:]]//g' fichier
> ```

### Quantificateurs

En sed standard, utilisez les quantificateurs basiques. Pour les regex étendues, utilisez `-E` ou `-r`.

```bash
# Regex basiques (sed standard)
\?      # 0 ou 1 occurrence (échappé)
\+      # 1 ou plusieurs (échappé)
\{n\}   # Exactement n occurrences (échappé)
\{n,\}  # Au moins n occurrences (échappé)
\{n,m\} # Entre n et m occurrences (échappé)

# Regex étendues (sed -E)
?       # 0 ou 1 occurrence
+       # 1 ou plusieurs
{n}     # Exactement n occurrences
{n,}    # Au moins n occurrences
{n,m}   # Entre n et m occurrences
```

> [!example] Exemples de quantificateurs
> 
> ```bash
> # Remplacer un ou plusieurs espaces par un seul
> sed 's/ \+/ /g' fichier              # Basique
> sed -E 's/ +/ /g' fichier            # Étendu
> 
> # Valider un code postal français (5 chiffres)
> sed -n '/^[0-9]\{5\}$/p' fichier     # Basique
> sed -En '/^[0-9]{5}$/p' fichier      # Étendu
> 
> # Supprimer 2 à 4 espaces en début de ligne
> sed 's/^ \{2,4\}//' fichier          # Basique
> sed -E 's/^ {2,4}//' fichier         # Étendu
> ```

### Groupes de capture

```bash
# Syntaxe basique (échappement nécessaire)
\(...\)    # Définit un groupe
\1, \2     # Référence les groupes

# Syntaxe étendue (avec -E)
(...)      # Définit un groupe
\1, \2     # Référence les groupes
```

> [!example] Manipulation avec groupes
> 
> ```bash
> # Inverser prénom et nom
> echo "Jean Dupont" | sed 's/\(.*\) \(.*\)/\2, \1/'
> # Résultat : Dupont, Jean
> 
> # Avec regex étendue
> echo "Jean Dupont" | sed -E 's/(.*) (.*)/\2, \1/'
> 
> # Extraire le domaine d'une URL
> echo "https://www.example.com/page" | sed -E 's|https?://([^/]+).*|\1|'
> # Résultat : www.example.com
> 
> # Formater un numéro de téléphone
> echo "0612345678" | sed -E 's/([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})/\1 \2 \3 \4 \5/'
> # Résultat : 06 12 34 56 78
> ```

### Ancres et limites

```bash
# ^ : Début de ligne
sed 's/^/> /' fichier          # Ajoute "> " au début de chaque ligne

# $ : Fin de ligne
sed 's/$/;/' fichier            # Ajoute ";" à la fin de chaque ligne

# \b : Limite de mot (avec -E, sinon \\b)
sed -E 's/\bword\b/MOT/g' fichier  # Remplace "word" mais pas "words" ou "keyword"

# Combiner ancres
sed 's/^$/LIGNE_VIDE/' fichier     # Remplace les lignes vides
```

### Alternatives (avec -E)

```bash
# Syntaxe : pattern1|pattern2
sed -E 's/(cat|dog)/animal/g' fichier
# Remplace "cat" OU "dog" par "animal"

# Groupes avec alternatives
sed -E 's/(Mr|Mrs|Ms)\.? //' fichier
# Supprime "Mr", "Mrs", "Ms" avec ou sans point
```

> [!example] Cas pratiques avec regex
> 
> ```bash
> # Valider et extraire des adresses email
> sed -En 's/.*([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}).*/\1/p' fichier
> 
> # Remplacer les adresses IPv4
> sed -E 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/XXX.XXX.XXX.XXX/g' logs.txt
> 
> # Nettoyer les espaces multiples
> sed 's/  \+/ /g' fichier                    # Basique
> sed -E 's/  +/ /g' fichier                   # Étendu
> 
> # Supprimer les espaces en début et fin de ligne
> sed 's/^[[:space:]]*//; s/[[:space:]]*$//' fichier
> 
> # Extraire le chemin d'un fichier
> echo "/home/user/docs/file.txt" | sed -E 's|(.*/)[^/]+|\1|'
> # Résultat : /home/user/docs/
> ```

### Échappement des caractères spéciaux

```bash
# Caractères à échapper dans les patterns : . * [ ] ^ $ \

# Remplacer un point littéral
sed 's/\./,/g' fichier

# Remplacer une URL (utiliser un délimiteur différent)
sed 's|http://old\.com|https://new.com|g' fichier

# Remplacer des crochets
sed 's/\[/\{/g; s/\]/\}/g' fichier
```

> [!warning] Attention aux métacaractères Dans le remplacement, seuls ces caractères sont spéciaux : `&`, `\`, `/` (ou le délimiteur), et `\n`
> 
> ```bash
> # Pattern : échapper . * [ ] ^ $ \
> sed 's/\$100/\$200/' fichier
> 
> # Remplacement : échapper & \ et le délimiteur
> sed 's/price/cost \& tax/' fichier  # Échappe &
> ```

---

## ⚠️ Pièges courants

### 1. Oublier les quotes

```bash
# ❌ ERREUR : sans quotes, le shell interprète les caractères spéciaux
sed s/foo/bar/ fichier           # Peut causer des erreurs
sed s/$USER/admin/ fichier       # $USER est évalué par le shell !

# ✅ CORRECT : toujours utiliser des quotes simples
sed 's/foo/bar/' fichier
sed 's/$USER/admin/' fichier     # $USER reste littéral
```

> [!tip] Quand utiliser des doubles quotes ? Utilisez des doubles quotes UNIQUEMENT si vous voulez que le shell évalue des variables :
> 
> ```bash
> name="John"
> sed "s/USER/$name/" fichier    # Remplace USER par John
> ```

### 2. Confusion entre sed et le fichier modifié

```bash
# ❌ ERREUR : sed affiche sur stdout par défaut
sed 's/foo/bar/' fichier         # Affiche le résultat, ne modifie pas le fichier

# ✅ Solutions :
# Option 1 : Rediriger vers un nouveau fichier
sed 's/foo/bar/' fichier > fichier_modifie

# Option 2 : Utiliser -i pour modifier in-place
sed -i 's/foo/bar/' fichier

# ❌ NE JAMAIS FAIRE : rediriger vers le même fichier !
sed 's/foo/bar/' fichier > fichier   # Vide le fichier !
```

### 3. Flag g oublié

```bash
# ❌ Sans g : remplace seulement la première occurrence
echo "foo foo foo" | sed 's/foo/bar/'
# Résultat : bar foo foo

# ✅ Avec g : remplace toutes les occurrences
echo "foo foo foo" | sed 's/foo/bar/g'
# Résultat : bar bar bar
```

### 4. Délimiteurs dans les chemins

```bash
# ❌ DIFFICILE À LIRE : échappement des /
sed 's/\/home\/user/\/opt\/app/' config

# ✅ MIEUX : changer le délimiteur
sed 's|/home/user|/opt/app|' config
sed 's#/home/user#/opt/app#' config
```

### 5. Regex basiques vs étendues

```bash
# ❌ ERREUR : + non échappé en regex basique
sed 's/a+/b/' fichier            # Cherche "a+" littéralement !

# ✅ Solutions :
# Option 1 : Échapper le +
sed 's/a\+/b/' fichier

# Option 2 : Utiliser -E pour regex étendues
sed -E 's/a+/b/' fichier
```

### 6. Ordre des commandes multiples

```bash
# L'ordre compte !

# ❌ Problème : la deuxième substitution annule la première
sed 's/foo/bar/; s/bar/baz/' fichier
# foo → bar → baz (résultat final : baz)

# ✅ Solution : être conscient de l'ordre
sed 's/bar/baz/; s/foo/bar/' fichier
# bar → baz, foo → bar (résultats différents)
```

### 7. Lignes vides et whitespace

```bash
# ❌ Ne supprime pas les lignes avec des espaces
sed '/^$/d' fichier

# ✅ Supprime aussi les lignes avec uniquement des espaces
sed '/^[[:space:]]*$/d' fichier
```

### 8. Modification in-place sans backup

```bash
# ❌ DANGEREUX : pas de retour en arrière possible
sed -i 's/important/data/' critical_file.conf

# ✅ SÉCURISÉ : toujours créer un backup
sed -i.bak 's/important/data/' critical_file.conf
```

### 9. Patterns qui matchent plus que prévu

```bash
# ❌ Supprime tout entre le premier START et le dernier END
sed '/START/,/END/d' fichier
# Si plusieurs blocs START...END, comportement non intuitif

# ✅ Vérifier avec -n et p d'abord
sed -n '/START/,/END/p' fichier   # Visualiser ce qui sera affecté
```

### 10. Caractères spéciaux dans le remplacement

```bash
# ❌ & a une signification spéciale (texte matché)
sed 's/foo/bar & baz/' fichier   # & sera remplacé par "foo"

# ✅ Échapper & si vous voulez le caractère littéral
sed 's/foo/bar \& baz/' fichier
```

> [!warning] Checklist avant d'exécuter
> 
> - [ ] Ai-je utilisé des quotes ?
> - [ ] Ai-je besoin du flag `g` ?
> - [ ] Ai-je créé un backup si j'utilise `-i` ?
> - [ ] Ai-je testé sur un petit échantillon d'abord ?
> - [ ] Les délimiteurs sont-ils appropriés ?
> - [ ] Ai-je échappé les caractères spéciaux ?

---

## 💡 Astuces avancées

### 1. Commandes multiples

```bash
# Méthode 1 : Séparer avec des point-virgules
sed 's/foo/bar/; s/old/new/; s/test/prod/' fichier

# Méthode 2 : Options -e multiples
sed -e 's/foo/bar/' -e 's/old/new/' -e 's/test/prod/' fichier

# Méthode 3 : Script multi-lignes
sed '
s/foo/bar/
s/old/new/
s/test/prod/
' fichier

# Méthode 4 : Fichier de script
# fichier script.sed :
# s/foo/bar/
# s/old/new/
sed -f script.sed fichier
```

### 2. Utilisation du hold space (avancé)

sed possède deux espaces mémoire : le **pattern space** (par défaut) et le **hold space** (pour stocker).

```bash
# h : copier pattern space vers hold space
# g : copier hold space vers pattern space
# x : échanger pattern space et hold space

# Exemple : inverser l'ordre de deux lignes
sed -n '1h; 2g; 2p; 1g; 1p' fichier

# Exemple : supprimer les lignes dupliquées consécutives
sed '$!N; /^\(.*\)\n\1$/!P; D' fichier
```

> [!tip] Le hold space est utile pour :
> 
> - Comparer des lignes
> - Stocker temporairement du texte
> - Réorganiser des lignes
> - Traiter des patterns multi-lignes

### 3. Traitement conditionnel avec les branches

```bash
# Syntaxe :
# :label     - Définit un label
# b label    - Branche vers un label
# t label    - Branche si substitution réussie

# Exemple : remplacer récursivement jusqu'à ce qu'il n'y ait plus de match
sed ':loop; s/foo/bar/; t loop' fichier
# Continue de remplacer foo par bar jusqu'à épuisement
```

### 4. Numérotation des lignes

```bash
# Ajouter le numéro de ligne au début
sed = fichier | sed 'N; s/\n/: /'

# Alternative avec awk (plus simple)
# awk '{print NR": "$0}' fichier

# Numéroter seulement les lignes non vides
sed '/./=' fichier | sed '/./N; s/\n/ /'
```

### 5. Traiter plusieurs fichiers

```bash
# Appliquer la même commande à plusieurs fichiers
sed -i.bak 's/old/new/g' *.txt

# Traiter différemment selon le fichier
for file in *.txt; do
    sed -i "s/FILENAME/${file}/" "$file"
done

# Concaténer avec séparateurs
sed -e '$a\\n---\n' file1.txt file2.txt file3.txt
```

### 6. Extraire et restructurer des données

```bash
# Extraire les adresses email d'un texte
sed -En 's/.*\b([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\b.*/\1/p' fichier

# Convertir CSV en format différent
sed 's/,/ | /g' data.csv

# Reformater des logs
sed -E 's/^([0-9-]+) ([0-9:]+) \[([A-Z]+)\] (.*)$/[\3] \1 \2 - \4/' app.log
```

### 7. Commentaire et décommentaire en masse

```bash
# Commenter toutes les lignes
sed 's/^/# /' config.txt

# Commenter seulement les lignes contenant un pattern
sed '/pattern/s/^/# /' config.txt

# Décommenter
sed 's/^# //' config.txt
sed 's/^#//' config.txt         # Sans espace après #

# Décommenter seulement certaines lignes
sed '/pattern/s/^# //' config.txt
```

### 8. Manipulation de fichiers INI/Config

```bash
# Changer une valeur dans une section
sed -i '/^\[section\]/,/^\[/{s/^key=.*/key=new_value/}' config.ini

# Ajouter une option dans une section
sed -i '/^\[section\]/a new_option=value' config.ini

# Supprimer une option
sed -i '/^old_option=/d' config.ini
```

### 9. Conversion de formats

```bash
# DOS vers Unix (supprimer \r)
sed 's/\r$//' dos_file.txt

# Unix vers DOS (ajouter \r)
sed 's/$/\r/' unix_file.txt

# Remplacer les tabulations par des espaces
sed 's/\t/    /g' fichier

# Remplacer les espaces par des tabulations
sed 's/    /\t/g' fichier
```

### 10. Performance et optimisation

```bash
# Stopper après N correspondances
sed '10q' fichier               # Quitte après la ligne 10 (comme head -10)

# Utiliser des patterns plus précis
sed -n '/^ERROR/p' fichier      # Plus rapide que sed -n '/ERROR/p'

# Combiner avec d'autres outils
grep "ERROR" fichier | sed 's/ERROR/ERREUR/'
# Plus rapide que sed seul sur de gros fichiers
```

### 11. Debugging des commandes sed

```bash
# Afficher ce que sed va traiter
sed -n 'l' fichier              # Liste le contenu avec caractères spéciaux visibles

# Tester pattern par pattern
sed -n '/pattern/p' fichier     # Voir ce qui matche

# Utiliser des labels pour comprendre le flux
sed -n '
/pattern/ {
    p
    a\DEBUG: Pattern trouvé
}
' fichier
```

### 12. Scripts sed réutilisables

Créez un fichier `clean_logs.sed` :

```sed
# Supprimer les lignes vides
/^$/d

# Supprimer les commentaires
/^#/d

# Remplacer les niveaux de log
s/\[DEBUG\]/[DBG]/g
s/\[INFO\]/[INF]/g
s/\[WARNING\]/[WRN]/g
s/\[ERROR\]/[ERR]/g

# Formater les timestamps
s/([0-9]{4})-([0-9]{2})-([0-9]{2})/\1\/\2\/\3/
```

Utilisation :

```bash
sed -Ef clean_logs.sed application.log > cleaned.log
```

### 13. One-liners utiles

```bash
# Doubler l'espacement d'un fichier
sed G fichier

# Tripler l'espacement
sed 'G;G' fichier

# Supprimer l'espacement double (garder lignes simples)
sed 'n;d' fichier

# Centrer du texte (largeur 80)
sed -e :a -e 's/^.\{1,79\}$/ & /;ta' fichier

# Inverser l'ordre des lignes (comme tac)
sed '1!G;h;$!d' fichier

# Afficher les lignes dupliquées
sed -n '/^\(.*\)\n\1$/p' fichier

# Supprimer les N premières lignes et garder le reste
sed '1,10d' fichier             # Supprime les 10 premières lignes
```

### 14. Combinaison avec d'autres commandes

```bash
# sed + find : modifier tous les fichiers d'une arborescence
find . -type f -name "*.txt" -exec sed -i 's/old/new/g' {} \;

# sed + xargs : traitement parallèle
find . -name "*.log" | xargs -P 4 sed -i 's/ERROR/ERREUR/g'

# sed + while : traitement ligne par ligne avec logique complexe
while IFS= read -r line; do
    echo "$line" | sed 's/pattern/replacement/'
done < fichier

# Pipeline complexe
cat data.csv | sed '1d' | sed 's/,/|/g' | sed 's/$/;/' > output.txt
```

### 15. Gestion des encodages

```bash
# Convertir l'encodage avant traitement
iconv -f ISO-8859-1 -t UTF-8 fichier.txt | sed 's/é/e/g'

# Traiter avec un encodage spécifique
LANG=fr_FR.UTF-8 sed 's/été/ete/g' fichier.txt
```

> [!tip] Astuce pro Pour des transformations complexes impliquant plusieurs conditions, considérez l'utilisation d'un langage de script plus puissant (awk, Python, Perl). sed excelle dans les transformations simples et rapides, mais peut devenir difficile à maintenir pour des logiques complexes.

---

## 🎓 Conclusion

Vous maîtrisez maintenant **sed**, un outil puissant pour l'édition de texte en ligne de commande. Les points clés à retenir :

- **Substitution** (`s///`) : L'opération la plus courante
- **Flags** (`g`, `i`, nombres) : Contrôlent le comportement des substitutions
- **Suppression** (`d`), **insertion** (`i`/`a`), **remplacement** (`c`) : Manipulation des lignes
- **Affichage sélectif** (`p` avec `-n`) : Filtrage précis
- **Plages** : Application ciblée des commandes
- **Modification in-place** (`-i`) : Édition directe des fichiers
- **Regex** : Puissance maximale pour le pattern matching

> [!tip] Pour aller plus loin
> 
> - Explorez le **hold space** pour des transformations complexes
> - Combinez sed avec d'autres outils Unix (grep, awk, cut)
> - Créez des scripts sed réutilisables pour vos tâches fréquentes
> - Pratiquez sur des cas réels pour développer votre intuition

**sed** est un outil indispensable dans la boîte à outils de tout administrateur système et développeur travaillant en environnement Unix/Linux. Sa maîtrise vous permettra d'automatiser efficacement vos tâches de traitement de texte.