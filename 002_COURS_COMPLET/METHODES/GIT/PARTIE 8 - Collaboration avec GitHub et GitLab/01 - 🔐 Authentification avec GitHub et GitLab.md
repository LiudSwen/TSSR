

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

## Introduction

L'authentification est le processus qui permet à Git de vérifier votre identité lorsque vous interagissez avec un dépôt distant (GitHub, GitLab, etc.). Sans authentification appropriée, vous ne pouvez pas effectuer d'opérations comme `git push`, `git pull` sur des dépôts privés, ou même `git clone` dans certains cas.

> [!info] Pourquoi l'authentification est cruciale
> 
> - **Sécurité** : Protège vos dépôts contre les accès non autorisés
> - **Traçabilité** : Identifie qui effectue quelles modifications
> - **Permissions** : Contrôle les droits d'accès (lecture, écriture, admin)

---

## HTTPS vs SSH

Il existe deux protocoles principaux pour communiquer avec les dépôts distants : HTTPS et SSH. Chacun a ses avantages et inconvénients.

### 🌐 HTTPS (HyperText Transfer Protocol Secure)

**Format d'URL** : `https://github.com/utilisateur/depot.git`

**Avantages** :

- Plus simple à configurer initialement
- Fonctionne sur tous les réseaux (même avec pare-feu strict)
- Pas besoin de générer des clés
- Port 443 généralement ouvert

**Inconvénients** :

- Nécessite de saisir des credentials régulièrement (sans cache)
- Avec GitHub : obligation d'utiliser un Personal Access Token (pas de mot de passe)
- Moins sécurisé si on stocke les credentials en clair

### 🔑 SSH (Secure Shell)

**Format d'URL** : `git@github.com:utilisateur/depot.git`

**Avantages** :

- Authentification automatique via clés cryptographiques
- Plus sécurisé (clés privées jamais transmises)
- Pas besoin de saisir de mot de passe à chaque opération
- Préféré pour un usage quotidien intensif

**Inconvénients** :

- Configuration initiale plus complexe
- Nécessite d'ajouter la clé publique sur GitHub/GitLab
- Port 22 parfois bloqué par les pare-feu d'entreprise

### 📊 Tableau comparatif

|Critère|HTTPS|SSH|
|---|---|---|
|**Facilité d'installation**|⭐⭐⭐⭐⭐|⭐⭐⭐|
|**Sécurité**|⭐⭐⭐|⭐⭐⭐⭐⭐|
|**Confort d'usage**|⭐⭐⭐|⭐⭐⭐⭐⭐|
|**Compatibilité réseau**|⭐⭐⭐⭐⭐|⭐⭐⭐|
|**Usage recommandé**|Débutants, accès ponctuel|Usage quotidien, professionnels|

> [!tip] Quelle méthode choisir ?
> 
> - **Débutant ou utilisation occasionnelle** : HTTPS avec Personal Access Token
> - **Développeur régulier** : SSH pour le confort quotidien
> - **Environnement d'entreprise** : Vérifiez d'abord les restrictions réseau

---

## Génération de clés SSH

Les clés SSH fonctionnent par paires : une **clé privée** (gardée secrète sur votre machine) et une **clé publique** (partagée avec GitHub/GitLab).

### 🔧 Vérifier les clés existantes

Avant de créer de nouvelles clés, vérifiez si vous en avez déjà :

```bash
# Lister les clés SSH existantes
ls -al ~/.ssh

# Fichiers typiques à rechercher :
# - id_rsa / id_rsa.pub (ancien algorithme RSA)
# - id_ed25519 / id_ed25519.pub (algorithme moderne recommandé)
# - id_ecdsa / id_ecdsa.pub (algorithme ECDSA)
```

> [!warning] Attention aux clés existantes Si vous avez déjà une clé SSH, vous pouvez la réutiliser plutôt que d'en créer une nouvelle. Créer une nouvelle clé écrasera l'ancienne si vous utilisez le même nom.

