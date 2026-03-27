

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

La boucle `for` est l'une des structures de contrôle les plus utilisées en Bash. Elle permet d'itérer sur une liste d'éléments (mots, fichiers, nombres, résultats de commandes) et d'exécuter un bloc de code pour chaque élément.

> [!info] Pourquoi utiliser les boucles for ?
> 
> - Automatiser des tâches répétitives sur plusieurs fichiers
> - Traiter des listes de données dynamiques
> - Créer des scripts flexibles et paramétrables
> - Éviter la duplication de code

---

## Syntaxe de base

La syntaxe classique d'une boucle `for` en Bash suit cette structure :

```bash
for variable in liste_elements
do
    # Code à exécuter pour chaque élément
    commande1
    commande2
done
```

**Variante sur une ligne :**

```bash
for variable in liste_elements; do commande1; commande2; done
```

> [!example] Exemple simple
> 
> ```bash
> for fruit in pomme poire banane
> do
>     echo "J'aime les ${fruit}s"
> done
> ```
> 
> **Résultat :**
> 
> ```
> J'aime les pommes
> J'aime les poires
> J'aime les bananes
> ```

**Composants :**

- `variable` : nom de la variable qui prendra successivement chaque valeur
- `liste_elements` : liste des éléments sur lesquels itérer (séparés par des espaces)
- `do...done` : bloc de code exécuté à chaque itération

---

## Itération sur des mots

L'itération sur des mots est la forme la plus simple de la boucle `for`. Les mots sont séparés par des espaces (ou des tabulations/retours à la ligne selon la valeur de `IFS`).

### Syntaxe

```bash
for mot in mot1 mot2 mot3 "mot avec espaces"
do
    echo "$mot"
done
```

> [!warning] Attention aux espaces Les mots contenant des espaces doivent être entre guillemets, sinon ils seront traités comme plusieurs mots distincts.

### Exemples pratiques

**Liste statique :**

```bash
#!/bin/bash
# Afficher une liste de serveurs
for serveur in web1 web2 db1 cache1
do
    echo "Vérification de $serveur..."
    # ping -c 1 $serveur
done
```

**Liste avec des chaînes complexes :**

```bash
for utilisateur in "Alice Dupont" "Bob Martin" "Charlie Durand"
do
    echo "Création du compte pour : $utilisateur"
done
```

**Liste depuis une variable :**

```bash
COULEURS="rouge vert bleu jaune"

for couleur in $COULEURS
do
    echo "Couleur : $couleur"
done
```

> [!tip] Astuce : liste sur plusieurs lignes
> 
> ```bash
> for item in \
>     element1 \
>     element2 \
>     element3
> do
>     echo "$item"
> done
> ```

---

## Itération sur des fichiers avec glob

Les **globs** (ou motifs de correspondance) permettent de sélectionner des fichiers selon des critères. C'est l'une des utilisations les plus courantes des boucles `for`.

### Caractères de glob principaux

|Motif|Description|Exemple|
|---|---|---|
|`*`|N'importe quelle chaîne|`*.txt` = tous les fichiers .txt|
|`?`|Un seul caractère|`file?.txt` = file1.txt, fileA.txt|
|`[...]`|Un caractère parmi ceux listés|`[abc].txt` = a.txt, b.txt, c.txt|
|`[^...]`|Un caractère NON listé|`[^0-9].txt` = exclut les chiffres|

### Syntaxe

```bash
for fichier in *.extension
do
    echo "Traitement de $fichier"
done
```

### Exemples pratiques

**Traiter tous les fichiers d'un type :**

```bash
#!/bin/bash
# Convertir tous les PNG en JPG
for image in *.png
do
    nom_base="${image%.png}"  # Retirer l'extension
    echo "Conversion de $image vers ${nom_base}.jpg"
    # convert "$image" "${nom_base}.jpg"
done
```

**Traiter des fichiers dans des sous-dossiers :**

```bash
# Lister tous les fichiers .log dans le répertoire courant et ses sous-dossiers
for log in **/*.log
do
    echo "Analyse de : $log"
    # grep "ERROR" "$log"
done
```

