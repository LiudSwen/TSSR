

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

SSH Agent est un gestionnaire de clés qui conserve vos clés privées en mémoire, vous évitant de saisir votre passphrase à chaque connexion SSH. Sous Windows, Microsoft a intégré un service natif ssh-agent qui fonctionne de manière similaire à son équivalent Unix/Linux, avec quelques spécificités propres à l'environnement Windows.

> [!info] Pourquoi utiliser SSH Agent ?
> 
> - **Confort** : Plus besoin de taper votre passphrase à chaque connexion
> - **Sécurité** : Les clés restent chiffrées sur disque, déchiffrées uniquement en mémoire
> - **Productivité** : Idéal pour les développeurs qui font de nombreuses connexions SSH ou Git
> - **Automatisation** : Permet les scripts sans compromettre la sécurité

---

## 🔧 SSH Agent sous Windows

### Qu'est-ce que SSH Agent ?

SSH Agent est un programme qui tourne en arrière-plan et maintient vos clés privées déchiffrées en mémoire. Lorsqu'une application SSH a besoin d'utiliser votre clé, elle communique avec l'agent au lieu d'accéder directement à la clé sur le disque.

**Fonctionnement :**

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Client    │  demande │  SSH Agent  │  utilise │   Clé privée│
│   SSH/Git   │ ────────>│ (mémoire)   │ ────────>│  déchiffrée │
└─────────────┘          └─────────────┘          └─────────────┘
                                │
                                │ Passphrase saisie
                                │ UNE SEULE FOIS
                                ▼
                         ┌─────────────┐
                         │ Clé chiffrée│
                         │  sur disque │
                         └─────────────┘
```

> [!warning] Important SSH Agent stocke les clés **en mémoire uniquement**. Au redémarrage de Windows ou du service, les clés doivent être rechargées.

---

### Service ssh-agent Windows

Windows 10 (depuis 1809) et Windows 11 incluent un service OpenSSH natif avec ssh-agent intégré.

#### Vérifier le statut du service

```powershell
# Vérifier l'état du service ssh-agent
Get-Service ssh-agent

# Affichage détaillé
Get-Service ssh-agent | Select-Object Name, Status, StartType
```

**États possibles :**

|Statut|Signification|
|---|---|
|`Running`|Le service est actif et fonctionnel|
|`Stopped`|Le service est installé mais arrêté|
|`Not found`|Le service n'est pas installé (rare sur Windows moderne)|

#### Démarrer le service

```powershell
# Démarrer le service (nécessite des droits administrateur)
Start-Service ssh-agent
```

> [!tip] Astuce pour les utilisateurs non-admin Si vous n'avez pas les droits administrateur, demandez à votre IT de configurer le service ou utilisez des alternatives comme Pageant (PuTTY).

#### Configurer le démarrage automatique

Par défaut, le service ssh-agent est en mode **Manuel**, ce qui signifie qu'il ne démarre pas automatiquement au démarrage de Windows.

```powershell
# Configurer le démarrage automatique (nécessite PowerShell en admin)
Set-Service -Name ssh-agent -StartupType Automatic

# Vérifier la configuration
Get-Service ssh-agent | Select-Object Name, StartType
```

**Types de démarrage :**

|StartType|Description|
|---|---|
|`Automatic`|Démarre automatiquement au boot de Windows|
|`Manual`|Démarre uniquement à la demande|
|`Disabled`|Ne peut pas être démarré|

> [!example] Configuration recommandée pour développeurs
> 
> ```powershell
> # En tant qu'administrateur
> Set-Service -Name ssh-agent -StartupType Automatic
> Start-Service ssh-agent
> 
> # Vérification
> Get-Service ssh-agent
> ```

#### Redémarrer le service

```powershell
# Redémarrer le service (utile si le service bug)
Restart-Service ssh-agent

# Ou en deux étapes
Stop-Service ssh-agent
Start-Service ssh-agent
```

> [!warning] Attention Redémarrer le service **efface toutes les clés en mémoire**. Vous devrez les rajouter avec `ssh-add`.

---

### Gestion des clés via ssh-add

`ssh-add` est l'outil en ligne de commande pour interagir avec ssh-agent. Il permet d'ajouter, lister et supprimer des clés.

#### Ajouter une clé à l'agent

```powershell
# Ajouter la clé par défaut (~/.ssh/id_rsa ou id_ed25519)
ssh-add

# Ajouter une clé spécifique
ssh-add C:\Users\VotreNom\.ssh\id_ed25519

