
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

## Introduction

L'authentification SSH sous Windows diffère légèrement de Linux, notamment dans l'emplacement des fichiers de configuration et les permissions. Cette partie couvre spécifiquement la connexion SSH entre deux machines Windows (client Windows → serveur Windows).

> [!info] Contexte Windows intègre nativement OpenSSH depuis Windows 10 (version 1809) et Windows Server 2019. Les commandes sont similaires à Linux, mais avec quelques particularités Windows.

---

## 🔑 Authentification par mot de passe Windows

### Principe de fonctionnement

L'authentification par mot de passe utilise directement les comptes utilisateurs Windows. Lorsqu'un utilisateur se connecte via SSH, le serveur vérifie ses identifiants contre la base SAM (Security Account Manager) ou Active Directory.

### Syntaxe de connexion

```bash
# Connexion SSH basique avec mot de passe
ssh utilisateur@adresse_ip

# Exemple concret
ssh john@192.168.1.100

# Avec spécification du port (si différent de 22)
ssh utilisateur@adresse_ip -p 2222
```

> [!example] Exemple de session
> 
> ```bash
> PS C:\Users\Alice> ssh bob@192.168.1.50
> bob@192.168.1.50's password: ********
> 
> Microsoft Windows [Version 10.0.19045.3803]
> (c) Microsoft Corporation. All rights reserved.
> 
> bob@DESKTOP-SERVER C:\Users\bob>
> ```

### Avantages et inconvénients

|Avantages|Inconvénients|
|---|---|
|✅ Configuration simple et rapide|❌ Moins sécurisé (vulnérable aux attaques par force brute)|
|✅ Utilise les comptes Windows existants|❌ Nécessite de saisir le mot de passe à chaque connexion|
|✅ Pas de gestion de clés|❌ Difficile à automatiser dans les scripts|

> [!warning] Sécurité L'authentification par mot de passe est déconseillée pour les serveurs exposés sur Internet. Privilégiez toujours l'authentification par clés SSH pour une sécurité renforcée.

### Configuration côté serveur

Pour autoriser l'authentification par mot de passe, vérifiez le fichier de configuration du serveur SSH :

```bash
# Emplacement du fichier de configuration
C:\ProgramData\ssh\sshd_config

# Paramètres à vérifier
PasswordAuthentication yes
```

> [!tip] Astuce Après modification du fichier `sshd_config`, redémarrez le service SSH avec : `Restart-Service sshd`

---

## 🔐 Génération de clés SSH sous Windows

### Pourquoi utiliser des clés SSH ?

Les clés SSH offrent une authentification **plus sécurisée** et **plus pratique** que les mots de passe. Une fois configurées, elles permettent des connexions automatiques sans saisie de mot de passe.

### Types d'algorithmes disponibles

|Algorithme|Sécurité|Compatibilité|Recommandation|
|---|---|---|---|
|**RSA**|Bonne (≥ 2048 bits)|Excellente|✅ Recommandé (2048-4096 bits)|
|**Ed25519**|Excellente|Bonne (systèmes récents)|✅ **Meilleur choix** (moderne et rapide)|
|**ECDSA**|Bonne|Bonne|⚠️ Acceptable|
|**DSA**|Faible|Obsolète|❌ Déprécié|

### Génération d'une clé Ed25519 (recommandé)

```bash
# Génération d'une clé Ed25519 moderne
ssh-keygen -t ed25519 -C "votre_email@exemple.com"

# Exemple concret
ssh-keygen -t ed25519 -C "alice@entreprise.com"
```

> [!example] Session de génération complète
> 
> ```bash
> PS C:\Users\Alice> ssh-keygen -t ed25519 -C "alice@entreprise.com"
> Generating public/private ed25519 key pair.
> Enter file in which to save the key (C:\Users\Alice/.ssh/id_ed25519):
> Enter passphrase (empty for no passphrase): ********
> Enter same passphrase again: ********
> Your identification has been saved in C:\Users\Alice/.ssh/id_ed25519
> Your public key has been saved in C:\Users\Alice/.ssh/id_ed25519.pub
> The key fingerprint is:
> SHA256:xK8... alice@entreprise.com
> The key's randomart image is:
> +--[ED25519 256]--+
> |     .o.         |
> |    ...o         |
> +----[SHA256]-----+
> ```

### Génération d'une clé RSA (alternative)

```bash
# Génération d'une clé RSA 4096 bits (plus sécurisée)
ssh-keygen -t rsa -b 4096 -C "votre_email@exemple.com"

# Options détaillées
ssh-keygen -t rsa        # Type d'algorithme (RSA)
           -b 4096       # Taille de la clé en bits
           -C "comment"  # Commentaire pour identifier la clé
           -f chemin     # Chemin personnalisé (optionnel)
```

