

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

## 🎯 Introduction aux opérateurs logiques

Les opérateurs logiques en Bash permettent de combiner plusieurs commandes ou conditions pour créer des logiques complexes. Ils sont essentiels pour :

- Exécuter des commandes de manière conditionnelle
- Construire des tests sophistiqués
- Gérer les flux d'exécution de scripts
- Créer des chaînes de traitement avec gestion d'erreurs

> [!info] Concept fondamental En Bash, tout repose sur les **codes de retour** :
> 
> - `0` = succès (vrai)
> - Toute autre valeur = échec (faux)
> 
> Les opérateurs logiques exploitent ces codes de retour pour décider quoi faire.

---

## ⛓️ Les opérateurs de chaînage

### L'opérateur ET (`&&`)

#### 📖 Fonctionnement

L'opérateur `&&` exécute la commande de droite **uniquement si** la commande de gauche réussit (retourne 0).

```bash
commande1 && commande2
```

**Logique :** "Fais commande1, ET SI elle réussit, fais commande2"

#### 💡 Quand l'utiliser

- Pour créer des dépendances entre commandes
- Pour éviter d'exécuter une commande si une condition préalable échoue
- Pour construire des chaînes de traitement sécurisées

#### 🔍 Exemples pratiques

```bash
# Créer un répertoire ET se déplacer dedans seulement si la création réussit
mkdir nouveau_dossier && cd nouveau_dossier

# Compiler ET exécuter seulement si la compilation réussit
gcc programme.c -o programme && ./programme

# Vérifier qu'un fichier existe ET le copier
[ -f fichier.txt ] && cp fichier.txt backup.txt

# Chaîne de plusieurs commandes
cd /tmp && mkdir test && cd test && touch fichier.txt
# Chaque commande ne s'exécute que si la précédente a réussi
```

> [!example] Cas d'usage réel
> 
> ```bash
> # Installation sécurisée
> ./configure && make && sudo make install
> # Arrêt immédiat si une étape échoue
> ```

#### ⚙️ Comportement détaillé

```bash
# Commande1 réussit (code retour 0)
true && echo "Ceci sera affiché"
# Sortie : Ceci sera affiché

# Commande1 échoue (code retour non-0)
false && echo "Ceci ne sera PAS affiché"
# Pas de sortie, la 2ème commande n'est pas exécutée

# Avec une commande réelle qui échoue
ls fichier_inexistant.txt && echo "Fichier trouvé"
# Sortie : ls: cannot access 'fichier_inexistant.txt': No such file or directory
# Le echo n'est jamais exécuté
```

---

### L'opérateur OU (`||`)

#### 📖 Fonctionnement

L'opérateur `||` exécute la commande de droite **uniquement si** la commande de gauche échoue (retourne non-0).

```bash
commande1 || commande2
```

**Logique :** "Fais commande1, OU SI elle échoue, fais commande2"

#### 💡 Quand l'utiliser

- Pour fournir un plan B ou une action de secours
- Pour gérer les erreurs
- Pour établir des valeurs par défaut
- Pour créer des mécanismes de fallback

#### 🔍 Exemples pratiques

```bash
# Essayer de se connecter à un serveur OU afficher un message d'erreur
ping -c 1 serveur.com || echo "Serveur inaccessible"

# Utiliser une variable OU une valeur par défaut
cd "$REPERTOIRE" || cd /tmp
# Si $REPERTOIRE est vide ou inexistant, aller dans /tmp

# Créer un répertoire s'il n'existe pas
[ -d backup ] || mkdir backup

# Tenter plusieurs commandes jusqu'à ce que l'une réussisse
command1 || command2 || command3 || echo "Toutes les commandes ont échoué"
```

> [!example] Cas d'usage réel
> 
> ```bash
> # Script de déploiement avec fallback
> deploy_v2.sh || deploy_v1.sh || echo "ERREUR: Déploiement impossible"
> ```

#### ⚙️ Comportement détaillé

