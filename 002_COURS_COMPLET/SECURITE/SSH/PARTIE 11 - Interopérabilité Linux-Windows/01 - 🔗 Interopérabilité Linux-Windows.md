

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

## 🌐 Introduction à l'interopérabilité {#introduction}

L'interopérabilité SSH entre Windows et Linux présente des défis spécifiques liés aux différences fondamentales entre ces systèmes : modèles de permissions, formats de fichiers, encodages, et implémentations SSH distinctes. Cette partie se concentre sur la connexion depuis un client Windows vers un serveur Linux.

> [!info] Contexte Windows utilise OpenSSH depuis Windows 10 (version 1809) et Windows Server 2019, mais des différences subsistent avec l'implémentation Unix/Linux, notamment au niveau des chemins, des permissions et des conventions de fichiers.

---

## 💻 Connexion Windows vers Linux {#connexion-windows-vers-linux}

### 🔑 Configuration des clés croisées {#configuration-des-clés-croisées}

#### Génération de clés sur Windows

Sous Windows, vous pouvez générer des clés SSH avec l'outil OpenSSH natif via PowerShell ou l'Invite de commandes.

```bash
# Génération d'une paire de clés ED25519 (recommandé)
ssh-keygen -t ed25519 -C "votre.email@example.com"

# Ou RSA si nécessaire (pour compatibilité anciens systèmes)
ssh-keygen -t rsa -b 4096 -C "votre.email@example.com"
```

> [!tip] Emplacement par défaut Par défaut, les clés sont stockées dans `C:\Users\VotreNom\.ssh\`
> 
> - Clé privée : `id_ed25519` ou `id_rsa`
> - Clé publique : `id_ed25519.pub` ou `id_rsa.pub`

#### Copie de la clé publique vers Linux

Plusieurs méthodes existent pour transférer votre clé publique Windows vers le serveur Linux :

**Méthode 1 : Via ssh-copy-id (si disponible)**

```bash
# Depuis PowerShell ou Git Bash
ssh-copy-id utilisateur@serveur-linux
```

> [!warning] Disponibilité limitée `ssh-copy-id` n'est pas toujours disponible dans l'OpenSSH Windows natif. Il faut parfois utiliser Git Bash ou WSL.

**Méthode 2 : Copie manuelle (méthode universelle)**

```bash
# 1. Afficher le contenu de votre clé publique (PowerShell)
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | Set-Clipboard

# 2. Se connecter au serveur Linux (avec mot de passe)
ssh utilisateur@serveur-linux

# 3. Sur le serveur Linux, ajouter la clé
mkdir -p ~/.ssh
echo "COLLEZ_VOTRE_CLÉ_PUBLIQUE_ICI" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

**Méthode 3 : Via une commande PowerShell en une ligne**

```bash
# Envoyer directement la clé publique au serveur
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh utilisateur@serveur-linux "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

#### Configuration du client SSH Windows

Créez ou éditez le fichier de configuration SSH Windows :

```bash
# Emplacement : C:\Users\VotreNom\.ssh\config

Host serveur-prod
    HostName 192.168.1.100
    User admin
    Port 22
    IdentityFile C:\Users\VotreNom\.ssh\id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3

Host *.example.com
    User deployuser
    IdentityFile C:\Users\VotreNom\.ssh\id_rsa_deploy
    ForwardAgent yes
```

> [!tip] Chemins Windows
> 
> - Utilisez des chemins absolus Windows ou relatifs à `%USERPROFILE%`
> - Les backslashes `\` fonctionnent, mais les slashs `/` sont aussi acceptés
> - Évitez les espaces dans les noms de fichiers de clés

---

### 🔒 Gestion des permissions {#gestion-des-permissions}

Les permissions de fichiers sont gérées différemment sous Windows (ACL) et Linux (permissions UNIX). C'est une source majeure de problèmes.

#### Permissions requises côté Linux (serveur)

Sur le serveur Linux, les permissions doivent être strictes pour des raisons de sécurité :

```bash
# Structure et permissions correctes sur Linux
~/.ssh/                    # 700 (drwx------)
~/.ssh/authorized_keys     # 600 (-rw-------)
~/.ssh/config              # 600 (-rw-------)
~/.ssh/known_hosts         # 644 (-rw-r--r--)
```

```bash
# Commandes de correction des permissions sur Linux
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/config
chmod 644 ~/.ssh/known_hosts

