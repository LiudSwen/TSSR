

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

### Qu'est-ce que case/esac ?

La structure `case/esac` est l'équivalent du `switch/case` d'autres langages. Elle permet de tester une variable contre plusieurs valeurs possibles de manière plus lisible et performante qu'une série de `if/elif/else`.

### Quand l'utiliser ?

> [!tip] Utilisez `case` quand :
> 
> - Vous devez comparer **une seule variable** contre plusieurs valeurs
> - Vous avez **3 comparaisons ou plus** à effectuer
> - Vous voulez utiliser des **patterns** (wildcards)
> - La lisibilité est importante (menus, parseurs d'options)

> [!info] Préférez `if/elif/else` quand :
> 
> - Vous devez tester plusieurs variables différentes
> - Vous avez besoin de conditions complexes (`-a`, `-o`, `&&`, `||`)
> - Vous testez des comparaisons numériques ou des tests de fichiers

---

## 🏗️ Structure de base

### Syntaxe minimale

```bash
case $variable in
    pattern1)
        commandes
        ;;
    pattern2)
        commandes
        ;;
    *)
        commandes_par_defaut
        ;;
esac
```

### Exemple simple

```bash
#!/bin/bash

fruit="pomme"

case $fruit in
    pomme)
        echo "C'est une pomme 🍎"
        ;;
    banane)
        echo "C'est une banane 🍌"
        ;;
    orange)
        echo "C'est une orange 🍊"
        ;;
    *)
        echo "Fruit inconnu"
        ;;
esac
```

**Sortie :** `C'est une pomme 🍎`

> [!info] Points clés
> 
> - `case` ouvre la structure, `esac` la ferme (case à l'envers)
> - `$variable` ou `"$variable"` : la variable à tester
> - Chaque pattern se termine par `)`
> - Chaque bloc se termine par `;;`
> - `*)` est le cas par défaut (optionnel mais recommandé)

---

## 📐 Syntaxe détaillée

### 1. Le mot-clé `case` et la variable

```bash
case $var in
# ou
case "$var" in
# ou
case $(commande) in
# ou
case expression in
```

> [!warning] Attention aux guillemets
> 
> ```bash
> # Sans guillemets - peut causer des problèmes si $var contient des espaces
> case $var in
> 
> # Avec guillemets - recommandé pour éviter les problèmes
> case "$var" in
> ```

### 2. Les patterns avec `)`

```bash
    pattern1)
        # Commandes pour pattern1
        ;;
```

**Syntaxe du pattern :**

- Se termine toujours par `)`
- Pas d'espace entre le pattern et `)`
- Peut contenir des wildcards (*, ?, [])

### 3. Les commandes dans chaque cas

```bash
    pattern)
        commande1
        commande2
        commande3
        ;;
```

> [!tip] Multiples commandes
> 
> - Vous pouvez mettre autant de commandes que nécessaire
> - Elles s'exécutent séquentiellement
> - L'indentation aide à la lisibilité

### 4. La terminaison avec `;;`

```bash
    pattern)
        commandes
        ;;  # Termine ce cas et sort du case
```

> [!info] Alternatives à `;;`
> 
> - `;;` : termine et sort du case (standard)
> - `;&` : continue vers le cas suivant (fall-through, bash 4+)
> - `;;&` : continue à tester les patterns suivants (bash 4+)

```bash
#!/bin/bash

lettre="a"

case $lettre in
    [a-z])
        echo "Minuscule"
        ;;&  # Continue à tester
    [aeiou])
        echo "Voyelle"
        ;;
    [bcdfg]*)
        echo "Consonne début alphabet"
        ;;
esac

# Sortie : 
# Minuscule
# Voyelle
```

### 5. La fermeture avec `esac`

```bash
case $var in
    # ... patterns ...
esac  # Fin de la structure case
```

---

## 🎭 Patterns et correspondances

### Patterns simples (littéraux)

```bash
case $couleur in
    rouge)
        echo "Rouge"
        ;;
    bleu)
        echo "Bleu"
        ;;
    vert)
        echo "Vert"
        ;;
esac
```

### Patterns multiples avec `|`

```bash
case $reponse in
    oui|o|yes|y)
        echo "Vous avez accepté"
        ;;
    non|n|no)
        echo "Vous avez refusé"
        ;;
    *)
        echo "Réponse invalide"
        ;;
esac
```

> [!tip] Astuce Le `|` signifie "OU" - le cas correspond si **n'importe quel** pattern correspond

### Wildcards : `*` (n'importe quelle chaîne)

```bash
case $fichier in
    *.txt)
        echo "Fichier texte"
        ;;
    *.jpg|*.png|*.gif)
        echo "Fichier image"
        ;;
    *.sh)
        echo "Script bash"
        ;;
    *)
        echo "Type inconnu"
        ;;
esac
```

> [!info] Le wildcard `*`
> 
> - Correspond à **0 ou plusieurs caractères** de n'importe quel type
> - `*.txt` : n'importe quoi se terminant par `.txt`
> - `log*` : n'importe quoi commençant par `log`
> - `*error*` : n'importe quoi contenant `error`

### Wildcards : `?` (un seul caractère)

```bash
case $code in
    [0-9][0-9][0-9])
        echo "Code à 3 chiffres"
        ;;
    ?)
        echo "Un seul caractère"
        ;;
    ??)
        echo "Deux caractères"
        ;;
esac
```

> [!info] Le wildcard `?`
> 
> - Correspond à **exactement 1 caractère** de n'importe quel type
> - `?` : exactement 1 caractère
> - `??` : exactement 2 caractères
> - `file?.txt` : file1.txt, fileA.txt, etc.

### Classes de caractères `[...]`

```bash
case $input in
    [0-9])
        echo "Un chiffre"
        ;;
    [a-z])
        echo "Une lettre minuscule"
        ;;
    [A-Z])
        echo "Une lettre majuscule"
        ;;
    [aeiou])
        echo "Une voyelle minuscule"
        ;;
    [!0-9]*)
        echo "Ne commence pas par un chiffre"
        ;;
esac
```

> [!info] Classes de caractères
> 
> - `[abc]` : correspond à a, b ou c
> - `[a-z]` : n'importe quelle lettre minuscule
> - `[0-9]` : n'importe quel chiffre
> - `[!...]` ou `[^...]` : négation (tout sauf)

### Exemples de patterns complexes

```bash
#!/bin/bash

case $1 in
    # Options longues
    --help|--aide)
        afficher_aide
        ;;
    
    # Options courtes
    -h|-?)
        afficher_aide
        ;;
    
    # Fichiers de configuration
    *.conf|*.cfg|*.config)
        echo "Fichier de configuration détecté"
        ;;
    
    # Chemins absolus vs relatifs
    /*)
        echo "Chemin absolu"
        ;;
    
    # Adresses email basiques
    *@*.*)
        echo "Possiblement une adresse email"
        ;;
    
    # Nombres
    [0-9]*)
        echo "Commence par un chiffre"
        ;;
    
    # Rien (chaîne vide)
    "")
        echo "Paramètre vide"
        ;;
    
    # Tout le reste
    *)
        echo "Pattern non reconnu: $1"
        ;;
esac
```

---

## 🎪 Cas spéciaux

### Le cas par défaut `*)`

```bash
case $choix in
    1)
        echo "Option 1"
        ;;
    2)
        echo "Option 2"
        ;;
    *)
        echo "Option invalide"
        exit 1
        ;;
esac
```

> [!warning] Toujours inclure un cas par défaut
> 
> - Gère les valeurs inattendues
> - Évite les comportements silencieux
> - Permet de valider les entrées utilisateur

### Chaîne vide `""`

```bash
case $variable in
    "")
        echo "Variable vide ou non définie"
        ;;
    *)
        echo "Variable contient: $variable"
        ;;
esac
```

### Patterns avec espaces

```bash
case "$phrase" in
    "hello world")
        echo "Phrase exacte avec espace"
        ;;
    *" "*)
        echo "Contient un espace"
        ;;
    *)
        echo "Pas d'espace"
        ;;
esac
```

> [!tip] Guillemets obligatoires Si votre pattern contient des espaces, vous **devez** utiliser des guillemets

### Case avec plusieurs actions et sous-shells

```bash
case $action in
    start)
        echo "Démarrage du service..."
        systemctl start monservice
        if [ $? -eq 0 ]; then
            echo "✓ Service démarré"
        fi
        ;;
    
    backup)
        echo "Création du backup..."
        {
            tar -czf backup.tar.gz /data
            mv backup.tar.gz /backups/
        } && echo "✓ Backup réussi" || echo "✗ Backup échoué"
        ;;
esac
```

---

## ⚖️ Comparaison avec if/elif/else

### Cas où `case` est préférable

```bash
# ❌ Avec if/elif/else (verbose)
if [ "$action" = "start" ]; then
    start_service
elif [ "$action" = "stop" ]; then
    stop_service
elif [ "$action" = "restart" ]; then
    restart_service
elif [ "$action" = "status" ]; then
    show_status
else
    echo "Action inconnue"
fi

# ✅ Avec case (clair et concis)
case $action in
    start)   start_service ;;
    stop)    stop_service ;;
    restart) restart_service ;;
    status)  show_status ;;
    *)       echo "Action inconnue" ;;
esac
```

### Cas où `if` est préférable

```bash
# ✅ Avec if (conditions complexes)
if [ $age -ge 18 ] && [ "$permis" = "oui" ]; then
    echo "Peut conduire"
elif [ $age -ge 16 ] && [ "$accompagne" = "oui" ]; then
    echo "Peut conduire accompagné"
else
    echo "Ne peut pas conduire"
fi

# ❌ Avec case (impossible ou très complexe)
# On ne peut pas facilement tester plusieurs variables avec des comparaisons
```

### Tableau comparatif

|Critère|case/esac|if/elif/else|
|---|---|---|
|**Lisibilité** (3+ options)|⭐⭐⭐⭐⭐ Excellente|⭐⭐⭐ Moyenne|
|**Une seule variable**|⭐⭐⭐⭐⭐ Parfait|⭐⭐⭐ Acceptable|
|**Patterns/wildcards**|⭐⭐⭐⭐⭐ Support natif|⭐⭐ Possible mais complexe|
|**Conditions multiples**|⭐ Très difficile|⭐⭐⭐⭐⭐ Parfait|
|**Tests numériques**|⭐⭐ Limité|⭐⭐⭐⭐⭐ Complet|
|**Tests de fichiers**|⭐ Non adapté|⭐⭐⭐⭐⭐ Parfait|
|**Performance** (3+ tests)|⭐⭐⭐⭐⭐ Rapide|⭐⭐⭐ Plus lent|

---

## ⚠️ Pièges courants

### 1. Oublier les `;;`

```bash
# ❌ ERREUR - Syntax error
case $var in
    1)
        echo "Un"
    2)  # ← Erreur de syntaxe ici
        echo "Deux"
        ;;
esac

# ✅ CORRECT
case $var in
    1)
        echo "Un"
        ;;  # Ne pas oublier
    2)
        echo "Deux"
        ;;
esac
```

### 2. Oublier le `esac`

```bash
# ❌ ERREUR
case $var in
    1) echo "Un" ;;
    2) echo "Deux" ;;
# ← Manque esac

# ✅ CORRECT
case $var in
    1) echo "Un" ;;
    2) echo "Deux" ;;
esac
```

### 3. Patterns avec espaces non quotés

```bash
# ❌ ERREUR - Ne fonctionnera pas comme prévu
case $var in
    hello world)  # ← Interprété comme deux mots séparés
        echo "Match"
        ;;
esac

# ✅ CORRECT
case $var in
    "hello world")
        echo "Match"
        ;;
esac
```

### 4. Variable non quotée contenant des espaces

```bash
fichier="mon fichier.txt"

# ❌ PROBLÈME POTENTIEL
case $fichier in
    *.txt)
        echo "Fichier texte"
        ;;
esac

# ✅ MIEUX
case "$fichier" in
    *.txt)
        echo "Fichier texte"
        ;;
esac
```

### 5. Ordre des patterns important

```bash
# ❌ PROBLÈME - Le * attrape tout avant les cas spécifiques
case $fichier in
    *)
        echo "Fichier quelconque"
        ;;
    *.txt)  # ← Ne sera jamais atteint !
        echo "Fichier texte"
        ;;
esac

# ✅ CORRECT - Les cas spécifiques avant le cas général
case $fichier in
    *.txt)
        echo "Fichier texte"
        ;;
    *.log)
        echo "Fichier log"
        ;;
    *)
        echo "Fichier quelconque"
        ;;
esac
```

### 6. Confusion entre `*` et `?`

```bash
# Tester avec un code à 3 chiffres
code="123"

# ❌ Match TOUT ce qui commence par un chiffre
case $code in
    [0-9]*)
        echo "Commence par un chiffre"  # ← Trop large
        ;;
esac

# ✅ Match EXACTEMENT 3 chiffres
case $code in
    [0-9][0-9][0-9])
        echo "Code à 3 chiffres"
        ;;
    *)
        echo "Pas un code à 3 chiffres"
        ;;
esac
```

### 7. Utiliser case pour des tests complexes

```bash
# ❌ MAUVAISE APPROCHE - case n'est pas fait pour ça
case "$age:$permis" in  # Concaténation artificielle
    [1][8-9]:oui|[2-9][0-9]:oui)
        echo "Peut conduire"
        ;;
esac

# ✅ UTILISER IF - Plus clair et maintenable
if [ "$age" -ge 18 ] && [ "$permis" = "oui" ]; then
    echo "Peut conduire"
fi
```

---

## ✅ Bonnes pratiques

### 1. Toujours inclure un cas par défaut

```bash
case $option in
    -h|--help)
        afficher_aide
        ;;
    -v|--version)
        afficher_version
        ;;
    *)
        echo "Option inconnue: $option" >&2
        exit 1
        ;;
esac
```

### 2. Utiliser l'indentation pour la lisibilité

```bash
# ✅ BIEN INDENTÉ
case $action in
    start)
        echo "Démarrage..."
        start_service
        ;;
    
    stop)
        echo "Arrêt..."
        stop_service
        ;;
    
    *)
        echo "Action inconnue"
        ;;
esac

# ❌ DIFFICILE À LIRE
case $action in
start)
echo "Démarrage..."
start_service
;;
stop)
echo "Arrêt..."
stop_service
;;
*)
echo "Action inconnue"
;;
esac
```

### 3. Grouper les patterns similaires

```bash
case $extension in
    # Images
    jpg|jpeg|png|gif|bmp|svg)
        type="image"
        ;;
    
    # Vidéos
    mp4|avi|mkv|mov|wmv)
        type="video"
        ;;
    
    # Documents
    pdf|doc|docx|odt|txt)
        type="document"
        ;;
    
    *)
        type="inconnu"
        ;;
esac
```

### 4. Mettre les cas spécifiques avant les cas généraux

```bash
case $fichier in
    # Cas spécifiques en premier
    config.conf)
        echo "Fichier de config principal"
        ;;
    *.conf)
        echo "Un fichier de config"
        ;;
    
    # Cas général à la fin
    *)
        echo "Pas un fichier de config"
        ;;
esac
```

### 5. Utiliser des fonctions pour les actions complexes

```bash
traiter_image() {
    echo "Traitement de l'image $1..."
    # Logique complexe ici
}

traiter_video() {
    echo "Traitement de la vidéo $1..."
    # Logique complexe ici
}

# Case reste simple et lisible
case $type in
    image)
        traiter_image "$fichier"
        ;;
    video)
        traiter_video "$fichier"
        ;;
    *)
        echo "Type non supporté"
        ;;
esac
```

### 6. Commenter les patterns complexes

```bash
case $input in
    # Adresse IPv4 (validation basique)
    [0-9]*.[0-9]*.[0-9]*.[0-9]*)
        echo "Possible adresse IP"
        ;;
    
    # Adresse email (validation basique)
    *@*.*)
        echo "Possible email"
        ;;
    
    # URL HTTP/HTTPS
    http://*|https://*)
        echo "URL web"
        ;;
esac
```

### 7. One-liner pour les cas simples

```bash
# ✅ ACCEPTABLE pour les cas très simples
case $cmd in
    start)   start_service ;;
    stop)    stop_service ;;
    restart) restart_service ;;
    *)       echo "Commande inconnue" ;;
esac

# ✅ MAIS préférer le multi-ligne si ça devient complexe
case $cmd in
    start)
        echo "Démarrage du service..."
        start_service
        [ $? -eq 0 ] && echo "✓ Démarré"
        ;;
    stop)
        echo "Arrêt du service..."
        stop_service
        [ $? -eq 0 ] && echo "✓ Arrêté"
        ;;
esac
```

### 8. Valider les entrées utilisateur

```bash
read -p "Voulez-vous continuer? (o/n) " reponse

case $reponse in
    o|O|oui|Oui|OUI|y|Y|yes|Yes|YES)
        echo "Continuation..."
        ;;
    n|N|non|Non|NON)
        echo "Annulation."
        exit 0
        ;;
    *)
        echo "Réponse invalide. Veuillez répondre par 'o' ou 'n'." >&2
        exit 1
        ;;
esac
```

---

## 🎯 Exemple complet : Menu interactif

```bash
#!/bin/bash

afficher_menu() {
    echo "================================"
    echo "   MENU PRINCIPAL"
    echo "================================"
    echo "1. Lister les fichiers"
    echo "2. Afficher la date"
    echo "3. Afficher l'utilisation disque"
    echo "4. Afficher les processus"
    echo "q. Quitter"
    echo "================================"
}

while true; do
    afficher_menu
    read -p "Votre choix: " choix
    
    case $choix in
        1)
            echo ""
            ls -lh
            echo ""
            ;;
        
        2)
            echo ""
            date "+%A %d %B %Y - %H:%M:%S"
            echo ""
            ;;
        
        3)
            echo ""
            df -h
            echo ""
            ;;
        
        4)
            echo ""
            ps aux | head -10
            echo ""
            ;;
        
        q|Q|quit|exit)
            echo "Au revoir !"
            exit 0
            ;;
        
        *)
            echo ""
            echo "⚠ Choix invalide. Veuillez choisir une option valide." >&2
            echo ""
            ;;
    esac
    
    read -p "Appuyez sur Entrée pour continuer..."
    clear
done
```

---

## 🎯 Exemple complet : Parseur d'options

```bash
#!/bin/bash

# Valeurs par défaut
verbose=false
output=""
mode="normal"

# Parcours des arguments
while [ $# -gt 0 ]; do
    case $1 in
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -h, --help          Affiche cette aide"
            echo "  -v, --verbose       Mode verbeux"
            echo "  -o, --output FILE   Fichier de sortie"
            echo "  -m, --mode MODE     Mode (normal|debug|test)"
            exit 0
            ;;
        
        -v|--verbose)
            verbose=true
            shift
            ;;
        
        -o|--output)
            if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                output=$2
                shift 2
            else
                echo "Erreur: -o nécessite un argument" >&2
                exit 1
            fi
            ;;
        
        -m|--mode)
            case $2 in
                normal|debug|test)
                    mode=$2
                    shift 2
                    ;;
                *)
                    echo "Erreur: mode invalide '$2'" >&2
                    echo "Modes valides: normal, debug, test" >&2
                    exit 1
                    ;;
            esac
            ;;
        
        -*)
            echo "Option inconnue: $1" >&2
            echo "Utilisez -h pour l'aide" >&2
            exit 1
            ;;
        
        *)
            echo "Argument invalide: $1" >&2
            exit 1
            ;;
    esac
done

# Affichage de la configuration
echo "Configuration:"
echo "  Verbose: $verbose"
echo "  Output: ${output:-stdout}"
echo "  Mode: $mode"
```

---

> [!tip] Astuces finales
> 
> - Utilisez `case` pour améliorer la **lisibilité** de vos scripts
> - Profitez des **patterns** pour gérer des familles de valeurs
> - Pensez à **tester** tous les cas, y compris les cas limites
> - **Documentez** les patterns complexes avec des commentaires
> - Préférez case pour les **menus** et les **parseurs d'options**
> - La performance de `case` est meilleure que `if/elif` pour de nombreux tests