```bash
# Commande1 échoue (code retour non-0)
false || echo "Ceci sera affiché car false a échoué"
# Sortie : Ceci sera affiché car false a échoué

# Commande1 réussit (code retour 0)
true || echo "Ceci ne sera PAS affiché"
# Pas de sortie, la 2ème commande n'est pas exécutée

# Avec des commandes réelles
ls fichier.txt 2>/dev/null || echo "Fichier non trouvé"
# Si fichier.txt n'existe pas, affiche "Fichier non trouvé"
```

---

### Combinaison de `&&` et `||`

#### 🎭 Structure ternaire

Vous pouvez combiner `&&` et `||` pour créer une structure similaire à `if-then-else` :

```bash
commande_test && commande_si_vrai || commande_si_faux
```

**Équivalent en pseudo-code :** `if (test) then action1 else action2`

#### 🔍 Exemples

```bash
# Vérifier un fichier et agir en conséquence
[ -f config.txt ] && echo "Config trouvée" || echo "Config manquante"

# Tester une connexion
ping -c 1 google.com &>/dev/null && echo "✓ Connecté" || echo "✗ Hors ligne"

# Vérifier les permissions
[ -w fichier.txt ] && echo "Fichier modifiable" || echo "Fichier en lecture seule"

# Avec une action concrète
[ -x script.sh ] && ./script.sh || chmod +x script.sh
# Si le script est exécutable, le lancer, sinon le rendre exécutable
```

> [!warning] Piège avec la structure ternaire Si `commande_si_vrai` échoue, alors `commande_si_faux` sera exécutée !
> 
> ```bash
> [ -f fichier.txt ] && rm fichier.txt || echo "Fichier supprimé"
> # Si rm échoue (permissions), le message s'affichera quand même !
> ```
> 
> Pour éviter ce problème, utilisez plutôt une vraie structure `if-then-else` pour les cas critiques.

#### 🔗 Chaînes complexes

```bash
# Chaîne de téléchargement avec fallback
wget https://site1.com/fichier.zip || \
    wget https://site2.com/fichier.zip || \
    curl -O https://site3.com/fichier.zip || \
    echo "ERREUR: Impossible de télécharger le fichier"

# Installation avec vérification
which python3 &>/dev/null && \
    echo "Python3 déjà installé" || \
    (sudo apt update && sudo apt install -y python3)
```

---

## 🧪 Les opérateurs dans les tests

Ces opérateurs s'utilisent **à l'intérieur** de la commande `test` ou des crochets `[ ]`.

### L'opérateur `-a` (AND)

#### 📖 Fonctionnement

L'opérateur `-a` permet de combiner deux tests avec un ET logique dans `[ ]`.

```bash
[ test1 -a test2 ]
```

**Les deux tests doivent être vrais pour que l'ensemble soit vrai.**

#### 🔍 Exemples

```bash
# Vérifier qu'un fichier existe ET qu'il est lisible
[ -f fichier.txt -a -r fichier.txt ] && echo "Fichier existe et est lisible"

# Vérifier qu'un nombre est dans un intervalle
[ "$age" -gt 18 -a "$age" -lt 65 ] && echo "Âge valide"

# Vérifier plusieurs propriétés d'un fichier
[ -f script.sh -a -x script.sh -a -s script.sh ] && echo "Script valide et non vide"

# Avec des variables
[ -n "$USER" -a -n "$HOME" ] && echo "Variables d'environnement définies"
```

> [!warning] Dépréciation L'opérateur `-a` est considéré comme obsolète dans les crochets simples `[ ]`. Il est recommandé d'utiliser plutôt :
> 
> - Les doubles crochets `[[ ]]` avec `&&`
> - Ou chaîner plusieurs tests avec `[ ] && [ ]`

#### ✨ Alternatives modernes

```bash
# Avec doubles crochets (RECOMMANDÉ)
[[ -f fichier.txt && -r fichier.txt ]] && echo "OK"

# Avec chaînage de tests
[ -f fichier.txt ] && [ -r fichier.txt ] && echo "OK"
```

---

### L'opérateur `-o` (OR)

#### 📖 Fonctionnement

L'opérateur `-o` permet de combiner deux tests avec un OU logique dans `[ ]`.