# Vérifier le propriétaire
ls -la ~/.ssh/
# Le propriétaire doit être l'utilisateur lui-même
```

> [!warning] Erreur fréquente Si `authorized_keys` a des permissions trop ouvertes (comme 644 ou 777), SSH refusera silencieusement d'utiliser le fichier. Vérifiez les logs : `/var/log/auth.log` ou `/var/log/secure`

#### Permissions requises côté Windows (client)

Windows OpenSSH vérifie également les permissions des clés privées. Seul le propriétaire doit y avoir accès.

**Vérification et correction des permissions (PowerShell en tant qu'administrateur) :**

```powershell
# Naviguer vers le dossier .ssh
cd $env:USERPROFILE\.ssh

# Vérifier les permissions actuelles
icacls id_ed25519

# Supprimer les permissions héritées et ne garder que l'utilisateur actuel
icacls id_ed25519 /inheritance:r
icacls id_ed25519 /grant:r "$($env:USERNAME):(R)"

# Alternative : script complet pour sécuriser les clés privées
$path = "$env:USERPROFILE\.ssh\id_ed25519"
icacls $path /inheritance:r
icacls $path /grant:r "$($env:USERNAME):(F)"
```

> [!info] Permissions Windows vs Linux
> 
> |Linux|Windows (équivalent)|
> |---|---|
> |600 (rw-------)|Propriétaire : Lecture/Écriture uniquement|
> |700 (rwx------)|Propriétaire : Contrôle total|
> |644 (rw-r--r--)|Propriétaire : Lecture/Écriture, Autres : Lecture|

**Commande pour corriger tous les fichiers du dossier .ssh :**

```powershell
# Script PowerShell pour sécuriser le dossier .ssh
$sshPath = "$env:USERPROFILE\.ssh"

# Dossier .ssh : accès complet pour l'utilisateur seul
icacls $sshPath /inheritance:r
icacls $sshPath /grant:r "$($env:USERNAME):(OI)(CI)(F)"

# Clés privées : lecture seule pour l'utilisateur
Get-ChildItem $sshPath -Filter "id_*" -Exclude "*.pub" | ForEach-Object {
    icacls $_.FullName /inheritance:r
    icacls $_.FullName /grant:r "$($env:USERNAME):(R)"
}

# Clés publiques : peuvent être moins restrictives
Get-ChildItem $sshPath -Filter "*.pub" | ForEach-Object {
    icacls $_.FullName /inheritance:r
    icacls $_.FullName /grant:r "$($env:USERNAME):(R,W)"
}
```

---

### ⚠️ Problèmes courants de compatibilité {#problèmes-courants-de-compatibilité}

#### Format de clé incompatible

**Symptôme :** Erreur `invalid format` ou connexion refusée malgré une clé valide.

**Cause :** OpenSSH Windows moderne génère des clés au format OpenSSH, mais certains vieux systèmes Linux attendent le format PEM.

```bash
# Vérifier le format de votre clé privée
head -n 1 ~/.ssh/id_rsa

# Format OpenSSH (moderne) :
# -----BEGIN OPENSSH PRIVATE KEY-----