# Ajouter une clé avec chemin relatif
ssh-add ~/.ssh/ma_cle_perso
```

**Ce qui se passe :**

1. `ssh-add` lit la clé privée chiffrée sur le disque
2. Vous demande la passphrase si la clé en a une
3. Déchiffre la clé en mémoire
4. La transmet à ssh-agent qui la garde en mémoire

> [!tip] Astuce : Ajouter toutes les clés d'un coup
> 
> ```powershell
> # Ajouter toutes les clés du dossier .ssh
> Get-ChildItem ~\.ssh\id_* -Exclude *.pub | ForEach-Object { ssh-add $_.FullName }
> ```

#### Lister les clés chargées

```powershell
# Afficher les clés actuellement dans l'agent
ssh-add -l

# Affichage plus détaillé avec le format de clé
ssh-add -L
```

**Exemple de sortie :**

```
256 SHA256:abc123def456... user@hostname (ED25519)
2048 SHA256:xyz789uvw012... user@hostname (RSA)
```

> [!info] Comprendre la sortie
> 
> - **256/2048** : Taille de la clé en bits
> - **SHA256:...** : Empreinte (fingerprint) de la clé
> - **user@hostname** : Commentaire de la clé
> - **(ED25519/RSA)** : Type d'algorithme

#### Supprimer des clés de l'agent

```powershell
# Supprimer une clé spécifique
ssh-add -d C:\Users\VotreNom\.ssh\id_ed25519

# Supprimer TOUTES les clés de l'agent
ssh-add -D
```

> [!warning] Attention avec -D `ssh-add -D` supprime **toutes** les clés de l'agent, pas seulement celle en cours. Utilisez avec précaution.

#### Définir une durée de vie pour une clé

```powershell
# Ajouter une clé qui sera automatiquement supprimée après 1 heure (3600 secondes)
ssh-add -t 3600 ~/.ssh/id_ed25519

# Ajouter une clé valable 8 heures (28800 secondes)
ssh-add -t 28800 ~/.ssh/id_rsa
```

> [!tip] Cas d'usage Utile pour les environnements partagés ou si vous voulez limiter l'exposition de vos clés en mémoire.

#### Tester la connexion avec l'agent

```powershell
# Se connecter à un serveur (l'agent fournira automatiquement la clé)
ssh utilisateur@serveur.com

# Tester avec Git
git clone git@github.com:username/repository.git
```

Si tout fonctionne, vous ne devriez **pas** avoir à saisir de passphrase.

---

### Persistance des clés

Par défaut sous Windows, les clés ajoutées à ssh-agent **ne sont pas persistantes** : elles sont perdues à chaque redémarrage du service ou de Windows.

#### Le problème de la non-persistance

```powershell
# Vous ajoutez vos clés
ssh-add ~/.ssh/id_ed25519

# Après un redémarrage de Windows
ssh-add -l
# Résultat : "The agent has no identities."
```

#### Solutions pour la persistance

##### Solution 1 : Script de démarrage PowerShell

Créez un script qui charge automatiquement vos clés au démarrage.

**Créer le script :**

```powershell
# Créer le dossier de profil s'il n'existe pas
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

# Ouvrir le profil PowerShell
notepad $PROFILE
```

**Contenu du script :**

```powershell
# Profil PowerShell - Chargement automatique SSH
# Fichier : Microsoft.PowerShell_profile.ps1

# Démarrer ssh-agent s'il n'est pas déjà lancé
$agentStatus = Get-Service ssh-agent | Select-Object -ExpandProperty Status
if ($agentStatus -ne 'Running') {
    Start-Service ssh-agent
}

# Fonction pour charger les clés SSH
function Load-SshKeys {
    # Liste des clés à charger
    $sshKeys = @(
        "$env:USERPROFILE\.ssh\id_ed25519",
        "$env:USERPROFILE\.ssh\id_rsa"
    )
    
    foreach ($key in $sshKeys) {
        if (Test-Path $key) {
            # Vérifier si la clé n'est pas déjà chargée
            $keyFingerprint = ssh-keygen -lf $key -E sha256 | Select-String -Pattern "SHA256:"
            $loadedKeys = ssh-add -l 2>$null
            
            if ($loadedKeys -notmatch $keyFingerprint) {
                Write-Host "Chargement de la clé : $key"
                ssh-add $key 2>$null
            }
        }
    }
}

# Charger les clés automatiquement
Load-SshKeys
```

> [!tip] Personnalisation Modifiez la variable `$sshKeys` pour inclure vos propres chemins de clés.

##### Solution 2 : Clés sans passphrase (NON RECOMMANDÉ)

```powershell
# Générer une clé SANS passphrase
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_no_passphrase -N ""
```

> [!warning] Sécurité compromise Les clés sans passphrase ne sont **PAS sécurisées**. Si quelqu'un accède à votre disque, il peut utiliser vos clés directement. À éviter absolument sauf pour des environnements de test isolés.

##### Solution 3 : Windows Credential Manager (Limitée)

Windows peut stocker certaines credentials, mais l'intégration native avec ssh-agent est limitée. Cette approche fonctionne mieux avec Git Credential Manager.

```powershell
# Installer Git Credential Manager (inclus avec Git pour Windows)
# Il gère automatiquement les credentials Git via SSH
```

#### Vérifier la persistance

```powershell
# Après configuration, redémarrer PowerShell
# Puis vérifier
ssh-add -l

