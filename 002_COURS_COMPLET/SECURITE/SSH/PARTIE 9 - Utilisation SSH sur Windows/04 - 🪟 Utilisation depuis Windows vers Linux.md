

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

## 🔧 Configuration du client SSH

### OpenSSH sur Windows

Depuis Windows 10 (1809) et Windows 11, OpenSSH est intégré nativement au système.

> [!info] Vérification de l'installation Pour vérifier si OpenSSH est installé :
> 
> ```powershell
> ssh -V
> ```
> 
> Vous devriez voir la version d'OpenSSH affichée (ex: `OpenSSH_for_Windows_8.1p1`)

#### Installation d'OpenSSH (si nécessaire)

Si OpenSSH n'est pas installé sur votre système :

```powershell
# Via PowerShell en tant qu'administrateur
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Vérifier l'installation
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
```

### Fichier de configuration SSH

Le fichier de configuration SSH sur Windows se trouve dans votre profil utilisateur.

**Emplacement :** `C:\Users\VotreNom\.ssh\config`

> [!example] Structure du fichier config
> 
> ```bash
> # Connexion à un serveur avec alias
> Host monserveur
>     HostName 192.168.1.100
>     User admin
>     Port 22
>     IdentityFile C:\Users\VotreNom\.ssh\id_rsa
> 
> # Connexion avec des options spécifiques
> Host prod-server
>     HostName prod.example.com
>     User deployer
>     Port 2222
>     IdentityFile C:\Users\VotreNom\.ssh\prod_key
>     ServerAliveInterval 60
>     ServerAliveCountMax 3
> 
> # Configuration par défaut pour tous les hôtes
> Host *
>     ServerAliveInterval 120
>     ServerAliveCountMax 3
>     Compression yes
> ```

#### Paramètres de configuration importants

|Paramètre|Description|Exemple|
|---|---|---|
|`Host`|Alias pour la connexion|`Host monserveur`|
|`HostName`|Adresse IP ou nom de domaine|`HostName 192.168.1.100`|
|`User`|Nom d'utilisateur par défaut|`User admin`|
|`Port`|Port SSH (22 par défaut)|`Port 2222`|
|`IdentityFile`|Chemin vers la clé privée|`IdentityFile ~/.ssh/id_rsa`|
|`ServerAliveInterval`|Envoie un signal toutes les X secondes|`ServerAliveInterval 60`|
|`ServerAliveCountMax`|Nombre de tentatives avant déconnexion|`ServerAliveCountMax 3`|
|`Compression`|Active la compression des données|`Compression yes`|

> [!tip] Utilisation des alias Une fois configuré, vous pouvez simplement taper :
> 
> ```bash
> ssh monserveur
> ```
> 
> Au lieu de :
> 
> ```bash
> ssh admin@192.168.1.100
> ```

### Connexion basique

```bash
# Syntaxe standard
ssh utilisateur@adresse_ip

# Exemples
ssh root@192.168.1.100
ssh admin@server.example.com

# Spécifier un port différent
ssh -p 2222 utilisateur@adresse_ip

# Connexion avec exécution de commande
ssh utilisateur@adresse_ip 'ls -la /home'

# Connexion avec transfert X11 (applications graphiques)
ssh -X utilisateur@adresse_ip
```

> [!warning] Première connexion Lors de votre première connexion à un serveur, SSH vous demandera de confirmer l'empreinte de la clé du serveur :
> 
> ```
> The authenticity of host '192.168.1.100' can't be established.
> ECDSA key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
> Are you sure you want to continue connecting (yes/no/[fingerprint])?
> ```
> 
> Tapez `yes` pour accepter et ajouter le serveur aux hôtes connus.

---

## 🔑 Gestion des clés SSH

### Génération de clés SSH

Les clés SSH offrent une authentification plus sécurisée que les mots de passe.

#### Création d'une paire de clés

```bash
# Générer une clé RSA (recommandé : 4096 bits)
ssh-keygen -t rsa -b 4096 -C "votre_email@example.com"

# Générer une clé Ed25519 (plus moderne et sécurisée)
ssh-keygen -t ed25519 -C "votre_email@example.com"

# Spécifier un nom de fichier personnalisé
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ma_cle_perso -C "description"
```

> [!info] Types de clés
> 
> - **RSA** : Le plus universel, compatible avec tous les systèmes (4096 bits recommandé)
> - **Ed25519** : Plus moderne, plus rapide, plus sécurisé, mais peut ne pas être supporté par des systèmes anciens
> - **ECDSA** : Bon compromis, mais Ed25519 est généralement préféré

**Processus interactif :**

```bash
PS C:\Users\VotreNom> ssh-keygen -t rsa -b 4096 -C "votre@email.com"
Generating public/private rsa key pair.
Enter file in which to save the key (C:\Users\VotreNom/.ssh/id_rsa): [Entrée]
Enter passphrase (empty for no passphrase): [Votre phrase secrète]
Enter same passphrase again: [Répéter la phrase secrète]
Your identification has been saved in C:\Users\VotreNom/.ssh/id_rsa
Your public key has been saved in C:\Users\VotreNom/.ssh/id_rsa.pub
```

