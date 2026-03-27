

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

L'installation et la configuration correcte de VirtualBox CLI sont essentielles pour une utilisation efficace. Cette partie couvre l'installation sur différents systèmes d'exploitation, la configuration de l'environnement et la compréhension de la structure des fichiers VirtualBox.

> [!info] Pourquoi c'est important Une installation correcte garantit que `VBoxManage` est accessible depuis n'importe quel répertoire et que VirtualBox peut gérer correctement vos machines virtuelles. Une mauvaise configuration peut entraîner des erreurs difficiles à diagnostiquer.

---

## Installation de VirtualBox

### Installation sur Linux

#### Debian/Ubuntu

```bash
# Méthode 1 : Via les dépôts officiels VirtualBox (recommandé)
# Ajouter la clé GPG d'Oracle
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg

# Ajouter le dépôt VirtualBox
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

# Mettre à jour et installer
sudo apt update
sudo apt install virtualbox-7.0

# Installer le Extension Pack (optionnel mais recommandé)
# Télécharger depuis https://www.virtualbox.org/wiki/Downloads
sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-*.vbox-extpack
```

```bash
# Méthode 2 : Via les dépôts Ubuntu (version potentiellement obsolète)
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack
```

#### Fedora/RHEL/CentOS

```bash
# Ajouter le dépôt VirtualBox
sudo wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -P /etc/yum.repos.d

# Installer les dépendances
sudo dnf install binutils kernel-devel kernel-headers libgomp make patch gcc glibc-headers glibc-devel dkms

# Installer VirtualBox
sudo dnf install VirtualBox-7.0

# Reconstruire les modules du noyau
sudo /usr/lib/virtualbox/vboxdrv.sh setup
```

#### Arch Linux

```bash
# Installer VirtualBox et les modules du noyau
sudo pacman -S virtualbox virtualbox-host-modules-arch

# Charger les modules
sudo modprobe vboxdrv vboxnetadp vboxnetflt
```

> [!warning] Modules du noyau Sur Linux, VirtualBox nécessite des modules kernel. Après une mise à jour du noyau, vous devrez peut-être reconstruire ces modules avec `sudo /usr/lib/virtualbox/vboxdrv.sh setup` ou `sudo vboxconfig`.

### Installation sur macOS

```bash
# Méthode 1 : Téléchargement manuel
# 1. Télécharger le .dmg depuis https://www.virtualbox.org/wiki/Downloads
# 2. Double-cliquer sur le fichier .dmg
# 3. Suivre l'assistant d'installation
# 4. Autoriser l'extension système dans Préférences Système > Sécurité

# Méthode 2 : Via Homebrew (recommandé)
brew install --cask virtualbox

# Installer le Extension Pack
brew install --cask virtualbox-extension-pack
```

> [!warning] Autorisations système macOS Sur macOS, vous devez autoriser l'extension système d'Oracle dans **Préférences Système → Sécurité et confidentialité**. Un redémarrage peut être nécessaire.

> [!tip] Apple Silicon (M1/M2/M3) VirtualBox ne supporte pas nativement les processeurs Apple Silicon. Pour ces machines, considérez des alternatives comme UTM ou Parallels Desktop.

### Installation sur Windows

```powershell
# Méthode 1 : Téléchargement manuel (recommandé)
# 1. Télécharger l'installeur .exe depuis https://www.virtualbox.org/wiki/Downloads
# 2. Exécuter l'installeur en tant qu'administrateur
# 3. Suivre l'assistant d'installation
# 4. Accepter l'installation des pilotes réseau

# Méthode 2 : Via Chocolatey
choco install virtualbox

# Méthode 3 : Via winget
winget install Oracle.VirtualBox
```

> [!warning] Hyper-V et VirtualBox VirtualBox et Hyper-V (utilisé par WSL2, Docker Desktop) ne peuvent pas coexister activement. Vous devrez désactiver Hyper-V si vous voulez utiliser VirtualBox :
> 
> ```powershell
> # Désactiver Hyper-V (nécessite un redémarrage)
> bcdedit /set hypervisorlaunchtype off
> 
> # Réactiver Hyper-V
> bcdedit /set hypervisorlaunchtype auto
> ```

---

## Vérification de l'installation de VBoxManage

Après l'installation, il est crucial de vérifier que `VBoxManage` fonctionne correctement.

```bash
# Vérifier que VBoxManage est accessible
VBoxManage --version

# Exemple de sortie attendue :
# 7.0.12r159484

# Afficher l'aide générale
VBoxManage --help

# Afficher l'aide pour une commande spécifique
VBoxManage list --help
```