# Format PEM (ancien) :
# -----BEGIN RSA PRIVATE KEY-----
```

**Solution :** Convertir la clé au format PEM si nécessaire

```bash
# Convertir OpenSSH vers PEM
ssh-keygen -p -m PEM -f ~/.ssh/id_rsa
```

> [!tip] Recommandation Privilégiez ED25519 qui a un format plus standard et est mieux supporté :
> 
> ```bash
> ssh-keygen -t ed25519 -C "votre@email.com"
> ```

#### Algorithmes cryptographiques désactivés

**Symptôme :** `Unable to negotiate` ou `no matching key exchange method found`

**Cause :** Le serveur Linux utilise des algorithmes obsolètes (DSA, RSA-SHA1) désactivés par défaut dans les nouvelles versions d'OpenSSH.

**Solution temporaire (client Windows) :**

```bash
# Fichier : C:\Users\VotreNom\.ssh\config

Host serveur-ancien
    HostName 192.168.1.50
    User admin
    # Réactiver les anciens algorithmes (temporairement)
    PubkeyAcceptedKeyTypes +ssh-rsa
    HostKeyAlgorithms +ssh-rsa
```

> [!warning] Sécurité Cette solution est temporaire. La vraie solution est de mettre à jour le serveur Linux et de régénérer des clés modernes (ED25519 ou RSA 4096 bits minimum).

#### Problèmes de chemins et d'espaces

**Cause :** Les espaces dans les chemins Windows peuvent causer des problèmes.

```bash
# ❌ Problématique
IdentityFile C:\Users\Jean Dupont\.ssh\id_rsa

# ✅ Solutions
IdentityFile "C:\Users\Jean Dupont\.ssh\id_rsa"
IdentityFile C:/Users/Jean\ Dupont/.ssh/id_rsa
IdentityFile ~/.ssh/id_rsa  # Chemin relatif recommandé
```

> [!tip] Bonne pratique Évitez les espaces dans les noms d'utilisateurs Windows si possible, ou utilisez toujours des chemins relatifs avec `~` dans la configuration SSH.

#### Erreur "Connection reset by peer"

**Causes possibles :**

1. Pare-feu Windows bloquant les connexions sortantes
2. MTU (Maximum Transmission Unit) incompatible
3. Keep-alive non configuré

**Solutions :**

```bash
# Configuration SSH pour connexions instables (config client)
Host *
    ServerAliveInterval 30
    ServerAliveCountMax 5
    TCPKeepAlive yes
    IPQoS throughput
```

```powershell
# Vérifier le pare-feu Windows (PowerShell admin)
Get-NetFirewallRule -DisplayName "*ssh*"

# Autoriser OpenSSH client
New-NetFirewallRule -DisplayName "OpenSSH Client" -Direction Outbound -Action Allow -Protocol TCP -LocalPort 22
```

#### Agent SSH non démarré

**Symptôme :** Les clés ne sont pas chargées automatiquement, demande de passphrase à chaque connexion.

**Solution :** Activer et démarrer le service ssh-agent

```powershell
# Vérifier le statut du service (PowerShell admin)
Get-Service ssh-agent

# Définir le service en démarrage automatique
Set-Service ssh-agent -StartupType Automatic

# Démarrer le service
Start-Service ssh-agent

# Ajouter une clé à l'agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

> [!info] Alternative : Pageant (PuTTY) Si vous utilisez PuTTY sur Windows, l'agent Pageant remplace ssh-agent. Les clés doivent être au format `.ppk` (convertibles avec PuTTYgen).

---

### 📝 Encodage et line endings {#encodage-et-line-endings}

Les différences d'encodage et de fins de ligne entre Windows et Linux sont une source fréquente de problèmes subtils.

#### Line endings (fins de ligne)

Windows et Linux utilisent des conventions différentes pour marquer la fin d'une ligne :

|Système|Fin de ligne|Représentation|Nom|
|---|---|---|---|
|Windows|CRLF|`\r\n`|Carriage Return + Line Feed|
|Linux/Unix|LF|`\n`|Line Feed uniquement|

**Impact sur SSH :**

