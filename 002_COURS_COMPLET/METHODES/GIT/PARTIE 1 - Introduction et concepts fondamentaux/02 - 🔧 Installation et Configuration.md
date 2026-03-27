

> [!info] À propos de cette partie Cette section couvre l'installation de Git sur différents systèmes d'exploitation et sa configuration initiale pour une utilisation optimale.

---

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

## 🖥️ Installation de Git

### Windows

#### Méthode recommandée : Git for Windows

**Téléchargement :**

- Site officiel : https://git-scm.com/download/win
- Le programme d'installation inclut Git Bash, Git GUI et l'intégration au menu contextuel

**Options d'installation importantes :**

> [!warning] Attention lors de l'installation Certaines options de l'installateur Windows peuvent modifier votre environnement système. Lisez attentivement chaque écran.

**Choix recommandés pendant l'installation :**

1. **Éditeur par défaut** : Choisissez votre éditeur préféré (Vim, VS Code, Notepad++, etc.)
2. **Ajustement de la variable PATH** : "Git from the command line and also from 3rd-party software"
3. **Backend SSH** : "Use bundled OpenSSH"
4. **Backend HTTPS** : "Use the OpenSSL library"
5. **Fin de ligne** : "Checkout Windows-style, commit Unix-style line endings"
6. **Émulateur de terminal** : "Use MinTTY"
7. **Comportement de git pull** : "Default (fast-forward or merge)"

#### Installation via package manager (alternatif)

```bash
# Via Chocolatey
choco install git

# Via Scoop
scoop install git

# Via Winget
winget install --id Git.Git -e --source winget
```

> [!tip] Astuce Windows Git Bash fournit un environnement Unix-like sur Windows, très utile pour suivre des tutoriels écrits pour Linux/macOS.

---

### Linux

L'installation varie selon votre distribution Linux.

#### Debian/Ubuntu et dérivés

```bash
# Mise à jour des paquets
sudo apt update

# Installation de Git
sudo apt install git

# Installation de la documentation (optionnel)
sudo apt install git-doc
```

#### Fedora/RHEL/CentOS

```bash
# Fedora 22 et supérieur
sudo dnf install git

# Versions plus anciennes
sudo yum install git
```

#### Arch Linux et dérivés

```bash
# Installation via pacman
sudo pacman -S git
```

#### openSUSE

```bash
# Installation via zypper
sudo zypper install git
```

> [!info] Version de Git Les dépôts officiels des distributions peuvent contenir des versions légèrement anciennes de Git. Pour la dernière version, consultez les instructions sur git-scm.com.

#### Installation depuis les sources (avancé)

```bash
# Installer les dépendances (Debian/Ubuntu)
sudo apt install dh-autoreconf libcurl4-gnutls-dev libexpat1-dev \
  gettext libz-dev libssl-dev

# Télécharger et compiler
wget https://github.com/git/git/archive/v2.x.x.tar.gz
tar -zxf v2.x.x.tar.gz
cd git-2.x.x
make prefix=/usr/local all
sudo make prefix=/usr/local install
```

---

### macOS

#### Méthode 1 : Xcode Command Line Tools (intégré)

```bash
# Lancez simplement git dans le terminal
git --version

# Si Git n'est pas installé, macOS proposera de l'installer
```

> [!warning] Version limitée La version fournie avec Xcode peut être en retard par rapport à la dernière version de Git.

#### Méthode 2 : Homebrew (recommandé)

```bash
# Installer Homebrew si nécessaire (voir https://brew.sh)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Installer Git
brew install git

# Mettre à jour Git
brew upgrade git
```

#### Méthode 3 : Installateur officiel

- Téléchargez l'installateur depuis https://git-scm.com/download/mac
- Ouvrez le fichier .dmg et suivez les instructions

#### Méthode 4 : MacPorts

```bash
sudo port install git
```

> [!tip] Gestion de plusieurs installations Si plusieurs versions de Git coexistent, vérifiez quelle version est utilisée avec `which git` et ajustez votre PATH si nécessaire.

