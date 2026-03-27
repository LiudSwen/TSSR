

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

## 🗂️ Localisation des fichiers de configuration

### Arborescence des fichiers OpenSSH sous Windows

Contrairement aux systèmes Unix/Linux où OpenSSH stocke ses fichiers dans `/etc/ssh/`, Windows utilise une structure différente :

```
C:\ProgramData\ssh\
├── sshd_config              # Configuration principale du serveur
├── ssh_host_ed25519_key     # Clé privée du serveur (Ed25519)
├── ssh_host_ed25519_key.pub # Clé publique du serveur
├── ssh_host_rsa_key         # Clé privée du serveur (RSA)
├── ssh_host_rsa_key.pub     # Clé publique du serveur
└── administrators_authorized_keys  # Clés autorisées pour les admins
```

> [!info] Pourquoi ProgramData ? Le dossier `C:\ProgramData\` est caché par défaut et contient les données d'applications partagées entre tous les utilisateurs. C'est l'équivalent Windows de `/etc/` sous Linux.

### Accéder aux fichiers de configuration

**Via l'Explorateur Windows :**

```powershell
# Ouvrir directement le dossier
explorer C:\ProgramData\ssh\
```

**Via PowerShell :**

```powershell
# Naviguer vers le dossier
cd C:\ProgramData\ssh\

# Lister le contenu
Get-ChildItem C:\ProgramData\ssh\
```

**Via l'invite de commandes (cmd) :**

```cmd
cd C:\ProgramData\ssh\
dir
```

> [!warning] Permissions requises Vous devez être **administrateur** pour modifier les fichiers de configuration. Faites un clic droit sur votre éditeur de texte et choisissez "Exécuter en tant qu'administrateur".

### Fichiers utilisateur

Les clés et configurations utilisateur se trouvent dans :

```
C:\Users\<VotreNom>\.ssh\
├── id_rsa              # Clé privée de l'utilisateur
├── id_rsa.pub          # Clé publique de l'utilisateur
├── known_hosts         # Empreintes des serveurs connus
├── config              # Configuration client SSH
└── authorized_keys     # Clés autorisées pour cet utilisateur
```

---

## 📝 Fichier sshd_config sous Windows

### Structure générale

Le fichier `sshd_config` sous Windows est similaire à sa version Linux, mais avec quelques spécificités. Voici sa structure :

```bash
# Exemple de sshd_config Windows par défaut

# Port d'écoute
Port 22

# Adresses d'écoute (0.0.0.0 = toutes les interfaces)
#ListenAddress 0.0.0.0
#ListenAddress ::

# Authentification par clé publique
PubkeyAuthentication yes

# Authentification par mot de passe
PasswordAuthentication yes

# Fichier des clés autorisées
AuthorizedKeysFile .ssh/authorized_keys

# Sous-système SFTP
Subsystem sftp sftp-server.exe

# Règle spécifique pour les administrateurs (Windows)
Match Group administrators
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

### Éditer le fichier de configuration

**Avec Notepad (mode administrateur) :**

```powershell
# Ouvrir avec Notepad en tant qu'admin
notepad C:\ProgramData\ssh\sshd_config
```

**Avec VS Code :**

```powershell
# Ouvrir avec VS Code
code C:\ProgramData\ssh\sshd_config
```

**Avec PowerShell ISE :**

```powershell
# Ouvrir avec PowerShell ISE
powershell_ise.exe C:\ProgramData\ssh\sshd_config
```

> [!tip] Sauvegarde avant modification Créez toujours une copie de sauvegarde avant de modifier la configuration :
> 
> ```powershell
> Copy-Item C:\ProgramData\ssh\sshd_config C:\ProgramData\ssh\sshd_config.backup
> ```

### Paramètres essentiels

|Paramètre|Description|Valeur par défaut|Recommandation|
|---|---|---|---|
|`Port`|Port d'écoute du serveur|22|22 (standard) ou port personnalisé|
|`PermitRootLogin`|Autoriser connexion root|N/A (pas de root sous Windows)|N/A|
|`PasswordAuthentication`|Autoriser mot de passe|yes|no (utiliser clés)|
|`PubkeyAuthentication`|Autoriser clés publiques|yes|yes|
|`PermitEmptyPasswords`|Autoriser mots de passe vides|no|no|
|`MaxAuthTries`|Tentatives d'authentification max|6|3|
|`MaxSessions`|Sessions simultanées max|10|10|

