

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

## 🎯 Introduction

L'appel de fonctions en Bash permet de réutiliser du code et de structurer vos scripts de manière modulaire. Contrairement à d'autres langages, Bash a des particularités importantes concernant la syntaxe d'appel et la gestion de la portée.

> [!info] Pourquoi apprendre l'appel de fonctions ?
> 
> - Réutiliser du code sans duplication
> - Organiser logiquement votre script
> - Faciliter la maintenance et le débogage
> - Créer des bibliothèques de fonctions réutilisables

---

## 📞 Appel simple d'une fonction

### Syntaxe de base

Pour appeler une fonction en Bash, il suffit d'écrire son nom sans parenthèses ni mot-clé spécial.

```bash
#!/bin/bash

# Définition de la fonction
dire_bonjour() {
    echo "Bonjour le monde !"
}

# Appel de la fonction - juste le nom
dire_bonjour
```

> [!warning] Attention aux parenthèses En Bash, on n'utilise **JAMAIS** de parenthèses lors de l'appel d'une fonction. Les parenthèses ne servent que lors de la définition.
> 
> ```bash
> # ✅ CORRECT
> ma_fonction
> 
> # ❌ INCORRECT
> ma_fonction()
> ```

### Comportement de l'appel

Lorsque vous appelez une fonction :

1. L'exécution du script se déplace vers la fonction
2. Les commandes de la fonction sont exécutées séquentiellement
3. L'exécution revient à la ligne suivant l'appel

```bash
#!/bin/bash

afficher_message() {
    echo "Début de la fonction"
    echo "Traitement..."
    echo "Fin de la fonction"
}

echo "Avant l'appel"
afficher_message
echo "Après l'appel"

# Sortie :
# Avant l'appel
# Début de la fonction
# Traitement...
# Fin de la fonction
# Après l'appel
```

> [!tip] Appels multiples Vous pouvez appeler la même fonction plusieurs fois dans votre script. Chaque appel exécute complètement la fonction.

```bash
#!/bin/bash

compteur() {
    echo "Exécution de la fonction"
}

compteur  # Premier appel
compteur  # Deuxième appel
compteur  # Troisième appel
```

---

## 📦 Appel avec arguments

### Passage d'arguments

Pour passer des arguments à une fonction, on les liste après le nom de la fonction, séparés par des espaces.

```bash
#!/bin/bash

# Définition d'une fonction avec paramètres
saluer() {
    echo "Bonjour $1 $2 !"
}

# Appel avec deux arguments
saluer "Jean" "Dupont"
# Sortie : Bonjour Jean Dupont !
```

### Accès aux arguments dans la fonction

|Variable|Description|Exemple|
|---|---|---|
|`$1`, `$2`, `$3`...|Arguments positionnels|`$1` = premier argument|
|`$#`|Nombre d'arguments|Si 3 arguments : `$#` = 3|
|`$@`|Tous les arguments (liste)|`"$@"` = `"arg1" "arg2" "arg3"`|
|`$*`|Tous les arguments (chaîne)|`"$*"` = `"arg1 arg2 arg3"`|
|`$0`|Nom du script (pas de la fonction)|Ne représente pas la fonction|

```bash
#!/bin/bash

afficher_infos() {
    echo "Nombre d'arguments : $#"
    echo "Premier argument : $1"
    echo "Deuxième argument : $2"
    echo "Tous les arguments : $@"
}

afficher_infos "alpha" "beta" "gamma"

# Sortie :
# Nombre d'arguments : 3
# Premier argument : alpha
# Deuxième argument : beta
# Tous les arguments : alpha beta gamma
```

> [!example] Exemple pratique : fonction de calcul
> 
> ```bash
> #!/bin/bash
> 
> calculer_somme() {
>     local resultat=$(( $1 + $2 ))
>     echo "La somme de $1 et $2 est : $resultat"
> }
> 
> calculer_somme 15 27
> # Sortie : La somme de 15 et 27 est : 42
> ```

### Arguments avec espaces

Pour passer des arguments contenant des espaces, utilisez des guillemets.

