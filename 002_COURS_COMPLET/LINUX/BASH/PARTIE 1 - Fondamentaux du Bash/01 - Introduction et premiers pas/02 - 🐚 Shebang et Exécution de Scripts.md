

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

L'exécution de scripts Bash nécessite de comprendre deux éléments fondamentaux : **le shebang** qui indique au système quel interpréteur utiliser, et les **méthodes d'exécution** qui déterminent comment le script sera lancé. Cette section couvre ces concepts essentiels pour écrire et exécuter correctement vos scripts.

---

## 🔍 Le Shebang : Définition et Rôle

### Qu'est-ce qu'un Shebang ?

Le **shebang** (aussi appelé _hashbang_ ou _sha-bang_) est une séquence de caractères spéciale placée en première ligne d'un script. Elle commence toujours par `#!` suivi du chemin vers l'interpréteur à utiliser.

> [!info] Origine du terme Le nom "shebang" vient de la contraction de "sharp" (#) et "bang" (!), les noms anglais de ces deux caractères.

### Pourquoi le Shebang est-il Important ?

Le shebang remplit plusieurs rôles cruciaux :

1. **Indique l'interpréteur** : Il dit au système d'exploitation quel programme utiliser pour exécuter le script
2. **Permet l'exécution directe** : Sans shebang, vous devez explicitement appeler l'interpréteur (`bash script.sh`)
3. **Garantit la portabilité** : Il assure que le bon interpréteur est utilisé, même si plusieurs versions sont installées
4. **Active les permissions d'exécution** : Combiné avec `chmod +x`, il transforme un fichier texte en exécutable

> [!example] Fonctionnement du système Quand vous exécutez `./script.sh`, le système :
> 
> 1. Lit la première ligne du fichier
> 2. Détecte le shebang `#!`
> 3. Lance l'interpréteur spécifié
> 4. Passe le reste du fichier à cet interpréteur

---

## 📝 Syntaxe du Shebang

### Structure de Base

```bash
#!/bin/bash
```

**Décomposition** :

- `#!` : Séquence magique reconnue par le noyau Linux/Unix
- `/bin/bash` : Chemin absolu vers l'interpréteur Bash

> [!warning] Règles Strictes
> 
> - Le shebang **DOIT** être la toute première ligne du fichier
> - Il **NE DOIT PAS** y avoir d'espace avant `#!`
> - Il **NE DOIT PAS** y avoir d'espace entre `#` et `!`
> - Le chemin doit être absolu, pas relatif

### Variations Courantes

```bash
#!/bin/bash
# Version standard, chemin fixe

#!/usr/bin/env bash
# Version portable, recherche bash dans le PATH

#!/bin/bash -e
# Avec option : arrête le script à la première erreur

#!/bin/bash -x
# Avec option : affiche chaque commande avant exécution
```

### Options du Shebang

Vous pouvez ajouter des options directement dans le shebang :

```bash
#!/bin/bash -eu

# -e : exit immédiatement en cas d'erreur
# -u : traite les variables non définies comme une erreur
```

|Option|Description|Usage|
|---|---|---|
|`-e`|Arrête à la première erreur|Scripts critiques|
|`-u`|Erreur si variable non définie|Débogage|
|`-x`|Mode trace (affiche les commandes)|Débogage|
|`-v`|Mode verbose (affiche les lignes)|Débogage avancé|

> [!tip] Combinaison d'options Vous pouvez combiner plusieurs options : `#!/bin/bash -eux`

---

## 🔀 Chemin du Shebang : /bin/bash vs /usr/bin/env bash

### Comparaison des Deux Approches

#### Méthode 1 : Chemin Absolu `/bin/bash`

```bash
#!/bin/bash
```

**Avantages** :

- Simple et direct
- Fonctionne sur la plupart des systèmes Linux/Unix standards
- Performance légèrement meilleure (pas de recherche dans PATH)

**Inconvénients** :

- Pas portable si Bash est installé ailleurs
- Problématique sur certains BSD ou systèmes personnalisés
- Impossible d'utiliser une version spécifique de Bash

#### Méthode 2 : Avec `env` `/usr/bin/env bash`

```bash
#!/usr/bin/env bash
```

**Avantages** :

- **Portable** : recherche `bash` dans la variable `PATH`
- Flexible : utilise la première version de Bash trouvée dans PATH
- Recommandé pour les scripts distribués
- Fonctionne avec les environnements virtuels ou personnalisés

**Inconvénients** :

- Légèrement plus lent (recherche dans PATH)
- Dépend de la configuration PATH de l'utilisateur
- Peut poser des problèmes de sécurité si PATH est compromis

### Tableau de Comparaison

|Critère|`/bin/bash`|`/usr/bin/env bash`|
|---|---|---|
|**Portabilité**|⭐⭐|⭐⭐⭐⭐⭐|
|**Performance**|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|
|**Sécurité**|⭐⭐⭐⭐⭐|⭐⭐⭐|
|**Flexibilité**|⭐⭐|⭐⭐⭐⭐⭐|
|**Usage recommandé**|Scripts système|Scripts utilisateur|

> [!tip] Quelle Méthode Choisir ?
> 
> - **Scripts système/admin** : Utilisez `/bin/bash` (prévisible et sécurisé)
> - **Scripts personnels/distribués** : Utilisez `/usr/bin/env bash` (portable)
> - **Scripts critiques** : Utilisez `/bin/bash` (évite les manipulations PATH)

### Localisation de Bash sur Votre Système

Pour savoir où se trouve Bash sur votre système :

```bash
# Trouver tous les emplacements de bash
which bash
# Sortie typique : /bin/bash

# Voir toutes les versions disponibles
which -a bash
# Peut montrer : /bin/bash, /usr/local/bin/bash, etc.

# Vérifier avec whereis
whereis bash
# Sortie : bash: /bin/bash /usr/share/man/man1/bash.1.gz
```

---

## 🚀 Création du Premier Script

### Étape par Étape

#### 1. Créer le Fichier

```bash
# Créer un nouveau fichier
touch mon_script.sh

# Ou directement avec un éditeur
nano mon_script.sh
# ou
vim mon_script.sh
```

> [!tip] Convention de Nommage
> 
> - Utilisez l'extension `.sh` pour identifier facilement les scripts Bash
> - Noms en minuscules avec underscores : `mon_script.sh`
> - Noms descriptifs : `backup_database.sh` plutôt que `script1.sh`

#### 2. Écrire le Script

```bash
#!/bin/bash

# Ceci est un commentaire
# Mon premier script Bash

echo "Bonjour, monde !"
echo "Script lancé par : $USER"
echo "Répertoire actuel : $(pwd)"
```

**Explication ligne par ligne** :

- `#!/bin/bash` : Shebang, indique l'interpréteur
- `# Commentaire` : Les lignes commençant par `#` (sauf shebang) sont des commentaires
- `echo` : Commande pour afficher du texte
- `$USER` : Variable contenant le nom de l'utilisateur
- `$(pwd)` : Substitution de commande, exécute `pwd` et insère le résultat

#### 3. Sauvegarder

Dans nano : `Ctrl+O` puis `Entrée` puis `Ctrl+X` Dans vim : `Esc` puis `:wq` puis `Entrée`

> [!example] Script Plus Complet
> 
> ```bash
> #!/bin/bash
> 
> # Script : hello.sh
> # Description : Affiche des informations de bienvenue
> # Auteur : Votre Nom
> # Date : 2024-12-16
> 
> echo "================================"
> echo "  Bienvenue sur ce système"
> echo "================================"
> echo ""
> echo "Utilisateur : $USER"
> echo "Hostname    : $(hostname)"
> echo "Date        : $(date '+%Y-%m-%d %H:%M:%S')"
> echo "Répertoire  : $(pwd)"
> echo ""
> echo "Script terminé avec succès !"
> ```

---

## ⚙️ Méthodes d'Exécution de Scripts

### Méthode 1 : Exécution avec `bash script.sh`

```bash
bash mon_script.sh
```

**Caractéristiques** :

- **Pas besoin de permissions d'exécution**
- **Pas besoin de shebang** (mais recommandé)
- Le script est exécuté dans un sous-shell
- L'interpréteur est explicitement spécifié

**Quand l'utiliser** :

- Tests rapides pendant le développement
- Scripts sans permissions d'exécution
- Forcer l'utilisation d'un interpréteur spécifique

```bash
# Exemples d'utilisation
bash mon_script.sh                    # Exécution normale
bash -x mon_script.sh                 # Avec mode debug
bash -n mon_script.sh                 # Vérification syntaxe uniquement
/bin/bash mon_script.sh               # Avec chemin absolu vers bash
```

> [!info] Variantes Vous pouvez également utiliser :
> 
> - `sh mon_script.sh` : utilise le shell par défaut (souvent lié à bash)
> - `/bin/bash mon_script.sh` : chemin absolu vers bash

### Méthode 2 : Exécution Directe `./script.sh`

```bash
./mon_script.sh
```

**Prérequis** :

1. Le fichier doit avoir les **permissions d'exécution**
2. Le script doit contenir un **shebang valide**

**Étapes complètes** :

#### Étape 1 : Vérifier les Permissions

```bash
ls -l mon_script.sh
# Sortie : -rw-r--r-- 1 user group 125 Dec 16 10:00 mon_script.sh
#          ^^^ Pas de 'x', donc pas exécutable
```

#### Étape 2 : Ajouter les Permissions d'Exécution

```bash
# Ajouter la permission d'exécution pour l'utilisateur
chmod +x mon_script.sh

# Ou avec permissions explicites
chmod 755 mon_script.sh  # rwxr-xr-x
chmod 744 mon_script.sh  # rwxr--r--
chmod 700 mon_script.sh  # rwx------ (uniquement pour vous)
```

**Tableau des Permissions** :

|Code|Signification|Utilisateur|Groupe|Autres|
|---|---|---|---|---|
|755|`rwxr-xr-x`|Lecture, écriture, exécution|Lecture, exécution|Lecture, exécution|
|750|`rwxr-x---`|Lecture, écriture, exécution|Lecture, exécution|Aucune|
|700|`rwx------`|Lecture, écriture, exécution|Aucune|Aucune|

> [!tip] Quelle Permission Choisir ?
> 
> - **755** : Scripts partagés que d'autres peuvent utiliser
> - **750** : Scripts d'équipe (groupe peut exécuter)
> - **700** : Scripts personnels/sensibles

#### Étape 3 : Vérifier les Nouvelles Permissions

```bash
ls -l mon_script.sh
# Sortie : -rwxr-xr-x 1 user group 125 Dec 16 10:00 mon_script.sh
#          ^^^ Maintenant avec 'x', donc exécutable
```

#### Étape 4 : Exécuter le Script

```bash
# Depuis le répertoire courant
./mon_script.sh

# Avec chemin absolu
/home/user/scripts/mon_script.sh

# Avec chemin relatif
../scripts/mon_script.sh
```

> [!warning] Le `./` est Obligatoire !
> 
> ```bash
> # ❌ INCORRECT - Ne fonctionnera pas
> mon_script.sh
> 
> # ✅ CORRECT - Avec ./
> ./mon_script.sh
> 
> # ✅ CORRECT - Avec chemin absolu
> /chemin/complet/mon_script.sh
> ```
> 
> Le `./` indique au shell de chercher le script dans le répertoire courant. Sans cela, le shell ne cherche que dans les répertoires listés dans la variable `PATH`.

### Méthode 3 : Exécution depuis PATH

Si vous voulez exécuter votre script comme une commande (sans `./`) :

```bash
# Option 1 : Déplacer le script dans un répertoire du PATH
sudo mv mon_script.sh /usr/local/bin/mon_script
sudo chmod +x /usr/local/bin/mon_script

# Maintenant vous pouvez l'exécuter de n'importe où
mon_script

# Option 2 : Ajouter le répertoire du script au PATH
export PATH="$PATH:$HOME/mes_scripts"
# Ajouter cette ligne dans ~/.bashrc pour la rendre permanente
```

### Méthode 4 : Sourcing avec `source` ou `.`

```bash
source mon_script.sh
# ou
. mon_script.sh
```

> [!warning] Différence Importante Cette méthode exécute le script **dans le shell courant**, pas dans un sous-shell. Les variables et modifications d'environnement persistent après l'exécution. Cette méthode sera détaillée dans une partie ultérieure sur les environnements et sous-shells.

### Comparaison des Méthodes

|Méthode|Permissions Requises|Shebang Requis|Sous-shell|Usage Typique|
|---|---|---|---|---|
|`bash script.sh`|❌ Non|❌ Non|✅ Oui|Tests, développement|
|`./script.sh`|✅ Oui|✅ Oui|✅ Oui|Production, scripts finalisés|
|`script` (dans PATH)|✅ Oui|✅ Oui|✅ Oui|Commandes utilisateur|
|`source script.sh`|❌ Non|❌ Non|❌ Non|Modification environnement|

---

## ⚠️ Pièges Courants et Bonnes Pratiques

### Pièges Courants

#### 1. Shebang Incorrect

```bash
# ❌ INCORRECT - Espace avant #!
 #!/bin/bash

# ❌ INCORRECT - Pas en première ligne

#!/bin/bash

# ❌ INCORRECT - Espace entre # et !
# !/bin/bash

# ❌ INCORRECT - Chemin relatif
#!bin/bash

# ✅ CORRECT
#!/bin/bash
```

#### 2. Oublier les Permissions

```bash
# Erreur typique
$ ./mon_script.sh
bash: ./mon_script.sh: Permission denied

# Solution
$ chmod +x mon_script.sh
$ ./mon_script.sh
```

#### 3. Oublier le `./`

```bash
# ❌ INCORRECT
$ mon_script.sh
bash: mon_script.sh: command not found

# ✅ CORRECT
$ ./mon_script.sh
```

#### 4. Fins de Ligne Windows (CRLF)

Si vous créez un script sous Windows et le transférez sur Linux :

```bash
# Symptôme : erreur cryptique
$ ./mon_script.sh
bash: ./mon_script.sh: /bin/bash^M: bad interpreter

# Diagnostic : vérifier les fins de ligne
file mon_script.sh
# Sortie : mon_script.sh: Bourne-Again shell script, ASCII text executable, with CRLF line terminators

# Solution : convertir avec dos2unix
dos2unix mon_script.sh

# Ou avec sed
sed -i 's/\r$//' mon_script.sh
```

> [!warning] Éditeurs et Encodage Assurez-vous que votre éditeur :
> 
> - Utilise les fins de ligne Unix (LF) et non Windows (CRLF)
> - Sauvegarde en UTF-8 sans BOM
> - Ne rajoute pas d'espaces ou de caractères invisibles

#### 5. Chemin Bash Incorrect

```bash
# Vérifier où est bash sur votre système
which bash

# Si bash est ailleurs, ajuster le shebang
#!/usr/local/bin/bash  # pour certains systèmes BSD
```

### Bonnes Pratiques

#### 1. En-tête de Script Complet

```bash
#!/bin/bash

################################################################################
# Script : backup_db.sh
# Description : Effectue une sauvegarde de la base de données
# Auteur : Votre Nom
# Date de création : 2024-12-16
# Dernière modification : 2024-12-16
# Version : 1.0
#
# Usage : ./backup_db.sh [options]
# Options :
#   -h, --help     Affiche ce message d'aide
#   -v, --verbose  Mode verbeux
#
# Dépendances : mysql, gzip
################################################################################

# Le script commence ici...
```

#### 2. Vérifications Préliminaires

```bash
#!/bin/bash

# Vérifier que le script n'est pas exécuté en tant que root
if [[ $EUID -eq 0 ]]; then
   echo "Ce script ne doit pas être exécuté en tant que root" 
   exit 1
fi

# Vérifier la présence de commandes nécessaires
command -v git >/dev/null 2>&1 || { echo "Git n'est pas installé. Abandon."; exit 1; }
```

#### 3. Mode Strict

```bash
#!/bin/bash

# Mode strict : arrête le script dès qu'une erreur survient
set -euo pipefail

# -e : exit si une commande échoue
# -u : traite les variables non définies comme erreur
# -o pipefail : un échec dans un pipe fait échouer tout le pipe
```

> [!tip] Mode Strict Expliqué
> 
> ```bash
> # Sans -e
> commande_inexistante  # Continue malgré l'erreur
> echo "Suite du script"  # S'exécute quand même
> 
> # Avec -e
> commande_inexistante  # Arrête immédiatement
> echo "Ne s'exécutera jamais"
> ```

#### 4. Vérifier la Syntaxe Sans Exécuter

```bash
# Vérifier la syntaxe d'un script
bash -n mon_script.sh

# Aucune sortie = syntaxe correcte
# Sinon, affiche les erreurs de syntaxe
```

#### 5. Déboguer un Script

```bash
# Exécution en mode debug (affiche chaque commande)
bash -x mon_script.sh

# Ou ajouter dans le script
#!/bin/bash -x

# Ou activer/désactiver à la volée
set -x  # Activer le mode debug
# commandes à déboguer
set +x  # Désactiver le mode debug
```

#### 6. Nommer les Scripts de Façon Explicite

```bash
# ❌ Noms peu clairs
script1.sh
test.sh
s.sh

# ✅ Noms descriptifs
backup_database.sh
deploy_production.sh
check_disk_space.sh
```

#### 7. Utiliser des Chemins Absolus pour les Fichiers Critiques

```bash
#!/bin/bash

# ❌ Chemin relatif (dépend du répertoire d'exécution)
source config.sh

# ✅ Chemin absolu ou relatif au script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
```

---

## 🎯 Astuces

### Créer un Template de Script

Créez un fichier `template.sh` que vous copiez pour chaque nouveau script :

```bash
#!/bin/bash
set -euo pipefail

################################################################################
# Script : 
# Description : 
# Auteur : 
# Date : $(date +%Y-%m-%d)
# Version : 1.0
################################################################################

# Variables globales


# Fonctions


# Script principal
main() {
    echo "Début du script"
    
    # Votre code ici
    
    echo "Fin du script"
}

# Point d'entrée
main "$@"
```

### Alias pour Création Rapide

Ajoutez dans votre `~/.bashrc` :

```bash
# Créer rapidement un nouveau script
newscript() {
    local filename="$1"
    cat > "$filename" << 'EOF'
#!/bin/bash
set -euo pipefail

# Description du script

echo "Script lancé"
EOF
    chmod +x "$filename"
    echo "Script '$filename' créé et rendu exécutable"
}

# Usage : newscript mon_nouveau_script.sh
```

### Exécution Sécurisée depuis un Répertoire Temporaire

```bash
# Créer et exécuter dans un répertoire temporaire
tmpdir=$(mktemp -d)
cd "$tmpdir" || exit 1
# ... commandes ...
cd - > /dev/null
rm -rf "$tmpdir"
```

---

**🎓 Vous maîtrisez maintenant le shebang et l'exécution de scripts Bash !**