> [!info] Taille des clés RSA
> 
> - **2048 bits** : Minimum acceptable
> - **3072 bits** : Bon compromis sécurité/performance
> - **4096 bits** : Maximum recommandé pour une sécurité maximale

### Protection par passphrase

```bash
# La passphrase protège votre clé privée
# Elle est demandée lors de la génération

Enter passphrase (empty for no passphrase): ********
Enter same passphrase again: ********
```

> [!warning] Passphrase vide Vous pouvez laisser vide pour ne pas avoir de passphrase, mais cela réduit la sécurité :
> 
> - ✅ **Avec passphrase** : Si quelqu'un vole votre clé privée, il ne peut pas l'utiliser
> - ❌ **Sans passphrase** : La clé peut être utilisée directement si elle est volée

> [!tip] Gestion des passphrases Utilisez `ssh-agent` pour mémoriser temporairement votre passphrase et ne pas avoir à la saisir à chaque connexion.

### Options avancées de génération

```bash
# Génération avec chemin personnalisé
ssh-keygen -t ed25519 -f C:\Users\Alice\.ssh\ma_cle_perso

# Génération sans confirmation interactive
ssh-keygen -t ed25519 -N "ma_passphrase" -f ~/.ssh/id_ed25519 -q

# Changement de la passphrase d'une clé existante
ssh-keygen -p -f ~/.ssh/id_ed25519
```

---

## 📁 Emplacement des clés SSH sous Windows

### Répertoire ~/.ssh sous Windows

Sous Windows, le répertoire `~/.ssh` correspond à :

```bash
C:\Users\VotreNom\.ssh\
```

> [!info] Équivalence de notation
> 
> - **Notation Unix** : `~/.ssh/`
> - **Chemin Windows** : `C:\Users\VotreNom\.ssh\`
> - Dans PowerShell, `~` fonctionne comme sous Linux

### Structure du répertoire .ssh

```
C:\Users\Alice\.ssh\
│
├── id_ed25519           # ← Clé PRIVÉE (à ne JAMAIS partager)
├── id_ed25519.pub       # ← Clé PUBLIQUE (à copier sur les serveurs)
├── id_rsa               # ← Clé PRIVÉE RSA (si vous en avez généré une)
├── id_rsa.pub           # ← Clé PUBLIQUE RSA
├── known_hosts          # ← Empreintes des serveurs connus
├── config               # ← Configuration personnalisée SSH (optionnel)
└── authorized_keys      # ← Clés publiques autorisées (côté serveur)
```

### Fichiers clés et leur rôle

|Fichier|Type|Rôle|À partager ?|
|---|---|---|---|
|`id_ed25519`|Clé privée|Prouve votre identité|❌ **JAMAIS**|
|`id_ed25519.pub`|Clé publique|Installée sur les serveurs|✅ Oui|
|`known_hosts`|Base de données|Mémorise les serveurs connus|⚠️ Non nécessaire|
|`authorized_keys`|Liste|Clés autorisées à se connecter|⚠️ Uniquement côté serveur|

> [!warning] Sécurité critique **Votre clé privée est comme un mot de passe universel** :
> 
> - Ne la partagez JAMAIS avec personne
> - Ne la copiez JAMAIS sur un serveur distant
> - Ne la commitez JAMAIS dans Git ou un système de versioning
> - Seule la clé publique (`.pub`) doit être diffusée

### Visualiser vos clés

```bash
# Lister le contenu du répertoire .ssh
dir ~/.ssh
# ou
ls ~/.ssh

# Afficher votre clé publique
type ~/.ssh/id_ed25519.pub
# ou sous PowerShell
Get-Content ~/.ssh/id_ed25519.pub

# Vérifier les permissions (important pour la sécurité)
icacls C:\Users\Alice\.ssh\id_ed25519
```

### Permissions sous Windows

Contrairement à Linux, Windows utilise un système de permissions différent (ACL). Pour sécuriser votre clé privée :

```powershell
# Définir les permissions correctes sur la clé privée
# Seul votre utilisateur doit avoir accès

# Supprimer l'héritage des permissions
icacls C:\Users\Alice\.ssh\id_ed25519 /inheritance:r

