

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

## 🎯 Niveaux de configuration

Git utilise un système de configuration hiérarchique à trois niveaux. Chaque niveau peut surcharger les paramètres du niveau précédent.

### Les trois niveaux

|Niveau|Scope|Fichier|Priorité|
|---|---|---|---|
|**System**|Tous les utilisateurs|`/etc/gitconfig`|3 (plus faible)|
|**Global**|Utilisateur courant|`~/.gitconfig` ou `~/.config/git/config`|2|
|**Local**|Dépôt spécifique|`.git/config`|1 (plus forte)|

> [!info] Hiérarchie des configurations Lorsqu'un paramètre est défini à plusieurs niveaux, Git utilise la valeur du niveau le plus spécifique (local > global > system).

### Syntaxe des commandes de configuration

```bash
# Configuration system (nécessite souvent sudo)
git config --system <clé> <valeur>

# Configuration global (utilisateur)
git config --global <clé> <valeur>

# Configuration local (dépôt actuel)
git config --local <clé> <valeur>
# ou simplement (local par défaut)
git config <clé> <valeur>
```

> [!tip] Bonne pratique Utilisez `--global` pour votre identité et préférences générales, et `--local` pour des configurations spécifiques à un projet (ex: email professionnel vs personnel).

---

## 👤 Configuration de base

### Identité obligatoire

Ces configurations sont **indispensables** pour effectuer des commits.

```bash
# Nom d'utilisateur
git config --global user.name "Votre Nom"

# Email
git config --global user.email "votre.email@example.com"
```

> [!warning] Email et historique L'email est intégré dans chaque commit. Si vous modifiez votre email, les anciens commits conserveront l'ancien email. Choisissez judicieusement !

### Éditeur par défaut

```bash
# Définir l'éditeur pour les messages de commit
git config --global core.editor "code --wait"  # VS Code
git config --global core.editor "vim"           # Vim
git config --global core.editor "nano"          # Nano
git config --global core.editor "subl -w"       # Sublime Text
```

> [!example] Éditeur avec option d'attente L'option `--wait` (VS Code) ou `-w` (Sublime) force Git à attendre que vous fermiez l'éditeur avant de continuer.

### Configuration de fin de ligne

```bash
# Linux/Mac
git config --global core.autocrlf input

# Windows
git config --global core.autocrlf true

# Désactiver complètement (attention aux problèmes)
git config --global core.autocrlf false
```

> [!info] Pourquoi c'est important ?
> 
> - **Windows** utilise CRLF (`\r\n`)
> - **Linux/Mac** utilisent LF (`\n`)
> - `autocrlf` gère automatiquement la conversion pour éviter les conflits

---

## ⚡ Alias Git

Les alias permettent de créer des raccourcis pour des commandes longues ou complexes.

### Syntaxe de base

```bash
# Créer un alias
git config --global alias.<nom-alias> '<commande-git>'

# Exemple simple
git config --global alias.st 'status'
# Utilisation: git st
```

### Alias courants et utiles

```bash
# Alias de base
git config --global alias.co 'checkout'
git config --global alias.br 'branch'
git config --global alias.ci 'commit'
git config --global alias.st 'status'

# Status court et coloré
git config --global alias.s 'status -s'

# Voir les branches avec leur dernier commit
git config --global alias.branches 'branch -vv'

# Log personnalisé en une ligne
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Log compact
git config --global alias.l 'log --oneline'

# Voir les fichiers modifiés dans le dernier commit
git config --global alias.dlc 'diff --cached HEAD^'

# Annuler le dernier commit (garde les modifications)
git config --global alias.undo 'reset --soft HEAD^'

# Voir les contributions par auteur
git config --global alias.who 'shortlog -sn --'

# Afficher le dernier commit
git config --global alias.last 'log -1 HEAD --stat'

# Liste des alias configurés
git config --global alias.aliases "config --get-regexp '^alias\.'"
```

> [!tip] Alias avec paramètres Vous pouvez passer des paramètres à vos alias. Par exemple : `git l -10` affichera les 10 derniers commits si vous avez défini `alias.l 'log --oneline'`.

### Alias avancés avec commandes shell

Pour des alias plus complexes, utilisez le préfixe `!` pour exécuter des commandes shell.

```bash
# Créer un commit avec un message formaté
git config --global alias.cm '!f() { git commit -m "$@"; }; f'

# Rechercher dans le code
git config --global alias.grep 'grep -Ii'

# Compter le nombre de commits
git config --global alias.count '!git log --oneline | wc -l'

# Afficher la taille du dépôt
git config --global alias.size '!git count-objects -vH'
```

> [!example] Utilisation d'alias avec shell
> 
> ```bash
> git cm "Fix: correction du bug #123"
> # Équivaut à: git commit -m "Fix: correction du bug #123"
> ```

---

## 🎨 Configurations utiles

### Interface et affichage

```bash
# Activer la couleur dans toutes les commandes
git config --global color.ui auto

# Couleurs spécifiques
git config --global color.status auto
git config --global color.branch auto
git config --global color.diff auto

# Pagination (désactiver pour éviter less)
git config --global core.pager 'less -R'
# ou désactiver complètement
git config --global core.pager cat
```

### Comportement des commandes

```bash
# Push uniquement la branche courante (recommandé)
git config --global push.default simple

# Ou push toutes les branches correspondantes
git config --global push.default matching

# Activer le suivi automatique des branches
git config --global push.autoSetupRemote true

# Pull avec rebase par défaut (plus propre)
git config --global pull.rebase true

# Merge avec fast-forward seulement si possible
git config --global merge.ff only
```