### 🆕 Créer une nouvelle paire de clés SSH

#### Méthode recommandée : Ed25519

```bash
# Génération avec l'algorithme Ed25519 (moderne et sécurisé)
ssh-keygen -t ed25519 -C "votre.email@exemple.com"

# Options détaillées :
# -t ed25519 : Type d'algorithme (Ed25519 est le plus moderne)
# -C "email" : Commentaire pour identifier la clé (généralement votre email)
```

**Processus interactif** :

1. **Emplacement du fichier** :

```
Enter file in which to save the key (/home/user/.ssh/id_ed25519):
```

Appuyez sur Entrée pour accepter l'emplacement par défaut, ou spécifiez un chemin personnalisé.

2. **Passphrase** :

```
Enter passphrase (empty for no passphrase):
```

> [!tip] Passphrase recommandée Ajoutez une passphrase pour une sécurité supplémentaire. Même si quelqu'un obtient votre clé privée, il ne pourra pas l'utiliser sans la passphrase. Vous pouvez utiliser `ssh-agent` pour ne la saisir qu'une fois par session.

#### Méthode alternative : RSA (compatibilité)

```bash
# Pour des systèmes plus anciens ne supportant pas Ed25519
ssh-keygen -t rsa -b 4096 -C "votre.email@exemple.com"

# Options :
# -t rsa : Type RSA
# -b 4096 : Taille de la clé (minimum 4096 bits pour la sécurité)
```

### 📋 Afficher votre clé publique

```bash
# Afficher le contenu de la clé publique
cat ~/.ssh/id_ed25519.pub

# Copier directement dans le presse-papier (Linux avec xclip)
cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard

# Copier directement dans le presse-papier (macOS)
cat ~/.ssh/id_ed25519.pub | pbcopy

# Copier directement dans le presse-papier (Windows Git Bash)
cat ~/.ssh/id_ed25519.pub | clip
```

Le contenu ressemble à ceci :

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJl3dIeudNqd0TH9v5kS3j9kX8hY8yZa9wFN6rN8k4UH votre.email@exemple.com
```

### 🌐 Ajouter la clé sur GitHub

1. Allez sur **GitHub.com** → **Settings** (icône profil en haut à droite)
2. Dans le menu latéral : **SSH and GPG keys**
3. Cliquez sur **New SSH key**
4. **Title** : Donnez un nom descriptif (ex: "Laptop personnel Ubuntu")
5. **Key type** : Laissez "Authentication Key"
6. **Key** : Collez votre clé publique complète
7. Cliquez sur **Add SSH key**

### 🦊 Ajouter la clé sur GitLab

1. Allez sur **GitLab.com** → **Preferences** (icône profil)
2. Dans le menu latéral : **SSH Keys**
3. Collez votre clé publique dans le champ **Key**
4. **Title** : Nom descriptif auto-rempli (modifiable)
5. **Expiration date** : (optionnel) Date d'expiration de la clé
6. Cliquez sur **Add key**

### 🧪 Tester la connexion SSH

```bash
# Tester la connexion avec GitHub
ssh -T git@github.com

# Résultat attendu :
# Hi username! You've successfully authenticated, but GitHub does not provide shell access.

# Tester la connexion avec GitLab
ssh -T git@gitlab.com

# Résultat attendu :
# Welcome to GitLab, @username!
```

> [!warning] Premier avertissement de connexion Lors de la première connexion, vous verrez un avertissement concernant l'authenticité de l'hôte :
> 
> ```
> The authenticity of host 'github.com (140.82.121.4)' can't be established.
> ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
> Are you sure you want to continue connecting (yes/no/[fingerprint])?
> ```
> 
> Tapez `yes` pour continuer. Cela ajoute GitHub/GitLab aux hôtes connus.

### 🔐 Utiliser ssh-agent (optionnel mais recommandé)

Si vous avez défini une passphrase, `ssh-agent` permet de ne la saisir qu'une fois par session :

```bash
# Démarrer ssh-agent en arrière-plan
eval "$(ssh-agent -s)"