1. **Fichiers de configuration** : Les fichiers `~/.ssh/config`, `authorized_keys` doivent utiliser LF (Unix)
2. **Scripts shell** : Un script avec CRLF ne s'exécutera pas correctement sur Linux
3. **Clés SSH** : Les clés publiques avec CRLF peuvent être rejetées

#### Détecter les line endings

```bash
# Sur Windows (PowerShell)
Get-Content -Raw $env:USERPROFILE\.ssh\config | Format-Hex | Select-Object -First 5

# Chercher les octets :
# 0D 0A = CRLF (Windows)
# 0A = LF (Unix)
```

```bash
# Sur Linux
file ~/.ssh/authorized_keys
# Résultat attendu : "ASCII text" (pas "with CRLF line terminators")

# Ou avec cat -A
cat -A ~/.ssh/authorized_keys
# $ = fin de ligne LF (correct)
# ^M$ = CRLF (problématique)
```

#### Corriger les line endings

**Méthode 1 : Avec dos2unix (sur Linux)**

```bash
# Installer dos2unix
sudo apt install dos2unix  # Debian/Ubuntu
sudo yum install dos2unix  # RHEL/CentOS

# Convertir un fichier
dos2unix ~/.ssh/authorized_keys
dos2unix ~/.ssh/config

# Vérifier
file ~/.ssh/authorized_keys
```

**Méthode 2 : Avec sed (sur Linux)**

```bash
# Supprimer les retours chariot (CR)
sed -i 's/\r$//' ~/.ssh/authorized_keys
```