```bash
#!/bin/bash

afficher_nom_complet() {
    echo "Nom complet : $1"
    echo "Age : $2"
}

# ✅ CORRECT - guillemets autour de l'argument avec espaces
afficher_nom_complet "Marie Curie" "66"

# ❌ INCORRECT - sans guillemets, "Marie" et "Curie" sont deux arguments
afficher_nom_complet Marie Curie 66
# Résultat inattendu : $1 = "Marie", $2 = "Curie", $3 = "66"
```

> [!warning] Distinction entre `$@` et `$*`
> 
> - `"$@"` : préserve chaque argument comme élément séparé (recommandé)
> - `"$*"` : concatène tous les arguments en une seule chaîne
> 
> ```bash
> demo() {
>     echo "Avec \$@:"
>     for arg in "$@"; do
>         echo "  - [$arg]"
>     done
> }
> 
> demo "arg 1" "arg 2"
> # Sortie :
> # Avec $@:
> #   - [arg 1]
> #   - [arg 2]
> ```

### Arguments par défaut

Bash ne supporte pas nativement les valeurs par défaut, mais vous pouvez les implémenter avec des tests.

```bash
#!/bin/bash

saluer() {
    local nom=${1:-"Invité"}  # Valeur par défaut si $1 est vide
    echo "Bonjour $nom !"
}

saluer "Alice"    # Sortie : Bonjour Alice !
saluer            # Sortie : Bonjour Invité !
```

---

## 📍 Position dans le script

### Règle fondamentale : définir avant d'appeler

En Bash, une fonction **doit être définie avant** d'être appelée. Le script est interprété de haut en bas.

```bash
#!/bin/bash

# ✅ CORRECT - définition avant l'appel
ma_fonction() {
    echo "Fonction exécutée"
}

ma_fonction  # Ça fonctionne

# ❌ INCORRECT - appel avant la définition
autre_fonction  # Erreur : command not found

autre_fonction() {
    echo "Trop tard"
}
```

> [!warning] Erreur courante
> 
> ```bash
> #!/bin/bash
> 
> calculer  # ❌ Erreur : calculer: command not found
> 
> calculer() {
>     echo "Calcul..."
> }
> ```

### Organisation recommandée

```bash
#!/bin/bash

# 1. Déclaration des variables globales
VERSION="1.0"
DEBUG=false

# 2. Définition de toutes les fonctions
fonction_helper() {
    echo "Fonction utilitaire"
}

fonction_principale() {
    echo "Fonction principale"
    fonction_helper  # Appel d'une autre fonction
}

# 3. Corps principal du script
echo "Démarrage du script"
fonction_principale
echo "Fin du script"
```

> [!tip] Astuce pour l'organisation Placez toutes vos définitions de fonctions au début du script, après les variables globales mais avant le code principal. Cela rend votre script plus lisible et évite les erreurs.

### Fonctions s'appelant entre elles

Les fonctions peuvent s'appeler mutuellement, mais attention à leur ordre de définition.

```bash
#!/bin/bash

# ✅ CORRECT - toutes les fonctions définies avant utilisation
fonction_a() {
    echo "A appelle B"
    fonction_b
}

fonction_b() {
    echo "B exécutée"
}

fonction_a  # Fonctionne car B est définie avant l'appel de A

# Sortie :
# A appelle B
# B exécutée
```

> [!info] Appels récursifs Une fonction peut s'appeler elle-même (récursion), mais assurez-vous d'avoir une condition d'arrêt pour éviter une boucle infinie.
> 
> ```bash
> factorielle() {
>     if [ $1 -le 1 ]; then
>         echo 1
>     else
>         local prev=$(factorielle $(($1 - 1)))
>         echo $(($1 * prev))
>     fi
> }
> 
> resultat=$(factorielle 5)
> echo "5! = $resultat"  # Sortie : 5! = 120
> ```

---

## 🔒 Portée des fonctions

### Portée de visibilité

Une fonction définie dans un script est visible dans tout le script **après sa définition**.