---

## ⚙️ Configuration initiale

Après l'installation, vous devez configurer votre identité Git. Ces informations seront incluses dans chaque commit que vous créerez.

### Configuration obligatoire : identité

```bash
# Configurer votre nom
git config --global user.name "Votre Nom"

# Configurer votre email
git config --global user.email "votre.email@example.com"
```

> [!warning] Importance de l'email L'adresse email doit correspondre à celle utilisée sur GitHub/GitLab si vous prévoyez de contribuer à des projets en ligne. GitHub associe vos commits à votre compte via cette adresse.

> [!example] Exemple concret
> 
> ```bash
> git config --global user.name "Marie Dupont"
> git config --global user.email "marie.dupont@email.com"
> ```

### Pourquoi ces informations sont importantes ?

- **Traçabilité** : Chaque commit enregistre l'auteur et permet de savoir qui a fait quoi
- **Collaboration** : Vos coéquipiers peuvent vous identifier et vous contacter
- **Historique** : L'historique Git conserve ces informations de manière permanente
- **Intégration** : Les plateformes comme GitHub utilisent l'email pour lier vos commits à votre profil

### Configuration optionnelle mais recommandée

```bash
# Définir la branche par défaut (moderne : main au lieu de master)
git config --global init.defaultBranch main

# Coloration automatique de la sortie Git
git config --global color.ui auto

# Mise en cache des identifiants (évite de retaper le mot de passe)
# Linux/macOS
git config --global credential.helper cache

# Windows
git config --global credential.helper manager

# Définir le timeout du cache (en secondes, ici 1 heure)
git config --global credential.helper 'cache --timeout=3600'
```

> [!tip] Configuration de credential helper Sur Windows, `manager` ouvre le Gestionnaire d'identification Windows qui stocke vos identifiants de manière sécurisée. Sur macOS, utilisez `osxkeychain`.

---

## 📝 Configuration de l'éditeur

Git utilise un éditeur de texte pour les messages de commit, les résolutions de conflits, et d'autres opérations interactives.

### Pourquoi configurer un éditeur ?

- **Messages de commit détaillés** : Lorsque vous faites `git commit` sans `-m`, Git ouvre l'éditeur
- **Rebase interactif** : Pour réorganiser, modifier ou fusionner des commits
- **Résolution de conflits** : Certains outils de merge utilisent l'éditeur configuré
- **Édition de configuration** : La commande `git config --global --edit` ouvre l'éditeur

### Configuration selon votre éditeur préféré

#### Visual Studio Code

```bash
git config --global core.editor "code --wait"
```

> [!info] L'option --wait L'option `--wait` indique à Git d'attendre que vous fermiez le fichier avant de continuer. C'est essentiel pour que Git sache quand vous avez terminé votre édition.

#### Vim (éditeur par défaut sur Unix)

```bash
git config --global core.editor vim
```

#### Nano (plus simple pour les débutants)

```bash
git config --global core.editor nano
```

#### Emacs

```bash
git config --global core.editor emacs
```

#### Sublime Text

```bash
# macOS
git config --global core.editor "subl -n -w"

# Windows
git config --global core.editor "'c:/program files/sublime text 3/sublime_text.exe' -w"

# Linux
git config --global core.editor "subl -n -w"
```

#### Notepad++ (Windows)

```bash
git config --global core.editor "'C:/Program Files/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugin"
```

#### Atom

```bash
git config --global core.editor "atom --wait"
```

> [!warning] Chemins Windows Sur Windows, utilisez des slashes `/` ou échappez les backslashes `\\` dans les chemins. Les espaces nécessitent des guillemets.

### Tableau comparatif des éditeurs

|Éditeur|Courbe d'apprentissage|Vitesse|Fonctionnalités|Recommandé pour|
|---|---|---|---|---|
|Nano|Facile|Rapide|Basiques|Débutants|
|Vim|Difficile|Très rapide|Avancées|Utilisateurs expérimentés|
|VS Code|Moyenne|Moyenne|Très complètes|Développement moderne|
|Sublime Text|Facile|Rapide|Complètes|Édition rapide|
|Emacs|Difficile|Rapide|Très avancées|Power users|