> [!tip] Passphrase (phrase secrète)
> 
> - Ajoute une couche de sécurité supplémentaire
> - Même si quelqu'un vole votre clé privée, il ne pourra pas l'utiliser sans la passphrase
> - Utilisez une phrase longue et mémorable plutôt qu'un mot de passe court

### Structure des clés

Après génération, vous obtenez deux fichiers :

```
C:\Users\VotreNom\.ssh\
├── id_rsa          # Clé PRIVÉE (à ne JAMAIS partager)
└── id_rsa.pub      # Clé PUBLIQUE (à copier sur les serveurs)
```

> [!warning] Sécurité de la clé privée
> 
> - **JAMAIS** envoyer votre clé privée par email ou messagerie
> - **JAMAIS** la stocker dans un dépôt Git public
> - **TOUJOURS** la protéger avec une passphrase
> - Permissions appropriées (lecture/écriture uniquement pour vous)

### Copie de la clé publique sur le serveur

#### Méthode 1 : ssh-copy-id (si disponible)

```bash
# Copie automatique de votre clé publique
ssh-copy-id utilisateur@adresse_ip

# Avec un port personnalisé
ssh-copy-id -p 2222 utilisateur@adresse_ip

# Spécifier une clé particulière
ssh-copy-id -i ~/.ssh/ma_cle.pub utilisateur@adresse_ip
```

#### Méthode 2 : Manuelle (si ssh-copy-id n'est pas disponible)

```powershell
# Lire le contenu de votre clé publique
type C:\Users\VotreNom\.ssh\id_rsa.pub | ssh utilisateur@adresse_ip "cat >> ~/.ssh/authorized_keys"
```

Ou manuellement :

1. Afficher votre clé publique :
    
    ```powershell
    type C:\Users\VotreNom\.ssh\id_rsa.pub
    ```
    
2. Se connecter au serveur avec mot de passe :
    
    ```bash
    ssh utilisateur@adresse_ip
    ```
    
3. Sur le serveur, ajouter la clé :
    
    ```bash
    # Créer le dossier .ssh si nécessaire
    mkdir -p ~/.ssh
    
    # Ajouter la clé publique
    echo "votre_clé_publique_copiée" >> ~/.ssh/authorized_keys
    
    # Définir les permissions correctes
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    ```
    

### Gestion de plusieurs clés

Lorsque vous avez plusieurs clés SSH pour différents serveurs :

> [!example] Configuration multi-clés
> 
> ```bash
> # Dans C:\Users\VotreNom\.ssh\config
> 
> # Serveur de production
> Host prod
>     HostName prod.example.com
>     User deployer
>     IdentityFile C:\Users\VotreNom\.ssh\prod_rsa
>     IdentitiesOnly yes
> 
> # Serveur de développement
> Host dev
>     HostName dev.example.com
>     User developer
>     IdentityFile C:\Users\VotreNom\.ssh\dev_rsa
>     IdentitiesOnly yes
> 
> # GitHub
> Host github.com
>     User git
>     IdentityFile C:\Users\VotreNom\.ssh\github_rsa
>     IdentitiesOnly yes
> ```

> [!tip] Option IdentitiesOnly `IdentitiesOnly yes` force SSH à utiliser uniquement la clé spécifiée, évitant les tentatives avec d'autres clés qui pourraient bloquer l'authentification.

### Agent SSH (ssh-agent)

L'agent SSH stocke vos clés déchiffrées en mémoire pour éviter de retaper la passphrase à chaque connexion.

#### Démarrage de l'agent SSH sur Windows

```powershell
# Démarrer le service ssh-agent
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent

# Vérifier le statut
Get-Service ssh-agent
```

#### Ajout de clés à l'agent

```bash
# Ajouter votre clé par défaut
ssh-add

# Ajouter une clé spécifique
ssh-add C:\Users\VotreNom\.ssh\ma_cle_privee

# Lister les clés chargées
ssh-add -l

# Supprimer toutes les clés de l'agent
ssh-add -D

# Supprimer une clé spécifique
ssh-add -d C:\Users\VotreNom\.ssh\ma_cle_privee
```

> [!tip] Persistance de l'agent Sur Windows, l'agent SSH peut ne pas persister entre les sessions. Pour une expérience plus fluide, configurez le service pour démarrer automatiquement comme montré ci-dessus.

### Vérification et test des clés

```bash
# Tester la connexion SSH
ssh -T git@github.com  # Pour GitHub
ssh -T utilisateur@votreserveur

# Tester avec une clé spécifique
ssh -i C:\Users\VotreNom\.ssh\cle_test utilisateur@serveur

# Mode verbeux pour déboguer les problèmes d'authentification
ssh -v utilisateur@serveur      # Verbeux
ssh -vv utilisateur@serveur     # Très verbeux
ssh -vvv utilisateur@serveur    # Extrêmement verbeux
```

---

## 📁 Transfert de fichiers

### SCP (Secure Copy)

SCP permet de copier des fichiers de manière sécurisée via SSH.

#### Syntaxe de base

