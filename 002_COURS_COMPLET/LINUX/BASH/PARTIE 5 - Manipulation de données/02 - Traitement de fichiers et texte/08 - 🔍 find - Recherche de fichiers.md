
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

La commande `find` est un outil puissant pour rechercher des fichiers et répertoires dans une arborescence. Contrairement à `locate` qui utilise une base de données, `find` explore le système de fichiers en temps réel, ce qui la rend plus lente mais aussi plus précise et flexible.

> [!info] Pourquoi utiliser find ?
> 
> - **Recherche en temps réel** : trouve les fichiers créés récemment
> - **Critères multiples** : combine nom, taille, date, permissions, etc.
> - **Actions automatiques** : peut exécuter des commandes sur les résultats
> - **Contrôle précis** : profondeur de recherche, exclusions, etc.

---

## Syntaxe de base

```bash
find [chemin...] [critères] [actions]
```

**Composants :**

- **chemin** : point de départ de la recherche (`.` pour le répertoire courant)
- **critères** : conditions de recherche (nom, taille, type, etc.)
- **actions** : opérations à effectuer sur les résultats

> [!example] Exemple basique
> 
> ```bash
> # Lister tous les fichiers et répertoires dans le répertoire courant
> find .
> 
> # Rechercher dans plusieurs chemins
> find /home /var /tmp -name "*.log"
> ```

---

## Recherche par nom

### `-name` : Recherche sensible à la casse

```bash
# Rechercher un fichier exact
find /home -name "document.txt"

# Utiliser des wildcards
find . -name "*.pdf"           # Tous les PDF
find . -name "report_*"        # Fichiers commençant par report_
find . -name "*2024*"          # Contenant 2024
```

### `-iname` : Recherche insensible à la casse

```bash
# Trouve document.txt, DOCUMENT.TXT, Document.Txt, etc.
find /home -iname "document.txt"

# Très utile pour les extensions
find . -iname "*.jpg"  # Trouve .jpg, .JPG, .Jpg, etc.
```

> [!warning] Attention aux guillemets Toujours mettre les patterns avec wildcards entre guillemets pour éviter que le shell ne les interprète avant `find`.
> 
> ```bash
> # ❌ Incorrect (le shell interprète le *)
> find . -name *.txt
> 
> # ✅ Correct
> find . -name "*.txt"
> ```

### Recherche de fichiers sans extension

```bash
# Fichiers ne contenant pas de point
find . -type f ! -name "*.*"

# Fichiers dont le nom ne se termine pas par une extension
find . -type f ! -name "*.*" -o -name ".*"
```

---

## Recherche par type

L'option `-type` permet de filtrer par type d'élément.

```bash
# Types courants
find . -type f    # Fichiers réguliers
find . -type d    # Répertoires
find . -type l    # Liens symboliques
find . -type s    # Sockets
find . -type p    # Pipes nommés
find . -type b    # Périphériques bloc
find . -type c    # Périphériques caractère
```

> [!example] Exemples pratiques
> 
> ```bash
> # Tous les répertoires nommés "backup"
> find /home -type d -name "backup"
> 
> # Tous les fichiers PDF (pas les dossiers nommés *.pdf)
> find . -type f -name "*.pdf"
> 
> # Tous les liens symboliques cassés
> find . -type l ! -exec test -e {} \; -print
> ```

|Type|Description|Usage|
|---|---|---|
|`f`|Fichier régulier|Le plus utilisé|
|`d`|Répertoire|Organisation, nettoyage|
|`l`|Lien symbolique|Détecter liens cassés|
|`s`|Socket|Administration système|

---

## Recherche par taille

L'option `-size` permet de rechercher par taille de fichier.

### Syntaxe

```bash
find . -size [+/-]N[unité]
```

**Unités disponibles :**

- `c` : octets (bytes)
- `k` : kilo-octets (1024 bytes)
- `M` : méga-octets (1024 KB)
- `G` : giga-octets (1024 MB)

**Préfixes :**

- `+N` : plus grand que N
- `-N` : plus petit que N
- `N` : exactement N

### Exemples