**Méthode 3 : Avec PowerShell (sur Windows avant l'envoi)**

```powershell
# Lire et réécrire avec LF uniquement
$content = Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub -Raw
$content = $content -replace "`r`n", "`n"
$content | Set-Content -NoNewline $env:USERPROFILE\.ssh\id_ed25519.pub
```

**Méthode 4 : Configurer Git pour gérer automatiquement**

```bash
# Configuration Git globale (sur Windows)
git config --global core.autocrlf true

# Pour le dossier .ssh spécifiquement
cd $env:USERPROFILE\.ssh
echo "* text eol=lf" > .gitattributes
```

> [!warning] Piège classique Si vous copiez-collez une clé publique depuis le Bloc-notes Windows vers un terminal Linux, des CRLF peuvent s'introduire. Utilisez toujours `cat` ou `type` avec redirection, ou un éditeur conscient des line endings comme VSCode.

#### Encodage des caractères

**Problème :** Les caractères spéciaux (accents, symboles) dans les noms d'utilisateurs, chemins ou commentaires de clés.

```bash
# Windows utilise généralement :
# - Console : CP850 ou CP1252 (encodages Windows)
# - PowerShell : UTF-16

# Linux utilise généralement :
# - UTF-8 partout
```

**Bonnes pratiques :**

1. **Utilisez uniquement ASCII pour les éléments critiques**
    
    - Noms d'utilisateurs SSH
    - Noms de fichiers de clés
    - Chemins dans la configuration
2. **Configurez PowerShell en UTF-8**
    

```powershell
# Dans votre profil PowerShell
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

3. **Vérifiez l'encodage des fichiers de configuration**

```powershell
# Sur Windows : utiliser un éditeur qui gère UTF-8
# VSCode, Notepad++, Sublime Text (pas le Bloc-notes classique)

# Vérifier dans VSCode : regarder en bas à droite "UTF-8" ou "UTF-8 with BOM"
# Préférer "UTF-8" sans BOM pour les fichiers de config SSH
```

#### Problèmes avec les clés publiques collées

**Symptôme :** La clé publique ne fonctionne pas après un copier-coller.

**Causes :**

- CRLF introduits par le presse-papier
- Sauts de ligne au milieu de la clé
- Caractères invisibles ajoutés

**Solution robuste :**

```bash
# Sur Windows : copier la clé dans le presse-papier
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | Set-Clipboard

# Sur Linux : nettoyer et ajouter en une ligne
# Méthode 1 : Coller puis nettoyer
vim ~/.ssh/authorized_keys
# Puis en mode commande :
# :%s/\r//g  (supprimer les CR)
# :wq

# Méthode 2 : Utiliser tr pour nettoyer le presse-papier
# (si vous collez depuis un partage de presse-papier VM/RDP)
xclip -o | tr -d '\r' >> ~/.ssh/authorized_keys
```

> [!example] Vérification d'une clé publique valide Une clé publique SSH valide :
> 
> - Tient sur **une seule ligne**
> - Commence par `ssh-ed25519`, `ssh-rsa`, `ecdsa-sha2-nistp256`, etc.
> - Contient une longue chaîne base64 sans espaces
> - Se termine optionnellement par un commentaire
> 
> ```
> ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGq... utilisateur@machine
> ```

#### Configuration d'éditeur pour SSH

Pour éviter ces problèmes, configurez votre éditeur correctement :

**VSCode :**

```json
// settings.json
{
    "files.eol": "\n",
    "files.encoding": "utf8",
    "[ssh-config]": {
        "files.eol": "\n"
    }
}
```

**Notepad++ :**

- Édition → Conversion du format de fin de ligne → Format Unix (LF)
- Encodage → Encoder en UTF-8 (sans BOM)

**Vim (sur Windows via Git Bash/WSL) :**

```vim
" Dans ~/.vimrc
set fileformat=unix
set encoding=utf-8
```

---

## 🎯 Récapitulatif des pièges courants

|Problème|Cause|Solution rapide|
|---|---|---|
|"Permission denied (publickey)"|Permissions Windows incorrectes|`icacls` pour réduire les ACL|
|Clé refusée côté Linux|`authorized_keys` trop permissif|`chmod 600 ~/.ssh/authorized_keys`|
|Caractères bizarres dans les clés|CRLF au lieu de LF|`dos2unix` ou `sed` sur le serveur|
|"Invalid format"|Format de clé incompatible|Régénérer en ED25519 ou convertir en PEM|
|Agent ne garde pas les clés|Service ssh-agent non démarré|`Start-Service ssh-agent`|
|Script ne s'exécute pas sur Linux|Line endings CRLF|Convertir en LF avant envoi|

> [!tip] Astuce de débogage Utilisez toujours `ssh -v` (ou `-vv`, `-vvv` pour plus de détails) pour diagnostiquer les problèmes de connexion :
> 
> ```bash
> ssh -vvv utilisateur@serveur-linux
> ```
> 
> Cela affichera chaque étape de la négociation et vous indiquera où ça bloque.

---

## 🔍 Checklist de validation

Avant de considérer votre configuration interopérable comme complète :

**Côté Windows (client) :**

- [ ] Clés générées avec algorithme moderne (ED25519 ou RSA 4096)
- [ ] Permissions restreintes sur les clés privées (ACL correctes)
- [ ] Fichier `config` utilise des chemins absolus ou relatifs à `~`
- [ ] Service `ssh-agent` configuré en démarrage automatique
- [ ] Line endings LF dans les fichiers de configuration
- [ ] Encodage UTF-8 sans BOM

**Côté Linux (serveur) :**

- [ ] `~/.ssh/` est en 700 (drwx------)
- [ ] `authorized_keys` est en 600 (-rw-------)
- [ ] Pas de CRLF dans `authorized_keys`
- [ ] Propriétaire correct des fichiers (utilisateur cible)
- [ ] SSHD configuré pour accepter l'authentification par clé
- [ ] Logs vérifiés (`/var/log/auth.log`) en cas de problème

**Test final :**

```bash
# Connexion sans mot de passe et sans erreur
ssh utilisateur@serveur-linux
```

Si cela fonctionne du premier coup, félicitations ! Votre configuration croisée est opérationnelle. 🎉