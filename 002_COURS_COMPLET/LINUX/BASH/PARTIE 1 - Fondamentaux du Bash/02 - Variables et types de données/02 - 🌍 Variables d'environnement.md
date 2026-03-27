
> [!info] Vue d'ensemble Les variables d'environnement sont un mécanisme fondamental qui permet aux processus de partager des informations de configuration et de contrôler le comportement des programmes. Elles constituent l'interface entre le système, le shell et les applications.

---

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

## 🎯 Définition et utilité

### Qu'est-ce qu'une variable d'environnement ?

Une variable d'environnement est une **valeur nommée** stockée dans l'environnement d'exécution d'un processus. Elle est transmise aux processus enfants et influence leur comportement.

> [!example] Analogie Imaginez les variables d'environnement comme des **notes adhésives** collées sur le bureau d'un employé. Tous les programmes qu'il lance peuvent lire ces notes pour savoir comment se comporter (où chercher des fichiers, quelle langue utiliser, etc.).

### Pourquoi sont-elles importantes ?

Les variables d'environnement permettent de :

- **Configurer le comportement des programmes** sans modifier leur code
- **Partager des informations** entre processus parent et enfants
- **Personnaliser l'environnement** de travail de chaque utilisateur
- **Localiser des ressources** (chemins de recherche, bibliothèques)
- **Gérer la sécurité** (tokens, clés API temporaires)

> [!tip] Cas d'usage courants
> 
> - Définir où chercher les commandes exécutables (`PATH`)
> - Spécifier l'éditeur de texte par défaut (`EDITOR`)
> - Configurer la langue de l'interface (`LANG`)
> - Stocker temporairement des identifiants API
> - Personnaliser l'apparence du prompt shell

---

## 🔧 Variables système courantes

Voici les variables d'environnement les plus importantes que vous rencontrerez quotidiennement :

### `$PATH` - Chemin de recherche des exécutables

La variable la plus cruciale du système. Elle contient une liste de répertoires (séparés par `:`) où le shell cherche les commandes exécutables.

```bash
# Afficher le PATH
echo $PATH
# Résultat typique : /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Ajouter un répertoire au PATH (temporaire)
export PATH="/mon/nouveau/dossier:$PATH"
```

> [!warning] Ordre important Les répertoires sont parcourus de **gauche à droite**. Si deux commandes portent le même nom, c'est la première trouvée qui sera exécutée.

**Pourquoi c'est important :** Sans `PATH`, vous devriez taper le chemin complet de chaque commande (`/usr/bin/ls` au lieu de `ls`).

### `$HOME` - Répertoire personnel

Contient le chemin absolu vers le répertoire personnel de l'utilisateur actuel.

```bash
echo $HOME
# Résultat : /home/username ou /Users/username (macOS)

# Équivalent au raccourci ~
cd $HOME
cd ~  # Identique
```

> [!tip] Utilisation dans les scripts Utilisez `$HOME` plutôt que le chemin en dur pour rendre vos scripts portables entre utilisateurs.

### `$USER` - Nom d'utilisateur

Identifie l'utilisateur actuel du système.

```bash
echo $USER
# Résultat : votre_nom_utilisateur

# Utilisation pratique dans un script
echo "Bonjour $USER, bienvenue !"
```

### `$PWD` - Répertoire courant

Contient le chemin absolu du répertoire de travail actuel (Present Working Directory).

```bash
echo $PWD
# Résultat : /home/username/projets/mon_projet

# Équivalent à la commande pwd
pwd
```

> [!info] Mise à jour automatique `PWD` est automatiquement mise à jour par le shell à chaque fois que vous changez de répertoire avec `cd`.

### Autres variables importantes

| Variable    | Description                 | Exemple               |
| ----------- | --------------------------- | --------------------- |
| `$SHELL`    | Chemin du shell courant     | `/bin/bash`           |
| `$TERM`     | Type de terminal            | `xterm-256color`      |
| `$LANG`     | Langue et encodage          | `fr_FR.UTF-8`         |
| `$EDITOR`   | Éditeur de texte par défaut | `vim`, `nano`         |
| `$HOSTNAME` | Nom de la machine           | `mon-ordinateur`      |
| `$OLDPWD`   | Répertoire précédent        | `/home/username/docs` |
| `$PS1`      | Format du prompt shell      | `\u@\h:\w\$`          |

```bash
# Exemples d'utilisation
echo "Shell utilisé : $SHELL"
echo "Nom de la machine : $HOSTNAME"
echo "Langue système : $LANG"
```