```bash
# Du local vers le distant
scp fichier_local utilisateur@serveur:/chemin/destination

# Du distant vers le local
scp utilisateur@serveur:/chemin/fichier_distant /chemin/local

# Avec un port personnalisé
scp -P 2222 fichier utilisateur@serveur:/destination
```

> [!warning] Attention : -P majuscule pour SCP SCP utilise `-P` (majuscule) pour le port, contrairement à SSH qui utilise `-p` (minuscule).

#### Exemples pratiques

```bash
# Copier un fichier vers le serveur
scp rapport.pdf admin@192.168.1.100:/home/admin/documents/

# Copier un fichier depuis le serveur
scp admin@192.168.1.100:/var/log/syslog C:\Users\VotreNom\Desktop\

# Copier un dossier entier (récursif)
scp -r C:\projets\monapp admin@192.168.1.100:/var/www/

# Copier avec préservation des attributs (dates, permissions)
scp -p fichier.txt admin@serveur:/backup/

# Copier plusieurs fichiers
scp fichier1.txt fichier2.txt admin@serveur:/destination/

# Utiliser un alias configuré
scp document.pdf monserveur:/home/user/
```

#### Options utiles de SCP

|Option|Description|Exemple|
|---|---|---|
|`-r`|Copie récursive (dossiers)|`scp -r dossier/ user@host:/dest/`|
|`-p`|Préserve les dates et permissions|`scp -p fichier user@host:/dest/`|
|`-P`|Spécifie le port|`scp -P 2222 fichier user@host:/dest/`|
|`-C`|Active la compression|`scp -C gros_fichier user@host:/dest/`|
|`-v`|Mode verbeux (debugging)|`scp -v fichier user@host:/dest/`|
|`-q`|Mode silencieux|`scp -q fichier user@host:/dest/`|
|`-l`|Limite la bande passante (Kbit/s)|`scp -l 1024 fichier user@host:/dest/`|

> [!example] Cas d'usage avancé
> 
> ```bash
> # Copie récursive avec compression et limitation de bande passante
> scp -r -C -l 2048 C:\projets\site admin@serveur:/var/www/
> 
> # Copie avec préservation et mode verbeux pour le débogage
> scp -p -v document.txt admin@serveur:/backup/
> ```

### SFTP (SSH File Transfer Protocol)

SFTP offre une interface interactive pour le transfert de fichiers, similaire à FTP mais sécurisée.

#### Connexion SFTP

```bash
# Connexion standard
sftp utilisateur@serveur

# Avec port personnalisé
sftp -P 2222 utilisateur@serveur

# Connexion avec alias
sftp monserveur
```

#### Commandes SFTP essentielles

**Navigation :**

```bash
# Afficher le répertoire distant actuel
pwd

# Lister les fichiers du répertoire distant
ls
ls -la          # Avec détails

# Changer de répertoire distant
cd /chemin/distant

# Afficher le répertoire local actuel
lpwd

# Lister les fichiers du répertoire local
lls
lls -la

# Changer de répertoire local
lcd C:\Users\VotreNom\Documents
```

**Transfert de fichiers :**

```bash
# Télécharger un fichier (distant -> local)
get fichier_distant.txt

# Télécharger dans un dossier local spécifique
get fichier_distant.txt C:\Downloads\

# Télécharger un dossier entier
get -r dossier_distant

# Envoyer un fichier (local -> distant)
put fichier_local.txt

# Envoyer dans un dossier distant spécifique
put fichier_local.txt /home/user/documents/

# Envoyer un dossier entier
put -r C:\projets\monapp
```

**Gestion des fichiers distants :**

```bash
# Créer un dossier distant
mkdir nouveau_dossier

# Supprimer un fichier distant
rm fichier.txt

# Supprimer un dossier distant
rmdir dossier_vide

# Renommer/déplacer un fichier distant
rename ancien_nom.txt nouveau_nom.txt

# Changer les permissions d'un fichier distant
chmod 644 fichier.txt
chmod 755 script.sh
```

**Autres commandes utiles :**

```bash
# Afficher l'aide
help
?

# Quitter SFTP
exit
quit
bye
```

> [!example] Session SFTP typique
> 
> ```bash
> sftp admin@192.168.1.100
> Connected to 192.168.1.100.
> 
> sftp> pwd
> Remote working directory: /home/admin
> 
> sftp> ls
> documents    downloads    scripts
> 
> sftp> cd documents
> sftp> get rapport.pdf
> Fetching /home/admin/documents/rapport.pdf to rapport.pdf
> 
> sftp> lcd C:\Downloads
> sftp> put presentation.pptx
> Uploading presentation.pptx to /home/admin/documents/presentation.pptx
> 
> sftp> exit
> ```

### RSYNC via SSH

Rsync n'est pas natif sur Windows, mais peut être installé via WSL, Git Bash, ou Cygwin.

> [!info] Installation de rsync
> 
> - **Via Git for Windows** : rsync est inclus dans Git Bash
> - **Via WSL** : `sudo apt install rsync`
> - **Via Cygwin** : Sélectionner le package rsync lors de l'installation

#### Syntaxe rsync

