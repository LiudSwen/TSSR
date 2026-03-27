
---

## 📘 PARTIE 1 : Fondamentaux du Bash

### 1. Introduction et premiers pas

#### 1.1 Qu'est-ce qu'un script Bash

- Définition d'un script shell
- Différence entre shell interactif et script
- Cas d'usage du scripting Bash
- Shells disponibles (sh, bash, zsh, etc.)

#### 1.2 Shebang et exécution de scripts

- Syntaxe du shebang `#!/bin/bash`
- Chemin du shebang (`/bin/bash` vs `/usr/bin/env bash`)
- Création du premier script
- Exécution avec `bash script.sh`
- Exécution directe `./script.sh`

#### 1.3 Droits d'exécution

- Commande `chmod +x script.sh`
- Permissions Unix (lecture, écriture, exécution)
- `chmod 755` vs `chmod +x`
- Vérification des permissions avec `ls -l`

#### 1.4 Commentaires

- Commentaires simples avec `#`
- Commentaires multi-lignes
- Documentation en en-tête de script
- Bonnes pratiques de commentaires

### 2. Variables et types de données

#### 2.1 Déclaration et affectation

- Syntaxe de déclaration `variable=valeur`
- Pas d'espaces autour du `=`
- Utilisation de variables `$variable` ou `${variable}`
- Variables en lecture seule `readonly`
- Suppression de variables `unset`

#### 2.2 Variables d'environnement

- Définition et utilité
- Variables système courantes (`PATH`, `HOME`, `USER`, `PWD`)
- Affichage avec `env` et `printenv`
- Export de variables `export VAR=valeur`
- Différence variable locale vs exportée
- Fichiers de configuration (`.bashrc`, `.bash_profile`)

#### 2.3 Variables spéciales

- `$?` : code de retour de la dernière commande
- `$#` : nombre d'arguments
- `$@` : tous les arguments (séparés)
- `$*` : tous les arguments (chaîne unique)
- `$$` : PID du script
- `$0` : nom du script
- `$1`, `$2`, etc. : arguments positionnels
- `$!` : PID du dernier processus en arrière-plan
- `$_` : dernier argument de la commande précédente

#### 2.4 Portée des variables

- Variables locales dans un script
- Variables globales
- `local` dans les fonctions
- `export` pour les processus enfants
- Héritage des variables

#### 2.5 Substitution de commandes

- Syntaxe avec backticks `` `commande` ``
- Syntaxe moderne `$(commande)`
- Substitution imbriquée
- Capture de sortie de commande

### 3. Entrées/Sorties

#### 3.1 Affichage avec echo

- Syntaxe de base `echo "texte"`
- Option `-n` (pas de retour à la ligne)
- Option `-e` (interprétation des échappements)
- Séquences d'échappement (`\n`, `\t`, `\a`)

#### 3.2 Affichage avec printf

- Syntaxe `printf "format" arguments`
- Spécificateurs de format (`%s`, `%d`, `%f`)
- Contrôle de la largeur et précision
- Différences avec echo

#### 3.3 Lecture utilisateur avec read

- Syntaxe `read variable`
- Option `-p` (prompt)
- Option `-s` (silent, pour mots de passe)
- Option `-t` (timeout)
- Option `-n` (nombre de caractères)
- Option `-a` (lecture dans un tableau)
- Lecture de plusieurs variables

#### 3.4 Redirections

- Redirection de sortie `>` (écrasement)
- Redirection de sortie `>>` (ajout)
- Redirection d'entrée `<`
- Redirection d'erreur `2>`
- Redirection combinée `&>` ou `2>&1`
- Redirection vers `/dev/null`
- Descripteurs de fichiers (0, 1, 2)

#### 3.5 Pipes

- Syntaxe `commande1 | commande2`
- Chaînage de commandes
- Utilisation avec grep, awk, sed
- Pipes nommés (FIFO)

#### 3.6 Here documents

- Syntaxe `<<EOF`
- Here documents avec substitution
- Here documents sans substitution `<<'EOF'`
- Here strings `<<<`

---

## 📘  PARTIE 2 : Tests et conditions

### 1. Tests et opérateurs

#### 1.1 Structure if/elif/else/fi

- Syntaxe de base `if [ condition ]; then`
- Indentation et lisibilité
- `elif` pour conditions multiples
- `else` pour cas par défaut
- Fermeture avec `fi`
- If sur une ligne avec `;`