> [!example] Tests de base
> 
> ```bash
> # Lister toutes les VMs (devrait retourner une liste vide si c'est une nouvelle installation)
> VBoxManage list vms
> 
> # Afficher les informations système
> VBoxManage list systemproperties
> 
> # Vérifier les types d'OS supportés
> VBoxManage list ostypes
> ```

> [!warning] Commande introuvable Si vous obtenez "command not found" ou "VBoxManage n'est pas reconnu", cela signifie que le PATH n'est pas configuré correctement. Consultez la section suivante.

---

## Variables d'environnement et PATH

### Comprendre le PATH

La variable `PATH` indique au système d'exploitation où chercher les exécutables. Lorsque vous tapez `VBoxManage`, le système parcourt tous les répertoires listés dans `PATH` jusqu'à trouver l'exécutable.

```bash
# Afficher le PATH actuel (Linux/macOS)
echo $PATH

# Afficher le PATH actuel (Windows PowerShell)
$env:PATH

# Afficher le PATH actuel (Windows CMD)
echo %PATH%
```

### Configuration du PATH par OS

#### Linux

Le chemin par défaut de VBoxManage sur Linux est généralement `/usr/bin/VBoxManage`, qui est déjà dans le PATH.

```bash
# Vérifier l'emplacement de VBoxManage
which VBoxManage
# Sortie attendue : /usr/bin/VBoxManage

# Si VBoxManage n'est pas trouvé, l'ajouter temporairement au PATH
export PATH=$PATH:/usr/bin

# Pour rendre permanent (ajouter à ~/.bashrc, ~/.zshrc, ou ~/.profile)
echo 'export PATH=$PATH:/usr/bin' >> ~/.bashrc
source ~/.bashrc
```

#### macOS

Sur macOS, VirtualBox s'installe dans `/Applications/VirtualBox.app/Contents/MacOS/`.

```bash
# Vérifier l'emplacement
which VBoxManage
# Si introuvable, il peut être dans :
ls /Applications/VirtualBox.app/Contents/MacOS/VBoxManage

# Ajouter au PATH temporairement
export PATH=$PATH:/Applications/VirtualBox.app/Contents/MacOS

# Pour rendre permanent (bash)
echo 'export PATH=$PATH:/Applications/VirtualBox.app/Contents/MacOS' >> ~/.bash_profile
source ~/.bash_profile

# Pour rendre permanent (zsh - par défaut sur macOS récents)
echo 'export PATH=$PATH:/Applications/VirtualBox.app/Contents/MacOS' >> ~/.zshrc
source ~/.zshrc
```

#### Windows

Sur Windows, l'installeur ajoute normalement VirtualBox au PATH automatiquement. Le chemin par défaut est `C:\Program Files\Oracle\VirtualBox\`.

```powershell
# Vérifier l'emplacement (PowerShell)
where.exe VBoxManage

# Si introuvable, vérifier l'existence
Test-Path "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

# Ajouter au PATH pour la session actuelle (PowerShell)
$env:PATH += ";C:\Program Files\Oracle\VirtualBox"

# Ajouter au PATH de manière permanente (PowerShell en tant qu'admin)
[Environment]::SetEnvironmentVariable(
    "PATH",
    $env:PATH + ";C:\Program Files\Oracle\VirtualBox",
    [System.EnvironmentVariableTarget]::Machine
)
```

```cmd
REM Ajouter au PATH pour la session actuelle (CMD)
set PATH=%PATH%;C:\Program Files\Oracle\VirtualBox

REM Pour permanent, utiliser l'interface graphique :
REM Panneau de configuration → Système → Paramètres système avancés
REM → Variables d'environnement → PATH → Modifier
```

> [!tip] Méthode GUI Windows Pour modifier le PATH de manière permanente sur Windows via l'interface graphique :
> 
> 1. Clic droit sur "Ce PC" → Propriétés
> 2. Paramètres système avancés
> 3. Variables d'environnement
> 4. Double-cliquer sur "Path" dans les variables système
> 5. Nouveau → Ajouter `C:\Program Files\Oracle\VirtualBox`
> 6. OK → OK → OK
> 7. Redémarrer le terminal

### Variables d'environnement VirtualBox

VirtualBox utilise plusieurs variables d'environnement pour personnaliser son comportement.

|Variable|Description|Exemple de valeur|
|---|---|---|
|`VBOX_USER_HOME`|Change l'emplacement du répertoire de configuration VirtualBox|`/home/user/custom-vbox`|
|`VBOX_IPC_SOCKETID`|Identifiant pour la communication inter-processus|`user123`|
|`VBOX_INSTALL_PATH`|Chemin d'installation de VirtualBox (défini automatiquement)|`/usr/lib/virtualbox`|

