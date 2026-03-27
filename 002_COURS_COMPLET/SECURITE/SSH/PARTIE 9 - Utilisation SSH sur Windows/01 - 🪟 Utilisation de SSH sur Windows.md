

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

## Introduction au client SSH natif

Depuis **Windows 10 version 1809** (octobre 2018) et **Windows Server 2019**, Microsoft intègre nativement OpenSSH dans Windows. Il n'est donc plus nécessaire d'installer des outils tiers comme PuTTY pour se connecter en SSH.

> [!info] Composants OpenSSH sur Windows Windows inclut deux composants OpenSSH :
> 
> - **OpenSSH Client** : pour se connecter à des serveurs distants (installé par défaut)
> - **OpenSSH Server** : pour transformer Windows en serveur SSH (optionnel)

### Vérification de l'installation

Pour vérifier si le client SSH est installé :

```bash
# Vérifier la version du client SSH
ssh -V

# Résultat attendu (exemple)
# OpenSSH_for_Windows_8.1p1, LibreSSL 3.0.2
```

> [!warning] Client SSH non installé ? Si la commande `ssh` n'est pas reconnue, vous devez activer le client SSH :
> 
> - **Paramètres** → **Applications** → **Fonctionnalités facultatives**
> - Cliquer sur **Ajouter une fonctionnalité**
> - Rechercher et installer **Client OpenSSH**

---

## Utilisation depuis PowerShell

PowerShell est l'interface en ligne de commande moderne de Windows et offre la meilleure expérience pour utiliser SSH.

### Connexion SSH de base

```bash
# Syntaxe minimale
ssh utilisateur@hote

# Exemple concret
ssh admin@192.168.1.100
```

> [!example] Première connexion Lors de votre première connexion à un serveur, SSH demande de vérifier l'empreinte de l'hôte :
> 
> ```
> The authenticity of host '192.168.1.100 (192.168.1.100)' can't be established.
> ECDSA key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
> Are you sure you want to continue connecting (yes/no/[fingerprint])?
> ```
> 
> Tapez `yes` pour ajouter l'hôte aux hôtes connus.

### Connexion avec port personnalisé

```bash
# Si le serveur SSH n'utilise pas le port 22 par défaut
ssh -p 2222 utilisateur@hote

# Exemple
ssh -p 2222 admin@monserveur.com
```

### Connexion avec clé privée

```bash
# Spécifier une clé privée spécifique
ssh -i C:\Users\VotreNom\.ssh\ma_cle_privee utilisateur@hote

# Exemple avec chemin Windows
ssh -i C:\Users\Jean\.ssh\id_rsa_production admin@prod.example.com
```

> [!tip] Chemins Windows dans PowerShell Dans PowerShell, vous pouvez utiliser :
> 
> - Les **antislashs** : `C:\Users\...`
> - Les **slashs** : `C:/Users/...` (style Unix, souvent plus pratique)
> - Les **chemins relatifs** : `~/.ssh/id_rsa` (~ représente votre dossier utilisateur)

### Variables d'environnement utiles

PowerShell permet d'utiliser des variables pour simplifier les connexions répétitives :

```powershell
# Définir des variables pour une connexion fréquente
$serveur = "192.168.1.100"
$user = "admin"

# Se connecter en utilisant les variables
ssh $user@$serveur

# Ou créer un alias personnalisé
function Connect-Production {
    ssh admin@prod.example.com
}

# Utilisation
Connect-Production
```

### Historique des commandes

PowerShell conserve un historique complet de vos commandes :

```powershell
# Chercher dans l'historique avec Ctrl+R
# Ou utiliser Get-History

# Afficher les 10 dernières commandes SSH
Get-History | Where-Object {$_.CommandLine -like "*ssh*"} | Select-Object -Last 10
```

> [!tip] Astuce PowerShell Utilisez `Ctrl + R` pour rechercher dans l'historique de manière interactive. Commencez à taper "ssh" et PowerShell vous proposera les commandes précédentes contenant "ssh".

---

## Utilisation depuis CMD

L'invite de commandes classique (CMD) supporte également le client SSH natif, bien qu'avec moins de fonctionnalités avancées que PowerShell.

### Connexion de base dans CMD

```bash
# Identique à PowerShell pour les commandes de base
ssh utilisateur@hote

# Exemple
ssh root@192.168.1.50
```

### Différences avec PowerShell