---

## 👁️ Affichage des variables

### Commande `env`

Affiche toutes les variables d'environnement **exportées** du processus courant.

```bash
# Afficher toutes les variables d'environnement
env

# Résultat (extrait) :
# PATH=/usr/local/bin:/usr/bin:/bin
# HOME=/home/username
# USER=username
# SHELL=/bin/bash
# ...
```

> [!tip] Filtrer avec grep
> 
> ```bash
> # Rechercher une variable spécifique
> env | grep PATH
> env | grep -i user  # Insensible à la casse
> ```

### Commande `printenv`

Similaire à `env`, mais permet d'afficher une variable spécifique.

```bash
# Afficher toutes les variables
printenv

# Afficher une variable spécifique
printenv PATH
printenv HOME

# Plusieurs variables à la fois
printenv PATH HOME USER
```

### Différence entre `env` et `printenv`

|Commande|Usage|Particularité|
|---|---|---|
|`env`|`env`|Peut exécuter une commande avec un environnement modifié|
|`printenv`|`printenv [VAR]`|Plus pratique pour afficher une variable précise|

```bash
# env peut exécuter des commandes avec environnement personnalisé
env VAR=valeur commande

# printenv est plus simple pour consulter
printenv VAR
```

### Affichage avec `echo`

La méthode la plus directe pour consulter une variable.

```bash
# Syntaxe avec $
echo $PATH
echo $HOME

# Syntaxe avec accolades (recommandée pour éviter les ambiguïtés)
echo ${PATH}
echo "Mon répertoire : ${HOME}/documents"
```

> [!warning] Attention aux guillemets
> 
> ```bash
> # Avec guillemets doubles : expansion des variables
> echo "Mon PATH : $PATH"  # ✅ La variable est remplacée
> 
> # Avec guillemets simples : pas d'expansion
> echo 'Mon PATH : $PATH'  # ❌ Affiche littéralement $PATH
> ```

### Commande `set`