```bash
[ test1 -o test2 ]
```

**Au moins un des deux tests doit être vrai pour que l'ensemble soit vrai.**

#### 🔍 Exemples

```bash
# Vérifier qu'un fichier OU un répertoire existe
[ -f config.txt -o -f config.conf ] && echo "Fichier de config trouvé"

# Accepter plusieurs extensions
[ "$fichier" = "*.txt" -o "$fichier" = "*.md" ] && echo "Fichier texte"

# Vérifier plusieurs conditions de sortie
[ "$USER" = "root" -o "$UID" -eq 0 ] && echo "Utilisateur privilégié"

# Multiples options valides
[ "$choix" = "o" -o "$choix" = "O" -o "$choix" = "oui" ] && echo "Accepté"
```

> [!warning] Dépréciation Comme `-a`, l'opérateur `-o` est obsolète dans `[ ]`. Préférez les alternatives modernes.

#### ✨ Alternatives modernes

```bash
# Avec doubles crochets (RECOMMANDÉ)
[[ -f config.txt || -f config.conf ]] && echo "Config trouvée"

# Avec chaînage
[ -f config.txt ] || [ -f config.conf ] && echo "Config trouvée"
```

---

### L'opérateur `!` (NOT)

#### 📖 Fonctionnement

L'opérateur `!` inverse le résultat d'un test ou d'une commande.

```bash
# Dans un test
[ ! test ]

# Avant une commande
! commande
```

**Si le test/commande retourne vrai (0), `!` le transforme en faux (non-0) et vice-versa.**

#### 🔍 Exemples avec tests

```bash
# Vérifier qu'un fichier N'existe PAS
[ ! -f fichier.txt ] && echo "Fichier inexistant, on peut le créer"

# Vérifier qu'un répertoire N'est PAS vide
[ ! -z "$(ls -A repertoire)" ] && echo "Le répertoire contient des fichiers"

# Vérifier qu'une variable N'est PAS définie
[ ! -v MA_VARIABLE ] && echo "Variable non définie"

# Vérifier qu'un utilisateur N'est PAS root
[ ! "$USER" = "root" ] && echo "Utilisateur standard" || echo "Utilisateur root"

# Double négation (rendre lisible une condition complexe)
[ ! -d backup ] && mkdir backup
# "Si le répertoire backup n'existe pas, le créer"
```

#### 🔍 Exemples avec commandes

```bash
# Exécuter si une commande ÉCHOUE
! ping -c 1 serveur.com &>/dev/null && echo "Serveur inaccessible"

# Vérifier qu'un processus ne tourne PAS
! pgrep apache2 &>/dev/null && echo "Apache n'est pas démarré"

# Inverser le résultat d'un grep
! grep -q "ERROR" log.txt && echo "Aucune erreur dans le log"

# Avec des pipelines
! ls fichier_inexistant.txt 2>/dev/null && echo "Fichier non trouvé"
```

> [!tip] Lisibilité L'opérateur `!` est excellent pour la lisibilité car il permet d'exprimer clairement une condition négative.
> 
> Comparez :
> 
> ```bash
> # Moins clair
> [ -f fichier.txt ] || echo "Fichier inexistant"
> 
> # Plus clair
> [ ! -f fichier.txt ] && echo "Fichier inexistant"
> ```

#### 🎯 Avec doubles crochets

```bash
# NOT fonctionne aussi avec [[]]
[[ ! -f fichier.txt ]] && echo "Fichier inexistant"

# Combiné avec d'autres opérateurs
[[ ! -f config.txt && ! -f config.conf ]] && echo "Aucun fichier de config"

# Avec des regex
[[ ! $email =~ @.*\. ]] && echo "Email invalide"
```

---

## 📊 Priorité des opérateurs

La priorité détermine l'ordre dans lequel les opérateurs sont évalués dans une expression complexe.

### 🔢 Ordre de priorité (du plus fort au plus faible)