```bash
# Fichiers de plus de 100 Mo
find . -type f -size +100M

# Fichiers de moins de 1 Ko
find . -type f -size -1k

# Fichiers entre 10 et 50 Mo
find . -type f -size +10M -size -50M

# Fichiers vides (0 octets)
find . -type f -size 0c
# ou plus simple :
find . -type f -empty
```

> [!tip] Trouver les gros fichiers
> 
> ```bash
> # Les 10 plus gros fichiers du système
> find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | \
>   sort -k5 -hr | head -10
> 
> # Fichiers de plus de 1 Go dans /home
> find /home -type f -size +1G -exec du -h {} \; | sort -hr
> ```

---

## Recherche par date

`find` offre trois critères temporels basés sur le nombre de jours.

### Options de temps

```bash
-mtime N    # Date de modification du contenu (modified)
-atime N    # Date de dernier accès (accessed)
-ctime N    # Date de changement des métadonnées (changed)
```

**Notation :**

- `+N` : plus vieux que N jours
- `-N` : plus récent que N jours
- `N` : exactement il y a N jours

### Exemples

```bash
# Fichiers modifiés dans les dernières 24 heures
find . -type f -mtime -1

# Fichiers modifiés il y a plus de 30 jours
find . -type f -mtime +30

# Fichiers non accédés depuis 180 jours
find . -type f -atime +180

# Fichiers modifiés il y a exactement 7 jours
find . -type f -mtime 7
```

### Options en minutes

Pour plus de précision, utilisez les variantes en minutes :

```bash
-mmin N    # Modification en minutes
-amin N    # Accès en minutes
-cmin N    # Changement en minutes
```

```bash
# Fichiers modifiés dans les 30 dernières minutes
find . -type f -mmin -30

# Fichiers créés il y a plus de 2 heures
find . -type f -cmin +120
```

> [!example] Cas pratique : Nettoyage des logs
> 
> ```bash
> # Supprimer les logs de plus de 90 jours
> find /var/log -type f -name "*.log" -mtime +90 -delete
> 
> # Fichiers temporaires non accédés depuis 7 jours
> find /tmp -type f -atime +7 -delete
> ```

### Comparaison avec un fichier de référence

```bash
# Plus récent que fichier.txt
find . -newer fichier.txt

# Plus ancien que fichier.txt
find . ! -newer fichier.txt
```

---

## Contrôle de la profondeur

Les options `-maxdepth` et `-mindepth` contrôlent la profondeur de recherche dans l'arborescence.

### `-maxdepth N` : Profondeur maximale

```bash
# Rechercher uniquement dans le répertoire courant (pas de sous-dossiers)
find . -maxdepth 1 -name "*.txt"

# Descendre au maximum 2 niveaux
find /home -maxdepth 2 -name "config"
```

### `-mindepth N` : Profondeur minimale

```bash
# Ignorer le répertoire courant, commencer au niveau 2
find . -mindepth 2 -name "*.log"

# Combiner les deux
find . -mindepth 1 -maxdepth 3 -type d
```

> [!info] Notation de profondeur
> 
> - Niveau 1 : le répertoire de départ
> - Niveau 2 : les sous-répertoires directs
> - Niveau 3 : les sous-sous-répertoires, etc.

**Exemple d'arborescence :**

```
.                           # Niveau 1
├── fichier1.txt           # Niveau 1
├── dossierA/              # Niveau 2
│   ├── fichier2.txt       # Niveau 2
│   └── sous-dossier/      # Niveau 3
│       └── fichier3.txt   # Niveau 3
└── dossierB/              # Niveau 2
    └── fichier4.txt       # Niveau 2
```

```bash
# maxdepth 1 : trouve uniquement fichier1.txt
find . -maxdepth 1 -type f

# maxdepth 2 : trouve fichier1.txt, fichier2.txt, fichier4.txt
find . -maxdepth 2 -type f

# mindepth 2 : trouve fichier2.txt, fichier3.txt, fichier4.txt
find . -mindepth 2 -type f
```

> [!tip] Performance Utiliser `-maxdepth` en début de commande améliore les performances en limitant la recherche.

---

## Exclure des répertoires

L'option `-prune` permet d'exclure des répertoires de la recherche.

### Syntaxe de base

```bash
find . -path "./dossier_a_exclure" -prune -o [critères] -print
```