### Redémarrer le service après modification

Après toute modification de `sshd_config`, vous devez redémarrer le service :

```powershell
# Redémarrer le service OpenSSH
Restart-Service sshd

# Vérifier le statut
Get-Service sshd

# Voir les logs en cas de problème
Get-EventLog -LogName Application -Source OpenSSH* -Newest 10
```

> [!warning] Erreur de syntaxe Si le service ne démarre pas après modification, vérifiez la syntaxe du fichier. Une seule erreur peut empêcher le démarrage complet du serveur SSH.

---

## ⚙️ Paramètres spécifiques Windows

### La règle Match Group administrators

Windows intègre une règle spéciale pour les comptes administrateurs :

```bash
Match Group administrators
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

> [!info] Pourquoi cette règle ? Sous Windows, les comptes du groupe **Administrateurs** utilisent un fichier de clés centralisé différent des utilisateurs normaux. Cela permet de gérer centralement l'accès SSH des administrateurs.

**Conséquences pratiques :**

- **Utilisateurs normaux** : leurs clés doivent être dans `C:\Users\<nom>\.ssh\authorized_keys`
- **Administrateurs** : leurs clés doivent être dans `C:\ProgramData\ssh\administrators_authorized_keys`

### Permissions des fichiers sous Windows

Les permissions sont **critiques** pour la sécurité SSH. Les fichiers de clés doivent avoir des permissions strictes.

**Définir les permissions correctes :**

```powershell
# Pour le fichier administrators_authorized_keys
icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
```

**Explication de la commande :**

- `/inheritance:r` : supprime l'héritage des permissions
- `/grant "Administrators:F"` : donne le contrôle total aux administrateurs
- `/grant "SYSTEM:F"` : donne le contrôle total au système

> [!warning] Erreurs de permissions courantes Si vos clés ne fonctionnent pas, c'est souvent un problème de permissions. Les fichiers ne doivent être accessibles QUE par vous et le système.

**Vérifier les permissions actuelles :**

```powershell
icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys"
```

**Pour un utilisateur normal :**

```powershell
# Aller dans le dossier .ssh de l'utilisateur
cd C:\Users\<VotreNom>\.ssh

# Définir les permissions du fichier authorized_keys
icacls.exe "authorized_keys" /inheritance:r /grant:r "%USERNAME%:F" /grant "SYSTEM:F"
```

### Variable **PROGRAMDATA**

Dans le fichier `sshd_config`, vous verrez `__PROGRAMDATA__` :

```bash
AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

> [!info] Variable d'environnement `__PROGRAMDATA__` est automatiquement remplacé par `C:\ProgramData` par OpenSSH. C'est une variable spécifique à l'implémentation Windows d'OpenSSH.

### Chemin du sous-système SFTP

Sous Windows, le chemin vers le serveur SFTP diffère :

```bash
# Sous Linux
Subsystem sftp /usr/lib/openssh/sftp-server

# Sous Windows
Subsystem sftp sftp-server.exe
```

> [!tip] SFTP intégré Windows OpenSSH inclut `sftp-server.exe` dans le même répertoire que `sshd.exe`. Pas besoin de spécifier un chemin absolu.

### Logs et diagnostics

**Activer les logs détaillés :**

```bash
# Ajouter dans sshd_config
LogLevel DEBUG3
```

**Consulter les logs :**

```powershell
# Logs Windows Event Viewer
Get-EventLog -LogName Application -Source OpenSSH* -Newest 20

# Filtrer par type
Get-EventLog -LogName Application -Source OpenSSH* -EntryType Error -Newest 10
```

> [!warning] DEBUG3 en production Le niveau `DEBUG3` génère énormément de logs. Utilisez-le uniquement pour le débogage, puis repassez à `INFO` ou `VERBOSE` en production.

---

## 💻 Shell par défaut (PowerShell vs cmd)

### Comprendre le shell par défaut

Quand vous vous connectez en SSH à un serveur Windows, le système ouvre un **shell par défaut**. Par défaut, c'est généralement **cmd.exe** (l'invite de commandes), mais vous pouvez le changer pour **PowerShell**.

### Vérifier le shell actuel

```powershell
# Se connecter en SSH et voir quel shell s'ouvre
ssh utilisateur@serveur-windows

# Une fois connecté, vérifier
echo $env:COMSPEC  # Affiche le shell actif
```