Affiche **toutes** les variables (locales et d'environnement) ainsi que les fonctions définies.

```bash
# Afficher absolument tout
set | less

# set produit beaucoup plus de sortie que env
```

---

## 📤 Export de variables

### Syntaxe de base

L'export permet de rendre une variable accessible aux **processus enfants** lancés depuis le shell courant.

```bash
# Définir une variable locale
MA_VAR="valeur"

# Exporter la variable
export MA_VAR

# Ou en une seule ligne (recommandé)
export MA_VAR="valeur"
```

> [!info] Pourquoi exporter ? Sans export, une variable n'existe que dans le shell courant. Les scripts et commandes que vous lancez ne peuvent pas y accéder.

### Exemples pratiques

```bash
# Définir l'éditeur par défaut
export EDITOR="vim"

# Ajouter un répertoire au PATH
export PATH="$HOME/bin:$PATH"

# Configurer une variable pour un projet
export PROJECT_ROOT="/home/username/mon_projet"
export API_KEY="secret123"

# Variables pour compilation
export CC="gcc"
export CFLAGS="-Wall -O2"
```

### Export temporaire pour une commande

Vous pouvez définir une variable d'environnement **uniquement pour une commande** sans affecter le shell :

```bash
# Syntaxe : VAR=valeur commande
LANG=en_US.UTF-8 date
TZ=America/New_York date

# La variable n'existe que le temps de l'exécution
echo $LANG  # Affiche la valeur originale, pas en_US.UTF-8
```

> [!example] Cas d'usage réel
> 
> ```bash
> # Lancer un programme avec une configuration spécifique
> DEBUG=1 ./mon_programme
> 
> # Compiler avec un compilateur différent
> CC=clang make
> 
> # Tester avec une langue différente
> LANG=fr_FR.UTF-8 ./application
> ```

### Retirer un export

```bash
# Supprimer complètement une variable
unset MA_VAR

# Vérifier qu'elle n'existe plus
echo $MA_VAR  # N'affiche rien
```

---

## ⚖️ Variables locales vs exportées

### Concept fondamental

C'est l'une des distinctions les plus importantes à comprendre en bash.

|Type|Portée|Héritage|Création|
|---|---|---|---|
|**Variable locale**|Shell courant uniquement|❌ Non transmise aux enfants|`VAR="valeur"`|
|**Variable exportée**|Shell + processus enfants|✅ Transmise aux enfants|`export VAR="valeur"`|

### Démonstration par l'exemple

```bash
# 1. Créer une variable locale
LOCAL_VAR="je suis locale"

# 2. Créer une variable exportée
export EXPORT_VAR="je suis exportée"

# 3. Tester dans le shell courant
echo $LOCAL_VAR    # Fonctionne : "je suis locale"
echo $EXPORT_VAR   # Fonctionne : "je suis exportée"

# 4. Tester dans un sous-shell (bash -c)
bash -c 'echo "Local : $LOCAL_VAR"'   # N'affiche rien
bash -c 'echo "Export : $EXPORT_VAR"' # Affiche : "je suis exportée"
```

> [!example] Illustration concrète
> 
> ```bash
> # Script test.sh
> #!/bin/bash
> echo "Dans le script :"
> echo "LOCAL_VAR = $LOCAL_VAR"
> echo "EXPORT_VAR = $EXPORT_VAR"
> 
> # Dans le shell :
> LOCAL_VAR="locale"
> export EXPORT_VAR="exportée"
> ./test.sh
> 
> # Résultat :
> # Dans le script :
> # LOCAL_VAR = 
> # EXPORT_VAR = exportée
> ```

### Quand utiliser chaque type ?

**Variables locales** :

- Calculs intermédiaires dans un script
- Données temporaires non partagées
- Éviter la pollution de l'environnement

```bash
# Bon usage de variables locales
compteur=0
temp_file="/tmp/data_$$"
resultat=$(calcul_complexe)
```

**Variables exportées** :

- Configuration persistante pour tous les programmes
- Variables nécessaires aux scripts enfants
- Paramètres d'environnement standard

```bash
# Bon usage de variables exportées
export PATH="$HOME/bin:$PATH"
export EDITOR="vim"
export PROJECT_DIR="/home/user/projet"
```

### Convertir une variable locale en exportée

```bash
# Définition locale
MA_VAR="valeur"

# Vérifier qu'elle n'est pas exportée
bash -c 'echo $MA_VAR'  # N'affiche rien

# Exporter après coup
export MA_VAR

# Maintenant elle est accessible
bash -c 'echo $MA_VAR'  # Affiche : "valeur"
```

### Afficher uniquement les variables exportées

```bash
# Méthode 1 : env ou printenv
env

# Méthode 2 : export sans argument
export

# Méthode 3 : declare avec -x
declare -x
```

---

## 📁 Fichiers de configuration

Les fichiers de configuration permettent de définir automatiquement vos variables d'environnement à chaque connexion.

### `.bashrc` - Configuration interactive

**Quand est-il chargé ?** À chaque ouverture d'un shell interactif non-login (terminal standard).

**Emplacement :** `~/.bashrc`

**Usage typique :** Alias, fonctions, personnalisation du prompt, variables pour l'usage quotidien.

```bash
# Exemple de ~/.bashrc

# Personnalisation du prompt
export PS1="\u@\h:\w\$ "

# Alias courants
alias ll='ls -lah'
alias grep='grep --color=auto'

# Variables d'environnement personnelles
export EDITOR="vim"
export VISUAL="vim"

# Ajout au PATH
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Variables de développement
export PROJECTS="$HOME/projets"
export GOPATH="$HOME/go"

# Configuration d'outils
export HISTSIZE=10000
export HISTFILESIZE=20000
```

> [!tip] Recharger .bashrc Après modification, rechargez sans redémarrer le terminal :
> 
> ```bash
> source ~/.bashrc
> # ou
> . ~/.bashrc
> ```

### `.bash_profile` - Configuration login

**Quand est-il chargé ?** Au démarrage d'un shell de connexion (login shell).

**Emplacement :** `~/.bash_profile` ou `~/.profile`

**Usage typique :** Variables d'environnement globales, chargement de `.bashrc`.

```bash
# Exemple de ~/.bash_profile

# Charger .bashrc pour unifier la configuration
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Variables d'environnement importantes
export PATH="/usr/local/bin:$PATH"
export LANG="fr_FR.UTF-8"
export LC_ALL="fr_FR.UTF-8"

# Configuration SSH
export SSH_KEY_PATH="~/.ssh/id_rsa"

# Variables pour applications spécifiques
export JAVA_HOME="/usr/lib/jvm/java-11"
export MAVEN_HOME="/opt/maven"
export PATH="$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH"
```

### Différence entre les fichiers

|Fichier|Type de shell|Quand|Usage principal|
|---|---|---|---|
|`.bash_profile`|Login|Connexion SSH, console|Variables d'environnement globales|
|`.bashrc`|Non-login|Nouveau terminal|Alias, fonctions, prompt|
|`.profile`|Login (POSIX)|Alternatif à `.bash_profile`|Compatible tous shells|

> [!warning] Ordre de chargement Bash cherche les fichiers dans cet ordre et charge le **premier trouvé** :
> 
> 1. `~/.bash_profile`
> 2. `~/.bash_login`
> 3. `~/.profile`
> 
> C'est pourquoi on source `.bashrc` depuis `.bash_profile` !

### Différence login vs non-login

```bash
# Shell de login (charge .bash_profile)
ssh user@server
su - user
bash --login

# Shell non-login (charge .bashrc)
bash
ouvrir un nouveau terminal
gnome-terminal
```

### `/etc/profile` et `/etc/bash.bashrc` - Configuration système

Ces fichiers contiennent la configuration **globale** pour tous les utilisateurs.

```bash
# /etc/profile : chargé pour tous les shells de login
# /etc/bash.bashrc : chargé pour tous les shells interactifs
```

> [!warning] Modifications système Ne modifiez ces fichiers que si vous êtes administrateur et que vous voulez affecter **tous les utilisateurs**. Privilégiez toujours vos fichiers personnels.

### Organisation recommandée

```bash
# ~/.bash_profile (minimal)
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# ~/.bashrc (configuration complète)
# 1. Variables d'environnement
export EDITOR="vim"
export PATH="$HOME/bin:$PATH"

# 2. Alias
alias ll='ls -lah'
alias ..='cd ..'

# 3. Fonctions personnalisées
mkcd() { mkdir -p "$1" && cd "$1"; }

# 4. Configuration du prompt
export PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '

# 5. Chargement de configurations spécifiques
[ -f ~/.bash_aliases ] && source ~/.bash_aliases
[ -f ~/.bash_functions ] && source ~/.bash_functions
```

---

## ✅ Bonnes pratiques

### Nommage des variables

```bash
# ✅ BON : Majuscules pour les variables exportées
export MY_APP_CONFIG="/etc/myapp"
export DATABASE_URL="postgres://localhost"

# ✅ BON : Minuscules pour les variables locales
local_var="temporaire"
temp_file="/tmp/data"

# ❌ ÉVITER : Minuscules pour variables exportées (confusion)
export path="/mon/chemin"  # Trop proche de PATH
```

> [!tip] Convention
> 
> - **MAJUSCULES** : Variables d'environnement globales
> - **minuscules** : Variables locales de scripts
> - **PascalCase** : Rare, parfois pour variables applicatives

### Modification du PATH

```bash
# ✅ BON : Ajouter au début (priorité)
export PATH="$HOME/bin:$PATH"

# ✅ BON : Ajouter à la fin
export PATH="$PATH:/opt/bin"

# ❌ DANGEREUX : Écraser complètement
export PATH="/mon/chemin"  # Vous perdez /usr/bin, /bin, etc.

# ✅ BON : Vérifier avant d'ajouter (éviter doublons)
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    export PATH="$HOME/bin:$PATH"
fi
```

### Protection des variables sensibles

```bash
# ❌ DANGEREUX : Stocker des secrets dans .bashrc
export API_KEY="secret123"  # Visible dans env, historique, etc.

# ✅ MIEUX : Utiliser un fichier séparé non versionné
[ -f ~/.bash_secrets ] && source ~/.bash_secrets

# ✅ MIEUX : Variables temporaires dans session
read -sp "Entrez votre mot de passe : " PASSWORD
export PASSWORD

# ✅ MIEUX : Outils de gestion de secrets
# - pass (gestionnaire de mots de passe)
# - keychain (gestion de clés SSH)
# - direnv (variables par répertoire)
```

### Valeurs par défaut

```bash
# Utiliser une valeur par défaut si variable non définie
echo "${EDITOR:-vim}"  # Si EDITOR vide, utilise "vim"

# Définir une variable seulement si non définie
: ${EDITOR:=vim}
export EDITOR

# Dans un script
OUTPUT_DIR="${OUTPUT_DIR:-./output}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
```

### Nettoyage

```bash
# Supprimer une variable devenue inutile
unset TEMP_VAR

# Nettoyer le PATH des doublons
export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':')
```

### Vérification de l'existence

```bash
# Tester si une variable est définie
if [ -z "$MY_VAR" ]; then
    echo "MY_VAR n'est pas définie"
fi

# Tester si une variable est non vide
if [ -n "$MY_VAR" ]; then
    echo "MY_VAR contient : $MY_VAR"
fi

# Arrêter le script si variable critique absente
: ${DATABASE_URL:?Erreur: DATABASE_URL doit être définie}
```

### Documentation dans les fichiers de config

```bash
# ~/.bashrc

# ============================================
# VARIABLES D'ENVIRONNEMENT
# ============================================

# Éditeur de texte par défaut
export EDITOR="vim"
export VISUAL="vim"

# Répertoires de développement
export PROJECTS="$HOME/projets"     # Tous mes projets
export DOTFILES="$HOME/.dotfiles"   # Configuration système

# Python - Environnement virtuel
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_PYTHON="/usr/bin/python3"

# ============================================
# PATH - Chemins de recherche
# ============================================

# Scripts personnels
export PATH="$HOME/bin:$PATH"

# Applications locales
export PATH="$HOME/.local/bin:$PATH"
```

---

## 🎯 Pièges courants

### Piège 1 : Espaces autour du `=`

```bash
# ❌ ERREUR : Espaces autour du =
export MA_VAR = "valeur"   # Erreur de syntaxe

# ✅ CORRECT
export MA_VAR="valeur"
```

### Piège 2 : Guillemets oubliés avec espaces

```bash
# ❌ PROBLÈME : Valeur avec espaces sans guillemets
export MESSAGE=Hello World  # N'assigne que "Hello"

# ✅ CORRECT
export MESSAGE="Hello World"
```

### Piège 3 : Confusion expansion de variables

```bash
# PATH actuel : /usr/bin:/bin
export PATH="/opt/bin:$PATH"  # ✅ Résultat : /opt/bin:/usr/bin:/bin
export PATH='/opt/bin:$PATH'  # ❌ Résultat : /opt/bin:$PATH (littéral)
```

### Piège 4 : Modification sans export

```bash
# Dans le shell
PATH="$HOME/bin:$PATH"  # ⚠️ Fonctionne mais pas exporté aux enfants

# ✅ MIEUX
export PATH="$HOME/bin:$PATH"
```

### Piège 5 : Réassignation complète du PATH

```bash
# ❌ CATASTROPHIQUE
export PATH="/mon/chemin"
# Vous ne pouvez plus exécuter ls, cd, cat, etc.

# 🔧 Solution d'urgence
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
```

---

## 🎓 Astuces avancées

### Afficher proprement le PATH

```bash
# PATH lisible ligne par ligne
echo $PATH | tr ':' '\n'

# Avec numérotation
echo $PATH | tr ':' '\n' | nl

# Afficher uniquement les répertoires existants
echo $PATH | tr ':' '\n' | while read dir; do [ -d "$dir" ] && echo "$dir"; done
```

### Variables temporaires dans un sous-shell

```bash
# N'affecte pas le shell parent
(
    export TEMP_VAR="temporaire"
    ./mon_script.sh
)
# TEMP_VAR n'existe plus ici
```

### Exporter plusieurs variables d'un coup

```bash
# Avec export
export VAR1="val1" VAR2="val2" VAR3="val3"

# Ou sur plusieurs lignes (plus lisible)
export VAR1="val1" \
       VAR2="val2" \
       VAR3="val3"
```

### Debugger l'environnement

```bash
# Voir toutes les variables contenant un mot
env | grep -i python

# Comparer deux environnements
env > env1.txt
# ... modifications ...
env > env2.txt
diff env1.txt env2.txt

# Lancer un shell avec environnement minimal
env -i bash --noprofile --norc
```

### Utiliser `direnv` pour variables par projet

```bash
# Installation : apt install direnv
# Dans le répertoire du projet : créer .envrc
echo 'export PROJECT_ROOT=$(pwd)' > .envrc
echo 'export DATABASE_URL=postgres://localhost/mydb' >> .envrc
direnv allow

# Les variables sont chargées automatiquement en entrant dans le dossier
```

---

> [!success] Résumé Les variables d'environnement sont essentielles pour configurer votre système et vos applications. Retenez que :
> 
> - Les variables **locales** restent dans le shell courant
> - Les variables **exportées** sont transmises aux processus enfants
> - `.bashrc` est pour la configuration interactive quotidienne
> - `.bash_profile` est pour les variables globales de connexion
> - Utilisez toujours `export` pour les variables que vos scripts doivent voir