```bash
#!/bin/bash

# Zone 1 : fonction_a n'existe pas encore

fonction_a() {
    echo "Je suis A"
}

# Zone 2 : fonction_a existe, fonction_b n'existe pas encore

fonction_b() {
    echo "Je suis B"
    fonction_a  # ✅ OK : A est définie avant B
}

# Zone 3 : les deux fonctions existent

fonction_b  # ✅ Fonctionne
fonction_a  # ✅ Fonctionne
```

### Portée des variables dans les fonctions

Les variables ont des comportements différents selon leur déclaration.

#### Variables globales (par défaut)

Sans le mot-clé `local`, toute variable modifiée dans une fonction affecte le script entier.

```bash
#!/bin/bash

compteur=0

incrementer() {
    compteur=$(($compteur + 1))  # Modifie la variable globale
}

echo "Avant : $compteur"  # 0
incrementer
echo "Après : $compteur"  # 1
```

#### Variables locales

Le mot-clé `local` limite la portée d'une variable à la fonction.

```bash
#!/bin/bash

nombre=100

modifier() {
    local nombre=50      # Variable locale, n'affecte pas la globale
    echo "Dans fonction : $nombre"
}

echo "Avant : $nombre"   # 100
modifier                 # Affiche : Dans fonction : 50
echo "Après : $nombre"   # 100 (inchangé)
```

> [!warning] Oubli du mot-clé `local` C'est une erreur très courante ! Sans `local`, vous modifiez la variable globale.
> 
> ```bash
> resultat=""
> 
> calculer() {
>     resultat="calculé"  # ❌ Modifie la variable globale
> }
> 
> calculer() {
>     local resultat="calculé"  # ✅ Variable locale
> }
> ```

### Tableau de comparaison des portées

|Type|Déclaration|Visible où ?|Persiste après la fonction ?|
|---|---|---|---|
|Variable globale|`var=valeur`|Partout dans le script|✅ Oui|
|Variable locale|`local var=valeur`|Uniquement dans la fonction|❌ Non|
|Argument|`$1`, `$2`...|Uniquement dans la fonction|❌ Non|

> [!example] Exemple complet de portée
> 
> ```bash
> #!/bin/bash
> 
> globale="Je suis globale"
> 
> demo_portee() {
>     local locale="Je suis locale"
>     globale="Modifiée dans la fonction"
>     
>     echo "Dans fonction - globale: $globale"
>     echo "Dans fonction - locale: $locale"
> }
> 
> echo "Avant fonction - globale: $globale"
> # echo "Avant fonction - locale: $locale"  # Erreur : variable non définie
> 
> demo_portee
> 
> echo "Après fonction - globale: $globale"
> # echo "Après fonction - locale: $locale"  # Erreur : variable non définie
> 
> # Sortie :
> # Avant fonction - globale: Je suis globale
> # Dans fonction - globale: Modifiée dans la fonction
> # Dans fonction - locale: Je suis locale
> # Après fonction - globale: Modifiée dans la fonction
> ```

### Fonctions et sous-shells

Les fonctions définies dans le script principal ne sont pas automatiquement disponibles dans les sous-shells.

```bash
#!/bin/bash

ma_fonction() {
    echo "Je suis une fonction"
}

# ✅ Appel direct - fonctionne
ma_fonction

# ❌ Dans un sous-shell - ne fonctionne pas
( ma_fonction )  # Erreur : command not found

# Solution : exporter la fonction
export -f ma_fonction
( ma_fonction )  # ✅ Fonctionne maintenant
```

---

## ⚠️ Pièges courants

### 1. Parenthèses lors de l'appel

```bash
# ❌ ERREUR
ma_fonction()  # Redéfinition accidentelle !

# ✅ CORRECT
ma_fonction
```

### 2. Ordre de définition

```bash
# ❌ ERREUR
fonction_b  # Appel avant définition

fonction_b() {
    echo "test"
}
```

### 3. Variables globales non intentionnelles

```bash
# ❌ PROBLÈME
modifier_config() {
    config="nouvelle valeur"  # Oups, modifie la globale
}

# ✅ SOLUTION
modifier_config() {
    local config="nouvelle valeur"  # Variable locale
}
```