# Ajouter votre clé privée à l'agent
ssh-add ~/.ssh/id_ed25519

# Vérifier les clés chargées dans l'agent
ssh-add -l
```

> [!tip] Configuration automatique au démarrage Ajoutez ces lignes à votre `~/.bashrc` ou `~/.zshrc` pour démarrer automatiquement l'agent :
> 
> ```bash
> if [ -z "$SSH_AUTH_SOCK" ]; then
>    eval "$(ssh-agent -s)"
>    ssh-add ~/.ssh/id_ed25519
> fi
> ```

---

## Personal Access Tokens (PAT)

Les **Personal Access Tokens** sont des alternatives sécurisées aux mots de passe pour l'authentification HTTPS. GitHub a rendu obligatoire leur utilisation depuis août 2021.

### 🎯 Pourquoi utiliser des PAT ?

- **Sécurité renforcée** : Permissions granulaires (scopes)
- **Révocabilité** : Supprimez un token compromis sans changer votre mot de passe
- **Traçabilité** : Chaque token peut être nommé pour identifier son usage
- **Expiration** : Tokens avec date d'expiration pour limiter les risques

> [!info] Types de tokens
> 
> - **Classic tokens** : Permissions par scope (repo, workflow, etc.)
> - **Fine-grained tokens** (nouveau) : Permissions précises par dépôt et action

### 🔧 Créer un Personal Access Token sur GitHub

#### Tokens classiques

1. **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Cliquez sur **Generate new token** → **Generate new token (classic)**
3. **Note** : Donnez un nom descriptif (ex: "Laptop dev principal")
4. **Expiration** : Choisissez une durée (30 jours, 90 jours, custom, no expiration)
5. **Scopes** : Sélectionnez les permissions nécessaires

**Scopes courants** :

- `repo` : Accès complet aux dépôts privés (clone, push, pull)
- `workflow` : Modifier les GitHub Actions
- `read:org` : Lire les informations d'organisation
- `gist` : Créer et modifier des Gists

6. Cliquez sur **Generate token**
7. **IMPORTANT** : Copiez immédiatement le token (il ne sera plus affiché)

> [!warning] Conservation du token Le token n'est affiché qu'une seule fois. Si vous le perdez, vous devrez en générer un nouveau. Stockez-le dans un gestionnaire de mots de passe sécurisé (1Password, Bitwarden, etc.).

### 🦊 Créer un Personal Access Token sur GitLab

1. **Preferences** → **Access Tokens**
2. **Token name** : Nom descriptif
3. **Expiration date** : Date d'expiration (recommandé)
4. **Select scopes** : Permissions nécessaires

**Scopes courants** :

- `read_repository` : Cloner et lire les dépôts
- `write_repository` : Pousser des changements
- `api` : Accès complet à l'API GitLab

5. Cliquez sur **Create personal access token**
6. Copiez le token immédiatement

### 🔌 Utiliser un PAT pour cloner/pousser

Lors de l'utilisation de HTTPS, Git vous demandera vos credentials :

```bash
# Cloner un dépôt via HTTPS
git clone https://github.com/utilisateur/depot.git

# Lors du push, Git demandera :
Username: votre_username
Password: <collez_votre_PAT_ici>
```

> [!tip] Le token remplace le mot de passe
> 
> - **Username** : Votre nom d'utilisateur GitHub/GitLab
> - **Password** : Collez le Personal Access Token (PAS votre mot de passe de compte)

---

## Configuration des credentials

Pour éviter de saisir vos credentials à chaque opération, Git propose plusieurs méthodes de stockage.

### 💾 Credential Helper

Git dispose d'un système de "credential helper" qui mémorise vos identifiants.

#### Cache temporaire (Linux/macOS)

```bash
# Mettre en cache les credentials pendant 1 heure (3600 secondes)
git config --global credential.helper cache