> [!warning] Activation de globstar Pour que `**` fonctionne (recherche récursive), il faut activer l'option :
> 
> ```bash
> shopt -s globstar
> ```

**Combiner plusieurs motifs :**

```bash
# Traiter à la fois les .jpg et les .png
for image in *.jpg *.png
do
    echo "Image trouvée : $image"
done
```

**Filtrer avec des conditions :**

```bash
for fichier in *
do
    # Ne traiter que les fichiers (pas les dossiers)
    if [ -f "$fichier" ]; then
        echo "Fichier : $fichier"
    fi
done
```

> [!tip] Vérifier qu'il y a des fichiers Si aucun fichier ne correspond au motif, la boucle s'exécute une fois avec le motif littéral :
> 
> ```bash
> for f in *.inexistant
> do
>     [ -e "$f" ] || { echo "Aucun fichier trouvé"; continue; }
>     echo "$f"
> done
> ```

---

## Itération sur des séquences

Bash propose plusieurs méthodes pour générer des séquences numériques et itérer dessus.

### Expansion d'accolades `{début..fin}`

```bash
for i in {1..10}
do
    echo "Itération numéro $i"
done
```

**Avec un pas personnalisé (Bash 4+) :**

```bash
# De 0 à 20 par pas de 2
for nombre in {0..20..2}
do
    echo "$nombre"
done
```

**Séquences décroissantes :**

```bash
# Compte à rebours
for compte in {10..1}
do
    echo "$compte"
done
echo "Décollage !"
```

**Séquences de lettres :**

```bash
# Itération sur l'alphabet
for lettre in {a..z}
do
    echo "$lettre"
done

# Ou majuscules
for lettre in {A..Z}
do
    echo "$lettre"
done
```

### Commande `seq`

La commande `seq` est plus flexible pour les séquences complexes :

```bash
# Syntaxe : seq [début] [pas] fin
for i in $(seq 1 10)
do
    echo "Nombre : $i"
done
```

**Avec un pas :**

```bash
# De 5 à 50 par pas de 5
for multiple in $(seq 5 5 50)
do
    echo "$multiple"
done
```

**Nombres décimaux :**

```bash
for valeur in $(seq 0 0.5 5)
do
    echo "Valeur : $valeur"
done
```

### Comparaison des méthodes

|Méthode|Avantages|Inconvénients|
|---|---|---|
|`{1..10}`|Rapide, intégré, lisible|Pas de variables, Bash 3+|
|`{1..10..2}`|Contrôle du pas|Bash 4+ uniquement|
|`seq`|Flexible, décimaux|Commande externe, sous-shell|

> [!example] Exemple pratique : créer des dossiers
> 
> ```bash
> #!/bin/bash
> # Créer 12 dossiers pour les mois
> for mois in {01..12}
> do
>     mkdir -p "2025-${mois}"
>     echo "Dossier 2025-${mois} créé"
> done
> ```

> [!tip] Largeur fixe avec seq
> 
> ```bash
> # Générer 001, 002, 003...
> for num in $(seq -w 1 100)
> do
>     echo "Fichier_${num}.txt"
> done
> ```

---

## Itération sur le résultat d'une commande

L'une des fonctionnalités les plus puissantes de Bash est la possibilité d'itérer sur la sortie d'une commande.

### Substitution de commande

```bash
for element in $(commande)
do
    echo "$element"
done
```

> [!info] Comment ça fonctionne ? `$(commande)` exécute la commande et remplace l'expression par sa sortie. Le shell divise ensuite cette sortie en mots (selon `IFS`).

### Exemples pratiques

**Lister des utilisateurs :**

```bash
# Itérer sur tous les utilisateurs du système
for user in $(cut -d: -f1 /etc/passwd)
do
    echo "Utilisateur : $user"
done
```

**Traiter des lignes de fichier :**

```bash
# Lire un fichier ligne par ligne (attention aux espaces)
for ligne in $(cat fichier.txt)
do
    echo "Ligne : $ligne"
done
```