|Aspect|PowerShell|CMD|
|---|---|---|
|**Gestion des chemins**|Supporte `/` et `\`, comprend `~`|Nécessite `\`, ne comprend pas `~`|
|**Variables**|Variables avancées `$variable`|Variables basiques `%variable%`|
|**Copier-coller**|Ctrl+C / Ctrl+V moderne|Clic droit uniquement (par défaut)|
|**Historique**|Historique persistant et recherchable|Historique limité à la session|
|**Couleurs**|Colorisation riche|Colorisation limitée|

### Spécificités CMD

```bash
# Dans CMD, utiliser le chemin complet Windows avec antislashs
ssh -i C:\Users\Jean\.ssh\id_rsa admin@server.com

# Les variables d'environnement utilisent %
ssh %USERNAME%@192.168.1.100

# Le tilde (~) ne fonctionne PAS dans CMD
# ❌ ssh -i ~/.ssh/id_rsa user@host
# ✅ ssh -i %USERPROFILE%\.ssh\id_rsa user@host
```

> [!warning] Limitations de CMD CMD est l'ancienne invite de commandes et ne bénéficie pas des améliorations modernes de PowerShell. Il est recommandé d'utiliser PowerShell ou Windows Terminal pour une meilleure expérience SSH.

### Activation du copier-coller dans CMD

Par défaut, CMD n'utilise pas Ctrl+C/Ctrl+V. Pour l'activer :

```bash
# Clic droit sur la barre de titre → Propriétés → Options
# Cocher "Utiliser Ctrl+Maj+C/V pour copier/coller"
```

---

## Syntaxe et options complètes

### Syntaxe générale

```bash
ssh [options] [utilisateur@]hote [commande]
```

### Options principales

|Option|Description|Exemple|
|---|---|---|
|`-p port`|Spécifier un port non standard|`ssh -p 2222 user@host`|
|`-i fichier_clé`|Utiliser une clé privée spécifique|`ssh -i ~/.ssh/ma_cle user@host`|
|`-l utilisateur`|Spécifier le nom d'utilisateur|`ssh -l admin host`|
|`-v`|Mode verbeux (debug)|`ssh -v user@host`|
|`-vv` ou `-vvv`|Mode très verbeux (debug détaillé)|`ssh -vvv user@host`|
|`-4`|Forcer IPv4 uniquement|`ssh -4 user@host`|
|`-6`|Forcer IPv6 uniquement|`ssh -6 user@host`|
|`-C`|Activer la compression|`ssh -C user@host`|
|`-N`|Ne pas exécuter de commande distante|`ssh -N -L 8080:localhost:80 user@host`|
|`-f`|Passer en arrière-plan après connexion|`ssh -f user@host`|
|`-T`|Désactiver l'allocation de pseudo-terminal|`ssh -T git@github.com`|
|`-o option`|Spécifier une option de configuration|`ssh -o "StrictHostKeyChecking=no" user@host`|

### Exemples d'utilisation avancée

#### Mode debug pour diagnostiquer les problèmes

```bash
# Afficher les détails de la connexion (utile pour débugger)
ssh -v admin@192.168.1.100

# Debug très détaillé (pour les problèmes complexes)
ssh -vvv admin@192.168.1.100
```

> [!example] Sortie du mode verbeux Le mode verbeux affiche :
> 
> - La lecture des fichiers de configuration
> - La tentative de connexion et le port utilisé
> - L'échange de clés cryptographiques
> - L'authentification (clé ou mot de passe)
> - La création du tunnel sécurisé

#### Exécution de commande distante

```bash
# Exécuter une commande sans ouvrir de session interactive
ssh user@host "ls -la /var/www"

# Exécuter plusieurs commandes
ssh user@host "cd /var/www && ls -la && pwd"

# Capturer le résultat dans une variable (PowerShell)
$result = ssh user@host "cat /etc/hostname"
```

#### Compression pour connexions lentes

```bash
# Activer la compression (utile pour connexions internet lentes)
ssh -C user@host

# Combiner avec d'autres options
ssh -C -p 2222 user@host
```

#### Ignorer la vérification de l'hôte (usage temporaire)

```bash
# Pour des tests uniquement - NON RECOMMANDÉ en production
ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" user@host
```

> [!warning] Sécurité Désactiver `StrictHostKeyChecking` expose à des attaques man-in-the-middle. Ne l'utilisez que pour des tests en environnement contrôlé.

### Options de configuration via `-o`

```bash
# Définir un timeout de connexion
ssh -o "ConnectTimeout=10" user@host

# Utiliser une méthode d'authentification spécifique
ssh -o "PreferredAuthentications=publickey" user@host