```bash
# Exemple : Utiliser un répertoire de configuration personnalisé
export VBOX_USER_HOME=/home/user/custom-virtualbox
VBoxManage list vms  # Utilisera le nouveau répertoire

# Vérifier les variables VirtualBox actives
env | grep VBOX
```

> [!warning] VBOX_USER_HOME Modifier `VBOX_USER_HOME` change l'emplacement où VirtualBox cherche ses VMs et sa configuration. Toutes les VMs créées avec l'emplacement par défaut ne seront plus visibles si vous changez cette variable.

---

## Structure des répertoires VirtualBox

Comprendre où VirtualBox stocke ses fichiers est essentiel pour la gestion, la sauvegarde et le dépannage.

### Répertoire principal

Le répertoire principal VirtualBox contient la configuration globale et les informations sur toutes les VMs.

|OS|Emplacement par défaut|
|---|---|
|**Linux**|`~/.config/VirtualBox/` ou `~/.VirtualBox/`|
|**macOS**|`~/Library/VirtualBox/`|
|**Windows**|`%USERPROFILE%\.VirtualBox\` (généralement `C:\Users\VotreNom\.VirtualBox\`)|

```bash
# Linux/macOS - Lister le contenu
ls -la ~/.config/VirtualBox/
# ou
ls -la ~/.VirtualBox/

# Windows PowerShell
Get-ChildItem $env:USERPROFILE\.VirtualBox\ -Force
```

### Configuration globale

Le fichier `VirtualBox.xml` contient la configuration globale de VirtualBox.

```bash
# Emplacement du fichier de configuration
# Linux/macOS
~/.config/VirtualBox/VirtualBox.xml

# Windows
%USERPROFILE%\.VirtualBox\VirtualBox.xml

# Visualiser la configuration (Linux/macOS)
cat ~/.config/VirtualBox/VirtualBox.xml

# Visualiser la configuration (Windows PowerShell)
Get-Content $env:USERPROFILE\.VirtualBox\VirtualBox.xml
```

> [!info] Contenu de VirtualBox.xml Ce fichier XML contient :
> 
> - Le répertoire par défaut des machines virtuelles
> - Les paramètres globaux de l'interface
> - La liste des médias enregistrés (disques durs virtuels, ISO)
> - Les paramètres réseau par défaut

> [!warning] Ne pas éditer manuellement N'éditez jamais `VirtualBox.xml` manuellement pendant que VirtualBox est en cours d'exécution, cela pourrait corrompre votre configuration. Utilisez toujours `VBoxManage` pour modifier les paramètres.

### Répertoire des machines virtuelles

Par défaut, chaque VM est stockée dans son propre sous-répertoire.

```bash
# Répertoire par défaut des VMs
# Linux
~/VirtualBox VMs/

# macOS
~/VirtualBox VMs/

# Windows
%USERPROFILE%\VirtualBox VMs\

# Lister les VMs et leurs emplacements
VBoxManage list vms

# Afficher le répertoire par défaut configuré
VBoxManage list systemproperties | grep "Default machine folder"
```

Structure typique d'une VM :

```
~/VirtualBox VMs/
└── MaVM/
    ├── MaVM.vbox           # Fichier de configuration de la VM (XML)
    ├── MaVM.vbox-prev      # Sauvegarde de la configuration précédente
    ├── MaVM.vdi            # Disque dur virtuel principal
    ├── Snapshots/          # Répertoire des snapshots
    │   └── snapshot.vdi
    └── Logs/               # Fichiers de logs
        ├── VBox.log
        ├── VBox.log.1
        └── VBox.log.2
```

> [!tip] Modifier le répertoire par défaut
> 
> ```bash
> # Changer le répertoire par défaut des nouvelles VMs
> VBoxManage setproperty machinefolder /chemin/vers/nouveau/repertoire
> 
> # Cela n'affecte que les nouvelles VMs
> # Les VMs existantes restent à leur emplacement actuel
> ```

### Autres répertoires importants

#### Répertoire des extensions

```bash
# Emplacement des extension packs
# Linux
~/.config/VirtualBox/ExtensionPacks/

# macOS
~/Library/VirtualBox/ExtensionPacks/

# Windows
%USERPROFILE%\.VirtualBox\ExtensionPacks\

# Lister les extensions installées
VBoxManage list extpacks
```

#### Répertoire des logs

```bash
# Logs de chaque VM
~/VirtualBox VMs/<NomVM>/Logs/

# Log principal de VirtualBox (Linux/macOS)
~/.config/VirtualBox/VBoxSVC.log