#### 1.2 Opérateurs de test

- `[ ]` : test classique POSIX
- `[[ ]]` : test étendu Bash
- `test` : commande équivalente à `[ ]`
- Différences entre `[ ]` et `[[ ]]`
- Quand utiliser chaque syntaxe

#### 1.3 Tests sur fichiers

- `-e` : fichier existe
- `-f` : fichier régulier existe
- `-d` : répertoire existe
- `-r` : fichier lisible
- `-w` : fichier modifiable
- `-x` : fichier exécutable
- `-s` : fichier non vide
- `-L` : lien symbolique
- `-h` : lien symbolique (alias de -L)
- `-b` : fichier bloc
- `-c` : fichier caractère
- `-p` : pipe nommé
- `-S` : socket
- `-N` : fichier modifié depuis dernière lecture
- `file1 -nt file2` : file1 plus récent que file2
- `file1 -ot file2` : file1 plus ancien que file2
- `file1 -ef file2` : même inode

#### 1.4 Tests sur chaînes

- `-z` : chaîne vide
- `-n` : chaîne non vide
- `=` ou `==` : égalité de chaînes
- `!=` : inégalité de chaînes
- `<` : ordre lexicographique (avec `[[ ]]`)
- `>` : ordre lexicographique (avec `[[ ]]`)
- Regex avec `=~` dans `[[ ]]`
- Wildcards avec `[[ ]]`

#### 1.5 Tests numériques

- `-eq` : égal à (equal)
- `-ne` : différent de (not equal)
- `-lt` : inférieur à (less than)
- `-gt` : supérieur à (greater than)
- `-le` : inférieur ou égal (less or equal)
- `-ge` : supérieur ou égal (greater or equal)
- Comparaison avec `(( ))` pour arithmétique

#### 1.6 Opérateurs logiques

- `&&` : ET logique (AND)
- `||` : OU logique (OR)
- `!` : négation (NOT)
- `-a` : AND dans `[ ]`
- `-o` : OR dans `[ ]`
- Priorité des opérateurs
- Parenthèses pour grouper

### 2. Structure case

#### 2.1 Syntaxe case/esac

- Structure de base `case $var in`
- Syntaxe des cas avec `)`
- Commandes dans chaque cas
- Terminaison avec `;;`
- Fermeture avec `esac`

#### 2.2 Patterns et wildcards

- Pattern simple (valeur exacte)
- `*` : n'importe quelle chaîne
- `?` : un caractère quelconque
- `[abc]` : ensemble de caractères
- `|` : alternative (ou)
- `)` : cas par défaut avec `*)`
- Fall-through avec `;;&` et `;&`

---

## 📘 PARTIE 3 : Boucles et opérations

### 1. Boucles

#### 1.1 Boucle for classique

- Syntaxe `for var in liste`
- Itération sur mots
- Itération sur fichiers avec glob
- Itération sur séquences `{1..10}`
- Itération sur résultat de commande
- Expansion de chemins

#### 1.2 Boucle for style C

- Syntaxe `for (( init; condition; increment ))`
- Initialisation de compteur
- Condition de continuation
- Incrémentation
- Comparaison avec for classique

#### 1.3 Boucle while

- Syntaxe `while [ condition ]; do`
- Condition vraie pour continuer
- Boucles infinies `while true`
- Lecture de fichiers ligne par ligne
- Combinaison avec read

#### 1.4 Boucle until

- Syntaxe `until [ condition ]; do`
- Condition fausse pour continuer
- Différence avec while
- Cas d'usage typiques

#### 1.5 Contrôle de boucles

- `break` : sortir de la boucle
- `break n` : sortir de n niveaux
- `continue` : passer à l'itération suivante
- `continue n` : dans boucles imbriquées

### 2. Opérations arithmétiques

#### 2.1 Expansion arithmétique $(( ))

- Syntaxe `$(( expression ))`
- Opérateurs de base (`+`, `-`, `*`, `/`, `%`)
- Opérateurs de bits
- Incrémentation `++` et décrémentation `--`
- Affectation combinée (`+=`, `-=`, etc.)
- Variables sans `$` dans `$(( ))`

#### 2.2 Commande let

- Syntaxe `let expression`
- Affectation de variables
- Expressions multiples
- Code de retour

#### 2.3 Commande expr