**Composants :**

- `-path` : spécifie le chemin à exclure
- `-prune` : empêche la descente dans ce répertoire
- `-o` : opérateur OR (ou)
- `-print` : affiche les résultats (nécessaire avec -prune)

### Exemples

```bash
# Exclure le dossier .git
find . -path "./.git" -prune -o -type f -print

# Exclure plusieurs dossiers
find . \( -path "./node_modules" -o -path "./.git" \) -prune -o -type f -print

# Exclure tous les dossiers cachés
find . -path "*/.*" -prune -o -type f -print

# Exclure par pattern
find . -path "*/temp*" -prune -o -name "*.txt" -print
```

> [!warning] Syntaxe avec -prune La structure `-prune -o ... -print` est essentielle :
> 
> - Sans `-print`, vous verrez aussi les dossiers exclus
> - L'ordre des options est important
> - Les parenthèses `\(` et `\)` sont nécessaires pour grouper plusieurs exclusions

### Alternative avec `-not` ou `!`

```bash
# Équivalent sans -prune (mais moins performant)
find . ! -path "./.git/*" -type f

# Exclure les fichiers d'un dossier
find . -type f ! -path "./backup/*"
```

> [!example] Cas pratique : Recherche dans un projet
> 
> ```bash
> # Chercher des fichiers Python en excluant les dossiers virtuels
> find . \( -path "./venv" -o -path "./__pycache__" \) \
>   -prune -o -name "*.py" -print
> 
> # Trouver des fichiers sans descendre dans les dossiers de build
> find . \( -name "build" -o -name "dist" -o -name "*.egg-info" \) \
>   -prune -o -type f -name "*.py" -print
> ```

---

## Exécuter des commandes

L'option `-exec` permet d'exécuter une commande sur chaque résultat trouvé.

### Syntaxe de base

```bash
find . [critères] -exec commande {} \;
```

**Éléments clés :**

- `{}` : remplacé par le nom du fichier trouvé
- `\;` : termine la commande (le backslash échappe le point-virgule)

### Exemples simples

```bash
# Afficher les détails de chaque fichier trouvé
find . -name "*.log" -exec ls -lh {} \;

# Copier tous les PDF dans un dossier
find . -name "*.pdf" -exec cp {} /destination/ \;

# Afficher le type de chaque fichier
find . -type f -exec file {} \;

# Compter les lignes de tous les fichiers .txt
find . -name "*.txt" -exec wc -l {} \;
```

### `-exec` avec `+` : Mode optimisé

```bash
find . -name "*.txt" -exec commande {} +
```

Utilise `+` au lieu de `\;` pour regrouper plusieurs fichiers en un seul appel :

```bash
# Au lieu de : rm fichier1 ; rm fichier2 ; rm fichier3
# Exécute : rm fichier1 fichier2 fichier3
find . -name "*.tmp" -exec rm {} +

# Afficher tous les fichiers en une seule commande ls
find . -type f -exec ls -lh {} +
```

> [!tip] Performance : ; vs +
> 
> - `\;` : lance la commande pour **chaque fichier** (lent)
> - `+` : lance la commande **une fois** avec tous les fichiers (rapide)
> 
> Utilisez `+` quand possible, sauf si la commande doit s'exécuter individuellement.

### `-execdir` : Exécuter dans le répertoire du fichier

```bash
# Exécute la commande dans le dossier contenant chaque fichier
find . -name "Makefile" -execdir make \;

# Utile pour des opérations relatives
find . -name "*.jpg" -execdir convert {} {}.png \;
```

### Confirmation interactive avec `-ok`

```bash
# Demande confirmation pour chaque fichier
find . -name "*.bak" -ok rm {} \;
```

> [!example] Exemples avancés
> 
> ```bash
> # Changer les permissions de tous les scripts
> find . -type f -name "*.sh" -exec chmod +x {} +
> 
> # Remplacer du texte dans tous les fichiers
> find . -name "*.txt" -exec sed -i 's/ancien/nouveau/g' {} +
> 
> # Créer une archive de tous les fichiers modifiés aujourd'hui
> find . -type f -mtime -1 -exec tar -rvf backup.tar {} +
> 
> # Afficher la taille totale des fichiers trouvés
> find . -name "*.log" -exec du -ch {} + | tail -1
> ```