> [!warning] Problème avec les espaces Cette méthode sépare sur les espaces. Pour lire ligne par ligne correctement, préférer `while read`.

**Trouver des fichiers avec `find` :**

```bash
# Trouver tous les fichiers modifiés dans les dernières 24h
for fichier in $(find . -type f -mtime -1)
do
    echo "Fichier récent : $fichier"
done
```

**Lister des processus :**

```bash
# Afficher les PID de tous les processus bash
for pid in $(pgrep bash)
do
    echo "Process bash avec PID : $pid"
done
```

**Combiner avec des pipes :**

```bash
# Lister les 5 plus gros fichiers
for fichier in $(du -ah | sort -rh | head -5 | awk '{print $2}')
do
    echo "Gros fichier : $fichier"
    ls -lh "$fichier"
done
```

> [!tip] Alternative plus robuste Pour les cas complexes, préférez :
> 
> ```bash
> find . -type f -print0 | while IFS= read -r -d '' fichier
> do
>     echo "$fichier"
> done
> ```

### Avec des tableaux

Pour gérer proprement les espaces et caractères spéciaux :

```bash
# Stocker d'abord dans un tableau
fichiers=($(ls *.txt))

# Puis itérer
for fichier in "${fichiers[@]}"
do
    echo "Fichier : $fichier"
done
```

---

## Expansion de chemins

L'expansion de chemins combine les globs avec la structure des répertoires pour naviguer efficacement dans l'arborescence.

### Chemins relatifs et absolus

```bash
# Chemin relatif
for fichier in ../parent/*.txt
do
    echo "$fichier"
done

# Chemin absolu
for log in /var/log/*.log
do
    echo "Log : $log"
done
```

### Expansion récursive avec `**`

```bash
# Nécessite globstar
shopt -s globstar

# Trouver tous les fichiers Python dans l'arborescence
for script in **/*.py
do
    echo "Script Python : $script"
done
```

### Expansion dans des sous-dossiers spécifiques

```bash
# Traiter les images dans plusieurs dossiers
for image in photos/{2023,2024,2025}/*.jpg
do
    echo "Image : $image"
done
```

**Équivalent développé :**

```bash
for image in photos/2023/*.jpg photos/2024/*.jpg photos/2025/*.jpg
do
    echo "Image : $image"
done
```

### Combiner plusieurs motifs

```bash
# Tous les fichiers de config dans /etc
for config in /etc/*.{conf,cfg,config}
do
    [ -f "$config" ] && echo "Config : $config"
done
```

### Exclure des patterns

```bash
# Tous les fichiers sauf les .log
shopt -s extglob
for fichier in !(*.log)
do
    echo "$fichier"
done
```

> [!info] Options de globbing utiles
> 
> ```bash
> shopt -s nullglob    # Ne rien retourner si aucun match
> shopt -s dotglob     # Inclure les fichiers cachés
> shopt -s globstar    # Activer **
> shopt -s extglob     # Patterns étendus
> ```

### Exemples pratiques

**Backup de fichiers spécifiques :**

```bash
#!/bin/bash
BACKUP_DIR="/backup"

for fichier in /home/*/Documents/*.{doc,docx,pdf}
do
    if [ -f "$fichier" ]; then
        cp "$fichier" "$BACKUP_DIR/"
        echo "Sauvegardé : $fichier"
    fi
done
```

**Nettoyer les fichiers temporaires :**

```bash
# Supprimer tous les fichiers .tmp dans le système
for temp in /tmp/**/*.tmp /var/tmp/*.tmp
do
    [ -f "$temp" ] && rm -f "$temp" && echo "Supprimé : $temp"
done
```

**Traiter des logs par date :**

```bash
# Analyser tous les logs de mars 2024
for log in /var/log/app/2024-03-*.log
do
    echo "=== Analyse de $log ==="
    grep "ERROR" "$log" | wc -l
done
```

---

## Pièges courants et bonnes pratiques

### 🚫 Piège 1 : Fichiers avec espaces

**Problème :**

```bash
# MAUVAIS : casse les noms avec espaces
for fichier in $(ls *.txt)
do
    echo "$fichier"
done
```