```bash
# Synchronisation de base (local -> distant)
rsync -avz /chemin/local/ utilisateur@serveur:/chemin/distant/

# Synchronisation (distant -> local)
rsync -avz utilisateur@serveur:/chemin/distant/ /chemin/local/

# Avec un port SSH personnalisé
rsync -avz -e "ssh -p 2222" /local/ user@serveur:/distant/
```

#### Options importantes de rsync

|Option|Description|
|---|---|
|`-a`|Mode archive (préserve tout : permissions, dates, liens symboliques)|
|`-v`|Mode verbeux (affiche les fichiers transférés)|
|`-z`|Active la compression pendant le transfert|
|`-r`|Récursif (pour les dossiers)|
|`-h`|Format lisible pour les tailles de fichiers|
|`--progress`|Affiche la progression du transfert|
|`--delete`|Supprime les fichiers sur la destination qui n'existent plus sur la source|
|`--exclude`|Exclut des fichiers/dossiers du transfert|
|`-n` ou `--dry-run`|Simulation sans réellement transférer|

> [!example] Exemples rsync avancés
> 
> ```bash
> # Synchronisation complète avec progression
> rsync -avzh --progress /projets/site/ admin@serveur:/var/www/site/
> 
> # Synchronisation avec suppression des anciens fichiers
> rsync -avz --delete /backup/ admin@serveur:/backup/
> 
> # Exclure certains fichiers
> rsync -avz --exclude='*.log' --exclude='node_modules' \
>   /projets/app/ admin@serveur:/apps/app/
> 
> # Test de synchronisation (dry-run)
> rsync -avzn --delete /local/ user@serveur:/distant/
> 
> # Synchronisation avec bande passante limitée
> rsync -avz --bwlimit=1024 /gros_fichiers/ user@serveur:/backup/
> ```

> [!tip] Trailing slash importante
> 
> - `/dossier/` (avec slash) : copie le **contenu** du dossier
> - `/dossier` (sans slash) : copie le **dossier lui-même**
> 
> Exemple :
> 
> ```bash
> rsync -avz /projets/site/ user@serveur:/var/www/
> # Résultat : fichiers dans /var/www/
> 
> rsync -avz /projets/site user@serveur:/var/www/
> # Résultat : /var/www/site/ contenant les fichiers
> ```

### Comparaison des outils de transfert

|Outil|Avantages|Inconvénients|Cas d'usage|
|---|---|---|---|
|**SCP**|Simple, rapide, natif|Pas de reprise, transfert complet à chaque fois|Transferts ponctuels de fichiers|
|**SFTP**|Interface interactive, gestion fichiers|Plus lent que SCP|Exploration et gestion de fichiers distants|
|**RSYNC**|Transferts incrémentiels, très efficace|Installation nécessaire sur Windows|Synchronisations régulières, gros volumes|

---

## ✅ Bonnes pratiques

### Sécurité

> [!warning] Règles de sécurité essentielles

#### 1. Protection des clés privées

```bash
# Ne jamais partager votre clé privée
# Ne jamais la stocker sur des services cloud non chiffrés
# Toujours utiliser une passphrase forte

# Vérifier les permissions de vos clés (sous WSL/Git Bash)
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 700 ~/.ssh
```

#### 2. Authentification par clés plutôt que par mot de passe

```bash
# Désactiver l'authentification par mot de passe sur le serveur
# (à configurer dans /etc/ssh/sshd_config sur le serveur)
PasswordAuthentication no
PubkeyAuthentication yes
```

#### 3. Utilisation de l'agent SSH

```bash
# Utiliser ssh-agent pour ne pas avoir à retaper la passphrase
# Ajouter les clés au démarrage de votre session
ssh-add ~/.ssh/id_rsa
```

#### 4. Vérification des empreintes de clés

```bash
# À la première connexion, vérifier l'empreinte du serveur
# Comparer avec l'empreinte fournie par l'administrateur

# Afficher l'empreinte d'une clé publique
ssh-keygen -lf ~/.ssh/id_rsa.pub
```

### Configuration du fichier config

> [!tip] Organisation du fichier config

```bash
# Dans C:\Users\VotreNom\.ssh\config

# ========================================
# SERVEURS DE PRODUCTION
# ========================================

Host prod-web
    HostName 203.0.113.10
    User deployer
    Port 22
    IdentityFile ~/.ssh/prod_web_rsa
    ServerAliveInterval 60
    ServerAliveCountMax 3

Host prod-db
    HostName 203.0.113.20
    User dbadmin
    Port 2222
    IdentityFile ~/.ssh/prod_db_rsa
    ServerAliveInterval 60

# ========================================
# SERVEURS DE DÉVELOPPEMENT
# ========================================

Host dev-*
    User developer
    Port 22
    ForwardAgent yes
    ServerAliveInterval 120

Host dev-web
    HostName dev.example.com
    IdentityFile ~/.ssh/dev_rsa

Host dev-api
    HostName api-dev.example.com
    IdentityFile ~/.ssh/dev_rsa

# ========================================
# SERVEURS PERSONNELS
# ========================================

Host homelab
    HostName 192.168.1.100
    User admin
    Port 22
    IdentityFile ~/.ssh/homelab_rsa

# ========================================
# SERVICES EXTERNES
# ========================================

Host github.com
    User git
    IdentityFile ~/.ssh/github_rsa
    IdentitiesOnly yes

Host gitlab.com
    User git
    IdentityFile ~/.ssh/gitlab_rsa
    IdentitiesOnly yes

# ========================================
# CONFIGURATION PAR DÉFAUT
# ========================================

Host *
    ServerAliveInterval 120
    ServerAliveCountMax 3
    Compression yes
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m
```