# Vous devriez voir vos clés chargées automatiquement
```

---

### Intégration avec Git

SSH Agent est particulièrement utile pour Git, permettant de cloner, pousser et tirer du code sans saisir de passphrase à chaque opération.

#### Configurer Git pour utiliser SSH

```bash
# Vérifier la configuration Git actuelle
git config --global --list | grep url

# Configurer Git pour utiliser SSH au lieu de HTTPS pour GitHub
git config --global url."git@github.com:".insteadOf "https://github.com/"

# Pour GitLab
git config --global url."git@gitlab.com:".insteadOf "https://gitlab.com/"

# Pour Bitbucket
git config --global url."git@bitbucket.org:".insteadOf "https://bitbucket.org/"
```

#### Tester la connexion SSH avec GitHub

```powershell
# Tester la connexion SSH avec GitHub
ssh -T git@github.com

# Résultat attendu :
# Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

> [!info] Message normal Le message "does not provide shell access" est **normal**. Il confirme que l'authentification SSH fonctionne.

#### Cloner un dépôt via SSH

```bash
# Cloner un dépôt GitHub via SSH
git clone git@github.com:username/repository.git

# Cloner un dépôt GitLab via SSH
git clone git@gitlab.com:username/repository.git
```

Si ssh-agent fonctionne correctement, vous ne devriez **pas** avoir à saisir votre passphrase.

#### Convertir un dépôt existant de HTTPS vers SSH

```bash
# Voir l'URL actuelle
git remote -v

# Changer l'URL de origin pour utiliser SSH
git remote set-url origin git@github.com:username/repository.git

# Vérifier le changement
git remote -v
```

#### Utiliser différentes clés pour différents services

Si vous avez plusieurs clés SSH (par exemple, une pour GitHub perso et une pour le travail), configurez le fichier `~/.ssh/config` :

```bash
# Fichier : C:\Users\VotreNom\.ssh\config

# GitHub personnel
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_perso
    IdentitiesOnly yes

# GitHub professionnel
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab
    IdentitiesOnly yes
```

**Utilisation :**

```bash
# Cloner avec le compte perso (utilise github.com)
git clone git@github.com:username/perso-repo.git

# Cloner avec le compte pro (utilise github-work)
git clone git@github-work:company/work-repo.git
```

> [!example] Configuration multi-comptes Cette approche est très utile si vous avez plusieurs comptes GitHub/GitLab et que vous voulez éviter les conflits de clés.

#### Déboguer les problèmes Git+SSH

```powershell
# Activer le mode verbeux pour voir ce qui se passe
$env:GIT_SSH_COMMAND="ssh -v"
git clone git@github.com:username/repository.git

# Ou en une ligne pour un seul clone
GIT_SSH_COMMAND="ssh -vvv" git clone git@github.com:username/repository.git
```

**Problèmes courants :**

|Erreur|Cause probable|Solution|
|---|---|---|
|`Permission denied (publickey)`|Clé publique non ajoutée à GitHub/GitLab|Ajouter la clé publique sur le service|
|`Could not open a connection to your authentication agent`|ssh-agent non démarré|`Start-Service ssh-agent`|
|`No identities`|Aucune clé chargée dans l'agent|`ssh-add ~/.ssh/id_ed25519`|
|`Host key verification failed`|Fingerprint du serveur inconnu|Ajouter le serveur aux `known_hosts`|

#### Git Credential Manager et SSH

Git pour Windows inclut Git Credential Manager (GCM), mais pour SSH, c'est ssh-agent qui prime.

```powershell
# Vérifier la configuration de GCM
git config --global credential.helper

# Désactiver GCM si vous voulez utiliser uniquement SSH
git config --global --unset credential.helper
```

> [!tip] Recommandation Pour les dépôts Git, préférez SSH + ssh-agent plutôt que HTTPS + GCM pour une meilleure sécurité et simplicité.

---

## 🎓 Pièges courants et bonnes pratiques

### Pièges courants

1. **Oublier de démarrer le service ssh-agent**
    
    ```powershell
    # Toujours vérifier avant d'utiliser ssh-add
    Get-Service ssh-agent
    ```
    
2. **Confondre clé privée et clé publique**
    
    ```powershell
    # ❌ FAUX : Ajouter la clé publique
    ssh-add ~/.ssh/id_ed25519.pub
    
    # ✅ CORRECT : Ajouter la clé privée
    ssh-add ~/.ssh/id_ed25519
    ```
    