---

## ✅ Vérification de l'installation

### Vérifier la version de Git

```bash
# Afficher la version installée
git --version

# Exemple de sortie
# git version 2.43.0
```

> [!tip] Version minimale Assurez-vous d'avoir au moins Git 2.23+ pour bénéficier des fonctionnalités modernes comme `git switch` et `git restore`.

### Vérifier la configuration

```bash
# Lister toutes les configurations
git config --list

# Afficher une configuration spécifique
git config user.name
git config user.email
git config core.editor

# Afficher la configuration avec l'origine (fichier source)
git config --list --show-origin
```

> [!example] Exemple de sortie
> 
> ```bash
> $ git config --list
> user.name=Marie Dupont
> user.email=marie.dupont@email.com
> core.editor=code --wait
> init.defaultbranch=main
> color.ui=auto
> ```

### Tester l'installation avec un dépôt de test

```bash
# Créer un répertoire de test
mkdir test-git
cd test-git

# Initialiser un dépôt Git
git init

# Vérifier le statut (doit fonctionner sans erreur)
git status

# Nettoyage
cd ..
rm -rf test-git
```

> [!info] Commande git init Cette commande crée un nouveau dépôt Git. Nous l'abordons en détail dans la section suivante du cours.

---

## 📊 Niveaux de configuration

Git utilise une hiérarchie de configuration à trois niveaux :

### 1. Configuration système (--system)

- **Emplacement** : `/etc/gitconfig` (Linux/macOS) ou `C:\Program Files\Git\etc\gitconfig` (Windows)
- **Portée** : Tous les utilisateurs du système et tous leurs dépôts
- **Accès** : Nécessite les droits administrateur

```bash
# Modifier la configuration système
sudo git config --system core.editor vim

# Lister la configuration système
git config --system --list
```

> [!warning] Rarement utilisé La configuration système est rarement modifiée. Elle sert principalement dans les environnements d'entreprise avec des politiques standardisées.

### 2. Configuration globale (--global)

- **Emplacement** : `~/.gitconfig` ou `~/.config/git/config` (Linux/macOS) ou `C:\Users\{username}\.gitconfig` (Windows)
- **Portée** : Utilisateur courant, tous les dépôts
- **Utilisation** : Configuration par défaut pour vos projets personnels

```bash
# Configuration la plus courante
git config --global user.name "Votre Nom"

# Lister la configuration globale
git config --global --list

# Éditer directement le fichier de configuration
git config --global --edit
```

> [!tip] Fichier éditable Vous pouvez éditer `~/.gitconfig` directement dans un éditeur de texte. C'est pratique pour des modifications en masse.

### 3. Configuration locale (--local ou par défaut)

- **Emplacement** : `.git/config` dans le répertoire du dépôt
- **Portée** : Dépôt courant uniquement
- **Utilisation** : Surcharger la configuration globale pour un projet spécifique

```bash
# Configuration spécifique au projet (doit être dans un dépôt Git)
git config --local user.email "email-professionnel@entreprise.com"

# Ou simplement (--local est implicite)
git config user.email "email-professionnel@entreprise.com"

# Lister la configuration locale
git config --local --list
```

> [!example] Cas d'usage : email différent par projet
> 
> ```bash
> # Email personnel pour les projets perso (global)
> git config --global user.email "perso@gmail.com"
> 
> # Email pro pour un projet pro spécifique (local)
> cd ~/projets/projet-entreprise
> git config --local user.email "prenom.nom@entreprise.fr"
> ```

### Priorité de configuration

Les niveaux se superposent selon cette priorité (du plus fort au plus faible) :

1. **Local** (`.git/config`) - priorité maximale
2. **Global** (`~/.gitconfig`) - priorité moyenne
3. **System** (`/etc/gitconfig`) - priorité minimale