### Options de configuration avancées

|Option|Description|Valeur recommandée|
|---|---|---|
|`ServerAliveInterval`|Envoie un signal au serveur régulièrement|`60` (secondes)|
|`ServerAliveCountMax`|Nombre de tentatives avant déconnexion|`3`|
|`Compression`|Compression des données transférées|`yes`|
|`ForwardAgent`|Transfert de l'agent SSH (attention sécurité)|`no` (sauf besoin spécifique)|
|`ControlMaster`|Réutilise les connexions SSH existantes|`auto`|
|`ControlPersist`|Garde la connexion ouverte|`10m`|
|`StrictHostKeyChecking`|Vérification stricte des clés d'hôte|`ask` ou `yes`|

### Gestion des sessions

#### Sessions persistantes avec tmux/screen

```bash
# Se connecter et démarrer une session tmux
ssh serveur 'tmux attach || tmux new -s travail'

# Lancer une commande en arrière-plan
ssh serveur 'nohup ./mon_script.sh > sortie.log 2>&1 &'
```

#### Connexions multiples optimisées

```bash
# Configuration pour réutiliser les connexions SSH
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m

# Créer le dossier pour les sockets (sous Git Bash/WSL)
mkdir -p ~/.ssh/sockets
```

> [!info] Multiplexage de connexions Avec `ControlMaster`, la première connexion SSH crée une "connexion maître". Les connexions suivantes réutilisent cette connexion, ce qui :
> 
> - Accélère les nouvelles connexions (pas de nouvelle authentification)
> - Réduit la charge sur le serveur
> - Permet de garder une connexion active même après fermeture des sessions

### Diagnostic et dépannage

#### Mode debug SSH

```bash
# Niveau 1 de verbosité
ssh -v utilisateur@serveur

# Niveau 2 (plus d'informations)
ssh -vv utilisateur@serveur

# Niveau 3 (maximum de détails)
ssh -vvv utilisateur@serveur
```

> [!tip] Que regarder dans les logs
> 
> - **Authentication methods** : méthodes d'authentification tentées
> - **Key exchange** : échange de clés SSL/TLS
> - **Permissions** : erreurs de permissions sur les fichiers de clés
> - **Connection attempts** : tentatives de connexion et réponses du serveur

#### Problèmes courants et solutions

|Problème|Cause probable|Solution|
|---|---|---|
|`Permission denied (publickey)`|Clé publique non installée sur le serveur|Copier la clé avec `ssh-copy-id`|
|`Connection refused`|Port fermé ou service SSH arrêté|Vérifier le port et le service sur le serveur|
|`Connection timeout`|Firewall ou mauvaise adresse|Vérifier les règles firewall et l'adresse|
|`Host key verification failed`|Clé du serveur a changé|Supprimer l'ancienne clé dans `known_hosts`|
|`Bad owner or permissions`|Permissions incorrectes sur les fichiers|`chmod 600 ~/.ssh/id_rsa` et `chmod 700 ~/.ssh`|

#### Nettoyer le fichier known_hosts

```bash
# Supprimer une clé d'hôte spécifique
ssh-keygen -R serveur.example.com
ssh-keygen -R 192.168.1.100

# Fichier known_hosts sur Windows
# C:\Users\VotreNom\.ssh\known_hosts
```

### Automatisation et scripts

#### Scripts PowerShell pour automatisation

```powershell
# Script de sauvegarde automatique via SSH
$serveur = "admin@192.168.1.100"
$source = "/var/www/monsite"
$destination = "C:\Backups\monsite_$(Get-Date -Format 'yyyyMMdd')"

# Créer le dossier de backup local
New-Item -ItemType Directory -Force -Path $destination

# Utiliser SCP pour récupérer les fichiers
scp -r "${serveur}:${source}" $destination

Write-Host "Backup terminé dans $destination"
```

#### Exécution de commandes distantes

```bash
# Exécuter une commande simple
ssh serveur 'df -h'

# Exécuter plusieurs commandes
ssh serveur 'cd /var/log && tail -n 50 syslog'

# Exécuter un script local sur le serveur distant
ssh serveur 'bash -s' < mon_script_local.sh

# Avec des variables
$commande = "systemctl status nginx"
ssh serveur $commande
```

### Optimisation des performances

#### Compression et algorithmes

```bash
# Configuration optimisée pour les connexions lentes
Host serveur-distant
    Compression yes
    CompressionLevel 6
    Ciphers aes128-gcm@openssh.com,aes256-gcm@openssh.com

# Configuration pour les réseaux rapides (LAN)
Host serveur-local
    Compression no
    Ciphers aes128-ctr,aes192-ctr,aes256-ctr
```

#### Transferts de gros volumes

```bash
# SCP avec compression
scp -C gros_fichier.tar user@serveur:/backup/

# Rsync avec compression et parallélisation
rsync -avz --progress --partial \
  /gros_dossier/ user@serveur:/backup/
```

