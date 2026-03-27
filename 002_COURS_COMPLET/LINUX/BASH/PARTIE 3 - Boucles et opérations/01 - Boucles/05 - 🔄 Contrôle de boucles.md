

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

Les commandes `break` et `continue` permettent de **contrôler le flux d'exécution** à l'intérieur des boucles (`for`, `while`, `until`). Elles offrent une flexibilité essentielle pour gérer des conditions spéciales sans avoir recours à des structures de contrôle complexes.

> [!info] Pourquoi utiliser break et continue ?
> 
> - **Éviter les itérations inutiles** : sortir d'une boucle dès qu'une condition est remplie
> - **Filtrer les itérations** : sauter certaines valeurs sans arrêter complètement la boucle
> - **Améliorer les performances** : réduire le nombre d'opérations
> - **Simplifier la logique** : rendre le code plus lisible et maintenable

---

## 🚪 La commande `break`

### Syntaxe de base

La commande `break` permet de **sortir immédiatement** de la boucle en cours, quel que soit le nombre d'itérations restantes.

```bash
break
```

> [!example] Exemple simple
> 
> ```bash
> #!/bin/bash
> 
> # Recherche d'un fichier spécifique
> for fichier in *.txt; do
>     if [[ "$fichier" == "config.txt" ]]; then
>         echo "✓ Fichier trouvé : $fichier"
>         break  # Sort de la boucle immédiatement
>     fi
>     echo "✗ Fichier vérifié : $fichier"
> done
> 
> echo "Recherche terminée"
> ```
> 
> **Sortie :**
> 
> ```
> ✗ Fichier vérifié : data.txt
> ✗ Fichier vérifié : notes.txt
> ✓ Fichier trouvé : config.txt
> Recherche terminée
> ```

> [!tip] Quand utiliser `break` ?
> 
> - Recherche d'un élément dans une liste (arrêt dès qu'on le trouve)
> - Sortie anticipée en cas d'erreur
> - Limitation du nombre d'essais dans une opération
> - Interruption dès qu'une condition critique est atteinte

**Exemple avec `while` :**

```bash
#!/bin/bash

compteur=1

while true; do  # Boucle infinie
    echo "Tentative $compteur"
    
    if [[ $compteur -eq 5 ]]; then
        echo "Limite atteinte, arrêt de la boucle"
        break
    fi
    
    ((compteur++))
done
```

---

### `break n` - Sortir de plusieurs niveaux

La syntaxe `break n` permet de sortir de **n niveaux de boucles imbriquées** en une seule commande.

```bash
break n  # n = nombre de niveaux à franchir
```

> [!warning] Attention `n` doit être un **entier positif**. Par défaut, `break` équivaut à `break 1`.

> [!example] Exemple avec boucles imbriquées
> 
> ```bash
> #!/bin/bash
> 
> for i in {1..3}; do
>     echo "=== Niveau externe : $i ==="
>     
>     for j in {1..5}; do
>         echo "  Niveau interne : $j"
>         
>         if [[ $i -eq 2 && $j -eq 3 ]]; then
>             echo "  🚨 Condition critique détectée !"
>             break 2  # Sort des DEUX boucles
>         fi
>     done
>     
>     echo "--- Fin de l'itération $i ---"
> done
> 
> echo "Programme terminé"
> ```
> 
> **Sortie :**
> 
> ```
> === Niveau externe : 1 ===
>   Niveau interne : 1
>   Niveau interne : 2
>   Niveau interne : 3
>   Niveau interne : 4
>   Niveau interne : 5
> --- Fin de l'itération 1 ---
> === Niveau externe : 2 ===
>   Niveau interne : 1
>   Niveau interne : 2
>   Niveau interne : 3
>   🚨 Condition critique détectée !
> Programme terminé
> ```

**Visualisation des niveaux :**

|Commande|Niveau 1 (externe)|Niveau 2 (interne)|Niveau 3|
|---|---|---|---|
|`break 1`|Continue|Sort|-|
|`break 2`|Sort|Sort|-|
|`break 3`|Sort|Sort|Sort|

> [!tip] Cas d'usage de `break n`
> 
> - Traitement de matrices ou tableaux multidimensionnels
> - Recherche dans des structures de données imbriquées
> - Arrêt global lors d'une erreur critique
> - Optimisation en évitant des vérifications inutiles

---

## ⏭️ La commande `continue`

### Syntaxe de base

La commande `continue` permet de **sauter l'itération courante** et de passer directement à la suivante, sans sortir de la boucle.

```bash
continue
```

> [!example] Exemple simple
> 
> ```bash
> #!/bin/bash
> 
> # Traiter uniquement les fichiers .txt
> for fichier in *; do
>     # Ignorer les répertoires
>     if [[ -d "$fichier" ]]; then
>         continue
>     fi
>     
>     # Ignorer les fichiers non .txt
>     if [[ ! "$fichier" =~ \.txt$ ]]; then
>         continue
>     fi
>     
>     echo "📄 Traitement de : $fichier"
>     # ... traitement du fichier ...
> done
> ```