# Donner les droits uniquement à votre utilisateur
icacls C:\Users\Alice\.ssh\id_ed25519 /grant:r "%USERNAME%:F"
```

> [!tip] Vérification automatique OpenSSH sous Windows vérifie automatiquement les permissions. Si elles sont trop ouvertes, vous verrez l'avertissement :
> 
> ```
> WARNING: UNPROTECTED PRIVATE KEY FILE!
> Permissions for 'id_ed25519' are too open.
> ```

### Création manuelle du répertoire .ssh

Si le répertoire n'existe pas encore :

```powershell
# Création du répertoire
mkdir ~\.ssh

# Avec les bonnes permissions
New-Item -ItemType Directory -Path ~\.ssh -Force
icacls ~\.ssh /inheritance:r
icacls ~\.ssh /grant:r "%USERNAME%:F"
```

---

## 🔧 Configuration du fichier authorized_keys

### Rôle du fichier authorized_keys

Le fichier `authorized_keys` contient la liste des **clés publiques autorisées** à se connecter à un compte utilisateur. Il se trouve **côté serveur** dans le répertoire SSH de l'utilisateur distant.

> [!info] Principe de fonctionnement
> 
> 1. Vous générez une paire de clés sur votre **machine client**
> 2. Vous copiez votre **clé publique** dans le fichier `authorized_keys` du **serveur**
> 3. Lors de la connexion, le serveur vérifie que votre clé privée correspond à une clé publique autorisée

### Emplacement selon le type d'utilisateur

Sous Windows, l'emplacement du fichier `authorized_keys` diffère selon le type de compte :

```bash
# Pour un utilisateur standard
C:\Users\NomUtilisateur\.ssh\authorized_keys

# Pour les administrateurs (particularité Windows)
C:\ProgramData\ssh\administrators_authorized_keys
```

> [!warning] Particularité Windows : utilisateurs administrateurs Si vous vous connectez avec un compte **administrateur**, Windows utilise un fichier centralisé différent pour des raisons de sécurité. Cette protection empêche les administrateurs de se créer des accès non autorisés.

### Méthode 1 : Copie manuelle de la clé

#### Étape 1 : Afficher votre clé publique (client)

```bash
# Sur votre machine Windows cliente
type ~\.ssh\id_ed25519.pub

# Exemple de sortie :
# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILx... alice@entreprise.com
```

#### Étape 2 : Copier dans authorized_keys (serveur)

Connectez-vous au serveur et créez/éditez le fichier :

```powershell
# Sur le serveur Windows, pour un utilisateur standard
# Créer le répertoire .ssh s'il n'existe pas
mkdir ~\.ssh -Force

# Ajouter la clé publique au fichier
echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILx... alice@entreprise.com >> ~\.ssh\authorized_keys
```

Pour un administrateur :

```powershell
# Pour un compte administrateur
echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILx... alice@entreprise.com >> C:\ProgramData\ssh\administrators_authorized_keys
```

### Méthode 2 : Utilisation de ssh-copy-id (PowerShell)

> [!info] ssh-copy-id sous Windows La commande `ssh-copy-id` n'existe pas nativement sous Windows, mais on peut créer une fonction PowerShell équivalente.

```powershell
# Fonction PowerShell pour simuler ssh-copy-id
function ssh-copy-id {
    param(
        [string]$User,
        [string]$Server,
        [string]$Key = "~\.ssh\id_ed25519.pub"
    )
    
    $pubKey = Get-Content $Key
    ssh $User@$Server "mkdir -p ~/.ssh; echo '$pubKey' >> ~/.ssh/authorized_keys"
}

# Utilisation
ssh-copy-id -User bob -Server 192.168.1.50
```

### Méthode 3 : Copie via SCP
```bash
# Copier la clé publique sur le serveur
scp ~\.ssh\id_ed25519.pub bob@192.168.1.50:C:\Users\bob\ma_cle.pub

# Puis se connecter au serveur et l'ajouter
ssh bob@192.168.1.50
mkdir .ssh
type ma_cle.pub >> .ssh\authorized_keys
del ma_cle.pub
```

> [!warning] Attention - Utilisateurs Administrateurs
> Si votre compte fait partie du **groupe Administrateurs**, Windows utilise un emplacement différent pour le fichier `authorized_keys` :
> 
> ```bash
> # Au lieu de .ssh\authorized_keys, utilisez :
> type ma_cle.pub >> C:\ProgramData\ssh\administrators_authorized_keys
> del ma_cle.pub
> ```
> 
> Ce fichier doit avoir des **permissions strictes** :
> ```powershell
> # Vérifier/corriger les permissions (en PowerShell Admin)
> icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r
> icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "SYSTEM:(F)"
> icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "Administrateurs:(F)"
> ```
### Configuration des permissions du fichier

Les permissions du fichier `authorized_keys` sont critiques pour la sécurité :

```powershell
# Pour un utilisateur standard
icacls C:\Users\bob\.ssh\authorized_keys /inheritance:r
icacls C:\Users\bob\.ssh\authorized_keys /grant:r "%USERNAME%:F"
icacls C:\Users\bob\.ssh\authorized_keys /grant SYSTEM:F