---

## Supprimer des fichiers

L'option `-delete` supprime les fichiers trouvés.

### Syntaxe

```bash
find . [critères] -delete
```

> [!warning] ⚠️ ATTENTION : Danger !
> 
> - `-delete` est **irréversible**
> - Testez **toujours** votre commande sans `-delete` d'abord
> - `-delete` implique automatiquement `-depth` (traite les fichiers avant les dossiers)

### Processus de sécurité

```bash
# 1. Tester la commande sans -delete
find . -name "*.tmp"

# 2. Vérifier les résultats
find . -name "*.tmp" -ls

# 3. Si tout est correct, supprimer
find . -name "*.tmp" -delete
```

### Exemples

```bash
# Supprimer les fichiers temporaires
find . -name "*.tmp" -delete

# Supprimer les fichiers vides
find . -type f -empty -delete

# Supprimer les anciens logs
find /var/log -name "*.log" -mtime +30 -delete

# Supprimer les répertoires vides
find . -type d -empty -delete
```

### Alternative avec `-exec`

Pour plus de contrôle ou de flexibilité :

```bash
# Avec confirmation
find . -name "*.bak" -ok rm {} \;

# Avec force (attention !)
find . -name "*.tmp" -exec rm -f {} +

# Supprimer des répertoires non vides
find . -name "node_modules" -type d -exec rm -rf {} +
```

> [!example] Nettoyage système
> 
> ```bash
> # Supprimer les caches de plus de 7 jours
> find ~/.cache -type f -mtime +7 -delete
> 
> # Nettoyer les fichiers de compilation
> find . \( -name "*.pyc" -o -name "*.pyo" -o -name "__pycache__" \) -delete
> 
> # Supprimer les sauvegardes anciennes
> find ./backups -name "*.bak" -mtime +90 -delete
> ```

> [!tip] Compter avant de supprimer
> 
> ```bash
> # Voir combien de fichiers seront supprimés
> find . -name "*.tmp" | wc -l
> 
> # Voir l'espace qui sera libéré
> find . -name "*.tmp" -exec du -ch {} + | tail -1
> ```

---

## Combinaison de critères

`find` utilise des opérateurs logiques pour combiner plusieurs critères.

### Opérateurs logiques

|Opérateur|Syntaxe|Description|
|---|---|---|
|**ET**|`-a` ou rien|Les deux conditions doivent être vraies (par défaut)|
|**OU**|`-o`|Au moins une condition doit être vraie|
|**NON**|`!` ou `-not`|Inverse la condition|
|**Groupement**|`\( ... \)`|Groupe les conditions|

### ET logique (par défaut)

```bash
# Fichiers .txt de plus de 1 Mo (ET implicite)
find . -name "*.txt" -size +1M

# Équivalent avec -a explicite
find . -name "*.txt" -a -size +1M

# Fichiers modifiés aujourd'hui ET appartenant à user
find . -mtime -1 -user user
```

### OU logique (`-o`)

```bash
# Fichiers .txt OU .pdf
find . -name "*.txt" -o -name "*.pdf"

# Fichiers de plus de 100M OU modifiés il y a plus de 30 jours
find . -size +100M -o -mtime +30

# Plusieurs extensions
find . \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" \)
```

### NON logique (`!` ou `-not`)

```bash
# Tous les fichiers SAUF les .txt
find . -type f ! -name "*.txt"

# Fichiers PAS dans le dossier backup
find . ! -path "*/backup/*"

# Fichiers NON vides
find . -type f ! -empty
```

### Combinaisons complexes

```bash
# (A ET B) OU C
find . \( -name "*.log" -size +10M \) -o -name "error.txt"

# A ET (B OU C)
find . -type f \( -name "*.jpg" -o -name "*.png" \) -size +1M

# PAS (A OU B)
find . ! \( -name "*.tmp" -o -name "*.bak" \)

# (A OU B) ET (C OU D)
find . \( -name "*.txt" -o -name "*.md" \) \
  \( -mtime -7 -o -size +1M \)
```