|Priorité|Opérateur|Description|
|---|---|---|
|1|`( )`|Parenthèses (groupement)|
|2|`!`|NOT (négation)|
|3|`-a` ou `&&`|AND (et logique)|
|4|`-o` ou `||

### 🔍 Exemples de priorité

#### Sans parenthèses

```bash
# Expression : A -o B -a C
# Évaluation : A -o (B -a C)
# Le AND est évalué en premier
[ condition1 -o condition2 -a condition3 ]

# Exemple concret
[ "$x" -eq 1 -o "$y" -eq 2 -a "$z" -eq 3 ]
# Équivaut à : [ "$x" -eq 1 -o ( "$y" -eq 2 -a "$z" -eq 3 ) ]
```

#### Avec parenthèses pour modifier la priorité

```bash
# Forcer l'évaluation du OR en premier
[ \( condition1 -o condition2 \) -a condition3 ]
# Note : les parenthèses doivent être échappées avec \ dans [ ]

# Exemple concret
[ \( "$x" -eq 1 -o "$y" -eq 2 \) -a "$z" -eq 3 ]
# Le OR est évalué en premier, puis le AND
```

> [!warning] Échappement des parenthèses Dans les crochets simples `[ ]`, les parenthèses doivent être échappées : `\( \)`
> 
> Dans les doubles crochets `[[ ]]`, pas besoin d'échapper : `( )`

### 📊 Tableau de vérité

Pour mieux comprendre comment les opérateurs se combinent :

|A|B|C|B AND C|A OR (B AND C)|
|---|---|---|---|---|
|V|V|V|V|V|
|V|V|F|F|V|
|V|F|V|F|V|
|V|F|F|F|V|
|F|V|V|V|V|
|F|V|F|F|F|
|F|F|V|F|F|
|F|F|F|F|F|

---

## 🎪 Parenthèses et groupement

Les parenthèses permettent de contrôler l'ordre d'évaluation et de regrouper des commandes.

### 🔧 Dans les tests simples `[ ]`

```bash
# Parenthèses ÉCHAPPÉES avec \
[ \( test1 -o test2 \) -a test3 ]

# Exemple concret
age=25
etudiant="oui"
[ \( "$age" -lt 18 -o "$etudiant" = "oui" \) -a -f carte.txt ] && echo "Réduction applicable"
# Traduction : (âge < 18 OU étudiant) ET possède une carte
```

### 🔧 Dans les tests doubles `[[ ]]`

```bash
# Parenthèses NON échappées
[[ (test1 || test2) && test3 ]]

# Exemple concret
[[ ($age -lt 18 || $etudiant == "oui") && -f carte.txt ]] && echo "Réduction applicable"
```

> [!tip] Recommandation Utilisez les doubles crochets `[[ ]]` pour éviter les problèmes d'échappement et bénéficier d'une syntaxe plus claire.

### 🎯 Groupement de commandes

Les parenthèses peuvent aussi grouper des **commandes** (pas seulement des tests) :

#### Sous-shell `( )`

```bash
# Crée un sous-shell
(cd /tmp && ls && pwd)
# Les changements ne persistent pas en dehors des parenthèses
pwd  # Toujours dans le répertoire original
```

**Caractéristiques :**

- Exécution dans un nouveau processus (sous-shell)
- Les modifications de variables, changements de répertoire, etc. sont isolés
- Utile pour isoler des actions

```bash
# Exemple pratique
(
    cd /tmp
    fichier="temp_$$.txt"
    echo "Traitement..." > "$fichier"
    cat "$fichier"
    rm "$fichier"
)
# Le fichier temporaire est créé et nettoyé dans le sous-shell
# Le répertoire courant n'a pas changé
```

#### Groupement `{ }`

```bash
# Exécute dans le shell courant
{ cd /tmp && ls && pwd; }
# Attention : nécessite des espaces et un ; à la fin
pwd  # Maintenant dans /tmp !
```

**Caractéristiques :**

- Exécution dans le shell courant (pas de nouveau processus)
- Les modifications persistent
- Plus rapide (pas de fork)
- Syntaxe stricte : espaces obligatoires, `;` final requis

```bash
# Exemple : redirection groupée
{
    echo "Ligne 1"
    echo "Ligne 2"
    echo "Ligne 3"
} > fichier.txt
# Toutes les sorties sont redirigées vers le fichier
```

### 🔀 Combinaison avec opérateurs logiques

```bash
# Grouper plusieurs commandes avec &&
(commande1 && commande2 && commande3) || echo "Au moins une commande a échoué"