# Désactiver le forwarding X11
ssh -o "ForwardX11=no" user@host

# Combiner plusieurs options
ssh -o "ConnectTimeout=10" -o "ServerAliveInterval=60" user@host
```

### Pièges courants

> [!warning] Erreur : Permission denied (publickey) Cette erreur signifie que l'authentification par clé a échoué. Vérifiez :
> 
> - Que la clé privée est correcte (`-i chemin/vers/clé`)
> - Que les permissions de la clé sont correctes (voir la partie sur la gestion des clés)
> - Que la clé publique correspondante est bien sur le serveur

> [!warning] Erreur : Connection refused Le serveur refuse la connexion. Causes possibles :
> 
> - Le service SSH n'est pas démarré sur le serveur
> - Le port SSH est incorrect (essayez avec `-p` si ce n'est pas le 22)
> - Un firewall bloque la connexion

> [!warning] Erreur : Connection timed out La connexion expire sans réponse. Causes possibles :
> 
> - L'adresse IP ou le nom d'hôte est incorrect
> - Le serveur est inaccessible (éteint, réseau coupé)
> - Un firewall bloque les paquets (pas de réponse)

---

## Windows Terminal

**Windows Terminal** est l'application terminal moderne de Microsoft, disponible sur Windows 10/11. Elle offre une expérience bien supérieure à PowerShell ou CMD traditionnels.

### Avantages de Windows Terminal

- **Interface à onglets** : gérer plusieurs sessions SSH simultanément
- **Profils personnalisables** : créer des profils pour vos serveurs fréquents
- **Support Unicode complet** : affichage correct des caractères spéciaux
- **Raccourcis clavier** : navigation rapide entre onglets et panneaux
- **Thèmes et personnalisation** : apparence moderne et configurable
- **Copier-coller moderne** : Ctrl+C / Ctrl+V fonctionne naturellement

### Installation

Windows Terminal est installé par défaut sur Windows 11. Pour Windows 10 :

```powershell
# Installation via winget (gestionnaire de paquets Windows)
winget install Microsoft.WindowsTerminal

# Ou télécharger depuis le Microsoft Store
```

### Utilisation de SSH dans Windows Terminal

```bash
# Ouvrir Windows Terminal et lancer SSH normalement
ssh user@host

# Ou depuis le menu : Ctrl+Maj+T puis sélectionner PowerShell
```

### Création de profils SSH personnalisés

Vous pouvez créer des profils pour vos connexions SSH fréquentes :

1. Ouvrir Windows Terminal
2. Aller dans **Paramètres** (Ctrl+,)
3. Cliquer sur **Ajouter un nouveau profil**
4. Configurer le profil :

```json
{
    "name": "Serveur Production",
    "commandline": "ssh admin@prod.example.com",
    "icon": "🖥️",
    "startingDirectory": "%USERPROFILE%",
    "colorScheme": "One Half Dark"
}
```

> [!tip] Profils personnalisés avancés Vous pouvez créer des profils avec :
> 
> - Des **icônes personnalisées** (emoji ou chemin vers une image)
> - Des **schémas de couleurs** différents par serveur
> - Des **commandes de démarrage** automatiques
> - Des **répertoires de travail** spécifiques

### Raccourcis clavier utiles

|Raccourci|Action|
|---|---|
|`Ctrl + Maj + T`|Nouvel onglet (profil par défaut)|
|`Ctrl + Maj + 1-9`|Ouvrir un profil spécifique|
|`Ctrl + Maj + D`|Dupliquer l'onglet actuel|
|`Ctrl + Tab`|Onglet suivant|
|`Ctrl + Maj + Tab`|Onglet précédent|
|`Ctrl + Maj + W`|Fermer l'onglet actuel|
|`Alt + Maj + +`|Diviser le volet horizontalement|
|`Alt + Maj + -`|Diviser le volet verticalement|
|`Alt + ↑↓←→`|Naviguer entre les volets|
|`Ctrl + Maj + F`|Rechercher dans le terminal|

### Diviser les volets pour plusieurs connexions SSH

Windows Terminal permet de diviser la fenêtre en plusieurs volets :

```bash
# Exemple d'utilisation : surveiller plusieurs serveurs simultanément
# Volet 1 : ssh admin@serveur1.com
# Volet 2 : ssh admin@serveur2.com
# Volet 3 : ssh admin@serveur3.com
```

> [!example] Cas d'usage : monitoring multi-serveurs
> 
> 1. Ouvrir Windows Terminal
> 2. Connexion au premier serveur : `ssh admin@web1.com`
> 3. `Alt + Maj + +` pour créer un nouveau volet
> 4. Connexion au second serveur : `ssh admin@db1.com`
> 5. Répéter pour chaque serveur à surveiller
> 6. Utiliser `Alt + Flèches` pour naviguer entre les volets

### Configuration du fichier settings.json

Pour des personnalisations avancées, éditer le fichier `settings.json` :

```json
{
    "profiles": {
        "list": [
            {
                "name": "Production SSH",
                "commandline": "powershell.exe -NoExit -Command ssh admin@prod.example.com",
                "icon": "🔴",
                "colorScheme": "Campbell",
                "fontSize": 11,
                "fontFace": "Cascadia Code"
            },
            {
                "name": "Dev SSH",
                "commandline": "powershell.exe -NoExit -Command ssh dev@dev.example.com",
                "icon": "🟢",
                "colorScheme": "One Half Dark"
            }
        ]
    },
    "schemes": [],
    "actions": [
        {
            "command": "find",
            "keys": "ctrl+shift+f"
        }
    ]
}
```

### Intégration avec SSH Config

Windows Terminal fonctionne parfaitement avec le fichier de configuration SSH (`~/.ssh/config`). Si vous avez défini des alias dans ce fichier, vous pouvez les utiliser directement :

```bash
# Dans Windows Terminal, si vous avez configuré un alias "prod" dans ~/.ssh/config
ssh prod