> [!example] Exemples pratiques
> 
> ```bash
> # Images récentes ou volumineuses
> find . \( -name "*.jpg" -o -name "*.png" \) \
>   \( -mtime -30 -o -size +5M \)
> 
> # Fichiers sources modifiés, sauf dans node_modules
> find . \( -name "*.js" -o -name "*.jsx" \) \
>   ! -path "*/node_modules/*" \
>   -mtime -7
> 
> # Logs anciens ou volumineux à nettoyer
> find /var/log \( -name "*.log" -o -name "*.log.*" \) \
>   \( -mtime +90 -o -size +100M \) \
>   -delete
> 
> # Fichiers sans extension ou avec extension spécifique
> find . -type f \( ! -name "*.*" -o -name "*.sh" \)
> ```

### Priorité des opérateurs

```bash
# Attention à la priorité !
# Ceci : (A ET B) OU C
find . -name "*.txt" -size +1M -o -name "*.pdf"

# Ceci : A ET (B OU C)
find . -name "*.txt" \( -size +1M -o -name "*.pdf" \)
```

> [!warning] Ordre d'évaluation
> 
> - `!` a la priorité la plus haute
> - `-a` (ET) est évalué avant `-o` (OU)
> - Utilisez des parenthèses `\( \)` pour clarifier les groupements complexes

---

## Pièges courants

### 1. Oublier les guillemets avec les wildcards

```bash
# ❌ Incorrect - le shell interprète le *
find . -name *.txt

# ✅ Correct
find . -name "*.txt"
```

### 2. Confusion entre `-mtime` et `-mmin`

```bash
# ❌ Cherche les fichiers modifiés il y a plus de 1 jour
find . -mtime +1

# ✅ Pour "dans les dernières 24h", utiliser -1
find . -mtime -1

# ✅ Pour "dans la dernière heure", utiliser -mmin
find . -mmin -60
```

### 3. Oublier `-print` avec `-prune`

```bash
# ❌ Affiche aussi les dossiers exclus
find . -path "./test" -prune -o -name "*.txt"

# ✅ Correct
find . -path "./test" -prune -o -name "*.txt" -print
```

### 4. Utiliser `-delete` sans tester

```bash
# ❌ Dangereux - suppression immédiate
find . -name "*.txt" -delete

# ✅ Tester d'abord
find . -name "*.txt"
# Puis si OK :
find . -name "*.txt" -delete
```

### 5. Ordre des options avec `-delete`

```bash
# ❌ Incorrect - -delete doit être en dernier
find . -delete -name "*.tmp"

# ✅ Correct
find . -name "*.tmp" -delete
```

### 6. Chemins relatifs avec `-exec`

```bash
# ❌ Peut échouer si le chemin est relatif
find . -name "*.txt" -exec cp {} ~/backup/ \;

# ✅ Utiliser un chemin absolu
find . -name "*.txt" -exec cp {} "$HOME/backup/" \;

# ✅ Ou utiliser -execdir
find . -name "*.txt" -execdir cp {} ~/backup/ \;
```

### 7. Performance avec de grands volumes

```bash
# ❌ Lent - lance une commande par fichier
find . -name "*.txt" -exec wc -l {} \;

# ✅ Rapide - une seule commande pour tous les fichiers
find . -name "*.txt" -exec wc -l {} +
```

### 8. Permissions insuffisantes

```bash
# ❌ Beaucoup d'erreurs "Permission denied"
find / -name "config.txt"

# ✅ Rediriger les erreurs
find / -name "config.txt" 2>/dev/null

# ✅ Ou utiliser sudo si nécessaire
sudo find / -name "config.txt"
```

---

## Astuces avancées

### 1. Recherche avec regex

```bash
# Utiliser -regex (ERE par défaut)
find . -regex ".*/[0-9]{4}-[0-9]{2}-[0-9]{2}.*\.log"

# POSIX extended regex
find . -regextype posix-extended -regex ".*\.(jpg|png|gif)"

# POSIX basic regex
find . -regextype posix-basic -regex ".*\.txt$"
```

### 2. Combiner find avec d'autres commandes