- Syntaxe `expr expression`
- Ancienne méthode (compatibilité)
- Espaces obligatoires
- Échappement des opérateurs
- Limitations

#### 2.4 Calculs avancés avec bc

- Utilisation de bc pour décimaux
- Syntaxe `echo "expression" | bc`
- Option `-l` pour bibliothèque mathématique
- Précision des décimales avec `scale`
- Fonctions mathématiques (sin, cos, sqrt, etc.)
- Here documents avec bc

---

## 📘 PARTIE 4 : Fonctions et tableaux

### 1. Fonctions

#### 1.1 Déclaration de fonctions

- Syntaxe `function nom { }`
- Syntaxe `nom() { }`
- Différences entre les syntaxes
- Bonnes pratiques de nommage

#### 1.2 Appel de fonctions

- Appel simple `nom`
- Appel avec arguments `nom arg1 arg2`
- Position dans le script
- Portée des fonctions

#### 1.3 Paramètres de fonction

- `$1`, `$2`, etc. : arguments positionnels
- `$#` : nombre d'arguments
- `$@` : tous les arguments (séparés)
- `$*` : tous les arguments (chaîne)
- Vérification du nombre d'arguments
- Arguments par défaut

#### 1.4 Valeur de retour

- `return` : code de retour (0-255)
- Convention : 0 = succès, autre = erreur
- Capture avec `$?`
- `echo` pour retourner des données
- Capture avec substitution de commande

#### 1.5 Variables locales

- Mot-clé `local`
- Portée dans la fonction
- Masquage de variables globales
- Variables locales vs globales

### 2. Tableaux

#### 2.1 Tableaux indexés

- Création `array=(val1 val2 val3)`
- Création vide `array=()`
- Déclaration explicite `declare -a array`
- Tableaux de plusieurs lignes

#### 2.2 Accès aux éléments

- Accès par index `${array[0]}`
- Premier élément (index 0)
- Dernier élément `${array[-1]}`
- Tous les éléments `${array[@]}`
- Tous les éléments `${array[*]}`
- Différence entre `@` et `*`

#### 2.3 Propriétés des tableaux

- Longueur du tableau `${#array[@]}`
- Longueur d'un élément `${#array[0]}`
- Indices utilisés `${!array[@]}`

#### 2.4 Modification de tableaux

- Ajout d'éléments `array+=(val)`
- Modification `array[index]=valeur`
- Suppression d'élément `unset array[index]`
- Suppression complète `unset array`

#### 2.5 Parcours de tableaux

- Boucle for sur valeurs
- Boucle for sur indices
- Boucle while avec compteur
- Slicing de tableaux `${array[@]:start:length}`

#### 2.6 Tableaux associatifs

- Déclaration `declare -A assoc`
- Syntaxe clé-valeur `assoc[key]=value`
- Accès `${assoc[key]}`
- Liste des clés `${!assoc[@]}`
- Vérification d'existence de clé
- Parcours des tableaux associatifs

---

## 📘 PARTIE 5 : Manipulation de données

### 1. Manipulation de chaînes

#### 1.1 Longueur de chaîne

- Syntaxe `${#variable}`
- Utilisation dans conditions
- Chaînes vides

#### 1.2 Extraction de sous-chaîne

- Syntaxe `${variable:offset}`
- Syntaxe `${variable:offset:length}`
- Offset négatif (depuis la fin)
- Extraction de suffixe

#### 1.3 Remplacement de patterns

- Première occurrence `${var/pattern/replacement}`
- Toutes occurrences `${var//pattern/replacement}`
- Remplacement au début `${var/#pattern/replacement}`
- Remplacement à la fin `${var/%pattern/replacement}`
- Suppression `${var/pattern/}`

#### 1.4 Suppression de préfixes/suffixes

- Plus court préfixe `${var#pattern}`
- Plus long préfixe `${var##pattern}`
- Plus court suffixe `${var%pattern}`
- Plus long suffixe `${var%%pattern}`
- Extraction de nom de fichier et extension

#### 1.5 Conversion de casse

- Tout en majuscules `${var^^}`
- Tout en minuscules `${var,,}`
- Premier caractère en majuscule `${var^}`
- Premier caractère en minuscule `${var,}`
- Patterns spécifiques `${var^^[pattern]}`

#### 1.6 Valeurs par défaut