# Ou créer un profil Windows Terminal qui utilise cet alias
# "commandline": "ssh prod"
```

> [!tip] Meilleures pratiques Windows Terminal + SSH
> 
> - **Profils par environnement** : créez des profils avec des couleurs différentes pour production (rouge), staging (orange), développement (vert)
> - **Utilisez des icônes** : les emoji ou icônes facilitent l'identification rapide des onglets
> - **Raccourcis dédiés** : assignez `Ctrl+Maj+1` à production, `Ctrl+Maj+2` à staging, etc.
> - **Volets persistants** : gardez des sessions SSH ouvertes dans différents volets pour surveiller logs et métriques

---

## 🎯 Bonnes pratiques générales

### Utiliser Windows Terminal pour SSH

> [!tip] Recommandation Privilégiez **Windows Terminal** plutôt que PowerShell ou CMD standalone pour bénéficier :
> 
> - D'une meilleure gestion des onglets
> - De profils SSH personnalisés
> - D'une expérience utilisateur moderne

### Sécuriser vos connexions SSH

```bash
# Toujours vérifier l'empreinte de l'hôte lors de la première connexion
# Utiliser l'authentification par clé plutôt que par mot de passe
# Utiliser des mots de passe forts pour vos clés privées
```

### Organiser vos clés SSH

```bash
# Structure recommandée du dossier .ssh
C:\Users\VotreNom\.ssh\
├── id_rsa              # Clé privée par défaut
├── id_rsa.pub          # Clé publique par défaut
├── id_rsa_prod         # Clé pour la production
├── id_rsa_prod.pub
├── config              # Fichier de configuration SSH
└── known_hosts         # Empreintes des hôtes connus
```

### Utiliser le fichier de configuration SSH

Le fichier `~/.ssh/config` simplifie grandement les connexions répétitives :

```bash
# Contenu de C:\Users\VotreNom\.ssh\config
Host prod
    HostName prod.example.com
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_rsa_prod

Host dev
    HostName 192.168.1.100
    User developer
    IdentityFile ~/.ssh/id_rsa_dev

# Utilisation simplifiée
ssh prod  # Au lieu de : ssh -p 2222 -i ~/.ssh/id_rsa_prod admin@prod.example.com
ssh dev   # Au lieu de : ssh -i ~/.ssh/id_rsa_dev developer@192.168.1.100
```

---

## 🔍 Résumé des commandes essentielles

```bash
# Connexion de base
ssh utilisateur@hote

# Connexion avec port personnalisé
ssh -p 2222 utilisateur@hote

# Connexion avec clé privée
ssh -i ~/.ssh/ma_cle utilisateur@hote

# Mode debug
ssh -v utilisateur@hote

# Exécuter une commande distante
ssh utilisateur@hote "commande"

# Vérifier la version SSH
ssh -V
```

> [!tip] Astuce finale Combinez Windows Terminal avec des profils SSH personnalisés et un fichier `~/.ssh/config` bien configuré pour transformer SSH sur Windows en une expérience aussi fluide que sur Linux/macOS !