> [!tip] Option --partial de rsync Permet de reprendre un transfert interrompu sans tout recommencer. Très utile pour les gros fichiers ou connexions instables.

### Sécurité avancée

#### Limitation des accès dans le fichier config

```bash
# Restriction d'accès pour certains serveurs sensibles
Host prod-*
    IdentityFile ~/.ssh/prod_key
    IdentitiesOnly yes
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    PubkeyAuthentication yes

# Serveurs de développement (moins restrictifs)
Host dev-*
    PasswordAuthentication yes
    PubkeyAuthentication yes
```

#### Audit et surveillance

```bash
# Vérifier les connexions SSH actives sur votre machine Windows
netstat -an | findstr :22

# Lister les clés chargées dans l'agent SSH
ssh-add -l

# Afficher les empreintes des clés
ssh-add -l -E sha256
ssh-add -l -E md5
```

#### Double authentification (2FA)

> [!info] Authentification multi-facteurs Certains serveurs peuvent être configurés pour utiliser une double authentification :
> 
> - Clé SSH + mot de passe
> - Clé SSH + code OTP (Google Authenticator, etc.)
> 
> Configuration effectuée côté serveur, mais le client Windows doit être prêt à fournir les deux facteurs.

### Sauvegarde et documentation

#### Sauvegarder vos clés SSH

> [!warning] Importance des sauvegardes
> 
> - Sauvegarder vos clés privées dans un endroit sécurisé (coffre-fort de mots de passe, stockage chiffré)
> - Ne jamais les stocker en clair sur des services cloud publics
> - Documenter quelle clé correspond à quel serveur

```powershell
# Exemple de script de sauvegarde sécurisé (avec 7-Zip pour le chiffrement)
$date = Get-Date -Format "yyyyMMdd"
$backup = "C:\Backups\ssh_keys_backup_$date.7z"

# Compresser et chiffrer les clés SSH
7z a -p -mhe=on $backup C:\Users\VotreNom\.ssh\*.pem C:\Users\VotreNom\.ssh\id_*

Write-Host "Backup créé : $backup"
Write-Host "ATTENTION : Stocker ce fichier dans un endroit sécurisé !"
```

#### Documentation de votre configuration

```bash
# Créer un fichier de documentation dans votre dossier .ssh
# C:\Users\VotreNom\.ssh\README.md

# Exemple de contenu :
# # Configuration SSH
# 
# ## Clés disponibles
# 
# - `id_rsa` : Clé personnelle par défaut (créée le 2024-01-15)
# - `prod_rsa` : Accès aux serveurs de production (créée le 2024-02-20)
# - `github_rsa` : Accès GitHub (créée le 2024-01-20)
# 
# ## Serveurs configurés
# 
# ### Production
# - `prod-web` : 203.0.113.10 (deployer)
# - `prod-db` : 203.0.113.20 (dbadmin)
# 
# ### Développement
# - `dev-web` : dev.example.com (developer)
# 
# ## Renouvellement des clés
# - Clés de production : à renouveler tous les 6 mois
# - Dernière rotation : 2024-02-20
# - Prochaine rotation : 2024-08-20
```

### Intégration avec des outils Windows

#### SSH avec PowerShell

```powershell
# Fonction PowerShell pour simplifier les connexions SSH
function Connect-SSH {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Server,
        [string]$User = "admin"
    )
    
    ssh "$User@$Server"
}

# Utilisation
Connect-SSH -Server "192.168.1.100" -User "root"

# Fonction pour copier des fichiers via SCP
function Copy-ToSSH {
    param(
        [Parameter(Mandatory=$true)]
        [string]$LocalPath,
        [Parameter(Mandatory=$true)]
        [string]$Server,
        [Parameter(Mandatory=$true)]
        [string]$RemotePath,
        [string]$User = "admin"
    )
    
    scp -r $LocalPath "${User}@${Server}:${RemotePath}"
}
```

#### SSH avec Windows Terminal

```json
// Configuration dans settings.json de Windows Terminal
{
    "profiles": {
        "list": [
            {
                "name": "SSH - Serveur Production",
                "commandline": "ssh prod-web",
                "icon": "🖥️",
                "colorScheme": "Campbell"
            },
            {
                "name": "SSH - Serveur Dev",
                "commandline": "ssh dev-web",
                "icon": "🔧",
                "colorScheme": "One Half Dark"
            }
        ]
    }
}
```

#### Intégration avec VS Code

> [!tip] Extension Remote-SSH Visual Studio Code offre une extension "Remote - SSH" qui permet de :
> 
> - Se connecter à des serveurs distants
> - Éditer des fichiers directement sur le serveur
> - Exécuter des commandes dans un terminal distant
> - Déboguer des applications à distance
> 
> Installation : Rechercher "Remote - SSH" dans les extensions VS Code

Configuration pour VS Code :

```json
// Dans .vscode/settings.json ou settings utilisateur
{
    "remote.SSH.configFile": "C:\\Users\\VotreNom\\.ssh\\config",
    "remote.SSH.showLoginTerminal": true,
    "remote.SSH.remotePlatform": {
        "prod-web": "linux",
        "dev-web": "linux"
    }
}
```