```bash
# Compter le nombre total de lignes dans tous les .py
find . -name "*.py" -exec cat {} + | wc -l

# Créer une liste de fichiers pour traitement ultérieur
find . -name "*.txt" > fichiers.txt

# Utiliser xargs pour traitement en batch
find . -name "*.log" | xargs grep "ERROR"

# Avec xargs et sécurité pour les espaces
find . -name "*.log" -print0 | xargs -0 grep "ERROR"
```

### 3. Trouver les doublons

```bash
# Fichiers avec le même nom
find . -type f -printf "%f\n" | sort | uniq -d

# Avec leur chemin complet
find . -type f -exec basename {} \; | sort | uniq -d | while read fname; do
    find . -name "$fname"
done
```

### 4. Opérations conditionnelles

```bash
# Si le fichier existe, faire quelque chose
find . -name "config.txt" -exec test -f {} \; -print

# Fichiers exécutables
find . -type f -executable

# Fichiers avec permissions spécifiques
find . -type f -perm 644
find . -type f -perm /u+x  # Au moins exécutable par le propriétaire
```

### 5. Recherche par propriétaire

```bash
# Fichiers appartenant à un utilisateur
find / -user www-data 2>/dev/null

# Fichiers d'un groupe
find / -group developers 2>/dev/null

# Fichiers sans propriétaire
find / -nouser -o -nogroup
```

### 6. Optimisation des performances

```bash
# Utiliser -maxdepth tôt dans la commande
find . -maxdepth 2 -name "*.txt"  # ✅ Rapide

# Éviter les recherches inutiles
find . -name "*.txt" -path "*/test/*" -prune  # ✅ Exclut /test

# Utiliser + au lieu de \; pour -exec
find . -name "*.txt" -exec cat {} +  # ✅ Plus rapide
```

### 7. Formatage personnalisé

```bash
# Affichage personnalisé avec -printf
find . -name "*.txt" -printf "%p - %s bytes - %t\n"

# Format: chemin | taille | date
find . -type f -printf "%p | %k KB | %TY-%Tm-%Td\n"

# Trier par taille
find . -type f -printf "%s\t%p\n" | sort -n
```

### 8. Travailler avec les liens symboliques

```bash
# Suivre les liens symboliques
find -L . -name "*.txt"

# Ne jamais suivre les liens
find -P . -name "*.txt"

# Trouver les liens cassés
find . -type l ! -exec test -e {} \; -print

# Résoudre les liens symboliques
find . -type l -exec readlink -f {} \;
```

### 9. Recherche de fichiers modifiés entre deux dates

```bash
# Créer des fichiers de référence
touch -t 202401010000 /tmp/start
touch -t 202412310000 /tmp/end

# Trouver les fichiers dans cet intervalle
find . -newer /tmp/start ! -newer /tmp/end
```

### 10. Statistiques sur les résultats

```bash
# Nombre de fichiers trouvés
find . -name "*.txt" | wc -l

# Taille totale
find . -name "*.txt" -exec du -ch {} + | tail -1

# Répartition par extension
find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn

# Fichiers par année de modification
find . -type f -printf "%TY\n" | sort | uniq -c
```

---

## 💡 Récapitulatif

> [!info] Points clés à retenir
> 
> **Syntaxe de base :**
> 
> - `find chemin critères actions`
> - Toujours tester avant de supprimer
> - Utiliser les guillemets pour les wildcards
> 
> **Critères principaux :**
> 
> - `-name` / `-iname` : recherche par nom
> - `-type` : type de fichier (f, d, l)
> - `-size` : taille (+100M, -1k)
> - `-mtime` / `-mmin` : date de modification
> 
> **Contrôle :**
> 
> - `-maxdepth` / `-mindepth` : profondeur
> - `-prune` : exclure des répertoires
> 
> **Actions :**
> 
> - `-exec cmd {} \;` : exécuter commande (une par fichier)
> - `-exec cmd {} +` : exécuter commande (groupée, plus rapide)
> - `-delete` : supprimer les fichiers
> 
> **Opérateurs logiques :**
> 
> - ET : `-a` ou implicite
> - OU : `-o`
> - NON : `!` ou `-not`
> - Groupement : `\( ... \)`
> 
> **Bonnes pratiques :**
> 
> - Commencer par des recherches simples
> - Utiliser `-maxdepth` pour limiter la profondeur
> - Toujours tester sans `-delete` d'abord
> - Préférer `+` à `\;` pour les performances
> - Rediriger les erreurs avec `2>/dev/null`