- `${var:-default}` : valeur par défaut si vide
- `${var:=default}` : assigner si vide
- `${var:?message}` : erreur si vide
- `${var:+alternative}` : valeur si définie

### 2. Traitement de fichiers et texte

#### 2.1 grep - Recherche de patterns

- Syntaxe de base `grep pattern file`
- Option `-i` : insensible à la casse
- Option `-v` : inverser la recherche
- Option `-r` : récursif
- Option `-l` : afficher noms de fichiers
- Option `-n` : numéros de lignes
- Option `-c` : compter les occurrences
- Option `-E` : regex étendues (egrep)
- Option `-o` : afficher seulement le match
- Expressions régulières basiques
- Expressions régulières étendues

#### 2.2 sed - Édition de flux

- Syntaxe `sed 'commande' file`
- Substitution `s/pattern/replacement/`
- Flags (`g`, `i`, numéro)
- Suppression de lignes `d`
- Insertion `i` et ajout `a`
- Remplacement de lignes `c`
- Affichage sélectif `p` avec `-n`
- Plages de lignes `1,10` ou `/pattern/,/pattern/`
- Option `-i` : modification in-place
- Utilisation avec regex

#### 2.3 awk - Traitement de colonnes

- Syntaxe `awk 'pattern {action}' file`
- Variables intégrées (`$1`, `$2`, `$NF`, `$NR`)
- Séparateur de champs `-F`
- BEGIN et END
- Conditions et filtres
- Opérations arithmétiques
- Fonctions intégrées (length, substr, etc.)
- Tableaux associatifs dans awk
- printf dans awk

#### 2.4 cut - Extraction de colonnes

- Option `-d` : délimiteur
- Option `-f` : champs à extraire
- Option `-c` : caractères à extraire
- Plages de champs `1-3` ou `1,3,5`

#### 2.5 sort - Tri de lignes

- Tri alphabétique par défaut
- Option `-n` : tri numérique
- Option `-r` : tri inverse
- Option `-k` : tri par colonne
- Option `-t` : délimiteur
- Option `-u` : supprimer doublons

#### 2.6 uniq - Lignes uniques

- Suppression de doublons consécutifs
- Option `-c` : compter occurrences
- Option `-d` : afficher seulement doublons
- Option `-u` : afficher seulement uniques
- Utilisation avec sort

#### 2.7 wc - Comptage

- `wc -l` : compter lignes
- `wc -w` : compter mots
- `wc -c` : compter octets
- `wc -m` : compter caractères

#### 2.8 find - Recherche de fichiers

- Syntaxe `find chemin critères`
- `-name` : recherche par nom
- `-iname` : insensible à la casse
- `-type` : type de fichier (f, d, l)
- `-size` : taille de fichier
- `-mtime` : date de modification
- `-exec` : exécuter commande
- `-delete` : supprimer fichiers
- Combinaison de critères
- `-maxdepth` et `-mindepth`
- `-prune` : exclure répertoires

---

## 📘 PARTIE 6 : Pratiques avancées et professionnelles

### 1. Gestion des erreurs

#### 1.1 Codes de retour

- Variable `$?`
- Convention : 0 = succès
- Codes d'erreur standards
- Définir codes personnalisés avec `exit`
- Vérification de codes de retour

#### 1.2 Options de sécurité (set)

- `set -e` : arrêt sur erreur
- `set -u` : erreur sur variable non définie
- `set -o pipefail` : échec dans pipes
- `set -x` : mode debug
- Combinaison `set -euo pipefail`
- Désactivation avec `+`

#### 1.3 trap - Gestion des signaux

- Syntaxe `trap 'commandes' SIGNAL`
- Signaux courants (EXIT, INT, TERM, ERR)
- Nettoyage en sortie de script
- Gestion d'interruption Ctrl+C
- Suppression de trap
- Fonctions dans trap

#### 1.4 Validation des entrées

- Vérification d'arguments
- Tests de validité
- Messages d'erreur clairs
- Usage et aide `--help`
- Valeurs par défaut sécurisées

### 2. Débogage

#### 2.1 Mode debug (set -x)

- Activation `set -x`
- Désactivation `set +x`
- Debug sélectif dans le script
- Variable `PS4` pour personnaliser
- Redirection du debug

#### 2.2 Mode verbose (set -v)

- Activation `set -v`
- Affichage des lignes avant exécution
- Différence avec `-x`
- Combinaison `-xv`

#### 2.3 Techniques de débogage