3. **Droits insuffisants sur le dossier .ssh**
    
    ```powershell
    # Les clés doivent être lisibles uniquement par vous
    icacls $env:USERPROFILE\.ssh\id_ed25519
    ```
    
4. **Mélanger plusieurs outils SSH (OpenSSH natif, Git Bash, PuTTY)**
    
    - Choisissez **un seul** environnement SSH et restez-y cohérent
    - OpenSSH natif Windows est recommandé pour la simplicité

### Bonnes pratiques

1. **Utiliser des clés modernes (ED25519)**
    
    ```powershell
    # Préférer ED25519 à RSA
    ssh-keygen -t ed25519 -C "votre@email.com"
    ```
    
2. **Toujours protéger vos clés avec une passphrase**
    
    - Ne créez jamais de clés sans passphrase en production
    - Utilisez un gestionnaire de mots de passe pour stocker la passphrase
3. **Configurer le démarrage automatique**
    
    ```powershell
    Set-Service -Name ssh-agent -StartupType Automatic
    ```
    
4. **Auditer régulièrement les clés chargées**
    
    ```powershell
    # Vérifier quelles clés sont en mémoire
    ssh-add -l
    ```
    
5. **Utiliser des clés différentes pour différents contextes**
    
    - Une clé pour le travail
    - Une clé pour les projets personnels
    - Ne jamais réutiliser une clé professionnelle pour du perso
6. **Documenter vos configurations**
    
    - Commentez votre fichier `~/.ssh/config`
    - Notez les passphrases dans un gestionnaire sécurisé

---

## 🔍 Astuces avancées

### Automatiser le chargement de clés dans un script

```powershell
# Script pour charger automatiquement les clés si elles ne sont pas présentes
function Ensure-SshKey {
    param (
        [string]$KeyPath
    )
    
    $fingerprint = ssh-keygen -lf $KeyPath -E sha256 2>$null | Select-String "SHA256:"
    $loadedKeys = ssh-add -l 2>$null
    
    if ($loadedKeys -notmatch $fingerprint) {
        ssh-add $KeyPath
    } else {
        Write-Host "Clé déjà chargée : $KeyPath"
    }
}

# Utilisation
Ensure-SshKey -KeyPath "$env:USERPROFILE\.ssh\id_ed25519"
```

### Utiliser ssh-agent dans WSL (Windows Subsystem for Linux)

Si vous utilisez WSL, vous pouvez partager ssh-agent entre Windows et Linux.

```bash
# Dans WSL, ajouter au ~/.bashrc ou ~/.zshrc
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
ss -a | grep -q $SSH_AUTH_SOCK
if [ $? -ne 0 ]; then
    rm -f $SSH_AUTH_SOCK
    (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
fi
```

> [!info] Prérequis Cette configuration nécessite `socat` et `npiperelay.exe` installés dans WSL.

### Créer un alias pour vérifier l'agent rapidement

```powershell
# Ajouter au profil PowerShell
function Check-SshAgent {
    $service = Get-Service ssh-agent
    Write-Host "Service ssh-agent : $($service.Status)"
    Write-Host "`nClés chargées :"
    ssh-add -l
}

# Créer un alias
Set-Alias -Name sshstatus -Value Check-SshAgent
```

### Réinitialiser complètement ssh-agent

```powershell
# En cas de problème, réinitialiser complètement
Stop-Service ssh-agent
Remove-Item "$env:USERPROFILE\.ssh\agent.sock" -ErrorAction SilentlyContinue
Start-Service ssh-agent
ssh-add ~/.ssh/id_ed25519
```

---

## 📊 Récapitulatif des commandes essentielles

|Commande|Description|
|---|---|
|`Get-Service ssh-agent`|Vérifier l'état du service|
|`Start-Service ssh-agent`|Démarrer le service|
|`Set-Service -Name ssh-agent -StartupType Automatic`|Configurer le démarrage auto|
|`ssh-add`|Ajouter la clé par défaut|
|`ssh-add ~/.ssh/id_ed25519`|Ajouter une clé spécifique|
|`ssh-add -l`|Lister les clés chargées|
|`ssh-add -L`|Afficher les clés publiques complètes|
|`ssh-add -D`|Supprimer toutes les clés de l'agent|
|`ssh-add -d <key>`|Supprimer une clé spécifique|
|`ssh -T git@github.com`|Tester la connexion SSH GitHub|

---

> [!tip] Point clé à retenir SSH Agent sous Windows simplifie énormément l'utilisation quotidienne de SSH et Git. Une fois configuré correctement avec le démarrage automatique et un script de chargement des clés, vous n'aurez plus jamais à saisir vos passphrases manuellement !