# Personnaliser la durée (ex: 24 heures = 86400 secondes)
git config --global credential.helper 'cache --timeout=86400'
```

Les credentials sont stockés en mémoire et disparaissent après expiration ou redémarrage.

#### Stockage permanent (⚠️ moins sécurisé)

```bash
# Stocker les credentials sur le disque (fichier en clair)
git config --global credential.helper store

# Le fichier se trouve ici :
# ~/.git-credentials
```

> [!warning] Risque de sécurité Avec `store`, les credentials sont sauvegardés **en clair** dans `~/.git-credentials`. N'utilisez cette méthode que sur une machine personnelle sécurisée.

#### Windows Credential Manager

```bash
# Windows utilise automatiquement le Credential Manager
git config --global credential.helper manager-core

# Ou pour les versions plus anciennes :
git config --global credential.helper wincred
```

Les credentials sont stockés dans le Gestionnaire d'identification Windows (sécurisé).

#### macOS Keychain

```bash
# Utiliser le trousseau macOS
git config --global credential.helper osxkeychain
```

Les credentials sont stockés dans le Keychain macOS (sécurisé).

### 🔍 Vérifier la configuration actuelle

```bash
# Afficher le credential helper configuré
git config --global credential.helper

# Afficher toutes les configurations liées aux credentials
git config --global --get-regexp credential
```

### 🗑️ Supprimer les credentials stockés

```bash
# Effacer les credentials en cache
git credential-cache exit

# Supprimer le fichier de credentials stockés
rm ~/.git-credentials

# Rejeter les credentials pour une URL spécifique
git credential reject
# Puis entrez :
protocol=https
host=github.com
# Ctrl+D pour valider
```

### 🔄 Changer le protocole d'un remote existant

Si vous avez cloné via HTTPS mais souhaitez passer à SSH (ou inversement) :

```bash
# Afficher l'URL actuelle du remote
git remote -v

# Changer HTTPS → SSH
git remote set-url origin git@github.com:utilisateur/depot.git

# Changer SSH → HTTPS
git remote set-url origin https://github.com/utilisateur/depot.git

# Vérifier le changement
git remote -v
```

### 🎛️ Configuration par dépôt vs globale

```bash
# Configuration globale (tous les dépôts)
git config --global credential.helper cache

# Configuration locale (dépôt actuel uniquement)
git config credential.helper store

# Supprimer une configuration
git config --global --unset credential.helper
```

### 📝 Format du fichier .git-credentials

Si vous utilisez `credential.helper store`, le fichier ressemble à ceci :

```
https://username:token@github.com
https://username:token@gitlab.com
```

> [!warning] Fichier en clair Ce fichier contient vos credentials en texte brut. Assurez-vous que les permissions sont restrictives :
> 
> ```bash
> chmod 600 ~/.git-credentials
> ```

### 🔐 Utiliser un gestionnaire de mots de passe tiers

Pour une sécurité maximale, utilisez un gestionnaire dédié :

#### Git Credential Manager (GCM)

```bash
# Installation (Linux)
wget https://github.com/GitCredentialManager/git-credential-manager/releases/latest/download/gcm-linux_amd64.*.deb
sudo dpkg -i gcm-linux_amd64.*.deb

# Configuration
git config --global credential.helper manager

# GCM stocke les credentials de manière sécurisée et gère automatiquement
# l'authentification OAuth avec GitHub/GitLab
```

**Avantages de GCM** :

- Authentification OAuth (plus sécurisée)
- Stockage sécurisé multi-plateforme
- Renouvellement automatique des tokens
- Interface graphique pour l'authentification

---

## Pièges courants

### ❌ Erreur : Permission denied (publickey)

**Symptôme** :

```bash
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
```

**Causes possibles** :

- Clé SSH pas ajoutée sur GitHub/GitLab
- Clé privée pas chargée dans ssh-agent
- Mauvaise clé utilisée (si vous en avez plusieurs)

**Solutions** :

```bash
# Vérifier que la clé est chargée
ssh-add -l