# Exemple concret : backup
(tar -czf backup.tar.gz /data && mv backup.tar.gz /backup) || {
    echo "Erreur lors du backup"
    exit 1
}

# Avec chaînage complexe
[[ -f config.txt ]] && {
    source config.txt
    echo "Configuration chargée"
    connexion_serveur
} || {
    echo "Pas de configuration, utilisation des valeurs par défaut"
    utiliser_defauts
}
```

---

## ⚠️ Pièges courants

### 1. Confusion entre `-a`/`-o` et `&&`/`||`

```bash
# ❌ ERREUR : Mélanger les syntaxes
[ -f fichier.txt && -r fichier.txt ]  # SYNTAXE INVALIDE

# ✅ CORRECT : Utiliser -a dans [ ]
[ -f fichier.txt -a -r fichier.txt ]

# ✅ CORRECT (meilleur) : Utiliser && dans [[ ]]
[[ -f fichier.txt && -r fichier.txt ]]

# ✅ CORRECT : Chaîner les tests
[ -f fichier.txt ] && [ -r fichier.txt ]
```

### 2. Oublier les espaces dans les tests

```bash
# ❌ ERREUR : Pas d'espaces
[-f fichier.txt]  # Syntaxe invalide

# ✅ CORRECT
[ -f fichier.txt ]  # Espaces obligatoires après [ et avant ]
```

### 3. Parenthèses non échappées dans `[ ]`

```bash
# ❌ ERREUR
[ (condition1 -o condition2) -a condition3 ]

# ✅ CORRECT
[ \( condition1 -o condition2 \) -a condition3 ]

# ✅ MEILLEUR : Utiliser [[]]
[[ (condition1 || condition2) && condition3 ]]
```

### 4. Structure ternaire problématique

```bash
# ❌ PROBLÈME : Si commande_vraie échoue, commande_fausse s'exécute
condition && commande_vraie || commande_fausse

# Exemple du problème
[ -f fichier.txt ] && rm fichier.txt || echo "Supprimé"
# Si rm échoue (permissions), "Supprimé" s'affiche quand même !

# ✅ SOLUTION : Utiliser if-then-else pour les cas critiques
if [ -f fichier.txt ]; then
    rm fichier.txt
else
    echo "Fichier inexistant"
fi
```

### 5. Priorité des opérateurs mal comprise

```bash
# Ce test peut être mal interprété
[ "$a" -eq 1 -o "$b" -eq 2 -a "$c" -eq 3 ]
# Est évalué comme : [ "$a" -eq 1 -o ("$b" -eq 2 -a "$c" -eq 3) ]

# ✅ CLAIR : Utiliser des parenthèses explicites
[ \( "$a" -eq 1 -o "$b" -eq 2 \) -a "$c" -eq 3 ]

# ✅ ENCORE MIEUX : Utiliser [[]]
[[ ($a -eq 1 || $b -eq 2) && $c -eq 3 ]]
```

### 6. Variables non quotées

```bash
# ❌ ERREUR : Variable vide ou avec espaces
[ $fichier = "test.txt" ]  # Si $fichier est vide → erreur

# ✅ CORRECT : Toujours quoter
[ "$fichier" = "test.txt" ]

# ✅ ENCORE MIEUX : [[ ]] gère mieux les variables vides
[[ $fichier = "test.txt" ]]  # Pas d'erreur si $fichier est vide
```

### 7. Confusion entre `!` et `-n`/`-z`

```bash
# Deux façons de tester si une variable est vide
[ -z "$var" ]      # vrai si $var est vide
[ ! -n "$var" ]    # vrai si $var n'est pas non-vide (= est vide)

# ⚠️ Attention : pas exactement équivalents avec variables non définies
# Préférer -z pour tester le vide, et -n pour tester le non-vide
```

---

## ✅ Bonnes pratiques

### 1. Préférer `[[ ]]` aux crochets simples

```bash
# ❌ Ancien style (mais toujours valide)
[ -f fichier.txt -a -r fichier.txt ]