- `echo` pour tracer l'exécution
- Affichage de variables
- Points d'arrêt avec `read`
- Logs dans fichiers
- Fonction de logging personnalisée
- Niveaux de log (DEBUG, INFO, ERROR)

### 3. Paramètres et options

#### 3.1 Arguments positionnels

- `$1`, `$2`, etc.
- Limite à `$9` (utiliser `${10}`)
- Vérification de présence
- Messages d'usage

#### 3.2 getopts - Options courtes

- Syntaxe `getopts "abc:" opt`
- Options sans argument
- Options avec argument (`:`)
- Variable `OPTARG`
- Variable `OPTIND`
- Gestion d'erreurs
- Boucle de traitement

#### 3.3 Parsing d'options avancé

- Options longues avec case
- Combinaison courtes et longues
- Arguments restants après options
- Format `--option=valeur`

#### 3.4 shift

- Décalage des arguments
- `shift n` : décaler de n positions
- Utilisation avec boucles
- Traitement d'arguments variables

### 4. Bonnes pratiques

#### 4.1 Nommage des variables

- Conventions de nommage
- MAJUSCULES pour constantes
- minuscules pour variables locales
- snake_case vs camelCase
- Noms descriptifs

#### 4.2 Quotage

- Guillemets doubles `" "` : interprétation
- Guillemets simples `' '` : littéral
- Quand utiliser chaque type
- Protection des espaces et caractères spéciaux
- Quotage de `"$@"` vs `$@`
- Expansion dans guillemets

#### 4.3 Sécurité

- Éviter `eval` quand possible
- Attention aux injections de commandes
- Validation des entrées utilisateur
- Chemins absolus pour commandes critiques
- Umask approprié
- Pas de mots de passe en clair
- Variables sensibles non exportées

#### 4.4 Portabilité

- Shebang portable `/usr/bin/env bash`
- Éviter les bashismes si sh requis
- Vérification de version de Bash
- Commandes POSIX vs GNU
- Tests de compatibilité

#### 4.5 Documentation

- En-tête de script (auteur, date, description)
- Commentaires explicatifs
- Documentation des fonctions
- Exemples d'utilisation
- Section `--help`
- Format standardisé

#### 4.6 Commandes dangereuses

- `rm -rf` : vérifications multiples
- `mv` et `cp` : options `-i` ou `-n`
- Commandes sur `/` : protections
- Wildcards : quotage et vérification
- `chmod` et `chown` récursifs

### 5. Utilitaires système courants

#### 5.1 Gestion des processus

- `ps` : lister les processus
- `ps aux` : tous les processus
- `pgrep` : trouver par nom
- `kill` : terminer un processus
- Signaux (`SIGTERM`, `SIGKILL`, etc.)
- `killall` et `pkill`
- `jobs` : tâches en arrière-plan
- `bg` : reprendre en arrière-plan
- `fg` : reprendre au premier plan
- `&` : lancer en arrière-plan
- `nohup` : détacher du terminal
- `wait` : attendre fin de processus

#### 5.2 Informations système

- `uname` : infos système
- `uname -a` : toutes les infos
- `hostname` : nom de la machine
- `whoami` : utilisateur courant
- `id` : identité complète
- `date` : date et heure
- Format de date personnalisé
- `uptime` : temps de fonctionnement
- `df` : espace disque
- `du` : usage disque
- `free` : mémoire disponible

#### 5.3 Gestion des utilisateurs et permissions

- `useradd` et `adduser`
- `userdel` : supprimer utilisateur
- `passwd` : changer mot de passe
- `groups` : groupes d'un utilisateur
- `chown` : changer propriétaire
- `chgrp` : changer groupe
- `chmod` : changer permissions
- Permissions symboliques vs octales
- ACL avec `setfacl` et `getfacl`

#### 5.4 Tâches planifiées (cron)

- Syntaxe de crontab
- `crontab -e` : éditer
- `crontab -l` : lister
- Format : minute heure jour mois jour_semaine
- Exemples de planification
- Variables d'environnement dans cron
- Logs de cron
- Alternatives : `at`, `systemd timers`

#### 5.5 Logs système

- Emplacement des logs (`/var/log/`)
- `syslog` et `rsyslog`
- `journalctl` (systemd)
- Lecture de logs avec `tail -f`
- Rotation des logs
- Niveaux de log
- Logger depuis scripts

---