# Si vide, ajouter la clé
ssh-add ~/.ssh/id_ed25519

# Tester la connexion
ssh -T git@github.com

# Déboguer la connexion (verbose)
ssh -vT git@github.com
```

### ❌ Erreur : Support for password authentication was removed

**Symptôme** :

```bash
remote: Support for password authentication was removed on August 13, 2021.
remote: Please use a personal access token instead.
```

**Cause** : Vous tentez d'utiliser votre mot de passe GitHub au lieu d'un PAT.

**Solution** :

1. Créez un Personal Access Token (voir section dédiée)
2. Utilisez le token comme mot de passe
3. Configurez un credential helper pour le sauvegarder

### ❌ Credentials incorrects répétés

**Symptôme** : Git continue à demander les credentials même après les avoir entrés.

**Causes** :

- Credentials incorrects stockés en cache
- Token expiré

**Solutions** :

```bash
# Vider le cache
git credential-cache exit

# Ou supprimer les credentials stockés
rm ~/.git-credentials

# Puis recommencer l'opération
git push
```

### ❌ Multiple comptes GitHub/GitLab

**Problème** : Vous avez plusieurs comptes (personnel, professionnel) et souhaitez utiliser des clés différentes.

**Solution** : Configuration SSH personnalisée dans `~/.ssh/config` :

```bash
# ~/.ssh/config

# Compte personnel GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal

# Compte professionnel GitHub
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work

# Compte personnel GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab
```

**Utilisation** :

```bash
# Cloner avec le compte professionnel
git clone git@github-work:entreprise/projet.git

# Le remote sera automatiquement configuré pour utiliser github-work
```

### ❌ Passphrase demandée à chaque fois

**Problème** : Vous devez saisir la passphrase SSH à chaque opération Git.

**Solution** : Utilisez ssh-agent pour la mémoriser pendant la session :

```bash
# Démarrer l'agent
eval "$(ssh-agent -s)"

# Ajouter la clé
ssh-add ~/.ssh/id_ed25519

# Sur macOS, ajouter au Keychain (permanent)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### ⚠️ Token expiré

**Symptôme** :

```bash
remote: Invalid username or password.
fatal: Authentication failed
```

**Solution** :

1. Vérifiez la date d'expiration de votre token sur GitHub/GitLab
2. Générez un nouveau token si nécessaire
3. Mettez à jour les credentials stockés :

```bash
# Supprimer les anciens credentials
git credential reject
# Entrez protocol=https et host=github.com

# Prochain push demandera le nouveau token
git push
```

---

## 💡 Astuces

### Créer des alias pour basculer entre comptes

```bash
# Dans ~/.bashrc ou ~/.zshrc
alias git-perso='git config user.email "perso@email.com"'
alias git-work='git config user.email "work@email.com"'

# Usage dans un dépôt
git-perso  # Configure l'email personnel pour ce dépôt
```

### Vérifier rapidement l'authentification actuelle

```bash
# Créer un alias pour tester l'authentification
alias git-test-auth='ssh -T git@github.com && ssh -T git@gitlab.com'

# Usage
git-test-auth
```

### Forcer la demande de credentials

```bash
# Utile pour tester un nouveau token sans attendre l'expiration du cache
git -c credential.helper= push
```

### Lister toutes les clés SSH sur votre compte GitHub

```bash
# Via l'API GitHub (nécessite un PAT avec scope admin:public_key)
curl -H "Authorization: token VOTRE_TOKEN" https://api.github.com/user/keys
```

### Rotation régulière des tokens

> [!tip] Bonne pratique de sécurité
> 
> - Définissez une expiration (90 jours recommandés)
> - Notez la date d'expiration dans votre calendrier
> - Générez un nouveau token avant expiration
> - Révoquez l'ancien token après mise à jour