### Tunnels SSH (Port Forwarding)

#### Tunnel local (Local Port Forwarding)

```bash
# Rediriger un port local vers un service distant
# ssh -L port_local:host_destination:port_destination utilisateur@serveur

# Exemple : Accéder à une base de données distante localement
ssh -L 3306:localhost:3306 admin@serveur-db

# Maintenant vous pouvez vous connecter à localhost:3306 sur votre machine Windows
# et cela sera redirigé vers le port 3306 du serveur distant
```

> [!example] Cas d'usage : Base de données
> 
> ```bash
> # Tunnel vers MySQL/MariaDB
> ssh -L 3306:localhost:3306 user@db-server
> 
> # Tunnel vers PostgreSQL
> ssh -L 5432:localhost:5432 user@db-server
> 
> # Tunnel vers MongoDB
> ssh -L 27017:localhost:27017 user@mongo-server
> 
> # Vous pouvez ensuite utiliser vos outils locaux (HeidiSQL, DBeaver, etc.)
> # pour vous connecter à localhost:3306
> ```

#### Tunnel distant (Remote Port Forwarding)

```bash
# Exposer un service local sur le serveur distant
# ssh -R port_distant:localhost:port_local utilisateur@serveur

# Exemple : Partager un serveur web local
ssh -R 8080:localhost:3000 admin@serveur-public

# Le serveur distant peut maintenant accéder à votre service local
# via son propre localhost:8080
```

#### Tunnel dynamique (SOCKS Proxy)

```bash
# Créer un proxy SOCKS
ssh -D 1080 utilisateur@serveur

# Configurer ensuite votre navigateur pour utiliser :
# Proxy SOCKS5 : localhost:1080
```

> [!tip] Usage du proxy SOCKS Permet de router tout votre trafic web à travers le serveur SSH, utile pour :
> 
> - Accéder à des ressources internes d'un réseau
> - Contourner des restrictions réseau
> - Sécuriser votre connexion sur des réseaux non fiables

#### Tunnel SSH persistant en arrière-plan

```bash
# Garder le tunnel ouvert sans interaction
ssh -f -N -L 3306:localhost:3306 admin@serveur

# Options :
# -f : Passe en arrière-plan après l'authentification
# -N : Ne pas exécuter de commande distante
# -L : Définit le port forwarding
```

### Journalisation et monitoring

#### Activer la journalisation SSH

```bash
# Dans votre fichier config
Host *
    LogLevel INFO
    # Niveaux disponibles : QUIET, FATAL, ERROR, INFO, VERBOSE, DEBUG, DEBUG1, DEBUG2, DEBUG3
```

#### Script de monitoring des connexions

```powershell
# Script PowerShell pour surveiller les connexions SSH actives
function Get-SSHConnections {
    Write-Host "=== Connexions SSH actives ===" -ForegroundColor Green
    
    # Connexions sortantes SSH
    $ssh_connections = netstat -an | Select-String ":22.*ESTABLISHED"
    
    if ($ssh_connections) {
        $ssh_connections | ForEach-Object {
            Write-Host $_ -ForegroundColor Yellow
        }
    } else {
        Write-Host "Aucune connexion SSH active" -ForegroundColor Gray
    }
    
    Write-Host "`n=== Clés chargées dans ssh-agent ===" -ForegroundColor Green
    ssh-add -l
}

# Utilisation
Get-SSHConnections
```

### Pièges courants à éviter

> [!warning] Erreurs fréquentes

#### 1. Mauvaises permissions sur les fichiers

```bash
# Problème : Permissions trop ouvertes
# SSH refusera d'utiliser une clé privée si elle est accessible par d'autres

# Solution (sous Git Bash ou WSL) :
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 700 ~/.ssh
chmod 644 ~/.ssh/config
```

#### 2. Espaces dans les chemins Windows

```bash
# Problème
ssh-add C:\Users\Mon Nom\.ssh\id_rsa  # ERREUR

# Solution : Utiliser des guillemets
ssh-add "C:\Users\Mon Nom\.ssh\id_rsa"

# Ou utiliser le format Unix-like dans Git Bash
ssh-add /c/Users/Mon\ Nom/.ssh/id_rsa
```

#### 3. Clé publique mal copiée

```bash
# Problème : La clé publique s'affiche sur plusieurs lignes
# Elle doit être sur UNE SEULE ligne dans authorized_keys

# Mauvais format dans authorized_keys :
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC...
...suite de la clé...
...fin

# Bon format :
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC...toute_la_clé_sur_une_seule_ligne... user@host
```

#### 4. Oublier le trailing slash avec rsync

```bash
# Avec slash : copie le CONTENU
rsync -avz /source/ user@server:/dest/
# Résultat : fichiers directement dans /dest/

# Sans slash : copie le DOSSIER
rsync -avz /source user@server:/dest/
# Résultat : /dest/source/fichiers
```

#### 5. Utiliser -p au lieu de -P avec SCP

```bash
# Erreur commune
scp -p 2222 fichier user@server:/dest/  # -p = preserve, pas port !