---

## 📚 Exemples de cas d'usage complets

### Maintenance système

```bash
# Nettoyer les fichiers temporaires de plus de 7 jours
find /tmp -type f -mtime +7 -delete

# Trouver les gros fichiers (plus de 500 Mo)
find / -type f -size +500M -exec ls -lh {} \; 2>/dev/null

# Fichiers logs de plus de 30 jours
find /var/log -name "*.log" -mtime +30 -exec gzip {} \;

# Répertoires vides à supprimer
find /home -type d -empty -delete
```

### Développement

```bash
# Trouver tous les fichiers Python sauf dans venv
find . -name "*.py" ! -path "*/venv/*" ! -path "*/__pycache__/*"

# Fichiers modifiés dans les dernières 2 heures (pour debug)
find . -type f -mmin -120 -ls

# Compter les lignes de code du projet
find . -name "*.py" ! -path "*/venv/*" -exec cat {} + | wc -l

# Trouver les TODO dans le code
find . -name "*.py" -exec grep -H "TODO" {} \;
```

### Gestion de médias

```bash
# Redimensionner toutes les images
find ./photos -name "*.jpg" -exec convert {} -resize 1920x1080 {} \;

# Déplacer les photos par année
find . -name "*.jpg" -newermt 2024-01-01 ! -newermt 2024-12-31 \
  -exec mv {} ./2024/ \;

# Trouver les images de plus de 5 Mo
find . \( -name "*.jpg" -o -name "*.png" \) -size +5M

# Convertir tous les PNG en JPG
find . -name "*.png" -exec sh -c 'convert "$1" "${1%.png}.jpg"' _ {} \;
```

### Sauvegarde et archivage

```bash
# Créer une archive des fichiers modifiés aujourd'hui
find . -type f -mtime -1 -exec tar -rvf backup_$(date +%Y%m%d).tar {} +

# Copier les fichiers récents vers un serveur
find . -type f -mtime -7 -exec scp {} user@server:/backup/ \;

# Trouver les fichiers à sauvegarder (modifiés, pas de backup)
find . -type f -mtime -30 ! -name "*.bak" ! -path "*/backup/*"

# Compresser les vieux fichiers logs
find /var/log -name "*.log" -mtime +90 -exec gzip {} \;
```

### Sécurité et permissions

```bash
# Trouver les fichiers avec permissions 777 (dangereux)
find / -type f -perm 0777 2>/dev/null

# Fichiers SUID (potentiellement dangereux)
find / -perm -4000 -type f 2>/dev/null

# Fichiers modifiables par tous
find / -perm -002 -type f 2>/dev/null

# Corriger les permissions des scripts
find . -name "*.sh" -exec chmod 755 {} +
```

### Recherche de contenu

```bash
# Chercher un mot dans tous les fichiers
find . -type f -exec grep -l "mot_clé" {} +

# Fichiers contenant une IP
find . -type f -exec grep -l "192.168.1.1" {} \;

# Remplacer du texte dans tous les fichiers
find . -name "*.txt" -exec sed -i 's/ancien/nouveau/g' {} +

# Trouver les fichiers avec une chaîne spécifique
find . -type f -exec grep -H "ERROR" {} + 2>/dev/null
```

---

## 🎯 Commandes find les plus utiles au quotidien

```bash
# 1. Trouver un fichier par nom (insensible à la casse)
find . -iname "nomfichier*"

# 2. Fichiers modifiés récemment (dernières 24h)
find . -type f -mtime -1

# 3. Gros fichiers (plus de 100 Mo)
find . -type f -size +100M

# 4. Supprimer les fichiers temporaires
find . -name "*.tmp" -o -name "*.bak" -delete

# 5. Chercher dans le répertoire courant uniquement
find . -maxdepth 1 -name "*.txt"

# 6. Exécuter une commande sur les résultats
find . -name "*.log" -exec tail -n 5 {} +

# 7. Exclure un dossier de la recherche
find . -path "./node_modules" -prune -o -name "*.js" -print

# 8. Compter les fichiers d'un type
find . -name "*.py" | wc -l

# 9. Lister avec détails et trier par taille
find . -type f -exec ls -lh {} + | sort -k5 -h

# 10. Trouver et copier vers un autre emplacement
find . -name "*.pdf" -exec cp {} ~/Documents/ \;
```