> [!tip] Quand utiliser `continue` ?
> 
> - Filtrer des éléments selon des critères
> - Ignorer des cas particuliers ou des erreurs non critiques
> - Sauter des valeurs invalides dans un traitement de données
> - Optimiser en évitant du code inutile

**Exemple avec condition de filtrage :**

```bash
#!/bin/bash

# Afficher uniquement les nombres pairs
for nombre in {1..10}; do
    # Si impair, on saute
    if [[ $((nombre % 2)) -ne 0 ]]; then
        continue
    fi
    
    echo "Nombre pair : $nombre"
done
```

**Sortie :**

```
Nombre pair : 2
Nombre pair : 4
Nombre pair : 6
Nombre pair : 8
Nombre pair : 10
```

---

### `continue n` - Sauter dans des boucles imbriquées

La syntaxe `continue n` permet de **remonter de n niveaux** pour continuer l'itération de la boucle correspondante.

```bash
continue n  # n = niveau de la boucle à continuer
```

> [!example] Exemple avec boucles imbriquées
> 
> ```bash
> #!/bin/bash
> 
> for i in {1..3}; do
>     echo "=== Groupe $i ==="
>     
>     for j in {1..4}; do
>         # Si j est pair dans le groupe 2, sauter tout le groupe
>         if [[ $i -eq 2 && $((j % 2)) -eq 0 ]]; then
>             echo "  ⏭️  Saut du groupe $i (j=$j)"
>             continue 2  # Continue la boucle externe
>         fi
>         
>         echo "  Élément : $i-$j"
>     done
>     
>     echo "--- Fin du groupe $i ---"
> done
> ```
> 
> **Sortie :**
> 
> ```
> === Groupe 1 ===
>   Élément : 1-1
>   Élément : 1-2
>   Élément : 1-3
>   Élément : 1-4
> --- Fin du groupe 1 ---
> === Groupe 2 ===
>   Élément : 2-1
>   ⏭️  Saut du groupe 2 (j=2)
> === Groupe 3 ===
>   Élément : 3-1
>   Élément : 3-2
>   Élément : 3-3
>   Élément : 3-4
> --- Fin du groupe 3 ---
> ```

**Différence clé avec `break n` :**

|Commande|Action|
|---|---|
|`break 2`|**Sort** complètement des 2 boucles|
|`continue 2`|**Passe** à l'itération suivante de la boucle externe|

---

## ⚖️ Comparaison break vs continue