# Log principal de VirtualBox (Windows)
%USERPROFILE%\.VirtualBox\VBoxSVC.log
```

> [!tip] Rotation des logs VirtualBox conserve automatiquement les 3 derniers fichiers de log pour chaque VM :
> 
> - `VBox.log` : log actuel
> - `VBox.log.1` : session précédente
> - `VBox.log.2` : deux sessions en arrière

#### Répertoire des snapshots

```bash
# Par défaut, dans le répertoire de chaque VM
~/VirtualBox VMs/<NomVM>/Snapshots/

# Lister tous les snapshots d'une VM
VBoxManage snapshot "NomVM" list

# Afficher l'emplacement des snapshots
VBoxManage showvminfo "NomVM" --details | grep -i snapshot
```

#### Répertoire des disques virtuels

Les disques virtuels peuvent être stockés n'importe où, mais par défaut ils sont dans le répertoire de la VM.

```bash
# Lister tous les disques virtuels enregistrés
VBoxManage list hdds

# Afficher les détails d'un disque
VBoxManage showmediuminfo disk /chemin/vers/disque.vdi
```

---

## Pièges courants et bonnes pratiques

### Pièges à éviter

> [!warning] Espace disque insuffisant VirtualBox ne peut pas fonctionner correctement si le disque est plein. Les disques virtuels dynamiques peuvent croître rapidement. Vérifiez régulièrement l'espace disponible.

> [!warning] Déplacement manuel des VMs Ne déplacez jamais manuellement les fichiers d'une VM avec l'explorateur de fichiers. Utilisez `VBoxManage clonevm` ou `VBoxManage movevm` (VirtualBox 7.0+) pour déplacer correctement une VM.

> [!warning] Chemins avec espaces Sur Windows, utilisez des guillemets pour les chemins contenant des espaces :
> 
> ```powershell
> VBoxManage startvm "Ma VM Windows"
> # et non :
> VBoxManage startvm Ma VM Windows  # ERREUR
> ```

> [!warning] Permissions insuffisantes Sur Linux, assurez-vous que votre utilisateur fait partie du groupe `vboxusers` :
> 
> ```bash
> # Ajouter l'utilisateur au groupe
> sudo usermod -aG vboxusers $USER
> 
> # Se déconnecter et reconnecter pour appliquer
> ```

### Bonnes pratiques

> [!tip] Sauvegardes régulières Sauvegardez régulièrement :
> 
> - Le fichier `VirtualBox.xml` (configuration globale)
> - Les fichiers `.vbox` de chaque VM (configuration de la VM)
> - Les disques virtuels `.vdi` ou utilisez les snapshots
> 
> ```bash
> # Exemple de sauvegarde simple
> tar -czf vbox-backup-$(date +%Y%m%d).tar.gz ~/.config/VirtualBox ~/VirtualBox\ VMs/
> ```

> [!tip] Organisation des VMs
> 
> - Utilisez des noms de VM descriptifs et sans espaces
> - Créez une structure de répertoires logique si vous avez beaucoup de VMs
> - Documentez vos VMs avec des descriptions : `VBoxManage modifyvm "MaVM" --description "Ubuntu 22.04 - Serveur Web"`

> [!tip] Surveillance de l'espace disque
> 
> ```bash
> # Vérifier la taille de tous les disques virtuels
> VBoxManage list hdds | grep -E "(Location|Capacity)"
> 
> # Afficher l'espace utilisé par chaque VM
> du -sh ~/VirtualBox\ VMs/*/
> ```

> [!tip] Nettoyage régulier
> 
> ```bash
> # Supprimer les médias inaccessibles
> VBoxManage list hdds | grep "inaccessible" -B 1 -A 5
> 
> # Compacter un disque dynamique pour récupérer de l'espace
> VBoxManage modifymedium disk /chemin/vers/disque.vdi --compact
> ```

> [!tip] Variables d'environnement dans les scripts Si vous écrivez des scripts utilisant VBoxManage, définissez explicitement le PATH :
> 
> ```bash
> #!/bin/bash
> # Assurer que VBoxManage est accessible
> export PATH=$PATH:/usr/bin:/usr/local/bin
> 
> # Ou utiliser le chemin complet
> /usr/bin/VBoxManage list vms
> ```

---

**Résumé** : L'installation et la configuration correctes de VirtualBox CLI garantissent un fonctionnement optimal. Assurez-vous que `VBoxManage` est accessible via le PATH, comprenez la structure des répertoires VirtualBox, et suivez les bonnes pratiques pour éviter les problèmes courants. Une fois ces bases maîtrisées, vous êtes prêt à créer et gérer vos machines virtuelles efficacement.