**Solution :**

```bash
# BON : utiliser directement les globs
for fichier in *.txt
do
    echo "$fichier"
done
```

### 🚫 Piège 2 : Boucle vide si aucun match

**Problème :**

```bash
for f in *.inexistant
do
    echo "$f"  # Affiche "*.inexistant" si aucun fichier
done
```

**Solution :**

```bash
shopt -s nullglob  # Ne rien retourner si aucun match

for f in *.inexistant
do
    echo "$f"  # Ne s'exécute pas si aucun fichier
done

shopt -u nullglob  # Désactiver après usage
```

**Ou avec vérification :**

```bash
for f in *.txt
do
    [ -e "$f" ] || continue  # Passer si le fichier n'existe pas
    echo "$f"
done
```

### 🚫 Piège 3 : Variables non quotées

**Problème :**

```bash
for fichier in *.txt
do
    cat $fichier  # Problème si le nom contient des espaces
done
```

**Solution :**

```bash
for fichier in *.txt
do
    cat "$fichier"  # TOUJOURS quoter les variables
done
```

### 🚫 Piège 4 : Modification du répertoire dans la boucle

**Problème :**

```bash
for dir in */
do
    cd "$dir"
    # Opérations...
    # Oubli de revenir : les prochaines itérations sont dans le mauvais dossier
done
```

**Solution :**

```bash
for dir in */
do
    (
        cd "$dir" || exit  # Sous-shell : ne change pas le répertoire parent
        # Opérations...
    )
done

# Ou explicitement
for dir in */
do
    pushd "$dir" > /dev/null
    # Opérations...
    popd > /dev/null
done
```

### ✅ Bonne pratique 1 : Toujours quoter les variables

```bash
for fichier in "$@"  # Guillemets pour les arguments
do
    rm -f "$fichier"  # Guillemets pour la variable
done
```

### ✅ Bonne pratique 2 : Vérifier l'existence

```bash
for fichier in *.log
do
    if [ ! -f "$fichier" ]; then
        echo "Aucun fichier .log trouvé"
        break
    fi
    # Traitement...
done
```

### ✅ Bonne pratique 3 : Utiliser des noms de variables clairs

```bash
# MAUVAIS
for i in *.txt
do
    cat "$i"
done

# BON
for fichier_texte in *.txt
do
    cat "$fichier_texte"
done
```

### ✅ Bonne pratique 4 : Gérer les erreurs

```bash
for fichier in *.conf
do
    if ! cp "$fichier" /etc/backup/; then
        echo "Erreur lors de la copie de $fichier" >&2
        continue  # Ou exit 1 selon le besoin
    fi
done
```

### ✅ Bonne pratique 5 : Limiter la portée avec les sous-shells

```bash
for config in *.conf
do
    (
        source "$config"  # Sous-shell : ne pollue pas l'environnement
        echo "Variable du config : $MA_VARIABLE"
    )
done
```

> [!tip] Astuce : debugging
> 
> ```bash
> # Activer le mode debug pour voir chaque itération
> set -x
> for i in {1..3}
> do
>     echo "Itération $i"
> done
> set +x
> ```

### Tableau récapitulatif des bonnes pratiques

|Situation|❌ À éviter|✅ À faire|
|---|---|---|
|Variables|`cat $file`|`cat "$file"`|
|Liste de fichiers|`for f in $(ls)`|`for f in *`|
|Pas de match|Laisser par défaut|`shopt -s nullglob`|
|Espaces dans noms|Ne pas quoter|Toujours quoter|
|Changement de dir|`cd` direct|Sous-shell ou `pushd/popd`|

---

> [!success] Points clés à retenir
> 
> - La boucle `for` est essentielle pour automatiser des tâches répétitives
> - Utilisez les globs (`*`, `?`, `[]`) pour sélectionner des fichiers
> - Les expansions d'accolades `{1..10}` sont parfaites pour les séquences
> - Quotez TOUJOURS vos variables pour gérer les espaces
> - Activez `nullglob` pour gérer les cas sans correspondance
> - Préférez les globs directs à `$(ls)` ou `$(find)`