### 4. Arguments avec espaces mal gérés

```bash
traiter_fichier() {
    echo "Fichier : $1"
}

# ❌ ERREUR
fichier="mon fichier.txt"
traiter_fichier $fichier  # Passe 2 arguments : "mon" et "fichier.txt"

# ✅ CORRECT
traiter_fichier "$fichier"  # Passe 1 argument : "mon fichier.txt"
```

### 5. Confusion entre `$@` et `$*`

```bash
afficher() {
    # $* concatène tout en une chaîne
    echo "Nombre d'éléments avec \$*: "
    for arg in $*; do echo "  - $arg"; done
    
    # $@ préserve les éléments séparés
    echo "Nombre d'éléments avec \"\$@\": "
    for arg in "$@"; do echo "  - $arg"; done
}

afficher "arg 1" "arg 2"
```

### 6. Retour de valeurs complexes

```bash
# ❌ ERREUR - return ne peut retourner que 0-255
calculer() {
    return 1000  # Sera tronqué à 1000 % 256 = 232
}

# ✅ SOLUTION - utiliser echo et capture de commande
calculer() {
    echo 1000
}

resultat=$(calculer)
echo "Résultat : $resultat"
```

---

## ✅ Bonnes pratiques

### 1. Utilisez toujours `local` pour les variables temporaires

```bash
traiter_donnees() {
    local temp_var="temporaire"    # ✅ Bonne pratique
    local i                         # ✅ Déclarer avant utilisation
    
    for i in {1..5}; do
        echo "$temp_var $i"
    done
}
```

### 2. Nommage clair des fonctions

```bash
# ✅ BON - nom descriptif
valider_email() {
    # ...
}

calculer_moyenne_notes() {
    # ...
}

# ❌ MAUVAIS - nom peu clair
func1() {
    # ...
}

do_stuff() {
    # ...
}
```

### 3. Vérifiez le nombre d'arguments

```bash
copier_fichier() {
    if [ $# -ne 2 ]; then
        echo "Erreur : Usage: copier_fichier <source> <destination>"
        return 1
    fi
    
    local source="$1"
    local destination="$2"
    
    cp "$source" "$destination"
}
```

### 4. Documentez vos fonctions

```bash
# Fonction : calculer_moyenne
# Description : Calcule la moyenne de nombres passés en arguments
# Arguments : liste de nombres
# Retour : affiche la moyenne (via echo)
# Exemple : moyenne=$(calculer_moyenne 10 20 30)
calculer_moyenne() {
    local somme=0
    local count=$#
    
    for nombre in "$@"; do
        somme=$((somme + nombre))
    done
    
    echo $((somme / count))
}
```

### 5. Regroupez les fonctions par thématique

```bash
#!/bin/bash

# === FONCTIONS DE VALIDATION ===
valider_email() { 
    # ...
}

valider_numero() { 
    # ...
}

# === FONCTIONS DE TRAITEMENT ===
traiter_donnees() { 
    # ...
}

calculer_statistiques() { 
    # ...
}

# === PROGRAMME PRINCIPAL ===
main() {
    valider_email "$1"
    traiter_donnees "$2"
}

main "$@"
```

### 6. Gérez les erreurs avec `return`

```bash
verifier_fichier() {
    local fichier="$1"
    
    if [ ! -f "$fichier" ]; then
        echo "Erreur : fichier '$fichier' introuvable" >&2
        return 1  # Code d'erreur
    fi
    
    return 0  # Succès
}

# Utilisation
if verifier_fichier "data.txt"; then
    echo "Fichier valide"
else
    echo "Vérification échouée"
fi
```

> [!tip] Astuce professionnelle Créez une fonction `main()` qui orchestre votre script et appelez-la en dernier. Cela rend le code plus structuré et testable.
> 
> ```bash
> #!/bin/bash
> 
> # Toutes les fonctions...
> 
> main() {
>     initialiser
>     traiter_arguments "$@"
>     executer_programme
>     nettoyer
> }
> 
> # Point d'entrée
> main "$@"
> ```

---