# Correct
scp -P 2222 fichier user@server:/dest/  # -P = port
```

### Astuces avancées

#### Alias PowerShell pour SSH

```powershell
# Dans votre profil PowerShell ($PROFILE)
# Créer si nécessaire : New-Item -Path $PROFILE -ItemType File -Force

# Alias de connexion rapide
Set-Alias -Name sshprod -Value "ssh prod-web"
Set-Alias -Name sshdev -Value "ssh dev-web"

# Fonction pour SCP rapide
function scp-to-prod {
    param([string]$file)
    scp $file prod-web:/tmp/
}

# Fonction pour se connecter avec exécution de commande
function ssh-run {
    param(
        [string]$host,
        [string]$command
    )
    ssh $host $command
}
```

#### Copier rapidement votre clé publique

```powershell
# Copier dans le presse-papiers (Windows 10+)
type C:\Users\VotreNom\.ssh\id_rsa.pub | clip

# Ensuite, collez simplement dans l'interface web du serveur
# ou dans authorized_keys via une session SSH
```

#### Connexion SSH avec expiration automatique

```bash
# Déconnecter automatiquement après 30 minutes d'inactivité
ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=30 user@server
```

#### Créer un raccourci Bureau pour une connexion SSH

1. Clic droit sur le Bureau → Nouveau → Raccourci
2. Emplacement : `C:\Windows\System32\cmd.exe /k ssh prod-web`
3. Nom : "SSH - Serveur Production"
4. Changer l'icône si désiré

### Check-list finale de sécurité

> [!tip] Vérifications régulières

- [ ] Toutes les clés privées ont une passphrase
- [ ] Les clés privées ne sont jamais partagées ou envoyées
- [ ] Le fichier `config` est bien configuré avec des alias
- [ ] L'agent SSH est configuré pour ne pas redemander les passphrases
- [ ] Les clés sont sauvegardées dans un endroit sécurisé
- [ ] Les permissions des fichiers SSH sont correctes
- [ ] Les serveurs distants utilisent uniquement l'authentification par clé
- [ ] Les clés sont renouvelées régulièrement (tous les 6-12 mois)
- [ ] Le fichier `known_hosts` est vérifié périodiquement
- [ ] Les logs SSH sont consultés pour détecter des tentatives suspectes
- [ ] Les tunnels SSH non utilisés sont fermés
- [ ] La documentation de configuration est à jour

### Commandes de référence rapide

```bash
# ============================================
# CONNEXIONS
# ============================================
ssh user@host                    # Connexion standard
ssh -p 2222 user@host           # Port personnalisé
ssh -i ~/.ssh/key user@host     # Clé spécifique
ssh user@host 'commande'        # Exécuter une commande

# ============================================
# GESTION DES CLÉS
# ============================================
ssh-keygen -t rsa -b 4096       # Générer une clé RSA
ssh-keygen -t ed25519           # Générer une clé Ed25519
ssh-copy-id user@host           # Copier la clé publique
ssh-add ~/.ssh/id_rsa           # Ajouter clé à l'agent
ssh-add -l                      # Lister les clés chargées
ssh-add -D                      # Supprimer toutes les clés

# ============================================
# TRANSFERT DE FICHIERS
# ============================================
scp file user@host:/path        # Copier vers distant
scp user@host:/path file        # Copier depuis distant
scp -r dir user@host:/path      # Copier dossier
sftp user@host                  # Session SFTP interactive
rsync -avz src/ user@host:/dst/ # Synchronisation

# ============================================
# TUNNELS SSH
# ============================================
ssh -L 3306:localhost:3306 user@host  # Tunnel local
ssh -R 8080:localhost:80 user@host    # Tunnel distant
ssh -D 1080 user@host                 # Proxy SOCKS
ssh -f -N -L 3306:localhost:3306 user@host  # Tunnel persistant

# ============================================
# DEBUG ET DIAGNOSTIC
# ============================================
ssh -v user@host                # Mode verbeux
ssh -vvv user@host              # Mode très verbeux
ssh-keygen -R hostname          # Supprimer clé d'hôte
netstat -an | findstr :22       # Connexions SSH actives

# ============================================
# CONFIGURATION
# ============================================
# Fichier config : C:\Users\VotreNom\.ssh\config
# Format :
# Host alias
#     HostName ip.ou.domaine
#     User username
#     Port 22
#     IdentityFile ~/.ssh/key
```

---

**🎯 Résumé des points clés**

1. **OpenSSH est natif** sur Windows 10/11 - pas besoin d'outils tiers
2. **Utilisez toujours des clés SSH** plutôt que des mots de passe
3. **Protégez vos clés privées** avec une passphrase forte
4. **Le fichier config** simplifie grandement l'utilisation quotidienne
5. **ssh-agent** évite de retaper les passphrases constamment
6. **SCP pour les transferts simples**, SFTP pour l'interactif, rsync pour la synchronisation
7. **Les tunnels SSH** sont puissants pour accéder aux services distants
8. **Documentez votre configuration** pour vous y retrouver plus tard
9. **Sauvegardez vos clés** dans un endroit sécurisé
10. **Vérifiez régulièrement** la sécurité de votre configuration