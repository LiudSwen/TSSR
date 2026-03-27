

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

## 🎯 Introduction aux tableaux indexés

Les tableaux indexés en Bash sont des structures de données qui permettent de stocker plusieurs valeurs dans une seule variable. Contrairement aux variables simples qui ne contiennent qu'une seule valeur, les tableaux peuvent contenir une liste ordonnée de valeurs accessibles par leur position (index numérique).

> [!info] Pourquoi utiliser des tableaux ?
> 
> - **Organisation** : Regrouper des données liées (liste d'utilisateurs, de fichiers, de commandes)
> - **Itération** : Parcourir facilement plusieurs valeurs avec des boucles
> - **Maintenance** : Modifier ou ajouter des éléments sans créer de nouvelles variables
> - **Scalabilité** : Gérer un nombre variable d'éléments

> [!warning] Limitation importante En Bash, les tableaux indexés utilisent des indices numériques commençant à 0. Pour des indices textuels (clé-valeur), il faut utiliser les tableaux associatifs (concept abordé dans une autre partie).

---

## 🔨 Création de tableaux

### Création avec valeurs initiales

La méthode la plus courante consiste à définir un tableau avec ses valeurs dès la création.

```bash
# Syntaxe de base : nom_tableau=(valeur1 valeur2 valeur3 ...)
fruits=(pomme poire banane orange)

# Les valeurs sont séparées par des espaces
couleurs=(rouge bleu vert jaune)

# Pour des valeurs contenant des espaces, utiliser des guillemets
phrases=("Bonjour le monde" "Au revoir" "Merci beaucoup")

# Mélange de valeurs avec et sans espaces
mix=(simple "avec espaces" autre "dernière valeur")
```

> [!example] Exemple pratique
> 
> ```bash
> # Liste de serveurs à superviser
> serveurs=(web01 web02 db01 cache01)
> 
> # Liste de fichiers de configuration
> configs=("/etc/nginx/nginx.conf" "/etc/php/php.ini" "/etc/mysql/my.cnf")
> 
> # Liste de ports
> ports=(80 443 3306 6379)
> ```

> [!tip] Astuce : valeurs dynamiques Vous pouvez créer des tableaux avec des résultats de commandes :
> 
> ```bash
> # Tous les fichiers .txt du répertoire courant
> fichiers_txt=(*.txt)
> 
> # Tous les utilisateurs du système
> utilisateurs=($(cut -d: -f1 /etc/passwd))
> 
> # Liste des processus d'un programme
> pids=($(pgrep nginx))
> ```

---

### Création de tableaux vides

Il est souvent utile de créer un tableau vide que vous remplirez progressivement dans votre script.

```bash
# Syntaxe 1 : Parenthèses vides
mon_tableau=()

# Ensuite, vous pouvez ajouter des éléments
mon_tableau+=("premier élément")
mon_tableau+=("deuxième élément")
```

> [!info] Quand créer un tableau vide ?
> 
> - Avant une boucle qui va le remplir dynamiquement
> - Quand vous ne connaissez pas encore les valeurs à l'avance
> - Pour initialiser proprement une structure de données

> [!example] Exemple : collecte de données
> 
> ```bash
> # Initialisation d'un tableau vide
> erreurs=()
> 
> # Boucle qui remplit le tableau
> for fichier in *.log; do
>     if grep -q "ERROR" "$fichier"; then
>         erreurs+=("$fichier")
>     fi
> done
> 
> # À la fin, erreurs contient tous les fichiers avec des erreurs
> echo "Fichiers avec erreurs : ${erreurs[@]}"
> ```

---

### Déclaration explicite

Bash permet de déclarer explicitement qu'une variable est un tableau avec la commande `declare`.

```bash
# Déclaration explicite d'un tableau indexé
declare -a mon_tableau

# Ensuite, vous pouvez l'utiliser normalement
mon_tableau=(val1 val2 val3)
```

> [!info] Pourquoi utiliser `declare -a` ?
> 
> - **Clarté du code** : Indique explicitement l'intention d'utiliser un tableau
> - **Éviter les erreurs** : Empêche d'écraser accidentellement une variable simple
> - **Cohérence** : Utile dans les fonctions pour déclarer des variables locales
> - **Documentation** : Aide à la compréhension du code

```bash
# Comparaison

# Sans déclaration explicite (fonctionne mais moins clair)
resultats=(10 20 30)

# Avec déclaration explicite (recommandé pour la lisibilité)
declare -a resultats
resultats=(10 20 30)
```

> [!tip] Utilisation dans les fonctions
> 
> ```bash
> ma_fonction() {
>     # Déclarer un tableau local à la fonction
>     declare -a donnees_locales
>     donnees_locales=(1 2 3 4 5)
>     
>     # Ce tableau n'existera que dans cette fonction
>     echo "${donnees_locales[@]}"
> }
> ```

> [!warning] Différence avec les tableaux associatifs
> 
> - `declare -a` : tableau indexé (indices numériques 0, 1, 2...)
> - `declare -A` : tableau associatif (indices textuels, comme "nom", "age"...) Ne confondez pas les deux !

---

### Tableaux sur plusieurs lignes

Pour améliorer la lisibilité, vous pouvez définir des tableaux sur plusieurs lignes, ce qui est particulièrement utile pour les longs tableaux ou les valeurs complexes.

```bash
# Syntaxe : chaque élément sur une ligne
mon_tableau=(
    "premier élément"
    "deuxième élément"
    "troisième élément"
    "quatrième élément"
)

# Équivalent à :
# mon_tableau=("premier élément" "deuxième élément" "troisième élément" "quatrième élément")
```

> [!example] Cas d'usage : configuration de serveurs
> 
> ```bash
> serveurs_production=(
>     "web01.example.com"
>     "web02.example.com"
>     "db01.example.com"
>     "cache01.example.com"
>     "backup01.example.com"
> )
> 
> # Plus lisible que tout sur une ligne !
> ```

> [!example] Cas d'usage : commandes complexes
> 
> ```bash
> options_rsync=(
>     "--archive"           # Préserve les permissions et attributs
>     "--verbose"           # Mode verbeux
>     "--compress"          # Compression pendant le transfert
>     "--delete"            # Supprime les fichiers absents de la source
>     "--exclude=*.tmp"     # Exclut les fichiers temporaires
>     "--exclude=.git"      # Exclut le répertoire git
> )
> 
> # Utilisation
> rsync "${options_rsync[@]}" /source/ /destination/
> ```

> [!tip] Commentaires dans les tableaux multi-lignes
> 
> ```bash
> packages=(
>     "nginx"        # Serveur web
>     "postgresql"   # Base de données
>     "redis"        # Cache
>     "certbot"      # Certificats SSL
>     # "mongodb"    # Désactivé temporairement
>     "git"          # Contrôle de version
> )
> ```

> [!info] Règles de formatage
> 
> - Chaque élément doit être sur sa propre ligne
> - Vous pouvez indenter pour la lisibilité
> - Les commentaires sont permis après chaque ligne
> - La dernière ligne peut avoir une virgule finale (ignorée en Bash)
> - N'oubliez pas de fermer la parenthèse

```bash
# ❌ Mauvais : difficile à lire et maintenir
urls=("https://api.example.com/v1/users" "https://api.example.com/v1/posts" "https://api.example.com/v1/comments")

# ✅ Bon : clair et maintenable
urls=(
    "https://api.example.com/v1/users"
    "https://api.example.com/v1/posts"
    "https://api.example.com/v1/comments"
)
```

---

## 🔢 Comprendre l'indexation

Les tableaux indexés en Bash utilisent une numérotation qui commence à **0**.

```bash
fruits=(pomme poire banane orange)

# Index :    0      1      2       3
# Valeur : pomme  poire  banane  orange
```

|Index|Valeur|
|---|---|
|0|pomme|
|1|poire|
|2|banane|
|3|orange|

> [!warning] Erreur courante de débutant Beaucoup de débutants pensent que le premier élément est à l'index 1. C'est faux !
> 
> ```bash
> nombres=(10 20 30)
> echo ${nombres[1]}  # Affiche 20, pas 10 !
> echo ${nombres[0]}  # Affiche 10 (premier élément)
> ```

> [!info] Indices négatifs (Bash 4.3+) Depuis Bash 4.3, vous pouvez utiliser des indices négatifs pour accéder aux éléments depuis la fin :
> 
> ```bash
> fruits=(pomme poire banane orange)
> echo ${fruits[-1]}  # Dernier élément : orange
> echo ${fruits[-2]}  # Avant-dernier : banane
> ```

---

## ⚠️ Pièges courants

### Piège 1 : Oublier les guillemets avec des espaces

```bash
# ❌ Problème
elements=(un deux trois quatre)      # 4 éléments
elements=(un deux "trois quatre")    # 3 éléments, mais...
phrase="trois quatre"
elements=(un deux $phrase)           # 4 éléments ! (mot divisé)

# ✅ Solution
phrase="trois quatre"
elements=(un deux "$phrase")         # 3 éléments (préserve l'espace)
```

### Piège 2 : Confondre déclaration et affectation

```bash
# ❌ Mauvais : écrase tout le tableau
tableau=(a b c)
tableau=d           # Remplace seulement l'index 0 !
echo ${tableau[@]}  # Affiche : d b c

# ✅ Bon : ajouter un élément
tableau=(a b c)
tableau+=(d)        # Ajoute à la fin
echo ${tableau[@]}  # Affiche : a b c d
```

### Piège 3 : Créer un tableau avec des indices non contigus

```bash
# Vous pouvez créer des tableaux avec des trous
tableau[0]="premier"
tableau[5]="sixième"
tableau[10]="onzième"

# Les indices 1-4 et 6-9 n'existent pas !
echo ${#tableau[@]}  # Affiche 3 (nombre d'éléments définis)
```

### Piège 4 : Itération incorrecte

```bash
# ❌ Mauvais : ne préserve pas les espaces
fruits=("pomme rouge" "poire" "banane jaune")
for fruit in ${fruits[@]}; do
    echo "$fruit"  # Divise "pomme rouge" en deux !
done

# ✅ Bon : utiliser des guillemets
for fruit in "${fruits[@]}"; do
    echo "$fruit"  # Préserve "pomme rouge" comme un seul élément
done
```

---

## ✨ Bonnes pratiques

### 1. Toujours utiliser des guillemets lors de l'expansion

```bash
# ✅ Toujours faire
echo "${tableau[@]}"
for element in "${tableau[@]}"; do
    echo "$element"
done

# ❌ Éviter
echo ${tableau[@]}
```

### 2. Nommer explicitement vos tableaux

```bash
# ✅ Bon : nom descriptif au pluriel
utilisateurs=(alice bob charlie)
fichiers_config=(/etc/app/*.conf)
ports_ouverts=(80 443 8080)

# ❌ Moins bon : nom vague
data=(alice bob charlie)
arr=(/etc/app/*.conf)
x=(80 443 8080)
```

### 3. Initialiser avant d'utiliser

```bash
# ✅ Bon
declare -a resultats=()
for i in {1..10}; do
    resultats+=($i)
done

# ❌ Risqué : si resultats existe déjà
for i in {1..10}; do
    resultats+=($i)  # Ajoute aux anciennes valeurs !
done
```

### 4. Documenter les tableaux complexes

```bash
# ✅ Bon : commentaires clairs
# Liste des serveurs de production par ordre de priorité
serveurs_prod=(
    "web01.example.com"    # Serveur principal
    "web02.example.com"    # Failover
    "web03.example.com"    # Backup
)
```

### 5. Vérifier qu'un tableau n'est pas vide

```bash
# ✅ Bon
if [ ${#tableau[@]} -eq 0 ]; then
    echo "Le tableau est vide"
else
    echo "Le tableau contient ${#tableau[@]} éléments"
fi
```

### 6. Préférer la déclaration multi-lignes pour la lisibilité

```bash
# ✅ Bon : facile à lire et modifier
options=(
    "--verbose"
    "--recursive"
    "--exclude=*.tmp"
    "--dry-run"
)

# ❌ Moins bon : difficile à modifier
options=("--verbose" "--recursive" "--exclude=*.tmp" "--dry-run")
```

---

> [!tip] Astuce finale : tester vos tableaux Pendant le développement, affichez toujours vos tableaux pour vérifier leur contenu :
> 
> ```bash
> # Afficher tous les éléments
> echo "Éléments : ${mon_tableau[@]}"
> 
> # Afficher le nombre d'éléments
> echo "Nombre : ${#mon_tableau[@]}"
> 
> # Afficher les indices
> echo "Indices : ${!mon_tableau[@]}"
> ```