# ✅ Style moderne (recommandé)
[[ -f fichier.txt && -r fichier.txt ]]
```

**Avantages de `[[ ]]` :**

- Pas besoin d'échapper les parenthèses
- Meilleure gestion des variables vides
- Support des regex avec `=~`
- Support des wildcards avec `==`
- Syntaxe plus cohérente avec d'autres langages

### 2. Quoter les variables dans les tests

```bash
# ✅ Toujours quoter
[[ -f "$fichier" ]]
[ "$var" = "valeur" ]

# Exception : avec [[ ]], les quotes sont optionnelles mais recommandées
[[ -f $fichier ]]  # Fonctionne, mais moins sûr
```

### 3. Utiliser des parenthèses pour la clarté

```bash
# ❌ Ambigu
[[ condition1 || condition2 && condition3 ]]

# ✅ Clair et explicite
[[ condition1 || (condition2 && condition3) ]]
```

### 4. Chaîner les commandes de manière lisible

```bash
# ✅ Sur une ligne pour les enchaînements simples
commande1 && commande2 || echo "Erreur"

# ✅ Multi-lignes pour les chaînes complexes
commande1 && \
    commande2 && \
    commande3 || {
        echo "Une commande a échoué"
        exit 1
    }
```

### 5. Utiliser des fonctions pour les tests complexes

```bash
# ✅ Encapsuler la logique complexe
est_fichier_valide() {
    [[ -f "$1" && -r "$1" && -s "$1" ]]
}

# Utilisation claire
if est_fichier_valide "config.txt"; then
    echo "Fichier valide"
fi
```

### 6. Documenter les conditions complexes

```bash
# ✅ Ajouter des commentaires pour les logiques non triviales
# Vérifie si l'utilisateur est admin OU si c'est un fichier système
[[ $USER == "admin" || $fichier =~ ^/sys/ ]] && {
    # Traitement spécial pour les admins ou fichiers système
    traitement_privilegie
}
```

### 7. Tester le code de retour explicitement quand nécessaire

```bash
# ✅ Pour les commandes critiques, capturer et tester le code de retour
commande_critique
code_retour=$?

if [[ $code_retour -eq 0 ]]; then
    echo "Succès"
elif [[ $code_retour -eq 1 ]]; then
    echo "Erreur mineure"
else
    echo "Erreur critique : $code_retour"
    exit 1
fi
```

### 8. Utiliser `set -e` pour arrêter sur erreur

```bash
#!/bin/bash
set -e  # Arrête le script si une commande échoue

# Maintenant, pas besoin de && entre chaque commande
commande1
commande2
commande3

# Pour permettre une commande d'échouer sans arrêter le script
commande_peut_echouer || true
```

> [!tip] Astuces avancées
> 
> - `set -u` : erreur si variable non définie
> - `set -o pipefail` : échec si une commande d'un pipeline échoue
> - Combinez-les : `set -euo pipefail` pour des scripts robustes

---

## 📚 Synthèse rapide

|Opérateur|Contexte|Signification|Exemple|
|---|---|---|---|
|`&&`|Chaînage|ET : exécute si succès|`cmd1 && cmd2`|
|`||`|Chaînage|
|`-a`|`[ ]`|AND dans test|`[ test1 -a test2 ]`|
|`-o`|`[ ]`|OR dans test|`[ test1 -o test2 ]`|
|`!`|Test/Cmd|NOT : inverse|`[ ! test ]` ou `! cmd`|
|`( )`|Groupement|Sous-shell ou priorité|`(cmd1 && cmd2)`|
|`{ }`|Groupement|Shell courant|`{ cmd1; cmd2; }`|

---

> [!tip] 💡 Astuce finale Les opérateurs logiques sont parmi les outils les plus puissants du shell scripting. Maîtrisez-les pour écrire des scripts élégants, robustes et maintenables. Privilégiez toujours la clarté : un script lisible vaut mieux qu'un script condensé mais obscur.