|Critère|`break`|`continue`|
|---|---|---|
|**Action**|Sort de la boucle|Passe à l'itération suivante|
|**Code après**|N'est pas exécuté|N'est pas exécuté (pour l'itération courante)|
|**Boucle**|S'arrête complètement|Continue de tourner|
|**Usage typique**|Recherche, limite atteinte|Filtrage, cas spéciaux|

> [!example] Comparaison visuelle
> 
> ```bash
> # Avec break
> for i in {1..5}; do
>     if [[ $i -eq 3 ]]; then
>         break  # Sortie : 1 2
>     fi
>     echo $i
> done
> 
> # Avec continue
> for i in {1..5}; do
>     if [[ $i -eq 3 ]]; then
>         continue  # Sortie : 1 2 4 5
>     fi
>     echo $i
> done
> ```

---

## 💼 Cas d'usage pratiques

### 1. Vérification de prérequis

```bash
#!/bin/bash

commandes_requises=("git" "docker" "curl" "jq")

for cmd in "${commandes_requises[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ Erreur : $cmd n'est pas installé"
        break  # Arrêt immédiat
    fi
    echo "✓ $cmd est disponible"
done
```

### 2. Traitement de fichiers avec filtres

```bash
#!/bin/bash

for fichier in *.log; do
    # Ignorer les fichiers vides
    if [[ ! -s "$fichier" ]]; then
        continue
    fi
    
    # Ignorer les fichiers anciens (>30 jours)
    if [[ $(find "$fichier" -mtime +30) ]]; then
        continue
    fi
    
    echo "Analyse de $fichier..."
    # ... traitement ...
done
```

### 3. Menu interactif avec sortie

```bash
#!/bin/bash

while true; do
    echo "Menu :"
    echo "1. Option A"
    echo "2. Option B"
    echo "3. Quitter"
    read -p "Choix : " choix
    
    case $choix in
        1) echo "Option A sélectionnée" ;;
        2) echo "Option B sélectionnée" ;;
        3) echo "Au revoir !"; break ;;
        *) echo "Choix invalide"; continue ;;
    esac
done
```

### 4. Recherche dans une structure hiérarchique

```bash
#!/bin/bash

trouve=false

for dossier in projet/*; do
    [[ ! -d "$dossier" ]] && continue
    
    for fichier in "$dossier"/*.conf; do
        [[ ! -f "$fichier" ]] && continue
        
        if grep -q "DATABASE_URL" "$fichier"; then
            echo "Configuration trouvée dans : $fichier"
            trouve=true
            break 2  # Sort des 2 boucles
        fi
    done
done

[[ $trouve == false ]] && echo "Configuration non trouvée"
```

---

## ⚠️ Pièges courants

> [!warning] Erreur 1 : Mauvais niveau avec `break n` / `continue n`
> 
> ```bash
> # ❌ ERREUR : tente de sortir de 3 niveaux alors qu'il n'y en a que 2
> for i in {1..3}; do
>     for j in {1..3}; do
>         break 3  # Erreur bash
>     done
> done
> ```
> 
> **Solution :** Vérifier le nombre de boucles imbriquées

> [!warning] Erreur 2 : `continue` dans un pipeline
> 
> ```bash
> # ❌ NE FONCTIONNE PAS comme attendu
> cat fichier.txt | while read ligne; do
>     [[ -z "$ligne" ]] && continue
>     echo "$ligne"
> done
> ```
> 
> Le `continue` fonctionne, mais attention : le `while` dans un pipeline s'exécute dans un sous-shell.

> [!warning] Erreur 3 : Logique inversée
> 
> ```bash
> # ❌ Confusion entre break et continue
> for fichier in *.txt; do
>     if [[ "$fichier" == "important.txt" ]]; then
>         break  # ❌ Sort de la boucle → autres fichiers ignorés !
>     fi
>     traiter_fichier "$fichier"
> done
> 
> # ✅ Correct
> for fichier in *.txt; do
>     if [[ "$fichier" == "important.txt" ]]; then
>         continue  # ✓ Saute ce fichier, continue avec les autres
>     fi
>     traiter_fichier "$fichier"
> done
> ```

> [!warning] Erreur 4 : Oublier que le code après est ignoré
> 
> ```bash
> for i in {1..5}; do
>     if [[ $i -eq 3 ]]; then
>         continue
>         echo "Ceci ne sera JAMAIS affiché"  # ❌ Code mort
>     fi
>     echo $i
> done
> ```

---

## ✅ Bonnes pratiques

> [!tip] 1. Privilégier la clarté
> 
> ```bash
> # ❌ Difficile à lire
> for i in {1..100}; do
>     [[ $((i % 2)) -eq 0 ]] && [[ $i -gt 50 ]] && break
>     [[ $((i % 3)) -eq 0 ]] && continue
>     echo $i
> done
> 
> # ✅ Plus clair
> for i in {1..100}; do
>     # Arrêt si nombre pair supérieur à 50
>     if [[ $((i % 2)) -eq 0 && $i -gt 50 ]]; then
>         break
>     fi
>     
>     # Ignorer les multiples de 3
>     if [[ $((i % 3)) -eq 0 ]]; then
>         continue
>     fi
>     
>     echo $i
> done
> ```

> [!tip] 2. Documenter l'utilisation de `break n` / `continue n`
> 
> ```bash
> for categorie in "${categories[@]}"; do
>     for produit in "${produits[@]}"; do
>         if condition_critique; then
>             # Sort de TOUTES les boucles car erreur fatale
>             break 2
>         fi
>     done
> done
> ```

> [!tip] 3. Utiliser des flags pour les cas complexes
> 
> ```bash
> erreur_detectee=false
> 
> for fichier in *.dat; do
>     if ! valider_fichier "$fichier"; then
>         erreur_detectee=true
>         break
>     fi
> done
> 
> if [[ $erreur_detectee == true ]]; then
>     echo "Traitement interrompu suite à une erreur"
>     exit 1
> fi
> ```

> [!tip] 4. Éviter les boucles infinies non contrôlées
> 
> ```bash
> # ✅ Boucle infinie avec garde-fou
> compteur=0
> max_iterations=1000
> 
> while true; do
>     # Logique métier
>     
>     ((compteur++))
>     if [[ $compteur -ge $max_iterations ]]; then
>         echo "⚠️  Limite d'itérations atteinte"
>         break
>     fi
> done
> ```

> [!tip] 5. Combiner avec des conditions de sortie claires
> 
> ```bash
> while true; do
>     read -p "Continuer ? (o/n) : " reponse
>     
>     case $reponse in
>         [oO]) echo "On continue..." ;;
>         [nN]) echo "Arrêt demandé"; break ;;
>         *) echo "Réponse invalide"; continue ;;
>     esac
>     
>     # Code métier ici
> done
> ```

---

## 🎓 Astuce finale

> [!tip] Pensez à la lisibilité Dans le doute entre une structure complexe avec `break`/`continue` et une fonction séparée, privilégiez la **fonction séparée**. Cela améliore la testabilité et la maintenabilité du code.
> 
> ```bash
> # Au lieu de boucles complexes avec break/continue imbriqués
> # → Extraire la logique dans une fonction
> 
> traiter_element() {
>     local element=$1
>     
>     # Conditions de filtrage
>     [[ -z "$element" ]] && return 1
>     [[ ! -f "$element" ]] && return 1
>     
>     # Traitement réel
>     echo "Traitement de $element"
>     return 0
> }
> 
> for element in *; do
>     traiter_element "$element"
> done
> ```

---

_Fin du cours - Contrôle de boucles en Bash_ 🎯