# Pour les administrateurs
icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant SYSTEM:F
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant BUILTIN\Administrators:F
```

> [!warning] Permissions strictes obligatoires Si les permissions sont trop ouvertes, OpenSSH **refusera** d'utiliser le fichier et vous devrez vous connecter par mot de passe.

### Format du fichier authorized_keys

```bash
# Format : une clé publique par ligne
# Type Clé Commentaire

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILx... alice@entreprise.com
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... bob@laptop
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMy... charlie@desktop
```

> [!tip] Bonnes pratiques
> 
> - **Une clé par ligne** : Ne jamais mettre plusieurs clés sur la même ligne
> - **Commentaires explicites** : Utilisez des commentaires pour identifier chaque clé
> - **Pas de lignes vides** : Évitez les lignes vides entre les clés
> - **Encodage UTF-8** : Assurez-vous que le fichier est en UTF-8 sans BOM

### Tester la connexion par clé

```bash
# Test de connexion avec verbosité pour diagnostiquer
ssh -v bob@192.168.1.50

# Recherchez dans la sortie :
# debug1: Offering public key: ~/.ssh/id_ed25519
# debug1: Server accepts key: ~/.ssh/id_ed25519
# debug1: Authentication succeeded (publickey)
```

> [!example] Connexion réussie
> 
> ```bash
> PS C:\Users\Alice> ssh bob@192.168.1.50
> # Aucun mot de passe demandé !
> Microsoft Windows [Version 10.0.19045.3803]
> bob@DESKTOP-SERVER C:\Users\bob>
> ```

### Gestion de plusieurs clés

Vous pouvez autoriser plusieurs clés publiques pour un même utilisateur :

```bash
# Dans authorized_keys, ajoutez simplement plusieurs lignes
ssh-ed25519 AAAAC3... alice@laptop     # Clé du laptop
ssh-ed25519 AAAAC3... alice@desktop    # Clé du desktop
ssh-rsa AAAAB3... alice@work           # Clé du travail
```

> [!tip] Organisation Ajoutez des commentaires pour identifier facilement chaque clé :
> 
> ```bash
> # Clé du laptop personnel - Créée le 2024-01-15
> ssh-ed25519 AAAAC3... alice@laptop
> 
> # Clé du bureau - Créée le 2024-02-20
> ssh-ed25519 AAAAC3... alice@desktop
> ```

---

## ⚠️ Pièges courants et solutions

### Problème 1 : Permissions du fichier authorized_keys

**Symptôme** : La connexion par clé ne fonctionne pas, vous devez toujours saisir un mot de passe.

```bash
# Vérifier les logs SSH sur le serveur
Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 50

# Message d'erreur typique :
# Bad ownership or modes for file authorized_keys
```

**Solution** :

```powershell
# Corriger les permissions
icacls C:\Users\bob\.ssh\authorized_keys /inheritance:r
icacls C:\Users\bob\.ssh\authorized_keys /grant:r "bob:F"
icacls C:\Users\bob\.ssh\authorized_keys /grant SYSTEM:F

# Redémarrer le service SSH
Restart-Service sshd
```

### Problème 2 : Mauvais emplacement pour les administrateurs

**Symptôme** : Vous êtes administrateur et votre clé dans `~\.ssh\authorized_keys` est ignorée.

**Solution** : Utilisez l'emplacement spécifique aux administrateurs :

```powershell
# Copier la clé au bon endroit
Copy-Item ~\.ssh\authorized_keys C:\ProgramData\ssh\administrators_authorized_keys

# Appliquer les bonnes permissions
icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant SYSTEM:F
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant BUILTIN\Administrators:F
```

### Problème 3 : Clé publique mal copiée

**Symptôme** : Erreur `Permission denied (publickey)` lors de la connexion.

**Cause** : La clé publique a été coupée ou modifiée lors de la copie (retours à la ligne, espaces).

**Solution** :

```bash
# Vérifier que la clé est sur UNE SEULE ligne
Get-Content C:\Users\bob\.ssh\authorized_keys

# Chaque clé doit être : Type Clé Commentaire (sans retour à la ligne)
# ❌ MAUVAIS :
# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILx
# GH5... alice@entreprise.com