### Changer le shell par défaut pour PowerShell

**Méthode 1 : Via le registre Windows**

```powershell
# Définir PowerShell comme shell par défaut
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
```

**Vérifier la clé de registre :**

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell
```

**Méthode 2 : Via une commande directe**

```powershell
# Version longue
Set-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name "DefaultShell" -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
```

> [!tip] PowerShell 7 Si vous avez installé PowerShell 7 (pwsh), vous pouvez l'utiliser comme shell :
> 
> ```powershell
> New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String -Force
> ```

### Différences entre cmd et PowerShell

|Caractéristique|cmd.exe|PowerShell|
|---|---|---|
|**Type**|Interpréteur de commandes|Shell orienté objet|
|**Syntaxe**|Commandes DOS classiques|Cmdlets modernes|
|**Scripting**|Fichiers `.bat`, `.cmd`|Fichiers `.ps1`|
|**Puissance**|Limité|Très puissant|
|**Administration**|Basique|Avancée|
|**Recommandation**|Compatibilité legacy|Utilisation moderne|

> [!example] Exemples de commandes
> 
> **Dans cmd :**
> 
> ```cmd
> dir
> cd C:\Windows
> ipconfig
> ```
> 
> **Dans PowerShell :**
> 
> ```powershell
> Get-ChildItem
> Set-Location C:\Windows
> Get-NetIPConfiguration
> ```

### Tester le shell par défaut

Après avoir changé le shell, **redémarrez le service SSH** puis testez :

```powershell
# Redémarrer le service
Restart-Service sshd

# Depuis une autre machine ou fenêtre
ssh utilisateur@votre-serveur-windows

# Une fois connecté, vérifier
$PSVersionTable  # Si PowerShell, affiche la version
```

### Forcer un shell spécifique à la connexion

Vous pouvez forcer l'utilisation d'un shell lors de la connexion :

```bash
# Forcer PowerShell
ssh utilisateur@serveur -t powershell

# Forcer cmd
ssh utilisateur@serveur -t cmd

# Forcer une commande spécifique
ssh utilisateur@serveur "Get-Process"
```

> [!info] Option -t L'option `-t` force l'allocation d'un pseudo-terminal, nécessaire pour les shells interactifs.

### Configuration dans sshd_config

Vous pouvez également définir le shell dans `sshd_config` :

```bash
# Ajouter cette ligne pour forcer PowerShell
ForceCommand powershell.exe -NoLogo -NoProfile
```

> [!warning] ForceCommand global `ForceCommand` s'applique à **toutes** les connexions. Soyez prudent, car cela peut limiter l'utilisation d'outils comme SFTP ou SCP.

**Alternative avec Match :**

```bash
# Appliquer uniquement pour un utilisateur spécifique
Match User alice
    ForceCommand powershell.exe -NoLogo -NoProfile
```

### Bonnes pratiques

> [!tip] Recommandations
> 
> 1. **Utilisez PowerShell** comme shell par défaut sur les systèmes modernes
> 2. **Gardez cmd** si vous avez besoin de compatibilité avec des scripts legacy
> 3. **Testez** toujours après un changement de configuration
> 4. **Documentez** le shell utilisé dans votre infrastructure
> 5. **Formez** vos équipes aux différences entre cmd et PowerShell

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> - **Chemin incorrect** : vérifiez que le chemin vers PowerShell ou cmd est exact
> - **Permissions** : assurez-vous que le service sshd a les droits sur le shell
> - **Oubli de redémarrage** : pensez toujours à redémarrer le service après modification
> - **Scripts incompatibles** : vos scripts `.bat` ne fonctionneront pas directement dans PowerShell

---

## 🎯 Récapitulatif

Vous savez maintenant :

- ✅ **Localiser** les fichiers de configuration OpenSSH sous Windows
- ✅ **Éditer** le fichier `sshd_config` avec les bonnes permissions
- ✅ **Comprendre** les paramètres spécifiques à Windows (Match Group administrators)
- ✅ **Gérer** les permissions des fichiers de clés avec `icacls`
- ✅ **Configurer** le shell par défaut (PowerShell vs cmd)
- ✅ **Diagnostiquer** les problèmes via les logs Windows

> [!success] Compétences acquises Vous maîtrisez maintenant la configuration du serveur OpenSSH sous Windows et pouvez l'adapter à vos besoins spécifiques.