---

## ⚡ Aide-mémoire rapide

|Action|Commande|
|---|---|
|Chercher par nom|`find . -name "fichier.txt"`|
|Insensible à la casse|`find . -iname "fichier.txt"`|
|Fichiers seulement|`find . -type f`|
|Dossiers seulement|`find . -type d`|
|Plus de 10 Mo|`find . -size +10M`|
|Modifié dernières 24h|`find . -mtime -1`|
|Modifié dernière heure|`find . -mmin -60`|
|Profondeur 1 niveau|`find . -maxdepth 1`|
|Exclure dossier|`find . -path "./test" -prune -o -print`|
|Exécuter commande|`find . -name "*.txt" -exec cat {} +`|
|Supprimer|`find . -name "*.tmp" -delete`|
|Fichiers vides|`find . -type f -empty`|
|ET logique|`find . -name "*.txt" -size +1M`|
|OU logique|`find . -name "*.txt" -o -name "*.md"`|
|NON logique|`find . ! -name "*.txt"`|

---

## 🔗 Différences avec d'autres commandes

|Commande|Usage|Avantages|Inconvénients|
|---|---|---|---|
|`find`|Recherche en temps réel|Précis, flexible, temps réel|Plus lent|
|`locate`|Recherche dans base de données|Très rapide|Base à jour quotidiennement|
|`grep -r`|Recherche dans contenu|Cherche le contenu|Ne cherche pas les noms|
|`ls -R`|Liste récursive|Simple|Pas de filtres avancés|

---

## 🚀 Pour aller plus loin

### Combiner find avec d'autres outils

```bash
# find + xargs (traitement parallèle)
find . -name "*.txt" -print0 | xargs -0 -P 4 gzip

# find + while (traitement ligne par ligne)
find . -name "*.log" | while read file; do
    echo "Processing: $file"
    # traitement ici
done

# find + tee (sauvegarder les résultats)
find . -name "*.txt" | tee fichiers_trouves.txt

# find + awk (traitement avancé)
find . -type f -printf "%s %p\n" | awk '{sum+=$1} END {print sum/1024/1024 " MB"}'
```

### Scripts utiles avec find

```bash
# Fonction pour trouver et éditer des fichiers
findedit() {
    local files=$(find . -name "*$1*" -type f)
    if [ -n "$files" ]; then
        echo "$files"
        read -p "Éditer ces fichiers? (o/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Oo]$ ]]; then
            $EDITOR $(find . -name "*$1*" -type f)
        fi
    fi
}

# Fonction pour trouver les plus gros fichiers
bigfiles() {
    find "${1:-.}" -type f -exec du -h {} + | sort -rh | head -n "${2:-10}"
}

# Fonction pour nettoyer les fichiers anciens
cleanup() {
    local dir="${1:-.}"
    local days="${2:-30}"
    echo "Fichiers de plus de $days jours dans $dir:"
    find "$dir" -type f -mtime +$days -ls
    read -p "Supprimer ces fichiers? (o/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        find "$dir" -type f -mtime +$days -delete
        echo "Fichiers supprimés."
    fi
}
```

### find dans les scripts shell

```bash
#!/bin/bash
# Script de sauvegarde avec find

BACKUP_DIR="/backup"
SOURCE_DIR="/home/user"
DATE=$(date +%Y%m%d)

# Créer l'archive des fichiers modifiés dans les 7 derniers jours
find "$SOURCE_DIR" -type f -mtime -7 \
    ! -path "*/.*" \
    ! -path "*/tmp/*" \
    -print0 | tar -czf "$BACKUP_DIR/backup_$DATE.tar.gz" --null -T -

# Supprimer les anciennes sauvegardes (plus de 30 jours)
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +30 -delete

echo "Sauvegarde terminée: backup_$DATE.tar.gz"
```

---

Voilà ! Le cours est maintenant complet et prêt à être copié dans Obsidian. Il couvre tous les aspects de la commande `find` de manière détaillée et pratique. 🎉