# ✅ BON :
# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxGH5... alice@entreprise.com
```

> [!tip] Copie sécurisée Utilisez `Get-Content` et redirection pour copier sans risque de modification :
> 
> ```powershell
> # Sur le client
> Get-Content ~\.ssh\id_ed25519.pub | Set-Clipboard
> 
> # Sur le serveur, coller directement
> Add-Content ~\.ssh\authorized_keys (Get-Clipboard)
> ```

### Problème 4 : Service SSH non démarré

**Symptôme** : `Connection refused` lors de la tentative de connexion.

**Solution** :

```powershell
# Vérifier l'état du service
Get-Service sshd

# Démarrer le service
Start-Service sshd

# Activer le démarrage automatique
Set-Service -Name sshd -StartupType Automatic
```

### Problème 5 : Firewall bloque le port SSH

**Symptôme** : Timeout lors de la connexion depuis une machine distante.

**Solution** :

```powershell
# Vérifier les règles de pare-feu
Get-NetFirewallRule -Name *ssh*

# Créer une règle pour autoriser SSH
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' `
    -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

### Problème 6 : Mauvais format de fin de ligne

**Symptôme** : Le fichier `authorized_keys` créé sous Windows ne fonctionne pas.

**Cause** : Windows utilise CRLF (`\r\n`) alors qu'OpenSSH attend LF (`\n`).

**Solution** :

```powershell
# Convertir le fichier en format Unix (LF)
(Get-Content ~\.ssh\authorized_keys) | Set-Content -NoNewline ~\.ssh\authorized_keys
```

> [!tip] Éditeur de texte Utilisez un éditeur capable de gérer les fins de ligne Unix (VSCode, Notepad++, etc.) lors de la modification manuelle du fichier.

### Problème 7 : Plusieurs clés et confusion

**Symptôme** : Vous avez plusieurs paires de clés et SSH utilise la mauvaise.

**Solution** : Spécifiez explicitement la clé à utiliser :

```bash
# Utiliser une clé spécifique
ssh -i ~\.ssh\ma_cle_speciale bob@192.168.1.50

# Ou configurer dans ~\.ssh\config
Host serveur1
    HostName 192.168.1.50
    User bob
    IdentityFile ~/.ssh/ma_cle_speciale
```

### Problème 8 : Authentification par clé désactivée

**Symptôme** : Le serveur refuse systématiquement l'authentification par clé.

**Solution** : Vérifier la configuration du serveur SSH :

```bash
# Éditer le fichier de configuration
notepad C:\ProgramData\ssh\sshd_config

# Vérifier ces lignes :
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Redémarrer le service
Restart-Service sshd
```

> [!warning] Erreurs de configuration Après modification de `sshd_config`, **redémarrez toujours** le service SSH pour appliquer les changements :
> 
> ```powershell
> Restart-Service sshd
> ```

---

## 🎯 Récapitulatif des commandes essentielles

```powershell
# === Génération de clés ===
ssh-keygen -t ed25519 -C "email@exemple.com"    # Générer une clé Ed25519
ssh-keygen -t rsa -b 4096 -C "email@exemple.com" # Générer une clé RSA 4096 bits

# === Visualisation ===
Get-Content ~\.ssh\id_ed25519.pub                # Afficher la clé publique
dir ~\.ssh                                        # Lister les clés

# === Installation sur le serveur (utilisateur standard) ===
mkdir ~\.ssh -Force                               # Créer le répertoire .ssh
echo "votre_clé_publique" >> ~\.ssh\authorized_keys

# === Installation sur le serveur (administrateur) ===
echo "votre_clé_publique" >> C:\ProgramData\ssh\administrators_authorized_keys

# === Permissions ===
icacls ~\.ssh\authorized_keys /inheritance:r
icacls ~\.ssh\authorized_keys /grant:r "%USERNAME%:F"

# === Test de connexion ===
ssh -v utilisateur@serveur                        # Connexion avec verbosité
ssh -i ~\.ssh\ma_cle utilisateur@serveur         # Utiliser une clé spécifique

# === Gestion du service SSH ===
Get-Service sshd                                  # Vérifier l'état
Start-Service sshd                                # Démarrer
Restart-Service sshd                              # Redémarrer
Set-Service -Name sshd -StartupType Automatic    # Démarrage automatique
```

---

> [!success] Points clés à retenir
> 
> - L'authentification par clé est **plus sécurisée** que par mot de passe
> - Préférez **Ed25519** pour sa sécurité et ses performances
> - **Ne partagez JAMAIS** votre clé privée (`id_ed25519`)
> - Les **administrateurs** utilisent un fichier `authorized_keys` différent
> - Les **permissions** doivent être strictes pour fonctionner
> - Testez avec `ssh -v` pour diagnostiquer les problèmes