> [!info] Fonctionnement de la priorité Si une même option est définie à plusieurs niveaux, c'est la valeur du niveau le plus spécifique (local > global > system) qui est utilisée.

---

## 🔍 Commandes de configuration avancées

### Afficher l'origine d'une configuration

```bash
# Voir d'où vient chaque configuration
git config --list --show-origin

# Exemple de sortie :
# file:/etc/gitconfig    credential.helper=osxkeychain
# file:/Users/marie/.gitconfig    user.name=Marie Dupont
# file:.git/config    user.email=marie@entreprise.com
```

### Supprimer une configuration

```bash
# Supprimer une option globale
git config --global --unset user.name

# Supprimer une option locale
git config --unset user.email

# Supprimer une section entière
git config --global --remove-section user
```

### Obtenir la valeur effective d'une option

```bash
# Quelle valeur est réellement utilisée ? (prend en compte la priorité)
git config --get user.email

# Obtenir toutes les valeurs d'une option (tous niveaux)
git config --get-all user.email
```

### Configurations utiles supplémentaires

```bash
# Aliaser des commandes longues
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'

# Configuration du diff
git config --global diff.tool vimdiff

# Configuration du merge
git config --global merge.tool vimdiff

# Ignorer les changements de permissions (utile sur Windows)
git config --global core.fileMode false

# Configuration du comportement de push
git config --global push.default simple

# Activer la réécriture d'URL (HTTPS vers SSH)
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

> [!tip] Alias pratiques Les alias vous font gagner beaucoup de temps. Au lieu de taper `git status`, tapez simplement `git st`.

### Voir la configuration complète formatée

```bash
# Afficher la config de manière lisible
git config --list --show-origin | grep -E "^file:|^command line:"

# Ou directement dans un éditeur
git config --global --edit
```

---

## 🎯 Pièges courants et bonnes pratiques

### Pièges à éviter

> [!warning] Erreurs fréquentes
> 
> 1. **Email incorrect** : Utiliser un email qui ne correspond pas à votre compte GitHub/GitLab empêche l'association correcte de vos commits
> 2. **Oublier --global** : Sans `--global`, la configuration s'applique uniquement au dépôt courant (s'il existe)
> 3. **Espaces dans les chemins Windows** : Toujours utiliser des guillemets pour les chemins contenant des espaces
> 4. **Éditeur non installé** : Configurer un éditeur qui n'est pas installé ou pas dans le PATH causera des erreurs

### Bonnes pratiques

> [!tip] Recommandations
> 
> 1. **Configurez immédiatement après l'installation** : Ne faites pas votre premier commit avant d'avoir configuré votre identité
> 2. **Utilisez des emails cohérents** : Même email pour Git et GitHub/GitLab
> 3. **Sauvegardez votre configuration** : Le fichier `~/.gitconfig` peut être versionné dans un dotfiles repository
> 4. **Testez votre éditeur** : Assurez-vous que `git config --global --edit` ouvre bien votre éditeur
> 5. **Configuration différente par contexte** : Utilisez la configuration locale pour les projets professionnels vs personnels

### Vérification finale

```bash
# Check-list de vérification
echo "=== Vérification de l'installation Git ==="
echo "Version Git :"
git --version
echo ""
echo "Nom d'utilisateur :"
git config user.name
echo "Email :"
git config user.email
echo "Éditeur :"
git config core.editor
echo "Branche par défaut :"
git config init.defaultBranch
```

> [!example] Sortie attendue
> 
> ```
> === Vérification de l'installation Git ===
> Version Git :
> git version 2.43.0
> 
> Nom d'utilisateur :
> Marie Dupont
> Email :
> marie.dupont@email.com
> Éditeur :
> code --wait
> Branche par défaut :
> main
> ```

---


> [!success] Installation terminée ! Votre environnement Git est maintenant configuré et prêt à l'emploi. Vous pouvez passer à l'apprentissage des commandes de base et à la création de votre premier dépôt.