> [!info] Push default
> 
> - **simple** : pousse uniquement la branche actuelle vers son upstream
> - **matching** : pousse toutes les branches ayant le même nom localement et sur le remote

### Performance et cache

```bash
# Cache des credentials (évite de retaper le mot de passe)
# Linux/Mac - en mémoire pour 15 minutes
git config --global credential.helper 'cache --timeout=900'

# Mac - utilise le Keychain
git config --global credential.helper osxkeychain

# Windows - utilise Windows Credential Manager
git config --global credential.helper wincred

# Optimiser la détection des renommages
git config --global diff.renames true
git config --global diff.renameLimit 5000

# Augmenter le cache delta (améliore les performances)
git config --global core.deltaBaseCacheLimit 2g
```

### Sécurité et bonnes pratiques

```bash
# Empêcher les commits vides
git config --global commit.gpgsign false

# Activer la signature GPG des commits (sécurité)
git config --global commit.gpgsign true
git config --global user.signingkey <votre-clé-GPG>

# Refuser les push en force (protection)
git config --global receive.denyNonFastForwards true

# Vérifier les whitespaces
git config --global core.whitespace trailing-space,space-before-tab
```

> [!warning] Signatures GPG La signature GPG nécessite une configuration supplémentaire (création de clé, etc.). Ne l'activez que si vous savez comment l'utiliser.

### Gestion des fichiers volumineux

```bash
# Compression des objets
git config --global core.compression 9

# Augmenter la limite pour les gros fichiers
git config --global http.postBuffer 524288000  # 500 MB

# Timeout plus long pour les connexions lentes
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 600
```

---

## 📋 Commandes de gestion

### Lister les configurations

```bash
# Toutes les configurations (tous niveaux)
git config --list

# Avec l'origine de chaque paramètre
git config --list --show-origin

# Configurations globales uniquement
git config --global --list

# Configurations locales uniquement
git config --local --list
```

> [!tip] Filtrer les résultats
> 
> ```bash
> # Voir uniquement les alias
> git config --list | grep alias
> 
> # Voir uniquement la configuration utilisateur
> git config --list | grep user
> ```

### Lire une configuration spécifique

```bash
# Lire une valeur
git config user.name
git config --global user.email

# Avec le scope explicite
git config --global --get user.name
git config --local --get core.editor
```

### Modifier et supprimer

```bash
# Modifier une valeur existante
git config --global user.name "Nouveau Nom"

# Supprimer une configuration
git config --global --unset user.email

# Supprimer une section entière
git config --global --remove-section alias

# Supprimer toutes les occurrences d'une clé
git config --global --unset-all remote.origin.fetch
```

> [!warning] Suppression de section `--remove-section` supprime tous les paramètres de cette section. Utilisez avec précaution !

### Éditer directement le fichier

```bash
# Ouvrir le fichier de config global dans l'éditeur
git config --global --edit

# Ouvrir le fichier de config local
git config --local --edit

# Ouvrir le fichier de config system
git config --system --edit
```

> [!example] Structure du fichier .gitconfig
> 
> ```ini
> [user]
>     name = Votre Nom
>     email = email@example.com
> [core]
>     editor = code --wait
>     autocrlf = input
> [alias]
>     st = status
>     co = checkout
>     lg = log --graph --oneline
> [color]
>     ui = auto
> [push]
>     default = simple
> ```

### Vérifier et déboguer

```bash
# Voir quelle configuration est utilisée
git config --list --show-scope

# Voir d'où vient une configuration spécifique
git config --show-origin user.name

# Tester une configuration
git config --get-all core.autocrlf
```

---

## 🎓 Pièges courants

> [!warning] Configuration locale vs globale Si vous configurez votre email localement dans un projet, les commits de ce projet utiliseront cet email, même si vous avez un email global différent. Vérifiez toujours : `git config user.email`

> [!warning] Cache de credentials Le cache de credentials stocke vos mots de passe. Sur une machine partagée, utilisez un timeout court ou désactivez-le.

> [!warning] Alias récursifs Évitez de créer des alias qui appellent d'autres alias de manière circulaire. Cela peut créer des boucles infinies.

> [!warning] Push default L'ancienne valeur par défaut (`matching`) pouvait pousser toutes vos branches. Utilisez `simple` pour plus de contrôle.

---

## 💡 Astuces

**🚀 Configuration rapide initiale**

Créez un script pour configurer Git sur une nouvelle machine :

```bash
#!/bin/bash
git config --global user.name "Votre Nom"
git config --global user.email "email@example.com"
git config --global core.editor "code --wait"
git config --global core.autocrlf input
git config --global push.default simple
git config --global pull.rebase true
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.lg "log --graph --oneline --all"
```

**🔍 Trouver rapidement une configuration**

```bash
# Chercher dans toutes les configs
git config --list | grep -i "terme"

# Exemple: trouver tous les alias
git config --list | grep alias
```

**📝 Sauvegarder sa configuration**

```bash
# Copier votre .gitconfig pour le réutiliser ailleurs
cp ~/.gitconfig ~/gitconfig.backup
```

**⚙️ Configuration par projet**

Pour des projets avec des besoins spécifiques (email différent, règles de merge, etc.), utilisez toujours `--local` :

```bash
cd mon-projet-pro
git config --local user.email "email.pro@entreprise.com"
```

**🎯 Désactiver temporairement une configuration**

Plutôt que de supprimer, commentez dans le fichier :

```bash
git config --global --edit
# Puis ajoutez # devant la ligne concernée
```